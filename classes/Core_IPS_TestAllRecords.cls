/***************************************************************************************************
Apex Class Name:  Core_IPS_TestAllRecords 
Version     : 1.0 
Created Date: 06 oct 2021
Function    : This class is to get the data for the list view tabs
Test Class  : Core_IPS_TestAllRecords_Test 
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------                 
* Vishal Suryavanshi           06/10/2021               Created
* Anil G                       10/12/2021               Modified    
* Vishal suryavanshi           13/12/2021               Modified        
* 
****************************************************************************************************/
public with sharing class Core_IPS_TestAllRecords {
    @AuraEnabled(cacheable=true)
    public static List<Case> getAllCaseRecords(String caseListView){
        
        if(caseListView == 'allCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c FROM Case LIMIT 50];
            if(caseList != null){
                return caseList;
            }
        }
        if(caseListView == 'myOpenCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c, ownerId FROM Case where ownerId =:userinfo.getUserId()  AND Status = 'Open'];
            if(caseList != null){
                return caseList;
            }
        }
        if(caseListView == 'myClosedCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c, ownerId FROM Case where ownerId =:userinfo.getUserId()  AND Status = 'Closed'];
            if(caseList != null){
                return caseList;
            }
        }
        if(caseListView == 'myRecentlyCreatedCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c, ownerId FROM Case where ownerId =:userinfo.getUserId() AND CreatedDate != null ORDER BY CreatedDate Desc];
            if(caseList != null){
                return caseList;
            }
        }
        if(caseListView == 'myRecentlyModifiedCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c, ownerId FROM Case where ownerId =:userinfo.getUserId() AND LastModifiedDate != null ORDER BY LastModifiedDate Desc ];
            if(caseList != null){
                return caseList;
            }
        }
        if(caseListView == 'myRecentlyViewedCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, LastViewedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c, ownerId FROM Case where ownerId =:userinfo.getUserId() ORDER BY LastViewedDate Desc ];
            if(caseList != null){
                return caseList;
            }
        }
        if(caseListView == 'myRecentlyClosedCases'){
            List<Case> caseList = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c, ownerId FROM Case where ownerId =:userinfo.getUserId() AND Status='Closed' AND LastModifiedDate != null ORDER BY LastModifiedDate Desc ];
            if(caseList != null){
                return caseList;
            }
        }
        
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Project__c> getAllProjects(){
        List<Core_IPS_Project__c> projectList = [SELECT Id, Name, CreatedDate , Core_Project_Description__c, Core_Status__c FROM Core_IPS_Project__c LIMIT 50];
        if(projectList != null){
            return projectList;
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getContactAndAccountDetails(Id UsrId)
    {
        List<user> UserRecord=[SELECT Id,ContactId From User where id=:UsrId];
        List<contact> UserContact=new List<Contact>();
        List<Account> Acc=new List<Account>();
        if(UserRecord.size() > 0)
        {
            UserContact=[SELECT Id,Name,AccountId,Account.Name From Contact WHERE Id=:UserRecord[0].ContactId limit 1];            
            if(UserContact.size() > 0)
            {
            	Acc=[SELECT Id,Name From Account WHERE Id=:UserContact[0].AccountId limit 1];
            }
        }
        if(acc != null){
            return Acc;
        }
        else{
            return null;
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Asset> getAllProducts(String productStatus,String accId){
        List<Asset> productList = new List<Asset>();
        if(productStatus == 'allproducts'){
            productList = productListRecords(null,accId);
            return productList;
        }else if(productStatus == 'activeproducts'){
            String status = 'Active';
            productList = productListRecords(status,accId);
            return productList;
        }else{
            return null;
        }
    }
    
    public static List<Asset> productListRecords(String status, String accId){
        String queryStr = 'SELECT Id, Name, core_Product_Application__c, Core_IPS_Support_License__c, Core_IPS_Project_Id__c, Core_IPS_Project__r.Name, Account.Name,Account.Id, status FROM Asset ';
        if(status != null){
            queryStr += ' WHERE Status =: status OR Account.id =: accId';
        }
        return Database.query(queryStr);
    }
    
    //Get the case record based on caseid
    @AuraEnabled(cacheable=true)
    public static Case getCurrentCase(Id csId){
        // Hassan Khan modifying "Case caseRecord = new Case()" to "List<Case> caseRecord" to fix (List has no rows for assignment to Sobject) Exception Handling issue.
        List<Case> caseRecord;
        if (Schema.sObjectType.Case.isAccessible()) {
            caseRecord = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c,Core_IPS_Supported_Product__c,
                          Core_Severity_Reason__c,Core_CaseType__c,Core_IPS_Legacy_IPS_ID__c,Core_IPS_Classification__c, Core_IPS_Bug_Doc_Fix_ID__c,
                          Core_IPS_Case_Owner_Name__c,core_Account_Name__c, Core_Contact_Name__c, Core_Case_Resolution_Reason__c,
                          Core_Customer_Reference_ID__c, Core_End_Customer__c, Subject,Description,Core_Issue_Description__c,
                          Core_IPS_Restricted_Secret_Content__c, Core_IPS_Knowledge_Base_Link__c,Core_IPS_Project_Case__c,Core_Case_Issue_Category__c,
                          Core_IPS_Product_name__c,ProductId, Asset.Id, Core_IPS_Project_Case__r.Name,Core_IPS_GEC_Flag__c,Core_Case_Issue_Sub_Category__c,
                          Core_External_Issue_Subcategory__c,Core_External_Issue_Category__c,Core_IPS_Premier_Support_Project_ID__c, Core_jsonfield__c,Core_Partner_Supported_Account__c,Core_Product_Variant__c,RecordType.DeveloperName,Core_IPS_Partner_Sup_Owner__c  FROM Case where id=:csId AND Core_IPS_Customer_Visible__c=true];
        }
        
        if(!caseRecord.isEmpty() && caseRecord != null){
            return caseRecord[0];
        }
        return null;
    }
    
    
    @AuraEnabled(cacheable = true)
    public static User getcurUsername() {
        
        User userObj = [SELECT id,Name,Email,Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
        return userObj;
    }
    
    @AuraEnabled
    public static String deleteAttachmentRecord(String attId){
        Core_IPS_Case_Attachments__c att =[Select Id, Name,Core_File_Name__c From Core_IPS_Case_Attachments__c Where Id =: attId];
        try{
            if (Schema.sObjectType.Core_IPS_Case_Attachments__c.isDeletable()) {
                delete att;
            }
            return 'Deleted';
        }
        catch(Exception e){
            return 'Not Deleted';
        }
    }
    
    //Get case comments based on the current caseid
    @AuraEnabled(cacheable=false)
    public static List<Core_IPS_Case_Comments__c> getCurrentCaseComments(Id csId){
        List<Core_IPS_Case_Comments__c> caseComments =  new List<Core_IPS_Case_Comments__c>();
        List<Core_IPS_Case_Comments__c> cscmtresult = new List<Core_IPS_Case_Comments__c>();
        String strqry = 'SELECT id,name,Core_IPS_Case_Comment_Type__c,Core_IPS_Case_Comment_Source__c,Core_IPS_Case__r.core_Account_Name__c,CreatedBy.Name,Core_IPS_Comment__c,Core_IPS_Rich_Comment__c,Core_IPS_Comment_Authored_By_Email__c,CreatedBy_Name__c,CreatedDate,Core_IPS_Comment_Author_Type__c,CreatedBy.Email,';
        /* Kalyani - Commenting out the SOQL query as it is not in use and was causing slow execution; this is part of code optimization.*/
        // User userObj = [SELECT id,Name,Email,Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
        String profile = getcurrentuserprofile();
        String PartnerProf  = System.Label.Core_IPS_Partner_Profile_Id;
        String partnerType;
        if(profile == 'Customer') 
        {   
            strqry += ' Core_IPS_Comment_Authored_By_Name__c,Core_IPS_Comment_Authored_By_FirstName__c FROM Core_IPS_Case_Comments__c WHERE Core_IPS_Case__c=:csId AND Core_IPS_Case_Comment_Type__c=\'Public to Customers\''; 
            
        }
        else if(profile =='PartnerAgent'){
            /*kalyani - Using IN operator instead of multiple ORs to improve query performance; this is part of code optimization.*/
            strqry += ' Core_IPS_Comment_Authored_By_Name__c,Core_IPS_Comment_Authored_By_FirstName__c FROM Core_IPS_Case_Comments__c WHERE Core_IPS_Case__c=:csId AND Core_IPS_Case_Comment_Type__c IN (\'Private to Agents\', \'Private to Intel\', \'Private to Partner\', \'Public to Customers\')';
        }
        else if(profile == 'PartnerFAE')
        {
            /*kalyani - Using IN operator instead of multiple ORs to improve query performance; this is part of code optimization.*/
            strqry += ' Core_IPS_Comment_Authored_By_Name__c,Core_IPS_Comment_Authored_By_FirstName__c FROM Core_IPS_Case_Comments__c WHERE Core_IPS_Case__c=:csId AND Core_IPS_Case_Comment_Type__c IN (\'Private to Partner\', \'Public to Customers\')';  
        }
        else
        {
            strqry += ' Core_IPS_Comment_Authored_By_Name__c,Core_IPS_Comment_Authored_By_FirstName__c FROM Core_IPS_Case_Comments__c WHERE Core_IPS_Case__c=:csId AND Core_IPS_Case_Comment_Type__c=\'Public to Customers\' '; 
        }
        strqry += ' ORDER BY CreatedDate DESC';
        caseComments = Database.Query(strqry);
        if(caseComments != null){
            cscmtresult = frmtComments(caseComments,profile);
            return cscmtresult;
        }
        return null;
        
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Core_IPS_Case_Comments__c> frmtComments(List<Core_IPS_Case_Comments__c> caseComments, String profile){
        for(Core_IPS_Case_Comments__c cmt: caseComments){
            if(cmt.Core_IPS_Case_Comment_Type__c =='Public to Customers'){
                if(cmt.Core_IPS_Comment_Authored_By_Email__c !=' ' && cmt.Core_IPS_Comment_Authored_By_Email__c !=null && (cmt.Core_IPS_Comment_Author_Type__c =='Customer' || cmt.Core_IPS_Comment_Author_Type__c =='Partner' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - DFAE' ) ){
                    cmt.Core_IPS_Rich_Comment__c = '<b>'+cmt.Core_IPS_Case__r.core_Account_Name__c+'</b>&nbsp&nbsp&nbsp&nbsp<b>'+cmt.Core_IPS_Comment_Authored_By_Email__c + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if(cmt.CreatedBy.Email !=null && (cmt.Core_IPS_Comment_Author_Type__c =='Customer' || cmt.Core_IPS_Comment_Author_Type__c =='Partner' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - DFAE' ) ){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' + cmt.Core_IPS_Case__r.core_Account_Name__c+'</b>&nbsp&nbsp&nbsp&nbsp<b>'+ cmt.CreatedBy.Email + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if(cmt.Core_IPS_Comment_Author_Type__c =='Customer' || cmt.Core_IPS_Comment_Author_Type__c =='Partner' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - DFAE' ){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' + cmt.Core_IPS_Case__r.core_Account_Name__c+'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if(( cmt.Core_IPS_Comment_Author_Type__c =='Agent' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - Agent'  || cmt.Core_IPS_Comment_Author_Type__c =='Backend Integration' ) && (profile=='Customer' || profile =='Partner' || profile =='PartnerFAE') ){
                    cmt.Core_IPS_Rich_Comment__c = '<b>'+System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist+'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                    if(!String.isBlank(cmt.Core_IPS_Comment_Authored_By_FirstName__c)){
                        cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                    }
                }
                else if(cmt.Core_IPS_Comment_Author_Type__c =='Partner - Agent' && (profile=='Customer')){
                    cmt.Core_IPS_Rich_Comment__c = '<b>'+System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist+'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                }
                else if(cmt.Core_IPS_Comment_Authored_By_Email__c !=' ' && cmt.Core_IPS_Comment_Authored_By_Email__c !=null && ( cmt.Core_IPS_Comment_Author_Type__c =='Agent' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - Agent' || cmt.Core_IPS_Comment_Author_Type__c =='Backend Integration'  ) && (profile =='PartnerAgent') ){
                    cmt.Core_IPS_Rich_Comment__c = '<b>'+System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist+'</b>&nbsp&nbsp&nbsp&nbsp<b>'+cmt.Core_IPS_Comment_Authored_By_Email__c + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if( ( cmt.Core_IPS_Comment_Author_Type__c =='Agent' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - Agent' || cmt.Core_IPS_Comment_Author_Type__c =='Backend Integration' ) && (profile=='Customer' || profile =='Partner' || profile =='PartnerFAE') ){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' +System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist +'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                }
                else if(cmt.CreatedBy.Email !=null && ( cmt.Core_IPS_Comment_Author_Type__c =='Agent' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - Agent' || cmt.Core_IPS_Comment_Author_Type__c =='Backend Integration'  ) && (profile =='PartnerAgent') ){
                    cmt.Core_IPS_Rich_Comment__c = '<b>'+System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist+'</b>&nbsp&nbsp&nbsp&nbsp<b>'+cmt.CreatedBy.Email + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if(( cmt.Core_IPS_Comment_Author_Type__c =='FAE' ) && (profile=='Customer' || profile =='Partner' || profile =='PartnerFAE')){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' +System.Label.Core_IPS_CaseRTF_Intel_Sales_Representative +'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                }
                else if(cmt.CreatedBy.Email !=null && ( cmt.Core_IPS_Comment_Author_Type__c =='FAE') && (profile =='PartnerAgent') ){
                    cmt.Core_IPS_Rich_Comment__c = '<b>'+System.Label.Core_IPS_CaseRTF_Intel_Sales_Representative+'</b>&nbsp&nbsp&nbsp&nbsp<b>'+cmt.CreatedBy.Email + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if(cmt.Core_IPS_Comment_Author_Type__c =='FAE'){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' +System.Label.Core_IPS_CaseRTF_Intel_Sales_Representative +'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if(cmt.Core_IPS_Comment_Author_Type__c =='Data Migration'){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' +System.Label.Core_IPS_Data_Migration_Profile_Name +'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = System.Label.Core_IPS_Data_Migration_Profile_Name;
                }
                else if(cmt.Core_IPS_Comment_Author_Type__c =='Agent' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - Agent' ){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' + System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist +'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
            }
            else{
                if(cmt.Core_IPS_Comment_Authored_By_Email__c !=' ' && cmt.Core_IPS_Comment_Authored_By_Email__c !=null && (cmt.Core_IPS_Comment_Author_Type__c =='Customer' || cmt.Core_IPS_Comment_Author_Type__c =='Partner' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - DFAE' ) ){
                    cmt.Core_IPS_Rich_Comment__c = '<b>'+cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+cmt.Core_IPS_Case__r.core_Account_Name__c+'</b>&nbsp&nbsp&nbsp&nbsp<b>'+cmt.Core_IPS_Comment_Authored_By_Email__c + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if(cmt.CreatedBy.Email !=null && (cmt.Core_IPS_Comment_Author_Type__c =='Customer' || cmt.Core_IPS_Comment_Author_Type__c =='Partner' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - DFAE' ) ){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' +cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+ cmt.Core_IPS_Case__r.core_Account_Name__c+'</b>&nbsp&nbsp&nbsp&nbsp<b>'+ cmt.CreatedBy.Email + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if(cmt.Core_IPS_Comment_Author_Type__c =='Customer' || cmt.Core_IPS_Comment_Author_Type__c =='Partner' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - DFAE' ){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' +cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+ cmt.Core_IPS_Case__r.core_Account_Name__c+'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if(( cmt.Core_IPS_Comment_Author_Type__c =='Agent' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - Agent'  || cmt.Core_IPS_Comment_Author_Type__c =='Backend Integration' ) && (profile=='Customer' || profile =='Partner' || profile =='PartnerFAE') ){
                    cmt.Core_IPS_Rich_Comment__c = '<b>'+cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist+'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                }
                else if(cmt.Core_IPS_Comment_Author_Type__c =='Partner - Agent' && (profile=='Customer')){
                    cmt.Core_IPS_Rich_Comment__c = '<b>'+cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist+'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                }
                else if(cmt.Core_IPS_Comment_Authored_By_Email__c !=' ' && cmt.Core_IPS_Comment_Authored_By_Email__c !=null && ( cmt.Core_IPS_Comment_Author_Type__c =='Agent' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - Agent' || cmt.Core_IPS_Comment_Author_Type__c =='Backend Integration'  ) && (profile =='PartnerAgent') ){
                    cmt.Core_IPS_Rich_Comment__c = '<b>'+cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist+'</b>&nbsp&nbsp&nbsp&nbsp<b>'+cmt.Core_IPS_Comment_Authored_By_Email__c + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if( ( cmt.Core_IPS_Comment_Author_Type__c =='Agent' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - Agent' || cmt.Core_IPS_Comment_Author_Type__c =='Backend Integration' ) && (profile=='Customer' || profile =='Partner' || profile =='PartnerFAE') ){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' +cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist +'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                }
                else if(cmt.CreatedBy.Email !=null && ( cmt.Core_IPS_Comment_Author_Type__c =='Agent' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - Agent' || cmt.Core_IPS_Comment_Author_Type__c =='Backend Integration'  ) && (profile =='PartnerAgent') ){
                    cmt.Core_IPS_Rich_Comment__c = '<b>'+cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist+'</b>&nbsp&nbsp&nbsp&nbsp<b>'+cmt.CreatedBy.Email + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if(( cmt.Core_IPS_Comment_Author_Type__c =='FAE' ) && (profile=='Customer' || profile =='Partner' || profile =='PartnerFAE')){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' +cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+System.Label.Core_IPS_CaseRTF_Intel_Sales_Representative +'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                }
                else if(cmt.CreatedBy.Email !=null && ( cmt.Core_IPS_Comment_Author_Type__c =='FAE') && (profile =='PartnerAgent') ){
                    cmt.Core_IPS_Rich_Comment__c = '<b>'+cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+System.Label.Core_IPS_CaseRTF_Intel_Sales_Representative+'</b>&nbsp&nbsp&nbsp&nbsp<b>'+cmt.CreatedBy.Email + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if(cmt.Core_IPS_Comment_Author_Type__c =='FAE'){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' +cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+System.Label.Core_IPS_CaseRTF_Intel_Sales_Representative +'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
                else if(cmt.Core_IPS_Comment_Author_Type__c =='Data Migration'){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' +cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+System.Label.Core_IPS_Data_Migration_Profile_Name +'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = System.Label.Core_IPS_Data_Migration_Profile_Name;
                }
                else if(cmt.Core_IPS_Comment_Author_Type__c =='Agent' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - Agent' ){
                    cmt.Core_IPS_Rich_Comment__c ='<b>' +cmt.Core_IPS_Case_Comment_Type__c +'</b>&nbsp&nbsp&nbsp&nbsp<b>'+ System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist +'</b><br/>' + cmt.Core_IPS_Rich_Comment__c ;
                }
            }
            
        }
        return caseComments;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getcurrentuserprofile(){
        User currentuser;
        List< PermissionSetAssignment> pset;
        currentUser = [SELECT Id, Name, Profile.Name,Profile.Id FROM User WHERE Id=:UserInfo.getUserId()];
        pset = [SELECT Id, PermissionSetId, PermissionSet.Name,  AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE Assignee.Id =:currentUser.Id AND PermissionSet.Name ='Core_IPS_Partner_FAE_Permission_Set'];
        String profileName = null;
        if(currentUser.Profile.Name == System.Label.Core_IPS_External_Customer_Profile){
            profileName = 'Customer';
            return profileName;
        }
        else if(currentUser.Profile.Id == System.Label.Core_IPS_Agent_Partner_Profile_id ){
            profileName = 'PartnerAgent';
            return profileName;
        }
        else if(!pset.isempty() && currentUser.Profile.Name == System.Label.Core_IPS_Partner_Profile_Name && pset[0].PermissionSet.Name =='Core_IPS_Partner_FAE_Permission_Set'){
            profileName = 'PartnerFAE';
            return profileName;
        } 
        profileName = 'Partner';
        return profileName;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getcurCaseContactProfile(ID caseId){
        User contactUser;
        Case cs = getCurrentCase(caseId);
        contactUser = [SELECT Id, Name, Profile.Name,Profile.Id FROM User WHERE Name =: cs.Core_Contact_Name__c AND (Profile.Name = 'IPS External Customer' OR Profile.Name = 'Partner') LIMIT 1];
        return contactUser.Profile.Name;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getcurcasestatus(String caseID){
        case caseRecord=new case();
        if (Schema.sObjectType.case.isAccessible()) {
            caseRecord = [SELECT Id, CaseNumber, Status  FROM Case where id=:caseID];
        }
        return caseRecord.Status;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Case_Attachments__c> getattachments(String caseID){
        
        List<Core_IPS_Case_Attachments__c> cdoc = new List<Core_IPS_Case_Attachments__c>();
        String strqry = 'SELECT Name,Core_Case__c,Core_File_GUID__c,Core_Case__r.Status,Core_File_URL__c,Core_File_Hyperlink__c,CreatedDate, Core_File_Description__c, Core_File_Name__c, Core_File_Size__c, Core_Upload_Status__c,Core_IPS_Attachment_Visibility__c FROM Core_IPS_Case_Attachments__c where Core_Case__c =:caseID';  
        User userObj = [SELECT id,Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
        String PartnerProf  = System.Label.Core_IPS_Partner_Profile_Id;
        String partnerType;
        if((System.Label.Core_IPS_External_Customer_Profile.contains(String.valueOf(userObj.Profile.Name)) )) 
        {
            strqry += ' AND Core_IPS_Attachment_Visibility__c=\'Public to Customers\'';
        }
        else if(System.Label.Core_IPS_Agent_Partner_Profile_id.contains(String.valueOf(userinfo.getProfileId()).substring(0,15))){
            /*kalyani - Using IN operator instead of multiple ORs to improve query performance; this is part of code optimization.*/
            strqry += ' AND Core_IPS_Attachment_Visibility__c IN (\'Private to Intel\', \'Private to Partner\', \'Public to Customers\')';
        }
        else if(PartnerProf.contains(String.valueOf(userinfo.getProfileId()).substring(0,15)))
        {  
            String uploadpartnerProfileType= Core_Utility.getPartnerUserType(userinfo.getuserid()); 
            if(uploadpartnerProfileType.length()>0)
            {
                partnerType = uploadpartnerProfileType.split(';')[0];
            }                                                       
            if(partnerType !=null && String.isNotBlank(partnerType)) 
            {                
                if(partnerType == 'Partner - DFAE')
                {
                    /*kalyani - Using IN operator instead of multiple ORs to improve query performance; this is part of code optimization.*/
                    strqry += ' AND Core_IPS_Attachment_Visibility__c IN (\'Private to Partner\', \'Public to Customers\')';  
                }
                else if(partnerType == 'Partner')
                {
                    strqry += ' AND Core_IPS_Attachment_Visibility__c=\'Public to Customers\' '; 
                }
            }
            
        }         
        strqry += ' ORDER BY CreatedDate DESC';
        cdoc = Database.Query(strqry);
        for(Core_IPS_Case_Attachments__c att:cdoc ){
            if(att.Core_Upload_Status__c == 'Pending'){
                String url = att.Core_File_Hyperlink__c;
                url = url.replace('<a href="', '').replace('" target="Self">Resume</a>', ' ').replace('amp;', '').trim();
                att.Core_File_URL__c = url;
            }
        }
        return cdoc;
    }
    //This method is used to close the case
    @AuraEnabled(Cacheable=false)
    public static String getCaseClosed(Id caseId){
        String status = 'success';
        Boolean isEditable;
        if (Schema.sObjectType.UserRecordAccess.isAccessible()) {
            isEditable = [SELECT HasEditAccess, RecordId 
                          FROM UserRecordAccess 
                          WHERE UserId =:userinfo.getuserId() 
                          AND RecordId = :caseId].HasEditAccess;
        }
        Case cs = new Case();
        List<Case> csList = new List<Case>();
        if (Schema.sObjectType.Case.isAccessible()) { 
            cs = [SELECT Id, Status FROM Case WHERE Id =: caseId];
            System.debug('cs1'+cs);
            /*if(csList.size() > 0)
            {
                cs = csList[0];
            }*/
        }
        try{
            if(cs.Status != 'Closed'){
                cs.Id = caseId;
                if(isEditable){
                    if (Schema.sObjectType.case.fields.Status.isUpdateable()) {
                        cs.Status = 'Closed';
                    }
                    if (Schema.sObjectType.case.fields.Core_Sub_Status__c.isUpdateable()) {
                        cs.Core_Sub_Status__c = 'Closed';
                    }
                    if (Schema.sObjectType.case.fields.Core_IPS_Partner_status_ReadOnly__c.isUpdateable()) {
                        cs.Core_IPS_Partner_status_ReadOnly__c = true;
                    }
                }
                update cs;
            }
            Case csObj = new Case();
            if(isEditable){
                csObj.Id = caseId;
                if (Schema.sObjectType.case.fields.Core_IPS_Partner_status_ReadOnly__c.isUpdateable()) {
                    csObj.Core_IPS_Partner_status_ReadOnly__c = false;
                }
            }
            update csObj;
        }catch(Exception e){
            Core_IPS_ExceptionHandling.logEntryWithException(e,'Core_IPS_TestAllRecords','Case');
            status = e.getMessage();
        }
        return status;
    }
    
    //This method is used to create new comment
    @AuraEnabled(Cacheable=false)
    public static String saveNewComment(String csId, String visibility, String comment){
        String status = 'success';
        try{
            comment = comment.unescapeHTML4();
            //comment = comment.replaceAll('<p>','');
            //comment = comment.replaceAll('</p>','');
            comment = comment.trim();
            if(comment=='' || comment==null){
                status = 'Blank Comment';  
            }else{
                Core_IPS_CaseCommentLWCController.initialize(csId);
                status = Core_IPS_CaseCommentLWCController.saveCaseComment(csId,visibility,comment);
            }
        }catch(Exception e){
            Core_IPS_ExceptionHandling.logEntryWithException(e,'Core_IPS_TestAllRecords','Core_IPS_Case_Comments__c');
            status = 'error';
        }
        return status;
        
    }
    
    @AuraEnabled(Cacheable=false)
    public static String updateCaseDetails(Id caseId, String caseData){
        Map<String, String> values = (Map<String, String>)JSON.deserialize(caseData, Map<String, String>.class);
        String subject = values.get('subject');    
        String description = values.get('description');
        String CaseType = values.get('CaseType');
        String Severity = values.get('Severity');
        String customerRefId = values.get('customerRefId');
        String endCustomer = values.get('endCustomer');
        String caseCategory = values.get('caseCategory');
        String caseSubCategory = values.get('caseSubCategory');
        Case cs = new Case();
        if(caseId != null){
            cs.Id = caseId;    
        }
        if(subject != null||Schema.sObjectType.Case.fields.Subject.isUpdateable()){
            cs.Subject = subject;
        }
        if(description != null||Schema.sObjectType.Case.fields.Core_Issue_Description__c.isUpdateable()||Schema.sObjectType.Case.fields.Description.isUpdateable()){
            cs.Description = description;
            cs.Core_Issue_Description__c = description; 
        }
        if(CaseType != null||Schema.sObjectType.Case.fields.Core_CaseType__c.isUpdateable()){
            cs.Core_CaseType__c = CaseType;
        }
        if(Severity != null||Schema.sObjectType.Case.fields.Core_Severity__c.isUpdateable()){
            cs.Core_Severity__c = Severity;
        }
        if(customerRefId != null||Schema.sObjectType.Case.fields.Core_Customer_Reference_ID__c.isUpdateable()){
            cs.Core_Customer_Reference_ID__c = customerRefId;
        }
        if(endCustomer != null||Schema.sObjectType.Case.fields.Core_End_Customer__c.isUpdateable()){
            cs.Core_End_Customer__c = endCustomer;
        }
        if(caseCategory != null||Schema.sObjectType.Case.fields.Core_External_Issue_Category__c.isUpdateable()){
            cs.Core_External_Issue_Category__c = caseCategory;
        }
        if(caseSubCategory != null||Schema.sObjectType.Case.fields.Core_External_Issue_Subcategory__c.isUpdateable()){
            cs.Core_External_Issue_Subcategory__c = caseSubCategory;
        }
        
        update cs; 
        return caseData;
    }
    
    @AuraEnabled(cacheable=true)
    public static Wrapsearchresult getSearchResult(String searchKey){
        User loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
        String loggedInUserAcctId = loggedInUser.Contact.AccountId;
        String loggedInUserContId = loggedInUser.ContactId ;
        Integer globalSearchDataLimit = Integer.valueOf(System.Label.Core_IPS_Portal_GlobalSearchDT_Limit);
         
        string searchKeyword ='%'+ searchKey+'%';
        Wrapsearchresult wraplist = new Wrapsearchresult();
       /* List<List<sObject>> searchResult = [FIND :searchKeyword
                                            IN ALL FIELDS RETURNING
                                            //Case(Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c),
                                            Case(Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c,AccountId  WHERE AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true ),
                                            Asset(Id,Name, core_Product_Application__c, Core_IPS_Support_License__c, Core_IPS_Project_Id__c, Core_IPS_Project__r.Name, Account.Name),
                                            Core_IPS_Project__c(Id,Name, CreatedDate , Core_Project_Description__c, Core_Status__c )];*/
        /*if(searchKey.isNumeric() == true){      
            wraplist.caselist = [Select Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name, Core_IPS_Project_Case__c,Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c,AccountId FROM Case WHERE AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND CaseNumber like:searchKeyword ];
            wraplist.prodlist = new List<Asset>();
            wraplist.projlist = new List<Core_IPS_Project__c>();
        }*/
        //else if(searchKey.isAlpha()== true || searchKey.isAlphanumeric()==true){
            Set<Id> projList = new Set<Id>();
            List<Core_IPS_Project_Member__c> projMemList = new List<Core_IPS_Project_Member__c>();
            projMemList = [select Id, name, core_ips_contact__c,Core_IPS_Project__c, Core_IPS_Contact__r.FirstName, Core_IPS_Contact__r.Account.Name from Core_IPS_Project_Member__c where core_ips_contact__c =: loggedInUserContId ];  
            for(Core_IPS_Project_Member__c p: projMemList){
                projList.add(p.Core_IPS_Project__c);
            }

            //wraplist.caselist = [Select Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name,Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c,AccountId FROM Case WHERE AccountId=:loggedInUserAcctId AND Core_IPS_Customer_Visible__c=true AND (Core_IPS_Product_name__c  like:searchKeyword OR Core_IPS_Project_Case__r.Name like:searchKeyword  OR Subject like:searchKeyword OR CaseNumber like:searchKeyword ) LIMIT :globalSearchDataLimit];
            Integer whereconditionlen = loggedInUserAcctId.length() + (projList.size() * 18)   + searchKeyword.length() * 4;
        if(whereconditionlen < 3800){
        	wraplist.caselist = [Select Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name,Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c,AccountId FROM Case WHERE (AccountId=:loggedInUserAcctId OR Core_IPS_Project_Case__c IN: projList ) AND Core_IPS_Customer_Visible__c=true AND (Core_IPS_Product_name__c  like:searchKeyword OR Core_IPS_Project_Case__r.Name like:searchKeyword  OR Subject like:searchKeyword OR CaseNumber like:searchKeyword ) LIMIT :globalSearchDataLimit];
            wraplist.prodlist = [Select Id,Name, core_Product_Application__c, Core_IPS_Support_License__c, Core_IPS_Project_Id__c, Core_IPS_Project__r.Name, Account.Name From Asset WHERE Name Like: searchKeyword LIMIT :globalSearchDataLimit];
            wraplist.projlist =[Select Id,Name, CreatedDate , Core_Project_Description__c, Core_Status__c FROM Core_IPS_Project__c WHERE Name like:searchKeyword LIMIT :globalSearchDataLimit];
        }
        return wraplist;
    }
    
    public class Wrapsearchresult{
        
        @AuraEnabled
        public  List<Case> caselist{get; set;}
        @AuraEnabled
        public  List<Asset> prodlist{get; set;}
        @AuraEnabled
        public  List<Core_IPS_Project__c> projlist {get;set;}
         
    }
    
    
    /*Get all EDQs based on caseId*/    
    @AuraEnabled(Cacheable=false)
    public static List<Core_IPS_Response__c> getEnvDetails(String csId){
        List<Core_IPS_Response__c> responseList = new List<Core_IPS_Response__c>();
        String profile = getcurrentuserprofile();
        if(csId != null){
            if(profile == 'PartnerFAE' || profile == 'Partner'){
                responseList = [Select Core_IPS_Case__c, Core_IPS_Answer__c, Core_IPS_Question__c From Core_IPS_Response__c Where Core_IPS_Case__c =:csId and Core_IPS_Agent_Only__c!=true];
                System.debug('HK IF----> '+responseList);
            }
            else{
                responseList = [Select Core_IPS_Case__c, Core_IPS_Answer__c, Core_IPS_Question__c From Core_IPS_Response__c Where Core_IPS_Case__c =:csId];
                System.debug('HK ELSE----> '+responseList);
            }        
        }
        return responseList; 
    }
    
    /*********
* Author: Shruti Hasilkar
* Date: 9/8/2022
* Description: To get the Partner Support Owner & Partner Supported Account  */ 
    @AuraEnabled
    public static User getPartnerSupportOwner(String passedProjectId){
        List<core_ips_project__c> projList = new List<core_ips_project__c>();
        String partnerSupportOwner ='' ;
        User passUserDetails ; 
        try {
            projList = [SELECT id,name,Core_IPS_Partner_Support_Owner__c FROM core_ips_project__c WHERE ID = :passedProjectId];
            if(projList[0].Core_IPS_Partner_Support_Owner__c != null){
                partnerSupportOwner = projList[0].Core_IPS_Partner_Support_Owner__c;
            }else{
                partnerSupportOwner = userinfo.getuserId();
            }
            passUserDetails = getUserDetail(partnerSupportOwner);
        } catch (Exception e) {
        }
        return passUserDetails;
    }
    
    public static User getUserDetail(String userId){
        User usDetail = new User();
        try{
            if(userId != null && userId != ''){
                usDetail = [SELECT ID, Name FROM User WHERE ID = :userId];
            }
            
        }catch(Exception e){
        }
        return usDetail;
    }
    
    @AuraEnabled
    public static Map<Id, String> getSupportedAccount(String selectedProject, String userID){
        if(selectedProject=='NoProj'){
            selectedProject=null;
        }
        List<Core_IPS_Project_Member__c> projMembersList = new List<Core_IPS_Project_Member__c>();
        Set<Id> projIds=new Set<Id>();
        if(!String.isBlank(userID)){
            List<User> contIdValLst = [select id,ContactId from user where id=:userID limit 1];
            if(contIdValLst.size()>0){
                String contId = contIdValLst[0].ContactId;
                if (Schema.sObjectType.Core_IPS_Project_Member__c.isAccessible()) {
                    projMembersList = [select id,name,Core_IPS_Project__c,Core_IPS_Contact_Account__c from Core_IPS_Project_Member__c where Core_IPS_Contact__c=:contId and Core_Status__c='Active'];  
                }
            }
        }
        
        for(integer i=0;i<projMembersList.size();i++){
            projIds.add(projMembersList[i].Core_IPS_Project__c);
        }
        if(!String.isBlank(selectedProject) && selectedProject!='NA'){
            
            projIds.clear();
            projIds.add(Id.valueOf(selectedProject));
        }
        List<Core_IPS_Account__c> projMemAccounts=new List<Core_IPS_Account__c>();
        if (Schema.sObjectType.Core_IPS_Account__c.isAccessible()) {
            projMemAccounts=[select id,name, Core_Account__r.id,Core_Account__c,Core_IPS_Account_Name__c,Core_IPS_Project__r.Name,Core_IPS_Project__c from Core_IPS_Account__c where Core_IPS_Project__c  IN :projIds AND Core_Account__c!=null AND Core_IPS_Account_Name__c!=null AND Core_Status__c='Active'];
        }
        Map<Id, String> accountMap = new Map<Id, String>();
        
        if(projMemAccounts <> null && projMemAccounts.size()>0) {
            for(Core_IPS_Account__c ipsacc : projMemAccounts){
                accountMap.put(ipsacc.Core_Account__c, ipsacc.Core_IPS_Account_Name__c);
            }
        }
        return accountMap;
    }
    
    @AuraEnabled
    public static Case getSupOwnerAndSupAccountforEditCase(String caseId){
        Case cs = new Case();
        try {
            if (Schema.sObjectType.Case.isAccessible()) {
                cs = [SELECT Core_IPS_Partner_Sup_Owner__r.Name, Core_IPS_Partner_Sup_Owner__c, Core_Partner_Supported_Account__r.Name, Core_Partner_Supported_Account__c FROM Case WHERE ID = :caseId];
            }    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return cs;
    }
    
    @AuraEnabled
    public static Case submitCaseClosureRes(Case updateCase){
        Case cs = new Case();
        try {
            cs.Id = updateCase.Id;
            if (Schema.sObjectType.case.fields.Status.isUpdateable()) {
                cs.Status = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Case_Status_Open');
            }
            if (Schema.sObjectType.case.fields.Core_Sub_Status__c.isUpdateable()) {
                cs.Core_Sub_Status__c =Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Close_Pending_SubStatus');
            }
            if (Schema.sObjectType.case.fields.Core_Case_Resolution_Reason__c.isUpdateable()) {
                cs.Core_Case_Resolution_Reason__c = updateCase.Core_Case_Resolution_Reason__c ;
            }
            if (Schema.sObjectType.case.fields.Core_IPS_Bug_Doc_Fix_ID__c.isUpdateable()) {
                cs.Core_IPS_Bug_Doc_Fix_ID__c = updateCase.Core_IPS_Bug_Doc_Fix_ID__c ;
            }
            if (Schema.sObjectType.case.fields.Core_IPS_Knowledge_Base_Link__c.isUpdateable()) {
                cs.Core_IPS_Knowledge_Base_Link__c = updateCase.Core_IPS_Knowledge_Base_Link__c ;
            }
            update cs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return cs;
    }
    
    @AuraEnabled(cacheable = true)
   public static Core_IPS_Project__c getProjectStatus(String projectId) {
        List<Core_IPS_Project__c> projectObj = new List<Core_IPS_Project__c>();
        try {    
            if (Schema.sObjectType.Core_IPS_Project__c.isAccessible()) {
                projectObj = [SELECT id, Core_Status__c FROM Core_IPS_Project__c WHERE id =:projectId];
            }
             if(projectObj.size() > 0){
                return projectObj[0];
            }
            return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }  
       // return projectObj;
    }
    
    @AuraEnabled(cacheable = true)
    public static Asset getProductStatus(String assetId) {
        List<Asset> assetObj = new List<Asset>();
        try {    
            if (Schema.sObjectType.Core_IPS_Project__c.isAccessible()) {
                assetObj = [SELECT id, Status FROM Asset WHERE id =:assetId];
            }

            if(assetObj.size() > 0){
                return assetObj[0];
            }
            return null;
           

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
       
       
    }
    
}