/******************************************************************************************************************************
Apex Class Name:  PRM_SF2MyIntel_Updates_API_Test
Version     : 1.0 
Created Date: DEC 2021
Function    : Test Class for PRM_SF2MyIntel_Updates_API

Modification Log :
* Developer                     Date                    Description
* ----------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       15/12/2021               Test Class for PRM_SF2MyIntel_Updates_API 
*******************************************************************************************************************************/
@isTest
public class PRM_SF2MyIntel_Updates_API_Test {
    
    @testSetup
    static void setupTestData() {
        Test.startTest();
        Contact testContact = createTestContact();    
        //createCommEnrollRequest();
        Id comEntitlementRecordTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('Community Entitlements').getRecordTypeId();
        List<PRM_VXEnttlmntMatrix__c> entMatrixInertList = new List<PRM_VXEnttlmntMatrix__c>();
        List<Core_Entitlement__c> corEntitInertList = new List<Core_Entitlement__c>();
        
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'IOT Community User';
        ent.Core_Display_Name__c = 'IOT Community User';
        ent.Core_IsActive__c = true;
        corEntitInertList.add(ent);
       
        
        Core_Entitlement__c ent1 = new Core_Entitlement__c();
        ent1.Name = 'Cloud Community User';
        ent1.Core_Display_Name__c = 'Cloud Community User';
        ent1.Core_IsActive__c = true;
        corEntitInertList.add(ent1);
        
        Core_Entitlement__c ent2 = new Core_Entitlement__c();
        ent2.Name = 'FPGA Community User';
        ent2.Core_Display_Name__c = 'FPGA Community User';
        ent2.Core_IsActive__c = true;
        corEntitInertList.add(ent2);
        
        if(corEntitInertList.size() > 0){
            insert corEntitInertList;
        }
        PRM_VXEnttlmntMatrix__c entMatrix = new PRM_VXEnttlmntMatrix__c();
        entMatrix.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix.Communities__c = 'Intel® IOT Solution Partner';
        entMatrix.PRM_Entitlement_Id__c = ent.id;
        entMatrixInertList.add(entMatrix);
        
        PRM_VXEnttlmntMatrix__c entMatrix1 = new PRM_VXEnttlmntMatrix__c();
        entMatrix1.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix1.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix1.Communities__c = 'Intel® Cloud Insider Partner';
        entMatrix1.PRM_Entitlement_Id__c = ent1.id;
        entMatrixInertList.add(entMatrix1);
        
        
        PRM_VXEnttlmntMatrix__c entMatrix2 = new PRM_VXEnttlmntMatrix__c();
        entMatrix2.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix2.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix2.Communities__c = 'Intel® FPGA Partner';
        entMatrix2.PRM_Entitlement_Id__c = ent2.id;
        entMatrixInertList.add(entMatrix2);
        
        if(entMatrixInertList.size() > 0){
            insert entMatrixInertList;
        }
        
        
        Test.stopTest();
    } 
    
    @isTest
    private static void getcommunityOptIns(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();  
        test.startTest();
        String email = [select id,Email,name from Contact].Email;
        PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails inputdetailsparser =new PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails();
        inputdetailsparser.EmailId=email;
        inputdetailsparser.Attribute = 'GETCOMMUNITYOPTINS';
        String emailMsgInJsonFormat = JSON.serialize(inputdetailsparser);        
        request.requestUri = '/services/apexrest/SF2myIntel/Updates';
        request.httpMethod = 'POST';       
        request.requestBody = Blob.valueOf(emailMsgInJsonFormat);
        RestContext.request = request;
        RestContext.response= response;
        PRM_SF2MyIntel_Updates_API.processMyIntelUpdates();
        test.stopTest();
    } 
    
