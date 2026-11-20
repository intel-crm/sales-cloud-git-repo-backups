/**************************************************************************************
Apex Class Name : PMP_SearchCompanyResourceTriggerActions
Version     : 1.0 
Created Date: 04/07/2019
Description : Trigger handler for PMP_SearchPartnerTierTrigger
* Modification Log :
* Developer                 Date                     Description
* ---------------------------------------------------------------------------- 
* Prabuddh                  04/07/2019               Original Version
*************************************************************************************/
public WithOut Sharing class PMP_SearchCompanyResourceTriggerActions {
        
    
  /*  public static void updateCompanyResource(List<PMP_Company_Resource__c> newResourceList , Map<Id,PMP_Company_Resource__c> newMap,Map<Id,PMP_Company_Resource__c> oldMap, Boolean triggerContext){
        List<ContentDistribution> cdtList = new List<ContentDistribution>();
        List<Id> delIds = new List<Id>();
        List<ContentDistribution> delList = new List<ContentDistribution>();
        
        Set<Id> conDocIds = new Set<Id>();
        Set<Id> partnerIds = new Set<Id>();
        Id partnerId;
      
        Id contDocId;
        
        map<Id,Id> resVerMap = new Map<Id,Id>();
        map<Id,Id> resContMap = new Map<Id,Id>();
        Boolean contDistrubtionPresent = false;
        
        List<PMP_Company_Resource__c> partner_resources = newResourceList;
        
        //Added by Subash for US622434  
        Map<Id, Id> conDocIdAndConVerId = new Map<Id, Id>();
        
        for(PMP_Company_Resource__c compRes: partner_resources) {
            
            if(compRes.PMP_Company_Image__c != NULL) { 
                conDocIds.add(compRes.PMP_Company_Image__c);
            }   
        }
        if(conDocIds.size() > 0) {
                
            for(ContentVersion cv : [SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :conDocIds]) {
                conDocIdAndConVerId.put(cv.ContentDocumentId, cv.Id);
            }
        }
        //End for US622434  
        for(PMP_Company_Resource__c res: partner_resources){
            if(res.PMP_Company_Resource_Type_Nm__c==PMP_StaticConstants_Offering.Image){
                   //|| res.PMP_Company_Resource_Type_Nm__c==PMP_StaticConstants_Offering.THUMBNAIL_IMAGE){
                    conDocIds.add(Id.valueof(res.PMP_Company_Image__c));
                    partnerIds.add(res.PMP_Company_Id__c);
                    contDocId = Id.valueof(res.PMP_Company_Image__c);
                    resContMap.put(res.id, contDocId);
                    
                    if(contDocId != NULL) {
                        resVerMap.put(res.Id, conDocIdAndConVerId.get(contDocId)); 
                    }
                    
                }
            }
        
        
        
            
            for( PMP_Company_Resource__c res: partner_resources ){
                if(  oldMap.get(res.Id).PMP_Company_Image__c != newMap.get(res.Id).PMP_Company_Image__c){
                    
                    delIds.add(oldMap.get(res.Id).PMP_Company_Image__c);
                        
                }else{
                    conDocIds.remove(newMap.get(res.Id).PMP_Company_Image__c);
                }
                
            }
            
        
        
        
        if(conDocIds!=null && partnerIds!=null){
            
            List<ContentDistribution> checkList = [SELECT id from ContentDistribution WHERE ContentDocumentId in: conDocIds]; //Added by Subash for US622434  
            
            for(PMP_Company_Resource__c res: [SELECT id, Name, PMP_Company_Id__c, PMP_Company_Resource_Type_Nm__c FROM PMP_Company_Resource__c WHERE PMP_Company_Image__c in :conDocIds]){
                if(res.PMP_Company_Resource_Type_Nm__c==PMP_StaticConstants_Offering.Image){
                   //|| res.PMP_Company_Resource_Type_Nm__c==PMP_StaticConstants_Offering.THUMBNAIL_IMAGE){
                    
                    
                    //List<ContentDistribution> checkList = [SELECT id from ContentDistribution WHERE ContentDocumentId in: conDocIds]; //Commented by Subash
                    if(checkList.size() > 0)
                        continue;
                    ContentDistribution cdi = new ContentDistribution();
                    
                    cdi.ContentVersionId = resVerMap.get(res.id);
                    cdi.name= res.Name;
                    cdi.PreferencesAllowOriginalDownload=true;
                    cdi.PreferencesAllowPDFDownload=true;
                    cdi.PreferencesLinkLatestVersion=true;
                    cdi.PreferencesAllowViewInBrowser=true;
                    cdi.PreferencesNotifyOnVisit=false;
                    cdi.RelatedRecordId=res.PMP_Company_Id__c;
                    cdtList.add(cdi);
                }
            }
        
            if(!cdtList.isEmpty()){
                     insert cdtList;
            }
            
            
        }
        
        if(!delIds.isEmpty()){
            List<ContentDistribution> delCds = [SELECT id from ContentDistribution where id in :delIds];
            delete delCds;
        }
        
    } 
*/
/*    
    public static void insertCompanyResource(List<PMP_Company_Resource__c> newResourceList , Map<Id,PMP_Company_Resource__c> newMap, Boolean triggerContext){
        List<ContentDistribution> cdtList = new List<ContentDistribution>();
        List<Id> delIds = new List<Id>();
        List<ContentDistribution> delList = new List<ContentDistribution>();
        
        Set<Id> conDocIds = new Set<Id>();
        Set<Id> partnerIds = new Set<Id>();
        Id partnerId;
      
        Id contDocId;
        
        map<Id,Id> resVerMap = new Map<Id,Id>();
        map<Id,Id> resContMap = new Map<Id,Id>();
        Boolean contDistrubtionPresent = false;
        
        List<PMP_Company_Resource__c> partner_resources = newResourceList;
        
        for(PMP_Company_Resource__c res: partner_resources){
            //if(res.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_partner.IMAGE){
            if(res.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_partner.IMAGE || res.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_partner.THUMBNAIL_IMAGE){ //Uday: for image resize
                    system.debug('resorces '+ res);
                    conDocIds.add(Id.valueof(res.PMP_Company_Image__c));
                    partnerIds.add(res.PMP_Company_Id__c);
                    contDocId = Id.valueof(res.PMP_Company_Image__c);
                    resContMap.put(res.id, contDocId);
                    if(conDocIds!=null){
                        for(ContentVersion cv:[select id,ContentDocumentId from ContentVersion where ContentDocumentId=:contDocId]){
                            resVerMap.put(res.Id,cv.Id);
                        }
                    }
                }
            }       
              
        if(conDocIds!=null && partnerIds!=null){
            for(PMP_Company_Resource__c res: [SELECT id, Name, PMP_Company_Id__c, PMP_Company_Resource_Type_Nm__c FROM PMP_Company_Resource__c WHERE PMP_Company_Image__c in :conDocIds]){
                //if(res.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_partner.IMAGE){
                if(res.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_partner.IMAGE || res.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_partner.THUMBNAIL_IMAGE){ //Uday: for image resize
                    
                    
                    List<ContentDistribution> checkList = [SELECT id from ContentDistribution WHERE ContentDocumentId in: conDocIds];
                    if(checkList.size() > 0)
                        continue;
                    ContentDistribution cdi = new ContentDistribution();
                    
                    cdi.ContentVersionId = resVerMap.get(res.id);
                    cdi.name= res.Name;
                    cdi.PreferencesAllowOriginalDownload=true;
                    cdi.PreferencesAllowPDFDownload=true;
                    cdi.PreferencesLinkLatestVersion=true;
                    cdi.PreferencesAllowViewInBrowser=true;
                    cdi.PreferencesNotifyOnVisit=false;
                    cdi.RelatedRecordId=res.PMP_Company_Id__c;
                    cdtList.add(cdi);
                }
            }
        
        if(!cdtList.isEmpty()){
                            
            
                     insert cdtList;
                }
        }
        
        if(!delIds.isEmpty()){
            List<ContentDistribution> delCds = [SELECT id from ContentDistribution where id in :delIds];
            delete delCds;
        }
        
    }
*/    
   /* public static void createContentDistribution(List<PMP_Company_Resource__c> partner_resources){
        try{
            //Variable Declarations
            List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
            Set<Id> contDocIds = new Set<Id>();      
            Map<Id,Id> contentVersionIdByDcoumentId = new Map<Id,Id>(); 
            List<PMP_Company_Resource__c> imageRelatedPartnerResources = new List<PMP_Company_Resource__c>();//Partner with type as image/thumbnail
            List<contentDocumentLink> cdlList = new List<contentDocumentLink>();
            
            //Loop through all the records and populate content document ids
            for(PMP_Company_Resource__c resource: partner_resources){
                //Check if the resource type is an image/thumbnail image then add all the content document Ids to a set
                if(resource.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_partner.IMAGE || resource.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_partner.THUMBNAIL_IMAGE){
                    contDocIds.add(Id.valueof(resource.PMP_Company_Image__c));
                    imageRelatedPartnerResources.add(resource);
                }
            }
            
            //If content documents are present for the offering resource, Querying content versions and getting all the coresponding Ids.
            if(!contDocIds.isEmpty()){
                for(ContentVersion cr:[select id,ContentDocumentId from ContentVersion where ContentDocumentId IN: contDocIds]){
                    contentVersionIdByDcoumentId.put(cr.ContentDocumentId,cr.Id);
                }
            }
            
            if(!contDocIds.isEmpty()){
             for(ContentDocumentLink cdl:[select ContentDocumentId,Id,ShareType,Visibility from ContentDocumentLink where ContentDocumentId IN: contDocIds]){
                    if(cdl.Visibility!='AllUsers'){
                       cdl.Visibility = 'AllUsers';
                       cdl.ShareType = 'I';
                       cdlList.add(cdl);
                    }
                }
            }
            
            for(PMP_Company_Resource__c iResource: imageRelatedPartnerResources){
                //Instantianting content Distribution record and adding it to a list
                if(!contentVersionIdByDcoumentId.isEmpty() && contentVersionIdByDcoumentId.containsKey(iResource.PMP_Company_Image__c)){
                    ContentDistribution cdi = getContentDistributionInstance(contentVersionIdByDcoumentId.get(iResource.PMP_Company_Image__c),iResource.Name,iResource.PMP_Company_Id__c);
                    contentDistributions.add(cdi);
                }   
             }
            
            system.debug('###contentDistributions:-'+contentDistributions);
             //Insertion of above created content distribution 
            if(!contentDistributions.isEmpty()){
                 insert contentDistributions;
            }
            
            if(!cdlList.isEmpty()){
                update cdlList;
            }
            
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
    } */
   /* public static contentDistribution getContentDistributionInstance(Id contVersionId, string contVersionName, Id partnerid){
        
        ContentDistribution cdi = new ContentDistribution();
        cdi.ContentVersionId = contVersionId; //Assigning Content Version Id
        cdi.name= contVersionName;           //Assigning the name 
        cdi.PreferencesAllowOriginalDownload=true;
        cdi.PreferencesAllowPDFDownload=true;
        cdi.PreferencesLinkLatestVersion=true;
        cdi.PreferencesAllowViewInBrowser=true;
        cdi.PreferencesNotifyOnVisit=false;
        cdi.RelatedRecordId=partnerid;  // Assigning related record id as partner Id to which partner resource is attached
        return cdi;    
        
    } */
    
    /**
    * @description Method to create content Asset for the Company resource
    * @param List
    * @return void
    * User story - US 524658 - Added by Manasa
    **/
    public static void createContentAsset(List<PMP_Company_Resource__c> partner_resources){
        try{
           //Variable Declarations
            Set<Id> contDocIds = new Set<Id>();
            List<contentDocumentLink> cdlList = new List<contentDocumentLink>();
            List<ContentAsset> contentAssetList = new List<ContentAsset>();
            Map<Id,string> contentAssetMap = new Map<Id,string>();
            Map<string,Id> contentAssetIdByName = new Map<string,Id>();
            List<ContentDocument> cdList = new List<ContentDocument>(); 
            //Loop through all the records and populate content document ids
            for(PMP_Company_Resource__c resource: partner_resources){
                //Check if the resource type is an image/thumbnail image then add all the content document Ids to a set
                if(resource.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_partner.IMAGE || resource.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_partner.THUMBNAIL_IMAGE){
                    if(resource.PMP_Company_Image__c!=null && resource.PMP_Company_Image__c!=''){
                        contDocIds.add(Id.valueof(resource.PMP_Company_Image__c));
                        contentAsset ca = getContentAssetInstance(Id.valueof(resource.PMP_Company_Image__c),resource.Id,resource.PMP_Company_Id__c); //creation of new content asset
                        contentAssetList.add(ca); //Add the created asset to a list for insertion outside loop
                        contentAssetMap.put(Id.valueof(resource.PMP_Company_Image__c),ca.DeveloperName); //Populating content document id and content asset name to a map : This will be used later to populate content asset id on content document
                    }    
                }
            }
            
            if(!contentAssetList.isEmpty()){
               //insert contentAssetList;  //inserting content asset
               Database.SaveResult[] caList = Database.insert(contentAssetList, false);
			   PMP_Utility.logDmlErrors((Object[]) caList, 'PMP_SearchCompanyResourceTriggerActions-createContentAsset');


            }
            
            for(contentAsset ca: contentAssetList){
                contentAssetIdByName.put(ca.DeveloperName,ca.Id);  //populating content asset name and content asset id in a map : With the help of this map we will retrieve the data from contentAssetMap
            }
            
            for(contentDocument cd: [select Id,ContentAssetId from contentDocument where Id IN:contDocIds]){
               cd.ContentAssetId = contentAssetIdByName.get(contentAssetMap.get(cd.Id));  //Querying content document in order to update content asset on same
               cdList.add(cd);
               
            }
           
            if(!cdList.isEmpty()){
               //update cdList; //Updating content document
                Database.SaveResult[] cList = Database.update(cdList, false);
			    PMP_Utility.logDmlErrors((Object[]) cList, 'PMP_SearchCompanyResourceTriggerActions-createContentAsset');
            }  
            
            getContentDocumentList(contDocIds,cdlList);
         
            if(!cdlList.isEmpty()){
                //update cdlList;
                Database.SaveResult[] cdlList1 = Database.update(cdlList, false);
			    PMP_Utility.logDmlErrors((Object[]) cdlList1, 'PMP_SearchCompanyResourceTriggerActions-createContentAsset');

            }
               
            
        }catch(exception e){
           PMP_Utility.logError(e,'PMP_SearchCompanyResourceTriggerActions');

        }
        
    }
    
     /**
    * @description Generic Method to create content Asset and return the instance
    * @param Id,Id,Id
    * @return ContentAsset
    * * User story - US 524658 - Added by Manasa
    **/
    public static contentAsset getContentAssetInstance(Id contDocId,Id resourceId,Id partnerid){
        ContentAsset ca =  new ContentAsset();
        ca.DeveloperName = string.valueof(resourceId)+'_'+string.valueof(partnerid);
        ca.MasterLabel= string.valueof(resourceId)+'_'+string.valueof(partnerid);
        ca.isVisibleByExternalUsers = TRUE;
        return ca;          
    }
    
    public static void getContentDocumentList(Set<Id> contDocIds,List<contentDocumentLink> cdlList){
          if(!contDocIds.isEmpty()){
                for(ContentDocumentLink cdl:[select ContentDocumentId,Id,ShareType,Visibility from ContentDocumentLink where ContentDocumentId IN: contDocIds]){
                    if(cdl.Visibility != 'AllUsers'){
                       cdl.Visibility = 'AllUsers';
                       cdl.ShareType = 'I';
                       cdlList.add(cdl);
                    }
                }
            } 
    }
    
    /**
    * @description Method to delete content Asset for the offering resource
    * @param List
    * @return void
    * * User story - US 524658 - Added by Manasa
    **/
    // public static void deleteContentAsset(List<PMP_Company_Resource__c> partner_resources){
    //     Set<Id> contDocIds = new Set<Id>();
    //     Set<Id> contentAssetIds = new Set<Id>();
    //     List<ContentAsset> contentAssetList = new List<ContentAsset>();
        
    //     //system.debug('*******partner_resources***in delete method****'+partner_resources);
    //     for(PMP_Company_Resource__c resource: partner_resources){
    //         //Check if the resource type is an image/thumbnail image then add all the content document Ids to a set
    //         if(resource.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_partner.IMAGE || resource.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_partner.THUMBNAIL_IMAGE){
    //             if(resource.PMP_Company_Image__c!=null && resource.PMP_Company_Image__c!=''){
    //                 contDocIds.add(Id.valueof(resource.PMP_Company_Image__c));  //storing content document ids in a set
    //             }    
    //         }
    //     }
        
    //     for(contentDocument cd: [select Id,ContentAssetId from contentDocument where Id IN:contDocIds]){ //querying content documents in order to get corresponding content assets
    //         contentAssetIds.add(cd.ContentAssetId);  //Querying content document in order to delete content asset     
    //     }
        
    //     for(contentAsset ca: [select Id from contentAsset where Id IN:contentAssetIds]){
    //         contentAssetList.add(ca);  //Querying content Asser in order to delete     
    //     }
         
    //     if(!contentAssetList.isEmpty()){
    //        delete contentAssetList; //Deleting content Asset
    //     }
        
    // }
}