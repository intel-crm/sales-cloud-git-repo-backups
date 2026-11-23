@isTest
public class Pricing_LinkQuotesController_Test {
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Account acc = new Account();
        Contact con = new  Contact();
        List<User> accountExecutiveUserList = new List<User>();
        List<User> salesRepUserList = new List<User>();
        Pricing_UnifiedEndCustomerAccountMapping__c endCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
        System.runAs(adminUserList[0]){
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            acc = Pricing_Test_Utility.createAccount();
            con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Link_Quote_Controller_test');
            accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();    
            endCustomer = Pricing_Test_Utility.createUnifiedEndCustomer(acc.Id);
            for(Integer i=0;i<4;i++){ 
                SBQQ__Quote__c quote = new SBQQ__Quote__c();
                quote.SBQQ__Account__c = acc.Id;
                quote.SBQQ__PrimaryContact__c = con.Id;
                quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
                quote.Pricing_Project_Name_Nm__c = 'Test Project';
                quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
                quote.Pricing_Intel_Sales_Rep_Email_Txt__c = salesRepUserList[0].Email;
                quote.Pricing_End_Customer__c = endCustomer.Id;
                quote.Pricing_Customer_Nm__c = '';
                quote.Pricing_ShipmentStDate_Dt__c = system.today();
                quote.Pricing_Intel_Account_Exec_Email_Txt__c = accountExecutiveUserList[0].Email;
                quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
                quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
                quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
                quote.Pricing_Region_Nm__c = 'APJ';      
                quote.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
                lstQuote.add(quote);
            }
            insert lstQuote;
            Pricing_Quote_Group__c grp = new Pricing_Quote_Group__c();
            insert grp;
            test.stopTest();
        }
        
