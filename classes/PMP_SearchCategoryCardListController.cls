public with sharing class PMP_SearchCategoryCardListController extends PMP_SearchWrapperStore{
    public PMP_SearchCategoryCardListController(){
        
    }
    
    // @AuraEnabled(cacheable=true)
    // public static List<Listing> getCategoryData(string SearchType, String langCode){	
        
    //     List<Listing> listings = new List<Listing>(); 
    //     List<PMP_Product_Categories_Images__mdt> metaDataList = new List<PMP_Product_Categories_Images__mdt>();
        
    //     List<PMP_Category__c> productCategories = new List<PMP_Category__c>();
    //     //Commented due to this condition is not working - check
    //     //if (!Schema.sObjectType.PMP_Category__c.isAccessible())
    //     //{
        
    //     try{
    //         productCategories = [SELECT  Name,PMP_Partner_Product_Category_Cd__c,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Parent_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_CATEGORY_ID
    //                              AND PMP_Active_Ind__c = true ORDER BY PMP_Category_Display_Sequence_Nbr__c];
    //         // system.debug('productCategories'+productCategories);
    //     }catch(Exception e){
    //         System.debug('Error in fetching Category objects records :' + e);
            
    //     }
    //     //}
    //     if(Schema.sObjectType.PMP_Product_Categories_Images__mdt.isAccessible()){
    //         metaDataList = [select URL__c,label,PIM_Category_Id__c from PMP_Product_Categories_Images__mdt where PIM_Category_Id__c != null];        
    //     }
        
    //     Map<String,String> metadataMap = new Map<String,String>();
    //     for(PMP_Product_Categories_Images__mdt md : metaDataList){
    //         metadataMap.put(md.PIM_Category_Id__c,md.URL__c);
    //     }
        
    //     for(PMP_Category__c cat : productCategories){
    //         SearchParams catPar = new SearchParams();
    //         catPar.cat = cat.Id;
    //         catPar.type = 'product';
            
    //         Listing catList = new Listing();
    //         catList.label = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
    //         // catList.imgUrl = 'https://intel--c.na74.content.force.com/servlet/servlet.ImageServer?id=0150n000000Esom&oid=00D0n000000D3l9&lastMod=1561973043000';
    //         try{
    //             // catList.imgUrl = [select URL__c,label,PIM_Category_Id__c from PMP_Product_Categories_Images__mdt where PIM_Category_Id__c =:cat.PMP_Partner_Product_Category_Cd__c].URL__c; 
    //             catList.imgUrl = metadataMap.get(cat.PMP_Partner_Product_Category_Cd__c); 
                
    //         }catch(Exception e){
    //             System.debug('Error in fetching PMP_Product_Categories_Images__mdt records :' + e);
    //             throw new AuraHandledException('Error in fetching PMP_Product_Categories_Images__mdt records :' + e);
    //         }
    //         catList.page = 'search';//'pmp-partner-offering-category';
    //         catList.searchParams = catPar;
    //         catList.isIcon=true;
            
    //         SearchType searchTy=new SearchType();
    //         searchTy.type='product';
            
    //         catList.SearchType=searchTy;
    //         listings.add(catList);
    //         // System.debug('listings'+listings);
            
            
    //     }
        
    //     return listings;
        
    // }
    // @AuraEnabled(cacheable=true)
    // public static List<Listing> getPartnerPrograms(String langCode){
        
    //     List<Listing> listings = new List<Listing>(); 
        
    //     List<PMP_SearchPartnerProgram_Config__mdt> ppList = new List<PMP_SearchPartnerProgram_Config__mdt>();
    //     if(Schema.sObjectType.PMP_SearchPartnerProgram_Config__mdt.isAccessible()){
    //         ppList = [SELECT Label,PMP_Partner_Program_Name__c,Active__c,  PMP_Partner_Program_value__c,
    //                   PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c
    //                   FROM PMP_SearchPartnerProgram_Config__mdt
    //                   where PMP_Partner_Program_Name__c != null
    //                   ORDER BY Label];
            
    //     }
        
    //     String partnerProgName = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Name',langCode);
    //     if(String.isEmpty(partnerProgName)){
    //         partnerProgName = 'PMP_Partner_Program_Name__c';
    //     }
    //     //Code to fetch URL of Tiles
    //     List<PMP_Tiles_Image_Url__mdt> urlList = new List<PMP_Tiles_Image_Url__mdt>();
    //     if(Schema.sObjectType.PMP_Tiles_Image_Url__mdt.isAccessible()){
    //         urlList = [SELECT PMP_Tile_Id__c,PMP_Url__c FROM PMP_Tiles_Image_Url__mdt WHERE PMP_Tile_Type__c = 'Intel Partner Directory'];
            
    //     }
    //     Map<String,String> urlMap = new Map<String,String>();
    //     for(PMP_Tiles_Image_Url__mdt tileUrl: urlList){
    //         urlMap.put(tileUrl.PMP_Tile_Id__c, tileUrl.PMP_Url__c);
    //     }
        
    //     List<PMP_Partner_Program__c> seoPpList =[SELECT id,Name, PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE];
        
    //     Map<String,String> ppIdValueMap = new Map<String, String>();
    //     Map<String,String> ppValueIdMap = new Map<String,String>();
    //     for(PMP_Partner_Program__c pp : seoPpList){
    //         ppIdValueMap.put(pp.Id, pp.PMP_Partner_Program_Value_Txt__c);
    //         ppValueIdMap.put(pp.PMP_Partner_Program_Value_Txt__c, pp.Id);
    //     }
    //     for(PMP_SearchPartnerProgram_Config__mdt pp : ppList){
    //         if(pp.PMP_Partner_Program_value__c != 'ODM-LOEM' && pp.PMP_Partner_Program_value__c !='ITP'){
    //             Listing program = new Listing();
    //             program.label = (String)pp.get(partnerProgName);
    //             if(String.isEmpty(program.label)){
    //                 program.label = pp.PMP_Partner_Program_Name__c;
    //             }
    //             program.page = 'search';
    //             program.searchParams = new SearchParams();
    //             program.isIcon=true;
                
    //             program.searchParams.PartnerProgram=ppValueIdMap.get(pp.PMP_Partner_Program_value__c);
    //             program.searchParams.cat=ppValueIdMap.get(pp.PMP_Partner_Program_value__c);
    //             // System.debug('program'+program);
    //             program.searchParams.type = PMP_StaticConstants_Partner.partner;
    //             if(urlMap.containsKey(pp.PMP_Partner_Program_value__c)){
    //                 program.imgUrl = urlMap.get(pp.PMP_Partner_Program_value__c);
    //             }
    //             SearchType searchTy=new SearchType();
    //             searchTy.type='partner';
    //             program.SearchType=searchTy;
                
    //             listings.add(program);
    //         }
            
    //     } 
        
        
    //     Listing odm = new Listing();
    //     odm.label = System.Label.PMP_Partner_Directory_title3;
    //     odm.page = 'search';
    //     odm.searchParams = new SearchParams();
    //     odm.isIcon=true;
    //     //odm.searchParams.cat = ppValueIdMap.get('ODM-LOEM');
    //     odm.searchParams.PartnerProgram=ppValueIdMap.get('ODM-LOEM');
    //     odm.searchParams.cat=ppValueIdMap.get('ODM-LOEM');
    //     odm.searchParams.type = PMP_StaticConstants_Partner.partner;
    //     if(urlMap.containsKey(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program.replace(' ','_'))){
    //         odm.imgUrl = urlMap.get(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program.replace(' ','_'));
    //     }
    //     listings.add(odm);
    //     return listings;
    //        }
}