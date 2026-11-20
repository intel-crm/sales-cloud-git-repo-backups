public with sharing class Core_Ips_ProductDataTable_LWC_Ctrl {
    @AuraEnabled(cacheable=true)
    public static DataTableResponse ProductFieldAndDataValues(String productListView)
    {
        List<DataTableColumns> prodDataColumns            = new List<DataTableColumns>();
        List<Asset> prodDataTableData                   = new List<Asset>();
        
        List<string> prdcolumnList                    = new List<string>();
        List<string> prdfieldAPINameList                    = new List<string>();
        List<Core_Ips_ProductListView_LWC__mdt> productTableComponentMetadata=new List<Core_Ips_ProductListView_LWC__mdt>();
        if(Core_Ips_ProductListView_LWC__mdt.SObjectType.getDescribe().isAccessible()){
            productTableComponentMetadata =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName FROM Core_Ips_ProductListView_LWC__mdt WHERE DeveloperName=:productListView];
        }
        for(Core_Ips_ProductListView_LWC__mdt mdt :productTableComponentMetadata){
            if(mdt.HeaderValue__c != null)
            {
                prdcolumnList = mdt.HeaderValue__c.split(',');
            }
            
            
            if(mdt.FieldValue__c != null)
            {
                prdfieldAPINameList = mdt.FieldValue__c.split(',');
            }
            
        }
        
        for(integer i = 0; i < prdcolumnList.size()-1; i++)
        {
            
            DataTableColumns datacolumns = new DataTableColumns( prdcolumnList[i].trim() , 
                                                                prdfieldAPINameList[i].substringBefore(':').trim(), 
                                                                prdfieldAPINameList[i].substringAfter(':').trim());
            
            prodDataColumns.add(datacolumns);
            
        } 
        
        User loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
        String loggedInUserAcctId = loggedInUser.Contact.AccountId;
        if(productListView=='AllProducts'){
            List<Asset> productList = [SELECT Id, Name, core_Product_Application__c, Core_IPS_Support_License__c, Core_IPS_Project_Id__c, Core_IPS_Project__c, Core_IPS_Project__r.Name,Core_IPS_Project__r.Core_Status__c,Core_IPS_Project_Status__c,Core_IPS_Project_Name__c, Account.Name,Account.Id, status FROM Asset ORDER BY Name Limit 49999]; //Limit Added by Tushar
            for( Asset prod:productList ){
                prodDataTableData.add(prod);
            }
            
        }
        if(productListView=='ActiveProducts'){
            List<Asset> productList = [SELECT Id, Name, core_Product_Application__c, Core_IPS_Support_License__c, Core_IPS_Project_Id__c, Core_IPS_Project__c, Core_IPS_Project__r.Name,Core_IPS_Project_Name__c, Account.Name,Account.Id, status,Core_IPS_Project_Status__c,Core_IPS_Supported_Product_EOIS__c FROM Asset WHERE status='Active'AND  Core_IPS_Supported_Product_EOIS__c != true ORDER BY Name];
            for( Asset prod:productList ){
                prodDataTableData.add(prod);
            }
            
        }
        
        
        
        DataTableResponse finalWrapper   = new DataTableResponse();
        finalWrapper.prodDataTableColumns = prodDataColumns;
        finalWrapper.prodDataTableData    = prodDataTableData;
        
        return finalWrapper;
    }
    
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        
        public DataTableColumns(String label, String fieldName, String type)
        {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;
            
        }
    }
    
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> prodDataTableColumns {get;set;}
        @AuraEnabled
        public List<Asset> prodDataTableData {get;set;}
        
        
    }
}