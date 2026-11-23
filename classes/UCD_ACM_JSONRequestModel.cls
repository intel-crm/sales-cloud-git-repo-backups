public with sharing class UCD_ACM_JSONRequestModel {
 
        @InvocableMethod
        public static void handlePayload(List<UCD_ACM_AccountPrimaryCoverage.UCD_ACM_JSONRequestModel12> payloadList) {
            for (UCD_ACM_AccountPrimaryCoverage.UCD_ACM_JSONRequestModel12 payload : payloadList) {
                //String jsonPayload = JSON.serialize(payload);
                UCD_ACM_AccountPrimaryCoverage.AccountPrimaryCoverage(payload.AccountId,payload.primarycoverge);
            }
        }
    }