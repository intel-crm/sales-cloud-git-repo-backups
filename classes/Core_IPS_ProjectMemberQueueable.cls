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
    * Pavani                      11/10/2024              Modified - Active Project Member Fix - Retry Mechanism - TWC745-6567  
****************************************************************************************************/  
public without sharing class Core_IPS_ProjectMemberQueueable implements Queueable {
    public class CustomException extends Exception {}
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
    //START - Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567
    Integer retrycount =0;
    public static Integer maxRetrycount =3; //END
    
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
    //START - Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567
    public Core_IPS_ProjectMemberQueueable(List<Core_IPS_Project_Member__c> projMemOldList,List<Core_IPS_Project_Member__c> projMemNewList,Map<Id,Core_IPS_Project__c> mapProject,String mode,Integer retryCnt) {
        this.projMember_OldList = projMemOldList;
        this.projMember_NewList = projMemNewList;
        this.mapProject = mapProject;
        this.mode = mode;
        this.retrycount = retryCnt;
    }//END
    
    public void execute(QueueableContext qc) {
        //Core_IPS_UserTriggerHandler.InsertProjMemberAsync(usersList, accList);
        //Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567 - Added Param in the Method
        if(String.isNotBlank(mode)) {
            if(mode.toLowerCase()=='insertprojectmember') {
                InsertProjMember(usersList, accList);
            }
            else if(mode.toLowerCase()=='updateprojectmember') {
                UpdateProjMember(ProjectIds, usersList, ContactIds);
            }
            else if(mode.toLowerCase()=='addprojectmember') {
                AddProjectMembertoGroup(projMember_NewList, mapProject,retrycount);
            }
            else if(mode.toLowerCase()=='addorremoveprojectmember') {
                AddorRemoveProjMembertoGroup(projMember_OldList, projMember_NewList,retrycount);
            }
            else if(mode.toLowerCase()=='removeprojectmemfromgroup') {
                removeProjectMemberfromGroupAfterDelete(projMember_OldList,retrycount);
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
                            ProjMembers.Core_User__c= u.id;
                            ProjMembers.Core_Selective_Member__c= false;
                            ProjMembers.Core_IPS_Contact__c = u.Contactid;
                            ProjMembers.Core_Status__c= 'Active';
                            //ProjMembers.Core_IPS_Provisioning_Date__c = System.Now();                            
                            ProjMembers.Core_IPS_Project__c = projAccount.Core_IPS_Project__c;
                            ProjMemberList.add(ProjMembers);
                        }
                    }
                }
                if(ProjMemberList <> null && ProjMemberList.size()>0){
                    try{
                        insert ProjMemberList;
                    } catch(exception e){ string  Str = new Core_Exceptionclass().InsertException('','Core_IPS_ProjectMemberQueueable','User','','InsertProjMember',e);}
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
                    ProjMember.Core_Status__c = 'Active';
                    //ProjMember.Core_IPS_Provisioning_Date__c = System.Now();
                    ProjMemberList.add(ProjMember);
                }
                if(ProjMemberList <> null && ProjMemberList.size()>0) {                    
                    try{
                        update ProjMemberList;
                    } catch(exception e){ string  Str = new Core_Exceptionclass().InsertException('','Core_IPS_ProjectMemberQueueable','User','','UpdateProjMember',e); }
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
    public static void AddProjectMembertoGroup(List<Core_IPS_Project_Member__c> newList, Map<Id,Core_IPS_Project__c> projectById,Integer retrycount){
        
        //List<Core_IPS_Project_Member__c> newList = (List<Core_IPS_Project_Member__c>)JSON.deserialize(serializedList, List<Core_IPS_Project_Member__c>.class);
        List<GroupMember> GMlist = new List<GroupMember>();
        Set<Id> groupMemSet = new Set<Id>();  //Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567
        
        for(Core_IPS_Project_Member__c PrjMember: newList){
            GroupMember GM = new GroupMember();
            GM.GroupId = projectById.get(PrjMember.Core_IPS_Project__c).Core_IPS_GroupId__c;
            GM.UserorGroupId = PrjMember.Core_User__c;
            GMList.add(GM);
        }
        if(!GMList.isEmpty()){
            /*try{ //Start - Commented by Pavani
                //insert GMList; 
            } catch(exception e){ string  Str = new Core_Exceptionclass().InsertException('','Core_IPS_ProjectMemberQueueable','Core_IPS_Project_Member__c','','AddProjectMembertoGroup',e); }            
            */ //END
            //Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567
            List<Database.SaveResult> results = Database.insert(GMList, false);
            List<String> errorRecs = new List<String>();
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        String errorMessage = 'Error occurred: ' + err.getStatusCode() + ' - ' + err.getMessage()+' - '+err.getFields();
                        errorRecs.add(errorMessage);
                    }  
                }
                else if(result.isSuccess()){
                    groupMemSet.add(result.getId());
                }
            } 
            if(!errorRecs.isEmpty() && errorRecs!=null){
                String fullErrorMessage = String.join(errorRecs, '\n');
                List<String> userFailedList = new List<String>();
                List<String> userSuccessList = new List<String>();
                List<Core_IPS_Project_Member__c> projMemRecNewList = new List<Core_IPS_Project_Member__c>();
                if(!groupMemSet.isEmpty() && groupMemSet!=null){
                    List<GroupMember> groupMemRecs = [SELECT Id,GroupId,UserOrGroupId FROM GroupMember WHERE Id IN: groupMemSet];
                    for (GroupMember gm : groupMemRecs) {
                        userSuccessList.add(gm.GroupId+':'+gm.UserOrGroupId);
                    }
                }
                for(Core_IPS_Project_Member__c PrjMemberRec: newList){
                    String grpUserId = projectById.get(PrjMemberRec.Core_IPS_Project__c).Core_IPS_GroupId__c +':'+PrjMemberRec.Core_User__c;
                    if(!userSuccessList.isEmpty() && userSuccessList!=null && !userSuccessList.contains(grpUserId)){
                        userFailedList.add(grpUserId);
                        projMemRecNewList.add(PrjMemberRec);
                    }
                    else if(userSuccessList.isEmpty() || userSuccessList == null){
                        userFailedList.add(grpUserId);
                        projMemRecNewList.add(PrjMemberRec);
                    }
                }
                if (projMemRecNewList!=null && !projMemRecNewList.isEmpty() && retrycount < maxRetrycount && !Test.isRunningTest()) {
                    retrycount++;
                    System.enqueueJob(new Core_IPS_ProjectMemberQueueable(null,projMemRecNewList,projectById,'addprojectmember',retrycount), Integer.valueOf(System.Label.Core_IPS_ProjectMemberSchedulerTimeLimit));
                } else {
                    fullErrorMessage = fullErrorMessage+ '\nFailed to Add Member in the Group Ids: '+ String.join(userFailedList, ',');
                insertExceptionInFuture('','Core_IPS_ProjectMemberQueueable','Core_IPS_Project_Member__c','','AddProjectMembertoGroup',fullErrorMessage);
            }
        }
        }//END
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
    public static void AddorRemoveProjMembertoGroup(List<Core_IPS_Project_Member__c> oldList, List<Core_IPS_Project_Member__c> newList,Integer retrycount){
        //List<Core_IPS_Project_Member__c> oldList= (List<Core_IPS_Project_Member__c>)JSON.deserialize(oldListStr, List<Core_IPS_Project_Member__c>.class);
        //List<Core_IPS_Project_Member__c> newList= (List<Core_IPS_Project_Member__c>)JSON.deserialize(newListStr, List<Core_IPS_Project_Member__c>.class);
		String operationType;
        Map<Id,Core_IPS_Project_Member__c> oldMap = new Map<Id,Core_IPS_Project_Member__c>(oldList);
        List<GroupMember> GMlist = new List<GroupMember>();
        Set<Id> ProjectIdSet = new Set<Id>();
        //START - Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567
        List<Core_IPS_Project_Member__c> projMemRecNewList = new List<Core_IPS_Project_Member__c>();
        Set<Id> groupMemSet = new Set<Id>(); 
        Boolean isAddMemberFailed = false;
        Boolean isRemoveMemberFailed = false;  //END
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
                projMemRecNewList.add(PrjMember);  //Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567             
            }
            
            
            //adding the group member in list
            if(PrjMember.Core_Status__c == 'Active' /*&& oldMap.get(PrjMember.Id).Core_Status__c == 'Inactive'*/){
                GroupMember GM = new GroupMember();
                GM.GroupId = projectById.get(PrjMember.Core_IPS_Project__c).Core_IPS_GroupId__c;
                GM.UserorGroupId = PrjMember.Core_User__c;
                GMList.add(GM);                
            }
        }
        /*try{            
            if(InactiveUserIdSet <> null && InactivegroupIdSet <> null){    
                List<GroupMember> deleteGMList = [select Id from GroupMember where UserorGroupId IN: InactiveUserIdSet and GroupId IN: InactivegroupIdSet];        
                delete deleteGMList;
            }
            
            if(!GMList.isEmpty()){
                insert GMList;
            }
        } catch(exception e){ string  Str = new Core_Exceptionclass().InsertException('','Core_IPS_ProjectMemberQueueable','Core_IPS_Project_Member__c','','AddorRemoveProjMembertoGroup',e);} */
        //Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567
        List<String> errorRecs = new List<String>();
        if(InactiveUserIdSet <> null && InactivegroupIdSet <> null){    
            List<GroupMember> deleteGMList = [select Id from GroupMember where UserorGroupId IN: InactiveUserIdSet and GroupId IN: InactivegroupIdSet];        
            List<Database.DeleteResult> resultsDel = Database.delete(deleteGMList, false);
            for (Database.DeleteResult result : resultsDel) {
                if (!result.isSuccess()) {
                    isRemoveMemberFailed = true;
                    for(Database.Error err : result.getErrors()) {
                        String errorDelMessage = 'Error occurred: ' + err.getStatusCode() + ' - ' + err.getMessage()+' - '+err.getFields();
                        errorRecs.add(errorDelMessage);
                    }  
                }
            } 
        }
        if(!GMList.isEmpty()){
            List<Database.SaveResult> results = Database.insert(GMList, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    isAddMemberFailed = true;
                    for(Database.Error err : result.getErrors()) {
                        String errorMessage = 'Error occurred: ' + err.getStatusCode() + ' - ' + err.getMessage()+' - '+err.getFields();
                        errorRecs.add(errorMessage);
                    }  
                }
                else if(result.isSuccess()){
                    groupMemSet.add(result.getId());
                }
            } 
        }
        if(!errorRecs.isEmpty() && errorRecs!=null){
            String errorDetailsRec = String.join(errorRecs, '\n');
            if(isAddMemberFailed){
                List<String> userFailedList = new List<String>();
                List<String> userSuccessList = new List<String>();
                if(!groupMemSet.isEmpty() && groupMemSet!=null){
                    List<GroupMember> groupMemRecs = [SELECT Id,GroupId,UserOrGroupId FROM GroupMember WHERE Id IN: groupMemSet];
                    for (GroupMember gm : groupMemRecs) {
                        userSuccessList.add(gm.GroupId+':'+gm.UserOrGroupId);
                    }
                }
                for(Core_IPS_Project_Member__c PrjMemberRec: newList){
                    String grpUserId = projectById.get(PrjMemberRec.Core_IPS_Project__c).Core_IPS_GroupId__c +':'+PrjMemberRec.Core_User__c;
                    if(!userSuccessList.isEmpty() && userSuccessList!=null && !userSuccessList.contains(grpUserId)){
                        userFailedList.add(grpUserId);
                        projMemRecNewList.add(PrjMemberRec);
                    }
                    else if(userSuccessList.isEmpty() || userSuccessList == null){
                        userFailedList.add(grpUserId);
                        projMemRecNewList.add(PrjMemberRec);
                    }
                }
                errorDetailsRec = errorDetailsRec+ '\nFailed to Add Member in the Group Ids: '+ String.join(userFailedList, ',');
            }
            if(isRemoveMemberFailed){
                List<String> userFailedRecList = new List<String>();
                List<GroupMember> failedGMList = [select Id,UserorGroupId,GroupId from GroupMember where UserorGroupId IN: InactiveUserIdSet AND GroupId IN: InactivegroupIdSet];
                for (GroupMember gm : failedGMList) {
                    userFailedRecList.add(gm.GroupId+':'+gm.UserOrGroupId);
                }
                errorDetailsRec = errorDetailsRec+ '\nFailed to Remove Member from the Group Ids: '+ String.join(userFailedRecList, ',');
            }
            if (projMemRecNewList!=null && !projMemRecNewList.isEmpty() && retrycount < maxRetrycount && !Test.isRunningTest()) {
                retrycount++;
                System.enqueueJob(new Core_IPS_ProjectMemberQueueable(oldList,projMemRecNewList,null,'addorremoveprojectmember',retrycount), Integer.valueOf(System.Label.Core_IPS_ProjectMemberSchedulerTimeLimit));
            } else {
            insertExceptionInFuture('','Core_IPS_ProjectMemberQueueable','Core_IPS_Project_Member__c','','AddorRemoveProjMembertoGroup',errorDetailsRec);
            }
        }
	//30072025 below part of the logic is shifted to Core_IPS_ProjectMember_Queueable.AddorRemoveProjMembertoGroup method from Core_IPS_Project_Member_Handler to enable ECBflag-Begin
	if(Core_Trigger_Executions__c.getValues('myIntelProjectMembersTriggerHandler') != null){ //US-0050009 Hercules_IPS_ECBFlagIssueFix
        if(Core_Trigger_Executions__c.getValues('myIntelProjectMembersTriggerHandler').Core_Active__c){
            System.debug('Myintel queueable logic test1 05082025');
            List<Core_IPS_Project_Member__c> projMembers = new List<Core_IPS_Project_Member__c>();
            for(integer i = 0 ; i< newList.size() ; i++){
                if(newList[i].Core_Status__c == 'Active' && oldList[i].Core_Status__c == 'Inactive'){
                    ProjectIdSet.add(newList[i].Core_IPS_Project__c);
                    operationType = 'Add';
                }
                if(newList[i].Core_Status__c == 'Inactive' && oldList[i].Core_Status__c == 'Active'){
                    ProjectIdSet.add(newList[i].Core_IPS_Project__c);
                    operationType = 'Remove';
                }
            }
            if(!ProjectIdSet.isEmpty()){
                Map<Id,Case> projectCases = new Map<Id,Case>();
                if(Case.SObjectType.getDescribe().isQueryable()){
                    projectCases = new Map<Id,Case>([SELECT Id FROM Case where Core_IPS_Project_Case__c IN : ProjectIdSet]);
                    System.debug('Myintel queueable logic test2 05082025 cases count'+projectCases.size());
                }
                if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isQueryable()){
                    projMembers = [SELECT Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__c IN: ProjectIdSet AND Core_Status__c = 'Active'];
                    System.debug('Myintel queueable logic test1 05082025 projmem count'+projMembers.size());
                }
                if(!Test.isRunningTest() && projectCases != null && !projMembers.isEmpty()){
                    System.enqueueJob(new Core_IPS_MyIntel_3_0(new List<Id>(projectCases.keySet()), operationType,projMembers)); 
                }
            }
        }
        } 
	//30072025 part of the logic shifted to Core_IPS_ProjectMember_Queueable.AddorRemoveProjMembertoGroup method from Core_IPS_Project_Member_Handler to enable ECBflag-End 
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
    public static void RemoveProjectMemberfromGroupAfterDelete(List<Core_IPS_Project_Member__c> oldList,Integer retrycount){        
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
            //try{
                List<GroupMember> deleteGMList = [select Id from GroupMember where UserorGroupId IN: InactiveUserIdSet AND GroupId IN: InactivegroupIdSet];        
                //delete deleteGMList;
            //} catch(exception e){ string  Str =  new Core_Exceptionclass().InsertException('','Core_IPS_ProjectMemberQueueable','Core_IPS_Project_Member__c','','removeProjectMemberfromGroupAfterDelete',e);}
            //Changes done by Pavani as part of Missed Active Project Member Fix
            List<Database.DeleteResult> results = Database.delete(deleteGMList, false);
            List<String> errorRecs = new List<String>();
            for (Database.DeleteResult result : results) {
                if (!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        String errorMessage = 'Error occurred: ' + err.getStatusCode() + ' - ' + err.getMessage()+' - '+err.getFields();
                        errorRecs.add(errorMessage);
                    }  
                }
            } 
            if(!errorRecs.isEmpty() && errorRecs!=null){
                List<String> userFailedList = new List<String>();
                List<GroupMember> failedGMList = [select Id,UserorGroupId,GroupId from GroupMember where UserorGroupId IN: InactiveUserIdSet AND GroupId IN: InactivegroupIdSet];
                for (GroupMember gm : failedGMList) {
                    userFailedList.add(gm.GroupId+':'+gm.UserOrGroupId);
                }
                if (retrycount < maxRetrycount && !Test.isRunningTest()) {
                    retrycount++;
                    System.enqueueJob(new Core_IPS_ProjectMemberQueueable(oldList,null,null,'removeprojectmemfromgroup',retrycount), Integer.valueOf(System.Label.Core_IPS_ProjectMemberSchedulerTimeLimit));
                } else {
                String fullErrorMessage = String.join(errorRecs, '\n');
                    fullErrorMessage = fullErrorMessage+ '\nFailed to Remove Member from the Group Ids: '+ String.join(userFailedList, ',');
                insertExceptionInFuture('','Core_IPS_ProjectMemberQueueable','Core_IPS_Project_Member__c','','removeProjectMemberfromGroupAfterDelete',fullErrorMessage);
            }
            }
        }
    }
    /***************************************************************************************************
    Created Date: 09 Sept 2024
    Function    : 
    Description: This method is used call to InsertionMethod in different transaction as we receiving MIXED DML Error if we are inserting setup(GroupMember) and non-setup(Core_Exception) objecst in same trnasaction
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Pavani                    09/09/2024              Created
****************************************************************************************************/
    @future
    public static void insertExceptionInFuture(string  Record_Id,string ClassName,string objectName,string Msg,string MethodName,String ex){ 
        String excetionDeatils= '';
        if(ex.length() >= 32768) {
            excetionDeatils = ex.substring(0, 32767);
        } else {
            excetionDeatils = ex;
        }
            string  Str = new Core_Exceptionclass().InsertException(Record_Id,ClassName,objectName,Msg,MethodName,excetionDeatils);
    }
}