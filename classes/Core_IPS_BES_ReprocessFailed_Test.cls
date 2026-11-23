@isTest
public class Core_IPS_BES_ReprocessFailed_Test {
 
    @isTest
    public static void batchTestMethod(){

        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'HSDES-PSG01';

        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
        
        Case cs =  TestUtilities.getCase();
        cs.Core_IPS_New_Backend_System__c = backendSystem.Id;
        cs.Core_IPS_BackendID__c = '121212212333';
        cs.Core_IPS_BES_Promote_Status__c = 'FAILED';
        insert cs;
        Core_IPS_BES_ReProcessFailedHandler.executeBatch('Case', 1);
        // Database.executeBatch(new Core_IPS_BES_ReprocessFailedRecords('Case', 1),1);
        System.assert(cs.Id!=null);
    }
  
}