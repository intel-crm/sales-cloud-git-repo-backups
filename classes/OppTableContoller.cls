public class OppTableContoller {
	/*@AuraEnabled(cacheable=true)
  public static List<case> getCases(){
		        /*return [SELECT Id, CaseNumber, Type, Subject,Status,Core_Sub_Status__c, ClosedDate, OwnerId, Owner.Name FROM Case];
        return [SELECT Id, CaseNumber, Status,Core_Sub_Status__c, Core_Severity__c, Subject,Core_IPS_Product_name__c,
                Core_IPS_Project_Case__c,Core_Contact_Name__c, CreatedDate, LastModifiedDate,Core_IPS_Legacy_IPS_ID__c,
                Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c,ClosedDate,
                Core_Customer_Reference_ID__c, ownerId FROM Case];
                /*where ownerId =:userinfo.getUserId()  AND Status = 'Open']
    }*/
    @AuraEnabled
    public static List<Case> getAllCaseRecords(String caseListView)
    {
        String devCaseCreate = Schema.SObjectType.case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
        String devCloseCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('IPS Closed Case').getRecordTypeId();
        String devGec = Schema.SObjectType.case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();
        if(caseListView == 'allCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Comment__c,Core_IPS_Premier_Support_Project_ID__c  FROM Case where Core_IPS_Customer_Visible__c=true LIMIT 50];
            if(caseList != null){
                return caseList;
            }
        }
        if(caseListView == 'myOpenCases'){
            String userId = UserInfo.getUserId();
            List<User> lstUser = [Select ContactId from User  where Id = :userId];
            Id conId = lstuser[0].contactId;
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId,Account.id,ContactId FROM Case where Core_IPS_Customer_Visible__c=true AND (Status = 'Open' OR Status = 'On Hold' OR Status = 'New') AND Core_Sub_Status__c!='Close-Pending' AND ContactId=:conId];
            if(caseList != null){
                return caseList;
            }
        }
        if(caseListView == 'myClosedCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId FROM Case where Status = 'Closed' AND Core_IPS_Customer_Visible__c=true AND Core_IPSPortal_Check__c=true AND (RecordTypeId=:devCaseCreate OR RecordTypeId=:devCloseCase OR RecordTypeId=:devGec )  ];
            if(caseList != null){
                return caseList;
            }
        }
        if(caseListView == 'myRecentlyCreatedCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId FROM Case where Core_IPS_Customer_Visible__c=true AND CreatedDate != null  AND CreatedDate = LAST_N_DAYS: 14 ORDER BY CreatedDate Desc];
            if(caseList != null){
                return caseList;
            }
        }
        if(caseListView == 'myRecentlyModifiedCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId FROM Case where  LastModifiedDate != null AND  Core_IPS_Customer_Visible__c=true AND Core_IPSPortal_Check__c=true AND (RecordTypeId=:devCaseCreate OR RecordTypeId=:devCloseCase OR RecordTypeId=:devGec )   AND LastModifiedDate = LAST_N_DAYS: 14 ORDER BY LastModifiedDate Desc ];
            if(caseList != null){
                return caseList;
            }
        }
        if(caseListView == 'myRecentlyViewedCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, LastViewedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId FROM Case where   Core_IPS_Customer_Visible__c=true AND LastViewedDate = LAST_N_DAYS: 14  ORDER BY LastViewedDate Desc  ];
            if(caseList != null){
                return caseList;
            }
        }
        if(caseListView == 'myRecentlyClosedCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId FROM Case where Status='Closed' AND LastModifiedDate != null AND Core_IPSPortal_Check__c=true AND   Core_IPS_Customer_Visible__c=true AND LastModifiedDate = LAST_N_DAYS: 20 ORDER BY LastModifiedDate Desc ];
            if(caseList != null){
                return caseList;
            }
        }
             if(caseListView == 'myInterestedPartyCases'){
                 List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId FROM Case where (Status='Open' OR Status='New') AND Core_Sub_Status__c!='Close-Pending' AND Core_IPS_Customer_Visible__c=true];
                if(caseList != null){
                    return caseList;
                 }    
        }
        
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getCases1( String searchKey, String sortBy, String sortDirection){
        String query = 'SELECT Id, CaseNumber, Type, Subject,Status,Core_Sub_Status__c, ClosedDate, OwnerId, Owner.Name FROM Case';
        system.debug('query---'+query);
        String srtBy = String.escapeSingleQuotes(sortBy);
        String srtDirection = String.escapeSingleQuotes(sortDirection);
   
        if ( searchKey != null && searchKey != '' ) {
           String key = '%' + searchKey + '%';
           query += ' WHERE CaseNumber LIKE :key';
       }
       if ( srtBy != null && srtDirection != null ) {
           query += ' ORDER BY ' + srtBy + ' ' + srtDirection;
       }
       return Database.query( query );
    }
}