/****************************************************************************************************************************************
* Class Name  : PMP_ProductPartnerDetailsController
* Version     : 1.0 
* Created Date: 06-26-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Raj                   06-26-2019                    Created for fetching partner details of given partner
* Tanzanite Team - Nikhil           07-25-2019                    Added getRegionAttribute method
****************************************************************************************************************************************************************/
public with sharing class PMP_ProductPartnerDetailsController extends PMP_SearchWrapperStore{
    /**
* Method added by raj to fetch partner detail of the given partnerId
* @description - method to fetch partner detail for the given partnerId
* @param - partnerId for which the detail is to be fetched
* @param - company i.e information to populate partner wrapper
* @param - isProductDetail to check from where the method is called
* @return - Partner
* Method parameters - Id
* Method parameters - PMP_Company__c
* Method parameters - Boolean
*/ 
    //IPA2.0:US-4497-1631_OfferingEOL
    public static Partner getPartnerDetails(/*Id offeringId,*/Id partnerId, PMP_Company__c companyInfo, Boolean isProductDetail, String langCode){
        
        List<PMP_Company_Resource__c> partner_resource = new List<PMP_Company_Resource__c>();
        Map<String, String> partnerContentMap = new Map<String,String>();//Added by Manasa - for content Asset implementation
        List<String> partnerConDocIds = new List<String>();//ContentDocumentId list
        //List<String> partner_progs = new List<String>();//company program list
        //List<String> partner_tiers  = new List<String>();//company program membership list
        //Map<String,String> programNameByValue = new Map<String,String>();//metadata map
        Partner partner=new Partner();//Instance of partner wrapper from PMP_SearchWrapperStore
        PMP_Company__c company;
        
        
        
        if(partnerId != null){              //fetching company record for the given partnerId if not null
            if(companyInfo == null){        //if received company info is null then query company info by partnerID
                if(Schema.sObjectType.PMP_Company__c.isAccessible()){
					//Modified as a part of OPID Restructure : Removing PMP_Account_Id__c from Query
                    company=[SELECT Id, Name, PMP_Partner_Benefit_Type__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c, PMP_Account_Dsc__c,PMP_Account_Address_Txt__c,
                             PMP_Account_Industry__c, PMP_Account_Application__c,PMP_Disti_Components_Nm__c,PMP_Disti_Sys_Solutions_Nm__c,
                             PMP_Account_Region__c,PMP_Account_Website__c,
                             PMP_Account_Program_Membership__c, PMP_Account_Specialty__c,PMP_Is_Distributor_Ind__c,toLabel(PMP_Company_Lead_Gen_Language_Nm__c)
                             FROM PMP_Company__c where id=:partnerId LIMIT 1];
                    //Existing Query:
                    /*
					company=[SELECT Id, Name, PMP_Partner_Benefit_Type__c, PMP_Account_Id__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c, PMP_Account_Dsc__c,PMP_Account_Address_Txt__c,
                             PMP_Account_Industry__c, PMP_Account_Application__c,PMP_Disti_Components_Nm__c,PMP_Disti_Sys_Solutions_Nm__c,
                             PMP_Account_Region__c,PMP_Account_Website__c,
                             PMP_Account_Program_Membership__c, PMP_Account_Specialty__c,PMP_Is_Distributor_Ind__c,toLabel(PMP_Company_Lead_Gen_Language_Nm__c)
                             FROM PMP_Company__c where id=:partnerId LIMIT 1];
					*/
                }         
            }
            else{//if received company info is not null then use that info to populate partner
                company=companyInfo;
        
            }
            
            //fetching company resource records for the given partner/company
            if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()){
                partner_resource = [SELECT PMP_Company_Id__c, PMP_Company_Image__c from PMP_Company_Resource__c WHERE PMP_Company_Id__c =: partnerId AND 
                                    PMP_Company_Resource_Type_Nm__c='Image' and PMP_Company_Image__c!=null and PMP_Company_Resource_Sequence_Nbr__c = 0 LIMIT 1];
            }
            if(!partner_resource.isEmpty()){//if company resource exists add to the contentdocumentId list
                for( PMP_Company_Resource__c res: partner_resource ){
                    //partnerConDocIds.add(partner_resource[0].PMP_Company_Image__c);
                    partnerContentMap.put(res.PMP_Company_Id__c,res.PMP_Company_Image__c);//Added by Manasa - for content Asset implementation
                }
            }
            partnerConDocIds.addAll(partnerContentMap.values());
            //get content distribution record for all the contentdocumentIds
           // List<ContentDistribution> partnerConDistIds = PMP_SearchOfferingImageUtility.getContentDistList(partnerConDocIds); //Added by Manasa - for content Asset implementation
            Map<String,String> partnerConAssetUrl = PMP_SearchOfferingImageUtility.getContentAssetUrlMap(partnerConDocIds);
            
            //populate the partner wrapper with fetched company record
            partner.id = company.Id;
            partner.autoPartnerId = company.PMP_Marketing_Profile_Id__c;
            //partner.description = company.PMP_Account_Dsc__c;
            partner.name = company.Name;
            if(isProductDetail){//if request is from product detail populate name $ image URL of partner wrapper
            	partner.benefitType = company.PMP_Partner_Benefit_Type__c;
                List<Options> languagePrefs = new List<Options>();
                if(company.PMP_Company_Lead_Gen_Language_Nm__c!=null){                       
                    for(String prefLang : company.PMP_Company_Lead_Gen_Language_Nm__c.split(';')){
                        Options option = new Options();
                        option.label = prefLang;
                        option.value = prefLang;
                        option.selected = true;
                        languagePrefs.add(option);
                    }                                   
                }
                
                partner.leadLangPreference = PMP_SearchUtilityController.getLanguageMessage(languagePrefs);
            }
            //if(!partnerConDistIds.isEmpty()){//if content distribution exists populate image URL with ContentDownloadUrl
            
            Map<Id, Boolean> companyIdAndMemberFlag = PMP_SearchPartnerController.formMemberFlagMap(new Set<Id> { company.Id });
            
            if(companyIdAndMemberFlag.get(company.Id) != NULL && companyIdAndMemberFlag.get(company.Id)) {
                partner.imageUrl = System.Label.PMP_Member_Card_Image;
            } else {
                
                if(partnerConAssetUrl.containsKey(partnerContentMap.get(company.Id))){//Added by Manasa  - for content Asset implementation
                    //partner.imageUrl = partnerConDistIds[0].ContentDownloadUrl;// base-url/file-assets/developerName
                    String assetName = partnerConAssetUrl.get(partnerContentMap.get(company.Id)); //Added by Manasa  - for content Asset implementation
                    partner.imageUrl = System.Label.PMP_CommunityURLSuffix+'file-asset/'+assetName+'?isOptimized=false'; //Added by Manasa  - for content Asset implementation
                    
                }
                else{//else populate imageUrl with static image Url //Modified by Nikhil on 28-Nov-2019 to move default image logic to content asset
                    partner.imageUrl = PMP_StaticConstants_Partner.staticPartnerUrl;
                }
            }
            //set the attributes(i.e Programs and Speciality) for the partner
            partner.attributes=new List<Attribute>();
            Attribute programs = new Attribute();
            //programs.name=System.Label.PMP_Program_Membership;
            //Added By Manjula as part of US692923        
            programs.name=System.Label.PMP_Partner_Role;
            programs.types=new List<Types>();
            
            String programMembership = company.PMP_Account_Program_Membership__c;
            
            if(String.isNotBlank(programMembership)) {
                
                Set<String> ppNames = new Set<String>();
                Map<String, List<String>> membershipMapList = new Map<String, List<String>>();
				
                for(String str : programMembership.split(';')) {
                    if(String.isNotBlank(str)) {
                        str = str.trim();
                        if(str.contains('-')) {
                            String[] strArr = str.split('-');
                            if(strArr.size() > 1) {
                                String key = strArr[0].trim();
                                ppNames.add(key);
                                if(membershipMapList.containsKey(key.toLowerCase())){
                                    List<String> distiBizOrgs= new List<String>();
                                    distiBizOrgs=membershipMapList.get(key.toLowerCase());
                                    distiBizOrgs.add(strArr[1].trim());
                                    membershipMapList.put(key.toLowerCase(), distiBizOrgs);
                                }
                                else{
                                    membershipMapList.put(key.toLowerCase(), new List<String> {strArr[1].trim()});
                                }
                            }
                        }
                    }
                }
                
        //        Map<String, PMP_SearchPartnerProgram_Config__mdt> partProgConfig = new Map<String, PMP_SearchPartnerProgram_Config__mdt>();
                Map<String, PMP_Partner_Tier__c> ipaBadgeTier = new Map<String, PMP_Partner_Tier__c>();
                Map<String, PMP_Partner_Tier__c> bizOrgType = new Map<String, PMP_Partner_Tier__c>();
                
              /*  for(PMP_SearchPartnerProgram_Config__mdt prog : [SELECT PMP_Partner_Program_Name__c,PMP_Partner_Program_Value__c,PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c FROM PMP_SearchPartnerProgram_Config__mdt WHERE Active__c = true]){
                	partProgConfig.put(prog.PMP_Partner_Program_Value__c, prog);
                }*/
                
                List<PMP_Partner_Tier__c> partnerTiers = new List<PMP_Partner_Tier__c>();
                
                if(Schema.sObjectType.PMP_Partner_Tier__c.isAccessible()){   //ApexCRUDViolation Fix
                    partnerTiers = [SELECT Id,Name,PMP_Is_Biz_Org_Type_Ind__c,PMP_Partner_Tier_Chinese_Nm__c,PMP_Partner_Tier_Name_Japanese__c FROM PMP_Partner_Tier__c where name != null];
                }
                
                for(PMP_Partner_Tier__c tier : partnerTiers) {
                	
                    if(tier.PMP_Is_Biz_Org_Type_Ind__c) {
                        bizOrgType.put(tier.Name, tier);
                    } else {
                        ipaBadgeTier.put(tier.Name, tier);
                    }                    
                }
                
                Set<String> chineseLangCodes = new Set<String> { 'zh-Hans-CN', 'zh-CN', 'zh_CN' };
                String fieldName = chineseLangCodes.contains(langCode) ? 'PMP_Partner_Tier_Chinese_Nm__c' : (langCode == 'ja' ? 'PMP_Partner_Tier_Name_Japanese__c' : 'Name');
                //String tierFieldName = chineseLangCodes.contains(langCode) ? 'PMP_IPA_Badge_Tier_Chinese__c' : (langCode == 'ja' ? 'PMP_IPA_Badge_Tier_Japanese__c' : 'PMP_IPA_Badge_Tier__c');
                //String bizFieldName = chineseLangCodes.contains(langCode) ? 'PMP_Biz_Org_Type_Chinese__c' : (langCode == 'ja' ? 'PMP_Biz_Org_Type_Japanese__c' : 'PMP_Biz_Org_Type__c');
                
                if(ppNames.size() > 0) {
                    for(PMP_Partner_Program__c pp : [SELECT Id, Name, PMP_Partner_Role_Parent_Id__c,PMP_Partner_Program_Value_Txt__c,
                                                     PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c FROM PMP_Partner_Program__c WHERE Name IN :ppNames AND PMP_Is_Active_Ind__c=TRUE]) {
                                                         //logic of forming the attributes and adding them to list is embedded inside the for loop to handle multiple disti bizorgs
                                                         for(String tier: membershipMapList.get(pp.Name.toLowerCase())){
                                                             Types type = new Types();
                                                             type.id = pp.PMP_Partner_Role_Parent_Id__c != NULL ? pp.PMP_Partner_Role_Parent_Id__c : pp.Id;
                                                             type.filterId = pp.PMP_Partner_Role_Parent_Id__c != NULL ? pp.Id : null;
																			   
                                                             PMP_Partner_Tier__c badgeTier = ipaBadgeTier.get(tier);
                                                             PMP_Partner_Tier__c bizType = bizOrgType.get(tier);
                                                             String tierVal = badgeTier != NULL && badgeTier.get(fieldName) != NULL ? (String)badgeTier.get(fieldName) : NULL;
                                                             String bizVal = bizType != NULL && bizType.get(fieldName) != NULL ? (String)bizType.get(fieldName) : NULL;
                                                             type.tier = tierVal != NULL ? tierVal : (bizVal != NULL ? bizVal : tier);
                                                                 if(type.tier == NULL) type.tier = tier;
                                                             //       PMP_SearchPartnerProgram_Config__mdt ppConfig = partProgConfig.get(pp.Name);
                                                             String progname=PMP_SearchUtilityController.getLocalisedName(pp, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                                                             //    type.name = ppConfig != NULL ? (String)ppConfig.get(fieldName) : pp.Name;
                                                             type.name = progname;      
                                                             programs.types.add(type); 
                                                         }

                    }
                }
            }
            
            /*
            if(company.PMP_Partner_Program_nm__c!=null && company.PMP_Account_Program_Membership__c!=null){//if program name and membership is not null,splitting it and adding them to the list
                partner_progs = company.PMP_Partner_Program_nm__c.split(';');
               
                partner_tiers = company.PMP_Account_Program_Membership__c.split(';');
            }
            
            if(company.PMP_Partner_Program_nm__c!=null){//if company program name is not null,fetch metadata records based on company program name and populate metadata map
                String userLanguage = langCode;
                String partnerProgName = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Name',userLanguage);
                if(String.isEmpty(partnerProgName)){
                    partnerProgName = 'PMP_Partner_Program_Name__c';
                }
                for (PMP_SearchPartnerProgram_Config__mdt prog: [select PMP_Partner_Program_Name__c,PMP_Partner_Program_Value__c,
                                                                 PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c
                                                                 from PMP_SearchPartnerProgram_Config__mdt where
                                                                 PMP_Partner_Program_Value__c in :partner_progs]){
                                                                     if(String.isEmpty((String)prog.get(partnerProgName))){
                                                                         programNameByValue.put(prog.PMP_Partner_Program_Value__c, prog.PMP_Partner_Program_Name__c);
                                                                     }
                                                                     else{
                                                                          programNameByValue.put(prog.PMP_Partner_Program_Value__c, (String)prog.get(partnerProgName));
                                                                     }
                                                                     
                                                                 }
                
                //populating partner program attributes for partner card
               
                for(Integer i = 0; i < partner_tiers.size(); i++){
                    Types type=new Types();
                    //if company membership contains '-' populate Program membership attribute as : for 'ITP - Gold' membership 'Program Membership' attribute should be 'Intel® Technology Provider Program - GOLD'
                    if(partner_tiers[i].contains('-')){
                        
                        type.id = programNameByValue.get(partner_tiers[i].split('-')[0].trim()) + ' - ' + partner_tiers[i].split('-')[1].trim().capitalize();
                       // type.name = programNameByValue.get(partner_tiers[i].split('-')[0].replace(' ','')) + ' - ' + partner_tiers[i].split('-')[1].replace(' ','').capitalize();  
                        type.name = programNameByValue.get(partner_tiers[i].split('-')[0].trim()) + ' - ' + partner_tiers[i].split('-')[1].capitalize();  
                        
                        programs.types.add(type);
                    }else{
                        type.id = programNameByValue.get(partner_tiers[i]);
                        type.name = programNameByValue.get(partner_tiers[i]);
                        programs.types.add(type);
                    }
                    
                }
                
           }
            */
           Map<String,String> valueLabelMap = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();      
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                valueLabelMap.put(pickListVal.getValue(),pickListVal.getLabel());
            }
            
            
            //Created by Kartik
            Map<String,String> valueIdMap = new Map<String,String>();
            Map<String,String> translatedLabelIdMap = new Map<String,String>();
            Map<String,String> idValueMap = new Map<String,String>();
            //Schema.DescribeFieldResult fieldOutput = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();
            List<PMP_Partner_Specialty__c> specialtyList = new List<PMP_Partner_Specialty__c>(); 
            if(Schema.sObjectType.PMP_Partner_Specialty__c.isAccessible()){ //ApexCRUDViolation Fix
            specialtyList = [SELECT id, Name,PMP_Partner_Specialty_Japanese_Nm__c, PMP_Partner_Specialty_Chinese_Nm__c, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE];
            }
            
            //Added as part of DE101266 as Optane related specialty values have different Label and API names 
            //Specialty have translations at Object records level(PMP_Partner_Specialty__c) and Picklist level(PMP_Company__c.PMP_Account_Specialty__c)
            Set<String> chineseLangCodes = new Set<String> { 'zh-Hans-CN', 'zh-CN', 'zh_CN' };
                
            for(PMP_Partner_Specialty__c specData: specialtyList){
                valueIdMap.put(specData.Name, specData.Id); 
                String translatedSpecialtyName =  chineseLangCodes.contains(langCode) ? specData.PMP_Partner_Specialty_Chinese_Nm__c : (langCode == 'ja' ? specData.PMP_Partner_Specialty_Japanese_Nm__c : specData.Name);
                
                //Map with translated specialty name as the key Id as the value
                translatedLabelIdMap.put(translatedSpecialtyName, specData.Id);  		
                idValueMap.put(specData.Id, specData.Name); 
                 	         			         
            }
                                   
            
            //Adding ODM-LOEM Specialty as Partner Program
           if(String.isNotEmpty(company.PMP_Account_Specialty__c)  && company.PMP_Account_Specialty__c.contains(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program)){
                
                Types odm = new Types();
                odm.id = valueIdMap.get(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program);
                odm.name = System.Label.PMP_Partner_Directory_title3;
                //programs.types.add(odm);
            }
            //Changes End
            if(!programs.types.isEmpty()){
                partner.attributes.add(programs);//add attribute to partner attribute list
            }
            
            
            if( String.isNotEmpty(company.PMP_Account_Specialty__c) ){
                Attribute att = new Attribute();
                att.types=new List<Types>();
                att.name=System.Label.PMP_Speciality;//2nd attribute
                for(String spec : company.PMP_Account_Specialty__c.split(';')){
                    if(valueLabelMap.containsKey(spec) && !spec.equals(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program)){
                        Types spectype=new Types();
                        //spectype.id= spec.replace(' ','_');
                        spectype.id = valueIdMap.get(spec);     
                        spectype.name= valueLabelMap.get(spec);                      
                        
                        SearchParams params = new SearchParams();
                        params.type = 'partner';
                        params.selectedFilters = new Map<String,List<String>>();
                        List<String> filterList = new List<String>();
                        //filterList.add(spectype.id);
                        filterList.add(valueIdMap.get(spec));   //Added by Kartik
                        params.selectedFilters.put('Specialty_Partner', filterList);
                  //      params.specialty = valueIdMap.get(spec);
          				 //Commented the above line and replaced with below line as part of DE101266: Optane related specialty values have different Label and API names     
          				 //passing the specialty id based on the specialty name          
                        params.specialty = translatedLabelIdMap.get(valueLabelMap.get(spec));
                        specType.searchParams=params;
                        
                        att.types.add(spectype);
                    }
                }
                if(!att.types.isEmpty()){
                    partner.attributes.add(att);//add attribute to partner attribute list
                }
                
            }
            
            // Logic to Show Countries for Disti Partner Accounts - Added By Manjula -US697105
            Attribute countryAtt = new Attribute();
            Boolean isDisti = company.PMP_Is_Distributor_Ind__c;
            countryAtt = isDisti ? getCountryAttribute(partnerId, isProductDetail, langCode) : getRegionAttribute(partnerId, isProductDetail, langCode/*, offeringId*/);//IPA2.0:US-4497-1631_OfferingEOL
            partner.attributes.add(countryAtt);
            
            //Logic to show Distributor Product Values for Disti Partner Accounts- Added By Manjula -US697107
           if(isDisti) {
                Attribute distiAtt = new Attribute();
                distiAtt.name = System.Label.PMP_Distribution_Products;//'Distribution Products';
                distiAtt.title = distiAtt.name;
                distiAtt.modalButtonLabel = System.Label.PMP_View_Distribution_Products;
                distiAtt.modalTitleLabel = System.Label.PMP_Distribution_Products;
                distiAtt.displayInModal = true;
                distiAtt.displaySectionsInModal = false;
                distiAtt.typeGroupings = new List<TypeGroup>();
                distiAtt.sections = new List<Sections>();
                if(company.PMP_Disti_Components_Nm__c != NULL) {
                    TypeGroup dc = new TypeGroup();
                    dc.isDistributor = true;
                    dc.name = System.Label.PMP_Distributor_Components;//'Distributor Components'
                    dc.types = new List<Types>();
                    
                    Sections distDcSec = new Sections();
                    distDcSec.label = System.Label.PMP_Distributor_Components;
                    distDcSec.values = new List<SectionValues>();
                    
                    for(String str : company.PMP_Disti_Components_Nm__c.split(';')) {
                        if(String.isNotBlank(str)) {
                            Types t = new Types();
                            t.name = str.trim();
                            dc.types.add(t);
                            
                            SectionValues dcSecVal = new SectionValues();
                            dcSecVal.label = str.trim();
                            distDcSec.values.add(dcSecVal);
                        }
                    }
                    distiAtt.typeGroupings.add(dc);
                    distiAtt.sections.add(distDcSec);
                }
                
                if(company.PMP_Disti_Sys_Solutions_Nm__c != NULL) {
                    TypeGroup dss = new TypeGroup();
                    dss.isDistributor = true;
                    dss.name =System.Label.PMP_Distributor_System_and_Solutions;// 'Distributor System and Solutions';
                    dss.types = new List<Types>();
                    
                    Sections distDssSec = new Sections();
                    distDssSec.label = System.Label.PMP_Distributor_System_and_Solutions;
                    distDssSec.values = new List<SectionValues>();
                    
                    for(String str : company.PMP_Disti_Sys_Solutions_Nm__c.split(';')) {
                        if(String.isNotBlank(str)) {
                            Types t = new Types();
                            t.name = str.trim();
                            dss.types.add(t);
                            
                            SectionValues dssSecVal = new SectionValues();
                            dssSecVal.label = str.trim();
                            distDssSec.values.add(dssSecVal);
                        }
                    }
                    distiAtt.typeGroupings.add(dss);
                    distiAtt.sections.add(distDssSec);
                }
                
                if(distiAtt.typeGroupings.size() > 0) {
                    partner.attributes.add(distiAtt);
                }
            }
            
            Attribute indAtt = getCategoryAttribute(partnerId, isProductDetail, PMP_StaticConstants_Partner.PIM_INDUSTRY_ID, langCode);
            if(indAtt!=null)
                partner.attributes.add(indAtt);
            
            Attribute appAtt = getCategoryAttribute(partnerId, isProductDetail, PMP_StaticConstants_Partner.PIM_APPLICATION_ID, langCode);
            if(appAtt!=null)
                partner.attributes.add(appAtt);
            //Changes End
            if(company.PMP_Account_Website__c != null){
                Attribute att = new Attribute();
                att.types=new List<Types>();
                att.name=System.Label.PMP_Website;
                att.isEditable=TRUE;    //Added by Subash for US685085
                Types type=new Types();
                type.id= company.PMP_Account_Website__c;
                type.name=company.PMP_Account_Website__c;
                type.link=company.PMP_Account_Website__c;
                
                att.types.add(type);
                partner.attributes.add(att);
            }
            if(company.PMP_Account_Address_Txt__c != null){
                Attribute att = new Attribute();
                att.name=System.Label.PMP_Address;
                att.isEditable=TRUE;    //Added by Subash for US686667
                att.textBlock=company.PMP_Account_Address_Txt__c;
                partner.attributes.add(att);
            }
        }
        return partner;
    }
 
    /** 
* @description : To get all the region and subregion related to Partner
* @developer : Nikhil
* @return : Attribute
* Method Parameters - Partner Id and isProductDetail
* Date : 25/Jul/2019
*/
    //IPA2.0:US-4497-1631_OfferingEOL
    public static Attribute getRegionAttribute(String partnerId, Boolean isProductDetail, String langCode/*, String offeringId*/){
        
        String userLang = langCode;
        if(langCode == 'en-US'){
            userLang = 'en_US';
        }else if(langCode == 'zh-Hans-CN' || langCode == 'zh-CN'){
            userLang = 'zh_CN';
        }

        try{
            Attribute att;
            String regPimId = PMP_StaticConstants_Partner.REGION_PIM_ID;
            PMP_Specification__c parent = new PMP_Specification__c();
            if(Schema.sObjectType.PMP_Specification__c.isAccessible()){ //ApexCRUDViolation Fix
            parent = [SELECT Id, Name, PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c,PMP_Partner_Product_Specification_Id__c FROM PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c =: regPimId AND PMP_Active_Ind__c = TRUE];
            }
            List<PMP_Company_Region__c> compRegionList = new List<PMP_Company_Region__c>();
            if(Schema.sObjectType.PMP_Company_Region__c.isAccessible() && Schema.sObjectType.PMP_Specification__c.isAccessible()){ //ApexCRUDViolation Fix
                compRegionList = [SELECT PMP_Company_Id__c,PMP_Specification_Id__c, PMP_Specification_Id__r.Name,   PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,
                                  PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c,PMP_Company_Id__r.PMP_Partner_Program_nm__c,
                                  PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c, 
                                  PMP_Specification_Id__r.PMP_Parent_Specification_Id__c,PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,PMP_Specification_Value__r.PMP_Specification_id__c,PMP_Specification_Value__r.PMP_Specification_Value_Chinese_Cd__c,
                                  PMP_Specification_Value__r.PMP_Specification_Value_Japanese_Cd__c,PMP_Specification_Value__c,PMP_Specification_Value__r.Name, PMP_Specification_Value__r.PMP_Specification_Product_Cd__c
                                  FROM PMP_Company_Region__c WHERE PMP_Company_Id__c =:partnerId 
                                  AND (PMP_Specification_Id__r.PMP_Active_Ind__c = true OR PMP_Specification_Value__r.PMP_Active_Ind__c = true) ORDER BY PMP_Specification_Value__r.Name,PMP_Specification_Id__r.Name];
            }
            if (!compRegionList.isEmpty()){         //if company region is present populate Geographical Regional Coverage attribute
                att = new Attribute();
                att.name=PMP_SearchUtilityController.getLocalisedName(parent, '', langCode);                
				att.title = att.name;
                String ppId, pp = compRegionList[0].PMP_Company_Id__r.PMP_Partner_Program_nm__c;
                Map<String, String> ppNameAndppId = new Map<String, String>();
                for(PMP_Partner_Program__c ppgm : [SELECT Id, Name FROM PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE AND PMP_Partner_Role_Parent_Id__c = NULL]) {
                    String ppName = ppgm.Name.toLowerCase();
                    String key = ppName.contains('manufacturer') ? 'manufacturer' : (ppName.contains('solution') ? 'solution' : (ppName.contains('fpga') ? 'fpga' : 'distributor'));
                    ppNameAndppId.put(key, ppgm.Id);
                }
                                
                if(String.isNotBlank(pp)) {
                    pp = pp.toLowerCase();
                    /*Logic added for OEM Partner Role Regional Coverage Redirection */
                    List<String> ppArr = pp.split(';');
                    Boolean mftFlag = false;
                    if(ppArr.size() > 0){
                        for(integer i=0;i<ppArr.size();i++){
                            if(ppArr[i].equals('manufacturer')){
                               mftFlag = true; 
                            }
                        }
                    }
                    ppId = (pp.contains('manufacturer') && mftFlag) ? ppNameAndppId.get('manufacturer') : (pp.contains('solution') || pp.contains('provider') || pp.contains('software') || (pp.contains('manufacturer') && !mftFlag) ? ppNameAndppId.get('solution') : (pp.contains('fpga') ? ppNameAndppId.get('fpga') : ppNameAndppId.get('solution')));
                }  
                if(String.isBlank(ppId)) ppId = ppNameAndppId.get('solution');
                
                if(!isProductDetail){
                    att.isEditable = true;
                    att.editButton = new EditButton();
                    att.editButton.currentStep = 2;
                }
                att.typeGroupings = new List<TypeGroup>();
                
                att.sections = new List<Sections>();
                Map<String, Sections> mapspecIdToSections = new Map<String, Sections>();
                Map<String, SectionValues> mapIdToSectionVal = new Map<String, SectionValues>();
                att.displayInModal = true;
                att.displaySectionsInModal = true;
                
                Map<String,TypeGroup> regTypeMap = new Map<String,TypeGroup>();
                
                //List<String> regIdList = new List<String>();
                Map<string,string> pimIdSpecIdMap = New Map<string,string>();

                for (PMP_Company_Region__c reg:compRegionList)
                {
                    if(reg.PMP_Specification_Id__c !=NULL){
                       pimIdSpecIdMap.put(reg.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c, reg.PMP_Specification_Id__r.PMP_Parent_Specification_Id__c);
                    }
                    
                    if(!regTypeMap.containsKey(reg.PMP_Specification_Id__c) && reg.PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c == regPimId){
                        TypeGroup typeGroup = new TypeGroup();
                        typeGroup.name = PMP_SearchUtilityController.getLocalisedName(reg, '', langCode);
                        typeGroup.types = new List<Types>();
                        
                        att.typeGroupings.add(typeGroup);
                        
						
                        regTypeMap.put(reg.PMP_Specification_Id__c,typeGroup);
                        
                        Sections section = new Sections();
                        section.label = PMP_SearchUtilityController.getLocalisedName(reg, '', langCode);
                        section.modalButtonLabel = System.Label.PMP_View_Countries_Regions;
                        section.modalTitleLabel = section.label;
                        section.values = new List<SectionValues>();
                        att.sections.add(section);
                        mapspecIdToSections.put(reg.PMP_Specification_Id__c,section);

                    }
                }
                for (PMP_Company_Region__c reg:compRegionList)
                {
                    if(regTypeMap.containsKey(reg.PMP_Specification_Id__r.PMP_Parent_Specification_Id__c) && !regTypeMap.containsKey(reg.PMP_Specification_Id__c)){
                        Types type = new Types();
                        type.name = PMP_SearchUtilityController.getLocalisedName(reg, '', langCode);
                        type.Id = reg.PMP_Specification_Id__c;
                        SearchParams params = new SearchParams();
                        params.selectedFilters = new Map<String,List<String>>();
                        params.type = 'partner';    
                        params.cat =  reg.PMP_Specification_Id__c;   //Added by Kartik
                        params.objectApiName = 'PMP_Partner_Program__c';
                        params.recordId = ppId;
                        //params.recordId = (!isProductDetail && partnerPrograms.size() > 0) ? partnerPrograms[0].Id : (isProductDetail && category.size() > 0 ? category[0].Id : NULL) ;
                        List<String> filterList = new List<String>();
                        filterList.add(reg.PMP_Specification_Id__c);
                        
                        params.selectedFilters.put(parent.Id, filterList);
                        type.searchParams=params;   
                        regTypeMap.get(reg.PMP_Specification_Id__r.PMP_Parent_Specification_Id__c).types.add(type);
                        regTypeMap.put(reg.PMP_Specification_Id__c,null);   //Adding id of subreg to avoide duplicate values
                        
                        SectionValues sectionValue = new SectionValues();
                        sectionValue.label = PMP_SearchUtilityController.getLocalisedName(reg, '', langCode);
                        sectionValue.subsection = '';
                        mapspecIdToSections.get(reg.PMP_Specification_Id__r.PMP_Parent_Specification_Id__c).values.add(sectionValue);
                        mapIdToSectionVal.put(reg.PMP_Specification_Id__c,sectionValue);
                    }
                    
                    if (reg.PMP_Specification_Value__c!=Null  && pimIdSpecIdMap.containsKey(reg.PMP_Specification_Value__r.PMP_Specification_Product_Cd__c) && regTypeMap.containsKey(pimIdSpecIdMap.get(reg.PMP_Specification_Value__r.PMP_Specification_Product_Cd__c))){
                        Types type = new Types();
                        type.name = reg.PMP_Specification_Value__r.Name;
                        type.name= userLang == 'en_US' ? reg.PMP_Specification_Value__r.Name : userLang=='zh_CN' ? reg.PMP_Specification_Value__r.PMP_Specification_Value_Chinese_Cd__c : reg.PMP_Specification_Value__r.PMP_Specification_Value_Japanese_Cd__c;
                        type.Id = reg.PMP_Specification_Value__c;
                        SearchParams params = new SearchParams();
                        params.selectedFilters = new Map<String,List<String>>();
                        params.type = 'partner';    
                        params.cat =  reg.PMP_Specification_Value__c;   //Added by Kartik
                        params.objectApiName = 'PMP_Partner_Program__c';
                        params.recordId = ppId;
                        //params.recordId = (!isProductDetail && partnerPrograms.size() > 0) ? partnerPrograms[0].Id : (isProductDetail && category.size() > 0 ? category[0].Id : NULL) ;
                        List<String> filterList = new List<String>();
                        filterList.add(reg.PMP_Specification_Value__c);
                        
                        params.selectedFilters.put(parent.Id, filterList);
                        type.searchParams=params;   
                        regTypeMap.get(pimIdSpecIdMap.get(reg.PMP_Specification_Value__r.PMP_Specification_Product_Cd__c)).types.add(type);
                        
                        if(mapIdToSectionVal.containskey(reg.PMP_Specification_Value__r.PMP_Specification_id__c)){
                            String subSec = mapIdToSectionVal.get(reg.PMP_Specification_Value__r.PMP_Specification_id__c).subsection;
                            mapIdToSectionVal.get(reg.PMP_Specification_Value__r.PMP_Specification_id__c).subsection = !String.isBlank(subSec) ? subSec + ', ' + reg.PMP_Specification_Value__r.Name : reg.PMP_Specification_Value__r.Name;
                        }
                    }
                }
				
				
            }
            return att;
        }catch(Exception e){
            throw new AuraHandledException('Error while fetching region attribute for Partner Card : '+ e.getMessage()+ '' + e.getLineNumber());
        }
    }
    
    /** 
* @description : To get all the Industry & Sub-Industry & Application related to Partner
* @developer : Prabuddh
* @return : Attribute
* Method Parameters - Partner Id, isProductDetail, pimId
* Date : 30/Jul/2019
*/
    public static Attribute getCategoryAttribute(String partnerId, Boolean isProductDetail, String pimId, String langCode){
        String finalPimId = pimId + '%';
        Attribute att = null;
        List<PMP_Partner_Category__c> companyCategoryList = new List<PMP_Partner_Category__c>(); 
        
        PMP_Category__c parent = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:pimId LIMIT 1];
            
        try{
            //if(Schema.sObjectType.PMP_Partner_Category__c.isAccessible()){
            companyCategoryList = [SELECT PMP_Category_Id__c, PMP_Partner_Id__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Parent_Category_Id__c,
                                   PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.Name, PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,
                                   PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c FROM PMP_Partner_Category__c WHERE
                                   PMP_Partner_Id__c =:partnerId AND PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c like :finalPimId
                                   AND PMP_Category_Id__r.PMP_Active_Ind__c =true ORDER BY PMP_Category_Id__r.Name];
            //}
            if(!companyCategoryList.isEmpty()){
                att = new Attribute();
                //changed by Nikhil to get name from pim
                att.name= PMP_SearchUtilityController.getLocalisedName(parent, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                att.title = att.name;
                att.modalButtonLabel = parent.Name == 'Industry' ? System.Label.PMP_View_Industries : ( parent.Name == 'Use Cases' ? System.Label.PMP_View_Use_Cases : '');
                att.modalTitleLabel = parent.Name == 'Industry' ? System.Label.PMP_Industries : ( parent.Name == 'Use Cases' ? att.name : '');
                att.displayInModal = true;
                att.displaySectionsInModal = false;
                if(!isProductDetail){
                    att.isEditable = true;
                    att.editButton = new EditButton();
                    att.editButton.currentStep = 2; //TODO : set step according to IND or APP
                }               
                att.typeGroupings = new List<TypeGroup>();
                att.sections = new List<Sections>();
                Map<String,TypeGroup> catTypeMap = new Map<String,TypeGroup>();
                Map<String,Sections> catSecMap = new Map<String,Sections>();
                
                for(PMP_Partner_Category__c cat: companyCategoryList){
                    if(!catTypeMap.containsKey(cat.PMP_Category_Id__c) && cat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c == pimId){
                        TypeGroup typeGroup = new TypeGroup();
                        typeGroup.name = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                        typeGroup.types = new List<Types>();
                        att.typeGroupings.add(typeGroup);
                        catTypeMap.put(cat.PMP_Category_Id__c,typeGroup);
                        
                        Sections indsutryOrAppSection = new Sections();
                        indsutryOrAppSection.label = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                        indsutryOrAppSection.values = new List<SectionValues>();
                        att.sections.add(indsutryOrAppSection);
                        catSecMap.put(cat.PMP_Category_Id__c, indsutryOrAppSection);
                    }
                }
                
                for(PMP_Partner_Category__c cat: companyCategoryList){
                    if(!catTypeMap.containsKey(cat.PMP_Category_Id__c) && catTypeMap.containsKey(cat.PMP_Category_Id__r.PMP_Parent_Category_Id__c)){
                        Types type = new Types();
                        type.name = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                        type.Id = cat.PMP_Category_Id__c;
                        
                        //Code to show hyperlink
                        SearchParams params = new SearchParams();
                        params.type = 'partner';
                        params.cat = cat.PMP_Category_Id__c;
                        params.contextualCat = true;
                        params.selectedFilters = new Map<String,List<String>>();
                        List<String> filterList = new List<String>();
                        filterList.add(cat.PMP_Category_Id__c);
                        
                        params.selectedFilters.put(parent.Id, filterList);
                        type.searchParams=params;
                        
                        //Changes end
                        SectionValues secVal = new SectionValues();
                        secVal.isLink = false;
                        secVal.label = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                        catSecMap.get(cat.PMP_Category_Id__r.PMP_Parent_Category_Id__c).values.add(secVal);
                        catTypeMap.get(cat.PMP_Category_Id__r.PMP_Parent_Category_Id__c).types.add(type);
                        catTypeMap.put(cat.PMP_Category_Id__c, null);
                    }
                }
            }
            
        }catch(Exception e){
            throw new AuraHandledException('Error while fetching Industry/Application attribute for Partner Card : '+ e.getMessage()+ '' + e.getLineNumber());
        }
        return att;   
    }
    
