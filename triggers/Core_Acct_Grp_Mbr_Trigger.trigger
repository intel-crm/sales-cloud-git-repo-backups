/**************************************************************************************
Apex Class Name : Core_Acct_Grp_Mbr_Trigger
Version     : 1.0 
Created Date: 24th June, 2019
Description : Trigger  for Core_Account_Group_Member__c
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Usha                 24/06/2019               Original Version
*************************************************************************************/

trigger Core_Acct_Grp_Mbr_Trigger on Core_Account_Group_Member__c (before insert, after insert, before update, after update,
                                                                       before delete, after delete ){ 
                                                                       // Added custom permission check by Dinesh as part of IPA2.0 refresh
if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){                                                    
        new Core_Acct_Grp_Mbr_TriggerHandler().run();
        }
        /*if(Trigger.isAfter) {
                PMP_PartnerAccGroupMemHandler.afterMethod(Trigger.old, Trigger.new);
        }
                                                                           
        if(Trigger.isBefore)
           {
           
             PMP_PartnerAccGroupMemHandler.beforeMethod(Trigger.old, Trigger.new);
             } */        
           
          
}