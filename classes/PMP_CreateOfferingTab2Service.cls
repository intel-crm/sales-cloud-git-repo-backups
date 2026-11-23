/****************************************************************************************************************************************
* Class Name  : PMP_CreateOfferingTab2Service 
* Version     : 1.0 
* Created Date: 04-25-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Abhishek                 05-05-2019                    Created for displaying tab1 - offering details elements in 'Create Offering' components
****************************************************************************************************************************************************************/
public with sharing class PMP_CreateOfferingTab2Service {
    
    
      
    public static Intel_Step getOfferingDetailsInputs(string stepName,List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specList,
                                                        Map<string, PMP_Specifications_Tab_Mapping__mdt> stepConfiguration,
                                                         PMP_Partner_Offering__c offering,set<string> offSpecSet,map<string,string> specValDataMap,
                                                         map<string,List<string>> specValListMap ){
         Intel_Step step2 = PMP_Offering_UI_Generator.createStep(stepName);
         
        System.debug('specList in tab2 service-->'+specList);
        //Section 1 for offering details
        Intel_Section section1 = PMP_Offering_UI_Generator.createSection(' ');
        step2.sections.add(section1);
        
        
        
        for(PMP_SpecificationController.Core_PMP_OfferingSpecs iterSpec : specList){
            
           //     if(iterSpec.specId !='NPP_Processors'){
                    System.debug('Specs-----> '+iterSpec.specName);
                    //system.debug('Specs-----> '+iterSpec.childOfferingSpecification[0]);
                    System.debug('Specs-----> '+iterSpec.childOfferingSpecification.size());
                    System.debug('---------------------------------------------------------------------------------------------------------------');
                    System.debug('Specs-----> '+specValDataMap);
                    System.debug('Specs-----> '+specValListMap);
                    PMP_Specifications_Tab_Mapping__mdt configMtd = stepConfiguration.get(iterSpec.specId);
                    Intel_Subsection subSection = PMP_Offering_UI_Generator.getSpecificationSubsection(iterSpec,configMtd , offering,offSpecSet,specValDataMap,specValListMap);
                    section1.subsections.add(subSection);
             //   }
           /*     else{
                    PMP_Specifications_Tab_Mapping__mdt configMtd = stepConfiguration.get(iterSpec.specId);
                    Intel_Subsection subSection = getSpecificationSubsection(iterSpec,configMtd , offering,offSpecSet,specValDataMap,specValListMap);
                    section1.subsections.add(subSection);
                } */
                
                
        
        }
        
        // This code is added as part of pre release requirment for IP iteration                                                    
        Intel_Subsection presub = new Intel_Subsection(System.Label.PMP_PreRelease_SubSection_Name); // Adding subsection
        presub.notActive = true;                                                                     //To Determine if section is active or not
        presub.showHeadline = true; 
        presub.additionalText = System.Label.PMP_PreRelease_SubSection_AdditionalHeading;   
        section1.subsections.add(presub);
        Intel_Radio presettings = new Intel_Radio();      // Adding Radio input and its options for pre release to be displayed
        presettings.valueType = 'picklist';
        presettings.fieldName = 'PMP_Pre_Release_Check_Nm__c';
        presettings.apiName = 'offering';
        presettings.required = false;
        presettings.errorMessage = System.Label.PMP_PreRelease_SubSection_ErrorMessage;
        presettings.additionalText = System.Label.PMP_PreRelease_Terms_And_Conditions;  
        presettings.label = System.Label.PMP_PreRelease_SubSection_Name;
        List<Intel_RadioOption> radopts = new List<Intel_RadioOption>();
        Intel_RadioOption roOne = new Intel_RadioOption(System.Label.PMP_PreRelease_SubSection_RadioOption1, 'Yes');
        Intel_RadioOption roTwo = new Intel_RadioOption(System.Label.PMP_PreRelease_SubSection_RadioOption2, 'No');
        if(offering.PMP_Pre_Release_Check_Nm__c=='Yes'){
            roOne.isSelected = true;
        }else if(offering.PMP_Pre_Release_Check_Nm__c=='No'){
            roTwo.isSelected = true;
        }
        radopts.add(roOne);
        radopts.add(roTwo);
        presettings.options = radopts;
        presub.inputs.add(presettings);
       
                                                             
        return step2; 
    } 
    
}