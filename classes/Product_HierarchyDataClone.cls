public with sharing class Product_HierarchyDataClone {

    @AuraEnabled(cacheable=true)
    public static WrapperClass getProducts(String HierarchyValue, String isActive) {
        WrapperClass wc= new WrapperClass();
        Boolean activeBoolValue;
        try{
            String query ='select Id,Core_OPN__c,Core_Code_Name_EPM_ID__c,Core_Code_Name__c,Core_Platform_Config_EPM_ID__c,Core_Platform_Config__c,Core_Platform_EPM_ID__c,Core_Platform_Name__c,Core_Product_Name_EPM_ID__c,Name,Core_Product_Group_EPM_ID__c, Core_Product_Group__c,Core_Product_Series_EPM_ID__c,Core_Product_Series__c,Core_Product_Family_EPM_ID__c,Core_Product_Family__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c, Core_Unique_ID__c,IsActive,Core_Sales_Visible_Flag__c,Core_IQR_Visible__c FROM Product2 where  Core_Hierarchy_ID__c=:HierarchyValue and Core_Product_Org__c =\'Sales\' and Core_Unique_ID__c!=null';
            if(isActive=='true'){
                activeBoolValue=true;
                query +=' and isActive=:activeBoolValue';
            }
            else if(isActive=='false') {
                activeBoolValue=false;
                query +=' and isActive=:activeBoolValue';
            }
            List<Product2> productList= new List<product2>();
            WrapperClass wc1= new WrapperClass();
        
                productList= Database.query(query);
                wc.prodData=productList;  
                wc1=createMap(productList);
            
            wc.epmIdtoNameMap=wc1.epmIdtoNameMap;
            wc.prodIdtoEpmMap=wc1.prodIdtoEpmMap;
        }
        catch(Exception ex){}
        return wc;
    }
    
    public static WrapperClass createMap(List<Product2> productList){
        WrapperClass wc= new WrapperClass();
        Map<String,String> epmIdtoNameMap = new Map<String,String>();
        Map<String,String> prodIdtoEpmMap = new Map<String,String>();
        for(Product2 prod:productList){
            if(prod.Core_Product_Name_EPM_ID__c!=null){
                epmIdtoNameMap.put(prod.Core_Product_Name_EPM_ID__c,prod.Name);
                prodIdtoEpmMap.put(prod.Id,prod.Core_Product_Name_EPM_ID__c);
            }
            if(prod.Core_Product_Group_EPM_ID__c!=null){
                epmIdtoNameMap.put(prod.Core_Product_Group_EPM_ID__c, prod.Core_Product_Group__c);
            }
            if(prod.Core_Product_Series_EPM_ID__c!=null){
                epmIdtoNameMap.put(prod.Core_Product_Series_EPM_ID__c, prod.Core_Product_Series__c);
            }
            if(prod.Core_Product_Family_EPM_ID__c!=null){
                epmIdtoNameMap.put(prod.Core_Product_Family_EPM_ID__c, prod.Core_Product_Family__c);
            }
            if(prod.Core_Product_Type_EPM_ID__c!=null){
                epmIdtoNameMap.put(prod.Core_Product_Type_EPM_ID__c, prod.Core_Product_Type__c);
            }
            if(prod.Core_Code_Name_EPM_ID__c!=null){
                epmIdtoNameMap.put(prod.Core_Code_Name_EPM_ID__c, prod.Core_Code_Name__c);
            }
            if(prod.Core_Platform_Config_EPM_ID__c!=null){
                epmIdtoNameMap.put(prod.Core_Platform_Config_EPM_ID__c, prod.Core_Platform_Config__c);
            }
            if(prod.Core_Platform_EPM_ID__c!=null){
                epmIdtoNameMap.put(prod.Core_Platform_EPM_ID__c, prod.Core_Platform_Name__c);
            }
        }
        wc.epmIdtoNameMap=epmIdtoNameMap;
        wc.prodIdtoEpmMap=prodIdtoEpmMap;
        return wc;
    }
    @AuraEnabled(cacheable=true)
    public static List<Product2History> getProductHistory(String ProductId){
        List<Product2History> phList = new List<Product2History>();
        try{
            phList = [select Id,CreatedById,CreatedBy.Name, CreatedDate, DataType, Field, NewValue, OldValue,Product2Id  from Product2History where Product2Id  =:ProductId order by createdDate DESC];
            return phList;
        }
        catch(Exception ex){return phList;}
    }
            
            @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getObjectFields(String objectApiName) {
        List<Map<String,String>> fieldNames = new List<Map<String,String>>();

        try {
            // Get the object describe result
            Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
			Map<String,String> mapFields;
            // Loop through all fields and add their API names to the list
            for (Schema.SObjectField field : describeResult.fields.getMap().values()) {
                if(field.getDescribe().isAccessible() && field.getDescribe().getName() == field.getDescribe().getLocalName()){
                    mapFields = new Map<String,String>();
                    mapFields.put('label',(String)field.getDescribe().getLabel());
                    mapFields.put('value',(String)field.getDescribe().getName());
                    fieldNames.add(mapFields);
                }
            }
        } catch (Exception e) {
            System.debug('Error getting object fields: ' + e.getMessage());
        }
        return fieldNames;
    }
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecordsByIds(List<String> idsList,String objectName,String fieldNames) {
        // Generate the dynamic SOQL query
        String soqlQuery = 'SELECT ' + fieldNames + ' FROM '+objectName +' WHERE Id IN: idsList LIMIT 50000';
        System.debug(soqlQuery);
        // Execute the dynamic SOQL query
        return Database.query(soqlQuery);
    }
            
            public class WrapperClass {
                @AuraEnabled
                public List<product2> prodData {get; set;}
                @AuraEnabled 
                public Map<String,String> epmIdtoNameMap {get; set;}
                @AuraEnabled 
                public Map<String,String> prodIdtoEpmMap {get; set;}
                @AuraEnabled
                public Boolean multi {get; set;}
            }

}