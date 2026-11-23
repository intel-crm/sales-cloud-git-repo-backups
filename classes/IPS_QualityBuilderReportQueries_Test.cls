@isTest
public class IPS_QualityBuilderReportQueries_Test {

    @isTest
    static void testBuildQueryDetails_nullInputsReturnNull() {
        System.assertEquals(null, IPS_QualityBuilderReportQueries.buildQueryDetailsFromReportId(null, '00O123', 'Case'));
        System.assertEquals(null, IPS_QualityBuilderReportQueries.buildQueryDetailsFromReportId('JobA', null, 'Case'));
        System.assertEquals(null, IPS_QualityBuilderReportQueries.buildQueryDetailsFromReportId('JobA', '00O123', null));
    }

    @isTest
    static void testBuildQueryDetails_describeUnavailableInTestContextReturnsNull() {
        Test.startTest();
        IPS_QualityBuilderReportQueries.QueryBuildResult result =
            IPS_QualityBuilderReportQueries.buildQueryDetailsFromReportId('JobA', '00O123456789ABC', 'Case');
        Test.stopTest();

        System.assertEquals(null, result);
    }

    @isTest
    static void testGetReportDescribe_returnsNullUnderTest() {
        Map<String, Object> result = IPS_QualityBuilderReportQueries.getReportDescribe('JobA', '00O123456789ABC');
        System.assertEquals(null, result);
    }

    @isTest
    static void testGetDetailColumnInfo_nullDescribeResult() {
        System.assertEquals(null, IPS_QualityBuilderReportQueries.getDetailColumnInfo(null));
    }

    @isTest
    static void testGetDetailColumnInfo_missingExtendedMetadata() {
        Map<String, Object> describeResult = new Map<String, Object>{ 'reportMetadata' => new Map<String, Object>() };
        System.assertEquals(null, IPS_QualityBuilderReportQueries.getDetailColumnInfo(describeResult));
    }

    @isTest
    static void testGetDetailColumnInfo_happyPath() {
        Map<String, Object> describeResult = buildSampleDescribeResult();
        Map<String, Object> info = IPS_QualityBuilderReportQueries.getDetailColumnInfo(describeResult);
        System.assertNotEquals(null, info);
        System.assertEquals(true, info.containsKey('Case.CaseNumber'));
    }

    @isTest
    static void testGetFieldList_resolvesFieldsAndLabelsInOrder_andAppendsId() {
        Map<String, Object> describeResult = buildSampleDescribeResult();
        Map<String, Object> reportMetadata = (Map<String, Object>) describeResult.get('reportMetadata');

        IPS_QualityBuilderReportQueries.FieldsWrapper fw =
            IPS_QualityBuilderReportQueries.getFieldList(reportMetadata, describeResult, 'Case');

        System.assertNotEquals(null, fw);
        System.assertEquals(4, fw.fields.size(), 'Expected 4 resolved report columns');
        System.assertEquals(fw.fields.size(), fw.fieldLabels.size(), 'fields and fieldLabels must stay index-aligned');

        System.assertEquals('CaseNumber', fw.fields[0]);
        System.assertEquals('Case Number', fw.fieldLabels[0]);

        System.assertEquals('Account.Name', fw.fields[1]);
        System.assertEquals('Account Name', fw.fieldLabels[1]);

        System.assertEquals('Status', fw.fields[2]);
        System.assertEquals('Status', fw.fieldLabels[2]);

        System.assertEquals('Owner.Name', fw.fields[3]);
        System.assertEquals('Case Owner', fw.fieldLabels[3]);

        System.assertEquals(true, fw.selectExpressions.contains('Id'),
            'Id should be auto-appended to the select expressions when not already selected');
    }

