/**************************************************************************************
Apex Class Name:  Core_IPS_Backend_Batch_ReprocessFailures
Version     : 1.0 
Created Date: 25 04 2016
Function    : Batch class to REPROCESS 'error' log entries. This will run on weekly basis.
Author      : Tanvi Chauhan
Modification Log :
* Change#           Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* IPS Cloud Rel1   Tanvi Chauhan          25/04/2016              Original Version
*
*************************************************************************************/

global class Core_IPS_Backend_Batch_ReprocessFailures implements Database.Batchable<sObject>, Database.Stateful{

global final String project = 'IPS Cloud';
global final String origin = 'PromoteCase';
global final String sObjectType = 'sf:Case';
global final String severity = 'error';
global String queryActive;
global integer limitSize;
public List<Core_Log_Entry__c> oldLogEntriesToBeDeleted = new List<Core_Log_Entry__c>();
public List<Core_Log_Entry__c> logEntriesToBeUpdated = new List<Core_Log_Entry__c>();
//this list will hold all the casenumbers that are promoted
global List<String> listOfCaseRecords = new List<String>(); 

//Fetching number of days from Custom settings.
List<Core_IPSBackendPromoteReprocesing__c> c = [SELECT Name, Core_Translate_Value__c FROM Core_IPSBackendPromoteReprocesing__c where Name = 'IPS_ReProcessBatchDate'] ;
Integer days = integer.valueOf(c[0].Core_Translate_Value__c);
global DateTime d = System.today().addDays(- days);
              
global Database.QueryLocator start(Database.BatchableContext BC){
    return Database.getQueryLocator(queryActive);
} 

global void execute(Database.BatchableContext BC, List<Core_Log_Entry__c> scope){ 
    
    try{
        for(Core_Log_Entry__c logEntry : scope){
            /** Ist Condition: Filtering out records that are eligible to be deleted (say, 60days old)**/
            if(logEntry.CreatedDate <= d){
                oldLogEntriesToBeDeleted.add(logEntry); 
            }
            /** 2nd Condition:- Filtering out records that r eligible to be updated with origin 'PromoteCase' & severity 'Error' **/
            else{
                if(logEntry.Core_Origin__c == origin && logEntry.Core_Severity__c == severity && logEntry.Core_sObjectType__c == sObjectType){
                    logEntriesToBeUpdated.add(logEntry); 
                }
            }
        }
    
        if(!oldLogEntriesToBeDeleted.isEmpty()){
            Database.delete(oldLogEntriesToBeDeleted);
            DataBase.emptyRecycleBin(oldLogEntriesToBeDeleted);
        }
        
        //Map<Id, Case> mapCaseIds = new Map<Id, Case>();
        //Case caseobj;       // Object Variable to store individual object       
        //Set<Id> caseIds = new Set<Id>();
        Set<String> caseIds = new Set<String>();
        
        if(!logEntriesToBeUpdated.isEmpty()){
            List<Core_Log_Entry__c> finalLogListToUpdate = new List<Core_Log_Entry__c>();  //this list will be updated
        
            //Iterating through each log entry and updating 'Severity' to 'processed'
            for(Core_Log_Entry__c logEntry : logEntriesToBeUpdated){
                logEntry.Core_Severity__c = 'Processed';
                //Adding values in the Set of CaseIds & Final Log entry list ie to be updated
                caseIds.add(logEntry.Core_sObjectId__c);
                finalLogListToUpdate.add(logEntry); 
            }
        
        if(caseIds.size()>0){
            Map<Id,Case> updateCaseMapIds = new Map<Id, Case>();   
            // Check all the case that are in 'InProgress and Failed' Status and backend system ID is not null and Backend ID is null
            List<Case> csIds= [SELECT id, CaseNumber, Core_Promote_Status__c from Case WHERE id IN :caseIDs AND Core_IPS_Backend_System__c <> null AND Core_IPS_Backend_ID__c = null];  
            
            for(Case cs: csIds){
                cs.Core_Promote_Status__c = 'Promote';
                listOfCaseRecords.add(cs.CaseNumber);
                updateCaseMapIds.put(cs.id, cs);
            }
            
            if(!updateCaseMapIDs.isEmpty()){
                update updateCaseMapIds.values();
            }
        }
        Database.update(finalLogListToUpdate);  
      }
     }catch(Exception ex){
     }        
 }     

global void finish (Database.BatchableContext BC){
    // making a single string with comma seprated from above list
    String commaSeperatedCaseList='';
    for(String str: listOfCaseRecords){
        commaSeperatedCaseList += str + ',';
    }
    // remove last additional comma from string
    if(commaSeperatedCaseList.length() >0){
        commaSeperatedCaseList = commaSeperatedCaseList.subString(0, commaSeperatedCaseList.length()-1);
    }
    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
    String message = 'The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.JobItemsProcessed + ' number of records and ' + a.NumberOfErrors + ' failures.';
   
    //Fetching Email Address details from Custom setting.
    List<Core_IPSBackendPromoteReprocesing__c> cs = [SELECT Name, Core_Translate_Value__c FROM Core_IPSBackendPromoteReprocesing__c where Name = 'IPS_Batch_SendToAddress'] ;
    
    // Send an email to the Apex job's submitter notifying of job completion only if Custom Setting 'toAddress' data is available
    if(cs[0].Core_Translate_Value__c != null || cs[0].Core_Translate_Value__c != ''){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {cs[0].Core_Translate_Value__c};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Salesforce BatchUpdateField ' + a.Status);
        mail.setPlainTextBody(message + '\n' + 'Cases Processed: '+commaSeperatedCaseList);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }

    }
}