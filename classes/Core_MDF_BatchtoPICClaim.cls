public class Core_MDF_BatchtoPICClaim implements Queueable, Database.AllowsCallouts {
    public List<PartnerFundClaim> claimList;

    public Core_MDF_BatchtoPICClaim(List<PartnerFundClaim> claimList) {
        this.claimList = claimList;
    }

    public void execute(QueueableContext context) {
        try {
            if (Core_MDF_Utility.byPassFeature('Bypass_addDelayInPICBatch')) {
                Core_MDF_PIC_Utility.addDelay();
            }

            List<PartnerFundClaim> allClaimsList = Core_MDF_HoldCriteriaListProcessHelper.processClaimsForCriteriaHold(claimList);
            if (allClaimsList == null || allClaimsList.isEmpty()) {
                return;
            }

            List<PartnerFundClaim> claimsToBeUpdated = new List<PartnerFundClaim>();
            Set<Id> legacyClaimIds = new Set<Id>();
            Set<Id> picClaimIds = new Set<Id>();
            Map<Id, PartnerFundClaim> claimsMap = new Map<Id, PartnerFundClaim>();
            for (PartnerFundClaim claim : allClaimsList) {
                if (claim.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM) {
                    continue;
                }
                if (Core_MDF_PIC_Utility.isLegacy(claim)) {
                    legacyClaimIds.add(claim.Id);
                } else {
                    picClaimIds.add(claim.Id);
                }
                claimsMap.put(claim.Id, claim);
            }

            Map<String, Set<Id>> inputForRuleEngine = new Map<String, Set<Id>>();
            if (!picClaimIds.isEmpty()) {
                inputForRuleEngine.put('PIC', picClaimIds);
            }
            if (!legacyClaimIds.isEmpty()) {
                inputForRuleEngine.put('Audit', legacyClaimIds);
            }
            Map<String, Map<Id, Core_MDF_Rules_Engine.RulesEngineParams>> ruleEngineResult = Core_MDF_Rules_Engine.genericEngineFlow(inputForRuleEngine);

            if (ruleEngineResult.containsKey('PIC')) {
                Map<Id, Core_MDF_Rules_Engine.RulesEngineParams> picResults = ruleEngineResult.get('PIC');
                for (Id claimId : picResults.keySet()) {
                    PartnerFundClaim claim = claimsMap.get(claimId);
                    if (picResults.get(claimId).result) {
                        claim.Core_MDF_Eligible_for_PIC__c = true;
                        claim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PIC_Pending');
                        claim.Core_MDF_Review_Hold_Rule_Nm__c = String.valueOf(picResults.get(claimId).ruleRecord.Name);
                    }
                    claim.Core_MDF_Reprocess_Claim__c = false;
                    claim.Core_MDF_Claim_EvalInProgress_Ind__c = false;
                    if ((claim.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && claim.Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c == false && claim.Request.Core_MDF_Is_Outcome_Based_Ind__c == false)
                        || (claim.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.RMF_PROGRAM && claim.Core_MDF_Budget_Type_Options_Nm__c == System.Label.Core_MDF_Retail_RSAMD_UnTranslated)) {
                        claim.Core_MDF_Eligible_for_PIC__c = true;
                        claim.Core_MDF_PIC_Review_Completed__c = true;
                    }
                    claimsToBeUpdated.add(claim);
                }
            }

            if (ruleEngineResult.containsKey('Audit')) {
                Map<Id, Core_MDF_Rules_Engine.RulesEngineParams> auditResults = ruleEngineResult.get('Audit');
                List<Id> docCheckList = new List<Id>();
                for (Id claimId : auditResults.keySet()) {
                    if (auditResults.get(claimId).result) {
                        docCheckList.add(claimId);
                    } else {
                        PartnerFundClaim claim = claimsMap.get(claimId);
                        claim.Core_MDF_Reprocess_Claim__c = false;
                        claim.Core_MDF_Claim_EvalInProgress_Ind__c = false;
                        claimsToBeUpdated.add(claim);
                    }
                }
                if (!docCheckList.isEmpty()) {
                    Map<Id, Boolean> docsAvailable = Core_MDF_Audit_Rules_Processing.checkPOPDocuments(docCheckList);
                    for (Id claimId : docCheckList) {
                        PartnerFundClaim claim = claimsMap.get(claimId);
                        if (!docsAvailable.get(claimId)) {
                            claim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_PendingDocs');
                            claim.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c =
                                System.now() + Integer.valueOf(Label.Core_MDF_Document_Submission_Days);
                        } else {
                            claim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PIC_Pending');
                        }
                        claim.Core_MDF_Eligible_for_PIC__c = true;
                        claim.Core_MDF_Review_Hold_Rule_Nm__c = String.valueOf(auditResults.get(claimId).ruleRecord.Name);
                        claim.Core_MDF_Reprocess_Claim__c = false;
                        claim.Core_MDF_Claim_EvalInProgress_Ind__c = false;
                        claimsToBeUpdated.add(claim);
                    }
                }
            }
            Database.update(claimsToBeUpdated);
        } catch (Exception exceptionRecord) {
            Core_MDF_CCP_UtilityClass.logError(exceptionRecord);
            throw exceptionRecord;
        }
    }

    public static void finish(Database.BatchableContext context) {
    }
}