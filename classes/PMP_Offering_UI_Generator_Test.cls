@isTest
public class PMP_Offering_UI_Generator_Test{
     
//     @testSetup
//     public static void generateData(){
//         List<PMP_Partner_Offering__c> offList = New List<PMP_Partner_Offering__c>();
//         for(integer i=0;i<5; i++){
//             PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoff'+ i, null,null,null,false,null,null );
//             offList.add(offering);
//         }
//         insert offList;
        
//         PMP_Partner_Offering_Category__c offCat1 = PMP_TestDataUtility.getPMPOfferingCategory(offList[0].id);
//          PMP_Partner_Offering_Category__c offCat2 = PMP_TestDataUtility.getPMPOfferingCategory(offList[0].id);
    
//     }
//     public static testMethod void createStepTest(){
//         test.startTest();
//         Intel_Step response = PMP_Offering_UI_Generator.createStep('Test Step');
//         System.assertNotEquals(response, Null);
//         test.stopTest();
//     }
    
//     public static testMethod void createSectionTest(){
//         test.startTest();
//         Intel_Section response = PMP_Offering_UI_Generator.createSection('Test Section');
//        System.assertNotEquals(response, Null);
//         test.stopTest();
//     }
    
//     public static testMethod void createSubsectionTest(){
//     test.startTest();
//         Intel_Subsection response = PMP_Offering_UI_Generator.createSubSection('Test Section');
//         System.assertNotEquals(response, Null);
//         test.stopTest();
//     }
    
//     public static testMethod void createDropdown1Test(){
//         test.startTest();
//         Intel_Dropdown response = PMP_Offering_UI_Generator.createDropDown('PMP_Offering_Language_Nm__c', 'Test Label', 'PMP_Partner_Offering__c', true,'test Api');
//         System.assertNotEquals(response, Null);
//         test.stopTest();
//     }
    
//     public static testMethod void createDropDown2Test(){
//         test.startTest();
        
        
//         List<PMP_Partner_Offering__c> offeringList = New List<PMP_Partner_Offering__c>();
//         Map<id,string> offMap = New Map<id, string>();
        
//         offeringList = [select id, Name, PMP_Partner_Offering_Nm__c from PMP_Partner_Offering__c limit 4];
//         System.assertEquals(false,offeringList.isEmpty());
//         for (PMP_Partner_Offering__c offering : offeringList){
//             offMap.put(offering.id, offering.PMP_Partner_Offering_Nm__c);
//         }
//         Intel_Dropdown response = PMP_Offering_UI_Generator.createDropDown(offMap,'test ApiName' , 'Test Label',false, 'Test Obj Api');       
//         System.assertNotEquals(response, Null);
//         test.stopTest();
//     }
    
    
//     public static testMethod void createDropDown3Test(){
//         test.startTest();
//         Map<string, string> testMap = New Map<string,string>{'key1' => 'value1', 'key2' => 'value2'};
//         Intel_Dropdown response = PMP_Offering_UI_Generator.createDropDown(testMap, 'testfieldApi Name', 'testLable', false);
//         System.assertNotEquals(response, Null);
//         test.stopTest();
//     }
    
//     public static testMethod void createTextTest(){
//         test.startTest();
//         Intel_Text response = PMP_Offering_UI_Generator.createText('TestApiName', 'TestLable', false);
//         Intel_Text response1 = PMP_Offering_UI_Generator.createText('TestApiName', 'TestLable', false, 'testObjApi');
//         Intel_Text response2 = PMP_Offering_UI_Generator.createTextTemp('TestApiName', 'TestLable', false, 'testObjApi','TestVal');
//         Intel_RichText response3 =  PMP_Offering_UI_Generator.createRichText('TestApiName', 'TestLable','TestError', false, 'testObjApi');
//         Intel_Text response4 = PMP_Offering_UI_Generator.createDate('date','TestApiName', 'TestLable', false, 'testObjApi');
//         System.assertNotEquals(response, Null);
//         System.assertNotEquals(response1, Null);
//         System.assertNotEquals(response2, Null);
//         System.assertNotEquals(response3, Null);
//         System.assertNotEquals(response4, Null);
//         test.stopTest();
//     }
    
//     public static testMethod void createCheckboxTest(){
//         test.startTest();
//         //PMP_Offering_UI_Generator.createCheckbox('TestApiName', 'TestLable');
//         Intel_Checkbox response = PMP_Offering_UI_Generator.checkboxSearch();
//         System.assertNotEquals(response, Null);
//         test.stopTest();
//     }
        
//     public static testMethod void createUploaderTest(){
//         PMP_Partner_Offering__c offering = [select id, Name, PMP_Partner_Offering_Nm__c from PMP_Partner_Offering__c limit 1];
//         Intel_Uploader response = PMP_Offering_UI_Generator.createUploader(offering, true);
//         System.assertNotEquals(response, Null);
//     }
//      public static testMethod void createResourcesTest(){
//         Intel_Resources response = PMP_Offering_UI_Generator.createResources();
//         System.assertNotEquals(response, Null);
//     }
//      public static testMethod void createDropdownComboTest(){
//         List<PMP_CategoryController.Core_PMP_OfferingCategory> categoryWrapperList = New List<PMP_CategoryController.Core_PMP_OfferingCategory>();
//         List<PMP_CategoryController.Core_PMP_OfferingCategory> categoryWrapList = New List<PMP_CategoryController.Core_PMP_OfferingCategory>();
//         for(integer i=0; i<10; i++){
//             PMP_CategoryController.Core_PMP_OfferingCategory  categoryWrapper = New PMP_CategoryController.Core_PMP_OfferingCategory('Test1Cat'+i, 'NPP_03'+i, 'NPP_02_Test', 'Test', 'TestAncestor', 'test','test',false,false,
//                                                                                 'testId', 'Test', false);
//             categoryWrapperList.add(categoryWrapper);
//             }

//         PMP_CategoryController.Core_PMP_OfferingCategory  categoryWrap1 = categoryWrapperList[0];
//         PMP_CategoryController.Core_PMP_OfferingCategory  categoryWrap2 = categoryWrapperList[1];
//         categoryWrap2.childOfferingCategory.add(categoryWrapperList[2]); 
//         categoryWrap2.childOfferingCategory.add(categoryWrapperList[3]); 
//         categoryWrap2.ancestorCategoryId = 'Test|Test1';
//         categoryWrap1.childOfferingCategory.add(categoryWrap2); 
//         categoryWrapList.add(categoryWrap1);
//         categoryWrapperList[4].ancestorCategoryId = 'Test1|Test2';
//         categoryWrapperList[5].childOfferingCategory.add(categoryWrapperList[6]);
//         categoryWrapperList[4].childOfferingCategory.add(categoryWrapperList[5]);
//         categoryWrapList.add(categoryWrapperList[4]);
        
//        // categoryWrapList.add(categoryWrapperList[5]);
//       //  categoryWrapList.add(categoryWrapperList[6]);
// test.startTest();
//         //PMP_Offering_UI_Generator.createDropdownCombo(categoryWrapList);
//         set <string> offCatId = New set <string>();
//         List <PMP_Partner_Offering_Category__c> offCatList = [select id from  PMP_Partner_Offering_Category__c LIMIT 10];
//         for(PMP_Partner_Offering_Category__c offcat : offCatList ){
//             offCatId.add(offcat.id);
//         }
//         Intel_DropdownRadioCombo response = PMP_Offering_UI_Generator.createCategoriesDropDownRadioCombo(categoryWrapList, offCatId );
//         PMP_Offering_UI_Generator.createCategoryInfo(categoryWrapList,'testLabel','testName', offCatId);
//         System.assertNotEquals(response, Null);
//          test.stopTest();
         
//     }
//     static testMethod void getOfferingDetailsInputsTest(){
//         test.startTest();
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specList = New List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
//         map<string, PMP_Specifications_Tab_Mapping__mdt> configSpecMap = New Map<string,PMP_Specifications_Tab_Mapping__mdt>();
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecsValues> specValList1 = PMP_TestDataUtility.getSpecValueWrapper(10,'checkbox');
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecsValues> specValList2 = PMP_TestDataUtility.getSpecValueWrapper(10,'checkbox');
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specWrapperList = PMP_TestDataUtility.getspecWrapperList(20,'checkbox');
//         PMP_Specifications_Tab_Mapping__mdt configMeta = [Select label,Accordion_Type__c,PMP_Field_Label__c, isAccordion__c,
//                                                                  isSearchable__c,tab__c ,
//                                                                  Interaction_Type__c,PMP_Is_Create_Offering_Ind__c, Show_Select_All__c, is_Inline_Radio__c 
//                                                                  from PMP_Specifications_Tab_Mapping__mdt where PMP_Is_Create_Offering_Ind__c=true Limit 1];
//         set<string> offSpecSet = new set<string>(); // To handle pre-population scenario.
//         map<string,string> specValDataMap = new map<string,string>();
//         map<string,List<string>> specValListMap = New Map<string,List<string>>();
        
        
//         //-----------1st set of data(Display Type = Checkbox)---------------
//         PMP_SpecificationController.Core_PMP_OfferingSpecs spec1 = specWrapperList[0];
//         offSpecSet.add(spec1.specId);
//         //1st Set 1st Level Specifications
//         specWrapperList[1].specId = 'NPP_Processors_ProcessorSocketed';
//         spec1.childOfferingSpecification.add(specWrapperList[1]);
        
//         specWrapperList[2].displayType = 'radioButton';
//         specWrapperList[2].childOfferingSpecification.add(specWrapperList[3]);
//         specWrapperList[2].childOfferingSpecification[0].childOfferingSpecification.add(specWrapperList[4]);
        
//         //End of 1st Set 1st Level Specifications
//         spec1.childOfferingSpecification.add(specWrapperList[2]);
        
        
//         configSpecMap.put(spec1.specid,configMeta );
        
//         //---------End of 1st Set --------------------
        
        

//         PMP_SpecificationController.Core_PMP_OfferingSpecs spec2 = specWrapperList[2];
        
//         //-------------- 2nd set of data(Display Type = Label) -------------------
//         spec2.childOfferingSpecification.add(specWrapperList[3]);
//         spec2.childOfferingSpecification.add(specWrapperList[4]);
//         spec2.childOfferingSpecification.add(specWrapperList[5]);
//         spec2.specValues = specValList1;
//         spec2.specValues = specValList2;
//         spec2.displaytype = 'label';
//         spec2.childOfferingSpecification.add(specWrapperList[8]);
//         spec2.childOfferingSpecification.add(specWrapperList[9]);
//         configSpecMap.put(spec2.specid,configMeta ); // adding spec id to config map
//         spec1.childOfferingSpecification.add(spec2); //adding spec 2 as a child of spec1
//         // -------------------- End of 2nd Set --------------------
            
//         //------------3rd set ------------
//             PMP_SpecificationController.Core_PMP_OfferingSpecs spec3 = specWrapperList[6];
//             spec3.displaytype = 'label';
//             configSpecMap.put(spec3.specid,configMeta );
//         //--------------End of 3rd Set------------------
        
//         //--------4th Set
//         PMP_SpecificationController.Core_PMP_OfferingSpecs spec4 = specWrapperList[7];
        
//         specWrapperList[13].displaytype = 'label';
//         specWrapperList[14].displaytype = 'integer';
//         spec4.childOfferingSpecification.add(specWrapperList[13]);
//         spec4.childOfferingSpecification.add(specWrapperList[14]);
//         specValList2[2].displaytype = 'integer';
//         specValList2[3].displaytype = 'integer';
//         specValList2[0].displaytype = 'checkbox';
//         specWrapperList[12].specValues = specValList2;
//         spec4.childOfferingSpecification.add(specWrapperList[12]);
//         configSpecMap.put(spec4.specid,configMeta );
//         //---------End of 4th Set ------------------------
        
        
        
//         PMP_SpecificationController.Core_PMP_OfferingSpecs spec5 = specWrapperList[10];
//         spec5.displaytype ='text';
//         PMP_SpecificationController.Core_PMP_OfferingSpecs spec6 = specWrapperList[11];
//         spec6.displaytype ='label';
//         PMP_SpecificationController.Core_PMP_OfferingSpecs spec7 = specWrapperList[15];
//         spec7.displayType = 'label';
//         PMP_SpecificationController.Core_PMP_OfferingSpecs spec7Child1 = specWrapperList[17];
//         spec7Child1.displayType = 'label';
//         specWrapperList[16].displayType = 'radioButton';
//         specWrapperList[16].specValues = PMP_TestDataUtility.getSpecValueWrapper(1,'radioButton');
//         spec7Child1.childOfferingSpecification.add(specWrapperList[16]);
//         spec7Child1.specValues = PMP_TestDataUtility.getSpecValueWrapper(0,'radioButton');
//         spec7.childOfferingSpecification.add(spec7Child1);
       
        
//         configSpecMap.put(spec7.specid,configMeta );
//         for(PMP_SpecificationController.Core_PMP_OfferingSpecsValues specVal : PMP_TestDataUtility.getSpecValueWrapper(5,'checkbox')){
//             specVal.displaytype = 'radioButton';
//             spec6.specValues.add(specVal);
//             specWrapperList[13].specValues.add(specVal);
//             spec4.specValues.add(specVal);
//         }
//         spec3.childOfferingSpecification.add(spec4);
//         spec3.childOfferingSpecification.add(specWrapperList[8]);
//         spec3.childOfferingSpecification.add(specWrapperList[9]);
//         specWrapperList[9].displaytype='radioButton';
//         specWrapperList[8].specValues = specValList2;
//         specWrapperList[9].specValues = specValList2;
//         specWrapperList[9].childOfferingSpecification.add(specWrapperList[8]);
//         spec1.childOfferingSpecification.add(specWrapperList[9]);
        
        
        
//         PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoff', null,null,null,true,null,null );
        
        
//         Intel_Subsection response = PMP_Offering_UI_Generator.getSpecificationSubsection(spec1,configMeta,offering,offSpecSet,specValDataMap,specValListMap );
//         Intel_Subsection response1 = PMP_Offering_UI_Generator.getSpecificationSubsection(spec3,configMeta,offering,offSpecSet,specValDataMap,specValListMap );
//         Intel_Subsection response2 = PMP_Offering_UI_Generator.getSpecificationSubsection(spec2,configMeta,offering,offSpecSet,specValDataMap,specValListMap );
//         Intel_Subsection response3 = PMP_Offering_UI_Generator.getSpecificationSubsection(spec4,configMeta,offering,offSpecSet,specValDataMap,specValListMap );
//         Intel_Subsection response4 = PMP_Offering_UI_Generator.getSpecificationSubsection(spec7,configMeta,offering,offSpecSet,specValDataMap,specValListMap );
//         System.assertNotEquals(response, Null);
//         System.assertNotEquals(response1, Null);
//         System.assertNotEquals(response2, Null);
//         System.assertNotEquals(response3, Null);
//         System.assertNotEquals(response4, Null);
//         test.stopTest();
//     } 
//     static testMethod void inputsTest(){
//         Intel_CheckboxOption checkOption = New Intel_CheckboxOption('lab','val');
//         Intel_CheckboxOption checkOption1 = New Intel_CheckboxOption('lab','val','integer');
//         checkOption1.labelOnly = true;
//         checkOption1.subType = 'text';
//         checkOption1.textSubType = 'number';
//         checkOption1.textValue = 'test';
//         checkOption1.additionalValues = New Map<string,string>{'testKey' => 'testVal'};
//         Intel_TextArea textArea = New Intel_TextArea();
//         textArea.Label = 'Test';
        
//         System.assertEquals(checkOption1.textSubType, 'number');
        
//     }
    

}