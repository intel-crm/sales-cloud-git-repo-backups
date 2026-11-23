@IsTest
public class IPS_QualityBuilderReportBatch_Test {

    private class UploadMock implements HttpCalloutMock {
        private Integer statusCode;
        UploadMock(Integer statusCode) { this.statusCode = statusCode; }
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody('{}');
            return res;
        }
    }

    private static IPS_QualityBuilder_Generic_Pipe_Setting__c settings() {
        return new IPS_QualityBuilder_Generic_Pipe_Setting__c(
            Name = 'Test Job',
            Report_Id__c = '00O000000000001AAA',
            File_Name_Prefix__c = 'QB_Test_',
            File_Name_Date_Format__c = 'yyyyMMdd'
        );
    }

    private static IPS_QualityBuilderReportBatch newBatch(List<String> fields) {
        IPS_QualityBuilderReportBatch batch = new IPS_QualityBuilderReportBatch(settings());
        batch.fieldApiNames = fields;
        return batch;
    }

    @IsTest
    static void testStart_QueryBuildFails_ReturnsEmptyLocator() {
        IPS_QualityBuilderReportBatch batch = new IPS_QualityBuilderReportBatch(settings());

        Test.startTest();
        Database.QueryLocator locator = batch.start(null);
        Test.stopTest();

        System.assertNotEquals(null, locator, 'start() should always return a QueryLocator.');
        System.assertEquals(false, batch.queryBuilt, 'queryBuilt should stay false when the query cannot be built.');
    }

    @IsTest
    static void testExecute() {
        Account acc = new Account(Id = '001000000000001AAA', Name = 'Test Account');
        IPS_QualityBuilderReportBatch batch = newBatch(new List<String>{ 'Id', 'Name' });

        Test.startTest();
        batch.execute(null, new List<SObject>{ acc });
        Test.stopTest();

        System.assertEquals(1, batch.csvRows.size());
        System.assertEquals('001000000000001AAA,Test Account', batch.csvRows[0]);
        System.assertEquals(1, batch.grandTotal);
    }

    @IsTest
    static void testExecute_RelationshipField() {
        Account acc = new Account(Id = '001000000000001AAA', Name = 'Test Account');
        acc.Owner = new User(Id = UserInfo.getUserId(), LastName = 'Owner Last');
        IPS_QualityBuilderReportBatch batch = newBatch(new List<String>{ 'Id', 'Name', 'Owner.LastName' });

        Test.startTest();
        batch.execute(null, new List<SObject>{ acc });
        Test.stopTest();

        System.assertEquals('001000000000001AAA,Test Account,Owner Last', batch.csvRows[0]);
    }

    @IsTest
    static void testExecute_EmptyScope() {
        IPS_QualityBuilderReportBatch batch = newBatch(new List<String>{ 'Id' });

        Test.startTest();
        batch.execute(null, new List<SObject>());
        Test.stopTest();

        System.assertEquals(0, batch.csvRows.size());
        System.assertEquals(0, batch.grandTotal);
    }

    @IsTest
    static void testExecute_InvalidField_IsCaughtNotThrown() {
        Account acc = new Account(Id = '001000000000001AAA', Name = 'Test Account');
        IPS_QualityBuilderReportBatch batch = newBatch(new List<String>{ 'Not_A_Field__c' });

        Test.startTest();
        batch.execute(null, new List<SObject>{ acc }); 
        Test.stopTest();

        System.assertEquals(0, batch.csvRows.size(), 'No row should be added when a field read fails.');
    }

    @IsTest
    static void testFinish_QueryNotBuilt_DoesNothing() {
        IPS_QualityBuilderReportBatch batch = newBatch(new List<String>{ 'Id' });
        batch.queryBuilt = false;

        Test.startTest();
        batch.finish(null);  
        Test.stopTest();

        System.assertEquals(false, batch.queryBuilt);
    }

    @IsTest
    static void testFinish_Success() {
        IPS_QualityBuilderReportBatch batch = newBatch(new List<String>{ 'Id', 'Name' });
        batch.queryBuilt = true;
        batch.csvRows.add('Id,Name');
        batch.csvRows.add('001000000000001AAA,Test Account');
        batch.grandTotal = 1;

        Test.setMock(HttpCalloutMock.class, new UploadMock(200));
        Test.startTest();
        batch.finish(null);
        Test.stopTest();

        System.assertEquals(null, IPS_QualityBuilderUtility.errorMessage == '' ? null : IPS_QualityBuilderUtility.errorMessage);
    }

    @IsTest
    static void testFinish_UploadFails() {
        IPS_QualityBuilderReportBatch batch = newBatch(new List<String>{ 'Id' });
        batch.queryBuilt = true;
        batch.csvRows.add('Id');
        batch.csvRows.add('001000000000001AAA');
        batch.grandTotal = 1;

        Test.setMock(HttpCalloutMock.class, new UploadMock(500));
        Test.startTest();
        batch.finish(null);
        Test.stopTest();

        System.assert(String.isNotBlank(IPS_QualityBuilderUtility.errorMessage),
            'A 500 response should leave an error message after retries.');
    }

    @IsTest
    static void testGetFieldValue_SimpleField() {
        Account acc = new Account(Id = '001000000000001AAA', Name = 'Test Account');
        System.assertEquals('Test Account', (String) newBatch(new List<String>{ 'Name' }).getFieldValue(acc, 'Name'));
    }

    @IsTest
    static void testGetFieldValue_Id() {
        Account acc = new Account(Id = '001000000000001AAA', Name = 'Test Account');
        System.assertEquals(acc.Id, newBatch(new List<String>{ 'Id' }).getFieldValue(acc, 'Id'));
    }

    @IsTest
    static void testGetFieldValue_NullValue() {
        Account acc = new Account(Id = '001000000000001AAA');
        System.assertEquals(null, newBatch(new List<String>{ 'Name' }).getFieldValue(acc, 'Name'));
    }

    @IsTest
    static void testGetFieldValue_NullRelationship() {
        Account acc = new Account(Id = '001000000000001AAA', Name = 'Test Account');
        System.assertEquals(null, newBatch(new List<String>{ 'Owner.Name' }).getFieldValue(acc, 'Owner.Name'));
    }

    @IsTest
    static void testGetFieldValue_NullRecord() {
        System.assertEquals(null, newBatch(new List<String>{ 'Name' }).getFieldValue(null, 'Owner.Name'));
    }

    @IsTest
    static void testBuildCsvLine_SimpleValues() {
        System.assertEquals('001,John,Active',
            newBatch(new List<String>{ 'Id' }).buildCsvLine(new List<String>{ '001', 'John', 'Active' }));
    }

    @IsTest
    static void testBuildCsvLine_CommasAndQuotes() {
        System.assertEquals('001,"Acme, Inc.","John ""JD"" Smith"',
            newBatch(new List<String>{ 'Id' }).buildCsvLine(new List<String>{ '001', 'Acme, Inc.', 'John "JD" Smith' }));
    }

    @IsTest
    static void testBuildCsvLine_NewLine() {
        System.assertEquals('001,"Line 1\nLine 2"',
            newBatch(new List<String>{ 'Id' }).buildCsvLine(new List<String>{ '001', 'Line 1\nLine 2' }));
    }

    @IsTest
    static void testBuildCsvLine_NullValues() {
        System.assertEquals('001,,Test',
            newBatch(new List<String>{ 'Id' }).buildCsvLine(new List<String>{ '001', null, 'Test' }));
    }

    @IsTest
    static void testEscapeCsv() {
        IPS_QualityBuilderReportBatch b = newBatch(new List<String>{ 'Id' });
        System.assertEquals('', b.escapeCsv(null));
        System.assertEquals('Hello', b.escapeCsv('Hello'));
        System.assertEquals('"Hello, World"', b.escapeCsv('Hello, World'));
        System.assertEquals('"He said ""Hello"""', b.escapeCsv('He said "Hello"'));
        System.assertEquals('"Hello\nWorld"', b.escapeCsv('Hello\nWorld'));
        System.assertEquals('"Hello\rWorld"', b.escapeCsv('Hello\rWorld'));
    }
}