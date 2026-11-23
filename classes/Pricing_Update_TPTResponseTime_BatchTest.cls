@isTest
public class Pricing_Update_TPTResponseTime_BatchTest {
    
    @isTest
    static void updateTptResponseTimeTest(){
        List<User> fseUser = Pricing_Test_Utility.createFSEUser();
        List<User> adminUser = Pricing_Test_Utility.createAdminUser();
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        Account acc;
        Contact con; 
        AccountTeamMember accTeam;
        List<SBQQ__Quote__c> lstquote;
        List<Pricing_Comments__c> commentsList;
        List<User> salesRepUserList = new List<User>();
        List<SBQQ__QuoteLine__c> quotelinelist = new List<SBQQ__QuoteLine__c>();
        system.runAs(adminUser[0]){
            Test.startTest();            
            Pricing_Test_Utility.createPriceBook();
            acc = Pricing_Test_Utility.createAccount();
            con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = fseUser[0].Id);
            insert accTeam;
            lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,fseUser[0].Email,accountExecutiveUserList[0].Email);
            quotelinelist = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 3);
        	Test.stopTest();
        }
        
        system.runAs(fseUser[0]){
            Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
        }
        
        system.runAs(adminUser[0]){
            quotelinelist[0].Pricing_Last_Approved_Date_dt__c = System.today();
            quotelinelist[0].Pricing_Original_Submitted_Date_dt__c = System.today();
            
            quotelinelist[1].Pricing_Last_Approved_Date_dt__c = System.today();
            quotelinelist[1].Pricing_Last_Submitted_Date_dt__c = System.today();
            update quotelinelist;
            
            Pricing_Quote_Line_Status_Age__c scope = [SELECT id,Pricing_First_SubmissionToResponse_Time__c,Pricing_Last_Submission_to_Response_Time__c,Pricing_TPT_Quote_Line_Number__r.Pricing_Last_Approved_Date_dt__c,Pricing_TPT_Quote_Line_Number__r.Pricing_Original_Submitted_Date_dt__c,Pricing_TPT_Quote_Line_Number__r.Pricing_Last_Submitted_Date_dt__c,Pricing_TPT_Change_Time__c, Pricing_TPT_Set_Time__c, Pricing_TPT_Age__c,Pricing_TPT_Status_Time__c
                                         FROM Pricing_Quote_Line_Status_Age__c where Pricing_TPT_Quote_Line_Number__r.id = :quotelinelist[2].Id];
            scope.Pricing_TPT_Change_Time__c = System.today();
            update scope;
            Pricing_Update_TPT_ResponseTime_Batch tptBatch = new Pricing_Update_TPT_ResponseTime_Batch();
            Id batchId = Database.executeBatch(tptBatch);
            System.assertEquals(batchId != null, true);
        }
    }
}