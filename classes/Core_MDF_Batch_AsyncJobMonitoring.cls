public class Core_MDF_Batch_AsyncJobMonitoring implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{

   public static List<Core_MDF_Async_Job_Details__c> updatedList= new List<Core_MDF_Async_Job_Details__c>();
   public Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            String status ='In Progress';
            String query = 'select id,Name,Core_MDF_Job_Id__c, Core_MDF_Message_txt__c, Core_MDF_Object_txt__c, Core_MDF_Operation_nm__c, Core_MDF_Status_nm__c' + ' From Core_MDF_Async_Job_Details__c ' + ' WHERE Core_MDF_Status_nm__c =: status order by CreatedDate DESC' + ' LIMIT 40';
            
            return Database.getQueryLocator(String.escapeSingleQuotes(query)); 
            
        } catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
        
    } 
    public void execute(Database.BatchableContext bc, List<sObject> scope) {//log entries
    
        List<Core_MDF_Async_Job_Details__c> asyncRecordList = (List<Core_MDF_Async_Job_Details__c>) scope;   
        for(Core_MDF_Async_Job_Details__c asyncRec : asyncRecordList)
        {
                String jobId =  asyncRec.Core_MDF_Job_Id__c;
                
                HttpRequest request3 = new HttpRequest();
                request3.setMethod('GET');
                String endPointUrl3 = URL.getOrgDomainUrl().toExternalForm() + '/services/data/' +'v56.0' + '/jobs/ingest/' + jobId + '/failedResults';
                request3.setEndpoint(endPointUrl3);
                request3.setHeader('content-type', 'application/json' );
                request3.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());                
                Http h3 = new Http();
                HttpResponse resp3 = h3.send(request3);
                system.debug('Response :- '+resp3.getBody());
                String rep = resp3.getBody();
                List<String> respList = rep.split('\n');
                 system.debug('Size- '+ respList.size());
                if(respList.size() >1)
                {
                //asyncRec.Core_MDF_Message__c = respList[1].split(',')[1] + ' ' + String.valueOf((respList.size() -1));
                asyncRec.Core_MDF_Message_txt__c =  String.valueOf((respList.size() -1)) + ' ' + 'Records Processed';
                asyncRec.Core_MDF_Status_nm__c   = 'Failed';
                    updatedList.add(asyncRec);
               }
               else
               {
                HttpRequest request4 = new HttpRequest();
                request4.setMethod('GET');
                String endPointUrl4 = URL.getOrgDomainUrl().toExternalForm() + '/services/data/' +'v56.0' + '/jobs/ingest/' + jobId + '/successfulResults';
                request4.setEndpoint(endPointUrl4);
                request4.setHeader('content-type', 'application/json' );
                request4.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());                
                Http h4 = new Http();
                HttpResponse resp4 = h4.send(request4);
                system.debug('Response :- '+resp4.getBody());
                String rep1 = resp4.getBody();
                List<String> respList1 = rep1.split('\n');
                   
                   if(respList1.size() >1)
                   {
                       System.debug('Inside->');
                        //asyncRec.Core_MDF_Message__c = respList1[1].split(',')[1] + ' ' +String.valueOf((respList1.size() -1)) + 'Records Inserted';
                        asyncRec.Core_MDF_Message_txt__c = String.valueOf((respList1.size() -1)) + ' ' +'Records Processed';
                        asyncRec.Core_MDF_Status_nm__c   = 'Success';
                       updatedList.add(asyncRec);
                   }

               } 
            
            
    }
    DataBase.update(updatedList);
    }
    public void finish(Database.BatchableContext bContext) {
   
        
    }
    
}