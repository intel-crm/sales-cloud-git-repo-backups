/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_TaxonomyStore
* Description : Stores all logic to fetch the Taxonomy.
* Version     : 1.0 
* Created Date: 08-June-2020
* Modification Log :
* Created By  : Tanzanite Team (Infosys)
********************************************************************************************************************************************************************************************************/


public with sharing class PMP_TaxonomyStore extends PMP_SearchWrapperStore{
    
    /*static map of metadata for language localization
key will consist of 3 parts--> objectname|fieldName|locale , value will field name that needs to be referred for the particular langaue
Example for pmp_specifcation_value__c object --> key: "pmp_specifcation_value__c|Name|en_US" value: "Name"
key: "pmp_specifcation_value__c|Name|ja" value: "PMP_Specification_Value_Japanese_Cd__c" */
   // public static Map<string,string> localisedFieldName = New Map<string,string>();
    
    
    /*******************************************************************************************************************************************************************************************************
* Method Name : fetchTaxonomy
* Description : this method returns the Map<id,Taxonomy> i.e all the taxonomies that are used will combined here and result is sent to lwc components. this methods is called from service js in lwc components.
* Version     : 1.0 
* Created Date: 08-June-2020
* Modification Log :
* Created By  : Tanzanite Team (Infosys)
********************************************************************************************************************************************************************************************************/
    
//     @AuraEnabled(cacheable=true)
//     public static  Map<string,Taxonomy> fetchTaxonomy(String requestJSON){
//         Map<string,Taxonomy> completeTaxonomy = new Map<string,Taxonomy>();
//         Map<string,Taxonomy> response = new Map<string,Taxonomy>();        
//         try{ //error handling
//             System.debug('requestJSON in taxonomystore:'+requestJSON);
//             TaxonomyParams params = (TaxonomyParams)JSON.deserialize(requestJSON, TaxonomyParams.class);
//             String langCode=params.langCode;
//             List<PMP_Language_to_Field_API_Mapping__mdt> languageMetadata = New List<PMP_Language_to_Field_API_Mapping__mdt>();
//             languageMetadata = [Select PMP_Object_Nm__c, PMP_Field_Nm__c, PMP_Language_Cd__c, PMP_Field_APINm__c 
//                                 from PMP_Language_to_Field_API_Mapping__mdt];
//             for(PMP_Language_to_Field_API_Mapping__mdt meta : languageMetadata){
//                 localisedFieldName.put(meta.PMP_Object_Nm__c+'|'+meta.PMP_Field_Nm__c+'|'+meta.PMP_Language_Cd__c ,meta.PMP_Field_APINm__c );
//             }                   
//             //system.debug('lang--->'+params.langCode);
//             //converting to the right langage code
//             String userLanguage = langCode;
//             if(langCode == 'en-US'){
//                 userLanguage = 'en_US';
//             }else if(langCode == 'zh-Hans-CN' || langCode == 'zh-CN'){
//                 userLanguage = 'zh_CN';
//             }else if(langCode == 'ja' || langCode == 'jp'){
//                 userLanguage = 'ja';
//             }else {
//                 userLanguage = 'en_US';
//             }
           
//             system.debug('...request.baseTaxonomy'+params.baseTaxonomy);
            
//             /*Sooriya - Implementation of Platform Cache :START - US851334*/
            
//             //Language code for cache key,key should not contain special characters
//             String cacheLanguage = langCode != NULL ? langCode.replace('_', '').replace('-', '') : '';  
            
//             // Name of a partition and key
//             String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');     
            
//             //Get the flag from Custom Metadata
//             String cacheFlag = PMP_Utility.getValue('Taxonomy_CacheFlag');
            
//             //To prepare the cachekey
//             String cacheKey = ''; 
            
//             //return only base taxonomies at the beginning
//             if(params.baseTaxonomy){
                
//                 cacheKey = 'BaseTaxonomy'+cacheLanguage;
                
//                 //If taxonomy data is present in platform cache it will return from here
//                 if(Cache.Org.contains(partitionInput+'.'+cacheKey) && cacheFlag.equalsIgnoreCase('true')) {
//                     completeTaxonomy = (Map<string,Taxonomy>)Cache.Org.getPartition(partitionInput).get(cacheKey);
//                     if(completeTaxonomy.size()>0){
//                         return completeTaxonomy;
//                     }
//                 } 
//                 //If not in platform cache the below logic will return the data
//                 //40k fix: added by priyanka : start
//                 List<PMP_Company__c> partnerList= getActivePartners(); // get all the active partners
//                 List<PMP_Company__c> partnersWithRole = new List<PMP_Company__c>();// to list all partners with role
//                 List<PMP_Company__c> partnersWithSpecialty = new List<PMP_Company__c>();// to list all partners with country coverage
//                 List<PMP_Company__c> partnersWithSegment = new List<PMP_Company__c>();// to list all partners with country coverage
                
                
//                 //get the list of partners with role and with country coverage , so that they can be passed to respective methods , below for loop added as part of the fix for production l2 page load issue.
//                 for(PMP_Company__c partner: partnerList){
//                     if(partner.PMP_Partner_Program_nm__c!=NULL){
//                         partnersWithRole.add(partner);
//                     }
//                     if(partner.PMP_Account_Specialty__c!=NULL){
//                         partnersWithSpecialty.add(partner);
//                     }
//                     if(partner.PMP_Partner_Segment_Nm__c!=NULL){
//                         partnersWithSegment.add(partner);
//                     }
//                 }
//                 partnerList.clear();//clearing the list as the processing is done
//                 //40k fix: added by priyanka : end
                
                
//                 completeTaxonomy.putAll(getOfferingCategoryTaxonomy(langCode, 'offeringCategories'));//offeringCategories
//                 completeTaxonomy.putAll(getOfferingCategoryTaxonomy(langCode, 'offeringIndustries'));//offeringIndustries
//                 completeTaxonomy.putAll(getOfferingCategoryTaxonomy(langCode, 'offeringApplications'));//offeringApplications
//                 completeTaxonomy.putAll(getOfferingSegmentContextualFilters(langCode,'OfferingSegments'));
                
//                 completeTaxonomy.putAll(PMP_TaxonomyStore.getPartnerRoles(langCode,'PartnerDirectory', partnersWithRole)); //40k fix : added new parameter partnersWithRole
//                 partnersWithRole.clear();
                
//                 completeTaxonomy.putAll(PMP_TaxonomyStore.getpartnerSpecialties(langCode,'PartnerSpecialties',partnersWithSpecialty)); //40k fix : added new parameter partnersWithSpecialty
//                 partnersWithSpecialty.clear();
                
//                 completeTaxonomy.putAll(PMP_TaxonomyStore.getPartnerIndustries(langCode,'PartnerIndustries'));
                
//                 completeTaxonomy.putAll(PMP_TaxonomyStore.getPartnerSegmentFilters(langCode,'PartnerSegments',partnersWithSegment)); //40k fix : added new parameter partnersWithSegment
//                 partnersWithSegment.clear();
                
                
//                 //Adding the return value into platform cache
//                 try{
//                     String cacheTTLStr = PMP_Utility.getValue('Cache_TTL');
//                     Integer cacheTTL = Integer.valueOf(cacheTTLStr); // 48hrs
//                     if(cacheFlag.equalsIgnoreCase('true')){
//                         Cache.Org.put(partitionInput+'.'+cacheKey, completeTaxonomy,cacheTTL);  
//                     }
//                 }
//                 Catch(Cache.ItemSizeLimitExceededException error){
//                     System.debug('Error due to Item Size Exceeded::'+error.getMessage() +'at line '+error.getLineNumber());
//                 }Catch(Cache.Org.OrgCacheException error){ 
//                     System.debug('Error due to Partition Exception::'+error.getMessage() +'at line '+error.getLineNumber());
//                 }
                
//             } 
//             else{      
//                 completeTaxonomy.putAll(getPartnerContextualFilters(langCode,'PartnerA-Z'));// 27k fix: we are not considering the baic access benifit partners for Partner A-Z filter taxonomy
//                 completeTaxonomy.putAll(getMarketplaceEvents('IntelPartnerEvents','PMP_Marketplace_Event__c'));
//                 completeTaxonomy.putAll(getTechnicalSpecsTaxonomy(userLanguage));
//                 completeTaxonomy.putAll(PMP_TaxonomyStore.getPartnerApplications(langCode, 'PartnerApplications'));
//                 completeTaxonomy.putAll(PMP_TaxonomyStore.getPartnertierFilters(langCode,'PartnerTier'));
//                 completeTaxonomy.putAll(PMP_TaxonomyStore.getDistiBizOrg(langCode, 'Distributor'));
//                 completeTaxonomy.putAll(PMP_TaxonomyStore.getDistiComponents(langCode, 'DistributorComponents'));
//                 completeTaxonomy.putAll(PMP_TaxonomyStore.getDistiSysSolutions(langCode, 'DistributorSystems&Solutions'));
//                 completeTaxonomy.putAll(PMP_TaxonomyStore.getDistiCountries(langCode, 'Country'));
//                 completeTaxonomy.putAll(PMP_TaxonomyStore.getServicesProviderTypeRoles(langCode,'Solutions_Software_And_Services_Provider_Type'));
//             }
//         }
//         catch(Exception e){//error handling
//                 //PMP_Utility.logError(e,'PMP_TaxonomyStore'); 
//             throw e;
//         }
//         // System.debug('completeTaxonomy: added by priyanka'+completeTaxonomy);       
//         return completeTaxonomy;
        
//     }
    
     /*******************************************************************************************************************************************************************************************************
 * Method Name : getActivePartners
 * Description : this method returns all the active partners in the system.
 * Version     : 1.0 
 * Created Date: 18-Jan-2021
 * Modification Log :
 * Created By  : Onyx Team (Infosys)
 ********************************************************************************************************************************************************************************************************/
    public static List<PMP_Company__c> getActivePartners(){
        List<PMP_Company__c> partnerList= new List<PMP_Company__c>();
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
            
            partnerList=[SELECT Id ,name,PMP_Partner_Program_nm__c,PMP_Disti_Country_Coverage_Txt__c,PMP_Partner_Segment_Nm__c,
                         toLabel(PMP_Account_Specialty__c) from PMP_Company__c
                         WHERE PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published
                         AND PMP_Benefit_Update_Ind__c=False AND (PMP_Partner_Program_nm__c !=null OR PMP_Partner_Segment_Nm__c !=null
                                                                  OR PMP_Account_Specialty__c !=null)];   //Dont add any further filter conditions here
        }
        
        return partnerList;
    }
    
    
//     /*******************************************************************************************************************************************************************************************************
// * Method Name : getPartnerRoles
// * Description : this method returns the partner programs taxonomy as a result.
// * Version     : 1.0 
// * Created Date: 08-June-2020
// * Modification Log :
// * Created By  : Tanzanite Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
    
    
//     @AuraEnabled(cacheable=true)
//     public static Map<string,Taxonomy> getPartnerRoles(String langCode,String taxonomyName, List<PMP_Company__c> partners){
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>();
        
//         Taxonomy taxanomy= new Taxonomy();
//         taxanomy.name=taxonomyName;
//         taxanomy.apiName='PMP_Category__c';
//         taxanomy.label = System.Label.PMP_L0_Partner_Role;
//         taxanomy.englishLabel = System.Label.PMP_L0_Partner_Role_English; // // Added as part of TWC1824-3754
//         taxanomy.viewAllLabel = System.Label.PMP_L0_ViewAll_Partners;
//         taxanomy.svgIconUrl=null;
//         //taxanomy.filterDisplayType = 'large-data';
//         taxanomy.topLevelIds=new List<String>();
//         taxanomy.records=new Map<String,TaxonomyRecord>();
        
//         // List<PMP_SearchPartnerProgram_Config__mdt> ppList = new List<PMP_SearchPartnerProgram_Config__mdt>();
//         /* if(Schema.sObjectType.PMP_SearchPartnerProgram_Config__mdt.isAccessible()){
// ppList = [SELECT Label,PMP_Partner_Program_Name__c,Active__c,  PMP_Partner_Program_value__c,
// PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c,PMP_Partner_Program_Desc__c,
// PMP_Partner_Program_Desc_Chinese__c,PMP_Partner_Program_Desc_Japanese__c
// FROM PMP_SearchPartnerProgram_Config__mdt
// WHERE Active__c = true 
// ORDER BY Label];

// }
// //PMP_SearchUtilityNew.filterPartnersByRole();
// // System.debug('....PMP_SearchPartnerProgram_Config__mdt list......'+ppList);

// String partnerProgName = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Name',langCode);
// if(String.isEmpty(partnerProgName)){
// partnerProgName = 'PMP_Partner_Program_Name__c';
// }
// System.debug('....partnerProgName......'+partnerProgName);