    @isTest
    static void testGetFieldList_dedupesRepeatedResolvedField() {
        Map<String, Object> detailColumnInfo = new Map<String, Object>{
            'Case.Status' => new Map<String, Object>{ 'label' => 'Status (A)' },
            'Status'      => new Map<String, Object>{ 'label' => 'Status (B)' }
        };
        Map<String, Object> reportMetadata = new Map<String, Object>{
            'detailColumns' => new List<Object>{ 'Case.Status', 'Status' }
        };
        Map<String, Object> describeResult = new Map<String, Object>{
            'reportExtendedMetadata' => new Map<String, Object>{ 'detailColumnInfo' => detailColumnInfo }
        };

        IPS_QualityBuilderReportQueries.FieldsWrapper fw =
            IPS_QualityBuilderReportQueries.getFieldList(reportMetadata, describeResult, 'Case');

        System.assertEquals(1, fw.fields.size(), 'Expected one deduped Status field');
        System.assertEquals('Status', fw.fields[0]);
        System.assertEquals('Status (A)', fw.fieldLabels[0], 'First occurrence label should win');
        System.assertEquals(true, fw.selectExpressions.contains('Id'),
            'Id should still be auto-appended to the select expressions');
    }

    @isTest
    static void testGetFieldList_skipsUnresolvableColumns() {
        Map<String, Object> reportMetadata = new Map<String, Object>{
            'detailColumns' => new List<Object>{ '', 'BUCKET_FIELD_1', 'Case.Not_A_Real_Field__c' }
        };
        Map<String, Object> describeResult = new Map<String, Object>{
            'reportExtendedMetadata' => new Map<String, Object>{ 'detailColumnInfo' => new Map<String, Object>() }
        };

        IPS_QualityBuilderReportQueries.FieldsWrapper fw =
            IPS_QualityBuilderReportQueries.getFieldList(reportMetadata, describeResult, 'Case');

        System.assertEquals(0, fw.fields.size(), 'Unresolvable columns should be skipped entirely');
        System.assertEquals(new List<String>{ 'Id' }, fw.selectExpressions,
            'Only the auto-added Id should remain in the select expressions');
    }

    @isTest
    static void testGetFieldList_alreadyContainsId_doesNotDuplicateIt() {
        Map<String, Object> detailColumnInfo = new Map<String, Object>{
            'Case.Id' => new Map<String, Object>{ 'label' => 'Record ID' }
        };
        Map<String, Object> reportMetadata = new Map<String, Object>{
            'detailColumns' => new List<Object>{ 'Case.Id' }
        };
        Map<String, Object> describeResult = new Map<String, Object>{
            'reportExtendedMetadata' => new Map<String, Object>{ 'detailColumnInfo' => detailColumnInfo }
        };

        IPS_QualityBuilderReportQueries.FieldsWrapper fw =
            IPS_QualityBuilderReportQueries.getFieldList(reportMetadata, describeResult, 'Case');

        System.assertEquals(1, fw.fields.size(), 'Only the explicitly selected Id column is expected');
        System.assertEquals('Id', fw.fields[0]);
        System.assertEquals('Record ID', fw.fieldLabels[0], 'Explicit label from detailColumnInfo should be kept');
        System.assertEquals(1, countOccurrences(fw.selectExpressions, 'Id'),
            'Id should not be appended twice to the select expressions');
    }

    @isTest
    static void testGetFieldList_noDetailColumnInfo_labelFallsBackToFieldName() {
        Map<String, Object> reportMetadata = new Map<String, Object>{
            'detailColumns' => new List<Object>{ 'Case.Status' }
        };
        Map<String, Object> describeResult = new Map<String, Object>(); // no reportExtendedMetadata

        IPS_QualityBuilderReportQueries.FieldsWrapper fw =
            IPS_QualityBuilderReportQueries.getFieldList(reportMetadata, describeResult, 'Case');

        System.assertEquals('Status', fw.fields[0]);
        System.assertEquals('Status', fw.fieldLabels[0]);
    }

    @isTest
    static void testGetFieldList_nullDetailColumns_returnsOnlyId() {
        IPS_QualityBuilderReportQueries.FieldsWrapper fw =
            IPS_QualityBuilderReportQueries.getFieldList(new Map<String, Object>(), new Map<String, Object>(), 'Case');

        System.assertEquals(0, fw.fields.size(), 'No report columns means no fields or labels');
        System.assertEquals(0, fw.fieldLabels.size());
        System.assertEquals(new List<String>{ 'Id' }, fw.selectExpressions,
            'Only the auto-added Id should remain in the select expressions');
    }

