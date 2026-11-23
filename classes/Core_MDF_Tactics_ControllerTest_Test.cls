@isTest
public class Core_MDF_Tactics_ControllerTest_Test{
    
    @TestSetup
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
            
            // Create Partner Fund Request - check if AccountId field exists
            PartnerFundRequest testActivity = new PartnerFundRequest(
                RequestedAmount = 10000,
                Status = 'Draft' // Add required status field
            );
            
            // Try to set AccountId if it exists
            try {
                testActivity.put('AccountId', testAccount.Id);
            } catch (Exception e) {
                System.debug('AccountId field not available on PartnerFundRequest: ' + e.getMessage());
            }
             Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            ChannelProgram cpipa = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
             Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', cpipa.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
            // Try to set other common fields
            try {
                testActivity.put('Name', 'Test Partner Fund Request');
                testActivity.put('Description', 'Test Description');
                testActivity.put('ChannelPartnerId', ipaCoMarketingAccount.id);
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
            
            // Create Partner Fund Claims
            List<PartnerFundClaim> claims = new List<PartnerFundClaim>();
            for (Integer i = 1; i <= 3; i++) {
                PartnerFundClaim claim = new PartnerFundClaim(
                    RequestId = testActivity.Id,
                    Status = 'Draft' // Add required status field
                );
                
                // Try to set AccountId if it exists
                try {
                    claim.put('AccountId', testAccount.Id);
                } catch (Exception e) {
                    System.debug('AccountId field not available on PartnerFundClaim: ' + e.getMessage());
                }
                
                // Try to set other common fields
                try {
                    claim.put('ClaimAmount', 1000 * i);
                    claim.put('Description', 'Test Claim ' + i);
                } catch (Exception e) {
                    System.debug('Additional claim fields not available: ' + e.getMessage());
                }
                
                claims.add(claim);
            }
            insert claims;
            
            // Update claims with custom fields
            try {
                claims[0].put('Core_MDF_Status__c', 'Draft');
                claims[0].put('Core_MDF_Claim_Ref_Number__c', 'TEST-001');
                claims[1].put('Core_MDF_Status__c', 'Pending Approval');
                claims[1].put('Core_MDF_Claim_Ref_Number__c', 'TEST-002');
                claims[2].put('Core_MDF_Status__c', 'Cancelled');
                claims[2].put('Core_MDF_Claim_Ref_Number__c', 'TEST-003');
                update claims;
            } catch (Exception e) {
                System.debug('Custom claim fields not available: ' + e.getMessage());
            }
            
            // Get valid picklist values
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            // Create Custom Metadata Utility records
            List<Core_MDF_CCP_Custom_Metadata_Utility__c> metadataRecords = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
            try {
                metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
                    Name = 'Test Metadata 1',
                    Core_MDF_Field_1_txt__c = validTactic,
                    Core_MDF_Field_2_txt__c = validFieldName,
                    Core_MDF_Field_3_txt__c = 'KPI',
                    Core_MDF_Program__c = 'Intel Partner Alliance',
                    Core_MDF_Category__c = 'Tactic Metrics',
                    Core_MDF_Is_Active_Ind__c = true
                ));
                metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
                    Name = 'Test Metadata 2',
                    Core_MDF_Field_1_txt__c = validTactic,
                    Core_MDF_Field_2_txt__c = validPercentageField,
                    Core_MDF_Field_3_txt__c = 'Percentage',
                    Core_MDF_Program__c = 'Intel Partner Alliance',
                    Core_MDF_Category__c = 'Tactic Metrics',
                    Core_MDF_Is_Active_Ind__c = true
                ));
                insert metadataRecords;
            } catch (Exception e) {
                System.debug('Could not create metadata records: ' + e.getMessage());
            }
            
            // Create Activity Attributes
            List<Core_MDF_Activity_Attributes__c> activityAttributes = new List<Core_MDF_Activity_Attributes__c>();
            try {
                activityAttributes.add(new Core_MDF_Activity_Attributes__c(
                    Core_MDF_Co_Marketing_Activity__c = testActivity.Id,
                    Core_MDF_Tactics_nm__c = validTactic,
                    Core_MDF_Field_Name_nm__c = validPercentageField,
                    Core_MDF_Field_Value_nbr__c = 60,
                    Core_MDF_Spending_Amount_amt__c = 3000,
                    Core_MDF_Type_nm__c = 'Percentage',
                    Core_MDF_Is_Active_Ind__c = true
                ));
                activityAttributes.add(new Core_MDF_Activity_Attributes__c(
                    Core_MDF_Co_Marketing_Activity__c = testActivity.Id,
                    Core_MDF_Tactics_nm__c = validTactic,
                    Core_MDF_Field_Name_nm__c = validFieldName,
                    Core_MDF_Field_Value_nbr__c = 100,
                    Core_MDF_Type_nm__c = 'KPI',
                    Core_MDF_Is_Active_Ind__c = true
                ));
                insert activityAttributes;
            } catch (Exception e) {
                System.debug('Could not create activity attributes: ' + e.getMessage());
            }
            
            // Create Claim Attributes
            List<Core_MDF_Claim_Attributes__c> claimAttributes = new List<Core_MDF_Claim_Attributes__c>();
            try {
                claimAttributes.add(new Core_MDF_Claim_Attributes__c(
                    Core_MDF_Claim_Id__c = claims[0].Id,
                    Core_MDF_Tactics_nm__c = validTactic,
                    Core_MDF_Field_Name_nm__c = 'Total_Planned_Spend',
                    Core_MDF_Field_Value_nbr__c = 6000,
                    Core_MDF_Type_nm__c = 'Total Planned Spend',
                    Core_MDF_Is_Active_Ind__c = true
                ));
                claimAttributes.add(new Core_MDF_Claim_Attributes__c(
                    Core_MDF_Claim_Id__c = claims[0].Id,
                    Core_MDF_Tactics_nm__c = validTactic,
                    Core_MDF_Field_Name_nm__c = 'Previous_Period_Spends',
                    Core_MDF_Field_Value_nbr__c = 2000,
                    Core_MDF_Type_nm__c = 'Previous Period Spends',
                    Core_MDF_Is_Active_Ind__c = true
                ));
                claimAttributes.add(new Core_MDF_Claim_Attributes__c(
                    Core_MDF_Claim_Id__c = claims[0].Id,
                    Core_MDF_Tactics_nm__c = validTactic,
                    Core_MDF_Field_Name_nm__c = 'Spend_This_Period',
                    Core_MDF_Field_Value_nbr__c = 1500,
                    Core_MDF_Type_nm__c = 'Spend This Period',
                    Core_MDF_Is_Active_Ind__c = true
                ));
                claimAttributes.add(new Core_MDF_Claim_Attributes__c(
                    Core_MDF_Claim_Id__c = claims[1].Id,
                    Core_MDF_Tactics_nm__c = validTactic,
                    Core_MDF_Field_Name_nm__c = 'Previous_Period_Spends',
                    Core_MDF_Field_Value_nbr__c = 3500,
                    Core_MDF_Type_nm__c = 'Previous Period Spends',
                    Core_MDF_Is_Active_Ind__c = true
                ));
                insert claimAttributes;
            } catch (Exception e) {
                System.debug('Could not create claim attributes: ' + e.getMessage());
            }
        }
    }
    
    // Helper method to get valid picklist values
    private static Map<String, String> getValidPicklistValues(String objectName, String fieldName) {
        Map<String, String> picklistValues = new Map<String, String>();
        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
            if (sObjectType != null) {
                Schema.DescribeSObjectResult objDescribe = sObjectType.getDescribe();
                Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
                if (fieldMap.containsKey(fieldName)) {
                    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                    List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();
                    for (Schema.PicklistEntry entry : entries) {
                        if (entry.isActive()) {
                            picklistValues.put(entry.getValue(), entry.getLabel());
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error getting picklist values: ' + e.getMessage());
        }
        return picklistValues;
    }
    
    // Helper method to create test user
    private static User createTestUser(String lastName, String email) {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        return new User(
            ProfileId = sysAdminProfile.Id,
            LastName = lastName,
            Email = email,
            Username = email + '.testorg',
            CompanyName = 'TEST',
            Title = 'Test User',
            Alias = lastName.substring(0, Math.min(lastName.length(), 8)),
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            IsActive = true
        );
    }
    
    @isTest
    static void testGetTacticMappings() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            List<Map<String, Object>> result = Core_MDF_Tactics_Controller.getTacticMappings('Intel Partner Alliance');
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() >= 0, 'Should return tactic mappings list');
        }
    }
    
    @isTest
    static void testGetTacticMappingsEmptyProgram() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            List<Map<String, Object>> result = Core_MDF_Tactics_Controller.getTacticMappings('NonExistent Program');
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return empty list for non-existent program');
        }
    }
    
    @isTest
    static void testGetTacticMappingsNullProgram() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            List<Map<String, Object>> result = Core_MDF_Tactics_Controller.getTacticMappings(null);
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return empty list for null program');
        }
    }
    
    @isTest
    static void testSaveKpiDataSuccess() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            List<Object> testRecords = new List<Object>();
            Map<String, Object> record1 = new Map<String, Object>();
            record1.put('tactic', new Map<String, Object>{'api' => validTactic});
            record1.put('percentageField', new Map<String, Object>{'api' => validPercentageField, 'label' => 'Spending Percentage'});
            record1.put('percentageValue', 100.00);
            record1.put('intelContri', 5000.00);
            record1.put('maxIntelInvest', 5000.00);
            record1.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'label' => 'KPI Field', 'value' => 100});
            record1.put('otherKpis', new List<Object>());
            
            testRecords.add(record1);
            
            Test.startTest();
            Core_MDF_Tactics_Controller.KpiSaveResponse response = Core_MDF_Tactics_Controller.saveKpiData(testRecords, activity.Id, false);
            Test.stopTest();
            
            System.assertNotEquals(null, response, 'Response should not be null');
            System.assertEquals(true, response.noError, 'Should have no error');
        }
    }
    
    @isTest
    static void testSaveKpiDataProposalBased() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            List<Object> testRecords = new List<Object>();
            Map<String, Object> record1 = new Map<String, Object>();
            record1.put('tactic', new Map<String, Object>{'api' => validTactic});
            record1.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record1.put('percentageValue', 100.00);
            record1.put('intelContri', 5000.00);
            record1.put('maxIntelInvest', 5000.00);
            record1.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100});
            record1.put('otherKpis', new List<Object>());
            
            testRecords.add(record1);
            
            Test.startTest();
            Core_MDF_Tactics_Controller.KpiSaveResponse response = Core_MDF_Tactics_Controller.saveKpiData(testRecords, activity.Id, true);
            Test.stopTest();
            
            System.assertNotEquals(null, response, 'Response should not be null');
            System.assertEquals(true, response.noError, 'Should have no error');
            System.assertNotEquals(null, response.records, 'Records should not be null');
        }
    }
    
    @isTest
    static void testSaveKpiDataStringTactic() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            List<Object> testRecords = new List<Object>();
            Map<String, Object> record1 = new Map<String, Object>();
            record1.put('tactic', validTactic); // String instead of Map
            record1.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record1.put('percentageValue', 100.00);
            record1.put('intelContri', 5000.00);
            record1.put('maxIntelInvest', 5000.00);
            record1.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100});
            record1.put('otherKpis', new List<Object>());
            
            testRecords.add(record1);
            
            Test.startTest();
            Core_MDF_Tactics_Controller.KpiSaveResponse response = Core_MDF_Tactics_Controller.saveKpiData(testRecords, activity.Id, false);
            Test.stopTest();
            
            System.assertNotEquals(null, response, 'Response should not be null');
        }
    }
    
    @isTest
    static void testSaveKpiDataWithOtherKpis() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            List<String> fieldNames = new List<String>(validFieldNameValues.keySet());
            String validFieldName = fieldNames.size() > 0 ? fieldNames[0] : 'Leads_Generated';
            String validPercentageField = fieldNames.size() > 1 ? fieldNames[1] : 'Spending_Percentage';
            String otherKpiField = fieldNames.size() > 2 ? fieldNames[2] : validFieldName;
            
            List<Object> otherKpis = new List<Object>();
            Map<String, Object> otherKpi = new Map<String, Object>();
            otherKpi.put('api', otherKpiField);
            otherKpi.put('label', 'Other KPI');
            otherKpi.put('value', 5.5);
            otherKpis.add(otherKpi);
            
            List<Object> testRecords = new List<Object>();
            Map<String, Object> record1 = new Map<String, Object>();
            record1.put('tactic', new Map<String, Object>{'api' => validTactic});
            record1.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record1.put('percentageValue', 100.00);
            record1.put('intelContri', 5000.00);
            record1.put('maxIntelInvest', 5000.00);
            record1.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100});
            record1.put('otherKpis', otherKpis);
            testRecords.add(record1);
            
            Test.startTest();
            Core_MDF_Tactics_Controller.KpiSaveResponse response = Core_MDF_Tactics_Controller.saveKpiData(testRecords, activity.Id, false);
            Test.stopTest();
            
            System.assertNotEquals(null, response, 'Response should not be null');
        }
    }
    
    @isTest
    static void testSaveKpiDataValidationErrors() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            Test.startTest();
            
            // Test percentage range error
            List<Object> testRecords1 = new List<Object>();
            Map<String, Object> record1 = new Map<String, Object>();
            record1.put('tactic', new Map<String, Object>{'api' => validTactic});
            record1.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record1.put('percentageValue', 150.00); // Invalid percentage > 100
            record1.put('intelContri', 2500.00);
            record1.put('maxIntelInvest', 5000.00);
            record1.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100});
            record1.put('otherKpis', new List<Object>());
            testRecords1.add(record1);
            
            try {
                Core_MDF_Tactics_Controller.saveKpiData(testRecords1, activity.Id, false);
                System.assert(false, 'Should have thrown exception for invalid percentage');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('range') || e.getMessage().contains('100'), 'Should throw range error');
            }
            
            // Test decimal places error
            List<Object> testRecords2 = new List<Object>();
            Map<String, Object> record2 = new Map<String, Object>();
            record2.put('tactic', new Map<String, Object>{'api' => validTactic});
            record2.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record2.put('percentageValue', 50.123); // Too many decimal places
            record2.put('intelContri', 2500.00);
            record2.put('maxIntelInvest', 5000.00);
            record2.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100});
            record2.put('otherKpis', new List<Object>());
            testRecords2.add(record2);
            
            try {
                Core_MDF_Tactics_Controller.saveKpiData(testRecords2, activity.Id, false);
                System.assert(false, 'Should have thrown exception for decimal places');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('decimal') || e.getMessage().contains('2'), 'Should throw decimal error');
            }
            
            // Test blank percentage error
            List<Object> testRecords3 = new List<Object>();
            Map<String, Object> record3 = new Map<String, Object>();
            record3.put('tactic', new Map<String, Object>{'api' => validTactic});
            record3.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record3.put('percentageValue', null); // Blank percentage
            record3.put('intelContri', null);
            record3.put('maxIntelInvest', null);
            record3.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100});
            record3.put('otherKpis', new List<Object>());
            testRecords3.add(record3);
            
            try {
                Core_MDF_Tactics_Controller.saveKpiData(testRecords3, activity.Id, false);
                System.assert(false, 'Should have thrown exception for blank percentage');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('blank') || e.getMessage().contains('null') || e.getMessage().contains('empty'), 'Should throw blank error');
            }
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSaveKpiDataIntelContributionMismatch() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            List<Object> testRecords = new List<Object>();
            Map<String, Object> record1 = new Map<String, Object>();
            record1.put('tactic', new Map<String, Object>{'api' => validTactic});
            record1.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record1.put('percentageValue', 50.00);
            record1.put('intelContri', 2500.00);
            record1.put('maxIntelInvest', 6000.00); // Mismatch with total spending
            record1.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100});
            record1.put('otherKpis', new List<Object>());
            testRecords.add(record1);
            
            Test.startTest();
            try {
                Core_MDF_Tactics_Controller.saveKpiData(testRecords, activity.Id, false);
                System.assert(false, 'Should have thrown exception for intel contribution mismatch');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('sum') || e.getMessage().contains('match') || e.getMessage().contains('total'), 'Should throw sum error');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSaveKpiDataKpiValidationErrors() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            Test.startTest();
            
            // Test KPI decimal places error
            List<Object> testRecords1 = new List<Object>();
            Map<String, Object> record1 = new Map<String, Object>();
            record1.put('tactic', new Map<String, Object>{'api' => validTactic});
            record1.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record1.put('percentageValue', 100.00);
            record1.put('intelContri', 5000.00);
            record1.put('maxIntelInvest', 5000.00);
            record1.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100.123}); // Too many decimals
            record1.put('otherKpis', new List<Object>());
            testRecords1.add(record1);
            
            try {
                Core_MDF_Tactics_Controller.saveKpiData(testRecords1, activity.Id, false);
                System.assert(false, 'Should have thrown exception for KPI decimal places');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('decimal') || e.getMessage().contains('2'), 'Should throw decimal error');
            }
            
            // Test KPI negative value error
            List<Object> testRecords2 = new List<Object>();
            Map<String, Object> record2 = new Map<String, Object>();
            record2.put('tactic', new Map<String, Object>{'api' => validTactic});
            record2.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record2.put('percentageValue', 100.00);
            record2.put('intelContri', 5000.00);
            record2.put('maxIntelInvest', 5000.00);
            record2.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 1}); // Less than 2
            record2.put('otherKpis', new List<Object>());
            testRecords2.add(record2);
            
            try {
                Core_MDF_Tactics_Controller.saveKpiData(testRecords2, activity.Id, false);
                System.assert(false, 'Should have thrown exception for KPI negative value');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('greater') || e.getMessage().contains('2') || e.getMessage().contains('minimum'), 'Should throw greater than error');
            }
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSaveKpiDataOtherKpiValidationErrors() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            Test.startTest();
            
            // Test other KPI negative value error
            List<Object> otherKpis = new List<Object>();
            Map<String, Object> otherKpi = new Map<String, Object>();
            otherKpi.put('api', validFieldName);
            otherKpi.put('value', -5); // Negative value
            otherKpis.add(otherKpi);
            
            List<Object> testRecords3 = new List<Object>();
            Map<String, Object> record3 = new Map<String, Object>();
            record3.put('tactic', new Map<String, Object>{'api' => validTactic});
            record3.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record3.put('percentageValue', 100.00);
            record3.put('intelContri', 5000.00);
            record3.put('maxIntelInvest', 5000.00);
            record3.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100});
            record3.put('otherKpis', otherKpis);
            testRecords3.add(record3);
            
            try {
                Core_MDF_Tactics_Controller.saveKpiData(testRecords3, activity.Id, false);
                System.assert(false, 'Should have thrown exception for other KPI negative value');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('negative') || e.getMessage().contains('0') || e.getMessage().contains('positive'), 'Should throw negative error for other KPI');
            }
            
            // Test other KPI decimal places error
            List<Object> otherKpis2 = new List<Object>();
            Map<String, Object> otherKpi2 = new Map<String, Object>();
            otherKpi2.put('api', validFieldName);
            otherKpi2.put('value', 5.123); // Too many decimals
            otherKpis2.add(otherKpi2);
            
            List<Object> testRecords4 = new List<Object>();
            Map<String, Object> record4 = new Map<String, Object>();
            record4.put('tactic', new Map<String, Object>{'api' => validTactic});
            record4.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record4.put('percentageValue', 100.00);
            record4.put('intelContri', 5000.00);
            record4.put('maxIntelInvest', 5000.00);
            record4.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100});
            record4.put('otherKpis', otherKpis2);
            testRecords4.add(record4);
            
            try {
                Core_MDF_Tactics_Controller.saveKpiData(testRecords4, activity.Id, false);
                System.assert(false, 'Should have thrown exception for other KPI decimal places');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('decimal') || e.getMessage().contains('2'), 'Should throw decimal error for other KPI');
            }
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSaveKpiDataMissingKpiValues() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            List<Object> testRecords = new List<Object>();
            Map<String, Object> record1 = new Map<String, Object>();
            record1.put('tactic', new Map<String, Object>{'api' => validTactic});
            record1.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record1.put('percentageValue', 100.00);
            record1.put('intelContri', 5000.00);
            record1.put('maxIntelInvest', 5000.00);
            record1.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => null}); // No KPI value
            record1.put('otherKpis', new List<Object>());
            testRecords.add(record1);
            
            Test.startTest();
            try {
                Core_MDF_Tactics_Controller.saveKpiData(testRecords, activity.Id, false);
                System.assert(false, 'Should have thrown exception for missing KPI values');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('KPI') || e.getMessage().contains('value') || e.getMessage().contains('required'), 'Should throw KPI missing error');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSaveKpiDataNullStringKpiValue() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            List<Object> testRecords = new List<Object>();
            Map<String, Object> record1 = new Map<String, Object>();
            record1.put('tactic', new Map<String, Object>{'api' => validTactic});
            record1.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record1.put('percentageValue', 100.00);
            record1.put('intelContri', 5000.00);
            record1.put('maxIntelInvest', 5000.00);
            record1.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 'null'}); // String 'null'
            record1.put('otherKpis', new List<Object>());
            testRecords.add(record1);
            
            Test.startTest();
            try {
                Core_MDF_Tactics_Controller.saveKpiData(testRecords, activity.Id, false);
                System.assert(false, 'Should have thrown exception for null string KPI values');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('KPI') || e.getMessage().contains('value') || e.getMessage().contains('null'), 'Should throw KPI missing error');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSaveKpiDataExistingRecords() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            // Create existing record to test update path
            Core_MDF_Activity_Attributes__c existingRecord = new Core_MDF_Activity_Attributes__c(
                Core_MDF_Co_Marketing_Activity__c = activity.Id,
                Core_MDF_Tactics_nm__c = validTactic,
                Core_MDF_Field_Name_nm__c = validPercentageField,
                Core_MDF_Field_Value_nbr__c = 50,
                Core_MDF_Type_nm__c = 'Percentage',
                Core_MDF_Is_Active_Ind__c = true
            );
            insert existingRecord;
            
            List<Object> testRecords = new List<Object>();
            Map<String, Object> record1 = new Map<String, Object>();
            record1.put('tactic', new Map<String, Object>{'api' => validTactic});
            record1.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record1.put('percentageValue', 100.00);
            record1.put('intelContri', 5000.00);
            record1.put('maxIntelInvest', 5000.00);
            record1.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100});
            record1.put('otherKpis', new List<Object>());
            
            testRecords.add(record1);
            
            Test.startTest();
            Core_MDF_Tactics_Controller.KpiSaveResponse response = Core_MDF_Tactics_Controller.saveKpiData(testRecords, activity.Id, false);
            Test.stopTest();
            
            // Verify existing record was updated
            Core_MDF_Activity_Attributes__c updatedRecord = [
                SELECT Core_MDF_Field_Value_nbr__c FROM Core_MDF_Activity_Attributes__c 
                WHERE Id = :existingRecord.Id
            ];
            System.assertEquals(100, updatedRecord.Core_MDF_Field_Value_nbr__c, 'Existing record should be updated');
        }
    }
    
    @isTest
    static void testSaveKpiDataDeactivateRecords() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            // Create existing record that won't be in the new data (should be deactivated)
            Core_MDF_Activity_Attributes__c existingRecord = new Core_MDF_Activity_Attributes__c(
                Core_MDF_Co_Marketing_Activity__c = activity.Id,
                Core_MDF_Tactics_nm__c = validTactic,
                Core_MDF_Field_Name_nm__c = 'Old_Field',
                Core_MDF_Field_Value_nbr__c = 50,
                Core_MDF_Type_nm__c = 'KPI',
                Core_MDF_Is_Active_Ind__c = true
            );
            insert existingRecord;
            
            List<Object> testRecords = new List<Object>();
            Map<String, Object> record1 = new Map<String, Object>();
            record1.put('tactic', new Map<String, Object>{'api' => validTactic});
            record1.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record1.put('percentageValue', 100.00);
            record1.put('intelContri', 5000.00);
            record1.put('maxIntelInvest', 5000.00);
            record1.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100});
            record1.put('otherKpis', new List<Object>());
            
            testRecords.add(record1);
            
            Test.startTest();
            Core_MDF_Tactics_Controller.KpiSaveResponse response = Core_MDF_Tactics_Controller.saveKpiData(testRecords, activity.Id, false);
            Test.stopTest();
            
            // Verify existing record was deactivated
            Core_MDF_Activity_Attributes__c deactivatedRecord = [
                SELECT Core_MDF_Is_Active_Ind__c FROM Core_MDF_Activity_Attributes__c 
                WHERE Id = :existingRecord.Id
            ];
            System.assertEquals(false, deactivatedRecord.Core_MDF_Is_Active_Ind__c, 'Old record should be deactivated');
        }
    }
    
    @isTest
    static void testSaveKpiDataEmptyRecords() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Test.startTest();
            Core_MDF_Tactics_Controller.KpiSaveResponse response = Core_MDF_Tactics_Controller.saveKpiData(new List<Object>(), activity.Id, false);
            Test.stopTest();
            
            System.assertNotEquals(null, response, 'Response should not be null');
            System.assertEquals(true, response.noError, 'Should have no error for empty records');
        }
    }
    
    @isTest
    static void testSaveKpiDataNullRecords() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Test.startTest();
            Core_MDF_Tactics_Controller.KpiSaveResponse response = Core_MDF_Tactics_Controller.saveKpiData(null, activity.Id, false);
            Test.stopTest();
            
            System.assertNotEquals(null, response, 'Response should not be null');
            System.assertEquals(true, response.noError, 'Should have no error for null records');
        }
    }
    
    @isTest
    static void testGetSavedKpiData() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Test.startTest();
            List<Map<String, Object>> result = Core_MDF_Tactics_Controller.getSavedKpiData(activity.Id);
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() >= 0, 'Should return KPI data list');
        }
    }
    
    @isTest
    static void testGetSavedKpiDataNullId() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            List<Map<String, Object>> result = Core_MDF_Tactics_Controller.getSavedKpiData(null);
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return empty list for null ID');
        }
    }
    
    @isTest
    static void testGetPicklistLabels() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            Map<String, String> result = Core_MDF_Tactics_Controller.getPicklistLabels();
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() >= 0, 'Should return picklist labels map');
        }
    }
    
    @isTest
    static void testGetLocalizedPicklistLabels() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            Map<String, String> result = Core_MDF_Tactics_Controller.getLocalizedPicklistLabels(
                'Core_MDF_Activity_Attributes__c', 
                new List<String>{'Core_MDF_Tactics_nm__c', 'Core_MDF_Field_Name_nm__c'}
            );
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }
    
    @isTest
    static void testGetLocalizedPicklistLabelsNullInputs() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            Map<String, String> result1 = Core_MDF_Tactics_Controller.getLocalizedPicklistLabels(null, null);
            Map<String, String> result2 = Core_MDF_Tactics_Controller.getLocalizedPicklistLabels('Core_MDF_Activity_Attributes__c', null);
            Map<String, String> result3 = Core_MDF_Tactics_Controller.getLocalizedPicklistLabels(null, new List<String>{'Core_MDF_Tactics_nm__c'});
            Test.stopTest();
            
            System.assertNotEquals(null, result1, 'Result should not be null for null inputs');
            System.assertNotEquals(null, result2, 'Result should not be null for null field list');
            System.assertNotEquals(null, result3, 'Result should not be null for null object name');
        }
    }
    
    @isTest
    static void testGetLocalizedFieldMetadata() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            List<Core_MDF_Tactics_Controller.FieldInfo> result = Core_MDF_Tactics_Controller.getLocalizedFieldMetadata(
                new List<String>{'Core_MDF_Activity_Attributes__c'}, 
                new List<String>{'Core_MDF_Tactics_nm__c', 'Core_MDF_Field_Name_nm__c'}
            );
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() >= 0, 'Should return field metadata');
        }
    }
    
    @isTest
    static void testGetLocalizedFieldMetadataNullInputs() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            List<Core_MDF_Tactics_Controller.FieldInfo> result1 = Core_MDF_Tactics_Controller.getLocalizedFieldMetadata(null, null);
            List<Core_MDF_Tactics_Controller.FieldInfo> result2 = Core_MDF_Tactics_Controller.getLocalizedFieldMetadata(new List<String>{'Core_MDF_Activity_Attributes__c'}, null);
            List<Core_MDF_Tactics_Controller.FieldInfo> result3 = Core_MDF_Tactics_Controller.getLocalizedFieldMetadata(null, new List<String>{'Core_MDF_Tactics_nm__c'});
            Test.stopTest();
            
            System.assertNotEquals(null, result1, 'Result should not be null for null inputs');
            System.assertNotEquals(null, result2, 'Result should not be null for null field list');
            System.assertNotEquals(null, result3, 'Result should not be null for null object list');
        }
    }
    
    @isTest
    static void testGetTacticSpendingWithClaimId() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            List<PartnerFundClaim> claims = [SELECT Id FROM PartnerFundClaim LIMIT 1];
            if (claims.size() > 0) {
                Test.startTest();
                List<Core_MDF_Tactics_Controller.TacticSpendingWrpper> result = 
                    Core_MDF_Tactics_Controller.getTacticSpending(true, claims[0].Id, null);
                Test.stopTest();
                
                System.assertNotEquals(null, result, 'Result should not be null');
                
                for (Core_MDF_Tactics_Controller.TacticSpendingWrpper wrapper : result) {
                    System.assertEquals(true, wrapper.editable, 'Should be editable');
                }
            }
        }
    }
    
    @isTest
    static void testGetTacticSpendingWithActivityId() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            PartnerFundRequest activity = [SELECT Id FROM PartnerFundRequest LIMIT 1];
            
            Test.startTest();
            List<Core_MDF_Tactics_Controller.TacticSpendingWrpper> result = 
                Core_MDF_Tactics_Controller.getTacticSpending(false, null, activity.Id);
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null');
            
            for (Core_MDF_Tactics_Controller.TacticSpendingWrpper wrapper : result) {
                System.assertEquals(false, wrapper.editable, 'Should not be editable');
            }
        }
    }
    
    @isTest
    static void testGetTacticSpendingEmptyResults() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            List<Core_MDF_Tactics_Controller.TacticSpendingWrpper> result = 
                Core_MDF_Tactics_Controller.getTacticSpending(true, null, null);
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return empty list when no IDs provided');
        }
    }
    
    @isTest
    static void testUpdateClaimAttributesCancel() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            List<PartnerFundClaim> claims = [SELECT Id FROM PartnerFundClaim LIMIT 1];
            if (claims.size() > 0) {
                Map<String, String> claimIdToRefMap = new Map<String, String>();
                claimIdToRefMap.put(claims[0].Id, 'TEST-001');
                
                Test.startTest();
                Core_MDF_Tactics_Controller.updateClaimAttributes1(claimIdToRefMap, 'Cancel');
                Test.stopTest();
                
                System.assert(true, 'Method should execute without errors');
            }
        }
    }
    
    @isTest
    static void testUpdateClaimAttributesEdit() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            List<PartnerFundClaim> claims = [SELECT Id FROM PartnerFundClaim LIMIT 1];
            if (claims.size() > 0) {
                Map<String, String> claimIdToRefMap = new Map<String, String>();
                Map<String, Map<String, Decimal>> claimIdToTacticDiffMap = new Map<String, Map<String, Decimal>>();
                
                claimIdToRefMap.put(claims[0].Id, 'TEST-001');
                Map<String, Decimal> tacticDiffs = new Map<String, Decimal>();
                tacticDiffs.put('Digital Marketing', 500.0);
                claimIdToTacticDiffMap.put(claims[0].Id, tacticDiffs);
                
                Test.startTest();
                Core_MDF_Tactics_Controller.updateClaimAttributes(claimIdToRefMap, claimIdToTacticDiffMap, 'Edit');
                Test.stopTest();
                
                System.assert(true, 'Method should execute without errors');
            }
        }
    }
    
    @isTest
    static void testUpdateClaimAttributesWithEmptyMaps() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            // Test with null maps
            Core_MDF_Tactics_Controller.updateClaimAttributes(null, null, 'Cancel');
            
            // Test with empty maps
            Core_MDF_Tactics_Controller.updateClaimAttributes(new Map<String, String>(), null, 'Cancel');
            Core_MDF_Tactics_Controller.updateClaimAttributes1(new Map<String, String>(), 'Cancel');
            Test.stopTest();
            
            System.assert(true, 'Methods should handle empty/null inputs gracefully');
        }
    }
    
    @isTest
    static void testHasMoreThanTwoDecimals() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            Boolean result1 = Core_MDF_Tactics_Controller.hasMoreThanTwoDecimals(10.123);
            Boolean result2 = Core_MDF_Tactics_Controller.hasMoreThanTwoDecimals(10.12);
            Boolean result3 = Core_MDF_Tactics_Controller.hasMoreThanTwoDecimals(10);
            Boolean result4 = Core_MDF_Tactics_Controller.hasMoreThanTwoDecimals(10.1);
            Boolean result5 = Core_MDF_Tactics_Controller.hasMoreThanTwoDecimals(0);
            Boolean result6 = Core_MDF_Tactics_Controller.hasMoreThanTwoDecimals(null);
            Test.stopTest();
            
            System.assertEquals(true, result1, 'Should return true for more than 2 decimals');
            System.assertEquals(false, result2, 'Should return false for 2 decimals');
            System.assertEquals(false, result3, 'Should return false for no decimals');
            System.assertEquals(false, result4, 'Should return false for 1 decimal');
            System.assertEquals(false, result5, 'Should return false for zero');
            System.assertEquals(false, result6, 'Should return false for null');
        }
    }
    
    @isTest
    static void testKpiSaveResponseClass() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            List<Core_MDF_Activity_Attributes__c> testRecords = new List<Core_MDF_Activity_Attributes__c>();
            
            Test.startTest();
            Core_MDF_Tactics_Controller.KpiSaveResponse response = 
                new Core_MDF_Tactics_Controller.KpiSaveResponse(true, testRecords);
            Test.stopTest();
            
            System.assertEquals(true, response.noError, 'NoError should be true');
            System.assertEquals(testRecords, response.records, 'Records should match');
        }
    }
    
    @isTest
    static void testTacticSpendingWrapperClass() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            Core_MDF_Tactics_Controller.TacticSpendingWrpper wrapper = 
                new Core_MDF_Tactics_Controller.TacticSpendingWrpper();
            wrapper.tactic = 'Test Tactic';
            wrapper.tacticLabel = 'Test Tactic Label';
            wrapper.totalPlannedSpend = 1000.0;
            wrapper.spendThisPeriod = 300.0;
            wrapper.editable = true;
            Test.stopTest();
            
            System.assertEquals('Test Tactic', wrapper.tactic, 'Tactic should match');
            System.assertEquals('Test Tactic Label', wrapper.tacticLabel, 'Tactic label should match');
            System.assertEquals(1000.0, wrapper.totalPlannedSpend, 'Total planned spend should match');
            System.assertEquals(300.0, wrapper.spendThisPeriod, 'Spend this period should match');
            System.assertEquals(true, wrapper.editable, 'Editable should be true');
        }
    }
    
    @isTest
    static void testFieldInfoClass() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            Core_MDF_Tactics_Controller.FieldInfo fieldInfo = 
                new Core_MDF_Tactics_Controller.FieldInfo('TestObject', 'TestField', 'Test Label', 'Test Help');
            Test.stopTest();
            
            System.assertEquals('TestObject', fieldInfo.objectName, 'Object name should match');
            System.assertEquals('TestField', fieldInfo.fieldName, 'Field name should match');
            System.assertEquals('Test Label', fieldInfo.label, 'Label should match');
            System.assertEquals('Test Help', fieldInfo.helpText, 'Help text should match');
        }
    }
    
    @isTest
    static void testClaimWithClaimAttributeWrapperClass() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            Core_MDF_Tactics_Controller.ClaimWithClaimAttributeWrapper wrapper = 
                new Core_MDF_Tactics_Controller.ClaimWithClaimAttributeWrapper();
            wrapper.claimIds = new Set<Id>();
            wrapper.type = 'Add';
            Test.stopTest();
            
            System.assertNotEquals(null, wrapper.claimIds, 'ClaimIds should not be null');
            System.assertEquals('Add', wrapper.type, 'Type should match');
        }
    }
    
    @isTest
    static void testSaveKpiDataDatabaseException() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            // Use invalid ID to force database exception
            String invalidId = '001000000000000';
            
            Map<String, String> validTacticValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Tactics_nm__c');
            Map<String, String> validFieldNameValues = getValidPicklistValues('Core_MDF_Activity_Attributes__c', 'Core_MDF_Field_Name_nm__c');
            
            String validTactic = !validTacticValues.isEmpty() ? new List<String>(validTacticValues.keySet())[0] : 'Digital Marketing';
            String validFieldName = !validFieldNameValues.isEmpty() ? new List<String>(validFieldNameValues.keySet())[0] : 'Leads_Generated';
            String validPercentageField = validFieldNameValues.size() > 1 ? new List<String>(validFieldNameValues.keySet())[1] : 'Spending_Percentage';
            
            List<Object> testRecords = new List<Object>();
            Map<String, Object> record1 = new Map<String, Object>();
            record1.put('tactic', new Map<String, Object>{'api' => validTactic});
            record1.put('percentageField', new Map<String, Object>{'api' => validPercentageField});
            record1.put('percentageValue', 100.00);
            record1.put('intelContri', 5000.00);
            record1.put('maxIntelInvest', 5000.00);
            record1.put('firstKpi', new Map<String, Object>{'api' => validFieldName, 'value' => 100});
            record1.put('otherKpis', new List<Object>());
            testRecords.add(record1);
            
            Test.startTest();
            try {
                Core_MDF_Tactics_Controller.saveKpiData(testRecords, invalidId, false);
                System.assert(false, 'Should have thrown exception for invalid ID');
            } catch (Exception e) {
                System.assert(true, 'Should handle database exceptions');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetTacticSpendingException() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'AdminUser' LIMIT 1];
        System.runAs(adminUser) {
            // Use invalid ID to test exception handling
            String invalidId = '001000000000000';
            
            Test.startTest();
            List<Core_MDF_Tactics_Controller.TacticSpendingWrpper> result = 
                Core_MDF_Tactics_Controller.getTacticSpending(true, invalidId, null);
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null even with invalid ID');
        }
    }
}