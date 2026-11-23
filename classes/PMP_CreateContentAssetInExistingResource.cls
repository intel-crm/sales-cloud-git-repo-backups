/**************************************************************************************
Apex Class Name : PMP_CreateContentAssetInExistingResource
Version     : 1.0 
Created Date: 9th Dec, 2019
Description : to generate the Content Asset for existing records
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Sandhya                  09/12/2019               
*************************************************************************************/
global class PMP_CreateContentAssetInExistingResource implements Database.Batchable<sObject>{
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String image = PMP_StaticConstants_Offering.IMAGE;
        String thumbnailImage = PMP_StaticConstants_Offering.THUMBNAIL_IMAGE;
      
        String query = 'SELECT ID, Name, PMP_Resource_Type_Nm__c, PMP_Partner_Offering_Image__c,PMP_Offering_Id__c' +
                ' FROM PMP_Partner_Offering_Resource__c ' + 
                'Where (PMP_Resource_Type_Nm__c =:image OR PMP_Resource_Type_Nm__c=:thumbnailImage)';
        system.debug('**********'+query);
        return Database.getQueryLocator(
             
            query
            );
        
        }
    
    global void execute(Database.BatchableContext bc, List<PMP_Partner_Offering_Resource__c> scope){
       system.debug('scope in batch------'+scope);
        try{
        PMP_OfferingResourceTriggerHelper.createContentAsset(scope);
        
        List<PMP_Partner_Offering_Resource__c> resToBeUpdated = new List<PMP_Partner_Offering_Resource__c>();
        
        for(PMP_Partner_Offering_Resource__c offRes: scope){
            offRes.PMP_Partner_Offering_Resource_URL_Txt__c = 'SuccessfullyUpdated';
            resToBeUpdated.add(offRes);
        }
        
        if(!resToBeUpdated.isEmpty()){
           update resToBeUpdated;
        }
        
        system.debug('*******************'+resToBeUpdated);
        }catch(Exception e){
            system.debug('Error Occured in Batch---'+e.getMessage());
        }
          
    }
    
    global void finish(Database.BatchableContext bc){
    }
}