/**************************************************************************************
Apex Class Name : PMP_CreateUpdatePublishOfferings
Version     : 1.0 
Created Date: 07th Nov, 2019
Description : Batch class to publish all images when offering is approved
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Sandhya                  07/11/2019               Original Version
*************************************************************************************/
global Class PMP_CreateUpdatePublishOfferings implements Database.Batchable<sObject>,Database.Stateful{

   // global String query;
  global List<PMP_Partner_Offering__c> clonedofferingList;
 
    List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
    Map<Id,Boolean> featuredOfferingMap = new Map<Id,Boolean>();
  
    List<PMP_Partner_Offering_Resource__c> resToBeInsertedList = new List<PMP_Partner_Offering_Resource__c>();
    
    global PMP_CreateUpdatePublishOfferings(List<PMP_Partner_Offering__c> batchOfferingList) {
    	this.clonedofferingList = batchOfferingList;
        system.debug('In Constructor call -----'+clonedofferingList);
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id offeringId = clonedofferingList.get(0).id;
    	String query ='select id from PMP_Partner_Offering__c where id =:offeringId ';
        system.debug('query--------'+query);
        system.debug('database query----------'+Database.getQueryLocator(query));
    return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<PMP_Partner_Offering__c> scope) {
        system.debug('Inside execute---');
        List<PMP_Partner_Offering_Resource__c> partnerOfferingRes = new List<PMP_Partner_Offering_Resource__c>();
        PMP_OfferingTriggerHelper.createPublishedOfferings(clonedofferingList);
       
            
        
    }
    global void finish(Database.BatchableContext bc) {
     
    }

}