    @isTest
    static void testResolveColumnLabel_usesLabelWhenPresent() {
        Map<String, Object> detailColumnInfo = new Map<String, Object>{
            'Case.Status' => new Map<String, Object>{ 'label' => 'Case Status' }
        };
        System.assertEquals('Case Status',
            IPS_QualityBuilderReportQueries.resolveColumnLabel('Case.Status', detailColumnInfo, 'Status'));
    }

    @isTest
    static void testResolveColumnLabel_fallsBackToFieldNameWhenLabelMissing() {
        Map<String, Object> detailColumnInfo = new Map<String, Object>{
            'STATUS' => new Map<String, Object>{ 'fullyQualifiedName' => 'Status' }
        };
        String label = IPS_QualityBuilderReportQueries.resolveColumnLabel('STATUS', detailColumnInfo, 'Status');
        System.assertEquals('Status', label);
    }

    @isTest
    static void testResolveColumnLabel_fallsBackWhenColumnKeyUnknown() {
        String label = IPS_QualityBuilderReportQueries.resolveColumnLabel('UNKNOWN_COL', new Map<String, Object>(), 'SomeField__c');
        System.assertEquals('SomeField__c', label);
    }

    @isTest
    static void testResolveColumnLabel_fallsBackWhenDetailColumnInfoNull() {
        String label = IPS_QualityBuilderReportQueries.resolveColumnLabel('STATUS', null, 'Status');
        System.assertEquals('Status', label);
    }

    @isTest
    static void testResolveEntityColumnName() {
        System.assertEquals('Status', IPS_QualityBuilderReportQueries.resolveEntityColumnName('Status', 'Case'));
        System.assertEquals('Status', IPS_QualityBuilderReportQueries.resolveEntityColumnName('Case.Status', 'Case'));
        System.assertEquals('Account.Name', IPS_QualityBuilderReportQueries.resolveEntityColumnName('Case.Account.Name', 'Case'));
        System.assertEquals(null, IPS_QualityBuilderReportQueries.resolveEntityColumnName('NOT_A_FIELD', 'Case'));
        System.assertEquals(null, IPS_QualityBuilderReportQueries.resolveEntityColumnName(null, 'Case'));
    }

    @isTest
    static void testResolveColumn_blankInputsReturnNull() {
        System.assertEquals(null, IPS_QualityBuilderReportQueries.resolveColumn(null, 'Case'));
        System.assertEquals(null, IPS_QualityBuilderReportQueries.resolveColumn('', 'Case'));
        System.assertEquals(null, IPS_QualityBuilderReportQueries.resolveColumn('Status', null));
        System.assertEquals(null, IPS_QualityBuilderReportQueries.resolveColumn('Status', ''));
    }

    @isTest
    static void testResolveColumn_simpleField_withAndWithoutRootPrefix() {
        IPS_QualityBuilderReportQueries.ResolvedColumn plain =
            IPS_QualityBuilderReportQueries.resolveColumn('Status', 'Case');
        System.assertEquals('Status', plain.soqlPath);
        System.assertEquals(Schema.DisplayType.PICKLIST, plain.displayType);

        IPS_QualityBuilderReportQueries.ResolvedColumn prefixed =
            IPS_QualityBuilderReportQueries.resolveColumn('Case.Status', 'Case');
        System.assertEquals('Status', prefixed.soqlPath);

        IPS_QualityBuilderReportQueries.ResolvedColumn mixedCase =
            IPS_QualityBuilderReportQueries.resolveColumn('case.STATUS', 'Case');
        System.assertEquals('Status', mixedCase.soqlPath, 'Lookup should be case-insensitive and return the canonical API name');
    }

    @isTest
    static void testResolveColumn_rootOnly_returnsNull() {
        System.assertEquals(null, IPS_QualityBuilderReportQueries.resolveColumn('Case', 'Case'));
    }

