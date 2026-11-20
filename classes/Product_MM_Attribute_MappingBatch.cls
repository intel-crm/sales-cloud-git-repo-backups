/***************************************************************************************************************************************************************************************************
Apex Class Name:  Product_MM_Attribute_MappingBatch
Version     : 1.0 
Created Date: 07 July 2023
Function    : This Batch class updates the Product ID and Deactivation from Product Table to MM Attribute Mapping.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Divya S           		07/07/2023              Original Version

*************************************************************************************************************************************************************************************************/
public with sharing class Product_MM_Attribute_MappingBatch implements Database.Batchable<sObject>{
    public String ipaasLoadId;
    List<Product_MM_Attribute_Mapping__c> deactivationLst = new List<Product_MM_Attribute_Mapping__c>();
    List<Core_Log_Entry__c> captureLogEntry = new List<Core_Log_Entry__c>();
    List<Product_MM_Attribute_Mapping__c> updatedMMLst = new List<Product_MM_Attribute_Mapping__c>();
    
    public Product_MM_Attribute_MappingBatch(String ipaasId){
        this.ipaasLoadId = ipaasId;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String attributeLst = 'Select Id, L4_Product__c, L5_Product__c, Product_Status__c, IsActive__c, Level_1_EPM_ID__c, Level_2_EPM_ID__c, Level_3_EPM_ID__c, Level_4_EPM_ID__c, Level_5_EPM_ID__c,Unique_ID__c from Product_MM_Attribute_Mapping__c where'+' '+Label.Product_MM_Attribute_Query_Condition;
        return Database.getQueryLocator( attributeLst );
    }
    
    public void execute(Database.BatchableContext BC, List<Product_MM_Attribute_Mapping__c> mm_attributeLst){
        try{
            
            List<String> l4_epmLst = new List<String>();
            List<String> l5_epmLst = new List<String>();
            
            Map<String,Product_fields_mapping__mdt> mdtMapping = Product_Utility.getSalesConfigurationMap();
            for(Product_fields_mapping__mdt prdfm : mdtMapping.values()){
                if(prdfm.Level__c == '5' && prdfm.Active__c){
                    l5_epmLst.add(prdfm.Product_Type_EMP_Id__c); 
                }
                else if(prdfm.Level__c == '4' && prdfm.Active__c){
                    l4_epmLst.add(prdfm.Product_Type_EMP_Id__c); 
                }
            }
            Set<String> l4_epmIds = new Set<String>(l4_epmLst);
            Set<String> l5_epmIds = new Set<String>(l5_epmLst);
            Set<String> repeat_epmIds = new Set<String>(l4_epmLst);
            Set<String> repeat_l4_uniqueIds = new Set<String>();
            
            /*Logic to remove common EPM Ids in both L4 and L5 */ 
            repeat_epmIds.retainAll(l5_epmLst); //Get only common EPMIds in L4 and L5
            l4_epmIds.removeAll(l5_epmLst); //remove common EPMIds from L4 EPMIds list
            l5_epmIds.removeAll(l4_epmLst); //remove common EPMIds from L5 EPMIds list
            updatedMMLst=processMMAttributes(mm_attributeLst,l5_epmIds,l4_epmIds,repeat_epmIds,repeat_l4_uniqueIds);
            try{
                processUpdateResults(updatedMMLst);
            }
            catch(Exception e){
                captureLogEntry.add(new Core_Log_Entry__c(Core_Details__c = 'Exception='+ e.getMessage() + e.getStackTraceString() , Core_XID__c = ipaasLoadId, Core_Message__c = 'L4/L5 Products Update Error', Core_Severity__c = 'High',Core_Project__c='Product MM Attribute Mapping', Core_Origin__c='Product_MM_Attribute_MappingBatch', Core_When__c = System.now()));
            }
        }
        catch(Exception e){
            Product_Utility.createLogEntryAndNotifyUser('PRD MM Attribute Mapping=='+e.getMessage(),ipaasLoadId,'Product_MM_Attribute_MappingBatch',null,null);
        }
    }
    
    public static List<Product_MM_Attribute_Mapping__c> processMMAttributes(List<Product_MM_Attribute_Mapping__c> mm_attributeLst,Set<String> l5_epmIds,Set<String> l4_epmIds,Set<String> repeat_epmIds,Set<String> repeat_l4_uniqueIds) {
        Map<String,List<Product_MM_Attribute_Mapping__c>> uniqueIdsMap = new Map<String,List<Product_MM_Attribute_Mapping__c>>();
        List<String> product_uniqueIds = new List<String>();
        Map<String,String> product2Map = new Map<String,String>();
        for(Product_MM_Attribute_Mapping__c mmAttr : mm_attributeLst){
            String uniqueId;
            
            /*Extract Unique ID in the format of Product2 -- Remove MMID from the Unique ID*/
            if(mmAttr.Unique_ID__c != null){
                if(l5_epmIds.contains(mmAttr.Level_1_EPM_ID__c)){
                    uniqueId = mmAttr.Unique_ID__c.SubStringAfter(';');
                }
                else if(l4_epmIds.contains(mmAttr.Level_1_EPM_ID__c)){
                    uniqueId = mmAttr.Unique_ID__c.SubStringAfter(';').SubStringAfter(';');
                }
                else if(repeat_epmIds.contains(mmAttr.Level_1_EPM_ID__c)){
                    uniqueId = mmAttr.Unique_ID__c.SubStringAfter(';');
                    repeat_l4_uniqueIds.add(mmAttr.Unique_ID__c.SubStringAfter(';').SubStringAfter(';'));
                }
                
            }
            
            /*Unique ID Map with MM attributes values */
            if (uniqueIdsMap.containsKey(uniqueId)) {
                uniqueIdsMap.get(uniqueId).add(mmAttr);
            } 
            else{
                uniqueIdsMap.put(uniqueId, new List<Product_MM_Attribute_Mapping__c> { mmAttr });
            }
        }//END FOR
        for (String str : uniqueIdsMap.keySet()) {
            product_uniqueIds.add(str);
        }
        product_uniqueIds.addAll(repeat_l4_uniqueIds);
        for(Product2 p : [SELECT Id, Core_Unique_ID__c, Core_Product_Type__c, Core_Product_Type_EPM_ID__c, Core_Product_Group_EPM_ID__c, Core_Product_Name_EPM_ID__c, IsActive 
                          FROM Product2 WHERE Core_Hierarchy_ID__c = :Product_Staging_StaticConstants.vphId AND IsActive = true AND 
                          Core_Product_Org__c = :Product_Staging_StaticConstants.sales AND Core_Unique_ID__c IN :product_uniqueIds]){
                              product2Map.put(p.Core_Unique_ID__c,p.Id);
                          }
        List<Product_MM_Attribute_Mapping__c> updateMMLst=updateMappingProductFields(uniqueIdsMap, product2Map, l5_epmIds, l4_epmIds, repeat_epmIds);
        return updateMMLst;
    }
    
    public static List<Product_MM_Attribute_Mapping__c> updateMappingProductFields(Map<String,List<Product_MM_Attribute_Mapping__c>> uniqueIdsMap, Map<String, String> product2Map, Set<String> l5_epmIds, Set<String> l4_epmIds, Set<String> repeat_epmIds) {
        List<Product_MM_Attribute_Mapping__c> updateMMList = new List<Product_MM_Attribute_Mapping__c>();
        for(String uniqueKey : uniqueIdsMap.keyset()){
            for(Product_MM_Attribute_Mapping__c mmprd :uniqueIdsMap.get(uniqueKey)){
                if (product2Map.get(uniqueKey) != null) {
                    if (l5_epmIds.contains(mmprd.Level_1_EPM_ID__c)) {
                        mmprd.L5_Product__c = product2Map.get(uniqueKey);
                    } else if (l4_epmIds.contains(mmprd.Level_1_EPM_ID__c)) {
                        mmprd.L4_Product__c = product2Map.get(uniqueKey);
                    } else if (repeat_epmIds.contains(mmprd.Level_1_EPM_ID__c)) {
                        mmprd.L5_Product__c = product2Map.get(uniqueKey);
                        mmprd.L4_Product__c = product2Map.get(uniqueKey.substringAfter(';')) != null ? product2Map.get(uniqueKey.substringAfter(';')) : null;
                    }
                }else if (repeat_epmIds.contains(mmprd.Level_1_EPM_ID__c) && product2Map.get(uniqueKey) == null && product2Map.containsKey(uniqueKey.substringAfter(';'))) {
                    mmprd.L4_Product__c = product2Map.get(uniqueKey.substringAfter(';'));
                }
                updateMMList.add(mmprd);
            }
        }
        return updateMMList;
    }
    
    public void processUpdateResults(List<Product_MM_Attribute_Mapping__c> updateMMLst) {
        if(!updateMMLst.isEmpty()){
            Database.SaveResult [] results = Database.update(updateMMLst, false);
            for(Database.SaveResult sr : results ) {
                if(!sr.isSuccess()){
                    captureLogEntry.add(new Core_Log_Entry__c(Core_Details__c = 'Exception='+ sr.getErrors()[0].getMessage(), Core_XID__c = ipaasLoadId, Core_Message__c = 'L4/L5 Products Update Error', Core_Severity__c = 'High',Core_Project__c='Product MM Attribute Mapping', Core_Origin__c='Product_MM_Attribute_MappingBatch', Core_When__c = System.now()));
                }
            }
        }//END--IF
    }
    
    
    public void finish(Database.BatchableContext BC){
        List<Product_MM_Attribute_Mapping__c> mmLst = new List<Product_MM_Attribute_Mapping__c>();
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
        if((mapFunctionalityNameTriggerExecution.containsKey('ExecuteProduct_DeactivationAndLogEntry') && mapFunctionalityNameTriggerExecution.get('ExecuteProduct_DeactivationAndLogEntry').Core_Active__c)){
            mmLst = [Select Id, IsActive__c,iPaaS_Load_ID__c from Product_MM_Attribute_Mapping__c where iPaaS_Load_ID__c != :ipaasLoadId and IsActive__c = true limit 45000];
        }else{
            // Deactivate MM records where linked Product2 records are inactive
            mmLst = [SELECT Id, IsActive__c, L4_Product__c, L5_Product__c
                     FROM Product_MM_Attribute_Mapping__c
                     WHERE IsActive__c = true
                     AND (
                         (L5_Product__c != null AND L5_Product__r.IsActive = false)
                         OR
                         (L4_Product__c != null AND L4_Product__r.IsActive = false)
                     )
                     LIMIT 9995];
        }
        if (!mmLst.isEmpty()) {
            for(Product_MM_Attribute_Mapping__c prd : mmLst){
                prd.IsActive__c = false;
                prd.L4_Product__c = null;
                prd.L5_Product__c = null;
                deactivationLst.add(prd);
            }
        }
        try{
            productMMDeactivation(deactivationLst);
            
        }
        catch(Exception e){
            captureLogEntry.add(new Core_Log_Entry__c(Core_Details__c = 'Exception==    '+ e.getMessage() + e.getStackTraceString() , Core_Message__c = 'iPaaS ID Deactivation', Core_Severity__c = 'High',Core_Project__c='DDR', Core_Origin__c='Product_MM_Attribute_MappingBatch', Core_When__c = System.now()));
        }
        
        if(!captureLogEntry.isEmpty()){
            insert captureLogEntry;
        }
    }
    
    
    public static void productMMDeactivation(List<Product_MM_Attribute_Mapping__c> deactivationList){
        if(!deactivationList.isEmpty() && deactivationList.size() < 9995){
            update deactivationList;
        }else if(!deactivationList.isEmpty() && deactivationList.size() >= 9995){
            /*To Avoid too many DML rows 10001 error - Remove the records from the end which will be deactivated in the next load. */
            Integer count=deactivationList.size()-1;
            for(integer i=count;i>=9995;i--){
                deactivationList.remove(i);
            }
            update deactivationList;
        }        
    }
    
}