/*******************************************************************************************************************************************************************************************************
* Class Name  : PSS_SolutionToOfferingConversionHelper
* Description : This Class is the Helper Class for PSS_SolutionToOfferingConverter Apex Class
* Version     : 1.0 
* Created Date: 26-May-2021
* Modification Log :
* Created By  : ONYX Team (Infosys)
********************************************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public without sharing class PSS_SolutionToOfferingConversionHelper {
}   
/**
* Method called from PSS_SolutionToOfferingConverter Apex Class for creating Content Versions
* @description- Copies the Allowable Format Docs from Solution and links it to offering
* @param propResponsesId List of Solution Ids for which ContentDocuments has to be processed
* @param sDocumentQuestionResultIdSet - Set of Document Upload QuestionResult Ids which will be checked for Mapping to Partner Offering Resource for copying Docs to offering
* @return ContentVersionsForOfferingWrapper - Wrapper Class Variables returned back to PSS_SolutionToOfferingConverter Apex Class
*/     
    /*
    public static ContentVersionsForOfferingWrapper createContentVersionsForOffering(List<string> propResponsesId,Set<string> sDocumentQuestionResultIdSet){
      
        //Offering resource list for inserting image records
        List<PMP_Partner_Offering_Resource__c> resourceList = New List<PMP_Partner_Offering_Resource__c>();
        
        //ContentDocumentLink list which links the offering with contentDocument
        List<ContentDocumentLink> contentDocCloneList = New List<ContentDocumentLink>();       

        //Acceptable and uploadable image formats in offering image section

        List<PSS_Conversion_File_Formats__c> lstFileFormats = new List<PSS_Conversion_File_Formats__c>();
        //get the data from PSS_Conversion_File_Formats__c custom settings
        lstFileFormats = PSS_Conversion_File_Formats__c.getall().values();
        Set<String> sAllowableFileFormats = New Set<String>();
        for(PSS_Conversion_File_Formats__c sFileFormat : lstFileFormats) 
        {
            if(!sFileFormat.PSS_Inactive_Ind__c)
            {								
                sAllowableFileFormats.add(sFileFormat.PSS_File_Format_Nm__c);
            }   
        }
            
        //key will be the survey result Id and the list of contentDocumentLink is the value
        Map<String,List<ContentDocumentLink>> docMap = New Map<String,List<ContentDocumentLink>>();
        
        //Map with key = contentDocId and value = LinkedEntityId
        Map<String,String> docIdMap = New Map<String,String>();
        
        //ContentVersionList
        List<ContentVersion>conVersionCloneList = New List<ContentVersion>();
        
        //Map with key = contentDocId and value = ContentVersion
        Map<String,String> conVersionCloneMap = New Map<String,String>();
        
        Map<String,String> conVersionIdMap = New Map<String,String>();
        
        Map<String,String> fileTypeMap = New Map<String,String>();

        Set<String> questionResultContentDocIds = new Set<String>();
        
        
        List<String> cVersionIds = New List<String>();
        
        //Network Id of Partner Solutions Market place community
        Id networkId;        
        Network psmNetwork = [SELECT Id FROM Network WHERE Name =: PMP_Utility.getValue('Marketplace_Community_Name') ];
        if(psmNetwork != null){
            networkId = psmNetwork.Id;
        }        
		
        //IMG UPLOAD ISSUE:
        List<ArdiraSurvey__Question_Result__c> SolImgUploadQuestionResult=[select id, name,ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c from ArdiraSurvey__Question_Result__c 
                                                                           where ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c ='Partner_Solution_Image_Upload_Key' and id in:sDocumentQuestionResultIdSet];
        
        String logoQuestionResID= NULL;//To store the QuestionResult id of the 
        if(SolImgUploadQuestionResult.size()>0){
            logoQuestionResID=SolImgUploadQuestionResult[0].Id; //get the question result id for provide solution image question in partner solution survey
        }
        //Get the image formats from Custom Metadata
        String imgFormats = PMP_Utility.getValue('PSS_ImageFormats');// get the image formats from metadata record
        List<String> sAllowableImageFormats = imgFormats.split('\\:');//split the string with delimiter : and get the image formats to a list

        Set<String> LogosDocumentIDs= new Set<String>();

        
        //FETCHING THE CONTENT DOCUMENT IDs RELATED TO QUESTION RESULT RECORD CONTENTDOCUMENTLINK
        for(ContentDocumentLink questionResultContentDocLink : [SELECT Id, ContentDocumentId,ContentDocument.FileType,ContentDocument.FileExtension,ContentDocument.Title,LinkedEntityId FROM ContentDocumentLink 
        WHERE LinkedEntityId in :sDocumentQuestionResultIdSet AND ContentDocument.FileType in :sAllowableFileFormats ]){
			
             //get the document ids for provide solution image question
            if(logoQuestionResID!=NULL && questionResultContentDocLink.LinkedEntityId == logoQuestionResID &&
               sAllowableImageFormats.contains(questionResultContentDocLink.ContentDocument.FileType) ){
                   LogosDocumentIDs.add(questionResultContentDocLink.ContentDocumentId);//get all the image documents for provide solution image question
               }
            else if(logoQuestionResID!=NULL && questionResultContentDocLink.LinkedEntityId == logoQuestionResID){// If user has uploaded non image files we have to skip them
                continue;
            }

            questionResultContentDocIds.add(questionResultContentDocLink.ContentDocumentId);

        }
        //CONSTRUCTING MAP OF CONTENTDOCUMENTID and SOLUTIONID FOR ONLY ALLOWABLE FORMAT DOCS THAT BELONGS TO ADMIN PAGE MAPPED DOCUMENT UPLOAD QUESTION RESULT ID
        for(ContentDocumentLink cdl: [SELECT Id, ContentDocumentId,ContentDocument.FileType,ContentDocument.FileExtension,ContentDocument.Title,LinkedEntityId FROM ContentDocumentLink
        WHERE LinkedEntityId in :propResponsesId AND ContentDocument.FileType in :sAllowableFileFormats AND ContentDocumentId in :questionResultContentDocIds]) {
            if(docMap.get(cdl.LinkedEntityId) == null) {
                docMap.put(cdl.LinkedEntityId, new List<ContentDocumentLink>());
            }
            docMap.get(cdl.LinkedEntityId).add(cdl); //Map(entityId, List<contentdocLink>)
            docIdMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
        }
        
        for(ContentVersion cd: [SELECT Id,VersionData,Title,Origin,PathOnClient, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId in :docIdMap.KeySet()]) {

          //Cloning and updating the ContentVersion Instance to create a new version for offering
          ContentVersion cVersion = New ContentVersion();
          cVersion.PathOnClient = cd.PathOnClient;//File name with extention
          cVersion.Origin = 'H';//H-Chatter Origin.
          cVersion.VersionData = cd.VersionData;//File content
          cVersion.NetworkId = networkId; //ID of the community that this file originated from
          cVersion.Description = cd.Title + '_' + String.valueOf(cd.ContentDocumentId);
          conVersionCloneList.add(cVersion);
          conVersionCloneMap.put(cVersion.Description,cd.ContentDocumentId);
        }
        
        // INSERTING ContentVersion WILL AUTOMATICALLY CREATE NEW ContentDocument Ids
        if(conVersionCloneList.size()>0){
            insert conVersionCloneList;
        } 

        Map<String,String> cvIdMap = New Map<String,String>();
        for(contentVersion cvL :conVersionCloneList){
            cVersionIds.add(cvL.Id);
        }
        // CREATE A MAP OF OLD CONTENTDOCUMENTID TO NEW CONTENTDOCUMENT ID (GENERATED WHILE INSERTING ContentVersion) in conVersionIdMap
        for(contentVersion cv : [Select id,ContentDocumentId,Description,FileType from contentVersion where Id in :cVersionIds]){
            conVersionIdMap.put(conVersionCloneMap.get(cv.Description),cv.ContentDocumentId);
            if(LogosDocumentIDs.contains(conVersionCloneMap.get(cv.Description))){
                 fileTypeMap.put(conVersionCloneMap.get(cv.Description),'LOGO_IMAGE');//if its logo document ,passing the unique type for processing

            }
            else{
                fileTypeMap.put(conVersionCloneMap.get(cv.Description),cv.FileType);  
            }
        }
        
        ContentVersionsForOfferingWrapper sWrapper = new ContentVersionsForOfferingWrapper();
        sWrapper.conVersionIdMap = conVersionIdMap;
        sWrapper.fileTypeMap = fileTypeMap;
        sWrapper.docMap = docMap;
        return sWrapper;
    }
*/
/**
* Method called from PSS_SolutionToOfferingConverter Apex Class
* @description-Retrieves the mapped Category values for programsApplicable selected in Solution using Metadata mapping
* @param propResponses List of Solution records for which ProgramsApplicable selected Category is fetched
* @return set<string> - Set of mapped PIM Ids in Metadata for selected ProgramsApplicable field values
*/ 
/*
    public static set<string> getProgramsApplicableCategoryPIMSet(List<ArdiraSurvey__Survey_Result__c> propResponses){

        // Added by Shahrukh to map programs applicable to categories        
        List<string> programsApplicableList = new List<String>();
        Map<string,string> solutionsMap = new Map<string,string>();
        
        for(PSS_Category_solution_mapping__mdt catSol: [select id,MasterLabel,PSS_Category_taxonomy_cd__c from PSS_Category_solution_mapping__mdt where PSS_Category_taxonomy_cd__c != null]){
			 solutionsMap.put(catSol.MasterLabel,catSol.PSS_Category_taxonomy_cd__c);
        }
        
        
        for(ArdiraSurvey__Survey_Result__c response : propResponses){
            if(response.PSS_Programs_Applicable_Nm__c!=Null){
               programsApplicableList = response.PSS_Programs_Applicable_Nm__c.split(';');
            }
        }
        
        set<string> categoryPIMSet = new set<string>();
                
        if(!programsApplicableList.isEmpty()){
            for(string progString: programsApplicableList){
                categoryPIMSet.add(solutionsMap.get(progString));
            }
        }
        return categoryPIMSet;

    }
*/
/**
* Method called from PSS_SolutionToOfferingConverter Apex Class
* @description-Retrieves the mapped Taxonomy Details and pass it back to PSS_SolutionToOfferingConverter and PSS_SolutionToOfferingConversionLogic class for further processing
* @param responseDetailMap Map of SolutionId with List of QuestionResult records along with Choices
* @return PIMIdToTaxonomyIdMapWrapper - Wrapper class with the Taxonomy mapping details
*/ 
/*
    public static PIMIdToTaxonomyIdMapWrapper getPIMIdToTaxonomyIdMap(Map<string,List<ArdiraSurvey__Question_Result__c>> responseDetailMap) {
        
        Set<string> sPIMIDSet = new Set<string>();
        Set<string> sDocumentQuestionResultIdSet = new Set<string>();
        PIMIdToTaxonomyIdMapWrapper sPIMIdToTaxonomyIdMapWrapper = new PIMIdToTaxonomyIdMapWrapper();
        Map<string,string> sPIMIdToTaxonomyIdCatMap = new Map<string,string>();
        Map<string,string> sPIMIdToTaxonomyIdSpecMap = new Map<string,string>();
        Map<string,string> sPIMIdToTaxonomyIdSpecValueMap = new Map<string,string>();
        Map<string,string> sSpecValueIdToSpecValueMap = new Map<string,string>();
        Map<string,string> sSpecValueIdToImmediateParentSpecPIM = new Map<string,string>();
        Map<String,String> sImmediateParentSpecPIMToSpecIdMap = new Map<String,String>();
	    Map<String,List<String>> sSpecIdToParentSpecsIdMap = new Map<String,List<String>>();
        Set<String> sImmediateParentSpecPIMSet = new Set<String>();
        String sResourceObjectName = PSS_StaticConstants.SOLUTIONS_CONVERSION_RESOURCEOBJECT_NAME;
        sPIMIdToTaxonomyIdMapWrapper.sPIMIdToTaxonomyIdCatMap = sPIMIdToTaxonomyIdCatMap;
        sPIMIdToTaxonomyIdMapWrapper.sPIMIdToTaxonomyIdSpecMap = sPIMIdToTaxonomyIdSpecMap;
        sPIMIdToTaxonomyIdMapWrapper.sPIMIdToTaxonomyIdSpecValueMap = sPIMIdToTaxonomyIdSpecValueMap;
        sPIMIdToTaxonomyIdMapWrapper.sSpecValueIdToSpecValueMap = sSpecValueIdToSpecValueMap;
        sPIMIdToTaxonomyIdMapWrapper.sDocumentQuestionResultIdSet = sDocumentQuestionResultIdSet;
        sPIMIdToTaxonomyIdMapWrapper.sSpecValueIdToImmediateParentSpecPIM = sSpecValueIdToImmediateParentSpecPIM;
        sPIMIdToTaxonomyIdMapWrapper.sImmediateParentSpecPIMToSpecIdMap = sImmediateParentSpecPIMToSpecIdMap;
        sPIMIdToTaxonomyIdMapWrapper.sSpecIdToParentSpecsIdMap = sSpecIdToParentSpecsIdMap;
        // LOOP THROUGH THE QUESTIONRESULT AND QUESTIONRESULTCHOICES RECORD FOR EACH SOLUTION AND GRAB PIMID SET AND DOCUMENTQUESTIONRESULTID Set
        for(Id responseId : responseDetailMap.keySet())
        {
            for(ArdiraSurvey__Question_Result__c responseQuestion :responseDetailMap.get(responseId) )
            {
                if(responseQuestion.ArdiraSurvey__Question_Result_Choices__r.size()>0)
                {
                    for( ArdiraSurvey__Question_Result_Choice__c resultChoice : responseQuestion.ArdiraSurvey__Question_Result_Choices__r)
                    {
                        if(resultChoice.ArdiraSurvey__Answer_Choice__r.PSS_Related_Offering_Options_Txt__c != null && resultChoice.ArdiraSurvey__Answer_Choice__r.PSS_Related_Offering_Options_Txt__c != '' )
                        {
                            List<string> sTempPIMIdList = resultChoice.ArdiraSurvey__Answer_Choice__r.PSS_Related_Offering_Options_Txt__c.split(',');
                            String sTempParentTaxonomyPIMIdList = resultChoice.ArdiraSurvey__Answer_Choice__r.PSS_Related_Parent_Taxonomy_Txt__c;
                            sPIMIDSet.addAll(sTempPIMIdList);
                            sPIMIDSet.add(sTempParentTaxonomyPIMIdList);
                        }
                    }

                }
                else if(responseQuestion.ArdiraSurvey__Question__r.PSS_Conversion_Taxonomy_Nm__c != sResourceObjectName
                && responseQuestion.ArdiraSurvey__Question__r.PSS_Related_Parent_Taxonomy_Txt__c != null && responseQuestion.ArdiraSurvey__Question__r.PSS_Related_Parent_Taxonomy_Txt__c != ''
                && responseQuestion.ArdiraSurvey__Question__r.PSS_Related_Offering_Options_Txt__c != null && responseQuestion.ArdiraSurvey__Question__r.PSS_Related_Offering_Options_Txt__c != '')
                {
                    List<string> sQuestionTempPIMIdList = responseQuestion.ArdiraSurvey__Question__r.PSS_Related_Offering_Options_Txt__c.split(',');
                    String sQuestionParentTaxonomyPIMId = responseQuestion.ArdiraSurvey__Question__r.PSS_Related_Parent_Taxonomy_Txt__c;
                    sPIMIDSet.addAll(sQuestionTempPIMIdList);
                    sPIMIDSet.add(sQuestionParentTaxonomyPIMId);
                }
                else if(responseQuestion.ArdiraSurvey__Question__r.PSS_Conversion_Taxonomy_Nm__c == sResourceObjectName)
                {
                    sDocumentQuestionResultIdSet.add(responseQuestion.Id);
                }

            }
        } // FOR LOOP END FOR ALL SOLUTIONS

        //IDENTIFY AND SEPARATE THE PIMID SET GATHERED BASED ON OBJECT IT BELONGS TO AND FORM MAPS FOR FURTHER PROCESSING
        if(sPIMIDSet.size() > 0)
        {
            for(PMP_Category__c sCategory : [SELECT Id,PMP_Partner_Product_Category_Key__c from PMP_Category__c WHERE PMP_Partner_Product_Category_Key__c IN: sPIMIDSet AND PMP_Active_Ind__c = true])
            {
                sPIMIdToTaxonomyIdCatMap.put(sCategory.PMP_Partner_Product_Category_Key__c , sCategory.Id);
                sPIMIdToTaxonomyIdMapWrapper.sPIMIdToTaxonomyIdCatMap = sPIMIdToTaxonomyIdCatMap;
            }
            
            for(PMP_Specification__c sSpecification : [SELECT Id,PMP_Partner_Product_Specification_Key__c from PMP_Specification__c WHERE PMP_Partner_Product_Specification_Key__c IN: sPIMIDSet AND PMP_Active_Ind__c = true])
            {
                sPIMIdToTaxonomyIdSpecMap.put(sSpecification.PMP_Partner_Product_Specification_Key__c , sSpecification.Id);
                sPIMIdToTaxonomyIdMapWrapper.sPIMIdToTaxonomyIdSpecMap = sPIMIdToTaxonomyIdSpecMap;
            }
            
            for(PMP_Specification_Value__c sSpecValue : [SELECT Id,PMP_Product_Specification_Value_Key__c,Name,PMP_Specification_Product_Cd__c from PMP_Specification_Value__c WHERE PMP_Product_Specification_Value_Key__c IN: sPIMIDSet AND PMP_Active_Ind__c = true])
            {
                sPIMIdToTaxonomyIdSpecValueMap.put(sSpecValue.PMP_Product_Specification_Value_Key__c , sSpecValue.Id);
                sSpecValueIdToSpecValueMap.put(sSpecValue.Id , sSpecValue.Name );
                sSpecValueIdToImmediateParentSpecPIM.put(sSpecValue.Id , sSpecValue.PMP_Specification_Product_Cd__c);
                sImmediateParentSpecPIMSet.add(sSpecValue.PMP_Specification_Product_Cd__c);
                sPIMIdToTaxonomyIdMapWrapper.sSpecValueIdToImmediateParentSpecPIM = sSpecValueIdToImmediateParentSpecPIM;
                sPIMIdToTaxonomyIdMapWrapper.sPIMIdToTaxonomyIdSpecValueMap = sPIMIdToTaxonomyIdSpecValueMap;
                sPIMIdToTaxonomyIdMapWrapper.sSpecValueIdToSpecValueMap = sSpecValueIdToSpecValueMap;
            }
        }

        // Set Wrapper Variable when QuestionResult Record mapped to Partner Offering Resource Exists
        if(sDocumentQuestionResultIdSet.size() > 0)
        {
            sPIMIdToTaxonomyIdMapWrapper.sDocumentQuestionResultIdSet = sDocumentQuestionResultIdSet;
        }

        //Call getTaxonomyHierarchyDetails method to fetch the Taxonomy Hierarchy for Parent Specification of Spec Values
        if(sImmediateParentSpecPIMSet.size() > 0)
        {
            TaxonomyHierarchyDetailsWrapper sTaxonomyHierarchyDetailsWrapper = getTaxonomyHierarchyDetails(sImmediateParentSpecPIMSet , 'Specification Value');
            sImmediateParentSpecPIMToSpecIdMap = sTaxonomyHierarchyDetailsWrapper.sImmediateParentSpecPIMToSpecIdMap;
            sSpecIdToParentSpecsIdMap = sTaxonomyHierarchyDetailsWrapper.sSpecIdToParentSpecsIdMap;
            sPIMIdToTaxonomyIdMapWrapper.sImmediateParentSpecPIMToSpecIdMap = sImmediateParentSpecPIMToSpecIdMap;
            sPIMIdToTaxonomyIdMapWrapper.sSpecIdToParentSpecsIdMap = sSpecIdToParentSpecsIdMap;
        }        

        return sPIMIdToTaxonomyIdMapWrapper;

    }
*/
/**
* METHOD CALLED FROM getPIMIdToTaxonomyIdMap method in this Apex class
* @description-METHOD WHICH RETURN THE TAXONOMY HIERARCHY DETAILS FOR PROCESSING WHEN PARENT SPECIFICATION PIMSet and Taxonomy Object Type is passed
* @param sPIMSet Set of ImmediateParentSpecification PIM Id for which Hierarchy is fetched
* @param sTaxonomyObjectType - Taxonomy Object to which the Set of PIMIds passed (sPIMSet) belongs to
* @return TaxonomyHierarchyDetailsWrapper - Wrapper Class Variables returned back to getPIMIdToTaxonomyIdMap method in this Apex class
*/ 
/*
public static TaxonomyHierarchyDetailsWrapper getTaxonomyHierarchyDetails(Set<String> sPIMSet, String sTaxonomyObjectType)
{

	Set<String> sSpecSet = new Set<String>();
	Map<String,List<String>> sSpecIdToPIMMap = new Map<String,List<String>>();
	Map<String,String> sSpecPIMToSpecIdMap = new Map<String,String>();
	Map<String,String> sImmediateParentSpecPIMToSpecIdMap = new Map<String,String>();
	Map<String,List<String>> sSpecIdToParentSpecsIdMap = new Map<String,List<String>>();
	TaxonomyHierarchyDetailsWrapper sTaxonomyHierarchyDetailsWrapper = new TaxonomyHierarchyDetailsWrapper();
	sTaxonomyHierarchyDetailsWrapper.sImmediateParentSpecPIMToSpecIdMap = sImmediateParentSpecPIMToSpecIdMap;
	sTaxonomyHierarchyDetailsWrapper.sSpecIdToParentSpecsIdMap = sSpecIdToParentSpecsIdMap;

	//Handle when Taxonomy Object Type is Specification Value
	if(sTaxonomyObjectType == 'Specification Value')
	{
	
		//LOOP THROUGH PARENT SPECIFICATION SET (sPIMSet) OF ALL SPEC VALUES AND FOR MAP BETWEEN PARENT SPECIFICATION ID AND LIST OF ITS PARENT SPECS
		for(PMP_Specification__c sSpecification : [SELECT Id,PMP_Partner_Product_Specification_Id__c,PMP_Partner_Product_Specification_Key__c,PMP_Ancestor_Specification_Cd__c from PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c IN: sPIMSet AND PMP_Active_Ind__c = true]) {
		
			List<String> sSpecListTemp = new List<String>();
			sImmediateParentSpecPIMToSpecIdMap.put(sSpecification.PMP_Partner_Product_Specification_Id__c , sSpecification.Id);
			sTaxonomyHierarchyDetailsWrapper.sImmediateParentSpecPIMToSpecIdMap = sImmediateParentSpecPIMToSpecIdMap;
            String sAncestorSpecificationValue = sSpecification.PMP_Ancestor_Specification_Cd__c;
            if(sAncestorSpecificationValue != null && sAncestorSpecificationValue != '')
            {
			    sSpecListTemp = sAncestorSpecificationValue.split('&#124;');//Equivalent code for | symbol is &#124; 
                sSpecListTemp.add(sSpecification.PMP_Partner_Product_Specification_Id__c);//Add Immediate Parent Spec PIM to List if it is not the Root Specification.Ex:WAN Record
            }
			if(sSpecListTemp.size() > 1)//Root Specification will appear as Heading in Offering and will not be a Partner Offering Specification record
			{
				sSpecListTemp.remove(0);
				sSpecSet.addAll(sSpecListTemp);
				sSpecIdToPIMMap.put(sSpecification.Id , sSpecListTemp);
			}		
			
		
		}
		
		if(sSpecSet.size() > 0) //PROCESS ALL PARENT SPECIFICATIONS OF IMMEDIATE PARENT SPECIFICATION AND OBTAIN PIMId to SpecId Map
		{
			for(PMP_Specification__c sSpecification : [SELECT Id,PMP_Partner_Product_Specification_Id__c,PMP_Partner_Product_Specification_Key__c,PMP_Ancestor_Specification_Cd__c from PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c IN: sSpecSet AND PMP_Active_Ind__c = true]) {
			
			sSpecPIMToSpecIdMap.put(sSpecification.PMP_Partner_Product_Specification_Id__c , sSpecification.Id);
			
			
			}
		
		}
		
		//LOOP THROUGH EACH SPECIFICATION IN sSpecIdToPIMMap AND FORM MAP BETWEEN IMMEDIATE PARENT SPECIFICATION ID AND ITS ALL PARENT SPECIFICATIONS ID
		for(String specId : sSpecIdToPIMMap.keySet())
		{
		
			List<String> sSpecIDListTemp = new List<String>();
			
			//LOOP THROUGH PIM LIST AGAINST EACH SPECIFICATION AND REPLACE PIM LIST WITH CORRESPONDING RECORD ID
			for(String sSpecPIM : sSpecIdToPIMMap.get(specId))
			{
				String sSpecIDTemp = sSpecPIMToSpecIdMap.get(sSpecPIM);
				sSpecIDListTemp.add(sSpecIDTemp);			
			
			}
			
			//THIS MAP STORES PARENT SPECIFICATION IDs OF EACH SPECIFICATION WHICH IS PARENT FOR SPEC VALUE
			sSpecIdToParentSpecsIdMap.put(specId , sSpecIDListTemp); 
			sTaxonomyHierarchyDetailsWrapper.sSpecIdToParentSpecsIdMap = sSpecIdToParentSpecsIdMap;
		
		}
				
	}

    return sTaxonomyHierarchyDetailsWrapper;
}

    //WRAPPER CLASS CREATED FOR createContentVersionsForOffering Method TO PASS THE PARAMETERS BACK TO PSS_SolutionToOfferingConverter Apex Class
    public class ContentVersionsForOfferingWrapper {
        public Map<String,String> conVersionIdMap { get; set; }
        public Map<String,String> fileTypeMap { get; set; }
        public Map<String,List<ContentDocumentLink>> docMap { get; set; }

    }

    //WRAPPER CLASS CREATED FOR getPIMIdToTaxonomyIdMap Method TO PASS THE PARAMETERS BACK TO PSS_SolutionToOfferingConverter Apex Class
    public class PIMIdToTaxonomyIdMapWrapper {

        public Map<string,string> sPIMIdToTaxonomyIdCatMap { get; set; }
        public Map<string,string> sPIMIdToTaxonomyIdSpecMap { get; set; }
        public Map<string,string> sPIMIdToTaxonomyIdSpecValueMap { get; set; }
        public Map<string,string> sSpecValueIdToSpecValueMap { get; set; }
        public Set<string> sDocumentQuestionResultIdSet { get; set; }
        public Map<string,string> sSpecValueIdToImmediateParentSpecPIM { get; set; }
        public Map<String,String> sImmediateParentSpecPIMToSpecIdMap { get; set; }
        public Map<String,List<String>> sSpecIdToParentSpecsIdMap { get; set; }

    }

    //WRAPPER CLASS CREATED FOR getTaxonomyHierarchyDetails Method TO PASS THE PARAMETERS BACK TO getPIMIdToTaxonomyIdMap Method
    public class TaxonomyHierarchyDetailsWrapper {

        public Map<String,String> sImmediateParentSpecPIMToSpecIdMap { get; set; }
        public Map<String,List<String>> sSpecIdToParentSpecsIdMap { get; set; }
        
    }



}
*/