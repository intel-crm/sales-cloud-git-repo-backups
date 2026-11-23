/**************************************************************************************
Apex Class Name:  Core_IPS_AccountTeam_DeletedRecords_Test
Version     : 1.0 
Created Date: 3/28/16
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              3/28/16                Initial Revision
*************************************************************************************/
@isTest
public class Core_IPS_AccountTeam_DeletedRecords_Test {

    static List<Account>           lstAccount;
    static List<User>              lstUser;
    static List<AccountTeamMember> lstAccountTeamMember;
    static Core_Batch_Header__c    batchHeader;

    static List<Core_Account_Team__c> lstCustomAccountTeamMember;


    static void setupTestData()
    {
        // A C C O U N T S
        lstAccount = Core_Test_Utility.createAccount(10);
        insert lstAccount;

        lstUser = Core_Test_Utility.Core_User(10);
        insert lstUser;
        
        lstAccountTeamMember = new List<AccountTeamMember>();
        
        List<AccountTeamMember> lstATM;
        for (Account acct : lstAccount) {
            System.debug('#11 acct: ' + acct);

            lstATM = Core_Test_Utility.Core_AccountTeamMember(lstUser);
            for (AccountTeamMember atm : lstATM)
                atm.AccountId = acct.Id;
            System.debug('#12 lstATM: ' + lstATM);
                            
            lstAccountTeamMember.addAll(lstATM);                
        }
        
        // Create a member mismatch
        lstAccountTeamMember.remove(0);        
        
        System.debug('#20 lstAccountTeamMember: ' + lstAccountTeamMember);
        insert lstAccountTeamMember;

        System.debug('#21 lstAccountTeamMember: ' + lstAccountTeamMember);
        
        
        lstCustomAccountTeamMember = new List<Core_Account_Team__c>();
        
        List<Core_Account_Team__c> lstCATM;
        for (Account acct : lstAccount) {
            lstCATM = Core_Test_Utility.Core_CustomAccountTeam(lstUser);
            for (Core_Account_Team__c atm : lstCATM)
                atm.Core_Account__c = acct.Id;
                            
            lstCustomAccountTeamMember.addAll(lstCATM);                
        }
        
        System.debug('#22 lstCustomAccountTeamMember: ' + lstCustomAccountTeamMember);
        insert lstCustomAccountTeamMember;

        System.debug('#23 lstCustomAccountTeamMember: ' + lstCustomAccountTeamMember);
                        
        batchHeader                = new Core_Batch_Header__c();
        batchHeader.Description__c = 'Batch delete';
        batchHeader.Name           = 'Core_IPS_AccountTeam_DeletedRecords_Bulk';        
        insert batchHeader;
                
    }
    

    static testMethod void deleteRecords_test_1()
    {
        setupTestData();
        
        Test.startTest();        
        
        Database.executeBatch(new Core_IPS_AccountTeam_DeletedRecords_Bulk(), 1000);
        
        Test.stopTest();        
    }

}