    @isTest
    private static void modifyCommunityOptIns(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse(); 
        Set<String> communityList =new Set<String>();
        communityList.addAll(System.Label.PRM_Available_Communities.split(';'));
        List<PRM_SF2MyIntel_Updates_API_Utility.composeCommunityDetails> composeCommunitesList = new List<PRM_SF2MyIntel_Updates_API_Utility.composeCommunityDetails>();
        test.startTest();
        String email = [select id,Email, name from Contact].Email;
        PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails inputdetailsparser =new PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails();
        inputdetailsparser.EmailId=email;
        inputdetailsparser.Attribute = 'MODIFYCOMMUNITYOPTINS';
        for(String comm : communityList){
            PRM_SF2MyIntel_Updates_API_Utility.composeCommunityDetails composeCommunites = new PRM_SF2MyIntel_Updates_API_Utility.composeCommunityDetails(); 
            composeCommunites.IsOptedIn=true;
            composeCommunites.CommunityName=comm;
            composeCommunitesList.add(composeCommunites);
        }
        inputdetailsparser.CommunityDetails=composeCommunitesList;
        String emailMsgInJsonFormat = JSON.serialize(inputdetailsparser);        
        request.requestUri = '/services/apexrest/SF2myIntel/Updates';
        request.httpMethod = 'POST';       
        request.requestBody = Blob.valueOf(emailMsgInJsonFormat);
        RestContext.request = request;
        RestContext.response= response;
        PRM_SF2MyIntel_Updates_API.processMyIntelUpdates();
        test.stopTest();
    }    
    
    @isTest
    private static void emptyCommunityOptIns(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();  
        test.startTest();
        String email = [select id,Email,name from Contact].Email;
        PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails inputdetailsparser =new PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails();
        inputdetailsparser.EmailId=email;      
        String emailMsgInJsonFormat = JSON.serialize(inputdetailsparser);        
        request.requestUri = '/services/apexrest/SF2myIntel/Updates';
        request.httpMethod = 'POST';       
        request.requestBody = Blob.valueOf(emailMsgInJsonFormat);
        RestContext.request = request;
        RestContext.response= response;
        PRM_SF2MyIntel_Updates_API.processMyIntelUpdates();
        test.stopTest();
    }
    
    @isTest
    private static void getcommunityOptInsWithOutEmail(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();  
        test.startTest();
        String email = [select id,Email,name from Contact].Email;
        PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails inputdetailsparser =new PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails();
        //inputdetailsparser.EmailId=email;
        inputdetailsparser.Attribute = 'GETCOMMUNITYOPTINS';
        String emailMsgInJsonFormat = JSON.serialize(inputdetailsparser);        
        request.requestUri = '/services/apexrest/SF2myIntel/Updates';
        request.httpMethod = 'POST';       
        request.requestBody = Blob.valueOf(emailMsgInJsonFormat);
        RestContext.request = request;
        RestContext.response= response;
        PRM_SF2MyIntel_Updates_API.processMyIntelUpdates();
        test.stopTest();
    }
    
     @isTest
    private static void modifyCommunityOptInsWithInvalidInput(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse(); 
        Set<String> communityList =new Set<String>();
        communityList.addAll(System.Label.PRM_Available_Communities.split(';'));
        List<PRM_SF2MyIntel_Updates_API_Utility.composeCommunityDetails> composeCommunitesList = new List<PRM_SF2MyIntel_Updates_API_Utility.composeCommunityDetails>();
        test.startTest();
        String email = [select id,Email, name from Contact].Email;
        PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails inputdetailsparser =new PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails();
        inputdetailsparser.EmailId=email;
        inputdetailsparser.Attribute = 'MODIFYCOMMUNITYOPTINS';
        String emailMsgInJsonFormat = JSON.serialize(inputdetailsparser);        
        request.requestUri = '/services/apexrest/SF2myIntel/Updates';
        request.httpMethod = 'POST';       
        request.requestBody = Blob.valueOf(emailMsgInJsonFormat);
        RestContext.request = request;
        RestContext.response= response;
        PRM_SF2MyIntel_Updates_API.processMyIntelUpdates();
        test.stopTest();
    }
    
    public static Contact createTestContact(){        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account acc = PRM_TestUtility.getAccount();
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);    
        
        Contact con = PRM_TestUtility.getContact();
        con.Email='testUser'+String.valueOf(Math.random())+'@sfapitest.com';
        con.AccountId = acc.Id;
        con.Core_Job_Function__c='Branch Manager';
        con.Core_eRPM_Language_Code__c='Eng';
        con.Core_IPA_PartnerRole__c = 'Service Provider';
        con.Core_Login_Id__c = 'abc';
        con.Core_IPA_Partner_Community__c='Intel® FPGA Partner';
        insert con; 
        return con;
    } 
    
    public static void createCommEnrollRequest(){
        Contact con = [select id,Email,name from Contact];
        PRM_Partner_Community_Enrollment_Request__c parCom = new PRM_Partner_Community_Enrollment_Request__c();
        parCom.PRM_Contact_Id__c = con.id;
        parCom.PRM_Partner_Community_Nm__c='Intel® FPGA Partner';
        parCom.PRM_Status_Nm__c = 'Approved';        
        insert parCom;
    }
}