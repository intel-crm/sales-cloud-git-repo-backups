public with sharing class Core_MDF_ExportToExcel {
    
    @TestVisible private static integer maxExportRows = Integer.valueOf(Label.Core_MDF_Max_export_limit);   
    @TestVisible private static integer maxFieldLength = 1000; 
    public static String logEntryMsg = '';
    public String strQuery;        
    public static string domainUrl;
    public static string pageUrl;    
    public static final integer ASCII_FOR_DOUBLE_QUOTE = 34;    
    public static Boolean isPDFExportActive { get; set; }    
    Boolean isExcelExportActive { get; set; }    
    public static Boolean isCSVExportActive { get; set; }    
    public static String contentType { get; set; } 
    public static String objName { get; set; }     
    public List<SingleColumn> lstColumn { get; set; }    
    public  String renderType { get; set; }    
    public List<List<Object>> lstlstObj { get; set; }    
    public String reportDate { get; set; }    
    public String filterName { get; set; }        
    public String newLine { get { return '\n'; } }
    public String bom    { get { return '\uFEFF'; } }    
    public String fileName { get; set; }
    public String returnURL;
    public static String strFilterId;
    public String errorMsg;
    
    public Core_MDF_ExportToExcel() { 
        try{
            pageUrl=ApexPages.currentPage().getUrl();        
            System.debug('pageUrl: '+pageUrl);
            objName =  ApexPages.currentPage().getUrl().substringAfter('ObjName=').substringBefore('&');
            System.debug('objName'+objName);        
            String q = String.escapeSingleQuotes('SELECT Id FROM '+objName+' LIMIT '+ (maxExportRows + 1));
            system.debug('q:'+q);
            List<sObject> objList = Database.query(q);
            system.debug('objList:'+objList);
            ApexPages.StandardSetController controller = new ApexPages.StandardSetController(objList);                
            System.debug('#01 controller.getResultSize(): ' + controller.getResultSize());
            Datetime dtNow = Datetime.now();
            reportDate = dtNow.format('yyyy-MM-dd h:mm a');        
            lstlstObj = new List<List<Object>>();        
            strfilterId = controller.getFilterId();
            system.debug('list view filterId:'+strfilterId);                
            List<System.SelectOption> lstSelectOption = controller.getListViewOptions();
            for (System.SelectOption so : lstSelectOption){
                if (so.getValue() == strfilterId) { 
                    filterName = so.getLabel();                    
                    Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9\\s]');
                    Matcher matcher = nonAlphanumeric.matcher(filterName);       
                    fileName = matcher.replaceAll('');
                    fileName = fileName.replace(' ', '_');
                    break;
                } 
            }
            loadFilterFields();
            //US523018: PRB000091900 : Unable to export raw reports (CSV,xlsx) from CLAIM list page            
            domainUrl = (String.isNotBlank(domainUrl) && domainUrl.lastIndexOf('/') == domainUrl.length()-1) ? domainUrl : URL.getSalesforceBaseUrl().toExternalForm() +'/';            
            system.debug('#07 domainUrl:' + domainUrl);
            returnURL = domainUrl+'lightning/o/'+objName+'/list?filterName='+strfilterId;
            System.debug('returnURL:'+returnURL); 
            if(strQuery != null && strQuery != ''){
                System.debug('#05 strQuery: ' + strQuery);        
            Integer idx = strQuery.indexOf(' FROM ');
            String strCountQuery = string.escapeSingleQuotes('SELECT Id ') + strQuery.substring(idx);
            //System.debug('#06 strCountQuery: ' + strCountQuery);            
            //strCountQuery = String.escapeSingleQuotes(strCountQuery);
            System.debug('#06 strCountQuery: ' + strCountQuery);                
            List<Object> lstObj = Database.query(strCountQuery);
            if (lstObj.size() > maxExportRows || (Test.isRunningTest() &&  lstObj.size() >1)) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, Label.Core_MDF_Max_export_limit_exceeded_msg);
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
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Core_MDF_ApplicationErrorMessage));
                          }
    }    
    public PageReference returnToPage() {      
        System.debug('retUrl:'+returnURL);
        PageReference returnPage = new PageReference(returnURL);            
        returnPage.setRedirect(true);
        return returnPage;
    }  
    
    public void loadData(Boolean cleanData) {        
        System.debug('#41 LoadData START - strQuery: ' + strQuery);
        try{
            List<Object> lstObjPage = new List<Object>();        
            integer counter = 0;
            System.debug('strQuery: '+strQuery);
            for (List<sObject> lstSObj : Database.Query(strQuery)) { 
                for (sObject sObj : lstSObj) {
                    if (cleanData){ 
                        lstObjPage.add(scrubDataFields(sObj, lstColumn));
                    }
                    else{                            
                        lstObjPage.add(sObj);                            
                    }
                    counter++;                        
                    if (counter == 1000 || Test.isRunningTest()) {
                        lstlstObj.add(lstObjPage);
                        lstObjPage = new List<Object>();
                        counter = 0;
                    }            
                }
            }        
            lstlstObj.add(lstObjPage);
            system.debug('lstlstObj:'+lstlstObj); 
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Core_MDF_ApplicationErrorMessage));
        }
    }
    
    
    public Map<String, Object> scrubDataFields(sObject sObj, List<SingleColumn> lstSingleColumn) {        
        Map<String, Object> mapRow = new Map<String, Object>();        
        sObject sObjParent;                
        List<String> lstFieldName;
        String strFieldName; 
        String strFieldValue;    
        Date   dtDateValue;
        try{
            for (SingleColumn sc : lstSingleColumn) {                            
                if (sc.fieldNameOrPath.contains('.')) {
                    system.debug('sc.fieldNameOrPath:'+sc.fieldNameOrPath);
                    lstFieldName  = sc.fieldNameOrPath.split('\\.');
                    string child=lstFieldName[0];
                    sObjParent    = sObj.getSOBject(child);
                    for(integer i=1;i<lstFieldName.size()-1;i++){
                        
                        child = lstFieldName[i];
                        sObjParent    = sObjParent.getSOBject(child);
                    }                                
                    strFieldValue = fieldToString(sObjParent, lstFieldName[lstFieldName.size()-1], sc.isDateType,sc.type);
                }    
                else {
                    strFieldValue = fieldToString(sObj, sc.fieldNameOrPath, sc.isDateType,sc.type);
                }            
                if (!sc.isDateType) {                
                    if (strFieldValue.length() > maxFieldLength){ 
                        strFieldValue = strFieldValue.subString(0, maxFieldLength) + '...'; 
                    }                       
                    strFieldValue = strFieldValue.escapeCSV();                        
                    if (strFieldValue.length() > 0) {
                        if (strFieldValue.charAt(0) != ASCII_FOR_DOUBLE_QUOTE) {
                            strFieldValue = '"' + strFieldValue + '"';                    
                        }                               
                    }                                  
                }            
                mapRow.put(sc.fieldNameOrPath, strFieldValue);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Core_MDF_ApplicationErrorMessage));
        }
        return mapRow;
    }
    
    @TestVisible private String fieldToString(sObject psObj, String fieldName, Boolean isDateType,String type) { 
        
        try{
            // Some record types won't have a value the for the column
            if (psObj == NULL){ 
                return '';
            }               
            // Some record types won't have a value the for the column
            if (psObj.get(fieldName) == NULL){
                return '';        
            }
            //check if the type is of datetime type or date type.
            if (isDateType && type.equalsIgnoreCase('date')) { 
                Date dDateValue = (Date) psObj.get(fieldName);
                return dDateValue.format(); 
            }
            else if (isDateType && type.equalsIgnoreCase('datetime')) { 
                Datetime dtDateValue = (DateTime) psObj.get(fieldName);
                return dtDateValue.format();    
            }            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Core_MDF_ApplicationErrorMessage));
        }
        return String.valueOf(psObj.get(fieldName));                                        
    }
    
    
    private void loadFilterFields() {
        HttpRequest req = new HttpRequest();
        String endpointUrl = '';
        try{
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');        
            /* Set the Cert here */                        
            req.setClientCertificateName(Label.Core_Self_Signed_Cert);        
            domainUrl = URL.getSalesforceBaseUrl().toExternalForm();
            system.debug('#07 domainUrl:' + domainUrl);
            //US523018: PRB000091900 : Unable to export raw reports (CSV,xlsx) from CLAIM list page
            domainUrl = (domainUrl.lastIndexOf('/') == domainUrl.length()-1) ? domainUrl : domainUrl+'/';
            system.debug('#07 domainUrl after edit:' + domainUrl);
            
            //SF Fix-Ealisha:start
            List<String> whiteListedObjApiNameList = new List<String>();
            for(Core_MDF_ListView_Group_Mapping__mdt mdt : [SELECT Label, Core_MDF_Active_ind__c, Core_MDF_SObject_txt__c,Core_MDF_Whitelisted_Object__c FROM Core_MDF_ListView_Group_Mapping__mdt WHERE Core_MDF_Whitelisted_Object__c=true and Core_MDF_Active_ind__c=true]){
                                                            whiteListedObjApiNameList.add(mdt.Core_MDF_SObject_txt__c); 
                                                            }
            system.debug('whiteListedObjApiNameList:'+whiteListedObjApiNameList);
            if(whiteListedObjApiNameList.contains(objName) && (strfilterId.length() == 15 || strfilterId.length() == 18)){
               endpointUrl = domainUrl + Label.Core_MDF_Describe_API_URL4 +objName + Label.Core_MDF_Describe_API_URL2 + strfilterId + Label.Core_MDF_Describe_API_URL3;
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Core_MDF_Export_Whitelisting_Error_Message));
            }
            //SF Fix-Ealisha:end
            
            system.debug('#08 domain URL' + endpointUrl);
            if(endpointUrl != ''){
            req.setEndpoint(endpointUrl);
            req.setMethod('GET');      
            Http h = new Http();
            HttpResponse res = h.send(req);
            system.debug('#09 res: ' + res.getBody());                
            Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());     
            strQuery = (String)root.get('query') + string.escapeSingleQuotes(' LIMIT ') + (maxExportRows + 1);        
            System.debug('#10 strQuery: ' + strQuery);        
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
                                col.label = col.label.replace(',', '');                            
                                lstColumn.add(col);                    
                            }    
                        }
                    }
                }
            }
            }
            System.debug('#10 lstColumn: ' + lstColumn);
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Core_MDF_ApplicationErrorMessage));
                          }
    }
    
    public PageReference exportToExcel() {        
        try {            
            loadData(false);  // The data DOES NOT have to be "cleaned" for Excel Export                        
        }
        catch (Exception e) {
            String consolidatedMessage = e.getTypeName() + ' on line# ' + e.getLineNumber() + ' : ' + e.getMessage();ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, consolidatedMessage);ApexPages.addMessage(myMsg);return null;
        }
        system.debug('fileName:'+fileName);
        contentType = 'application/vnd.ms-excel#' + fileName + '.xls';
        renderType  = '';        
        PageReference excelPage = page.Core_MDF_ListView_Export_Excel;
        excelPage.setRedirect(false);
        return excelPage;
        
    }  
    
    public PageReference exportToCSV() {        
        try {
            loadData(true);  // The data must be "cleaned" for CSV.                                    
        }
        catch (Exception e) {
            String consolidatedMessage = e.getTypeName() + ' on line# ' + e.getLineNumber() + ' : ' + e.getMessage();ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, consolidatedMessage);ApexPages.addMessage(myMsg);return null;
        }        
        // For CSV: \uFEFF
        contentType = 'text/csv#' + fileName + '.csv; charset=UTF-8';
        renderType  = '';        
        PageReference excelPage = page.Core_MDF_ListView_Export_CSV;
        excelPage.setRedirect(false);
        return excelPage;        
    } 
    
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