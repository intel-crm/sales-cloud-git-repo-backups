/****************************************************************************************************************************************
 * Class Name  : Core_IPS_Portal_Project_Controller
 * Version     : 1.0
 * Created Date:  03/02/2022
 * Modification Log :
 * Developer                     Date                          Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Team: PopcornApps            03/02/2022                    Main Controller to create Premier Support Projects As IPS External Customer
 *****************************************************************************************************************************************/
public with sharing class Core_IPS_Portal_Project_Controller{
    public static Core_IPS_Project__c ipsProject;
    public static User loggedInUser;
    @AuraEnabled
    public static List<Contact> AvailablecontactsforaddingtoprojectMembers(String projIdfromJS){
        String queryStr = null;
        if (projIdfromJS != null){
            //FLS SOSL fix applied Nagendra Phani 09/11/2022
            queryStr = String.escapeSingleQuotes(projIdfromJS);
        }

        List<Contact> sobjListAPM;
        try{
            Core_IPS_Project__c ipsProject = new Core_IPS_Project__c();
            loggedInUser = (User)Core_IPS_QueryService.queryRecords(
                'Select Id, Name, profileId, ContactId, Contact.AccountId From User where Id = :userId',
                new Map<String, Object>{ 'userId' => UserInfo.getUserId() }
            )[0];
            String loggedInUserAcctId = loggedInUser.Contact.AccountId;
            String loggedInUserContId = loggedInUser.ContactId;
            Integer projMemberDataLimit = Integer.valueOf(System.Label.Core_IPS_Portal_ProjMember_Limit);

            String query = null;
            // SOQL Injection Fix - Start -  Shipra
            Map<String, Object> bindMap = new Map<String, Object>{ 'LoggedInUserAcctId' => loggedInUserAcctId, 'LoggedInUserContId' => loggedInUserContId, 'Status' => 'Active', 'ProjMemberDataLimit' => projMemberDataLimit, 'queryString' =>(queryStr == null ? '' : queryStr) };
            query = 'Select id,Name,LastName, FirstName,Core_Status__c, Email, Account.Name, Core_IPS_Active__c,Core_IPS_Email_Opt_Out__c From Contact Where AccountId =:loggedInUserAcctId  AND ID != :loggedInUserContId   AND Core_IPS_Active__c  = true';
            query += ' AND ID NOT IN ( Select Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where  Core_Status__c = :Status AND Core_IPS_Project__c =  :queryString ) And ID in (SELECT ContactId FROM User) LIMIT :projMemberDataLimit'; // IsActive remove by tushar garg because of Inactive Users (due to UIOLI) should be added as Project members
            sobjListAPM = Database.queryWithBinds(query, bindMap, AccessLevel.USER_MODE);
            // SOQL Injection Fix - End -  Shipra
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return sobjListAPM;
    }

    @AuraEnabled
    public static List<Asset> AvailableIPSProducts(String projIdfromJS){
        String queryStr = null;
        if (projIdfromJS != null){
            //FLS SOSL fix applied Nagendra Phani 09/11/2022
            queryStr = String.escapeSingleQuotes(projIdfromJS);
        }

        List<Asset> sobjListAprdos;
        try{
            loggedInUser = (User)Core_IPS_QueryService.queryRecords(
                'Select Id, Name, profileId, ContactId, Contact.AccountId From User where Id = :userId',
                new Map<String, Object>{ 'userId' => UserInfo.getUserId() }
            )[0];

            String loggedInUserAcctId = loggedInUser.Contact.AccountId;
            String loggedInUserContId = loggedInUser.ContactId;
            String query = null;
              // SOQL Injection Fix - Start -  Shipra
              Map<String, Object> bindMap = new Map<String, Object>{ 'LoggedInUserAcctId' => loggedInUserAcctId, 'recordType' => 'Public Products', 'Status' => 'Active','queryString' =>(queryStr == null ? '' : queryStr) };
            
            query = 'Select Name,Account.Name, Core_Supported_Product__r.Core_Product_Organization__r.Name,core_Product_Application__c, Core_Supported_Product__r.Core_Flag_Status__c, ' + 
                    'Core_Code_Name__c,  InstallDate, Status, Description, Core_IPS_Asset__c, Core_IPS_Project__c, Core_Supported_Product__c, Core_Product_Organization__c ' + 
                    'From Asset ' + 
                    'Where (AccountId = :LoggedInUserAcctId or RecordType.Name = :recordType or Core_IPS_Project__c = Null ) AND status = :Status AND Core_IPS_Supported_Product_EOIS__c = false AND ' + 
                    'Core_Supported_Product__C NOT IN ( Select Core_Supported_Product__c FROM Core_IPS_Product__c WHERE Core_IPS_Product_Status__c = :Status AND Core_IPS_Project__c =  :queryString )';

            sobjListAprdos = Database.queryWithBinds(query, bindMap, AccessLevel.USER_MODE);
            // SOQL Injection Fix - End -  Shipra

        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return sobjListAprdos;
    }

    //create IPS Project
    @AuraEnabled
    public static Core_IPS_Project__c createProjects(String projName, String projDes, boolean parties, boolean notify, String userName){
        loggedInUser = (User)Core_IPS_QueryService.queryRecords(
            'Select Id, Name, profileId, ContactId, Contact.AccountId From User where Id = :userId',
            new Map<String, Object>{ 'userId' => UserInfo.getUserId() }
        )[0];
        String loggedInUserAcctId = loggedInUser.Contact.AccountId;
        String loggedInUserContId = loggedInUser.ContactId;
        ipsProject = new Core_IPS_Project__c();
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Name.isCreateable() || Schema.sObjectType.Core_IPS_Project__c.fields.Name.isUpdateable()){
            ipsProject.Name = projName;
        }
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_Project_Description__c.isCreateable() || Schema.sObjectType.Core_IPS_Project__c.fields.Core_Project_Description__c.isupdateable()){
            ipsProject.Core_Project_Description__c = projDes;
        }
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_Status__c.isUpdateable() || Schema.sObjectType.Core_IPS_Project__c.fields.Core_Status__c.isCreateable()){
            ipsProject.Core_Status__c = 'Draft';
        }
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_EnableMemberasInterestedParties__c.isCreateable() || Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_EnableMemberasInterestedParties__c.isupdateable()){
            ipsProject.Core_IPS_EnableMemberasInterestedParties__c = parties;
        }
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_Remove_Notification_Details__c.isCreateable() || Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_Remove_Notification_Details__c.isupdateable()){
            ipsProject.Core_IPS_Remove_Notification_Details__c = notify;
        }
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_Partner_Support_Owner__c.isCreateable() || Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_Partner_Support_Owner__c.isupdateable()){
            if (userName != 'None'){
                ipsProject.Core_IPS_Partner_Support_Owner__c = loggedInUser.id;
            }
        }
        // Venrublity Fix - Refering query to service class
        // upsert ipsProject;
        ipsProject = (Core_IPS_Project__c)Core_IPS_QueryService.upsertRecords(new List<SObject>{ ipsProject })[0];

        createIPSProject(ipsProject, loggedInUser);

        return ipsProject;
    }

    private static void createIPSProject(Core_IPS_Project__c ipsProject, User loggedInUser){
        Map<Id, Core_IPS_Project__c> mipsProject = new Map<Id, Core_IPS_Project__c>();
        mipsProject.put(ipsProject.id, ipsProject);
        createAccountOnProjectCreationForExternalCustomer(mipsProject, loggedInUser);
    }

    //Create an IPS Account
    public static void createAccountOnProjectCreationForExternalCustomer(Map<Id, Core_IPS_Project__c> projectMap, User loggerInUser){
        if (projectMap.values() != null && projectMap.values().size() > 0){
            try{
                Set<id> userCreatedByIds = new Set<id>();
                List<Core_IPS_Account__c> lstCoreIpsAccount = new List<Core_IPS_Account__c>();
                //List<Core_IPS_Project_Member__c> lstCoreIipsProjectrojectMembers = new List<Core_IPS_Project_Member__c>();
                for (Id coreips : projectMap.keyset()){
                    if (projectMap.get(coreips) != null){
                        Core_IPS_Account__c ipsAcc = new Core_IPS_Account__c();
                        if (Schema.sObjectType.Core_IPS_Account__c.fields.Core_IPS_Project__c.isCreateable()){
                            ipsAcc.Core_IPS_Project__c = coreips;
                        }
                        if (Schema.sObjectType.Core_IPS_Account__c.fields.Core_Status__c.isCreateable()){
                            ipsAcc.Core_Status__c = 'Active';
                        }
                        if (Schema.sObjectType.Core_IPS_Account__c.fields.Core_Members__c.isCreateable()){
                            ipsAcc.Core_Members__c = 'Selective';
                        }
                        if (Schema.sObjectType.Core_IPS_Account__c.fields.Core_Account__c.isCreateable()){
                            ipsAcc.Core_Account__c = loggerInUser.Contact.AccountId;
                        }
                        lstCoreIpsAccount.add(ipsAcc);
                        /*Commented this logic and moved it to add members logic where including the loggedin user also
                         Core_IPS_Project_Member__c coreMember = new Core_IPS_Project_Member__c();
                         if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isCreateable())
                         {
                         coreMember.Core_IPS_Project__c = coreips;
                         }
                         if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isCreateable())
                         {
                         coreMember.Core_Selective_Member__c = true;
                         }
                         if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isCreateable())
                         {
                         coreMember.Core_IPS_Contact__c = loggerInUser.ContactId;
                         }
                         if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isCreateable())
                         {
                         coreMember.Core_User__c = loggerInUser.Id;
                         }
                         lstCoreIipsProjectrojectMembers.add(coreMember);*/
                    }
                }
                // Venrublity Fix - Refering query to service class
                // Database.insert (lstCoreIpsAccount, false);
                lstCoreIpsAccount = (List<Core_IPS_Account__c>) Core_IPS_QueryService.insertRecords((List<SObject>) lstCoreIpsAccount);

                // Database.SaveResult[] results = Database.insert( lstCoreIipsProjectrojectMembers,false);
                //Added by Hassan
                for (Id coreIpsProjectUpdate : projectMap.Keyset()){
                    projectMap.get(coreIpsProjectUpdate).Core_Status__c = 'Active';
                }
                // Venrublity Fix - Refering query to service class
                // Upsert projectMap.values();
                Core_IPS_QueryService.upsertRecords((List<SObject>) projectMap.values());
            } catch (exception ex){
                String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                Core_IPS_ExceptionHandling.logEntryWithException(ex, 'Core_IPS_Portal_Project_Controller', 'GroupMember');
            }
        }
    }

    //Insert Project Members,Activate Members
    @AuraEnabled
    public static List<Core_IPS_Project_Member__c> upsertProjectMembers(list<Id> selectedIdsInsecondPage, string ipsProject){
        loggedInUser = (User)Core_IPS_QueryService.queryRecords(
            'Select Id, Name, profileId, ContactId, Contact.AccountId From User where Id = :userId',
            new Map<String, Object>{ 'userId' => UserInfo.getUserId() }
        )[0];
        List<Core_IPS_Project_Member__c> lProjMembers = new List<Core_IPS_Project_Member__c>();
        Map<Id, Id> contactUserMap = new Map<Id, Id>();
        List<User> userList = [SELECT ID, ContactID
                               FROM User
                               WHERE ContactID IN:selectedIdsInsecondPage];
        for (User us : userList){
            contactUserMap.put(us.ContactID, us.Id);
        }
        for (Id memberId : selectedIdsInsecondPage){
            Core_IPS_Project_Member__c pm = new Core_IPS_Project_Member__c();
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isupdateable()){
                pm.Core_IPS_Contact__c = memberId;
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isupdateable()){
                pm.Core_Selective_Member__c = true;
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isupdateable()){
                pm.Core_Status__c = 'Active';
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isupdateable()){
                pm.Core_User__c = contactUserMap.get(memberId);//loggedInUser.Id;
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isupdateable()){
                pm.Core_IPS_Project__c = ipsProject;
            }
            lProjMembers.add(pm);
        }
        if (lProjMembers != null){
            // Venrublity Fix - Refering query to service class
            // upsert lProjMembers;
            lProjMembers = (List<Core_IPS_Project_Member__c>) Core_IPS_QueryService.upsertRecords((List<SObject>) lProjMembers);
        }
        return lProjMembers;
    }

    public static Map<Id, Asset> mapofIdAsset;
    @AuraEnabled
    public static List<Core_IPS_Product__c> upsertIPSProducts(list<Id> selectedIdsInThirdPage, string ipsProject){
        List<Core_IPS_Product__c> lIPSProducts = new List<Core_IPS_Product__c>();
       if (Asset.SObjectType.getDescribe().isAccessible()){
         /* mapofIdAsset = new Map<Id, Asset>([Select Name, Account.Name, Core_Supported_Product__r.Core_Product_Organization__r.Name, core_Product_Application__c, Core_Supported_Product__r.Core_Flag_Status__c, Core_Code_Name__c, InstallDate, Status, Description, Core_IPS_Asset__c, Core_IPS_Project__c, Core_Supported_Product__c, Core_Product_Organization__c
                                               From Asset
                                               where Id IN:selectedIdsInThirdPage]); */
        //added by sabira 21-07-2026
String assetQuery = 'Select Name, Account.Name, Core_Supported_Product__r.Core_Product_Organization__r.Name, core_Product_Application__c, Core_Supported_Product__r.Core_Flag_Status__c, Core_Code_Name__c, InstallDate, Status, Description, Core_IPS_Asset__c, Core_IPS_Project__c, Core_Supported_Product__c, Core_Product_Organization__c From Asset where Id IN :selectedIdsInThirdPage';
    mapofIdAsset = new Map<Id, Asset>(
        (List<Asset>) Core_IPS_QueryService.queryRecords(assetQuery, new Map<String, Object>{ 'selectedIdsInThirdPage' => selectedIdsInThirdPage })
    ); //sabira
 
        }
        Id IPSProductBasicRecordType = [SELECT Id
                                        FROM RecordType
                                        where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'].Id;
        for (Id Assetid : selectedIdsInThirdPage){
            Core_IPS_Product__c prod = new Core_IPS_Product__c();
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Project__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Project__c.isupdateable()){
                prod.Core_IPS_Project__c = ipsProject;
            }
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_Supported_Product__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_Supported_Product__c.isUpdateable()){
                prod.Core_Supported_Product__c = mapofIdAsset.get(Assetid).Core_Supported_Product__c;
            }
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Product_Status__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Product_Status__c.isupdateable()){
                prod.Core_IPS_Product_Status__c = 'Active';
            }
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Status__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Status__c.isupdateable()){
                prod.Status__c = 'Approved';
            }
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_IsAutoApprove__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_IsAutoApprove__c.isupdateable()){
                prod.Core_IPS_IsAutoApprove__c = true;
            }
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_Intel_Product__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_Intel_Product__c.isupdateable()){
                prod.Core_Intel_Product__c = Assetid;
            }
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IsSubmitted_Header__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_IsSubmitted_Header__c.isupdateable()){
                prod.Core_IsSubmitted_Header__c = true;
            }
            if (Schema.sObjectType.Core_IPS_Product__c.fields.RecordTypeId.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.RecordTypeId.isupdateable()){
                prod.RecordTypeId = IPSProductBasicRecordType;
            }
            lIPSProducts.add(prod);
        }
        if (lIPSProducts != null){
         // Venrublity Fix - Refering query to service class
         // upsert lIPSProducts;
           lIPSProducts = (List<Core_IPS_Product__c>) Core_IPS_QueryService.upsertRecords((List<SObject>) lIPSProducts);//added by sabira 21-07-2026
          
        }
        return lIPSProducts;
    }

    public static list<Core_IPS_Project__c> lstIPSProject;
    @AuraEnabled
    public static List<id> getChildIPSProdctsToProject(string ipsProject){
        List<id> prodIds = new List<id>();
        if (Core_IPS_Project__c.SObjectType.getDescribe().isAccessible()){
            lstIPSProject = (List<Core_IPS_Project__c>)Core_IPS_QueryService.queryRecords(
                'select id, (select id, Core_Intel_Product__c from IPS_Products__r) from Core_IPS_Project__c where id = :ipsProject',
                new Map<String, Object>{ 'ipsProject' => ipsProject }
            );
        }
        for (Core_IPS_Project__c lstproj : lstIPSProject){
            for (Core_IPS_Product__c lst : lstproj.IPS_Products__r){
                prodIds.add(lst.Core_Intel_Product__c);
            }
        }
        if (prodIds != null){
           return prodIds;          
            
        }
        return null;
    }

    @AuraEnabled
    public static List<Case> getcaseRecordsUnderproject(string ipsProject, string fetchType){
        List<Case> caseList = new List<Case>();
        if (Case.SObjectType.getDescribe().isAccessible()){
            if (fetchType == 'Load Data'){

                caseList = [SELECT Id, Core_IPS_Project_Case__c, CaseNumber, Status, Subject, CreatedDate, LastModifiedDate
                            FROM Case
                            where Core_IPS_Project_Case__c = :ipsProject
                            ORDER BY CreatedDate];
            } else if (fetchType == 'All Data'){

                caseList = [SELECT Id, Core_IPS_Project_Case__c, CaseNumber, Status, Subject, CreatedDate, LastModifiedDate
                            FROM Case
                            where Core_IPS_Project_Case__c = :ipsProject];
            }
        }
        return caseList;
    }

    @AuraEnabled(cacheable = true)
    public static Core_IPS_Project__c getCurrentproj(Id pId){
        // Hassan Khan make a "List<Core_IPS_Project__c> projRecord" to fix (List has no rows for assignment to Sobject) Exception Handling issue.
        List<Core_IPS_Project__c> projRecord = [SELECT Id, Name, Core_MPNDA__c, Core_Project_Description__c, Core_Status__c, Core_IPS_EnableMemberasInterestedParties__c, Core_IPS_Enable_ISTasInterested_Parties__c, Core_IPS_Project_ID__c, Core_IPS_Remove_Notification_Details__c
                                          FROM Core_IPS_Project__c
                                          where id = :pId];

        if (!projRecord.isEmpty() && projRecord != null){
            return projRecord[0];
        }
        return null;
    }
}