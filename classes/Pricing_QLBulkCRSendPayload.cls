/**
* @description       : Class is created to check if the operation is run by RPM user and to call Pricing_QLBulkCRSendPayloadBatch to send request to MyDeals
* @author            : Rahul Maindalkar
* @group             : 
* @last modified on  : 08-24-2022
* @last modified by  : Rahul Maindalkar
**/
public without sharing class Pricing_QLBulkCRSendPayload {

    /**
    * @description  Method is created to check if the user is RPM user and to call Pricing_QLBulkCRSendPayloadBatch with the new QL set 
    * @author Rahul Maindalkar | 08-24-2022 
    * @param newQLSet 
    **/    
    public static void callPayloadBatch(Set<Id> newQLSet){
        
        List<String> userRPMList = New List<String>();
        userRPMList = Pricing_QuoteLineCloneController.userHasRPMPermissionSet();
        if(userRPMList.size()>0){
            string batchSize = Label.Pricing_Bulk_CR_SendPayload_Size; 
            Pricing_QLBulkCRSendPayloadBatch bulkCR = New Pricing_QLBulkCRSendPayloadBatch(newQLSet);
            Database.executeBatch(bulkCR, integer.valueOf(batchSize));  
            
        }        
    }
}