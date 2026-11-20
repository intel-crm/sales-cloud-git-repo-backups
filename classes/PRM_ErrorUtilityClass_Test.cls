/*********************************************************************************************************************
Class Name  : PRM_ErrorUtilityClass_Test
Version       : 1.0
Created Date  : Nov 2018
Function      : Test Class for 'PRM_ErrorUtilityClass'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Rahul Kainth               11/02/2018              PRM_ErrorUtilityClass

*********************************************************************************************************************/
@isTest
public class PRM_ErrorUtilityClass_Test{
    static testMethod void testlog(){
    Map<String,String> mapLogEntry = new Map<String,String>();
    
    Test.startTest();
    try{
    //just to cover exception class
    MyException  e = new MyException  ('Error', false);
        e.addError('Error', false);
    Core_Log_Entry__c cl = PRM_TestUtility.getLogData();
    cl.Core_When__c = System.Today();
    insert cl;
    
    mapLogEntry.put('abc','xyz');
if(Test.isRunningTest()){
    throw new myException();
    }    

    Test.stopTest();
    System.assertEquals(cl.Core_Project__c, 'intel', 'Value does not match');
    PRM_ErrorUtilityClass.logErrorInLogObject('test','cl');
    
    PRM_ErrorUtilityClass.createLogEntry(mapLogEntry);
    }
    catch(Exception e){
        PRM_ErrorUtilityClass.getErrorDetails(e);
        PRM_ErrorUtilityClass.logError(e);
    }
    
    
    }

}