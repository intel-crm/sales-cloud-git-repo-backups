public class ExcelImportParser {

    // ============================================
    // REQUEST & RESULT CLASSES
    // ============================================
    
    public class ParseRequest {
        @InvocableVariable(
            required=true 
            label='Content Version Id')
        public String contentVersionId;
    }
    
    public class ParseResult {
        @InvocableVariable(label='Detected Columns JSON')
        public String detectedColumnsJson;
        
        @InvocableVariable(label='Parsed Data JSON')
        public String parsedDataJson;
        
        @InvocableVariable(label='Total Rows')
        public Integer totalRows;
        
        @InvocableVariable(label='Is Success')
        public Boolean isSuccess;
        
        @InvocableVariable(label='Error Message')
        public String errorMessage;
        
        @InvocableVariable(label='Columns Already Match')
        public Boolean columnsAlreadyMatch;
        
        @InvocableVariable(label='Auto Mapping JSON')
        public String autoMappingJson;
    }

    // ============================================
    // MAIN INVOCABLE METHOD
    // ============================================
    
    @InvocableMethod(
        label='Parse Import File' 
        description='Parses uploaded CSV file and detects columns'
        category='Excel Import'
    )
    public static List<ParseResult> parseFile(
        List<ParseRequest> requests) {
        
        List<ParseResult> results = new List<ParseResult>();
        ParseResult result = new ParseResult();
        
        try {
            // Step 1: Get file from ContentVersion
            ContentVersion cv = [
                SELECT VersionData, 
                       FileExtension, 
                       Title
                FROM ContentVersion 
                WHERE Id = :requests[0].contentVersionId
                LIMIT 1
            ];
            
            // Step 2: Validate file type
            if(cv.FileExtension.toLowerCase() != 'csv') {
                result.isSuccess = false;
                result.errorMessage = 
                    'Please upload a CSV file. ' +
                    'To convert: Open Excel → ' +
                    'File → Save As → CSV format.';
                results.add(result);
                return results;
            }
            
            // Step 3: Convert file to string
            String fileContent = cv.VersionData.toString();
            
            // Step 4: Split into rows
            // Handle both Windows (\r\n) and Mac/Linux (\n)
            fileContent = fileContent.replace('\r\n', '\n');
            fileContent = fileContent.replace('\r', '\n');
            List<String> rows = fileContent.split('\n');
            
            if(rows.size() < 2) {
                result.isSuccess = false;
                result.errorMessage = 
                    'File has no data rows. ' +
                    'Please check your file.';
                results.add(result);
                return results;
            }
            
            // Step 5: Parse header row
            List<String> headers = parseCSVRow(rows[0]);
            result.detectedColumnsJson = JSON.serialize(headers);
            
            // Step 6: Parse all data rows
            List<Map<String,String>> allData = 
                new List<Map<String,String>>();
                
            for(Integer i = 1; i < rows.size(); i++) {
                String row = rows[i].trim();
                if(String.isBlank(row)) continue;
                
                List<String> values = parseCSVRow(row);
                Map<String,String> rowData = 
                    new Map<String,String>();
                
                for(Integer j = 0; j < headers.size(); j++) {
                    String val = j < values.size() ? 
                        values[j].trim() : '';
                    rowData.put(headers[j].trim(), val);
                }
                allData.add(rowData);
            }
            
            result.parsedDataJson = JSON.serialize(allData);
            result.totalRows = allData.size();
            
            // Step 7: Try auto mapping
            Map<String,String> autoMapping = 
                attemptAutoMapping(headers);
            result.autoMappingJson = 
                JSON.serialize(autoMapping);
            result.columnsAlreadyMatch = 
                checkRequiredColumnsMapped(autoMapping);
            
            result.isSuccess = true;
            
        } catch(Exception e) {
            result.isSuccess = false;
            result.errorMessage = 
                'Error: ' + e.getMessage();
        }
        
        results.add(result);
        return results;
    }
    
    // ============================================
    // HELPER: Parse CSV row
    // Handles commas inside quoted values
    // ============================================
    
    private static List<String> parseCSVRow(String row) {
        List<String> values = new List<String>();
        Boolean inQuotes = false;
        String currentVal = '';
        
        for(Integer i = 0; i < row.length(); i++) {
            String ch = row.substring(i, i+1);
            
            if(ch == '"') {
                inQuotes = !inQuotes;
            } else if(ch == ',' && !inQuotes) {
                values.add(currentVal.trim()
                    .removeStart('"')
                    .removeEnd('"'));
                currentVal = '';
            } else {
                currentVal += ch;
            }
        }
        values.add(currentVal.trim()
            .removeStart('"')
            .removeEnd('"'));
            
        return values;
    }
    
    // ============================================
    // HELPER: Auto map columns
    // ============================================
    
    private static Map<String,String> attemptAutoMapping(
        List<String> headers) {
        
        Map<String,String> mapping = new Map<String,String>();
        
        // Expected columns and their common aliases
        Map<String,List<String>> expectedColumns = 
            new Map<String,List<String>>{
                'company_name' => new List<String>{
                    'company name','company','client',
                    'account','organization','business',
                    'account name'
                },
                'product' => new List<String>{
                    'product','product name','item',
                    'sku','service','product code'
                },
                'owner_email' => new List<String>{
                    'owner email','owner','rep','email',
                    'assigned to','sales rep','rep email'
                },
                'notes' => new List<String>{
                    'notes','description','comments',
                    'details','remarks','note'
                }
            };
        
        for(String expectedKey : expectedColumns.keySet()) {
            List<String> aliases = 
                expectedColumns.get(expectedKey);
            
            for(String header : headers) {
                if(aliases.contains(
                    header.trim().toLowerCase())) {
                    mapping.put(expectedKey, header.trim());
                    break;
                }
            }
        }
        
        return mapping;
    }
    
    // ============================================
    // HELPER: Check required columns mapped
    // ============================================
    
    private static Boolean checkRequiredColumnsMapped(
        Map<String,String> mapping) {
        
        // company_name and product are required
        return mapping.containsKey('company_name') && 
               mapping.containsKey('product');
    }
}