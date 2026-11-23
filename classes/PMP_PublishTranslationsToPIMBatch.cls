/****************************************************************************************************************************************
* Class Name  : PMP_PublishTranslationsToPIMBatch
* Version     : 1.0 
* Created Date: 29-Jan-2020
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Sandhya                   29/Jan/2019                    This class is used to send the existing offering to PIm after translation(US542699)
****************************************************************************************************************************************************************/
global class PMP_PublishTranslationsToPIMBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        // get the offerings whose working copy and pim product is not nul and status is 'Published'
        query='SELECT Id, PMP_Offering_Language_Nm__c,PMP_Partner_Offering_Id__c FROM PMP_Partner_Offering__c where PMP_Partner_Offering_Lifecycle_Status_Nm__c=\'Published\'' +
            'and PMP_Working_Copy_Id__c!=\'\' and PMP_Partner_Offering_Id__c !=\'\' '; 
        system.debug('query-----'+query);
        return Database.getQueryLocator(
            query
        );

    }
    global void execute(Database.BatchableContext bc, List<PMP_Partner_Offering__c> scope){
        //Initialise
        List<id> offeringIdsList = new List<Id>();
        List<String> offeringPimProductList = new List<String>();
        Map<String,PMP_Languages__mdt> languageMap = new Map<String,PMP_Languages__mdt>();
        List<PMP_Languages__mdt> languageList = new List<PMP_Languages__mdt>();
        
        // get all the translation locales from PMP_Languages__mdt
        for(PMP_Languages__mdt lang:[select PIM_Language_Code__c,PIM_Locale_Name__c, Locale_Nm__c from PMP_Languages__mdt]){
            system.debug('lang-----'+lang);
            //adding the locale names to Map
            languageMap.put(lang.Locale_Nm__c,lang);
            system.debug('languageMap----'+languageMap);
            
        }
        
        // Iterate on each of the offering to send it to Pim after translation
        for(PMP_Partner_Offering__c offeringRec:scope){
            system.debug('languageMap.keySet1---------'+languageMap.keySet());
            for(String langKey:languageMap.keySet()){
                
                // send the offering for other languages except Input Language
                if(langKey != offeringRec.PMP_Offering_Language_Nm__c){ 
                    languageList.add(languageMap.get(langKey));
                    offeringIdsList.add(offeringRec.Id);
            		offeringPimProductList.add(offeringRec.PMP_Partner_Offering_Id__c);
                }
            }
            system.debug('languageList---'+languageList);
            try{
            	//PMP_PIMProduct.generateTranslatedPIMProductList(offeringIdsList, offeringPimProductList, languageList, false, true);
            	PMP_PIMProduct.generatePIMProduct(offeringIdsList, languageList, False, True);
            }catch(Exception e){
            system.debug('Error--'+e.getMessage());
        }
             
         
    }    
    }
    global void finish(Database.BatchableContext bc){
        
    }  
    
}