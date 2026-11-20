/****************************************************************************************************************************************
* Class Name       : Core_MDF_CustomLayout_TriggerHandler 
* Version          : 1.0 
* Created Date     : 12/13/2021
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       12/13/2021         Created for extending Trigger framework to process Custom Layout Configuration 
                                          object business logic methods.    
*****************************************************************************************************************************************/
public class Core_MDF_CustomLayout_TriggerHandler extends TriggerHandler {
    public override void beforeInsert(){
        Core_MDF_CustomLayout_ServiceHandler.validRecord((List<Core_MDF_Custom_Layout_Configurations__c>) Trigger.new,
                                                              Trigger.isInsert,
                                                              Trigger.isUpdate,
                                                              (List<Core_MDF_Custom_Layout_Configurations__c>) Trigger.old); 
    }

    public override void beforeUpdate(){
        Core_MDF_CustomLayout_ServiceHandler.validRecord((List<Core_MDF_Custom_Layout_Configurations__c>) Trigger.new,
                                                              Trigger.isInsert,
                                                              Trigger.isUpdate,
                                                              (List<Core_MDF_Custom_Layout_Configurations__c>) Trigger.old); 
    }
}