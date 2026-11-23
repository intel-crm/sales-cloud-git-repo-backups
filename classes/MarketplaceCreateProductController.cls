// //IPA 2.0 TWC729-7887-need to remove class and aura
 public class  MarketplaceCreateProductController {
      public static Boolean isWorking() {
        return true;
    }
 }

//     public class  MarketplaceCreateProductController {
    
//     @AuraEnabled(cacheable=true)
//     public static Intel_WizardData buildResponse(PMP_Partner_Offering__c offering,string selectedLanguage) {
//         Intel_WizardData response = new Intel_WizardData();
//         // FormData represents the current state of the form and all its values
//         Intel_FormData formData = new Intel_FormData();
//         formData.offering = offering;
//         Map<string, List<Intel_SpecificationDataWrapper>> specifications = New Map<string, List<Intel_SpecificationDataWrapper>>();
//         Map<string, List<string>> specification_smpl = New Map<string, List<string>>();
//         Map<string,string> specification_txt = New Map<string,string>();
//         //Intel_ProductWebPageDataWrapper webPageData = new Intel_ProductWebPageDataWrapper();
//         formData.specifications = specifications;
//         formData.company=new Map<String, Intel_SpecificationDataWrapper>();
//         formData.specification_smplTab1 = specification_smpl;
//         formData.specification_smplTab2 = specification_smpl;
//         formData.specification_smplTab3 = specification_smpl;
//         formData.specification_txtTab1 = specification_txt;
//         formData.specification_txtTab2 = specification_txt;
//         formData.specification_txtTab3 = specification_txt;
//         formData.specification_cmplxTab1 = specifications;
//         formData.specification_cmplxTab2 = specifications;
//         formData.specification_cmplxTab3 = specifications;
//         formData.industryAndApplication = specifications;
//         formData.categoryAndSubCategory = specifications;
//         //adding productwebpage data to response
//         formData.productWebPageData = PMP_OfferingResourceHelper.getProductWebPageData(offering.Id);
//         //adding additional resources data to response
//         formData.resources = PMP_OfferingResourceHelper.getAdditionalResources(offering.Id);
        
//         // TODO Add relevant other fields to formData here
//         // formData.selectedCategories ....
        
//         response.formData = formData;
//         /* Prakash response.activeStep = Integer.valueOf(offering.PMP_Active_Step_Txt__c);
// response.currentStep = Integer.valueOf(offering.PMP_Current_Step_Txt__c); */
//         // Null checks needed
//         response.activeStep = !String.isBlank(offering.PMP_Active_Step_Txt__c) ? Integer.valueOf(offering.PMP_Active_Step_Txt__c) : 0;
//         response.currentStep = !String.isBlank(offering.PMP_Current_Step_Txt__c) ? Integer.valueOf(offering.PMP_Current_Step_Txt__c) : 0;
        
//         response.category = offering.PMP_Category_nm__c;
//         response.steps = new List<Intel_Step>();
        
//         //GET OFFERING INFO(CDNA NUMBER)
        
//         List<PMP_Partner_Offering_Category__c> offeringCategories = new List<PMP_Partner_Offering_Category__c>();
        
//         //POC - Specifications
//         if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
//             offeringCategories  = [Select Name,PMP_Offering_Category_External_Key__c, PMP_Category_Id__r.Type__c
//                                    from PMP_Partner_Offering_Category__c
//                                    Where PMP_Offering_Id__c =: offering.id];
//         }   
//         List<string> categoryList = new List<string>();
//         final String categoryPIMId;
//         if(offeringCategories.size() > 0  ){
//             for(PMP_Partner_Offering_Category__c offeringCat : offeringCategories  ){
//                 categoryList.add(offeringCat.PMP_Offering_Category_External_Key__c);
//                 /*Added by raj to get the PIM Id of the category selected on tab0*/
//                 if(offeringCat.Name == offering.PMP_Category_nm__c && offeringCat.PMP_Category_Id__r.Type__c == 'Category'){
//                     categoryPIMId = offeringCat.PMP_Offering_Category_External_Key__c;
//                     //system.debug('#####piMID--->'+categoryPIMId);
//                 }
//                 /*--------------------Changes End-----------------------------*/
//             }
//         }
        
//         //system.debug('#####piMID2--->'+categoryList);
        
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specValues = New List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
//         specValues = PMP_SpecificationController.getOfferingSpecificationList(categoryList,null,selectedLanguage);
        
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecs> step1SpecList = new List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecs> step2SpecList = new List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecs> step3SpecList = new List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
        
//         List<PMP_Specifications_Tab_Mapping__mdt> stepConfigurations = [Select label,Accordion_Type__c,PMP_Field_Label__c, isAccordion__c, isSearchable__c,
//                                                                         tab__c,Show_Select_All__c,Interaction_Type__c,PMP_Is_Create_Offering_Ind__c, LayoutItem_Size__c, is_Inline_Radio__c from PMP_Specifications_Tab_Mapping__mdt where PMP_Is_Create_Offering_Ind__c=true];
//         Map<String, PMP_Specifications_Tab_Mapping__mdt> stepConfigurationsMap = New Map<String, PMP_Specifications_Tab_Mapping__mdt>();
        
        
//         for(PMP_Specifications_Tab_Mapping__mdt iterMetaData : stepConfigurations ){
            
//             stepConfigurationsMap.put(iterMetaData.label, iterMetaData);
//         }
//         for(PMP_SpecificationController.Core_PMP_OfferingSpecs specification : specValues) {
            
//             string tab ='';
//             if(stepConfigurationsMap.get(specification.specId)!=null){
//                 tab=stepConfigurationsMap.get(specification.specId).tab__c;
//             }
//             //system.debug('tab:'+stepConfigurationsMap);
//             //system.debug('tab2:'+specification.specId);
//             //system.debug('tab3:'+stepConfigurationsMap.get(specification.specId));
            
            
//             if(tab!=null && tab == 'Tab1'){
//                 step1SpecList.add(specification);
//             }
//             else if(tab!=null && tab == 'Tab2'){
//                 step2SpecList.add(specification);
//             }
//             else if(tab!=null && tab == 'Tab3') {
//                 step3SpecList.add(specification);
//             }
//         }
        
//         //Added by Shahrukh : Prepopulation of selected Geo Regions and End Customer Type US364094
//         //Abhishek --> getting it out of getSpecificationSubsection of UI generator to avoid query in loop and re-usability.
//         set<string> offSpecSet = new set<string>();
//         map<string,string> specValDataMap = new map<string,string>();
//         map<string,List<string>> specValListMap = new map<string,List<string>>();
//         List<PMP_Partner_Offering_Specification__c> offeringSpecList = new List<PMP_Partner_Offering_Specification__c>();
//         if(offering.Id!=null && Schema.sObjectType.PMP_Partner_Offering_Specification__c.isAccessible()){
            
//             offeringSpecList = [select id,PMP_Product_Specification_Cd__c,PMP_Specification_Value_Nm__c,PMP_Specification_Value_Cd__c,PMP_Offering_Id__c ,
//                                 PMP_Specification_Value_Id__c, PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c,
//                                 PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Key__c
//                                  from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering.Id];
//             //Checking if there are any selected specifications
//             if(!offeringSpecList.isEmpty()){
//                 //Looping through all the selected specifications and populating the PIM id values in the set
//                 for(PMP_Partner_Offering_Specification__c offSpec : offeringSpecList){
//                     offSpecSet.add(offSpec.PMP_Product_Specification_Cd__c); //Adding PIM Id in the set, This set will contain unique PIM Ids
//                     if(offSpec.PMP_Specification_Value_Cd__c!=null && offSpec.PMP_Specification_Value_Cd__c!='' && offSpec.PMP_Specification_Value_Id__c == null){
//                         offSpecSet.add(offSpec.PMP_Specification_Value_Cd__c);
//                         specValDataMap.put(offSpec.PMP_Product_Specification_Cd__c,offSpec.PMP_Specification_Value_Cd__c);
//                     }
//                     else if(offSpec.PMP_Specification_Value_Cd__c!=null && offSpec.PMP_Specification_Value_Cd__c!='' && offSpec.PMP_Specification_Value_Id__c != null){
//                         if(!specValListMap.isEmpty() && specValListMap.get(offSpec.PMP_Product_Specification_Cd__c)!= null){
//                             List<string> valueList = specValListMap.get(offSpec.PMP_Product_Specification_Cd__c);
//                             valueList.add(offSpec.PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Key__c);
//                             specValListMap.put(offSpec.PMP_Product_Specification_Cd__c, valueList);
//                         }
//                         else{
//                             List<string> valueList = New List<string>{offSpec.PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Key__c};
//                                 specValListMap.put(offSpec.PMP_Product_Specification_Cd__c, valueList);
//                         }
                        
