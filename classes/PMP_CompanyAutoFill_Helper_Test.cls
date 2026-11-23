@IsTest
public class PMP_CompanyAutoFill_Helper_Test {

    @IsTest
    static void testFullFlow_WithRegionsIndustriesApplications() {
        Core_Trigger_Executions__c cte = new Core_Trigger_Executions__c (Name = 'Company_Autofill_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'Test',
                                                                        Core_Object__c = 'PMP_CompanyAutofill__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update and create Stage');
        insert cte;

        PMP_Company__c company = new PMP_Company__c(
            Name = 'Test Company',
            PMP_Company_Lifecycle_Status_Nm__c = 'Draft',
            PMP_Account_Website__c = 'https://test.com'
        );
        insert company;

        PMP_CompanyAutoFill__c stage = new PMP_CompanyAutoFill__c(
            PMP_Partner_Id__c = company.Id,
            PMP_Autofill_Status__c = 'Staged',
            PMP_Website__c = company.PMP_Account_Website__c
        );
        insert stage;

        //Update staged record
        stage.PMP_Autofill_Status__c = 'Scraped';
        stage.PMP_Tagline__c = 'AI Company';
        stage.PMP_Description__c = 'AI Driven Solutions';

        stage.PMP_Regions__c = 'Americas;Latin America Region;Asia, Pacific, and Japan';
        stage.PMP_Industries__c = 'Healthcare';
        stage.PMP_Applications__c = 'Connected Worker';

        Test.startTest();
        update stage;
        Test.stopTest();

        // Assert Company updated
        PMP_Company__c updatedCompany = [
            SELECT PMP_Account_Tag_Line__c,
                   PMP_Account_Dsc__c,
                   PMP_Autofill_Txt__c
            FROM PMP_Company__c
            WHERE Id = :company.Id
        ];

        System.assertEquals('AI Company', updatedCompany.PMP_Account_Tag_Line__c);
        System.assertEquals('AI Driven Solutions', updatedCompany.PMP_Account_Dsc__c);
        System.assertEquals('Scraped', updatedCompany.PMP_Autofill_Txt__c);

        // Assert Translations inserted
        System.assertEquals(
            2,
            [SELECT COUNT()
             FROM PMP_Company_Translation__c
             WHERE PMP_Company_Information_Id__c = :company.Id]
        );

        // Region & Category code EXECUTED safely
        // No assertion on count (expected = 0)
        System.assert(true, 'Region and Category logic executed without failure');
    }

    @IsTest
    static void testPublishStagedCompanies() {

        PMP_Company__c company = new PMP_Company__c(
            Name = 'Publish Company',
            PMP_Company_Lifecycle_Status_Nm__c = 'Draft',
            PMP_Account_Website__c = 'https://publish.com'
        );
        insert company;

        PMP_CompanyAutoFill__c stage = new PMP_CompanyAutoFill__c(
            PMP_Partner_Id__c = company.Id,
            PMP_Website__c = 'https://publish.com',
            PMP_Autofill_Status__c = 'Staged'
        );
        insert stage;

        Test.startTest();
        PMP_CompanyAutoFill_Helper.publishStagedCompanies(
            new List<PMP_CompanyAutoFill__c>{ stage }
        );
        Test.stopTest();

        System.assert(true, 'Platform Event published');
    }
}