/**
* @description       : Utlity class for Software & Services
* @author            : Prasad
* @group             : Software & Services
* @last modified on  : 9-04-2024
* @last modified by  : Prasad
**/

public without sharing class Pricing_SW_Utility {
    // Generic method to get the Id of a record type by passing objectName and recordTypeName
    public static id getRecordTypeId(String objectName,String recordTypeName){
        Id recTypeId;

        SObjectType r = ((SObject)Type.forName('Schema',objectName).newInstance()).getSObjectType();
        recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        return recTypeId;
    }

    // Creates core log entry record	
    public static void createCoreLogEntry(String className,String programName, String methodName,String message,String details,String sObjectName,String Severity,String sObjectId){
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
        objCLE.Core_Origin__c=className;
        objCLE.Core_Project__c=programName;
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