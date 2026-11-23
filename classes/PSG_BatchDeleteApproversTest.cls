/****************************************************************************************************
Apex Class Name : PSG_BatchDeleteApproversTest
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_BatchDeleteApprovers.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Tushar             08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_BatchDeleteApproversTest{    
    /*@isTest
    static void batchCreateApproverTest(){
        List<User> lstUsers3 = PSG_Test_Utility.createAdminUser(); 
        List<User> lstUsers4 = PSG_Test_Utility.createBMUser(); 
        List<sbaa__Approver__c> avp = PSG_Test_Utility.createApprover(lstUsers3[0].Id);
        system.runAs(lstUsers4[0]){
            System.assert(!lstUsers4.isEmpty(),'User Created');
            Test.startTest();
            PSG_BatchDeleteApprovers deleteRec = new PSG_BatchDeleteApprovers();
            database.executeBatch(deleteRec);
            Test.stopTest();
        }
    }*/ 
}