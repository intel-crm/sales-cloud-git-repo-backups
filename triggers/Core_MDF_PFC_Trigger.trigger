/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PFC_Trigger 
* Version           : 1.0 
* Created Date      : 11-03-2018
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV       11/03/2018        Trigger on Partner Fund Claim object.
* Accenture - Charu    10/20/2022        Added code to conditionally bypass trigger execution for specific Users
*****************************************************************************************************************************************/
trigger Core_MDF_PFC_Trigger on PartnerFundClaim (before insert,
                                                   before update,
                                                   before delete,
                                                   after insert,
                                                   after update,
                                                   after delete,
                                                   after undelete) 
{  
    If(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_PFC_Trigger') == null || !(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_PFC_Trigger').Core_Active__c 
    && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c !=null && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName())))
    {
        Core_MDF_PFC_TriggerHandler handlerObject = new Core_MDF_PFC_TriggerHandler();
        handlerObject.run();
    }
     
}