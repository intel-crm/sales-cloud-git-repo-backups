/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_AccountTeamAudit_Controller
Version     : 1.0 
Created Date: 5/24/16 
Function    : Controller for Core_AccountTeamAudit and Core_AccountTeamAudit_DataOps VF pages
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* David S Wong              5/24/16                Development Start
* KavyaShree          july22,2020        Security scan fix
*****************************************************************************************************************************************************************************************************/
public class Core_AccountTeamAudit_Controller {
public Boolean pageEditedFlag{get;set;}
public Core_AccountTeamAudit_Controller(){
pageEditedFlag=false; //US105593-For lightning migration added the pageEditedFlag set to False onload page by Rajesh//
}
    public class TeamMemberWithAccess {
        public Id userID {get;set;} 
        public Id accountID {get;set;} 
        public Id atmID {get;set;} 
        public String userName {get;set;} 
        public String caseAccess {get;set;} 
        public String opportunityAccess {get;set;} 
        public String accountAccess {get;set;} 
        public String caseAccessUI {get;set;} 
        public String opportunityAccessUI {get;set;} 
        public String accountAccessUI {get;set;} 
        public String teamRole {get;set;} 
        public String rowCause {get;set;} 
        public DateTime createdDate {get;set;}
        public String createdByUser {get;set;}
        public boolean isActive {get;set;}
    }
    public class Paginate {
        public Integer index {get;set;}
        public Integer pageNum {get;set;}
        public Integer totalPage {get;set;}
        public Integer totalResults {get;set;}
        public String previousQueryString {get;set;}
        public String nextQueryString {get;set;}
        public Boolean isAll {get;set;}
          
        public Paginate(Integer listSize, Integer pageSize){
            this.totalResults = listSize;
            this.totalPage = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
            if (ApexPages.CurrentPage().getParameters().get('page') != null 
                && ApexPages.CurrentPage().getParameters().get('page').isNumeric() 
                && Integer.valueof(ApexPages.CurrentPage().getParameters().get('page')) != null )
            {
                Integer queryPage = Integer.valueof(ApexPages.CurrentPage().getParameters().get('page'));
                if(queryPage > this.totalPage)
                    this.pageNum = this.totalPage;
                else if(queryPage < 1)
                    this.pageNum = 1;
                else 
                    this.pageNum = queryPage;
            }
            else 
                this.pageNum = 1;
            this.isAll = (listSize == pageSize)?true:false;
            this.index = this.pageNum - 1;
        }
        
        public void updateQueryStrings(Integer pageNum, String searchString){
            if(String.isBlank(searchString)) {
                this.previousQueryString = '?page=' + String.valueOf(this.pageNum - 1);
                this.nextQueryString = '?page=' + String.valueOf(this.pageNum + 1);
            }
            else {
                this.previousQueryString = '?page=' + String.valueOf(this.pageNum - 1) + '&search=' + searchString;
                this.nextQueryString = '?page=' + String.valueOf(this.pageNum + 1) + '&search=' + searchString;
            }
        }
    }  
   
    public Paginate paginater {get;set;}  
    public List<Account> accounts {get;set;} 
    public List<Account> displayList{get;set;}
    public List<List<Account>> fullList{get;set;}
    public List<TeamMemberWithAccess> teamMembers {get;set;} 
    public String searchFilter {get;set;}
    public Integer accountMaximum {get;set;}
    public Integer pageSize {get;set;}
    
    public void save(){
        //update accounts;
        List<Account> accList = new List<Account>();
        for(Account acc : accounts){
            if(acc.Core_Account_Team_Audit_Complete__c == true){
                accList.add(acc);
            }
        }
        update accList;
    }

    public void loadSettings() {
        Map<String,Core_Account_Team_Audit_Settings__c> settings = Core_Account_Team_Audit_Settings__c.getAll();
        if (settings.containsKey('PageMaxAccountsLoaded'))
            this.accountMaximum = Integer.valueOf(settings.get('PageMaxAccountsLoaded').Core_Value__c);
        else
            this.accountMaximum = 1000;

        if (settings.containsKey('PageSize'))
            this.pageSize = Integer.valueOf(settings.get('PageSize').Core_Value__c);
        else
            this.pageSize = 20;
    }
    
