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
* Abhishek Telkar           04/27/2026              Remove line 22,39,91,92,95 to 100, Remove line 25, 37, 53 to 58 19 107 for PSG EOL
*****************************************************************************************************************************************/
trigger Core_Product on Product2 (after insert, after update, before update, before insert) {
    //Gireesh:US863168: For Updating Quotable, Shippable and Ordreable flags  
    Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if(trigger.isAfter && Trigger.isInsert){
        //Hari : US1045419 For copying related MSVP,PriceBookEntry,Forward Cost with product inserted.
        // if(TriggerHandler.isActive('PSG_Product_changeProductOnRelatedObject')){
        //     PSG_ProductBusinessLogic.changeProductOnRelatedObjects(Trigger.new,Trigger.oldMap,true);
        // }
        // Sandhya :US1055323 : For moving the extended Attributes from Pre release to Release Product
       // Core_PSG_ActiveProductExtAttrHandler.updateExtAttributesOnActiveProduct(Trigger.new,Trigger.oldMap,true);
       // Core_PSG_ActiveProductExtAttrHandler.updateSignalCodeOnAllProducts(Trigger.new,Trigger.oldMap);
        // Core_ProductHandler.updateSalesVisibleFlagForPSG(Trigger.new,Trigger.oldMap);
        //Core_PSG_Change_Sales_Status.UpdateSalesStatus(Trigger.new, null);
        
        //TWC3123-618 start
        /*if(mapFunctionalityNameTriggerExecution.containsKey('updateProductEOL') && 
           mapFunctionalityNameTriggerExecution.get('updateProductEOL').Core_Active__c ){
              Core_UpdateEOLOppProd.updateEOL(Trigger.New);
        }*/
        //TWC3123-618 end.
       
    }
    //Gireesh:US863168: For Updating Quotable, Shippable and Ordreable flags 
    if(trigger.isAfter && Trigger.isUpdate){
        //Core_PSG_Change_Sales_Status.UpdateSalesStatus(Trigger.new, Trigger.oldMap);
        // Sandhya :US1055323 : For moving the extended Attributes from Pre release to Release Product
        //Core_PSG_ActiveProductExtAttrHandler.updateExtAttributesOnActiveProduct(Trigger.new,Trigger.oldMap,false);
        //Core_PSG_ActiveProductExtAttrHandler.updateSignalCodeOnAllProducts(Trigger.new,Trigger.oldMap);
        // Core_ProductHandler.updateSalesVisibleFlagForPSG(Trigger.new,Trigger.oldMap);
        //Hari : US1045419 For copying related MSVP,PriceBookEntry,Forward Cost with product updated.
        //PSG Team code commenting
        /*if(TriggerHandler.isActive('PSG_Product_changeProductOnRelatedObject')){
            PSG_ProductBusinessLogic.changeProductOnRelatedObjects(Trigger.new,Trigger.oldMap,false);
        }*/
        //TWC3123-618 start
        if(mapFunctionalityNameTriggerExecution.containsKey('updateProductEOL') && 
           mapFunctionalityNameTriggerExecution.get('updateProductEOL').Core_Active__c ){
               Core_UpdateEOLOppProd.updateEOLonUpdate(Trigger.New,Trigger.oldMap);
        }
        //TWC3123-618 end.
    }
    // if(trigger.isAfter && Trigger.isUpdate){
    //     if(mapFunctionalityNameTriggerExecution.containsKey('SendUpdatedProductstoOrders') && mapFunctionalityNameTriggerExecution.get('SendUpdatedProductstoOrders').Core_Active__c){

    //       Core_PSG_Change_Sales_Status.SendUpdatedProductstoOrders(Trigger.new, Trigger.oldMap);    
    //      }
    // }
    
    // Added by Kavyashree HR (Infosys Team) for US780862.Fetching "Custom Setting" containing details to trigger switch on/off
    
    if (Trigger.isAfter)
        Core_ProductHandler.afterMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    //Added by Kavyashree HR (Infosys Team) for US780862   
    
    if(Trigger.isBefore){
        //Gireesh:For Demo
        /*if(Trigger.isInsert){
            for(Product2  updatedProductList: Trigger.new){
                if(updatedProductList.Core_PSG_License__c!=null){
                    updatedProductList.addError('Product to this Extended Attribute already exists!');
                }
            }
        }*/   
        
        if(Trigger.isInsert || Trigger.isUpdate){
            if(mapFunctionalityNameTriggerExecution.containsKey('updateProcessorNumber') && mapFunctionalityNameTriggerExecution.get('updateProcessorNumber').Core_Active__c)
                Core_ProductOpportunity.updateProcessorNumber(Trigger.new);    
            
            //Added for Density Calculation
            Core_ProductHandler.updateProductDensity(Trigger.new);     
            
        //Gireesh:Update SalesVisibleFlag and DesignRegistrationEligibleFlags as false when Status = OB for an active PSG product
        Core_ProductHandler.updateSalesVisibleDesignRegistrationFlags(Trigger.new);
               
        }
        // Sandhya :US1055323 : For moving the Signal Code from Pre release to Release Product
        if(Trigger.isInsert){
            //Commented as part of Signal Code FIX -- Added Alternate Method
            //Core_PSG_ActiveProductExtAttrHandler.updateSignalCodeOnActiveProduct(Trigger.new);
           // Core_PSG_ActiveProductExtAttrHandler.updateSignalCodeOnAllProducts(Trigger.new,Trigger.oldMap,new Map<String,String>()); 
          // Core_PSG_ActiveProductExtAttrHandler.updateProductsWithoutSignalCode(Trigger.new,Trigger.oldMap,true);
        }

        // if(Trigger.isUpdate) { 
        //     if(mapFunctionalityNameTriggerExecution.containsKey('removeSignalCodeUpdatedProducts') && mapFunctionalityNameTriggerExecution.get('removeSignalCodeUpdatedProducts').Core_Active__c){
		// 		Core_PSG_ActiveProductExtAttrHandler.removeSignalCodeUpdatedProducts(Trigger.new, Trigger.oldMap);
        //     }
        //     Core_PSG_ActiveProductExtAttrHandler.updateProductsWithoutSignalCode(Trigger.new,Trigger.oldMap,false);
        // }
    }
    
    //Added by Kavyashree HR (Infosys Team) for US757567   
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            Core_ProductHandler.checkProductStatus(Trigger.New);
            // Core_ProductHandler.updateSalesVisibleFlagForPSG(Trigger.new,Trigger.oldMap);
            //MM Attributes Update Logic - rohitx.podder@intel.com 07-09-2026
            if((mapFunctionalityNameTriggerExecution.containsKey('ExecuteProduct_DeactivationAndLogEntry') && !mapFunctionalityNameTriggerExecution.get('ExecuteProduct_DeactivationAndLogEntry').Core_Active__c)){
                Core_ProductHandler.productMMAttributeValiation(Trigger.New, Trigger.OldMap);
            }
            if(mapFunctionalityNameTriggerExecution.containsKey('isProductNameChanged') && mapFunctionalityNameTriggerExecution.get('isProductNameChanged').Core_Active__c)
                Core_ProductOpportunity.isProductNameChanged(Trigger.new,Trigger.oldMap); 
        }    
        
    }    
}