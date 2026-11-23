/**************************************************************************************
Apex Class Name : PMP_OfferingResourceTriggerHelper
Version     : 1.0 
Created Date: 31st Jul, 2019
Description : Trigger handler for PMP_Offering_Resource_Trigger
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shahrukh                  31/07/2019               Original Version
*************************************************************************************/

public class PMP_OfferingResourceTriggerHelper{
    /**
    * @description Method to create content distribution for the offering resource
    * @param List
    * @return void
    **/
  /*  public static void createContentDistribution(List<PMP_Partner_Offering_Resource__c> offResources){
        try{
            //Variable Declarations
            List<ContentDistribution> contentDitributions = new List<ContentDistribution>();
            Set<Id> contDocIds = new Set<Id>();      
            Map<Id,Id> contentVersionIdByDcoumentId = new Map<Id,Id>(); 
            List<PMP_Partner_Offering_Resource__c> imageRelatedOfferingResources = new List<PMP_Partner_Offering_Resource__c>();//Offering with type as image/thumbnail
            Map<Id,Boolean> contentDistributionMap = new Map<Id,Boolean>();
            List<contentDocumentLink> cdlList = new List<contentDocumentLink>();
            List<ContentAsset> contentAssetList = new List<ContentAsset>();
            Map<Id,string> contentAssetMap = new Map<Id,string>();
            Map<string,Id> contentAssetIdByName = new Map<string,Id>();
            List<ContentDocument> cdList = new List<ContentDocument>();
            
            //Loop through all the records and populate content document ids
            for(PMP_Partner_Offering_Resource__c resource: offResources){
                //Check if the resource type is an image/thumbnail image then add all the content document Ids to a set
                if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.Image || resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.THUMBNAIL_IMAGE){
                    if(resource.PMP_Partner_Offering_Image__c!=null && resource.PMP_Partner_Offering_Image__c!=''){
                        contDocIds.add(Id.valueof(resource.PMP_Partner_Offering_Image__c));
                        
                        imageRelatedOfferingResources.add(resource);
                    }    
                }
            }
            
            
            //If content documents are present for the offering resource, Querying content versions and getting all the coresponding Ids.
            if(!contDocIds.isEmpty()){
                for(ContentVersion cr:[select id,ContentDocumentId from ContentVersion where ContentDocumentId IN: contDocIds order by CreatedDate]){
                    contentVersionIdByDcoumentId.put(cr.ContentDocumentId,cr.Id);
                }
                
                for(ContentDistribution cd:[select id,ContentDocumentId from contentDistribution where ContentDocumentId IN: contDocIds]){
                    contentDistributionMap.put(cd.ContentDocumentId,true);
                }
                
                for(ContentDocumentLink cdl:[select ContentDocumentId,Id,ShareType,Visibility from ContentDocumentLink where ContentDocumentId IN: contDocIds]){
                    if(cdl.Visibility!='AllUsers'){
                       cdl.Visibility = 'AllUsers';
                       cdl.ShareType = 'I';
                       cdlList.add(cdl);
                    }
                }
            }
            
           
            
            
            for(PMP_Partner_Offering_Resource__c iResource: imageRelatedOfferingResources){
                //Instantianting content Distribution record and adding it to a list
                if(!contentVersionIdByDcoumentId.isEmpty() && contentVersionIdByDcoumentId.containsKey(iResource.PMP_Partner_Offering_Image__c) && !contentDistributionMap.containsKey(iResource.PMP_Partner_Offering_Image__c)){
                    ContentDistribution cdi = getContentDistributionInstance(contentVersionIdByDcoumentId.get(iResource.PMP_Partner_Offering_Image__c),iResource.Name,iResource.PMP_Offering_Id__c);
                    contentDitributions.add(cdi);
                }   
             }
             
            
            system.debug('###contentDitributions:-'+contentDitributions);
             //Insertion of above created content distribution 
            if(!contentDitributions.isEmpty()){
                 insert contentDitributions;
            }
            
            if(!cdlList.isEmpty()){
                update cdlList;
            }
            
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
    }*/
    /**
    * @description Generic Method to create content distribution and return the instance
    * @param Id,String,Id
    * @return ContentDistribution
    **/
   /* public static contentDistribution getContentDistributionInstance(Id contVersionId, string contVersionName, Id offeringId){
        
        ContentDistribution cdi = new ContentDistribution();
        cdi.ContentVersionId = contVersionId; //Assigning Content Version Id
        cdi.name= contVersionName;           //Assigning the name 
        cdi.PreferencesAllowOriginalDownload=true;
        cdi.PreferencesAllowPDFDownload=true;
        cdi.PreferencesLinkLatestVersion=true;
        cdi.PreferencesAllowViewInBrowser=true;
        cdi.PreferencesNotifyOnVisit=false;
        cdi.RelatedRecordId=offeringId;  // Assigning related record id as offering Id to which offering resource is attached
        return cdi;    
        
    }*/
    /**
    * @description Method to create content Asset for the offering resource
    * @param List
    * @return void
    **/
    public static void createContentAsset(List<PMP_Partner_Offering_Resource__c> offResources){
        system.debug('Inside Content Asset creation---');
        try{
            //Variable Declarations
            Set<Id> contDocIds = new Set<Id>();
            List<contentDocumentLink> cdlList = new List<contentDocumentLink>();
            List<ContentAsset> contentAssetList = new List<ContentAsset>();
            Map<Id,string> contentAssetNameMap = new Map<Id,string>();
            Map<string,Id> contentAssetIdByName = new Map<string,Id>();
            List<ContentDocument> cdList = new List<ContentDocument>();
            
            //Loop through all the records and populate content document ids
            for(PMP_Partner_Offering_Resource__c resource: offResources){
                //Check if the resource type is an image/thumbnail image then add all the content document Ids to a set
                system.debug('resource in helper---'+resource.Id+' '+resource.PMP_Offering_Id__c+' '+resource.PMP_Partner_Offering_Image__c);
                if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.Image || resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.THUMBNAIL_IMAGE){
                    if(string.isNotBlank(resource.PMP_Partner_Offering_Image__c)){
                        contDocIds.add(Id.valueof(resource.PMP_Partner_Offering_Image__c));
                        
                        contentAsset ca = getContentAssetInstance(resource.Id,resource.PMP_Offering_Id__c); //creation of new content asset
                        contentAssetList.add(ca); //Add the created asset to a list for insertion outside loop
                        contentAssetNameMap.put(Id.valueof(resource.PMP_Partner_Offering_Image__c),ca.DeveloperName); //Populating content document id and content asset name to a map : This will be used later to populate content asset id on content document
                    }    
                }
            }
            
            if(!contentAssetList.isEmpty()){
               insert contentAssetList;  //inserting content asset
            }
            
            for(contentAsset ca: contentAssetList){
                contentAssetIdByName.put(ca.DeveloperName,ca.Id);  //populating content asset name and content asset id in a map : With the help of this map we will retrieve the data from contentAssetMap 
            }
            
            for(Id contId: contDocIds){
                contentDocument cd = new contentDocument();
                cd.Id = contId;
                cd.ContentAssetId = contentAssetIdByName.get(contentAssetNameMap.get(cd.Id));
                cdList.add(cd);
            }
            
            
            if(!cdList.isEmpty()){
               update cdList; //Updating content document
            }
            
            //If content documents are present for the offering resource, Querying content versions and getting all the coresponding Ids.
            if(!contDocIds.isEmpty()){
                for(ContentDocumentLink cdl:[select ContentDocumentId,Id,ShareType,Visibility from ContentDocumentLink where ContentDocumentId IN: contDocIds]){
                    if(cdl.Visibility!='AllUsers'){
                       cdl.Visibility = 'AllUsers';
                       cdl.ShareType = 'I';
                       cdlList.add(cdl);
                    }
                }
            }
            
           
            
            if(!cdlList.isEmpty()){
                update cdlList;
            }
            
        }
        catch(exception e){
            system.debug(e.getMessage());
            system.debug('Error---'+e.getLineNumber()+' '+e.getStackTraceString());
        }
    }
    /**
    * @description Generic Method to create content Asset and return the instance
    * @param Id,Id,Id
    * @return ContentAsset
    **/
    public static contentAsset getContentAssetInstance(Id resourceId,Id offId){
        
        ContentAsset ca =  new ContentAsset();
        ca.DeveloperName = string.valueof(resourceId)+'_'+string.valueof(offId);
        ca.MasterLabel= string.valueof(resourceId)+'_'+string.valueof(offId);
        ca.isVisibleByExternalUsers = TRUE;
        return ca;  
    }
    /**
    * @description Method to delete content Asset for the offering resource
    * @param List
    * @return void
    **/
    public static void deleteContentAsset(List<PMP_Partner_Offering_Resource__c> offResources){
       
        system.debug('I came back here');
        Set<Id> contDocIds = new Set<Id>();
        Set<Id> contentAssetIds = new Set<Id>();
        List<ContentAsset> contentAssetList = new List<ContentAsset>();
        set<string> assetUniqueNameSet = new set<string>();
       
        for(PMP_Partner_Offering_Resource__c resource: offResources){
            //Check if the resource type is an image/thumbnail image then add all the content document Ids to a set
            if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.Image || resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.THUMBNAIL_IMAGE){
                if(string.isNotBlank(resource.PMP_Partner_Offering_Image__c)){
                    contDocIds.add(Id.valueof(resource.PMP_Partner_Offering_Image__c));  //storing content document ids in a set
                    assetUniqueNameSet.add(string.valueOf(resource.Id)+'_'+string.valueOf(resource.PMP_Offering_Id__c));
                }    
            }
        }
        system.debug('assetUniqueNameSet'+assetUniqueNameSet);
       /* for(contentDocument cd: [select Id,ContentAssetId from contentDocument where Id IN:contDocIds]){ //querying content documents in order to get corresponding content assets
            contentAssetIds.add(cd.ContentAssetId);  //Querying content document in order to delete content asset     
        }*/
        
        for(contentAsset ca: [select Id,DeveloperName from contentAsset where DeveloperName IN:assetUniqueNameSet]){
            contentAssetList.add(ca);  //Querying content Asset in order to delete     
        }
        
        if(!contentAssetList.isEmpty()){
           delete contentAssetList; //Deleting content Asset
        }
    
    }
    
}