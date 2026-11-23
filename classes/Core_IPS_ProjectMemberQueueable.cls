/***************************************************************************************************
    Version     : 1.0 
    Created Date: 08 Nov 2017
    Class Name : Core_IPS_ProjectMemberQueueable
    Description: This class is used to perform various operation related to Project Members in async mode. This class
         is called from Trigger Handler classes.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    11/08/2017              Created
****************************************************************************************************/  
public class Core_IPS_ProjectMemberQueueable implements Queueable {
    List<Id> usersList;
    List<Id> accList;
    
    Set<Id> ProjectIds;
    List<Id> ContactIds;
    
    String oldListStr;
    String newListStr;
    
    List<Core_IPS_Project_Member__c> projMember_NewList;
    List<Core_IPS_Project_Member__c> projMember_OldList;
    Map<Id,Core_IPS_Project__c> mapProject;
        
    String mode;
    
    public Core_IPS_ProjectMemberQueueable(List<Id> usersList, List<Id> accList) {
        this.usersList = usersList;
        this.accList = accList;
        mode = 'insertprojectmember';
    }
    
    public Core_IPS_ProjectMemberQueueable(Set<Id> ProjectIds, List<Id> UserIds, List<Id> ContactIds) {
        this.ProjectIds = ProjectIds;
        this.usersList = UserIds;
        this.ContactIds = ContactIds;
        mode = 'updateprojectmember';
    }
    
    public Core_IPS_ProjectMemberQueueable(List<Core_IPS_Project_Member__c> oldList, List<Core_IPS_Project_Member__c> newList) {
        this.projMember_OldList = oldList;
        this.projMember_NewList = newList;     
        mode = 'addorremoveprojectmember';
    }
    
    public Core_IPS_ProjectMemberQueueable(List<Core_IPS_Project_Member__c> projMember_NewList, Map<Id,Core_IPS_Project__c> mapProject) {
        this.projMember_NewList = projMember_NewList;
        this.mapProject = mapProject;
        mode = 'addprojectmember';
    }
    
    public Core_IPS_ProjectMemberQueueable(List<Core_IPS_Project_Member__c> projMember_OldList, String mode) {
        this.projMember_OldList = projMember_OldList;
        this.mode = mode;
    }
    
