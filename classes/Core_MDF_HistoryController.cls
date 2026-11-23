/****************************************************************************************************************************************
* Class Name  : Core_MDF_HistoryController 
* Version     : 1.0 
* Created Date: 11/20/2019
* Modification & Enhancement Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Mayuri              21/05/2024                   This class hold the custom history component methods. Modified the code to resolve below existing issues 
1) Number and ID issue - 15 digit number is considered as Id
2) User Masking issue  - Not all the history records are masked by existing code. Code is masking records randomly
3) If on the history record there are two users, one is internal and another is external then the existing code is not working properly. Either it will mask both users or none.
*****************************************************************************************************************************************/

public with sharing class Core_MDF_HistoryController {
    
    public static Map<String,String> userIdToUserNameMapping;
    public static Map<String,String> userIdToUrlMapping;
    public static Map<String,String> uidToNameMap ;
    public static String globalInternalUserName;
    public static Map<String, SObjectField> fieldtofieldDetailsMap;
    public static Map<String, String> fieldtofieldLabel = new Map<String,String>();
    public static Set<String> maskedFields = new Set<String>();
    public static List<String> hisIdList = new List<String>();
    public static List<String> userNames = new List<String>();
    
    //mask user name and url
    public static void maskUserName(Map<Id,User> userIdToUserMapping,string internalUserName){
        uidToNameMap = new Map<String,String> {};
            userIdToUserNameMapping = new Map<String,String> {};
                userIdToUrlMapping = new Map<String,String> {};
                    globalInternalUserName = internalUserName;
        String url='';
        String userName = '';
        try{
            for(Id uId : userIdToUserMapping.keySet()) {
                uidToNameMap.put(uId,userIdToUserMapping.get(uId).Name);
                if(userIdToUserMapping.get(uId).UserType == 'PowerPartner') {
                    if(UserInfo.getUserType() == 'PowerPartner') {
                        userName = userIdToUserMapping.get(uId).Name;
                        url=Label.Core_MDF_PFRCommunityLink + 's/profile/' + uId;
                    }
                    else{
                        //get the internal url link
                        userName = userIdToUserMapping.get(uId).Name;
                        url=Label.Core_MDF_Environment_URL + 'User/' + uId + '/view';
                    }
                }
                else{
                    userName = internalUserName;
                    url='';
                }
                userIdToUrlMapping.put(String.valueOf(uId),url);
                userIdToUserNameMapping.put(String.valueOf(uId),userName);
            }
        }
        catch(Exception e) {
          Core_MDF_CCP_UtilityClass.logError(e); 
         throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);
         }
    }
    
    //Load the history data based on record Id and Object name
    @AuraEnabled(cacheable=true)
    public static List<History> loadData(Id recordId,string objectInfo,string internalUserName, String fieldsToMask){
        Core_MDF_HistoryUtility userValueList=new Core_MDF_HistoryUtility();
        String historyTestIds = Label.Core_MDF_History_Test_Ids;
        String[] testIds =  historyTestIds.split(',');
        List<String> valueList = new List<String> {};
        String objectName = '';
        String idFieldName = '';
        List<String> fieldsList = new List<String>();
        Map<Id,User> userIdTouserTypeMap = new Map<Id,User> {};
        List<History> newHistList = new List<History>();
        List<sObject> historyData = new List<SObject>();
        List<String> notAccessibleFieldList = new List<String>();
        fieldsList = fieldsToMask.split(';');
        maskedFields.addALL(fieldsList);

        try{      
            // check the accessibility of the fields in sObject  
            // get the details of the field in the object
            Map<String,String> fieldLabelToFieldApiNameMap = new Map<String,String>{};
                fieldtofieldDetailsMap = Schema.getGlobalDescribe().get(objectInfo).getDescribe().Fields.getMap(); 
            for (String fieldName: fieldtofieldDetailsMap.keySet()) {  
                fieldLabelToFieldApiNameMap.put(fieldtofieldDetailsMap.get(fieldName).getDescribe().getLabel(),fieldName);
            }

            Set<String> historyDataFieldSet = new Set<String>();
            
            //check whether its standard or custom object
            if(objectInfo.contains('__c')) {
                  objectName= objectInfo.substringBefore('__c')+'__History';
                  idFieldName = 'ParentId';
             } 
            else{
                objectName= objectInfo+'History';
                idFieldName = objectInfo+'Id';
            }
            //create a new history object instance
            sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
            Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
            SObject sObjectHistory = t.newSObject();
            String objName = String.valueOf(t);
            //get the history data by querying the history object
            String query ='SELECT Id, CreatedById, format(CreatedDate), Field , toLabel(Field) localizedField, toLabel(OldValue), toLabel(NewValue),'
                +String.escapeSingleQuotes(idFieldName)+' FROM '+String.escapeSingleQuotes(objName)+' where '+String.escapeSingleQuotes(idFieldName)+' =\''+String.escapeSingleQuotes(recordId)+'\' order by CreatedDate desc';
            List<sObject> historyDatafromQuery = Database.query(query);
            for(SObject hData : historyDatafromQuery){historyDataFieldSet.add(String.valueOf(hData.get('localizedField')));
                                                     }
            for(String f : historyDataFieldSet){
                if(fieldLabelToFieldApiNameMap.containsKey(f)){
                     Schema.DescribeFieldResult fieldDetails = fieldtofieldDetailsMap.get(fieldLabelToFieldApiNameMap.get(f)).getDescribe();
                     if(!fieldDetails.isAccessible()){
                                  notAccessibleFieldList.add(f);
                     }
                                                              }
            }
            for(integer i =0; i<historyDatafromQuery.size(); i++){String fieldName = String.valueOf(historyDatafromQuery[i].get('localizedField'));
                 if(!notAccessibleFieldList.contains(fieldName)){historyData.add(historyDatafromQuery[i]);}}
            
            if(Test.isRunningTest()) {
                if(objectInfo == 'Account') {
                    historyData.add(new AccountHistory
                                    (
                                        AccountId=recordId,
                                        Field='Type'
                                    ));
                    historyData.add(new AccountHistory
                                    (
                                        AccountId=recordId,
                                        Field='Core_MDF_Channel_Program__c'
                                    ));
                    if (Schema.sObjectType.User.fields.userType.isAccessible()) {
                    User u = [SELECT Id,Name,userType FROM User where usertype='PowerPartner' limit 1];
                    valueList.add(u.id);
                    }

                }
                else if(objectInfo == 'PartnerFundClaim'){
                    if (Schema.sObjectType.PartnerFundCLaimHistory.fields.Id.isAccessible()) {
                    historyData = [Select Id, CreatedById, format(CreatedDate), tolabel(Field), format(OldValue), format(NewValue) FROM PartnerFundCLaimHistory Where PartnerFundClaimId =:recordId limit 1000];//ATHR
                    historyData.add(new PartnerFundClaimHistory
                                    (
                                        PartnerFundClaimId=recordId,
                                        Field='created'
                                    ));
                    }
                    if (Schema.sObjectType.User.fields.userType.isAccessible()) {
                        User u = [SELECT Id,Name,userType FROM User where usertype='Standard' limit 1];
                        valueList.add(u.id);
                        }                  
                }
            }
            
            //loop through the list and capture all user id type values in a list valueList.
            Integer i=0;
            for(SObject hobj:historyData) {
                String newStr = String.valueOf(hobj.get('NewValue'));
                String oldStr = String.valueOf(hobj.get('OldValue'));
                String CreatedById = String.valueOf(hobj.get('CreatedById'));
                String hisId = String.valueOf(historyData[i].get('Id'));
                String nonLocField = String.valueOf(hobj.get('Field'));
                String field = '';
                if(!Test.isRunningTest()) {
                     field = String.valueOf(hobj.get('localizedField'));
                  }
                
                if((newStr != null && isId(newStr) && newStr.startsWith('005') && maskedFields.contains(nonLocField)) 
                   || (oldStr != null && isId(oldStr) && oldStr.startsWith('005') && maskedFields.contains(nonLocField)))
                {
                    valueList.add(newStr);
                    valueList.add(oldStr);
                    hisIdList.add(hisId);
                }
                valueList.add(CreatedById);
                i++;
            }
            
            //Get User Details
            userIdTouserTypeMap = userValueList.getUserDetails(valueList);
            
            //call method to mask user name
            maskUserName(userIdTouserTypeMap,internalUserName);
            //form history data and return to UI.
            newHistList = formHistoryData(historyData);
        }
        catch(Exception e) {
     Core_MDF_CCP_UtilityClass.logError(e); 
     throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);}
        return newHistList;
    }
    
    //check whether passed string parameter is an Id or not
    public static Boolean isId(String possibleId) { 
        try { 
            Id.valueOf(possibleId); 
        } catch(Exception ex) { 
            return false; 
        } 
        return true; 
    }  
    
    public static String getValueForOtherDataTypes(String oldOrNewValueStr, object oldOrNewValue) 
    {
        
        String  updatedOldOrNewValue ='';       
        //if old value is of Date format    
        if(oldOrNewValueStr != null && oldOrNewValue instanceOf Date) {
            DateTime oldDate = DateTime.valueOf(oldOrNewValueStr);
            DateTime myDate = DateTime.newInstance(oldDate.year(), oldDate.month(), oldDate.day());
            updatedOldOrNewValue = myDate.format('yyyy-MM-dd');
        }                                                                                                     
        //if old value is of Datetime format    
        else if(oldOrNewValueStr != null && oldOrNewValue instanceOf DateTime) {
            DateTime oldDate = DateTime.valueOf(oldOrNewValueStr);
            DateTime myDate = DateTime.newInstanceGmt(oldDate.year(),oldDate.month(),oldDate.day(),oldDate.hour(),oldDate.minute(),oldDate.second()); 
            updatedOldOrNewValue = myDate.format('MM/dd/yyyy h:m a');
        }                                                                                                           
        //if old value is of currency format, set scale to 2 decimal places 
        else if(oldOrNewValueStr != null && oldOrNewValue instanceOf String) {
            if(oldOrNewValueStr.contains('.')){
                String replacedStringwithoutPeriod = oldOrNewValueStr.substringBefore('.')+oldOrNewValueStr.substringAfter('.');
                if(replacedStringwithoutPeriod.isNumeric()){
                    updatedOldOrNewValue = String.valueOf(Decimal.valueOf(oldOrNewValueStr).setScale(2));
                }else{updatedOldOrNewValue =oldOrNewValueStr;
                     }}else{updatedOldOrNewValue =oldOrNewValueStr;
                           }
        }                                                                                                   
        else{
            updatedOldOrNewValue =oldOrNewValueStr;
        }
        return updatedOldOrNewValue;
    }
    
    
    //form history data
    public static List<History> formHistoryData(List<sObject> historyData){
        List<History> newHistList = new List<History>();
        try{
            //Again loop through the history data and form all values required for UI.
            for(SObject his:historyData) {
                History hisWrapper = new History();
                String newStr = String.valueOf(his.get('NewValue'));
                String oldStr = String.valueOf(his.get('OldValue'));
                String hisId = String.valueOf(his.get('Id'));
                String hisCreatedDate = String.valueOf(his.get('CreatedDate'));
                String hisCreatedById = String.valueOf(his.get('CreatedById'));
                String nonLocField = String.valueOf(his.get('Field'));
                String hisField ='';
                
                if(!Test.isRunningTest()) {
                     hisField = String.valueOf(his.get('localizedField'));
                  }
                

                if(maskedFields.contains(nonLocField) && ((userNames.contains(oldStr) || userNames.contains(newStr))) )
                {
                    continue;
                }
                if(((!isId(newStr)) && (!isId(oldStr))) || (hisIdList.contains(hisId))){
                    hisWrapper.id= hisId;
                    hisWrapper.user=(userIdToUserNameMapping != null && userIdToUserNameMapping.get(hisCreatedById) != null) ? userIdToUserNameMapping.get(hisCreatedById) : globalInternalUserName;
                    hisWrapper.field = hisField;				
                    hisWrapper.createdDate = hisCreatedDate;
                    hisWrapper.userUrl = userIdToUrlMapping.get(hisCreatedById);
                    hisWrapper.isCheckbox=false;
                    
                    //if old value is a user name
                    if(uidToNameMap.containsKey(oldStr) && hisIdList.contains(hisId)) {
                        Id uId = Id.valueOf(oldStr);
                        hisWrapper.oldValue = userIdToUserNameMapping.get(uId);
                        hisWrapper.oldValueUrl = userIdToUrlMapping.get(uId);
                    }
                    //if old value is of boolean type
                    else if(oldStr != null && his.get('OldValue') instanceOf Boolean) {
                        hisWrapper.isCheckbox=true;
                        hisWrapper.oldValue = oldStr;
                    }
                    //Check for other data types                                                                  
                    else {
                        hisWrapper.oldValue = getValueForOtherDataTypes(oldStr,his.get('OldValue'));
                    }
                    //if new value is a user name
                    
                    if(uidToNameMap.containsKey(newStr) && hisIdList.contains(hisId)) {
                        Id uId = Id.valueOf(newStr);
                        hisWrapper.newValue = userIdToUserNameMapping.get(uId);
                        hisWrapper.newValueUrl = userIdToUrlMapping.get(uId);
                    }
                    //if new value is of boolean type
                    else if(newStr != null && his.get('NewValue') instanceOf Boolean) {hisWrapper.newValue = newStr;
                                                                                      }
                    //Check for other data types 
                    else {
                        hisWrapper.newValue = getValueForOtherDataTypes(newStr,his.get('NewValue'));
                    }
                    newHistList.add(hisWrapper);
                }
            }
        }
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); 
        throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);}
        return newHistList;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static HistoryHeader getHistoryHeader(string objectInfo){
        HistoryHeader hh = new HistoryHeader();
        //setting default lang to English.
        String userLang = 'en_US';
        //Stores the history object name derieved from objectInfo passed.
        string objectName;
        //Stores the translation text for the history header based on user's language.
        Core_MDF_History_Header_Translation__mdt[] langTrans;
        try{
            //Check if the object is a custom object or a standard one.
            //Incase of standard object just append History at end else remove __c and append __History for custom one.
            if(objectInfo.contains('__c')) 
            {objectName= objectInfo.substringBefore('__c')+'__History';} 
            else
            {objectName= objectInfo+'History';}
                //Get the label value for the history object.
                List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectName}); // this can accept list of strings, we describe only one object here
                String objectLabel = describeSobjectsResult[0].getLabel();
                if(String.isNotBlank(objectLabel)){

                
                //Check if the label contains : then spilt and save otherwise save null.
                String[] customHeader = objectLabel.contains(':') ? objectLabel.split(':') : null; 
                //Set the history header to include history at end with the object name for custom object else just show the object label for the standard object.
                hh.objectName= (customHeader != null) ? (customHeader[1]+' History').trim() : objectLabel.trim();                                  
                //Get the user language.
                userLang = (UserInfo.getLanguage() != null) ? UserInfo.getLanguage() : 'en_US';
                    String query = 'Select toLabel(Core_MDF_History_Header_Translation_nm__c) '+
                        ' from Core_MDF_History_Header_Translation__mdt where Core_MDF_obj_nm__c=\''+
                        String.escapeSingleQuotes(objectInfo)+'\''+' Limit 1';
                    String v1 = query;
                    langTrans=Database.query(v1);
                    if(langTrans.size() > 0){
                        
                        hh.objectName = String.valueOf(langTrans[0].Core_MDF_History_Header_Translation_nm__c);
                    }
                }
                hh.errorMessage = '';
                       
        }
        catch(Exception e) {
            if(e.getMessage().contains('Invalid sobject provided')){
                hh.objectName = Label.Core_MDF_History;
                hh.errorMessage = Label.Core_MDF_Invalid_Sobject_Error;
            }
            else{
                hh.errorMessage = Label.Core_MDF_ApplicationErrorMessage;
                Core_MDF_CCP_UtilityClass.logError(e);
            }
           
        }
        return hh;
    }
    
    
    public class History {
        @AuraEnabled public String id  { get; set; }
        @AuraEnabled public String createdDate  { get; set; }
        @AuraEnabled public String field { get; set; }
        @AuraEnabled public String user { get; set; }
        @AuraEnabled public String oldValue          { get; set; }
        @AuraEnabled public String newValue           { get; set; }
        @AuraEnabled public String userUrl           { get; set; }
        @AuraEnabled public String oldValueUrl           { get; set; }
        @AuraEnabled public String newValueUrl           { get; set; }
        @AuraEnabled public Boolean isCheckbox           { get; set; }
    }
    
    public class HistoryHeader {
        @AuraEnabled public String objectName  { get; set; }
        @AuraEnabled public String errorMessage {get; set; }
    }
    
    public without sharing class Core_MDF_HistoryUtility{
        public Map<Id,User> getUserDetails(List<String> valueList){
            Map<Id,User> userIdTouserTypeMap = new Map<Id,User>();
            for(User u : [SELECT Id,name,UserType FROM User where ID IN:valueList])
            {
                userIdTouserTypeMap.put(u.Id, u);
                userNames.add(u.name);
            }
            return userIdTouserTypeMap;
        }
        
    }
}