//                     }
//                 }
//             }
//         }
        
//         //POC - Specifications
        
//         // STEP 1: Offering Details
//         //system.debug('**************response.category*************');
        
//         Intel_Step step1 = PMP_CreateOfferingTab1Service.getOfferingDetailsInputs(System.Label.PMP_Create_Offering_Form_STEP1,categoryPIMId,
//                                                                                   step1SpecList, stepConfigurationsMap, offering, offSpecSet,specValDataMap,specValListMap,selectedLanguage );
        
//         //new Intel_Step(System.Label.PMP_Create_Offering_Form_STEP1);
        
//         // STEP 2: Intel Technologies
//         Intel_Step step2 =  PMP_CreateOfferingTab2Service.getOfferingDetailsInputs(System.Label.PMP_Create_Offering_Form_STEP2,step2SpecList,stepConfigurationsMap, offering, offSpecSet,specValDataMap,specValListMap);
//         //Intel_Step step2 = new Intel_Step(System.Label.PMP_Create_Offering_Form_STEP2);
//         // STEP 3: Specifications
//         // Intel_Step step3 = new Intel_Step(System.Label.PMP_Create_Offering_Form_STEP3);
//         Intel_Step step3 =  PMP_CreateOfferingTab3Service.getOfferingDetailsInputs(System.Label.PMP_Create_Offering_Form_STEP3,step3SpecList, stepConfigurationsMap,offering, offSpecSet,specValDataMap,specValListMap);
//         // STEP 4: Resources 
//         Intel_Step step4 = PMP_CreateOfferingTab4Service.getResourcesInputs(System.Label.PMP_Create_Offering_Form_STEP4,offering); 
//         //new Intel_Step(System.Label.PMP_Create_Offering_Form_STEP4);
        
//         Intel_Step step5 = new Intel_Step(System.Label.PMP_Create_Offering_Form_STEP5);
        
        
        
        
        
//         response.steps.add(step1);
//         response.steps.add(step2);
//         response.steps.add(step3); 
//         response.steps.add(step4);
//         response.steps.add(step5);
        
        
//         //Gireesh
//         //Get public group members
//         Group grp=[SELECT Id FROM Group where DeveloperName='PMP_All_Intel_Admin_Users' LIMIT 1];
        
//         if (grp!=Null){
//             List<GroupMember> groupMembers=[SELECT UserOrGroupId FROM GroupMember where GroupId=:grp.Id];
//             List<Id> userIds=new List<Id>();
//             for (GroupMember groupMember: groupMembers){
//                 userIds.add(groupMember.UserOrGroupId);
//             }
            
//             //Add Admin Review Tab for admins
//             if(userIds.contains(userinfo.getUserId())){
//                 Intel_Step step6 = new Intel_Step(System.Label.PMP_Admin_Review);  //Adding Step 6 if the user name is as per mentioned in above condition.
//                 response.steps.add(step6);
//             }
//         }
        
//         /*Gireesh
// //Added By Shahrukh for US341597. This is Temporary logic until security setup is done
// if(offering.PMP_Current_User_Profile_Nm__c=='11629028@intel.com.crm.nppdevpmp' || offering.PMP_Current_User_Profile_Nm__c=='11849006@intel.com'
// || offering.PMP_Current_User_Profile_Nm__c=='1875036@intel.com') {
// Intel_Step step6 = new Intel_Step('Admin Review');  //Adding Step 6 if the user name is as per mentioned in above condition.
// response.steps.add(step6);
// }  */
        
//         // NOTE: Separate into service classes...
//         // Build out form here, based on current values of offering and back end data model
//         if (offering.PMP_Category_nm__c != null) {
            
//         }
        
//         return response;
//     }
    
//     @AuraEnabled(cacheable=true)
//     // this returns JSON string of Wizard Data
//     public static String getWizardData(Id offeringId,string selectedLanguage) {
//         // NOTE: include any fields you need on the offering record here
//         //system.debug('****offeringId****'+offeringId);
//         string response;
//         if (Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()) {
//             PMP_Partner_Offering__c offering = [
//                 SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Active_Step_Txt__c, PMP_Current_Step_Txt__c,
//                 PMP_Review_Comment_Txt__c, // ISG test category field
//                 PMP_Offering_Create_Dt__c, // new offering date (date)
//                 PMP_Partner_Offering_Dsc__c, // description (rich text)
//                 PMP_Partner_Offering_Tag_Line_Txt__c, // tag line (text)
//                 PMP_Partner_Offering_Start_Dt__c, // start date (date)
//                 PMP_Partner_Offering_Visibility_Nm__c,
//                 PMP_Partner_Offering_Lifecycle_Status_Nm__c, // status (picklist)
//                 PMP_Review_Comment_History_Txt__c, // text area
//                 PMP_Business_Segment_Nm__c, // multi-select picklist
//                 PMP_Partner_Offering_End_Dt__c, // end date (date)
//                 PMP_Company_Id__c, //Offered by (Dropdown)
//                 PMP_Company_Id__r.Name, //Offered by - Company Name
//                 PMP_Offering_Language_Nm__c, // multi-select picklist
//                 PMP_Offering_Status_Update_Dt__c,
//                 PMP_Category_nm__c,
//                 PMP_Pre_Release_Check_Nm__c,
//                 PMP_Is_Converted_Ind__c
//                 FROM PMP_Partner_Offering__c where Id =: offeringId LIMIT 1
//             ];
//             //string tempString = offering.PMP_Review_Comment_History_Txt__c;
            
//             /* Setting blank value to the Offering Name field for the first time of offering record insertion
//     If Offering ID equals Offering Name, we are setting the Name field to blank*/
//             //system.debug('****offeringId1****'+offering.id);
//             //system.debug('****offeringName****'+offering.Name);
//             if(offering.id!=null){
//                 if(string.Valueof(offering.id).substring(0, 15) == offering.Name){ 
//                     offering.Name = '';  
//                 }
//             }
//             //If User is navigating to offering edit via language hyperlinks.(US434806) When User is on Tab1   
//             if(selectedLanguage !=null){
//                 Map<string, PMP_Partner_Offering_Translation__c> fieldAndValueMap = New Map<string,PMP_Partner_Offering_Translation__c>(); 
//                 Map<string,string> languageFieldMap = New Map<string,string>(); 
//                 List<PMP_Partner_Offering_Translation__c> existingtransValues = PMP_Utility.getOfferingTranslationRecords(offering.Id);
//                 List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeMtdList = PMP_Utility.getLocaleToFieldMdtRecordsByObject(selectedLanguage,'Offering_Translation');
//                 for(PMP_Partner_Offering_Translation__c iterValue : existingtransValues){ //fetch values from translation table.
//                     fieldAndValueMap.put(iterValue.PMP_Field_Nm__c, iterValue );
//                 }
//                 for(PMP_Locale_To_FieldAPINm_Mapping__mdt mapping : localeMtdList ){
//                     //  PMP_Locale_To_FieldAPINm_Mapping__mdt indicates which translation fields to refer to, based on the language parameter.
//                     // example: if language= en_US - translation fields referred will be English_Text__c.
//                     languageFieldMap.put(mapping.PMP_Locale_Nm__c,mapping.PMP_Field_APINm__c ); 
//                 }
//                 //replacing offering field values with values fetched from translation table.
//                 offering.PMP_Partner_Offering_Nm__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c') ?
//                     string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(selectedLanguage))).unescapeHtml4() : offering.PMP_Partner_Offering_Nm__c;
                
//                 offering.PMP_Partner_Offering_Dsc__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Dsc__c') ?
//                     string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Dsc__c').get(languageFieldMap.get(selectedLanguage))) : offering.PMP_Partner_Offering_Dsc__c;
//                 //offering.PMP_Partner_Offering_Tag_Line_Txt__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c') ?
//                    // string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(selectedLanguage))).unescapeHtml4() : offering.PMP_Partner_Offering_Tag_Line_Txt__c;
                
//                 if (fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c') && 
//                         fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c') != null &&fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(selectedLanguage)) != null) {
                        
//                         offering.PMP_Partner_Offering_Tag_Line_Txt__c = 
//                             string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c')
//                                             .get(languageFieldMap.get(selectedLanguage)))
//                                    .unescapeHtml4();
//                     }                     
                
//             }
//             response = JSON.serialize(buildResponse(offering,selectedLanguage));
            
//         }
//         return response;
//     }
    
    
    
