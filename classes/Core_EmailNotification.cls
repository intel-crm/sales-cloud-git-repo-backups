/**************************************************************************************
Apex Class Name:  Core_EmailNotification
Version     : 1.0 
Created Date: 26 FEB 2023
Function    : 
Test Class Name: Core_EmailNotificationTest
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay					  20/05/2023			  Common class for Email notification
*************************************************************************************/
public without sharing class Core_EmailNotification implements Queueable{
    
    public static List<OrgWideEmailAddress> OrgWideAddress = [SELECT Id  FROM OrgWideEmailAddress where Address = 'wsm-postmaster@intel.com' limit 1];
    public static Map<Id,List<Id>> acceptedUser = new Map<Id , List<Id>>();
    public static Map<Id,Core_Opportunity_Support_Team__c> OppSupTeam =  new Map<Id,Core_Opportunity_Support_Team__c>();
    public  Set<Id> supportReqId;
    public  string templateName;
    public boolean checkExcution = false;
   
    public Core_EmailNotification(Set<Id> supportReqId, String templateName,boolean checkExcution) {
        this.supportReqId = supportReqId;
        this.templateName = templateName;
        this.checkExcution = checkExcution;
        
    }
    public void execute(QueueableContext context) {
       
        if(checkExcution)
        	sendNotificationApprover(supportReqId,templateName);
        else 
           updateApproveOrRejectComents(supportReqId);
       
    }
    public static Messaging.SingleEmailMessage createEmailList(String emailTemplate, List<String> toAddresses, List<String> ccAddresses, Id recordId, id OrgWideAddress ){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        if(emailTemplate != null && toAddresses.size() > 0 && recordId != null && OrgWideAddress != null){            
            email.setToAddresses(toAddresses);
            if(ccAddresses.size() > 0)
                email.setCcAddresses(ccAddresses);
            email.setTemplateId(emailTemplate);
            email.setTargetObjectId(UserInfo.getUserId());
            email.setWhatId(recordId);            
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(OrgWideAddress);
        }
        return email;
    }
    
    public static void sendNotificationApprover(Set<Id> supportReqId,string templateName){
        List<EmailTemplate> emailTemplateForApprove = [SELECT Id , DeveloperName  FROM EmailTemplate WHERE DeveloperName =: templateName  LIMIT 1];
        string templateId = emailTemplateForApprove.size() > 0 ? emailTemplateForApprove[0].id : null;
        string orgWideAddress  = OrgWideAddress.size() > 0 ? OrgWideAddress[0].id : null;
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Core_Exceptions__c> emailException = new List<Core_Exceptions__c>();
        for (Core_Opportunity_Support__c opp_supp : [select id,LastModifiedBy.Email, Core_Approval_Comments__c,Core_Approver_1__r.Email,Core_Approver_2__r.Email,Core_Approver_3__r.Email,Core_Approver_4__r.Email,Core_Approver_5__r.Email,Core_Approver_6__r.Email,Core_Approver_7__r.Email,Core_Approver_8__r.Email,Core_Approver_9__r.Email,Core_Approver_10__r.Email,CreatedBy.Email, Opportunity__r.Owner.Email  from Core_Opportunity_Support__c where id IN : supportReqId ]) {
            Set<String> toAddres = new Set<String>();
            toAddres.add(opp_supp.CreatedBy.Email);
            toAddres.add(opp_supp.Opportunity__r.Owner.Email);
            
            Set<String> ccAddres = new Set<String>();
            ccAddres.add(opp_supp.Core_Approver_1__r.Email);
            ccAddres.add(opp_supp.Core_Approver_2__r.Email);
            ccAddres.add(opp_supp.Core_Approver_3__r.Email);
            ccAddres.add(opp_supp.Core_Approver_4__r.Email);
            ccAddres.add(opp_supp.Core_Approver_5__r.Email);
            ccAddres.add(opp_supp.Core_Approver_6__r.Email);
            ccAddres.add(opp_supp.Core_Approver_7__r.Email);
            ccAddres.add(opp_supp.Core_Approver_8__r.Email);
            ccAddres.add(opp_supp.Core_Approver_9__r.Email);
            ccAddres.add(opp_supp.Core_Approver_10__r.Email);
            
            //ccAddres.remove(opp_supp.LastModifiedBy.Email);
            if(acceptedUser.size() > 0 ){
                
                for(string suppTeamId : acceptedUser.get(opp_supp.id)){
                    if(OppSupTeam.size() > 0){
                        toAddres.add(OppSupTeam.get(suppTeamId).Core_Opportunity_Support_Team_Member__r.Email);
                        emailList.add(createEmailList(templateId,new List<String>(toAddres),new List<String>(ccAddres),suppTeamId,orgWideAddress));
                    }
                }
            }
            else{
                toAddres.add(opp_supp.LastModifiedBy.Email);
                if(ccAddres.contains(opp_supp.LastModifiedBy.Email))
                    ccAddres.remove(opp_supp.LastModifiedBy.Email);
                emailList.add(createEmailList(templateId,new List<String>(toAddres),new List<String>(ccAddres),opp_supp.id,orgWideAddress));
            }
        }
        
        // Send the bulk email notifications
        List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailList);
        
        // Process the send results if needed
        for (Messaging.SendEmailResult result : sendResults) {
            if (result.isSuccess()) {
            } else {
                Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = 'Failure : ########### - '+result.getErrors()[0].getMessage(),Core_Class_Name__c ='Core_EmailNotification',Core_Method_Name__c ='Send Notification to Approver',Core_IPS_Object_Name__c = 'Core_Opportunity_Support__c');
                emailException.add(excep);
                //System.debug('Email sending failed. Error: ' + result.getErrors()[0].getMessage());
            }
        }
        
        if(emailException.size() > 0)
            insert emailException;
    }
    
    public static void userAcceptReq(Map<Id,List<Id>> acceptedUserMap){
        acceptedUser = acceptedUserMap;
        List<Id> OppTeamId = new List<Id>();        
        for (List<Id> idOppSupTeam : acceptedUserMap.values()) {
           OppTeamId.addAll(idOppSupTeam);
        }       
        OppSupTeam =new Map<Id,Core_Opportunity_Support_Team__c>( [Select id , Core_Opportunity_Support_Team_Member__r.Email from Core_Opportunity_Support_Team__c where Id IN: OppTeamId]);
        sendNotificationApprover(acceptedUserMap.keySet(),'Opportunity_Support_Team_Member_Approve');
         
    }   
    
    public static void denyRequestEmail(Set<Id> supportReq,string tempName,id userID,Core_Opportunity_Support_Team__c oppSupTEam){
        String orgInstance = URL.getOrgDomainUrl().toExternalForm();        
        List<EmailTemplate> emailTemplateForApprove = [SELECT Id , DeveloperName  FROM EmailTemplate WHERE DeveloperName =: tempName  LIMIT 1];
        string templateId = emailTemplateForApprove.size() > 0 ? emailTemplateForApprove[0].id : null;
        string orgWideAddress  = OrgWideAddress.size() > 0 ? OrgWideAddress[0].id : null;
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Core_Exceptions__c> emailException = new List<Core_Exceptions__c>();
        List<OpportunityShare> oppToShare = new List<OpportunityShare>();
        id Opportunityid;
         
            for (Core_Opportunity_Support__c opp_supp : [select id,LastModifiedBy.Email,Opportunity__c, Core_Approval_Comments__c,Core_Approver_1__r.Email,Core_Approver_2__r.Email,Core_Approver_3__r.Email,Core_Approver_4__r.Email,Core_Approver_5__r.Email,CreatedBy.Email, Opportunity__r.Owner.Email  from Core_Opportunity_Support__c where id IN : supportReq ]) {
           		Opportunityid = opp_supp.Opportunity__c;
                
                Set<String> toAddres = new Set<String>();
            Set<String> ccAddres = new Set<String>();
            toAddres.add(oppSupTEam.LastModifiedBy.Email);
            toAddres.add(oppSupTEam.Core_Opportunity_Support_Team_Member__r.Email);
            /*toAddres.add(opp_supp.Core_Approver_3__r.Email);
            toAddres.add(opp_supp.Core_Approver_4__r.Email);
            toAddres.add(opp_supp.Core_Approver_5__r.Email);*/
            emailList.add(createEmailList(templateId,new List<String>(toAddres),new List<String>(ccAddres),oppSupTEam.id,orgWideAddress));
        }
        
        List<OpportunityShare> tempTeam = [select id ,UserOrGroupId from OpportunityShare  where OpportunityId  =: Opportunityid and UserOrGroupId =:userID and RowCause != 'Owner' limit 1  ];
        if(tempTeam.size() == 0){
            OpportunityShare oppteam = new OpportunityShare();               
            oppteam.OpportunityId = Opportunityid;
            oppteam.OpportunityAccessLevel = 'Edit';
            oppteam.UserOrGroupId = userID;          

            oppToShare.add(oppteam);
        }
            
        
        if(oppToShare.size() > 0)
            insert oppToShare;
        // Send the bulk email notifications
        List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailList);
        
        if(oppToShare.size() > 0)
            delete oppToShare;
        // Process the send results if needed
        for (Messaging.SendEmailResult result : sendResults) {
            if (result.isSuccess()) {
            } else {
                Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = 'Failure : ########### - '+result.getErrors()[0].getMessage(),Core_Class_Name__c ='Core_EmailNotification',Core_Method_Name__c ='Send Notification to Approver',Core_IPS_Object_Name__c = 'Core_Opportunity_Support__c');
                emailException.add(excep);
                //System.debug('Email sending failed. Error: ' + result.getErrors()[0].getMessage());
            }
        }
        
        if(emailException.size() > 0)
            insert emailException;
        
    }
    
    
    public static void updateApproveOrRejectComents(Set<Id> OppSuppReqId){
        List<Id> toTrackLastedOppId = new List<Id>();
        Map<ID,Core_Opportunity_Support__c> updateComemnts = new Map<Id,Core_Opportunity_Support__c>();
        List<ProcessInstance> pI= [SELECT Id, TargetObjectId, (SELECT Id, Comments FROM Steps where Comments != null ORDER BY CreatedDate DESC LIMIT 1) 
                                   FROM ProcessInstance WHERE TargetObjectId IN :OppSuppReqId AND Status IN ('Approved','Rejected') order by CreatedDate desc]; 
        
        for (ProcessInstance processInstance1 : pI) { 
            List<ProcessInstanceStep> steps = processInstance1.Steps;
            if(!toTrackLastedOppId.contains(processInstance1.TargetObjectId) && (steps.size() > 0)  && ( !string.isEmpty(processInstance1.Steps[0].comments ) ||  !string.isBlank(processInstance1.Steps[0].comments))){ 
                toTrackLastedOppId.add(processInstance1.TargetObjectId);                   
                string comments = processInstance1.Steps[0].comments;
                Core_Opportunity_Support__c tempSup = new Core_Opportunity_Support__c();                
                if(!updateComemnts.containskey(processInstance1.TargetObjectId)){
                    tempSup.id = processInstance1.TargetObjectId;
                    tempSup.Core_Approval_Comments__c = comments;  
                    updateComemnts.put(processInstance1.TargetObjectId,tempSup);
                }
            }
        }
        if(updateComemnts.size() > 0)
            update updateComemnts.values();
    }
    
    
}