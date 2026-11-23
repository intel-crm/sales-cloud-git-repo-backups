/******************************************************************************************************************************************
Class Name  : Core_Product3Opportunity
Version     : 1.0 
Created Date: 16 OCT 2015
Function    : Business functions related to handling Opportunities related to Products, invoked from the Product trigger/handler class
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 10/16/2015              Original version
*****************************************************************************************************************************************/
public class Core_Product3Opportunity {

    //The whole method is commented by Kavyashree HR(Infosys Team) as a part of  US757567
    // This method is called from an After Update trigger, and does the following:
    //   - For all Product records being updated, checks to see which ones had a name change
    //   - For all where the name is changing, gets all Opportunity & Opportunity Product records with those Products
    //   - For all of those Opportunities, reconstructs the concatenated Product field
    //   
    /**public static void oppProductConcatenatedFieldUpdate(List<Product3__c> oldProductList, List<Product3__c> newProductList,
                                                         Map<Id,Product3__c> oldProductMap, Map<Id,Product3__c> newProductMap)
    {
        if (!Core_ProductHandler.alreadyUpdatedOppProductField) {
            
            Core_ProductHandler.alreadyUpdatedOppProductField = true;   // Ensure no re-entry
            
            // Only execute this logic if the trigger is turned on
            if (!Core_ProductHandler.mapFunctionalityNameTriggerExecution.isEmpty()) {
                if (Core_ProductHandler.mapFunctionalityNameTriggerExecution.containsKey('oppProdConcatenatedFieldUpdate') && 
                   Core_ProductHandler.mapFunctionalityNameTriggerExecution.get('oppProdConcatenatedFieldUpdate').Core_Active__c)
                {                    
                    Set<Id> productIdsChanging = new Set<Id>();
                    
                    // We only want to operate on Products whose names are changing, so build a set of those
                    for (Product3__c prod : newProductList)
                        if (prod.Name != oldProductMap.get(prod.Id).Name)
                        productIdsChanging.add(prod.Id);
                    
                    // Do we have any where the name changed?
                    if (productIdsChanging.size() > 0) {**/
                        
                        //**********************************************************************************************************
                        // 12/21/2015 - to fix an urgent production issue, this entire section was wrapped in a try-catch block so
                        // product name changes succeed even if the concatenated field can't be updated. The long term fix needs to
                        // be to make the OpportunityLineItem query more selective, by addition an additional filter
                        // *********************************************************************************************************
                      /**  try {
                        
                            // Grab the Opportunity Products with changed names, and then build a full set of Opportunity Products for
                            // their Opportunities, so we can use that full set to reconstruct the concatenated field
                            List<OpportunityLineItem> oppProdsChanging = [select OpportunityId, Product3__c.Name from OpportunityLineItem where Product3__cId in :productIdsChanging];
                            
                            Set<Id> oppIdsToBeUpdated = new Set<Id>();                
                            for (OpportunityLineItem oppProd : oppProdsChanging) {
                                oppIdsToBeUpdated.add(oppProd.OpportunityId);
                            }
                            
                            List<OpportunityLineItem> fullSetOppProds = [select OpportunityId, Product3__c.Name from OpportunityLineItem where OpportunityId in :oppIdsToBeUpdated];
                            
                            // Build a map of Opportunity IDs to the lists of Opportunity Products for each, so we can use it for later lookups 
                            Map<Id,List<OpportunityLineItem>> oppIdToOppProds = new Map<Id,List<OpportunityLineItem>>();
                            
                            for (OpportunityLineItem oppProd : fullSetOppProds) {
                                
                                Id oppId = oppProd.OpportunityId;
                                if (oppIdToOppProds.containsKey(oppId)) {
                                    List<OpportunityLineItem> oppProds = oppIdToOppProds.get(oppId);
                                    oppProds.add(oppProd);
                                    oppIdToOppProds.put(oppId, oppProds);
                                }
                                else
                                    oppIdToOppProds.put(oppId, new List<OpportunityLineItem>{ oppProd });
                            }
                            
                            // Pull the current concatenated Product values for the Opportunities in question
                            List<Opportunity> oppsToBeUpdated = [select Id, Core_Opportunity_Products__c from Opportunity where Id in :oppIdsToBeUpdated];
                            
                            List<String> prodNames;
                            Set<String> prodNameSet = new Set<String>();
                            String result = '';
                            
                            // Loop through the Opportunities and set the rebuilt concatenated string for each
                            for (Opportunity opp : oppsToBeUpdated) {
                                
                                prodNameSet.clear();
                                
                                // Go through the Products for this Opportunity and add them to a set (to ensure uniqueness)
                                for (OpportunityLineItem oppProd : oppIdToOppProds.get(opp.Id))
                                    prodNameSet.add(oppProd.Product3__c.Name);
                                
                                // Convert to a list for iteration, then construct the concatenated string and set it on the Opportunity
                                prodNames = new List<String>(prodNameSet);
                                
                                result = '';
                                for (String prodName : prodNames)
                                    result += prodName + ', ';
                                
                                if (result.length() > 2)
                                    result = result.left(result.length()-2);      
                                
                                opp.Core_Opportunity_Products__c = result;
                                
                                // Place the updated Opportunity in our map that will be updated in the consolidated DML at end of trigger execution
                                Core_ProductHandler.objectsToUpdate.put(opp.Id, opp);
                            }
                        }
                        catch(Exception e) {
                            System.debug('##### Exception: ' + e.getMessage());
                            System.debug('##### productIdsChanging: ' + productIdsChanging);
                        }
                    }
                }
            }
        }
    }**/
    
