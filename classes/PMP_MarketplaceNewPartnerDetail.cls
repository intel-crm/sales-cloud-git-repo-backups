public with sharing class PMP_MarketplaceNewPartnerDetail extends PMP_SearchWrapperStore{
    @AuraEnabled(cacheable=true)
    public static PartnerDetail getPartnerDetails(String partnerId, String langCode){
        PartnerDetail partnerDetail=new PartnerDetail();
        PMP_Company__c company = new PMP_Company__c();
        
        //To get company information
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
            company=[SELECT Id, Name,PMP_Is_Working_Copy_Ind__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c, PMP_Account_Dsc__c, PMP_Account_Address_Txt__c,
                     PMP_Account_Industry__c, PMP_Account_Application__c,PMP_Account_Region__c, PMP_Account_Program_Membership__c,PMP_Company_Lifecycle_Status_Nm__c, 
                     PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c, PMP_Account_Specialty__c,PMP_Account_Website__c,
                     PMP_Account_Tag_Line__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,
                     PMP_Working_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Working_Copy_Id__r.PMP_Is_Updated_Ind__c,
                     PMP_Working_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Published_Copy_Id__c,
                     PMP_Published_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Published_Copy_Id__r.PMP_Is_Updated_Ind__c,
                     PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Published_Ind__c,PMP_IPA_Badge_Tier_Txt__c,
                     PMP_Published_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c,
                     toLabel(PMP_Disti_Components_Nm__c),toLabel(PMP_Disti_Sys_Solutions_Nm__c),PMP_Is_Distributor_Ind__c,PMP_Company_Status_Published_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c
                     FROM PMP_Company__c where id=:partnerId LIMIT 1];
        }
        if(company.PMP_Is_Working_Copy_Ind__c == true){
            try{
                if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                    company=[SELECT Id, Name,PMP_Marketing_Profile_Id__c,PMP_Partner_Program_nm__c, PMP_Account_Dsc__c, PMP_Account_Address_Txt__c,PMP_Company_Lifecycle_Status_Nm__c,
                             PMP_Account_Industry__c, PMP_Account_Application__c,PMP_Account_Region__c, PMP_Account_Program_Membership__c, 
                             PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c, PMP_Account_Specialty__c,PMP_Account_Website__c,
                             PMP_Account_Tag_Line__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,
                             PMP_Working_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Working_Copy_Id__r.PMP_Is_Updated_Ind__c,
                             PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Published_Ind__c, PMP_IPA_Badge_Tier_Txt__c,
                             PMP_Working_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c,
                             toLabel(PMP_Disti_Components_Nm__c),toLabel(PMP_Disti_Sys_Solutions_Nm__c),PMP_Is_Distributor_Ind__c,PMP_Published_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c,PMP_Company_Status_Published_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c
                             FROM PMP_Company__c where PMP_Working_Copy_Id__c =: partnerId LIMIT 1];
                }
                partnerId = company.Id;
            }catch(Exception e){
                //system.debug('error while fetching company records' + e);
            }
        }
        
        partnerDetail.id=partnerId;
        partnerDetail.name=company.Name;
        partnerDetail.leadSettings = PMP_SearchCompanyLeadGenController.getExistingSettings(partnerId);
        partnerDetail.leadLangPreference = PMP_SearchUtilityController.getLanguageMessage(partnerDetail.leadSettings.languagePreference);
        partnerDetail.isGuest = PMP_SearchUtilityController.isGuest();
        partnerDetail.isContactPartnerVisible = PMP_SearchUtilityController.isContactButtonVisible(company);
        partnerDetail.website = ( company.PMP_Account_Website__c != '' ?  company.PMP_Account_Website__c : ' ');
        partnerDetail.tierStatus = ( company.PMP_IPA_Badge_Tier_Txt__c != NULL ?  company.PMP_IPA_Badge_Tier_Txt__c.toLowercase() : ' ');
        partnerDetail.isDistributor = company.PMP_Is_Distributor_Ind__c;
        
        //To get Company Tagline and Description with translation
        String userLanguage =  langCode;
        String description = '';
        String tagline = '';
        List<PMP_Company_Translation__c> transList = new List<PMP_Company_Translation__c>();
        String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
        try{
            if(Schema.sObjectType.PMP_Company_Translation__c.isAccessible()){
                transList = [select id, Name, PMP_Field_Nm__c, PMP_English_Txt__c,
                             PMP_Chinese_Txt__c, PMP_Japanese_Txt__c from PMP_Company_Translation__c 
                             where PMP_Company_Information_Id__c = :partnerId AND PMP_Field_Nm__c != :streamIdName];
            }            
        }catch(Exception e){ 
            //System.debug('Error in fetching records of Company Translation :'+ e);
        }
        for(PMP_Company_Translation__c trans: transList)
        {
            String temp = '';
            if ((userLanguage == PMP_StaticConstants_Partner.ZH_CN || userLanguage == PMP_StaticConstants_Partner.ZH_HANS_CN_NEW) && trans.PMP_Chinese_Txt__c != null){
                temp = trans.PMP_Chinese_Txt__c;
            }
            else if (userLanguage == PMP_StaticConstants_Partner.JA && trans.PMP_Japanese_Txt__c != null){
                temp = trans.PMP_Japanese_Txt__c;
            }
            else if (trans.PMP_English_Txt__c != null){
                temp = trans.PMP_English_Txt__c;
            }
            if (trans.PMP_Field_Nm__c == 'PMP_Account_Dsc__c')
            {
                description = temp;
            }
            else if (trans.PMP_Field_Nm__c == 'PMP_Account_Tag_Line__c')
            {
                tagline = temp;
            }
        }
        if(tagline != null){
            partnerDetail.tagline = tagline.unescapeHtml4().stripHtmlTags(); 
        }
        if(description != null){   
            partnerDetail.partnerDescription= description.unescapeHtml4().stripHtmlTags();
            //To get short description
            String shortDescription = '';
            String fullDesc = description.unescapeHtml4().stripHtmlTags();
            Integer charLimit = Integer.valueOf(System.Label.PMP_Dsc_Char_Limit);
            if(fullDesc.length() > charLimit){
                Integer length = fulldesc.substring(0,charLimit).lastIndexOf(' ');
                if(length > 0) {
                    shortDescription = fulldesc.substring(0,length)+ '...';
                } else {
                    shortDescription = '...';
                }
            } else {
                shortDescription = description.unescapeHtml4().stripHtmlTags();
            }
            partnerDetail.partnerShortDescription = shortDescription;
        }
        
        //To get company attributes
        //IPA2.0:US-4497-1631_OfferingEOL
        //Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(NULL, company.Id, company, false, langCode);
        Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(company.Id, company, false, langCode);
        
        //To get Distributor Role
        //Set<String> distributorRole = new Set<String>();
        List<Attribute> newAttribute = new List<Attribute>();
        List<Specialties> distributorRoleList = new List<Specialties>();
        Map<String, Attribute> existingAttribute = new Map<String, Attribute>();
        
        Set<String> ppNames = new Set<String>();
        Map<String, List<String>> membershipMapList = new Map<String, List<String>>();
        String programMembership = company.PMP_Account_Program_Membership__c;
        
        if(String.isNotBlank(programMembership)) {
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
            
            
            Map<String, PMP_Partner_Tier__c> bizOrgType = new Map<String, PMP_Partner_Tier__c>();
            
            
            List<PMP_Partner_Tier__c> partnerTiers = new List<PMP_Partner_Tier__c>();
            if(Schema.sObjectType.PMP_Partner_Tier__c.isAccessible()){
                partnerTiers = [SELECT Id,Name,PMP_Is_Biz_Org_Type_Ind__c,PMP_Partner_Tier_Chinese_Nm__c,PMP_Partner_Tier_Name_Japanese__c FROM PMP_Partner_Tier__c where Name != null];
            }
            
            for(PMP_Partner_Tier__c tier : partnerTiers) {
                if(tier.PMP_Is_Biz_Org_Type_Ind__c) {
                    bizOrgType.put(tier.Name, tier);
                }                    
            }
            List<PMP_Partner_Program__c> partnerPrograms = [SELECT Id, Name, PMP_Partner_Role_Parent_Id__c,PMP_Partner_Program_Value_Txt__c,PMP_Partner_Program_Name_Chinese__c, 
                                                            PMP_Partner_Program_Name_Japanese__c FROM PMP_Partner_Program__c WHERE Name IN :ppNames AND PMP_Is_Active_Ind__c=TRUE];
            //List<String> tierValue = new List<String>{'Member', 'Gold', 'Titanium'};
                Set<String> chineseLangCodes = new Set<String> { 'zh_Hans_CN','zh-Hans-CN', 'zh-CN', 'zh_CN' };
                    String fieldName = chineseLangCodes.contains(langCode) ? 'PMP_Partner_Tier_Chinese_Nm__c' : (langCode == 'ja' ? 'PMP_Partner_Tier_Name_Japanese__c' : 'Name');
                        
                        if(ppNames.size() > 0) {
                            for(PMP_Partner_Program__c pp : partnerPrograms) {
                                for(String tier: membershipMapList.get(pp.Name.toLowerCase())){
                                    PMP_Partner_Tier__c bizType = bizOrgType.get(tier);
                                    String pname = PMP_SearchUtilityController.getLocalisedName(pp, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                                    /*if(bizType != null || (pp.Name == PMP_StaticConstants_Partner.SOLUTION_PROVIDER && !tierValue.contains(tier))){
                                        String bizVal;
                                        if(bizType != null){
                                            bizVal = bizType.get(fieldName) != NULL ? (String)bizType.get(fieldName) : NULL;
                                        }else{
                                            bizVal = tier;
                                        }
                                        Specialties spec= new Specialties();
                                        spec.name =  pname + ' - ' + bizVal;
                                        distributorRoleList.add(spec);
                                    }
                                    else{
                                        Specialties spec= new Specialties();
                                        spec.name =  pname;
                                        distributorRoleList.add(spec);
                                    }*/
                                    //Added as part of new UI requirement to show only disti roles --starts Here
                                    String bizVal;
                                    if(bizType != null){
                                        bizVal = bizType.get(fieldName) != NULL ? (String)bizType.get(fieldName) : NULL;
                                        Specialties spec= new Specialties();
                                        spec.name =  pname + ' - ' + bizVal;
                                        distributorRoleList.add(spec);
                                    }
                                    // --Ends Here
                                }
                            }
                        }
        }
        
        if(partner.attributes != null && !partner.attributes.isEmpty()){
            for(Attribute oldAttribute : partner.attributes){
                if(oldAttribute != null){
                    existingAttribute.put(oldAttribute.name, oldAttribute);
                }
            }
            
            /*if(existingAttribute != null){
                for(String attkey : existingAttribute.keySet()){
                    if(attkey == System.Label.PMP_Partner_Role) {
                        if(existingAttribute.get(attkey).types.size() > 0){
                            for(Types distributor : existingAttribute.get(attkey).types){
                                Specialties spec= new Specialties();
                                spec.name = distributor.name;
                                distributorRoleList.add(spec);
                            }
                        }
                    }
                }
            }*/
        }
        
        
        //To get Regional Coverage label
        String regPimId = PMP_StaticConstants_Partner.REGION_PIM_ID;
        String Regional_Coverage = '';
        String Industry = '';
        String Application = '';
        List<PMP_Specification__c> parent = new List<PMP_Specification__c>();
        if(Schema.sObjectType.PMP_Specification__c.isAccessible()){ 
            parent = [SELECT Id, Name, PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c,PMP_Partner_Product_Specification_Id__c FROM PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c =: regPimId AND PMP_Active_Ind__c = TRUE];
        }
        if(parent.size()>0){
            Regional_Coverage = PMP_SearchUtilityController.getLocalisedName(parent[0], '', langCode); 
        }
        
        //To get Industry Label
        List<PMP_Category__c> parentIndustry = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_INDUSTRY_ID];
        if(parentIndustry.size()>0){
            Industry = PMP_SearchUtilityController.getLocalisedName(parentIndustry[0], PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
        }
        
        //To get Application Label
        List<PMP_Category__c> parentApplication = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_APPLICATION_ID];
        if(parentApplication.size()>0){
            Application = PMP_SearchUtilityController.getLocalisedName(parentApplication[0], PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
        }
        
        //To remove attributes except Address, Regional Coverage, Industry & Application
        if(!existingAttribute.isEmpty()){
            List<String> removeItems = new List<String>();
            for(String attkey : existingAttribute.keySet()){
                if(attkey != System.Label.PMP_Address && attkey != Regional_Coverage &&
                   attkey != System.Label.PMP_Country_Coverage && attkey != System.Label.PMP_Distribution_Products &&
                   attkey != Industry && attkey != Application){
                    removeItems.add(attkey);
                }
            }
            
            for(String attkey : existingAttribute.keySet()){
                if(removeItems.contains(attkey)){
                    existingAttribute.remove(attkey);
                }
                /*if(attkey == System.Label.PMP_Country_Coverage){
                    if(existingAttribute.get(attkey).typeGroupings.size() > 0){
                        String strArrwithoutLine = '';
                        for(TypeGroup groupVal : existingAttribute.get(attkey).typeGroupings){
                            if(groupVal.name.contains(' | ')){
                                String[] strArrwithLine = groupVal.name.split('\\|');
                                List<Types> newGroup = new List<Types>();
                                for(integer i =0;i< strArrwithLine.size();i++){
                                    if(strArrwithLine[i].length() > 1){
                                        Types countryType = new Types();
                                        countryType.name = strArrwithLine[i];
                                        newGroup.add(countryType);
                                        
                                    }
                                    existingAttribute.get(attkey).typeGroupings[0].name = '';
                                    existingAttribute.get(attkey).typeGroupings[0].types = newGroup;
                                }
                            }
                        }
                    }
                }*/
                if(attkey == System.Label.PMP_Country_Coverage && existingAttribute.get(attkey).typeGroupings.size() > 0){
                    //if(existingAttribute.get(attkey).typeGroupings.size() > 0){
                        Attribute oldCountryCovAtt = existingAttribute.get(attkey);
                        Attribute countryCovAtt = new Attribute();
                        countryCovAtt.title = System.Label.PMP_Country_Coverage;
                        countryCovAtt.modalButtonLabel = System.Label.PMP_View_Countries_Regions;
                        countryCovAtt.modalTitleLabel = System.Label.PMP_View_Countries_Regions;
                        countryCovAtt.displayInModal = true;
                        countryCovAtt.displaySectionsInModal = false;
                        countryCovAtt.sections = new List<Sections>();
                        Sections countryCovSection = new Sections();
                        countryCovSection.label = '';
                        countryCovSection.values = new List<SectionValues>();
                        countryCovAtt.sections.add(countryCovSection);
                        existingAttribute.put(attkey, countryCovAtt);
                        //String strArrwithoutLine = '';

                        for(TypeGroup groupVal : oldCountryCovAtt.typeGroupings){
                            List<SectionValues> secValList = new List<SectionValues>();
                            if(groupVal.name.contains(' | ')){
                                String[] strArrwithLine = groupVal.name.split('\\|');
                                for(integer i =0;i< strArrwithLine.size();i++){
                                    if(strArrwithLine[i].length() > 1){
                                        SectionValues secVal = new SectionValues();
                                        secVal.isLink = false;
                                        secVal.label = strArrwithLine[i];
                                        secValList.add(secVal);
                                    }
                                    existingAttribute.get(attkey).sections[0].values = secValList;
                                }
                            }else{
                                SectionValues secVal = new SectionValues();
                                secVal.isLink = false;
                                secVal.label = groupVal.name;
                                secValList.add(secVal);
                                existingAttribute.get(attkey).sections[0].values = secValList;
                            }
                        }
                    //}
                }
                if(attkey == System.Label.PMP_Address){
                    Attribute oldAddressAtt = existingAttribute.get(attkey);
                    Attribute addressAtt = new Attribute();
                    addressAtt.title = System.Label.PMP_Address;
                    List<Sections> sectionsList = new List<Sections>();
                    Sections section = new Sections();
                    section.label = '';
                    List<SectionValues> sectionValuesList = new List<SectionValues>();
                    if(!String.isBlank(oldAddressAtt.textBlock) && oldAddressAtt.textBlock.contains('<br>')){
                        String[] strArrwithBreak = oldAddressAtt.textBlock.split('<br>');
                        for(integer i =0;i< strArrwithBreak.size();i++){
                            SectionValues sectionValue = new SectionValues();
                            sectionValue.isLink = false;
                            sectionValue.label = strArrwithBreak[i] ;
                            sectionValuesList.add(sectionValue);
                        }
                    }
                    section.values = sectionValuesList;
                    sectionsList.add(section);
                    addressAtt.sections = sectionsList;
                    addressAtt.displayInModal = false;
                    addressAtt.displaySectionsInModal = false;
                    existingAttribute.put(attkey, addressAtt);
                }
            }
            newAttribute = existingAttribute.values();
            //To move Address to first position and add other attributes
            string var = System.Label.PMP_Address;
            integer index; 
            for(integer i =0;i< newAttribute.size();i++){
                if(var==newAttribute[i].title) index=i;
            }
            if(index != null){
                list<Attribute> tempLst = newAttribute.clone();
                newAttribute.clear(); 
                
                newAttribute.add(tempLst[index]);
                tempLst.remove(index); 
                newAttribute.addAll(tempLst); 
            } 
            partner.attributes = newAttribute;
        }
        
        partner.contactByEmail = false;
        partner.contactByForm = true;
        partnerDetail.partnerDetails= partner;
        
        //To get Specialty Grey Image and Name
        List<Specialties> specialtyAndRoleList = new List<Specialties>();
        Map<String, List<Specialties>> partnerSpecialties = getpartnerSpecialtyforCards(new String[]{partnerId}, langCode);
        if(!partnerSpecialties.isEmpty()) {
            specialtyAndRoleList.addAll(partnerSpecialties.get(partnerId));
        }
        if(!distributorRoleList.isEmpty()) {
            specialtyAndRoleList.addAll(distributorRoleList);
        }
        partnerDetail.specialties = specialtyAndRoleList;
        
        //To get Company Resources
        partnerDetail.companyResources=new List<PartnerResource>();
        List<PMP_Company_Resource__c> resourceList = new List<PMP_Company_Resource__c>();
        if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()){
            resourceList = [SELECT id,Name, PMP_Company_Resource_Type_Nm__c, PMP_Company_Resource_URL_txt__c from PMP_Company_Resource__c where PMP_Company_Id__c=:partnerId and PMP_Company_Resource_Type_Nm__c!='Image' and PMP_Company_Resource_Type_Nm__c!='Thumbnail Image'];
        }
        
        for(PMP_Company_Resource__c resource : resourceList){
            PartnerResource res= new PartnerResource();
            res.title= resource.Name;
            res.type =resource.PMP_Company_Resource_Type_Nm__c;
            res.linkUrl = resource.PMP_Company_Resource_URL_txt__c;
            partnerDetail.companyResources.add(res);
        }
        return partnerDetail;
    }
    
    public static Map<String, List<Specialties>> getpartnerSpecialtyforCards(List<String> partnerIds, string langCode){
        Map<String, List<Specialties>>  response= new Map<String, List<Specialties>> ();
        List<PMP_Partner_Specialty__c> specialtyList = [SELECT Id,Name,PMP_Partner_Specialty_Chinese_Nm__c, PMP_Partner_Specialty_Japanese_Nm__c,PMP_Partner_Specialty_English_Dsc__c,PMP_Partner_Specialty_Chinese_Dsc__c,PMP_Partner_Specialty_Japanese_Dsc__c, PMP_Is_Active_Ind__c FROM PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE order by Name];
        String specialtyName = PMP_SearchUtilityController.getFieldApiName('PMP_Partner_Specialty__c', 'Name',langCode);
        if(String.isEmpty(specialtyName)){
            specialtyName = 'Name';
        }
        Map<string, string> sMap= new Map<String,String>();
        for(PMP_Partner_Specialty__c sp:specialtyList)   {
            sMap.put(sp.Name, (String)sp.get(specialtyName));
        }
        
        Map<String,String> metadataMap = new Map<String,String>();
        List<PMP_Specialty_Images__mdt> metaDataList = [SELECT PMP_Account_Specialty_Name__c,PMP_Specialty_Name_Chinese__c,PMP_Specialty_Name_Japanese__c, Grey_Image_URL__c from PMP_Specialty_Images__mdt where PMP_Account_Specialty_Name__c != null];
        for(PMP_Specialty_Images__mdt md: metaDataList){
            String specTransName=md.PMP_Account_Specialty_Name__c;
            if(langCode=='ja'){
                specTransName=md.PMP_Specialty_Name_Japanese__c;
            } 
            else if(langCode=='zh-Hans-CN' || langCode=='zh_CN' || langCode=='zh_Hans_CN'){
                specTransName=md.PMP_Specialty_Name_Chinese__c;
            }
            metadataMap.put(specTransName, md.Grey_Image_URL__c);
        }
        
        Map<String,List<String>> partnerSpecMap=new Map<String,List<String>>();
        List<PMP_Company__c> partners = [select toLabel(PMP_Account_Specialty__c) from PMP_Company__c where Id IN:partnerIds and PMP_Account_Specialty__c!=null];
        for(PMP_Company__C c: partners){
            List<String> specList=new List<String>();
            specList.addAll(c.PMP_Account_Specialty__c.split(';'));
            partnerSpecMap.put(c.id,specList);
        } 
        
        if(!partnerSpecMap.isEmpty()) {
            for(String s: partnerSpecMap.keySet()){
                for(String specVal:partnerSpecMap.get(s)){
                    Specialties spec= new Specialties();
                    if(sMap.containsKey(specVal))
                        spec.name=sMap.get(specVal);
                    else 
                        spec.name=specVal;
                    spec.image=metadataMap.get(specVal);
                    if(response.containsKey(s)){
                        List<Specialties> speclist=response.get(s);
                        speclist.add(spec);
                        response.put(s,speclist);
                    }
                    else{
                        response.put(s,new List<Specialties> {spec});
                    }
                }
            }
        }
        return response;
    }
}