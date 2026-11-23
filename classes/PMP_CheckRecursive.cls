/****************************************************************************************************************************************
* Class Name  : PMP_CheckRecursive
* Version     : 1.0 
* Created Date: 13-11-2018
* Modification Log :
* Developer                      Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys-Sangeetha Ganta       12/27/2018          To Avoid recursive trigger error in after update
*****************************************************************************************************************************************/

public Class PMP_CheckRecursive{
    private static boolean run = true;
    public static boolean runOnce(){
    if(run){
     run=false;
     return true;
    }else{
        return run;
 }
    }
}