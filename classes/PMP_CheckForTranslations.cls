/****************************************************************************************************************************************
* Class Name  : PMP_CheckForTranslations
* Version     : 1.0 
* Created Date: 01/04/2020 
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Gireesh                   01/04/2020                    Batch to check if any other tranlations are present to publish to PIM    
****************************************************************************************************************************************************************/





//US607597:Gireesh
//Batch to check if any other tranlations are present to publish to PIM    
global class PMP_CheckForTranslations implements Database.Batchable<sObject>, Database.AllowsCallouts{

   global List<Id> offeringList;

   global PMP_CheckForTranslations(List<Id> batchOfferingList){

      this.offeringList = batchOfferingList;
       system.debug('In Constructor callg -----'+offeringList);
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      String query ='select id from PMP_Partner_Offering__c where id IN :offeringList';
        system.debug('queryg--------'+query);
        system.debug('database queryg----------'+Database.getQueryLocator(query));
       return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       system.debug('Inside executeg---');
     PMP_PIMProduct.checkExistingTranslatedDataList(offeringList);
    }

   global void finish(Database.BatchableContext BC){
   }
}