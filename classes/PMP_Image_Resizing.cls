/*************************************************************************************************************************************************************************
* Class Name  : PMP_Image_Resizing 
* Version     : 1.0 
* Created Date: 7/23/2019
* Modification Log :
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Uday              M-01    : Original version     7/23/2019                                 class for resizing the images uploaded in storefront.
**************************************************************************************************************************************************************************/
public without sharing class PMP_Image_Resizing {

    @future (callout=true)
    public static void generateThumbnailImages(Id sObjectId) {

       List<PMP_Company_Resource__c> partnerResources = new List<PMP_Company_Resource__c>(); 
       String contentAssetName = '';
       String contentAssetURL = '';
       String questionMarkSymbol = '?';       
       String partnerName='';
       Id companyResourceId=null;
      // if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()){ //ApexCRUDViolation Fix
        partnerResources = [SELECT Id,
                            PMP_Company_Image__c,
                            PMP_Company_Id__c,PMP_Company_Resource_Sequence_Nbr__c ,PMP_Company_Id__r.Name
                            FROM PMP_Company_Resource__c
                            WHERE PMP_Company_Id__c = :sObjectId AND PMP_Company_Resource_Type_Nm__c='Image'];

     //  }   
   
         if(!partnerResources.isEmpty() && string.isNotBlank(partnerResources[0].PMP_Company_Image__c)) {
             contentAssetName = string.valueOf(partnerResources[0].Id) +'_'+ string.valueOf(partnerResources[0].PMP_Company_Id__c);
             partnerName = partnerResources[0].PMP_Company_Id__r.Name;
             companyResourceId= partnerResources[0].Id;

            }

            HTTPResponse response;           

            //fetch base community URL
            String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();

            //remove '/s' from baseCommunityUrl community URL
            if(baseCommunityUrl.endsWith('/s')){
                baseCommunityUrl =baseCommunityUrl.removeEnd('/s');
            }            
            //fetch static text called "/file-asset" from metaData
            String staticFileAsset = PMP_Utility.getValue('Community_File_Asset');  

             if(string.isNotEmpty(contentAssetName)) {

                 contentAssetURL =  baseCommunityUrl+staticFileAsset+contentAssetName+questionMarkSymbol;
                 //IPA2.0:US-4497-1631_OfferingEOL
                 //response = PMP_ImageResizeService.makeCalloutToPIM(contentAssetURL);// make a call out to PIM
                 response = PMP_CompanyImageResizeService.makeCalloutToPIM(contentAssetURL);// make a call out to PIM


             }

             //if response status is 200 means it is a success call
             if(response != null && response.getStatusCode() == 200){
                //get the response body as blob data
                blob thumbNailImage = response.getBodyAsBlob();
               //Create a content version instance
               ContentVersion newVersion = CreateContentVersionInstance(contentAssetName,thumbNailImage);

               //insert offering resource record with resource type as thumbnail
               insertThumbnailCompanyResource(newVersion,partnerResources[0].PMP_Company_Id__c,Integer.valueOf(partnerResources[0].PMP_Company_Resource_Sequence_Nbr__c));

             }
            else if(response != null && response.getStatusCode() == 400) { 
                    //create log entry record to track the failed callouts 
                PMP_Utility.creatFailedCalloutLogEntryRecord(companyResourceId,'PMP_CompanyImageResizeService','PMP','PMP_Company_Resource__c','Failed',
                                                             response,sObjectId,partnerName);
            }
            else if(response != null){
                //create log entry record to retry from batch 
                PMP_Utility.creatFailedCalloutLogEntryRecord(companyResourceId,'PMP_CompanyImageResizeService','PMP','PMP_Company_Resource__c','Investigating',
                                                             response,sObjectId,partnerName);
            }
        }


    public static ContentVersion CreateContentVersionInstance (String resourceAssetId, Blob thumbNailImage) {

        //Network Id of Partner Solutions Market place community
        Network psmNetwork;

        psmNetwork = [SELECT Id FROM Network WHERE Name =: PMP_Utility.getValue('Marketplace_Community_Name') ];

        Id networkId;
        if(psmNetwork != null){
            networkId = psmNetwork.Id;
        }
        ContentVersion contentVersion = new ContentVersion();//content version instance
        contentVersion.Title = resourceAssetId;// title of content version
        contentVersion.PathOnClient = resourceAssetId + Datetime.now().getTime() + '.png'; // set path on client
        contentVersion.VersionData = thumbNailImage; // set the thumbnail image as the data
        contentVersion.Origin = 'H'; // set the origin
        //contentVersion.PublishStatus = 'P';//The document is published to a public library and is visible to other users
        contentVersion.NetworkId = networkId; //ID of the community that this file originated from
		//contentVersion.OwnerId = UserInfo.getUserId(); // explicit owner to match context
        insert contentVersion; // insert content version

        return contentVersion;
    }

     public static void insertThumbnailCompanyResource (ContentVersion content,Id partnerId,Integer imgSequence) {

        id documentId;

        documentId = [Select ContentDocumentId FROM ContentVersion WHERE Id =:content.Id].ContentDocumentId;


        PMP_Company_Resource__c companyResource = new PMP_Company_Resource__c(); // offering resource instance
        companyResource.Name = content.Title.length()>80 ? content.Title.subString(0,80) : content.Title; // populating company resource name
        companyResource.PMP_Company_Resource_Type_Nm__c = 'Thumbnail Image';
        companyResource.PMP_Company_Id__c = partnerId; // associating company Id
        companyResource.PMP_Company_Image__c = documentId; // associating content document id
        companyResource.PMP_Company_Resource_Sequence_Nbr__c = imgSequence;

      //  if(Schema.sObjectType.PMP_Company_Resource__c.isCreateable()){ //ApexCRUDViolation Fix
        insert companyResource; // insert company resource
      //  }   

    }       
}