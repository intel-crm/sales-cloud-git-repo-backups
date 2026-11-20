/*********************************************8
* Name : Core_AAQC_ProcessBuilderNoActionTest 
* Author : Nikhil Godhani
* Date Created : 06-November-2018
* Description : This is being used in execute test cases of 'Core_AAQC_ProcessBuilderNoAction' class
* Version Updates : 
*   
* Date          By                      User-Story              Details 
* 06-11-18      Nikhil                  US110982                 created 
************************************************/
@isTest
public class Core_AAQC_ProcessBuilderNoActionTest {
    
    static testMethod void executeCode(){
        List<string> xyz = new List<string>();
        Core_AAQC_ProcessBuilderNoAction.DoNothing(xyz);
    }

}