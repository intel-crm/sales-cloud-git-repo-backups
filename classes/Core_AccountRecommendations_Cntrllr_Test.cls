@isTest
public class Core_AccountRecommendations_Cntrllr_Test {
    
    static testMethod void testAccountRecommendations_Controller() {
        
        // Pages, controller, and parameter map we'll use for testing
        PageReference recPage = Page.Core_AccountRecommendations;
        PageReference nextPage = null;
        Core_AccountRecommendations_Controller recController;
        
        // Set up a test account that we'll use
        Account acct;
        acct = Core_Test_Utility.Core_Account(1)[0];
        acct.Core_CIM_ID__c = '999293859';
        insert acct;
        
        Test.startTest();
        
        // Test with no recommendations data, to ensure null is returned
        Test.setCurrentPage(recPage);
        ApexPages.currentPage().getParameters().put('AccountId', acct.Id);
        Core_Account_Recommendations__c rec = new Core_Account_Recommendations__c();
        recController = new Core_AccountRecommendations_Controller(new ApexPages.StandardController(rec));
        nextPage = recController.onLoad();
        System.assertEquals(null, nextPage);
        
        // Add some recommendations data for our test account
        rec = new Core_Account_Recommendations__c(
            Core_Account__c = acct.Id, Core_CIM_ID__c = acct.Core_CIM_ID__c, Core_Account_Product_Type__c = 'test',
            Core_Brand_Top_Sales_1_Item__c = 'a', Core_Brand_Top_Sales_1_Last_Purchase_Dt__c = '201506', Core_Brand_Top_Sales_1_Last_Purchase_Qty__c = 90, Core_Brand_Top_Sales_1_Total_Qty__c = 900,
            Core_Brand_Top_Sales_2_Item__c = 'b', Core_Brand_Top_Sales_2_Last_Purchase_Dt__c = '201506', Core_Brand_Top_Sales_2_Last_Purchase_Qty__c = 80, Core_Brand_Top_Sales_2_Total_Qty__c = 800,
            Core_Brand_Top_Sales_3_Item__c = 'c', Core_Brand_Top_Sales_3_Last_Purchase_Dt__c = '201506', Core_Brand_Top_Sales_3_Last_Purchase_Qty__c = 70, Core_Brand_Top_Sales_3_Total_Qty__c = 700,
            Core_Comp_Top_Sales_1_Item__c = 'd', Core_Comp_Top_Sales_1_Last_Purchase_Dt__c = '201506', Core_Comp_Top_Sales_1_Last_Purchase_Qty__c = 90, Core_Comp_Top_Sales_1_Total_Qty__c = 900,
            Core_Comp_Top_Sales_2_Item__c = 'e', Core_Comp_Top_Sales_2_Last_Purchase_Dt__c = '201506', Core_Comp_Top_Sales_2_Last_Purchase_Qty__c = 80, Core_Comp_Top_Sales_2_Total_Qty__c = 800,
            Core_Comp_Top_Sales_3_Item__c = 'f', Core_Comp_Top_Sales_3_Last_Purchase_Dt__c = '201506', Core_Comp_Top_Sales_3_Last_Purchase_Qty__c = 70, Core_Comp_Top_Sales_3_Total_Qty__c = 700,
            Core_Feedback_1_Indicator__c = '1', Core_Feedback_1_Timestamp__c = DateTime.now(), Core_Feedback_1_User__c = UserInfo.getUserId(),
            Core_Feedback_2_Indicator__c = '0', Core_Feedback_2_Timestamp__c = DateTime.now(), Core_Feedback_2_User__c = UserInfo.getUserId(),
            Core_Feedback_3_Indicator__c = '1', Core_Feedback_3_Timestamp__c = DateTime.now(), Core_Feedback_3_User__c = UserInfo.getUserId(),
            Core_Geography__c = 'EMEA', Core_Model_Timestamp__c = DateTime.now(), Core_Organization_Account_ID__c = '83729028',
            Core_Product_Recommended_1_Based_On__c = 'a', Core_Product_Recommended_1_Early_Adopter__c = true, Core_Product_Recommended_1_Form_Factor__c = 'a',
            	Core_Product_Recommended_1_ID__c = 111111, Core_Product_Recommended_1_Name__c = 'a', Core_Product_Recommended_1_Sell_Type__c = 'cross', Core_Product_Recommended_1_Type__c = 'a',
            Core_Product_Recommended_2_Based_On__c = 'b', Core_Product_Recommended_2_Early_Adopter__c = false, Core_Product_Recommended_2_Form_Factor__c = 'b',
            	Core_Product_Recommended_2_ID__c = 222222, Core_Product_Recommended_2_Name__c = 'b', Core_Product_Recommended_2_Sell_Type__c = 'up', Core_Product_Recommended_2_Type__c = 'b',
            Core_Product_Recommended_3_Based_On__c = 'c', Core_Product_Recommended_3_Early_Adopter__c = true, Core_Product_Recommended_3_Form_Factor__c = 'c',
            	Core_Product_Recommended_3_ID__c = 333333, Core_Product_Recommended_3_Name__c = 'c', Core_Product_Recommended_3_Sell_Type__c = 'cross', Core_Product_Recommended_3_Type__c = 'c',
            Core_Recommendations_Viewed__c = false);
        insert rec;
        
        // Test with nothing passed, to ensure null is returned from the methods
        Test.setCurrentPage(recPage);
        ApexPages.currentPage().getParameters().clear();
        recController = new Core_AccountRecommendations_Controller(new ApexPages.StandardController(rec));
        nextPage = recController.onLoad();
        System.assertEquals(null, nextPage);
        nextPage = recController.goToAccount();
        System.assertEquals(null, nextPage);
        
        // Test with only the Account ID passed, to ensure the page returned is the proper redirect page
        Test.setCurrentPage(recPage);
        ApexPages.currentPage().getParameters().put('AccountId', acct.Id);
        recController = new Core_AccountRecommendations_Controller(new ApexPages.StandardController(rec));
        nextPage = recController.onLoad();
        System.assert(nextPage.getUrl().containsIgnoreCase(Page.Core_AccountRecommendations.getUrl()));
        System.assertEquals(rec.Id, nextPage.getParameters().get('Id'));
        
        // Test with the ID passed, to ensure everything works properly
        Test.setCurrentPage(recPage);
        ApexPages.currentPage().getParameters().put('Id', rec.Id);
        recController = new Core_AccountRecommendations_Controller(new ApexPages.StandardController(rec));
        System.assertEquals(true, recController.isAccessAllowed);
        nextPage = recController.onLoad();
        System.assertEquals(null, nextPage);
        System.assertNotEquals(null, recController.getFeedbackOptions());
        System.assertNotEquals(null, recController.goToAccount());
        
        // Create a random user who would not have access to the page
        Test.setCurrentPage(recPage);
        ApexPages.currentPage().getParameters().put('Id', rec.Id);
        User randomUser = new User(FirstName='Random', LastName='User', Alias='ranuser', Email='random.user1239871230@intel.com',
                                   Username='random.user1239871230@test.com.crm', CommunityNickname='random.user',
                                   ProfileId=[select Id from Profile where Name='Sales Rep-BB' limit 1][0].Id,
                                   TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US',
                                   Core_Employee_Type_Code__c='EMP', Core_Employee_Status_Code__c='A');
        insert randomUser;
        
        // Make sure the user can view the account (for some reason, just inserting them as 'EMP' isn't working to give access)
        AccountShare acctShare = new AccountShare(UserOrGroupId=randomUser.Id, AccountId=acct.Id, AccountAccessLevel='Read',
                                                  OpportunityAccessLevel='None');
        insert acctShare;
        
        // Load the page as the random user and make sure they don't have access
        System.runAs(randomUser) {
            recController = new Core_AccountRecommendations_Controller(new ApexPages.StandardController(rec));
            System.assertEquals(false, recController.isAccessAllowed);
            nextPage = recController.onLoad();
            System.assertEquals(null, nextPage);
        }
        
        // Now give that user access, reload the page, and save some data, to make sure fields get updated
        acctShare = new AccountShare(UserOrGroupId=randomUser.Id, AccountId=acct.Id, AccountAccessLevel='Edit',
                                     OpportunityAccessLevel='Edit');
        insert acctShare;
        
        // Fix a minor issue that causes the test to fail
        rec.Core_Feedback_1_User__c = null;
        rec.Core_Feedback_2_User__c = null;
        rec.Core_Feedback_3_User__c = null;
        update rec;
        
        // Save the feedback and make sure the values changed
        System.runAs(randomUser) {
            Test.setCurrentPage(recPage);
            ApexPages.currentPage().getParameters().put('Id', rec.Id);
            recController = new Core_AccountRecommendations_Controller(new ApexPages.StandardController(rec));
            System.assertEquals(true, recController.isAccessAllowed);
            nextPage = recController.onLoad();
            
            rec.Core_Feedback_1_Indicator__c = '0';
            rec.Core_Feedback_2_Indicator__c = '1';
            rec.Core_Feedback_3_Indicator__c = '0';
            nextPage = recController.saveFeedback();
            
            System.assertEquals(randomUser.Id, rec.Core_Feedback_1_User__c);
            System.assertEquals(randomUser.Id, rec.Core_Feedback_2_User__c);
            System.assertEquals(randomUser.Id, rec.Core_Feedback_3_User__c);
        }
        
        // Remove the user's access, then add them to the exec access group
        acctShare = [select Id, AccountAccessLevel, OpportunityAccessLevel from AccountShare
                     where UserOrGroupId = :randomUser.Id and AccountId = :acct.Id];
        acctShare.AccountAccessLevel = 'Read';
        acctShare.OpportunityAccessLevel = 'None';
        update acctShare;
        
        System.runAs(new User(Id=UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId=[select Id from group where DeveloperName = :Label.Core_Account_330_Executive_Access limit 1][0].Id,
                                             UserOrGroupId=randomUser.Id);
            insert gm;
        }
        
        // Exercise the code path that checks exec group access
        System.runAs(randomUser) {
            Test.setCurrentPage(recPage);
            ApexPages.currentPage().getParameters().put('Id', rec.Id);
            recController = new Core_AccountRecommendations_Controller(new ApexPages.StandardController(rec));
            System.assertEquals(true, recController.isAccessAllowed);
        }
        
        // Add the user to an account team and check that path
        AccountTeamMember atm = new AccountTeamMember(AccountId=acct.Id, UserId=randomUser.Id, TeamMemberRole='Team Member');
        insert atm;
        
        System.runAs(randomUser) {
            Test.setCurrentPage(recPage);
            ApexPages.currentPage().getParameters().put('Id', rec.Id);
            recController = new Core_AccountRecommendations_Controller(new ApexPages.StandardController(rec));
            System.assertEquals(true, recController.isAccessAllowed);
        }
        
        Test.stopTest();
    }
}