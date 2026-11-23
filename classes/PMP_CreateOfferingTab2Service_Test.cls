@isTest
public class PMP_CreateOfferingTab2Service_Test {

    static testMethod void getOfferingDetailsInputsTest(){
        List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specList = New List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
        map<string, PMP_Specifications_Tab_Mapping__mdt> configSpecMap = New Map<string,PMP_Specifications_Tab_Mapping__mdt>();
        List<PMP_SpecificationController.Core_PMP_OfferingSpecsValues> specValList1 = PMP_TestDataUtility.getSpecValueWrapper(5,'CheckBox');
        List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specWrapperList = PMP_TestDataUtility.getspecWrapperList(10,'CheckBox');
        set<string> offSpecSet = New set<string>();
        map<string,string> specValDataMap = New Map<string,string>();
        map<string,List<string>> specValListMap = New Map<string,List<string>>();
        PMP_Specifications_Tab_Mapping__mdt configMeta = [Select label,Accordion_Type__c,PMP_Field_Label__c, isAccordion__c,
                                                                 isSearchable__c,tab__c,
                                                                 Interaction_Type__c, Show_Select_All__c
                                                                  from PMP_Specifications_Tab_Mapping__mdt Limit 1];
        
        PMP_SpecificationController.Core_PMP_OfferingSpecs spec1 = specWrapperList[0];
        spec1.childOfferingSpecification.add(specWrapperList[1]);
        
        PMP_SpecificationController.Core_PMP_OfferingSpecs spec2 = specWrapperList[2];
        spec2.childOfferingSpecification.add(specWrapperList[3]);
        spec2.childOfferingSpecification.add(specWrapperList[4]);
        spec2.childOfferingSpecification.add(specWrapperList[5]);
        spec2.specValues = specValList1;
        spec1.childOfferingSpecification.add(spec2);
        
        PMP_SpecificationController.Core_PMP_OfferingSpecs spec3 = specWrapperList[6];
        spec3.childOfferingSpecification.add(specWrapperList[7]);
        spec3.childOfferingSpecification.add(specWrapperList[8]);
        spec3.childOfferingSpecification.add(specWrapperList[9]);
        
        configSpecMap.put(spec1.specid,configMeta );
        configSpecMap.put(spec2.specid,configMeta );
        configSpecMap.put(spec3.specid,configMeta );
        specList.add(spec1);
        specList.add(spec2);
        specList.add(spec3);
        
        PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoff', null,null,null,true,null,null );
        
        Intel_Step step = PMP_CreateOfferingTab2Service.getOfferingDetailsInputs('Tab1',specList,configSpecMap,offering,offSpecSet,specValDataMap,specValListMap );
    } 



}