/****************************************************************************************************************************************
* Class Name  : PRM_checkRecursive
* Version     : 1.0 
* Created Date: APR 2022
* Modification Log :
* Developer                      Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sathya       APR 2022          To Avoid recursive trigger error in after update
*****************************************************************************************************************************************/
public Class PRM_checkRecursive{
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