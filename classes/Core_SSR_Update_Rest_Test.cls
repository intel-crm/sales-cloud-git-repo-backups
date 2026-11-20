/**************************************************************************************
* Apex Class Name   : Core_SSR_Update_Rest_Test 
* Created Date      : July 27th, 2017
* Description       : Test Class for Core_SSR_Update_Rest 
* Modification Log  :
* Developer           Date               Description
* ----------------------------------------------------------------------------    
* Rangesh Kona    : Version 1:  Aug 22nd, 2017  Initial Deployed Version
*************************************************************************************/
@isTest
private class Core_SSR_Update_Rest_Test {
    
    @testsetup
    static void setupData() {
        
        // select standard Profile
        Id profId = [select Id from Profile where Name='Standard User' limit 1][0].Id;
        
        // create User Record
        User testUser =   new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User 1', Email='test.user1@intel.com',
                                   Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                                   ProfileId=profId, LanguageLocaleKey='en_US');
        insert testUser;
        List<User> testUsers =[select id from User where Id=: testUser.Id];
        system.assertEquals(1,testUsers.size());
        
        
        // create Account Record
        Id recAccountTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
        Account testAccount =   new Account(Name='Test SMG SSR Account', RecordTypeId=recAccountTypeId,
                                            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA');
        insert testAccount;      
        List<Account> testAccounts = [select id from Account where Id =: testAccount.Id];
        system.assertEquals(1, testAccounts.size());
        
        
        // create Opty Record
        Id recOpportunityTypeId = [select Id from RecordType where DeveloperName = 'Core_Opportunity' limit 1][0].Id;
        Opportunity testOpportunity = new Opportunity(Name='Test SSG Support Request with Account',
                                                      AccountId=testAccount.Id, StageName='Qualifying', RecordTypeId=recOpportunityTypeId,
                                                      CloseDate=System.Date.today().addYears(1), OwnerId=testUser.Id);
        
        insert testOpportunity;
        List<Opportunity> testOpportunities = [select id from Opportunity where Id =: testOpportunity.Id];
        system.assertEquals(1, testOpportunities.size());
        
        
    }
    
    // Test Method to update SSR Status
    public static testmethod void Core_SSR_Update_Status() {
        
        // get opportunity id
        Opportunity testOpportunity = [select id from Opportunity where Name = 'Test SSG Support Request with Account'];
        Id opportunity_id = testOpportunity.Id;
       
        // get record type id
        Id recordTypeId = Schema.SObjectType.Core_Sales_Support_Request__c.getRecordTypeInfosByName().get(System.Label.Core_SSR_Record_Type).getRecordTypeId();
        
        String Service_Request_Type         = 'Engineering Request';                            
        String Description                  = 'Test Description for SMG SSR ';                  
        String Subject                      = 'Test Subject for SMG SSR';  
        String DRD_ID                       = 'DRD_SMG-001';
       
        Boolean User_Agreed_to_Share_Opty   = true;                     // User_Agreed_to_Share_Opty blank
        Date deadlineForResults             =  Date.valueOf('2013-05-05');

       
        // Create Sales Support Request
        Core_Sales_Support_Request__C SMGSupportRequest = 
            new Core_Sales_Support_Request__C(Core_DRD_Description__c = description, 
                                              Core_Opportunity__C = opportunity_id,
                                              Core_DRD_Request_Type__c=Service_Request_Type,
                                              Core_DRD_Subject__c=subject,
                                              Core_DRD_Deadline_for_Results__C=deadLineForResults,
                                              Core_External_ID__C=DRD_ID,
                                              RecordTypeId=recordTypeId
                                              
                                             );
        insert SMGSupportRequest;
        String  SSR_ID      = SMGSupportRequest.Id;
   
        System.assert(SSR_ID != null);
        
        List<Core_Sales_Support_Request__C> ssr = [select Core_DRD_Subject__c,Core_DRD_Request_Type__c from Core_Sales_Support_Request__C];
        System.assertEquals(1, ssr.size());
        System.assertEquals('Test Subject for SMG SSR', ssr[0].Core_DRD_Subject__c);
        System.assertEquals('Engineering Request', ssr[0].Core_DRD_Request_Type__c);
        
        String  Status      = 'Ready to Assign';
        String  CaseOwner   = 'Test Case Owner';        
        
        // Set up a test request
        RestRequest request = new RestRequest();
        
        // Set request properties
        request.requestUri = System.Label.Core_SSR_Update_Endpoint + '/services/apexrest/UpdateSSRStatus/updateStatus';
        
        // set Http Method
        request.httpMethod = 'Post';
     
        // Set request Body parameters
        request.requestBody = Blob.valueof('{"ssrobj":[ {"SSR_ID":"' + DRD_ID + '","Status":"' + Status + '", "CaseOwner":"' + CaseOwner + '" }]}');
        
        // Finally, assign the request to RestContext if used
        RestContext.request = request;
        
        String Results = Core_SSR_Update_Rest.updateStatus();
        
        // DRD system excepts what's the stored value to cross verify whether update thru fine or not            
        Core_Sales_Support_Request__C SSR_Obj_After_Update =  [select Id,Status__c, Core_DRD_Case_Owner__c from Core_Sales_Support_Request__C where core_external_id__C  = :DRD_ID];
        System.assertEquals('Ready to Assign', SSR_Obj_After_Update.Status__c);
        System.assertEquals('Test Case Owner', SSR_Obj_After_Update.Core_DRD_Case_Owner__c );
        
    
    }
    
}