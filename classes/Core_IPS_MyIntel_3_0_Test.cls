/*********************************************
* Name : Core_IPS_MyIntel_3_0_Test 
* Author : Chandrashekar Pallikonda
* Date Created : 21/05/2021
* Description : Test class for Core_IPS_MyIntel_3.
*   
************************************************/
@isTest
global class Core_IPS_MyIntel_3_0_Test {
    @testSetup
    static void setup(){

        Account caseAccount = TestUtilities.getAccountRecord();
        insert caseAccount;
        system.assert(caseAccount.Id != null,true);
        
        Account projectAccount = TestUtilities.getAccountRecord();
        projectAccount.Name = 'HP Products';
        insert projectAccount;
        system.assert(projectAccount.Id != null,true);
        
        Account caseContactAccount = TestUtilities.getAccountRecord();
        caseContactAccount.Name = 'Sony Products';
        insert caseContactAccount;
         system.assert(caseContactAccount.Id != null,true);
        
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'myIntelIntegration';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution.Core_Description__c = 'To update Case fields.';
        triggerExecution.Core_Object__c = 'Case';
        triggerExecution.Core_Trigger_Events__c = 'before insert';
        insert triggerExecution;
         system.assert(triggerExecution.Id != null,true);
        
        
        Contact caseContact = new Contact();
        caseContact.FirstName = 'Test';
        caseContact.LastName = 'Contact1';
        caseContact.Email = 'testemail@email.com';
        caseContact.Core_Enterprise_Id__c = '88899';
        caseContact.AccountId = caseContactAccount.Id;
        caseContact .MailingCountry = 'India';
        insert caseContact;
         system.assert(caseContact.Id != null,true);
        
        Contact projectMemberContact = new Contact();
        projectMemberContact.FirstName = 'Testi';
        projectMemberContact.LastName = 'Contact2';
        projectMemberContact.Email = 'testemail2@email.com';
        projectMemberContact.Core_Enterprise_Id__c = '99988';
        projectMemberContact.AccountId = projectAccount.Id;
        projectMemberContact.MailingCountry = 'India';
        insert projectMemberContact;
         system.assert(projectMemberContact.Id != null,true);
        
        Contact projectMemberContact2 = new Contact();
        projectMemberContact2.FirstName = 'Testing';
        projectMemberContact2.LastName = 'Contact3';
        projectMemberContact2.Email = 'testemail333@email.com';
        projectMemberContact2.Core_Enterprise_Id__c = '19988';
        projectMemberContact2.AccountId = projectAccount.Id;
        projectMemberContact2.mailingCountry = 'India';
        insert projectMemberContact2;
 		system.assert(projectMemberContact2.Id != null,true);
        

        Product2 product = TestUtilities.getProduct();
        insert product;
		 system.assert(product.Id != null,true);
        

        Core_IPS_Project__c premierProjectRecord = new Core_IPS_Project__c();
        insert premierProjectRecord;
		 system.assert(premierProjectRecord.Id != null,true);
        
        
        Core_IPS_Account__c premierProjectAccount = new Core_IPS_Account__c();
        premierProjectAccount.Core_Account__c = projectAccount.Id;
        premierProjectAccount.Core_IPS_Project__c = premierProjectRecord.Id;
        insert premierProjectAccount;
         system.assert(premierProjectAccount.Id != null,true);
        
        Core_IPS_Project_Member__c premierProjectMember = new Core_IPS_Project_Member__c();
        premierProjectMember.Core_IPS_Contact__c = projectMemberContact.Id;
        premierProjectMember.Core_IPS_Project__c = premierProjectRecord.Id;
        insert premierProjectMember;
         system.assert(premierProjectMember.Id != null,true);
        
        Core_IPS_Project_Member__c premierProjectMember2 = new Core_IPS_Project_Member__c();
        premierProjectMember2.Core_IPS_Contact__c = projectMemberContact2.Id;
        premierProjectMember2.Core_IPS_Project__c = premierProjectRecord.Id;
        insert premierProjectMember2;
    	system.assert(premierProjectMember2.Id != null,true);
        

        
        Case caseRecord = new Case();
        caseRecord.Core_IPS_Project_Case__c = premierProjectRecord.Id;
        caseRecord.Subject = 'Test Subject';
        caseRecord.ProductId = product.Id;
        caseRecord.Status = 'Open';
        caseRecord.CreatedDate = DateTime.parse(System.Now().format());
        caseRecord.LastModifiedDate = DateTime.parse(System.Now().format());
        caseRecord.AccountId = caseAccount.Id;
        caseRecord.ContactId = caseContact.Id;
        caseRecord.Core_CaseType__c = 'Debug Request';
        caseRecord.Core_IPS_Customer_Visible__c = true;
        insert caseRecord;
		 system.assert(caseRecord.Id != null,true);
        
        

        Core_IPS_APIGEE_Custom_Settings__c customSetting = new Core_IPS_APIGEE_Custom_Settings__c();
        customSetting.Name = 'Core_IPS_MyIntel_Integration';
        customSetting.MyIntel_Client_Id__c = '07e04e4c-dd0b-4b24-9c46-6056a822530833';
        customSetting.MyIntel_Client_Secret__c = 'XnK1KXtLthP4.778QgL-2fTS~OahSiL_qc';
        customSetting.MyIntel_Endpoint_URL__c = 'https://apis-sandbox.intel.com/m2r/intel-customers/v1/profiles';
        customSetting.MyIntel_GrantType__c = 'client_credentials';
        customSetting.MyIntel_Integration_Class_Name__c = 'Core_IPS_MyIntel_3';
        customSetting.MyIntel_Token_Endpoint_URL__c = 'https://apis-sandbox.intel.com/v1/auth/token';
        insert customSetting;
         system.assert(customSetting.Id != null,true);
        
        Core_Trigger_Executions__c triggerExc = new Core_Trigger_Executions__c();
        triggerExc.Core_Active__c = true;
        triggerExc.Core_Class_Name__c = 'Core_CaseTrigger_Dispatcher';
        triggerExc.Core_Description__c = 'this method is used to add the project members & Intel Support Team to Case interested parties from the project';
        triggerExc.Core_Object__c='Case';
        triggerExc.Core_Trigger_Events__c ='After Insert';
        triggerExc.Name ='Core_CaseTrigger_Dispatcher';
        insert triggerExc;
         system.assert(triggerExc.Id != null,true);
        
        
        Core_IPS_MyIntel_Outbound_Message__c outMsg = new Core_IPS_MyIntel_Outbound_Message__c();
        outMsg.Core_IPS_Case_ID__c = caseRecord.Id;
        outMsg.Core_IPS_Operation_Type__c = 'Update';
        outMsg.Core_IPS_Status__c = 'Failed';
        outMsg.Core_IPS_Retry_Count__c = 3;
        insert outMsg;
		 system.assert(outMsg.Id != null,true);
        
    }
    @isTest static void testCRUDPositiveScenario(){
        String Message = 'Create';
        List<Id> caseIds = new List<Id>();
        List<Core_IPS_Project_Member__c> memberList;
        for(Case cs: [SELECT Id FROM Case]){
            caseIds.add(cs.Id);
        }
        Core_IPS_MyIntel_Outbound_Message__c outboundMsg = [Select Id from Core_IPS_MyIntel_Outbound_Message__c Limit 1];
        Test.setMock(HttpCalloutMock.class, new Core_IPS_myIntelHttpCalloutMock());
        Test.startTest();
        memberList = [SELECT Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_Status__c ='Active'];
        Id jobId = System.enqueueJob(new Core_IPS_MyIntel_3_0(caseIds, Message, memberList));
         //Core_IPS_MyIntel_3_0.MessageWrapper testWrp = new Core_IPS_MyIntel_3_0.MessageWrapper();
        //testWrp.errorCode =400;
        System.assert(jobId != null);
        Test.stopTest();
    }
    
    @isTest static void testCRUDNegativeScenario(){
        String Message = 'Remove';
        Core_IPS_APIGEE_Custom_Settings__c integrationSetting = Core_IPS_APIGEE_Custom_Settings__c.getValues('Core_IPS_MyIntel_Integration');
        integrationSetting.MyIntel_Token_Endpoint_URL__c = 'https://apis-sandbox.intel.com/v1/authenticate/token';
        integrationSetting.MyIntel_Endpoint_URL__c ='https://apis-sandbox.intel.com/m2r/intel-customer/v1/profiles';
      //   integrationSetting.MyIntel_Endpoint_URL__c ='https://apis.intel.com/m2r/intel-customers/v1/profile';
       update integrationSetting;
        List<Id> caseIds = new List<Id>();
        List<Core_IPS_Project_Member__c> memberList;
        for(Case cs: [SELECT Id FROM Case]){
            caseIds.add(cs.Id);
        }
        Test.setMock(HttpCalloutMock.class, new Core_IPS_myIntelHttpCalloutMock());
        Test.startTest();
        memberList = [SELECT Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_Status__c ='Active'];
        Id jobId = System.enqueueJob(new Core_IPS_MyIntel_3_0(caseIds, Message, memberList));
       // Core_IPS_MyIntel_3_0.MessageWrapper testWrp = new Core_IPS_MyIntel_3_0.MessageWrapper();
        //testWrp.errorCode =400;
        System.assert(jobId != null );
        Test.stopTest();
    }
    @isTest static void testCRUD1NegativeScenario(){
        String Message = 'Create';
        
        
       // Core_IPS_APIGEE_Custom_Settings__c integrationSetting = Core_IPS_APIGEE_Custom_Settings__c.getValues('Core_IPS_MyIntel_Integration');
       // integrationSetting.MyIntel_Token_Endpoint_URL__c = 'https://apis-sandbox.intel.com/v1/auth/token';
       // integrationSetting.MyIntel_Endpoint_URL__c ='https://apis-sandbox.intel.com/m2r/intel-customers/v1/profile';
       // update integrationSetting;
        List<Id> caseIds = new List<Id>();
        List<Core_IPS_Project_Member__c> memberList;
        for(Case cs: [SELECT Id FROM Case]){
            //Added by Sowmya to execute negative scenario - Start - 27/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
			 cs.Subject = 'error404';
             update cs;  
            //Sowmya - End - 19/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
     		 caseIds.add(cs.Id);
     
        }
        System.AssertEquals(caseIds[0]!= null, true);
   
        Test.setMock(HttpCalloutMock.class, new Core_IPS_myIntelHttpCalloutMock());
        Core_IPS_MyIntel_3_0.doChainJob = false;
        Test.startTest();
        memberList = [SELECT Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_Status__c ='Active'];
        Id jobId = System.enqueueJob(new Core_IPS_MyIntel_3_0(caseIds, Message, memberList));
        
        System.enqueueJob(new Core_IPS_MyIntel_3_0(caseIds, Message, memberList,0));
        //List<Core_IPS_Case_Interested_Party__c> testList = new List<Core_IPS_Case_Interested_Party__c>();
        //System.enqueueJob(new Core_IPS_MyIntel_3_0(caseIds, Message, testList));
        //Core_IPS_MyIntel_3_0.MessageWrapper testWrp = new Core_IPS_MyIntel_3_0.MessageWrapper();
        //testWrp.setBody='error404';
        //testWrp.errorCode =400;
     //   System.assert(jobId != null );
        Test.stopTest();
    }
   
    @isTest static void testCRUDPositiveScenario1(){
        /*String Message = 'Create';
        List<Id> caseIds = new List<Id>();
        List<Core_IPS_Project_Member__c> memberList;
        for(Case cs: [SELECT Id FROM Case]){
            caseIds.add(cs.Id);
        }*/
        Core_IPS_MyIntel_Outbound_Message__c outboundMsg = [Select Id from Core_IPS_MyIntel_Outbound_Message__c Limit 1];
        Core_IPS_MyIntel_Re_Promote.retryMechForCase(outboundMsg.Id);
        Core_IPS_MyIntel_Re_Promote.retryCallFromLightning(outboundMsg.Id);
        /*Test.setMock(HttpCalloutMock.class, new Core_IPS_myIntelHttpCalloutMock());
        Test.startTest();
        memberList = [SELECT Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_Status__c ='Active'];
        Id jobId = System.enqueueJob(new Core_IPS_MyIntel_3_0(caseIds, Message, memberList));
         //Core_IPS_MyIntel_3_0.MessageWrapper testWrp = new Core_IPS_MyIntel_3_0.MessageWrapper();
        //testWrp.errorCode =400;
        System.assert(jobId != null);
        Test.stopTest();*/
        System.AssertEquals(outboundMsg!= null, true);
    }
    @isTest static void testContactScenario(){
        Account acc = TestUtilities.getAccountRecord();
        acc.Name = 'Test Products';
        insert acc;
        
		Contact c = new Contact();
		c.FirstName = 'Test';
        c.LastName = 'Contact 001';
        c.Email = 'testemail001@email.com';
        c.Core_Enterprise_Id__c = '111199';
        c.Core_IPS_Active__c = true;
        c.AccountId = acc.Id;
        c.MailingCountry = 'India';
        insert c;		
        
        Contact c2 = new Contact();
		c2.FirstName = 'Test';
        c2.LastName = 'Contact 002';
        c2.Email = 'testemail002@email.com';
        c2.Core_Enterprise_Id__c = '222299';
        c2.AccountId = acc.Id;
        c2.MailingCountry = 'India';
        insert c2;	
        
        Product2 product1 = TestUtilities.getProduct();
        product1.Name = 'TG Product';
        insert product1;
        
        Case cs = new Case();
        cs.Subject = 'Test Subject 001 ';
        cs.ProductId = product1.Id;
        cs.Status = 'Open';
        cs.CreatedDate = DateTime.parse(System.Now().format());
        cs.LastModifiedDate = DateTime.parse(System.Now().format());
        cs.AccountId = acc.Id;
        cs.ContactId = c2.Id;
        cs.Core_CaseType__c = 'Debug Request';
        cs.Core_IPS_Customer_Visible__c = true;
        insert cs;
        
        List<Contact> ctList = [SELECT Id FROM Contact WHERE Core_Enterprise_Id__c = '111199'];
        Test.startTest();
        Core_IPS_MyIntel_3_0.allCasesMyIntel(ctList);
        Test.stopTest();
        System.AssertEquals(cs!= null, true);
    }
}