public without sharing class Core_MDF_CustomLayout_ClaimController {
    @AuraEnabled
    public static Map<String, List<ResultWrapper>> getObjectFields(String recordId, String objAPIName, String fieldView) {
        List<ResultWrapper> resultList = new List<ResultWrapper>();
        Map<String, List<ResultWrapper>> resultMap = new Map<String, List<ResultWrapper>>();
        List<Core_MDF_Custom_Layout_Configurations__c> fieldName = new List<Core_MDF_Custom_Layout_Configurations__c>();
        String userType = UserInfo.getUserType() == 'PowerPartner' ? 'External User' : 'Internal User'; 
        //String fieldAPINameStr =  String.escapeSingleQuotes(fieldAPIName);
        String objAPINameStr =  String.escapeSingleQuotes(objAPIName);
        
        String query = 'SELECT '+
            'Core_MDF_Program__c FROM ' +
            objAPINameStr +
            ' WHERE Id=: recordId ';
        System.debug('query--> '+query);
        List<SObject> records = Database.query( query );
        If(records.isEmpty()){
            return resultMap;
        }
        //String filterCriteria = fieldAPIName +  ' == '  +records.get(0).get(fieldAPIName);
        String recordTypeName = (String)records.get(0).get('Core_MDF_Program__c');
        //System.debug('filterCriteria--> '+filterCriteria);
        System.debug('recordTypeName--> '+recordTypeName);
        String recordQuery = 'SELECT ' ;
        for(Core_MDF_Custom_Layout_Configurations__c field : [SELECT id, Core_MDF_Field_Label_txt__c, Core_MDF_Field_API_Name_txt__c,
                                                              Core_MDF_Budget_Type_nm__c, Core_MDF_Record_Type_Name_txt__c, Core_MDF_Object_API_Name_txt__c, Core_MDF_Alignment_nm__c, 
                                                              Core_MDF_Display_Custom_Label_Ind__c, Core_MDF_zh_CN_cd__c, Core_MDF_zh_TW_cd__c, 
                                                              Core_MDF_fr_cd__c, Core_MDF_de_cd__c, Core_MDF_Sequence_No_nbr__c, Core_MDF_it_cd__c, Core_MDF_ja_cd__c, Core_MDF_ko_cd__c, 
                                                              Core_MDF_pt_BR_cd__c, Core_MDF_ru_cd__c, Core_MDF_es_MX_cd__c, Core_MDF_es_cd__c, Core_MDF_Section_id__r.Core_MDF_Section_Name_txt__c,
                                                              Core_MDF_Section_id__r.Core_MDF_No_Of_Columns_nm__c, Core_MDF_Section_id__r.Core_MDF_zh_CN_cd__c, Core_MDF_Section_id__r.Core_MDF_zh_TW_cd__c,
                                                              Core_MDF_Section_id__r.Core_MDF_fr_cd__c, Core_MDF_Section_id__r.Core_MDF_de_cd__c, 
                                                              Core_MDF_Section_id__r.Core_MDF_it_cd__c, Core_MDF_Section_id__r.Core_MDF_ja_cd__c, Core_MDF_Section_id__r.Core_MDF_ko_cd__c, 
                                                              Core_MDF_Section_id__r.Core_MDF_pt_BR_cd__c, Core_MDF_Section_id__r.Core_MDF_ru_cd__c,
                                                              Core_MDF_Section_id__r.Core_MDF_es_MX_cd__c, Core_MDF_Section_id__r.Core_MDF_es_cd__c, Core_MDF_Record_Name_nm__c, Core_MDF_Is_Lookup_Ind__c
                                                              FROM Core_MDF_Custom_Layout_Configurations__c 
                                                              WHERE Core_MDF_Object_API_Name_txt__c = :objAPIName 
                                                              AND Core_MDF_Active_Ind__c = True
                                                              AND Core_MDF_Record_Type_Name_txt__c = :recordTypeName
                                                              AND Core_MDF_User_Type_nm__c = :userType
                                                              AND Core_MDF_Section_id__r.Core_MDF_Object_Name_txt__c = :objAPIName
                                                              AND Core_MDF_Section_id__r.Core_MDF_Field_View_nm__c = :fieldView
                                                              ORDER BY Core_MDF_Section_id__r.Core_MDF_Sequence_No_nbr__c,Core_MDF_Sequence_No_nbr__c ASC]) {
            fieldName.add(field);
            recordQuery += field.Core_MDF_Field_API_Name_txt__c + ','  ;
            If(field.Core_MDF_Is_Lookup_Ind__c == true && field.Core_MDF_Record_Name_nm__c != null){
                recordQuery += field.Core_MDF_Record_Name_nm__c + ',' ;
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
            Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objAPIName).getDescribe();
            for(Integer j=0; j < fieldName.size(); j++){
                resultList.add(getLayoutDetails(fieldName[j], getRecords, objectDescribe, userLang));
            }
            resultMap.put(userType, resultList);
        }
        try {
            return resultMap;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }
    
    @AuraEnabled
    public static Map<String, List<ButtonDetailsWrapper>> getObjActions(String recordId, String objAPIName, String fieldView) {
        Map<String, List<ButtonDetailsWrapper>> resultMap = new Map<String, List<ButtonDetailsWrapper>>();
        List<ButtonDetailsWrapper> buttonDetailsList = new List<ButtonDetailsWrapper>();
        Map<String, String> buttonsMap = new Map<String, String>();
        String objAPINameStr =  String.escapeSingleQuotes(objAPIName);
        //String fieldAPINameStr =  String.escapeSingleQuotes(fieldAPIName);
        
        String objectName = objAPIName.endsWith('__c') ? objAPIName.substring(0, objAPIName.length() - 3) : String.valueOf(objAPIName);
        List<Core_MDF_Custom_Layout_Configration__mdt> metaDataRecords = [Select label, Core_MDF_Field_API_Name__c, 
                                                                          Core_MDF_Record_Status_txt__c, Core_MDF_Tab_Icons_Details_txt__c, 
                                                                          Core_MDF_Buttons_Config_Details_txt__c 
                                                                          From Core_MDF_Custom_Layout_Configration__mdt 
                                                                          where DeveloperName= :objectName];
        String fldName = String.valueOf(metaDataRecords.get(0).get('Core_MDF_Field_API_Name__c'));
        String recordStatus = String.valueOf(metaDataRecords.get(0).get('Core_MDF_Record_Status_txt__c'));
        String tabIcon = String.valueOf(metaDataRecords.get(0).get('Core_MDF_Tab_Icons_Details_txt__c')) != '' ? String.valueOf(metaDataRecords.get(0).get('Core_MDF_Tab_Icons_Details_txt__c')) : '';
        String objLabel = String.valueOf(metaDataRecords.get(0).get('label'));
        String query = 'SELECT '+
            fldName + ', ' +
            recordStatus + ',' +
            ', Core_MDF_Program__c FROM ' +
            objAPINameStr +
            ' WHERE Id=: recordId ';
        List<SObject> records = Database.query( query );
        String resultMapKey = tabIcon + '$%@#' + objLabel + '$%@#' + String.valueOf(records.get(0).get(fldName));
        //String budgetType = records.get(0).get(fieldAPIName) == True ? 'Proposal Based' : 'Account Based';
        String recordTypeName = (String)records.get(0).get('Core_MDF_Program__c');
        String customLayoutSectionQuery = 'SELECT Core_MDF_ButtonsVisibilityOnStatus_txt__c, Core_MDF_ButtonVisibilityByProfile_txt__c'+
            ' FROM Core_MDF_Custom_Layout_Section__c' +
            ' WHERE Core_MDF_Object_Name_txt__c=: objAPIName And Core_MDF_Field_View_nm__c =: fieldView' +
            ' And Core_MDF_Record_Type_Name_txt__c=: recordTypeName';             
        List<SObject> sectionRecords = Database.query( customLayoutSectionQuery );
        If(sectionRecords.isEmpty()){
            resultMap.put(resultMapKey, new List<ButtonDetailsWrapper>());
            return resultMap;
        }
        String actionButtonjson = (String)sectionRecords.get(0).get('Core_MDF_ButtonsVisibilityOnStatus_txt__c');
        String actionButtonjsonProfile = (String)sectionRecords.get(0).get('Core_MDF_ButtonVisibilityByProfile_txt__c');
        
        // Deserialize button based on Object
        Map<String, String> buttonDetailsMap = new Map<String, String>();
        String buttonDetailsJson = String.valueOf(metaDataRecords.get(0).get('Core_MDF_Buttons_Config_Details_txt__c'));
        List<ButtonDetails> buttonList = (List<ButtonDetails>) System.JSON.deserialize(buttonDetailsJson, List<ButtonDetails>.class);
        for(Integer k=0; k < buttonList.size(); k++){
            String mapValue = buttonList[k].buttonType + ',' + buttonList[k].ComponentNameOrStatus;
            buttonDetailsMap.put(buttonList[k].buttonName, mapValue);
        }

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
                        buttonsListProfile = dataMapProfile.get(p.Assignee.profile.name).get(String.valueOf(records.get(0).get(recordStatus)));
                        count = count + 1;
                    }   
                }
                if(dataMap.size() > 0){
                    if(dataMap.containsKey(p.PermissionSet.Name)){
                        buttonsList = dataMap.get(p.PermissionSet.Name).get(String.valueOf(records.get(0).get(recordStatus)));
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
                        buttonsListProfile = dataMapProfile.get(profileName.Name).get(String.valueOf(records.get(0).get(recordStatus)));
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
            finalButtonsList.addall(buttonsListPS);
            for(String field : finalButtonsList){
                if(!buttonsName.contains(field)){
                    buttonsName.add(field);
                    buttonDetailsList.add(getButtonsDetails(field, buttonDetailsMap.get(field)));
                }
            }
            resultMap.put(resultMapKey, buttonDetailsList);
        }
        try {
            return resultMap;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    @AuraEnabled
    public static String updateCampRecord(String recordId, String campStatus){
        String msg = '';
        Campaign[] cmp = new List<Campaign>{
            new Campaign(Id = recordId, Status= campStatus)};
        Database.SaveResult[] srList = Database.update(cmp, false);
        
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                    msg += err.getMessage();
                }
            } else {
                System.debug('Sucess');
                msg = 'sucess';
            }
        }
        System.debug('msg---> ' +msg);
        return msg;
    }
    
    private static ResultWrapper getLayoutDetails(Core_MDF_Custom_Layout_Configurations__c field, List<SObject> fieldvalues, Schema.DescribeSObjectResult objectDescribe, String userLang){
        Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(field.Core_MDF_Field_API_Name_txt__c).getDescribe();
        system.debug('@@ field name= '+objectDescribe.fields.getMap().get(field.Core_MDF_Field_API_Name_txt__c));
        System.debug('@@fieldDescribe.isAccessible() '+fieldDescribe.isAccessible());
        ResultWrapper wrapper = new ResultWrapper();
        If(field.Core_MDF_Display_Custom_Label_Ind__c == True){
            If(userLang != null && userLang != 'en_US'){
                String colToBeQueried = 'Core_MDF_'+userLang+'_cd__c';
                wrapper.fieldLabel = String.valueOf(field.get(colToBeQueried));
            }
            else {
                wrapper.fieldLabel = String.valueOf(field.Core_MDF_Field_Label_txt__c);
            }
        } else {
            wrapper.fieldLabel = fieldDescribe.getLabel();
        }
        
        If(String.valueOf(fieldvalues.get(0).get(field.Core_MDF_Field_API_Name_txt__c)) != null 
           && String.valueOf(fieldvalues.get(0).get(field.Core_MDF_Field_API_Name_txt__c)) != ''){
               String picVal = '';
               String recordName = '';
               String parentObjectName = '';
               String tabIcon = '';
               String fieldType = String.valueOf(fieldDescribe.getType());
               If(fieldType == 'REFERENCE'){
                   Id recId = String.valueOf(fieldvalues.get(0).get(field.Core_MDF_Field_API_Name_txt__c));
                   Schema.SObjectType objName = recId.getSobjectType();
                   parentObjectName = String.valueOf(objName);
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
               wrapper.tabIcon = fieldType == 'REFERENCE' ? tabIcon : '';
               wrapper.fieldType = fieldType;
           } else {
               wrapper.fieldValue = '';
               wrapper.fieldValueName = '';
               wrapper.parentObjectName = '';
               wrapper.tabIcon = '';
               wrapper.fieldType = 'STRING';
           }
        wrapper.fieldPosition = field.Core_MDF_Alignment_nm__c;
        wrapper.isAccessible = fieldDescribe.isAccessible() == true ? true : false;
        wrapper.helpText = fieldDescribe.getInlineHelpText() != null ? fieldDescribe.getInlineHelpText() : '';
        If(userLang != null && userLang != 'en_US'){
            String colToBeQueried = 'Core_MDF_'+userLang+'_cd__c';
            wrapper.section = String.valueOf(field.Core_MDF_Section_id__r.get(colToBeQueried));
        }
        else {
            wrapper.section = String.valueOf(field.Core_MDF_Section_id__r.Core_MDF_Section_Name_txt__c);
        }
        wrapper.noOfColumns = field.Core_MDF_Section_id__r.Core_MDF_No_Of_Columns_nm__c;
        return wrapper;
    }
    
    private static ButtonDetailsWrapper getButtonsDetails(String label, String type){
        ButtonDetailsWrapper wrapper = new ButtonDetailsWrapper();
        wrapper.label = label;
        wrapper.type = type;
        return wrapper;
    }
    
    public class ResultWrapper {
        @AuraEnabled public String fieldLabel { get; set; }
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
    }
    
    public class ButtonDetailsWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String type;
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