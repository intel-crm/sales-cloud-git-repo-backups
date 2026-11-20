/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchUtilityController
* Description : Contains the common classes used throught the Marketplace Search.
* Version     : 1.0 
* Created Date: 07-May-2019
* Modification Log :
* Created By  : Tanzanite Team (Infosys)
********************************************************************************************************************************************************************************************************/

public with sharing class PMP_SearchUtilityController extends PMP_SearchWrapperStore { 
     
  /*  @AuraEnabled(cacheable=true)
    public static String newSearch(String requestJSON){
        SearchRequest request = (SearchRequest)JSON.deserialize(requestJSON, SearchRequest.class);
        
        SearchResponse response = new SearchResponse();
        response.results = new List<PMP_SearchPartnerController.Partner>();
        response.resultCounts = new Map<String, Integer>();
        response.totalResults = 0;
        response.totalPages = 0;
        
        List<String> offerings = new List<String>();
        List<String> partners = new List<String>();
        
        if(request.category!=null){ 
            if(request.searchType == 'pmp-category'){               
            	offerings = filterOfferingsBySection(request.category,offerings);
                
                if(!request.filters.isEmpty()){
                    offerings = filterOfferingsBySelectedFilters(offerings, request.filters, request.searchType);
                    //system.debug('offerings after con filters : ' + offerings.size());
                }
                
                if(request.keyword != null){
                    offerings = PMP_SearchProductController.getOfferingIds(request.keyword, offerings);
                }
                response.results = PMP_SearchProductController.getProducts(offerings,request.page, 12,request.sortType, 'en_US');
            }else{
                if(request.searchType == 'pmp-partner-program'){

                   partners = filterPartnersByRole(request.category, null); 
                }else if(request.searchType == 'pmp-partner-category'){
                   partners = filterPartnersByIndustry(request.category, null); 
                }else if(request.searchType == 'pmp-partner-specialty'){
                   partners = filterPartnersBySpecialty(request.category, null); 
                }else if(request.searchType == 'pmp-partner-segment'){
                   partners = filterPartnersBySegment(request.category, null); 
                }   
                if(!request.filters.isEmpty()){
                    partners = filterOfferingsBySelectedFilters(partners, request.filters, request.searchType);
                    system.debug('...PARTNERS..'+partners);
                }
                
                if(request.keyword != null){
                    partners = PMP_SearchPartnerController.getPartnerList(request.keyword, partners);
                }
               // Boolean isDisti= [SELECT Id, PMP_Is_Distributor_Ind__c,PMP_Disti_Country_Coverage_Txt__c,PMP_Disti_Sys_Solutions_Nm__c,PMP_Disti_Components_Nm__c FROM PMP_Company__c WHERE Id IN:partnerIds]
				response.results = PMP_SearchPartnerController.getPartners(partners, request.page, 12, request.sortType, 'en_US');   
                System.debug('response.results'+response.results);
            }
            
        }
        
        
        
        if(request.searchType == 'pmp-category'){
            //response.resultCounts = PMP_SearchResponseResultCountStore.getResultCount(request.searchType, request.filters, offerings, request.isDisti);
        }else{
            //response.resultCounts = PMP_SearchResponseResultCountStore.getResultCount(request.searchType, request.filters, partners, request.isDisti);
        }
        
        

        
        response.totalResults = response.results.size();
        response.totalPages = response.totalResults/12;
        
        if(response.totalResults < 12){
            response.resultsPerPage = response.totalResults;
        }else{
            response.resultsPerPage = 12;
        }
        system.debug('-----ResultCount----- ' + JSON.serialize(response.resultCounts));
        system.debug('-----Response----- ' + response);
        //Card limit per page set to 12 - Prabuddh
        response.totalPages = (Integer)Math.ceil(Decimal.valueOf(response.totalResults).divide(/*Limit per page*///12, /* dec digits to round off*/ 1));

 //       return JSON.serialize(response);
  //  }
    
 /*   public static List<String> filterOfferingsBySelectedFilters(List<String> ids, Map<String, List<String>> selectedFilters, String searchType){
        List<String> offIds = ids;
        Set<String> filteredId = new Set<String>();
        List<String> result = new List<String>();
        filteredId.addAll(offIds);
        if(searchType == 'pmp-category'){
            offIds = PMP_SearchContextualFilterController.contfilterResults(selectedFilters, ids);
            filteredId.retainAll(offIds);
        }        
        if(selectedFilters.containsKey('Offering Categories') && !selectedFilters.get('Offering Categories').isEmpty()){
            offIds = PMP_SearchProductController.filterOfferings(selectedFilters.get('Offering Categories'), ids);
            filteredId.retainAll(offIds);
            system.debug('FilterId 1 : ' + filteredId.size());
        }
        if(selectedFilters.containsKey('Offering Industries') && !selectedFilters.get('Offering Industries').isEmpty()){
            offIds = PMP_SearchProductController.filterOfferings(selectedFilters.get('Offering Industries'), ids);
            filteredId.retainAll(offIds);
            system.debug('FilterId 2 : ' + filteredId.size());
        }   
        if(selectedFilters.containsKey('Offering Applications') && !selectedFilters.get('Offering Applications').isEmpty()){
            offIds = PMP_SearchProductController.filterOfferings(selectedFilters.get('Offering Applications'), ids);
            filteredId.retainAll(offIds);
            system.debug('FilterId 3 : ' + filteredId.size());
        }        
        if(selectedFilters.containsKey('Partner Specialties') && !selectedFilters.get('Partner Specialties').isEmpty()){
            //Logic to filter offerings based on selected specialty
            offIds = PMP_SearchContextualFilterController.getOfferingSpecialtyResults(selectedFilters.get('Partner Specialties'));                  
            filteredId.retainAll(offIds);            
            system.debug('FilterId 4 : ' + offIds.size());
        }
        if(selectedFilters.containsKey('Offering Segments') && !selectedFilters.get('Offering Segments').isEmpty()){
            offIds = getOfferingSegmentResults(selectedFilters.get('Offering Segments'), offIds, searchType);
            filteredId.retainAll(offIds);
            system.debug('FilterId 5 : ' + filteredId.size());
        }
        if(selectedFilters.containsKey('Partner Directory') && !selectedFilters.get('Partner Directory').isEmpty()){
            offIds = getPartnerRoleResults(selectedFilters.get('Partner Directory'), offIds, searchType);
            filteredId.retainAll(offIds);
            system.debug('FilterId 6 : ' + filteredId.size());
        }
        if(selectedFilters.containsKey('Partner Tier') && !selectedFilters.get('Partner Tier').isEmpty()){
            offIds = getPartnerTierResults(selectedFilters.get('Partner Tier'), offIds, searchType);
        }
        if(selectedFilters.containsKey('Intel Partner Events') && !selectedFilters.get('Intel Partner Events').isEmpty()){
            
            offIds =  PMP_SearchEventDetailController.getEventOfferings(selectedFilters.get('Intel Partner Events'),offIds );                 
            filteredId.retainAll(offIds);
            system.debug('FilterId 7 : ' + filteredId.size());
        }
        if(selectedFilters.containsKey('Partner A-Z') && !selectedFilters.get('Partner A-Z').isEmpty()){
           List<PMP_Partner_Offering__c> offList = [select id from PMP_Partner_Offering__c where id in :ids and PMP_Company_Id__c in :selectedFilters.get('Partner A-Z')];
            List<String> offIdList = new List<String>();
            for (PMP_Partner_Offering__c off: offList){
                offIdList.add(off.Id);
            }
            offIds= offIdList;
            filteredId.retainAll(offIds);
            system.debug('FilterId 8 : ' + filteredId.size());
        }
          
        result.addAll(filteredId);
        system.debug('FilterId 9 : ' + result.size());
        
        return result;
    }
    
    public static List<String> getPartnerTierResults(List<String> optionList, List<String> ids, String searchType){
        Map<String, String> idTierMap = new Map<String, String>();
        List<String> finalIds= new List<Id>();
        Set<String> result = new Set<String>();
        if(searchType == 'pmp-category'){
            List<PMP_Partner_Offering__c> offeringList = [SELECT id,PMP_Company_Id__r.PMP_Account_Program_Membership__c
                                                          from PMP_Partner_offering__c where Id IN: ids];
            
            
            for( PMP_Partner_Offering__c offering : offeringList )
            {
                idTierMap.put(offering.Id, offering.PMP_Company_Id__r.PMP_Account_Program_Membership__c);
            }
        }else{
            List<PMP_Company__c> partnerList = [SELECT id,PMP_Account_Program_Membership__c
                                                          from PMP_Company__c where Id IN: ids];
            
            
            for( PMP_Company__c offering : partnerList )
            {
                idTierMap.put(offering.Id, offering.PMP_Account_Program_Membership__c);
            }
        }
        
        for(String offId : idTierMap.keySet()){
            for(String opt : optionList){
                if(idTierMap.get(offId).contains(opt)){
                    result.add(offId);                    
                }
            }
            
        }    
        finalIds.addAll(result);
        return finalIds;
    }
    
    public static List<String> getOfferingSegmentResults(List<String> optionList, List<String> ids, String searchType){
        List<String> finalIds=new List<String>();
        
        if(searchType == 'pmp-category'){
            List<PMP_Partner_Offering__c> offList = new List<PMP_Partner_Offering__c>();
            String query =  'SELECT id FROM PMP_Partner_Offering__c WHERE Id IN:ids AND PMP_Business_Segment_Nm__c  INCLUDES (';
            
            for(String option :optionList){
                //Checking the indexof substring
                if(optionList.indexOf(option) == optionList.size()-1){
                    
                    query += '\'' + String.escapeSingleQuotes(option) + '\'';
                }else{
                    query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
                }
                
            }
            query+=')';
            
            offList = Database.query(query);
            for(PMP_Partner_offering__c off : offList){
                finalIds.add(off.Id);
            }
        }else{
            List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
            String query = 'SELECT id FROM PMP_Company__c WHERE Id IN:ids AND PMP_Partner_Segment_Nm__c INCLUDES (';
             
            for(String option :optionList){
                //Checking the indexof substring
                if(optionList.indexOf(option) == optionList.size()-1){
                    
                    query += '\'' + String.escapeSingleQuotes(option) + '\'';
                }else{
                    query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
                }
                
            }
            query+=')';
            partnerList = Database.query(query);
            for(PMP_Company__c partner : partnerList){
                finalIds.add(partner.Id);
            }
        }
        
        
        return finalIds;
    }
    
    public static List<String> getPartnerRoleResults(List<String> optionList, List<String> offerings, String searchType){
        List<Id> offeringIds= new List<Id>();
        List<Id> result = null;
        List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        
        if (!optionList.isEmpty()){
            if(searchType == 'pmp-category'){
                String query =  'SELECT id FROM PMP_Partner_Offering__c WHERE Id IN:offerings PMP_Company_Id__r.PMP_Partner_Program_nm__c  INCLUDES (';
                
                for(String option :optionList){
                    //Checking the indexof substring
                    if(optionList.indexOf(option) == optionList.size()-1){
                        
                        query += '\'' + String.escapeSingleQuotes(option) + '\'';
                    }else{
                        query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
                    }
                }
                
                query+=')';
                
                offeringList = Database.query(query);
                
                for( PMP_Partner_Offering__c offering : offeringList )
                {
                    offeringIds.add(offering.Id);
                }
                result = offeringIds;
            }else{
                String query = 'SELECT id FROM PMP_Company__c WHERE Id IN:ids AND PMP_Partner_Program_nm__c INCLUDES (';
                for(String option :optionList){
                    //Checking the indexof substring
                    if(optionList.indexOf(option) == optionList.size()-1){
                        
                        query += '\'' + String.escapeSingleQuotes(option) + '\'';
                    }else{
                        query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
                    }
                }
                query+=')';
                partnerList = Database.query(query);
                 for( PMP_Company__c offering : partnerList )
                {
                    offeringIds.add(offering.Id);
                }
                result = offeringIds;
            }
            
        }
        return result;
    }
    
    public static List<String> filterOfferingsBySection(String categoryId, List<String> offerings){
        List<PMP_Partner_Offering_Category__c> offList = new List<PMP_Partner_Offering_Category__c>();
       	
        offList = [select PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where 
                  PMP_Category_Id__c =:categoryId and PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c!=null 
                  and PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c!=null
                  and PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published
                  and PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY
                  and PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = False];
       
        Set<Id> offIds = new Set<Id>();
        for(PMP_Partner_Offering_Category__c off : offList){
            offIds.add(off.PMP_Offering_Id__c);
        } 
        List<Id> offIdsList=new List<Id>();
        offIdsList.addAll(offIds);    
        return offIdsList;
    }
    
    public static List<String> filterPartnersByRole(String roleId, List<String> partners){
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        List<String> roleList = new List<String>();
        List<String> result = new List<String>();
        List<PMP_Partner_Program__c> seoRoleList = [SELECT id, PMP_Is_Active_Ind__c, PMP_Partner_Program_Value_Txt__c
                                                  from PMP_Partner_Program__c
                                                  where (id =:roleId OR PMP_Partner_Role_Parent_Id__c =:roleId) AND PMP_Is_Active_Ind__c=TRUE];
        
        for(PMP_Partner_Program__c role : seoRoleList){
            roleList.add(role.PMP_Partner_Program_Value_Txt__c);
        }
        
        if(!roleList.isEmpty()){
            String query =  'SELECT id FROM PMP_Company__c WHERE PMP_Company_Lifecycle_Status_Nm__c =\'Published\' AND PMP_Benefit_Update_Ind__c=False AND PMP_Partner_Program_nm__c  INCLUDES (';
            
            for(String option :roleList){
                //Checking the indexof substring
                if(roleList.indexOf(option) == roleList.size()-1){
              
                    query += '\'' + String.escapeSingleQuotes(option) + '\'';
                }else{
                    query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
                }
     
            }
            query+=')';
            
            partnerList = Database.query(query);
            
            for(PMP_Company__c com : partnerList){
                result.add(com.Id);
            }
        }
        
        
       
        return result;
    }
    
    public static List<String> filterPartnersBySpecialty(String specialtyId, List<String> partners){
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        List<String> specialtyList = new List<String>();
        List<String> result = new List<String>();
        
        List<PMP_Partner_Specialty__c> seoSpecialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c where id =:specialtyId AND PMP_Is_Active_Ind__c = TRUE];
        
        for(PMP_Partner_Specialty__c spec : seoSpecialtyList){
            specialtyList.add(spec.Name);
        }
        
        if(!specialtyList.isEmpty()){
            String query =  'SELECT id FROM PMP_Company__c WHERE PMP_Company_Lifecycle_Status_Nm__c =\'Published\' AND PMP_Benefit_Update_Ind__c=False AND PMP_Account_Specialty__c  INCLUDES (';
            
            for(String option :specialtyList){
                //Checking the indexof substring
                if(specialtyList.indexOf(option) == specialtyList.size()-1){
              
                    query += '\'' + String.escapeSingleQuotes(option) + '\'';
                }else{
                    query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
                }
     
            }
            query+=')';
            
            partnerList = Database.query(query);
            
            for(PMP_Company__c com : partnerList){
                result.add(com.Id);
            }
        }
        
        return result;
    }
    
    public static List<String> filterPartnersByIndustry(String indShadowId, List<String> partners){
        
       String industryId = getMasterIdByShadowId(indShadowId);
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        List<String> result = new List<String>();
        
        List<PMP_Partner_Category__c> partnerCatList = [SELECT PMP_Partner_Id__c FROM PMP_Partner_Category__c WHERE PMP_Category_Id__c =:industryId 
                                                        AND PMP_Category_Id__r.PMP_Active_Ind__c = true
                                                        AND PMP_Partner_Id__r.PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published AND PMP_Partner_Id__r.PMP_Benefit_Update_Ind__c=False
                                                        ];
        
        for(PMP_Partner_Category__c partCat: partnerCatList){
                result.add(partCat.PMP_Partner_Id__c);
            }
        
        return result;
    }
    
    public static List<String> filterPartnersBySegment(String segmentId, List<String> partners){
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();        
        List<String> result = new List<String>();
        
        List<PMP_Partner_Segment__c> segmentList = [SELECT id,PMP_Partner_Segment_Value_Txt__c from PMP_Partner_Segment__c where id=: segmentId];
        
        partnerList = [Select id from PMP_Company__c where PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published AND PMP_Benefit_Update_Ind__c=False AND  PMP_Partner_Segment_Nm__c INCLUDES (:segmentList[0].PMP_Partner_Segment_Value_Txt__c)];
        
		for(PMP_Company__c com : partnerList){
           result.add(com.Id);
        }        
        
        return result;
    }
    
   public static String getMasterIdByShadowId(String shadowId){
        PMP_Category_Partner__c shad = new PMP_Category_Partner__c();
        if(String.isNotEmpty(shadowId)){
           shad = [select id, PMP_Category_Id__c from PMP_Category_Partner__c where id =:shadowId limit 1];
        }
       
        return shad.PMP_Category_Id__c;
    }*/
    
    //Method to get category tree and count based on search text//
 /*   @AuraEnabled(cacheable=true)
    public static String categorySearch(String requestJSON) {
        String sortField='';
        List<String> offerings = new List<String>();
        
        List<Id> partners = new List<Id>();
        
        SearchRequest request = (SearchRequest)JSON.deserialize(requestJSON, SearchRequest.class); 
        
        CategorySearchResponse response = new CategorySearchResponse();         
        response.keyword = request.keyword;
        response.allMarketplaceCount = 0;
        response.allPartnerCount = 0;
        response.allProductCount = 0;
        response.partnerCategories = new List<Category>(); //This list will contain All Partner tree
        response.productCategories = new List<Category>();// This list will contain All Offerings Tree
        response.filters = new List<Filter>();
        
        offerings = PMP_SearchProductController.getOfferingIds(request.keyword, offerings); //Give you the Offering based on keyowrd, If keyword is null it will give you all offerings 
               
        //partners = PMP_SearchPartnerController.getPartnerList(request.keyword);//Give you the Partner based on keyowrd, If keyword is null it will give you all partners
        
      
          
        
        //Filter offerings/partner is contextual filters are selected
        if(!request.selectedFilters.isEmpty() ){    
            if(request.searchType == PMP_StaticConstants_Partner.product){
                offerings = PMP_SearchProductController.quickSearchResults(request.selectedFilters,offerings);
                if (request.category!=null){
                    offerings = PMP_SearchContextualFilterController.contfilterResults(request.selectedFilters, offerings );
                } 
            }
            else if (request.searchType == PMP_StaticConstants_Partner.partner){  
                partners = PMP_SearchPartnerController.partnerQuickSearchResults(request.selectedFilters, request.searchType, partners);
            }
            else if(request.searchType == PMP_StaticConstants_Partner.all){
                partners = PMP_SearchPartnerController.partnerQuickSearchResults(request.selectedFilters, request.searchType, partners); 
                offerings = PMP_SearchProductController.quickSearchResults(request.selectedFilters,offerings);
            }
        }
        //Logic End
        
        //Build All Products Count
        Map<String,Integer> countMap = new Map<String,Integer>();
        if(!offerings.isEmpty()){
            countMap = PMP_SearchProductController.getCount(offerings);
        }
        
        //Build All Partners Count
        Map<String, Integer> partnerCount = new Map<String, Integer>(); 
        if(!partners.isEmpty()){
            partnerCount = PMP_SearchPartnerController.getPartnerCount(partners);
        }
        //Logic End
        
        response.allProductCount= offerings.size();
        response.allPartnerCount = partners.size();
        response.allMarketplaceCount= offerings.size() + partners.size();
        
        //Add Contextual Filters
       
        
       
        if(request.searchType == PMP_StaticConstants_Partner.product){
            //Filter offerings based on selected category
            if (request.category!=null){
                List<String> category=new List<String>();
                category.add(request.category);                
                offerings=PMP_SearchProductController.filterOfferings(category,offerings);
                
            }
            //Logic End
            
          
            
            
            
            //Adding Industry/Application Filter
            List<String> pimIds = new List<String>();
            pimIds.add(PMP_StaticConstants_Partner.PIM_INDUSTRY_ID);
            pimIds.add(PMP_StaticConstants_Partner.PIM_APPLICATION_ID);
             
            system.debug('pimIds'+pimIds);
            response.filters.addAll(PMP_SearchContextualFilterController.getOfferingCategoryFilters(pimIds,offerings, request.langCode));
            system.debug('response'+response);
            //Changes End
            
            //Adding Partner Filter
            Filter partnerFilter = PMP_SearchContextualFilterController.getOfferingPartnerFilter(offerings);
            if(!partnerFilter.tags.isEmpty())
                response.filters.add(partnerFilter);
            
            
            
            //Adding Partner Program Filter for MP Admin only
            //if(PMP_SearchUtilityController.isIntelAdmin())
            //{
            Filter partnerProgramFilter = PMP_SearchContextualFilterController.getOfferingPartnerProgramFilter(offerings,request.langCode);
            if(!partnerProgramFilter.tags.isEmpty())
            response.filters.add(partnerProgramFilter);
            //}
          
            //Created by Kartik 07-Jan-2020
            //Adding Speciality Filter for all the users - Public/Logged in Users
            //if(PMP_SearchUtilityController.isIntelAdmin()){   
            Filter offeringSpecialityFilter = PMP_SearchContextualFilterController.getPartnerSpecialtyFilterOfferings(offerings);
            if(!offeringSpecialityFilter.tags.isEmpty())
                response.filters.add(offeringSpecialityFilter);           
            
            //} 
                        
            //Adding all Contextual Filters
            if(request.category != null)
                response.filters.addAll(PMP_SearchContextualFilterController.getAllContextualFilters(offerings, request.langCode));
            
        }
        
        if(request.searchType == PMP_StaticConstants_Partner.partner){
            //Filter partners based on selected category
            if(request.category != null){
                partners = PMP_SearchPartnerController.filterPartners(request.category, partners);
            }
                
            response.filters = PMP_SearchContextualFilterController.getPartnerContextualFilters(partners, request.langCode);
        }
        
       
            //Add event filter
            Filter eventFilter = PMP_SearchEventDetailController.getEvents(request.selectedFilters,request.searchType, offerings, partners);
            
            if(!eventFilter.tags.isEmpty())
                response.filters.add(eventFilter);
        
        
        
        
        //Build Category Tree for All Offerings
        String userLanguage = request.langCode;
        Map<String,Category> catMap = new Map<String,Category>();
        
        
        String catNameAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Category__c','Name',userLanguage); 
        if(String.isEmpty(catNameAPI)){
            catNameAPI = 'Name';
        }
        String catDescAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Category__c','Description',userLanguage);
        if(String.isEmpty(catDescAPI)){
            catDescAPI = 'PMP_Partner_Offering_Category_Dsc__c';
        }
        
        //Learn More URL Logic
        String learnMoreUrlAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Learn_More_URL__mdt', 'URL', userLanguage);
        if(String.isEmpty(learnMoreUrlAPI)){
            learnMoreUrlAPI = 'PMP_Learn_More_English_Url__c';
        }
        Map<String,String> learnMoreUrlMap = new Map<String,String>();
        
        // To get all featured category Pim Ids
        for (PMP_Learn_More_URL__mdt learnMoreUrls:[select PMP_PIM_Category_Id__c,PMP_Learn_More_English_Url__c,PMP_Learn_More_Chinese_Url__c,PMP_Learn_More_Japanese_Url__c from PMP_Learn_More_URL__mdt ]){
            learnMoreUrlMap.put(learnMoreUrls.PMP_PIM_Category_Id__c, (String)learnMoreUrls.get(learnMoreUrlAPI));
        }
        //Logic End
        
        String pimId = PMP_StaticConstants_Partner.PIM_CATEGORY_ID;
        String ansPimId = PMP_StaticConstants_Partner.PIM_CATEGORY_ID + '%';
        List<PMP_Category__c> categories = [SELECT Id,PMP_Parent_Category_Id__c, Name,PMP_Partner_Offering_Category_Dsc__c, PMP_Category_Chinese_Dsc__c,    PMP_Category_Japanese_Dsc__c,PMP_Partner_Product_Category_Cd__c,
                                            PMP_Category_Chinese_Nm__c, PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Parent_Category_Cd__c 
                                            FROM PMP_Category__c 
                                            WHERE PMP_Active_Ind__c = true AND PMP_Ancestor_Category_Cd__c LIKE : ansPimId ORDER BY PMP_Category_Display_Sequence_Nbr__c];
        
        
        
            
        for(PMP_Category__c category: categories){
            Category cat = new Category();
            cat.categoryId = category.Id;
            
            cat.categoryName = String.valueOf(category.get(catNameAPI));
            if(String.isEmpty(cat.categoryName)){
                cat.categoryName = category.Name;
            }
            cat.categoryType = PMP_StaticConstants_Partner.product;
            cat.count = 0;
            if(countMap.containsKey(category.Id)){
                cat.count = countMap.get(category.Id);
            }
            cat.children = new List<Category>();
            cat.parentId = category.PMP_Parent_Category_Id__c;
            
            
            if(String.isNotEmpty(learnMoreUrlMap.get(category.PMP_Partner_Product_Category_Cd__c ))){
                cat.categoryCtaLink = learnMoreUrlMap.get(category.PMP_Partner_Product_Category_Cd__c );
            }
            
            if(category.PMP_Partner_Product_Parent_Category_Cd__c == pimId)
                response.productCategories.add(cat);    //Adding first level categories in the list
            catMap.put(category.Id,cat);
            
        }
        //To Build Tree structure
        for(Category cat: catMap.values()){
            if(catMap.containsKey(cat.parentId)){
                catMap.get(cat.parentId).children.add(cat);
            }
        }
        //Changes End
        
        /**************Partner Tree starts*******************/ 
         
 /*       List<PMP_SearchPartnerProgram_Config__mdt> ppList = new List<PMP_SearchPartnerProgram_Config__mdt>();
        if(Schema.sObjectType.PMP_SearchPartnerProgram_Config__mdt.isAccessible()){
            ppList = [SELECT Label,PMP_Partner_Program_Name__c,Active__c,  PMP_Partner_Program_value__c,
                      PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c,
                      PMP_Partner_Program_Desc__c, PMP_Partner_Program_Desc_Chinese__c, PMP_Partner_Program_Desc_Japanese__c
                      FROM PMP_SearchPartnerProgram_Config__mdt
                      ORDER BY Label ];
            
        }
        String partnerProgName = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Name',userLanguage);
        if(String.isEmpty(partnerProgName)){
                    partnerProgName = 'PMP_Partner_Program_Name__c';
                }
        
        
        String partnerProgDescApi = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Description',userLanguage);
        if(String.isEmpty(partnerProgDescApi)){
            partnerProgDescApi = 'PMP_Partner_Program_Desc__c';
        }
        List<PMP_Partner_Program__c> seoPpList = [SELECT id,PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE];
        Map<String,String> ppIdValueMap = new Map<String, String>();
        Map<String,String> ppValueIdMap = new Map<String,String>();
       
        for(PMP_Partner_Program__c pp : seoPpList){
           ppIdValueMap.put(pp.Id, pp.PMP_Partner_Program_Value_Txt__c);
           ppValueIdMap.put(pp.PMP_Partner_Program_Value_Txt__c, pp.Id);
        }
        
        Map<String, Category> partnerCatMap = new Map<String, Category>();
        
        for(PMP_SearchPartnerProgram_Config__mdt pp : ppList){
            if(pp.PMP_Partner_Program_value__c != 'ODM-LOEM' && pp.PMP_Partner_Program_value__c !='ITP'){
                Category partnerCat = new Category();
                //partnerCat.categoryId = pp.PMP_Partner_Program_value__c;
                partnerCat.categoryId = ppValueIdMap.get(pp.PMP_Partner_Program_value__c);
                partnerCat.categoryDescription = (String)pp.get(partnerProgDescApi);
                if(String.isEmpty(partnerCat.categoryDescription)){
                    partnerCat.categoryDescription = pp.PMP_Partner_Program_Desc__c;
                }
                
                partnerCat.categoryName = (String)pp.get(partnerProgName);
                if(String.isEmpty(partnerCat.categoryName)){
                    partnerCat.categoryName = pp.PMP_Partner_Program_Name__c;
                }
                partnerCat.categoryType = PMP_StaticConstants_Partner.partner;
                partnerCat.count=0;
                
                partnerCatMap.put(pp.PMP_Partner_Program_value__c, partnerCat); 
            }
            
        }   
        
        //Adding ODM-LOEM Speciality as Partner Program
        
        
        Category odm = new Category();
        odm.categoryId = ppValueIdMap.get('ODM-LOEM');
        odm.categoryName = System.Label.PMP_Partner_Directory_title3;
        odm.categoryType = PMP_StaticConstants_Partner.partner;
        odm.categoryDescription = System.Label.PMP_ODM_LOEM_Description;
        odm.count = 0;
        partnerCatMap.put(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program, odm);

         
        for(String s: partnerCatMap.keySet()){
            if(partnerCount.containsKey(s)){
                partnerCatMap.get(s).count = partnerCount.get(s);
            } 
        }
        response.partnerCategories.addAll(partnerCatMap.values());
        /****************Partner Tree ends******************/ 
        
        
         
       
 //       return JSON.serialize(response);
 //   }
    
    /***********************************************************************************************************/
    
 /*   @AuraEnabled(cacheable=true)
    public static String search(String requestJSON) {
        
        SearchRequest request = (SearchRequest)JSON.deserialize(requestJSON, SearchRequest.class);
        
        SearchResponse response = new SearchResponse();
        response.keyword = request.keyword;
        response.category = request.category;
        response.searchType = request.searchType;
        response.sortField = request.sortField;
        response.sortDirection = request.sortDirection;
        response.currentPage = request.currentPage;
        
        response.pageSize = request.pageSize;
        response.totalCount = 0;
        response.productResults = new List<PMP_SearchProductController.Product>();
        response.partnerResults = new List<PMP_SearchPartnerController.Partner>();
        response.filters = new List<Filter>();
        
        String userLanguage = request.langCode;
        
        
       
        
        //getting offering Ids using keyword
        List<String> offerings = null;//PMP_SearchProductController.getOfferingIds(request.keyword);
        
        //Getting partners using keyword
        List<String> partners = null;//PMP_SearchPartnerController.getPartnerList(request.keyword);
        
        
        if (request.searchType == PMP_StaticConstants_Partner.product) { 
            if (request.category!=null)
            {
                String catNameAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Category__c','Name',userLanguage); 
                if(String.isEmpty(catNameAPI)){
                    catNameAPI = 'Name';
                }
                String catDescAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Category__c','Description',userLanguage);
                if(String.isEmpty(catDescAPI)){
                    catDescAPI = 'PMP_Partner_Offering_Category_Dsc__c';
                }
                PMP_Category__c selectedCat = [SELECT id, Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Offering_Category_Dsc__c ,
                                               PMP_Category_Chinese_Dsc__c,PMP_Category_Japanese_Dsc__c
                                              From PMP_Category__c where id=: request.category];
                response.searchHeading = (String)selectedCat.get(catNameAPI);
                if(String.isEmpty(response.searchHeading)){
                    response.searchHeading = selectedCat.Name;
                }
                response.categoryDescription = (String)selectedCat.get(catDescAPI);
                if(String.isEmpty(response.categoryDescription)){
                    response.categoryDescription = selectedCat.PMP_Partner_Offering_Category_Dsc__c;
                }
                
                //Filters offerings based on selected categories
                List<String> category=new List<String>();
                category.add(request.category);                
                offerings=PMP_SearchProductController.filterOfferings(category,offerings);
                
            }
            
            //Filter Offerings based on Selected Contextual Filters
            if (!request.selectedFilters.isEmpty()){
                offerings = PMP_SearchProductController.quickSearchResults(request.selectedFilters, offerings);
                if (request.category!=null){
                    offerings = PMP_SearchContextualFilterController.contfilterResults(request.selectedFilters, offerings );
                }  
            }
          
        }
        
        if (request.searchType == PMP_StaticConstants_Partner.partner) {
            
          if(request.specialty!=null){
                System.debug('Inside request.specialty!=null');
                List<PMP_Partner_Specialty__c> psList = [SELECT Name,PMP_Partner_Specialty_Chinese_Nm__c,PMP_Partner_Specialty_Chinese_Dsc__c,PMP_Partner_Specialty_English_Dsc__c,PMP_Partner_Specialty_Japanese_Nm__c,PMP_Partner_Specialty_Japanese_Dsc__c, PMP_Is_Active_Ind__c 
                                                                     FROM PMP_Partner_Specialty__c where  id=: request.specialty AND PMP_Is_Active_Ind__c = TRUE
                                                                    ];
             
              
              String specDescApi = PMP_SearchUtilityController.getFieldApiName('PMP_Partner_Specialty__c', 'Description (English)',userLanguage);
             	if(String.isEmpty(specDescApi)){
                    specDescApi = 'PMP_Partner_Specialty_English_Dsc__c';
                }
                Map<String,String> valueLabelMap = new Map<String,String>();
              Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();      
              List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
              for( Schema.PicklistEntry pickListVal : ple){
                  valueLabelMap.put(pickListVal.getValue(),pickListVal.getLabel());
              }  
                response.searchHeading = valueLabelMap.get((String)psList[0].Name);
              if(String.isNotEmpty((String)psList[0].get(specDescApi))){
                  response.categoryDescription = (String)psList[0].get(specDescApi);
              }else{
                  response.categoryDescription = psList[0].PMP_Partner_Specialty_English_Dsc__c;
              }
                
                    //labelDescMap.get(psValueIdMap.get(psValueSeoIdMap.get(request.specialty)));
                
                //Filter partners based on selected specialty
               // partners = PMP_SearchPartnerController.filterPartners(request.specialty, partners);     
               
              
        
            //Learn More URL Logic for Specialty Learnmore link
             String learnMoreUrlAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Learn_More_URL__mdt', 'URL', userLanguage);
             if(String.isEmpty(learnMoreUrlAPI)){
            learnMoreUrlAPI = 'PMP_Learn_More_English_Url__c';
        }  
                Map<String,String> learnMoreUrlMap = new Map<String,String>();
         
       // To get all Specialty names from Metadata
       List<PMP_Learn_More_URL__mdt> learnMoreUrls=[select Label,isSpecialty__c,PMP_Learn_More_English_Url__c,PMP_Learn_More_Chinese_Url__c,PMP_Learn_More_Japanese_Url__c from PMP_Learn_More_URL__mdt where isSpecialty__c=True];
       
        
        for (PMP_Learn_More_URL__mdt learnMoreUrl:learnMoreUrls){
            learnMoreUrlMap.put(learnMoreUrl.Label, (String)learnMoreUrl.get(learnMoreUrlAPI));
           
        }
             
            if(!psList.isEmpty() && learnMoreUrlMap.containskey((String)psList[0].Name)) //checking the label
              
           
            {
            
               
               response.learMoreLink=learnMoreUrlMap.get((String)psList[0].Name);
            
                
            }
                                   
            }

           //logic end
            

            
            if(request.category!=null){
                System.debug('request.category!=null');
                List<PMP_SearchPartnerProgram_Config__mdt> ppList = [SELECT Label,PMP_Partner_Program_Name__c,Active__c,  PMP_Partner_Program_value__c,
                                                                     PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c,
                                                                     PMP_Partner_Program_Desc__c, PMP_Partner_Program_Desc_Chinese__c, PMP_Partner_Program_Desc_Japanese__c 
                                                                     FROM PMP_SearchPartnerProgram_Config__mdt
                                                                    ];
                String partnerProgName = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Name',userLanguage);
        		if(String.isEmpty(partnerProgName)){
                    partnerProgName = 'PMP_Partner_Program_Name__c';
                }
                String partnerProgDescApi = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Description',userLanguage);
                if(String.isEmpty(partnerProgDescApi)){
                    partnerProgDescApi = 'PMP_Partner_Program_Desc__c';
                }
                
                List<PMP_Partner_Program__c> partnerPrograms =[SELECT id, PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE];
                
                
                Map<String, String> ppValueSeoIdMap = new Map<String,String>();
                
                for(PMP_Partner_Program__c pp : partnerPrograms){
                    ppValueSeoIdMap.put(pp.Id, pp.PMP_Partner_Program_Value_Txt__c);
                }
                Map<String,String> labelValueMap = new Map<String,String>();
                Map<String,String> labelDescMap = new Map<String,String>();
                Map<String,String> ppValueIdMap = new Map<String,String>();
                for(PMP_SearchPartnerProgram_Config__mdt pp : ppList){
                    ppValueIdMap.put(pp.PMP_Partner_Program_Value__c, pp.Id);
                    if(String.isNotEmpty((String)pp.get(partnerProgName))){
                        labelValueMap.put( pp.Id,(String)pp.get(partnerProgName));
                    }else{
                       labelValueMap.put( pp.Id,pp.PMP_Partner_Program_Name__c);
                    }
                    if(String.isNotEmpty((String)pp.get(partnerProgDescApi))){
                        labelDescMap.put(pp.Id, (String)pp.get(partnerProgDescApi));
                    }else{
                        labelDescMap.put(pp.Id, pp.PMP_Partner_Program_Desc__c);
                    }
                    
                }
             labelValueMap.put(ppValueIdMap.get('ODM-LOEM'), System.Label.PMP_Partner_Directory_title3 );
             labelDescMap.put(ppValueIdMap.get('ODM-LOEM'), System.Label.PMP_ODM_LOEM_Description);
                response.searchHeading = labelValueMap.get(ppValueIdMap.get(ppValueSeoIdMap.get(request.category)));
                response.categoryDescription = labelDescMap.get(ppValueIdMap.get(ppValueSeoIdMap.get(request.category)));
                
                //Filter partners based on selected partner program
                partners = PMP_SearchPartnerController.filterPartners(request.category, partners);                
            }
                            system.debug('outside if --->'+request.selectedFilters);

            //Filter partners based on selected Contextual Filters
            if(!request.selectedFilters.isEmpty()){
                system.debug('entering if --->');
                partners = PMP_SearchPartnerController.partnerQuickSearchResults(request.selectedFilters, request.searchType, partners);
            }
            
            
        }
        
        if(request.searchType == PMP_StaticConstants_Partner.all){
            if(!request.selectedFilters.isEmpty() && request.selectedFilters.get('Marketplace_Event')!=null && !request.selectedFilters.get('Marketplace_Event').isEmpty()){
                offerings = PMP_SearchProductController.quickSearchResults(request.selectedFilters, offerings);
                partners = PMP_SearchPartnerController.partnerQuickSearchResults(request.selectedFilters, request.searchType, partners);
            }
        }
        
        if (request.searchType != PMP_StaticConstants_Partner.partner){
            
            List<String> offIds = new List<String>();
            
            List<PMP_SearchProductController.Product> allProducts= PMP_SearchProductController.getProducts(offerings,request.currentPage, request.pageSize,request.sortField, request.langCode);
            response.productResults = allProducts;
            response.totalCount += offerings.size();
            response.totalProductCount = offerings.size();
            
        }    
        
        // PARTNERS
        
        if (request.searchType!= PMP_StaticConstants_Partner.product){
            
            List<String> partnerIds = new List<String>();
          
            List<PMP_SearchPartnerController.Partner> allPartners = PMP_SearchPartnerController.getPartners(partners, request.currentPage, request.pageSize,request.sortField, request.langCode);
            
            response.partnerResults = allPartners;
            response.totalCount += partners.size();
            response.totalPartnerCount = partners.size();
            
        }
       

        
        // other search suggestions if 0 results
        response.suggestions = new List<String>();
        response.suggestions.add('Lorem');
        
        
        //system.debug(JSON.serialize(response));
        return JSON.serialize(response);
                
    }
    
    /**********************************************************************************************************/
    //Updated by Nikhil to show typeahead based on user locale
    //Updated by Subash for US601910
/*    @AuraEnabled(cacheable=true)
    public static String searchAutoComplete(String query,String searchType, String langCode) {
        
        String retResponse = '';
        AutoCompleteOptionForPartnerAndOffering finalResp = new AutoCompleteOptionForPartnerAndOffering();
        List<AutoCompleteOption> response = new List<AutoCompleteOption>(); 
        List<PMP_Partner_Offering__c> resultList = new List<PMP_Partner_Offering__c>();
        
        
        //Conditional check to perform not to display any offerings when search string is empty 
        if(searchType == PMP_StaticConstants_Partner.all) {
            
            finalResp.partnerOptions = getPartner(query, searchType, langCode);
            finalResp.offeringOptions = getOffering(query, searchType, langCode);
            AutoCompleteOptionForPartnerAndOffering[] po = new List<AutoCompleteOptionForPartnerAndOffering>();
            po.add(finalResp);
            retResponse = JSON.serialize(po);
            
        } else if(String.isNotEmpty(query) && searchType != PMP_StaticConstants_Partner.partner) {
            
            response = getOffering(query, searchType, langCode);
            retResponse = JSON.serialize(response);
            
        } else if(String.isNotEmpty(query) && searchType == PMP_StaticConstants_Partner.partner) {
            
            response = getPartner(query, searchType, langCode);
            retResponse = JSON.serialize(response);
        }  
        
        system.debug('offeringDetailList'+response);
        
        return retResponse;        
    }
    
    public static List<AutoCompleteOption> getPartner(String query,String searchType, String userLanguage) {
        
        List<AutoCompleteOption> response = new List<AutoCompleteOption>();
        List<String> PartnerIDSet = new List<String>();
        if(searchType == PMP_StaticConstants_Partner.partner)
        {
             PartnerIDSet = PMP_SearchPartnerController.SerachPartnersByName(query);
        }
        else
        {
        
            //PartnerIDSet = PMP_SearchPartnerController.getPartnerList(query);
        }
        if(PartnerIDSet != null && PartnerIDSet.size() > 0) {
            
            if(Schema.sObjectType.PMP_Company__c.isAccessible()) {
                
                Integer recLimit = searchType == PMP_StaticConstants_Partner.all ? Integer.valueOf(Label.PMP_Search_Suggestion_Count) : 6;
                
                //Removing Basic Access Benefit associated Partners from type ahead suggestions as part of US629512
                for(PMP_Company__c ptnr : [SELECT Name FROM PMP_Company__c WHERE Id IN : PartnerIDSet
                                           AND PMP_Partner_Benefit_Type__c !=: PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access ORDER BY Name ASC LIMIT :recLimit]) {
                    
                    AutoCompleteOption od = new AutoCompleteOption();
                    od.recordId = ptnr.id;
                    od.label = ptnr.Name;
                    od.keyword = ptnr.Name;
                    od.searchType = PMP_StaticConstants_Partner.partner;
                    od.category= null;
                    response.add(od);   
                }
            }
            system.debug(LoggingLevel.INFO, response);
        }
        return response;
    }
    
    
    public static List<AutoCompleteOption> getOffering(String query,String searchType, String userLanguage) {
        
        List<AutoCompleteOption> response = new List<AutoCompleteOption>();
        Map<String,PMP_Partner_Offering_Translation__c> offTransMap = new Map<String,PMP_Partner_Offering_Translation__c>();
        String offNameAPI = getFieldApiName('PMP_Partner_Offering_Translation__c','Name',userLanguage);
        if(String.isEmpty(offNameAPI)){
            offNameAPI = 'PMP_English_Txt__c';
        }
        //List<String> offerings = null;
        List<String> offerings =  PMP_SearchProductController.getOfferingIds(query,);
        
        List<PMP_Partner_Offering_Translation__c> offTransList = [SELECT PMP_Partner_Offering_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Partner_Offering_Translation__c 
                                                                  WHERE PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_NAME AND PMP_Partner_Offering_Id__c IN :offerings 
                                                                  ORDER BY PMP_Partner_Offering_Id__r.PMP_Featured_Offering_Ind__c DESC NULLS LAST,PMP_Partner_Offering_Id__r.PMP_Offering_Status_Update_Dt__c DESC NULLS LAST];
        
        for(PMP_Partner_Offering_Translation__c trans: offTransList){
            offTransMap.put(trans.PMP_Partner_Offering_Id__c,trans);
        }
        
        Integer rangeLast = Math.min(6, offerings.size());
        if(searchType == PMP_StaticConstants_Partner.all) {
            Integer suggestionCount = Integer.valueOf(Label.PMP_Search_Suggestion_Count);
            rangeLast = Math.min(suggestionCount, offerings.size());     //To show suggestions size based on PMP_Search_Suggestion_Count custom label in homepage
        }
        for(Integer i=0; i < rangeLast; i++){
            AutoCompleteOption od = new AutoCompleteOption();
            od.recordId =offerings[i];
            if(offTransMap.containsKey(od.recordId)){
                if(((String)offTransMap.get(od.recordId).get(offNameAPI)) != null){
                    od.label = ((String)offTransMap.get(od.recordId).get(offNameAPI)).unescapeHtml4();
                }else if(offTransMap.get(od.recordId).PMP_English_Txt__c != null){
                    od.label = offTransMap.get(od.recordId).PMP_English_Txt__c.unescapeHtml4();
                }
                
            }
            od.keyword = query;
            od.searchType = PMP_StaticConstants_Partner.product;
            od.category= null;
            response.add(od);
        }
        
        return response;
    }*/
    
    /**********************************************************************************************************/
    
    
    /** 
* @description : to check if the current user belongs to the same partner 
* @developer : Prabuddh
* @return a Map<String, Boolean> 
* Method Parameters - List of account Ids
*/
     //OPTIMISATION WW44
    public static user returnCurrentUser(){       
        User currentUser = [Select id, AccountId,Core_IPA_One_Partner_Id__c from User where Id =: UserInfo.getUserId()]; //Fetching the AccountId related to current user       
    return currentUser;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> isSamePartnerUser(List<String> accountIds){
        Map<String, Boolean> isSamePartnerMap = new Map<String, Boolean>();
         //OPTIMISATION WW44
		User currentUser = returnCurrentUser();
        /*for(String accId : accountIds){
            isSamePartnerMap.put(accId, false);
        }
        
        if(currentUser.AccountId != null){ // If the Account has AccountId field (filtering sys admins and guest users)

            for(String accId : accountIds){
                if(currentUser.Core_IPA_One_Partner_Id__c == accId){
                    isSamePartnerMap.put(accId, true); // Mark True againt the param accountId
                }else{
                    isSamePartnerMap.put(accId, false); // mark False against the param accountId
                }
                
            }
        }*/for(String accId : accountIds){
                if(currentUser.AccountId != null){            
                isSamePartnerMap.put(accId,currentUser.Core_IPA_One_Partner_Id__c == accId);
            }
         else {
             isSamePartnerMap.put(accId, false);
            }
        }       
       return isSamePartnerMap; // Return the Map
    }
    
     //OPTIMISATION WW44
  /** 
* @description : to check if the current user belongs to the same partner (new method) for detail pages
* @developer : Yashasvi Aggarwal
* @return a Boolean 
* Method Parameters - List of account Ids
*/
   /* @AuraEnabled(cacheable=true)
    public static Boolean isSamePartnerUserMethod(List<String> accountIds){
        Boolean isSamePartner = false;

        User currentUser = [Select id, AccountId,Core_IPA_One_Partner_Id__c from User where Id =: UserInfo.getUserId()]; //Fetching the AccountId related to current user
        
        if(currentUser.AccountId != null){ // If the Account has AccountId field (filtering sys admins and guest users)

            for(String accId : accountIds){
                if(currentUser.Core_IPA_One_Partner_Id__c == accId){
                    isSamePartner=true; // true if same partner
                }
            }
        }      
       return isSamePartner; // Return the boolean value
    }*/
    
     @AuraEnabled(cacheable=true)
    public static Boolean isSamePartnerUserMethod(List<String> accountIds){
        User currentUser = returnCurrentUser();
        //User currentUser = [Select id, AccountId,Core_IPA_One_Partner_Id__c from User where Id =: UserInfo.getUserId()]; //Fetching the AccountId related to current user       
        if(currentUser.AccountId != null && currentUser.Core_IPA_One_Partner_Id__c!=null){
    		return accountIds.contains(currentUser.Core_IPA_One_Partner_Id__c);
	}
        return false;    
    }
    
     /** 
* @description : to check if the current user belongs to the same partner (new method) for partner and offering cards only
* @developer : Yashasvi Aggarwal
* @return a Boolean 
* Method Parameters - List of account Ids
*/ //OPTIMISATION WW44
     @AuraEnabled(cacheable=true)
    public static Boolean isSamePartnerUserCardMethod(List<String> accountIds,String isAccountId,String loggedinUserAccountId){
       /* Boolean isSamePartner = false;
        if(isAccountId != null){ // If the Account has AccountId field (filtering sys admins and guest users)

            for(String accId : accountIds){
                if(loggedinUserAccountId == accId){
                    isSamePartner=true; // true if same partner
                }
            }
        }
        
       return isSamePartner; */
        return isAccountId != null && loggedinUserAccountId!=null && accountIds.contains(loggedinUserAccountId);
    }
    
    /** 
* @description : to check if the current user is a guest user 
* @developer : Prabuddh
* @return : Boolean 
* Method Parameters - no parameters
*/
    @AuraEnabled(cacheable = true)
    public static Boolean isGuest(){
        
        Boolean isGuest = false;
        
        String userName = UserInfo.getFirstName()+' '+ UserInfo.getLastName();
        if(userName.equalsIgnoreCase(PMP_StaticConstants_Partner.guestUser))
            isGuest = true;
        
        return isGuest;
    }
    
    /** 
* @description : to check if the current user is the System Administrator 
* @developer : Prabuddh
* @return a Boolean 
* Method Parameters - No params
*/
    @AuraEnabled(cacheable = true)
    public static Boolean isSysAdmin(){
        Boolean isSysAdmin = false;
        Id profId = userInfo.getProfileId();
        String profileName = [Select Name from Profile where Id =: profId].Name;
        
        if(PMP_StaticConstants_Partner.adminProfiles.contains(profileName))
            isSysAdmin = true;
        
        return isSysAdmin;
    }
    
    /** 
* @description : to check if for the current user contact partner button is visible
* @developer : Prabuddh
* @return a Map<String, Boolean> 
* Method Parameters - List of Company Information Objects
* "Used for product/partner cards"
*/
   /* @AuraEnabled(cacheable = true)
    public static Map<String, Boolean> isContactPartnerVisible(List<PMP_Company__c> partners){
        Map<String,List<String>> partnerAccMap= new Map<String,List<String>>();//map to store partner id with respective active opid accounts
        Map<String,boolean> partnerSamePartnerBooleanMap= new Map<String,boolean>();//map to store partner id with same partner boolean value
        Map<String, Boolean> contactVisMap = new Map<String,Boolean>();
        //Map<String, Boolean> isSamePartnerMap = new Map<String, Boolean>();
        List<String> accountIds = new List<String>();
        //Modified as a part of OPID Restructure
        Set<Id> partnerId = new Set<Id>();
        for(PMP_Company__c partner : partners){
            partnerId.add(partner.Id);
        }
        //OPTIMISATION WW44
       // User currentUser = [Select id, AccountId,Core_IPA_One_Partner_Id__c from User where Id =: UserInfo.getUserId()]; //Fetching the AccountId related to current user
       User currentUser = returnCurrentUser();
        List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccountToMpiByCompanyId(partnerId);
        Map<Id,Set<Id>> mapOfMpiToListAccountsActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjects);  
        for(PMP_Company__c partner : partners){
            if(mapOfMpiToListAccountsActive.containsKey(partner.Id)){
                for(Id acc : mapOfMpiToListAccountsActive.get(partner.Id)){
                    accountIds.add(acc);
                }
                partnerAccMap.put(partner.Id,accountIds);
                accountIds = new List<String>();
            }
        }
        for(PMP_Company__c partner : partners){
            if(partnerAccMap.containsKey(partner.Id)){
                Boolean isSamePartner=false;
                if(partnerAccMap.get(partner.Id)!=null)
                {
                   isSamePartner = PMP_SearchUtilityController.isSamePartnerUserCardMethod(partnerAccMap.get(partner.Id),currentUser.AccountId,currentUser.Core_IPA_One_Partner_Id__c);// Checking if the current user belongs to which partner as part new OPID Restructure
                }
                partnerSamePartnerBooleanMap.put(partner.id,isSamePartner);
            }
        }
        //Existing Logic
        /*for(PMP_Company__c partner : partners){
            accountIds.add(partner.PMP_Account_Id__c);  // getting all accountIds related to the partners       
        }*/
       // isSamePartnerMap = PMP_SearchUtilityController.isSamePartnerUser(accountIds); // Checking if the current user belongs to which partner    
      //  Boolean isCurrentUserEligible; 
        
       /* if(Test.isRunningTest()){
            isCurrentUserEligible = true;
        }
        else{
           isCurrentUserEligible = PMP_Utility.showContactPartnerButton();
        }
        // Checking if the currentUser is eligible to view the button
        for(PMP_Company__c partner : partners){ //iterating over the partners
            if(isCurrentUserEligible){ // Check if current user is eligible to view button
                //Condition to check if Enable Lead gen is true
                if(partner.PMP_Is_Enabled_Lead_Gen_Nm__c == PMP_StaticConstants_Partner.TRUE_STRING || partner.PMP_Is_Enabled_Lead_Gen_Nm__c == null){
                    //Condition to check if Limit Lead Gen is False
                    if(partner.PMP_Is_Lead_Gen_Limited_Nm__c == PMP_StaticConstants_Partner.FALSE_STRING || partner.PMP_Is_Lead_Gen_Limited_Nm__c == null){  
                        if(partnerSamePartnerBooleanMap.containsKey(partner.id)){        
                            //Checking if the current user is not of same partner
                            if(!partnerSamePartnerBooleanMap.get(partner.id)){
                                contactVisMap.put(partner.Id, true); // If all conditions match set visibility boolean as true
                            }else{
                                contactVisMap.put(partner.Id, false);// if a condition doesn't match set visibility boolean as false
                            } 
                        }
                        /* Existing code
                        if(isSamePartnerMap.containsKey(partner.PMP_Account_Id__c)){
                            //Checking if the current user is not of same partner
                            if(!isSamePartnerMap.get(partner.PMP_Account_Id__c)){
                                contactVisMap.put(partner.Id, true); // If all conditions match set visibility boolean as true
                            }else{
                                contactVisMap.put(partner.Id, false);// if a condition doesn't match set visibility boolean as false
                            }
                        }*/
                  /*  }else{ // If Limit Lead gen is True --- contact partner button will be limited to partner users only
                        if(!PMP_SearchUtilityController.isGuest() && partnerSamePartnerBooleanMap.containsKey(partner.id)){ // checking if the current user is not a guest
                            //if(partnerSamePartnerBooleanMap.containsKey(partner.id)){  
                                if(!partnerSamePartnerBooleanMap.get(partner.id)){ 
                                    contactVisMap.put(partner.Id, true); // If all conditions match set visibility boolean as true
                                }else{
                                    contactVisMap.put(partner.Id, false);// if a condition doesn't match set visibility boolean as false
                                }  
                            //}
                        }
                        /*Existing code
                            if(isSamePartnerMap.containsKey(partner.PMP_Account_Id__c)){
                                //Checking if the current user is not of same partner
                                if(!isSamePartnerMap.get(partner.PMP_Account_Id__c)){
                                    contactVisMap.put(partner.Id, true);// If all conditions match set visibility boolean as true
                                }else{
                                    contactVisMap.put(partner.Id, false);// if a condition doesn't match set visibility boolean as false
                                }
                            }
                        */
                    
                      /*  else{
                                   contactVisMap.put(partner.Id, false);// if a condition doesn't match set visibility boolean as false                            
                        }
                    }
                }else{ // If Enable Lead Gen is false set visibility boolean as false
                    contactVisMap.put(partner.Id, false);
                }
            }else{ // If current user is not eligible set visibility boolean as false
                contactVisMap.put(partner.Id, false);
            }            
        } 
       return  contactVisMap; // Return contact button visibility map
    }*/

      @AuraEnabled(cacheable = true)
    public static Map<String, Boolean> isContactPartnerVisible(List<PMP_Company__c> partners){
        Map<String,List<String>> partnerAccMap= new Map<String,List<String>>();//map to store partner id with respective active opid accounts
        Map<String,boolean> partnerSamePartnerBooleanMap= new Map<String,boolean>();//map to store partner id with same partner boolean value
        Map<String, Boolean> contactVisMap = new Map<String,Boolean>();
        //Map<String, Boolean> isSamePartnerMap = new Map<String, Boolean>();
        List<String> accountIds = new List<String>();
        //Modified as a part of OPID Restructure
        Set<Id> partnerId = new Set<Id>();
        for(PMP_Company__c partner : partners){
            partnerId.add(partner.Id);
        }
        //OPTIMISATION WW44
       // User currentUser = [Select id, AccountId,Core_IPA_One_Partner_Id__c from User where Id =: UserInfo.getUserId()]; //Fetching the AccountId related to current user
       User currentUser = returnCurrentUser();
        List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccountToMpiByCompanyId(partnerId);
        Map<Id,Set<Id>> mapOfMpiToListAccountsActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjects); 
         Boolean isCurrentUserEligible; 
        
        if(Test.isRunningTest()){
            isCurrentUserEligible = true;
        }
        else{
           isCurrentUserEligible = PMP_Utility.showContactPartnerButton();
        }
        for(PMP_Company__c partner : partners){
            if(mapOfMpiToListAccountsActive.containsKey(partner.Id)){
                for(Id acc : mapOfMpiToListAccountsActive.get(partner.Id)){
                    accountIds.add(acc);
                }
                partnerAccMap.put(partner.Id,accountIds);
                accountIds = new List<String>();
            }
             //OPTIMISATION WW44
       // }
        //for(PMP_Company__c partner : partners){
            if(partnerAccMap.containsKey(partner.Id)){
                Boolean isSamePartner=false;
                if(partnerAccMap.get(partner.Id)!=null)
                {
                   isSamePartner = PMP_SearchUtilityController.isSamePartnerUserCardMethod(partnerAccMap.get(partner.Id),currentUser.AccountId,currentUser.Core_IPA_One_Partner_Id__c);// Checking if the current user belongs to which partner as part new OPID Restructure
                }
                partnerSamePartnerBooleanMap.put(partner.id,isSamePartner);
            }
       // }
        //OPTIMISATION WW44
        // Checking if the currentUser is eligible to view the button
       // for(PMP_Company__c partner : partners){ //iterating over the partners
            if(isCurrentUserEligible){ // Check if current user is eligible to view button
                //Condition to check if Enable Lead gen is true
                if(partner.PMP_Is_Enabled_Lead_Gen_Nm__c == PMP_StaticConstants_Partner.TRUE_STRING || partner.PMP_Is_Enabled_Lead_Gen_Nm__c == null){
                    //Condition to check if Limit Lead Gen is False
                    if(partner.PMP_Is_Lead_Gen_Limited_Nm__c == PMP_StaticConstants_Partner.FALSE_STRING || partner.PMP_Is_Lead_Gen_Limited_Nm__c == null){  
                        if(partnerSamePartnerBooleanMap.containsKey(partner.id)){        
                            //Checking if the current user is not of same partner
                            if(!partnerSamePartnerBooleanMap.get(partner.id)){
                                contactVisMap.put(partner.Id, true); // If all conditions match set visibility boolean as true
                            }else{
                                contactVisMap.put(partner.Id, false);// if a condition doesn't match set visibility boolean as false
                            } 
                        }
                    }else{ // If Limit Lead gen is True --- contact partner button will be limited to partner users only
                        if(!PMP_SearchUtilityController.isGuest() && partnerSamePartnerBooleanMap.containsKey(partner.id)){ // checking if the current user is not a guest
                                if(!partnerSamePartnerBooleanMap.get(partner.id)){ 
                                    contactVisMap.put(partner.Id, true); // If all conditions match set visibility boolean as true
                                }else{
                                    contactVisMap.put(partner.Id, false);// if a condition doesn't match set visibility boolean as false
                                } 
                        }                     
                        else{
                                   contactVisMap.put(partner.Id, false);// if a condition doesn't match set visibility boolean as false                            
                        }
                    }
                }else{ // If Enable Lead Gen is false set visibility boolean as false
                    contactVisMap.put(partner.Id, false);
                }
            }else{ // If current user is not eligible set visibility boolean as false
                contactVisMap.put(partner.Id, false);
            }            
        } 
       return  contactVisMap; // Return contact button visibility map
    }

 
    
    /** 
    * @description : to check if for the current user contact partner button is visible
    * @developer : Prabuddh
    * @return a Boolean 
    * Method Parameters - sObject (offering | partner)
    * "Used for Detail pages"
    */
    public static Boolean isContactButtonVisible(sObject record){
        
        Boolean result = false;
        Map<String, Boolean> isSamePartnerMap = new Map<String, Boolean>();
        List<String> accountIds = new List<String>();
         Boolean isCurrentUserEligible;
        if(Test.isRunningTest()){
            
          isCurrentUserEligible  =true;
        }else{
            isCurrentUserEligible = PMP_Utility.showContactPartnerButton();
            
        }
        
        Boolean isPartnerRecord = false;
        Boolean isSamePartner = false;
        PMP_Company__c partner = new PMP_Company__c();
        PMP_Partner_Offering__c offering = new PMP_Partner_Offering__c();
        if(record.getSObjectType() == PMP_Company__c.sObjectType){
            isPartnerRecord = true;
            partner = (PMP_Company__c)record;  
        }else if(record.getSObjectType() == PMP_Partner_Offering__c.sObjectType){
            isPartnerRecord = false;
            offering = (PMP_Partner_Offering__c)record;
        }
        
        //Added as a part of OPID Restructure
        List<PMP_OPID_MPI_Rel__c> junctionObjects = new List<PMP_OPID_MPI_Rel__c>();
        Map<Id,Set<Id>> mapOfMpiToListAccountActive = new Map<Id,Set<Id>>();
        //

        if(isPartnerRecord){                      
            //Modified as a part of OPID Restructure
            Set<Id> partnerId = new Set<Id>{partner.Id};
            junctionObjects = PMP_Utility.getJunctionAccountToMpiByCompanyId(partnerId);
            mapOfMpiToListAccountActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjects);
            if(mapOfMpiToListAccountActive.containsKey(partner.Id)){
            for(Id acc : mapOfMpiToListAccountActive.get(partner.Id)){
                accountIds.add(acc);
            }
            }
        }else{   
            //Modified as a part of OPID Restructure
            Set<Id> partnerId = new Set<Id>{offering.PMP_Company_Id__r.Id};
            junctionObjects = PMP_Utility.getJunctionAccountToMpiByCompanyId(partnerId);
            mapOfMpiToListAccountActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjects);
            if(mapOfMpiToListAccountActive.containsKey(offering.PMP_Company_Id__r.Id)){
            for(Id acc : mapOfMpiToListAccountActive.get(offering.PMP_Company_Id__r.Id)){
                accountIds.add(acc);
            }
           }       
        }
        //OPTIMISATION WW44
        User currentUser = returnCurrentUser();
        // isSamePartnerMap = PMP_SearchUtilityController.isSamePartnerUser(accountIds);
            //isSamePartner=PMP_SearchUtilityController.isSamePartnerUserMethod(accountIds);

        for(String accId : accountIds){
            isSamePartnerMap.put(accId,currentUser.Core_IPA_One_Partner_Id__c == accId);
        }
        
        isSamePartner =accountIds.contains(currentUser.Core_IPA_One_Partner_Id__c);
        
        if(isCurrentUserEligible){
            if(isPartnerRecord){
                if(partner.PMP_Is_Enabled_Lead_Gen_Nm__c == PMP_StaticConstants_Partner.TRUE_STRING || partner.PMP_Is_Enabled_Lead_Gen_Nm__c == null){
                    if(partner.PMP_Is_Lead_Gen_Limited_Nm__c == PMP_StaticConstants_Partner.FALSE_STRING || partner.PMP_Is_Lead_Gen_Limited_Nm__c == null){
                        //Modified as a part of OPID Restructure
                        if(mapOfMpiToListAccountActive.containsKey(partner.Id)){
                        for(Id acc : mapOfMpiToListAccountActive.get(partner.Id)){
                            if(isSamePartnerMap.containsKey(acc)){
                                if(!isSamePartner){
                                   result = true;
                                }else{
                                   result = false;
                                }
                            }
                        }
                        }
                        /*if(isSamePartnerMap.containsKey(partner.PMP_Account_Id__c)){
                            if(!isSamePartnerMap.get(partner.PMP_Account_Id__c)){
                               result = true;
                            }else{
                               result = false;
                            }
                        }*/
                    }else{
                        if(!PMP_SearchUtilityController.isGuest() && mapOfMpiToListAccountActive.containsKey(partner.Id)){
                        //Modified as a part of OPID Restructure
                        for(Id acc : mapOfMpiToListAccountActive.get(partner.Id)){
                            if(isSamePartnerMap.containsKey(acc)){
                                if(!isSamePartner){
                                   result = true;
                                }else{
                                   result = false;
                                }
                            }
                        }
                            /*if(isSamePartnerMap.containsKey(partner.PMP_Account_Id__c)){
                                if(!isSamePartnerMap.get(partner.PMP_Account_Id__c)){
                                   result = true;
                                }else{
                                   result = false;
                                }
                            }*/
                        }
                    }
                }else{
                    result = false;
                }
            }else{
                //offering record
                if(offering.PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c == PMP_StaticConstants_Partner.TRUE_STRING || offering.PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c == null){
                    if(offering.PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c == PMP_StaticConstants_Partner.FALSE_STRING || offering.PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c == null){
                        //Modified as a part of OPID Restructure
                        if(mapOfMpiToListAccountActive.containsKey(offering.PMP_Company_Id__r.Id)){
                        for(Id acc : mapOfMpiToListAccountActive.get(offering.PMP_Company_Id__r.Id)){
                            if(isSamePartnerMap.containsKey(acc)){
                                if(!isSamePartner){
                                   result = true;
                                }else{
                                   result = false;
                                }
                            }
                        }
                       }
                        /*if(isSamePartnerMap.containsKey(offering.PMP_Company_Id__r.PMP_Account_Id__c)){
                            if(!isSamePartnerMap.get(offering.PMP_Company_Id__r.PMP_Account_Id__c)){
                               result = true;
                            }else{
                               result = false;
                            }
                        }*/
                    }else{
                        if(!PMP_SearchUtilityController.isGuest() && mapOfMpiToListAccountActive.containsKey(offering.PMP_Company_Id__r.Id)){
                            //Modified as a part of OPID Restructure
                            for(Id acc : mapOfMpiToListAccountActive.get(offering.PMP_Company_Id__r.Id)){
                                if(isSamePartnerMap.containsKey(acc)){
                                    if(!isSamePartner){
                                       result = true;
                                    }else{
                                       result = false;
                                    }
                                }
                            }
                            /*if(isSamePartnerMap.containsKey(offering.PMP_Company_Id__r.PMP_Account_Id__c)){
                                if(!isSamePartnerMap.get(offering.PMP_Company_Id__r.PMP_Account_Id__c)){
                                   result = true;
                                }else{
                                   result = false;
                                }
                            }*/
                        }
                    }
                }else{
                    result = false;
                }
            }
        }else{
            result = false;
        }
        return result;
    } 
    
    /** 
* @description : To get Category Options Available
* @developer : Nikhil
* @return a List<Option> 
* Method Parameters - PIM Id of desired Category and Level 
*/
    public static List<Option> getCategoryTree(String pimId, Boolean all, String langCode){
        String ansPimId = pimId + '%';
        List<Option> ret  = new List<Option>();
       // Order by added in the query to sort categories based on sequence Number US705467/US705466.
        List<PMP_Category__c> productCategories = new List<PMP_Category__c>();
       if(Test.isRunningTest()){
        if(Schema.sObjectType.PMP_Category__c.isAccessible()){

           productCategories = [SELECT Id, Name,PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Parent_Category_Cd__c,
                                                   PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c, PMP_Parent_Category_Id__c,
                                                   PMP_Category_Display_Sequence_Nbr__c
                                                   FROM PMP_Category__c 
                                                   WHERE PMP_Active_Ind__c = true];
        }
           
       }
        else{
            if(Schema.sObjectType.PMP_Category__c.isAccessible()){
            productCategories = [SELECT Id, Name,PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Parent_Category_Cd__c,
                                                   PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c, PMP_Parent_Category_Id__c,
                                                   PMP_Category_Display_Sequence_Nbr__c
                                                   FROM PMP_Category__c 
                                                   WHERE PMP_Active_Ind__c = true and PMP_Ancestor_Category_Cd__c like :ansPimId
                                                      Order By PMP_Category_Display_Sequence_Nbr__c ];
        }
        }
        
        Map<string,Option> catMap = new Map<String,Option>();
        for(PMP_Category__c cat : productCategories) {
            if(!catMap.containsKey(cat.Id) && cat.PMP_Partner_Product_Parent_Category_Cd__c == pimId){
                Option opt = new Option();
                opt.label = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                
                opt.value = cat.Id;
                opt.children = new List<Option>();
                
                catMap.put(cat.id,opt);
                
                ret.add(opt);
            }
        }
        if(all){
            for(PMP_Category__c cat : productCategories) {    
                if (catMap.containsKey(cat.PMP_Parent_Category_Id__c) && !catMap.containsKey(cat.Id)){
                    Option opt = new Option();
                    opt.label = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                    
                    opt.value = cat.Id;
                    opt.children = new List<Option>();
                    
                    catMap.put(cat.id,opt);
                    catMap.get(cat.PMP_Parent_Category_Id__c).children.add(opt);
                }        
            }
        }
        return ret;
    }
    
    /** 
* @description : To get the logged in User's locale
* @developer : Prabuddh
* @return : String (user Language code) 
* Method Parameters - none 
*/    
    public static String getUserLocale(){
        
        String languageCode = '';
        
        if(UserInfo.getLanguage()!=null){
            if(PMP_StaticConstants_Partner.languagesSupported.contains(UserInfo.getLanguage())){
                languageCode = UserInfo.getLanguage();
            }else{
                languageCode = PMP_StaticConstants_Partner.EN_US;
            } 
            
        }
        return languageCode;
    }
    
    /** 
* @description : To get Localised Name value based on User Locale
* @developer : Nikhil, Prabuddh
* @return : String(Name)
* Method Parameters - Object( Specification or Category), String(filedName), String(lang code) 
*/
    
    public static String getLocalisedName(sObject obj, String fieldName, String languageCode){
        String name = '';
        //string truncateName = '';
        String userLanguage = languageCode;
        if(languageCode == 'en-US'){
            userLanguage = 'en_US';
        }else if(languageCode == 'zh-Hans-CN' || languageCode == 'zh-CN' || languageCode == 'zh_Hans_CN'){ // languageCode == 'zh_Hans_CN : Added as part of new L3 storefront page
            userLanguage = 'zh_CN';
        }
        //UserInfo.getLanguage();
        try{
            //Category Object
            if(obj.getSObjectType() == PMP_Category__c.sObjectType){
                PMP_Category__c cat = (PMP_Category__c)obj;
                if(fieldName == PMP_StaticConstants_Partner.CAT_NAME_FIELD){
                    if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && cat.PMP_Category_Chinese_Nm__c != null){
                        name = cat.PMP_Category_Chinese_Nm__c;
                    }
                    else if (userLanguage == PMP_StaticConstants_Partner.JA && cat.PMP_Category_Japanese_Nm__c != null){
                        name = cat.PMP_Category_Japanese_Nm__c;
                    }
                    else{
                        name = cat.Name;
                    }         
                }else if(fieldName == PMP_StaticConstants_Partner.CAT_DESC_FIELD){
                    if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && cat.PMP_Category_Chinese_Dsc__c != null){
                        name = cat.PMP_Category_Chinese_Dsc__c;
                    }
                    else if (userLanguage == PMP_StaticConstants_Partner.JA && cat.PMP_Category_Japanese_Dsc__c != null){
                        name = cat.PMP_Category_Japanese_Dsc__c;
                    }
                    else{
                        if(cat.PMP_Partner_Offering_Category_Dsc__c!=null){
                            name = cat.PMP_Partner_Offering_Category_Dsc__c;
                        }else{
                            name ='';
                        }
                        
                    }
                }
                   
            }
          
            //Partner Offering Category Object
            if(obj.getSObjectType() == PMP_Partner_Offering_Category__c.sObjectType){
                PMP_Partner_Offering_Category__c offCat = (PMP_Partner_Offering_Category__c)obj;
                if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && offCat.PMP_Category_Id__r.PMP_Category_Chinese_Nm__c != null){
                    name = offCat.PMP_Category_Id__r.PMP_Category_Chinese_Nm__c;
                }
                else if (userLanguage == PMP_StaticConstants_Partner.JA && offCat.PMP_Category_Id__r.PMP_Category_Japanese_Nm__c != null){
                    name = offCat.PMP_Category_Id__r.PMP_Category_Japanese_Nm__c;
                   
                }
                else{
                    name = offCat.PMP_Category_Id__r.Name;
                }            
            }
            //Partner Category Object
            if(obj.getSObjectType() == PMP_Partner_Category__c.sObjectType){
                PMP_Partner_Category__c partCat = (PMP_Partner_Category__c)obj;
                if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && partCat.PMP_Category_Id__r.PMP_Category_Chinese_Nm__c != null){
                    name = partCat.PMP_Category_Id__r.PMP_Category_Chinese_Nm__c;
                }
                else if (userLanguage == PMP_StaticConstants_Partner.JA && partCat.PMP_Category_Id__r.PMP_Category_Japanese_Nm__c != null){
                    name = partCat.PMP_Category_Id__r.PMP_Category_Japanese_Nm__c;
                }
                else{
                    name = partCat.PMP_Category_Id__r.Name;
                }            
            }
            //Specification Object
            if(obj.getSObjectType() == PMP_Specification__c.sObjectType){
                
                PMP_Specification__c spec = (PMP_Specification__c)obj;
                if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && spec.PMP_Specification_Chinese_Nm__c != null){
                    name = spec.PMP_Specification_Chinese_Nm__c;
                }
                
                else if (userLanguage == PMP_StaticConstants_Partner.JA && spec.PMP_Specification_Japanese_Nm__c != null){
                    name = spec.PMP_Specification_Japanese_Nm__c;
                }
                else{
                    name = spec.Name;
                }            
            }

            //Specification value Object /*added by krishna ch as part of country changes for store front.
            if(obj.getSObjectType() == PMP_Specification_Value__c.sObjectType){
                
                PMP_Specification_Value__c specVal = (PMP_Specification_Value__c)obj;
                if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && specVal.PMP_Name_Chinese__c != null){
                    name = specVal.PMP_Name_Chinese__c;
                }
                else if (userLanguage == PMP_StaticConstants_Partner.JA && specVal.PMP_Name_Japanese__c != null){
                    name = specVal.PMP_Name_Japanese__c;
                }
                else{
                    name = specVal.Name;
                }            
            }
            
            //End

            //Offering Specification Object
            if(obj.getSObjectType() == PMP_Partner_Offering_Specification__c.sObjectType){
                PMP_Partner_Offering_Specification__c offSpec = (PMP_Partner_Offering_Specification__c)obj;
                if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && offSpec.PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c != null){
                    name = offSpec.PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
                }
                else if (userLanguage == PMP_StaticConstants_Partner.JA && offSpec.PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c != null){
                    name = offSpec.PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c;
                }
                else{
                    name = offSpec.PMP_Specification_Id__r.Name;
                }            
            }
            //Marketplace Profile Region(Partner Specificaton Junction) Object
            if(obj.getSObjectType() == PMP_Company_Region__c.sObjectType){
                PMP_Company_Region__c companyReg = (PMP_Company_Region__c)obj;
                if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && companyReg.PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c != null){
                    name = companyReg.PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
                }
                else if (userLanguage == PMP_StaticConstants_Partner.JA && companyReg.PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c != null){
                    name = companyReg.PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c;
                }
                else{
                    name = companyReg.PMP_Specification_Id__r.Name;
                }            
            }
            //Category Spec AscObject
            if(obj.getSObjectType() == PMP_Category_Specification_Association__c.sObjectType){
                PMP_Category_Specification_Association__c catSpecAsc = (PMP_Category_Specification_Association__c)obj;
                if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && catSpecAsc.PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c != null){
                    name = catSpecAsc.PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
                }
                else if (userLanguage == PMP_StaticConstants_Partner.JA && catSpecAsc.PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c != null){
                    name = catSpecAsc.PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c;
                }
                else{
                    name = catSpecAsc.PMP_Specification_Id__r.Name;
                }            
            }
            //Spec Value Asc Object
            if(obj.getSObjectType() == PMP_Specification_Value_Association__c.sObjectType){
                PMP_Specification_Value_Association__c specValAsc = (PMP_Specification_Value_Association__c)obj;
                if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && specValAsc.PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c != null){
                    name = specValAsc.PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c;
                }
                else if (userLanguage == PMP_StaticConstants_Partner.JA && specValAsc.PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c != null){
                    name = specValAsc.PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c;
                }
                else{
                    name = specValAsc.PMP_Specification_Value_Id__r.Name;
                }            
            }
            //Partner Offering Translation
            if(obj.getSObjectType() == PMP_Partner_Offering_Translation__c.sObjectType){
                PMP_Partner_Offering_Translation__c trans = (PMP_Partner_Offering_Translation__c)obj;
                if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && String.isNotEmpty(trans.PMP_Chinese_Txt__c)){
                    name = trans.PMP_Chinese_Txt__c.replaceAll('<[/a-zAZ0-9]*>', '');
                }
                else if (userLanguage == PMP_StaticConstants_Partner.JA && String.isNotEmpty(trans.PMP_Japanese_Txt__c)){
                    name = trans.PMP_Japanese_Txt__c.replaceAll('<[/a-zAZ0-9]*>', '');
                }
                else if(String.isNotEmpty(trans.PMP_English_Txt__c)){
                    name = trans.PMP_English_Txt__c.replaceAll('<[/a-zAZ0-9]*>', '');
                }            
            }
            //Partner Translation
            //TranslationEOL
            /*
            if(obj.getSObjectType() == PMP_Company_Translation__c.sObjectType){
                PMP_Company_Translation__c trans = (PMP_Company_Translation__c)obj;
                if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && String.isNotEmpty(trans.PMP_Chinese_Txt__c)){
                    name = trans.PMP_Chinese_Txt__c.replaceAll('<[/a-zAZ0-9]*>', '');
                }
                else if (userLanguage == PMP_StaticConstants_Partner.JA && String.isNotEmpty(trans.PMP_Japanese_Txt__c)){
                    name = trans.PMP_Japanese_Txt__c.replaceAll('<[/a-zAZ0-9]*>', '');
                }
                else if(String.isNotEmpty(trans.PMP_English_Txt__c)){
                    name = trans.PMP_English_Txt__c.replaceAll('<[/a-zAZ0-9]*>', '');
                }            
            }*/
            
            //Partner Segment
            if(obj.getSObjectType() == PMP_Partner_Segment__c.sObjectType){
                if(fieldName == PMP_StaticConstants_Partner.CAT_NAME_FIELD){
                	PMP_Partner_Segment__c segmentName = (PMP_Partner_Segment__c)obj;
                	if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && segmentName.PMP_Partner_Segment_Chinese_Name_Txt__c != null){
                    	name = segmentName.PMP_Partner_Segment_Chinese_Name_Txt__c;
                	}
                	else if (userLanguage == PMP_StaticConstants_Partner.JA && segmentName.PMP_Partner_Segment_Japanese_Name_Txt__c != null){
                    	name = segmentName.PMP_Partner_Segment_Japanese_Name_Txt__c;
                	}
                	else{
                    	name = segmentName.PMP_Partner_Segment_Value_Txt__c;
                	}            
                }
                else if(fieldName == PMP_StaticConstants_Partner.CAT_DESC_FIELD){
                    PMP_Partner_Segment__c segmentDesc = (PMP_Partner_Segment__c)obj;
                	if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && segmentDesc.PMP_Partner_Segment_Chinese_Dsc_Txt__c != null){
                    	name = segmentDesc.PMP_Partner_Segment_Chinese_Dsc_Txt__c;
                	}
                	else if (userLanguage == PMP_StaticConstants_Partner.JA && segmentDesc.PMP_Partner_Segment_Japanese_Dsc_Txt__c != null){
                    	name = segmentDesc.PMP_Partner_Segment_Japanese_Dsc_Txt__c;
                	}
                	else{
                    	name = segmentDesc.PMP_Partner_Segment_English_Dsc_Txt__c;
                	}            
                }
            }
            
            //Partner Role
            if(obj.getSObjectType() == PMP_Partner_Program__c.sObjectType){
                if(fieldName == PMP_StaticConstants_Partner.CAT_NAME_FIELD){
                	PMP_Partner_Program__c roleName = (PMP_Partner_Program__c)obj;
                	if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && roleName.PMP_Partner_Program_Name_Chinese__c != null){
                    	name = roleName.PMP_Partner_Program_Name_Chinese__c;
                	}
                	else if (userLanguage == PMP_StaticConstants_Partner.JA && roleName.PMP_Partner_Program_Name_Japanese__c != null){
                    	name = roleName.PMP_Partner_Program_Name_Japanese__c;
                	}
                	else{
                    	name = roleName.PMP_Partner_Program_Value_Txt__c;
                	}            
                }
                else if(fieldName == PMP_StaticConstants_Partner.CAT_DESC_FIELD){
                    PMP_Partner_Program__c roleDesc = (PMP_Partner_Program__c)obj;
                	if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && roleDesc.PMP_Partner_Program_Desc_Chinese__c != null){
                    	name = roleDesc.PMP_Partner_Program_Desc_Chinese__c;
                	}
                	else if (userLanguage == PMP_StaticConstants_Partner.JA && roleDesc.PMP_Partner_Program_Desc_Japanese__c != null){
                    	name = roleDesc.PMP_Partner_Program_Desc_Japanese__c;
                	}
                	else{
                    	name = roleDesc.PMP_Partner_Program_Desc__c !=NULL? roleDesc.PMP_Partner_Program_Desc__c : '';
                	}            
                }
            }
            
            //Biz org values
            if(obj.getSObjectType() == PMP_Partner_Tier__c.sObjectType){
                if(fieldName == PMP_StaticConstants_Partner.CAT_NAME_FIELD){
                	PMP_Partner_Tier__c bizOrg = (PMP_Partner_Tier__c)obj;
                	if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && bizOrg.PMP_Partner_Tier_Chinese_Nm__c != null){
                    	name = bizOrg.PMP_Partner_Tier_Chinese_Nm__c;
                	}
                	else if (userLanguage == PMP_StaticConstants_Partner.JA && bizOrg.PMP_Partner_Tier_Name_Japanese__c  != null){
                    	name = bizOrg.PMP_Partner_Tier_Name_Japanese__c ;
                	}
                	else{
                    	name =bizOrg.Name;
                	}            
                }
            }
            
            
            
        }catch(Exception e){
            throw e;//error handling
            
        }
       // return name;
        // truncate the name whose char length is more than 80 char
      /*   if(name.Length()>=80)
           truncateName = name.substring(0, 80);
         else 
           truncateName = name; */ // Not needed, redundant
        
         
        return name;
    }
    
    
