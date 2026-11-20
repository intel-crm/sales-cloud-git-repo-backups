@isTest
public class PRM_IPAR_IPAMembershipTransformBatchTest {
    
    @testSetup
    static void setupTestData() {
        // Query existing Record Types (assuming they already exist in the Salesforce org)
        RecordType partnerAccountGroupRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Core_Partner_Account_Group' AND SObjectType = 'Account' LIMIT 1];
        RecordType intelAccountRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Mastered_Account' AND SObjectType = 'Account' LIMIT 1];

        // Create Accounts for testing
        Account account1 = new Account(
            Name = 'Test Account 1',
            RecordTypeId = partnerAccountGroupRecType.Id,
            Core_Deactivated__c = false,
            Core_Intel_Partner_Alliance_PartnerGroup__c = true,
            BillingCity='Bangalore',
            BillingStreet = 'Street ',
            BillingCountry = 'India',
            BillingPostalCode = 'Postal Code ',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Industry = 'Agriculture'
            
        );

        Account account2 = new Account(
            Name = 'Test Account 2',
            RecordTypeId = partnerAccountGroupRecType.Id,
            Core_Deactivated__c = false,
            Core_Intel_Partner_Alliance_PartnerGroup__c = true,
            BillingCity='Bangalore',
            BillingStreet = 'Street ',
            BillingCountry = 'India',
            BillingPostalCode = 'Postal Code ',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Industry = 'Agriculture'
            
        );

        Account account3 = new Account(
            Name = 'Test Account 3',
            RecordTypeId = partnerAccountGroupRecType.Id,
            Core_Deactivated__c = false,
            Core_Intel_Partner_Alliance_PartnerGroup__c = true,
            BillingCity='Bangalore',
            BillingStreet = 'Street ',
            BillingCountry = 'India',
            BillingPostalCode = 'Postal Code ',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Industry = 'Agriculture'
            
        );
        
        insert new List<Account>{account1, account2,account3};
	// Create Core_Account_Group_Member__c records
        Core_Account_Group_Member__c accountGroupMember = new Core_Account_Group_Member__c(
            Core_Partner_Account_Id__c = account1.Id, 
            Core_Intel_Account_Id__c = account2.Id,
            Core_Inactive_Ind__c = false
        );
        insert accountGroupMember;
        
        PRM_AccountChannelMembership__c membership1 = new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = account1.Id,
            PRM_Status_Nm__c = 'Approved',
            PRM_Status_Reason_Txt__c = 'Test class',
            PRM_Partner_Role__c='Guest'
        );
        
