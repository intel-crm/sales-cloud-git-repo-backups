/******************************************************************************************************************************************
Class Name  : Core_ProductOpportunity
Version     : 1.0 
Created Date: 16 OCT 2015
Function    : Business functions related to handling Opportunities related to Products, invoked from the Product trigger/handler class
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 10/16/2015              Original version
*****************************************************************************************************************************************/
public class Core_ProductOpportunity {

    // This method is called from an After Update trigger, and does the following:
    //   - For all Product records being updated, checks to see which ones had a name change
    //   - For all where the name is changing, gets all Opportunity & Opportunity Product records with those Products
    //   - For all of those Opportunities, reconstructs the concatenated Product field
    //   
    public static void oppProductConcatenatedFieldUpdate(List<Product2> oldProductList, List<Product2> newProductList,
                                                         Map<Id,Product2> oldProductMap, Map<Id,Product2> newProductMap)
    {
        if (!Core_ProductHandler.alreadyUpdatedOppProductField) {
            
            Core_ProductHandler.alreadyUpdatedOppProductField = true;	// Ensure no re-entry
            
            // Only execute this logic if the trigger is turned on
            if (!Core_ProductHandler.mapFunctionalityNameTriggerExecution.isEmpty()) {
                if (Core_ProductHandler.mapFunctionalityNameTriggerExecution.containsKey('oppProdConcatenatedFieldUpdate') && 
                   Core_ProductHandler.mapFunctionalityNameTriggerExecution.get('oppProdConcatenatedFieldUpdate').Core_Active__c)
                {                    
                    Set<Id> productIdsChanging = new Set<Id>();
                    
                    // We only want to operate on Products whose names are changing, so build a set of those
                    for (Product2 prod : newProductList)
                        if (prod.Name != oldProductMap.get(prod.Id).Name)
                        productIdsChanging.add(prod.Id);
                    
                    // Do we have any where the name changed?
                    if (productIdsChanging.size() > 0) {
                        
                        //**********************************************************************************************************
                        // 12/21/2015 - to fix an urgent production issue, this entire section was wrapped in a try-catch block so
                        // product name changes succeed even if the concatenated field can't be updated. The long term fix needs to
                        // be to make the OpportunityLineItem query more selective, by addition an additional filter
                        // *********************************************************************************************************
                        try {
                        
                            // Grab the Opportunity Products with changed names, and then build a full set of Opportunity Products for
                            // their Opportunities, so we can use that full set to reconstruct the concatenated field
                            List<OpportunityLineItem> oppProdsChanging = [select OpportunityId, Product2.Name from OpportunityLineItem where Product2Id in :productIdsChanging];
                            
                            Set<Id> oppIdsToBeUpdated = new Set<Id>();                
                            for (OpportunityLineItem oppProd : oppProdsChanging) {
                                oppIdsToBeUpdated.add(oppProd.OpportunityId);
                            }
                            
                            List<OpportunityLineItem> fullSetOppProds = [select OpportunityId, Product2.Name from OpportunityLineItem where OpportunityId in :oppIdsToBeUpdated];
                            
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
                                    prodNameSet.add(oppProd.Product2.Name);
                                
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
    }
}