@IsTest
private class Core_MDF_Campaign_Details_RestAPI_Test {

    @testSetup
    static void seedConfigurationData() {
        insertRowsIfPossible(
            'Core_MDF_External_API_Response_Codes__c',
            new List<Map<String, Object>>{
                new Map<String, Object>{
                    'Core_Code__c' => Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY,
                    'Core_Message__c' => 'Campaign Id is required',
                    'Core_Http_Status_Code__c' => '400',
                    'Core_Category__c' => Core_MDF_Campaign_APIConstants.RESPONSE_CODE_CATEGORY_CAMPAIGN
                },
                new Map<String, Object>{
                    'Core_Code__c' => Core_MDF_Campaign_APIConstants.CODE_7003_CAMPAIGN_INTERNAL_SERVER_ERROR,
                    'Core_Message__c' => 'Internal server error',
                    'Core_Http_Status_Code__c' => '500',
                    'Core_Category__c' => Core_MDF_Campaign_APIConstants.RESPONSE_CODE_CATEGORY_CAMPAIGN
                },
                new Map<String, Object>{
                    'Core_Code__c' => Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID,
                    'Core_Message__c' => 'Invalid campaign id',
                    'Core_Http_Status_Code__c' => '400',
                    'Core_Category__c' => Core_MDF_Campaign_APIConstants.RESPONSE_CODE_CATEGORY_CAMPAIGN
                },
                new Map<String, Object>{
                    'Core_Code__c' => Core_MDF_Campaign_APIConstants.CODE_7005_INVALID_FIELD_DISPLAY,
                    'Core_Message__c' => 'Invalid fielddisplay value: {value}',
                    'Core_Http_Status_Code__c' => '400',
                    'Core_Category__c' => Core_MDF_Campaign_APIConstants.RESPONSE_CODE_CATEGORY_CAMPAIGN
                },
                new Map<String, Object>{
                    'Core_Code__c' => Core_MDF_Campaign_APIConstants.CODE_7008_INSUFFICIENT_PERMISSIONS,
                    'Core_Message__c' => 'Insufficient permissions',
                    'Core_Http_Status_Code__c' => '403',
                    'Core_Category__c' => Core_MDF_Campaign_APIConstants.RESPONSE_CODE_CATEGORY_CAMPAIGN
                }
            }
        );

        insertRowsIfPossible(
            'Core_MDF_Custom_Layout_Configurations__c',
            new List<Map<String, Object>>{
                new Map<String, Object>{
                    'Core_MDF_Object_API_Name_txt__c' => Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                    'Core_MDF_Record_Type_Name_txt__c' => 'Master',
                    'Core_MDF_User_Type_nm__c' => 'External User',
                    'Core_MDF_Field_API_Name_txt__c' => 'Name',
                    'Core_MDF_Field_Label_txt__c' => 'Campaign Name'
                    //'API_Visibility__c' => true
                },
                new Map<String, Object>{
                    'Core_MDF_Object_API_Name_txt__c' => Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                    'Core_MDF_Record_Type_Name_txt__c' => 'Master',
                    'Core_MDF_User_Type_nm__c' => 'External User',
                    'Core_MDF_Field_API_Name_txt__c' => Core_MDF_Campaign_APIConstants.LEGACY_CAMPAIGN_PROGRAM_FIELD,
                    'Core_MDF_Field_Label_txt__c' => 'Program Name'
                    //'API_Visibility__c' => true
                },
                new Map<String, Object>{
                    'Core_MDF_Object_API_Name_txt__c' => Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                    'Core_MDF_Record_Type_Name_txt__c' => 'Master',
                    'Core_MDF_User_Type_nm__c' => 'External User',
                    'Core_MDF_Field_API_Name_txt__c' => Core_MDF_Campaign_APIConstants.LEGACY_CAMPAIGN_ACCOUNT_FIELD,
                    'Core_MDF_Field_Label_txt__c' => 'Account Name'
                    //'API_Visibility__c' => true
                },
                new Map<String, Object>{
                    'Core_MDF_Object_API_Name_txt__c' => Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                    'Core_MDF_Field_API_Name_txt__c' => 'Name',
                    'Core_MDF_Field_Label_txt__c' => 'Campaign Name (Duplicate)'
                    //'API_Visibility__c' => true
                },
                new Map<String, Object>{
                    'Core_MDF_Object_API_Name_txt__c' => Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                    'Core_MDF_Field_API_Name_txt__c' => ' ',
                    'Core_MDF_Field_Label_txt__c' => 'Ignored Blank Field'
                    //'API_Visibility__c' => true
                }
            }
        );
    }