    @isTest
    static void testResolveColumn_relationshipTraversal() {
        IPS_QualityBuilderReportQueries.ResolvedColumn rc =
            IPS_QualityBuilderReportQueries.resolveColumn('Case.Account.Name', 'Case');
        System.assertEquals('Account.Name', rc.soqlPath);
        System.assertEquals(Schema.DisplayType.STRING, rc.displayType);

        IPS_QualityBuilderReportQueries.ResolvedColumn deeper =
            IPS_QualityBuilderReportQueries.resolveColumn('Case.Account.Owner.Name', 'Case');
        System.assertEquals('Account.Owner.Name', deeper.soqlPath);
    }

    @isTest
    static void testResolveColumn_polymorphicOwnerResolvesToUser() {
        IPS_QualityBuilderReportQueries.ResolvedColumn rc =
            IPS_QualityBuilderReportQueries.resolveColumn('Case.Owner.Name', 'Case');
        System.assertNotEquals(null, rc);
        System.assertEquals('Owner.Name', rc.soqlPath);
    }

    @isTest
    static void testResolveColumn_lastSegmentIsRelationship_appendsName() {
        IPS_QualityBuilderReportQueries.ResolvedColumn rc =
            IPS_QualityBuilderReportQueries.resolveColumn('Case.Owner', 'Case');
        System.assertNotEquals(null, rc);
        System.assertEquals('Owner.Name', rc.soqlPath);
        System.assertEquals(Schema.DisplayType.STRING, rc.displayType);
    }

    @isTest
    static void testResolveColumn_unknownFieldOrRelationship_returnsNull() {
        System.assertEquals(null, IPS_QualityBuilderReportQueries.resolveColumn('Case.Not_A_Field__c', 'Case'));
        System.assertEquals(null, IPS_QualityBuilderReportQueries.resolveColumn('Case.Not_A_Rel__r.Name', 'Case'));
        System.assertEquals(null, IPS_QualityBuilderReportQueries.resolveColumn('Status', 'Not_A_Real_Object__x'));
    }

    @isTest
    static void testResolveColumn_nonReferenceFieldUsedAsRelationship_returnsNull() {
        System.assertEquals(null, IPS_QualityBuilderReportQueries.resolveColumn('Case.Status.Name', 'Case'));
    }

    @isTest
    static void testResolveColumn_otherObjectPrefix_isRejected() {
        System.assertEquals(null, IPS_QualityBuilderReportQueries.resolveColumn('Account.Name', 'Case'));
    }

    @isTest
    static void testResolveColumn_exceedsMaxRelationshipDepth_returnsNull() {
        System.assertEquals(null,
            IPS_QualityBuilderReportQueries.resolveColumn(
                'Case.Contact.Account.Owner.Manager.Manager.Manager.Name', 'Case'));

        IPS_QualityBuilderReportQueries.ResolvedColumn ok =
            IPS_QualityBuilderReportQueries.resolveColumn('Case.Contact.Account.Owner.Manager.Name', 'Case');
        System.assertNotEquals(null, ok);
        System.assertEquals('Contact.Account.Owner.Manager.Name', ok.soqlPath);
    }

    @isTest
    static void testPickReferenceTarget() {
        
        System.assertEquals('User',
            IPS_QualityBuilderReportQueries.pickReferenceTarget(Schema.SObjectType.Case.fields.OwnerId));

        System.assertEquals('Account',
            IPS_QualityBuilderReportQueries.pickReferenceTarget(Schema.SObjectType.Contact.fields.AccountId));

        System.assertEquals(null,
            IPS_QualityBuilderReportQueries.pickReferenceTarget(Schema.SObjectType.Case.fields.Status));
    }

