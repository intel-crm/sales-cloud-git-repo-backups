/****************************************************************************************************
Apex Class Name : PSG_BatchCreateApproversTest
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_BatchCreateApprovers.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Tushar             08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_BatchCreateApproversTest{
    /*@isTest
    static void batchCreateApproverTest(){
        List<User> lstUsers3 = PSG_Test_Utility.createAdminUser(); 
        List<User> lstUsers4 = PSG_Test_Utility.createBMUser(); 
        List<sbaa__Approver__c> avp = PSG_Test_Utility.createApprover(lstUsers4[0].Id);
        system.runAs(lstUsers4[0]){
            System.assert(!lstUsers4.isEmpty(), 'User Created');
            Test.startTest();
            Database.executeBatch(new PSG_BatchCreateApprovers());
            Test.stopTest();
        }
    }*/ 
}