// String partnerProgDescApi = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Description',langCode);
// system.debug('..partnerProgDescApi.'+partnerProgDescApi);
// if(String.isEmpty(partnerProgDescApi)){
// partnerProgDescApi = 'PMP_Partner_Program_Desc__c';
// }*/
        
        
//         //Code to fetch URL of Tiles
//         List<PMP_Tiles_Image_Url__mdt> urlList = new List<PMP_Tiles_Image_Url__mdt>();
//         if(Schema.sObjectType.PMP_Tiles_Image_Url__mdt.isAccessible()){
//             urlList = [SELECT PMP_Tile_Id__c,PMP_Url__c FROM PMP_Tiles_Image_Url__mdt WHERE PMP_Tile_Type__c = 'Intel Partner Directory'];
            
//         }
        
//         //System.debug('....urlList......'+urlList);
        
//         Map<String,String> urlMap = new Map<String,String>();
//         for(PMP_Tiles_Image_Url__mdt tileUrl: urlList){
//             urlMap.put(tileUrl.PMP_Tile_Id__c, tileUrl.PMP_Url__c);
//         }
        
//         //System.debug('....urlMap......'+urlMap);
//         List<PMP_Partner_Program__c> partnerRoleList= new List<PMP_Partner_Program__c>();
//         if(Schema.sObjectType.PMP_Partner_Program__c.isAccessible()){
//             partnerRoleList =[SELECT id,Name, PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c,PMP_Partner_Role_Parent_Id__c,PMP_Partner_Program_Desc_Chinese__c, 
//                               PMP_Partner_Program_Desc__c,PMP_Partner_Program_Desc_Japanese__c, PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c
//                               from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE ORDER BY Name];
//         }
//         //System.debug('....partnerRoleList  ......'+partnerRoleList);
        
//         /* Map<String,String> roleNameMap = new Map<String, String>();
// Map<String,String> roleDescriptionMap = new Map<String,String>();
// for(PMP_SearchPartnerProgram_Config__mdt pp : ppList){
// if((String)pp.get(partnerProgName)!=Null){
// roleNameMap.put(pp.PMP_Partner_Program_value__c,(String)pp.get(partnerProgName)); 
// }
// else{
// roleNameMap.put(pp.PMP_Partner_Program_value__c,pp.PMP_Partner_Program_value__c);
// }

// if((String)pp.get(partnerProgDescApi)!=Null){
// roleDescriptionMap.put(pp.PMP_Partner_Program_value__c, (String)pp.get(partnerProgDescApi));
// }
// else{
// roleDescriptionMap.put(pp.PMP_Partner_Program_value__c, pp.PMP_Partner_Program_Desc__c);
// }

// }*/
//         //40k fix: commented by priyanka
//         /*List<PMP_Company__c> partners = new List<PMP_Company__c>();
// if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){

// partners = [SELECT id , PMP_Partner_Program_nm__c from PMP_Company__c
// where PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published
// AND PMP_Benefit_Update_Ind__c=False
// AND PMP_Partner_Program_nm__c!= NULL];
// }*/
//         //40k fix: commented by priyanka - end
        
//         Set<String> finalRoles = new Set<String>();
//         //System.debug('.....roleNameMap.....'+roleNameMap);
//         //System.debug('.....roleDescriptionMap.....'+roleDescriptionMap);
        
//         //List<String> childRoles = new List<String>();
//         Map<String, List<String>> childRolesList = new Map<String, List<String>>();
//         for(PMP_Company__c partner : partners){
//             finalRoles.addAll(partner.PMP_Partner_Program_nm__c.split(';'));
//         }
        
//         List<String> childRoles = new List<String>();
//         for(PMP_Partner_Program__c role : partnerRoleList){
//             if(role.PMP_Partner_Role_Parent_Id__c!=null){
//                 childRoles.add(role.Id);
//             }
//         }
        
//         if(childRoles.size() > 0){
//             finalRoles.add('Solution, Software, and Service Providers');
//         }
        
//         Map<String, String> valueLabelMap = new Map<String,String>();
//         Integer featuredCount=0;
//         for(PMP_Partner_Program__c partnerRole : partnerRoleList){
            
//             if(partnerRole.PMP_Partner_Role_Parent_Id__c == NULL){
                
//                 if(finalRoles.contains(partnerRole.name)){
//                     boolean isFeatured=false;
//                     string icon=(String)urlMap.get(partnerRole.name);
//                     String parentId=partnerRole.PMP_Partner_Role_Parent_Id__c;
//                     List<String> children=new List<String>();
//                     String label=partnerRole.name;
//                     String roleDesc=null;
//                     if(parentId==null){
//                         taxanomy.topLevelIds.add(partnerRole.Id);  
//                         isFeatured=true;
//                     }
                    
                    
//                     /*      if(roleNameMap.containsKey(partnerRole.name)){
// label=roleNameMap.get(partnerRole.name);
// }
// if(roleDescriptionMap.containsKey(partnerRole.name)){
// roleDesc=roleDescriptionMap.get(partnerRole.name);
// }*/
//                     roleDesc=PMP_SearchUtilityController.getLocalisedName(partnerRole, PMP_StaticConstants_Partner.CAT_DESC_FIELD, langCode);
//                     label=PMP_SearchUtilityController.getLocalisedName(partnerRole, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
//                     String englishLabel=PMP_SearchUtilityController.getLocalisedName(partnerRole, PMP_StaticConstants_Partner.CAT_NAME_FIELD, PMP_StaticConstants_Partner.EN_US);  // Added as part of TWC1824-3754
//                     TaxonomyRecord taxonomyRecord= PMP_TaxonomyStore.getTaxonomyRecord(label,englishLabel,System.Label.PMP_ViewAll+' '+label,partnerRole.id,children,icon,parentId,taxonomyName,roleDesc,isFeatured);
                    
//                     //for disti partner roles
//                     List<SearchResultsGrouping> ResultsGroupings= New List<SearchResultsGrouping>();
                    
//                     if(taxonomyRecord.label== System.Label.PMP_L2_Distributor_Filter){             
//                         SearchResultsGrouping grouping1= new SearchResultsGrouping();
//                         grouping1.name='Intel Authorized Distributor';
//                         grouping1.heading=System.Label.PMP_Intel_Authorized_Distributor;
//                         grouping1.subheading=System.Label.PMP_Intel_Authorized_Distributor_Txt;
//                         ResultsGroupings.add(grouping1);
//                         SearchResultsGrouping grouping2= new SearchResultsGrouping();
//                         grouping2.name='Intel Approved Component Supplier';
//                         grouping2.heading=System.Label.PMP_Intel_Approved_Component_Supplier;
//                         grouping2.subheading=System.Label.PMP_Intel_Approved_Component_Supplier_Txt;
//                         ResultsGroupings.add(grouping2);
//                         SearchResultsGrouping grouping3= new SearchResultsGrouping();
//                         grouping3.name='Intel Approved Device Supplier';
//                         grouping3.heading=System.Label.PMP_Intel_Approved_Device_Supplier;
//                         grouping3.subheading=System.Label.PMP_Intel_Approved_Device_Supplier_Txt;
//                         ResultsGroupings.add(grouping3);
//                         taxonomyRecord.searchResultsGroupings=ResultsGroupings;
//                         taxonomyRecord.showCountryWarning = true;
//                         //default value of country filter  to USA is removed         
//                         //taxonomyRecord.defaultFilters= New Map<String, List<String>> {'Country' => New string[] {'USA'}}; 
                            
//                         //system.debug('countval'+taxonomyRecord.defaultFilters);
//                         //system.debug('ResultsGroupings'+ResultsGroupings);
//                         //system.debug('taxrecvalue'+taxonomyRecord); 
//                     }
                    
//                     taxanomy.records.put(taxonomyRecord.id,taxonomyRecord);  
//                 }
                
                
//             }
            
            
//         }
//         System.debug('.......Partner taxonomy............'+taxanomy);
//         //added to populate filter groupings
//         taxanomy.searchFiltersGroupings=new List<SearchFiltersGrouping>();
//         taxanomy.searchFiltersGroupings=fetchSearchFilterGroupings(taxanomy.name);
//         response.put(taxonomyName, taxanomy);
//         System.debug('.....response.....'+response);
//         return response;
//     }   
    
//     public static Map<String, Taxonomy> getServicesProviderTypeRoles(String langCode, String taxonomyName){
        
//         /* List<PMP_SearchPartnerProgram_Config__mdt> ppList = new List<PMP_SearchPartnerProgram_Config__mdt>();
// if(Schema.sObjectType.PMP_SearchPartnerProgram_Config__mdt.isAccessible()){
// ppList = [SELECT Label,PMP_Partner_Program_Name__c,Active__c,  PMP_Partner_Program_value__c,
// PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c,PMP_Partner_Program_Desc__c,
// PMP_Partner_Program_Desc_Chinese__c,PMP_Partner_Program_Desc_Japanese__c
// FROM PMP_SearchPartnerProgram_Config__mdt
// WHERE Active__c = true 
// ORDER BY Label];
// }*/
        
//         /* String partnerProgName = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Name',langCode);
// if(String.isEmpty(partnerProgName)){
// partnerProgName = 'PMP_Partner_Program_Name__c';
// }
// String partnerProgDescApi = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Description',langCode);
// if(String.isEmpty(partnerProgDescApi)){
// partnerProgDescApi = 'PMP_Partner_Program_Desc__c';
// }*/
//         /* Map<String,String> roleNameMap = new Map<String, String>();
// Map<String,String> roleDescriptionMap = new Map<String,String>();
// for(PMP_SearchPartnerProgram_Config__mdt pp : ppList){
// if((String)pp.get(partnerProgName)!=null){
// roleNameMap.put(pp.PMP_Partner_Program_value__c,(String)pp.get(partnerProgName));
// }
// else{
// roleNameMap.put(pp.PMP_Partner_Program_value__c,(String)pp.get('PMP_Partner_Program_Name__c'));
// }
// if((String)pp.get(partnerProgDescApi)!=null){
// roleDescriptionMap.put(pp.PMP_Partner_Program_value__c, (String)pp.get(partnerProgDescApi));
// }
// else{
// roleDescriptionMap.put(pp.PMP_Partner_Program_value__c,(String)pp.get('PMP_Partner_Program_Desc__c'));
// }

// }*/
//         /* 27k fix: commented by Priyanka 
// List<PMP_Company__c> partners = new  List<PMP_Company__c>();
// if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){

// partners = [SELECT id , PMP_Partner_Program_nm__c from PMP_Company__c
// where PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published
// AND PMP_Benefit_Update_Ind__c=False
// AND PMP_Partner_Program_nm__c!= NULL];
// }
// Set<String> finalRoles = new Set<String>();
// for(PMP_Company__c partner : partners){
// finalRoles.addAll(partner.PMP_Partner_Program_nm__c.split(';'));
// }
// */ 
//         // 27k fix end 
//         List<PMP_Partner_Program__c> partnerRoleList= new List<PMP_Partner_Program__c>();
//         if(Schema.sObjectType.PMP_Partner_Program__c.isAccessible()){
            
//             partnerRoleList =[SELECT id,Name, PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c,PMP_Partner_Role_Parent_Id__c, PMP_Partner_Role_Parent_Id__r.Name,
//                               PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c, PMP_Partner_Program_Desc__c, PMP_Partner_Program_Desc_Chinese__c, PMP_Partner_Program_Desc_Japanese__c 
//                               from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE AND PMP_Partner_Role_Parent_Id__c!=null 
//                               ORDER BY Name]; // 27k fix : AND PMP_Partner_Program_Value_Txt__c IN :finalRoles is removed from the query
//         }
//         Map<String,Taxonomy> response= new Map<string,Taxonomy>();
        
//         Taxonomy taxonomy= new Taxonomy();
//         taxonomy.name=taxonomyName;
//         taxonomy.apiName='PMP_Partner_Program__c';
//         taxonomy.expandByDefault=true;
//         if(partnerRoleList.size() > 0){
//             //taxonomy.label = partnerRoleList[0].PMP_Partner_Role_Parent_Id__r.Name;
//             taxonomy.label= System.Label.PMP_Solution_Software_and_Service_Provider_Types_Contextual_Filter;//'Solution, Software and Service Provider Types';
//             taxonomy.englishLabel = System.Label.PMP_Solution_Software_and_Service_Provider_Types_Contextual_Filter_English; // Added as part of TWC1824-3754
//         }
        
//         //System.Label.PMP_L0_Partner_Role;
//         //taxonomy.viewAllLabel = 'Solutions, Software and Services Provider Type';// we may have to create the label for this
//         taxonomy.svgIconUrl=null;
//         //taxanomy.filterDisplayType = 'large-data';
//         taxonomy.topLevelIds=new List<String>();
//         taxonomy.records=new Map<String,TaxonomyRecord>();
        
//         for(PMP_Partner_Program__c role:partnerRoleList){
//             TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
//             taxonomyRecord.viewAllLabel='';
//             taxonomyRecord.label='';
//             taxonomyRecord.id=role.Id;
//             taxonomyRecord.children=new List<String>();
//             taxonomyRecord.svgIconUrl='';
            