/** 
* @description : To get Language Message on Lead Form
* @developer : Prabuddh
* @return : String(Message)
* Method Parameters - List of Language preferences 
*/
    public static String getLanguageMessage(List<Options> languagePrefs){
        
        String defaultLabel = System.Label.PMP_Language_Preferrence;
        String finalLabel = '';
        
        List<String> langSelected = new List<String>();
        
        if(languagePrefs!=null) {       
            for( Options lang : languagePrefs ){
                if(lang.selected == true){
                    langSelected.add(lang.label);
                }
            }
          
            if(langSelected.size() == 3)
                finalLabel = String.format(System.Label.PMP_Contact_Preference3, langSelected);
            else if(langSelected.size() == 2)
                finalLabel = String.format(System.Label.PMP_Contact_Preference2, langSelected);
            else if(langSelected.size() == 1){ 
                finalLabel = String.format(System.Label.PMP_Contact_Preference1, langSelected);
            }else if(langSelected.isEmpty())
                finalLabel = defaultLabel;
        }         
        return finalLabel;
        
    }
    
    public static Boolean isIntelAdmin(){
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        try{
            //if(Schema.sObjectType.PermissionSetAssignment.isAccessible()){ //Uday: commented as the Intel Admins not able to edit storefront.
                permissionSetList = [SELECT Id  FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId() 
                                     AND PermissionSet.Name =: PMP_StaticConstants_Partner.INTEL_ADMIN];
                
            //}
            if(!permissionSetList.isEmpty()){
                return true;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }
    
    /** 
* @description : Method to escape reserved charactor for SOSL
* @developer : Nikhil
* @return : String text
* Method Parameters - Input Text 
*/
    public static String escapeSosl( String text ) {
        Boolean isSingle = false;
        
        if(text.length() == 1){
            isSingle = true;           
        }
        Boolean isSpecialOnly = false;
       final String aplhaNumber = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789';
        if(!text.containsAny(aplhaNumber)){
            isSpecialOnly = true;
        }
        
        // handle single quotes
        String escapedText = String.escapeSingleQuotes( text ) ;
        
        
        if(isSingle){
             escapedText = '\\' + escapedText;
        }else{
            if(isSpecialOnly){
                
                // remove reserved logical operators
                escapedText = escapedText.replaceAll( '(?i)( AND NOT | AND | OR )', ' ' );
                // match special characters to escape
                Pattern myPattern = Pattern.compile( '(\\?|\\/|\\&|\\||\\!|\\{|\\}|\\[|\\]|\\^|\\~|\\:|\\+|\\-|\\(|\\)|\\*|\\")' ); 
                Matcher myMatcher = myPattern.matcher( escapedText );
                escapedText = myMatcher.replaceAll( '\\\\\\\\\\\\\\\\$1' );                
                
            }else{
                // remove reserved logical operators
                escapedText = escapedText.replaceAll( '(?i)( AND NOT | AND | OR )', ' ' );
                // match special characters to escape
                Pattern myPattern = Pattern.compile( '(\\?|\\/|\\&|\\||\\!|\\{|\\}|\\[|\\]|\\^|\\~|\\:|\\+|\\-|\\(|\\)|\\*|\\")' ); 
                Matcher myMatcher = myPattern.matcher( escapedText );
                escapedText = myMatcher.replaceAll( '\\\\$1' );                
                
            }
             // collapse extra whitespace
                escapedText = escapedText.replaceAll( '( )+', ' ' ).trim();
            if(!String.isEmpty(escapedText)){
                escapedText+= '*';
            }   
            
        }
        
        
       
        return escapedText;
    }

    /** 
    * @description : To get MDA Id from Partner's AccountId.
    * @developer : Prabuddh
    * @return : String/Id
    * Method Parameters - accountId 
    */ 
    //Placeholder
    public static String getMdaId(String intelAccountId){
        
        //Since the Intel Account is of the Marketing Profile info, it is already a MDA
       String mdaId = '';
        try{
            //Commented as a part of US628755
            /*Core_Account_Group_Member__c pagMember = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c, Core_MDA_Ind__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c =: intelAccountId]; 
       
            if(pagMember.Core_MDA_Ind__c){
                mdaId = pagMember.Core_Partner_Account_Id__c;
            } */
            //Added as a part of OPID restructure
            if(Schema.sObjectType.PMP_OPID_MPI_Rel__c.isAccessible()){
                PMP_OPID_MPI_Rel__c junctionObjectRec = [select Id,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c,Is_Active__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c =:intelAccountId AND PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published LIMIT 1];
                if(junctionObjectRec!=null){
                    mdaId = junctionObjectRec.PMP_Marketing_Profile_Id__c;
                }
            }

            //Existing Logic
            /*PMP_Company__c partner= new PMP_Company__c();
            if( PMP_Company__c.SObjectType.getDescribe().isAccessible()){

                partner = [SELECT Id,PMP_Account_Id__c from PMP_Company__c
                                    where PMP_Account_Id__c=: intelAccountId AND PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published limit 1];
            }
            if(partner!=null){
                mdaId = partner.Id;
            }*/
            
        }catch(Exception e){
            //system.debug('Error in fetching One Partner ID from Marketing Profile Info record : '+ e.getMessage());
        } 
       
        
       return mdaId; 
    }
    
    //Method to get API name of translation
   //Do not call this method in for loop 
    public static String getFieldApiName(String objectName, String fieldName, String userLanguage){
        String fieldAPI ='';
         String languageCode = userLanguage;
        if(userLanguage == 'en-US'){
            languageCode = 'en_US';
        }else if(userLanguage == 'zh-Hans-CN' || userLanguage == 'zh-CN' || userLanguage == 'zh_Hans_CN'){ // languageCode == 'zh_Hans_CN : Added as part of new L3 storefront page
            languageCode = 'zh_CN';
        }
        try{
            List<PMP_Language_to_Field_API_Mapping__mdt> metadataList= new List<PMP_Language_to_Field_API_Mapping__mdt>();
            /*fieldAPI*/metadataList = [SELECT PMP_Field_APINm__c FROM PMP_Language_to_Field_API_Mapping__mdt 
                        WHERE PMP_Field_Nm__c =:fieldName AND PMP_Language_Cd__c =: languageCode AND PMP_Object_Nm__c =: objectName LIMIT 1];//.PMP_Field_APINm__c;
            if(metadataList.size()>0){ //error handling 
                fieldAPI=metadataList[0].PMP_Field_APINm__c;
            }
            
        }catch(Exception e){
            throw e;//error handling
        }
        return fieldAPI;
    }
    
 /********************************************************************************
 *Method Name: getCompanyInfoType
 *Description: This method will return the type of Company info depending on the
 *             beifit added to it. It can be 'Storefront' or 'Partner'
 *Params : PMP_Company__c 
 *Author : Abhishek   
 */

    public static string getCompanyInfoType(PMP_Company__c company){
        
        List<String> benifitCode = new List<String>();
        //Modified as a part of OPID Restructure
        if(Schema.sObjectType.PMP_OPID_MPI_Rel__c.isAccessible()){
            List<PMP_OPID_MPI_Rel__c> junctionObjectRec = [select Id,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c,Is_Active__c from PMP_OPID_MPI_Rel__c where PMP_Marketing_Profile_Id__c =:company.Id];
            List<Id> accIds = new List<Id>();
            for(PMP_OPID_MPI_Rel__c juncRec : junctionObjectRec){
                accIds.add(juncRec.PMP_One_Partner_ID__c);
            }
            for(PRM_AccountBenefitAssociation__c accBen:[SELECT PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c 
                                                        WHERE PRM_Account_Id__c in: accIds])
            {
                benifitCode.add(accBen.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c);
            }
        }
        //Existing Logic       
        /*for (PRM_AccountBenefitAssociation__c accBen:[SELECT PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c 
                                                              WHERE     PRM_Account_Id__c =:company.PMP_Account_Id__c])
                {
                    benifitCode.add(accBen.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c);
                    
                  
                }
        */       
            if (benifitCode.contains(PMP_StaticConstants_Partner.BENEFIT_ENHANCED_CODE)){
                return 'Storefront';
            }
            else {
                return 'Profile';
            }
    
    }    
    
    
    /**********************************************************************************************************/    
  /*  public class SearchResponse {
        @AuraEnabled public List<Object> results {get; set;} //TBD to change type to cards
        @AuraEnabled public Map<String, Integer> resultCounts {get; set;}
        @AuraEnabled public Integer resultsPerPage {get; set;}
        @AuraEnabled public Integer totalResults {get; set;}
        @AuraEnabled public Integer totalPages {get; set;}
        
        //old design
        
        @AuraEnabled public String keyword { get; set; }
        @AuraEnabled public String category { get; set; }
        @AuraEnabled public String searchType { get; set; }
        @AuraEnabled public String sortField { get; set; }
        @AuraEnabled public String sortDirection { get; set; }
        @AuraEnabled public Integer currentPage { get; set; }
        @AuraEnabled public Integer pageSize { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
        @AuraEnabled public Integer totalProductCount { get; set; }
        @AuraEnabled public Integer totalPartnerCount { get; set; } 
        @AuraEnabled public List<PMP_SearchProductController.Product> productResults { get; set; }
        @AuraEnabled public List<PMP_SearchPartnerController.Partner> partnerResults { get; set; }
        @AuraEnabled public List<Filter> filters { get; set; }
        @AuraEnabled public List<String> suggestions { get; set; }
        @AuraEnabled public String searchHeading { get; set; }
        @AuraEnabled public String categoryDescription { get; set; }
        @AuraEnabled public String learMoreLink { get; set; }   //Added by Megha as part of Specialty learnMoreLink

        @AuraEnabled public Map<String, List<String>> selectedFilters { get; set; }
    }*/
    
    
}