        PRM_AccountChannelMembership__c membership2 = new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = account2.Id,
            PRM_Status_Nm__c = 'Approved',
            PRM_Status_Reason_Txt__c = 'Test class',
            PRM_Partner_Role__c='Independent Software Vendor'
        );
        
        insert new List<PRM_AccountChannelMembership__c>{membership1, membership2};
        // Create PRM_Profile_Questions__c for all possible question codes
        List<PRM_Profile_Questions__c> questions = new List<PRM_Profile_Questions__c>();
        String[] questionCodes = new String[]{
            'PRM_Opt_In', 'PRM_Point_Not_Eligible', 'PRM_Status', 
            'PRM_Status_date', 'PRM_ODM_Whitebox_Point', 'PRM_Branded_Point',
            'PRM_Component_point','IPA_Registration_Source'
        };

        for (String code : questionCodes) {
            questions.add(new PRM_Profile_Questions__c(
                PRM_Question_Cd__c = code
            ));
        }
        insert questions;

        // Create PRM_Profile_Responses__c records for each question code
        List<PRM_Profile_Responses__c> profileResponses = new List<PRM_Profile_Responses__c>();
        for (PRM_Profile_Questions__c question : questions) {
            if (question.PRM_Question_Cd__c == 'PRM_Opt_In') {
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account1.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = '01/01/2025'
                ));
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account2.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'FALSE'
                ));
                 profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account3.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'TRUE'
                ));
            } else if (question.PRM_Question_Cd__c == 'PRM_Point_Not_Eligible') {
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account2.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'TRUE',
                    PRM_Reason_Text__c = 'Test reason'
                ));
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account1.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'FALSE',
                    PRM_Reason_Text__c = 'Test reason'
                ));
            } else if (question.PRM_Question_Cd__c == 'PRM_Status') {
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account1.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'Active',
                    PRM_Reason_Text__c = 'Status reason'
                ));
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account2.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'Not Eligible',
                    PRM_Reason_Text__c = 'Status reason'
                ));
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account3.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'Eligible',
                    PRM_Reason_Text__c = 'Status reason'
                ));
            } else if (question.PRM_Question_Cd__c == 'PRM_Status_date') {
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account2.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = '2023-02-01'
                ));
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account1.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = '2023-02-01'
                ));
            } else if (question.PRM_Question_Cd__c == 'PRM_ODM_Whitebox_Point') {
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account2.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'TRUE'
                ));
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account1.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'FALSE'
                ));
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account3.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = '10/05/2025'
                ));
            } else if (question.PRM_Question_Cd__c == 'PRM_Branded_Point') {
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account2.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'TRUE'
                ));
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account1.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'FASLE'
                ));
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account3.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = '10/05/2025'
                ));
            } else if (question.PRM_Question_Cd__c == 'PRM_Component_point') {
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account2.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = '2023-03-01'
                ));
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account3.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'TRUE'
                ));
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account1.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'FALSE'
                ));
            }else if (question.PRM_Question_Cd__c == 'IPA_Registration_Source') {
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account2.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'Mobile'
                ));
                profileResponses.add(new PRM_Profile_Responses__c(
                    PRM_Account_Id__c = account1.Id,
                    PRM_Profile_Questions_Id__c = question.Id,
                    PRM_Response_Txt__c = 'Mobile'
                ));
            }
        }
        insert profileResponses;
       
         
    }

    
    @isTest
    static void testBatchExecution1() {
        Test.startTest();
            Account acc= [Select id from Account where name='Test Account 1' limit 1];
            String accountId = String.valueOf(acc.Id);
            PRM_IPAR_IPAMembershipTransformBatch batch = new PRM_IPAR_IPAMembershipTransformBatch(accountId);
            // Run the batch
            Database.executeBatch(batch, 200);
         Test.stopTest();

       /* RecordType partnerAccountGroupRecordType = [SELECT Id FROM RecordType WHERE Name = 'Partner Account Group' AND SObjectType = 'Account' LIMIT 1];
        RecordType intelAccountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Intel Account' AND SObjectType = 'Account' LIMIT 1];
        
        Account account1 = new Account(
            Name = 'Test Account 1',
            RecordTypeId = partnerAccountGroupRecordType.Id,
            Core_Deactivated__c = false,
            Core_Intel_Partner_Alliance_PartnerGroup__c = true,
            BillingCity='Bangalore',
            BillingStreet = 'Street ',
            BillingCountry = 'India',
            BillingPostalCode = 'Postal Code ',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Industry = 'Agriculture'
            
        );
        
        Account account2 = new Account(
            Name = 'Test Account 2',
            RecordTypeId = intelAccountRecordType.Id,
            Core_Deactivated__c = false,
            Core_Intel_Partner_Alliance_PartnerGroup__c = true,
            BillingCity='Bangalore',
            BillingStreet = 'Street ',
            BillingCountry = 'India',
            BillingPostalCode = 'Postal Code ',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Industry = 'Agriculture'
            
        );
        
        insert new List<Account>{account1, account2};
        
        PRM_AccountChannelMembership__c membership1 = new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = account1.Id,
            PRM_Status_Nm__c = 'Approved',
            PRM_Partner_Role__c='Guest'
        );
        
        PRM_AccountChannelMembership__c membership2 = new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = account2.Id,
            PRM_Status_Nm__c = 'Approved',
            PRM_Partner_Role__c='Builder'
        );
        
        insert new List<PRM_AccountChannelMembership__c>{membership1, membership2};
        
        // Ensure account2 is excluded by adding a record in PRM_IPAMembership_Attributes__c
        PRM_IPAMembership_Attributes__c ipamembership = new PRM_IPAMembership_Attributes__c(
            PRM_Account_Id__c = account2.Id
        );
        
        insert ipamembership;

		PRM_Profile_Questions__c question11 = new PRM_Profile_Questions__c(
            PRM_Question_Cd__c = 'PRM_Opt_In'
        );    
        insert question11;
        PRM_Profile_Questions__c question2 = new PRM_Profile_Questions__c(
            PRM_Question_Cd__c = ''
        );*/
        
        
       
    }

}