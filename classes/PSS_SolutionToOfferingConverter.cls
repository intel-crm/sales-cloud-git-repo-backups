/*******************************************************************************************************************************************************************************************************
* Class Name  : PSS_SolutionToOfferingConverter
* Description : This Class is the Core Engine which converts the Solution to Draft Offering
                Input to this Class is List<ArdiraSurvey__Survey_Result__c>
                List<ArdiraSurvey__Survey_Result__c> should contain the fields(Id,PSS_Programs_Applicable_Nm__c,PSS_Company_Id__c) mandatorily as Input
* Version     : 1.0 
* Created Date: 26-May-2021
* Modification Log :
* Created By  : ONYX Team (Infosys)
********************************************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public without sharing class PSS_SolutionToOfferingConverter{
    
    /**
    * Method called from Submit button in PSS_AdminReviewPage and also from Retrigger Button in Solution Detail page.Some Batch class related to migration may also call this Method for Conversion to offering
    * @description - Converts the List of Solution records passed into Offering Object Records and creates Draft Offerings
    * @param propResponses List of Solution Records with fields(Id,PSS_Programs_Applicable_Nm__c,PSS_Company_Id__c) as mandatory input 
    */     
        // public static void convertProposal(List<ArdiraSurvey__Survey_Result__c> propResponses){
        //     PSS_StaticConstants.intelProductsTriggerLogicStop = False;
        //     //Setting the Savepoint to rollback in case of any exception during Conversion
        //     Savepoint spBeforeConversion = Database.setSavepoint();
            
        // try{
            
        //     /*Note: This logic is based on confirmation
        //     that At any point there will be only one active survey, and response will be for that survey */
            
        //     List<string> propResponsesId = New List<string>();
        //     String sResourceObjectName = PSS_StaticConstants.SOLUTIONS_CONVERSION_RESOURCEOBJECT_NAME;
        //     Map<string,List<ArdiraSurvey__Question_Result__c>> responseDetailMap = New Map<string,List<ArdiraSurvey__Question_Result__c>>();
            
        //     Map<string,PMP_Partner_Offering__c> responseOfferingMap = New Map<string,PMP_Partner_Offering__c>(); 
        //     List<PMP_Partner_Offering__c> offeringsList = New List<PMP_Partner_Offering__c>();
        //     for(ArdiraSurvey__Survey_Result__c response : propResponses ){
        //         propResponsesId.add(response.id);
        //     }
        //     //FETCH LIST OF QUESTION RESULT RECORDS AND CORRESPONDING QUESTION RESULT CHOICES RECORDS WHICH HAS BEEN ANSWERED DURING SURVEY
        //     for(ArdiraSurvey__Question_Result__c resultQuestion : [Select id, ArdiraSurvey__Answer_Text__c, ArdiraSurvey__Answer_Rich_Text__c,ArdiraSurvey__Answer_Number__c,
        //                                                            ArdiraSurvey__Question__r.PSS_Offering_Nm__c,
        //                                                            ArdiraSurvey__Question__r.PSS_Conversion_Taxonomy_Nm__c,  
        //                                                            ArdiraSurvey__Question__r.PSS_Related_Parent_Taxonomy_Txt__c, 
        //                                                            ArdiraSurvey__Question__r.PSS_Related_Offering_Options_Txt__c,
        //                                                            ArdiraSurvey__Question__r.ArdiraSurvey__Type__c,ArdiraSurvey__Question_Text__c,
        //                                                            ArdiraSurvey__Survey_Result__r.Id,
        //                                                         (Select id ,ArdiraSurvey__Answer_Choice__r.PSS_Related_Offering_Options_Txt__c,ArdiraSurvey__Answer_Choice__r.PSS_Related_Parent_Taxonomy_Txt__c
        //                                                          from ArdiraSurvey__Question_Result_Choices__r) from ArdiraSurvey__Question_Result__c
        //                                                         Where ArdiraSurvey__Survey_Result__r.Id IN : propResponsesId AND ArdiraSurvey__Answered__c = true]){
                                                              
                
                
        //         //map of responseid and all the questions related to it. 
        //         if(responseDetailMap.containsKey(resultQuestion.ArdiraSurvey__Survey_Result__r.Id)){
        //             List<ArdiraSurvey__Question_Result__c> tempList = responseDetailMap.get(resultQuestion.ArdiraSurvey__Survey_Result__r.Id);
        //             tempList.add(resultQuestion);
        //             responseDetailMap.put(resultQuestion.ArdiraSurvey__Survey_Result__r.Id, tempList);
        //         }
        //         else{
        //             List<ArdiraSurvey__Question_Result__c> tempList = New List<ArdiraSurvey__Question_Result__c>();
        //             tempList.add(resultQuestion);
        //             responseDetailMap.put(resultQuestion.ArdiraSurvey__Survey_Result__r.Id, tempList);
        //         }
                                                                    
        //     }
            
            
        //     //CALL HELPER CLASS METHOD TO GET MAPS OF PIM ID TO TAXONOMY OBJECT ID FOR FURTHER PROCESSING
        //     PSS_SolutionToOfferingConversionHelper.PIMIdToTaxonomyIdMapWrapper sPIMIdToTaxonomyIdMapWrapper = PSS_SolutionToOfferingConversionHelper.getPIMIdToTaxonomyIdMap(responseDetailMap);
        //     Map<string,string> sPIMIdToTaxonomyIdCatMap = sPIMIdToTaxonomyIdMapWrapper.sPIMIdToTaxonomyIdCatMap;
        //     Map<string,string> sPIMIdToTaxonomyIdSpecMap = sPIMIdToTaxonomyIdMapWrapper.sPIMIdToTaxonomyIdSpecMap;
        //     Map<string,string> sPIMIdToTaxonomyIdSpecValueMap = sPIMIdToTaxonomyIdMapWrapper.sPIMIdToTaxonomyIdSpecValueMap;
        //     Map<string,string> sSpecValueIdToSpecValueMap = sPIMIdToTaxonomyIdMapWrapper.sSpecValueIdToSpecValueMap;
        //     Set<string> sDocumentQuestionResultIdSet = sPIMIdToTaxonomyIdMapWrapper.sDocumentQuestionResultIdSet;
        //     Map<string,string> sSpecValueIdToImmediateParentSpecPIM = sPIMIdToTaxonomyIdMapWrapper.sSpecValueIdToImmediateParentSpecPIM;
        //     Map<String,String> sImmediateParentSpecPIMToSpecIdMap = sPIMIdToTaxonomyIdMapWrapper.sImmediateParentSpecPIMToSpecIdMap;
        //     Map<String,List<String>> sSpecIdToParentSpecsIdMap = sPIMIdToTaxonomyIdMapWrapper.sSpecIdToParentSpecsIdMap;
            
            
        //     //Offering resource list for inserting image records
        //     List<PMP_Partner_Offering_Resource__c> resourceList = New List<PMP_Partner_Offering_Resource__c>();
            
        //     //Acceptable and uploadable image formats in offering image section
    
        //     List<PSS_Conversion_File_Formats__c> lstFileFormats = new List<PSS_Conversion_File_Formats__c>();
        //     //Get the data from PSS_Conversion_File_Formats__c custom settings to stamp the Resource Type for corresponding File Formats allowed during Conversion
        //     lstFileFormats = PSS_Conversion_File_Formats__c.getall().values();
        //     Map<string,string> sFileFormatToResourceTypeMap = New Map<string,string>();
        //     for(PSS_Conversion_File_Formats__c sFileFormat : lstFileFormats) 
        //     {
        //         if(!sFileFormat.PSS_Inactive_Ind__c)
        //         {                               
        //             sFileFormatToResourceTypeMap.put(sFileFormat.PSS_File_Format_Nm__c , sFileFormat.PSS_Resource_Type_Txt__c);
        //         }   
        //     }
            
        //     //ContentDocumentLink list which links the offering with contentDocument
        //     List<ContentDocumentLink> contentDocCloneList = New List<ContentDocumentLink>(); 
        //     Map<String,List<ContentDocumentLink>> docMap = new Map<String,List<ContentDocumentLink>>();
        //     Map<String,String> conVersionIdMap = new Map<String,String>(); 
        //     Map<String,String> fileTypeMap = new Map<String,String>();      
            
        //     //CREATE CONTENTDOCUMENT ONLY WHEN THE ADMIN PAGE MAPPED DOCUMENT UPLOAD QUESTION IS ANSWERED IN SURVEY
        //     if(sDocumentQuestionResultIdSet.size() > 0 && sDocumentQuestionResultIdSet != null)
        //     {
        //         PSS_SolutionToOfferingConversionHelper.ContentVersionsForOfferingWrapper sContentVersionWrapper = PSS_SolutionToOfferingConversionHelper.createContentVersionsForOffering(propResponsesId,sDocumentQuestionResultIdSet);
        //         docMap = sContentVersionWrapper.docMap;
        //         conVersionIdMap = sContentVersionWrapper.conVersionIdMap;
        //         fileTypeMap = sContentVersionWrapper.fileTypeMap;
        //     }
            
    
        //     // Added by Shahrukh to map programs applicable to categories
            
        //     set<string> categoryPIMSet = PSS_SolutionToOfferingConversionHelper.getProgramsApplicableCategoryPIMSet(propResponses);
        //     List<Id> adminGroupUserIds = PMP_Utility.intelAdminGrpMembers();
            
        //     //creating offerings for each of the response   
        //     // one offering for each response.
        //     for(ArdiraSurvey__Survey_Result__c response : propResponses){
        //         //logic to identify partner solution
        //         Boolean isPartnerSolution = false; 
        //         if (response.PSS_Programs_Applicable_Nm__c != null) {
        //             List<String> programs = response.PSS_Programs_Applicable_Nm__c.split(';');
        //             if (programs.size() == 1 && programs[0] == PSS_StaticConstants.PARTNER_SOLUTION) {
        //                 isPartnerSolution = true;
        //             }
        //         }
        //          //logic to identify partner solution

        //         PMP_Partner_Offering__c offering = New PMP_Partner_Offering__c();
        //         offering.PMP_Active_Step_Txt__c = '0';
        //         offering.PMP_Current_Step_Txt__c = '0';
               
        //         offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Draft';
        //         offering.PMP_Offering_Status_Update_Dt__c = system.now();
        //         offering.PMP_Partner_Offering_Start_Dt__c = system.today();
        //         offering.PMP_Partner_Offering_End_Dt__c = System.today().addYears(2);
        //         offering.PMP_Offering_Language_Nm__c = 'English'; 
        //         offering.PMP_Partner_Offering_Visibility_Nm__c = 'Public Content';
        //         offering.PMP_Translated_Languages__c = 'English';
        //         offering.PMP_Category_nm__c = 'Solution'; //as it is converted from solution
        //         offering.PMP_Is_Converted_Ind__c = true; //Indicator to identify the offerings converted from solutions[US917587]  
        //         offering.PMP_Company_Id__c = response.PSS_Company_Id__c!= null ? response.PSS_Company_Id__c : null; //to update the company id
        //         offering.PMP_Sub_Category_nm__c = '';
        //         //offering.PMP_Partner_Offering_Nm__c = response.PSS_Proposal_Name_Txt__c;
        //         //offering.OwnerId = response.PSS_Solution_Submitter_UserId_Id__c; //to assign solution submitter as the offering owner 
        //         if(adminGroupUserIds.contains(response.PSS_Solution_Submitter_UserId_Id__c)) {
        //                 offering.OwnerId = response.ArdiraSurvey__Assigned_To_User__c; //to assign solution submitter as the offering owner 
        //             }
        //             else {
        //                 offering.OwnerId = response.PSS_Solution_Submitter_UserId_Id__c; //to assign solution submitter as the offering owner 
        //             }
        //         offering.PMP_Partner_Offering_LifecycleStatus_Txt__c= offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c;

        //         //for partner solution we should publish the offering as part of conversion
        //         if (isPartnerSolution) {
        //             offering.PMP_Active_Step_Txt__c = '4';
        //             offering.PMP_Current_Step_Txt__c = '4';
        //             offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
        //             offering.PMP_Intel_Admin_Id__c = response.PSS_Intel_Admin_Id__c;
        //             offering.PMP_Is_Not_Available_On_MP_Ind__c = false;
        //             if (adminGroupUserIds.contains(response.PSS_Solution_Submitter_UserId_Id__c)) {
        //                 offering.PMP_Offering_Submitter_UserId__c =  response.ArdiraSurvey__Assigned_To_User__c;
        //                 offering.OwnerId = response.ArdiraSurvey__Assigned_To_User__c; //to assign solution submitter as the offering owner 
        //             }
        //             else {
        //                 offering.PMP_Offering_Submitter_UserId__c =  response.PSS_Solution_Submitter_UserId_Id__c;
        //                 offering.OwnerId = response.PSS_Solution_Submitter_UserId_Id__c; //to assign solution submitter as the offering owner 
        //             }
        //             //offering.PMP_Offering_Submitter_UserId__c =  response.ArdiraSurvey__Assigned_To_User__c;
        //             offering.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
        //         }
                
        //         offeringsList.add(offering);
        //     }
            
        //     if(offeringsList.size()>0 /*&& PMP_Partner_Offering__c.SObjectType.getDescribe().isCreateable()*/) {
        //         insert offeringsList;
        //     }
        //     Set<string> offIds = new Set<string>();
        //     //101 SOQL defect fix on conversion to offering.
        //     if(!offeringsList.isEmpty()){
        //         for(PMP_Partner_Offering__c off : offeringsList){
        //             offIds.add(off.id);
        //         }
        //     }
        //     /* Creation of Published Copy of the Offering*/
        //     List<PMP_Partner_Offering__c> publishedOffLst = new List<PMP_Partner_Offering__c>();
        //     if(!offIds.isEmpty()){
        //      publishedOffLst = createPublishedOffering(offIds);
        //     }
            
        //     //default category to be inserted along with offering.
        //     List<PMP_Partner_Offering_Category__c> defOffCat = New List<PMP_Partner_Offering_Category__c>();
        //     List<PMP_Category__c> specificCategory = new List<PMP_Category__c>();
        //     Map<Id,string> subCategoryMap = new Map<Id,string>();
        //     Map<Id,string> businessSegmentMap = new Map<Id,string>();
        //     List<PMP_Partner_Offering__c> offeringSubCategoryUpdateList = New List<PMP_Partner_Offering__c>();
            
        //     if((!categoryPIMSet.isEmpty() ) && Schema.sObjectType.PMP_Category__c.isAccessible()){
        //        specificCategory = [Select id,Name,PMP_Business_Segment_Nm__c,PMP_Partner_Product_Category_Cd__c,PMP_Ancestor_Category_Cd__c 
        //                             from PMP_Category__c  where PMP_Partner_Product_Category_Cd__c IN: categoryPIMSet
        //                             And PMP_Active_Ind__c = True];
        //     }                                     
        //     List<PMP_Category__c> defaultCategory = [Select id,Name,PMP_Partner_Product_Category_Cd__c,PMP_Ancestor_Category_Cd__c 
        //                                         from PMP_Category__c  where (PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE'
        //                                          OR PMP_Partner_Product_Category_Cd__c = 'IPA_TYPE_Sol') And PMP_Active_Ind__c = True];
            
            
            
        //     // one offering for each response.
        //     List<PMP_Partner_Offering__c> updateOfferingList = New List<PMP_Partner_Offering__c>();
        //     integer counter = 0;
        //     for(ArdiraSurvey__Survey_Result__c response : propResponses){
        //         //update statement not required as this method will be called in before update context
        //         //US1022213-changing status to "Converted to MP offering" if solution is converted into draft offering
        //         response.PSS_Partner_Solution_Lifecycle_Status_Nm__c = PSS_StaticConstants.SOLUTION_CONVERTED_STATUS;
        //         //added below line to populate Offering name by Krishna Ch.
        //         //Once Solution is Converted, associating the published offering to the respective solution
        //         response.PSS_Partner_Offering__c = publishedOffLst[counter].id; 
        //         response.PSS_Offering_Id_Txt__c = publishedOffLst[counter].id; 
                                        
        //         updateOfferingList.add(offeringsList[counter]);
        //         responseOfferingMap.put(response.id,offeringsList[counter]);
                
        //         //creating 2 default categories for each offering i,e Category and Solution
        //         PMP_Partner_Offering_Category__c cat1 = New PMP_Partner_Offering_Category__c();
        //         cat1.Name = defaultCategory[0].Name;            
        //         cat1.PMP_Offering_Id__c = offeringsList[counter].id;
        //         cat1.PMP_Offering_Category_External_Key__c = defaultCategory[0].PMP_Partner_Product_Category_Cd__c; 
        //         cat1.PMP_Category_Id__c = defaultCategory[0].id;
        //         cat1.PMP_Ancestor_Category_Cd__c =  defaultCategory[0].PMP_Ancestor_Category_Cd__c ;
        //         defOffCat.add(cat1) ;
                
        //         PMP_Partner_Offering_Category__c cat2 = New PMP_Partner_Offering_Category__c();
        //         cat2.Name=defaultCategory[1].Name;    
        //         cat2.PMP_Offering_Id__c = offeringsList[counter].id;
        //         cat2.PMP_Offering_Category_External_Key__c= defaultCategory[1].PMP_Partner_Product_Category_Cd__c;
        //         cat2.PMP_Ancestor_Category_Cd__c = defaultCategory[1].PMP_Ancestor_Category_Cd__c ;
        //         cat2.PMP_Category_Id__c =  defaultCategory[1].id; 
        //         defOffCat.add(cat2);
                
                
        //         if(!specificCategory.isEmpty()){
        //             for(PMP_Category__c cat: specificCategory){
        //                 PMP_Partner_Offering_Category__c offCat = New PMP_Partner_Offering_Category__c();
        //                 offCat.Name=cat.Name;    
        //                 offCat.PMP_Offering_Id__c = offeringsList[counter].id;
        //                 offCat.PMP_Offering_Category_External_Key__c= cat.PMP_Partner_Product_Category_Cd__c;
        //                 offCat.PMP_Ancestor_Category_Cd__c = cat.PMP_Ancestor_Category_Cd__c ;
        //                 offCat.PMP_Category_Id__c =  cat.id; 
        //                 defOffCat.add(offCat);
        //                 if(businessSegmentMap.containskey(offeringsList[counter].id)){
        //                     businessSegmentMap.put(offeringsList[counter].id,businessSegmentMap.get(offeringsList[counter].id)+';'+cat.PMP_Business_Segment_Nm__c);
        //                 }else{
        //                     businessSegmentMap.put(offeringsList[counter].id,cat.PMP_Business_Segment_Nm__c);
        //                 } 
                        
        //                 if(subCategoryMap.containsKey(offeringsList[counter].id)){
        //                     subCategoryMap.put(offeringsList[counter].id,subCategoryMap.get(offeringsList[counter].id)+','+cat.Name);
        //                 }else{
        //                     subCategoryMap.put(offeringsList[counter].id,cat.Name);
        //                 }
                        
        //             }
        //         }
                
        //         //ADDED BY SOORIYA
        //         if(docMap.containsKey(response.Id)){
        //             Integer imageOrder=0;
    
        //             for(ContentDocumentLink cd: docMap.get(response.Id)){
        //                 //updating the contentDocumentLink linkentityId with the offering Id
        //                 //based on the LinkedEntityId only the image will be preuploaded in the resource tab
        //                 ContentDocumentLink newclnk = cd.clone();
        //                 newclnk.LinkedEntityId = offeringsList[counter].id;
        //                 if(conVersionIdMap.containsKey(cd.ContentDocumentId)){
        //                    newclnk.ContentDocumentId = conVersionIdMap.get(cd.ContentDocumentId);                        
        //                 }
        //                 newclnk.ShareType = 'I';
        //                 newclnk.Visibility = 'AllUsers'; 
        //                 contentDocCloneList.add(newclnk);
                                
        //                 //creating offering resource record for Image
        //                 PMP_Partner_Offering_Resource__c offeringResource = New PMP_Partner_Offering_Resource__c();
        //                 offeringResource.PMP_Offering_Id__c = offeringsList[counter].id;
        //                 offeringResource.PMP_Resource_Sequence_Nbr__c= imageOrder;
        //                 offeringResource.PMP_Partner_Offering_Image__c=newclnk.ContentDocumentId;
        //                 String sFileTypeFormat = fileTypeMap.get(cd.ContentDocumentId);
        //                 //if sFileTypeFormat is 'LOGO_IMAGE', it means it should be mapped to offering logo,else will be added to additional resource.
        //                 offeringResource.PMP_Resource_Type_Nm__c=sFileTypeFormat == 'LOGO_IMAGE'? System.Label.PMP_Image : sFileFormatToResourceTypeMap.get(sFileTypeFormat);
        //                 String sFileName = cd.ContentDocument.Title;
        //                 Integer sSubStringEnd = sFileName.length() > 80 ? 80 : sFileName.length();
        //                 String sTruncatedFileNameWithExtension = sFileName.substring(0, sSubStringEnd);
        //                 String sFileExtension = '.' + cd.ContentDocument.FileExtension;
        //                 String sFileNameWithoutExtension = sTruncatedFileNameWithExtension.removeEndIgnoreCase(sFileExtension);
        //                 offeringResource.Name = sFileNameWithoutExtension;
                        
        //                 resourceList.add(offeringResource);
        //                 imageOrder++;
                        
        //             }
        //         }
        //         //ADDED BY SOORIYA-END 
        //         counter++;
        //     }
            
        //     if( Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isUpdateable())
        //     {
        //         update propResponses;
        //     }
    
            
        //     if(defOffCat.size()>0 && Schema.sObjectType.PMP_Partner_Offering_Category__c.isCreateable()){
                
        //         insert defOffCat;
        //     }
            
        //      //ADDED BY SOORIYA      
        //     if(contentDocCloneList.size()>0){
        //         insert contentDocCloneList;
        //     }
            
        //     // INSERT PARTNER OFFERING RESOURCES RECORD FOR EACH OFFERING FOR DOCUMENTS ALONE. ContentAsset GENERATED AT THE TRIGGER OF PARTNER OFFERING RESOURCE OBJECT       
        //     if(resourceList.size()>0 && Schema.sObjectType.PMP_Partner_Offering_Resource__c.isCreateable()){
        //         insert resourceList;
        //     }
            
        //     /* Code to populate all categories field */
        //     Map<String,String> offeringCategoryMap = new Map<String,String>();
        //     for(PMP_Partner_Offering_Category__c offCat: [select id,PMP_Category_Id__c,PMP_Ancestor_Category_Cd__c,PMP_Offering_Id__c,
        //                                       PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,PMP_Category_Id__r.Name 
        //                                       from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c IN:offIds 
        //                                       and PMP_Ancestor_Category_Cd__c Like '%NPP_01_TYPE%']){
        //         offeringCategoryMap.put(offCat.PMP_Offering_Id__c+'_'+string.valueOf(offCat.PMP_Ancestor_Category_Cd__c.countMatches('|')),
        //         offCat.PMP_Category_Id__r.Name+'|'+offCat.PMP_Category_Id__r.Id);    
        //     }
        //     for(PMP_Partner_Offering__c offObj : offeringsList){
        //         string allCategories = '';
        //         for(Integer i = 0;i<5;i++){
        //             if(offeringCategoryMap.containsKey(offObj.Id+'_'+string.valueOf(i))){
        //                 allCategories = allCategories==''? offeringCategoryMap.get(offObj.Id+'_'+string.valueOf(i)) : allCategories+';'+offeringCategoryMap.get(offObj.Id+'_'+string.valueOf(i)); 
        //             }
        //         }
        //         offObj.PMP_All_Categories_Txt__c = allCategories;
        //     }
        //     /* Code to populate all categories field */

        //     for(PMP_Partner_Offering__c offering: offeringsList){
        //         if(subCategoryMap.containsKey(offering.id) && businessSegmentMap.containsKey(offering.id)){
        //             offering.PMP_Sub_Category_nm__c = subCategoryMap.get(offering.id);
        //             List<string> businessSegmentList = businessSegmentMap.get(offering.id).split(';');
        //             string businessSegment;
        //             for(string str:businessSegmentList){
        //                 if(businessSegment == Null){   
        //                     businessSegment = str;
        //                 }
        //                 else if(!businessSegment.containsIgnoreCase(str)){
        //                    businessSegment = businessSegment+';'+str;
        //                 }
        //             }
        //             offering.PMP_Business_Segment_Nm__c = businessSegment;
        //             offeringSubCategoryUpdateList.add(offering);
        //         }    
        //     }
            
        //     if(offeringSubCategoryUpdateList.size()>0 && Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable()){
        //        update offeringSubCategoryUpdateList;
        //     }
            
        //     //ADDED BY SOORIYA-END 
        //     //Call Helper Class which contains Core Solution to Offering Conversion Logic and to insert offering related records
        //     PSS_SolutionToOfferingConversionLogic.solutionToOfferingConversionLogic(responseDetailMap, sResourceObjectName, sPIMIdToTaxonomyIdSpecValueMap, sPIMIdToTaxonomyIdSpecMap, sPIMIdToTaxonomyIdCatMap, responseOfferingMap, sSpecValueIdToSpecValueMap,sSpecValueIdToImmediateParentSpecPIM,sImmediateParentSpecPIMToSpecIdMap,sSpecIdToParentSpecsIdMap);
            
                        
        //     /*Creation of Related/Child Records for the Published Offering */
        //    if(!offIds.isEmpty()){
        //       createChildRecordsUnderPublishedCopy(offIds);            
        //     }
            

        //     //* create translation records for approved copy and published copy
        //    List<PMP_Partner_Offering__c> offeringsData = new List<PMP_Partner_Offering__c>();
        //     List<PMP_Partner_Offering_Translation__c> translationData = new List<PMP_Partner_Offering_Translation__c>();
        //     offeringsData = [SELECT Id,
        //                         PMP_Partner_Offering_Nm__c,
        //                         PMP_Partner_Offering_Tag_Line_Txt__c, 
        //                         PMP_Partner_Offering_Dsc__c,
        //                         PMP_Offering_Language_Nm__c FROM PMP_Partner_Offering__c 
        //                         WHERE (ID IN: offIds OR PMP_Working_Copy_Id__c IN :offIds)];
        //         for (PMP_Partner_Offering__c offering : offeringsData) {

        //             translationData.addAll(prepareLanguageTranslation(offering));
        //         }
                
        //         if(Schema.sObjectType.PMP_Partner_Offering_Translation__c.isCreateable()){
        //             insert translationData;
        //         }         
        //     //TWC729-5771 - Logic to create thumbnail when Partner Solution is converted into offering
        //     if(!offeringsList.isEmpty()){

        //         for(PMP_Partner_Offering__c off: offeringsList){
                    
        //             if(off.PMP_Partner_Offering_Lifecycle_Status_Nm__c=='Approved'){

        //                 if(System.isBatch()){
    
        //                     PMP_CreateOfferingTab5Service.generateThumbnailImagesSynchronously(off.Id);  //synchronous method if execution is a batch context  
    
        //                     //system.debug ('inside if--->');                
    
        //                 }else{
    
        //                     PMP_CreateOfferingTab5Service.generateThumbnailImages(off.Id); //future method if execution is not a batch context
    
        //                     //system.debug ('inside else--->');
    
        //                 }

        //         }
        //       }

        //     }
    
    
        // }//TRY End
        //     catch(Exception e){
        //         Database.rollback(spBeforeConversion);//Rollback to the Save point set before starting Conversion Process
        //         PMP_Utility.logError(e,'PSS_SolutionToOfferingConverter');
        //         /*Logic added to handle any exception like 101 SQQL captured to display to Admins*/ 
        //         if( Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isUpdateable())
        //         {
        //             List<ArdiraSurvey__Survey_Result__c> lstSR = new List<ArdiraSurvey__Survey_Result__c>();
        //             for(ArdiraSurvey__Survey_Result__c sr: propResponses){
        //                 sr.PSS_Conversion_Admin_Log_Details_Txt__c = sr.PSS_Conversion_Admin_Log_Details_Txt__c +'\n' + e.getMessage() + PSS_StaticConstants.LOG_MESSAGE_SEPERATOR + System.Now();
        //                 lstSR.add(sr);
        //             }
        //             if(!lstSR.isEmpty()){
        //                 update lstSR;
        //             }
                       
        //         }
        //         throw e;
        //     }//CATCH End
        // }
    
       
        // /**
        // * @description Method To clone Draft Offering and create new Published Offering
        // * @param Set<PMP_Partner_Offering__c>
        // * @return void
        // **/
        //     public static List<PMP_Partner_Offering__c> createPublishedOffering(Set<string> offIds){
        //     Set<Id> offeringId = new Set<Id>();
            
        //     DescribeSObjectResult offFields = PMP_Partner_Offering__c.getSObjectType().getDescribe();
        //     string tempoffQuery = PMP_Utility.getObjectFields(offFields);
        //     string offQuery = tempoffQuery +    ' WHERE ' +         ' Id =: offIds';
        //     list<PMP_Partner_Offering__c>  clonedofferinglist = Database.query(offQuery);
        //     List<PMP_Partner_Offering__c> finaClonedOffering = new List<PMP_Partner_Offering__c>();
        //     //List to populate ispublished flag on working copy , so that id will populate in emails
        //     Set<Id> workingOfferingIds = new Set<Id>();
        //     if(clonedofferinglist.size()>0){
                
        //         for(PMP_Partner_Offering__c cloneOffList : clonedofferinglist){
        //             PMP_Partner_Offering__c clonedOffering = new PMP_Partner_Offering__c(); //cloning offering with clone method
        
        //             clonedOffering = cloneOffList.clone(false,true,true,false);
                    
        //             clonedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        //             clonedoffering.PMP_Is_Not_Available_On_MP_Ind__c = true;                  
        //             clonedOffering.PMP_Partner_Offering_LifecycleStatus_Txt__c= clonedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c;
        //             clonedoffering.PMP_Working_Copy_Id__c = cloneOffList.id;
        //             clonedoffering.PMP_Is_Published_Ind__c = false;
                    
        //             finaClonedOffering.add(clonedoffering);

        //             if(cloneOffList.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Approved'){
        //                 workingOfferingIds.add(cloneOffList.Id);
        //             }
        //         }
        //         try{
        //             if(!finaClonedOffering.isEmpty()){
        //             insert finaClonedOffering; //Inserting Dummy Published Offering
        //             }
        //         }
        //         catch(Exception e){
        //         PMP_Utility.logError(e,'PSS_SolutionToOfferingConverter');
        //         throw e;
        //         }//CATCH End
        //         if(finaClonedOffering.size()>0){
                    
        //             List<PMP_Partner_Offering__c> updateOffering = new List<PMP_Partner_Offering__c>();
        
        //             for (PMP_Partner_Offering__c finalOffering : finaClonedOffering){
                       
        
        //                 //Update the PMP_Published_Copy_Id_Txt__c on both Working and Dummy Published Copy
        //                 PMP_Partner_Offering__c updateOffering1 = new PMP_Partner_Offering__c();
        //                 PMP_Partner_Offering__c updateOffering2 = new PMP_Partner_Offering__c();
                        
        //                 //For Dummy Published Copy
        //                 updateOffering1.id = finalOffering.id;
        //                 updateOffering1.PMP_Published_Copy_Id_Txt__c = finalOffering.id;
        //                 updateOffering.add(updateOffering1);
                        
        //                 //For Working Copy
        //                 updateOffering2.id = finalOffering.PMP_Working_Copy_Id__c;
        //                 updateOffering2.PMP_Published_Copy_Id_Txt__c = finalOffering.id;
        //                 updateOffering.add(updateOffering2);
        //             }
                  
        //                if(!updateOffering.isEmpty()){
        //                     update updateOffering; //update the PMP_Published_Copy_Id_Txt__c on both Working and Dummy Published Copy 
        //                 }
        //             }
        //     }
        //     return finaClonedOffering;
        // }

        // public static void createChildRecordsUnderPublishedCopy(Set<string> offIds){
        //     Set<Id> offeringId = new Set<Id>();
        //     //system.debug('Working offeringId' + offIds);
        
        //     DescribeSObjectResult offFields = PMP_Partner_Offering__c.getSObjectType().getDescribe();
        //     string tempoffQuery = PMP_Utility.getObjectFields(offFields);
        //     string offQuery = tempoffQuery +    ' WHERE ' +         ' Id =: offIds';
        //     list<PMP_Partner_Offering__c>  draftOfferingList = Database.query(offQuery);
        //     List<PMP_Partner_Offering__c> publishedOfferingList = new List<PMP_Partner_Offering__c>();
        //     List<PMP_Partner_Offering__c> tempOfferingList = new List<PMP_Partner_Offering__c>();
        //     if(draftOfferingList.size()>0){     
        //         for(PMP_Partner_Offering__c draftOffering : draftOfferingList){
        //             PMP_Partner_Offering__c publishedOffering = new PMP_Partner_Offering__c(); 
        //             publishedOffering.Id = draftOffering.PMP_Published_Copy_Id_Txt__c;
        //             Boolean isOfferingPartnerSolution = false;
        //             if(draftOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Approved' ){
        //                 isOfferingPartnerSolution = true;
        //                 //Added this condition to trigger Approved & Published Email with Offering Name
        //                 draftOffering.PMP_Is_Published_Ind__c = true;
        //                 tempOfferingList.add(draftOffering);
        //             }
        //             //Adding Partner Offering Name and Desc for Non Partner solution.
        //             publishedOffering.PMP_Partner_Offering_Nm__c = draftOffering.PMP_Partner_Offering_Nm__c;
        //             publishedOffering.PMP_Partner_Offering_Dsc__c = draftOffering.PMP_Partner_Offering_Dsc__c;
                    
        //             //Override few fields on published copy if it is of partner type solution
        //             if(isOfferingPartnerSolution){
        //                 publishedOffering.PMP_Is_Not_Available_On_MP_Ind__c = false;
        //                 publishedOffering.PMP_Partner_Offering_Nm__c = draftOffering.PMP_Partner_Offering_Nm__c;
        //                 publishedOffering.PMP_Partner_Offering_Dsc__c = draftOffering.PMP_Partner_Offering_Dsc__c;
        //                 publishedOffering.PMP_Sub_Category_nm__c = draftOffering.PMP_Sub_Category_nm__c;
        //                 publishedOffering.PMP_Business_Segment_Nm__c = draftOffering.PMP_Business_Segment_Nm__c;
        //                 publishedOffering.PMP_All_Categories_Txt__c = draftOffering.PMP_All_Categories_Txt__c;
        //                 publishedOffering.PMP_Working_Copy_Id__c = draftOffering.Id;
        //             }
        //             publishedOfferingList.add(publishedOffering);
        //             //Override few fields on published copy if it is of partner type solution
                    
                    
        //         }
        //         if(publishedOfferingList.size()>0){
        //             update publishedOfferingList; //Inserting Dummy Published Offering
        //         }
        //         //system.debug('publishedOfferingList ' +publishedOfferingList);
        //         if(publishedOfferingList.size()>0){
                    
        //             List<PMP_Partner_Offering_Category__c> clonedOffCats = new List<PMP_Partner_Offering_Category__c>();
        //             List<PMP_Partner_Offering_Specification__c> clonedOffSpecs = new List<PMP_Partner_Offering_Specification__c>();
        //             List<PMP_Partner_Offering_Resource__c> clonedOffResources = new List<PMP_Partner_Offering_Resource__c>();
        //             List<PMP_Partner_Offering__c> updateOffering = new List<PMP_Partner_Offering__c>();
        
        //             for (PMP_Partner_Offering__c finalOffering : publishedOfferingList){
        //                 List<PMP_Partner_Offering_Category__c> clonedOffCats1 = cloneOfferingCategories(finalOffering.PMP_Working_Copy_Id__c,finalOffering.Id);
        //                 List<PMP_Partner_Offering_Specification__c> clonedOffSpecs1 = cloneOfferingSpecifications(finalOffering.PMP_Working_Copy_Id__c,finalOffering.Id);
        //                 List<PMP_Partner_Offering_Resource__c> clonedOffResources1 = cloneOfferingResources(finalOffering.PMP_Working_Copy_Id__c,finalOffering.Id);
        
        //                 clonedOffCats.addAll(clonedOffCats1);
        //                 clonedOffSpecs.addAll(clonedOffSpecs1);
        //                 clonedOffResources.addAll(clonedOffResources1);
        //             }
                  
        //             if(!Test.isRunningTest()){  
        //                 if(!clonedOffCats.isEmpty()){
        //                     insert clonedOffCats; //inserting offering categories
        //                 }
                            
        //                 if(!clonedOffSpecs.isEmpty()){
        //                    insert clonedOffSpecs; //inserting offering specifications
        //                 }
        
        //                 if(!clonedOffResources.isEmpty()){
        //                   insert clonedOffResources; //inserting offering resources
        //                 }
        //             }    
        //         }
        //     }
        //     if(!Test.isRunningTest() && tempOfferingList.size()>0){
        //             update tempOfferingList; //Inserting Draft Offering with Published Copy True
        //         }
        // }

        //  /**
        // * @description Method To clone Offering categories
        // * @param Id,Id
        // * @return List<PMP_Partner_Offering_Category__c>
        // **/
        // @AuraEnabled
        // public static List<PMP_Partner_Offering_Category__c> cloneOfferingCategories(Id offeringId,Id clonedOfferingId){
        
        //      List<PMP_Partner_Offering_Category__c> clonedOffCatList = new List<PMP_Partner_Offering_Category__c>();
        //     try{
        //         //Querying all the child records
        //         if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
        //             DescribeSObjectResult offCatFields = PMP_Partner_Offering_Category__c.getSObjectType().getDescribe();   
        //             string tempoffCatQuery = PMP_Utility.getObjectFields(offCatFields);
        //             string offCatQuery = tempoffCatQuery+    ' WHERE ' +         ' PMP_Offering_Id__c =: offeringId';  
        //             List<PMP_Partner_Offering_Category__c> tempCatList = Database.query(offCatQuery);
                    
        //             for(PMP_Partner_Offering_Category__c offCat:tempCatList){
        //                 PMP_Partner_Offering_Category__c clonedOffCat = new PMP_Partner_Offering_Category__c();
        //                 clonedOffCat = offCat.clone(false,false,true,true);
        //                 clonedOffCat.PMP_Offering_Id__c = clonedOfferingId;
        //                 clonedOffCat.CreatedById = UserInfo.getUserId();
        //                 clonedOffCatList.add(clonedOffCat);
        //             }
                
        //         }
                
        //         }catch(exception e){
        //         PMP_Utility.logError(e,'PMP_CloneOffering');
        //     }
        //     return clonedOffCatList;
        // }
         
        //  /**
        // * @description Method To clone Offering specs
        // * @param Id,Id
        // * @return List<PMP_Partner_Offering_Specification__c>
        // **/
        //  public static List<PMP_Partner_Offering_Specification__c> cloneOfferingSpecifications(Id offeringId,Id clonedOfferingId){
        //     List<PMP_Partner_Offering_Specification__c> clonedOffSpecList = new List<PMP_Partner_Offering_Specification__c>();
        //     try{
        //         //Querying all the child records
        //         if(Schema.sObjectType.PMP_Partner_Offering_Specification__c.isAccessible()){
        //             DescribeSObjectResult offSpecFields = PMP_Partner_Offering_Specification__c.getSObjectType().getDescribe();   
        //             string tempoffSpecQuery = PMP_Utility.getObjectFields(offSpecFields);
        //             string offSpecQuery = tempoffSpecQuery +    ' WHERE ' +         ' PMP_Offering_Id__c =: offeringId';   
        //             List<PMP_Partner_Offering_Specification__c> tempSpecList = Database.query(offSpecQuery);
        //             for(PMP_Partner_Offering_Specification__c offSpec:tempSpecList){
        //                 PMP_Partner_Offering_Specification__c clonedOffSpec = new PMP_Partner_Offering_Specification__c();
        //                 clonedOffSpec = offSpec.clone(false,false,true,true);
        //                 clonedOffSpec.PMP_Offering_Id__c = clonedOfferingId;
        //                 clonedOffSpec.CreatedById = UserInfo.getUserId();
        //                 clonedOffSpecList.add(clonedOffSpec);
        //             }
                                        
        //             }
        //         }catch(exception e){
        //             PMP_Utility.logError(e,'PMP_CloneOffering');
        //         }
        //     return clonedOffSpecList;
            
        //     }
        
        // /**
        // * Method added by Vardaan aj to create offeringResource records for cloned offering
        // * @description-Method to create cloned offeringResource
        // * @param-offeringId Id of the offering which is being cloned
        // * @param-clonedOfferingId Id of the cloned offering
        // * @return-List<PMP_Partner_Offering_Resource__c>
        // * Method Parameters-Id,Id 
        // **/    
        // public  static List<PMP_Partner_Offering_Resource__c> cloneOfferingResources(Id offeringId, Id clonedOfferingId){
        //     List<PMP_Partner_Offering_Resource__c> clonedOfferingResources = new List<PMP_Partner_Offering_Resource__c>();//list to store newly created offeringResources
        //     List<ContentVersion> clonedContentVersions = new List<ContentVersion>();//List to store newly created contentVersions
        //     List<ContentDocumentLink> clonedDocumentLinks = new List<ContentDocumentLink>();//List to store contentDocumentLinks 
        //     Set<Id> contentDocs = new Set<Id>();//List to store contentDocuments of the existing offering images 
        //     Set<Id> clonedContentVersionIds = new Set<Id>();//list to store newly created contentversion 
        //     Map<Id,Id> resourceIdByContentId = new Map<Id,Id>();//map to store existing resource Ids by contentDocument Ids
        //     Map<Id, Id> contentIdByResourceId = new Map<Id, Id>();//map to store existing contentDocument Ids by resource Ids
        //     Map<Id, Id> clonedContentIdsByOriginalContentIds = new Map<Id, Id>();// map to store newly created contentDocument Ids by existing contentDocument Ids.
            
        //     try{
        //         if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
        //         DescribeSObjectResult offeringResourceFields = PMP_Partner_Offering_Resource__c.getSObjectType().getDescribe();
        //         string tempoffResourceQuery = PMP_Utility.getObjectFields(offeringResourceFields);
        //         string offResourceQuery= tempoffResourceQuery+    ' WHERE ' +         ' PMP_Offering_Id__c =: offeringId and PMP_Resource_Type_Nm__c!=\''+'Thumbnail Image'+'\'';
                
        //         List<PMP_Partner_Offering_Resource__c> existingOfferingresources = database.query(offResourceQuery);//querying all the fields of offering record
                
        //         for(PMP_Partner_Offering_Resource__c resource : existingOfferingresources){
                    
        //             //to accomodate new additonal resource changes as additional resource records will also have files
        //             if(string.isNotBlank(resource.PMP_Partner_Offering_Image__c)){
        //                 contentDocs.add(resource.PMP_Partner_Offering_Image__c);//List containing docIds of the image and thumbnail of original resources
        //                 resourceIdByContentId.put((Id)resource.PMP_Partner_Offering_Image__c, resource.Id);//Map<Id, Id>, containing <docId, resourceId>
        //                 contentIdByResourceId.put(resource.Id, (Id)resource.PMP_Partner_Offering_Image__c);//Map<Id, Id>, containing <resourceId, docId>
        //             }
        //         }
                
        //         List<ContentVersion>  contentVersions = [SELECT Id, ContentDocumentId,Title   FROM ContentVersion where ContentDocumentId IN: contentDocs AND IsLatest=true];
                
        //         if(!contentVersions.isEmpty()){
        //             for(ContentVersion version : contentVersions){//iterating over original contentversion to create cloned version with same version data and pathOnClient 
        //                 ContentVersion cv = new ContentVersion();
                        
        //                 String description = String.valueOf(resourceIdByContentId.get(version.ContentDocumentId));
                      
        //                 clonedContentIdsByOriginalContentIds.put(contentIdByResourceId.get(description), version.ContentDocumentId);
        //             }
        //         }
        //         contentVersions.clear();//clearing the list to reduce the heap size
                
        //         if(!clonedContentVersions.isEmpty()){
                    
        //             insert clonedContentVersions;//inserting cloned contentVersions
                    
        //             for(ContentVersion version : clonedContentVersions){
        //                 clonedContentVersionIds.add(version.Id);//List containing all the newly created version Ids
        //             }
                    
        //             clonedContentVersions.clear();//clearing the list to reduce the heap size
                    
        //             List<ContentVersion>  newContentVersions = [SELECT Id, Title, ContentDocumentId,VersionData,Description FROM ContentVersion where Id IN: clonedContentVersionIds AND IsLatest=true];//get all the cloned contentVersion records
                    
        //             if(!newContentVersions.isEmpty()){
        //                 for(ContentVersion version : newContentVersions){//iterating over the newly created contentVersions
        //                     clonedContentIdsByOriginalContentIds.put(String.valueOf(contentIdByResourceId.get(version.Description.substringAfterLast('_'))), version.ContentDocumentId);//Map<Id,Id>, containing<originalDocId, clonedDocId>
        //                 }
        //             }
                    
        //             newContentVersions.clear(); //clearing the list to reduce the heap size
                   
        //         }
                
        //         for(PMP_Partner_Offering_Resource__c resource : existingOfferingresources){
                    
        //             PMP_Partner_Offering_Resource__c clonedResource = new PMP_Partner_Offering_Resource__c();
        //             clonedResource = resource.clone(false, false, true, true);//cloning the existing OfferingResource record
        //             clonedResource.PMP_Offering_Id__c = clonedOfferingId;//mapping the cloned resource to cloned offering
        //             clonedResource.PMP_Partner_Offering_Image__c = clonedContentIdsByOriginalContentIds.get(resource.PMP_Partner_Offering_Image__c);//populating contentDocument Id of the cloned image
        //             clonedResource.CreatedById = UserInfo.getUserId();
        //             clonedOfferingResources.add(clonedResource);
        //             if( clonedContentIdsByOriginalContentIds.get(resource.PMP_Partner_Offering_Image__c) != null && (clonedResource.PMP_Resource_Type_Nm__c!=null || clonedResource.PMP_Resource_Type_Nm__c!='')){//if the resource type is image, create contentDocument link for that image
        //                 ContentDocumentLink cdl = PMP_Utility.getContentDocumentLinkInstance(clonedContentIdsByOriginalContentIds.get(resource.PMP_Partner_Offering_Image__c), clonedOfferingId);//get contentDocumentLink from utility class
        //                 clonedDocumentLinks.add(cdl);
        //             }
        //         }
        //         insert clonedDocumentLinks;
        //         }
        //     }
        //     catch(exception e){
        //         PMP_Utility.logError(e,'PMP_CloneOffering');
        //     }
        //     return clonedOfferingResources;//returning the cloned resources 
        // }
        
        //  /**
        // * Method added by Prakash to prepare offering translation records for offering
        // * @description-Method to create offering translations
        // * @param-offering under which translations to be created
        // * @return-List<PMP_Partner_Offering_Translation__c>
        // * Method Parameter- PMP_Partner_Offering__c
        // **/ 
        // public static List<PMP_Partner_Offering_Translation__c> prepareLanguageTranslation(PMP_Partner_Offering__c offering) {
    
        //     list<PMP_Partner_Offering_Translation__c> translationRecordList = new list<PMP_Partner_Offering_Translation__c>();   
        //     if(offering.PMP_Partner_Offering_Nm__c != null) {            
        //         PMP_Partner_Offering_Translation__c lngeTrnsl = new PMP_Partner_Offering_Translation__c();
        //         lngeTrnsl.Name = offering.id+PMP_StaticConstants_Offering.Name;
        //         lngeTrnsl.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Name; 
        //         lngeTrnsl.PMP_Partner_Offering_Id__c=offering.id;
        //         if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.English) {
        //             lngeTrnsl.PMP_English_Txt__c = offering.PMP_Partner_Offering_Nm__c;        
        //         }           
        //         else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Chinese) {
        //             lngeTrnsl.PMP_Chinese_Txt__c= offering.PMP_Partner_Offering_Nm__c;
        //         }
        //         else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Japanese) {
        //             lngeTrnsl.PMP_Japanese_Txt__c = offering.PMP_Partner_Offering_Nm__c;
        //         }
        //         translationRecordList.add(lngeTrnsl);
        //     }

        //     if(offering.PMP_Partner_Offering_Tag_Line_Txt__c != null) {            
        //         PMP_Partner_Offering_Translation__c lngeTrnsl = new PMP_Partner_Offering_Translation__c();
        //         lngeTrnsl.Name = offering.id+PMP_StaticConstants_Offering.Tag; 
        //         lngeTrnsl.PMP_Partner_Offering_Id__c = offering.id;
        //         lngeTrnsl.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Tag; 
        //         if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.English) {                
        //             lngeTrnsl.PMP_English_Txt__c = offering.PMP_Partner_Offering_Tag_Line_Txt__c ;
        //         }                   
        //         else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Chinese){
        //             lngeTrnsl.PMP_Chinese_Txt__c= offering.PMP_Partner_Offering_Tag_Line_Txt__c;
        //         }
        //         else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Japanese){
        //             lngeTrnsl.PMP_Japanese_Txt__c = offering.PMP_Partner_Offering_Tag_Line_Txt__c;
        //         }
        //         translationRecordList.add(lngeTrnsl);
        //     }

        //     if(offering.PMP_Partner_Offering_Dsc__c != null) {
        //         PMP_Partner_Offering_Translation__c lngeTrnsl = new PMP_Partner_Offering_Translation__c();
        //         lngeTrnsl.Name = offering.id+PMP_StaticConstants_Offering.Description ; 
        //         lngeTrnsl.PMP_Partner_Offering_Id__c=offering.id;
        //         lngeTrnsl.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Description ; 
        //         if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.English){ 
        //             lngeTrnsl.PMP_English_Txt__c = offering.PMP_Partner_Offering_Dsc__c;
        //         }                   
        //         else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Chinese) {
        //             lngeTrnsl.PMP_Chinese_Txt__c= offering.PMP_Partner_Offering_Dsc__c;
        //         }
        //         else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Japanese) {
        //             lngeTrnsl.PMP_Japanese_Txt__c = offering.PMP_Partner_Offering_Dsc__c;
        //         }
        //         translationRecordList.add(lngeTrnsl);
        //     }
        //     return translationRecordList;
        // }
    }