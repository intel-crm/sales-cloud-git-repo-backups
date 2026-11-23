/****************************************************************************************************************************************
* Class Name  	   : Core_MDF_IUPGM_TriggerHandler 
* Version          : 1.0 
* Created Date     : 07/29/2019
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       07/29/2019         Created for extending Trigger framework to process 
Internal User Partner Geo Mapping object business logic methods.
*****************************************************************************************************************************************/
public class Core_MDF_IUPGM_TriggerHandler extends TriggerHandler {
    
    public override void beforeInsert(){
        if(isActive('Core_MDF_beforeInsertIUPGM')){ 
            Core_MDF_IUPGM_ServiceHandler.checkUserPermission((List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.new,
                                                              Trigger.isInsert,
                                                              Trigger.isUpdate,
                                                              (Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.oldMap); 
        }
    }
    
    public override void beforeUpdate(){
        if(isActive('Core_MDF_beforeUpdateIUPGM')){ 
            Core_MDF_IUPGM_ServiceHandler.checkUserPermission((List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.new,
                                                              Trigger.isInsert,
                                                              Trigger.isUpdate,
                                                              (Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.oldMap); 
        }
    }
    
    public override void afterInsert(){
        if(isActive('Core_MDF_afterInsertIUPGM')){
            Core_MDF_IUPGM_ServiceHandler.checkPGM((List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.new);
        }
    }
    
    public override void afterUpdate(){
        if(isActive('Core_MDF_afterUpdateIUPGM')){
            Core_MDF_IUPGM_ServiceHandler.removeGroupMember((Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.newMap,
                                                        (Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c>) Trigger.oldMap);
        }
    }
}