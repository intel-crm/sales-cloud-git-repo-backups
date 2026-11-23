trigger Core_PSG_ProductExtendedAttributes on Core_Product_Ext_Attribute__c(before insert, after insert, after update) {
    
    if(trigger.isBefore && Trigger.isInsert){
        Set<Id> productIds=new Set<Id>();
        Set<Id> prodwithExtSet=new Set<Id>();
        for(Core_Product_Ext_Attribute__c ext: Trigger.New){
            if(ext.Core_Product_Id__c!=null){
                productIds.add(ext.Core_Product_Id__c);
            }
        }  
        for(Core_Product_Ext_Attribute__c ext : [select Id,Core_Product_Id__c from Core_Product_Ext_Attribute__c where Core_Product_Id__c in :productIds]){
            prodwithExtSet.add(ext.Core_Product_Id__c);
        }        
        for(Core_Product_Ext_Attribute__c updatedExtendedAttribute: Trigger.new){            
            if(updatedExtendedAttribute.Core_Product_Id__c!=null && prodwithExtSet.contains(updatedExtendedAttribute.Core_Product_Id__c)){                
                updatedExtendedAttribute.addError(System.Label.PSG_Restrict_One_Ext_Attribute_per_Product);
            }
        }
    }
    
    if(trigger.isAfter && Trigger.isInsert){
        //Core_PSG_Change_Sales_Status.updateProductRecord(Trigger.new);
    }
    if(trigger.isAfter && Trigger.isupdate){
        Map<Id,Boolean> prodIdToRegFlagMap=new Map<Id,Boolean>();
        for(Core_Product_Ext_Attribute__c extRec : Trigger.New){
            if(Trigger.oldMap.get(extRec.Id).PSG_Restricted_Product__c !=extRec.PSG_Restricted_Product__c ){
                prodIdToRegFlagMap.put(extRec.Core_Product_Id__c,extRec.PSG_Restricted_Product__c);
            }
        }
        if(!prodIdToRegFlagMap.isEmpty()){
            //PSG_QuoteLineBusinessLogic.fetchQLwithRestrcitedProduct(prodIdToRegFlagMap); 
        }
        
    }
}