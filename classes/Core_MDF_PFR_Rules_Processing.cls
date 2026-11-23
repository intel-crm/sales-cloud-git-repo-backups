public without sharing class Core_MDF_PFR_Rules_Processing {
    
    public static void executeActivityRule(List<PartnerFundRequest> activityRec,Map<Id,PartnerFundRequest> oldMapPartner) {
        List<PartnerFundRequest> frontEndReviewList = new List<PartnerFundRequest>();
        system.debug('activityRec-->'+activityRec);
        try{
            for(PartnerFundRequest activityRr: activityRec) {
                if(activityRr.Core_MDF_Budget_Type_nm__c == 'RSA MD' || activityRr.Core_MDF_Budget_Type_nm__c == 'MDF' || activityRr.Core_MDF_Budget_Type_nm__c == 'OEM CMP'){
                    if(activityRr.Core_MDF_Approval_Step_Completed__c == 0 || activityRr.Core_MDF_Approval_Step_Completed__c != oldMapPartner.get(activityRr.Id).Core_MDF_Approval_Step_Completed__c){
                        if(activityRr.Core_MDF_Approval_Step_Completed__c > oldMapPartner.get(activityRr.Id).Core_MDF_Approval_Step_Completed__c){
                         activityRr.Core_MDF_Completed_Approval_Level_Name__c = activityRr.Core_MDF_Pending_Approval_Level_Name__c;  
                        }	
                        frontEndReviewList.add(activityRr);
                    }
                }
            }
            //system.debug('frontEndReviewList-->'+frontEndReviewList[0].Core_MDF_Completed_Approval_Level_Name__c);
            if(frontEndReviewList.size() > 0){
                Map<string,List<sobject>> inputMap = new Map<string,List<sobject>>();
                Map<String,Core_MDF_Rules_Engine.RulesEngineParams> ruleMatch = new  Map<String,Core_MDF_Rules_Engine.RulesEngineParams>();
                Core_MDF_Rules_Engine.RulesEngineParams matchedRuleReturn = new Core_MDF_Rules_Engine.RulesEngineParams();
                
                inputMap.put('Front End Review', frontEndReviewList);
                Map<String,Map<String,Core_MDF_Rules_Engine.RulesEngineParams>> rulesWrapper =  Core_MDF_Rules_Engine.executeRulesByObjects(inputMap);
                System.debug('rulesWrapper'+rulesWrapper);
                for(String s:rulesWrapper.keySet()){
                    ruleMatch = rulesWrapper.get(s);   
                }
                for(String d:ruleMatch.keySet()){
                    matchedRuleReturn = ruleMatch.get(d) ;
                }
                System.debug('ruleMatch'+ruleMatch);
                System.debug('matchedRuleReturn'+matchedRuleReturn);
                System.debug('ruleMatch3'+matchedRuleReturn.result);
                System.debug('ruleMatch4'+matchedRuleReturn.ruleRecord);
                System.debug('ruleMatch5'+matchedRuleReturn.ruleRecord.Core_MDF_Process_Name__c);
                System.debug('ruleMatch9');
                System.debug('activityRec-->'+activityRec);
                System.debug('oldMapPartner-->'+oldMapPartner);
                for(PartnerFundRequest actvtyRecord: frontEndReviewList) {
                    if(matchedRuleReturn.ruleRecord != null){
                        if(matchedRuleReturn.ruleRecord.Core_MDF_Action_on_True_nm__c != null && matchedRuleReturn.result == true){
                            actvtyRecord.Core_MDF_Pending_Approval_Level_Name__c = matchedRuleReturn.ruleRecord.Core_MDF_Action_on_True_nm__c;
                        } if(matchedRuleReturn.ruleRecord.Core_MDF_Action_on_False_nm__c != null && matchedRuleReturn.result == false){
                            actvtyRecord.Core_MDF_Pending_Approval_Level_Name__c = matchedRuleReturn.ruleRecord.Core_MDF_Action_on_False_nm__c;
                        }
                        if(matchedRuleReturn.ruleRecord.Core_MDF_Process_Name__c != null){
                            actvtyRecord.Core_MDF_Rule_Engine_Process_Name__c = matchedRuleReturn.ruleRecord.Core_MDF_Process_Name__c;
                        } 
                    }
                } 
            }
            
        }
        
        catch(exception ex){
            system.debug('ex-->'+ex.getMessage());
            Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
    
}