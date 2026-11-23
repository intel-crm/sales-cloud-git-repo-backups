/******************************************************************************************************
* Class Name  : Core_MDF_Account_Owner_Change_Test 
* Version     : 1.0 
* Created Date: 01-04-2022.
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - NK      01-04-2022          Test class for Core_MDF_Account_Owner_Change
*******************************************************************************************************/
@isTest
public class Core_MDF_Account_Owner_Change_Test {
	@testSetup 
    static void setup(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
		UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        List<user> userList = new List<user>();  
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.profileId = sysAdminProfile.Id;
        usr1.UserRoleId = usRole.Id;
        usr1.email='sysadmin1@example.com';
        userList.add(usr1);
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.profileId = sysAdminProfile.Id;
        usr2.UserRoleId = usRole.Id;
        usr2.email='sysadmin2@example.com';
        userList.add(usr2);
        Database.insert(userList);
        System.runAs(usr1){
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IntelAcc ', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,true);
        Account corpAccCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test CorpAccCCF', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccount.Id,true); 
        
            }
    }
     @isTest static void testOwnerChange(){
         user usr = [Select Id from user where email='sysadmin2@example.com'];
         Account acc = [Select Id,ownerId from Account where name = 'Test CorpAccCCF'];
         list<accountshare> accShareList1 = [select id from accountshare where accountid =:acc.id];
         
         acc.ownerId=usr.Id;
         list<accountshare> accShareList2 = [select id from accountshare where accountid =:acc.id];
         
         system.runAs(usr){
         update acc;
         }
         system.assertEquals(accShareList1.size(), accShareList2.size());
     }
}