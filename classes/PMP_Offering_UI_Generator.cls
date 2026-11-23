@isTest
/****************************************************************************************************************************************
* Class Name  : PMP_Offering_UI_Generator 
* Version     : 1.0 
* Created Date: 04-28-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Prakash                        04-28-2019                    Created for displaying UI elements in 'Create Offering' components
****************************************************************************************************************************************************************/
public with sharing class PMP_Offering_UI_Generator {
    
    

//     /** 
//     * @description create a step
//     * @param stepName name of the step
//     * @return a step
//     */
//     public static final string levelThreeCategory = 'NPP_03';
//     public static final string levelTwoCategory = 'NPP_02';
    
//     public static Intel_Step createStep(string stepName){
//         Intel_Step newStep = new Intel_Step(stepName);
//         return newStep;
//     }
        
    
//    /** 
//     * @description create a section
//     * @param sectionName name of the section
//     * @return a section
//     */
//     public static Intel_Section createSection(string sectionName){
//         Intel_Section newSection = new Intel_Section(sectionName);
//         return newSection;
//     }
    
//     /** 
//     * @description create a sub section
//     * @param subSectionName name of the section
//     * @return a Subsection
//     */
//     public static Intel_Subsection createSubsection(string subSectionName){
//         Intel_Subsection newSubsection = new Intel_Subsection(subSectionName);
//         newSubsection.showHeadline = true;
//         return newSubsection;
//     }
    
//     /** 
//     * @description create a section
//     * @param sectionName name of the section
//     * @return a section
//     */
//     public static Intel_Label createLabel(string labelText){
//         Intel_Label newLabel = new Intel_Label();
//         newLabel.label=labelText;
//         return newLabel;
//     }
//     /** 
//     * @description create a drop down
//     * @param fieldAPIName - field api name of the dropdown
//     * @param fieldLabel - label of the dropdown
//     * @param objAPIName - object api name from which picklist is getting described
//     * @param required - to display a field as required in UI
//     * @param isOfferingField - exist this field on offering object or not
//     * @return Intel_Dropdown 
//     * Method Parameters - String,String,String,Boolean,Boolean 
//     */
//     public static Intel_Dropdown createDropdown(string fieldAPIName,string fieldLabel,string objAPIName,boolean required,string objectApiName){
//         Intel_Dropdown dropDown = new Intel_Dropdown(fieldAPIName, objAPIName); 
//         //system.debug('dropDown'+dropDown);
//         dropDown.fieldName = fieldAPIName;
//         dropDown.label = fieldLabel;
//         dropDown.required = required;
//         dropDown.apiName = objectApiName;
//         dropDown.layoutItemMediumDeviceSize = 6;
        
//         return dropDown;
//     }
//     /** 
//     * @description create a drop down
//     * @param nameById - map of record Id and Name
//     * @param fieldAPIName - field api name of the dropdown
//     * @param fieldLabel - label of the dropdown
//     * @param required - requiredness of the field in UI
//     * @param isOfferingField - exist this field on offering object or not
//     * @return a Intel_Dropdown 
//     * Method Parameters - Map<Id,String>,String,String,Boolean,Boolean
//     */
//     public static Intel_Dropdown createDropdown(Map<Id,String> nameById,string fieldAPIName,string fieldLabel, boolean required, string objectApiName){
//         Intel_Dropdown dropDown = new Intel_Dropdown(nameById);
//         //system.debug('dropDown Map'+dropDown);
//         dropDown.fieldName = fieldAPIName;
//         dropDown.label = fieldLabel;
//         dropDown.required = required;
//         dropDown.apiName = objectApiName;
//         dropDown.layoutItemSize = 6;
//         dropDown.layoutItemMediumDeviceSize = 6;
//         return dropDown;
//     }
//     /** 
//     * @description create a drop down
//     * @param nameByName - record name by record name of the dropdown
//     * @param fieldAPIName - field api name of the dropdown
//     * @param fieldLabel - label of the dropdown
//     * @param required - requiredness of the field in UI
//     * @return a Intel_Dropdown 
//     * Method Parameters - Map<String,String>,String,String,Boolean
//     */
//     public static Intel_Dropdown createDropdown(Map<String,String> nameByName,string fieldAPIName,string fieldLabel, boolean required){
//         Intel_Dropdown dropDown = new Intel_Dropdown(nameByName);
//         //system.debug('dropDown Map'+dropDown);
//         dropDown.fieldName = fieldAPIName;
//         dropDown.label = fieldLabel;
//         dropDown.required = required;
//         dropDown.layoutItemSize = 6;
//         dropDown.layoutItemMediumDeviceSize = 6;
//         return dropDown;
//     }
    
//     /** 
//     * @description create a text box and associate to offering object
//     * @param fieldAPIName - field api name of the text box
//     * @param fieldLabel - label of the text box
//     * @param required - requiredness of the field in UI
//     * Method Parameters - String,String,Boolean
//     * @return a text box
//     */
//     public static Intel_Text createText(string fieldAPIName,string fieldLabel, boolean required){
//         Intel_Text textBox = new Intel_Text();
//         //system.debug('fieldAPIName:'+fieldAPIName+':'+fieldLabel);
//         textBox.fieldName = fieldAPIName;
//         textBox.label = fieldLabel;
//         textBox.required = required;
//         textBox.layoutItemMediumDeviceSize = 6;
//         return textBox;
//     }
    
//     /** 
//     * @description create a text box 
//     * @param fieldAPIName - field api name of the text box
//     * @param fieldLabel - label of the text box
//     * @param required - requiredness of the field in UI
//     * @param isOfferingField - exist this field on offering object or not
//     * Method Parameters - String,String,Boolean,Boolean
//     * @return a text box
//     */
//     public static Intel_Text createText(string fieldAPIName,string fieldLabel, boolean required, string objectApiName){
//         Intel_Text textBox = new Intel_Text();
//         textBox.fieldName = fieldAPIName;
//         textBox.label = fieldLabel;
//         textBox.apiName = objectApiName;
//         textBox.required = required;
//         textBox.layoutItemMediumDeviceSize = 6;
//         return textBox;
//     }
    
//     public static Intel_Text createTextTemp(string fieldAPIName,string fieldLabel, boolean required, string objectApiName,string fieldValue){
//         Intel_Text textBox = new Intel_Text();
//         textBox.fieldName = fieldAPIName; 
//         textBox.label = fieldLabel;
//         textBox.apiName = objectApiName;
//         textBox.required = required;
//         textBox.layoutItemMediumDeviceSize = 6;
//         return textBox;
//     }
//     /** 
//     * @description create a rich text box
//     * @param fieldAPIName - field api name of the rich text box
//     * @param fieldLabel - field label of the rich text box
//     * @param errorMessage message to display if rich text box is blank
//     * @param required - requiredness of the field in UI
//     * @param isOfferingField - exist this field on offering object or not
//     * Method Parameters - String,String,String,Boolean,Boolean
//     * @return a text box
//     */
//     public static Intel_RichText createRichText(string fieldAPIName,string fieldLabel,string errorMessage, boolean required,string objectApiName){
//         Intel_RichText richTextBox = new Intel_RichText();
//         richTextBox.fieldName = fieldAPIName;
//         richTextBox.label = fieldLabel;
//         richTextBox.required = required;
//         richTextBox.apiName = objectApiName;
//         richTextBox.formats = 'bold,list,indent,header';
//         richTextBox.errorMessage = errorMessage;
//         richTextBox.layoutItemSize = 12;
//         return richTextBox;
//     }
    
//    /** 
//     * @description create a date field
//     * @param subType - type of text box ,for Date it is  'date'
//     * @param fieldAPIName -  api name of the date field
//     * @param fieldLabel - label of the date field
//     * @param required - requiredness of the field in UI
//     * @param isOfferingField - exist this field on offering object or not
//     * @return a date field
//     */
//     public static Intel_Text createDate(string subType,string fieldAPIName,string fieldLabel,boolean required,string objectApiName){
//         Intel_Text dateField = new Intel_Text(subType);
//         dateField.fieldName = fieldAPIName;
//         dateField.label = fieldLabel;
//         dateField.required = required;
//         dateField.apiName = objectApiName;
//         dateField.layoutItemMediumDeviceSize = 6;
//         return dateField;
//     }
    
//    /** 
//     * @description create a checkbox field
//     * @param name -  api name of the check box field
//     * @param label - label of the check box field
//     * @return a check box field
//     */
//     /*public static Intel_Checkbox createCheckbox(string name,string label){
//           Intel_Checkbox check = new Intel_Checkbox();
//           check.doNotSave = true;
//           check.interactionType = 'parent'; 
//           check.label = label;
//           check.required = true;
//           Intel_CheckboxOption opt = new Intel_CheckboxOption('Client', 'Client');
//           Intel_CheckboxOption opt2 = new Intel_CheckboxOption('IoT', 'IoT');
//           Intel_CheckboxOption opt3 = new Intel_CheckboxOption('Server', 'Server');
//           opt.children.add(opt2);
//           opt.children.add(opt3);
//           check.options.add(opt);
//           for (Integer i = 0; i < 2; i++) {
//             Intel_CheckboxOption optmock = new Intel_CheckboxOption('Mock #' + i, 'MOCKIDXX' + i);
//             for (Integer j = 0; j < 2; j++) {
//               Intel_CheckboxOption optmock1 = new Intel_CheckboxOption('Sub Mock #' + i, 'MOCKIDXX' + i + 'XX' + j);
//               for (Integer k = 0; k < 2; k++) {
//                 Intel_CheckboxOption optmock2 = new Intel_CheckboxOption('Sub Sub Mock #' + k, 'MOCKIDXX' + i + 'XX' + j + 'XX' + k);
//                 optmock1.children.add(optmock2);
//               }
//               optmock.children.add(optmock1);
//             }
//             check.options.add(optmock);
//             }
//             return check;
//    }*/
    
//     //TODO : make this method more dynamic
//     public static Intel_Checkbox checkboxSearch() {
//       Intel_Checkbox chk = new Intel_Checkbox();
//       chk.interactionType = 'parent';
//       chk.accordionType = 'search';
//       chk.valueType = 'complex';
//       return chk;
//     }
    
//        /** 
//     * @description create a uploader field
//     * @param offering - offering object
//     * @return a uploader field
//     */
//     public static Intel_Uploader createUploader(PMP_Partner_Offering__c offering,boolean required){
//         Intel_Uploader uploader = new Intel_Uploader();
//         uploader.recordIdForUpload=offering.Id;
//         uploader.required=required;
//         return uploader;
//     }
//     /** 
//     * @description create a uploader field
//     * @param offering - offering object
//     * @return a uploader field
//     */
//     public static Intel_Video_Uploader createVideoUploader(PMP_Partner_Offering__c offering,boolean required){
//         Intel_Video_Uploader videoUploader = new Intel_Video_Uploader();
//         videoUploader.offeringId=offering.Id;
//         videoUploader.required=required;
//         return videoUploader;
//     }

    
//     public static Intel_Resources createResources(){
//         Intel_Resources resources=new Intel_Resources();
//         Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('PMP_Partner_Offering_Resource__c').getDescribe().fields.getMap().get('PMP_Resource_Type_Nm__c').getDescribe();
//         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
//         for (Schema.PicklistEntry pickListVal : ple){
//           if(pickListVal.getValue() != 'Web Page' && pickListVal.getValue() != 'Additional Resources' && pickListVal.getValue() != 'Image' && pickListVal.getValue() != 'Thumbnail Image') { //TODO : move to constants
//                resources.typeOptions.add(new Intel_DropdownOption(pickListVal.getLabel(), pickListVal.getValue()));
//           }
//         }
//         return resources;
//     }
    
    
//     /** 
//     * @description create a drop down combo field - this will display category, sub category 
//     *               and sub sub category information
//     * @param categoryWrapper - contains category and its childs information in a wrapper format
//     * @return a Intel_DropdownRadioCombo field
//     */
//     public static Intel_DropdownRadioCombo createCategoriesDropDownRadioCombo(List<PMP_CategoryController.Core_PMP_OfferingCategory> categoryWrapper,Set<string> offCatIds){
//             //Gireesh:US692547:Dynamic label
//         List<Object> params = new List<Object>{''};
//         String formatted = '';
//         Map<string,string> categoryPicklistMap = new Map<string,string>();// ???
//         List<Intel_Radio> radioList = new List<Intel_Radio>();
//         List<Intel_DropdownOption> subCategoryDropDownOptions= new List<Intel_DropdownOption>(); // Sub category values and will display as dropdown
//         //integer i = 0; // ???
//         string categorySelected; // declared to get selected sub category dropdownvalue
//         //Looping Through Category Values to set up Sub Category DropDown
//         for(PMP_CategoryController.Core_PMP_OfferingCategory iterWrapper : categoryWrapper){          
//             categoryPicklistMap.put(iterWrapper.PIMCategoryId,iterWrapper.categoryName); // ??? 
            
//             if(iterWrapper.ancestorCategoryId.countMatches('|')==1){ // should we depend this way ??               
//                //Adding Label and Value for Sub Categories
//                Intel_DropdownOption dropDown =   new Intel_DropdownOption(iterWrapper.categoryName ,iterWrapper.recordId/*PIMCategoryId*/);
//                dropDown.businessSegments = iterWrapper.businessSegments; 
//                subCategoryDropDownOptions.add(dropDown);
                
//                 //Added by Shahrukh : Prepopulation of selected sub category US364094
//                 if(!offCatIds.isEmpty() && offCatIds.contains(iterWrapper.PIMCategoryId)){
//                     //if(offCatIds.contains(iterWrapper.PIMCategoryId)){
//                        categorySelected = iterWrapper.recordId; // storing the value of dropdown in string to populate in dropdown radio combo
//                     //}    
//                 }
//                 //End of prepopulation
                       
               
//                 Intel_Radio radio = new Intel_Radio();
//                 //radio.label = 'Sub-Category Level 2';
//                 radio.label = System.label.PMP_Sub_Category_Level2;
//                  // TODO : Move to custom label
//                 if(iterWrapper.childOfferingCategory.size() > 0){ //If there are any children, Adding them to dropdown radio Combo
//                       //Looping Through First set of Children
                    
//                     for(PMP_CategoryController.Core_PMP_OfferingCategory iterSubWrapper : iterWrapper.childOfferingCategory){                 
//                           //Creating Radio Option  
//                         Intel_RadioOption radioOption =   new Intel_RadioOption(iterSubWrapper.categoryName,iterSubWrapper.recordId);
//                         //Added by Shahrukh : Prepopulation of selected sub category US368094
//                         if(!offCatIds.isEmpty() && offCatIds.contains(iterSubWrapper.PIMCategoryId)){
//                             //if(offCatIds.contains(iterSubWrapper.PIMCategoryId)){
//                               radioOption.isSelected = true; //setting the radio value to true under dropdown radio combo
//                             //}    
//                         } 
//                         //End of prepopulation
//                         radio.options.add(radioOption);
                        
//                         if(iterSubWrapper.childOfferingCategory.size() > 0){    
//                             //Looping through second set of children
//                             radioOption.valueType = 'complex';
//                             for(PMP_CategoryController.Core_PMP_OfferingCategory iterSubSubWrapper : iterSubWrapper.childOfferingCategory){   
//                                 //Creating Child Radio Option
//                                 Intel_RadioOption childradOption =   new Intel_RadioOption(iterSubSubWrapper.categoryName,iterSubSubWrapper.recordId);
                                
//                                 //Added by Shahrukh : Prepopulation of selected sub category US368094
//                                 if(!offCatIds.isEmpty()){
//                                     if(offCatIds.contains(iterSubSubWrapper.PIMCategoryId)){
//                                       childradOption.isSelected = true;
//                                     }    
//                                 }
//                                 //End of prepopulation
                                
//                                 childradOption.valueType = 'complex';
//                                 radioOption.children.add(childradOption);
                                
//                                 childradOption.isChildRequired=iterSubWrapper.childMandatoryFlag;
//                             }
                            
//                         }
//                     }
//                     radio.required=iterWrapper.childMandatoryFlag;//added by raj as part of US621683 for making Cloud level-3 as mandatory[03/24]
//                     //radio.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ System.label.PMP_Sub_Category_Level2;
//                     //Gireesh:US692547:Dynamic label
//                     params[0] = System.label.PMP_Sub_Category_Level2;
                    
//                     formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                     radio.errorMessage = formatted;
                    
//                 }
            
//                 radioList.add(radio); 
                
//                 }
//             }
            
//         //populating few properties for drop down
//         Intel_Dropdown dropDown = new Intel_Dropdown ();
//         dropDown.label = System.Label.PMP_Sub_Category; // TODO : move to custom label
//         dropDown.options = subCategoryDropDownOptions;
//         dropDown.layoutItemSize = 12;
//         dropDown.required = true;
        
//         //Adding final values for dropdown radio combo        
//         Intel_DropdownRadioCombo dropdownCombo = new Intel_DropdownRadioCombo();
//         dropdownCombo.dropdown = dropDown;
//         dropdownCombo.radios = radioList;
//         dropdownCombo.dropdownValue = categorySelected; // Setting the dropdown value if any sub category is selected
//         dropdownCombo.apiName = 'categoryAndSubCategory';
//         dropdownCombo.fieldName ='Tab1DropdownRadioCombo';
//         dropdownCombo.label = System.Label.PMP_Sub_Category;
        
//         return dropdownCombo; 
//     }
  
  
//   //Added By Shahrukh US356103 Loading of Industry and Application  
//   public static Intel_Checkbox createCategoryInfo(List<PMP_CategoryController.Core_PMP_OfferingCategory> categoryWrapper,string label,String fieldName,set<string> offCatIds){
//       //Gireesh:US692547:Dynamic label
//         List<Object> params = new List<Object>{''};
//         String formatted = '';  
//       // system.debug('inside method drcombo');
//         Map<string,string> categoryPicklistMap = New Map<string,string>();
//         Intel_Checkbox check = new Intel_Checkbox();
//           //  check.isOfferingField = false;
//             check.doNotSave = false;
//             check.interactionType = 'parent';
//             //check.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ label;
//             //Gireesh:US692547:Dynamic label
//             params[0] = label;
//             formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//             check.errorMessage = formatted;
//             //check.isAccordion = true;
//             check.label = label;
//             check.accordionType = 'search';
//             check.valueType = 'complex';
//             check.apiName = 'industryAndApplication';
//             check.fieldName = fieldName;
//             check.required = true;
//          //Looping through to get all the first level values
//           for(PMP_CategoryController.Core_PMP_OfferingCategory iterWrapper : categoryWrapper){
//               categoryPicklistMap.put(iterWrapper.PIMCategoryId,iterWrapper.categoryName);
//               Intel_CheckboxOption opt;
              
//               if(iterWrapper.ancestorCategoryId.countMatches('|')==0){
//                opt = new Intel_CheckboxOption(iterWrapper.categoryName , iterWrapper.recordId);//Setting Label and Value
                
//                //Added by Shahrukh : US368094    
//                if(!offCatIds.isEmpty() && offCatIds.contains(iterWrapper.PIMCategoryId)){   
//                    //if(offCatIds.contains(iterWrapper.PIMCategoryId)){  
//                         opt.checked = true; //Setting the checkbox as true if any Industry or Application is selected
//                    //}    
//                }   
//               //End of code for US368094
//               if(iterWrapper.childOfferingCategory.size() > 0){
//                   for(PMP_CategoryController.Core_PMP_OfferingCategory iterSubWrapper : iterWrapper.childOfferingCategory){ //Checking if there is a child and adding it to parent
//                       //system.debug('inside child for loop --> dropdowncombo' );
//                       //string name = iterSubWrapper.categoryName;
//                       //string id = iterSubWrapper.PIMCategoryId;                      
//                       Intel_CheckboxOption optChild = new Intel_CheckboxOption(iterSubWrapper.categoryName , iterSubWrapper.recordId);//Setting Label and Value
//                       //Added by Shahrukh : US368094
//                       if(!offCatIds.isEmpty() && offCatIds.contains(iterSubWrapper.PIMCategoryId)){   
//                           //if(offCatIds.contains(iterSubWrapper.PIMCategoryId)){
//                            optChild.checked = true; //Setting the checkbox as true if any Industry or Application is selected  
//                           //}    
//                       }
//                       //End of code for US368094
//                       opt.children.add(optChild);
//                       if(iterSubWrapper.childOfferingCategory.size() > 0){
//                           for(PMP_CategoryController.Core_PMP_OfferingCategory iterSubSubWrapper : iterSubWrapper.childOfferingCategory){ //Checking if child has any further children, if present then adding it to immediate parent
                             
//                               //string childname = iterSubSubWrapper.categoryName;
//                               //string childid = iterSubSubWrapper.PIMCategoryId;
//                               Intel_CheckboxOption childOptChild = new Intel_CheckboxOption(iterSubSubWrapper.categoryName , iterSubSubWrapper.recordId); //Setting Label and Value
//                               //Added by Shahrukh : US368094
//                               if(!offCatIds.isEmpty()){   
//                                   if(offCatIds.contains(iterSubSubWrapper.PIMCategoryId)){
//                                    childOptChild.checked = true;  //Setting the checkbox as true if any Industry or Application is selected 
//                                   }    
//                               } 
//                               //End of code for US368094
//                               optChild.children.add(childOptChild);
//                           }
//                     }
//                   }
                  
//                 }
              
//                check.options.add(opt);
//               }      
//           }
       
//         return check;
//     }  
     
//           public static Intel_Subsection getSpecificationSubsection(PMP_SpecificationController.Core_PMP_OfferingSpecs spec,PMP_Specifications_Tab_Mapping__mdt configMtd,
//                                                            PMP_Partner_Offering__c offering,set<string> offSpecSet,map<string,string> specValDataMap,
//                                                            map<string,List<string>> specValListMap){
//                 //Gireesh:US692547:Dynamic label
//                 List<Object> params = new List<Object>{''};
//                 String formatted = '';
                                                               
//             boolean mandatory= false;
            
//             List<PMP_SpecificationController.Core_PMP_OfferingSpecs> level1childSpecs = Spec.childOfferingSpecification;
                        
//             Intel_Subsection subSection = PMP_Offering_UI_Generator.createSubsection(spec.specName);
//             List<string> existingParentValuesList = new List<string>();
//             List<Intel_Text> textList = New List<Intel_Text>();
//             List<Intel_Radio> radioList = New List<Intel_Radio>();
            
            
//             Intel_Radio radioNew = new Intel_Radio();
//             radioNew.apiName = 'specification_cmplx'+configMtd.Tab__c;
//             radioNew.fieldName = spec.specId ;
//             radioNew.required =  spec.mandatoryCheck;
//             radioNew.label = spec.specName;
//             radioNew.valueType = 'complex';
//             //List<Intel_RadioOption> radOptionListNew = new List<Intel_RadioOption>();
            
            
//             Intel_Checkbox check = new Intel_Checkbox();
//             Intel_Checkbox prcssrSktdcheck = new Intel_Checkbox();
//             check.doNotSave = false;
//             check.interactionType = configMtd.Interaction_Type__c;
//             check.valueType = 'complex';
//             //spec.specNamesystem.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ spec.specName;                                                   
//             //Gireesh:US692547:Dynamic label
//             params[0] = spec.specName;
                                                          
//             formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//             check.errorMessage = formatted;
            
//             check.apiName = 'specification_cmplx'+configMtd.Tab__c;
//             check.fieldName = spec.specId ;
//             boolean createProcessorsSocketed =false; //to create a seperate field for processor socketed with Processors Subsection
//           check.required =  spec.mandatoryCheck;
          
//            check.accordionType = configMtd.Accordion_Type__c != null?  configMtd.Accordion_Type__c : null;
//           check.label = spec.specName;
//           //US-378930 :creating a dummy checkbox option SelectAll. This will be add to the checkbox based on metadata setting.
//           Intel_CheckboxOption SelectAllOption = new Intel_CheckboxOption(System.Label.PMP_Select_All , 'Do_Not_Save' );
//              if(configMtd.Accordion_Type__c == 'search')
//                  check.label = spec.specName;
//             //looping through first level children
//             for(PMP_SpecificationController.Core_PMP_OfferingSpecs level1Child : level1childSpecs ){
                
//                 if(level1Child.displayType == 'Checkbox'){
//                     check.layoutItemSize  = spec.specId == 'AvailabilityandPricingLevel1' ? 6 : 12; //psg
//                     Intel_CheckboxOption opt = new Intel_CheckboxOption(level1Child.specName , level1Child.specRecordId );
//                     opt.FieldName = level1Child.specId; //for PSG
//                     opt.inputSpecId = level1Child.ancestorSpecID;
//                     if(level1Child.specId == 'NPP_Processors_ProcessorSocketed'){ //to create a seperate field for processor socketed with Processors Subsection
//                         prcssrSktdcheck.doNotSave = false;
//                         prcssrSktdcheck.interactionType = configMtd.Interaction_Type__c;
//                         prcssrSktdcheck.valueType = 'default';
//                         prcssrSktdcheck.apiName = 'specification_smpl'+configMtd.Tab__c;
//                         prcssrSktdcheck.fieldName = spec.specName;
//                         prcssrSktdcheck.label = level1Child.specName;
                        
//                         prcssrSktdcheck.required = level1Child.mandatoryCheck;
//                         Intel_CheckboxOption prcssrSktdOpt = new Intel_CheckboxOption(level1Child.specName , level1Child.specRecordId );
//                         prcssrSktdOpt.checked = offSpecSet.contains(level1Child.specId)? true: false;
//                         prcssrSktdcheck.options.add(prcssrSktdOpt);
//                         createProcessorsSocketed = true;
//                     }
//                     //Added by Shahrukh : US368094 
//                     if(!offSpecSet.isEmpty() && offSpecSet.contains(level1Child.specId)){
//                         //if(offSpecSet.contains(level1Child.specId)){   
//                             opt.checked = true; //Setting the checkbox value to true if there are any selected specifications 
//                         //}    
//                     }
//                     //End of code for US368094
                    
//                     if(level1Child.childOfferingSpecification.size()> 0 ){
//                         if(level1Child.mandatoryCheck){
//                             mandatory=true;
//                         }
//                         //2nd level specifications
//                         for(PMP_SpecificationController.Core_PMP_OfferingSpecs level2child : level1Child.childOfferingSpecification){
//                             if(level2child.displayType == 'Checkbox'){
//                                 if(level2Child.specName=='AI Training'){
//                                     // system.debug('**** level2Child.specRecordId '+ level2Child.specRecordId);
//                                 }
//                                 Intel_CheckboxOption optChild = new Intel_CheckboxOption(level2Child.specName, level2Child.specRecordId );
//                                 //optChild.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level2Child.specName;
//                                 //Gireesh:US692547:Dynamic label   
                                                        
//                                 params[0] = level2Child.specName;
//                                 formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                                 optChild.errorMessage = formatted;
//                                 optChild.inputSpecId = level2child.ancestorSpecID;
//                                 //Added by Shahrukh : US368094 
//                                 if(!offSpecSet.isEmpty()){
//                                     if(offSpecSet.contains(level2child.specId) || offSpecSet.contains(level2child.specValueId)){
//                                         optChild.checked = true; //Setting the checkbox value to true if there are any selected specifications
//                                     } 
//                                 }    
//                                 //End of code for US368094
                                 
//                                 opt.children.add(optChild);
//                                 if(level2child.specValues.size()>0){
//                                     Intel_Radio radio = new Intel_Radio();
//                                     radio.label = level2child.specName;
//                                     radio.valueType = 'default';
//                                     //radio.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level2child.specName;
//                                     //Gireesh:US692547:Dynamic label
//                                     params[0] = level2child.specName;
//                                     formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                                     radio.errorMessage = formatted;
//                                     List<string> existingValuesList = New List<string>();
//                                     if(!specValListMap.isEmpty()){existingValuesList = specValListMap.get(level2child.specId);}
                                    
//                                     //specValue child records of level 2 specifications(will be 3rd level in the hierarchy).
//                                     for(PMP_SpecificationController.Core_PMP_OfferingSpecsValues level3childSpecValues : level2Child.specValues){
//                                         if(level3childSpecValues.displayType == 'Checkbox'){
//                                             if(level2Child.specName=='AI Training'){
//                                                 // system.debug('**** level2Child.specRecordId '+ level2Child.specRecordId);
//                                             }
//                                             Intel_CheckboxOption opt2Child = new Intel_CheckboxOption(level3childSpecValues.specValue , level3childSpecValues.specValueRecordId + '|' +level3childSpecValues.specRecordId);
//                                             //opt2Child.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level3childSpecValues.specValue;
//                                             //Gireesh:US692547:Dynamic label
//                                             params[0] = level3childSpecValues.specValue;
//                                             formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                                             opt2Child.errorMessage = formatted;
//                                             opt2Child.inputSpecId = level3childSpecValues.ancestorSpecID;
//                                             //Added by Shahrukh : US368094 
//                                             if(existingValuesList != null && existingValuesList.size()>0){
//                                                 if(existingValuesList.contains(level3childSpecValues.specValueId)){
//                                                    opt2Child.checked = true; //Setting the checkbox value to true if there are any selected specifications
//                                                 }   
//                                             }  
//                                             //End of code for US368094
                                            
//                                             //GIREESH:US357426: IF PRE-RELEASE ITEM AND VISIBILITY IS NOT PUBLIC CONTENT
//                                             if(level3childSpecValues.preReleased==true && offering.PMP_Partner_Offering_Visibility_Nm__c!='Public Content'){
//                                                 optChild.children.add(opt2Child); 
//                                                 opt2Child.prerelease=True;//US581383:Gireesh: Pre-release item tagging
//                                             }
//                                             else if(level3childSpecValues.preReleased==false){
//                                                 optChild.children.add(opt2Child);    
//                                             } 
//                                         }
//                                         else if(level3childSpecValues.displayType == 'Integer' || level3childSpecValues.displayType == 'Text' ||
//                                                 level3childSpecValues.displayType == 'date'){
//                                             Intel_CheckboxOption opt2Child = new Intel_CheckboxOption(level3childSpecValues.specValue , level3childSpecValues.specValueRecordId+ '|' +level3childSpecValues.specRecordId );
//                                             opt2Child.subtype = 'text';
//                                             opt2Child.textSubType = level3childSpecValues.displayType == 'Integer' ? 'number' : level3childSpecValues.displayType; //US586645:Gireesh
//                                             //opt2Child.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level3childSpecValues.specValue;
//                                             //Gireesh:US692547:Dynamic label
//                                             params[0] = level3childSpecValues.specValue;
//                                             formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                                             opt2Child.errorMessage = formatted;
//                                             opt2Child.inputSpecId = level3childSpecValues.ancestorSpecID;        
//                                             //GIREESH:US357426: IF PRE-RELEASE ITEM AND VISIBILITY IS NOT PUBLIC CONTENT
//                                             if(level3childSpecValues.preReleased==true && offering.PMP_Partner_Offering_Visibility_Nm__c!='Public Content'){
                                                
//                                                 optChild.children.add(opt2Child); 
//                                                 opt2Child.prerelease=True; //US581383:Gireesh: Pre-release item tagging
//                                             }
//                                             else if(level3childSpecValues.preReleased==false){
                                               
//                                                optChild.children.add(opt2Child); 
//                                             }
                                            
//                                         }                          
//                                     }
//                                 }
//                             }
//                             else if(level2child.displayType == 'Integer' || level2child.displayType == 'Text' || level2child.displayType == 'date' ){
//                                 Intel_CheckboxOption optChild = new Intel_CheckboxOption(level2Child.specName , level2Child.specRecordId );
//                                //system.debug('@insideLev1childtext-->' +level2Child.specName + level2child.displayType   );
//                                 optChild.subType = 'text';
//                                 optChild.textSubType=level2child.displayType == 'Integer' ? 'number' : level2child.displayType; //US586645:Gireesh
//                                 //optChild.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level2Child.specName;    
//                                 //Gireesh:US692547:Dynamic label
//                                 params[0] = level2Child.specName;
//                                 formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                                 optChild.errorMessage = formatted; 
//                                 optChild.inputSpecId = level2Child.ancestorSpecID;
//                                 if(offSpecSet.contains(level1Child.specId)){
                    
//                                     if(!specValDataMap.isEmpty()){
                                        
//                                        optChild.textValue= specValDataMap.get(level2Child.specId);
//                                     }
//                                 }   
         
//                                 opt.children.add(optChild); 
                                    
//                             }
                            
//                             else if(level2child.displayType == 'Label'){
                              
//                               Intel_CheckboxOption optChild = new Intel_CheckboxOption(level2Child.specName , level2Child.specRecordId );
//                               optChild.subType = 'radio';
//                               //optChild.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level2Child.specName;  
//                               //Gireesh:US692547:Dynamic label
//                               params[0] = level2Child.specName;
//                               formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                               optChild.errorMessage = formatted;
//                               optChild.inputSpecId = level2Child.ancestorSpecID;  
//                               List<Intel_RadioOption> radioOptList = New List<Intel_RadioOption>();  
//                               //string tempLabel;
                              
//                               if(level2child.specValues.size() > 0){
//                                 List<string> existingValuesList = New List<string>();
//                                 if(!specValListMap.isEmpty()){
//                                     existingValuesList = specValListMap.get(level2child.specId);
//                                 }
//                                 for(PMP_SpecificationController.Core_PMP_OfferingSpecsValues level3childSpecValues : level2Child.specValues){
//                                     Intel_RadioOption radOption =   New Intel_RadioOption(level3childSpecValues.specValue,level3childSpecValues.specValueRecordId +'|'+level3childSpecValues.specRecordId);
//                                     //radOption.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level3childSpecValues.specValue;
//                                     //Gireesh:US692547:Dynamic label
//                                     params[0] = level3childSpecValues.specValue;
//                                     formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                                     radOption.errorMessage = formatted;
//                                     if(existingValuesList != null && existingValuesList.size()>0&& existingValuesList.contains(level3childSpecValues.specValueId)){
//                                         radOption.isSelected = true;
//                                    }
                                     
//                                     //GIREESH:US357426: IF PRE-RELEASE ITEM AND VISIBILITY IS NOT PUBLIC CONTENT
                                    
//                                             if(level3childSpecValues.preReleased==true && offering.PMP_Partner_Offering_Visibility_Nm__c!='Public Content'){
//                                                 radioOptList.add(radOption);
//                                             }
//                                             else if(level3childSpecValues.preReleased==false){
//                                                radioOptList.add(radOption);
//                                             }
                                        
//                                 }
//                               }
//                               if(radioOptList.size()> 0){
//                                 optChild.radioOptions = radioOptList;
//                                 opt.children.add(optChild);
//                               }
//                             }                         
                            
//                         }
//                     }
//                     if(level1Child.specValues.size()>0){
//                         List<string> existingValuesList = New List<string>();
//                         if(!specValListMap.isEmpty()){
//                             existingValuesList = specValListMap.get(level1Child.specId);
//                         }
//                         for(PMP_SpecificationController.Core_PMP_OfferingSpecsValues level2childSpecValues : level1Child.specValues){
//                             Intel_CheckboxOption optChild = new Intel_CheckboxOption(level2childSpecValues.specValue , level2childSpecValues.specValueRecordId +'|'+ level2childSpecValues.specRecordId);
//                             //optChild.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level2childSpecValues.specValue;
//                             //Gireesh:US692547:Dynamic label
//                             params[0] = level2childSpecValues.specValue;
//                             formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                             optChild.errorMessage = formatted;
//                             optChild.inputSpecId = level2childSpecValues.ancestorSpecID;
//                             if(level2childSpecValues.displayType == 'Integer' || level2childSpecValues.displayType == 'Text' || level2childSpecValues.displayType == 'date'){
//                                 optChild.subType = 'text';
//                                 optChild.textSubType = level2childSpecValues.displayType == 'Integer' ? 'number' : level2childSpecValues.displayType; //US586645:Gireesh
//                             }
//                             else{
//                                 if(existingValuesList !=null && existingValuesList.contains(level2childSpecValues.specValueId)) optChild.checked = true;
//                              }
//                             //GIREESH:US357426: IF PRE-RELEASE ITEM AND VISIBILITY IS NOT PUBLIC CONTENT
//                             if(level2childSpecValues.preReleased==true && offering.PMP_Partner_Offering_Visibility_Nm__c!='Public Content'){
//                                 opt.children.add(optChild);  
//                                 optChild.prerelease=True; //US581383:Gireesh: Pre-release item tagging
//                             }
//                             else if(level2childSpecValues.preReleased==false){
//                                 opt.children.add(optChild);
//                             }
                                          
                            
//                         }
                        
//                     } 
//                    if(configMtd.Show_Select_All__c == true){ // US-378930 If Show_Select_All__c metadata field is set to true
//                         SelectAllOption.children.add(opt); //SelectAllOption will be added to the checkbox options at the end of the loop.
                       
//                     }
//                     else{ //If Show_Select_All__c metadata field is set to false
//                         if(!createProcessorsSocketed){check.options.add(opt);}
                        
//                     }   
//                 }
//                 else if(level1Child.displayType == 'Label' ){
//                     string tempLabel;
//                     if(offSpecSet.contains(level1Child.specId) && !specValDataMap.isEmpty()){
                    
//                         //if(!specValDataMap.isEmpty()){
                           
//                            tempLabel= specValDataMap.get(level1Child.specId);
                              
                           
//                         //}
//                     }
                        
//                     if(level1Child.specValues.size() >0){
//                         List<string> existingValuesList = New List<string>();
//                         if(!specValListMap.isEmpty()){
//                             existingValuesList = specValListMap.get(level1Child.specId);
//                         }
                        
//                         if(level1Child.specValues.size()>1 && level1Child.specValues[1].displayType == 'radioButton') {
                            
//                              Intel_Radio radio = new Intel_Radio();
//                              radio.label = level1Child.specName;
//                              radio.valueType = 'default';
//                             radio.required = level1Child.mandatoryCheck;
//                              radio.apiName = 'specification_txt'+configMtd.Tab__c;
//                              radio.fieldName = level1Child.specRecordId ; // for PSG make change here;
//                              radio.inputSpecId = level1Child.specId;
//                              radio.valuetype = 'picklist';
//                              radio.layoutItemSize = 6;
//                              radio.isInlineRadio = configMtd.is_Inline_Radio__c;//poc for IP Quality metrics
//                              //radio.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level1Child.specName;
//                              //Gireesh:US692547:Dynamic label
//                              params[0] = level1Child.specName;
//                             formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                             radio.errorMessage = formatted;
//                             List<Intel_RadioOption> radOptionList = new List<Intel_RadioOption>();
                            
//                             set<string> level1Questions = new set<string>();
                            
//                             for(PMP_SpecificationController.Core_PMP_OfferingSpecsValues level2SpecValues : level1Child.specValues){
//                                  Intel_RadioOption radOption =   New Intel_RadioOption(level2SpecValues.specValue ,level2SpecValues.specValueRecordId +'|'+level2SpecValues.specRecordId );
//                                  //radOption.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level2SpecValues.specValue;
//                                  //Gireesh:US692547:Dynamic label
//                                 params[0] = level2SpecValues.specValue;
//                                 formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                                 radOption.errorMessage = formatted;
                                
                                
                                
//                                 if(existingValuesList != null && existingValuesList.size()>0 && existingValuesList.contains(level2SpecValues.specValueId)){
                                 
//                                     radOption.isSelected = true;
//                                     if(level1Child.parentId == 'IPQualityMetricsLevel1' || level1Child.parentId == 'BoardQualityMetricsLevel1'){
//                                        level1Questions.add(level1Child.specName);
//                                     }
//                                 }
//                                 else if((level1Child.parentId == 'IPQualityMetricsLevel1' || level1Child.parentId == 'BoardQualityMetricsLevel1') && level2SpecValues.specValueId.contains('_no_boolean') && !level1Questions.contains(level1Child.specName)){//PSG POC Added by raj
//                                     radOption.isSelected = true;
//                                 }
                                
//                                  radOptionList.add(radOption);
//                             }
//                             radio.options= radOptionList;
//                             subSection.inputs.add(radio);
//                         }
//                         else if(level1Child.specValues.size() == 1 && level1Child.specValues[0].displayType == 'radioButton') {
//                              Intel_Radio radio = new Intel_Radio();
//                              radio.label = level1Child.specName;
                            
//                              radio.valueType = 'default';
//                             radio.required = level1Child.mandatoryCheck;
//                              radio.apiName = 'specification_txt'+configMtd.Tab__c;
//                              radio.fieldName = level1Child.specRecordId;
//                              radio.valuetype = 'picklist';
//                              //radio.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level1Child.specName;
//                              //Gireesh:US692547:Dynamic label
//                              params[0] = level1Child.specName;
//                             formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                             radio.errorMessage = formatted;
//                             List<Intel_RadioOption> radOptionList = new List<Intel_RadioOption>();
//                             for(PMP_SpecificationController.Core_PMP_OfferingSpecsValues level2SpecValues : level1Child.specValues){
//                                  Intel_RadioOption radOption =   New Intel_RadioOption(level2SpecValues.specValue ,level2SpecValues.specValueRecordId +'|'+level2SpecValues.specRecordId );
//                                  //radOption.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level2SpecValues.specValue;
//                                  //Gireesh:US692547:Dynamic label
//                                 params[0] = level2SpecValues.specValue;
//                                 formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                                 radOption.errorMessage = formatted;
//                                 if(existingValuesList != null && existingValuesList.size()>0 && existingValuesList.contains(level2SpecValues.specValueId)){
                                 
//                                     radOption.isSelected = true;
//                                 }
//                                 // system.debug('akjRadioval -->' +tempLabel +'-' + level2SpecValues.specValue);
                               
//                                  radOptionList.add(radOption);
//                             }
//                             radio.options= radOptionList;
//                             subSection.inputs.add(radio);
//                         }
//                         else if(level1Child.specValues[0].displayType == 'Checkbox'){
//                             Intel_Checkbox check1 = new Intel_Checkbox();
//                             check1.interactionType = 'parent';
//                             check1.valueType = 'default';
                           
//                             //check1.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level1Child.specname;
//                             //Gireesh:US692547:Dynamic label
//                             params[0] = level1Child.specname;
//                             formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                             check1.errorMessage = formatted;
//                             check1.apiName = 'specification_smpl'+configMtd.Tab__c;
//                             check1.fieldName = level1Child.specRecordId;
//                             check1.label = level1Child.specname ;
//                             check1.required = level1Child.mandatoryCheck;
//                             for(PMP_SpecificationController.Core_PMP_OfferingSpecsValues level2SpecValues : level1Child.specValues){
//                                 Intel_CheckboxOption opt = new Intel_CheckboxOption(level2SpecValues.specValue , level2SpecValues.specValueRecordId +'|'+level2SpecValues.specRecordId);
//                                 //opt.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level2SpecValues.specValue;
//                                 //Gireesh:US692547:Dynamic label
//                                 params[0] = level2SpecValues.specValue;
//                                 formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                                 opt.errorMessage = formatted;
//                                 opt.inputSpecId = level2SpecValues.ancestorSpecID;
//                                 if(existingValuesList != null && existingValuesList.size()>0 && existingValuesList.contains(level2SpecValues.specValueId)){
                                 
//                                     opt.checked =  true;
//                                 }
                                
//                                 check1.options.add(opt);
//                             }
//                             subSection.inputs.add(check1);
//                         }
//                     }
//                     if(level1Child.childOfferingSpecification.size()> 0 ){
                    
//                         if(level1Child.childOfferingSpecification[0].displayType == 'radioButton') {
//                              boolean required = false;
//                              Intel_Radio radio = new Intel_Radio();
//                              radio.label = level1Child.specName;
//                              //radio.valuetype = 'picklist';
                             
//                              radio.apiName = 'specification_cmplx'+configMtd.Tab__c;
//                              radio.fieldName = level1Child.specRecordId;
//                              radio.valueType = 'complex';
//                              //radio.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level1Child.specName;
//                              //Gireesh:US692547:Dynamic label
//                              params[0] = level1Child.specName;
//                             formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                             radio.errorMessage = formatted;
//                              required = level1Child.mandatoryCheck ? true : required;
//                              List<Intel_RadioOption> radOptionList = new List<Intel_RadioOption>();
//                              List<string> existingValuesList = New List<string>();
                            
//                              for(PMP_SpecificationController.Core_PMP_OfferingSpecs level2child : level1Child.childOfferingSpecification){
//                                  Intel_RadioOption radOption =   New Intel_RadioOption(level2child.specName ,level2child.specRecordId );
//                                  //radOption.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level2child.specName;
//                                  //Gireesh:US692547:Dynamic label
//                                 params[0] = level2child.specName;
//                                 formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                                 radOption.errorMessage = formatted;
//                                  radOption.isSelected = offSpecSet.contains(level2child.specId) ? true: false;
//                                  required = level2Child.mandatoryCheck ? true : required;
//                                  if(!specValListMap.isEmpty()){
//                                     existingValuesList = specValListMap.get(level2Child.specId);
//                                 }
//                                  if(level2child.specValues.size()>0){
//                                     for(PMP_SpecificationController.Core_PMP_OfferingSpecsValues level3SpecValues : level2Child.specValues){
//                                         Intel_RadioOption childRadOption =   New Intel_RadioOption(level3SpecValues.specValue , level3SpecValues.specValueRecordId +'|'+level3SpecValues.specRecordId );
//                                         //childRadOption.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level3SpecValues.specValue;
//                                         //Gireesh:US692547:Dynamic label
//                                         params[0] = level3SpecValues.specValue;
//                                         formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                                         childRadOption.errorMessage = formatted;
//                                         if(existingValuesList != null && existingValuesList.size()>0 && existingValuesList.contains(level3SpecValues.specValueId)){
                                 
//                                             childRadOption.isSelected =  true;
//                                         }   
//                                         radOption.children.add(childRadOption);
//                                     } 
//                                  }
//                                  radOptionList.add(radOption);
//                                 }
//                             radio.required = required;  
//                             radio.options= radOptionList;
//                             subSection.inputs.add(radio);
//                         }
//                         else if(level1Child.childOfferingSpecification[0].displayType == 'Checkbox'){
//                         Intel_Checkbox check1 = new Intel_Checkbox();
//                         boolean required = false;
//                         check1.interactionType = 'parent';
//                         check1.valueType = 'default';
//                         //check1.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level1Child.specname;
//                         //Gireesh:US692547:Dynamic label
//                         params[0] = level1Child.specname;
//                         formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                         check1.errorMessage = formatted;
//                         check1.apiName = 'specification_smpl'+configMtd.Tab__c;
//                         check1.fieldName = level1Child.specRecordId;
//                         check1.label = level1Child.specname;
                        
                        
//                         required = level1Child.mandatoryCheck ? true : required;
//                         List<string> existingValuesList = New List<string>();
                        
//                             for(PMP_SpecificationController.Core_PMP_OfferingSpecs level2child : level1Child.childOfferingSpecification){
//                                 if(!specValListMap.isEmpty()){
//                                     existingValuesList = specValListMap.get(level2Child.specId);
//                                 }
//                                 Intel_CheckboxOption opt = new Intel_CheckboxOption(level2child.specName, level2child.specRecordId );
//                                 //opt.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level2child.specName;
//                                 //Gireesh:US692547:Dynamic label
//                                 params[0] = level2child.specName;
//                                 formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                                 opt.errorMessage = formatted;
//                                 opt.checked = offSpecSet.contains(level2child.specId) ? true: false;
//                                 opt.inputSpecId = level2child.ancestorSpecID;
                                
//                                 required = level2Child.mandatoryCheck ? true : required;
//                                 check1.options.add(opt);
                                
//                                 //PSG Abhishek ------
//                                  if(level2Child.specValues.size()!= 0){
//                                     for(PMP_SpecificationController.Core_PMP_OfferingSpecsValues  level3childSpecVal : level2Child.specValues){
//                                         Intel_CheckboxOption lev3Opt = new Intel_CheckboxOption(level3childSpecVal.specValue , level3childSpecVal.specValueRecordId +'|'+level2Child.specRecordId);
//                                         lev3Opt.inputSpecId = level3childSpecVal.ancestorSpecID;
//                                         if(existingValuesList != null && existingValuesList.size()>0&& existingValuesList.contains(level3childSpecVal.specValueId)){
//                                             lev3Opt.checked = true;
//                                        }
//                                         opt.children.add(lev3Opt);
//                                     }   
//                                 }
                                
//                                 // PSG End
//                             }
//                             check1.required = required;
                            
//                             subSection.inputs.add(check1);
//                         }
//                     }
                    
                    
                    
                    
//                 }
//                 else if(level1Child.displayType == 'Text' || level1Child.displayType == 'date' ||
//                         level1Child.displayType == 'Integer'){
//                     Intel_Text textField = PMP_Offering_UI_Generator.createText(level1Child.specRecordId,level1Child.specName,level1Child.mandatoryCheck,'Specification__c');
//                     textField.apiName = 'specification_txt'+configMtd.Tab__c;
//                     textField.required = level1Child.mandatoryCheck;
//                     //psg------
//                     if(level1Child.specId == 'NPP_AvailabilityAndPricing_Price' && offSpecSet.contains(System.label.PMP_ContactForPrice) ){
//                         textField.disabled = true;
//                          //textField.required = false;
//                     }
//                     //psg end-----
//                     /*PSG Board Metrics[Raj]*/
//                     if(level1Child.specId == 'NPP_Board_Quality_Metrics_Test_Plan_Summary'){
//                        textField.layoutItemMediumDeviceSize = 12;         
//                     }
//                     /*End*/
//                     if(offSpecSet.contains(level1Child.specId) && !specValDataMap.isEmpty()){
                    
//                         //if(!specValDataMap.isEmpty()){
                           
//                            textField.textValue= specValDataMap.get(level1Child.specId);
                            
                           
//                         //}
//                     }   
//                     textField.fieldName = level1Child.specRecordId; 
//                     textField.inputSpecId = level1Child.specId ;// changed by Abhishek level1Child.specRecordId;
                    
//                     textField.subType =    level1Child.displayType== 'Integer' ? 'number' : level1Child.displayType;
                    
//                     textList.add(textField);
                    
//                 }
             
//             }
//             if(!specValListMap.isEmpty()){
//                 existingParentValuesList = specValListMap.get(spec.specId);
//             }
            
            
            
//             for(PMP_SpecificationController.Core_PMP_OfferingSpecsValues level1ChildSpecValues : spec.specValues ){
            
                
            
//                 if(level1ChildSpecValues.displayType=='Radiobutton'){
                    
                    
//                    Intel_RadioOption radOption =   New Intel_RadioOption(level1ChildSpecValues.specValue,level1ChildSpecValues.specValueRecordId + '|'+level1ChildSpecValues.specRecordId );
//                    params[0] = level1ChildSpecValues.specValue;
//                     formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                     radOption.errorMessage = formatted;
//                     radOption.fieldName = level1ChildSpecValues.specValue;
//                     radioNew.options.add(radOption);
//                     if(existingParentValuesList != null && existingParentValuesList.size()>0 && existingParentValuesList.contains(level1ChildSpecValues.specValueId)){
//                        radOption.isSelected = true; 
//                     } 
                    
                
                
//                 }else{
                    
//                     Intel_CheckboxOption opt = new Intel_CheckboxOption(level1ChildSpecValues.specValue, level1ChildSpecValues.specValueRecordId + '|'+level1ChildSpecValues.specRecordId   );
//                     //opt.errorMessage = system.Label.PMP_RequiredCheckbox_ErrorMessage +' '+ level1ChildSpecValues.specValue;   
//                     //Gireesh:US692547:Dynamic label
//                     params[0] = level1ChildSpecValues.specValue;
//                     formatted = String.format(system.Label.PMP_RequiredCheckbox_ErrorMessage, params);
//                     opt.errorMessage = formatted;
                    
//                        if(existingParentValuesList != null && existingParentValuesList.size()>0 && existingParentValuesList.contains(level1ChildSpecValues.specValueId)) opt.checked = true;
//                     //GIREESH:US357426: IF PRE-RELEASE ITEM AND VISIBILITY IS NOT PUBLIC CONTENT
//                     if(level1ChildSpecValues.preReleased==true && offering.PMP_Partner_Offering_Visibility_Nm__c!='Public Content'){
//                         check.options.add(opt);
//                     }
//                     else if(level1ChildSpecValues.preReleased==false){
//                         check.options.add(opt);
//                     }
               
//                 } 
                
//             }
            
//             if(radioNew.options.size() > 0){
               
               
//                subSection.inputs.add(radioNew);
               
//             }
            
            
//             if(configMtd.Show_Select_All__c == true){ //If Show_Select_All__c metadata field is set to true 
                
//                 check.options.add(SelectAllOption);
//             }
            
//             if(check.options.size() > 0){
                
                
//                 //setting all other specification on tab 1 mandatory other than end customer type(irrespective of category)
//                 check.required = (subSection.inputs.size() == 0 && check.required)|| (configMtd.Tab__c == 'Tab1' && spec.specId != Label.PMP_NPP_EndCustomerType)? true : false;
//                 //US523547 End Customer type default not mandatory (create Scenario)
//                 if(spec.specId == Label.PMP_NPP_EndCustomerType && offering.PMP_Business_Segment_Nm__c ==null){
//                     check.required = false;
//                 }
//                 //US523547 End Customer type should not be mandatory for embedded IoT.(Edit Scenario)
//                 else if(spec.specId == Label.PMP_NPP_EndCustomerType && offering.PMP_Business_Segment_Nm__c !=null ){
//                       check.required = offering.PMP_Business_Segment_Nm__c.contains('IoT')? false : true;
                      
//                   }
//                 //check.label = subSection.inputs.size() <= 1 && check.required ? check.label : null;
//                 subSection.inputs.add(check);
//                 if(createProcessorsSocketed){subSection.inputs.add(prcssrSktdcheck);}
//             }
//             for(Intel_radio radio : radioList){
//                // subSection.inputs.add(radio); 
//             }
//             for(Intel_Text textField : textList){
//                 subSection.inputs.add(textField); 
//             }
            
                                                               
                                                           
//             return subSection;
        
//     } 
}