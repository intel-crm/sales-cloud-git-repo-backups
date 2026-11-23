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
            PMP_SearchCompanyLeadGenController.fetchUser();
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
        System.assertNotEquals(null, PMP_SearchCompanyLeadGenController.getJobFunction());
        Test.stopTest();
    }
    
    @isTest
    static void getCommunityUrlTest(){
        Test.startTest();
        System.assertNotEquals(null, PMP_SearchCompanyLeadGenController.getCommunityURL());
        Test.stopTest();
    }
    
    @isTest static void submitTest1(){
        User u = PMP_SearchTestDataFactory.createUser(true);
        System.runAs(u){
            Test.startTest();
            UserDetails userDet = PMP_SearchCompanyLeadGenController.fetchUser();
            userDet.firstName = 'firstName1';
            userDet.lastName = 'lastName1';
            //userDet.jobTitle = 'jobTitle1';
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
            PMP_SearchCompanyLeadGenController.submit(userDet, 'quote', 'partnerId', 'partnerName', 'offeringId', 'offeringName', 'offeringLink');
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
            //userDet.jobTitle = 'jobTitle1';
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
            PMP_SearchCompanyLeadGenController.submit(userDet, 'contact', 'partnerId', 'partnerName', 'offeringId', 'offeringName', 'offeringLink');
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
            System.runAs(usr){
                /**PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =:PMP_StaticConstants_Partner.PARTNER_ADMIN];
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = usrTest.Id;
                psa.PermissionSetId = ps.Id;
                insert psa;**/
                Test.startTest();
                PMP_SearchCompanyLeadGenController.getPartnerAdminAccounts();
                Test.stopTest();
            }
        }        
                
    }
}