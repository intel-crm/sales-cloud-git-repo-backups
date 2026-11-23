/**************************************************************************************************
Apex Class Name:  Core_IPS_Interested_Party_Int_Controller
Version     : 1.0
Created Date: 11 05 2015
Function    : Extension Controller Class for Core_IPS_Interested_Party_Internal Page. This class defines all the methods
              which are used for Searching, Adding, Removing Internal Interested Parties to the Case.
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Manoj Kumar                         04/18/2017              Core_IPS_Interested_Party_Int_Controller(),doSearch() method updated
                                                              as per Implentation of US61151. Added Try & Catch blocks to handle exceptions
* Karthick                            04/03/2018              Defect Fix - DE35929
* Ashutosh                             25/04/2018              changes for US103988 added
* Gourav                09/10/2018        US176534 - To enable Sales Reps to add other users like Agents as well  
* Sumukh                               10/11/2018             Added logic for US176533 - Iteration -18 
* Aayushi								15/11/2018			 Modified US113669
*****************************************************************************************************/

public with sharing class Core_IPS_Interested_Party_Int_Controller {

    private static final String DEFAULT_SORT_FIELD = 'FirstName';

    public string searchText{get;set;}
    public list<IPWrapper> IPRecordSet{get;set;} 
    //public list<IPWrapper> IPRecordSetSearch{get;set;} 
    public Id CaseId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
    public list<User> UserList = new List<User>();
    public list<Core_IPS_Intel_Support_Team__c> istUserList = new List<Core_IPS_Intel_Support_Team__c>();
    public Case CaseObj;
    public SET<ID> relatedUserIDs = new SET<ID>();
    
    //Added IPS Agent,Sales Reps variables  -- 4/18/2017 Manoj Kumar
    //Modified ProfileId type from ID to String -- 4/18/2017 Manoj Kumar
    Set<String> ProfileID = new Set<String>();
    public Boolean searchMadeInt{get;set;}
    public Boolean showErrorMsg{get;set;}
    public Boolean isEditable{get;set;} // added by sumukh for US176533
    //public List<Core_IPS_Case_Interested_Party__c> LinkedInternalParties{get;set;}Ashutosh - US103988 - Commented as a part of the US
    public List<InterestedPartyWrapper> linkedPartiesList{get;set;}//Ashutosh - US103988 - Wrapper list to show all parties
    private Map<Id,InterestedPartyWrapper> existingIpByUserId;//Ashutosh - US103988 - To handle selection/deselection of same record
    private Set<Id> toBeDeletedIps;//Ashutosh - US103988 - to maintain the IPs which were deselected from already selected list
    private List<Id> atmid = new List<Id>();
    public String noAssignedContactCaseRecordType;
    
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
    
    
    public Core_IPS_Interested_Party_Int_Controller() {
        try{
            List<Profile> ProfileLst = new List<Profile>();
            List<String> interestedPartiesList = new List<String>();
            toBeDeletedIps = new Set<Id>();//Ashutosh - US103988 - initialization
            IPRecordSet = new list<IPWrapper>();
            searchMadeInt = false;
            showErrorMsg = false;

            if(CaseId != null){
                //FLS check Added - Nishitha
                if(Case.SObjectType.getDescribe().isAccessible()){
                    CaseObj = [Select id, RecordTypeId,AccountID,account.ownerid,ownerid, Core_IPS_Project_Case__c,Core_IPS_Private_Project__c from Case where ID =: CaseId];
                }
            }           
            noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
            Id noAssignedContactCaseId = getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
            List<Core_IPS_Case_Interested_Party__c> LinkedInternalParties = new List<Core_IPS_Case_Interested_Party__c>();
            linkedPartiesList = new List<InterestedPartyWrapper>();//Ashutosh - US103988
            existingIpByUserId = new Map<Id,InterestedPartyWrapper>();//Ashutosh - US103988
            /*Ashutosh - 20/04/2018 -  US103988 - Adding "Type" check on interesetd party soql to get only internal parties*/
            //FLS Check Added - Nishitha
            if(Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isAccessible()){
                LinkedInternalParties = [Select ID, Contact__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: CaseId AND Type__c = 'Internal'];                 
            }
            /*Ashutosh - US103988 - 20/04/2018 - adding below block to populate values from wrapper*/
            if(LinkedInternalParties.size() > 0){
                for(Core_IPS_Case_Interested_Party__c CIPSCIPEXT : LinkedInternalParties){
                    if(CIPSCIPEXT.User__c != null){
                        relatedUserIDs.add(CIPSCIPEXT.User__c);
                    }
                    //InterestedPartyWrapper(Id usrId ,String fname ,String lname ,String emailId , Id recId ,Boolean isChecked)
                    /*Mapping All esisting ips wrapper record by user id so that if same user record get deselected and selected again then we will check map and add the samerecord back to wrapper list and also remove the ip record id from ipsToBeDeleted set which will save deletion of the record */
                    InterestedPartyWrapper partyRecord = new InterestedPartyWrapper(CIPSCIPEXT.User__c,CIPSCIPEXT.First_Name__c,CIPSCIPEXT.Last_Name__c,CIPSCIPEXT.Email__c,CIPSCIPEXT.Id,true);
                    linkedPartiesList.add(partyRecord);
                    if(existingIpByUserId.get(CIPSCIPEXT.User__c) == null){
                        existingIpByUserId.put(CIPSCIPEXT.User__c,partyRecord);
                    }
                }
            }   
            /**********************************************************************************************/
            
            interestedPartiesList = System.Label.Interested_Parties_Internal_Agent.split(';');//IPS Agent;IPS Agent Enhanced;Sales Rep-BB-Dual IPS;IPS Agent-Partner
            
            //Check if Loggedin User is IPS Agent and allow to search all Sales Reps irrespective of Case Account Team  -- 4/18/2017 Manoj Kumar
            for(String str : Label.Interested_Parties_Internal_Agent_ProfileIds.split(',')){  //All Agents profile IDs,Agent-Partner,SalesRep BB Dual IPS,IPS Support Org Admin 
                if(str == string.valueof(UserInfo.getProfileId())){
                    interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';')));
                    break;
                }
            }// END Manoj Kumar
            
             // added by sumukh for US176533
              
            isEditable = [SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId() AND RecordId = :CaseId].HasEditAccess;
            
            if(isEditable == false) {
                showErrorMsg = true;
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'You dont have sufficient access to add interested parties'));
                return ;
            }
            
            if(isEditable && CaseObj.RecordTypeId!=noAssignedContactCaseId ) {
                interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';')));                
            }
            
            //End by sumukh for US176533
            
            
            //US176534 -- Gourav: To fetch all Sales Rep IDs for non-Project NAC cases
            if(CaseObj.RecordTypeId==noAssignedContactCaseId && (CaseObj.AccountId==null) && (CaseObj.Core_IPS_Project_Case__c==null) ){
              interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';'))); //All Sales profiles included
            }
            
            ProfileLst = [Select ID, Name from Profile Where (Name =: System.Label.Interested_Parties_Internal_Admin OR Name in: interestedPartiesList) AND (NOT(ID IN : relatedUserIDs))];
            
            for(Profile P : ProfileLst){
                ProfileID.add(P.id); //Profile IDs of IPS Agent,Support Org Admin and all Sales profiles
            }
            
            
            String sQuery;
            
        } catch (exception ex){            
        }
    }


    
    
   public PageReference doSearch()
    {
        try{
             
            //Ashutosh - US103988 - created below block to add relatedIds from wrapper List
            if(linkedPartiesList <> null && linkedPartiesList.size() > 0){
            
                for(InterestedPartyWrapper CIPSCIPEXT : linkedPartiesList){
                    if(CIPSCIPEXT.userId != null){
                        relatedUserIDs.add(CIPSCIPEXT.userId); 
                    }
                }
            }
            String searchableString = '';
            atmId.clear();
            
            for(String profId : label.Core_IPS_Sales_Rep_ProfileIds.split(',')){ /* qualifying profiles ,Sales Manager, Sales Ops ,Sales Rep-BB ,Sales Rep-CW*/
                
                if(UserInfo.getProfileId() == profId ){
                    ProfileID.addall(new List<String>(label.Core_IPS_Sales_Rep_ProfileIds.split(',')));
                    break;
                }
                // }
            } // END  -- Manoj Kumar
            // }
            atmid.add(CaseObj.account.ownerid); 
            atmid.add(CaseObj.ownerid); 
            
            if(String.IsBlank(searchText))
            {
                showErrorMsg = true;
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Please enter text to be searched.'));
                if(IPRecordSet.size() > 0){ IPRecordSet.clear(); }
            } 
            
            //start Added for US113669
            else if(CaseObj.Core_IPS_Project_Case__c!=null && CaseObj.Core_IPS_Private_Project__c){                 

                searchableString = searchText + '%'; //Starts with search functionality
                searchableString = searchableString.escapeHtml4();
                String sQuery;
                String projId=CaseObj.Core_IPS_Project_Case__c;
                sQuery= 'SELECT Id, Name, FirstName, LastName, Email FROM User WHERE Id In (Select Core_IPS_User__c from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c =:projId AND Status__c=\'Active\') AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :relatedUserIDs)) AND (IsActive = true) ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast +' Limit '+System.Label.Core_IPS_Interested_Party_Limit; 
                UserList = Database.query(sQuery.escapeHtml4());  
            }//end
            else{
                //Modified by Karthick - DE35929 - I9 
                //searchableString = '%' + searchText + '%';
                searchableString = searchText + '%'; //Starts with search functionality
                String sQuery;
                sQuery = 'SELECT Id, Name, FirstName, LastName, Email ' + 
                    'FROM User ' + 
                    'WHERE (ProfileID IN :ProfileID AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :relatedUserIDs)) AND (IsActive = true)) OR (ID in :atmid AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN : relatedUserIDs)) AND (IsActive = true)) ' + 
                    'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast +' Limit '+System.Label.Core_IPS_Interested_Party_Limit;
                UserList = Database.query(sQuery.escapeHtml4());
                
            }
            
                if(UserList!=null && UserList.size() > 0 ){
                    if(IPRecordSet.size() > 0){
                        IPRecordSet.clear();
                    }
                    for(User UserRec: UserList)
                    {
                        IPRecordSet.add(new IPWrapper(UserRec));
                        searchMadeInt = true;
                    }//Added by Karthick to render warning msg- - DE35929 - I9
                        
                        if(isMoreThanThousand(searchableString)){
                        showErrorMsg = true;
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+System.Label.Core_IPS_Interested_Party_Warning_Msg));
                    }
                }
                else{
                    if(IPRecordSet.size() > 0){
                        IPRecordSet.clear();
                    }
                    showErrorMsg = true;
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No User Found.'));
                }
                
                //searchText = searchText.removeEnd('%');
                //searchText = searchText.removeStart('%');
                //return null;
                        
            
        } catch (Exception ex){
            showErrorMsg = true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.Core_IPS_Internal_InterestedParty_SearchException_Msg));
        }
        return null;
    }
    

    public class IPWrapper {
        
        public boolean isSelected{get;set;}
        public User Usr{get;set;}
        
        public IPWrapper(User U)
        {
            Usr = U;
            isSelected = false;
        }
    }

    
    public PageReference AddSelectedContacts(){
        
        try{
            list<Core_IPS_Case_Interested_Party__c> IPSObjList = new list<Core_IPS_Case_Interested_Party__c>();
            
            if(IPRecordSet.size() > 0)
            {
                for(IPWrapper IPW1:IPRecordSet)
                {
                    if(IPW1.isSelected)
                    {                          
                        if(existingIpByUserId.get(IPW1.Usr.Id) == null){                            
                            linkedPartiesList.add(new InterestedPartyWrapper(IPW1.Usr.Id,IPW1.Usr.FirstName,IPW1.Usr.LastName,IPW1.Usr.Email,null,true));
                        }
                        else{
                            existingIpByUserId.get(IPW1.Usr.Id).isSelected =  true;//Ashutosh-Us103988
                            linkedPartiesList.add(existingIpByUserId.get(IPW1.Usr.Id));
                            toBeDeletedIps.remove(existingIpByUserId.get(IPW1.Usr.Id).recordId);//Ashutosh-US103988 - Removing the Id from Ips to be deleted
                        }                       
                    }                    
                }
            }
            
                       
            if(linkedPartiesList.size() > 0){
               doSearch();
                ApexPages.getMessages().clear();
                if(ApexPages.getMessages().size()>0){
                    showErrorMsg = false;
                }    
            }                
        } 
        catch (Exception ex){
            showErrorMsg = true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Core_IPS_Internal_Interested_Party_Exception_Msg));
            if(IPRecordSet.size() > 0){
                for(IPWrapper IPW1:IPRecordSet)
                {
                    IPW1.isSelected = false;
                }
            }
        }
        return null;
    }


    public PageReference removeSelectedContacts(){
        
        //Ashutosh - US103988 - Craeted the block to maintain everything on the wrapper basis
        //Here also avoiding try catch as previously we could have exception on record deleted but now we are not doing any DML
        if(linkedPartiesList.size() > 0){
            for(Integer i =0 ;i< linkedPartiesList.size();i++){
                if(linkedPartiesList.get(i).isSelected == false){
                    //we are identifying old records here using record id from wrapper so here only processing old records
                    if(linkedPartiesList.get(i).recordId != null){
                        //Maintaining set of IDs for old records so that we can delete later
                        toBeDeletedIps.add(linkedPartiesList.get(i).recordId);
                    }
                    linkedPartiesList.remove(i);
                }
            }
            relatedUserIDs.clear(); 
            dosearch();
            ApexPages.getMessages().clear();
            if(ApexPages.getMessages().size()>0) {
                showErrorMsg = false;
            }    
        }
        return null;
    }

    public PageReference Finished(){
        return (new PageReference ('/' + CaseId));
    }


    public PageReference simpleSort() {
        IPRecordSet.clear();
        
        /* atmid is being loaded by the search routine */
        //Modified by Karthick - DE35929 - I9 
        //String searchableString = '%' + searchText + '%';
        String searchableString = searchText + '%';
        
        String sQuery;
        sQuery = 'SELECT Id, Name, FirstName, LastName, Email ' + 
            'FROM User ' + 
            'WHERE (ProfileID IN :ProfileID AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :relatedUserIDs)) AND (IsActive = true)) OR (ID in :atmid AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN : relatedUserIDs)) AND (IsActive = true)) ' + 
            'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast +' Limit '+System.Label.Core_IPS_Interested_Party_Limit;
        UserList = Database.query(sQuery.escapeHtml4());
        if(UserList != NULL && UserList.size() > 0)
        {
            for(User userRec: UserList)
            {
                IPRecordSet.add(new IPWrapper(UserRec));
                searchMadeInt = true;
            }//Added by Karthick to render warning msg- DE35929 - I9 
            if(isMoreThanThousand(searchableString)){
                
                showErrorMsg = true;
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+System.Label.Core_IPS_Interested_Party_Warning_Msg));
            }
        }
        return null;
    }
    
    //Check the search resutls are more than 1000 or not
    public boolean isMoreThanThousand(String searchableString){
        String sQueryCount;
        //start Added for US113669
        if(CaseObj.Core_IPS_Project_Case__c!=null && CaseObj.Core_IPS_Private_Project__c){
            String projId=CaseObj.Core_IPS_Project_Case__c;
         sQueryCount = 'SELECT count() FROM User WHERE Id In (Select Core_IPS_User__c from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c =:projId AND Status__c=\'Active\') AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :relatedUserIDs)) AND (IsActive = true)';   
        }
        else{//end
        sQueryCount = 'Select Count() FROM User '+ 
                         'WHERE (ProfileID IN :ProfileID AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :relatedUserIDs)) AND (IsActive = true)) OR (ID in :atmid AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN : relatedUserIDs)) AND (IsActive = true)) ';
        }
            Integer recordCount = Database.countQuery(sQueryCount);
        
        return (recordCount > Integer.valueof(System.Label.Core_IPS_Interested_Party_Limit));
        
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
                delete partiesToBeDeleted;
            }
            
            if(!linkedPartiesList.isEmpty()){
                for(InterestedPartyWrapper item  : linkedPartiesList){
                    //Ashutosh - US103988 - Iterating over final wrapper list and getting only new entry to create new IPs record.
                    if(item.isSelected == true && String.isBlank(item.recordId)){
                        Core_IPS_Case_Interested_Party__c newRecord = new Core_IPS_Case_Interested_Party__c();
                        newRecord.User__c = item.userId; 
                        newRecord.Case__c = CaseId;
                        newRecord.Type__c = 'Internal';
                        newRecord.Active__c = true;
                        if(CaseObj.Core_IPS_Project_Case__c!=null && CaseObj.Core_IPS_Private_Project__c ){
                         newRecord.Core_IPS_Project_Interested_Party__c=true;   
                        }
                        interestedPartiesToBeCreated.add(newRecord);
                    }
                }
                if(!interestedPartiesToBeCreated.isEmpty()){
                    insert interestedPartiesToBeCreated;
                }
            }
            ref= new PageReference('/'+CaseId);
        }
        catch(Exception e){
            showErrorMsg = true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error :'+e.getMessage()));
            
        }
        return ref;
    }
    
    //Gourav - Utility Method to fetch Case RecordtypeId based on RecordType Name 
  public static Schema.DescribeSObjectResult DescCase;  
    public static Map<id,Schema.RecordTypeInfo> MapCaseRecordTypeID ;
    public static Map<string,Schema.RecordTypeInfo> MapCaseRecordTypeName;    
    public static Id getCaseRecordtypeIDByName(string caseRecordtypeName)
    {
        Id  CaseRecordtypeID = null;
        if(DescCase==null)
        {
            DescCase = Schema.SObjectType.Case; 
        }
        if(MapCaseRecordTypeName ==  null)
        {
            MapCaseRecordTypeName = DescCase.getRecordTypeInfosByName();
        }       
        CaseRecordtypeID = MapCaseRecordTypeName.get(caseRecordtypeName).getRecordTypeId();
        return CaseRecordtypeID;
        
    }
    
    /*Ashutosh - US103988-20/04/2018 - created the wrapper to hold all selected or deselected value on behalf of which new records for Ips get created */ 
    public class InterestedPartyWrapper{
        Id userId;
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String email {get; set;}
        Id recordId;
        public Boolean isSelected{get;set;}
        public InterestedPartyWrapper(Id usrId ,String fname ,String lname ,String emailId , Id recId ,Boolean isChecked){
            userId = usrId;
            firstName = fname;
            lastName = lname;
            email = emailId;
            recordId = recId;
            isSelected = isChecked;
            
        }
    }
}