    @isTest
    static void testIsPlausibleFieldPath() {
        System.assertEquals(true, IPS_QualityBuilderReportQueries.isPlausibleFieldPath('Account.Owner.Name'));
        System.assertEquals(true, IPS_QualityBuilderReportQueries.isPlausibleFieldPath('Status__c'));
        System.assertEquals(false, IPS_QualityBuilderReportQueries.isPlausibleFieldPath('Status; DROP TABLE'));
        System.assertEquals(false, IPS_QualityBuilderReportQueries.isPlausibleFieldPath('Field Name With Spaces'));
    }

    @isTest
    static void testBuildWhereClause_defaultAndLogic_noBooleanFilter() {
        Map<String, Object> describeResult = buildSampleDescribeResult();
        Map<String, Object> reportMetadata = (Map<String, Object>) describeResult.get('reportMetadata');

        String whereClause = IPS_QualityBuilderReportQueries.buildWhereClause(reportMetadata, describeResult, 'Case');
        System.assertEquals(
            'Status IN (\'Open\', \'Escalated\') AND CaseNumber LIKE \'%00001%\'',
            whereClause
        );
    }

    @isTest
    static void testBuildWhereClause_customBooleanTemplate() {
        Map<String, Object> describeResult = buildSampleDescribeResult();
        Map<String, Object> reportMetadata = (Map<String, Object>) describeResult.get('reportMetadata');
        reportMetadata.put('reportBooleanFilter', '1 OR 2');

        String whereClause = IPS_QualityBuilderReportQueries.buildWhereClause(reportMetadata, describeResult, 'Case');
        System.assertEquals(
            '(Status IN (\'Open\', \'Escalated\')) OR (CaseNumber LIKE \'%00001%\')',
            whereClause
        );
    }

    @isTest
    static void testBuildWhereClause_noFiltersReturnsNull() {
        Map<String, Object> reportMetadata = new Map<String, Object>{ 'reportFilters' => new List<Object>() };
        System.assertEquals(null,
            IPS_QualityBuilderReportQueries.buildWhereClause(reportMetadata, new Map<String, Object>(), 'Case'));

        System.assertEquals(null,
            IPS_QualityBuilderReportQueries.buildWhereClause(new Map<String, Object>(), new Map<String, Object>(), 'Case'));
    }

    @isTest
    static void testBuildWhereClause_unresolvableFilterDroppedAsNoOp() {
        Map<String, Object> reportMetadata = new Map<String, Object>{
            'reportFilters' => new List<Object>{
                new Map<String, Object>{ 'column' => '', 'operator' => 'equals', 'value' => 'x' }
            }
        };
        String whereClause = IPS_QualityBuilderReportQueries.buildWhereClause(reportMetadata, new Map<String, Object>(), 'Case');
        System.assertEquals(null, whereClause, 'A wholly unresolvable filter should leave no condition, not throw');
    }

    @isTest
    static void testBuildWhereClause_partiallyUnresolvable_keepsNumberingAligned() {
        Map<String, Object> reportMetadata = new Map<String, Object>{
            'reportFilters' => new List<Object>{
                new Map<String, Object>{ 'column' => 'BUCKET_FIELD_1', 'operator' => 'equals', 'value' => 'x' },
                new Map<String, Object>{ 'column' => 'Case.Status', 'operator' => 'equals', 'value' => 'Open' }
            },
            'reportBooleanFilter' => '1 OR 2'
        };

        String whereClause = IPS_QualityBuilderReportQueries.buildWhereClause(reportMetadata, new Map<String, Object>(), 'Case');
        System.assertEquals('(Id != null) OR (Status = \'Open\')', whereClause);
    }

    @isTest
    static void testBuildWhereClause_unknownOperatorDefaultsToEquals() {
        Map<String, Object> reportMetadata = new Map<String, Object>{
            'reportFilters' => new List<Object>{
                new Map<String, Object>{ 'column' => 'Case.Subject', 'operator' => 'somethingNew', 'value' => 'Hello' }
            }
        };
        String whereClause = IPS_QualityBuilderReportQueries.buildWhereClause(reportMetadata, new Map<String, Object>(), 'Case');
        System.assertEquals('Subject = \'Hello\'', whereClause);
    }

