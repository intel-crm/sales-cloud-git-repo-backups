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
    public static Partner getPartnerDetails(Id partnerId, PMP_Company__c companyInfo, Boolean isProductDetail, String langCode){
        
        List<PMP_Company_Resource__c> partner_resource = new List<PMP_Company_Resource__c>();
         Map<String, String> partnerContentMap = new Map<String,String>();//Added by Manasa - for content Asset implementation
        List<String> partnerConDocIds = new List<String>();//ContentDocumentId list
        List<String> partner_progs = new List<String>();//company program list
        List<String> partner_tiers  = new List<String>();//company program membership list
        Map<String,String> programNameByValue = new Map<String,String>();//metadata map
        Partner partner=new Partner();//Instance of partner wrapper from PMP_SearchWrapperStore
        PMP_Company__c company;
        
        if(partnerId != null){				//fetching company record for the given partnerId if not null
            if(companyInfo == null){		//if received company info is null then query company info by partnerID
                if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                    company=[SELECT Id, Name, PMP_Account_Id__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c, PMP_Account_Dsc__c,PMP_Account_Address_Txt__c
                             ,PMP_Account_Industry__c, PMP_Account_Application__c
                             , PMP_Account_Region__c,PMP_Account_Website__c,
                             PMP_Account_Program_Membership__c, PMP_Account_Specialty__c, toLabel(PMP_Company_Lead_Gen_Language_Nm__c)
                             FROM PMP_Company__c where id=:partnerId LIMIT 1];
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
            if(partnerConAssetUrl.containsKey(partnerContentMap.get(company.Id))){//Added by Manasa  - for content Asset implementation
                    //partner.imageUrl = partnerConDistIds[0].ContentDownloadUrl;// base-url/file-assets/developerName
                    String assetName = partnerConAssetUrl.get(partnerContentMap.get(company.Id)); //Added by Manasa  - for content Asset implementation
                    partner.imageUrl = System.Label.PMP_CommunityURLSuffix+'file-asset/'+assetName+'?isOptimized=false'; //Added by Manasa  - for content Asset implementation
                
                }
                else{//else populate imageUrl with static image Url //Modified by Nikhil on 28-Nov-2019 to move default image logic to content asset
                    partner.imageUrl = PMP_StaticConstants_Partner.staticPartnerUrl;
                }
            //set the attributes(i.e Programs and Speciality) for the partner
            partner.attributes=new List<Attribute>();
            Attribute programs = new Attribute();
            programs.name=System.Label.PMP_Program_Membership;
            programs.types=new List<Types>();
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
                    /*if company membership contains '-' populate Program membership attribute as :
for 'ITP - Gold' membership 'Program Membership' attribute should be 'Intel® Technology Provider Program - GOLD'*/
                    if(partner_tiers[i].contains('-')){
                        type.id = programNameByValue.get(partner_tiers[i].split('-')[0].replace(' ','')) + ' - ' + partner_tiers[i].split('-')[1].replace(' ','').capitalize();
                        type.name = programNameByValue.get(partner_tiers[i].split('-')[0].replace(' ','')) + ' - ' + partner_tiers[i].split('-')[1].replace(' ','').capitalize();  
                    	programs.types.add(type);
                    }else{
                        type.id = programNameByValue.get(partner_tiers[i]);
                        type.name = programNameByValue.get(partner_tiers[i]);
                        programs.types.add(type);
                    }
                    
                }
                
           }
            
           Map<String,String> valueLabelMap = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();      
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                valueLabelMap.put(pickListVal.getValue(),pickListVal.getLabel());
            }
            
            //Created by Kartik
            Map<String,String> valueIdMap = new Map<String,String>();
            Map<String,String> idValueMap = new Map<String,String>();
            //Schema.DescribeFieldResult fieldOutput = PMP_Company__c.PMP_Account_Specialty__c.getDescribe(); 
            List<PMP_Partner_Specialty__c> specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE];
            for(PMP_Partner_Specialty__c specData: specialtyList){
                valueIdMap.put(specData.Name, specData.Id); 
                idValueMap.put(specData.Id, specData.Name);
            }
            
            
            
            //Adding ODM-LOEM Specialty as Partner Program
           if(String.isNotEmpty(company.PMP_Account_Specialty__c)  && company.PMP_Account_Specialty__c.contains(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program)){
                
                Types odm = new Types();
                odm.id = valueIdMap.get(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program);
                odm.name = System.Label.PMP_Partner_Directory_title3;
                programs.types.add(odm);
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
                        params.specialty = valueIdMap.get(spec);
                        specType.searchParams=params;
                        
                        att.types.add(spectype);
                    }
                }
                if(!att.types.isEmpty()){
                    partner.attributes.add(att);//add attribute to partner attribute list
                }
                
            }
            
            //Logic Updated By Nikhil
            Attribute regAtt = getRegionAttribute(partnerId, isProductDetail, langCode);
            if(regAtt != null)
                partner.attributes.add(regAtt);
            
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
    public static Attribute getRegionAttribute(String partnerId, Boolean isProductDetail, String langCode){
        
        
        try{
            Attribute att;
            String regPimId = PMP_StaticConstants_Partner.REGION_PIM_ID;
            
            PMP_Specification__c parent = [SELECT Id, Name, PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c,PMP_Partner_Product_Specification_Id__c FROM PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c =: regPimId AND PMP_Active_Ind__c = TRUE];
            
            List<PMP_Company_Region__c> compRegionList = new List<PMP_Company_Region__c>();
            //if(Schema.sObjectType.PMP_Company_Region__c.isAccessible() && Schema.sObjectType.PMP_Specification__c.isAccessible()){
                compRegionList = [SELECT PMP_Company_Id__c,PMP_Specification_Id__c, PMP_Specification_Id__r.Name,	PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,
                                  PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c,
                                  PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c, 
                                  PMP_Specification_Id__r.PMP_Parent_Specification_Id__c
                                  FROM PMP_Company_Region__c WHERE PMP_Company_Id__c =:partnerId 
                                  AND PMP_Specification_Id__r.PMP_Active_Ind__c = true ORDER BY PMP_Specification_Id__r.Name];
            //}
            if (!compRegionList.isEmpty()){			//if company region is present populate Geographical Regional Coverage attribute
                att = new Attribute();
                att.name=PMP_SearchUtilityController.getLocalisedName(parent, '', langCode);
                
                if(!isProductDetail){
                    att.isEditable = true;
                    att.editButton = new EditButton();
                    att.editButton.currentStep = 2;
                }
                att.typeGroupings = new List<TypeGroup>();
                
                Map<String,TypeGroup> regTypeMap = new Map<String,TypeGroup>();
                
                List<String> regIdList = new List<String>();
                for (PMP_Company_Region__c reg:compRegionList)
                {
                    if(!regTypeMap.containsKey(reg.PMP_Specification_Id__c) && reg.PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c == regPimId){
                        TypeGroup typeGroup = new TypeGroup();
                        typeGroup.name = PMP_SearchUtilityController.getLocalisedName(reg, '', langCode);
                        typeGroup.types = new List<Types>();
                        
                        att.typeGroupings.add(typeGroup);
                        
                        
                        regTypeMap.put(reg.PMP_Specification_Id__c,typeGroup);
                    } 
                }
                for (PMP_Company_Region__c reg:compRegionList)
                {
                    if(regTypeMap.containsKey(reg.PMP_Specification_Id__r.PMP_Parent_Specification_Id__c) && !regTypeMap.containsKey(reg.PMP_Specification_Id__c)){
                        Types type = new Types();
                        type.name = PMP_SearchUtilityController.getLocalisedName(reg, '', langCode);
                        type.Id = reg.PMP_Specification_Id__c;
                        System.debug('Specifictaion Id'+reg.PMP_Specification_Id__c);
                        SearchParams params = new SearchParams();
                        params.selectedFilters = new Map<String,List<String>>();
                        params.type = 'partner';    
                        params.cat =  reg.PMP_Specification_Id__c;   //Added by Kartik
                        List<String> filterList = new List<String>();
                        filterList.add(reg.PMP_Specification_Id__c);
                        
                        params.selectedFilters.put(parent.Id, filterList);
                        type.searchParams=params;	
                        
                        regTypeMap.get(reg.PMP_Specification_Id__r.PMP_Parent_Specification_Id__c).types.add(type);
                        regTypeMap.put(reg.PMP_Specification_Id__c,null);   //Adding id of subreg to avoide duplicate values
                    } 
                }
                
                
            }
            return att;
        }catch(Exception e){
            system.debug('Error while fetching region attribute for Partner Card : '+ e.getMessage()+ '' + e.getLineNumber());
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
                
                if(!isProductDetail){
                    att.isEditable = true;
                    att.editButton = new EditButton();
                    att.editButton.currentStep = 2; //TODO : set step according to IND or APP
                }               
                att.typeGroupings = new List<TypeGroup>();
                
                Map<String,TypeGroup> catTypeMap = new Map<String,TypeGroup>();
                
                
                for(PMP_Partner_Category__c cat: companyCategoryList){
                    if(!catTypeMap.containsKey(cat.PMP_Category_Id__c) && cat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c == pimId){
                        TypeGroup typeGroup = new TypeGroup();
                        typeGroup.name = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                        typeGroup.types = new List<Types>();
                        att.typeGroupings.add(typeGroup);
                        catTypeMap.put(cat.PMP_Category_Id__c,typeGroup);
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
                        catTypeMap.get(cat.PMP_Category_Id__r.PMP_Parent_Category_Id__c).types.add(type);
                        catTypeMap.put(cat.PMP_Category_Id__c, null);
                    }
                }
            }
            
        }catch(Exception e){
            system.debug('Error while fetching Industry/Application attribute for Partner Card : '+ e.getMessage()+ '' + e.getLineNumber());
            throw new AuraHandledException('Error while fetching Industry/Application attribute for Partner Card : '+ e.getMessage()+ '' + e.getLineNumber());
        }
        return att;  
    }
}