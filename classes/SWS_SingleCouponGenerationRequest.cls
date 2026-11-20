/****************************************************************************************************
Apex Class Name : SWS_SingleCouponGenerationRequest
Version         : 1.0 
Created Date    : 21/8/2024
Test Class      : SWS_SingleCouponGenerationRequestTest
Function        : This class is used to make api call for coupon generation in batches
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bishal Singh               21/8/2024                Created
*****************************************************************************************************/
public without sharing class SWS_SingleCouponGenerationRequest {
    
    private static Set<String> processedIds = new Set<String>();
    private static Map<String, SWS_Cloud_Credit_Request__c> updatedRecordMap = new Map<String, SWS_Cloud_Credit_Request__c>();
   
    /************************************************************************************************************
    *Method Name : singleRequest
    *Created Date: 2024-07-18
    *Author: Saileela Bojanapu 
    *Description : Method to generate Single Coupon for request.
    ************************************************************************************************************/
    public static void singleRequest(List<SWS_MultipleCouponGeneration.BulkInput> bulkValue){
        SWS_MultipleCouponGeneration.BulkInput inputFromFlow = bulkValue[0];
        if(inputFromFlow.singleCoupon){
            SWS_Cloud_Credit_Request__c request = getNewInstance(inputFromFlow);
            SWS_IDCIntegration.bypassUpdate = true;
            SWS_IDCIntegration.requestObj = request;
            SWS_IDCIntegration.getCoupon(request);            
            processInput(inputFromFlow);
            if(!updatedRecordMap.isEmpty()){
                Boolean isFailed = false;
                SWS_Utility.updateByPass();
                SWS_RetryOperationUtility updateRecord = new SWS_RetryOperationUtility(updatedRecordMap.values());
                SWS_Utility.updateByPass();
                sendEmail(inputFromFlow);
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : processInput
    *Created Date: 2024-07-18
    *Author: Ajinkya Ambalkar 
    *Description : Method to process input for single coupon generation.
    ************************************************************************************************************/
    private static void processInput(SWS_MultipleCouponGeneration.BulkInput inputFromFlow) {
        for(sObject obj : inputFromFlow.requestList){
            String recordId = (String) obj.get('Id');
            String couponStatus = (String) obj.get('SWS_Request_Status__c');
            String email = (String) obj.get('SWS_Email__c');
            if (!processedIds.contains(recordId) && couponStatus != 'Coupon_Generated') {
                SWS_Cloud_Credit_Request__c req = SWS_IDCIntegration.requestObj.clone();
                req.Id = recordId;
                req.SWS_Email__c = email;
                updatedRecordMap.put(recordId, req);
                processedIds.add(recordId);
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : sendEmail
    *Created Date: 2024-07-19
    *Author: Bishal Singh 
    *Description : Method to get send email for single coupon request.
    ************************************************************************************************************/
    private static void sendEmail(SWS_MultipleCouponGeneration.BulkInput inputFromFlow){
        if(processedIds.isEmpty()){
            return;
        }
        List<SWS_Cloud_Credit_Request__c> requestEmailList = new List<SWS_Cloud_Credit_Request__c>(); 
        for(sObject obj : inputFromFlow.requestList){
            String recordId = (String) obj.get('Id');
            if(processedIds.contains(recordId) && SWS_IDCIntegration.requestObj?.SWS_Request_Status__c == 'Coupon_Generated') {
                requestEmailList.add((SWS_Cloud_Credit_Request__c)obj);
            }
        }
        SWS_SendEmailController.requestBatchList = requestEmailList;
        SWS_SendEmailController.sendEmail('', 'SWS_SendCouponDetails');
    }
    
    /************************************************************************************************************
    *Method Name : getNewInstance
    *Created Date: 2024-07-18
    *Author: Bishal Singh 
    *Description : Method to get new instance of cloud credit request to generate coupon for single request.
    ************************************************************************************************************/
    private static SWS_Cloud_Credit_Request__c getNewInstance(SWS_MultipleCouponGeneration.BulkInput inputFromFlow) {
        return new SWS_Cloud_Credit_Request__c(
            SWS_Email__c = UserInfo.getUserEmail(),
            SWS_Expiry_Date__c = inputFromFlow.endDate,
            SWS_Coupon_Value__c = inputFromFlow.couponValue,
            SWS_No_Of_User__c = inputFromFlow.noOfUsers,
            SWS_Is_Standard__c = inputFromFlow.isStandard
        );
    }
}