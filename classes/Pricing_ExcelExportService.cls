/**
 * @description Service class to generate Excel files and store them as ContentDocument records
 * @author Accenture
 * @group Gravity
 * @last modified on 04-16-2026
 */
public without sharing class Pricing_ExcelExportService {
    
    private static final String EXCEL_HEADER = '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
    private static final String WORKBOOK_START = '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">';
    private static final String WORKBOOK_END = '</Workbook>';
    private static final String CDB_INTEGRATION_USER = 'CDB Integration User';
    
    /**
     * @description Container class for Excel data structure
     */
    public class ExcelData {
        public List<String> headers;
        public List<List<String>> rows;
        public String sheetName;
        
        public ExcelData(List<String> headers, List<List<String>> rows, String sheetName) {
            this.headers = headers;
            this.rows = rows;
            this.sheetName = sheetName;
        }
    }
    
    /**
     * @description Generates Excel file and stores it as ContentDocument
     * @param recordId Quote record ID
     * @return String ContentDocument ID
     */
    @AuraEnabled
    public static String generateAndStoreExcelFile(Id recordId) {
        try {
            // Get QLI data using existing controller method
            Map<String, Map<String, List<List<String>>>> qliData = Pricing_RunExportController.getQLIData(recordId);
            
            if (qliData == null || qliData.isEmpty()) {
                //add log entry
                //throw new AuraHandledException('No data available to export.');
            }
            
            // Prepare Excel data structures
            List<ExcelData> excelDataList = new List<ExcelData>();
            String quoteName = '';
            
            for (String sheetName : qliData.keySet()) {
                Map<String, List<List<String>>> headerToDataMap = qliData.get(sheetName);
                
                for (String headerString : headerToDataMap.keySet()) {
                    List<String> headers = headerString.split(',');
                    List<List<String>> rows = headerToDataMap.get(headerString);
                    
                    // Sort rows by Quote Line Number (assuming it's in the headers)
                    Integer quoteLineNumberIndex = getHeaderIndex(headers, 'Quote Line Number');
                    if (quoteLineNumberIndex >= 0 && rows.size() > 0) {
                        rows = sortDataByColumn(rows, quoteLineNumberIndex);
                    }
                    
                    // Extract quote number for filename
                    if (String.isBlank(quoteName) && rows.size() > 0) {
                        Integer quoteNumberIndex = getHeaderIndex(headers, 'Quote Number');
                        if (quoteNumberIndex >= 0 && rows[0].size() > quoteNumberIndex) {
                            quoteName = rows[0][quoteNumberIndex];
                        }
                    }
                    
                    excelDataList.add(new ExcelData(headers, rows, sheetName));
                }
            }
            
            // Generate Excel file content
            String excelContent = generateExcelXML(excelDataList);
            
            // Create filename
            String filename = String.isNotBlank(quoteName) 
                ? 'IQR - ' + quoteName + ' - INTEL CONFIDENTIAL.xls'
                : 'IQR - Report - INTEL CONFIDENTIAL.xls';
            
            // Create ContentVersion and share with CDB Integration User
            String contentDocumentId = createContentDocument(excelContent, filename, recordId);
            
            return contentDocumentId;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error generating Excel file: ' + e.getMessage());
        }
    }
    
    /**
     * @description Generates Excel XML content from ExcelData list
     * @param excelDataList List of ExcelData objects
     * @return String Excel XML content
     */
    private static String generateExcelXML(List<ExcelData> excelDataList) {
        List<String> xmlParts = new List<String>();
        xmlParts.add(EXCEL_HEADER);
        xmlParts.add(WORKBOOK_START);
        
        // Add styles for header row
        xmlParts.add('<Styles>');
        xmlParts.add('<Style ss:ID="HeaderStyle">');
        xmlParts.add('<Font ss:Bold="1"/>');
        xmlParts.add('<Interior ss:Color="#D3D3D3" ss:Pattern="Solid"/>');
        xmlParts.add('</Style>');
        xmlParts.add('</Styles>');
        
        // Create worksheets
        for (ExcelData excelData : excelDataList) {
            xmlParts.add(generateWorksheet(excelData));
        }
        
        xmlParts.add(WORKBOOK_END);
        return String.join(xmlParts, '');
    }
    
    /**
     * @description Generates a single worksheet XML
     * @param excelData ExcelData object containing sheet data
     * @return String Worksheet XML
     */
    private static String generateWorksheet(ExcelData excelData) {
        List<String> worksheetParts = new List<String>();
        String sanitizedSheetName = sanitizeSheetName(excelData.sheetName);
        
        worksheetParts.add('<Worksheet ss:Name="' + sanitizedSheetName + '">');
        worksheetParts.add('<Table>');
        
        // Add header row
        if (excelData.headers != null && !excelData.headers.isEmpty()) {
            worksheetParts.add('<Row>');
            for (String header : excelData.headers) {
                worksheetParts.add('<Cell ss:StyleID="HeaderStyle">');
                worksheetParts.add('<Data ss:Type="String">' + escapeXML(header) + '</Data>');
                worksheetParts.add('</Cell>');
            }
            worksheetParts.add('</Row>');
        }
        
        // Add data rows
        if (excelData.rows != null && !excelData.rows.isEmpty()) {
            for (List<String> row : excelData.rows) {
                worksheetParts.add('<Row>');
                for (String cellValue : row) {
                    worksheetParts.add('<Cell>');
                    String dataType = isNumeric(cellValue) ? 'Number' : 'String';
                    String value = cellValue != null ? escapeXML(cellValue) : '';
                    worksheetParts.add('<Data ss:Type="' + dataType + '">' + value + '</Data>');
                    worksheetParts.add('</Cell>');
                }
                worksheetParts.add('</Row>');
            }
        }
        
        worksheetParts.add('</Table>');
        worksheetParts.add('</Worksheet>');
        return String.join(worksheetParts, '');
    }
    
    /**
     * @description Creates ContentVersion and ContentDocumentLink records
     * @param excelContent Excel file content
     * @param filename Filename for the document
     * @param recordId Related record ID (Quote)
     * @return String ContentDocument ID
     */
    private static String createContentDocument(String excelContent, String filename, Id recordId) {
        // Create ContentVersion
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = filename;
        contentVersion.PathOnClient = filename;
        contentVersion.VersionData = Blob.valueOf(excelContent);
        contentVersion.FirstPublishLocationId = recordId;
        contentVersion.IsMajorVersion = true;
        
        insert contentVersion;
        
        // Get ContentDocument ID
        ContentVersion insertedCV = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id 
            LIMIT 1
        ];
        
        String contentDocumentId = insertedCV.ContentDocumentId;
        
        // Share with CDB Integration User
        shareWithCDBUser(contentDocumentId);
        
        return contentDocumentId;
    }
    
    /**
     * @description Shares ContentDocument with CDB Integration User
     * @param contentDocumentId ContentDocument ID
     */
    private static void shareWithCDBUser(String contentDocumentId) {
        // Find CDB Integration User
        List<User> cdbUsers = [
            SELECT Id 
            FROM User 
            WHERE Name = :CDB_INTEGRATION_USER 
            AND IsActive = true 
            LIMIT 1
        ];
        
        if (!cdbUsers.isEmpty()) {
            // Create ContentDocumentLink for sharing
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contentDocumentId;
            cdl.LinkedEntityId = cdbUsers[0].Id;
            cdl.ShareType = 'V'; // Viewer permission
            cdl.Visibility = 'AllUsers';
            
            insert cdl;
        } else {
            System.debug('CDB Integration User not found. ContentDocument not shared.');
        }
    }
    
    /**
     * @description Sorts data rows by specified column index
     * @param rows List of data rows
     * @param columnIndex Column index to sort by
     * @return List<List<String>> Sorted rows
     */
    private static List<List<String>> sortDataByColumn(List<List<String>> rows, Integer columnIndex) {
        List<RowWrapper> wrappers = new List<RowWrapper>();
        
        for (List<String> row : rows) {
            if (row.size() > columnIndex) {
                wrappers.add(new RowWrapper(row, row[columnIndex]));
            }
        }
        
        wrappers.sort();
        
        List<List<String>> sortedRows = new List<List<String>>();
        for (RowWrapper wrapper : wrappers) {
            sortedRows.add(wrapper.row);
        }
        
        return sortedRows;
    }
    
    /**
     * @description Helper class for sorting rows
     */
    private class RowWrapper implements Comparable {
        public List<String> row;
        public String sortValue;
        
        public RowWrapper(List<String> row, String sortValue) {
            this.row = row;
            this.sortValue = sortValue;
        }
        
        public Integer compareTo(Object compareTo) {
            RowWrapper compareToRow = (RowWrapper) compareTo;
            
            if (sortValue == compareToRow.sortValue) return 0;
            if (sortValue > compareToRow.sortValue) return 1;
            return -1;
        }
    }
    
    /**
     * @description Gets index of header by name
     * @param headers List of header names
     * @param headerName Header name to find
     * @return Integer Index of header, -1 if not found
     */
    private static Integer getHeaderIndex(List<String> headers, String headerName) {
        for (Integer i = 0; i < headers.size(); i++) {
            if (headers[i].equalsIgnoreCase(headerName)) {
                return i;
            }
        }
        return -1;
    }
    
    /**
     * @description Sanitizes sheet name for Excel compatibility
     * @param sheetName Original sheet name
     * @return String Sanitized sheet name
     */
    private static String sanitizeSheetName(String sheetName) {
        if (String.isBlank(sheetName)) {
            return 'Sheet1';
        }
        
        // Excel sheet names cannot contain: \ / ? * [ ]
        // and must be <= 31 characters
        String sanitized = sheetName.replaceAll('[\\\\/:?*\\[\\]]', '_');
        
        if (sanitized.length() > 31) {
            sanitized = sanitized.substring(0, 31);
        }
        
        return sanitized;
    }
    
    /**
     * @description Escapes special XML characters
     * @param value String to escape
     * @return String Escaped string
     */
    private static String escapeXML(String value) {
        if (String.isBlank(value)) {
            return '';
        }
        
        String escaped = value;
        escaped = escaped.replace('&', '&amp;');
        escaped = escaped.replace('<', '&lt;');
        escaped = escaped.replace('>', '&gt;');
        escaped = escaped.replace('"', '&quot;');
        escaped = escaped.replace('\'', '&apos;');
        return escaped;
    }
    
    /**
     * @description Checks if a string is numeric
     * @param value String to check
     * @return Boolean True if numeric
     */
    private static Boolean isNumeric(String value) {
        if (String.isBlank(value)) {
            return false;
        }
        
        try {
            Decimal.valueOf(value);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}