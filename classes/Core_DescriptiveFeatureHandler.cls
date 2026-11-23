/**************************************************************************************
Apex Class Name:  Core_DescFeaturesHandler
Version     : 1.0 
Created Date: 13 NOV 2014
Function    : methods to handle DescFeatures Trigger functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             11/13/2014              Original Version
* Srikant Joshi             01/21/2015              Changed the Opportunity fact Query
* Dave Hood                 09/21/2015              Added parameter to method calls to bypass multiselect attribute,
*                                                   and bulkified the code to work on multiple opportunities at once
*************************************************************************************/
public class Core_DescriptiveFeatureHandler {
    
    public static Set<String> setAPIFieldName = new Set<String>{};
    
    /*
    * Method name  : DescFeaturesObjectBeforeHandler
    * Description  : 
    */     
    public static void OpportunityFactsUpdate(List<Core_Opportunity_Features__c> listNewDescFeatures, List<Core_Opportunity_Features__c> listOldDescFeatures,
        Map<Id,Core_Opportunity_Features__c> mapNewsObject, Map<Id,Core_Opportunity_Features__c> mapOldsObject,
        Boolean bypassMultiselect)
    {
        // Initialize the variables
        List<Id> lstOpportunityID = new List<Id>{};
        Set<Id> setOppIdsToUpsert = new Set<Id>{};
        List<Opportunity> lstOppsToUpsert = new List<Opportunity>{};
        List<Core_Opportunity_Facts__c> lstOpportunityFact = new List<Core_Opportunity_Facts__c>{};
        Map<Id,Core_Opportunity_Facts__c> mapOpportunityIDToFact = new Map<Id,Core_Opportunity_Facts__c>{};

        // Set the values of the API names of the Opportunity Facts fields
        setAPIFieldName = Core_Opportunity_Facts__c.getSObjectType().getDescribe().fields.getMap().KeySet();
        
        Boolean isInsert = ((listOldDescFeatures == NULL) && (listNewDescFeatures != NULL));
        Boolean isUpdate = ((listOldDescFeatures != NULL) && (listNewDescFeatures != NULL));
        Boolean isDelete = ((listOldDescFeatures != NULL) && (listNewDescFeatures == NULL));
        
        // If the operation is insert or update
        if(isInsert || isUpdate){
            for(Core_Opportunity_Features__c sobjDescFeatures : listNewDescFeatures){
                lstOpportunityID.add(sobjDescFeatures.Core_Opportunity__c); 
            }
        }
        
        // If the operation is update or delete
        if(isUpdate || isDelete){
            for(Core_Opportunity_Features__c sobjDescFeatures : listOldDescFeatures){
                lstOpportunityID.add(sobjDescFeatures.Core_Opportunity__c);
            }
        }
        
        //Set the QueryString for quering the field values
        String sQueryString = 'SELECT ';
        for(String sFieldName : setAPIFieldName){ 
            // Loop through the field names of the Opp facts objects
            if(!sQueryString.equals('SELECT '))
                sQueryString = sQueryString + ', '+ sFieldName;
            else
                sQueryString = sQueryString + sFieldName;  
        }
        
        // Add the inner Query to extract the opportunity records
        /* Changed the query to make the Opportunity fact query selective */
        sQueryString = sQueryString +', (SELECT Id from Opportunities__r) FROM Core_Opportunity_Facts__c WHERE Core_Opportunity_ID__c in :lstOpportunityID';
        
        System.debug('##### sQueryString: ' + sQueryString);
        System.debug('##### lstOpportunityID: ' + lstOpportunityID);
        
        //Get the SOQL from the Opportunity fact
        for(Core_Opportunity_Facts__c sobjOppFact : Database.Query(sQueryString)){
            if(!sobjOppFact.Opportunities__r.IsEmpty())
                mapOpportunityIDToFact.put(sobjOppFact.Opportunities__r[0].ID,sobjOppFact);    
        }
        
        // Initialize the Opportunity fact instance
        Core_Opportunity_Facts__c oppFact = new Core_Opportunity_Facts__c();
        
        // Create maps of Opportunity IDs to old and new sets of descriptive features depending on what operation we're doing
        Map<Id,List<Core_Opportunity_Features__c>> mapOppIDOldNewDescFeatures = new Map<Id,List<Core_Opportunity_Features__c>>();
        
        if (isDelete) {
            for (Core_Opportunity_Features__c oppFeature : listOldDescFeatures) {
                if (mapOppIDOldNewDescFeatures.containsKey(oppFeature.Core_Opportunity__c))
                    mapOppIDOldNewDescFeatures.get(oppFeature.Core_Opportunity__c).add(oppFeature);
                else {
                    List<Core_Opportunity_Features__c> oppFeatures = new List<Core_Opportunity_Features__c>();
                    oppFeatures.add(oppFeature);
                    mapOppIDOldNewDescFeatures.put(oppFeature.Core_Opportunity__c, oppFeatures);
                }
            }
        }
        else if (isInsert || isUpdate) {
            for (Core_Opportunity_Features__c oppFeature : listNewDescFeatures) {
                if (mapOppIDOldNewDescFeatures.containsKey(oppFeature.Core_Opportunity__c))
                    mapOppIDOldNewDescFeatures.get(oppFeature.Core_Opportunity__c).add(oppFeature);
                else {
                    List<Core_Opportunity_Features__c> oppFeatures = new List<Core_Opportunity_Features__c>();
                    oppFeatures.add(oppFeature);
                    mapOppIDOldNewDescFeatures.put(oppFeature.Core_Opportunity__c, oppFeatures);
                }
            }
        }
        // Pass those maps of old or new features to the proper method based on what operation we're performing,
        // to construct a list of the Opportunity Facts records we'll need to upsert
        for (Id oppId : mapOppIDOldNewDescFeatures.keySet()) {
            if (isDelete) {
                oppFact = OpportunityFactsDeleteOp(oppId, mapOppIDOldNewDescFeatures.get(oppId), mapOpportunityIDToFact.get(oppId), bypassMultiselect);
            }
            else if (isInsert || isUpdate) {
                if (mapOpportunityIDToFact.get(oppId) == null) {
                    mapOpportunityIDToFact.put(oppId, new Core_Opportunity_Facts__c(Core_Opportunity_ID__c = oppId));
                    
                    // Keep track of the opportunity ID, since we'll need to upsert the facts ID on the oppty later
                    setOppIdsToUpsert.add(oppId);
                }
                
                oppFact = OpportunityFactsInsertUpdateOp(oppId, mapOppIDOldNewDescFeatures.get(oppId), mapOpportunityIDToFact.get(oppId), false);
            }
            
            lstOpportunityFact.add(oppFact);
        }
        
        System.debug('##### lstOpportunityFact.size(): ' + lstOpportunityFact.size());
       
       //If the list is not empty then upsert the opportunity fact instance
       if(!lstOpportunityFact.isEmpty()){
           List<Database.upsertResult> uResults = Database.upsert(lstOpportunityFact,false);
           for (Database.upsertResult sr : uResults){
               //If there are failed result               
               if (!sr.isSuccess() || Test.isRunningTest()) {
                   for(Database.Error err : sr.getErrors()) {
                       //Get the instance of the opprtunity fact to throw up error
                       Core_Opportunity_Features__c  objOppFeature = new Core_Opportunity_Features__c(Id=sr.getId());
                       objOppFeature.addError(err.getMessage()); 
                   }
                }
            }
        
            //If the list is not empty then update the opportunity instance
            for (Core_Opportunity_Facts__c opptyFact : lstOpportunityFact) {
                if ((opptyFact.Core_Opportunity_ID__c != NULL) && (setOppIdsToUpsert.contains(opptyFact.Core_Opportunity_ID__c))) {
                    Opportunity opp = new Opportunity(Id=opptyFact.Core_Opportunity_ID__c, Core_Opportunity_Facts_ID__c=opptyFact.ID);
                    lstOppsToUpsert.add(opp); 
                }               
            }
            
            //If the list is not empty then update the opportunity  instance
            if(!lstOppsToUpsert.isEmpty()){
               List<Database.upsertResult> uOppResults = Database.upsert(lstOppsToUpsert, false);
               for (Database.upsertResult sr : uOppResults){
                   //If there are failed result               
                   if (!sr.isSuccess() || Test.isRunningTest()) {
                       for(Database.Error err : sr.getErrors()) {
                           //Get the instance of the opprtunity fact to throw up error
                           Opportunity objOppFeature = new Opportunity(Id=sr.getId());
                           objOppFeature.addError(err.getMessage()); 
                       }
                   }
                }
            }
        }
    }
    
    
    /*
    * Method name  : OpportunityFactsDeleteOp
    * Description  : Take the Opporunity Fact record passed in, delete the Features passed in, then return it back.
    *                bypassMultiselect means to ignore the multi-select attribute when doing so, so it doesn't do a search & replace,
    *                but instead blanks out the field completely. That's only needed when invoked from the Feature trigger, when
    *                we need to blank out any current values and later reset the field completely based on multi-select yes/no.
    */     
    public static Core_Opportunity_Facts__c OpportunityFactsDeleteOp(Id oppId, List<Core_Opportunity_Features__c> oldDescFeatures,
                                                                     Core_Opportunity_Facts__c oldOppFacts, Boolean bypassMultiselect)
    {
        // Strings for holding the Name and Value
        String fieldName;
        String fieldValue;

        // Initialize the Opportunity fact instance
        Core_Opportunity_Facts__c newOppFacts = oldOppFacts.clone(true, true, true, true);
       
        // Run the loop for the old set of Opp features records 
        for (Core_Opportunity_Features__c descFeature : oldDescFeatures) {
           
            // Set the Value for the field and the field values
            fieldName = 'Core_' + Core_Utility.replaceSpecialCharacWithUnderscore(descFeature.Core_Feature_Type__c) + '__c';
            fieldValue = '';
            
            // Check if the field name constructed belongs to the API field names in the opportunity facts
            if (setAPIFieldName.Contains(fieldName.toLowerCase())) {
                
                // Get the value of the field value populated based on the if the Field name is not empty
                if (newOppFacts.get(fieldName) != NULL && String.isEmpty(fieldValue) && descFeature.Core_Multi_Select__c == TRUE &&
                    bypassMultiSelect != TRUE)
                    fieldValue = String.valueOf(newOppFacts.get(fieldName));
                
                // Get the value of the field value based on the condition
                if (descFeature.Core_Feature_Name__c != NULL) {
                    if ((String.isEmpty(fieldValue) || (String.isNOTBlank(fieldValue) && newOppFacts.get(fieldName) != NULL)) && 
                        ((descFeature.Core_Multi_Select__c != TRUE) || (bypassMultiSelect == TRUE)))
                        fieldValue = NULL;
                    else if(fieldValue != NULL && (descFeature.Core_Multi_Select__c == TRUE && bypassMultiSelect != TRUE))
                        fieldValue = fieldValue.remove(descFeature.Core_Feature_Name__c + ';');
                }
                
                //Put the value of the field to the field    
                newOppFacts.put(fieldName, fieldValue); 
            }
        }
        return newOppFacts;
    }
    