//     @AuraEnabled
//     public static String saveOffering(String saveRequest) {
//         // THIS METHOD SAVES THE OFFERING AND ANY OTHER DATA
//         // AND RETURNS THE WIZARD DATA STRUCTURE
//         // NOTE: IF ANYTHING HAS CHANGED BASED ON THE SAVED DATA, ie. DEPENDENT INPUTS
//         // THE RETURN WIZARD DATA MIGHT CONTAIN NEW CHANGES
//         Intel_WizardData wizardData = (Intel_WizardData)JSON.deserialize(saveRequest, Intel_WizardData.class);
//         PMP_Partner_Offering__c oldOffering = new PMP_Partner_Offering__c();
        
//         // by updating the offering.. all modified values on the record get updated automatically
        
//         PMP_Partner_Offering__c offering = wizardData.formData.offering;

//         //Added by raj to populate standard name field of offering object for US406575
//         if(String.isNotBlank(offering.PMP_Partner_Offering_Nm__c)){//if offering custom name field is not blank,store that name in standard name field
//             if(offering.PMP_Partner_Offering_Nm__c.length() >= 80){//if the name is greater than 80 characters,store only 78 characters in standard name field
//                 offering.Name = offering.PMP_Partner_Offering_Nm__c.subString(0,78);
//             }
//             else{//else store the full name in standard name field
//                 offering.Name = offering.PMP_Partner_Offering_Nm__c;
//                 //offering.Name = offering.Name.trim();
//             }
//         }
//         /*-----------------------------End--------------------------------------------*/
//         //Gireesh:US322454:If the logged in user is partner, add the company info
//         Map<String, Intel_SpecificationDataWrapper> comapnyInfo=wizardData.formData.company;
//         if(comapnyInfo!=null && comapnyInfo.get('PMP_Company_Id__c')!=null){
//             Intel_SpecificationDataWrapper isdw=comapnyInfo.get('PMP_Company_Id__c');
//             if(isdw.relatedId!=null){
//                 offering.PMP_Company_Id__c=isdw.relatedId;
//             }
//         }
        
//         // TODO ADD ALL FIELD VALIDATIONS / PERMISSION AND SHARING VERIFICATIONS HERE
//         // TODO MOVE LOGIC TO SERVICE CLASS
//         //Abhishek: To save offering specifications--- start -----------
//         // if(wizardData.formData.selectedSpecifications!=null){
//         //system.debug('deleteOffSpec-->' +wizardData.deleteOfferingSpecifications);
//         if(wizardData.deleteOfferingSpecifications && Schema.sObjectType.PMP_Partner_Offering_Specification__c.isAccessible()){
//             List<PMP_Partner_Offering_Specification__c> exisitingOffSpecs = New List<PMP_Partner_Offering_Specification__c>();
//             if (Schema.sObjectType.PMP_Partner_Offering_Specification__c.isAccessible()) {
//             exisitingOffSpecs = [Select id from PMP_Partner_Offering_Specification__c
//                                  Where PMP_Offering_Id__c =: offering.Id];
//             }
//             if(exisitingOffSpecs.size() > 0 ){
//                 delete exisitingOffSpecs;
//             }
//         }
//         if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
//             oldOffering = [Select Name,PMP_Partner_Offering_Nm__c, PMP_Partner_Offering_Dsc__c,
//                            PMP_Partner_Offering_Tag_Line_Txt__c from PMP_Partner_Offering__c 
//                            WHERE Id =: offering.id];
//         }
//         //if(!Test.isRunningTest()){
//         try{
//             if(wizardData.formData.solutionSubCategory!=Null){
//                 PMP_OfferingCategoryHelper.saveGetmCategories(wizardData.formData.solutionSubCategory, offering.Id, wizardData.formData.industryAndApplication);
//             }else{
//                PMP_OfferingCategoryHelper.createOfferingCategories(wizardData.formData, offering, wizarddata.currentStep, wizarddata.stepchange); 
//             }   
//             PMP_OfferingSpecificationHelper.createOfferingSpecification(wizardData.formData, offering.Id, wizarddata.currentStep, wizarddata.stepchange);
//        // }
        
//             }
//                 catch(Exception e){
//                 //system.debug(e.getMessage()+e.getLineNumber());
//                 }
            
//         // }
//         //Abhishek --------End-----------------
//         // we separate these fields out because they are inherently important and relevant to the wizard
//         // but they could be renamed in the lightning component to use the respective fields on the record instead
//         offering.PMP_Active_Step_Txt__c = String.valueOf(wizardData.activeStep);
//         offering.PMP_Current_Step_Txt__c = String.valueOf(wizardData.currentStep);
//         List<String> tab0CategoryData = new List<String>();
//         if(wizardData.category.contains('|')){
//             tab0CategoryData = wizardData.category.split('\\|');//tab0CategoryData structure --> "categoryName|categoryPIMId",split it by '|' and use name only to populate offering field
//             offering.PMP_Category_nm__c = tab0CategoryData[0];
//         }
//         else{
//             offering.PMP_Category_nm__c = wizardData.category;
//         }
        
//         //Added by shahrukh : 11July 2019
//         boolean isAdmin = PMP_Utility.isLoggedInUserAdmin();
        
//         //system.debug('++++++++++++++++'+isAdmin);
//         if(isAdmin==false){
//             //system.debug('++++++++++++++++'+isAdmin);
//             offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Draft';
//         }
        
//         string selectedLanguage = wizardData.selectedLanguage;
//         string translationSaveType = wizardData.translationSaveType;
//         Map<string, PMP_Partner_Offering_Translation__c> fieldAndValueMap = New Map<string,PMP_Partner_Offering_Translation__c>();
//         List<PMP_Partner_Offering_Translation__c> updatedTranslation = New List<PMP_Partner_Offering_Translation__c>();
//         List<PMP_Partner_Offering_Translation__c> existingtransValues = PMP_Utility.getOfferingTranslationRecords(offering.Id);
//         Map<string,string> languageFieldMap = New Map<string,string>();
//         List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeMtdList = New List<PMP_Locale_To_FieldAPINm_Mapping__mdt> ();
//         //If User is navigating to offering edit via language hyperlinks.(US434806) -----
        
//         boolean isTranslationRequired = PMP_Utility.isTranslationRequired(offering);                                           
//         if(selectedLanguage!=null){
//             //fetching the old offering for comparision and to replace name/desc/tag-line if these fields or not changed in UI or if offering
//             //is edited in different language other than its created language.
            
            
//             if(existingtransValues.size()>0){
//                 //creating Map of field name and existing translation records.
//                 for(PMP_Partner_Offering_Translation__c iterValue : existingtransValues){
//                     fieldAndValueMap.put(iterValue.PMP_Field_Nm__c, iterValue );
//                 }
//             }
//             PMP_Partner_Offering_Translation__c nameTranslation = fieldAndValueMap.get('PMP_Partner_Offering_Nm__c');
//             PMP_Partner_Offering_Translation__c descTranslation = fieldAndValueMap.get('PMP_Partner_Offering_Dsc__c');
            
//             PMP_Partner_Offering_Translation__c tagTranslation = fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c')?
//                 fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c') :null;
//             localeMtdList = PMP_Utility.getLocaleToFieldMdtRecordsByObject(selectedLanguage,'Offering_Translation');
//             Map<string,string> localeCodeLanguageNameMap = New Map<String,string>();
            
//             //languageFieldMap is a Map of Locale code and the field to be updated on the translation object based on Language.
//             //Ex. if Selected Language = en_US, PMP_English_Txt__c is the field that needs to be updated on the translation records.
//             //localeCodeLanguageNameMap Ex. en_US => English. 
//             for(PMP_Locale_To_FieldAPINm_Mapping__mdt mapping : localeMtdList ){
//                 languageFieldMap.put(mapping.PMP_Locale_Nm__c,mapping.PMP_Field_APINm__c );
//                 localeCodeLanguageNameMap.put(mapping.PMP_Locale_Nm__c, mapping.PMP_Language_Nm__c) ;
//             }
            
//             //system.debug('translationSaveType:->'+translationSaveType);
//             //system.debug('isTranslationRequired:->'+isTranslationRequired);
            
