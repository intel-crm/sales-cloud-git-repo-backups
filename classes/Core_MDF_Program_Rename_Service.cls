/**
 * @description Scans and renames only RecordType and ValidationRule metadata explicitly
 *              listed in the impact-workbook scope resource. All other metadata types fail
 *              closed and must be handled through the normal source-control release pipeline.
 */
public with sharing class Core_MDF_Program_Rename_Service {
  public static final String NAMED_CREDENTIAL = 'callout:Core_MDF_Metadata_API';
  public static final String TOOLING_ROOT = '/services/data/v67.0/tooling';
  public static final String SCOPE_RESOURCE = 'Core_MDF_Program_Rename_Scope';
  public static final Integer MAX_SELECTED_COMPONENTS = 45;

  private static final String RECORD_TYPE = 'RecordType';
  private static final String VALIDATION_RULE = 'ValidationRule';
  private static final String RECORD_TYPE_ID_PREFIX = '012';
  private static final String VALIDATION_RULE_ID_PREFIX = '03d';
  private static final Pattern RECORD_TYPE_ID_PATTERN = Pattern.compile(
    '^012[A-Za-z0-9]{12}([A-Za-z0-9]{3})?$'
  );
  private static final Pattern VALIDATION_RULE_ID_PATTERN = Pattern.compile(
    '^03d[A-Za-z0-9]{12}([A-Za-z0-9]{3})?$'
  );
  private static final Integer PREVIEW_VALUE_LIMIT = 500;
  private static final String WORD_CHARACTERS = 'A-Za-z0-9_';

  @TestVisible
  private static String scopeJsonOverride;
  private static String cachedScopeJson;

  public class RenameException extends Exception {
  }

  private class ScopeEntry {
    String metadataType;
    String fullName;
    String programName;
    String elementPath;
    String exactLiteral;
    String contextKind;
  }

  private class ChangePreview {
    String path;
    String beforeValue;
    String afterValue;
    Integer count;
  }

  public class ScanResult {
    public List<Core_MDF_Program_Rename_Item> items = new List<Core_MDF_Program_Rename_Item>();
    public List<Core_MDF_Program_Rename_Occurrence> occurrences = new List<Core_MDF_Program_Rename_Occurrence>();
  }

  /**
   * @description Validates the input names and supported metadata type.
   */
  public static String validateInput(
    String metadataType,
    String oldName,
    String newName
  ) {
    if (String.isBlank(oldName) || String.isBlank(newName)) {
      return 'Current and new program names are required.';
    }
    if (oldName.trim().equals(newName.trim())) {
      return 'The new program name must be different from the current name.';
    }
    if (!isSupportedType(metadataType)) {
      return 'This Flow supports RecordType and ValidationRule only. Handle other workbook metadata through the release pipeline.';
    }
    return null;
  }

  /**
   * @description Finds exact workbook-scoped metadata matches for one metadata type.
   */
  public static List<Core_MDF_Program_Rename_Item> scan(
    String metadataType,
    String oldName,
    String newName
  ) {
    return scanDetailed(metadataType, oldName, newName).items;
  }

  /**
   * @description Finds workbook-scoped matches and returns both component rows and path-level details.
   */
  public static ScanResult scanDetailed(
    String metadataType,
    String oldName,
    String newName
  ) {
    String validationMessage = validateInput(metadataType, oldName, newName);
    if (validationMessage != null) {
      throw new RenameException(validationMessage);
    }

    List<ScopeEntry> entries = readScope(metadataType, oldName.trim());
    Map<String, List<ScopeEntry>> entriesByFullName = groupScopeEntries(
      entries
    );
    ScanResult results = new ScanResult();
    if (entriesByFullName.isEmpty()) {
      return results;
    }

    if (RECORD_TYPE.equals(metadataType)) {
      scanRecordTypes(
        entriesByFullName,
        oldName.trim(),
        newName.trim(),
        results.items,
        results.occurrences
      );
    } else {
      scanValidationRules(
        entriesByFullName,
        oldName.trim(),
        newName.trim(),
        results.items,
        results.occurrences
      );
    }
    return results;
  }

  /**
   * @description Re-reads each selected component, confirms its workbook scope and updates
   *              only approved metadata values. Each selected component is handled separately,
   *              so a failure does not hide the results for the remaining components.
   */
  public static List<Core_MDF_Program_Rename_Item> apply(
    List<Core_MDF_Program_Rename_Item> selectedItems,
    String oldName,
    String newName
  ) {
    List<Core_MDF_Program_Rename_Item> results = new List<Core_MDF_Program_Rename_Item>();
    if (selectedItems == null || selectedItems.isEmpty()) {
      return results;
    }
    if (selectedItems.size() > MAX_SELECTED_COMPONENTS) {
      throw new RenameException(
        'Select no more than ' +
          MAX_SELECTED_COMPONENTS +
          ' components per apply step.'
      );
    }

    for (Core_MDF_Program_Rename_Item selected : selectedItems) {
      Core_MDF_Program_Rename_Item result = selected;
      try {
        String validationMessage = validateInput(
          selected.metadataType,
          oldName,
          newName
        );
        if (validationMessage != null) {
          results.add(markResult(result, 'Failed', validationMessage));
          continue;
        }
        results.add(applyOne(selected, oldName.trim(), newName.trim()));
      } catch (Exception error) {
        results.add(markResult(result, 'Failed', error.getMessage()));
      }
    }
    return results;
  }

  private static Core_MDF_Program_Rename_Item applyOne(
    Core_MDF_Program_Rename_Item selected,
    String oldName,
    String newName
  ) {
    if (
      String.isBlank(selected.recordId) || String.isBlank(selected.fullName)
    ) {
      return markResult(
        selected,
        'Skipped',
        'The selected row is missing its component identity.'
      );
    }

    String expectedPrefix = RECORD_TYPE.equals(selected.metadataType)
      ? RECORD_TYPE_ID_PREFIX
      : VALIDATION_RULE_ID_PREFIX;
    Pattern expectedIdPattern = RECORD_TYPE.equals(selected.metadataType)
      ? RECORD_TYPE_ID_PATTERN
      : VALIDATION_RULE_ID_PATTERN;
    if (
      !selected.recordId.startsWith(expectedPrefix) ||
      !expectedIdPattern.matcher(selected.recordId).matches()
    ) {
      return markResult(
        selected,
        'Skipped',
        'The selected row has an invalid component Id.'
      );
    }

    List<ScopeEntry> entries = readScope(selected.metadataType, oldName);
    Map<String, List<ScopeEntry>> entriesByFullName = groupScopeEntries(
      entries
    );
    if (!entriesByFullName.containsKey(selected.fullName)) {
      return markResult(
        selected,
        'Skipped',
        'This component is not listed in the workbook scope.'
      );
    }

    Map<String, Object> component = readComponent(
      selected.metadataType,
      selected.recordId
    );
    if (!selected.fullName.equals((String) component.get('FullName'))) {
      return markResult(
        selected,
        'Skipped',
        'The component changed since the scan. Run the scan again.'
      );
    }

    Map<String, Object> metadata = metadataFor(component);
    List<ChangePreview> changes = findChanges(
      selected.metadataType,
      metadata,
      entriesByFullName.get(selected.fullName),
      oldName,
      newName,
      knownProgramNames()
    );
    if (changes.isEmpty()) {
      return markResult(
        selected,
        'No change',
        'No current workbook-scoped exact match remains.'
      );
    }

    applyChangesToMetadata(selected.metadataType, metadata, changes);
    Map<String, Object> updateBody = new Map<String, Object>{
      'Metadata' => metadata
    };
    send(
      'PATCH',
      TOOLING_ROOT +
        '/sobjects/' +
        selected.metadataType +
        '/' +
        selected.recordId,
      JSON.serialize(updateBody)
    );
    Core_MDF_Program_Rename_Item updated = buildItem(
      selected.metadataType,
      selected.recordId,
      selected.fullName,
      metadata,
      changes,
      'Updated',
      null
    );
    return updated;
  }

  private static void scanRecordTypes(
    Map<String, List<ScopeEntry>> entriesByFullName,
    String oldName,
    String newName,
    List<Core_MDF_Program_Rename_Item> results,
    List<Core_MDF_Program_Rename_Occurrence> occurrences
  ) {
    String queryText =
      'SELECT Id, Name FROM RecordType WHERE Name = \'' +
      String.escapeSingleQuotes(oldName) +
      '\'';
    for (Map<String, Object> row : queryTooling(queryText)) {
      if (!oldName.equals((String) row.get('Name'))) {
        continue;
      }
      String recordId = (String) row.get('Id');
      Map<String, Object> component = readComponent(RECORD_TYPE, recordId);
      String fullName = (String) component.get('FullName');
      if (!entriesByFullName.containsKey(fullName)) {
        continue;
      }
      Map<String, Object> metadata = metadataFor(component);
      List<ChangePreview> changes = findChanges(
        RECORD_TYPE,
        metadata,
        entriesByFullName.get(fullName),
        oldName,
        newName,
        knownProgramNames()
      );
      if (!changes.isEmpty()) {
        results.add(
          buildItem(
            RECORD_TYPE,
            recordId,
            fullName,
            metadata,
            changes,
            'Pending',
            null
          )
        );
        occurrences.addAll(
          buildOccurrences(
            RECORD_TYPE,
            recordId,
            fullName,
            changes,
            oldName,
            newName
          )
        );
      }
    }
  }

  private static void scanValidationRules(
    Map<String, List<ScopeEntry>> entriesByFullName,
    String oldName,
    String newName,
    List<Core_MDF_Program_Rename_Item> results,
    List<Core_MDF_Program_Rename_Occurrence> occurrences
  ) {
    Map<String, Set<String>> ruleNamesByObject = new Map<String, Set<String>>();
    for (String fullName : entriesByFullName.keySet()) {
      Integer separator = fullName.indexOf('.');
      if (separator <= 0 || separator == fullName.length() - 1) {
        continue;
      }
      String objectName = fullName.substring(0, separator);
      String ruleName = fullName.substring(separator + 1);
      if (!ruleNamesByObject.containsKey(objectName)) {
        ruleNamesByObject.put(objectName, new Set<String>());
      }
      ruleNamesByObject.get(objectName).add(ruleName);
    }

    for (String objectName : ruleNamesByObject.keySet()) {
      Set<String> ruleNames = ruleNamesByObject.get(objectName);
      List<String> quotedNames = new List<String>();
      for (String ruleName : ruleNames) {
        quotedNames.add('\'' + String.escapeSingleQuotes(ruleName) + '\'');
      }
      String queryText =
        'SELECT Id, ValidationName, EntityDefinition.QualifiedApiName ' +
        'FROM ValidationRule ' +
        'WHERE EntityDefinition.QualifiedApiName = \'' +
        String.escapeSingleQuotes(objectName) +
        '\' ' +
        'AND ValidationName IN (' +
        String.join(quotedNames, ',') +
        ')';

      for (Map<String, Object> row : queryTooling(queryText)) {
        String returnedObject = (String) ((Map<String, Object>) row.get(
            'EntityDefinition'
          ))
          .get('QualifiedApiName');
        String fullName =
          returnedObject +
          '.' +
          (String) row.get('ValidationName');
        if (!entriesByFullName.containsKey(fullName)) {
          continue;
        }
        String recordId = (String) row.get('Id');
        Map<String, Object> component = readComponent(
          VALIDATION_RULE,
          recordId
        );
        if (!fullName.equals((String) component.get('FullName'))) {
          continue;
        }
        Map<String, Object> metadata = metadataFor(component);
        List<ChangePreview> changes = findChanges(
          VALIDATION_RULE,
          metadata,
          entriesByFullName.get(fullName),
          oldName,
          newName,
          knownProgramNames()
        );
        if (!changes.isEmpty()) {
          results.add(
            buildItem(
              VALIDATION_RULE,
              recordId,
              fullName,
              metadata,
              changes,
              'Pending',
              null
            )
          );
          occurrences.addAll(
            buildOccurrences(
              VALIDATION_RULE,
              recordId,
              fullName,
              changes,
              oldName,
              newName
            )
          );
        }
      }
    }
  }

  private static List<ChangePreview> findChanges(
    String metadataType,
    Map<String, Object> metadata,
    List<ScopeEntry> scopeEntries,
    String oldName,
    String newName,
    Set<String> programNames
  ) {
    Map<String, ChangePreview> changesByPath = new Map<String, ChangePreview>();
    for (ScopeEntry entry : scopeEntries) {
      String fieldName = fieldNameForPath(metadataType, entry.elementPath);
      if (fieldName == null || !metadata.containsKey(fieldName)) {
        continue;
      }
      String currentValue = (String) metadata.get(fieldName);
      if (currentValue == null) {
        continue;
      }
      Integer replacementCount = 0;
      String proposedValue;
      if (RECORD_TYPE.equals(metadataType) && fieldName == 'label') {
        proposedValue = currentValue.equals(oldName) ? newName : currentValue;
        replacementCount = currentValue.equals(oldName) ? 1 : 0;
      } else if (fieldName == 'errorConditionFormula') {
        if (!'Yes'.equals(entry.exactLiteral)) {
          continue;
        }
        List<Object> replacement = replaceQuotedFormulaLiteral(
          currentValue,
          oldName,
          newName
        );
        proposedValue = (String) replacement[0];
        replacementCount = (Integer) replacement[1];
      } else {
        proposedValue = replaceWholePhrase(
          currentValue,
          oldName,
          newName,
          programNames
        );
        replacementCount = countPhraseMatches(
          currentValue,
          oldName,
          programNames
        );
      }
      if (replacementCount == 0) {
        continue;
      }
      ChangePreview preview = changesByPath.get(entry.elementPath);
      if (preview == null) {
        preview = new ChangePreview();
        preview.path = entry.elementPath;
        preview.beforeValue = currentValue;
        preview.afterValue = proposedValue;
        preview.count = replacementCount;
        changesByPath.put(entry.elementPath, preview);
      } else if (preview.afterValue != proposedValue) {
        throw new RenameException(
          'Conflicting workbook instructions for ' +
            entry.fullName +
            ' at ' +
            entry.elementPath +
            '.'
        );
      }
    }
    return changesByPath.values();
  }

  private static void applyChangesToMetadata(
    String metadataType,
    Map<String, Object> metadata,
    List<ChangePreview> changes
  ) {
    for (ChangePreview change : changes) {
      String fieldName = fieldNameForPath(metadataType, change.path);
      if (fieldName != null) {
        metadata.put(fieldName, change.afterValue);
      }
    }
  }

  private static String fieldNameForPath(
    String metadataType,
    String elementPath
  ) {
    if (RECORD_TYPE.equals(metadataType)) {
      if (elementPath.endsWith('/recordTypes/label')) {
        return 'label';
      }
      if (elementPath.endsWith('/recordTypes/description')) {
        return 'description';
      }
    } else if (VALIDATION_RULE.equals(metadataType)) {
      if (elementPath.endsWith('/validationRules/errorConditionFormula')) {
        return 'errorConditionFormula';
      }
      if (elementPath.endsWith('/validationRules/description')) {
        return 'description';
      }
      if (elementPath.endsWith('/validationRules/errorMessage')) {
        return 'errorMessage';
      }
    }
    return null;
  }

  private static Core_MDF_Program_Rename_Item buildItem(
    String metadataType,
    String recordId,
    String fullName,
    Map<String, Object> metadata,
    List<ChangePreview> changes,
    String status,
    String message
  ) {
    Core_MDF_Program_Rename_Item item = new Core_MDF_Program_Rename_Item();
    item.metadataType = metadataType;
    item.recordId = recordId;
    item.fullName = fullName;
    Integer separator = fullName == null ? -1 : fullName.indexOf('.');
    item.objectName = separator > 0 ? fullName.substring(0, separator) : null;
    item.replacementCount = 0;
    List<String> beforeLines = new List<String>();
    List<String> afterLines = new List<String>();
    for (ChangePreview change : changes) {
      item.replacementCount += change.count;
      beforeLines.add(change.path + ': ' + previewValue(change.beforeValue));
      afterLines.add(change.path + ': ' + previewValue(change.afterValue));
    }
    item.currentValue = String.join(beforeLines, '\n');
    item.proposedValue = String.join(afterLines, '\n');
    item.status = status;
    item.message = message;
    return item;
  }

  private static List<Core_MDF_Program_Rename_Occurrence> buildOccurrences(
    String metadataType,
    String recordId,
    String fullName,
    List<ChangePreview> changes,
    String oldName,
    String newName
  ) {
    List<Core_MDF_Program_Rename_Occurrence> results = new List<Core_MDF_Program_Rename_Occurrence>();
    Integer separator = fullName == null ? -1 : fullName.indexOf('.');
    String objectName = separator > 0 ? fullName.substring(0, separator) : null;
    for (ChangePreview change : changes) {
      Core_MDF_Program_Rename_Occurrence occurrence = new Core_MDF_Program_Rename_Occurrence();
      occurrence.occurrenceId = recordId + '|' + change.path;
      occurrence.metadataType = metadataType;
      occurrence.recordId = recordId;
      occurrence.fullName = fullName;
      occurrence.objectName = objectName;
      occurrence.metadataPath = change.path;
      occurrence.matchCount = change.count;
      occurrence.oldProgramName = oldName;
      occurrence.newProgramName = newName;
      occurrence.currentValue = previewValue(change.beforeValue);
      occurrence.proposedValue = previewValue(change.afterValue);
      results.add(occurrence);
    }
    return results;
  }

  private static String previewValue(String value) {
    if (value == null || value.length() <= PREVIEW_VALUE_LIMIT) {
      return value;
    }
    return value.substring(0, PREVIEW_VALUE_LIMIT) + ' … [truncated]';
  }

  private static Core_MDF_Program_Rename_Item markResult(
    Core_MDF_Program_Rename_Item item,
    String status,
    String message
  ) {
    item.status = status;
    item.message = message;
    return item;
  }

  private static Map<String, List<ScopeEntry>> groupScopeEntries(
    List<ScopeEntry> entries
  ) {
    Map<String, List<ScopeEntry>> grouped = new Map<String, List<ScopeEntry>>();
    for (ScopeEntry entry : entries) {
      if (!grouped.containsKey(entry.fullName)) {
        grouped.put(entry.fullName, new List<ScopeEntry>());
      }
      grouped.get(entry.fullName).add(entry);
    }
    return grouped;
  }

  private static List<ScopeEntry> readScope(
    String metadataType,
    String oldName
  ) {
    String scopeJson = scopeContent();
    Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(
      scopeJson
    );
    List<ScopeEntry> results = new List<ScopeEntry>();
    for (Object rawEntry : (List<Object>) root.get('entries')) {
      Map<String, Object> entryMap = (Map<String, Object>) rawEntry;
      if (
        !metadataType.equals((String) entryMap.get('metadataType')) ||
        !oldName.equals((String) entryMap.get('programName'))
      ) {
        continue;
      }
      ScopeEntry entry = new ScopeEntry();
      entry.metadataType = (String) entryMap.get('metadataType');
      entry.fullName = (String) entryMap.get('fullName');
      entry.programName = (String) entryMap.get('programName');
      entry.elementPath = (String) entryMap.get('elementPath');
      entry.exactLiteral = (String) entryMap.get('exactLiteral');
      entry.contextKind = (String) entryMap.get('contextKind');
      if (
        String.isNotBlank(entry.fullName) &&
        String.isNotBlank(entry.elementPath)
      ) {
        results.add(entry);
      }
    }
    return results;
  }

  private static Set<String> knownProgramNames() {
    String scopeJson = scopeContent();
    Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(
      scopeJson
    );
    Set<String> programNames = new Set<String>();
    for (Object name : (List<Object>) root.get('programNames')) {
      if (name != null) {
        programNames.add((String) name);
      }
    }
    return programNames;
  }

  private static String scopeContent() {
    if (scopeJsonOverride != null) {
      return scopeJsonOverride;
    }
    if (cachedScopeJson != null) {
      return cachedScopeJson;
    }
    List<StaticResource> resources = [
      SELECT Body
      FROM StaticResource
      WHERE Name = :SCOPE_RESOURCE
      LIMIT 1
    ];
    if (resources.isEmpty()) {
      throw new RenameException(
        'Required workbook scope resource ' + SCOPE_RESOURCE + ' is missing.'
      );
    }
    cachedScopeJson = resources[0].Body.toString();
    return cachedScopeJson;
  }

  private static Map<String, Object> readComponent(
    String metadataType,
    String recordId
  ) {
    HttpResponse response = send(
      'GET',
      TOOLING_ROOT + '/sobjects/' + metadataType + '/' + recordId,
      null
    );
    Map<String, Object> component = (Map<String, Object>) JSON.deserializeUntyped(
      response.getBody()
    );
    if (component.get('Metadata') == null) {
      throw new RenameException(
        'Tooling API did not return Metadata for ' +
          metadataType +
          ' ' +
          recordId +
          '.'
      );
    }
    return component;
  }

  private static Map<String, Object> metadataFor(
    Map<String, Object> component
  ) {
    return (Map<String, Object>) component.get('Metadata');
  }

  private static List<Map<String, Object>> queryTooling(String soql) {
    List<Map<String, Object>> records = new List<Map<String, Object>>();
    String nextPath =
      TOOLING_ROOT +
      '/query/?q=' +
      EncodingUtil.urlEncode(soql, 'UTF-8');
    Integer pageCount = 0;
    while (String.isNotBlank(nextPath)) {
      pageCount++;
      if (pageCount > 10) {
        throw new RenameException(
          'Tooling API query exceeded 10 pages. Narrow the program-name scope.'
        );
      }
      Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
        send('GET', nextPath, null).getBody()
      );
      for (Object record : (List<Object>) response.get('records')) {
        records.add((Map<String, Object>) record);
      }
      nextPath = response.get('done') == true
        ? null
        : (String) response.get('nextRecordsUrl');
    }
    return records;
  }

  private static HttpResponse send(String method, String path, String body) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(NAMED_CREDENTIAL + path);
    request.setMethod(method);
    request.setTimeout(120000);
    request.setHeader('Accept', 'application/json');
    request.setHeader('Content-Type', 'application/json');
    if (body != null) {
      request.setBody(body);
    }
    HttpResponse response = new Http().send(request);
    if (response.getStatusCode() >= 300) {
      throw new RenameException(
        'Tooling API ' +
          response.getStatusCode() +
          ': ' +
          extractError(response.getBody())
      );
    }
    return response;
  }

  private static String extractError(String responseBody) {
    if (String.isBlank(responseBody)) {
      return 'The API returned no error details.';
    }
    try {
      Object parsed = JSON.deserializeUntyped(responseBody);
      if (parsed instanceof List<Object>) {
        List<Object> errors = (List<Object>) parsed;
        if (!errors.isEmpty()) {
          return (String) ((Map<String, Object>) errors[0]).get('message');
        }
      } else if (parsed instanceof Map<String, Object>) {
        return (String) ((Map<String, Object>) parsed).get('message');
      }
    } catch (Exception ignoredParseError) {
      return responseBody.left(500);
    }
    return responseBody.left(500);
  }

  private static Boolean isSupportedType(String metadataType) {
    return RECORD_TYPE.equals(metadataType) ||
      VALIDATION_RULE.equals(metadataType);
  }

  @TestVisible
  private static String replaceWholePhrase(
    String text,
    String oldName,
    String newName,
    Set<String> programNames
  ) {
    List<List<Integer>> protectedSpans = new List<List<Integer>>();
    for (String programName : programNames) {
      if (
        programName.length() <= oldName.length() ||
        !programName.contains(oldName)
      ) {
        continue;
      }
      Matcher longerMatcher = Pattern.compile(Pattern.quote(programName))
        .matcher(text);
      while (longerMatcher.find()) {
        protectedSpans.add(
          new List<Integer>{ longerMatcher.start(), longerMatcher.end() }
        );
      }
    }

    Pattern namePattern = Pattern.compile(
      '(?<![' +
        WORD_CHARACTERS +
        '])' +
        Pattern.quote(oldName) +
        '(?![' +
        WORD_CHARACTERS +
        '])'
    );
    Matcher nameMatcher = namePattern.matcher(text);
    String result = '';
    Integer lastEnd = 0;
    while (nameMatcher.find()) {
      if (
        isInsideProtectedSpan(
          nameMatcher.start(),
          nameMatcher.end(),
          protectedSpans
        )
      ) {
        continue;
      }
      result += text.substring(lastEnd, nameMatcher.start()) + newName;
      lastEnd = nameMatcher.end();
    }
    return result + text.substring(lastEnd);
  }

  private static Integer countPhraseMatches(
    String text,
    String oldName,
    Set<String> programNames
  ) {
    String changed = replaceWholePhrase(
      text,
      oldName,
      '__PROGRAM_RENAME_SENTINEL__',
      programNames
    );
    return changed.equals(text)
      ? 0
      : changed.countMatches('__PROGRAM_RENAME_SENTINEL__');
  }

  private static Boolean isInsideProtectedSpan(
    Integer startIndex,
    Integer endIndex,
    List<List<Integer>> spans
  ) {
    for (List<Integer> span : spans) {
      if (span[0] <= startIndex && endIndex <= span[1]) {
        return true;
      }
    }
    return false;
  }

  private static List<Object> replaceQuotedFormulaLiteral(
    String formula,
    String oldName,
    String newName
  ) {
    Pattern literalPattern = Pattern.compile(
      '(\\x27' +
        Pattern.quote(oldName) +
        '\\x27|"' +
        Pattern.quote(oldName) +
        '")'
    );
    Matcher matcher = literalPattern.matcher(formula);
    Integer count = 0;
    String result = '';
    Integer lastEnd = 0;
    while (matcher.find()) {
      result += formula.substring(lastEnd, matcher.start());
      String matchedLiteral = matcher.group(0);
      String quoteCharacter = matchedLiteral.substring(0, 1);
      result += quoteCharacter + newName + quoteCharacter;
      lastEnd = matcher.end();
      count++;
    }
    result += formula.substring(lastEnd);
    return new List<Object>{ result, count };
  }
}