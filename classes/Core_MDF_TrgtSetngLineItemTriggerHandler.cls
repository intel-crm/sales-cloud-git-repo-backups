public class Core_MDF_TrgtSetngLineItemTriggerHandler extends TriggerHandler{
    public override void afterInsert(){
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ST_LineItemsShare')){
            Core_MDF_TrgtSetngLineItemServiceHandler.shareRecords((List<Core_MDF_Target_Setting_Line_Item__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting_Line_Item__c>) Trigger.oldMap, Trigger.isInsert);
        }
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ST_LineItemAmountSum')){
            Core_MDF_TrgtSetngLineItemServiceHandler.sumOfAmount((List<Core_MDF_Target_Setting_Line_Item__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting_Line_Item__c>) Trigger.oldMap, Trigger.isInsert);
        }
    }
    public override void afterUpdate(){
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ST_LineItemsShare')){
            Core_MDF_TrgtSetngLineItemServiceHandler.shareRecords((List<Core_MDF_Target_Setting_Line_Item__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting_Line_Item__c>) Trigger.oldMap, Trigger.isInsert);
        }
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ST_LineItemAmountSum')){
            Core_MDF_TrgtSetngLineItemServiceHandler.sumOfAmount((List<Core_MDF_Target_Setting_Line_Item__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting_Line_Item__c>) Trigger.oldMap, Trigger.isInsert);
        }
    }
    
    public override void beforeInsert(){
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ST_LineItemsValRegion')){
            Core_MDF_TrgtSetngLineItemServiceHandler.validateUserRegion((List<Core_MDF_Target_Setting_Line_Item__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting_Line_Item__c>) Trigger.oldMap, Trigger.isInsert);
       } 
       if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_DuplTrgtSetngLineItem')){
         Core_MDF_TrgtSetngLineItemServiceHandler.validateDuplicateTargetSetngLineItemRcrds((List<Core_MDF_Target_Setting_Line_Item__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting_Line_Item__c>) Trigger.oldMap);
       }
       if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ValCountrySelTrget')){
        Core_MDF_TrgtSetngLineItemServiceHandler.validateCountrySelection((List<Core_MDF_Target_Setting_Line_Item__c>) Trigger.new);
      }
    }
    
     public override void beforeUpdate(){
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ST_LineItemsValRegion')){
            Core_MDF_TrgtSetngLineItemServiceHandler.validateUserRegion((List<Core_MDF_Target_Setting_Line_Item__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting_Line_Item__c>) Trigger.oldMap, Trigger.isInsert);
    	}
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_DuplTrgtSetngLineItem')){
           Core_MDF_TrgtSetngLineItemServiceHandler.validateDuplicateTargetSetngLineItemRcrds((List<Core_MDF_Target_Setting_Line_Item__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting_Line_Item__c>) Trigger.oldMap);
        }
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ValCountrySelTrget')){
            Core_MDF_TrgtSetngLineItemServiceHandler.validateCountrySelection((List<Core_MDF_Target_Setting_Line_Item__c>) Trigger.new);
          }   
    }
}