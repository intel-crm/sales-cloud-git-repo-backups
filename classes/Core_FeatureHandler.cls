/**************************************************************************************
Apex Class Name:  Core_FeatureHandler
Version     : 1.0 
Created Date: 16 OCT 2014
Function    : Utility methods to handle Feature functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/16/2014              Original Version
* Dave Hood                 09/21/2015              After Update code added to handle single->multiselect
* Dave Hood                 10/15/2015              Added code to handle Feature value changes and refactored
*************************************************************************************/
public class Core_FeatureHandler {
    
    // Make sure we only execute functionality once
    public static Boolean alreadyEnsuredConsistentMultiselect = false;    
    public static Boolean alreadyCheckedForValueChange = false;
    public static Boolean alreadyCheckedForMultiToSingleSelect = false;
    
    /*
	* Method name  : ensureConsistentMultiselect
	* Description  : Checks to see if multiselect option is changing for a Feature, or a completely new value is being inserted,
	*                and updates the same checkbox value for all Features with that Feature Type
	* Return Type  : VOID
	* Parameter    : Trigger.New and Trigger.Old
	*/
    public static void ensureConsistentMultiselect(List<Core_Feature__c> oldFeatureList, Map<Id,Core_Feature__c> oldFeatureMap,
                                                   List<Core_Feature__c> newFeatureList, Map<Id,Core_Feature__c> newFeatureMap)
    {
        if(!alreadyEnsuredConsistentMultiselect) {
            alreadyEnsuredConsistentMultiselect = true;
            
            Set<Id> featureIdsChanging = new Set<Id>();
            Set<Core_Feature__c> featuresChanging = new Set<Core_Feature__c>();
            Set<String> featureTypesChanging = new Set<String>();
            
            for (Core_Feature__c newFeature : newFeatureList) {
                if ((oldFeatureList == null) || (oldFeatureMap.get(newFeature.Id).Core_Multi_Select__c != newFeature.Core_Multi_Select__c)) {
                    featureIdsChanging.add(newFeature.Id);
                    featureTypesChanging.add(newFeature.Core_Feature_Type__c);
                    featuresChanging.add(newFeature);
                }
            }
            
            if (featureIdsChanging.size() > 0) {
                
                // Pull all Features for all Feature Types changing, where Feature ID is not a record already being saved to the DB
                List<Core_Feature__c> otherFeatures = [select Id, Core_Feature_Type__c, Core_Multi_Select__c from Core_Feature__c
                                                       where Core_Feature_Type__c in :featureTypesChanging and Id not in :featureIdsChanging];
                
                // Only proceed if we have other Features that need updating
                if ((otherFeatures != null) && (otherFeatures.size() > 0)) {
                    
                    // Go through the Features changing, and create a map of Feature Type to the multiselect value
                    Map<String,Boolean> featureTypesToMultiselect = new Map<String,Boolean>();
                    for (Core_Feature__c feature : featuresChanging)
                        featureTypesToMultiselect.put(feature.Core_Feature_Type__c, feature.Core_Multi_Select__c);
                    
                    // Create a map of Feature Types to the Lists of those "other Features"
                    Map<String,List<Core_Feature__c>> featureTypesToOtherFeatures = new Map<String,List<Core_Feature__c>>();
                    for (Core_Feature__c feature : otherFeatures) {
                        if (featureTypesToOtherFeatures.containsKey(feature.Core_Feature_Type__c))
                            featureTypesToOtherFeatures.get(feature.Core_Feature_Type__c).add(feature);
                        else {
                            List<Core_Feature__c> newOtherFeatures = new List<Core_Feature__c>();
                            newOtherFeatures.add(feature);
                            featureTypesToOtherFeatures.put(feature.Core_Feature_Type__c, newOtherFeatures);
                        }
                    }            
                    
                    // Update those "other Features" with the multiselect value they should have
                    List<Core_Feature__c> featuresToUpdate = new List<Core_Feature__c>();
                    for (String featureType : featureTypesToOtherFeatures.keySet()) {
                        for (Core_Feature__c feature : featureTypesToOtherFeatures.get(featureType)) {
                            feature.Core_Multi_Select__c = featureTypesToMultiselect.get(featureType);
                            featuresToUpdate.add(feature);
                        }
                    }
                    update featuresToUpdate;
                }
            }
        }
    }
    
