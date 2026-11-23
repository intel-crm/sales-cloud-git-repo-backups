/**
* @description       : Class is created to check if the operation is run by RPM user and to call validate and create Change Request batch
* @author            : Rahul Maindalkar
* @group             : 
* @last modified on  : 05-21-2026
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_QLBulkCRValidation {
    
    /**
* @description  Method is created to check if the user is RPM user and to call bulk CR batch with the new QL map 
* @author Rahul Maindalkar | 08-24-2022 
* @param newQLMap 
**/
    public static void validateBulkCR(Map<String,SBQQ__QuoteLine__c> newQLMap, Map<String,Id> wwIdUserIdMap){
        
        system.debug('newQLMap:'+newQLMap);
        system.debug('newQLMap.KeySet():'+newQLMap.KeySet());
        List<String> userRPMList = New List<String>();
        userRPMList = Pricing_QuoteLineCloneController.userHasRPMPermissionSet();
        if(userRPMList.size()>0){
            Map<Id,SBQQ__QuoteLine__c> newIdQLMap = New Map<Id,SBQQ__QuoteLine__c>();
            // Logic to create new QL map with Id and CSV quote line data
            for(SBQQ__QuoteLine__c quoteLine : [Select Id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where Pricing_Quote_Line_Number__c in :newQLMap.KeySet()]){
                if(newQLMap.containsKey(quoteLine.Pricing_Quote_Line_Number__c)){
                    newIdQLMap.put(quoteLine.Id, newQLMap.get(quoteLine.Pricing_Quote_Line_Number__c)); 
                    // Logic to populate the Pricing Manager as per the WWID present in csv
                    string wwid = newIdQLMap.get(quoteLine.Id).Pricing_FSE_Recommended_Price_Nm__c;                  
                    if(!wwIdUserIdMap.isEmpty() && wwIdUserIdMap.containsKey(wwid)){
                        newIdQLMap.get(quoteLine.Id).Pricing_Manager__c = wwIdUserIdMap.get(wwid) ;
                    }
                } 
            }
            string batchSize = Label.Pricing_Bulk_CR_Batch_Size;
            Pricing_QLBulkCRValidationBatch bulkCR = New Pricing_QLBulkCRValidationBatch(newIdQLMap);
            Database.executeBatch(bulkCR, integer.valueOf(batchSize));  
            
        }        
    }
}