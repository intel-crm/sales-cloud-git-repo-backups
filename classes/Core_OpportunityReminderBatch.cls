/********************************************************************************************************************************************************************
Apex Class Name: Core_OpportunityReminderBatch
Version: 1.0
Created Date: 12/07/2023
Function: Batch class to send emails on delayed Opportunity approvals.

Modification Log :
* Developer Date Description
* ----------------------------------------------------------------------------
* Chowdary Jahnavi 12/07/2023 Original Version developed
*******************************************************************************************************************************************************************/
global without sharing class Core_OpportunityReminderBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public static String fromEmailAddress = System.Label.Core_SetFromEmailAddress; // Organization-Wide Email Address
    
    //String remDays = Core_CRM_Utility.getCRMLabel('core_reminderDays'); // '-12,-15,-18'
    //String[] remDaysVal = remDays.split('\\,'); // ['-12','-15','-18']
    
    Date twelveDaysAgo = System.today().addDays(-12);
    Date fifteenDaysAgo = System.today().addDays(-15);
    Date eighteenDaysAgo = System.today().addDays(-18);
    String source = '';
    
    
    List<Core_Log_Entry__c> sendingemail = new List<Core_Log_Entry__c>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryOppty = 'SELECT Id, Name, OwnerId, Owner.Email, Owner.Manager.Email, Owner.ManagerId, Owner.Manager.delegatedApproverId, Owner.Manager.Manager.Email, Owner.Manager.ManagerId, ' +
