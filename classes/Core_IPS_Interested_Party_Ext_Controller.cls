/***************************************************************************************************
 Class Name          : Core_IPS_Interested_Party_Ext_Controller
 Version             : 2.0
 Description         : This Class is a Controller class for Core_IPS_Interested_Party_External Visualforce page
 Used in             : Core_IPS_Interested_Party_External Visualforce page
 Modification Log :
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Amritesh                    5/11/2018              DE39208 - Added Core_IPS_Email_Opt_Out__c check in queries
 * Gourav                      09/17/2018             DE20059 - Added Inactive_ContactIDs_Query string to avoid List use and reduce view state size
 * Tanvi                       02/21/2019             PRB000082369 - Fixed SOQLs & logic to retrieve Active user contacts to avoid Case comments issue
 * Tanvi                       03/04/2019             DE35668 - External Customers not able to view all Project members related to other accounts
 ****************************************************************************************************/
public with sharing class Core_IPS_Interested_Party_Ext_Controller{
    private static final String DEFAULT_SORT_FIELD = 'FirstName';
    //fix PRB000082369---TChauhan
    //private static final String Inactive_ContactIDs_Query =' (Select contactid from User where isActive = false and contactid != null) ';
    public string searchText{ get; set; }

    public list<IPWrapper> IPRecordSet{ get; set; }

    public list<IPWrapper> IPRecordSetSearch{ get; set; }

    public Map<id, User> myUserMap = new Map<id, User>();
        // Unencoded Formulas in Script Tags XSS Fix - TWC745-7251
    public Id CaseId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
    
    public list<Contact> ConList{ get; set; }

    public Case CaseObj;
    public SET<ID> relatedConatactIDs = new SET<ID>();
    public Boolean searchMade{ get; set; }

    List<Profile> ProfileLst = new List<Profile>();
    Set<ID> ProfileID = new Set<ID>();
    public Core_SortedGrid_ColumnHeader sortHeader{
        get{
            if (sortHeader == NULL)
                sortHeader = new Core_SortedGrid_ColumnHeader(DEFAULT_SORT_FIELD);
            return sortHeader;
        }

        set{
            sortHeader = value;
        }
    }

    public String searchableString;
        // Unencoded Formulas in Script Tags XSS Fix - TWC745-7251
    String mode = ApexPages.currentPage().getParameters().get('mode');
    //public List<Core_IPS_Case_Interested_Party__c> LinkedExternalParties{get;set;}//Ashutosh - DE34860 - Making it a local variable as we are using wrapper info on UI
    public List<LinkedExtPartyWrapper> LinkedExternalPartiesList{ get; set; }

    //Ashutosh - DE34860 - wrapper to store new or old Ext Ips to handle insertion and UI manipulations
    private Map<Id, LinkedExtPartyWrapper> existingIpByContactId;//Ashutosh - US103988 - To handle selection/deselection of same record
    private Set<Id> toBeDeletedIps;

    //Ashutosh - US103988 - to maintain the IPs which were deselected from already selected list
    public List<Core_IPS_Project_Member__c> ProjMem{ get; set; }

    //STARTS-- PRB000082369---TCHAUHAN----02192019
    public Set<Id> allActiveContactIds = new Set<Id>();
    //constructor
    public Core_IPS_Interested_Party_Ext_Controller(ApexPages.StandardController controller){
    
        LinkedExternalPartiesList = new List<LinkedExtPartyWrapper>(); //Ashutosh - DE34860 -  US103988
        existingIpByContactId = new Map<Id, LinkedExtPartyWrapper>();//Ashutosh - US103988
        toBeDeletedIps = new Set<Id>();//Ashutosh - US103988
        ProjMem = new List<Core_IPS_Project_Member__c>();
        searchMade = false;
        IPRecordSet = new list<IPWrapper>();

        if (CaseId != null){
            //FLS Check Added - Madhuri
            if (Case.SObjectType.getDescribe().isAccessible()){
                CaseObj = [Select id, AccountID, Core_IPS_Project_Case__c, Core_IPS_Project_Case__r.Name
                           from Case
                           where ID = :CaseId
                           LIMIT 1];
            }
        }

        externalPartiesData(CaseObj, mode);

        //Commenting below snippet as it is not used anywhere--TChauhan---02212019
        /**User currentuser=[Select Id, ContactId, AccountId, isActive from User where Id=:userinfo.getuserId()];
         if(currentuser.ContactId <> null){
         //currentContactId = currentuser.ContactId;
         currentAccountId = currentuser.AccountId;
         }**/

        if (LinkedExternalPartiesList.size() > 0){
            for (LinkedExtPartyWrapper ip : LinkedExternalPartiesList){
                if (ip.contactId != null){
                    relatedConatactIDs.add(ip.contactId);
                }
            }
        }

        String sQuery;
        Set<ID> ContactID = new Set<ID>();

        /**STARTS---Fixed PRB000082369----TChauhan----02192019**/
        if (CaseObj != null){
            //Case1: If Case rec is created without Project
            if (CaseObj.Core_IPS_Project_Case__c == null && CaseObj.AccountId != null){
                Id acctId = CaseObj.AccountId;
                //Query all active user contacts related to this account
                allActiveContactIds = getActiveContacts(NULL, acctId);
                // SOQL Injection Start - End -  Shipra
                Map<String, Object> bindMap = new Map<String, Object>{ 'accountId' => acctId, 'activeIds' => allActiveContactIds, 'relatedConIds' => relatedConatactIDs };
                sQuery = 'SELECT Id, FirstName, LastName, Name, Email, AccountId, Account.Name ' + 
                     'FROM Contact ' + 
                     'WHERE AccountID = :accountId ' + 
                     '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' +   //modified by amritesh - DE39208 - 5/11/2018
                '  AND (ID IN : activeIds) ' +    //fix PRB000082369
                '  AND (NOT(ID IN : relatedConIds)) ' + 
                     'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;
                ConList = Database.queryWithBinds(sQuery, bindMap, AccessLevel.USER_MODE);
                // SOQL Injection Fix - End -  Shipra
            }

            //Case2: If Case rec is created with Project details
            if (CaseObj.Core_IPS_Project_Case__c != null){
                //Fetch project members
                //FLS Check Added - Madhuri
                if (Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
                    ProjMem = [SELECT ID, Core_IPS_Contact__c
                               FROM Core_IPS_Project_Member__c
                               WHERE Core_IPS_Project__c = :CaseObj.Core_IPS_Project_Case__c AND Core_Status__c = 'Active' AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c = false];
                }
                for (Core_IPS_Project_Member__c CPM : ProjMem){
                    if (CPM.Core_IPS_Contact__c != null){
                        ContactID.add(CPM.Core_IPS_Contact__c);
                    }
                }
                if (ContactID.size() > 0){
                    //Query all active user contacts related to this PROJECT
                    allActiveContactIds = getActiveContacts(ContactID, NULL);
                    // SOQL Injection Fix - Start -  Shipra
                    Map<String, Object> bindMap = new Map<String, Object>{ 'contactID' => ContactID, 'ActiveConIds' => allActiveContactIds, 'relatedConIds' => relatedConatactIDs };

                    sQuery = 'SELECT Id, FirstName, LastName, Email, Name, AccountId, Account.Name ' + 
                         'FROM Contact ' + 
                         'WHERE Id IN :contactID ' + 
                         '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' +    //modified by amritesh - DE39208 - 5/11/2018
                    '  AND (ID IN :ActiveConIds) ' +    //fix PRB000082369
                    '  AND (NOT(ID IN :relatedConIds)) ' + 
                         'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;
                    ConList = Database.queryWithBinds(sQuery, bindMap, AccessLevel.USER_MODE);
                    // SOQL Injection Fix - End -  Shipra
                }
            }

            if (ConList != null){
                List<User> myUserList = [Select id, contactid
                                         from User
                                         where contactid in:ConList];
                for (User uc : myUserList){
                    myUserMap.put(uc.contactid, uc);
                }
                for (Contact ConRec : ConList){
                    IPRecordSet.add(new IPWrapper(ConRec, myUserMap.get(ConRec.id)));
                }
            }

        }
    }

    /* public Core_IPS_Interested_Party_Ext_Controller() {


     }*/
    public PageReference doSearch(){
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
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '' + 'Please enter text to be searched.'));
            if (IPRecordSet <> null && IPRecordSet.size() > 0){
                IPRecordSet.clear();
                //searchMade = true;
            }
        } else{
            if (searchText.contains('*')){
                searchableString = searchText.replace('*', '%');
                isEstrik = true;
            } else{
                searchableString = searchText;
            }
            //searchableString = '%' + searchableString + '%';
            // SOQL Injection Fix - Start -  Shipra
            Map<String, Object> bindMap = new Map<String, Object>{ 'accountId' => acctId, 'searchableString' => '%' + searchableString + '%', 'ActiveConIds' => allActiveContactIds, 'relatedConIds' => relatedConatactIDs };

            //Case1: Inside 'doSearch' if No project selected  /blank
            if (CaseObj <> null && CaseObj.Core_IPS_Project_Case__c == null && CaseObj.AccountId != null){
                acctId = CaseObj.AccountId;
                //Query all active user contacts related to this account
                allActiveContactIds = getActiveContacts(NULL, acctId);
                sQuery = 'SELECT Id, firstName, LastName, Email, Name, AccountId, Account.Name ' + 
                     'FROM Contact ' + 
                     'WHERE AccountId = :accountId ' + 
                     '  AND (Name like :searchableString OR ' + 
                     '       FirstName like :searchableString OR ' + 
                     '       LastName like :searchableString OR ' + 
                     '       Email like :searchableString) ' + 
                     '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' +   //modified by amritesh - DE39208 - 5/11/2018
                '  AND (ID IN : ActiveConIds) ' +      //fix PRB000082369
                '  AND (NOT(ID IN :relatedConIds)) ' + 
                     'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;

                ConList = Database.queryWithBinds(sQuery, bindMap, AccessLevel.USER_MODE);
                // SOQL Injection Fix - End -  Shipra
            }

            //Case2: Inside 'doSearch' if Project is selected
            if (CaseObj <> null && CaseObj.Core_IPS_Project_Case__c != null){

                //Innerclass without sharing
                //DE35668 ----TChauhan---Fixed visibility of Project members for External portal users
                ContactDataRetrieve conData = new ContactDataRetrieve();
                ProjMem = conData.fetchProjectMembers(CaseObj); //End--DE35668
                Set<ID> ContactID = new Set<ID>();
                for (Core_IPS_Project_Member__c CPM : ProjMem){
                    if (CPM.Core_IPS_Contact__c != null){
                        ContactID.add(CPM.Core_IPS_Contact__c);
                    }
                }

                if (ContactID.size() > 0){
                    //Query all active user contacts related to this project
                    allActiveContactIds = conData.getActiveContactsNoSharing(ContactID, NULL);
                    sQuery = 'SELECT Id, FirstName, LastName, Email, Name, AccountId, Account.Name ' + 
                         'FROM Contact ' + 
                         'WHERE Id IN :ContactID ' + 
                         '  AND (Name like :searchableString OR ' + 
                         '       FirstName like :searchableString OR ' + 
                         '       LastName like :searchableString OR ' + 
                         '       Email like :searchableString) ' + 
                         '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' +   //modified by amritesh - DE39208 - 5/11/2018
                    '  AND (ID IN: allActiveContactIds) ' +    //fix PRB000082369
                    '  AND (NOT(ID IN : relatedConatactIDs)) ' + 
                         'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;

                    //Modified by Geetha as per US103991
                    ConList = conData.getRecords(sQuery, ContactID, searchableString, relatedConatactIDs, allActiveContactIds);
                    //ConList = Database.query(sQuery);
                } else{
                    if (IPRecordSet.size() > 0){
                        IPRecordSet.clear();
                    }
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '' + 'No Results Found.'));
                    return null;
                }
            }

            if (ConList <> null && ConList.size() > 0){
                if (IPRecordSet.size() > 0){
                    IPRecordSet.clear();
                }
                //  Added by Chiru - 20-08-24 - APEX GURU - SOQL FIX
                Map<Id, Contact> ConListMap = new Map<Id, Contact>();
                if (ConList != null && ConList.size() > 0){
                    ConListMap = new Map<Id, Contact>(ConList);
                }
                List<User> myUserList = [Select id, contactid
                                         from User
                                         where contactid in:ConListMap.keySet()];
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
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '' + 'No Results Found.'));
                //return null;
            }

        }
        return null;
    }

    /**Start---PRB000082369---TChauhan---Below is the reusable method to query User and filter out set of Active user contact ids**/
    public Set<Id> getActiveContacts(Set<Id> projContactIds, Id accountId){
        Set<Id> activeContactIds = new Set<Id>();
        List<User> allActiveUsers = new List<User>();

        if (accountId != NULL && projContactIds == NULL){
            allActiveUsers = [SELECT Id, Accountid, contactid
                              FROM User
                              WHERE isActive = TRUE and contactid != null AND Accountid = :accountId];
        } else if (projContactIds != Null && accountId == Null){
            allActiveUsers = [SELECT Id, contactid
                              FROM User
                              WHERE isActive = TRUE and contactid IN:projContactIds];
        }
        for (User active : allActiveUsers){
            activeContactIds.add(active.contactid);
        }

        return activeContactIds;
    }

    /**End ---PRB000082369**/
    public PageReference AddSelectedContacts(){
        list<Core_IPS_Case_Interested_Party__c> IPSObjList = new list<Core_IPS_Case_Interested_Party__c>();
        if (IPRecordSet.size() > 0){
            for (IPWrapper IPW1 : IPRecordSet){
                if (IPW1.isSelected){
                    Id userId = (IPW1 <> null && IPW1.conUser <> null && IPW1.conUser.Id <> null) ? IPW1.conUser.Id : null;
                    /*Ashutosh - US103988- If we found that interested party record don't exist for this contact we will create new record with recordId attribute set to null
                     else we will get the record from the map where we mapped wrapper element by contact id and will add it to the current list to show and also remove the
                     interested party id from the set "toBedeletedIps" to avoid deletion of ip record of this entry*/
                    if (existingIpByContactId.get(IPW1.Con.Id) == null){
                        LinkedExternalPartiesList.add(new LinkedExtPartyWrapper(IPW1.Con.Id, userId, IPW1.con.firstName, IPW1.con.lastName, IPW1.con.email, null, true, IPW1.Con, null));
                    } else{
                        existingIpByContactId.get(IPW1.Con.Id).isSelected = true;//Ashutosh-Us103988
                        LinkedExternalPartiesList.add(existingIpByContactId.get(IPW1.Con.Id));
                        toBeDeletedIps.remove(existingIpByContactId.get(IPW1.Con.Id).recordId);//Ashutosh-US103988 - Removing the Id from Ips to be deleted
                    }
                }
            }
        }

        if (LinkedExternalPartiesList.size() > 0){
            doSearch();
            return null;
        }

        return null;
    }

    public PageReference removeSelectedContacts(){
        /*Ashutosh - DE34860 - Below we are creating different collection for new not commited and old commited records and criteria to find old and
         * new is based on "recordId" attribute of wrapper class because new records will have no id but old ones will have so in
         * total we are having following type of data
         * unselect - New uncommited record - null in recordId
         * unselect - commited record - id in recordId
         * Selected - uncommited - null in recordId
         * Selected - commited - id in recordId
         *
         * So all selected new entries/old commited records in selected section will remain as it is in "LinkedExternalPartiesList" and there id will  be included in do search when do
         * search method will get the records from "LinkedExternalPartiesList"
         * unselected new/already commited records are now removed from list so they will come as new contacts in search record section .
         *
         */
        List<Core_IPS_Case_Interested_Party__c> partiesToDelete = new List<Core_IPS_Case_Interested_Party__c>();
        Boolean isRecordDeleted = false;//To check whether any record is un selected
        if (LinkedExternalPartiesList.size() > 0){
            for (Integer i = 0; i < LinkedExternalPartiesList.size(); i++){
                if (LinkedExternalPartiesList.get(i).isSelected == false){
                    //we are identifying old records here using record id from wrapper so here only processing old records
                    if (LinkedExternalPartiesList.get(i).recordId != null){
                        //Maintaining set of IDs for old records so that we can delete later
                        toBeDeletedIps.add(LinkedExternalPartiesList.get(i).recordId);
                    }
                    LinkedExternalPartiesList.remove(i);
                }
            }

            relatedConatactIDs.clear();
            doSearch();
        }

        return null;
    }

    public PageReference Finished(){
        return (new PageReference('/' + CaseId));
    }

    public class IPWrapper{
        public boolean isSelected{ get; set; }

        public Contact Con{ get; set; }

        public User conUser{ get; set; }

        public IPWrapper(Contact C, User U){
            Con = C;
            conUser = U;
            isSelected = false;
        }

    }

    private void externalPartiesData(Case CaseObj, String mode){
        List<Core_IPS_Case_Interested_Party__c> LinkedExternalParties;//Ashutosh - DE34860 - making this a local var instead of global one
        if (CaseObj <> null && ((CaseObj.AccountId <> null && CaseObj.Core_IPS_Project_Case__c == null) || (CaseObj.Core_IPS_Project_Case__r <> null /*&& CaseObj.Core_IPS_Project_Case__r.Name <> null*/))){
            /*Ashutosh-US103988-Add type filter to only get external interested parties*/
            //FLS Check Added - Madhuri
            if (Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isAccessible()){
                LinkedExternalParties = [Select ID, Contact__c, Core_IPS_Account_Name__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c
                                         from Core_IPS_Case_Interested_Party__c
                                         WHERE Case__c = :CaseId AND Contact__c != null AND Type__c = 'External' AND Active__c = true];//US113986
            }
        }
        /*Ashutosh - DE34860 - adding the current Ext Ips to be shown on UI*/
        if (LinkedExternalParties != null && !LinkedExternalParties.isEmpty()){
            for (Core_IPS_Case_Interested_Party__c exIps : LinkedExternalParties){
                /*Mapping All esisting ips wrapper record by contact id so that if same contact record get deselected and selected again then we will check map and add the samerecord back to wrapper list and also remove the ip record id from ipsToBeDeleted set which will save deletion of the record */

                LinkedExtPartyWrapper partyRecord = new LinkedExtPartyWrapper(exIps.Contact__c, exIps.User__c, exIps.First_Name__c, exIps.Last_Name__c, exIps.Email__c, exIps.Id, true, null, exIps);
                LinkedExternalPartiesList.add(partyRecord);
                if (existingIpByContactId.get(exIps.Contact__c) == null){
                    existingIpByContactId.put(exIps.Contact__c, partyRecord);
                }
            }

        }
    }

    //DE35668 ----TChauhan---Commented out below method--Using this query in Without sharing Inner class
    /**private void fetchProjectMembers(Case CaseObj,String mode){
     //FLS Check Added - Madhuri
     if(Case.SObjectType.getDescribe().isAccessible()){
     ProjMem = [Select ID, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where Core_IPS_Project__c =: CaseObj.Core_IPS_Project_Case__c AND Core_Status__c = 'Active' AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c=false];
     }
     }**/
    public PageReference simpleSort(){
        IPRecordSet.clear();
        String sQuery;
        if (CaseId != null){
            //FLS Check Added - Madhuri
            if (Case.SObjectType.getDescribe().isAccessible()){
                CaseObj = [SELECT id, AccountID, Core_IPS_Project_Case__c, Core_IPS_Project_Case__r.Name
                           FROM Case
                           WHERE id = :CaseId];
            }
        }
        //Query all active user contacts related to this account
        allActiveContactIds = getActiveContacts(NULL, CaseObj.AccountId);
        // SOQL Injection Start - End -  Shipra
        Map<String, Object> bindMap = new Map<String, Object>{ 'accountId' => CaseObj.AccountId, 'searchableStr' => String.escapeSingleQuotes(searchableString),'ActiveConIds' => allActiveContactIds, 'relatedConIds' => relatedConatactIDs };

        sQuery = 'SELECT Id, firstName, LastName, Email, Name, AccountId, Account.Name ' + 
             'FROM Contact ' + 
             'WHERE AccountId = :accountId ' + 
             '  AND (Name like  : searchableStr OR ' + 
             'FirstName like :searchableStr  OR ' + 
             'LastName like :searchableStr OR ' + 
             'Email like :searchableStr )  ' + 
             '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' +   //modified by amritesh - DE39208 - 5/11/2018
        '  AND (ID IN : ActiveConIds) ' + 
             '  AND (NOT(ID IN : relatedConIds)) ' + 
             'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;

        ConList = Database.queryWithBinds(sQuery, bindMap, AccessLevel.USER_MODE);
        // SOQL Injection Fix - End -  Shipra
        for (Contact ConRec : ConList){
            IPRecordSet.add(new IPWrapper(ConRec, myUserMap.get(ConRec.id)));
            searchMade = true;
        }
        return null;
    }

    /***************************************************************************************************
     Method Name:  saveAndRedirect
     Method Type: Navigation Method
     Version     : 1.0
     Created Date: 23 Apr 2018
     Function    : Used to save/delete internal interested party/ies on case and redirect to case detail page.
     Input Parameters: No signature value but internally will use List<InterestedPartyWrapper> linkedPartiesList
     Output Parameters: Page reference to case detail page
     Description:   Used on the click of save button
     Used in     : Internal Interested parties creation/deletion and redirect
     Modification Log :
     * Developer                   Date                   Description
     * ----------------------------------------------------------------------------
     * Ashutosh Bhardwaj           23/04/2018              Created(US-103988)

     ****************************************************************************************************/
    public PageReference saveAndRedirect(){
        List<Core_IPS_Case_Interested_Party__c> interestedPartiesToBeCreated = new List<Core_IPS_Case_Interested_Party__c>();
        List<Core_IPS_Case_Interested_Party__c> partiesToBeDeleted = new List<Core_IPS_Case_Interested_Party__c>();
        PageReference ref = null;
        try{
            //Ashutosh - US103988 - creating list of parties to be deleted
            if (!toBeDeletedIps.isEmpty()){
                for (Id recId : toBeDeletedIps){
                    partiesToBeDeleted.add(new Core_IPS_Case_Interested_Party__c(
                        Id = recId
                    ));
                }
                ContactDataRetrieve conData = new ContactDataRetrieve();
                conData.deleteRecords(partiesToBeDeleted);

            }

            if (!LinkedExternalPartiesList.isEmpty()){
                for (LinkedExtPartyWrapper item : LinkedExternalPartiesList){
                    //Ashutosh - US103988 - Iterating over final wrapper list and getting only new entry to create new IPs record.
                    if (item.isSelected == true && String.isBlank(item.recordId)){
                        Core_IPS_Case_Interested_Party__c newRecord = new Core_IPS_Case_Interested_Party__c();
                        newRecord.Contact__c = item.contactId;
                        if (item <> null && item.userId <> null)
                            newRecord.User__c = item.userId;
                        //FLS check Added - Nishitha
                        if (Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Case__c.isCreateable() || Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Case__c.isUpdateable()){
                            newRecord.Case__c = CaseId;
                        }
                        newRecord.Type__c = 'External';
                        newRecord.Active__c = true;

                        interestedPartiesToBeCreated.add(newRecord);
                    }
                }
                if (!interestedPartiesToBeCreated.isEmpty()){

                    //Modified by Geetha as per US103991
                    ContactDataRetrieve conData = new ContactDataRetrieve();
                    conData.saveRecords(interestedPartiesToBeCreated);

                }
            }
            ref = new PageReference('/' + CaseId);
        } catch (Exception e){
            //showErrorMsg = true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error :' + e.getMessage()));

        }
        return ref;
    }

    /*Ashutosh - DE34860 - created the wrapper to hold all selected or deselected value on behalf of which new records for Ips get created */
    public class LinkedExtPartyWrapper{
        Id contactId;
        Id userId;

        public String firstName{ get; set; }

        public String lastName{ get; set; }

        public String email{ get; set; }

        Id recordId;

        public Boolean isSelected{ get; set; }

        public Contact con{ get; set; }

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

    //Added by Geetha as per US103991
    public without sharing class ContactDataRetrieve{
        public List<Contact> getRecords(String sQuery, Set<ID> ContactID, String searchableString, Set<ID> relatedConatactIDs, Set<ID> allActiveContactIds){
            return Database.query(sQuery);
        }

        public void saveRecords(list<Core_IPS_Case_Interested_Party__c> IPSObjList){
            insert IPSObjList;
        }

        /*Ashutosh _ US103988 -To accomodate Geetha changes*/
        public void deleteRecords(list<Core_IPS_Case_Interested_Party__c> IPSObjList){
            delete IPSObjList;
        }

        /**DE35668---TChauhan ---Added this method to query project members in without sharing context**/
        public List<Core_IPS_Project_Member__c> fetchProjectMembers(Case CaseObj){
            List<Core_IPS_Project_Member__c> listOfProjectMembers = new List<Core_IPS_Project_Member__c>();
            //FLS Check Added - Madhuri
            if (Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
                listOfProjectMembers = [Select ID, Core_IPS_Contact__c
                                        FROM Core_IPS_Project_Member__c
                                        where Core_IPS_Project__c = :CaseObj.Core_IPS_Project_Case__c AND Core_Status__c = 'Active' AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c = false];
            }
            return listOfProjectMembers;
        }

        /**Start---DE35668---TChauhan---Below is the reusable method to query User and filter out set of Active user contact ids in WITHOUT SHARING CONTEXT**/
        public Set<Id> getActiveContactsNoSharing(Set<Id> projContactIds, Id accountId){
            Set<Id> activeContactIds = new Set<Id>();
            List<User> allActiveUsers = new List<User>();

            if (accountId != NULL && projContactIds == NULL){
                allActiveUsers = [SELECT Id, Accountid, contactid
                                  FROM User
                                  WHERE isActive = TRUE and contactid != null AND Accountid = :accountId];
            } else if (projContactIds != Null && accountId == Null){
                allActiveUsers = [SELECT Id, contactid
                                  FROM User
                                  WHERE isActive = TRUE and contactid IN:projContactIds];
            }
            for (User active : allActiveUsers){
                activeContactIds.add(active.contactid);
            }

            return activeContactIds;
        }

        /**End ---DE35668**/
    }

}