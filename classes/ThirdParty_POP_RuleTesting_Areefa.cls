public class ThirdParty_POP_RuleTesting_Areefa {
    
    public static boolean thirdPartyPOPRule(){
        
        boolean isThirstPartyPOP = false;
        List<PartnerFundClaim> claimListToBeProcessed = [Select Id,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_Program__c,Request.Core_MDF_Fund_Request_Status__c  
                                                         from PartnerFundClaim where Core_MDF_Program__c='Client Co-Marketing Fund' and Id='0RBg00000000A2OGAU' limit 1];
        List<sObject> obj = new List<sObject>(); 
        obj = (List<sObject>)claimListToBeProcessed;
        Map<String,List<sobject>> inputForRuleEngine= new Map<String,List<sobject>>();
        inputForRuleEngine.put('Third Party', obj);
        
        Map<String,List<sobject>> inputForRuleEngine1= new Map<String,List<sobject>>();         
        inputForRuleEngine1.put('Third Party', claimListToBeProcessed);
        
        system.debug('inputForRuleEngine::'+inputForRuleEngine);
        Map<String,Map<String,Core_MDF_Rules_Engine.RulesEngineParams>> ruleEngineResult = Core_MDF_Rules_Engine.executeRulesByObjects(inputForRuleEngine1); 
        system.debug('ruleEngineResult' +ruleEngineResult);
        
        for(String ruleType : ruleEngineResult.keySet()){
            if(ruleType == 'Third Party'){   
                System.Debug('Inside Third Party check');
                Map<String,Core_MDF_Rules_Engine.RulesEngineParams> rule1 = ruleEngineResult.get('Third Party');
                for(String trdPrtPop : rule1.keySet()){
                    if(rule1.get(trdPrtPop).result){
                        system.debug('inside rule1.keySet()');
                        isThirstPartyPOP=true;
                    }
                }
                
            }
        }        
        system.debug('isThirstPartyPO'+isThirstPartyPOP);
        return isThirstPartyPOP;
    }
}

 
        /*
     	system.debug('inputForRuleEngine::'+inputForRuleEngine);
        Map<String,Map<String,Core_MDF_Rules_Engine.RulesEngineParams>> ruleEngineResult = Core_MDF_Rules_Engine.executeRulesByObjects(inputForRuleEngine); 
        system.debug('ruleEngineResult' +ruleEngineResult);
         //2. ruleEngineResult : containes check for ThirdParty, if containe ruleEngineResult.get (third party).result , isThirstPartyPOP=true;  break .
         // 3.update ruleId, obj, and flag 
         // 4. and enable track history on claim
         
        ///for(String ruleType : ruleEngineResult.keySet()){
            if(ruleType == 'Third Party'){   ///
                System.Debug('Inside Third Party check');
                Map<String,Core_MDF_Rules_Engine.RulesEngineParams> rule1 = ruleEngineResult.get('Third Party'); // if rule1 is null will get exception testing
                for(String thirdPartyPop : rule1.keySet()){
                    if(rule1.get(thirdPartyPop)!=null && rule1.get(thirdPartyPop).result){
                        system.debug('inside rule1.keySet()');
                        isThirstPartyPOP=true;  
                    }
                }
                
            }
        }        
        system.debug('isThirstPartyPO'+isThirstPartyPOP);
        return isThirstPartyPOP; */

//2. ruleEngineResult : containes check for ThirdParty, if containe ruleEngineResult.get (third party).result , isThirstPartyPOP=true;  break .
         // 3.update ruleId, obj, and flag 
         // 4. and enable track history on claim
         // 
 /*PartnerFundClaim pfc1 =[Select Id,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Region_Cd__c,Core_MDF_Type_Txt__c,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_Program__c,Request.Core_MDF_Fund_Request_Status__c  
                                                 from PartnerFundClaim 
                                                 where Id In('0RBg00000000AYoGAM')]; 
        pfc1.Core_MDF_Region_Cd__c='APJ';*/
        //pfc.Core_MDF_Budget_Type_Options_Nm__c='MDF';