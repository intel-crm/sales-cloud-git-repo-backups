/***************************************************************************************************
Apex Class Name:  Core_IPS_TestAllRecords
Version         : 1.0
Created Date    : 06 oct 2021
Function        : This class is to get the data for the list view tabs
Test Class      : Core_IPS_TestAllRecords_Test
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------
* Vishal Suryavanshi           06/10/2021               Created
* Anil G                       10/12/2021               Modified
* Vishal suryavanshi           13/12/2021               Modified
****************************************************************************************************/
public with sharing class Core_IPS_TestAllRecords {

    @AuraEnabled(cacheable=true)
    public static List<Case> getAllCaseRecords(String caseListView) {
        String userId = UserInfo.getUserId();

        if (caseListView == 'allCases') {
            String query = 'SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, ' +
                'Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name, Core_Contact_Name__c, ' +
                'CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, ' +
                'Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c ' +
                'FROM Case LIMIT 50';

            return (List<Case>) Core_IPS_QueryService.queryRecords(query);
        }

        if (caseListView == 'myOpenCases') {
            String query = 'SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, ' +
                'Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, ' +
                'CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, ' +
                'Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c, OwnerId ' +
                'FROM Case WHERE OwnerId = :userId AND Status = \'Open\'';

            return (List<Case>) Core_IPS_QueryService.queryRecords(query, new Map<String, Object>{
                'userId' => userId
            });
        }

        if (caseListView == 'myClosedCases') {
            String query = 'SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, ' +
                'Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, ' +
                'CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, ' +
                'Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c, OwnerId ' +
                'FROM Case WHERE OwnerId = :userId AND Status = \'Closed\'';

            return (List<Case>) Core_IPS_QueryService.queryRecords(query, new Map<String, Object>{
                'userId' => userId
            });
        }

        if (caseListView == 'myRecentlyCreatedCases') {
            String query = 'SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, ' +
                'Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, ' +
                'CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, ' +
                'Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c, OwnerId ' +
                'FROM Case WHERE OwnerId = :userId AND CreatedDate != null ORDER BY CreatedDate DESC';

            return (List<Case>) Core_IPS_QueryService.queryRecords(query, new Map<String, Object>{
                'userId' => userId
            });
        }

        if (caseListView == 'myRecentlyModifiedCases') {
            String query = 'SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, ' +
                'Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, ' +
                'CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, ' +
                'Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c, OwnerId ' +
                'FROM Case WHERE OwnerId = :userId AND LastModifiedDate != null ORDER BY LastModifiedDate DESC';

            return (List<Case>) Core_IPS_QueryService.queryRecords(query, new Map<String, Object>{
                'userId' => userId
            });
        }

        if (caseListView == 'myRecentlyViewedCases') {
            String query = 'SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, ' +
                'Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, ' +
                'CreatedDate, LastModifiedDate, LastViewedDate, Core_IPS_Legacy_IPS_ID__c, ' +
                'Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, ' +
                'Core_Customer_Reference_ID__c, OwnerId ' +
                'FROM Case WHERE OwnerId = :userId ORDER BY LastViewedDate DESC';

            return (List<Case>) Core_IPS_QueryService.queryRecords(query, new Map<String, Object>{
                'userId' => userId
            });
        }

        if (caseListView == 'myRecentlyClosedCases') {
            String query = 'SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, ' +
                'Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, ' +
                'CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, ' +
                'Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c, OwnerId ' +
                'FROM Case WHERE OwnerId = :userId AND Status = \'Closed\' AND LastModifiedDate != null ' +
                'ORDER BY LastModifiedDate DESC';

            return (List<Case>) Core_IPS_QueryService.queryRecords(query, new Map<String, Object>{
                'userId' => userId
            });
        }

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Project__c> getAllProjects() {
        String query = 'SELECT Id, Name, CreatedDate, Core_Project_Description__c, Core_Status__c ' +
            'FROM Core_IPS_Project__c LIMIT 50';

        return (List<Core_IPS_Project__c>) Core_IPS_QueryService.queryRecords(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getContactAndAccountDetails(Id usrId) {
        String userQuery = 'SELECT Id, ContactId FROM User WHERE Id = :usrId';
        List<User> userRecords = (List<User>) Core_IPS_QueryService.queryRecords(userQuery, new Map<String, Object>{
            'usrId' => usrId
        });

        if (userRecords == null || userRecords.isEmpty() || userRecords[0].ContactId == null) {
            return new List<Account>();
        }

        String contactQuery = 'SELECT Id, Name, AccountId, Account.Name FROM Contact WHERE Id = :contactId LIMIT 1';
        List<Contact> userContact = (List<Contact>) Core_IPS_QueryService.queryRecords(contactQuery, new Map<String, Object>{
            'contactId' => userRecords[0].ContactId
        });

        if (userContact == null || userContact.isEmpty() || userContact[0].AccountId == null) {
            return new List<Account>();
        }

        String accountQuery = 'SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1';
        return (List<Account>) Core_IPS_QueryService.queryRecords(accountQuery, new Map<String, Object>{
            'accountId' => userContact[0].AccountId
        });
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset> getAllProducts(String productStatus, String accId) {
        List<Asset> productList = new List<Asset>();

        if (productStatus == 'allproducts') {
            return productListRecords(null, accId);
        } else if (productStatus == 'activeproducts') {
            return productListRecords('Active', accId);
        } else {
            return null;
        }
    }

    public static List<Asset> productListRecords(String status, String accId) {
        String queryStr = 'SELECT Id, Name, core_Product_Application__c, Core_IPS_Support_License__c, ' +
            'Core_IPS_Project_Id__c, Core_IPS_Project__r.Name, Account.Name, Account.Id, Status FROM Asset';

        if (status != null) {
            queryStr += ' WHERE Status = :status OR Account.Id = :accId';
            return (List<Asset>) Core_IPS_QueryService.queryRecords(queryStr, new Map<String, Object>{
                'status' => status,
                'accId' => accId
            });
        }

        return (List<Asset>) Core_IPS_QueryService.queryRecords(queryStr);
    }

    @AuraEnabled(cacheable=true)
    public static Case getCurrentCase(Id csId) {
        List<Case> caseRecord;

        if (Schema.sObjectType.Case.isAccessible()) {
            String query = 'SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Core_IPS_Supported_Product__c, ' +
                'Core_Severity_Reason__c, Core_CaseType__c, Core_IPS_Legacy_IPS_ID__c, Core_IPS_Classification__c, ' +
                'Core_IPS_Bug_Doc_Fix_ID__c, Core_IPS_Case_Owner_Name__c, core_Account_Name__c, Core_Contact_Name__c, ' +
                'Core_Case_Resolution_Reason__c, Core_Customer_Reference_ID__c, Core_End_Customer__c, Subject, Description, ' +
                'Core_Issue_Description__c, Core_IPS_Restricted_Secret_Content__c, Core_IPS_Knowledge_Base_Link__c, ' +
                'Core_IPS_Project_Case__c, Core_Case_Issue_Category__c, Core_IPS_Product_name__c, ProductId, Asset.Id, ' +
                'Core_IPS_Project_Case__r.Name, Core_IPS_GEC_Flag__c, Core_Case_Issue_Sub_Category__c, ' +
                'Core_External_Issue_Subcategory__c, Core_External_Issue_Category__c, Core_IPS_Premier_Support_Project_ID__c, ' +
                'Core_jsonfield__c, Core_Partner_Supported_Account__c, Core_Product_Variant__c, RecordType.DeveloperName, ' +
                'Core_IPS_Partner_Sup_Owner__c FROM Case WHERE Id = :csId AND Core_IPS_Customer_Visible__c = true';

            caseRecord = (List<Case>) Core_IPS_QueryService.queryRecords(query, new Map<String, Object>{
                'csId' => csId
            });
        }

        if (caseRecord != null && !caseRecord.isEmpty()) {
            return caseRecord[0];
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static User getcurUsername() {
        String query = 'SELECT Id, Name, Email, Profile.Name FROM User WHERE Id = :userId';
        return (User) Core_IPS_QueryService.querySingleRecord(query, new Map<String, Object>{
            'userId' => UserInfo.getUserId()
        });
    }

    @AuraEnabled
    public static String deleteAttachmentRecord(String attId) {
        String query = 'SELECT Id, Name, Core_File_Name__c FROM Core_IPS_Case_Attachments__c WHERE Id = :attId';
        List<Core_IPS_Case_Attachments__c> attList = (List<Core_IPS_Case_Attachments__c>) Core_IPS_QueryService.queryRecords(query, new Map<String, Object>{
            'attId' => attId
        });

        try {
            if (attList != null && !attList.isEmpty()) {
                if (Schema.sObjectType.Core_IPS_Case_Attachments__c.isDeletable()) {
                    Core_IPS_QueryService.deleteRecords(new List<SObject>{ attList[0] });
                }
            }
            return 'Deleted';
        } catch (Exception e) {
            return 'Not Deleted';
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Core_IPS_Case_Comments__c> getCurrentCaseComments(Id csId) {
        List<Core_IPS_Case_Comments__c> caseComments;
        List<Core_IPS_Case_Comments__c> cscmtresult = new List<Core_IPS_Case_Comments__c>();

        String strqry = 'SELECT Id, Name, Core_IPS_Case_Comment_Type__c, Core_IPS_Case_Comment_Source__c, ' +
            'Core_IPS_Case__r.core_Account_Name__c, CreatedBy.Name, Core_IPS_Comment__c, Core_IPS_Rich_Comment__c, ' +
            'Core_IPS_Comment_Authored_By_Email__c, CreatedBy_Name__c, CreatedDate, Core_IPS_Comment_Author_Type__c, CreatedBy.Email, ';

        User userObj = (User) Core_IPS_QueryService.querySingleRecord(
            'SELECT Id, Name, Email, Profile.Name FROM User WHERE Id = :userId',
            new Map<String, Object>{ 'userId' => UserInfo.getUserId() }
        );

        String profile = getcurrentuserprofile();

        if (profile == 'Customer') {
            strqry += ' Core_IPS_Comment_Authored_By_Name__c, Core_IPS_Comment_Authored_By_FirstName__c ' +
                'FROM Core_IPS_Case_Comments__c WHERE Core_IPS_Case__c = :csId AND Core_IPS_Case_Comment_Type__c = \'Public to Customers\'';
        } else if (profile == 'PartnerAgent') {
            strqry += ' Core_IPS_Comment_Authored_By_Name__c, Core_IPS_Comment_Authored_By_FirstName__c ' +
                'FROM Core_IPS_Case_Comments__c WHERE Core_IPS_Case__c = :csId AND ' +
                '(Core_IPS_Case_Comment_Type__c = \'Private to Agents\' OR Core_IPS_Case_Comment_Type__c = \'Private to Intel\' OR ' +
                'Core_IPS_Case_Comment_Type__c = \'Private to Partner\' OR Core_IPS_Case_Comment_Type__c = \'Public to Customers\')';
        } else if (profile == 'PartnerFAE') {
            strqry += ' Core_IPS_Comment_Authored_By_Name__c, Core_IPS_Comment_Authored_By_FirstName__c ' +
                'FROM Core_IPS_Case_Comments__c WHERE Core_IPS_Case__c = :csId AND ' +
                '(Core_IPS_Case_Comment_Type__c = \'Private to Partner\' OR Core_IPS_Case_Comment_Type__c = \'Public to Customers\')';
        } else {
            strqry += ' Core_IPS_Comment_Authored_By_Name__c, Core_IPS_Comment_Authored_By_FirstName__c ' +
                'FROM Core_IPS_Case_Comments__c WHERE Core_IPS_Case__c = :csId AND Core_IPS_Case_Comment_Type__c = \'Public to Customers\'';
        }

        strqry += ' ORDER BY CreatedDate DESC';

        caseComments = (List<Core_IPS_Case_Comments__c>) Core_IPS_QueryService.queryRecords(strqry, new Map<String, Object>{
            'csId' => csId
        });

        if (caseComments != null) {
            cscmtresult = frmtComments(caseComments, profile);
            return cscmtresult;
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Case_Comments__c> frmtComments(List<Core_IPS_Case_Comments__c> caseComments, String profile) {
        for (Core_IPS_Case_Comments__c cmt : caseComments) {
            if (cmt.Core_IPS_Case_Comment_Type__c == 'Public to Customers') {
                if (cmt.Core_IPS_Comment_Authored_By_Email__c != ' ' && cmt.Core_IPS_Comment_Authored_By_Email__c != null &&
                    (cmt.Core_IPS_Comment_Author_Type__c == 'Customer' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner' ||
                     cmt.Core_IPS_Comment_Author_Type__c == 'Partner - DFAE')) {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case__r.core_Account_Name__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.Core_IPS_Comment_Authored_By_Email__c + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if (cmt.CreatedBy.Email != null &&
                    (cmt.Core_IPS_Comment_Author_Type__c == 'Customer' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner' ||
                     cmt.Core_IPS_Comment_Author_Type__c == 'Partner - DFAE')) {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case__r.core_Account_Name__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.CreatedBy.Email + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if (cmt.Core_IPS_Comment_Author_Type__c == 'Customer' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner' ||
                    cmt.Core_IPS_Comment_Author_Type__c == 'Partner - DFAE') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case__r.core_Account_Name__c + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if ((cmt.Core_IPS_Comment_Author_Type__c == 'Agent' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner - Agent' ||
                    cmt.Core_IPS_Comment_Author_Type__c == 'Backend Integration') &&
                    (profile == 'Customer' || profile == 'Partner' || profile == 'PartnerFAE')) {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                    if (!String.isBlank(cmt.Core_IPS_Comment_Authored_By_FirstName__c)) {
                        cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                    }
                } else if (cmt.Core_IPS_Comment_Author_Type__c == 'Partner - Agent' && profile == 'Customer') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                } else if (cmt.Core_IPS_Comment_Authored_By_Email__c != ' ' && cmt.Core_IPS_Comment_Authored_By_Email__c != null &&
                    (cmt.Core_IPS_Comment_Author_Type__c == 'Agent' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner - Agent' ||
                     cmt.Core_IPS_Comment_Author_Type__c == 'Backend Integration') && profile == 'PartnerAgent') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.Core_IPS_Comment_Authored_By_Email__c + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if ((cmt.Core_IPS_Comment_Author_Type__c == 'Agent' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner - Agent' ||
                    cmt.Core_IPS_Comment_Author_Type__c == 'Backend Integration') &&
                    (profile == 'Customer' || profile == 'Partner' || profile == 'PartnerFAE')) {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                } else if (cmt.CreatedBy.Email != null &&
                    (cmt.Core_IPS_Comment_Author_Type__c == 'Agent' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner - Agent' ||
                     cmt.Core_IPS_Comment_Author_Type__c == 'Backend Integration') && profile == 'PartnerAgent') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.CreatedBy.Email + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if ((cmt.Core_IPS_Comment_Author_Type__c == 'FAE') &&
                    (profile == 'Customer' || profile == 'Partner' || profile == 'PartnerFAE')) {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + System.Label.Core_IPS_CaseRTF_Intel_Sales_Representative + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                } else if (cmt.CreatedBy.Email != null && cmt.Core_IPS_Comment_Author_Type__c == 'FAE' && profile == 'PartnerAgent') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + System.Label.Core_IPS_CaseRTF_Intel_Sales_Representative + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.CreatedBy.Email + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if (cmt.Core_IPS_Comment_Author_Type__c == 'FAE') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + System.Label.Core_IPS_CaseRTF_Intel_Sales_Representative + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if (cmt.Core_IPS_Comment_Author_Type__c == 'Data Migration') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + System.Label.Core_IPS_Data_Migration_Profile_Name + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = System.Label.Core_IPS_Data_Migration_Profile_Name;
                } else if (cmt.Core_IPS_Comment_Author_Type__c == 'Agent' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner - Agent') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                }
            } else {
                if (cmt.Core_IPS_Comment_Authored_By_Email__c != ' ' && cmt.Core_IPS_Comment_Authored_By_Email__c != null &&
                    (cmt.Core_IPS_Comment_Author_Type__c == 'Customer' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner' ||
                     cmt.Core_IPS_Comment_Author_Type__c == 'Partner - DFAE')) {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.Core_IPS_Case__r.core_Account_Name__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.Core_IPS_Comment_Authored_By_Email__c + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if (cmt.CreatedBy.Email != null &&
                    (cmt.Core_IPS_Comment_Author_Type__c == 'Customer' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner' ||
                     cmt.Core_IPS_Comment_Author_Type__c == 'Partner - DFAE')) {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.Core_IPS_Case__r.core_Account_Name__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.CreatedBy.Email + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if (cmt.Core_IPS_Comment_Author_Type__c == 'Customer' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner' ||
                    cmt.Core_IPS_Comment_Author_Type__c == 'Partner - DFAE') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.Core_IPS_Case__r.core_Account_Name__c + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if ((cmt.Core_IPS_Comment_Author_Type__c == 'Agent' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner - Agent' ||
                    cmt.Core_IPS_Comment_Author_Type__c == 'Backend Integration') &&
                    (profile == 'Customer' || profile == 'Partner' || profile == 'PartnerFAE')) {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                } else if (cmt.Core_IPS_Comment_Author_Type__c == 'Partner - Agent' && profile == 'Customer') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                } else if (cmt.Core_IPS_Comment_Authored_By_Email__c != ' ' && cmt.Core_IPS_Comment_Authored_By_Email__c != null &&
                    (cmt.Core_IPS_Comment_Author_Type__c == 'Agent' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner - Agent' ||
                     cmt.Core_IPS_Comment_Author_Type__c == 'Backend Integration') && profile == 'PartnerAgent') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.Core_IPS_Comment_Authored_By_Email__c + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if ((cmt.Core_IPS_Comment_Author_Type__c == 'Agent' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner - Agent' ||
                    cmt.Core_IPS_Comment_Author_Type__c == 'Backend Integration') &&
                    (profile == 'Customer' || profile == 'Partner' || profile == 'PartnerFAE')) {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                } else if (cmt.CreatedBy.Email != null &&
                    (cmt.Core_IPS_Comment_Author_Type__c == 'Agent' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner - Agent' ||
                     cmt.Core_IPS_Comment_Author_Type__c == 'Backend Integration') && profile == 'PartnerAgent') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.CreatedBy.Email + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if ((cmt.Core_IPS_Comment_Author_Type__c == 'FAE') &&
                    (profile == 'Customer' || profile == 'Partner' || profile == 'PartnerFAE')) {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        System.Label.Core_IPS_CaseRTF_Intel_Sales_Representative + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = cmt.Core_IPS_Comment_Authored_By_FirstName__c;
                } else if (cmt.CreatedBy.Email != null && cmt.Core_IPS_Comment_Author_Type__c == 'FAE' && profile == 'PartnerAgent') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        System.Label.Core_IPS_CaseRTF_Intel_Sales_Representative + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        cmt.CreatedBy.Email + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if (cmt.Core_IPS_Comment_Author_Type__c == 'FAE') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        System.Label.Core_IPS_CaseRTF_Intel_Sales_Representative + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                } else if (cmt.Core_IPS_Comment_Author_Type__c == 'Data Migration') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        System.Label.Core_IPS_Data_Migration_Profile_Name + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                    cmt.Core_IPS_Comment_Authored_By_Name__c = System.Label.Core_IPS_Data_Migration_Profile_Name;
                } else if (cmt.Core_IPS_Comment_Author_Type__c == 'Agent' || cmt.Core_IPS_Comment_Author_Type__c == 'Partner - Agent') {
                    cmt.Core_IPS_Rich_Comment__c = '<b>' + cmt.Core_IPS_Case_Comment_Type__c + '</b>&nbsp&nbsp&nbsp&nbsp<b>' +
                        System.Label.Core_IPS_CaseRTF_Intel_Technical_Specialist + '</b><br/>' + cmt.Core_IPS_Rich_Comment__c;
                }
            }
        }

        return caseComments;
    }

    @AuraEnabled(cacheable=true)
    public static String getcurrentuserprofile() {
        String userId = UserInfo.getUserId();

        User currentUser = (User) Core_IPS_QueryService.querySingleRecord(
            'SELECT Id, Name, Profile.Name, Profile.Id FROM User WHERE Id = :userId',
            new Map<String, Object>{ 'userId' => userId }
        );

        List<PermissionSetAssignment> pset = (List<PermissionSetAssignment>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment ' +
            'WHERE Assignee.Id = :userId AND PermissionSet.Name = \'Core_IPS_Partner_FAE_Permission_Set\'',
            new Map<String, Object>{ 'userId' => userId }
        );

        String profileName = null;

        if (currentUser != null && currentUser.Profile != null && currentUser.Profile.Name == System.Label.Core_IPS_External_Customer_Profile) {
            profileName = 'Customer';
            return profileName;
        } else if (currentUser != null && currentUser.Profile != null && currentUser.Profile.Id == System.Label.Core_IPS_Agent_Partner_Profile_id) {
            profileName = 'PartnerAgent';
            return profileName;
        } else if (currentUser != null && currentUser.Profile != null &&
            !pset.isEmpty() && currentUser.Profile.Name == System.Label.Core_IPS_Partner_Profile_Name &&
            pset[0].PermissionSet.Name == 'Core_IPS_Partner_FAE_Permission_Set') {
            profileName = 'PartnerFAE';
            return profileName;
        }

        profileName = 'Partner';
        return profileName;
    }

    @AuraEnabled(cacheable=true)
    public static String getcurCaseContactProfile(ID caseId) {
        Case cs = getCurrentCase(caseId);

        if (cs == null || String.isBlank(cs.Core_Contact_Name__c)) {
            return null;
        }

        List<User> contactUsers = (List<User>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, Name, Profile.Name, Profile.Id FROM User WHERE Name = :contactName AND (Profile.Name = \'IPS External Customer\' OR Profile.Name = \'Partner\') LIMIT 1',
            new Map<String, Object>{ 'contactName' => cs.Core_Contact_Name__c }
        );

        if (contactUsers != null && !contactUsers.isEmpty()) {
            return contactUsers[0].Profile.Name;
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static String getcurcasestatus(String caseID) {
        Case caseRecord = (Case) Core_IPS_QueryService.querySingleRecord(
            'SELECT Id, CaseNumber, Status FROM Case WHERE Id = :caseId',
            new Map<String, Object>{ 'caseId' => caseID }
        );

        return (caseRecord != null) ? caseRecord.Status : null;
    }

    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Case_Attachments__c> getattachments(String caseID) {
        List<Core_IPS_Case_Attachments__c> cdoc = new List<Core_IPS_Case_Attachments__c>();

        String strqry = 'SELECT Name, Core_Case__c, Core_File_GUID__c, Core_Case__r.Status, Core_File_URL__c, Core_File_Hyperlink__c, ' +
            'CreatedDate, Core_File_Description__c, Core_File_Name__c, Core_File_Size__c, Core_Upload_Status__c, ' +
            'Core_IPS_Attachment_Visibility__c FROM Core_IPS_Case_Attachments__c WHERE Core_Case__c = :caseId';

        User userObj = (User) Core_IPS_QueryService.querySingleRecord(
            'SELECT Id, Profile.Name FROM User WHERE Id = :userId',
            new Map<String, Object>{ 'userId' => UserInfo.getUserId() }
        );

        String partnerProf = System.Label.Core_IPS_Partner_Profile_Id;
        String partnerType;

        if (userObj != null && userObj.Profile != null &&
            System.Label.Core_IPS_External_Customer_Profile.contains(String.valueOf(userObj.Profile.Name))) {
            strqry += ' AND Core_IPS_Attachment_Visibility__c = \'Public to Customers\'';
        } else if (System.Label.Core_IPS_Agent_Partner_Profile_id.contains(String.valueOf(UserInfo.getProfileId()).substring(0, 15))) {
            strqry += ' AND (Core_IPS_Attachment_Visibility__c = \'Private to Intel\' OR Core_IPS_Attachment_Visibility__c = \'Private to Partner\' OR ' +
                'Core_IPS_Attachment_Visibility__c = \'Public to Customers\')';
        } else if (partnerProf.contains(String.valueOf(UserInfo.getProfileId()).substring(0, 15))) {
            String uploadpartnerProfileType = Core_Utility.getPartnerUserType(UserInfo.getUserId());
            if (uploadpartnerProfileType != null && uploadpartnerProfileType.length() > 0) {
                partnerType = uploadpartnerProfileType.split(';')[0];
            }

            if (partnerType != null && String.isNotBlank(partnerType)) {
                if (partnerType == 'Partner - DFAE') {
                    strqry += ' AND (Core_IPS_Attachment_Visibility__c = \'Private to Partner\' OR Core_IPS_Attachment_Visibility__c = \'Public to Customers\')';
                } else if (partnerType == 'Partner') {
                    strqry += ' AND Core_IPS_Attachment_Visibility__c = \'Public to Customers\'';
                }
            }
        }

        strqry += ' ORDER BY CreatedDate DESC';

        cdoc = (List<Core_IPS_Case_Attachments__c>) Core_IPS_QueryService.queryRecords(strqry, new Map<String, Object>{
            'caseId' => caseID
        });

        for (Core_IPS_Case_Attachments__c att : cdoc) {
            if (att.Core_Upload_Status__c == 'Pending') {
                String url = att.Core_File_Hyperlink__c;
                url = url.replace('<a href="', '').replace('" target="Self">Resume</a>', ' ').replace('amp;', '').trim();
                att.Core_File_URL__c = url;
            }
        }
        return cdoc;
    }

    @AuraEnabled(Cacheable=false)
    public static String getCaseClosed(Id caseId) {
        String status = 'success';
        Boolean isEditable;

        if (Schema.sObjectType.UserRecordAccess.isAccessible()) {
            List<UserRecordAccess> accessList = (List<UserRecordAccess>) Core_IPS_QueryService.queryRecords(
                'SELECT HasEditAccess, RecordId FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :caseId',
                new Map<String, Object>{
                    'userId' => UserInfo.getUserId(),
                    'caseId' => caseId
                }
            );

            if (!accessList.isEmpty()) {
                isEditable = accessList[0].HasEditAccess;
            }
        }

        Case cs = new Case();

        List<Case> csList = (List<Case>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, Status FROM Case WHERE Id = :caseId',
            new Map<String, Object>{ 'caseId' => caseId }
        );

        if (csList != null && !csList.isEmpty()) {
            cs = csList[0];
        }

        try {
            if (cs.Status != 'Closed') {
                cs.Id = caseId;
                if (isEditable) {
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
                Core_IPS_QueryService.updateRecords(new List<SObject>{ cs });
            }

            Case csObj = new Case();
            if (isEditable) {
                csObj.Id = caseId;
                if (Schema.sObjectType.case.fields.Core_IPS_Partner_status_ReadOnly__c.isUpdateable()) {
                    csObj.Core_IPS_Partner_status_ReadOnly__c = false;
                }
            }
            Core_IPS_QueryService.updateRecords(new List<SObject>{ csObj });
        } catch (Exception e) {
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'Core_IPS_TestAllRecords', 'Case');
            status = e.getMessage();
        }
        return status;
    }

    @AuraEnabled(Cacheable=false)
    public static String saveNewComment(String csId, String visibility, String comment) {
        String status = 'success';
        try {
            comment = comment.unescapeHTML4();
            comment = comment.trim();

            if (comment == '' || comment == null) {
                status = 'Blank Comment';
            } else {
                Core_IPS_CaseCommentLWCController.initialize(csId);
                status = Core_IPS_CaseCommentLWCController.saveCaseComment(csId, visibility, comment);
            }
        } catch (Exception e) {
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'Core_IPS_TestAllRecords', 'Core_IPS_Case_Comments__c');
            status = 'error';
        }
        return status;
    }

    @AuraEnabled(Cacheable=false)
    public static String updateCaseDetails(Id caseId, String caseData) {
        Map<String, String> values = (Map<String, String>) JSON.deserialize(caseData, Map<String, String>.class);
        String subject = values.get('subject');
        String description = values.get('description');
        String caseType = values.get('CaseType');
        String severity = values.get('Severity');
        String customerRefId = values.get('customerRefId');
        String endCustomer = values.get('endCustomer');
        String caseCategory = values.get('caseCategory');
        String caseSubCategory = values.get('caseSubCategory');

        Case cs = new Case();
        if (caseId != null) {
            cs.Id = caseId;
        }

        if (subject != null || Schema.sObjectType.Case.fields.Subject.isUpdateable()) {
            cs.Subject = subject;
        }
        if (description != null || Schema.sObjectType.Case.fields.Core_Issue_Description__c.isUpdateable() || Schema.sObjectType.Case.fields.Description.isUpdateable()) {
            cs.Description = description;
            cs.Core_Issue_Description__c = description;
        }
        if (caseType != null || Schema.sObjectType.Case.fields.Core_CaseType__c.isUpdateable()) {
            cs.Core_CaseType__c = caseType;
        }
        if (severity != null || Schema.sObjectType.Case.fields.Core_Severity__c.isUpdateable()) {
            cs.Core_Severity__c = severity;
        }
        if (customerRefId != null || Schema.sObjectType.Case.fields.Core_Customer_Reference_ID__c.isUpdateable()) {
            cs.Core_Customer_Reference_ID__c = customerRefId;
        }
        if (endCustomer != null || Schema.sObjectType.Case.fields.Core_End_Customer__c.isUpdateable()) {
            cs.Core_End_Customer__c = endCustomer;
        }
        if (caseCategory != null || Schema.sObjectType.Case.fields.Core_External_Issue_Category__c.isUpdateable()) {
            cs.Core_External_Issue_Category__c = caseCategory;
        }
        if (caseSubCategory != null || Schema.sObjectType.Case.fields.Core_External_Issue_Subcategory__c.isUpdateable()) {
            cs.Core_External_Issue_Subcategory__c = caseSubCategory;
        }

        Core_IPS_QueryService.updateRecords(new List<SObject>{ cs });
        return caseData;
    }

    @AuraEnabled(cacheable=true)
    public static Wrapsearchresult getSearchResult(String searchKey) {
        User loggedInUser = (User) Core_IPS_QueryService.querySingleRecord(
            'SELECT Id, Name, ProfileId, ContactId, Contact.AccountId FROM User WHERE Id = :userId',
            new Map<String, Object>{ 'userId' => UserInfo.getUserId() }
        );

        String loggedInUserAcctId = loggedInUser.Contact.AccountId;
        String loggedInUserContId = loggedInUser.ContactId;
        Integer globalSearchDataLimit = Integer.valueOf(System.Label.Core_IPS_Portal_GlobalSearchDT_Limit);

        String searchKeyword = '%' + searchKey + '%';
        Wrapsearchresult wraplist = new Wrapsearchresult();

        Set<Id> projList = new Set<Id>();
        List<Core_IPS_Project_Member__c> projMemList = (List<Core_IPS_Project_Member__c>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, Name, Core_IPS_Contact__c, Core_IPS_Project__c, Core_IPS_Contact__r.FirstName, Core_IPS_Contact__r.Account.Name ' +
            'FROM Core_IPS_Project_Member__c WHERE Core_IPS_Contact__c = :contactId',
            new Map<String, Object>{ 'contactId' => loggedInUserContId }
        );

        for (Core_IPS_Project_Member__c p : projMemList) {
            projList.add(p.Core_IPS_Project__c);
        }

        wraplist.caselist = (List<Case>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, ' +
            'Core_IPS_Project_Case__r.Name, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, ' +
            'Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, ' +
            'Core_Customer_Reference_ID__c, Core_IPS_Premier_Support_Project_ID__c, AccountId ' +
            'FROM Case WHERE (AccountId = :acctId OR Core_IPS_Project_Case__c IN :projList) ' +
            'AND Core_IPS_Customer_Visible__c = true AND (Core_IPS_Product_name__c LIKE :searchKeyword OR ' +
            'Core_IPS_Project_Case__r.Name LIKE :searchKeyword OR Subject LIKE :searchKeyword OR CaseNumber LIKE :searchKeyword) ' +
            'LIMIT :limitSize',
            new Map<String, Object>{
                'acctId' => loggedInUserAcctId,
                'projList' => projList,
                'searchKeyword' => searchKeyword,
                'limitSize' => globalSearchDataLimit
            }
        );

        wraplist.prodlist = (List<Asset>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, Name, core_Product_Application__c, Core_IPS_Support_License__c, Core_IPS_Project_Id__c, ' +
            'Core_IPS_Project__r.Name, Account.Name FROM Asset WHERE Name LIKE :searchKeyword LIMIT :limitSize',
            new Map<String, Object>{
                'searchKeyword' => searchKeyword,
                'limitSize' => globalSearchDataLimit
            }
        );

        wraplist.projlist = (List<Core_IPS_Project__c>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, Name, CreatedDate, Core_Project_Description__c, Core_Status__c FROM Core_IPS_Project__c WHERE Name LIKE :searchKeyword LIMIT :limitSize',
            new Map<String, Object>{
                'searchKeyword' => searchKeyword,
                'limitSize' => globalSearchDataLimit
            }
        );

        return wraplist;
    }

    public class Wrapsearchresult {
        @AuraEnabled
        public List<Case> caselist { get; set; }
        @AuraEnabled
        public List<Asset> prodlist { get; set; }
        @AuraEnabled
        public List<Core_IPS_Project__c> projlist { get; set; }
    }

    @AuraEnabled(Cacheable=false)
    public static List<Core_IPS_Response__c> getEnvDetails(String csId) {
        List<Core_IPS_Response__c> responseList = new List<Core_IPS_Response__c>();
        String profile = getcurrentuserprofile();

        if (csId != null) {
            if (profile == 'PartnerFAE' || profile == 'Partner') {
                responseList = (List<Core_IPS_Response__c>) Core_IPS_QueryService.queryRecords(
                    'SELECT Core_IPS_Case__c, Core_IPS_Answer__c, Core_IPS_Question__c ' +
                    'FROM Core_IPS_Response__c WHERE Core_IPS_Case__c = :csId AND Core_IPS_Agent_Only__c != true',
                    new Map<String, Object>{ 'csId' => csId }
                );
            } else {
                responseList = (List<Core_IPS_Response__c>) Core_IPS_QueryService.queryRecords(
                    'SELECT Core_IPS_Case__c, Core_IPS_Answer__c, Core_IPS_Question__c FROM Core_IPS_Response__c WHERE Core_IPS_Case__c = :csId',
                    new Map<String, Object>{ 'csId' => csId }
                );
            }
        }
        return responseList;
    }

    @AuraEnabled
    public static User getPartnerSupportOwner(String passedProjectId) {
        List<core_ips_project__c> projList = (List<core_ips_project__c>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, Name, Core_IPS_Partner_Support_Owner__c FROM core_ips_project__c WHERE Id = :projectId',
            new Map<String, Object>{ 'projectId' => passedProjectId }
        );

        String partnerSupportOwner = '';
        User passUserDetails;

        try {
            if (projList != null && !projList.isEmpty() && projList[0].Core_IPS_Partner_Support_Owner__c != null) {
                partnerSupportOwner = projList[0].Core_IPS_Partner_Support_Owner__c;
            } else {
                partnerSupportOwner = UserInfo.getUserId();
            }

            passUserDetails = getUserDetail(partnerSupportOwner);
        } catch (Exception e) {
        }

        return passUserDetails;
    }

    public static User getUserDetail(String userId) {
        User usDetail = new User();

        try {
            if (userId != null && userId != '') {
                usDetail = (User) Core_IPS_QueryService.querySingleRecord(
                    'SELECT Id, Name FROM User WHERE Id = :userId',
                    new Map<String, Object>{ 'userId' => userId }
                );
            }
        } catch (Exception e) {
        }
        return usDetail;
    }

    @AuraEnabled
    public static Map<Id, String> getSupportedAccount(String selectedProject, String userID) {
        if (selectedProject == 'NoProj') {
            selectedProject = null;
        }

        List<Core_IPS_Project_Member__c> projMembersList = new List<Core_IPS_Project_Member__c>();
        Set<Id> projIds = new Set<Id>();

        if (!String.isBlank(userID)) {
            List<User> contIdValLst = (List<User>) Core_IPS_QueryService.queryRecords(
                'SELECT Id, ContactId FROM User WHERE Id = :userId LIMIT 1',
                new Map<String, Object>{ 'userId' => userID }
            );

            if (contIdValLst != null && !contIdValLst.isEmpty()) {
                String contId = contIdValLst[0].ContactId;

                if (Schema.sObjectType.Core_IPS_Project_Member__c.isAccessible()) {
                    projMembersList = (List<Core_IPS_Project_Member__c>) Core_IPS_QueryService.queryRecords(
                        'SELECT Id, Name, Core_IPS_Project__c, Core_IPS_Contact_Account__c FROM Core_IPS_Project_Member__c ' +
                        'WHERE Core_IPS_Contact__c = :contactId AND Core_Status__c = \'Active\'',
                        new Map<String, Object>{ 'contactId' => contId }
                    );
                }
            }
        }

        for (Integer i = 0; i < projMembersList.size(); i++) {
            projIds.add(projMembersList[i].Core_IPS_Project__c);
        }

        if (!String.isBlank(selectedProject) && selectedProject != 'NA') {
            projIds.clear();
            projIds.add(Id.valueOf(selectedProject));
        }

        List<Core_IPS_Account__c> projMemAccounts = new List<Core_IPS_Account__c>();

        if (Schema.sObjectType.Core_IPS_Account__c.isAccessible()) {
            projMemAccounts = (List<Core_IPS_Account__c>) Core_IPS_QueryService.queryRecords(
                'SELECT Id, Name, Core_Account__r.Id, Core_Account__c, Core_IPS_Account_Name__c, Core_IPS_Project__r.Name, Core_IPS_Project__c ' +
                'FROM Core_IPS_Account__c WHERE Core_IPS_Project__c IN :projIds AND Core_Account__c != null AND Core_IPS_Account_Name__c != null AND Core_Status__c = \'Active\'',
                new Map<String, Object>{ 'projIds' => projIds }
            );
        }

        Map<Id, String> accountMap = new Map<Id, String>();

        if (projMemAccounts != null && !projMemAccounts.isEmpty()) {
            for (Core_IPS_Account__c ipsacc : projMemAccounts) {
                accountMap.put(ipsacc.Core_Account__c, ipsacc.Core_IPS_Account_Name__c);
            }
        }
        return accountMap;
    }

    @AuraEnabled
    public static Case getSupOwnerAndSupAccountforEditCase(String caseId) {
        Case cs = new Case();

        try {
            if (Schema.sObjectType.Case.isAccessible()) {
                cs = (Case) Core_IPS_QueryService.querySingleRecord(
                    'SELECT Core_IPS_Partner_Sup_Owner__r.Name, Core_IPS_Partner_Sup_Owner__c, Core_Partner_Supported_Account__r.Name, Core_Partner_Supported_Account__c ' +
                    'FROM Case WHERE Id = :caseId',
                    new Map<String, Object>{ 'caseId' => caseId }
                );
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return cs;
    }

    @AuraEnabled
    public static Case submitCaseClosureRes(Case updateCase) {
        Case cs = new Case();

        try {
            cs.Id = updateCase.Id;

            if (Schema.sObjectType.case.fields.Status.isUpdateable()) {
                cs.Status = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Case_Status_Open');
            }
            if (Schema.sObjectType.case.fields.Core_Sub_Status__c.isUpdateable()) {
                cs.Core_Sub_Status__c = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Close_Pending_SubStatus');
            }
            if (Schema.sObjectType.case.fields.Core_Case_Resolution_Reason__c.isUpdateable()) {
                cs.Core_Case_Resolution_Reason__c = updateCase.Core_Case_Resolution_Reason__c;
            }
            if (Schema.sObjectType.case.fields.Core_IPS_Bug_Doc_Fix_ID__c.isUpdateable()) {
                cs.Core_IPS_Bug_Doc_Fix_ID__c = updateCase.Core_IPS_Bug_Doc_Fix_ID__c;
            }
            if (Schema.sObjectType.case.fields.Core_IPS_Knowledge_Base_Link__c.isUpdateable()) {
                cs.Core_IPS_Knowledge_Base_Link__c = updateCase.Core_IPS_Knowledge_Base_Link__c;
            }

            Core_IPS_QueryService.updateRecords(new List<SObject>{ cs });
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return cs;
    }

    @AuraEnabled(cacheable=true)
    public static Core_IPS_Project__c getProjectStatus(String projectId) {
        List<Core_IPS_Project__c> projectObj = new List<Core_IPS_Project__c>();

        try {
            if (Schema.sObjectType.Core_IPS_Project__c.isAccessible()) {
                projectObj = (List<Core_IPS_Project__c>) Core_IPS_QueryService.queryRecords(
                    'SELECT Id, Core_Status__c FROM Core_IPS_Project__c WHERE Id = :projectId',
                    new Map<String, Object>{ 'projectId' => projectId }
                );
            }

            if (projectObj != null && projectObj.size() > 0) {
                return projectObj[0];
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Asset getProductStatus(String assetId) {
        List<Asset> assetObj = new List<Asset>();

        try {
            if (Schema.sObjectType.Asset.isAccessible()) {
                assetObj = (List<Asset>) Core_IPS_QueryService.queryRecords(
                    'SELECT Id, Status FROM Asset WHERE Id = :assetId',
                    new Map<String, Object>{ 'assetId' => assetId }
                );
            }

            if (assetObj != null && assetObj.size() > 0) {
                return assetObj[0];
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}