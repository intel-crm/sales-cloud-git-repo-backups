/**************************************************************************************
Apex Class Name: Core_Lead_Weekly_PartnerNotification
Version : 1.0 
Created Date: 06 Dec 2016
Function: Schedulable class that will send weekly email summary notifications to partner users
This summary contains the outstanding leads assigned which are in open state.

Modification Log :
Developer                Date                   Description
----------------------------------------------------------------------------                 
Aran Wongsaprome          12/06/2016              Initial Version
*************************************************************************************/

global without sharing class Core_Lead_Weekly_PartnerNotification implements schedulable{
    // Main method that gets called by the scheduler and is required
    global void execute(SchedulableContext sc){
       // Database.executeBatch(new Core_PartnerLead_ReminderEmail(), Integer.valueOf(Label.Core_Reminder_Email_Batch_Size));
    }
}