    @isTest
    static void testApplyBooleanFilterTemplate_basicAndOr() {
        Map<Integer, String> conditions = new Map<Integer, String>{
            1 => 'Status = \'Open\'',
            2 => 'Priority = \'High\'',
            3 => 'Amount__c > 1000'
        };
        String result = IPS_QualityBuilderReportQueries.applyBooleanFilterTemplate('1 AND (2 OR 3)', conditions);
        System.assertEquals('(Status = \'Open\') AND ((Priority = \'High\') OR (Amount__c > 1000))', result);
    }

    @isTest
    static void testApplyBooleanFilterTemplate_conditionTextContainingDigitsIsNotReSubstituted() {
        Map<Integer, String> conditions = new Map<Integer, String>{
            1 => 'Amount__c > 2',
            2 => 'Priority = \'1\''
        };
        String result = IPS_QualityBuilderReportQueries.applyBooleanFilterTemplate('1 AND 2', conditions);
        System.assertEquals('(Amount__c > 2) AND (Priority = \'1\')', result);
    }

    @isTest
    static void testApplyBooleanFilterTemplate_unresolvedReferenceBecomesNoOp() {
        Map<Integer, String> conditions = new Map<Integer, String>{ 1 => 'Status = \'Open\'' };
        // Reference 2 has no matching condition (e.g. it was dropped upstream as unresolvable).
        String result = IPS_QualityBuilderReportQueries.applyBooleanFilterTemplate('1 AND 2', conditions);
        System.assertEquals('(Status = \'Open\') AND (Id != null)', result);
    }

    @isTest
    static void testApplyBooleanFilterTemplate_notOperator() {
        Map<Integer, String> conditions = new Map<Integer, String>{
            1 => 'Status = \'Open\'',
            2 => 'Priority = \'High\''
        };
        String result = IPS_QualityBuilderReportQueries.applyBooleanFilterTemplate('1 AND NOT 2', conditions);
        System.assertEquals('(Status = \'Open\') AND (NOT (Priority = \'High\'))', result);
    }

    @isTest
    static void testWrapNotGroups_bareNumberAndParenthesizedGroup() {
        System.assertEquals('1 AND (NOT 2)', IPS_QualityBuilderReportQueries.wrapNotGroups('1 AND NOT 2'));
        System.assertEquals('(NOT (2 AND 3))', IPS_QualityBuilderReportQueries.wrapNotGroups('NOT (2 AND 3)'));
    }

    @isTest
    static void testWrapNotGroups_noNotPassesThroughUnchanged() {
        System.assertEquals('1 AND (2 OR 3)', IPS_QualityBuilderReportQueries.wrapNotGroups('1 AND (2 OR 3)'));
    }

    @isTest
    static void testWrapNotGroups_notFollowedByNeitherGroupNorNumber_passesThrough() {
        System.assertEquals('NOT AND', IPS_QualityBuilderReportQueries.wrapNotGroups('NOT AND'));
    }

    @isTest
    static void testWrapNotGroups_malformedParensPassesThroughWithoutThrowing() {
        String result = IPS_QualityBuilderReportQueries.wrapNotGroups('NOT (2 AND 3');
        System.assertEquals(true, result.contains('NOT'));
    }

    @isTest
    static void testCharacterClassifiers() {
        System.assertEquals(true, IPS_QualityBuilderReportQueries.isWordChar('A'));
        System.assertEquals(false, IPS_QualityBuilderReportQueries.isWordChar(' '));
        System.assertEquals(true, IPS_QualityBuilderReportQueries.isWhitespace(' '));
        System.assertEquals(false, IPS_QualityBuilderReportQueries.isWhitespace('A'));
        System.assertEquals(true, IPS_QualityBuilderReportQueries.isDigit('7'));
        System.assertEquals(false, IPS_QualityBuilderReportQueries.isDigit('A'));
    }

