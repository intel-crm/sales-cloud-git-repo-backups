/****************************************************************************************************
Apex Class Name : Core_Goal_addOpptyControllerExt
Version         : 1.0 
Created Date    : 10/27/17
Function        : Controller class for adding and removing Opportunities from Deal Win Goal
Modifications:
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Ashwin Dash                10/27/17                Original Version
*****************************************************************************************************/
public without sharing class Core_Goal_addOpptyControllerExt {
    
    //Defining Variables
    public String soql {get;set;}
    public String soql1{get;set;}
    public Id goalId{get;set;}
    public Core_Goal__c goalObj1{get;set;}
    public sObject goalObj{get;set;}
    public Integer size{get;set;}
    public Integer noOfRecords{get; set;} 
    public List<SelectOption> paginationSizeOptions{get;set;}
    public String selOwnerFilter{get;set;}
    public String selOpptyNameOp{get;set;}
    public String selOpptyOwnerOp{get;set;}
    public String selTechOwnerOp{get;set;}
    public String selAccNameOp{get;set;}
    public String selOpptyName{get;set;}
    public String selOpptyOwner{get;set;}
    public String selTechOwner{get;set;}
    public String selAccName{get;set;}
    public String testing{get;set;}
    public Id loginUserId{get;set;}
    public static final String CORE_EQUALS = 'equals';
    public static final String CORE_CONTAINS = 'contains';
    public Set<Id> opptyIdSet{get;set;}
    public List<String> goalErrorMsgList{get;set;}
    public List<opptyWrapper> queriedOppty{get;set;}
    public Set<Id> selectedOpptSet{get;set;}
    public List<opptyWrapper> selectedOppWrapList{get;set;}
    public List<opptyWrapper> selectedOppWrapList1{get;set;}
    public List<opptyWrapper> removeOppty{get;set;}
    
    // Defining the current sort direction. defaults to asc
    public String sortDir{
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
    }
    
    // the current field to sort by. defaults to last name
    public String sortField{
        get  { if (sortField == null) {sortField = 'Name'; } return sortField;  }
        set;
    }
    //Defining the Criteria
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        SelectOption so1 = new SelectOption('All Opportunities','<span title="All Exisitng Opportunities">All Opportunities</span>');
        so1.setEscapeItem(false);
        options.add(so1); 
        SelectOption so2 = new SelectOption('My Opportunities','<span title="All Opportunities where logged in User is the Owner">My Opportunities</span>');
        so2.setEscapeItem(false);
        options.add(so2); 
        SelectOption so3 = new SelectOption('My Opportunity Teams','<span title="All Opportunities where Logged in User is either Owner or Added to Opportunity Team">My Opportunity Teams</span>');
        so3.setEscapeItem(false);
        options.add(so3); 
        return options; 
    }
    
    //Initializing the standard set controller
    public ApexPages.StandardSetController setCon{
        get {
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
                setCon.setPageSize(size);  
                noOfRecords = setCon.getResultSize();
            }            
            return setCon;
        }
        set;
    }
    
    // init the controller and display some sample data when the page loads
    public Core_Goal_addOpptyControllerExt(){
        goalId = Id.valueOf(Apexpages.currentPage().getParameters().get('id'));
        Schema.SObjectType token = goalId.getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        testing = '';
        queriedOppty = new List<opptyWrapper>();
        selectedOpptSet = new Set<Id>();
        selectedOppWrapList = new List<opptyWrapper>();
        selectedOppWrapList1 = new List<opptyWrapper>();
        removeOppty = new List<opptyWrapper>();
        if(dr.getName() == 'Core_Goal__c'){
            goalObj =[SELECT id, Name, Core_Goal_Opportunity_Identified__c,(SELECT id, Name FROM Opportunities__r) FROM Core_Goal__c WHERE Id = :goalId LIMIT 1];
            goalObj1 = (Core_Goal__c)goalObj;
        }else{
            goalObj = Schema.getGlobalDescribe().get(dr.getName()).newSObject();
        }
        soql = 'select Id, Name, StageName, Core_Approval_Status__c, AccountId, Account.Name, CloseDate, Core_Approved_Date__c, Core_Technical_Owner__c, Owner.Name, Core_Technical_Owner__r.Name FROM Opportunity where AccountId != null and Account.Core_Deactivated__c = false order by Name LIMIT 10000';
        soql1 = soql.left(soql.indexOf('order'));
        size=10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
        loginUserId = UserInfo.getUserId();
        selOwnerFilter = 'All Opportunities';
        goalErrorMsgList = new List<String>();
        goalErrorMsgList = (String.valueOf(Label.Core_Goal_ErrorMessages)).split(';');
        List<Opportunity> oppList = setCon.getRecords();
        for(Opportunity opp : oppList){
            opptyWrapper opw = new opptyWrapper(opp);
            queriedOppty.add(opw);
        }
        //runQuery();
    }
    
    //adding equals or contains operators in the additional filter criteria
    public List<SelectOption> getOperators() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(CORE_EQUALS, CORE_EQUALS));
        options.add(new SelectOption(CORE_CONTAINS, CORE_CONTAINS));
        return options;
    }

    // toggles the sorting of query from asc<-->desc
    public void toggleSort(){
        // simply toggle the direction
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        soql = soql.left(soql.indexOf('order'));
        soql = soql + 'order by ' + sortField + ' ' + sortDir;
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
        setCon.setPageSize(size);  
        noOfRecords = setCon.getResultSize();
        List<Opportunity> oppList = setCon.getRecords();
        queriedOppty = new List<opptyWrapper>();
        for(Opportunity opp : oppList){
            opptyWrapper opw = new opptyWrapper(opp);
            if(selectedOpptSet.contains(opp.Id)){
                opw.selected = true;
            }
            queriedOppty.add(opw);
        }
    }
    
    public void changeQuery(){
        opptyIdSet = new Set<Id>();
        if(selOwnerFilter == 'All Opportunities'){
            soql = 'select Id, Name, StageName, Core_Approval_Status__c, AccountId, Account.Name, CloseDate, Core_Approved_Date__c, Core_Technical_Owner__c, Owner.Name, Core_Technical_Owner__r.Name FROM Opportunity where AccountId != null and Account.Core_Deactivated__c = false order by '+sortField+' LIMIT 10000';
        }else if(selOwnerFilter == 'My Opportunities'){
            soql = 'select Id, Name, StageName, Core_Approval_Status__c, AccountId, Account.Name, CloseDate, Core_Approved_Date__c, Core_Technical_Owner__c, Owner.Name, Core_Technical_Owner__r.Name FROM Opportunity where AccountId != null and Account.Core_Deactivated__c = false and OwnerId=:loginUserId order by '+sortField+' LIMIT 10000';
        }else if(selOwnerFilter == 'My Opportunity Teams'){
            for(OpportunityTeamMember otm : [SELECT id, OpportunityId, UserId FROM OpportunityTeamMember WHERE UserId = :loginUserId]){
                opptyIdSet.add(otm.OpportunityId);
            }
            soql = 'select Id, Name, StageName, Core_Approval_Status__c, AccountId, Account.Name, CloseDate, Core_Approved_Date__c, Core_Technical_Owner__c, Owner.Name, Core_Technical_Owner__r.Name FROM Opportunity where AccountId != null and Account.Core_Deactivated__c = false AND (id IN :opptyIdSet OR OwnerId=:loginUserId) order by '+sortField+' LIMIT 10000';
        }
        //soql1 = soql;
        soql1 = soql.left(soql.indexOf('order'));
        //soql1 = soql1.removeEndIgnoreCase('order by Name');
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
        setCon.setPageSize(size);  
        noOfRecords = setCon.getResultSize();
        List<Opportunity> oppList = setCon.getRecords();
        queriedOppty = new List<opptyWrapper>();
        for(Opportunity opp : oppList){
            opptyWrapper opw = new opptyWrapper(opp);
            if(selectedOpptSet.contains(opp.Id)){
                opw.selected = true;
            }
            queriedOppty.add(opw);
        }
    }
    
    //Changes the size of pagination
    public PageReference refreshPageSize() {
        setCon.setPageSize(size);
        List<Opportunity> oppList = setCon.getRecords();
        queriedOppty = new List<opptyWrapper>();
        for(Opportunity opp : oppList){
            opptyWrapper opw = new opptyWrapper(opp);
            if(selectedOpptSet.contains(opp.Id)){
                opw.selected = true;
            }
            queriedOppty.add(opw);
        }
        return null;
    }
    
    public PageReference searchMethod(){
        soql = soql1;
        soql = soql + ' AND (';
        if(selOpptyName != null && selOpptyName != ''){
            if(selOpptyNameOp == CORE_EQUALS){
                soql = soql + 'Name = :selOpptyName AND ';
            }else if(selOpptyNameOp == CORE_CONTAINS){
                soql = soql + 'Name LIKE \'%'+selOpptyName+'%\' AND ';
            }
        }
        if(selOpptyOwner != null && selOpptyOwner != ''){
            if(selOpptyOwnerOp == CORE_EQUALS){
                soql = soql + 'Owner.Name = :selOpptyOwner AND ';
            }else if(selOpptyOwnerOp == CORE_CONTAINS){
                soql = soql + 'Owner.Name LIKE \'%'+selOpptyOwner+'%\' AND ';
            }
        }
        if(selTechOwner != null && selTechOwner != ''){
            if(selTechOwnerOp == CORE_EQUALS){
                soql = soql + 'Core_Technical_Owner__r.Name = :selTechOwner AND ';
            }else if(selTechOwnerOp == CORE_CONTAINS){
                soql = soql + 'Core_Technical_Owner__r.Name LIKE \'%'+selTechOwner+'%\' AND ';
            }
        }
        if(selAccName != null && selAccName != ''){
            if(selAccNameOp == CORE_EQUALS){
                soql = soql + 'Account.Name = :selAccName AND ';
            }else if(selAccNameOp == CORE_CONTAINS){
                soql = soql + 'Account.Name LIKE \'%'+selAccName+'%\' AND ';
            }
        }
        if(soql.endsWithIgnoreCase('AND ')){
            soql = soql.removeEndIgnoreCase('AND ');
            soql = soql + ')';
        }else if(soql.endsWithIgnoreCase('AND (')){
            soql = soql.removeEndIgnoreCase('AND (');
        }
        soql = soql + ' order by '+sortField+' LIMIT 10000';
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
        setCon.setPageSize(size);  
        noOfRecords = setCon.getResultSize();
        List<Opportunity> oppList = setCon.getRecords();
        queriedOppty = new List<opptyWrapper>();
        for(Opportunity opp : oppList){
            opptyWrapper opw = new opptyWrapper(opp);
            if(selectedOpptSet.contains(opp.Id)){
                opw.selected = true;
            }
            queriedOppty.add(opw);
        }
        if(noOfRecords == 0){
            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO, goalErrorMsgList[4]));
            return null;
        }
        return null;
    }
    
    //The below method is being called when opportunities are selected
    public PageReference getSelected(){
        for(opptyWrapper oppWrapper : queriedOppty){
            if(oppWrapper.selected == true && !selectedOpptSet.contains(oppWrapper.opp.Id)){
                selectedOpptSet.add(oppWrapper.opp.Id);
                opptyWrapper obj = new opptyWrapper(oppWrapper.opp);
                obj.selected = true;
                selectedOppWrapList.add(obj);
            }else if(oppWrapper.selected == false && selectedOpptSet.contains(oppWrapper.opp.Id)){
                selectedOpptSet.remove(oppWrapper.opp.Id);
                for(Integer i = 0; i< selectedOppWrapList.size(); i++){
                    if(selectedOppWrapList[i].opp.Id == oppWrapper.opp.Id){
                        selectedOppWrapList.remove(i);
                    }
                }
            }
        }
        testing=String.valueOf(selectedOppWrapList.size());
        selectedOppWrapList1= new List<opptyWrapper>();
        selectedOppWrapList1.addAll(selectedOppWrapList);
        return null;
    }   
    
    public void clearTable(){
        selectedOppWrapList.clear();
        selectedOpptSet.clear();
        selectedOppWrapList1.clear();
        for(opptyWrapper op1 : queriedOppty){
            if(op1.selected == true)
                op1.selected = false;
        }
    }
    public PageReference cancelAdd(){
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef = new PageReference(globalUrl+'/'+goalId);
        pgRef.setRedirect(true);
        return pgRef;
    }

    public PageReference addOpptytoGoal(){
        List<opptyWrapper> tempWrapList = new List<opptyWrapper>();
        if(!selectedOppWrapList1.isEmpty()){
            for(OpptyWrapper opw : selectedOppWrapList1){
                if(opw.selected){
                    tempWrapList.add(opw);
                }
            }
            try{
                if(Approval.isLocked(goalObj1.Id)){
                    throw new OtherException('Record cannot be added/removed since it is LOCKED, kindly contact administrator');
                }else{
                    List<Opportunity> listOppty = new List<Opportunity>();
                    for(opptyWrapper oppty  : tempWrapList){
                        oppty.opp.Core_Opp_Deal_Win_Goal__c = goalObj1.Id;
                        listOppty.add(oppty.opp);
                    }
                    try{
                        update listOppty;
                        if(!goalObj1.Core_Goal_Opportunity_Identified__c && !tempWrapList.isEmpty()){ //Fixed the defect
                            goalObj1.Core_Goal_Opportunity_Identified__c = true;
                            update goalObj1;
                        }
                    }catch (Exception ex){
                        System.debug('***Error - '+ex.getMessage());
                        throw ex;
                    }                    
                }
            }catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
            }
        }else{
            try{
                if(goalObj1.Core_Goal_Opportunity_Identified__c){
                    goalObj1.Core_Goal_Opportunity_Identified__c = false;
                    update goalObj1;
                }
            }catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
            }
        }
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef = new PageReference(globalUrl+'/'+goalObj1.Id);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public PageReference first() {
        setCon.first();
        refreshPageSize();
        return null;
    }
  
    public PageReference last() {
        setCon.last();
        refreshPageSize();
        return null;
    }
  
    public PageReference previous() {
        setCon.previous();
        refreshPageSize();
        return null;
    }
  
    public PageReference next() {
        setCon.next();
        refreshPageSize();
        return null;
    }
    
    //START - Called from remove Oppty button to be removed///
    public PageReference updateOppty() {
        List<opptyWrapper> tempWrapList = new List<opptyWrapper>();     
        if(!removeOppty.isEmpty()){
            for(OpptyWrapper opw : removeOppty){
                if(opw.selected){
                    tempWrapList.add(opw);
                }
            }
            try{ 
                if(Approval.isLocked(goalObj.Id)){
                    throw new OtherException('Record cannot be added/removed since it is LOCKED, kindly contact administrator');
                }else{
                    List<Opportunity> listOppty = new List<Opportunity>();
                    for(opptyWrapper oppty  : tempWrapList){
                        oppty.opp.Core_Opp_Deal_Win_Goal__c = null;
                        listOppty.add(oppty.opp);
                    }
                    try{
                        update listOppty;
                        Core_Goal__c dwg1 = [SELECT id, Core_Goal_Status__c, Core_Goal_Opportunities_at_Approval__c, Core_Goal_Opportunity_Identified__c, (SELECT id, Name FROM Opportunities__r) FROM Core_Goal__c WHERE Id = :goalId LIMIT 1];
                        if(dwg1.Opportunities__r == null || dwg1.Opportunities__r.isEmpty()){
                            dwg1.Core_Goal_Opportunity_Identified__c = false;
                        }
                        update dwg1;
                    }catch (Exception ex){
                        System.debug('***Error - '+ex.getMessage());
                        throw ex;
                    }                    
                }
            }catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
            }
        }
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef = new PageReference(globalUrl+'/'+goalId);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public void populateOpptyList(){
        for(Opportunity oppty : [SELECT id, Name, StageName, Core_Opp_Deal_Win_Goal__c, Account.Name FROM Opportunity WHERE Core_Opp_Deal_Win_Goal__c = :goalId]){
            removeOppty.add(new OpptyWrapper(oppty));
        }
    }
    ////END - to be removed///////
    
    ////////////////////////////////////////////////////////////////
    //       *Defining inner classes for Parent class*         /////
    ////////////////////////////////////////////////////////////////
    
    //Creating wrapper for Opportunity
    public class opptyWrapper{
        public Opportunity opp{get; set;}
        public Boolean selected {get; set;}
        public opptyWrapper(Opportunity o)
        {
            opp = o;
            selected = false;
        }
    }
    
    public class OtherException extends Exception {}
    
}