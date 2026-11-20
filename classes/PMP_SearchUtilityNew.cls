@isTest
/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchUtilityNew
* Description : Contains the common classes used throught the Marketplace 2.0 Search.
* Version     : 1.0 
* Created Date: 16-July-2020
* Modification Log :  
* Created By  : Tanzanite Team (Infosys)
********************************************************************************************************************************************************************************************************/


public with sharing class PMP_SearchUtilityNew extends PMP_SearchWrapperStore{
    public PMP_SearchUtilityNew(){
        
    }
    // 27k fix : below line added by priyanka.
//        public static Map<Id,PMP_Company__c> allPartners= new Map<Id,PMP_Company__c>();


//     @AuraEnabled(cacheable=true) 
//     public static String newSearch(String requestJSON){
//         SearchRequest request = (SearchRequest)JSON.deserialize(requestJSON, SearchRequest.class);
//         // system.debug('lang--->'+request);
//         // system.debug('...request.languageCode...'+request.langCode);
//         string langCode = UserInfo.getLanguage();
//         SearchResponse response = new SearchResponse();
//         response.results = new List<PMP_SearchPartnerController.Partner>();
//         response.resultCounts = new Map<String, Integer>();
//         response.totalResults = 0;
//         response.totalPages = 0;
//         List<String> offerings = new List<String>();
//         List<String> partners = new List<String>();
//         String partnerProgType = '';
//         List<PMP_Partner_Program__c>  partnerPrograms = new List<PMP_Partner_Program__c>();
//         System.debug('request.filters:'+request.filters);
//         try{ //error handling
//         if(request.sortType =='relevance' || request.sortType == ''){
//             request.sortType ='SORT_BY_TIER';
//         }
//         if(request.category!=null){ 
//             if(request.searchType == 'pmp-category'){   
//                 //to get the offering ids
//                 offerings=getPartnersAndOfferings(request);
//                 response.results = PMP_SearchProductController.getProducts(offerings,request.page, 12,request.sortType, request.langCode,request.keyword);//PROD DEFECT FIX: added keyword=null parameter at the end
//                 // system.debug('request.page'+request.page);
//             }
//             else{
//                 //to get the partner ids
//                 partners=getPartnersAndOfferings(request);
//                 // Added PartnerProgType Param to fix no pagination issue for Disti page
//                 partnerPrograms = [SELECT Id,Name from PMP_Partner_Program__c where id =: request.category];
//                 if(!partnerPrograms.isEmpty()){
//                     partnerProgType = partnerPrograms[0].Name;
//                 }
//                 List<String> selectedBizOrgs= new List<String>();
//                 if(request.filters.containsKey('Distributor')){
//                     selectedBizOrgs=request.filters.get('Distributor');
//                 }
                
//                 response.results = PMP_SearchPartnerController.getPartners(partners, request.page, 12, request.sortType, request.langCode, request.keyword, partnerProgType,selectedBizOrgs);//PROD DEFECT FIX: added keyword=null parameter at the end
//                 // System.debug('response.results-utility'+response.results);
//             }
            
//         }
        
        
//             if(request.searchType == 'pmp-category'){
//                 response.totalResults = offerings.size();
//             }else if (partnerProgType == PMP_StaticConstants_Partner.distributor){
//                 response.totalResults = response.results.size();
//             }
//             else{
//                 response.totalResults = partners.size();
//             }
            
//         if(response.totalResults < 12){
//             response.resultsPerPage = response.totalResults;
//         }else{
//             response.resultsPerPage = 12;
//         }
//         // system.debug('-----ResultCount----- ' + JSON.serialize(response.resultCounts));
//         // system.debug('-----Response----- ' + response);
//         //Card limit per page set to 12 - Prabuddh
//         response.totalPages = (Integer)Math.ceil(Decimal.valueOf(response.totalResults).divide(/*Limit per page*/12, /* dec digits to round off*/ 1));
        
//         Options opt1 = new Options();
//         opt1.value = 'SORT_BY_TIER';
//         opt1.label = System.Label.PMP_L2_By_Tiers;
//         //opt1.selected = true;
        
//         Options opt2 = new Options();
//         opt2.value = 'SORT_BY_MOST_RECENT';
//         opt2.label = System.Label.PMP_L2_By_Most_Recent;
//         //opt2.selected = false;
        
//         if(request.sortType == 'SORT_BY_MOST_RECENT'){
//             opt2.selected = true;
//         }else{
//             opt1.selected =true;
//         }
        
//         List<Options> sortOptions = new List<Options>();
//         sortOptions.add(opt1);sortOptions.add(opt2);
//         response.sortByOptions = sortOptions;
        
//         // system.debug('Search Results from backend: '+JSON.serialize(response));
//         }
//         catch(Exception e){ //error handling
//             //PMP_Utility.logError(e,'PMP_SearchUtilityNew'); 
//             throw e;
//         }
       
//         return JSON.serialize(response);
//     }
    
//     public static List<String> filterOfferingsBySelectedFilters(List<String> ids, Map<String, List<String>> selectedFilters, String searchType){
//         List<String> offIds = ids;
//         Set<String> filteredId = new Set<String>();
//         List<String> result = new List<String>();
//         filteredId.addAll(offIds);
//         if(searchType == 'pmp-category'){
//             offIds = PMP_SearchContextualFilterController.contfilterResults(selectedFilters, ids);
//             filteredId.retainAll(offIds);
//         }else{
//             if(selectedFilters.containsKey('RegionalCoverage') && !selectedFilters.get('RegionalCoverage').isEmpty()){
//                 offIds = PMP_SearchPartnerController.getRegionResults(selectedFilters.get('RegionalCoverage'));
//                 filteredId.retainAll(offIds);
//             }
            
//         }        
//         if(selectedFilters.containsKey('OfferingCategories') && !selectedFilters.get('OfferingCategories').isEmpty()){
//             offIds = PMP_SearchProductController.filterOfferings(selectedFilters.get('OfferingCategories'), ids);
//             filteredId.retainAll(offIds);
//             // system.debug('FilterId 1 : ' + filteredId.size());
//         }
//         if(selectedFilters.containsKey('OfferingIndustries') && !selectedFilters.get('OfferingIndustries').isEmpty()){
//             offIds = PMP_SearchProductController.filterOfferings(selectedFilters.get('OfferingIndustries'), ids);
//             filteredId.retainAll(offIds);
//             // system.debug('FilterId 2 : ' + filteredId.size());
//         }   
//         if(selectedFilters.containsKey('OfferingApplications') && !selectedFilters.get('OfferingApplications').isEmpty()){
//             offIds = PMP_SearchProductController.filterOfferings(selectedFilters.get('OfferingApplications'), ids);
//             filteredId.retainAll(offIds);
//             // system.debug('FilterId 3 : ' + filteredId.size());
//         }        
//         if(selectedFilters.containsKey('PartnerSpecialties') && !selectedFilters.get('PartnerSpecialties').isEmpty()){
//             //Logic to filter offerings based on selected specialty
//             if(searchType=='pmp-category'){
//                 offIds = PMP_SearchContextualFilterController.getOfferingSpecialtyResults(selectedFilters.get('PartnerSpecialties'));                  
//                 filteredId.retainAll(offIds);            
//             }else if(searchType!='pmp-partner-program'){
//                 offIds = PMP_SearchPartnerController.getSpecialtyResults(selectedFilters.get('PartnerSpecialties'));
//                 filteredId.retainAll(offIds); 
//             }           
//             // system.debug('FilterId 4 : ' + offIds.size());
//         }
//         if(selectedFilters.containsKey('OfferingSegments') && !selectedFilters.get('OfferingSegments').isEmpty()){
//            offIds = getOfferingSegmentResults(selectedFilters.get('OfferingSegments'), offIds, searchType);
//            filteredId.retainAll(offIds);
//             // system.debug('FilterId 5 : ' + filteredId.size());
//         }
//         if(selectedFilters.containsKey('PartnerDirectory') && !selectedFilters.get('PartnerDirectory').isEmpty()){
//             offIds = getPartnerRoleResults(selectedFilters.get('PartnerDirectory'), offIds, searchType);
//             filteredId.retainAll(offIds);
//             // system.debug('FilterId 6 : ' + filteredId.size());
//         }
//         if(selectedFilters.containsKey('Solutions_Software_And_Services_Provider_Type') && !selectedFilters.get('Solutions_Software_And_Services_Provider_Type').isEmpty()){
//            // offIds = getPartnerRoleResults(selectedFilters.get('Solutions_Software_And_Services_Provider_Type'), offIds, searchType);
//            // filteredId.retainAll(offIds);
//             // system.debug('FilterId 6 : ' + filteredId.size());
//         }
//         if(selectedFilters.containsKey('PartnerTier') && !selectedFilters.get('PartnerTier').isEmpty() && searchType!='pmp-partner-program'){
//                 offIds = getPartnerTierResults(selectedFilters.get('PartnerTier'), offIds, searchType);
//                 filteredId.retainAll(offIds);
            
//         }
//         if(selectedFilters.containsKey('IntelPartnerEvents') && !selectedFilters.get('IntelPartnerEvents').isEmpty()){
//             if(searchType == 'pmp-category'){
//                 offIds =  PMP_SearchEventDetailController.getEventOfferings(selectedFilters.get('IntelPartnerEvents'),offIds );                 
//                 filteredId.retainAll(offIds);
//             }else{
//                 offIds = PMP_SearchEventDetailController.getEventPartners(selectedFilters.get('IntelPartnerEvents'),offIds);
//                 filteredId.retainAll(offIds);
//             }
            
//             // system.debug('FilterId 7 : ' + filteredId.size());
//         }
//         if(selectedFilters.containsKey('PartnerA-Z') && !selectedFilters.get('PartnerA-Z').isEmpty()){
//             if(searchType == 'pmp-category'){
//                 List<PMP_Partner_Offering__c> offList= new  List<PMP_Partner_Offering__c>();
//                 if(PMP_Partner_Offering__c.SObjectType.getDescribe().isAccessible()){
//                     offList = [select id from PMP_Partner_Offering__c where id in :ids and PMP_Company_Id__c in :selectedFilters.get('PartnerA-Z')];
//                 }
//                 List<String> offIdList = new List<String>();
//                 for (PMP_Partner_Offering__c off: offList){
//                     offIdList.add(off.Id);
//                 }
//                 offIds= offIdList;
//                 filteredId.retainAll(offIds);
//                 // system.debug('FilterId 8 : ' + filteredId.size());
                
//             }
            
//             else{
//                 List<PMP_Company__c> partnerList= new  List<PMP_Company__c>();
//                 if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){
//                     partnerList = [SELECT Id FROM PMP_Company__c where Id in: ids and id in :selectedFilters.get('PartnerA-Z') ORDER BY Name];
//                 }
//                 List<String> offIdList = new List<String>();
//                 for (PMP_Company__c off: partnerList){
//                     offIdList.add(off.Id);
//                 }
//                 offIds= offIdList;
//                 filteredId.retainAll(offIds);
//                 // system.debug('FilterId 8 : ' + filteredId.size());
                
//             }
            
            
//         }
//         if(selectedFilters.containsKey('Distributor') && !selectedFilters.get('Distributor').isEmpty()){
//             offIds = getDistiBizOrgResults(selectedFilters.get('Distributor'), offIds);
//             filteredId.retainAll(offIds);
//         }
//         if(selectedFilters.containsKey('DistributorComponents') && !selectedFilters.get('DistributorComponents').isEmpty()){
//             offIds = getDistiComponentResults(selectedFilters.get('DistributorComponents'), offIds);
//             filteredId.retainAll(offIds);
            
            
            
//         }
//         if(selectedFilters.containsKey('DistributorSystems&Solutions') && !selectedFilters.get('DistributorSystems&Solutions').isEmpty()){
//             offIds = getDistiSysSolutionResults(selectedFilters.get('DistributorSystems&Solutions'), offIds);
//             filteredId.retainAll(offIds);
//         }
//         if(selectedFilters.containsKey('Country') && !selectedFilters.get('Country').isEmpty()){
//             offIds = getDistiCountryResults(selectedFilters.get('Country'), offIds);
//             filteredId.retainAll(offIds);
//         }
        
//         //for partner segment
//         if(selectedFilters.containsKey('PartnerSegments') && !selectedFilters.get('PartnerSegments').isEmpty() && searchType!='pmp-partner-program'){
//             offIds =filterPartnersSeg(selectedFilters.get('PartnerSegments'), offIds, searchType);                  
//             filteredId.retainAll(offIds);   
//              system.debug('FilterId 13 : ' + filteredId.size());
//             system.debug('FilterId 13.1 : ' + offIds);
//         }
        
//         //for partner industries
//         if(selectedFilters.containsKey('PartnerIndustries') && !selectedFilters.get('PartnerIndustries').isEmpty()){
//             offIds =getPartnerIndustries(selectedFilters.get('PartnerIndustries'), offIds, searchType);                  
//             filteredId.retainAll(offIds);   
//         }
        
//         if(selectedFilters.containsKey('PartnerApplications') && !selectedFilters.get('PartnerApplications').isEmpty()){
//             offIds =getPartnerIndustries(selectedFilters.get('PartnerApplications'), offIds, searchType);                  
//             filteredId.retainAll(offIds);   
//         }
        
        
//         result.addAll(filteredId);
//         system.debug('FilterId 9 : ' + result.size());
        
//         return result;
//     }
    
//     public static List<String> getPartnerTierResults(List<String> optionList, List<String> ids, String searchType){
//         Map<String, String> idTierMap = new Map<String, String>();
//         List<String> finalIds= new List<Id>();
//         Set<String> result = new Set<String>();
//         System.debug('..getPartnerTierResults-->optionList..'+optionList);
//         if(searchType == 'pmp-category'){
//             List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
//             if(PMP_Partner_Offering__c.SObjectType.getDescribe().isAccessible()){
                
//                 offeringList = [SELECT id,PMP_Company_Id__r.PMP_IPA_Badge_Tier_Txt__c
//                                 from PMP_Partner_offering__c where Id IN: ids and PMP_Company_Id__r.PMP_IPA_Badge_Tier_Txt__c!=null];
                
//             }
//             for( PMP_Partner_Offering__c offering : offeringList )
//             {
//                 //if(offering.PMP_Company_Id__r.PMP_IPA_Badge_Tier_Txt__c!=null){
//                 idTierMap.put(offering.Id, offering.PMP_Company_Id__r.PMP_IPA_Badge_Tier_Txt__c);
//                 //}
                
//             }
//         }else{
//             List<PMP_Company__c> partnerList= new List<PMP_Company__c>();
//             if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){
                
//                 partnerList = [SELECT id,PMP_IPA_Badge_Tier_Txt__c
//                                from PMP_Company__c where Id IN: ids and PMP_IPA_Badge_Tier_Txt__c!=null];
//             }
            
//             for( PMP_Company__c offering : partnerList )
//             {
//                 //if(offering.PMP_Account_Program_Membership__c!=null){
//                 // system.debug('..PMP_Account_Program_Membership__c..'+offering.PMP_IPA_Badge_Tier_Txt__c);
//                 idTierMap.put(offering.Id, offering.PMP_IPA_Badge_Tier_Txt__c);
//                 // }
                
//             }
//         }
        
//         for(String offId : idTierMap.keySet()){
//             for(String opt : optionList){
//                 if(idTierMap.containsKey(offId)){
//                     if(idTierMap.get(offId).contains(opt)){
//                         result.add(offId);                    
//                     }
//                 }
                
//             }
            
//         }    
//         finalIds.addAll(result);
//         System.debug('...getPartnerTierResults-->finalIds..'+finalIds.size());
//         return finalIds;
//     }
    
//     public static List<String> getOfferingSegmentResults(List<String> optionList, List<String> ids, String searchType){
//         List<String> finalIds=new List<String>();
//         System.debug('...getOfferingSegmentResults--->optionList'+optionList);
//         if(searchType == 'pmp-category'){
//             List<PMP_Partner_Offering__c> offList = new List<PMP_Partner_Offering__c>();
//             String query =  'SELECT id FROM PMP_Partner_Offering__c WHERE Id IN:ids AND PMP_Business_Segment_Nm__c  INCLUDES (';
            
//             for(String option :optionList){
//                 //Checking the indexof substring
//                 if(optionList.indexOf(option) == optionList.size()-1){
                    
//                     query += '\'' + String.escapeSingleQuotes(option) + '\'';
//                 }else{
//                     query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
//                 }
                
//             }
//             query+=')';
//             String strQuery=query;
//             offList = Database.query(strQuery);
//             for(PMP_Partner_offering__c off : offList){
//                 finalIds.add(off.Id);
//             }
//         }else{
//             List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
//             String query = 'SELECT id FROM PMP_Company__c WHERE Id IN:ids AND PMP_Partner_Segment_Nm__c INCLUDES (';
            
//             for(String option :optionList){
//                 //Checking the indexof substring
//                 if(optionList.indexOf(option) == optionList.size()-1){
                    
//                     query += '\'' + String.escapeSingleQuotes(option) + '\'';
//                 }else{
//                     query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
//                 }
                
//             }
//             query+=')';
//             String strQuery=query;
//             partnerList = Database.query(strQuery);
//             for(PMP_Company__c partner : partnerList){
//                 finalIds.add(partner.Id);
//             }
//         }
        
        
//         return finalIds;
//     }
    
//     public static List<String> getPartnerRoleResults(List<String> optionList, List<String> offerings, String searchType){
//         List<Id> offeringIds= new List<Id>();
//         List<Id> result = null;
//         List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
//         List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
//         System.debug('.getPartnerRoleResults-->optionList'+optionList);
//         System.debug('.getPartnerRoleResults-->offerings'+offerings);
//         System.debug('.getPartnerRoleResults-->searchType'+searchType);
//         List<PMP_Partner_Program__c> partnerRoleList= new List<PMP_Partner_Program__c>();
//         if(PMP_Partner_Program__c.SObjectType.getDescribe().isAccessible()){
//             partnerRoleList =[SELECT id,Name, PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c,PMP_Partner_Role_Parent_Id__c
//                               from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE 
//                               ORDER BY Name];
//         }
//         List<String> childRoles = new List<String>();
//         String parentRoleId = '';
//         List<String> roles=new List<String>();
//         for(PMP_Partner_Program__c role: partnerRoleList){
//             if(optionList.contains(role.Id)){
//                 roles.add(role.PMP_Partner_Program_Value_Txt__c); 
//             }
//             if(role.PMP_Partner_Role_Parent_Id__c != null){
//                 childRoles.add(role.PMP_Partner_Program_Value_Txt__c);
//                 parentRoleId = role.PMP_Partner_Role_Parent_Id__c;
//             }
            
//         }
        
//         if(optionList.contains(parentRoleId)){
//             roles.addAll(childRoles);
//         }
        
//         optionList.clear();
//         optionList.addAll(roles);
//         // System.debug('..optionList...'+optionList);
        
//         if (!optionList.isEmpty()){
//             if(searchType == 'pmp-category'){
//                 String query =  'SELECT id FROM PMP_Partner_Offering__c WHERE Id IN:offerings AND PMP_Company_Id__r.PMP_Partner_Program_nm__c  INCLUDES (';
                
//                 for(String option :optionList){
//                     //Checking the indexof substring
//                     if(optionList.indexOf(option) == optionList.size()-1){
                        
//                         query += '\'' + String.escapeSingleQuotes(option) + '\'';
//                     }else{
//                         query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
//                     }
//                 }
                
//                 query+=')';
//                 String strQuery=query;
//                 offeringList = Database.query(strQuery);
                
//                 for( PMP_Partner_Offering__c offering : offeringList )
//                 {
//                     offeringIds.add(offering.Id);
//                 }
//                 result = offeringIds;
//             }else{
//                 String query = 'SELECT id FROM PMP_Company__c WHERE Id IN:offerings AND PMP_Partner_Program_nm__c INCLUDES (';
//                 for(String option :optionList){
//                     //Checking the indexof substring
//                     if(optionList.indexOf(option) == optionList.size()-1){
                        
//                         query += '\'' + String.escapeSingleQuotes(option) + '\'';
//                     }else{
//                         query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
//                     }
//                 }
//                 query+=')';
//                 String strQuery=query;
//                 partnerList = Database.query(strQuery);
//                 // System.debug('partnerList:'+partnerList);
//                 for( PMP_Company__c offering : partnerList )
//                 {
//                     offeringIds.add(offering.Id);
//                 }
//                 result = offeringIds;
//             }
            
//         }
//         // System.debug('.getPartnerRoleResults-->result'+result);
        
//         return result;
//     }
    
//     public static List<String> getDistiBizOrgResults(List<String> optionList, List<String> partners){
        
//         List<String> result = new List<String>();
//         List<PMP_Company__c> partnerList= new List<PMP_Company__c>();
//         if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){
//             partnerList = [SELECT id, PMP_Biz_Org_Type_Txt__c from PMP_Company__c where id IN: partners AND PMP_Biz_Org_Type_Txt__c!=null AND PMP_Biz_Org_Type_Txt__c NOT IN ('IoT Solution Aggregator')];
//         }
//         for(PMP_Company__c partner : partnerList){
            
//             for(String biz : partner.PMP_Biz_Org_Type_Txt__c.split('\\;')){
//                 if(optionList.contains(biz)){
//                     if(!result.contains(partner.id)){
//                         result.add(partner.id);
//                     }
//                 }
//             }
//         }
        
//         return result;
//     }
    
//     public static List<String> getDistiComponentResults(List<String> optionList, List<String> partners){
//         List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
//         List<String> result = new List<String>();
//         String query = 'SELECT id, PMP_Disti_Components_Nm__c from PMP_Company__c where Id IN: partners AND PMP_Disti_Components_Nm__c INCLUDES (';
        
//         for(String option :optionList){
//             //Checking the indexof substring 
//             if(optionList.indexOf(option) == optionList.size()-1){
                
//                 query += '\'' + String.escapeSingleQuotes(option) + '\'';
//             }else{
//                 query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
//             }
//         }
        
//         query+=')';
//         String strQuery=query;
//         partnerList = Database.query(strQuery);
//         for(PMP_Company__c partner : partnerList){
//             result.add(partner.Id);
//         }
//         return result;
//     }
    
//     public static List<String> getDistiSysSolutionResults(List<String> optionList, List<String> partners){
//         List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        
//         List<String> result = new List<String>();
//         String query = 'SELECT id, PMP_Disti_Sys_Solutions_Nm__c from PMP_Company__c where Id IN: partners AND PMP_Disti_Sys_Solutions_Nm__c INCLUDES (';
        
//         for(String option :optionList){
//             //Checking the indexof substring 
//             if(optionList.indexOf(option) == optionList.size()-1){
//                 option= option.replace('_', ' ');

//                 query += '\'' + String.escapeSingleQuotes(option) + '\'';
//             }else{
//                 option= option.replace('_', ' ');
//                 query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
//             }
//         }
        
//         query+=')';
//         String strQuery=query;
//         partnerList = Database.query(strQuery);
//         for(PMP_Company__c partner : partnerList){
//             result.add(partner.Id);
//         }
//         return result;
        
//     }
    
//     public static List<String> getDistiCountryResults(List<String> optionList, List<String> partners) {
//         List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
//         List<String> result = new List<String>();
//         String query = 'SELECT id, PMP_Disti_Country_Coverage_Txt__c from PMP_Company__c where Id IN :partners';
//         Set<String> countries = new Set<String>();
        
//         if(optionList != NULL) {
//             for(String cntry : optionList) {
//                 if(cntry != NULL)
//                     countries.add(cntry.toLowerCase());
//             }
//         }  
//         String strQuery=query;
//         partnerList = Database.query(strQuery);
//         for(PMP_Company__c partner : partnerList) {
            
//             String cc = partner.PMP_Disti_Country_Coverage_Txt__c;
//             if(cc != NULL) {
//                 cc = cc.toLowerCase();
//                 for(String cnt : countries) {
//                     if(cc.contains(cnt)) {
//                         result.add(partner.Id);
//                     }
//                 }
//             }
//         }
//         return result;
//     }
    
//     public static List<String> filterOfferingsBySection(String categoryId, List<String> offerings){
//         List<PMP_Partner_Offering_Category__c> offList = new List<PMP_Partner_Offering_Category__c>();
//         boolean isIntelEmployee = PMP_Utility.isIntelEmployee();
//         string novalue = PMP_Utility.getValue('PMP_PreReleaseCheck_Nm');
//         if(PMP_Partner_Offering_Category__c.SObjectType.getDescribe().isAccessible()) {
//             if(isIntelEmployee == true) {
//                 //Sai Thotakura
//                 //Updated the filter conditions to include pre-release approved offerings only for Intel Employees
//                 /*
//                 1. Fully Published Copies
//                 2. Pre-release count greater than 0 approved offerings
//                 3. Pre-release count is zero and pre release check : NO offerings
//                 4. Offerings with future start date
//                 */
//                 offList = [select PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where 
//                 PMP_Category_Id__c =:categoryId and PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c!=null 
//                 and PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c!=null
//                 and (( PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published and ( PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY and PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = false))
//                 OR
//                 (PMP_Offering_Id__r.PMP_Working_Copy_Id__c = null and PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Approved and PMP_Offering_Id__r.PMP_Pre_Release_Item_Count_Num__c >:PMP_StaticConstants_MasterData.Zero and PMP_Offering_Id__r.PMP_Pre_Release_Check_Nm__c != null)
//                 OR
//                 (PMP_Offering_Id__r.PMP_Working_Copy_Id__c = null and PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Approved and PMP_Offering_Id__r.PMP_Pre_Release_Item_Count_Num__c =:PMP_StaticConstants_MasterData.Zero and PMP_Offering_Id__r.PMP_Pre_Release_Check_Nm__c =:novalue and PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c != null)
//                 OR
//                 (PMP_Offering_Id__r.PMP_Working_Copy_Id__c = null and PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Approved and PMP_Offering_Id__r.PMP_Pre_Release_Item_Count_Num__c =:PMP_StaticConstants_MasterData.Zero and PMP_Offering_Id__r.PMP_Pre_Release_Check_Nm__c = null and PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c > TODAY))
//                 and PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = False]; 
//             } else {
//                 //this query is for public user context
//                 offList = [select PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where 
//                 PMP_Category_Id__c =:categoryId and PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c!=null 
//                 and PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c!=null
//                 and PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published and PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY and PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = false
//                 and PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = False ];
//             }
//         }
//         Set<Id> offIds = new Set<Id>();
//         for(PMP_Partner_Offering_Category__c off : offList){
//             offIds.add(off.PMP_Offering_Id__c);
//         } 
//         List<Id> offIdsList=new List<Id>();
//         offIdsList.addAll(offIds);    
//         return offIdsList;
//     }
    
//     public static List<String> filterPartnersByRole(String roleId, List<String> partners){
//         List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
//         List<String> roleList = new List<String>();
//         List<String> result = new List<String>();
//         List<PMP_Partner_Program__c> seoRoleList= new List<PMP_Partner_Program__c>();
//         if(PMP_Partner_Program__c.SObjectType.getDescribe().isAccessible()){
            
//             seoRoleList = [SELECT id, PMP_Is_Active_Ind__c, PMP_Partner_Program_Value_Txt__c
//                            from PMP_Partner_Program__c
//                            where (id =:roleId OR PMP_Partner_Role_Parent_Id__c =:roleId) AND PMP_Is_Active_Ind__c=TRUE];
//         }
//         for(PMP_Partner_Program__c role : seoRoleList){
//             roleList.add(role.PMP_Partner_Program_Value_Txt__c);
//         }
//         // System.debug('filterPartnersByRole-->roleList'+roleList);
        
//         if(!roleList.isEmpty()){
//             //27k fix: PMP_Partner_Program_nm__c is added in the fields list to query
//             String query =  'SELECT id,PMP_Partner_Program_nm__c FROM PMP_Company__c WHERE PMP_Company_Lifecycle_Status_Nm__c =\'Published\' AND PMP_Benefit_Update_Ind__c=False AND PMP_Partner_Program_nm__c  INCLUDES (';
            
//             for(String option :roleList){
//                 //Checking the indexof substring
//                 if(roleList.indexOf(option) == roleList.size()-1){
                    
//                     query += '\'' + String.escapeSingleQuotes(option) + '\'';
//                 }else{
//                     query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
//                 }
                
//             }
//             query+=')';
//             // system.debug('dynamic query : '+ query);
//             String strQuery=query;
//             partnerList = Database.query(strQuery);
//             // system.debug('list size : '+ partnerList.size());
//             for(PMP_Company__c com : partnerList){
//                 result.add(com.Id);
//                 // 27k fix : below line added by priyanka
//                 //allPartners.put(com.Id, com);

//             }
//         }
        
        
        
//         return result;
//     }
    
//     public static List<String> filterPartnersBySpecialty(String specialtyId, List<String> partners,String langCode, String sortField){
//         List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
//         List<String> specialtyList = new List<String>();
//         List<String> result = new List<String>();
//         List<PMP_Partner_Specialty__c> seoSpecialtyList= new List<PMP_Partner_Specialty__c>();
//         if(PMP_Partner_Specialty__c.SObjectType.getDescribe().isAccessible()){
            
//             seoSpecialtyList = [SELECT id, Name,PMP_Partner_Specialty_Japanese_Nm__c,PMP_Partner_Specialty_Chinese_Nm__c, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c where id =:specialtyId AND PMP_Is_Active_Ind__c = TRUE];
//         }
//         String specialtyName = PMP_SearchUtilityController.getFieldApiName('PMP_Partner_Specialty__c', 'Name',langCode);
//         if(String.isEmpty(specialtyName)){
//             specialtyName = 'Name';
//         }
//         system.debug('specialty1:::'+specialtyName);
//         for(PMP_Partner_Specialty__c spec : seoSpecialtyList){
//             specialtyList.add((String)spec.get(specialtyName));
//         }
//         system.debug('spec1::'+specialtyList);
//         system.debug('specId::'+specialtyId);
//         if(!specialtyList.isEmpty()){
//            //all Partners static list changes : PMP_Partner_Program_nm__c,PMP_IPA_Badge_Tier_Txt__c,toLabel(PMP_Account_Specialty__c),PMP_Partner_Segment_Nm__c

//             String query =  'SELECT id,PMP_Partner_Program_nm__c,PMP_IPA_Badge_Tier_Txt__c,toLabel(PMP_Account_Specialty__c),PMP_Partner_Segment_Nm__c FROM PMP_Company__c WHERE PMP_Company_Lifecycle_Status_Nm__c =\'Published\' AND PMP_Benefit_Update_Ind__c=False AND toLabel(PMP_Account_Specialty__c) INCLUDES (';
            
//             for(String option :specialtyList){
//                 //Checking the indexof substring
//                 if(specialtyList.indexOf(option) == specialtyList.size()-1){
                    
//                     query += '\'' + String.escapeSingleQuotes(option) + '\'';
//                 }else{
//                     query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
//                 }
                
//             }
//             query+=')';
            
//             //pagination fix: added by priyanka
//             String sortBy='';
//             if(sortField == PMP_StaticConstants_Partner.sortFieldTier){
//                 sortBy = PMP_StaticConstants_Partner.sortByTierPartner ; 
//                 //sortBy= 'PMP_Partner_Id__r.PMP_Badge_Tier_Sequence_Nbr__c,PMP_Partner_Id__r.Name';
//             }else{
//                 sortBy = PMP_StaticConstants_Partner.sortByMostRecentPartner;
//                 //sortBy= 'PMP_Partner_Id__r.PMP_Company_Status_Update_Dt__c DESC NULLS LAST';
                
//             }
//             query= query+' ORDER BY '+sortBy;
//             //pagination fix: added by priyanka end

//             String strQuery=query;
//             partnerList = Database.query(strQuery);
//             // system.debug('spec3::'+partnerList);
//             // system.debug('strQuery::'+strQuery);
//             for(PMP_Company__c com : partnerList){
//                 result.add(com.Id);
//                 //populate all Partners
//                 allPartners.put(com.Id, com);
//             }
//         }
        
//         return result;
//     }
    
//     public static List<String> filterPartnersByIndustry(String indShadowId, List<String> partners, String sortField){
        
//         String industryId = getMasterIdByShadowId(indShadowId);
//         List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
//         List<String> result = new List<String>();
//         List<PMP_Partner_Category__c> partnerCatList= new List<PMP_Partner_Category__c>();
//         //pagination fix : commented by priyanka
//         /*if(PMP_Partner_Category__c.SObjectType.getDescribe().isAccessible()){
//             partnerCatList = [SELECT PMP_Partner_Id__c FROM PMP_Partner_Category__c WHERE PMP_Category_Id__c =:industryId 
//                               AND PMP_Category_Id__r.PMP_Active_Ind__c = true
//                               AND PMP_Partner_Id__r.PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published AND PMP_Partner_Id__r.PMP_Benefit_Update_Ind__c=False
//                              ];
//         }*/
//         //pagination fix : commented by priyanka end

//         //pagination fix: added by priyanka (added few fields to check the all partners static list)
//         String CatList='SELECT PMP_Partner_Id__c,PMP_Partner_Id__r.PMP_Partner_Program_nm__c,toLabel(PMP_Partner_Id__r.PMP_Account_Specialty__c),PMP_Partner_Id__r.PMP_Partner_Segment_Nm__c FROM PMP_Partner_Category__c WHERE PMP_Category_Id__c =:industryId  AND PMP_Category_Id__r.PMP_Active_Ind__c = true AND PMP_Partner_Id__r.PMP_Company_Lifecycle_Status_Nm__c =\'Published\' AND PMP_Partner_Id__r.PMP_Benefit_Update_Ind__c=False ORDER BY ';
//         String sortBy='';
//         if(sortField == PMP_StaticConstants_Partner.sortFieldTier){
//             sortBy= 'PMP_Partner_Id__r.PMP_Badge_Tier_Sequence_Nbr__c,PMP_Partner_Id__r.Name';
//         }else{
//             sortBy= 'PMP_Partner_Id__r.PMP_Company_Status_Update_Dt__c DESC NULLS LAST';
            
//         }
//         CatList=CatList+sortBy;
//         if(PMP_Partner_Category__c.SObjectType.getDescribe().isAccessible()){
//             partnerCatList=Database.query(CatList);
//         }
//         //pagination fix: added by priyanka end
        
        
//         for(PMP_Partner_Category__c partCat: partnerCatList){
//             result.add(partCat.PMP_Partner_Id__c);
//             //allPartners changes start
//             PMP_Company__c com= new PMP_Company__c(Id=partCat.PMP_Partner_Id__c,PMP_Partner_Program_nm__c=partCat.PMP_Partner_Id__r.PMP_Partner_Program_nm__c,
//                                                        PMP_Partner_Segment_Nm__c=partCat.PMP_Partner_Id__r.PMP_Partner_Segment_Nm__c,PMP_Account_Specialty__c=partCat.PMP_Partner_Id__r.PMP_Account_Specialty__c);
//             //populate all Partners
//             allPartners.put(com.id,com);
//             //allPartners Changes end
//         }
        
//         return result;
//     }
    
//     public static List<String> filterPartnersBySegment(String segmentId, List<String> partners, String sortField){
//         List<PMP_Company__c> partnerList = new List<PMP_Company__c>();        
//         List<String> result = new List<String>();
//         List<PMP_Partner_Segment__c> segmentList= new List<PMP_Partner_Segment__c>();
//         if(PMP_Partner_Segment__c.SObjectType.getDescribe().isAccessible()){
            
//             segmentList = [SELECT id,PMP_Partner_Segment_Value_Txt__c from PMP_Partner_Segment__c where id=: segmentId];
//         }
//         //pagination fix: commented by priyanka - start
//         /*if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){
//             partnerList = [Select id from PMP_Company__c where PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published AND PMP_Benefit_Update_Ind__c=False AND  PMP_Partner_Segment_Nm__c INCLUDES (:segmentList[0].PMP_Partner_Segment_Value_Txt__c)];
//         }*/
//         //pagination fix: commented by priyanka - end

//         //pagination fix: added by priyanka
//         String segment= segmentList[0].PMP_Partner_Segment_Value_Txt__c;
//         //all partners static list change: PMP_Partner_Program_nm__c,PMP_IPA_Badge_Tier_Txt__c,toLabel(PMP_Account_Specialty__c),PMP_Partner_Segment_Nm__c
//         String query='Select id,PMP_Partner_Program_nm__c,PMP_IPA_Badge_Tier_Txt__c,toLabel(PMP_Account_Specialty__c),PMP_Partner_Segment_Nm__c from PMP_Company__c where PMP_Company_Lifecycle_Status_Nm__c =\'Published\' AND PMP_Benefit_Update_Ind__c=False AND  PMP_Partner_Segment_Nm__c INCLUDES (:segment) ORDER BY ';
//         string sortBy='';
//         if(sortField == PMP_StaticConstants_Partner.sortFieldTier){
//             sortBy = PMP_StaticConstants_Partner.sortByTierPartner ; 
//         }else{
//             sortBy = PMP_StaticConstants_Partner.sortByMostRecentPartner;
//         }
//         query= query+sortBy;
//         if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){
//             partnerList= Database.query(query);
//         }
//         //pagination fix: added by priyanka - end

//         for(PMP_Company__c com : partnerList){
//             result.add(com.Id);
//             //populate all partners
//             allPartners.put(com.Id,com); 

//         }        
        
//         return result;
//     }
    
//     public static String getMasterIdByShadowId(String shadowId){
//         PMP_Category_Partner__c shad = new PMP_Category_Partner__c();
//         if(String.isNotEmpty(shadowId)){
//             if(PMP_Category_Partner__c.SObjectType.getDescribe().isAccessible()){ 
//                 shad = [select id, PMP_Category_Id__c from PMP_Category_Partner__c where id =:shadowId limit 1];
//             }
//         }
        
//         return shad.PMP_Category_Id__c;
//     }
    
//     public class SearchResponse {
//         @AuraEnabled public List<Object> results {get; set;} //TBD to change type to cards
//         @AuraEnabled public Map<String, Integer> resultCounts {get; set;}
//         @AuraEnabled public Integer resultsPerPage {get; set;}
//         @AuraEnabled public Integer totalResults {get; set;}
//         @AuraEnabled public Integer totalPages {get; set;}
//         @AuraEnabled public List<Options> sortByOptions {get; set;}
//         //old design
        
//         /*  @AuraEnabled public String keyword { get; set; }
// @AuraEnabled public String category { get; set; }
// @AuraEnabled public String searchType { get; set; }
// @AuraEnabled public String sortField { get; set; }
// @AuraEnabled public String sortDirection { get; set; }
// @AuraEnabled public Integer currentPage { get; set; }
// @AuraEnabled public Integer pageSize { get; set; }
// @AuraEnabled public Integer totalCount { get; set; }
// @AuraEnabled public Integer totalProductCount { get; set; }
// @AuraEnabled public Integer totalPartnerCount { get; set; } 
// @AuraEnabled public List<PMP_SearchProductController.Product> productResults { get; set; }
// @AuraEnabled public List<PMP_SearchPartnerController.Partner> partnerResults { get; set; }
// @AuraEnabled public List<Filter> filters { get; set; }
// @AuraEnabled public List<String> suggestions { get; set; }
// @AuraEnabled public String searchHeading { get; set; }
// @AuraEnabled public String categoryDescription { get; set; }
// @AuraEnabled public String learMoreLink { get; set; }   //Added by Megha as part of Specialty learnMoreLink

// @AuraEnabled public Map<String, List<String>> selectedFilters { get; set; }*/
//     }
    
//     //added for partner segment contextual filter
//     public static List<String> filterPartnersSeg(List<String> optionList, List<String> partners, String searchType){
//         List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
//         List<String> result = new List<String>();
//         List<String> seoSegments = new List<String>(); 
//         List<PMP_Partner_Segment__c> segmentsList= new List<PMP_Partner_Segment__c>();
//         if(PMP_Partner_Segment__c.SObjectType.getDescribe().isAccessible()){
            
//             segmentsList = [SELECT id, PMP_Is_Active_Ind__c,PMP_Partner_Segment_Value_Txt__c from PMP_Partner_Segment__c where PMP_Is_Active_Ind__c=True AND id In :optionList];
//         }
//         for(PMP_Partner_Segment__c segment :segmentsList){
//             seoSegments.add(segment.PMP_Partner_Segment_Value_Txt__c);
            
//         }                   
        
//         string allstring = string.join(seoSegments,';');
//         if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){
            
//             partnerList =[SELECT id,PMP_Partner_Segment_Nm__c from PMP_Company__c where Id IN: partners AND PMP_Partner_Segment_Nm__c INCLUDES (:allstring)];
//         }
//         for(PMP_Company__c partner : partnerList){
//             result.add(partner.Id);
//         }
        
//         return result;
//     }
    
    
//     //added to get the offerings related to partner industries
//     public static List<String> getPartnerIndustries(List<String> optionList, List<String> partners, String searchType){
        
//         List<String> catIds= new List<String>();
//         List<String> partnerIds= new List<String>();
//         List<PMP_Category_Partner__c> shadowIndustries= new  List<PMP_Category_Partner__c>();
//         if(PMP_Category_Partner__c.SObjectType.getDescribe().isAccessible()){
            
//             shadowIndustries= [select PMP_Category_Id__c from PMP_Category_Partner__c where id IN:optionList];
//         }
//         System.debug(shadowIndustries);
        
//         for(PMP_Category_Partner__c shadowRec: shadowIndustries){
//             catIds.add(shadowRec.PMP_Category_Id__c);
//         }
//         List<PMP_Partner_Category__c> partnerList= new List<PMP_Partner_Category__c> ();
//         if(PMP_Partner_Category__c.SObjectType.getDescribe().isAccessible()){
            
//             partnerList= [SELECT PMP_Partner_Id__c, PMP_Category_Id__c               
//                           FROM PMP_Partner_Category__c WHERE PMP_Partner_Id__c in:partners AND PMP_Category_Id__c in:catIds];
            
//         }
//         for(PMP_Partner_Category__c partner:partnerList){
//             partnerIds.add(partner.PMP_Partner_Id__c);
            
//         }
//         return partnerIds;
//     }
    
    
    
    
    
//     public static String checkIfDistiOrServiceProvider(String roleId){
//         PMP_Partner_Program__c role = [SELECT id, Name from PMP_Partner_Program__c where id=:roleId];
        
//         return role.Name;
//     }
    
    
 
// /*******************************************************************************************************************************************************************************************************
// * Method Name : getPartnersAndOfferings
// * Description : Method created as part of the US -US801948 , methods return either partners ids or offering ids based on search-context
// * Version     : 1.0 
// * Created Date: 07-Oct-2020
// * Created By  : Tanzanite Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
 
    
//     public static List<String> getPartnersAndOfferings(SearchRequest request){
//         List<String> Ids = new List<String>();
//         if(request.category!=null){ 
//             if(request.searchType == 'pmp-category'){               
//                 Ids = filterOfferingsBySection(request.category,Ids);
                
//                 if(!request.filters.isEmpty()){
//                     Ids = filterOfferingsBySelectedFilters(Ids, request.filters, request.searchType);
//                     //system.debug('offerings after con filters : ' + offerings.size());
//                 }
                
//                 if(String.isNotBlank(request.keyword)){//request.keyword != null is changed to String.isNotBlank(request.keyword) done similar to partner
//                     Ids = PMP_SearchProductController.getOfferingIds(request.keyword, Ids);
//                 }
                
//             }else{
//                 if(request.searchType == 'pmp-partner-program'){
                    
//                     //Ids = filterPartnersByRole(request.category, null);
//                     Ids = getPartners(request.category,request.filters, request.sortType) ;//Added by Abhishek , //pagination fix: added sort type parameter - changed by priyanka
//                     system.debug('inside the pmp-partner-program '+Ids);
                    
//                 }else if(request.searchType == 'pmp-partner-category'){
//                     Ids = filterPartnersByIndustry(request.category, null, request.sortType); //pagination fix: added sort type parameter - changed by priyanka
//                 }else if(request.searchType == 'pmp-partner-specialty'){
//                     Ids = filterPartnersBySpecialty(request.category, null,request.langCode,request.sortType); //pagination fix: added sort type parameter - changed by priyanka
//                 }else if(request.searchType == 'pmp-partner-segment'){
//                     Ids = filterPartnersBySegment(request.category, null,request.sortType); //pagination fix: added sort type parameter - changed by priyanka
//                 }   
//                 if(!request.filters.isEmpty()){
//                     Ids = filterOfferingsBySelectedFilters(Ids, request.filters, request.searchType);
//                     // system.debug('...PARTNERS..'+Ids);
//                 }
                
//                 if(String.isNotBlank(request.keyword)){ 
//                     system.debug('...Keyword Search..>'+request.keyword);
//                     Ids = PMP_SearchPartnerController.getPartnerList(request.keyword, Ids);
//                 }
                
//             }
            
//         }
//         return Ids;
        
//     }
    
 
//      /*******************************************************************************************************************************************************************************************************
// * Method Name : getResultCountsForFilters
// * Description : Method created as part of the US -US801948 , this returns response that has result counts
// * Version     : 1.0 
// * Created Date: 07-Oct-2020
// * Modification Log :
// * Created By  : Tanzanite Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
   
    
//     @AuraEnabled(cacheable=true) 
//     public static String getResultCountsForFilters(String requestJSON){
//         SearchRequest request = (SearchRequest)JSON.deserialize(requestJSON, SearchRequest.class);
//         //system.debug('lang--->'+request);
//         //system.debug('...request.languageCode...'+request.langCode);
//         SearchResponse response = new SearchResponse();
//         response.resultCounts = new Map<String, Integer>();
//         Boolean isDisti = false;
//         Boolean isServiceProvider = false;
        
//         List<String> offerings = new List<String>();
//         List<String> partners = new List<String>();
//         //try{
//         if(request.category!=null){ 
//             if(request.searchType == 'pmp-category'){               
//                 offerings=getPartnersAndOfferings(request);
//             }
//             else{
//                 partners=getPartnersAndOfferings(request);
//                 if(request.searchType == 'pmp-partner-program'){
//                     String roleName = checkIfDistiOrServiceProvider(request.category);
//                     if(roleName == PMP_StaticConstants_Partner.distributor){
//                         isDisti = true;
//                     }else if(roleName == PMP_StaticConstants_Partner.serviceProviders){
//                         isServiceProvider = true;
//                     }
                    
//                 }
                
//             }
//         }
//         if(request.searchType == 'pmp-category' && offerings.size() > 0){
//                 response.resultCounts = PMP_SearchResponseResultCountStore.getResultCount(request.searchType, request.filters, offerings, isDisti, isServiceProvider,request.langCode);
  
//         }else if(partners.size() > 0){
//                 response.resultCounts = PMP_SearchResponseResultCountStore.getResultCount(request.searchType, request.filters, partners, isDisti, isServiceProvider,request.langCode);
            
//         }
//         //}
//        /* catch(Exception e){
//             //PMP_Utility.logError(e,'PMP_SearchUtilityNew'); 
//             throw e;
//         }*/
       
//         // system.debug('Result Counts from Backend: '+response.resultCounts);

//         return JSON.serialize(response);
        
//     } 
//     /* 
//     Method by Abhishek for search performance POC
//     */
//     public static string getAdditionalFilterCriteria(Map<String, List<String>> selectedFilters){
//         String queryParam = null;
//         if(selectedFilters.containsKey('PartnerSpecialties') && !selectedFilters.get('PartnerSpecialties').isEmpty()){
//                 List<PMP_Partner_Specialty__c> specialtyList = new List<PMP_Partner_Specialty__c>();
//                 List<String> optionList = selectedFilters.get('PartnerSpecialties');
//                 if(Schema.sObjectType.PMP_Partner_Specialty__c.isAccessible()){
//                     specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c where id in:optionList  AND PMP_Is_Active_Ind__c = TRUE ];//WITH SECURITY_ENFORCED
//                 }
//                 optionList = new List<String>();
//                 for(PMP_Partner_Specialty__c specData: specialtyList){
//                     optionList.add(specData.Name); 
//                 }
//                 // system.debug('OptionList : '+ optionList);
//                 if (!optionList.isEmpty()){
//                     string tempString =  ' '+ 'AND toLabel(PMP_Account_Specialty__c) INCLUDES (';
                    
//                     for(String option :optionList){
//                         if(optionList.indexOf(option) == optionList.size()-1){
//                             tempString += '\'' + String.escapeSingleQuotes(option.replace('_',' ')) + '\'';
//                         }else{
//                             tempString += '\'' + String.escapeSingleQuotes(option.replace('_',' ')) + '\''+ ',';
//                         }
//                     }
//                     tempString += ')';
//                     queryParam = queryParam == null ? tempString : queryParam + tempString;
//             }
        
//         }
//         if(selectedFilters.containsKey('PartnerSegments') && !selectedFilters.get('PartnerSegments').isEmpty()){
            
//             List<String> optionList = new List<String>(); 
//             List<PMP_Partner_Segment__c> segmentsList= new List<PMP_Partner_Segment__c>();
//             if(PMP_Partner_Segment__c.SObjectType.getDescribe().isAccessible()){
                
//                 segmentsList = [SELECT id, PMP_Is_Active_Ind__c,PMP_Partner_Segment_Value_Txt__c from PMP_Partner_Segment__c where PMP_Is_Active_Ind__c=True AND id In :selectedFilters.get('PartnerSegments')];
//             }
//             for(PMP_Partner_Segment__c segment :segmentsList){
//                 optionList.add(segment.PMP_Partner_Segment_Value_Txt__c);
                
//             }                   
            
//             //List<string> optionList = selectedFilters.get('PartnerSegments'); 
//             String tempString = ' ' +'AND PMP_Partner_Segment_Nm__c INCLUDES (';
            
//             for(String option :optionList){
//                 //Checking the indexof substring
//                 if(optionList.indexOf(option) == optionList.size()-1){
                    
//                     tempString += '\'' + String.escapeSingleQuotes(option) + '\'';
//                 }else{
//                     tempString += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
//                 }
                
//             }
//             tempString+=')';
            
            
            
            
//             queryParam = queryParam == null ? tempString : queryParam + tempString;   
//         }
//         if(selectedFilters.containsKey('PartnerTier') && !selectedFilters.get('PartnerTier').isEmpty()){
//             List<string> optionList = selectedFilters.get('PartnerTier'); 
//             string tempString = null;
//             if(optionList.size()>1 ){
//                 tempString =  ' ' + 'And (PMP_IPA_Badge_Tier_Txt__c = ' + '\'' + optionList[0] + '\''  ;
//                 for(integer i =1 ; i <optionList.size() ; i++){
//                     tempString = tempString + ' ' + 'Or PMP_IPA_Badge_Tier_Txt__c = ' +'\'' +optionList[i] + '\'';
                    
//                 }
//                 tempString = tempString + ')';
//                 queryParam = queryParam == null ? tempString : queryParam + tempString;   
//             }
//             else{
//                 tempString =  ' ' + 'And (PMP_IPA_Badge_Tier_Txt__c = ' + '\'' +optionList[0] +'\'' + ')';
//                 queryParam = queryParam == null ? tempString : queryParam + tempString; 
//             }
             
//         }
//         return queryParam;   
//     }
//     public static List<String>getPartners(String roleId, Map<String, List<String>> selectedFilters, String sortField){
//        // System.debug('venky2'+selectedFilters);
//         List<string> allSelectedRoles = New List<string>();
//         allSelectedRoles.add(roleId);
//         if(selectedFilters.containsKey('Solutions_Software_And_Services_Provider_Type') && 
//         !selectedFilters.get('Solutions_Software_And_Services_Provider_Type').isEmpty())
//         {
//                 allSelectedRoles.addAll(selectedFilters.get('Solutions_Software_And_Services_Provider_Type'));
//         }
//         List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
//         List<String> roleList = new List<String>();
//         List<String> childRoles = new List<String>();
//         String parentRoleId = '';
//         List<String> result = new List<String>();
//         List<PMP_Partner_Program__c> seoRoleList= new List<PMP_Partner_Program__c>();
//         if(PMP_Partner_Program__c.SObjectType.getDescribe().isAccessible()){
            
//             seoRoleList = [SELECT id,Name, PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c,
//                                 PMP_Partner_Role_Parent_Id__c
//                               from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE 
//                               ORDER BY Name];
//         }
//         for(PMP_Partner_Program__c role : seoRoleList){
            
//             if(allSelectedRoles.size()>0 && allSelectedRoles.contains(role.Id)){
//                 roleList.add(role.PMP_Partner_Program_Value_Txt__c);
//             }
//             if(role.PMP_Partner_Role_Parent_Id__c != null){
//                 childRoles.add(role.PMP_Partner_Program_Value_Txt__c);
//                 parentRoleId = role.PMP_Partner_Role_Parent_Id__c;
//             } 
            
//         }
//         if(allSelectedRoles.size()==1 && allSelectedRoles.contains(parentRoleId)  ){
//             roleList.addAll(childRoles);
//         } 
        
//         // System.debug('filterPartnersByRole-->roleList'+roleList);
        
//         if(!roleList.isEmpty()){
//             String query =  'SELECT id,PMP_Partner_Program_nm__c,PMP_IPA_Badge_Tier_Txt__c,toLabel(PMP_Account_Specialty__c),PMP_Partner_Segment_Nm__c FROM PMP_Company__c WHERE PMP_Company_Lifecycle_Status_Nm__c =\'Published\' AND PMP_Benefit_Update_Ind__c=False AND PMP_Partner_Program_nm__c  INCLUDES (';
            
//             for(String option :roleList){
//                 //Checking the indexof substring
//                 if(roleList.indexOf(option) == roleList.size()-1){
                    
//                     query += '\'' + String.escapeSingleQuotes(option) + '\'';
//                 }else{
//                     query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
//                 }
                
//             }
//             query+=')';
//             string additionalFilter = null;
//             //fetch additional filter conditions
//             if(!selectedFilters.isEmpty()){
//                 additionalFilter = getAdditionalFilterCriteria(selectedFilters);
            
//             }
            
//             String strQuery= additionalFilter != null? query +additionalFilter : query;
//             // pagination fix: added by priyanka
//             String sortBy='';
//             if(sortField == PMP_StaticConstants_Partner.sortFieldTier){
//                 sortBy = PMP_StaticConstants_Partner.sortByTierPartner ; 
//                 //sortBy= 'PMP_Partner_Id__r.PMP_Badge_Tier_Sequence_Nbr__c,PMP_Partner_Id__r.Name';
//             }else{
//                 sortBy = PMP_StaticConstants_Partner.sortByMostRecentPartner;
//                 //sortBy= 'PMP_Partner_Id__r.PMP_Company_Status_Update_Dt__c DESC NULLS LAST';
                
//             }
//             String query_Limit = PMP_Utility.getValue('Query_Limit');
//             // System.debug('query_Limit...'+query_Limit);
            
//             strQuery =strQuery+' ORDER BY '+sortBy+' Limit '+query_Limit;
//             // pagination fix: added by priyanka - end 

//             // system.debug('dynamic query : '+ strQuery);
//             partnerList = Database.query(strQuery);
            
//             // system.debug('list size : '+ partnerList.size());
//             for(PMP_Company__c com : partnerList){
//                 result.add(com.Id);
//                 allPartners.put(com.Id,com); 
//             }
//         }
//         return result;
//     }
}