     /*
    * Method name  : OpportunityFactsInsertOp
    * Description  : Take the Opporunity Fact record passed in, insert/update Features in it based on Descriptive Features passed in,
    *                then return it. overwriteMultiselect means that instead of concatenating values to the end of the current ones,
    *                start with blank and concatenate from there. That's only needed when invoked from the Feature trigger, when Feature values 
    *                have changed. Need to completely rewrite multiselect values since we don't have the old values for search & replace.
    */      
    public static Core_Opportunity_Facts__c OpportunityFactsInsertUpdateOp(Id oppId, List<Core_Opportunity_Features__c> newDescFeatures,
                                                                           Core_Opportunity_Facts__c oldOppFacts, Boolean overwriteMultiselect)
    {    
        // Strings for holding the Field Name and Value
        String fieldName;
        String fieldValue;
        
        // Initialize the new Opportunity Facts record based on a clone of the old one
        Core_Opportunity_Facts__c newOppFacts = oldOppFacts.clone(true, true, true, true);
        
        System.debug('####### OpportunityFactsInsertOp START newDescFeatures = ' + newDescFeatures);
        System.debug('####### OpportunityFactsInsertOp START newOppFacts = ' + newOppFacts);
        
        // If we're overwriting multi-select values, blank them out before we do our normal concatenation logic below
        if (overwriteMultiselect) {
            for (Core_Opportunity_Features__c descFeature : newDescFeatures) {
                if (descFeature.Core_Multi_Select__c) {
                    fieldName = 'Core_' + Core_Utility.replaceSpecialCharacWithUnderscore(descFeature.Core_Feature_Type__c) + '__c';
                    if (setAPIFieldName.Contains(fieldName.toLowerCase()))
                        newOppFacts.put(fieldName, '');
                }
            }
        }
        
        // Loop through the Descriptive Features records that were passed in
        for (Core_Opportunity_Features__c descFeature : newDescFeatures) {
            System.debug('####### OpportunityFactsInsertOp MIDDLE descFeature = ' + descFeature);
                
            // Field name should be what the field is called in Opportunity Facts, e.g. Core_Screen_Size__c for a
            // Feature Type of Screen Size
            fieldName = 'Core_' + Core_Utility.replaceSpecialCharacWithUnderscore(descFeature.Core_Feature_Type__c) + '__c';
            
            fieldValue = ''; // Blank this out every time through the loop so we can check for that later
            
            // Make sure the field name is valid in Opportunity Facts
            if (setAPIFieldName.Contains(fieldName.toLowerCase())) {
                
                // DH 10/14/15: commented out the next 2 lines and replaced them with ones that made more sense to me, below
                // 
                // Get the value of the field value populated based on the if the Field name is not empty
                //if (newOppFacts.get(fieldName) != NULL && String.isEmpty(fieldValue) && descFeature.Core_Multi_Select__c == TRUE )
                
                // If there's already a value in the field, and it's a multi-select field, initialize our value whatever's already there
                if (newOppFacts.get(fieldName) != NULL && descFeature.Core_Multi_Select__c == TRUE )
                    fieldValue = String.valueOf(newOppFacts.get(fieldName));
                
                // Make sure we're on a valid Descriptive Feature record
                if (descFeature.Core_Feature_Name__c != NULL) {
                    
                    // DH 10/14/15: these next conditions don't make sense to me, so I commented them out and replaced them with code that does
                    //if ((descFeature.Core_Multi_Select__c != TRUE) &&
                    //    (String.isEmpty(fieldValue) || (String.isNotBlank(fieldValue) && newOppFacts.get(fieldName) != NULL)))
                    //    [more conditions, see archive]
                    
                    // If it's a multi-select field, concatenate the current Descriptive Feature onto whatever we already have
                    if (descFeature.Core_Multi_Select__c == TRUE)
                        fieldValue = fieldValue + descFeature.Core_Feature_Name__c + ';';                          
                    // If it's NOT a multi-select field, just set the value to the Descriptive Feature we're on
                    else
                        fieldValue = descFeature.Core_Feature_Name__c;
                }
                
                //Put the value of the field to the field    
                newOppFacts.put(fieldName, fieldValue);
                System.debug('####### OpportunityFactsInsertOp MIDDLE fieldName = ' + fieldName + ' fieldValue = ' + fieldValue);
                System.debug('####### OpportunityFactsInsertOp MIDDLE newOppFacts = ' + newOppFacts);
            }
        }
        System.debug('####### OpportunityFactsInsertOp FINISH newOppFacts = ' + newOppFacts);
        return newOppFacts;
    }
}