    public void execute(QueueableContext qc) {
        //Core_IPS_UserTriggerHandler.InsertProjMemberAsync(usersList, accList);
        if(String.isNotBlank(mode)) {
            if(mode.toLowerCase()=='insertprojectmember') {
                InsertProjMember(usersList, accList);
            }
            else if(mode.toLowerCase()=='updateprojectmember') {
                UpdateProjMember(ProjectIds, usersList, ContactIds);
            }
            else if(mode.toLowerCase()=='addprojectmember') {
                AddProjectMembertoGroup(projMember_NewList, mapProject);
            }
            else if(mode.toLowerCase()=='addorremoveprojectmember') {
                AddorRemoveProjMembertoGroup(projMember_OldList, projMember_NewList);
            }
            else if(mode.toLowerCase()=='removeprojectmemfromgroup') {
                removeProjectMemberfromGroupAfterDelete(projMember_OldList);
            }
        }
    }
    
    
 /***************************************************************************************************
    Version     : 1.0 
    Created Date: 08 Nov 2017
    Function    : 
    Input Parameters: List of user Id's, List of Account Id's
    Output Parameters: None
    Description: This method is used to Add IPS Enabled contacts to Project members object 
                 All the accounts added with All Core_member type are added to project member object
    Used in     : Core_IPS_UserTriggerHandler
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    11/08/2017              Created
****************************************************************************************************/  
    public static void InsertProjMember(List<Id> usersList, List<Id> accList){
        if(usersList <> null && usersList.size()>0 && accList <> null && accList.size()>0){
            List<Core_IPS_Project_Member__c> ProjMemberList = new List<Core_IPS_Project_Member__c>();
            List<String> userTypeList = new List<String>();
            if(String.isNotBlank(Label.Core_IPS_CustCommPlus_UserType)) {
                userTypeList.add(Label.Core_IPS_CustCommPlus_UserType);
            }
            /*if(String.isNotBlank(Label.Core_IPS_Partner_Community_User_Type)) {
                userTypeList.add(Label.Core_IPS_Partner_Community_User_Type);
            }*/
            List<User> ipsUsers = [select id, name, Contact.Id, Contact.AccountId from user where id IN: usersList and usertype IN :userTypeList /*and userroleid!=null*/ and Contact.Core_IPS_Active__c = true AND isActive=true];
            List<Core_IPS_Account__c> ProjAccounts = [Select id, Core_Account__c, Core_IPS_Project__c, Core_Status__c from Core_IPS_Account__c where Core_Account__c IN: accList and Core_Members__c ='All'];
            if(ipsUsers <> null && ipsUsers.size()>0){
                for(User u: ipsUsers) {
                    for(Core_IPS_Account__c projAccount: ProjAccounts){
                        if(u.Contact.AccountId == projAccount.Core_Account__c){
                            Core_IPS_Project_Member__c ProjMembers = new Core_IPS_Project_Member__c();
                            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isCreateable()) {
                            ProjMembers.Core_User__c= u.id;
                            }
                            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isCreateable()) {
                            ProjMembers.Core_Selective_Member__c= false;
                            }
                            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isCreateable()) {
                            ProjMembers.Core_IPS_Contact__c = u.Contactid;
                            }
                            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isCreateable()) {
                            ProjMembers.Core_Status__c= 'Active';
                            }
                            //ProjMembers.Core_IPS_Provisioning_Date__c = System.Now();                            
                            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isCreateable()) {
                            ProjMembers.Core_IPS_Project__c = projAccount.Core_IPS_Project__c;
                            }
                            ProjMemberList.add(ProjMembers);
                        }
                    }
                }
                if(ProjMemberList <> null && ProjMemberList.size()>0){
                    try{
                        insert ProjMemberList;
                    } catch(exception e){ 
                        string  Str = new Core_Exceptionclass().InsertException('','Core_IPS_ProjectMemberQueueable','User','','InsertProjMember',e); 
                        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + Str); 
                    }
                }
            }
        }
    }
   
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 08 Nov 2017
    Function    : 
    Input Parameters: List of user Id's, List of Contact Id's
    Output Parameters: None
    Description: This method is used to update IPS Enabled contacts to Project members object 
                 All the project members added with Account as All Core_member type are activated
    Used in     : Core_IPS_UserTriggerHandler
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    11/08/2017              Created
****************************************************************************************************/
    public static void UpdateProjMember(Set<Id> ProjectIds, List<Id> UserIds, List<Id> ContactIds){
        List<Core_IPS_Project_Member__c> ProjMemberList = new List<Core_IPS_Project_Member__c>();
        List<Core_IPS_Project_Member__c> ProjectMembers = new List<Core_IPS_Project_Member__c>();
        if(ProjectIds <> null && ProjectIds.size()>0)
        ProjectMembers = [Select id from Core_IPS_Project_Member__c where Core_Status__c = 'Inactive' and Core_User__c IN: UserIds and Core_IPS_Contact__c IN: ContactIds AND Core_IPS_Project__c IN: ProjectIds];
            if(ProjectMembers <> null && ProjectMembers.size()>0){
                for(Core_IPS_Project_Member__c ProjMember: ProjectMembers){
                    if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isUpdateable()) { /*--US1038641--06/24/2021--Haritha--FLS Check for security vulnerability--*/
                        ProjMember.Core_Status__c = 'Active';
                    }
                    //ProjMember.Core_IPS_Provisioning_Date__c = System.Now();
                    ProjMemberList.add(ProjMember);
                }
                if(ProjMemberList <> null && ProjMemberList.size()>0) {                    
                    try{
                        update ProjMemberList;
                    } catch(exception e){ 
                        string  Str = new Core_Exceptionclass().InsertException('','Core_IPS_ProjectMemberQueueable','User','','UpdateProjMember',e); 
                        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + Str); 
                    }
                }
            }
    }
        
 /***************************************************************************************************
    Version     : 1.0 
    Created Date: 08 Nov 2017
    Function    : 
    Input Parameters: List of Project Member, Map of Project
    Output Parameters: None
    Description: This method is used to Add Project Members as Group Members in the project based public group
    Used in     : Core_IPS_Project_Member_Handler
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    11/08/2017              Created
****************************************************************************************************/ 
    public static void AddProjectMembertoGroup(List<Core_IPS_Project_Member__c> newList, Map<Id,Core_IPS_Project__c> projectById){
        
        //List<Core_IPS_Project_Member__c> newList = (List<Core_IPS_Project_Member__c>)JSON.deserialize(serializedList, List<Core_IPS_Project_Member__c>.class);
        List<GroupMember> GMlist = new List<GroupMember>();
        /*Set<Id> ProjectIdSet = new Set<Id>();
        for(Core_IPS_Project_Member__c PrjMember: newList){
            ProjectIdSet.add(PrjMember.Core_IPS_Project__c);
        }
        
        Map<Id,Core_IPS_Project__c> projectById = new Map<Id,Core_IPS_Project__c>([Select id, Core_IPS_GroupId__c from Core_IPS_Project__c where id IN: ProjectIdSet]);
        */
        for(Core_IPS_Project_Member__c PrjMember: newList){
            GroupMember GM = new GroupMember();
            if (Schema.sObjectType.GroupMember.fields.GroupId.isCreateable()) {
            GM.GroupId = projectById.get(PrjMember.Core_IPS_Project__c).Core_IPS_GroupId__c;
            }
            if (Schema.sObjectType.GroupMember.fields.UserorGroupId.isCreateable()) {
            GM.UserorGroupId = PrjMember.Core_User__c;
            }
            GMList.add(GM);
        }
        if(!GMList.isEmpty()){
            try{
                insert GMList;
            } catch(exception e){ 
                string  Str = new Core_Exceptionclass().InsertException('','Core_IPS_ProjectMemberQueueable','Core_IPS_Project_Member__c','','AddProjectMembertoGroup',e); 
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + Str); 
            }            
        }
    }
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 08 Nov 2017
    Function    : 
    Input Parameters: List of Trigger.Old Project Member, List of Trigger.New Project Member
    Output Parameters: None
    Description: This method is used to Add/remove Project Members as Group Members in the project based public group
    Used in     : Core_IPS_Project_Member_Handler
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    11/08/2017              Created
****************************************************************************************************/ 
    public static void AddorRemoveProjMembertoGroup(List<Core_IPS_Project_Member__c> oldList, List<Core_IPS_Project_Member__c> newList){
        //List<Core_IPS_Project_Member__c> oldList= (List<Core_IPS_Project_Member__c>)JSON.deserialize(oldListStr, List<Core_IPS_Project_Member__c>.class);
        //List<Core_IPS_Project_Member__c> newList= (List<Core_IPS_Project_Member__c>)JSON.deserialize(newListStr, List<Core_IPS_Project_Member__c>.class);
        Map<Id,Core_IPS_Project_Member__c> oldMap = new Map<Id,Core_IPS_Project_Member__c>(oldList);
        List<GroupMember> GMlist = new List<GroupMember>();
        Set<Id> ProjectIdSet = new Set<Id>();
        
        
        Map<Id,Id> revokeAccessRecords = new Map<Id,Id>();
        Set<Id> InactiveUserIdSet = new Set<Id>();
        Set<Id> InactivegroupIdSet = new Set<Id>();
        for(Core_IPS_Project_Member__c PrjMember: newList){
            ProjectIdSet.add(PrjMember.Core_IPS_Project__c);
        }
        
        Map<Id,Core_IPS_Project__c> projectById = new Map<Id,Core_IPS_Project__c>([Select id, Core_IPS_GroupId__c,Createdby.ProfileId from Core_IPS_Project__c where id IN: ProjectIdSet]);        
        List<Core_IPS_Project_Member__c> prjmem = [select id,Core_User__c,Core_Status__c ,Core_IPS_Project__c, Core_IPS_Project__r.Core_Status__c,Core_IPS_Project__r.Core_IPS_GroupId__c from Core_IPS_Project_Member__c where id IN: newList ];
        
        
        for(Core_IPS_Project_Member__c PrjMember: prjmem){
            
            //logic for removing the group member
            if(PrjMember.Core_Status__c == 'Inactive' && oldMap.get(PrjMember.Id).Core_Status__c == 'Active'){
                InactiveUserIdSet.add(PrjMember.Core_User__c);
                InactivegroupIdSet.add(PrjMember.Core_IPS_Project__r.Core_IPS_GroupId__c);                
            }
            
            
            //adding the group member in list
            if(PrjMember.Core_Status__c == 'Active' /*&& oldMap.get(PrjMember.Id).Core_Status__c == 'Inactive'*/){
                GroupMember GM = new GroupMember();
                if (Schema.sObjectType.GroupMember.fields.GroupId.isCreateable()) { /*--US1038641--06/24/2021--Haritha--FLS Check for security vulnerability--*/
                    GM.GroupId = projectById.get(PrjMember.Core_IPS_Project__c).Core_IPS_GroupId__c;
                }
                if (Schema.sObjectType.GroupMember.fields.UserorGroupId.isCreateable()) { /*--US1038641--06/24/2021--Haritha--FLS Check for security vulnerability--*/
                    GM.UserorGroupId = PrjMember.Core_User__c;
                }
                GMList.add(GM);                
            }
        }
        try{            
            if(InactiveUserIdSet <> null && InactivegroupIdSet <> null){    
                List<GroupMember> deleteGMList = [select Id from GroupMember where UserorGroupId IN: InactiveUserIdSet and GroupId IN: InactivegroupIdSet];        
                /*US1038641 - 06/23/2021 - Yamini - CRUD Delete Check for security vulnerability --*/
                if (GroupMember.sObjectType.getDescribe().isDeletable()) {
                delete deleteGMList;
                }
            }
            
            if(!GMList.isEmpty()){
                insert GMList;
            }
        } catch(exception e){ 
            string  Str = new Core_Exceptionclass().InsertException('','Core_IPS_ProjectMemberQueueable','Core_IPS_Project_Member__c','','AddorRemoveProjMembertoGroup',e); 
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + Str); 
        }  
    }
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 08 Nov 2017
    Function    : 
    Input Parameters: List of Trigger.Old Project Member
    Output Parameters: None
    Description: This method is used to Remove Project Members as Group Members in the project based public group when 
         project members are deleted
    Used in     : Core_IPS_Project_Member_Handler
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    11/08/2017              Created
****************************************************************************************************/
    public static void RemoveProjectMemberfromGroupAfterDelete(List<Core_IPS_Project_Member__c> oldList){        
        Set<Id> ProjectIdSet = new Set<Id>();
        
        for(Core_IPS_Project_Member__c projMem : oldList){
            ProjectIdSet.add(projMem.Core_IPS_Project__c);
        }
        
        Set<Id> InactiveUserIdSet = new Set<Id>();
        Set<Id> InactivegroupIdSet = new Set<Id>();
        
        Map<Id,Core_IPS_Project__c> mapProject = new Map<Id,Core_IPS_Project__c>([Select Id, Core_IPS_GroupId__c,Createdby.ProfileId from Core_IPS_Project__c where Id IN: ProjectIdSet]);        
        //List<Core_IPS_Project_Member__c> prjmem = [select id,Core_User__c,Core_Status__c ,Core_IPS_Project__c, Core_IPS_Project__r.Core_Status__c,Core_IPS_Project__r.Core_IPS_GroupId__c from Core_IPS_Project_Member__c where id IN: oldList ];
        
        for(Core_IPS_Project_Member__c PrjMember : oldList){            
            InactiveUserIdSet.add(PrjMember.Core_User__c);
            InactivegroupIdSet.add(mapProject.get(PrjMember.Core_IPS_Project__c).Core_IPS_GroupId__c);   
        }
        if(InactiveUserIdSet <> null && InactivegroupIdSet <> null){    
            try{
                List<GroupMember> deleteGMList = [select Id from GroupMember where UserorGroupId IN: InactiveUserIdSet AND GroupId IN: InactivegroupIdSet];        
                /*US1038641 - 06/23/2021 - Yamini - CRUD Delete Check for security vulnerability --*/
                if (GroupMember.sObjectType.getDescribe().isDeletable()) {
                delete deleteGMList;
                }
            } catch(exception e){ 
                string  Str =  new Core_Exceptionclass().InsertException('','Core_IPS_ProjectMemberQueueable','Core_IPS_Project_Member__c','','removeProjectMemberfromGroupAfterDelete',e); 
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + Str); 
            }
        }
    }
}