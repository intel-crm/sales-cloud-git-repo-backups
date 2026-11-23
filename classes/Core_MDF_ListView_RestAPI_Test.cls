@isTest
private class Core_MDF_ListView_RestAPI_Test {
    @isTest
    static void passesUnconvertibleFilterValuesThrough() {
        System.assertEquals(
            'invalid-date',
            Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('invalid-date', Schema.DisplayType.Date)
        );
        System.assertEquals(
            'not-a-boolean',
            Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('not-a-boolean', Schema.DisplayType.Boolean)
        );
        System.assertEquals(
            'not-an-id',
            Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('not-an-id', Schema.DisplayType.ID)
        );
        System.assertEquals(
            Time.newInstance(9, 30, 0, 0),
            Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('09:30:00', Schema.DisplayType.Time)
        );
        System.assertEquals(
            '24:30:00',
            Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('24:30:00', Schema.DisplayType.Time)
        );
        System.assertEquals(
            new List<Object>{ 'a', 'b' },
            Core_MDF_ListView_RestAPI.normalizeSingleFilterValue(
                new List<Object>{ 'a', 'b' },
                Schema.DisplayType.String
            )
        );
    }

    @isTest
    static void passesFilterLogicSyntaxToSoqlWithoutValidatingIt() {
        List<String> whereClauses = new List<String>{ 'Name = :v0', 'Status = :v1' };

        System.assertEquals(
            'Name = :v0 OR OR Status = :v1',
            Core_MDF_ListView_RestAPI.buildFilterLogicWhereClause('1 OR OR 2', whereClauses)
        );
        System.assertEquals(
            'Name = :v0 OR INVALID_FILTER_LOGIC_TOKEN',
            Core_MDF_ListView_RestAPI.buildFilterLogicWhereClause('1 OR Name', whereClauses)
        );
    }

    @isTest
    static void returnsSalesforceQueryErrorMessage() {
        RestContext.response = new RestResponse();
        Core_MDF_ListView_RestAPI.ListResponseTracker tracker =
            new Core_MDF_ListView_RestAPI.ListResponseTracker();

        Core_MDF_ListView_RestAPI.sendResponse(
            tracker,
            false,
            'unexpected token: OR',
            '400',
            400,
            null
        );

        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(
            RestContext.response.responseBody.toString()
        );
        Map<String, Object> error = (Map<String, Object>) responseBody.get('error');
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(false, responseBody.containsKey('details'));
        System.assertEquals('unexpected token: OR', error.get('message'));
        System.assertEquals('400', error.get('code'));
        System.assertEquals('400', tracker.statusCode);
        System.assertEquals(false, tracker.isSuccess);
    }

    @isTest
    static void describesInvalidConfiguredOperator() {
        String message = Core_MDF_ListView_RestAPI.buildInvalidOperatorErrorMessage(
            new Map<String, Object>{
                'field' => 'StartDate',
                'operator' => 'CONTAINS',
                'allowedOperators' => new List<String>{ 'EQ', 'GT', 'LT' }
            }
        );

        System.assertEquals(
            'Invalid operator "CONTAINS" for filter "StartDate". Allowed operators for this filter: EQ, GT, LT.',
            message
        );
        System.assertEquals(null, Core_MDF_ListView_RestAPI.buildInvalidOperatorErrorMessage(null));
    }

    @isTest
    static void describesInvalidFilterField() {
        String message = Core_MDF_ListView_RestAPI.buildInvalidFieldErrorMessage(
            new Map<String, Object>{
                'field' => 'UnknownField__c',
                'allowedFields' => new List<String>{ 'Name', 'Status', 'StartDate' }
            }
        );

        System.assertEquals(
            'Invalid field "UnknownField__c". Allowed filter fields: Name, Status, StartDate.',
            message
        );
        System.assertEquals(null, Core_MDF_ListView_RestAPI.buildInvalidFieldErrorMessage(null));
    }

    @isTest
    static void normalizesConfiguredOperatorTokens() {
        System.assertEquals('EQ', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('='));
        System.assertEquals('NE', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('not equal to'));
        System.assertEquals('GT', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('GREATER tHAN'));
        System.assertEquals('GE', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('>='));
        System.assertEquals('INCLUDE', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('INCLUDES'));
        System.assertEquals('NOT CONTAIN', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('NOT LIKE'));
    }

