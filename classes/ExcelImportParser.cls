public with sharing class ExcelImportParser {

    private static final Integer MAX_FILE_BYTES  = 5242880;
    private static final Integer MAX_DATA_ROWS   = 5000;

    private static final Set<String> COMPANY_ALIASES =
        new Set<String>{
            'company name', 'company',
            'client',       'account',
            'organization', 'business',
            'account name', 'client name'
        };

    private static final Set<String> PRODUCT_ALIASES =
        new Set<String>{
            'product',      'product name',
            'item',         'sku',
            'service',      'product code',
            'item name'
        };

    public class ParseResult {
        @AuraEnabled public String  detectedColumnsJson;
        @AuraEnabled public String  parsedDataJson;
        @AuraEnabled public Integer totalRows;
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String  errorMessage;
        @AuraEnabled public String  warningMessage;
        @AuraEnabled public Boolean columnsAlreadyMatch;
        @AuraEnabled public String  autoMappingJson;
    }

    @AuraEnabled(cacheable=false)
    public static List<ParseResult> parseFile(
            String contentVersionId) {

        List<ParseResult> results = new List<ParseResult>();
        ParseResult result        = new ParseResult();
        result.isSuccess          = false;
        result.errorMessage       = 'Processing not completed';

        try {

            // ── Step 1 · Validate ID ─────────────────────
            if (String.isBlank(contentVersionId)) {
                result.errorMessage =
                    'No file ID received. ' +
                    'Please try uploading again.';
                results.add(result);
                return results;
            }

            // ── Step 2 · Query file ──────────────────────
            List<ContentVersion> cvList = [
                SELECT VersionData,
                       FileExtension,
                       Title
                FROM   ContentVersion
                WHERE  Id = :contentVersionId
                WITH    USER_MODE
                LIMIT  1
            ];

            if (cvList.isEmpty()) {
                result.errorMessage =
                    'File not found. ' +
                    'Please upload again.';
                results.add(result);
                return results;
            }

            ContentVersion cv = cvList[0];

            // ── Step 3 · Validate extension ──────────────
            if (cv.FileExtension == null ||
                    cv.FileExtension.toLowerCase() != 'csv') {
                result.errorMessage =
                    'Please upload a CSV file. ' +
                    'Received: ' + cv.FileExtension;
                results.add(result);
                return results;
            }

            // ── Step 4 · Validate file size ──────────────
            if (cv.VersionData.size() > MAX_FILE_BYTES) {
                result.errorMessage =
                    'File exceeds the 5 MB limit. ' +
                    'Please split it into smaller files.';
                results.add(result);
                return results;
            }

            // ── Step 5 · Decode + normalise ──────────────
            String raw = cv.VersionData.toString()
                .replace('\r\n', '\n')
                .replace('\r',   '\n');

            List<String> rows = raw.split('\n');

            if (rows.size() < 2) {
                result.errorMessage =
                    'The file has no data rows. ' +
                    'Please check your file.';
                results.add(result);
                return results;
            }

            // ── Step 6 · Parse header row ─────────────────
            List<String> headers = parseCSVRow(rows[0]);

            // Validate no empty or duplicate headers
            Set<String> seen = new Set<String>();
            for (Integer i = 0; i < headers.size(); i++) {
                if (String.isBlank(headers[i])) {
                    result.errorMessage =
                        'Column ' + (i + 1) +
                        ' has no header name. ' +
                        'Please fix your CSV.';
                    results.add(result);
                    return results;
                }
                String lower = headers[i].trim().toLowerCase();
                if (!seen.add(lower)) {
                    result.errorMessage =
                        'Duplicate column name: "' +
                        headers[i] + '". ' +
                        'Headers must be unique.';
                    results.add(result);
                    return results;
                }
            }

            result.detectedColumnsJson =
                JSON.serialize(headers);

            // ── Step 7 · Parse data rows ──────────────────
            List<Map<String,String>> allData =
                new List<Map<String,String>>();

            Integer rowLimit = Math.min(
                rows.size(),
                MAX_DATA_ROWS + 1
            );

            for (Integer i = 1; i < rowLimit; i++) {

                if (Limits.getCpuTime() >
                        Limits.getLimitCpuTime() * 0.85) {
                    result.warningMessage =
                        'Processing stopped at row ' + i +
                        ' due to CPU limits. ' +
                        'Please use a smaller file.';
                    break;
                }

                String row = rows[i].trim();
                if (String.isBlank(row)) continue;

                List<String>       values  = parseCSVRow(row);
                Map<String,String> rowData =
                    new Map<String,String>();

                for (Integer j = 0; j < headers.size(); j++) {
                    String val = j < values.size()
                        ? values[j].trim()
                        : '';
                    rowData.put(headers[j].trim(), val);
                }

                allData.add(rowData);
            }

            result.parsedDataJson = JSON.serialize(allData);
            result.totalRows      = allData.size();

            // ── Step 8 · Truncation warning ───────────────
            Integer totalDataLines = rows.size() - 1;
            if (totalDataLines > MAX_DATA_ROWS) {
                result.warningMessage =
                    'Only the first ' + MAX_DATA_ROWS +
                    ' of ' + totalDataLines +
                    ' rows were processed. ' +
                    'Please split the file into batches.';
            }

            // ── Step 9 · Auto-mapping ─────────────────────
            Map<String,String> autoMapping =
                attemptAutoMapping(headers);

            result.autoMappingJson      =
                JSON.serialize(autoMapping);
            result.columnsAlreadyMatch  =
                checkRequiredColumnsMapped(autoMapping);
            result.isSuccess            = true;
            result.errorMessage         = null;

        } catch (Exception e) {
            System.debug(
                LoggingLevel.ERROR,
                'ExcelImportParser error: ' +
                e.getMessage() +
                ' | line: ' + e.getLineNumber()
            );
            result.isSuccess    = false;
            result.errorMessage =
                'An unexpected error occurred: ' +
                e.getMessage();
        }

        results.add(result);
        return results;
    }

    @TestVisible
    private static List<String> parseCSVRow(String row) {

        List<String> values        = new List<String>();
        Boolean      inQuotes      = false;
        Boolean      fieldWasQuoted = false;
        List<String> chars         = new List<String>();

        for (Integer i = 0; i < row.length(); i++) {

            String ch = row.substring(i, i + 1);

            if (ch == '"') {
                if (inQuotes
                        && i + 1 < row.length()
                        && row.substring(i + 1, i + 2) == '"') {
                    chars.add('"');
                    i++;
                } else {
                    if (!inQuotes) fieldWasQuoted = true;
                    inQuotes = !inQuotes;
                }
            } else if (ch == ',' && !inQuotes) {
                String fieldValue = String.join(chars, '');
                values.add(
                    fieldWasQuoted
                        ? fieldValue
                        : fieldValue.trim()
                );
                chars          = new List<String>();
                fieldWasQuoted = false;
            } else {
                chars.add(ch);
            }
        }

        String lastField = String.join(chars, '');
        values.add(
            fieldWasQuoted
                ? lastField
                : lastField.trim()
        );

        return values;
    }

    private static Map<String,String> attemptAutoMapping(
            List<String> headers) {

        Map<String,String> mapping = new Map<String,String>();

        for (String header : headers) {
            String h = header.trim().toLowerCase();

            if (!mapping.containsKey('company_name')
                    && COMPANY_ALIASES.contains(h)) {
                mapping.put('company_name', header.trim());
            }
            if (!mapping.containsKey('product')
                    && PRODUCT_ALIASES.contains(h)) {
                mapping.put('product', header.trim());
            }
        }

        return mapping;
    }

    private static Boolean checkRequiredColumnsMapped(
            Map<String,String> mapping) {
        return mapping.containsKey('company_name') &&
               mapping.containsKey('product');
    }
}