'Core_Date_Submitted_for_Approval__c, Core_Technical_Owner__c, Core_Technical_Owner__r.Email, Core_Technical_Owner__r.Manager.Email, ' +
'Core_Technical_Owner__r.Manager.delegatedapproverId, Core_Technical_Owner__r.ManagerId, core_approval_status__c, ' +
'Core_Opportunity_Coverage_Nm__c, Core_Coverage_Type_Nm__c, Core_Opportunity_Type__c ' +
'FROM Opportunity ' +
'WHERE ' +
'((StageName = \'Design\' AND core_approval_status__c = \'Submitted\') OR (StageName = \'Design Win\' AND Core_PW_Approval_Status__c = \'Submitted\')) ' +
'AND (NOT (Core_Coverage_Type_Nm__c = \'Deal Registration\' AND Core_Opportunity_Coverage_Nm__c = \'Partner-Led Opportunity\')) ' +
'ORDER BY createddate';
        
        
        return Database.getQueryLocator(queryOppty);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        
        List<Id> opportunitiesToRecall = null;
        List<Opportunity> opportunitieswith12DaysDelay = null;
        List<Opportunity> opportunitieswith15DaysDelay = null;
        List<Opportunity> opportunitieswith18DaysDelay = null;
        
        if(scope != null){
             opportunitiesToRecall = new List<Id>();       
            for (Opportunity opp : scope) {
                
                opportunitieswith12DaysDelay = new List<Opportunity>();
                opportunitieswith15DaysDelay = new List<Opportunity>();
                opportunitieswith18DaysDelay = new List<Opportunity>();
                
                
                source = '';
                
                if ((opp.Core_Date_Submitted_for_Approval__c == twelveDaysAgo) && (opp.OwnerId != null)) {
                    
                    opportunitieswith12DaysDelay.add(opp);
                    source = '12days'; // Assigning the value '12days' to the varaible source 
                    processEmails(opportunitieswith12DaysDelay);
                    
                } else if (opp.Core_Date_Submitted_for_Approval__c == fifteenDaysAgo && (opp.OwnerId != null)) {
                    
                    opportunitieswith15DaysDelay.add(opp);
                    
                    source = '15days';
                    
                    processEmails(opportunitieswith15DaysDelay);
                    
                } else if (opp.Core_Date_Submitted_for_Approval__c == eighteenDaysAgo && (opp.OwnerId != null)) {
                   
                    
                    opportunitieswith18DaysDelay.add(opp);
                    opportunitiesToRecall.add(opp.Id);
                    
                    source = '18days';
                    
                    processEmails(opportunitieswith18DaysDelay);  
                    
                    
                }
            }
            //Recall the oppty approval  
            List<Approval.ProcessWorkItemRequest> requests = new List<Approval.ProcessWorkItemRequest>();           
            List<ProcessInstanceWorkitem> processInstWorkItm = [SELECT Id,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN :opportunitiesToRecall AND ProcessInstance.Status = 'Pending']; 
            //if (processInstWorkItm.size() > 0) {
                
               // Approval.ProcessWorkItemRequest Preq = null;
                //Create a map to group Work items by their target opportunity
                Map<Id, List<ProcessInstanceWorkitem>> workItemMap = new Map<Id, List<ProcessInstanceWorkitem>>();
            for(ProcessInstanceWorkitem workItem : processInstWorkItm){
                if(!workItemMap.containsKey(workItem.ProcessInstance.TargetObjectId)){
                    workItemMap.put(workItem.ProcessInstance.TargetObjectId, new List<ProcessInstanceWorkitem>());
                }
                workItemMap.get(workItem.ProcessInstance.TargetObjectId).add(workItem);
            }
            //Process each Opportunity Work items
                for(Id opps : opportunitiesToRecall){
                    List<ProcessInstanceWorkitem> workItemsForOpp = workItemMap.get(opps);
                    if(workItemsForOpp != null && workItemsForOpp.size()>0){
                        for(ProcessInstanceWorkitem pval : workItemsForOpp){
                        //Preq = new Approval.ProcessWorkItemRequest();
                        Approval.ProcessWorkItemRequest Preq = new Approval.ProcessWorkItemRequest();
                        Preq.setAction('Removed');
                        Preq.setComments('System automated recall');
                        Preq.setWorkItemId(pval.Id);
                        //Approval.ProcessResult result = Approval.process(Preq);
                        requests.add(Preq);
                        
                    }    
                    }
                    //Preq = new Approval.ProcessWorkItemRequest(); 
                                      
                }             
            //}
            
            //Process the approval requests in bulk
            if(requests.size() > 0){
                List<Approval.ProcessResult> results = Approval.process(requests);
            }
            
        }
        
    }
    
    
    private void processEmails(List<Opportunity> opportunities) {
        
        Set<Id> usersSet = new Set<Id>();
        List<Id> activeUsers = new List<Id>();
        for(Opportunity opp :opportunities){
            usersSet.add(opp.OwnerId);
            usersSet.add(opp.Owner.ManagerId);
            usersSet.add(opp.Owner.Manager.ManagerId);
            usersSet.add(opp.Owner.Manager.delegatedApproverId);
            usersSet.add(opp.Core_Technical_Owner__c);
            usersSet.add(opp.Core_Technical_Owner__r.ManagerId);
            usersSet.add(opp.Core_Technical_Owner__r.Manager.delegatedapproverId);
        }
        for( User usr :[Select id from User where id in:usersSet and isactive = true ]){
            activeUsers.add(usr.id);
        }
        
        if(!opportunities.isEmpty()){
            String emailBody = '';
            String subject = '';
            List<String> toAddressList = null;
            List<String> ccAddressList = null;
            List<Messaging.SingleEmailMessage> emails = null;
            if (source == '12days') {
                emailBody = Core_CRM_Utility.getCRMLabel('emailBody12Days');
                subject = 'ACTION REQUIRED: 6 days left to respond for Opportunity Approval';
                toAddressList = new List<String>();
                ccAddressList = new List<String>();
                emails = new List<Messaging.SingleEmailMessage>();
            } else if (source == '15days') {
                emailBody = Core_CRM_Utility.getCRMLabel('emailBody15Days');
                subject = 'ACTION REQUIRED: 3 days left to respond for Opportunity Approval';
                toAddressList = new List<String>();
                ccAddressList = new List<String>();
                emails = new List<Messaging.SingleEmailMessage>();
            } else if (source == '18days') {
                emailBody = Core_CRM_Utility.getCRMLabel('emailBody18Days');
                subject = 'NOTICE: Opportunity Approval Submission recalled ';
                toAddressList = new List<String>();
                ccAddressList = new List<String>();
                emails = new List<Messaging.SingleEmailMessage>();
            }
            
            
            for (Opportunity opp : opportunities) {
                
                
                if(source == '12days' || source == '15days' ){
                    if ((opp.Owner.ManagerId != null && activeUsers.contains(opp.Owner.ManagerId) )) {
                        toAddressList.add(opp.Owner.Manager.Email);
                        ccAddressList.add(opp.Owner.Email);
                        if (opp.Owner.Manager.delegatedApproverId != null && activeUsers.contains(opp.Owner.Manager.delegatedApproverId) )
                            toAddressList.add(opp.Owner.Manager.delegatedApproverId);
                    }
                    if ( opp.Core_Technical_Owner__r.ManagerId != null && activeUsers.contains(opp.Core_Technical_Owner__r.ManagerId)) {
                        toAddressList.add(opp.Core_Technical_Owner__r.Manager.Email);
                        //  ccAddressList.add(opp.Core_Technical_Owner__r.Email);
                        if (opp.Core_Technical_Owner__r.Manager.delegatedApproverId != null && activeUsers.contains(opp.Core_Technical_Owner__r.Manager.delegatedApproverId))
                            toAddressList.add(opp.Core_Technical_Owner__r.Manager.delegatedApproverId);
                    }
                    if( (source == '15days') && (opp.Owner.Manager.ManagerId != null && activeUsers.contains(opp.Owner.Manager.ManagerId)) ){
                        ccAddressList.add(opp.Owner.Manager.Manager.Email);
                    }
                }
                else if(source == '18days'){
                    
                    if (( opp.Owner.ManagerId != null && activeUsers.contains(opp.Owner.ManagerId))) {
                        ccAddressList.add(opp.Owner.Manager.Email);
                        
                        if(activeUsers.contains(opp.OwnerId))
                        toAddressList.add(opp.Owner.Email);
                        if (opp.Owner.Manager.delegatedApproverId != null && activeUsers.contains(opp.Owner.Manager.delegatedApproverId) )
                            ccAddressList.add(opp.Owner.Manager.delegatedApproverId);
                    }
                    if ( opp.Core_Technical_Owner__r.ManagerId != null && activeUsers.contains(opp.Core_Technical_Owner__r.ManagerId) ) {
                        ccAddressList.add(opp.Core_Technical_Owner__r.Manager.Email);
                    }
                }
             //      ccAddressList.add('chaitanyax.vedak@intel.com');
             //   ccAddressList.add('bharathx.indla@intel.com');
                
                if (!toAddressList.isEmpty() || !ccAddressList.isEmpty() ) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    
                    email.setToAddresses(toAddressList);
                    email.setCcAddresses(ccAddressList);
                    
                    email.setSubject(subject);
                    String opportunityLink = URL.getOrgDomainURL().toExternalForm() + '/' + opp.Id;
                    email.setHtmlBody('Hello,<br><br>' + emailBody + '<br><br>' + 'Link to opportunity: <a href="' + opportunityLink + '">' + opp.Name + '</a>');
                    // email.setHtmlBody('Hello,<br><br>' + emailBody + '<br><br>' + 'Link to opportunity : <a>' + URL.getOrgDomainURL().toExternalForm() + '/' + opp.Id + '</a>');
                    email.setOrgWideEmailAddressId(fromEmailAddress);
                    emails.add(email);
                }
            }
            
            if (!emails.isEmpty()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
                
                if (results[0].success) {
                    sendingemail.add(new Core_Log_Entry__c(Core_Details__c = 'The email was sent successfully.', Core_Message__c = 'Email Sent Successfully', Core_Severity__c = 'Info', Core_Origin__c = 'Email_Sending_Process', Core_When__c = System.now()));
                } else {
                    sendingemail.add(new Core_Log_Entry__c(Core_Details__c = 'The email failed to send: ' + results[0].errors[0].message, Core_Message__c = 'Email Sending Failure', Core_Severity__c = 'Error', Core_Origin__c = 'Email_Sending_Process', Core_When__c = System.now()));
                }
            }
            
            
            if (!sendingemail.isEmpty()) {
                database.insert(sendingemail,false);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
             
    }
}