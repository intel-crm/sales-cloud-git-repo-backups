/****************************************************************************************************************************************
* Class Name  : PMP_CreateOfferingTab3Service 
* Version     : 1.0 
* Created Date: 04-25-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Abhishek                 05-10-2019                    Created for displaying tab3 - offering details elements in 'Create Offering' components
****************************************************************************************************************************************************************/
public with sharing class PMP_CreateOfferingTab3Service {
    
    
      
    public static Intel_Step getOfferingDetailsInputs(string stepName,List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specList,
                                                         Map<String, PMP_Specifications_Tab_Mapping__mdt> stepConfigurationsMap,
                                                          PMP_Partner_Offering__c offering,set<string> offSpecSet,map<string,string> specValDataMap,
                                                          map<string,List<string>> specValListMap ){
         Intel_Step step3 = PMP_Offering_UI_Generator.createStep(stepName);
         
        
        //Section 1 for offering details
        Intel_Section section1 = PMP_Offering_UI_Generator.createSection(' ');
        
        step3.sections.add(section1);
        
        for(PMP_SpecificationController.Core_PMP_OfferingSpecs iterSpec : specList){
               
                 PMP_Specifications_Tab_Mapping__mdt configMtd = stepConfigurationsMap.get(iterSpec.specId);
                Intel_Subsection subSection = PMP_Offering_UI_Generator.getSpecificationSubsection(iterSpec,configMtd , offering,offSpecSet,specValDataMap,specValListMap );
                section1.subsections.add(subSection);
        
        }
        return step3;
     } 
}