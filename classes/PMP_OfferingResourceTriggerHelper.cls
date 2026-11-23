@isTest
/**************************************************************************************
Apex Class Name : PMP_OfferingResourceTriggerHelper
Version     : 1.0 
Created Date: 31st Jul, 2019
Description : Trigger handler for PMP_Offering_Resource_Trigger 
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shahrukh                  31/07/2019               Original Version
* Sivashankaran Ezhilarasan	31/05/2021				 Added Code to create ContentAsset for Resource Type 'Others' with Image Id
*************************************************************************************/

public without sharing class PMP_OfferingResourceTriggerHelper{
    // /**
    // * @description Method to create content Asset for the offering resource
    // * @param List
    // * @return void
    // **/
    // public static void createContentAsset(List<PMP_Partner_Offering_Resource__c> offResources){
        
    //     try{
    //         //Variable Declarations
    //         Set<Id> contDocIds = new Set<Id>();
    //         List<contentDocumentLink> cdlList = new List<contentDocumentLink>();
    //         List<ContentAsset> contentAssetList = new List<ContentAsset>();
    //         Map<Id,string> contentAssetNameMap = new Map<Id,string>();
    //         Map<string,Id> contentAssetIdByName = new Map<string,Id>();
    //         List<ContentDocument> cdList = new List<ContentDocument>();
    //         String baseCommunityURL = PMP_Utility.getBaseCommunityUrl();
    //         //remove '/s' from baseCommunityURL community URL
    //         if(baseCommunityURL.endsWith('/s')){
    //             baseCommunityURL =baseCommunityURL.removeEnd('/s');
    //         }
    //         //fetch static text called "/file-asset/" from metaData
    //         //String staticFileAsset = PMP_Utility.getValue('Community_File_Asset'); 
    //         //List<PMP_Partner_Offering_Resource__c> sResourceList = new List<PMP_Partner_Offering_Resource__c>();
            
    //         //Loop through all the records and populate content document ids
    //         for(PMP_Partner_Offering_Resource__c resource: offResources){
    //             //Check if the resource record contains image Id i.e content document Id
    //             if(string.isNotBlank(resource.PMP_Partner_Offering_Image__c) && string.isBlank(resource.PMP_External_Source_Id__c)){
    //             	contDocIds.add(Id.valueof(resource.PMP_Partner_Offering_Image__c));
                        
    //                 contentAsset ca = getContentAssetInstance(resource.Id,resource.PMP_Offering_Id__c); //creation of new content asset
    //                 contentAssetList.add(ca); //Add the created asset to a list for insertion outside loop
    //                 contentAssetNameMap.put(Id.valueof(resource.PMP_Partner_Offering_Image__c),ca.DeveloperName); //Populating content document id and content asset name to a map : This will be used later to populate content asset id on content document
    //             }
    //         }
            
    //         if(!contentAssetList.isEmpty()){
    //            insert contentAssetList;  //inserting content asset
    //         }
            
    //         for(contentAsset ca: contentAssetList){
    //             contentAssetIdByName.put(ca.DeveloperName,ca.Id);  //populating content asset name and content asset id in a map : With the help of this map we will retrieve the data from contentAssetMap 
    //         }
            
    //         for(Id contId: contDocIds){
    //             contentDocument cd = new contentDocument();
    //             cd.Id = contId;
    //             cd.ContentAssetId = contentAssetIdByName.get(contentAssetNameMap.get(cd.Id));
    //             cdList.add(cd);
    //         }
            
            
    //         if(!cdList.isEmpty()){
    //            update cdList; //Updating content document
    //         }
            
    //         //If content documents are present for the offering resource, Querying content versions and getting all the coresponding Ids.
    //         if(!contDocIds.isEmpty()){
    //             for(ContentDocumentLink cdl:[select ContentDocumentId,Id,ShareType,Visibility from ContentDocumentLink where ContentDocumentId IN: contDocIds]){
    //                 if(cdl.Visibility!='AllUsers'){
    //                    cdl.Visibility = 'AllUsers';
    //                    cdl.ShareType = 'I';
    //                    cdlList.add(cdl);
    //                 }
    //             }
    //         }
                      
    //         if(!cdlList.isEmpty()){
    //             update cdlList;
    //         }
            
    //     }
    //     catch(exception e){
    //         //system.debug(e.getMessage());
    //         //system.debug('Error---'+e.getLineNumber()+' '+e.getStackTraceString());
    //     }
    // }
    // /**
    // * @description Generic Method to create content Asset and return the instance
    // * @param Id,Id,Id
    // * @return ContentAsset
    // **/
    // public static contentAsset getContentAssetInstance(Id resourceId,Id offId){
        
    //     ContentAsset ca =  new ContentAsset();
    //     ca.DeveloperName = string.valueof(resourceId)+'_'+string.valueof(offId);
    //     ca.MasterLabel= string.valueof(resourceId)+'_'+string.valueof(offId);
    //     ca.isVisibleByExternalUsers = TRUE;
    //     return ca;  
    // }
    // /**
    // * @description Method to delete content Asset for the offering resource
    // * @param List
    // * @return void
    // **/
    // public static void deleteContentAsset(List<PMP_Partner_Offering_Resource__c> offResources){
    //     List<Id> contentDocIds = new List<Id>();
    //     //Set<Id> contentAssetIds = new Set<Id>();
    //     //List<ContentAsset> contentAssetList = new List<ContentAsset>();
    //     set<string> assetUniqueNameSet = new set<string>();
    //     List<Id> imageIds = new List<Id>();
       
    //     for(PMP_Partner_Offering_Resource__c resource: offResources){
    //         if(string.isNotBlank(resource.PMP_Partner_Offering_Image__c)){
    //             //Check if the resource type is thumbnail image then add all the content document Ids to a set
    //             if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.THUMBNAIL_IMAGE){
    //                 assetUniqueNameSet.add(string.valueOf(resource.Id)+'_'+string.valueOf(resource.PMP_Offering_Id__c));
    //                 contentDocIds.add(Id.valueof(resource.PMP_Partner_Offering_Image__c));  //storing thumbnail image content document ids in a set
    //             }
    //             //If other resource types with Content Documents then store the Ids in different set to further filter out using published condition
    //             else{
    //                 assetUniqueNameSet.add(string.valueOf(resource.Id)+'_'+string.valueOf(resource.PMP_Offering_Id__c));
    //                 imageIds.add(Id.valueof(resource.PMP_Partner_Offering_Image__c));  //storing Image/additionals resources content document ids in a List                    
    //             }
    //         }      
    //     }
        
    //     //Fetching the content document Id's of deleted published offering Image/additional resource records
    //     for(PMP_Partner_Offering_Resource__c res: [select Id,PMP_Partner_Offering_Image__c,PMP_Offering_Id__r.PMP_Is_Published_Ind__c from PMP_Partner_Offering_Resource__c 
    //                                                where PMP_Partner_Offering_Image__c IN: imageIds AND PMP_Offering_Id__r.PMP_Is_Published_Ind__c=False 
    //                                                AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Offering.PUBLISHED AND PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = FALSE  ]){
    //         contentDocIds.add(Id.valueof(res.PMP_Partner_Offering_Image__c)); 
    //     }
       
    //     // for(contentAsset ca: [select Id,DeveloperName from contentAsset where DeveloperName IN:assetUniqueNameSet]){
    //     //     contentAssetList.add(ca);  //Querying content Asset in order to delete     
    //     // }
        
    //     // ==if(!contentAssetList.isEmpty()){
    //     //    delete contentAssetList; //Deleting content Asset
    //     // }

    //     //if(!contentDocIds.isEmpty()){
    //     //    DELETE [Select Id from ContentDocument WHERE Id IN :contentDocIds]; //Deleting content documents for deleted thumbnails and published copy image resource records
    //    // }

    //    deleteResourcesFiles(contentDocIds);
    
    // }
    
    
    // public static Void deleteResourcesFiles(List<id> deleteFileIds){
        
    //     List<PMP_Partner_Offering_Resource__c> checkResource = new List<PMP_Partner_Offering_Resource__c>();
    //     List<ContentDocument> toDeleteList = New List<ContentDocument>();

    //     Set<id> deleteFileIds2  = new Set<id>();
    //     Set<id> deleteFileldIdNew  = new Set<id>();

    //     deleteFileIds2.addAll(deleteFileIds);

    //     if(!deleteFileIds2.IsEmpty()){
    //         checkResource = [ Select id,PMP_Partner_Offering_Image__c,PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c,
    //                                             PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c from PMP_Partner_Offering_Resource__c 
    //                                             where PMP_Partner_Offering_Image__c =: deleteFileIds2 ];
    //         if(!checkResource.ISEmpty()){

    //             for (PMP_Partner_Offering_Resource__c offRes : checkResource){
                    
    //                 if ((offRes.PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c == false && 
    //                     offRes.PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Published')){
    //                         deleteFileldIdNew.add(String.valueOf(offRes.PMP_Partner_Offering_Image__c));    
    //                 }  
    //             }

    //             deleteFileIds2.removeAll(deleteFileldIdNew);

                
                
    //             if(!deleteFileIds2.IsEmpty()){ 
                    
    //                 List<id> newIdList = new List<id>(deleteFileIds2);
    //                 deleteFileldIdNew  = new Set<id>();

    //                 for (integer i = 0; i < newIdList.size(); i++ ){
    //                     integer workingCpyCount = 0;
                        
    //                     for (PMP_Partner_Offering_Resource__c offRes : checkResource){
    //                         if(offRes.PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c != 'Published' &&  offRes.PMP_Partner_Offering_Image__c == newIdList[i]){
    //                             workingCpyCount++;
    //                         }

    //                         if(workingCpyCount>= 1){
    //                             deleteFileldIdNew.add(String.valueOf(offRes.PMP_Partner_Offering_Image__c)); 
    //                         }
    //                     }
    //                 }

    //                 deleteFileIds2.removeAll(deleteFileldIdNew);
    //             }
               

    //         } 

        
    //         //getting the list of content documents which needs to be deleted by filtering using the input Ids
    //         toDeleteList = [select id from ContentDocument where Id IN : deleteFileIds2];
            
    //     }
        
    //     if(!toDeleteList.IsEmpty()){
    //         delete toDeleteList;
    //     }

    //     List<ContentAsset> contentAssetList = new List<ContentAsset>();

    //     for(contentAsset ca: [select Id,DeveloperName from contentAsset where ContentDocumentId IN:deleteFileIds2]){
    //         contentAssetList.add(ca);  //Querying content Asset in order to delete     
    //     }
        
    //     if(!contentAssetList.isEmpty()){
    //        delete contentAssetList; //Deleting content Asset
    //     }

    // }
}