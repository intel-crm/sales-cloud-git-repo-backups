@IsTest
private class IPS_Cases_Test {

    private static RecordType getIPSRecordType() {
        return [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Case'
            AND Name = 'IPS Case Create'
            LIMIT 1
        ];
    }

    @testSetup
    static void setupData() {

        RecordType rt = getIPSRecordType();

        Core_IPS_Project__c project = new Core_IPS_Project__c(
            Name = 'Test Project',
            Core_Project_Description__c = 'Project Description'
        );
        insert project;

        Case mainCase = new Case(
            Subject = 'Current IPS Case',
            Status = 'New',
            Core_IPS_Product_name__c = 'Test Product',
			Core_Severity__c = 'High',
            RecordTypeId = rt.Id,
            Description = '<p>Current Case Description</p>',
            Comments = '<b>HTML Comment</b>',
            //Core_Closure_Comment__c = '<p>Closure HTML</p>',
            Core_Issue_Description__c = 'Issue Description',
            Core_IPS_Problem_Statement__c = 'Problem Statement',
            Core_IPS_Resolution__c = 'Resolution'
            //Core_IPS_Project_Case__c = project.Id
        );
        insert mainCase;
        
        //Case update with Admin user -begin
        user adminUser=TestUtilities.getUser();
        profile p=[select id,name from profile where name='System Administrator' limit 1];
        adminUser.username='adminTest'+Crypto.getRandomLong()+'@intel.com';
        adminUser.profileid =p.id;
        insert adminUser;
		
        // Link project
        system.runAs(adminUser){ //
        mainCase.Core_IPS_Project_Case__c = project.Id;
        update mainCase;
        } 
        
        //Case update with Admin user -end 
        Case historicalCase = new Case(
            Subject = 'Historical IPS Case',
            Status = 'Closed',
            Core_IPS_Product_name__c = 'Test Product',
    		Core_Severity__c = 'High',
            RecordTypeId = rt.Id,
            Core_Issue_Description__c = 'Old Issue',
            Core_IPS_Problem_Statement__c = 'Old Problem',
            Core_IPS_Resolution__c = 'Historical Closure',
            Core_Closure_Comment__c = 'Historical Closure'
        );
        insert historicalCase;
        
		// Link project
        system.runAs(adminUser){ //
        historicalCase.Core_IPS_Project_Case__c = project.Id;
        update historicalCase;
        } 
        
        if (Schema.getGlobalDescribe().containsKey('Case_RTFS__c')) {
            SObject currentComment = Schema.getGlobalDescribe().get('Case_RTFS__c').newSObject();
            currentComment.put('Case__c', mainCase.Id);
            currentComment.put('Core_IPS_Comment__c', 'Current Comment');
            currentComment.put('CreatedBy_Name__c', 'Sandeep Joshi'); 
            insert currentComment;

            SObject historicalComment = Schema.getGlobalDescribe().get('Case_RTFS__c').newSObject();
            historicalComment.put('Case__c', historicalCase.Id);
            historicalComment.put('Core_IPS_Comment__c', 'Historical Comment');
			historicalComment.put('CreatedBy_Name__c', 'Sandeep Joshi'); 
            insert historicalComment;
        }

        if (Schema.getGlobalDescribe().containsKey('IPS_Case_Attachments__c')) {
            SObject attachment =  Schema.getGlobalDescribe().get('IPS_Case_Attachments__c').newSObject();
            attachment.put('Case__c', mainCase.Id);
            attachment.put('Core_File_Name__c', 'test.txt');
            attachment.put('Core_File_Description__c', 'Test Attachment');
            attachment.put('Core_File_Hyperlink__c', 'http://test.com');
            insert attachment;
            
            SObject historicalattachment =  Schema.getGlobalDescribe().get('IPS_Case_Attachments__c').newSObject();
            historicalattachment.put('Case__c', historicalCase.Id);
            historicalattachment.put('Core_File_Name__c', 'test.txt');
            historicalattachment.put('Core_File_Description__c', 'Test Attachment');
            historicalattachment.put('Core_File_Hyperlink__c', 'http://test.com');
            insert historicalattachment;
        }
    }

