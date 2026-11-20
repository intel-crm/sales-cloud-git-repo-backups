/**************************************************************************************
Apex Class Name:  Core_IPS_AccountTeam_DeletedRecords_Test
Version     : 1.0 
Created Date: 3/28/16
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              3/28/16                Initial Revision
* System.assert()--> Statements Added By Hassan Khan 01-02-2024 
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

            lstATM = Core_Test_Utility.Core_AccountTeamMember(lstUser);
            for (AccountTeamMember atm : lstATM)
                atm.AccountId = acct.Id;
                            
            lstAccountTeamMember.addAll(lstATM);                
        }
        
        // Create a member mismatch
        lstAccountTeamMember.remove(0);        
        
        insert lstAccountTeamMember;        
        
        lstCustomAccountTeamMember = new List<Core_Account_Team__c>();
        
        List<Core_Account_Team__c> lstCATM;
        for (Account acct : lstAccount) {
            lstCATM = Core_Test_Utility.Core_CustomAccountTeam(lstUser);
            for (Core_Account_Team__c atm : lstCATM)
                atm.Core_Account__c = acct.Id;
                            
            lstCustomAccountTeamMember.addAll(lstCATM);                
        }
        
        insert lstCustomAccountTeamMember;

                        
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
        System.assert(lstCustomAccountTeamMember.size() > 0, true);  
    }

}