public class Core_MDF_BatchtoPICClaim implements Queueable, Database.AllowsCallouts {
    
     public List<PartnerFundClaim> claimList;
    
     public Core_MDF_BatchtoPICClaim(List<PartnerFundClaim> claimList){
        this.claimList = claimList;    
    }


     public void execute(QueueableContext context){
        try{
            if(Core_MDF_Utility.byPassFeature('Bypass_addDelayInPICBatch'))
            {
                Core_MDF_PIC_Utility.addDelay();
            }
            
            List<PartnerFundClaim> claimsToBeUpdated = new List<PartnerFundClaim>();
            // Calling Hold List Criteria Logic
            List<PartnerFundClaim> allClaimsList =  Core_MDF_HoldCriteriaListProcessHelper.processClaimsForCriteriaHold(claimList);   
            Set<Id> legacyClaimIdList = new Set<Id>();
            Set<Id> claimIdList = new Set<Id>();
            Map<Id,PartnerFundClaim> legacyClaimsMap = new Map<Id,PartnerFundClaim>();
            Map<Id,PartnerFundClaim> claimsMap = new Map<Id,PartnerFundClaim>();
            Map<string,Set<Id>> inputForRuleEngine= new Map<string,Set<Id>>();
            //ATHR - Deeply Nested if 16209
            if(allClaimsList == null || allClaimsList.isEmpty()){
                return;
            }
                List<PartnerFundClaim> claimsToBeProcessedList = new List<PartnerFundClaim>();
                for(PartnerFundClaim pfc : allClaimsList)
                {
                    if(pfc.Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM){//Bypass CoGTM claims
                        claimsToBeProcessedList.add(pfc);
                    }
                }

                for (PartnerFundClaim pfc : claimsToBeProcessedList) {
                    if(Core_MDF_PIC_Utility.isLegacy(pfc)){
                        legacyClaimIdList.add(pfc.ID);
                    }else{
                        claimIdList.add(pfc.ID);
                    }
                    
                    claimsMap.put(pfc.Id, pfc);
                }
                
                if(claimIdList!=null && claimIdList.size()>0){
                    inputForRuleEngine.put('PIC',claimIdList);    
                }
                
                if(legacyClaimIdList!=null && legacyClaimIdList.size()>0){
                    inputForRuleEngine.put('Audit',legacyClaimIdList);    
                }
                                                
                Map<string,Map<Id,Core_MDF_Rules_Engine.RulesEngineParams>> ruleEngineResult = Core_MDF_Rules_Engine.genericEngineFlow(inputForRuleEngine);
                
                for(String ruleType : ruleEngineResult.keySet())
                {
                    System.debug('RuleType -->'+ruleType);
                    if(ruleType == 'PIC')
                    {   
                        Map<Id,Core_MDF_Rules_Engine.RulesEngineParams> rule1 = ruleEngineResult.get('PIC');
                        for(Id claimID : rule1.keySet())
                        {
                            PartnerFundClaim claim1 = claimsMap.get(claimID);
                            if(rule1.get(claimID).result)
                            {
                                claim1.Core_MDF_Eligible_for_PIC__c = true;
                                claim1.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PIC_Pending');
                                claim1.Core_MDF_Review_Hold_Rule_Nm__c = string.valueof(rule1.get(claimID).ruleRecord.Name);
                            }
                            claim1.Core_MDF_Reprocess_Claim__c = false;//Added to avoid conflict with validation rule preventing reprocessing for other statuses
							claim1.Core_MDF_Claim_EvalInProgress_Ind__c = false;
                            if((claim1.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && (claim1.Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c == FALSE && claim1.Request.Core_MDF_Is_Outcome_Based_Ind__c == FALSE))
                            || (claim1.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.RMF_PROGRAM && claim1.Core_MDF_Budget_Type_Options_Nm__c == System.Label.Core_MDF_Retail_RSAMD_UnTranslated)){
                                claim1.Core_MDF_Eligible_for_PIC__c = true;
                                claim1.Core_MDF_PIC_Review_Completed__c = true;
                            }
                            claimsToBeUpdated.add(claim1);
                        }
                    }
                    if(ruleType == 'Audit')
                    {
                        Map<Id,Core_MDF_Rules_Engine.RulesEngineParams> rule2 = ruleEngineResult.get('Audit');
                        List<Id> docCheckList= new List<Id>();
                        for(Id claimID : rule2.keySet())
                        {
                            if(rule2.get(claimID).result)
                            {
                                docCheckList.add(claimID);
                                
                            }
                            else
                            {
                                PartnerFundClaim claim3 = claimsMap.get(claimID);
                                claim3.Core_MDF_Reprocess_Claim__c = false;//Added to avoid conflict with validation rule preventing reprocessing for other statuses
                                
                                claim3.Core_MDF_Claim_EvalInProgress_Ind__c = false;
                                claimsToBeUpdated.add(claim3);
                            }
                        }
                        Map<Id,Boolean> docsAvailable = Core_MDF_Audit_Rules_Processing.checkPOPDocuments(docCheckList);
                        for(Id pfcId : docCheckList)
                        {
                            PartnerFundClaim claim2 = claimsMap.get(pfcId);
                            if(!docsAvailable.get(pfcId))
                            {
                                claim2.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_PendingDocs');
                                claim2.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c  = System.now() + Integer.valueOf(Label.Core_MDF_Document_Submission_Days);//For Reminder Notifications
                            }
                            else
                            {
                                claim2.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PIC_Pending');
                            }
                            claim2.Core_MDF_Eligible_for_PIC__c = true;
                            claim2.Core_MDF_Review_Hold_Rule_Nm__c = string.valueof(rule2.get(pfcId).ruleRecord.Name);
                            claim2.Core_MDF_Reprocess_Claim__c = false;//Added to avoid conflict with validation rule preventing reprocessing for other statuses
                            claim2.Core_MDF_Claim_EvalInProgress_Ind__c = false;
                            claimsToBeUpdated.add(claim2); 
                        }
                    }
                    
                }

                Database.update(claimsToBeUpdated);
        }
        catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e); throw e;
        }
    }
    
    public static  void finish(Database.BatchableContext BC){
        
          }
    
}