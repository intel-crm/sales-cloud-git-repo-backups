/**************************************************************************************************************
Version     : 1.0 
Created Date: 22 June 2020
Function    : Batch class to Implement Territory and Public Group Automation
Modification Log :
* Developer             		 Date              Description
* ----------------------------------------------------------------------------                 
* Harshita            22/06/2020        Initial version
***************************************************************************************************************/

global without sharing class Core_Batch_PG_To_Territory_Assignment implements Database.Batchable<sObject>{
	
    
    global static Database.QueryLocator start(Database.BatchableContext context){
         System.debug('startmethod');
         String query = 'SELECT Core_Public_Group_Name_txt__c, Core_Territory_Name_txt__c FROM Core_PublicGroup_Territory_Mapping__mdt'; 
         System.debug('in start --> '+query);
      	 return database.getQueryLocator(query);
   		 
    } 
 
 	
	global void execute(Database.BatchableContext context, List<Core_PublicGroup_Territory_Mapping__mdt> scope){
        //System.debug('in execute method'+ scope);
		System.debug('meta data size' + scope.size());
        Core_PG_Territory_Assignment.addOrRemoveUsers(scope);
        //Core_PG_Territory_Assignment.removeUsers(scope);
           
    }
          
    
    global void finish(Database.BatchableContext context){
		System.debug('Inside Finish');
        //update reg_req;
    }  
    
}