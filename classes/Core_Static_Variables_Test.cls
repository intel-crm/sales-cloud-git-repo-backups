/**************************************************************************************
*Apex Class Name:Core_Static_Variables_Test  
*Version     : 1.0 
*Created Date: 27 July 2017
*Description : Test class for Core_Static_Variables 
* Developer                 Date         Description
* ----------------------------------------------------------------------------
* Ajay Doddangadi          27/07/2017    Original Version
*************************************************************************************/
@isTest
private class Core_Static_Variables_Test{

    static testmethod void testStaticMethod(){
         Test.StartTest();
                 Core_Static_Variables staticObj = new Core_Static_Variables();
         Test.StopTest();
    }
}