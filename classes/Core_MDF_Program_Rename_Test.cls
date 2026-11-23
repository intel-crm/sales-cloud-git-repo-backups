/**
 * @description Tests the generic program rename actions with mocked Tooling API responses.
 */
@IsTest
private class Core_MDF_Program_Rename_Test {
  private static final String RECORD_TYPE_ID = '012000000000001AAA';
  private static final String VALIDATION_RULE_ID = '03d000000000001AAA';
  private static final String SCOPE_JSON =
    '{"programNames":["Client","Client Co-Marketing Fund Boost","Datacenter"],' +
    '"entries":[' +
    '{"metadataType":"RecordType","fullName":"Campaign.Core_MDF_DC","programName":"Datacenter",' +
    '"elementPath":"/CustomObject/recordTypes/label","exactLiteral":"Yes","contextKind":"Code/Configuration"},' +
    '{"metadataType":"RecordType","fullName":"Campaign.Core_MDF_DC","programName":"Datacenter",' +
    '"elementPath":"/CustomObject/recordTypes/description","exactLiteral":"No","contextKind":"Description/Help text"},' +
    '{"metadataType":"ValidationRule","fullName":"Account.Core_MDF_DC_Rule","programName":"Datacenter",' +
    '"elementPath":"/CustomObject/validationRules/errorConditionFormula","exactLiteral":"Yes","contextKind":"Code/Configuration"},' +
    '{"metadataType":"ValidationRule","fullName":"Account.Core_MDF_DC_Rule","programName":"Datacenter",' +
    '"elementPath":"/CustomObject/validationRules/description","exactLiteral":"No","contextKind":"Description/Help text"}' +
    ',{"metadataType":"ValidationRule","fullName":"Account.Core_MDF_DC_Rule","programName":"Datacenter",' +
    '"elementPath":"/CustomObject/validationRules/errorMessage","exactLiteral":"No","contextKind":"Code/Configuration"}' +
    ']}';

  private class ToolingMock implements HttpCalloutMock {
    Integer patchStatusCode;
    String lastPatchBody;
    Integer patchCount = 0;
    Boolean staleRecordType = false;
    Boolean alreadyRenamedRecordType = false;
    Boolean paginateRecordTypeQuery = false;
    Boolean failQuery = false;