    /*
     * Method name  : isProductNameChanged
     * Description  : Method to update Core_IsName_Changed__c checkbox if the name of the product is changed.
     * Return Type  : Void
     * Parameter    : List<Product3__c> , Map<Id,Product3__c>
     */
    public static void isProductNameChanged(List<Product3__c> newProductList, Map<Id,Product3__c> oldProductMap){
        //Updates the check box Core_IsName_Changed__c if the Product name changes which will be picked up by the batch class
        for (Product3__c prod : newProductList){
            if(prod.Name != oldProductMap.get(prod.Id).Name){
                prod.Core_Is_Name_Changed_Chk__c = true;
                prod.Core_Old_Product_Name_Txt__c = oldProductMap.get(prod.Id).Name;
                prod.Core_ProductName_Changed_Time_Dte__c = System.NOW();
            }
        }     
    }
    
    /*
     * Method name  : updateProcessorNumber
     * Description  : Method to update the processorNumber if the processor number is not blank and product type is processor, save the value else blank out.
     * Return Type  : Void
     * Parameter    : List<Product3__c>
     */
    public static void updateProcessorNumber(List<Product3__c> newProductList){
        String substr='';
        for(Product3__c prod : newProductList){
            /*if(prod.Core_Processor_Number_Nm__c !='' && prod.Core_Product_Type__c == 'Processors'){
                prod.Core_Processor_Number_Nm__c = prod.Core_Processor_Number_Nm__c;    
            }
            else{
                prod.Core_Processor_Number_Nm__c = '';   
            }*/
            //Gireesh:US845281:Copy 255 chars from new Processor Number(Core_Processor_Number_Ta_Nm__c)  to old Processor(Core_Processor_Number_Nm__c)
            if(prod.Core_Processor_Number_Ta_Nm__c !=''  && (prod.Core_Product_Type__c == 'Processors' || prod.Core_Product_Type__c == 'Partnered Products')){
                prod.Core_Processor_Number_Ta_Nm__c = prod.Core_Processor_Number_Ta_Nm__c;
                substr=prod.Core_Processor_Number_Ta_Nm__c;
               if(prod.Core_Processor_Number_Ta_Nm__c!=Null && (prod.Core_Processor_Number_Ta_Nm__c).length()>=255){
                    substr= prod.Core_Processor_Number_Ta_Nm__c.substring(0,255);
                }
                    prod.Core_Processor_Number_Nm__c=substr;    
            }
            else{
                prod.Core_Processor_Number_Ta_Nm__c = ''; 
                prod.Core_Processor_Number_Nm__c='';
            }            
        }               
    }
}