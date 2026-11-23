/***************************************************************************************************************************************
Apex Class Name     : PRM_AGSFailureNotifierBacth
Version             : 1.0
Created Date        : March 2022
Function            : Batch class to  notification to IPA admins about AGS identity Creation failure
Modification Log    :
* Developer                         Date                           Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------
* Sathya                        March 2022                     Batch class to to notification to IPA admins about AGS identity Creation failure
*************************************************************************************************************************************************************/
global class PRM_AGSFailureNotifierBatch implements Database.Batchable<sObject>{
    public static String LOG_ENTRY_ORIGIN  = 'PRM_AGSFailureNotifierBatch';
    public static String LOG_ENTRY_SEVERITY  = 'Medium';
    public static String LOG_ENTRY_PROJECT  = 'IPA';
    public Datetime MinDiff = Datetime.now().addMinutes(-(integer.valueof(LABEL.PRM_AGS_WaitTime)));
    public set<id> ACRIds;
    public OrgWideEmailAddress owea;
    public string ReportLink;

    global  PRM_AGSFailureNotifierBatch(set<id> ACRIdset){
        this.ACRIds=ACRIdset;
    }
    
    global  Database.QueryLocator start(Database.BatchableContext context){
         String query;
         try{
            Trigger_Execution__mdt TE = Trigger_Execution__mdt.getInstance('PRM_AGSFailureNotifierBatch');
            //Switch to turn on/off Excution
            if(TE!=null && TE.Active__c){
                query = 'SELECT ID, Name,PRM_Contact_Id__c,PRM_Contact_Id__r.email,PRM_Record_Link__c, PRM_AGS_Failure_Notified__c,PRM_Contact_Id__r.Core_Enterprise_Id__c, PRM_InActive_Ind__c, PRM_Initiated_By__c,PRM_Activated_Date__c,PRM_Source_Agent__C  ' +
                        ' FROM PRM_Account_Contact_Relationship__c WHERE PRM_Contact_Id__r.Core_Enterprise_Id__c=null ' +
                        ' AND PRM_Activated_Date__c <:MinDiff '+
                        ' AND PRM_Activated_Date__c= TODAY '+
                        ' AND PRM_InActive_Ind__c=false ' +
                        ' AND PRM_AGS_Failure_Notified__c=false ';                               
                system.debug('--query '+query);
            }
         }
         catch(Exception e){
         
         }
        return Database.getQueryLocator(query);
    } 
   
    
    global void execute(Database.BatchableContext context, List<PRM_Account_Contact_Relationship__c> scope){
        list<PRM_Account_Contact_Relationship__c> UpdateACrList=new list<PRM_Account_Contact_Relationship__c>();
        List<Id> UserIds=new list<Id>();
        List<Id> PGUserIds=new list<Id>();
        EmailTemplate template;
        list<Messaging.SingleEmailMessage> totalMailList=new list<Messaging.SingleEmailMessage>();
        system.debug('---Scope '+scope.size()+scope);
        TRY{
            //Query to get Report Link
            Report rep=[select id from Report where developername='AGS_Identity_Creation_Failure_Report'];
            string reporturl=URL.getSalesforceBaseUrl().toExternalForm()+'/'+rep.Id;
            ReportLink='<a href='+ reporturl +'>'+' here ' + '</a>';            
           
                //Template for PartnerInvite
                EmailTemplate PAtemplateId = [select id, name,HtmlValue,Body,Subject from EmailTemplate where developername =: system.label.IPA_AGS_IdentityFail_TEMPLATE ];
                //OWA
                owea= [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com LIMIT 1];

                //get userids from public group
                for(user u:[SELECT Id, Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Developername = :'PRM_IPA_Registration_Approvers')]){
                    PGUserIds.add(u.Id);                
                }
                for(PRM_Account_Contact_Relationship__c acr:scope ){
                    if(acr.PRM_Source_Agent__C!=null){                
                        acr.PRM_AGS_Failure_Notified__c=true;
                        UpdateACrList.add(acr);                    
                        string recordLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+acr.Id;
                        if(acr.PRM_Source_Agent__C=='Partner Invite'){
                            UserIds=PGUserIds;
                            template=PAtemplateId;
                        }
                        list<Messaging.SingleEmailMessage> mailList=sendEmail(acr.PRM_Contact_Id__r.email,recordLink,template,UserIds);
                        if(mailList.size()>0)
                        totalMailList.addall(mailList);
                    }
                }
                
               //Send Mail 
               if(totalMailList.size()>0)
                   Messaging.sendEmail( totalMailList );
                
                if(UpdateACrList.size()>0)
                    Update UpdateACrList;
            
        }
        CATCH(EXCEPTION e){
            system.debug('--Exception '+ e.getmessage());
            Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_ORIGIN, LOG_ENTRY_SEVERITY,'PRM_AGSFailureNotifierBatch '+system.now() ,e.getmessage()  , '', '', '');           
        }
        
    }
    
    global void finish(Database.BatchableContext context){
       
    }
    
    Public  list<Messaging.SingleEmailMessage> sendEmail(string contactEmail,string recordLink,EmailTemplate ET, list<id> userId){
        String htmlBody;
        list<Messaging.SingleEmailMessage> singlemailList=new list<Messaging.SingleEmailMessage>();
        if(userId.size()>0){
            if(ET!=null)
                htmlBody = ET.HtmlValue;
            if(STRING.ISNOTBLANK(contactEmail))
                htmlBody = htmlBody.replace('%%email Id%%', contactEmail); 
            if(STRING.ISNOTBLANK(recordLink))
                htmlBody = htmlBody.replace('%link%', recordLink);
            if(STRING.ISNOTBLANK(ReportLink))
                htmlBody = htmlBody.replace('%%Report%%', ReportLink);          
                
            for(id usrid: userId){                 
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(usrid );
                mail.setSubject(ET.Subject);
                mail.setSaveAsActivity(false);
                mail.setHtmlBody(htmlBody);
                mail.setTemplateId(ET.id);
                if (owea!=null) 
                    mail.setOrgWideEmailAddressId(owea.Id); // Setting From address in the email
                singlemailList.add(mail);
           }
       }
       return  singlemailList;
    } 
}