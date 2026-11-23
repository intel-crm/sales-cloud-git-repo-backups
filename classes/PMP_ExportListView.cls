public with sharing class PMP_ExportListView {
public static List<SingleColumn> lstColumn { get; set; }
    public static String strQuery;
     public  static List<sObject> recs = new List<sObject>();
    @TestVisible private static integer maxExportRows= 100000;
    
       
    @AuraEnabled 
    public static list<objWrapper> sObjectNames(){
         list<objWrapper> objWrapperList = new list<objWrapper>();
       
        Set<String> sObjectSet = new Set<String>();
       for (PMP_ListViewMapping__mdt mdt :  [SELECT MasterLabel,Hyperlink_Field_Names__c, PMP_List_View_Name__c,DeveloperName, PMP_Is_Active__c,PMP_sObjectName__c 
                                             FROM PMP_ListViewMapping__mdt WHERE PMP_Is_Active__c = TRUE]){
                                                  objWrapper objW = new objWrapper();
                                         //if(!sObjectSet.contains(mdt.PMP_sObjectName__c)){
                                                     //sObjectSet.add(mdt.PMP_sObjectName__c);
                                             objW.sobjectName = mdt.PMP_sObjectName__c;
                                             objW.hypersinkFields = mdt.Hyperlink_Field_Names__c;
                                             objWrapperList.add(objW);
                                                // }
                                                 
                          }
        return objWrapperList;
        //return new list<string>(sObjectSet);
        
    }
    
    @AuraEnabled (cacheable=true)
    public static list<listViewWrapper> listValues(String sObjectName){             
        Set<String> listViewSet = new Set<String>();
        list<listViewWrapper> oListViewWrapper = new list<listViewWrapper>();
        Id loggedUserId = UserInfo.getUserId();    
                
        try{  
            for(PMP_ListViewMapping__mdt mdt : [SELECT MasterLabel, Hyperlink_Field_Names__c,PMP_List_View_Name__c,DeveloperName, PMP_Is_Active__c,PMP_sObjectName__c 
                                                       FROM PMP_ListViewMapping__mdt WHERE PMP_sObjectName__c =:sObjectName AND PMP_Is_Active__c = TRUE]){
                                                           
                                                           listViewSet.add(mdt.PMP_List_View_Name__c);
                                                       }
          
            for(ListView lv : [SELECT Id, Name, DeveloperName,CreatedById FROM ListView
                               WHERE sObjectType = : sObjectName ORDER By Name ASC]){
                                   
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
            system.debug('Error on fetching listviews '+e.getMessage());
        }        
        system.debug('ListViewsReturned:'+oListViewWrapper);
        return oListViewWrapper; 
    }
    
    /*method: Apex method to call describe api for selected list view.
	*input: Object name and list view filter id
	*output: void */
    @AuraEnabled
    public static void listViewFilter(Id filterId, String sObjectName) {
        HttpRequest req = new HttpRequest();
         try{
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');      
        //req.setClientCertificateName(Label.PMP_Self_Signed_Cert);  
        
        String communityURL = PMP_Utility.getBaseCommunityUrl();
        communityURL = communityURL.substringBeforeLast('/') ;             
        String endpointUrl =  communityURL + '/services/data/v45.0/sobjects/' +sObjectName + '/listviews/' + filterId + '/describe';
        system.debug('endpoint:'+endpointUrl);
        req.setEndpoint(endpointUrl);
        req.setMethod('GET');      
        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug('res body:'+res.getBody());
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());     
        //get the query string from the response
        strQuery = (String)root.get('query') + ' LIMIT ' + (maxExportRows+ 1);        
        System.debug('#10 strQuery: ' + strQuery);
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
                            system.debug('lstColumn'+lstColumn);
                        }    
                    }
                }
            }
        }
         }
        catch(Exception e){
            system.debug('Error on API callout '+e.getMessage());
        }  
        
    }
    /*
    
    @AuraEnabled
    public static ID executebach(Id filterId, String sObjectName){
        Id batchjobid;
     System.debug('strQuery before fetch: ' + strQuery+sObjectName);
        if(strQuery == null){
            listViewFilter(filterId,sObjectName);
            System.debug('strQuery after fetch from inside if: ' + strQuery);
        }
         try{
             
             
            batchjobid = Database.executeBatch(new PMP_ExportListViewBatch(strQuery), 200);
            
         // lstRec = recs;
        }
        catch(Exception e){
            system.debug('Error on fetching records '+e.getMessage());
        } 
        return batchjobid;
    }
    
    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobID];
        return jobInfo;
    }
  */
    
    /*method: Apex method to fetch records for a selected list view.
	*input: Object name and list view filter id
	*output: List<sObject> */
    @AuraEnabled
    public static List<sObject> fetchRecords(Id filterId, String sObjectName){
        //fetching records based on the query.
        System.debug('strQuery before fetch: ' + strQuery+sObjectName);
        if(strQuery == null){
            listViewFilter(filterId,sObjectName);
            System.debug('strQuery after fetch from inside if: ' + strQuery);
        }
        List<sObject> lstRec = new List<sObject>();
        try{
            for(sObject sobj : Database.query(strQuery) ){
                lstRec.add(sobj);
            }
           
             
         
        }
        catch(Exception e){
            system.debug('Error on fetching records '+e.getMessage());
        } 
       return lstRec;

        
    }
    

    /*method: Apex method to fetch columns for a selected list view.
	*input: Object name and list view filter id
	*output: Map<String,String> */
    @AuraEnabled
    public static Map<String,String> fetchKeys(Id filterId, String sObjectName){
        Map<String,String> keysToLabelMap = new Map<String,String>{};
            try{
                listViewFilter(filterId, sObjectName);        
                for(SingleColumn l: lstColumn){
                    keysToLabelMap.put(l.selectListItem,l.label);
                    
                }
                
                system.debug('keys:'+keysToLabelMap);
            }
        catch(Exception e){
            system.debug('Error on fetching keys '+e.getMessage());
        } 
        return keysToLabelMap;
    }
    
    /*wrapper class to store listView details*/ 
    public class listViewWrapper{
        @AuraEnabled public string label{get;set;} 
        @AuraEnabled public string developerName{get;set;}
        @AuraEnabled public string listViewId{get;set;}
        
    }
    public class objWrapper{
        @AuraEnabled public string sobjectName{get;set;}
        @AuraEnabled public string hypersinkFields{get;set;}
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