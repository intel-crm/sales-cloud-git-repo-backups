public without sharing class SWS_UpdateCoupon {
    public static final String LOG_ENTRY_ORIGIN   = 'SWS_ValidateRequest';
    public static final String LOG_ENTRY_SCOPE    = 'Failed to get Coupon';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    
    //private static SWS_Cloud_Credit_Request__c requestObj;
    public static void getCoupon(List<SObject> record){
        /*
        requestObj = (SWS_Cloud_Credit_Request__c) record[0];
        try{
            Time myStartTime = Time.newInstance(00, 00, 00, 0);
            Time myExpiryTime = Time.newInstance(23, 59, 59, 0);
            requestObj.SWS_Locked__c = false;
            update as system requestObj;
            requestObj.SWS_Coupon_Code__c = '0FNR-AYC0-WG9G' ;
            requestObj.SWS_Coupon_Created_On__c = System.now();
            requestObj.SWS_Coupon_Creator__c = requestObj.SWS_Full_name__c;
            requestObj.SWS_Coupon_Expiration_Date__c = DateTime.newInstance(requestObj.SWS_Expiry_Date__c, myExpiryTime);
            requestObj.SWS_Coupon_Valid_From__c = DateTime.newInstance(requestObj.SWS_Start_Date__c, myStartTime);
            requestObj.SWS_Coupon_Amount__c = requestObj.sws_coupon_value__c;
            requestObj.SWS_Request_Status__c = 'Coupon_Generated';
            requestObj.SWS_Request_Status_fm__c = requestObj.SWS_Request_Status__c;
            requestObj.SWS_Locked__c = true;
            update as system requestObj;
            SWS_SendEmailController.sendEmail(requestObj.Id, 'SWS_SendCouponDetails');
        }catch(Exception ex){
            SWS_Utility.createCoreLogEntry(LOG_ENTRY_ORIGIN,'getCoupon',LOG_ENTRY_SCOPE,'',ex,'SWS_Cloud_Credit_Request__c',LOG_ENTRY_SEVERITY,requestObj.Id);
        }
		*/
    }
}