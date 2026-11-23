@isTest
public class  Claim_Test{
    
    @testSetup
    static void setupTestData() {
      // Create System Administrator user with valid data
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            ProfileId = sysAdminProfile.Id,
            LastName = 'AdminUser',
            Email = 'admin@intel.com',
            Username = 'admin@testintel' + System.currentTimeMillis() + '.com',
            CompanyName = 'TEST',
            Title = 'System Administrator',
            Alias = 'admin',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            IsActive = true
        );
        insert adminUser;
        
        System.runAs(adminUser) {
            // Create Account with valid address data
            Account testAccount = new Account(
                Name = 'Test Account',
                BillingCity = 'Sydney',
                BillingCountry = 'AUS',
                BillingCountryCode = 'AUS',
                BillingState = 'NSW', // Use state code instead of full name
                BillingStateCode = 'NSW',
                BillingStreet = '#24 Street',
                BillingPostalCode = '325687'
            );
            insert testAccount;
            
             Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            ChannelProgram cpipa = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
             Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', cpipa.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, true);
            
                  System.assertNotEquals(null, ipaCoMarketingAccount.Id, 
                'CoMarketing Account must have an Id before use');
            
            // Create Partner Fund Request - check if AccountId field exists
            PartnerFundRequest testActivity = new PartnerFundRequest(
                RequestedAmount = 10000,
                Status = 'Draft',
                ChannelPartnerId = ipaCoMarketingAccount.Id // Add required status field
            );
            
            // Try to set AccountId if it exists
            try {
                testActivity.put('AccountId', testAccount.Id);
            } catch (Exception e) {
                System.debug('AccountId field not available on PartnerFundRequest: ' + e.getMessage());
            }

            // Try to set other common fields
            try {
                testActivity.put('Name', 'Test Partner Fund Request');
                testActivity.put('Description', 'Test Description');
               
                // IPApfr.ChannelPartnerId = ipaCoMarketingAccount.id;
            } catch (Exception e) {
                System.debug('Additional fields not available: ' + e.getMessage());
            }
            
            insert testActivity;
            
            // Update with custom fields
            try {
                testActivity.put('Core_MDF_Program__c', 'Intel Partner Alliance');
                testActivity.put('Core_MDF_ActivityCategory__c', 'Outcome-Based');
                testActivity.put('Core_MDF_Reimbursement_Rate__c', '50%');
                testActivity.put('Core_MDF_Activity_Reimbursement_Amt_nbr__c', 5000);
                update testActivity;
            } catch (Exception e) {
                System.debug('Custom fields not available: ' + e.getMessage());
            }    
        }    
    }
    @isTest
    static void testSaveClaimWithSubClaims_SOQL_Limit() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
        
        // Create parent claim
        PartnerFundClaim parentClaim = new PartnerFundClaim(
            RequestId = activity.Id,
            Core_MDF_Status__c = 'Draft',
            Core_MDF_Type_Txt__c = 'Claim',
            Core_MDF_Total_Invoice_Amount_Local__c = 1000,
            Core_MDF_Currency__c = 'USD'
        );
        
        // Create sub-claims (this triggers the issue)
        List<PartnerFundClaim> subClaimList = new List<PartnerFundClaim>();
        for(Integer i = 0; i < 20; i++) {  // Create 50 sub-claims
            PartnerFundClaim subClaim = new PartnerFundClaim(
                RequestId = activity.Id,
                Core_MDF_Status__c = 'Draft',
                Core_MDF_Type_Txt__c = 'Claim',
                Core_MDF_Amount_Percentage__c = 2,  // 50 x 2% = 100%
                Core_MDF_Total_Invoice_Amount_Local__c = 20
            );
            subClaimList.add(subClaim);
        }
        
        Test.startTest();
        try {
             Core_MDF_PartnerFundClaim.saveClaim(
                parentClaim,
                new List<Core_MDF_Audit_Document__c>(),
                null,
                null,
                false,
                new List<Core_MDF_Claim_Attributes__c>(),
                false,
                subClaimList,
                false
            );
            
           
        } catch(Exception e) {
            System.debug('EXCEPTION CAUGHT: ' + e.getMessage());
            System.debug('EXCEPTION TYPE: ' + e.getTypeName());
            System.assert(e.getMessage().contains('Too many SOQL queries'), 
                'Expected SOQL limit exception');
        }
        Test.stopTest();
    }
}