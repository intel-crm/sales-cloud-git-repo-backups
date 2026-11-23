/*********************************************************************************************************************
Modification Log : 
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
*Manjula(Tanzanite)       07/08/2020                Added changes for update of Partner Role and Tier in Marketing Profile Information Records
*                                                    Line# :47,101
*********************************************************************************************************************/
public class PRM_ACM_TriggerHandler extends TriggerHandler{
    
    public static boolean firstRun = true;
    public static boolean iPAFirstRun = true;
    public static boolean mPFirstRun = true;
    @TestVisible static Boolean executeTrigger = true;

}