//             //if offering is edited in a different language it is created in, Only translation records need to be updated 
//             if(translationSaveType == 'translation_table'){ 
//                 string tempName = offering.PMP_Partner_Offering_Nm__c ;
//                 string tempDesc = offering.PMP_Partner_Offering_Dsc__c;
//                 string tempTag = offering.PMP_Partner_Offering_Tag_Line_Txt__c;
//                 //system.debug('oldOff-->' +oldOffering.PMP_Partner_Offering_Nm__c);
//                 //reverting back the offering name and description to earlier value, as we need to make change only on translation record.
//                 offering.PMP_Partner_Offering_Nm__c = oldOffering.PMP_Partner_Offering_Nm__c;
//                 offering.PMP_Partner_Offering_Dsc__c = oldOffering.PMP_Partner_Offering_Dsc__c;
//                 offering.PMP_Partner_Offering_Tag_Line_Txt__c = oldOffering.PMP_Partner_Offering_Tag_Line_Txt__c;
//                 offering.Name = oldOffering.Name;
//                 if(isTranslationRequired){ 
//                     offering.PMP_Edit_Language_Cd__c = localeCodeLanguageNameMap.get(selectedLanguage);
//                     offering.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
//                     offering.PMP_Translated_Languages__c = localeCodeLanguageNameMap.get(selectedLanguage);
//                 }
//                 // Below else block added for the US - US835349
//                 else{
//                       offering.PMP_Translation_Lifecycle_Status_nm__c = 'Not Applicable';
//                 }
//                 /*system.debug('selectedLanguage'+selectedLanguage);
//                 system.debug('languageFieldMap'+languageFieldMap);
//                 system.debug('languageFieldMap.get(selectedLanguage)'+languageFieldMap.get(selectedLanguage));
//                 system.debug('tempName'+tempName);
//                 system.debug('nameTranslation'+nameTranslation);*/
//                 nameTranslation.put(languageFieldMap.get(selectedLanguage), tempName);
//                 descTranslation.put(languageFieldMap.get(selectedLanguage), tempDesc);
//                 if(tagTranslation !=null){
//                     tagTranslation.put(languageFieldMap.get(selectedLanguage), tempTag);
//                     updatedTranslation.add(tagTranslation);
//                 }
//                 updatedTranslation.add(nameTranslation);
//                 updatedTranslation.add(descTranslation);
                
                
//             }
            
//             //if offering is edited in same language it is created in, both translation record and offering needs to be updated.
//             else if(translationSaveType == 'both'){ 
                
//                 /*system.debug('selectedLanguage'+selectedLanguage);
//                 system.debug('languageFieldMap'+languageFieldMap);
//                 system.debug('languageFieldMap.get(selectedLanguage)'+languageFieldMap.get(selectedLanguage));
//                 system.debug('offering.PMP_Partner_Offering_Nm__c'+offering.PMP_Partner_Offering_Nm__c);*/
//                 nameTranslation.put(languageFieldMap.get(selectedLanguage), offering.PMP_Partner_Offering_Nm__c);
//                 descTranslation.put(languageFieldMap.get(selectedLanguage), offering.PMP_Partner_Offering_Dsc__c);  
//                 if(tagTranslation !=null)
//                 {
//                     tagTranslation.put(languageFieldMap.get(selectedLanguage), offering.PMP_Partner_Offering_Tag_Line_Txt__c);
//                     updatedTranslation.add(tagTranslation);
//                 } 
//                 if(isTranslationRequired){
//                     offering.PMP_Edit_Language_Cd__c = localeCodeLanguageNameMap.get(selectedLanguage);
//                     offering.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
//                     offering.PMP_Translated_Languages__c = localeCodeLanguageNameMap.get(selectedLanguage);
//                 }
//                 // Below else block added for the US - US835349
//                 else{
//                       offering.PMP_Translation_Lifecycle_Status_nm__c = 'Not Applicable';
//                 }
                
//                 updatedTranslation.add(nameTranslation);
//                 updatedTranslation.add(descTranslation);
                
//             }
//             else {
//                 //system.debug('isTranslationRequired in else:->'+isTranslationRequired);
//                 //if translationSaveType == null, this means name/desc/tagline is not edited in the UI, so we need to revert back to old offering value.
//                 offering.PMP_Partner_Offering_Nm__c = oldOffering.PMP_Partner_Offering_Nm__c;
//                 offering.PMP_Partner_Offering_Dsc__c = oldOffering.PMP_Partner_Offering_Dsc__c;
//                 offering.PMP_Partner_Offering_Tag_Line_Txt__c = oldOffering.PMP_Partner_Offering_Tag_Line_Txt__c;
//                 offering.Name = oldOffering.Name;
                
//             }
            
//         }
//         else{ //wiping out edited language if selected language is null.
//         /*system.debug('Blanking edit language');
//         system.debug('isTranslationRequired:->'+isTranslationRequired);
//         system.debug('offering:->'+offering.PMP_Translation_Lifecycle_Status_nm__c);*/
//             offering.PMP_Edit_Language_Cd__c = null;
//             if (offering.PMP_Partner_Offering_Nm__c != oldOffering.PMP_Partner_Offering_Nm__c ||
//                 offering.PMP_Partner_Offering_Dsc__c != oldOffering.PMP_Partner_Offering_Dsc__c || 
//                 offering.PMP_Partner_Offering_Tag_Line_Txt__c != oldOffering.PMP_Partner_Offering_Tag_Line_Txt__c){ //Translated Language values reset
//                     //system.debug('inside elseIf-->434');
//                     offering.PMP_Translated_Languages__c = offering.PMP_Offering_Language_Nm__c;
//                     //US835349 - Below line is updated 
//                     offering.PMP_Translation_Lifecycle_Status_nm__c= 'Not Applicable';
//                     offering.PMP_Translation_Lifecycle_Status_nm__c = isTranslationRequired ?'Pending' : offering.PMP_Translation_Lifecycle_Status_nm__c;
                    
//                 }/*else if(isTranslationRequired && offering.PMP_Translation_Lifecycle_Status_nm__c == 'Not Applicable'){
//                      system.debug('Changing the lifecycle status');
//                     offering.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
//                 }*/
//         }
//         //system.debug('offering:->'+offering);
//         //Added by Vardaan for Dummy Published Copy -start 
//         PMP_Partner_Offering__c dummyPublishedCopy = new PMP_Partner_Offering__c();
//         PMP_Partner_Offering__c dummyPublishedCopyId = new PMP_Partner_Offering__c();
        
//             try{
//                 dummyPublishedCopyId = [ select id,PMP_Is_Not_Available_On_MP_Ind__c from PMP_Partner_Offering__c 
//                                                     where PMP_Working_Copy_Id__c=:offering.Id ];
//                }
//                catch(Exception e){
//                     dummyPublishedCopyId = new PMP_Partner_Offering__c(); 
//                 }
           
//             dummyPublishedCopy = offering.clone(false,true,true,true);
        
//         //Added by Vardaan for Dummy Published Copy -end

//         if (Schema.sObjectType.PMP_Partner_Offering__c.isCreateable() && Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable()) {
//            //Added by Vardaan for Dummy Published Copy -start 
//             //TWC1824-1066 --Added by Vardaan - start
//             if(offering.PMP_Pre_Release_Check_Nm__c == PMP_StaticConstants_MasterData.Yes){
//                 offering.PMP_Is_Notified_Ind__c = false;
//             }
//             //TWC1824-1066 --Added by Vardaan - end
//             offering.PMP_Partner_Offering_LifecycleStatus_Txt__c = offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c; 
            
//             if( dummyPublishedCopyId.id <> null && dummyPublishedCopyId.PMP_Is_Not_Available_On_MP_Ind__c ==true){
                
//                 offering.PMP_Published_Copy_Id_Txt__c = dummyPublishedCopyId.Id;
                
//                 upsert offering; 
//                 dummyPublishedCopy.id = dummyPublishedCopyId.Id;
//                 dummyPublishedCopy.PMP_Published_Copy_Id_Txt__c = dummyPublishedCopyId.Id;
//                 dummyPublishedCopy.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
//                 dummyPublishedCopy.PMP_Partner_Offering_LifecycleStatus_Txt__c = 'Published';
                
//                 if(wizardData.deleteOfferingSpecifications && Schema.sObjectType.PMP_Partner_Offering_Specification__c.isAccessible()){
//                     List<PMP_Partner_Offering_Specification__c> exisitingDummyOffSpecs = New List<PMP_Partner_Offering_Specification__c>();
//                     if (Schema.sObjectType.PMP_Partner_Offering_Specification__c.isAccessible()) {
//                         exisitingDummyOffSpecs = [Select id from PMP_Partner_Offering_Specification__c
//                                         Where PMP_Offering_Id__c =: dummyPublishedCopy.id];
//                     }
//                     if(exisitingDummyOffSpecs.size() > 0 ){
//                         delete exisitingDummyOffSpecs;
//                     }
//                  }
                
