@isTest(SeeAllData=false)
private class Core_MDF_Batch_AcctToBudgetTypeMap_Test {

    @TestSetup static void setUpData(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        Database.insert(testUser);
        
        System.runAs(testUser){
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, true);           
            
            String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
           
        }
    }
    
     @isTest 
    static void insertApplicableMDFBudgetTypeTest(){
        
        Test.startTest();
        Account ipaCoMarketingAccount = [select id,Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
         List<Account> acctList = new List<Account>();
            acctList.add(ipaCoMarketingAccount);
            //Core_MDF_Batch_AcctToBudgetTypeMap.insertApplicableMDFBudgetType(acctList);
    }
    
    
}