    @isTest
    static void testBuildCondition_likeAndNotLike() {
        System.assertEquals('Subject LIKE \'%urgent%\'',
            IPS_QualityBuilderReportQueries.buildCondition('Subject', 'LIKE', 'urgent', 'Case'));
        System.assertEquals('(NOT (Subject LIKE \'%urgent%\'))',
            IPS_QualityBuilderReportQueries.buildCondition('Subject', 'NOT LIKE', 'urgent', 'Case'));
    }

    @isTest
    static void testBuildCondition_inAndNotInForMultiValue() {
        System.assertEquals('Status IN (\'Open\', \'Escalated\')',
            IPS_QualityBuilderReportQueries.buildCondition('Status', '=', 'Open,Escalated', 'Case'));
        System.assertEquals('Status NOT IN (\'Open\', \'Escalated\')',
            IPS_QualityBuilderReportQueries.buildCondition('Status', '!=', 'Open,Escalated', 'Case'));
    }

    @isTest
    static void testBuildCondition_singleEqualsIsNotTreatedAsInList() {
        System.assertEquals('Status = \'Open\'',
            IPS_QualityBuilderReportQueries.buildCondition('Status', '=', 'Open', 'Case'));
    }

    @isTest
    static void testBuildCondition_booleanField() {
        System.assertEquals('IsClosed = true',
            IPS_QualityBuilderReportQueries.buildCondition('IsClosed', '=', 'true', 'Case'));
        System.assertEquals('IsClosed = false',
            IPS_QualityBuilderReportQueries.buildCondition('IsClosed', '=', 'false', 'Case'));
    }

    @isTest
    static void testBuildCondition_numericValueUnquoted() {
        System.assertEquals('Amount > 1000',
            IPS_QualityBuilderReportQueries.buildCondition('Amount', '>', '1000', 'Opportunity'));
    }

    @isTest
    static void testBuildCondition_dateLiteralUnquoted() {
        System.assertEquals('CreatedDate = TODAY',
            IPS_QualityBuilderReportQueries.buildCondition('CreatedDate', '=', 'TODAY', 'Case'));
    }

    @isTest
    static void testBuildCondition_relativeDurationPhraseConverted() {
        System.assertEquals('CreatedDate = N_MONTHS_AGO:3',
            IPS_QualityBuilderReportQueries.buildCondition('CreatedDate', '=', '3 months ago', 'Case'));
    }

    @isTest
    static void testBuildCondition_plainStringLiteralEscaped() {
        String rawValue = 'O\'Brien';
        String expected = 'Subject = \'' + String.escapeSingleQuotes(rawValue) + '\'';
        System.assertEquals(expected,
            IPS_QualityBuilderReportQueries.buildCondition('Subject', '=', rawValue, 'Case'));
    }

    @isTest
    static void testParseMultiValueList_basIPSplit() {
        List<String> tokens = IPS_QualityBuilderReportQueries.parseMultiValueList('Open,Escalated,Closed');
        System.assertEquals(new List<String>{ 'Open', 'Escalated', 'Closed' }, tokens);
    }

    @isTest
    static void testParseMultiValueList_respectsQuotedCommas() {
        List<String> tokens = IPS_QualityBuilderReportQueries.parseMultiValueList('"Smith, John",Doe');
        System.assertEquals(new List<String>{ 'Smith, John', 'Doe' }, tokens);
    }

    @isTest
    static void testParseMultiValueList_blankReturnsEmptyList() {
        System.assertEquals(0, IPS_QualityBuilderReportQueries.parseMultiValueList(null).size());
        System.assertEquals(0, IPS_QualityBuilderReportQueries.parseMultiValueList('').size());
    }

    @isTest
    static void testIsNumericValue() {
        System.assertEquals(true, IPS_QualityBuilderReportQueries.isNumericValue('1000'));
        System.assertEquals(true, IPS_QualityBuilderReportQueries.isNumericValue('-42.5'));
        System.assertEquals(false, IPS_QualityBuilderReportQueries.isNumericValue('Open'));
        System.assertEquals(false, IPS_QualityBuilderReportQueries.isNumericValue(null));
    }