/** 
* @description : To get country values related to Disti Partner
* @developer :Manjula
* @return : Attribute
* Method Parameters - Partner Id, isProductDetail, pimId
* Date : 25/Jul/2019
*/
    
     public static Attribute getCountryAttribute(String partnerId, Boolean isProductDetail, String langCode){
        Attribute att = new Attribute();
		 //Modified as a part of OPID Restructure : Removing PMP_Account_Id__c from Query
        PMP_Company__c cmp = [SELECT Id,PMP_Disti_Country_Coverage_Txt__c FROM PMP_Company__c WHERE id =:partnerId];
       //Existing Query:
       // PMP_Company__c cmp = [SELECT Id, PMP_Account_Id__c,PMP_Disti_Country_Coverage_Txt__c FROM PMP_Company__c WHERE id =:partnerId];
        
        if(String.isNotBlank(cmp.PMP_Disti_Country_Coverage_Txt__c)){
             
            att.name = System.Label.PMP_Country_Coverage;//'Country Coverage';
            att.typeGroupings = new List<TypeGroup>();
            TypeGroup typeGroup = new TypeGroup();
            typeGroup.name = cmp.PMP_Disti_Country_Coverage_Txt__c.replaceAll(';', ' | ');
            typeGroup.types = new List<Types>();
            att.typeGroupings.add(typeGroup);
        }
        
        
        return att;
    }    
}