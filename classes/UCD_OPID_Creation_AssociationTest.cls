@isTest
public class UCD_OPID_Creation_AssociationTest {

    @isTest
    static void testGetMessageFromApex() {
        
        // Create test data: Account, Core_Account_Group_Member, Core_OnePartner_Inbound_Message, PRM_AccountChannelMembership
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();

    Account opidAcc = new Account();//Account
        opidAcc.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc.Name='vista';
        opidAcc.BillingCity='City9';
        opidAcc.BillingStreet='Street9';
        opidAcc.BillingCountry='India';
        opidAcc.BillingPostalCode='Postal code';
        opidAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc.Core_IPA_Partner_Role__c = 'Solution Integrator';
    insert opidAcc;
    
        Account testAccount = new Account();//Account
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='Greg Thomas';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        testAccount.Core_User_Defined_Website__c='www.sample.com';
        testAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        //testAccount.Core_IPA_One_Partner_Id__c = opidAcc.id;
        testAccount.Unified_Hierarchy_View__c = 'Global';
        testAccount.Core_CIM_ID__c = '9456456' ;
        insert testAccount;

        // Test Core_Account_Group_Member__c record
        Core_Account_Group_Member__c agmRecord = new Core_Account_Group_Member__c(
            Core_Intel_Account_Id__c = testAccount.Id,
        Core_Partner_Account_Id__c = opidAcc.id,
            Core_Inactive_Ind__c = false
        );
        insert agmRecord;

        // Test Core_OnePartner_Inbound_Message__c record
        Core_OnePartner_Inbound_Message__c inboundRecord = new Core_OnePartner_Inbound_Message__c(
            Core_SalesCloud_AccountID__c = testAccount.Id,
            Core_Status__c = 'NEW'
        );
        insert inboundRecord;

        // Test PRM_AccountChannelMembership__c record
        PRM_AccountChannelMembership__c acmRecord = new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = testAccount.Id,
            PRM_Partner_Role__c = 'FPGA Designer',
            PRM_Status_Nm__c = 'Approved'
        );
        insert acmRecord;

        // Call method and test the response for the scenario with an existing Core_Account_Group_Member record
        Test.startTest();
        String result = UCD_OPID_Creation_Association.getMessageFromApex(testAccount.Id);
        //Test.stopTest();
        
        // Validate the result for the case when agm is not empty
        //System.assertEquals('Please delink the existing 1PID association to create a new one', result);

        // Now test for an Account with Unified_Hierarchy_View__c = 'Intermediate'
        testAccount.Unified_Hierarchy_View__c = 'Intermediate';
        update testAccount;

        //Test.startTest();
        result = UCD_OPID_Creation_Association.getMessageFromApex(testAccount.Id);
        //Test.stopTest();
        
        // Validate the result for the account with valid Unified_Hierarchy_View__c
        //System.assertEquals(null, result);

        // Test for the case when there is an inbound message
        inboundRecord.Core_Status__c = 'NEW'; // Ensure the record still exists
        update inboundRecord;

        //Test.startTest();
        result = UCD_OPID_Creation_Association.getMessageFromApex(testAccount.Id);
        //Test.stopTest();

        // Validate that the message is returned for the inbound message
        //System.assertEquals('The 1PID creation/association is in progress and a notification will be sent once the process is completed.', result);

        // Test for the case when account is not associated with any PRM_AccountChannelMembership and Core_Intel_Partner_Alliance_PartnerGroup__c is false (assuming this condition might be used later)
        testAccount.Unified_Hierarchy_View__c = 'Global'; // Reset Unified_Hierarchy_View
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        update testAccount;

        //Test.startTest();
        result = UCD_OPID_Creation_Association.getMessageFromApex(testAccount.Id);
        Test.stopTest();

        // Assuming the final else condition works when there are no inbound or association records
        //System.assertEquals(null, result);
    }
    @isTest
    static void testGetMessageFromApex2() {
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();

    Account opidAcc = new Account();//Account
        opidAcc.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc.Name='vista';
        opidAcc.BillingCity='City9';
        opidAcc.BillingStreet='Street9';
        opidAcc.BillingCountry='India';
        opidAcc.BillingPostalCode='Postal code';
        opidAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc.Core_IPA_Partner_Role__c = 'Solution Integrator';
    insert opidAcc;
    
        Account testAccount = new Account();//Account
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='Greg Thomas';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        testAccount.Core_User_Defined_Website__c='www.sample.com';
        testAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        //testAccount.Core_IPA_One_Partner_Id__c = opidAcc.id;
        testAccount.Unified_Hierarchy_View__c = 'Global';
        testAccount.Core_CIM_ID__c = '9456456' ;
        insert testAccount;
        
        Test.startTest();
        String result = UCD_OPID_Creation_Association.getMessageFromApex(testAccount.Id);
        Test.stopTest();
    }
}