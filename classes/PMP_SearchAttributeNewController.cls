public with sharing class PMP_SearchAttributeNewController extends PMP_SearchWrapperStore {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Object>> getAttributes(String partnerOrOffId, String langCode) { 
        Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe();
        Schema.SObjectType s = m.get('PMP_Company__c');
        Schema.DescribeSObjectResult r = s.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        Map<String, List<Object>> response = new Map<String, List<Object>>();
        
        
        if(String.isNotBlank(partnerOrOffId)) {
            
            if(partnerOrOffId.startsWith(keyPrefix)) {
                // system.debug('partnerOrOffId1:::'+partnerOrOffId);
                response = getPartnerAttributes(partnerOrOffId, langCode);
            } 
            //IPA2.0:US-4497-1631_OfferingEOL
            /*else {
                // system.debug('partnerOrOffId2:::'+partnerOrOffId);
                response = getOfferingAttributes(partnerOrOffId, langCode);
            }*/
        }
        return response;
    }
    
    public static Map<String, List<Object>> getPartnerAttributes(String ptnrId, String langCode) {
        String userLang = langCode;
         //TranslationEOL
        //if(langCode == 'en-US'){
            userLang = 'en_US';
         //TranslationEOL
        //}else if(langCode == 'zh-Hans-CN' || langCode == 'zh-CN'){
           // userLang = 'zh_CN';
        //}

        Boolean testIsDisti = false; 
        Boolean testIsNotDisti = false;        
         
        if(Test.isRunningTest()){
            testIsDisti = true; 
            testIsNotDisti = true;
        }
        
        Map<String,PMP_Category__c> catMap = new Map<String,PMP_Category__c>();
        List<PMP_Category__c> topLevelCat = new List<PMP_Category__c>();
        if(Schema.sObjectType.PMP_Category__c.isAccessible()){ //ApexCRUDViolation Fix
            topLevelCat = [SELECT Id,Name,PMP_Category_Japanese_Nm__c,PMP_Category_Chinese_Nm__c,PMP_Partner_Product_Category_Cd__c FROM PMP_Category__c 
                           WHERE PMP_Partner_Product_Parent_Category_Cd__c =:PMP_StaticConstants_Partner.SOLUTION_MARKETPLACE_HIERARCHY AND PMP_Active_Ind__c=true];
        }
        for(PMP_Category__c cat:topLevelCat){
            catMap.put(cat.PMP_Partner_Product_Category_Cd__c, cat);
        }
        
        Map<String,List<Object>> partnerCatMap = new Map<String , List<Object>>();
        Map<String, List<Types>> partnerTypeMap = new Map<String, List<Types>>();
        List<ID> partnerOfferingIds = new  List<ID>();
        List<String> partnerOfferingCat = new  List<String>();
        //List<PMP_Partner_Offering__c> partnerOffering = new  List<PMP_Partner_Offering__c>();
        List<PMP_Partner_Offering_Category__c> partnerOfferingCatList = new  List<PMP_Partner_Offering_Category__c>();
        map<id, PMP_Partner_Offering_Category__c> offCatMap = new map<id, PMP_Partner_Offering_Category__c>();
        //List<PMP_Partner_Offering__c> partnerOfferingList ;
        
        for(PMP_Partner_Offering__c partnerOfferingIns:  [Select id, name,PMP_Category_nm__c,PMP_Company_Id__c, PMP_Sub_Category_nm__c FROM PMP_Partner_Offering__c WHERE PMP_Company_Id__c =:ptnrId ]){
            
            partnerOfferingIds.add(partnerOfferingIns.id);
            partnerOfferingCat.add(partnerOfferingIns.PMP_Category_nm__c);
            
        }
        for(PMP_Partner_Offering_Category__c partOffCat : [Select id, name, PMP_Offering_Id__c,PMP_Category_Id__r.name from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c IN :partnerOfferingIds and PMP_Category_Id__r.name in :partnerOfferingCat ]){
            partnerOfferingCatList.add(partOffCat);
            offCatMap.put(partOffCat.PMP_Offering_Id__c,partOffCat);
        }
        
        //PMP_Category_Id__c
        
        List<PMP_Partner_Category__c> partnerCatList = new List<PMP_Partner_Category__c>();
        if(Schema.sObjectType.PMP_Partner_Category__c.isAccessible()){ //ApexCRUDViolation Fix
            partnerCatList = [SELECT PMP_Category_Id__c, PMP_Partner_Id__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,
                              PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c 
                              FROM PMP_Partner_Category__c WHERE PMP_Partner_Id__c =:ptnrId AND PMP_Category_Id__r.PMP_Active_Ind__c=true 
                              ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c NULLS LAST];
        }
         //TranslationEOL
      /*  Map<String,PMP_Company_Translation__c> ptnrDescMap = new Map<String,PMP_Company_Translation__c>(); 
        List<PMP_Company_Translation__c> ptnrTransList = new List<PMP_Company_Translation__c>();
        if(Schema.sObjectType.PMP_Company_Translation__c.isAccessible()){ //ApexCRUDViolation Fix
            ptnrTransList = [SELECT PMP_Field_Nm__c, PMP_Company_Information_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Company_Translation__c 
                             WHERE (PMP_Field_Nm__c = :PMP_StaticConstants_Partner.Description) AND PMP_Company_Information_Id__c =: ptnrId ];//WITH SECURITY_ENFORCED
        }
        for(PMP_Company_Translation__c trans: ptnrTransList){
            ptnrDescMap.put(trans.PMP_Company_Information_Id__c,trans);
        }
        // added by balaji
        String temp = '';
        String descrip = '';
        String tagline = '';
        string userLanguage = langCode;
        
        if(ptnrDescMap.containsKey(ptnrId)){
            
            // system.debug('userLanguage'+userLanguage +'static constant'+PMP_StaticConstants_Partner.JA);
            //DE114193 -- added the condition --> || userLanguage == PMP_StaticConstants_Partner.ZH_HANS_CN
            if (userLanguage == PMP_StaticConstants_Partner.ZH_CN || userLanguage == PMP_StaticConstants_Partner.ZH_HANS_CN && ptnrDescMap.get(ptnrId).PMP_Chinese_Txt__c != null){
                temp = ptnrDescMap.get(ptnrId).PMP_Chinese_Txt__c;
            }
            else if (userLanguage == PMP_StaticConstants_Partner.JA && ptnrDescMap.get(ptnrId).PMP_Japanese_Txt__c != null){
                
                temp = ptnrDescMap.get(ptnrId).PMP_Japanese_Txt__c;
            }
            else if (ptnrDescMap.get(ptnrId).PMP_English_Txt__c != null){
                
                temp = ptnrDescMap.get(ptnrId).PMP_English_Txt__c;
            }
            if (ptnrDescMap.get(ptnrId).PMP_Field_Nm__c == PMP_StaticConstants_Partner.Description)
            {
                descrip = temp;
            }
            else if (ptnrDescMap.get(ptnrId).PMP_Field_Nm__c == 'PMP_Account_Tag_Line__c')
            {
                tagline = temp;
            }
            
        }
        //String longDesc = PMP_SearchUtilityController.getLocalisedName(ptnrDescMap.get(ptnrId), '', langCode);
        String longDescription = descrip != NULL ? descrip.unescapeHtml4().stripHtmlTags() : descrip;*/
        String longDescription ='';
        Map<String, List<Specialty>> partnerSpecialties = PMP_SearchPartnerController.getpartnerSpecialtyforCards(new String[]{ptnrId}, langCode);
        
        
        
        //Modified as part of OPID Restructure : Removing PMP_Account_Id__r.Core_IPA_Partner_Role__c from query
        for(PMP_Company__c comp : [SELECT Id,Name,PMP_Biz_Org_Type_Txt__c, PMP_Is_Distributor_Ind__c,PMP_Disti_Country_Coverage_Txt__c,toLabel(PMP_Disti_Sys_Solutions_Nm__c),toLabel(PMP_Disti_Components_Nm__c),PMP_Account_Specialty__c,PMP_Account_Dsc__c,
                                   (SELECT PMP_Category_Id__c, PMP_Partner_Id__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,
                                    PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c FROM Partner_Industry_Applications__r WHERE PMP_Category_Id__r.PMP_Active_Ind__c =true 
                                    ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c NULLS LAST),
                                   (SELECT PMP_Company_Id__c,PMP_Specification_Id__c, PMP_Specification_Id__r.Name,PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,
                                    PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c, 
                                    PMP_Specification_Id__r.PMP_Parent_Specification_Id__c,PMP_Specification_Value__c,PMP_Specification_Value__r.Name,PMP_Specification_Value__r.PMP_Specification_Value_Japanese_Cd__c,PMP_Specification_Value__r.PMP_Specification_Value_Chinese_Cd__c  FROM Company_Regions__r WHERE PMP_Specification_Id__r.PMP_Active_Ind__c = true OR PMP_Specification_Value__r.PMP_Active_Ind__c = true ORDER BY PMP_Specification_Id__r.Name, PMP_Specification_Value__r.name)
                                   FROM PMP_Company__c WHERE Id =:ptnrId]
           ){
       			partnerCatMap.put(comp.Id, new List<Attribute>());
               //TranslationEOL
                   String longDesc=comp.PMP_Account_Dsc__c;
                   longDescription = longDesc!=NULL ? longDesc.unescapeHtml4().stripHtmlTags():longDesc ;
        
        /*Display Disti Attributes (Components, solutions, country coverage)in Disti card*/
        /*New Change --> Iterating the values and storing in list Types- to display show more/less link - As part of US961625 */
               if(comp.PMP_Is_Distributor_Ind__c){
                  if(comp.PMP_Disti_Components_Nm__c != NULL) { //For Disti components 
                       Attribute att = new Attribute();
                       att.name = System.Label.PMP_Distributor_Components;
                       List<Types> types = new List<Types>();
                       if(comp.PMP_Disti_Components_Nm__c !=null){
                           for(String str : comp.PMP_Disti_Components_Nm__c.split(';')) { 
                               Types ty = new Types();
                               ty.name = str;
                               types.add(ty);
                           }
                       }
                       att.types = types;
                       partnerCatMap.get(comp.Id).add(att);
                   }
                   
                   if(comp.PMP_Disti_Sys_Solutions_Nm__c != NULL) { //For Disti solutions & systems 
                       Attribute att = new Attribute();
                       att.name = System.Label.PMP_Distributor_System_and_Solutions;
                       List<Types> types = new List<Types>();
                       if(comp.PMP_Disti_Sys_Solutions_Nm__c !=null){
                           for(String str : comp.PMP_Disti_Sys_Solutions_Nm__c.split(';')) {
                               Types ty = new Types();
                               ty.name = str;
                               types.add(ty);
                           }
                           
                       }
                       att.types = types;
                       partnerCatMap.get(comp.Id).add(att);
                   }
                   
                   
                   if(comp.PMP_Disti_Country_Coverage_Txt__c != NULL) { //For Country Coverage
                       Attribute att = new Attribute();
                       att.name = System.Label.PMP_Country_Coverage;
                       List<Types> types = new List<Types>();
                       if(comp.PMP_Disti_Country_Coverage_Txt__c !=null){
                           for(String str : comp.PMP_Disti_Country_Coverage_Txt__c.split(';')) {
                               Types ty = new Types();
                               ty.name = str;
                               types.add(ty);
                           }
                           
                       }
                       
                       att.types = types;
                       partnerCatMap.get(comp.Id).add(att);
                   }
                   
                   Map<string, string> bizorgMap = New Map<string, string> {'Intel Approved Component Supplier (IACS)'   => 'Intel Approved Component Supplier',
                       'Intel Approved Device Supplier (IADS)'      =>  'Intel Approved Device Supplier',
                       'Intel Authorized Distributor (IAD)'         =>  'Intel Authorized Distributor'  };  
                           String distributorTagline ='';
                   String description = '';
                   //Start : Added by Krishn Ch : as part of biz org description defect fix DE112480.
                   String BizOrgList = comp.PMP_Biz_Org_Type_Txt__c;
                   if(!string.isBlank(BizOrgList)){
                       for(string strVal :  BizOrgList.split('\\;')){
                           	   //distributorTagline = bizorgMap.get(strVal);
                               //distributorTaglineSet.add(bizorgMap.get(strVal));  
                               if(bizorgMap.containsKey(strVal)){
                                   distributorTagline = bizorgMap.get(strVal);
                                   if(distributorTagline =='Intel Approved Component Supplier'){
                       					description = System.Label.PMP_Intel_Approved_Component_Supplier_Txt;
                                       
                                        break;
                       
                   				    } if(distributorTagline == 'Intel Approved Device Supplier'){
                       					description = System.Label.PMP_Intel_Approved_Device_Supplier_Txt;
                                        
                                        break;
                       
                   					}if(distributorTagline == 'Intel Authorized Distributor'){
                       					description = System.Label.PMP_Intel_Authorized_Distributor_Txt ;                                         
                                        break;
                   					}
                           }
                       }
                   }
                   //End  : Added by Krishn Ch : as part of biz org description defect fix DE112480.
                  
                  
                   partnerCatMap.put('Description', new String[]{description});                   
               } 
               
               if((!comp.PMP_Is_Distributor_Ind__c)){
                   partnerCatMap.put('Specialty', partnerSpecialties.get(ptnrId));
                   partnerCatMap.put('Description', new String[]{longDescription}); 
                   Attribute attribute = new Attribute();
                   attribute.name = System.Label.PMP_GeographicalCoverage;
                   attribute.types = new List<Types>();
                   List<Types> regions= new List<Types>();
                   List<Types> subRegions= new List<Types>();
					List<Types> countries= new List<Types>();
                   //Set<String> specValues= new Set<String>();
                   for(PMP_Company_Region__c region : comp.Company_Regions__r) {
                       
                       Types ty = new Types();
                       if(region.PMP_Specification_Id__c!=Null && region.PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c == PMP_StaticConstants_Partner.REGION_PIM_ID){
                          ty.name = PMP_SearchUtilityController.getLocalisedName(region, '', langCode);
                           regions.add(ty);
                          //tribute.types.add(ty);
                        
                       }
                       else if (region.PMP_Specification_Id__c!=Null){
                           ty.name = PMP_SearchUtilityController.getLocalisedName(region, '', langCode);
                           subRegions.add(ty);
                          
                       }
                       else if (region.PMP_Specification_Value__c!=NULL){
                           ty.name= userLang == 'en_US' ? region.PMP_Specification_Value__r.Name : userLang=='zh_CN' ? region.PMP_Specification_Value__r.PMP_Specification_Value_Chinese_Cd__c : region.PMP_Specification_Value__r.PMP_Specification_Value_Japanese_Cd__c ;
                          countries.add(ty);
                       }
                   }
                   
                   attribute.types.addAll(regions);
                   attribute.types.addAll(subRegions);
                   attribute.types.addAll(countries);

                   
                   partnerCatMap.get(comp.Id).add(attribute);
                   
                   for(PMP_Partner_Category__c cat : comp.Partner_Industry_Applications__r){
                       
                       Types type = new Types();
                       type.id = cat.PMP_Category_Id__c;
                       type.name = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                       type.englishName = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'en_US');
                       
                       //if(Test.isRunningTest()){
                       //  type.ancestor= 'NPP_01_TYPE|NPP_01_Industry';
                       //}else{
                       if(cat.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c != null)
                           type.ancestor = cat.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c.split('\\|')[0];
                       // }
                       if(!partnerTypeMap.containsKey(cat.PMP_Partner_Id__c)){
                           List<Types> types = new List<Types>();
                           types.add(type);
                           partnerTypeMap.put(cat.PMP_Partner_Id__c, types);
                           partnerTypeMap.get(cat.PMP_Partner_Id__c).sort();
                       }else{
                           partnerTypeMap.get(cat.PMP_Partner_Id__c).add(type);
                           partnerTypeMap.get(cat.PMP_Partner_Id__c).sort();
                       }                        
                   }
                   
                   for(String partnerId : partnerTypeMap.keySet()){
                       Map<String, Attribute> attMap = new Map<String ,Attribute>();
                       
                       for(Types type  : partnerTypeMap.get(partnerId)){
                           if (!attMap.containsKey(type.ancestor))
                           {
                               Attribute att= new Attribute();
                               if(catMap.containsKey(type.ancestor)){
                                   att.name = PMP_SearchUtilityController.getLocalisedName(catMap.get(type.ancestor), PMP_StaticConstants_Partner.CAT_NAME_FIELD,langCode);
                               }
                               att.types = new List<Types>();
                               att.types.add(type);
                               attMap.put(type.ancestor , att);
                           }
                           else
                           {
                               attMap.get(type.ancestor).types.add(type);
                           }
                       }
                       //Code to sequence the offering card Attributes
                       List<Attribute> catAttributes = new List<Attribute>();
                       List<String> catOrder = PMP_StaticConstants_Partner.catOrder;
                       for(String cat :catOrder){
                           if(attMap.containsKey(cat)){
                               catAttributes.add(attMap.get(cat));
                           }
                       }
                       //Changes End
                       
                       partnerCatMap.get(comp.Id).addAll(catAttributes);
                   }
               }
               //Market place 2.0 Changes for Disti Quick Card Requirement End
           } 
        return partnerCatMap;
        
    }
    //IPA2.0:US-4497-1631_OfferingEOL
    /*public static Map<String, List<Object>> getOfferingAttributes(String offeringId, String langCode) {
        Map<String,List<Types>> offCatMap = new Map<String , List<Types>>();
        Map<String,PMP_Category__c> catMap = new Map<String,PMP_Category__c>();
        List<PMP_Partner_Offering_Specification__c> specList = new List<PMP_Partner_Offering_Specification__c>();
        String geograPhyname = PMP_StaticConstants_Partner.Geography;
        List<Id> countryId = new List<Id>();
        if(Schema.sObjectType.PMP_Partner_Offering_Specification__c.isAccessible()){ //ApexCRUDViolation Fix
            specList = [SELECT Id, Name, PMP_Specification_Nm__c, PMP_Ancestor_Specification_Cd__c,PMP_Specification_Value_Cd__c
                        ,PMP_Specification_Id__r.Name,PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c, 
                        PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c,PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c,
                        PMP_Specification_Value_Id__c FROM PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c =:offeringId Order By PMP_Specification_Nm__c,PMP_Specification_Value_Cd__c]; 
        }
        Map<Id, Boolean> specIdToSpecValFlag = new Map<Id, Boolean>();
       // Boolean specValueNull = false;
        for(PMP_Partner_Offering_Specification__c spec : specList) { 
            if(spec.PMP_Ancestor_Specification_Cd__c != null && spec.PMP_Ancestor_Specification_Cd__c.contains('NPP_GeographicCoverage'))
            {   
                if(spec.PMP_Specification_Value_Cd__c == null){
                    specIdToSpecValFlag.put(spec.Id, true); 
                    //specValueNull = true;
                }
                else{                        
                    countryId.add(spec.PMP_Specification_Value_Id__c);
                    specIdToSpecValFlag.put(spec.Id, false);					
                }
            }
        }

        List<PMP_Specification_Value__c> specCountryValues = new List<PMP_Specification_Value__c>();
        if(geograPhyname != '' && countryId != null){
             specCountryValues = [Select Id,Name,PMP_Specification_Value_Chinese_Cd__c, 
                                        PMP_Specification_Value_Japanese_Cd__c , PMP_Spec_Value_Type_Nm__c
                                        From PMP_Specification_Value__c where PMP_Spec_Value_Type_Nm__c =: geograPhyname and Id IN :countryId Order By Name];
        }

        List<PMP_Category__c> topLevelCat = [SELECT Id,Name,PMP_Category_Japanese_Nm__c,PMP_Category_Chinese_Nm__c,PMP_Partner_Product_Category_Cd__c FROM PMP_Category__c 
                                             WHERE PMP_Partner_Product_Parent_Category_Cd__c =:PMP_StaticConstants_Partner.SOLUTION_MARKETPLACE_HIERARCHY AND PMP_Active_Ind__c=true];
        
        for(PMP_Category__c cat:topLevelCat){
            catMap.put(cat.PMP_Partner_Product_Category_Cd__c, cat);
        }
        List<PMP_Partner_Offering_Category__c> offCatList  = new List<PMP_Partner_Offering_Category__c>();
        if(Test.isRunningTest()){
            if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){ //ApexCRUDViolation Fix
                offCatList  = [Select id,PMP_Offering_Id__c, Name,PMP_Category_Id__c,PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,
                               PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.Type__c, PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c, 
                               PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c,PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c ,PMP_Category_Id__r.PMP_Parent_Category_Id__c from PMP_Partner_Offering_Category__c  where name != null];
            }
            //System.debug('offCatList'+offCatList);
            for(PMP_Partner_Offering_Category__c offCat : offCatList){
                // System.debug(offCat+'-');
                // System.debug(offCat.PMP_Category_Id__r.Name);
                // System.debug('ddd'+offcat.PMP_Category_Id__r.PMP_Parent_Category_Id__c );
            }
            
        } 
        else{
            offCatList = [SELECT PMP_Offering_Id__c,PMP_Category_Id__c, PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,
                          PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.Type__c, PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c, 
                          PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c,PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c ,PMP_Category_Id__r.PMP_Parent_Category_Id__c
                          FROM PMP_Partner_Offering_Category__c WHERE PMP_Offering_Id__c  =:offeringId AND PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c !=null
                          AND PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c !=null AND PMP_Category_Id__r.PMP_Active_Ind__c = true 
                          ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c NULLS LAST];
        }
        
        Map<String,PMP_Partner_Offering_Translation__c> offDescMap = new Map<String,PMP_Partner_Offering_Translation__c>();
        List<PMP_Partner_Offering_Translation__c> offTransList = new List<PMP_Partner_Offering_Translation__c>();
        if(Schema.sObjectType.PMP_Partner_Offering_Translation__c.isAccessible()){ //ApexCRUDViolation Fix
            offTransList = [SELECT PMP_Field_Nm__c, PMP_Partner_Offering_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Partner_Offering_Translation__c 
                            WHERE (PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_NAME OR PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_DESCRIPTION) AND PMP_Partner_Offering_Id__c =:offeringId];
            
        }                                                         
        for(PMP_Partner_Offering_Translation__c trans: offTransList){
            if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_DESCRIPTION){
                offDescMap.put(trans.PMP_Partner_Offering_Id__c,trans);
            }
            
        }
        // added by balaji
        String temp = '';
        String descrip = '';
        String tagline = '';
        string userLanguage = langCode;
        
        if(offDescMap.containsKey(offeringId)){
            
            //system.debug('userLanguage'+userLanguage +'static constant'+PMP_StaticConstants_Partner.JA);
            //DE114193 -- added the condition --> || userLanguage == PMP_StaticConstants_Partner.ZH_HANS_CN
            if (userLanguage == PMP_StaticConstants_Partner.ZH_CN || userLanguage == PMP_StaticConstants_Partner.ZH_HANS_CN && offDescMap.get(offeringId).PMP_Chinese_Txt__c != null){
                temp = offDescMap.get(offeringId).PMP_Chinese_Txt__c;
            }
            else if (userLanguage == PMP_StaticConstants_Partner.JA && offDescMap.get(offeringId).PMP_Japanese_Txt__c != null){
                
                temp = offDescMap.get(offeringId).PMP_Japanese_Txt__c;
            }
            else if (offDescMap.get(offeringId).PMP_English_Txt__c != null){
                
                temp = offDescMap.get(offeringId).PMP_English_Txt__c;
            }
            if (offDescMap.get(offeringId).PMP_Field_Nm__c == PMP_StaticConstants_Offering.Description)
            {
                descrip = temp;
            }
            else if (offDescMap.get(offeringId).PMP_Field_Nm__c == 'PMP_Account_Tag_Line__c')
            {
                tagline = temp;
            }
            
        }
        //String longDesc = PMP_SearchUtilityController.getLocalisedName(offDescMap.get(offeringId), '', langCode);
        String longDescription = descrip != NULL ? descrip.stripHtmlTags() : descrip;
        
        
        
        Map<String,Types> catTypeMap = new Map<String,Types>();
        for (PMP_Partner_Offering_Category__c offCat : offCatList){
            
            Types type = new Types();
            type.id = offCat.PMP_Category_Id__c;
            type.parentId = offCat.PMP_Category_Id__r.PMP_Parent_Category_Id__c;
            type.name = PMP_SearchUtilityController.getLocalisedName(offCat, '', langCode);
            if(Test.isRunningTest()){
                //type.ancestor= 'NPP_01_TYPE|NPP_01_Industry';
                //type.ancestorId = 'NPP_01_TYPE|NPP_01_Industry';
                type.ancestor='Test1|Test2';
                type.ancestorId='Test1|Test2';
                
            }else{
                type.ancestor = offcat.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c.split('\\|')[0];
                type.ancestorId = offcat.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c;
            }
            
            //Used in Compare Products
            type.secondTierCat = false;
            if(offCat.PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c!=null){
                List<String> ancestors = offCat.PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.split('\\|');
                if(offCat.PMP_Category_Id__r.Type__c == 'Category' && ancestors.size()==2){
                    type.secondTierCat=true;
                    type.searchParams = new SearchParams();
                    type.searchParams.cat = type.Id;
                    type.searchParams.type = PMP_StaticConstants_Partner.product;
                }
            }
            catTypeMap.put(offCat.PMP_Category_Id__c,type);
            //Changes End
            //
            if (!offCatMap.containsKey(offCat.PMP_Offering_Id__c))
            {
                List<Types> typeList= new List<Types>();
                typeList.add(type);
                offCatMap.put(offCat.PMP_Offering_Id__c, typeList);
            }
            else
            {
                offCatMap.get(offCat.PMP_Offering_Id__c).add(type); 
            }
        }
        
        Map<String , List<Object>> offAttMap = new Map<String ,List<Object>>();
        offAttMap.put('Description', new String[]{longDescription});
        for (String off : offCatMap.keySet())
        {
            Map<String , Attribute> attMap = new Map<String ,Attribute>();
            for (Types type : offCatMap.get(off))
            {
                if(type.ancestor==PMP_StaticConstants_Partner.PIM_CATEGORY_ID){
                    if(type.ancestorId.split('\\|').size()==2 && catTypeMap.containsKey(type.parentId)){
                        type.name = catTypeMap.get(type.parentId).name+' – '+type.name;
                        if (!attMap.containsKey(type.ancestor))
                        {
                            Attribute att= new Attribute();
                            if(catMap.containsKey(type.ancestor)){
                                att.name = PMP_SearchUtilityController.getLocalisedName(catMap.get(type.ancestor), PMP_StaticConstants_Partner.CAT_NAME_FIELD,langCode);
                            }
                            att.types = new List<Types>();
                            att.types.add(type);
                            //attMap.put(type.ancestor , att);
                        }
                        else
                        {
                            // attMap.get(type.ancestor).types.add(type);
                        }
                    }
                }else{
                    
                    if(!attMap.containsKey(type.ancestor)) {
                        
                        Attribute att= new Attribute();
                        if(catMap.containsKey(type.ancestor)){
                            att.name = PMP_SearchUtilityController.getLocalisedName(catMap.get(type.ancestor), PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                        }
                        att.types = new List<Types>();
                        att.types.add(type);
                        attMap.put(type.ancestor , att);
                    }
                    else
                    {
                        attMap.get(type.ancestor).types.add(type);
                    }
                }
            }
            Attribute regAtt = new Attribute();
            regAtt.name = System.Label.PMP_GeographicalCoverage;
            regAtt.types = new List<Types>();
             

            List<Types> regions = new List<Types>();
            List<Types> subRegions = new List<Types>();
            List<Types> countries = new List<Types>();

            for(PMP_Partner_Offering_Specification__c spec : specList) { 
                Types ty = new Types();
                if(spec.PMP_Ancestor_Specification_Cd__c != null && spec.PMP_Ancestor_Specification_Cd__c.contains('NPP_GeographicCoverage'))
                {   
                    if(specIdToSpecValFlag.get(spec.Id) == true){
                        if(spec.PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c == PMP_StaticConstants_Partner.REGION_PIM_ID){
                           ty.name =  PMP_SearchUtilityController.getLocalisedName(spec,'',langCode);  
                           regions.add(ty);
                        }
                        else{
                           ty.name =  PMP_SearchUtilityController.getLocalisedName(spec,'',langCode); 
                           subRegions.add(ty);
                        }
                    }
                }
            }
           
            for(PMP_Specification_Value__c country : specCountryValues){
                Types ty = new Types();
                ty.name = (langCode=='zh_CN' || langCode == 'zh-Hans-CN')?country.PMP_Specification_Value_Chinese_Cd__c : ((langCode=='ja') ? country.PMP_Specification_Value_Japanese_Cd__c: country.Name);
                countries.add(ty);
            }

            regAtt.types.addAll(regions);
            regAtt.types.addAll(subRegions);
            regAtt.types.addAll(countries);          
            
            //Code to sequence the offering card Attributes
            List<Attribute> catAttributes = new List<Attribute>();
            
            catAttributes.add(regAtt);
            List<String> catOrder = PMP_StaticConstants_Partner.catOrder;
            for(String cat: catOrder){
                if(attMap.containsKey(cat)){
                    catAttributes.add(attMap.get(cat));
                }
            }
            //Changes End
            offAttMap.put(off , catAttributes);
        }
        
        return offAttMap;
    }*/
      
}