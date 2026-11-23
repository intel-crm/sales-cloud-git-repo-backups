public with sharing class Core_IPS_Case_List_View_Export { 

    @TestVisible private static integer MAX_EXPORT_ROWS = 6000;

    @TestVisible private static integer MAX_FIELD_LENGTH = 1000;    

    @TestVisible private String strQuery;    

    
    public static final integer ASCII_FOR_DOUBLE_QUOTE = 34;

    public Boolean isPDFExportActive { get; set; }

    public Boolean isExcelExportActive { get; set; }

    public Boolean isCSVExportActive { get; set; }

    public String contentType { get; set; } 

    public String renderType { get; set; }

    public List<List<Object>> lstlstObj { get; set; }

    public String reportDate { get; set; }

    public String filterName { get; set; }

    public List<SingleColumn> lstColumn { get; set; }

    public String newLine { get { return '\n'; } }
    public String BOM     { get { return '\uFEFF'; } }

    private String fileName;
    private String returnURL;
    private String strFilterId;
    
    public Core_IPS_Case_List_View_Export(ApexPages.StandardSetController controller) {
            // Unencoded Formulas in Script Tags XSS Fix - TWC745-7251
        //returnURL = ApexPages.currentPage().getParameters().get('retURL').escapeHtml4();
        returnURL = ApexPages.currentPage().getParameters().get('retURL');
		// For PDF:
        // contentType = 'application/pdf#Export.pdf';
        // renderType  = 'PDF';

        // For VF Page:
        // contentType = '';
        // renderType  = '';

        Datetime dtNow = Datetime.now();
        reportDate = dtNow.format('yyyy-MM-dd h:mm a');

        lstlstObj = new List<List<Object>>();

        strfilterId = controller.getFilterId();
        
        List<System.SelectOption> lstSelectOption = controller.getListViewOptions();
        for (System.SelectOption so : lstSelectOption)
            if (so.getValue() == strfilterId) { 
                filterName = so.getLabel();    
                
                Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9\\s]');
                Matcher matcher = nonAlphanumeric.matcher(filterName);       
                fileName = matcher.replaceAll('');
                fileName = fileName.replace(' ', '_');
                break;
            }
        
        loadFilterFields();
        
        Integer idx = strQuery.indexOf(' FROM ');
		

        // String strCountQuery = 'SELECT Id ' + strQuery.substring(idx) + ' LIMIT ' + (MAX_EXPORT_ROWS + 1); // commented by Tushar
        
        Integer limitValue = MAX_EXPORT_ROWS + 1; // line added by Tushar
        String strCountQuery = 'SELECT Id ' + strQuery.substring(idx) + ' LIMIT :limitValue'; //added by Tushar
        
        List<Object> lstObj = Database.query(strCountQuery);
        if (lstObj.size() > MAX_EXPORT_ROWS) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'Maximum export size of ' + MAX_EXPORT_ROWS.format() + ' rows exceeded.');
            ApexPages.addMessage(myMsg);
            isPDFExportActive   = false;
            isExcelExportActive = false;
            isCSVExportActive   = false;
            return;
        }            
 
        isPDFExportActive   = false;
        isExcelExportActive = true;
        isCSVExportActive   = true;
                       
    }
    
    
    public PageReference returnToPage() {
        String finalReturnURL='';
        if( returnURL!= null){
            finalReturnURL = returnURL;
        }else{
            finalReturnURL = '/500/o';
        }           
        PageReference returnPage = new PageReference(finalReturnURL);
        returnPage.setRedirect(true);
        return returnPage;
    }      
    
    
    public void loadData(Boolean cleanData) {

        
        List<Object> lstObjPage = new List<Object>();
        
        integer counter = 0;
        
        for (List<sObject> lstSObj : Database.Query(strQuery)) {
        
            for (sObject sObj : lstSObj) {
                if (cleanData) 
                    lstObjPage.add(scrubDataFields(sObj, lstColumn));            
                else                            
                    lstObjPage.add(sObj);            
                    
                counter++;                        
                if (counter == 1000) {
                    lstlstObj.add(lstObjPage);
                    lstObjPage = new List<Object>();
                    counter = 0;
                }            
            }
        }

        lstlstObj.add(lstObjPage);
                
    }


    private Map<String, Object> scrubDataFields(sObject sObj, List<SingleColumn> lstSingleColumn) {

        Map<String, Object> mapRow = new Map<String, Object>();

        sObject sObjParent;

        List<String> lstFieldName;
        String strFieldName; 
        String strFieldValue;    
        Date   dtDateValue;

        for (SingleColumn sc : lstSingleColumn) {                
        
            if (sc.fieldNameOrPath.contains('.')) {
                lstFieldName  = sc.fieldNameOrPath.split('\\.');
                sObjParent    = sObj.getSOBject(lstFieldName[0]);
                strFieldValue = fieldToString(sObjParent, lstFieldName[1], sc.isDateType);
            }    
            else {
                strFieldValue = fieldToString(sObj, sc.fieldNameOrPath, sc.isDateType);
            }

            if (!sc.isDateType) {                
                if (strFieldValue.length() > MAX_FIELD_LENGTH) 
                    strFieldValue = strFieldValue.subString(0, MAX_FIELD_LENGTH) + '...';                
                
                strFieldValue = strFieldValue.escapeCSV();        
                //Avoid Deeply Nested IF Statements Kamala              
                if ((strFieldValue.length() > 0) && (strFieldValue.charAt(0) != ASCII_FOR_DOUBLE_QUOTE)) {
                        strFieldValue = '"' + strFieldValue + '"';                    
                }                                  
            }
            
            mapRow.put(sc.fieldNameOrPath, strFieldValue);
        }
        
        return mapRow;
    }


    private String fieldToString(sObject psObj, String fieldName, Boolean isDateType) { 
        // Some record types won't have a value the for the column
        if (psObj == NULL) 
            return '';

        // Some record types won't have a value the for the column
        if (psObj.get(fieldName) == NULL)
            return '';

        if (isDateType) {   
            Datetime dtDateValue = (DateTime) psObj.get(fieldName);
            return dtDateValue.format();    
        } 
        
        return String.valueOf(psObj.get(fieldName));                                        
    }


    private void loadFilterFields() {
        //added By Hassan for Authorization issue Fix.
        String ipsAuthorization = System.Label.IPS_Authorization;
        
        HttpRequest req = new HttpRequest();
        req.setHeader(ipsAuthorization, 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        
        /* Set the Cert here */                        
        req.setClientCertificateName(Label.Core_Self_Signed_Cert);
    
        String domainUrl = URL.getSalesforceBaseUrl().toExternalForm();
    
        if (Core_IPS_Case_Comments_Handler.isCurrentUserPortalUser()) {                            
            Organization currOrg = [Select IsSandbox from Organization limit 1];
            if (currOrg.isSandBox)
                domainUrl += '/IPS';  
            else
                domainUrl = Label.Core_IPS_API_Domain_Override;    
        }
    
        String endpointUrl = domainUrl + '/services/data/v37.0/sobjects/Case/listviews/' + strfilterId + '/describe';
    
        req.setEndpoint(endpointUrl);
        req.setMethod('GET');      
        Http h = new Http();
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 200){

        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody()); 
        strQuery = (String)root.get('query');
        strQuery = strQuery.replace('Owner.Alias', 'Owner.Name');
   
        if (Core_IPS_Case_Comments_Handler.isCurrentUserPortalUser() && strQuery.contains('USING SCOPE mine'))                            
            strQuery = processScopeForCases(strQuery);
        
        
        // This HAS to be reset every iteration.
        lstColumn = new List<SingleColumn>();
         
        //Parsing JSON string to get the column details    
        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null){ 
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {       
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        
                        SingleColumn col = (SingleColumn)parser.readValueAs(SingleColumn.class);
                        if(col.hidden == false && col.fieldNameOrPath != NULL && !col.fieldNameOrPath.contains('Clone')) {            
                            if (col.fieldNameOrPath == 'Owner.Alias') {
                                col.fieldNameOrPath = 'Owner.Name';
                                col.label = 'Case Owner';
                            }
                            
                            col.label = col.label.replace(',', '');                            
                            lstColumn.add(col);                    
                        }    
                    }
                }
            }
         }
        }
    }
    

    public string processScopeForCases(String strScopeQuery) {    
        if (!strScopeQuery.contains('USING SCOPE mine'))
            return strScopeQuery;
            
        String strSelectClause  = strScopeQuery.substring(0, strScopeQuery.indexOf('USING'));                
        String strWhereClause   = '';
        String strOrderByClause = '';
        
        Integer intWhereStart   = strScopeQuery.indexOf('WHERE');
        Integer intOrderByStart = strScopeQuery.indexOf('ORDER BY');
                
        Id idUser = UserInfo.getUserId();        
        User objUser = [SELECT Id, ContactId FROM User WHERE Id = :idUser LIMIT 1];         
                
        if ((intWhereStart == -1) && (intOrderByStart == -1))        
            strWhereClause  = 'WHERE Contact.Id = \'' + objUser.ContactId + '\' ';
        else if ((intWhereStart != -1) && (intOrderByStart == -1)) {       
            strWhereClause  = strScopeQuery.substring(strScopeQuery.indexOf('WHERE'));
            strWhereClause += ' AND Contact.Id = \'' + objUser.ContactId + '\' ';
        }
        else if ((intWhereStart == -1) && (intOrderByStart != -1)) {       
            strWhereClause   = 'WHERE Contact.Id = \'' + objUser.ContactId + '\' ';
            strOrderByClause = strScopeQuery.substring(intOrderByStart);
        }
        else if ((intWhereStart != -1) && (intOrderByStart != -1)) {       
            strWhereClause   = strScopeQuery.substring(strScopeQuery.indexOf('WHERE'), strScopeQuery.indexOf('ORDER BY') - 1);
            strWhereClause  += ' AND Contact.Id = \'' + objUser.ContactId + '\' ';
            strOrderByClause = strScopeQuery.substring(intOrderByStart);        
        }
                
        return strSelectClause + strWhereClause + strOrderByClause;
    }

    
    public PageReference exportToExcel() {

        try {            
            loadData(false);  // The data DOES NOT have to be "cleaned" for Excel Export
        }
        catch (Exception e) {
            String consolidatedMessage = e.getTypeName() + ' on line# ' + e.getLineNumber() + ' : ' + e.getMessage();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, consolidatedMessage);
            ApexPages.addMessage(myMsg);
            return null;
        }

        contentType = 'application/vnd.ms-excel#' + fileName + '.xls';
        renderType  = '';
        
        PageReference excelPage = page.Core_IPS_Case_List_View;
        excelPage.setRedirect(false);
        return excelPage;

    }  


    public PageReference exportToCSV() {

        try {
            loadData(true);  // The data must be "cleaned" for CSV
        }
        catch (Exception e) {
            String consolidatedMessage = e.getTypeName() + ' on line# ' + e.getLineNumber() + ' : ' + e.getMessage();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, consolidatedMessage);
            ApexPages.addMessage(myMsg);
            return null;
        }

        // For CSV: \uFEFF
        contentType = 'text/csv#' + fileName + '.csv; charset=UTF-8';
        renderType  = '';
        
        PageReference excelPage = page.Core_IPS_Case_List_View_CSV;
        excelPage.setRedirect(false);
        return excelPage;
                
    }  


    public class applicationException extends Exception {}


    public class SingleColumn {    
        public String  ascendingLabel  { get; set; }
        public String  descendingLabel { get; set; }
        public String  fieldNameOrPath { get; set; }
        public Boolean hidden          { get; set; }
        public String  label           { get; set; }
        public String  selectListItem  { get; set; }
        public String  sortDirection   { get; set; }
        public Integer sortIndex       { get; set; }
        public Boolean sortable        { get; set; }
        public String  type            { get; set; }
        public Boolean isDateType {
            get {
                   return (type != NULL && type.contains('date'));     
            }
        }    
    }                   
}