    @isTest
    static void testIsDateLiteral() {
        System.assertEquals(true, IPS_QualityBuilderReportQueries.isDateLiteral('TODAY'));
        System.assertEquals(true, IPS_QualityBuilderReportQueries.isDateLiteral('LAST_N_DAYS:5'));
        System.assertEquals(false, IPS_QualityBuilderReportQueries.isDateLiteral('Open'));
        System.assertEquals(false, IPS_QualityBuilderReportQueries.isDateLiteral(null));
    }

    @isTest
    static void testConvertRelativeDurationToSoqlLiteral() {
        System.assertEquals('N_DAYS_AGO:1', IPS_QualityBuilderReportQueries.convertRelativeDurationToSoqlLiteral('1 day ago'));
        System.assertEquals('N_WEEKS_AGO:2', IPS_QualityBuilderReportQueries.convertRelativeDurationToSoqlLiteral('2 weeks ago'));
        System.assertEquals('N_MONTHS_AGO:3', IPS_QualityBuilderReportQueries.convertRelativeDurationToSoqlLiteral('3 months ago'));
        System.assertEquals('N_QUARTERS_AGO:1', IPS_QualityBuilderReportQueries.convertRelativeDurationToSoqlLiteral('1 quarter ago'));
        System.assertEquals('N_YEARS_AGO:5', IPS_QualityBuilderReportQueries.convertRelativeDurationToSoqlLiteral('5 years ago'));
        System.assertEquals(null, IPS_QualityBuilderReportQueries.convertRelativeDurationToSoqlLiteral('yesterday'));
        System.assertEquals(null, IPS_QualityBuilderReportQueries.convertRelativeDurationToSoqlLiteral(null));
    }

    @isTest
    static void testGetFieldDisplayType() {
        System.assertEquals(Schema.DisplayType.BOOLEAN,
            IPS_QualityBuilderReportQueries.getFieldDisplayType('IsClosed', 'Case'));
        System.assertEquals(Schema.DisplayType.PICKLIST,
            IPS_QualityBuilderReportQueries.getFieldDisplayType('Case.Status', 'Case'));
        System.assertEquals(Schema.DisplayType.STRING,
            IPS_QualityBuilderReportQueries.getFieldDisplayType('Account.Name', 'Account')); 
        System.assertEquals(null,
            IPS_QualityBuilderReportQueries.getFieldDisplayType('Account.Name', 'Case')); 
        System.assertEquals(null,
            IPS_QualityBuilderReportQueries.getFieldDisplayType('NotARealField__c', 'Case'));
        System.assertEquals(null,
            IPS_QualityBuilderReportQueries.getFieldDisplayType('Status', 'Not_A_Real_Object__x'));
        System.assertEquals(null,
            IPS_QualityBuilderReportQueries.getFieldDisplayType(null, 'Case'));
    }

    //Counts how many entries in the list exactly match the target value.
    private static Integer countOccurrences(List<String> values, String target) {
        Integer occurrences = 0;
        for (String v : values) {
            if (v == target) occurrences++;
        }
        return occurrences;
    }

    private static Map<String, Object> buildSampleDescribeResult() {
        String jsonData =
            '{'
            + '  "reportMetadata": {'
            + '    "detailColumns": ["Case.CaseNumber", "Case.Account.Name", "Case.Status", "Case.Owner.Name"],'
            + '    "reportFilters": ['
            + '      { "column": "Case.Status", "operator": "equals", "value": "Open,Escalated" },'
            + '      { "column": "Case.CaseNumber", "operator": "contains", "value": "00001" }'
            + '    ],'
            + '    "reportBooleanFilter": null'
            + '  },'
            + '  "reportExtendedMetadata": {'
            + '    "detailColumnInfo": {'
            + '      "Case.CaseNumber":  { "label": "Case Number" },'
            + '      "Case.Account.Name": { "label": "Account Name" },'
            + '      "Case.Status":       { "label": "Status" },'
            + '      "Case.Owner.Name":   { "label": "Case Owner" }'
            + '    }'
            + '  }'
            + '}';

        return (Map<String, Object>) JSON.deserializeUntyped(jsonData);
    }
}