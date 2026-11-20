public with sharing class Core_Ips_ProjectDataTable_Lwc_Ctrl {

    @AuraEnabled(cacheable=true)
    public static DataTableResponse projectFieldColumnValues(String projectListView)
    {
        List<DataTableColumns> prjDataColumns= new List<DataTableColumns>();
        List<Core_IPS_Project__c> prjDataTableData = new List<Core_IPS_Project__c>();
        List<string> prjcolumnList= new List<string>();
        List<string> prjfieldAPINameList= new List<string>();
        List<Core_Ips_ProjectListView_Lwc__mdt> prjTableComponentMetadata=new List<Core_Ips_ProjectListView_Lwc__mdt>();
        if(Core_Ips_ProjectListView_Lwc__mdt.SObjectType.getDescribe().isAccessible()){
        prjTableComponentMetadata =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName FROM Core_Ips_ProjectListView_Lwc__mdt WHERE DeveloperName=:projectListView];
        }
        for(Core_Ips_ProjectListView_Lwc__mdt mdt :prjTableComponentMetadata){
        if(mdt.HeaderValue__c != null)
        {
            prjcolumnList = mdt.HeaderValue__c.split(',');
        }
        if(mdt.FieldValue__c != null)
        {
            prjfieldAPINameList = mdt.FieldValue__c.split(',');
        }
        
        }
        
        for(integer i = 0; i < prjcolumnList.size(); i++)
        {
            
            DataTableColumns datacolumns = new DataTableColumns( prjcolumnList[i].trim() , 
                                                                prjfieldAPINameList[i].substringBefore(':').trim(), 
                                                                prjfieldAPINameList[i].substringAfter(':').trim());
            
            prjDataColumns.add(datacolumns);
            
        } 
        
        if(projectListView=='AllProjects'){
            List<Core_IPS_Project__c> projectList = [SELECT Id, Name, CreatedDate , Core_Project_Description__c, Core_Status__c,Core_IPS_Project_ID__c FROM Core_IPS_Project__c WHERE Core_Status__c='Active' OR Core_Status__c='Inactive' ORDER BY LastModifiedDate Desc];
            for( Core_IPS_Project__c proj:projectList ){
                prjDataTableData.add(proj);
            }
        }
        
        DataTableResponse finalWrapper   = new DataTableResponse();
        finalWrapper.prjDataTableColumns = prjDataColumns;
        finalWrapper.prjDataTableData    = prjDataTableData;
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
        public List<DataTableColumns> prjDataTableColumns {get;set;}
        @AuraEnabled
       public List<Core_IPS_Project__c> prjDataTableData {get;set;}
    }
}