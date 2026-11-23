@isTest
public class PSG_BatchForDelegation_Test {
    @isTest
    private static void testBatchDelegateQuotes(){
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
                core_cpq_delegated_for__c = UserInfo.getUserId(),
                Start_Date__c = System.today()
            );
            core_user_delegation__c ud1 = new core_user_delegation__c(
                core_cpq_delegated_to__c = lstUsers4[0].Id,
                core_cpq_delegated_for__c = UserInfo.getUserId(),
                End_Date__c = System.today()
            );
            uds.add(ud);
            uds.add(ud1);
            insert uds;
        }        
        Database.executeBatch(new PSG_BatchForDelegation(), 50);
        System.schedule('TestJob', '0 0 6 1/1 * ? *', new PSG_BatchForDelegation());
        Test.stopTest();
    }
}