/****************************************************************************************************************************************
* Class Name  : PMP_DelayedPublishToPIM
* Version     : 1.0 
* Created Date: 12/09/2020 
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Gireesh                   01/04/2020                    Batch to publish to PIM
****************************************************************************************************************************************************************/

//DE87519:Gireesh
global class PMP_DelayedPublishToPIM implements Database.Batchable<sObject>, Database.AllowsCallouts{

    
   global PMP_DelayedPublishToPIM(List<Id> batchOfferingList, List<PMP_Languages__mdt> translations, Boolean isFuture, Boolean isTranslationAvailable, Boolean isWorkingCopyOffering){

    //   this.offeringList = batchOfferingList;
    //    this.offeringTranslations = translations;
    //    this.batchIsFuture=isFuture;
    //    this.batchIsTranslationAvailable = isTranslationAvailable;
    //    if(isWorkingCopyOffering){
    //        List<PMP_Partner_Offering__c> publishPartnerOfferings = new List<PMP_Partner_Offering__c>();
    //     if(batchOfferingList!=null && batchOfferingList.size()>0){
    //         publishPartnerOfferings = [SELECT Id from PMP_Partner_Offering__c where PMP_Working_Copy_Id__c IN:batchOfferingList];
    //     }
    //        List<Id> offeringIds= new List<Id>();
    //        if(publishPartnerOfferings!=null && publishPartnerOfferings.size()>0){
    //            for(PMP_Partner_Offering__c publishPartnerOffering:publishPartnerOfferings){
    //                offeringIds.add(publishPartnerOffering.Id);
    //            }
    //        }
    //        if(offeringIds!=null && offeringIds.size()>0){
	// 			      this.offeringList=offeringIds;     
    //        }
    //    }
    //    system.debug('In Constructor callg -----'+offeringList);
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
    //   String query ='select id from PMP_Partner_Offering__c where id IN :offeringList';
    //     system.debug('queryg--------'+query);
    //     system.debug('database queryg----------'+Database.getQueryLocator(query));
    String query=null;
       return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<PMP_Partner_Offering__c> scope){
       system.debug('Inside delayed---');
    //    // process each batch of records
    //     List<Id> publishOfferingIds=new List<Id>();
    //     system.debug('size:'+scope.size());
    //     for (PMP_Partner_Offering__c offering : scope) {
    //         publishOfferingIds.add(offering.Id);
    //     }
    //     system.debug('qs:'+publishOfferingIds.size());

    //     List<PMP_Languages__mdt> nullTranslations = new List<PMP_Languages__mdt>();
    //      	PMP_PIMProduct.generatePIMProduct(publishOfferingIds, nullTranslations, False, False); 

    }

   global void finish(Database.BatchableContext BC){
    //    if(!batchIsTranslationAvailable){
    //        String cronId = System.scheduleBatch(new PMP_CheckForTranslations(offeringList), 'checkExistingTranslatedDataList'+ System.now().getTime(),1);
    //        system.debug('scheduleBatch:cronId:'+cronId);
    //    }
   }
}