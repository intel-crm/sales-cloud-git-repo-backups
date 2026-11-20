/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-09-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_QuoteHoldStatusAgeHandler_Test {
    
    static testmethod void setUpData(){
        Test.startTest();
    	List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Hold_Status_Age_Handler_Test');
            User partnerUser = Pricing_Test_Utility.createPartnerAdminUser(acc.Id);
            Group grp = Pricing_Test_Utility.createGroupRecord();
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = adminUserList[0].id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;
            ChannelProgram chProg = Pricing_Test_Utility.createChannelProgramRecord();
            List<Core_MDF_Partner_Group_Mapping__c> partnerGroupList = Pricing_Test_Utility.createPGMRecord(acc,grp,chProg,1);
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuote(acc.Id, con.Id, 1);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
            Pricing_Quote_Hold_Status_Age__c onHoldEntry = new Pricing_Quote_Hold_Status_Age__c();
            onHoldEntry.Pricing_QuoteOnHold__c = quoteList[0].Id;
            onHoldEntry.Pricing_Is_On_Hold__c = quoteList[0].Pricing_On_Hold_Cb__c;
            onHoldEntry.Pricing_Quote_On_Hold_Comment__c = quoteList[0].Pricing_On_Hold_Comment__c;
            onHoldEntry.Pricing_QuoteOnHold_Start_Time__c = System.now();
            onHoldEntry.Pricing_QuoteOnHold_User_Role__c = 'SDM';
            insert onHoldEntry;
            System.assertEquals(true ,quoteList.size() > 0);
        }
        Test.stopTest();
    }
}