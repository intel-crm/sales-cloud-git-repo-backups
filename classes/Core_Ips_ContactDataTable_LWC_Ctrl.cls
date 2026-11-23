public with sharing class Core_Ips_ContactDataTable_LWC_Ctrl { // Changed by tushar because for vanuability changes
    public static User loggedInUser;
    public static List<Core_Ips_ContactListView_LWC__mdt> TableComponentMetadata;
    @AuraEnabled(cacheable=true)
    public static DataTableResponse ContactFieldAndDataValues(String contactListView)
    {
        List<DataTableColumns> conDataColumns = new List<DataTableColumns>();
        List<Contact> conDataTableData = new List<Contact>();
        
        List<string> columnList = new List<string>();
        List<string> fieldAPINameList = new List<string>();
        if (Schema.sObjectType.Core_Ips_ContactListView_LWC__mdt.isAccessible()) {
            // Venrublity Fix - Refering query to service class
             TableComponentMetadata =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName FROM Core_Ips_ContactListView_LWC__mdt WHERE DeveloperName=:contactListView];
            /*TableComponentMetadata = (List<Core_Ips_ContactListView_LWC__mdt>) Core_IPS_QueryService.queryRecords(
                'SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName FROM Core_Ips_ContactListView_LWC__mdt WHERE DeveloperName = :contactListView',
                new Map<String, Object>{ 'contactListView' => contactListView }
            );*/
        }
        
        for(Core_Ips_ContactListView_LWC__mdt mdt :TableComponentMetadata){
            if(mdt.HeaderValue__c != null)
            {
                columnList = mdt.HeaderValue__c.split(',');
            }
            
            if(mdt.FieldValue__c != null)
            {
                fieldAPINameList = mdt.FieldValue__c.split(',');
            }
            
        }
        
        for(integer i = 0; i < columnList.size(); i++)
        {
            
            DataTableColumns datacolumns = new DataTableColumns( columnList[i].trim() , 
                                                                fieldAPINameList[i].substringBefore(':').trim(), 
                                                                fieldAPINameList[i].substringAfter(':').trim());
            
            conDataColumns.add(datacolumns);
            
        } 
        
        
        if(contactListView=='MyContacts'){
            // Venrublity Fix - Refering query to service class
             loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
            /*List<User> loggedInUserList = (List<User>) Core_IPS_QueryService.queryRecords(
                'Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id = :userId',
                new Map<String, Object>{ 'userId' => UserInfo.getUserId() }
            );
            if(!loggedInUserList.isEmpty()){
                loggedInUser = loggedInUserList[0];
            }*/
            String loggedInUserAcctId = loggedInUser.Contact.AccountId;
            String loggedInUserContId = loggedInUser.ContactId ;
            // Venrublity Fix - Refering query to service class
            List<Contact> contactList = [Select id,Name,LastName, FirstName,Core_Status__c, Email, Account.Name, Core_IPS_Active__c, CreatedDate,AccountId From Contact Where AccountId =:loggedInUserAcctId AND Core_IPS_Active__c  = true   limit 50];
            /*List<Contact> contactList = (List<Contact>) Core_IPS_QueryService.queryRecords(
                'Select id,Name,LastName, FirstName,Core_Status__c, Email, Account.Name, Core_IPS_Active__c, CreatedDate,AccountId From Contact Where AccountId = :loggedInUserAcctId AND Core_IPS_Active__c = true limit 50',
                new Map<String, Object>{ 'loggedInUserAcctId' => loggedInUserAcctId }
            );*/
            for( Contact con:contactList ){
                conDataTableData.add(con);
            }
        }
        
        DataTableResponse finalWrapper   = new DataTableResponse();
        finalWrapper.conDataTableColumns = conDataColumns;
        finalWrapper.conDataTableData    = conDataTableData;
        
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
        public List<DataTableColumns> conDataTableColumns {get;set;}
        @AuraEnabled
        public List<Contact> conDataTableData {get;set;}
        
    }
    
}