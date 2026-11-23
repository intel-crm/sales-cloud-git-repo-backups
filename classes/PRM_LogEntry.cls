/*********************************************************************************************************************
Apex Class Name  : PRM_LogEntry
Version       : 1.0
Created Date  : JAN 2021
Function      : Declares the variables required for Integration Log Entry
Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* 
*********************************************************************************************************************/

public without sharing class PRM_LogEntry {

    //Variables for Integration Log Entries
    public static String logModule;
    public static String logSystem;
    public static String logClass;
    public static String requestPayload;
    public static String recordId;
    public static String externalId;
    public static String calloutType;
    public static String responsePayload;
    public static Integer responseCode;
    public static String errorMessage;
    
}