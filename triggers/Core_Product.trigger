/******************************************************************************************************************************************
Trigger Name: Core_Product
Version     : 1.0 
Created Date: 16 OCT 2015
Function    : Trigger for the object Product2.
NOTE: this is using the new trigger framework agreed upon in the technical governance meetings,
which is why it may look a little different than other triggers.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 10/16/2015              Original version
*****************************************************************************************************************************************/
trigger Core_Product on Product2 (after insert, after update, before update, before insert) {
    Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if(trigger.isAfter && Trigger.isInsert){
        if(TriggerHandler.isActive('PSG_Product_changeProductOnRelatedObject')){
			system.debug('No of soql Before changeProductOnRelatedObjects in insert>>'+Limits.getQueries());
            PSG_ProductBusinessLogic.changeProductOnRelatedObjects(Trigger.new,Trigger.oldMap,true);
			system.debug('No of soql After changeProductOnRelatedObjects in insert>>'+Limits.getQueries());
        }
        system.debug('No of soql before updateExtAttributesOnActiveProduct in Insert>>'+Limits.getQueries());
        Core_PSG_ActiveProductExtAttrHandler.updateExtAttributesOnActiveProduct(Trigger.new,Trigger.oldMap,true);
		system.debug('No of soql After updateExtAttributesOnActiveProduct in insert>>'+Limits.getQueries());
		system.debug('No of soql before UpdateSalesStatus in Insert>>'+Limits.getQueries());
		Core_PSG_Change_Sales_Status.UpdateSalesStatus(Trigger.new, null);
		system.debug('No of soql After UpdateSalesStatus in Insert>>'+Limits.getQueries());
    }
    if(trigger.isAfter && Trigger.isUpdate){
		system.debug('No of soql before UpdateSalesStatus in Update>>'+Limits.getQueries());
        Core_PSG_Change_Sales_Status.UpdateSalesStatus(Trigger.new, Trigger.oldMap);
		system.debug('No of soql After UpdateSalesStatus in Update>>'+Limits.getQueries());
        system.debug('No of soql before updateExtAttributesOnActiveProduct in Update>>'+Limits.getQueries());
        Core_PSG_ActiveProductExtAttrHandler.updateExtAttributesOnActiveProduct(Trigger.new,Trigger.oldMap,false);
		system.debug('No of soql After updateExtAttributesOnActiveProduct in Update>>'+Limits.getQueries());
        if(TriggerHandler.isActive('PSG_Product_changeProductOnRelatedObject')){
			system.debug('No of soql Before changeProductOnRelatedObjects in update>>'+Limits.getQueries());
            PSG_ProductBusinessLogic.changeProductOnRelatedObjects(Trigger.new,Trigger.oldMap,false);
			system.debug('No of soql After changeProductOnRelatedObjects in update>>'+Limits.getQueries());
        }
        if(mapFunctionalityNameTriggerExecution.containsKey('updateProductEOL') && 
           mapFunctionalityNameTriggerExecution.get('updateProductEOL').Core_Active__c ){
               Core_UpdateEOLOppProd.updateEOLonUpdate(Trigger.New,Trigger.oldMap);
        }
    }
    if(trigger.isAfter && Trigger.isUpdate){
        if(mapFunctionalityNameTriggerExecution.containsKey('SendUpdatedProductstoOrders') && mapFunctionalityNameTriggerExecution.get('SendUpdatedProductstoOrders').Core_Active__c){

          Core_PSG_Change_Sales_Status.SendUpdatedProductstoOrders(Trigger.new, Trigger.oldMap);    
         }
    }
    
    if (Trigger.isAfter)
        Core_ProductHandler.afterMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    if(Trigger.isBefore){
		if(Trigger.isInsert || Trigger.isUpdate){
            if(mapFunctionalityNameTriggerExecution.containsKey('updateProcessorNumber') && mapFunctionalityNameTriggerExecution.get('updateProcessorNumber').Core_Active__c)
                Core_ProductOpportunity.updateProcessorNumber(Trigger.new);  
			system.debug('No of soql Before updateProductDensity in insert/update>>'+Limits.getQueries());
            Core_ProductHandler.updateProductDensity(Trigger.new);  
			system.debug('No of soql After updateProductDensity in insert/update>>'+Limits.getQueries());
			system.debug('No of soql Before updateSalesVisibleDesignRegistrationFlags in insert/update>>'+Limits.getQueries());			
            Core_ProductHandler.updateSalesVisibleDesignRegistrationFlags(Trigger.new);
			system.debug('No of soql After updateSalesVisibleDesignRegistrationFlags in insert/update>>'+Limits.getQueries());
               
        }
        if(Trigger.isInsert){
			system.debug('No of soql Before updateSignalCodeOnAllProducts in insert>>'+Limits.getQueries());
			Core_PSG_ActiveProductExtAttrHandler.updateSignalCodeOnAllProducts(Trigger.new,Trigger.oldMap,new Map<String,String>()); 
			system.debug('No of soql After updateSignalCodeOnAllProducts in insert>>'+Limits.getQueries());
			system.debug('No of soql Before updateProductsWithoutSignalCode in insert>>'+Limits.getQueries());
			Core_PSG_ActiveProductExtAttrHandler.updateProductsWithoutSignalCode(Trigger.new,Trigger.oldMap,true);
			system.debug('No of soql After updateProductsWithoutSignalCode in insert>>'+Limits.getQueries());
        }

        if(Trigger.isUpdate) { 
            if(mapFunctionalityNameTriggerExecution.containsKey('removeSignalCodeUpdatedProducts') && mapFunctionalityNameTriggerExecution.get('removeSignalCodeUpdatedProducts').Core_Active__c){
				system.debug('No of soql Before removeSignalCodeUpdatedProducts in update>>'+Limits.getQueries());
				Core_PSG_ActiveProductExtAttrHandler.removeSignalCodeUpdatedProducts(Trigger.new, Trigger.oldMap);
				system.debug('No of soql After removeSignalCodeUpdatedProducts in update>>'+Limits.getQueries());
            }
			system.debug('No of soql Before updateProductsWithoutSignalCode in update>>'+Limits.getQueries());
            Core_PSG_ActiveProductExtAttrHandler.updateProductsWithoutSignalCode(Trigger.new,Trigger.oldMap,false);
			system.debug('No of soql After updateProductsWithoutSignalCode in update>>'+Limits.getQueries());
        }
    }
    
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
			system.debug('No of soql Before checkProductStatus in update>>'+Limits.getQueries());
            Core_ProductHandler.checkProductStatus(Trigger.New);
			system.debug('No of soql After checkProductStatus in update>>'+Limits.getQueries());
			system.debug('No of soql Before updateSalesVisibleFlagForPSG in update>>'+Limits.getQueries());
            Core_ProductHandler.updateSalesVisibleFlagForPSG(Trigger.new,Trigger.oldMap);
			system.debug('No of soql After updateSalesVisibleFlagForPSG in update>>'+Limits.getQueries());
            if(mapFunctionalityNameTriggerExecution.containsKey('isProductNameChanged') && mapFunctionalityNameTriggerExecution.get('isProductNameChanged').Core_Active__c)
                Core_ProductOpportunity.isProductNameChanged(Trigger.new,Trigger.oldMap); 
        }    
        
    }
    
     
}