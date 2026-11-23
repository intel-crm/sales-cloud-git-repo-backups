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
    public static List<Id> getPartnerList(String keyword, List<String> partners){
        
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
                String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
                //SOSL to find partner in all fields which are published.
                pubTransList = [FIND :keyword IN ALL FIELDS RETURNING PMP_Company_Translation__c(PMP_Company_Information_Id__c
                                                                                                  WHERE PMP_Company_Information_Id__c IN :partners AND PMP_Company_Information_Id__r.PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published
                                                                                                 AND PMP_Company_Information_Id__r.PMP_Benefit_Update_Ind__c=False AND PMP_Field_Nm__c != :streamIdName)];
            
            }catch(Exception e){
                //System.debug('Error occured while searching the keyword in traslation object :'+ e);
                //throw e;//error handling
                
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
                                    WHERE Id IN :partners AND PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published
                                   AND PMP_Benefit_Update_Ind__c=False LIMIT 30000];
                } 
            }catch(Exception e){
                //System.debug('Error occured while searching the keyword in traslation object :'+ e);
               // throw e;//error handling
                
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
                String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
                //SOSL to find partner in name field which are published.
                pubTransList = [FIND :keyword IN NAME FIELDS RETURNING PMP_Company_Translation__c(PMP_Company_Information_Id__c
                                                                                                  WHERE PMP_Company_Information_Id__r.PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published AND PMP_Company_Information_Id__r.PMP_Benefit_Update_Ind__c=False
                                                                                                  AND PMP_Field_Nm__c != :streamIdName)];
            
            
            }catch(Exception e){
                //System.debug('Error occured while searching the keyword in traslation object :'+ e);
                
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
        // System.debug('partnerIds'+partnerIds);
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
                    partnerRegionList = [select PMP_Company_Id__c from PMP_Company_Region__c  where PMP_Specification_Id__c IN :optionList or PMP_Specification_Value__c IN:optionList];
                }
                for(PMP_Company_Region__c partner : partnerRegionList)
                {
                    partnerIds.add(partner.PMP_Company_Id__c);   
                }
            }
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+e.getLineNumber()+' '+e.getCause());
            throw new AuraHandledException(e.getMessage()+' '+e.getLineNumber()+' '+e.getCause());
            //throw e;error handling
        }
        return partnerIds;
    }
    
    
    /****************************************************/
    
    //Method to fetch partners based on the Specialty selected//
    @AuraEnabled(cacheable=true)
    public static List<Id> getSpecialtyResults(List<String> optionList){
        List<Id> partnerIds=new List<Id>();   
        //List<PMP_Company__c> partnerList;
        List<Id> result = new List<Id>();   //retainAll will not work with null list.
 
        //Map to fetch the specialty value for a metadata record id
        //Map<String,Id> idValueMap = new Map<String,Id>();
        List<PMP_Partner_Specialty__c> specialtyList = new List<PMP_Partner_Specialty__c>();
        if(Schema.sObjectType.PMP_Partner_Specialty__c.isAccessible()){
            specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c where id in:optionList AND PMP_Is_Active_Ind__c = TRUE ];//WITH SECURITY_ENFORCED
        }
        optionList = new List<String>();
        for(PMP_Partner_Specialty__c specData: specialtyList){
            optionList.add(specData.Name); 
        }
        // system.debug('OptionList : '+ optionList);
        if (!optionList.isEmpty()){
            
            String query =  'SELECT id FROM PMP_Company__c WHERE toLabel(PMP_Account_Specialty__c) INCLUDES (';
                        
            for(String option :optionList){
                if(optionList.indexOf(option) == optionList.size()-1){
                    query += '\'' + String.escapeSingleQuotes(option.replace('_',' ')) + '\'';
                }else{
                    query += '\'' + String.escapeSingleQuotes(option.replace('_',' ')) + '\''+ ',';
                }
            }
            query += ')';
            
            /*
            Set<String> tempSet = new Set<String>();
            for(String option :optionList){
                tempSet.add(option.replace('_',' '));
            }
            String query =  'SELECT id FROM PMP_Company__c WHERE PMP_Account_Specialty__c IN :tempSet';*/
            
            //---------- PMD SOQL INJECTION FIX Statrs ----------
            string strquery = query;
            List<sobject> sob = new List<sobject>(); 
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                //query = String.escapeSingleQuotes(query);
                
                sob = Database.query(strquery); 
                
            }
            if (sob.size() > 0){
            for(sObject sobj : sob){
                partnerIds.add(sobj.Id);   
            }
        }
           
            result = partnerIds;
        }
        return result;
    }
    
    /******************************************************/
    
    public static List<String> filterPartnerByRole(String roleId, List<String> partners){
        //List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        List<String> roleList = new List<String>();
        List<String> result = new List<String>();
        List<PMP_Partner_Program__c> seoRoleList = new List<PMP_Partner_Program__c>();
        if(Schema.sObjectType.PMP_Partner_Program__c.isAccessible()){
            seoRoleList = [SELECT id, PMP_Is_Active_Ind__c, PMP_Partner_Program_Value_Txt__c
                           from PMP_Partner_Program__c
                           where (id =:roleId OR PMP_Partner_Role_Parent_Id__c =:roleId) AND PMP_Is_Active_Ind__c=TRUE];//WITH SECURITY_ENFORCED
        }
        for(PMP_Partner_Program__c role : seoRoleList){
            roleList.add(role.PMP_Partner_Program_Value_Txt__c);
        }
        
        if(!roleList.isEmpty()){
            String query =  'SELECT id FROM PMP_Company__c WHERE PMP_Partner_Program_nm__c  INCLUDES (';
            
            for(String option :roleList){
                //Checking the indexof substring
                if(roleList.indexOf(option) == roleList.size()-1){
              
                    query += '\'' + String.escapeSingleQuotes(option) + '\'';
                }else{
                    query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
                }
     
            }
            query+=')';
            //---------- PMD SOQL INJECTION FIX Statrs ----------
            string strquery = query;
            List<sobject> partnerList = new List<sobject>(); 
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                partnerList = Database.query(strquery);            
            }
            if (partnerList.size() > 0){
            for(sObject sobj : partnerList){
                result.add(sobj.Id);   
            }
        }
         //----------PMD SOQL INJECTION FIX ENDS -------
         /*Start of code ---- before PMD SOQL INJECTION FIX  
         partnerList = Database.query(query);
            
            for(PMP_Company__c com : partnerList){
                result.add(com.Id);
            }
        End of Code ---- before PMD SOQL INJECTION FIX*/
        }
        
        
        
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Id> getPartnerProgramResults(String option){
        //List<Id> offIds=new List<Id>();
        List<Id> partnerIds = new List<Id>();
        List<Id> result = null;
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        // System.debug('option'+option);
        //option = '234825394t34';
         //   option = metada.value;
         
      //    List<PMP_SearchPartnerProgram_Config__mdt> partnerPrograms = new List<PMP_SearchPartnerProgram_Config__mdt>();
        List<PMP_Partner_Program__c> seoPpList = new List<PMP_Partner_Program__c>();
        if(Schema.sObjectType.PMP_Partner_Program__c.isAccessible()){
            seoPpList = [SELECT id, PMP_Is_Active_Ind__c,    PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c where id=:option AND PMP_Is_Active_Ind__c=TRUE ];// WITH SECURITY_ENFORCED
        }                                                  
          option = seoPpList[0].PMP_Partner_Program_Value_Txt__c;       
          
        try{
            partnerList = [ select id from PMP_Company__c where (PMP_Partner_Program_nm__c INCLUDES (:option) OR PMP_Account_Specialty__c INCLUDES (:option.replace('_', ' ')))];
            //System.debug('partnerList'+partnerList);
        }catch(Exception e){
            //System.debug('Error in fetching Company Information records :'+ e);
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
        PMP_Category__c industry = new PMP_Category__c();
        PMP_Category__c application = new PMP_Category__c();
        PMP_Specification__c region = new PMP_Specification__c();
        
        if(Schema.sObjectType.PMP_Category__c.isAccessible()){
            industry = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_INDUSTRY_ID LIMIT 1 ];// WITH SECURITY_ENFORCED
            application = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_APPLICATION_ID LIMIT 1];// WITH SECURITY_ENFORCED
        }
        if(Schema.sObjectType.PMP_Specification__c.isAccessible()){
            region = [SELECT Id,Name,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c FROM PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c =: PMP_StaticConstants_Partner.REGION_PIM_ID  LIMIT 1];//WITH SECURITY_ENFORCED
        }
        mergeSet.addAll(partnerIds);
        // system.debug('---------'+partnerIds.size());
        if(selectedFilters.get('Partner Program_Partner')!=null && selectedFilters.get('Partner Program_Partner').size()>0){
           // partnerIds = getPartnerProgramResults(selectedFilters.get('Partner Program_Partner')[0]);                 
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
        //IPA2.0:TWC729-8114 Topics Removal/Event Removal
        /*if(selectedFilters.containsKey('Marketplace_Event') && !selectedFilters.get('Marketplace_Event').isEmpty()){
            partnerIds = PMP_SearchEventDetailController.getEventPartners(selectedFilters.get('Marketplace_Event'),partnerIds);                  
            mergeSet.retainAll(partnerIds);    
        }*/
        
        result.addAll(mergeSet); 
        
        
        
        return result;
    }
    
    /************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<Partner> getPartners(List<Id> partners, Integer currentPage, Integer pageSize, String sortField, String langCode, String keyword, String partnerProgType, List<String> selectedBizOrgs){//PROD DEFECT FIX: added keyword parameter at the end, added partnerProgType for Disti Pagination fix
        //below query is commented as part of the story US853176
        /*List<PMP_Company_Translation__c> transList = new List<PMP_Company_Translation__c>();
        String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
        if(Schema.sObjectType.PMP_Company_Translation__c.isAccessible()){
            transList = [SELECT PMP_Company_Information_Id__c, PMP_Field_Nm__c,
                         PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Company_Translation__c
                         WHERE PMP_Company_Information_Id__c in :partners AND PMP_Field_Nm__c != :streamIdName];//WITH SECURITY_ENFORCED
        }*/
        List<Partner> partnerResults = new List<Partner>();
		// system.debug('partnerProgType'+partnerProgType);
        // System.debug('..partners ids in getpartners.'+partners);
        List<Id> partIds= partners;
        
        //Sorting Logic
        String sortBy;
        //New Logic for sorting - 2.0 changes
        if(sortField == PMP_StaticConstants_Partner.sortFieldTier){
            sortBy = PMP_StaticConstants_Partner.sortByTierPartner ;
        }else{
            sortBy = PMP_StaticConstants_Partner.sortByMostRecentPartner;
        }
        // System.debug('$$PsortBy-->'+sortBy);
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        //Logic to fetch sorted partners
        //String ptnrList = 'select Id,Name,PMP_Is_Distributor_Ind__c,PMP_Account_Id__c,PMP_Badge_Tier_Sequence_Nbr__c,PMP_Account_Id__r.Core_IPA_Badge_Tier__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c,PMP_Account_Industry__c,PMP_Account_Application__c,PMP_Account_Specialty__c,PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c,toLabel(PMP_Company_Lead_Gen_Language_Nm__c),PMP_IPA_Badge_Tier_Txt__c,PMP_Company_Status_Update_Dt__c,PMP_Account_Dsc__c,PMP_Account_Website__c,PMP_Disti_Sys_Solutions_Nm__c,PMP_Disti_Components_Nm__c,PMP_Disti_Country_Coverage_Txt__c,PMP_Account_Id__r.Core_Account_Type__c,PMP_Partner_Benefit_Type__c,PMP_Biz_Org_Type_Txt__c from PMP_Company__c where id in :partIds ORDER BY ';
        //Pagination fix: below ptnrList variable is modified
		//Modified as a part of OPID restructure : Removing PMP_Account_Id__c, PMP_Account_Id__r.Core_IPA_Badge_Tier__c from query																														  
        //String ptnrList = 'select Id,Name,PMP_Is_Distributor_Ind__c,PMP_Account_Id__c,PMP_Badge_Tier_Sequence_Nbr__c,PMP_Account_Id__r.Core_IPA_Badge_Tier__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c,PMP_Account_Industry__c,PMP_Account_Application__c,PMP_Account_Specialty__c,PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c,toLabel(PMP_Company_Lead_Gen_Language_Nm__c),PMP_IPA_Badge_Tier_Txt__c,PMP_Company_Status_Update_Dt__c,PMP_Account_Dsc__c,PMP_Account_Website__c,PMP_Disti_Sys_Solutions_Nm__c,PMP_Disti_Components_Nm__c,PMP_Disti_Country_Coverage_Txt__c,PMP_Account_Id__r.Core_Account_Type__c,PMP_Partner_Benefit_Type__c,PMP_Biz_Org_Type_Txt__c from PMP_Company__c ';
		String ptnrList = 'select Id,Name,PMP_Is_Distributor_Ind__c,PMP_Badge_Tier_Sequence_Nbr__c,PMP_Account_Id__r.Core_IPA_Badge_Tier__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c,PMP_Account_Industry__c,PMP_Account_Application__c,PMP_Account_Specialty__c,PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c,toLabel(PMP_Company_Lead_Gen_Language_Nm__c),PMP_IPA_Badge_Tier_Txt__c,PMP_Company_Status_Update_Dt__c,PMP_Account_Dsc__c,PMP_Account_Website__c,PMP_Disti_Sys_Solutions_Nm__c,PMP_Disti_Components_Nm__c,PMP_Disti_Country_Coverage_Txt__c,PMP_Account_Id__r.Core_Account_Type__c,PMP_Partner_Benefit_Type__c,PMP_Biz_Org_Type_Txt__c from PMP_Company__c ';																																																																																																																																																													   
       
        //String finalPartnerList= ptnrList+sortBy; //pagination fix: commented by priyanka
        String finalPartnerList= ptnrList;// pagination fix: modified by priyanka from 'ptnrList+ sortBy' to 'ptnrList'
        //System.Debug('ptnrList to check biz org type'+ptnrList);
        Integer offset = (currentPage-1)*pageSize;
        //system.debug('offset' + offset);
        List<String> finalPartnerIds= new List<String>(); //pagination fix: declared by priyanka
        
        //Pagination Logic
        if(offset > 2000){                  //since max offset limit is 2000 only
            Integer rangeFirst = pageSize * (currentPage - 1) ;
            Integer rangeLast = Math.min(pageSize * currentPage, partners.size()) ;
            //Fetch all the sorted partners first
            
            //pagination fix: below line is commented by priyanka
            //List<PMP_Company__c> allPartners = Database.query(String.escapeSingleQuotes(finalPartnerList)); //
           if(rangeFirst>rangeLast){
                rangeFirst = 0;
                if(partners.size()>=pageSize){
                    rangeLast = pageSize;
                }else{
                    rangeLast = partners.size();       
                }
            } 
            for (Integer i = rangeFirst; i < rangeLast ; i++)
            {
                //partnerList.add(allPartners.get(i));//pagination fix: commented by priyanka
                finalPartnerIds.add(partIds.get(i));//pagination fix: added by priyanka, to get the ids for the current page

            }
            //pagination fix: added by priyanka - start
            finalPartnerList=ptnrList+' WHERE id in :finalPartnerIds ORDER BY '+sortBy; //as sort by is already applied in the initial query, we will recieve the ids sorted , but still added the sort by here.
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                partnerList = Database.query(String.escapeSingleQuotes(finalPartnerList));

            }
            //pagination fix: added by priyanka - end
            
            }else{
                //IPA2.0:TWC729-8114 Topics Removal/Event Removal
                /*if(sortField=='event'){      
                    finalPartnerList+=' WHERE id in:partIds ORDER BY '+sortBy+' LIMIT 8 OFFSET ' + offset;
                }*/
				if ((keyword==null || partners.size()>=offset) && (partnerProgType == PMP_StaticConstants_Partner.distributor)){ // Disti No Pagination Fix : Added by Manjula
                    finalPartnerList+=' WHERE id in:partIds ORDER BY '+sortBy+' OFFSET ' + offset; 
                    
                }

                else if (keyword==null || partners.size()>=offset){ //PROD Defect fix : added the if condition here
                    //finalPartnerList+=' LIMIT 12 OFFSET ' + offset; // pagination fix: commented by priyanka
                    finalPartnerList+=' WHERE id in:partIds ORDER BY '+sortBy+' LIMIT 12 OFFSET ' + offset; // Pagination fix: added by priyanka

                }
                //PROD Defect fix - added the else block below
                else {
                    finalPartnerList+=' WHERE id in:partIds ORDER BY '+sortBy+' LIMIT 12 '; 
                }
            
            // system.debug('query is --------- ' + finalPartnerList);
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                String finalQuery=finalPartnerList;
                partnerList = Database.query(finalQuery);
            }
        }
        List<PMP_Company__c> partnerPaginatedList = new List<PMP_Company__c>();
        List<Id> paginatedIds = new List<Id>();
		//Commenting as a part of OPID restructure										  
        //Set<Id> accIds = new Set<Id>();
       // System.debug('..partnerList inside the getPartners()...'+partnerList);
        
        for (PMP_Company__c comp : partnerList)
        {
            partnerPaginatedList.add(comp);
            paginatedIds.add(comp.Id);
            //accIds.add(comp.PMP_Account_Id__c); //Commenting as a part of OPID restructure
        }
        Map<Id, Boolean> companyIdAndMemberFlag = formMemberFlagMap(new Set<Id>(paginatedIds));
    /*    List<PMP_SearchPartnerProgram_Config__mdt> partnerPrograms = new List<PMP_SearchPartnerProgram_Config__mdt>();
        
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
       for(PMP_SearchPartnerProgram_Config__mdt pmdt: partnerPrograms){
            if(String.isEmpty((String)pmdt.get(partnerProgApi))){
                ppMap.put(pmdt.PMP_Partner_Program_value__c, pmdt.PMP_Partner_Program_Name__c);
            }else{
                ppMap.put(pmdt.PMP_Partner_Program_value__c, (String)pmdt.get(partnerProgApi));
            }
        }*/
        
        //changing from PMP_SearchPartnerProgram_Config__mdt to PMP_Partner_Program__c
         List<PMP_Partner_Program__c> partnerPrograms = new List<PMP_Partner_Program__c>();
        
        if(Schema.sObjectType.PMP_Partner_Program__c.isAccessible()){
            partnerPrograms = [select id,Name, PMP_Is_Active_Ind__c, PMP_Partner_Program_Value_Txt__c, PMP_Partner_Program_Desc__c, 
                               PMP_Partner_Program_Desc_Chinese__c, PMP_Partner_Program_Desc_Japanese__c, 
                               PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=True ];
        }
       String userLanguage = langCode;           
       Map<String, String> ppMap = new Map<String, String>();
       for(PMP_Partner_Program__c pmdt: partnerPrograms){
           String label=PMP_SearchUtilityController.getLocalisedName(pmdt, PMP_StaticConstants_Partner.CAT_NAME_FIELD, userLanguage);        
           ppMap.put(pmdt.PMP_Partner_Program_Value_Txt__c, label);
        }
        
        //Partner Image Implemetation
        Map<String, String> partnerContentMap = new Map<String,String>();
        //Map<String, String> partnerResMap = new Map<String,String>();
        List<PMP_Company_Resource__c> partnerResource = new List<PMP_Company_Resource__c>();
        List<String> partnerConDocList = new List<String>();
        if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()){
            partnerResource = [SELECT PMP_Company_Id__c, PMP_Company_Image__c from PMP_Company_Resource__c 
                               WHERE PMP_Company_Id__c in : paginatedIds and (PMP_Company_Resource_Type_Nm__c =: PMP_StaticConstants_Partner.THUMBNAIL_IMAGE OR PMP_Company_Resource_Type_Nm__c=: PMP_StaticConstants_Partner.IMAGE)
                               and PMP_Company_Image__c!=null and PMP_Company_Resource_Sequence_Nbr__c = 0 ORDER BY PMP_Company_Resource_Type_Nm__c ASC]; // Uday:changed resource type to Thumbnail WITH SECURITY_ENFORCED
        }
        
        if(!partnerResource.isEmpty()){
            for(PMP_Company_Resource__c res: partnerResource){
                partnerContentMap.put(res.PMP_Company_Id__c,res.PMP_Company_Image__c);
            }
        }
       partnerConDocList.addAll(partnerContentMap.values());
       Map<String,String> partnerConAssetUrl = PMP_SearchOfferingImageUtility.getContentAssetUrlMap(partnerConDocList);
       /* if(!partnerConDistList.isEmpty()){
            for(ContentDistribution cd : partnerConDistList){
                partnerResMap.put(partnerContentMap.get(cd.ContentDocumentId), cd.ContentDownloadUrl);
            }
        } */
        
       //Partner Card Attributes - Program Membership,Industry,Application
       Map<String, Boolean> contactVisMap = new Map<String,Boolean>();
       contactVisMap = PMP_SearchUtilityController.isContactPartnerVisible(partnerPaginatedList);
        
       //Logic to get Partner Description from translation
       Map<String,PMP_Company_Translation__c> ptnrDescMap = new Map<String,PMP_Company_Translation__c>(); 
        List<PMP_Company_Translation__c> ptnrTransList = new List<PMP_Company_Translation__c>();
        if(Schema.sObjectType.PMP_Company_Translation__c.isAccessible()){
            ptnrTransList = [SELECT PMP_Field_Nm__c, PMP_Company_Information_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Company_Translation__c 
                             WHERE (PMP_Field_Nm__c = :PMP_StaticConstants_Partner.Description) AND PMP_Company_Information_Id__c IN :paginatedIds ];//WITH SECURITY_ENFORCED
            
        }
        for(PMP_Company_Translation__c trans: ptnrTransList){
            ptnrDescMap.put(trans.PMP_Company_Information_Id__c,trans);
        }
        //Changes End
        Map<String,Id> valueIdMap = new Map<String,Id>();
        List<PMP_Partner_Specialty__c> specialtyList = new List<PMP_Partner_Specialty__c>();
        if(Schema.sObjectType.PMP_Partner_Specialty__c.isAccessible()){
            specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE ];//WITH SECURITY_ENFORCED
        }
        for(PMP_Partner_Specialty__c specData: specialtyList){
            valueIdMap.put(specData.Name, specData.Id); 
        }
       
        //Event related partner eyebrows
        //IPA2.0:TWC729-8114 Topics Removal/Event Removal
        /*Map<String,String> eventpartnerId= new Map<String,String>();
        List<PMP_Marketplace_Event_Partner__c> partnerEvents = new List<PMP_Marketplace_Event_Partner__c>();
        if(Schema.sObjectType.PMP_Marketplace_Event_Partner__c.isAccessible()){
            partnerEvents =[select PMP_Company_Id__c,PMP_Event_Id__r.Name from PMP_Marketplace_Event_Partner__c 
                            WHERE PMP_Company_Id__c IN :partners AND  PMP_Event_Id__r.PMP_Marketplace_Event_Status__c =true ORDER BY PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c DESC];
        }
        for(PMP_Marketplace_Event_Partner__c events: partnerEvents){
            if(!eventpartnerId.containsKey(events.PMP_Company_Id__c)){
                eventpartnerId.put(events.PMP_Company_Id__c,events.PMP_Event_Id__r.Name);
            }
        }*/
         
       Boolean isSysAdmin=PMP_SearchUtilityController.isSysAdmin();
       for(PMP_Company__c ptnr : partnerPaginatedList)
        {
            //Start : added by krishna as part of TWC1824-3755.
            Boolean isNandType= false;
            if(ptnr.PMP_Disti_Components_Nm__c != NULL ){
                 string distriCmp = ptnr.PMP_Disti_Components_Nm__c;
                if(!distriCmp.contains(';') && distriCmp == PMP_StaticConstants_Partner.nandProduct){
                   //List<String> strDistri=ptnr.PMP_Disti_Components_Nm__c.split('\\;');
                   // for(string st: strDistri){
                    // if(st == PMP_StaticConstants_Partner.nandProduct){
                         isNandType = True;
                     //  }
                     //}  
                }
               /* else if(distriCmp == PMP_StaticConstants_Partner.nandProduct){
                    isNandType = true;
                }*/
                   
             }
            //End : added by krishna as part of TWC1824-3755.
                    
            Partner partnerWrapper = new Partner();
            partnerWrapper.autoPartnerId = ptnr.PMP_Marketing_Profile_Id__c;
            partnerWrapper.id = ptnr.Id;

            //Changed default logo for Partner Card by NIKHIL 26-Nov-2019
         // partnerWrapper.imageUrl = companyIdAndMemberFlag.get(ptnr.Id) != NULL && companyIdAndMemberFlag.get(ptnr.Id) ? System.Label.PMP_Member_Card_Image : PMP_StaticConstants_Partner.staticPartnerUrl;
            /*if (partnerResMap.containsKey(ptnr.Id)){            
                    partnerWrapper.imageUrl = partnerResMap.get(ptnr.id);          
            }*/
            if(partnerConAssetUrl.containsKey(partnerContentMap.get(ptnr.Id))){
                String assetName = partnerConAssetUrl.get(partnerContentMap.get(ptnr.Id));
                partnerWrapper.imageUrl = System.Label.PMP_CommunityURLSuffix+'file-asset/'+assetName+'?isOptimized=false';
            }
            else{
                 partnerWrapper.imageUrl = companyIdAndMemberFlag.get(ptnr.Id) != NULL && companyIdAndMemberFlag.get(ptnr.Id) ? PMP_StaticConstants_Partner.MemberCardLogo : PMP_StaticConstants_Partner.staticPartnerUrl;
            }
            
            partnerWrapper.isGuest = PMP_SearchUtilityController.isGuest();
       
            if(ptnrDescMap.containsKey(ptnr.Id)){
                
                 String temp = '';
                String description = '';
                String tagline = '';
              // US959732 -- added userLanguage == 'zh-Hans-CN'
            if (userLanguage == PMP_StaticConstants_Partner.ZH_CN || userLanguage == PMP_StaticConstants_Partner.ZH_HANS_CN && ptnrDescMap.get(ptnr.Id).PMP_Chinese_Txt__c != null){
                temp = ptnrDescMap.get(ptnr.Id).PMP_Chinese_Txt__c;
            }
            else if (userLanguage == PMP_StaticConstants_Partner.JA && ptnrDescMap.get(ptnr.Id).PMP_Japanese_Txt__c != null){
                
                temp = ptnrDescMap.get(ptnr.Id).PMP_Japanese_Txt__c;
            }
            else if (ptnrDescMap.get(ptnr.Id).PMP_English_Txt__c != null){
                
                temp = ptnrDescMap.get(ptnr.Id).PMP_English_Txt__c;
            }
            if (ptnrDescMap.get(ptnr.Id).PMP_Field_Nm__c == PMP_StaticConstants_Partner.Description)
            {   
                description = temp;
                            }
            else if (ptnrDescMap.get(ptnr.Id).PMP_Field_Nm__c == 'PMP_Account_Tag_Line__c')
            {
                tagline = temp;
            }
                partnerWrapper.longDescription = description != NULL ? description.unescapeHtml4().stripHtmlTags() : description;
                partnerWrapper.description = description != NULL ? description.unescapeHtml4().stripHtmlTags() : description;
                
            }
            partnerWrapper.name = ptnr.Name;
            partnerWrapper.contactByEmail = false;
            partnerWrapper.contactByForm = true;
            partnerWrapper.attributes = new Map<String, List<Types>>();
            
            //IPA2.0:TWC729-8114 Topics Removal/Event Removal
            /*if(eventpartnerId.keySet().Contains(ptnr.Id)){
                partnerWrapper.eyebrow = true;
                partnerWrapper.eyebrowTagline = eventpartnerId.get(ptnr.Id);
            }*/
            
            Map<String,String> valueLabelMap = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();      
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                valueLabelMap.put(pickListVal.getValue(),pickListVal.getLabel());
            }
            
           
            if(isSysAdmin){
                partnerWrapper.isContactPartnerVisible = true;
            }
            else{
                partnerWrapper.isContactPartnerVisible = contactVisMap.get(ptnr.Id);
            }
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
            String partner_Role='';
            if(ptnr.PMP_Partner_Program_nm__c !=null){          
                List<String> str=ptnr.PMP_Partner_Program_nm__c.split(';');
                List<String> rolevalue = new List<String>();
                for(String partnerRole : str ){
                    if(ppMap.containsKey(partnerRole)){
                        rolevalue.add(ppMap.get(partnerRole));
                    }
                }
                partner_Role = String.join(rolevalue, ', ' );
            }      
            partnerWrapper.role = ptnr.PMP_Is_Distributor_Ind__c ? '' : partner_Role;
            partnerWrapper.partnerRole = ptnr.PMP_Is_Distributor_Ind__c ? '' : partner_Role;
            //String tier = ptnr.PMP_IPA_Badge_Tier_Txt__c != NULL ? ptnr.PMP_IPA_Badge_Tier_Txt__c.toLowerCase() : '';
            //partnerWrapper.status = tier;
            
            /*if(ptnr.PMP_Partner_Benefit_Type__c == 'Solution Marketplace Basic Access'){
                partnerWrapper.partnerStatus = 'member';
                partnerWrapper.status = 'member';
            }
            else{*/
                
                //Ribbon should be displayed as per tier
                if(ptnr.PMP_IPA_Badge_Tier_Txt__c!=null && ptnr.PMP_Is_Distributor_Ind__c!=true){
                // partnerWrapper.partnerStatus = ptnr.PMP_IPA_Badge_Tier_Txt__c.toLowerCase();
                    partnerWrapper.status = ptnr.PMP_IPA_Badge_Tier_Txt__c.toLowerCase();
                    
                    //Added this attribute as part of US857818:Based on benefit - card data should be displayed
                    partnerWrapper.benefitType=ptnr.PMP_Partner_Benefit_Type__c;
                }
                
                
            //}
                
             String web = '';
             if(ptnr.PMP_Account_Website__c != NULL) {
                    web = (ptnr.PMP_Account_Website__c.startsWith('http') ? '' : 'https://') + ptnr.PMP_Account_Website__c;
                    //system.debug('..PMP_Account_Website__c...'+web);
                    partnerWrapper.website = web;
                }            
            
            
            
            if(ptnr.PMP_Is_Distributor_Ind__c) {
                String website = NULL;
                if(ptnr.PMP_Account_Website__c != NULL) {
                    website = (ptnr.PMP_Account_Website__c.startsWith('http') ? '' : 'https://') + ptnr.PMP_Account_Website__c;
                }
                partnerWrapper.distributorWebsite = website;
            }
            // Disti changes MP 2.0
            Map<string, string> bizorgMap = New Map<string, string> {'Intel Approved Component Supplier (IACS)'   => 'Intel Approved Component Supplier',
                'Intel Approved Device Supplier (IADS)'      =>  'Intel Approved Device Supplier',
                'Intel Authorized Distributor (IAD)'         =>  'Intel Authorized Distributor'  };  
            
            Map<string, string> bizorgTaglineMap = New Map<string, string> {'Intel Approved Component Supplier (IACS)'   => System.Label.PMP_Intel_Approved_Component_Supplier,
                'Intel Approved Device Supplier (IADS)'      =>   System.Label.PMP_Intel_Approved_Device_Supplier,
                'Intel Authorized Distributor (IAD)'         =>   System.Label.PMP_Intel_Authorized_Distributor  };  
                    
             //get all the partner bizorg from the below formula field
             String bizOrgList = ptnr.PMP_Biz_Org_Type_Txt__c;
             //disti cards should show all the biz ords the partner is associated with , so this variable holds all the biz orgs of partner as , seperator
             String distributorPartnerTagLine = '';
            if(!string.isBlank(bizOrgList)){
                for(string strVal :  bizOrgList.split('\\;')){
                    if(bizorgMap.containsKey(strVal)){
                        if(distributorPartnerTagLine==''){
                            distributorPartnerTagLine = bizorgTaglineMap.get(strVal);
                        }
                        else{
                            distributorPartnerTagLine = distributorPartnerTagLine +', '+bizorgTaglineMap.get(strVal);// append the biz orgs as comma seperated
                        }
                    }
                }
            }
            
            boolean isDistiPartner= false; // boolean to check if biz org cards are formed
            if(!string.isBlank(bizOrgList)){
                for(string strVal :  bizOrgList.split('\\;')){
                    if(selectedBizOrgs.size()==0 || (selectedBizOrgs.size()>0 && selectedBizOrgs.contains(strVal))){
                    //get all the partner data to local variable to duplicate the card for each biz org.
                    Partner partnerWrapperBizOrg = new Partner();
                    partnerWrapperBizOrg.type= partnerWrapper.type;
                    partnerWrapperBizOrg.id= partnerWrapper.id;
                    partnerWrapperBizOrg.imageUrl= partnerWrapper.imageUrl;
                    partnerWrapperBizOrg.description= partnerWrapper.description;
                    partnerWrapperBizOrg.name= partnerWrapper.name;
                    partnerWrapperBizOrg.contactByEmail= partnerWrapper.contactByEmail;
                    partnerWrapperBizOrg.contactByForm= partnerWrapper.contactByForm;
                    partnerWrapperBizOrg.attributes= partnerWrapper.attributes;
                    partnerWrapperBizOrg.isContactPartnerVisible= partnerWrapper.isContactPartnerVisible;
                    partnerWrapperBizOrg.contactPartnerVisible= partnerWrapper.contactPartnerVisible;
                    partnerWrapperBizOrg.leadLangPreference= partnerWrapper.leadLangPreference;
                    partnerWrapperBizOrg.isGuest= partnerWrapper.isGuest;
                    partnerWrapperBizOrg.autoPartnerId= partnerWrapper.autoPartnerId;
                    partnerWrapperBizOrg.role= partnerWrapper.role;
                    partnerWrapperBizOrg.status= partnerWrapper.status;
                    partnerWrapperBizOrg.website= partnerWrapper.website;
                    partnerWrapperBizOrg.distributorWebsite= partnerWrapper.distributorWebsite;
                    partnerWrapperBizOrg.specialties= partnerWrapper.specialties;
                    partnerWrapperBizOrg.partnerStatus= partnerWrapper.partnerStatus;
                    partnerWrapperBizOrg.partnerRole= partnerWrapper.partnerRole;
                    partnerWrapperBizOrg.benefitType= partnerWrapper.benefitType;
                    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
					/*partnerWrapperBizOrg.eyebrow= partnerWrapper.eyebrow;
					partnerWrapperBizOrg.eyebrowTagline= partnerWrapper.eyebrowTagline;*/
                    
                    if(bizorgMap.containsKey(strVal)){
                        partnerWrapperBizOrg.distributorTagline = bizorgTaglineMap.get(strVal);
                        partnerWrapperBizOrg.searchGrouping = bizorgMap.get(strVal); 
                        if(partnerWrapperBizOrg.distributorTagline == System.Label.PMP_Intel_Approved_Component_Supplier){
                           //Below changes added by krishna as part of TWC1824-3755.
                             if(isNandType){
                                partnerWrapperBizOrg.longDescription =System.Label.PMP_Intel_Approved_Component_Supplier_NAND_Product_txt.stripHtmlTags();  
                                partnerWrapperBizOrg.description = System.Label.PMP_Intel_Approved_Component_Supplier_NAND_Product_txt.stripHtmlTags(); 
                            }
                            //end
                            else{
                              partnerWrapperBizOrg.longDescription = System.Label.PMP_Intel_Approved_Component_Supplier_Txt.stripHtmlTags();  
                              partnerWrapperBizOrg.description = System.Label.PMP_Intel_Approved_Component_Supplier_Txt.stripHtmlTags();   
                            }
                            
                        }
                        else if(partnerWrapperBizOrg.distributorTagline == System.Label.PMP_Intel_Approved_Device_Supplier){
                            partnerWrapperBizOrg.longDescription = System.Label.PMP_Intel_Approved_Device_Supplier_Txt.stripHtmlTags();     
                            partnerWrapperBizOrg.description = System.Label.PMP_Intel_Approved_Device_Supplier_Txt.stripHtmlTags();
                        }
                        else if(partnerWrapperBizOrg.distributorTagline == System.Label.PMP_Intel_Authorized_Distributor){
                            partnerWrapperBizOrg.longDescription = System.Label.PMP_Intel_Authorized_Distributor_Txt.stripHtmlTags();                  
                            partnerWrapperBizOrg.description = System.Label.PMP_Intel_Authorized_Distributor_Txt.stripHtmlTags();
                        }
                        partnerWrapperBizOrg.distributorTagline = distributorPartnerTagLine;
                        partnerWrapperBizOrg.contactPartnerVisible=partnerWrapper.isContactPartnerVisible;
                        isDistiPartner=true; //to indicate disti cards are formed
                        // System.debug('PPP: partnerWrapper'+partnerWrapper);
                        partnerResults.add(partnerWrapperBizOrg);
                    }
                    }
                    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
                    if(/*sortField=='event' ||*/ partnerProgType != PMP_StaticConstants_Partner.distributor){
                        break;
                    }
                }
            }
            //System.debug('PPP: partnerWrapper'+partnerWrapper);
            
            if(!isDistiPartner){ // for non disti partner
                partnerWrapper.contactPartnerVisible = partnerWrapper.isContactPartnerVisible; //for cta button visibility on partner cards
                //System.debug('partnerWrapper'+partnerWrapper);
                
                /*End - 2.0 Changes*/
                partnerResults.add(partnerWrapper);
           }
        }
        return partnerResults;
    }
    
    /*****************************************************************************/
    
    //Modified on 15-Aug-2019 By nikhil
    public static Map<String,Integer> getPartnerCount (List<Id> partnerFound){
        
        Map<String, Integer> partnerCountMap = new Map<String, Integer>();
        List<PMP_Company__c> partnerList = [SELECT PMP_Partner_Program_nm__c,PMP_Account_Specialty__c from PMP_Company__c where id in :partnerFound and (PMP_Partner_Program_nm__c != NULL OR PMP_Account_Specialty__c INCLUDES (:PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program))  ];//WITH SECURITY_ENFORCED
        
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
        // System.debug('catId'+catId);
        List<PMP_Partner_Program__c> odmLoem = new List<PMP_Partner_Program__c>();
        List<PMP_Partner_Program__c> partnerPrograms = new List<PMP_Partner_Program__c>();
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
            odmLoem = [SELECT id, PMP_Is_Active_Ind__c, PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c where PMP_Partner_Program_Value_Txt__c = 'ODM-LOEM' AND PMP_Is_Active_Ind__c=TRUE];//WITH SECURITY_ENFORCED
            partnerPrograms = [SELECT id, PMP_Is_Active_Ind__c, PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c where Id=:catId AND PMP_Is_Active_Ind__c=TRUE];//WITH SECURITY_ENFORCED
        }
        // System.debug('partnerPrograms'+partnerPrograms);
        if(partnerPrograms.size() > 0){
            if(catId!=odmLoem[0].Id){
                 catId = partnerPrograms[0].PMP_Partner_Program_Value_Txt__c;
            }else{
                catId = PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program.replace(' ','_');
            }
           
            
        }
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
            partnerList = [SELECT id,Name from PMP_Company__c where id in :partners and (PMP_Partner_Program_nm__c includes (:catId) OR PMP_Account_Specialty__c INCLUDES ( :catId.replace('_',' ')))];//WITH SECURITY_ENFORCED
        }
        // System.debug('partnerList'+partnerList);
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
            
            List<PMP_Partner_Category__c> partnerCatList = new List<PMP_Partner_Category__c>();
            if(Schema.sObjectType.PMP_Partner_Category__c.isAccessible()){
                partnerCatList = [SELECT PMP_Partner_Id__c FROM PMP_Partner_Category__c WHERE PMP_Category_Id__c IN :options 
                                  AND PMP_Category_Id__r.PMP_Active_Ind__c = true 
                                  AND  PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c like :ansPimId];//WITH SECURITY_ENFORCED
            }
            for(PMP_Partner_Category__c partCat: partnerCatList){
                partnerIds.add(partCat.PMP_Partner_Id__c);
            }
            return partnerIds;
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
        }
    }
      
    public static Map<Id, Boolean> formMemberFlagMap(Set<Id> companyIds) {
        Map<Id, Boolean> companyIdAndMemberFlag = new Map<Id, Boolean>();
        if(companyIds != NULL && companyIds.size() > 0) {
            List<PMP_Company__c> companies = new List<PMP_Company__c>();
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                companies = [SELECT Id, PMP_Partner_Benefit_Type__c FROM PMP_Company__c WHERE Id IN :companyIds];
            }
            for(PMP_Company__c company : companies) {
                companyIdAndMemberFlag.put(company.Id, company.PMP_Partner_Benefit_Type__c == 'Solution Marketplace Basic Access');
            }
        }
        return companyIdAndMemberFlag;
    }
    
     public static Map<String, List<Specialty>> getpartnerSpecialtyforCards(List<String> partnerIds, string langCode){
        Map<String, List<Specialty>>  response= new Map<String, List<Specialty>> ();
        List<PMP_Partner_Specialty__c> specialtyList = [SELECT name,PMP_Partner_Specialty_Chinese_Nm__c, PMP_Partner_Specialty_Japanese_Nm__c, Id, PMP_Partner_Specialty_Chinese_Dsc__c, PMP_Partner_Specialty_English_Dsc__c, PMP_Partner_Specialty_Japanese_Dsc__c, PMP_Is_Active_Ind__c FROM PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE order by name];
        String specialtyName = PMP_SearchUtilityController.getFieldApiName('PMP_Partner_Specialty__c', 'Name',langCode);
         if(String.isEmpty(specialtyName)){
            specialtyName = 'Name';
        }
        List<PMP_Specialty_Images__mdt> metaDataList = new List<PMP_Specialty_Images__mdt>();
        metaDataList = [select PMP_Account_Specialty_Name__c,PMP_Specialty_Name_Chinese__c,PMP_Specialty_Name_Japanese__c, URL__c from PMP_Specialty_Images__mdt where PMP_Account_Specialty_Name__c != null];
        Map<String,String> metadataMap = new Map<String,String>();
        for(PMP_Specialty_Images__mdt md: metaDataList){
            String specTransName=md.PMP_Account_Specialty_Name__c;
            if(langCode=='ja'){
                specTransName=md.PMP_Specialty_Name_Japanese__c;
            } 
            else if(langCode=='zh-Hans-CN' || langCode=='zh-CN'){
                specTransName=md.PMP_Specialty_Name_Chinese__c;
            }
            metadataMap.put(specTransName, md.URL__c);
         //   metadataMap.put(md.PMP_Account_Specialty_Name__c, md.URL__c);
        }
        Map<string, string> sMap= new Map<String,String>();
        for(PMP_Partner_Specialty__c sp:specialtyList)   {
            sMap.put(sp.Name, (String)sp.get(specialtyName));
        }
        List<PMP_Company__c> partners = new  List<PMP_Company__c>();
        Map<String,List<String>> partnerSpecMap=new Map<String,List<String>>();
        partners = [select toLabel(PMP_Account_Specialty__c) from PMP_Company__c where Id IN:partnerIds and PMP_Account_Specialty__c!=null];
        for(PMP_Company__C c: partners){
            List<String> specList=new List<String>();
            specList.addAll(c.PMP_Account_Specialty__c.split(';'));
            partnerSpecMap.put(c.id,specList);
        } 
        //system.debug('partnerSpecMap'+partnerSpecMap);
        for(String s: partnerSpecMap.keySet()){
            for(String specVal:partnerSpecMap.get(s)){
                Specialty spec= new Specialty();
                if(sMap.containsKey(specVal))
                spec.title=sMap.get(specVal);
                else 
                    spec.title=specVal;
                spec.icon=metadataMap.get(specVal);
                spec.iconImgUrl=metadataMap.get(specVal);
                //spec.svgIcon = metadataMap.get(specVal);
                spec.sfIcon='';
                if(response.containsKey(s)){
                    List<Specialty> speclist=response.get(s);
                    speclist.add(spec);
                    response.put(s,speclist);
                }
                else{
                    response.put(s,new List<Specialty> {spec});
                
                }
            }
        }
            //System.debug('..response..'+response);
     return response;
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
        @AuraEnabled public Boolean contactPartnerVisible {get; set;}
        @AuraEnabled public String leadLangPreference {get; set;}
        @AuraEnabled public Boolean isGuest {get; set;}
        @AuraEnabled public String autoPartnerId {get; set;}
        /*2.0 Changes*/
        @AuraEnabled public String role {get; set;}
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String website {get; set;}
        @AuraEnabled public String distributorWebsite {get; set;}
        @AuraEnabled public String distributorTagline {get; set;}
        @AuraEnabled public String searchGrouping {get; set;}
        @AuraEnabled public String longDescription {get;set;}
        @AuraEnabled public List<Specialty> specialties {get;set;}
        @AuraEnabled public String partnerStatus {get; set;}
        @AuraEnabled public String partnerRole {get; set;}
        @AuraEnabled public String benefitType {get; set;}
        
        //IPA2.0:TWC729-8114 Topics Removal/Event Removal
        //eventeyebrow
        /*@AuraEnabled public Boolean eyebrow {get; set;}
        @AuraEnabled public String eyebrowTagline {get; set;}*/ 
       
    }   
}