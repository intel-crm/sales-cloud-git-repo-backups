/****************************************************************************************************************************************
* Class Name  : PMP_SearchPartnerController   
* Version     : 1.0 
* Created Date: 07-May-2019
* Modification Log :
* Created By : Tanzanite Team Infosys
* * Developer                 Date         Description
* ----------------------------------------------------------------------------
* Nikhil          29/06/2019               Update getPartnerList method to use new Company Translation object
*****************************************************************************************************************************************/

public with sharing class PMP_SearchPartnerController extends PMP_SearchWrapperStore {
    
    //Method to get partner Ids based on searched keyword 
    @AuraEnabled(cacheable=true) 
    public static List<Id> getPartnerList(String keyword){
        
        keyword = PMP_SearchUtilityController.escapeSosl(keyword);
        
        Set<Id> partnersIdsFound = New Set<Id>(); 
        List<id> partnerIds=new List<id>();
        
        String userLangCode = '';
        
        
        if(UserInfo.getLanguage() != null){
            userLangCode = UserInfo.getLanguage();
        }
        
        if (String.isNotEmpty(keyword))
        {   
            List<List<SObject>> pubTransList= new List<List<SObject>>(); 
            try{
                
                //SOSL to find partner in all fields which are published.
                pubTransList = [FIND :keyword IN ALL FIELDS RETURNING PMP_Company_Translation__c(PMP_Company_Information_Id__c
                                                                                                  WHERE PMP_Company_Information_Id__r.PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published)];
            
            
            }catch(Exception e){
                System.debug('Error occured while searching the keyword in traslation object :'+ e);
                
            }
            for (List<SObject> listObj : pubTransList)
            {
                for(SObject obj : listObj)
                {
                    if(obj.getSObjectType() == PMP_Company_Translation__c.sObjectType)
                    {
                        PMP_Company_Translation__c trans = (PMP_Company_Translation__c) obj; 
                        partnersIdsFound.add(trans.PMP_Company_Information_Id__c);
                        
                    }
                }
            }
        }
        else{
            List<PMP_Company__c> pubCompList = new List<PMP_Company__c>();
            try{
                if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                    pubCompList = [SELECT Id FROM PMP_Company__c 
                                    WHERE PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published LIMIT 30000];
                } 
            }catch(Exception e){
                System.debug('Error occured while searching the keyword in traslation object :'+ e);
                
            }
            for(PMP_Company__c comp :pubCompList)
            {   
                partnersIdsFound.add(comp.Id);
            }
        }
        
        partnerIds.addAll(partnersIdsFound);
        
        return partnerIds;
    }
    /**********************************************************************************************/
    
    
    //Method to get partner Ids based on searched keyword for Result landing page
    // The text based search bar in result landing page will show the options based just on the Name match for Partners
   
    @AuraEnabled(cacheable=true) 
    public static List<Id> SerachPartnersByName(String keyword){
        
        keyword = PMP_SearchUtilityController.escapeSosl(keyword);
        
        Set<Id> partnersIdsFound = New Set<Id>(); 
        List<id> partnerIds=new List<id>();
        
        String userLangCode = '';
        
        
        if(UserInfo.getLanguage() != null){
            userLangCode = UserInfo.getLanguage();
        }
        
        if (String.isNotEmpty(keyword))
        {   
            List<List<SObject>> pubTransList= new List<List<SObject>>(); 
            try{
                //SOSL to find partner in name field which are published.
                pubTransList = [FIND :keyword IN NAME FIELDS RETURNING PMP_Company_Translation__c(PMP_Company_Information_Id__c
                                                                                                  WHERE PMP_Company_Information_Id__r.PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published)];
            
            
            }catch(Exception e){
                System.debug('Error occured while searching the keyword in traslation object :'+ e);
                
            }
            for (List<SObject> listObj : pubTransList)
            {
                for(SObject obj : listObj)
                {
                    if(obj.getSObjectType() == PMP_Company_Translation__c.sObjectType)
                    {
                        PMP_Company_Translation__c trans = (PMP_Company_Translation__c) obj; 
                        partnersIdsFound.add(trans.PMP_Company_Information_Id__c);
                        
                    }
                }
            }
        }
       
        
        partnerIds.addAll(partnersIdsFound);
        
        return partnerIds;
    }
    /**********************************************************************************************/
    
    //Method to fetch partners based on the Region selected//
    @AuraEnabled(cacheable=true)
    public static List<Id> getRegionResults(List<String> optionList){
        
        List<Id> partnerIds=new List<Id>();
        try{
            List<PMP_Company_Region__c> partnerRegionList= new List<PMP_Company_Region__c>();
            if (!optionList.isEmpty()){ 
                if(Schema.sObjectType.PMP_Company_Region__c.isAccessible()){
                    partnerRegionList = [select PMP_Company_Id__c from PMP_Company_Region__c  where PMP_Specification_Id__c IN :optionList];
                }
                for(PMP_Company_Region__c partner : partnerRegionList)
                {
                    partnerIds.add(partner.PMP_Company_Id__c);   
                }
            }
        }catch(Exception e){
            System.debug(e.getMessage()+' '+e.getLineNumber()+' '+e.getCause());
            throw new AuraHandledException(e.getMessage()+' '+e.getLineNumber()+' '+e.getCause());
        }
        return partnerIds;
    }
    
    
    /****************************************************/
    
    //Method to fetch partners based on the Specialty selected//
    @AuraEnabled(cacheable=true)
    public static List<Id> getSpecialtyResults(List<String> optionList){
        List<Id> partnerIds=new List<Id>();   
        List<PMP_Company__c> partnerList;
        List<Id> result = new List<Id>();   //retainAll will not work with null list.
        
        //Map to fetch the specialty value for a metadata record id
        Map<String,Id> idValueMap = new Map<String,Id>();
        List<PMP_Partner_Specialty__c> specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c where id in:optionList AND PMP_Is_Active_Ind__c = TRUE];
        optionList = new List<String>();
        for(PMP_Partner_Specialty__c specData: specialtyList){
            optionList.add(specData.Name); 
        }
        
        if (!optionList.isEmpty()){
            String query =  'SELECT id FROM PMP_Company__c WHERE PMP_Account_Specialty__c INCLUDES (';
            
            for(String option :optionList){
                if(optionList.indexOf(option) == optionList.size()-1){
                    query += '\'' + String.escapeSingleQuotes(option.replace('_',' ')) + '\'';
                }else{
                    query += '\'' + String.escapeSingleQuotes(option.replace('_',' ')) + '\''+ ',';
                }
                
                
            }
            query += ')';
            
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                partnerList = Database.query(query);
            }
            
            for(PMP_Company__c partner : partnerList){
                partnerIds.add(partner.Id);   
            }
            result = partnerIds;
        }
        return result;
    }
    
    /******************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<Id> getPartnerProgramResults(String option){
        List<Id> offIds=new List<Id>();
        List<Id> partnerIds = new List<Id>();
        List<Id> result = null;
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        System.debug('option'+option);
        //option = '234825394t34';
         //   option = metada.value;
         
          List<PMP_SearchPartnerProgram_Config__mdt> partnerPrograms = new List<PMP_SearchPartnerProgram_Config__mdt>();
          List<PMP_Partner_Program__c> seoPpList = [SELECT id, PMP_Is_Active_Ind__c,	PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c where id=:option AND PMP_Is_Active_Ind__c=TRUE];
                                         									
          option = seoPpList[0].PMP_Partner_Program_Value_Txt__c; 		
          
        try{
            partnerList = [ select id from PMP_Company__c where (PMP_Partner_Program_nm__c INCLUDES (:option) OR PMP_Account_Specialty__c INCLUDES (:option.replace('_', ' ')))];
            System.debug('partnerList'+partnerList);
        }catch(Exception e){
            System.debug('Error in fetching Company Information records :'+ e);
        }
        
        for( PMP_Company__c partner : partnerList )
        {
            partnerIds.add(partner.Id);
        }
        result = partnerIds;
        return result;
        
    }
    
    /**************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<Id> partnerQuickSearchResults(Map<String,List<String>> selectedFilters,String searchType, List<Id> partnerFound){
        
        List<Id> partnerIds = partnerFound;
        List<Id> result = new List<Id>();
        Set<Id> mergeSet = new Set<Id>();
        
        PMP_Category__c industry = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_INDUSTRY_ID LIMIT 1];
        PMP_Category__c application = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_APPLICATION_ID LIMIT 1];
        PMP_Specification__c region = [SELECT Id,Name,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c FROM PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c =: PMP_StaticConstants_Partner.REGION_PIM_ID LIMIT 1];
        
        mergeSet.addAll(partnerIds);
        system.debug('---------'+partnerIds.size());
        if(selectedFilters.get('Partner Program_Partner')!=null && selectedFilters.get('Partner Program_Partner').size()>0){
            partnerIds = getPartnerProgramResults(selectedFilters.get('Partner Program_Partner')[0]);                 
            mergeSet.retainAll(partnerIds);    
        }
        if(selectedFilters.containsKey(industry.Id) && !selectedFilters.get(industry.Id).isEmpty()){
            partnerIds = getPartnerCategoryResults(PMP_StaticConstants_Partner.PIM_INDUSTRY_ID ,selectedFilters.get(industry.Id));                    
            mergeSet.retainAll(partnerIds);    
        }   
        if(selectedFilters.containsKey(application.Id) && !selectedFilters.get(application.Id).isEmpty()){
            partnerIds = getPartnerCategoryResults(PMP_StaticConstants_Partner.PIM_APPLICATION_ID ,selectedFilters.get(application.Id));                  
            mergeSet.retainAll(partnerIds);    
        }   
        if(selectedFilters.containsKey(region.Id) && !selectedFilters.get(region.Id).isEmpty()){
            partnerIds = getRegionResults(selectedFilters.get(region.Id));                    
            mergeSet.retainAll(partnerIds);    
        }
        
        if(selectedFilters.containsKey('Specialty_Partner') && !selectedFilters.get('Specialty_Partner').isEmpty()){
            partnerIds = getSpecialtyResults(selectedFilters.get('Specialty_Partner'));                  
            mergeSet.retainAll(partnerIds);    
        }
        
         if(selectedFilters.containsKey('Marketplace_Event') && !selectedFilters.get('Marketplace_Event').isEmpty()){
            partnerIds = PMP_SearchEventDetailController.getEventPartners(selectedFilters.get('Marketplace_Event'),partnerIds);                  
            mergeSet.retainAll(partnerIds);    
        }
        
        result.addAll(mergeSet); 
        
        
        
        return result;
    }
    
    /************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<Partner> getPartners(List<Id> partners, Integer currentPage, Integer pageSize, String sortField, String langCode){
        
        List<PMP_Company_Translation__c> transList = [SELECT PMP_Company_Information_Id__c, PMP_Field_Nm__c,
                                                      PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Company_Translation__c
                                                      WHERE PMP_Company_Information_Id__c in :partners];
        
        List<Partner> partnerResults = new List<Partner>();
        
        List<Id> partIds= partners;
        
        //Sorting Logic
        String sortBy;
        if (sortField == PMP_StaticConstants_Partner.SortFieldPartnerDescending)
        {
            sortBy = PMP_StaticConstants_Partner.SortByDescending;
        }
        else 
        {
            sortBy = PMP_StaticConstants_Partner.SortByAscending;
        }
        //Logic End
        
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        
        //Logic to fetch sorted partners
        String ptnrList = 'select Id,Name,PMP_Account_Id__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c,PMP_Account_Industry__c,PMP_Account_Application__c,PMP_Account_Specialty__c,PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c,toLabel(PMP_Company_Lead_Gen_Language_Nm__c) from PMP_Company__c where id in :partIds ORDER BY ';
        String finalPartnerList = String.escapeSingleQuotes(ptnrList + sortBy);
        Integer offset = (currentPage-1)*pageSize;
        system.debug('offset' + offset);
        
        //Pagination Logic
        if(offset > 2000){                  //since max offset limit is 2000 only
            Integer rangeFirst = pageSize * (currentPage - 1) ;
            Integer rangeLast = Math.min(pageSize * currentPage, partners.size()) ;
            //Fetch all the sorted partners first
            List<PMP_Company__c> allPartners = Database.query(String.escapeSingleQuotes(finalPartnerList));
            
            //Pagination Logic
            for (Integer i = rangeFirst; i < rangeLast ; i++)
            {
                partnerList.add(allPartners.get(i));
            }
        }else{
            finalPartnerList+=' LIMIT 9 OFFSET ' + offset;
            
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                partnerList = Database.query(finalPartnerList);
            }
        }
        //Logic END
        
        
        
        List<PMP_Company__c> partnerPaginatedList = new List<PMP_Company__c>();
        List<Id> paginatedIds = new List<Id>();
        
        for (PMP_Company__c comp : partnerList)
        {
            partnerPaginatedList.add(comp);
            paginatedIds.add(comp.Id);
            
        }
        
        //Logic End
        
        List<PMP_SearchPartnerProgram_Config__mdt> partnerPrograms = new List<PMP_SearchPartnerProgram_Config__mdt>();
        
        if(Schema.sObjectType.PMP_SearchPartnerProgram_Config__mdt.isAccessible()){
            partnerPrograms = [SELECT Label, PMP_Partner_Program_Name__c, PMP_Partner_Program_value__c,
                               PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c
                               from PMP_SearchPartnerProgram_Config__mdt];
        }
        String userLanguage = langCode;
        String partnerProgApi = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Name', userLanguage);
        if(String.isEmpty(partnerProgApi)){
            partnerProgApi = 'PMP_Partner_Program_Name__c';
        }
     Map<String, String> ppMap = new Map<String, String>();
       //Map<Id, String> ppMap = new Map<Id, String>();
        for(PMP_SearchPartnerProgram_Config__mdt pmdt: partnerPrograms){
            if(String.isEmpty((String)pmdt.get(partnerProgApi))){
                ppMap.put(pmdt.PMP_Partner_Program_value__c, pmdt.PMP_Partner_Program_Name__c);
            }else{
                ppMap.put(pmdt.PMP_Partner_Program_value__c, (String)pmdt.get(partnerProgApi));
            }
        }
        
        //Partner Image Implemetation
        Map<String, String> partnerContentMap = new Map<String,String>();
        Map<String, String> partnerResMap = new Map<String,String>();
        List<PMP_Company_Resource__c> partnerResource = new List<PMP_Company_Resource__c>();
        List<String> partnerConDocList = new List<String>();
        
            partnerResource = [SELECT PMP_Company_Id__c, PMP_Company_Image__c from PMP_Company_Resource__c 
                               WHERE PMP_Company_Id__c in : paginatedIds and PMP_Company_Resource_Type_Nm__c =: PMP_StaticConstants_Partner.THUMBNAIL_IMAGE and PMP_Company_Image__c!=null and PMP_Company_Resource_Sequence_Nbr__c = 0]; // Uday:changed resource type to Thumbnail
        
        
        if(!partnerResource.isEmpty()){
            for(PMP_Company_Resource__c res: partnerResource){
                partnerContentMap.put(res.PMP_Company_Id__c,res.PMP_Company_Image__c);
            }
        }
    
        partnerConDocList.addAll(partnerContentMap.values());
        
        //List<ContentDistribution> partnerConDistList = PMP_SearchOfferingImageUtility.getContentDistList(partnerConDocList);
        Map<String,String> partnerConAssetUrl = PMP_SearchOfferingImageUtility.getContentAssetUrlMap(partnerConDocList);
        
       /* if(!partnerConDistList.isEmpty()){
            for(ContentDistribution cd : partnerConDistList){
                partnerResMap.put(partnerContentMap.get(cd.ContentDocumentId), cd.ContentDownloadUrl);
            }
        } */
        
        //Partner Image Implemetation ends
        
        //Partner Card Attributes - Program Membership,Industry,Application

        
        Map<String, Boolean> contactVisMap = new Map<String,Boolean>();
        
        contactVisMap = PMP_SearchUtilityController.isContactPartnerVisible(partnerPaginatedList);
        system.debug('---------paginatedIds' + paginatedIds);
        
        Map<String,List<Attribute>> partnerAttMap=PMP_SearchAttributeController.getPartnerAttributes(paginatedIds, langCode);
        
        //Logic to get Partner Description from translation
        Map<String,PMP_Company_Translation__c> ptnrDescMap = new Map<String,PMP_Company_Translation__c>(); 
     
        List<PMP_Company_Translation__c> ptnrTransList = [SELECT PMP_Field_Nm__c, PMP_Company_Information_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Company_Translation__c 
                                                                  WHERE (PMP_Field_Nm__c = :PMP_StaticConstants_Partner.Description) AND PMP_Company_Information_Id__c IN :paginatedIds];
        for(PMP_Company_Translation__c trans: ptnrTransList){
            ptnrDescMap.put(trans.PMP_Company_Information_Id__c,trans);
        }
        //Changes End
        
        
        
        for(PMP_Company__c ptnr : partnerPaginatedList)
        {
            Partner partnerWrapper = new Partner();
            partnerWrapper.autoPartnerId = ptnr.PMP_Marketing_Profile_Id__c;
            partnerWrapper.id = ptnr.Id;
            //Changed default logo for Partner Card by NIKHIL 26-Nov-2019
            partnerWrapper.imageUrl =PMP_StaticConstants_Partner.staticPartnerUrl;
            
          /*  if (partnerResMap.containsKey(ptnr.Id)){            
                    partnerWrapper.imageUrl = partnerResMap.get(ptnr.id);          
            }   */
            
            if(partnerConAssetUrl.containsKey(partnerContentMap.get(ptnr.Id))){
                String assetName = partnerConAssetUrl.get(partnerContentMap.get(ptnr.Id));
                partnerWrapper.imageUrl = System.Label.PMP_CommunityURLSuffix+'file-asset/'+assetName+'?isOptimized=false';
            }
            
            partnerWrapper.isGuest = PMP_SearchUtilityController.isGuest();
            //partnerWrapper.description = ptnr.PMP_Account_Dsc__c;
            
            /*if(ptnrDescMap.containsKey(ptnr.Id)){
                partnerWrapper.description = PMP_SearchUtilityController.getLocalisedName(ptnrDescMap.get(ptnr.Id), '', langCode);
            }*/
            partnerWrapper.name = ptnr.Name;
            partnerWrapper.contactByEmail = false;
            partnerWrapper.contactByForm = true;
            
            //Adding Partner Card Attributes
            partnerWrapper.attributes = new Map<String, List<Types>>();
            
            //Program Membership
            List<Types> programs = new List<Types>();
            if(String.isNotEmpty(ptnr.PMP_Partner_Program_nm__c))
            {
                for(String s: ptnr.PMP_Partner_Program_nm__c.split(';'))
                {
                    if(ppMap.containsKey(s)){
                        Types type = new Types();
                        type.id = s;
                        type.name = ppMap.get(s);
                        programs.add(type); 
                    }
                    
                }
            }
            
            //Specialty
            Map<String,String> valueLabelMap = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();      
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                valueLabelMap.put(pickListVal.getValue(),pickListVal.getLabel());
            }
            
            //Added by Kartik
           /* Map<String,Id> valueIdMap = new Map<String,Id>();
            List<PMP_Specialty__mdt> special = [Select id, MasterLabel from PMP_Specialty__mdt];
            for(PMP_Specialty__mdt specData: special){
                valueIdMap.put(specData.MasterLabel, specData.Id); 
            }  */
            //Added by Kartik
            Map<String,Id> valueIdMap = new Map<String,Id>();
            List<PMP_Partner_Specialty__c> specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE];
            for(PMP_Partner_Specialty__c specData: specialtyList){
                valueIdMap.put(specData.Name, specData.Id); 
            } 

            List<Types> specialities = new List<Types>();
            if(String.isNotEmpty(ptnr.PMP_Account_Specialty__c)){
                for(String spec : ptnr.PMP_Account_Specialty__c.split(';')){
                    if(valueLabelMap.containsKey(spec)){
                        Types type = new Types();
                        //type.id = labelValueMap.get(spec).replace(' ','_');
                        type.id = valueIdMap.get(spec);  //Added by Kartik
                        type.name = valueLabelMap.get(spec);
                        
                        //Adding ODM-LOEM as partner program
                        if(spec == PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program){
                            programs.add(type); 
                        }else{
                            specialities.add(type);
                        }
                    }
                }  
            }
            
            //Industry and Application
            Map<String,List<Types>> tempMap = new Map<String,List<Types>>();
            if (partnerAttMap.containsKey(ptnr.Id))
            {	system.debug('inside ptnr loop : ' + ptnr.Id);
                for (Integer i = partnerAttMap.get(ptnr.id).size()-1; i >=0 ; i--)
                {
                    Attribute att = partnerAttMap.get(ptnr.id)[i];
                   
                    	tempMap.put(att.name, att.types);
                }
            }
            
            partnerWrapper.attributes = tempMap; 
            if(!specialities.isEmpty()){
                partnerWrapper.attributes.put(System.Label.PMP_Specialty, specialities );
            }
            if(!programs.isEmpty()){
                partnerWrapper.attributes.put(System.Label.PMP_Program_Membership, programs);
            }
            
            if(PMP_SearchUtilityController.isSysAdmin())
                partnerWrapper.isContactPartnerVisible = true;
            else
                partnerWrapper.isContactPartnerVisible = contactVisMap.get(ptnr.Id);
            
            
            List<Options> languagePrefs = new List<Options>();
            if(ptnr.PMP_Company_Lead_Gen_Language_Nm__c!=null){                       
                for(String prefLang : ptnr.PMP_Company_Lead_Gen_Language_Nm__c.split(';')){
                    Options option = new Options();
                    option.label = prefLang;
                    option.value = prefLang;
                    option.selected = true;
                    languagePrefs.add(option);
                }                                   
            }
            partnerWrapper.leadLangPreference = PMP_SearchUtilityController.getlanguageMessage(languagePrefs);  
            partnerResults.add(partnerWrapper);
            
        
        }
        
        
        system.debug('partnerResults'+partnerResults);
        return partnerResults;         
    }
    
    /*****************************************************************************/
    
    //Modified on 15-Aug-2019 By nikhil
    public static Map<String,Integer> getPartnerCount (List<Id> partnerFound){
        
        Map<String, Integer> partnerCountMap = new Map<String, Integer>();
        List<PMP_Company__c> partnerList = [SELECT PMP_Partner_Program_nm__c,PMP_Account_Specialty__c from PMP_Company__c where id in :partnerFound and (PMP_Partner_Program_nm__c != NULL OR PMP_Account_Specialty__c INCLUDES (:PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program))];
        
        List<String> countList = new List<String>();
        for(PMP_Company__c partner : partnerList){
            Set<String> temp = new Set<String>();
            if(String.isNotEmpty(partner.PMP_Partner_Program_nm__c)){
                temp.addAll(partner.PMP_Partner_Program_nm__c.split(';'));
            }
                
            //To get the Count of ODM-LOEM
            if(String.isNotEmpty(partner.PMP_Account_Specialty__c) && partner.PMP_Account_Specialty__c.contains(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program)){
                temp.add(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program);
                
                
                
                
            }
            countList.addAll(temp);
        }
        for(String pp : countList){
            if(partnerCountMap.containsKey(pp)){
                partnerCountMap.put(pp,partnerCountMap.get(pp)+1);
            }
            else{
                partnerCountMap.put(pp,1);
            }
        }
        return partnerCountMap;
    }
    
    /***************************************************************/
    
    //Modified on 15-Aug-2019 to search ODM_LOEM specialty by Nikhil
    public static List<Id> filterPartners(String catId,List<Id> partners){
        System.debug('catId'+catId);
        List<PMP_Partner_Program__c> odmLoem = [SELECT id, PMP_Is_Active_Ind__c,	PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c where PMP_Partner_Program_Value_Txt__c = 'ODM-LOEM' AND PMP_Is_Active_Ind__c=TRUE];
     
         List<PMP_Partner_Program__c> partnerPrograms = [SELECT id, PMP_Is_Active_Ind__c,	PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c where Id=:catId AND PMP_Is_Active_Ind__c=TRUE];
        
        System.debug('partnerPrograms'+partnerPrograms);
        if(partnerPrograms.size() > 0){
            if(catId!=odmLoem[0].Id){
                 catId = partnerPrograms[0].PMP_Partner_Program_Value_Txt__c;
            }else{
                catId = PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program.replace(' ','_');
            }
           
            
        }
        
        
        List<PMP_Company__c> partnerList = [SELECT id,Name from PMP_Company__c where id in :partners and (PMP_Partner_Program_nm__c includes (:catId) OR PMP_Account_Specialty__c INCLUDES ( :catId.replace('_',' ')))];
       
        System.debug('partnerList'+partnerList);
        List<Id> partnerIds = new List<Id>();
        for(PMP_Company__c partner : partnerList){
            partnerIds.add(partner.id);
        }
        
        return partnerIds;
    }
    
    /***********************************************************************************************/
    
    public static List<String> getPartnerCategoryResults(String pimId, List<String> options){
        try{
            List<String> partnerIds = new List<String>();
            String ansPimId = pimId+ '%';
            
            List<PMP_Partner_Category__c> partnerCatList = [SELECT PMP_Partner_Id__c FROM PMP_Partner_Category__c WHERE PMP_Category_Id__c IN :options 
                                                            AND PMP_Category_Id__r.PMP_Active_Ind__c = true 
                                                            AND  PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c like :ansPimId];
            for(PMP_Partner_Category__c partCat: partnerCatList){
                partnerIds.add(partCat.PMP_Partner_Id__c);
            }
            return partnerIds;
        }catch(Exception e){
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
        }
    }
    
    
    
    public class Partner {
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String imageUrl { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Boolean contactByEmail { get; set; }
        @AuraEnabled public Boolean contactByForm { get; set; }
        @AuraEnabled public Map<String, List<Types>> attributes { get; set; }
        @AuraEnabled public Boolean isContactPartnerVisible {get; set;}
        @AuraEnabled public String leadLangPreference {get; set;}
        @AuraEnabled public Boolean isGuest {get; set;}
        @AuraEnabled public String autoPartnerId {get; set;}
    }   
    
    
}