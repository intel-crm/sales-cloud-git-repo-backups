/*************************************************************************************************************************************************************************
* Class Name  : PMP_SearchGenerateThumbnailImages 
* Version     : 1.0 
* Description : One time batch class for resizing and generating thumbnail image records for the images uploaded in the company resources.
* Modification Log : 
*
* Developer         Modification Log        Date                    Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Sooriya              M-01               12/23/2020         Modified the class with content asset changes

Execute the below code in anonymous window once the image records are loaded in the company resources object.
********************************************************************************************************
PMP_SearchGenerateThumbnailImages companyThumbnailImageBatch = new PMP_SearchGenerateThumbnailImages(); 
Id batchJobId = Database.executeBatch(companyThumbnailImageBatch,1); //batch size should be one
**************************************************************************************************************************************************************************/

global without sharing class PMP_SearchGenerateThumbnailImages implements Database.Batchable<sObject>, Database.AllowsCallouts {
    //start method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, name, CreatedDate, CreatedById from PMP_Company__c '+
                       ' Where CreatedById = \'' +System.Label.PMP_CreatedByIdFilter + '\''+
                       ' AND CreatedDate >= '+System.Label.PMP_CreatedDateFilter + 
                       ' AND CreatedDate <= '+System.Label.PMP_CreatedByDateEndFilter;
        
        // system.debug('query = '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<PMP_Company__c> partners) {
        for(PMP_Company__c partner : partners){  
            generateThumbnails(partner.Id);
        }        
    }

    global void finish(Database.BatchableContext bc) {
        //Id jobId = bc.getJobId();
        // System.debug('JobId----->'+jobId);
    } 

    public void generateThumbnails(Id partnerId) {
    
         try{            
            List<PMP_Company_Resource__c> partnerResources = new List<PMP_Company_Resource__c>(); 

            String contentAssetName = '';
            String contentAssetURL = '';
            String questionMark = '?'; 
            blob thumbNailImage;
            String partnerName='';
            Id companyResourceId=null;
            //query company resources for the company Image
            partnerResources = [SELECT Id,
                                   PMP_Company_Image__c,
                                   PMP_Company_Id__c,PMP_Company_Resource_Sequence_Nbr__c ,PMP_Company_Id__r.Name
                                   FROM PMP_Company_Resource__c WHERE
                                   PMP_Company_Id__c = :partnerId
                                   AND PMP_Company_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.IMAGE];
                        
            if(string.isNotBlank(partnerResources[0].PMP_Company_Image__c)) {
                 contentAssetName = string.valueOf(partnerResources[0].Id) +'_'+ string.valueOf(partnerResources[0].PMP_Company_Id__c);
                partnerName=partnerResources[0].PMP_Company_Id__r.Name;
                companyResourceId=partnerResources[0].Id;
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
                contentAssetURL =  baseCommunityUrl+staticFileAsset+contentAssetName+questionMark;
				//IPA2.0:US-4497-1631_OfferingEOL
                //response = PMP_ImageResizeService.makeCalloutToPIM(contentAssetURL);// make a call out to PIM
                response = PMP_CompanyImageResizeService.makeCalloutToPIM(contentAssetURL);// make a call out to PIM

            }              
                 
             //if response status is 200 means it is a success call
             if(response != null && response.getStatusCode() == 200){              
                //get the response body as blob data
                thumbNailImage = response.getBodyAsBlob();
                 //Create a content version instance
                 ContentVersion newVersion = PMP_Image_Resizing.CreateContentVersionInstance(contentAssetName,thumbNailImage);
                 
                 //insert offering resource record with resource type as thumbnail
                 PMP_Image_Resizing.insertThumbnailCompanyResource(newVersion,partnerResources[0].PMP_Company_Id__c,Integer.valueOf(partnerResources[0].PMP_Company_Resource_Sequence_Nbr__c));                        
             }
             else if(response != null && response.getStatusCode() == 400) { 
                 //create log entry record to track the failed callouts 
                 PMP_Utility.creatFailedCalloutLogEntryRecord(companyResourceId,'PMP_CompanyImageResizeService','PMP','PMP_Company_Resource__c','Failed',
                                                              response,partnerId,partnerName);
             }
             else if(response != null){
                 //create log entry record to retry from batch 
                 PMP_Utility.creatFailedCalloutLogEntryRecord(companyResourceId,'PMP_CompanyImageResizeService','PMP','PMP_Company_Resource__c','Investigating',
                                                              response,partnerId,partnerName);
             }

           
        }catch(Exception ex){
            //system.debug('Exception while making PIM Resize callout:->'+ex);
            PMP_Utility.logError(ex,'PMP_Company_Thumbnail_Batch');
        }
        
    
    }    
}