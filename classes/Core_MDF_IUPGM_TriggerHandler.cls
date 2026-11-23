/****************************************************************************************************************************************
* Class Name       : Core_MDF_IUPGM_TriggerHandler 
* Version          : 1.0 
* Created Date     : 07/29/2019
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       07/29/2019         Created for extending Trigger framework to process Internal User Partner Geo Mapping 
                                          object business logic methods.    
*****************************************************************************************************************************************/
public class Core_MDF_IUPGM_TriggerHandler extends TriggerHandler {

    private static Boolean shouldBypassDuplicateValidation(){
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_DuplAllAccValidation')){
            return false;
        }
        // Preserve the existing switch-only bypass in test classes.
        if(Test.isRunningTest()){
            return true;
        }
        Core_MDF_Custom_Label_Configration__mdt bypassUsers =
            Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users');
        return bypassUsers != null && String.isNotBlank(bypassUsers.Core_MDF_Value_Txt__c) &&
            bypassUsers.Core_MDF_Value_Txt__c.contains(UserInfo.getUserName());
    }
    
    public override void beforeInsert(){
        if(isActive('Core_MDF_beforeInsertIUPGM')){ 
           if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_AccOnboardValidation')){
            Core_MDF_IUPGM_ServiceHandler.validateAccountOnboardedForProgram((List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.new); 
           } 
            Core_MDF_IUPGM_ServiceHandler.checkUserPermission((List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.new,
                                                              Trigger.isInsert,
                                                              Trigger.isUpdate,
                                                              (Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.oldMap);
            
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_AccountValidation')){
                Core_MDF_IUPGM_ServiceHandler.validateSelectedAccount((List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.new,
                                                                      (Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.oldMap);
            }
            if(!shouldBypassDuplicateValidation()){
                Core_MDF_IUPGM_ServiceHandler.validateDuplicateAccounts((List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.new,
                                                                        (Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.oldMap);
            }
        }
    }
    
    public override void beforeUpdate(){
        if(isActive('Core_MDF_beforeUpdateIUPGM')){ 
           Core_MDF_IUPGM_ServiceHandler.checkUserPermission((List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.new,
                                                              Trigger.isInsert,
                                                              Trigger.isUpdate,
                                                              (Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.oldMap);
            
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_AccountValidation')){
                Core_MDF_IUPGM_ServiceHandler.validateSelectedAccount((List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.new,
                                                                      (Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.oldMap);
            }
            if(!shouldBypassDuplicateValidation()){
                Core_MDF_IUPGM_ServiceHandler.validateDuplicateAccounts((List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.new,
                                                                        (Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.oldMap);
            }
        }
    }
    
    public override void afterInsert(){
        if(isActive('Core_MDF_afterInsertIUPGM')){
            //Core_MDF_IUPGM_ServiceHandler.checkPGM((List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.new);
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_CheckPGMBypass')){
            	Core_MDF_IUPGM_ServiceHandler.checkPGM((Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.newMap);
            }
        }
    }
    
    public override void afterUpdate(){
        if(isActive('Core_MDF_afterUpdateIUPGM')){
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_RemoveGrpMemberBypass')){
                Core_MDF_IUPGM_ServiceHandler.removeGroupMember((Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.newMap,
                                                                (Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.oldMap);
            }
        }
    }
    public override void beforeDelete(){
       if(isActive('Core_MDF_beforeDeleteIUPGM')){
            Core_MDF_IUPGM_ServiceHandler.restrictDeletion((Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.oldMap);
        }
    }
}