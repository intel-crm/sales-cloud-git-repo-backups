public class Pricing_MyDeals_Integration_Queueable implements Queueable, Database.AllowsCallouts {
    
    public List<Id> OBMIds = new List<Id>();
    public integer calloutCounter = 0;
    public Map<String,Id> sObjectNameToRecordIdMap = new Map<String,Id>();
    public List<Pricing_Integration_Staging__c> obmLst = new List<Pricing_Integration_Staging__c>();
    public List<Pricing_Integration_Staging__c> obmLstFailed = new List<Pricing_Integration_Staging__c>();
    public List<Core_Integration_Inbound_Message__c> iimList = new List<Core_Integration_Inbound_Message__c>();
    public List<Exception> expLst = new List<Exception>();
    
    public Pricing_MyDeals_Integration_Queueable(List<Id> OBMIds){
        this.OBMIds = OBMIds;
    }
    
    public void execute(QueueableContext context) {
        for(Pricing_Integration_Staging__c obms : [SELECT id,Name,Pricing_Payload__c,Pricing_Retry_Number__c,Pricing_Status__c, Pricing_Bulk_ChangeRequest_chk__c FROM Pricing_Integration_Staging__c WHERE Id In :OBMIds]){
            If(!obms.Pricing_Bulk_ChangeRequest_chk__c && calloutCounter <= 50){
                sendPayload(obms, 0);   
                OBMIds.remove(OBMIds.indexOf(obms.id));
            }
        }
        if(!iimList.isEmpty()){
            Database.SaveResult[] res= Database.insert(iimList, true);
        }
        if(!obmLst.isEmpty()){
            update obmLst;
        }
        if(!obmLstFailed.isEmpty()){
            createLogEntry();
        }
        if(!expLst.isEmpty()){
            createExceptionLog();
        }
        if(calloutCounter > 50){
            System.enqueueJob(new Pricing_MyDeals_Integration_Queueable(OBMIds));
        }
    }
    
    public void updateStatus(Pricing_Integration_Staging__c obm, String status){
        obm.Pricing_Status__c = status;
        obm.Pricing_Retry_Number__c = (obm.Pricing_Status__c == 'Successful')?obm.Pricing_Retry_Number__c:(obm.Pricing_Retry_Number__c==null) ? 1 : obm.Pricing_Retry_Number__c+1;
        obmLst.add(obm);
        //update obm;
        if(obm.Pricing_Status__c == 'Failed' && obm.Pricing_Retry_Number__c > 2) {
            obmLstFailed.add(obm);
            //createLogEntry();
        }
    }
    
    public void sendPayload(Pricing_Integration_Staging__c obm, Integer retryCounter){
        try{
            if(retryCounter==3){
                updateStatus(obm, 'Failed');
                return; 
            }            
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp);
            return;
        }
        
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:APIGEE_MyDeals');
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');            
            req.setBody(obm.Pricing_Payload__c);
            HttpResponse resp = new Http().send(req);
            calloutCounter++;
            if(resp.getStatus() == 'SUCCESS' || resp.getStatus() == 'OK'){
                system.debug('Response==>'+resp.getBody());
                insertInboundMessage(resp.getBody());
                updateStatus(obm, 'Successful');            	
            }else{
                retryCounter++;                
                sendPayload(obm,retryCounter);  
            }            
        }catch(Exception exp){
            retryCounter++;            
            sendPayload(obm,retryCounter);
            //Pricing_Tender_Utility.logError(exp);
            expLst.add(exp);
            return;
        }    
    }
    
    public void insertInboundMessage(String payload){
        try{
            Pricing_JSONString jsonMap = (Pricing_JSONString) System.JSON.deserialize(payload, Pricing_JSONString.class);
            Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
            String tag = jsonMap.RecordDetails.Quote.Id != null ? jsonMap.RecordDetails.Quote.Id + ' - ' : '';
            if(jsonMap.RecordDetails.Quote.QuoteLine != null && jsonMap.RecordDetails.Quote.QuoteLine.Size() > 0){
                tag += jsonMap.RecordDetails.Quote.QuoteLine[0].Id;
            } 
            iim.Core_Payload__c = JSON.serialize(jsonMap);
            iim.Core_Message_Type__c = jsonMap.Header.target_system;
            iim.Core_Processing_Status__c = 'Successful';
            iim.Core_Error_Code__c = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200;
            iim.Core_Source_System__c = jsonMap.Header.source_system;
            iim.Core_Tags__c = tag;
            iimList.add(iim);
            //Database.SaveResult[] res= Database.insert(iimList, true);
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp);
        }
    }
    
    public void createLogEntry() {
        Map<String,String> errorMap = new Map<String,String>();
        Map<String,Id> sObjectNameToRecordIdMap = new Map<String,Id>();
        for(Pricing_Integration_Staging__c obm: obmLst){
            errorMap.put(obm.Name,Label.Pricing_Tender_Staging_Outbound_Failed_Error);
            sObjectNameToRecordIdMap.put(obm.Name,obm.id);
        }
        List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
        if(!errorMap.isEmpty()){
            logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectIntegration(errorMap,sObjectNameToRecordIdMap,'Critical'));
        }
        if(logEntryList.size() > 0){
            insert logEntryList;    
        }
    }
    
    public void createExceptionLog(){
        Map<String, String> coreLogMap = new Map<String, String>();
        for(Exception e : expLst){
            Id exceptionRecordId =  Pricing_Tender_Utility.getRecordId(e);
            String sObjType;
            String objectName;
            if(exceptionRecordId != null) {
                sObjType = exceptionRecordId.getSObjectType().getDescribe().getName();
            }
            String subject = Label.Pricing_IQR_Support_Email_Subject + ' ' +  objectName + ' ' + 'sObject Id: ' + exceptionRecordId;
            coreLogMap.put('Core_Details__c', Pricing_Tender_Utility.getErrorDetails(e));
            coreLogMap.put('Core_Message__c', Label.Pricing_IQR_SFDC_Environment + ': ' + subject);
            coreLogMap.put('Core_Origin__c', Label.Pricing_IQR_Program_Name);
            coreLogMap.put('Core_Project__c',Label.Pricing_IQR_Program_Name);
            coreLogMap.put('Core_Scope__c',e.getStackTraceString().substringBefore(':'));
            coreLogMap.put('Core_Severity__c', 'Critical');
            coreLogMap.put('Core_Support_Email__c', Label.Pricing_IQR_Support_Email);
            coreLogMap.put('Core_Support_Link__c', Label.Pricing_IQR_Support_Link);
            coreLogMap.put('Core_Tags__c', '') ;
            coreLogMap.put('Core_sObjectId__c', exceptionRecordId);
            coreLogMap.put('Core_sObjectType__c', sObjType);
        }
        Pricing_Tender_Utility.createLogEntry(coreLogMap);
    }
}