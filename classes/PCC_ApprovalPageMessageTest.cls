/**************************************************************************************************
Apex Class Name:  PCC_ApprovalPageMessageTest
Version     : 1.0 
Created Date: 24 MAY 2024
Function    :This is a test class for PCC_ApprovalPageMessage
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------   
Shivini Sampath        24/5/2024        Original Version
*****************************************************************************************************/
@isTest
private class PCC_ApprovalPageMessageTest {

    @isTest
    static void testHasPermissionSet() {
        // Set up test data
        User testUser = createTestUser();
        insert testUser;
        System.runAs(testUser) {
            // Assign a Permission Set to the test user
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PCC_Deal_Reg_Internal_Admin' LIMIT 1];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = testUser.Id,
                PermissionSetId = ps.Id
            );
            insert psa;

            // Test the hasPermissionSet method
            Boolean hasPermission = PCC_ApprovalPageMessage.hasPermissionSet('PCC_Deal_Reg_Internal_Admin');
            System.assertEquals(true, hasPermission, 'The user should have the permission set assigned.');
        }
    }
    @isTest
    static void testHasPreapproverPermissionSet() {
        // Set up test data
        User testUser = createTestUser();
        insert testUser;
        System.runAs(testUser) {
            // Assign a Permission Set to the test user
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PCC_Deal_Reg_Channel_Ops' LIMIT 1];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = testUser.Id,
                PermissionSetId = ps.Id
            );
            insert psa;

            // Test the hasPermissionSet method
            Boolean hasPermission = PCC_ApprovalPageMessage.hasPreapproverPermissionSet('PCC_Deal_Reg_Channel_Ops');
            System.assertEquals(true, hasPermission, 'The user should have the permission set assigned.');
        }
    }

    @isTest
    static void testIsCoreDesignRegistrationProcessInstance() {
        // Create test users
        User testUser = createTestUser();
        insert testUser;
        User testUser1 = createTestUser();
        testUser1.UserName = 'standarduser1approval@testorgintel.com';
        insert testUser1;
        // Create test accounts
        List<Account> LstAcc = Core_Test_Utility.createAccount(6);
        Id accountRecordTypeIntel = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        for (Account acc : LstAcc) {
            acc.RecordTypeId = accountRecordTypeIntel;
            acc.OwnerId=testUser.Id;
        }
        insert LstAcc;
        // RunAs a system user to perform DML on setup objects
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Query for the existing public groups
            Group publicGroup = [SELECT Id FROM Group WHERE Name = 'AGS_Deal Reg- ASMO' LIMIT 1];
            Group publicGroup1 = [SELECT Id FROM Group WHERE Name = 'AGS_Channel Ops Approver Group' LIMIT 1];
            // Assign testUser to the existing public group
            GroupMember gm1 = new GroupMember(GroupId = publicGroup.Id, UserOrGroupId = testUser.Id);
            insert gm1;
            // Assign testUser1 to the existing public group
            GroupMember gm2 = new GroupMember(GroupId = publicGroup1.Id, UserOrGroupId = testUser1.Id);
            insert gm2;
        }
        // Continue the test as the first test user
        System.runAs(testUser) {
            // Assign a Permission Set to the test user
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PCC_Deal_Reg_Internal_Admin' LIMIT 1];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = testUser.Id,
                PermissionSetId = ps.Id
            );
            insert psa;  
        }
        // Continue the test as the second test user
        System.runAs(testUser1) {
            // Assign a Permission Set to the second test user
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'PCC_Deal_Reg_Channel_Ops' LIMIT 1];
            PermissionSetAssignment psa1 = new PermissionSetAssignment(
                AssigneeId = testUser1.Id,
                PermissionSetId = ps1.Id
            );
            insert psa1;
            Id dealRecordTypeIDLocked = Schema.getGlobalDescribe().get('Core_Design_Registration__c').getDescribe().getRecordTypeInfosByName().get('Deal Registration - Locked').getRecordTypeId();            
            List< Core_Design_Registration__c> dealRec = Core_DDR_Utility.createDDR(2);
            dealRec[0].Core_Vertical_Market_Nm__c='Education';
            dealRec[0].Core_Partner_Account_Id__c=LstAcc[0].id;
            dealRec[0].Core_Product_Segment_Nm__c='Client Computing';
            dealRec[0].Core_Product_Application_Nm__c='Business Desktop';
            dealRec[0].Core_Partner_FAE_Nm__c='Test FAE';
            dealRec[0].Core_Partner_FSR_Nm__c='Test FSR';
            dealRec[0].Core_End_Customer_Nm__c='Arrow Electronics Account';
            dealRec[0].Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
            dealRec[0].Core_End_Customer_Street_Addr_Line2_Txt__c='';
            dealRec[0].PCC_End_Customer_Country__c='India';
            dealRec[0].Core_End_Customer_City_Nm__c='Bangalore';
            dealRec[0].Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
            dealRec[0].Core_End_Customer_Postal_Cd__c='758854';
            dealRec[0].Core_End_Customer_Contact_Title_Txt__c='Mr.';
            dealRec[0].Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
            dealRec[0].Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
            dealRec[0].Core_End_Customer_Contact_Phone_Txt__c='7826499722';
            dealRec[0].Core_Manufacturing_Region_Cd__c='ASMO';
            dealRec[0].Core_First_Customer_Ship_Dt__c = system.today()+21;
            dealRec[0].Core_Production_End_Dt__c = system.today()+22;
            dealRec[0].Core_Intel_Platform_Nm__c='Agilex';
            dealRec[0].Core_Design_Registration_Nm__c='Test DR Name Arrow';
            dealRec[0].Core_Design_Registration_Dsc__c='Test Des';
            dealRec[0].DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
            dealRec[0].Core_End_Customer_URL__c = 'Test';
            dealRec[0].Core_Design_Registration_Status_Nm__c ='Pre-Approved';
            dealRec[0].PCC_Pricing_End_Date__c = system.today()-4;
            dealRec[0].PCC_Pricing_Start_Date__c = system.today()-2;
            dealRec[0].PCC_Deal_Description__c='Test';
            dealRec[0].PCC_End_Customer_Use__c='Test';
            dealRec[0].PCC_Competition_Assumptions__c='Test';
            dealRec[0].PCC_Intel_Response_Requested_By_Date__c=system.today();
            dealRec[0].PCC_Proposal_Due_Date__c = system.today()-2;
            dealRec[0].Core_Opportunity_Decision_Dt__c = system.today()+2;
            dealRec[0].PCC_Consumption_Countries__c='INDIA';
            dealRec[0].PCC_Current_EndCustomer_Product_Provider__c='test'; 
            dealRec[0].Core_End_Customer_Account_Id__c=LstAcc[0].id;
            dealRec[0].PCC_Approval_Level__c='Level 1' ; 
            dealRec[0].L2_Approver__c = testUser.id;  
            dealRec[0].Level2_approver_type__c='L2 Approver';
            dealRec[0].Core_Approver_Grp_Nm__c='AGS_Deal Reg- ASMO';            
            dealRec[0].recordTypeId =  dealRecordTypeIDLocked;
            insert dealRec;
            dealRec[0].Level2_approver_type__c='L2 Approver';
            dealRec[0].Core_Approver_Grp_Nm__c='AGS_Deal Reg- ASMO';    
            update dealRec;
            System.debug('l222222222--->'+dealRec[0].L2_Approver__c);
            List<Id> nextApproverIds = new List<Id>{testUser.Id};
            Test.startTest();
                // Create an approval request for the account
                Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(dealRec[0].id);
                /* Submit on behalf of a specific submitter*/
                req1.setSubmitterId(testUser1.Id); 
                req1.setNextApproverIds(nextApproverIds);
                /* Submit the record to specific process and skip the criteria evaluation*/
                req1.setProcessDefinitionNameOrId('PCC_Deal_Reg_Approval_Process');
                req1.setSkipEntryCriteria(true);
                Approval.ProcessResult result = Approval.process(req1);
                List<Id> newWorkItemIds = result.getNewWorkitemIds();
            
            // Create a ProcessInstance for the test record
            List<ProcessInstanceWorkitem> piwList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :result.getInstanceId() LIMIT 1];
            Boolean isCorrectType = PCC_ApprovalPageMessage.objectTypedetail(piwList[0].Id);
            // Verify the result
            System.assertEquals(true, isCorrectType, 'The record should be associated with a Core_Design_Registration__c process instance.');
     try {
                Approval.ProcessWorkitemRequest req2 = 
                 new Approval.ProcessWorkitemRequest();
                req2.setComments('Approving request.');
                req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                // Use the ID from the newly created item to specify the item to be worked
                req2.setWorkitemId(newWorkItemIds.get(0));
                req2.setAction('Approve');
                Approval.ProcessResult result2 =  Approval.process(req2);
                Test.stopTest();
                Boolean isCorrect = PCC_ApprovalPageMessage.objectTypedetail(result2.getInstanceId());
            }
    catch(Exception e) {
    System.debug('Exception ' + e);
     }
}

    }

    // Helper method to create a test user
    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User(
            Alias = 'standt',
            Email = 'standarduser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduserapproval@testorgintel.com'
        );
        return u;
    }
}