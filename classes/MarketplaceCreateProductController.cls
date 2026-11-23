public with sharing class MarketplaceCreateProductController {
    
     @AuraEnabled(cacheable=true)
    public static Intel_WizardData buildResponse(PMP_Partner_Offering__c offering,string selectedLanguage) {
      Intel_WizardData response = new Intel_WizardData();
      // FormData represents the current state of the form and all its values
      Intel_FormData formData = new Intel_FormData();
      formData.offering = offering;
        Map<string, List<Intel_SpecificationDataWrapper>> specifications = New Map<string, List<Intel_SpecificationDataWrapper>>();
        Map<string, List<string>> specification_smpl = New Map<string, List<string>>();
        Map<string,string> specification_txt = New Map<string,string>();
        //Intel_ProductWebPageDataWrapper webPageData = new Intel_ProductWebPageDataWrapper();
        formData.specifications = specifications;
        formData.company=new Map<String, Intel_SpecificationDataWrapper>();
        formData.specification_smplTab1 = specification_smpl;
        formData.specification_smplTab2 = specification_smpl;
        formData.specification_smplTab3 = specification_smpl;
        formData.specification_txtTab1 = specification_txt;
        formData.specification_txtTab2 = specification_txt;
        formData.specification_txtTab3 = specification_txt;
        formData.specification_cmplxTab1 = specifications;
        formData.specification_cmplxTab2 = specifications;
        formData.specification_cmplxTab3 = specifications;
        formData.industryAndApplication = specifications;
        formData.categoryAndSubCategory = specifications;
        //adding productwebpage data to response
        formData.productWebPageData = PMP_OfferingResourceHelper.getProductWebPageData(offering.Id);
        //adding additional resources data to response
        formData.resources = PMP_OfferingResourceHelper.getAdditionalResources(offering.Id);

      // TODO Add relevant other fields to formData here
      // formData.selectedCategories ....

      response.formData = formData;
      /* Prakash response.activeStep = Integer.valueOf(offering.PMP_Active_Step_Txt__c);
      response.currentStep = Integer.valueOf(offering.PMP_Current_Step_Txt__c); */
      // Null checks needed
      response.activeStep = !String.isBlank(offering.PMP_Active_Step_Txt__c) ? Integer.valueOf(offering.PMP_Active_Step_Txt__c) : 0;
      response.currentStep = !String.isBlank(offering.PMP_Current_Step_Txt__c) ? Integer.valueOf(offering.PMP_Current_Step_Txt__c) : 0;
      
      response.category = offering.PMP_Category_nm__c;
      response.steps = new List<Intel_Step>();

        //GET OFFERING INFO(CDNA NUMBER)



      //POC - Specifications
      List<PMP_Partner_Offering_Category__c> offeringCategories  = [Select Name,PMP_Offering_Category_External_Key__c, PMP_Category_Id__r.Type__c
                                                                  from PMP_Partner_Offering_Category__c
                                                                  Where PMP_Offering_Id__c =: offering.id];
        List<string> categoryList = new List<string>();
        final String categoryPIMId;
        if(offeringCategories.size() > 0  ){
            for(PMP_Partner_Offering_Category__c offeringCat : offeringCategories  ){
                categoryList.add(offeringCat.PMP_Offering_Category_External_Key__c);
                /*Added by raj to get the PIM Id of the category selected on tab0*/
                if(offeringCat.Name == offering.PMP_Category_nm__c && offeringCat.PMP_Category_Id__r.Type__c == 'Category'){
                    categoryPIMId = offeringCat.PMP_Offering_Category_External_Key__c;
                    system.debug('#####piMID--->'+categoryPIMId);
                }
                /*--------------------Changes End-----------------------------*/
            }
        }
        system.debug('#####piMID2--->'+categoryList);
        List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specValues = New List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
        specValues = PMP_SpecificationController.getOfferingSpecificationList(categoryList,null,selectedLanguage);
    
        List<PMP_SpecificationController.Core_PMP_OfferingSpecs> step1SpecList = new List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
        List<PMP_SpecificationController.Core_PMP_OfferingSpecs> step2SpecList = new List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
        List<PMP_SpecificationController.Core_PMP_OfferingSpecs> step3SpecList = new List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();

        List<PMP_Specifications_Tab_Mapping__mdt> stepConfigurations = [Select label,Accordion_Type__c,PMP_Field_Label__c, isAccordion__c, isSearchable__c,
                                                                                tab__c,Show_Select_All__c,Interaction_Type__c from PMP_Specifications_Tab_Mapping__mdt];
        Map<String, PMP_Specifications_Tab_Mapping__mdt> stepConfigurationsMap = New Map<String, PMP_Specifications_Tab_Mapping__mdt>();


        for(PMP_Specifications_Tab_Mapping__mdt iterMetaData : stepConfigurations ){
            
            stepConfigurationsMap.put(iterMetaData.label, iterMetaData);
        }
        for(PMP_SpecificationController.Core_PMP_OfferingSpecs specification : specValues) {
           
            string tab ='';
            if(stepConfigurationsMap.get(specification.specId)!=null){
                tab=stepConfigurationsMap.get(specification.specId).tab__c;
            }
            system.debug('tab:'+stepConfigurationsMap);
            system.debug('tab2:'+specification.specId);
            system.debug('tab3:'+stepConfigurationsMap.get(specification.specId));


            if(tab!=null && tab == 'Tab1'){
                step1SpecList.add(specification);
            }
            else if(tab!=null && tab == 'Tab2'){
                step2SpecList.add(specification);
            }
            else if(tab!=null && tab == 'Tab3') {
                step3SpecList.add(specification);
            }
        }

           //Added by Shahrukh : Prepopulation of selected Geo Regions and End Customer Type US364094
           //Abhishek --> getting it out of getSpecificationSubsection of UI generator to avoid query in loop and re-usability.
             set<string> offSpecSet = new set<string>();
            map<string,string> specValDataMap = new map<string,string>();
            map<string,List<string>> specValListMap = new map<string,List<string>>();
            List<PMP_Partner_Offering_Specification__c> offeringSpecList = new List<PMP_Partner_Offering_Specification__c>();
         if(offering.Id!=null){

             offeringSpecList = [select id,PMP_Product_Specification_Cd__c,PMP_Specification_Value_Nm__c,PMP_Specification_Value_Cd__c,PMP_Offering_Id__c ,
                                 PMP_Specification_Value_Id__c, PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering.Id];
             //Checking if there are any selected specifications
             if(!offeringSpecList.isEmpty()){
                 //Looping through all the selected specifications and populating the PIM id values in the set
                 for(PMP_Partner_Offering_Specification__c offSpec : offeringSpecList){
                    offSpecSet.add(offSpec.PMP_Product_Specification_Cd__c); //Adding PIM Id in the set, This set will contain unique PIM Ids
                    if(offSpec.PMP_Specification_Value_Cd__c!=null && offSpec.PMP_Specification_Value_Cd__c!='' && offSpec.PMP_Specification_Value_Id__c == null){
                       offSpecSet.add(offSpec.PMP_Specification_Value_Cd__c);
                       specValDataMap.put(offSpec.PMP_Product_Specification_Cd__c,offSpec.PMP_Specification_Value_Cd__c);
                    }
                    else if(offSpec.PMP_Specification_Value_Cd__c!=null && offSpec.PMP_Specification_Value_Cd__c!='' && offSpec.PMP_Specification_Value_Id__c != null){
                        if(!specValListMap.isEmpty() && specValListMap.get(offSpec.PMP_Product_Specification_Cd__c)!= null){
                            List<string> valueList = specValListMap.get(offSpec.PMP_Product_Specification_Cd__c);
                            valueList.add(offSpec.PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c);
                            specValListMap.put(offSpec.PMP_Product_Specification_Cd__c, valueList);
                        }
                        else{
                            List<string> valueList = New List<string>{offSpec.PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c};
                            specValListMap.put(offSpec.PMP_Product_Specification_Cd__c, valueList);
                        }
                        
                    }
                 }
             }
         }

      //POC - Specifications

      // STEP 1: Offering Details
      //system.debug('**************response.category*************');

      Intel_Step step1 = PMP_CreateOfferingTab1Service.getOfferingDetailsInputs(System.Label.PMP_Create_Offering_Form_STEP1,categoryPIMId,
                                                                                   step1SpecList, stepConfigurationsMap, offering, offSpecSet,specValDataMap,specValListMap,selectedLanguage );

      //new Intel_Step(System.Label.PMP_Create_Offering_Form_STEP1);

      // STEP 2: Intel Technologies
        Intel_Step step2 =  PMP_CreateOfferingTab2Service.getOfferingDetailsInputs(System.Label.PMP_Create_Offering_Form_STEP2,step2SpecList,stepConfigurationsMap, offering, offSpecSet,specValDataMap,specValListMap);
      //Intel_Step step2 = new Intel_Step(System.Label.PMP_Create_Offering_Form_STEP2);
       // STEP 3: Specifications
     // Intel_Step step3 = new Intel_Step(System.Label.PMP_Create_Offering_Form_STEP3);
      Intel_Step step3 =  PMP_CreateOfferingTab3Service.getOfferingDetailsInputs(System.Label.PMP_Create_Offering_Form_STEP3,step3SpecList, stepConfigurationsMap,offering, offSpecSet,specValDataMap,specValListMap);
       // STEP 4: Resources 
      Intel_Step step4 = PMP_CreateOfferingTab4Service.getResourcesInputs(System.Label.PMP_Create_Offering_Form_STEP4,offering); 
      //new Intel_Step(System.Label.PMP_Create_Offering_Form_STEP4);

      Intel_Step step5 = new Intel_Step(System.Label.PMP_Create_Offering_Form_STEP5);





      response.steps.add(step1);
      response.steps.add(step2);
      response.steps.add(step3); 
      response.steps.add(step4);
      response.steps.add(step5);


        //Gireesh
        //Get public group members
        Group grp=[SELECT Id FROM Group where Name='PMP - All Intel Admin Users' LIMIT 1];
        system.debug('****grp****'+grp);
        if (grp!=Null){
            List<GroupMember> groupMembers=[SELECT UserOrGroupId FROM GroupMember where GroupId=:grp.Id];
            List<Id> userIds=new List<Id>();
            for (GroupMember groupMember: groupMembers){
                userIds.add(groupMember.UserOrGroupId);
                system.debug('****userIds****'+userIds);

            }
            
            //Add Admin Review Tab for admins
            if(userIds.contains(userinfo.getUserId())){
                Intel_Step step6 = new Intel_Step(System.Label.PMP_Admin_Review);  //Adding Step 6 if the user name is as per mentioned in above condition.
                response.steps.add(step6);
            }
        }

        /*Gireesh
      //Added By Shahrukh for US341597. This is Temporary logic until security setup is done
      if(offering.PMP_Current_User_Profile_Nm__c=='11629028@intel.com.crm.nppdevpmp' || offering.PMP_Current_User_Profile_Nm__c=='11849006@intel.com'
        || offering.PMP_Current_User_Profile_Nm__c=='1875036@intel.com') {
          Intel_Step step6 = new Intel_Step('Admin Review');  //Adding Step 6 if the user name is as per mentioned in above condition.
          response.steps.add(step6);
      }  */

      // NOTE: Separate into service classes...
      // Build out form here, based on current values of offering and back end data model
      if (offering.PMP_Category_nm__c != null) {

      }

      return response;
    }

    @AuraEnabled(cacheable=true)
    // this returns JSON string of Wizard Data
    public static String getWizardData(Id offeringId,string selectedLanguage) {
      // NOTE: include any fields you need on the offering record here
      system.debug('****offeringId****'+offeringId);
      PMP_Partner_Offering__c offering = [
        SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Active_Step_Txt__c, PMP_Current_Step_Txt__c,
          PMP_Review_Comment_Txt__c, // ISG test category field
          PMP_Offering_Create_Dt__c, // new offering date (date)
          PMP_Partner_Offering_Dsc__c, // description (rich text)
          PMP_Partner_Offering_Tag_Line_Txt__c, // tag line (text)
          PMP_Partner_Offering_Start_Dt__c, // start date (date)
          PMP_Partner_Offering_Visibility_Nm__c,
          PMP_Partner_Offering_Lifecycle_Status_Nm__c, // status (picklist)
          PMP_Review_Comment_History_Txt__c, // text area
          PMP_Business_Segment_Nm__c, // multi-select picklist
          PMP_Partner_Offering_End_Dt__c, // end date (date)
          PMP_Company_Id__c, //Offered by (Dropdown)
          PMP_Company_Id__r.Name, //Offered by - Company Name
          PMP_Offering_Language_Nm__c, // multi-select picklist
          PMP_Offering_Status_Update_Dt__c,
          PMP_Category_nm__c,
          PMP_Pre_Release_Check_Nm__c
        FROM PMP_Partner_Offering__c where Id =: offeringId LIMIT 1
      ];
       string tempString = offering.PMP_Review_Comment_History_Txt__c;

      /* Setting blank value to the Offering Name field for the first time of offering record insertion
           If Offering ID equals Offering Name, we are setting the Name field to blank*/
        system.debug('****offeringId1****'+offering.id);
        system.debug('****offeringName****'+offering.Name);
      if(offering.id!=null){
            if(string.Valueof(offering.id).substring(0, 15) == offering.Name){ 
                offering.Name = '';  
            }
        }
      //If User is navigating to offering edit via language hyperlinks.(US434806) When User is on Tab1   
      if(selectedLanguage !=null){
            Map<string, PMP_Partner_Offering_Translation__c> fieldAndValueMap = New Map<string,PMP_Partner_Offering_Translation__c>(); 
            Map<string,string> languageFieldMap = New Map<string,string>(); 
            List<PMP_Partner_Offering_Translation__c> existingtransValues = PMP_Utility.getOfferingTranslationRecords(offering.Id);
            List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeMtdList = PMP_Utility.getLocaleToFieldMdtRecordsByObject(selectedLanguage,'Offering_Translation');
            for(PMP_Partner_Offering_Translation__c iterValue : existingtransValues){ //fetch values from translation table.
                        fieldAndValueMap.put(iterValue.PMP_Field_Nm__c, iterValue );
            }
            for(PMP_Locale_To_FieldAPINm_Mapping__mdt mapping : localeMtdList ){
          //  PMP_Locale_To_FieldAPINm_Mapping__mdt indicates which translation fields to refer to, based on the language parameter.
          // example: if language= en_US - translation fields referred will be English_Text__c.
                    languageFieldMap.put(mapping.PMP_Locale_Nm__c,mapping.PMP_Field_APINm__c ); 
            }
            //replacing offering field values with values fetched from translation table.
            offering.PMP_Partner_Offering_Nm__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c') ?
                            string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(selectedLanguage))).unescapeHtml4() : offering.PMP_Partner_Offering_Nm__c;
                             
            offering.PMP_Partner_Offering_Dsc__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Dsc__c') ?
                            string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Dsc__c').get(languageFieldMap.get(selectedLanguage))) : offering.PMP_Partner_Offering_Dsc__c;
            offering.PMP_Partner_Offering_Tag_Line_Txt__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c') ?
                            string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(selectedLanguage))).unescapeHtml4() : offering.PMP_Partner_Offering_Tag_Line_Txt__c;
            
          
      }
      Intel_WizardData response = buildResponse(offering,selectedLanguage);
      return JSON.serialize(response);
    }



    @AuraEnabled
    public static String saveOffering(String saveRequest) {
      // THIS METHOD SAVES THE OFFERING AND ANY OTHER DATA
      // AND RETURNS THE WIZARD DATA STRUCTURE
      // NOTE: IF ANYTHING HAS CHANGED BASED ON THE SAVED DATA, ie. DEPENDENT INPUTS
      // THE RETURN WIZARD DATA MIGHT CONTAIN NEW CHANGES
        Intel_WizardData wizardData = (Intel_WizardData)JSON.deserialize(saveRequest, Intel_WizardData.class);

        // by updating the offering.. all modified values on the record get updated automatically
        
        PMP_Partner_Offering__c offering = wizardData.formData.offering;
        
        //Added by raj to populate standard name field of offering object for US406575
        if(String.isNotBlank(offering.PMP_Partner_Offering_Nm__c)){//if offering custom name field is not blank,store that name in standard name field
            if(offering.PMP_Partner_Offering_Nm__c.length() >= 80){//if the name is greater than 80 characters,store only 78 characters in standard name field
                offering.Name = offering.PMP_Partner_Offering_Nm__c.subString(0,78);
            }
            else{//else store the full name in standard name field
                offering.Name = offering.PMP_Partner_Offering_Nm__c;
            }
        }
        /*-----------------------------End--------------------------------------------*/
        //Gireesh:US322454:If the logged in user is partner, add the company info
        Map<String, Intel_SpecificationDataWrapper> comapnyInfo=wizardData.formData.company;
        if(comapnyInfo!=null && comapnyInfo.get('PMP_Company_Id__c')!=null){
            Intel_SpecificationDataWrapper isdw=comapnyInfo.get('PMP_Company_Id__c');
            if(isdw.relatedId!=null){
                offering.PMP_Company_Id__c=isdw.relatedId;
            }
        }

      // TODO ADD ALL FIELD VALIDATIONS / PERMISSION AND SHARING VERIFICATIONS HERE
      // TODO MOVE LOGIC TO SERVICE CLASS
        //Abhishek: To save offering specifications--- start -----------
       // if(wizardData.formData.selectedSpecifications!=null){
       system.debug('deleteOffSpec-->' +wizardData.deleteOfferingSpecifications);
       if(wizardData.deleteOfferingSpecifications){
           List<PMP_Partner_Offering_Specification__c> exisitingOffSpecs = New List<PMP_Partner_Offering_Specification__c>();
           exisitingOffSpecs = [Select id from PMP_Partner_Offering_Specification__c
                                 Where PMP_Offering_Id__c =: offering.Id];
           if(exisitingOffSpecs.size() > 0 ){
               delete exisitingOffSpecs;
           }
       }
       PMP_Partner_Offering__c oldOffering = [Select Name,PMP_Partner_Offering_Nm__c, PMP_Partner_Offering_Dsc__c,
                                                    PMP_Partner_Offering_Tag_Line_Txt__c from PMP_Partner_Offering__c 
                                                    WHERE Id =: offering.id];
       if(!Test.isRunningTest()){
           PMP_OfferingCategoryHelper.createOfferingCategories(wizardData.formData, offering, wizarddata.currentStep, wizarddata.stepchange);
            PMP_OfferingSpecificationHelper.createOfferingSpecification(wizardData.formData, offering.Id, wizarddata.currentStep, wizarddata.stepchange);
       }
            
       // }
        //Abhishek --------End-----------------
      // we separate these fields out because they are inherently important and relevant to the wizard
      // but they could be renamed in the lightning component to use the respective fields on the record instead
      offering.PMP_Active_Step_Txt__c = String.valueOf(wizardData.activeStep);
      offering.PMP_Current_Step_Txt__c = String.valueOf(wizardData.currentStep);
      List<String> tab0CategoryData = new List<String>();
      if(wizardData.category.contains('|')){
          tab0CategoryData = wizardData.category.split('\\|');//tab0CategoryData structure --> "categoryName|categoryPIMId",split it by '|' and use name only to populate offering field
          offering.PMP_Category_nm__c = tab0CategoryData[0];
      }
        else{
            offering.PMP_Category_nm__c = wizardData.category;
        }
       
        //Added by shahrukh : 11July 2019
        boolean isAdmin = PMP_Utility.isLoggedInUserAdmin();
        
        system.debug('++++++++++++++++'+isAdmin);
        if(isAdmin==false){
           system.debug('++++++++++++++++'+isAdmin);
           offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Draft'; 
        }
        
        string selectedLanguage = wizardData.selectedLanguage;
        string translationSaveType = wizardData.translationSaveType;
        Map<string, PMP_Partner_Offering_Translation__c> fieldAndValueMap = New Map<string,PMP_Partner_Offering_Translation__c>();
        List<PMP_Partner_Offering_Translation__c> updatedTranslation = New List<PMP_Partner_Offering_Translation__c>();
        List<PMP_Partner_Offering_Translation__c> existingtransValues = PMP_Utility.getOfferingTranslationRecords(offering.Id);
        Map<string,string> languageFieldMap = New Map<string,string>();
        List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeMtdList = New List<PMP_Locale_To_FieldAPINm_Mapping__mdt> ();
        //If User is navigating to offering edit via language hyperlinks.(US434806) -----
        
        boolean isTranslationRequired = PMP_Utility.isTranslationRequired(offering);                                           
        if(selectedLanguage!=null){
            //fetching the old offering for comparision and to replace name/desc/tag-line if these fields or not changed in UI or if offering
            //is edited in different language other than its created language.
            
            
            if(existingtransValues.size()>0){
                //creating Map of field name and existing translation records.
                for(PMP_Partner_Offering_Translation__c iterValue : existingtransValues){
                    fieldAndValueMap.put(iterValue.PMP_Field_Nm__c, iterValue );
                }
            }
            PMP_Partner_Offering_Translation__c nameTranslation = fieldAndValueMap.get('PMP_Partner_Offering_Nm__c');
            PMP_Partner_Offering_Translation__c descTranslation = fieldAndValueMap.get('PMP_Partner_Offering_Dsc__c');
            
            PMP_Partner_Offering_Translation__c tagTranslation = fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c')?
                                    fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c') :null;
            localeMtdList = PMP_Utility.getLocaleToFieldMdtRecordsByObject(selectedLanguage,'Offering_Translation');
            Map<string,string> localeCodeLanguageNameMap = New Map<String,string>();
            
            //languageFieldMap is a Map of Locale code and the field to be updated on the translation object based on Language.
            //Ex. if Selected Language = en_US, PMP_English_Txt__c is the field that needs to be updated on the translation records.
            //localeCodeLanguageNameMap Ex. en_US => English. 
            for(PMP_Locale_To_FieldAPINm_Mapping__mdt mapping : localeMtdList ){
                languageFieldMap.put(mapping.PMP_Locale_Nm__c,mapping.PMP_Field_APINm__c );
                localeCodeLanguageNameMap.put(mapping.PMP_Locale_Nm__c, mapping.PMP_Language_Nm__c) ;
            }
            //if offering is edited in a different language it is created in, Only translation records need to be updated 
            if(translationSaveType == 'translation_table'){ 
                string tempName = offering.PMP_Partner_Offering_Nm__c ;
                string tempDesc = offering.PMP_Partner_Offering_Dsc__c;
                string tempTag = offering.PMP_Partner_Offering_Tag_Line_Txt__c;
                system.debug('oldOff-->' +oldOffering.PMP_Partner_Offering_Nm__c);
                //reverting back the offering name and description to earlier value, as we need to make change only on translation record.
                offering.PMP_Partner_Offering_Nm__c = oldOffering.PMP_Partner_Offering_Nm__c;
                offering.PMP_Partner_Offering_Dsc__c = oldOffering.PMP_Partner_Offering_Dsc__c;
                offering.PMP_Partner_Offering_Tag_Line_Txt__c = oldOffering.PMP_Partner_Offering_Tag_Line_Txt__c;
                offering.Name = oldOffering.Name;
                 
                if(isTranslationRequired){ 
                    offering.PMP_Edit_Language_Cd__c = localeCodeLanguageNameMap.get(selectedLanguage);
                    offering.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
                    offering.PMP_Translated_Languages__c = localeCodeLanguageNameMap.get(selectedLanguage);
                }
                system.debug('selectedLanguage'+selectedLanguage);
                system.debug('languageFieldMap'+languageFieldMap);
                system.debug('languageFieldMap.get(selectedLanguage)'+languageFieldMap.get(selectedLanguage));
                system.debug('tempName'+tempName);
                system.debug('nameTranslation'+nameTranslation);
                nameTranslation.put(languageFieldMap.get(selectedLanguage), tempName);
                descTranslation.put(languageFieldMap.get(selectedLanguage), tempDesc);
                if(tagTranslation !=null){
                    tagTranslation.put(languageFieldMap.get(selectedLanguage), tempTag);
                    updatedTranslation.add(tagTranslation);
                }
                updatedTranslation.add(nameTranslation);
                updatedTranslation.add(descTranslation);
                
            
            }
            
            //if offering is edited in same language it is created in, both translation record and offering needs to be updated.
            else if(translationSaveType == 'both'){ 
                
                system.debug('selectedLanguage'+selectedLanguage);
                system.debug('languageFieldMap'+languageFieldMap);
                system.debug('languageFieldMap.get(selectedLanguage)'+languageFieldMap.get(selectedLanguage));
                system.debug('offering.PMP_Partner_Offering_Nm__c'+offering.PMP_Partner_Offering_Nm__c);
                nameTranslation.put(languageFieldMap.get(selectedLanguage), offering.PMP_Partner_Offering_Nm__c);
                descTranslation.put(languageFieldMap.get(selectedLanguage), offering.PMP_Partner_Offering_Dsc__c);  
                if(tagTranslation !=null)
                {
                    tagTranslation.put(languageFieldMap.get(selectedLanguage), offering.PMP_Partner_Offering_Tag_Line_Txt__c);
                    updatedTranslation.add(tagTranslation);
                }  
                if(isTranslationRequired){
                    offering.PMP_Edit_Language_Cd__c = localeCodeLanguageNameMap.get(selectedLanguage);
                    offering.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
                    offering.PMP_Translated_Languages__c = localeCodeLanguageNameMap.get(selectedLanguage);
                }
 
                updatedTranslation.add(nameTranslation);
                updatedTranslation.add(descTranslation);
                
            }
            else {
                //if translationSaveType == null, this means name/desc/tagline is not edited in the UI, so we need to revert back to old offering value.
                offering.PMP_Partner_Offering_Nm__c = oldOffering.PMP_Partner_Offering_Nm__c;
                offering.PMP_Partner_Offering_Dsc__c = oldOffering.PMP_Partner_Offering_Dsc__c;
                offering.PMP_Partner_Offering_Tag_Line_Txt__c = oldOffering.PMP_Partner_Offering_Tag_Line_Txt__c;
                offering.Name = oldOffering.Name;
            
            }
        
        }
        else{ //wiping out edited language if selected language is null.
            offering.PMP_Edit_Language_Cd__c = null;
           if (offering.PMP_Partner_Offering_Nm__c != oldOffering.PMP_Partner_Offering_Nm__c ||
                offering.PMP_Partner_Offering_Dsc__c != oldOffering.PMP_Partner_Offering_Dsc__c || 
                offering.PMP_Partner_Offering_Tag_Line_Txt__c != oldOffering.PMP_Partner_Offering_Tag_Line_Txt__c){ //Translated Language values reset
                    system.debug('inside elseIf-->434');
                    offering.PMP_Translated_Languages__c = offering.PMP_Offering_Language_Nm__c;
                    offering.PMP_Translation_Lifecycle_Status_nm__c = isTranslationRequired ?'Pending' : offering.PMP_Translation_Lifecycle_Status_nm__c;
            }
        }
        upsert offering; // updates offering record
        if(!updatedTranslation.isEmpty()){
            update updatedTranslation;
        }
        // End of Part1 of US434806 -----
      

      // creating offering resources records for the offering when navigating from tab4 to tab5
      if((wizarddata.currentStep-wizarddata.stepchange) == 3){
          PMP_OfferingResourceHelper.createOfferingResource(wizardData.formData, offering.Id);
      }
      
      //creating offering category records for top 2 categories(i.e ultimate parent and category selected on tab0) related to the offering
      if(String.isBlank(offering.PMP_Partner_Offering_Nm__c)){
            PMP_CreateOfferingTab0Service.createTopLevelOffCategoriesRecord(offering.id, tab0CategoryData[1]);
      } 
        
        //PMP_CreateOfferingTab5Service.generateThumbnailImages(offering.Id);
            system.debug('Lang-->'+ selectedLanguage );
      // Rebuild the wizard data response (reflecting any new changes)
      
        /* --------------------- Part2 of US434806 -----
        *Once the offering and translation records are saved, we need to display the updated values on the UI,
        * therefore, replacing offering name,description and tagline values in the below if else blocks. 
        
        */      
      
            if(selectedLanguage !=null &&  !updatedTranslation.isEmpty()){
            system.debug('insideif--lang');
                Map<string,PMP_Partner_Offering_Translation__c > updtdFieldAndValueMap = New Map<string,PMP_Partner_Offering_Translation__c >();
                    for(PMP_Partner_Offering_Translation__c iterValue : updatedTranslation){
                        updtdFieldAndValueMap.put(iterValue.PMP_Field_Nm__c, iterValue );
                    }
                    offering.PMP_Partner_Offering_Nm__c = string.valueOf(updtdFieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(selectedLanguage)));
                    offering.PMP_Partner_Offering_Dsc__c = string.valueOf(updtdFieldAndValueMap.get('PMP_Partner_Offering_Dsc__c').get(languageFieldMap.get(selectedLanguage)));
                    offering.PMP_Partner_Offering_Tag_Line_Txt__c = updtdFieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c')?
                                string.valueOf(updtdFieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(selectedLanguage))):offering.PMP_Partner_Offering_Tag_Line_Txt__c ;
                
            }
            
            else if(selectedLanguage !=null &&  updatedTranslation.isEmpty()){
                    system.debug('insideelseif--lang');
                    system.debug('selectedLanguage'+selectedLanguage);
                system.debug('languageFieldMap'+languageFieldMap);
                system.debug('languageFieldMap.get(selectedLanguage)'+languageFieldMap.get(selectedLanguage));
                system.debug('offering.PMP_Partner_Offering_Nm__c'+offering.PMP_Partner_Offering_Nm__c);
                    offering.PMP_Partner_Offering_Nm__c = string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(selectedLanguage)));
                    offering.PMP_Partner_Offering_Dsc__c = string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Dsc__c').get(languageFieldMap.get(selectedLanguage)));
                    offering.PMP_Partner_Offering_Tag_Line_Txt__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c')?
                     string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(selectedLanguage))) :null;
                   // offering.PMP_Partner_Offering_Tag_Line_Txt__c = 'Working';
            }
            //-----------End of Part2 of US434806    ------------------
            system.debug(' Limits--> Before Build Response' +'Soql: ' +limits.getQueries()+' Dml : '+ Limits.getDMLStatements());    
            Intel_WizardData response = buildResponse(offering,selectedLanguage);
            system.debug('Limits-->' +'Soql: ' +limits.getQueries()+' Dml : '+ Limits.getDMLStatements());
            return JSON.serialize(response);



    }

    @AuraEnabled(cacheable=true)
    public static String refreshData(String request) {
      // THIS METHOD REFRESHES WITH NEW DATA, BUT WITHOUT SAVING
      Intel_WizardData wizardData = (Intel_WizardData)JSON.deserialize(request, Intel_WizardData.class);
      PMP_Partner_Offering__c offering = wizardData.formData.offering;
      offering.PMP_Active_Step_Txt__c = String.valueOf(wizardData.activeStep);
      offering.PMP_Current_Step_Txt__c = String.valueOf(wizardData.currentStep);
        if(wizardData.category.contains('|')){
            List<String> tab0CategoryData = wizardData.category.split('\\|');
            offering.PMP_Category_nm__c = tab0CategoryData[0];
        }
        else{
            offering.PMP_Category_nm__c = wizardData.category;
        }

      // HANDLE REFRESH DATA HERE
      // TODO: selectedCategories
      // wizardData.formData.selectedCategories
      // TODO: selectedSpecifications

      // Rebuild the wizard data response (reflecting any new changes)
      Intel_WizardData response = buildResponse(offering,null);
      
      return JSON.serialize(response);
    }

    // FOR DEVELOPMENT ONLY -- to be deleted
    @AuraEnabled
    public static Id createRecord() {

      PMP_Partner_Offering__c offering = new PMP_Partner_Offering__c();
      offering.PMP_Active_Step_Txt__c = '0';
      offering.PMP_Current_Step_Txt__c = '0';
      offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Draft';
      offering.PMP_Offering_Status_Update_Dt__c = system.now();
      offering.PMP_Offering_Language_Nm__c = 'English'; //US 378929 - Added by Manasa
      offering.PMP_Partner_Offering_Visibility_Nm__c = 'Public Content'; //US 406710 - Added by 
      //offering.PMP_Pre_Release_Check_Nm__c='No';
      insert offering;
      system.debug('##offering:->'+offering);
      return offering.Id;

    }

    //Added by raj to fetch all top level categories for US321536
    @AuraEnabled(cacheable=true)
    public static String getCategoryList(){
        List<PMP_CreateOfferingTab0Service.CategoryWrapper> categories=PMP_CreateOfferingTab0Service.fetchTopLevelCategories();
        return JSON.serialize(categories);
    }
    /*-------------------End US321536------------------------------------------------------*/
    //Added by Manasa to get duplicate offering name check for US340188 - moved to validateOfferingData method
    @AuraEnabled(cacheable=true)
    public static Integer isDuplicateOfferingServerCall(string strOfferingName, string offeringId, string companyId){
        system.debug('offeringId in controller: ' + offeringId);
            system.debug('companyId in controller: ' + companyId);
            system.debug('strOfferingName in controller: '+ strOfferingName);
        Integer checkDuplicateOff = PMP_CheckIfDuplicateOffering.isDuplicateOffering(strOfferingName,offeringId,companyId);
        return checkDuplicateOff;
    }
    
    //added by raj to handle submit for US341586
    /**
    * @description-submit the offering to admin and change the status to 'Admin Review'
    * @param submitRequest the data related to the offering
    * @return void
    * Method Parameters - String
    */
    @AuraEnabled 
    public static void submitOffering(String submitRequest,string userSelectedLanguage){
        Intel_FormData formData = (Intel_FormData)JSON.deserialize(submitRequest,Intel_FormData.class);
        PMP_Partner_Offering__c offering =formData.offering;
        //Commneted by Abhishek ---- 
    /*    // Sandhya US415145 - Get the Business Value populated in the offering and compare it with Custom metadata
        List<PMP_Business_Segments__mdt> bizValuesFromMetaData = new List<PMP_Business_Segments__mdt>();
        bizValuesFromMetaData = [SELECT DeveloperName FROM PMP_Business_Segments__mdt];
        //system.debug('bizValuesFromMetaData--------'+bizValuesFromMetaData);
        List<PMP_Partner_Offering__c> offeringRec = [select PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Edit_Language_Cd__c,PMP_Translation_Lifecycle_Status_nm__c,PMP_Offering_Language_Nm__c,PMP_Partner_Offering_Dsc__c,PMP_Translated_Languages__c,
                                                    PMP_Partner_Offering_Tag_Line_Txt__c from PMP_Partner_Offering__c where id=:offering.Id LIMIT 1 ];
        system.debug('transStatus before-->' +offeringRec[0].PMP_Translation_Lifecycle_Status_nm__c );
        //Added by Abhishek
        system.debug('insideLT-->' +userSelectedLanguage);
    /*    if(userSelectedLanguage == null && offeringRec[0].PMP_Translation_Lifecycle_Status_nm__c == 'Not Applicable'){ //This field needs to be stamped, only when
            
            offeringRec[0].PMP_Translated_Languages__c = offeringRec[0].PMP_Offering_Language_Nm__c;
        } 
                                             
      // system.debug('offering Translation LC----'+offeringRec[0].PMP_Translation_Lifecycle_Status_nm__c);
        system.debug('transStatus after-->' +offeringRec[0].PMP_Translation_Lifecycle_Status_nm__c );
        List<String> finalBizSegmentValues;
        if(offeringRec!=null ){
            finalBizSegmentValues = offeringRec[0].PMP_Business_Segment_Nm__c.split(';');
        }
        
        if(offeringRec[0].PMP_Business_Segment_Nm__c != null){
           if(!bizValuesFromMetaData.isEmpty() ){ 
               for(PMP_Business_Segments__mdt bizValueRec :bizValuesFromMetaData){
                   
                    if(finalBizSegmentValues.contains(bizValueRec.DeveloperName ) ){
                        
                       // offeringRec[0].PMP_Translation_Lifecycle_Status_nm__c = 'Pending';  
                        break;
                    }
                }
            }
         }
         system.debug('status after-->' +offeringRec[0].PMP_Partner_Offering_Lifecycle_Status_Nm__c);
            //offeringRec.PMP_Translated_Languages__c = null; */
         //We need to requery the offering to replace the translation values.   
         PMP_Partner_Offering__c offeringRec = [select PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Edit_Language_Cd__c,PMP_Translation_Lifecycle_Status_nm__c,PMP_Offering_Language_Nm__c,PMP_Partner_Offering_Dsc__c,PMP_Translated_Languages__c,
                                                    PMP_Partner_Offering_Tag_Line_Txt__c from PMP_Partner_Offering__c where id=:offering.Id LIMIT 1 ];
        offeringRec.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Admin Review';
        
        try{
            
            update offeringRec;
            if(String.isEmpty(userSelectedLanguage)){ //if only fresh offering
                PMP_CreateLanguageTranslations.updateLanguageTranslation(offering);
            }
            
            
            PMP_CreateOfferingTab5Service.generateThumbnailImages(offering.Id);
          
        }
               
        catch(Exception e){
            system.debug(e.getMessage()+e.getLineNumber());
        }
        
    }
    
    /*------------------End US341586------------------------------------------------------*/


   /*--------------------Prakash : US340229 - Start --------------------------------------------------*/
   /**
    * @description Cancel the current offering i.e delete if it is not pubished yet
    *               else sync back the current working copy with published version
    * @param offeringId  the Id of the offering you are canceling
    * @return void
    * Method Parameters - String
    * +Lalit/US614314 : Commented  
    */
  /* @AuraEnabled
    public static void cancelOffering(Id offeringId){

        Savepoint sp = Database.setSavepoint();
        try{
            boolean isAdmin = PMP_Utility.isLoggedInUserAdmin();

            if(isAdmin==false){
                List<PMP_Partner_Offering__c> offerings = [Select Id,PMP_Partner_Offering_Lifecycle_Status_Nm__c
                                                    FROM PMP_Partner_Offering__c  WHERE PMP_Working_Copy_Id__c = :offeringId or ID = :offeringId] ;

                if(offerings != null && offerings.size() == 2){ // TODO : Chcek for the exact identifier
                    system.debug('###Synching with published version');
                    syncBackWorkingCopyWithPublishedVersion(offeringId);
                }else{
                    delete offerings[0];
                }
            }
        }Catch(Exception ex) {
            Database.rollback(sp);
        }
    }
    @TestVisible
    private static void syncBackWorkingCopyWithPublishedVersion(Id offeringId) {

                List<Id> offeringIds = new List<Id>();
        offeringIds.add(offeringId);
            Id publishedOfferingId = [Select Id,PMP_Working_Copy_Id__c from PMP_Partner_Offering__c WHERE PMP_Working_Copy_Id__c = :offeringId].Id;
            List<Id> publishedIds = new List<Id>();
            publishedIds.add(publishedOfferingId);

            DescribeSObjectResult offeringFields = PMP_Partner_Offering__c.getSObjectType().getDescribe();
            List<String> offeringFieldNames = new List<String>( offeringFields.fields.getMap().keySet() );
            String offeringQuery =    ' SELECT ' +    String.escapeSingleQuotes(String.join( offeringFieldNames, ',' )) +    ' FROM ' +          String.escapeSingleQuotes(offeringFields.getName()) +    ' WHERE ' +         ' ID  IN : publishedIds';
            List<PMP_Partner_Offering__c> tempOfferingList = Database.query(offeringQuery);

            List<PMP_Partner_Offering__c> offeringsToBeSynched = new List<PMP_Partner_Offering__c>();
            for(PMP_Partner_Offering__c offering:tempOfferingList){
                PMP_Partner_Offering__c clonedOffering = new PMP_Partner_Offering__c();
                clonedOffering = offering.clone(false,false,false,false);
                clonedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
                clonedOffering.Id = offering.PMP_Working_Copy_Id__c;
                clonedOffering.PMP_Working_Copy_Id__c = null;
                //Set additional fields here like PMP_Offering_Status_Update_Dt__c,PMP_Partner_Offering_Sync_Status_Nm__c
                offeringsToBeSynched.add(clonedOffering);
            }


            if(!offeringsToBeSynched.isEmpty()){
                system.debug('###Synching offeringsToBeSynched');
                Update offeringsToBeSynched;

                List<PMP_Partner_Offering_Category__c> clonedOffCatList = new List<PMP_Partner_Offering_Category__c>();
                List<PMP_Partner_Offering_Specification__c> clonedOffSpecList = new List<PMP_Partner_Offering_Specification__c>();
                List<PMP_Partner_Offering_Resource__c> clonedOffResList = new List<PMP_Partner_Offering_Resource__c>();

                DescribeSObjectResult offCatFields = PMP_Partner_Offering_Category__c.getSObjectType().getDescribe();
                List<String> catFieldNames = new List<String>( offCatFields.fields.getMap().keySet() );
                String offCatQuery =    ' SELECT ' +        String.escapeSingleQuotes(String.join( catFieldNames, ',' )) +    ' FROM ' +         String.escapeSingleQuotes(offCatFields.getName()) +    ' WHERE ' +         ' PMP_Offering_Id__c  IN : publishedIds';
                List<PMP_Partner_Offering_Category__c> tempCatList = Database.query(offCatQuery);
                for(PMP_Partner_Offering_Category__c offCat:tempCatList){
                    PMP_Partner_Offering_Category__c clonedOffCat = new PMP_Partner_Offering_Category__c();
                    clonedOffCat = offCat.clone(false,true,true,true);
                    clonedOffCat.PMP_Offering_Id__c = offeringId;
                    clonedOffCat.CreatedById = offCat.CreatedById;
                    clonedOffCatList.add(clonedOffCat);
                }

                //Get all the fields of offering specification to copy using clone
                DescribeSObjectResult offSpecFields = PMP_Partner_Offering_Specification__c.getSObjectType().getDescribe();
                List<String> specFieldNames = new List<String>( offSpecFields.fields.getMap().keySet() );
                String offSpecQuery =    ' SELECT ' +       String.escapeSingleQuotes(String.join( specFieldNames, ',' )) +    ' FROM ' +          String.escapeSingleQuotes(offSpecFields.getName()) +    ' WHERE ' +         ' PMP_Offering_Id__c  IN : publishedIds';
                List<PMP_Partner_Offering_Specification__c> tempSpecList = Database.query(offSpecQuery);

                for(PMP_Partner_Offering_Specification__c offSpec:tempSpecList){
                    PMP_Partner_Offering_Specification__c clonedOffSpec = new PMP_Partner_Offering_Specification__c();
                    clonedOffSpec = offSpec.clone(false,true,true,true);
                    clonedOffSpec.PMP_Offering_Id__c = offeringId;
                    clonedOffSpec.CreatedById = offSpec.CreatedById;
                    clonedOffSpecList.add(clonedOffSpec);
                }

                //Get all the fields of offering Resources to copy using clone
                DescribeSObjectResult offResFields = PMP_Partner_Offering_Resource__c.getSObjectType().getDescribe();
                List<String> resFieldNames = new List<String>( offResFields.fields.getMap().keySet() );
                String offResQuery =    ' SELECT ' +      String.escapeSingleQuotes(String.join( resFieldNames, ',' )) +    ' FROM ' +         String.escapeSingleQuotes(offResFields.getName()) +    ' WHERE ' +         ' PMP_Offering_Id__c  IN : publishedIds';
                List<PMP_Partner_Offering_Resource__c> tempResList = Database.query(offResQuery);
                for(PMP_Partner_Offering_Resource__c offResc:tempResList){
                    PMP_Partner_Offering_Resource__c clonedOffResc = new PMP_Partner_Offering_Resource__c();
                    clonedOffResc = offResc.clone(false,true,true,true);
                    system.debug('###:->'+offResc);
                    if(offResc.PMP_Resource_Type_Nm__c==PMP_StaticConstants_Offering.IMAGE && offResc.PMP_Partner_Offering_Image__c != ''){
                        List<ContentVersion>  content=[SELECT Id, Title, IsLatest, PathOnClient,VersionData
                                 FROM ContentVersion where ContentDocumentId=:offResc.PMP_Partner_Offering_Image__c AND IsLatest=true LIMIT 1];
                        ContentVersion newContent = new ContentVersion();
                        if(!content.isEmpty()) {
                            newContent.Title  = content[0].Title;
                            newContent.PathOnClient  = content[0].PathOnClient;
                            newContent.VersionData = content[0].VersionData;
                            insert newContent;
                        }
                        system.debug('###newContent:->'+newContent);
                        ContentVersion  newContentDocId;

                        if (Schema.sObjectType.ContentVersion.isAccessible() && newContent != null && string.isNotBlank(newContent.ContentDocumentId)){
                            newContentDocId=[SELECT Id,IsLatest, ContentDocumentId FROM ContentVersion where Id=:newContent.Id AND IsLatest=true limit 1];
                            clonedOffResc.PMP_Partner_Offering_Image__c=newContent.ContentDocumentId;
                        }
                    }
                    clonedOffResc.PMP_Offering_Id__c = offeringId;
                    clonedOffResc.CreatedById = offResc.CreatedById;
                    clonedOffResList.add(clonedOffResc);
                }


                //Delete offering transaction records
                List<PMP_Partner_Offering_Category__c> offeringCategoryRecords = [SELECT Id FROM PMP_Partner_Offering_Category__c
                                                                                                WHERE PMP_Offering_Id__c IN : offeringIds];

                if(!offeringCategoryRecords.isEmpty()){
                    system.debug('###delete offeringCategoryRecords'+ offeringCategoryRecords.size());
                    delete offeringCategoryRecords;
                }

                List<PMP_Partner_Offering_Specification__c> offeringSpecificationRecords = [select id from PMP_Partner_Offering_Specification__c
                                                                                            where PMP_Offering_Id__c IN :offeringIds];

                if(!offeringSpecificationRecords.isEmpty()){
                    system.debug('###delete offeringSpecificationRecords:->'+offeringSpecificationRecords.size());
                    delete offeringSpecificationRecords;
                }

                List<PMP_Partner_Offering_Resource__c> offerigResourceRecords = [select id from PMP_Partner_Offering_Resource__c
                                                                                    where PMP_Offering_Id__c IN :offeringIds];

                if(!offerigResourceRecords.isEmpty()){
                    system.debug('###deleting offerigResourceRecords:->'+offerigResourceRecords.size());
                    delete offerigResourceRecords;
                }

                //Insert new records
                if(!clonedOffCatList.isEmpty()){
                    system.debug('###inserting clonedOffCatList:->'+clonedOffCatList);
                   insert clonedOffCatList;
                }

                if(!clonedOffSpecList.isEmpty()){
                    system.debug('###inserting clonedOffSpecList:->'+clonedOffSpecList);
                   insert clonedOffSpecList;
                }

                if(!clonedOffResList.isEmpty()){
                    system.debug('###inserting clonedOffResList:->'+clonedOffResList);
                   insert clonedOffResList;
                }
            }
    }  */
    /*------------------Prakash : US340229 - End ------------------------------------------------------*/

   
    //Gireesh:US364045:GET ADMIN DETAILS
    @AuraEnabled(cacheable=true)
    public static PMP_LightningServerResponse  getAdminDetails(Id offeringId) {
        map<string,object> adminDetails = new map<string,object>();
        map<String, Object> mapErrorInfo = new map<string,object>();


        Profile profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String profileName = profile.Name;
        User user;

        if(profileName!=null){
            user=[SELECT Id, Name FROM User where Id=:userinfo.getUserId() Limit 1];

        } 

        //Get public group members
        Group grp=[SELECT Id FROM Group where Name='PMP - All Intel Admin Users' LIMIT 1];
        List<GroupMember> groupMembers=[SELECT UserOrGroupId FROM GroupMember where GroupId=:grp.Id];
        List<Id> userIds=new List<Id>();
        for (GroupMember groupMember: groupMembers){
            userIds.add(groupMember.UserOrGroupId);
        }
        List<User> admins=[SELECT Id, Name FROM User where Id in :userIds];

        //Get Current Admin
        
        String finalBusinessSegment;
        PMP_Partner_Offering__c currentAdmin=[SELECT PMP_Intel_Admin_Id__c,PMP_Intel_Admin_Nm__c, PMP_Partner_Offering_Lifecycle_Status_Nm__c,toLabel(PMP_Business_Segment_Nm__c) from PMP_Partner_Offering__c where Id=:offeringId LIMIT 1];
        //Sandhya : US379001 - Get Business Segment values from Partner OfferingList<PMP_Partner_Offering__c> businessSegment = [select PMP_Business_Segment_Nm__c from PMP_Partner_Offering__c where Id=:offeringId AND PMP_Business_Segment_Nm__c!= NULL LIMIT 1];
        List<String> finalBusinessValues = new List<String>();
        system.debug('businessSegment in Class-------------'+currentAdmin.PMP_Business_Segment_Nm__c);
        system.debug('Inside If---');
        if(currentAdmin != null && currentAdmin.PMP_Business_Segment_Nm__c != null){
            List<String> businessSegmentValues = currentAdmin.PMP_Business_Segment_Nm__c.split(';');
            for(String businessValueRec : businessSegmentValues){
                String businessVal = businessValueRec;
                finalBusinessValues.add(businessVal);
            }            //Sandhya : US379001 - Adding the business Segment Values to Map
            adminDetails.put('businessSegment',finalBusinessValues);   
        }
        adminDetails.put('loggedInUser',user); 
        adminDetails.put('adminUsers',admins);
        adminDetails.put('currentAdmin',currentAdmin); 
        
        Map<String,String> pickListValuesMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = PMP_Partner_Offering__c.PMP_Partner_Offering_Lifecycle_Status_Nm__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
        }     
        adminDetails.put('pickListValuesMap',pickListValuesMap);
        
        return new PMP_LightningServerResponse(true,mapErrorInfo,adminDetails);
    }
    //Gireesh:US364045:Save Admin Details
    @AuraEnabled
    public static String saveAdminDetails(Id offeringId, String selectedAdmin, String selectedOfferingStatus) {
        PMP_Partner_Offering__c adminDetails=[SELECT Id, PMP_Intel_Admin_Id__c, PMP_Active_Step_Txt__c, PMP_Current_Step_Txt__c, PMP_Intel_Admin_Nm__c, PMP_Partner_Offering_Lifecycle_Status_Nm__c from PMP_Partner_Offering__c where Id=:offeringId LIMIT 1];
        adminDetails.PMP_Intel_Admin_Id__c=selectedAdmin;
        adminDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c=selectedOfferingStatus;
        adminDetails.PMP_Active_Step_Txt__c='4';
        adminDetails.PMP_Current_Step_Txt__c='4';
        try{
            update adminDetails;
        }catch(exception e){
            return 'error';
        }
        return 'saved';
    }
 
    
    /*Gireesh:US378991:check if any pre-release items are selected*/
     @AuraEnabled(cacheable=true)
    public static Boolean getOffSetValues(Id offeringId){
        return PMP_SpecificationController.getOffSetValues(offeringId);
    }
    
    /**
    * Added by raj to restrict editing for external users (US428208)
    @description returns true if logged in user has create offering access
    @param NA
    @return boolean
    @Method Parameters NA
    */
    @AuraEnabled(cacheable=true)
    public static Boolean getCreateOfferingAccess(){
        
        return Schema.sObjectType.PMP_Partner_Offering__c.isCreateable();       
    }
    /*-------------------------End---------------------------------*/
    
    @AuraEnabled(cacheable=true)
    public static Integer validateOfferingDataServerCall(String checkRequestData){
        Integer status;
        Intel_FormData formData = (Intel_FormData)JSON.deserialize(checkRequestData,Intel_FormData.class);
        //PMP_Partner_Offering__c offering = formData.offering;
        
        status = PMP_CreateOfferingTab1Service.validateOfferingData(formData);
        
        return status;
        
    }
    
}