@isTest
public class PMP_SearchCompanyLeadGenFromReg_Test extends PMP_SearchWrapperStore {

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
        PMP_SearchCompanyLeadGenFromRegistration.getExistingSettings(partner.Id);
        Test.stopTest();
    }
    
     @isTest static void testGetExistingSettingsNullLanguage(){
        PMP_Company__c partner = [SELECT Id, Name from PMP_Company__c where Name='testPartner2' Limit 1];
        system.assertEquals(partner != null, true);
        Test.startTest();
        PMP_SearchCompanyLeadGenFromRegistration.getExistingSettings(partner.Id);
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
        system.assertEquals(true, PMP_SearchCompanyLeadGenFromRegistration.saveSettingsData(partner.Id, JSON.serialize(data)));
            
        Test.stopTest();
        
    }
    
    @isTest static void testGetLanguagePreferences(){
         PMP_Company__c partner = [SELECT Id, Name from PMP_Company__c where Name='testPartner'];
        system.assertEquals(partner != null, true);
        Test.startTest();
        PMP_SearchCompanyLeadGenFromRegistration.getLanguagePreferences(partner.Id);
        Test.stopTest();
    }
    
    @isTest static void testGetUserDetails(){
       
            Account acc = new Account();   
            acc.Name = 'Test';
       		acc.BillingCity = 'Jaipur';
        	acc.BillingCountry = 'India';
        	acc.BillingStreet = 'Test';
        	
           insert acc;
            
            Contact con = new Contact();
        	con.FirstName = 'Test';
            con.LastName = 'Test';
            con.Email = 'testing@gmail.com';
            con.AccountId = acc.Id;
        	
            insert con;
           
 			PRM_Registration_Request__c regUser = new PRM_Registration_Request__c ();
    
            regUser.PRM_First_Name__c = 'firstName1';
            regUser.PRM_Last_Name__c = 'lastName1';
            regUser.PRM_Account_Name__c = 'intel1';
            regUser.PRM_Country__c = 'India';
            regUser.PRM_State_Province__c = 'Karnataka';
            regUser.PRM_Person_Phone_Number__c = '9876543210';
            regUser.PRM_Email_ID__c = con.Email;
            insert regUser;
        	
         	Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new PMP_SearchCompanyLeadGenHttpResponse(201));
        	PMP_SearchCompanyLeadGenFromRegistration.fetchUser(regUser.Id);
            System.assertEquals(regUser != null, true, 'user detail is null');

            Test.stopTest();
        
        
    }
    
    
    
    @isTest
    static void getDependentMapTest(){
        Test.startTest();
        System.assertNotEquals(null, PMP_SearchCompanyLeadGenFromRegistration.getDependentMap());
        Test.stopTest();
    }
    
    @isTest
    static void getJobFunctionsTest(){
        Test.startTest();
        System.assertNotEquals(null, PMP_SearchCompanyLeadGenFromRegistration.getPartnerProfession());
        Test.stopTest();
    }
    
    @isTest
    static void getCommunityUrlTest(){
        Test.startTest();
        System.assertNotEquals(null, PMP_SearchCompanyLeadGenFromRegistration.getCommunityURL());
        Test.stopTest();
    }
    
    @isTest static void submitTest1(){
        User u = PMP_SearchTestDataFactory.createUser(true);
        System.runAs(u){
            Test.startTest();
            PRM_Registration_Request__c regUser = new PRM_Registration_Request__c ();
    
            regUser.PRM_First_Name__c = 'firstName1';
            regUser.PRM_Last_Name__c = 'lastName1';
            regUser.PRM_Account_Name__c = 'intel1';
            regUser.PRM_Country__c = 'India';
            regUser.PRM_State_Province__c = 'Karnataka';
            regUser.PRM_Person_Phone_Number__c = '9876543210';
            regUser.PRM_Email_ID__c = 'testing@gmail.com';
           // insert regUser;
            
            Test.setMock(HttpCalloutMock.class, new PMP_SearchCompanyLeadGenHttpResponse(201));
            PMP_SearchCompanyLeadGenFromRegistration.submit(regUser, 'quote', null, null, null, null, null);
            System.assertEquals(regUser != null, true, 'user detail is null');
            Test.stopTest();
        } 
    }
    
    @isTest static void submitTest2(){
        User u = PMP_SearchTestDataFactory.createUser(true);
        System.runAs(u){
            Test.startTest();
			PRM_Registration_Request__c regUser = new PRM_Registration_Request__c ();
           
            regUser.PRM_First_Name__c = 'firstName1';
            regUser.PRM_Last_Name__c = 'lastName1';
            regUser.PRM_Account_Name__c = 'intel1';
            regUser.PRM_Country__c = 'India';
            regUser.PRM_State_Province__c = 'Karnataka';
            regUser.PRM_Person_Phone_Number__c = '9876543210';
            regUser.PRM_Email_ID__c = 'testing@gmail.com';
            
            Test.setMock(HttpCalloutMock.class, new PMP_SearchCompanyLeadGenHttpResponse(200));
            PMP_SearchCompanyLeadGenFromRegistration.submit(regUser, 'contact', 'partnerId', 'partnerName', 'offeringId', 'offeringName', 'offeringLink');
            System.assertEquals(regUser != null, true, 'user detail is null');
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
        //Create portal account owner
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'testUser'+String.valueOf(Math.random())+'@example.com',
            Alias = 'batman',
            Email='testUser'+String.valueOf(Math.random())+'@example.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles'
        );
        Database.insert(portalAccountOwner1);
        
        System.runAs(portalAccountOwner1){
            //Create account
            Account portalAccount1 = new Account(
                Name = 'TestAcc1',
                RecordTypeId = PMP_SearchTestDataFactory.intel_Account_Record_Type,
                OwnerId = portalAccountOwner1.Id,
                Core_Account_Type__c='Distributor',
                BillingCity='Bangalore', BillingCountry='IND', BillingStreet = 'TestStreet'
            );
            Database.insert(portalAccount1);
            portalAccount1.IsPartner = true;
 			Database.update(portalAccount1);        
            //Create contact
            Contact contact1 = new Contact(
                    FirstName = 'Test',
                    Lastname = 'McTesty',
                    AccountId = portalAccount1.Id,
                    Email = 'testcontact'+String.valueOf(Math.random())+'@example.com'
            );
            Database.insert(contact1);
                    
            Id p = [select id from profile where name='Partner'].id;
            Account testPartAccount = PMP_SearchTestDataFactory.createIntelAccount('TestPartAcc1', PMP_SearchTestDataFactory.Partner_Account_Record_Type, true);
            Core_Account_Group_Member__c testpagmbr = PMP_SearchTestDataFactory.createPAGMember(testPartAccount.Id,portalAccount1.Id,true,false,true);
            User usr = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email=contact1.Email,
                                         EmailEncodingKey='UTF-8', LastName=contact1.LastName, LanguageLocaleKey='en_US',
                                         LocaleSidKey='en_US', ProfileId = p,IsActive = true,
                                         TimeZoneSidKey='America/Los_Angeles', UserName=contact1.Email,FirstName=contact1.FirstName, ContactId = contact1.Id);
            insert usr; 
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name ='PMP_External_Partner_Admin'];
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = usr.Id;
                psa.PermissionSetId = ps.Id;
                insert psa;
            System.runAs(usr){
               
                Test.startTest();
                List<Contact> partnerContact = PMP_SearchCompanyLeadGenFromRegistration.getPartnerAdminAccounts();
                System.assertEquals(partnerContact != null, true, 'Partner Contact list size  is'+partnerContact.size());
                
                Test.stopTest();
            }
        }        
                
    }
}