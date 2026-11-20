/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_BankTrigger 
* Version           : 1.0 
* Created Date      : 11-11-2018
* Modification Log  : 
* Developer            Date(MM/DD/YYYY)  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       11/11/2018        Trigger on Bank object.
*****************************************************************************************************************************************/
trigger Core_MDF_BankTrigger on Core_MDF_Bank__c (before insert,
                                                  before update,
                                                  before delete,
                                                  after insert,
                                                  after update,
                                                  after delete,
                                                  after undelete) {
    new Core_MDF_BankTriggerHandler().run();
}