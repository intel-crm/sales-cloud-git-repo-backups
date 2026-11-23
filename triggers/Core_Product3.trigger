trigger Core_Product3 on Product3__c (after insert, after update, before update, before insert) {
    /*
    //Gireesh:US863168: For Updating Quotable, Shippable and Ordreable flags  
    Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if(trigger.isAfter && Trigger.isInsert){
        //Hari : US1045419 For copying related MSVP,PriceBookEntry,Forward Cost with product inserted.
        if(TriggerHandler.isActive('PSG_Product_changeProductOnRelatedObject')){
            Core_Product3Handler.changeProductOnRelatedObjects(Trigger.new,Trigger.oldMap,true); 
        }
        // Sandhya :US1055323 : For moving the extended Attributes from Pre release to Release Product
        Core_Product3Handler.updateExtAttributesOnActiveProduct(Trigger.new,Trigger.oldMap,true); 
       // Core_PSG_ActiveProductExtAttrHandler.updateSignalCodeOnAllProducts(Trigger.new,Trigger.oldMap);
        // Core_Product3Handler.updateSalesVisibleFlagForPSG(Trigger.new,Trigger.oldMap);
        Core_Product3Handler.UpdateSalesStatus(Trigger.new, null); 
       
    }
    //Gireesh:US863168: For Updating Quotable, Shippable and Ordreable flags 
    if(trigger.isAfter && Trigger.isUpdate){
        Core_Product3Handler.UpdateSalesStatus(Trigger.new, Trigger.oldMap); 
        // Sandhya :US1055323 : For moving the extended Attributes from Pre release to Release Product
        Core_Product3Handler.updateExtAttributesOnActiveProduct(Trigger.new,Trigger.oldMap,false);
        //Core_PSG_ActiveProductExtAttrHandler.updateSignalCodeOnAllProducts(Trigger.new,Trigger.oldMap);
        // Core_Product3Handler.updateSalesVisibleFlagForPSG(Trigger.new,Trigger.oldMap);
        //Hari : US1045419 For copying related MSVP,PriceBookEntry,Forward Cost with product updated.
        if(TriggerHandler.isActive('PSG_Product_changeProductOnRelatedObject')){
            Core_Product3Handler.changeProductOnRelatedObjects(Trigger.new,Trigger.oldMap,false); 
        }
        //TWC3123-618 start
        if(mapFunctionalityNameTriggerExecution.containsKey('updateProductEOL') && 
           mapFunctionalityNameTriggerExecution.get('updateProductEOL').Core_Active__c ){
               Core_Product3Handler.updateEOLonUpdate(Trigger.New,Trigger.oldMap); 
        }
        //TWC3123-618 end.
    }
    if(trigger.isAfter && Trigger.isUpdate){
        if(mapFunctionalityNameTriggerExecution.containsKey('SendUpdatedProductstoOrders') && mapFunctionalityNameTriggerExecution.get('SendUpdatedProductstoOrders').Core_Active__c){

          Core_Product3Handler.SendUpdatedProductstoOrders(Trigger.new, Trigger.oldMap);    
         }
    }
    
    // Added by Kavyashree HR (Infosys Team) for US780862.Fetching "Custom Setting" containing details to trigger switch on/off
    
    if (Trigger.isAfter)
        Core_Product3Handler.afterMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    //Added by Kavyashree HR (Infosys Team) for US780862   
    
    if(Trigger.isBefore){        
        
        if(Trigger.isInsert || Trigger.isUpdate){
            if(mapFunctionalityNameTriggerExecution.containsKey('updateProcessorNumber') && mapFunctionalityNameTriggerExecution.get('updateProcessorNumber').Core_Active__c)
                Core_Product3Handler.updateProcessorNumber(Trigger.new);   
            
            //Added for Density Calculation
            Core_Product3Handler.updateProductDensity(Trigger.new);     
            
        //Gireesh:Update SalesVisibleFlag and DesignRegistrationEligibleFlags as false when Status = OB for an active PSG product
        Core_Product3Handler.updateSalesVisibleDesignRegistrationFlags(Trigger.new);
               
        }
        // Sandhya :US1055323 : For moving the Signal Code from Pre release to Release Product
        if(Trigger.isInsert){
            //Commented as part of Signal Code FIX -- Added Alternate Method
            //Core_PSG_ActiveProductExtAttrHandler.updateSignalCodeOnActiveProduct(Trigger.new);
            Core_Product3Handler.updateSignalCodeOnAllProducts(Trigger.new,Trigger.oldMap,new Map<String,String>()); 
            Core_Product3Handler.updateProductsWithoutSignalCode(Trigger.new,Trigger.oldMap,true); 
        }

        if(Trigger.isUpdate) { 
            if(mapFunctionalityNameTriggerExecution.containsKey('removeSignalCodeUpdatedProducts') && mapFunctionalityNameTriggerExecution.get('removeSignalCodeUpdatedProducts').Core_Active__c){
				Core_Product3Handler.removeSignalCodeUpdatedProducts(Trigger.new, Trigger.oldMap); 
            }
            Core_Product3Handler.updateProductsWithoutSignalCode(Trigger.new,Trigger.oldMap,false); 
        }
    }
    
    //Added by Kavyashree HR (Infosys Team) for US757567   
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            Core_Product3Handler.checkProductStatus(Trigger.New);
            Core_Product3Handler.updateSalesVisibleFlagForPSG(Trigger.new,Trigger.oldMap);
            if(mapFunctionalityNameTriggerExecution.containsKey('isProductNameChanged') && mapFunctionalityNameTriggerExecution.get('isProductNameChanged').Core_Active__c)
                Core_Product3Handler.isProductNameChanged(Trigger.new,Trigger.oldMap); 
        }    
        
    }
    */
     
}