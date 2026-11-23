/**************************************************************************************
Apex Class Name:  Core_PartnerLead_SummaryEmail
Version     : 1.0 
Created Date: 28 August 2019
Function    : This class is used for partner lead summary email
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             28/08/2019              Original Version
*************************************************************************************/
global class Core_PartnerLead_SummaryEmail implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String partnerRecType = System.Label.Core_Partner_Lead_Record_Id;
        Date todayDt = Date.today();
        DateTime startOfDT = DateTime.newInstance(todayDt.year(),todayDt.month(),todayDt.day(),0,0,0);
        DateTime endOfDT = DateTime.newInstance(todayDt.year(),todayDt.month(),todayDt.day(),23,59,59);
        String query = 'select Id, Core_Public_Group_Id__c, FirstName, LastName, Company, Core_Lead_Source_Pkt__c, OwnerId, Core_PSG_Lead__c from Lead where createdDate >=: startOfDT AND createdDate <=: endOfDT AND recordTypeId =: partnerRecType';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leadList){
        Core_PartnerLeadHandler.sendNotificationEmails(leadList,false);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}