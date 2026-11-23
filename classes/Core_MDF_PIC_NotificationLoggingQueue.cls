/****************************************************************************************************************************************
* Class Name        : Core_MDF_PIC_NotificationLoggingQueue
* Test Class Name   : Core_MDF_PIC_Completion_NotifyBatch_Test
* Created Date      : 25/02/2024
* Description       : To log pic notification emails
* Developer         : Aditya
*****************************************************************************************************************************************/
public class Core_MDF_PIC_NotificationLoggingQueue implements Queueable, Database.AllowsCallouts {
    public List<Core_MDF_GenericClassToSendMail.EmailLogDetailsWrapper> wrapList = new List<Core_MDF_GenericClassToSendMail.EmailLogDetailsWrapper>();
    public Core_MDF_PIC_NotificationLoggingQueue(List<Core_MDF_GenericClassToSendMail.EmailLogDetailsWrapper> wrapList){
        this.wrapList = wrapList;      
    }
	public void execute(QueueableContext context) {
         try{
             if(wrapList != null && wrapList.size() > 0){
                 system.debug('wrapList.size()  '+wrapList.size());
                 // log entry object JSON to be inserted
             	String jsonString = '"Core_sObjectId__c","Core_sObjectType__c","Core_Details__c","Core_Message__c","Core_Project__c","Core_Tags__c","Core_When__c","Core_Origin__c","Core_Severity__c","Core_Scope__c"'+'\r\n';
             	//iterate over incomming wraplist
                 For(Core_MDF_GenericClassToSendMail.EmailLogDetailsWrapper wrap : wrapList){
                 String logDetails = JSON.serialize(wrap);
                 string detail = logDetails.length()> 32765? logDetails.subString(0,	32765) : logDetails;
                 // escape double quotes from details to pass to API
                 detail = detail.replace('"','""');
                 // update when in this format --> '2024-02-25T10:01:04'
                 string whn = string.valueOf(System.now().format('YYYY-MM-dd\'T\'HH:mm:ss'));
                 string msg = wrap != null && (wrap.EmailDeliverabilityStatus == Core_MDF_CCP_ConstantClass.strSuccess) ? 'Email Sent Successfully at '+ System.now() : 'Email Deliverability Failed' ;
                 string status = wrap != null && (wrap.EmailDeliverabilityStatus == Core_MDF_CCP_ConstantClass.strSuccess) ? 'Info' : 'Medium' ;
                  jsonString+='"'+ wrap.sObjectId + '","'+ wrap.sObjectId.getSObjectType().getDescribe().getName() + '","' + detail  
                      				+ '","' + msg + '","' + Label.Core_MDF_Program_Name + '","' + wrap.sObjectId + '","' + whn 
                      				+ '","' + 'Core_MDF_PIC_NotificationLoggingQueue' + '","' + status + '","' + 'Email Logging for CCP' + '"' +'\r\n';
             }
              insertBulkEmailLogEntry(jsonString);
             }
             }catch(Exception e){
                Core_MDF_CCP_UtilityClass.logError(e);
            }
    }
    public static void insertBulkEmailLogEntry(string jsonString){
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        String endPointUrl = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest';
        request.setEndpoint(endPointUrl);
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        request.setHeader('content-type', 'application/json' );
        String body = '{'+  
            '"lineEnding": "CRLF",'+ 
            '"operation": "insert",'+ 
            '"object": "Core_Log_Entry__c",'+ 
            '"contentType": "CSV"'+
            '}';
        request.setBody(body);
        Http h = new Http();
        HttpResponse resp = h.send(request);
        if(resp.getStatusCode() <= 299) {
            Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
            String jobId = (String)respMap.get('id');
            //second request to store data
            HttpRequest request1 = new HttpRequest();
            request1.setMethod('PUT');
            String endPointUrl1 = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest/' + jobId+'/batches';
            request1.setEndpoint(endPointUrl1);
            request1.setHeader('content-type', 'text/csv' );
            request1.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            request1.setBody(jsonString);
            request1.setTimeout(20000);
            Http h1 = new Http();
            HttpResponse resp1 = h1.send(request1);
            if(resp1.getStatusCode() <= 299) {
                HttpRequest request2 = new HttpRequest();
                request2.setMethod('PATCH');
                String endPointUrl2 = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest/' + jobId;
                request2.setEndpoint(endPointUrl2);
                request2.setHeader('content-type', 'application/json' );
				request2.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());                
                request2.setBody('{ "state" : "UploadComplete" }');
                Http h2 = new Http();
                HttpResponse resp2 = h2.send(request2);
            }
            
        }
    }
}