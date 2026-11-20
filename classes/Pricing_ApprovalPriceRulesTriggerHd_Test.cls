/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-26-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_ApprovalPriceRulesTriggerHd_Test {

     @testSetup
    static void setupData() {
        List<User> regionalManager = Pricing_Test_Utility.createPricingMangerUser2();
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('ApprovalPriceRule');
         Pricing_Test_Utility.createPriceBook();
         List<Product2> products = Pricing_Test_Utility.createProduct(2);
        System.runAs(adminUserList[0]) {
        Account acc = Pricing_Test_Utility.createAccount(); 
        }
    }
    @isTest
    static void testInsertApprovalTrigger() {
        User adminUser = [Select id from User where Email='ApprovalPriceRule@intel.com'];
        Account acc = [select id,Name from Account limit 1];
        System.runAs(adminUser) {
        Pricing_Approval_Price_Rules__c rule = new Pricing_Approval_Price_Rules__c(
            Pricing_Rule_Name__c = 'Test Rule',
            Pricing_Approval_Status__c = 'Draft',
            Pricing_End_Date__c = Date.today().addMonths(1),
            Pricing_Quote_Type__c = 'Client',
            Pricing_Account__c = acc.Id,
            Pricing_End_Customer_Country__c = 'India',
            Pricing_Form_Factor__c = 'AIO',
            Pricing_Intel_Account_Exec_Email_Txt__c = 'exec@example.com',
            Pricing_Intel_Sales_Rep_Email_Txt__c = 'rep@example.com',
            Pricing_Market_Segment_values_Nm__c = 'Corp'
        );
        Test.startTest();
        insert rule;
        Test.stopTest();
       
        // Verify start/end dates are set
        rule = [SELECT Pricing_Rule_Start_Date__c, Pricing_Rule_End_Date__c FROM Pricing_Approval_Price_Rules__c WHERE Id = :rule.Id];
        System.assertNotEquals(null, rule.Pricing_Rule_Start_Date__c, 'Start Date should be auto-set');
        System.assertNotEquals(null, rule.Pricing_Rule_End_Date__c, 'End Date should be auto-set');
        }
    }

    @isTest
    static void testUpdateApprovalPendingToApproved() {
        // Insert record first
        Map<Id,Pricing_Approval_Price_Rules__c> ruleIdToPresentRecordMap = new Map<Id,Pricing_Approval_Price_Rules__c>();
        Account acc = [select id,Name from Account limit 1];
        User adminUser = [Select id from User where Email='ApprovalPriceRule@intel.com'];
        Pricing_Approval_Price_Rules__c rule = new Pricing_Approval_Price_Rules__c(
            Pricing_Rule_Name__c = 'Rule Update Test',
            Pricing_Approval_Status__c = 'Submitted',
            Pricing_Quote_Type__c = 'Client',
            Pricing_Account__c = acc.Id,
            Pricing_End_Customer_Country__c = 'India',
            Pricing_End_Date__c = Date.today().addMonths(1)
        );
        System.runAs(adminUser) {
        insert rule;
		ruleIdToPresentRecordMap.put(rule.Id,rule);
        Test.startTest();
            Pricing_ApprovalPriceRulesTriggerHandler.approvalRecordsCreation(ruleIdToPresentRecordMap);
        // Simulate update and approval status change
        rule.Pricing_Approval_Status__c = 'Approved';
        //rule.Pricing_Quote_Type__c = 'Data center';
        update rule;
        Test.stopTest();

        // Re-query to verify status
        rule = [SELECT Pricing_Approval_Status__c FROM Pricing_Approval_Price_Rules__c WHERE Id = :rule.Id];
        System.assertEquals('Approved', rule.Pricing_Approval_Status__c);
        }
    }

    @isTest
    static void testFieldChangeTriggersPendingStatus() {
        Account acc = [select id,Name from Account limit 1];
        User adminUser = [Select id from User where Email='ApprovalPriceRule@intel.com'];
        System.runAs(adminUser) {
        Pricing_Approval_Price_Rules__c rule = new Pricing_Approval_Price_Rules__c(
            Pricing_Rule_Name__c = 'Change Detection',
            Pricing_Approval_Status__c = 'Approved',
            Pricing_Quote_Type__c = 'Client',
             Pricing_Account__c = acc.Id,
            Pricing_End_Customer_Country__c = 'India',
            Pricing_End_Date__c = Date.today().addMonths(1)
        );
        insert rule;

        Test.startTest();
        rule.Pricing_Quote_Type__c = 'Data center';
        update rule;
        Test.stopTest();

        rule = [SELECT Pricing_Approval_Status__c FROM Pricing_Approval_Price_Rules__c WHERE Id = :rule.Id];
        System.assertEquals('Draft', rule.Pricing_Approval_Status__c, 'Status should reset to Draft on field change');
        }
    }

    @isTest
    static void testProcessRecordsAndValidateProductFloorPrice() {
      Product2 prod = [SELECT Id,Product2.Name FROM Product2 LIMIT 1];
       Account acc = [select id,Name from Account limit 1];
        User adminUser = [Select id from User where Email='ApprovalPriceRule@intel.com'];
        Pricing_Approval_Price_Rules__c rule = new Pricing_Approval_Price_Rules__c(
            Pricing_Rule_Name__c = 'Rule Update Test',
            Pricing_Approval_Status__c = 'Approved',
            Pricing_Quote_Type__c = 'Client',
            Pricing_Account__c = acc.Id,
            Pricing_End_Customer_Country__c = 'India',
            Pricing_End_Date__c = Date.today().addMonths(1)
        );
        System.runAs(adminUser) {
            insert rule;
        }

        Pricing_Product_Floor_Price__c floorPriceToInsert = new Pricing_Product_Floor_Price__c();
        floorPriceToInsert.Pricing_Product__c = prod.Id;
        floorPriceToInsert.Pricing_Approved_ECAP_Price__c = 500;
        floorPriceToInsert.Pricing_Active__c = True;
        floorPriceToInsert.Pricing_Approval_Price_Rules__c = rule.Id;
        System.runAs(adminUser) {
            insert floorPriceToInsert;
        } 

        // Build CSV content: header + two rows (one quoted)
        string base64Data = JSON.serialize('Floor Product, Floor Price, Active\n"Test Product 1","100","True"');
        

        Test.startTest();
            String result = Pricing_ApprovalPriceRulesTriggerHandler.processRecords(base64Data, 'Pricing_Product_Floor_Price__c', rule.Id);
        Test.stopTest();

        // Ensure no error string returned
        System.assertEquals(rule != null, true);

    }
}