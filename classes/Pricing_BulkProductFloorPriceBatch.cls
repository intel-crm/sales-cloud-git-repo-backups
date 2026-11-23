/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-28-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Pricing_BulkProductFloorPriceBatch implements Database.Batchable<sObject>, Database.Stateful {
   Map<String, String> resultMap = new Map<String, String>();
    Map<String, Pricing_Product_Floor_Price__c> productFloorPriceMap = New Map<String, Pricing_Product_Floor_Price__c>();
    String recordId;
    Map<Id,String> prodIdToNameMap = new Map<Id,String>();
    public Pricing_BulkProductFloorPriceBatch(Map<String,Pricing_Product_Floor_Price__c> newProductFloorPriceMapBatch, String recordId, Map<Id,String> prodIdToNameMap){
        this.productFloorPriceMap = new Map<String,Pricing_Product_Floor_Price__c>(newProductFloorPriceMapBatch);
        this.prodIdToNameMap = new Map<Id,String>(prodIdToNameMap);
        this.recordId = recordId;
    }

    public Iterable<Pricing_Product_Floor_Price__c> start(Database.BatchableContext bc){
        return productFloorPriceMap.values();
    }

    public void execute(Database.BatchableContext bc, List<Pricing_Product_Floor_Price__c> productFloorPriceList){
        Map<String, String> ProdcutFloorPriceSuccessErrorMap = new Map<String, String>();
        system.debug('productFloorPriceListbatch:'+productFloorPriceList);
        system.debug('prodIdToNameMap:'+prodIdToNameMap);
        ProdcutFloorPriceSuccessErrorMap = Pricing_ApprovalPriceRulesTriggerHandler.validateProductFloorPrice(productFloorPriceList,recordId,prodIdToNameMap,productFloorPriceMap);
        resultMap.putAll(ProdcutFloorPriceSuccessErrorMap);
    }

    public void finish(database.BatchableContext bc) {
        String csvColumnHeader;
        List<String> csvRowValues = new List<String>();
        system.debug('resultMap:'+resultMap);
        for(String key : resultMap.keySet()){            
            String response = resultMap.get(key);
            String csvRowVal;
               system.debug('response:'+response);
            csvRowVal = response;
            csvRowValues.add(csvRowVal);
        }
        system.debug('csvRowValues:'+csvRowValues);
        csvColumnHeader = 'Product Id,Product Name,Floor Price,Active,Result\n';
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        List<OrgWideEmailAddress> orgWideEmailAdd = [SELECT Id from OrgWideEmailAddress where Address=:Label.Pricing_OrgWideEmailAddress];
        Id orgWideEmailAddId = orgWideEmailAdd[0].id;
        Pricing_Approval_Price_Rules__c rule = [select Name from Pricing_Approval_Price_Rules__c where Id =: recordId];
        //send email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment attachFile = new Messaging.EmailFileAttachment();
        blob b;
        b = Blob.valueOf(csvFile);                        
        String emailAddress = UserInfo.getUserEmail();
        String ccemailAddress = Label.Pricing_IQR_Support_Email;
        attachFile.setFileName('Product Floor Price_'+string.valueOf(system.now())+'.csv');
        attachFile.setBody(b);
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{attachFile});
        message.setTargetObjectId(UserInfo.getUserId());
        String[] toAddresses = new String[] {emailAddress};
        String[] ccAddresses = new String[] {ccemailAddress};
        message.setToAddresses(toAddresses);
        message.setccAddresses(ccAddresses);
         message.setOrgWideEmailAddressId(orgWideEmailAddId);
        message.setSubject('Result : Bulk Product Floor Price Upload For : '+rule.Name); 
        message.setHtmlBody('Floor Product and Floor Price upload has completed. Please see the attached file for upload results.');
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
}