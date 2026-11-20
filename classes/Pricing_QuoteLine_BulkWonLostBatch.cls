/**
 * @description       : Class to process bulk won/lost records in batches
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 04-26-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_QuoteLine_BulkWonLostBatch implements Database.Batchable<sObject>, Database.Stateful{

    Map<String, String> resultMap = new Map<String, String>();
    Map<String, SBQQ__QuoteLine__c> quoteLineNumberMap = New Map<String, SBQQ__QuoteLine__c>();

    public Pricing_QuoteLine_BulkWonLostBatch(Map<String,SBQQ__QuoteLine__c> newQLMapBatch){
        quoteLineNumberMap = new Map<String,SBQQ__QuoteLine__c>(newQLMapBatch);
    }

    /**
    * @description start method of batch class
    * @author Sandeep Chamate | 06-12-2023 
    * @param bc 
    * @return Database.QueryLocator - returns the Quoteline records which matches with Quoteline number from csv files.
    **/
    public Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator([SELECT Id,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,Pricing_Won_Lost_Comments_Txt__c,SBQQ__Quote__r.SBQQ__Account__c,Pricing_Deal_RFQ_Id__c,Pricing_Lost_Reason_Nm__c,
                                          SBQQ__Quote__r.Pricing_On_Hold_Cb__c FROM SBQQ__QuoteLine__c WHERE Pricing_Quote_Line_Number__c IN :quoteLineNumberMap.KeySet() ORDER By SBQQ__Quote__c]);
    }

    /**
    * @description execute methods call the method to validate Quotelines for won/lost.
    * @author Sandeep Chamate | 06-12-2023 
    * @param bc 
    * @param quoteLineList - Quoteline records list.
    **/
    public void execute(Database.BatchableContext bc, List<SBQQ__QuoteLine__c> quoteLineList){
        Map<String, String> quoteLineSuccessErrorMap = new Map<String, String>();
        quoteLineSuccessErrorMap = Pricing_QuoteLine_BulkWonLost.validateWonLostQuoteLines(quoteLineNumberMap, quoteLineList);
        resultMap.putAll(quoteLineSuccessErrorMap);
    }

    /**
    * @description finish method which send the mail to user with all processed records.
    * @author Sandeep Chamate | 06-12-2023 
    * @param bc 
    **/
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
        csvColumnHeader = 'Quote Line Number, Quote Line Status, Deal ID, Result\n';
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        
        //send email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment attachFile = new Messaging.EmailFileAttachment();
        blob b;
        b = Blob.valueOf(csvFile);                        
        
        String emailAddress = UserInfo.getUserEmail();
        String ccemailAddress = Label.Pricing_Bulk_CR_Email;        
        attachFile.setFileName('Bulk Won/Lost Success Error File_'+string.valueOf(system.now())+'.csv');
        attachFile.setBody(b);
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{attachFile});
        String[] toAddresses = new String[] {emailAddress};
        String[] ccAddresses = new String[] {ccemailAddress};
        message.setToAddresses(toAddresses);
        message.setccAddresses(ccAddresses);
        message.setOrgWideEmailAddressId(orgWideEmailAddId);
        message.setSubject('Result : Bulk Won/Lost Operation'); 
        message.setHtmlBody('Please see attached Bulk Won/Lost success error csv file');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });

        Pricing_QuoteLine_BulkWonLost.updateAtRiskForWonQuotelines(resultMap);
    }
}