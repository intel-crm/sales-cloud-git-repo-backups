@isTest(SeeAllData=false)
public class TransferDemo {
    @isTest static void validateSearchAccountsLookupforBudgetLoader(){
        Test.startTest();
        List<Account> toBeUpdated = new List<Account>();
        
        for(Account acc: [Select id,isPartner,Name from Account where Name IN ('Test Account 1','Test Account 2')]){
            acc.isPartner = true;
            toBeUpdated.add(acc);
        } 
        
        Database.update(toBeUpdated);
        
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
  
        Database.insert(usr);
        //insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        System.runAs(usr){
            PermissionSet pSet = [SELECT Id,Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
            
            PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
            assignPermissionSet.AssigneeId = usr.Id;
            assignPermissionSet.PermissionSetId = pSet.Id;
            Database.insert(assignPermissionSet);            
        }
        
        System.runAs(usr){
            List<Account> accountDetail = Core_MDF_BudgetTransfer.SearchAccountsLookup(toBeUpdated[1].Name);
            if(!accountDetail.IsEmpty() && accountDetail.size()>0){
                System.assertEquals(toBeUpdated[1].Id, accountDetail[0].Id);
            }
        }
        Test.stopTest();
        
    }
}