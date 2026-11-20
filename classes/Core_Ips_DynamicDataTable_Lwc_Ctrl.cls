public with sharing class Core_Ips_DynamicDataTable_Lwc_Ctrl {
    
    @AuraEnabled
    public static DataTableResponse GetWrapperOfSObjectFieldColumnActionValues(String caseListView)
    {
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        List<Case> lstDataTableData = new List<Case>();
        List<case> finalCasedata = new List<case>();
        List<string> columnList  = new List<string>();
        List<string> fieldAPINameList = new List<string>();
        
        List<Core_Ips_CaseListView_Lwc__mdt> TableComponentMetadata=new List<Core_Ips_CaseListView_Lwc__mdt>();
        //Read Permission
        if (Schema.sObjectType.Core_Ips_CaseListView_Lwc__mdt.fields.FieldValue__c.isAccessible()||Schema.sObjectType.Core_Ips_CaseListView_Lwc__mdt.fields.HeaderValue__c.isAccessible()||Schema.sObjectType.Core_Ips_CaseListView_Lwc__mdt.fields.DeveloperName.isAccessible()||Schema.sObjectType.Core_Ips_CaseListView_Lwc__mdt.fields.Query__c.isAccessible()) 
        {
            TableComponentMetadata =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName=:caseListView];
        }
        
        for(Core_Ips_CaseListView_Lwc__mdt mdt :TableComponentMetadata){
            if(mdt.HeaderValue__c != null){
                columnList = mdt.HeaderValue__c.split(',');
            }
            if(mdt.FieldValue__c != null){
                fieldAPINameList = mdt.FieldValue__c.split(',');
            }
            
        }
        
        for(integer i = 0; i <columnList.size(); i++)
        {
            
            DataTableColumns datacolumns = new DataTableColumns( columnList[i].trim() , 
                                                                fieldAPINameList[i].substringBefore(':').trim(), 
                                                                fieldAPINameList[i].substringAfter(':').trim());
            
            lstDataColumns.add(datacolumns);
            
        } 
        
        String devCaseCreate = Schema.SObjectType.case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
        String devCloseCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('IPS Closed Case').getRecordTypeId();
        String devGec = Schema.SObjectType.case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();
        
        
        User loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
        String loggedInUserAcctId = loggedInUser.Contact.AccountId;
        String loggedInUserContId = loggedInUser.ContactId ;
        Integer caseDataTableLimit = Integer.valueOf(System.Label.Core_IPS_Portal_DatatableLimit);
        String userId = UserInfo.getUserId();
        List<User> lstUser = [Select ContactId from User  where Id = :userId];
        Id conId = lstuser[0].contactId;
        List<Core_IPS_Project_Member__c> projMembersList=new List<Core_IPS_Project_Member__c>();
        if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isAccessible()){
            projMembersList = [SELECT Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_User__c =: UserInfo.getUserId() AND Core_Status__c = 'Active'];  
        }
        set<ID> idSet = new set<Id>();
        for(Core_IPS_Project_Member__c projMem: projMembersList){
            idSet.add(projMem.Core_IPS_Project__c);
        }
        
        if(caseListView=='AllCases'){
            List<Case> caseList = new List<Case>(); 
        if (Schema.sObjectType.Case.isAccessible()){ //FLS Read fix applied - Gangadhar 19-10-2022
            caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Comment__c,Core_IPS_Premier_Support_Project_ID__c  FROM Case WHERE (Core_IPS_Project_Case__c = null AND AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true) OR (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND Core_IPS_Project_Case__c != null AND Core_IPS_Project_Case__c IN :idSet) ORDER BY LastModifiedDate Desc LIMIT :caseDataTableLimit]; 
            }
        for( Case cs:caseList ){
                lstDataTableData.add(cs);
            }
            
        }
        if(caseListView=='All_Cases_Detail_View'){
            List<Case> caseList=new List<Case>();
            if (Schema.sObjectType.Case.isAccessible()) {
                caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Comment__c,Core_IPS_Premier_Support_Project_ID__c,Owner.FirstName,Core_Last_Case_Comment__c,Core_Last_Case_Comment_Timestamp__c,Core_IPS_Age__c,Account.Name  FROM Case where (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND Core_IPS_Project_Case__c = null) OR (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND Core_IPS_Project_Case__c != null AND Core_IPS_Project_Case__c IN :idSet) ORDER BY LastModifiedDate Desc LIMIT :caseDataTableLimit];
            }
            
            for( Case cs:caseList ){
                
                if(cs.Core_Last_Case_Comment__c != null){
                    String str = cs.Core_Last_Case_Comment__c;
                    cs.Core_Last_Case_Comment__c = str.stripHtmlTags();
                }
                lstDataTableData.add(cs);
            }
        }
        if(caseListView=='All_Open_Cases_Detail_View'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Comment__c,Core_IPS_Premier_Support_Project_ID__c,Owner.FirstName,Core_Last_Case_Comment__c,Core_Last_Case_Comment_Timestamp__c,Core_IPS_Age__c,Account.Name FROM Case where (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND Core_IPS_Project_Case__c = null  AND Status !='Closed') OR (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND Status !='Closed' AND Core_IPS_Project_Case__c != null AND Core_IPS_Project_Case__c IN :idSet) ORDER BY LastModifiedDate Desc  LIMIT :caseDataTableLimit];
            for( Case cs:caseList ){
                lstDataTableData.add(cs);
            }
        }
        if(caseListView=='My_Recently_Updates_Cases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId,Account.Name FROM Case where (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND LastModifiedDate != null AND Core_IPS_Project_Case__c = null  AND (RecordTypeId=:devCaseCreate OR RecordTypeId=:devCloseCase OR RecordTypeId=:devGec ) AND LastModifiedDate = LAST_N_DAYS: 14) OR (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND LastModifiedDate != null AND LastModifiedDate = LAST_N_DAYS: 14 AND (RecordTypeId=:devCaseCreate OR RecordTypeId=:devCloseCase OR RecordTypeId=:devGec ) AND Core_IPS_Project_Case__c != null AND Core_IPS_Project_Case__c IN :idSet) ORDER BY LastModifiedDate Desc]; // CaseNumber];
            for( Case cs:caseList ){
                lstDataTableData.add(cs);
            }
        }
        if(caseListView=='Recently_Viewed_Cases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, LastViewedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId,Owner.Alias FROM Case where (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND Core_IPS_Project_Case__c = null  AND LastViewedDate = LAST_N_DAYS: 14) OR (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND LastViewedDate = LAST_N_DAYS: 14 AND Core_IPS_Project_Case__c != null AND Core_IPS_Project_Case__c IN :idSet) ORDER BY LastViewedDate Desc];
            for( Case cs:caseList ){
                lstDataTableData.add(cs);
            }
        }
        if(caseListView=='My_Account_Cases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId,Account.Name,ContactId,Core_IPS_Project_Case__r.Name FROM Case where (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND Core_IPS_Project_Case__c = null  AND Core_IPS_UserAccount_Case__c=true) OR (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND Core_IPS_UserAccount_Case__c=true AND Core_IPS_Project_Case__c != null AND Core_IPS_Project_Case__c IN :idSet) ORDER BY LastModifiedDate Desc LIMIT :caseDataTableLimit];
            for( Case cs:caseList ){
                lstDataTableData.add(cs);
            }
        }
        if(caseListView=='My_Open_Cases'){
            
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId,Account.id,ContactId,Core_IPS_Project_Case__r.Name,Account.Name FROM Case where AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND (Status = 'Open' OR Status = 'On Hold' OR Status = 'New') AND Core_Sub_Status__c!='Close-Pending' AND ContactId=:conId AND (RecordTypeId=:devCaseCreate OR RecordTypeId=:devCloseCase OR RecordTypeId=:devGec ) ORDER BY LastModifiedDate Desc];
            for( Case cs:caseList ){
                lstDataTableData.add(cs);
            }
        }
        if(caseListView == 'My_Closed_Cases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId,Core_IPS_Project_Case__r.Name,Account.Name FROM Case where (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND Core_IPS_Project_Case__c = null AND Status = 'Closed' AND Core_IPSPortal_Check__c=true  AND (RecordTypeId=:devCaseCreate OR RecordTypeId=:devCloseCase OR RecordTypeId=:devGec )) OR (AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND Status = 'Closed' AND (RecordTypeId=:devCaseCreate OR RecordTypeId=:devCloseCase OR RecordTypeId=:devGec ) AND Core_IPSPortal_Check__c=true AND Core_IPS_Project_Case__c != null AND Core_IPS_Project_Case__c IN :idSet) ORDER BY LastModifiedDate Desc];
            for( Case cs:caseList ){
                lstDataTableData.add(cs);
            }
        }
        
        DataTableResponse finalWrapper   = new DataTableResponse();
        finalWrapper.lstDataTableColumns = lstDataColumns;
        finalWrapper.lstDataTableData    = lstDataTableData;
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
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<Case> lstDataTableData {get;set;}
    }
}