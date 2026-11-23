/****************************************************************************************************
Apex Class Name : PSG_UserDelegationBusinessLogic_Test
Version         : 1.0 
Created Date    : 01/06/2021
Function        : Test class for PSG_UserDelegationBusinessLogic
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                  01/06/2021                 Created
*****************************************************************************************************/
@isTest
public with sharing class PSG_UserDelegationBusinessLogic_Test {
    @isTest
    public static void testCreateQuote(){
        List<User> lstUsers1 = PSG_Test_Utility.createSOSUser();
        List<User> lstUsers2 = PSG_Test_Utility.createSOSUser();
        List<User> lstUsers3 = PSG_Test_Utility.createAdminUser();
        system.runAs(lstUsers3[0]){                
            Test.startTest();
            core_user_delegation__c ud = new core_user_delegation__c(
                core_cpq_delegated_to__c = lstUsers1[0].Id,
                core_cpq_delegated_for__c = lstUsers2[0].Id
            );
            insert ud;
            system.assert(ud.Id != null , 'User record not created');
            List<User> lstUsers4 = PSG_Test_Utility.createSOSUser();
            List<User> lstUsers5 = PSG_Test_Utility.createSOSUser();
            ud.core_cpq_delegated_For__c = lstUsers4[0].Id;
            ud.core_cpq_delegated_to__c = lstUsers5[0].Id;
            update ud;
            Test.stopTest();
        }   
    }
    
    @isTest
    private static void testShareQuotes(){
        List<User> lstUsers3 = PSG_Test_Utility.createAdminUser();
        List<User> lstUsers4 = PSG_Test_Utility.createAdminUser();
        List<User> lstUsers5 = PSG_Test_Utility.createAdminUser();
        Account acc = PSG_Test_Utility.createDirectAccount();
        Account acc4 = PSG_Test_Utility.createAccount();
        acc4.Core_Direct_Pricing_Parent_Id__c=acc.id;
        acc4.Core_Direct_Legal_Parent_Id__c=acc.id;
        update acc4;
        Account acc2 = PSG_Test_Utility.createAccount();
        Contact con = PSG_Test_Utility.createContact(acc2.Id);
        Test.startTest();
        System.runAs(lstUsers5[0]){
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc4.Id, con.Id, 1);
            system.assert(!lstquote.isEMpty() , 'Quote Created');
            List<core_user_delegation__c> uds=new List<core_user_delegation__c>();
            core_user_delegation__c ud = new core_user_delegation__c(
                core_cpq_delegated_to__c = lstUsers3[0].Id,
                core_cpq_delegated_for__c = UserInfo.getUserId()
            );
            core_user_delegation__c ud1 = new core_user_delegation__c(
                core_cpq_delegated_to__c = lstUsers4[0].Id,
                core_cpq_delegated_for__c = UserInfo.getUserId()
            );
            uds.add(ud);
            uds.add(ud1);
            insert uds;
            PSG_UserDelegationBusinessLogic.createSharingForDelegates(uds,'grant');
            PSG_UserDelegationBusinessLogic.createSharingForDelegates(uds,'revoke');
        }
        Test.stopTest();        
    }
}