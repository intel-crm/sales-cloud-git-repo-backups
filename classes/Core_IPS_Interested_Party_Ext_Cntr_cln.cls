/***************************************************************************************************
Class Name          : Core_IPS_Interested_Party_Ext_Controller
Version             : 2.0 
Description         : This Class is a Controller class for Core_IPS_Interested_Party_External Visualforce page
Used in             : Core_IPS_Interested_Party_External Visualforce page
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                    
* Amritesh					  5/11/2018				 DE39208 - Added Core_IPS_Email_Opt_Out__c check in queries
****************************************************************************************************/  

public class Core_IPS_Interested_Party_Ext_Cntr_cln {
    
    private static final String DEFAULT_SORT_FIELD = 'FirstName'; 
    private static final String Inactive_ContactIDs_Query =' (Select contactid from User where isActive = false and contactid != null) ';
    public string searchText{get;set;}
    public list<IPWrapper> IPRecordSet{get;set;} 
    public list<IPWrapper> IPRecordSetSearch{get;set;} 
    public Map<id,User> myUserMap = new Map<id,User>();
    public Id CaseId = ApexPages.currentPage().getParameters().get('id');
    public list<Contact> ConList{get;set;}
    public Case CaseObj;
    public SET<ID> relatedConatactIDs = new SET<ID>();
    //public SET<ID> inactiveContactIDs = new SET<ID>();
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
    
    //public List<Core_IPS_Case_Interested_Party__c> LinkedExternalParties{get;set;}//Ashutosh - DE34860 - Making it a local variable as we are using wrapper info on UI
    public List<LinkedExtPartyWrapper> LinkedExternalPartiesList{get;set;}//Ashutosh - DE34860 - wrapper to store new or old Ext Ips to handle insertion and UI manipulations
    private Map<Id,LinkedExtPartyWrapper> existingIpByContactId;//Ashutosh - US103988 - To handle selection/deselection of same record
    private Set<Id> toBeDeletedIps;//Ashutosh - US103988 - to maintain the IPs which were deselected from already selected list
    public List<Core_IPS_Project_Member__c> ProjMem{get;set;}
    
