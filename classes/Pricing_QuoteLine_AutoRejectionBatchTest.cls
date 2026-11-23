@isTest
public class Pricing_QuoteLine_AutoRejectionBatchTest {
    
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Auto_Rejection_Batch');
            User partnerUser = Pricing_Test_Utility.createPartnerAdminUser(acc.Id);

            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuote(acc.Id, con.Id, 1);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
            Document document;            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;
            Test.stopTest();
        }
    }
    
    static testMethod void testquoteLineAutoRejectionBatch(){
        Test.startTest();
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        List<SBQQ__Quote__c> quoteList = [SELECT Id,Name,Pricing_Intel_Response_Requested_By_Date__c,Pricing_Status_Precedence_Number__c,Pricing_Bid_Dt__c FROM SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id,Pricing_Integration_Status_Nm__c,SBQQ__Quote__c,Pricing_Quote_Line_Status_Number__c,Pricing_Status_Nm__c,Pricing_Last_Submitted_By_Id__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_Quote_Program_Nm__c,Pricing_Intel_Response_Requested_By_Date__c,Pricing_Rejection_Comments_nm__c,SBQQ__Quote__r.Pricing_Bid_Dt__c FROM SBQQ__QuoteLine__c LIMIT 1];
        System.runAs(adminUserList[0]){      
           quoteLineList[0].Pricing_Last_Submitted_Date_dt__c = System.now() - 181;
           quoteLineList[0].Pricing_Quote_Program_Nm__c ='Tender';
            quoteLineList[0].Pricing_Integration_Status_Nm__c ='';
           quoteLineList[0].Pricing_Status_Nm__c = 'Pending Intel Field Review';
           update quoteLineList[0];
        }
        Pricing_QuoteLine_AutoRejection_Batch autoRejectBatch = new Pricing_QuoteLine_AutoRejection_Batch();
        Database.QueryLocator ql = autoRejectBatch.start(null);
        autoRejectBatch.execute(null,quoteLineList);
        autoRejectBatch.Finish(null);
        System.assertEquals(Label.Pricing_Tender_QuoteLine_Status_Rejected, quoteLineList[0].Pricing_Status_Nm__c , 'QuoteLine status is not updated.');
        Test.stopTest();
        Pricing_QuoteLine_AutoRejection_Batch.createCoreLogEntry('test details','test message','test class');
    } 
}