    //Core_AccountTeamAudit page
    public void onLoad(){
        if (!String.isBlank(ApexPages.CurrentPage().getParameters().get('search'))){
            searchFilter = ApexPages.CurrentPage().getParameters().get('search');
        } 

        loadSettings();

        if (String.isBlank(searchFilter)) {
          accounts = [SELECT Id,(SELECT Id, TeamMemberRole, User.Name, User.Id, CreatedById, CreatedDate, User.isActive FROM Account.AccountTeamMembers), 
                      Name, Core_Account_Team_Audit_Complete__c, Core_Account_Team_Anchor_URL__c, Core_CIM_ID__c, Owner.Name, CreatedById
                      FROM Account 
                      WHERE Core_Account_Team_Audit_Complete__c = false
                      AND OwnerID = :UserInfo.getUserId() 
                      ORDER BY Name
                      LIMIT : Integer.valueof(accountMaximum)
                    ];
        }
        else {
           //Edited by Kavyashree HR(Infosys Pegasus Team) on 30/04/2020 to fix security scan issues(US667277)
          String searchFilterFormatted =  '%'+ String.escapeSingleQuotes(searchFilter)+'%';
          accounts = [SELECT Id,(SELECT Id, TeamMemberRole, User.Name, User.Id, CreatedById, CreatedDate, User.isActive FROM Account.AccountTeamMembers), 
                      Name, Core_Account_Team_Audit_Complete__c, Core_Account_Team_Anchor_URL__c, Core_CIM_ID__c, Owner.Name, CreatedById
                      FROM Account 
                      WHERE Core_Account_Team_Audit_Complete__c = false
                      AND OwnerID = :UserInfo.getUserId() 
                      AND (
                        Name LIKE :searchFilterFormatted
                      )                    
                      ORDER BY Name
                      LIMIT : Integer.valueof(accountMaximum)
                    ];
        }      
        completePageLoad();      
    }

    //Core_AccountTeamAudit_DataOps page
    public void onLoadForDataOps() {
        if (!String.isBlank(ApexPages.CurrentPage().getParameters().get('search'))){
            searchFilter = ApexPages.CurrentPage().getParameters().get('search');
        } 

        loadSettings();

        if (String.isBlank(searchFilter)) {
          accounts = [SELECT Id,(SELECT Id, TeamMemberRole, User.Name, User.Id, CreatedById, CreatedDate, User.isActive FROM Account.AccountTeamMembers), 
                    Name, Core_Account_Team_Audit_Complete__c, Core_Account_Team_Anchor_URL__c, Core_CIM_ID__c, Owner.Name, CreatedById
                    FROM Account 
                    WHERE Core_Account_Team_Audit_Complete__c = false
                    ORDER BY Owner.LastName, Owner.FirstName, Name
                    LIMIT : Integer.valueof(accountMaximum)
                    ];
        }
        else {
          //Edited by Kavyashree HR(Infosys Pegasus Team) on 30/04/2020 to fix security scan issues(US667277)
          String searchFilterFormatted =  '%'+ String.escapeSingleQuotes(searchFilter)+'%';
          accounts = [SELECT Id,(SELECT Id, TeamMemberRole, User.Name, User.Id, CreatedById, CreatedDate, User.isActive FROM Account.AccountTeamMembers), 
                    Name, Core_Account_Team_Audit_Complete__c, Core_Account_Team_Anchor_URL__c, Core_CIM_ID__c, Owner.Name, CreatedById
                    FROM Account 
                    WHERE Core_Account_Team_Audit_Complete__c = false
                    AND (
                      Name LIKE :searchFilterFormatted
                      OR Owner.Name LIKE :searchFilterFormatted
                      OR Owner.Core_WWID__c = :searchFilterFormatted
                    )                    
                    ORDER BY Owner.LastName, Owner.FirstName, Name
                    LIMIT :Integer.valueof(accountMaximum)
                    ];
        }
        
        completePageLoad();      
    }

