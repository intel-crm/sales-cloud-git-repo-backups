/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchUtilityController
* Description : Contains the common classes used throught the Marketplace Search.
* Version     : 1.0 
* Created Date: 07-May-2019
* Modification Log :
* Created By  : Tanzanite Team (Infosys)
********************************************************************************************************************************************************************************************************/

public with sharing class PMP_SearchUtilityController extends PMP_SearchWrapperStore { 
    
    //Method to get category tree and count based on search text//
    @AuraEnabled(cacheable=true)
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
        
        offerings = PMP_SearchProductController.getOfferingIds(request.keyword); //Give you the Offering based on keyowrd, If keyword is null it will give you all offerings 
               
        partners = PMP_SearchPartnerController.getPartnerList(request.keyword);//Give you the Partner based on keyowrd, If keyword is null it will give you all partners
        
      
          
        
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
         
        List<PMP_SearchPartnerProgram_Config__mdt> ppList = new List<PMP_SearchPartnerProgram_Config__mdt>();
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
        
        
         
       
        return JSON.serialize(response);
    }
    
    /***********************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
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
        List<String> offerings = PMP_SearchProductController.getOfferingIds(request.keyword);
        
        //Getting partners using keyword
        List<String> partners = PMP_SearchPartnerController.getPartnerList(request.keyword);
        
        
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
            }   

            
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
    @AuraEnabled(cacheable=true)
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
        
            PartnerIDSet = PMP_SearchPartnerController.getPartnerList(query);
        }
        if(PartnerIDSet != null && PartnerIDSet.size() > 0) {
            
            if(Schema.sObjectType.PMP_Company__c.isAccessible()) {
                
                Integer recLimit = searchType == PMP_StaticConstants_Partner.all ? Integer.valueOf(Label.PMP_Search_Suggestion_Count) : 6;
                
                for(PMP_Company__c ptnr : [SELECT Name FROM PMP_Company__c WHERE Id IN : PartnerIDSet ORDER BY Name ASC LIMIT :recLimit]) {
                    
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
        List<String> offerings = PMP_SearchProductController.getOfferingIds(query);
        
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
    }
    
    /**********************************************************************************************************/
    
    
    /** 
* @description : to check if the current user belongs to the same partner 
* @developer : Prabuddh
* @return a Map<String, Boolean> 
* Method Parameters - List of account Ids
*/
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> isSamePartnerUser(List<String> accountIds){
        Map<String, Boolean> isSamePartnerMap = new Map<String, Boolean>();
        List<Core_Account_Group_Member__c> accountGroupMem = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c userAccountGroupMem;
        
        User currentUser = [Select id, AccountId from User where Id =: UserInfo.getUserId()]; //Fetching the AccountId related to current user
        
        for(String accId : accountIds){
            isSamePartnerMap.put(accId, false);
        }
        
        if(currentUser.AccountId != null){ // If the Account has AccountId field (filtering sys admins and guest users)
            try{
                accountGroupMem = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c
                                  where Core_Intel_Account_Id__c in:accountIds limit 1]; // Getting the PAG records for the accountIds param
                userAccountGroupMem = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c
                                      where Core_Intel_Account_Id__c=:currentUser.AccountId limit 1]; // Getting the PAG record for the User's accountId
            }catch(Exception e){
                system.debug('Error in fetching PAG records : ' + e.getMessage());
            }
            
            if(userAccountGroupMem!=null && !accountGroupMem.isEmpty()){ // If PAG records are fetched succesfully
                for(Core_Account_Group_Member__c pag : accountGroupMem){ // Iterate over the PAG records found for the accountIds Param
                    if(pag.Core_Partner_Account_Id__c == userAccountGroupMem.Core_Partner_Account_Id__c){ // if partnerAccountId for the param and user matches
                        isSamePartnerMap.put(pag.Core_Intel_Account_Id__c, true); // Mark True againt the param accountId
                    }else{
                        isSamePartnerMap.put(pag.Core_Intel_Account_Id__c, false); // mark False against the param accountId
                    }
                }
            }
            
        }
        
       return isSamePartnerMap; // Return the Map
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
    @AuraEnabled(cacheable = true)
    public static Map<String, Boolean> isContactPartnerVisible(List<PMP_Company__c> partners){
        Map<String, Boolean> contactVisMap = new Map<String,Boolean>();
        Map<String, Boolean> isSamePartnerMap = new Map<String, Boolean>();
        List<String> accountIds = new List<String>();
        
        for(PMP_Company__c partner : partners){
            accountIds.add(partner.PMP_Account_Id__c);  // getting all accountIds related to the partners       
        }
        
        isSamePartnerMap = PMP_SearchUtilityController.isSamePartnerUser(accountIds); // Checking if the current user belongs to which partner              
        
        Boolean isCurrentUserEligible = PMP_Utility.showContactPartnerButton(); // Checking if the currentUser is eligible to view the button
        
        for(PMP_Company__c partner : partners){ //iterating over the partners
            
            if(isCurrentUserEligible){ // Check if current user is eligible to view button
                //Condition to check if Enable Lead gen is true
                if(partner.PMP_Is_Enabled_Lead_Gen_Nm__c == PMP_StaticConstants_Partner.TRUE_STRING || partner.PMP_Is_Enabled_Lead_Gen_Nm__c == null){
                    //Condition to check if Limit Lead Gen is False
                    if(partner.PMP_Is_Lead_Gen_Limited_Nm__c == PMP_StaticConstants_Partner.FALSE_STRING || partner.PMP_Is_Lead_Gen_Limited_Nm__c == null){
                        //Conditional check if the Map contains the key
                        if(isSamePartnerMap.containsKey(partner.PMP_Account_Id__c)){
                            //Checking if the current user is not of same partner
                            if(!isSamePartnerMap.get(partner.PMP_Account_Id__c)){
                                contactVisMap.put(partner.Id, true); // If all conditions match set visibility boolean as true
                            }else{
                                contactVisMap.put(partner.Id, false);// if a condition doesn't match set visibility boolean as false
                            }
                        }
                    }else{ // If Limit Lead gen is True --- contact partner button will be limited to partner users only
                        if(!PMP_SearchUtilityController.isGuest()){ // checking if the current user is not a guest
                            //Conditional check if the Map contains the key
                            if(isSamePartnerMap.containsKey(partner.PMP_Account_Id__c)){
                                //Checking if the current user is not of same partner
                                if(!isSamePartnerMap.get(partner.PMP_Account_Id__c)){
                                    contactVisMap.put(partner.Id, true);// If all conditions match set visibility boolean as true
                                }else{
                                    contactVisMap.put(partner.Id, false);// if a condition doesn't match set visibility boolean as false
                                }
                            }
                        }
                    }
                }else{ // If Enable Lead Gen is false set visibility boolean as false
                    contactVisMap.put(partner.Id, false);
                }
            }else{ // If current user is not eligible set visibility boolean as false
                contactVisMap.put(partner.Id, false);
            }            
        } 
        system.debug('====>contactVisMap : '+ contactVisMap);
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
        Boolean isCurrentUserEligible = PMP_Utility.showContactPartnerButton();
        
        Boolean isPartnerRecord = false;
        PMP_Company__c partner = new PMP_Company__c();
        PMP_Partner_Offering__c offering = new PMP_Partner_Offering__c();
        if(record.getSObjectType() == PMP_Company__c.sObjectType){
            isPartnerRecord = true;
            partner = (PMP_Company__c)record;  
        }else if(record.getSObjectType() == PMP_Partner_Offering__c.sObjectType){
            isPartnerRecord = false;
            offering = (PMP_Partner_Offering__c)record;
        }
        
        if(isPartnerRecord){
                      
            accountIds.add(partner.PMP_Account_Id__c);
            isSamePartnerMap = PMP_SearchUtilityController.isSamePartnerUser(accountIds);
        }else{           
            accountIds.add(offering.PMP_Company_Id__r.PMP_Account_Id__c);
            isSamePartnerMap = PMP_SearchUtilityController.isSamePartnerUser(accountIds);
        }
        
        if(isCurrentUserEligible){
            if(isPartnerRecord){
                if(partner.PMP_Is_Enabled_Lead_Gen_Nm__c == PMP_StaticConstants_Partner.TRUE_STRING || partner.PMP_Is_Enabled_Lead_Gen_Nm__c == null){
                    if(partner.PMP_Is_Lead_Gen_Limited_Nm__c == PMP_StaticConstants_Partner.FALSE_STRING || partner.PMP_Is_Lead_Gen_Limited_Nm__c == null){
                        if(isSamePartnerMap.containsKey(partner.PMP_Account_Id__c)){
                            if(!isSamePartnerMap.get(partner.PMP_Account_Id__c)){
                               result = true;
                            }else{
                               result = false;
                            }
                        }
                    }else{
                        if(!PMP_SearchUtilityController.isGuest()){
                            if(isSamePartnerMap.containsKey(partner.PMP_Account_Id__c)){
                                if(!isSamePartnerMap.get(partner.PMP_Account_Id__c)){
                                   result = true;
                                }else{
                                   result = false;
                                }
                            }
                        }
                    }
                }else{
                    result = false;
                }
            }else{
                //offering record
                if(offering.PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c == PMP_StaticConstants_Partner.TRUE_STRING || offering.PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c == null){
                    if(offering.PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c == PMP_StaticConstants_Partner.FALSE_STRING || offering.PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c == null){
                        if(isSamePartnerMap.containsKey(offering.PMP_Company_Id__r.PMP_Account_Id__c)){
                            if(!isSamePartnerMap.get(offering.PMP_Company_Id__r.PMP_Account_Id__c)){
                               result = true;
                            }else{
                               result = false;
                            }
                        }
                    }else{
                        if(!PMP_SearchUtilityController.isGuest()){
                            if(isSamePartnerMap.containsKey(offering.PMP_Company_Id__r.PMP_Account_Id__c)){
                                if(!isSamePartnerMap.get(offering.PMP_Company_Id__r.PMP_Account_Id__c)){
                                   result = true;
                                }else{
                                   result = false;
                                }
                            }
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
        List<PMP_Category__c> productCategories = [SELECT Id, Name,PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Parent_Category_Cd__c,
                                                   PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c, PMP_Parent_Category_Id__c FROM PMP_Category__c 
                                                   WHERE PMP_Active_Ind__c = true and PMP_Ancestor_Category_Cd__c like :ansPimId ORDER BY PMP_Category_Display_Sequence_Nbr__c];
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
        string truncateName = '';
        String userLanguage = languageCode;//UserInfo.getLanguage();
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
            }
        }catch(Exception e){
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
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
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
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
        
        
        system.debug('0'+ escapedText);
        if(isSingle){
             escapedText = '\\' + escapedText;
            system.debug('1'+ escapedText);
        }else{
            if(isSpecialOnly){
                
                // remove reserved logical operators
                escapedText = escapedText.replaceAll( '(?i)( AND NOT | AND | OR )', ' ' );
                system.debug('2'+ escapedText);       
                // match special characters to escape
                Pattern myPattern = Pattern.compile( '(\\?|\\/|\\&|\\||\\!|\\{|\\}|\\[|\\]|\\^|\\~|\\:|\\+|\\-|\\(|\\)|\\*|\\")' ); 
                Matcher myMatcher = myPattern.matcher( escapedText );
                escapedText = myMatcher.replaceAll( '\\\\\\\\\\\\\\\\$1' );                
                
            }else{
                // remove reserved logical operators
                escapedText = escapedText.replaceAll( '(?i)( AND NOT | AND | OR )', ' ' );
                system.debug('3'+ escapedText);       
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
        
        system.debug('3'+ escapedText);
        
       
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
            /*Core_Account_Group_Member__c pagMember = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c, Core_MDA_Ind__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c =: intelAccountId]; 
       
            if(pagMember.Core_MDA_Ind__c){
                system.debug('###Entered getMdaId');
                mdaId = pagMember.Core_Partner_Account_Id__c;
            } */
            
            PMP_Company__c partner = [SELECT Id,PMP_Account_Id__c from PMP_Company__c
                                      where PMP_Account_Id__c=: intelAccountId AND PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published limit 1];
            if(partner!=null){
                mdaId = partner.Id;
            }
            
        }catch(Exception e){
            system.debug('Error in fetching One Partner ID from Marketing Profile Info record : '+ e.getMessage());
        } 
       
        
       return mdaId; 
    }
    
    //Method to get API name of translation
   //Do not call this method in for loop 
    public static String getFieldApiName(String objectName, String fieldName, String userLanguage){
        String fieldAPI ='';
        try{
            system.debug('---fieldName---'+fieldName+ '---userLanguage---'+userLanguage+'----objectName---'+objectName);
            
            fieldAPI = [SELECT PMP_Field_APINm__c FROM PMP_Language_to_Field_API_Mapping__mdt 
                        WHERE PMP_Field_Nm__c =:fieldName AND PMP_Language_Cd__c =: userLanguage AND PMP_Object_Nm__c =: objectName LIMIT 1].PMP_Field_APINm__c;
        }catch(Exception e){
            system.debug('Error while fething PMP_Language_to_Field_API_Mapping__mdt records');
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
         for (PRM_AccountBenefitAssociation__c accBen:[SELECT PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c 
                                                              WHERE     PRM_Account_Id__c =:company.PMP_Account_Id__c])
                {
                    benifitCode.add(accBen.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c);
                    
                  
                }
               
            if (benifitCode.contains(PMP_StaticConstants_Partner.BENEFIT_ENHANCED_CODE)){
                return 'Storefront';
            }
            else {
                return 'Profile';
            }
    
    }    
    
    
    /**********************************************************************************************************/    
    public class SearchResponse {
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
        @AuraEnabled public Map<String, List<String>> selectedFilters { get; set; }
    }
    
    
}