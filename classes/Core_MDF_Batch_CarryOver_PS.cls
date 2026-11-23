global without sharing class Core_MDF_Batch_CarryOver_PS implements Database.Batchable<SObject> {
    Integer SOQL_DAYS = 30;
    Set<String> nodeAccountSupportedProgramsSet = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query Partnership Score records directly instead of Cases
        String query = 'SELECT Id, Core_MDF_Program_nm__c, Core_MDF_Virtual_Corp_Account_Id__c, ' +
                      'Core_MDF_Channel_Program_Id__c, Core_MDF_Quarter_Year_Nm__c, ' +
                      'Core_MDF_Channel_Program_Id__r.Name, LastModifiedDate ' +
                      'FROM Core_MDF_Partnership_Score__c ' +
                      'WHERE LastModifiedDate = LAST_N_DAYS:' + SOQL_DAYS + ' ' +
                      'AND Core_MDF_Balance_Amount_Amt__c != 0';
        
        system.debug('Partnership Score Records: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Core_MDF_Partnership_Score__c> scope) {
        try {
            Set<String> currentQuarters = new Set<String>();
            Set<String> previousQuarters = new Set<String>();
            Map<String, Core_MDF_Partnership_Score__c> currentQuarterPSMap = new Map<String, Core_MDF_Partnership_Score__c>();
            Set<Id> channelProgramIds = new Set<Id>();
            Set<Id> virtualCorpAccountIds = new Set<Id>();
            
            system.debug('Partnership Score Records: ' + scope);
            
            // Process current quarter Partnership Score records
            for (Core_MDF_Partnership_Score__c ps : scope) {
                String currentQuarter = ps.Core_MDF_Quarter_Year_Nm__c;
                String previousQuarter = getPreviousQuarter(currentQuarter);
                
                if (String.isNotBlank(currentQuarter) && String.isNotBlank(previousQuarter)) {
                    currentQuarters.add(currentQuarter);
                    previousQuarters.add(previousQuarter);
                    
                    // Create unique key for current quarter PS
                    String psKey = String.valueOf(ps.Core_MDF_Program_nm__c) + 
                                  String.valueOf(ps.Core_MDF_Virtual_Corp_Account_Id__c) + 
                                  String.valueOf(currentQuarter);
                    currentQuarterPSMap.put(psKey, ps);
                    
                    channelProgramIds.add(ps.Core_MDF_Channel_Program_Id__c);
                    virtualCorpAccountIds.add(ps.Core_MDF_Virtual_Corp_Account_Id__c);
                }
            }
            
            if (currentQuarterPSMap.isEmpty()) {
                return;
            }

            system.debug('Current Quarter PS Map: ' + currentQuarterPSMap);
            
            // Query previous quarter Partnership Score records
            Map<String, Core_MDF_Partnership_Score__c> previousQuarterPSMap = new Map<String, Core_MDF_Partnership_Score__c>();
            for (Core_MDF_Partnership_Score__c prevPS : [SELECT Id, Core_MDF_Program_nm__c, Core_MDF_Virtual_Corp_Account_Id__c, 
                                                        Core_MDF_Channel_Program_Id__c, Core_MDF_Quarter_Year_Nm__c 
                                                        FROM Core_MDF_Partnership_Score__c 
                                                        WHERE Core_MDF_Quarter_Year_Nm__c IN :previousQuarters 
                                                        AND Core_MDF_Channel_Program_Id__c IN :channelProgramIds 
                                                        AND Core_MDF_Virtual_Corp_Account_Id__c IN :virtualCorpAccountIds]) {
                
                String prevPSKey = String.valueOf(prevPS.Core_MDF_Program_nm__c) + 
                                  String.valueOf(prevPS.Core_MDF_Virtual_Corp_Account_Id__c) + 
                                  String.valueOf(prevPS.Core_MDF_Quarter_Year_Nm__c);
                previousQuarterPSMap.put(prevPSKey, prevPS);
            }
            
            system.debug('Previous Quarter PS Map: ' + previousQuarterPSMap);
            
            // Build external IDs for PSD records
            Set<String> allExternalIds = new Set<String>();
            Map<String, String> currentToPreviousExtIdMap = new Map<String, String>();
            
            for (Core_MDF_Partnership_Score__c currentPS : scope) {
                String currentQuarter = currentPS.Core_MDF_Quarter_Year_Nm__c;
                String previousQuarter = getPreviousQuarter(currentQuarter);
                String programName = currentPS.Core_MDF_Program_nm__c;
                
                // Find corresponding previous quarter PS
                String prevPSKey = String.valueOf(programName) + 
                                  String.valueOf(currentPS.Core_MDF_Virtual_Corp_Account_Id__c) + 
                                  String.valueOf(previousQuarter);
                
                if (!previousQuarterPSMap.containsKey(prevPSKey)) {
                    continue; // Skip if no previous quarter PS found
                }
                
                // Query PSD records for this PS to get all budget types and regions
                List<Core_MDF_Partnership_Score_Detail__c> previousPSDList = [
                    SELECT Id, Core_MDF_External_Id__c, Core_MDF_Balance_Amount_Amt__c, 
                           Core_MDF_Budget_Type_Nm__c, Core_MDF_Region_Cd__c, Core_MDF_Node_Account_Id__c
                    FROM Core_MDF_Partnership_Score_Detail__c 
                    WHERE Core_MDF_Partnership_Score_Id__c = :previousQuarterPSMap.get(prevPSKey).Id
                    AND Core_MDF_Balance_Amount_Amt__c != null 
                    AND Core_MDF_Balance_Amount_Amt__c != 0
                ];
                
                // Create external IDs for current quarter based on previous quarter PSD structure
                for (Core_MDF_Partnership_Score_Detail__c prevPSD : previousPSDList) {
                    Id nodeAccountId = prevPSD.Core_MDF_Node_Account_Id__c;
                    String budgetType = prevPSD.Core_MDF_Budget_Type_Nm__c;
                    String region = prevPSD.Core_MDF_Region_Cd__c;
                    
                    // Create external IDs
                    String currentExtId = String.valueOf(currentPS.Core_MDF_Channel_Program_Id__c) + 
                                         String.valueOf(currentPS.Core_MDF_Virtual_Corp_Account_Id__c) + 
                                         String.valueOf(currentQuarter) + 
                                         (nodeAccountId != null ? String.valueOf(nodeAccountId) : '') + 
                                         String.valueOf(budgetType) + 
                                         String.valueOf(region);
                    
                    String previousExtId = prevPSD.Core_MDF_External_Id__c;
                    
                    allExternalIds.add(currentExtId);
                    allExternalIds.add(previousExtId);
                    currentToPreviousExtIdMap.put(currentExtId, previousExtId);
                }
            }
            
            if (allExternalIds.isEmpty()) {
                return;
            }
            
            system.debug('All External IDs: ' + allExternalIds);
            
            //Query all existing PSD records (both current and previous quarters)
            //Creates a map for quick lookup by external ID
            Map<String, Core_MDF_Partnership_Score_Detail__c> extIdToPSDMap = new Map<String, Core_MDF_Partnership_Score_Detail__c>();
            for (Core_MDF_Partnership_Score_Detail__c psd : [SELECT Id, Core_MDF_External_Id__c, Core_MDF_Balance_Amount_Amt__c, 
                                                            Core_MDF_Carry_Over_Amt__c, Core_MDF_Partnership_Score_Detail_Id__c,
                                                            Core_MDF_Budget_Type_Nm__c, Core_MDF_Region_Cd__c, Core_MDF_Node_Account_Id__c
                                                            FROM Core_MDF_Partnership_Score_Detail__c 
                                                            WHERE Core_MDF_External_Id__c IN :allExternalIds]) {
                extIdToPSDMap.put(psd.Core_MDF_External_Id__c, psd);
            }
            
            system.debug('External ID to PSD Map: ' + extIdToPSDMap);
            
            List<Core_MDF_Partnership_Score_Detail__c> psdToUpdate = new List<Core_MDF_Partnership_Score_Detail__c>();
            List<Core_MDF_Partnership_Score_Detail__c> psdToUpsert = new List<Core_MDF_Partnership_Score_Detail__c>();
            
            // Process carry over logic
            //For each current quarter external ID, finds the corresponding previous quarter PSD
            //Takes the balance amount from previous quarter as carry-over amount
            //If current quarter PSD exists: Updates the carry-over amount if different
            //If current quarter PSD doesn't exist: Creates a new PSD record with carry-over amount
            for (String currentExtId : currentToPreviousExtIdMap.keySet()) {
                String previousExtId = currentToPreviousExtIdMap.get(currentExtId);
                Core_MDF_Partnership_Score_Detail__c previousPsd = extIdToPSDMap.get(previousExtId);
                
                if (previousPsd == null || previousPsd.Core_MDF_Balance_Amount_Amt__c == null) {
                    continue; // Skip if no previous PSD or no balance amount
                }
                
                Decimal carryOverAmount = previousPsd.Core_MDF_Balance_Amount_Amt__c;
                Core_MDF_Partnership_Score_Detail__c currentPsd = extIdToPSDMap.get(currentExtId);
                
                if (currentPsd != null) {
                    // Update existing current quarter PSD
                    Decimal existingCarryOverAmount = currentPsd.Core_MDF_Carry_Over_Amt__c == null ? 0 : currentPsd.Core_MDF_Carry_Over_Amt__c;
                    
                    if (existingCarryOverAmount != carryOverAmount) {
                        Core_MDF_Partnership_Score_Detail__c updateRec = new Core_MDF_Partnership_Score_Detail__c(
                            Id = currentPsd.Id,
                            Core_MDF_Carry_Over_Amt__c = carryOverAmount
                        );
                        psdToUpdate.add(updateRec);
                    }
                } else if (carryOverAmount != 0) {
                    // Create new current quarter PSD
                    // Find the corresponding current quarter PS
                    Core_MDF_Partnership_Score__c currentPS = getCurrentQuarterPS(currentExtId, scope);
                    
                    if (currentPS != null) {
                        Core_MDF_Partnership_Score_Detail__c insertRec = new Core_MDF_Partnership_Score_Detail__c();
                        insertRec.Core_MDF_External_Id__c = currentExtId;
                        insertRec.Core_MDF_Partnership_Score_Id__c = currentPS.Id;
                        insertRec.Core_MDF_Carry_Over_Amt__c = carryOverAmount;
                        insertRec.Core_MDF_Budget_Type_Nm__c = previousPsd.Core_MDF_Budget_Type_Nm__c;
                        insertRec.Core_MDF_Region_Cd__c = previousPsd.Core_MDF_Region_Cd__c;
                        insertRec.Core_MDF_Node_Account_Id__c = previousPsd.Core_MDF_Node_Account_Id__c;
                        insertRec.Core_MDF_Partnership_Score_Detail_Id__c = previousPsd.Id;
                        
                        psdToUpsert.add(insertRec);
                    }
                }
            }
            
            system.debug('PSD to Update: ' + psdToUpdate);
            system.debug('PSD to Upsert: ' + psdToUpsert);
            
            /*
            if (!psdToUpdate.isEmpty()) {
                Database.SaveResult[] updateResults = Database.update(psdToUpdate, false);
            }
            if (!psdToUpsert.isEmpty()) {
                 Schema.SObjectField externalIdField = Core_MDF_Partnership_Score_Detail__c.Core_MDF_External_Id__c;
                 Database.UpsertResult[] upsertResults = Database.upsert(psdToUpsert, externalIdField, false);
            }*/
            
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    
    global void finish(Database.BatchableContext bc) {}
    
    private Core_MDF_Partnership_Score__c getCurrentQuarterPS(String currentExtId, List<Core_MDF_Partnership_Score__c> scope) {
        for (Core_MDF_Partnership_Score__c ps : scope) {
            if (currentExtId.contains(String.valueOf(ps.Core_MDF_Channel_Program_Id__c)) && 
                currentExtId.contains(String.valueOf(ps.Core_MDF_Virtual_Corp_Account_Id__c)) &&
                currentExtId.contains(ps.Core_MDF_Quarter_Year_Nm__c)) {
                return ps;
            }
        }
        return null;
    }
    
    public static String getPreviousQuarter(String quarter) {
        List<String> qySplit = quarter.trim().split(' ');
        List<String> qSplit = qySplit[0].split('');
        Integer quarterInteger = Integer.valueOf(qSplit[1]);
        Integer yearInteger = Integer.valueOf(qySplit[1]);
        
        yearInteger = (quarterInteger == 1) ? yearInteger - 1 : yearInteger;
        quarterInteger = (quarterInteger == 1) ? 4 : quarterInteger - 1;
        
        return 'Q' + quarterInteger + ' ' + yearInteger;
    }
}