//                // if(!Test.isRunningTest()){
//                 try{
//                     if(wizardData.formData.solutionSubCategory!=Null){
//                         PMP_OfferingCategoryHelper.saveGetmCategories(wizardData.formData.solutionSubCategory, dummyPublishedCopy.id, wizardData.formData.industryAndApplication);
//                     }else{
//                        PMP_OfferingCategoryHelper.createOfferingCategories(wizardData.formData, dummyPublishedCopy, wizarddata.currentStep, wizarddata.stepchange); 
//                     }   
//                     PMP_OfferingSpecificationHelper.createOfferingSpecification(wizardData.formData, dummyPublishedCopy.id, wizarddata.currentStep, wizarddata.stepchange);
//                // }
//                 }
//                 catch(Exception e){
//                 //system.debug(e.getMessage()+e.getLineNumber());
//                 }
//                 upsert dummyPublishedCopy;    
//             //Added by Vardaan for Dummy Published Copy -end                   
//             }
//             else{
//                 upsert offering; // updates offering record
//             }
//         }
        
//         if(!updatedTranslation.isEmpty() && Schema.sObjectType.PMP_Partner_Offering_Translation__c.isUpdateable()){
//             update updatedTranslation;
//         }
//         // End of Part1 of US434806 -----
        
        
//         // creating offering resources records for the offering when navigating from tab4 to tab5
//         if((wizarddata.currentStep-wizarddata.stepchange) == 3){
//             PMP_OfferingResourceHelper.createOfferingResource(wizardData.formData, offering.Id);
//             // if( dummyPublishedCopyId.id <> null && dummyPublishedCopyId.PMP_Is_Not_Available_On_MP_Ind__c ==true){
//             //     PMP_OfferingResourceHelper.createOfferingResource(wizardData.formData, dummyPublishedCopyId.id);
                
//             // }
//         }
        
//         //creating offering category records for top 2 categories(i.e ultimate parent and category selected on tab0) related to the offering
//         if(String.isBlank(offering.PMP_Partner_Offering_Nm__c)){
//             PMP_CreateOfferingTab0Service.createTopLevelOffCategoriesRecord(offering.id, tab0CategoryData[1]);
//             if( dummyPublishedCopyId.id <> null && dummyPublishedCopyId.PMP_Is_Not_Available_On_MP_Ind__c ==true){
//                 PMP_CreateOfferingTab0Service.createTopLevelOffCategoriesRecord(dummyPublishedCopyId.id, tab0CategoryData[1]);
//             }
//         } 
        
//         //PMP_CreateOfferingTab5Service.generateThumbnailImages(offering.Id);
//         //system.debug('Lang-->'+ selectedLanguage );
//         // Rebuild the wizard data response (reflecting any new changes)
        
//         /* --------------------- Part2 of US434806 -----
// *Once the offering and translation records are saved, we need to display the updated values on the UI,
// * therefore, replacing offering name,description and tagline values in the below if else blocks. 
// */      
        
//         if(selectedLanguage !=null &&  !updatedTranslation.isEmpty()){
//             //system.debug('insideif--lang');
//             Map<string,PMP_Partner_Offering_Translation__c > updtdFieldAndValueMap = New Map<string,PMP_Partner_Offering_Translation__c >();
//             for(PMP_Partner_Offering_Translation__c iterValue : updatedTranslation){
//                 updtdFieldAndValueMap.put(iterValue.PMP_Field_Nm__c, iterValue );
//             }
//             offering.PMP_Partner_Offering_Nm__c = string.valueOf(updtdFieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(selectedLanguage)));
//             offering.PMP_Partner_Offering_Dsc__c = string.valueOf(updtdFieldAndValueMap.get('PMP_Partner_Offering_Dsc__c').get(languageFieldMap.get(selectedLanguage)));
//             offering.PMP_Partner_Offering_Tag_Line_Txt__c = updtdFieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c')?
//                 string.valueOf(updtdFieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(selectedLanguage))):offering.PMP_Partner_Offering_Tag_Line_Txt__c ;
            
//         }
        
//         else if(selectedLanguage !=null &&  updatedTranslation.isEmpty()){
//             /*system.debug('insideelseif--lang');
//             system.debug('selectedLanguage'+selectedLanguage);
//             system.debug('languageFieldMap'+languageFieldMap);
//             system.debug('languageFieldMap.get(selectedLanguage)'+languageFieldMap.get(selectedLanguage));
//             system.debug('offering.PMP_Partner_Offering_Nm__c'+offering.PMP_Partner_Offering_Nm__c);*/
//             offering.PMP_Partner_Offering_Nm__c = (fieldAndValueMap != null && fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c') && languageFieldMap != null && languageFieldMap.get(selectedLanguage) != null) 
//             ? String.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(selectedLanguage))) : '';

//             offering.PMP_Partner_Offering_Dsc__c=  (fieldAndValueMap != null && fieldAndValueMap.containsKey('PMP_Partner_Offering_Dsc__c') && languageFieldMap != null && languageFieldMap.get(selectedLanguage) != null) 
//             ? String.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Dsc__c').get(languageFieldMap.get(selectedLanguage))) : '';

//             offering.PMP_Partner_Offering_Tag_Line_Txt__c =  (fieldAndValueMap != null && fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c') && languageFieldMap != null && languageFieldMap.get(selectedLanguage) != null) 
//             ? String.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(selectedLanguage))) : '';
            
//             // offering.PMP_Partner_Offering_Nm__c = string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(selectedLanguage)));
//             // offering.PMP_Partner_Offering_Dsc__c = string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Dsc__c').get(languageFieldMap.get(selectedLanguage)));
//             // offering.PMP_Partner_Offering_Tag_Line_Txt__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c')?
//             //     string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(selectedLanguage))) :null;
//             // offering.PMP_Partner_Offering_Tag_Line_Txt__c = 'Working';
//         }
//         //-----------End of Part2 of US434806    ------------------
//         //system.debug(' Limits--> Before Build Response' +'Soql: ' +limits.getQueries()+' Dml : '+ Limits.getDMLStatements());    
//         Intel_WizardData response = buildResponse(offering,selectedLanguage);
//         //system.debug('Limits-->' +'Soql: ' +limits.getQueries()+' Dml : '+ Limits.getDMLStatements());
//         return JSON.serialize(response);
        
        
        
//     }
    
//     @AuraEnabled(cacheable=true)
//     public static String refreshData(String request) {
//         // THIS METHOD REFRESHES WITH NEW DATA, BUT WITHOUT SAVING
//         Intel_WizardData wizardData = (Intel_WizardData)JSON.deserialize(request, Intel_WizardData.class);
//         PMP_Partner_Offering__c offering = wizardData.formData.offering;
//         offering.PMP_Active_Step_Txt__c = String.valueOf(wizardData.activeStep);
//         offering.PMP_Current_Step_Txt__c = String.valueOf(wizardData.currentStep);
//         if(wizardData.category.contains('|')){
//             List<String> tab0CategoryData = wizardData.category.split('\\|');
//             offering.PMP_Category_nm__c = tab0CategoryData[0];
//         }
//         else{
//             offering.PMP_Category_nm__c = wizardData.category;
//         }
        
//         // HANDLE REFRESH DATA HERE
//         // TODO: selectedCategories
//         // wizardData.formData.selectedCategories
//         // TODO: selectedSpecifications
        
//         // Rebuild the wizard data response (reflecting any new changes)
//         Intel_WizardData response = buildResponse(offering,null);
        
//         return JSON.serialize(response);
//     }
    
//     // FOR DEVELOPMENT ONLY -- to be deleted
//     @AuraEnabled
//     public static Id createRecord() {
        
//         PMP_Partner_Offering__c offering = new PMP_Partner_Offering__c();
//         offering.PMP_Active_Step_Txt__c = '0';
//         offering.PMP_Current_Step_Txt__c = '0';
//         offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Draft';
//         offering.PMP_Offering_Status_Update_Dt__c = system.now();
//         offering.PMP_Offering_Language_Nm__c = 'English'; //US 378929 - Added by Manasa
//         offering.PMP_Partner_Offering_Visibility_Nm__c = 'Public Content'; //US 406710 - Added by 
//         //offering.PMP_Pre_Release_Check_Nm__c='No';
//         //Added by Vardaan for Dummy Published Copy -start 
//         PMP_Partner_Offering__c dummyPublishedOffering = new PMP_Partner_Offering__c();
//         dummyPublishedOffering.PMP_Active_Step_Txt__c = '0';
//         dummyPublishedOffering.PMP_Current_Step_Txt__c = '0';
//         dummyPublishedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
//         dummyPublishedOffering.PMP_Offering_Status_Update_Dt__c = system.now();
//         dummyPublishedOffering.PMP_Offering_Language_Nm__c = 'English'; 
//         dummyPublishedOffering.PMP_Partner_Offering_Visibility_Nm__c = 'Public Content';
//         dummyPublishedOffering.PMP_Is_Not_Available_On_MP_Ind__c = true;
//         offering.PMP_Partner_Offering_LifecycleStatus_Txt__c= offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c;
//         dummyPublishedOffering.PMP_Partner_Offering_LifecycleStatus_Txt__c= dummyPublishedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c;    

