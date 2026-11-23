/*********************************************************************************************************************
Class Name    : Sales_UpdateLicRnwlStatus_Queuable
Version       : 1.0
Created Date  : March 2022
Function      : This Queuable class will pick all the records whose Expiration Date is in the past and update the Renewal Status to expired.
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Bharath Kumar           31-March-2022          TWC3144-335: Implementation of TWC3144-335 
* *********************************************************************************************************************/
global class Sales_UpdateLicRnwlStatus_Queuable implements Queueable {
     private static final string ORIGIN = 'Sales_UpdateLicRnwlStatus_Queuable';
     private static final string SEVERITY = 'info';
     private static final string PROJECT = 'Sales';
     List<Sales_License__c> licensesToUpdate = new List<Sales_License__c>();
    global void execute(QueueableContext SC) {
    Sales_UpdateContactDetails.BypassTriggerForContactUpdate = false;    
    List<Sales_License__c> expiredLicenses = [Select id, Name, Sales_License_Maintenance_Exp_Dt__c, Sales_License_Renewed_Date__c,Sales_License_Renewal_Status__c from Sales_License__c where Sales_License_Maintenance_Exp_Dt__c!= null and Sales_License_Maintenance_Exp_Dt__c < TODAY
                                        					and Sales_License_Renewal_Status__c != 'License Expired' and Sales_License_Type__c != 'Renewal' and Sales_License_Status__c !='Cancelled' and  Sales_License_Status__c != 'Renewals Applied'  LIMIT 10000 ];
       if(!expiredLicenses.isEmpty()){
           for(Sales_License__c lic : expiredLicenses){
               lic.Sales_License_Renewal_Status__c = 'License Expired';
               lic.Sales_License_Renewed_Date__c = null;
               licensesToUpdate.add(lic);
           }
        }
       if(!licensesToUpdate.isEmpty()){
           try{
               Sales_UpdateContactDetails.BypassTriggerForContactUpdate = true;
               Database.SaveResult[] results = Database.update(licensesToUpdate, false);               
               for( Database.SaveResult sr : results){
                   if(sr.isSuccess()){
                   }else{
                       for(Database.Error err : sr.getErrors()){
                          Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Line 41', SEVERITY,null, err.getMessage(),null,'', '');  
                       }
                   }
               }
               System.enqueueJob(new Sales_UpdateLicRnwlStatus_Queuable());
           }catch(Exception e){
                Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Line 48', SEVERITY,null, e.getMessage(),null,'', '');
           }
    }
 }
}