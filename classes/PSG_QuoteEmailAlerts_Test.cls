/****************************************************************************************************
Apex Class Name : PSG_QuoteEmailAlerts_Test
Version         : 1.0 
Created Date    : 02/25/2022
Function        : Test class for PSG_QuoteEmailAlerts.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Drushti Chauhan      		02/25/2022              	Created
*****************************************************************************************************/
@isTest
public class PSG_QuoteEmailAlerts_Test {
    /*@testSetup
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
        System.assertEquals('','');
        }
    }
    static testMethod void testQuoteEmailAlerts(){
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = [select Id,OwnerId,core_cpq_requestor_nm__c from SBQQ__Quote__c limit 1];
        core_user_delegation__c userDeleg = new core_user_delegation__c();
        userDeleg.core_cpq_delegated_For__c = lstquote[0].OwnerId;
        List<User> sosUser = PSG_Test_Utility.createSOSUser();
        userDeleg.core_cpq_delegated_to__c = sosUser[0].id;
        List<id> quoteid = new List<id>();
        quoteid.add(lstquote[0].id);
        PSG_QuoteEmailAlerts.getQuotes(quoteid);
        System.assertEquals('','');
        Test.stopTest();
    }*/
}