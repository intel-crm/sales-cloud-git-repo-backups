/********************************************************************
* Clas Name 		: Core_MDF_CustomLayoutConfig_Controller
* Test Class Name  : Core_MDF_CustomLayoutConfig_Contrl_Test
* Description		: Config the fields on layout 
********************************************************************/
public without sharing class Core_MDF_CustomLayoutConfig_Controller {
    public static List<string> languages = (Core_MDF_CCP_ConstantClass.CCP_SUPPORTED_LOCALE).split(',');
    public static boolean notifyPartnerCheck = false;

    // ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
    // Static cache added at class level — shared across all methods
    private static Map<String, Schema.DescribeSObjectResult> describeCache = new Map<String, Schema.DescribeSObjectResult>();

    // Private helper replaces getGlobalDescribe() in all methods
    private static Schema.DescribeSObjectResult getSObjectDescribe(String objectName) {
        if (String.isBlank(objectName)) { return null; }
        String key = objectName.toLowerCase();
        if (!describeCache.containsKey(key)) {
            try {
                Schema.DescribeSObjectResult[] results = Schema.describeSObjects(new List<String>{ objectName });
                if (results != null && !results.isEmpty()) {
                    describeCache.put(key, results[0]);
                }
            } catch (Exception e) {
                Core_MDF_CCP_UtilityClass.logError(e);
            }
        }
        return describeCache.containsKey(key) ? describeCache.get(key) : null;
    }

    public class LayoutRequest {
        public String recordId;
        public String objAPIName;
        public String fieldAPIName;
        public String fieldView;
        public String fieldAPIoperator;

        public LayoutRequest(String recordId, String objAPIName, String fieldAPIName, String fieldView, String fieldAPIoperator) {
            this.recordId = recordId;
            this.objAPIName = objAPIName;
            this.fieldAPIName = fieldAPIName;
            this.fieldView = fieldView;
            this.fieldAPIoperator = fieldAPIoperator;
        }
    }

    @AuraEnabled
    public static Map<String, List<ResultWrapper>> getObjectFields(String recordId, String objAPIName, String fieldAPIName, String fieldView, String fieldAPIoperator) {
        LayoutRequest request = new LayoutRequest(recordId, objAPIName, fieldAPIName, fieldView, fieldAPIoperator);
        return getObjectFields(request);
    }

    private static Map<String, List<ResultWrapper>> getObjectFields(LayoutRequest request) {
        String recordId = request.recordId;
        String objAPIName = request.objAPIName;
        String fieldAPIName = request.fieldAPIName;
        String fieldView = request.fieldView;
        String fieldAPIoperator = request.fieldAPIoperator;

        List<ResultWrapper> resultList = new List<ResultWrapper>();
        Map<String, List<ResultWrapper>> resultMap = new Map<String, List<ResultWrapper>>();
        List<Core_MDF_Custom_Layout_Configurations__c> fieldName = new List<Core_MDF_Custom_Layout_Configurations__c>();
        String userType = UserInfo.getUserType() == 'PowerPartner' ? 'External User' : 'Internal User'; 
        system.debug('@@fieldAPIName :'+fieldAPIName);
        String fieldAPINameStr =  String.escapeSingleQuotes(fieldAPIName);
        system.debug('@@fieldAPINameStr :'+fieldAPINameStr);
    
        if(objAPIName == 'PartnerFundRequest' && !fieldAPIName.contains('Core_MDF_Is_Outcome_Based_Ind__c')){
            fieldAPINameStr  = fieldAPINameStr + ',Core_MDF_Is_Outcome_Based_Ind__c';
        }
        /*if(objAPIName == 'PartnerFundClaim'){//14820
            fieldAPINameStr  = fieldAPINameStr + ',Core_MDF_OutcomeBased_Ind__c';
        }*/
        String objAPINameStr =  String.escapeSingleQuotes(objAPIName);
        String filterCriteria;
        String query = 'SELECT '+ fieldAPINameStr + ',Core_MDF_Program__c, RecordTypeId FROM ' + objAPINameStr + ' WHERE Id=: recordId ';
        List<SObject> records = Database.query( query );
        If(records.isEmpty()){
            return resultMap;
        }

        /*if(objAPIName == 'PartnerFundRequest' && records.get(0).get('Core_MDF_Is_Outcome_Based_Ind__c') == true ){
            fieldAPINameStr = 'Core_MDF_Is_Outcome_Based_Ind__c';
        }*/

        if(objAPIName == 'PartnerFundRequest' && !fieldAPIName.contains('Core_MDF_Is_Outcome_Based_Ind__c')){
            fieldAPINameStr = (records.get(0).get('Core_MDF_Is_Outcome_Based_Ind__c') == true) ? 'Core_MDF_Is_Outcome_Based_Ind__c' : 'Core_MDF_Proposal_Based_Ind__c';
        }

        /*if(objAPIName == 'PartnerFundClaim' && records.get(0).get('Core_MDF_OutcomeBased_Ind__c') == true && records.get(0).get('Core_MDF_Proposal_Based_Ind__c') == false){//14820
            fieldAPIName = 'Core_MDF_OutcomeBased_Ind__c';
        }*/
        System.debug('@@fieldAPINameStr: '+fieldAPINameStr);
        //14820 starts
        //if(objAPIName == 'PartnerFundClaim'){
            List<String> fields = String.isBlank(fieldAPINameStr) ? new List<String>() : new List<String>(fieldAPINameStr.split(','));  
            for (Integer i = 0; i < fields.size(); i++) {
                fields[i] = fields[i].trim();
            }
            System.debug('@@fields; '+fields);
            Boolean multiple = fields.size() > 1;
            String queryOperator = multiple ? (String.isBlank(fieldAPIoperator) ? 'AND' : fieldAPIoperator.trim().toUpperCase()) : '';
            System.debug('@@queryOperator; '+queryOperator);         
            List<String> criteriaParts = new List<String>();
            for (String f : fields) {
                Object val = records.get(0).get(f);
                if (val == null) {continue;}
                if (val instanceof Id) {
                    criteriaParts.add(f + ' != null');
                } else {
                    criteriaParts.add(f + ' == ' + String.valueOf(val));
                }

                //criteriaParts.add(f + ' == ' + (val == null ? 'null' : String.valueOf(val)));
            }  
            System.debug('@@criteriaParts; '+criteriaParts);
            if (!criteriaParts.isEmpty()){
                filterCriteria = (criteriaParts.size() == 1) ? criteriaParts[0] : String.join(criteriaParts, ' ' + queryOperator + ' ');
            } 
        //}
        //14820 ends
        
        //if(objAPIName == 'PartnerFundRequest' || objAPIName == 'Campaign'){filterCriteria = fieldAPIName + ' == ' + records.get(0).get(fieldAPIName);}
        //String recordTypeName = (String)records.get(0).get('Core_MDF_Program__c');//Swati - Commented 
        String recordTypeId = (String)records.get(0).get('recordTypeId');//Swati - Added
        String recordTypeName = [SELECT Name FROM RecordType WHERE Id = :recordTypeId LIMIT 1].Name;//Swati - Added
        //String recordTypeName = (String)records.get(0).get('RecordType.Name');
        String recordQuery = 'SELECT ' ;
        Set<String> fieldSet = new Set<String>();
        System.debug('@@recordTypeName: '+recordTypeName);
        System.debug('@@filterCriteria: '+filterCriteria);
        for(Core_MDF_Custom_Layout_Configurations__c field : [SELECT id, Core_MDF_Field_Label_txt__c, Core_MDF_Field_API_Name_txt__c,
                                                              Core_MDF_Budget_Type_nm__c, Core_MDF_Record_Type_Name_txt__c, Core_MDF_Object_API_Name_txt__c, Core_MDF_Alignment_nm__c, 
                                                              Core_MDF_Display_Custom_Label_Ind__c, Core_MDF_zh_CN_cd__c, Core_MDF_zh_TW_cd__c, 
                                                              Core_MDF_fr_cd__c, Core_MDF_de_cd__c, Core_MDF_Sequence_No_nbr__c, Core_MDF_it_cd__c, Core_MDF_ja_cd__c, Core_MDF_ko_cd__c, 
                                                              Core_MDF_pt_BR_cd__c, Core_MDF_ru_cd__c, Core_MDF_es_MX_cd__c, Core_MDF_es_cd__c, Core_MDF_Section_id__r.Core_MDF_Section_Name_txt__c,
                                                              Core_MDF_Section_id__r.Core_MDF_No_Of_Columns_nm__c, Core_MDF_Section_id__r.Core_MDF_zh_CN_cd__c, Core_MDF_Section_id__r.Core_MDF_zh_TW_cd__c,
                                                              Core_MDF_Section_id__r.Core_MDF_fr_cd__c, Core_MDF_Section_id__r.Core_MDF_de_cd__c, 
                                                              Core_MDF_Section_id__r.Core_MDF_it_cd__c, Core_MDF_Section_id__r.Core_MDF_ja_cd__c, Core_MDF_Section_id__r.Core_MDF_ko_cd__c, 
                                                              Core_MDF_Section_id__r.Core_MDF_pt_BR_cd__c, Core_MDF_Section_id__r.Core_MDF_ru_cd__c,Core_MDF_Is_Relationship_Ind__c,
                                                              Core_MDF_Section_id__r.Core_MDF_es_MX_cd__c, Core_MDF_Section_id__r.Core_MDF_es_cd__c, Core_MDF_Record_Name_nm__c, Core_MDF_Is_Lookup_Ind__c,
                                                              Core_MDF_Hide_If_No_Value_Ind__c,Core_MDF_Hidden_Ind__c,Core_MDF_Section_id__r.Core_MDF_Hide_If_No_Value_Ind__c,Core_MDF_Parent_Object_nm__c,Core_MDF_RichText_Ind__c,
                                                              Core_MDF_Lookup_Custom_URL_Ind__c,Core_MDF_Lookup_Custom_URL_Link_txt__c
                                                              FROM Core_MDF_Custom_Layout_Configurations__c 
                                                              WHERE Core_MDF_Object_API_Name_txt__c = :objAPIName 
                                                              AND Core_MDF_Active_Ind__c = True
                                                              AND Core_MDF_Record_Type_Name_txt__c = :recordTypeName
                                                              AND Core_MDF_Filter_Criteria_txt__c = :filterCriteria
                                                              AND Core_MDF_User_Type_nm__c = :userType
                                                              AND Core_MDF_Section_id__r.Core_MDF_Object_Name_txt__c = :objAPIName
                                                              AND Core_MDF_Section_id__r.Core_MDF_Field_View_nm__c = :fieldView
                                                              ORDER BY Core_MDF_Section_id__r.Core_MDF_Sequence_No_nbr__c,Core_MDF_Sequence_No_nbr__c ASC]) {
                               
                                                                  if(field.Core_MDF_Is_Relationship_Ind__c == true && field.Core_MDF_Record_Name_nm__c != null){
                                                                      //recordQuery += field.Core_MDF_Record_Name_nm__c + ','  ;
                                                                      fieldSet.add(field.Core_MDF_Record_Name_nm__c);
                                                                  } else {
                                                                      //recordQuery += field.Core_MDF_Field_API_Name_txt__c + ','  ;
                                                                      //block duplicate fields - check if its a exact match or partial match
                                                                      //add all the values to a set with no dulicates and then use it in query
                                                                      fieldSet.add(field.Core_MDF_Field_API_Name_txt__c);
                                                                  }
                                                                  fieldName.add(field);
                                                                  
                                                                  If(field.Core_MDF_Is_Lookup_Ind__c == true && field.Core_MDF_Record_Name_nm__c != null){
                                                                      fieldSet.add(field.Core_MDF_Record_Name_nm__c);
                                                                      //recordQuery += field.Core_MDF_Record_Name_nm__c + ',' ;
                                                                  }                                                    
                                                              }
        if(fieldSet != null && fieldSet.size() > 0) {
            for(String fld: fieldSet) {
                recordQuery += fld + ',';
            }
        } 
        recordQuery = recordQuery.removeEnd(',');
        recordQuery += ' FROM ' +
            objAPINameStr +
            ' WHERE Id=: recordId';
        if(fieldName.isEmpty()){
            resultMap.put(userType, new List<ResultWrapper>());
            return resultMap;
        } else {
            List<SObject> getRecords = Database.query( recordQuery );
            String userLang = UserInfo.getLanguage();
            // ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
            Schema.DescribeSObjectResult objectDescribe = getSObjectDescribe(objAPIName);
            for(Integer j=0; j < fieldName.size(); j++){
                // ATHR Fix: Null check on fields.getMap().get() return value
                SObjectField fieldToken = objectDescribe.fields.getMap().get(fieldName[j].Core_MDF_Field_API_Name_txt__c);
                if(fieldToken == null) { continue; }
                Schema.DescribeFieldResult fieldDescribe = fieldToken.getDescribe();
                if(fieldDescribe.isAccessible() == true){ 
                	resultList.add(getLayoutDetails(fieldName[j], getRecords, fieldDescribe, userLang));      
                }
            }
            resultMap.put(userType, resultList);
        }
        try {
            Integer cpuTimeUsed = Limits.getCpuTime();
            System.debug('CPU time used 2' + cpuTimeUsed + ' milliseconds');
            return resultMap;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }
    
    @AuraEnabled
    public static Map<String, List<ButtonDetailsWrapper>> getObjActions(String recordId, String objAPIName, String fieldAPIName, String fieldView, String fieldAPIoperator) {
        LayoutRequest request = new LayoutRequest(recordId, objAPIName, fieldAPIName, fieldView, fieldAPIoperator);
        return getObjActions(request);
    }

    private static Map<String, List<ButtonDetailsWrapper>> getObjActions(LayoutRequest request) {
        String recordId = request.recordId;
        String objAPIName = request.objAPIName;
        String fieldAPIName = request.fieldAPIName;
        String fieldView = request.fieldView;
        String fieldAPIoperator = request.fieldAPIoperator;

        Map<String, List<ButtonDetailsWrapper>> resultMap = new Map<String, List<ButtonDetailsWrapper>>();
        List<ButtonDetailsWrapper> buttonDetailsList = new List<ButtonDetailsWrapper>();
        Map<String, String> buttonsMap = new Map<String, String>();
        String objAPINameStr =  String.escapeSingleQuotes(objAPIName);
        String fieldAPINameStr =  String.escapeSingleQuotes(fieldAPIName);

        String objectName = objAPIName.endsWith('__c') ? objAPIName.substring(0, objAPIName.length() - 3) : String.valueOf(objAPIName);
        List<Core_MDF_Custom_Layout_Configration__mdt> metaDataRecords = [Select label, Core_MDF_Field_API_Name__c, 
                                                                          Core_MDF_Record_Status_txt__c, Core_MDF_Tab_Icons_Details_txt__c, 
                                                                          Core_MDF_Buttons_Config_Details_txt__c 
                                                                          From Core_MDF_Custom_Layout_Configration__mdt 
                                                                          where DeveloperName= :objectName];
        if(!metaDataRecords.isEmpty() && metaDataRecords.size()>0){
            String fldName = String.valueOf(metaDataRecords.get(0).get('Core_MDF_Field_API_Name__c'));
            String recordStatus = String.valueOf(metaDataRecords.get(0).get('Core_MDF_Record_Status_txt__c'));
            String tabIcon = String.valueOf(metaDataRecords.get(0).get('Core_MDF_Tab_Icons_Details_txt__c')) != '' ? String.valueOf(metaDataRecords.get(0).get('Core_MDF_Tab_Icons_Details_txt__c')) : '';
            
            
		String query = 'SELECT '+
            String.escapeSingleQuotes(fldName) + ', ' +
            String.escapeSingleQuotes(recordStatus) + ',' +
            fieldAPINameStr +
            ', Core_MDF_Program__c FROM ' + 
            objAPINameStr +
            ' WHERE Id=: recordId ';
        
        
        List<SObject> records = Database.query( query );
            if(records == null || records.isEmpty()){ // Indira
                return resultMap;      
            }
        String filterCriteria;
        List<String> fields = String.isBlank(fieldAPINameStr) ? new List<String>() : new List<String>(fieldAPINameStr.split(','));  
            for (Integer i = 0; i < fields.size(); i++) {
                fields[i] = fields[i].trim();
            }
            Boolean multiple = fields.size() > 1;
            String queryOperator = multiple ? (String.isBlank(fieldAPIoperator) ? 'AND' : fieldAPIoperator.trim().toUpperCase()) : '';
            List<String> criteriaParts = new List<String>();
            for (String f : fields) {
                if (String.isBlank(f)) {continue;}
                Object val = records[0].get(f);
                if (val == null) {continue;}
                if (val instanceof Id) {
                    criteriaParts.add(f + ' != null');
                } else {
                    criteriaParts.add(f + ' == ' + String.valueOf(val));
                }

                //criteriaParts.add(f + ' == ' + (val == null ? 'null' : String.valueOf(val)));
            }  
            if (!criteriaParts.isEmpty()){
                filterCriteria = (criteriaParts.size() == 1) ? criteriaParts[0] : String.join(criteriaParts, ' ' + queryOperator + ' ');
            }

        List<Core_MDF_Custom_Layout_Button__mdt> buttonsMetaDataRecords = [Select toLabel(Core_MDF_Button_Name_nm__c) localizedButtonName,
                                                                           Core_MDF_Button_Name_nm__c, Core_MDF_Button_Type_nm__c, 
                                                                           toLabel(Core_MDF_Object_Name_nm__c)
                                                                           From Core_MDF_Custom_Layout_Button__mdt 
                                                                           where Core_MDF_Object_API_Name_nm__c= :objAPINameStr
                                                                           And Core_MDF_Active_Ind__c = True
                                                                           And Core_MDF_Filter_Criteria_Field__c = :filterCriteria];
        
        Map<String, String> buttonDetailsMap = new Map<String, String>();
        Map<String, String> buttonLocalMap = new Map<String, String>();
        String objLabel;
        If(buttonsMetaDataRecords != null && !buttonsMetaDataRecords.isEmpty()){
            objLabel = String.valueOf(buttonsMetaDataRecords.get(0).get('Core_MDF_Object_Name_nm__c'));
            for(Core_MDF_Custom_Layout_Button__mdt btRecords : buttonsMetaDataRecords){
                buttonLocalMap.put(btRecords.Core_MDF_Button_Name_nm__c, String.valueOf(btRecords.get('localizedButtonName')));
                buttonDetailsMap.put(btRecords.Core_MDF_Button_Name_nm__c, btRecords.Core_MDF_Button_Type_nm__c);
            }
        }
            
            //14820 starts
            Boolean proposalValue = false;
            if (fields.contains('Core_MDF_Proposal_Based_Ind__c')) {
                proposalValue = (Boolean) records.get(0).get('Core_MDF_Proposal_Based_Ind__c');
            }
			//14820 ends
            
            if(!records.isEmpty() && records.size()>0){
                String resultMapKey = tabIcon + '$%@#' + objLabel + '$%@#' + String.valueOf(records.get(0).get(fldName));
                //String budgetType = records.get(0).get(fieldAPIName) == True ? 'Proposal Based' : 'Account Based';
                String budgetType = proposalValue == True ? 'Proposal Based' : 'Account Based';//14820 starts
                String recordTypeName = (String)records.get(0).get('Core_MDF_Program__c');
               /*String customLayoutSectionQuery = 'SELECT Core_MDF_ButtonsVisibilityOnStatus_txt__c, Core_MDF_ButtonVisibilityByProfile_txt__c'+
                    ' FROM Core_MDF_Custom_Layout_Section__c' +
                    ' WHERE Core_MDF_Object_Name_txt__c=: objAPIName And Core_MDF_Field_View_nm__c =: fieldView' +
                    ' And Core_MDF_Record_Type_Name_txt__c=: recordTypeName And Core_MDF_Budget_Type_nm__c =: budgetType';             
                List<SObject> sectionRecords = Database.query( customLayoutSectionQuery );*/
            //Sections with a Budget Type must match the record's computed budget type;
            //sections with no Budget Type (e.g. Client program) are program-wide - no budget type check.
            List<Sobject> sectionRecords =[SELECT Core_MDF_ButtonsVisibilityOnStatus_txt__c,Core_MDF_ButtonVisibilityByProfile_txt__c 
                FROM Core_MDF_Custom_Layout_Section__c 
            WHERE Core_MDF_Object_Name_txt__c =:objAPIName
                AND Core_MDF_Field_View_nm__c =:fieldView 
            AND Core_MDF_Record_Type_Name_txt__c =:recordTypeName
                AND Core_MDF_Budget_Type_nm__c =: budgetType];
                If(sectionRecords.isEmpty()){
                    resultMap.put(resultMapKey, new List<ButtonDetailsWrapper>());
                    return resultMap;
                }
                String actionButtonjson = (String)sectionRecords.get(0).get('Core_MDF_ButtonsVisibilityOnStatus_txt__c');
                String actionButtonjsonProfile = (String)sectionRecords.get(0).get('Core_MDF_ButtonVisibilityByProfile_txt__c');
                
                // Deserialize button based on Profile
                Map<String, Map<String, List<String>>> dataMapProfile = new Map<String, Map<String, List<String>>>();
                if(actionButtonjsonProfile != null && actionButtonjsonProfile != ''){
                    List<ParserClassBasedOnProfile> jsonListProfile = (List<ParserClassBasedOnProfile>) System.JSON.deserialize(actionButtonjsonProfile, List<ParserClassBasedOnProfile>.class);
                    for(Integer i=0; i < jsonListProfile.size(); i++){
                        Map<String, List<String>> buttonMapProfile = new Map<String, List<String>>();
                        for(Integer j=0; j < jsonListProfile[i].controllingFieldValueBasedOnPs.size(); j++){
                            List<String> buttonValues = jsonListProfile[i].controllingFieldValueBasedOnPs[j].buttons;
                            buttonMapProfile.put(jsonListProfile[i].controllingFieldValueBasedOnPs[j].controllingFieldValue, buttonValues);
                        }
                        dataMapProfile.put(jsonListProfile[i].profileName, buttonMapProfile);
                    }
                }
                
                // Deserialize button based on Permission Set
                Map<String, Map<String, List<String>>> dataMap = new Map<String, Map<String, List<String>>>();
                if(actionButtonjson != null && actionButtonjson != ''){
                    List<ParserClass> jsonList = (List<ParserClass>) System.JSON.deserialize(actionButtonjson, List<ParserClass>.class);
                    for(Integer i = 0; i < jsonList.size(); i++){
                        Map<String, List<String>> buttonMap = new Map<String, List<String>>();
                        for(Integer j=0; j < jsonList[i].controllingFieldValueBasedOnPs.size(); j++){
                            List<String> buttonValues = jsonList[i].controllingFieldValueBasedOnPs[j].buttons;
                            buttonMap.put(jsonList[i].controllingFieldValueBasedOnPs[j].controllingFieldValue, buttonValues);
                        }
                        dataMap.put(jsonList[i].prmissionSetName, buttonMap);
                    }
                }


                List<String> buttonsListProfile = new List<String>();
                List<String> buttonsList = new List<String>();
                List<String> buttonsListPS = new List<String>();
                List<String> finalButtonsList = new List<String>();
                Decimal count = 0;
                List<PermissionSetAssignment> ps = [SELECT PermissionSet.Name, Assignee.profile.name
                                                  FROM PermissionSetAssignment 
                                                  WHERE AssigneeId = :UserInfo.getUserId()];

                if(ps.size() > 0){
                    for(PermissionSetAssignment p : ps) {
                        if(dataMapProfile.size() > 0){
                            if(dataMapProfile.containsKey(p.Assignee.profile.name) && count < 1){
                                //16041
                                //buttonsListProfile = dataMapProfile.get(p.Assignee.profile.name).get(String.valueOf(records.get(0).get(recordStatus)));
                                List<String> tempButtonsListProfile = dataMapProfile.get(p.Assignee.profile.name).get(String.valueOf(records.get(0).get(recordStatus)));
                                buttonsListProfile = (tempButtonsListProfile != null) ? tempButtonsListProfile : new List<String>();                                
                                count = count + 1;
                            }   
                        }
                        if(dataMap.size() > 0){
                            if(dataMap.containsKey(p.PermissionSet.Name)){
								//16041
                                //buttonsList = dataMap.get(p.PermissionSet.Name).get(String.valueOf(records.get(0).get(recordStatus)));
                                List<String> tempButtonsList = dataMap.get(p.PermissionSet.Name).get(String.valueOf(records.get(0).get(recordStatus)));
                                buttonsList = (tempButtonsList != null) ? tempButtonsList : new List<String>();
                                system.debug('buttonsList@@@' + buttonsList);
                                for(String btnLabel : buttonsList){
                                    buttonsListPS.add(btnLabel);
                                }
                            }
                        }
                    }
                } else {
                    if(dataMapProfile.size() > 0){
                        for(Profile profileName : [SELECT Name FROM Profile WHERE Id =: userinfo.getProfileid()]) {
                            if(dataMapProfile.containsKey(profileName.Name)){
                                //16041
                                //buttonsListProfile = dataMapProfile.get(profileName.Name).get(String.valueOf(records.get(0).get(recordStatus)));
                                List<String> tempButtonsListProfile = dataMapProfile.get(profileName.Name).get(String.valueOf(records.get(0).get(recordStatus)));
                                buttonsListProfile = (tempButtonsListProfile != null) ? tempButtonsListProfile : new List<String>();
                            }
                        }
                    }
                }
                if(buttonsListProfile.isEmpty() && buttonsListPS.isEmpty()){
                    resultMap.put(resultMapKey, new List<ButtonDetailsWrapper>());
                    return resultMap;
                } else{
                    Set<String> buttonsName= new Set<String>();
                    if(!buttonsListProfile.isEmpty()){
                       finalButtonsList.addall(buttonsListProfile);
                    }
                    if(!buttonsListPS.isEmpty()){
                        finalButtonsList.addall(buttonsListPS);
                     }

                    
                
                for(String field : finalButtonsList){
                        if(!buttonsName.contains(field)){
                            buttonsName.add(field);
                            if(buttonLocalMap.containsKey(field) && buttonDetailsMap.containsKey(field)){
                                buttonDetailsList.add(getButtonsDetails(buttonLocalMap.get(field), buttonDetailsMap.get(field), field)); 
                            }
                       
                    }
                    }
                    resultMap.put(resultMapKey, buttonDetailsList);
                }
            }
    	}
        try {
            return resultMap;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    @AuraEnabled
    public static String updateCampRecord(String recordId, String campStatus){

        //Roshan
        if(recordId.startsWith('0RB')){
            return updateClaimRecord(recordId, campStatus);
        }

        String msg = '';
        Integer incrementStepCounter = Core_MDF_CCP_ConstantClass.INCREMENT_STEP_COUNTER ; //VALUE = 0
        String completedApprovalLevel = '';
        String updateIpaApprovalStatus = '';
        /*if(Core_MDF_CampaignPFR_Controller.isCustomPermissionAssigned('Core_MDF_CCP_Int_IPA_ProposalL1_Approver')){
         	
            incrementStepCounter = incrementStepCounter + 1; 
            completedApprovalLevel = Core_MDF_CCP_ConstantClass.COMPLETED_APPROVAL_LEVEL; //L1 Approval
        }*/
        Campaign[] cmp = new List<Campaign>{ 
        new Campaign(Id = recordId, Status = campStatus, Core_MDF_Approval_Step_Counter_nbr__c = incrementStepCounter, 
                     Core_MDF_Completed_Approval_Level_Nm__c = completedApprovalLevel, Core_MDF_IPA_Approval_Status_nm__c = updateIpaApprovalStatus)};
        Database.SaveResult[] srList = Database.update(cmp, false);
        
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    msg += err.getMessage();
                }
            } else {
                msg = 'sucess';
            }
        }
        return msg;
    }

    //Roshan
    @AuraEnabled
    public static String updateClaimRecord(String recordId, String claimStatus){

        String msg = '';

        PartnerFundClaim[] clm = new List<PartnerFundClaim>{ 
        new PartnerFundClaim(Id = recordId, Core_MDF_Status__c = claimStatus)};

        Database.SaveResult[] srList = Database.update(clm, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    msg += err.getMessage();
                }
            } else {
                msg = 'sucess';
            }
        }
        return msg;
    }
    
    //Swati - Added to Notify Partner
    @AuraEnabled
    public static void notifyPartner(String recordId) {
        notifyPartnerCheck = true;
        Boolean addReminderInSubject = false;    
        System.debug('recordId..'+recordId);
        Core_MDF_PIC_SendEmailToClaimOwner.NotificationWrapper input = new Core_MDF_PIC_SendEmailToClaimOwner.NotificationWrapper();
        input.claimIds = recordId;
        input.notifyPartnerUser = notifyPartnerCheck;
        input.addReminderInSubject = addReminderInSubject;
        List<Core_MDF_PIC_SendEmailToClaimOwner.NotificationWrapper> NotificationWrapperList = new List<Core_MDF_PIC_SendEmailToClaimOwner.NotificationWrapper>();
        NotificationWrapperList.add(input);
        try{
        	Core_MDF_PIC_SendEmailToClaimOwner.sendEmailtoClaimOwnerOnResubReqd(NotificationWrapperList);            
        }
        catch(Exception ex){
            System.debug('An error occurred while trying to send the email: ' + ex.getMessage());
        }
    }
    
    private static ResultWrapper getLayoutDetails(Core_MDF_Custom_Layout_Configurations__c field, List<SObject> fieldvalues, Schema.DescribeFieldResult fieldDesc, String userLang){
        Schema.DescribeFieldResult fieldDescribe = fieldDesc;
        Schema.DescribeFieldResult parentFieldDescribe;
        ResultWrapper wrapper = new ResultWrapper();
        If(field.Core_MDF_Display_Custom_Label_Ind__c == True){
            If(userLang != null && languages.contains(userLang)){
                String colToBeQueried = 'Core_MDF_'+userLang+'_cd__c';
                //Update - Display in english if localization not available
                String fldLabelInEng = String.valueOf(field.Core_MDF_Field_Label_txt__c);//Field label in english - default
                wrapper.fieldLabel = userLang != 'en_US' ? String.valueOf(field.get(colToBeQueried)) != null ? String.valueOf(field.get(colToBeQueried)) : fldLabelInEng : fldLabelInEng;
            }
            else {
                wrapper.fieldLabel = String.valueOf(field.Core_MDF_Field_Label_txt__c);
            }
        } else {
            wrapper.fieldLabel = field.Core_MDF_Is_Relationship_Ind__c == false ? fieldDescribe.getLabel() : '';
        }
        wrapper.fieldApiName = field.Core_MDF_Field_API_Name_txt__c; //Akash changes for $ and %
        
        If(field.Core_MDF_Is_Relationship_Ind__c == false 
           && String.valueOf(fieldvalues.get(0).get(field.Core_MDF_Field_API_Name_txt__c)) != null 
           && String.valueOf(fieldvalues.get(0).get(field.Core_MDF_Field_API_Name_txt__c)) != ''){
               String picVal = '';
               String recordName = '';
               String parentObjectName = '';
               String tabIcon = '';
               String fieldType = String.valueOf(fieldDescribe.getType());
               Boolean lookupCustomUrlInd = false; //TWC3117-15824
               String lookupCustomUrlValue = ''; //TWC3117-15824
               If(fieldType == 'REFERENCE'){
                   Id recId = String.valueOf(fieldvalues.get(0).get(field.Core_MDF_Field_API_Name_txt__c));
                   Schema.SObjectType objName = recId.getSobjectType();
                   parentObjectName = String.valueOf(objName);
                   lookupCustomUrlInd = field.Core_MDF_Lookup_Custom_URL_Ind__c;   //TWC3117-15824                 
                   lookupCustomUrlValue = String.valueOf(field.Core_MDF_Lookup_Custom_URL_Link_txt__c); //TWC3117-15824

                   String relationName = field.Core_MDF_Record_Name_nm__c;
                   
                   If(String.isNotBlank(relationName)){
                    recordName = (String)fieldvalues.get(0).getsobject(relationName.substringbefore('.')).get(relationName.substringafter('.'));
                   }
                   
                   String objectName = String.valueOf(objName);
                   objectName = objectName.endsWith('__c') ? objectName.substring(0, objectName.length() - 3) : String.valueOf(objName);
                   Core_MDF_Custom_Layout_Configration__mdt fieldname = Core_MDF_Custom_Layout_Configration__mdt.getInstance(objectName);
                   tabIcon = String.valueOf(fieldname.Core_MDF_Tab_Icons_Details_txt__c);
                   
               }
               else if(fieldType == 'PICKLIST' || fieldType == 'MULTIPICKLIST'){
                   Map<String, String> picklistValues = new Map<String, String>();
                   List<Schema.PicklistEntry> pick_list_values = fieldDescribe.getPickListValues(); //grab the list of picklist values for the passed field on the sobject
                   for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                       picklistValues.put(a.getValue() , a.getLabel());
                   }
                   List<string> piclistValue = String.valueOf(fieldvalues.get(0).get(field.Core_MDF_Field_API_Name_txt__c)).split(';');
                   for (String str : piclistValue) { //for all values in the picklist list
                       picval += picklistValues.get(str) + ';';
                   }
                   picval = picval.removeEnd(';');
               }
               if(fieldType == 'PICKLIST' || fieldType == 'MULTIPICKLIST'){
                   wrapper.fieldValue = picVal;
               } else {
                   wrapper.fieldValue = String.valueOf(fieldvalues.get(0).get(field.Core_MDF_Field_API_Name_txt__c));
               }
               wrapper.fieldValueName = fieldType == 'REFERENCE' ? recordName : '';
               wrapper.parentObjectName = fieldType == 'REFERENCE' ? parentObjectName : '';               
               wrapper.lookupCustomUrlInd = fieldType == 'REFERENCE' ? lookupCustomUrlInd : false; //TWC3117-15824
               wrapper.lookupCustomUrlValue = fieldType == 'REFERENCE' ? lookupCustomUrlValue : ''; //TWC3117-15824

               wrapper.tabIcon = fieldType == 'REFERENCE' ? tabIcon : '';
               wrapper.fieldType = fieldType;
           } 
        else if(field.Core_MDF_Is_Relationship_Ind__c == true){
              String piclistFieldVal = '';
              String parentRelationName = '';
              String parentName = '';
              String parentFieldName = '';
              Schema.DescribeSObjectResult parentObjectDescribe;
              String relationName = field.Core_MDF_Record_Name_nm__c;
              if(String.isNotBlank(relationName)){
                parentRelationName = relationName.substringbefore('.');
                //parentName = parentRelationName.endsWith('__r') ? parentRelationName.substring(0, parentRelationName.length() - 1) + 'c' : parentRelationName;//Core_MDF_Campaign_Id__c - Campaign
				//Another field to specify the exact parent Name - no diff this is std or custom - mandate, 394 is not needed
				//existing data - updates(validation rule)
				parentName = field.Core_MDF_Parent_Object_nm__c;//Object nm - Parent Ovject Name
                parentFieldName = relationName.substringafter('.');
              }
              if(String.isNotBlank(parentName)){
                  //parentObjectDescribe = Schema.getGlobalDescribe().get(parentName).getDescribe();
                  if(parentName=='Campaign'){
                    parentObjectDescribe=Campaign.SObjectType.getDescribe();
                  }
                  else if(parentName == 'PartnerFundRequest'){
                    parentObjectDescribe=PartnerFundRequest.SObjectType.getDescribe();
                  }
                  else{
                    // ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
                    parentObjectDescribe = getSObjectDescribe(parentName);
                }
            }
              if(parentObjectDescribe != null && parentObjectDescribe.isAccessible()){
                // ATHR Fix: Null check on fields.getMap().get() return value
                SObjectField parentFieldToken = parentObjectDescribe.fields.getMap().get(parentFieldName);
                if(parentFieldToken != null) {
                    parentFieldDescribe = parentFieldToken.getDescribe();
                }
              }
              if(parentFieldDescribe != null){
                    String fieldType = String.valueOf(parentFieldDescribe.getType());
                    
                    if(String.valueOf(fieldvalues.get(0).getsobject(parentRelationName).get(parentFieldName)) != null 
                       && String.valueOf(fieldvalues.get(0).getsobject(parentRelationName).get(parentFieldName)) != ''){
                        String recordName;
                        if(fieldType == 'DATE') {
                            Datetime myDT = Date.valueOf(fieldvalues.get(0).getsobject(parentRelationName).get(parentFieldName));
                            TimeZone userTz = UserInfo.getTimeZone();
                            String formattedDate = myDT.format('yyyy-MM-dd', userTz.getID());
                            //String myDTString = myDT.formatGMT('yyyy-MM-dd');//formatGMTLocale
                            //recordName = (string)myDTString;
                            recordName = formattedDate;
                        } else {
                            recordName = (String)fieldvalues.get(0).getsobject(parentRelationName).get(parentFieldName);
                        }
                        
                        if(fieldType == 'PICKLIST' || fieldType == 'MULTIPICKLIST'){
                            Map<String, String> picklistValues = new Map<String, String>();
                            List<Schema.PicklistEntry> pick_list_values = parentFieldDescribe.getPickListValues(); //grab the list of picklist values for the passed field on the sobject
                            for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                                picklistValues.put(a.getValue() , a.getLabel());
                            }
                            List<string> piclistValue = String.valueOf(recordName).split(';');
                            for (String str : piclistValue) { //for all values in the picklist list
                                piclistFieldVal += picklistValues.get(str) + ';';
                            }
                            piclistFieldVal = piclistFieldVal.removeEnd(';');
                        }
                        if(fieldType == 'PICKLIST' || fieldType == 'MULTIPICKLIST'){
                            wrapper.fieldValue = piclistFieldVal;
                        } else {
                        wrapper.fieldValue = recordName;
                        }
                      }
                    wrapper.fieldLabel = parentFieldDescribe.getLabel();
                    wrapper.fieldValueName = '';
                    wrapper.parentObjectName = '';
                    wrapper.lookupCustomUrlInd = false; //TWC3117-15824
                    wrapper.lookupCustomUrlValue = ''; //TWC3117-15824
                    wrapper.tabIcon = '';
                    wrapper.fieldType = 'STRING';
                }
           } else {
               wrapper.fieldValue = '';
               wrapper.fieldValueName = '';
               wrapper.parentObjectName = '';
               wrapper.lookupCustomUrlInd = false; //TWC3117-15824
               wrapper.lookupCustomUrlValue = ''; //TWC3117-15824
               wrapper.tabIcon = '';
               wrapper.fieldType = 'STRING';
           }
        wrapper.fieldPosition = field.Core_MDF_Alignment_nm__c;
        wrapper.isAccessible = fieldDescribe.isAccessible() == true ? true : false;
        wrapper.hideIfNoValue = field.Core_MDF_Hide_If_No_Value_Ind__c;
        wrapper.isHiddenFromUI = field.Core_MDF_Hidden_Ind__c;//Added by AN
        wrapper.hideSectionIfNoValue = field.Core_MDF_Section_id__r.Core_MDF_Hide_If_No_Value_Ind__c;//Added by RS
        wrapper.isRichTextField = field.Core_MDF_RichText_Ind__c;//Added by VB
        if((parentFieldDescribe == null && fieldDescribe.isAccessible() == true) || 
           (parentFieldDescribe != null && parentFieldDescribe.isAccessible() == true)){
           wrapper.isAccessible = true;
        } else {
           wrapper.isAccessible = false;
        }
        if(parentFieldDescribe != null){
           wrapper.helpText = parentFieldDescribe.getInlineHelpText() != null ? parentFieldDescribe.getInlineHelpText() : '';
        } 
        else if(parentFieldDescribe == null){
        wrapper.helpText = fieldDescribe.getInlineHelpText() != null ? fieldDescribe.getInlineHelpText() : '';
        } 
        
        If(userLang != null && languages.contains(userLang)){
            String colToBeQueried = 'Core_MDF_'+userLang+'_cd__c';
            String	sectionNameInEng = String.valueOf(field.Core_MDF_Section_id__r.Core_MDF_Section_Name_txt__c);//Section Name in English
            wrapper.section = userLang != 'en_US' ? String.valueOf(field.Core_MDF_Section_id__r.get(colToBeQueried)) != null ? String.valueOf(field.Core_MDF_Section_id__r.get(colToBeQueried)) : sectionNameInEng : sectionNameInEng;
        }
        else {
            wrapper.section = String.valueOf(field.Core_MDF_Section_id__r.Core_MDF_Section_Name_txt__c);//for other languages which is not configured
        }
        wrapper.noOfColumns = field.Core_MDF_Section_id__r.Core_MDF_No_Of_Columns_nm__c;
        return wrapper;
    }

    //TWC3117-19154 start
    @AuraEnabled
    public static void recallToPaymentClearance(Id claimId) {
        if (claimId == null || claimId.getSObjectType() != PartnerFundClaim.SObjectType) {
            throw new AuraHandledException('Provide a valid claim ID.');
        }
        try {
            Set<String> eligibleSubclaimStatuses = new Set<String>{
                Label.Core_MDF_Claim_Status_Payment_Due,
                Label.Core_MDF_Claim_Status_Pending_Available_Fund,
                Label.Core_MDF_Hold_Status
            };
            List<PartnerFundClaim> claimsToUpdate = new List<PartnerFundClaim>{
                new PartnerFundClaim(
                    Id = claimId,
                    Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Payment_Clearance_Processing,
                    Core_MDF_PIC_Review_Completed__c = false
                )
            };
            List<PartnerFundClaim> eligibleSubclaims = [SELECT Id FROM PartnerFundClaim WHERE Core_MDF_Claim_Id__c = :claimId AND Core_MDF_Status__c IN :eligibleSubclaimStatuses FOR UPDATE];
            for (PartnerFundClaim subclaim : eligibleSubclaims) {
                claimsToUpdate.add(new PartnerFundClaim(
                    Id = subclaim.Id,
                    Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Draft,
                    Core_MDF_PIC_Review_Completed__c = false
                ));
            }
            update claimsToUpdate;
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    //TWC3117-19154 end

    // Roshan - Recall for CCF/DCF/RMF
    @AuraEnabled
    public static void recallToPICReview(Id claimId) {
        try {
            PartnerFundClaim claim = [SELECT Id, Core_MDF_Status__c, Core_MDF_ESD_Hold__c, Core_MDF_Audit_Hold__c, Core_MDF_Payment_Hold_ind__c, Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c, Core_MDF_Member_Manual_Hold_Ind__c, Core_MDF_Document_Hold_Ind__c, Core_MDF_VAT_Hold_Ind__c, Core_MDF_Bank_Doc_Hold_Ind__c FROM PartnerFundClaim WHERE Id = :claimId FOR UPDATE];
            
            update new PartnerFundClaim(
                Id = claimId,
                Core_MDF_Status__c = Label.Core_MDF_Claim_Status_PIC_Pending,
                Core_MDF_PIC_Review_Completed__c = false
            );
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void logErrors(String errorMessage, String objName) {
        try {
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorMessage, objName);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    private static ButtonDetailsWrapper getButtonsDetails(String label, String type, String orgLabel){
        ButtonDetailsWrapper wrapper = new ButtonDetailsWrapper();
        wrapper.label = label;
        wrapper.type = type;
        wrapper.orgLabel = orgLabel;
        return wrapper;
    }
    
    public class ResultWrapper {
        @AuraEnabled public String fieldLabel { get; set; }
        @AuraEnabled public String fieldApiName { get; set; } //Akash changes for $ and %
        @AuraEnabled public String fieldValue { get; set; }
        @AuraEnabled public String fieldValueName { get; set; }
        @AuraEnabled public String parentObjectName { get; set; }
        @AuraEnabled public String tabIcon { get; set; }
        @AuraEnabled public String fieldPosition { get; set; }
        @AuraEnabled public Boolean isAccessible { get; set; }
        @AuraEnabled public String helpText { get; set; }
        @AuraEnabled public String section { get; set; }
        @AuraEnabled public String noOfColumns { get; set; }
        @AuraEnabled public String fieldType { get; set; }
        @AuraEnabled public Boolean hideIfNoValue { get; set; }
        @AuraEnabled public Boolean isHiddenFromUI {get; set;}//Added by AN
        @AuraEnabled public Boolean hideSectionIfNoValue {get; set;}//Added by RS
        @AuraEnabled public Boolean isRichTextField {get; set;}//Added by VB
        @AuraEnabled public Boolean lookupCustomUrlInd {get; set;}//TWC3117-15824
        @AuraEnabled public String lookupCustomUrlValue {get; set;}//TWC3117-15824

    }
    
    public class ButtonDetailsWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String type;
        @AuraEnabled public String orgLabel;
    }
    
    public class ParserClass {
        public String prmissionSetName;
        public List<ControllingFieldValueBasedOnPs> controllingFieldValueBasedOnPs;
    }

    public class ParserClassBasedOnProfile {
        public String profileName;
        public List<ControllingFieldValueBasedOnPs> controllingFieldValueBasedOnPs;
    }
    
    public class ControllingFieldValueBasedOnPs {
        public String controllingFieldValue;
        public List<String> buttons;
    }
    
    public class ButtonDetails {
        public String buttonName;
        public String buttonType;
        public String ComponentNameOrStatus;
    }
}