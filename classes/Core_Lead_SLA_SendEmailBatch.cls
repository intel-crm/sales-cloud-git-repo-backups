/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Lead_SLA_SendEmailBatch
Version     : 1.0 
Created Date: 11 Nov 2018
Function    : Batch class to send notification email while lead is on SAL
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            11/11/2018              Original Version
--------------------------------------------------------------------------------------------*/

global class Core_Lead_SLA_SendEmailBatch implements Database.Batchable<sobject>{
    
    global Database.Querylocator start (Database.BatchableContext BC) {
        Date finalDate = date.today();
        String stage = 'Sales Accepted Lead';
        String status = 'Accepted';
        String leadRecType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
        String query = 'Select id, Status, Core_SendEmail__c, Core_SendEmail4__c, Core_SAL_Four_Weeks_Datetime__c, Core_SAL_Four_Weeks_Weekend_Calculation__c, Core_SAL_Email_Trigger_Date__c, Core_SAL_Weekend_Email_Trigger_Date__c From Lead WHERE Status =: stage AND Core_Lead_Status__c =: status AND Core_DateToSendMail__c =: finalDate AND recordTypeId !=: leadRecType AND (Core_SendEmail__c = false OR Core_SendEmail4__c = false)';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<Lead> leadList) {
        
        List<Lead> filteredLeadList = new List<Lead>();
        Datetime dt = Datetime.now();
        date myDate = date.newInstance(dT.year(), dT.month(), dT.day());
        Integer batchTime = dt.hour();
        Date bDay;
        Date bDayW;
        Date wDay;
        Date wDayW;
        if(batchTime < 23){
            for(Lead leads : leadList){
                if(leads.Core_SAL_Email_Trigger_Date__c <> null){
                    bDay = date.newInstance(leads.Core_SAL_Email_Trigger_Date__c.year(), leads.Core_SAL_Email_Trigger_Date__c.month(), leads.Core_SAL_Email_Trigger_Date__c.day());
                }
                if(leads.Core_SAL_Weekend_Email_Trigger_Date__c <> null){
                    bDayW = date.newInstance(leads.Core_SAL_Weekend_Email_Trigger_Date__c.year(), leads.Core_SAL_Weekend_Email_Trigger_Date__c.month(), leads.Core_SAL_Weekend_Email_Trigger_Date__c.day());
                }
                if(leads.Core_SAL_Four_Weeks_Datetime__c <> null){
                    wDay = date.newInstance(leads.Core_SAL_Four_Weeks_Datetime__c.year(), leads.Core_SAL_Four_Weeks_Datetime__c.month(), leads.Core_SAL_Four_Weeks_Datetime__c.day());
                }
                if(leads.Core_SAL_Four_Weeks_Weekend_Calculation__c <> null){
                    wDayW = date.newInstance(leads.Core_SAL_Four_Weeks_Weekend_Calculation__c.year(), leads.Core_SAL_Four_Weeks_Weekend_Calculation__c.month(), leads.Core_SAL_Four_Weeks_Weekend_Calculation__c.day());
                }
                if(bDay == myDate && leads.Core_SAL_Email_Trigger_Date__c <= datetime.now()){
                    filteredLeadList.add(leads);
                }else if(bDayW == myDate && leads.Core_SAL_Weekend_Email_Trigger_Date__c <= datetime.now()){
                    filteredLeadList.add(leads);
                }else if(wDay == myDate && leads.Core_SAL_Four_Weeks_Datetime__c <= datetime.now()){
                    filteredLeadList.add(leads);
                }else if(wDayW == myDate && leads.Core_SAL_Four_Weeks_Weekend_Calculation__c <= datetime.now()){
                    filteredLeadList.add(leads);
                }
            }
        }else{
            filteredLeadList = leadList;
        }
        List<Lead> finalList = new List<Lead>();
        for(Lead leads : filteredLeadList){
            if(leads.Core_SAL_Email_Trigger_Date__c <> null){
                bDay = date.newInstance(leads.Core_SAL_Email_Trigger_Date__c.year(), leads.Core_SAL_Email_Trigger_Date__c.month(), leads.Core_SAL_Email_Trigger_Date__c.day());
            }
            if(leads.Core_SAL_Weekend_Email_Trigger_Date__c <> null){
                bDayW = date.newInstance(leads.Core_SAL_Weekend_Email_Trigger_Date__c.year(), leads.Core_SAL_Weekend_Email_Trigger_Date__c.month(), leads.Core_SAL_Weekend_Email_Trigger_Date__c.day());
            }
            if(leads.Core_SAL_Four_Weeks_Datetime__c <> null){
                wDay = date.newInstance(leads.Core_SAL_Four_Weeks_Datetime__c.year(), leads.Core_SAL_Four_Weeks_Datetime__c.month(), leads.Core_SAL_Four_Weeks_Datetime__c.day());
            }
            if(leads.Core_SAL_Four_Weeks_Weekend_Calculation__c <> null){
                wDayW = date.newInstance(leads.Core_SAL_Four_Weeks_Weekend_Calculation__c.year(), leads.Core_SAL_Four_Weeks_Weekend_Calculation__c.month(), leads.Core_SAL_Four_Weeks_Weekend_Calculation__c.day());
            }
            if(leads.Core_SendEmail__c == false && (bDay == myDate || bDayW == myDate)){
                leads.Core_SendEmail__c = true;
                finalList.add(leads);
            }else if(leads.Core_SendEmail4__c == false && (wDay == myDate || wDayW == myDate)){
                leads.Core_SendEmail4__c = true;
                finalList.add(leads);
            }
        }
        update finalList;
    }
    
    global void finish (Database.BatchableContext BC) {
        
    }
}