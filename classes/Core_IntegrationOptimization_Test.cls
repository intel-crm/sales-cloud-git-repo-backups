@isTest
public class Core_IntegrationOptimization_Test {
    @isTest 
    public static void GetTop1Account(){
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Test.startTest();
        Core_IntegrationOptimization.GetMatchingAccountSFIDfromCIMID(new Set<String>{acc1.Core_CIM_ID__c, acc2.Core_CIM_ID__c} ,new Set<String>{'54321'});
        Core_IntegrationOptimization.SendEmail('test@gmail.com','Test');
        Test.stopTest();
    }
    
    @isTest 
    public static void GetTop2Account()
    {
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);        
        Test.startTest();
        Core_IntegrationOptimization.GetMatchingAccountSFIDfromCIMID(new Set<String>{acc1.Core_CIM_ID__c} ,new Set<String>{'54321'});
        Test.stopTest();
    }
}