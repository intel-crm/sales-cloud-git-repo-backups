/****************************************************************************************************
Apex Class Name : SWS_MultipleCouponGenerationBatch
Version         : 1.0 
Created Date    : 26/6/2024
Test Class      : SWS_MultipleCouponGenerationBatchTest
Function        : This class is used to make api call for coupon generation in batches
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Saileela B               26/6/2024                Created
*****************************************************************************************************/
public without sharing class SWS_MultipleCouponGenerationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful {    
    private static final String LOG_ENTRY_ORIGIN   = 'SWS_MultipleCouponGenerationBatch';
    private static final String LOG_ENTRY_SCOPE    = 'Failed to get bulk Coupon';
    private static final String LOG_ENTRY_SEVERITY = 'Medium';
    public List<String> recordList;
    private static List<String> missingRequiredFieldList = new List<String>();
    private Map<String, SWS_Cloud_Credit_Request__c> responseWrapMap = new Map<String, SWS_Cloud_Credit_Request__c>();
    private Map<String,RecordWrapper> recordWrapMap = new Map<String,RecordWrapper>();
    public static integer unsuccessRequest = 0;
    public static integer missingFieldsCount = 0;
    List<SWS_Cloud_Credit_Request__c> credRecList = new List<SWS_Cloud_Credit_Request__c>();
    
    public SWS_MultipleCouponGenerationBatch(List<string> recordList){
        this.recordList = recordList;
    }   
    
    public Database.QueryLocator start(Database.BatchableContext batchContext) { 
        String queryString = 'SELECT Id,Name,SWS_Full_Name__c,SWS_Submitter_Name__c, SWS_Request_Status__c,SWS_Request_Type__c,SWS_Email__c,SWS_Cost_Center__c,SWS_First_Name__c, SWS_Last_Name__c,SWS_Submitter_Email__c,SWS_Submitter_Requster_Email__c,SWS_Country__c,SWS_Job_Title__c, SWS_Company_Name__c, SWS_Intel_BU_Field_Sales_Contact__c,SWS_Salesforce_Opportunity_ID__c,SWS_HW_Compute_Platform_PL__c,SWS_HW_Compute_Quantity__c, SWS_Custom_Coupon_Request__c, SWS_Use_Case_Details__c, SWS_Coupon_Type__c, SWS_Compute_Service_Requirements__c, SWS_Coupon_Value__c,SWS_No_Of_User__c,SWS_Expiry_Date__c,SWS_Is_Standard__c,SWS_Processing_Team__c,SWS_Use_Case__c,SWS_Community_Program_Name__c,SWS_Community_Program_Coupon_Type__c,SWS_Event_Start_Date__c,SWS_Event_End_Date__c,SWS_Number_of_Participants__c,SWS_Event_Compute_Environment_Details__c,SWS_Event_Country_Name__c,CreatedById ' +
            'FROM SWS_Cloud_Credit_Request__c WHERE Id IN:recordList AND SWS_Request_Status__c NOT IN (\'Coupon_Generated\')';
        return Database.getQueryLocator(queryString);        
    }
    
    public void execute(Database.BatchableContext batchContext, List<sObject> creditRequestList) {   
        credRecList = ((List<SWS_Cloud_Credit_Request__c>)creditRequestList);
        if(creditRequestList.isEmpty()){
            return;
        }
        for(sObject rec : creditRequestList){   
            RecordWrapper recordWrap = new RecordWrapper();
            recordWrap.recordId = (String) rec.get('Id');
            recordWrap.name = (String)rec.get('Name');
            Date expiryDate = (Date) rec.get('sws_expiry_date__c');
	    SWS_ValidateRequest.bypassUpdate = true;
            If(expiryDate < System.Today()){
                String ExpiryMessage = SWS_Core_CRM_Labels__c.getValues('ExpiryDateMessage')?.SWS_Value__c;
                recordWrap.result = 'Error';
                recordWrap.message = ExpiryMessage != null ? ExpiryMessage : '';
                recordWrapMap.put((String) rec.get('Id'), recordWrap);
			}else{
                     
                missingRequiredFieldList = SWS_ValidateRequest.validateRequest(new List<sObject>{rec}); 
                if(missingRequiredFieldList.isEmpty()){
                    SWS_IDCIntegration.bypassUpdate = true;
                    SWS_IDCIntegration.requestObj= (SWS_Cloud_Credit_Request__c) rec;
                    SWS_IDCIntegration.getCoupon(rec);
                    responseWrapMap.put((String) rec.get('Id'), SWS_IDCIntegration.requestObj); 
                    recordWrap.result = '';
                    recordWrap.message = '';               
                }else if(!missingRequiredFieldList.isEmpty()){
                    recordWrap.result = 'Missing required fields';
                    recordWrap.message = String.join(missingRequiredFieldList,';').replace('\n','');             
                }
                recordWrapMap.put((String) rec.get('Id'),recordWrap);            
            }
        }
        if(!responseWrapMap.isEmpty()){
            updateRecords();
        }
    }
    
    public void finish(Database.BatchableContext bc){
        List<SWS_Cloud_Credit_Request__c> requestList = new List<SWS_Cloud_Credit_Request__c>();
        if(!responseWrapMap.isEmpty()){
            for(String reqId : responseWrapMap.keySet()){
                if(responseWrapMap.get(reqId)?.SWS_Request_Status__c == 'Coupon_Generated'){
                    requestList.add(responseWrapMap.get(reqId));               
                }               
            }	
        }
        
        SWS_SendEmailController.requestBatchList = requestList;
        SWS_SendEmailController.sendEmail('','SWS_SendCouponDetails');
        if(!recordWrapMap.isEmpty()){            
            SWS_SendEmailController.attachment.add(generateCSVFile());
            EmailTemplate template = SWS_SendEmailController.getEmailTemplate('SWS_MultipleCouponGeneration');
            String subject = template.Subject;
            SWS_SendEmailController.bypassUpdate = true;
            Messaging.SingleEmailMessage sendEmail = SWS_SendEmailController.getRenderEmailContent(template.Id, null); 
            subject = subject.replace('[TOTAL_NUMBER]', String.valueOf(this.recordList.size()));          
            String body = sendEmail.getHtmlBody();
            body = body.replace('[TOTAL_NUMBER]', String.valueOf(this.recordList.size()));
            body = body.replace('[SUCCESS]', String.valueOf(requestList.size()));
            body = body.replace('[UNSUCCESS]', String.valueOf(this.recordList.size() - requestList.size()));
            sendEmail.setHtmlBody(body);
            sendEmail.setSubject(subject);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{sendEmail});
        }        
    } 
    
    private void updateRecords(){
        List<SWS_Cloud_Credit_Request__c> requestList = new List<SWS_Cloud_Credit_Request__c>();
        for(String reqId : responseWrapMap.keySet()){
            if(responseWrapMap.get(reqId)?.SWS_Request_Status__c == 'Coupon_Generation_in_Progress'){
                RecordWrapper wrap = recordWrapMap.get(reqId);
                wrap.result = 'Failed to generate';
                wrap.message = responseWrapMap.get(reqId)?.SWS_Error__c;
                recordWrapMap.put(reqId, wrap);
            }
            requestList.add(responseWrapMap.get(reqId));
        }
        if(requestList.size() > 0){
            SWS_RetryOperationUtility updateRecord = new SWS_RetryOperationUtility(requestList);
            for(Integer i = 0; i < SWS_RetryOperationUtility.results.size(); i++){
                Database.SaveResult sr = SWS_RetryOperationUtility.results[i];
                RecordWrapper wrap = recordWrapMap.get(SWS_RetryOperationUtility.results[i].getId());
                if (!sr.isSuccess()) {
                    wrap.result = 'Failed to Update Record';
                    wrap.message = SWS_Utility.getErrorAsString(sr.getErrors(),LOG_ENTRY_ORIGIN);
                }else if(String.isBlank(wrap.result)){                  
                    wrap.result = 'Coupon Generated';
                    wrap.message = '';
                }
                recordWrapMap.put(SWS_RetryOperationUtility.results[i].getId(), wrap);
            }
        }     
    }
    
    private Messaging.EmailFileAttachment generateCSVFile(){
        String csvContent = 'Id,Record Number,Result,Error Message\n';
        if(!recordWrapMap.isempty()){
            for (RecordWrapper rw : recordWrapMap.values()) {
                csvContent = csvContent + '' + rw.recordId + ',' + rw.name + ',' + rw.result + ',' + rw.message + '\n';
            }             
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setContentType('text/csv');
            attachment.setFilename('Credit Request List' +'.csv');
            attachment.setInline(true);
            attachment.Body = (Blob.valueOf(csvContent));
            return attachment;
        }
        return null;        
    }     
    
    public class RecordWrapper {
        public String recordId;
        public String name;
        public String result;
        public String message;
    }
}