//             taxonomyRecord.taxonomy=taxonomyName;
//             taxonomyRecord.description=PMP_SearchUtilityController.getLocalisedName(role, PMP_StaticConstants_Partner.CAT_DESC_FIELD, langCode);
//             taxonomyRecord.label=PMP_SearchUtilityController.getLocalisedName(role, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
//             taxonomyRecord.englishLabel=PMP_SearchUtilityController.getLocalisedName(role, PMP_StaticConstants_Partner.CAT_NAME_FIELD, PMP_StaticConstants_Partner.EN_US); // Added as part of TWC1824-3754


            
            
//             /*taxonomyRecord.description='';      
// if(roleNameMap.containsKey(role.PMP_Partner_Program_Value_Txt__c)){
// taxonomyRecord.label =roleNameMap.get(role.PMP_Partner_Program_Value_Txt__c);

// }
// if(roleDescriptionMap.containsKey(role.PMP_Partner_Program_Value_Txt__c)){
// taxonomyRecord.description=roleDescriptionMap.get(role.PMP_Partner_Program_Value_Txt__c);
// }*/
            
//             taxonomy.records.put(taxonomyRecord.Id,taxonomyRecord);
//         }
//         response.put(taxonomy.name,taxonomy);
//         return response;
//     }
//     /*******************************************************************************************************************************************************************************************************
// * Method Name : getpartnerSpecialties
// * Description : this method returns the partner specialities taxonomy as a result.
// * Version     : 1.0 
// * Created Date: 08-June-2020
// * Modification Log :
// * Created By  : Tanzanite Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
//     @AuraEnabled(cacheable=true)
//     public static Map<string,Taxonomy> getpartnerSpecialties(String langCode,String taxonomyName,List<PMP_Company__c> partners){
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>();
//         Taxonomy taxanomy= new Taxonomy();
//         taxanomy.name=taxonomyName;
//         taxanomy.apiName='PMP_Partner_Specialty__c';//PMP_Partner_Specialty__c
//         taxanomy.label = System.Label.PMP_L0_Partners_Specialty; 
//         taxanomy.englishLabel = System.Label.PMP_L0_Partners_Specialty_English; // Added as part of TWC1824-3754
//         taxanomy.viewAllLabel = System.Label.PMP_L0_ViewAll_Specialty;
//         taxanomy.svgIconUrl=null;
//         taxanomy.topLevelIds=new List<String>();
//         taxanomy.records=new Map<String,TaxonomyRecord>();
        
//         List<PMP_Specialty_Images__mdt> metaDataList = new List<PMP_Specialty_Images__mdt>();
//         metaDataList = [select PMP_Account_Specialty_Name__c,PMP_Specialty_Name_Chinese__c,PMP_Specialty_Name_Japanese__c, URL__c from PMP_Specialty_Images__mdt];
//         Map<String,String> metadataMap = new Map<String,String>();
//         for(PMP_Specialty_Images__mdt md: metaDataList){
//             metadataMap.put(md.PMP_Account_Specialty_Name__c, md.URL__c);
//         }
//         List<PMP_Partner_Specialty__c> specialtyList= new List<PMP_Partner_Specialty__c>();
//         if(Schema.sObjectType.PMP_Partner_Specialty__c.isAccessible()){
//             specialtyList = [SELECT name,PMP_Partner_Specialty_Chinese_Nm__c, PMP_Partner_Specialty_Japanese_Nm__c, Id, PMP_Partner_Specialty_Chinese_Dsc__c, PMP_Partner_Specialty_English_Dsc__c, PMP_Partner_Specialty_Japanese_Dsc__c, PMP_Is_Active_Ind__c FROM PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE order by name];
//         }
//         //40k fix: commented by priyanka
//         /*List<PMP_Company__c> partners = new  List<PMP_Company__c>();
// if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){

// partners = [select toLabel(PMP_Account_Specialty__c) from PMP_Company__c where PMP_Account_Specialty__c != null AND PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published AND PMP_Benefit_Update_Ind__c=false];
// }*/
//         //40k fix: commented by priyanka end 
        
//         // system.debug('....partners.....'+partners);    
//         List<String> accountSpecilaities= new List<String>();
//         for(PMP_Company__C c: partners){
//             accountSpecilaities.addAll(c.PMP_Account_Specialty__c.split(';'));
//         }
        
//         //system.debug('...account specialties.....'+accountSpecilaities);
//         String specialtyDesc = PMP_SearchUtilityController.getFieldApiName('PMP_Partner_Specialty__c', 'Description (English)',langCode);
//         if(String.isEmpty(specialtyDesc)){
//             specialtyDesc = 'PMP_Partner_Specialty_English_Dsc__c';
//         }
        
//         String specialtyName = PMP_SearchUtilityController.getFieldApiName('PMP_Partner_Specialty__c', 'Name',langCode);
//         if(String.isEmpty(specialtyName)){
//             specialtyName = 'Name';
//         }
//         //Learn More URL Logic for Specialty Learnmore link
//         String learnMoreUrlAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Learn_More_URL__mdt', 'URL', langCode);
//         if(String.isEmpty(learnMoreUrlAPI)){
//             learnMoreUrlAPI = 'PMP_Learn_More_English_Url__c';
//         }  
//         Map<String,String> learnMoreUrlMap = new Map<String,String>();        
//         // To get all Specialty names from Metadata
//         List<PMP_Learn_More_URL__mdt> learnMoreUrls=[select Label,isSpecialty__c,PMP_Learn_More_English_Url__c,PMP_Learn_More_Chinese_Url__c,PMP_Learn_More_Japanese_Url__c from PMP_Learn_More_URL__mdt where isSpecialty__c=True];   
//         for (PMP_Learn_More_URL__mdt learnMoreUrl:learnMoreUrls){
//             learnMoreUrlMap.put(learnMoreUrl.Label, (String)learnMoreUrl.get(learnMoreUrlAPI));            
//         }
        
//         integer featuredCount=0;
//         for(PMP_Partner_Specialty__c md : specialtyList){
            
//             if(accountSpecilaities.contains((String)md.get(specialtyName)))
//             {
//                 boolean isFeatured=false;
//                 if (featuredCount<5){
//                     isFeatured=true;
//                     featuredCount++;
//                 }
//                 taxanomy.topLevelIds.add(md.Id);
//                 TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
//                 String label=(String)md.get(specialtyName);
//                 String description=(String)md.get(specialtyDesc);
//                 List<String> children=new List<String>();
//                 taxonomyRecord= PMP_TaxonomyStore.getTaxonomyRecord(label,md.name,'view all '+label,md.id,children,(string)metadataMap.get(md.name),null,taxonomyName,description,isFeatured); // modified as part of TWC1824-3754
                
//                 if(learnMoreUrlMap.containsKey(md.name)){
//                     taxonomyRecord.learnMoreUrl = learnMoreUrlMap.get(md.name);
//                 }
//                 // system.debug(':::taxonomyRecord::'+taxonomyRecord);
                
//                 taxanomy.records.put(md.id,taxonomyRecord);
//             }   
            
//         }
        
//         //added to populate filter groupings
//         taxanomy.searchFiltersGroupings=new List<SearchFiltersGrouping>();
//         taxanomy.searchFiltersGroupings=fetchSearchFilterGroupings(taxanomy.name);
        
//         response.put(taxonomyName,taxanomy);
//         System.debug('.....response.....'+response);
//         return response;
        
//     }
    
    
//     public static Map<String, Taxonomy> getPartnerApplications(String langCode, String taxonomyName){
        
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>();
//         Taxonomy taxanomy= new Taxonomy();
//         taxanomy.name=taxonomyName;
//         taxanomy.apiName='PMP_Category__c';
//         taxanomy.label = System.Label.PMP_Partners_by_Application;//'Partners by Application';
//         taxanomy.englishLabel = System.Label.PMP_Partners_by_Application_English; // Added as part of TWC1824-3754
//         //taxanomy.viewAllLabel = System.Label.PMP_L0_ViewAll_PartnerIndustry;
//         taxanomy.svgIconUrl=null;
//         taxanomy.topLevelIds=new List<String>();
//         taxanomy.records=new Map<String,TaxonomyRecord>();
//         List<PMP_Category__c> childrenCategories=new List<PMP_Category__c>();
        
//         List<PMP_Category__c> industries=new List<PMP_Category__c>();
//         for (PMP_Category__c c:[ select id , Name, PMP_Ancestor_Category_Cd__c,PMP_Parent_Category_Id__c,PMP_Ancestor_Category_Nm__c, PMP_Partner_Product_Category_Cd__c, PMP_Partner_Offering_Category_Dsc__c,
//                                 PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,
//                                 (SELECT PMP_Category_Id__c FROM Partner_Industry_Applications__r WHERE
//                                  PMP_Partner_Id__r.PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published AND
//                                  PMP_Partner_Id__r.PMP_Benefit_Update_Ind__c=False limit 1)
//                                 from PMP_Category__c where PMP_Ancestor_Category_Cd__c like '%NPP_01_APP%' order by Name]){
//                                     system.debug('..c..'+c);
//                                     if(c.Partner_Industry_Applications__r.size()>0)
//                                     {
//                                         industries.add(c);
                                        
//                                     }
//                                 }        
        
//         //Map to store shadow id for SEO
//         Map<Id, Id> shadowIdMap = new Map<Id, Id> (); 
//         for(PMP_Category_Partner__c shadowrecord :[select Id, Name, PMP_Category_Id__c from PMP_Category_Partner__c ]){
//             shadowIdMap.put(shadowrecord.PMP_Category_Id__c,shadowrecord.Id);
//         }
        
//         Map<String, TaxonomyRecord> catTaxMap = new Map<String, TaxonomyRecord>();        
        
//         for(PMP_Category__c md:industries){
            
//             Boolean isFeatured=false;
//             List<String> children= new List<String>();
//             String parentId=null;
            
//             if(PMP_StaticConstants_Partner.industryTopLevelList.contains(md.PMP_Partner_Product_Category_Cd__c)){
                
//                 isFeatured=true;
//             }
            
//             if(md.PMP_Ancestor_Category_Cd__c =='NPP_01_APP'){
//                 taxanomy.topLevelIds.add(shadowIdMap.get(md.id));
//             }else{
//                 parentId=md.PMP_Parent_Category_Id__c;
//             }
            
            
            
//             String label=PMP_SearchUtilityController.getLocalisedName(md, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
//             String englishLabel=PMP_SearchUtilityController.getLocalisedName(md, PMP_StaticConstants_Partner.CAT_NAME_FIELD, PMP_StaticConstants_Partner.EN_US);// Added as part of TWC1824-3754
            
//             TaxonomyRecord taxonomyRecord= PMP_TaxonomyStore.getTaxonomyRecord(label,englishLabel,'View all '+label,shadowIdMap.get(md.id),children,null,shadowIdMap.get(parentId),taxonomyName,'',isFeatured); // Modified as part of TWC1824-3754
//             catTaxMap.put(shadowIdMap.get(md.Id), taxonomyRecord);
//             system.debug('taxonomyrecord'+taxonomyRecord);
//         }
        
//         for(TaxonomyRecord tax : catTaxMap.values()){
//             if(catTaxMap.containsKey(tax.parentId) && tax.parentId!=null){
//                 catTaxMap.get(tax.parentId).children.add(tax.Id);
//             }
//         }
        
//         taxanomy.records = catTaxMap;
        
//         //added to populate filter groupings
//         //taxanomy.searchFiltersGroupings=new List<SearchFiltersGrouping>();
//         //taxanomy.searchFiltersGroupings=fetchSearchFilterGroupings(taxanomy.name);
        
//         response.put(taxonomyName,taxanomy);
//         System.debug('.....response.....'+response);
//         return response;
        
        
//     }
    
//     /*******************************************************************************************************************************************************************************************************
// * Method Name : getPartnerIndustries
// * Description : this method returns the partner industried taxonomy as a result.
// * Version     : 1.0 
// * Created Date: 08-June-2020
// * Modification Log :
// * Created By  : Tanzanite Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
//     @AuraEnabled(cacheable=true)
//     public static Map<string,Taxonomy> getPartnerIndustries(String langCode,String taxonomyName){
//         system.debug('Language in industries : '  + langCode);
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>();
//         Taxonomy taxanomy= new Taxonomy();
//         taxanomy.name=taxonomyName;
//         taxanomy.apiName='PMP_Category__c';
//         taxanomy.label = System.Label.PMP_L0_Partners_Industry;
//         taxanomy.englishLabel = System.Label.PMP_L0_Partners_Industry_English; // Added as part of TWC1824-3754
//         taxanomy.viewAllLabel = System.Label.PMP_L0_ViewAll_PartnerIndustry;
//         taxanomy.svgIconUrl=null;
//         taxanomy.topLevelIds=new List<String>();
//         taxanomy.records=new Map<String,TaxonomyRecord>();
//         List<PMP_Category__c> childrenCategories=new List<PMP_Category__c>();
        