    /*
    * Method name  : checkForSingleToMultiselect
    * Description  : On update, checks to see if a feature is changing from single to multi-select, and if so,
    *                updates any existing Opportunity Facts records to append a semicolon
    */
    public static void checkForSingleToMultiselect(List<Core_Feature__c> oldFeatures,
                                                   Map<Id,Core_Feature__c> newFeatureMap)
    {   
        // The set of Feature IDs that are changing from single-select to multi-select
        Set<Id> featureIdsChanging = new Set<Id>();
        
        // Build the set of Feature IDs changing from single-select to multi-select
        for (Core_Feature__c feature : oldFeatures) {
            if ((feature.Core_Multi_Select__c == false) && (newFeatureMap.get(feature.Id).Core_Multi_Select__c == true))
                featureIdsChanging.add(feature.Id);
        }
        
        if (featureIdsChanging.size() > 0) {
            
            // Get a unique set of Feature Types changing
            List<Core_Feature__c> featuresChanging = [select Core_Feature_Type__c from Core_Feature__c
                                                      where Id in :featureIdsChanging];
            Set<String> featureTypesChanging = new Set<String>();
            for (Core_Feature__c feature : featuresChanging)
                featureTypesChanging.add(feature.Core_Feature_Type__c);
            
            // Pull the corresponding Descriptive Features records where we may need to append a semicolon in Opportunity Facts
            List<Core_Opportunity_Features__c> descFeaturesToUpdate = [
                select Id, Core_Feature_Name__c, Core_Feature_Set__c, Core_Feature_Type__c, Core_Multi_Select__c, Core_Opportunity__c
                from Core_Opportunity_Features__c where Core_Feature_Type__c in :featureTypesChanging];
            
            Map<Id,Core_Opportunity_Features__c> mapDescFeaturesToUpdate = new Map<Id,Core_Opportunity_Features__c>(descFeaturesToUpdate);
            
            // Pass these lists/maps to the static methods that will correctly update Opportunity Facts.
            // First, remove them all, passing in a parameter to ignore the Multi-Select attribute, so it's equivalent to FALSE,
            // so they get blanked out. Then add them all back, to ensure they get added back properly, with semicolons.
            Core_DescriptiveFeatureHandler.OpportunityFactsUpdate(null, descFeaturesToUpdate, null, mapDescFeaturesToUpdate, true);
            Core_DescriptiveFeatureHandler.OpportunityFactsUpdate(descFeaturesToUpdate, null, mapDescFeaturesToUpdate, null, false);
        }
    }
    
