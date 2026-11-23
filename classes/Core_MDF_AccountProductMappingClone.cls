public class Core_MDF_AccountProductMappingClone {
    /*
     * Method Name - getProducts
     * Desc - To get products
     */
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        List<Product2> productList = new List<Product2>();
        try {
            productList = [ SELECT Id, Core_Product_Family__c, Name 
                            FROM Product2 
                           WHERE isactive = true AND Core_End_of_Intel_Service_Flag__c = false AND Core_Hierarchy_ID__c = '43' 
                           AND (Core_Product_Type__c = 'Chipsets' OR Core_Product_Type__c = 'Memory and Storage' OR Core_Product_Type__c = 'Graphics'
                            OR (Core_Product_Type__c = 'Processors' and (Core_Product_Status__c like '%AC%' OR Core_Product_Status__c LIKE '%PA%' OR Core_Product_Status__c LIKE '%EN%'))) ORDER BY Core_Product_Family__c, Name];
        }
        catch(Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
            final String errMsg = 'Exception: '+exp.getMessage();
            throw new AuraHandledException(errMsg);
        }
        return productList;
    }
    
    /*
     * Method Name - createUpdateAccountAndProductMappingRecords
     * Desc - To create/update Account Product Mapping
     */
    @AuraEnabled
    //public static void createUpdateAccountAndProductMappingRecords(Map<String,List<String>> accountProductIdMap) {
    public static void createUpdateAccountAndProductMappingRecords(String accountId,List<String> productIds,String program,Boolean isAllAccount) {
        string sQuery = 'SELECT Id, Core_MDF_Account__c, Core_MDF_Product__c, Core_MDF_Active_ind__c, Core_MDF_Program_Account_Map__c,Core_MDF_All_Account_Ind__c ' +
            'FROM Core_MDF_Account_Product_Mapping__c '+
            'WHERE Core_MDF_Program_Account_Map__c =: program '+
            'AND Core_MDF_Product__c IN :productIds ' +
            'AND ((Core_MDF_All_Account_Ind__c = true and Core_MDF_Account__c = null) ' + 
            'OR (Core_MDF_All_Account_Ind__c = false and Core_MDF_Account__c !=null))';
        Map<String, Core_MDF_Account_Product_Mapping__c> existingAccProdMap = new Map<String, Core_MDF_Account_Product_Mapping__c>();
        List<Core_MDF_Account_Product_Mapping__c> apmList = Database.Query(sQuery);
        for(Core_MDF_Account_Product_Mapping__c apm : apmList){
            String key = apm.Core_MDF_Program_Account_Map__c + apm.Core_MDF_Product__c ;
            key = apm.Core_MDF_Account__c  !=null? key +apm.Core_MDF_Account__c + 'NO': key +'Yes';
            existingAccProdMap.put(key,apm);
        }    
        Map<String, List<Core_MDF_Account_Product_Mapping__c>> oldAccProdMap = new Map<String, List<Core_MDF_Account_Product_Mapping__c>>();
        if(isAllAccount == true){
            system.debug('<<Enter50>>');
            for(Id productId : productIds){
                String key = program + productId + 'Yes';
                system.debug('existingAccProdMap'+existingAccProdMap);
                if(existingAccProdMap.containsKey(key)){
                    Core_MDF_Account_Product_Mapping__c existingapm = existingAccProdMap.get(key);
                    Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
                    apm.Id = existingapm.Id;
                    apm.Core_MDF_Product__c = existingapm.Core_MDF_Product__c;
                    apm.Core_MDF_Active_ind__c = false;      
                    if(!oldAccProdMap.containsKey(key)){                    
                        oldAccProdMap.put(key, new List<Core_MDF_Account_Product_Mapping__c>());
                    }
                    oldAccProdMap.get(key).add(apm);
                }
            }
        }     
        else{
            for(Id productId : productIds){
                String key = program + productId + accountId + 'No';
                if(existingAccProdMap.containsKey(key)){
                    Core_MDF_Account_Product_Mapping__c existingapm = existingAccProdMap.get(key);
                    Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
                    apm.Id = existingapm.Id;
                    apm.Core_MDF_Account__c = existingapm.Core_MDF_Account__c;
                    apm.Core_MDF_Product__c = existingapm.Core_MDF_Product__c;
                    apm.Core_MDF_Active_ind__c = false;      
                    if(!oldAccProdMap.containsKey(key)){                    
                        oldAccProdMap.put(key, new List<Core_MDF_Account_Product_Mapping__c>());
                    }
                    oldAccProdMap.get(key).add(apm);
                }
            }
        }        
        List<Core_MDF_Account_Product_Mapping__c> upsertList = new List<Core_MDF_Account_Product_Mapping__c>();
        for(Id productId : productIds){
            String key = program + productId + 'Yes' ;
            String key1 = program + productId + accountId + 'No';
            //key = accountId  !=null? key +accountId  + 'NO': key +'Yes';
            if(oldAccProdMap.containsKey(key) ||oldAccProdMap.containsKey(key1)){
                for(List<Core_MDF_Account_Product_Mapping__c> oldAPM : oldAccProdMap.values()){
                    for(Core_MDF_Account_Product_Mapping__c accProdMapping : oldAPM){
                        Core_MDF_Account_Product_Mapping__c accProdMapping1 = new Core_MDF_Account_Product_Mapping__c();
                        accProdMapping1.Id = accProdMapping.Id;
                        accProdMapping1.Core_MDF_Account__c = accProdMapping.Core_MDF_Account__c;
                        accProdMapping1.Core_MDF_Product__c = productId;    
                        accProdMapping1.Core_MDF_All_Account_Ind__c = accProdMapping.Core_MDF_All_Account_Ind__c;
                        accProdMapping1.Core_MDF_Active_ind__c = true;
                        accProdMapping1.Core_MDF_Program_Account_Map__c = program;
                        upsertList.add(accProdMapping1);
                    }
                }
            }
            else{
                Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
                apm.Core_MDF_Account__c = accountId;                                
                apm.Core_MDF_All_Account_Ind__c = isAllAccount;                                
                apm.Core_MDF_Product__c = productId;
                apm.Core_MDF_Active_ind__c = true;
                apm.Core_MDF_Program_Account_Map__c = program;
                upsertList.add(apm);
            }
          }
        
        if(!upsertList.isEmpty()){
            upsert upsertList;
        }
    }
    
    /*
     * Method Name - getAccountProductMapping
     * Desc - To get Account Product Mappings
	 */
    @AuraEnabled
    public static Map<Id, List<Core_MDF_Account_Product_Mapping__c>> getAccountProductMapping(List<String> accountIds, String program) {
        Map<Id, List<Core_MDF_Account_Product_Mapping__c>> existingAccProdMap = new Map<Id, List<Core_MDF_Account_Product_Mapping__c>>();
        try {
            for(Core_MDF_Account_Product_Mapping__c apm : [SELECT Id, Core_MDF_Account__c, Core_MDF_Product__c  FROM Core_MDF_Account_Product_Mapping__c WHERE Core_MDF_Active_ind__c = true AND Core_MDF_Account__c IN :accountIds AND Core_MDF_Program_Account_Map__c = :program]) {
                if(existingAccProdMap.containsKey(apm.Core_MDF_Account__c)) {
                    existingAccProdMap.get(apm.Core_MDF_Account__c).add(apm);
                } else {
                    existingAccProdMap.put(apm.Core_MDF_Account__c, new List<Core_MDF_Account_Product_Mapping__c>{apm});
                }
            }
        }
        catch(Exception exp) {
			Core_MDF_CCP_UtilityClass.logError(exp);
            final String errMsg = 'Exception: '+exp.getMessage();
            throw new AuraHandledException(errMsg);           
        }
        system.debug('existingAccProdMap---'+ existingAccProdMap);
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
}