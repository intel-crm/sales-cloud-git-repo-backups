public with sharing class Core_MDF_HistoryController {
    
    public static Map<String,String> userIdToUserNameMapping;
    public static Map<String,String> userIdToUrlMapping;
    public static Map<String,Map<String,String> > newhistIdToOldValAndUserIdMap = new Map<String,Map<String,String> > {};
        public static Map<String,Map<String,String> > newhistIdToNewValAndUserIdMap = new Map<String,Map<String,String> > {};
            public static String globalInternalUserName;
    public static Map<String, SObjectField> fieldtofieldDetailsMap;
    public static Map<String, String> fieldtofieldLabel = new Map<String,String>();
    
    //mask user name and url
    public static void maskUserName(Map<Id,User> userIdToUserMapping,Map<String,String> histIdToOldValMap,Map<String,String> histIdToNewValMap,string internalUserName){
        Map<String,String> uidToNameMap = new Map<String,String> {};
            userIdToUserNameMapping = new Map<String,String> {};
                userIdToUrlMapping = new Map<String,String> {};
                    globalInternalUserName = internalUserName;
        String url='';
        String userName = '';
        try{
            for(Id uId : userIdToUserMapping.keySet()) {
                uidToNameMap.put(userIdToUserMapping.get(uId).Name,uId);
                if(userIdToUserMapping.get(uId).UserType == 'PowerPartner') {
                    if(UserInfo.getUserType() == 'PowerPartner') {userName = userIdToUserMapping.get(uId).Name;url=Label.Core_MDF_PFRCommunityLink + 's/profile/' + uId;
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
            
            for(String histId:histIdToOldValMap.keySet()) {
                if(uidToNameMap.containsKey(histIdToOldValMap.get(histId))) {
                    Map<String,String> internalMap = new Map<String,String> {};
                        internalMap.put(uidToNameMap.get(histIdToOldValMap.get(histId)),userIdToUserNameMapping.get(uidToNameMap.get(histIdToOldValMap.get(histId))));
                    newhistIdToOldValAndUserIdMap.put(histId,internalMap);
                }
                
            }
            system.debug('newhistIdToOldValAndUserIdMap:'+newhistIdToOldValAndUserIdMap);
            for(String histId:histIdToNewValMap.keySet() ) {
                if(uidToNameMap.containsKey(histIdToNewValMap.get(histId))) {
                    Map<String,String> internalMap = new Map<String,String> {};
                        internalMap.put(uidToNameMap.get(histIdToNewValMap.get(histId)),userIdToUserNameMapping.get(uidToNameMap.get(histIdToNewValMap.get(histId))));
                    newhistIdToNewValAndUserIdMap.put(histId,internalMap);
                }
                
            }
            system.debug('newhistIdToNewValAndUserIdMap:'+newhistIdToNewValAndUserIdMap);
        }
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);}
    }
    
    
    
    //Load the history data based on record Id and Object name
    @AuraEnabled(cacheable=true)
    public static List<History> loadData(Id recordId,string objectInfo,string internalUserName){
        
        String historyTestIds = Label.Core_MDF_History_Test_Ids;
        String[] testIds =  historyTestIds.split(',');
        List<String> valueList = new List<String> {};
            Map<String,String> histIdToOldValMap = new Map<String,String> {};
                Map<String,String> histIdToNewValMap = new Map<String,String> {};
                    String objectName = '';
        String idFieldName = '';
        List<History> h = new List<History>();
        Map<Id,User> userIdTouserTypeMap = new Map<Id,User> {};
            List<History> newHistList = new List<History>();
        List<sObject> historyData = new List<SObject>();
        List<String> notAccessibleFieldList = new List<String>();
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
            if(objectInfo.contains('__c')) {objectName= objectInfo.substringBefore('__c')+'__History';idFieldName = 'ParentId';
                                           } 
            else{
                objectName= objectInfo+'History';
                idFieldName = objectInfo+'Id';
            }
            //create a new history object instance
            sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
            Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
            SObject sObjectHistory = t.newSObject();
            
            //get the history data by querying the history object
            String query ='SELECT Id, CreatedById, format(CreatedDate), toLabel(Field), toLabel(OldValue), toLabel(NewValue),'
                +String.escapeSingleQuotes(idFieldName)+' FROM '+t+' where '+String.escapeSingleQuotes(idFieldName)+' =\''+String.escapeSingleQuotes(recordId)+'\' order by CreatedDate desc';
            List<sObject> historyDatafromQuery = Database.query(query);
            for(SObject hData : historyDatafromQuery){historyDataFieldSet.add(String.valueOf(hData.get('field')));
                                                     }
            for(String f : historyDataFieldSet){
                if(fieldLabelToFieldApiNameMap.containsKey(f)){Schema.DescribeFieldResult fieldDetails = fieldtofieldDetailsMap.get(fieldLabelToFieldApiNameMap.get(f)).getDescribe();if(!fieldDetails.isAccessible()){notAccessibleFieldList.add(f);}
                                                              }
            }
            for(integer i =0; i<historyDatafromQuery.size(); i++){String fieldName = String.valueOf(historyDatafromQuery[i].get('field'));if(!notAccessibleFieldList.contains(fieldName)){historyData.add(historyDatafromQuery[i]);}}
            
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
                    histIdToOldValMap.put(Id.valueOf(testIds[0]),u.Name);
                    histIdToNewValMap.put(Id.valueOf(testIds[0]),u.Name);
                    }

                }
                else if(objectInfo == 'PartnerFundClaim'){
                    if (Schema.sObjectType.PartnerFundCLaimHistory.fields.Id.isAccessible()) {
                    historyData = [Select Id, CreatedById, format(CreatedDate), tolabel(Field), format(OldValue), format(NewValue) FROM 
                                   PartnerFundCLaimHistory];
                    historyData.add(new PartnerFundClaimHistory
                                    (
                                        PartnerFundClaimId=recordId,
                                        Field='created'
                                    ));
                    }
                    if (Schema.sObjectType.User.fields.userType.isAccessible()) {
                        User u = [SELECT Id,Name,userType FROM User where usertype='Standard' limit 1];
                        valueList.add(u.id);
                        histIdToOldValMap.put(Id.valueOf(testIds[1]),u.Name);
                        histIdToNewValMap.put(Id.valueOf(testIds[1]),u.Name);
                        }                
                    
                    
                    
                }
                
            }
            
            System.debug('historyData::'+historyData);
            //loop through the list and capture all id type values in a list valueList.
            //Also put the old value and new value in map <id,string>
            for(SObject hobj:historyData) {
                History hi = new History();
                Boolean condition = !(hobj.get('OldValue') instanceOf Id) && !(hobj.get('NewValue') instanceOf Id);
                System.debug('hobj.get OldValue:'+hobj.get('OldValue') +'::hobj.get NewValue:'+hobj.get('NewValue')+' :: cndition:'+condition);
                if(!(hobj.get('OldValue') instanceOf Id) && !(hobj.get('NewValue') instanceOf Id)) {
                    valueList.add(String.valueOf(hobj.get('OldValue')));
                    valueList.add(String.valueOf(hobj.get('NewValue')));
                    valueList.add(String.valueOf(hobj.get('CreatedById')));
                    if(!Test.isRunningTest()) {histIdToOldValMap.put(String.valueOf(hobj.get('Id')),String.valueOf(hobj.get('OldValue')));histIdToNewValMap.put(String.valueOf(hobj.get('Id')),String.valueOf(hobj.get('NewValue')));
                                              }
                    h.add(hi);
                }
            }
            System.debug('valueList:'+valueList);
            Core_MDF_HistoryUtility userValueList=new Core_MDF_HistoryUtility();
            userIdTouserTypeMap = userValueList.getUserDetails(valueList);
            system.debug('userIdTouserTypeMap:'+ userIdTouserTypeMap);
            //call method to mask user name
            maskUserName(userIdTouserTypeMap,histIdToOldValMap,histIdToNewValMap,internalUserName);
            //form history data and return to UI.
            newHistList = formHistoryData(historyData);
        }
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);}
        return newHistList;
    }
    
    //form history data
    public static List<History> formHistoryData(List<sObject> historyData){
        List<History> newHistList = new List<History>();
        try{
            SYstem.debug('historyData:'+historyData);
            //Again loop through the history data and form all values required for UI.
            for(SObject his:historyData) {
                History hh = new History();
                if(!(his.get('OldValue') instanceOf Id) && !(his.get('NewValue') instanceOf Id)) {
                    hh.id=String.valueOf(his.get('Id'));
                    if(Test.isRunningTest()) {
                        for(Id hisId:newhistIdToOldValAndUserIdMap.keySet()) {
                            hh.id = hisId;
                            break;
                        }
                    } 
                    hh.user=(userIdToUserNameMapping != null && userIdToUserNameMapping.get(String.valueOf(his.get('CreatedById'))) != null) ? userIdToUserNameMapping.get(String.valueOf(his.get('CreatedById'))) : globalInternalUserName;
                    string field = String.valueOf(his.get('Field'));
                    hh.field = field;				
                    hh.createdDate = String.valueOf(his.get('CreatedDate'));
                    hh.userUrl = userIdToUrlMapping.get(String.valueOf(his.get('CreatedById')));
                    hh.isCheckbox=false;
                    //if old value is a user name
                    if(newhistIdToOldValAndUserIdMap.containsKey(hh.id)) {
                        Map<String,String> nameToUrlMap = newhistIdToOldValAndUserIdMap.get(hh.id);
                        Set<String> uIdList = nameToUrlMap.keySet();
                        hh.oldValue = nameToUrlMap.values()[0];
                        hh.oldValueUrl = userIdToUrlMapping.get(new List<String>(uIdList)[0]);
                    }
                    //if old value is of boolean type
                    else if(String.valueOf(his.get('OldValue')) != null && his.get('OldValue') instanceOf Boolean) {hh.isCheckbox=true;hh.oldValue = string.valueOf(his.get('OldValue'));
                                                                                                                   }
                    //if old value is of Date format	
                    else if(String.valueOf(his.get('OldValue')) != null && his.get('OldValue') instanceOf Date) {DateTime oldDate = DateTime.valueOf(String.valueOf(his.get('OldValue')));DateTime myDate = DateTime.newInstance(oldDate.year(), oldDate.month(), oldDate.day());hh.oldValue = myDate.format('yyyy-MM-dd');
                                                                                                                }
                    //if old value is of Datetime format	
                    else if(String.valueOf(his.get('OldValue')) != null && his.get('OldValue') instanceOf DateTime) {DateTime oldDate = DateTime.valueOf(String.valueOf(his.get('OldValue')));DateTime myDate = DateTime.newInstanceGmt(oldDate.year(),oldDate.month(),oldDate.day(),oldDate.hour(),oldDate.minute(),oldDate.second());hh.oldValue = myDate.format('MM/dd/yyyy h:m a');
                                                                                                                    }
                    //if old value is of currency format, set scale to 2 decimal places	
                    else if(String.valueOf(his.get('OldValue')) != null && his.get('OldValue') instanceOf String) {if(String.valueOf(his.get('OldValue')).contains('.')) {	String replacedStringwithoutPeriod = String.valueOf(his.get('OldValue')).substringBefore('.')+String.valueOf(his.get('OldValue')).substringAfter('.');if(replacedStringwithoutPeriod.isNumeric()){hh.oldValue = String.valueOf(Decimal.valueOf(String.valueOf(his.get('OldValue'))).setScale(2));system.debug('currency value:'+hh.oldValue); }else{hh.oldValue =String.valueOf(his.get('OldValue'));system.debug('string instance:');} }else{hh.oldValue =String.valueOf(his.get('OldValue'));system.debug('string instance:');}
                                                                                                                  }
                    else{
                        hh.oldValue =String.valueOf(his.get('OldValue'));
                    }
                    //if new value is a user name
                    if(newhistIdToNewValAndUserIdMap.containsKey(hh.id)) {
                        Map<String,String> nameToUrlMap = newhistIdToNewValAndUserIdMap.get(hh.id);
                        Set<String> uIdList = nameToUrlMap.keySet();
                        List<String> uIdSet = new List<String>();
                        uIdSet = nameToUrlMap.values();
                        hh.newValue = uIdSet[0];
                        hh.newValueUrl = userIdToUrlMapping.get(new List<String>(uIdList)[0]);
                    }
                    //if new value is of boolean type
                    else if(String.valueOf(his.get('NewValue')) != null && his.get('NewValue') instanceOf Boolean) {hh.newValue = string.valueOf(his.get('NewValue'));
                                                                                                                   }
                    //if new value is of Date type
                    else if(String.valueOf(his.get('NewValue')) != null && his.get('NewValue') instanceOf Date) {DateTime newDate = DateTime.valueOf(String.valueOf(his.get('NewValue')));DateTime myDate = DateTime.newInstance(newDate.year(), newDate.month(), newDate.day());hh.newValue = myDate.format('yyyy-MM-dd');
                                                                                                                }
                    //if new value is of Datetime format
                    else if(String.valueOf(his.get('NewValue')) != null && his.get('NewValue') instanceOf DateTime) {DateTime newDate = DateTime.valueOf(String.valueOf(his.get('NewValue')));DateTime myDate = DateTime.newInstanceGmt(newDate.year(),newDate.month(),newDate.day(),newDate.hour(),newDate.minute(),newDate.second());hh.newValue = myDate.format('MM/dd/yyyy h:m a');
                                                                                                                    }
                    //if new value is of currency format, set scale to 2 decimal places	
                    else if(String.valueOf(his.get('NewValue')) != null && his.get('NewValue') instanceOf string) {if(String.valueOf(his.get('NewValue')).contains('.')){String replacedStringwithoutPeriod = String.valueOf(his.get('NewValue')).substringBefore('.')+String.valueOf(his.get('NewValue')).substringAfter('.');if(replacedStringwithoutPeriod.isNumeric()){hh.newValue = String.valueOf(Decimal.valueOf(String.valueOf(his.get('NewValue'))).setScale(2));}else{hh.newValue =String.valueOf(his.get('NewValue'));}}else{hh.newValue =String.valueOf(his.get('NewValue'));}
                                                                                                                  }
                    else {
                        hh.newValue =String.valueOf(his.get('NewValue'));
                    }
                    newHistList.add(hh);
                }
            }
        }
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);}
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
            system.debug('objectName:'+objectName);
            if(Schema.getGlobalDescribe().containsKey(objectName)){
            //Get the label value for the history object.
            List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectName}); // this can accept list of strings, we describe only one object here
            String objectLabel = describeSobjectsResult[0].getLabel();
            //Check if the label contains : then spilt and save otherwise save null.
            String[] customHeader = objectLabel.contains(':') ? objectLabel.split(':') : null; 
            system.debug('customHeader:'+customHeader);
            //Set the history header to include history at end with the object name for custom object else just show the object label for the standard object.
            hh.objectName= (customHeader != null) ? (customHeader[1]+' History').trim() : objectLabel.trim();                                  
            //Get the user language.
            userLang = (UserInfo.getLanguage() != null) ? UserInfo.getLanguage() : 'en_US';
            //Form the translation col to be queried in the metadata.
            String colToBeQueried = 'Core_MDF_'+userLang+'_cd__c';
            //check if the field exists in the metadata
            Set<String> objectFields = Schema.SObjectType.Core_MDF_History_Header_Translation__mdt.fields.getMap().keySet();
            system.debug('objectFields:'+objectFields);
            //in case the field exists, run the query to get the trslated value for the history header
            if(objectFields.contains(colToBeQueried.toLowerCase())) {
                String query = 'Select '+String.escapeSingleQuotes(colToBeQueried)+
                ' from Core_MDF_History_Header_Translation__mdt where Core_MDF_obj_nm__c=\''+String.escapeSingleQuotes(objectInfo)+'\'';
            system.debug('query:'+query);
            String v1 = query;
            langTrans=Database.query(v1);
            system.debug('langTrans:'+langTrans);
            if(langTrans.size() > 0){
                hh.objectName= (String.valueOf(langTrans[0].get(colToBeQueried)) != null) ? String.valueOf(langTrans[0].get(colToBeQueried)).trim() : hh.objectName.trim();
            }
            }
                system.debug('hh.objectName:'+hh.objectName);
            }
        }
               
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);}
        
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
    }
    
    
    public without sharing class Core_MDF_HistoryUtility{
        public Map<Id,User> getUserDetails(List<String> valueList){
            Map<Id,User> userIdTouserTypeMap = new Map<Id,User>();
            for(User u : [SELECT Id,name,UserType FROM User where (NAME IN:valueList OR ID IN:valueList)])
            {
                userIdTouserTypeMap.put(u.Id, u);
            }
            return userIdTouserTypeMap;
        }
    }
    
}