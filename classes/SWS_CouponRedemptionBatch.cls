/****************************************************************************************************
Apex Class Name : SWS_CouponRedemptionBatch
Version         : 1.0 
Created Date    : 2024-05-15
Function        : Batch job to get the coupon redemption details from IDC
User Story      : TWC5945-307
Test Class      : SWS_CouponRedemptionBatchTest,SWS_IDCBatchIntegrationMockTest
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Arulraj Swaminathan       2024-05-15                 Created
* Bishal Singh              2024-07-28                 Modified
*****************************************************************************************************/
public without sharing class SWS_CouponRedemptionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    private Map<String, List<SWS_CouponRedemptionWrapper.Redemptions>> couponRedemptionMap;
    private static Integer responseCode;
    private List<String> errorMessages = new List<String>();
    private DateTime batchStartTime = Datetime.newInstance(1341828183000L);
    
    public Database.queryLocator start(Database.BatchableContext bc){
        batchStartTime = System.now();
        responseCode = getAllCoupon();
        SWS_Utility.updateByPass();
        List<String> couponCodes = new List<String>(couponRedemptionMap.keySet());
        String queryString = 'SELECT Id, SWS_Coupon_Status__c, SWS_Coupon_Code__c, SWS_IDC_Response_Time__c, SWS_Number_of_Redemptions__c, SWS_Last_redeemed_date__c FROM SWS_Cloud_Credit_Request__c WHERE SWS_Coupon_Status__c = \'Active\' AND SWS_Coupon_Code__c IN :couponCodes';
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<SWS_Cloud_Credit_Request__c> creditRequestList){
        if (creditRequestList.isEmpty() || couponRedemptionMap.isEmpty()) {
            return;
        }
        List<SWS_Cloud_Credit_Request__c> updateRequestList = new List<SWS_Cloud_Credit_Request__c>();
        for (SWS_Cloud_Credit_Request__c credRequest : creditRequestList) {
            List<SWS_CouponRedemptionWrapper.Redemptions> redemptions = couponRedemptionMap.get(credRequest.SWS_Coupon_Code__c);
            if (redemptions != null && !redemptions.isEmpty()) {
                SWS_Cloud_Credit_Request__c updatedRequest = updateRedemptionDetails(credRequest, redemptions);
                updateRequestList.add(updatedRequest);
            }
        }

        if (!updateRequestList.isEmpty()) {
            updateCloudRequet(updateRequestList);
        }
    }

    public void finish(Database.BatchableContext bc) {
        if(errorMessages.isEmpty()){
            SWS_Utility.mapBypassValidation.Last_Batch_Update__c = batchStartTime;
        }
        SWS_Utility.updateByPass();
    }
    
    private SWS_Cloud_Credit_Request__c updateRedemptionDetails(SWS_Cloud_Credit_Request__c credRequest, List<SWS_CouponRedemptionWrapper.Redemptions> redemptions) {      
        Decimal totalRedemptions = credRequest.SWS_Number_of_Redemptions__c == null ? 0 : credRequest.SWS_Number_of_Redemptions__c;
        for (SWS_CouponRedemptionWrapper.Redemptions red : redemptions) {
            if (red.redeemed > credRequest.SWS_Last_redeemed_date__c || credRequest.SWS_Last_redeemed_date__c == null) {
                credRequest.SWS_Last_redeemed_date__c = red.redeemed;
                totalRedemptions++;
            }
        }
        credRequest.SWS_redeemed_expired__c = false;
        credRequest.SWS_Response_Code__c = responseCode;
        credRequest.SWS_Last_Redeem_Run_Date__c = System.now();
        credRequest.SWS_Number_of_Redemptions__c = totalRedemptions;
        return credRequest;
    }
    
    private void updateCloudRequet(List<SWS_Cloud_Credit_Request__c> updateRequestList){
        SWS_RetryOperationUtility updateRecord = new SWS_RetryOperationUtility(updateRequestList);
        for(Integer i = 0; i < SWS_RetryOperationUtility.results.size(); i++){
            Database.SaveResult sr = SWS_RetryOperationUtility.results[i];
            if (!sr.isSuccess()) {
                errorMessages.add(sr.getId() + ' => ' + SWS_Utility.getErrorAsString(sr.getErrors(), 'SWS_CouponRedeemptionBatch'));
            }
        }
        if(errorMessages.size() > 0){
            SWS_Utility.createCoreLogEntry('SWS_CouponRedeemptionBatch', 'execute', 'Error while updating credit request redeemption details on '+System.now(), String.join(errorMessages,';'), null, 'SWS_Cloud_Credit_Request__c', 'High','');
        }
    }
    

    private Integer getAllCoupon() {
        couponRedemptionMap = new Map<String, List<SWS_CouponRedemptionWrapper.Redemptions>>();
        String getCouponURL = createEndPoint();
        if(String.isBlank(getCouponURL)) {
            return 404;
        }
        
        String endpoint = 'callout:IDC_Credit_Request_NC' + getCouponURL;
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endpoint);
        httpReq.setMethod('GET');
        HttpResponse response = new Http().send(httpReq);
        if (response.getStatusCode() == 200) {
            SWS_CouponRedemptionWrapper wrapper = (SWS_CouponRedemptionWrapper) JSON.deserialize(response.getBody(), SWS_CouponRedemptionWrapper.class);
            for (SWS_CouponRedemptionWrapper.redemptions cl : wrapper.redemptions) {
                if (!couponRedemptionMap.containsKey(cl.code)) {
                    couponRedemptionMap.put(cl.code, new List<SWS_CouponRedemptionWrapper.Redemptions>());
                }
                couponRedemptionMap.get(cl.code).add(cl);
            }
        } else {
            SWS_Utility.createCoreLogEntry('SWS_CouponRedeemptionBatch', 'getAllCoupon', 'Error fetching coupon details', response.getBody(), null, 'SWS_Cloud_Credit_Request__c', 'High', '');
        }
        return (Integer) response.getStatusCode();
    }
    
    private String createEndPoint(){
        String getCouponURL = SWS_Core_CRM_Labels__c.getValues('GetRedeemDetail')?.SWS_Value__c;
        if(String.isNotBlank(getCouponURL)){
            getCouponURL += SWS_Utility.mapBypassValidation?.Last_Batch_Update__c.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }
        
        if(SWS_Utility.mapBypassValidation?.Allow_Creator__c && String.isNotBlank(getCouponURL)){
            String getCreatorURL = SWS_Core_CRM_Labels__c.getValues('GetRedeemCreatorDetail')?.SWS_Value__c + Label.SWS_IDCCouponCreator;
            if(String.isNotBlank(getCreatorURL)){
                return getCouponURL + getCreatorURL;
            }
        }
        return getCouponURL;
    }
}