public with sharing class Core_IPS_ListViewsCtrl_LWC {
   
//     @AuraEnabled
//     public static List<Contact> getContactRecords(Integer offSetCount) {
//         //return [SELECT Id, Name, AccountNumber, Phone, CreatedDate FROM Account order by Name asc LIMIT 20 OFFSET :offSetCount];
//         return [SELECT Id, Name, Account.Name, Owner.Name, Owner.Alias, OwnerId, Email, CreatedDate, LastViewedDate FROM Contact LIMIT 20 OFFSET :offSetCount];
//     }
// /*
//     @AuraEnabled(cacheable=true)
//     public static List<Contact> getAllContacts(String contactlistValues, Integer offset){
//         List<contact> contactList = new List<Contact>();
        
//         if(contactlistValues == 'allcontacts'){
//             contactList = contactListRecords(null, false, false, offset);
//             return contactList;
//         }else if(contactlistValues == 'myContacts'){
//             String ownerId = Userinfo.getUserId();
//             contactList = contactListRecords(ownerId, false, false, offset);  
//             return contactList;
//         }else if(contactlistValues == 'newThisWeek'){
//             Boolean thisWeek = true;
//             contactList = contactListRecords(null, true, false, offset);   
//             return contactList;
//         }else if(contactlistValues == 'recentlyViewedContacts'){
//             Boolean lastViewedDate = true;
//             contactList = contactListRecords(null, false, lastViewedDate, offset);   
//             return contactList;
//         }
//         else{
//             return null;
//         }
//     }
//     private static List<Contact> contactListRecords(String ownerId, Boolean thisWeek, Boolean lastViewDate, Integer offSetCount){
//         try {
//             String queryStr = 'SELECT Id, Name, Account.Name, Owner.Name, Owner.Alias, OwnerId, Email, CreatedDate, LastViewedDate FROM Contact';
//             System.debug('Owner id from test all'+ownerId);
//             if(ownerId != null){
//                 queryStr += ' WHERE OwnerId =: ownerId';
//             }
//             if(thisWeek){
//                 queryStr += ' WHERE CreatedDate = THIS_WEEK ORDER BY CreatedDate DESC';
//             }
//             if(lastViewDate){
//                 queryStr += ' ORDER BY LastViewedDate DESC LIMIT 20 OFFSET : offSetCount ';
//             }
//             else{
//                 queryStr += ' ORDER BY CreatedDate LIMIT 20 OFFSET : offSetCount';
//             }
//             return Database.query(queryStr);
//         } catch (Exception e) {
//             return null;
//         }
        
//     }
// */
// 	@AuraEnabled(cacheable=true)
//     // public static List<Contact> getAllContacts(String contactlistValues, Integer offset, Integer limitSize, String fetchType){
//     //     try{
//     //         String queryStr = 'SELECT Id, Name, Account.Name, Owner.Name, Owner.Alias, OwnerId, Email, CreatedDate, LastViewedDate FROM Contact';
//     //         if(contactlistValues == 'allcontacts' && fetchType != 'All Data'){
//     //             queryStr += ' ORDER BY CreatedDate LIMIT :limitSize OFFSET :offset';
//     //         }
//     //         return Database.query(queryStr);
            
//     //     }catch (Exception e) {
//     //         throw new AuraHandledException('Error Getting Contact Records :' +e.getMessage());
//     //     }
        
//     // }
//     public static List<Contact> getAllContacts(String contactlistValues, Integer offset, Integer limitSize){
//     if(contactlistValues=='allContacts'){
//         List<Contact> queryStr = [SELECT Id, Name, Account.Name, Owner.Name, Owner.Alias, OwnerId, Email, CreatedDate, LastViewedDate FROM Contact LIMIT:limitSize OFFSET:offset];
        

//         return queryStr;
//     }
            
        
//     }




//     // This is testing again
//     @AuraEnabled(cacheable = true)   
//     public static AccountWrapper fetchAccountRecords(Integer queryLimit, Integer queryOffset) {   
//         return new AccountWrapper([SELECT count() FROM Account],   
//         [SELECT Name, CreatedBy.Name, Rating, AccountSource, CreatedDate    
//                 FROM Account   
//                 ORDER BY CreatedDate DESC    
//                 LIMIT :queryLimit    
//                 OFFSET :queryOffset]);   
//     }   
   
//     public class AccountWrapper {   
//         @AuraEnabled   
//         public Integer totalRecordCount { get; set; }   
//         @AuraEnabled   
//         public List<Account> accRecords { get; set; }   
//         public AccountWrapper(Integer totalRecordCount, List<Account> accRecords) {   
//             this.totalRecordCount = totalRecordCount;   
//             this.accRecords = accRecords;   
//         }   
//     }   
    


@AuraEnabled(cacheable=true)
public static DataTableResponse GetWrapperOfSObjectFieldColumnActionValues(String caseListView,Integer rowOffset)
{
    List<DataTableColumns> lstDataColumns            = new List<DataTableColumns>();
    List<Case> lstDataTableData                   = new List<Case>();

    List<string> columnList                    = new List<string>();
    List<string> fieldAPINameList                    = new List<string>();
    
    List<Core_Ips_CaseListView_Lwc__mdt> TableComponentMetadata =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName=:caseListView];
    
    for(Core_Ips_CaseListView_Lwc__mdt mdt :TableComponentMetadata){
    if(mdt.HeaderValue__c != null)
    {
        columnList = mdt.HeaderValue__c.split(',');
    }
    
    
    if(mdt.FieldValue__c != null)
    {
        fieldAPINameList = mdt.FieldValue__c.split(',');
    }
    
    }
    
    for(integer i = 0; i <columnList.size(); i++)
    {
        
        DataTableColumns datacolumns = new DataTableColumns( columnList[i].trim() , 
                                                            fieldAPINameList[i].substringBefore(':').trim(), 
                                                            fieldAPINameList[i].substringAfter(':').trim());
        
        lstDataColumns.add(datacolumns);
        system.debug('lstDataColumns'+lstDataColumns);
    } 
    
    String devCaseCreate = Schema.SObjectType.case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
    String devCloseCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('IPS Closed Case').getRecordTypeId();
    String devGec = Schema.SObjectType.case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();


    User loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
    String loggedInUserAcctId = loggedInUser.Contact.AccountId;
    String loggedInUserContId = loggedInUser.ContactId ;

    String userId = UserInfo.getUserId();
    List<User> lstUser = [Select ContactId from User  where Id = :userId];
    Id conId = lstuser[0].contactId;

    if(caseListView=='AllCases'){
        List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Comment__c,Core_IPS_Premier_Support_Project_ID__c  FROM Case where AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true LIMIT 10 OFFSET:rowOffset];
        for( Case cs:caseList ){
            lstDataTableData.add(cs);
        }
        system.debug('result'+lstDataTableData.size());
    }
    
    
    DataTableResponse finalWrapper   = new DataTableResponse();
    finalWrapper.lstDataTableColumns = lstDataColumns;
    finalWrapper.lstDataTableData    = lstDataTableData;
    system.debug('vfgjkfgnfg'+finalWrapper.lstDataTableData);
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
        system.debug('FieldName'+fieldName);          
    }
}

public class DataTableResponse {
    @AuraEnabled
    public List<DataTableColumns> lstDataTableColumns {get;set;}
    @AuraEnabled
    public List<Case> lstDataTableData {get;set;}

    
}
}