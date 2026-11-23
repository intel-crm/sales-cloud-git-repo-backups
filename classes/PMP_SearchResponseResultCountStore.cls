@isTest
public with sharing class PMP_SearchResponseResultCountStore {
    
    public PMP_SearchResponseResultCountStore(){
        
    }
    
//     public static Map<String, Integer> getResultCount(String searchType, Map<String , List<String>> selectedFilters, List<String> ids, Boolean isDisti, Boolean isServiceProvider,String langCode){
//         Map<String, Integer> resultCount = new Map<String,Integer>();
        
//         if(searchType == 'pmp-category'){
//             resultCount = getTechSpecCount(ids, searchType);
//             resultCount.putAll(getOfferingCategoryFilters(ids, searchType, 'NPP_01_APP'));
//             resultCount.putAll(getOfferingCategoryFilters(ids, searchType, 'NPP_01_Industry'));//NPP_01_TYPE
//             resultCount.putAll(getOfferingCategoryFilters(ids, searchType, 'NPP_01_TYPE'));
//             resultCount.putAll(getPartnerSpecialtyCount(ids, searchType,langCode));
//             resultCount.putAll(getOfferingSegmentCount(ids, searchType));
//             resultCount.putAll(getPartnerRoleCount(ids, searchType));
//             resultCount.putAll(getPartnerTierCount(ids, searchType));
//             resultCount.putAll(getMPEventCount(ids, searchType));
//             resultCount.putAll(getOfferingPartnerFilter(ids, searchType));
//             //system.debug('..partner A-Z...'+getOfferingPartnerFilter(ids, searchType))
            
//         }else{            
//             if(isDisti){
//                 resultCount = getDistiBizOrgTypeCount(ids, searchType);
//                 resultCount.putAll(getDistiSystemSolutionCount(ids, searchType));
//                 resultCount.putAll(getDistiComponentsCount(ids, searchType));
//                 resultCount.putAll(getDistiCountriesCount(ids, searchType));
//                 //resultCount.putAll(getOfferingCategoryFilters(ids, searchType, 'NPP_01_APP'));
//                 //resultCount.putAll(getOfferingCategoryFilters(ids, searchType, 'NPP_01_Industry'));
                
//                 //resultCount.putAll(getOfferingSegmentCount(ids, searchType));
            
//                 //resultCount.putAll(getPartnerRoleCount(ids, searchType));  //27k fix : line is commented by priyanka as it is not required for disti filter

//                 //resultCount.putAll(getPartnerTierCount(ids, searchType));
//                 resultCount.putAll(getMPEventCount(ids, searchType));  	
//                 //resultCount.putAll(getPartnerSegmentCount(ids, searchType));
                
//             }else{
//                 resultCount = getOfferingCategoryFilters(ids, searchType, 'NPP_01_APP');
//                 resultCount.putAll(getOfferingCategoryFilters(ids, searchType, 'NPP_01_Industry'));
                
//                 resultCount.putAll(getPartnerSpecialtyCount(ids, searchType,langCode));
//                 if(isServiceProvider){
//                     resultCount.putAll(getServiceProviderTypeCount(ids, searchType));
//                 }
//                 resultCount.putAll(getPartnerRegionCount(ids));
//                 /*27k fix : below condition is added by priyanka
//                  Partner directory filter is not applicable for any of the partner role page. 
//                  It will required for other partner page (partner by speciaty, partner by segmnet, partner by indutry) */
//                 if(searchType != 'pmp-partner-program'){
//                     resultCount.putAll(getPartnerRoleCount(ids, searchType));// 
//                 }

//                 resultCount.putAll(getPartnerTierCount(ids, searchType));
//                 resultCount.putAll(getMPEventCount(ids, searchType));
//                 resultCount.putAll(getPartnerSegmentCount(ids, searchType));
//                 resultCount.putAll(getOfferingPartnerFilter(ids, searchType));
                
//             }
            
//             //resultCount.putAll(getOfferingPartnerFilter(ids, searchType));
//         }
        
//         return resultCount;
//     }
    
    
    
//     public static Map<String, Integer> getPartnerRegionCount(List<String> ids){
//         Map<String ,Integer> countMap = new Map<String, Integer>();
//         List<AggregateResult> partnerCatList = new  List<AggregateResult>();
//         List<AggregateResult> partnerSpecValList = new  List<AggregateResult>();

//         if(PMP_Company_Region__c.SObjectType.getDescribe().isAccessible()){
//             partnerCatList =[select COUNT(PMP_Company_Id__c)cnt, PMP_Specification_Id__c,PMP_Specification_Value__c
//                              FROM PMP_Company_Region__c WHERE (PMP_Company_Id__c in :ids AND (PMP_Specification_Id__r.PMP_Active_Ind__c = TRUE OR PMP_Specification_Value__r.PMP_Active_Ind__c  = TRUE))
//                              GROUP BY PMP_Specification_Id__c,PMP_Specification_Value__c ];
            
        
//     }
        
//         for(AggregateResult pCat : partnerCatList){
//             String specId = (String)pCat.get('PMP_Specification_Id__c');
//             String specValId = (String)pCat.get('PMP_Specification_Value__c');
//             if(specId!=Null){
//                 countMap.put(specId, (Integer)pCat.get('cnt'));
//             }
//             if(specValId!=null){
//                 countMap.put(specValId, (Integer)pCat.get('cnt'));
//             }
//         }
        
//         return countMap;
//     }    
//     public static Map<String, Integer> getTechSpecCount(List<String> ids, String searchType){
//         Map<String ,Integer> countMap = new Map<String, Integer>();
//         List<AggregateResult> offSpecs= new List<AggregateResult>();
//         if(PMP_Partner_Offering_Specification__c.SObjectType.getDescribe().isAccessible()){
//          offSpecs = [SELECT COUNT(PMP_Offering_Id__c)cnt, PMP_Specification_Id__c,
//                                           PMP_Specification_Id__r.PMP_Parent_Specification_Id__c, PMP_Specification_Value_Id__c                                          
//                                           FROM PMP_Partner_Offering_Specification__c
//                                           WHERE  PMP_Specification_Id__c !=null AND PMP_Specification_Id__r.PMP_Active_Ind__c = TRUE 
//                                           AND PMP_Offering_Id__c IN: ids
//                                           GROUP BY PMP_Specification_Id__c, PMP_Specification_Value_Id__c,
//                                           PMP_Specification_Id__r.PMP_Parent_Specification_Id__c];
//         }
        
//         for(AggregateResult offSpec : offSpecs){
            
//             String specId = (String)offSpec.get('PMP_Specification_Id__c');
//             String specValId = (String)offSpec.get('PMP_Specification_Value_Id__c');
//             Integer count = (Integer)offSpec.get('cnt');
            
//             if(String.isEmpty(specValId)){
//                 countMap.put(specId, count);
//             }else{
//                 countMap.put(specValId, count);
//             }
//         }
        
        
//         return countMap;
//     }
    
//     //getPartnerRoleCount,  partner role related to offerings
//     public static Map<String, Integer> getPartnerRoleCount(List<String> ids, String searchType){
//         //System.debug('.getPartnerRoleCount-->ids'+ids);
//         Map<String, List<String>> partnerRoleMap= new Map<String, List<String>>();
        
//         Map<String, Integer> countMap = new Map<String,Integer>();
//         List<String> partnerRoles = new List<String>();
//         List<String> childRoles = new List<String>();
//         String parentRole = 'Solution, Software, and Service Providers';
//         List<PMP_Partner_Program__c> partnerRoleList= new List<PMP_Partner_Program__c>();
//         if(PMP_Partner_Program__c.SObjectType.getDescribe().isAccessible()){
//          partnerRoleList =[SELECT id,Name, PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c,PMP_Partner_Role_Parent_Id__c from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE];
//          } 
//          Map<String,String> valueIdMap= new Map<String,String> ();
//         for(PMP_Partner_Program__c pgm:partnerRoleList){
//             valueIdMap.put(pgm.Name,pgm.Id);
//             if(pgm.PMP_Partner_Role_Parent_Id__c != null){
//                 childRoles.add(pgm.PMP_Partner_Program_Value_Txt__c);
//             }
//         }
        
//         if(searchType=='pmp-category'){
//             List<PMP_Partner_Offering__c> offList = new List<PMP_Partner_Offering__c>();
//             if(PMP_Partner_Offering__c.SObjectType.getDescribe().isAccessible()){

//             offList = [SELECT id, PMP_Company_Id__r.PMP_Partner_Program_nm__c from PMP_Partner_Offering__c where Id in: ids and PMP_Company_Id__r.PMP_Partner_Program_nm__c!=null];
//             }
//             for(PMP_Partner_Offering__c off: offList){
//                 if(off.PMP_Company_Id__r.PMP_Partner_Program_nm__c!=null){
//                     List<string> roles= new List<String>();
//                     roles=off.PMP_Company_Id__r.PMP_Partner_Program_nm__c.split(';');
//                     partnerRoles.addAll(off.PMP_Company_Id__r.PMP_Partner_Program_nm__c.split(';'));
//                     partnerRoleMap.put(off.Id, roles);
                    
//                 }
                
//             }
            
//         }
//         else{
//             List<PMP_Company__c> partnerList= new  List<PMP_Company__c>();
//             //27k fix: commented by priyanka start
//             /*if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){
//              partnerList = [SELECT Id, PMP_Partner_Program_nm__c FROM PMP_Company__c where Id in: ids and PMP_Partner_Program_nm__c!=null];
//             }*/
//             //27k fix: commented by priyanka end
            
//             //27k fix: below 5 lines of codes is added by priyanka start
//             Map<Id,PMP_Company__c> partnerData= new Map<Id,PMP_Company__c>();
//             partnerData=PMP_SearchUtilityNew.allPartners;
//             for(Id partnerId:ids){
//                 if(partnerData.containsKey(partnerId) && partnerData.get(partnerId).PMP_Partner_Program_nm__c!=null){
//                     //partnerList.add(partnerData.get(partnerId));
//                     List<string> roles= new List<String>();
//                 	roles= partnerData.get(partnerId).PMP_Partner_Program_nm__c.split(';');
// 					partnerRoleMap.put(partnerData.get(partnerId).Id, roles);
//                 }
//             }
//             partnerData=null;// as processing is done , clearing the data in the variable
            
//           /*  for(PMP_Company__c partner: partnerList){
//                 List<string> roles= new List<String>();
//                 roles=partner.PMP_Partner_Program_nm__c.split(';');
//                 partnerRoles.addAll(partner.PMP_Partner_Program_nm__c.split(';'));
//                 partnerRoleMap.put(partner.Id, roles);
//             } commented by AKJ as loop not required*/
//         }
//         /*System.debug('.getPartnerRoleCount-->partnerRoles'+partnerRoles);
// for(String pr : partnerRoles){
// if(!childRoles.contains(pr)){
// if(valueIdMap.containsKey(pr)){
// String roleId=valueIdMap.get(pr);
// if(roleId!=null){
// if(countMap.containsKey(roleId)){
// countMap.put(roleId, countMap.get(roleId)+1);
// }else{
// countMap.put(roleId, 1);
// }  
// }

// }
// }

// }

// for(String pr : partnerRoles){
// if(childRoles.contains(pr)){
// if(valueIdMap.containsKey(pr)){
// String roleId=valueIdMap.get(parentRole);
// if(roleId!=null){
// if(countMap.containsKey(roleId)){
// countMap.put(roleId, countMap.get(roleId)+1);
// }else{
// countMap.put(roleId, 1);
// } 
// }

// }
// }
// }*/
//         for(String partnerid : partnerRoleMap.keySet()){
            
//             Integer count=0;
//             String parentRoleId=null;
//             for(String pr: partnerRoleMap.get(partnerid)){
//                 if(!childRoles.contains(pr)){
                    
//                     if(valueIdMap.containsKey(pr)){
//                         String roleId=valueIdMap.get(pr);
//                         if(roleId!=null){
//                             if(countMap.containsKey(roleId)){
//                                 countMap.put(roleId, countMap.get(roleId)+1);
//                             }else{
//                                 countMap.put(roleId, 1);
//                             }  
//                         }
                        
//                     }
//                 }
                
//                 else{ 
//                     if(childRoles.contains(pr)){
//                         if(valueIdMap.containsKey(pr)){
//                             parentRoleId=valueIdMap.get(parentRole);
//                             if(parentRoleId!=null){
//                                 count=1;
//                             }
                            
//                         }
//                     }	
//                 }
//             }
            
//             if(parentRoleId!=null && count!=0){
//                 if(countMap.containsKey(parentRoleId)){
//                     countMap.put(parentRoleId, countMap.get(parentRoleId)+1);
//                 }else{
//                     countMap.put(parentRoleId, 1);
//                 }  
//             }
            
//         }
//         //System.debug('.getPartnerRoleCount-->countMap'+countMap);
        
//         //countMap.put('a6y8A000000L8VVQA0',1);        
//         return countMap; 
//     }
    
//     public static Map<String, Integer> getServiceProviderTypeCount(List<String> ids, String searchType){
//         Map<String, Integer> countMap = new Map<String,Integer>();
//         Map<String,String> valueIdMap= new Map<String,String> ();
        
//         List<String> partnerRoles = new List<String>();
//         List<PMP_Partner_Program__c> roleList= new List<PMP_Partner_Program__c>();
//         if(PMP_Partner_Program__c.SObjectType.getDescribe().isAccessible()){

//         roleList = [SELECT id,Name from PMP_Partner_Program__c where PMP_Partner_Role_Parent_Id__c!=null];
//         }
//         for(PMP_Partner_Program__c role : roleList){
//             valueIdMap.put(role.Name, role.Id);
//         }
//         //List<PMP_Company__c> partnerList= new List<PMP_Company__c>();
//         //27k fix: below 5 lines of codes is added by priyanka start
//         Map<Id,PMP_Company__c> partnerData= new Map<Id,PMP_Company__c>();
//         partnerData = PMP_SearchUtilityNew.allPartners;
//         for(Id partnerId:ids){
//             if(partnerData.containsKey(partnerId) && partnerData.get(partnerId).PMP_Partner_Program_Nm__c!=null){
//                 //partnerList.add(partnerData.get(partnerId));
//                 PMP_Company__c partner=partnerData.get(partnerId);
//                 partnerRoles.addAll(partner.PMP_Partner_Program_nm__c.split(';'));

//             } 
            
//         }
//         partnerData=null;// as processing is done , clearing the data in the variable
//         //27k fix: below 5 lines of codes is added by priyanka End

//         //27k fix: below query is commented by priyanka - start
//         /*if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){

//          partnerList = [SELECT id, PMP_Partner_Program_Nm__c FROM PMP_Company__c where Id IN: ids];
//         }*/
        
//           //27k fix: below query is commented by priyanka - End

        
//         /*for(PMP_Company__c partner : partnerList){
//             if(partner.PMP_Partner_Program_nm__c!=null){
//                 partnerRoles.addAll(partner.PMP_Partner_Program_nm__c.split(';'));
//             }
//         }*/
        
        
//         for(String pr : partnerRoles){            
//             if(valueIdMap.containsKey(pr)){
//                 String roleId=valueIdMap.get(pr);
//                 if(countMap.containsKey(roleId)){
//                     countMap.put(roleId, countMap.get(roleId)+1);
//                 }else{
//                     countMap.put(roleId, 1);
//                 } 
//             }     
//         }
        
//         return countMap;
//     }
    
//     //getPartnerSpecialtyCount, specialty related to  partner
//     public static Map<String, Integer> getPartnerSpecialtyCount(List<String> ids, string searchType,String langCode){
//         Map<String, Integer> countMap = new Map<String,Integer>();
//         Map<string,string> valueIdMap= new Map<string,string>();
//         List<String> specList = new List<String>();
//         List<PMP_Partner_Specialty__c> specialtyList= new  List<PMP_Partner_Specialty__c>();
//         if(PMP_Partner_Specialty__c.SObjectType.getDescribe().isAccessible()){

//          specialtyList = [SELECT id, Name,PMP_Partner_Specialty_Chinese_Nm__c,PMP_Partner_Specialty_Japanese_Nm__c, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE];
//         }
//         for(PMP_Partner_Specialty__c specData: specialtyList){
//             String specTransName=specData.Name;
//             if(langCode=='ja'){
//                 specTransName=specData.PMP_Partner_Specialty_Japanese_Nm__c;
//             } 
//             else if(langCode=='zh-Hans-CN' || langCode=='zh-CN'){
//                 specTransName=specData.PMP_Partner_Specialty_Chinese_Nm__c;
//             }
//             valueIdMap.put(specTransName, specData.Id);
//          //   valueIdMap.put(specData.Name, specData.Id); 
//         }
        
//         if(searchType=='pmp-category'){
//             List<PMP_Partner_Offering__c> offList = new List<PMP_Partner_Offering__c>();
//             if(PMP_Partner_Offering__c.SObjectType.getDescribe().isAccessible()){

//             offList = [SELECT toLabel(PMP_Company_Id__r.PMP_Account_Specialty__c) FROM PMP_Partner_Offering__c WHERE Id in :ids AND PMP_Company_Id__r.PMP_Account_Specialty__c != null]; 
//             }
//             for(PMP_Partner_Offering__c offering:offList){    
//                 if(offering.PMP_Company_Id__r.PMP_Account_Specialty__c != null){
//                     specList.addAll(offering.PMP_Company_Id__r.PMP_Account_Specialty__c.split(';'));
//                 }
//             }
            
//         }
        
//         else{
//             List<PMP_Company__c> companyList = new List<PMP_Company__c>();
//             /*if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){

//             companyList = [SELECT toLabel(PMP_Account_Specialty__c) from PMP_Company__c WHERE id in :ids AND PMP_Account_Specialty__c != null];
//             }*/
//             //40k fix: added by priyanka : start
//             Map<Id,PMP_Company__c> partnerData= new Map<Id,PMP_Company__c>();
// 			partnerData=PMP_SearchUtilityNew.allPartners;
// 			//systen.debug('partnerData'+partnerData);
//             for(Id partnerId:ids){
//                 if(partnerData.containsKey(partnerId) && partnerData.get(partnerId).PMP_Account_Specialty__c!=null){ 
//                     //companyList.add(partnerData.get(partnerId)); AKJ
// 					specList.addAll(partnerData.get(partnerId).PMP_Account_Specialty__c.split(';'));
//                 }
//             }
//             partnerData=null;// as processing is done , clearing the data in the variable
// 			//40k fix: added by priyanka : End
             
//           /*  for(PMP_Company__c partner:companyList){
//                 if(String.isNotBlank(partner.PMP_Account_Specialty__c)){
//                      specList.addAll(partner.PMP_Account_Specialty__c.split(';'));

//                 }
//             }  commented by AKJ as it is not required */
            
//         }
//         //system.debug('spec2::'+specList);
        
//         for(String spec : specList){
//             if(valueIdMap.containsKey(spec)){
//                 String specId=valueIdMap.get(spec);
//                 if(countMap.containsKey(specId)){
//                     countMap.put(specId, countMap.get(specId)+1);
//                 }else{
//                     countMap.put(specId, 1);
//                 }
//             }
            
//         }
//         //system.debug('::countMap'+countMap);
//         return countMap;
        
//     }
    
    
//     /******************************************************************************************/
//     //Method to get Partner A-Z contextual filter 
//     public static Map<String,Integer> getOfferingPartnerFilter(List<String> ids, string searchType){
//         Map<String,Integer> countMap = new Map<String,Integer>(); //build count
//         //system.debug('..Partner A_Z Ids..'+ids);
//         if(searchType=='pmp-category'){
//             List<PMP_Partner_Offering__c> offList = new List<PMP_Partner_Offering__c>();
//             if(PMP_Partner_Offering__c.SObjectType.getDescribe().isAccessible()){

//             offList = [SELECT Id , PMP_Company_Id__r.Name, PMP_Company_Id__c FROM PMP_Partner_Offering__c WHERE Id in :ids]; 
//             }
//             for (PMP_Partner_Offering__c off: offList){
//                 if(off.PMP_Company_Id__c!=null){
//                     if (countMap.containsKey(off.PMP_Company_Id__c)){
//                         countMap.put(off.PMP_Company_Id__c, countMap.get(off.PMP_Company_Id__c)+1);
//                     }
//                     else
//                     {
//                         countMap.put(off.PMP_Company_Id__c,1);
//                     }
//                 }
                
//             }
//         }
        
//         else{
//             List<PMP_Company__c> partnerList= new List<PMP_Company__c>();
//             //27k fix: commented by priyanka -start
//             /*if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){

//             partnerList = [SELECT Id FROM PMP_Company__c where Id in: ids ORDER BY Name];
//             }

//             for (PMP_Company__c partner: partnerList){
//                 if (countMap.containsKey(partner.Id)){
//                     countMap.put(partner.Id, countMap.get(partner.Id)+1);
//                 }
//                 else
//                 {
//                     countMap.put(partner.Id,1);
//                 }
//             }
//             //27k fix: commented by priyanka -end
// 			*/
			
// 			// 27k fix: added by priyanka , query is not required as we are already have the partner ids - Start
// 			for (Id partner: ids){
//                 countMap.put(partner,1);

//             }
//              // 27k fix: added by priyanka , query is not required as we are already have the partner ids - End

			
			
            
//         } 
		
// 		// Partner filter is only for offerings
        
//         //system.debug('.countMap in Partner A-Z..'+countMap);
//         return countMap;
        
//     }
//     /******************************************************************************************/ 
    
    
    
//     //get Marketplce events count
//     public static Map<String,Integer> getMPEventCount(List<String> ids, string searchType){
//         Map<String,Integer> countMap = new Map<String,Integer>(); //build count
        
//         if(searchType=='pmp-category'){
//             List<AggregateResult> eventOffAggregate= new  List<AggregateResult>();
//            if(PMP_Marketplace_Event_Offering__c.SObjectType.getDescribe().isAccessible()){
//             eventOffAggregate = [SELECT COUNT(PMP_Offering_Id__c)cnt,PMP_Event_Id__c
//                                                        from PMP_Marketplace_Event_Offering__c
//                                                        WHERE  PMP_Offering_Id__c in: ids AND
//                                                        (PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
//                                                        GROUP BY PMP_Event_Id__c];
//            }
            
//             for(AggregateResult eventOff : eventOffAggregate){
//                 String eveId = (String)eventOff.get('PMP_Event_Id__c');
//                 if(countMap.containsKey(eveId)){
//                     countMap.put(eveId,countMap.get(eveId)+(Integer)eventOff.get('cnt') ) ;
//                 }
//                 else{ countMap.put(eveId,(Integer)eventOff.get('cnt') ) ;
//                     }
//             }
            
//         }
        
//         else{
//             List<AggregateResult> eventPartnerAggregate = new  List<AggregateResult>();
//             if(PMP_Marketplace_Event_Partner__c.SObjectType.getDescribe().isAccessible()){

//             eventPartnerAggregate=[Select COUNT(PMP_Company_Id__c)cnt,PMP_Event_Id__c
//                                                          from PMP_Marketplace_Event_Partner__c 
//                                                          where PMP_Company_Id__c in: ids AND
//                                                          (PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
//                                                          GROUP BY PMP_Event_Id__c];
//             }
//             for(AggregateResult eventOfPartner : eventPartnerAggregate){
//                 String eveId = (String)eventOfPartner.get('PMP_Event_Id__c');
//                 if(countMap.containsKey(eveId)){
//                     countMap.put(eveId,countMap.get(eveId)+(Integer)eventOfPartner.get('cnt') );}
//                 else{
//                     countMap.put(eveId,(Integer)eventOfPartner.get('cnt') );}
//             }
//         }
        
//         return countMap;
//     }
    
//     //get partnertier resultcount 
//     public static  Map<String,Integer> getPartnerTierCount(List<String> ids, string searchType){
//         Map<String,Integer> countMap = new Map<String,Integer>();
//         List<String> partnerTiers= new List<String>();
//         if(searchType=='pmp-category'){
//             List<PMP_Partner_Offering__c> offList= new  List<PMP_Partner_Offering__c>();
//             if(PMP_Partner_Offering__c.SObjectType.getDescribe().isAccessible()){

//              offList = [SELECT id,PMP_Company_Id__r.PMP_IPA_Badge_Tier_Txt__c  from PMP_Partner_Offering__c where Id  in: ids and PMP_Company_Id__r.PMP_IPA_Badge_Tier_Txt__c  !=null];
//             }
//             for(PMP_Partner_Offering__c off: offList){
//                 String tier= off.PMP_Company_Id__r.PMP_IPA_Badge_Tier_Txt__c;
//                 if(countMap.containsKey(tier)){
//                     countMap.put(tier, countMap.get(tier)+1);
//                 }else{
//                     countMap.put(tier, 1);
//                 }
//             }
//         }
        
//         else{
//             List<PMP_Company__c> partners= new List<PMP_Company__c>();
//             // 27k fix : added by priyanka , instead of SOQL , changed it to aggregate query
//             if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){
//                 List<AggregateResult> partnerTiersAggr = new  List<AggregateResult>();
                
//                 partnerTiersAggr = [SELECT count(id) cnt,PMP_IPA_Badge_Tier_Txt__c  from PMP_Company__c where Id in:ids and PMP_IPA_Badge_Tier_Txt__c!=null  group by PMP_IPA_Badge_Tier_Txt__c];
//                 for(AggregateResult ptAgregate : partnerTiersAggr){
//                     String partnerTier = (String)ptAgregate.get('PMP_IPA_Badge_Tier_Txt__c');
//                     if(countMap.containsKey(partnerTier)){
//                         countMap.put(partnerTier,countMap.get(partnerTier)+(Integer)ptAgregate.get('cnt') );}
//                     else{
//                         countMap.put(partnerTier,(Integer)ptAgregate.get('cnt') );
//                     }
//                 }
//             }
//             // 27k fix : added by priyanka , instead of SOQL , changed it to aggregate query - end
            
            
//           /* 27k fix: below block of code in commented by priyanka  */
//             /*if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){

//              partners = [SELECT id,PMP_IPA_Badge_Tier_Txt__c,PMP_Account_Program_Membership__c  from PMP_Company__c where Id in:ids and PMP_IPA_Badge_Tier_Txt__c!=null];
//             }
//             System.debug('..Ids---partners..'+ids+''+partners);
//             for(PMP_Company__c partner: partners){
//                 String tier=partner.PMP_IPA_Badge_Tier_Txt__c;
//                 if(countMap.containsKey(tier)){
//                     countMap.put(tier, countMap.get(tier)+1);
//                 }else{
//                     countMap.put(tier, 1);
//                 }
//             }*/
            
//           /* 27k fix: below block of code in commented by priyanka End*/
            
//         }
//         return countMap;
        
//     }
    
    
//     // offering segment count
//     public static  Map<String,Integer> getOfferingSegmentCount(List<String> ids, string searchType){
//         Map<String,Integer> countMap = new Map<String,Integer>();
//         List<String> offSegments = new List<String>();
//         List<PMP_Partner_Offering__c> offList= new List<PMP_Partner_Offering__c>();
//         if(PMP_Partner_Offering__c.SObjectType.getDescribe().isAccessible()){
//          offList = [SELECT id, PMP_Business_Segment_Nm__c from PMP_Partner_Offering__c where Id in: ids and PMP_Business_Segment_Nm__c !=null];
//         }
//          for(PMP_Partner_Offering__c off: offList){
//             offSegments.addAll(off.PMP_Business_Segment_Nm__c.split(';'));
//         }
//         //System.debug('getOfferingSegmentCount-->offSegments'+offSegments);
//         for(String pr : offSegments){
//             //pr=pr.replace(' ', '_');
//             if(countMap.containsKey(pr)){
//                 countMap.put(pr, countMap.get(pr)+1);
//             }else{
//                 countMap.put(pr, 1);
//             }
//         }
        
        
//         //System.debug('getOfferingSegmentCount-->countMap '+countMap);
        
//         return countMap;
//     }
    
    
    
//     // category filters both (Apllication and Industry)
    
//     public static  Map<String,Integer> getOfferingCategoryFilters(List<String> ids, String searchType,String pimId){
//         // need to include the offerngs in the query condition 
//         Map<String,Integer> countMap = new Map<String,Integer>();
//         //List<String> pimIds= new List<String>();
//         //pimIds.add(PMP_StaticConstants_Partner.PIM_INDUSTRY_ID);
//         //pimIds.add(PMP_StaticConstants_Partner.PIM_APPLICATION_ID);
//         if(searchType=='pmp-category'){
//             List<PMP_Category__c> catList = new List<PMP_Category__c>();
//             //System.debug('catList'+catList);
//             String offCatQuery = '';
            
//             List<AggregateResult> offeringCatList = new List<AggregateResult>();
            
//             try{
//                  if(PMP_Category__c.SObjectType.getDescribe().isAccessible()){
//                 catList = [SELECT Id,Name,PMP_Partner_Product_Category_Cd__c,
//                            PMP_Category_Display_Sequence_Nbr__c 			 
//                            FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c  =:pimId AND PMP_Active_Ind__c = true
//                            Order By PMP_Category_Display_Sequence_Nbr__c];
//                 //System.debug('catList'+catList);
//                 }
//                 offCatQuery = 'SELECT COUNT(PMP_Offering_Id__c)cnt, PMP_Category_Id__c '+                
//                     'FROM PMP_Partner_Offering_Category__c WHERE PMP_Offering_Id__c in:ids AND PMP_Category_Id__r.PMP_Active_Ind__c = true AND (';
                
//                 //System.debug('offCatQuery'+offCatQuery);
//                 for(PMP_Category__c cat: catList){
                    
//                     if(catList.indexOf(cat) == 0){
//                         offCatQuery += 'PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c LIKE \'' + String.escapeSingleQuotes(cat.PMP_Partner_Product_Category_Cd__c) + '%\'';
//                     }else{
//                         offCatQuery += ' OR PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c LIKE \'' + String.escapeSingleQuotes(cat.PMP_Partner_Product_Category_Cd__c) + '%\'';
//                     }
//                 }
//                 offCatQuery += ') GROUP BY PMP_Category_Id__c';
                
//                 //system.debug('query :' + offCatQuery);
//                 String queryCat=offCatQuery;
                
//                 offeringCatList = Database.query(queryCat);
//                 //system.debug('..offeringCatList..'+offeringCatList);
                
//                 for(AggregateResult res:offeringCatList){
//                     string catId=(String)res.get('PMP_Category_Id__c');
//                     Integer count=(Integer)res.get('cnt');
//                     if(countMap.containsKey(catId)){
//                         countMap.put(catId,countMap.get(catId)+count);
//                     }
//                     else{
//                         countMap.put(catId,count);
//                     }
                    
//                 }
                
//             }
            
//             catch(Exception e){
//                 //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
//                 //throw new AuraHandledException(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
//             }
            
//         }
        
        
//         else{
//             //need to add the logic for pim id 
//             List<PMP_Category__c> catList = new List<PMP_Category__c>();
//             try{
//                 String query='SELECT Id,PMP_Active_Ind__c FROM PMP_Category__c WHERE PMP_Ancestor_Category_Cd__c LIKE \'' + String.escapeSingleQuotes(pimId) + '%\'';
//                 //query+= ' OR PMP_Partner_Product_Category_Cd__c LIKE \'' + String.escapeSingleQuotes(PMP_StaticConstants_Partner.PIM_APPLICATION_ID) + '%\'';
//                 query+=' AND PMP_Active_Ind__c = true Order By PMP_Category_Display_Sequence_Nbr__c';
//                 //System.debug('..query..'+query);
//                 catList= Database.query(query);
//                 // System.debug('....catList......'+catList);
//                 // System.debug('....ids........'+ids);
//                 List<AggregateResult> result= new  List<AggregateResult>();
//                 if(PMP_Partner_Category__c.SObjectType.getDescribe().isAccessible()){
//                 result=[SELECT Count(id) cnt,PMP_Category_Id__r.Id cid FROM PMP_Partner_Category__c 
//                                               where PMP_Partner_Id__c IN:ids and PMP_Category_Id__r.Id IN:catList  group by PMP_Category_Id__r.Id ];
//                 }
//                 //System.debug('..Checking the Partner filters of appn and industry..'+result);
//                 //Map to store shadow id for SEO
//                 Map<Id, Id> shadowIdMap = new Map<Id, Id> (); 
//                 for(PMP_Category_Partner__c shadowrecord :[select Id, Name, PMP_Category_Id__c from PMP_Category_Partner__c where PMP_Category_Id__c != null ]){
//                     shadowIdMap.put(shadowrecord.PMP_Category_Id__c,shadowrecord.Id);
//                 }
                
//                 for(AggregateResult res:result){
//                     string catId=(String)res.get('cid');
//                     Integer count=(Integer)res.get('cnt');
//                     if(shadowIdMap.containsKey(catId)){
//                         catId=shadowIdMap.get(catId);
//                     }
//                     if(countMap.containsKey(catId)){
//                         countMap.put(catId,countMap.get(catId)+count);
//                     }
//                     else{
//                         countMap.put(catId,count);
//                     }
//                 }
//             }
            
//             catch(Exception e){
//                 //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
//                 throw new AuraHandledException(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
//             }
//         }  
        
//         //System.debug('....countMap....'+countMap);        
//         return countMap;
//     }
    
    
//     public static Map<String, Integer> getDistiBizOrgTypeCount(List<String> ids, String searchType){
//         Map<String, Integer> countMap = new Map<String,Integer>();
//         List<String> partnerTypes=new List<String>();
//         List<PMP_Company__c> distributors= new List<PMP_Company__c>();
//         if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){ 

//          distributors= [SELECT id, PMP_Biz_Org_Type_Txt__c  from PMP_Company__c where id in: ids AND PMP_Biz_Org_Type_Txt__c!=null];
//         }
        
//         for (PMP_Company__c distiPartner:distributors){
//             partnerTypes.addAll(distiPartner.PMP_Biz_Org_Type_Txt__c.split(';'));
//         }
        
//         for(String bizOrgType:partnerTypes){
//             //bizOrgType=bizOrgType.replace(' ', '_');
//             if(countMap.containsKey(bizOrgType)){
//                 countMap.put(bizOrgType,countMap.get(bizOrgType)+1);
                
//             }
//             else{
//                 countMap.put(bizOrgType,1);
                
//             }
            
//         }
//         return countMap;
//     }
    
    
    
    
//     public static Map<String, Integer> getDistiSystemSolutionCount(List<String> ids, String searchType){
//         Map<String, Integer> countMap = new Map<String,Integer>();
//         List<String> sysTypes=new List<String>();
//         List<PMP_Company__c> distributors=new List<PMP_Company__c>();
//         if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){ 

//         distributors= [SELECT Id, Name,PMP_Disti_Sys_Solutions_Nm__c  FROM PMP_Company__c where id in : ids and PMP_Is_Published_Ind__c=true and PMP_Disti_Sys_Solutions_Nm__c!=null];
//         }
        
//         for (PMP_Company__c distiPartner:distributors){
//             sysTypes.addAll(distiPartner.PMP_Disti_Sys_Solutions_Nm__c.split(';'));
//         }
        
//         for(String sysType:sysTypes){
//             sysType= sysType.replace(' ', '_');
//             if(countMap.containsKey(sysType)){
//                 countMap.put(sysType,countMap.get(sysType)+1);
                
//             }
//             else{
//                 countMap.put(sysType,1);
                
//             }
//         }
//         return countMap;
//     }
    
    
//     //getDistiComponentsCount related to  partner
//     public static Map<String, Integer> getDistiComponentsCount(List<String> ids, string searchType){
//         Map<String, Integer> countMap = new Map<String,Integer>();
//         List<String> componentList = new List<String>();
//         List<PMP_Company__c> companyList= new  List<PMP_Company__c> ();
//         if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){ 

//         companyList = [SELECT Id,PMP_Disti_Components_Nm__c from PMP_Company__c WHERE Id in :ids AND PMP_Disti_Components_Nm__c != null];
//         }
//         for(PMP_Company__c partner:companyList){
//             componentList.addAll(partner.PMP_Disti_Components_Nm__c.split(';'));
//         }
        
//         for(String comp : componentList){
//             //comp=comp.replace(' ', '_');
//             if(countMap.containsKey(comp)){
//                 countMap.put(comp, countMap.get(comp)+1);
//             }else{
//                 countMap.put(comp, 1);
//             }                   
//         }
        
//         return countMap;
        
//     }
    
//     //getDistiCountriesCount related to  partner
//     public static Map<String, Integer> getDistiCountriesCount(List<String> ids, string searchType){
//         Map<String, Integer> countMap = new Map<String,Integer>();
//         List<String> countriesList = new List<String>();
//         List<PMP_Company__c> companyList = new List<PMP_Company__c>();
//         if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){ 

//         companyList = [SELECT Id,PMP_Disti_Country_Coverage_Txt__c,PMP_Is_Distributor_Ind__c from PMP_Company__c WHERE Id in :ids  AND  PMP_Is_Published_Ind__c=true AND PMP_Is_Distributor_Ind__c = true];
       
//         }
//         for(PMP_Company__c partner:companyList){
//             if(partner.PMP_Disti_Country_Coverage_Txt__c != null) /*Added this as part of data type change*/
//             countriesList.addAll(partner.PMP_Disti_Country_Coverage_Txt__c.split(';')); 
//         }
        
//         for(String comp : countriesList){
//             if(countMap.containsKey(comp)){
//                 countMap.put(comp, countMap.get(comp)+1);
//             }else{
//                 countMap.put(comp, 1);
//             }                   
//         }
        
//         return countMap;
        
//     }
    
    
    
//     // partner segment count for partners
//     public static  Map<String,Integer> getPartnerSegmentCount(List<String> ids, string searchType){
//         Map<String,Integer> countMap = new Map<String,Integer>();
//         List<String> partnerSegments = new List<String>();
//         //List<PMP_Company__c> partnerList= new List<PMP_Company__c>();
//         //27k fix: commented by priyanka start
//         /*if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){ 
            
//             partnerList = [SELECT id,PMP_Partner_Segment_Nm__c from PMP_Company__c where Id in: ids and PMP_Partner_Segment_Nm__c !=null];
//         }*/
//         //27k fix: commented by priyanka start

//         //27k fix: below 5 lines of codes is added by priyanka start
//         Map<Id,PMP_Company__c> partnerData= new Map<Id,PMP_Company__c>();
//         partnerData=PMP_SearchUtilityNew.allPartners;
//         for(Id partnerId:ids){
//             if(partnerData.containsKey(partnerId) && partnerData.get(partnerId).PMP_Partner_Segment_Nm__c!=null){
//                 //partnerList.add(partnerData.get(partnerId));
//                 PMP_Company__c partner =partnerData.get(partnerId);
//                 partnerSegments.addAll(partner.PMP_Partner_Segment_Nm__c.split(';'));

//             }
//         }
//         partnerData=null;// as processing is done , clearing the data in the variable
        
//         //27k fix: below 5 lines of codes is added by priyanka end
        
        
//         /*for(PMP_Company__c partner: partnerList){
//             partnerSegments.addAll(partner.PMP_Partner_Segment_Nm__c.split(';'));
//         }*/
//         List<PMP_Partner_Segment__c> psList= new List<PMP_Partner_Segment__c>();
//         if(PMP_Partner_Segment__c.SObjectType.getDescribe().isAccessible()){ 
//         psList =[SELECT PMP_Partner_Segment_Value_Txt__c, PMP_Is_Active_Ind__c, Id FROM PMP_Partner_Segment__c where PMP_Partner_Segment_Value_Txt__c != null];
//         }
//         Map<String,String> valueIdMap= new  Map<String,String>();
//         for(PMP_Partner_Segment__c ps:psList){
//             valueIdMap.put(ps.PMP_Partner_Segment_Value_Txt__c,ps.Id);
//         }
//         for(String pr : partnerSegments){
//             String key='';
//             if(valueIdMap.containsKey(pr)){
//                 key=valueIdMap.get(pr);
                
//                 if(countMap.containsKey(key)){
//                     countMap.put(key, countMap.get(key)+1);
//                 }
//                 else{
//                     countMap.put(key, 1);
//                 }
//             }
//         }
//         // system.debug('..getPartnerSegmentCount ids recieved..'+ids);
//         // system.debug('..getPartnerSegmentCount ids recieved..'+countMap);
        
//         return countMap;
        
//     }
    
}