/** Class for executing the New Prection Rules using Einstein Score
*  Enabled for CCF, DCF Claims - WW34 2021
*/
public without sharing class Core_MDF_Audit_Rules_Processing {
    
    /* Constant that would store the Audit Rules required to be executed */
    public static final Map<id,Core_MDF_Audit_Rules_Engine__c> AUDIT_RULES_MAP = new Map<id,Core_MDF_Audit_Rules_Engine__c>();
    /* Constant that would contain the Claims that need to be processed */
    public static final Map<id,PartnerFundClaim> CLAIM_MAP= new Map<id,PartnerFundClaim>();
    /* Constant that would contain the Claim Prediction records that need to be processed */
    public static final Map<id,Core_MDF_Claim_Prediction__c> CLAIMPRED_MAP= new Map<id,Core_MDF_Claim_Prediction__c>();
    /* Constant that would contain the Activities that need to be processed */
    public static final Map<id,PartnerFundRequest> ACT_MAP= new Map<id,PartnerFundRequest>();
    
    /*  Get the Program of the incoming Claim list
		Get the rules corresponding to the Program
		Execute the rules against the Claims and determine if needed to be picked up by Audit*/
    public static void executePredictionFlow(List<Core_MDF_Claim_Prediction__c> claimPredRecords) {
        try{
            Map<string, List<Core_MDF_Audit_Rules_Engine__c>> programToRules = Core_MDF_Audit_Rules_Processing.getAuditRulesRecords(claimPredRecords);
            Core_MDF_Audit_Rules_Processing.matchTheClaimsAgainstRules(claimPredRecords,programToRules);    
        }
        
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
    /* Method to query all the Audit rules relevant to the Program */
    public static Map<string, List<Core_MDF_Audit_Rules_Engine__c>> getAuditRulesRecords(List<Core_MDF_Claim_Prediction__c> claimRecords) {
        Map<string, List<Core_MDF_Audit_Rules_Engine__c>> prgmBTToRulesMap = new Map<string,List<Core_MDF_Audit_Rules_Engine__c>>();
        List<Core_MDF_Audit_Rules_Engine__c> rulesList;
        Set<string> fieldsList; 
        string random = 'Random';
        Map<string,set<string>> objectToFieldsMap = new Map<string,set<string>>();
        try{
            for(Core_MDF_Audit_Rules_Engine__c rules: [select Name, toLabel(Core_MDF_Program_Nm__c), Core_MDF_Budget_Type_Nm__c,Core_MDF_Region_Cd__c, Core_MDF_Object_Nm__c,Core_MDF_Field_Nm__c, Core_MDF_Operator_Nm__c,Core_MDF_Value_Txt__c,Core_MDF_Next_Rule_Id__c,Core_MDF_Immediate_Ind__c,Core_MDF_Next_Rule_False_Id__c,Core_MDF_ID_Field_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Rule_Type_Nm__c
                                                       from Core_MDF_Audit_Rules_Engine__c where Core_MDF_Active_Ind__c=true order by Core_MDF_Region_Cd__c]) {
                                                           //AND toLabel(Core_MDF_Program_Nm__c) in :program
                                                           string key = rules.Core_MDF_Program_Nm__c + rules.Core_MDF_Budget_Type_Nm__c;
                                                           rulesList = prgmBTToRulesMap.get(key) == null? new List<Core_MDF_Audit_Rules_Engine__c>() : prgmBTToRulesMap.get(key);
                                                           if(rules.Core_MDF_Object_Nm__c!=random) {
                                                               fieldsList = objectToFieldsMap.get(rules.Core_MDF_Object_Nm__c) == null? new Set<string>():objectToFieldsMap.get(rules.Core_MDF_Object_Nm__c);
                                                               fieldsList.add(rules.Core_MDF_Field_Nm__c);
                                                               objectToFieldsMap.put(rules.Core_MDF_Object_Nm__c,fieldsList);
                                                           }
                                                           rulesList.add(rules);
                                                           prgmBTToRulesMap.put(key, rulesList);
                                                           
                                                           AUDIT_RULES_MAP.put(rules.id,rules);
                                                       }
            if(objectToFieldsMap.keySet().contains('PartnerFundClaim') || objectToFieldsMap.keySet().contains('PartnerFundRequest')) {
                queryClaimFields(objectToFieldsMap, claimRecords);
            }
            
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return prgmBTToRulesMap;
    }
    /* Get all the Claim records from the Claim Prediction lookup to Claim */ 
    public static void queryClaimFields (Map<string,Set<string>> objectToFieldsMap, List<Core_MDF_Claim_Prediction__c> claimPredRecords) {
        
        Map<string,string> objToApiMap = new Map<string,string>();
        
        set<id> claimIds = new set<id>();
        set<id> actIds = new set<id>();

        try{
            for(Core_MDF_Claim_Prediction__c claimPred: claimPredRecords) {
                claimIds.add(claimPred.Core_MDF_Claim_id__c);
                actIds.add(claimPred.Core_MDF_Activity_ID__c);
                CLAIMPRED_MAP.put(claimPred.Core_MDF_Claim_id__c,claimPred);
            }
            
            for(string objectName: objectToFieldsMap.keyset()) {
                Set<string> fields = objectToFieldsMap.get(objectName);
                List<string> queryFieldsList = new List<string>();
                for(string field : fields) {
                    queryFieldsList.add(field);
                } 
                string result = String.join(queryFieldsList,',');
                objToApiMap.put(objectName,result);
            } 
            
                if(objectToFieldsMap.keyset().contains('PartnerFundClaim')){
                    string fields = objToApiMap.get('PartnerFundClaim');
                    string query1 = 'Select Id,RequestId,Core_MDF_Document_Hold_Ind__c,';
                    string query2= ' FROM PartnerFundClaim where id in :claimIds';
                     string finalQuery1 = query1 + String.escapeSingleQuotes(fields) + query2;
                    for(PartnerFundClaim claimRecords : Database.query(String.escapeSingleQuotes(finalQuery1))) {
                        CLAIM_MAP.put(claimRecords.id,claimRecords);
                    }
                    
                }
                else if(objectToFieldsMap.keyset().contains('PartnerFundRequest')){ 
                    string fields = objToApiMap.get('PartnerFundRequest');
                    string query3 = 'Select Id,';
                    string query4= ' FROM PartnerFundRequest where id in :actIds';
		    string finalQuery = query3 + String.escapeSingleQuotes(fields) + query4;
                    for(PartnerFundRequest actRecords : Database.query(String.escapeSingleQuotes(finalQuery))) {
                        ACT_MAP.put(actRecords.id,actRecords);
                    }
                    
                                      
                }              
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }

    //checkPOPDocuments method contain query it was called inside loop so collected data in list and called method on 127 line
    //docDaysMap method is called inside updateClaimValues it was inside loop so method is called at 117 and passed in updateClaimValues parameter

    /* Validate the Claims/Claim Pred records against the corresponding rules */
    public static void matchTheClaimsAgainstRules(List<Core_MDF_Claim_Prediction__c> claimRecords, Map<string, List<Core_MDF_Audit_Rules_Engine__c>> prgmBTToRulesMap) {
        List<Core_MDF_Audit_Rules_Engine__c> rulesToBeExecuted = new List<Core_MDF_Audit_Rules_Engine__c>();
        List<Id> cmpClaimIds = new List<Id>();
        Map<id,boolean> claimPOPMap = new Map<id,boolean>();
        
        List<PartnerFundClaim> toBeUpdated = new List<PartnerFundClaim>();
        Map<id,string> result = new Map<id,string>();
        Map<string,decimal> docDaysMap = queryMetadata();
        string yes='Yes';
        try{
            for(Core_MDF_Claim_Prediction__c claimPredRecord: claimRecords) {
                if(claimPredRecord.Core_MDF_Budget_Type_Nm__c != null && Label.Core_MDF_FileUpload_BudgetTypes.contains(claimPredRecord.Core_MDF_Budget_Type_Nm__c)){
                    cmpClaimIds.add(claimPredRecord.Core_MDF_Claim_id__c);
                }
            }

            if(cmpClaimIds.size() > 0){
                claimPOPMap = checkPOPDocuments(cmpClaimIds); // why popdoc check is required
            }

            for(Core_MDF_Claim_Prediction__c claimPredRecord: claimRecords) {
                rulesToBeExecuted = prgmBTToRulesMap.get(claimPredRecord.Core_MDF_Program_Nm__c + claimPredRecord.Core_MDF_Budget_Type_Nm__c);
                result = getresult(rulesToBeExecuted, result, claimPredRecord);
                
                
                PartnerFundClaim claimRecord = new PartnerFundClaim(id =claimPredRecord.Core_MDF_Claim_id__c);
                 //DE119538: The CCF1.0/DCF1.0 claims remain in submitted status if audit rules are made for different region
                if(result.isEmpty()) {
                    List<String> resultForNoMatchingRules = new List<String>{'false'};
                    claimRecord = updateClaimValues(claimRecord, resultForNoMatchingRules, claimPOPMap,docDaysMap);
                        
                }
                else {
                    List<string> resultFromMethod = result.get(claimPredRecord.Core_MDF_Claim_id__c).split(';');
                    claimRecord = updateClaimValues(claimRecord, resultFromMethod, claimPOPMap,docDaysMap);  
                }
                toBeUpdated.add(claimRecord);
            }
            
            

           
            if(!toBeUpdated.isEmpty()) {
                Database.SaveResult[] claimsToBeUpd = Database.update(toBeUpdated,false);
            
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }

    public static  Map<id,string> getresult (List<Core_MDF_Audit_Rules_Engine__c> rulesToBeExecuted, Map<id,string> result,Core_MDF_Claim_Prediction__c claimPredRecord){
        string yes='Yes';
        if(rulesToBeExecuted!=null && !rulesToBeExecuted.isEmpty()){
            for(Core_MDF_Audit_Rules_Engine__c rule: rulesToBeExecuted) {
                if(rule.Core_MDF_Immediate_Ind__c==yes) {
                    
                    if(rule.Core_MDF_Region_Cd__c == 'WW'){
                        result = runRules(claimPredRecord,rule);
                        break;
                    }
                    else if(rule.Core_MDF_Region_Cd__c == claimPredRecord.Core_MDF_Region_Cd__c){
                        result = runRules(claimPredRecord,rule);
                        break;
                    }  
                }
            }
        }
        return result;
    }


    /* Match each Claim/Claim Pred record against the corresponding Rules */
    public static Map<id,string> runRules(Core_MDF_Claim_Prediction__c claimPredRecord, Core_MDF_Audit_Rules_Engine__c rule) {       
        //boolean result =false; 
        boolean regionCheck = false;
        Map<id,string> resultMap = new Map<id,string>();
        DateTime claimCreatedDate = claimPredRecord.Core_MDF_Claim_Created_Dt__c;
        try{
            //DE119538: The CCF1.0/DCF1.0 claims remain in submitted status if audit rules are made for different region
            
            if(rule.Core_MDF_Effective_Dt__c <= claimCreatedDate.date()) {
                switch on rule.Core_MDF_Object_Nm__c {
                    when 'Core_MDF_Claim_Prediction__c'{
                        resultMap = executePredictionRule(claimPredRecord,rule); 
                    }
                    when 'Random'{
                        resultMap = executeRandomLogic(claimPredRecord,rule);
                        
                    }
                    when else{
                          resultMap = executeThresholdRules(claimPredRecord,rule); 
                    }
                }
            } 
            
            resultMap = getResultMap(resultMap,claimPredRecord,rule);
            
        }
        catch(exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);}
        
        return resultMap;
    }


    public static Map<id,string> getResultMap(Map<id,string> resultMap,Core_MDF_Claim_Prediction__c claimPredRecord, Core_MDF_Audit_Rules_Engine__c rule) {
        boolean result =false;
        if(!resultMap.isEmpty()) {
            List<string> resultString = resultMap.get(claimPredRecord.Core_MDF_Claim_id__c).split(';');
            result = Boolean.valueOf(resultString[0]);}
        //DE119936: Devint3 | The CCF1.0/DCF1.0 claims are getting selected for audit even by Immediate rules even if the rule is not active
        if(result) {
            if(rule.Core_MDF_Next_Rule_Id__c!=null && AUDIT_RULES_MAP.containsKey(rule.Core_MDF_Next_Rule_Id__c)) {
                resultMap = runRules(claimPredRecord, AUDIT_RULES_MAP.get(rule.Core_MDF_Next_Rule_Id__c));
            }
        }
        else {
            if(rule.Core_MDF_Next_Rule_False_Id__c!=null && AUDIT_RULES_MAP.containsKey(rule.Core_MDF_Next_Rule_False_Id__c)) {
                resultMap = runRules(claimPredRecord, AUDIT_RULES_MAP.get(rule.Core_MDF_Next_Rule_False_Id__c));
            }
        }
        return resultMap;
    }
    
    /* Execute the Prediction Rule */
    public static Map<id,string> executePredictionRule(Core_MDF_Claim_Prediction__c claimPredRecord, Core_MDF_Audit_Rules_Engine__c rule) {
        Map<id,string> resultMap = new Map<id,string>();
        boolean result = false;
        string fieldType = Core_MDF_Reusable_Code.getDataTypeOfField(rule.Core_MDF_Object_Nm__c,rule.Core_MDF_Field_Nm__c);
        try{
            Core_MDF_Reusable_Code.ValidateRuleParams inputRecord = new Core_MDF_Reusable_Code.ValidateRuleParams();
            inputRecord.recValue = string.valueof(claimPredRecord.get(rule.Core_MDF_Field_Nm__c));
            inputRecord.crtValue = rule.Core_MDF_Value_Txt__c;
            inputRecord.operator = rule.Core_MDF_Operator_Nm__c;
            inputRecord.fieldType = fieldType;
            result = Core_MDF_Reusable_Code.validateRule(inputRecord);
            resultMap.put(claimPredRecord.Core_MDF_Claim_id__c,result + ';' + 'Einstein Prediction' + ';' + rule.Name + ';' + rule.Core_MDF_Rule_Type_Nm__c);
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return resultMap;
    }
    /* Execute the Threshold Rules */
    public static Map<id,string> executeThresholdRules(Core_MDF_Claim_Prediction__c claimPredRecord, Core_MDF_Audit_Rules_Engine__c rule) {
        Map<id,string> resultMap = new Map<id,string>();
        boolean result = false;
        try{
            PartnerFundClaim claimRecord = CLAIM_MAP.get(claimPredRecord.Core_MDF_Claim_id__c);
            PartnerFundRequest actRecord = ACT_MAP.get(claimPredRecord.Core_MDF_Activity_ID__c);
            string criteriaValue = rule.Core_MDF_ID_Field_Id__c == null ? rule.Core_MDF_Value_Txt__c : rule.Core_MDF_ID_Field_Id__c;
            string fieldType = Core_MDF_Reusable_Code.getDataTypeOfField(rule.Core_MDF_Object_Nm__c,rule.Core_MDF_Field_Nm__c);
            
            Core_MDF_Reusable_Code.ValidateRuleParams inputRecord = new Core_MDF_Reusable_Code.ValidateRuleParams();
            inputRecord.recValue = (rule.Core_MDF_Object_Nm__c == 'PartnerFundClaim')?string.valueof(claimRecord.get(rule.Core_MDF_Field_Nm__c)): string.valueof(actRecord.get(rule.Core_MDF_Field_Nm__c));
            inputRecord.crtValue = criteriaValue;
            inputRecord.operator = rule.Core_MDF_Operator_Nm__c;
            inputRecord.fieldType = fieldType;
            result = Core_MDF_Reusable_Code.validateRule(inputRecord);  
            resultMap.put(claimPredRecord.Core_MDF_Claim_id__c,result + ';' +'Immediate Rules' + ';' + rule.Name + ';' + rule.Core_MDF_Rule_Type_Nm__c);
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        
        return resultMap;
        
    }
    /* Execute the Random Logic */
    public static Map<id,string> executeRandomLogic(Core_MDF_Claim_Prediction__c claimPredRecord, Core_MDF_Audit_Rules_Engine__c rule) {
        Map<id,string> resultMap = new Map<id,string>();
        boolean result = false;
        try{
            integer randomNoRule = Integer.valueOf(rule.Core_MDF_Value_Txt__c.removeEnd('%'));
            decimal randomNo = Math.round(Math.random()*(100 / randomNoRule));
            result = randomNo == 1 || randomNoRule == 100? true:false;
            resultMap.put(claimPredRecord.Core_MDF_Claim_id__c,result + ';' +'Random' + ';' + rule.Name + ';' + rule.Core_MDF_Rule_Type_Nm__c);
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return resultMap; 
    }
    /* Update values on Claim depending on the Audit rules result - Audit or No Audit */
    public static PartnerFundClaim updateClaimValues(PartnerFundClaim claimRecord , List<string> result, Map<id,boolean> claimPOPMap,Map<string,decimal> docDaysMap) {
        //Map<string,decimal> docDaysMap = new Map<string,decimal>();
        try{
            Core_MDF_Claim_Prediction__c claimPred = CLAIMPRED_MAP.get(claimRecord.id);
            
            if(Boolean.valueOf(result[0])) {
                if(result[3] == 'Audit'){
                    claimRecord.Core_MDF_Audit_Hold__c = true;
                    claimRecord.Core_MDF_Audit_Type__c= result[1];              
                    claimRecord.Core_MDF_FlaggedForAudit__c = true; 
                    claimRecord.Core_MDF_Status__c = 'Hold';
                    claimRecord.Core_MDF_AuditSelectionInProgress__c = false;
                    claimRecord.Core_MDF_Review_Hold_Rule_Nm__c = result[2];
                    //US1100385: [OEM Integration] - [POP Selection] - Edit of Doc Hold Claim
                    claimRecord.Core_MDF_Doc_Hold_to_Review_Hold_Ind__c = CLAIM_MAP.get(claimRecord.id).Core_MDF_Document_Hold_Ind__c?true: false;
                    claimRecord.Core_MDF_Document_Hold_Ind__c = false; 
                }
                else if(result[3] == 'POP' && Label.Core_MDF_FileUpload_BudgetTypes.contains(claimPred.Core_MDF_Budget_Type_Nm__c)){
                    boolean popResult = claimPOPMap.get(claimRecord.id);
                    if(popResult){
                        claimRecord.Core_MDF_Audit_Hold__c = false;
                        claimRecord.Core_MDF_FlaggedForAudit__c = false; 
                        claimRecord.Core_MDF_AuditSelectionInProgress__c = false;
                    }
                    else {
                        integer days = integer.valueOf(docDaysMap.get(claimPred.Core_MDF_Program_Nm__c + claimPred.Core_MDF_Budget_Type_Nm__c));
                        claimRecord.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c = claimPred.Core_MDF_Claim_Created_Dt__c.addDays(days);
                        claimRecord.Core_MDF_Status__c = 'Hold';
                        claimRecord.Core_MDF_AuditSelectionInProgress__c = false;
                        claimRecord.Core_MDF_Review_Hold_Rule_Nm__c = result[2];
                        claimRecord.Core_MDF_Document_Hold_Eligibility_Ind__c = true;
                        claimRecord.Core_MDF_Document_Hold_Ind__c = true; 
                    }
                    
                }
            }
            else {
                claimRecord.Core_MDF_Audit_Hold__c = false;
                claimRecord.Core_MDF_FlaggedForAudit__c = false; 
                claimRecord.Core_MDF_AuditSelectionInProgress__c = false;
            }   
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return claimRecord;
    }
    
    /* Check if POP are uploaded */
    public static Map<id,boolean> checkPOPDocuments(List<id> claimIds){
        Map<id,boolean> result = new Map<id,boolean>();
        Map<id,string> claimToDocsMap = new Map<id,string>();
        try{
            for(id claimID: claimIds){
                result.put(claimID,false);    
            }
            
            for(Core_MDF_Audit_Document__c auditDoc :[SELECT Id,Core_MDF_Claim__c,Core_MDF_App_Document_Types_nm__c,Core_MDF_Document_Types__c
                                                      FROM Core_MDF_Audit_Document__c WHERE Core_MDF_Claim__c in :claimIds ORDER By Core_MDF_Claim__c]) {
                                                          //DE123130: CCF (OEM CMP) & DCF Opal Claims (both Service Provider & OEM CMP) are going in Document hold when individual documents are submitted for each POP type                       
                                                          if(claimToDocsMap.containsKey(auditDoc.Core_MDF_Claim__c)){
                                                              string existingDocs = claimToDocsMap.get(auditDoc.Core_MDF_Claim__c);
                                                              claimToDocsMap.put(auditDoc.Core_MDF_Claim__c, existingDocs + ';' + auditDoc.Core_MDF_Document_Types__c);
                                                          }
                                                          else{
                                                              string docDetails = auditDoc.Core_MDF_App_Document_Types_nm__c + '-' + auditDoc.Core_MDF_Document_Types__c;
                                                              claimToDocsMap.put(auditDoc.Core_MDF_Claim__c, docDetails);
                                                          }
                                                      }
        
            for(id claimId: claimToDocsMap.keySet()) {
                List<string> docs = claimToDocsMap.get(claimId).split('-');
                List<string> appDocs = docs[0].split(';'); 
                string availDocs = docs[1];
                for(string aDocs: appDocs) {
                    if(availDocs.contains(aDocs)) {
                        result.put(claimId,true);
                    }
                    else {
                        result.put(claimId,false);
                        break;
                    }
                }
            }
               
        }
        catch(exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);}
        return result;
    }
    
    /* Query Metadata for Document Submission Due Date */
    public static Map<string,decimal> queryMetadata(){
        Map<string,decimal> progBudgetToDocDays = new Map<string,decimal>();
        List<string> oemBudgetTypes = Label.Core_MDF_FileUpload_BudgetTypes.split(';');
        
        List<Core_MDF_CCP_Submission_Window__mdt> mdtList = [select Core_MDF_Doc_Submission_Window_Claim_Nbr__c,Core_MDF_Program__c,Core_MDF_Budget_Type__c from Core_MDF_CCP_Submission_Window__mdt where 
        Core_MDF_Budget_Type__c in :oemBudgetTypes];
        
        try{
            for(Core_MDF_CCP_Submission_Window__mdt record: mdtList){
                                                                 progBudgetToDocDays.put(record.Core_MDF_Program__c + record.Core_MDF_Budget_Type__c, record.Core_MDF_Doc_Submission_Window_Claim_Nbr__c);
                                                             }
            
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return progBudgetToDocDays;
    }
}