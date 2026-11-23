/*************************************************************************************************************************************************************************
* Class Name  : PMP_CloneOfferingController 
* Version     : 1.0 
* Created Date: 1/03/2020
* Modification Log :
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Shahrukh Riyan    M-01    : Original version     1/03/2020                           This class is used for functionalities related to clone offering
**************************************************************************************************************************************************************************/
@isTest
public without sharing class PMP_CloneOfferingController{ 
    
//     /**
//     * @description Method To clone Offering
//     * @param Id
//     * @return PMP_LightningServerResponse
//     **/
//     @AuraEnabled
//     public static PMP_LightningServerResponse cloneOffering(Id offeringId,string language){
    
//         //Boolean bSuccessful = true;    
//         map<string,object> uiData = new map<string,object>();
//         map<String, Object> mapErrorInfo = new map<string,object>();
        
        
//         String communityURL = PMP_Utility.getBaseCommunityUrl(); // getting community base url
        
//         try{
//             //Querying offering that needs to be cloned
//             if(Schema.sObjectType.pmp_partner_offering__c.isAccessible()){
//             DescribeSObjectResult offFields = pmp_partner_offering__c.getSObjectType().getDescribe();
//             string tempoffQuery = PMP_Utility.getObjectFields(offFields);
//             string offQuery = tempoffQuery +    ' WHERE ' +         ' Id =: offeringId';
//             list<pmp_partner_offering__c>  clonedofferinglist = Database.query(offQuery);
            
//             if(clonedofferinglist.size()>0){
//                 pmp_partner_offering__c clonedOffering = new pmp_partner_offering__c(); //cloning offering with clone method
//                 clonedOffering = clonedofferinglist[0].clone(false,true,true,false);
//                 clonedoffering.PMP_Translated_Languages__c = clonedofferinglist[0].PMP_Offering_Language_Nm__c;
//                 if(language != null && language != 'NA'){ //If language parameter is not null, we need to translate the name, desc and tagline fields.
//                     getOfferingTranslation(clonedOffering, clonedofferinglist[0], language );
//                 }
//                 clonedOffering.PMP_Active_Step_Txt__c = '0';    //setting active step and current step to zero to land on page 1 and setting status as draft
//                 clonedOffering.PMP_Current_Step_Txt__c = '0';
//                 clonedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Draft';
//                 clonedOffering.PMP_Partner_Offering_Sync_Status_Nm__c = '';
//                 clonedOffering.PMP_Working_Copy_Id__c = Null; // setting the working copy as null
//                 clonedOffering.PMP_Intel_Admin_Id__c = Null;
//                 clonedoffering.PMP_Translation_Lifecycle_Status_nm__c = clonedofferinglist[0].PMP_Translation_Lifecycle_Status_nm__c == 'Not Applicable'?'Not Applicable':'Pending';
//                 clonedoffering.PMP_Is_Published_Ind__c = false;
//                 clonedoffering.PMP_Is_Notified_Ind__c=false;//setting isnotified to false while cloning the offering
//                 //clonedoffering.PMP_Is_Pre_Release_Published_Ind__c=false;//setting pre release publish indicator to false while cloning the offering
//                 clonedoffering.PMP_Pre_Release_Check_Nm__c='';//Clearing Pre-release check
//                 clonedoffering.PMP_Partner_Offering_Start_Dt__c = system.today();
//                 clonedoffering.PMP_Partner_Offering_End_Dt__c = system.today().addDays(730);
//                 clonedoffering.createdByID = UserInfo.getUserId() ;
//                 clonedoffering.OwnerId = UserInfo.getUserId() ;
//                 clonedoffering.PMP_Featured_Offering_Ind__c = false; //Added by shahrukh to clear featured offering Ind 21/4/2021
                
//                 string cloneOfferingPrefixName = '['+Label.PMP_CloneOfferingNamePrefix+']';
//                 String offeringName = clonedOffering.PMP_Partner_Offering_Nm__c;
//                 string dateValue = system.today().format();
//                 string cloneOfferingSuffixName = '['+dateValue.replace('/','-')+' '+ Datetime.now().format('h:mm a')+']';
//                 clonedOffering.PMP_Partner_Offering_Nm__c = cloneOfferingPrefixName+' '+ offeringName.left(220).unescapeHtml4() +' '+ cloneOfferingSuffixName;
//                 clonedOffering.Name = cloneOfferingPrefixName+' '+ offeringName.left(45).unescapeHtml4() +' '+ cloneOfferingSuffixName;
//                 if(string.isNotBlank(clonedOffering.PMP_Partner_Offering_Tag_Line_Txt__c)){
//                    clonedOffering.PMP_Partner_Offering_Tag_Line_Txt__c = clonedOffering.PMP_Partner_Offering_Tag_Line_Txt__c.unescapeHtml4();
//                 }
//                 if(string.isNotBlank(clonedOffering.PMP_Partner_Offering_Dsc__c)){
//                    clonedOffering.PMP_Partner_Offering_Dsc__c= clonedOffering.PMP_Partner_Offering_Dsc__c.unescapeHtml4();
//                 }
      
//                 List<PMP_Category__c> categoryList=new List<PMP_Category__c>();
//                 //Need to update the subcategory as Partner Solutions and business segment for cloning the solution related offerings- TWC1824-2406
//                 if( clonedOffering.PMP_Category_nm__c == PMP_StaticConstants_Offering.solutionCategory
//                   && Schema.sObjectType.PMP_Category__c.isAccessible()){
//                     categoryList =[select id , name, PMP_Ancestor_Category_Cd__c, PMP_Partner_Product_Category_Cd__c,PMP_Business_Segment_Nm__c from PMP_Category__c where name=:PMP_StaticConstants_Offering.partnerSolutionsCategory];
//                 }
//                 if(categoryList.size()>0){
//                     clonedOffering.PMP_Business_Segment_Nm__c=categoryList[0].PMP_Business_Segment_Nm__c;
//                     clonedOffering.PMP_Sub_Category_nm__c = categoryList[0].Name;
//                 }            

//                 pmp_partner_offering__c publishedClonedOffering = new pmp_partner_offering__c();
//                 publishedClonedOffering = clonedOffering.clone(false,true,true,false);
//                 publishedClonedOffering.PMP_Is_Not_Available_On_MP_Ind__c = true;
//                 publishedClonedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
//                 publishedClonedOffering.PMP_Partner_Offering_LifecycleStatus_Txt__c= publishedClonedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c;   
                        
//                 insert clonedOffering; //inserting newly cloned offering and returning it back to client side.
                
//                 publishedClonedOffering.PMP_Working_Copy_Id__c = clonedOffering.id;
//                 insert publishedClonedOffering;

//                 uiData.put('clonedRecId',clonedOffering.Id);
//                 //uiData.put('clonedRecId',publishedClonedOffering.Id);
//                 uiData.put('communityURL',communityURL);
                
//                 if(clonedOffering.Id!=null){
//                    List<PMP_Partner_Offering_Category__c> clonedOffCats = cloneOfferingCategories(offeringId,clonedOffering,categoryList);//TWC1824-2406 , updated the parameters
                   
//                    if(!clonedOffCats.isEmpty()){
//                       insert clonedOffCats; //inserting offering categories
//                    }
                   
//                    List<PMP_Partner_Offering_Specification__c> clonedOffSpecs = cloneOfferingSpecifications(offeringId,clonedOffering.Id);
                   
//                    if(!clonedOffSpecs.isEmpty()){
//                       insert clonedOffSpecs; //inserting offering specifications
//                    }
                   
//                    List<PMP_Partner_Offering_Resource__c> clonedOffResources = cloneOfferingResourcesDocumentLink(offeringId,clonedOffering.Id);
//                    if(!clonedOffResources.isEmpty()){
//                       insert clonedOffResources; //inserting offering resources
//                    }
                   
//                 }

//                 if(publishedClonedOffering.Id!=null){
//                     List<PMP_Partner_Offering_Category__c> clonedOffCatsPublished = cloneOfferingCategories(offeringId,publishedClonedOffering,categoryList);//TWC1824-2406 , updated the parameters
                    
//                     if(!clonedOffCatsPublished.isEmpty()){
//                        insert clonedOffCatsPublished; //inserting offering categories
//                     }
                    
//                     List<PMP_Partner_Offering_Specification__c> clonedOffSpecsPublished = cloneOfferingSpecifications(offeringId,publishedClonedOffering.Id);
                    
//                     if(!clonedOffSpecsPublished.isEmpty()){
//                        insert clonedOffSpecsPublished; //inserting offering specifications
//                     }
                    
//                     List<PMP_Partner_Offering_Resource__c> clonedOffResourcesPublished = cloneOfferingResourcesDocumentLink(offeringId,publishedClonedOffering.Id);
//                     if(!clonedOffResourcesPublished.isEmpty()){
//                        insert clonedOffResourcesPublished; //inserting offering resources
//                     }
                    
//                  }
//             }
//             }  
        
        
//         }catch (Exception e) {
//             PMP_Utility.logError(e,'PMP_CloneOffering');
            
//         }
        
//         return new PMP_LightningServerResponse(true,mapErrorInfo,uiData);
    
    
    
//     }
    
//     /**
//     * @description Method To clone Offering categories
//     * @param Id,Id
//     * @return List<PMP_Partner_Offering_Category__c>
//     **/
//     @AuraEnabled
//     public static List<PMP_Partner_Offering_Category__c> cloneOfferingCategories(Id offeringId, PMP_Partner_Offering__c clonedOffering,List<PMP_Category__c> categories ){
    
//          List<PMP_Partner_Offering_Category__c> clonedOffCatList = new List<PMP_Partner_Offering_Category__c>();
//         try{
//             //Querying all the child records
//             if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
//                 DescribeSObjectResult offCatFields = PMP_Partner_Offering_Category__c.getSObjectType().getDescribe();   
//                 string tempoffCatQuery = PMP_Utility.getObjectFields(offCatFields);
//                 string offCatQuery = tempoffCatQuery+    ' WHERE ' +         ' PMP_Offering_Id__c =: offeringId';  
//                 List<PMP_Partner_Offering_Category__c> tempCatList = Database.query(offCatQuery);
//                 Boolean hasPartnerSol=false;
//                 for(PMP_Partner_Offering_Category__c offCat:tempCatList){
//                     //TWC1824-2406, if category = solution, skip all the subcategories of solution except Partner solutions.
//                     if(offCat.PMP_Ancestor_Category_Cd__c=='NPP_01_TYPE|IPA_TYPE_Sol'){
//                         if(offCat.Name==PMP_StaticConstants_Offering.partnerSolutionsCategory) {
//                             hasPartnerSol=true;
//                         }
//                         else {
//                             continue;
//                         }
//                     }
//                     PMP_Partner_Offering_Category__c clonedOffCat = new PMP_Partner_Offering_Category__c();
//                     clonedOffCat = offCat.clone(false,false,true,true);
//                     clonedOffCat.PMP_Offering_Id__c = clonedOffering.Id;
//                     clonedOffCat.CreatedById = UserInfo.getUserId();
//                     clonedOffCatList.add(clonedOffCat);
//                 }
//                 //TWC1824-2406 ,if category=solution, Below code will create the partner solutions category association if its not there in the offering from which it is being cloned              
//                 if(clonedOffering.PMP_Category_nm__c == PMP_StaticConstants_Offering.solutionCategory && !hasPartnerSol && categories.size()>0){
//                     PMP_Partner_Offering_Category__c offeringCat = new PMP_Partner_Offering_Category__c();
//                     offeringCat.PMP_Ancestor_Category_Cd__c = categories[0].PMP_Ancestor_Category_Cd__c;
//                     offeringCat.PMP_Category_Id__c = categories[0].Id; 
//                     offeringCat.Name = categories[0].Name;
//                     offeringCat.PMP_Offering_Category_External_Key__c   = categories[0].PMP_Partner_Product_Category_Cd__c;
//                     offeringCat.PMP_Offering_Id__c   = clonedOffering.Id;
//                     clonedOffCatList.add(offeringCat);
//                 }
                
//             }
            
//             }catch(exception e){
//             PMP_Utility.logError(e,'PMP_CloneOffering');
//         }
//         return clonedOffCatList;
//     }
     
//      /**
//     * @description Method To clone Offering specs
//     * @param Id,Id
//     * @return List<PMP_Partner_Offering_Specification__c>
//     **/
//      public static List<PMP_Partner_Offering_Specification__c> cloneOfferingSpecifications(Id offeringId,Id clonedOfferingId){
//         List<PMP_Partner_Offering_Specification__c> clonedOffSpecList = new List<PMP_Partner_Offering_Specification__c>();
//         try{
//             //Querying all the child records
//             if(Schema.sObjectType.PMP_Partner_Offering_Specification__c.isAccessible()){
//                 DescribeSObjectResult offSpecFields = PMP_Partner_Offering_Specification__c.getSObjectType().getDescribe();   
//                 string tempoffSpecQuery = PMP_Utility.getObjectFields(offSpecFields);
//                 string offSpecQuery = tempoffSpecQuery +    ' WHERE ' +         ' PMP_Offering_Id__c =: offeringId';   
//                 List<PMP_Partner_Offering_Specification__c> tempSpecList = Database.query(offSpecQuery);
                            
//                 for(PMP_Partner_Offering_Specification__c offSpec:tempSpecList){
//                     PMP_Partner_Offering_Specification__c clonedOffSpec = new PMP_Partner_Offering_Specification__c();
//                     clonedOffSpec = offSpec.clone(false,false,true,true);
//                     clonedOffSpec.PMP_Offering_Id__c = clonedOfferingId;
//                     clonedOffSpec.CreatedById = UserInfo.getUserId();
//                     clonedOffSpecList.add(clonedOffSpec);
//                 }
                
                
//                 }
//             }catch(exception e){
//                 PMP_Utility.logError(e,'PMP_CloneOffering');
//             }
//         return clonedOffSpecList;
        
//         }
    
//     /**
//     * Method added by raj to create offeringResource records for cloned offering
//     * @description-Method to create cloned offeringResource
//     * @param-offeringId Id of the offering which is being cloned
//     * @param-clonedOfferingId Id of the cloned offering
//     * @return-List<PMP_Partner_Offering_Resource__c>
//     * Method Parameters-Id,Id 
//     **/    
//     public  static List<PMP_Partner_Offering_Resource__c> cloneOfferingResources(Id offeringId, Id clonedOfferingId){
//         List<PMP_Partner_Offering_Resource__c> clonedOfferingResources = new List<PMP_Partner_Offering_Resource__c>();//list to store newly created offeringResources
//         List<ContentVersion> clonedContentVersions = new List<ContentVersion>();//List to store newly created contentVersions
//         List<ContentDocumentLink> clonedDocumentLinks = new List<ContentDocumentLink>();//List to store contentDocumentLinks 
//         Set<Id> contentDocs = new Set<Id>();//List to store contentDocuments of the existing offering images 
//         Set<Id> clonedContentVersionIds = new Set<Id>();//list to store newly created contentversion 
//         Map<Id,Id> resourceIdByContentId = new Map<Id,Id>();//map to store existing resource Ids by contentDocument Ids
//         Map<Id, Id> contentIdByResourceId = new Map<Id, Id>();//map to store existing contentDocument Ids by resource Ids
//         Map<Id, Id> clonedContentIdsByOriginalContentIds = new Map<Id, Id>();// map to store newly created contentDocument Ids by existing contentDocument Ids.
        
//         try{
//             if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
//             DescribeSObjectResult offeringResourceFields = PMP_Partner_Offering_Resource__c.getSObjectType().getDescribe();
//             string tempoffResourceQuery = PMP_Utility.getObjectFields(offeringResourceFields);
//             string offResourceQuery= tempoffResourceQuery+    ' WHERE ' +         ' PMP_Offering_Id__c =: offeringId and PMP_External_Source_Id__c = null and PMP_Resource_Type_Nm__c!=\''+'Thumbnail Image'+'\'';
            
//             List<PMP_Partner_Offering_Resource__c> existingOfferingresources = database.query(offResourceQuery);//querying all the fields of offering record
            
//             for(PMP_Partner_Offering_Resource__c resource : existingOfferingresources){
                
//                 //if(resource.PMP_Resource_Type_Nm__c=='Image' || resource.PMP_Resource_Type_Nm__c=='Thumbnail Image'){
//                 //to accomodate new additonal resource changes as additional resource records will also have files
//                 if(string.isNotBlank(resource.PMP_Partner_Offering_Image__c)){
//                     contentDocs.add(resource.PMP_Partner_Offering_Image__c);//List containing docIds of the image and thumbnail of original resources
//                     resourceIdByContentId.put((Id)resource.PMP_Partner_Offering_Image__c, resource.Id);//Map<Id, Id>, containing <docId, resourceId>
//                     contentIdByResourceId.put(resource.Id, (Id)resource.PMP_Partner_Offering_Image__c);//Map<Id, Id>, containing <resourceId, docId>
//                 }
//             }
            
//             List<ContentVersion>  contentVersions = [SELECT Id, ContentDocumentId,Title, IsLatest, PathOnClient,FirstPublishLocationId, Description, RatingCount, VersionData, FileExtension 
//                                                      FROM ContentVersion where ContentDocumentId IN: contentDocs AND IsLatest=true];
            
//             if(!contentVersions.isEmpty()){
//                 for(ContentVersion version : contentVersions){//iterating over original contentversion to create cloned version with same version data and pathOnClient 
//                     ContentVersion cv = new ContentVersion();
//                     cv.Title = version.Title;
//                     cv.Description = version.Title + '_' + String.valueOf(resourceIdByContentId.get(version.ContentDocumentId));
//                     cv.PathOnClient = version.PathOnClient;
//                     cv.VersionData = version.VersionData;
                    
//                     clonedContentVersions.add(cv);
//                 }
//             }
//             contentVersions.clear();//clearing the list to reduce the heap size
            
//             if(!clonedContentVersions.isEmpty()){
                
//                 insert clonedContentVersions;//inserting cloned contentVersions
                
//                 for(ContentVersion version : clonedContentVersions){
//                     clonedContentVersionIds.add(version.Id);//List containing all the newly created version Ids
//                 }
                
//                 clonedContentVersions.clear();//clearing the list to reduce the heap size
                
//                 List<ContentVersion>  newContentVersions = [SELECT Id, Title, ContentDocumentId,VersionData,Description FROM ContentVersion where Id IN: clonedContentVersionIds AND IsLatest=true];//get all the cloned contentVersion records
                
//                 if(!newContentVersions.isEmpty()){
//                     for(ContentVersion version : newContentVersions){//iterating over the newly created contentVersions
//                         clonedContentIdsByOriginalContentIds.put(String.valueOf(contentIdByResourceId.get(version.Description.substringAfterLast('_'))), version.ContentDocumentId);//Map<Id,Id>, containing<originalDocId, clonedDocId>
//                     }
//                 }
                
//                 newContentVersions.clear(); //clearing the list to reduce the heap size
               
//             }
            
//             for(PMP_Partner_Offering_Resource__c resource : existingOfferingresources){
                
//                 PMP_Partner_Offering_Resource__c clonedResource = new PMP_Partner_Offering_Resource__c();
//                 clonedResource = resource.clone(false, false, true, true);//cloning the existing OfferingResource record
//                 clonedResource.PMP_Offering_Id__c = clonedOfferingId;//mapping the cloned resource to cloned offering
//                 clonedResource.PMP_Partner_Offering_Image__c = clonedContentIdsByOriginalContentIds.get(resource.PMP_Partner_Offering_Image__c);//populating contentDocument Id of the cloned image
//                 clonedResource.CreatedById = UserInfo.getUserId();
//                 clonedOfferingResources.add(clonedResource);
//                 if(clonedResource.PMP_Resource_Type_Nm__c=='Image'){//if the resource type is image, create contentDocument link for that image
//                     ContentDocumentLink cdl = PMP_Utility.getContentDocumentLinkInstance(clonedContentIdsByOriginalContentIds.get(resource.PMP_Partner_Offering_Image__c), clonedOfferingId);//get contentDocumentLink from utility class
//                     clonedDocumentLinks.add(cdl);
//                 }
//             }
//             insert clonedDocumentLinks;
//             }
//         }
//         catch(exception e){
//             PMP_Utility.logError(e,'PMP_CloneOffering');
//         }
//         return clonedOfferingResources;//returning the cloned resources 
//     }
    
// /*
// @Autor - Abhishek
// @Params - PMP_Partner_Offering__c, PMP_Partner_Offering__c , Language string
// @Description - If there is translation present for an offering and user requests for a clone,
//                the offering Name, description and tagline will be replaced from the translation table based on language string.
// @return - Cloned offering */ 
 
              
    
//  public static PMP_Partner_Offering__c getOfferingTranslation(PMP_Partner_Offering__c clonedOffering, PMP_Partner_Offering__c parentOffering, string language ){
                 
//             Map<string,string> languageFieldMap = New Map<string,string>();
//             Map<string,string> languageCodeToValueMap = New Map<string,string>();
//             List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeMtdList = New List<PMP_Locale_To_FieldAPINm_Mapping__mdt>();
//             //get the translation records for the offering
//             List<PMP_Partner_Offering_Translation__c> translatedValues = PMP_Utility.getOfferingTranslationRecords(parentOffering.id);
//            // get the metadata records for the offering translation object from PMP_Language_to_Field_API_Mapping__mdt metadata
//             localeMtdList = PMP_Utility.getLocaleToFieldMdtRecordsByObject(language,'Offering_Translation');
//             Map<string, PMP_Partner_Offering_Translation__c> fieldAndValueMap = New Map<string,PMP_Partner_Offering_Translation__c>();
//             //create a map of locale name and the metadata record and map of locale name and actual name.
//             for(PMP_Locale_To_FieldAPINm_Mapping__mdt mapping : localeMtdList ){
//                  languageFieldMap.put(mapping.PMP_Locale_Nm__c,mapping.PMP_Field_APINm__c ); 
//                  languageCodeToValueMap.put(mapping.PMP_Locale_Nm__c, mapping.PMP_Language_Nm__c);
//              }
//              //iterate through the offering translation records and prepare a map of OFFERING field name & translation record.
             
//             if(translatedValues.size()>0){
//                 for(PMP_Partner_Offering_Translation__c iterValue : translatedValues){
//                     // system.debug('trans--.' +iterValue );
//                     fieldAndValueMap.put(iterValue.PMP_Field_Nm__c, iterValue );
//                 }
//             }
//             //if translation record exists, replace offering name, description, and tagline field values with the values from the translation table.
//             clonedOffering.PMP_Partner_Offering_Nm__c= fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c')?
//                                                             string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(language))) : null;     
//             clonedOffering.PMP_Partner_Offering_Dsc__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Dsc__c')?
//                                                 string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Dsc__c').get(languageFieldMap.get(language))) : null;
//             clonedOffering.PMP_Partner_Offering_Tag_Line_Txt__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c')?
//                                                 string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(language))) : null;        
             
//             clonedOffering.PMP_Offering_Language_Nm__c =  languageCodeToValueMap.get(language);
//             clonedOffering.PMP_Translated_Languages__c =  languageCodeToValueMap.get(language);
        
//         return clonedOffering;
//     }


//      /**
//     * Method added by raj to create offeringResource records for cloned offering
//     * @description-Method to create cloned offeringResource
//     * @param-offeringId Id of the offering which is being cloned
//     * @param-clonedOfferingId Id of the cloned offering
//     * @return-List<PMP_Partner_Offering_Resource__c>
//     * Method Parameters-Id,Id 
//     **/    
//     public  static List<PMP_Partner_Offering_Resource__c> cloneOfferingResourcesDocumentLink(Id offeringId, Id clonedOfferingId){
        
//         List<PMP_Partner_Offering_Resource__c> clonedOfferingResources = new List<PMP_Partner_Offering_Resource__c>();//list to store newly created offeringResources
//         //List<ContentVersion> clonedContentVersions = new List<ContentVersion>();//List to store newly created contentVersions
//         List<ContentDocumentLink> clonedDocumentLinks = new List<ContentDocumentLink>();//List to store contentDocumentLinks 
//         Set<Id> contentDocs = new Set<Id>();//List to store contentDocuments of the existing offering images 
//         //Set<Id> clonedContentVersionIds = new Set<Id>();//list to store newly created contentversion 
//         Map<Id,Id> resourceIdByContentId = new Map<Id,Id>();//map to store existing resource Ids by contentDocument Ids
//         Map<Id, Id> contentIdByResourceId = new Map<Id, Id>();//map to store existing contentDocument Ids by resource Ids
//         Map<Id, Id> clonedContentIdsByOriginalContentIds = new Map<Id, Id>();// map to store newly created contentDocument Ids by existing contentDocument Ids.
        
//         try{
//             if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
//             DescribeSObjectResult offeringResourceFields = PMP_Partner_Offering_Resource__c.getSObjectType().getDescribe();
//             string tempoffResourceQuery = PMP_Utility.getObjectFields(offeringResourceFields);
//             string offResourceQuery= tempoffResourceQuery+    ' WHERE ' +         ' PMP_Offering_Id__c =: offeringId and PMP_External_Source_Id__c = null and PMP_Resource_Type_Nm__c!=\''+'Thumbnail Image'+'\'';
            
//             List<PMP_Partner_Offering_Resource__c> existingOfferingresources = database.query(offResourceQuery);//querying all the fields of offering record
            
//             for(PMP_Partner_Offering_Resource__c resource : existingOfferingresources){
                
//                 if(string.isNotBlank(resource.PMP_Partner_Offering_Image__c)){
//                     contentDocs.add(resource.PMP_Partner_Offering_Image__c);//List containing docIds of the image and thumbnail of original resources
//                     resourceIdByContentId.put((Id)resource.PMP_Partner_Offering_Image__c, resource.Id);//Map<Id, Id>, containing <docId, resourceId>
//                     contentIdByResourceId.put(resource.Id, (Id)resource.PMP_Partner_Offering_Image__c);//Map<Id, Id>, containing <resourceId, docId>
//                 }
//             }
            
//             List<ContentVersion>  contentVersions = [SELECT Id, ContentDocumentId,Title  FROM ContentVersion where ContentDocumentId IN: contentDocs AND IsLatest=true];
            
//             if(!contentVersions.isEmpty()){
//                 for(ContentVersion version : contentVersions){//iterating over original contentversion to create cloned version with same version data and pathOnClient 
//                    // ContentVersion cv = new ContentVersion();
                    
//                     String description = String.valueOf(resourceIdByContentId.get(version.ContentDocumentId));
                  
//                     clonedContentIdsByOriginalContentIds.put(contentIdByResourceId.get(description), version.ContentDocumentId);
                    
//                 }
//             }
//             contentVersions.clear();//clearing the list to reduce the heap size
            
           
            
//             for(PMP_Partner_Offering_Resource__c resource : existingOfferingresources){
                
//                 PMP_Partner_Offering_Resource__c clonedResource = new PMP_Partner_Offering_Resource__c();
//                 clonedResource = resource.clone(false, false, true, true);//cloning the existing OfferingResource record
//                 clonedResource.PMP_Offering_Id__c = clonedOfferingId;//mapping the cloned resource to cloned offering
//                 clonedResource.PMP_Partner_Offering_Image__c = clonedContentIdsByOriginalContentIds.get(resource.PMP_Partner_Offering_Image__c);//populating contentDocument Id of the cloned image
//                 clonedResource.CreatedById = UserInfo.getUserId();
//                 clonedOfferingResources.add(clonedResource);
//                 if( clonedContentIdsByOriginalContentIds.get(resource.PMP_Partner_Offering_Image__c) != null && (clonedResource.PMP_Resource_Type_Nm__c!=null || clonedResource.PMP_Resource_Type_Nm__c!='')){//if the resource type is image, create contentDocument link for that image
//                     ContentDocumentLink cdl = PMP_Utility.getContentDocumentLinkInstance(clonedContentIdsByOriginalContentIds.get(resource.PMP_Partner_Offering_Image__c), clonedOfferingId);//get contentDocumentLink from utility class
//                     clonedDocumentLinks.add(cdl);
//                 }
//             }
//             insert clonedDocumentLinks;
//             }
//         }
//         catch(exception e){
//             PMP_Utility.logError(e,'PMP_CloneOffering');
//         }
//         return clonedOfferingResources;//returning the cloned resources 
//     }
}