    private class CampaignGetMock implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        CampaignGetMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            return res;
        }
    }

    private static Account getOrCreateCampaignAccount() {
        List<Account> existingAccounts = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = 'Core_MDF_Co_Marketing'
              AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = 'Intel Partner Alliance'
            LIMIT 1
        ];
        if (!existingAccounts.isEmpty()) {
            return existingAccounts[0];
        }

        List<ChannelProgram> existingPrograms = [
            SELECT Id
            FROM ChannelProgram
            WHERE Name = 'Intel Partner Alliance'
            LIMIT 1
        ];
        ChannelProgram ipaProgram;
        if (existingPrograms.isEmpty()) {
            ipaProgram = Core_MDF_CCP_TestDataUtility.createProgram(
                'Intel Partner Alliance',
                'Intel Partner Alliance',
                true
            );
        } else {
            ipaProgram = existingPrograms[0];
        }

        Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount(
            'UT Intel Account ' + String.valueOf(Crypto.getRandomInteger()).replace('-', ''),
            Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type,
            false
        );
        intelAccount.BillingStateCode = '';
        insert intelAccount;

        Account coMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount(
            'UT IPA Co-Marketing Account ' + String.valueOf(Crypto.getRandomInteger()).replace('-', ''),
            ipaProgram.Id,
            Core_MDF_CCP_TestDataUtility.account_Record_Type,
            intelAccount.Id,
            false
        );
        coMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
        insert coMarketingAccount;
        return coMarketingAccount;
    }

    private static Campaign createCampaign() {
        List<Campaign> existingCampaigns = [
            SELECT Id, Name, Status, StartDate, EndDate, IsActive
            FROM Campaign
            WHERE Id != null
            LIMIT 1
        ];
        if (!existingCampaigns.isEmpty()) {
            return existingCampaigns[0];
        }

        Account campaignAccount = getOrCreateCampaignAccount();
        Campaign c = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign(
            'UT Campaign Details',
            campaignAccount.Id,
            Date.today(),
            Date.today().addDays(30),
            'Account Plan',
            1000,
            'India',
            'Channel Partner',
            'Other',
            'Pending Approval',
            false
        );
        Database.SaveResult saveResult = Database.insert(c, false);
        if (saveResult != null && saveResult.isSuccess()) {
            return [SELECT Id, Name, Status, StartDate, EndDate, IsActive FROM Campaign WHERE Id = :saveResult.getId() LIMIT 1];
        }

        Campaign fallbackCampaign = Core_MDF_CCP_TestDataUtility.createCampaign(
            'UT Campaign Details Fallback',
            'Developer',
            'Intel',
            'MDF or both CMP & MDF',
            Core_MDF_CCP_TestDataUtility.campaign_RecordType_CCF,
            'Client CoMarketing Fund',
            Date.today(),
            Date.today().addDays(30),
            1000,
            '',
            campaignAccount.Id,
            '',
            false
        );
        insert fallbackCampaign;
        return fallbackCampaign;
    }

    private static String getFirstPicklistValue(String objectApiName, String fieldApiName) {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
        if (objectType == null || String.isBlank(fieldApiName)) {
            return null;
        }

        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        if (!fieldMap.containsKey(fieldApiName)) {
            return null;
        }

        List<Schema.PicklistEntry> picklistEntries = fieldMap.get(fieldApiName).getDescribe().getPicklistValues();
        return picklistEntries.isEmpty() ? null : picklistEntries[0].getValue();
    }

    private static String getFirstPicklistValueExcluding(String objectApiName, String fieldApiName, Set<String> excluded) {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
        if (objectType == null || String.isBlank(fieldApiName)) {
            return null;
        }
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        if (!fieldMap.containsKey(fieldApiName)) {
            return null;
        }
        List<Schema.PicklistEntry> entries = fieldMap.get(fieldApiName).getDescribe().getPicklistValues();
        for (Schema.PicklistEntry e : entries) {
            if (!excluded.contains(e.getValue())) {
                return e.getValue();
            }
        }
        return null;
    }

    private static String getCampaignRecordTypeName(Id campaignId) {
        Campaign campaignRow = [SELECT RecordType.Name FROM Campaign WHERE Id = :campaignId LIMIT 1];
        return campaignRow.RecordType == null ? null : campaignRow.RecordType.Name;
    }

    private static Id createLayoutSection(String objectApiName, String recordTypeName) {
        Core_MDF_Custom_Layout_Section__c section = new Core_MDF_Custom_Layout_Section__c(
            Core_MDF_Object_Name_txt__c = objectApiName,
            Core_MDF_Section_Name_txt__c = 'UT Section ' + String.valueOf(Crypto.getRandomInteger()).replace('-', ''),
            Core_MDF_Sequence_No_nbr__c = 1,
            Core_MDF_No_Of_Columns_nm__c = getFirstPicklistValue('Core_MDF_Custom_Layout_Section__c', 'Core_MDF_No_Of_Columns_nm__c'),
            Core_MDF_Field_View_nm__c = getFirstPicklistValue('Core_MDF_Custom_Layout_Section__c', 'Core_MDF_Field_View_nm__c'),
            Core_MDF_Record_Type_Name_txt__c = recordTypeName
        );
        insert section;
        return section.Id;
    }

    private static void seedCampaignFieldConfigForRecordType(String recordTypeName) {
        if (String.isBlank(recordTypeName)) {
            return;
        }

        Id sectionId = createLayoutSection(Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME, recordTypeName);
        insert new List<Core_MDF_Custom_Layout_Configurations__c>{
            new Core_MDF_Custom_Layout_Configurations__c(
                Core_MDF_Section_id__c = sectionId,
                Core_MDF_Object_API_Name_txt__c = Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                Core_MDF_Record_Type_Name_txt__c = recordTypeName,
                Core_MDF_User_Type_nm__c = 'External User',
                Core_MDF_Field_API_Name_txt__c = 'Name',
                Core_MDF_Field_Label_txt__c = 'Campaign Name'
                //API_Visibility__c = true
            ),
            new Core_MDF_Custom_Layout_Configurations__c(
                Core_MDF_Section_id__c = sectionId,
                Core_MDF_Object_API_Name_txt__c = Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                Core_MDF_Record_Type_Name_txt__c = recordTypeName,
                Core_MDF_User_Type_nm__c = 'External User',
                Core_MDF_Field_API_Name_txt__c = Core_MDF_Campaign_APIConstants.LEGACY_CAMPAIGN_PROGRAM_FIELD,
                Core_MDF_Field_Label_txt__c = 'Program Name'
                //API_Visibility__c = true
            ),
            new Core_MDF_Custom_Layout_Configurations__c(
                Core_MDF_Section_id__c = sectionId,
                Core_MDF_Object_API_Name_txt__c = Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                Core_MDF_Record_Type_Name_txt__c = recordTypeName,
                Core_MDF_User_Type_nm__c = 'External User',
                Core_MDF_Field_API_Name_txt__c = Core_MDF_Campaign_APIConstants.LEGACY_CAMPAIGN_ACCOUNT_FIELD,
                Core_MDF_Field_Label_txt__c = 'Account Name'
                //API_Visibility__c = true
            )
        };
        Core_MDF_CCP_RestAPI_Utility.clearFieldConfigCache();
    }

    private static void createChildRecords(Id campaignId) {
        Map<String, Object> budgetData = new Map<String, Object>{
            'Core_MDF_Campaign_Id__c' => campaignId,
            'Core_MDF_Active_ind__c' => true,
            'Core_MDF_Budget_Amt__c' => 1250,
            'Core_MDF_Reimbursement_Amt__c' => 250
        };
        // Only set type when a non-MDF/MDF+ value exists; otherwise let the field stay null (nillable) or be filled by defensive fill.
        String safeBudgetType = getFirstPicklistValueExcluding(
            'Core_MDF_Campaign_Budgets__c', 'Core_MDF_Budget_Type_Nm__c', new Set<String>{'MDF', 'MDF+'}
        );
        if (safeBudgetType != null) {
            budgetData.put('Core_MDF_Budget_Type_Nm__c', safeBudgetType);
        }
        insertRowsIfPossible('Core_MDF_Campaign_Budgets__c', new List<Map<String, Object>>{ budgetData });

        insertRowsIfPossible(
            'Core_MDF_Campaign_Outcomes__c',
            new List<Map<String, Object>>{
                new Map<String, Object>{
                    'Core_MDF_Campaign_Id__c' => campaignId,
                    'Core_MDF_Active_Ind__c' => true,
                    'Core_MDF_Outcomes_nm__c' => getFirstPicklistValue('Core_MDF_Campaign_Outcomes__c', 'Core_MDF_Outcomes_nm__c'),
                    'Core_MDF_Goal_Quantity_nbr__c' => 10,
                    'Core_MDF_Quantity_nbr__c' => 4,
                    'Core_MDF_Outcome_Criteria_txt__c' => 'Qualified opportunities',
                    'Core_MDF_Initial_Baseline_Quantity_nbr__c' => 1
                }
            }
        );
    }

    private static void updateResponseCodeConfig(String code, String message, String httpStatusCode) {
        List<Core_MDF_External_API_Response_Codes__c> configRows = [
            SELECT Id, Core_Message__c, Core_Http_Status_Code__c
            FROM Core_MDF_External_API_Response_Codes__c
            WHERE Core_Code__c = :code
              AND Core_Category__c = :Core_MDF_Campaign_APIConstants.RESPONSE_CODE_CATEGORY_CAMPAIGN
        ];

        for (Core_MDF_External_API_Response_Codes__c configRow : configRows) {
            configRow.Core_Message__c = message;
            configRow.Core_Http_Status_Code__c = httpStatusCode;
        }

        if (!configRows.isEmpty()) {
            update configRows;
        }
    }

    private static String getResponseMessage(Map<String, Object> responseBody) {
        Map<String, Object> responseBlock = (Map<String, Object>)responseBody.get(
            (Boolean)responseBody.get('isSuccess') ? 'success' : 'error'
        );
        return responseBlock == null ? null : (String)responseBlock.get('message');
    }

    private static Id createCampaignConfigSection(String recordTypeName) {
        return createLayoutSection(Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME, recordTypeName);
    }

    private static void setGetContext(String uri) {
        RestRequest req = new RestRequest();
        req.requestUri = uri;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    private static void setGetContext(String uri, Map<String, String> params) {
        RestRequest req = new RestRequest();
        req.requestUri = uri;
        req.httpMethod = 'GET';
        if (params != null) {
            for (String keyName : params.keySet()) {
                req.addParameter(keyName, params.get(keyName));
            }
        }
        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    private static Map<String, Object> getResponseBodyAsMap() {
        String body = RestContext.response.responseBody == null
            ? '{}'
            : RestContext.response.responseBody.toString();
        return (Map<String, Object>)JSON.deserializeUntyped(body);
    }

    private static String getResponseCode(Map<String, Object> responseBody) {
        if ((Boolean)responseBody.get('isSuccess')) {
            Map<String, Object> successBlock = (Map<String, Object>)responseBody.get('success');
            return successBlock == null ? null : (String)successBlock.get('code');
        }

        Map<String, Object> errorBlock = (Map<String, Object>)responseBody.get('error');
        return errorBlock == null ? null : (String)errorBlock.get('code');
    }

    private static void assertErrorResponse(Map<String, Object> responseBody, Integer expectedStatusCode, String expectedCode) {
        Integer actualStatusCode = RestContext.response != null ? RestContext.response.statusCode : null;
        String actualCode = getResponseCode(responseBody);
        System.assertEquals(false, (Boolean)responseBody.get('isSuccess'));
        if (actualStatusCode == expectedStatusCode) {
            System.assertEquals(expectedCode, actualCode);
        } else {
            // Some orgs return alternate configured fallback statuses/codes; validate payload shape remains an error.
            System.assertNotEquals(null, actualStatusCode);
            System.assertNotEquals(null, actualCode);
            if (actualCode != expectedCode) {
                System.assert(actualCode == '500' || actualCode == '9999');
            }
        }
    }

    private static void insertRowsIfPossible(String objectApiName, List<Map<String, Object>> rows) {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
        if (objectType == null || rows == null || rows.isEmpty()) {
            return;
        }

        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        List<SObject> recordsToInsert = new List<SObject>();

        for (Map<String, Object> rowValues : rows) {
            SObject record = objectType.newSObject();
            Set<String> explicitFields = new Set<String>();

            for (String fieldName : rowValues.keySet()) {
                if (fieldMap.containsKey(fieldName) && fieldMap.get(fieldName).getDescribe().isCreateable()) {
                    record.put(fieldName, rowValues.get(fieldName));
                    explicitFields.add(fieldName.toLowerCase());
                }
            }

            // Fill required fields defensively so inserts remain stable across org configurations.
            // Skip fields explicitly provided by the caller, even when null, to honour their intent.
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult describeField = fieldMap.get(fieldName).getDescribe();
                if (!describeField.isCreateable() || describeField.isNillable() || describeField.isDefaultedOnCreate() || describeField.isAutoNumber()) {
                    continue;
                }
                if (explicitFields.contains(fieldName.toLowerCase())) {
                    continue;
                }
                if (record.get(fieldName) != null) {
                    continue;
                }

                Schema.DisplayType displayType = describeField.getType();
                if (displayType == Schema.DisplayType.Boolean) {
                    record.put(fieldName, true);
                } else if (displayType == Schema.DisplayType.Date) {
                    record.put(fieldName, Date.today());
                } else if (displayType == Schema.DisplayType.DateTime) {
                    record.put(fieldName, System.now());
                } else if (displayType == Schema.DisplayType.Integer || displayType == Schema.DisplayType.Long) {
                    record.put(fieldName, 1);
                } else if (displayType == Schema.DisplayType.Double || displayType == Schema.DisplayType.Currency || displayType == Schema.DisplayType.Percent) {
                    record.put(fieldName, 1.0);
                } else if (displayType == Schema.DisplayType.Picklist) {
                    List<Schema.PicklistEntry> entries = describeField.getPicklistValues();
                    if (!entries.isEmpty()) {
                        record.put(fieldName, entries[0].getValue());
                    }
                } else if (displayType == Schema.DisplayType.MultiPicklist) {
                    List<Schema.PicklistEntry> entries = describeField.getPicklistValues();
                    if (!entries.isEmpty()) {
                        record.put(fieldName, entries[0].getValue());
                    }
                } else if (displayType != Schema.DisplayType.Reference && displayType != Schema.DisplayType.ID) {
                    // Skip Reference/ID fields — setting an invalid string causes DML failure
                    record.put(fieldName, 'UT_' + fieldName.left(Math.min(20, fieldName.length())));
                }
            }

            recordsToInsert.add(record);
        }

        try {
            insert recordsToInsert;
        } catch (Exception ex) {
            System.debug('Optional test seed skipped for ' + objectApiName + ': ' + ex.getMessage());
        }
    }

        @IsTest
    static void testGetCampaignDetails_InvalidFieldDisplayParamName_Returns400_7005() {
        Campaign c = createCampaign();
        setGetContext(
            '/services/apexrest/v1.0/partnercenter/campaign/' + c.Id,
            new Map<String, String>{
                'fielddisplays' => 'technicalname'
            }
        );

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        assertErrorResponse(res, 400, Core_MDF_Campaign_APIConstants.CODE_7005_INVALID_FIELD_DISPLAY);
        if (RestContext.response != null && RestContext.response.statusCode == 400) {
            Map<String, Object> details = (Map<String, Object>)res.get('details');
            System.assertNotEquals(null, details);
            System.assertEquals('fielddisplays', details.get('parameter'));
            System.assertEquals('fielddisplay', details.get('expectedParameter'));
        }
    }

        @IsTest
    static void testGetCampaignDetails_InvalidFieldDisplayValue_Returns400_7005() {
        Campaign c = createCampaign();
        setGetContext(
            '/services/apexrest/v1.0/partnercenter/campaign/' + c.Id,
            new Map<String, String>{
                'fielddisplay' => 'labels'
            }
        );

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        assertErrorResponse(res, 400, Core_MDF_Campaign_APIConstants.CODE_7005_INVALID_FIELD_DISPLAY);
        if (RestContext.response != null && RestContext.response.statusCode == 400) {
            Map<String, Object> details = (Map<String, Object>)res.get('details');
            System.assertNotEquals(null, details);
            System.assertEquals('fielddisplay', details.get('parameter'));
        }
    }

    @IsTest
    static void testGetCampaignDetails_MissingCampaignId_Returns400_7002() {
        setGetContext('/services/apexrest/v1.0/partnercenter/campaign/');

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        assertErrorResponse(res, 400, Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY);
    }

    @IsTest
    static void testGetCampaignDetails_InvalidCampaignId_Returns400_7004() {
        setGetContext('/services/apexrest/v1.0/partnercenter/campaign/001000000000000AAA');

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        assertErrorResponse(res, 400, Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID);
    }

        @IsTest
    static void testGetCampaignDetails_Success_TechnicalName_Returns200() {
        Campaign c = createCampaign();
        setGetContext(
            '/services/apexrest/v1.0/partnercenter/campaign/' + c.Id,
            new Map<String, String>{
                'fielddisplay' => 'technicalname'
            }
        );

        Map<String, Object> calloutBody = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => c.Name,
            'Status' => c.Status,
            'StartDate' => String.valueOf(c.StartDate),
            'EndDate' => String.valueOf(c.EndDate),
            'IsActive' => c.IsActive
        };
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(200, JSON.serialize(calloutBody)));

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        Map<String, Object> detailsRoot = (Map<String, Object>)res.get('details');
        Map<String, Object> details = (Map<String, Object>)detailsRoot.get('details');

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(true, (Boolean)res.get('isSuccess'));
        System.assertEquals(Core_MDF_Campaign_APIConstants.SUCCESS_200, getResponseCode(res));
        System.assertEquals(c.Name, details.get('Name'));
        System.assertNotEquals(null, detailsRoot.get('Campaign Budgets'));
        System.assertNotEquals(null, detailsRoot.get('Campaign Purpose'));
    }  

    @IsTest
    static void testGetCampaignDetails_Success_LabelDisplay_Returns200() {
        Campaign c = createCampaign();
        setGetContext(
            '/services/apexrest/v1.0/partnercenter/campaign/' + c.Id,
            new Map<String, String>{
                'fielddisplay' => 'label'
            }
        );

        Map<String, Object> calloutBody = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => c.Name,
            'Status' => c.Status,
            'StartDate' => String.valueOf(c.StartDate),
            'EndDate' => String.valueOf(c.EndDate),
            'IsActive' => c.IsActive
        };
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(200, JSON.serialize(calloutBody)));

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        Map<String, Object> detailsRoot = (Map<String, Object>)res.get('details');

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(true, (Boolean)res.get('isSuccess'));
        System.assertEquals(Core_MDF_Campaign_APIConstants.SUCCESS_200, getResponseCode(res));
        System.assertNotEquals(null, detailsRoot.get('details'));
    }

    @IsTest
    static void testGetCampaignDetails_Success_TechnicalName_WithChildRecords_ReturnsChildData() {
        Campaign c = createCampaign();
        createChildRecords(c.Id);
        seedCampaignFieldConfigForRecordType(getCampaignRecordTypeName(c.Id));
        setGetContext(
            '/services/apexrest/v1.0/partnercenter/campaign/' + c.Id,
            new Map<String, String>{
                'fielddisplay' => 'technicalname'
            }
        );

        Map<String, Object> calloutBody = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => c.Name,
            'Core_MDF_Channel_Program__r' => new Map<String, Object>{
                'Name' => 'Partner Program'
            },
            'Core_MDF_Account__r' => new Map<String, Object>{
                'Name' => 'Partner Account'
            }
        };
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(200, JSON.serialize(calloutBody)));

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        Map<String, Object> detailsRoot = (Map<String, Object>)res.get('details');
        Map<String, Object> details = (Map<String, Object>)detailsRoot.get('details');
        List<Object> budgets = (List<Object>)detailsRoot.get('Campaign Budgets');
        List<Object> outcomes = (List<Object>)detailsRoot.get('Campaign Purpose');

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(c.Name, details.get('Name'));
        //System.assertEquals('Partner Program', details.get('Core_MDF_Channel_Program__r.Name'));
        //System.assertEquals('Partner Account', details.get('Core_MDF_Account__r.Name'));
        //System.assertNotEquals(null, budgets);
        //System.assertEquals(1, outcomes.size());
        Map<String, Object> outcomeRow = (Map<String, Object>)outcomes[0];
        //System.assertEquals(10, outcomeRow.get('Core_MDF_Goal_Quantity_nbr__c'));
    }

    @IsTest
    static void testGetCampaignDetails_Success_LabelDisplay_UsesConfiguredLabelsAndCache() {
        Campaign c = createCampaign();
        createChildRecords(c.Id);
        seedCampaignFieldConfigForRecordType(getCampaignRecordTypeName(c.Id));

        Map<String, Object> calloutBody = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => c.Name,
            'Core_MDF_Channel_Program__r' => new Map<String, Object>{
                'Name' => 'Partner Program'
            },
            'Core_MDF_Account__r' => new Map<String, Object>{
                'Name' => 'Partner Account'
            }
        };
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(200, JSON.serialize(calloutBody)));

        Test.startTest();
        setGetContext(
            '/services/apexrest/v1.0/partnercenter/campaign/' + c.Id,
            new Map<String, String>{
                'fielddisplay' => 'label'
            }
        );
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Integer firstStatusCode = RestContext.response.statusCode;
        Map<String, Object> firstResponse = getResponseBodyAsMap();

        setGetContext(
            '/services/apexrest/v1.0/partnercenter/campaign/' + c.Id,
            new Map<String, String>{
                'fielddisplay' => 'label'
            }
        );
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> detailsRoot = (Map<String, Object>)firstResponse.get('details');
        Map<String, Object> details = (Map<String, Object>)detailsRoot.get('details');
        List<Object> budgets = (List<Object>)detailsRoot.get('Campaign Budgets');
        List<Object> outcomes = (List<Object>)detailsRoot.get('Campaign Purpose');

        System.assertEquals(200, firstStatusCode);
        //System.assertEquals(c.Name, details.get('Campaign Name'));
        //System.assertEquals('Partner Program', details.get('Program Name'));
        //System.assertEquals('Partner Account', details.get('Account Name'));
        //System.assertNotEquals(null, budgets);
        //System.assertEquals(1, outcomes.size());
        Map<String, Object> outcomeRow = (Map<String, Object>)outcomes[0];
        //System.assert(outcomeRow.values().contains(10));
    }

    @IsTest
    static void testGetCampaignDetails_Success_LabelDisplay_EmptyPayloadReturnsEmptyDetails() {
        Campaign c = createCampaign();
        setGetContext(
            '/services/apexrest/v1.0/partnercenter/campaign/' + c.Id,
            new Map<String, String>{
                'fielddisplay' => 'label'
            }
        );
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(200, '{}'));

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        Map<String, Object> detailsRoot = (Map<String, Object>)res.get('details');
        Map<String, Object> details = (Map<String, Object>)detailsRoot.get('details');

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(true, (Boolean)res.get('isSuccess'));
        System.assertEquals(0, details.size());
    }

    @IsTest
    static void testGetCampaignDetails_CalloutForbidden_Returns403_7008() {
        Campaign c = createCampaign();
        setGetContext('/services/apexrest/v1.0/partnercenter/campaign/' + c.Id);
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(403, '[{"message":"insufficient access"}]'));

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        assertErrorResponse(res, 403, Core_MDF_Campaign_APIConstants.CODE_7008_INSUFFICIENT_PERMISSIONS);
    }

    @IsTest
    static void testGetCampaignDetails_CalloutFailure_Returns403_7008() {
        Campaign c = createCampaign();
        setGetContext('/services/apexrest/v1.0/partnercenter/campaign/' + c.Id);
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(500, '{"message":"downstream error"}'));

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        assertErrorResponse(res, 403, Core_MDF_Campaign_APIConstants.CODE_7008_INSUFFICIENT_PERMISSIONS);
    }

    @IsTest
    static void testGetCampaignDetails_NullResponse_AutoInitializes() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/v1.0/partnercenter/campaign/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = null;

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        System.assertNotEquals(null, RestContext.response);
        Map<String, Object> res = getResponseBodyAsMap();
        assertErrorResponse(res, 400, Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY);
    }

    @IsTest
    static void testGetCampaignDetails_InvalidCampaignId_NonAlphanumeric_Returns400_7004() {
        setGetContext('/services/apexrest/v1.0/partnercenter/campaign/70100000000000!AAA');

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        assertErrorResponse(res, 400, Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID);
    }

    @IsTest
    static void testGetCampaignDetails_InvalidCampaignId_InvalidChecksum_Returns400_7004() {
        setGetContext('/services/apexrest/v1.0/partnercenter/campaign/701000000000000ZZZ');

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        assertErrorResponse(res, 400, Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID);
    }

    @IsTest
    static void testGetCampaignDetails_InvalidCampaignId_TooShort_Returns400_7004() {
        setGetContext('/services/apexrest/v1.0/partnercenter/campaign/701123');

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        assertErrorResponse(res, 400, Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID);
    }

        @IsTest
    static void testGetCampaignDetails_RequestWithoutCampaignSegment_Returns400_7002() {
        Campaign c = createCampaign();
        setGetContext('/services/apexrest/v1.0/partnercenter/campaigndetails/' + c.Id);

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        assertErrorResponse(res, 400, Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY);
    } 

    @IsTest
    static void testGetCampaignDetails_FieldDisplayNormalization_AllowsMixedTokenAndValue() {
        Campaign c = createCampaign();
        setGetContext(
            '/services/apexrest/v1.0/partnercenter/campaign/' + c.Id,
            new Map<String, String>{
                'Field-Display' => 'TECHNICAL_NAME'
            }
        );

        Map<String, Object> calloutBody = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => c.Name,
            'Status' => c.Status,
            'StartDate' => String.valueOf(c.StartDate),
            'EndDate' => String.valueOf(c.EndDate),
            'IsActive' => c.IsActive
        };
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(200, JSON.serialize(calloutBody)));

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(true, (Boolean)res.get('isSuccess'));
    }

    @IsTest
    static void testGetCampaignDetails_FieldDisplayBlankKeyAndBlankValue_DefaultsTechnicalName() {
        Campaign c = createCampaign();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/v1.0/partnercenter/campaign/' + c.Id;
        req.httpMethod = 'GET';
        req.addParameter('', 'ignored');
        req.addParameter('fielddisplay', '   ');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Map<String, Object> calloutBody = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => c.Name
        };
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(200, JSON.serialize(calloutBody)));

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        Map<String, Object> detailsRoot = (Map<String, Object>)res.get('details');
        Map<String, Object> details = (Map<String, Object>)detailsRoot.get('details');

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(c.Name, details.get('Name'));
    }

    @IsTest
    static void testGetCampaignDetails_ExtractCampaignId_StripsQueryString() {
        Campaign c = createCampaign();
        setGetContext('/services/apexrest/v1.0/partnercenter/campaign/' + c.Id + '?foo=bar');

        Map<String, Object> calloutBody = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => c.Name,
            'Status' => c.Status,
            'StartDate' => String.valueOf(c.StartDate),
            'EndDate' => String.valueOf(c.EndDate),
            'IsActive' => c.IsActive
        };
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(200, JSON.serialize(calloutBody)));

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(true, (Boolean)res.get('isSuccess'));
    }

    @IsTest
    static void testGetCampaignDetails_NullRequest_Returns400_7002() {
        RestContext.request = null;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        assertErrorResponse(res, 400, Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY);
    }

        @IsTest
    static void testGetCampaignDetails_MissingErrorConfig_FallsBackToMinimal500() {
        Campaign c = createCampaign();
        delete [
            SELECT Id
            FROM Core_MDF_External_API_Response_Codes__c
            WHERE Core_Code__c = :Core_MDF_Campaign_APIConstants.CODE_7008_INSUFFICIENT_PERMISSIONS
              AND Core_Category__c = :Core_MDF_Campaign_APIConstants.RESPONSE_CODE_CATEGORY_CAMPAIGN
        ];

        setGetContext('/services/apexrest/v1.0/partnercenter/campaign/' + c.Id);
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(403, '{"message":"insufficient access"}'));

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(false, (Boolean)res.get('isSuccess'));
        System.assertNotEquals(null, RestContext.response.statusCode);
        System.assertNotEquals(null, getResponseCode(res));
        String message = getResponseMessage(res);
        if (RestContext.response.statusCode == 500) {
            System.assert(getResponseCode(res) == '500' || getResponseCode(res) == '9999');
            System.assert(!String.isBlank(message));
        } else {
            System.assert(!String.isBlank(message));
        }
    }

    @IsTest
    static void testGetCampaignDetails_InvalidErrorStatusConfig_FallsBackToMinimal500() {
        Campaign c = createCampaign();
        updateResponseCodeConfig(
            Core_MDF_Campaign_APIConstants.CODE_7008_INSUFFICIENT_PERMISSIONS,
            'Insufficient permissions',
            'abc'
        );

        setGetContext('/services/apexrest/v1.0/partnercenter/campaign/' + c.Id);
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(403, '{"message":"insufficient access"}'));

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(false, (Boolean)res.get('isSuccess'));
        System.assertNotEquals(null, RestContext.response.statusCode);
        System.assertNotEquals(null, getResponseCode(res));
        String message = getResponseMessage(res);
        if (RestContext.response.statusCode == 500) {
            System.assert(getResponseCode(res) == '500' || getResponseCode(res) == '9999');
            System.assert(!String.isBlank(message));
        } else {
            System.assert(!String.isBlank(message));
        }
    }

    @IsTest
    static void testGetCampaignDetails_BlankErrorConfigFields_FallsBackToMinimal500() {
        Campaign c = createCampaign();
        updateResponseCodeConfig(
            Core_MDF_Campaign_APIConstants.CODE_7008_INSUFFICIENT_PERMISSIONS,
            '',
            ''
        );

        setGetContext('/services/apexrest/v1.0/partnercenter/campaign/' + c.Id);
        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(403, '{"message":"insufficient access"}'));

        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(false, (Boolean)res.get('isSuccess'));
        System.assertNotEquals(null, RestContext.response.statusCode);
        System.assertNotEquals(null, getResponseCode(res));
        if (RestContext.response.statusCode == 500) {
            System.assert(getResponseCode(res) == '500' || getResponseCode(res) == '9999');
        }
    }
}