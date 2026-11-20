/****************************************************************************************************************************************
* Class Name  : PMP_SearchProductController 
* Version     : 1.0 
* Created Date: 07-May-2019
* Created By : Tanzanite Team Infosys

* Modification Log :
* Developer       Date                 Description
* ----------------------------------------------------------------------------
* Nikhil          07-Jul-2019          Updated getOfferingIds method to use Partner Offering Translation object        
*****************************************************************************************************************************************/

public with sharing class PMP_SearchProductController extends PMP_SearchWrapperStore {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getOfferingIds(String keyword, List<String> offerings) {
        keyword = PMP_SearchUtilityController.escapeSosl(keyword);
        // system.debug(keyword);
        List<String> offIdsFound = new List<String>();
        Set<String>  offIds = new Set<String>();
        boolean isIntelEmployee = PMP_Utility.isIntelEmployee();
        string novalue = PMP_Utility.getValue('PMP_PreReleaseCheck_Nm');
        if (String.isNotBlank(keyword))
        {   
            List<List<SObject>> pubTransList= new List<List<SObject>>();    
            try {
                if(isIntelEmployee == true) {
                    //Sai Thotakura
                    //Updated the filter conditions to include pre-release approved offerings for intel employees only
                    /*
                     1. Fully Published Copies
                     2. Pre-release count greater than 0 approved offerings
                     3. Pre-release count is zero and pre release check : NO offerings
                     4. Offerings with future start date
                    */
                    pubTransList = [FIND :keyword IN ALL FIELDS RETURNING 
                    PMP_Partner_Offering_Translation__c(PMP_Partner_Offering_Id__c
                    WHERE (( PMP_Partner_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published and ( PMP_Partner_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Partner_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY and PMP_Partner_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = false))
                    OR
                    (PMP_Partner_Offering_Id__r.PMP_Working_Copy_Id__c = null and PMP_Partner_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Approved and PMP_Partner_Offering_Id__r.PMP_Pre_Release_Item_Count_Num__c >: PMP_StaticConstants_MasterData.Zero and PMP_Partner_Offering_Id__r.PMP_Pre_Release_Check_Nm__c != null)
                    OR
                    (PMP_Partner_Offering_Id__r.PMP_Working_Copy_Id__c = null and PMP_Partner_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Approved and PMP_Partner_Offering_Id__r.PMP_Pre_Release_Item_Count_Num__c =:PMP_StaticConstants_MasterData.Zero and PMP_Partner_Offering_Id__r.PMP_Pre_Release_Check_Nm__c =:novalue and PMP_Partner_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c !=null)
                    OR
                    (PMP_Partner_Offering_Id__r.PMP_Working_Copy_Id__c = null and PMP_Partner_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Approved and PMP_Partner_Offering_Id__r.PMP_Pre_Release_Item_Count_Num__c =:PMP_StaticConstants_MasterData.Zero and PMP_Partner_Offering_Id__r.PMP_Pre_Release_Check_Nm__c = null and PMP_Partner_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c > TODAY)) 
                    AND PMP_Partner_Offering_Id__r.PMP_Company_Id__r.PMP_Benefit_Update_Ind__c=False AND PMP_Partner_Offering_Id__c IN :offerings
                    ORDER BY PMP_Partner_Offering_Id__r.PMP_Offering_Status_Update_Dt__c DESC NULLS LAST )];

                } else {
                    //this query is for public user
                    pubTransList = [FIND :keyword IN ALL FIELDS RETURNING 
                    PMP_Partner_Offering_Translation__c(PMP_Partner_Offering_Id__c
                    WHERE PMP_Partner_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published and PMP_Partner_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Partner_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY and PMP_Partner_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = false 
                    AND PMP_Partner_Offering_Id__r.PMP_Company_Id__r.PMP_Benefit_Update_Ind__c=False AND PMP_Partner_Offering_Id__c IN :offerings
                    ORDER BY PMP_Partner_Offering_Id__r.PMP_Offering_Status_Update_Dt__c DESC NULLS LAST)];
                } 
            } catch(Exception e){
                //System.debug('Error occured while searching the keyword in traslation object :'+ e);
                //throw e;//error handling
            }
            for (List<SObject> listObj : pubTransList)
            {
                for(SObject obj : listObj)
                {

                    if(obj.getSObjectType() == PMP_Partner_Offering_Translation__c.sObjectType)
                    {
                        PMP_Partner_Offering_Translation__c trans = (PMP_Partner_Offering_Translation__c) obj; 
                        
                            offIds.add(trans.PMP_Partner_Offering_Id__c);
                                  
                    }
                }

            }  
        }
        else
        {
            List<PMP_Partner_Offering__c> pubOffList = new List<PMP_Partner_Offering__c>();
            try{
                if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
                    if(isIntelEmployee == true) {

                        //Sai Thotakura
                       //Updated the filter conditions to include pre-release approved offerings for intel employees only
                        /*
                         1. Fully Published Copies
                         2. Pre-release count greater than 0 approved offerings
                         3. Pre-release count is zero and pre release check : NO offerings
                         4. Offerings with future start date
                        */
                        pubOffList = [SELECT Id FROM PMP_Partner_Offering__c 
                        WHERE (( PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published and ( PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Partner_Offering_End_Dt__c >= TODAY and PMP_Is_Not_Available_On_MP_Ind__c = false))
                        OR
                        (PMP_Working_Copy_Id__c = null and PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Approved and PMP_Pre_Release_Item_Count_Num__c >:PMP_StaticConstants_MasterData.Zero and PMP_Pre_Release_Check_Nm__c != null)
                        OR
                        (PMP_Working_Copy_Id__c = null and PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Approved and PMP_Pre_Release_Item_Count_Num__c =:PMP_StaticConstants_MasterData.Zero and PMP_Pre_Release_Check_Nm__c =:novalue and  PMP_Partner_Offering_Start_Dt__c != null)
                        OR
                        (PMP_Working_Copy_Id__c = null and PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Approved and PMP_Pre_Release_Item_Count_Num__c =:PMP_StaticConstants_MasterData.Zero and PMP_Pre_Release_Check_Nm__c = null and PMP_Partner_Offering_Start_Dt__c > TODAY))
                        AND PMP_Company_Id__r.PMP_Benefit_Update_Ind__c=False AND Id IN :offerings
                        ORDER BY PMP_Offering_Status_Update_Dt__c DESC NULLS LAST LIMIT 30000];
                    } else {
                        //this query is for public user
                        pubOffList = [SELECT Id FROM PMP_Partner_Offering__c 
                        WHERE PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published and PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Partner_Offering_End_Dt__c >= TODAY and PMP_Is_Not_Available_On_MP_Ind__c = false
                        AND PMP_Company_Id__r.PMP_Benefit_Update_Ind__c=False AND Id IN :offerings
                        ORDER BY PMP_Offering_Status_Update_Dt__c DESC NULLS LAST LIMIT 30000];
                    }             
                }
            }catch(Exception e){
                //System.debug('Error occured while searching the keyword in traslation object :'+ e);
               // throw e; //error handling
            }
            for(PMP_Partner_Offering__c off :pubOffList)
            {
                
                    offIds.add(off.Id);
            }
        } 
        offIdsFound.addAll(offIds);
        return offIdsFound;
    }
    
    
    
    /****************************************************************************************************************/
    
    /*@AuraEnabled(cacheable=true)
    public static Map<String,Integer> getCount (List<id> offFound){
        Map<String,Integer> countMap=new Map<String,Integer>();
        Map<String,set<String>> offPimIdsMap=new Map<String,set<String>>();
        List<PMP_Partner_Offering_Category__c> catList = new List<PMP_Partner_Offering_Category__c>();
        if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
            catList = [select  PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,  PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c, PMP_Ancestor_Category_Cd__c,PMP_Offering_Category_External_Key__c,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c 
                       where PMP_Offering_Id__c in :(offFound) and PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c!=null 
                       and PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c!=null and PMP_Category_Id__c !=null AND PMP_Category_Id__r.PMP_Active_Ind__c = true ];         
        }
        
        for(PMP_Partner_Offering_Category__c offCategory : catList){
            set<String> pimIds=new Set<String>(); 
            
            pimIds.addAll(offCategory.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c.split('\\|')); //Adding All Ancestors
            pimIds.add(offCategory.PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c);       //Adding pimId of Category associated
            //Mapping Offering with associated category List
            if (offPimIdsMap.containsKey(offCategory.PMP_Offering_Id__c)){
                offPimIdsMap.get(offCategory.PMP_Offering_Id__c).addAll(pimIds);
            }else{
                offPimIdsMap.put(offCategory.PMP_Offering_Id__c,pimIds);
            }    
        }
        //Count Logic//
        for (Set<String> pimIdsList: offPimIdsMap.values()){
            for (String pimIds: pimIdsList){
                if (countMap.containsKey(pimIds)){
                    Integer count = countMap.get(pimIds) + 1 ;
                    countMap.put(pimIds,count);
                }else{
                    countMap.put(pimIds,1);
                }
            }
        }
        return countMap;
    }
    */
    /*************************************************************************************************************/
    
    
    public static List<Id> filterOfferings(List<String> catId,List<Id> offerings){
        List<PMP_Partner_Offering_Category__c> offList = new List<PMP_Partner_Offering_Category__c>();
       // if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
            offList = [select PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c IN:offerings and
                       PMP_Category_Id__c in :catId and PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c!=null 
                       and PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c!=null ];
       // }
        Set<Id> offIds = new Set<Id>();
        for(PMP_Partner_Offering_Category__c off : offList){
            offIds.add(off.PMP_Offering_Id__c);
        } 
        List<Id> offIdsList=new List<Id>();
        offIdsList.addAll(offIds);    
        return offIdsList;
    }
    
    /*************************************************************************************************************/
    /*
    //Created by Kartik
    //Method to fetch offerings based on the Specialty selected//
    
    public static List<Id> getOfferingSpecialtyResults(List<String> optionList){
        List<Id> offeringIds = new List<Id>();
        List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
        List<Id> result = null;
        
        if (!optionList.isEmpty()){
            String query =  'SELECT id FROM PMP_Partner_Offering__c WHERE PMP_Company_Id__r.PMP_Account_Specialty__c INCLUDES (';
            
            for(String option :optionList){
                if(optionList.indexOf(option) == optionList.size()-1){
                    query += '\'' + String.escapeSingleQuotes(option.replace('_',' ')) + '\'';
                }else{
                    query += '\'' + String.escapeSingleQuotes(option.replace('_',' ')) + '\''+ ',';
                }
                
                
            }
            query += ')';
            
            offeringList = Database.query(query);
            
            for(PMP_Partner_Offering__c offering : offeringList){
                offeringIds.add(offering.Id); 
            }
            result = offeringIds;
        }
        return result;
    }
    
    */
    /*************************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<Product> getProducts(List<id> offerings,Integer currentPage, Integer pageSize,String sortField, String langCode,String keyword){//PROD DEFECT FIX: added keyword=null parameter at the end
        
        List<Product> productList= new List<Product>();
        String sortBy = '';
        String pubstatus = PMP_StaticConstants_Partner.Published;
        String approvedstatus = PMP_StaticConstants_Partner.Approved;
        Integer prereleasecount = PMP_StaticConstants_MasterData.Zero;
        string novalue = PMP_Utility.getValue('PMP_PreReleaseCheck_Nm');
        String offeringList;
        //New Logic for sorting - 2.0 changes
        if(sortField == PMP_StaticConstants_Partner.sortFieldTier)
            sortBy = PMP_StaticConstants_Partner.sortByTierOffering ;
        else
            sortBy = PMP_StaticConstants_Partner.sortByMostRecentOffering;
        // System.debug('$$sortBy-->'+sortBy);
        //Sort logic End
        //Fetch Sorted Offering
        //Check for Is Intel Employee
        boolean isIntelEmployee = PMP_Utility.isIntelEmployee();
        if(isIntelEmployee == true)
        {
           //Sai Thotakura
           //If IsIntelEmployee, the user will see fully published copies along with pre-release approved offerings.
           /*
            1. Fully Published Copies
            2. Pre-release count greater than 0 approved offerings
            3. Pre-release count is zero and pre release check : NO offerings
            4. Offerings with future start date
           */
           offeringList = 'select PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Partner_Offering_Visibility_Nm__c,PMP_Published_Copy_Id_Txt__c,PMP_Featured_Offering_Ind__c, PMP_Company_Id__r.PMP_IPA_Badge_Tier_Txt__c,PMP_Partner_Offering_Nm__c,Name,PMP_Company_Id__c , PMP_Company_Id__r.PMP_Marketing_Profile_Id__c ,PMP_Company_Id__r.Name, PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c,PMP_Offering_Id__c, PMP_Category_nm__c, PMP_Sub_Category_nm__c,PMP_Company_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Company_Id__r.PMP_Company_Status_Published_Date_Dt__c,PMP_Company_Id__r.PMP_Partner_Program_nm__c,PMP_Partner_Offering_Dsc__c from PMP_Partner_Offering__c where id in :offerings and ( ( PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Partner_Offering_End_Dt__c >= TODAY and PMP_Partner_Offering_Lifecycle_Status_Nm__c = :pubstatus and PMP_Is_Not_Available_On_MP_Ind__c = false) OR (PMP_Partner_Offering_Lifecycle_Status_Nm__c = :approvedstatus and PMP_Working_Copy_Id__c = null and PMP_Pre_Release_Item_Count_Num__c >:prereleasecount and PMP_Pre_Release_Check_Nm__c != null) OR (PMP_Partner_Offering_Lifecycle_Status_Nm__c = :approvedstatus and PMP_Working_Copy_Id__c = null and PMP_Pre_Release_Item_Count_Num__c =:prereleasecount and PMP_Pre_Release_Check_Nm__c =:novalue and PMP_Partner_Offering_Start_Dt__c !=null) OR (PMP_Partner_Offering_Lifecycle_Status_Nm__c = :approvedstatus and PMP_Working_Copy_Id__c = null and PMP_Pre_Release_Item_Count_Num__c =:prereleasecount and PMP_Pre_Release_Check_Nm__c = null and PMP_Partner_Offering_Start_Dt__c > TODAY ) ) ORDER BY ';
        } 
        else
        {
            //Sai Thotakura
            //If not an Intel Employee, only fully published copies are displayed.
           offeringList = 'select PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Partner_Offering_Visibility_Nm__c,PMP_Published_Copy_Id_Txt__c,PMP_Featured_Offering_Ind__c, PMP_Company_Id__r.PMP_IPA_Badge_Tier_Txt__c,PMP_Partner_Offering_Nm__c,Name,PMP_Company_Id__c , PMP_Company_Id__r.PMP_Marketing_Profile_Id__c , PMP_Company_Id__r.Name, PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c,PMP_Offering_Id__c, PMP_Category_nm__c, PMP_Sub_Category_nm__c,PMP_Company_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Company_Id__r.PMP_Company_Status_Published_Date_Dt__c,PMP_Company_Id__r.PMP_Partner_Program_nm__c,PMP_Partner_Offering_Dsc__c from PMP_Partner_Offering__c where id in :offerings and ( PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Partner_Offering_End_Dt__c >= TODAY and PMP_Partner_Offering_Lifecycle_Status_Nm__c = :pubstatus and PMP_Is_Not_Available_On_MP_Ind__c = false ) ORDER BY ';
        }
        String finalOfferingList = offeringList + sortBy;
        //Calculate Offset
        Integer offset = (currentPage-1)*pageSize;
        // system.debug('offset' + offset);
        
        List<PMP_Partner_Offering__c> offList = new List<PMP_Partner_Offering__c>();
        
        //Pagination Logic
        if(offset > 2000){                  //since max offset limit is 2000 only
            Integer rangeFirst = pageSize * (currentPage - 1) ;
            Integer rangeLast = Math.min(pageSize * currentPage, offerings.size()) ;
            //Fetch all the sorted offerings first
            List<PMP_Partner_Offering__c> allOfferings = Database.query(String.escapeSingleQuotes(finalOfferingList));
            //IPA2.0:TWC729-8114 Topics Removal/Event Removal
            /*if(sortField=='event'){
                rangeLast = Math.min(pageSize * currentPage, allOfferings.size()) ;
            }*/

            //Pagination Logic
            for (Integer i = rangeFirst; i < rangeLast ; i++)
            {
                offList.add(allOfferings.get(i));
            }
        }
        else{
            //IPA2.0:TWC729-8114 Topics Removal/Event Removal
            /*if(sortField=='event'){   
                finalOfferingList+=' LIMIT 8 OFFSET ' + offset;
            }*/
            if (keyword==null || offerings.size()>=offset){ //PROD DEFECT FIX: added if condition here
                finalOfferingList+=' LIMIT 12 OFFSET ' + offset;
            }
            //PROD DEFECT FIX: added below else block
            else {
                finalOfferingList+=' LIMIT 12 ';
            }
            // system.debug('finalOfferingList'+finalOfferingList);
            offList = Database.query(String.escapeSingleQuotes(finalOfferingList));
        }
        
        // system.debug('..offList..'+offList.Size());
        //Logic END
        Map<String, String> offL2CatIdMap = new Map<String, String>();
        Map<String,String> OffL3CatIdMap = new Map<String,String>();
        
        List<PMP_Partner_Offering__c> productPaginatedList = new List<PMP_Partner_Offering__c>();
        List<PMP_Company__c> partners = new List<PMP_Company__c>();
        List<Id> paginatedIds = new List<Id>();
        List<Id> partnerIds = new List<Id>();
        Set<String> OffIdWithL3Cat= new Set<String>();
        //Set<String> OffL3Categories= new Set<String>();
        List<String> categoryListForL1L2L3= new List<String>();
        
        for(PMP_Partner_Offering__c off : offList){
            paginatedIds.add(off.Id);
            productPaginatedList.add(off);
            offL2CatIdMap.put(off.Id, off.PMP_Sub_Category_nm__c);
            partnerIds.add(off.PMP_Company_Id__c);
            if(off.PMP_Sub_Category_nm__c!=null && off.PMP_Category_nm__c!=null ){
                OffL3CatIdMap.put(off.Id,off.PMP_Category_nm__c+'|'+off.PMP_Sub_Category_nm__c);
            }
            if(off.PMP_Sub_Category_nm__c!=null){
                //TWC1824-260 - to handle multiple L2 subcategories
                categoryListForL1L2L3.addAll(off.PMP_Sub_Category_nm__c.split(','));

            }
             if(off.PMP_Category_nm__c!=null){
                categoryListForL1L2L3.add(off.PMP_Category_nm__c);
            }

        }
        
        //System.debug('..OffL3CatIdMap..'+OffL3CatIdMap);
        OffIdWithL3Cat.addAll(OffL3CatIdMap.keySet());
        //OffL3Categories.addAll(OffL3CatIdMap.values());
        Map<String,String> L3Values=new Map<String, String>();
        
        List<PMP_Partner_Offering_Category__c> L3Categories=[select id,name, PMP_Ancestor_Category_Cd__c, PMP_Category_Id__r.name,
                                                             PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c 
                                                             where PMP_Offering_Id__c IN:OffIdWithL3Cat and PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c LIKE:'Categories%'];
        // System.debug('.....L3Categories.....'+L3Categories);
        
        for(PMP_Partner_Offering_Category__c poc:L3Categories){
            String str= poc.PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c;
            if(str!=null){
                   String[] categories= str.split('\\|');
                if(categories.size()>3){
                       String value= categories[3];
                       L3Values.put(poc.PMP_Offering_Id__c,value); 
                }
                else if (categories.size()==3)
                   L3Values.put(poc.PMP_Offering_Id__c,poc.name); 
            }
        }
        //System.debug('....L3Values...'+L3Values);
        categoryListForL1L2L3.addAll(L3Values.values());
        List<PMP_Category__c> catL1L2L3List = [SELECT id, Name,PMP_Parent_Category_Id__r.Name,PMP_Category_Chinese_Nm__c, PMP_Category_Japanese_Nm__c from PMP_Category__c where Name IN:categoryListForL1L2L3];
        Map<String,String> catL1L2L3NameIdMap= new Map<String,String>();
        Map<String,String> catL1L2L3NameTrans=new Map<String,String>();
        
        for(PMP_Category__c cat: catL1L2L3List){
            If(L3Values.Values().Contains(cat.Name)){
                 catL1L2L3NameIdMap.put(cat.PMP_Parent_Category_Id__r.Name+'-'+cat.Name,cat.Id);
            }
            else catL1L2L3NameIdMap.put(cat.Name,cat.Id);
            //added the below line for translation values
            catL1L2L3NameTrans.put(cat.Name, PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD,langCode)); 
           // PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
        }
        //system.debug('..Language inside the product controller...'+langCode);
        //system.debug('..Language inside the product controller...'+catL1L2L3NameTrans);

        //Logic End
        
        List<PMP_Category__c> catL2List = [SELECT id, Name from PMP_Category__c where Name IN:offL2CatIdMap.values()];
        Map<String,String> catNameIdMap = new Map<String, String>();
        for(PMP_Category__c cat : catL2List){
            catNameIdMap.put(cat.Name, cat.Id);
        }
        
        //Image Logic
        List<PMP_Partner_Offering_Resource__c> offResList = new List<PMP_Partner_Offering_Resource__c>();
        
        Map<String,String> offContentMap = new Map<String,String>();
        //Map<Id,String> offResMap = new Map<Id,String>();
        
        if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
            offResList = [Select PMP_Offering_Id__c, PMP_Partner_Offering_Image__c from PMP_Partner_Offering_Resource__c WHERE PMP_Offering_Id__c in :paginatedIds
                          and (PMP_Resource_Type_Nm__c =: PMP_StaticConstants_Partner.THUMBNAIL_IMAGE OR PMP_Resource_Type_Nm__c=: PMP_StaticConstants_Partner.IMAGE) 
                          and PMP_Partner_Offering_Image__c!=null and PMP_Resource_Sequence_Nbr__c = 0 ORDER BY PMP_Resource_Type_Nm__c ASC]; // Uday:changed resource type to Thumbnail        
        }
        
        for(PMP_Partner_Offering_Resource__c offRes : offResList){
            offContentMap.put(offRes.PMP_Offering_Id__c, offRes.PMP_Partner_Offering_Image__c);
        }
        
        List<String> conDocList = new List<String>();
        conDocList.addAll(offContentMap.values());
        //List<ContentDistribution> conDistList = PMP_SearchOfferingImageUtility.getContentDistList(conDocList);
    
        Map<String,String> offAssetUrlMap = new Map<String, String>();
        if(!conDocList.isEmpty()){
          offAssetUrlMap = PMP_SearchOfferingImageUtility.getContentAssetUrlMap(conDocList);
        }
        
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
            //Modified as a part of OPID Restructure : Removing PMP_Account_Id__c from Query
            partners = [SELECT id, PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c, toLabel(PMP_Company_Lead_Gen_Language_Nm__c) from PMP_Company__c where id in :partnerIds];
            //Existing Query                                                                                            
            //partners = [SELECT id,PMP_Account_Id__c, PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c, toLabel(PMP_Company_Lead_Gen_Language_Nm__c) from PMP_Company__c where id in :partnerIds];
        }
        //Logic End
        
        //Event related offerings eyebrow
        //IPA2.0:TWC729-8114 Topics Removal/Event Removal
        /*Map<String,String> eventofferingId= new Map<String,String>();
        List<PMP_Marketplace_Event_Offering__c> offeringEvents =[select PMP_Offering_Id__c,PMP_Event_Id__r.Name from PMP_Marketplace_Event_Offering__c  
                                                               WHERE PMP_Offering_Id__c IN :offerings AND PMP_Event_Id__r.PMP_Marketplace_Event_Status__c =true ORDER BY PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c DESC];
        for(PMP_Marketplace_Event_Offering__c events: offeringEvents){
            if(!eventofferingId.containsKey(events.PMP_Offering_Id__c)){
                eventofferingId.put(events.PMP_Offering_Id__c,events.PMP_Event_Id__r.Name);
            }
        }*/
        
        
        Map<String, List<Options>> partnerLangOptionMap = new Map<String, List<Options>>();
        
        for(PMP_Company__c partner : partners){
            List<Options> languagePrefs = new List<Options>();
            if(partner.PMP_Company_Lead_Gen_Language_Nm__c!=null){                       
                for(String prefLang : partner.PMP_Company_Lead_Gen_Language_Nm__c.split(';')){
                    Options option = new Options();
                    option.label = prefLang;
                    option.value = prefLang;
                    option.selected = true;
                    languagePrefs.add(option);
                    
                }
            }
            partnerLangOptionMap.put(partner.Id, languagePrefs);
            
        }
       
        Map<String, Boolean> contactVisMap = new Map<String,Boolean>();
        contactVisMap = PMP_SearchUtilityController.isContactPartnerVisible(partners);
        
        //Logic to get Offering Name from translation
        Map<String,PMP_Partner_Offering_Translation__c> offNameMap = new Map<String,PMP_Partner_Offering_Translation__c>(); 
        Map<String,PMP_Partner_Offering_Translation__c> offDescMap = new Map<String,PMP_Partner_Offering_Translation__c>(); 
        List<PMP_Partner_Offering_Translation__c> offTransList = [SELECT PMP_Field_Nm__c, PMP_Partner_Offering_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Partner_Offering_Translation__c 
                                                                  WHERE (PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_NAME OR PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_DESCRIPTION) AND PMP_Partner_Offering_Id__c IN :paginatedIds];
        for(PMP_Partner_Offering_Translation__c trans: offTransList){
            if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_NAME){
                offNameMap.put(trans.PMP_Partner_Offering_Id__c,trans);
            }else if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_DESCRIPTION){
                offDescMap.put(trans.PMP_Partner_Offering_Id__c,trans);
            }
            
        }
        //Changes End
        
        //Logic to get prerelease information
        Map<String,Boolean> preIndMap = isPreReleased(paginatedIds);
        Boolean isAdminUser =  PMP_SearchUtilityController.isSysAdmin();
        for(PMP_Partner_Offering__c off : productPaginatedList){
            Product productWrapper = new Product();
          //  productWrapper.featured = off.PMP_Featured_Offering_Ind__c;
           if(off.PMP_Partner_Offering_Lifecycle_Status_Nm__c == pubstatus) {
               //if it is a fully published copy take the pub copy id
               productWrapper.id = off.id;
           } else {
               //take the dummy pub copy if available if not then take approved copy id
            productWrapper.id = off.PMP_Published_Copy_Id_Txt__c !=null ? off.PMP_Published_Copy_Id_Txt__c : off.id;
           }

           
            //To Check if prerelease
            if(preIndMap.containsKey(off.Id)){
                productWrapper.prerelease = preIndMap.get(off.Id);
            }
            //Logic End
            
            
            //To check if intel only offering
            if(off.PMP_Partner_Offering_Visibility_Nm__c == PMP_StaticConstants_Partner.INTEL_ONLY){
                productWrapper.onlyVisibleToIntel = true;
            }
            //Logic end
           
            if(offAssetUrlMap.containsKey(offContentMap.get(off.Id))){
                String assetName = offAssetUrlMap.get(offContentMap.get(off.Id));
                productWrapper.imageUrl = System.Label.PMP_CommunityURLSuffix+'file-asset/'+assetName+'?isOptimized=false';
            }
            else{
                //Changed default logo for Product Card by NIKHIL 26-Nov-2019
                productWrapper.imageUrl = PMP_StaticConstants_Partner.staticProductUrl;
            }
           
            productWrapper.title = off.PMP_Partner_Offering_Nm__c;
            if(offNameMap.containsKey(off.Id)){
                productWrapper.title = PMP_SearchUtilityController.getLocalisedName(offNameMap.get(off.Id), '', langCode).unescapeHtml4().stripHtmlTags();
            }
                          
            //String descr = PMP_SearchUtilityController.getLocalisedName(offDescMap.get(off.Id), '', langCode);    
            String temp = '';   
            String descrip = '';    
            String tagline = '';    
            string userLanguage = langCode; 
            
        if(offDescMap.containsKey(off.Id)){ 
                            
            //system.debug('userLanguage'+userLanguage +'static constant'+PMP_StaticConstants_Partner.JA);
            //US959732 : added userLanguage == 'zh-Hans-CN'
            if (userLanguage == PMP_StaticConstants_Partner.ZH_CN || userLanguage == PMP_StaticConstants_Partner.ZH_HANS_CN  && offDescMap.get(off.Id).PMP_Chinese_Txt__c != null){ 
                temp = offDescMap.get(off.Id).PMP_Chinese_Txt__c;   
            }   
            else if (userLanguage == PMP_StaticConstants_Partner.JA && offDescMap.get(off.Id).PMP_Japanese_Txt__c != null){ 
                    
                temp = offDescMap.get(off.Id).PMP_Japanese_Txt__c;  
            }   
            else if (offDescMap.get(off.Id).PMP_English_Txt__c != null){    
                    
                temp = offDescMap.get(off.Id).PMP_English_Txt__c;   
            }   
            if (offDescMap.get(off.Id).PMP_Field_Nm__c == PMP_StaticConstants_Offering.Description) 
            {   
                descrip = temp; 
            }   
            else if (offDescMap.get(off.Id).PMP_Field_Nm__c == 'PMP_Account_Tag_Line__c')   
            {   
                tagline = temp; 
            }   
                
        }   
                productWrapper.description = descrip != NULL ? descrip.unescapeHtml4().stripHtmlTags() : descrip;
           // productWrapper.description=off.PMP_Partner_Offering_Dsc__c != NULL ? off.PMP_Partner_Offering_Dsc__c.stripHtmlTags() : off.PMP_Partner_Offering_Dsc__c;
            Partner productPartner = new Partner();
            productPartner.autoPartnerId = off.PMP_Company_Id__r.PMP_Marketing_Profile_Id__c;
            productPartner.id = off.PMP_Company_Id__r.id ; //'somefakeID2x92'; //product.PMP_Company_Id__r.Id;
            productPartner.name = off.PMP_Company_Id__r.Name; // 'AMAX Engineering Corporation';//('Mock Partner #' +  ' Lorem ipsum dolor sit amet, consectetur adipiscing elit Vivamus convallis dolor sit amet tortor').substring(0, (Math.round(Math.random()*60) + 20)); //product.PMP_Company_Id__r.Name;
            productPartner.contactByEmail = true;
            productPartner.contactByForm = false;
           
            String Role='';
            if(off.PMP_Company_Id__r.PMP_Partner_Program_nm__c !=null){
                List<String> str1=off.PMP_Company_Id__r.PMP_Partner_Program_nm__c.split(';');
                Role = String.join(str1, ', ' );
            }
          
            productWrapper.partner = productPartner;
            productWrapper.isGuest = PMP_SearchUtilityController.isGuest();
            //2.0 Changes
            productWrapper.cardType = 'product';
            //updated below line for the story : US959732
            productWrapper.name =productWrapper.title!=null ? productWrapper.title : off.PMP_Partner_Offering_Nm__c; 
            //productWrapper.partnerByLine =off.PMP_Category_nm__c ;
            
            //Eyebrow for event related offerings
            //IPA2.0:TWC729-8114 Topics Removal/Event Removal
            /*if(eventofferingId.keySet().Contains(off.Id) && off.PMP_Featured_Offering_Ind__c == false){
                productWrapper.partner.eyebrow = true;
                productWrapper.partner.eyebrowTagline = eventofferingId.get(off.Id);
            }*/
            
            //eyebrow for featured offerings
            if(off.PMP_Featured_Offering_Ind__c){
                productWrapper.partner.eyebrow = true;
                productWrapper.partner.eyebrowTagline = System.Label.PMP_Featured;
            }
            
            //productWrapper.partner.byline =off.PMP_Category_nm__c ;
            if(catNameIdMap.containsKey(off.PMP_Sub_Category_nm__c)){
                productWrapper.compareCategoryId =catNameIdMap.get(off.PMP_Sub_Category_nm__c);
            }
            if(isAdminUser)
                productWrapper.isContactPartnerVisible = true;
            else
                productWrapper.isContactPartnerVisible = contactVisMap.get(off.PMP_Company_Id__c);

            productWrapper.leadLangPreference = PMP_SearchUtilityController.getLanguageMessage(partnerLangOptionMap.get(off.PMP_Company_Id__c ));
            //productWrapper.attributes = tempMap; 
            productWrapper.contactPartnerVisible = productWrapper.isContactPartnerVisible;
            productWrapper.featured = off.PMP_Featured_Offering_Ind__c;
            productWrapper.autoOffId = off.PMP_Offering_Id__c;
            productWrapper.categoryLabel = off.PMP_Category_nm__c + '-' + off.PMP_Sub_Category_nm__c;
            productWrapper.categories = new List<String>();
            if(off.PMP_Category_nm__c!=null){
                String catId=catL1L2L3NameIdMap.get(off.PMP_Category_nm__c);
                if(catId!=null){
                    CategoryLevel l1= new CategoryLevel();
                    l1.Name=catL1L2L3NameTrans.get(off.PMP_Category_nm__c); l1.Id=catId;
                    productWrapper.categoryL1=l1;
                }
            }
            //productWrapper.categories.add(off.PMP_Category_nm__c);
            if(off.PMP_Sub_Category_nm__c!=null){
          //TWC1824-260 - to handle multiple L2 subcategories
               List<CategoryLevel> cLevelList= new List<CategoryLevel>();
                List<String> subCategories=off.PMP_Sub_Category_nm__c.split(',');
                        for(String subCat: subCategories){
                        String catIdL2=catL1L2L3NameIdMap.get(subCat);
                    if(catIdL2!=null){
                        CategoryLevel l2= new CategoryLevel();
                        l2.Name=catL1L2L3NameTrans.get(subCat); l2.Id=catIdL2;
                        cLevelList.add(l2);
                      }
                     }
                   productWrapper.categoryL2=cLevelList;
                    
                if(L3Values.containsKey(off.Id)){
                    //String catIdL3=catL1L2L3NameIdMap.get(L3Values.get(off.Id));
                   String catIdL3 =catL1L2L3NameIdMap.get(off.PMP_Sub_Category_nm__c+'-'+L3Values.get(off.Id));
                   if(catIdL3!=null){
                        CategoryLevel l3= new CategoryLevel();
                        l3.Name=catL1L2L3NameTrans.get(L3Values.get(off.Id)); l3.Id=catIdL3;
                        productWrapper.categoryL3=l3;
                        
                    }
                }
                
            }
            
            productList.add(productWrapper); 
        }
        return productList;
    }
    
    
    
    /****************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<Id> quickSearchResults(Map<String,List<String>> selectedFilters,List<id> offerings){
        
        List<Id> result = new List<Id>();
        
        List<Id> offIds=offerings;
        set<Id> filteredOff=new set<Id>();
        PMP_Category__c industry;
        PMP_Category__c application;
        PMP_Specification__c region;
        PMP_Category__c types;
        if(Schema.sObjectType.PMP_Category__c.isAccessible()){
            industry = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_INDUSTRY_ID LIMIT 1];        
        }
        if(Schema.sObjectType.PMP_Category__c.isAccessible()){
            application = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_APPLICATION_ID LIMIT 1];        
        }
        if(Schema.sObjectType.PMP_Specification__c.isAccessible()){
            region = [SELECT Id,Name,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c FROM PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c =: PMP_StaticConstants_Partner.REGION_PIM_ID LIMIT 1];        
        }
        if(Schema.sObjectType.PMP_Category__c.isAccessible()){
            types = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_CATEGORY_ID LIMIT 1];
        }
        
        filteredOff.addAll(offIds);
        
        //To filter the offering based on selected application filter//
        if (selectedFilters.containsKey(application.Id) && !selectedFilters.get(application.Id).isEmpty()){
            offIds= filterOfferings(selectedFilters.get(application.Id),offIds);
            filteredOff.retainAll(offIds);
        }
        if (selectedFilters.containsKey(industry.Id) && !selectedFilters.get(industry.Id).isEmpty()){
            offIds= filterOfferings(selectedFilters.get(industry.Id),offIds); 
            filteredOff.retainAll(offIds);
        }
        if (selectedFilters.containsKey(region.Id) && !selectedFilters.get(region.Id).isEmpty()){
            offIds= PMP_SearchContextualFilterController.contFilterOfferings(selectedFilters.get(region.Id), offIds); 
            filteredOff.retainAll(offIds);
        }
        if (selectedFilters.containsKey(types.Id) && !selectedFilters.get(types.Id).isEmpty()){
            offIds= filterOfferings(selectedFilters.get(types.Id),offIds); 
            filteredOff.retainAll(offIds);
        }
        if (Schema.sObjectType.PMP_Partner_Offering__c.isAccessible() && selectedFilters.get('Partner')!=null && selectedFilters.get('Partner').size() > 0){   
            List<PMP_Partner_Offering__c> offList = [select id from PMP_Partner_Offering__c where id in :offerings and PMP_Company_Id__c in :selectedFilters.get('Partner')];
            List<String> offIdList = new List<String>();
            for (PMP_Partner_Offering__c off: offList){
                offIdList.add(off.Id);
            }
            offIds= offIdList;
            filteredOff.retainAll(offIds); 
        }
        
        //Kartik Chadha
        //To filter offerings based on selected specialty
        if(selectedFilters.get('Specialty_Offering')!=null && !selectedFilters.get('Specialty_Offering').isEmpty()){
            //Logic to filter offerings based on selected specialty
            offIds = PMP_SearchContextualFilterController.getOfferingSpecialtyResults(selectedFilters.get('Specialty_Offering'));                  
            filteredOff.retainAll(offIds);
            //system.debug('specialities select list :'+ selectedFilters.get('Specialty_Offering'));
        }
        
        
        //To filter offerings based on selected partner program
        if(selectedFilters.get('Partner_Program_Offering')!=null && !selectedFilters.get('Partner_Program_Offering').isEmpty()){
            //system.debug('option'+ selectedFilters.get('Partner_Program_Offering'));
            offIds =  PMP_SearchContextualFilterController.getOfferingPartnerProgramResults(selectedFilters.get('Partner_Program_Offering'));                 
            filteredOff.retainAll(offIds);  //Retains elements in filteredOff set that are contained in offIds list.
            //system.debug('Partner_Program_Offering select list :'+ selectedFilters.get('Partner_Program_Offering'));
        }
        
        //To get filtered results of offerings based on events
        //IPA2.0:TWC729-8114 Topics Removal/Event Removal
        /*if(selectedFilters.get('Marketplace_Event')!=null && !selectedFilters.get('Marketplace_Event').isEmpty()){
            
            offIds =  PMP_SearchEventDetailController.getEventOfferings(selectedFilters.get('Marketplace_Event'),offIds );                 
            filteredOff.retainAll(offIds);  
        }*/
        
        result.addAll(filteredOff); //Offering Ids
        return result;
    }
    
    /*****************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<String> getProductProgramResults (String option, List<String> offerings){
        List<Id> offIds=new List<Id>();
        List<PMP_Partner_Offering__c> OfferingDetailrecord = new List<PMP_Partner_Offering__c>();
        if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
            OfferingDetailrecord = [select id from PMP_Partner_Offering__c 
                                    where (PMP_Company_Id__r.PMP_Partner_Program_nm__c  includes (:option) OR PMP_Company_Id__r.PMP_Account_Specialty__c INCLUDES (:option.replace('_',' '))) and id in :offerings 
                                    and PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Partner_Offering_End_Dt__c >= TODAY 
                                    ORDER BY PMP_Offering_Status_Update_Dt__c DESC NULLS LAST];
        }
        
        for(PMP_Partner_Offering__c off : OfferingDetailrecord)
        {
            offIds.add(off.Id);  
        }
        
        return offIds;
    }
    
    public static Map<String,Boolean> isPreReleased(List<String> offeringIds){
        Map<String,Boolean> offIndMap = new Map<String,Boolean>();
        List<PMP_Partner_Offering_Specification__c> offSpecs = [SELECT PMP_Offering_Id__c,PMP_Specification_Value_Id__r.PMP_Spec_Pre_Release_Ind__c FROM PMP_Partner_Offering_Specification__c
                                                               WHERE PMP_Offering_Id__c IN :offeringIds AND PMP_Specification_Value_Id__c != NULL AND PMP_Specification_Value_Id__r.PMP_Spec_Pre_Release_Ind__c = true];
        for(PMP_Partner_Offering_Specification__c offSpec: offSpecs){
            offIndMap.put(offSpec.PMP_Offering_Id__c,offSpec.PMP_Specification_Value_Id__r.PMP_Spec_Pre_Release_Ind__c);
        }
        return offIndMap;
    }
        
    public static Map<String,Integer> getCount(List<String> offerings){ //4
        Map<String,Integer> countMap = new Map<String,Integer>();
        // System.debug('cat count bef'+ Limits.getQueryRows());
        List<AggregateResult> offCats = [select COUNT(PMP_Offering_Id__c)cnt, PMP_Category_Id__c from PMP_Partner_Offering_Category__c 
                                         where PMP_Offering_Id__c IN :offerings 
                                         and PMP_Category_Id__c !=null AND PMP_Category_Id__r.PMP_Active_Ind__c = true GROUP BY PMP_Category_Id__c ];
        for(AggregateResult offCat: offCats){
            countMap.put((String)offCat.get('PMP_Category_Id__c'),(Integer)offCat.get('cnt'));
        }
        // System.debug('cat count after'+ Limits.getQueryRows());
        //system.debug('countMap' + countMap);
        return countMap;
    }
    
    public class Product {
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String imageUrl { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public Partner partner { get; set; }
        @AuraEnabled public Map<String , List<Types>> attributes { get; set; }
        @AuraEnabled public Boolean featured { get; set; }
        @AuraEnabled public Boolean isContactPartnerVisible {get; set;}
        @AuraEnabled public String leadLangPreference {get; set;}
        @AuraEnabled public Boolean isGuest {get; set;}
        @AuraEnabled public Boolean prerelease { get; set; }
        @AuraEnabled public String prerelaseText { get; set; }
        @AuraEnabled public Boolean onlyVisibleToIntel { get; set; }
        @AuraEnabled public String autoOffId {get; set;} 
        @AuraEnabled public String categoryLabel {get;set;}
        @AuraEnabled public String compareCategoryId {get;set;}
        
        //2.0 Changes
        @AuraEnabled public String cardType { get; set; }
        @AuraEnabled public List<Attribute> partnerAttributes { get; set; }
        @AuraEnabled public String partnerName { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String partnerByLine { get; set; }
        @AuraEnabled public String partnerRole { get; set; }
        @AuraEnabled public String longDescription { get; set; }
        @AuraEnabled public Boolean eyebrow { get; set; }
        @AuraEnabled public String eyebrowTagline {get;set;}
        @AuraEnabled public List<String> categories {get;set;}
        //for cta button visibility
        @AuraEnabled public Boolean contactPartnerVisible {get; set;}
        @AuraEnabled public CategoryLevel categoryL1 {get; set;}
        @AuraEnabled public List<CategoryLevel> categoryL2 {get; set;} //TWC1824-260 - to handle multiple L2 subcategories
        @AuraEnabled public CategoryLevel categoryL3 {get; set;}

    }
    
    public class CategoryLevel{
                @AuraEnabled public String Id { get; set; }
                @AuraEnabled public String Name { get; set; }

    }
    
}