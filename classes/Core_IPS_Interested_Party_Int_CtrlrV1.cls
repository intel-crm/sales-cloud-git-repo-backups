public class Core_IPS_Interested_Party_Int_CtrlrV1 {
    /*Ashutosh - US103988 - 20/04/2017 - created for a poc on story*/
    private static final String DEFAULT_SORT_FIELD = 'FirstName';

    public string searchText{get;set;}
    public list<IPWrapper> IPRecordSet{get;set;} 
    //public list<IPWrapper> IPRecordSetSearch{get;set;} 
    public Id CaseId = ApexPages.currentPage().getParameters().get('id');
    public list<User> UserList = new List<User>();
    public Case CaseObj;
    public SET<ID> relatedUserIDs = new SET<ID>();
    
    //Added IPS Agent,Sales Reps variables  -- 4/18/2017 Manoj Kumar
    //Modified ProfileId type from ID to String -- 4/18/2017 Manoj Kumar
    Set<String> ProfileID = new Set<String>();
    public Boolean searchMadeInt{get;set;}
    public Boolean showErrorMsg{get;set;}
    //public List<Core_IPS_Case_Interested_Party__c> LinkedInternalParties{get;set;}Ashutosh - US103988 - Commented as a part of the US
    public List<InterestedPartyWrapper> linkedPartiesList{get;set;}//Ashutosh - US103988 - Wrapper list to show all parties
    private Set<Id> toBeDeletedIps;//Ashutosh - US103988 - to maintain the IPs which were deselected from already selected list
    private List<Id> atmid = new List<Id>();
    
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
    
    
    public Core_IPS_Interested_Party_Int_CtrlrV1() {
        try{
            List<Profile> ProfileLst = new List<Profile>();
            List<String> interestedPartiesList = new List<String>();
            toBeDeletedIps = new Set<Id>();//Ashutosh - US103988 - initialization
            IPRecordSet = new list<IPWrapper>();
            searchMadeInt = false;
            showErrorMsg = false;
            
            if(CaseId != null){
                CaseObj = [Select id, AccountID,account.ownerid,ownerid, Core_IPS_Project_Case__c from Case where ID =: CaseId];
            }
            system.debug('1234567 CaseObj '+CaseObj);        
            List<Core_IPS_Case_Interested_Party__c> LinkedInternalParties = new List<Core_IPS_Case_Interested_Party__c>();
            linkedPartiesList = new List<InterestedPartyWrapper>();//Ashutosh - US103988
            /*Ashutosh - 20/04/2018 -  US103988 - Adding "Type" check on interesetd party soql to get only internal parties*/
            LinkedInternalParties = [Select ID, Contact__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: CaseId AND Type__c = 'Internal'];
            
            /* Ashutosh - US103988 - 20/04/2018 - commenting below block to stop populating values from query result
            if(LinkedInternalParties.size() > 0){
                for(Core_IPS_Case_Interested_Party__c CIPSCIPEXT : LinkedInternalParties){
                    if(CIPSCIPEXT.User__c != null){
                        relatedUserIDs.add(CIPSCIPEXT.User__c);
                    }
                } 
            }*/
            /*Ashutosh - US103988 - 20/04/2018 - adding below block to populate values from wrapper*/
			if(LinkedInternalParties.size() > 0){
                for(Core_IPS_Case_Interested_Party__c CIPSCIPEXT : LinkedInternalParties){
                    if(CIPSCIPEXT.User__c != null){
                        relatedUserIDs.add(CIPSCIPEXT.User__c);
                    }
                    //InterestedPartyWrapper(Id usrId ,String fname ,String lname ,String emailId , Id recId ,Boolean isChecked)
                    linkedPartiesList.add(new InterestedPartyWrapper(CIPSCIPEXT.User__c,CIPSCIPEXT.First_Name__c,CIPSCIPEXT.Last_Name__c,CIPSCIPEXT.Email__c,CIPSCIPEXT.Id,true));
                }
            }	
            /**********************************************************************************************/
            
            interestedPartiesList = System.Label.Interested_Parties_Internal_Agent.split(';');
            
            //Check if Loggedin User is IPS Agent and allow to search all Sales Reps irrespective of Case Account Team  -- 4/18/2017 Manoj Kumar
            for(String str : Label.Interested_Parties_Internal_Agent_ProfileIds.split(',')){
                if(str == string.valueof(UserInfo.getProfileId())){
                    System.debug('--IPS Agent User --');
                    interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';')));
                    break;
                }
            }// END Manoj Kumar
            
            ProfileLst = [Select ID, Name from Profile Where (Name =: System.Label.Interested_Parties_Internal_Admin OR Name in: interestedPartiesList) AND (NOT(ID IN : relatedUserIDs))];
            
            for(Profile P : ProfileLst){
                ProfileID.add(P.id);
            }
            
            
            String sQuery;
            /**************************Commented as it is causing view state Error while Loading Internal Interested Party page
            ***************************and these Users are not showing anywhere on Page at the time of Loading -- 4/2/52017  Manoj Kumar
            if(CaseObj != null)
            {            
                sQuery = 'SELECT Id, Name, FirstName, LastName, Email ' + 
                         'FROM User ' + 
                         'WHERE (ProfileID IN :ProfileID AND (IsActive = true)) ' + 
                         'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast;
                UserList = Database.query(sQuery);

                system.debug('#21 UserList: ' + UserList);
                if(UserList !=null)
                {
                    for(User UserRec: UserList)
                    {
                        IPRecordSet.add(new IPWrapper(UserRec));
                        
                    }
                }
                
            } */
            System.debug('1234567 IPRecordSet View '+IPRecordSet);
            System.debug('1234567 IPRecordSet.size View '+IPRecordSet.size());
        } catch (exception ex){
            System.debug('-- Exception Occured :'+ex.getMessage());
        }
    }


    
    
    public PageReference doSearch()
    {
        try{
            //linkedPartiesList
            /*Ashutosh - US103988 - Commented below block to stop getting related Id from query result
            if(LinkedInternalParties <> null && LinkedInternalParties.size() > 0){
                for(Core_IPS_Case_Interested_Party__c CIPSCIPEXT : LinkedInternalParties){
                    if(CIPSCIPEXT.User__c != null){
                        relatedUserIDs.add(CIPSCIPEXT.User__c);
                    }
                }
            }*/
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
            Set<Id> SetAccountID = new Set<Id>();            
            SetAccountID.add(CaseObj.accountid);
            System.debug('--SetAccountID--'+SetAccountID);
            for(Set<id> SetID : Core_IPS_Helper_Utility.getFAEsByAccount(SetAccountID).values())
            {
                atmid.addall(SetID);
                
                //Checking if Loggedin User is SalesRep and part of Case Account Team or not-- 4/18/2017 Manoj
                if(SetID.contains(UserInfo.getUserId())){
                    System.debug('--Loggedin User is part of Case Account Team --');
                    for(String profId : label.Core_IPS_Sales_Rep_ProfileIds.split(',')){
                        /*
                         * qualifying profiles
                            Sales Manager
                            Sales Ops
                            Sales Rep-BB
                            Sales Rep-CW

                        */
                    if(UserInfo.getProfileId() == profId ){
                        System.debug('--Loggedin User is SalesRep and part of Case Account Team --');
                           ProfileID.addall(new List<String>(label.Core_IPS_Sales_Rep_ProfileIds.split(',')));
                           break;
                        }
                    }
                } // END  -- Manoj Kumar
            }
            System.debug('--ProfileID --'+ProfileID);
            atmid.add(CaseObj.account.ownerid); 
            atmid.add(CaseObj.ownerid); 
            
            if(String.IsBlank(searchText))
            {
                showErrorMsg = true;
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Please enter text to be searched.'));
                if(IPRecordSet.size() > 0){ IPRecordSet.clear(); }
            }        
            else{
                //Modified by Karthick - DE35929 - I9 
                //searchableString = '%' + searchText + '%';
                searchableString = searchText + '%'; //Starts with search functionality
                String sQuery;
                sQuery = 'SELECT Id, Name, FirstName, LastName, Email ' + 
                         'FROM User ' + 
                         'WHERE (ProfileID IN :ProfileID AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :relatedUserIDs)) AND (IsActive = true)) OR (ID in :atmid AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN : relatedUserIDs)) AND (IsActive = true)) ' + 
                         'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast +' Limit '+System.Label.Core_IPS_Interested_Party_Limit;
                UserList = Database.query(sQuery);
                                
                system.debug('eeee UserList '+UserList);
                system.debug('eeee UserList size '+UserList.size());
                
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
            }
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
            system.debug('1234567 IPRecordSet Add selected Start '+IPRecordSet);
            if(IPRecordSet.size() > 0)
            {
                for(IPWrapper IPW1:IPRecordSet)
                {
                    if(IPW1.isSelected)
                    {   
                        system.debug('1234567 inside if is selected');
                        /*
                         *Ashutosh - US103988 - commented to create wrapper instance 
                        Core_IPS_Case_Interested_Party__c IPSObj = new Core_IPS_Case_Interested_Party__c();
                        IPSObj.User__c = IPW1.Usr.Id;
                        IPSObj.Case__c = CaseId;
                        IPSObj.Type__c = 'Internal';
                        IPSObj.Active__c = true;
                        IPSObjList.add(IPSObj);*/
                        //InterestedPartyWrapper(Id usrId ,String fname ,String lname ,String emailId , Id recId ,Boolean isChecked)
                        linkedPartiesList.add(new InterestedPartyWrapper(IPW1.Usr.Id,IPW1.Usr.FirstName,IPW1.Usr.LastName,IPW1.Usr.Email,null,true));
                        
                    }
                    
                    system.debug('1234567 IPSObjList before insert '+IPSObjList);
                    system.debug('1234567 IPSObjList.size before insert '+IPSObjList.size());
                }
            }
            
            /*Ashutosh - US103988 - stop inseration on just selection and will use wrapper to do any furthur activity
             * if(IPSObjList.size()>0){
                //insert IPSObjList;Ashutosh - US103988 - stop inseration on just selection
                //externalPartiesData(CaseObj,mode);
                //if((CaseObj.AccountId <> null && CaseObj.Core_IPS_Project_Case__c == null) || (CaseObj.Core_IPS_Project_Case__r <> null && CaseObj.Core_IPS_Project_Case__r.Name <> null))
                //    LinkedExternalParties = [Select ID, Contact__c,Core_IPS_Account_Name__c, First_Name__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: CaseId AND Contact__c != null];
                //LinkedExternalParties.addAll(IPSObjList);
                
                //Ashutosh - US103988 - commented below query as we are just adding value in wrapper instead querying
                //LinkedInternalParties = [Select ID, Contact__c, First_Name__c, Last_Name__c, Email__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: CaseId];
                //searchText = '*';
                doSearch();
                ApexPages.getMessages().clear();
                if(ApexPages.getMessages().size()>0) showErrorMsg = false;
            } */           
            if(linkedPartiesList.size() > 0){
                doSearch();
                ApexPages.getMessages().clear();
                if(ApexPages.getMessages().size()>0) showErrorMsg = false;
            }
        } catch (Exception ex){
            System.debug('--Exception Occured--');
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
        /*
         * Ashutosh - US103988 - Commented the below block
         * try{
            list<Core_IPS_Case_Interested_Party__c> IPSObjList = new list<Core_IPS_Case_Interested_Party__c>();
            list<Core_IPS_Case_Interested_Party__c> IPSObjRemainingItemsList = new list<Core_IPS_Case_Interested_Party__c>();
            system.debug('1234567 LinkedInernalParties Add selected Start '+LinkedInternalParties);
            if(LinkedInternalParties.size() > 0)
            {
            
                for(Core_IPS_Case_Interested_Party__c lepObj:LinkedInternalParties)
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
            
            if(IPSObjList.size()>0) {
                delete IPSObjList;
                LinkedInternalParties.clear();
                LinkedInternalParties.addAll(IPSObjRemainingItemsList);
                relatedUserIDs.clear();
                dosearch();
                ApexPages.getMessages().clear();
                if(ApexPages.getMessages().size()>0) showErrorMsg = false;
            }
        } catch (Exception ex){
            System.debug('--Exception Occured--');
            showErrorMsg = true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Core_IPS_Internal_Interested_PartyRemove_Exception_Msg));
            if(LinkedInternalParties.size() > 0){
                for(Core_IPS_Case_Interested_Party__c IPs:LinkedInternalParties)
                {   
                    if(IPs.Active__c == false)
                    IPs.Active__c = true;
                }
            }
        }*/
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
            if(ApexPages.getMessages().size()>0) showErrorMsg = false;
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
            UserList = Database.query(sQuery);
                     
            system.debug('#71 sQuery: ' + sQuery);
            system.debug('#72 UserList size: ' + UserList.size());
            if(UserList != NULL && UserList.size() > 0)
            {
                for(User UserRec: UserList)
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
        
        String sQueryCount = 'Select Count() FROM User '+ 
                         'WHERE (ProfileID IN :ProfileID AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :relatedUserIDs)) AND (IsActive = true)) OR (ID in :atmid AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN : relatedUserIDs)) AND (IsActive = true)) ';
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