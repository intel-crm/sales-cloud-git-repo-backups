/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PFC_VAT_Trigger 
* Version           : 1.0 
* Created Date      : 08/Oct/2020
* Modification Log  : 
* Developer       Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sridhar       08/Oct/2020        Trigger on VAT Info Object for validations
*****************************************************************************************************************************************/
trigger Core_MDF_PFC_VAT_Trigger on Core_MDF_Claim_VAT_Info__c (before insert,
                                                   before update,
                                                   before delete,
                                                   after insert,
                                                   after update,
                                                   after delete,
                                                   after undelete) 
{                                                                            
    new Core_MDF_PFC_VAT_TriggerHandler().run();
 
}