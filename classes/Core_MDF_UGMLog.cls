/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_UGMLog 
* Version     : 1.0 
* Created Date: 04-03-2019
* Modification Log :
* Developer                     Date                          Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi     04-03-2019            Batch class to log into Core_MDF_UserGroupMapping_Log__c object 
**************************************************************************************************************************************************************************************/
//global class Core_MDF_UGMLog implements Database.Batchable<Core_MDF_UserGroupMapping_Log__c> {
//US949837 - Added without sharing keyword to fix checkmarx issues
global without sharing class Core_MDF_UGMLog implements Database.Batchable<Core_MDF_UserGroupMapping_Log__c> {  
   public List<Core_MDF_UserGroupMapping_Log__c> tobeLogged = new List<Core_MDF_UserGroupMapping_Log__c>();
   public static String logEntryMsg = '';
   public static exception ex;
    public Boolean pgmSynch = false;

   global Core_MDF_UGMLog(List<Core_MDF_UserGroupMapping_Log__c> inputFromUserGroupMappingClass)
   {
     tobeLogged = inputFromUserGroupMappingClass;          
   }
   global List<Core_MDF_UserGroupMapping_Log__c> start(Database.BatchableContext BC)
   {
      return tobeLogged;
   }

   global void execute(Database.BatchableContext BC, List<Core_MDF_UserGroupMapping_Log__c> tobeLogged)
   {
       
list<Id> contactIds = new List<Id>();
       Map<String,Id> contactIdProgramIdtoUGMIdMap = new Map<String,Id>();
      try{
          
          Database.SaveResult[] saveList = Database.insert(tobeLogged,false);

      }
       
       catch(exception ex){logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Core_MDF_UserGroupMappingAutomation - Core_MDF_UGMLog()');}     
   }

   global void finish(Database.BatchableContext BC)
   {

   }

}