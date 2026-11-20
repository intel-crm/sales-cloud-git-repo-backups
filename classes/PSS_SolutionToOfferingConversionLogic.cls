/*******************************************************************************************************************************************************************************************************
* Class Name  : PSS_SolutionToOfferingConversionLogic
* Description : This Class is the Helper Class for Core Conversion Logic for PSS_SolutionToOfferingConverter Apex Class
* Version     : 1.0 
* Created Date: 26-May-2021
* Modification Log :
* Created By  : ONYX Team (Infosys)
********************************************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public without sharing class PSS_SolutionToOfferingConversionLogic {
}    
/**
* Method called from the Apex Class PSS_SolutionToOfferingConverter
* @description-This method contains the Core Logic that determines the conversion of Solution to corresponding Partner Offering Category, Specification, Resources,etc,. records based on Mapping
* @param responseDetailMap Map that contains the SolutionId and its corresponding QuestioResult with its choices
* @param sResourceObjectName - Name of the Partner Offering Resource Object
* @param sPIMIdToTaxonomyIdSpecValueMap - Map of PIM Id to Taxonomy Record Id for Specification Values
* @param sPIMIdToTaxonomyIdSpecMap - Map of PIM Id to Taxonomy Record Id of Specifications
* @param sPIMIdToTaxonomyIdCatMap - Map of PIM Id to Taxonomy Record Id of Category
* @param responseOfferingMap - Map of Solution to Partner Offering Object
* @param sSpecValueIdToSpecValueMap - Map of Taxonomy Record Id of Spec Value to Spec Value
* @param sSpecValueIdToImmediateParentSpecPIM - Map of Taxonomy record id of Spec Value to its Immediate Parent Specification PIM id
* @param sImmediateParentSpecPIMToSpecIdMap - Map of Immediate Parent Specification PIM of Spec Value to its Specification id
* @param sSpecIdToParentSpecsIdMap - Map of Immediate Parent Specification Record id to its List of Parent Specifications id in hierarchy
*/  
/*
    public static void solutionToOfferingConversionLogic(Map<string,List<ArdiraSurvey__Question_Result__c>> responseDetailMap, String sResourceObjectName, Map<string,string> sPIMIdToTaxonomyIdSpecValueMap, Map<string,string> sPIMIdToTaxonomyIdSpecMap, Map<string,string> sPIMIdToTaxonomyIdCatMap, Map<string,PMP_Partner_Offering__c> responseOfferingMap, Map<string,string> sSpecValueIdToSpecValueMap, Map<string,string> sSpecValueIdToImmediateParentSpecPIM, Map<String,String> sImmediateParentSpecPIMToSpecIdMap, Map<String,List<String>> sSpecIdToParentSpecsIdMap)
    {
           
        //to insert offeringCategory and specification
        List<PMP_Partner_Offering_Category__c> offCategoryList = New List<PMP_Partner_Offering_Category__c>();
        List<PMP_Partner_Offering_Specification__c> offSpecList = New List<PMP_Partner_Offering_Specification__c>();
        List<PMP_Partner_Offering_Resource__c> resourceList = New List<PMP_Partner_Offering_Resource__c>();
        List<string> categoryIdSet = New List<string>();
        List<string> specIdSet = New List<string>();
        List<string> sResourceURLList = New List<string>();
        List<string> specValueIdList = New List<string>();
        Map<string,List<string>> offeringCatMap = New Map<string,List<string>>();
        Map<string,List<string>> offeringSpecMap = New Map<string,List<string>>();
        Map<string,List<string>> offeringResourcesMap = New Map<string,List<string>>();
        Map<string,string> urlQuestionResourceMap = new Map<string,string>();
        Map<string,Map<string,string>> offeringSpecIdToAnswerTextMap = New Map<string,Map<string,string>>();
        Map<string,Map<string,List<string>>> offeringToSpecAndSpecValueMap = New Map<string,Map<string,List<string>>>();
        Map<id,PMP_Partner_Offering__c> updateOffMap = New Map<id,PMP_Partner_Offering__c>(); //cannot use a set or List here,
        //LOOP THROUGH AND PROCESS FOR EACH SOLUTION RECORD
        //Moved outside for loop as part of annual health
        List<Id> offeringIds_wc= new List<Id>();
            for(PMP_Partner_Offering__c off: responseOfferingMap.values()){
                offeringIds_wc.add(off.Id);
            }
        Map<Id, PMP_Partner_Offering__c> offMap= new Map<Id, PMP_Partner_Offering__c> ([Select id, PMP_Published_Copy_Id_Txt__c from PMP_Partner_Offering__c where id in:offeringIds_wc]);
        for(Id responseId : responseDetailMap.keySet()){
            List<string> tempCategoryIdSet = New List<string>();
            List<string> tempSpecIdSet = New List<string>();
            List<string> tempResourceURLList = New List<string>();
            List<string> tempSpecValueIdList = New List<string>();
            Set<string> sParentCategoryIdSet = New Set<string>();
            Map<string,List<string>> specSpecValueListMap = New Map<string,List<string>>();
            Map<string,string> specIdToAnswerTextMap = New Map<string,string>();
            
            Map<String, Schema.SObjectField> offeringFields = Schema.SObjectType.PMP_Partner_Offering__c.fields.getMap();
            boolean updateOffering = false;
            for(ArdiraSurvey__Question_Result__c responseQuestion :responseDetailMap.get(responseId) ){
                //if answer choices are present, question mapping is not required, we need to 
                //map choices to the taxonomy
                if(responseQuestion.ArdiraSurvey__Question_Result_Choices__r.size()>0){
                   for( ArdiraSurvey__Question_Result_Choice__c resultChoice : responseQuestion.ArdiraSurvey__Question_Result_Choices__r){
                        //if the choice has been mapped to a taxonomy by admin.
                        if(resultChoice.ArdiraSurvey__Answer_Choice__r.PSS_Related_Offering_Options_Txt__c != null && resultChoice.ArdiraSurvey__Answer_Choice__r.PSS_Related_Offering_Options_Txt__c != '' ){
                            List<string> relatedToList = resultChoice.ArdiraSurvey__Answer_Choice__r.PSS_Related_Offering_Options_Txt__c.split(',');
                            String sTempParentTaxonomyPIMId = resultChoice.ArdiraSurvey__Answer_Choice__r.PSS_Related_Parent_Taxonomy_Txt__c;
                            List<string> relatedToListId = new List<string>();
                            
                            //IF MAPPED CHOICES BELONG TO CATEGORY OBJECT
                            if(sPIMIdToTaxonomyIdCatMap.containsKey(relatedToList[0])){
                                for(String sPIMId : relatedToList)
                                {
                                    relatedToListId.add(sPIMIdToTaxonomyIdCatMap.get(sPIMId));
                                }
                                categoryIdSet.addAll(relatedToListId);
                                tempCategoryIdSet.addAll(relatedToListId);
                                sParentCategoryIdSet.add(sPIMIdToTaxonomyIdCatMap.get(sTempParentTaxonomyPIMId));
                            }
                            //IF MAPPED CHOICES BELONG TO SPECIFICATION OBJECT
                            else if(sPIMIdToTaxonomyIdSpecMap.containsKey(relatedToList[0])){
                                for(String sPIMId : relatedToList)
                                {
                                    relatedToListId.add(sPIMIdToTaxonomyIdSpecMap.get(sPIMId));
                                }
                                specIdSet.addAll(relatedToListId);
                                tempSpecIdSet.addAll(relatedToListId);
                            }
                            //IF MAPPED CHOICES BELONG TO SPECIFICATION VALUE OBJECT.Ex: Cloud Services with Google Cloud Platform and Alibaba Cloud
                            else if(sPIMIdToTaxonomyIdSpecValueMap.containsKey(relatedToList[0])){

                                for(String sPIMId : relatedToList)
                                {
                                    relatedToListId.add(sPIMIdToTaxonomyIdSpecValueMap.get(sPIMId));
                                }
                                specValueIdList.addAll(relatedToListId);
                                tempSpecValueIdList.addAll(relatedToListId);
                                sTempParentTaxonomyPIMId = sSpecValueIdToImmediateParentSpecPIM.get(relatedToListId[0]); // Get Parent Spec PIM of Spec Value                                
                                String sParentTaxonomyId = sImmediateParentSpecPIMToSpecIdMap.get(sTempParentTaxonomyPIMId);
                                
                                //ITERATING AND ADDING PARENT TAXONOMY ID FOR EACH SPEC VALUE MAPPED AGAINST A SINGLE CHOICE
                                for(String sSpecValueTaxonomyId : relatedToListId)
                                {
                                    specIdSet.add(sParentTaxonomyId);
                                    tempSpecIdSet.add(sParentTaxonomyId);
                                }
                                // ADDING IDs OF SPECIFICATIONS HIERARCHY OF THE SPEC VALUE PARENT TAXONOMY EXCEPT ROOT SPECIFICATION RECORD
                                // THIS WILL ADD MIXTURE OF SPECIFICATION AND SPECIFICATION VALUES UNDER SAME HIERARCHY IN OFFERING FOR SINGLE CHOICE SELECTED IN GET-M. Ex:- WAN with 3G,4G scenario 
                                if(sSpecIdToParentSpecsIdMap.containsKey(sParentTaxonomyId))
                                {
                                    List<String> sParentSpecsIdList = sSpecIdToParentSpecsIdMap.get(sParentTaxonomyId);
                                    // ADD THE HIERARCHY SPECIFICATIONS ID TO OVERALL LIST VARIABLE FOR FURTHER PROCESSING
                                    specIdSet.addAll(sParentSpecsIdList);
                                    tempSpecIdSet.addAll(sParentSpecsIdList);
                                }

                                //MAPPING EACH SPECIFICATION TO THIS LIST OF SPECIFICATION VALUES FOR ITERATING THE OFFERING SPECIFICATION RECORD WITH DIFFERENT SPECIFICATION VALUE
                                if(specSpecValueListMap.containsKey(sParentTaxonomyId))
                                {
                                    List<String> tempSpecValueList = specSpecValueListMap.get(sParentTaxonomyId);
                                    tempSpecValueList.addAll(relatedToListId);
                                    specSpecValueListMap.put(sParentTaxonomyId , tempSpecValueList);
                                }
                                else
                                {
                                    List<String> tempSpecValueList = New List<String>();
                                    tempSpecValueList.addAll(relatedToListId);
                                    specSpecValueListMap.put(sParentTaxonomyId , tempSpecValueList);
                                }

                            }
                            
                        }
                    }
                    //to map the offeringCategory or Specification to taxonomy
                    if(tempCategoryIdSet.size()>0){
                        tempCategoryIdSet.addAll(sParentCategoryIdSet);
                        categoryIdSet.addAll(sParentCategoryIdSet);
                        offeringCatMap.put(responseOfferingMap.get(responseId).id,tempCategoryIdSet );
                    }
                    if(tempSpecIdSet.size()>0){
                        offeringSpecMap.put(responseOfferingMap.get(responseId).id,tempSpecIdSet);
                    }
                    if(tempSpecValueIdList.size()>0)//MAP SPECIFICATION AND SPEC VALUE MAP TO THE OFFERING ID
                    {
                        offeringToSpecAndSpecValueMap.put(responseOfferingMap.get(responseId).id , specSpecValueListMap);
                    }
                }
                //IF QUESTION RESULT DONT HAVE CHOICES AND OFFERING FIELD MAPPING HAPPENED AT QUESTION RECORD LEVEL
                else if(responseQuestion.ArdiraSurvey__Question__r.PSS_Conversion_Taxonomy_Nm__c != sResourceObjectName && responseQuestion.ArdiraSurvey__Question__r.PSS_Offering_Nm__c != null 
                        && offeringFields.containsKey(responseQuestion.ArdiraSurvey__Question__r.PSS_Offering_Nm__c)
                       && ( (responseQuestion.ArdiraSurvey__Answer_Text__c != null && responseQuestion.ArdiraSurvey__Answer_Text__c != '') || (responseQuestion.ArdiraSurvey__Answer_Rich_Text__c != null && responseQuestion.ArdiraSurvey__Answer_Rich_Text__c != '') ) ){
                    PMP_Partner_Offering__c off = New PMP_Partner_Offering__c();
                    off = responseOfferingMap.get(responseId);
                    if(responseQuestion.ArdiraSurvey__Answer_Rich_Text__c != null && responseQuestion.ArdiraSurvey__Answer_Rich_Text__c != ''){

                        off.put(responseQuestion.ArdiraSurvey__Question__r.PSS_Offering_Nm__c, responseQuestion.ArdiraSurvey__Answer_Rich_Text__c );
                    }
                    else{ // if Answer Rich text not present, Grab the value from Answer Text

                        off.put(responseQuestion.ArdiraSurvey__Question__r.PSS_Offering_Nm__c, responseQuestion.ArdiraSurvey__Answer_Text__c );
                    }      
                    
                    responseOfferingMap.put(responseId,off); //updating the map
                    //name needs to be mapped to both Name field and   PMP_Offering_Field_Nm__custom field     
                   if(responseQuestion.ArdiraSurvey__Question__r.PSS_Offering_Nm__c =='PMP_Partner_Offering_Nm__c'){
                          string name = responseQuestion.ArdiraSurvey__Answer_Text__c;
                          off.Name = name.length() > 80 ? responseQuestion.ArdiraSurvey__Answer_Text__c.substring(0,80) :responseQuestion.ArdiraSurvey__Answer_Text__c ;//added by Krishna ch to fix Offering name to 80 charecters 
                          off.PMP_Partner_Offering_Nm__c = responseQuestion.ArdiraSurvey__Answer_Text__c;
                     }
                    //cant use a list or set,as for same record, we might be updating multiple fields,
                    //to avoid overwriting of filed values need a map   
                    updateOffMap.put(off.id, off); 
                    String pubCopyId=offMap.containsKey(off.id) && offMap.get(off.Id).PMP_Published_Copy_Id_Txt__c!=Null?offMap.get(off.Id).PMP_Published_Copy_Id_Txt__c:Null;
                    if(pubCopyId!=Null){
                        updateOffMap.put(pubCopyId, new PMP_Partner_Offering__c(Id=pubCopyId,Name=off.Name)); 
                    }
                    
                }
                //IF QUESTION RESULT DONT HAVE CHOICES AND TAXONOMY MAPPING HAPPENED AT QUESTION RECORD LEVEL
                else if(responseQuestion.ArdiraSurvey__Question__r.PSS_Conversion_Taxonomy_Nm__c != sResourceObjectName
                        && responseQuestion.ArdiraSurvey__Question__r.PSS_Related_Parent_Taxonomy_Txt__c != null && responseQuestion.ArdiraSurvey__Question__r.PSS_Related_Parent_Taxonomy_Txt__c != ''
                        && responseQuestion.ArdiraSurvey__Question__r.PSS_Related_Offering_Options_Txt__c != null && responseQuestion.ArdiraSurvey__Question__r.PSS_Related_Offering_Options_Txt__c != '')
                { // Handle when Question mapped to Taxonomy Objects

                    List<string> relatedToList = responseQuestion.ArdiraSurvey__Question__r.PSS_Related_Offering_Options_Txt__c.split(',');
                    String sTempParentTaxonomyPIMId = responseQuestion.ArdiraSurvey__Question__r.PSS_Related_Parent_Taxonomy_Txt__c;
                    List<string> relatedToListId = new List<string>();                    
                    if(sPIMIdToTaxonomyIdCatMap.containsKey(relatedToList[0])){
                        for(String sPIMId : relatedToList)
                        {
                            relatedToListId.add(sPIMIdToTaxonomyIdCatMap.get(sPIMId));
                        }
                        categoryIdSet.addAll(relatedToListId);
                        tempCategoryIdSet.addAll(relatedToListId);
                    }
                    else if(sPIMIdToTaxonomyIdSpecMap.containsKey(relatedToList[0])){
                        for(String sPIMId : relatedToList)
                        {
                            relatedToListId.add(sPIMIdToTaxonomyIdSpecMap.get(sPIMId));
                            specIdToAnswerTextMap.put(sPIMIdToTaxonomyIdSpecMap.get(sPIMId) , responseQuestion.ArdiraSurvey__Answer_Text__c);
                        }
                        specIdSet.addAll(relatedToListId);
                        tempSpecIdSet.addAll(relatedToListId);
                    }
                         
                    //to map the offeringCategory or Specification to taxonomy
                    if(tempCategoryIdSet.size()>0){
                        offeringCatMap.put(responseOfferingMap.get(responseId).id,tempCategoryIdSet );
                    }
                    if(tempSpecIdSet.size()>0){
                        offeringSpecMap.put(responseOfferingMap.get(responseId).id,tempSpecIdSet);
                    }
                    if(specIdToAnswerTextMap.values().size() > 0){

                        offeringSpecIdToAnswerTextMap.put(responseOfferingMap.get(responseId).id , specIdToAnswerTextMap);

                    }


                }
                //IF QUESTION MAPPED TO PARTNER OFFERING RESOURCE AND IT IS AN URL QUESTION
                else if(responseQuestion.ArdiraSurvey__Question__r.PSS_Conversion_Taxonomy_Nm__c == sResourceObjectName && responseQuestion.ArdiraSurvey__Answer_Text__c != '' && responseQuestion.ArdiraSurvey__Answer_Text__c != null)
                { // Handle when Question mapped to Partner Offering Resource Object
                    String sURLValue = responseQuestion.ArdiraSurvey__Answer_Text__c;
                    String requiredQuestion = PMP_Utility.getValue('Solution_URL_Question');
                    //String requiredQuestion = 'Provide a link to your solution or service offering. Please enter a valid URL beginning with http:// or https:// and with no more than 255 characters';
                    if( responseQuestion.ArdiraSurvey__Question_Text__c.contains(requiredQuestion)){
                        urlQuestionResourceMap.put(responseOfferingMap.get(responseId).id,sURLValue);
                    }
                    System.debug('My Question is  ::::: '+ urlQuestionResourceMap);
                    sResourceURLList.add(sURLValue);
                    tempResourceURLList.add(sURLValue);
                    if(tempResourceURLList.size() > 0)
                    {
                        offeringResourcesMap.put(responseOfferingMap.get(responseId).id , tempResourceURLList);
                    }
                    System.debug('Offering Resource Map ::::'+offeringResourcesMap);

                }
            }
        }//FOR LOOP END FOR ALL SOLUTIONS
        // HANDLE INSERTING THE PARTNER OFFERING CATEGORY RECORDS
        if(categoryIdSet.size()>0){
            //get all the necessary taxonomy
            Map<id, PMP_Category__c> catDetails = New Map<id,PMP_Category__c>([Select id, Name,PMP_Ancestor_Category_Cd__c,
                                                PMP_Partner_Product_Category_Cd__c
                                                from PMP_Category__c where id IN : categoryIdSet  ]);
            for(string offId :offeringCatMap.keySet() ){
                //default categories for each offering               
                
                for(id catId : offeringCatMap.get(offId)){
                    if(catDetails.containsKey(catId))
                    {

                    PMP_Partner_Offering_Category__c offCat = New PMP_Partner_Offering_Category__c();
                    offCat.Name = catDetails.get(catId).Name;
                    offCat.PMP_Category_Id__c = catDetails.get(catId).Id;
                    offCat.PMP_Offering_Id__c = offId;
                    offCat.PMP_Ancestor_Category_Cd__c = catDetails.get(catId).PMP_Ancestor_Category_Cd__c;
                    offCat.PMP_Offering_Category_External_Key__c = catDetails.get(catId).PMP_Partner_Product_Category_Cd__c;
                    offCategoryList.add(offCat);

                    }
                }
            }

            if(offCategoryList.size() > 0 && Schema.sObjectType.PMP_Partner_Offering_Category__c.isCreateable())
            {
                Set<PMP_Partner_Offering_Category__c> offCategorySet = new Set<PMP_Partner_Offering_Category__c>();
                offCategorySet.addAll(offCategoryList); // Remove Duplicates in Partner Offering Category Records.
                List<PMP_Partner_Offering_Category__c> offCategoryUniqueList = new List<PMP_Partner_Offering_Category__c>();
                offCategoryUniqueList.addAll(offCategorySet);
                insert offCategoryUniqueList;
            }
        }
        // HANDLE INSERTING THE PARTNER OFFERING SPECIFICATION RECORDS ALONG WITH SPECIFICATION VALUE
        if(specIdSet.size()>0){
            Map<id,PMP_Specification__c> specDetails =New Map<id,PMP_Specification__c>([Select id, Name,PMP_Ancestor_Specification_Cd__c,PMP_Display_Type_Nm__c,
                                                        PMP_Partner_Product_Specification_Id__c         
                                                      from PMP_Specification__c where id IN : specIdSet  ]);
            for(string offId :offeringSpecMap.keySet()){
                Boolean sSpecValuePresent = false;
                Map<string,List<string>> sTempspecSpecValueListMap = New Map<string,List<string>>();
                Map<string,string> sTempSpecIdToAnswerTextMap = New Map<string,string>();
                if(offeringToSpecAndSpecValueMap.containsKey(offId))
                {
                    sTempspecSpecValueListMap = offeringToSpecAndSpecValueMap.get(offId);
                    sSpecValuePresent = true;
                }
                if(offeringSpecIdToAnswerTextMap.containsKey(offId))
                {
                    sTempSpecIdToAnswerTextMap = offeringSpecIdToAnswerTextMap.get(offId);
                }
                for(id specId : offeringSpecMap.get(offId)){

                    if(specDetails.containsKey(specId))
                    {

                        PMP_Partner_Offering_Specification__c offSpec = New PMP_Partner_Offering_Specification__c();
                        offSpec.Name = specDetails.get(specId).Name;
                        offSpec.PMP_Specification_Id__c = specDetails.get(specId).Id;
                        offSpec.PMP_Offering_Id__c = offId;
                        offSpec.PMP_Display_Type_Nm__c = specDetails.get(specId).PMP_Display_Type_Nm__c;
                        offSpec.PMP_Ancestor_Specification_Cd__c = specDetails.get(specId).PMP_Ancestor_Specification_Cd__c;
                        offSpec.PMP_Product_Specification_Cd__c = specDetails.get(specId).PMP_Partner_Product_Specification_Id__c;
                        offSpec.PMP_Specification_Nm__c = specDetails.get(specId).Name;

                        if(sSpecValuePresent == true && sTempspecSpecValueListMap.containsKey(specId))
                        {
                            List<string> sSpecValues = sTempspecSpecValueListMap.get(specId);
                            String sSpecValueIdForAssociation = null; // Declared Null to Nullify Spec Value Lookup in case of adding Parent Specification of Spec Value
                            String sSpecValueForAssociation = '';
                            if(sSpecValues.size() > 0)
                            {
                                sSpecValueIdForAssociation = sSpecValues.remove(0);
                                sSpecValueForAssociation = sSpecValueIdToSpecValueMap.get(sSpecValueIdForAssociation);
                                sTempspecSpecValueListMap.put(specId,sSpecValues);
                            }
                            offSpec.PMP_Specification_Value_Id__c = (Id) sSpecValueIdForAssociation;
                            offSpec.PMP_Specification_Value_Cd__c = sSpecValueForAssociation;
                        }
                        else
                        {
                            offSpec.PMP_Specification_Value_Cd__c = sTempSpecIdToAnswerTextMap.get(specId);
                        }

                        offSpecList.add(offSpec);

                    }
                }
            } 
           if(offSpecList.size() > 0 && PMP_Partner_Offering_Specification__c.SObjectType.getDescribe().isCreateable())
            {   
                Set<PMP_Partner_Offering_Specification__c> offSpecSet = new Set<PMP_Partner_Offering_Specification__c>();
                offSpecSet.addAll(offSpecList); // Remove Duplicates in Partner Offering Specification Records.Cannot do using Set at beginnning since Duplicate Specification Id has to be iterated for different Spec Values
                List<PMP_Partner_Offering_Specification__c> offSpecUniqueList = new List<PMP_Partner_Offering_Specification__c>();
                offSpecUniqueList.addAll(offSpecSet);
                insert offSpecUniqueList;
            }
        }

        // INSERT PARTNER OFFERING RESOURCES RECORD FOR EACH OFFERING FOR URL QUESTIONS ALONE.
        if(sResourceURLList.size() > 0)
        {
            for(string offId : offeringResourcesMap.keySet())
            {
                for(string sURL : offeringResourcesMap.get(offId))
                {
                    PMP_Partner_Offering_Resource__c offeringResource = New PMP_Partner_Offering_Resource__c();
                    
                    offeringResource.PMP_Offering_Id__c = offId;
                    offeringResource.PMP_Resource_Type_Nm__c = PMP_StaticConstants_Offering.Others;
                    offeringResource.PMP_Partner_Offering_Resource_URL_Txt__c = sURL.length() > 255 ? sURL.substring(0,255):sURL ;//add by krishna ch as part of max charecter lenght fix.
                    offeringResource.Name = 'Marketing Collateral';
                    
                    if(urlQuestionResourceMap.containsKey(offId)){
                        offeringResource.PMP_Resource_Type_Nm__c = PMP_StaticConstants_Offering.URL;
                    	offeringResource.Name = PSS_StaticConstants.Offering_Web_Page;
                    }                                                                                                     
                    resourceList.add(offeringResource);
                }
            }

            if(resourceList.size() > 0 && Schema.sObjectType.PMP_Partner_Offering_Resource__c.isCreateable())
            {
                insert resourceList;
            }
        }
        
        if(updateOffMap.values().size()> 0){
            update updateOffMap.values();
        }
  
  
  
    }

}
*/