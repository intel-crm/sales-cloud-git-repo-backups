global with sharing class Core_MDF_IUPGM_Monitor_Batch implements Database.Batchable<sObject>,Database.Stateful {
    Public String csvHeader = 'Account Id, Account Name, Program Name, Role, Region, Budget Type';
    Public List<String> csvDataList = new List<String>{csvHeader};
        Public List<ContentVersion> contentVersionListToBeInserted = new List<ContentVersion>();
    Public Integer count = 0;
    Public Id recordTrackingId;
    Public String Program = '';
    Public Boolean isNewContent = false;
    Public final Integer MAX_RECORDS = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IUPGMDataMonitorMaxFileSize'));
    Public String IUPGMMonitor =  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IUPGMDataMonitor');
    Public Set<String> progList = new Set<String>();
    Public Map<String, List<String>> programToRoleMap = new Map<String, List<String>>();
    Map<String,String> benefitToBudgetTypeMap = new Map<String,String>();
    Map<String,Set<String>> progToRegionMap = new Map<String,Set<String>>();
    Set<String> benefitSet = new Set<String>();
    Set<String> roleSet = new Set<String>();
    Map<String,String> roleApiToLabelMap = new Map<String,String>();
    Map<String,Boolean> roleToBgtTypeApplicableMap = new Map<String,Boolean>();
    String IPA_Program = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name');
    Boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
    Boolean optAccountBenefitAssociation = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_OptAccountBenefitAssoc');
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        
        for(Core_MDF_ProgramGeoRoleGroupMap__c csRec : [SELECT Id,
                                                        Core_MDF_Region_txt__c,
                                                        Core_MDF_Program_txt__c, 
                                                        Core_MDF_Role_txt__c,
                                                        Core_MDF_Is_Budget_Type_Applicable_Ind__c
                                                        FROM Core_MDF_ProgramGeoRoleGroupMap__c
                                                        WHERE Core_MDF_Is_Active__c = true 
                                                        AND Core_MDF_Is_For_IUPGM_Monitor_Ind__c = true]){
                                                            List<String> budgetTypesList = new List<String>();
                                                            if(csRec.Core_MDF_Role_txt__c != null){
                                                                roleSet.add(csRec.Core_MDF_Role_txt__c);
                                                            }
                                                            
                                                            if(programToRoleMap.containsKey(csRec.Core_MDF_Program_txt__c) && programToRoleMap.get(csRec.Core_MDF_Program_txt__c) != null){
                                                                programToRoleMap.get(csRec.Core_MDF_Program_txt__c).add(csRec.Core_MDF_Role_txt__c);
                                                            }
                                                            else{
                                                                programToRoleMap.put(csRec.Core_MDF_Program_txt__c,new List<String>{csRec.Core_MDF_Role_txt__c});
                                                            }
                                                            if(csRec.Core_MDF_Is_Budget_Type_Applicable_Ind__c == True && csRec.Core_MDF_Role_txt__c != null){
                                                                roleToBgtTypeApplicableMap.put(csRec.Core_MDF_Role_txt__c, csRec.Core_MDF_Is_Budget_Type_Applicable_Ind__c);  
                                                            }
                                                            
                                                            List<String> regionList = new List<String>();
                                                            
                                                            if(csRec.Core_MDF_Region_txt__c != null){
                                                                
                                                                regionList = csRec.Core_MDF_Region_txt__c.split(',');
                                                                
                                                                
                                                                for(String geo : regionList){
                                                                    
                                                                    if(progToRegionMap.containsKey(csRec.Core_MDF_Program_txt__c)){ 
                                                                        
                                                                        progToRegionMap.get(csRec.Core_MDF_Program_txt__c).add(geo);
                                                                        
                                                                    }
                                                                    
                                                                    else{
                                                                        
                                                                        progToRegionMap.put(csRec.Core_MDF_Program_txt__c,new Set<String>{geo});
                                                                        
                                                                    }
                                                                }
                                                                
                                                            }
                                                        }
        
        for(PermissionSet psRole : [select id,Name,Label from PermissionSet where name In: roleSet]){
            roleApiToLabelMap.put(psRole.Name, psRole.Label);
        }
        
        Set<String> programSet = programToRoleMap.keySet();
        
        
        // Here we update the custometa data into custom label--RS
        /* for(Core_MDF_BudgetType_Benefit_Mapping__mdt   budgetTypeBenefit : [SELECT Id, Core_MDF_Budget_Type__c, Core_MDF_Partner_Benefit__c from Core_MDF_BudgetType_Benefit_Mapping__mdt   
WHERE Core_MDF_Program_Nm__c IN: programSet
AND Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = TRUE])*/
        for(Core_MDF_BudgetType_Benefit_Mappings__c   budgetTypeBenefit : [SELECT Id, Core_MDF_Budget_Type__c, Core_MDF_Partner_Benefit__c from Core_MDF_BudgetType_Benefit_Mappings__c   
                                                                           WHERE Core_MDF_Program_Nm__c IN: programSet
                                                                           AND Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = TRUE]){
                                                                               
                                                                               
                                                                               if(budgetTypeBenefit.Core_MDF_Budget_Type__c != null && budgetTypeBenefit.Core_MDF_Partner_Benefit__c != null){
                                                                                   benefitToBudgetTypeMap.put(budgetTypeBenefit.Core_MDF_Partner_Benefit__c, budgetTypeBenefit.Core_MDF_Budget_Type__c);
                                                                                   
                                                                               }
                                                                               
                                                                               
                                                                               
                                                                           }
        
        
        //Akanksha - Prime EOL changes
        String unifiedIdEnabledField = '';
        if(isUnifiedIdEnabled){
            unifiedIdEnabledField = ', Core_MDF_Account__r.Core_Unified_Global_Customer_BP_Id__c, Core_MDF_Account__r.Core_IPA_One_Partner_Id__c ';
        }
        String query = 'SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.Name,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c ' + unifiedIdEnabledField + 'FROM Core_MDF_Partner_Group_Mapping__c ' +
            'WHERE Core_MDF_Type_of_Access__c = \'External\' ' +
            'AND Core_MDF_Account__c != NULL ' +
            'AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c IN: programSet ' +
            'AND Core_MDF_Account__r.Core_MDF_CoMarketingActive__c = TRUE ' +
            'AND Core_MDF_Inactive_Ind__c = FALSE ' +
            'ORDER BY Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c';
        
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Core_MDF_Partner_Group_Mapping__c> pgmObjList){
        try {
        Set<String> accIdSet = new Set<String>();
        Set<String> programSet = new Set<String>();
        Set<String> roleSet = new Set<String>();
        Map<id,String> ultimateAccountToGeoMap = new Map<id,String>();
        Map<id,Set<String>> ultimateAccountToBudgetTypeMap = new Map<id,Set<String>>();
        Set<String> pgmKeySet = new Set<String>();
        Set<String> iupgmKeySet = new Set<String>();
        Set<String> pgmAllAccKeySet = new Set<String>();
        Set<String> accountIdSet = new Set<String>();
        List<pgmWrapper> pgmWrapperList = new List<pgmWrapper>();
        Set<String> primeIdSet = new Set<String>();
        
        
        
        
        for(Core_MDF_Partner_Group_Mapping__c pgmRec : pgmObjList){
           
            accountIdSet.add(pgmRec.Core_MDF_Account__c); // add all the ultimate account Ids
            //Akanksha - Prime EOL Changes
            if(isUnifiedIdEnabled){
                if(pgmRec.Core_MDF_Account__r.Core_Unified_Global_Customer_BP_Id__c != null){
                    primeIdSet.add(pgmRec.Core_MDF_Account__r.Core_Unified_Global_Customer_BP_Id__c);
                }
                
            }
        }
        
        if(accountIdSet != null && !accountIdSet.isEmpty()){
            for(Account acc : [SELECT Id,Core_Geo__c,Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__r.Name, Core_MDF_Parent_Fund_Account__c,Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c    
                               FROM account 
                               WHERE Core_MDF_Parent_Fund_Account__c IN: accountIdSet
                               AND Core_MDF_Channel_Program__r.Name =: IPA_Program
                              ]){
                                  if(accountIdSet.contains(acc.Core_MDF_Parent_Fund_Account__c) && acc.Core_Geo__c != null){
                                      ultimateAccountToGeoMap.put(acc.Core_MDF_CoMarketing_Ultimate_Account__c,acc.Core_Geo__c);
                                  }
                                  
                              }
            
            
            //Akanksha - Prime EOL Chnages
            if(ultimateAccountToGeoMap != null && !ultimateAccountToGeoMap.isEmpty() && benefitToBudgetTypeMap != null && !benefitToBudgetTypeMap.isEmpty()){
                if(isUnifiedIdEnabled){
                    if(optAccountBenefitAssociation){ 
                        ultimateAccountToBudgetTypeMap = GetBenefitsMappedtoAccountByOPId(primeIdSet,benefitToBudgetTypeMap);//returning map of account Ids to set of Benefits
                        
                    }
                    else{
                        ultimateAccountToBudgetTypeMap = GetSpecialtyMappedtoAccountByUcdId(primeIdSet,benefitToBudgetTypeMap);
                        
                    }
                }   
            }
            
            
            
            /* if(!allIntelAccIdSet.isEmpty()){
String mdfExcludedPartner = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExcludedPartner');
for(PRM_IPA_Affiliation__c accIpaAff : [SELECT Id, PRM_Account__c,PRM_Account__r.Core_Prime_Id__c 
FROM PRM_IPA_Affiliation__c 
WHERE PRM_Builder_Strategy__r.Name =: mdfExcludedPartner
AND (PRM_Account__c IN: allIntelAccIdSet OR PRM_Account__c IN:setOfOnePartnerIds)AND PRM_Active__c = TRUE]){
accInIpaAffiliation.add(accIpaAff.PRM_Account__c);
}
}       

if(ultimateAccountToGeoMap != null && !ultimateAccountToGeoMap.isEmpty() && benefitToBudgetTypeMap != null && !benefitToBudgetTypeMap.isEmpty()){
//we are fetching account in ultimateAccountToGeoMap so that we only get those accounts who has virtual corp account which has host region.
if(optAccountBenefitAssociation){
for(PRM_AccountBenefitAssociation__c aba : [SELECT ID,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c 
from PRM_AccountBenefitAssociation__c
where PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c IN:benefitToBudgetTypeMap.keySet()
AND PRM_Account_Id__r.RecordType.DeveloperName ='Core_Partner_Account_Group'
AND PRM_Account_Id__c in: setOfOnePartnerIds
AND PRM_Status_Nm__c = 'Active'
AND PRM_Partner_Benefit_Id__c != null 
AND PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c != null]){



// mapOfIntelAccountandPrimeId->key = Account Id; value= UCD Id
// mapOfUCDIdSetofOPId-> key = UCD Id ; value= Set of OPID accounts
if(!mapOfIntelAccountandPrimeId.isEmpty() && mapOfIntelAccountandPrimeId.size () >0){                                                               
for (Id accId : mapOfIntelAccountandPrimeId.keyset()){
if(mapOfIntelAccountandPrimeId.containsKey(accId)){ 
for (String ucdId: mapOfIntelAccountandPrimeId.get(accId)){
if(!mapOfUCDIdSetofOPId.isEmpty() && mapOfUCDIdSetofOPId.size () >0 && mapOfUCDIdSetofOPId.containsKey(ucdId)){
for(Id opId: mapOfUCDIdSetofOPId.get(ucdId)){

if(opId ==aba.PRM_Account_Id__c){
if(ultimateAccountToBudgetTypeMap.containsKey(accId)){ 
ultimateAccountToBudgetTypeMap.get(accId).add(benefitToBudgetTypeMap.get(aba.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c));
}
else{
ultimateAccountToBudgetTypeMap.put(accId,new Set<String>{benefitToBudgetTypeMap.get(aba.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c)});
}
}
}
}
}
}
}
}
}


}
else{
for(PRM_Account_Specialty_Association__c asa : [SELECT PRM_Account_Id__c,PRM_Specialty_Id__r.Name 
FROM PRM_Account_Specialty_Association__c 
//WHERE PRM_Specialty_Id__r.Name in: budgetTypeValues
WHERE PRM_Specialty_Id__r.Name in: benefitToBudgetTypeMap.keySet()
AND PRM_Account_Id__c in: allIntelAccIdSet 
AND PRM_Specialty_Id__c != null 
AND PRM_Specialty_Id__r.Name != null]){


//multiple budget type may be associated to a single account so storing them in map->ultimateAccountToBudgetTypeMap
if(ultimateAccountToBudgetTypeMap.containsKey(asa.PRM_Account_Id__c)){ 
// ultimateAccountToBudgetTypeMap.get(asa.PRM_Account_Id__c).add(asa.PRM_Specialty_Id__r.Name);
ultimateAccountToBudgetTypeMap.get(asa.PRM_Account_Id__c).add(benefitToBudgetTypeMap.get(asa.PRM_Specialty_Id__r.Name));

}
else{
ultimateAccountToBudgetTypeMap.put(asa.PRM_Account_Id__c,new Set<String>{benefitToBudgetTypeMap.get(asa.PRM_Specialty_Id__r.Name)});

}
}
}
//we are fetching account in ultimateAccountToGeoMap because some roles may not have budget types.
}*/
            
        }
        
        
        for(Core_MDF_Partner_Group_Mapping__c pgm : pgmObjList){
            String specificAccSpecificGeoKey = '';
            String allAccSpecificGeoKey = '';
            String WW_specificAccSpecificGeoKey = '';
            String WW_allAccSpecificGeoKey = '';
            string program = pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
            if(programToRoleMap.containsKey(program) && programToRoleMap.get(program) != null){
                
                for(String role : programToRoleMap.get(program)){
                    specificAccSpecificGeoKey = program + ';' + role + ';' + pgm.Core_MDF_Account__c + ';' + pgm.Core_MDF_Account__r.Name;
                    allAccSpecificGeoKey = program + ';' + role;
                    WW_specificAccSpecificGeoKey = program + ';' + role + ';' + pgm.Core_MDF_Account__c + ';' + pgm.Core_MDF_Account__r.Name + ';' + 'WW';
                    WW_allAccSpecificGeoKey = program + ';' + role + ';' + 'WW';
                    if(program == IPA_Program){
                        
                        specificAccSpecificGeoKey += ';' + ultimateAccountToGeoMap.get(pgm.Core_MDF_Account__c);
                        allAccSpecificGeoKey += ';' + ultimateAccountToGeoMap.get(pgm.Core_MDF_Account__c);
                        
                        
                        
                        if(ultimateAccountToBudgetTypeMap.containskey(pgm.Core_MDF_Account__c) && ultimateAccountToBudgetTypeMap.get(pgm.Core_MDF_Account__c) != null){
                            
                            for(String budgetType: ultimateAccountToBudgetTypeMap.get(pgm.Core_MDF_Account__c)){
                                if(roleToBgtTypeApplicableMap.containsKey(role) && roleToBgtTypeApplicableMap.get(role) == TRUE){
                                    String specificAccSpecificBTKey = specificAccSpecificGeoKey + ';' + budgetType;
                                    String allAccSpecificBTKey = allAccSpecificGeoKey + ';' + budgetType;
                                    
                                    
                                    String WW_specificAccSpecificBTKey = WW_specificAccSpecificGeoKey + ';' + budgetType;String WW_allAccSpecificBTKey = WW_allAccSpecificGeoKey + ';' + budgetType;
                                    pgmWrapper pgmWrap = new pgmWrapper();pgmWrap.specificAccSpecificBT = specificAccSpecificBTKey;pgmWrap.allAccSpecificBT = allAccSpecificBTKey;pgmWrap.specificAccSpecificGeo = specificAccSpecificGeoKey;pgmWrap.allAccSpecificGeo = allAccSpecificGeoKey;pgmWrap.WW_specificAccSpecificBT = WW_specificAccSpecificBTKey;pgmWrap.WW_allAccSpecificBT = WW_allAccSpecificBTKey;pgmWrap.WW_specificAccSpecificGeo = WW_specificAccSpecificGeoKey;pgmWrap.WW_allAccSpecificGeo = WW_allAccSpecificGeoKey;pgmWrap.accId = pgm.Core_MDF_Account__c;pgmWrap.accName = pgm.Core_MDF_Account__r.Name;pgmWrap.role = role;pgmWrap.prog = program;pgmWrap.region = ultimateAccountToGeoMap.get(pgm.Core_MDF_Account__c);pgmWrap.budgetType = budgetType;pgmWrapperList.add(pgmWrap);
                                }
                                else{pgmWrapper pgmWrap = new pgmWrapper();pgmWrap.WW_specificAccSpecificGeo = WW_specificAccSpecificGeoKey;
                                    pgmWrap.WW_allAccSpecificGeo = WW_allAccSpecificGeoKey;pgmWrap.specificAccSpecificGeo = specificAccSpecificGeoKey;pgmWrap.allAccSpecificGeo = allAccSpecificGeoKey;pgmWrap.accId = pgm.Core_MDF_Account__c;pgmWrap.accName = pgm.Core_MDF_Account__r.Name;pgmWrap.role = role;pgmWrap.prog = program;pgmWrap.region = ultimateAccountToGeoMap.get(pgm.Core_MDF_Account__c);pgmWrapperList.add(pgmWrap); 
                                }
                            }
                        }
                    }
                    else{
                        // we will form keys for other programs
                        
                        if(ProgToRegionMap.containskey(program) && ProgToRegionMap.get(program) != null){
                            for(String geo : ProgToRegionMap.get(program)){
                                String pgmgeoKey = specificAccSpecificGeoKey + ';' + geo;
                                
                                pgmKeySet.add(pgmgeoKey);
                            }
                        }
                        else{
                            pgmKeySet.add(specificAccSpecificGeoKey);
                        }
                    }
                    
                    accIdSet.add(pgm.Core_MDF_Account__c);
                    programSet.add(program);
                    roleSet.add(role);
                }
            }
            
        }
        
        
        
        if(!accIdSet.isEmpty() && !programSet.isEmpty() && !roleSet.isEmpty()){
           
            list<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = [SELECT Id, Core_MDF_Account_id__c,
                                                                         Core_MDF_Account_id__r.Name, 
                                                                         Core_MDF_Program_nm__c, 
                                                                         Core_MDF_Role_nm__c, 
                                                                         Core_MDF_Region_Sub_Region_nm__c, 
                                                                         Core_MDF_All_Accounts_cd__c,
                                                                         Core_MDF_Budget_Type_nm__c,
                                                                         Core_MDF_All_Budget_Type_Access_Ind__c,
                                                                         Core_MDF_GeoSubGeo_Budget_Type_nm__c
                                                                         FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                         WHERE (Core_MDF_Account_id__c IN: accIdSet or Core_MDF_All_Accounts_cd__c = 'Yes') 
                                                                         AND Core_MDF_Program_nm__c IN: programSet 
                                                                         AND Core_MDF_Role_nm__c IN: roleSet
                                                                         AND Core_MDF_Active_Ind__c = true];
            
            
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id, Core_MDF_Account_id__c,
                                                                   Core_MDF_Account_id__r.Name, 
                                                                   Core_MDF_Program_nm__c, 
                                                                   Core_MDF_Role_nm__c, 
                                                                   Core_MDF_Region_Sub_Region_nm__c, 
                                                                   Core_MDF_All_Accounts_cd__c,
                                                                   Core_MDF_Budget_Type_nm__c,
                                                                   Core_MDF_All_Budget_Type_Access_Ind__c,
                                                                   Core_MDF_GeoSubGeo_Budget_Type_nm__c
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                   WHERE (Core_MDF_Account_id__c IN: accIdSet or Core_MDF_All_Accounts_cd__c = 'Yes') 
                                                                   AND Core_MDF_Program_nm__c IN: programSet 
                                                                   AND Core_MDF_Role_nm__c IN: roleSet
                                                                   AND Core_MDF_Active_Ind__c = true]){
                                                                       
                                                                       String IUPGMkey ='';
                                                                       
                                                                       List<String> iupgmRegionList =  new List<String>();//Region
                                                                       
                                                                       if(iupgm.Core_MDF_Region_Sub_Region_nm__c != null){
                                                                           
                                                                           iupgmRegionList = iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';');
                                                                           
                                                                       }
                                                                       
                                                                       if(iupgm.Core_MDF_Program_nm__c == IPA_Program){
                                                                           String hostRegion = ultimateAccountToGeoMap.get(iupgm.Core_MDF_Account_id__c);
                                                                           
                                                                           if(iupgm.Core_MDF_All_Accounts_cd__c == 'Yes'){
                                                                               if(iupgm.Core_MDF_Budget_Type_nm__c != null){
                                                                                   if(iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null){
                                                                                       for(String geoBudgetTypeStr : iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';')){
                                                                                           String geo = geoBudgetTypeStr.split('->')[0] ;                             
                                                                                           String budtype = geoBudgetTypeStr.split('->')[1] ;
                                                                                           IUPGMkey = iupgm.Core_MDF_Program_nm__c + ';' +iupgm.Core_MDF_Role_nm__c + ';' + geo + ';' + budtype;
                                                                                           
                                                                                           iupgmKeySet.add(IUPGMkey);
                                                                                           
                                                                                       }
                                                                                   }
                                                                               }
                                                                               else{
                                                                                   for(String region : iupgmRegionList){
                                                                                       IUPGMkey = iupgm.Core_MDF_Program_nm__c + ';' +iupgm.Core_MDF_Role_nm__c + ';' + region;
                                                                                       
                                                                                       iupgmKeySet.add(IUPGMkey);
                                                                                   }
                                                                               }
                                                                           }
                                                                           else{ // for All Account = 'No'
                                                                               if(iupgm.Core_MDF_Budget_Type_nm__c != null){
                                                                                   if(iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null){
                                                                                       for(String geoBudgetTypeStr : iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';')){
                                                                                           String geo = geoBudgetTypeStr.split('->')[0] ;                             
                                                                                           String budtype = geoBudgetTypeStr.split('->')[1] ;
                                                                                           IUPGMkey = iupgm.Core_MDF_Program_nm__c + ';' +iupgm.Core_MDF_Role_nm__c + ';' + iupgm.Core_MDF_Account_id__c + ';' + iupgm.Core_MDF_Account_id__r.Name + ';' + geo + ';' + budtype;
                                                                                           
                                                                                           iupgmKeySet.add(IUPGMkey);
                                                                                           
                                                                                       }
                                                                                   }  
                                                                               }
                                                                               else{
                                                                                   for(String region : iupgmRegionList){
                                                                                       IUPGMkey = iupgm.Core_MDF_Program_nm__c + ';' +iupgm.Core_MDF_Role_nm__c + ';' + iupgm.Core_MDF_Account_id__c + ';' + iupgm.Core_MDF_Account_id__r.Name + ';' + region;
                                                                                       
                                                                                       iupgmKeySet.add(IUPGMkey);
                                                                                   }
                                                                               }
                                                                           }
                                                                           
                                                                       }
                                                                       else{
                                                                           
                                                                           // we will form keys for other programs
                                                                           if(iupgm.Core_MDF_All_Accounts_cd__c == 'Yes'){
                                                                               IUPGMkey = iupgm.Core_MDF_Program_nm__c + ',' +iupgm.Core_MDF_Role_nm__c;
                                                                               iupgmKeySet.add(IUPGMkey);
                                                                           }
                                                                           else{
                                                                               IUPGMkey = iupgm.Core_MDF_Program_nm__c + ',' +iupgm.Core_MDF_Role_nm__c + ',' + iupgm.Core_MDF_Account_id__c + ',' + iupgm.Core_MDF_Account_id__r.Name;
                                                                               iupgmKeySet.add(IUPGMkey);
                                                                           }
                                                                           
                                                                           if(!iupgmRegionList.isEmpty()){
                                                                               for(String geo : iupgmRegionList){
                                                                                   if(iupgm.Core_MDF_All_Accounts_cd__c == 'Yes'){
                                                                                       IUPGMkey = iupgm.Core_MDF_Program_nm__c + ',' +iupgm.Core_MDF_Role_nm__c + ',' + iupgm.Core_MDF_Account_id__c + ',' + iupgm.Core_MDF_Account_id__r.Name + ',' + geo;
                                                                                       iupgmKeySet.add(IUPGMkey);
                                                                                   }
                                                                                   else{
                                                                                       IUPGMkey = iupgm.Core_MDF_Program_nm__c + ',' +iupgm.Core_MDF_Role_nm__c + ',' + geo;
                                                                                       iupgmKeySet.add(IUPGMkey);
                                                                                   }
                                                                               }
                                                                           }
                                                                           
                                                                       }
                                                                       
                                                                   }
            
        }
        
        
        
        for(pgmWrapper pgmKey : pgmWrapperList){
            
            
            
            if(!(iupgmKeySet.contains(pgmKey.specificAccSpecificBT) || iupgmKeySet.contains(pgmKey.specificAccSpecificGeo)
                 || iupgmKeySet.contains(pgmKey.allAccSpecificBT) || iupgmKeySet.contains(pgmKey.allAccSpecificGeo)
                 || iupgmKeySet.contains(pgmKey.WW_allAccSpecificGeo) || iupgmKeySet.contains(pgmKey.WW_allAccSpecificBT)
                 || iupgmKeySet.contains(pgmKey.WW_specificAccSpecificBT) || iupgmKeySet.contains(pgmKey.WW_specificAccSpecificGeo))){
                     
                    
                     if(pgmKey.accName != null){
                         pgmKey.accName = '"' + pgmKey.accName.replace('"', '') + '"';
                     }
                     
                     
                     //   String csvRow = wrapper.prog + ',' + wrapper.role + ',' + wrapper.accId + ',' + wrapper.region + ',' + wrapper.budgetType;
                     String csvRow = pgmKey.accId + ',' + pgmKey.accName + ',' + pgmKey.prog + ',' + roleApiToLabelMap.get(pgmKey.role) + ',' + pgmKey.region; 
                     
                     csvRow += string.isNotBlank(pgmKey.budgetType) ? ',' + pgmKey.budgetType : '';
                     
                     
                     
                     
                     if(!csvDataList.contains(csvRow)){
                         
                         csvDataList.add(csvRow);
                         ++count;
                         Program = pgmKey.prog;
                     }
                     
                     
                     if(!progList.contains(pgmKey.prog)){
                         progList.add(pgmKey.prog);
                         if(progList.size() == 1){
                             isNewContent = TRUE;
                         }
                     } 
                 }   
            
        }
        
        if(isNewContent || progList.size() > 1 || count == MAX_RECORDS){
           
            contentVersionListToBeInserted.add(createContentVersion(csvDataList));
            isNewContent = FALSE;
        }
        } catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    /*-----------------------------------------------------------------------------------
Method Name         : createContentVersion
@Input Parameters   : List of csv records.
Description         : This method creates file based on progam. 
------------------------------------------------------------------------------------*/
    
    
    public ContentVersion createContentVersion(List<String> csvDataList){
        ContentVersion cv = new ContentVersion();
        cv.Title = IUPGMMonitor+'-'+Program+'.csv';
        String base64 = EncodingUtil.base64Encode(Blob.valueOf(String.join(csvDataList,'\n')));
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.PathOnClient = IUPGMMonitor+'-'+Program+'.csv';
        
        
        
        
        
        count = 0;
        csvDataList.clear();
        csvDataList.add(csvHeader);
        if(progList.size() > 1 && count < MAX_RECORDS){
            progList.remove(Program);
        }
        
        return cv;
    }
    
    // this method will be called in finish
    public void saveAttachment(List<ContentVersion> contentVersionListToBeInserted){
        
        
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
        
        if(recordTrackingId != null){
            for(ContentDocument contentDoc : [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVersionListToBeInserted]){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDoc.Id; 
                cdl.LinkedEntityId = recordTrackingId;
                cdl.ShareType = 'V'; // V stands for "Viewer Access". You can also use E for "Edit Access"
                cdl.Visibility = 'InternalUsers';// set the visibility of the file. Other options are InternalUsers or SharedUsers
                contentDocLinkList.add(cdl);
            }
            insert contentDocLinkList;
        }
        
    }
    
    //Akanksha - EOL
    public Map<Id, Set<String>> GetSpecialtyMappedtoAccountByUcdId(Set<String> primeIdSet,Map<String, String> benefitToBudgetTypeMap){
        Map<Id, Set<String>> ultiAccToBudgetTypeMap = new Map<Id, Set<String>>();
        Set<Id> allIntelAccIdSet = new Set<Id>();
        
        for(Account account : [Select Id,Core_Unified_Global_Customer_BP_Id__c,Core_MDF_CoMarketingActive__c,Core_IPA_One_Partner_Id__c  
                               from Account 
                               where Core_Unified_Global_Customer_BP_Id__c IN: (primeIdSet) 
                               and (RecordType.DeveloperName = 'Core_Partner_Account_Group' 
                                    OR (RecordType.DeveloperName =: Label.Core_MDF_MasterAccount AND Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE))]){                
                                        
                                        allIntelAccIdSet.add(account.Id);
                                        
                                    }
        
        for(PRM_Account_Specialty_Association__c asa : [SELECT PRM_Account_Id__c,PRM_Specialty_Id__r.Name 
                                                        FROM PRM_Account_Specialty_Association__c 
                                                        WHERE PRM_Specialty_Id__r.Name in: benefitToBudgetTypeMap.keySet()
                                                        AND PRM_Account_Id__c in: allIntelAccIdSet 
                                                        AND PRM_Specialty_Id__c != null 
                                                        AND PRM_Specialty_Id__r.Name != null]){
                                                            
                                                            
                                                            //multiple budget type may be associated to a single account so storing them in map->ultiAccToBudgetTypeMap
                                                            if(ultiAccToBudgetTypeMap.containsKey(asa.PRM_Account_Id__c)){ 
                                                                
                                                                ultiAccToBudgetTypeMap.get(asa.PRM_Account_Id__c).add(benefitToBudgetTypeMap.get(asa.PRM_Specialty_Id__r.Name));
                                                                
                                                            }
                                                            else{
                                                                ultiAccToBudgetTypeMap.put(asa.PRM_Account_Id__c,new Set<String>{benefitToBudgetTypeMap.get(asa.PRM_Specialty_Id__r.Name)});
                                                                
                                                            }
                                                        }
        
        return ultiAccToBudgetTypeMap;
    }
    
    //[WW32] Ramapriya ->for handling Account Benefit Association
    public Map<Id, Set<String>> GetBenefitsMappedtoAccountByOPId(Set<String> primeIdSet,Map<String, String> benefitToBudgetTypeMap){
        Map<String, Set<Id>> mapOfUCDIdSetofOPId = new Map<String, Set<Id>>();
        Map<Id, Set<String>> ultiAccToBudgetTypeMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> mapOfIntelAccountandPrimeId= new Map<Id, Set<String>>();
        Set<Id> setOfOnePartnerIds = new Set<Id>();
        
        for(Account acc : [Select Id,Core_Unified_Global_Customer_BP_Id__c,Core_MDF_CoMarketingActive__c,Core_IPA_One_Partner_Id__c  
                           from Account 
                           where Core_Unified_Global_Customer_BP_Id__c IN: (primeIdSet) 
                           and (RecordType.DeveloperName = 'Core_Partner_Account_Group' 
                                OR (RecordType.DeveloperName =: Label.Core_MDF_MasterAccount AND Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE))]){
                                    
                                    // map to store UCD Id corresponding to each incoming Account 
                                    if (mapOfIntelAccountandPrimeId.containsKey(acc.Id)){
                                        mapOfIntelAccountandPrimeId.get(acc.Id).add(acc.Core_Unified_Global_Customer_BP_Id__c);               
                                    }
                                    else{
                                        mapOfIntelAccountandPrimeId.put(acc.Id,new Set<String>{acc.Core_Unified_Global_Customer_BP_Id__c});
                                    }
                                    
                                    //creating map of UCD Id to set of OPID Accounts
                                    if(mapOfUCDIdSetofOPId.containsKey(acc.Core_Unified_Global_Customer_BP_Id__c)){
                                        mapOfUCDIdSetofOPId.get(acc.Core_Unified_Global_Customer_BP_Id__c).add(acc.Core_IPA_One_Partner_Id__c);
                                        
                                    }
                                    else{
                                        mapOfUCDIdSetofOPId.put(acc.Core_Unified_Global_Customer_BP_Id__c, new Set<Id>{acc.Core_IPA_One_Partner_Id__c});
                                    }
                                    setOfOnePartnerIds.add(acc.Core_IPA_One_Partner_Id__c);           
                                }
        
        
        
        
        
        
        for(PRM_AccountBenefitAssociation__c aba : [SELECT ID,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c 
                                                    from PRM_AccountBenefitAssociation__c
                                                    where PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c IN:benefitToBudgetTypeMap.keySet()
                                                    AND PRM_Account_Id__r.RecordType.DeveloperName ='Core_Partner_Account_Group'
                                                    AND PRM_Account_Id__c in: setOfOnePartnerIds
                                                    AND PRM_Status_Nm__c = 'Active'
                                                    AND PRM_Partner_Benefit_Id__c != null 
                                                    AND PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c != null]){
                                                        
                                                        // mapOfIntelAccountandPrimeId->key = Account Id; value= UCD Id
                                                        // mapOfUCDIdSetofOPId-> key = UCD Id ; value= Set of OPID accounts
                                                        if(!mapOfIntelAccountandPrimeId.isEmpty() && mapOfIntelAccountandPrimeId.size () >0){                                                               
                                                            for (Id accId : mapOfIntelAccountandPrimeId.keyset()){
                                                                
                                                                if(mapOfIntelAccountandPrimeId.containsKey(accId)){ 
                                                                    for (String ucdId: mapOfIntelAccountandPrimeId.get(accId)){
                                                                        
                                                                        if(!mapOfUCDIdSetofOPId.isEmpty() && mapOfUCDIdSetofOPId.size () >0 && mapOfUCDIdSetofOPId.containsKey(ucdId)){
                                                                            for(Id opId: mapOfUCDIdSetofOPId.get(ucdId)){
                                                                                
                                                                                
                                                                                if(opId ==aba.PRM_Account_Id__c){
                                                                                    
                                                                                    if(ultiAccToBudgetTypeMap.containsKey(accId)){ 
                                                                                        ultiAccToBudgetTypeMap.get(accId).add(benefitToBudgetTypeMap.get(aba.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c));
                                                                                    }
                                                                                    else{
                                                                                        ultiAccToBudgetTypeMap.put(accId,new Set<String>{benefitToBudgetTypeMap.get(aba.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c)});
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                        
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
        
        
        
        return ultiAccToBudgetTypeMap;
    }
    
    global void finish(Database.BatchableContext bc) {
        try {
        if(recordTrackingId == null){
            Core_MDF_Record_Tracking__c rt = new Core_MDF_Record_Tracking__c();
            rt.Core_MDF_Scope_nm__c = IUPGMMonitor;
            Database.SaveResult insertedRecord = Database.insert(rt);
            
            if(insertedRecord != null && insertedRecord.isSuccess()){
                recordTrackingId = insertedRecord.getId();
                
            }  
        } 
        
        if(!contentVersionListToBeInserted.isEmpty()){
            
            Database.insert(contentVersionListToBeInserted);
            saveAttachment(contentVersionListToBeInserted);
        }
        
        if(recordTrackingId != null){
            List<String> userIdsList = new List<String>();
            List<Messaging.SingleEmailMessage> singleEmailList = new List<Messaging.SingleEmailMessage>();
            // List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
            String templateName =  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IUPGMDataMonitorEmailTemplate');
            String iupgmGroupName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IUPGMDataMonitorRecipients');
            EmailTemplate template = [SELECT Id, HtmlValue, Subject 
                                      FROM EmailTemplate 
                                      WHERE DeveloperName = :templateName LIMIT 1];
            
            for(GroupMember grpMember : [SELECT Id, GroupId, UserOrGroupId, Group.DeveloperName 
                                         FROM GroupMember 
                                         WHERE Group.DeveloperName =:iupgmGroupName]){
                                             userIdsList.add(grpMember.UserOrGroupId);
                                         }
            
            for( User usr : [SELECT Id FROM user WHERE Id in: userIdsList]){
                Messaging.SingleEmailMessage sendEmail =new Messaging.SingleEmailMessage();
                sendEmail.setWhatId(recordTrackingId);
                sendEmail.setTemplateId(template.id);
                sendEmail.setTargetObjectId(usr.id);
                sendEmail.setSaveAsActivity(false);
                sendEmail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                singleEmailList.add(sendEmail);
            }
            
            
            
            
            if(singleEmailList != NULL && singleEmailList.size() > 0){
                Core_MDF_GenericClassToSendMail.sendEmails(singleEmailList);
            }
            
        }
        } catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    public class pgmWrapper{
        
        public string allAccSpecificGeo;
        public string allAccSpecificBT; 
        public string specificAccSpecificBT;
        public string specificAccSpecificGeo;
        public string WW_allAccSpecificGeo;
        public string WW_allAccSpecificBT; 
        public string WW_specificAccSpecificBT;
        public string WW_specificAccSpecificGeo;
        public string accId;
        public string accName; 
        public string role;
        public string prog;
        public string region;
        public string budgetType;
        
    }
    
}