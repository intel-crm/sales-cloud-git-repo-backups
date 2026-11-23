public class Core_MDF_Rules_Engine_Dummy {
    public static final Map<id,Core_MDF_Audit_Rules_Engine__c> GENERIC_RULES_MAP = new Map<id,Core_MDF_Audit_Rules_Engine__c>();
     public static final Map<id,PartnerFundClaim> claimMAP= new Map<id,PartnerFundClaim>();
     public static final Map<id,PartnerFundRequest> ACT_MAP= new Map<id,PartnerFundRequest>();
     public static final Map<id,Core_MDF_Claim_Prediction__c> claimPred_MAP= new Map<id,Core_MDF_Claim_Prediction__c>();
     public static final Map<string, List<Core_MDF_Audit_Rules_Engine__c>> RuleprgmBTToRulesMap = new Map<string,List<Core_MDF_Audit_Rules_Engine__c>>();
     public static final Map<string,Map<string,set<string>>> RuletyptoFieldMap = new Map <string,Map<string,set<string>>>();
     public static final List<Core_MDF_Claim_Prediction__c> claimPredRecords = new List<Core_MDF_Claim_Prediction__c>() ;
     public static final set<id> claimIds = new set<id>();
     public static final set<id> actIds = new set<id>();
    

    //Generic method to be called by other team members
     public static Map<string,Map<Id,RulesEngineParams>> genericEngineFlow(Map<string,set<Id>> input) {
        Map<string,Map<Id,RulesEngineParams>> result = new Map<string,Map<Id,RulesEngineParams>>();
        Map<string, List<Core_MDF_Audit_Rules_Engine__c>> getAuditRulesRecordsres = new Map<string, List<Core_MDF_Audit_Rules_Engine__c>>();
        List<SObject> queryObjectFieldsres = new List<SObject>();
        try{
              getAuditRulesRecordsres = getAuditRulesRecords(input);
              result=matchTheClaimsAgainstRulesafterinsert(input,getAuditRulesRecordsres);
              system.debug('line 23'+result);
            
        	}catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return result;
    }
     public static Map<string, List<Core_MDF_Audit_Rules_Engine__c>> getAuditRulesRecords(Map<string,set<Id>> input){//Get all the Audit rules based on Rule Type
        Map<string, List<Core_MDF_Audit_Rules_Engine__c>> RuleprgmBTToRulesMap = new Map<string,List<Core_MDF_Audit_Rules_Engine__c>>();
        Map <string,Map<string,set<string>>> RuletyptoFieldMap = new Map <string,Map<string,set<string>>>();
        List<Core_MDF_Audit_Rules_Engine__c> rulesList;
    
        Map<string,set<string>> ObjectList;
        
        Set<string> fieldsList;
        List<String> btList = new List<String>(); 
        List<String> btypearray = new List<String>();
        string random = 'Random';
        string key;
        Map<string,set<string>> objectToFieldsMap = new Map<string,set<string>>();
        try{
            for(Core_MDF_Audit_Rules_Engine__c rules: [select Name, toLabel(Core_MDF_Program_Nm__c),Core_MDF_Budget_Type_Multi_Nm__c,Core_MDF_Region_Cd__c, Core_MDF_Object_Nm__c,Core_MDF_Field_Nm__c, Core_MDF_Operator_Nm__c,Core_MDF_Value_Txt__c,Core_MDF_Next_Rule_Id__c,Core_MDF_Immediate_Ind__c,Core_MDF_Next_Rule_False_Id__c,Core_MDF_ID_Field_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Rule_Type_Nm__c
                                                       from Core_MDF_Audit_Rules_Engine__c where Core_MDF_Active_Ind__c=true order by Core_MDF_Rule_Type_Nm__c]) {
                                                       
                                                           if(rules.Core_MDF_Budget_Type_Multi_Nm__c !=null)
                                                           {
                                                           if(rules.Core_MDF_Budget_Type_Multi_Nm__c!=null && rules.Core_MDF_Budget_Type_Multi_Nm__c.contains(';') ){
                                                               btypearray = rules.Core_MDF_Budget_Type_Multi_Nm__c.split(';');
                                                           }
                                                           else{
                                                                string budg =rules.Core_MDF_Budget_Type_Multi_Nm__c;
                                                           }
                                                               for (string btyp : rules.Core_MDF_Budget_Type_Multi_Nm__c.split(';'))
                                                               { 
                                                          		 key = rules.Core_MDF_Rule_Type_Nm__c + rules.Core_MDF_Program_Nm__c + btyp;
                                                               }
                                                                rulesList = RuleprgmBTToRulesMap.get(key) == null? new List<Core_MDF_Audit_Rules_Engine__c>() : RuleprgmBTToRulesMap.get(key);
                                                       				if(rules.Core_MDF_Object_Nm__c!=random && rules.Core_MDF_Rule_Type_Nm__c!=null) {
                                                               		fieldsList = objectToFieldsMap.get(rules.Core_MDF_Object_Nm__c) == null? new Set<string>():objectToFieldsMap.get(rules.Core_MDF_Object_Nm__c);
                                                               		fieldsList.add(rules.Core_MDF_Field_Nm__c);
                                                              		ObjectToFieldsMap.put(rules.Core_MDF_Object_Nm__c,fieldsList);
                                           					   		RuletyptoFieldMap.put(rules.Core_MDF_Rule_Type_Nm__c,ObjectToFieldsMap);
                                                       				}
                                                     
                                                       			rulesList.add(rules);                       
                                                       			RuleprgmBTToRulesMap.put(key, rulesList);
                                                       			GENERIC_RULES_MAP.put(rules.id,rules);
                                                       			
                                                           }
                                                       }
                                                       
       system.debug('line 67'+RuleprgmBTToRulesMap.keyset()); 
              
        queryObjectFields(RuletyptoFieldMap,input);
       
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return RuleprgmBTToRulesMap;
         
       
    }
    
   
    //Query based on each Rule type for the fields returned from the object Map<string,List<Id>> input
   public static void queryObjectFields (Map<string,Map<string,set<string>>> RuletyptoFieldMap,Map<string,set<Id>> input) {
       Map<string,string> objToApiMap = new Map<string,string>();
       set<id> claimIds = new set<id>();
       set<id> inputIdSet = new set<id>();
       Set<Id> inpid = new set<id>();
       Set<Id> actinputid = new set<id>();
       boolean var=false;
       try{
       for(string rule_type_nm: RuletyptoFieldMap.keyset())
       {
             Map<string,set<string>>objtofields = new Map<string,set<string>>();
             objtofields = RuletyptoFieldMap.get(rule_type_nm);
           	 for(String InputId: input.keyset()) {
                 String inpruletyp = InputId;
                 inpid = input.get(InputId);
                 for(id singleinpid : inpid)
                 {
                     actinputid.add(singleinpid);
                 }
                 
          	}	
           system.debug('line 94'+actinputid);
       		 for(string objectName: objtofields.keyset()) {
                Set<string> fields = objtofields.get(objectName);
                List<string> queryFieldsList = new List<string>();
                for(string field : fields) {
                    queryFieldsList.add(field);
                } 
                string result = String.join(queryFieldsList,',');
                objToApiMap.put(objectName,result); //objectnm+Fieldscommasep
       } 
       }
       
       for(string obj: objToApiMap.keyset())
       {
            system.debug('objToApiMap.keyset()'+objToApiMap.keyset());
       		string fields = objToApiMap.get(obj);
            if(obj=='PartnerFundClaim')
            {
                system.debug('abc-first'+actinputid);
      			string query1 = 'Select Id,RequestId,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Program__c,CreatedDate,Core_MDF_Region_Cd__c,';
       			string query2= ' FROM '+ obj + ' where id in :actinputid';
	          
  				for(PartnerFundClaim claimRecords : Database.query(query1 + String.escapeSingleQuotes(fields) + query2)) {
                claimMAP.put(claimRecords.id,claimRecords);
           		actIds.add(claimRecords.RequestId);
           				
            }
       		}
       else if(obj=='PartnerFundRequest')
       {
            system.debug('abc-2nd');
            system.debug('line 118'+actIds);
       		set<id> actIdfromclaimid = new set<id>();
       		actIdfromclaimid = actIds.isEmpty()?actinputid:actIds;
           // actIdfromclaimid = actIds.size()>0?inpid.add(actIds):inpid;
       		string query3 = 'Select Id,Core_MDF_Program__c,Core_MDF_Budget_Type_nm__c,CreatedDate,Core_MDF_Region_Cd__c,';
       		string query4= ' FROM '+ obj + ' where id in :actIdfromclaimid';
			for(PartnerFundRequest actRecords : Database.query(query3 + String.escapeSingleQuotes(fields) + query4)) {
            ACT_MAP.put(actRecords.id,actRecords);
            
        }
           
           
       }
       else if(obj=='Core_MDF_Claim_Prediction__c')
       {
		   system.debug('abc-3rd');
           system.debug('line 123'+inpid);
         	string query5 = 'select Core_MDF_Claim_id__r.Id,Core_MDF_Prediction_Score_Nbr__c,Core_MDF_Prediction_Score_PB__c from Core_MDF_Claim_Prediction__c where Core_MDF_Claim_id__r.Id = :actinputid';
            for(Core_MDF_Claim_Prediction__c claimPredRec: Database.query(query5)){
            claimPred_MAP.put(claimPredRec.Core_MDF_Claim_id__r.Id,claimPredRec); 
            
            }
           system.debug('line 129'+claimPred_MAP);
       }
          
      }
          
     }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
      
}
    
    public static Map<string,Map<Id,RulesEngineParams>> matchTheClaimsAgainstRulesafterinsert(Map<string,Set<Id>> input,Map<string, List<Core_MDF_Audit_Rules_Engine__c>> RuleprgmBTToRulesMap) {
        List<Core_MDF_Audit_Rules_Engine__c> rulesToBeExecuted = new List<Core_MDF_Audit_Rules_Engine__c>();
        List<Id> cmpClaimIds = new List<Id>();
        PartnerfundRequest pfr;
        PartnerfundClaim pfc;
        Core_MDF_Claim_Prediction__c cp;
        Map<string,Map<Id,RulesEngineParams>> resultMap = new Map<string,Map<Id,RulesEngineParams>>();
        Map<Id,RulesEngineParams> resultMapRE = new Map<Id,RulesEngineParams>();
        Map<Id,RulesEngineParams> result = new Map<Id,RulesEngineParams> ();
        
        string yes='Yes';
        integer i=0;
        try{
                system.debug('var i'+i+'claimMap'+claimMAP);
            
                for(string RuleType : input.keyset()) 
                {
                    set<id> inpId = input.get(RuleType);
                    system.debug('For inp id'+inpId);
                    for(id sobjId :inpId)
                    {	
                        
                        system.debug('Enter here for rule type'+RuleType +'InputId'+sobjId+'var i'+i);
                        
                     	if(ACT_MAP.containsKey(sobjId)){
                   				pfr = ACT_MAP.get(sobjId);
                        		rulesToBeExecuted = RuleprgmBTToRulesMap.get(RuleType + pfr.Core_MDF_Program__c + pfr.Core_MDF_Budget_Type_Nm__c);
                            	system.debug('Enter here line pfr'+'var i'+i+'rule type'+ruleType +'InputId'+sobjId);
                        }
                        
                     	else if(claimMAP.containsKey(sobjId)){
                            	pfc = claimMAP.get(sobjId);
                            	
                            	rulesToBeExecuted = RuleprgmBTToRulesMap.get(RuleType + pfc.Core_MDF_Program__c + pfc.Core_MDF_Budget_Type_Options_Nm__c);
                          		system.debug('Enter here line pfc'+'var i'+i+'rule type'+ruleType +'InputId'+sobjId);
                            	
                        }
                     	else if(claimPred_MAP.containsKey(sobjId)){
                         		cp = claimPred_MAP.get(sobjId);
                         		rulesToBeExecuted = RuleprgmBTToRulesMap.get(RuleType + pfc.Core_MDF_Program__c + pfc.Core_MDF_Budget_Type_Options_Nm__c);
                            	system.debug('Enter here line cp'+'var i'+i+'rule type'+ruleType +'InputId'+sobjId);
                        }
                        
                    	if(rulesToBeExecuted!=null && !rulesToBeExecuted.isEmpty()){
                            system.debug('line 173'+ rulesToBeExecuted);
                    		for(Core_MDF_Audit_Rules_Engine__c rule: rulesToBeExecuted){
                              
                        		if(rule.Core_MDF_Immediate_Ind__c==yes) {
                           				system.debug('line 170');
                                        if(rule.Core_MDF_Region_Cd__c == (pfr!=null ? pfr.Core_MDF_Region_nm__c:pfc.Core_MDF_Region_Cd__c)){
                           		 		result = runRules(sobjId,rule);
                                 		resultMap.put(RuleType,result);
                            	 		break;
                            	}
                                    	else if(rule.Core_MDF_Region_Cd__c == 'WW'){
                               			result = runRules(sobjId,rule);
                               			resultMap.put(RuleType,result);
                               			break;
                            	}
                            	
                        	    }
                                else{ 
                              	RulesEngineParams REparam = new RulesEngineParams();
            					REparam.result = false;
                                REparam.additionalInfo='No immediate rules exist';
            					resultMapRE.put(sobjId,REparam);
            					resultMap.put(RuleType,resultMapRE);
                                }
                    	}
               		 }
                     else{
                         		system.debug('line 181');
                            	RulesEngineParams REparam = new RulesEngineParams();
            					REparam.result = false;
                         		REparam.additionalInfo='No rules match for the given input in the Audit rules Engine';
            					resultMapRE.put(sobjId,REparam);
            					resultMap.put(RuleType,resultMapRE);
            				
                         }
            		  i=i+1;
                     }
                }
            }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        	return resultMap;
    }
   
      /* Match each Claim/Claim Pred record against the corresponding Rules */
    public static Map<Id,RulesEngineParams> runRules(Id input, Core_MDF_Audit_Rules_Engine__c rule) {       
        boolean resultval =false; 
        boolean regionCheck = false;
        PartnerfundRequest pfr;
        PartnerfundClaim pfc;
        Map<Id,RulesEngineParams> resultMap = new Map<Id,RulesEngineParams>();
   
         try{
          			
           			if(ACT_MAP.containsKey(input)){
                        pfr = ACT_MAP.get(input);
                    }
                    else if(claimMAP.containsKey(input)){
                            pfc = claimMAP.get(input);}
                        
                     DateTime claimCreatedDate = pfr!=null ? pfr.CreatedDate:pfc.CreatedDate;
             
           		if(rule.Core_MDF_Effective_Dt__c <= claimCreatedDate.date() || rule.Core_MDF_Effective_Dt__c >= claimCreatedDate.date()) { //need to change to <=
                	
                    switch on rule.Core_MDF_Object_Nm__c {
                    
                        when 'Core_MDF_Claim_Prediction__c'{
                          resultMap = executePredictionRule(input,rule);
                    }
                    	when 'Random'{
                         resultMap = executeRandomLogic(input,rule);
                        
                    }
                    	when else{
                        resultMap = executeThresholdRules(input,rule); 
                    }
                	}
            	}
               if(!resultMap.isEmpty() && resultMap!=null) 
               {
                 
            		RulesEngineParams ruleslinedup = new RulesEngineParams();
                    
                    ruleslinedup = resultMap.get(input);
                    resultval = ruleslinedup.result;
                    if(resultval) {
                		if(rule.Core_MDF_Next_Rule_Id__c!=null && GENERIC_RULES_MAP.containsKey(rule.Core_MDF_Next_Rule_Id__c)) {
                    	resultMap = runRules(input, GENERIC_RULES_MAP.get(rule.Core_MDF_Next_Rule_Id__c));
                    	}
                    }
                    else{
                		if(rule.Core_MDF_Next_Rule_False_Id__c!=null && GENERIC_RULES_MAP.containsKey(rule.Core_MDF_Next_Rule_False_Id__c)) {
                    	resultMap = runRules(input, GENERIC_RULES_MAP.get(rule.Core_MDF_Next_Rule_False_Id__c));
               			}
            		}
            	
             }
             else{
                  		RulesEngineParams REparam = new RulesEngineParams();
            			REparam.result = false;
            			resultMap.put(input,REparam);
            	 }
               
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return resultMap;
    }
    /* Execute the Prediction Rule */
    public static Map<Id,RulesEngineParams> executePredictionRule(Id input, Core_MDF_Audit_Rules_Engine__c rule) {
        Map<Id,RulesEngineParams> resultMap = new Map<Id,RulesEngineParams>();
        Core_MDF_Audit_Rules_Engine__c ruleRecord;
        boolean result = false;
       
        try{
        
            Core_MDF_Claim_Prediction__c cprec = claimPred_MAP.get(input);
        	string fieldType = Core_MDF_Reusable_Code.getDataTypeOfField(rule.Core_MDF_Object_Nm__c,rule.Core_MDF_Field_Nm__c);
            Core_MDF_Reusable_Code.ValidateRuleParams inputRecord = new Core_MDF_Reusable_Code.ValidateRuleParams();
            inputRecord.recValue = string.valueof(cprec.get(rule.Core_MDF_Field_Nm__c));
            inputRecord.crtValue = rule.Core_MDF_Value_Txt__c;
            inputRecord.operator = rule.Core_MDF_Operator_Nm__c;
            inputRecord.fieldType = fieldType;
            result = Core_MDF_Reusable_Code.validateRule(inputRecord);
            if(result)
            {
          	ruleRecord=rule;}
            RulesEngineParams REparam = new RulesEngineParams();
            REparam.result = result;
            REparam.ruleRecord=ruleRecord;
            resultMap.put(input,REparam);
            }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return resultMap;
    }
    
    /* Execute the Random Logic */
    public static Map<Id,RulesEngineParams> executeRandomLogic(Id input, Core_MDF_Audit_Rules_Engine__c rule) {
       
        Core_MDF_Audit_Rules_Engine__c ruleRecord;
        PartnerfundRequest pfr;
        PartnerfundClaim pfc;
        Map<Id,RulesEngineParams> resultMap = new Map<Id,RulesEngineParams>();
        boolean result = false;
        try{
             
                    if(ACT_MAP.containsKey(input))
                     {
                        pfr = ACT_MAP.get(input);
                     }
            
                     else if(claimMAP.containsKey(input)){
                            pfc = claimMAP.get(input);
                     }
                   
            integer randomNoRule = Integer.valueOf(rule.Core_MDF_Value_Txt__c.removeEnd('%'));
            decimal randomNo = Math.round(Math.random()*(100 / randomNoRule));
            result = randomNo == 1 || randomNoRule == 100? true:false;
            system.debug('randomNo' +randomNo + rule.Core_MDF_Value_Txt__c.removeEnd('%'));
            if(result)
            {
             	ruleRecord=rule;
            	
            }
            RulesEngineParams REparam = new RulesEngineParams();
            REparam.result = result;
            REparam.ruleRecord=ruleRecord;
            resultMap.put(input,REparam);
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return resultMap; 
    }
    
    /* Execute the Threshold Rules */
    public static Map<Id,RulesEngineParams> executeThresholdRules(Id input, Core_MDF_Audit_Rules_Engine__c rule) {

        Core_MDF_Audit_Rules_Engine__c ruleRecord;
        PartnerfundRequest pfr;
        PartnerfundClaim pfc;
        Id genericid;
        Map<Id,RulesEngineParams> resultMap = new Map<Id,RulesEngineParams>();
        boolean result = false;
        system.debug('actIds--'+actIds);
        try{
             if(ACT_MAP.containsKey(input))
             {
                pfr = ACT_MAP.get(input);
                genericid = pfr.id;
             }
             else if(claimMAP.containsKey(input)){
             	pfc = claimMAP.get(input);
             	genericid = pfc.id;
             }
             if(pfr==null && rule.Core_MDF_Object_Nm__c == 'PartnerFundRequest')
             {
                system.debug('Enter-here at 380'+ACT_MAP);
                for(id actvityid :actIds)
                {
                        pfr = ACT_MAP.get(actvityid);
                         	
                 }
             }
        	
            string criteriaValue = rule.Core_MDF_ID_Field_Id__c == null ? rule.Core_MDF_Value_Txt__c : rule.Core_MDF_ID_Field_Id__c;
            string fieldType = Core_MDF_Reusable_Code.getDataTypeOfField(rule.Core_MDF_Object_Nm__c,rule.Core_MDF_Field_Nm__c);
            system.debug('rule.Core_MDF_Object_Nm__c'+rule.Core_MDF_Object_Nm__c+'id'+input+'name'+rule.name);
            Core_MDF_Reusable_Code.ValidateRuleParams inputRecord = new Core_MDF_Reusable_Code.ValidateRuleParams();
            inputRecord.recValue = (rule.Core_MDF_Object_Nm__c == 'PartnerFundClaim')?string.valueof(pfc.get(rule.Core_MDF_Field_Nm__c)): string.valueof(pfr.get(rule.Core_MDF_Field_Nm__c));
            inputRecord.crtValue = criteriaValue;
            inputRecord.operator = rule.Core_MDF_Operator_Nm__c;
            inputRecord.fieldType = fieldType;
            result = Core_MDF_Reusable_Code.validateRule(inputRecord);
            if(result)
            {
             	ruleRecord=rule;
            }
            RulesEngineParams REparam = new RulesEngineParams();
            REparam.result = result;
            REparam.ruleRecord=ruleRecord;
            resultMap.put(genericid,REparam);
           }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return resultMap;
        
    }
    
    
    public class RulesEngineParams {
       
        public boolean result {get;set;}
       
        public Core_MDF_Audit_Rules_Engine__c ruleRecord {get;set;}
        
        public string actionOnTrue {get;set;}
       
        public string actionOnFalse {get;set;}
        
        public string additionalInfo {get;set;}
    }

}