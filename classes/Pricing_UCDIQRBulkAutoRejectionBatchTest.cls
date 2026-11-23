@isTest
public class Pricing_UCDIQRBulkAutoRejectionBatchTest {
  //Setting up Test Data
    @testSetup
    public static void setUpData(){
    	List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
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
    
    static testmethod void testAutoRejectionBulkBatch() {
        Test.startTest();
        List<User> lstUsers4 = [select id from user where email = 'firstName@intel.com' limit 1];
        List<User> partnerUser = [select id from user where email = 'partner@noemail.com' limit 1];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id,Pricing_Unified_Global_End_Customer_Nm__c,SBQQ__Account__c from SBQQ__Quote__c Limit 1]);
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id  limit 1]);
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        Pricing_Publish_Quote.globalVariables glbVariable;
        
        List<Pricing_Comments__c> lstComment = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c,Pricing_Quote__c
                                                FROM Pricing_Comments__c 
                                                WHERE Pricing_Quote__c =: lstquote[0].id and recordtypeid=:commentRecordTypeId];
        for(Pricing_Comments__c pc: lstComment){
            if(lstquote[0].id == pc.Pricing_Quote__c){
                pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = true;
            }
            else{
                pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = false;
            }
        }
        update lstComment;
        List<Pricing_Performance_Metric__c> performanceList;
        performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);    
        if(!performanceList.isEmpty()){
            insert performanceList;
        }
        
        system.runAs(lstUsers4[0]){
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
            lstquoteLines[0].Pricing_Quote_Line_Status_Number__c = 30;
            lstquoteLines[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview;
        	update lstquoteLines[0];
        }

        Pricing_Quote_Line_Status_Age__c qlineTPT = new Pricing_Quote_Line_Status_Age__c();
        qlineTPT.Pricing_TPT_Quote_Line_Number__c = lstquoteLines[0].Id;
        qlineTPT.Pricing_TPT_Status_Name__c = 'Rejected';
        insert qlineTPT;

        Pricing_UnifiedEndCustomerAccountMapping__c newEndCustAccL1 = new Pricing_UnifiedEndCustomerAccountMapping__c();
        newEndCustAccL1.Name = 'Test End Customer';
        newEndCustAccL1.Pricing_Account_Nm__c = lstquote[0].SBQQ__Account__c;
        newEndCustAccL1.Pricing_Active_cb__c = true;
        newEndCustAccL1.Pricing_Unified_EndCustomer_Id__c = '12345';
        insert newEndCustAccL1;
        
        Pricing_UnifiedEndCustomerCountryMapping__c newEndCustCountry = new Pricing_UnifiedEndCustomerCountryMapping__c();
        newEndCustCountry.Name = 'Test End Customer';
        newEndCustCountry.Pricing_Country_Nm__c = 'Afghanistan';
        newEndCustCountry.Pricing_Unified_Country_EndCustomer_Id__c ='56789';
        newEndCustCountry.Pricing_Unified_EndCustomer_Act_Mapping__c = newEndCustAccL1.Id;
        newEndCustCountry.Pricing_Compliance_Watch_List__c = 'EC';
        insert newEndCustCountry;
        
        lstquote[0].Pricing_Unified_Global_End_Customer_Nm__c = newEndCustCountry.Id;
        update lstquote[0];

        Pricing_UCD_IQR_BulkAutoRejection_Batch bulkRejectBatch = new Pricing_UCD_IQR_BulkAutoRejection_Batch();
        Id batchId = Database.executeBatch(bulkRejectBatch);
        System.assertEquals(batchId != null, true);
        Test.stopTest();
        
    }

}