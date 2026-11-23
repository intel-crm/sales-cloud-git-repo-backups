/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_BankAccountMapping  
* Version           : 1.0 
* Created Date      : 11-22-2018
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sridahr      11/22/2018        Trigger on Partner Node User Mapping object.
*****************************************************************************************************************************************/
trigger Core_MDF_BankAccountMapping on Core_MDF_Account_Bank_Mapping__c (before insert,
                                                                                  before update,
                                                                                  before delete,
                                                                                  after insert,
                                                                                  after update,
                                                                                  after delete,
                                                                                  after undelete) {
    try{                                                                              
    new Core_MDF_BankAccountTriggerHandler().run();}catch(Exception e){
        system.debug('exception'+e.getMessage());
    }
}