//         //Added by Vardaan for Dummy Published Copy -end
//        if(Schema.sObjectType.PMP_Partner_Offering__c.isCreateable()){
//         insert offering;
//         //Added by Vardaan for Dummy Published Copy -start 
//         dummyPublishedOffering.PMP_Working_Copy_Id__c = offering.id;
//         insert dummyPublishedOffering;
        
//         offering.PMP_Published_Copy_Id_Txt__c  = dummyPublishedOffering.Id;
//         update offering;

//         dummyPublishedOffering.PMP_Published_Copy_Id_Txt__c  = dummyPublishedOffering.Id;
//         update dummyPublishedOffering;
//         //Added by Vardaan for Dummy Published Copy -end
//        }
        
//         //system.debug('##offering:->'+offering);
//         return offering.Id;
//         //Added by Vardaan for Dummy Published Copy -start 
//         //return dummyPublishedOffering.Id;
//         //Added by Vardaan for Dummy Published Copy -end
//     }
    
//     //Added by raj to fetch all top level categories for US321536
//     @AuraEnabled(cacheable=true)
//     public static String getCategoryList(){
//         List<PMP_CreateOfferingTab0Service.CategoryWrapper> categories=PMP_CreateOfferingTab0Service.fetchTopLevelCategories();
//         return JSON.serialize(categories);
//     }
//     /*-------------------End US321536------------------------------------------------------*/
//     //Added by Manasa to get duplicate offering name check for US340188 - moved to validateOfferingData method
//     @AuraEnabled(cacheable=true)
//     public static Integer isDuplicateOfferingServerCall(string strOfferingName, string offeringId, string companyId){
//         /*system.debug('offeringId in controller: ' + offeringId);
//         system.debug('companyId in controller: ' + companyId);
//         system.debug('strOfferingName in controller: '+ strOfferingName);*/
//         Integer checkDuplicateOff = PMP_CheckIfDuplicateOffering.isDuplicateOffering(strOfferingName,offeringId,companyId);
//         return checkDuplicateOff;
//     }
    
//     //added by raj to handle submit for US341586
//     /**
// * @description-submit the offering to admin and change the status to 'Admin Review'
// * @param submitRequest the data related to the offering
// * @return void
// * Method Parameters - String
// */
//     @AuraEnabled 
//     public static void submitOffering(String submitRequest,string userSelectedLanguage){
//          PMP_Partner_Offering__c publishedOfferingRec = new  PMP_Partner_Offering__c();
//         Intel_FormData formData = (Intel_FormData)JSON.deserialize(submitRequest,Intel_FormData.class);
//         PMP_Partner_Offering__c offering =formData.offering;
//         String userProfileId=UserInfo.getProfileId();
         
//         if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()) {  
//             PMP_Partner_Offering__c offeringRec = [select PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Edit_Language_Cd__c,PMP_Translation_Lifecycle_Status_nm__c,PMP_Offering_Language_Nm__c,PMP_Partner_Offering_Dsc__c,PMP_Translated_Languages__c,
//                                                    PMP_Partner_Offering_Tag_Line_Txt__c,PMP_Offering_Submitter_UserId__c from PMP_Partner_Offering__c where id=:offering.Id LIMIT 1 ];
//             offeringRec.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Admin Review';
//             offeringRec.PMP_Partner_Offering_LifecycleStatus_Txt__c = 'Admin Review';
//            //Added by Krishna to capture the last submitter id to send email for offering 
//             if(userProfileId.substring(0,15) == System.label.PMP_Partner_Profile_Id)
//             {
//                 offeringRec.PMP_Offering_Submitter_UserId__c =UserInfo.getUserId();
//             }
//             else
//             {
//                 if( offeringRec.PMP_Offering_Submitter_UserId__c ==null)
//                 {
//                     offeringRec.PMP_Offering_Submitter_UserId__c =UserInfo.getUserId();
//                 }
//             }    
            
//                 //Added by Vardaan for Dummy Published Copy -start
//                 publishedOfferingRec = [select PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Edit_Language_Cd__c,PMP_Translation_Lifecycle_Status_nm__c,PMP_Offering_Language_Nm__c,PMP_Partner_Offering_Dsc__c,PMP_Translated_Languages__c,
//                                                                 PMP_Partner_Offering_Tag_Line_Txt__c, PMP_Is_Not_Available_On_MP_Ind__c,PMP_Working_Copy_Id__c,PMP_Offering_Submitter_UserId__c from PMP_Partner_Offering__c where PMP_Working_Copy_Id__c=:offering.Id LIMIT 1 ];
                
//                 //Added by Vardaan for Dummy Published Copy stop
            

//             try{
                
//                     //Added by Vardaan for Dummy Published Copy -start
                        
//                     if(publishedOfferingRec.id<>null && publishedOfferingRec.PMP_Is_Not_Available_On_MP_Ind__c ==true){
                        
//                         Set<Id> existingOffIds = new Set<Id>();
//                         Set<Id> newOfferingIds = new Set<Id>();
//                         Map<Id,Id> offeringPublishedMap = new map<Id,Id>();
                        
//                         newOfferingIds.add(publishedOfferingRec.id);

//                         offeringPublishedMap.put(publishedOfferingRec.PMP_Working_Copy_Id__c,publishedOfferingRec.PMP_Working_Copy_Id__c);
//                         existingOffIds.add(publishedOfferingRec.PMP_Working_Copy_Id__c);
//                         List<PMP_Partner_Offering__c> existingOfferingList = new List<PMP_Partner_Offering__c>();
//                         existingOfferingList.add(publishedOfferingRec);
//                         List<PMP_Partner_Offering_Resource__c> resToBeInsertedList = new List<PMP_Partner_Offering_Resource__c>();
//                         List<PMP_Partner_Offering_Resource__c> resUpdateList  = PMP_OfferingTriggerHelper.createResourcesDocumentLink(existingOfferingList,existingOffIds,offeringPublishedMap);
                        
//                         List<PMP_Partner_Offering_Resource__c> ResDeletionList = new List<PMP_Partner_Offering_Resource__c>();
//                         if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
//                             ResDeletionList = [select id,PMP_Offering_Id__c,PMP_Partner_Offering_Image__c from PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c IN :newOfferingIds];
//                         }
//                         if(!ResDeletionList.isEmpty()){
//                             PMP_OfferingTriggerHelper.deleteImageFiles(ResDeletionList);
//                             delete ResDeletionList;
//                         }
                        
//                         if(!resUpdateList.isEmpty()){
//                             resToBeInsertedList.addAll(resUpdateList);
//                          }
//                         if(!resToBeInsertedList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering_Resource__c.isCreateable()){
//                             insert resToBeInsertedList;
//                          }


//                         publishedOfferingRec.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
//                         publishedOfferingRec.PMP_Partner_Offering_LifecycleStatus_Txt__c = 'Published';
//                         if(userProfileId.substring(0,15) == System.label.PMP_Partner_Profile_Id)
//                         {
//                             publishedOfferingRec.PMP_Offering_Submitter_UserId__c =UserInfo.getUserId();
//                         }
//                         else
//                         {
//                             if( publishedOfferingRec.PMP_Offering_Submitter_UserId__c ==null)
//                             {
//                                 publishedOfferingRec.PMP_Offering_Submitter_UserId__c =UserInfo.getUserId();
//                             }
//                         }  
//                         update publishedOfferingRec;
//                     }
//                     //Added by Vardaan for Dummy Published Copy -stop             
                
//                 update offeringRec;
                
//                 if(String.isEmpty(userSelectedLanguage)){ //if only fresh offering
//                     PMP_CreateLanguageTranslations.updateLanguageTranslation(offering);
//                 }
                
//             // US982076-Commented and calling this method in PMP_Offering_TriggerHelper after offering is Approved  
//             // PMP_CreateOfferingTab5Service.generateThumbnailImages(offering.Id);
                
//             }
            
//             catch(Exception e){
//                 //system.debug(e.getMessage()+e.getLineNumber());
//                 PMP_Utility.logError(e,'PMP_Offering');
//             }
//         }  
        
//     }
    
//     /*------------------End US341586------------------------------------------------------*/
    
     
//     //Gireesh:US364045:GET ADMIN DETAILS
//     @AuraEnabled(cacheable=true)
//     public static PMP_LightningServerResponse  getAdminDetails(Id offeringId) {
//         map<string,object> adminDetails = new map<string,object>();
//         map<String, Object> mapErrorInfo = new map<string,object>();
//         PMP_Partner_Offering__c currentAdmin = new PMP_Partner_Offering__c();
        