//         List<PMP_Category__c> industries=new List<PMP_Category__c>();
//         for (PMP_Category__c c:[ select id , Name, PMP_Ancestor_Category_Cd__c,PMP_Parent_Category_Id__c,PMP_Ancestor_Category_Nm__c, PMP_Partner_Product_Category_Cd__c, PMP_Partner_Offering_Category_Dsc__c,
//                                 PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,
//                                 (SELECT PMP_Category_Id__c FROM Partner_Industry_Applications__r WHERE
//                                  PMP_Partner_Id__r.PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published AND
//                                  PMP_Partner_Id__r.PMP_Benefit_Update_Ind__c=False limit 1)
//                                 from PMP_Category__c where PMP_Ancestor_Category_Cd__c like '%NPP_01_Industry%' order by Name]){
//                                     system.debug('..c..'+c);
//                                     if(c.Partner_Industry_Applications__r.size()>0)
//                                     {
//                                         industries.add(c);
                                        
//                                     }
//                                 }        
        
//         //Map to store shadow id for SEO
//         Map<Id, Id> shadowIdMap = new Map<Id, Id> (); 
//         for(PMP_Category_Partner__c shadowrecord :[select Id, Name, PMP_Category_Id__c from PMP_Category_Partner__c ]){
//             shadowIdMap.put(shadowrecord.PMP_Category_Id__c,shadowrecord.Id);
//         }
        
//         Map<String, TaxonomyRecord> catTaxMap = new Map<String, TaxonomyRecord>();        
        
//         for(PMP_Category__c md:industries){
            
//             Boolean isFeatured=false;
//             List<String> children= new List<String>();
//             String parentId=null;
            
//             if(PMP_StaticConstants_Partner.industryTopLevelList.contains(md.PMP_Partner_Product_Category_Cd__c)){
                
//                 isFeatured=true;
//             }
            
//             if(md.PMP_Ancestor_Category_Cd__c =='NPP_01_Industry'){
//                 taxanomy.topLevelIds.add(shadowIdMap.get(md.id));
//             }else{
//                 parentId=md.PMP_Parent_Category_Id__c;
//             }
            
            
            
//             String label=PMP_SearchUtilityController.getLocalisedName(md, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
//             String englishLabel=PMP_SearchUtilityController.getLocalisedName(md, PMP_StaticConstants_Partner.CAT_NAME_FIELD, PMP_StaticConstants_Partner.EN_US); // Added as part of TWC1824-3754

            
//             String descript =  PMP_Utility.getReplacedWithDynamicValue( System.Label.PMP_Partner_Industry_Desc, label);
            
//             TaxonomyRecord taxonomyRecord= PMP_TaxonomyStore.getTaxonomyRecord(label,englishLabel,'View all '+label,shadowIdMap.get(md.id),children,null,shadowIdMap.get(parentId),taxonomyName,descript,isFeatured);
//             catTaxMap.put(shadowIdMap.get(md.Id), taxonomyRecord);
//             system.debug('taxonomyrecord'+taxonomyRecord);
//         }
        
//         System.debug('..catTaxMap at the end..'+catTaxMap);
//         for(TaxonomyRecord tax : catTaxMap.values()){
//             if(catTaxMap.containsKey(tax.parentId) && tax.parentId!=null){
//                 catTaxMap.get(tax.parentId).children.add(tax.Id);
//             }
//         }
        
//         taxanomy.records = catTaxMap;
        
//         //added to populate filter groupings
//         taxanomy.searchFiltersGroupings=new List<SearchFiltersGrouping>();
//         taxanomy.searchFiltersGroupings=fetchSearchFilterGroupings(taxanomy.name);
        
//         response.put(taxonomyName,taxanomy);
//         System.debug('.....response.....'+response);
//         return response;
//     } 
    
    
//     /*******************************************************************************************************************************************************************************************************
// * Class Name  : PMP_TaxonomyStore
// * Method Name : getOfferingCategoryTaxonomy
// * Description : this method returns the offering categories/offering application/offering industries taxonomy as a result.
// * Version     : 1.0 
// * Created Date: 08-June-2020
// * Modification Log :
// * Created By  : Tanzanite Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
    
//     public static Map<String,Taxonomy> getOfferingCategoryTaxonomy(String langcode, String section){
        
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>();
        
//         Taxonomy taxanomy = new Taxonomy();
//         taxanomy.name = PMP_StaticConstants_Partner.taxonomyLabelMapNew.get(section);
//         taxanomy.apiName ='PMP_Category__c';
//         taxanomy.label = PMP_StaticConstants_Partner.taxonomyLabelMap.get(section);
//         taxanomy.englishLabel = PMP_StaticConstants_Partner.taxonomyLabelEnglishMap.get(section); // Added as part of TWC1824-3754
//         taxanomy.viewAllLabel = PMP_StaticConstants_Partner.taxonomyCtaLabelMap.get(section);
//         taxanomy.svgIconUrl = null;
//         taxanomy.topLevelIds = new List<String>();
//         taxanomy.records=new Map<String,TaxonomyRecord>();
//         if(section=='offeringCategories'){
//             taxanomy.filterDisplayType='large-data'; }
        
//         // taxanomy.records=new Map<id,TaxonomyRecord>();
//         //Learn More URL Logic
//         String learnMoreUrlAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Learn_More_URL__mdt', 'URL', langCode);
//         if(String.isEmpty(learnMoreUrlAPI)){
//             learnMoreUrlAPI = 'PMP_Learn_More_English_Url__c';
//         }
//         Map<String,String> learnMoreUrlMap = new Map<String,String>();        
//         // To get all featured category Pim Ids
//         for (PMP_Learn_More_URL__mdt learnMoreUrls:[select PMP_PIM_Category_Id__c,PMP_Learn_More_English_Url__c,PMP_Learn_More_Chinese_Url__c,PMP_Learn_More_Japanese_Url__c from PMP_Learn_More_URL__mdt ]){
//             learnMoreUrlMap.put(learnMoreUrls.PMP_PIM_Category_Id__c, (String)learnMoreUrls.get(learnMoreUrlAPI));
//         }
        
//         Map<String, Taxonomy> specTaxonomyMap = new Map<String, Taxonomy>();
//         specTaxonomyMap.put(section, taxanomy);
//         List<PMP_Category__c> productCategories = new List<PMP_Category__c>();
//         List<PMP_Product_Categories_Images__mdt> metaDataList = new List<PMP_Product_Categories_Images__mdt>();
//         Map<String,String> metadataMap = new Map<String,String>();
        
//         String pimId = PMP_StaticConstants_Partner.taxonomyPimIdMap.get(section);
//         pimId = '%' + pimId + '%';
//         System.debug('pimId - Prod Issue: '+pimId);
        
//         Map<String, TaxonomyRecord> specTaxRecordMap = new Map<String, TaxonomyRecord>();
//         Map<String, TaxonomyRecord> finalMap = new Map<String, TaxonomyRecord>();
        
//         try{
//             // if(PMP_Category__c.SObjectType.getDescribe().isAccessible()){
            
//             productCategories = [SELECT id, Name, PMP_Partner_Product_Category_Cd__c,
//                                  PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Parent_Category_Cd__c,
//                                  PMP_Parent_Category_Id__c,PMP_Partner_Offering_Category_Dsc__c,PMP_Category_Chinese_Dsc__c,PMP_Category_Japanese_Dsc__c,
//                                  (SELECT id from Offering_Categories__r
//                                   where PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published AND PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = FALSE
//                                   AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY AND PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY AND
//                                   PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Benefit_Update_Ind__c=False limit 1)
//                                  from PMP_Category__c
//                                  where PMP_Active_Ind__c = true AND PMP_Ancestor_Category_Cd__c like :pimId 
//                                  ORDER BY Name];
//             // }
            
//             metaDataList = [select URL__c,label,PIM_Category_Id__c from PMP_Product_Categories_Images__mdt ]; 
            
//             List<PMP_Category__c> finalList = new List<PMP_Category__c>();
            
//             for(PMP_Category__c cat: productCategories){
//                 if(cat.Offering_Categories__r.size() > 0){
//                     finalList.add(cat);
//                 }
//             }
//             for(PMP_Product_Categories_Images__mdt md : metaDataList){
//                 metadataMap.put(md.PIM_Category_Id__c,md.URL__c);
//             }
//             system.debug('catlist size : ' + finalList.size());
//             for(PMP_Category__c cat : finalList){
//                 System.debug('cat.PMP_Partner_Product_Parent_Category_Cd__c --> PROD Issue'+cat.PMP_Partner_Product_Parent_Category_Cd__c);
//                 TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
//                 if(cat.PMP_Partner_Product_Parent_Category_Cd__c == PMP_StaticConstants_Partner.taxonomyPimIdMap.get(section)){
//                     taxanomy.topLevelIds.add(cat.Id);
//                 }else{
//                     taxonomyRecord.parentId= cat.PMP_Parent_Category_Id__c;
//                 }
                
                
//                 taxonomyRecord.label = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
//                 taxonomyRecord.englishLabel = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, PMP_StaticConstants_Partner.EN_US); // Added as part of TWC1824-3754
//                 //Add getLoacalized logic for aggregate results;
//                 taxonomyRecord.viewAllLabel = System.Label.PMP_ViewAll + ' ' + (taxonomyRecord.label).toLowercase();
//                 taxonomyRecord.id=cat.id;
                
//                 //copy deck changes                
//                 if(section == 'offeringCategories'){
//                     taxonomyRecord.description = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, langCode);                    
//                 }               
//                 else{
//                     taxonomyRecord.description =System.Label.PMP_L2_Offering_Marquee_Subtitle +' '+ PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
//                 }
                
//                 if(String.isBlank(taxonomyRecord.description)) {
//                     String des = System.Label.PMP_L2_Offering_Marquee_Subtitle +' '+ PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode); 
//                     taxonomyRecord.description = des + ' ' + (section == 'offeringCategories' ? (System.Label.PMP_CreateOffering_Solutions).toLowercase() : '');
//                 }
                
//                 taxonomyRecord.children= new List<String>();
//                 taxonomyRecord.svgIconUrl = metadataMap.get(cat.PMP_Partner_Product_Category_Cd__c);
                
//                 taxonomyRecord.taxonomy = taxanomy.name;
                
//                 if(PMP_StaticConstants_Partner.taxonomyTopLevelListMap.get(section).contains(cat.PMP_Partner_Product_Category_Cd__c)){
//                     taxonomyRecord.featured = true;
//                 }else{
//                     taxonomyRecord.featured = false;
//                 }
                
//                 specTaxRecordMap.put(cat.id,taxonomyRecord);
                
//                 if(learnMoreUrlMap.containsKey(cat.PMP_Partner_Product_Category_Cd__c)){
//                     taxonomyRecord.learnMoreUrl = learnMoreUrlMap.get(cat.PMP_Partner_Product_Category_Cd__c);
//                 }
                
                
//             }
//              for(TaxonomyRecord tax : specTaxRecordMap.values()){
//                 if(specTaxRecordMap.containsKey(tax.parentId) && tax.parentId!=null){
//                     specTaxRecordMap.get(tax.parentId).children.add(tax.Id);
                    
//                 }
                
//             }
//             system.debug('map sepc tac 2 : ' + specTaxRecordMap.values());
//             taxanomy.records = specTaxRecordMap;
            
//         }catch(Exception e){
//             System.debug('Error in fetching Offering by Category records :' + e);
//             throw e;//error handling 
            
//         }
//         System.debug('response :' + response);
        
//         //added to populate filter groupings
//         // taxanomy.searchFiltersGroupings=new List<SearchFiltersGrouping>();
//         //taxanomy.searchFiltersGroupings=fetchSearchFilterGroupings('offeringApplications');
        
//         //added to populate filter groupings
//         taxanomy.searchFiltersGroupings=new List<SearchFiltersGrouping>();
//         taxanomy.searchFiltersGroupings=fetchSearchFilterGroupings(taxanomy.name);
        
//         response.put(taxanomy.name, taxanomy);
//         System.debug('response from method'+response);
        
//         return response;
//     }
    
    
//     /*******************************************************************************************************************************************************************************************************
// * Class Name  : PMP_TaxonomyStore
// * Method Name : getPartnerContextualFilters
// * Description : this method returns the partner contextual filter taxonomy as a result.
// * Version     : 1.0 
// * Created Date: 24-June-2020
// * Modification Log :
// * Created By  : Tanzanite Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
//     public static Map<String,Taxonomy> getPartnerContextualFilters(String langCode, String taxonomyName){
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>();
//         Taxonomy taxanomy= new Taxonomy();
//         taxanomy.name=taxonomyName;
//         taxanomy.apiName='PMP_Company__c';
//         taxanomy.label=System.Label.PMP_L2_Filter_Partner_A_To_Z;
//         taxanomy.englishLabel = System.Label.PMP_L2_Filter_Partner_A_To_Z_English; // Added as part of TWC1824-3754
//         taxanomy.viewAllLabel=System.Label.PMP_L2_View_all_Partner_Contextual_Filters;
//         taxanomy.svgIconUrl=null;
//         taxanomy.topLevelIds=new List<String>();
//         taxanomy.records=new Map<String,TaxonomyRecord>();
//         taxanomy.filterDisplayType='partner-list';
//         // 27k fix : added the condition 'and PMP_Partner_Benefit_Type__c !='Solution Marketplace Basic Access' to the below query
//         for(PMP_Company__c partner:[SELECT Id,Name FROM PMP_Company__c where   
//                                     PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published AND PMP_Benefit_Update_Ind__c=False and PMP_Partner_Benefit_Type__c !='Solution Marketplace Basic Access']){
//                                         TaxonomyRecord taxonomyRecord= PMP_TaxonomyStore.getTaxonomyRecord(partner.Name,partner.Name,'view all Label',partner.id,new List<String>(),null,null,taxonomyName,partner.Name,false); //Modified as part of TWC1824-3754
//                                         taxanomy.records.put(partner.id,taxonomyRecord);
//                                         taxanomy.topLevelIds.add(partner.id);
//                                     }
//         response.put(taxonomyName,taxanomy);
//         system.debug('.....response.....'+response);
//         return response;
//     } 
    
    
//     /*******************************************************************************************************************************************************************************************************
// * Class Name  : PMP_TaxonomyStore
// * Method Name : getOfferingSegmentContextualFilters
// * Description : this method returns the offering segment contextual filter taxonomy as a result.
// * Version     : 1.0 
// * Created Date: 24-June-2020
// * Modification Log :
// * Created By  : Tanzanite Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
    
