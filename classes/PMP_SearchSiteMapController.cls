public with sharing class PMP_SearchSiteMapController extends PMP_SearchWrapperStore{
    
    public static final String categoryBaseUrl = '/pmp-category/';
    public static final String specialtybaseUrl = '/pmp-partner-specialty/';
    public static final String partnerProgramBaseUrl = '/pmp-partner-program/';
    public static String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();    
  /*  @AuraEnabled(cacheable=true)
    public static List<Category> getAllSiteMapCategories(String langCode){
        
        String userLanguage = langCode;
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
        //
        List<PMP_Category__c> categories = [SELECT Id,PMP_Parent_Category_Id__c, Name,PMP_Partner_Offering_Category_Dsc__c, PMP_Category_Chinese_Dsc__c,    PMP_Category_Japanese_Dsc__c,PMP_Partner_Product_Category_Cd__c,
                                            PMP_Category_Chinese_Nm__c, PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Parent_Category_Cd__c 
                                            FROM PMP_Category__c 
                                            WHERE PMP_Active_Ind__c = true ORDER BY PMP_Category_Display_Sequence_Nbr__c];
        
        
        
            
        for(PMP_Category__c category: categories){
            Category cat = new Category();
            cat.categoryId = category.Id;
            
            cat.categoryName = String.valueOf(category.get(catNameAPI));
            if(String.isEmpty(cat.categoryName)){
                cat.categoryName = category.Name;
            }
            cat.categoryType = PMP_StaticConstants_Partner.product;
            
            cat.children = new List<Category>();
            cat.parentId = category.PMP_Parent_Category_Id__c;
            
            
            if(String.isNotEmpty(learnMoreUrlMap.get(category.PMP_Partner_Product_Category_Cd__c ))){
                cat.categoryCtaLink = learnMoreUrlMap.get(category.PMP_Partner_Product_Category_Cd__c );
            }
                //Adding first level categories in the list
            catMap.put(category.Id,cat);
            
        }
        //To Build Tree structure
        //
        List<Category> returnList = new List<Category>();
        for(Category cat: catMap.values()){
            if(catMap.containsKey(cat.parentId)){
                catMap.get(cat.parentId).children.add(cat);
            }
            if(cat.parentId == null){
                returnList.add(cat);
            }
        }
        
        return returnList;
    }
    @AuraEnabled(cacheable=true)
    public static List<SeoCat> getSiteMapCategories(){
        String ansPimId = PMP_StaticConstants_Partner.PIM_CATEGORY_ID + '%';
        List<PMP_Category__c> categories = [SELECT Id,PMP_Parent_Category_Id__c, Name,PMP_Partner_Product_Category_Cd__c
                                            ,PMP_Partner_Product_Parent_Category_Cd__c, PMP_Ancestor_Category_Cd__c 
                                            FROM PMP_Category__c 
                                            WHERE PMP_Active_Ind__c = true AND PMP_Ancestor_Category_Cd__c !=null
                                            ORDER BY PMP_Category_Display_Sequence_Nbr__c];
        
		List<SeoCat> catList = new List<SeoCat>();        
        for(PMP_Category__c cat : categories){
            SeoCat sCat = new SeoCat();
            sCat.Name = cat.Name;
            sCat.Id = cat.Id;
            sCat.categoryLevel = cat.PMP_Ancestor_Category_Cd__c.split('\\|').size();
            catList.add(sCat);
        }
       return catList; 
    }*/
    
    
    @AuraEnabled(cacheable=true)
    public static Map<String,List<SeoCat>> getAllCategories(){
        
        Map<String, List<SeoCat>> catMap = new Map<String,List<SeoCat>>();
        
        List<PMP_Category__c> categories = [SELECT Id,PMP_Parent_Category_Id__c, Name,PMP_Partner_Product_Category_Cd__c
                                            ,PMP_Partner_Product_Parent_Category_Cd__c, PMP_Ancestor_Category_Cd__c 
                                            FROM PMP_Category__c 
                                            WHERE PMP_Active_Ind__c = true 
                                            ORDER BY PMP_Category_Display_Sequence_Nbr__c];
 		
        for(PMP_Category__c cat : categories){
            if(cat.PMP_Partner_Product_Category_Cd__c == 'TPS_900002'){
                List<SeoCat> sCatList = new List<SeoCat>();
                sCatList.add(getSeoCat(cat,baseCommunityUrl));
                catMap.put('Component', sCatList);
            }else if(cat.PMP_Partner_Product_Category_Cd__c == 'IPA_TYPE_Sys'){
                List<SeoCat> sCatList = new List<SeoCat>();
                sCatList.add(getSeoCat(cat,baseCommunityUrl));
                catMap.put('System', sCatList);
            }else if(cat.PMP_Partner_Product_Category_Cd__c == 'TPS_900003'){
                List<SeoCat> sCatList = new List<SeoCat>();
                sCatList.add(getSeoCat(cat,baseCommunityUrl));
                catMap.put('Software', sCatList);
            }else if(cat.PMP_Partner_Product_Category_Cd__c == 'IPA_TYPE_Ser'){
                List<SeoCat> sCatList = new List<SeoCat>();
                sCatList.add(getSeoCat(cat,baseCommunityUrl));
                catMap.put('Service', sCatList);
            }else if(cat.PMP_Partner_Product_Category_Cd__c == 'IPA_TYPE_Sol'){
                List<SeoCat> sCatList = new List<SeoCat>();
                sCatList.add(getSeoCat(cat,baseCommunityUrl));
                catMap.put('Solution', sCatList);
            }else if(cat.PMP_Partner_Product_Category_Cd__c == 'NPP_01_Industry'){
                List<SeoCat> sCatList = new List<SeoCat>();
                sCatList.add(getSeoCat(cat,baseCommunityUrl));
                catMap.put('Industry', sCatList);
            }else if(cat.PMP_Partner_Product_Category_Cd__c == 'NPP_01_APP'){
                List<SeoCat> sCatList = new List<SeoCat>();
                sCatList.add(getSeoCat(cat,baseCommunityUrl));
                catMap.put('Application', sCatList);
            }
        }
        
        for(PMP_Category__c cat : categories){
            if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|').size() >1 && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[1] == 'TPS_900002'){
                if(catMap.containsKey('Component')){
                   catMap.get('Component').add(getSeoCat(cat,baseCommunityUrl )); 
                }
                
            }else if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|').size() >1 && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[1] == 'IPA_TYPE_Sys'){
                if(catMap.containsKey('System')){
                   catMap.get('System').add(getSeoCat(cat,baseCommunityUrl)); 
                }       
            }else if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|').size() >1 && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[1] == 'TPS_900003'){
                if(catMap.containsKey('Software')){
                   catMap.get('Software').add(getSeoCat(cat,baseCommunityUrl)); 
                }                 
            }else if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|').size() >1 && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[1] == 'IPA_TYPE_Ser'){
                if(catMap.containsKey('Service')){
                   catMap.get('Service').add(getSeoCat(cat,baseCommunityUrl)); 
                } 
            }else if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|').size() >1 && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[1] == 'IPA_TYPE_Sol'){
                if(catMap.containsKey('Solution')){
                   catMap.get('Solution').add(getSeoCat(cat,baseCommunityUrl)); 
                }  
            }else if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[0] == 'NPP_01_Industry'){
                if(catMap.containsKey('Industry')){
                   catMap.get('Industry').add(getSeoCat(cat,baseCommunityUrl)); 
                }   
            }else if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[0] == 'NPP_01_APP'){
                if(catMap.containsKey('Application')){
                  catMap.get('Application').add(getSeoCat(cat,baseCommunityUrl));  
                }  
            }
        }
        
        
        
 		return getAllSpecialtyAndPartnerProgram(catMap);
    }
    
    public static Map<String,List<SeoCat>> getAllSpecialtyAndPartnerProgram(Map<String,List<SeoCat>> masterMap){
        
        List<PMP_Partner_Specialty__c> specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c where Name!=:PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program AND PMP_Is_Active_Ind__c = TRUE];
        List<SeoCat> specList = new List<SeoCat>();
        SeoCat specialty = new SeoCat();
        specialty.Name = 'Specialty';
        specList.add(specialty);
        for(PMP_Partner_Specialty__c spec : specialtyList){
            SeoCat sCat = new SeoCat();
            sCat.Id = spec.Id;
            sCat.objectAPiName = 'PMP_Partner_Specialty__c';
            sCat.Name = spec.Name;
            sCat.url = baseCommunityUrl + specialtybaseUrl + spec.Id;
            specList.add(sCat);
        }
        masterMap.put('Specialty', specList);
        
        List<PMP_Partner_Program__c> seoPpList =[SELECT id,Name,PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE];
        List<SeoCat> ppList = new List<SeoCat>();
        SeoCat pp = new SeoCat();
        pp.Name = 'Partner Program';
        ppList.add(pp);
        for(PMP_Partner_Program__c pProg : seoPpList){
            SeoCat sCat = new SeoCat();
            sCat.Id = pProg.Id;
            sCat.objectApiName = 'PMP_Partner_Program__c';
            sCat.Name = pProg.Name;
            sCat.url = baseCommunityUrl + partnerProgramBaseUrl + pProg.Id;
           if(pProg.PMP_Partner_Program_Value_Txt__c == 'ODM-LOEM'){
                sCat.Name = PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program;
            }
            ppList.add(sCat);
        }
        masterMap.put('Partner Program', ppList);
        return masterMap;
    }
    
    private static SeoCat getSeoCat(PMP_Category__c cat, String baseUrl){
        SeoCat sCat = new SeoCat();
        sCat.Id = cat.Id;
        sCat.objectApiName = 'PMP_Category__c';
        sCat.Name = cat.Name;
        sCat.url = baseUrl + categoryBaseUrl + cat.Id;
        if(cat.PMP_Ancestor_Category_Cd__c!= null)
        	sCat.categoryLevel = cat.PMP_Ancestor_Category_Cd__c.split('\\|').size();
        else
            sCat.categoryLevel = 0;
        if(cat.PMP_Partner_Product_Category_Cd__c == 'NPP_01_Industry' || cat.PMP_Partner_Product_Category_Cd__c == 'NPP_01_APP'){
            sCat.categoryLevel+=1;
            sCat.url = '';
        }
            
            
        if(cat.PMP_Ancestor_Category_Cd__c!=null){
           if(cat.PMP_Ancestor_Category_Cd__c.split('\\|')[0] == 'NPP_01_Industry' || cat.PMP_Ancestor_Category_Cd__c.split('\\|')[0] == 'NPP_01_APP')
           sCat.categoryLevel+=1;  
        }
        
        return sCat;
    }
    
     
    
}