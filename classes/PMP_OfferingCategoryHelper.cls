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
  
  public static void createOfferingCategories(Intel_FormData formData, PMP_Partner_Offering__c offering,integer currentStep,integer stepChange){
        List<Intel_SpecificationDataWrapper> specList = New List<Intel_SpecificationDataWrapper>(); //main list 
        set<id> specValueSet = New set<id>();
        set<id> specSet = New set<id>();
        Map<id, PMP_Category__c> categoryById = New Map<id, PMP_Category__c>();
        Boolean SubCategoryPresent = false;
        List<PMP_Partner_Offering_Specification__c> offerinfSpecificationList = New List<PMP_Partner_Offering_Specification__c>();
       if((currentStep-stepchange) == 0){ // if user is on tab1 of UI
           specList =  populateSpecificationDataWrapper(formData.categoryAndSubCategory,null,formData.industryAndApplication);
       
       
           Map<id,PMP_Partner_Offering_Category__c> existingOfferingCategories = New Map<id,PMP_Partner_Offering_Category__c>();
            set<id> existingCategorySet = New set<id>();
            set<id> newCategorySet = New set<id>();
            List<PMP_Partner_Offering_Category__c> deleteOffCatList = New List<PMP_Partner_Offering_Category__c>();
            existingOfferingCategories = getExistingOfferingCategories(offering.Id); //to fetch existing offering categories
            List<Intel_SpecificationDataWrapper> filteredOffCategories = New List<Intel_SpecificationDataWrapper>();
             Set<String> uniqueSet = new Set<String>();
            for(PMP_Partner_Offering_Category__c existingOffCategory : existingOfferingCategories.values() ){
                existingCategorySet.add(existingOffCategory.PMP_Category_Id__c);
            }
        
            for(Intel_SpecificationDataWrapper spec : specList){
                newCategorySet.add(spec.id);
                
                if(!existingCategorySet.contains(spec.id)){
                    filteredOffCategories.add(spec); //to create record only for the newly selected categories
                }
            }
           	set<id> categoryIdSet = New set<id>();
            //looping through existing offering categories, to delete ones which are unselected
            for(id key : existingOfferingCategories.keySet()){
                PMP_Partner_Offering_Category__c offCat = existingOfferingCategories.get(key);
             
                //Not to delete Level1 and Level2 Categories 
                if((!newCategorySet.contains(offCat.PMP_Category_Id__c)) 
                    && offCat.Name != 'Categories'  
                   && offCat.PMP_Ancestor_Category_Cd__c != 'NPP_01_TYPE'){
                   
                       if(offCat.Name !='Industry' && offCat.Name !='Application'){
                           deleteOffCatList.add(offCat);
                       }
                        
                }
                /*Added by raj to get Id of level1 and level2 categories*/
                else if(!newCategorySet.contains(offCat.PMP_Category_Id__c) && (offCat.Name == 'Categories' || offCat.PMP_Ancestor_Category_Cd__c == 'NPP_01_TYPE')){
                    categoryIdSet.add(offCat.PMP_Category_Id__c);
                }
                /*-------------------------------------------End----------------------------------------------------------------------------------------------------*/
                //adding to uniqueset so that we will not create duplicate industry and application records
                if(offCat.Name =='Industry'){
                    uniqueSet.add('NPP_01_Industry');
                }
                if(offCat.Name =='Application'){
                    uniqueSet.add('NPP_01_APP');
                } 

            }
           
         
         if(specList.size() > 0){
           for(Intel_SpecificationDataWrapper spec : specList){
                    categoryIdSet.add((id)spec.Id);
                } 
            }
               if(categoryIdSet.size() >0) {
                 Map<id, PMP_Category__c> categoryMap = New Map<id, PMP_Category__c>( [Select id,PMP_Ancestor_Category_Cd__c, Name,PMP_Parent_Category_Id__c,Type__c,
                 PMP_Parent_Category_Id__r.PMP_Partner_Product_Category_Cd__c, PMP_Partner_Product_Parent_Category_Cd__c,PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Category_Key__c, 
                 PMP_Business_Segment_Nm__c from PMP_Category__c where id IN : categoryIdSet]);
                 categoryById = categoryMap;
               }
           	system.debug('###categoryIdSet:->'+categoryIdSet);
            system.debug('###categoryById:->'+categoryById);
            List<PMP_Partner_Offering_Category__c> offeringCategories = new List<PMP_Partner_Offering_Category__c>();
            system.debug('##spec:->'+filteredOffCategories);
            for(Intel_SpecificationDataWrapper spec : filteredOffCategories ){
              system.debug('##spec:->'+spec);
              PMP_Category__c category = categoryById.get(spec.Id);
              system.debug('###category:->'+category);
                PMP_Partner_Offering_Category__c offeringCat = new PMP_Partner_Offering_Category__c();
                offeringCat.PMP_Ancestor_Category_Cd__c = category.PMP_Ancestor_Category_Cd__c;
                system.debug('beforeException--->'+category.PMP_Ancestor_Category_Cd__c);
                if(category.PMP_Ancestor_Category_Cd__c.countMatches('|')==1 && category.Type__c == 'Category'){
                    SubCategoryPresent = true;
                	offering.PMP_Sub_Category_nm__c = category.Name;
                    offering.PMP_Business_Segment_Nm__c = category.PMP_Business_Segment_Nm__c;
                }   
                offeringCat.PMP_Category_Id__c = category.Id; 
                offeringCat.Name = category.Name;
                //offeringCat.PMP_Localized_Category_Nm__c = spec.PMP_Localized_Category_Nm__c;
                offeringCat.PMP_Offering_Category_External_Key__c   = category.PMP_Partner_Product_Category_Cd__c;
                offeringCat.PMP_Offering_Id__c   = offering.Id;
                
                offeringCategories.add(offeringCat);
                
                if((category.PMP_Ancestor_Category_Cd__c == 'NPP_01_Industry' || category.PMP_Ancestor_Category_Cd__c == 'NPP_01_APP')&& !uniqueSet.contains(category.PMP_Ancestor_Category_Cd__c)) {
                  PMP_Category__c category1 = categoryById.get(spec.Id);
                system.debug('###category:->'+category1.Name);
                  PMP_Partner_Offering_Category__c parentOfferingCat = new PMP_Partner_Offering_Category__c();
                  //parentOfferingCat.PMP_Ancestor_Category_Cd__c = category.PMP_Ancestor_Category_Cd__c;
                  parentOfferingCat.PMP_Category_Id__c = category.PMP_Parent_Category_Id__c; 
                  if(category.PMP_Ancestor_Category_Cd__c == 'NPP_01_Industry'){
                    parentOfferingCat.Name = 'Industry';
                  }else{
                    parentOfferingCat.Name = 'Application';
                  }
                  //offeringCat.PMP_Localized_Category_Nm__c = spec.PMP_Localized_Category_Nm__c;
                  parentOfferingCat.PMP_Offering_Category_External_Key__c   = category.PMP_Parent_Category_Id__r.PMP_Partner_Product_Category_Cd__c;
                  parentOfferingCat.PMP_Offering_Id__c   = offering.Id;
                  
                  uniqueSet.add(category.PMP_Ancestor_Category_Cd__c);
                  offeringCategories.add(parentOfferingCat);
                }
            }
            /*Added by raj to get all business segment from all the selected categories*/
		   /*Map<Id,List<PMP_Category__c>> categoryChildsById  = new Map<Id,List<PMP_Category__c>>();//contains list of childs for the category Id
		   Set<String> catPartnerSegment = new Set<String>();//to store unique business segment
           Boolean hasBusinessSegment = false;//to check whether the offering has business segment or not
           for(PMP_Category__c cat : categoryById.values()){//iterate over all the selected categories record from categoryById map
			   if(String.isNotBlank(cat.PMP_Parent_Category_Id__c) && String.isNotBlank(cat.PMP_Ancestor_Category_Cd__c) && cat.Type__c == 'Category'){//if parent,categoryId is not null and current category belongs to type category,populate categoryChildsById map
                   	List<PMP_Category__c> catChilds = new List<PMP_Category__c>();//list to hold category's children
					categoryChildsById.put(cat.Id,catChilds);//put the category as key and empty child list as value 
					if(categoryChildsById.containsKey(cat.PMP_Parent_Category_Id__c)){//if the map contains current category's parent add the category to child list
						categoryChildsById.get(cat.PMP_Parent_Category_Id__c).add(cat);//adding the category to child list
					}
			   }
           }
           for(Id catId : categoryChildsById.keySet()){//iterate over parent categories from the categoryChildsById map
               if(categoryChildsById.get(catId).size() == 0 && String.isNotBlank(categoryById.get(catId).PMP_Business_Segment_Nm__c)){//if the parent has no child and has business segment populate the set
                   catPartnerSegment.addAll(categoryById.get(catId).PMP_Business_Segment_Nm__c.split(';'));//split business segment and store in a set to get unique value
                   offering.PMP_Business_Segment_Nm__c = String.join((Iterable<String>)catPartnerSegment, ';');//join the partnerSegment with semi colon and populate the offering field
                   hasBusinessSegment = true;//set hasBusinessSegment as true
               }
           }*/
           system.debug('newBusinessSegment---->'+offering.PMP_Business_Segment_Nm__c);
           /*--------------------------------Changes End----------------------------*/
            if(offeringCategories.size() > 0){
                system.debug('insert list size --> ' +offeringCategories.size() );
                insert offeringCategories;
                
                if(SubCategoryPresent==true){//if sub category is present then update the offering
                  update offering;  
                }
                
            }
           
          /* if(SubCategoryPresent==false){
              offering.PMP_Sub_Category_nm__c = ''; 
           } */
           
           
            system.debug('deloffcatsize-->' +deleteOffCatList);
            if(deleteOffCatList.size()>0){
                delete deleteOffCatList;
            }
        }       
    }
      
  
  public static List<Intel_SpecificationDataWrapper> populateSpecificationDataWrapper(Map<string, List<Intel_SpecificationDataWrapper>> complexDataMap, Map<string, List<string>> smplListMap,
                                                            Map<string, List<Intel_SpecificationDataWrapper>> complexDataMap2){
        List<Intel_SpecificationDataWrapper> specList = New List<Intel_SpecificationDataWrapper>();
    
    if(complexDataMap != null) {
        for(string key : complexDataMap.keyset()){
            for(Intel_SpecificationDataWrapper iterSpec : complexDataMap.get(key)){
            Intel_SpecificationDataWrapper spec = New Intel_SpecificationDataWrapper();
                if(iterSpec.id.contains('|')){
                    spec.id = (id) iterSpec.id.substringBefore('|');
                    spec.relatedId = (id) iterSpec.id.substringAfter('|');
                }
                else{
                    spec.id = iterSpec.id;
                }
                spec.Value = iterSpec.Value != null ? iterSpec.Value : null;
                specList.add(spec); 
            }
        }
    }
            if(smplListMap != null) {
              for(string key : smplListMap.keyset()){
                  for(string iterSpec : smplListMap.get(key)){
                  Intel_SpecificationDataWrapper spec = New Intel_SpecificationDataWrapper();
                      if(iterSpec.contains('|')){
                          spec.id = iterSpec.substringBefore('|');
                          spec.relatedId = iterSpec.substringAfter('|');
                      }
                      else{
                          spec.id =  iterSpec;
                      }
                      
                      specList.add(spec); 
                  }
              }
            }
                
               
            for(string key : complexDataMap2.keyset()){
              /*Intel_SpecificationDataWrapper spec1 = New Intel_SpecificationDataWrapper();
              spec1.Id = key;
              specList.add(spec1);*/
              for(Intel_SpecificationDataWrapper iterSpec : complexDataMap2.get(key)){
              Intel_SpecificationDataWrapper spec = New Intel_SpecificationDataWrapper();
                  if(iterSpec.id.contains('|')){
                      spec.id = (id) iterSpec.id.substringBefore('|');
                      spec.relatedId = (id) iterSpec.id.substringAfter('|');
                  }
                  else{
                      spec.id = (id) iterSpec.id;
                  }
                  spec.Value = iterSpec.Value != null ? iterSpec.Value : null;
                  specList.add(spec); 
              }
            }
        
            return specList;
    }
    public static Map<id,PMP_Partner_Offering_Category__c> getExistingOfferingCategories(id offeringId){
        Map<id,PMP_Partner_Offering_Category__c> offCatMap = New Map<id,PMP_Partner_Offering_Category__c>([Select id, Name,PMP_Ancestor_Category_Cd__c,
                                                                PMP_Category_Id__c, PMP_Offering_Id__c from 
                                                                PMP_Partner_Offering_Category__c Where
                                                                PMP_Offering_Id__c =: offeringId]);
        return offCatMap;
    }
}