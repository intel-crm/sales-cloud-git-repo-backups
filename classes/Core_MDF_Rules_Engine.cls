//Core_MDF_Rules_Engine_Test
public without sharing class Core_MDF_Rules_Engine {
	public static final Map < id, Core_MDF_Audit_Rules_Engine__c > GENERIC_RULES_MAP = new Map < id, Core_MDF_Audit_Rules_Engine__c > ();
   public static final Map < id, PartnerFundClaim > claimMAP = new Map < id, PartnerFundClaim > ();
   public static final Map < id, PartnerFundRequest > ACT_MAP = new Map < id, PartnerFundRequest > ();
   public static final Map < id, Core_MDF_Claim_Prediction__c > claimPred_MAP = new Map < id, Core_MDF_Claim_Prediction__c > ();
   public static final Map < string, List < Core_MDF_Audit_Rules_Engine__c >> RuleprgmBTToRulesMap = new Map < string, List < Core_MDF_Audit_Rules_Engine__c >> ();
   public static final Map < string, Map < string, set < string >>> RuletyptoFieldMap = new Map < string, Map < string, set < string >>> ();
   public static final Map < String, RulesEngineParams > ruleEngineResultMap = new Map < String, RulesEngineParams > (); //used in runRulesBySObject method
   public static Map<string,Map<string,SObjectField>> objNameToApiNameToType = new Map<string,Map<string,SObjectField>>();
   public static final List < Core_MDF_Claim_Prediction__c > claimPredRecords = new List < Core_MDF_Claim_Prediction__c > ();
   public static final set < id > claimIds = new set < id > ();
   public static final set < id > actIds = new set < id > ();
 
 
   //Generic method to be called by other team members
   public static Map < string, Map < Id, RulesEngineParams >> genericEngineFlow(Map < string, set < Id >> input) {
	   Map < string, Map < Id, RulesEngineParams >> result = new Map < string, Map < Id, RulesEngineParams >> ();
	   Map < string, List < Core_MDF_Audit_Rules_Engine__c >> getAuditRulesRecordsres = new Map < string, List < Core_MDF_Audit_Rules_Engine__c >> ();
	   List < SObject > queryObjectFieldsres = new List < SObject > ();
	   try {
		   getAuditRulesRecordsres = getAuditRulesRecords(input);
		   result = matchTheClaimsAgainstRulesafterinsert(input, getAuditRulesRecordsres);
	   } catch (exception ex) {
		   Core_MDF_CCP_UtilityClass.logError(ex);
	   }
	   return result;
   }
   public static Map < string, List < Core_MDF_Audit_Rules_Engine__c >> getAuditRulesRecords(Map < string, set < Id >> input) { //Get all the Audit rules based on Rule Type
	 Map < string, List < Core_MDF_Audit_Rules_Engine__c >> RuleprgmBTToRulesMap = new Map < string, List < Core_MDF_Audit_Rules_Engine__c >> ();
	 Map < string, Map < string, set < string >>> RuletyptoFieldMap = new Map < string, Map < string, set < string >>> ();
	 List < Core_MDF_Audit_Rules_Engine__c > rulesList;
 
	 Map < string, set < string >> ObjectList;
 
	 Set < string > fieldsList;
	 List < String > btList = new List < String > ();
	 string random = 'Random';
	 Map < string, set < string >> objectToFieldsMap = new Map < string, set < string >> ();
 
	 try {
	   //NP - Added Core_MDF_Rule_Type_Nm__c where condition for PROD Fix
	   for (Core_MDF_Audit_Rules_Engine__c rules: [select Name, Core_MDF_Program_Nm__c, Core_MDF_Budget_Type_Multi_Nm__c, Core_MDF_Region_Cd__c, Core_MDF_Object_Nm__c, Core_MDF_Field_Nm__c, Core_MDF_Operator_Nm__c, Core_MDF_Value_Txt__c, Core_MDF_Next_Rule_Id__c, Core_MDF_Immediate_Ind__c, Core_MDF_Next_Rule_False_Id__c, Core_MDF_ID_Field_Id__c, Core_MDF_Effective_Dt__c, Core_MDF_Rule_Type_Nm__c
		   from Core_MDF_Audit_Rules_Engine__c where Core_MDF_Active_Ind__c = true and Core_MDF_Rule_Type_Nm__c in: input.keyset() order by Core_MDF_Rule_Type_Nm__c
		 ]) {
		 //NP - PROD Fix : Initializing budgetType inside the for
		 List < string > budgetTypes = new List < string > ();
		 if (rules.Core_MDF_Budget_Type_Multi_Nm__c != null && rules.Core_MDF_Budget_Type_Multi_Nm__c.contains(';')) {
		   budgetTypes = rules.Core_MDF_Budget_Type_Multi_Nm__c.split(';');
		 } else {
		   budgetTypes.add(rules.Core_MDF_Budget_Type_Multi_Nm__c);
		 }
		 for (string btyp: budgetTypes) {
		   string key = rules.Core_MDF_Rule_Type_Nm__c + rules.Core_MDF_Program_Nm__c + btyp;
		   rulesList = RuleprgmBTToRulesMap.get(key) == null ? new List < Core_MDF_Audit_Rules_Engine__c > () : RuleprgmBTToRulesMap.get(key);
		   if (rules.Core_MDF_Object_Nm__c != random && rules.Core_MDF_Rule_Type_Nm__c != null) {
			 fieldsList = objectToFieldsMap.get(rules.Core_MDF_Object_Nm__c) == null ? new Set < string > () : objectToFieldsMap.get(rules.Core_MDF_Object_Nm__c);
			 fieldsList.add(rules.Core_MDF_Field_Nm__c);
			 ObjectToFieldsMap.put(rules.Core_MDF_Object_Nm__c, fieldsList);
			 RuletyptoFieldMap.put(rules.Core_MDF_Rule_Type_Nm__c, ObjectToFieldsMap);
		   }
 
		   rulesList.add(rules);
		   RuleprgmBTToRulesMap.put(key, rulesList);
		   GENERIC_RULES_MAP.put(rules.id, rules);
 
		 }
	   }
	   queryObjectFields(RuletyptoFieldMap, input);
	 } catch (exception ex) {
	   Core_MDF_CCP_UtilityClass.logError(ex);
	 }
	 return RuleprgmBTToRulesMap;
   }


   //Query based on each Rule type for the fields returned from the object Map<string,List<Id>> input
   public static void queryObjectFields(Map < string, Map < string, set < string >>> RuletyptoFieldMap, Map < string, set < Id >> input) {
	 Map < string, string > objToApiMap = new Map < string, string > ();
	 set < id > claimIds = new set < id > ();
	 set < id > inputIdSet = new set < id > ();
	 Set < Id > inpid = new set < id > ();
	 Set < Id > actinputid = new set < id > ();
		boolean var=false;
	 try {
	   for (string rule_type_nm: RuletyptoFieldMap.keyset()) {
		 Map < string, set < string >> objtofields = new Map < string, set < string >> ();
		 objtofields = RuletyptoFieldMap.get(rule_type_nm);
		 for (String InputId: input.keyset()) {
		   String inpruletyp = InputId;
		   inpid = input.get(InputId);
		   actinputid.addAll(inpid);
		 }
		 for (string objectName: objtofields.keyset()) {
		   Set < string > fields = objtofields.get(objectName);
		   //NP - Added for PROD Fix - duplicate field selected
		   Set < string > queryFieldsList = new Set < string > ();
		   for (string field: fields) {
						 //NP - Fix for case sensitive issue
			 queryFieldsList.add(field.toLowerCase());
			 //NP - Added for PROD Fix - duplicate field selected
			 if (objectName == 'PartnerFundClaim') {
			   queryFieldsList.add('requestid');
			   queryFieldsList.add('core_mdf_budget_type_options_nm__c');
			 }
			 queryFieldsList.add('core_mdf_program__c');
			 queryFieldsList.add('createddate');
			 queryFieldsList.add('core_mdf_region_cd__c');
		   }
		   string result = String.join(new List < String > (queryFieldsList), ',');
		   objToApiMap.put(objectName, result);
		 }
	   }
 
		//for (string obj: objToApiMap.keyset()) {
		  
		  if (objToApiMap.keyset().contains('PartnerFundClaim')) {
			string obj = 'PartnerFundClaim';
			string fields = objToApiMap.get(obj);
			//NP - Added for PROD Fix - duplicate field selected
			//string query1 = 'Select Id,RequestId,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Program__c,CreatedDate,Core_MDF_Region_Cd__c,';
			string query1 = 'Select Id,';
			string query2 = ' FROM ' + obj + ' where id in :actinputid';
			string finalQuery = query1 + String.escapeSingleQuotes(fields) + query2;
			for (PartnerFundClaim claimRecords: Database.query(String.escapeSingleQuotes(finalQuery))) {
			  claimMAP.put(claimRecords.id, claimRecords);
			  actIds.add(claimRecords.RequestId);
			}
		  }
	  
	  if (objToApiMap.keyset().contains('PartnerFundRequest')) {
			string obj = 'PartnerFundRequest';
			string fields = objToApiMap.get(obj);
			set < id > actIdfromclaimid = new set < id > ();
			actIdfromclaimid = actIds.isEmpty() ? actinputid : actIds;
			//NP - Added for PROD Fix - duplicate field selected
			//string query3 = 'Select Id,Core_MDF_Program__c,CreatedDate,Core_MDF_Region_Cd__c,';
			string query3 = 'Select Id,';
			string query4 = ' FROM ' + obj + ' where id in :actIdfromclaimid';
			string finalQuery1 = query3 + String.escapeSingleQuotes(fields) + query4;
			for (PartnerFundRequest actRecords: Database.query(String.escapeSingleQuotes(finalQuery1))) {
			  ACT_MAP.put(actRecords.id, actRecords);
			}
		  }
	  
	  if (objToApiMap.keyset().contains('Core_MDF_Claim_Prediction__c')) {
		   string obj = 'Core_MDF_Claim_Prediction__c';
			string fields = objToApiMap.get(obj);
			string query5 = 'select Core_MDF_Claim_id__c,Core_MDF_New_Prediction_Score_nbr__c,Core_MDF_Prediction_Score_PB__c from Core_MDF_Claim_Prediction__c where Core_MDF_Claim_id__c  = :actinputid';
			for (Core_MDF_Claim_Prediction__c claimPredRec: Database.query(query5)) {
			  claimPred_MAP.put(claimPredRec.Core_MDF_Claim_id__c, claimPredRec);
 
			}
		  }
		//}
 
	 } catch (exception ex) {
	   Core_MDF_CCP_UtilityClass.logError(ex);
	 }
   }

   public static Map < string, Map < Id, RulesEngineParams >> matchTheClaimsAgainstRulesafterinsert(Map < string, Set < Id >> input, Map < string, List < Core_MDF_Audit_Rules_Engine__c >> RuleprgmBTToRulesMap) {
	   List < Core_MDF_Audit_Rules_Engine__c > rulesToBeExecuted = new List < Core_MDF_Audit_Rules_Engine__c > ();
	   List < Id > cmpClaimIds = new List < Id > ();
	   PartnerfundRequest pfr;
	   PartnerfundClaim pfc;
	   Core_MDF_Claim_Prediction__c cp;
	   Map < string, Map < Id, RulesEngineParams >> resultMap = new Map < string, Map < Id, RulesEngineParams >> ();
	   Map < Id, RulesEngineParams > resultMapRE = new Map < Id, RulesEngineParams > ();
	   Map < Id, RulesEngineParams > result = new Map < Id, RulesEngineParams > ();
		
	   string yes = 'Yes';
	   integer i = 0;
	   try {
		   for (string RuleType: input.keyset()) {
			   set < id > inpId = input.get(RuleType);
			   for (id sobjId: inpId) {
				   if (ACT_MAP.containsKey(sobjId)) {
					   pfr = ACT_MAP.get(sobjId);
                       String programName = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(pfr.Core_MDF_Program__c);
					   rulesToBeExecuted = RuleprgmBTToRulesMap.get(RuleType + programName + pfr.Core_MDF_Budget_Type_Nm__c);
				   } else if (claimMAP.containsKey(sobjId)) {

					   pfc = claimMAP.get(sobjId);
					  String programName = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(pfc.Core_MDF_Program__c);
					   rulesToBeExecuted = RuleprgmBTToRulesMap.get(RuleType + programName + pfc.Core_MDF_Budget_Type_Options_Nm__c);
		   } else if (claimPred_MAP.containsKey(sobjId)) {
			 cp = claimPred_MAP.get(sobjId);
			  rulesToBeExecuted = RuleprgmBTToRulesMap.get(RuleType + cp.Core_MDF_Program_Nm__c + pfc.Core_MDF_Budget_Type_Options_Nm__c);
		   }
 
		   if (rulesToBeExecuted != null && !rulesToBeExecuted.isEmpty()) {
			 for (Core_MDF_Audit_Rules_Engine__c rule: rulesToBeExecuted) {
			   if (rule.Core_MDF_Immediate_Ind__c == yes) {
				 if (rule.Core_MDF_Region_Cd__c == (pfr != null ? pfr.Core_MDF_Region_nm__c : pfc.Core_MDF_Region_Cd__c)) {
				   result = runRules(sobjId, rule);
				   break;
				 } else if (rule.Core_MDF_Region_Cd__c == 'WW') {
				   result = runRules(sobjId, rule);
				   break;
				 }
			   } else {
				 RulesEngineParams REparam = new RulesEngineParams();
				 REparam.result = false;
				 REparam.additionalInfo = 'No immediate rules exist';
				 resultMapRE.put(sobjId, REparam);
				 if (resultMap.containsKey(RuleType)) {
				   resultMap.get(RuleType).put(sobjId, REparam);
				 } else {
				   resultMap.put(RuleType, resultMapRE);
				 }
			   }
			 }
		   } else {
			 RulesEngineParams REparam = new RulesEngineParams();
			 REparam.result = false;
			 REparam.additionalInfo = 'No rules match for the given input in the Audit rules Engine';
			 resultMapRE.put(sobjId, REparam);
			 if (resultMap.containsKey(RuleType)) {
			   resultMap.get(RuleType).put(sobjId, REparam);
			 } else {
			   resultMap.put(RuleType, resultMapRE);
			 }
 
		   }
		   i = i + 1;
		   if (resultMap.containsKey(RuleType)) {
			 resultMap.get(RuleType).putall(result);
		   } else {
			 resultMap.put(RuleType, result);
		   }
		 }
 
	   }
	 } catch (exception ex) {
	   Core_MDF_CCP_UtilityClass.logError(ex);
	 }
 
	 return resultMap;
 
   }

   /* Match each Claim/Claim Pred record against the corresponding Rules */
   public static Map < Id, RulesEngineParams > runRules(Id input, Core_MDF_Audit_Rules_Engine__c rule) {
	   boolean resultval = false;
	   boolean regionCheck = false;
	   PartnerfundRequest pfr;
	   PartnerfundClaim pfc;
	   Map < Id, RulesEngineParams > resultMap = new Map < Id, RulesEngineParams > ();

	   try {
		   if (ACT_MAP.containsKey(input)) {
			   pfr = ACT_MAP.get(input);
		   } else if (claimMAP.containsKey(input)) {
			   pfc = claimMAP.get(input);
		   }

		   DateTime claimCreatedDate = pfr != null ? pfr.CreatedDate : pfc.CreatedDate;

		   if (rule.Core_MDF_Effective_Dt__c <= claimCreatedDate.date()) {

			   switch on rule.Core_MDF_Object_Nm__c {

				   when 'Core_MDF_Claim_Prediction__c' {
					   resultMap = executePredictionRule(input, rule);
				   }
				   when 'Random' {
					   resultMap = executeRandomLogic(input, rule);

				   }
				   when
				   else {
					   resultMap = executeThresholdRules(input, rule);
				   }
			   }
		   }
		   if (!resultMap.isEmpty() && resultMap != null) {

			   RulesEngineParams ruleslinedup = new RulesEngineParams();

			   ruleslinedup = resultMap.get(input);
			   resultval = ruleslinedup.result;
			   if (resultval) {
				   if (rule.Core_MDF_Next_Rule_Id__c != null && GENERIC_RULES_MAP.containsKey(rule.Core_MDF_Next_Rule_Id__c)) {
					   resultMap = runRules(input, GENERIC_RULES_MAP.get(rule.Core_MDF_Next_Rule_Id__c));
				   }
			   } else {
				   if (rule.Core_MDF_Next_Rule_False_Id__c != null && GENERIC_RULES_MAP.containsKey(rule.Core_MDF_Next_Rule_False_Id__c)) {
					   resultMap = runRules(input, GENERIC_RULES_MAP.get(rule.Core_MDF_Next_Rule_False_Id__c));
				   }
			   }

		   } else {
			   RulesEngineParams REparam = new RulesEngineParams();
			   REparam.result = false;
			   resultMap.put(input, REparam);
		   }

	   } catch (exception ex) {
		   Core_MDF_CCP_UtilityClass.logError(ex);
	   }
	   return resultMap;
   }
   /* Execute the Prediction Rule */
   public static Map < Id, RulesEngineParams > executePredictionRule(Id input, Core_MDF_Audit_Rules_Engine__c rule) {
	   Map < Id, RulesEngineParams > resultMap = new Map < Id, RulesEngineParams > ();
	   Core_MDF_Audit_Rules_Engine__c ruleRecord;
	   boolean result = false;
	   string predvalue;
	   Trigger_Execution__mdt switchOnOrOff = Trigger_Execution__mdt.getInstance('Core_MDF_Eintein_API_Call_Switch');

	   try {
		   Core_MDF_Claim_Prediction__c cprec = claimPred_MAP.get(input);
		   //TWC742-358 - Added API call to Model if prediction score is null 
		   if (switchOnOrOff.Active__c) {
			   if (string.valueof(cprec.get(rule.Core_MDF_Field_Nm__c)) == null) {
				   ConnectApi.SmartDataDiscoveryPredictInputRecords predictInput = new ConnectApi.SmartDataDiscoveryPredictInputRecords();
				   predictInput.predictionDefinition = Label.Core_MDF_Einstein_Model_ID;
				   predictInput.records = new List < Id > {
					   cprec.id
				   };
				   ConnectApi.SmartDataDiscoveryPrediction response = ConnectApi.SmartDataDiscovery.predict(predictInput);
				   ConnectApi.SmartDataDiscoveryPredictObject prediction = (ConnectApi.SmartDataDiscoveryPredictObject) response.predictions[0];
				   predvalue = string.valueof(prediction.prediction.total);
			   }
		   }
		   string fieldType = Core_MDF_Reusable_Code.getDataTypeOfField(rule.Core_MDF_Object_Nm__c, rule.Core_MDF_Field_Nm__c);
		   Core_MDF_Reusable_Code.ValidateRuleParams inputRecord = new Core_MDF_Reusable_Code.ValidateRuleParams();
		   inputRecord.recValue = string.valueof(cprec.get(rule.Core_MDF_Field_Nm__c)) == null ? predvalue : string.valueof(cprec.get(rule.Core_MDF_Field_Nm__c));
		   inputRecord.crtValue = rule.Core_MDF_Value_Txt__c;
		   inputRecord.operator = rule.Core_MDF_Operator_Nm__c;
		   inputRecord.fieldType = fieldType;
		   result = Core_MDF_Reusable_Code.validateRule(inputRecord);
		   RulesEngineParams REparam = new RulesEngineParams();
		   if (result) {
			   REparam.ruleRecord = rule;
			   REparam.additionalInfo = 'Einstein Prediction';
		   }

		   REparam.result = result;
		   resultMap.put(input, REparam);
	   } catch (exception ex) {
		   Core_MDF_CCP_UtilityClass.logError(ex);
	   }
	   return resultMap;
   }

   /* Execute the Random Logic */
   public static Map < Id, RulesEngineParams > executeRandomLogic(Id input, Core_MDF_Audit_Rules_Engine__c rule) {

	   Core_MDF_Audit_Rules_Engine__c ruleRecord;
	   PartnerfundRequest pfr;
	   PartnerfundClaim pfc;
	   Map < Id, RulesEngineParams > resultMap = new Map < Id, RulesEngineParams > ();
	   boolean result = false;
	   try {

		   if (ACT_MAP.containsKey(input)) {
			   pfr = ACT_MAP.get(input);
		   } else if (claimMAP.containsKey(input)) {
			   pfc = claimMAP.get(input);
		   }

		   integer randomNoRule = Integer.valueOf(rule.Core_MDF_Value_Txt__c.removeEnd('%'));
		   decimal randomNo = Math.round(Math.random() * (100 / randomNoRule));
		   result = randomNo == 1 || randomNoRule == 100 ? true : false;
		   RulesEngineParams REparam = new RulesEngineParams();
		   if (result) {
			   REparam.ruleRecord = rule;
			   REparam.additionalInfo = 'Random';

		   }

		   REparam.result = result;

		   resultMap.put(input, REparam);
	   } catch (exception ex) {
		   Core_MDF_CCP_UtilityClass.logError(ex);
	   }
	   return resultMap;
   }

   /* Execute the Threshold Rules */
   public static Map < Id, RulesEngineParams > executeThresholdRules(Id input, Core_MDF_Audit_Rules_Engine__c rule) {

	   Core_MDF_Audit_Rules_Engine__c ruleRecord;
	   PartnerfundRequest pfr;
	   PartnerfundClaim pfc;
	   Id genericid;
	   Map < Id, RulesEngineParams > resultMap = new Map < Id, RulesEngineParams > ();
	   boolean result = false;
	   try {
		   if (ACT_MAP.containsKey(input)) {
			   pfr = ACT_MAP.get(input);
			   genericid = pfr.id;
		   } else if (claimMAP.containsKey(input)) {
			   pfc = claimMAP.get(input);
			   genericid = pfc.id;
		   }
		   if (pfr == null && rule.Core_MDF_Object_Nm__c == 'PartnerFundRequest') {
			   for (id actvityid: actIds) {
				   pfr = ACT_MAP.get(actvityid);
			   }
		   }

		   string criteriaValue = rule.Core_MDF_ID_Field_Id__c == null ? rule.Core_MDF_Value_Txt__c : rule.Core_MDF_ID_Field_Id__c;
		   string fieldType = Core_MDF_Reusable_Code.getDataTypeOfField(rule.Core_MDF_Object_Nm__c, rule.Core_MDF_Field_Nm__c);
		   Core_MDF_Reusable_Code.ValidateRuleParams inputRecord = new Core_MDF_Reusable_Code.ValidateRuleParams();
		   inputRecord.recValue = (rule.Core_MDF_Object_Nm__c == 'PartnerFundClaim') ? string.valueof(pfc.get(rule.Core_MDF_Field_Nm__c)) : string.valueof(pfr.get(rule.Core_MDF_Field_Nm__c));
		   inputRecord.crtValue = criteriaValue;
		   inputRecord.operator = rule.Core_MDF_Operator_Nm__c;
		   inputRecord.fieldType = fieldType;
		   result = Core_MDF_Reusable_Code.validateRule(inputRecord);
		   RulesEngineParams REparam = new RulesEngineParams();
		   if (result) {
			   REparam.ruleRecord = rule;
			   REparam.additionalInfo = 'Immediate Rules';
		   }

		   REparam.result = result;
		   resultMap.put(genericid, REparam);
	   } catch (exception ex) {
		   Core_MDF_CCP_UtilityClass.logError(ex);
	   }
	   return resultMap;

   }
   public class RulesEngineParams {
 
		 public boolean result {get;set;}
		 public Core_MDF_Audit_Rules_Engine__c ruleRecord {get;set;}
		 public string actionOnTrue {get;set;}
		 public string actionOnFalse {get;set;}
		 public string additionalInfo {get;set;}
   }
   // New code starts here --- for handlng the before insert/update by passing only object list not ids
   // Input patrameter -> Map<string,List<sobject>> -- Key is Rule Type
   // Map<String,Map<String,RulesEngineParams>> -- first Map , key is Rule Type, key of the first map result is dummy ID
   public static Map < String, Map < String, RulesEngineParams >> executeRulesByObjects(Map < string, List < sobject >> inputMap) {
	   Map < string, Map < String, RulesEngineParams >> finaResult = new Map < string, Map < String, RulesEngineParams >> ();
	   Set < String > auditRuleTypeSet = new Set < String > ();
	   Set < String > objectNameSet = new Set < String > ();
	   List < sobject > sobjectList = new List < sobject > ();
	   Map < String, String > RuleTypeSobjectMap = new Map < String, String > ();
	   Map < string, Set < string >> recMap = new Map < string, Set < string >> ();
	   if (inputMap != null && inputMap.keySet() != null) {

		   auditRuleTypeSet = inputMap.keySet();
		   for (String key: inputMap.keySet()) {
			   RuleTypeSobjectMap.put(key, getObjectType(inputMap.get(key)[0]));
			   List < sobject > sObjList = new List < sobject > ();
			   objectNameSet.add(getObjectType(inputMap.get(key)[0]));
			   sobjectList.addAll(inputMap.get(key)); //incorrect code -- it is collecting all the object list
			   if (!recMap.containsKey(key)) {
				   recMap.put(key, new Set < string > ());
			   }
			   recMap.get(key).addAll(objectNameSet);
		   }
	   }
	   //get the lost of immediate rules and its dependent rules
	   Map < string, List < Core_MDF_Audit_Rules_Engine__c >> programToRules = Core_MDF_Rules_Engine.getMatchingRules(recMap.keySet(), objectNameSet);
	   //Start processing the input data
	   for (String ruleType: inputMap.keyset()) {
		   Map < String, SObject > newInputMap = new Map < String, SObject > ();
		   Map < string, Map < String, RulesEngineParams >> resultWrapper = new Map < string, Map < String, RulesEngineParams >> ();
		   for (Sobject sobj: inputmap.get(ruleType)) {
			   //Assign Dummy ID to each sboject record input
			   //added to form map with Existing Id
			   if (sobj.Id == Null) {
				   String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
				   Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
				   String hexDigest = EncodingUtil.convertToHex(hash);
				   newInputMap.put(hexDigest, sobj);
			   } else {
				   newInputMap.put(sobj.Id, sobj);
			   }
		   }
		   resultWrapper = Core_MDF_Rules_Engine.matchRecordsAgainstRules(ruleType, RuleTypeSobjectMap.get(ruleType), newInputMap, programToRules);

		   If(resultWrapper != null && resultWrapper.get(ruleType) != null) {
			   finaResult.put(ruleType, resultWrapper.get(ruleType));
		   }
	   }
	   return finaResult;
   }
   public static string getObjectType(sObject obj) {
	   string objectTypeStr;
	   Schema.sObjectType objType = obj.getSObjectType();
	   if (objType != null) {
		   objectTypeStr = String.valueOf(objType);
	   }
	   return objectTypeStr;
   }

   public static Map < string, List < Core_MDF_Audit_Rules_Engine__c >> getMatchingRules(Set < string > ruleTypes, Set < String > objectNames) {
	   Map < string, List < Core_MDF_Audit_Rules_Engine__c >> RuleprgmBTToRulesMap = new Map < string, List < Core_MDF_Audit_Rules_Engine__c >> ();
	   Map < string, Map < string, set < string >>> RuletyptoFieldMap = new Map < string, Map < string, set < string >>> ();
	   List < Core_MDF_Audit_Rules_Engine__c > rulesList;
	   List < String > btList = new List < String > ();
	   Map < string, set < string >> objectToFieldsMap = new Map < string, set < string >> ();

	   try {
		   for (Core_MDF_Audit_Rules_Engine__c rules: [select Name, Core_MDF_Program_Nm__c,
				   Core_MDF_Budget_Type_Multi_Nm__c, Core_MDF_Region_Cd__c, Core_MDF_Object_Nm__c,
				   Core_MDF_Field_Nm__c, Core_MDF_Operator_Nm__c, Core_MDF_Value_Txt__c,
				   Core_MDF_Next_Rule_Id__c, Core_MDF_Immediate_Ind__c, Core_MDF_Next_Rule_False_Id__c,
				   Core_MDF_ID_Field_Id__c, Core_MDF_Effective_Dt__c, Core_MDF_Rule_Type_Nm__c,
				   Core_MDF_Rule_Action_on_True_nm__c,
				   Core_MDF_Rule_Action_on_False_nm__c,
				   Core_MDF_Approver_Source_on_True_nm__c, Core_MDF_Approver_Source_on_False_nm__c,
				   Core_MDF_Approver_Source_Value_on_True__c, Core_MDF_Approver_Source_Value_on_False__c,
				   Core_MDF_Look_Up_Field_Ind__c, Core_MDF_Process_Name__c

				   from Core_MDF_Audit_Rules_Engine__c
				   where Core_MDF_Active_Ind__c = true
				   and Core_MDF_Rule_Type_Nm__c IN: ruleTypes and Core_MDF_Object_Nm__c In: objectNames
				   order by Core_MDF_Rule_Type_Nm__c, Name
			   ]) {
			   if (rules.Core_MDF_Immediate_Ind__c == 'Yes') {
				   List < String > budgetTypes = new List < String > ();
				   if (rules.Core_MDF_Budget_Type_Multi_Nm__c != null && rules.Core_MDF_Budget_Type_Multi_Nm__c.contains(';')) {
					   budgetTypes = rules.Core_MDF_Budget_Type_Multi_Nm__c.split(';');
				   } else {
					   budgetTypes.add(rules.Core_MDF_Budget_Type_Multi_Nm__c);
				   }
				   for (string btyp: budgetTypes) //swap with immediate rule check
				   {
					   {
						   string key = rules.Core_MDF_Rule_Type_Nm__c + rules.Core_MDF_Program_Nm__c + btyp;
						   rulesList = RuleprgmBTToRulesMap.get(key) == null ? new List < Core_MDF_Audit_Rules_Engine__c > () : RuleprgmBTToRulesMap.get(key);
						   rulesList.add(rules);
						   RuleprgmBTToRulesMap.put(key, rulesList);
					   }

				   }
			   }
			   GENERIC_RULES_MAP.put(rules.id, rules);
		   }

	   } catch (exception ex) {
		   Core_MDF_CCP_UtilityClass.logError(ex);
	   }
	   return RuleprgmBTToRulesMap;

   }
   public static Map < string, Map < String, RulesEngineParams >> matchRecordsAgainstRules(String ruleTypeName, String sObjectName, Map < String, SOBject > recordList, Map < string, List < Core_MDF_Audit_Rules_Engine__c >> RuleprgmBTToRulesMap) {
	 List < Core_MDF_Audit_Rules_Engine__c > rulesToBeExecuted = new List < Core_MDF_Audit_Rules_Engine__c > ();
	 List < Id > cmpClaimIds = new List < Id > ();
	 List < PartnerfundRequest > pfrList;
	 List < PartnerfundClaim > pfcList;
	 Core_MDF_Claim_Prediction__c cp;
	 Map < string, Map < String, RulesEngineParams >> resultMap = new Map < string, Map < String, RulesEngineParams >> ();
	 Map < String, RulesEngineParams > resultMapRE = new Map < String, RulesEngineParams > ();
	 Map < String, RulesEngineParams > result = new Map < String, RulesEngineParams > ();
	 string yes = 'Yes';
	 String ruleKey;
	 String regionCode;
	 Boolean immediateRuleExist = false;
	 try {
	   for (String genericId: recordList.keyset()) {
		 If(sObjectName == 'PartnerfundRequest') {
 
		   PartnerFundRequest pfr = (PartnerfundRequest) recordList.get(genericId);
                   String programName = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(pfr.Core_MDF_Program__c);
				   ruleKey = ruleTypeName + programName + pfr.Core_MDF_Budget_Type_Nm__c;
		   regionCode = pfr.Core_MDF_Region_nm__c;
		 }
		 else If(sObjectName == 'PartnerfundClaim') {
		   PartnerFundClaim pfc = (PartnerFundClaim) recordList.get(genericId);
				   String programName = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(pfc.Core_MDF_Program__c);
				   ruleKey = ruleTypeName + programName + pfc.Core_MDF_Budget_Type_Options_Nm__c;
				   regionCode = pfc.Core_MDF_Region_Cd__c;
			   }

			   rulesToBeExecuted = RuleprgmBTToRulesMap.get(ruleKey);
			   if (rulesToBeExecuted != null && !rulesToBeExecuted.isEmpty()) {
				   if(!objNameToApiNameToType.containsKey(sObjectName)) {
						objNameToApiNameToType = Core_MDF_Reusable_Code.getDataTypeOfFieldsMap(recordList.get(genericId));
				   }
				   //Loop through the rules which are immediate rules
				   for (Core_MDF_Audit_Rules_Engine__c rule: rulesToBeExecuted) {
					   if (rule.Core_MDF_Region_Cd__c == regionCode || rule.Core_MDF_Region_Cd__c == 'WW') {
						   result = runRulesBySObject(genericid, recordList.get(genericId), sObjectName, rule);
						   resultMap.put(ruleTypeName, result);
						   immediateRuleExist = true;
						   break; //picks the first rule that satisfies
					   }
				   }
			   }
			   If(!immediateRuleExist) {
				   RulesEngineParams REparam = new RulesEngineParams();
				   REparam.result = false;
				   REparam.additionalInfo = 'No Immediate rules match for the given input rule type:' + ruleTypeName;
				   resultMapRE.put(genericid, REparam);
				   resultMap.put(ruleTypeName, resultMapRE);
			   }
		   }
	   } catch (exception ex) {
		   Core_MDF_CCP_UtilityClass.logError(ex);
	   }
	   return resultMap;
   }

   public static Map < String, RulesEngineParams > runRulesBySObject(String genericId, SObject objRecord, String objTypeName, Core_MDF_Audit_Rules_Engine__c rule) {
	 boolean resultval = false;
	 boolean regionCheck = false;
	 boolean result = false;
	 PartnerfundRequest pfr;
	 PartnerfundClaim pfc;
	 Core_MDF_Audit_Rules_Engine__c ruleRecord;
	 try {
	   if (objTypeName == 'PartnerfundRequest') {
		 pfr = (PartnerfundRequest) objRecord;
	   } else if (objTypeName == 'PartnerfundClaim') {
		 pfc = (PartnerfundClaim) objRecord;
	   }
 
	   string criteriaValue = rule.Core_MDF_ID_Field_Id__c == null ? rule.Core_MDF_Value_Txt__c : rule.Core_MDF_ID_Field_Id__c;
	   
	   string fieldType =  (!objNameToApiNameToType.isEmpty() && objNameToApiNameToType.containsKey(rule.Core_MDF_Object_Nm__c)) ? 
	   string.valueOf(objNameToApiNameToType.get(rule.Core_MDF_Object_Nm__c).get(rule.Core_MDF_Field_Nm__c).getDescribe().getType()) : '';
 
	   Core_MDF_Reusable_Code.ValidateRuleParams inputRecord = new Core_MDF_Reusable_Code.ValidateRuleParams();
 
	   inputRecord.recValue = (rule.Core_MDF_Object_Nm__c == 'PartnerFundClaim') ? string.valueof(pfc.get(rule.Core_MDF_Field_Nm__c)) : string.valueof(pfr.get(rule.Core_MDF_Field_Nm__c));
	   inputRecord.crtValue = criteriaValue;
	   inputRecord.operator = rule.Core_MDF_Operator_Nm__c;
	   inputRecord.fieldType = fieldType;
	   result = Core_MDF_Reusable_Code.validateRule(inputRecord);
	   Id actionResult;
 
	   if (result) {
		 ruleRecord = rule;
		 actionResult = rule.Core_MDF_Next_Rule_Id__c;
	   } else {
		 ruleRecord = rule;
		 actionResult = rule.Core_MDF_Next_Rule_False_Id__c;
	   }
	   if (actionResult != null) {
		 return runRulesBySObject(genericid, objRecord, objTypeName, GENERIC_RULES_MAP.get(actionResult));
 
	   }
 
	   RulesEngineParams REparam = new RulesEngineParams();
	   REparam.result = result;
	   REparam.ruleRecord = rule;
	   REparam.actionOnTrue = rule.Core_MDF_Rule_Action_on_True_nm__c;
	   REparam.actionOnFalse = rule.Core_MDF_Rule_Action_on_False_nm__c;
	   REparam.additionalInfo = rule.Core_MDF_Process_Name__c;
	   ruleEngineResultMap.put(genericid, REparam);
	 } catch (exception ex) {
	   Core_MDF_CCP_UtilityClass.logError(ex);
	 }
	 return ruleEngineResultMap;
   }
}