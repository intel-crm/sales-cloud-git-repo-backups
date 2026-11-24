public with sharing class AccountExactMatchProcessor {

    // ── Constants ─────────────────────────────────────
    private static final Integer MAX_ACCOUNTS = 50000;

    // ── Result DTO ────────────────────────────────────
    public class ProcessResult {
        @AuraEnabled public Integer tasksCreated;
        @AuraEnabled public Integer notFoundCount;
        @AuraEnabled public String  notFoundListString;
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String  errorMessage;
    }

    // ── Entry Point ───────────────────────────────────
    @AuraEnabled(cacheable=false)
    public static List<ProcessResult> processRecords(
            String parsedDataJson,
            String columnMappingJson) {

        List<ProcessResult> results = new List<ProcessResult>();
        ProcessResult result        = new ProcessResult();
        result.isSuccess            = false;
        result.errorMessage         = 'Processing not completed';
        result.tasksCreated         = 0;
        result.notFoundCount        = 0;
        result.notFoundListString   = '';

        try {

            // ── Step 1 · Deserialise inputs ───────────
            List<Object> rawData =
                (List<Object>)
                JSON.deserializeUntyped(parsedDataJson);

            Map<String,Object> colMapping =
                (Map<String,Object>)
                JSON.deserializeUntyped(columnMappingJson);

            // ── Step 2 · Resolve + validate columns ───
            String companyCol =
                (String) colMapping.get('company_name');
            String productCol =
                (String) colMapping.get('product');

            if (String.isBlank(companyCol)) {
                result.errorMessage =
                    'Column mapping is missing ' +
                    '"company_name". ' +
                    'Please re-map your columns.';
                results.add(result);
                return results;
            }

            if (String.isBlank(productCol)) {
                result.errorMessage =
                    'Column mapping is missing ' +
                    '"product". ' +
                    'Please re-map your columns.';
                results.add(result);
                return results;
            }

            // ── Step 3 · Collect valid rows ───────────
            // Also build a Set of company names for
            // the WHERE Name IN :nameSet SOQL —
            // this replaces the fragile LIKE approach
            List<String>             companyNames =
                new List<String>();
            List<Map<String,Object>> validRows    =
                new List<Map<String,Object>>();

            // nameSet holds the exact names from
            // the CSV — used directly in SOQL
            // WHERE Name IN clause for precise fetch
            Set<String> nameSet = new Set<String>();

            for (Object rowObj : rawData) {

                Map<String,Object> row =
                    (Map<String,Object>) rowObj;

                String companyName =
                    (String) row.get(companyCol);

                if (String.isBlank(companyName))
                    continue;

                String trimmedName =
                    companyName.trim();

                companyNames.add(trimmedName);
                validRows.add(row);
                nameSet.add(trimmedName);
            }

            if (validRows.isEmpty()) {
                result.errorMessage =
                    'No valid rows found. ' +
                    'Please check the ' +
                    'Company Name column.';
                results.add(result);
                return results;
            }

            System.debug(
                'AccountExactMatchProcessor · ' +
                'unique company names to match: ' +
                nameSet.size()
            );
            System.debug(
                'AccountExactMatchProcessor · ' +
                'nameSet: ' + nameSet
            );

            // ── Step 4 · Query accounts by exact name ─
            //
            // WHERE Name IN :nameSet
            //   · Salesforce performs this as a
            //     case-INSENSITIVE exact match
            //   · No LIKE, no wildcards, no fragility
            //   · Directly fetches only the accounts
            //     whose names appear in the CSV
            //   · Bound variable prevents SOQL injection
            //
            List<Account> matchedAccounts = [
                SELECT Id,
                       Name,
                       OwnerId
                FROM   Account
                WHERE  Name IN :nameSet
                WITH   USER_MODE
                LIMIT  :MAX_ACCOUNTS
            ];

            System.debug(
                'AccountExactMatchProcessor · ' +
                'accounts fetched: ' +
                matchedAccounts.size()
            );

            for (Account acc : matchedAccounts) {
                System.debug(
                    'AccountExactMatchProcessor · ' +
                    'fetched account: [' +
                    acc.Name + ']'
                );
            }

            // ── Step 5 · Build exact lookup map ───────
            //
            // Key   = account name lowercased + trimmed
            // Value = Account record
            //
            // Lowercasing both sides ensures the match
            // is case-insensitive even if Salesforce
            // returns mixed-case names
            //
            Map<String,Account> exactNameMap =
                new Map<String,Account>();

            for (Account acc : matchedAccounts) {
                String key =
                    acc.Name.trim().toLowerCase();

                // Keep first if duplicate names exist
                if (!exactNameMap.containsKey(key)) {
                    exactNameMap.put(key, acc);
                }
            }

            System.debug(
                'AccountExactMatchProcessor · ' +
                'exactNameMap keys: ' +
                exactNameMap.keySet()
            );

            // ── Step 6 · Match rows → build Tasks ─────
            List<Task>   tasksToCreate =
                new List<Task>();
            List<String> notFoundParts =
                new List<String>();
            Integer      notFoundCount = 0;

            for (Integer rowIdx = 0;
                    rowIdx < validRows.size();
                    rowIdx++) {

                Map<String,Object> row =
                    validRows[rowIdx];

                String companyName =
                    companyNames[rowIdx];

                String product =
                    (String) row.get(productCol);

                if (String.isBlank(product)) {
                    product = '';
                }

                // Lowercase both sides for
                // case-insensitive comparison
                String lookupKey =
                    companyName.toLowerCase();

                System.debug(
                    'AccountExactMatchProcessor · ' +
                    'looking up: [' +
                    lookupKey + ']'
                );

                Account matched =
                    exactNameMap.get(lookupKey);

                if (matched != null) {

                    System.debug(
                        'AccountExactMatchProcessor · ' +
                        'MATCHED: [' +
                        matched.Name + ']'
                    );

                    Task t         = new Task();
                    t.WhatId       = matched.Id;
                    t.OwnerId      = matched.OwnerId;
                    t.Subject      =
                        matched.Name +
                        ' - ' + product;
                    t.Description  =
                        'Account : ' +
                            matched.Name + '\n' +
                        'Product : ' +
                            product      + '\n' +
                        'CSV Row : ' +
                            companyName;
                    t.Status       = 'Not Started';
                    t.Priority     = 'Normal';
                    t.ActivityDate =
                        Date.today().addDays(7);

                    tasksToCreate.add(t);

                } else {

                    System.debug(
                        'AccountExactMatchProcessor · ' +
                        'NOT FOUND: [' +
                        companyName + ']'
                    );

                    notFoundParts.add(
                        (notFoundCount + 1) +
                        '. ' + companyName  + '\n' +
                        '   Reason: No account ' +
                        'with exact name: "' +
                        companyName + '"'   + '\n' +
                        '─────────────────────'
                    );

                    notFoundCount++;
                }
            }

            // ── Step 7 · DML with partial success ─────
            Integer successCount = 0;

            if (!tasksToCreate.isEmpty()) {

                Database.SaveResult[] saveResults =
                    Database.insert(
                        tasksToCreate, false
                    );

                List<String> insertErrors =
                    new List<String>();

                for (Integer i = 0;
                        i < saveResults.size();
                        i++) {

                    if (saveResults[i].isSuccess()) {
                        successCount++;
                    } else {
                        for (Database.Error err :
                                saveResults[i]
                                    .getErrors()) {
                            insertErrors.add(
                                'Row ' + (i + 1) +
                                ': ' +
                                err.getMessage()
                            );
                        }
                    }
                }

                if (!insertErrors.isEmpty()) {
                    System.debug(
                        LoggingLevel.WARN,
                        'AccountExactMatchProcessor' +
                        ' · insert errors: ' +
                        String.join(
                            insertErrors, ' | '
                        )
                    );
                }
            }

            // ── Step 8 · Populate result ──────────────
            result.tasksCreated       = successCount;
            result.notFoundCount      = notFoundCount;
            result.notFoundListString =
                String.join(notFoundParts, '\n');
            result.isSuccess          = true;
            result.errorMessage       = null;

        } catch (Exception e) {
            System.debug(
                LoggingLevel.ERROR,
                'AccountExactMatchProcessor · ' +
                'error: ' + e.getMessage() +
                ' | line: ' + e.getLineNumber()
            );
            result.isSuccess    = false;
            result.errorMessage = e.getMessage();
        }

        results.add(result);
        return results;
    }
}