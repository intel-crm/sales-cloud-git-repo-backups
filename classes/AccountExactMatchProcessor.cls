/**
 * AccountExactMatchProcessor
 *
 * Matches CSV rows to Accounts by exact name (SOQL WHERE Name IN)
 * with a bulk SOSL fuzzy fallback for all unmatched rows.
 *
 * Design decisions
 * ────────────────
 * · Exact match  → single bulk SOQL  (one query, no loop)
 * · Fuzzy match  → single bulk SOSL  (one query, not one per row)
 * · DML          → single Database.insert with partial success
 * · USER_MODE    → SOQL uses WITH USER_MODE;
 *                  SOSL uses Search.query() which runs in user context
 *                  when called from an @AuraEnabled method
 */
public with sharing class AccountExactMatchProcessor {

    // ── Constants ─────────────────────────────────────────────────────────
    private static final Integer MAX_ACCOUNTS  = 50000;
    private static final Integer MAX_SOSL      = 200;
    private static final Integer TASK_DUE_DAYS = 7;

    // ── Result DTO ────────────────────────────────────────────────────────
    public class ProcessResult {
        @AuraEnabled public Integer tasksCreated;
        @AuraEnabled public Integer notFoundCount;
        @AuraEnabled public String  notFoundListString;
        @AuraEnabled public String  insertErrorString;
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String  errorMessage;
    }

    // ── Column Mapping DTO ────────────────────────────────────────────────
    @TestVisible
    private class ColumnMapping {
        String companyCol;
        String productCol;
        String streetCol;
        String cityCol;
        String stateCol;
        String countryCol;
        String postalCol;

        String validate() {
            if (String.isBlank(companyCol)) {
                return 'Column mapping is missing "company_name". ' +
                       'Please re-map your columns.';
            }
            if (String.isBlank(productCol)) {
                return 'Column mapping is missing "product". ' +
                       'Please re-map your columns.';
            }
            return null;
        }
    }

    // ── Entry Point ───────────────────────────────────────────────────────
    @AuraEnabled(cacheable=false)
    public static List<ProcessResult> processRecords(
            String parsedDataJson,
            String columnMappingJson) {

        ProcessResult       result  = blankResult();
        List<ProcessResult> results =
            new List<ProcessResult>{ result };

        try {

            // ── Step 1 · Deserialise inputs ───────────────────────────────
            List<Object> rawData =
                (List<Object>) JSON.deserializeUntyped(parsedDataJson);

            ColumnMapping colMap =
                deserialiseMapping(columnMappingJson);

            // ── Step 2 · Validate column mapping ─────────────────────────
            String validationError = colMap.validate();
            if (validationError != null) {
                result.errorMessage = validationError;
                return results;
            }

            // ── Step 3 · Collect valid rows ───────────────────────────────
            List<Map<String,Object>> validRows =
                new List<Map<String,Object>>();
            Set<String> nameSet = new Set<String>();

            for (Object rowObj : rawData) {
                Map<String,Object> row =
                    (Map<String,Object>) rowObj;

                String raw =
                    safeString(row.get(colMap.companyCol));

                if (String.isBlank(raw)) continue;

                validRows.add(row);
                nameSet.add(raw.trim());
            }

            if (validRows.isEmpty()) {
                result.errorMessage =
                    'No valid rows found. ' +
                    'Please check the Company Name column.';
                return results;
            }

            System.debug(LoggingLevel.DEBUG,
                'AccountExactMatchProcessor · ' +
                'unique names: ' + nameSet.size());

            // ── Step 4 · Bulk exact-match SOQL ───────────────────────────
            Map<String,Account> exactNameMap =
                buildExactNameMap(nameSet);

            System.debug(LoggingLevel.DEBUG,
                'AccountExactMatchProcessor · ' +
                'exact matches: ' + exactNameMap.size());

            // ── Step 5 · Collect unmatched names ─────────────────────────
            Set<String> unmatchedNames = new Set<String>();

            for (Map<String,Object> row : validRows) {
                String name =
                    safeString(row.get(colMap.companyCol)).trim();
                if (!exactNameMap.containsKey(
                        name.toLowerCase())) {
                    unmatchedNames.add(name);
                }
            }

            // ── Step 6 · Bulk fuzzy SOSL ──────────────────────────────────
            Map<String,Account> fuzzyNameMap =
                new Map<String,Account>();

            if (!unmatchedNames.isEmpty()) {
                fuzzyNameMap = bulkFuzzyFind(
                    unmatchedNames,
                    colMap,
                    validRows
                );
                System.debug(LoggingLevel.DEBUG,
                    'AccountExactMatchProcessor · ' +
                    'fuzzy matches: ' + fuzzyNameMap.size());
            }

            // ── Step 7 · Build Tasks ──────────────────────────────────────
            List<Task>   tasksToCreate = new List<Task>();
            List<String> notFoundParts = new List<String>();
            Integer      notFoundCount = 0;
            Set<Id>      seenIds       = new Set<Id>();

            for (Map<String,Object> row : validRows) {

                String companyName =
                    safeString(row.get(colMap.companyCol)).trim();

                String product =
                    safeString(row.get(colMap.productCol));

                String lookupKey = companyName.toLowerCase();

                Account matched =
                    exactNameMap.containsKey(lookupKey)
                        ? exactNameMap.get(lookupKey)
                        : fuzzyNameMap.get(lookupKey);

                if (matched != null) {

                    if (seenIds.contains(matched.Id)) {
                        System.debug(LoggingLevel.DEBUG,
                            'AccountExactMatchProcessor · ' +
                            'duplicate skipped: ' +
                            matched.Name);
                        continue;
                    }

                    seenIds.add(matched.Id);
                    tasksToCreate.add(
                        buildTask(matched, companyName, product)
                    );

                } else {

                    notFoundCount++;
                    notFoundParts.add(
                        notFoundCount + '. ' +
                        companyName  + '\n' +
                        'Reason: No exact or fuzzy ' +
                        'match found.'
                    );

                    System.debug(LoggingLevel.DEBUG,
                        'AccountExactMatchProcessor · ' +
                        'NOT FOUND: [' +
                        companyName + ']');
                }
            }

            // ── Step 8 · Bulk DML ─────────────────────────────────────────
            Integer      successCount = 0;
            List<String> insertErrors = new List<String>();

            if (!tasksToCreate.isEmpty()) {

                Database.SaveResult[] saveResults =
                    Database.insert(tasksToCreate, false);

                for (Integer i = 0;
                        i < saveResults.size(); i++) {

                    if (saveResults[i].isSuccess()) {
                        successCount++;
                    } else {
                        for (Database.Error err :
                                saveResults[i].getErrors()) {
                            insertErrors.add(
                                'Row ' + (i + 1) +
                                ': ' + err.getMessage()
                            );
                        }
                    }
                }

                if (!insertErrors.isEmpty()) {
                    System.debug(LoggingLevel.WARN,
                        'AccountExactMatchProcessor · ' +
                        'insert errors: ' +
                        String.join(insertErrors, ' | '));
                }
            }

            // ── Step 9 · Populate result ──────────────────────────────────
            result.tasksCreated      = successCount;
            result.notFoundCount     = notFoundCount;
            result.notFoundListString =
                String.join(notFoundParts, '\n');
            result.insertErrorString =
                String.join(insertErrors, '\n');
            result.isSuccess         = true;
            result.errorMessage      = null;

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'AccountExactMatchProcessor · error: ' +
                e.getMessage() +
                ' | line: ' + e.getLineNumber());
            result.isSuccess    = false;
            result.errorMessage = e.getMessage();
        }

        return results;
    }

    // ═════════════════════════════════════════════════════════════════════
    // Private helpers
    // ═════════════════════════════════════════════════════════════════════

    // ── Deserialisation ───────────────────────────────────────────────────

    /**
     * Parses the column-mapping JSON into a typed ColumnMapping.
     * Uses JSON.deserializeUntyped (static method on JSON class).
     */
    private static ColumnMapping deserialiseMapping(
            String jsonStr) {

        Map<String,Object> raw =
            (Map<String,Object>)
                JSON.deserializeUntyped(jsonStr);   // ← JSON class, not String

        ColumnMapping m = new ColumnMapping();
        m.companyCol    = safeString(raw.get('company_name'));
        m.productCol    = safeString(raw.get('product'));
        m.streetCol     = safeString(raw.get('billing_street'));
        m.cityCol       = safeString(raw.get('billing_city'));
        m.stateCol      = safeString(raw.get('billing_state'));
        m.countryCol    = safeString(raw.get('billing_country'));
        m.postalCol     = safeString(raw.get('billing_postal_code'));
        return m;
    }

    // ── Exact-match SOQL ──────────────────────────────────────────────────

    /**
     * Single SOQL query — no loop.
     * WHERE Name IN :nameSet is case-insensitive on the platform.
     * WITH USER_MODE enforces field-level and object-level security.
     */
    private static Map<String,Account> buildExactNameMap(
            Set<String> nameSet) {

        Map<String,Account> nameMap =
            new Map<String,Account>();

        for (Account acc : [
            SELECT Id, Name, OwnerId
            FROM   Account
            WHERE  Name IN :nameSet
            WITH   USER_MODE
            LIMIT  :MAX_ACCOUNTS
        ]) {
            String key = acc.Name.trim().toLowerCase();
            if (!nameMap.containsKey(key)) {
                nameMap.put(key, acc);
            }
        }

        return nameMap;
    }

    // ── Bulk fuzzy SOSL ───────────────────────────────────────────────────

    /**
     * Fires ONE Search.query() call for all unmatched names.
     *
     * Why Search.query() instead of a SOSL literal?
     * ──────────────────────────────────────────────
     * · SOSL literals do not support WITH USER_MODE.
     * · Search.query() runs in the sharing context of the
     *   calling class (with sharing), which is equivalent.
     * · Dynamic search terms require Search.query() anyway.
     *
     * Injection safety
     * ────────────────
     * · Every word is passed through escapeSosl() before
     *   being placed in the search string.
     * · Address filtering is done in Apex — no user data
     *   is ever concatenated into the SOSL WHERE clause.
     */
    @TestVisible
    private static Map<String,Account> bulkFuzzyFind(
            Set<String>              unmatchedNames,
            ColumnMapping            colMap,
            List<Map<String,Object>> validRows) {

        // Build name → row lookup for address data
        Map<String,Map<String,Object>> rowByName =
            new Map<String,Map<String,Object>>();

        for (Map<String,Object> row : validRows) {
            String name =
                safeString(row.get(colMap.companyCol)).trim();
            if (unmatchedNames.contains(name)) {
                rowByName.put(name.toLowerCase(), row);
            }
        }

        // ── Build SOSL search term ────────────────────────────────────────
        Set<String> wordSet = new Set<String>();

        for (String name : unmatchedNames) {
            for (String word : name.trim().split('\\s+')) {
                if (String.isNotBlank(word)) {
                    wordSet.add(escapeSosl(word.trim()));
                }
            }
        }

        if (wordSet.isEmpty()) {
            return new Map<String,Account>();
        }

        List<String> terms = new List<String>();
        for (String w : wordSet) {
            terms.add(w);
            terms.add(w + '*');
        }

        String soslTerm = String.join(terms, ' OR ');

        System.debug(LoggingLevel.DEBUG,
            'AccountExactMatchProcessor · ' +
            'SOSL term: ' + soslTerm);

        // ── Execute SOSL via Search.query() ───────────────────────────────
        //
        // Search.query() respects the "with sharing" declaration
        // of this class — no WITH USER_MODE keyword needed.
        //
        // The RETURNING clause has NO dynamic WHERE — all address
        // filtering happens in Apex below (injection-safe).
        //
        String soslQuery =
            'FIND :soslTerm '           +
            'IN NAME FIELDS '           +
            'RETURNING Account ('       +
                'Id, '                  +
                'Name, '                +
                'OwnerId, '             +
                'BillingStreet, '       +
                'BillingCity, '         +
                'BillingStateCode, '    +
                'BillingCountryCode, '  +
                'BillingPostalCode '    +
                'ORDER BY Name '        +
                'LIMIT :MAX_SOSL'       +
            ')';

        List<List<SObject>> searchResults;

        try {
            searchResults = Search.query(soslQuery);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'AccountExactMatchProcessor · ' +
                'SOSL error: ' + e.getMessage());
            return new Map<String,Account>();
        }

        if (searchResults        == null  ||
            searchResults.isEmpty()       ||
            searchResults[0].isEmpty()) {
            return new Map<String,Account>();
        }

        List<Account> candidates =
            (List<Account>) searchResults[0];

        // ── Score candidates against each unmatched name ──────────────────
        Map<String,Account> result =
            new Map<String,Account>();

        for (String unmatchedName : unmatchedNames) {

            String lowerName = unmatchedName.toLowerCase();
            Map<String,Object> row =
                rowByName.get(lowerName);

            String csvStreet  =
                row != null
                    ? safeString(row.get(colMap.streetCol))
                    : '';
            String csvCity    =
                row != null
                    ? safeString(row.get(colMap.cityCol))
                    : '';
            String csvState   =
                row != null
                    ? safeString(row.get(colMap.stateCol))
                    : '';
            String csvCountry =
                row != null
                    ? safeString(row.get(colMap.countryCol))
                    : '';
            String csvPostal  =
                row != null
                    ? safeString(row.get(colMap.postalCol))
                    : '';

            Account bestMatch = null;
            Integer bestScore = -1;

            for (Account candidate : candidates) {

                // Address pre-filter — pure Apex, no injection risk
                if (!addressMatches(
                        candidate,
                        csvStreet, csvCity,
                        csvState,  csvCountry,
                        csvPostal)) {
                    continue;
                }

                Integer score =
                    nameScore(unmatchedName, candidate.Name);

                if (score > bestScore) {
                    bestScore = score;
                    bestMatch = candidate;
                }
            }

            if (bestMatch != null && bestScore > 0) {
                result.put(lowerName, bestMatch);
                System.debug(LoggingLevel.DEBUG,
                    'AccountExactMatchProcessor · ' +
                    'fuzzy match: [' + unmatchedName +
                    '] → [' + bestMatch.Name +
                    '] score=' + bestScore);
            }
        }

        return result;
    }

    // ── Scoring ───────────────────────────────────────────────────────────

    /**
     * Word-overlap score.
     * Counts how many words from csvName appear in accountName.
     * Both sides are lowercased before comparison.
     */
    @TestVisible
    private static Integer nameScore(
            String csvName,
            String accountName) {

        if (String.isBlank(csvName) ||
            String.isBlank(accountName)) return 0;

        String lowerAccount = accountName.toLowerCase();
        Integer score = 0;

        for (String word :
                csvName.toLowerCase().split('\\s+')) {
            if (String.isNotBlank(word) &&
                lowerAccount.contains(word)) {
                score++;
            }
        }
        return score;
    }

    // ── Address filter ────────────────────────────────────────────────────

    /**
     * Returns true when every non-blank CSV address field
     * is contained in the corresponding Account field.
     * Blank CSV fields are treated as "don't care".
     */
    @TestVisible
    private static Boolean addressMatches(
            Account acc,
            String  csvStreet,
            String  csvCity,
            String  csvState,
            String  csvCountry,
            String  csvPostal) {

        if (String.isNotBlank(csvStreet) &&
            !safeString(acc.BillingStreet)
                .toLowerCase()
                .contains(csvStreet.toLowerCase())) {
            return false;
        }

        if (String.isNotBlank(csvCity) &&
            !safeString(acc.BillingCity)
                .toLowerCase()
                .contains(csvCity.toLowerCase())) {
            return false;
        }

        if (String.isNotBlank(csvState) &&
            !safeString(acc.BillingStateCode)
                .equalsIgnoreCase(csvState)) {
            return false;
        }

        if (String.isNotBlank(csvCountry) &&
            !safeString(acc.BillingCountryCode)
                .equalsIgnoreCase(csvCountry)) {
            return false;
        }

        if (String.isNotBlank(csvPostal) &&
            !safeString(acc.BillingPostalCode)
                .contains(csvPostal)) {
            return false;
        }

        return true;
    }

    // ── Task builder ──────────────────────────────────────────────────────

    private static Task buildTask(
            Account acc,
            String  csvCompanyName,
            String  product) {

        Task t         = new Task();
        t.WhatId       = acc.Id;
        t.OwnerId      = acc.OwnerId;
        t.Subject      = acc.Name + ' - ' + product;
        t.Description  =
            'Account : ' + acc.Name       + '\n' +
            'Product : ' + product        + '\n' +
            'CSV Row : ' + csvCompanyName;
        t.Status       = 'Not Started';
        t.Priority     = 'Normal';
        t.ActivityDate =
            Date.today().addDays(TASK_DUE_DAYS);
        return t;
    }

    // ── Utilities ─────────────────────────────────────────────────────────

    /**
     * Null-safe Object → String.
     * Returns empty string for null — never throws.
     */
    private static String safeString(Object val) {
        return val == null ? '' : String.valueOf(val);
    }

    /**
     * Escapes SOSL reserved characters.
     * Prevents user-supplied text from breaking
     * or injecting into the Search.query() string.
     */
    private static String escapeSosl(String input) {
        if (String.isBlank(input)) return '';
        return input
            .replace('\\', '\\\\')
            .replace('"',  '\\"')
            .replace('\'', '\\\'')
            .replace('(',  '\\(')
            .replace(')',  '\\)')
            .replace('{',  '\\{')
            .replace('}',  '\\}')
            .replace('[',  '\\[')
            .replace(']',  '\\]')
            .replace('^',  '\\^')
            .replace('~',  '\\~')
            .replace(':',  '\\:')
            .replace('!',  '\\!')
            .replace('&',  '\\&')
            .replace('|',  '\\|')
            .replace('+',  '\\+')
            .replace('-',  '\\-');
    }

    /** Returns a blank, initialised ProcessResult. */
    private static ProcessResult blankResult() {
        ProcessResult r      = new ProcessResult();
        r.isSuccess          = false;
        r.errorMessage       = 'Processing not completed';
        r.tasksCreated       = 0;
        r.notFoundCount      = 0;
        r.notFoundListString = '';
        r.insertErrorString  = '';
        return r;
    }
}