//         Profile profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
//         String profileName = profile.Name;
//         User user;
        
//         if(profileName!=null){
//             user=[SELECT Id, Name FROM User where Id=:userinfo.getUserId() Limit 1];
            
//         } 
        
//         //Get public group members
//         Group grp=[SELECT Id FROM Group where DeveloperName='PMP_All_Intel_Admin_Users' LIMIT 1];
//         List<GroupMember> groupMembers=[SELECT UserOrGroupId FROM GroupMember where GroupId=:grp.Id];
//         List<Id> userIds=new List<Id>();
//         for (GroupMember groupMember: groupMembers){
//             userIds.add(groupMember.UserOrGroupId);
//         }
//         List<User> admins=[SELECT Id, Name FROM User where Id in :userIds];
        
//         //Get Current Admin
        
//         //String finalBusinessSegment;
//         if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
//             currentAdmin=[SELECT PMP_Intel_Admin_Id__c,PMP_Reason_for_Retired_Txt__c,PMP_Intel_Admin_Nm__c, PMP_Translated_Languages__c, PMP_Partner_Offering_Lifecycle_Status_Nm__c,toLabel(PMP_Business_Segment_Nm__c) from PMP_Partner_Offering__c where Id=:offeringId LIMIT 1];
//         }
//         //Sandhya : US379001 - Get Business Segment values from Partner OfferingList<PMP_Partner_Offering__c> businessSegment = [select PMP_Business_Segment_Nm__c from PMP_Partner_Offering__c where Id=:offeringId AND PMP_Business_Segment_Nm__c!= NULL LIMIT 1];
//         List<String> finalBusinessValues = new List<String>();
//         //system.debug('businessSegment in Class-------------'+currentAdmin.PMP_Business_Segment_Nm__c);
//         //system.debug('Inside If---');
//         if(currentAdmin != null && currentAdmin.PMP_Business_Segment_Nm__c != null){
//             List<String> businessSegmentValues = currentAdmin.PMP_Business_Segment_Nm__c.split(';');
//             for(String businessValueRec : businessSegmentValues){
//                 String businessVal = businessValueRec;
//                 finalBusinessValues.add(businessVal);
//             }            //Sandhya : US379001 - Adding the business Segment Values to Map
//             adminDetails.put('businessSegment',finalBusinessValues);   
//             adminDetails.put('languageStatus',currentAdmin.PMP_Translated_Languages__c);    //Gireesh:US762788
            
//         }
//         if(currentAdmin.PMP_Reason_for_Retired_Txt__c!=''){
//             adminDetails.put('retiredComments',currentAdmin.PMP_Reason_for_Retired_Txt__c);
//         } 
//         adminDetails.put('loggedInUser',user); 
//         adminDetails.put('adminUsers',admins);
//         adminDetails.put('currentAdmin',currentAdmin); 
        
//         Map<String,String> pickListValuesMap = new Map<String,String>();
//         Schema.DescribeFieldResult fieldResult = PMP_Partner_Offering__c.PMP_Partner_Offering_Lifecycle_Status_Nm__c.getDescribe();
//         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
//         for( Schema.PicklistEntry pickListVal : ple){
//             pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
//         }     
//         adminDetails.put('pickListValuesMap',pickListValuesMap);
        
//         List<PMP_Partner_Offering_Resource__c> offeringVideoResourcesList = [SELECT id FROM PMP_Partner_Offering_Resource__c WHERE PMP_Offering_Id__c =: offeringId
//         AND PMP_Delete_BrightCove_Video_Ind__c=false AND (PMP_BrightCoveVideoThumbnail_URL__c=null OR PMP_BrightCoveVideoThumbnail_URL__c='') 
//         AND (PMP_Partner_Offering_Resource_URL_Txt__c='' OR PMP_Partner_Offering_Resource_URL_Txt__c=null)
//         AND PMP_Resource_Type_Nm__c ='Video'];
//         if(offeringVideoResourcesList.size()>0){
//             adminDetails.put('videoProcesssing',true);
//         }
//         else{
//             adminDetails.put('videoProcesssing',false);
//         }
//         return new PMP_LightningServerResponse(true,mapErrorInfo,adminDetails);
//     }
//     //Gireesh:US364045:Save Admin Details
//     @AuraEnabled
//     public static String saveAdminDetails(Id offeringId, String selectedAdmin, String selectedOfferingStatus, String retiredComments) {
//         //Added By Shahrukh - To store category values on offering
//         //Map<integer,string> offeringCategoryMap = new Map<integer,string>();
//         //List<Integer> sortedOrderList = new List<Integer>();
//         Boolean LeadPending = false;
//         Id publishedCopyId;
//         if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
//             PMP_Partner_Offering__c adminDetails=[SELECT Id, PMP_Intel_Admin_Id__c,PMP_Reason_for_Retired_Txt__c,PMP_All_Categories_Txt__c,PMP_Published_Copy_Id_Txt__c, PMP_Active_Step_Txt__c, PMP_Current_Step_Txt__c, PMP_Intel_Admin_Nm__c, PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Working_Copy_Id__c from PMP_Partner_Offering__c where Id=:offeringId LIMIT 1];
//             if(adminDetails.PMP_Working_Copy_Id__c<>null){
//                 adminDetails.Id = adminDetails.PMP_Working_Copy_Id__c;
//             }
//             adminDetails.PMP_Intel_Admin_Id__c=selectedAdmin;
//             adminDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c=selectedOfferingStatus;
//             adminDetails.PMP_Partner_Offering_LifecycleStatus_Txt__c = adminDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c;
//             adminDetails.PMP_Active_Step_Txt__c='4';
//             adminDetails.PMP_Current_Step_Txt__c='4';
//             adminDetails.PMP_Reason_for_Retired_Txt__c = retiredComments;
//             if(adminDetails.PMP_Published_Copy_Id_Txt__c!=Null){
//                publishedCopyId = Id.ValueOf(adminDetails.PMP_Published_Copy_Id_Txt__c);
//             }
//             if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
//                 string allCategories = '';
//                 //Added by Shahrukh - Querying offering categories and populating all the names of categories on one field in offering object(PMP_All_Categories_Txt__c ) in sort order 
//                 for(PMP_Partner_Offering_Category__c offCat: [select id,PMP_Category_Id__c,PMP_Ancestor_Category_Cd__c,PMP_Offering_Id__c,
//                                                               PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,PMP_Category_Id__r.Name 
//                                                               from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offeringId 
//                                                               and PMP_Ancestor_Category_Cd__c Like '%NPP_01_TYPE%']){
//                    allCategories = allCategories==''? offCat.PMP_Category_Id__r.Name+'|'+offCat.PMP_Category_Id__r.Id : allCategories+';'+ offCat.PMP_Category_Id__r.Name+'|'+offCat.PMP_Category_Id__r.Id;
//                 }
                
//                 adminDetails.PMP_All_Categories_Txt__c = allCategories;      
                
//             }
            
//             if(publishedCopyId!=Null && Schema.sObjectType.Lead.isAccessible()){
            
//                 list<lead> pendingLeads = [select id,Core_Partner_Offering__c,Core_Lead_Status__c from lead where Core_Partner_Offering__c=:publishedCopyId and Core_Lead_Status__c!='Qualified'];
                
//                 if(pendingLeads.size()>0){
//                     LeadPending = true;
//                 }
//             }
            
            
//             try{
//                 update adminDetails;
//             }catch(exception e){
//                 return 'error';
//             }
//         }
        
//         if(LeadPending==true){
            
//             return 'PendingLead';
//         }else{
//             return 'saved';
//         }   
        
//     }
    
    
//     /*Gireesh:US378991:check if any pre-release items are selected*/
//     @AuraEnabled(cacheable=true)
//     public static Boolean getOffSetValues(Id offeringId){
//         return PMP_SpecificationController.getOffSetValues(offeringId);
//     }
    
//     /**
// * Added by raj to restrict editing for external users (US428208)
// @description returns true if logged in user has create offering access
// @param NA
// @return boolean
// @Method Parameters NA
// */
//     @AuraEnabled(cacheable=true)
//     public static Boolean getCreateOfferingAccess(){
//         Boolean hasCreateOfferingAccess = false;    
//         User userObj= [Select id,ContactId,Contact.AccountId,Contact.Account.Name from User where id=:UserInfo.getUserId()];
//         //system.debug('userObj ' + userObj);
//         //system.debug('userObjCOntact ' + userObj.Contact.AccountId);
//         //Fetching the permissions assigned to the logged in user
//         List<PermissionSetAssignment> permissionsList=[SELECT PermissionSet.Name FROM PermissionSetAssignment 
//                                                        WHERE AssigneeId=:userObj.Id];
//         List<String> currentUserPermissionSetNames = new List<String>();
//         List<PMP_Company__c> enhancedBenefitComp;
//         for(PermissionSetAssignment paObj:permissionsList) {
//             currentUserPermissionSetNames.add(String.valueOf(paObj.PermissionSet.Name));
//         }
        
