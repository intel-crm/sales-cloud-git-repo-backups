@isTest
public class Core_IntegrationOptimization_Test {
    @isTest 
    public static void GetTop1Account(){
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Test.startTest();
        String accId = Core_IntegrationOptimization.GetMatchingAccountSFIDfromCIMID(new Set<String>{acc1.Core_CIM_ID__c, acc2.Core_CIM_ID__c} ,new Set<String>{'54321'});
        System.assertEquals(acc1.Id, accId);
        String templateName = [SELECT Id, DeveloperName FROM EmailTemplate LIMIT 1].DeveloperName;
        Core_IntegrationOptimization.SendEmail('test@maillinator.com',templateName);
        Test.stopTest();
    }
    
    @isTest 
    public static void GetTop2Account()
    {
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);        
        Test.startTest();
        String accountId = Core_IntegrationOptimization.GetMatchingAccountSFIDfromCIMID(new Set<String>{acc1.Core_CIM_ID__c} ,new Set<String>{'54321'});
        System.assertEquals(acc1.Id, accountId);
        Test.stopTest();
    }
}