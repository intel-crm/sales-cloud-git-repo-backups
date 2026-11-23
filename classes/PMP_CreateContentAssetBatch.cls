/****************************************************************************************************************************************
* Class Name  : PMP_CreateContentAssetBatch
* Version     : 1.0 
* Created Date: 12-11-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* Tanzanite Team - Deepanshu          12-11-2019                    Batch class for creating Content Asset of Existing Companies Resources
****************************************************************************************************************************************************************/

global class PMP_CreateContentAssetBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String image = PMP_StaticConstants_Partner.Image;
        String thumbnailImage = PMP_StaticConstants_Partner.THUMBNAIL_IMAGE;
        
        String query = 'SELECT ID, Name, PMP_Company_Resource_Type_Nm__c, PMP_Company_Image__c, PMP_Company_Id__c FROM PMP_Company_Resource__c WHERE (PMP_Company_Resource_Type_Nm__c = \'Image\' OR PMP_Company_Resource_Type_Nm__c = \'Thumbnail Image\')';
        
        // system.debug('Query Passed ---> '+query);
        
        return Database.getQueryLocator(query);                                                                                                                                                                                                       
    }
    
    global void execute(Database.BatchableContext bc, List<PMP_Company_Resource__c> scope){
        // system.debug('Scope ---> '+scope);
        PMP_SearchCompanyResourceTriggerActions.createContentAsset(scope);
    }
    
    global void finish(Database.BatchableContext bc){
    }
}