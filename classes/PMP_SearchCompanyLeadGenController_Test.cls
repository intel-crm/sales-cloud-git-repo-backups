@isTest
public class PMP_SearchCompanyLeadGenController_Test extends PMP_SearchWrapperStore{
	
    @testSetup static void dataFactory(){
         Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
		 PMP_Company__c testpartner3 = PMP_SearchTestDataFactory.createCompanyInformation('testPartner3', testAccount.Id, true);        
		 PMP_Company__c testpartner = PMP_SearchTestDataFactory.createCompanyInformation('testPartner', testAccount.Id, true);
        	testpartner.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
            testpartner.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
        	testpartner.PMP_Company_Lead_Gen_Language_Nm__c = 'English;Japanese';
        	testpartner.PMP_Working_Copy_Id__c = testpartner3.Id;
        update testpartner;
        //system.assertEquals(testpartner.PMP_Is_Lead_Gen_Limited_Nm__c, true);
        PMP_Company__c testpartner2 = PMP_SearchTestDataFactory.createCompanyInformation('testPartner2', testAccount.Id, true);
        testpartner.PMP_Is_Enabled_Lead_Gen_Nm__c = 'False';
            testpartner.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
        	testpartner.PMP_Company_Lead_Gen_Language_Nm__c = '';
        update testpartner2;   
    }
    
    @isTest static void testGetExistingSettings(){
        PMP_Company__c partner = [SELECT Id, Name from PMP_Company__c where Name='testPartner' Limit 1];
        system.assertEquals(partner != null, true);
        Test.startTest();
        PMP_SearchCompanyLeadGenController.getExistingSettings(partner.Id);
        Test.stopTest();
    }
    
     @isTest static void testGetExistingSettingsNullLanguage(){
        PMP_Company__c partner = [SELECT Id, Name from PMP_Company__c where Name='testPartner2' Limit 1];
        system.assertEquals(partner != null, true);
        Test.startTest();
        PMP_SearchCompanyLeadGenController.getExistingSettings(partner.Id);
        Test.stopTest();
    }
    
    @isTest static void testSaveSettingsData(){
        PMP_Company__c partner = [SELECT Id, Name from PMP_Company__c where Name='testPartner' Limit 1];
        
        system.assertEquals(partner != null, true);
        List<Options> langPref = new List<Options>();
        Options lang = new Options();
        lang.label = 'English';
        lang.value = 'English';
        lang.selected = true;
        langPref.add(lang);
        
        LeadGenSettings data = new LeadGenSettings();
        data.enableLeadGeneration = true;
        data.limitToPartners = true;
        data.languagePreference = new List<Options>();
        data.languagePreference =langPref;
        
        Test.startTest();
        system.assertEquals(true, PMP_SearchCompanyLeadGenController.saveSettingsData(partner.Id, JSON.serialize(data)));
            
        Test.stopTest();
        
    }
    
    @isTest static void testGetLanguagePreferences(){
         PMP_Company__c partner = [SELECT Id, Name from PMP_Company__c where Name='testPartner'];
        system.assertEquals(partner != null, true);
        Test.startTest();
        PMP_SearchCompanyLeadGenController.getLanguagePreferences(partner.Id);
        Test.stopTest();
    }
    
    @isTest static void testGetUserDetails(){
        User u = PMP_SearchTestDataFactory.createUser(true);
        System.runAs(u){
            Test.startTest();
            UserDetails userdet=null;

            userdet = PMP_SearchCompanyLeadGenController.fetchUser();
            
            System.assertEquals(userdet != null, true, 'user detail is null');

            Test.stopTest();
        } 
        
    }
    
    
    
    @isTest
    static void getDependentMapTest(){
        Test.startTest();
        System.assertNotEquals(null, PMP_SearchCompanyLeadGenController.getDependentMap());
        Test.stopTest();
    }
    
    @isTest
    static void getJobFunctionsTest(){
        Test.startTest();
        System.assertNotEquals(null, PMP_SearchCompanyLeadGenController.getPartnerProfession());
        Test.stopTest();
    }

    
    @isTest static void submitTest1(){
        User u = PMP_SearchTestDataFactory.createUser(true);
        System.runAs(u){
            Test.startTest();
            UserDetails userDet = PMP_SearchCompanyLeadGenController.fetchUser();
            userDet.firstName = 'firstName1';
            userDet.lastName = 'lastName1';
            userDet.profession = 'profession1';
            userDet.companyName = 'intel1';
            userDet.country = 'India';
            userDet.state = 'Karnataka';
            userDet.phone = '9876543210';
            userDet.email = 'testing@gmail.com';
            userDet.volume = 55;
            userDet.description = 'testing eloqua';
            userDet.deliveryDate = date.today();
            userDet.partnerProgramSegment = 'test1;test2';
            userDet.sessionId = 'testSessionId';
            Test.setMock(HttpCalloutMock.class, new PMP_SearchCompanyLeadGenHttpResponse(201));
            PMP_SearchCompanyLeadGenController.submit(userDet, 'quote', 'partnerId', 'partnerName', 'offeringId', 'offeringName', 'offeringLink', true);
            System.assertEquals(userDet != null, true, 'user detail is null');
            Test.stopTest();
        } 
    }
    
    @isTest static void submitTest2(){
        User u = PMP_SearchTestDataFactory.createUser(true);
        System.runAs(u){
            Test.startTest();
            UserDetails userDet = PMP_SearchCompanyLeadGenController.fetchUser();
            userDet.firstName = 'firstName1';
            userDet.lastName = 'lastName1';
            userDet.profession = 'profession1';
            userDet.companyName = 'intel1';
            userDet.country = 'India';
            userDet.state = 'Karnataka';
            userDet.phone = '9876543210';
            userDet.email = 'testing@gmail.com';
            userDet.volume = 55;
            userDet.description = 'testing eloqua';
            userDet.deliveryDate = date.today();
            userDet.partnerProgramSegment = 'test1;test2';
            Test.setMock(HttpCalloutMock.class, new PMP_SearchCompanyLeadGenHttpResponse(200));
            PMP_SearchCompanyLeadGenController.submit(userDet, 'contact', 'partnerId', 'partnerName', 'offeringId', 'offeringName', 'offeringLink', true);
            System.assertEquals(userDet != null, true, 'user detail is null');
            Test.stopTest();
        } 
    }
    
    public class PMP_SearchCompanyLeadGenHttpResponse implements HttpCalloutMock {
        
        public Integer statusCode;
        public PMP_SearchCompanyLeadGenHttpResponse(Integer statusCode){
            this.statusCode = statusCode;
        }
        public HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test" , "values":[{"value":"test value"}]}');
            res.setStatusCode(statusCode);
            return res;
        }
    }
    
    @isTest static void testGetPartnerAdminAccounts(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        
        User user = [SELECT AccountId FROM User WHERE id =:Userinfo.getUserId()];
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
        
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = user.AccountId; 
        coreAccnt.Core_Inactive_Ind__c = false;
        insert coreAccnt;
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=False;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
      
        insert company;
        System.assertNotEquals(company, Null);
       
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;     
        insert jun;
        system.runAs(user){
            Test.startTest();
            PMP_PartnerAdminAccounts.getPartnerAdminAccounts();
            PMP_SearchCompanyLeadGenController.getPartnerAdminAccounts();
            Test.stopTest();
        }
        
    }
}