        User extUser = [Select id from User where ContactId =: con.id];
        System.runAs(extUser){
            Pricing_Quote_Group__c grp = new Pricing_Quote_Group__c();
            insert grp;
        }
    }
    static testMethod void testGetQuotes(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c from SBQQ__Quote__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        System.runAs(adminUser){
            Test.startTest();
            Pricing_LinkQuotesController.getQuotes(quoteList[0].Id);
            Test.stopTest();
        }
    }
    static testMethod void testGetQuotesExternal(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, SBQQ__PrimaryContact__c, Pricing_Group_Nm__c from SBQQ__Quote__c LIMIT 1];
        User extUser = [Select id from User where ContactId =: quoteList[0].SBQQ__PrimaryContact__c];
        System.runAs(extUser){
            Test.startTest();
            Pricing_LinkQuotesController.getQuotes(quoteList[0].Id);
            Test.stopTest();
        }
    }
    static testMethod void testGetQuoteLinkStatus(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c from SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        Pricing_LinkQuotesController.getQuoteLinkStatus(quoteList[0].Id);
        Test.stopTest();
    }
    static testMethod void testGetQuoteLinkStatusWGrp(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c from SBQQ__Quote__c LIMIT 1];
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        quoteList[0].Pricing_Group_Nm__c = qGrp.Id;
        update quoteList;
        Test.startTest();
        Pricing_LinkQuotesController.getQuoteLinkStatus(quoteList[0].Id);
        Test.stopTest();
    }
    static testMethod void testGetQuoteGroup(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c,Pricing_Group_Nm__r.Name from SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        Pricing_LinkQuotesController.getQuoteGroup(quoteList[0].Id);
        Test.stopTest();
    }
    static testMethod void testGetQuoteGroupExt(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, SBQQ__PrimaryContact__c, Pricing_Group_Nm__c,Pricing_Group_Nm__r.Name 
                                          from SBQQ__Quote__c LIMIT 1];
        User extUser = [Select id from User where ContactId =: quoteList[0].SBQQ__PrimaryContact__c];
        System.runAs(extUser){
            Test.startTest();
            Pricing_LinkQuotesController.getQuoteGroup(quoteList[0].Id);
            Test.stopTest();
        }
    }
    static testMethod void testFindRecordsQuoteType(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c from SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        Pricing_LinkQuotesController.findRecords(quoteList[0].Id,'Data','Quote Type');
        Test.stopTest();
    }
    static testMethod void testFindRecordsQuoteTypeExt(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, SBQQ__PrimaryContact__c, Pricing_Group_Nm__c from SBQQ__Quote__c LIMIT 1];
        User extUser = [Select id from User where ContactId =: quoteList[0].SBQQ__PrimaryContact__c];
        System.runAs(extUser){
            Test.startTest();
            Pricing_LinkQuotesController.findRecords(quoteList[0].Id,'Data','Quote Type');
            Test.stopTest();
        }
    }
    static testMethod void testFindRecordsQuoteNumber(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, SBQQ__Account__c, SBQQ__Account__r.Name, Pricing_Group_Nm__c 
                                          from SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        Pricing_LinkQuotesController.findRecords(quoteList[0].Id,'Q','Quote Number');
        Test.stopTest();
    }
    static testMethod void testFindRecordsProject(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c from SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        Pricing_LinkQuotesController.findRecords(quoteList[0].Id,'Test','Project');
        Test.stopTest();
    }
    static testMethod void testFindRecordsEndCust(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c from SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        Pricing_LinkQuotesController.findRecords(quoteList[0].Id,'End','End Customer');
        Test.stopTest();
    }
    static testMethod void testLinkQuotes(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c,Pricing_Group_Nm__r.Name from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__Quote__c> quotLstRecs = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name 
                                            from SBQQ__Quote__c where Id !=: quoteList[0].Id LIMIT 2];
        for(SBQQ__Quote__c qt: quotLstRecs){
            quoteNumList.add(qt.Name);
        }
        Test.startTest();
        Pricing_LinkQuotesController.linkQuotes(quoteNumList,quoteList[0].Id);
        Test.stopTest();
    }
    static testMethod void testLinkQuoteWoGrp(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c,Pricing_Group_Nm__r.Name from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__Quote__c> quotLstRecs = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name 
                                            from SBQQ__Quote__c where Id !=: quoteList[0].Id LIMIT 2];
        for(SBQQ__Quote__c qt: quotLstRecs){
            quoteNumList.add(qt.Name);
        }
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        quotLstRecs[0].Pricing_Group_Nm__c = qGrp.Id;
        update quotLstRecs;
        Test.startTest();
        Pricing_LinkQuotesController.linkQuoteWoGrp(quoteNumList,qGrp.Name,quoteList[0].Id);
        Test.stopTest();
    }
    static testMethod void testRemoveQuoteLink(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name from SBQQ__Quote__c LIMIT 1];
        quoteNumList.add(quoteList[0].Name);
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        Test.startTest();
        Pricing_LinkQuotesController.removeQuoteLink(quoteList[0].Id,quoteNumList);
        Test.stopTest();
    }
    static testMethod void testGetQuoteGroupDtlsUnlinkWGrp(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name from SBQQ__Quote__c LIMIT 1];
        quoteNumList.add(quoteList[0].Name);
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        quoteList[0].Pricing_Group_Nm__c = qGrp.Id;
        update quoteList;
        Test.startTest();
        Pricing_LinkQuotesController.getQuoteGroupDtlsUnlink(quoteList[0].Id,qGrp.Id);
        Test.stopTest();
    }
    static testMethod void testGetQuoteGroupDtlsUnlinkWGrpTwoQuotes(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name FROM SBQQ__Quote__c LIMIT 2];
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        List<SBQQ__Quote__c> quoteListUpd = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote: quoteList){
            quoteNumList.add(quote.Name);
            quote.Pricing_Group_Nm__c = qGrp.Id;
            quoteListUpd.add(quote);
        }
        update quoteListUpd;
        Test.startTest();
        Pricing_LinkQuotesController.getQuoteGroupDtlsUnlink(quoteList[0].Id,qGrp.Id);
        Test.stopTest();
    }
    static testMethod void testGetQuoteGroupDtlsUnlinkWGrpExt(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, SBQQ__PrimaryContact__c, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name 
                                          from SBQQ__Quote__c LIMIT 1];
        quoteNumList.add(quoteList[0].Name);
        User extUser = [Select id from User where ContactId =: quoteList[0].SBQQ__PrimaryContact__c];
        System.runAs(extUser){
            Test.startTest();
            Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
            quoteList[0].Pricing_Group_Nm__c = qGrp.Id;
            update quoteList;
            Pricing_LinkQuotesController.getQuoteGroupDtlsUnlink(quoteList[0].Id,qGrp.Id);
            Test.stopTest();
        }
    }
    static testMethod void testGetQuoteGroupDtlsUnlinkWGrpTwoQuotesExt(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name, SBQQ__PrimaryContact__c 
                                          FROM SBQQ__Quote__c LIMIT 2];
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        List<SBQQ__Quote__c> quoteListUpd = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote: quoteList){
            quoteNumList.add(quote.Name);
            quote.Pricing_Group_Nm__c = qGrp.Id;
            quoteListUpd.add(quote);
        }
        update quoteListUpd;
        User extUser = [Select id from User where ContactId =: quoteList[0].SBQQ__PrimaryContact__c];
        System.runAs(extUser){
            Test.startTest();
            Pricing_LinkQuotesController.getQuoteGroupDtlsUnlink(quoteList[0].Id,qGrp.Id);
            Test.stopTest();
        }
    }
    static testMethod void testGetQuoteGroupDtlsUnlinkWoGrp(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name from SBQQ__Quote__c LIMIT 1];
        quoteNumList.add(quoteList[0].Name);
        quoteList[0].Pricing_Group_Nm__c = null;
        update quoteList;
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        Test.startTest();
        Pricing_LinkQuotesController.getQuoteGroupDtlsUnlink(quoteList[0].Id,qGrp.Id);
        Test.stopTest();
    }
    static testMethod void testGetQuoteGroupDtlsUnlinkWoGrpExt(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, SBQQ__PrimaryContact__c, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name 
                                          from SBQQ__Quote__c LIMIT 1];
        quoteNumList.add(quoteList[0].Name);
        quoteList[0].Pricing_Group_Nm__c = null;
        update quoteList;
        User extUser = [Select id from User where ContactId =: quoteList[0].SBQQ__PrimaryContact__c];
        System.runAs(extUser){
            Test.startTest();
            Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
            Pricing_LinkQuotesController.getQuoteGroupDtlsUnlink(quoteList[0].Id,qGrp.Id);
            Test.stopTest();
        }
    }
    static testMethod void testVerifyLinkStatusTwoQuotesWGrp(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteLstUpd = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name from SBQQ__Quote__c LIMIT 1];
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        List<SBQQ__Quote__c> quoteListNums = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name 
                                              FROM SBQQ__Quote__c WHERE Id !=: quoteList[0].Id LIMIT 2];
        for(SBQQ__Quote__c qt: quoteListNums){
            qt.Pricing_Group_Nm__c = qGrp.Id;
            quoteLstUpd.add(qt);
            quoteNumList.add(qt.Name);
        }
        update quoteLstUpd;
        Test.startTest();
        Pricing_LinkQuotesController.verifyLinkStatus(quoteNumList);
        Test.stopTest();
    }
    static testMethod void testVerifyLinkStatusOneQuote(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name from SBQQ__Quote__c LIMIT 1];
        SBQQ__Quote__c quoteNumRec = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name 
                                      FROM SBQQ__Quote__c WHERE Id !=: quoteList[0].Id LIMIT 1];
        quoteNumList.add(quoteNumRec.Name);
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        Test.startTest();
        Pricing_LinkQuotesController.verifyLinkStatus(quoteNumList);
        Test.stopTest();
    }
    static testMethod void testVerifyLinkStatusOneQuoteWGrp(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name from SBQQ__Quote__c LIMIT 1];
        SBQQ__Quote__c quoteNumRec = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name 
                                      FROM SBQQ__Quote__c WHERE Id !=: quoteList[0].Id LIMIT 1];
        quoteNumList.add(quoteNumRec.Name);
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        quoteList[0].Pricing_Group_Nm__c = qGrp.Id;
        update quoteList;
        Test.startTest();
        Pricing_LinkQuotesController.verifyLinkStatus(quoteNumList);
        Test.stopTest();
    }
    static testMethod void testVerifyLinkStatusTwoQuotesWTwoGrps(){
        List<String> quoteNumList = new List<String>();
        List<SBQQ__Quote__c> quoteLstUpd = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name from SBQQ__Quote__c LIMIT 1];
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        List<SBQQ__Quote__c> quoteListNums = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name 
                                              FROM SBQQ__Quote__c WHERE Id !=: quoteList[0].Id LIMIT 2];
        for(SBQQ__Quote__c qt: quoteListNums){
            quoteNumList.add(qt.Name);
        }
        quoteListNums[0].Pricing_Group_Nm__c = qGrp.Id;
        Pricing_Quote_Group__c qGrpNew = new Pricing_Quote_Group__c();
        insert qGrpNew;
        quoteListNums[1].Pricing_Group_Nm__c = qGrpNew.Id;
        update quoteListNums;
        Test.startTest();
        Pricing_LinkQuotesController.verifyLinkStatus(quoteNumList);
        Test.stopTest();
    }
    static testMethod void testGetQuoteNumber(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c from SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        Pricing_LinkQuotesController.getQuoteNumber(quoteList[0].Id);
        Test.stopTest();
    }
    static testMethod void testGetMetadataColumns(){
        Test.startTest();
        Pricing_LinkQuotesController.getMetadataColumns('Quote');
        Pricing_LinkQuotesController.isReadOnlyUser();
        Test.stopTest();
    }
    static testMethod void testGetQuoteGroupLinkStatus(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c from SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        Pricing_LinkQuotesController.getQuoteGroupLinkStatus(quoteList[0].Id);
        Test.stopTest();
    }
    static testMethod void testGetQuoteGroupLinkStatusWGrp(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c from SBQQ__Quote__c LIMIT 1];
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        quoteList[0].Pricing_Group_Nm__c = qGrp.Id;
        update quoteList;
        Test.startTest();
        Pricing_LinkQuotesController.getQuoteGroupLinkStatus(quoteList[0].Id);
        Test.stopTest();
    }
}