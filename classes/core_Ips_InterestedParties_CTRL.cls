public with sharing class core_Ips_InterestedParties_CTRL{// Changed by tushar because for vanuability changes
    private static final String DEFAULT_SORT_FIELD = 'FirstName';
    public static string searchText = '*';
    @AuraEnabled
    public static list<IPWrapper> IPRecordSet{ get; set; }

    @AuraEnabled
    public static list<IPWrapper> IPRecordSetSearch{ get; set; }

    public static Map<id, User> myUserMap = new Map<id, User>();
    public static Id CaseId{ get; set; }

    public static list<Contact> ConList{ get; set; }

    public static Case CaseObj{ get; set; }

    public static SET<ID> relatedConatactIDs = new SET<ID>();
    public static Boolean searchMade{ get; set; }

    List<Profile> ProfileLst = new List<Profile>();
    Set<ID> ProfileID = new Set<ID>();
    public static Core_SortedGrid_ColumnHeader sortHeader{
        get{
            if (sortHeader == NULL)
                sortHeader = new Core_SortedGrid_ColumnHeader(DEFAULT_SORT_FIELD);
            return sortHeader;
        }

        set{
            sortHeader = value;
        }
    }

    public static String searchableString;
    static String mode = 'mip';
    @AuraEnabled
    public static List<LinkedExtPartyWrapper> LinkedExternalPartiesList{ get; set; }

    private static Map<Id, LinkedExtPartyWrapper> existingIpByContactId;
    /*kalyani - Commented below set, it is not in use; this is part of code optimization.*/
    // private static Set<Id> toBeDeletedIps;

    public static List<Core_IPS_Project_Member__c> ProjMem{ get; set; }

    public static Set<Id> allActiveContactIds = new Set<Id>();
    @Auraenabled(cacheable = true)
    public static String core_Ips_InterestedParties_CTRL1(Id caseid){
        CaseId = caseid;
        LinkedExternalPartiesList = new List<LinkedExtPartyWrapper>();
        existingIpByContactId = new Map<Id, LinkedExtPartyWrapper>();
        /*kalyani - Commented below set, it is not in use; this is part of code optimization.*/
        // toBeDeletedIps = new Set<Id>();
        ProjMem = new List<Core_IPS_Project_Member__c>();
        searchMade = false;
        IPRecordSet = new list<IPWrapper>();
        if (CaseId != null){
            if (Case.SObjectType.getDescribe().isAccessible()){
                // Venrublity Fix - Refering query to service class
                // CaseObj = [Select id, AccountID, Core_IPS_Project_Case__c, Core_IPS_Project_Case__r.Name
                //            from Case
                //            where ID = :CaseId
                //            LIMIT 1];
                List<Case> caseObjList = (List<Case>) Core_IPS_QueryService.queryRecords(
                    'Select id, AccountID, Core_IPS_Project_Case__c, Core_IPS_Project_Case__r.Name from Case where ID = :CaseId LIMIT 1',
                    new Map<String, Object>{ 'CaseId' => CaseId }
                );
                if (!caseObjList.isEmpty()){
                    CaseObj = caseObjList[0];
                }
            }
        }
        externalPartiesData(CaseObj, mode, CaseId);
        if (LinkedExternalPartiesList.size() > 0){
            for (LinkedExtPartyWrapper ip : LinkedExternalPartiesList){
                if (ip.contactId != null){
                    relatedConatactIDs.add(ip.contactId);
                }
            }
        }

        String sQuery;
        Set<ID> ContactID = new Set<ID>();

        if (CaseObj != null){
            if (CaseObj.Core_IPS_Project_Case__c == null && CaseObj.AccountId != null){
                Id acctId = CaseObj.AccountId;
                allActiveContactIds = getActiveContacts(NULL, acctId);
                // SOQL Injection Fix - Start -  Shipra
                Map<String, Object> bindMap = new Map<String, Object>{ 'accountId' => acctId, 'ActiveConIds' => allActiveContactIds, 'relatedConIds' => relatedConatactIDs };
                sQuery = 'SELECT Id, FirstName, LastName, Name, Email, AccountId, Account.Name ' + 
                     'FROM Contact ' + 
                     'WHERE AccountID = :accountId ' + 
                     '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' + 
                     '  AND (ID IN :ActiveConIds) ' + 
                     '  AND (NOT(ID IN : relatedConIds)) ' + 
                     'ORDER BY ' + String.escapeSingleQuotes(sortHeader.sortExpression) + ' ' + String.escapeSingleQuotes(sortHeader.sortDirection) + ' ' + String.escapeSingleQuotes(sortHeader.sortNullFirstLast);
                // Venrublity Fix - Refering query to service class
                // ConList = Database.queryWithBinds(sQuery, bindMap, AccessLevel.USER_MODE);
                ConList = (List<Contact>) Core_IPS_QueryService.queryRecords(sQuery, bindMap);
                // SOQL Injection Fix - End -  Shipra
            }
            if (CaseObj.Core_IPS_Project_Case__c != null){
                if (Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
                    // Venrublity Fix - Refering query to service class
                    // ProjMem = [SELECT ID, Core_IPS_Contact__c
                    //            FROM Core_IPS_Project_Member__c
                    //            WHERE Core_IPS_Project__c = :CaseObj.Core_IPS_Project_Case__c AND Core_Status__c = 'Active' AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c = false];
                    ProjMem = (List<Core_IPS_Project_Member__c>) Core_IPS_QueryService.queryRecords(
                        'SELECT ID, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__c = :projectCaseId AND Core_Status__c = \'Active\' AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c = false',
                        new Map<String, Object>{ 'projectCaseId' => CaseObj.Core_IPS_Project_Case__c }
                    );
                }
                for (Core_IPS_Project_Member__c CPM : ProjMem){
                    if (CPM.Core_IPS_Contact__c != null){
                        ContactID.add(CPM.Core_IPS_Contact__c);
                    }
                }

                if (ContactID.size() > 0){

                    allActiveContactIds = getActiveContacts(ContactID, NULL);
                    // SOQL Injection Fix - Start -  Shipra
                    Map<String, Object> bindMap = new Map<String, Object>{ 'contactId' => ContactID, 'ActiveConIds' => allActiveContactIds, 'relatedConIds' => relatedConatactIDs };

                    sQuery = 'SELECT Id, FirstName, LastName, Email, Name, AccountId, Account.Name ' + 
                         'FROM Contact ' + 
                         'WHERE Id IN :contactId ' + 
                         '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' + 
                         '  AND (ID IN : ActiveConIds) ' + 
                         '  AND (NOT(ID IN : relatedConIds)) ' + 
                         'ORDER BY ' + String.escapeSingleQuotes(sortHeader.sortExpression) + ' ' + String.escapeSingleQuotes(sortHeader.sortDirection) + ' ' + String.escapeSingleQuotes(sortHeader.sortNullFirstLast);
                    // Venrublity Fix - Refering query to service class
                    // ConList = Database.queryWithBinds(sQuery, bindMap, AccessLevel.USER_MODE);
                    ConList = (List<Contact>) Core_IPS_QueryService.queryRecords(sQuery, bindMap);
                    // SOQL Injection Fix - End -  Shipra

                }
            }

            if (ConList != null){
                List<User> myUserList = new List<User>();
                // Venrublity Fix - Refering query to service class
                 myUserList = [Select id, contactid
                              from User
                              where contactid in:ConList];
                /*myUserList = (List<User>) Core_IPS_QueryService.queryRecords(
                    'Select id, contactid from User where contactid in :ConList',
                    new Map<String, Object>{ 'ConList' => ConList }
                );*/
                for (User uc : myUserList){
                    myUserMap.put(uc.contactid, uc);
                }
                for (Contact ConRec : ConList){
                    IPRecordSet.add(new IPWrapper(ConRec, myUserMap.get(ConRec.id)));
                }
            }

        }

        doSearch(CaseObj);
        List<caseobjvalue> cb = new List<caseobjvalue>();
        cb.add(new caseobjvalue(ConList, LinkedExternalPartiesList));
        return System.JSON.serialize(cb);
    }

    public class caseobjvalue{
        public list<Contact> cs{ get; set; }

        public List<LinkedExtPartyWrapper> linkedextparty{ get; set; }

        public caseobjvalue(list<Contact> cs, List<LinkedExtPartyWrapper> lxtParty){
            this.cs = cs;
            this.linkedextparty = lxtParty;
        }

    }

    @Auraenabled(cacheable = true)
    public static list<Contact> doSearch(Case CaseObj){

        Id acctId;
        String sQuery;
        if (LinkedExternalPartiesList <> null && LinkedExternalPartiesList.size() > 0){
            for (LinkedExtPartyWrapper CIPSCIPEXT : LinkedExternalPartiesList){
                if (CIPSCIPEXT.contactId != null){
                    relatedConatactIDs.add(CIPSCIPEXT.contactId);
                }
            }
        }
        Boolean isEstrik = false;
        if (String.IsBlank(searchText)){
            if (IPRecordSet <> null && IPRecordSet.size() > 0){
                IPRecordSet.clear();
            }

        } else{

            if (searchText.contains('*')){
                searchableString = searchText.replace('*', '%');
                isEstrik = true;
            } else{
                searchableString = searchText;
            }
            // SOQL Injection Fix - Start -  Shipra
            if (CaseObj <> null && CaseObj.Core_IPS_Project_Case__c == null && CaseObj.AccountId != null){
                acctId = CaseObj.AccountId;
                Map<String, Object> bindMap = new Map<String, Object>{ 'accountId' => acctId, 'searchableString' => '%' + searchableString + '%', 'ActiveConIds' => allActiveContactIds, 'relatedConIds' => relatedConatactIDs };

                allActiveContactIds = getActiveContacts(NULL, acctId);
                sQuery = 'SELECT Id, firstName, LastName, Email, Name, AccountId, Account.Name ' + 
                     'FROM Contact ' + 
                     'WHERE AccountId = :accountId ' + 
                     '  AND (Name like :searchableString OR ' + 
                     '  FirstName like :searchableString OR ' + 
                     '  LastName like :searchableString OR ' + 
                     '  Email like :searchableString) ' + 
                     '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' + 
                     '  AND (ID IN : ActiveConIds) ' + 
                     '  AND (NOT(ID IN :relatedConIds)) ' + 
                     'ORDER BY ' + String.escapeSingleQuotes(sortHeader.sortExpression) + ' ' + String.escapeSingleQuotes(sortHeader.sortDirection) + ' ' + String.escapeSingleQuotes(sortHeader.sortNullFirstLast);

                // Venrublity Fix - Refering query to service class
                // ConList = Database.queryWithBinds(sQuery, bindMap, AccessLevel.USER_MODE);
                ConList = (List<Contact>) Core_IPS_QueryService.queryRecords(sQuery, bindMap);
                // SOQL Injection Fix - End -  Shipra

            }

            if (CaseObj <> null && CaseObj.Core_IPS_Project_Case__c != null){
                ContactDataRetrieve conData = new ContactDataRetrieve();
                ProjMem = conData.fetchProjectMembers(CaseObj);
                Set<ID> ContactID = new Set<ID>();
                    
                for (Core_IPS_Project_Member__c CPM : ProjMem){
                    if (CPM.Core_IPS_Contact__c != null){
                        ContactID.add(CPM.Core_IPS_Contact__c);
                    }
                }

                if (ContactID.size() > 0){

                    allActiveContactIds = conData.getActiveContactsNoSharing(ContactID, NULL);
                    sQuery = 'SELECT Id, FirstName, LastName, Email, Name, AccountId, Account.Name ' + 
                         'FROM Contact ' + 
                         'WHERE Id IN :ContactID ' + 
                         '  AND (Name like :searchableString OR ' + 
                         '       FirstName like :searchableString OR ' + 
                         '       LastName like :searchableString OR ' + 
                         '       Email like :searchableString) ' + 
                         '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' + 
                         '  AND (ID IN: allActiveContactIds) ' + 
                         '  AND (NOT(ID IN : relatedConatactIDs)) ' + 
                         'ORDER BY ' + String.escapeSingleQuotes(sortHeader.sortExpression) + ' ' + String.escapeSingleQuotes(sortHeader.sortDirection) + ' ' + String.escapeSingleQuotes(sortHeader.sortNullFirstLast);


                    ConList = conData.getRecords(sQuery, ContactID, searchableString, relatedConatactIDs, allActiveContactIds);

                } else{
                    if (IPRecordSet.size() > 0){
                        IPRecordSet.clear();
                    }

                    return null;
                }

            }

            if (ConList <> null && ConList.size() > 0){
                if (IPRecordSet.size() > 0){
                    IPRecordSet.clear();
                }
                List<User> myUserList = new List<User>();
                // if(User.SObjectType.getDescribe().isAccessible()){
                // Venrublity Fix - Refering query to service class
                 myUserList = [Select id, contactid
                               from User
                               where contactid in:ConList];
                /*myUserList = (List<User>) Core_IPS_QueryService.queryRecords(
                    'Select id, contactid from User where contactid in :ConList',
                    new Map<String, Object>{ 'ConList' => ConList }
                );*/
                //}
                for (User uc : myUserList){
                    myUserMap.put(uc.contactid, uc);
                }
                for (Contact ConRec : ConList){
                    IPRecordSet.add(new IPWrapper(ConRec, myUserMap.get(ConRec.id)));
                    searchMade = true;
                }
            } else{
                if (IPRecordSet <> null && IPRecordSet.size() > 0){
                    IPRecordSet.clear();
                }
            }
        }
        return ConList;
    }

    public static Set<Id> getActiveContacts(Set<Id> projContactIds, Id accountId){
        Set<Id> activeContactIds = new Set<Id>();
        List<User> allActiveUsers = new List<User>();
        if (accountId != NULL && projContactIds == NULL){
            // Venrublity Fix - Refering query to service class
             allActiveUsers = [SELECT Id, Accountid, contactid
                               FROM User
                               WHERE isActive = TRUE and contactid != null AND Accountid = :accountId];
            /*allActiveUsers = (List<User>) Core_IPS_QueryService.queryRecords(
                'SELECT Id, Accountid, contactid FROM User WHERE isActive = TRUE and contactid != null AND Accountid = :accountId',
                new Map<String, Object>{ 'accountId' => accountId }
            );*/
        } else if (projContactIds != Null && accountId == Null){
            // Venrublity Fix - Refering query to service class
             allActiveUsers = [SELECT Id, contactid
                              FROM User
                              WHERE isActive = TRUE and contactid IN:projContactIds];
           /* allActiveUsers = (List<User>) Core_IPS_QueryService.queryRecords(
                'SELECT Id, contactid FROM User WHERE isActive = TRUE and contactid IN :projContactIds',
                new Map<String, Object>{ 'projContactIds' => projContactIds }
            );*/
        }
        for (User active : allActiveUsers){
            activeContactIds.add(active.contactid);
        }

        return activeContactIds;
    }

    public class IPWrapper{
        @AuraEnabled
        public boolean isSelected{ get; set; }

        @AuraEnabled
        public Contact Con{ get; set; }

        @AuraEnabled
        public User conUser{ get; set; }

        public IPWrapper(Contact C, User U){
            Con = C;
            conUser = U;
            isSelected = false;
        }

    }

    public static void externalPartiesData(Case CaseObj, String mode, Id CaseId){

        List<Core_IPS_Case_Interested_Party__c> LinkedExternalParties;
        if (CaseObj <> null && ((CaseObj.AccountId <> null && CaseObj.Core_IPS_Project_Case__c == null) || (CaseObj.Core_IPS_Project_Case__r <> null /*&& CaseObj.Core_IPS_Project_Case__r.Name <> null*/))){

            if (Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isAccessible()){
                // Venrublity Fix - Refering query to service class
                // LinkedExternalParties = [Select ID, Contact__c, Core_IPS_Account_Name__c, First_Name__c, Email__c, Agent_Name__c, Last_Name__c, User__c, Active__c, Contact__r.Name
                //                          from Core_IPS_Case_Interested_Party__c
                //                          WHERE Case__c = :CaseId AND Contact__c != null AND Type__c = 'External' AND Active__c = true];//US113986
                LinkedExternalParties = (List<Core_IPS_Case_Interested_Party__c>) Core_IPS_QueryService.queryRecords(
                    'Select ID, Contact__c, Core_IPS_Account_Name__c, First_Name__c, Email__c, Agent_Name__c, Last_Name__c, User__c, Active__c, Contact__r.Name from Core_IPS_Case_Interested_Party__c WHERE Case__c = :CaseId AND Contact__c != null AND Type__c = \'External\' AND Active__c = true',
                    new Map<String, Object>{ 'CaseId' => CaseId }
                );
            }
        }

        if (LinkedExternalParties != null && !LinkedExternalParties.isEmpty()){
            for (Core_IPS_Case_Interested_Party__c exIps : LinkedExternalParties){
                LinkedExtPartyWrapper partyRecord = new LinkedExtPartyWrapper(exIps.Contact__c, exIps.User__c, exIps.First_Name__c, exIps.Last_Name__c, exIps.Email__c, exIps.Id, true, null, exIps);
                LinkedExternalPartiesList.add(partyRecord);
                if (existingIpByContactId.get(exIps.Contact__c) == null){
                    existingIpByContactId.put(exIps.Contact__c, partyRecord);
                }
            }

        }
    }

    public List<Contact> simpleSort(){
        IPRecordSet.clear();

        String sQuery;
        if (CaseId != null){
            if (Case.SObjectType.getDescribe().isAccessible()){
                // Venrublity Fix - Refering query to service class
                // CaseObj = [SELECT id, AccountID, Core_IPS_Project_Case__c, Core_IPS_Project_Case__r.Name
                //            FROM Case
                //            WHERE id = :CaseId];
                List<Case> caseObjList = (List<Case>) Core_IPS_QueryService.queryRecords(
                    'SELECT id, AccountID, Core_IPS_Project_Case__c, Core_IPS_Project_Case__r.Name FROM Case WHERE id = :CaseId',
                    new Map<String, Object>{ 'CaseId' => CaseId }
                );
                if (!caseObjList.isEmpty()){
                    CaseObj = caseObjList[0];
                }
            }
        }

        allActiveContactIds = getActiveContacts(NULL, CaseObj.AccountId);
         // SOQL Injection Fix - Start -  Shipra
         Map<String, Object> bindMap = new Map<String, Object>{ 'accountId' => CaseObj.AccountId, 'searchableString' =>  String.escapeSingleQuotes(searchableString) , 'ActiveConIds' => allActiveContactIds, 'relatedConIds' => relatedConatactIDs };
           
        sQuery = 'SELECT Id, firstName, LastName, Email, Name, AccountId, Account.Name ' + 
             'FROM Contact ' + 
             'WHERE AccountId = :accountId ' + 
             '  AND (Name like : searchableString OR ' + 
             'FirstName like :searchableString  OR ' + 
             'LastName like :searchableString OR ' + 
             'Email like :searchableString )  ' + 
             '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' + 
             '  AND (ID IN : ActiveConIds) ' + 
             '  AND (NOT(ID IN : relatedConIds)) ' + 
             'ORDER BY ' + String.escapeSingleQuotes(sortHeader.sortExpression) + ' ' + String.escapeSingleQuotes(sortHeader.sortDirection) + ' ' + String.escapeSingleQuotes(sortHeader.sortNullFirstLast);
        // Venrublity Fix - Refering query to service class
        // ConList = Database.queryWithBinds(sQuery, bindMap, AccessLevel.USER_MODE);
        ConList = (List<Contact>) Core_IPS_QueryService.queryRecords(sQuery, bindMap);
        // SOQL Injection Fix - End -  Shipra
        for (Contact ConRec : ConList){
            IPRecordSet.add(new IPWrapper(ConRec, myUserMap.get(ConRec.id)));
            searchMade = true;
        }
        return null;
    }

    public class LinkedExtPartyWrapper{
        @AuraEnabled
        public Id contactId;
        @AuraEnabled
        public Id userId;

        @AuraEnabled
        public String firstName{ get; set; }

        @AuraEnabled
        public String lastName{ get; set; }

        @AuraEnabled
        public String email{ get; set; }

        @AuraEnabled
        public Id recordId;

        @AuraEnabled
        public Boolean isSelected{ get; set; }

        @AuraEnabled
        public Contact con{ get; set; }

        @AuraEnabled
        public Core_IPS_Case_Interested_Party__c ipRecord{ get; set; }

        public LinkedExtPartyWrapper(Id conId, Id usrId, String fname, String lname, String emailId, Id recId, Boolean isChecked, Contact conRec, Core_IPS_Case_Interested_Party__c ipRec){
            contactId = conId;
            userId = usrId;
            firstName = fname;
            lastName = lname;
            email = emailId;
            recordId = recId;
            isSelected = isChecked;
            con = conRec;
            ipRecord = ipRec;
        }

    }

    public without sharing class ContactDataRetrieve{
        public List<Contact> getRecords(String sQuery, Set<ID> ContactID, String searchableString, Set<ID> relatedConatactIDs, Set<ID> allActiveContactIds){
            // Venrublity Fix - Refering query to service class
            // return Database.query(sQuery);
            return (List<Contact>) Core_IPS_QueryService.queryRecords(
                sQuery,
                new Map<String, Object>{
                    'ContactID' => ContactID,
                    'searchableString' => searchableString,
                    'relatedConatactIDs' => relatedConatactIDs,
                    'allActiveContactIds' => allActiveContactIds
                }
            );
        }

        public void saveRecords(list<Core_IPS_Case_Interested_Party__c> IPSObjList){
            // Venrublity Fix - Refering query to service class
            // insert IPSObjList;
            IPSObjList = (List<Core_IPS_Case_Interested_Party__c>) Core_IPS_QueryService.insertRecords((List<SObject>) IPSObjList);
        }

        public void deleteRecords(list<Core_IPS_Case_Interested_Party__c> IPSObjList){
            if (Core_IPS_Case_Interested_Party__c.sObjectType.getDescribe().isDeletable()){
                // Venrublity Fix - Refering query to service class
                // delete IPSObjList;
                IPSObjList = (List<Core_IPS_Case_Interested_Party__c>) Core_IPS_QueryService.deleteRecords((List<SObject>) IPSObjList);
            }
        }

        public List<Core_IPS_Project_Member__c> fetchProjectMembers(Case CaseObj){
            List<Core_IPS_Project_Member__c> listOfProjectMembers = new List<Core_IPS_Project_Member__c>();
            if (Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
                // Venrublity Fix - Refering query to service class
                // listOfProjectMembers = [Select ID, Core_IPS_Contact__c
                //                         FROM Core_IPS_Project_Member__c
                //                         where Core_IPS_Project__c = :CaseObj.Core_IPS_Project_Case__c AND Core_Status__c = 'Active' AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c = false];
                listOfProjectMembers = (List<Core_IPS_Project_Member__c>) Core_IPS_QueryService.queryRecords(
                    'Select ID, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where Core_IPS_Project__c = :projectCaseId AND Core_Status__c = \'Active\' AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c = false',
                    new Map<String, Object>{ 'projectCaseId' => CaseObj.Core_IPS_Project_Case__c }
                );
            }
            return listOfProjectMembers;
        }

        public Set<Id> getActiveContactsNoSharing(Set<Id> projContactIds, Id accountId){
            Set<Id> activeContactIds = new Set<Id>();
            List<User> allActiveUsers = new List<User>();

            if (accountId != NULL && projContactIds == NULL){
                // Venrublity Fix - Refering query to service class
                 allActiveUsers = [SELECT Id, Accountid, contactid
                                   FROM User
                                   WHERE isActive = TRUE and contactid != null AND Accountid = :accountId];
               /* allActiveUsers = (List<User>) Core_IPS_QueryService.queryRecords(
                    'SELECT Id, Accountid, contactid FROM User WHERE isActive = TRUE and contactid != null AND Accountid = :accountId',
                    new Map<String, Object>{ 'accountId' => accountId }
                );*/
            } else if (projContactIds != Null && accountId == Null){
                // Venrublity Fix - Refering query to service class
                 allActiveUsers = [SELECT Id, contactid
                                  FROM User
                                  WHERE isActive = TRUE and contactid IN:projContactIds];
                /*allActiveUsers = (List<User>) Core_IPS_QueryService.queryRecords(
                    'SELECT Id, contactid FROM User WHERE isActive = TRUE and contactid IN :projContactIds',
                    new Map<String, Object>{ 'projContactIds' => projContactIds }
                );*/
            }
            for (User active : allActiveUsers){
                activeContactIds.add(active.contactid);
            }
            return activeContactIds;
        }

    }

    @AuraEnabled
    public static string addOrRemovePartyMembers(List<ID> initialIds, List<ID> selectedIds, String caseID){
        String message;
        try{

            List<Id> addIdList = new List<Id>();
            List<Id> removeIdList = new List<Id>();
            if (selectedIds.size() > initialIds.size()){
                for (ID ids : selectedIds){
                    if (!initialIds.contains(ids)){
                        addIdList.add(ids);
                    }
                }

            }
            if (addIdList.size() > 0){


                List<Core_IPS_Case_Interested_Party__c> addIPSPartyMemList = addPartyMem(addIdList, caseID);
                if (addIPSPartyMemList.size() > 0){
                    message = 'Success';
                }
            }
            if (selectedIds.size() < initialIds.size()){
                for (ID ids2 : initialIds){
                    if (!selectedIds.contains(ids2)){
                        removeIdList.add(ids2);
                    }
                }
            }
            if (removeIdList.size() > 0){
                List<Core_IPS_Case_Interested_Party__c> removedIPSPartyMemList = removePartyMem(removeIdList, caseID);
                if (removedIPSPartyMemList.size() > 0){
                    message = 'Success';
                }
            }
        } catch (Exception e){
            message = e.getStackTraceString();
        }

        return message;
    }

    public static List<Core_IPS_Case_Interested_Party__c> PartyMembers;
    public static List<Core_IPS_Case_Interested_Party__c> addPartyMem(List<Id> addList, String caseID){
        List<Core_IPS_Case_Interested_Party__c> lPartyMembers = new List<Core_IPS_Case_Interested_Party__c>();
        if (Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isAccessible()){
            // Venrublity Fix - Refering query to service class
            // PartyMembers = [select Id, IsDeleted, Name, RecordTypeId, Case__c, Active__c, Contact__c, Core_IPS_Account_Name__c, First_Name__c, Last_Name__c, Type__c, User__c, Core_IPS_Project_Interested_Party__c
            //                 from Core_IPS_Case_Interested_Party__c
            //                 WHERE Contact__c IN:addList AND Case__c = :caseID];
            PartyMembers = (List<Core_IPS_Case_Interested_Party__c>) Core_IPS_QueryService.queryRecords(
                'select Id, IsDeleted, Name, RecordTypeId, Case__c, Active__c, Contact__c, Core_IPS_Account_Name__c, First_Name__c, Last_Name__c, Type__c, User__c, Core_IPS_Project_Interested_Party__c from Core_IPS_Case_Interested_Party__c WHERE Contact__c IN :addList AND Case__c = :caseID',
                new Map<String, Object>{ 'addList' => addList, 'caseID' => caseID }
            );
        }
        List<Id> contactIdList = new List<Id>();
        if (PartyMembers.size() > 0){
            for (Core_IPS_Case_Interested_Party__c PartyMem : PartyMembers){
                contactIdList.add(PartyMem.Contact__c);
            }
        }
        List<Id> partyMemNeedToCreateList = new List<Id>();
        if (contactIdList != null){
            for (ID ids2 : addList){
                if (!contactIdList.contains(ids2)){
                    partyMemNeedToCreateList.add(ids2);
                }
            }
        }

        List<Id> memberId = new List<Id>();
        for (Id memId : partyMemNeedToCreateList){
            memberId.add(memId);
        }
        // Venrublity Fix - Refering query to service class
         List<User> loggedInUser = [SELECT Id, Name, Email, ContactId
                                    FROM User
                                    WHERE ContactId IN:memberId];
        /*List<User> loggedInUser = (List<User>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, Name, Email, ContactId FROM User WHERE ContactId IN :memberId',
            new Map<String, Object>{ 'memberId' => memberId }
        );*/

        for (User usm : loggedInUser){
            Core_IPS_Case_Interested_Party__c pm = new Core_IPS_Case_Interested_Party__c();
            pm.Contact__c = usm.ContactId;
            if (Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Active__c.isCreateable()){
                pm.Active__c = true;
            }
            pm.User__c = usm.Id;
            if (Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Type__c.isCreateable() || Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Type__c.isupdateable()){
                pm.Type__c = 'External';
            }
            pm.Case__c = caseID;
            lPartyMembers.add(pm);
        }


        if (PartyMembers.size() > 0){
            List<Id> partyId = new List<Id>();
            for (Core_IPS_Case_Interested_Party__c parId : PartyMembers){
                partyId.add(parId.Contact__c);
            }

            // Venrublity Fix - Refering query to service class
             List<User> loggedInUser1 = [SELECT Id, Name, Email
                                         FROM User
                                         WHERE ContactId IN:partyId];
            /*List<User> loggedInUser1 = (List<User>) Core_IPS_QueryService.queryRecords(
                'SELECT Id, Name, Email FROM User WHERE ContactId IN :partyId',
                new Map<String, Object>{ 'partyId' => partyId }
            );*/
            integer i = 0;
            for (Core_IPS_Case_Interested_Party__c PartyMem : PartyMembers){

                Core_IPS_Case_Interested_Party__c pm = new Core_IPS_Case_Interested_Party__c();
                pm.ID = PartyMem.ID;
                if (Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Active__c.isCreateable() || Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Active__c.isupdateable()){
                    pm.Active__c = true;
                }

                pm.User__c = loggedInUser1[i].id;
                i++;
                pm.Type__c = 'External';
                lPartyMembers.add(pm);
            }
        }
        if (lPartyMembers != null){
            // Venrublity Fix - Refering query to service class
            // upsert lPartyMembers;
            lPartyMembers = (List<Core_IPS_Case_Interested_Party__c>) Core_IPS_QueryService.upsertRecords((List<SObject>) lPartyMembers);
        }
        return lPartyMembers;
    }

    public static List<Core_IPS_Case_Interested_Party__c> removePartyMem(List<Id> removeList, String caseID){

        List<Core_IPS_Case_Interested_Party__c> PartyMembers = new List<Core_IPS_Case_Interested_Party__c>();
        // Venrublity Fix - Refering query to service class
         PartyMembers = [select Id, IsDeleted, Name, RecordTypeId, Case__c, Active__c, Contact__c, First_Name__c, Last_Name__c, Type__c, User__c
                         FROM Core_IPS_Case_Interested_Party__c
                         WHERE Contact__c IN:removeList AND Case__c = :caseID];
        /*PartyMembers = (List<Core_IPS_Case_Interested_Party__c>) Core_IPS_QueryService.queryRecords(
            'select Id, IsDeleted, Name, RecordTypeId, Case__c, Active__c, Contact__c, First_Name__c, Last_Name__c, Type__c, User__c FROM Core_IPS_Case_Interested_Party__c WHERE Contact__c IN :removeList AND Case__c = :caseID',
            new Map<String, Object>{ 'removeList' => removeList, 'caseID' => caseID }
        );*/

        if (PartyMembers.size() > 0){
            for (Core_IPS_Case_Interested_Party__c PartyMem : PartyMembers){
                if (Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Active__c.isCreateable() || Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Active__c.isupdateable()){
                    PartyMem.Active__c = false;
                }

            }
            // Venrublity Fix - Refering query to service class
            // upsert PartyMembers;
            PartyMembers = (List<Core_IPS_Case_Interested_Party__c>) Core_IPS_QueryService.upsertRecords((List<SObject>) PartyMembers);
        }
        return PartyMembers;
    }

}