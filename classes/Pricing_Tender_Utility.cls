/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-28-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_Tender_Utility
{
    //Generic method to get the Id of a recrd type by passing
    //object name and record type name
    public static id getRecordTypeId(String objectName,String recordTypeName){
        Id recTypeId;

        SObjectType r = ((SObject)Type.forName('Schema',objectName).newInstance()).getSObjectType();
        recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        return recTypeId;
    }
    
    /***************************************************************************************************** 
    Method Name:        getErrorDetails
    @return  :          String
    @parameters:        Exception - This will contain the Exception that is caught in various other classes. This 
                        will be called from the logError method.
    Description:        Whenever an exception is passed as an argument, it will fetch all the details from the 
                        Exception and return the formed String.
    Added By:           Biswa - 11/06/2020
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static String getErrorDetails(Exception e){
        return 'Class & Method Name = ' + e.getStackTraceString().substringBefore(':') + ';\n' +
               'Exception Message = ' + e.getMessage() + ';\n' +
               'LineNumber = ' + String.valueOf(e.getLineNumber()) + ';\n' +
               'StackTrace = ' + e.getStackTraceString() + ';\n' +
               'Logged in user = ' + UserInfo.getName();
        	    
    }
    
    /***************************************************************************************************** 
    Method Name:        logError
    @return  :          void
    @parameters:        Exception - This will contain the Exception that is caught in various other classes.
    Description:        Whenever an exception is passed as an argument, it will call the getErrorDetails method and
                        pass the string returned to create the Log Entry record through the logErrorinLogObject method.
    Added By:           Biswa - 11/06/2020
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void logError(Exception e){
        String exceptionType = e.getTypeName();
        Id exceptionRecordId;
        if(exceptionType.equals('System.DmlException')){
            exceptionRecordId =  getRecordId(e);
        }
        logErrorinLogObject(getErrorDetails(e), e.getStackTraceString().substringBefore(':'),exceptionRecordId);
    }
    public static void logError(Exception e, String sObjectId){
 
        Id exceptionRecordId;
        exceptionRecordId = Id.valueOf(sObjectId);
        logErrorinLogObject(getErrorDetails(e), e.getStackTraceString().substringBefore(':'),exceptionRecordId);
    }
    
    public static String getExceptionMessage(Exception e){
        String resp = '';
        String msg = e.getMessage();
        String FIELD_VALIDATION = Label.Pricing_Custom_Log_Entry_Exception_Label;
        if(msg.contains(FIELD_VALIDATION)){
             String[] errorMsg = msg.split(FIELD_VALIDATION); 
             String rightStr = errorMsg[1].right(errorMsg[1].indexOf('.:'));               
             resp = errorMsg[1].left(rightStr.length()).trim()+'.';
        }
        return resp;
    }

    public static Pricing_QuoteLineCloneController.GlobalVariables handleError(Pricing_QuoteLineCloneController.GlobalVariables globalVar, Exception error, String errMsg, String sObjectId, String quoteLineNumber){
        String retMsg = Pricing_Tender_Utility.getExceptionMessage(error);
        Pricing_Tender_Utility.logError(error, sObjectId);
        if(retMsg != ''){
            globalVar.messageResult = retMsg;
        }
        else{
            String msg = error.getMessage();
            globalVar.messageResult = msg.contains('DUPLICATE_VALUE') ? (Label.Pricing_Tender_CR_Existing_Request_Error).replace('${quoteLineNumber}', quoteLineNumber) : JSON.serialize(msg);
        }
        globalVar.quoteLineId = null;
        globalVar.isSuccess = false;
        return globalVar;
    }
    
    //Call Log object to log errors
    public static void logErrorinLogObject(string errorMessage,string objectName, Id recordId){
        String sObjType;
        if(recordId != null) {
            sObjType = recordId.getSObjectType().getDescribe().getName();
        }
        String subject = Label.Pricing_IQR_Support_Email_Subject + ' ' +  objectName + ' ' + 'sObject Id: ' + recordId;
            Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Details__c', errorMessage);
            coreLogMap.put('Core_Message__c', Label.Pricing_IQR_SFDC_Environment + ': ' + subject);
            coreLogMap.put('Core_Origin__c', Label.Pricing_IQR_Program_Name);
            coreLogMap.put('Core_Project__c',Label.Pricing_IQR_Program_Name);
            coreLogMap.put('Core_Scope__c',objectName);
            coreLogMap.put('Core_Severity__c', 'Critical');
            coreLogMap.put('Core_Support_Email__c', Label.Pricing_IQR_Support_Email);
            coreLogMap.put('Core_Support_Link__c', Label.Pricing_IQR_Support_Link);
            coreLogMap.put('Core_Tags__c', '') ;
            coreLogMap.put('Core_sObjectId__c', recordId);
            coreLogMap.put('Core_sObjectType__c', sObjType) ;
        	createLogEntry(coreLogMap);

    }
    
        //Call Log object to log errors for MyDeals Integration
    public static List<Core_Log_Entry__c> logErrorinLogObjectIntegration(Map<String,String> errorMap,Map<String,Id> inboundIdToRecordIdMap, String severity){
        List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
            for(String objectName : errorMap.keySet()){
                String errorMessage= errorMap.get(objectName);
                Id objectId;
                String sObjType;    
                if(!inboundIdToRecordIdMap.isEmpty() && inboundIdToRecordIdMap.containsKey(objectName)){
                    objectId = inboundIdToRecordIdMap.get(objectName);
                    sObjType = objectId.getSObjectType().getDescribe().getName();
                }
                String subject;
                if(severity == 'Critical'){
                   subject = Label.Pricing_IQR_Support_Email_Subject + ' ' + objectName + ' ' + 'sObject Id: ' + objectId;
                }else if(severity == 'Low') {
                    subject = 'Successful' + ' ' +  objectName;
                }
                Map<String, String> coreLogMap = new Map<String, String>();
                coreLogMap.put('Core_Details__c', errorMessage);
                coreLogMap.put('Core_Message__c', Label.Pricing_IQR_SFDC_Environment + ': ' + subject);
                coreLogMap.put('Core_Origin__c', Label.Pricing_MyDeal_Integration_Origin);
                coreLogMap.put('Core_Project__c',Label.Pricing_IQR_Program_Name);
                coreLogMap.put('Core_Scope__c',objectName);
                coreLogMap.put('Core_Severity__c', severity);
                coreLogMap.put('Core_Support_Email__c', Label.Pricing_IQR_Support_Email);
                coreLogMap.put('Core_Support_Link__c', Label.Pricing_IQR_Support_Link);
                coreLogMap.put('Core_Tags__c', '') ;
                coreLogMap.put('Core_sObjectId__c', objectId);
                coreLogMap.put('Core_sObjectType__c', sObjType);
                Core_Log_Entry__c logEntry = createLogEntryIntegration(coreLogMap);
                logEntryList.add(logEntry);
            }
            return logEntryList;
    }
    
        // Create Log Object by passing the logobject field names and values in the Map    
    public static Core_Log_Entry__c createLogEntryIntegration(Map<String, String> coreLogMap){
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
        try {
            
            DateTime dtWhen = system.now();
            Map<String, Schema.SObjectField> logFields = Schema.SObjectType.Core_Log_Entry__c.fields.getMap();
            if(coreLogMap != null && coreLogMap.size() > 0){    
                for(String key:coreLogMap.keySet()){        
                    if(logFields.containsKey(key)){
                        Schema.DescribeFieldResult field= logFields.get(key).getDescribe();    
                        Integer length = field.getLength();
                        String value = String.valueOf(coreLogMap.get(key)); 
                        if(String.isNotBlank(value)){                                           
                            objCLE.put(key, value.left(length));
                        }else{
                            objCLE.put(key, '');
                        }                        
                    }
                }
                
                if(objCLE != null){
                    objCLE.put('Core_When__c',dtWhen);
                    return objCLE;
                }
            }                      
        } catch(Exception e) {
            Pricing_Tender_Utility.logError(e);
        }
        return null;    
    }

    //Call Log object to log errors for PricingAI Integration
    public static List<Core_Log_Entry__c> logErrorinLogObjectPricingAIIntegration(Map<String,String> errorMap,Map<String,Id> inboundIdToRecordIdMap, String severity){
        List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
            for(String objectName : errorMap.keySet()){
                String errorMessage= errorMap.get(objectName);
                Id objectId;
                String sObjType;    
                if(!inboundIdToRecordIdMap.isEmpty() && inboundIdToRecordIdMap.containsKey(objectName)){
                    objectId = inboundIdToRecordIdMap.get(objectName);
                    sObjType = objectId.getSObjectType().getDescribe().getName();
                }
                String subject;
                if(severity == 'Critical'){
                   subject = Label.Pricing_IQR_Support_Email_Subject + ' ' + objectName + ' ' + 'sObject Id: ' + objectId;
                }else if(severity == 'Low') {
                    subject = 'Successful' + ' ' +  objectName;
                }
                Map<String, String> coreLogMap = new Map<String, String>();
                coreLogMap.put('Core_Details__c', errorMessage);
                coreLogMap.put('Core_Message__c', Label.Pricing_IQR_SFDC_Environment + ': ' + subject);
                coreLogMap.put('Core_Origin__c', 'PricingAI-Integration');
                coreLogMap.put('Core_Project__c',Label.Pricing_IQR_Program_Name);
                coreLogMap.put('Core_Scope__c',objectName);
                coreLogMap.put('Core_Severity__c', severity);
                coreLogMap.put('Core_Support_Email__c', Label.Pricing_IQR_Support_Email);
                coreLogMap.put('Core_Support_Link__c', Label.Pricing_IQR_Support_Link);
                coreLogMap.put('Core_Tags__c', '') ;
                coreLogMap.put('Core_sObjectId__c', objectId);
                coreLogMap.put('Core_sObjectType__c', sObjType);
                Core_Log_Entry__c logEntry = createLogEntryIntegration(coreLogMap);
                logEntryList.add(logEntry);
            }
            return logEntryList;
    }

    //Method written to log success or errors for Bulk Account Executive Update on Quote or Bulk Account Executive Insert on Quote Team
    public static List<Core_Log_Entry__c> logErrorinLogObjectBulkUpdateInsertAE(Map<String,String> errorMap,Map<String,Id> inboundIdToRecordIdMap, String severity, String aeAction){
	List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
		for(String objectName : errorMap.keySet()){
			String errorMessage= errorMap.get(objectName);
			Id objectId;
			String sObjType;    
			if(!inboundIdToRecordIdMap.isEmpty() && inboundIdToRecordIdMap.containsKey(objectName)){
				objectId = inboundIdToRecordIdMap.get(objectName);
				sObjType = objectId.getSObjectType().getDescribe().getName();
			}
			String subject;
			if(severity == 'Medium'){
			   subject = Label.Pricing_IQR_Support_Email_Subject + ' ' + objectName + ' in '+Label.Pricing_IQR_SFDC_Environment+'.';
			}else if(severity == 'Low') {
				subject = 'Successfully processed the record:' + ' ' +  objectName;
			}
			Map<String, String> coreLogMap = new Map<String, String>();
			coreLogMap.put('Core_Details__c', errorMessage);
			coreLogMap.put('Core_Message__c', Label.Pricing_IQR_SFDC_Environment + ': ' + subject);
			coreLogMap.put('Core_Origin__c', 'Bulk '+aeAction);
			coreLogMap.put('Core_Project__c',Label.Pricing_IQR_Program_Name);
			coreLogMap.put('Core_Scope__c',objectName);
			coreLogMap.put('Core_Severity__c', severity);
			coreLogMap.put('Core_Support_Email__c', Label.Pricing_IQR_Support_Email);
			coreLogMap.put('Core_Support_Link__c', Label.Pricing_IQR_Support_Link);
			coreLogMap.put('Core_Tags__c', '') ;
			coreLogMap.put('Core_sObjectId__c', objectId);
			coreLogMap.put('Core_sObjectType__c', sObjType);
			Core_Log_Entry__c logEntry = createLogEntryIntegration(coreLogMap);
			logEntryList.add(logEntry);
		}
		return logEntryList;
    }
    
    public static Id getRecordId (Exception e) {
        Id recordId;
        for (Integer i = 0; i < e.getNumDml(); i++){
          recordId = e.getDmlId(i); 
        }
         return recordId;  
    }
    
    // Create Log Object by passing the logobject field names and values in the Map    
    public static String createLogEntry(Map<String, String> coreLogMap){
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
        try {
            
            DateTime dtWhen = system.now();
            Map<String, Schema.SObjectField> logFields = Schema.SObjectType.Core_Log_Entry__c.fields.getMap();
            if(coreLogMap != null && coreLogMap.size() > 0){    
                for(String key:coreLogMap.keySet()){        
                    if(logFields.containsKey(key)){
                        Schema.DescribeFieldResult field= logFields.get(key).getDescribe();    
                        Integer length = field.getLength();
                        String value = String.valueOf(coreLogMap.get(key));                        
                        if(String.isNotBlank(value)){                                           
                            objCLE.put(key, value.left(length));
                        }else{
                            objCLE.put(key, '');
                        }                          
                    }
                }
                
                if(objCLE != null){
                    objCLE.put('Core_When__c',dtWhen);
                    Database.insert(objCLE);
                    return objCLE.id;
                }
            }                      
        } catch(Exception e) {
            Pricing_Tender_Utility.logError(e);
        }
        return null;    
    }  
    
     //Method to validate text fields and return true if Non Latin Characters are present
     public static Boolean validateNonLatinChars(String value) {
        Boolean isNotLatin = false;
        String emailRegex = Label.Pricing_Latin_Characters_Regular_Expr_Label;
        Pattern p = Pattern.compile(emailRegex);
        Matcher m = p.matcher(value);
        if(!m.matches()){
            isNotLatin = true;
        }
        return isNotLatin;
    }

    //Method to get the GUID
    public static String getGUID(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }
    
    // Method to get CIM Id
    public static String getCIMId(String AccId, String exeAccCIMId){
        String cimId;
        Pricing_Account_To_CIM_ID_Mapping__mdt CIMData = Pricing_Account_To_CIM_ID_Mapping__mdt.getInstance('Id_'+AccId);
        if(CIMData!=Null){
            cimId = CIMData.CIM_Id__c;
        }
        else{
            cimId = exeAccCIMId;   
        }
        return cimId;
    } 
    
    /**
    * @description future method to call method to create usage tracking record for bulk actions
    * @author Sandeep | 02-23-2023 
    * @param set<Id> sObjectIds 
    * @param Id parentId 
    * @param String action 
    **/
    @future
    public static void createUsageTrackingLog(Set<Id> sObjectIds,Id parentId,String action){
        try{
            if(!System.isBatch()){
                createUsageTrackingLogforBulkActions(sObjectIds, parentId, action);
            }
        }catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        } 
    }

    /**
    * @description method to create usage tracking record for bulk actions
    * @author Subhanku | 02-07-2023 
    * @param Set<Id> sObjectIds 
    * @param String action 
    **/
    public static void createUsageTrackingLogforBulkActions(Set<Id> sObjectIds,Id parentId,String action)
    {
        List<core_log_entry__c> corelist = new List<core_log_entry__c>();
        core_log_entry__c logEntry = new core_log_entry__c();
        logEntry.Core_sObjectId__c = parentId;
        logEntry.Core_Message__c = 'Bulk '+ action;
        logEntry.Core_Details__c = String.join(new List<Id>(sObjectIds),',');
        logEntry.Core_Origin__c =  'Usage Tracking';
        logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
        logEntry.Core_Severity__c = 'Low';
        logEntry.Core_Support_Email__c = Label.Pricing_IQR_Support_Email;
        logEntry.Core_Support_Link__c = Label.Pricing_IQR_Support_Link;
        logEntry.Core_Scope__c = 'Usage Tracking';
        logEntry.Core_When__c = system.now();
        corelist.add(logEntry);
        insert corelist;   
        
    }
    
    public static void logErrorPricingSW(Exception e){
        String exceptionType = e.getTypeName();
        Id exceptionRecordId;
        if(exceptionType.equals('System.DmlException')){
            exceptionRecordId =  getRecordId(e);
        }
        logErrorinLogObjectPricingSW(getErrorDetails(e), e.getStackTraceString().substringBefore(':'),exceptionRecordId);
    }
    
    
 //Call Log object to log errors
    public static void logErrorinLogObjectPricingSW(string errorMessage,string objectName, Id recordId){
        String sObjType;
        if(recordId != null) {
            sObjType = recordId.getSObjectType().getDescribe().getName();
        }
        String subject = Label.Pricing_IQR_Support_Email_Subject + ' ' +  objectName + ' ' + 'sObject Id: ' + recordId;
            Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Details__c', errorMessage);
            coreLogMap.put('Core_Message__c', Label.Pricing_IQR_SFDC_Environment + ': ' + subject);
            coreLogMap.put('Core_Origin__c', Label.Pricing_sw_LogEntry_Software);
            coreLogMap.put('Core_Project__c',Label.Pricing_IQR_Program_Name);
            coreLogMap.put('Core_Scope__c',objectName);
            coreLogMap.put('Core_Severity__c', 'Critical');
            coreLogMap.put('Core_Support_Email__c', Label.Pricing_IQR_Support_Email);
            coreLogMap.put('Core_Support_Link__c', Label.Pricing_IQR_Support_Link);
            coreLogMap.put('Core_Tags__c', '') ;
            coreLogMap.put('Core_sObjectId__c', recordId);
            coreLogMap.put('Core_sObjectType__c', sObjType) ;
            createLogEntry(coreLogMap);
    } 
    
    public static void createCoreLogEntrySW(String className,String methodName,String message,String details,String sObjectName,String Severity,String sObjectId){
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
        objCLE.Core_Origin__c=className;
        objCLE.Core_Project__c='PSG';
        objCLE.Core_Scope__c=methodName;
        objCLE.Core_Severity__c=Severity;
        objCLE.Core_sObjectType__c=sObjectName;
        objCLE.Core_Message__c=message;
        objCLE.Core_Details__c=details;
        objCLE.Core_When__c=System.now();
        objCLE.Core_sObjectId__c=sObjectId;
        insert objCLE;
    }
}