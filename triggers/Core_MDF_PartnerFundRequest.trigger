/****************************************************************************************************************************************
* Trigger Name  : Core_MDF_PartnerFundRequest 
* Version     : 1.0 
* Created Date: 08-21-2018
* Modification Log :
* Description:                                                
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel-Narayani Perachi        8/21/2018                     Trigger to handle Core MDF PartnerFundRequest functionalities.
* Prashant Dhanagar             12/15/2022                    Added bypass logic to switch ON/OFF 
 
*****************************************************************************************************************************************/
trigger Core_MDF_PartnerFundRequest on PartnerFundRequest (before update, after insert, after update, before insert) {
   if(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_PFR_Trigger') == null || !(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_PFR_Trigger').Core_Active__c && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c !=null && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName()))){
                 new Core_MDF_PartnerRequestTriggerHandler().run();
   }

}