    public Core_IPS_Interested_Party_Ext_Cntr_cln(ApexPages.StandardController controller) {
        
        LinkedExternalPartiesList = new List<LinkedExtPartyWrapper>(); //Ashutosh - DE34860 -  US103988
        existingIpByContactId = new Map<Id,LinkedExtPartyWrapper>();//Ashutosh - US103988
        toBeDeletedIps = new Set<Id>();//Ashutosh - US103988
        ProjMem = new List<Core_IPS_Project_Member__c>();
        //linkedExternalPartiesForInlineVF = new List<Core_IPS_Case_Interested_Party__c>();
        searchMade = false;
        IPRecordSet = new list<IPWrapper>();
        
        if(CaseId != null){
            CaseObj = [Select id, AccountID, Core_IPS_Project_Case__c,Core_IPS_Project_Case__r.Name from Case where ID =: CaseId];
        }        
        //system.debug('1234567 CaseObj '+CaseObj);
        
        User currentuser=[Select Id,ContactId,AccountId from User where Id=:userinfo.getuserId()];
        if(currentuser.ContactId <> null){
            //currentContactId = currentuser.ContactId;
            currentAccountId = currentuser.AccountId;
        }
        //List<Core_IPS_Case_Interested_Party__c> LinkedExternalParties = new List<Core_IPS_Case_Interested_Party__c>();        
        externalPartiesData(CaseObj,mode);
                //Started for ViewState Error : Gourav
      /*  List<User> AllInactiveUser = new List<User>();
        AllInactiveUser = [Select id, contactid from User where isActive = false];
        //system.debug('AllInactiveUser==>'+AllInactiveUser);
        for(User inactiveUsr : AllInactiveUser){
            
            if(inactiveUsr.contactid != null){
                inactiveContactIDs.add(inactiveUsr.contactid);
                
            }
        } */
        
        /*
* Ashutosh - DE34860 - commented this block because now we can use wrapper list insted of an Ips object's  list collection 
if(LinkedExternalParties.size() > 0){
for(Core_IPS_Case_Interested_Party__c CIPSCIPEXT : LinkedExternalParties){
if(CIPSCIPEXT.Contact__c != null){
relatedConatactIDs.add(CIPSCIPEXT.Contact__c);
}
}
}*/
        if(LinkedExternalPartiesList.size() > 0){
            for(LinkedExtPartyWrapper ip : LinkedExternalPartiesList){
                if(ip.contactId != null){
                    relatedConatactIDs.add(ip.contactId);
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
                    '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' + //modified by amritesh - DE39208 - 5/11/2018
                    '  AND (NOT(ID IN : relatedConatactIDs)) ' + 
                    '  AND (ID NOT IN '+Inactive_ContactIDs_Query+') ' + 
                    'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;
                System.debug('===================================----------------------->>'+sQuery);
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
                        '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' +  //modified by amritesh - DE39208 - 5/11/2018
                        '  AND (NOT(ID IN : relatedConatactIDs)) ' + 
                        '  AND (ID NOT IN '+Inactive_ContactIDs_Query+')' + 
                        'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;
                    System.debug('========================---------------------->>'+sQuery);
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
        //System.debug('1234567 IPRecordSet.size View '+IPRecordSet.size());
        //Added by kareem
        
    }
    public Core_IPS_Interested_Party_Ext_Cntr_cln() {
        
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
ConList = [Select Id, FirstName, LastName, Name, Email,AccountId,Account.Name From Contact where AccountID =: CaseObj.Accountid AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false AND (NOT(ID IN : relatedConatactIDs)) AND (NOT(ID IN : inactiveContactIDs))];  //modified by amritesh - DE39208 - 5/11/2018

}
if(CaseObj.Core_IPS_Project_Case__c != null){

List<Core_IPS_Project_Member__c> ProjMem = new List<Core_IPS_Project_Member__c>();
ProjMem = [Select ID, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where Core_IPS_Project__c =: CaseObj.Core_IPS_Project_Case__c AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c=false];

for(Core_IPS_Project_Member__c CPM : ProjMem){
if(CPM.Core_IPS_Contact__c != null){
ContactID.add(CPM.Core_IPS_Contact__c);
}
}

if(ContactID.size()>0){
ConList = [Select Id, FirstName, LastName, Email, Name,AccountId,Account.Name From Contact where ID IN :ContactID AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false AND (NOT(ID IN : relatedConatactIDs)) AND (NOT(ID IN : inactiveContactIDs))]; //modified by amritesh - DE39208 - 5/11/2018
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
        /*
* Ashutosh - DE34860 - commenting the block as we will now loop on wrappper list for IPs
if(LinkedExternalParties <> null && LinkedExternalParties.size() > 0){
for(Core_IPS_Case_Interested_Party__c CIPSCIPEXT : LinkedExternalParties){
if(CIPSCIPEXT.Contact__c != null){
relatedConatactIDs.add(CIPSCIPEXT.Contact__c);
system.debug('****####***'+CIPSCIPEXT.Contact__c);
}
}
}*/
        if(LinkedExternalPartiesList <> null && LinkedExternalPartiesList.size() > 0){
            for(LinkedExtPartyWrapper CIPSCIPEXT : LinkedExternalPartiesList){
                if(CIPSCIPEXT.contactId != null){
                    relatedConatactIDs.add(CIPSCIPEXT.contactId);
                    system.debug('****####***'+CIPSCIPEXT.contactId);
                }
            }
        }
        //system.debug('@@@@@@@@'+relatedConatactIDs+relatedConatactIDs.size());
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
                    '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' + //modified by amritesh - DE39208 - 5/11/2018
                    '  AND (NOT(ID IN :relatedConatactIDs)) ' + 
                    '  AND (ID NOT IN '+Inactive_ContactIDs_Query+') ' + 
                    'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;
                ConList = Database.query(sQuery);           
                
                //system.debug('$$$$ inactiveContactIDs 1 '+inactiveContactIDs);
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
                //system.debug('$$$$ ProjMem size '+ProjMem.size());
                
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
                        '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' + //modified by amritesh - DE39208 - 5/11/2018
                        '  AND (NOT(ID IN : relatedConatactIDs)) ' + 
                        '  AND (ID NOT IN '+Inactive_ContactIDs_Query+') ' + 
                        'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;
                    
                    //Innerclass without sharing:
                    ContactDataRetrieve conData = new ContactDataRetrieve();                    
                    //Modified by Geetha as per US103991
                    ConList = conData.getRecords(sQuery,ContactID,searchableString,relatedConatactIDs);
                    //ConList = Database.query(sQuery);
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
        system.debug('*****************'+searchText);
        return null;
    }
    
    
    
    
    
    public  PageReference AddSelectedContacts(){
        list<Core_IPS_Case_Interested_Party__c> IPSObjList = new list<Core_IPS_Case_Interested_Party__c>();
        system.debug('1234567 IPRecordSet Add selected Start '+IPRecordSet);
        if(IPRecordSet.size() > 0)
        {
            for(IPWrapper IPW1:IPRecordSet)
            {
                if(IPW1.isSelected)
                {   
                    system.debug('1234567 inside if is selected');
                    /*
* Ashutosh - DE34860 - commented here because now we will maintain the wrapper list here instead of saving records
* we will fill up the wrapper list with newly selected contacts 
* LinkedExtPartyWrapper (Id conId ,Id usrId ,String fname ,String lname ,String emailId , Boolean isNewRecord ,Boolean isChecked,Contact contactRecord,Core_Ips_interested_Party ipRecord)
* Here "isNewRecord" will be true to distinct these records from existing External IPs also at last when we will add those records 
* from wrapper to list then we will set the property Case__c,Type__c,Active__c according to mentioned here as these will be same for all new records.
Core_IPS_Case_Interested_Party__c IPSObj = new Core_IPS_Case_Interested_Party__c();
IPSObj.Contact__c = IPW1.Con.Id;
if(IPW1 <> null && IPW1.conUser <> null && IPW1.conUser.Id <> null)
IPSObj.User__c = IPW1.conUser.Id;
IPSObj.Case__c = CaseId;
IPSObj.Type__c = 'External';
IPSObj.Active__c = true;
IPSObjList.add(IPSObj);*/
                    Id userId = (IPW1 <> null && IPW1.conUser <> null && IPW1.conUser.Id <> null) ? IPW1.conUser.Id : null;
                    //LinkedExtPartyWrapper LinkedExtPartyWrapper(Id conId ,Id usrId ,String fname ,String lname ,String emailId , Id recId ,Boolean isChecked)
                    
                    /*Ashutosh - US103988- If we found that interested party record don't exist for this contact we will create new record with recordId attribute set to null
else we will get the record from the map where we mapped wrapper element by contact id and will add it to the current list to show and also remove the 
interested party id from the set "toBedeletedIps" to avoid deletion of ip record of this entry*/
                    if(existingIpByContactId.get(IPW1.Con.Id) == null){
                        
                        LinkedExternalPartiesList.add(new LinkedExtPartyWrapper(IPW1.Con.Id ,userId ,IPW1.con.firstName,IPW1.con.lastName,IPW1.con.email , null ,true,IPW1.Con,null));
                    }
                    else{
                        existingIpByContactId.get(IPW1.Con.Id).isSelected =  true;//Ashutosh-Us103988
                        LinkedExternalPartiesList.add(existingIpByContactId.get(IPW1.Con.Id));
                        toBeDeletedIps.remove(existingIpByContactId.get(IPW1.Con.Id).recordId);//Ashutosh-US103988 - Removing the Id from Ips to be deleted
                    }
                }
                
                system.debug('1234567 IPSObjList before insert '+IPSObjList);
                //system.debug('1234567 IPSObjList.size before insert '+IPSObjList.size());
            }
        }
        
        /*
* Ashutosh - DE34860 - To put a check on Ips wrapper list and to stop insert DML for Interested party record on just selecting a record
if(IPSObjList.size()>0){
insert IPSObjList; Ashutosh - DE34860 - So preventing any object to be inserted on just selection
externalPartiesData(CaseObj,mode);
//if((CaseObj.AccountId <> null && CaseObj.Core_IPS_Project_Case__c == null) || (CaseObj.Core_IPS_Project_Case__r <> null && CaseObj.Core_IPS_Project_Case__r.Name <> null))
//    LinkedExternalParties = [Select ID, Contact__c,Core_IPS_Account_Name__c, First_Name__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: CaseId AND Contact__c != null];
//LinkedExternalParties.addAll(IPSObjList);
//searchText = '*';
doSearch();
return null;
//return (new PageReference ('/' + CaseId));
}*/
        if(LinkedExternalPartiesList.size() > 0){
            //externalPartiesData(CaseObj,mode);
            
            doSearch();
            return null;
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
        /*
* Ashutosh - DE34860 - commenting implementation because new implemenatation will work according to wrapper list pf IPs
* list<Core_IPS_Case_Interested_Party__c> IPSObjList = new list<Core_IPS_Case_Interested_Party__c>();
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
//system.debug('1234567 IPSObjList.size before insert '+IPSObjList.size());
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
}*/
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
        if(LinkedExternalPartiesList.size() > 0){
            for(Integer i =0 ;i< LinkedExternalPartiesList.size();i++){
                if(LinkedExternalPartiesList.get(i).isSelected == false){
                    //we are identifying old records here using record id from wrapper so here only processing old records
                    if(LinkedExternalPartiesList.get(i).recordId != null){
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
        return (new PageReference ('/' + CaseId));
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
        List<Core_IPS_Case_Interested_Party__c> LinkedExternalParties;//Ashutosh - DE34860 - making this a local var instead of global one
        if(CaseObj <> null && ((CaseObj.AccountId <> null && CaseObj.Core_IPS_Project_Case__c == null) || (CaseObj.Core_IPS_Project_Case__r <> null /*&& CaseObj.Core_IPS_Project_Case__r.Name <> null*/))){
            /*Ashutosh-US103988-Add type filter to only get external interested parties*/	
            LinkedExternalParties = [Select ID, Contact__c,Core_IPS_Account_Name__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c
                                     WHERE Case__c =: CaseId AND Contact__c != null  AND Type__c= 'External' AND Active__c = true];//US113986 
            
            //system.debug('&&&&else&&&&&'+LinkedExternalParties.size()+LinkedExternalParties);
            
        }
        /*Ashutosh - DE34860 - adding the current Ext Ips to be shown on UI*/
        if(LinkedExternalParties != null && !LinkedExternalParties.isEmpty()){
            for(Core_IPS_Case_Interested_Party__c exIps : LinkedExternalParties){
                //LinkedExtPartyWrapper(Id conId ,Id usrId ,String fname ,String lname ,String emailId , Id recId ,Boolean isChecked,Contact conRec , core_Ips_interested_Party interestedParty)
                /*Mapping All esisting ips wrapper record by contact id so that if same contact record get deselected and selected again then we will check map and add the samerecord back to wrapper list and also remove the ip record id from ipsToBeDeleted set which will save deletion of the record */
                
                LinkedExtPartyWrapper partyRecord = new LinkedExtPartyWrapper(exIps.Contact__c,exIps.User__c,exIps.First_Name__c,exIps.Last_Name__c,exIps.Email__c,exIps.Id,true,null,exIps);
                LinkedExternalPartiesList.add(partyRecord);
                if(existingIpByContactId.get(exIps.Contact__c) == null){
                    existingIpByContactId.put(exIps.Contact__c,partyRecord);
                }
            }
            
        }
    }
    
    private void fetchProjectMembers(Case CaseObj,String mode){
        //Modified by Karthick - US104036 - R4.2 - I10
        /*IF(mode <> null && mode == 'mip'){
ProjMem = [Select ID, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where Core_IPS_Project__c =: CaseObj.Core_IPS_Project_Case__c  AND Core_Status__c = 'Active' AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c=false];
//system.debug('&&&&&&&&&'+ProjMem.size()+ProjMem);
}else{ */
        
        ProjMem = [Select ID, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where Core_IPS_Project__c =: CaseObj.Core_IPS_Project_Case__c AND Core_Status__c = 'Active' AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c=false];
        //system.debug('&&&&&&&&&'+ProjMem.size()+ProjMem);
        
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
            '  AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false' + //modified by amritesh - DE39208 - 5/11/2018
            '  AND (NOT(ID IN : relatedConatactIDs)) ' + 
            '  AND (ID NOT IN '+Inactive_ContactIDs_Query+') ' +
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
            if(!toBeDeletedIps.isEmpty()){
                for(Id recId  : toBeDeletedIps){
                    partiesToBeDeleted.add(new Core_IPS_Case_Interested_Party__c(Id = recId));
                }
                ContactDataRetrieve conData = new ContactDataRetrieve();
                conData.deleteRecords(partiesToBeDeleted);
                
            }
            
            if(!LinkedExternalPartiesList.isEmpty()){
                for(LinkedExtPartyWrapper item  : LinkedExternalPartiesList){
                    //Ashutosh - US103988 - Iterating over final wrapper list and getting only new entry to create new IPs record.
                    if(item.isSelected == true && String.isBlank(item.recordId)){
                        Core_IPS_Case_Interested_Party__c newRecord = new Core_IPS_Case_Interested_Party__c();
                        newRecord.Contact__c = item.contactId;
                        if(item <> null && item.userId <> null)
                            newRecord.User__c = item.userId;
                        newRecord.Case__c = CaseId;
                        newRecord.Type__c = 'External';
                        newRecord.Active__c = true;
                        
                        interestedPartiesToBeCreated.add(newRecord);
                    }
                }
                if(!interestedPartiesToBeCreated.isEmpty()){
                    
                    //Modified by Geetha as per US103991
                    ContactDataRetrieve conData = new ContactDataRetrieve();
                    conData.saveRecords(interestedPartiesToBeCreated);	
                    
                }
            }
            ref= new PageReference('/'+CaseId);
        }
        catch(Exception e){
            //showErrorMsg = true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error :'+e.getMessage()));
            
        }
        return ref;
    }
    /*Ashutosh - DE34860 - created the wrapper to hold all selected or deselected value on behalf of which new records for Ips get created */ 
    public class LinkedExtPartyWrapper{
        Id contactId;
        Id userId;
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String email {get; set;}
        Id recordId;
        public Boolean isSelected{get;set;}
        public Contact con {get;set;}
        public Core_IPS_Case_Interested_Party__c ipRecord {get;set;}
        public LinkedExtPartyWrapper(Id conId ,Id usrId ,String fname ,String lname ,String emailId , Id recId ,Boolean isChecked,Contact conRec , Core_IPS_Case_Interested_Party__c ipRec){
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
        public  List<Contact> getRecords(String sQuery, Set<ID> ContactID,String searchableString,Set<ID> relatedConatactIDs){
            return Database.query(sQuery);
        }
        public void saveRecords(list<Core_IPS_Case_Interested_Party__c> IPSObjList){
            insert IPSObjList;
        }
        /*Ashutosh _ US103988 -To accomodate Geetha changes*/
        public void deleteRecords(list<Core_IPS_Case_Interested_Party__c> IPSObjList){
            delete IPSObjList;
        }
    } 
}