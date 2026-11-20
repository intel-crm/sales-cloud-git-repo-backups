/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_InternalUsersPartnerGeoMapping_Trigger 
* Version           : 1.0 
* Created Date      : 07/29/2019
* Modification Log  : 
* Developer            Date(MM/DD/YYYY)  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       07/29/2019        Trigger on Internal User Partner Geo Mapping object.
*****************************************************************************************************************************************/
trigger Core_MDF_InternalUsersPartnerGeoMapping_Trigger on Core_MDF_Int_Users_Partner_Geo_Mapping__c (before insert, after insert,
                                                                                                      before update,after update,
                                                                                                      before delete,after delete){
          if(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_IUPGM_Trigger') == null || !(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_IUPGM_Trigger').Core_Active__c && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName()))){
                     new Core_MDF_IUPGM_TriggerHandler().run();
           }
                                                                                                          
                                                                                                      }