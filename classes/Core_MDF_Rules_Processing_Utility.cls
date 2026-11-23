public class Core_MDF_Rules_Processing_Utility {

    public static final Map<id,Core_MDF_Audit_Rules_Engine__c> AUDIT_RULES_MAP = new Map<id,Core_MDF_Audit_Rules_Engine__c>();
    /***********************************************************
     * Method Name 		: executeRulesByObjects
     * Input Parameter	: Map<string,List<sobject>> ; Key -> Rule Type , List<Sbojects> - obejctlist for which the rules need to be evalauted
     * Return Type 		: Map<String , Core_MDF_RuleEngineParams>
	 * Description		: This accepts the record with unique identifier..
    ***********************************************************/
    public static Map<String,List<Core_MDF_RuleEngineParams>> executeRulesByObjects(Map<string,List<sobject>> inputMap) {
        Map<String,List<Core_MDF_RuleEngineParams>> resultWrapper;
       Set<String> auditRuleTypeSet = new Set<String>();
		Set<String> objectNameSet = new Set<String>();
        List<sobject> sobjectList = new List<sobject>();
		Map<string,Set<string>> recMap = new Map<string,Set<string>>();
        if(inputMap != null && inputMap.keySet()!=null){
            auditRuleTypeSet = inputMap.keySet();
			for(String key:inputMap.keySet()){
                List<sobject> sObjList = new List<sobject>();
				objectNameSet.add(getObjectType(inputMap.get(key)[0]));
                sobjectList.addAll(inputMap.get(key));
				if(!recMap.containsKey(key)){
					recMap.put(key,new Set<string>());
				}
				recMap.get(key).addAll(objectNameSet);
			}
        }
        system.debug('recMap---> ' + recMap);
        system.debug('objectNameSet--->' + objectNameSet);
		//if(!objectNameSet.isEmpty()){
			Map<string, Map<Id, Core_MDF_Audit_Rules_Engine__c>> programToRules = Core_MDF_Rules_Processing_Utility.getMatchingRules(recMap.keySet(),objectNameSet);
			
            for(String ruleType : inputMap.keyset()){
                //system.debug('ruleType---> ' + ruleType);
                //system.debug('value---> ' + inputMap.get(ruleType));
                Core_MDF_Rules_Processing_Utility.matchRecordsAgainstRules(ruleType, inputMap.get(ruleType), programToRules);
            }
        //}
        return resultWrapper;        
    }
    
	/***********************************************************
     * Method Name 		: executeRulesByObjects
     * Input Parameter	: Map<string,List<sobject>>
     * Return Type 		: Map<String , Core_MDF_RuleEngineParams>
	 * Description		: This accepts the record with unique identifier..
    ***********************************************************/
    public Map<String,Core_MDF_RuleEngineParams> executeRulesByObjects(Map<string,List<Map<id,sobject>>> inputMap) {
        Map<String,Core_MDF_RuleEngineParams>resultWrapper;
        Set<String> auditRuleTypeSet = new Set<String>();
		Set<String> objectNameSet = new Set<String>();
        List<sobject> sobjectList = new List<sobject>();
		Map<string,Set<string>> recMap = new Map<string,Set<string>>();
        if(inputMap != null && inputMap.keySet()!=null){
            auditRuleTypeSet = inputMap.keySet();
			for(String key:inputMap.keySet()){
             /*   List<sobject> sObjList = new List<sobject>();
                sObjList = inputMap.get(key);
				objectNameSet.add(getObjectType(sObjList[0]));
                sobjectList.addAll(inputMap.get(key));
				if(!recMap.containsKey(key)){
					recMap.put(key,new Set<string>());
				}
				recMap.get(key).addAll(objectNameSet);*/
			}
        }
		if(!objectNameSet.isEmpty()){
			//Map<string, List<Core_MDF_Audit_Rules_Engine__c>> programToRules = Core_MDF_Rules_Processing_Utility.getMatchingRules(recMap);
			//Core_MDF_PFR_Rules_Processing.matchActivityAgainstRules(sobjectList,programToRules);
		}
        return resultWrapper;    
	}
  
    /***********************************************************
     * Method Name 		: getObjectType
     * Input Parameter	: sObject
     * Return Type 		: String
    ***********************************************************/
    public static string getObjectType(sObject obj) {
        string objectTypeStr;
       Schema.sObjectType objType = obj.getSObjectType();
		if(objType !=null){
			objectTypeStr = String.valueOf(objType);
		}
        return objectTypeStr;
    }
    public static void executeRule(Set<string> ruleTypes, Set<String> objectNames,List<sobject> recordList) {
        try{
            Map<string, Map<Id,Core_MDF_Audit_Rules_Engine__c>> programToRules = Core_MDF_Rules_Processing_Utility.getMatchingRules(ruleTypes,objectNames);
            System.debug('AurRecor'+programToRules);
          //  Core_MDF_Rules_Processing_Utility.matchRecordsAgainstRules(recordList,programToRules);    
        }
        
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }
	 /* Method to query all the  rules relevant to the Program */
    public static Map<string, Map<Id, Core_MDF_Audit_Rules_Engine__c>> getMatchingRules(Set<string> ruleTypes, Set<String> objectNames) {
        Map<string, Map<Id, Core_MDF_Audit_Rules_Engine__c>> prgmBTToRulesMap = new Map<string,Map<ID,Core_MDF_Audit_Rules_Engine__c>>();
        List<Core_MDF_Audit_Rules_Engine__c> rulesList;
        Set<string> fieldsList; 
        string random = 'Random';
	
        Map<string,set<string>> objectToFieldsMap = new Map<string,set<string>>();
        Map<Id,Core_MDF_Audit_Rules_Engine__c> IdRulesObjectMap = new Map<Id,Core_MDF_Audit_Rules_Engine__c>();
        Map<Id,Core_MDF_Audit_Rules_Engine__c> ImeIdRulesObjectMap = new Map<Id,Core_MDF_Audit_Rules_Engine__c>();
        try{
            for(Core_MDF_Audit_Rules_Engine__c rules: [select Name, toLabel(Core_MDF_Program_Nm__c), Core_MDF_Budget_Type_Nm__c,Core_MDF_Region_Cd__c, Core_MDF_Object_Nm__c,Core_MDF_Field_Nm__c, Core_MDF_Operator_Nm__c,Core_MDF_Value_Txt__c,Core_MDF_Next_Rule_Id__c,Core_MDF_Immediate_Ind__c,Core_MDF_Next_Rule_False_Id__c,Core_MDF_ID_Field_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Rule_Type_Nm__c
                                                       ,Core_MDF_Action_on_True_nm__c
                                                       ,Core_MDF_Action_on_False_nm__c
                                                       ,Core_MDF_Look_Up_Field_Ind__c,
                                                       Core_MDF_Process_Name__c from Core_MDF_Audit_Rules_Engine__c 
													   where Core_MDF_Active_Ind__c=true  
                                                       and Core_MDF_Rule_Type_Nm__c IN : ruleTypes and  Core_MDF_Object_Nm__c In : objectNames
													   order by Core_MDF_Region_Cd__c]) {
                                                           //AND toLabel(Core_MDF_Program_Nm__c) in :program
                                                        
                                                        if(prgmBTToRulesMap.get(rules.Core_MDF_Rule_Type_Nm__c) != null){
                                                            prgmBTToRulesMap.get(rules.Core_MDF_Rule_Type_Nm__c).put(rules.id,rules);
                                                        }
                                                        else{
                                                            prgmBTToRulesMap.put(rules.Core_MDF_Rule_Type_Nm__c,new Map<Id, Core_MDF_Audit_Rules_Engine__c>() );
                                                            prgmBTToRulesMap.get(rules.Core_MDF_Rule_Type_Nm__c).put(rules.id,rules);
                                                        }
                                                        
                                                        if(rules.Core_MDF_Immediate_Ind__c == 'Yes'){
                                                            String KeyImd = rules.Core_MDF_Rule_Type_Nm__c + 'Imd';
                                                            if(prgmBTToRulesMap.get(KeyImd) != null){
                                                                prgmBTToRulesMap.get(KeyImd).put(rules.id, rules);
                                                            }
                                                            else{
                                                                prgmBTToRulesMap.put(KeyImd,new Map<Id, Core_MDF_Audit_Rules_Engine__c>());
                                                                prgmBTToRulesMap.get(KeyImd).put(rules.id, rules);
                                                            }
                                                        }
                                                           
                                                           
                                                      /*     string key = rules.Core_MDF_Program_Nm__c + rules.Core_MDF_Budget_Type_Nm__c;
                                                           rulesList = prgmBTToRulesMap.get(key) == null? new List<Core_MDF_Audit_Rules_Engine__c>() : prgmBTToRulesMap.get(key);
                                                           if(rules.Core_MDF_Object_Nm__c!=random) {
                                                               fieldsList = objectToFieldsMap.get(rules.Core_MDF_Object_Nm__c) == null? new Set<string>():objectToFieldsMap.get(rules.Core_MDF_Object_Nm__c);
                                                               fieldsList.add(rules.Core_MDF_Field_Nm__c);
                                                               objectToFieldsMap.put(rules.Core_MDF_Object_Nm__c,fieldsList);
                                                           }
                                                           rulesList.add(rules);
                                                           prgmBTToRulesMap.put(key, rulesList);
                                                           
                                                           AUDIT_RULES_MAP.put(rules.id,rules);*/
                                                       }
            //if(objectToFieldsMap.keySet().contains('PartnerFundClaim') || objectToFieldsMap.keySet().contains('PartnerFundRequest')) {
                //  queryClaimFields(objectToFieldsMap, claimRecords);
          //  }
            system.debug('prgmBTToRulesMap' + prgmBTToRulesMap);
            system.debug('objectToFieldsMap' + objectToFieldsMap);
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return prgmBTToRulesMap;
    }
    
     public static void matchRecordsAgainstRules(String ruleType, List<PartnerFundRequest> recordList, Map<string, Map<Id, Core_MDF_Audit_Rules_Engine__c>> prgmBTToRulesMap) {
        List<Core_MDF_Audit_Rules_Engine__c> rulesToBeExecuted = new List<Core_MDF_Audit_Rules_Engine__c>();
        Map<id,string> result = new Map<id,string>();
        string yes='Yes';
        String KeyImd = ruleType + 'Imd';
        try{
            Map<Id, Core_MDF_Audit_Rules_Engine__c> ruleRecordList = prgmBTToRulesMap.get(ruleType);
            Map<Id, Core_MDF_Audit_Rules_Engine__c> ImdRuleRecordList = prgmBTToRulesMap.get(KeyImd);



            for(PartnerFundRequest recordObj: recordList) {
                for(Core_MDF_Audit_Rules_Engine__c imdRecord: ImdRuleRecordList.values()) {
                    system.debug('11111111');
                    if(imdRecord.Core_MDF_Program_Nm__c == recordObj.Core_MDF_Program__c){
                        system.debug('Program');
                       if(imdRecord.Core_MDF_Budget_Type_Nm__c.contains(recordObj.Core_MDF_Budget_Type_nm__c)){
                        system.debug('Budget');
                           if(imdRecord.Core_MDF_Region_Cd__c != 'WW' ){
                              if(imdRecord.Core_MDF_Region_Cd__c.contains(recordObj.Core_MDF_Region_nm__c)){
                                system.debug('Imd -----');
                               }
                           }else{
                            system.debug('Not--- WW -----');
                           }
                       }
                    }
                }
            }






            // for(sObject recordObj: recordList) {
            //     rulesToBeExecuted = prgmBTToRulesMap.get(recordObj.get('Core_MDF_Program__c') + ''+ recordObj.get('Core_MDF_Budget_Type_Nm__c'));
            //     if(rulesToBeExecuted!=null && !rulesToBeExecuted.isEmpty()){
            //         for(Core_MDF_Audit_Rules_Engine__c rule: rulesToBeExecuted) {
            //             if(rule.Core_MDF_Immediate_Ind__c==yes) {
            //                 system.debug('rule'+ rule.Core_MDF_Region_Cd__c);
            //                 if(rule.Core_MDF_Region_Cd__c == 'WW'){
                                
            //                   //  result = runRules(recordObj,rule);
            //                     system.debug('rule2'+result );
                                                              
            //                     break;
            //                 }
            //                 else if(rule.Core_MDF_Region_Cd__c == recordObj.get('Core_MDF_Region_Cd__c')){
            //                  //   result = runRules(recordObj,rule);
            //                     break;
            //                 }  
            //             }
            //         }
            //     }
                
            //     system.debug('result' +result);
            // }   
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
    /*
    public static void matchActivityAgainstRules(List<PartnerFundRequest> activityRecords, Map<string, List<Core_MDF_Audit_Rules_Engine__c>> prgmBTToRulesMap,Boolean isAfter) {
        List<Core_MDF_Audit_Rules_Engine__c> rulesToBeExecuted = new List<Core_MDF_Audit_Rules_Engine__c>();
         List<Id> instancrNotExists = new List<Id>();
        Map<id,string> result = new Map<id,string>();
        string yes='Yes';
        try{
              instancrNotExists = Core_MDF_ProcessCCP_PartnerFundRequest.isProcessInstanceExist(activityRecords);
            for(PartnerFundRequest actvtyRecord: activityRecords) {
                   system.debug('rulealo');
                rulesToBeExecuted = prgmBTToRulesMap.get(actvtyRecord.Core_MDF_Program__c + actvtyRecord.Core_MDF_Budget_Type_Nm__c);
                if(rulesToBeExecuted!=null && !rulesToBeExecuted.isEmpty()){
                    for(Core_MDF_Audit_Rules_Engine__c rule: rulesToBeExecuted) {
                        if(rule.Core_MDF_Immediate_Ind__c==yes) {
                            system.debug('rule'+ rule.Core_MDF_Region_Cd__c);
                            if(rule.Core_MDF_Region_Cd__c == 'WW'){
                                
                                result = runRules(actvtyRecord,rule);
                                system.debug('rule2'+result );
                                List<string> resultString = result.get(actvtyRecord.Id).split(';');
                                system.debug('rule3'+resultString[4] );
                            //resultMap.put(acttRec.Id,result + ';' + 'Activity Rule' + ';' + rule.Name + ';' + rule.Core_MDF_Rule_Type_Nm__c+ ';' +rule.Core_MDF_Process_Name__c+ ';' +result+';' + rule.Id + ';'+rule.Core_MDF_Action_on_True__c);
								   boolean actn =  Boolean.valueOf(resultString[5]);
                             System.debug('trrr'+!instancrNotExists.contains(actvtyRecord.Id));
                               
                                if(isAfter !=true){
                                    actvtyRecord.Core_MDF_Rule_Engine_txt__c =  resultString[7];
                                   actvtyRecord.Core_MDF_Rule_Engine_Process_Name__c = resultString[4];
                                }
                                break;
                            }
                            else if(rule.Core_MDF_Region_Cd__c == actvtyRecord.Core_MDF_Region_Cd__c){
                                result = runRules(actvtyRecord,rule,isAfter);
                                break;
                            }  
                        }
                    }
                }
                
                system.debug('result' +result);
            }      
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }*/
    
 /*   public static Map<id,string> executeActProcessRule(sObject acttRec, Core_MDF_Audit_Rules_Engine__c rule) {
        Map<id,string> resultMap = new Map<id,string>();
        boolean result = false;
        string fieldType = Core_MDF_Reusable_Code.getDataTypeOfField(rule.Core_MDF_Object_Nm__c,rule.Core_MDF_Field_Nm__c);
        try{
            Core_MDF_Reusable_Code.ValidateRuleParams inputRecord = new Core_MDF_Reusable_Code.ValidateRuleParams();
            inputRecord.recValue = string.valueof(acttRec.get(rule.Core_MDF_Field_Nm__c));
            inputRecord.crtValue = rule.Core_MDF_Value_Txt__c;
            inputRecord.operator = rule.Core_MDF_Operator_Nm__c;
            inputRecord.fieldType = fieldType;
            result = Core_MDF_Reusable_Code.validateRule(inputRecord);
          /*  if(isAfter ==false && result == true ){
                acttRec.Core_MDF_Rule_Engine_txt__c = rule.Core_MDF_Action_on_True__c;
                acttRec.Core_MDF_Rules_Engine__c    =   rule.Id;
            }*/
          /* if(result == true  && isAfter ==true && (rule.Core_MDF_Process_Name__c != null && rule.Core_MDF_Process_Name__c != '')){
                Core_MDF_PFR_Rules_Processing.callPFRApproval(acttRec,rule.Core_MDF_Process_Name__c);
              
           } 
            resultMap.put(acttRec.Id,result + ';' + 'Activity Rule' + ';' + rule.Name + ';' + rule.Core_MDF_Rule_Type_Nm__c+ ';' +rule.Core_MDF_Process_Name__c+ ';' +result+';' + rule.Id + ';'+rule.Core_MDF_Action_on_True_Ind__c);
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return resultMap;
    }
    
    
    /* Match each Claim/Claim Pred record against the corresponding Rules
    public static Map<id,string> runRules(sObject recordObj, Core_MDF_Audit_Rules_Engine__c rule) {       
        boolean result =false; 
        boolean regionCheck = false;
        Map<id,string> resultMap = new Map<id,string>();
        DateTime actCreatedDate = (DateTime) recordObj.get('Core_MDF_Start_Date__c');
        try{
            //DE119538: The CCF1.0/DCF1.0 claims remain in submitted status if audit rules are made for different region
            system.debug('rule - name'+ rule.Name);
            
            if(rule.Core_MDF_Effective_Dt__c <= actCreatedDate.date()) {
                switch on rule.Core_MDF_Object_Nm__c {
                    when 'PartnerFundRequest'{
                        System.debug('tt'+rule.Name);
                        resultMap = executeActProcessRule(recordObj,rule); 
                    }
                }
            } 
            
            if(!resultMap.isEmpty()) {
                List<string> resultString = resultMap.get(recordObj.Id).split(';');
                result = Boolean.valueOf(resultString[0]);}
            //DE119936: Devint3 | The CCF1.0/DCF1.0 claims are getting selected for audit even by Immediate rules even if the rule is not active
            if(result) {
                if(rule.Core_MDF_Next_Rule_Id__c!=null && AUDIT_RULES_MAP.containsKey(rule.Core_MDF_Next_Rule_Id__c)) {
                    resultMap = runRules(recordObj, AUDIT_RULES_MAP.get(rule.Core_MDF_Next_Rule_Id__c));
                }
            }
            else {
                if(rule.Core_MDF_Next_Rule_False_Id__c!=null && AUDIT_RULES_MAP.containsKey(rule.Core_MDF_Next_Rule_False_Id__c)) {
                    resultMap = runRules(recordObj, AUDIT_RULES_MAP.get(rule.Core_MDF_Next_Rule_False_Id__c));
                }
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        
        return resultMap;
    }*/
  
    
}