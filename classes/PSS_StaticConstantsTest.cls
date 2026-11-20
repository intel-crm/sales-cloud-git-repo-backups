/**************************************************************************************
Apex Class Name: PSS_StaticConstants 
Created Date: 14th Jun, 2021
Description : Test class PSS_StaticConstants
* Modification Log :
* Developer                 Date         Description
* ----------------------------------------------------------------------------
* Prakash          14/06/2021    Original Version
*************************************************************************************/

@isTest
public class PSS_StaticConstantsTest{  
    
    public static testMethod void testStaticMethod(){
        Test.StartTest();
        PSS_StaticConstants  staticConstants= new PSS_StaticConstants();
        System.AssertEquals(PSS_StaticConstants.COMPLETED,'Completed');
        System.AssertEquals(PSS_StaticConstants.ADMIN_REVIEW,'Admin Review');
        System.AssertEquals(PSS_StaticConstants.SOLUTION_APPROVED_STATUS,'Approved');
        System.AssertEquals(PSS_StaticConstants.SOLUTION_ONHOLD_STATUS,'On Hold');
        Test.StopTest();
    }

}