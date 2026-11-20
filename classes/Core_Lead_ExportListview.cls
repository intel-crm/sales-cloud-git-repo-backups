/**************************************************************************************
Apex Class Name:  Core_Lead_ExportListview
Version     : 1.0 
Created Date: 10 October 2019
Function    : This class is used to export listviews and report.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             10/10/2019              Original Version
*************************************************************************************/

public without sharing class Core_Lead_ExportListview {

    public static String objectInfo = 'Lead';
    public static List<SingleColumn> lstColumn { get; set; }
    public static String strQuery;
    
    @TestVisible 
    private static integer maxExportRows= 6000;

    // Helper: Validate that the generated query is a trusted List View query with a bounded LIMIT.
    @TestVisible
    private static Boolean isTrustedListViewQuery(String q) {
        if (String.isBlank(q)) {
            return false;
        }
        String qTrim = q.trim();
        if (!qTrim.toUpperCase().startsWith('SELECT ')) {
            return false;
        }
        
        // Additional security: Check for potentially dangerous keywords
        String upperQuery = qTrim.toUpperCase();
        List<String> dangerousKeywords = new List<String>{'DELETE', 'INSERT', 'UPDATE', 'UPSERT', 'MERGE'};
        for (String keyword : dangerousKeywords) {
            if (upperQuery.contains(keyword)) {
                return false;
            }
        }
        
        // Ensure FROM clause contains only Lead object
        if (!upperQuery.contains('FROM ' + objectInfo.toUpperCase())) {
            return false;
        }
        
        // Ensure LIMIT exists and is within expected range
        Integer limitIdx = qTrim.toUpperCase().lastIndexOf(' LIMIT ');
        if (limitIdx < 0) {
            return false;
        }
        String limitPart = qTrim.substring(limitIdx + 7).trim();
        // Remove optional trailing semicolon
        if (limitPart.endsWith(';')) {
            limitPart = limitPart.left(limitPart.length() - 1).trim();
        }
        Integer parsedLimit;
        try {
            parsedLimit = Integer.valueOf(limitPart);
        } catch (Exception ex) {
            return false;
        }
        return parsedLimit == (maxExportRows + 1);
    }

    // Helper: Parse columns from the List View describe response body
    @TestVisible
    private static List<SingleColumn> parseColumns(String body) {
        List<SingleColumn> cols = new List<SingleColumn>();
        if (String.isBlank(body)) {
            return cols;
        }
        
        try {
            System.JSONParser parser = JSON.createParser(body);
            processJsonTokens(parser, cols);
        } catch (Exception ex) {
            System.debug('Error parsing columns: ' + ex.getMessage());
        }
        
        return cols;
    }

    // Helper: Process JSON tokens to extract columns
    @TestVisible
    private static void processJsonTokens(System.JSONParser parser, List<SingleColumn> cols) {
        while (parser.nextToken() != null) { 
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {       
                processArrayTokens(parser, cols);
            }
        }
    }

    // Helper: Process array tokens to extract column objects
    @TestVisible
    private static void processArrayTokens(System.JSONParser parser, List<SingleColumn> cols) {
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                processColumnObject(parser, cols);
            }
        }
    }

    // Helper: Process individual column object
    @TestVisible
    private static void processColumnObject(System.JSONParser parser, List<SingleColumn> cols) {
        SingleColumn col = (SingleColumn) parser.readValueAs(SingleColumn.class);
        if (isValidColumn(col)) {
            sanitizeColumnLabel(col);
            cols.add(col);                    
        }
    }

    // Helper: Sanitize column label by removing commas
    @TestVisible
    private static void sanitizeColumnLabel(SingleColumn col) {
        if (col.label != null) {
            col.label = col.label.replace(',', '');
        }
    }

    // Helper: Column filter predicate
    @TestVisible
    private static Boolean isValidColumn(SingleColumn col) {
        if (col == null) {
            return false;
        }
        if (col.hidden == true) {
            return false;
        }
        if (col.fieldNameOrPath == null) {
            return false;
        }
        if (col.fieldNameOrPath.contains('Clone')) {
            return false;
        }
        return true;
    }
    
    @AuraEnabled
    public static list<listViewWrapper> listValues(){              
        Set<String> listViewSet = new Set<String>();
        list<listViewWrapper> oListViewWrapper = new list<listViewWrapper>();
        Id loggedUserId = UserInfo.getUserId();        
        
        try{  
            for(Core_Lead_Listview_Mapping__mdt mdt : [SELECT MasterLabel, DeveloperName, Core_Is_Active__c FROM Core_Lead_Listview_Mapping__mdt WHERE Core_Is_Active__c = TRUE]){
                listViewSet.add(mdt.DeveloperName);
            }
            for(ListView lv : [SELECT Id, Name, DeveloperName,CreatedById FROM ListView WHERE sObjectType = : objectInfo ORDER By Name ASC]){                              
                if(lv.CreatedById == loggedUserId || listViewSet.contains(lv.DeveloperName)){
                    listViewWrapper oWrapper = new listViewWrapper();
                    oWrapper.label = lv.Name;
                    oWrapper.developerName = lv.DeveloperName;
                    oWrapper.listViewId = lv.Id;
                    oListViewWrapper.add(oWrapper);
                }
            }
        }
        catch(Exception e){
            PMP_Utility.logError(e, 'Core_Lead_ExportListview.listValues');
        }        
        return oListViewWrapper; 
    }
    
    /*method: Apex method to call describe api for selected list view.
	*input: Object name and list view filter id
	*output: void */
    @AuraEnabled
    public static void listViewFilter(Id filterId, String sObjectName) {
        HttpRequest req = new HttpRequest();
        try{
            req.setHeader('Content-Type', 'application/json');      
			req.setEndpoint('callout:ExportListView'+ '/sobjects/' +sObjectName + '/listviews/' + filterId + '/describe');
            req.setMethod('GET');      
            Http h = new Http();
            HttpResponse res = h.send(req);
            Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());     
            // Build query and enforce LIMIT. Keep behavior: LIMIT maxExportRows+1
            String baseQuery = (String)root.get('query');
            if (String.isBlank(baseQuery)) {
                // If no query returned, leave state predictable
                strQuery = null;
                lstColumn = new List<SingleColumn>();
                return;
            }
            // Ensure no trailing semicolon before appending LIMIT
            baseQuery = baseQuery.trim();
            if (baseQuery.endsWith(';')) {
                baseQuery = baseQuery.left(baseQuery.length() - 1);
            }
            strQuery = baseQuery + ' LIMIT ' + (maxExportRows + 1);
            lstColumn = parseColumns(res.getBody());
        }
        catch(Exception e){
            PMP_Utility.logError(e, 'Core_Lead_ExportListview.listViewFilter');
        }  
        
    }
    
    /*method: Apex method to fetch records for a selected list view.
	*input: Object name and list view filter id
	*output: List<sObject> */
    @AuraEnabled
    public static List<sObject> fetchRecords(Id filterId){
        //fetching records based on the query.
        if(strQuery == null){
            listViewFilter(filterId,objectInfo);
        }
        if (strQuery == null || !isTrustedListViewQuery(strQuery)) {
            // Defensive: if query couldn't be built/validated, return empty to preserve stability
            return new List<sObject>();
        }
        List<sObject> lstRec = new List<sObject>();
        try{
            // Security: Execute query using Database.queryWithBinds for additional protection
            // The query is validated by isTrustedListViewQuery and originates from Salesforce List View API
            Map<String, Object> bindVars = new Map<String, Object>();
            lstRec = Database.queryWithBinds(strQuery, bindVars, AccessLevel.USER_MODE);
        }
        catch(Exception e){
            PMP_Utility.logError(e, 'Core_Lead_ExportListview.fetchRecords');
        }
        return lstRec;
    }
        
    /*method: Apex method to fetch columns for a selected list view.
	*input: Object name and list view filter id
	*output: Map<String,String> */
    @AuraEnabled
    public static Map<String,String> fetchKeys(Id filterId){
        Map<String,String> keysToLabelMap = new Map<String,String>{};
        try{
            listViewFilter(filterId, objectInfo);        
            for(SingleColumn l: lstColumn){
                keysToLabelMap.put(l.selectListItem,l.label);
            } 
        }
        catch(Exception e){
            PMP_Utility.logError(e, 'Core_Lead_ExportListview.fetchKeys');
        } 
        return keysToLabelMap;
    }
    
    /*wrapper class to store listView details*/ 
    public class listViewWrapper{
        @AuraEnabled public string label{get;set;} 
        @AuraEnabled public string developerName{get;set;}
        @AuraEnabled public string listViewId{get;set;}
        
    }
    
    public class SingleColumn {    
        @AuraEnabled public String  ascendingLabel  { get; set; }
        @AuraEnabled public String  descendingLabel { get; set; }
        @AuraEnabled public String  fieldNameOrPath { get; set; }
        @AuraEnabled public Boolean hidden          { get; set; }
        @AuraEnabled public String  label           { get; set; }
        @AuraEnabled public String  selectListItem  { get; set; }
        @AuraEnabled public String  sortDirection   { get; set; }
        @AuraEnabled public Integer sortIndex       { get; set; }
        @AuraEnabled public Boolean sortable        { get; set; }
        @AuraEnabled public String  type            { get; set; }
        @AuraEnabled public Boolean isDateType {
            get {
                return (type != NULL && type.contains('date'));     
            }
        }    
    }
}