    @isTest
    static void mapsConfiguredOperatorsToSoql() {
        System.assertEquals('=', Core_MDF_ListView_RestAPI.normalizeOperator('EQ'));
        System.assertEquals('!=', Core_MDF_ListView_RestAPI.normalizeOperator('NE'));
        System.assertEquals('>=', Core_MDF_ListView_RestAPI.normalizeOperator('GE'));
        System.assertEquals('INCLUDES', Core_MDF_ListView_RestAPI.normalizeOperator('INCLUDE'));
        System.assertEquals('EXCLUDES', Core_MDF_ListView_RestAPI.normalizeOperator('EXCLUDE'));
        System.assertEquals('LIKE', Core_MDF_ListView_RestAPI.normalizeOperator('CONTAIN'));
        System.assertEquals('%partner%', Core_MDF_ListView_RestAPI.buildContainsPattern('partner'));
        System.assertEquals('%partner%', Core_MDF_ListView_RestAPI.buildContainsPattern('%partner'));
        System.assertEquals('%partner%', Core_MDF_ListView_RestAPI.buildContainsPattern('partner%'));
        System.assertEquals('%partner%', Core_MDF_ListView_RestAPI.buildContainsPattern('%partner%'));
    }

    @isTest
    static void includesNullFieldsInRecordResponse() {
        Campaign campaignRecord = new Campaign(Name = 'Null field response test');
        campaignRecord.put('Core_MDF_Reimbursement_Rate__c', null);
        List<Object> responseRecords = (List<Object>) JSON.deserializeUntyped(
            JSON.serialize(new List<SObject>{ campaignRecord }, false)
        );
        Map<String, Object> responseRecord = (Map<String, Object>) responseRecords[0];

        System.assert(responseRecord.containsKey('Core_MDF_Reimbursement_Rate__c'));
        System.assertEquals(null, responseRecord.get('Core_MDF_Reimbursement_Rate__c'));

        RestContext.response = new RestResponse();
        Core_MDF_ListView_RestAPI.sendResponse(
            new Core_MDF_ListView_RestAPI.ListResponseTracker(),
            true,
            'Records returned',
            '200',
            200,
            new Map<String, Object>{ 'records' => responseRecords }
        );
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(
            RestContext.response.responseBody.toString()
        );
        Map<String, Object> responseDetails = (Map<String, Object>) responseBody.get('details');
        List<Object> serializedRecords = (List<Object>) responseDetails.get('records');
        Map<String, Object> serializedRecord = (Map<String, Object>) serializedRecords[0];

        System.assert(serializedRecord.containsKey('Core_MDF_Reimbursement_Rate__c'));
        System.assertEquals(null, serializedRecord.get('Core_MDF_Reimbursement_Rate__c'));
    }

    @isTest
    static void keysRecordsByConfiguredLabels() {
        Core_MDF_CCP_RestAPI_Utility.FieldConfiguration fieldConfig = Core_MDF_CCP_RestAPI_Utility.buildFieldConfiguration(
            new List<Core_MDF_Custom_Layout_Configurations__c>{
                new Core_MDF_Custom_Layout_Configurations__c(
                    Core_MDF_Field_API_Name_txt__c = 'Name',
                    Core_MDF_Field_Label_txt__c = 'Campaign Name',
                    API_Visibility__c = true
                ),
                new Core_MDF_Custom_Layout_Configurations__c(
                    Core_MDF_Field_API_Name_txt__c = 'Core_MDF_Account__c',
                    Core_MDF_Record_Name_nm__c = 'Core_MDF_Account__r.Name',
                    Core_MDF_Field_Label_txt__c = 'Account',
                    API_Visibility__c = true
                )
            }
        );
        Campaign campaignRecord = new Campaign(Name = 'Label test');
        campaignRecord.putSObject('Core_MDF_Account__r', new Account(Name = 'CCF - LexCorp'));

        List<Object> labeledRecords = Core_MDF_ListView_RestAPI.toLabelKeyedRecords(
            new List<SObject>{ campaignRecord, new Campaign(Name = 'No account') },
            new List<String>{ 'Name', 'Core_MDF_Account__c', 'Core_MDF_Account__r.Name', 'Id' },
            fieldConfig
        );

        Map<String, Object> firstRecord = (Map<String, Object>) labeledRecords[0];
        System.assertEquals('Label test', firstRecord.get('Campaign Name'));
        System.assertEquals('CCF - LexCorp', firstRecord.get('Account'));
        System.assert(firstRecord.containsKey('Account Id'), 'Lookup Id field is labeled with an Id suffix.');
        System.assert(firstRecord.containsKey('Id'));
        System.assertEquals(null, ((Map<String, Object>) labeledRecords[1]).get('Account'));
    }

}