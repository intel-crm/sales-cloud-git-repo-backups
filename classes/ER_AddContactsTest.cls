@isTest
public class ER_AddContactsTest {
    @testSetup    
    static void setupDataCreation()
    {
        List<Core_Entitlement__c> entList = new list<Core_Entitlement__c>();
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'PSG User Entitlement';
        ent.Core_Display_Name__c = 'RDC PSG Entitlement';
        ent.ER_Program__c = 'PSG';
        entList.add(ent);
        
        Core_Entitlement__c ent1 = new Core_Entitlement__c();
        ent1.Name = 'IQR User Entitlement';
        ent1.Core_Display_Name__c = 'RDC IQR Entitlement';
        ent1.ER_Program__c = 'IQR';
        entList.add(ent1);
        insert entList;  
        
        List<Business_Types__c> btList = new List<Business_Types__c>();
        Business_Types__c bt = new Business_Types__c();
        bt.Name = 'PSG User Entitlement';
        bt.Is_Active__c = true;
        bt.Business_Type_Code__c = 'PSG';
        btList.add(bt);
        
        Business_Types__c bt1 = new Business_Types__c();
        bt1.Name = 'IQR User Entitlement';
        bt1.Is_Active__c = true;
        bt1.Business_Type_Code__c = 'IQR';
        btList.add(bt1);
        insert btList;
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Entitlement_Id__c = ent.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.Business_Types__c = bt.Id;
        emList.add(em);
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.PRM_Entitlement_Id__c = ent1.id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.Business_Types__c = bt1.Id;
        emList.add(em1);
        insert emList;
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.Industry='Construction';
        testAccount.OwnerId = UserInfo.getUserId();
        testAccount.Core_User_Defined_Website__c = 'www.abc.com';
        testAccount.Core_OnePartnerID__c = testAccount.Id;
        testAccount.Core_Geo__c = 'ASMO';
        insert testAccount;
        
        Core_Country_Code_Mapping__c corecode = new Core_Country_Code_Mapping__c();
        corecode.Country_Code__c='US';
        corecode.ISO_Code__c='USA';
        corecode.Name ='USA Code';
        insert corecode;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='RDCAck1';
        cont.FirstName='RDCAck1';
        cont.email='test_rdcuser1@mailinator.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_IPA_PartnerRole__c='Service Provider';
        cont.Core_eRPM_Language_Code__c='Eng';
        insert cont;
        
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        List<PRM_Registration_Request__c> regRequestList = new List<PRM_Registration_Request__c>();
        for(integer i=0; i<10; i++){
            PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
            regRequest.RecordTypeId=accCreateRequestId;
            regRequest.Name= 'RDCAck'+i;
            regRequest.PRM_First_Name__c= 'RDCAck'+i;
            regRequest.PRM_Last_Name__c= 'RDCAck'+i;
            regRequest.PRM_Contact_Country__c= 'USA';
            regRequest.PRM_Contact_Login_ID__c= 'test_rdcuser'+i+'@mailinator.com';
            regRequest.PRM_Email_ID__c= 'test_rdcuser'+i+'@mailinator.com';
            regRequest.PRM_Enterprise_ID__c= '3000002446643';
            if(i <= 5){
                regRequest.Entitlement_Details__c= entList[0].Id;
            }else{
                regRequest.PRM_Contact_Country__c= 'US';
                regRequest.Entitlement_Details__c= entList[1].Id;    
            }
            regRequest.PRM_EV_Token__c= 'EAAAAFEKpZnzESjs92XoY55f4ngu9BUyuOIraFcrFXziDwRdlXdOuIOyDgk3K+dJD7x3mZ83lu3LT3yn9PHHd7Z2q0CXeXQOFnEV2oKB/DivrTpg+TYum1pfXY2/Yq5Vin+38436zR3W4Z7zO9albgNnAljH0lj7JnfGAu90Z8Ju9K4oa1uzPqUoRXcacHaLGediMDSAhLcrvxqNwgthOeJ0loAbLMZYnQQ+3a6YOWAiyAsvUsGEXKfV1M2KNSbYeos8lA==';
            regRequest.PRM_Person_Phone_Number__c= '3232';
            regRequest.PRM_Preferred_Language__c= 'ENG';
            if(i == 3){
                regRequest.PRM_Preferred_Language__c= '';
            }
            regRequest.PRM_Status__c= 'New';
            regRequest.PRM_Salesforce_ID__c = testAccount.Id;
            regRequestList.add(regRequest);
        }
        PRM_Registration_Request__c regRequest1 = new PRM_Registration_Request__c();
        regRequest1.RecordTypeId=accCreateRequestId;
        regRequest1.Name= 'RDCAck2';
        regRequest1.PRM_First_Name__c= 'RDCAck2';
        regRequest1.PRM_Last_Name__c= 'RDCAck2';
        regRequest1.PRM_Contact_Country__c= 'USA';
        regRequest1.PRM_Contact_Login_ID__c= 'test_rdcuser2@mailinator.com';
        regRequest1.PRM_Email_ID__c= 'test_rdcuser2@mailinator.com';
        regRequest1.PRM_Enterprise_ID__c= '3000002446643';
        regRequest1.PRM_Contact_Country__c= 'US';
        regRequest1.Entitlement_Details__c= entList[1].Id;
        regRequest1.PRM_EV_Token__c= 'EAAAAFEKpZnzESjs92XoY55f4ngu9BUyuOIraFcrFXziDwRdlXdOuIOyDgk3K+dJD7x3mZ83lu3LT3yn9PHHd7Z2q0CXeXQOFnEV2oKB/DivrTpg+TYum1pfXY2/Yq5Vin+38436zR3W4Z7zO9albgNnAljH0lj7JnfGAu90Z8Ju9K4oa1uzPqUoRXcacHaLGediMDSAhLcrvxqNwgthOeJ0loAbLMZYnQQ+3a6YOWAiyAsvUsGEXKfV1M2KNSbYeos8lA==';
        regRequest1.PRM_Person_Phone_Number__c= '3232';
        regRequest1.PRM_Preferred_Language__c= 'ENG';
        regRequest1.PRM_Status__c= 'New';
        regRequest1.PRM_Salesforce_ID__c = testAccount.Id;
        regRequestList.add(regRequest1);
        insert regRequestList;
    }
    @isTest 
    public static void createContactsTestMethod(){
        List<ER_AddContacts.newRegFlowInput> flowInputList = New List<ER_AddContacts.newRegFlowInput>();
        for(PRM_Registration_Request__c appNewReg : [SELECT Id,PRM_First_Name__c,PRM_Last_Name__c,PRM_Email_ID__c,
                                                     PRM_Person_Phone_Number__c,
                                                     PRM_Source__c,
                                                     PRM_Profession__c,
                                                     PRM_Salesforce_ID__c,
                                                     PRM_Preferred_Language__c,
                                                     PRM_Contact_Login_ID__c,
                                                     PRM_Enterprise_ID__c,
                                                     PRM_Partner_Role__c,
                                                     PRM_Contact_Country__c
                                                     FROM PRM_Registration_Request__c]){
                                                         ER_AddContacts.newRegFlowInput flowinput = New ER_AddContacts.newRegFlowInput();
                                                         flowinput.newRegistration = appNewReg;
                                                         flowinput.countryCode = appNewReg.PRM_Contact_Country__c;
                                                         flowInputList.add(flowinput);
                                                     }
        Test.startTest();
        ER_AddContacts.setContacts(flowInputList);
        Test.stopTest();
        List<Contact> conList = [SELECT Id,Email FROM Contact];
        system.assert(conList.size() == 10, 'This is not empty list');
        
    }
}