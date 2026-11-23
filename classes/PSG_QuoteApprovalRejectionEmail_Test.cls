/******************************************************************************************************
Apex Class Name : PSG_QuoteApprovalRejectionEmail_Test
Version         : 1.0 
Created Date    : 11/18/2022
Function        : Test class for PSG_QuoteApprovalRejectionEmailAlerts
Modifications   :
*******************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Adarsh Parashar             11/18/2022             Created
*******************************************************************************************************/
@isTest
public class PSG_QuoteApprovalRejectionEmail_Test {
    @TestSetup
    public static void setUpData(){
    	SBQQ.TriggerControl.disable();
        List<User> distyUserList = PSG_Test_Utility.createDistyUser();
        List<User> sosUser1 = PSG_Test_Utility.createSOSUser();
        System.runAs(distyUserList[0]){
            Account acc = PSG_Test_Utility.createAccount();
            Contact con = PSG_Test_Utility.createContact(acc.Id);
            List<SBQQ__Quote__c> quote = new List<SBQQ__Quote__c>();
            PSG_Test_Utility.createQuote(acc.id,con.id,1);
            quote = [select id,OwnerId,core_cpq_requestor_nm__c from SBQQ__Quote__c];
        }
    }
    static testMethod void testQuoteEmailAlerts(){
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = [select Id,OwnerId,core_cpq_requestor_nm__c from SBQQ__Quote__c limit 1];
        core_user_delegation__c userDeleg = new core_user_delegation__c();
        userDeleg.core_cpq_delegated_For__c = lstquote[0].OwnerId;
        List<User> sosUser = PSG_Test_Utility.createSOSUser();
        userDeleg.core_cpq_delegated_to__c = sosUser[0].id;
        List<sbaa__approval__c> approvalList = PSG_Test_Utility.createApproval(lstquote[0].id);
        List<id> approvalId = new List<id>();
        approvalId.add(approvalList[0].id);
        approvalList[1].sbaa__Status__c = 'Rejected';
        approvalList[1].sbaa__RejectedBy__c = sosUser[0].id;
        update approvalList;
        PSG_QuoteApprovalRejectionEmailAlerts.getApprovalId(approvalId);
        Test.stopTest();
    }
}