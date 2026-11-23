/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-23-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_PriceRulesEmailController_Test {
    //Method to setup test data
    @testSetup
    public static void setUpData(){
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();
        system.runAs(lstUsers2[0])
        {
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            List<Contact> drLimitedConList = Pricing_Test_Utility.createDrafterLimitedContact(acc.Id,1);
            Contact con =drLimitedConList[0];
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Test.startTest();
            
            
            Document document;
            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;
            
            Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
            insert prod;
            
            Pricing_Approval_Price_Rules__c approvalPriceRule = new Pricing_Approval_Price_Rules__c(
            Pricing_Rule_Name__c = 'Test Rule',
            Pricing_Approval_Status__c = 'Pending',
            Pricing_End_Date__c = Date.today().addMonths(1),
            Pricing_Quote_Type__c = 'Client',
            Pricing_Account__c = acc.Id,
            Pricing_End_Customer_Country__c = 'India',
            Pricing_Form_Factor__c = 'AIO',
            Pricing_Intel_Account_Exec_Email_Txt__c = 'exec@example.com',
            Pricing_Intel_Sales_Rep_Email_Txt__c = 'rep@example.com',
            Pricing_Market_Segment_values_Nm__c = 'Corp');
            insert approvalPriceRule;
            
            
            Test.stopTest();
        }
    }
    //Method to test Pricing_PriceRulesEmailController class
    @isTest
    public static void testPriceRulesEmailController1()
    {
        Test.StartTest();
        List<Pricing_Approval_Price_Rules__c> lstApprovalPriceRules = [SELECT Id, Name, Pricing_Quote_Type__c, Pricing_Form_Factor__c, Pricing_Server_Deal_Type_Nm__c, Pricing_End_Customer_Country__c, Pricing_Account__r.Name, Pricing_Market_Segment_values_Nm__c, Pricing_Intel_Sales_Rep_Email_Txt__c, Pricing_Intel_Account_Exec_Email_Txt__c, Pricing_Approval_Status__c
                                                                       FROM Pricing_Approval_Price_Rules__c  LIMIT 1];
        
        
        List<User> lstUsers = Pricing_Test_Utility.createUser();
        Pricing_PriceRulesEmailController p1 = new Pricing_PriceRulesEmailController();
        p1.approvalPriceRuleId = lstApprovalPriceRules[0].Id;
        String domain = p1.getDomainName();
        p1.getHeaderURL();
        System.assertEquals(String.valueOf(URL.getOrgDomainUrl().toExternalForm()),domain,'Domain Name is Incorrect');
        Test.StopTest();
    }
    
    @isTest
    public static void testPriceRulesEmailController2(){
        Test.startTest();
        Pricing_PriceRulesEmailController p2 = new Pricing_PriceRulesEmailController();
        p2.approvalPriceRuleId = 'aFODf000000012tOAz'; // Non-existent Id
        Pricing_Approval_Price_Rules__c rule = p2.approvalPriceRuleDetails();
        System.assertNotEquals(null, rule);
        Pricing_PriceRulesEmailController p3 = new Pricing_PriceRulesEmailController();
        p3.approvalPriceRuleId = null; 
        p3.approvalPriceRuleDetails(); 
        Test.stopTest();
        
    }
}