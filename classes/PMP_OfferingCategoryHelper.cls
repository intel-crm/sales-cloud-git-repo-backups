@isTest
/****************************************************************************************************************************************
* Class Name  : PMP_OfferingCategoryHelper 
* Version     : 1.0 
* Created Date: Jun-03-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Prakash                 Jun-03-2019                    Created for Creating Offering Category records
****************************************************************************************************************************************************************/


  
  public with sharing class PMP_OfferingCategoryHelper {
  
//   public static void createOfferingCategories(Intel_FormData formData, PMP_Partner_Offering__c offering,integer currentStep,integer stepChange){ 
//       List<Intel_SpecificationDataWrapper> specList = New List<Intel_SpecificationDataWrapper>(); //main list 
//         //set<id> specValueSet = New set<id>();
//         //set<id> specSet = New set<id>();
//         Map<id, PMP_Category__c> categoryById = New Map<id, PMP_Category__c>();
//         Boolean SubCategoryPresent = false;
//         //List<PMP_Partner_Offering_Specification__c> offerinfSpecificationList = New List<PMP_Partner_Offering_Specification__c>();
       
//       if((currentStep-stepchange) == 0){ // if user is on tab1 of UI
           
//            specList =  populateSpecificationDataWrapper(formData.categoryAndSubCategory,null,formData.industryAndApplication);
       
       
//            Map<id,PMP_Partner_Offering_Category__c> existingOfferingCategories = New Map<id,PMP_Partner_Offering_Category__c>();
//             set<id> existingCategorySet = New set<id>();
//             set<id> newCategorySet = New set<id>();
//             List<PMP_Partner_Offering_Category__c> deleteOffCatList = New List<PMP_Partner_Offering_Category__c>();
//             existingOfferingCategories = getExistingOfferingCategories(offering.Id); //to fetch existing offering categories
//             List<Intel_SpecificationDataWrapper> filteredOffCategories = New List<Intel_SpecificationDataWrapper>();
//              Set<String> uniqueSet = new Set<String>();
//             for(PMP_Partner_Offering_Category__c existingOffCategory : existingOfferingCategories.values() ){
//                 existingCategorySet.add(existingOffCategory.PMP_Category_Id__c);
//             }
             
//             for(Intel_SpecificationDataWrapper spec : specList){
//                 newCategorySet.add(spec.id);
                
//                 if(!existingCategorySet.contains(spec.id)){
//                     filteredOffCategories.add(spec); //to create record only for the newly selected categories
//                 }
//             }
//             set<id> categoryIdSet = New set<id>();
//             //looping through existing offering categories, to delete ones which are unselected
//             for(id key : existingOfferingCategories.keySet()){
//                 PMP_Partner_Offering_Category__c offCat = existingOfferingCategories.get(key);
             
//                 //Not to delete Level1 and Level2 Categories 
//                 if((!newCategorySet.contains(offCat.PMP_Category_Id__c)) 
//                     && offCat.Name != 'Categories'  
//                    && offCat.PMP_Ancestor_Category_Cd__c != 'NPP_01_TYPE'){
                   
//                        if(offCat.PMP_Offering_Category_External_Key__c !=System.Label.PMP_NPP_01_Industry &&
//                           offCat.PMP_Offering_Category_External_Key__c != System.Label.PMP_NPP_01_APP){
//                            deleteOffCatList.add(offCat);
//                        }
                        
//                 }
//                 /*Added by raj to get Id of level1 and level2 categories*/
//                 else if(!newCategorySet.contains(offCat.PMP_Category_Id__c) && (offCat.Name == 'Categories' || offCat.PMP_Ancestor_Category_Cd__c == 'NPP_01_TYPE')){
//                     categoryIdSet.add(offCat.PMP_Category_Id__c);
//                 }
//                 /*-------------------------------------------End----------------------------------------------------------------------------------------------------*/
//                 //adding to uniqueset so that we will not create duplicate industry and application records
//                 if(offCat.PMP_Offering_Category_External_Key__c ==System.Label.PMP_NPP_01_Industry){
//                     uniqueSet.add(System.Label.PMP_NPP_01_Industry);
//                 }
//                 if(offCat.PMP_Offering_Category_External_Key__c ==System.Label.PMP_NPP_01_APP){
//                     uniqueSet.add(System.Label.PMP_NPP_01_APP);
//                 } 

//             }
           
         
//          if(specList.size() > 0){
//            for(Intel_SpecificationDataWrapper spec : specList){
//                     categoryIdSet.add((id)spec.Id);
//                 } 
//             }
//                if(categoryIdSet.size() >0) {
//                  Map<id, PMP_Category__c> categoryMap = New Map<id, PMP_Category__c>( [Select id,PMP_Ancestor_Category_Cd__c, Name,PMP_Parent_Category_Id__c,Type__c,
//                  PMP_Parent_Category_Id__r.PMP_Partner_Product_Category_Cd__c, PMP_Partner_Product_Parent_Category_Cd__c,PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Category_Key__c, 
//                  PMP_Business_Segment_Nm__c from PMP_Category__c where id IN : categoryIdSet]);
//                  categoryById = categoryMap;
//                }
            
//             List<PMP_Partner_Offering_Category__c> offeringCategories = new List<PMP_Partner_Offering_Category__c>();
            
//             for(Intel_SpecificationDataWrapper spec : filteredOffCategories ){
              
//               PMP_Category__c category = categoryById.get(spec.Id);
                
//                 PMP_Partner_Offering_Category__c offeringCat = new PMP_Partner_Offering_Category__c();
//                 offeringCat.PMP_Ancestor_Category_Cd__c = category.PMP_Ancestor_Category_Cd__c;
//                 if(category.PMP_Ancestor_Category_Cd__c != null && category.PMP_Ancestor_Category_Cd__c.countMatches('|')==1 
//                    && category.Type__c == 'Category'){
//                     SubCategoryPresent = true;
// 					offeringCat.PMP_Ancestor_Category_Cd__c = category.PMP_Ancestor_Category_Cd__c;
//                     offering.PMP_Sub_Category_nm__c = category.Name;
//                     offering.PMP_Business_Segment_Nm__c = category.PMP_Business_Segment_Nm__c;
//                 }   
//                 offeringCat.PMP_Category_Id__c = category.Id; 
//                 offeringCat.Name = category.Name;
//                 //offeringCat.PMP_Localized_Category_Nm__c = spec.PMP_Localized_Category_Nm__c;
//                 offeringCat.PMP_Offering_Category_External_Key__c   = category.PMP_Partner_Product_Category_Cd__c;
//                 offeringCat.PMP_Offering_Id__c   = offering.Id;
                                
//                 offeringCategories.add(offeringCat);
                
//                 if((category.PMP_Ancestor_Category_Cd__c == 'NPP_01_Industry' || category.PMP_Ancestor_Category_Cd__c == 'NPP_01_APP')&& !uniqueSet.contains(category.PMP_Ancestor_Category_Cd__c)) {
//                   //PMP_Category__c category1 = categoryById.get(spec.Id);
                
//                   PMP_Partner_Offering_Category__c parentOfferingCat = new PMP_Partner_Offering_Category__c();
//                   //parentOfferingCat.PMP_Ancestor_Category_Cd__c = category.PMP_Ancestor_Category_Cd__c;
//                   parentOfferingCat.PMP_Category_Id__c = category.PMP_Parent_Category_Id__c; 
//                   if(category.PMP_Ancestor_Category_Cd__c == 'NPP_01_Industry'){
//                     parentOfferingCat.Name = 'Industry';
//                   }else{
//                     parentOfferingCat.Name = system.label.PMP_application; // value change from Application to Use Cases
//                   }
//                   //offeringCat.PMP_Localized_Category_Nm__c = spec.PMP_Localized_Category_Nm__c;
//                   parentOfferingCat.PMP_Offering_Category_External_Key__c   = category.PMP_Parent_Category_Id__r.PMP_Partner_Product_Category_Cd__c;
//                   parentOfferingCat.PMP_Offering_Id__c   = offering.Id;
                  
//                   uniqueSet.add(category.PMP_Ancestor_Category_Cd__c);
//                   offeringCategories.add(parentOfferingCat);
//                 }
//             }
           
//            /*--------------------------------Changes End----------------------------*/
//             if(offeringCategories.size() > 0 && Schema.SObjectType.PMP_Partner_Offering_Category__c.isCreateable()){
                
//                 insert offeringCategories;
                
//                 if(SubCategoryPresent==true && Schema.SObjectType.PMP_Partner_Offering__c.isUpdateable()){//if sub category is present then update the offering
//                   update offering;  
//                 }
                
//             }
//             if(deleteOffCatList.size()>0){
//                 delete deleteOffCatList;
//             }
//         }       
//     }
      
  
//   public static List<Intel_SpecificationDataWrapper> populateSpecificationDataWrapper(Map<string, List<Intel_SpecificationDataWrapper>> complexDataMap, Map<string, List<string>> smplListMap,
//                                                             Map<string, List<Intel_SpecificationDataWrapper>> complexDataMap2){
//         List<Intel_SpecificationDataWrapper> specList = New List<Intel_SpecificationDataWrapper>();
    
//     if(complexDataMap != null) {
//         for(string key : complexDataMap.keyset()){
//             for(Intel_SpecificationDataWrapper iterSpec : complexDataMap.get(key)){
//             Intel_SpecificationDataWrapper spec = New Intel_SpecificationDataWrapper();
//                 if(iterSpec.id.contains('|')){
//                     spec.id = (id) iterSpec.id.substringBefore('|');
//                     spec.relatedId = (id) iterSpec.id.substringAfter('|');
//                 }
//                 else{
//                     spec.id = iterSpec.id;
//                 }
//                 spec.Value = iterSpec.Value != null ? iterSpec.Value : null;
//                 specList.add(spec); 
//             }
//         }
//     }
//             if(smplListMap != null) {
//               for(string key : smplListMap.keyset()){
//                   for(string iterSpec : smplListMap.get(key)){
//                   Intel_SpecificationDataWrapper spec = New Intel_SpecificationDataWrapper();
//                       if(iterSpec.contains('|')){
//                           spec.id = iterSpec.substringBefore('|');
//                           spec.relatedId = iterSpec.substringAfter('|');
//                       }
//                       else{
//                           spec.id =  iterSpec;
//                       }
                      
//                       specList.add(spec); 
//                   }
//               }
//             }
                
               
//             for(string key : complexDataMap2.keyset()){
              
//               for(Intel_SpecificationDataWrapper iterSpec : complexDataMap2.get(key)){
//               Intel_SpecificationDataWrapper spec = New Intel_SpecificationDataWrapper();
//                   if(iterSpec.id.contains('|')){
//                       spec.id = (id) iterSpec.id.substringBefore('|');
//                       spec.relatedId = (id) iterSpec.id.substringAfter('|');
//                   }
//                   else{
//                       spec.id = (id) iterSpec.id;
//                   }
//                   spec.Value = iterSpec.Value != null ? iterSpec.Value : null;
//                   specList.add(spec); 
//               }
//             }
        
//             return specList;
//     }
//     public static Map<id,PMP_Partner_Offering_Category__c> getExistingOfferingCategories(id offeringId){
//         Map<id,PMP_Partner_Offering_Category__c> offCatMap = New Map<id,PMP_Partner_Offering_Category__c>([Select id, Name,PMP_Ancestor_Category_Cd__c,
//                                                                 PMP_Category_Id__c, PMP_Offering_Id__c,
//                                                                 PMP_Offering_Category_External_Key__c from 
//                                                                 PMP_Partner_Offering_Category__c Where
//                                                                 PMP_Offering_Id__c =: offeringId]);
//         return offCatMap;
//     }
//        public static void saveGetmCategories(string offeringCategories, id offeringId,map<string,List<Intel_SpecificationDataWrapper>> industryAndApplications){
//         List<Intel_SpecificationDataWrapper> specList = New List<Intel_SpecificationDataWrapper>();    
//         List<String> catList = offeringCategories.split(';');
//         Set<string> categoryIdSet = new Set<string>();
//         String Subcategory;
//         String businessSegment;  
//         String businessSegmentFinal; 
//         categoryIdSet.addAll(catList);
           
//            if(!industryAndApplications.isEmpty()){
//                specList =  populateSpecificationDataWrapper(null,null,industryAndApplications);
               
//                for(Intel_SpecificationDataWrapper spec : specList){
//                     categoryIdSet.add(string.valueOf(spec.id));
//             }
               
//            }   
        
//         //List<PMP_Partner_Offering_Category__c> existingOfferingCategories = new List<PMP_Partner_Offering_Category__c>();
//         Map<Id,PMP_Partner_Offering_Category__c> existingOfferingMap = new Map<Id,PMP_Partner_Offering_Category__c>();
//         List<PMP_Partner_Offering_Category__c> newOffCatList = new List<PMP_Partner_Offering_Category__c>();
//         List<PMP_Partner_Offering_Category__c> deleteOffcatList = new List<PMP_Partner_Offering_Category__c>();
//         Map<String,String> BusinessSegmentMap = new Map<String,String>();
        
//         for(PMP_Partner_Offering_Category__c offCat: [Select id, Name,PMP_Ancestor_Category_Cd__c,
//                                                                     PMP_Category_Id__c,PMP_Category_Id__r.PMP_Business_Segment_Nm__c, PMP_Offering_Id__c,
//                                                                     PMP_Offering_Category_External_Key__c from 
//                                                                     PMP_Partner_Offering_Category__c Where
//                                                                     PMP_Offering_Id__c =: offeringId]){
//                 // system.debug('offCat.Name'+offCat.Name);  
//                 // system.debug('offCat.PMP_Ancestor_Category_Cd__c'+offCat.PMP_Ancestor_Category_Cd__c);                                                    
//                 if((offCat.PMP_Ancestor_Category_Cd__c != null && offCat.PMP_Ancestor_Category_Cd__c.countMatches('|')>0) || (offCat.PMP_Ancestor_Category_Cd__c == 'NPP_01_Industry' || offCat.PMP_Ancestor_Category_Cd__c == 'NPP_01_APP')){
//                     existingOfferingMap.put(offCat.PMP_Category_Id__c,offCat);  
//                     BusinessSegmentMap.put(offCat.PMP_Category_Id__c,offCat.PMP_Category_Id__r.PMP_Business_Segment_Nm__c);
//                 }
    
//         }   
        
           
//         for(PMP_Category__c cat: [Select id,PMP_Ancestor_Category_Cd__c, Name,PMP_Parent_Category_Id__c,Type__c,
//                      PMP_Parent_Category_Id__r.PMP_Partner_Product_Category_Cd__c, PMP_Partner_Product_Parent_Category_Cd__c,
//                      PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Category_Key__c, 
//                      PMP_Business_Segment_Nm__c from PMP_Category__c where id IN : categoryIdSet]){
//             // system.debug('cat.Name'+cat.Name);         
//             // system.debug('cat.PMP_Ancestor_Category_Cd__c'+cat.PMP_Ancestor_Category_Cd__c);         
//             if((cat.PMP_Ancestor_Category_Cd__c != null && cat.PMP_Ancestor_Category_Cd__c.countMatches('|')>0) || (cat.PMP_Ancestor_Category_Cd__c == 'NPP_01_Industry' || cat.PMP_Ancestor_Category_Cd__c == 'NPP_01_APP')){             
//                 if(categoryIdSet.contains(cat.Id) && !existingOfferingMap.containsKey(cat.Id)){
//                    PMP_Partner_Offering_Category__c newOfferingCat = new PMP_Partner_Offering_Category__c();
//                    newOfferingCat.PMP_Category_Id__c = cat.Id;
//                    newOfferingCat.Name = cat.Name;
//                    newOfferingCat.PMP_Offering_Id__c = offeringId;
//                    newOfferingCat.PMP_Offering_Category_External_Key__c   = cat.PMP_Partner_Product_Category_Cd__c; 
//                    newOfferingCat.PMP_Ancestor_Category_Cd__c = cat.PMP_Ancestor_Category_Cd__c;
                    
//                    newOffCatList.add(newOfferingCat);
                   
//                    if(cat.PMP_Ancestor_Category_Cd__c != null && cat.PMP_Ancestor_Category_Cd__c.countMatches('|')==1 && cat.PMP_Ancestor_Category_Cd__c.contains('NPP_01_TYPE')){
//                        Subcategory = Subcategory==null?cat.Name:Subcategory+','+cat.Name;
//                        businessSegment = businessSegment==null?cat.PMP_Business_Segment_Nm__c:businessSegment+';'+cat.PMP_Business_Segment_Nm__c;
//                    }
//                 }
         
//         }
                         
           
        
//         }
           
//         for(id key : existingOfferingMap.keySet()){
//             if(!categoryIdSet.contains(string.valueOf(key))){
//                deleteOffcatList.add(existingOfferingMap.get(key)); 
//             }else{
//                 if(existingOfferingMap.get(key).PMP_Ancestor_Category_Cd__c.contains('NPP_01_TYPE') && existingOfferingMap.get(key).PMP_Ancestor_Category_Cd__c.countMatches('|')==1){
//                     Subcategory = Subcategory==null?existingOfferingMap.get(key).Name:Subcategory+','+existingOfferingMap.get(key).Name;
//                     businessSegment = businessSegment==null?businessSegmentMap.get(key):businessSegment+';'+businessSegmentMap.get(key);
//                 }
//             }    
               
//         }    
        
//         if(!deleteOffcatList.isEmpty()){
//            delete deleteOffcatList;
//         }
        
//         if(!newOffCatList.isEmpty()){
//            insert newOffCatList;
//         }
        
//         if(businessSegment!=Null && businessSegment!=''){
//            List<string> businessSegmentList = businessSegment.split(';');
           
//            for(string str:businessSegmentList){
                
//                 if(businessSegmentFinal == Null){   
//                     businessSegmentFinal = str;
                     
//                 }
//                 else if(!businessSegmentFinal.containsIgnoreCase(str)){
//                    businessSegmentFinal = businessSegmentFinal+';'+str;
                  
//                 }
//             }
            
//             PMP_Partner_Offering__c offering = new PMP_Partner_Offering__c();
//             offering.Id = offeringId;
//             offering.PMP_Business_Segment_Nm__c = businessSegmentFinal;
//             offering.PMP_Sub_Category_nm__c = Subcategory;
            
//             update offering;
//         }   
//     }   
}