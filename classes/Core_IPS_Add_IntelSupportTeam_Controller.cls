/**************************************************************************************************
Apex Class Name:  Core_IPS_Add_IntelSupportTeam_Controller
Version     : 1.0
Created Date: 19 04 2018
Function    : Controller Class for Core_IPS_Add_IntelSupportTeam Page. This class defines all the methods
which are used for Searching, Adding Intel Support team on a Project.
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi Singhal                       18/04/2018            Created for US102838
* Sumukh                                06/12/2018            added logic for US216779
*****************************************************************************************************/
public with sharing class Core_IPS_Add_IntelSupportTeam_Controller { // Niyaz -- 12/06/2025 --- added as part of vulnerability fix, changed to with sharing
    private static final String DEFAULT_SORT_FIELD = 'FirstName';
    public string searchText{get;set;}
    public String errorMsg{get;set;}
    public Boolean showErrorMsg{get;set;}
    public Boolean accessErrorMsg{get;set;}
    public Boolean searchMadeInt{get;set;}
    Set<String> AgentProfileId = new Set<String>();
    Set<Id> FaeId=new Set<Id>();
    public list<User> UserList = new List<User>();
    public Id projectId = ApexPages.currentPage().getParameters().get('projectId');
    public List<ISTWrapper> ISTRecordSet{get;set;} 
    public List<Core_IPS_Intel_Support_Team__c> existingMembers{get;set;}
    Set<Id> existingUser=new Set<Id>();
    
    public Core_SortedGrid_ColumnHeader sortHeader 
    {
        get 
        {
            if (sortHeader == NULL){
                sortHeader = new Core_SortedGrid_ColumnHeader(DEFAULT_SORT_FIELD);
            }    
            
            return sortHeader;                
        }        
        set
        {
            sortHeader = value;       
        }
    }  
    
    public Core_IPS_Add_IntelSupportTeam_Controller(){
        searchMadeInt = false;
        showErrorMsg = false;
        accessErrorMsg=false;
        ISTRecordSet=new List<ISTWrapper>();
        checkAccess();
        //existingMembers=new List<Core_IPS_Intel_Support_Team__c>();
        //FLS Check Added - Madhuri
        if(Core_IPS_Intel_Support_Team__c.SObjectType.getDescribe().isAccessible()){
            existingMembers= [Select Id,Core_IPS_User__c,Core_IPS_User__r.FirstName,Core_IPS_User__r.LastName,Core_IPS_User__r.Email,Core_IPS_Profile__c,Core_IPS_Project__c from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c= :projectId];
        }
    }
    
    public void doSearch(){
        List<Core_IPS_Account__c>  projAccList;
        String searchableString = '';
        Set<Id> accountId = new Set<Id>(); 
        
        try{
            if(projectId!=null){
                String activeStatus=Core_IPS_Helper_Utility.getIPSLabel('CoreStatus_Active');
                //FLS Check Added - Madhuri
                if(Core_IPS_Account__c.SObjectType.getDescribe().isAccessible()){
                    projAccList=[select Id,Core_Account__c,Core_IPS_Project__c from Core_IPS_Account__c where Core_IPS_Project__c=:projectId AND Core_Status__c=:activeStatus];     
                }
                if(projAccList!=null && projAccList.size()>0){
                    for(Core_IPS_Account__c projAcc: projAccList){
                        accountId.add(projAcc.Core_Account__c);  
                    }
                    if(accountId!=null && accountId.size()>0){
                        for(Set<Id> setId: Core_IPS_Helper_Utility.getFAEsByAccount(accountId).values()){
                            faeId.addAll(SetId); 
                        }   
                        
                    }
                }
                if(String.IsBlank(searchText))
                {
                    showErrorMsg = true;
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,System.Label.Core_IPS_SearchText));
                    if(ISTRecordSet!=null && ISTRecordSet.size() > 0){ ISTRecordSet.clear(); }
                } 
                else{
                    AgentProfileId.addall(new List<String>(label.Core_IPS_Agent_Profile_Ids.split(',')));
                    
                     // Added by sumukh for US216779
                    List<Id> orgAdminPermUser = new List<Id>();                   
                    for(PermissionSetAssignment permSetUser: [SELECT id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.name ='Core_IPS_SupportOrgAdmin' ]){                  
                      orgAdminPermUser.add(permSetUser.AssigneeId);
                    }
                
                   // End by sumukh for US216779
                    
                    if(existingMembers!=null && existingMembers.size()>0){
                        for(Core_IPS_Intel_Support_Team__c existingmem: existingMembers) {
                            existingUser.add(existingmem.Core_IPS_User__c)   ;
                        }
                        
                    }
                    
                    searchableString = searchText + '%';
                    String sQuery;                                                                                                 // Added changes by sumukh for US216779
                    if((AgentProfileId!=null && AgentProfileId.size()>0) || (FaeId!=null && FaeId.size()>0) || orgAdminPermUser .size()>0){
                        sQuery = 'SELECT Id,Profile.Name, Name, FirstName, LastName, Email FROM User ' + 
                            'WHERE (ProfileId In :AgentProfileId  AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :existingUser)) AND (IsActive = true)) OR (ID in :FaeId AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN : existingUser))  AND (IsActive = true))  OR (ID IN :orgAdminPermUser AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN : existingUser))  AND (IsActive = true))' +
                            'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast +' Limit '+System.Label.Core_IPS_Interested_Party_Limit;
                        
                       
                        UserList = Database.query(sQuery);
                        if(UserList!=null && UserList.size()>0){
                            if(ISTRecordSet!=null && ISTRecordSet.size() > 0){
                                ISTRecordSet.clear();
                            }
                            for(User userRec: UserList)
                            {
                                ISTRecordSet.add(new ISTWrapper(UserRec));
                                searchMadeInt = true;
                            }
                            if(isMoreThanThousand(searchableString)){
                                
                                showErrorMsg = true;
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,System.Label.Core_IPS_Interested_Party_Warning_Msg));
                            }
                        }
                        else{
                            if(ISTRecordSet.size() > 0){
                                ISTRecordSet.clear();
                            }
                            showErrorMsg = true;
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,System.Label.Core_IPS_No_User));
                        }
                    }
                }
            }  
        }catch(Exception ex){
        }  
    }
    
    public void addSelectedContacts(){
        try{
            List<Core_IPS_Intel_Support_Team__c> istList=new List<Core_IPS_Intel_Support_Team__c>();
            if(ISTRecordSet!=null && ISTRecordSet.size()>0){
                for(ISTWrapper wrapper: ISTRecordSet){
                    if(wrapper.isSelected){
                        Core_IPS_Intel_Support_Team__c ist=new Core_IPS_Intel_Support_Team__c();
                        ist.Core_IPS_Project__c=projectId;
                        ist.Core_IPS_User__c=wrapper.Usr.id;
                        if (Schema.sObjectType.Core_IPS_Intel_Support_Team__c.fields.Status__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/
                            ist.Status__c='Active';
                        }
                        istList.add(ist);
                    }
                }
                if(istList!=null && istList.size()>0){
                    insert istList;
                    //FLS Check Added - Madhuri
                    if(Core_IPS_Intel_Support_Team__c.SObjectType.getDescribe().isAccessible()){
                        existingMembers= [Select Id,Core_IPS_User__c,Core_IPS_User__r.FirstName,Core_IPS_User__r.LastName,Core_IPS_User__r.Email,Core_IPS_Profile__c,Core_IPS_Project__c from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c= :projectId];
                    }
                    doSearch();
                }
            }
        } 
        catch (Exception ex){
            showErrorMsg = true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Core_IPS_Intel_Support_Team_Exception_Msg));
            if(ISTRecordSet.size() > 0){
                for(ISTWrapper wrapper:ISTRecordSet)
                {
                    wrapper.isSelected = false;
                }
            }
        }
    }
    
    public PageReference finished(){
        return (new PageReference ('/' + projectId));
    }
    
    public class ISTWrapper {
        
        public boolean isSelected{get;set;}
        public User usr{get;set;}
        
        public ISTWrapper(User U)
        {
            Usr = U;
            isSelected = false;
        }
    }
    
    //Check the search resutls are more than 1000 or not
    public boolean isMoreThanThousand(String searchableString){
        
        String sQueryCount = 'Select Count() FROM User '+ 
            'WHERE (ProfileID IN :AgentProfileId AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :existingUser)) AND (IsActive = true)) OR (ID in :FaeId AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN : existingUser)) AND (IsActive = true)) ';
        Integer recordCount = Database.countQuery(sQueryCount);
        
        return (recordCount > Integer.valueof(System.Label.Core_IPS_Interested_Party_Limit));
        
    }
    
    public void checkAccess(){
        Boolean hasProjectEditAccess = false;
        UserRecordAccess objURA = [SELECT RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId=:userInfo.getUserId() AND RecordId=:projectId];
        if(objURA!=null) {
            hasProjectEditAccess = objURA.HasEditAccess;
        }
        
        if(!hasProjectEditAccess){
                errorMsg=System.Label.Core_IPS_Access_Error;
            accessErrorMsg=true;
        }
        else{
            accessErrorMsg=false;
        }
    }
    
}