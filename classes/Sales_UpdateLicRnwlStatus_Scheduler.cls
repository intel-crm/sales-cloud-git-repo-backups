/*********************************************************************************************************************
Class Name    : Sales_UpdateLicRnwlStatus_Scheduler
Version       : 1.0
Created Date  : March 2022
Function      : This is a Schedulable class which will check if there are any Expired Licenses and initiate a queuable Job to update the status on them.
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Bharath Kumar           31-March-2022          TWC3144-335: Implementation of TWC3144-335 
* *********************************************************************************************************************/
public without sharing class Sales_UpdateLicRnwlStatus_Scheduler implements Schedulable {
   public void execute(SchedulableContext sc) {
     List<Sales_License__c> expiredLicenses = [Select id, Name, Sales_License_Maintenance_Exp_Dt__c, Sales_License_Renewed_Date__c,Sales_License_Renewal_Status__c from Sales_License__c where Sales_License_Maintenance_Exp_Dt__c!= null and Sales_License_Maintenance_Exp_Dt__c < TODAY
                                                            and Sales_License_Renewal_Status__c != 'License Expired'  and Sales_License_Type__c != 'Renewal' and Sales_License_Status__c !='Cancelled' and  Sales_License_Status__c != 'Renewals Applied'  limit 1000 ];
       if(!expiredLicenses.isEmpty()){
          ID jobID = System.enqueueJob(new Sales_UpdateLicRnwlStatus_Queuable());
       }
   }
}