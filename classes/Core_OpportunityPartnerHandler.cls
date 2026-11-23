/******************************************************************************************************
Apex Class Name:  Core_OpportunityPartnerHandler
Version     : 1.0 
Created Date: 20 JUL 2015
Function    : Methods to handle Core_Opportunity_Partner__c trigger functions
Modification Log :
* Developer                 Date                   Description
* ----------------------------------------------------------------------------                 
* Nick Krisa, Dave Hood     07/20/2014             Copied from Descriptive Features code and refactored
******************************************************************************************************/
public without sharing class Core_OpportunityPartnerHandler {//TWC3123-5376: codescan fix: added without sharing
    
    // API names for all of the fields in Opportunity Facts
    public static set<String> fieldNames = new set<String>{};
    
    // Arbitrary separator chars to use internally in this method to create combination strings of
    // Opportunity ID & Partner Type (to use in maps)
    public static final String separator = ';;';
        
    /*
    * Method name  : opportunityPartnerFactsUpdate
    * Description  : This method is invoked when a set of Opportunity Partner records is inserted, updated, or deleted,
                     and performs 4 main steps to "pivot" the Partner Names into fields (based on Partner Type) in the
                     Opportunity Facts table:
                       1. Get all of the Opportunity Facts records that we will need to update
                       2. Figure out which fields need updating and what the updated values should be
                       3. Iterate through the Opportunity Facts records to update the values
                       4. Perform an upsert to the database with those records
    */     
    public static void opportunityPartnerFactsUpdate(List<Core_Opportunity_Partner__c> lstNewOppPartners,
                                                     List<Core_Opportunity_Partner__c> lstOldOppPartners)
    {
        //---------------------------------------------------------------------------------------------------------------
        // This first section is all about getting the Opportunity Facts records that we'll need to update later on
        
        Set<Id> oppIds = new Set<Id>();
        
        // If insert or update
        if (lstNewOppPartners != NULL)
            for(Core_Opportunity_Partner__c oppPartner : lstNewOppPartners)
                oppIds.add(oppPartner.Core_Opportunity__c);
        
        // If delete
        if (lstNewOppPartners == NULL)
            for(Core_Opportunity_Partner__c oppPartner : lstOldOppPartners)
                oppIds.add(oppPartner.Core_Opportunity__c);
        
        // For updates & deletes, we need to keep track of all of the old OpportunityId/Partner Type combinations, so
        // we can make sure to blank them out later if needed (since the current state of the DB may not have them at all)
        Set<String> oldOppIdPartnerTypes = new Set<String>();
        
        // If delete or update
        if (lstOldOppPartners != NULL)
            for(Core_Opportunity_Partner__c oppPartner : lstOldOppPartners)
                oldOppIdPartnerTypes.add(oppPartner.Core_Opportunity__c + separator + oppPartner.Core_Partner_Type__c);
        
        // Need to build a map of Opportunity IDs to Opportunity Facts records, for updating them later
        Map<Id,Core_Opportunity_Facts__c> mapOppIDsToFacts = new Map<Id,Core_Opportunity_Facts__c>();
        
        // Get all of the API names for Opportunity Facts fields
        fieldNames = Core_Opportunity_Facts__c.getSObjectType().getDescribe().fields.getMap().keySet();
        
        // Build a query string to pull all fields in Opportunity Facts
        String queryString = 'select ';
        for (String fieldName : fieldNames) {
            if(queryString.equals('select '))
                queryString += fieldName;  
            else
                queryString += ', ' + fieldName;
        }
        
        // Add an inner query to extract Opportunity records (should only be one, per Opportunity Facts record)
        queryString = queryString + ', (select Id from Opportunities__r) from Core_Opportunity_Facts__c WHERE Core_Opportunity_ID__c in :oppIds';
        
        // Query Opportunity Facts, iterate through the results, and place them in our map of Opportunity IDs to Facts
        for (Core_Opportunity_Facts__c oppFact : Database.query(String.escapeSingleQuotes(queryString))) {  //TWC3123-5376: codescan fix : Avoid Untrusted/Unescaped Variables in DML Query(possible soql injection)-added String.escapeSingleQuotes
            if (!oppFact.Opportunities__r.IsEmpty())
            {mapOppIDsToFacts.put(oppFact.Opportunities__r[0].Id, oppFact);}   
        }
        
        //---------------------------------------------------------------------------------------------------------------
        // Now that we have the Opportunity Facts records we'll need to update, we need to figure out what the updated
        // values should be.  Need to build a map of OpportunityId/Partner Type combinations to represent each row/field,
        // where the value it contains is the set of Partner Names in that field.
        
        Map<String,Set<String>> mapOppIdPartnerTypeToPartnerNames = new Map<String,Set<String>>();
        
        // Place ALL Opportunity Partner records for all OpportunityIds being updated in a list (regardless of whether
        // they're being inserted/updated/deleted at the moment)
        List<Core_Opportunity_Partner__c> allOppPartners = [select Id, Core_Opportunity__c, Core_Partner_Type__c, Core_Partner__r.Name
                                                            from Core_Opportunity_Partner__c where Core_Opportunity__c in :oppIds];
        
        // Iterate through that list and create a current map of OpportunityId/Partner Type combinations and Partner Names
        for (Core_Opportunity_Partner__c oppPartner : allOppPartners) {
            
            // Make the key combination with our arbitrary separator
            String oppIdPartnerType = oppPartner.Core_Opportunity__c + separator + oppPartner.Core_Partner_Type__c;
            
            if (mapOppIdPartnerTypeToPartnerNames.containsKey(oppIdPartnerType)) {
                Set<String> partnerNames = mapOppIdPartnerTypeToPartnerNames.get(oppIdPartnerType);
                partnerNames.add(oppPartner.Core_Partner__r.Name);
                mapOppIdPartnerTypeToPartnerNames.put(oppIdPartnerType, partnerNames);
            }
            else {
                mapOppIdPartnerTypeToPartnerNames.put(oppIdPartnerType, new Set<String>{oppPartner.Core_Partner__r.Name});
            }
        }
        
        // For deletes, we need to do something special -- need to add on the old OpportunityId/Partner Type combinations
        // since they won't be in the map we created above (since they're already gone)
        if (lstOldOppPartners != NULL) {
            for (String oppIdPartnerType : oldOppIdPartnerTypes) {
                if (!mapOppIdPartnerTypeToPartnerNames.containsKey(oppIdPartnerType))
                    mapOppIdPartnerTypeToPartnerNames.put(oppIdPartnerType, new Set<String>());
            }
        }
        
        //---------------------------------------------------------------------------------------------------------------
        // Now that we know what the values should be for every OpportunityId/Partner Type combination, we need to iterate
        // through that keyset, get the Opportunity Facts record corresponding to it, update the proper field, and put
        // it back in our map for later updating.
        
        for (String oppIdPartnerType : mapOppIdPartnerTypeToPartnerNames.keySet()) {
            
            Id oppId = oppIdPartnerType.split(separator)[0];
            String partnerType = oppIdPartnerType.split(separator)[1];
            
            if (String.isNotBlank(Core_Utility.replaceSpecialCharacWithUnderscore(partnerType)) &&
                (Core_Utility.replaceSpecialCharacWithUnderscore(partnerType) != 'null')) {
                
                String fieldName = 'Core_' + Core_Utility.replaceSpecialCharacWithUnderscore(partnerType) + '__c';
                
                Core_Opportunity_Facts__c oppFact = mapOppIdsToFacts.get(oppId);
                if (oppFact == null) oppFact = new Core_Opportunity_Facts__c(Core_Opportunity_ID__c=oppId);
                String fieldValue;
                if (mapOppIdPartnerTypeToPartnerNames.get(oppIdPartnerType) == null)
                    fieldValue = null;
                else
                    fieldValue = convertSetToString(mapOppIdPartnerTypeToPartnerNames.get(oppIdPartnerType));
                try {
                    oppFact.put(fieldName, fieldValue);
                }
                catch (Exception e) {
                }
                mapOppIdsToFacts.put(oppId, oppFact);
            }
        }
        
        //---------------------------------------------------------------------------------------------------------------
        // Update the database with all of the Opportunity Facts we just updated
        
        Set<Core_Opportunity_Facts__c> oppFactsNew = new Set<Core_Opportunity_Facts__c>();
        for (Id oppId : mapOppIdsToFacts.keySet()) {
            oppFactsNew.add(mapOppIdsToFacts.get(oppId));
        }
        
        // If the list is not empty then upsert the Opportunity Facts records
        if (!oppFactsNew.isEmpty()) {
            List<Database.upsertResult> upsertResults = Database.upsert(new List<Core_Opportunity_Facts__c>(oppFactsNew), false);
            for (Database.upsertResult result : upsertResults) {
                // If there are failed results              
                if (!result.isSuccess() || Test.isRunningTest()) {
                    for (Database.Error err : result.getErrors()) {
                        // Get the instance of the opportunity partner to attach the error
                        Core_Opportunity_Partner__c oppPartner = new Core_Opportunity_Partner__c(Id=result.getId());
                        oppPartner.addError(err.getMessage()); 
                    }
                }
            }         
            
            // Build a list of corresponding Opportunity records to upsert (need to use a map first to ensure no duplicates)
            Map<Id,Opportunity> oppIdMap = new Map<Id,Opportunity>();
            for (Core_Opportunity_Facts__c oppFact : oppFactsNew) {
                if (oppFact.Core_Opportunity_ID__c != null) {
                    Opportunity opp = new Opportunity(Id=oppFact.Core_Opportunity_ID__c, Core_Opportunity_Facts_ID__c=oppFact.ID);
                    oppIdMap.put(opp.Id, opp);
                }               
            }
            List<Opportunity> opps = new List<Opportunity>();
            for (Id oppId : oppIdMap.keySet())
                opps.add(oppIdMap.get(oppId));
            
            // If the list is not empty then upsert the Opportunity records
            if(!opps.isEmpty()) {
                List<Database.upsertResult> upsertOppResults = Database.upsert(opps, false);
                for (Database.upsertResult result : upsertOppResults) {
                    // If there are failed results
                    if (!result.isSuccess() || Test.isRunningTest()) {
                        for(Database.Error err : result.getErrors()) {
                            // Get the instance of the opportunity to attach the error
                            Opportunity opp = new Opportunity(Id=result.getId());
                            opp.addError(err.getMessage());
                        }
                    }
                }
            }
        }
    }
        
    private static String convertSetToString(Set<String> inputSet) {
        List<String> inputList = new List<String>(inputSet);
        String outputStr = '';
        for (String str : inputList)
            outputStr += str + ';';
        return outputStr;
    }
    
    
    /*
    * Method name  : opportunityFactsUpdate
    * Description  :  
    *     
    public static void opportunityFactsUpdate(List<Core_Opportunity_Partner__c> lstNewOppPartners, List<Core_Opportunity_Partner__c> lstOldOppPartners,
                                              Map<Id,Core_Opportunity_Partner__c> mapNewOppPartners, Map<Id,Core_Opportunity_Partner__c> mapOldOppPartners)
    {
        // Initialize the variables
        List<ID> lstOppIds = new List<ID>{};
        List<Opportunity> lstOpps = new List<Opportunity>{};
        List<Core_Opportunity_Facts__c> lstOppFacts = new List<Core_Opportunity_Facts__c>{};
        Map<ID,Core_Opportunity_Facts__c> mapOppIDsToFacts = new Map<ID,Core_Opportunity_Facts__c>{};
                        
        // Set the values of the API names of the Opportunity Facts fields
        fieldNames = Core_Opportunity_Facts__c.getSObjectType().getDescribe().fields.getMap().keySet();
        
        // If the operation is insert or update
        if(lstNewOppPartners != NULL)
            for(Core_Opportunity_Partner__c oppPartner : lstNewOppPartners)
                lstOppIds.add(oppPartner.Core_Opportunity__c);
        
        // If the operation is delete
        if(lstNewOppPartners == NULL)
            for(Core_Opportunity_Partner__c oppPartner : lstOldOppPartners)
                lstOppIds.add(oppPartner.Core_Opportunity__c);
        
        // Set the query string for querying all fields in Opportunity Facts
        String queryString = 'SELECT ';
        for (String fieldName : fieldNames) {
            if(queryString.equals('SELECT '))
                queryString = queryString + fieldName;  
            else
                queryString = queryString + ', ' + fieldName;
        }
        
        // Add the inner query to extract the opportunity records (should only be one, per opportunity facts record)
        queryString = queryString + ', (SELECT Id from Opportunities__r) FROM Core_Opportunity_Facts__c WHERE Core_Opportunity_ID__c in :lstOppIds';
        
        // Get the SOQL from the Opportunity fact
        for (Core_Opportunity_Facts__c fact : Database.Query(queryString)) {
            if (!fact.Opportunities__r.IsEmpty())
                mapOppIDsToFacts.put(fact.Opportunities__r[0].ID, fact);    
        }
        
        // Initialize the Opportunity fact instance
        Core_Opportunity_Facts__c oppFact = new Core_Opportunity_Facts__c();
        
        // If the operation is Delete
        if (lstOldOppPartners != NULL && lstNewOppPartners == NULL) {
            
            // Get the opportunity fact instance after deleting the old partners
            oppFact = OpportunityFactsUpdate(lstOldOppPartners, mapOppIDsToFacts, 'delete');
            lstOppFacts.add(oppFact);
        }
        
        // If the operation is insert or update
        if (lstNewOppPartners != NULL) {   
            
            // Get the opportunity fact instance after adding the new partners
            oppFact = OpportunityFactsUpdate(lstNewOppPartners, mapOppIDsToFacts, 'insert');
            lstOppFacts.add(oppFact);
        }
        
        // If the list is not empty then upsert the opportunity fact instance
        if (!lstOppFacts.isEmpty()) {
            List<Database.upsertResult> uResults = Database.upsert(lstOppFacts, false);
            for (Database.upsertResult sr : uResults) {
                // If there are failed results              
                if (!sr.isSuccess() || Test.isRunningTest()) {
                    for (Database.Error err : sr.getErrors()) {
                        //Get the instance of the opportunity partner to attach the error
                        Core_Opportunity_Partner__c oppPartner = new Core_Opportunity_Partner__c(ID=sr.getId());
                        oppPartner.addError(err.getMessage()); 
                    }
                }
            }
            
            // If the list is not empty then update the opportunity  instance
            for (Core_Opportunity_Facts__c fact : lstOppFacts) {
                if (fact.Core_Opportunity_ID__c != NULL) {
                    Opportunity opp = new Opportunity(Id=fact.Core_Opportunity_ID__c, Core_Opportunity_Facts_ID__c=fact.ID);
                    lstOpps.add(opp);
                }               
            }
            
            // If the list is not empty then update the opportunity  instance
            if(!lstOpps.isEmpty()) {
                List<Database.upsertResult> uOppResults = Database.upsert(lstOpps, false);
                for (Database.upsertResult sr : uOppResults) {
                    // If there are failed results
                    if (!sr.isSuccess() || Test.isRunningTest()) {
                        for(Database.Error err : sr.getErrors()) {
                            // Get the instance of the opportunity to attach the error
                            Opportunity opp = new Opportunity(ID=sr.getId());
                            opp.addError(err.getMessage());
                        }
                    }
                }
            }
        }
    }    
    
    *
    * Method name  : OpportunityFactsDeleteOp
    * Description  : Look at Opportunity Partners being deleted and return an appropriate Opportunity Facts record
    *
    public static Core_Opportunity_Facts__c OpportunityFactsDeleteOp(
        List<Core_Opportunity_Partner__c> listOldOppPartners,
        map<ID,Core_Opportunity_Facts__c> mapOpportunityIDToFact) {
            
            // Strings to hold field name & value for Opportunity Facts
            String fieldName;
            String fieldValue;
            
            // Initialize the Opportunity Facts instance
            Core_Opportunity_Facts__c sobjOppFact = new Core_Opportunity_Facts__c();
            
            // Loop through the Opportunity Partner records
            for(Core_Opportunity_Partner__c sobjOppPartner : listOldOppPartners){
                
                // Set the Value for the field and the field values
                fieldName = System.Label.Core_ValueForCore + Core_Utility.replaceSpecialCharacWithUnderscore(sobjOppPartner.Core_Partner_Type__c)+
                    System.Label.Core_ValueForUnderscore;
                // Clear the value of the previous field value
                fieldValue = '';
                
                // Check if the field name constructed belongs to the API field names in the opportunity facts
                if(fieldNames.Contains(fieldName.toLowerCase())) {
                    
                    if(mapOpportunityIDToFact.containsKey(sobjOppPartner.Core_Opportunity__c)) {
                        
                        // Get the Opportunity fact relevant to the opportunity in question
                        if(mapOpportunityIDToFact.containsKey(sobjOppPartner.Core_Opportunity__c)) {
                            
                            sobjOppFact = mapOpportunityIDToFact.get(sobjOppPartner.Core_Opportunity__c);
                            
                            // Get the value of the field value populated based on the if the Field name is not empty
                            if(sobjOppFact.get(fieldName) != NULL && String.isEmpty(fieldValue) )
                                fieldValue = string.valueOf(sobjOppFact.get(fieldName));
                            
                            // Get the value of the field value based on the condition
                            if(sobjOppPartner.Core_Partner__c != NULL){
                                if((String.isEmpty(fieldValue) || (String.isNOTBlank(fieldValue) && sobjOppFact.get(fieldName) != NULL)))
                                    fieldValue = NULL;
                                else if(fieldValue != NULL)
                                    fieldValue = fieldValue.remove(sobjOppPartner.Core_Partner__c + System.Label.Core_ValueforSemicolon);                          
                            }
                            
                            // Put the map with the newest values of the field to the ID  
                            mapOpportunityIDToFact.put(sobjOppPartner.Core_Opportunity__c,sobjOppFact); 
                        }
                    }
                    
                    // Put the value of the field to the field    
                    sobjOppFact.put(fieldName, fieldValue); 
                }
            }
            return sobjOppFact;
        }
    */
    
    /*
    * Method name  : opportunityFactsUpdate
    * Description  : Look at Opportunity Partners being inserted/updated/deleted and return an appropriate Opportunity Facts record
    * NOTE: This currently only works for opportunity partners associated with a single opportunity ID
    *
    public static Core_Opportunity_Facts__c opportunityFactsUpdate(List<Core_Opportunity_Partner__c> lstNewOppPartners,
                                                                   Map<ID,Core_Opportunity_Facts__c> mapOppIDsToFacts,
                                                                   String operation)
    {
        // Opportunity ID we're updating -- NOTE: this needs to be bulkified to work for multiple opp IDs
        Id oppId;
        
        // Strings to hold field name & value
        String fieldName;
        String fieldValue;
        
        // Map of fields we're updating to the ID values we need to look up, for each
        Map<String,Set<Id>> mapFieldsToAcctIds = new Map<String,Set<Id>>();
        
        // Map of fields we're updating to the Account names
        Map<String,String> mapFieldsToAcctNames = new Map<String,String>();
        
        // Initialize the Opportunity fact instance
        Core_Opportunity_Facts__c oppFact = new Core_Opportunity_Facts__c();
        
        //  Run the loop for the new set of Opp partner records
        for (Core_Opportunity_Partner__c oppPartner : lstNewOppPartners) {
            
            if (oppPartner.Core_Partner_Type__c != null) {
                
                oppId = oppPartner.Core_Opportunity__c;  // NOTE: this will need to change when bulkified to work for multiple opp IDs
                
                // Set the Value for the field and the field values
                fieldName = 'Core_' + Core_Utility.replaceSpecialCharacWithUnderscore(oppPartner.Core_Partner_Type__c) + '__c';
                
                // Verify that the field name is a valid opportunity facts field name
                if (fieldNames.contains(fieldName.toLowerCase())) {
                    
                    // Add the opportunity partner account IDs to the sets we need to look up at the end
                    if (oppPartner.Core_Partner__c != null) {
                        if (mapFieldsToAcctIds.containsKey(fieldName)) {
                            if (oppPartner.Core_Partner__c != null) {
                                Set<Id> acctIds = mapFieldsToAcctIds.get(fieldName);
                                acctIds.add(oppPartner.Core_Partner__c);
                                mapFieldsToAcctIds.put(fieldName, acctIds);
                            }
                        }
                        else {
                            mapFieldsToAcctIds.put(fieldName, new Set<Id>{oppPartner.Core_Partner__c});
                        }
                    }
                }
            }
        }
        
        for (String field : mapFieldsToAcctIds.keySet()) {
            Set<Id> acctIds = mapFieldsToAcctIds.get(field);
            List<Account> accts = [select Name from Account where Id in :acctIds];
            String acctNames = '';
            for (Account acct : accts)
                acctNames += acct.Name + ';';
            mapFieldsToAcctNames.put(field, acctNames);
        }
        
        for (String field : mapFieldsToAcctNames.keySet()) {                
            // Get the Opportunity facts relavant to the opportunity in question
            if (mapOppIDsToFacts.containsKey(oppId))
                oppFact = mapOppIDsToFacts.get(oppId);
            else
                oppFact = new Core_Opportunity_Facts__c(Core_Opportunity_ID__c=oppId);
            
            // Get the existing value of the field, if there is one
            fieldValue = '';
            if (oppFact.get(field) != null)
                fieldValue = string.valueOf(oppFact.get(field));
            
            // If this is an insert, we need to add on the new values to the field
            if (operation == 'insert') {
                if (mapFieldsToAcctNames.containsKey(field))
                    fieldValue += mapFieldsToAcctNames.get(field);
            }
            // If it's a delete, we need to remove them
            else if (operation == 'delete') {
                List<String> acctNames = mapFieldsToAcctNames.get(field).split(';');
                for (String acctName : acctNames) {
                    if (acctName != '')
                        fieldValue = fieldValue.remove(acctName + ';');
                }
            }
            
            // Put the new values back in the field for this facts record
            oppFact.put(field, fieldValue);
                
            // Store the updated facts record back in the map for this opportunity
            mapOppIDsToFacts.put(oppId, oppFact);
        }
        return oppFact;
    }
*/
    
    public static void createOppPartnerJSONInsert(List<Core_Opportunity_Partner__c> oppPartnerList){//TWC3123-702 
        List<String> oppId = new List<String>();
        List<String> oppIdForKPI = new List<String>();
        for(Core_Opportunity_Partner__c OppPartner: oppPartnerList){
            oppId.add(OppPartner.Core_Opportunity__c);      
        }
        if(oppId.size()>0){
            for (Opportunity allOppKPI: [SELECT ID FROM Opportunity WHERE Id IN :oppId and (Core_Opportunity_Coverage_Nm__c <> 'Partner-Led Opportunity' or
                                         Core_Coverage_Type_Nm__c <> 'Deal Registration')
                                        ]) {
                                            oppIdForKPI.add(allOppKPI.Id);
                                        }
            if(oppIdForKPI.Size() > 0){
                oppPartnerJSON(oppIdForKPI);
            }            
        }
    }
/*
* Method name  : createOppPartnerJSONUpdate
* Description  : This Method used to sent a message to azure for any update on the Partner type. Called from After Update
* Return Type  : void
* Parameter    : (List<Core_Opportunity_Partner__c> opportunityPartnerList, Map<Id, Core_Opportunity_Partner__c> oldOppPartnerMap).
*/     
    public static void createOppPartnerJSONUpdate(List<Core_Opportunity_Partner__c> opportunityPartnerList, Map<Id, Core_Opportunity_Partner__c> oldOppPartnerMap){ //TWC3123-702
        List<String> oppId = new List<String>();
        List<String> oppIdForKPI = new List<String>();
        for(Core_Opportunity_Partner__c OppPartner: opportunityPartnerList){
            if(OppPartner.Core_Partner_Type__c <> oldOppPartnerMap.get(OppPartner.Id).Core_Partner_Type__c){
                oppId.add(OppPartner.Core_Opportunity__c);
            }
        }
        if(oppId.size()>0){
            for (Opportunity allOppKPI: [SELECT ID FROM Opportunity WHERE Id IN :oppId and (Core_Opportunity_Coverage_Nm__c <> 'Partner-Led Opportunity' or
                                         Core_Coverage_Type_Nm__c <> 'Deal Registration')
                                        ]) {
                                            oppIdForKPI.add(allOppKPI.Id);
                                        }
            if(oppIdForKPI.Size() > 0){
                oppPartnerJSON(oppIdForKPI);
            }            
        }
    }
    
    public static void oppPartnerJSON(List<String> Oppid){
      
        Core_OpportunityJSON updateJob = new Core_OpportunityJSON(Oppid);
        ID jobID=System.enqueueJob(updateJob);
        
      
    }
    public static void createOppPartnerJSONAfterDelete(List<Core_Opportunity_Partner__c> oppPartnerList){//TWC3123-702 
    Core_OpportunityPartnerHandler.createOppPartnerJSONInsert(oppPartnerList);
    }
    
    //TWC3123-5659 - Devashish
    public static void checkPCCOpptyLock(List<Core_Opportunity_Partner__c> newOpptyPartnerList){
        Set<Id> oppIds = new Set<Id>();                     
        for(Core_Opportunity_Partner__c oppPrtnr:newOpptyPartnerList)
        {
                oppIds.add(oppPrtnr.Core_Opportunity__c);
        }
        if(oppIds.size() > 0){
            List<Opportunity> OpptyList = [SELECT Id, name, SBQQ__PrimaryQuote__c, Core_Coverage_Type_Nm__c, Core_Opportunity_Coverage_Nm__c FROM Opportunity WHERE Id IN:oppIds AND Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity' AND Core_Coverage_Type_Nm__c ='Deal Registration']; 
            Boolean lock = Core_CRM_Utility.lockOpportunity(OpptyList);
            if(lock)
            {
                for(Core_Opportunity_Partner__c oppPrtnr:newOpptyPartnerList)
                {
                    oppPrtnr.adderror(System.Label.Core_LockPCCOppty);
                }
            }
        }
    }
}