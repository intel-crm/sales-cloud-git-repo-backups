/****************************************************************************************************************************************
* Class Name  : PMP_OfferingResourceHelper
* Version     : 1.0 
* Created Date: 06-20-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Raj                   06-20-2019                    Created for Creating Offering resource records
****************************************************************************************************************************************************************/
public with sharing class PMP_OfferingResourceHelper { 
    
	/**
    * Method added by raj to create OfferingResource records
    * @description-create offering resource records 
    * @param formData the data entered by user on create offering form
    * @param offeringId the Id of the offering
    * @return void
    * Method Parameters - Intel_FormData
    * Method Parameters - Id
    */
    public static void createOfferingResource(Intel_FormData formData, id offeringId){
        
	  	List<PMP_Partner_Offering_Resource__c> addOfferingResources = new List<PMP_Partner_Offering_Resource__c>();//list of offeringResources which are to be inserted
        List<PMP_Partner_Offering_Resource__c> delOfferingResources = new List<PMP_Partner_Offering_Resource__c>();//list of offeringResources which are to be deleted
        PMP_Partner_Offering_Resource__c offeringResource;
        List<Id> linkIds = new List<Id>();
       	List<ContentDocument> contentDoc= new List<ContentDocument>();
        Integer imageOrder=0;
        
        //Implement sequencing to the Product web page and Additional Resources :
        Integer prodWebPageSequence = 0;
        Integer additionalResSequence = 1;
        
      	//fetch the existing offering resources records
      	List<PMP_Partner_Offering_Resource__c> existingOfferingResources=PMP_CreateOfferingTab4Service.getOfferingResources(offeringId);
        
        for(PMP_Partner_Offering_Resource__c res : existingOfferingResources){
            if(res.PMP_Resource_Type_Nm__c != 'Thumbnail Image'){//adding all offeringresources to delete list except for the 'Thumbnail Image' type
                delOfferingResources.add(res);
            }
        }
      	
        //setting the savepoint to protect the existing records in case of exception 
      	Savepoint sp = Database.setSavepoint();
        
                  //for product web page related information
                  if(formData.productWebPageData!=null && String.isNotBlank(formData.productWebPageData.Name) && String.isNotBlank(formData.productWebPageData.Url)) {
                    //create offering resource record for type Product Web Page
                    offeringResource = new PMP_Partner_Offering_Resource__c();
                    offeringResource.PMP_Offering_Id__c = offeringId;
                    offeringResource.Name = formData.productWebPageData.Name; 
                    offeringResource.PMP_Partner_Offering_Resource_URL_Txt__c = formData.productWebPageData.Url;
                    offeringResource.PMP_Resource_Type_Nm__c = 'Product Web Page'; // TODO : Need to move to custom labels if this text displays in UI
                    offeringResource.PMP_Resource_Sequence_Nbr__c = prodWebPageSequence;
                    addOfferingResources.add(offeringResource);
                  }
                    
                  //for additional resources
                  if(!formData.resources.isEmpty()){
                      for(PMP_Partner_Offering_Resource__c resource : formData.resources){
                            system.debug('formData.resources------->'+resource);
                          	//creating Offering Resource record for type other than Product Web Page and Image
                            offeringResource = new PMP_Partner_Offering_Resource__c();
                            offeringResource.PMP_Offering_Id__c = offeringId;
                            offeringResource.Name = resource.Name;
                            offeringResource.PMP_Partner_Offering_Resource_URL_Txt__c =resource.PMP_Partner_Offering_Resource_URL_Txt__c;
                            offeringResource.PMP_Resource_Type_Nm__c = resource.PMP_Resource_Type_Nm__c;
                          	offeringResource.PMP_Resource_Sequence_Nbr__c = additionalResSequence;
                            addOfferingResources.add(offeringResource);
                      		additionalResSequence++;
                      }
                  }
                    
                  //Added by raj to add images to offering resources object for US357476
                  
                  List<ContentDocumentLink> links = [SELECT Id,ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = :offeringId];//to fetch records related to the offering
        
                  for (ContentDocumentLink l : links) {//add contentDocumentId of the fetched record to a list
                  		linkIds.add(l.ContentDocumentId);
                  }
                  
                  for(ContentDocument cd:[SELECT Id, Title, CreatedDate FROM ContentDocument WHERE Id IN :linkIds ORDER BY CreatedDate]){//fetch all contentdocument record for all the Ids in the list 
                      //creating offering resources record for type image
                            offeringResource = new PMP_Partner_Offering_Resource__c();
                            offeringResource.PMP_Offering_Id__c = offeringId;
                            offeringResource.Name = cd.Title;
                            offeringResource.PMP_Resource_Type_Nm__c ='Image';
                            offeringResource.PMP_Partner_Offering_Image__c=cd.Id;
                            offeringResource.PMP_Resource_Sequence_Nbr__c=imageOrder;
                      		system.debug('Resource Sequence Number-----'+offeringResource.PMP_Resource_Sequence_Nbr__c);
                            addOfferingResources.add(offeringResource);
                            imageOrder++;
                  }
          /*----------------------------End US357476----------------------------------------*/
            try{
                if(!delOfferingResources.isEmpty()){//deleting already existing OfferingResource if any record exists
                    delete delOfferingResources;
                }   
                
                if(!addOfferingResources.isEmpty()) {//insert offeringResource records if present
                    system.debug('offering resource list----'+addOfferingResources);
                    insert addOfferingResources;
                }
                
            }
            catch(Exception e){
                  Database.rollback(sp);//rollback to the save point if there is any error while inserting or deleting
                  system.debug(e.getMessage()+e.getLineNumber());
                  throw e;
                }
      }
    
    /**
    * Method added by raj to fetch productwebpage data from offering resources records
    * @description- fetch productwebpage data from offering resources record
    * @param offeringId the Id of the offering
    * @return Intel_ProductWebPageDataWrapper
    * Method Parameters - Id
    */
    public static Intel_ProductWebPageDataWrapper getProductWebPageData(Id offeringId){
        
        Intel_ProductWebPageDataWrapper webPageData = new Intel_ProductWebPageDataWrapper();
        
        if(offeringId != null && string.isNotBlank(offeringId)){
            List<PMP_Partner_Offering_Resource__c> offeringResources = PMP_CreateOfferingTab4Service.getOfferingResources(offeringId);
            for(PMP_Partner_Offering_Resource__c resource : offeringResources){
                if(resource.PMP_Resource_Type_Nm__c == 'Product Web Page'){
                   webPageData.Name =  resource.Name;
                   webPageData.Url = resource.PMP_Partner_Offering_Resource_URL_Txt__c;
                }
            }
        }
        return webPageData;
    }
    /**
    * Method added by raj to fetch additional resources data from offering resources records
    * @description- fetch additional resources data from offering resources record
    * @param offeringId the Id of the offering
    * @return List<PMP_Partner_Offering_Resource__c>
    * Method Parameters - Id
    */
    public static List<PMP_Partner_Offering_Resource__c> getAdditionalResources(Id offeringId){
        
        List<PMP_Partner_Offering_Resource__c> additionalResources = new List<PMP_Partner_Offering_Resource__c>();//additional resources list
        
        if(offeringId != null && string.isNotBlank(offeringId)){
            List<PMP_Partner_Offering_Resource__c> offeringResources = PMP_CreateOfferingTab4Service.getOfferingResources(offeringId);//fetch all the offering resources related to that offering
            for(PMP_Partner_Offering_Resource__c resource : offeringResources){
                if(resource.PMP_Resource_Type_Nm__c != 'Product Web Page' && resource.PMP_Resource_Type_Nm__c != 'Image'//resource type other than Image,Thumbnail Image and Product Web Page are additional resources 
                   && resource.PMP_Resource_Type_Nm__c != 'Thumbnail Image'){
					additionalResources.add(resource);
                }
            }
        }
        return additionalResources;
    }
    
}