//     public static Map<String,Taxonomy> getOfferingSegmentContextualFilters(String langCode, String taxonomyName){
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>();
//         Taxonomy taxonomy= new Taxonomy();
//         taxonomy.name=taxonomyName;
//         taxonomy.apiName='PMP_Partner_Segment__c';
//         taxonomy.label=System.Label.PMP_L2_Offering_Segment;
//         taxonomy.englishLabel = System.Label.PMP_L2_Offering_Segment_English; // Added as part of TWC1824-3754
//         taxonomy.viewAllLabel='View all Offering Segment Filters';
//         taxonomy.svgIconUrl=null;
//         taxonomy.topLevelIds=new List<String>();
//         taxonomy.records=new Map<String,TaxonomyRecord>();
//         Map<String,String> valueLabelMap = new Map<String,String>();
//         Schema.DescribeFieldResult fieldResult = PMP_Partner_Offering__c.PMP_Business_Segment_Nm__c.getDescribe();      
//         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
//         for( Schema.PicklistEntry pickListVal : ple){
//             valueLabelMap.put(pickListVal.getValue(),pickListVal.getLabel());
//         }
        
//         for(String segmentFilter:valueLabelMap.keyset()){
//             System.debug('..inside far loop..'+segmentFilter);
//             TaxonomyRecord taxonomyRecord= PMP_TaxonomyStore.getTaxonomyRecord(valueLabelMap.get(segmentFilter),segmentFilter,'view all Label',segmentFilter,new List<String>(),null,null,taxonomyName,segmentFilter,false);// Modified as part of TWC1824-3754
//             taxonomy.records.put(taxonomyRecord.id,taxonomyRecord);
//             taxonomy.topLevelIds.add(taxonomyRecord.id);
            
//         }
//         //added to populate filter groupings
//         taxonomy.searchFiltersGroupings=new List<SearchFiltersGrouping>();
//         taxonomy.searchFiltersGroupings=fetchSearchFilterGroupings(taxonomy.name);
        
//         response.put(taxonomyName,taxonomy);
//         system.debug('.....response.....'+response);
//         return response;
        
//     }
    
//     /*******************************************************************************************************************************************************************************************************
// * Class Name  : PMP_TaxonomyStore
// * Method Name :getPartnertierFilters
// * Description : this method return the marketplace partner tier filter in the given taxonomy structure.
// * Version     : 1.0 
// * Created Date: 24-June-2020
// * Modification Log :
// * Created By  : Tanzanite Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
//     @AuraEnabled(cacheable=true)
//     public static Map<string,Taxonomy> getPartnertierFilters(String langCode ,String taxonomyName){
        
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>(); 
//         Map<String,TaxonomyRecord> listings = new Map<String,TaxonomyRecord>(); 
        
//         Taxonomy taxonomy= new Taxonomy();
//         taxonomy.name=taxonomyName;
//         taxonomy.apiName='Partner_Tier';
//         taxonomy.label=System.Label.PMP_L2_Partner_Tier;
//         taxonomy.englishLabel = System.Label.PMP_L2_Partner_Tier_English; // Added as part of TWC1824-3754
//         taxonomy.viewAllLabel='View all partners by Tier';
//         taxonomy.svgIconUrl=null;
//         taxonomy.topLevelIds=new List<String>();
//         taxonomy.records=listings;
//         List<PMP_Partner_Tier__c> partnerTiers=[SELECT Id, OwnerId, Name, PMP_Partner_Tier_Chinese_Nm__c, PMP_Is_Biz_Org_Type_Ind__c, PMP_Partner_Tier_Name_Japanese__c FROM PMP_Partner_Tier__c where PMP_Is_Biz_Org_Type_Ind__c=false order by Name];
        
//         /* Map<String,String> valueLabelMap = new Map<String,String>();
//         Schema.DescribeFieldResult fieldResult = Account.Core_IPA_Badge_Tier__c.getDescribe();      
//         List<Schema.PicklistEntry> tiers = fieldResult.getPicklistValues();
//         for( Schema.PicklistEntry tierValue : tiers){
//         valueLabelMap.put(tierValue.getValue(),tierValue.getLabel());
//         }
//         system.debug('.valueLabelMap..'+valueLabelMap);*/
                
//         for(PMP_Partner_Tier__c tierFilter : partnerTiers){
//             System.debug('..tierFilter..'+tierFilter);
//             TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
//             taxonomyRecord.label =PMP_SearchUtilityController.getLocalisedName(tierFilter, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
//             taxonomyRecord.englishLabel =PMP_SearchUtilityController.getLocalisedName(tierFilter, PMP_StaticConstants_Partner.CAT_NAME_FIELD, PMP_StaticConstants_Partner.EN_US); // Added as part of TWC1824-3754
//             taxonomyRecord.viewAllLabel=System.Label.PMP_L2_View_all_Label;
//             taxonomyRecord.id=tierFilter.Name;
//             taxonomyRecord.children=new List<String>();
//             taxonomyRecord.svgIconUrl='';
//             taxonomyRecord.parentId=null;
//             taxonomyRecord.taxonomy=taxonomyName;
//             //taxonomyRecord.viewAllLabel='view all label';
//             taxonomyRecord.description=tierFilter.Name;         
//             listings.put(taxonomyRecord.id,taxonomyRecord);
//             taxonomy.topLevelIds.add(taxonomyRecord.id);
            
//         }
//         taxonomy.records=listings;
//         response.put(taxonomyName,taxonomy);
//         system.debug('.....response.....'+response);
//         return response;
//     }
    
//     /*******************************************************************************************************************************************************************************************************
// * Class Name  : PMP_TaxonomyStore
// * Method Name : getPartnerSegmentFilters
// * Description : this method return the marketplace partner segment filter in the given taxonomy structure.
// * Version     : 1.0 
// * Created Date: 24-June-2020
// * Modification Log :
// * Created By  : Tanzanite Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
//     @AuraEnabled(cacheable=true)
//     public static Map<string,Taxonomy> getPartnerSegmentFilters(String langCode,String taxonomyName,List<PMP_Company__c> partnerList){
        
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>(); 
//         Map<String,TaxonomyRecord> listings = new Map<String,TaxonomyRecord>();   
        
//         Taxonomy taxonomy= new Taxonomy();
//         taxonomy.name=taxonomyName;
//         taxonomy.apiName='Partner_Segment';
//         taxonomy.label= System.Label.PMP_L0_Partners_Market_Segment;
//         taxonomy.englishLabel = System.Label.PMP_L0_Partners_Market_Segment_English; // Added as part of TWC1824-3754
//         taxonomy.viewAllLabel = System.Label.PMP_L0_Viewall_Market_Segment;
//         taxonomy.svgIconUrl=null;
//         taxonomy.topLevelIds= new List<String>();
//         taxonomy.records=listings;
//         Set<String> partnerSegments= new Set<String>();
//         //40k fix: commented by priyanka
//         /*List<PMP_Company__c> partnerList= new  List<PMP_Company__c>();
//         if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){
        
//         partnerList= [SELECT id,PMP_Partner_Segment_Nm__c from PMP_Company__c where PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published AND PMP_Benefit_Update_Ind__c=False AND PMP_Partner_Segment_Nm__c !=null];
//         }*/
//         //40k fix: commented by priyanka end
                
//         for(PMP_Company__c partner: partnerList){
//             partnerSegments.addAll(partner.PMP_Partner_Segment_Nm__c.split(';'));
//         }
//         List<PMP_Partner_Segment__c> segmentsList = new  List<PMP_Partner_Segment__c> ();
//         if(Schema.sObjectType.PMP_Partner_Segment__c.isAccessible()){
//             segmentsList = [SELECT Id, Name, PMP_Is_Active_Ind__c, PMP_Partner_Segment_Value_Txt__c,PMP_Partner_Segment_English_Dsc_Txt__c,PMP_Partner_Segment_Japanese_Dsc_Txt__c,
//                             PMP_Partner_Segment_Chinese_Dsc_Txt__c,PMP_Partner_Segment_Chinese_Name_Txt__c,PMP_Partner_Segment_Japanese_Name_Txt__c
//                             from PMP_Partner_Segment__c  WHERE PMP_Is_Active_Ind__c = TRUE AND PMP_Partner_Segment_Value_Txt__c IN : partnerSegments order by Name];
//         }
//         for(PMP_Partner_Segment__c segmentFilter : segmentsList){
//             System.debug('..segmentFilter..'+segmentFilter);
//             TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
//             String segmentDesc=PMP_SearchUtilityController.getLocalisedName(segmentFilter, PMP_StaticConstants_Partner.CAT_DESC_FIELD, langCode);
//             String segmentName=PMP_SearchUtilityController.getLocalisedName(segmentFilter, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
//             taxonomyRecord.label =segmentName;
//             taxonomyRecord.englishLabel = PMP_SearchUtilityController.getLocalisedName(segmentFilter, PMP_StaticConstants_Partner.CAT_NAME_FIELD, PMP_StaticConstants_Partner.EN_US); // Added as part of TWC1824-3754
//             //taxonomyRecord.viewAllLabel='view all Label';
//             taxonomyRecord.id=segmentFilter.Id;
//             taxonomyRecord.children=new List<String>();
//             taxonomyRecord.svgIconUrl='';
//             taxonomyRecord.parentId=null;
//             taxonomyRecord.taxonomy=taxonomyName;
//             taxonomyRecord.viewAllLabel=System.Label.PMP_L2_View_all_Label;
//             taxonomyRecord.description=segmentDesc;         
//             listings.put(taxonomyRecord.id,taxonomyRecord);
//             taxonomy.topLevelIds.add(taxonomyRecord.id);
//             if(PMP_StaticConstants_Partner.TopPartnerSegments.contains(segmentFilter.PMP_Partner_Segment_Value_Txt__c)){
//                 //topLevelIds.add(md.id);
//                 taxonomyRecord.featured=true;
//             }
            
//         }
//         taxonomy.records=listings;
//         //added to populate filter groupings
//         taxonomy.searchFiltersGroupings=new List<SearchFiltersGrouping>();
//         taxonomy.searchFiltersGroupings=fetchSearchFilterGroupings(taxonomy.name);
        
//         response.put(taxonomyName,taxonomy);
//         system.debug('.....response.....'+response);
//         return response;
//     }
    
    
//     public static Map<string,Taxonomy> getTechnicalSpecsTaxonomy(String langCode){
        
//         boolean isIntelemp = PMP_Utility.isIntelEmployee();
//         system.debug('###Inside getTechnicalSpecsTaxonomy');
        
//         Map<String,TaxonomyRecord> specTaxRecordMap = new Map<String, TaxonomyRecord>();
//         Map<String,TaxonomyRecord> specValueTaxRecordMap = new Map<String, TaxonomyRecord>();
//         Map<String, Taxonomy> specTaxonomyMap = new Map<String, Taxonomy>();
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>();
//         List<PMP_Specification__c> specList= new List<PMP_Specification__c>();

//         //localization change Abhishek 
//         string specNameLocal = localisedFieldName.get('PMP_Specification__c|Name|' +langCode);
//         String specNameEnglish = localisedFieldName.get('PMP_Specification__c|Name|' +PMP_StaticConstants_Partner.EN_US); // Added as part of TWC1824-3754
//         string specValNameLocal =   localisedFieldName.get('PMP_Specification_Value__c|Name|' +langCode);
//         string specValNameEnglish =   localisedFieldName.get('PMP_Specification_Value__c|Name|' +PMP_StaticConstants_Partner.EN_US); // Added as part of TWC1824-3754

//         Map<string,string> pimIdSpecIdMap = New Map<string,string>();
//         Map<string,PMP_Specification__c> pimIdSpecMap = New Map<string,PMP_Specification__c>();//US1030147
//         List<PMP_Specification_Value__c> specValList= new List<PMP_Specification_Value__c>();//US1030147
        
