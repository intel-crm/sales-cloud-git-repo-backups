/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PFC_Trigger 
* Version           : 1.0 
* Created Date      : 11-03-2018
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV       11/03/2018        Trigger on Partner Fund Claim object.
*****************************************************************************************************************************************/
trigger Core_MDF_PFC_Trigger on PartnerFundClaim (before insert,
                                                   before update,
                                                   before delete,
                                                   after insert,
                                                   after update,
                                                   after delete,
                                                   after undelete) 
{                                                                            
    Core_MDF_PFC_TriggerHandler handlerObject = new Core_MDF_PFC_TriggerHandler();
    handlerObject.run();
 
}