    ToolingMock(Integer patchStatusCode) {
      this.patchStatusCode = patchStatusCode;
    }

    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      String endpoint = request.getEndpoint();
      response.setHeader('Content-Type', 'application/json');
      if (endpoint.contains('/query/') && failQuery) {
        response.setStatusCode(403);
        response.setBody(
          '[{"message":"Query access denied","errorCode":"INSUFFICIENT_ACCESS"}]'
        );
        return response;
      }
      if (request.getMethod() == 'PATCH') {
        patchCount++;
        lastPatchBody = request.getBody();
        response.setStatusCode(patchStatusCode);
        response.setBody(
          patchStatusCode >= 300
            ? '[{"message":"Insufficient access","errorCode":"INSUFFICIENT_ACCESS"}]'
            : ''
        );
        return response;
      }
      response.setStatusCode(200);
      if (endpoint.contains('/query/')) {
        if (paginateRecordTypeQuery && endpoint.contains('?q=')) {
          response.setBody(
            '{"done":false,"records":[],' +
            '"nextRecordsUrl":"/services/data/v67.0/tooling/query/next"}'
          );
          return response;
        }
        if (paginateRecordTypeQuery && endpoint.endsWith('/query/next')) {
          response.setBody(
            '{"done":true,"records":[{"Id":"' +
              RECORD_TYPE_ID +
              '","Name":"Datacenter"}]}'
          );
          return response;
        }
        if (endpoint.contains('ValidationRule')) {
          response.setBody(
            '{"done":true,"records":[{"Id":"' +
              VALIDATION_RULE_ID +
              '","ValidationName":"Core_MDF_DC_Rule",' +
              '"EntityDefinition":{"QualifiedApiName":"Account"}}]}'
          );
        } else {
          response.setBody(
            '{"done":true,"records":[' +
              '{"Id":"012000000000002AAA","Name":"datacenter"},' +
              '{"Id":"' +
              RECORD_TYPE_ID +
              '","Name":"Datacenter"}]}'
          );
        }
      } else if (endpoint.endsWith(RECORD_TYPE_ID)) {
        response.setBody(
          '{"FullName":"' +
            (staleRecordType ? 'Campaign.Stale' : 'Campaign.Core_MDF_DC') +
            '","Metadata":' +
            '{"label":"' +
            (alreadyRenamedRecordType ? 'Datacenter New' : 'Datacenter') +
            '","description":"' +
            (alreadyRenamedRecordType
              ? 'Program renamed'
              : 'Record Type for Datacenter Program, not Client Co-Marketing Fund Boost') +
            '",' +
            '"active":true,"picklistValues":[{"picklist":"Status","values":[{"valueName":"Planned","default":true}]}]}}'
        );
      } else if (endpoint.endsWith(VALIDATION_RULE_ID)) {
        Map<String, Object> validationRuleMetadata = new Map<String, Object>{
          'active' => true,
          'description' => 'Datacenter restriction',
          'errorMessage' => 'Only Datacenter is allowed.',
          'errorConditionFormula' => 'OR(ISPICKVAL(Program__c, \'Datacenter\'), ISPICKVAL(Program__c, \'Datacenter Plus\'))',
          'errorMessage' => 'Only Datacenter is allowed.'
        };
        response.setBody(
          JSON.serialize(
            new Map<String, Object>{
              'FullName' => 'Account.Core_MDF_DC_Rule',
              'Metadata' => validationRuleMetadata
            }
          )
        );
      } else {
        response.setStatusCode(404);
        response.setBody('[{"message":"Not found","errorCode":"NOT_FOUND"}]');
      }
      return response;
    }
  }

  private static Core_MDF_Program_Rename_ScanAction.Response scan(
    String metadataType,
    String oldName,
    String newName
  ) {
    Core_MDF_Program_Rename_ScanAction.Request request = new Core_MDF_Program_Rename_ScanAction.Request();
    request.metadataType = metadataType;
    request.oldName = oldName;
    request.newName = newName;
    return Core_MDF_Program_Rename_ScanAction.scan(
      new List<Core_MDF_Program_Rename_ScanAction.Request>{ request }
    )[0];
  }

  private static Core_MDF_Program_Rename_ApplyAction.Response apply(
    List<Core_MDF_Program_Rename_Item> selectedItems,
    String metadataType
  ) {
    Core_MDF_Program_Rename_Item item = selectedItems[0];
    item.metadataType = metadataType;
    Core_MDF_Program_Rename_ApplyAction.Request request = new Core_MDF_Program_Rename_ApplyAction.Request();
    request.selectedItems = selectedItems;
    request.oldName = 'Datacenter';
    request.newName = 'Datacenter New';
    return Core_MDF_Program_Rename_ApplyAction.apply(
      new List<Core_MDF_Program_Rename_ApplyAction.Request>{ request }
    )[0];
  }

  @IsTest
  static void scansOnlyInScopeRecordTypeAndProtectsLongerNames() {
    Core_MDF_Program_Rename_Service.scopeJsonOverride = SCOPE_JSON;
    Test.setMock(HttpCalloutMock.class, new ToolingMock(204));
    Test.startTest();
    Core_MDF_Program_Rename_ScanAction.Response result = scan(
      'RecordType',
      'Datacenter',
      'Datacenter New'
    );
    Test.stopTest();

    System.assertEquals(null, result.errorMessage);
    System.assertEquals(1, result.itemCount);
    System.assertEquals('Campaign.Core_MDF_DC', result.items[0].fullName);
    System.assertEquals(2, result.items[0].replacementCount);
    System.assert(result.items[0].proposedValue.contains('Datacenter New'));
    System.assert(
      result.items[0].proposedValue.contains('Client Co-Marketing Fund Boost')
    );
    System.assertEquals(2, result.occurrences.size());
    for (Core_MDF_Program_Rename_Occurrence occurrence : result.occurrences) {
      System.assertEquals('RecordType', occurrence.metadataType);
      System.assertEquals('Campaign.Core_MDF_DC', occurrence.fullName);
      System.assertEquals(1, occurrence.matchCount);
      System.assert(occurrence.currentValue.contains('Datacenter'));
      System.assert(occurrence.proposedValue.contains('Datacenter New'));
    }
  }

  @IsTest
  static void scansAndAppliesValidationRuleFormula() {
    Core_MDF_Program_Rename_Service.scopeJsonOverride = SCOPE_JSON;
    ToolingMock mock = new ToolingMock(204);
    Test.setMock(HttpCalloutMock.class, mock);
    Test.startTest();
    Core_MDF_Program_Rename_ScanAction.Response scanned = scan(
      'ValidationRule',
      'Datacenter',
      'Datacenter New'
    );
    System.assertEquals(
      null,
      scanned.errorMessage,
      'Validation rule scan should succeed.'
    );
    System.assertEquals(
      1,
      scanned.itemCount,
      'One in-scope validation rule should be returned.'
    );
    System.assertEquals(3, scanned.occurrences.size());
    Set<String> occurrencePaths = new Set<String>();
    for (Core_MDF_Program_Rename_Occurrence occurrence : scanned.occurrences) {
      occurrencePaths.add(occurrence.metadataPath);
      System.assertEquals(1, occurrence.matchCount);
    }
    System.assert(
      occurrencePaths.contains(
        '/CustomObject/validationRules/errorConditionFormula'
      )
    );
    System.assert(
      occurrencePaths.contains('/CustomObject/validationRules/description')
    );
    System.assert(
      occurrencePaths.contains('/CustomObject/validationRules/errorMessage')
    );
    Core_MDF_Program_Rename_ApplyAction.Response applied = apply(
      scanned.items,
      'ValidationRule'
    );
    Test.stopTest();

    System.assertEquals(1, scanned.itemCount);
    System.assertEquals(1, applied.updatedCount);
    System.assertEquals('Updated', applied.results[0].status);
    Map<String, Object> updateBody = (Map<String, Object>) JSON.deserializeUntyped(
      mock.lastPatchBody
    );
    Map<String, Object> metadata = (Map<String, Object>) updateBody.get(
      'Metadata'
    );
    System.assert(
      ((String) metadata.get('errorConditionFormula'))
        .contains('Datacenter New')
    );
    System.assert(
      ((String) metadata.get('errorConditionFormula'))
        .contains('Datacenter Plus')
    );
    System.assertEquals(
      'Datacenter New restriction',
      metadata.get('description')
    );
    System.assertEquals(
      'Only Datacenter New is allowed.',
      metadata.get('errorMessage')
    );
  }

  @IsTest
  static void rejectsUnsupportedMetadataTypesAndInvalidNames() {
    Core_MDF_Program_Rename_Service.scopeJsonOverride = SCOPE_JSON;
    Test.startTest();
    Core_MDF_Program_Rename_ScanAction.Response unsupported = scan(
      'ApprovalProcess',
      'Datacenter',
      'Datacenter New'
    );
    Core_MDF_Program_Rename_ScanAction.Response sameName = scan(
      'RecordType',
      'Datacenter',
      'Datacenter'
    );
    Core_MDF_Program_Rename_ScanAction.Response blankName = scan(
      'RecordType',
      '',
      'X'
    );
    Test.stopTest();

    System.assert(
      unsupported.errorMessage.contains('RecordType and ValidationRule only')
    );
    System.assert(sameName.errorMessage.contains('different'));
    System.assert(blankName.errorMessage.contains('required'));
  }

  @IsTest
  static void reportsApiFailuresAndSkipsOutOfScopeRows() {
    Core_MDF_Program_Rename_Service.scopeJsonOverride = SCOPE_JSON;
    ToolingMock mock = new ToolingMock(403);
    Test.setMock(HttpCalloutMock.class, mock);
    Core_MDF_Program_Rename_Item outOfScope = new Core_MDF_Program_Rename_Item();
    outOfScope.metadataType = 'RecordType';
    outOfScope.recordId = '012000000000002AAA';
    outOfScope.fullName = 'Campaign.NotInScope';
    Core_MDF_Program_Rename_Item selected = new Core_MDF_Program_Rename_Item();
    selected.metadataType = 'RecordType';
    selected.recordId = RECORD_TYPE_ID;
    selected.fullName = 'Campaign.Core_MDF_DC';

    Test.startTest();
    Core_MDF_Program_Rename_ApplyAction.Response outOfScopeResult = apply(
      new List<Core_MDF_Program_Rename_Item>{ outOfScope },
      'RecordType'
    );
    Core_MDF_Program_Rename_ApplyAction.Response failedResult = apply(
      new List<Core_MDF_Program_Rename_Item>{ selected },
      'RecordType'
    );
    Test.stopTest();

    System.assertEquals('Skipped', outOfScopeResult.results[0].status);
    System.assertEquals(1, failedResult.failedCount);
    System.assert(
      failedResult.results[0].message.contains('Insufficient access')
    );
  }

  @IsTest
  static void scansQueryPagesAndSkipsCaseInsensitiveButNonExactNames() {
    Core_MDF_Program_Rename_Service.scopeJsonOverride = SCOPE_JSON;
    ToolingMock mock = new ToolingMock(204);
    mock.paginateRecordTypeQuery = true;
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    Core_MDF_Program_Rename_ScanAction.Response result = scan(
      'RecordType',
      'Datacenter',
      'Datacenter New'
    );
    Test.stopTest();

    System.assertEquals(null, result.errorMessage);
    System.assertEquals(1, result.itemCount);
  }

  @IsTest
  static void applySkipsInvalidIdsAndStaleComponents() {
    Core_MDF_Program_Rename_Service.scopeJsonOverride = SCOPE_JSON;
    ToolingMock mock = new ToolingMock(204);
    mock.staleRecordType = true;
    Test.setMock(HttpCalloutMock.class, mock);

    Core_MDF_Program_Rename_Item invalidId = new Core_MDF_Program_Rename_Item();
    invalidId.metadataType = 'RecordType';
    invalidId.recordId = '001000000000001AAA';
    invalidId.fullName = 'Campaign.Core_MDF_DC';
    Core_MDF_Program_Rename_Item stale = new Core_MDF_Program_Rename_Item();
    stale.metadataType = 'RecordType';
    stale.recordId = RECORD_TYPE_ID;
    stale.fullName = 'Campaign.Core_MDF_DC';

    Test.startTest();
    Core_MDF_Program_Rename_ApplyAction.Response invalidResult = apply(
      new List<Core_MDF_Program_Rename_Item>{ invalidId },
      'RecordType'
    );
    Core_MDF_Program_Rename_ApplyAction.Response staleResult = apply(
      new List<Core_MDF_Program_Rename_Item>{ stale },
      'RecordType'
    );
    Test.stopTest();

    System.assertEquals('Skipped', invalidResult.results[0].status);
    System.assertEquals('Skipped', staleResult.results[0].status);
    System.assert(
      staleResult.results[0].message.contains('changed since the scan')
    );
  }

  @IsTest
  static void enforcesEmptyAndMaximumSelections() {
    Core_MDF_Program_Rename_Service.scopeJsonOverride = SCOPE_JSON;
    Core_MDF_Program_Rename_ApplyAction.Request emptyRequest = new Core_MDF_Program_Rename_ApplyAction.Request();
    emptyRequest.selectedItems = new List<Core_MDF_Program_Rename_Item>();
    emptyRequest.oldName = 'Datacenter';
    emptyRequest.newName = 'Datacenter New';
    Core_MDF_Program_Rename_ApplyAction.Request largeRequest = new Core_MDF_Program_Rename_ApplyAction.Request();
    largeRequest.selectedItems = new List<Core_MDF_Program_Rename_Item>();
    largeRequest.oldName = 'Datacenter';
    largeRequest.newName = 'Datacenter New';
    for (Integer index = 0; index < 46; index++) {
      largeRequest.selectedItems.add(new Core_MDF_Program_Rename_Item());
    }

    Test.startTest();
    List<Core_MDF_Program_Rename_ApplyAction.Response> responses = Core_MDF_Program_Rename_ApplyAction.apply(
      new List<Core_MDF_Program_Rename_ApplyAction.Request>{
        emptyRequest,
        largeRequest
      }
    );
    Test.stopTest();

    System.assertEquals(0, responses[0].results.size());
    System.assert(responses[1].errorMessage.contains('no more than 45'));
  }

  @IsTest
  static void reportsToolingQueryFailure() {
    Core_MDF_Program_Rename_Service.scopeJsonOverride = SCOPE_JSON;
    ToolingMock mock = new ToolingMock(204);
    mock.failQuery = true;
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    Core_MDF_Program_Rename_ScanAction.Response result = scan(
      'RecordType',
      'Datacenter',
      'Datacenter New'
    );
    Test.stopTest();

    System.assert(result.errorMessage.contains('Query access denied'));
  }

  @IsTest
  static void noWorkbookMatchesReturnAnEmptyScan() {
    Core_MDF_Program_Rename_Service.scopeJsonOverride = SCOPE_JSON;
    Test.startTest();
    Core_MDF_Program_Rename_ScanAction.Response result = scan(
      'RecordType',
      'No Matching Program',
      'New Name'
    );
    Test.stopTest();

    System.assertEquals(null, result.errorMessage);
    System.assertEquals(0, result.itemCount);
    System.assertEquals(0, result.occurrences.size());
  }

  @IsTest
  static void applySurfacesInvalidNamesAndMissingComponentIdentity() {
    Core_MDF_Program_Rename_Service.scopeJsonOverride = SCOPE_JSON;
    Core_MDF_Program_Rename_Item invalidNameItem = new Core_MDF_Program_Rename_Item();
    invalidNameItem.metadataType = 'RecordType';
    invalidNameItem.recordId = RECORD_TYPE_ID;
    invalidNameItem.fullName = 'Campaign.Core_MDF_DC';
    Core_MDF_Program_Rename_Item missingIdentity = new Core_MDF_Program_Rename_Item();
    missingIdentity.metadataType = 'RecordType';
    missingIdentity.fullName = 'Campaign.Core_MDF_DC';
    Core_MDF_Program_Rename_ApplyAction.Request invalidNameRequest = new Core_MDF_Program_Rename_ApplyAction.Request();
    invalidNameRequest.selectedItems = new List<Core_MDF_Program_Rename_Item>{
      invalidNameItem
    };
    invalidNameRequest.oldName = '';
    invalidNameRequest.newName = 'New Name';
    Core_MDF_Program_Rename_ApplyAction.Request missingIdentityRequest = new Core_MDF_Program_Rename_ApplyAction.Request();
    missingIdentityRequest.selectedItems = new List<Core_MDF_Program_Rename_Item>{
      missingIdentity
    };
    missingIdentityRequest.oldName = 'Datacenter';
    missingIdentityRequest.newName = 'Datacenter New';
    Test.setMock(HttpCalloutMock.class, new ToolingMock(204));

    Test.startTest();
    List<Core_MDF_Program_Rename_ApplyAction.Response> results = Core_MDF_Program_Rename_ApplyAction.apply(
      new List<Core_MDF_Program_Rename_ApplyAction.Request>{
        invalidNameRequest,
        missingIdentityRequest
      }
    );
    Test.stopTest();

    System.assertEquals('Failed', results[0].results[0].status);
    System.assertEquals('Skipped', results[1].results[0].status);
    System.assert(results[0].results[0].message.contains('required'));
  }

  @IsTest
  static void applySkipsWhenTheScopedValuesAreAlreadyRenamed() {
    Core_MDF_Program_Rename_Service.scopeJsonOverride = SCOPE_JSON;
    ToolingMock mock = new ToolingMock(204);
    mock.alreadyRenamedRecordType = true;
    Test.setMock(HttpCalloutMock.class, mock);
    Core_MDF_Program_Rename_Item selected = new Core_MDF_Program_Rename_Item();
    selected.metadataType = 'RecordType';
    selected.recordId = RECORD_TYPE_ID;
    selected.fullName = 'Campaign.Core_MDF_DC';

    Test.startTest();
    Core_MDF_Program_Rename_ApplyAction.Response result = apply(
      new List<Core_MDF_Program_Rename_Item>{ selected },
      'RecordType'
    );
    Test.stopTest();

    System.assertEquals('No change', result.results[0].status);
    System.assertEquals(0, mock.patchCount);
  }
}