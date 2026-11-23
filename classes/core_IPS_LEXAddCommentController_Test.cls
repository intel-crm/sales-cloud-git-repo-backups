@isTest
public with sharing class core_IPS_LEXAddCommentController_Test {
    @TestSetup
    static void makeData(){
        list<Core_IPS_Labels__c> lstCs = new list<Core_IPS_Labels__c>();
        lstCs.add(new Core_IPS_Labels__c(name='Comment Source - Customer', value__c='Customer Portal'));
        lstCs.add(new Core_IPS_Labels__c(name='Comment Source - Internal', value__c='Internal Portal'));
        lstCs.add(new Core_IPS_Labels__c(name='Comment Source - B2B API', value__c='B2B API'));
        lstCs.add(new Core_IPS_Labels__c(name='Partner - Agent', value__c='Partner - Agent'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'IPS Standard Entitlement', Value__c='IPS Standard Entitlement'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'PRIVATE_TO_INTEL', Value__c = 'Private to Intel'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'Agent', Value__c = 'Agent'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'PUBLIC_TO_CUSTOMERS', Value__c = 'Public to Customers'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'Customer', Value__c = 'Customer'));
        lstCs.add(new Core_IPS_Labels__c(name = 'Partner', value__c = 'Partner'));
        lstCs.add(new Core_IPS_Labels__c (name='FAE', value__c='FAE'));
        lstCs.add(new Core_IPS_Labels__c(name='Backend Integration', value__c='Backend Integration'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Partner - DFAE', value__c= 'Partner - DFAE'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Comment Source - Backend System', value__c='Backend System'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Comment Source - Data Migration', value__c='Data Migration'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Comment Source - Email', value__c='Email')); 
        lstCs.add(new Core_IPS_Labels__c(name= 'Comment Source - N/A', value__c='N/A'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Data Migration', value__c='Data Migration'));
        lstCs.add(new Core_IPS_Labels__c(name= 'PRIVATE_TO_AGENTS', value__c='PRIVATE_TO_AGENTS'));
        lstCs.add(new Core_IPS_Labels__c(name= 'PRIVATE_TO_PARTNERS', value__c='PRIVATE_TO_PARTNERS'));
        insert lstCs; 
        insert TestUtilities.getCase();
        Id caseRec = [SELECT ID FROM Case Limit 1].Id;
        List<Core_IPS_Case_Comments__c> caseComments = TestUtilities.getCaseComments(3);
        for(Core_IPS_Case_Comments__c caseComment : caseComments){
            caseComment.Core_IPS_Case__c = caseRec;           
        }
        insert caseComments;
        System.assert(caseComments[0].Id != null, 'Record not created');

    }
    public static TestMethod void searchTestMethodWithRecords(){
        core_IPS_LEXAddCommentController.userhasAccess = true;
        core_IPS_LEXAddCommentController.partnerAgentUser = false;
        String str = 'testing';
        Id caseRec = [SELECT ID FROM Case Limit 1].Id;
        List<Core_IPS_Case_Comments__c> ls = core_IPS_LEXAddCommentController.search(str, caseRec);
        core_IPS_LEXAddCommentController.clear();
    }
    public static TestMethod void searchTestMethodWithOutRecords(){
        core_IPS_LEXAddCommentController.userhasAccess = False;
       	core_IPS_LEXAddCommentController.partnerAgentUser = False;
        
        String str = 'test';
        Id caseRec = [SELECT ID FROM Case Limit 1].Id;
        List<Core_IPS_Case_Comments__c> ls = core_IPS_LEXAddCommentController.search(str, caseRec);
    }
    public static TestMethod void searchTestMethodIpsAgentPartner(){
        core_IPS_LEXAddCommentController.userhasAccess = false;
        core_IPS_LEXAddCommentController.partnerAgentUser = false;
        core_IPS_LEXAddCommentController.ExternalUser = true;
        core_IPS_LEXAddCommentController.partnerType = 'Not a Partner';
        String profileId = [SELECT Id from Profile where Name='IPS Agent-Partner'].Id;
        User AccountOwner= TestUtilities.getAccountOwner();
              System.runas(AccountOwner){
              Account acc = TestUtilities.getAccountRecord();
        	  acc.OwnerId = AccountOwner.Id; //Added by Nuthana
        	  insert acc;
        	  System.debug('owner Id'+acc.OwnerId);
              System.assert(acc.Id != null, 'Record not created');

        	Contact con = TestUtilities.getContact();
        	con.AccountId = acc.ID;
        	insert con;
        	System.assert(con.Id != null, 'Record not created');
              
          }
          Contact con = [select Id from Contact Limit 1];
        /*Account acc = TestUtilities.getAccountRecord();
        insert acc;
        System.assert(acc.Id != null, 'Record not created');

        Contact con = TestUtilities.getContact();
        con.AccountId = acc.ID;
        insert con;
        System.assert(con.Id != null, 'Record not created');*/

        User uu = new User(
            ProfileId = profileId,
            LastName = 'last',
            Email = 'puser00012@amamama.com',
            Username = 'puser00012@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = con.Id);
        insert uu;
        System.assert(uu.Id != null, 'Record not created');

        System.runAs(uu){
            insert TestUtilities.getCase();
            String str = 'testing';
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            List<Core_IPS_Case_Comments__c> ls = core_IPS_LEXAddCommentController.search(str, caseRec);
        }
    }
     public static TestMethod void searchTestMethodIpsPartner(){
        core_IPS_LEXAddCommentController.userhasAccess = false;
        core_IPS_LEXAddCommentController.partnerAgentUser = false;
        core_IPS_LEXAddCommentController.ExternalUser = true;
        core_IPS_LEXAddCommentController.partnerType = 'Not a Partner';
        String profileId = [SELECT Id from Profile where Name='Partner'].Id;
        core_IPS_LEXAddCommentController.partnerProf = profileId;
         User AccountOwner= TestUtilities.getAccountOwner();
                   System.runas(AccountOwner){
              Account acc = TestUtilities.getAccountRecord();
        	  acc.OwnerId = AccountOwner.Id; //Added by Nuthana
        	  insert acc;
        	  System.debug('owner Id'+acc.OwnerId);
              System.assert(acc.Id != null, 'Record not created');

        	Contact con = TestUtilities.getContact();
        	con.AccountId = acc.ID;
        	insert con;
        	System.assert(con.Id != null, 'Record not created');
              
          }
          Contact con = [select Id from Contact Limit 1];
         
        /*Account acc = TestUtilities.getAccountRecord();
        insert acc;
        System.assert(acc.Id != null, 'Record not created');

        Contact con = TestUtilities.getContact();
        con.AccountId = acc.ID;
        insert con;
        System.assert(con.Id != null, 'Record not created');*/

        User uu = new User(
            ProfileId = profileId,
            LastName = 'last',
            Email = 'puser00012@amamama.com',
            Username = 'puser00012@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = con.Id);
        insert uu;
        System.assert(uu.Id != null, 'Record not created');

        System.runAs(uu){
            insert TestUtilities.getCase();
            String str = 'testing';
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            List<Core_IPS_Case_Comments__c> ls = core_IPS_LEXAddCommentController.search(str, caseRec);
        }
    }
   
    public static TestMethod void saveCommentsTest(){
        
         String profileId = [SELECT Id from Profile where Name='IPS Agent-Partner'].Id;
        core_IPS_LEXAddCommentController.partnerProf = profileId;
        core_IPS_LEXAddCommentController.partnerType = 'Not a Partner';
        User AccountOwner= TestUtilities.getAccountOwner();
        System.runAs(AccountOwner){
            list<Core_IPS_Labels__c> lstCs = new list<Core_IPS_Labels__c>();
        	lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Agent_Partner_Profile_id', value__c=profileId));
        	lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Profile_Name', value__c='IPS External Customer'));
        	insert lstCs;
            
        }
         
        
          System.runas(AccountOwner){
              Account acc = TestUtilities.getAccountRecord();
        	  acc.OwnerId = AccountOwner.Id; //Added by Nuthana
        	  insert acc;
        	  System.debug('owner Id'+acc.OwnerId);
              System.assert(acc.Id != null, 'Record not created');

        	Contact con = TestUtilities.getContact();
        	con.AccountId = acc.ID;
        	insert con;
        	System.assert(con.Id != null, 'Record not created');
              
          }
          Contact con = [select Id from Contact Limit 1];

        User uu = new User(
            ProfileId = profileId,
            LastName = 'last',
            Email = 'puser00012@amamama.com',
            Username = 'puser00012@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = con.Id);
        insert uu;
        System.assert(uu.Id != null, 'Record not created');

     /*   PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = uu.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = uu.id, PermissionSetId = ps1.Id );*/
        
        System.runAs(uu){ 
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = '';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = '';
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
        }
    }
    public static TestMethod void saveCommentsTest1(){
		String profileId = [SELECT Id from Profile where Name='Data Ops'].Id;
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
       	testuser.LanguageLocaleKey = 'en_US';
		testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        insert testuser;
        System.assert(testuser.Id != null, 'Record not created');

        PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps1.Id );
        
         System.runAs(testuser){ 
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = '';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = '';
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
        }
    }
    public static TestMethod void saveCommentsTest3(){
		String profileId = [SELECT Id from Profile where Name='Sales Ops'].Id;
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
       	testuser.LanguageLocaleKey = 'en_US';
		testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        insert testuser;
        System.assert(testuser.Id != null, 'Record not created');

         PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps1.Id );
       
         System.runAs(testuser){ 
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = '';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = '';
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
        }
    }public static TestMethod void saveCommentsTest41(){
		String profileId = [SELECT Id from Profile where Name='Production Support-IPS'].Id;
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
       	testuser.LanguageLocaleKey = 'en_US';
		testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        insert testuser;
        System.assert(testuser.Id != null, 'Record not created');

         PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps1.Id );
       
         System.runAs(testuser){ 
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = '';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = '';
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
        }
    }
    public static TestMethod void saveCommentsTest4(){
		String profileId = [SELECT Id from Profile where Name='Production Support-IPS'].Id;
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
       	testuser.LanguageLocaleKey = 'en_US';
		testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        insert testuser;
        System.assert(testuser.Id != null, 'Record not created');

         PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps1.Id );
       
         System.runAs(testuser){ 
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = '';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = '';
            caseWrapperObj.caseid = caseRec;
            //caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
        }
    }
    public static TestMethod void saveCommentsTest5(){
		String profileId = [SELECT Id from Profile limit 1].Id;
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
       	testuser.LanguageLocaleKey = 'en_US';
		testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        insert testuser;
		System.assert(testuser.Id != null, 'Record not created');

        PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps1.Id );
         System.runAs(testuser){ 
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = 'test';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = '';
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
        }
    }
    public static TestMethod void saveCommentsTest6(){
		String profileId = [SELECT Id from Profile where Name='Integration'].Id;
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
       	testuser.LanguageLocaleKey = 'en_US';
		testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        insert testuser;
        System.assert(testuser.Id != null, 'Record not created');

		PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps1.Id );
       
         System.runAs(testuser){ 
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = '';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = string.valueof(system.today()-1);
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
        }
    }
    
   static testmethod void testexception(){
        try{
       //core_IPS_LEXAddCommentController.saveComment(null);
	   core_IPS_LEXAddCommentController.search(null,null);
	   core_IPS_LEXAddCommentController.clear();
       core_IPS_LEXAddCommentController testcon=new core_IPS_LEXAddCommentController('');
        }
        catch(exception ex)
        {
            system.assert(ex!=null);
        }
      }
    public static TestMethod void saveCommentsTest2(){
		String profileId = [SELECT Id from Profile where Name='IPS External Customer'].Id;
        User AccountOwner= TestUtilities.getAccountOwner();
        System.runas(AccountOwner){
            Account accountRecord = new Account();
        accountRecord.recordTypeId = [select id from Recordtype where Developername='Mastered_Account'].id;
        accountRecord.Name = 'Test Account';
        accountRecord.Core_Account_Type__c = 'Distributor';
        accountRecord.Core_Sales_Segment__c = 'Compute';
        accountRecord.Industry = 'Banking';
        accountRecord.BillingCity = 'Delhi';
        accountRecord.BillingCountry = 'USA';
        accountRecord.billingState = 'AK';
        accountRecord.billingStreet = '10street';
        insert accountRecord;
        System.assert(accountRecord.Id != null, 'Record not created');

        contact con=new contact();
        con.firstname='testuser';
        con.lastname='1998';
        con.email='testuser1998@example.com';
        con.AccountId=accountRecord.Id;
        con.MailingCountry = 'India';
        insert con;
        System.assert(con.Id != null, 'Record not created');

            
        }
        Contact con=[Select Id from Contact limit 1];
         
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
       	testuser.LanguageLocaleKey = 'en_US';
		testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        testuser.ContactId=con.Id;
        insert testuser;
        System.assert(testuser.Id != null, 'Record not created');

         System.runAs(testuser){ 
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = '';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = '';
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
        }
    }
    
      public static TestMethod void saveCommentsPartnerTest(){
        
         String profileId = [SELECT Id from Profile where Name='Partner'].Id;
        core_IPS_LEXAddCommentController.partnerProf = profileId;
      /*   list<Core_IPS_Labels__c> lstCs = new list<Core_IPS_Labels__c>();
        lstCs.add(new Core_IPS_Labels__c(name='Core_Partner_Profile_Id', value__c=profileId));
        lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Profile_Name', value__c='IPS External Customer'));
        insert lstCs;*/
        /* UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
         Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
          User AccountOwner = new User(
            ProfileId = profile1.Id,
            LastName = 'last',
            Email = 'puser00012@example.com',
            Username = 'puser00012@example.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId=portalRole.Id
            );
        insert AccountOwner;*/
         User AccountOwner= TestUtilities.getAccountOwner();
          System.runas(AccountOwner){
              Account acc = TestUtilities.getAccountRecord();
        	  acc.OwnerId = AccountOwner.Id; //Added by Nuthana
        	  insert acc;
        	  System.debug('owner Id'+acc.OwnerId);
              System.assert(acc.Id != null, 'Record not created');

        	Contact con = TestUtilities.getContact();
        	con.AccountId = acc.ID;
        	insert con;
        	System.assert(con.Id != null, 'Record not created');
              
          }
          Contact con = [select Id from Contact Limit 1];
        

        User uu = new User(
            ProfileId = profileId,
            LastName = 'last',
            Email = 'puser00012@example.com',
            Username = 'puser00012@example.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = con.Id);
        insert uu;
        System.assert(uu.Id != null, 'Record not created');

		//PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        //PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        //insert new PermissionSetAssignment(AssigneeId = uu.id, PermissionSetId = ps.Id );
        //insert new PermissionSetAssignment(AssigneeId = uu.id, PermissionSetId = ps1.Id );
       
        System.runAs(uu){ 
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
           // core_IPS_LEXAddCommentController testcon=new core_IPS_LEXAddCommentController()
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = '';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = '';
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Private to Partner';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
        }
    }
     public static TestMethod void getFieldSetFieldsByFieldSetNameTest(){
        
             Case cs = TestUtilities.getCase();
             insert cs;
         	 System.assert(cs.Id != null, 'Record not created');

             core_IPS_LEXAddCommentController.getFieldSetFieldsByFieldSetName('Case', 'Case_Compact_Layout', cs.Id);
			 core_IPS_LEXAddCommentController.getRequiredValues(cs.Id);
         
     } 
    public static TestMethod void getCaseCommentsForLWCTest(){
        Case cs = TestUtilities.getCase();
        insert cs;
        core_IPS_LEXAddCommentController.getCaseCommentsForLWC(cs.id);
        
    }
    
}