@isTest
public class ER_DuplicationUtility_Test {
    
    @testSetup
    static void DataSetup() {
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'Resource & Design Center for Secure Content';
        ent.Core_Display_Name__c = 'RDC Entitlement';
        insert ent;
        
        PRM_PartnerAgreement__c pa = new PRM_PartnerAgreement__c();
        pa.Name = 'RDC Privileges Terms & Conditions';
        pa.PRM_Agreement_Cd__c = 'RDC_Priv_TC';
        insert pa;
    }
    
    @isTest static void RejectDuplicatesTest() {
        Test.startTest();
        
        List<PRM_Registration_Request__c> listReq = new List<PRM_Registration_Request__c>();
        List<Core_Entitlement__c> ent = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        PRM_Registration_Request__c regRequest1 = getRegistrationRequest();
        regRequest1.RecordTypeId = accCreateRequestId;
        regRequest1.Entitlement_Details__c = ent[0].Id;
        regRequest1.PRM_Account_Name__c ='Test Account';
        regRequest1.PRM_Status__c ='New';
        regRequest1.PRM_Contact_Login_ID__c = 'loginContact11@mailinator.com';
        //listReq.add(regRequest1);
        insert regRequest1;
        
        PRM_Registration_Request__c regRequest2 = getRegistrationRequest();
        regRequest2.RecordTypeId = accCreateRequestId;
        regRequest2.Entitlement_Details__c = ent[0].Id;
        regRequest2.PRM_Account_Name__c ='Test Account';
        regRequest2.PRM_Status__c ='New';
        regRequest2.PRM_Contact_Login_ID__c = 'loginContact11@mailinator.com';
        //listReq.add(regRequest2);        
        insert regRequest2;
        
        //regRequest1.RecordTypeId = accCreateRequestId;
        //update regRequest1;
        
        //regRequest2.RecordTypeId = accCreateRequestId;
        //update regRequest2;
        
        List<PRM_Registration_Request__c> req = [SELECT Id, PRM_Status__c 
                                                 FROM PRM_Registration_Request__c
                                                 WHERE Id =: regRequest2.Id];
        List<PRM_Registration_Request__c> newList = new List<PRM_Registration_Request__c>();
        newList.add(regRequest1);
        newList.add(regRequest2);
        ER_DuplicationUtility.rejectDuplicates(newList,null);
       // System.assertEquals(req[0].PRM_Status__c,'Rejected');
       // ER_DuplicationUtility.rejectDuplicates(); 
       // ER_DuplicationUtility.DupCheck();
        Test.stopTest();
        
    }
    
    @isTest static void DupCheckTest() {
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;

        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        
        List<PRM_Registration_Request__c> listReq = new List<PRM_Registration_Request__c>();
        List<Core_Entitlement__c> ent = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        PRM_Registration_Request__c regRequest1 = getRegistrationRequest();
        regRequest1.RecordTypeId = accCreateRequestId;
        regRequest1.Entitlement_Details__c = ent[0].Id;
        regRequest1.PRM_Contact_Login_ID__c = 'loginContact11@mailinator.com';
        listReq.add(regRequest1);       
        
        insert listReq;
        
        //regRequest1.RecordTypeId = accCreateRequestId;
        //update regRequest1;
        
		 List<PRM_Registration_Request__c> reqst = [SELECT Id, Name, PRM_Status__c, PRM_Dup_Status__c, PRM_DeDup_Criteria__c
                                                 FROM PRM_Registration_Request__c
                                                 WHERE Id =: regRequest1.Id];        

        System.assertEquals(reqst[0].Name,'RR1');
        //System.assertEquals(reqst[0].PRM_Dup_Status__c,System.Label.PRM_Partdup);
        //System.assertEquals(reqst[0].PRM_DeDup_Criteria__c,System.Label.PRM_Fail);
        
        Test.stopTest();
    }
    
    /*Method to get 'Registration Request' object*/
    public static PRM_Registration_Request__c getRegistrationRequest(){
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_First_Name__c = 'Test Request';
        regRequest.PRM_Last_Name__c = 'New';
        regRequest.PRM_Email_ID__c = 'testrequest@mailinator.com';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.PRM_Account_Name__c='Intel';
        regRequest.PRM_Company_Email_Domain__c='intel.com';
        regRequest.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        regRequest.PRM_Address_Line_2__c='Bengaluru,India'; 
        regRequest.PRM_City__c='Las Vegas';
        regRequest.PRM_State_Province__c='NY';
        regRequest.PRM_Country__c='USA';
        regRequest.PRM_Zip_Postal_Code__c = '54533';
        regRequest.PRM_Status__c ='New';
        return regRequest;
        
        
    }
    
    public static List<PRM_CIMSearchResults__c> getCIMResults(integer score){
        List<PRM_CIMSearchResults__c> cimList = new List<PRM_CIMSearchResults__c>();
        PRM_CIMSearchResults__c cimData = new PRM_CIMSearchResults__c();
        cimData.PRM_SearchScore_Nbr__c = score;
        cimList.add(cimData);
        return cimList;
    }

}