public with sharing class PMP_MarketplaceNewPartnerDetailFeed extends PMP_SearchWrapperStore{
    
    public static Map<Id, FilterData> mapParentToChildFilterData = new Map<Id, FilterData>();
    public static Map<String,CardData> offeringMap = new Map<String,CardData>();
    public static Map<String, Integer> mapCategoryIdToSeq = new Map<String, Integer>(); //new enhancement in feed card - Categories
    
    @AuraEnabled(cacheable=true)
    public static StorefrontFeedItem getStorefrontFeedDetails(String partnerId, String langCode){
        StorefrontFeedItem item = new StorefrontFeedItem();
        
        //Get the company information
        PMP_Company__c company = new PMP_Company__c();
        try{
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
            //as part of new OPID structure, added new field PMP_Partner_Benefit_Type__c in the query
            company=[SELECT Id,Name,PMP_Partner_Benefit_Type__c,PMP_Is_Working_Copy_Ind__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c, PMP_Account_Dsc__c, PMP_Account_Address_Txt__c,
                     PMP_Account_Industry__c, PMP_Account_Application__c,PMP_Account_Region__c, PMP_Account_Program_Membership__c,PMP_Company_Lifecycle_Status_Nm__c, 
                     PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c, PMP_Account_Specialty__c,PMP_Account_Website__c,
                     PMP_Account_Tag_Line__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,
                     PMP_Working_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Working_Copy_Id__r.PMP_Is_Updated_Ind__c,
                     PMP_Working_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Published_Copy_Id__c,
                     PMP_Published_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Published_Copy_Id__r.PMP_Is_Updated_Ind__c,
                     PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Published_Ind__c,
                     PMP_Published_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c,
                     toLabel(PMP_Disti_Components_Nm__c),toLabel(PMP_Disti_Sys_Solutions_Nm__c),PMP_Is_Distributor_Ind__c,PMP_Company_Status_Published_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c
                     FROM PMP_Company__c where id=:partnerId LIMIT 1];
        }
        }catch(Exception e){
           // system.debug('error while fetching company records' + e);
           PMP_Utility.logError(e, 'PMP_MarketplaceNewPartnerDetailFeed');
            //Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, SCOPE, SEVERITY, e.getMessage(), e.getStackTraceString(), '', '', '');
       
           
        }
        if(company.PMP_Is_Working_Copy_Ind__c == true){
            try{
                if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                    //as part of new OPID structure, added new field PMP_Partner_Benefit_Type__c in the query
                    company=[SELECT Id,Name,PMP_Partner_Benefit_Type__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c, PMP_Account_Dsc__c, PMP_Account_Address_Txt__c,PMP_Company_Lifecycle_Status_Nm__c,
                             PMP_Account_Industry__c, PMP_Account_Application__c,PMP_Account_Region__c, PMP_Account_Program_Membership__c, 
                             PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c, PMP_Account_Specialty__c,PMP_Account_Website__c,
                             PMP_Account_Tag_Line__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,
                             PMP_Working_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Working_Copy_Id__r.PMP_Is_Updated_Ind__c,
                             PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Published_Ind__c,
                             PMP_Working_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c,
                             toLabel(PMP_Disti_Components_Nm__c),toLabel(PMP_Disti_Sys_Solutions_Nm__c),PMP_Is_Distributor_Ind__c,PMP_Published_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c,PMP_Company_Status_Published_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c
                             FROM PMP_Company__c where PMP_Working_Copy_Id__c =: partnerId LIMIT 1];
                }
                partnerId = company.Id;
            }catch(Exception e){
                PMP_Utility.logError(e, 'PMP_MarketplaceNewPartnerDetailFeed');
            //Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, SCOPE, SEVERITY, e.getMessage(), e.getStackTraceString(), '', '', '');
            }
        }
        
        item.cardData=new List<cardData>(); 
        item.filterStructure = new List<FilterStructure>(); 
        item.filterData = new Map<id,FilterData>();
        //as part of new OPID structure, commented below part query and added below

        //List<String> benCode = new List<String>();
        /*for (PRM_AccountBenefitAssociation__c accBen:[SELECT PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c 
                                                      WHERE PRM_Account_Id__c =:company.PMP_Account_Id__c AND PRM_Status_Nm__c = 'Active'])
        {
            benCode.add(accBen.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c);
        }
        if (benCode.contains(PMP_StaticConstants_Partner.BENEFIT_ENHANCED_CODE)){*/
        if(company.PMP_Partner_Benefit_Type__c==PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced){
            //To get offerings related to company
            //getPartnerOfferings(item, partnerId, company.Name, langCode);
            //To get filter data and filter structure of the offerings 
            //getFilterData(item, offeringMap.keySet(), langCode);
        }
        //To get articles related to the company
        //getArticles(item, partnerId, langCode); need check
        //Get total items count
        item.totalItems = item.cardData.size();
        
        return item;
    }
    
    // public static void getPartnerOfferings(StorefrontFeedItem item, String partnerId, String partnerName, String langCode){
        
    //      //To get the Category of 'NPP_01_TYPE'
    //     List<PMP_Category__c> cats = new List<PMP_Category__c>();
    //     if(Schema.sObjectType.PMP_Category__c.isAccessible()){
    //         cats = [SELECT Id FROM PMP_Category__c WHERE PMP_Active_Ind__c= TRUE AND PMP_Partner_Product_Parent_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_CATEGORY_ID ];
    //     }
    //     List<String> catIds = new List<String>();
    //     for(PMP_Category__c cat: cats){
    //         catIds.add(cat.Id);
    //     } 
        
    //     //To get Offerings associated for each category
    //     List<PMP_Category__c> catList = new List<PMP_Category__c>();
    //     if(Schema.sObjectType.PMP_Category__c.isAccessible() && Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
    //         catList = [SELECT Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Category_Cd__c,
    //                    (SELECT PMP_Offering_Id__r.PMP_Partner_Offering_Visibility_Nm__c,PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c,
    //                     PMP_Offering_Id__c, PMP_Offering_Id__r.Name, PMP_Offering_Id__r.PMP_Partner_Offering_Dsc__c, PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c, 
    //                     PMP_Offering_Id__r.PMP_Partner_Offering_Tag_Line_Txt__c, PMP_Offering_Id__r.PMP_Offering_Status_Update_Dt__c FROM Offering_Categories__r WHERE PMP_Offering_Id__r.PMP_Company_Id__c =: partnerId 
    //                     AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published AND PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = false
    //                     AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY 
    //                     ORDER BY PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Id__r.PMP_Offering_Status_Update_Dt__c DESC NULLS LAST) 
    //                   FROM PMP_Category__c WHERE PMP_Active_Ind__c=true AND Id IN:catIds ORDER BY PMP_Category_Display_Sequence_Nbr__c];
    //     }
        
    //     //Get the Category & their offerings
    //     for(PMP_Category__c cat: catList){
    //         for(PMP_Partner_Offering_Category__c offCat: cat.Offering_Categories__r){
    //             CardData offeringData = new CardData();
    //             offeringData.cardType = PMP_StaticConstants_Partner.Offering;
    //             offeringData.id = offCat.PMP_Offering_Id__c;
    //             offeringData.title = offCat.PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c;
    //             offeringData.tagline = offCat.PMP_Offering_Id__r.PMP_Partner_Offering_Tag_Line_Txt__c;
    //             offeringData.description = offCat.PMP_Offering_Id__r.PMP_Partner_Offering_Dsc__c;
    //             offeringData.description = offeringData.description.unescapeHtml4().stripHtmlTags(); //added by krishna ch
    //             offeringData.imageUrl = PMP_StaticConstants_Partner.staticProductUrl;
    //             offeringData.imageAlt = offCat.PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c;
    //             offeringData.featured = offCat.PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c;
    //             offeringData.statusUpdateDate = string.valueOfGmt(offCat.PMP_Offering_Id__r.PMP_Offering_Status_Update_Dt__c);
    //             OfferingData.categories = new List<Categories>(); //new enhancement in feed card - Categories
    //             item.cardData.add(offeringData);
    //             offeringMap.put(offeringData.Id,offeringData);
    //         }
    //     }
    //     item.cardData.sort();
        
    //     //To get translation for offering title & description
    //     Map<String,PMP_Partner_Offering_Translation__c> offTransMap = new Map<String,PMP_Partner_Offering_Translation__c>(); 
    //     List<PMP_Partner_Offering_Translation__c> offTransList = new List<PMP_Partner_Offering_Translation__c>();
    //     if(Schema.sObjectType.PMP_Partner_Offering_Translation__c.isAccessible()){
    //         offTransList = [SELECT PMP_Field_Nm__c, PMP_Partner_Offering_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Partner_Offering_Translation__c 
    //                         WHERE (PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_NAME 
    //                                OR PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_DESCRIPTION
    //                                OR PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_TAGLINE) 
    //                         AND PMP_Partner_Offering_Id__c IN :offeringMap.keySet()];
    //     }
    //     for(PMP_Partner_Offering_Translation__c trans: offTransList){
    //         if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_NAME){
    //             offeringMap.get(trans.PMP_Partner_Offering_Id__c).title = PMP_SearchUtilityController.getLocalisedName(trans, '',langCode).unescapeHtml4().stripHtmlTags(); 
    //             offeringMap.get(trans.PMP_Partner_Offering_Id__c).imageAlt = PMP_SearchUtilityController.getLocalisedName(trans, '',langCode).unescapeHtml4().stripHtmlTags(); 
    //         }
    //         if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_DESCRIPTION){
    //             offeringMap.get(trans.PMP_Partner_Offering_Id__c).description = PMP_SearchUtilityController.getLocalisedName(trans, '', langCode).stripHtmlTags().replaceAll('<[^>]+>', '');
    //         }
    //         if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_TAGLINE){
    //             offeringMap.get(trans.PMP_Partner_Offering_Id__c).tagline = PMP_SearchUtilityController.getLocalisedName(trans, '', langCode).unescapeHtml4().stripHtmlTags();
    //         }
    //     }  
        
    //     //To get Offering Image
    //     Map<String,String> offContentMap=new Map<String,String>();
    //     List<String> conDocList = new List<String>();
    //     List<PMP_Partner_Offering_Resource__c> offResList = new List<PMP_Partner_Offering_Resource__c>();
    //     if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
    //         offResList = [Select PMP_Offering_Id__c, PMP_Partner_Offering_Image__c from PMP_Partner_Offering_Resource__c
    //                       WHERE PMP_Offering_Id__c in :offeringMap.keySet() 
    //                       AND PMP_Resource_Type_Nm__c=:PMP_StaticConstants_Partner.IMAGE
    //                       AND PMP_Partner_Offering_Image__c != null and PMP_Resource_Sequence_Nbr__c = 0 ORDER BY PMP_Resource_Type_Nm__c ASC];      
    //     } 
    //     for(PMP_Partner_Offering_Resource__c offRes : offResList){
    //         if(offRes.PMP_Partner_Offering_Image__c != null){
    //             offContentMap.put(offRes.PMP_Offering_Id__c, offRes.PMP_Partner_Offering_Image__c);
    //         }
    //     }
    //     conDocList.addAll(offContentMap.values());
    //     Map<String,String> offConAssetUrl = PMP_SearchOfferingImageUtility.getContentAssetUrlMap(conDocList);
    //     if(!conDocList.isEmpty()){
    //         for(String offId: offeringMap.keySet()){
    //             if(offContentMap.containsKey(offId)){
    //                 String assetName = offConAssetUrl.get(offContentMap.get(offId));
    //                 offeringMap.get(offId).imageUrl = System.Label.PMP_CommunityURLSuffix+'file-asset/'+assetName+'?isOptimized=false';  
    //             }
    //         }            
    //     }
    // }
    
    // public static void getArticles(StorefrontFeedItem item, String partnerId, String langCode) {
        
    //     ArticleData artData = new ArticleData();
    //     artData = PMP_CompanyArticles.getArticles(partnerId, langCode);
    //     if(artData.articleList != null){
    //         for(Article dt : artData.articleList) {
    //             CardData articleData = new CardData();
    //             articleData.cardType = PMP_StaticConstants_Partner.Article;
    //             articleData.title = dt.title;
    //             articleData.description = dt.description;
    //             articleData.externalUrl = dt.link;
    //             articleData.createdDate = dt.createdDate;
    //             articleData.statusUpdateDate = dt.createdAt;
    //             articleData.featured = false;
    //             item.cardData.add(articleData);
    //         }
    //     }
    //     item.cardData.sort();
    //     if(item.cardData.size() > 0){
    //         List<CardData> sortedCardData = new List<CardData>();
    //         for(CardData offeringData :  item.cardData){
    //             if(offeringData.featured){
    //                 sortedCardData.add(offeringData);
    //             }
    //         }
    //         for(CardData offeringData :  item.cardData){
    //             if(!offeringData.featured){
    //                 sortedCardData.add(offeringData);
    //             }
    //         }
    //         item.cardData = sortedCardData;
    //     }
    // }
    
    // public static void getFilterData(StorefrontFeedItem item, Set<String> offeringIds, String langCode) {
        
    //     Map<Id, FilterStructure> mapParentToFilterStructure = new Map<Id, FilterStructure>();
    //     List<PMP_Partner_Offering_Category__c> catOfferingList = new List<PMP_Partner_Offering_Category__c>();
        
    //     //To get offerings by category, application and industry
    //     if(offeringIds.size() > 0){
    //         if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
    //             catOfferingList = [Select id,Name,PMP_Category_Id__c,PMP_Ancestor_Category_Cd__c, PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name,
    //                                PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Chinese_Nm__c,
    //                                PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Japanese_Nm__c,
    //                                PMP_Offering_Id__c  ,PMP_Localized_Category_Nm__c,PMP_Offering_Category_External_Key__c,PMP_Category_Id__r.PMP_Active_Ind__c,
    //                                PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c,PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,
    //                                PMP_Category_Id__r.PMP_Tool_Tip_English_Txt__c,PMP_Category_Id__r.PMP_Tool_Tip_Chinese_Txt__c,
    //                                PMP_Category_Id__r.PMP_Tool_Tip_Japanese_Txt__c,PMP_Category_Id__r.Name,
    //                                PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c, PMP_Category_Id__r.Type__c, 
    //                                PMP_Category_Id__r.PMP_ChildMandatory_Ind__c, PMP_Category_Id__r.PMP_Parent_Category_Id__c
    //                                from PMP_Partner_Offering_Category__c 
    //                                Where PMP_Offering_Id__c IN: offeringIds ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c NULLS LAST];
    //         }
            
    //         String localeCatNmField;
    //         List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeFields = PMP_Utility.getLocaleToFieldMdtRecordsByField(langCode, 'Name');
    //         for(PMP_Locale_To_FieldAPINm_Mapping__mdt localField : localeFields){
    //             if(localField.PMP_Object_Nm__c == 'Category'){
    //                 localeCatNmField = localField.PMP_Field_APINm__c;
    //             }
    //         }
            
    //         //new enhancement in feed card - Categories
    //         String typeNameCategoryId;
    //         Map<Id, String> mapCategoryIdToLabelLanguage = new Map<Id, String>();
    //         Map<Id, Set<Id>> mapOfferingIdToCategories = new Map<Id, Set<Id>>();
            
    //         //Initialize filter structure for Categories, Application and Industry
    //         for(PMP_Partner_Offering_Category__c category : catOfferingList){
    //             mapCategoryIdToLabelLanguage.put(category.PMP_Category_Id__c, String.valueOf(category.PMP_Category_Id__r.get(localeCatNmField))); //new enhancement in feed card - Categories
    //             mapOfferingIdToCategories.put(category.PMP_Offering_Id__c, new Set<Id>()); //new enhancement in feed card - Categories
    //             if(category.PMP_Category_Id__r.PMP_Parent_Category_Id__c == null){
    //                 FilterStructure fileStruc = new FilterStructure();
    //                 fileStruc.id = category.PMP_Category_Id__c;
    //                 fileStruc.filterName = category.Name;
    //                 // value change from Application to Use Cases
    //                 if(category.Name == system.label.PMP_application){
    //                     fileStruc.label = System.Label.PMP_L0_Offerings_Application;
    //                 }else if(category.Name == 'Industry'){
    //                     fileStruc.label = System.Label.PMP_L0_Offerings_Industry;
    //                 }else if(category.Name == 'Categories'){ //new enhancement in feed card - Categories
    //                     typeNameCategoryId = category.PMP_Category_Id__c;
    //                 }
    //                 fileStruc.children  = new Set<String>();
    //                 fileStruc.relatedOfferings = new Set<String>();
    //                 mapParentToFilterStructure.put(fileStruc.id, fileStruc); 
    //             }
    //         }
            
    //         //To get Immediate Children to Categories, Application and Industry
    //         for(PMP_Partner_Offering_Category__c category : catOfferingList){
                
    //             if(category.PMP_Category_Id__r.PMP_Parent_Category_Id__c != null){
    //                 //To get the Children of filter structure only if categories/application/industry is the parent
    //                 FilterStructure filStruc = mapParentToFilterStructure.get(category.PMP_Category_Id__r.PMP_Parent_Category_Id__c);
    //                 if(filStruc!=null){
    //                     mapParentToFilterStructure.get(category.PMP_Category_Id__r.PMP_Parent_Category_Id__c).children.add(category.PMP_Category_Id__c);
    //                 }
    //             }else {
    //                 //To get related offerings
    //                 if(mapParentToFilterStructure.containsKey(category.PMP_Category_Id__c)){
    //                     mapParentToFilterStructure.get(category.PMP_Category_Id__c).relatedOfferings.add(category.PMP_Offering_Id__c);
    //                 }
    //             }
    //         }
            
    //         item.filterStructure = mapParentToFilterStructure.values();
            
    //         //Initialize filter data and add all children and related offerings associated to that category
    //         for(PMP_Partner_Offering_Category__c category : catOfferingList){
    //             if(category.PMP_Category_Id__r.PMP_Parent_Category_Id__c != null || Test.isRunningTest()){
    //                 FilterData filterdata = new Filterdata();
    //                 filterdata.id = category.PMP_Category_Id__c;
    //                 filterdata.label = String.valueOf(category.PMP_Category_Id__r.get(localeCatNmField)); //category.Name;
    //                 filterdata.count = 0;
    //                 filterdata.children = new Set<String>();
    //                 filterdata.relatedOfferings = new Set<String>();
    //                 /* Commented as a part of PROD fix : APEX CPU LIMIT EXCEEDED
    //                 //To get children & related offerings
    //                 for(PMP_Partner_Offering_Category__c childCategory : catOfferingList){
    //                     if(childCategory.PMP_Category_Id__r.PMP_Parent_Category_Id__c == category.PMP_Category_Id__c){
    //                         filterdata.children.add(childCategory.PMP_Category_Id__c);
    //                     }
    //                     if(childCategory.PMP_Category_Id__c == category.PMP_Category_Id__c){
    //                         filterdata.relatedOfferings.add(childCategory.PMP_Offering_Id__c);
    //                     }
    //                 }
    //                 //To get filters count
    //                 filterdata.count = filterdata.relatedOfferings.size();
    //                 */
    //                 //To add parent data
    //                 if(!mapParentToFilterStructure.containskey(category.PMP_Category_Id__r.PMP_Parent_Category_Id__c)){
    //                     filterdata.parent = category.PMP_Category_Id__r.PMP_Parent_Category_Id__c;
    //                 }
    //                 mapParentToChildFilterData.put(category.PMP_Category_Id__c, filterdata);
    //             }
    //         }
            
    //         //To get children & related offerings
    //         for(PMP_Partner_Offering_Category__c childCategory : catOfferingList){
    //             if(mapParentToChildFilterData.containsKey(childCategory.PMP_Category_Id__r.PMP_Parent_Category_Id__c)){
    //                 mapParentToChildFilterData.get(childCategory.PMP_Category_Id__r.PMP_Parent_Category_Id__c).children.add(childCategory.PMP_Category_Id__c);
    //             }
    //             if(mapParentToChildFilterData.containsKey(childCategory.PMP_Category_Id__c)){
    //                 mapParentToChildFilterData.get(childCategory.PMP_Category_Id__c).relatedOfferings.add(childCategory.PMP_Offering_Id__c);
    //             }
    //         }
    //         //To get filters count
    //         for(PMP_Partner_Offering_Category__c subCategory : catOfferingList){
    //             FilterData fltData = mapParentToChildFilterData.get(subCategory.PMP_Category_Id__c);
    //             if(fltData != null){
    //                 mapParentToChildFilterData.get(subCategory.PMP_Category_Id__c).count = mapParentToChildFilterData.get(subCategory.PMP_Category_Id__c).relatedOfferings.size();
    //             }
    //         }
            
    //         item.filterData = mapParentToChildFilterData;
            
    //         //new enhancement in feed card - Categories --Logic starts Here--
    //         Set<String> newCategoryIds = new Set<String>();
    //         for(String child : mapParentToFilterStructure.get(typeNameCategoryId).children){
    //             newCategoryIds.add(child);
    //             newCategoryIds.addAll(getAllChildren(child, 0));
    //         }

    //         for(FilterData fltData : mapParentToChildFilterData.values()){
    //             if(newCategoryIds.contains(fltData.id)){
    //                 for(String offeringId : fltData.relatedOfferings){
    //                     mapOfferingIdToCategories.get(offeringId).add(fltData.id);
    //                 }
    //             }
    //         }

    //         for(CardData OfferingData : item.cardData ){
    //             List<Categories> catList = new List<Categories>();
    //             Categories cat = new Categories();
    //             cat.separator = '/';
    //             List<CategoryAttribute> catAttList = new List<CategoryAttribute>();
    //             for(Id categoryId : mapOfferingIdToCategories.get(OfferingData.id)){
    //                 CategoryAttribute catAtt = new CategoryAttribute();
    //                 catAtt.isLink = true;
    //                 catAtt.label = mapCategoryIdToLabelLanguage.get(categoryId);
    //                 catAtt.recordId = categoryId;
    //                 catAtt.objectPage = 'PMP_Category__c';
    //                 catAtt.sequenceNumber = mapCategoryIdToSeq.get(categoryId);
    //                 catAttList.add(catAtt);
    //             }
    //             catAttList.sort();
    //             cat.values = catAttList;
    //             catList.add(cat);
    //             OfferingData.categories = catList;
    //         }
    //         // -- Ends Here
    //     }
    // }
    
    // //New Method : New enhancement in feed card - Categories
    // public static Set<String> getAllChildren(String parent, Integer level){
    //     Set<String> allChilds = new Set<String>();
    //     mapCategoryIdToSeq.put(parent,level);
    //     if(mapParentToChildFilterData.containsKey(parent) && mapParentToChildFilterData.get(parent).children != null && mapParentToChildFilterData.get(parent).children.size() > 0){
    //         for(String child : mapParentToChildFilterData.get(parent).children){
    //             allChilds.add(child);
    //             allChilds.addAll(getAllChildren(child, level+1));
    //         }
    //         return allChilds;
    //     }
    //     else{
    //         return new Set<String>{parent};
    //     }
        
    // }
    
    // public static Integer getFilterCount(Id parentId) {
        
    //     FilterData fltData = mapParentToChildFilterData.get(parentId);
        
    //     Integer count = 0;
    //     if(fltData == null || fltData.children.isEmpty()){
    //         count = 1;
    //         mapParentToChildFilterData.get(parentId).count = count;
    //     }else{
    //         for(String child : fltData.children){
    //             count+= getFilterCount(child);
    //             mapParentToChildFilterData.get(parentId).count = count;
    //         }
    //     }
    //     return count;
    // }
    public PMP_MarketplaceNewPartnerDetailFeed(){
    }
}