//         /*Create Offering button should be visible to Intel admins as well as only those partner admins and offering editors 
// who have a published storefront for the partner accounts correspondig to  their accounts*/
// if(!currentUserPermissionSetNames.contains('PMP_Internal_Intel_Admin') && (currentUserPermissionSetNames.contains('PMP_External_Offering_Editor')||
// currentUserPermissionSetNames.contains('PMP_External_Partner_Admin'))){
               
//                //Querying the PAG member to get the partner account for the corresponding user account
           
//            Core_Account_Group_Member__c partnerAccountGroupMember1=[select Core_Partner_Account_Id__c,/* Core_MDA_Ind__c,*/ Core_Intel_Account_Id__c from Core_Account_Group_Member__c 
//                                                                        Where (Core_Intel_Account_Id__c=:userObj.contact.AccountId OR
//                                                                        Core_Partner_Account_Id__c =:userObj.contact.AccountId)
//                                                                        and Core_Inactive_Ind__c=false LIMIT 1];
                  
//             // Added as part of OPID Restructure - Sathish                                                                       
//             List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccountToMpiByAccountId(new set<Id>{partnerAccountGroupMember1.Core_Partner_Account_Id__c});
//             List<Id> listRelatedMpiToAccount = PMP_Utility.getListMpiIds(junctionObjects);
//                //Checking if the storefront associated with the user's account is published already and has enhanced benefit
//                //IPA 2.0 TWC729-7887

//             //   enhancedBenefitComp = [SELECT id FROM PMP_Company__c 
//             //                           WHERE Id in : listRelatedMpiToAccount
//             //                           AND PMP_Partner_Benefit_Type__c=:PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced //IPA2.0 - TWC729-7885
//             //                           AND PMP_Benefit_Update_Ind__c=False 
//             //                           AND PMP_Partner_Inactive_Ind__c = False
//             //                           AND PMP_Is_Published_Ind__c=true 
//             //                           AND PMP_Company_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published];
              
//             //    if(!enhancedBenefitComp.isEmpty()) {
//             //                                         hasCreateOfferingAccess = true;                
//             //                                     }
// }else if(currentUserPermissionSetNames.contains('PMP_Internal_Intel_Admin')){
//                hasCreateOfferingAccess=true;
//            } 
        
//         return (hasCreateOfferingAccess && Schema.sObjectType.PMP_Partner_Offering__c.isCreateable());
//     }
//     /*-------------------------End---------------------------------*/
    
//     @AuraEnabled(cacheable=true)
//     public static Integer validateOfferingDataServerCall(String checkRequestData){
//         Integer status;
//         Intel_FormData formData = (Intel_FormData)JSON.deserialize(checkRequestData,Intel_FormData.class);
//         //PMP_Partner_Offering__c offering = formData.offering;
        
//         status = PMP_CreateOfferingTab1Service.validateOfferingData(formData);
        
//         return status;
        
//     }
    
//     /* ---------------------------
//      @ Part of US998003: New Ge-TM - Redirect MP user to Manage solutions
//      @ Added by Bharath
//      @ Created on 14-May-2021
//      @ Description: Deleting current offering record when we click on solution icon in offering creation page 
//      ---------------------------*/
//     @AuraEnabled
//     public static void deletecurrentOffering(Id currentofferingid){
//         //system.debug('*** Fettiching Current Offering Id: '+currentofferingid);
//         PMP_Partner_Offering__c offering = [select id,Name from PMP_Partner_Offering__c where Id=:currentofferingid limit 1];
//         delete offering;
//     }
//     /* ---------------------------
//      @ Part of Livelier #214:Check URL Navigation access is allowed or not
//      @ Added by Pranjal
//      @ Created on 14-Feb-2021
//      @ Description: Check the URL access id allowed for craete offering or not 
//      ---------------------------*/
//     @AuraEnabled
//     public static OfferingDataCheckWrapper isSafeURLNavigation(Id offeringId) {
//         String benefitName = Core_UtilityController.checkBenefitLevel();
//        // IPA 2.0 TWC729-7887

//        /* Boolean isEnhancedAccess=false, isBasicAccess=false*/Boolean isPartnerUser=false,is_PMP_Manage_Offerings=false,access=false;
//         OfferingDataCheckWrapper offeringDataWrapper = new OfferingDataCheckWrapper();
//         //IPA 2.0 TWC729-7887

//         // if(benefitName != '' &&  benefitName == System.Label.PMP_Offering_Benefit){ 
//         //     isEnhancedAccess = true;
//         // }
//         // if(benefitName == '' || benefitName == 'Solution Marketplace Basic Access'){
//         //     isBasicAccess = true;
//         // }
//         User userRecord = Core_UtilityController.fetchUser();
//         if(userRecord != null && userRecord.ContactId != null
//                                            && userRecord.ContactId != null){
//             isPartnerUser = true;
//         }
//         Map<String, Boolean> mapPermmision = Core_UtilityController.checkForCustomPermission();
//         if(mapPermmision.get('PMP_Manage_Offerings') != null){
//             is_PMP_Manage_Offerings = true;
//         }
//         if(isPartnerUser){
//             //IPA 2.0 TWC729-7887

//             // if(isBasicAccess){
//             //     access= false;
//             // } else if(isEnhancedAccess && is_PMP_Manage_Offerings){
//             //     access= true;
//             // }
//             if(is_PMP_Manage_Offerings == true)  {
//                 access= true;
//             } else {
//                access= false; 
//             }
//         }
//         else{
//             if(is_PMP_Manage_Offerings == true)  {
//                 access= true;
//             } else {
//                access= false; 
//             }
//         }


//         offeringDataWrapper.validateBookmarkUrl=validateBookMarkedOffering(offeringId);
//         offeringDataWrapper.access = access;
//         return offeringDataWrapper;
        
//     }
//     /* ---------------------------
//      @ Part of TWC4497-83: MP : PA/POE or Intel MP Admin clicks on bookmarked URL of the offering in Retired/Admin Review.
//      @ Added by Sandhya
//      @ Created on 19-May-2021
//      @ Description: MP : PA/POE or Intel MP Admin clicks on bookmarked URL of the offering in Retired/Admin Review.
//      ---------------------------*/
//     @AuraEnabled
//         public static String validateBookMarkedOffering(Id offeringId) {
//             String AdminReviewCheck = '';
//             String RetiredCheck = '';
//             Boolean isPartnerUser = false;
//        try{
//         PMP_Partner_Offering__c bookmarkedOffering =[select id,PMP_Partner_Offering_Lifecycle_Status_Nm__c from PMP_Partner_Offering__c 
//         where id=:offeringId];
//         User userRecord = Core_UtilityController.fetchUser();
//         if(userRecord != null && userRecord.ContactId != null){
//             isPartnerUser = true;
            
//         }
//         if(bookmarkedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c==PMP_StaticConstants_Offering.ADMIN_REVIEW && isPartnerUser){
//             AdminReviewCheck = 'isAdminreview';
            
            
//         }
//         else if(bookmarkedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c==PMP_StaticConstants_Offering.RETIRED && (isPartnerUser || PMP_Utility.isLoggedInUserAdmin())){
//             RetiredCheck =  'isRetired';
            
           
//         }
//         if(AdminReviewCheck != ''){
//             return AdminReviewCheck;
//         }
//         if(RetiredCheck != ''){
//             return RetiredCheck;
//         }
        
//     }catch(Exception e){
//        PMP_Utility.logError(e,'MarketplaceCreateProductController');
//     }
//     return '';
//     }

//     public class OfferingDataCheckWrapper{

//         @AuraEnabled
//         public Boolean access {get;set;}

//         @AuraEnabled

//         public String validateBookmarkUrl {get;set;}

//     }
    
//     /**
//     * @description Method To clone Offering
//     * @param Id
//     * @return String
//     **/
//     @AuraEnabled
//     public static String cloneOfferingDetail(Id offeringId, string language){
//         PMP_LightningServerResponse lightningResponse = new PMP_LightningServerResponse();
//         try{
//             lightningResponse = PMP_CloneOfferingController.cloneOffering(offeringId, language);
//         }catch (Exception e) {
//             PMP_Utility.logError(e,'PMP_CloneOffering'); 
//         }       
//         return JSON.serialize(lightningResponse);
//     }

// }