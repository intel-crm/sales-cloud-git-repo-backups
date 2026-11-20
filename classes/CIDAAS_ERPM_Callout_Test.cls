@isTest
public class CIDAAS_ERPM_Callout_Test {
    
    @testSetup 
    public static void DataSetup() {
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'Resource & Design Center for Secure Content';
        ent.Core_Display_Name__c = 'RDC Entitlement';
        insert ent;      
        
        ChannelProgram iqrProgram = new ChannelProgram();
        iqrProgram.Name='Intel Quote Request';
        iqrProgram.PRM_programCode__c='IQR';
        insert iqrProgram;
    }
    
    @isTest 
    public static void InsertRegRequestDZP() {
        Core_Entitlement__c entt = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id accountCreateRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.RecordTypeId=accountCreateRT;
        regRequest.Name= 'RDCAck2';
        regRequest.PRM_First_Name__c= 'RDCAck2';
        regRequest.PRM_Last_Name__c= 'RDCAck2';
        regRequest.PRM_Email_ID__c= 'test_rdcuser44@mailinator.com';
        regRequest.Entitlement_Details__c= entt.Id;
        regRequest.PRM_Person_Phone_Number__c= '323253';
        regRequest.PRM_Preferred_Language__c= 'ENG';
        regRequest.PRM_Profession__c = 'CONSULTANT';
        regRequest.PRM_Job_Function__c  = 'CONSLT' ; 
        regRequest.PRM_Address_Line_1__c= '470 Potrero Ave';
        regRequest.PRM_City__c= 'Bangalore';
        regRequest.PRM_Country__c= 'IN';
        regRequest.PRM_Subscriptions__c = 'IDEV_sub1';
        
        Test.startTest();
        insert regRequest;
        Test.stopTest();
    }
    
    @isTest 
    public static void InsertRegRequestDZPGenPayloadExecp() {
        Core_Entitlement__c entt = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id accountCreateRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.RecordTypeId=accountCreateRT;
        regRequest.Name= 'RDCAck2Exception';
        regRequest.PRM_First_Name__c= 'RDCAck2';
        regRequest.PRM_Last_Name__c= 'RDCAck2';
        regRequest.PRM_Email_ID__c= 'test_rdcuser44@mailinator.com';
        regRequest.Entitlement_Details__c= entt.Id;
        regRequest.PRM_Person_Phone_Number__c= '323253';
        regRequest.PRM_Preferred_Language__c= 'ENG';
        regRequest.PRM_Profession__c = 'CONSULTANT';
        regRequest.PRM_Job_Function__c  = 'CONSLT' ; 
        regRequest.PRM_Address_Line_1__c= '470 Potrero Ave';
        regRequest.PRM_City__c= 'Bangalore';
        regRequest.PRM_Country__c= 'IN';
        
        Test.startTest();
        insert regRequest;
        Test.stopTest();
    }
    
    @isTest
    public static void InsertReqRequestIQR() {
        ChannelProgram cp1 = [Select Id from ChannelProgram where Name = 'Intel Quote Request' LIMIT 1];
        Id accountCreateRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.RecordTypeId=accountCreateRT;
        regRequest.Name= 'RDCAck2';
        regRequest.PRM_First_Name__c= 'RDCAck2';
        regRequest.PRM_Last_Name__c= 'RDCAck2';
        regRequest.PRM_Email_ID__c= 'test_rdcuser44@mailinator.com';
        regRequest.PRM_Channel_Program__c = cp1.Id;
        regRequest.PRM_Person_Phone_Number__c= '323253';
        regRequest.PRM_Preferred_Language__c= 'ENG';
        regRequest.PRM_Profession__c = 'CONSULTANT';
        regRequest.PRM_Job_Function__c  = 'CONSLT' ; 
        regRequest.PRM_Address_Line_1__c= '470 Potrero Ave';
        regRequest.PRM_City__c= 'Bangalore';
        regRequest.PRM_Country__c= 'IN';
        
        Test.startTest();
        insert regRequest;
        Test.stopTest();
    }

}