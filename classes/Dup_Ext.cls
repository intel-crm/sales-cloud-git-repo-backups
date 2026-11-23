public with sharing class Dup_Ext{

    private static final String DEFAULT_SORT_FIELD = 'FirstName';

    public string searchText{get;set;}
    public list<IPWrapper> IPRecordSet{get;set;} 
    public list<IPWrapper> IPRecordSetSearch{get;set;} 
    public Map<id,User> myUserMap = new Map<id,User>();
    public Id CaseId{get;set;}
    public list<Contact> ConList{get;set;}
    public Case CaseObj;
    public SET<ID> relatedConatactIDs = new SET<ID>();
    public SET<ID> inactiveContactIDs = new SET<ID>();
    public Boolean searchMade{get;set;}
    List<Profile> ProfileLst = new List<Profile>();
    Set<ID> ProfileID = new Set<ID>();
    
  

    public Core_SortedGrid_ColumnHeader sortHeader 
    {
        get 
        {
             if (sortHeader == NULL)
                 sortHeader = new Core_SortedGrid_ColumnHeader(DEFAULT_SORT_FIELD);
                 
             return sortHeader;                
        }        
        set
        {
             sortHeader = value;       
        }
    }


    Public String searchableString ;

    Id currentAccountId;
    String mode = ApexPages.currentPage().getParameters().get('mode');

    public List<Core_IPS_Case_Interested_Party__c> LinkedExternalParties{get;set;}
    public List<Core_IPS_Project_Member__c> ProjMem{get;set;}

    //public List<Core_IPS_Case_Interested_Party__c> linkedExternalPartiesForInlineVF{get;set;}
    //public List<List<sobject>> searchResults {get;set;}
    //public Account Accnt{get;set;}
    //public User loggedInUser;
    //public Contact Cont;
    //public boolean search{get;set;}
    //public boolean allList{get;set;}
    //public List<Core_Project_Member__c> ProjMem{get;set;};
    public Dup_Ext(ApexPages.StandardController controller) {
    
        CaseId =ApexPages.currentPage().getParameters().get('id');
        //LinkedExternalParties = [Select ID, Contact__c,Contact__r.Account.Name, First_Name__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: ApexPages.currentPage().getParameters().get('id') AND Contact__c != null];
        //system.debug('###@@###'+LinkedExternalParties);
        LinkedExternalParties = new List<Core_IPS_Case_Interested_Party__c>();
        ProjMem = new List<Core_IPS_Project_Member__c>();
        //linkedExternalPartiesForInlineVF = new List<Core_IPS_Case_Interested_Party__c>();
        searchMade = false;
        IPRecordSet = new list<IPWrapper>();
        
        if(CaseId != null){
            CaseObj = [Select id, AccountID, Core_IPS_Project_Case__c,Core_IPS_Project_Case__r.Name from Case where ID =: CaseId];
        }        
        system.debug('1234567 CaseObj '+CaseObj);
        
        User currentuser=[Select Id,ContactId,AccountId from User where Id=:userinfo.getuserId()];
        if(currentuser.ContactId <> null){
            //currentContactId = currentuser.ContactId;
            currentAccountId = currentuser.AccountId;
        }
        //List<Core_IPS_Case_Interested_Party__c> LinkedExternalParties = new List<Core_IPS_Case_Interested_Party__c>();        
        externalPartiesData(CaseObj,mode);
        //if((CaseObj.AccountId <> null && CaseObj.Core_IPS_Project_Case__c == null) || (CaseObj.Core_IPS_Project_Case__r <> null && CaseObj.Core_IPS_Project_Case__r.Name <> null))
        //LinkedExternalParties = [Select ID, Contact__c,Core_IPS_Account_Name__c, First_Name__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: CaseId AND Contact__c != null];
        //system.debug(' AND Contact__r.AccountId =:CaseObj.AccountId############'+CaseObj.Core_IPS_Project_Case__r.Name+LinkedExternalParties);
        /*if((CaseObj.AccountId <> null && CaseObj.Core_IPS_Project_Case__c == null) || (CaseObj.Core_IPS_Project_Case__r <> null && CaseObj.Core_IPS_Project_Case__r.Name <> null))
        linkedExternalPartiesForInlineVF = [Select ID, Contact__c,Core_IPS_Account_Name__c, First_Name__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: CaseId AND Contact__c != null];
        system.debug('###@@###'+linkedExternalPartiesForInlineVF);*/   
        List<User> AllInactiveUser = new List<User>();
        AllInactiveUser = [Select id, contactid from User where isActive = false];
        
        for(User inactiveUsr : AllInactiveUser){
            if(inactiveUsr.contactid != null){
                inactiveContactIDs.add(inactiveUsr.contactid);
            }
        }
        
        if(LinkedExternalParties.size() > 0){
            for(Core_IPS_Case_Interested_Party__c CIPSCIPEXT : LinkedExternalParties){
                if(CIPSCIPEXT.Contact__c != null){
                    relatedConatactIDs.add(CIPSCIPEXT.Contact__c);
                }
            }
        }

        
        String sQuery;
        Set<ID> ContactID = new Set<ID>();
        if(CaseObj != null){
            if(CaseObj.Core_IPS_Project_Case__c == null && CaseObj.AccountId != null){
                Id acctId = CaseObj.AccountId;
                sQuery = 'SELECT Id, FirstName, LastName, Name, Email, AccountId, Account.Name ' + 
                         'FROM Contact ' + 
                         'WHERE AccountID = :acctId ' + 
                         '  AND Core_IPS_Active__c = true ' + 
                         '  AND (NOT(ID IN : relatedConatactIDs)) ' + 
                         '  AND (NOT(ID IN : inactiveContactIDs)) ' + 
                         'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;
                ConList = Database.query(sQuery);           
            }
            if(CaseObj.Core_IPS_Project_Case__c != null){
                fetchProjectMembers(CaseObj,mode);
                //ProjMem = [Select ID, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where Core_IPS_Project__c =: CaseObj.Core_IPS_Project_Case__c];
                                
                for(Core_IPS_Project_Member__c CPM : ProjMem){
                    if(CPM.Core_IPS_Contact__c != null){
                        ContactID.add(CPM.Core_IPS_Contact__c);
                    }
                }
                
                if(ContactID.size()>0){
                    sQuery = 'SELECT Id, FirstName, LastName, Email, Name, AccountId, Account.Name ' + 
                             'FROM Contact ' + 
                             'WHERE Id IN :ContactID ' + 
                             '  AND Core_IPS_Active__c = true ' + 
                             '  AND (NOT(ID IN : relatedConatactIDs)) ' + 
                             '  AND (NOT(ID IN : inactiveContactIDs))' + 
                             'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;
                    ConList = Database.query(sQuery);           
                }                
            }
            
            if(ConList !=null)
            {
                List<User> myUserList = [Select id,contactid from User where contactid in :ConList];
                for(User uc : myUserList)
                {
                    myUserMap.put(uc.contactid,uc);
                }                 
                for(Contact ConRec: ConList)
                {
                    IPRecordSet.add(new IPWrapper(ConRec,myUserMap.get(ConRec.id)));                    
                }
            }
            
        }
        System.debug('1234567 IPRecordSet View '+IPRecordSet);
        System.debug('1234567 IPRecordSet.size View '+IPRecordSet.size());
        //Added by kareem
        
    }
    public Dup_Ext() {
        
        /*searchMade = false;
        IPRecordSet = new list<IPWrapper>();
        
        if(CaseId != null){
            CaseObj = [Select id, AccountID, Core_IPS_Project_Case__c from Case where ID =: CaseId];
        }        
        system.debug('1234567 CaseObj '+CaseObj);
        
        User currentuser=[Select Id,ContactId from User where Id=:userinfo.getuserId()];
        if(currentuser.ContactId <> null)
            currentContactId = currentuser.ContactId;
        //List<Core_IPS_Case_Interested_Party__c> LinkedExternalParties = new List<Core_IPS_Case_Interested_Party__c>();
        LinkedExternalParties = [Select ID, Contact__c, Core_IPS_Account_Name__c, First_Name__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: CaseId AND Contact__c != null];
        system.debug('###@@###'+LinkedExternalParties);   
        List<User> AllInactiveUser = new List<User>();
        AllInactiveUser = [Select id, contactid from User where isActive = false];
        
        for(User inactiveUsr : AllInactiveUser){
            if(inactiveUsr.contactid != null){
                inactiveContactIDs.add(inactiveUsr.contactid);
            }
        }
        
        if(LinkedExternalParties.size() > 0){
            for(Core_IPS_Case_Interested_Party__c CIPSCIPEXT : LinkedExternalParties){
                if(CIPSCIPEXT.Contact__c != null){
                    relatedConatactIDs.add(CIPSCIPEXT.Contact__c);
                }
            }
        }
        
        Set<ID> ContactID = new Set<ID>();
        if(CaseObj != null){
            if(CaseObj.Core_IPS_Project_Case__c == null && CaseObj.AccountId != null){
                ConList = [Select Id, FirstName, LastName, Name, Email,AccountId,Account.Name From Contact where AccountID =: CaseObj.Accountid AND Core_IPS_Active__c = true AND (NOT(ID IN : relatedConatactIDs)) AND (NOT(ID IN : inactiveContactIDs))];
                
            }
            if(CaseObj.Core_IPS_Project_Case__c != null){
                
                List<Core_IPS_Project_Member__c> ProjMem = new List<Core_IPS_Project_Member__c>();
                ProjMem = [Select ID, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where Core_IPS_Project__c =: CaseObj.Core_IPS_Project_Case__c];
                                
                for(Core_IPS_Project_Member__c CPM : ProjMem){
                    if(CPM.Core_IPS_Contact__c != null){
                        ContactID.add(CPM.Core_IPS_Contact__c);
                    }
                }
                
                if(ContactID.size()>0){
                    ConList = [Select Id, FirstName, LastName, Email, Name,AccountId,Account.Name From Contact where ID IN :ContactID AND Core_IPS_Active__c = true AND (NOT(ID IN : relatedConatactIDs)) AND (NOT(ID IN : inactiveContactIDs))];
                }
                
            }
            
            if(ConList !=null)
            {
                List<User> myUserList = [Select id,contactid from User where contactid in :ConList];
                for(User uc : myUserList)
                {
                    myUserMap.put(uc.contactid,uc);
                }                 
                for(Contact ConRec: ConList)
                {
                    IPRecordSet.add(new IPWrapper(ConRec,myUserMap.get(ConRec.id)));                    
                }
            }
            
        }
        System.debug('1234567 IPRecordSet View '+IPRecordSet);
        System.debug('1234567 IPRecordSet.size View '+IPRecordSet.size());*/
    }

    
    public PageReference doSearch(){
        
        Id acctId;
        String sQuery;
        
        //system.debug('@@@@@@@@'+LinkedExternalParties.size()+LinkedExternalParties+'*************'+IPRecordSet.size()+IPRecordSet+relatedConatactIDs.size()+relatedConatactIDs);
        if(LinkedExternalParties <> null && LinkedExternalParties.size() > 0){
            for(Core_IPS_Case_Interested_Party__c CIPSCIPEXT : LinkedExternalParties){
                if(CIPSCIPEXT.Contact__c != null){
                    relatedConatactIDs.add(CIPSCIPEXT.Contact__c);
                    system.debug('****####***'+CIPSCIPEXT.Contact__c);
                }
            }
        }
        system.debug('@@@@@@@@'+relatedConatactIDs+relatedConatactIDs.size());
        system.debug('$$$$ searchText '+searchText);        
        Boolean isEstrik = false;
        if(String.IsBlank(searchText)){
            system.debug('$$$$ inside is blank ');
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Please enter text to be searched.'));
            if(IPRecordSet <> null && IPRecordSet.size() > 0){
                IPRecordSet.clear();
                //searchMade = true;
            }
        }        
        else{            
            if(searchText.contains('*')){
                searchableString = searchText.replace('*','%');
                isEstrik = true;
            }else{
                searchableString = searchText;
            }
            searchableString =  '%' + searchableString + '%';
            system.debug('$$$$ inside not is blank '+searchableString );
            
            /*if((CaseObj.Core_IPS_Project_Case__c == null && CaseObj.AccountId != null) || (CaseObj.Core_IPS_Project_Case__c != null)){
                System.debug('^^^^^ inside else');
                if(IPRecordSet.size() > 0){
                    IPRecordSet.clear();
                }
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No Results Found.'));
                //return null;
            }*/
            
            if(CaseObj <> null && CaseObj.Core_IPS_Project_Case__c == null && CaseObj.AccountId != null){
                system.debug('$$$$ inside first IF ');
                
                //ConList  = [select Id, firstName, LastName, Email, Name,AccountId,Account.Name from Contact where AccountId =: CaseObj.AccountId AND (Name like :searchableString OR FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND Core_IPS_Active__c = true AND (NOT(ID IN : relatedConatactIDs)) AND (NOT(ID IN : inactiveContactIDs)) AND (NOT(ID =: currentContactId))];

                acctId = CaseObj.AccountId;
                sQuery = 'SELECT Id, firstName, LastName, Email, Name, AccountId, Account.Name ' + 
                         'FROM Contact ' + 
                         'WHERE AccountId = :acctId ' + 
                         '  AND (Name like :searchableString OR ' + 
                         '       FirstName like :searchableString OR ' + 
                         '       LastName like :searchableString OR ' + 
                         '       Email like :searchableString) ' + 
                         '  AND Core_IPS_Active__c = true ' + 
                         '  AND (NOT(ID IN :relatedConatactIDs)) ' + 
                         '  AND (NOT(ID IN :inactiveContactIDs)) ' + 
                         'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;
                ConList = Database.query(sQuery);           
                
                system.debug('$$$$ inactiveContactIDs 1 '+inactiveContactIDs);
                system.debug('$$$$ relatedConatactIDs 1 '+relatedConatactIDs);
                system.debug('$$$$ ConList 1 '+ConList);
            }
            if(CaseObj <> null && CaseObj.Core_IPS_Project_Case__c != null)
            {
                system.debug('$$$$ inside second IF ');
                //List<Core_IPS_Project_Member__c> ProjMem = new List<Core_IPS_Project_Member__c>();
                fetchProjectMembers(CaseObj,mode);
                //ProjMem = [Select ID, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where Core_IPS_Project__c =: CaseObj.Core_IPS_Project_Case__c AND Core_Status__c = 'Active'];
                system.debug('$$$$ ProjMem '+ProjMem);
                system.debug('$$$$ ProjMem size '+ProjMem.size());
                
                Set<ID> ContactID = new Set<ID>();
                for(Core_IPS_Project_Member__c CPM : ProjMem){
                    if(CPM.Core_IPS_Contact__c != null){
                        ContactID.add(CPM.Core_IPS_Contact__c);
                    }
                }
                //system.debug('$$$$ ContactID '+ContactID+'$$$$'+currentContactId);
                if(ContactID.size()>0){
                    //ConList = [Select Id, FirstName, LastName, Email, Name,AccountId,Account.Name From Contact where ID IN :ContactID AND (Name like :searchableString OR FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND Core_IPS_Active__c = true AND (NOT(ID IN : relatedConatactIDs)) AND (NOT(ID IN : inactiveContactIDs)) AND (NOT(ID =: currentContactId))];
                    sQuery = 'SELECT Id, FirstName, LastName, Email, Name, AccountId, Account.Name ' + 
                             'FROM Contact ' + 
                             'WHERE Id IN :ContactID ' + 
                             '  AND (Name like :searchableString OR ' + 
                             '       FirstName like :searchableString OR ' + 
                             '       LastName like :searchableString OR ' + 
                             '       Email like :searchableString) ' + 
                             '  AND Core_IPS_Active__c = true ' + 
                             '  AND (NOT(ID IN : relatedConatactIDs)) ' + 
                             '  AND (NOT(ID IN : inactiveContactIDs)) ' + 
                             'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;
                    ConList = Database.query(sQuery);           
                    system.debug('$$$$ ConList 2 '+ConList);
                }
                /////////////
                else{
                    if(IPRecordSet.size() > 0){
                    IPRecordSet.clear();
                    }
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No Results Found.'));
                    //searchText = searchableString.removeEnd('%');
                    //searchText = searchableString.removeStart('%');
                    return null;
                }
                ////////////
            }
            
            if(ConList <> null && ConList.size() > 0)
            {
                System.debug('^^^^^ inside if'+ConList);
                if(IPRecordSet.size() > 0){
                    IPRecordSet.clear();
                }
                List<User> myUserList = [Select id,contactid from User where contactid in :ConList];
                for(User uc : myUserList)
                {
                    myUserMap.put(uc.contactid,uc);
                } 
                for(Contact ConRec: ConList)
                {
                    IPRecordSet.add(new IPWrapper(ConRec,myUserMap.get(ConRec.id)));
                    searchMade = true;
                }
                system.debug('--Search List--'+IPRecordSet);
            }
            else{
                System.debug('^^^^^ inside else');
                if(IPRecordSet <> null && IPRecordSet.size() > 0){
                    IPRecordSet.clear();
                }
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No Results Found.'));
                //return null;
            }
            
        }
        
        System.debug('1234567 IPRecordSet Search '+IPRecordSet);
        //System.debug('1234567 IPRecordSet.size Search '+IPRecordSet.size());
        system.debug('*****************'+searchText+searchableString);
        //searchText = searchableString.removeEnd('%');
        //searchText = searchableString.removeStart('%');
        //if(searchText.contains('%') && isEstrik == true){                        
        //    searchText = searchText.replace('%','*');
        //}
        system.debug('*****************'+searchText);
        return null;
    }
    
    /*public PageReference back(){
        if(CaseId != null){
            PageReference CasePage = new PageReference('/' + CaseId);
            CasePage.setRedirect(true);
            return CasePage;
        }
        else{
            PageReference CasePage = new PageReference('/' + '500/o');
            CasePage.setRedirect(true);
            return CasePage;
        }
    }*/
    
    
    public PageReference AddSelectedContacts(){
        
        
        list<Core_IPS_Case_Interested_Party__c> IPSObjList = new list<Core_IPS_Case_Interested_Party__c>();
        system.debug('1234567 IPRecordSet Add selected Start '+IPRecordSet);
        if(IPRecordSet.size() > 0)
        {
            for(IPWrapper IPW1:IPRecordSet)
            {
                if(IPW1.isSelected)
                {   
                    system.debug('1234567 inside if is selected');
                    Core_IPS_Case_Interested_Party__c IPSObj = new Core_IPS_Case_Interested_Party__c();
                    IPSObj.Contact__c = IPW1.Con.Id;
                    if(IPW1 <> null && IPW1.conUser <> null && IPW1.conUser.Id <> null)
                    IPSObj.User__c = IPW1.conUser.Id;
                    IPSObj.Case__c = CaseId;
                    IPSObj.Type__c = 'External';
                    IPSObj.Active__c = true;
                    IPSObjList.add(IPSObj);
                }
                
                system.debug('1234567 IPSObjList before insert '+IPSObjList);
                system.debug('1234567 IPSObjList.size before insert '+IPSObjList.size());
            }
        }
        
        if(IPSObjList.size()>0){
                    insert IPSObjList;
                    externalPartiesData(CaseObj,mode);
                    //if((CaseObj.AccountId <> null && CaseObj.Core_IPS_Project_Case__c == null) || (CaseObj.Core_IPS_Project_Case__r <> null && CaseObj.Core_IPS_Project_Case__r.Name <> null))
                    //    LinkedExternalParties = [Select ID, Contact__c,Core_IPS_Account_Name__c, First_Name__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: CaseId AND Contact__c != null];
                    //LinkedExternalParties.addAll(IPSObjList);
                    //searchText = '*';
                    doSearch();
                    return null;
                    //return (new PageReference ('/' + CaseId));
                }
        
        /*try{
            ProfileLst = [Select ID, Name from Profile Where (Name =: System.Label.Interested_Parties_Internal_Admin OR Name =: System.Label.Interested_Parties_Internal_Agent OR Name =: System.Label.Interested_Parties_Internal_ExternalCustomer)];
        
            for(Profile P : ProfileLst){
                ProfileID.add(P.id);
            }
            
            Id CurrentUserProfileId = userinfo.getProfileId();
            
            if(ProfileID.contains(CurrentUserProfileId)){
                if(IPSObjList.size()>0){
                    insert IPSObjList;
                    return (new PageReference ('/' + CaseId));
                }
               else{
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Please select at least one Contact as interested party.'));
                    return null;
                }
            }
            else{
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Only IPS SUPPORT ORG ADMIN NEW, IPS AGENT NEW and IPS EXTERNAL CONTACT NEW profile user can add interested party.'));
                return null;
            }   
        }
        catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+e));
            system.debug('exception = '+e);
            
        }*/
        return null;
    }

    public PageReference removeSelectedContacts(){
        list<Core_IPS_Case_Interested_Party__c> IPSObjList = new list<Core_IPS_Case_Interested_Party__c>();
        list<Core_IPS_Case_Interested_Party__c> IPSObjRemainingItemsList = new list<Core_IPS_Case_Interested_Party__c>();
        system.debug('1234567 LinkedExternalParties Add selected Start '+LinkedExternalParties);
        if(LinkedExternalParties.size() > 0)
        {
        
            for(Core_IPS_Case_Interested_Party__c lepObj:LinkedExternalParties)
            {
                if(lepObj.Active__c == false)
                {   
                    system.debug('1234567 inside if is selected');
                    IPSObjList.add(lepObj);
                    //LinkedExternalParties.remove(0);
                }else{
                    IPSObjRemainingItemsList.add(lepObj);
                }
                
                system.debug('1234567 IPSObjList before insert '+IPSObjList);
                system.debug('1234567 IPSObjList.size before insert '+IPSObjList.size());
            }
        }
        
        if(IPSObjList.size()>0){
                    delete IPSObjList;
                    LinkedExternalParties.clear();
                    LinkedExternalParties.addAll(IPSObjRemainingItemsList);
                    relatedConatactIDs.clear();
                    //searchText = '*';
                    dosearch();
                    return null;
                    //return (new PageReference ('/' + CaseId));
                }
        return null;
    }


    public PageReference Finished(){
        return new PageReference ('/' + CaseId);
    }
    
    public class IPWrapper {
        
        public boolean isSelected{get;set;}
        public Contact Con{get;set;}
        public User conUser{get;set;}
        
        public IPWrapper(Contact C,User U)
        {
            Con = C;
            conUser = U;
            isSelected = false;
        }
    }
    
    private void externalPartiesData(Case CaseObj,String mode){
            //system.debug('CaseObj===    '+CaseObj.Core_IPS_Project_Case__r.Name);
            //system.debug('CaseObj===    '+CaseObj.Core_IPS_Project_Case__r);
            //system.debug('mode===   '+mode);
            if(CaseObj <> null && ((CaseObj.AccountId <> null && CaseObj.Core_IPS_Project_Case__c == null) || (CaseObj.Core_IPS_Project_Case__r <> null /*&& CaseObj.Core_IPS_Project_Case__r.Name <> null*/))){
                IF(mode <> null && mode == 'mip' && (CaseObj.Core_IPS_Project_Case__r <> null /*&& CaseObj.Core_IPS_Project_Case__r.Name <> null*/)){                    
                    LinkedExternalParties = [Select ID, Contact__c,Core_IPS_Account_Name__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c
                                             WHERE Case__c =: CaseId AND Contact__c != null AND Contact__r.AccountId =:currentAccountId];
                    system.debug('&&&&if&&&&&'+LinkedExternalParties.size()+LinkedExternalParties);
                }else{
                    LinkedExternalParties = [Select ID, Contact__c,Core_IPS_Account_Name__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c
                                             WHERE Case__c =: CaseId AND Contact__c != null];
                    system.debug('&&&&else&&&&&'+LinkedExternalParties.size()+LinkedExternalParties);
                }               
            }
    }
    
    private void fetchProjectMembers(Case CaseObj,String mode){
        IF(mode <> null && mode == 'mip'){
            ProjMem = [Select ID, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where Core_IPS_Project__c =: CaseObj.Core_IPS_Project_Case__c AND Core_IPS_Contact__r.AccountId =:currentAccountId AND Core_Status__c = 'Active'];
            system.debug('&&&&&&&&&'+ProjMem.size()+ProjMem);
        }else{
            ProjMem = [Select ID, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where Core_IPS_Project__c =: CaseObj.Core_IPS_Project_Case__c AND Core_Status__c = 'Active'];
            system.debug('&&&&&&&&&'+ProjMem.size()+ProjMem);
        }
    }


    public void sort() {
    }
    

    public PageReference simpleSort()
    {
        IPRecordSet.clear();
        
        String sQuery;
        if(CaseId != null){
            CaseObj = [SELECT id, AccountID, Core_IPS_Project_Case__c, Core_IPS_Project_Case__r.Name 
                       FROM Case 
                       WHERE id = :CaseId];
        }  

        sQuery = 'SELECT Id, firstName, LastName, Email, Name, AccountId, Account.Name ' + 
                 'FROM Contact ' + 
                 'WHERE AccountId =\''+ CaseObj.AccountId+ '\' ' + 
                 '  AND (Name like \''      + String.escapeSingleQuotes(searchableString) + '\' OR ' + 
                        'FirstName like \'' + String.escapeSingleQuotes(searchableString) + '\' OR ' + 
                        'LastName like \''  + String.escapeSingleQuotes(searchableString) + '\' OR ' + 
                        'Email like \''     + String.escapeSingleQuotes(searchableString) + '\' )  ' + 
                 '  AND Core_IPS_Active__c = true ' + 
                 '  AND (NOT(ID IN : relatedConatactIDs)) ' + 
                 '  AND (NOT(ID IN : inactiveContactIDs)) ' +
                 'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;   
     
        System.debug('#51 sQuery: ' + sQuery);
      
        ConList = Database.query(sQuery);  
        System.Debug('#52 ConList: ' + ConList); 
        
        for(Contact ConRec: ConList)
        {
            IPRecordSet.add(new IPWrapper(ConRec, myUserMap.get(ConRec.id)));
            searchMade = true;
        }     
        System.Debug('#53 IPRecordSet: ' + IPRecordSet); 

        return null;
    }
    
}