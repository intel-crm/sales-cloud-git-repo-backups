/****************************************************************************************************
Apex Class Name : SWS_IDCIntegration
Version         : 1.0 
Test Class		: SWS_IDCIntegrationTest,SWS_IDCIntegrationMockTest
Created Date    : 2024-03-28
Function        : Handle Integration with IDC application
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bishal Singh               2024-03-28                Created
*****************************************************************************************************/
public without sharing class SWS_IDCIntegration {
    private static final String LOG_ENTRY_ORIGIN   = 'SWS_IDCIntegration';
    private static final String LOG_ENTRY_SCOPE    = 'Failed to get Coupon';
    private static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static String payload;
    public static SWS_Cloud_Credit_Request__c requestObj;
    public static SWS_IDCResponseWrapper wrapper;
    public static Long startTime;
    public static Long endTime;
    private static Double timeDifference;
    private static List<String> failureResponse = new List<String>();
    private static Database.SaveResult saveResult;
    public static Boolean bypassUpdate = false;
    public static HttpResponse response = new HttpResponse();
    public static string  custJustification = '';
    public static string  custEmail = '';

    /************************************************************************************************************
    *Method Name : getCoupon
    *Created Date: 2024-03-28
    *Author: Bishal Singh
    *Description : Convert this to invocable method to call this from flow.
    ************************************************************************************************************/
    @InvocableMethod(label='Get IDC Coupon' description='Request IDC Coupon from SWS')
    public static List<String> getCoupon(List<SObject> record){        
        SObject rec = record[0];
        String msg = '';
        if (rec.get('SWS_Coupon_Code__c') != null) {
            msg = SWS_Core_CRM_Labels__c.getValues('CouponGeneratedMessage')?.SWS_Value__c;
            failureResponse.add(msg != null ? msg : '');
        } else if ((Date)rec.get('sws_expiry_date__c') < System.Today()) {
            msg = SWS_Core_CRM_Labels__c.getValues('ExpiryDateMessage')?.SWS_Value__c;
            failureResponse.add(msg != null ? msg : '');
        } else {
            requestObj = (SWS_Cloud_Credit_Request__c) rec;
            getCoupon(rec);
        }
        return failureResponse;  
    }
    
    /************************************************************************************************************
    *Method Name : getCoupon
    *Created Date: 2024-03-28
    *Author: Bishal Singh
    *Description : Future callout to getCoupon 
    ************************************************************************************************************/
    public static void getCoupon(SObject recordId) {
        String getCouponURL = SWS_Core_CRM_Labels__c.getValues('GenerateCoupon') != null ? SWS_Core_CRM_Labels__c.getValues('GenerateCoupon').SWS_Value__c : '';
        String reqtype = (String)recordId.get('SWS_Request_Type__c');
        if(reqtype == null){
            custJustification = SWS_Core_CRM_Labels__c.getValues('One_time_external_event')?.SWS_Value__c;
        }else{
            custJustification = SWS_Core_CRM_Labels__c.getValues((String)recordId.get('SWS_Request_Type__c'))?.SWS_Value__c;
        }   
        custEmail = (String)recordId.get('SWS_Email__c');
       	if(requestObj == null || String.isBlank(getCouponURL)){
            return;
        }
        payload = createPayload();
        system.debug('payload==>'+payload);
        if(!String.isBlank(payload)){
            String endpoint = 'callout:IDC_Credit_Request_NC' + getCouponURL;
            HttpRequest httpReq = new HttpRequest();
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setEndpoint(endpoint);
            httpReq.setMethod('POST');
            httpReq.setBody(payload);
            Http http = new Http();
            startTime = (Datetime.now().getTime());
            response = http.send(httpReq);
            endTime = (Datetime.now().getTime());
            if(response.getStatusCode() == 200){
                wrapper = new SWS_IDCResponseWrapper().parse(response.getBody());
            }
            updateRequestRecord(response,wrapper);            
        }
    }
    
    /************************************************************************************************************
    *Method Name : createPayload
    *Created Date: 2024-03-28
    *Author: Bishal Singh
    *Description : Create payload for IDC.
    ************************************************************************************************************/
    private static String createPayload() {
    Map<String, FieldDetail> requestMapping = getRequestMapping();
    JSONGenerator jsGen = JSON.createGenerator(true);
    jsGen.writeStartObject();

    for (String f : requestMapping.keySet()) {
        FieldDetail fieldDetail = requestMapping.get(f);
        Object fieldValue = String.isBlank(fieldDetail.fieldApiName) ? null : requestObj.get(fieldDetail.fieldApiName);

        switch on fieldDetail.fieldType {
            when 'Text' {
                handleTextField(jsGen, f, fieldValue);
            }
            when 'Number' {
                handleNumberField(jsGen, f, fieldValue);
            }
            when 'DateTime' {
                handleDateTimeField(jsGen, f, fieldValue);
            }
            when 'Boolean' {
                handleBooleanField(jsGen, f, fieldValue);
            }
            when 'TextArea' {
                handleTextAreaField(jsGen, f, fieldValue);
            }
        }
    }

        jsGen.writeEndObject();
        jsGen.close();
        return jsGen.getAsString();
    }

        private static void handleTextField(JSONGenerator jsGen, String fieldName, Object fieldValue) {
            String textVal = (Label.SWS_IDCCouponCreator != null) ? Label.SWS_IDCCouponCreator : (String) fieldValue;
            if (textVal != null) {
                jsGen.writeStringField(fieldName, textVal);
            }
            jsGen.writeStringField('justification', custJustification == null ? '' : custJustification);
            jsGen.writeStringField('created_for', custEmail == null ? '' : custEmail);
        }
        
        private static void handleNumberField(JSONGenerator jsGen, String fieldName, Object fieldValue) {
            jsGen.writeStringField(fieldName, fieldValue == null ? '' : String.valueOf(fieldValue));
        }
        
        private static void handleDateTimeField(JSONGenerator jsGen, String fieldName, Object fieldValue) {
            Datetime dateTi = (fieldValue == null) ? System.now() : DateTime.newInstanceGmt(
                (Date.newInstance(((Date) fieldValue).year(), ((Date) fieldValue).month(), ((Date) fieldValue).day())),
                Time.newInstance(23, 59, 59, 0)
            );
            jsGen.writeDateTimeField(fieldName, dateTi);
        }
        
        private static void handleBooleanField(JSONGenerator jsGen, String fieldName, Object fieldValue) {
            Boolean b = (Boolean) fieldValue;
            jsGen.writeBooleanField(fieldName, b);
        }
        
        private static void handleTextAreaField(JSONGenerator jsGen, String fieldName, Object fieldValue) {
            jsGen.writeStringField(fieldName,fieldValue == null ? '' : String.valueOf(fieldValue));
        }
 
    
    /************************************************************************************************************
    *Method Name : updateRequestRecord
    *Created Date: 2024-03-28
    *Author: Bishal Singh
    *Description : Update record based on IDC Response.
    ************************************************************************************************************/
    private static void updateRequestRecord(HttpResponse response,SWS_IDCResponseWrapper wrapper){
        requestObj.SWS_Submitted_By__c = UserInfo.getUserId();
        requestObj.SWS_Submitted_On__c = System.now();
        requestObj.SWS_coupon_request__c = payload;
        requestObj.SWS_coupon_response__c = response.getbody();
        if(response.getStatusCode() != 200){
            String getErrorMessage = SWS_Core_CRM_Labels__c.getValues(response.getStatusCode().format()) != null ? SWS_Core_CRM_Labels__c.getValues(response.getStatusCode().format()).SWS_Value__c : SWS_Core_CRM_Labels__c.getValues('DefaultMessage').SWS_Value__c;
            failureResponse.add(getErrorMessage);
            requestObj.SWS_Request_Status__c = 'Coupon_Generation_in_Progress';
            requestObj.SWS_Error__c = getErrorMessage;
            requestObj.SWS_IDC_Error_Time__c = DateTime.now();
	        requestObj.SWS_IDCErrorForAdmin__c = 'Response Code => ' + response.getStatusCode() + ' => ' + response.getBody();
        }else if(response.getStatusCode() == 200){
            timeDifference = (endTime - startTime).intValue();
            Double timeTaken  = timeDifference / 1000;
            requestObj.SWS_Coupon_Code__c = wrapper.code ;
            requestObj.SWS_Coupon_Created_On__c = wrapper.created;
            requestObj.SWS_Coupon_Creator__c = wrapper.creator;
            requestObj.SWS_Coupon_Expiration_Date__c = wrapper.expires ;
            requestObj.SWS_Coupon_Valid_From__c = wrapper.start ;
            requestObj.SWS_Coupon_Amount__c = wrapper.amount;
            requestObj.sws_no_of_user__c = wrapper.numUses;
            requestObj.SWS_Request_Status__c = 'Coupon_Generated';
            requestObj.SWS_Locked__c = true;
            requestObj.SWS_IDC_Response_Time__c = timeTaken;          
        }
        if(!bypassUpdate){
            saveResult =  Database.update(requestObj,false);
            if(saveResult.isSuccess() && requestObj.SWS_Request_Status__c == 'Coupon_Generated'){
                SWS_SendEmailController.sendEmail(requestObj.Id, 'SWS_SendCouponDetails');
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : getRequestMapping
    *Created Date: 2024-03-28
    *Author: Bishal Singh
    *Description : Method to create map of field details to send to IDC.
    ************************************************************************************************************/
    private static Map<String,FieldDetail> getRequestMapping(){
        Map<String,FieldDetail> requestMapping=new Map<String,FieldDetail>();
        requestMapping.put('amount',new FieldDetail('sws_coupon_value__c','Number'));
        requestMapping.put('creator',new FieldDetail('','Text'));
        requestMapping.put('expires',new FieldDetail('sws_expiry_date__c','DateTime'));
        requestMapping.put('isStandard',new FieldDetail('sws_is_standard__c','Boolean'));
        requestMapping.put('numUses',new FieldDetail('sws_no_of_user__c','Number'));
        requestMapping.put('start',new FieldDetail('','DateTime'));
        requestMapping.put('notes',new FieldDetail('SWS_Compute_Service_Requirements__c','TextArea'));
        return requestMapping;
    }
    
    /************************************************************************************************************
    *Class Name : FieldDetail
    *Created Date: 2024-03-28
    *Author: Bishal Singh
    *Description : Wrapper class to create field details for JSON.
    ************************************************************************************************************/
    public class FieldDetail{
        private String fieldApiName;
        private String fieldType;
        
        public FieldDetail(String fieldApiName,String fieldType){
            this.fieldApiName=fieldApiName;
            this.fieldType=fieldType;
        }
    }
    
    /************************************************************************************************************
    *Class Name : SWS_IDCResponseWrapper
    *Created Date: 2024-03-28
    *Author: Bishal Singh
    *Description : Wrapper class to parse the response from IDC.
    ************************************************************************************************************/
    public class SWS_IDCResponseWrapper {
        public String code;	
        public String creator;	
        public Datetime created;	
        public Datetime start;	
        public Datetime expires;	
        private String disabled;
        public Double amount;	
        public Integer numUses;	
        public Integer numRedeemed;	
        public List<SWS_IDCIntegration.Redemptions> redemptions;
        private boolean isStandard;
        
        public SWS_IDCResponseWrapper parse(String response){
            return (SWS_IDCResponseWrapper) System.JSON.deserialize(response, SWS_IDCResponseWrapper.class);
        }
    }
    
    public class Redemptions {
        public String code;
        public String cloudAccountId;
        public Datetime redeemed;
        public Boolean installed;
    }
}