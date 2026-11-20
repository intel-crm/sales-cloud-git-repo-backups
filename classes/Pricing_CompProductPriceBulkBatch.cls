/**
 * @description       : Class to process Competitor Product Price records in batches
 * @author            : Suraj Barade
 * @group             : Accenture
 * @last modified on  : 04-26-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_CompProductPriceBulkBatch implements Database.Batchable<SObject>, Database.Stateful{

    Map<String, String> resultMap = new Map<String, String>();
    Map<String, Pricing_Competitor_Product_Price_Staging__c> compProductPriceMap = New Map<String, Pricing_Competitor_Product_Price_Staging__c>();

    public Pricing_CompProductPriceBulkBatch(Map<String,Pricing_Competitor_Product_Price_Staging__c> newCompProductPriceMapBatch){
        compProductPriceMap = new Map<String,Pricing_Competitor_Product_Price_Staging__c>(newCompProductPriceMapBatch);
    }

    public Iterable<Pricing_Competitor_Product_Price_Staging__c> start(Database.BatchableContext bc){
        return compProductPriceMap.values();
    }

    public void execute(Database.BatchableContext bc, List<Pricing_Competitor_Product_Price_Staging__c> compProductPriceList){
        Map<String, String> compProdcutPriceSuccessErrorMap = new Map<String, String>();
        compProdcutPriceSuccessErrorMap = Pricing_IQR_UploadFile.validateCompetitorProductPrice(compProductPriceList);
        resultMap.putAll(compProdcutPriceSuccessErrorMap);
    }

    public void finish(database.BatchableContext bc) {
        String csvColumnHeader;
        List<String> csvRowValues = new List<String>();
        for(String key : resultMap.keySet()){            
            String response = resultMap.get(key);
            String csvRowVal;
            csvRowVal = response; 
            csvRowValues.add(csvRowVal);
        }
        List<OrgWideEmailAddress> orgWideEmailAdd = [SELECT Id from OrgWideEmailAddress where Address=:Label.Pricing_OrgWideEmailAddress];
        Id orgWideEmailAddId = orgWideEmailAdd[0].id;
        csvColumnHeader = 'Competitor Product Id,Competitor Product Name,List Price,Region,Median Meet Comp Discount,Application,Final Meet Comp Price,Result\n';
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        
        //send email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment attachFile = new Messaging.EmailFileAttachment();
        blob b;
        b = Blob.valueOf(csvFile);                        
        
        String emailAddress = UserInfo.getUserEmail();
        String ccemailAddress = Label.Pricing_IQR_Support_Email;
        attachFile.setFileName('Comp Product Price_'+string.valueOf(system.now())+'.csv');
        attachFile.setBody(b);
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{attachFile});
        message.setTargetObjectId(UserInfo.getUserId());
        String[] toAddresses = new String[] {emailAddress};
        String[] ccAddresses = new String[] {ccemailAddress};
        message.setToAddresses(toAddresses);
        message.setccAddresses(ccAddresses);
        message.setOrgWideEmailAddressId(orgWideEmailAddId);
        message.setSubject('Result : Bulk Competitor Product Price Operation'); 
        message.setHtmlBody('Please see attached Bulk Competitor Product Price success error csv file');
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
}