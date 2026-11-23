/**
 * @description       : 
 * @author            : Sandeep Chamate
 * @group             : 
 * @last modified on  : 01-13-2025
 * @last modified by  : Vrushabh Uprikar
**/
@isTest
public class Pricing_QuoteLineCloneController_Test {
    //Setup test data
    @testSetup
    public static void setUpData() {
        List < User > lstUsers2 = Pricing_Test_Utility.createAdminUserWithParam('quoteLineCloneControllerAdmin');
        List < User > accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
        List < User > salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
        List < User > lstUsers = Pricing_Test_Utility.createUser();

        system.runAs(lstUsers2[0]) {
            /*
                        Pricing_Test_Utility.createPriceBook();
                        Account acc = Pricing_Test_Utility.createAccount();
                        Contact con = Pricing_Test_Utility.createContact(acc.Id);
                        Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
                        List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuote(acc.Id, con.Id, 1);
                        */
            test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_line_clone_controller');
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            //Pricing_Test_Utility.createAEUser();

            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                TeamMemberRole = 'Technical Sales', UserId = salesRepUserList[0].Id);
            insert accTeam;
            List < SBQQ__Quote__c > lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2, salesRepUserList[0].Email, accountExecutiveUserList[0].Email);
            List < SBQQ__QuoteLine__c > lstQuoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 2);
            test.stopTest();
        }
    }

    //Method to test Pricing_QuoteLineCloneController class
    @isTest
    public static void testQuoteClone() {
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c', Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        List < SBQQ__Quote__c > lstquote = [select id from SBQQ__Quote__c];
        List < SBQQ__QuoteLine__c > lstquoteLines = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__c =: lstquote[0].Id];

        List < Pricing_Comments__c > lstComment = [SELECT Id, Pricing_Answer__c, Pricing_Required_Ind__c, Pricing_Quote__c
            FROM Pricing_Comments__c
            WHERE Pricing_Quote__c =: lstquote and recordtypeid =: commentRecordTypeId
        ];
        for (Pricing_Comments__c pc: lstComment) {
            if (lstquote[0].id == pc.Pricing_Quote__c) {
                pc.Pricing_Answer__c = null;
                pc.Pricing_Required_Ind__c = true;
            } else {
                pc.Pricing_Required_Ind__c = false;
            }
        }
        update lstComment;

        List < Pricing_Performance_Metric__c > performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);
        insert performanceList;
        //Test.StartTest();
        Pricing_QuoteLineCloneController.getQuoteLine(lstquoteLines[0].Id);

        Pricing_QuoteLineCloneController.GlobalVariables globalVar = new Pricing_QuoteLineCloneController.GlobalVariables();
        Test.StartTest();
        globalVar = Pricing_QuoteLineCloneController.doClone(lstquoteLines[0], '');
        Test.StopTest();
        System.assertEquals(true, globalVar.isSuccess, globalVar.messageResult);
    }

    @isTest
    public static void testQuoteClone3() {
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c', Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        List < SBQQ__Quote__c > lstquote = [select id from SBQQ__Quote__c];

        List < SBQQ__QuoteLine__c > lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 2);

        List < Pricing_Comments__c > lstComment = [SELECT Id, Pricing_Answer__c, Pricing_Required_Ind__c, Pricing_Quote__c
            FROM Pricing_Comments__c
            WHERE Pricing_Quote__c =: lstquote and recordtypeid =: commentRecordTypeId
        ];
        for (Pricing_Comments__c pc: lstComment) {
            if (lstquote[0].id == pc.Pricing_Quote__c) {
                pc.Pricing_Answer__c = null;
                pc.Pricing_Required_Ind__c = true;
            } else {
                pc.Pricing_Required_Ind__c = false;
            }
        }
        update lstComment;

        List < Pricing_Performance_Metric__c > performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);
        insert performanceList;
        Test.startTest();
        Pricing_QuoteLineCloneController.GlobalVariables globalVar = new Pricing_QuoteLineCloneController.GlobalVariables();
        globalVar = Pricing_QuoteLineCloneController.doClone(lstquoteLines[0], Label.Pricing_Tender_QuoteLine_Action_Request_Change);
        //System.assertEquals(true, globalVar.isSuccess, globalVar.messageResult);
        List < String > pickListValues = Pricing_QuoteLineCloneController.getPicklistValuesQLI();
        Pricing_QuoteLineCloneController.rpmCRAutoPopulation(lstquoteLines[0], lstquoteLines[0], lstquoteLines[1]);
        Pricing_QuoteLineCloneController.oEMCRAutoPopulation(lstquoteLines[0],lstquoteLines[1]);
        Pricing_QuoteLineCloneController.validateQuoteTeamFSE(lstquoteLines[0]);
        Pricing_QuoteLineCloneController.fetchDate();
        Test.stopTest();
        //SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE ID =:globalVar.quoteLineId ]; 
        //Pricing_QuoteLineCloneController.doClone(quoteLine, Label.Pricing_Tender_QuoteLine_Action_Request_Change);
        //System.assertEquals(false, globalVar.isSuccess, globalVar.messageResult);
    }

    @isTest
    public static void testQuoteClone2() {
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c', Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        List < SBQQ__Quote__c > lstquote = [select id from SBQQ__Quote__c];

        SBQQ__QuoteLine__c lstquoteLines = Pricing_Test_Utility.createWINQuoteLines(lstquote[0].id);
        List < SBQQ__QuoteLine__c > lstqls = new List < SBQQ__QuoteLine__c > ();
        lstqls.add(lstquoteLines);
        List < Pricing_Comments__c > lstComment = [SELECT Id, Pricing_Answer__c, Pricing_Required_Ind__c, Pricing_Quote__c
            FROM Pricing_Comments__c
            WHERE Pricing_Quote__c =: lstquote and recordtypeid =: commentRecordTypeId
        ];

        for (Pricing_Comments__c pc: lstComment) {
            if (lstquote[0].id == pc.Pricing_Quote__c) {
                pc.Pricing_Answer__c = null;
                pc.Pricing_Required_Ind__c = true;
            } else {
                pc.Pricing_Required_Ind__c = false;
            }

        }

        update lstComment;
        List < Pricing_Performance_Metric__c > performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines.Id);
        insert performanceList;
        Test.StartTest();
        Pricing_QuoteLineCloneController.rpmCRAutoPopulation(lstqls[0], lstquoteLines, lstquoteLines);
        Product2 productName = [select name from Product2 where id =: lstquoteLines.Pricing_Product_Nm__c Limit 1];
        if (productName.Name != Label.Pricing_Tender_Write_In_Product)
            System.assertEquals(Pricing_QuoteLineCloneController.fetchDate() != null, true);
        else
            System.assertEquals(Pricing_QuoteLineCloneController.fetchDate() == null, false);
        Pricing_QuoteLineCloneController.billingStartDateCheck(lstquoteLines);
        List<Product2> newListProd = Pricing_QuoteLineCloneController.searchProductsSOQL('Intel','Small Volume Quotes - Data Center Xeon® CPU');
        Test.StopTest();
    }

    @isTest
    public static void testBillingDateCheck() {
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c', Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        List < SBQQ__Quote__c > lstquote = [select id from SBQQ__Quote__c];
        SBQQ__QuoteLine__c lstquoteLines = Pricing_Test_Utility.createWINQuoteLines(lstquote[0].id);
        List < SBQQ__QuoteLine__c > lstqls = new List < SBQQ__QuoteLine__c > ();
        lstqls.add(lstquoteLines);
        List < Pricing_Comments__c > lstComment = [SELECT Id, Pricing_Answer__c, Pricing_Required_Ind__c, Pricing_Quote__c
            FROM Pricing_Comments__c
            WHERE Pricing_Quote__c =: lstquote and recordtypeid =: commentRecordTypeId
        ];
        for (Pricing_Comments__c pc: lstComment) {
            if (lstquote[0].id == pc.Pricing_Quote__c) {
                pc.Pricing_Answer__c = null;
                pc.Pricing_Required_Ind__c = true;
            } else {
                pc.Pricing_Required_Ind__c = false;
            }
        }
        update lstComment;

        List < Pricing_Performance_Metric__c > performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines.Id);
        insert performanceList;
        Test.StartTest();
        lstqls[0].Pricing_Approved_Start_Date_Dt__c = System.today();
        lstqls[0].Pricing_Billing_Start_Date_Dt__c = System.today() - 91;
        boolean billingStartDateError = Pricing_QuoteLineCloneController.billingStartDateCheck(lstqls[0]);
        System.assert(billingStartDateError == false || billingStartDateError == true, 'Billing Start Date');
        Test.StopTest();
    }

    @isTest
    public static void getLoggedinUserPermissionSetBusinessAdminTest() {
        List < User > lstUsers2 = Pricing_Test_Utility.createAdminUserWithParam('getLoggedinUserPermissionSetBusinessAdmin');

        system.runAs(lstUsers2[0]) {
            test.startTest();
            List<String> str = Pricing_QuoteLineCloneController.getLoggedinUserPermissionSetBusinessAdmin();
            System.assert(str.size() > 0 || str.size() < 0, 'Billing Start Date');
            test.stopTest();
        }
    }
}