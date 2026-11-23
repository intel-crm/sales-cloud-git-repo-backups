// Core_MDF_Batch_CarryOver_Sync batch = new Core_MDF_Batch_CarryOver_Sync(); Database.executeBatch(batch, 200);

// multiple cases for same key? - can happen? how to handle? - should be fine, because psd will be single only
// what to do if source psd is null? - skip or still create target psd? - can happen?


global without sharing class Core_MDF_Batch_CarryOver_Sync implements Database.Batchable<SObject> {

    Integer SOQL_DAYS = 30;
    Set<String> nodeAccountSupportedProgramsSet = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;

    global Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT Id, AccountId, Account.Core_MDF_Virtual_Corp_Account_Id__c, Account.Core_MDF_Channel_Program__c, Account.Core_MDF_CoMarketing_Ultimate_Account__c, ' +
                        'Core_MDF_Channel_Program_txt__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Previous_Closed_Dt__c, Core_MDF_Earlier_Quarter_Closed_Dt__c, Core_MDF_Region_SubRegion_txt__c, ' + 
            			'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c FROM Case WHERE Core_MDF_Claim_Lookup_Id__c != null AND ' +
                        'RecordType.DeveloperName IN (\'' + CCPConstantClass.CASE_OPEN_RECORDTYPE_NAME + '\',\'' + CCPConstantClass.CASE_CLOSED_RECORDTYPE_NAME + '\') ' +
                        'AND Core_MDF_Earlier_Quarter_Closed_Dt__c != null AND LastModifiedDate = LAST_N_DAYS:' + SOQL_DAYS;

                        //case reopen flag
                        

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        try {

            Set<String> targetQuarters = new Set<String>();

            Map<Id, String> caseIdToTargetQuarterMap = new Map<Id, String>();
            Map<Id, String> caseIdToSourceQuarterMap = new Map<Id, String>();

            Map<String, Case> targetExtIdToCaseMap = new Map<String, Case>();
            Map<String, String> targetExtIdToSourceExtIdMap = new Map<String, String>();

            Set<Id> channelProgramIds = new Set<Id>();
            Set<Id> virtualCorpAccountIds = new Set<Id>();
            Set<Id> ultimateAccountIds = new Set<Id>();

            system.debug('caseRec@@@' + scope);
            for (Case caseRec : scope) {
                
                String targetQuarter = Core_MDF_ReverseAuditDecision.determineQuartYear(Date.newinstance(caseRec.Core_MDF_Earlier_Quarter_Closed_Dt__c.year(), caseRec.Core_MDF_Earlier_Quarter_Closed_Dt__c.month(), caseRec.Core_MDF_Earlier_Quarter_Closed_Dt__c.day()));
                String sourceQuarter = getPreviousQuarter(targetQuarter);

                if (String.isNotBlank(targetQuarter) && String.isNotBlank(sourceQuarter)) {
                    caseIdToTargetQuarterMap.put(caseRec.Id, targetQuarter);
                    caseIdToSourceQuarterMap.put(caseRec.Id, sourceQuarter);
                    targetQuarters.add(targetQuarter);  // to query for PS records (to stamp on PSD)
                }
                if (caseRec.Account.Core_MDF_CoMarketing_Ultimate_Account__c != null) {
                    ultimateAccountIds.add(caseRec.Account.Core_MDF_CoMarketing_Ultimate_Account__c);
                }
            }

            if (caseIdToTargetQuarterMap.isEmpty()) { return; }

            String ultimateAccountIdsFinal = ultimateAccountIds.isEmpty() ? '' : String.join(new List<Id>(ultimateAccountIds), ',');
            system.debug('ultimateAccountIdsFinal@@@' + ultimateAccountIdsFinal);
            //get virtua lcorp directly from case - check
            Map<Id, Map<Id, Id>> intelAccountIdToProgramToVirtualCorpAccountId = Core_MDF_IAH_Partnership_Score.getVirtualCorpAccount('', ultimateAccountIdsFinal);
            system.debug('intelAccountIdToProgramToVirtualCorpAccountId@@@' + intelAccountIdToProgramToVirtualCorpAccountId);

            
            for (Case caseRec : scope) {
                if (!caseIdToTargetQuarterMap.containsKey(caseRec.Id)) { continue; }

                Id channelProgramId = caseRec.Account.Core_MDF_Channel_Program__c;
                Id virtualCorpAccountId = getVirtualCorpAccountId(caseRec, intelAccountIdToProgramToVirtualCorpAccountId);
                String programName = String.valueOf(caseRec.Core_MDF_Channel_Program_txt__c);
                Id nodeAccountId = nodeAccountSupportedProgramsSet.contains(programName) ? caseRec.AccountId : null;
                String budgetType = caseRec.Core_MDF_Budget_Type_nm__c;
                String region = caseRec.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c;

                String targetQuarter = caseIdToTargetQuarterMap.get(caseRec.Id);
                String sourceQuarter = caseIdToSourceQuarterMap.get(caseRec.Id);

                // Creating PSD unique key for both source and target quarter
                String targetExtId = String.valueOf(channelProgramId) + String.valueOf(virtualCorpAccountId) + String.valueOf(targetQuarter) + (nodeAccountId != null ? String.valueOf(nodeAccountId) : '') + String.valueOf(budgetType) + String.valueOf(region);
                String sourceExtId = String.valueOf(channelProgramId) + String.valueOf(virtualCorpAccountId) + String.valueOf(sourceQuarter) + (nodeAccountId != null ? String.valueOf(nodeAccountId) : '') + String.valueOf(budgetType) + String.valueOf(region);

                system.debug('targetExtId@@@' + targetExtId);
                if (!targetExtIdToCaseMap.containsKey(targetExtId)) {
                    targetExtIdToCaseMap.put(targetExtId, caseRec);  // used while creating PSD records for target quarter
                    targetExtIdToSourceExtIdMap.put(targetExtId, sourceExtId);  // used to get balacne amount from source quarter PSD
                }

                channelProgramIds.add(channelProgramId);
                if (virtualCorpAccountId != null) {
                    virtualCorpAccountIds.add(virtualCorpAccountId);
                }
            }

            if (targetExtIdToCaseMap.isEmpty()) { return; }

            system.debug('targetExtIdToCaseMap@@@' + targetExtIdToCaseMap);
            system.debug('channelProgramIds@@@' + channelProgramIds);
            system.debug('virtualCorpAccountIds@@@' + virtualCorpAccountIds); 

            //querying Partnership Score records from target quarters (to stamp on target quarter PSD record)
            Map<String, Core_MDF_Partnership_Score__c> programVcQuarterToPScoreMap = new Map<String, Core_MDF_Partnership_Score__c>();
            for (Core_MDF_Partnership_Score__c ps : [SELECT Id, Core_MDF_Program_nm__c, Core_MDF_Virtual_Corp_Account_Id__c, Core_MDF_Channel_Program_Id__c, Core_MDF_Quarter_Year_Nm__c
                                                        FROM Core_MDF_Partnership_Score__c WHERE Core_MDF_Quarter_Year_Nm__c IN :targetQuarters
                                                        AND Core_MDF_Channel_Program_Id__c IN :channelProgramIds AND Core_MDF_Virtual_Corp_Account_Id__c IN :virtualCorpAccountIds]) {
                programVcQuarterToPScoreMap.put(String.valueOf(ps.Core_MDF_Program_nm__c) + String.valueOf(ps.Core_MDF_Virtual_Corp_Account_Id__c) + String.valueOf(ps.Core_MDF_Quarter_Year_Nm__c), ps);
            }

            system.debug('programVcQuarterToPScoreMap@@@' + programVcQuarterToPScoreMap);

            //building external IDs for both target quarter and source quarter
            Set<String> allExternalIds = new Set<String>();
            for (String targetExtId : targetExtIdToCaseMap.keySet()) {
                allExternalIds.add(targetExtIdToSourceExtIdMap.get(targetExtId));
                allExternalIds.add(targetExtId);
            }
            system.debug('allExternalIds@@@' + allExternalIds);

            //querying Partnership Score Detail records from target quarter and source quarter external IDs
            Map<String, Core_MDF_Partnership_Score_Detail__c> extIdToPSDMap = new Map<String, Core_MDF_Partnership_Score_Detail__c>();
            for (Core_MDF_Partnership_Score_Detail__c psd : [SELECT Id, Core_MDF_External_Id__c, Core_MDF_Balance_Amount_Amt__c, Core_MDF_Carry_Over_Amt__c, Core_MDF_Partnership_Score_Detail_Id__c
                                                                FROM Core_MDF_Partnership_Score_Detail__c WHERE Core_MDF_External_Id__c IN :allExternalIds]) {
                extIdToPSDMap.put(psd.Core_MDF_External_Id__c, psd);
            }
            system.debug('extIdToPSDMap@@@' + extIdToPSDMap);

            List<Core_MDF_Partnership_Score_Detail__c> psdToUpdate = new List<Core_MDF_Partnership_Score_Detail__c>();
            List<Core_MDF_Partnership_Score_Detail__c> psdToUpsert = new List<Core_MDF_Partnership_Score_Detail__c>();

            //updating existing target quarter PSD or inserting missing target quarter PSD
            for (String targetExtId : targetExtIdToCaseMap.keySet()) {
                Case caseRec = targetExtIdToCaseMap.get(targetExtId);
                String sourceExtId = targetExtIdToSourceExtIdMap.get(targetExtId);

                Core_MDF_Partnership_Score_Detail__c sourcePsd = extIdToPSDMap.get(sourceExtId);
                if (sourcePsd == null) { continue; }  //skipping if source quarter PSD is not found
                Core_MDF_Partnership_Score_Detail__c targetPsd = extIdToPSDMap.get(targetExtId);

                Decimal carryOverAmount = 0;
                if (sourcePsd.Core_MDF_Balance_Amount_Amt__c != null) {
                    carryOverAmount = sourcePsd.Core_MDF_Balance_Amount_Amt__c;
                } 

                if (targetPsd != null) {
                    Decimal existingCarryOverAmount = targetPsd.Core_MDF_Carry_Over_Amt__c == null ? 0 : targetPsd.Core_MDF_Carry_Over_Amt__c;

                    // updating if there is a change in carryover amount
                    if (existingCarryOverAmount != carryOverAmount) {
                        Core_MDF_Partnership_Score_Detail__c updateRec = new Core_MDF_Partnership_Score_Detail__c(
                            Id = targetPsd.Id,
                            Core_MDF_Carry_Over_Amt__c = carryOverAmount
                        );
                        psdToUpdate.add(updateRec);
                    }
                    continue;
                } else {
                    // creating new PSD if it is missing and carry over is not 0 (positive or negative)
                    Id virtualCorpAccountId = getVirtualCorpAccountId(caseRec, intelAccountIdToProgramToVirtualCorpAccountId);
                    String programName = String.valueOf(caseRec.Core_MDF_Channel_Program_txt__c);
                    String targetQuarter = caseIdToTargetQuarterMap.get(caseRec.Id);
                    Core_MDF_Partnership_Score__c targetPS = programVcQuarterToPScoreMap.get(String.valueOf(programName) + String.valueOf(virtualCorpAccountId) + String.valueOf(targetQuarter));

                    if (carryOverAmount == 0/* || targetPS == null*/) { continue; }  //check for target ps not null before stamping, ideal scenario?
                    Core_MDF_Partnership_Score_Detail__c insertRec = new Core_MDF_Partnership_Score_Detail__c();
                    insertRec.Core_MDF_External_Id__c = targetExtId;
                    insertRec.Core_MDF_Partnership_Score_Id__c = targetPS.Id;
                    insertRec.Core_MDF_Carry_Over_Amt__c = carryOverAmount;
                    insertRec.Core_MDF_Budget_Type_Nm__c = caseRec.Core_MDF_Budget_Type_nm__c;
                    insertRec.Core_MDF_Region_Cd__c = caseRec.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c;
                    insertRec.Core_MDF_Node_Account_Id__c = nodeAccountSupportedProgramsSet.contains(programName) ? caseRec.AccountId : null;
                    insertRec.Core_MDF_Partnership_Score_Detail_Id__c = sourcePsd.Id;
                    psdToUpsert.add(insertRec);
                }
            }

            system.debug('psdToUpdate@@@' + psdToUpdate);
            system.debug('psdToUpsert@@@' + psdToUpsert);

            // if (!psdToUpdate.isEmpty()) {
            //     Database.SaveResult[] updateResults = Database.update(psdToUpdate, false);
            // }

            // if (!psdToUpsert.isEmpty()) {
            //     Schema.SObjectField externalIdField = Core_MDF_Partnership_Score_Detail__c.Core_MDF_External_Id__c;
            //     Database.UpsertResult[] upsertResults = Database.upsert(psdToUpsert, externalIdField, false);
            // }

        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }

    global void finish(Database.BatchableContext bc) {}

    public static Id getVirtualCorpAccountId(Case caseRec, Map<Id, Map<Id, Id>> intelAccountIdToProgramToVirtualCorpAccountId) {
        Id ultimateAccountId = caseRec.Account.Core_MDF_CoMarketing_Ultimate_Account__c;

        if (ultimateAccountId != null && intelAccountIdToProgramToVirtualCorpAccountId.containsKey(ultimateAccountId) && intelAccountIdToProgramToVirtualCorpAccountId.get(ultimateAccountId).containsKey(caseRec.Account.Core_MDF_Channel_Program__c)) {
            return intelAccountIdToProgramToVirtualCorpAccountId.get(ultimateAccountId).get(caseRec.Account.Core_MDF_Channel_Program__c);
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