/**
 * @description       : 
 * @author            : Sandeep Chamate
 * @group             : 
 * @last modified on  : 05-10-2024
 * @last modified by  : Sandeep Chamate
**/
@isTest
public class Pricing_QuoteCloneController_Test {
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('quoteCloneControllerAdmin');
        Pricing_Test_Utility.createPriceBook();

        System.runAs(adminUserList[0]){
            //Pricing_Test_Utility.createPriceBook();
            
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Clone_Controller');
            
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            User partnerUserList = Pricing_Test_Utility.createPartnerUser(acc.Id);
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
            insert accTeam;
            AccountTeamMember accTeam2 = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam2;
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
            Core_Trigger_Executions__c triggerEntry2 = new Core_Trigger_Executions__c();
            triggerEntry2.name = 'pricingSendOutboundMessagesIQR';
            triggerEntry2.Core_Object__c = 'Descriptive Feature';
            triggerEntry2.Core_Trigger_Events__c = 'After insert';
            triggerEntry2.Core_Active__c = TRUE;
            triggerEntry2.Core_Description__c = 'This is test description';
            triggerEntry2.Core_Class_Name__c = 'Test Class';
            insert triggerEntry2;
            
            Pricing_Quote_Team__c quoteTM = new Pricing_Quote_Team__c();  
            quoteTM.Pricing_Quote_Id__c = quoteList[0].Id;
            quoteTM.Pricing_Quote_Team_Member_Id__c = adminUserList[0].id;
            quoteTM.Pricing_Role_Nm__c = 'Account Executive'; 
            insert quoteTM;
            
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
            //The setUpData covers 54% for quote creation
            
            //Creating data for Object1 and Object2
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedAccountObj;
            unifiedAccountObj = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedAccountObj.Name = 'Test';
            unifiedAccountObj.Pricing_Unified_EndCustomer_Id__c = '123';
            unifiedAccountObj.Pricing_Account_Nm__c = acc.Id;
            insert unifiedAccountObj;
            
            Pricing_UnifiedEndCustomerCountryMapping__c unifiedCountryObj;
            unifiedCountryObj = new Pricing_UnifiedEndCustomerCountryMapping__c();
            unifiedCountryObj.Pricing_Unified_EndCustomer_Act_Mapping__c = unifiedAccountObj.Id;
            unifiedCountryObj.Name = 'Test';
            unifiedCountryObj.Pricing_Unified_Country_EndCustomer_Id__c = '111';
            insert unifiedCountryObj;
        }
    }
    
    static testMethod void testCloneasAdminUser(){
        //Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Intel_Account_Exec_Email_Txt__c from SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Pricing_Quote_Line_Number__c,SBQQ__Quote__c,Pricing_Req_Discounted_Unit_Price__c,SBQQ__Quote__r.OwnerId,RecordType.Name,Pricing_Sales_Rep__c, Pricing_Status_Nm__c from SBQQ__QuoteLine__c LIMIT 1];
        quoteLineList[0].Pricing_Quote_Line_Number__c = null;
      	update quoteLineList;
        User adminUser = [Select id from User where Email='quoteCloneControllerAdmin@intel.com'];
        Pricing_QuoteCloneController.GlobalVariables globalVar = new Pricing_QuoteCloneController.GlobalVariables();
        String msg;
        Test.startTest();
        System.runAs(adminUser){
            try{
                globalVar = Pricing_QuoteCloneController.doClone(quote.Id,Label.Pricing_Tender_Standard_Quote);
                //quoteLineList[0].Pricing_Req_Discounted_Unit_Price__c = -10;
                //update quoteLineList;
				Pricing_QuoteCloneController.doClone(quoteLineList[0].Id,Label.Pricing_Tender_Standard_QuoteLine);
            }
            catch(DmlException e){
                msg = e.getMessage();
            }
        }
        Test.stopTest();
        System.assert(globalVar.isSuccess,''+msg);
    }
    
    static testMethod void testCloneaCrossQuoteType(){
        //Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Pricing_Quote_Line_Number__c,SBQQ__Quote__c,Pricing_Req_Discounted_Unit_Price__c,SBQQ__Quote__r.OwnerId,RecordType.Name,Pricing_Sales_Rep__c, Pricing_Status_Nm__c from SBQQ__QuoteLine__c LIMIT 1];
        quoteLineList[0].Pricing_Quote_Line_Number__c = null;
      	update quoteLineList;
        User adminUser = [Select id from User where Email='quoteCloneControllerAdmin@intel.com'];
        Pricing_QuoteCloneController.GlobalVariables globalVar = new Pricing_QuoteCloneController.GlobalVariables();
        String msg;
        Test.startTest();
        System.runAs(adminUser){
            try{
                globalVar = Pricing_QuoteCloneController.doClone(quote.Id,Label.Pricing_Tender_SSD_Quote);
                //quoteLineList[0].Pricing_Req_Discounted_Unit_Price__c = -10;
                //update quoteLineList;
                Pricing_QuoteCloneController.doClone(quoteLineList[0].Id,Label.Pricing_Tender_SSD_Quote);
            }
            catch(DmlException e){
                msg = e.getMessage();
            }
        }
        Test.stopTest();
        System.assert(globalVar.isSuccess,''+msg);
    }

   /* static testMethod void testCloneAsAE(){
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Pricing_Quote_Line_Number__c,SBQQ__Quote__c,SBQQ__Quote__r.OwnerId,RecordType.Name,Pricing_Sales_Rep__c, Pricing_Status_Nm__c from SBQQ__QuoteLine__c LIMIT 1];
        quoteLineList[0].Pricing_Quote_Line_Number__c = null;
      	update quoteLineList;
        User AEUser = [Select id from User where Email='firstNameAE@intel.com'];
        Pricing_QuoteCloneController.GlobalVariables globalVar = new Pricing_QuoteCloneController.GlobalVariables();
        String msg;
        Test.startTest();
        System.runAs(AEUser){
            globalVar = Pricing_QuoteCloneController.doClone(quote.id,Label.Pricing_Tender_Standard_Quote);
        }
        Test.stopTest();
        System.assert(globalVar.isSuccess,''+msg);
    }*/
    
   
    
    static testMethod void testCloneEndCustomer(){
        //Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id,Pricing_Unified_Global_End_Customer_Nm__c,Pricing_End_Customer__c,Pricing_Customer_Nm__c,Pricing_IsUnifiedCustomer__c FROM SBQQ__Quote__c LIMIT 1];
         List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Pricing_Quote_Line_Number__c,SBQQ__Quote__c,SBQQ__Quote__r.OwnerId,RecordType.Name,Pricing_Sales_Rep__c, Pricing_Status_Nm__c from SBQQ__QuoteLine__c LIMIT 1];
        quoteLineList[0].Pricing_Quote_Line_Number__c = null;
      	update quoteLineList;
        Pricing_UnifiedEndCustomerCountryMapping__c unifiedCountryObj = [SELECT Id FROM Pricing_UnifiedEndCustomerCountryMapping__c LIMIT 1];
        User adminUser = [Select id from User where Email='quoteCloneControllerAdmin@intel.com'];
        Pricing_QuoteCloneController.GlobalVariables globalVar = new Pricing_QuoteCloneController.GlobalVariables();
        Test.startTest();
        System.runAs(adminUser){
            //quote.Pricing_End_Customer__r.Name = 'Write In End customer';
            //quote.Pricing_Customer_Nm__c = 'Test';
            quote.Pricing_Unified_Global_End_Customer_Nm__c = unifiedCountryObj.Id;
            update quote;
            globalVar = Pricing_QuoteCloneController.doClone(quote.Id,Label.Pricing_Tender_Standard_Quote);
        }
        Test.stopTest();
        System.assert(globalVar.isSuccess,'Error in Pricing_QuoteCloneController.doClone');
    }

    static testMethod void testCloneAsInternalAndPartnerUser(){
        Pricing_QuoteCloneController.GlobalVariables globalVar = new Pricing_QuoteCloneController.GlobalVariables();
        test.startTest();
        //Account acc = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__PrimaryContact__c, SBQQ__Account__r.Id from SBQQ__Quote__c LIMIT 1];
        //User loggedInUserContactId = [SELECT Id, Name, ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        //Contact c = [SELECT Id, LastName FROM Contact WHERE Email = 'FirstName@intel.com'];
        //quote.SBQQ__PrimaryContact__c = c.Id;
        //update quote;
        globalVar =  Pricing_QuoteCloneController.doClone(quote.Id,Label.Pricing_Tender_Standard_Quote);
        test.stopTest();
        //System.assert(globalVar.isSuccess,'Error in Pricing_QuoteCloneController.doClone');
    }
    
    static testMethod void testGetQuoteDetails(){
        test.startTest();
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__Quote__c newQuote = Pricing_QuoteCloneController.getQuoteDetails(quote.Id);
        test.stopTest();
        System.assert(quote.Id == newQuote.Id,'Error in getQuoteDetails');
	}
    
    static testMethod void testIsSVDCloneAllowed(){
        test.startTest();
        SBQQ__Quote__c quote = [SELECT Id,SBQQ__Account__c FROM SBQQ__Quote__c LIMIT 1];
        Boolean isSVD = Pricing_QuoteCloneController.isSVDCloneAllowed(quote.SBQQ__Account__c);
        System.assert(isSVD == false, 'SVD not allowed');
        test.stopTest();
    }
}