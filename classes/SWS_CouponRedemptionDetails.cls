/****************************************************************************************************
Apex Class Name : SWS_CouponRedemptionDetails
Version         : 1.0 
Test Class      : SWS_CouponRedemptionDetailsTest
Created Date    : 2024-06-12
Author          : Naveen(Team Garnet)
Function        : This class is used to get the coupon redemption details for perticular request from IDC
Modifications   :
*****************************************************************************************************/
public without sharing class SWS_CouponRedemptionDetails {
    private static final String LOG_ENTRY_ORIGIN   = 'SWS_CouponRedemptionDetails';
    private static final String LOG_ENTRY_SCOPE    = 'Failed to get redemption details';
    private static final String LOG_ENTRY_SEVERITY = 'High';
    private static SWS_Cloud_Credit_Request__c requestObj;
    private static SWS_IDCIntegration.SWS_IDCResponseWrapper wrapper;
    private static Boolean isBatch = true;
    private static Boolean isRecordUpdated = false;
   
    /************************************************************************************************************
    *Method Name : getRedemptionDetail
    *Created Date: 2024-06-12
    *Author: Naveen
    *Description : Convert this to invocable method to call this from flow.
    ************************************************************************************************************/
    @InvocableMethod(label='Get Coupon Redemption' description='Request IDC Coupon from SWS')
    public static List<sObject> getRedemptionDetail(List<SObject> record){
        isBatch = false;
        Boolean req = getCouponRedemptionDetails(record[0]);
        return record;
    }
    
    /************************************************************************************************************
    *Method Name : getCouponRedemptionDetails
    *Created Date: 2024-03-28
    *Author      : Naveen
    *Description : callout to IDC for fetching coupon redemption details.
    ************************************************************************************************************/
    public static Boolean getCouponRedemptionDetails(SObject record) {
        try {
            String getRedeemCouponURL = SWS_Core_CRM_Labels__c.getValues('RedeemCoupon') != null ? SWS_Core_CRM_Labels__c.getValues('RedeemCoupon').SWS_Value__c : '';
            if(record == null || String.isBlank(getRedeemCouponURL)){
                return isRecordUpdated;
            }    
            HttpRequest httpReq = new HttpRequest();
            String endpoint = 'callout:IDC_Credit_Request_NC' + getRedeemCouponURL + ((String) record.get('SWS_Coupon_Code__c'));
            httpReq.setEndpoint(endpoint);        
            httpReq.setMethod('GET');  
            Http http = new Http();
            HttpResponse response;
            response = http.send(httpReq);
            if(response.getStatusCode() == 200){                    
                wrapperResponse(response,record);
            }else if(response.getStatusCode() != 200 && !isBatch){
                SWS_Utility.updateRedemptionDetails((SWS_Cloud_Credit_Request__c) record,null,isBatch,response);
               
            }
        }catch(Exception ex){
            SWS_Utility.createCoreLogEntry(LOG_ENTRY_ORIGIN,'getCouponRedemptionDetails','Error While fetching Credit Request List','',ex,'SWS_Cloud_Credit_Request__c',LOG_ENTRY_SEVERITY,(String) record.get('Id'));
        }        
        return isRecordUpdated;
    }

    /************************************************************************************************************
    *Method Name : wrapperResult
    *Created Date: 2024-06-12
    *Author      : Naveen
    *Description : Iterate the wrapper data and update it on cloud credit request object.
    ************************************************************************************************************/
    public static void wrapperResult(SObject record,HttpResponse response){            
        if(wrapper != null && wrapper.numRedeemed>=0 || (string)record.get('SWS_Coupon_Status__c') == 'Expired'){  
            isRecordUpdated = SWS_Utility.updateRedemptionDetails((SWS_Cloud_Credit_Request__c) record,wrapper,isBatch,response);
        }
    }
    
    /************************************************************************************************************
    *Method Name : wrapperResponse
    *Created Date: 2024-06-12
    *Author      : Naveen
    *Description : Parse the response 
    ************************************************************************************************************/
    public static void wrapperResponse(HttpResponse response, SObject record){
        Integer jsonStringLength = response.getBody().length();
        Integer startIndex = -1;
        Integer openBraceCount = 0;
        for (Integer i = 1; i < jsonStringLength; i++) {
            if (response.getBody().substring(i, i + 1).equals('{')) {
                if (openBraceCount == 0) {
                    startIndex = i;
                }
                openBraceCount++;
            } else if (response.getBody().substring(i, i + 1).equals('}')) {
                openBraceCount--;
                if (openBraceCount == 0 && startIndex != -1) {
                    wrapper = new SWS_IDCIntegration.SWS_IDCResponseWrapper().parse(response.getBody().substring(startIndex, i + 1));
                    
                    startIndex = -1;
                }
            }
        }
        wrapperResult(record,response);
    }
}