//         for(PMP_Specification__c spec : [SELECT id, Name, PMP_Partner_Product_Display_Sequence_Nbr__c, PMP_Specification_Chinese_Nm__c, PMP_Specification_Japanese_Nm__c,
//                                          PMP_Partner_Product_Specification_Id__c, PMP_Product_Parent_Specification_Id__c
//                                          , PMP_Ancestor_Specification_Cd__c,PMP_Parent_Specification_Id__c , PMP_Specification_Name__c
                                         
//                                          FROM PMP_Specification__c
//                                          WHERE PMP_Active_Ind__c = TRUE ORDER BY PMP_Partner_Product_Display_Sequence_Nbr__c]){
//                                              if(spec.PMP_Product_Parent_Specification_Id__c == null){
//                                                  Taxonomy taxanomy = new Taxonomy();
//                                                  taxanomy.name = spec.Name.deleteWhitespace();// added to remove space
//                                                  taxanomy.apiName =spec.Id;
                                                 
//                                                  if(spec.get(specNameLocal)!= null){
//                                                      taxanomy.label = (string)spec.get(specNameLocal);
//                                                  }
//                                                  else{
//                                                      taxanomy.label = spec.Name;
//                                                  }
//                                                  taxanomy.englishLabel =(string)spec.get(specNameEnglish); // Added as part of TWC1824-3754
//                                                  // taxanomy.label = PMP_SearchUtilityController.getLocalisedName(spec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                                                 
//                                                  //taxanomy.viewAllLabel = PMP_StaticConstants_Partner.taxonomyCtaLabelMap.get(section);
//                                                  taxanomy.svgIconUrl = null;
//                                                  taxanomy.topLevelIds = new List<Id>();
//                                                  taxanomy.records = new Map<String,TaxonomyRecord>();
//                                                  if(spec.PMP_Partner_Product_Specification_Id__c=='NPP_Processors'){
//                                                      taxanomy.filterDisplayType='large-data'; 
//                                                  }
//                                                  specTaxonomyMap.put(spec.Id, taxanomy);
//                                              }
//                                              else{                
//                                                  TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
//                                                  // taxonomyRecord.label = PMP_SearchUtilityController.getLocalisedName(spec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);//spec.Name;
//                                                  if(spec.get(specNameLocal)!= null){
//                                                      taxonomyRecord.label = (string)spec.get(specNameLocal);
//                                                  }
//                                                  else{
//                                                      taxonomyRecord.label = spec.Name;
//                                                  }
//                                                  taxonomyRecord.englishLabel = (string)spec.get(specNameEnglish); // Added as part of TWC1824-3754
//                                                  taxonomyRecord.id=spec.Id;
//                                                  taxonomyRecord.description = '';
//                                                  taxonomyRecord.children= new List<String>();
//                                                  //taxonomyRecord.svgIconUrl = metadataMap.get(cat.PMP_Partner_Product_Category_Cd__c);
//                                                  taxonomyRecord.parentId=spec.PMP_Parent_Specification_Id__c;
//                                                  specTaxRecordMap.put(spec.Id, taxonomyRecord);
                                                 
//                                              }
//                                              pimIdSpecIdMap.put(spec.PMP_Partner_Product_Specification_Id__c, spec.id);
//                                              pimIdSpecMap.put(spec.PMP_Partner_Product_Specification_Id__c, spec);//US1030147
//                                              specList.add(spec);
                                             
//                                          }
//         for(PMP_Specification_Value__c specVal : [Select id, Name, PMP_Specification_Value_Sequence_Nbr__c, PMP_Specification_Value_Chinese_Cd__c,PMP_Specification_id__c,
//                                                   PMP_Spec_Pre_Release_Ind__c,PMP_Specification_Value_Japanese_Cd__c,PMP_Specification_Value_Nm__c,
//                                                   PMP_Name_Chinese__c,PMP_Name_Japanese__c,PMP_Specification_Product_Cd__c
//                                                   from PMP_Specification_Value__c  
//                                                   where PMP_Active_Ind__c = true ORDER BY PMP_Specification_Value_Sequence_Nbr__c
//                                                  ]){
//                                                      TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
//                                                      if(specVal.get(specValNameLocal)!= null){
//                                                          taxonomyRecord.label = (string)specVal.get(specValNameLocal);
//                                                      }
//                                                      else{
//                                                          taxonomyRecord.label = specVal.Name;
//                                                      }
//                                                      taxonomyRecord.englishLabel = (string)specVal.get(specValNameEnglish); // Added as part of TWC1824-3754
//                                                      taxonomyRecord.prerelease = (boolean)specVal.PMP_Spec_Pre_Release_Ind__c;
//                                                      taxonomyRecord.isIntelEmployee = isIntelemp;
//                                                      taxonomyRecord.id =  specVal.id;
//                                                      taxonomyRecord.description = '';
//                                                      taxonomyRecord.children= new List<String>();
//                                                      taxonomyRecord.parentId=pimIdSpecIdMap.get(specVal.PMP_Specification_Product_Cd__c);   
//                                                      system.debug('taxonomyRecord.label + parentIDd:'+taxonomyRecord.label+' '+taxonomyRecord.parentId);                                       
//                                                      specTaxRecordMap.put(specVal.id, taxonomyRecord);
//                                                      specValList.add(specVal); //US1030147                                       
                                                     
//                                                  }
//         //System.debug('PPPP-->specValList:  '+specValList);
//         //-----------------------Abhishek poc end ----------
//         //Map<String, List<TaxonomyRecords>> taxRecordGrandParentMap = new Map<String, List<TaxonomyRecords>>();
//         for(TaxonomyRecord tag : specTaxRecordMap.values()){
            
//             if(specTaxRecordMap.containsKey(tag.parentId)){
//                 specTaxRecordMap.get(tag.parentId).children.add(tag.Id);
//             }
            
//             if(specTaxonomyMap.containsKey(tag.parentId) && tag.parentId!=null){
//                 specTaxonomyMap.get(tag.parentId).records.put(tag.Id, tag);
//                 tag.taxonomy = specTaxonomyMap.get(tag.parentId).name;
//             }
//             else{
//                 if(specTaxRecordMap.containsKey(tag.parentId) && tag.parentId != null){
//                     if(specTaxonomyMap.containsKey(specTaxRecordMap.get(tag.parentId).parentId) ){
//                         specTaxonomyMap.get(specTaxRecordMap.get(tag.parentId).parentId).records.put(tag.Id, tag);
//                         tag.taxonomy = specTaxonomyMap.get(specTaxRecordMap.get(tag.parentId).parentId).name;
//                     }
//                 }
                
                
//                 if(tag.parentId != null && specTaxRecordMap.get(tag.parentId) !=null && specTaxRecordMap.get(tag.parentId).parentId != null && specTaxRecordMap.containsKey(specTaxRecordMap.get(tag.parentId).parentId) ){
//                     if(specTaxonomyMap.containsKey(specTaxRecordMap.get(specTaxRecordMap.get(tag.parentId).parentId).parentId)){
//                         specTaxonomyMap.get((specTaxRecordMap.get(specTaxRecordMap.get(tag.parentId).parentId).parentId)).records.put(tag.Id, tag);
//                         tag.taxonomy = specTaxonomyMap.get((specTaxRecordMap.get(specTaxRecordMap.get(tag.parentId).parentId)).parentId).name;
//                     }
//                 }
//             }
            
            
            
//         }
        
//         for(TaxonomyRecord tag: specTaxRecordMap.values()){
//             if(specTaxonomyMap.containsKey(tag.parentId)){
//                 if(!response.containsKey(tag.parentId)){
//                     response.put(specTaxonomyMap.get(tag.parentId).name,specTaxonomyMap.get(tag.parentId));
//                 } 
//             }
//         }
        
        
//         for(PMP_Specification__c spec : specList){
//             if(spec.PMP_Ancestor_Specification_Cd__c != null){
//                 if(spec.PMP_Ancestor_Specification_Cd__c.split('\\|').size() == 1){
//                     specTaxRecordMap.get(spec.Id).parentId = null;
//                 }
                
//             }
            
//             if(spec.PMP_Ancestor_Specification_Cd__c == spec.PMP_Product_Parent_Specification_Id__c){
//                 if(specTaxonomyMap.containsKey(spec.PMP_Parent_Specification_Id__c)){
//                     specTaxonomyMap.get(spec.PMP_Parent_Specification_Id__c).topLevelIds.add(spec.Id);
//                 }
                
//             }
//         }
        
//         //fix for filter defect : US1030147
//         for(PMP_Specification_Value__c specVal : specValList){
//             if(pimIdSpecMap.get(specVal.PMP_Specification_Product_Cd__c)!=null && pimIdSpecMap.get(specVal.PMP_Specification_Product_Cd__c).PMP_Ancestor_Specification_Cd__c == null){
//                 system.debug('inside the PMP_Specification_Value__c list:- ');
//                 specTaxRecordMap.get(specVal.Id).parentId = null;
                
//             }
//         }
//         //fix for filter ends : US1030147
       
//         return response;
//     }
    
//     /*******************************************************************************************************************************************************************************************************
// * Class Name  : PMP_TaxonomyStore
// * Method Name :getMarketplaceEvents
// * Description : this method return the marketplace events in the given taxonomy structure.
// * Version     : 1.0 
// * Created Date: 24-June-2020
// * Modification Log :
// * Created By  : Tanzanite Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
//     public static  Map<string,Taxonomy> getMarketplaceEvents(String taxonomyName,String apiName){
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>(); 
//         Taxonomy taxonomy= new Taxonomy();
//         taxonomy.name=taxonomyName;
//         taxonomy.apiName=apiName;
//         taxonomy.label=System.Label.PMP_Marketplace_Event;
//         taxonomy.englishLabel =System.Label.PMP_Marketplace_Event_English; // Added as part of TWC1824-3754
//         taxonomy.viewAllLabel='View all marketplace Events';
//         taxonomy.svgIconUrl=null;
//         taxonomy.topLevelIds=new List<String>();
//         taxonomy.records=new Map<String,TaxonomyRecord>();
//         List<PMP_Marketplace_Event__c> eventList = new List<PMP_Marketplace_Event__c>();
//         if(Schema.sObjectType.PMP_Marketplace_Event__c.isAccessible()){
//             eventList = [SELECT Name from PMP_Marketplace_Event__c 
//                          WHERE (PMP_Marketplace_Event_Start_Dt__c <=: SYSTEM.NOW() AND PMP_Marketplace_Event_End_Dt__c >=: SYSTEM.NOW())
//                          ORDER BY PMP_Marketplace_Event_Start_Dt__c DESC];
//         }
        
//         for(PMP_Marketplace_Event__c evt:eventList){
//             TaxonomyRecord taxonomyRecord= PMP_TaxonomyStore.getTaxonomyRecord(evt.name,evt.name,'view all Label',evt.id,new List<String>(),null,null,taxonomyName,evt.Name,false); // Modified as part of TWC1824-3754
//             taxonomy.records.put(taxonomyRecord.id,taxonomyRecord);
//             taxonomy.topLevelIds.add(taxonomyRecord.id);
//         }
//         response.put(taxonomyName,taxonomy);
//         return response;
        
//     }
    
    
    
//     /*******************************************************************************************************************************************************************************************************
// * Class Name  : PMP_TaxonomyStore
// * Method Name :getTaxonomyRecord
// * Description : this methods form the taxonomy record accepting the details from calling method and returns the TaxonomyRecord as result.
// * Version     : 1.0 
// * Created Date: 24-June-2020
// * Modification Log :
// * Created By  : Tanzanite Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
    
//     public static taxonomyRecord getTaxonomyRecord(String label,String englishLabel,String viewAllLabel,String recId,String[] children, String icon, String parentId,String taxonomyName,String description,Boolean isFeatured){ // Modified as part of TWC1824-3754
        
//         TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
//         taxonomyRecord.label = label;
//         taxonomyRecord.englishLabel = englishLabel; // Added as part of TWC1824-3754
//         taxonomyRecord.viewAllLabel=viewAllLabel;
//         taxonomyRecord.id=recId;
//         taxonomyRecord.children=children;
//         taxonomyRecord.svgIconUrl=icon;
//         taxonomyRecord.parentId=parentId;
//         taxonomyRecord.taxonomy=taxonomyName;
//         taxonomyRecord.description=description;
//         taxonomyRecord.featured=isFeatured;
//         return taxonomyRecord;
//     }
    
    
    
//     //for code updation created the duplicate method
//     public static  List<SearchFiltersGrouping> fetchSearchFilterGroupings(String section){
//         List<PMP_Specifications_Tab_Mapping__mdt> filterList = new List<PMP_Specifications_Tab_Mapping__mdt>();
//         filterList = [select PMP_Field_Label__c, PMP_Search_Filter_Group_Txt__c, PMP_Search_Filter_Label_Txt__c, 
//                       PMP_Is_Search_Ind__c, PMP_Is_Create_Offering_Ind__c ,PMP_Filter_Sequence__c 
//                       from PMP_Specifications_Tab_Mapping__mdt where PMP_Search_Filter_Label_Txt__c != NULL order by PMP_Filter_Sequence__c];
        
