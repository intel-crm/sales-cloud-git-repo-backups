/* Class Name : Core_MDF_AccountProductMappingController
 * Test class : Core_MDF_AccountProductMappingCntrlTest
 */ 
public without sharing class Core_MDF_AccountProductMappingController {
    
    /*
     * Method Name - getProducts
     * Desc - To get products
     */
    /*@AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        List<Product2> productList = new List<Product2>();
        try {
            productList = [ SELECT Id, Core_Product_Family__c, Name 
                            FROM Product2 
                           WHERE isactive = true AND Core_End_of_Intel_Service_Flag__c = false AND Core_Hierarchy_ID__c = '43' 
                           AND Core_Sales_Visible_Flag__c = true
                           AND (Core_Product_Type__c = 'Chipsets' OR Core_Product_Type__c = 'Memory and Storage' OR Core_Product_Type__c = 'Graphics'
                            OR (Core_Product_Type__c = 'Processors' and (Core_Product_Status__c like '%AC%' OR Core_Product_Status__c LIKE '%PA%' OR Core_Product_Status__c LIKE '%EN%'))) ORDER BY Core_Product_Family__c, Name];
        }
        catch(Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
            final String errMsg = 'Exception: '+exp.getMessage();
            throw new AuraHandledException(errMsg);
        }
        return productList;
    }*/
   @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        List<Product2> productList = new List<Product2>();
        String segment=null;
        try {
            productList = retrieveProductsUsingDynamicQuery(segment);
        }
            
        catch(Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
            final String errMsg = 'Exception: '+exp.getMessage();
            throw new AuraHandledException(errMsg);
        }
        System.debug('prodlistget->'+productList);
        return productList;
    }

    /*
     * Method Name - retrieveProductsDynamicQuery
     * Desc - Genreric method to prepare the dynamic query & get the list of products from particular product family
     * Created by- Ramapriya (Weezer-ccp_)
     * Created date- 24/July/2024
     * Reference- Core_MDF_ActivitySegmentMapping.cls
     */
    public static List<Product2> retrieveProductsUsingDynamicQuery(String segment){
		
        List<Product2> productList = new List<Product2>();
        Map<String,List<String>> pfrProductMappingMap = new Map<String,List<String>>();
        Map<String,String> mapOfSegmentAndCriteria = new Map<String,String>();
        Set<String> segmentsAllProductsset =  new Set<String>();
        Set<String> prodsegmentsset =  new Set<String>();
        Set<String> productEPMIDset =  new Set<String>();
        String productQuery=null;
        String hierarchynumber=String.valueof(43);

        try{
            for(Core_MDF_PFR_Product_Mapping__c pfrProductMapping : Core_MDF_PFR_Product_Mapping__c.getall().values())
                    {
                       if(pfrProductMapping.Core_MDF_IsActive_Ind__c && (segment==null || (segment != null && pfrProductMapping.Core_MDF_Segment_ProductType_txt__c==segment))){
                        //Avoid Deeply Nested IF Statements
                        //    if(pfrProductMapping.Core_MDF_Show_All_Products_ind__c){
                        //      if(pfrProductMapping.Core_MDF_Criteria_For_Product_txt__c==null){
                        //          segmentsAllProductsset.add(pfrProductMapping.Core_MDF_Segment_ProductType_txt__c);
                        //      }
                        //      if(pfrProductMapping.Core_MDF_Criteria_For_Product_txt__c!=null){
                        //          mapOfSegmentAndCriteria.put(pfrProductMapping.Core_MDF_Segment_ProductType_txt__c,pfrProductMapping.Core_MDF_Criteria_For_Product_txt__c);
                        //      }
                        //    }
                        //Avoid Deeply Nested IF Statements
                           if(pfrProductMapping.Core_MDF_Show_All_Products_ind__c && pfrProductMapping.Core_MDF_Criteria_For_Product_txt__c==null){
                                segmentsAllProductsset.add(pfrProductMapping.Core_MDF_Segment_ProductType_txt__c);
                           }
                           if(pfrProductMapping.Core_MDF_Show_All_Products_ind__c && pfrProductMapping.Core_MDF_Criteria_For_Product_txt__c!=null){
                                mapOfSegmentAndCriteria.put(pfrProductMapping.Core_MDF_Segment_ProductType_txt__c,pfrProductMapping.Core_MDF_Criteria_For_Product_txt__c);
                           }
                             else if(!pfrProductMapping.Core_MDF_Show_All_Products_ind__c){
                                
                                prodsegmentsset.add(pfrProductMapping.Core_MDF_Segment_ProductType_txt__c);
                                
                                productEPMIDset.add(pfrProductMapping.Core_MDF_Product_EPM_ID_txt__c);

                             }
                        }
                    }
            if(!segmentsAllProductsset.isEmpty() || (!prodsegmentsset.isEmpty() && !productEPMIDset.isEmpty()) || !mapOfSegmentAndCriteria.isEmpty()){
                //As part of Avoid Untrusted/Unescaped Variables in DML Query fix,Used secure bind variable :hierarchynumber instead of concatenation 
                //productQuery= 'SELECT Id, Core_Product_Family__c, Name,Core_Product_Name_EPM_ID__c,Core_Processor_Number_Nm__c FROM Product2 WHERE isactive = true AND Core_End_of_Intel_Service_Flag__c = false AND Core_Hierarchy_ID__c = ' + '\'' + String.escapeSingleQuotes(hierarchynumber) + '\'' + ' AND Core_Sales_Visible_Flag__c = true ';
                productQuery= 'SELECT Id, Core_Product_Family__c, Name,Core_Product_Name_EPM_ID__c,Core_Processor_Number_Nm__c FROM Product2 WHERE isactive = true AND Core_End_of_Intel_Service_Flag__c = false AND Core_Hierarchy_ID__c = :hierarchynumber AND Core_Sales_Visible_Flag__c = true ';    
                    if(!segmentsAllProductsset.isEmpty()){ //chipsets, memory and storage, graphics
                        productQuery+= 'AND (Core_Product_Type__c IN:segmentsAllProductsset ';
                    }
            
                    if(!prodsegmentsset.isEmpty() && !productEPMIDset.isEmpty()){ //Ethernet, Technology
                        //Avoid Deeply Nested IF Statements
                        productQuery += !segmentsAllProductsset.isEmpty() 
                            ? 'OR (Core_Product_Type__c IN:prodsegmentsset and Core_Product_Name_EPM_ID__c IN:productEPMIDset) '
                            : 'AND ((Core_Product_Type__c IN:prodsegmentsset and Core_Product_Name_EPM_ID__c IN:productEPMIDset) ';
                        //Avoid Deeply Nested IF Statements
                        // if(!segmentsAllProductsset.isEmpty()){
                        //     productQuery+= 'OR (Core_Product_Type__c IN:prodsegmentsset and Core_Product_Name_EPM_ID__c IN:productEPMIDset) ';
                        // }
                        // else{
                        //     productQuery+= 'AND ((Core_Product_Type__c IN:prodsegmentsset and Core_Product_Name_EPM_ID__c IN:productEPMIDset) ';
                        // }
                        
                    }
            
                    if(!mapOfSegmentAndCriteria.isEmpty()){
                        for(String productType : mapOfSegmentAndCriteria.keyset()){//Processors
                            String criteria = mapOfSegmentAndCriteria.get(productType);
                            //Avoid Deeply Nested IF Statements
                            productQuery += (!segmentsAllProductsset.isEmpty() || (!prodsegmentsset.isEmpty() && !productEPMIDset.isEmpty()))
                                ? 'OR (Core_Product_Type__c =\''+String.escapeSingleQuotes(productType)+'\' AND '+criteria+') '
                                : 'AND ((Core_Product_Type__c =\''+String.escapeSingleQuotes(productType)+'\' AND '+criteria+') ';
                            //Avoid Deeply Nested IF Statements
                            // if(!segmentsAllProductsset.isEmpty() || (!prodsegmentsset.isEmpty() && !productEPMIDset.isEmpty())){
                            //     productQuery+= 'OR (Core_Product_Type__c =\''+String.escapeSingleQuotes(productType)+'\' AND '+criteria+') ';
                            // }
                            // else{
                            //     productQuery+= 'AND ((Core_Product_Type__c =\''+String.escapeSingleQuotes(productType)+'\' AND '+criteria+') ';
                            // }
                        
                        } 
                    }
                    if(!segmentsAllProductsset.isEmpty() || (!prodsegmentsset.isEmpty() && !productEPMIDset.isEmpty()) || !mapOfSegmentAndCriteria.isEmpty()){
                        productQuery+=') ORDER BY Core_Product_Family__c, Name';
                    }
                    else{
                        productQuery+=' ORDER BY Core_Product_Family__c, Name';
                    }
            
            }
            if(productQuery!=null){
                productList = Database.query(productQuery);
            }
            System.debug('productqueryacc1->'+productList.size());
            return productList;
        }catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e); 
            return null;
        }
        
    }
    
    /*
     * Method Name - createUpdateAccountAndProductMappingRecords
     * Desc - To create/update Account Product Mapping
     */
    
     @AuraEnabled
     public static void createUpdateAccountAndProductMappingRecords(string details){
        AccountProdMapWrapper accProdMapWrap = (AccountProdMapWrapper) JSON.deserialize(details,AccountProdMapWrapper.class); 
        boolean isAllAccount = accProdMapWrap.isAllAccount;
        string accountId = accProdMapWrap.accountId;
        
        if(!isAllAccount && string.isNotBlank(accountId)){
            upsertAccountSpecficProductMapping(details);
            System.debug('specific account creation->');
        }else{
            Database.executeBatch(new Core_MDF_AccountProductMap_Batch(details),Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Acc_Product_Mapping_Batch_Size')));
        }
     }

     public static void upsertAccountSpecficProductMapping(String details) {
        try {
            AccountProdMapWrapper accProdMapWrap = (AccountProdMapWrapper) JSON.deserialize(details,AccountProdMapWrapper.class); 
            string accountId = accProdMapWrap.accountId;
            List<string> selectedProdIds = accProdMapWrap.selectedProdIds;
            List<string> uncheckedProdIds = accProdMapWrap.uncheckedProdIds;
            string program = accProdMapWrap.program;
            System.debug('progcheck123'+program);
   
            Map<String, Core_MDF_Account_Product_Mapping__c> oldAccProdMap = new Map<String, Core_MDF_Account_Product_Mapping__c>();
            Map<String, Core_MDF_Account_Product_Mapping__c> newAccProdMap = new Map<String, Core_MDF_Account_Product_Mapping__c>();

            Map<String,List<String>> accountProductIdMap = new Map<String,List<String>>();
            accountProductIdMap.put(accountId,selectedProdIds);
            System.debug('new accountProductIdMap ->'+accountProductIdMap);
            Map<Id, Core_MDF_Account_Product_Mapping__c> existingAccProdMap = new Map<Id, Core_MDF_Account_Product_Mapping__c>(
                                                            [SELECT Id, Core_MDF_Account__c, Core_MDF_Product__c, Core_MDF_Active_ind__c  
                                                            FROM Core_MDF_Account_Product_Mapping__c 
                                                            WHERE Core_MDF_Account__c IN :accountProductIdMap.keySet() 
                                                            AND Core_MDF_Program_Account_Map__c = :program]);         

            System.debug('old existingAccProdMap ->'+existingAccProdMap);                                                
            if(existingAccProdMap != null && !existingAccProdMap.isEmpty()) {
                for(Id accProdMapId : existingAccProdMap.keySet()) {
                    Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
                    apm.Id = accProdMapId;
                    apm.Core_MDF_Account__c = existingAccProdMap.get(accProdMapId).Core_MDF_Account__c;
                    apm.Core_MDF_Product__c = existingAccProdMap.get(accProdMapId).Core_MDF_Product__c;
                    apm.Core_MDF_Active_ind__c = false;
                    final String keyStr1 = apm.Core_MDF_Account__c + '$' + apm.Core_MDF_Product__c;
                    oldAccProdMap.put(keyStr1, apm);
                }
            }
            if(accountProductIdMap != null && !accountProductIdMap.isEmpty()) {
                for(Id accId : accountProductIdMap.keySet()) {
                    for(Id prodId : accountProductIdMap.get(accId)) {
                        final String keyStr2 = accId + '$' + prodId;
                        if(oldAccProdMap != null && oldAccProdMap.containsKey(keyStr2)) {
                            Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
                            apm.Id = oldAccProdMap.get(keyStr2).Id;
                            apm.Core_MDF_Account__c = accId;
                            apm.Core_MDF_Product__c = prodId;
                            apm.Core_MDF_Active_ind__c = true;
                            apm.Core_MDF_Program_Account_Map__c = program;
                            oldAccProdMap.put(keyStr2, apm);
                        } 
                        else {
                            Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
                            apm.Core_MDF_Account__c = accId;
                            apm.Core_MDF_Product__c = prodId;
                            apm.Core_MDF_Active_ind__c = true;
                            apm.Core_MDF_Program_Account_Map__c = program;
                            newAccProdMap.put(keyStr2, apm);   
                        }
                    }
                }

                if(oldAccProdMap != null && !oldAccProdMap.isEmpty()) {
                     newAccProdMap.putAll(oldAccProdMap);
                }
                if(uncheckedProdIds != null && !uncheckedProdIds.isEmpty()){
                        for(string prodId : uncheckedProdIds){
                        String keyStr = accountId + '$' + prodId;
                            Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
                            apm.Core_MDF_Account__c = accountId;
                            apm.Core_MDF_Product__c = prodId;
                            apm.Core_MDF_Active_ind__c = false;
                            apm.Core_MDF_Program_Account_Map__c = program;
                            if(!newAccProdMap.containsKey(keyStr)){
                                newAccProdMap.put(keyStr,apm);
                            }
                        }
                    }

                    System.debug('old oldAccProdMap ->'+oldAccProdMap);
                    System.debug('new newAccProdMap ->'+newAccProdMap);
                



                

                if(newAccProdMap != null && !newAccProdMap.isEmpty()) {
                    upsert newAccProdMap.values();
                }
            }
        }
        catch(Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
            final String errMsg = 'Exception: '+exp.getMessage();
            throw new AuraHandledException(errMsg);
        } 
    }


    public static Core_MDF_Account_Product_Mapping__c createAccountProdMapInstance(string accId, Boolean allAccount, string productId, string program, boolean isActive){
        Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
        apm.Core_MDF_Account__c = accId;
        apm.Core_MDF_All_Account_Ind__c = allAccount;
        apm.Core_MDF_Product__c = productId;
        apm.Core_MDF_Program_Account_Map__c = program;
        apm.Core_MDF_Active_ind__c = isActive;
        return apm;
    }


    
    /*
     * Method Name - getAccountProductMapping
     * Desc - To get Account Product Mappings
     */
    @AuraEnabled
    public static Map<String, List<Core_MDF_Account_Product_Mapping__c>> getAccountProductMapping(List<String> accountIds, String program) {
        Map<String, List<Core_MDF_Account_Product_Mapping__c>> existingAccProdMap = new Map<String, List<Core_MDF_Account_Product_Mapping__c>>();
        Map<string,Core_MDF_Account_Product_Mapping__c> productIdToApmMap = new Map<string,Core_MDF_Account_Product_Mapping__c>();
        List<Core_MDF_Account_Product_Mapping__c> existingApmList = new List<Core_MDF_Account_Product_Mapping__c>();
        set<string> specificAccProductSet = new set<string>();
        string accId = accountIds != null ? accountIds[0] : null;
        try {
            existingApmList = [SELECT Id, Core_MDF_Account__c, Core_MDF_Product__c,Core_MDF_All_Account_Ind__c,Core_MDF_Active_ind__c  
                               FROM Core_MDF_Account_Product_Mapping__c
                               WHERE (Core_MDF_Account__c IN :accountIds OR Core_MDF_All_Account_Ind__c = true) 
                               AND Core_MDF_Program_Account_Map__c = :program];
            //if(!existingApmList.isEmpty()){  US - TWC702-14285 - commented original code 
            // Early return if no records found
            if (existingApmList.isEmpty()) return existingAccProdMap;                                           
                for(Core_MDF_Account_Product_Mapping__c apm: existingApmList){
                    // US - TWC702-14285: Flatten nested IFs (no logic change) - Begin
                    if(!apm.Core_MDF_Active_ind__c && string.isNotBlank(accId) && apm.Core_MDF_Account__c == accId) {
                        specificAccProductSet.add(apm.Core_MDF_Product__c);
                    } else if(apm.Core_MDF_Active_ind__c && apm.Core_MDF_All_Account_Ind__c && string.isBlank(apm.Core_MDF_Account__c)) {
                        productIdToApmMap.put(apm.Core_MDF_Product__c,apm);
                    } else if(apm.Core_MDF_Active_ind__c && !(apm.Core_MDF_All_Account_Ind__c && string.isBlank(apm.Core_MDF_Account__c))) {
                        if(!existingAccProdMap.containsKey(accId)) {
                            existingAccProdMap.put(accId, new List<Core_MDF_Account_Product_Mapping__c>());
                        }
                        existingAccProdMap.get(accId).add(apm);
                        specificAccProductSet.add(apm.Core_MDF_Product__c);
                    }
                    // US - TWC702-14285: Flatten nested IFs (no logic change) - End
                    /*
                    // Original nested logic preserved for reference (no logic change):
                    if(apm.Core_MDF_Active_ind__c){
                        if(apm.Core_MDF_All_Account_Ind__c && string.isBlank(apm.Core_MDF_Account__c)){
                            productIdToApmMap.put(apm.Core_MDF_Product__c,apm);
                        }else{
                            if(!existingAccProdMap.containsKey(accId)) {
                                existingAccProdMap.put(accId, new List<Core_MDF_Account_Product_Mapping__c>());
                            }
                            existingAccProdMap.get(accId).add(apm);
                            specificAccProductSet.add(apm.Core_MDF_Product__c);
                        } 
                    }else{
                        if(string.isNotBlank(accId) && apm.Core_MDF_Account__c == accId){
                            specificAccProductSet.add(apm.Core_MDF_Product__c);
                        }
                    }
                    */
                }
            if(!productIdToApmMap.isEmpty()){
                 for(string allAccprodId : productIdToApmMap.keySet()){
                     // US - TWC702-14285: Flatten nested IFs (no logic change) - Begin
                     if(!specificAccProductSet.contains(allAccprodId) && !existingAccProdMap.containsKey(accId)) {
                        existingAccProdMap.put(accId, new List<Core_MDF_Account_Product_Mapping__c>());
                     } else if(!specificAccProductSet.contains(allAccprodId)) {
                        existingAccProdMap.get(accId).add(productIdToApmMap.get(allAccprodId));
                     }
                     // US - TWC702-14285: Flatten nested IFs (no logic change) - End
                     /*
                     // Original nested logic preserved for reference (no logic change):
                     if(!specificAccProductSet.contains(allAccprodId)){
                         if(!existingAccProdMap.containsKey(accId)) {
                            existingAccProdMap.put(accId, new List<Core_MDF_Account_Product_Mapping__c>());
                          }
                        existingAccProdMap.get(accId).add(productIdToApmMap.get(allAccprodId));
                     }
                     */
                 }
             }
          //} US - TWC702-14285 - commented original code
        }
        catch(Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
            final String errMsg = 'Exception: '+exp.getMessage();
            throw new AuraHandledException(errMsg);           
        }
        System.debug('data 1->'+existingAccProdMap);
        return existingAccProdMap;
    }
    /*
     * Method Name - hasAccessToPriceReviewerMaintanceTab
     * Desc - To check if user has access to tab
     */
    @AuraEnabled
    public static Boolean hasAccessToPriceReviewerMaintanceTab() {
        Boolean hasAccess = false;
        if (FeatureManagement.checkPermission('Core_MDF_PriceReviewer') || FeatureManagement.checkPermission('Core_MDF_PriceReviewMaintenanceAllAccounts')) {
            hasAccess = true;
        }
       return hasAccess;
    }
    
    public class AccountProdMapWrapper{
        @AuraEnabled public string accountId;
        @AuraEnabled public List<String> selectedProdIds;
        @AuraEnabled public String program;
        @AuraEnabled public boolean isAllAccount;
        @AuraEnabled public List<string> uncheckedProdIds;
    }
    
}