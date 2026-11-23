@isTest
private class Core_Accept_Partner_Leads_Ctrl_Test {
    static testmethod void PartnerUserLead(){
        List<Lead> lstLeads = new List<Lead>();
        user profileuser;
        System.runAs(Core_Test_Utility.systemAdminUser){ 
                UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            User portalAccountOwner1 = new User(
                UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                Username = System.now().millisecond() + 'test2@test.com',
                Alias = 'admin',
                Email = 'test.user1@intel.com',
                EmailEncodingKey='UTF-8',
                Firstname='Bruce',
                Lastname='Wayne',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago'
            );
            Database.insert(portalAccountOwner1);  
		
            Account testAccount = Core_Test_Utility.createAccount(1)[0];
            testAccount.RecordTypeId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
            insert testAccount;
            /*Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,Core_CIM_ID__c='12345',
                                              Core_Account_Type__c='Other', Industry='Others',RecordTypeId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId(),
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '12345',OwnerId = portalAccountOwner1.Id);
            insert testAccount;*/
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact;
            
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name ='Partner Community Login User' Limit 1];
            
            profileuser= new User(
                Username = System.now().millisecond() + 'test12345Intel@test.com',
                contactid=testcontact.id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test12345@apttus.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            Database.insert(profileuser);
            Lead lead1 = new Lead();
            lead1.RecordTypeId = System.Label.Core_Partner_Lead_Record_Id;
            lead1.FirstName = 'Test1';
            lead1.LastName = 'Test12';
            lead1.email = 'gerald.reinartz=intel.com@example.com';
            lead1.Phone = '123 4567';
            lead1.Company = 'Test1';
            lead1.CountryCode = 'USA';
            lead1.LeadSource = 'Partner Program';
            lead1.Core_Partner_Name__c = 'TestPartner1';
            lead1.OwnerId=profileuser.Id;
            //lead1.Status='Partner Qualified Lead';
            lead1.Core_Rejection_Comments__c ='Test';
            lead1.Core_Partner_Lead_Owner__c = profileuser.Id;
            lead1.CreatedDate = Datetime.now().addDays(-1); // Create date should be yesterday, so the batch job can pick the lead for summary count
            lstLeads.add(lead1);
            insert lstLeads;
            
        }
        System.runAs(profileuser){ 
            //lstLeads[0].Status='Partner Qualified Lead';
            lstLeads[0].Core_Rejection_Comments__c=null;
            
            update lstLeads;
            
            Test.startTest();
            Test.setCurrentPage(Page.Core_Accept_Partner_Leads);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstLeads);
            stdSetController.setSelected(lstLeads);
            Core_Accept_Partner_Leads_Ctrl ext = new Core_Accept_Partner_Leads_Ctrl(stdSetController);
            ext.acceptPartnerLeads();
            Test.stopTest();
        }
        
    }   
    static testmethod void AdminUserLead(){ 
        List<Lead> lstLeads1 = new List<Lead>();
        System.runAs(Core_Test_Utility.systemAdminUser){           
            Lead lead1 = new Lead();
            lead1.RecordTypeId = System.Label.Core_Partner_Lead_Record_Id;
            lead1.FirstName = 'Test1';
            lead1.LastName = 'Test12';
            lead1.email = 'gerald.reinartz=intel.com@example.com';
            lead1.Phone = '123 4567';
            lead1.Company = 'Test1';
            lead1.CountryCode = 'USA';
            lead1.LeadSource = 'Partner Program';
            lead1.Core_Partner_Name__c = 'TestPartner1';
            lead1.Status='Tele Accepted Prospect';
            lead1.Core_Rejection_Comments__c ='Test';
            //lstLeads1[0].Lead_Status_on_Claim__c = 'true';
            lead1.CreatedDate = Datetime.now().addDays(-1);// Create date should be yesterday, so the batch job can pick the lead for summary count
            lstLeads1.add(lead1);
            insert lstLeads1;
            
            lstLeads1[0].Status='Partner Qualified Lead';
            lstLeads1[0].Core_Rejection_Comments__c=null;
          
            update lstLeads1;
            Test.startTest();
            Test.setCurrentPage(Page.Core_Accept_Partner_Leads);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstLeads1);
            stdSetController.setSelected(lstLeads1);
            Core_Accept_Partner_Leads_Ctrl ext = new Core_Accept_Partner_Leads_Ctrl(stdSetController);
            ext.acceptPartnerLeads();
            Test.stopTest();        
        }
        
    }
}