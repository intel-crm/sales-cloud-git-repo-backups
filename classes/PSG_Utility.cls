/****************************************************************************************************
Apex Class Name : PSG_Utility
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Utility class for PSG operations.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                     01/05/2021               Created
*****************************************************************************************************/
public without Sharing class PSG_Utility {
    /************************************************************************************************************
	*Method Name : syncQuoteStatus
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : Updates the status of the Quote.
	************************************************************************************************************/
    public static void syncQuoteStatus(Id quoteId, String quoteStatus){
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Id = quoteId;
        quote.SBQQ__Status__c = quoteStatus;
        update quote;
    }
    
    /************************************************************************************************************
	*Method Name : getLoginUserType
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : get the type of logged in user.
	************************************************************************************************************/
    public static String getLoginUserType(Id userId){
        Boolean isDisty = false;
        String loginUserType;
        Boolean isInternal;
        for(PermissionSetAssignment psaInternal : [SELECT Id,PermissionSet.Name,PermissionSet.Profile.Name,Assignee.Contact.AccountId FROM PermissionSetAssignment
                                                   WHERE AssigneeId = : userId AND 
                                                   (PermissionSet.Name =:Label.PSG_Quote_SOS_PermissionSet OR 
                                                    PermissionSet.Name =:Label.PSG_Quote_BO_PermissionSet OR 
                                                    PermissionSet.Name =:Label.PSG_Quote_BM_PermissionSet OR 
                                                    PermissionSet.Name =:Label.PSG_PermissionSets_PSG_Distributor OR
                                                    PermissionSet.ProfileId =:Userinfo.getProfileId())]){
                                                        if(psaInternal.PermissionSet.Name == Label.PSG_PermissionSets_PSG_Distributor){
                                                            isDisty = true;
                                                            loginUserType = psaInternal.PermissionSet.Name;
                                                        }else {
                                                            if (!isDisty){                        
                                                                isInternal = true;
                                                                if(psaInternal.PermissionSet.ProfileId != null && psaInternal.PermissionSet.Profile.Name == 'System Administrator'){
                                                                    loginUserType = 'System Administrator';
                                                                }                                                               
                                                                if(psaInternal.PermissionSet.Name == Label.PSG_Quote_SOS_PermissionSet){
                                                                    loginUserType = psaInternal.PermissionSet.Name;
                                                                }else if(psaInternal.PermissionSet.Name == Label.PSG_Quote_BM_PermissionSet){
                                                                    loginUserType = psaInternal.PermissionSet.Name;
                                                                }else if(psaInternal.PermissionSet.Name == Label.PSG_Quote_BO_PermissionSet){
                                                                    loginUserType = psaInternal.PermissionSet.Name;
                                                                }
                                                            }
                                                        }
                                                    }
        
        return loginUserType;
    }
    
    /************************************************************************************************************
	*Method Name : getRecordTypeId
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : Returns the Id of respected object and recordtype.
	************************************************************************************************************/
    public static Id getRecordTypeId(String objectName,String recordTypeName){
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = new Map<String,Schema.RecordTypeInfo>();
        Id recTypeId;
        sObject obj;
        
        SObjectType r = ((SObject)Type.forName('Schema',objectName).newInstance()).getSObjectType();
        recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        return recTypeId; 
        /*Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        
        if(objType != null){
            obj = objType.newsObject();  
            Schema.DescribeSObjectResult sObjDesc = obj.getSObjectType().getDescribe(); 
            
            if(sObjDesc != null){  
                recordTypeInfoMap = sObjDesc.getRecordTypeInfosByDeveloperName();  
            }
            
            if(recordTypeInfoMap.containsKey(recordTypeName)){
                recTypeId = recordTypeInfoMap.get(recordTypeName).getRecordTypeId();
                return recTypeId;
            }
        }        
        return null;*/
    }
    
    /************************************************************************************************************
	*Method Name : getUserPemissionSets
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : Returns all the permission sets assigned to the user.
	************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<PermissionSetAssignment> getUserPemissionSets(String userId){
        List<PermissionSetAssignment> userPermissionSets = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE Assigneeid = : userId];
        return userPermissionSets;
    }
    
    /************************************************************************************************************
	*Method Name : getUserInformation
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : Returns logged in user details.
	************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static user getUserInformation(){
        Set < Id > permissionSetIds = new Set < Id >();  
        List < User > userList = new List < User >();  
        for ( SetupEntityAccess access : [ SELECT ParentId FROM SetupEntityAccess WHERE SetupEntityId IN ( SELECT Id FROM CustomPermission WHERE DeveloperName = 'PSG_External_Disty' )]){   
            permissionSetIds.add(access.ParentId);                                                                                                 
        }
        userList=[SELECT Id ,Name,Account.Name ,Email, Account.Core_Geo__c  FROM User WHERE  Id IN (SELECT AssigneeId FROM PermissionSetAssignment  WHERE PermissionSetId IN :permissionSetIds AND AssigneeId =: UserInfo.getUserId())];
        if(!userList.isempty()){
            return userList[0];
        }
        else{
            return null;
        }
    }
    
    /************************************************************************************************************
	*Method Name : logError
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : creates log record for the exception.
	************************************************************************************************************/
    public static void logError(Exception e){
        String exceptionType = e.getTypeName();
        Id exceptionRecordId;
        if(exceptionType.equals('System.DmlException')){
            exceptionRecordId =  getRecordId(e);
        }
        logErrorinLogObject(getErrorDetails(e), e.getStackTraceString().substringBefore(':'),exceptionRecordId);
    }
    
    /************************************************************************************************************
	*Method Name : getRecordId
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : Returns record id present in the exception.
	************************************************************************************************************/
    public static Id getRecordId (Exception e) {
        Id recordId;
        for (Integer i = 0; i < e.getNumDml(); i++){
            recordId = e.getDmlId(i); 
        }
        return recordId;  
    }
    
    /************************************************************************************************************
	*Method Name : logErrorinLogObject
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : create log entries.
	************************************************************************************************************/
    public static void logErrorinLogObject(string errorMessage,string objectName, Id recordId){
        String sObjType;
        if(recordId!=null){
            sObjType = recordId.getSObjectType().getDescribe().getName();
        }
        String subject = Label.PSG_Support_Email_Subject + ' ' +  objectName;
        Map<String, String> coreLogMap = new Map<String, String>();
        coreLogMap.put('Core_Details__c', errorMessage);
        coreLogMap.put('Core_Message__c', Label.PSG_SFDC_Environment + ': ' + subject);
        coreLogMap.put('Core_Origin__c', Label.PSG_Program_Name);
        coreLogMap.put('Core_Project__c',Label.PSG_Program_Name);
        coreLogMap.put('Core_Scope__c',objectName);
        coreLogMap.put('Core_Severity__c', 'Critical');
        coreLogMap.put('Core_Support_Email__c', Label.Pricing_IQR_Support_Email);//to be modified as per PSG
        coreLogMap.put('Core_Support_Link__c', Label.PSG_Support_Link);
        coreLogMap.put('Core_Tags__c', '') ;
        coreLogMap.put('Core_sObjectId__c', recordId);
        if( sObjType!=null){
            coreLogMap.put('Core_sObjectType__c', sObjType) ;
        }
        createLogEntry(coreLogMap);
    }
    
    /************************************************************************************************************
	*Method Name : createLogEntry
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : create log entries.
	************************************************************************************************************/
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
            PSG_Utility.logError(e);
            throw e;
        }
        return null;    
    }  
    
    /************************************************************************************************************
	*Method Name : getErrorDetails
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : Returns error details from the exception.
	************************************************************************************************************/
    public static String getErrorDetails(Exception e){
        return 'Class & Method Name = ' + e.getStackTraceString().substringBefore(':') + ';\n' +
            'Exception Message = ' + e.getMessage() + ';\n' +
            'LineNumber = ' + String.valueOf(e.getLineNumber()) + ';\n' +
            'StackTrace = ' + e.getStackTraceString() + ';\n' +
            'Logged in user = ' + UserInfo.getName();
        
    }
    
    /************************************************************************************************************
	*Method Name : createPSGLogEntry
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : create PSG log entry record.
	************************************************************************************************************/
    public static void createPSGLogEntry(String className,String methodName,String message,String details,String sObjectName,String Severity,String logType,String sObjectId,String sObjectType,String sObjectRecord){
        core_cpq_psg_log_entry__c le=new core_cpq_psg_log_entry__c();
        le.core_cpq_class_name__c=className;
        le.core_cpq_method_name__c=methodName;
        le.core_cpq_severity__c=Severity;
        le.core_cpq_sobjectname__c=sObjectName;
        le.core_cpq_message__c=message;
        le.core_cpq_details__c=details;
        le.core_cpq_when__c=System.now();
        le.core_cpq_type__c=logType;
        le.core_cpq_sobjectid__c=sObjectId;
        le.core_cpq_sObjectType__c=sObjectType;
        le.core_cpq_sObjectRecord__c=sObjectRecord;
        insert le;
    }
    
    /************************************************************************************************************
	*Method Name : createCoreLogEntry
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : Creates core log entry record.
	************************************************************************************************************/
    public static void createCoreLogEntry(String className,String methodName,String message,String details,String sObjectName,String Severity,String sObjectId){
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
    @AuraEnabled(cacheable=true)
    public static boolean createProactiveAlert(String dpaId){
        boolean hasalert=false;
        if(dpaId!=null){
            List<core_cpq_dpa_aln_line__c> dpaobj=[SELECT id from core_cpq_dpa_aln_line__c  WHERE core_cpq_dollar_change_flag__c=true AND core_cpq_cis_no_nbr__c=:dpaId];
            if(dpaobj.size()>0){
                hasalert=true;
            }
        }
        return hasalert;
    }
}