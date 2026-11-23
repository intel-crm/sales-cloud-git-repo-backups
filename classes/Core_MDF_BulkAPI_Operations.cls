/****************************************************************************************************************************************
* Class Name  : Core_MDF_BulkAPI_Operations 
* Version     : 1.0 
* Created Date: 01-10-2023
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Mayuri Dhanjani      01-10-2023                  Bulk API calls to insert and delete share records
*******************************************************************************************************************************************************/

public without sharing class Core_MDF_BulkAPI_Operations {
    
    //Bulk API Call to delete Share Records
    public static AysncJobDetailWrapper deleteShareBulkRecords(Set<Id> dynObjectList , Set<String> hostGeo, String shareObjectName, String fieldName){
        Set<Id> shareRecordIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        Set<String> grpNames = new Set<String>();
        String rowCause = 'Manual';
        String jobId ='';
        Map<String, Object> respMap = new Map<String, Object>();
        for(Core_MDF_Partner_Group_Mapping__c pgm : [Select Id, Core_MDF_Account__c,Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c,Core_MDF_Group_Name__c 
                                                     from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Region_cd__c IN : hostGeo and Core_MDF_Type_of_Access__c ='Internal' and  Core_MDF_Inactive_Ind__c = false])
        {
            groupIds.add(pgm.Core_MDF_Group_Id__c);
        }
        
        for(Core_MDF_ProgramGeoGroupMap__mdt rec : [select id,DeveloperName, Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c from Core_MDF_ProgramGeoGroupMap__mdt where Core_MDF_Region__c IN : hostGeo])
        {
            grpNames.add(rec.Core_MDF_Group_Name__c);
            grpNames.add(rec.Core_MDF_Group_Name_RO__c);
            
        }
        
        for(Group grp : [SELECT Id, DeveloperName FROM Group where DeveloperName IN :grpNames])
        {
            groupIds.add(grp.Id);
        }
        
        String sQuery = 'SELECT Id,UserOrGroupId FROM ' + shareObjectName + 
            ' WHERE ' +  fieldName + ' IN : ' + 'dynObjectList'  + ' AND UserOrGroupId IN : '+ 'groupIds' + ' AND RowCause =: rowCause';
        
        List<Sobject> results = new List<Sobject>(Database.query(String.escapeSingleQuotes(sQuery)));
        
        for(Sobject shareRecords : results)
        {
            if(String.valueOf(shareRecords.get('UserOrGroupId')).startsWith('00G'))
            {
                shareRecordIds.add((Id)shareRecords.get('Id'));
            }
            
        }
        String requestString ='';
        //ATHR - Deeply Nested if 16209
        if(shareRecordIds.isEmpty()){
            return new AysncJobDetailWrapper(null,'Bulk API',null,null,'In Progress');
        }
            
            requestString = '"Id"'+'\r\n';
            
            for(Id sOb : shareRecordIds){
                
                requestString += '"'+sOb +'"'+'\r\n';
            }
            
            
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            //String endPointUrl = URL.getOrgDomainUrl().toExternalForm() + '/services/data/' +'v56.0' + '/jobs/ingest';  //should be replaced with named creds
            String endPointUrl = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest';  //should be replaced with named creds
            request.setEndpoint(endPointUrl);
            //request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());  //automatically handled by named creds, should be removed
            request.setHeader('content-type', 'application/json' );
            String body = '{'+  
                '"lineEnding": "CRLF",'+ 
                '"operation": "delete",'+ 
                '"object": "'+shareObjectName+'",'+ 
                '"contentType": "CSV"'+
                '}';
            
            request.setBody(body);
            Http h = new Http();
            HttpResponse resp = h.send(request);
            //ATHR - Deeply Nested if 16209
            if(resp.getStatusCode() > 299){
                return new AysncJobDetailWrapper(null,'Bulk API',null,null,'In Progress');
            }
                respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
                jobId = (String)respMap.get('id');
                
                //second request to store data
                HttpRequest request1 = new HttpRequest();
                request1.setMethod('PUT');
                String endPointUrl1Old = URL.getOrgDomainUrl().toExternalForm() + '/services/data/' +'v56.0' + '/jobs/ingest/' + jobId+'/batches';
                
                String endPointUrl1 = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest/' + jobId+'/batches';
              
                request1.setEndpoint(endPointUrl1);
                request1.setHeader('content-type', 'text/csv' );
                //request1.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
                request1.setBody(requestString);
                request1.setTimeout(20000);
                Http h1 = new Http();
                HttpResponse resp1 = h1.send(request1);
               
                if(resp1.getStatusCode() <= 299) {
                    
                    HttpRequest request2 = new HttpRequest();
                    request2.setMethod('PATCH');
                    String endPointUrl2Old = URL.getOrgDomainUrl().toExternalForm() + '/services/data/' +'v56.0' + '/jobs/ingest/' + jobId;
                   
                    String endPointUrl2 = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest/'+ jobId;
                  
                    request2.setEndpoint(endPointUrl2);
                    request2.setHeader('content-type', 'application/json' );
                    //request2.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());                
                    request2.setBody('{ "state" : "UploadComplete" }');
                    Http h2 = new Http();
                    HttpResponse resp2 = h2.send(request2);
                  
                }
                
        String jobIds = (String)respMap.get('id');
        String operation = (String)respMap.get('operation');
        String objectName = (String)respMap.get('object');
        
        AysncJobDetailWrapper wrapper = new AysncJobDetailWrapper(jobIds,'Bulk API',objectName,operation,'In Progress');
        return wrapper;
    }
    
    //Bulk API Call to Insert Share Records
    public static AysncJobDetailWrapper insertShareBulkRecords(List<sObject> shareRecordList, String shareObjectName, String parentObjId){
        String requestString ='';
        String jobId ='';
        Map<String,Object> respMap = new Map<String,Object>();
        if(!shareRecordList.isEmpty()){
            
            requestString = '"' + parentObjId + '","UserOrGroupId","RowCause","AccessLevel"'+'\r\n';
            
            for(Sobject sOb : shareRecordList){
                
                requestString += '"'+ sOb.get(parentObjId) + '","'+sOb.get('UserOrGroupId')+ '","'+sOb.get('RowCause')+ '","'+sOb.get('AccessLevel')+'"'+'\r\n';
            }
        }
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        String endPointUrlOld = URL.getOrgDomainUrl().toExternalForm() + '/services/data/' +'v56.0' + '/jobs/ingest';
        
        String endPointUrl = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest';
    
        
        request.setEndpoint(endPointUrl);
        //request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        request.setHeader('content-type', 'application/json' );
        String body = '{'+  
            '"lineEnding": "CRLF",'+ 
            '"operation": "insert",'+ 
            '"object": "'+shareObjectName+'",'+ 
            '"contentType": "CSV"'+
            '}';
        
        request.setBody(body);
        Http h = new Http();
        HttpResponse resp = h.send(request);
        
        if(resp.getStatusCode() <= 299) {
            respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
            jobId = (String)respMap.get('id');
            
            
            
            //second request to store data
            HttpRequest request1 = new HttpRequest();
            request1.setMethod('PUT');
            String endPointUrlOld171 = URL.getOrgDomainUrl().toExternalForm() + '/services/data/' +'v56.0' + '/jobs/ingest/' + jobId+'/batches';
            
            String endPointUrl1 = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest/'+ jobId+'/batches';
            

            request1.setEndpoint(endPointUrl1);
            request1.setHeader('content-type', 'text/csv' );
           // request1.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            request1.setBody(requestString);
            request1.setTimeout(20000);
            Http h1 = new Http();
            HttpResponse resp1 = h1.send(request1);
            
            if(resp1.getStatusCode() <= 299) {
                
                HttpRequest request2 = new HttpRequest();
                request2.setMethod('PATCH');
                String endPointUrlOld188 = URL.getOrgDomainUrl().toExternalForm() + '/services/data/' +'v56.0' + '/jobs/ingest/' + jobId;
               
                String endPointUrl2 = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest/' + jobId;
                
                
                request2.setEndpoint(endPointUrl2);
                request2.setHeader('content-type', 'application/json' );
                //request2.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());                
                request2.setBody('{ "state" : "UploadComplete" }');
                Http h2 = new Http();
                HttpResponse resp2 = h2.send(request2);
               
            } 
            
        }
        String jobIds = (String)respMap.get('id');
        String operation = (String)respMap.get('operation');
        String objectName = (String)respMap.get('object');
        
        aysncJobDetailWrapper wrapper = new aysncJobDetailWrapper(jobIds,'Bulk API',objectName,operation,'In Progress');
        return wrapper;
    }
    public static void insertAsyncBulkRecords(List<aysncJobDetailWrapper> asyncRecList){
        
        List<Core_MDF_Async_Job_Details__c> asyncDetailRecList = new List<Core_MDF_Async_Job_Details__c> ();
        try{
            for(aysncJobDetailWrapper asyncRec : asyncRecList)
            {
                if(String.isNotBlank(asyncRec.jobId))
                {
                    Core_MDF_Async_Job_Details__c asyncDetailRec = new Core_MDF_Async_Job_Details__c ();
                    asyncDetailRec.Core_MDF_Job_Id__c = asyncRec.jobId;
                    asyncDetailRec.Core_MDF_Job_Type_nm__c = 'Bulk API';
                    asyncDetailRec.Core_MDF_Object_txt__c = asyncRec.objectName;
                    asyncDetailRec.Core_MDF_Operation_nm__c = asyncRec.operation;
                    asyncDetailRec.Core_MDF_Status_nm__c   = 'In Progress';
                    asyncDetailRecList.add(asyncDetailRec);
                }
                
                
            }
            if(asyncDetailRecList != null && asyncDetailRecList.size() > 0)
            {
                insert asyncDetailRecList; 
            }  
            
        }
        catch(Exception e) { 
            Core_MDF_CCP_UtilityClass.logError(e); throw e;}
        
    }
    
    public static void insertAsyncBulkRecordsByPE(List<aysncJobDetailWrapper> asyncRecList)
    {
        List<Core_MDF_Bulk_Transaction__e> RecordList = new List<Core_MDF_Bulk_Transaction__e>();
        try{
            for(aysncJobDetailWrapper asyncRec : asyncRecList)
            {
                if(String.isNotBlank(asyncRec.jobId))
                {
                    Core_MDF_Async_Job_Details__c asyncDetailRec = new Core_MDF_Async_Job_Details__c ();
                    asyncDetailRec.Core_MDF_Job_Id__c = asyncRec.jobId;
                    asyncDetailRec.Core_MDF_Job_Type_nm__c = 'Bulk API';
                    asyncDetailRec.Core_MDF_Object_txt__c = asyncRec.objectName;
                    asyncDetailRec.Core_MDF_Operation_nm__c = asyncRec.operation;
                    asyncDetailRec.Core_MDF_Status_nm__c   = 'Failed';
                    asyncDetailRec.Core_MDF_Message_txt__c = 'PE';
                    
                    Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e(); 
                    evtObj.Core_MDF_JSON_Data__c = JSON.serialize(asyncDetailRec); 
                    evtObj.Core_MDF_Object_Name__c = 'Core_MDF_Async_Job_Details__c';
                    RecordList.add(evtObj);
                }
                
            }
            
            if(!RecordList.isEmpty()){
                List<Database.SaveResult> results1 = EventBus.publish(RecordList);
                for (Database.SaveResult sr : results1) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event.');
                    } 
                    else { 
                        for(Database.Error err : sr.getErrors()) { 
                            System.debug('Error returned: ' + err.getStatusCode() ); 
                        }
                    }
                }
            }
        }catch(Exception e) { 
            Core_MDF_CCP_UtilityClass.logError(e); throw e;}
    }
    
    public class AysncJobDetailWrapper
    {
        public string jobId {get;set;}
        public string jobType {get;set;}
        public string objectName { get; set; }
        public string operation { get; set; }
        public string status { get; set; }
        
        public AysncJobDetailWrapper(String jobId, String jobType, String objectName, String operation, String status){
            this.jobId = jobId;
            this.jobType = jobType;
            this.objectName = objectName;
            this.operation = operation;
            this.status = status;
        }
    }
}