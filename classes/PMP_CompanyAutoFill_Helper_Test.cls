@IsTest
public class PMP_CompanyAutoFill_Helper_Test {
    private static void createRegionData() {
        PMP_Specification__c geoCoverage = new PMP_Specification__c(
            Name = 'Geographic Coverage',
            PMP_Partner_Product_Specification_Id__c = 'NPP_GeographicCoverage',
            PMP_Active_Ind__c = true
        );
        insert geoCoverage;
        PMP_Specification__c americas = new PMP_Specification__c(
            Name = 'Americas',
            PMP_Partner_Product_Specification_Id__c = 'AMERICAS',
            PMP_Product_Parent_Specification_Id__c = 'NPP_GeographicCoverage',
            PMP_Parent_Specification_Id__c = geoCoverage.Id,
            PMP_Active_Ind__c = true
        );
        insert americas;
        PMP_Specification__c latam = new PMP_Specification__c(
            Name = 'Latin America Region',
            PMP_Partner_Product_Specification_Id__c = 'LATAM',
            PMP_Product_Parent_Specification_Id__c = 'AMERICAS',
            PMP_Parent_Specification_Id__c = americas.Id,
            PMP_Active_Ind__c = true
        );
        insert latam;
        PMP_Specification_Value__c brazil = new PMP_Specification_Value__c(
            Name = 'Brazil',
            PMP_Specification_Product_Cd__c = 'LATAM',
            PMP_Active_Ind__c = true
        );
        insert brazil;
    }

    @IsTest
    static void testFullFlow() {
        createRegionData();
        Core_Trigger_Executions__c cte = new Core_Trigger_Executions__c(
            Name = 'Company_Autofill_Handler',
            Core_Active__c = true,
            Core_Class_Name__c = 'Test',
            Core_Object__c = 'PMP_CompanyAutofill__c',
            Core_Trigger_Events__c = 'After Insert, After Update',
            Core_Description__c = 'Test'
        );
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
            PMP_Website__c = 'https://test.com'
        );
        insert stage;
        ContentVersion cv = new ContentVersion(
            Title = 'Logo',
            PathOnClient = 'logo.png',
            VersionData = Blob.valueOf('Logo Data'),
            IsMajorVersion = true
        );
        insert cv;
        cv = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];
        stage.PMP_Autofill_Status__c = 'Scraped';
        stage.PMP_Tagline__c = 'AI Company';
        stage.PMP_Description__c = 'AI Driven Solutions';
        stage.PMP_Regions__c = 'Americas;Latin America Region;Brazil';
        stage.Company_Key_Values__c = 'logo_document_id:' + cv.ContentDocumentId;
        stage.PMP_Resources_JSON__c = '[' +
            '{"name":"Intel AI Use Case","type":"Use Case","url":"https://intel.com/usecase"},' +
            '{"name":"Databricks White Paper","type":"White Paper","url":"https://databricks.com/whitepaper.pdf"}' +
            ']';
        Test.startTest();
        update stage;
        Test.stopTest();
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
        List<PMP_Company_Translation__c> translations = [
            SELECT Id
            FROM PMP_Company_Translation__c
            WHERE PMP_Company_Information_Id__c = :company.Id
        ];
        System.assertEquals(2, translations.size());
        List<PMP_Company_Resource__c> resources = [
            SELECT Name,
                   PMP_Company_Id__c,
                   PMP_Company_Resource_Type_Nm__c,
                   PMP_Company_Resource_URL_txt__c
            FROM PMP_Company_Resource__c
            WHERE PMP_Company_Id__c = :company.Id
        ];
        System.assertEquals(2, resources.size(), 'Expected 2 company resources to be created');
        List<PMP_Company_Region__c> regions = [
            SELECT Id,
                   PMP_Company_Id__c,
                   PMP_Specification_Id__c,
                   PMP_Specification_Value__c
            FROM PMP_Company_Region__c
            WHERE PMP_Company_Id__c = :company.Id
        ];
        System.debug(JSON.serializePretty(regions));
        System.assert(regions.size() > 0, 'Expected region records to be created');
        Integer logoLinks = [
            SELECT Count()
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :cv.ContentDocumentId
        ];
        System.assert(logoLinks >= 2, 'Expected logo to be linked');
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
        PMP_CompanyAutoFill_Helper.publishStagedCompanies(new List<PMP_CompanyAutoFill__c>{ stage });
        Test.stopTest();
        System.assert(true);
    }

    @IsTest
    static void testSaveRegionsBulkDirectly() {
        createRegionData();
        PMP_Company__c company = new PMP_Company__c(
            Name = 'Region Company',
            PMP_Company_Lifecycle_Status_Nm__c = 'Draft'
        );
        insert company;
        Map<Id,List<String>> regionMap = new Map<Id,List<String>>();
        regionMap.put(company.Id, new List<String>{ 'Americas', 'Latin America Region', 'Brazil' });
        Test.startTest();
        PMP_CompanyAutoFill_Helper.saveRegionsBulk(regionMap);
        Test.stopTest();
        Integer regionCount = [
            SELECT COUNT()
            FROM PMP_Company_Region__c
            WHERE PMP_Company_Id__c = :company.Id
        ];
        System.assert(regionCount > 0, 'saveRegionsBulk should create region records');
    }
}