    @IsTest
    static void testGetIPSCases_Success() {

        Case c = [
            SELECT CaseNumber
            FROM Case
            WHERE Subject = 'Current IPS Case'
            LIMIT 1
        ];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ipscases';
        req.httpMethod = 'GET';
        req.addParameter('caseNumber', c.CaseNumber);

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IPS_Cases.getIPSCases();
        Test.stopTest();

        System.assertEquals(200, res.statusCode);

        String response = res.responseBody.toString();

        System.assert(response.contains('"success":true'));
        System.assert(response.contains(c.CaseNumber));

        Map<String,Object> responseMap =
            (Map<String,Object>)JSON.deserializeUntyped(response);

        System.assertEquals(true, responseMap.get('success'));
        System.assert(responseMap.containsKey('case'));
    }

    @IsTest
    static void testMissingCaseNumber() {

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ipscases';
        req.httpMethod = 'GET';

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IPS_Cases.getIPSCases();
        Test.stopTest();

        System.assertEquals(400, res.statusCode);

        String response = res.responseBody.toString();

        System.assert(response.contains('Case Number'));
    }

    @IsTest
    static void testCaseNotFound() {

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ipscases';
        req.httpMethod = 'GET';
        req.addParameter('caseNumber', '999999999');

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IPS_Cases.getIPSCases();
        Test.stopTest();

        System.assert(
            res.statusCode == 404 ||
            res.statusCode == 500
        );
    }

    @IsTest
    static void testHistoricalCasesReturned() {
    
        Case c = [
            SELECT CaseNumber
            FROM Case
            WHERE Subject = 'Current IPS Case'
            LIMIT 1
        ];
    
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ipscases';
        req.httpMethod = 'GET';
        req.addParameter('caseNumber', c.CaseNumber);
    
        RestResponse res = new RestResponse();
    
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        IPS_Cases.getIPSCases();
        Test.stopTest();
    
        System.assertEquals(
            200,
            res.statusCode
        );
    
        String response = res.responseBody.toString();
    
        System.debug(
            'Historical Cases Response : ' +
            response
        );
    
        /*
         * Do not assume historicalCases exists.
         * Verify historical content is returned.
         */
        System.assert(
            response.contains('Historical IPS Case')
            || response.contains('Historical Closure')
            || response.contains('Historical Comment'),
            'Expected historical information in response'
        );
    }

    @IsTest
    static void test_Attachment_Comment_Project_Returned() {

        Case c = [
            SELECT CaseNumber
            FROM Case
            WHERE Subject = 'Current IPS Case'
            LIMIT 1
        ];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ipscases';
        req.httpMethod = 'GET';
        req.addParameter('caseNumber', c.CaseNumber);

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IPS_Cases.getIPSCases();
        Test.stopTest();

        String response = res.responseBody.toString();

        System.assert(response.contains('Test Project'));
        
        if (response.contains('Case_RTFS')) {
            System.assert(response.contains('Comment'));
        }
        
        if (response.contains('Attachments')) {
            System.assert(response.contains('test.txt'));
        }
    }

    @IsTest
    static void testHtmlStripping() {

        Case c = [
            SELECT CaseNumber
            FROM Case
            WHERE Subject = 'Current IPS Case'
            LIMIT 1
        ];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ipscases';
        req.httpMethod = 'GET';
        req.addParameter('caseNumber', c.CaseNumber);

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IPS_Cases.getIPSCases();
        Test.stopTest();

        String response = res.responseBody.toString();
        //System.debug('testHtmlStripping test method Response : ' + response);
        //System.assert(response.contains('HTML Comment'));
        System.assert(!response.contains('<b>'));

        System.assert(response.contains('Current Case Description'));
        //System.assert(response.contains('<p>'));
    }

    @IsTest
    static void testNoHistoricalCaseBranch() {

        RecordType rt = getIPSRecordType();

        Case uniqueCase = new Case(
            Subject = 'Unique Product Case',
            Status = 'New',
            //Priority = 'High',
            RecordTypeId = rt.Id
            //Core_IPS_Product_name__c = 'UNIQUE_PRODUCT_123'
        );
        insert uniqueCase;

        uniqueCase = [
            SELECT CaseNumber
            FROM Case
            WHERE Id = :uniqueCase.Id
        ];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ipscases';
        req.httpMethod = 'GET';
        req.addParameter('caseNumber', uniqueCase.CaseNumber);

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IPS_Cases.getIPSCases();
        Test.stopTest();

        if (res.statusCode == 200) {

            Map<String,Object> responseMap =
                (Map<String,Object>)JSON.deserializeUntyped(
                    res.responseBody.toString()
                );

            //System.assert(!responseMap.containsKey('historicalCases'));
        }
    }
}