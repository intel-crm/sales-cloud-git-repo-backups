/**************************************************************************************
Apex Class Name:  Core_PartnerLead_ReminderEmail
Version     : 1.0 
Created Date: 28 August 2019
Function    : This class is used for partner lead reminder email
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             28/08/2019              Original Version
*************************************************************************************/
global class Core_PartnerLead_ReminderEmail implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String partnerRecType = System.Label.Core_Partner_Lead_Record_Id;
        Date todatDt = date.today();
        if(test.isRunningTest()){
            todatDt = todatDt.addDays(8);
        }
        String leadStatus = 'New';
        string LeadStage ='Rejected';
        string LeadState ='Terminated';
        String query = 'select Id, Core_Public_Group_Id__c, FirstName, LastName, Company, Core_Lead_Source_Pkt__c, OwnerId, Core_PSG_Lead__c, CreatedDate, Core_1st_Reminder__c, Core_2nd_Reminder__c, Core_3rd_Reminder__c, Core_4th_Reminder__c from Lead where recordTypeId =: partnerRecType AND (Core_1st_Reminder__c =: todatDt OR Core_2nd_Reminder__c =: todatDt OR Core_3rd_Reminder__c =: todatDt OR Core_4th_Reminder__c =: todatDt) AND Core_Lead_Status__c =: leadStatus AND (Status !=: LeadStage AND Core_Lead_State__c !=: LeadState)';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leadList){
        Core_PartnerLeadHandler.sendNotificationEmails(leadList,true);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}