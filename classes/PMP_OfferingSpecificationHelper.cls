@isTest
/****************************************************************************************************************************************
* Class Name  : PMP_OfferingSpecificationHelper
* Version     : 1.0 
* Created Date: 05-28-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Abhishek                         04-28-2019                    Created for Creating Offering Spec records
****************************************************************************************************************************************************************/

public with sharing class PMP_OfferingSpecificationHelper{
    
    
    // public static void createOfferingSpecification(Intel_FormData formData, id offeringId,integer currentStep,integer stepChange){
    //     List<Intel_SpecificationDataWrapper> specList = New List<Intel_SpecificationDataWrapper>(); //main list 
    //     set<id> specValueSet = New set<id>();
    //     set<id> specSet = New set<id>();
    //     Map<id, PMP_Specification__c> specificationMap = New Map<id, PMP_Specification__c>();
    //     Map<id, PMP_Specification_Value__c> specificationValueMap = New Map<id, PMP_Specification_Value__c>();
    //     List<PMP_Partner_Offering_Specification__c> offerinfSpecificationList = New List<PMP_Partner_Offering_Specification__c>();
    //     integer step = currentStep-stepchange;
        
    //     //set<string> ancestorCategorySet = New set<string>();
        
    //     List<PMP_Partner_Offering_Specification__c> exisitingOfferingSpecs = New List<PMP_Partner_Offering_Specification__c>();
        
    //     //stepchange will be 1 if user has clicked on next button and 0 if user has clicked on save.
        
    //     //getSpecList() method will return a list wrapper records so as to maintain uniformity while processing them in further steps.
    //    if((step) == 0){ // if user is on tab1 of UI
           
    //        exisitingOfferingSpecs = getExistingoffSpecs('tab1', offeringId); //fetch existing offering specs based on the tab
    //        specList =  getSpecList(formData.specification_cmplxTab1, formData.specification_smplTab1, formData.specification_txtTab1);
    //    }
       
    //    else if((step) == 1){ //if user  is on tab2 of UI
    //        //deleteExistingOfferingSpecs('tab2',offeringId); //delete exisiting records of the tab before re-inserting them
    //        exisitingOfferingSpecs = getExistingoffSpecs('tab2', offeringId);
    //        specList =  getSpecList(formData.specification_cmplxTab2, formData.specification_smplTab2, formData.specification_txtTab2);
    //    }
    //    else if((step) == 2){ //if user is on tab3
    //        //deleteExistingOfferingSpecs('tab3',offeringId); //delete exisiting records of the tab before re-inserting them
    //        exisitingOfferingSpecs = getExistingoffSpecs('tab3', offeringId);
    //        specList =  getSpecList(formData.specification_cmplxTab3, formData.specification_smplTab3, formData.specification_txtTab3);
    //    }
    
        
    //     Map<id,PMP_Partner_Offering_Specification__c> existingSpecMap = New Map<id,PMP_Partner_Offering_Specification__c>();
    //     Map<id,PMP_Partner_Offering_Specification__c> existingSpecValueMap = New Map<id,PMP_Partner_Offering_Specification__c>();
        
    //     set<string> newSpecValueSet = New Set<string>();
    //     set<string> newSpecSet = New Set<string>();
    //     List<PMP_Partner_Offering_Specification__c> specDeleteList = New List<PMP_Partner_Offering_Specification__c>();
    //     //loop through existing offspecs to populate existingSpecValueMap and existingSpecMap 
    //      for(PMP_Partner_Offering_Specification__c offSpec :exisitingOfferingSpecs){
    //          if(offSpec.PMP_Specification_Value_Id__c != null ){ // specification values
                 
    //              existingSpecValueMap.put(offSpec.PMP_Specification_Value_Id__c,offSpec);
    //          }
    //          else{ //specifications
    //              existingSpecMap.put(offSpec.PMP_Specification_Id__c, offSpec);
    //          }
    //     }
    //     List<Intel_SpecificationDataWrapper> toInsertSpecList = New List<Intel_SpecificationDataWrapper>();
    //  if(specList.size() > 0){
    //  //looping through the new set of records and comparing with exsting values to filter out already existing records.
    //      for(Intel_SpecificationDataWrapper spec : specList){
    //       /*  PMP_Specification_Value__c specValue = New PMP_Specification_Value__c();
    //         id recordId = (id) spec.id;
    //      if related id is null, it means record selected is specification. Else is relatedId is not null then its a spec value. */ 
    //         if(spec.relatedId != null ){ //if record is specification
    //             newSpecValueSet.add(spec.id);
    //             if(!existingSpecValueMap.containsKey(spec.Id)){ 
    //                 specValueSet.add((id) spec.Id);
    //                 specSet.add((id) spec.relatedId);
    //                 toInsertSpecList.add(spec);
    //             }
    //         }
    //         else{ //if record is specification value
    //             newSpecSet.add(spec.id);
    //             if(existingSpecMap.containsKey(spec.id)){
    //                 if(existingSpecMap.get(spec.id).PMP_Specification_Value_Cd__c != spec.value){
    //                     specSet.add((id) spec.Id);
    //                     specDeleteList.add(existingSpecMap.get(spec.id));
    //                     if(spec.value!=null)
    //                     {
    //                          toInsertSpecList.add(spec);
    //                     } 
    //                 }
                    
    //             }
    //             else{
    //                 specSet.add((id) spec.Id);
    //                 toInsertSpecList.add(spec);
    //             }
                
    //         } 
    //     }
    //  }
    //     //looping through existing offering specs to delete the unselected ones.
    //     for(PMP_Partner_Offering_Specification__c offSpec :exisitingOfferingSpecs){
          
    //          if(offSpec.PMP_Specification_Value_Id__c != null ){
    //              if(!newSpecValueSet.contains(offSpec.PMP_Specification_Value_Id__c)){         
    //                  specDeleteList.add(existingSpecValueMap.get(offSpec.PMP_Specification_Value_Id__c));
    //              }
                 
    //          }
    //          else{
    //              if(!newSpecSet.contains(offSpec.PMP_Specification_Id__c)){
    //                  specDeleteList.add(existingSpecMap.get(offSpec.PMP_Specification_Id__c));

    //              }
                 
    //          }
    //     }
        
        
    //     if(specSet.size() > 0){ //query the corresponding specification and spec value records for additional information required to create offering specification record.
    //          Map<id, PMP_Specification__c> specMap = New Map<id, PMP_Specification__c>( [Select id, Name,PMP_Specification_Name__c,PMP_Ancestor_Specification_Cd__c,PMP_Display_Type_Nm__c,   PMP_Partner_Product_Specification_Id__c from PMP_Specification__c where id IN : specSet]);
    //          specificationMap = specMap;
    //         }
    //         if(specValueSet.size() > 0){
    //           Map<id, PMP_Specification_Value__c>  specValueMap = New Map<id, PMP_Specification_Value__c> ([Select id, Name,PMP_Specification_Value_Nm__c, PMP_Spec_Pre_Release_Ind__c from PMP_Specification_Value__c Where id IN : specValueSet ]);
    //           specificationValueMap = specValueMap;
    //         }
            
    //     //creating list of offering specs to insert.    
    //     for(Intel_SpecificationDataWrapper spec : toInsertSpecList){
             
    //         if(spec.relatedId != null ){
    //             PMP_Partner_Offering_Specification__c offeringSpec = New PMP_Partner_Offering_Specification__c ();
    //             PMP_Specification__c specification = specificationMap.get(spec.relatedId);
    //             offeringSpec.PMP_Ancestor_Specification_Cd__c = specification.PMP_Ancestor_Specification_Cd__c;
    //             offeringSpec.PMP_Display_Type_Nm__c = specification.PMP_Display_Type_Nm__c;
    //             offeringSpec.PMP_Specification_Nm__c = specification.PMP_Specification_Name__c;
    //             offeringSpec.Name = specification.PMP_Specification_Name__c;
    //             offeringSpec.PMP_Product_Specification_Cd__c = specification.PMP_Partner_Product_Specification_Id__c;
    //             offeringSpec.PMP_Offering_Id__c = offeringId;
    //             offeringSpec.PMP_Specification_Id__c = specification.id;
    //             offeringSpec.PMP_Specification_Value_Cd__c = specificationValueMap.get(spec.Id).PMP_Specification_Value_Nm__c;
    //             //++Lalit--US601698--Set this flag based on Pre release indicator flag on Master object
    //             offeringSpec.PMP_Is_Pre_Release_Item_Ind__c = specificationValueMap.get(spec.Id).PMP_Spec_Pre_Release_Ind__c;
    //             offeringSpec.PMP_Specification_Value_Id__c = spec.id;
    //             offerinfSpecificationList.add(offeringSpec);
                    
    //         }
    //         else{
    //             PMP_Partner_Offering_Specification__c offeringSpec = New PMP_Partner_Offering_Specification__c ();
    //             PMP_Specification__c specification = specificationMap.get(spec.id);
    //             if(spec.value!=''){//Gireesh:US586645
    //                 offeringSpec.PMP_Ancestor_Specification_Cd__c = specification.PMP_Ancestor_Specification_Cd__c;
    //                 offeringSpec.PMP_Display_Type_Nm__c = specification.PMP_Display_Type_Nm__c;
    //                 offeringSpec.PMP_Specification_Nm__c = specification.PMP_Specification_Name__c;
    //                 offeringSpec.Name = specification.PMP_Specification_Name__c;
    //                 offeringSpec.PMP_Product_Specification_Cd__c = specification.PMP_Partner_Product_Specification_Id__c;
    //                 offeringSpec.PMP_Offering_Id__c = offeringId;
    //                 offeringSpec.PMP_Specification_Id__c = specification.id;
    //                 offeringSpec.PMP_Specification_Value_Cd__c = spec.value !='' ? spec.value : null;
    //                 offerinfSpecificationList.add(offeringSpec);
    //             }
                
            
    //         }
    //     }
           
    //        if(offerinfSpecificationList.size() > 0 && Schema.sObjectType.PMP_Partner_Offering_Specification__c.isCreateable()){
    //             insert offerinfSpecificationList;
    //         }
    //         if(specDeleteList.size()>0)
    //         {delete specDeleteList;}
     
     
    // }
    
    
    
    // public static List<Intel_SpecificationDataWrapper> getSpecList(Map<string, List<Intel_SpecificationDataWrapper>> complexDataMap, Map<string, List<string>> smplListMap,
    //                                                         Map<string, string> textMap){
     
    //     List<Intel_SpecificationDataWrapper> specList = New List<Intel_SpecificationDataWrapper>();
    //     /*Note :
    //         * If there is a '|' seperation in ID or the Map keyset --> it means selected record is a specification value.
    //         * When the record is specification value --> Intel_SpecificationDataWrapper.id = specification value record id,
    //                                                      Intel_SpecificationDataWrapper.relatedId = specification id
    //                                                      Intel_SpecificationDataWrapper.value = null if field is checkbox or radio. User entered value in case of text.
    //         *When the record is specification -->        Intel_SpecificationDataWrapper.id = specification record id,
    //                                                      Intel_SpecificationDataWrapper.relatedId = null,   
        
    //     */
    //     for(string key : complexDataMap.keyset()){  
    //         for(Intel_SpecificationDataWrapper iterSpec : complexDataMap.get(key)){     
    //         Intel_SpecificationDataWrapper spec = New Intel_SpecificationDataWrapper();
    //         //For Select All Checkbox, the value is set to 'Do_Not_Save', this will aviod saving Select All as record
    //             if(iterSpec.id != 'Do_Not_Save'){
    //                 if(iterSpec.id.contains('|')){
    //                     spec.id = (id) iterSpec.id.substringBefore('|');
    //                     spec.relatedId = (id) iterSpec.id.substringAfter('|');
    //                     spec.Value = iterSpec.Value != null ? iterSpec.Value : null;
    //                 }
    //                 else{
                        
    //                     if(iterSpec.value != null && iterSpec.value.contains('|')){
    //                         spec.relatedId = (id) iterSpec.value.substringAfter('|');
    //                         spec.id = (id) iterSpec.value.substringBefore('|');
    //                         spec.Value = null;
    //                     }
    //                     else{
    //                         spec.id = (id) iterSpec.id;
    //                         spec.Value = iterSpec.Value != null ? iterSpec.Value : null;
    //                     }
    //                 }
    //                 specList.add(spec); 
    //             }
    //         }
    //     }
    //         for(string key : smplListMap.keyset()){
    //             for(string iterSpec : smplListMap.get(key)){
    //             Intel_SpecificationDataWrapper spec = New Intel_SpecificationDataWrapper();
    //                 if(spec.id != 'Do_Not_Save'){
    //                     if(iterSpec.contains('|')){
    //                         spec.id = iterSpec.substringBefore('|');
    //                         spec.relatedId = iterSpec.substringAfter('|');
    //                     }
    //                     else{
    //                         spec.id =  iterSpec;
    //                     }
                       
    //                     specList.add(spec);
    //                 } 
                   
    //             }
    //         }
                
    //             for(string key : textMap.keyset()){
    //                 // system.debug('textMap' + 'Key-' +key +'value ' +textMap.get(Key) );
    //                 Intel_SpecificationDataWrapper spec = New Intel_SpecificationDataWrapper();
    //                     if(key.contains('|')){
    //                         spec.id =  key.substringBefore('|');
    //                         spec.relatedId =  key.substringAfter('|');
    //                         spec.Value = textMap.get(key).contains('|')? null: textMap.get(key);
    //                     }
    //                     else{
    //                         if(textMap.get(Key) != null && textMap.get(Key)?.contains('|')){
    //                             spec.id =  textMap.get(key).substringBefore('|');
    //                             spec.relatedId =  textMap.get(key).substringAfter('|');
    //                             spec.value =null;
    //                         }
    //                         else{
    //                             spec.id =  key;
    //                             spec.Value = textMap.get(key);
    //                         }
                            
                            
                            
    //                     }
    //                     specList.add(spec); 
    //             }                                            
    //         return specList;
    // }
  
    // public static List<PMP_Partner_Offering_Specification__c> getExistingoffSpecs(string tab, string offeringId){
        
    //     List <PMP_Specifications_Tab_Mapping__mdt> createOfferingMtdList;
        
    //     createOfferingMtdList = [Select Label from PMP_Specifications_Tab_Mapping__mdt
    //                              where tab__c=:tab and PMP_Is_Create_Offering_Ind__c=true];
            
    //     set<string> ancestorCategorySet = New set<string>(); 
        
    //     if(!createOfferingMtdList.isEmpty()){
    //         for(PMP_Specifications_Tab_Mapping__mdt CreateOfferingMtd : createOfferingMtdList){
    //             ancestorCategorySet.add('%'+CreateOfferingMtd.label+'%');
    //         }
    //     }    
    //     List<PMP_Partner_Offering_Specification__c> existingOfferingSpecList = New List<PMP_Partner_Offering_Specification__c>(); 
    //     List<PMP_Partner_Offering_Specification__c> onlyCurrentTabOfferingSpecList = New List<PMP_Partner_Offering_Specification__c>();     
        
    //     existingOfferingSpecList = [Select id, name, PMP_Ancestor_Specification_Cd__c,
    //                                                           PMP_Specification_Id__c,PMP_Specification_Value_Id__c,
    //                                                           PMP_Specification_Value_Cd__c,
    //                                                           PMP_Product_Specification_Cd__c
    //                                                           from PMP_Partner_Offering_Specification__c
    //                                          Where (PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c Like : ancestorCategorySet 
    //                                          or PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c Like : ancestorCategorySet)
    //                                          AND PMP_Offering_Id__c=: offeringId ];
                                             
    //     //to fix prod issue we have added below extra condition  
    //     //for FPGA(tab1) and FPGA Device Utilization Performance(tab2) have same PIM Id pattern
    //     //hence from when we are moving from intel technologies to specifications it is getting deleted
    //     //May need to change the design if more specs fall into this scenario
    //     if(tab == 'tab2') {
    //         for(PMP_Partner_Offering_Specification__c pOffSpec : existingOfferingSpecList){  
    //             if(pOffSpec.PMP_Product_Specification_Cd__c != 'NPP_FPGA_Device_Utilization_Performance'){
    //                 onlyCurrentTabOfferingSpecList.add(pOffSpec);                   
    //             }               
    //         }
    //         existingOfferingSpecList.clear();           
    //         existingOfferingSpecList.addAll(onlyCurrentTabOfferingSpecList);
    //         onlyCurrentTabOfferingSpecList.clear();
    //     }
        
    //     return existingOfferingSpecList;
    // } 
   
}