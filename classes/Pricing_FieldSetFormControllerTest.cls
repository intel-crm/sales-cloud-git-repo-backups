/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-10-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_FieldSetFormControllerTest {
	@testSetUp
    public static void setUpData() {
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]) {
            Test.startTest();
            	Account acc = Pricing_Test_Utility.createAccount();
            	Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Field_Set_Form_Controller_Test');
            	List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            	List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            	AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
            	insert accTeam;
                List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);
                List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
        	Test.stopTest();
        }
        
    }
    
    static testMethod void testgetFormFieldsAndSectionLabel() {
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.OwnerId,RecordType.Name,Pricing_Sales_Rep__c, Pricing_Status_Nm__c from SBQQ__QuoteLine__c LIMIT 1];
        List<Pricing_FieldSetFormController.FieldSetForm> form = new List<Pricing_FieldSetFormController.FieldSetForm>(); 
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        
        System.runAs(adminUser){
        	form = Pricing_FieldSetFormController.getFormFieldsAndSectionLabel(quoteLineList[0].Id);
            SBQQ__QuoteLine__c quoteLine = Pricing_FieldSetFormController.getQuoteLineDetails(quoteLineList[0].Id);
            System.assertEquals(true, quoteLineList.size() > 0);
        }
        Test.stopTest();
    }
    static testMethod void testIsReadOnlyUser(){
        Test.startTest();
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        
        System.runAs(adminUser){
        	Boolean isRPM = Pricing_FieldSetFormController.isReadOnlyUser();
            System.assertEquals(isRPM, false);
        }
        Test.stopTest();        
    }
    
}