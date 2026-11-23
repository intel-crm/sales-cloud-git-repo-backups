/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-26-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_FieldSetUtilTest {
	@testSetUp
    public static void setUpData() {
        Pricing_Test_Utility.createPriceBook();
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]) {
            Test.startTest();
            	Account acc = Pricing_Test_Utility.createAccount();
            	Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Field_Set_Util_Test');
            	List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            	//List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            	AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
            	insert accTeam;
                List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);
                List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
        	Test.stopTest();
        }
    }
        
        
    static testMethod void testgetFormFieldsAndSectionLabel () {
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.OwnerId,RecordType.Name,Pricing_Sales_Rep__c, Pricing_Status_Nm__c from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<Pricing_Field> fieldList = new List<Pricing_Field>();
        
        System.runAs(adminUser){
            fieldList = Pricing_FieldSetUtil.getFields(quoteLineList[0].Id,'SBQQ__QuoteLine__c','Pricing_SSD_AdditionalDetails',True);
            fieldList = Pricing_FieldSetUtil.getFields(quoteLineList[0].Id,'SBQQ__QuoteLine__c','Pricing_SSD_AdditionalDetails',False);
            fieldList = Pricing_FieldSetUtil.getFields('SBQQ__QuoteLine__c','Pricing_SSD_AdditionalDetails',True);
        System.assertEquals(true, quoteList.size() > 0);
        }
        Test.stopTest();
    }
}