    /*
    * Method name  : checkForMultiToSingleSelect
    * Description  : After update, checks to see if a Feature is changing from multi-select to single-select, and if so,
    *                ensures all Descriptive Features and Opportunity Facts records are properly updated
    */
    public static void checkForMultiToSingleSelect(List<Core_Feature__c> oldFeatures,
                                                   Map<Id,Core_Feature__c> newFeatureMap)
    {
        if (!alreadyCheckedForMultiToSingleSelect) {
            alreadyCheckedForMultiToSingleSelect = true;
            
            // The set of Feature IDs that are changing from multi-select to single-select
            Set<Id> featureIdsChanging = new Set<Id>();
            
            // Build the set of Feature IDs changing from multi-select to single-select
            for (Core_Feature__c feature : oldFeatures) {
                if ((feature.Core_Multi_Select__c == true) && (newFeatureMap.get(feature.Id).Core_Multi_Select__c == false))
                    featureIdsChanging.add(feature.Id);
            }
            
            if (featureIdsChanging.size() > 0) {
                
                // Get a unique set of Feature Types changing
                List<Core_Feature__c> featuresChanging = [select Core_Feature_Type__c from Core_Feature__c
                                                          where Id in :featureIdsChanging];
                Set<String> featureTypesChanging = new Set<String>();
                for (Core_Feature__c feature : featuresChanging)
                    featureTypesChanging.add(feature.Core_Feature_Type__c);
                
                // Take care of Descriptive Features and Opportunity Facts --
                //   - Pull all Opportunities with at least one of those Feature Types set on it
                //   - For each of those:
                //       - Build a map of Opp ID to a list of Descriptive Features records for those Feature Types
                //           - List of Desc Features will be ordered by Feature Type, then Display Order
                //       - Build a map of Opp ID to the Opportunity Facts record for it
                //   - Iterate through the Opportunities again, and for each:
                //       - Go through the Descriptive Features, and for each Feature Type:
                //           - Add the first Feature to a list of what the Descriptive Features *should be*
                //           - Add any additional Features to a list of Descriptive Features *to be deleted*
                //   - Delete all Descriptive Features *to be deleted*
                
                // Pull all Opportunities with at least one of those Feature Types set on it
                List<Core_Opportunity_Features__c> descFeaturesChanging = [select Core_Opportunity__c, Core_Feature_Name__c, Core_Feature_Type__c
                                                                           from Core_Opportunity_Features__c
                                                                           where Core_Feature_Type__c in :featureTypesChanging];
                
                Set<Id> oppIdsChanging = new Set<Id>();
                for (Core_Opportunity_Features__c descFeature : descFeaturesChanging)
                    oppIdsChanging.add(descFeature.Core_Opportunity__c);
                List<Id> oppIdsChangingList = new List<Id>(oppIdsChanging);
                
                // Get a map of Opp ID to a list of Descriptive Features records (remembering Desc Features returned by this method
                // are ordered by Feature Type, then Display Order)
                Map<Id,List<Core_Opportunity_Features__c>> oppIdToDescFeatures =
                    getDescFeaturesForOpportunities(oppIdsChanging, featureTypesChanging);
                
                // Get a map of Opp ID to the Opportunity Facts record for each
                Map<Id,Core_Opportunity_Facts__c> oppIdToOppFacts = getOppFactsForOpportunities(oppIdsChanging);
                
                // Iterate through the Opportunities, and for each, go through the Descriptive Features, and for each Feature Type,
                // add the first Feature to a list of Descriptive Features to keep, any Features beyond that to a list to be deleted
                List<Core_Opportunity_Features__c> descFeaturesToDelete = new List<Core_Opportunity_Features__c>();
                List<Core_Opportunity_Features__c> descFeaturesToKeep = new List<Core_Opportunity_Features__c>();
                
                for (Id oppId : oppIdsChangingList) {
                    
                    if (oppIdToDescFeatures.containsKey(oppId)) {
                        
                        List<Core_Opportunity_Features__c> descFeatures = oppIdToDescFeatures.get(oppId);
                        String lastFeatureType = '';
                        for (Core_Opportunity_Features__c descFeature : descFeatures) {
                            
                            // If Feature Type is different than the previous one, it means it's the first one and we should keep it
                            if (descFeature.Core_Feature_Type__c != lastFeatureType)
                                descFeaturesToKeep.add(descFeature);
                            // Otherwise, delete it
                            else
                                descFeaturesToDelete.add(descFeature);
                            
                            lastFeatureType = descFeature.Core_Feature_Type__c;
                        }
                    }
                }
                
                // Perform the deletion
                delete descFeaturesToDelete;
                
                // Add back any DFs we're keeping
                update descFeaturesToKeep;
            }
        }
    }
    
    /*
    * Method name  : checkForValueChange
    * Description  : After update, checks to see if a feature value is changing, and if so, updates Opportunity Facts records
    */
    public static void checkForValueChange(List<Core_Feature__c> oldFeatureList, Map<Id,Core_Feature__c> oldFeatureMap,
                                           List<Core_Feature__c> newFeatureList, Map<Id,Core_Feature__c> newFeatureMap)
    {
        if (!alreadyCheckedForValueChange) {
            alreadyCheckedForValueChange = true;
            
            // Overall logic:
            // 1. Checks to see if any Feature values are changing and if so, gets any Opportunities using those features
            //    (via Feature Sets -> Descriptive Features)
            // 2. Gets Opportunity Facts records for those Opportunities
            // 3. Gets all Descriptive Features records for those Opportunities
            // 4. Invokes Core_DescriptiveFeatureHandler logic to return the correct the Opportunity Facts records based on new value
            // 5. Upserts those Opportunity Facts records
            
            Set<Id> featureIdsChanging = new Set<Id>();
            
            for (Core_Feature__c oldFeature : oldFeatureList) {
                if (oldFeature.Core_Feature_Value__c != newFeatureMap.get(oldFeature.Id).Core_Feature_Value__c) {                
                    featureIdsChanging.add(oldFeature.Id);                
                }
            }
            
            if (featureIdsChanging.size() > 0) {
                
                Set<Id> featureSetIdsChanging = new Set<Id>();
                for (Core_Feature_Set__c featureSet : [select Id from Core_Feature_Set__c where Core_Feature__c in :featureIdsChanging])
                    featureSetIdsChanging.add(featureSet.Id);
                
                List<Core_Opportunity_Features__c> descFeaturesChanging = [select Id, Core_Opportunity__c from Core_Opportunity_Features__c
                                                                           where Core_Feature_Set__c in :featureSetIdsChanging];
                Set<Id> oppIdsChanging = new Set<Id>();
                for (Core_Opportunity_Features__c descFeature : descFeaturesChanging)
                    oppIdsChanging.add(descFeature.Core_Opportunity__c);
                
                List<Opportunity> oppsChanging = [select Id, Core_Opportunity_Facts_ID__c from Opportunity where Id in :oppIdsChanging];
                
                // Create a map of Oppty ID to ALL of its Descriptive Features
                Map<Id,List<Core_Opportunity_Features__c>> oppIdToDescriptiveFeatures = getDescFeaturesForOpportunities(oppIdsChanging, null);
                
                // Create a map of Oppty ID to its Opportunity Facts record
                Map<Id,Core_Opportunity_Facts__c> oppIdToOppFacts = getOppFactsForOpportunities(oppIdsChanging);
                
                // Iterate through our Opportunities and pull the updated Opportunity Facts records, then perform the upsert
                List<Core_Opportunity_Facts__c> updatedOppFacts = new List<Core_Opportunity_Facts__c>();                
                Core_DescriptiveFeatureHandler.setAPIFieldName = Core_Opportunity_Facts__c.getSObjectType().getDescribe().fields.getMap().keySet();
                
                for (Opportunity opp : oppsChanging) {
                    updatedOppFacts.add(Core_DescriptiveFeatureHandler.OpportunityFactsInsertUpdateOp(
                        opp.Id, oppIdToDescriptiveFeatures.get(opp.Id), oppIdToOppFacts.get(opp.Id), true));
                }                
                upsert updatedOppFacts;
            }
        }
    }
    
