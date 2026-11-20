/*************************************************************************************************************************************************************************
* Class Name  : PSS_SolutionMappingController 
* Version     : 1.0 
* Created Date: 4/06/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX              M-01    : Original version       4/06/2021                         Mapping class used by admin
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public without sharing class PSS_SolutionMappingController {

     /**
    * @description method to questions which are answered for a solution    
    * @param void 
    * @return Map<string,List<object>> responseMap 
    **/
    // @AuraEnabled
    // public static Map<String, List<Object>> getQuestions() {
    //     Map<String, List<Object>> responseMap = new Map<String, List<Object>>();
    
    //     // Get active survey ID
    //     String activeSurveyId = getActiveSurveyId();
    
    //     // Fetch questions
    //     List<ArdiraSurvey__Question__c> questionsList = getSurveyQuestions(activeSurveyId);
    
    //     // Process questions and choices
    //     List<questionWrapper> finalQuestionWrapperList = processQuestions(questionsList);
    
    //     // Get top categories and specs
    //     List<Object> topTaxonomy = new List<Object>();
    //     topTaxonomy.addAll(getTopCategory());
    //     topTaxonomy.addAll(getTopSpecs());
    
    //     // Populate response map
    //     responseMap.put('questions', (List<Object>)finalQuestionWrapperList);
    //     responseMap.put('topTaxonomy', topTaxonomy);
    //     responseMap.put('offeringFields', (List<Object>)getOfferingField());
    
    //     return responseMap;
    // }
    
    // // Helper methods
    
    // // Retrieve active survey ID
    // private static String getActiveSurveyId() {
    //     if (Test.isRunningTest()) {
    //         ArdiraSurvey__Survey__c survey = [SELECT Id FROM ArdiraSurvey__Survey__c LIMIT 1];
    //         return survey.Id;
    //     } else {
    //         PMP_Static_Data__mdt sPMPStaticMetadata = [SELECT Id, Value__c FROM PMP_Static_Data__mdt WHERE DeveloperName = 'PSS_Survey_RecordId' LIMIT 1];
    //         return sPMPStaticMetadata.Value__c;
    //     }
    // }
    
    // // Retrieve questions for the active survey
    // private static List<ArdiraSurvey__Question__c> getSurveyQuestions(String activeSurveyId) {
    //     return [SELECT Id, ArdiraSurvey__Question__c, ArdiraSurvey__Type__c,
    //             (SELECT Id, Name, ArdiraSurvey__Choice_Label__c, PSS_Related_Offering_Options_Txt__c, PSS_Related_Parent_Taxonomy_Txt__c
    //              FROM ArdiraSurvey__Answer_Choices__r)
    //             FROM ArdiraSurvey__Question__c
    //             WHERE ArdiraSurvey__Survey__r.Id = :activeSurveyId AND ArdiraSurvey__Type__c != :PSS_StaticConstants.SURVEY_QUESTION_THANKS_TYPE 
    //             ORDER BY ArdiraSurvey__Display_Order__c];
    // }
    
    // // Process questions and choices
    // private static List<questionWrapper> processQuestions(List<ArdiraSurvey__Question__c> questionsList) {
    //     Set<String> topTaxonomySet = new Set<String>();
    //     Set<String> selectedChildren = new Set<String>();
    //     List<questionWrapper> finalQuestionWrapperList = new List<questionWrapper>();
    //     List<questionWrapper> mappedQuestions = new List<questionWrapper>();
    
    //     for (ArdiraSurvey__Question__c question : questionsList) {
    //         questionWrapper questWrapper = new questionWrapper();
    //         questWrapper.Label = question.ArdiraSurvey__Question__c;
    //         questWrapper.Id = question.Id;
    //         questWrapper.questionType = question.ArdiraSurvey__Type__c;
    
    //         List<questionChoice> questChoice = new List<questionChoice>();
    //         boolean addQuestion = true;
    
    //         for (ArdiraSurvey__Answer_Choice__c choice : question.ArdiraSurvey__Answer_Choices__r) {
    //             questionChoice choiceWrapper = new questionChoice();
    //             choiceWrapper.Label = choice.ArdiraSurvey__Choice_Label__c;
    //             choiceWrapper.Id = choice.Id;
    //             choiceWrapper.selectedTopTaxonomy = choice.PSS_Related_Parent_Taxonomy_Txt__c;
    //             choiceWrapper.selectedChildTaxonomy = choice.PSS_Related_Offering_Options_Txt__c;
    //             questChoice.add(choiceWrapper);
    
    //             if (choice.PSS_Related_Parent_Taxonomy_Txt__c != null && choice.PSS_Related_Offering_Options_Txt__c != null) {
    //                 topTaxonomySet.add(choice.PSS_Related_Parent_Taxonomy_Txt__c);
    //                 selectedChildren.addAll(choice.PSS_Related_Offering_Options_Txt__c.split(','));
    //                 addQuestion = false;
    //             }
    //         }
    
    //         questWrapper.choices = questChoice;
    
    //         if (addQuestion) {
    //             finalQuestionWrapperList.add(questWrapper);
    //         } else {
    //             mappedQuestions.add(questWrapper);
    //         }
    //     }
    
    //     // Further processing for mapped questions
    //     processMappedQuestions(mappedQuestions, topTaxonomySet);
    
    //     return finalQuestionWrapperList;
    // }
    
    // // Process mapped questions
    // private static void processMappedQuestions(List<questionWrapper> mappedQuestions, Set<String> topTaxonomySet) {
    //     Map<String, List<Object>> taxonomyAndChildValues = fetchChildren(topTaxonomySet);
    //     Map<String, String> taxonomyIdName = getTaxonomyIdNameMap(taxonomyAndChildValues);
    
    //     for (questionWrapper question : mappedQuestions) {
    //         List<mappingByName> mappingsNameList = new List<mappingByName>();
    //         List<questionChoice> updatedChoice = new List<questionChoice>();
    
    //         for (questionChoice choice : question.choices) {
    //             if (choice.selectedTopTaxonomy != null && choice.selectedChildTaxonomy != null) {
    //                 List<Object> offeringOptions = taxonomyAndChildValues.get(choice.selectedTopTaxonomy);
    //                 choice.offeringOptions = offeringOptions;
    
    //                 String mappingName = buildMappingName(choice.selectedChildTaxonomy, taxonomyIdName);
                    
    //                 mappingByName mapByName = new mappingByName();
    //                 mapByName.Label = choice.Label;
    //                 mapByName.SelectedTaxonomy = mappingName;
    //                 mappingsNameList.add(mapByName);
    //                 updatedChoice.add(choice);
    //             } else {
    //                 updatedChoice.add(choice);
    //                 mappingsNameList.add(new mappingByName());
    //             }
    //         }
    
    //         question.choices = updatedChoice;
    //         question.mappedChoicesByName = mappingsNameList;
    //     }
    // }
    
    // // Helper method to build the mapping name
    // private static String buildMappingName(String selectedChildTaxonomy, Map<String, String> taxonomyIdName) {
    //     String mappingName = '';
    //     for (String str : selectedChildTaxonomy.split(',')) {
    //         mappingName += (mappingName != '' ? ',' : '') + taxonomyIdName.get(str);
    //     }
    //     return mappingName;
    // }
    
    // // Helper method to create the map of taxonomy IDs and names
    // private static Map<String, String> getTaxonomyIdNameMap(Map<String, List<Object>> taxonomyAndChildValues) {
    //     Map<String, String> taxonomyIdName = new Map<String, String>();
    //     for (String str : taxonomyAndChildValues.keySet()) {
    //         for (Object taxonomy : taxonomyAndChildValues.get(str)) {
    //             SObject tax = (SObject)taxonomy;
    //             taxonomyIdName.put((String)tax.get('Id'), (String)tax.get('Name'));
    //         }
    //     }
    //     return taxonomyIdName;
    // }
    
    

    // /**
    // * @description Method to get top level category data
    // * @param void 
    // * @return List<taxonomy>
    // **/
    // public static List<taxonomy> getTopCategory(){
    //     List<taxonomy> catList = New List<taxonomy>();
    //     if(Schema.sObjectType.PMP_Category__c.isAccessible()){
    //         for(PMP_category__c cat :[select name,PMP_Partner_Product_Category_Cd__c,id  from pmp_Category__c where PMP_Parent_Category_Id__c = null 
    //                               and PMP_Active_Ind__c = true and PMP_Partner_Product_Category_Cd__c  != 'NPP_01_TYPE'] ){
    //                                   taxonomy categoryTax = New taxonomy();
    //                                   categoryTax.name = cat.name;
    //                                   categoryTax.pimId = cat.PMP_Partner_Product_Category_Cd__c;                           
    //                                   catList.add(categoryTax);	
    //                               }
    //     }
    //     return  catList;  
    // }

    // /**
    // * @description Method to get all active specifications data
    // * @param void 
    // * @return List<taxonomy>
    // **/
    // public static List<taxonomy> getTopSpecs(){
    //     List<taxonomy> specList = New List<taxonomy>();
    //     if(Schema.sObjectType.pmp_specification__c.isAccessible()){
    //         for(pmp_specification__c spec : [select name,id,PMP_Partner_Product_Specification_Id__c 
    //                                      from pmp_specification__c where 
    //                                      PMP_Parent_specification_Id__c = null and PMP_Active_Ind__c = true ]){
    //                                          taxonomy specTax = New taxonomy();
    //                                          specTax.name = spec.name;
    //                                          specTax.pimId = spec.PMP_Partner_Product_Specification_Id__c;                           
    //                                          specList.add(specTax);	        	
    //                                      }
    //         }
    //     return specList;
    // }

    //  /**
    // * @description Method to get offering related fields
    // * @param void 
    // * @return List<field>
    // **/
    // public static List<field> getOfferingField(){
    //     List<string> offeringFieldList = New List<string>{'PMP_Partner_Offering_Nm__c', 'PMP_Partner_Offering_Dsc__c',
    //         'PMP_Partner_Offering_Tag_Line_Txt__c','PMP_Partner_Offering_Start_Dt__c',
    //         'PMP_Partner_Offering_End_Dt__c'};
                
    //     Map<String, Schema.SObjectField> obj = Schema.SObjectType.PMP_Partner_Offering__c.fields.getMap();
    //     List<field> fieldList = New List<field>(); 
    //     for(string iterField : offeringFieldList){
    //         Field fld = New field();
    //         fld.Name= obj.get(iterField).getDescribe().getLabel();
    //         fld.apiName = iterField;
    //         fld.objectApiName = 'PMP_Partner_Offering__c';
    //         fieldList.add(fld);
    //     }
    //     return fieldList;
    // }

    
    // /**
    // * @description Method to get child taxonomy records
    // * @param String parentId
    // * @return List<Object>
    // **/
    // @auraEnabled   
    // public static List<Object> getChildTaxonomies(string parentId){
    //     List<object> response = New List<object>();
    //     if(parentId  == 'NPP_01_APP' || parentId=='NPP_01_Industry' ){
            
    //         string pimId = parentId + '%';
    //         response = (List<object>)[Select Name, id from PMP_Category__c where PMP_Ancestor_Category_Cd__c
    //                                   like : pimId ];
    //     }
    //     else{
            
    //         string pimId = parentId+ '%';
    //         response = (List<object>)[Select Name, id from PMP_Specification__c where PMP_Ancestor_Specification_Cd__c
    //                                   like : pimId ];
    //     } 
    //     return response;
    // }

    // /**
    // * @description Method to save the mapping to optionsMap
    // * @param String parentId
    // * @return void
    // **/    
    // @AuraEnabled
    // public static void saveProposalMapping(mappingData data ){
    //     if(data.mappedChoices != null){
    //         List<ArdiraSurvey__Answer_Choice__c> choicesToUpdate = data.mappedChoices;
    //         if(Schema.sObjectType.ArdiraSurvey__Answer_Choice__c.isUpdateable()) {
    //             update choicesToUpdate;  
    //         }
            
    //     }
    //     if(data.mappedQuestion!=null){
    //         ArdiraSurvey__Question__c question= data.mappedQuestion;
    //         if(Schema.sObjectType.ArdiraSurvey__Question__c.isUpdateable()) {
    //             update question;
    //         }
            
    //     }
        
    // }
    
    // /**
    // * @description Method to fetch the child taxonomies when mapping is already present,
    // *              we need to pre populate the fields on UI for which this method is used
    // * @param set<string> pimIdSet
    // * @return Map<string, List<object>> pimIdTaxonomyMap
    // **/
    // public static Map<String, List<Object>> fetchChildren(Set<String> pimIdSet) {
    //     Set<String> catPimIds = new Set<String>();
    //     Set<String> specPimIds = new Set<String>();
    //     Map<String, List<Object>> pimIdTaxonomyMap = new Map<String, List<Object>>();
    
    //     // Categorize PIM IDs
    //     categorizePimIds(pimIdSet, catPimIds, specPimIds);
    
    //     // Fetch categories and specifications
    //     fetchCategories(catPimIds, pimIdTaxonomyMap);
    //     fetchSpecifications(specPimIds, pimIdTaxonomyMap);
    
    //     return pimIdTaxonomyMap;
    // }
    
    // // Helper method to categorize PIM IDs into categories and specifications
    // private static void categorizePimIds(Set<String> pimIdSet, Set<String> catPimIds, Set<String> specPimIds) {
    //     for (String pimId : pimIdSet) {
    //         if (pimId == 'NPP_01_APP' || pimId == 'NPP_01_Industry') {
    //             catPimIds.add(pimId);
    //         } else {
    //             specPimIds.add(pimId);
    //         }
    //     }
    // }
    
    // // Helper method to fetch categories
    // private static void fetchCategories(Set<String> catPimIds, Map<String, List<Object>> pimIdTaxonomyMap) {
    //     if (catPimIds.size() > 0 && Schema.sObjectType.PMP_Category__c.isAccessible()) {
    //         for (PMP_Category__c category : [SELECT Name, Id, PMP_Ancestor_Category_Cd__c FROM PMP_Category__c
    //                                          WHERE PMP_Ancestor_Category_Cd__c LIKE :catPimIds]) {
    //             String key = category.PMP_Ancestor_Category_Cd__c.contains('|') ? category.PMP_Ancestor_Category_Cd__c.substringBefore('|') : category.PMP_Ancestor_Category_Cd__c;
    //             updateTaxonomyMap(key, category, pimIdTaxonomyMap);
    //         }
    //     }
    // }
    
    // // Helper method to fetch specifications
    // private static void fetchSpecifications(Set<String> specPimIds, Map<String, List<Object>> pimIdTaxonomyMap) {
    //     if (specPimIds.size() > 0 && Schema.sObjectType.PMP_Specification__c.isAccessible()) {
    //         for (PMP_Specification__c spec : [SELECT Name, Id, PMP_Ancestor_Specification_Cd__c FROM PMP_Specification__c
    //                                            WHERE PMP_Ancestor_Specification_Cd__c LIKE :specPimIds]) {
    //             String key = spec.PMP_Ancestor_Specification_Cd__c.contains('|') ? spec.PMP_Ancestor_Specification_Cd__c.substringBefore('|') : spec.PMP_Ancestor_Specification_Cd__c;
    //             updateTaxonomyMap(key, spec, pimIdTaxonomyMap);
    //         }
    //     }
    // }
    
    // // Helper method to update taxonomy map
    // private static void updateTaxonomyMap(String key, Object record, Map<String, List<Object>> pimIdTaxonomyMap) {
    //     if (pimIdTaxonomyMap.containsKey(key)) {
    //         List<Object> objList = pimIdTaxonomyMap.get(key);
    //         objList.add(record);
    //         pimIdTaxonomyMap.put(key, objList);
    //     } else {
    //         List<Object> objList = new List<Object>();
    //         objList.add(record);
    //         pimIdTaxonomyMap.put(key, objList);
    //     }
    // }
    
    // public class Field{
    //     @AuraEnabled public string name{get;set;}
    //     @AuraEnabled public string apiName{get;set;}
    //     @AuraEnabled public string objectApiName{get;set;}
        
    // } 
    
    // //Wrapper class to store mapping data
    // public class MappingData{
    //     @AuraEnabled public ArdiraSurvey__Question__c mappedQuestion{get;set;}
    //     @AuraEnabled public List<ArdiraSurvey__Answer_Choice__c> mappedChoices{get;set;}
    // }

    // //wrapper class to store taxonomy name and id
    // public class Taxonomy{
    //     @AuraEnabled public string name{get;set;}
    //     @AuraEnabled public string pimId{get;set;}
    // }

    // // wrapper class to store question related data
    // public class QuestionWrapper{
    //     @AuraEnabled public string label{get;set;}
    //     @AuraEnabled public string id{get;set;}
    //     @AuraEnabled public string questionType{get;set;}
    //     @AuraEnabled public List<questionChoice> choices{get;set;}
    //     @AuraEnabled public List<mappingByName> mappedChoicesByName{get;set;} //for displaying mapped options
    // }
    // // wrapper class to store question choice
    // public class QuestionChoice{
    //     @AuraEnabled public string label{get;set;}
    //     @AuraEnabled public string id{get;set;}
    //     @AuraEnabled public string selectedTopTaxonomy{get;set;}
    //     @AuraEnabled public string selectedChildTaxonomy{get;set;}
    //     @AuraEnabled public List<object> offeringOptions{get;set;}
    // }
    // //wrapper class to pre-populate taxonomy data in edit scenario
    // public class MappingByName{
    //     @AuraEnabled public string label{get;set;} 
    //     @AuraEnabled public string selectedTaxonomy{get;set;}
    // }   
}