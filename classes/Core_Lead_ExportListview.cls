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
            strQuery = (String)root.get('query') + string.escapeSingleQuotes(' LIMIT ') + (maxExportRows+ 1);  
            lstColumn = new List<SingleColumn>();
            
            //Parsing JSON string to get the column details    
            System.JSONParser parser = JSON.createParser(res.getBody());
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
        List<sObject> lstRec = new List<sObject>();
        try{
            lstRec = Database.query(strQuery);
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