//         System.debug('filterList:'+filterList);        
//         List<String> techSpecificationList = new List<String>();
//         List<SearchFiltersGrouping> searchFilterGroup = new List<SearchFiltersGrouping>();
//         Map<String,List<String>> filtermap = new Map<String,List<String>>(); 
//         List<String> PIFilters= new List<String>();
//         PIFilters= PMP_StaticConstants_Partner.PIGroupFilters;
//         String partnerPIGroup=PMP_StaticConstants_Partner.PIGroup;
        
//         for(PMP_Specifications_Tab_Mapping__mdt filter : filterList)
//         {
//             System.debug('filter.........'+filter.PMP_Search_Filter_Label_Txt__c+'section:'+section);
//             if(filtermap.get(filter.PMP_Search_Filter_Group_Txt__c) == NULL) {
//                 filtermap.put(filter.PMP_Search_Filter_Group_Txt__c, new List<String>());
//             }
//             //Offering Applications
//             if(section == 'OfferingApplications' && filter.PMP_Search_Filter_Label_Txt__c != 'OfferingApplications' &&
//                filter.PMP_Search_Filter_Label_Txt__c != 'PartnerIndustries' && filter.PMP_Search_Filter_Label_Txt__c !='PartnerApplications' && 
//                filter.PMP_Search_Filter_Label_Txt__c !='PartnerSegments' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup)
//             {
//                 /*if(filtermap.get('Business Filters')!=null && !filtermap.get('Business Filters').contains('OfferingCategories')){
//                     filtermap.get('Business Filters').add('OfferingCategories');
//                 }   */
                
//                 filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);   
//             }
//             if( section == 'OfferingIndustries' && filter.PMP_Search_Filter_Label_Txt__c != 'PartnerIndustries' && 
//                filter.PMP_Search_Filter_Label_Txt__c !='PartnerSegments' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup && 
//                filter.PMP_Search_Filter_Label_Txt__c!='OfferingIndustries' && filter.PMP_Search_Filter_Label_Txt__c !='PartnerApplications')
//             {
//                 /* if(filtermap.get('Business Filters')!=null && !filtermap.get('Business Filters').contains('OfferingCategories')){
//                     filtermap.get('Business Filters').add('OfferingCategories');
//                     } */
//                 filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);   
//             }
//             if(section == 'PartnerIndustries' && filter.PMP_Search_Filter_Label_Txt__c != 'PartnerIndustries' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup 
//                && filter.PMP_Search_Filter_Label_Txt__c!='OfferingIndustries' && filter.PMP_Search_Filter_Label_Txt__c != 'OfferingApplications'
//                && filter.PMP_Search_Filter_Label_Txt__c!='OfferingSegments' && filter.PMP_Search_Filter_Label_Txt__c !='OfferingCategories')
//             {
//                 filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);   
//             }
            
//             if(section == 'PartnerSpecialties' && filter.PMP_Search_Filter_Label_Txt__c != 'PartnerSpecialties' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup && filter.PMP_Search_Filter_Label_Txt__c!='OfferingIndustries' && filter.PMP_Search_Filter_Label_Txt__c !='OfferingCategories')
//             {
//                 //filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);   
//                 if(PIFilters.Contains(filter.PMP_Search_Filter_Label_Txt__c)){
//                     if(filtermap.containsKey(partnerPIGroup)){
//                         filtermap.get(partnerPIGroup).add(filter.PMP_Search_Filter_Label_Txt__c); 
//                     }
//                     else{
//                         filtermap.put(partnerPIGroup,new List<String> {filter.PMP_Search_Filter_Label_Txt__c}); 
//                     }
//                 }
//                 else
//                 {
//                     filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c); 
//                 }
                
//                 /*if(filter.PMP_Search_Filter_Label_Txt__c == 'PartnerTier'||filter.PMP_Search_Filter_Label_Txt__c == 'IntelPartnerEvents'){
//                     filtermap.get('Business Filters').add(filter.PMP_Search_Filter_Label_Txt__c);
//                     }*/
                
//             }
//             if(section == 'PartnerDirectory' && filter.PMP_Search_Filter_Label_Txt__c != 'PartnerDirectory' && 
//                filter.PMP_Search_Filter_Label_Txt__c!='OfferingIndustries' && filter.PMP_Search_Filter_Label_Txt__c!='OfferingApplications'
//                && filter.PMP_Search_Filter_Label_Txt__c!='OfferingSegments' && filter.PMP_Search_Filter_Label_Txt__c !='OfferingCategories')//&& filter.PMP_Search_Filter_Label_Txt__c != 'Partner Directory'
//             {
//                 if(PIFilters.Contains(filter.PMP_Search_Filter_Label_Txt__c)){
//                     if(filtermap.containsKey(partnerPIGroup)){
//                         filtermap.get(partnerPIGroup).add(filter.PMP_Search_Filter_Label_Txt__c); 
//                     }
//                     else{
//                         filtermap.put(partnerPIGroup,new List<String> {filter.PMP_Search_Filter_Label_Txt__c}); 
//                     }
//                 }
//                 else
//                 {
//                     filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c); 
//                 }
//                 // filtermap.put('DistiBizOrgType',getDistiBizOrg('DistiBizOrgType','').get('DistiBizOrgType').Label);
//                 /* if(filter.PMP_Search_Filter_Label_Txt__c == 'PartnerTier'||filter.PMP_Search_Filter_Label_Txt__c == 'IntelPartnerEvents' || filter.PMP_Search_Filter_Label_Txt__c == 'PartnerSpecialties' ){
//                 filtermap.get('Business Filters').add(filter.PMP_Search_Filter_Label_Txt__c);
//                 }*/
                
//             }
//             if(section == 'PartnerSegments' && filter.PMP_Search_Filter_Label_Txt__c != 'OfferingSegments' && 
//                filter.PMP_Search_Filter_Label_Txt__c !='PartnerSegments' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup 
//                && filter.PMP_Search_Filter_Label_Txt__c!='OfferingIndustries' && filter.PMP_Search_Filter_Label_Txt__c!='OfferingApplications' && filter.PMP_Search_Filter_Label_Txt__c !='OfferingCategories')
//             {
//                 //filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);  
//                 if(PIFilters.Contains(filter.PMP_Search_Filter_Label_Txt__c)){
//                     if(filtermap.containsKey(partnerPIGroup)){
//                         filtermap.get(partnerPIGroup).add(filter.PMP_Search_Filter_Label_Txt__c); 
//                     }
//                     else{
//                         filtermap.put(partnerPIGroup,new List<String> {filter.PMP_Search_Filter_Label_Txt__c}); 
//                     }
//                 }
//                 else
//                 {
//                     filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c); 
//                 }
//                 /* if(filter.PMP_Search_Filter_Label_Txt__c == 'PartnerTier'||filter.PMP_Search_Filter_Label_Txt__c == 'IntelPartnerEvents' || filter.PMP_Search_Filter_Label_Txt__c == 'PartnerSpecialties' ){
//                     filtermap.get('Business Filters').add(filter.PMP_Search_Filter_Label_Txt__c);
//                 }*/
//             }
//             if(section == 'OfferingSegments' && filter.PMP_Search_Filter_Label_Txt__c != 'OfferingSegments' &&
//                filter.PMP_Search_Filter_Label_Txt__c != 'PartnerIndustries' && filter.PMP_Search_Filter_Label_Txt__c !='PartnerApplications' && 
//                filter.PMP_Search_Filter_Label_Txt__c !='PartnerSegments' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup && filter.PMP_Search_Filter_Label_Txt__c !='OfferingCategories')
                
//             {
//                 filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);   
//             }
            
//             if(section == 'OfferingCategories' && filter.PMP_Search_Filter_Label_Txt__c != 'PartnerIndustries' 
//                && filter.PMP_Search_Filter_Label_Txt__c !='PartnerApplications' && filter.PMP_Search_Filter_Label_Txt__c !='PartnerSegments' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup && filter.PMP_Search_Filter_Label_Txt__c !='OfferingCategories')
//             {
//                 filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);   
//             }
//         }
        
//         if(section=='PartnerDirectory') {
        
//         filtermap.get(partnerPIGroup).add('Country'); 
//             filtermap.get(partnerPIGroup).add('Distributor');
//             Integer index=filtermap.get(partnerPIGroup).indexOf('IntelPartnerEvents');
//             filtermap.get(partnerPIGroup).remove(index);
//             filtermap.get(partnerPIGroup).add('IntelPartnerEvents'); 
//             //filtermap.get('Business Filters').add('PartnerTier');
//             //filtermap.get('Business Filters').add('IntelPartnerEvents');
            
            
//             //grouplist[index1]=partnerPIGroup;
//             //grouplist[index2]='Business Filters';
            
            
//             //filtermap.containsKey('Distributor Product'){
//             // filtermap.get('Distributor Product').add('Distributor Components');              
//             // filtermap.get('Distributor Product').add('Distributor Systems & Solutions');  //Partner Segments
//             // }
//             //else{
//             filtermap.put('Distributor Product',new List<String>{'DistributorComponents','DistributorSystems&Solutions'});
//             // }
            
//             /*filtermap.get('Business Filters').add('PartnerSegments');  //Partner Segments
//             filtermap.get('Business Filters').add('PartnerApplications');
//             filtermap.get(partnerPIGroup).add('Solutions_Software_And_Services_Provider_Type');*/
            
//             //filtermap.put('Solutions, Software and Services Provider Type',new List<String>{'Solutions, Software and Services Provider Type'});
            
            
            
//         }
        
//         /*  if(section == 'PartnerSegments' || section == 'PartnerDirectory' || section=='PartnerSpecialties' || section=='PartnerIndustries'){
//         filtermap.get('Business Filters').add('PartnerTier');
//         filtermap.get('Business Filters').add('IntelPartnerEvents');
//         if(section!='PartnerSpecialties')
//         filtermap.get('Business Filters').add('PartnerSpecialties');
//         }*/
                
//                 /* if(section == 'PartnerSegments'){
//         filtermap.get('Business Filters').add('PartnerApplications'); 
//         }
        
//         if(section=='PartnerIndustries' || section=='PartnerSpecialties') {
//         filtermap.get('Business Filters').add('PartnerSegments');  //Partner Segments
//         filtermap.get('Business Filters').add('PartnerApplications');
//         }
//         if(section=='OfferingApplications' || section=='OfferingIndustries'){
//         filtermap.get('Business Filters').add('OfferingCategories');  //Partner Segments
//         }*/
        
        
//         system.debug('..filtermap Updated..'+filtermap);
//         List<String> filterSections= new List<String>();
//         filterSections = PMP_StaticConstants_Partner.groupsByPageMap.get(section);
//         system.debug('filterSections...'+filterSections);
//         /* List<String> grouplist= new List<String>();
//         grouplist.addAll(filtermap.keySet());
//         Integer BFIndex=-1;
//         Integer PIIndex=-1;
//         if(grouplist.contains('Business Filters')){
//         BFIndex=grouplist.indexOf('Business Filters');
//         }
//         if(grouplist.contains(partnerPIGroup)){
//         PIIndex=grouplist.indexOf(partnerPIGroup);
//         }
//         if(BFIndex>PIIndex && BFIndex!=-1 && PIIndex!=-1){
//         grouplist[BFIndex]=partnerPIGroup;
//         grouplist[PIIndex]='Business Filters';
//         }*/
//         for(String filter : filtermap.keySet())
//         {
//             if(filterSections!=null){
//                 for(String sec :filterSections )
//                 {
//                     if(filter==sec)
//                     {
//                         SearchFiltersGrouping wrapper = new SearchFiltersGrouping();
//                         wrapper.label = filter;
//                         if(filter=='Business Filters'){
//                             wrapper.label=System.Label.PMP_L2_Business_Filters;
//                             wrapper.englishLabel = System.Label.PMP_L2_Business_Filters_English; // Added as part of TWC1824-3754
//                         }
//                         if(filter=='Technical Specifications'){
//                             wrapper.label=System.Label.PMP_L2_Filter_Technical_Specifications;
//                             wrapper.englishLabel = System.Label.PMP_L2_Filter_Technical_Specifications_English; // Added as part of TWC1824-3754

//                         }
//                         if(filter=='Partner Information'){
//                             wrapper.label=System.Label.PMP_L2_Filter_Partner_Information;
//                             wrapper.englishLabel = System.Label.PMP_L2_Filter_Partner_Information_English; // Added as part of TWC1824-3754
//                         }
                        
//                         if(filter=='Distributor Product'){
//                             wrapper.label=System.label.PMP_L2_Filter_Distributor_Product;
//                             wrapper.englishLabel = System.label.PMP_L2_Filter_Distributor_Product_English;// Added as part of TWC1824-3754
//                         }
//                         wrapper.filters = filtermap.get(filter);
//                         searchFilterGroup.add(wrapper);
                        
//                     }
                    
                    
//                 }
//             }
            
