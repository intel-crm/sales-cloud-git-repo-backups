/**************************************************************************************
Apex Class Name: Core_Lead_Daily_PartnerNotification
Version : 1.0 
Created Date: 15 AUG 2016
Function: Schedulable class that will send daily email summary notifications to partner users
This summary contains the number of leads they got assigned each day.

Modification Log :
Developer                 Date                    Description
----------------------------------------------------------------------------                 
Venu Karumuru             08/15/2016              Initial Version
*************************************************************************************/

global without sharing class Core_Lead_Daily_PartnerNotification implements schedulable{
    // Main method that gets called by the sechduler and is required
    global void execute(SchedulableContext sc){
        Database.executeBatch(new Core_PartnerLead_SummaryEmail(), 100);
    }
}