    public void completePageLoad() {
        //Create a new instance of Paginate passing in the overall size of 
        //the list of data and the page size you want
        this.paginater = new Paginate(accounts.size(), this.pageSize);

        this.paginater.updateQueryStrings(this.paginater.pageNum, searchFilter);

        if(this.paginater.totalResults==this.accountMaximum)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Only the first ' + String.valueOf(this.accountMaximum) + ' Accounts requiring review are included in the pages below.  To see any remaining Accounts, please use the search box to filter.'));

        if(this.paginater.totalResults <=0)
            if (!String.isBlank(searchFilter))
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'There are currently no Account Team reviews to complete, or your search returned no results.'));
            else
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'There are currently no Account Team reviews to complete.'));


        //These lists hold the data
        this.fullList = new List<List<Account>>();
        this.displayList = new List<Account>();
      
        //Break out the full list into a list of lists
        if(accounts.size() > 0){
            List<Account> tempList = new List<Account>();         
            Integer i = 0;
            for(Account cc : accounts){
                tempList.add(cc);
                i++;
                if(i == this.pageSize){
                    this.fullList.add(tempList);
                    tempList = new List<Account>();
                    i = 0;
                }
            }
            if(!tempList.isEmpty()){
                this.fullList.add(tempList);
            }
              
            //Gets the correct list of data to show on the page
            loadPageData();
        }
    }

    private void loadPageData() {
        this.displayList = this.fullList.get(this.paginater.index);
        Set<Id> accountIDs = new Set<Id>();
        
        teamMembers = new List<TeamMemberWithAccess>();
        Set<Id> atmIdSet = new Set<Id>();
        for(Account acc:displayList) {
            for(AccountTeamMember atm:acc.AccountTeamMembers) {             
                atmIdSet.add(atm.CreatedById);
            }           
        }
        Map<Id, User> createdUserMap = new Map<Id, User>([SELECT id, Name FROM User WHERE id IN :atmIdSet]);
        TeamMemberWithAccess newTeamMember;
        for(Account acc:displayList) {
            for(AccountTeamMember atm:acc.AccountTeamMembers) {
                newTeamMember = new TeamMemberWithAccess();
                newTeamMember.teamRole = atm.TeamMemberRole;
                newTeamMember.userName = atm.User.Name;
                newTeamMember.userID = atm.User.Id;
                newTeamMember.accountID = acc.Id;    
                newTeamMember.atmID = atm.Id;    
                newTeamMember.createdDate = atm.CreatedDate;
                if(!createdUserMap.isEmpty()){
                    newTeamMember.createdByUser = createdUserMap.get(atm.CreatedById).Name;
                }
                newTeamMember.isActive = atm.User.isActive;
                
                teamMembers.add(newTeamMember);
            }
            accountIDs.add(acc.Id);          
        }

        List<AccountShare> accountShares = [Select ID,AccountID,UserOrGroupId,AccountAccessLevel,CaseAccessLevel,OpportunityAccessLevel,RowCause 
                                            From AccountShare Where AccountID In :displayList AND RowCause = 'Team'];

        for(TeamMemberWithAccess tm:teamMembers) {
            for(AccountShare accsh: accountShares) {
                if(tm.accountID == accsh.AccountID && tm.userID == accsh.UserOrGroupId) {
                    tm.caseAccess = accsh.CaseAccessLevel;
                    tm.accountAccess = accsh.AccountAccessLevel;
                    tm.opportunityAccess = accsh.OpportunityAccessLevel;
                    tm.caseAccessUI = convertAccountShareStringsToUI(accsh.CaseAccessLevel);
                    tm.accountAccessUI = convertAccountShareStringsToUI(accsh.AccountAccessLevel);
                    tm.opportunityAccessUI = convertAccountShareStringsToUI(accsh.OpportunityAccessLevel);
                    tm.rowCause = accsh.RowCause; 
                }
            }           
        }

        //Owner Access supercedes Team Access
        List<AccountShare> accountSharesOwner = [Select ID,AccountID,UserOrGroupId,AccountAccessLevel,CaseAccessLevel,OpportunityAccessLevel,RowCause 
                                            From AccountShare Where AccountID In :displayList AND RowCause = 'Owner'];

        for(TeamMemberWithAccess tm:teamMembers) {
            for(AccountShare accsh: accountSharesOwner) {
                if(tm.accountID == accsh.AccountID && tm.userID == accsh.UserOrGroupId) {
                    tm.caseAccess = accsh.CaseAccessLevel;
                    tm.accountAccess = accsh.AccountAccessLevel;
                    tm.opportunityAccess = accsh.OpportunityAccessLevel;
                    tm.caseAccessUI = convertAccountShareStringsToUI(accsh.CaseAccessLevel);
                    tm.accountAccessUI = convertAccountShareStringsToUI(accsh.AccountAccessLevel);
                    tm.opportunityAccessUI = convertAccountShareStringsToUI(accsh.OpportunityAccessLevel);
                    tm.rowCause = accsh.RowCause; 
                }
            }           

            //If access values haven't been set yet, there is no corresponding AccountShare entry for the team member
            // and the UI should show 'Private'
            if (String.isBlank(tm.caseAccess) && String.isBlank(tm.accountAccess) && String.isBlank(tm.opportunityAccess)) {
                tm.caseAccessUI = 'Private';
                tm.accountAccessUI = 'Private';
                tm.opportunityAccessUI = 'Private';
            }         
        }
    }

    public String convertAccountShareStringsToUI(String asString) {
        if (asString == 'None' || String.isBlank(asString))
            return 'Private';
        else if (asString == 'All')
            return 'Full Access';
        else if ( asString == 'Edit')
            return 'Read/Write';
        else if (asString == 'Read')
            return 'Read Only';      
        else 
          return '?'; 
    }

}