//         }
//         system.debug('..searchFilterGroup....'+searchFilterGroup);
//         return searchFilterGroup;
        
        
//         //public static final Map<String, String[]> groupsByPageMap = new Map<String, String[]>{'Offering Categories' => offFilterGroups,'Offering Segments' =>partnerFilterGroups, 'Offering Industries' => offFilterGroups, 'Offering Applications' => offFilterGroups, 'Partner Industries' => partnerFilterGroups,'Partner Directory' => partnerFilterGroups,'Partner Specialties' => partnerFilterGroups,'Partner Segments' =>partnerFilterGroups};        
        
//     }
    
    
//     //below methods are added to get the filters for distributor
    
//     @AuraEnabled(cacheable=true)
//     public static Map<string,Taxonomy> getDistiBizOrg(String langCode,String taxonomyName){
        
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>(); 
//         Map<String,TaxonomyRecord> listings = new Map<String,TaxonomyRecord>(); 
        
//         Taxonomy taxonomy= new Taxonomy();
//         taxonomy.name=taxonomyName;
//         taxonomy.apiName='DistiBizOrg';
//         taxonomy.label=System.Label.PMP_L2_Distributor_Filter;
//         taxonomy.englishLabel = System.Label.PMP_L2_Distributor_Filter_English;// Added as part of TWC1824-3754
//         taxonomy.viewAllLabel='View all Partners';
//         taxonomy.svgIconUrl=null;
//         taxonomy.topLevelIds=new List<String>();
//         taxonomy.records=listings;
//         List<PMP_Partner_Tier__c> bizOrgs=[SELECT Id, OwnerId, Name, PMP_Partner_Tier_Chinese_Nm__c, PMP_Is_Biz_Org_Type_Ind__c, PMP_Partner_Tier_Name_Japanese__c FROM PMP_Partner_Tier__c where PMP_Is_Biz_Org_Type_Ind__c=true];
        
//         //Map<String,String> valueLabelMap = new Map<String,String>();
//         //PMP_Intel_Authorized_Distributor_Biz_Org , PMP_Intel_Approved_Component_Supplier_Biz_Org , PMP_Intel_Approved_Device_Supplier_Biz_Org
//         List<String> BizOrgsList=New List<String> {'Intel Authorized Distributor (IAD)','Intel Approved Component Supplier (IACS)','Intel Approved Device Supplier (IADS)'};
//             //List<String> BizOrgs=New List<String> {System.Label.PMP_Intel_Authorized_Distributor_Biz_Org,System.Label.PMP_Intel_Approved_Component_Supplier_Biz_Org,System.Label.PMP_Intel_Approved_Device_Supplier_Biz_Org};
            
//         /*Schema.DescribeFieldResult fieldResult = Account.Core_Account_Type__c.getDescribe();      
//         List<Schema.PicklistEntry> components = fieldResult.getPicklistValues();
//         for( Schema.PicklistEntry comp : components){
//         valueLabelMap.put(comp.getValue(),comp.getLabel());
//         }
//         system.debug('.valueLabelMap..'+valueLabelMap);
//         List<String> pickValues= new List<String>();
//         pickValues= valueLabelMap.values();*/
//             List<PMP_Partner_Tier__c> bizOrgsTierRecords= new List<PMP_Partner_Tier__c>();
//         Map<String,PMP_Partner_Tier__c> bizOrgsMap= new Map<String,PMP_Partner_Tier__c>();
//         for(PMP_Partner_Tier__c DistiBizOrgFilter : bizOrgs){
//             bizOrgsMap.put(DistiBizOrgFilter.Name,DistiBizOrgFilter);
//         }
//         for(String borg:BizOrgsList){
//             if(bizOrgsMap.keySet().contains(borg)){
//                 bizOrgsTierRecords.add(bizOrgsMap.get(borg));
//             }
//         }
        
        
//         for(PMP_Partner_Tier__c DistiBizOrgFilter : bizOrgsTierRecords){
//             //if(pickValues.contains(DistiBizOrgFilter)){
//             System.debug('..DistiBizOrgFilter..'+DistiBizOrgFilter);
//             TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
//             taxonomyRecord.label =PMP_SearchUtilityController.getLocalisedName(DistiBizOrgFilter, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
//             taxonomyRecord.englishLabel =PMP_SearchUtilityController.getLocalisedName(DistiBizOrgFilter, PMP_StaticConstants_Partner.CAT_NAME_FIELD, PMP_StaticConstants_Partner.EN_US); // Added as part of TWC1824-3754
//             taxonomyRecord.viewAllLabel='view all Partners';
//             taxonomyRecord.id=DistiBizOrgFilter.Name;
//             taxonomyRecord.children=new List<String>();
//             taxonomyRecord.svgIconUrl='';
//             taxonomyRecord.parentId=null;
//             taxonomyRecord.taxonomy=taxonomyName;
//             taxonomyRecord.viewAllLabel='view all label';
//             taxonomyRecord.description='';         
//             listings.put(taxonomyRecord.id,taxonomyRecord);
//             // }
//         }
//         taxonomy.records=listings;
//         taxonomy.expandByDefault=true;
//         response.put(taxonomyName,taxonomy);
//         system.debug('.....response.....'+response);
//         return response;
//     }
    
    
//     @AuraEnabled(cacheable=true)
//     public static Map<string,Taxonomy> getDistiComponents(String langCode,String taxonomyName){
        
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>(); 
//         Map<String,TaxonomyRecord> listings = new Map<String,TaxonomyRecord>(); 
//         Taxonomy taxonomy= new Taxonomy();
//         taxonomy.name=taxonomyName;
//         taxonomy.apiName='DistiComponents';
//         taxonomy.label=System.Label.PMP_Distributor_Components;
//         taxonomy.englishLabel = System.Label.PMP_Distributor_Components_English; // Added as part of TWC1824-3754
//         taxonomy.viewAllLabel='View all Partners';
//         taxonomy.svgIconUrl=null;
//         taxonomy.topLevelIds=new List<String>();
//         taxonomy.records=listings;
        
//         Map<String,String> valueLabelMap = new Map<String,String>();
        
//         Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Disti_Components_Nm__c.getDescribe();      
//         List<Schema.PicklistEntry> components = fieldResult.getPicklistValues();
//         for( Schema.PicklistEntry comp : components){
//             valueLabelMap.put(comp.getValue(),comp.getLabel());
//         }
//         system.debug('.valueLabelMap..'+valueLabelMap);
        
//         for(String DistiComponentsFilter : valueLabelMap.keyset()){
//             System.debug('..DistiComponentsFilter..'+DistiComponentsFilter);
//             TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
//             taxonomyRecord.label =valueLabelMap.get(DistiComponentsFilter);
//             taxonomyRecord.englishLabel = DistiComponentsFilter; // Added as part of TWC1824-3754
//             taxonomyRecord.viewAllLabel='view all Partners';
//             //      taxonomyRecord.id=valueLabelMap.get(DistiComponentsFilter);
//             taxonomyRecord.id=DistiComponentsFilter;
//             taxonomyRecord.children=new List<String>();
//             taxonomyRecord.svgIconUrl='';
//             taxonomyRecord.parentId=null;
//             taxonomyRecord.taxonomy=taxonomyName;
//             taxonomyRecord.viewAllLabel='view all label';
//             taxonomyRecord.description='';         
//             listings.put(taxonomyRecord.id,taxonomyRecord);
            
//         }
//         taxonomy.records=listings;
//         taxonomy.expandByDefault=true;
//         response.put(taxonomyName,taxonomy);
//         system.debug('.....response.....'+response);
//         return response;
//     }
    
    
//     @AuraEnabled(cacheable=true)
//     public static Map<string,Taxonomy> getDistiSysSolutions(String langCode,String taxonomyName){
        
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>(); 
//         Map<String,TaxonomyRecord> listings = new Map<String,TaxonomyRecord>();      
        
//         Taxonomy taxonomy= new Taxonomy();
//         taxonomy.name=taxonomyName;
//         taxonomy.apiName='DistiSysSolutions';
//         taxonomy.label=System.Label.PMP_Distributor_System_and_Solutions;
//         taxonomy.englishLabel = System.Label.PMP_Distributor_System_and_Solutions_English; // Added as part of TWC1824-3754
//         taxonomy.viewAllLabel='View all Partners';
//         taxonomy.svgIconUrl=null;
//         taxonomy.topLevelIds=new List<String>();
//         taxonomy.records=listings;
        
//         Map<String,String> valueLabelMap = new Map<String,String>();
        
//         Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Disti_Sys_Solutions_Nm__c.getDescribe();      
//         List<Schema.PicklistEntry> components = fieldResult.getPicklistValues();
//         for( Schema.PicklistEntry comp : components){
//             valueLabelMap.put(comp.getValue(),comp.getLabel());
//         }
//         system.debug('.valueLabelMap..'+valueLabelMap);
        
//         for(String DistiSysSolutionsFilter : valueLabelMap.keyset()){
//             System.debug('..DistiSysSolutionsFilter..'+DistiSysSolutionsFilter);
//             TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
//             taxonomyRecord.label =valueLabelMap.get(DistiSysSolutionsFilter) ;
//             taxonomyRecord.englishLabel = DistiSysSolutionsFilter; // Added as part of TWC1824-3754
//             taxonomyRecord.viewAllLabel='view all Label';
//             //      taxonomyRecord.id=valueLabelMap.get(DistiSysSolutionsFilter);
//             taxonomyRecord.id=DistiSysSolutionsFilter.replace(' ', '_');
//             taxonomyRecord.children=new List<String>();
//             taxonomyRecord.svgIconUrl='';
//             taxonomyRecord.parentId=null;
//             taxonomyRecord.taxonomy=taxonomyName;
//             taxonomyRecord.viewAllLabel='view all label';
//             taxonomyRecord.description='';         
//             listings.put(taxonomyRecord.id,taxonomyRecord);
            
//         }
//         taxonomy.records=listings;
//         taxonomy.expandByDefault=true;
//         response.put(taxonomyName,taxonomy);
//         system.debug('.....response.....'+response);
//         return response;
//     }
    
//     @AuraEnabled(cacheable=true)
//     public static Map<string,Taxonomy> getDistiCountries(String langCode,String taxonomyName){
//         Map<string,Taxonomy> response= new Map<string,Taxonomy>(); 
//         Taxonomy taxonomy= new Taxonomy();
//         taxonomy.name=taxonomyName;//country
//         taxonomy.apiName='country';
//         taxonomy.label=System.Label.PMP_Country;
//         taxonomy.englishLabel = System.Label.PMP_Country_English; // Added as part of TWC1824-3754
//         taxonomy.viewAllLabel='View all Partners';
//         taxonomy.svgIconUrl=null;
//         taxonomy.topLevelIds=new List<String>();
//         taxonomy.records= new Map<String,TaxonomyRecord>();
//         taxonomy.filterDisplayType='select';
        
//         /*       Schema.DescribeFieldResult countryResult = Contact.MailingCountryCode.getDescribe();
// Schema.sObjectField ctrlField = countryResult.getSObjectField();
// List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues(); */
//         List<PMP_Company__c> partnersList = new List<PMP_Company__c>();
//         Set<String> valueLabel = new Set<String>(); 
//         if(Schema.sObjectType.PMP_Company__c.isAccessible()){
//             partnersList=[select name,id,PMP_Disti_Country_Coverage_Txt__c,PMP_Is_Distributor_Ind__c from PMP_Company__c where PMP_Company_Lifecycle_Status_Nm__c ='Published' AND PMP_Is_Distributor_Ind__c = true AND PMP_Benefit_Update_Ind__c =false];        
//         }
        
//         if(partnersList != NULL) {
//             for( PMP_Company__c comp : partnersList){
//                 if(comp.PMP_Disti_Country_Coverage_Txt__c != null){ //Added null check from query filter to here as part of data type change
//                     List<String> country=comp.PMP_Disti_Country_Coverage_Txt__c.split(';'); 
//                     for(String con :country){
//                         valueLabel.add(con);
//                     }
//                 }
                
//             }
//         }
//         system.debug('.valueLabel..'+valueLabel);
        
//         //      for (Schema.PicklistEntry val : contrEntries) {
//         for (String val : valueLabel) { 
//             TaxonomyRecord taxonomyRecord= PMP_TaxonomyStore.getTaxonomyRecord(val,val,'view all Label',val,new List<String>(),null,null,taxonomyName,null,false);// Modified as part of TWC1824-3754
//             //      TaxonomyRecord taxonomyRecord= PMP_TaxonomyStore.getTaxonomyRecord(val.getlabel(),'view all Label',val.getValue(),new List<String>(),null,null,taxonomyName,null,false);
//             //      taxonomy.records.put(val.getValue(),taxonomyRecord);   
//             //      taxonomy.topLevelIds.add(val.getValue());
//              taxonomy.expandByDefault=true;      
//             taxonomy.records.put(val,taxonomyRecord);  
//             taxonomy.topLevelIds.add(val); 
           

//         }
//         response.put(taxonomyName,taxonomy); 
//         System.debug('...countries...'+response);
//         return response;
//     }
}