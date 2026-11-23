/****************************************************************************************************
Apex Class Name : SWS_MultipleCouponGeneration
Version         : 1.0 
Test Class    : SWS_MultipleCouponGenerationBatchTest
Created Date    : 6/20/2024
Created By    : Saileela Bojanapu
Function        : To generate bulk coupon for request.
*****************************************************************************************************
Modifications   : Bishal Singh
*****************************************************************************************************/
public without sharing class  SWS_MultipleCouponGeneration {
    
    public class BulkInput{
        @InvocableVariable
        public List<String> ids;
        @InvocableVariable
        public Boolean singleCoupon;
        @InvocableVariable
        public Date endDate;
        @InvocableVariable
        public Decimal couponValue;
        @InvocableVariable
        public Integer noOfUsers;
        @InvocableVariable
        public Boolean isStandard;
        @InvocableVariable
        public List<sObject> requestList;
    }
    
    /************************************************************************************************************
    *Method Name : bulkRequest
    *Created Date: 2024-07-18
    *Author: Saileela Bojanapu 
    *Description : Method to generate Multiple/Single Coupon for request.
    ************************************************************************************************************/
    @InvocableMethod(label ='bulkRequest')
    public static void bulkRequest(List<BulkInput> bulkValue){
        BulkInput inputFromFlow = bulkValue[0];
        if(inputFromFlow.singleCoupon){
            SWS_SingleCouponGenerationRequest.singleRequest(bulkValue);
        } else if (!inputFromFlow.singleCoupon) {
            SWS_MultipleCouponGenerationBatch multipleCouponBatch = new SWS_MultipleCouponGenerationBatch(inputFromFlow.ids);
            Database.executeBatch(multipleCouponBatch, 40);   
        }
    }
}