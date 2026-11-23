/**************************************************************************************************************
Apex Class Name:  PRM_EmailReminderBatch
Version     : 1.0 
Created Date: 22 May 2020
Function    : This batch is to process all the contacts with pending status PCR. We would be sending reminder emails to these contacts.
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Sayeed Javid        02/14/2022        Initial version
***************************************************************************************************************/
global with sharing class PRM_EmailReminderBatch implements  Database.Batchable<sObject>,Database.AllowsCallouts,Database.stateful {
    
    
    public Set<Id> processIDs = new Set<Id>();    
    // List<Core_OnePartner_Inbound_Message__c> inboundMessageforBatch2 = new  List<Core_OnePartner_Inbound_Message__c>();        
    // public List<Core_Account_Group_Member__c> cagIds = new List<Core_Account_Group_Member__c>();
    // public Set<String> opidIds = new Set<String>();
    public Set<String> intelAccountIds = new Set<String>(); 
    global String logEntryMsg='';
    
    public static final String LOG_ENTRY_ORIGIN = 'PRM_EmailReminderBatch';
    public static final String LOG_ENTRY_PROJECT = 'IPA';
    public static final String LOG_ENTRY_SCOPE = 'PRM_EmailReminderBatch';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String PRM_PROCESSINBOUNDCLASS = 'PRM_EmailReminderBatch';
    string Pending_Action = System.label.Pending_Action ;    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //check if another apex job for this batch class is already running or in hold
        Id currentJobId = bc.getJobId();
        List<AsyncApexJob> apexJobsList = [Select id from AsyncApexJob where Status IN ('Holding', 'Preparing', 'Processing', 'Queued') and ApexClass.Name = :PRM_PROCESSINBOUNDCLASS and id != :currentJobId];
        if(!apexJobsList.isEmpty()){            
            System.abortJob(currentJobId);
        }
        // batch will run at specific time and will get all the records with status as new  and will pass it to execute method 
        String query = 'SELECT Id,PRM_Soft_Contact__c,PRM_InActive_Ind__c,PRM_No_Email__c,PRM_Contact_Id__c,PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c,PRM_CampaignId__c,PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c FROM PRM_Account_Contact_Relationship__c  WHERE PRM_InActive_Ind__c=false and PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c = true and PRM_Status_Nm__c =:Pending_Action and PRM_CampaignId__c = null and CreatedDate = LAST_N_DAYS:50';
        return Database.getQueryLocator(query);
        //added by Anish - end
        
    }
    
    global void execute(Database.BatchableContext bc, List<PRM_Account_Contact_Relationship__c> inboundprocess) {//cognitive complexity of 57
        logEntryMsg+='\nJob started at:'+System.Now().format('MM/dd/YYYY HH:MM:SS','PST')+' PST dt@@@';
        set<id> ContactIdSet = new set<id>();  
        Map<id,PRM_Account_Contact_Relationship__c> ContactInputMap = new Map<id,PRM_Account_Contact_Relationship__c>(); 
       // List<PRM_Account_Contact_Relationship__c> Invitemail = new  List<PRM_Account_Contact_Relationship__c>(); 
       // List<PRM_Account_Contact_Relationship__c> EVTokeneMail = new  List<PRM_Account_Contact_Relationship__c>(); 
        Map<id,contact> ContMap = new Map<id,contact>();     
        Map<id,List<PRM_EmailLog__c>> EmailContactMap = new Map<id,list<PRM_EmailLog__c>>(); 
        List<string> allLangTemplate = System.Label.PRM_EmailTemplate_Languages.split(';') ;                                 //TWC729-3350-OtherLanguages-addition
        List<string> allLangTemplate_PartnerInvite = System.Label.PRM_EmailTemplate_Languages_partnerInvite.split(';') ;     //TWC729-3350-OtherLanguages-addition

        for(PRM_Account_Contact_Relationship__c acr : inboundprocess){
            ContactIdSet.add(acr.PRM_Contact_Id__c)  ;
            ContactInputMap.put(acr.PRM_Contact_Id__c,acr);   
        }
        if(!ContactIdSet.IsEmpty()){
            for(PRM_EmailLog__c EmailLog : [select id, name, PRM_Subject__c  , CreatedDate, PRM_Contact__c,PRM_Contact__r.email , PRM_Contact__r.Core_IPA_Email_Verification_Date__c ,Email_Reminder__c from PRM_EmailLog__c where PRM_Contact__c in :ContactIdSet and (Email_Template_Name__c in: allLangTemplate or Email_Template_Name__c in: allLangTemplate_PartnerInvite)  order by CreatedDate desc  ]){  //TWC729-3350-OtherLanguages-addition
                if(EmailContactMap.keyset().contains(EmailLog.PRM_Contact__c)){
                    // this map will have unique contacts with their latest email log version
                    List<PRM_EmailLog__c> ListEmailLogs = EmailContactMap.get(EmailLog.PRM_Contact__c);
                    ListEmailLogs.add(EmailLog);
                    EmailContactMap.put(EmailLog.PRM_Contact__c, ListEmailLogs);
                }
                else{
                    EmailContactMap.put(EmailLog.PRM_Contact__c,new List<PRM_EmailLog__c>{EmailLog}) ;
                }                
            }
        }
        
        // Below loop is to get the details of contact record
        if(!ContactIdSet.IsEmpty()){
            //calling 
            fetchAndPopulateContacts(ContactIdSet, ContMap);
            /*if(IS_CIDAAS_ENABLED){ //As a part of CiDaaS change
                ContMap.putAll([select id,name, email,Core_IPA_PartnerRole__c,Core_Preferred_Language__c,MailingCountryCode,AccountId,Account.AccountNumber,Account.name  from Contact where id in :ContactIdSet]);
            }
            else{
                ContMap.putAll([select id,name, email,Core_IPA_PartnerRole__c,Core_Preferred_Language__c,MailingCountryCode,AccountId,Account.AccountNumber,Account.name, Core_IPA_Email_Verification_Date__c ,Core_Email_Verification_Token__c, Core_Password_Token__c from Contact where id in :ContactIdSet]);            
            }*/
        }
        
        if (!EmailContactMap.isEmpty()) {
        sendEmailToContacts(EmailContactMap,ContMap);     }  
    }

    public void fetchAndPopulateContacts(Set<Id> contactIdSet, Map<Id, Contact> contMap) {
        if (!contactIdSet.isEmpty()) {          
                ContMap.putAll([select id,name, email,Core_IPA_PartnerRole__c,Core_Preferred_Language__c,MailingCountryCode,AccountId,Account.AccountNumber,Account.name  from Contact where id in :ContactIdSet]);            
        }
    }
    
    
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,  
                            TotalJobItems, CreatedBy.Email 
                            FROM AsyncApexJob 
                            WHERE Id = :bc.getJobId()]; 
        logEntryMsg+='\n*1st JOB END*';
    }   
    public static void sendEmailToContacts(Map<id,List<PRM_EmailLog__c>> EmailContactMap, Map<id,contact> ContMap){
        
        Map<id,PRM_EmailLog__c>  EmaillWithoutEv = new Map<id,PRM_EmailLog__c>();
        Map<id,PRM_EmailLog__c> EmaillogListMap = new Map<id,PRM_EmailLog__c>();  
        set<id> EmaillWithEVSet = new set<id> ();
        Integer Intervals   = integer.valueof(system.label.PRM_Intervals) ;
        Integer No_Of_reminders = integer.valueof(system.label.PRM_No_Of_Reminders) ;

        for (Id conts : EmailContactMap.keyset()){
            if (EmailContactMap.get(conts).size() <=  No_Of_reminders  && String.valueOf(EmailContactMap.get(conts)[0].CreatedDate.adddays(Intervals).date()).substring(0,10) == String.valueOf(system.today()).substring(0,10) ){
                
                //As a part of CiDaaS change
                //Considering EmaillWithEVSet as the primary set for further processes since we won't have dynamic links to do step 1 and step 2 which has value stored in EmaillWithEVSet and EmaillWithoutEV as part of CiDaaS.               
                    EmaillogListMap.put(EmailContactMap.get(conts)[0].PRM_Contact__c,EmailContactMap.get(conts)[0]) ;
                    EmaillWithEVSet.add(EmailContactMap.get(conts)[0].PRM_Contact__c);                                      
            }
        }
        sendEmail(EmaillogListMap,EmaillWithoutEv,EmaillWithEVSet,ContMap);
    }
    public static void sendEmail(Map<id,PRM_EmailLog__c> EmaillogListMap, Map<id,PRM_EmailLog__c>  EmaillWithoutEv, set<id> EmaillWithEVSet, Map<id,contact> ContMap){
        Map<id,string> EmaillWithEVFinal = new Map<id,string> () ;   
        for(Id contid : EmaillogListMap.keyset() ){
            if(EmaillWithEVSet.contains(contid)){
                String evtoken = null;
                EmaillWithEVFinal.put(contid,evtoken);   
            }
        }
        sendEmailWithEV(EmaillWithEVFinal,EmaillWithEVSet,ContMap);
        sendEmailWithoutEV(EmaillWithEVFinal,EmaillWithoutEV,ContMap);
    }
    public static void sendEmailWithEV(Map<id,string> EmaillWithEVFinal,set<id> EmaillWithEVSet,Map<id,contact> ContMap){
        if(!EmaillWithEVSet.isEmpty()){
            for(id cont: EmaillWithEVSet){
               if(ContMap.get(cont) != null && EmaillWithEVFinal.containsKey(cont)){                                 
               PRM_Contact_AGS_CallbackHandler.sendEmailToContact(ContMap.get(cont) ,EmaillWithEVFinal.get(cont), null);
                }
            }
        }
    }
    public static void sendEmailWithoutEV(Map<id,string> EmaillWithEVFinal,Map<id,PRM_EmailLog__c> EmaillWithoutEV,Map<id,contact> ContMap){
        if(!EmaillWithoutEV.keyset().isEmpty()){
            for(id cont: EmaillWithoutEV.keyset()){
                if(ContMap.get(cont) != null){
                PRM_Contact_AGS_CallbackHandler.sendEmailToContact(ContMap.get(cont) ,EmaillWithEVFinal.get(cont), null);
                }
            }
        } 

    }
}