    // Take a set of Opportunity IDs and return a map of Opp ID to a list of Descriptive Features records for each,
    // for all Feature Types passed (as a set of Strings). If Feature Types is null, return all.
    public static Map<Id,List<Core_Opportunity_Features__c>> getDescFeaturesForOpportunities(Set<Id> oppIds, Set<String> featureTypes)
    {
        String queryString = 'select Id, Core_Feature_Name__c, Core_Feature_Set__c, Core_Feature_Type__c, ' +
            'Core_Multi_Select__c, Core_Opportunity__c ' +
            'from Core_Opportunity_Features__c where Core_Opportunity__c in :oppIds ';
        
        if (featureTypes != null)
            queryString += ' and Core_Feature_Type__c in :featureTypes';
        
        // Order by Opportunity ID, Feature Type, then Display Order. This will be important for some code above that
        // relies on it to simplify the logic.
        queryString += ' order by Core_Opportunity__c, Core_Feature_Type__c, Core_Feature_Set__r.Core_Display_Order__c';
        
        List<Core_Opportunity_Features__c> fullSetDescFeatures = Database.query(queryString);
        
        Map<Id,List<Core_Opportunity_Features__c>> oppIdToDescriptiveFeatures = new Map<Id,List<Core_Opportunity_Features__c>>();
        
        for (Core_Opportunity_Features__c descFeature : fullSetDescFeatures) {
            if (oppIdToDescriptiveFeatures.containsKey(descFeature.Core_Opportunity__c))
                oppIdToDescriptiveFeatures.get(descFeature.Core_Opportunity__c).add(descFeature);
            else {
                List<Core_Opportunity_Features__c> descFeatures = new List<Core_Opportunity_Features__c>();
                descFeatures.add(descFeature);
                oppIdToDescriptiveFeatures.put(descFeature.Core_Opportunity__c, descFeatures);
            }
        }
        return oppIdToDescriptiveFeatures;
    }
    
    // Take a set of Opportunity IDs and return a map of Opp ID to Opportunity Facts records for them
    public static Map<Id,Core_Opportunity_Facts__c> getOppFactsForOpportunities(Set<Id> oppIds)
    {
        Map<Id,Core_Opportunity_Facts__c> oppIdToOppFacts = new Map<Id,Core_Opportunity_Facts__c>();
        
        // Get all of the fields in Opportunity Facts
        Set<String> oppFactsFields = Core_Opportunity_Facts__c.getSObjectType().getDescribe().fields.getMap().keySet();
        
        // Build our query string to pull all of the fields
        String queryString = 'select ';
        for (String fieldName : oppFactsFields) {
            if(queryString == 'select ')
                queryString = queryString + fieldName;
            else
                queryString = queryString + ', '+ fieldName;
        }            
        queryString = queryString + ', (select Id from Opportunities__r) from Core_Opportunity_Facts__c where Core_Opportunity_ID__c in :oppIds';
        
        // Execute the query and build up our map
        for (Core_Opportunity_Facts__c oppFact : Database.query(queryString)) {
            if(!oppFact.Opportunities__r.isEmpty())
                oppIdToOppFacts.put(oppFact.Opportunities__r[0].Id, oppFact);
        }
        return oppIdToOppFacts;
    }
}