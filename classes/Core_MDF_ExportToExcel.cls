public with sharing class Core_MDF_ExportToExcel {
    
    @TestVisible private static integer maxExportRows = Integer.valueOf(Label.Core_MDF_Max_export_limit);   
    @TestVisible private static integer maxFieldLength = 1000; 
    public static String logEntryMsg = '';
    public String strQuery;        
    public static string domainUrl;
    public static string pageUrl;
    public static boolean isVaildSObject;    
    public static final integer ASCII_FOR_DOUBLE_QUOTE = 34;    
    public static Boolean isPDFExportActive { get; set; }    
    Boolean isExcelExportActive { get; set; } 
    public static Boolean isMobileView { get; set; } 
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
    public static Id strFilterId; //Converted the datatype to Id as part of WW49 ATHR fix
    public String errorMsg;
    public string testendpointUrl;
    public string sanitizedEndPointUrl;
    
 public Core_MDF_ExportToExcel() { 
        try{
            //check if the page is opened from salesforce1 mobile app then display info msg else load the page.
            if(UserInfo.getUiTheme() == 'Theme4t'){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'Export not enabled for mobile app in current version.');
                ApexPages.addMessage(myMsg);
                isMobileView=true;
                return;
            }
            else{
            pageUrl=ApexPages.currentPage().getUrl();    
            objName =  String.escapeSingleQuotes(ApexPages.currentPage().getUrl().substringAfter('ObjName=').substringBefore('&'));
           //check if the objname is a valid sobject.
            for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
                 String sobjName = String.valueOf(sObjectType);
                 if (sobjName.contains(objName) ) {
                    isVaildSObject = true;
                    break;
                 }
                
            }
            String q = String.escapeSingleQuotes('SELECT Id FROM '+objName+' LIMIT '+ (maxExportRows + 1));
            List<sObject> objList = Database.query(q);
            ApexPages.StandardSetController controller = new ApexPages.StandardSetController(objList);                
            Datetime dtNow = Datetime.now();
            reportDate = dtNow.format('yyyy-MM-dd h:mm a');        
            lstlstObj = new List<List<Object>>();        
            strfilterId = controller.getFilterId();
            Boolean hasUserAccessToFilterId = false;
            List<System.SelectOption> lstSelectOption = controller.getListViewOptions();
            for (System.SelectOption so : lstSelectOption){
                if (so.getValue() == strfilterId) {
                    hasUserAccessToFilterId = true;
                    filterName = so.getLabel();                    
                    Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9\\s]');
                    Matcher matcher = nonAlphanumeric.matcher(filterName);       
                    fileName = matcher.replaceAll('');
                    fileName = fileName.replace(' ', '_');
                    break;
                } 
            }
            if(!hasUserAccessToFilterId) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Core_MDF_Int_ExportListView_Access_Error));
                isMobileView = true;
                return;
            }
            loadFilterFields();
            //US523018: PRB000091900 : Unable to export raw reports (CSV,xlsx) from CLAIM list page            
            //domainUrl = (String.isNotBlank(domainUrl) && domainUrl.lastIndexOf('/') == domainUrl.length()-1) ? domainUrl : String.valueOf(URL.getSalesforceBaseUrl().toExternalForm()) +'/';            
            //returnURL = domainUrl+'lightning/o/'+objName+'/list?filterName='+strfilterId;
            testendpointUrl = Label.Core_MDF_Export_URL + objName + '/list?filterName='+strfilterId;
            sanitizedEndPointUrl = String.escapeSingleQuotes(testendpointUrl);
            if(strQuery != null && strQuery != ''){        
            Integer idx = strQuery.indexOf(' FROM ');
            String strCountQuery = string.escapeSingleQuotes('SELECT Id ') + strQuery.substring(idx);
            //strCountQuery = String.escapeSingleQuotes(strCountQuery);        
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
        }
     catch(Exception e){
         //Core_MDF_CCP_UtilityClass.logError(e);
         Core_MDF_Error_Logging__e el = new Core_MDF_Error_Logging__e();
         el.Core_MDF_Details_txt__c = e.getMessage();
         el.Core_MDF_Apex_Class_Name_Txt__c = 'Core_MDF_ExportToExcel';
         el.Core_MDF_Exception_Message_Txt__c = Core_MDF_CCP_UtilityClass.getErrorDetails(e);
         el.Core_MDF_Severity_txt__c = 'Critical';
         el.Core_MDF_Project_nm__c = Label.Core_MDF_Program_Name;
         el.Core_MDF_Tag_txt__c = 'ExportToExcel';
         el.Core_MDF_Object_Name_Nm__c = e.getStackTraceString().substringBefore(':');
         EventBus.publish(el);
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Core_MDF_ApplicationErrorMessage));
     }
    }    
    public PageReference returnToPage() {   
        PageReference returnPage = new PageReference(sanitizedEndPointUrl);
        returnPage.setRedirect(true);
        return returnPage;
    }  
    
    public void loadData(Boolean cleanData) {        
        try{
            List<Object> lstObjPage = new List<Object>();        
            integer counter = 0;
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
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Core_MDF_ApplicationErrorMessage));
        }
    }
    
    
    public Map<String, Object> scrubDataFields(sObject sObj, List<SingleColumn> lstSingleColumn) {        
        Map<String, Object> mapRow = new Map<String, Object>();        
        sObject sObjParent;                
        List<String> lstFieldName;
         
        String strFieldValue; 
        
        try{
            for (SingleColumn sc : lstSingleColumn) {                            
                if (sc.fieldNameOrPath.contains('.')) {
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
                    //ATHR - Deeply Nested if 16209
                    if (strFieldValue.length() > 0 && strFieldValue.charAt(0) != ASCII_FOR_DOUBLE_QUOTE) {
                        //if (strFieldValue.charAt(0) != ASCII_FOR_DOUBLE_QUOTE) {
                            strFieldValue = '"' + strFieldValue + '"';                    
                        //}                               
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
            domainUrl = Label.Core_MDF_domianURL_Export;
            //US523018: PRB000091900 : Unable to export raw reports (CSV,xlsx) from CLAIM list page
            domainUrl = (domainUrl.lastIndexOf('/') == domainUrl.length()-1) ? domainUrl : domainUrl+'/';
            
            //SF Fix-Ealisha:start
            List<String> whiteListedObjApiNameList = new List<String>();
            // for(Core_MDF_ListView_Group_Mapping__mdt mdt : [SELECT Core_MDF_Label_txt__c, Core_MDF_Active_ind__c, Core_MDF_SObject_txt__c,Core_MDF_Whitelisted_Object__c FROM Core_MDF_ListView_Group_Mapping__mdt WHERE Core_MDF_Whitelisted_Object__c=true and Core_MDF_Active_ind__c=true]){
            //                                                 whiteListedObjApiNameList.add(mdt.Core_MDF_SObject_txt__c); 
            //                                                 }
            //updated the code for the change of Custom Metadata to Custom Settings - Akanksha(WW32-2024)
            for(Core_MDF_List_View_Group_Mapping__c itrOnListViewMapping : Core_MDF_List_View_Group_Mapping__c.getall().values()){
                if(itrOnListViewMapping.Core_MDF_Whitelisted_Object__c && itrOnListViewMapping.Core_MDF_Active_ind__c){
                    whiteListedObjApiNameList.add(itrOnListViewMapping.Core_MDF_SObject_txt__c); 
                }
            }
            if((isVaildSObject && whiteListedObjApiNameList.contains(objName)) /*&& (strfilterId.length() == 15 || strfilterId.length() == 18)*/){
               endpointUrl = domainUrl + Label.Core_MDF_Describe_API_URL4 +objName + Label.Core_MDF_Describe_API_URL2 + strfilterId + Label.Core_MDF_Describe_API_URL3;
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Core_MDF_Export_Whitelisting_Error_Message));
            }
            //SF Fix-Ealisha:end
            if(endpointUrl != ''){
            req.setEndpoint(endpointUrl);
            req.setMethod('GET');      
            Http h = new Http();
            HttpResponse res = h.send(req);             
            Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());     
            strQuery = (String)root.get('query') + string.escapeSingleQuotes(' LIMIT ') + (maxExportRows + 1);        
                    
            // This HAS to be reset every iteration.
            lstColumn = new List<SingleColumn>();        
            //Parsing JSON string to get the column details    
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null){ 
                //ATHR - Deeply Nested if 16209
                if(parser.getCurrentToken() != JSONToken.START_ARRAY) {
                    continue;
                }
                //if(parser.getCurrentToken() == JSONToken.START_ARRAY) {       
                    while (parser.nextToken() != null) {
                        //ATHR - Deeply Nested if 16209
                        if (parser.getCurrentToken() != JSONToken.START_OBJECT) {
                            continue;
                        }
                        //if (parser.getCurrentToken() == JSONToken.START_OBJECT) {                        
                            SingleColumn col = (SingleColumn)parser.readValueAs(SingleColumn.class);
                        	if(col == null || col.hidden == null || col.label == null || col.hidden == true || col.fieldNameOrPath == NULL || col.fieldNameOrPath.contains('Clone')) {
                                continue;
                            }
                            //if(col.hidden == false && col.fieldNameOrPath != NULL && !col.fieldNameOrPath.contains('Clone')) {                                        
                                col.label = col.label.replace(',', '');                            
                                lstColumn.add(col);                    
                            //}    
                        //}
                    }
                //}
            }
            }
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