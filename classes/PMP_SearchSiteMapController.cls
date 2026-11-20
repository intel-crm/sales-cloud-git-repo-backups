@isTest
public with sharing class PMP_SearchSiteMapController extends PMP_SearchWrapperStore{
    
    //public static final String categoryBaseUrl = '/pmp-category/';
    //public static final String specialtybaseUrl = '/pmp-partner-specialty/';
    //public static final String partnerProgramBaseUrl = '/pmp-partner-program/';
     //public static final String partnerSegmentBaseUrl = '/partners-by-market-segment/';
    //public static String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();    
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
    
    
    // @AuraEnabled(cacheable=true)
    // public static Map<String,List<SeoCat>> getAllCategories(String langCode){
        
    //     Map<String, List<SeoCat>> catMap = new Map<String,List<SeoCat>>();
    //     List<PMP_Category__c> categories = new  List<PMP_Category__c> ();
    //     if(Schema.sObjectType.PMP_Category__c.isAccessible()){ //PMD Fix
    //         /*
    //     categories = [SELECT Id,PMP_Parent_Category_Id__c, Name,PMP_Partner_Product_Category_Cd__c
    //                                         ,PMP_Partner_Product_Parent_Category_Cd__c, PMP_Ancestor_Category_Cd__c,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c
    //                                         FROM PMP_Category__c 
    //                                         WHERE PMP_Active_Ind__c = true 
    //                                         ORDER BY PMP_Category_Display_Sequence_Nbr__c];
	// 		*/            

    //         for(PMP_Category__c cat : [SELECT Id,PMP_Parent_Category_Id__c, Name,PMP_Partner_Product_Category_Cd__c,
    //                                    (SELECT Id FROM Offering_Categories__r WHERE PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published 
    //                                     AND PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c=False AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY AND PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY AND 
    //                                     PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published AND
    //                                     PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Benefit_Update_Ind__c=False LIMIT 1),
    //                                    PMP_Partner_Product_Parent_Category_Cd__c, PMP_Ancestor_Category_Cd__c,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c
    //                                    FROM PMP_Category__c 
    //                                    WHERE PMP_Active_Ind__c = true 
    //                                    ORDER BY PMP_Category_Display_Sequence_Nbr__c]) {
    //              if(cat.Offering_Categories__r.size() > 0) { 
    //                  categories.add(cat);
    //              }
    //         }
    //     }
    //    /* List<PMP_Category__c> categories = [SELECT Id,PMP_Parent_Category_Id__c, Name,PMP_Partner_Product_Category_Cd__c
    //                                         ,PMP_Partner_Product_Parent_Category_Cd__c, PMP_Ancestor_Category_Cd__c,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c
    //                                         FROM PMP_Category__c 
    //                                         WHERE PMP_Active_Ind__c = true 
    //                                         ORDER BY PMP_Category_Display_Sequence_Nbr__c];*/
 		
    //     for(PMP_Category__c cat : categories){
    //         if(cat.PMP_Partner_Product_Category_Cd__c == 'TPS_900002'){
    //             List<SeoCat> sCatList = new List<SeoCat>();
    //             sCatList.add(getSeoCat(cat,baseCommunityUrl,langCode));
    //             catMap.put('Component', sCatList);
    //         }else if(cat.PMP_Partner_Product_Category_Cd__c == 'IPA_TYPE_Sys'){
    //             List<SeoCat> sCatList = new List<SeoCat>();
    //             sCatList.add(getSeoCat(cat,baseCommunityUrl,langCode));
    //             catMap.put('System', sCatList);
    //         }else if(cat.PMP_Partner_Product_Category_Cd__c == 'TPS_900003'){
    //             List<SeoCat> sCatList = new List<SeoCat>();
    //             sCatList.add(getSeoCat(cat,baseCommunityUrl,langCode));
    //             catMap.put('Software', sCatList);
    //         }else if(cat.PMP_Partner_Product_Category_Cd__c == 'IPA_TYPE_Ser'){
    //             List<SeoCat> sCatList = new List<SeoCat>();
    //             sCatList.add(getSeoCat(cat,baseCommunityUrl,langCode));
    //             catMap.put('Service', sCatList);
    //         }else if(cat.PMP_Partner_Product_Category_Cd__c == 'IPA_TYPE_Sol'){
    //             List<SeoCat> sCatList = new List<SeoCat>();
    //             sCatList.add(getSeoCat(cat,baseCommunityUrl,langCode));
    //             catMap.put('Solution', sCatList);
    //         }else if(cat.PMP_Partner_Product_Category_Cd__c == 'NPP_01_Industry'){
    //             //cat.name = 'Offerings by Industry';
    //             cat.name = system.Label.PMP_L0_Offerings_Industry;
    //             List<SeoCat> sCatList = new List<SeoCat>();
    //             sCatList.add(getSeoCat(cat,baseCommunityUrl,langCode));
    //             //catMap.put('Offerings by Industry', sCatList);
    //             catMap.put(system.Label.PMP_L0_Offerings_Industry, sCatList);
    //         }else if(cat.PMP_Partner_Product_Category_Cd__c == 'NPP_01_APP'){
    //             cat.name = system.label.PMP_L0_Offerings_Application; // value change from Application to Use Cases
    //             //cat.name = 'Offerings by Application';
                
    //             List<SeoCat> sCatList = new List<SeoCat>();
    //             sCatList.add(getSeoCat(cat,baseCommunityUrl,langCode));
    //             catMap.put(system.label.PMP_application, sCatList); // value change from Application to Use Cases
    //         }
    //     }
        
    //     for(PMP_Category__c cat : categories){
    //         if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|').size() >1 && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[1] == 'TPS_900002'){
    //             if(catMap.containsKey('Component')){
    //                catMap.get('Component').add(getSeoCat(cat,baseCommunityUrl,langCode)); 
    //             }
                
    //         }else if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|').size() >1 && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[1] == 'IPA_TYPE_Sys'){
    //             if(catMap.containsKey('System')){
    //                catMap.get('System').add(getSeoCat(cat,baseCommunityUrl,langCode)); 
    //             }       
    //         }else if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|').size() >1 && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[1] == 'TPS_900003'){
    //             if(catMap.containsKey('Software')){
    //                catMap.get('Software').add(getSeoCat(cat,baseCommunityUrl,langCode)); 
    //             }                 
    //         }else if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|').size() >1 && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[1] == 'IPA_TYPE_Ser'){
    //             if(catMap.containsKey('Service')){
    //                catMap.get('Service').add(getSeoCat(cat,baseCommunityUrl,langCode)); 
    //             } 
    //         }else if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|').size() >1 && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[1] == 'IPA_TYPE_Sol'){
    //             if(catMap.containsKey('Solution')){
    //                catMap.get('Solution').add(getSeoCat(cat,baseCommunityUrl,langCode)); 
    //             }  
    //         }else if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[0] == 'NPP_01_Industry'){
    //            /* if(catMap.containsKey('Offerings by Industry')){
    //                catMap.get('Offerings by Industry').add(getSeoCat(cat,baseCommunityUrl,langCode)); 
    //             }*/
    //              if(catMap.containsKey(system.Label.PMP_L0_Offerings_Industry)){
    //                catMap.get(system.Label.PMP_L0_Offerings_Industry).add(getSeoCat(cat,baseCommunityUrl,langCode)); 
    //             }
    //         }else if(cat.PMP_Ancestor_Category_Cd__c!=null && cat.PMP_Ancestor_Category_Cd__c.split('\\|')[0] == 'NPP_01_APP'){
    //             if(catMap.containsKey(system.label.PMP_application)){
    //               catMap.get(system.label.PMP_application).add(getSeoCat(cat,baseCommunityUrl,langCode)); // value change from Application to Use Cases
    //             }  
    //         }
    //     }
        
	
 	// 	return getAllSpecialtyAndPartnerProgram(catMap,langCode);
    // }
    
   
    
    
    // public static Map<String,List<SeoCat>> getAllSpecialtyAndPartnerProgram(Map<String,List<SeoCat>> masterMap,String langCode){

    //     Set<String> specialtyNames = new Set<String>();
    //     Set<String> partnerSegments = new Set<String>();
    //     Set<String> partnerDirectories = new Set<String>();
    //     List<PMP_Company__c> activePartners = New List<PMP_Company__c>();
    //      if(Schema.sObjectType.PMP_Company__c.isAccessible()){ //PMD Fix
    //          activePartners = [Select id,toLabel(PMP_Account_Specialty__c),PMP_Partner_Segment_Nm__c,PMP_Partner_Program_nm__c from PMP_Company__c where PMP_Company_Lifecycle_Status_Nm__c ='Published' and PMP_Benefit_Update_Ind__c =false
    //                            AND (PMP_Account_Specialty__c != NULL OR PMP_Partner_Segment_Nm__c != NULL OR PMP_Partner_Program_nm__c != NULL)
    //                           ];
    //      }
    //     for(PMP_Company__c comp : activePartners){
    //         if(String.isNotBlank(comp.PMP_Account_Specialty__c)) {
    //         specialtyNames.addall(comp.PMP_Account_Specialty__c.split(';'));
    //     }
      
    //         if(String.isNotBlank(comp.PMP_Partner_Segment_Nm__c)) {
    //             partnerSegments.addAll(comp.PMP_Partner_Segment_Nm__c.split(';'));
    //         }
            
    //         if(String.isNotBlank(comp.PMP_Partner_Program_nm__c)) {
    //             partnerDirectories.addAll(comp.PMP_Partner_Program_nm__c.split(';'));
    //         }
    //     }

    //     List<PMP_Partner_Specialty__c> specialtyList = new List<PMP_Partner_Specialty__c>();
    //     if(Schema.sObjectType.PMP_Partner_Specialty__c.isAccessible()){ //PMD Fix
    //         if(langCode=='ja'){
    //             specialtyList = [SELECT id, Name,PMP_Partner_Specialty_Chinese_Nm__c, PMP_Partner_Specialty_Japanese_Nm__c,PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c where PMP_Is_Active_Ind__c = TRUE AND PMP_Partner_Specialty_Japanese_Nm__c in :specialtyNames];
    //         }
    //         else if(langCode=='zh-CN' || langCode=='zh-Hans-CN' ||langCode=='zh_CN'){
    //             specialtyList = [SELECT id, Name,PMP_Partner_Specialty_Chinese_Nm__c, PMP_Partner_Specialty_Japanese_Nm__c,PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c where PMP_Is_Active_Ind__c = TRUE AND PMP_Partner_Specialty_Chinese_Nm__c in :specialtyNames];
    //         }
    //         else{
    //             specialtyList = [SELECT id, Name,PMP_Partner_Specialty_Chinese_Nm__c, PMP_Partner_Specialty_Japanese_Nm__c,PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c where PMP_Is_Active_Ind__c = TRUE AND Name in :specialtyNames];
    //         }
        
    //     }
    //   //  List<PMP_Partner_Specialty__c> specialtyList = [SELECT id, Name,PMP_Partner_Specialty_Chinese_Nm__c, PMP_Partner_Specialty_Japanese_Nm__c,PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c where Name!=:PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program AND PMP_Is_Active_Ind__c = TRUE];
        
       
    //     List<SeoCat> specList = new List<SeoCat>();
    //     SeoCat specialty = new SeoCat();
    //      //For translations
     
    //     String specialtyName = PMP_SearchUtilityController.getFieldApiName('PMP_Partner_Specialty__c', 'Name',langCode);
    //     if(String.isEmpty(specialtyName)){
    //         specialtyName = 'Name';
    //     }
    //     //For translations
    //     //specialty.Name = 'Partners by Specialty';
    //     specialty.Name = System.Label.PMP_L1_Partners_By_Specialty;
    //     specList.add(specialty);
    //     for(PMP_Partner_Specialty__c spec : specialtyList){
    //         SeoCat sCat = new SeoCat();
    //         sCat.Id = spec.Id;
    //         //sCat.objectAPiName = 'PMP_Partner_Specialty__c';
    //         sCat.objectAPiName = specialtyName;
    //         //sCat.Name = spec.Name+' '+System.Label.PMP_Partner;
    //          if((String)spec.get(specialtyName)!=null)
    //         sCat.Name = (String)spec.get(specialtyName)+' '+System.Label.PMP_Partner;
    //         else 
    //         sCat.Name = (String)spec.get('Name')+' '+System.Label.PMP_Partner;
    //         sCat.url = baseCommunityUrl + specialtybaseUrl + spec.Id;
    //         specList.add(sCat);
    //     }
    //     masterMap.put(System.Label.PMP_L1_Partners_By_Specialty, specList);

    //     List<PMP_Partner_Program__c> seoPpList = new  List<PMP_Partner_Program__c>();
    //     if(Schema.sObjectType.PMP_Partner_Program__c.isAccessible()){ //PMD Fix
    //     seoPpList =[SELECT id,Name,PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c,PMP_Partner_Role_Parent_Id__c,
    //                 PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE AND Name IN :partnerDirectories];       
    //     }
    //     // List<PMP_Partner_Program__c> seoPpList =[SELECT id,Name,PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c,PMP_Partner_Role_Parent_Id__c from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE];
    //    //For translations
    // /*    List<PMP_SearchPartnerProgram_Config__mdt> ppListmdt = new List<PMP_SearchPartnerProgram_Config__mdt>();
    //     if(Schema.sObjectType.PMP_SearchPartnerProgram_Config__mdt.isAccessible()){
    //         ppListmdt = [SELECT Label,PMP_Partner_Program_Name__c,Active__c,  PMP_Partner_Program_value__c,
    //                   PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c                      
    //                   FROM PMP_SearchPartnerProgram_Config__mdt
    //                   WHERE Active__c = true 
    //                   ORDER BY Label];
            
    //    }
    //     String partnerProgName = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Name',langCode);
    //     if(String.isEmpty(partnerProgName)){
    //         partnerProgName = 'PMP_Partner_Program_Name__c';
    //     }
    //     Map<String,String> roleNameMap = new Map<String, String>();
    //     for(PMP_SearchPartnerProgram_Config__mdt pp : ppListmdt){
    //         if((String)pp.get(partnerProgName)!=Null){
    //              roleNameMap.put(pp.PMP_Partner_Program_value__c,(String)pp.get(partnerProgName)); 
    //         }
    //         else{
    //         	roleNameMap.put(pp.PMP_Partner_Program_value__c,pp.PMP_Partner_Program_value__c);
    //         }
    //     }*/
        
    //    //For translations
                
    //     List<SeoCat> ppList = new List<SeoCat>();
    //     SeoCat pp = new SeoCat();
    //     //pp.Name = 'Partner Directory';
    //     pp.Name = System.Label.PMP_Breadcrumbs_All_Partners;
    //     ppList.add(pp);
    //     for(PMP_Partner_Program__c pProg : seoPpList){
    //         SeoCat sCat = new SeoCat();
    //         if(pProg.PMP_Partner_Role_Parent_Id__c!=null){
    //         sCat.Id = pProg.PMP_Partner_Role_Parent_Id__c;  
    //         }else{
    //         sCat.Id = pProg.Id;
    //         }
    //         sCat.objectApiName = 'PMP_Partner_Program__c';
    //   /*      if(roleNameMap.containskey(pProg.Name)){
    //         sCat.Name = roleNameMap.get(pProg.Name)+' '+System.Label.PMP_Partner;
    //         }
    //         else{
    //         sCat.Name = pProg.Name+' '+System.Label.PMP_Partner;                
    //         }*/
    //         sCat.Name = PMP_SearchUtilityController.getLocalisedName(pProg, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode)+' '+System.Label.PMP_Partner;
    //         sCat.url = baseCommunityUrl + partnerProgramBaseUrl + pProg.Id;
    //        if(pProg.PMP_Partner_Program_Value_Txt__c == 'ODM-LOEM'){
    //             sCat.Name = PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program;
    //         }
    //         ppList.add(sCat);
    //     }
    //     masterMap.put(System.Label.PMP_Breadcrumbs_All_Partners, ppList);
    //     // Partner by Segment
    //     List<PMP_Partner_Segment__c> partnerSegmentList = new List<PMP_Partner_Segment__c>();
    //     if(Schema.sObjectType.PMP_Partner_Segment__c.isAccessible()){ //PMD Fix
    //     partnerSegmentList = [Select Id, name, PMP_Partner_Segment_Value_Txt__c,PMP_Partner_Segment_Chinese_Name_Txt__c,PMP_Partner_Segment_Japanese_Name_Txt__c from PMP_Partner_Segment__c where PMP_Is_Active_Ind__c = true AND Name IN :partnerSegments];
    //     }
    //     //List<PMP_Partner_Segment__c> partnerSegmentList = [Select Id, name, PMP_Partner_Segment_Value_Txt__c,PMP_Partner_Segment_Chinese_Name_Txt__c,PMP_Partner_Segment_Japanese_Name_Txt__c from PMP_Partner_Segment__c where PMP_Is_Active_Ind__c = true];
       	 
        
    //     List<SeoCat> psegList = new List<SeoCat>();
    //     SeoCat pseg = new SeoCat();
    //     pseg.Name = System.Label.PMP_L0_Partners_Market_Segment;
    //     psegList.add(pseg);
    //     for(PMP_Partner_Segment__c pProg : partnerSegmentList){
    //         SeoCat sCat = new SeoCat();
    //         sCat.Id = pProg.Id;
    //         sCat.objectApiName = 'PMP_Partner_Segment__c';
    //         String segmentName=PMP_SearchUtilityController.getLocalisedName(pProg, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
    //         //sCat.Name = pProg.Name+' '+System.Label.PMP_Partner;
    //         sCat.Name = segmentName+' '+System.Label.PMP_Partner;
    //         sCat.url = baseCommunityUrl + partnerProgramBaseUrl + pProg.Id;
           
    //         psegList.add(sCat);
    //     }
    //     masterMap.put(System.Label.PMP_L0_Partners_Market_Segment, psegList);
    //     // End of Partner by Segment 
        
      
    //     // added for Partner By Industry -- Start
    //     List<PMP_Category_Partner__c> industryPartnersList = new List<PMP_Category_Partner__c>();
    //    if(Test.isRunningTest()){
    //     if(Schema.sObjectType.PMP_Category_Partner__c.isAccessible()){ //PMD Fix
    //        industryPartnersList =  [SELECT Id, Name, PMP_Category_Id__c,
    //                                                            PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,PMP_Category_Id__r.PMP_Parent_Category_Id__c,
    //                                                            PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c FROM PMP_Category_Partner__c 
    //                                                            WHERE PMP_Category_Id__r.PMP_Active_Ind__c = true 
    //                                                            ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c ];
    //     }
    //     }else{
    //         if(Schema.sObjectType.PMP_Category_Partner__c.isAccessible()){ //PMD Fix
    //             /*
    //         industryPartnersList  = [SELECT Id, Name, PMP_Category_Id__c,
    //                                                            PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,PMP_Category_Id__r.PMP_Parent_Category_Id__c,
    //                                                            PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c FROM PMP_Category_Partner__c 
    //                                                            WHERE  PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c LIKE '%NPP_01_Industry%'
    //                                                            AND PMP_Category_Id__r.PMP_Active_Ind__c = true 
    //                                                            ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c ];
    //             */
    //             Set<Id> catIds = new Set<Id>();
    //             Set<Id> validCatIds = new Set<Id>();
    //             for(PMP_Category_Partner__c catPartner : [SELECT Id, Name, PMP_Category_Id__c FROM PMP_Category_Partner__c 
    //                                                       WHERE  PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c LIKE '%NPP_01_Industry%'
    //                                                       AND PMP_Category_Id__r.PMP_Active_Ind__c = true 
    //                                                       ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c]) {
    //                  catIds.add(catPartner.PMP_Category_Id__c);
    //             }
                
    //             for(PMP_Category__c cat : [SELECT Id,(SELECT Id FROM Partner_Industry_Applications__r WHERE PMP_Partner_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published AND
    //                                        PMP_Partner_Id__r.PMP_Benefit_Update_Ind__c=False LIMIT 1) FROM PMP_Category__c WHERE Id IN :catIds]) {
    //                  if(cat.Partner_Industry_Applications__r.size() > 0) {
    //                      validCatIds.add(cat.Id);
    //                  }
    //             }
                
    //             industryPartnersList  = [SELECT Id, Name, PMP_Category_Id__c,
    //                                      PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,PMP_Category_Id__r.PMP_Parent_Category_Id__c,
    //                                      PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c FROM PMP_Category_Partner__c 
    //                                      WHERE PMP_Category_Id__c IN :validCatIds AND PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c LIKE '%NPP_01_Industry%'
    //                                      ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c];
    //      }
    //     }
    
    //     List<SeoCat> shadInduList = new List<SeoCat>();
    //     List<Id> shadowCatId = new List<Id>();
        
    //    // system.debug('bala industryPartnersList'+industryPartnersList);
    //     SeoCat shadoIndus = new SeoCat();
    //     shadoIndus.Name = System.Label.PMP_L0_Partners_Industry;
    //     shadInduList.add(shadoIndus);
    //    // system.debug('bala industryPartnersList'+industryPartnersList[0].Name+industryPartnersList[0].PMP_Category_Id__r.Name+industryPartnersList[0].PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c);
		      

    //     for(PMP_Category_Partner__c shadow :industryPartnersList){
    //         PMP_Category__c realrec = new PMP_Category__c();
    //         realrec.id = shadow.PMP_Category_Id__c;
    //         realrec.PMP_Category_Japanese_Nm__c = shadow.PMP_Category_Id__r.PMP_Category_Japanese_Nm__c;
    //         realrec.PMP_Category_Chinese_Nm__c = shadow.PMP_Category_Id__r.PMP_Category_Chinese_Nm__c;
    //         realrec.Name = shadow.PMP_Category_Id__r.Name;
    //         SeoCat sCat = new SeoCat();
    //         sCat.Id = shadow.Id;
    //         sCat.objectAPiName = 'PMP_Category_Partner__c';
    //         String indstylab=PMP_SearchUtilityController.getLocalisedName(realrec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
    //         //sCat.Name = shadow.Name+' '+System.Label.PMP_Partner;
    //         sCat.Name = indstylab+' '+System.Label.PMP_Partner;
    //         sCat.url = baseCommunityUrl + specialtybaseUrl + shadow.Id;
        
        
    //     if(shadow.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c!= null){
    //         sCat.categoryLevel = shadow.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c.split('\\|').size();
    //     }
        
    //     else{
    //         sCat.categoryLevel = 0;
            
    //     }
        
    //     if(shadow.PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c == 'NPP_01_Industry' || shadow.PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c == 'NPP_01_APP'){
    //         sCat.categoryLevel+=1;
    //         sCat.url = '';
    //     }
        
        
    //     if(shadow.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c!=null){
    //         if(shadow.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c.split('\\|')[0] == 'NPP_01_Industry' || shadow.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c.split('\\|')[0] == 'NPP_01_APP')
    //             sCat.categoryLevel+=1;  
    //     }
        
    //         shadInduList.add(sCat);
            
    //     }
    //     masterMap.put(System.Label.PMP_L0_Partners_Industry, shadInduList);
    //     //catMap.get('Application').add(getSeoCat(cat,baseCommunityUrl));
    //     // added for Partner By Industry -- Ends
        
    //     return masterMap;
    // }
    
    // private static SeoCat getSeoCat(PMP_Category__c cat, String baseUrl,string langCode){
    //     SeoCat sCat = new SeoCat();
    //     sCat.Id = cat.Id;
    //     sCat.objectApiName = 'PMP_Category__c';
    //     //sCat.Name = cat.Name+' '+'Offering';

    //     //Added a check for 'Offerings by Industry' and 'Offerings by Application' as these are titles and no need to append 'Offering' with name
    //     // [DE101602]
    //     if(cat.Name==system.Label.PMP_L0_Offerings_Industry || cat.Name==system.label.PMP_L0_Offerings_Application ){
    //         sCat.Name = cat.Name;
    //     }
    //     else{
    //       String label=PMP_SearchUtilityController.getLocalisedName(cat,PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
    //       sCat.Name = label+' '+ system.label.PMP_SiteMap_Offering;  
    //     }
    //     //scat.page = pageName;
    //     sCat.url = baseUrl + categoryBaseUrl + cat.Id;
    //     if(cat.PMP_Ancestor_Category_Cd__c!= null){
    //         sCat.categoryLevel = cat.PMP_Ancestor_Category_Cd__c.split('\\|').size();
    //     }
        	
    //     else{
    //           sCat.categoryLevel = 0;
           	 
    //     }
       
    //     if(cat.PMP_Partner_Product_Category_Cd__c == 'NPP_01_Industry' || cat.PMP_Partner_Product_Category_Cd__c == 'NPP_01_APP'){
    //         sCat.categoryLevel+=1;
    //         sCat.url = '';
    //     }
            
            
    //     if(cat.PMP_Ancestor_Category_Cd__c!=null){
    //        if(cat.PMP_Ancestor_Category_Cd__c.split('\\|')[0] == 'NPP_01_Industry' || cat.PMP_Ancestor_Category_Cd__c.split('\\|')[0] == 'NPP_01_APP')
    //        sCat.categoryLevel+=1;  
    //     }
        
    //     return sCat;
    // }
    
     
    
}