public without sharing class PMP_SearchOfferingImageUtility {
    
    /*
* Author: Kumar Prabuddh - Tanzanite
* Created on : 11/04/2019
* Description : Class created for the access of ContentDistribution and ContentVersion Objects.
*/
   /* @AuraEnabled(cacheable=true)
    public static List<Contentversion> getContentVerId( List<String> conDocIdList) {
        List<Contentversion> cvList = new List<Contentversion>();

		if(Schema.sObjectType.ContentVersion.isAccessible()){
	        try{
	            cvList = [Select Id,ContentDocumentId from ContentVersion where ContentDocumentId in : conDocIdList];
	        }catch(Exception e){
	            system.debug('Error in ContentDistribution '+ e.getMessage() ); 
	        }			
		}        
        return cvList;
    }*/
    
    // @AuraEnabled(cacheable=true)
    // public static List<ContentDistribution> getContentDistList(List<String> conDocIdList) {
    //     List<ContentDistribution> cdList = new List<ContentDistribution>();
       
	// 	//if(Schema.sObjectType.ContentDistribution.isAccessible()){
	//         try{
	//             cdList = [SELECT Id,ContentDocumentId, ContentDownloadUrl from ContentDistribution Where ContentDocumentId in: conDocIdList ];
    
	//         }catch(Exception e){
	//             system.debug('Error in ContentDistribution '+ e.getMessage() );
	//         }			
	// 	//}
    //     return cdList;
    // }
    
    /*** User story - US 524658 - Added by Manasa***/
   /* @AuraEnabled(cacheable=true)
    public static List<ContentAsset> getContentAssetList( List<String> conDocIdList) {
        List<ContentAsset> conAssets = new List<ContentAsset>();
        List<ContentDocument> conDocuments = new List<ContentDocument>();
        Set<Id> contentAssetIds = new Set<Id>();
        try{
            if(conDocIdList.size() >0 ){
                conDocuments = [select id,title,ContentAssetId,FileType,FileExtension,ContentSize from ContentDocument where id in :conDocIdList ORDER by createdDate];
                if(!conDocuments.isEmpty()){
                   for(contentDocument cd: conDocuments){
                            contentAssetIds.add(cd.contentAssetId);
                   }
                    if(contentAssetIds.size() > 0){
                        conAssets = [select id,developerName from contentAsset where id IN:contentAssetIds];
                   }
                }
            }
        }catch(Exception e){
	            system.debug('Error in ContentAsset '+ e.getMessage() );
	        }
        return conAssets;       
    }*/
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getContentAssetUrlMap(List<String> conDocIdList){
                       
        Map<String,String> docIdAssetNameMap = new Map<String, String>();
               
        try{
            if(conDocIdList.size() >0 ){
                
                for(ContentAsset ca : [Select Id,developerName, ContentDocumentId from ContentAsset where ContentDocumentId in: conDocIdList]){
                    
                    docIdAssetNameMap.put(ca.ContentDocumentId, ca.DeveloperName);
                    
                }                               
            }            
        }catch(Exception e){
            //system.debug('Error in ContentAsset '+ e.getMessage() );
        }
        return docIdAssetNameMap; 
    }
    
   /* public static Map<String, String> getContentAssetUrl(List<sObject> resources){
        Map<String, String> recordIdAssetNameMap = new Map<String, String>();
        
        for(sObject res : resources){
            String assetUrl = '';
            if(res.getSObjectType() == PMP_Company_Resource__c.sObjectType){
                PMP_Company_Resource__c cRes = (PMP_Company_Resource__c)res;
                assetUrl = '/file-asset/'+string.valueOf(cRes.Id)+'_'+string.valueOf(cRes.PMP_Company_Id__c);
                recordIdAssetNameMap.put(cRes.PMP_Company_Id__c, assetUrl);
            }
            else if(res.getSObjectType() == PMP_Partner_Offering_Resource__c.sObjectType){
                PMP_Partner_Offering_Resource__c oRes = (PMP_Partner_Offering_Resource__c)res;
                assetUrl = '/file-asset/'+string.valueOf(oRes.Id)+'_'+string.valueOf(oRes.PMP_Offering_Id__c);
                recordIdAssetNameMap.put(oRes.PMP_Offering_Id__c, assetUrl);
            }
        }
        
        return recordIdAssetNameMap;
    } */
}