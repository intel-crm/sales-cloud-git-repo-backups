/**************************************************************************************************
Apex Class Name :  Core_IPS_Project_Member_Handler
Description     :  Handler Class used in Project Member Trigger.
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------    
* Sugandha                              20/04/2018             Modified(User Story# US102846 Iteration# 10)
*****************************************************************************************************/
public without sharing class Core_IPS_Project_Member_Handler{ 
public static Integer repeat =0;
    /***************************************************************************************************
Version     : 1.0 
Created Date: 07 Dec 2015
Function    : 
Input Parameters: 
Output Parameters: None
Transactions: After Insert, After Update
Description: This method is used to Add IPS Enabled contacts to Project members object 
All the accounts added with All Core_member type are added to project member object
Used in     : Core_IPS_Account_Dispatcher
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/07/2015              Created
****************************************************************************************************/   
    public static void PreventDelete(List<Core_IPS_Project_Member__c> oldList){
        //added trigger execution by Aayushi for US109046
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('PreventDelete'))     return;
        /*added by Aayushi 07-11-2017 US79852*/
        Core_IPS_Labels__c IpsLabels = Core_IPS_Labels__c.getValues('CoreStatus_Draft');
        String status=IpsLabels.Value__c;
        //start added by Aayushi for US109046
        List<Id> projIdList=new List<Id>();
        List<Case> caseList=new List<Case>();   //end
        if(oldList<> null && oldList.size()>0){
            //List<Core_IPS_Project_Member__c> ProjMemberList = [Select id,Core_IPS_Project__r.Core_Status__c from Core_IPS_Project_Member__c where id IN: oldList];
            Map<Id,Core_IPS_Project_Member__c> ProjMemberMap = new Map<Id,Core_IPS_Project_Member__c>([Select id,Core_IPS_Project__r.Core_Status__c from Core_IPS_Project_Member__c where id IN: oldList]);

            if(ProjMemberMap <> null && ProjMemberMap.size()>0){
                //start added by Aayushi for US109046
                for(Core_IPS_Project_Member__c projMember: oldList){
                    projIdList.add(projMember.Core_IPS_Project__c);    
                }
                
                if(projIdList!=null && projIdList.size()>0){
                    //FLS check added-Venugopal
                    if(Case.SObjectType.getDescribe().isAccessible()){
                        caseList=[Select Id,ContactId,Core_IPS_Project_Case__c from Case where Core_IPS_Project_Case__c In: projIdList AND Status!='Closed'];
                    }
                }//end
                for(Core_IPS_Project_Member__c ProjMember: oldList){
                    //start added by Aayushi for US109046 
                    if(caseList!=null && caseList.size()>0){
                        for(Case case1:caseList) {


                            
                            if(ProjMember.Core_IPS_Contact__c==case1.ContactId && Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(UserInfo.getUserId())==FALSE){ //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
                                ProjMember.adderror('Cannot delete this Project Member when all Cases for this Project Member are not Closed');   
                            }
                            
                            
                            else if(ProjMember.Core_IPS_Contact__c!=case1.ContactId && ProjMemberMap?.get(ProjMember.id).Core_IPS_Project__r.Core_Status__c <> status && !System.Label.Core_IPS_AdminAndSupport_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15)) && Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(UserInfo.getUserId())==FALSE){ //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
                                ProjMember.adderror('Cannot delete this Project Member when status is either Submitted or Active');
                            }
                        }
                    }//end
                    /*modified by Aayushi 2-11-17 US79852*/
                    
                    if(ProjMemberMap?.get(ProjMember.id).Core_IPS_Project__r.Core_Status__c <> status && !System.Label.Core_IPS_AdminAndSupport_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15)) && Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(UserInfo.getUserId())==FALSE){ //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
                        ProjMember.adderror('Cannot delete this Project Member when status is either Submitted or Active');
                    }
                }
            }     
        }
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 09 Jan 2015
Function    : 
Input Parameters: 
Output Parameters: None
Transactions: After Insert, After Update
Description: This method is used to Add IPS Enabled contacts to Project members object 
All the accounts added with All Core_member type are added to project member object
Used in     : Core_IPS_Account_Dispatcher
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        01/09/2015              Created
* Amritesh                   11/08/2017              Modified - updated the logic with Queueable apex
****************************************************************************************************/ 
    
    public static void ManageGroupMember(List<Core_IPS_Project_Member__c>  newList){
        /********* Commenetd as logic moved to queueable apex ***********
String newListStr = ''; 
List<Id> prjIds = new List<Id>();
newListStr= JSON.serialize(newList); 
for(Core_IPS_Project_Member__c prjMem: newList){
if(prjMem.Core_IPS_Provisioning_Date__c == null){
prjIds.add(prjMem.id);              
}
}        
if(prjIds.size()>0)
ManageGroupMemberatFuture(newListStr);
********************************************************/
        //Added - Chandrashekar - US1038332
        Set<Id> ProjectIdSet = new Set<Id>();
        if(Core_Trigger_Executions__c.getValues('myIntelProjectMembersTriggerHandler') != null){
            if(Core_Trigger_Executions__c.getValues('myIntelProjectMembersTriggerHandler').Core_Active__c){
                List<Core_IPS_Project_Member__c> projMembers;
                for(Core_IPS_Project_Member__c PrjMember: newList){
                    ProjectIdSet.add(PrjMember.Core_IPS_Project__c);   
                }
                Map<Id,Case> projectCases;
                if(Case.SObjectType.getDescribe().isQueryable()){
                    projectCases = new Map<Id,Case>([SELECT Id FROM Case where Core_IPS_Project_Case__c IN : ProjectIdSet]);
                }
                if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isQueryable()){
                    projMembers = [SELECT Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__c IN: ProjectIdSet AND Core_Status__c = 'Active'];
                }
                if(!Test.isRunningTest() && projectCases != null && !projMembers.isEmpty()){ 
                    System.enqueueJob(new Core_IPS_MyIntel_3_0(new List<Id>(projectCases.keySet()), 'Add',projMembers)); 
                }
            }
        }
        //End - Chandrashekar - US1038332
        /************* Added by amritesh - US80097 - start *************/
        Map<Id,Core_IPS_Project__c> mapProjectById = new Map<Id,Core_IPS_Project__c>([Select id, Core_IPS_GroupId__c,Createdby.ProfileId from Core_IPS_Project__c where id IN: ProjectIdSet]);

        if(!Test.isRunningTest() && newList.size() < 150){ 
            System.enqueueJob(new Core_IPS_ProjectMemberQueueable(newList, mapProjectById)); 
        }
        else{
            repeat = repeat + Integer.valueOf(System.Label.Core_IPS_ProjectMemberSchedulerTimeLimit);
            DateTime dtCurrentTime = System.now().addminutes(repeat);
            
            String sHour = '', sMinute='', sDayOfMonth='', sMonth='', sYear='';
            
            sMinute = String.ValueOf(dtCurrentTime.minute());
            sHour = String.ValueOf(dtCurrentTime.hour());
            sDayOfMonth = String.ValueOf(dtCurrentTime.day());
            sMonth = String.ValueOf(dtCurrentTime.month());
            sYear = String.ValueOf(dtCurrentTime.year());   
            
            System.schedule('Schedule Batch Job that runs only once after 1 mins '+System.now() + ' ' + dtCurrentTime.milliSecond(), '0 '+sMinute+' '+sHour+' '+sDayOfMonth+' '+sMonth+' ?'+' '+sYear, new Core_IPS_InsertGroupMemberScheduler('SELECT Id,Core_IPS_Project__r.Core_IPS_GroupId__c,Core_User__c From Core_IPS_Project_Member__c WHERE ID',newList,0));
        }
        /************* Added by amritesh - US80097 - end *************/
        
    } 
    /***************************************************************************************************
Version     : 1.0 
Created Date: 09 Jan 2015
Function    : 
Input Parameters: 
Output Parameters: None
Transactions: After Insert, After Update
Description: This method is used to Add IPS Enabled contacts to Project members object 
All the accounts added with All Core_member type are added to project member object
Used in     : Core_IPS_Account_Dispatcher
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        01/09/2015              Created
****************************************************************************************************/ 
    // method commented as logic moved to queueable apex -- amritesh - US80097 - 11/08/2017
    /*
@future
public static void ManageGroupMemberatFuture(String serializedList){
List<Core_IPS_Project_Member__c> newList = (List<Core_IPS_Project_Member__c>)JSON.deserialize(serializedList, List<Core_IPS_Project_Member__c>.class);
List<GroupMember> GMlist = new List<GroupMember>();
Set<Id> ProjectIdSet = new Set<Id>();
for(Core_IPS_Project_Member__c PrjMember: newList){
ProjectIdSet.add(PrjMember.Core_IPS_Project__c);
}
Map<Id,Core_IPS_Project__c> projectById = new Map<Id,Core_IPS_Project__c>([Select id, Core_IPS_GroupId__c from Core_IPS_Project__c where id IN: ProjectIdSet]);
for(Core_IPS_Project_Member__c PrjMember: newList){
GroupMember GM = new GroupMember();
GM.GroupId = projectById.get(PrjMember.Core_IPS_Project__c).Core_IPS_GroupId__c;
GM.UserorGroupId = PrjMember.Core_User__c;
GMList.add(GM);
}
if(!GMList.isEmpty()){
insert GMList;
}
}*/
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 09 Jan 2015
Function    : 
Input Parameters: 
Output Parameters: None
Transactions: After Insert, After Update
Description: This method is used to Delete IPS Enabled contacts to Project members object 
All the accounts added with All Core_member type are added to project member object
Used in     : Core_IPS_Account_Dispatcher
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        01/09/2015              Created
* Chandrashekar              21/06/2021              Updated-US1038332
****************************************************************************************************/     
    public static void RemoveorReaddProjMember(Map<Id,Core_IPS_Project_Member__c> oldMap, List<Core_IPS_Project_Member__c> oldList, List<Core_IPS_Project_Member__c> newList){
        String operationType;
        String newListStr = ''; 
        String oldListStr = '';
        newListStr= JSON.serialize(newList); 
        oldListStr = JSON.serialize(oldList);
        List<Id> prjIds =  new List<Id>();
        List<GroupMember> GMlist = new List<GroupMember>();
        Set<Id> ProjectIdSet = new Set<Id>();
        for(Core_IPS_Project_Member__c prjMem: newList){
            if(prjMem.Core_IPS_isFuture_onInsert__c && oldMap.get(prjMem.id).Core_IPS_isFuture_onInsert__c <> prjMem.Core_IPS_isFuture_onInsert__c){
                prjIds.add(prjMem.id);
            }else if(prjMem.Core_IPS_isFuture_onUpdate__c && prjMem.Core_Status__c == 'Active' && prjMem.Core_IPS_Provisioning_Date__c == null){ 
                prjIds.add(prjMem.id);
            }
            else{
                if(prjMem.Core_IPS_Provisioning_Date__c == null && (prjMem.Core_Status__c == 'Inactive' || prjMem.Core_Status__c == 'Active'))
                    prjIds.add(prjMem.id);
            }
        }
        //Added - Chandrashekar - US1038332 
    //30072025 below part of the logic shifted to Core_IPS_ProjectMember_Queueable.AddorRemoveProjMembertoGroup method from Core_IPS_Project_Member_Handler to enable ECBflag-Begin 
     /* if(Core_Trigger_Executions__c.getValues('myIntelProjectMembersTriggerHandler') != null){ //US-0050009 Hercules_IPS_ECBFlagIssueFix
        if(Core_Trigger_Executions__c.getValues('myIntelProjectMembersTriggerHandler').Core_Active__c){
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
                    projectCases = new Map<Id,Case>([SELECT Id FROM Case where Core_IPS_Project_Case__c IN : ProjectIdSet AND Status != 'Closed' ]); //query opt
                }
                if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isQueryable()){
                    projMembers = [SELECT Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__c IN: ProjectIdSet AND Core_Status__c = 'Active'];
                }
                if(!Test.isRunningTest() && projectCases != null && !projMembers.isEmpty()){
                    System.enqueueJob(new Core_IPS_MyIntel_3_0(new List<Id>(projectCases.keySet()), operationType,projMembers)); 
                }
            }
        }
        } */
      	//30072025 part of the logic shifted to Core_IPS_ProjectMember_Queueable.AddorRemoveProjMembertoGroup method from Core_IPS_Project_Member_Handler to enable ECBflag-End 
        // End - Chandrashekar - US1038332
        // WF 1: Entry Criteria - Date <> null, Result - Make isFutureInsert as True and Set Date to null
        // WF 2: Entry Criteria - Date <> null and Status is Active, Result - Make isFutureUpdate as True and Set Date to null
        
        // if(ProjectIdSet <> null && ProjectIdSet.size()>0){
        // Map<Id,Core_IPS_Project__c> projectById = new Map<Id,Core_IPS_Project__c>([Select id, Core_IPS_GroupId__c from Core_IPS_Project__c where id IN: ProjectIdSet]);
        // for(Core_IPS_Project_Member__c PrjMember: newList){
        // GroupMember GM = new GroupMember();
        // GM.GroupId = projectById.get(PrjMember.Core_IPS_Project__c).Core_IPS_GroupId__c;
        // GM.UserorGroupId = PrjMember.Core_User__c;
        // GMList.add(GM);
        // }
        // if(!GMList.isEmpty()){

            // insert GMList;
        // }
        // }
        
        /********* Commenetd as logic moved to queueable apex ***********
if(prjIds <> null && prjIds.size()>0)
RemoveorReaddProjMemberatFuture(oldListStr,newListStr);
*****************************************************************/
        
        /************* Added by amritesh - US80097 - start *************/
        if(!Test.isRunningTest()){ System.enqueueJob(new Core_IPS_ProjectMemberQueueable(oldList, newList)); }
    }
    /***************************************************************************************************
Version     : 1.0 
Created Date: 21 Jun 2021
Function    : 
Input Parameters: 
Output Parameters: None
Transactions: Before Delete
Description: This method is used to handle the deletion of project member from 
Used in     : Core_IPS_Account_Dispatcher
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                        Date                   Description
* ----------------------------------------------------------------------------                 
* Chandrashekar Pallikonda         21/06/2021              Created
****************************************************************************************************/     
    public static void handleDeleteProjMember(List<Core_IPS_Project_Member__c> oldList){
        if(Core_Trigger_Executions__c.getValues('myIntelProjectMembersTriggerHandler') != null){ 
        if(!Core_Trigger_Executions__c.getValues('myIntelProjectMembersTriggerHandler').Core_Active__c){
            return;
        }
        }
        Set<Id> ProjectIdSet = new Set<Id>();
        List<Id> memberList = new List<Id>();
        Map<Id,Case> projectCases;
        List<Core_IPS_Project_Member__c> projMembers;
        for(Core_IPS_Project_Member__c PrjMember: oldList){
            if(PrjMember.Core_Status__c != 'Inactive'){
                ProjectIdSet.add(PrjMember.Core_IPS_Project__c);    
                memberList.add(PrjMember.Id);
            }
        }
        if(!ProjectIdSet.isEmpty()){
            if(Case.SObjectType.getDescribe().isQueryable()){
                projectCases = new Map<Id,Case>([SELECT Id FROM Case where Core_IPS_Project_Case__c IN : ProjectIdSet]);
            }
            if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isQueryable()){
                projMembers = [SELECT Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__c IN: ProjectIdSet AND Core_Status__c = 'Active'];
            }
            if(!Test.isRunningTest() && projectCases != null && !projMembers.isEmpty()){ 
                System.enqueueJob(new Core_IPS_MyIntel_3_0(new List<Id>(projectCases.keySet()), 'Remove', projMembers)); 
            }
        }
    }
    /***************************************************************************************************
Version     : 1.0 
Created Date: 09 Jan 2015
Function    : 
Input Parameters: 
Output Parameters: None
Transactions: After Insert, After Update
Description: This method is used to Delete IPS Enabled contacts to Project members object 
All the accounts added with All Core_member type are added to project member object
Used in     : Core_IPS_Account_Dispatcher
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        01/09/2015              Created
****************************************************************************************************/     
    // method commented as logic moved to queueable apex -- amritesh - US80097 - 11/08/2017
    /*
@future
public static void RemoveorReaddProjMemberatFuture(String oldListStr,String newListStr){
List<Core_IPS_Project_Member__c> oldList= (List<Core_IPS_Project_Member__c>)JSON.deserialize(oldListStr, List<Core_IPS_Project_Member__c>.class);
List<Core_IPS_Project_Member__c> newList= (List<Core_IPS_Project_Member__c>)JSON.deserialize(newListStr, List<Core_IPS_Project_Member__c>.class);
Map<Id,Core_IPS_Project_Member__c> oldMap = new Map<Id,Core_IPS_Project_Member__c>();
List<GroupMember> GMlist = new List<GroupMember>();
Set<Id> ProjectIdSet = new Set<Id>();
for(Core_IPS_Project_Member__c projMem:oldList){
oldMap.put(projMem.id,projMem);
}
Map<Id,Id> revokeAccessRecords = new Map<Id,Id>();
Set<Id> InactiveUserIdSet = new Set<Id>();
Set<Id> InactivegroupIdSet = new Set<Id>();
for(Core_IPS_Project_Member__c PrjMember: newList){
ProjectIdSet.add(PrjMember.Core_IPS_Project__c);
}
Map<Id,Core_IPS_Project__c> projectById = new Map<Id,Core_IPS_Project__c>([Select id, Core_IPS_GroupId__c from Core_IPS_Project__c where id IN: ProjectIdSet]);
List<Core_IPS_Project_Member__c> prjmem = [select id,Core_User__c,Core_Status__c ,Core_IPS_Project__r.Core_Status__c,Core_IPS_Project__r.Core_IPS_GroupId__c from Core_IPS_Project_Member__c where id IN: newList ];
for(Core_IPS_Project_Member__c PrjMember: prjmem){
    if(PrjMember.Core_Status__c == 'Inactive' && oldMap.get(PrjMember.Id).Core_Status__c == 'Active'){
        InactiveUserIdSet.add(PrjMember.Core_User__c);
InactivegroupIdSet.add(PrjMember.Core_IPS_Project__r.Core_IPS_GroupId__c);
}
if(PrjMember.Core_Status__c == 'Active' ){
//&& oldMap.get(PrjMember.Id).Core_Status__c == 'Inactive'){
    GroupMember GM = new GroupMember();
GM.GroupId = projectById.get(PrjMember.Core_IPS_Project__c).Core_IPS_GroupId__c;
GM.UserorGroupId = PrjMember.Core_User__c;
GMList.add(GM);
}
}
if(InactiveUserIdSet <> null && InactivegroupIdSet <> null){    
List<GroupMember> deleteGMList = [select Id from GroupMember where UserorGroupId IN: InactiveUserIdSet and GroupId IN: InactivegroupIdSet];        
delete deleteGMList;
}
if(!GMList.isEmpty()){
    insert GMList;
}
}*/ 
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 11/08/2017        
Function    : 
Input Parameters: 
Output Parameters: None
Transactions: After Insert, After Update
Description: This method is used to Remove members from Group if Project Member is deleted
Used in     : Core_IPS_Project_Member_Dispatcher
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:2
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh                   11/08/2017              Created - US80097
****************************************************************************************************/ 
    public static void removeProjectMemberFromGroup(List<Core_IPS_Project_Member__c> oldList) {
        if(!Test.isRunningTest()){ System.enqueueJob(new Core_IPS_ProjectMemberQueueable(oldList, 'removeprojectmemfromgroup')); }
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 09/01/2018        
Function    : 
Input Parameters: Project Member List
Output Parameters: None
Transactions: After Update
Description: This method is used to prevent Inactivating Project Members, atleast one Active Project Member should be there on an account
Used in     : Core_IPS_Project_Member_Dispatcher
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi Singhal                    09/01/2018              Created - US90060
****************************************************************************************************/ 
    public static void preventInactivatingProjectMember(Map<Id,Core_IPS_Project_Member__c> oldMap,List<Core_IPS_Project_Member__c> newList) {
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('inactivatingProjMem'))
            return;
        try{
	    List<AggregateResult> activeProjMemList = new List<AggregateResult>();
            String errorMsg,inactiveStatus,activeStatus=null;
            boolean internalUser;
            internalUser=Network.getNetWorkid()== null? True:false;
            inactiveStatus = Core_IPS_Helper_Utility.getIPSLabel('CoreStatus_Inactive'); 
            activeStatus = Core_IPS_Helper_Utility.getIPSLabel('CoreStatus_Active'); 
            errorMsg = Core_IPS_Helper_Utility.getIPSLabel('Core_InactivatingProjMem_Error');
            List<Id> projectList=new List<Id>();
            Map<Id,Integer> activeProjMemMap=new Map<Id,Integer> ();
            if(inactiveStatus!=null && activeStatus!=null && internalUser){
                for(Core_IPS_Project_Member__c projectMember: newList){
                    if(projectMember.Core_Status__c==inactiveStatus && oldMap.get(projectMember.Id).Core_Status__c!=inactiveStatus){
                        projectList.add(projectMember.Core_IPS_Project__c);
                    }
                }
                if(projectList.size()>0){
                    //FLS check added-Venugopal
                    if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
                        activeProjMemList= [select Count(Id),Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_Status__c =:activeStatus and Core_IPS_Project__c IN :projectList GROUP BY Core_IPS_Project__c];
                    }
                    for(AggregateResult activeProjMem:activeProjMemList){
                        activeProjMemMap.put((Id)activeProjMem?.get('Core_IPS_Project__c'),(Integer)activeProjMem.get('expr0'));
                    }
                }
                for(Core_IPS_Project_Member__c projectMember: newList){
                    if(projectMember.Core_Status__c==inactiveStatus && oldMap.get(projectMember.Id).Core_Status__c!=inactiveStatus){
                        Integer countInactiveProjMem=activeProjMemMap?.get(projectMember.Core_IPS_Project__c);

                        if((countInactiveProjMem==null || countInactiveProjMem<1)&& projectMember.Core_IPS_Contact_IPS_Active__c){
                            if(Core_IPS_SkipTriggerHandler.skipQueueable){ //US-0050009 Hercules_IPS_ECBFlagIssueFix
                                return;
                            }
                            projectMember.addError(errorMsg); 
                        }
                    }
                }
            }
        }
        catch(Exception e){Core_IPS_ExceptionHandling.logEntryWithException(e, 'Project', 'Core_IPS_Project_Handler');
                          // System.debug('Core_IPS_Project_Handler-->activateProject-->Exception--->'+e.getMessage()+'At Line Number-->'+e.getLineNumber());
                          }
        
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 19 Apr 2018
Input Parameters: 
Transactions: before update
Description: This method is used to show an error message for FAE on deactivate of an Active Project Member
from non affiliated Account Team.
Used in     : Core_IPS_Account_Dispatcher
Number of Queries Within this Method: 2
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                    20/04/2018              Created(User Story# US102846 Iteration# 10)
****************************************************************************************************/   
    public static void PreventInactivateProMem_FAE(List<Core_IPS_Project_Member__c> newList){
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('PreventInactivateProMem_FAE'))
            return;
        
        //Check logged in users profile, this code execute only for FAE users 
        if(System.Label.Core_IPS_SalesRep_Profile_Ids.Contains(String.ValueOf(userinfo.getProfileId()).substring(0,15))){ 
            Set<Id> setContId = new Set<Id>();// set of Project Member Contact Ids
            Set<Id> setAccId = new Set<Id>();// set of Project Member Contacts Account Ids
            Map<Id,Id> mapConAccId = new Map <Id,Id>(); // Map of Project Contact Id to Account Id
            Set<Id> setEligbleAcc = new Set<Id>(); // set Account Ids in which FAE is a Team Member
            
            for(Core_IPS_Project_Member__c proj: newList){
                setContId.add(proj.Core_IPS_Contact__c);
            }
            //FLS check added-Venugopal
            if(Contact.SObjectType.getDescribe().isAccessible()){
                for(Contact con: [SELECT Id,AccountId FROM Contact where  Id IN :setContId]){
                    setAccId.add(con.AccountId);   
                    mapConAccId.put(con.Id,con.AccountId); 
                }
            }
            //query UserRecordAccess for FAE loggedinuser  for all the above account set
            // FLS check added-Venugopal
            if(AccountTeamMember.SObjectType.getDescribe().isAccessible()){
                for(AccountTeamMember accteam : [SELECT Id, AccountId FROM AccountTeamMember WHERE UserId =:UserInfo.getUserId()]){
                    setEligbleAcc.add(accteam.AccountId);
                }
            }
            //Iterate using newList of Project Member and display an Error on insufficient access
            for(Core_IPS_Project_Member__c projMem: newList){
                if(projMem.Core_Status__c == Core_IPS_Helper_Utility.getIPSLabel('CoreStatus_Inactive') 
                   && !setEligbleAcc.Contains(mapConAccId?.get(projMem.Core_IPS_Contact__c))){
                       projMem.addError(Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_ProjectMem_Inactive_Error'));
                   }
            }
        }
    }
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 23 May 2018
Input Parameters: 
Transactions: After Insert
Description: This method is used to add the project members to Case external interested parties from
the Project. 
Used in     : Core_IPS_Project_Member_Dispatcher
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rakesh Marka                   23/05/2018              User Story--US80116 
* Aayushi Singhal              15/02/2019           DE32193
****************************************************************************************************/  
    // Method to insert a record in InterestedParties using SupportProjectMembers
    
    public static void interestedParties_ProjectMembers(List<Core_IPS_Project_Member__c> newList,Map<Id,Core_IPS_Project_Member__c> oldMap) {  
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('interestedParties_ProjectMembers') && !Test.isRunningTest())
            return;
        Map<id,id> mapMember2ProjId = new Map<id,id>();
        Set<Id> setContactId=new Set<Id>();
        Set<Id> setProjectId=new Set<Id>();
        List<Core_IPS_Case_Interested_Party__c> interestedPartyList= new List<Core_IPS_Case_Interested_Party__c>();
        
        if(newList!=null && newList.size()>0){ 
            //start modified for DE32193
            for(Core_IPS_Project_Member__c cp:newList){ 
                if(oldMap!=null && cp.Add_as_Case_Interested_Party__c){
                    setContactId.add(cp.Core_IPS_Contact__c); 
                }
                if(oldMap==null && cp.Add_as_Case_Interested_Party__c==true && cp.Core_Status__c=='Active'){
                 setProjectId.add(cp.Core_IPS_Project__c);   
                }
            }
            if(setContactId!=null && setContactId.size()>0){
                Map<Id,User> objUser = new Map<Id,User>([SELECT Id,ContactId,Contact.Core_IPS_Active__c,Contact.Core_IPS_Email_Opt_Out__c,Isactive FROM User WHERE ContactId IN :setContactId]);
                if(objUser!=null && objUser.size()>0){
                    for(Core_IPS_Project_Member__c cp:newList){
                        //  PRB10061297-  Start - Shipra
                        if (objUser.containsKey(cp.Core_User__c) && !objUser.get(cp.Core_User__c).Contact.Core_IPS_Active__c){
                            cp.addError('Contact IPS is Not Checked ');  
                        } else if (objUser.containsKey(cp.Core_User__c) && objUser.get(cp.Core_User__c).Contact.Core_IPS_Email_Opt_Out__c){
                            cp.addError('Cannot enable as Interested Parties since Contact Email opt Out is Checked');   
                        } else if (objUser.containsKey(cp.Core_User__c) && !objUser.get(cp.Core_User__c).Isactive){
                            cp.addError('User is Not Active ');   
                        } else{
                         setProjectId.add(cp.Core_IPS_Project__c);  
                        }
                        //  PRB10061297-  End - Shipra
                    }   
                }
        }
            
            if(setProjectId!=null && setProjectId.size()>0){
            interestedPartyList= createInterestedParty(setProjectId);

            if(interestedPartyList!=null && interestedPartyList.size()>0){
                    System.enqueueJob(new Core_IPS_insertInterestedPartyQueueable(interestedPartyList));
                }
            }
            
           /*  for(Core_IPS_Project_Member__c cp:newList){ 
                if(cp.Add_as_Case_Interested_Party__c==true && cp.Core_Status__c=='Active'){              
                    mapMember2ProjId.put(cp.id,cp.Core_IPS_Project__c);    
                }
            }
            
            if(mapMember2ProjId.size()>0){       
                List<case> lstCase = new List<Case>([SELECT Id from Case WHERE Core_IPS_Project_Case__c IN :mapMember2ProjId.Values() and Status!='Closed']);  
                insertInterestedParty(newList, lstCase);
            }  */
            //end
        }
    }
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 14 June 2018
Input Parameters: 
Transactions: After Insert
Description: This method is used 
Used in     : Core_IPS_Project_Dispatcher
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rakesh Marka                   14/06/2018              User Story--US107411
* Aayushi                       12/02/2019              DE32193
****************************************************************************************************/  
    
    // insert External Interested party
    public static void insertInterestedParty(List<Core_IPS_Project_Member__c> lstProjectmember, List<Case> lstCase) {
   
    //Modified for DE32193 to avoid CPU timeout
    // System.enqueueJob(new Core_IPS_ueueable(lstProjectmember,lstCase));
        
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 11 JUNE 2018
Input Parameters: 
Transactions: before Update
Description: This method is used to remove the project members from the case interested parties when the status of the 
project member is inactive
Used in     : Core_IPS_Project_Member_Dispatcher
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rakesh Marka                   11/06/2018              User Story--US107411 
****************************************************************************************************/  
    
    
    // Removing Interested parties using status in Project Memebers
    public static void removeRelatedIpsOnStatusChangeForPM(List<Core_IPS_Project_Member__c> projectMembersList,Map<Id,Core_IPS_Project_Member__c> oldMap){
        List<case> cistList = new List<case>();
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('removeRelatedIpsOnStatusChangeForPM'))
        {return;}
        
        set<Id> project_map=new set<Id>();     
        Map<id,id> caseMap=new Map<id,id>();
        List<Core_IPS_Case_Interested_Party__c> cipListToBeInserted = new List<Core_IPS_Case_Interested_Party__c>();    
        if(projectMembersList.size()>0){          
            for(Core_IPS_Project_Member__c projectMember_list:projectMembersList){  
                if(oldMap.get(projectMember_list.id).Core_Status__c!=projectMember_list.Core_Status__c && projectMember_list.Core_Status__c=='Inactive'){          
                    project_map.add(projectMember_list.Core_IPS_Project__c);
                    projectMember_list.Add_as_Case_Interested_Party__c=false;
                }else if(oldMap.get(projectMember_list.id).Add_as_Case_Interested_Party__c  !=projectMember_list.Add_as_Case_Interested_Party__c && projectMember_list.Add_as_Case_Interested_Party__c==true && oldMap.get(projectMember_list.id).Core_Status__c==projectMember_list.Core_Status__c && projectMember_list.Core_Status__c=='Inactive' ){
                    projectMember_list.addError('Cannot Enable as Interested Parties when status is Inactive');
                }       
            }
            
        }
        if(project_map.size()>0){
            //FLS check added-Venugopal
            if(case.SObjectType.getDescribe().isAccessible()){
                cistList=[select id,CaseNumber,Core_IPS_Project_Case__c from case where Core_IPS_Project_Case__c In:project_map and status!='closed'];      
            }
            if(cistList.size()>0){ 
                for(Core_IPS_Project_Member__c projectMember_list:projectMembersList){     
                    for(case caseList:cistList){   
                        if(caseList.Core_IPS_Project_Case__c==projectMember_list.Core_IPS_Project__c){        
                            caseMap.put(caseList.id,projectMember_list.Core_IPS_Contact__c);
                        } 
                    }  
                } 
            } 
        }
        if(caseMap.size()>0 && caseMap!=null){
            /*US1038641 - 06/23/2021 - Yamini - CRUD Delete Check for security vulnerability --*/
            if (Core_IPS_Case_Interested_Party__c.sObjectType.getDescribe().isDeletable()) {
                delete [select id from Core_IPS_Case_Interested_Party__c where Case__c in : caseMap.keySet() and Contact__c in:caseMap.values()];
            } 
        }
        
    }
    
    /***************************************************************************************************    
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Rakesh                                             Created - DE18795
    ****************************************************************************************************/   
    public static void addNewProjectMember(List<Core_IPS_Project_Member__c> newList) {
        List<Id> projectIDs=new List<Id>();
        for(Core_IPS_Project_Member__c projMember : newList){
            projectIDs.add(projMember.Core_IPS_Project__c);
        }
        Map<Id,Boolean> projectIDValueMap = new Map<Id,Boolean>();
        List<Core_IPS_Project__c> projectList = new List<Core_IPS_Project__c>();
        Map<Id,Core_IPS_Project_Member__c> oldProjMemberMap = (Map<Id,Core_IPS_Project_Member__c>)Trigger.oldMap;
        if(Core_IPS_Project__c.SObjectType.getDescribe().isAccessible()){
            projectList = [select id, Core_IPS_EnableMemberasInterestedParties__c from Core_IPS_Project__c where Core_IPS_Project__c.id in : projectIDs ];    
        }        
        for(Core_IPS_Project__c  projRecord: projectList){
            projectIDValueMap.put(projRecord.id, projRecord.Core_IPS_EnableMemberasInterestedParties__c );
        }
        for(Core_IPS_Project_Member__c projMember : newList){
            Id projmem=projMember.Core_IPS_Project__c;
            if(projectIDValueMap!=null && projectIDValueMap?.get(projmem)!=null){
                if((projectIDValueMap?.get(projmem) && projMember.Core_Status__c=='Active') && (oldProjMemberMap!=null) && (projMember.Add_as_Case_Interested_Party__c != oldProjMemberMap.get(projMember.Id).Add_as_Case_Interested_Party__c)){
                    //No action performed. Default behaviour
                }else if(projectIDValueMap?.get(projmem) && projMember.Core_Status__c=='Active'){
                    projMember.Add_as_Case_Interested_Party__c=true;

                }
            }
        }
    } 
    
    /***************************************************************************************************
    Version     : 1.0 
    Input Parameters: List, Map
    Transactions: before update
    Description: This method is used to remove PSO from Project if project member is inactivated
    from non affiliated Account Team.
    Used in     : Core_IPS_Project_Member_Dispatcher
    Number of Queries Within this Method: 2
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    09/05/2018             Created - US137508
    ****************************************************************************************************/   
    public static void RemovePSO(List<Core_IPS_Project_Member__c> newList, Map<Id, Core_IPS_Project_Member__c> oldMap) {
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('removePSOonProject')) {return;}
        
        String inactiveStatus = Core_IPS_Helper_Utility.getIPSLabel('CoreStatus_Inactive'); 
        Map<Id,Core_IPS_Project__c> mapProjectId2RemovePSO = new Map<Id,Core_IPS_Project__c>();
        List<Case> lstCase2RemovePSO = new List<Case>();
        Map<Id,Set<Id>> mapProjectId2RemovedPSO4Case = new Map<Id,Set<Id>>();
        Set<Id> setProjectId = new Set<Id>();
        Map<Id,Core_IPS_Project__c> mapProject;
        
        for(Core_IPS_Project_Member__c objProjMem : newList) {
            setProjectId.add(objProjMem.Core_IPS_Project__c);
        }
        //FLS check added-Venugopal
        if(Core_IPS_project__c.SObjectType.getDescribe().isAccessible()){
            mapProject = new Map<Id,Core_IPS_Project__c>([SELECT Id,Core_IPS_Partner_Support_Owner__c FROM Core_IPS_project__c WHERE Id IN :setProjectId]);        
        }
        for(Core_IPS_Project_Member__c objProjMem : newList) {
            if(
               (Trigger.isUpdate && objProjMem.Core_Status__c!=oldMap.get(objProjMem.Id).Core_Status__c && objProjMem.Core_Status__c==inactiveStatus)
               ||
               (Trigger.isDelete)
            )
            {
                if(objProjMem.Core_User__c==mapProject?.get(objProjMem.Core_IPS_Project__c).Core_IPS_Partner_Support_Owner__c)
                mapProjectId2RemovePSO.put(objProjMem.Core_IPS_Project__c, new Core_IPS_Project__c(Id=objProjMem.Core_IPS_Project__c, Core_IPS_Partner_Support_Owner__c=null));
            
                if(!mapProjectId2RemovedPSO4Case.containsKey(objProjMem.Core_IPS_Project__c)) {
                    mapProjectId2RemovedPSO4Case.put(objProjMem.Core_IPS_Project__c, new Set<Id>());                    
                }
                mapProjectId2RemovedPSO4Case?.get(objProjMem.Core_IPS_Project__c).add(objProjMem.Core_User__c);
            }            
        }
        
        if(Case.SObjectType.getDescribe().isAccessible()){
            for(Case objCase : [SELECT Id,Core_IPS_Partner_Sup_Owner__c,Core_IPS_Project_Case__c FROM Case WHERE Core_IPS_Project_Case__c IN :mapProjectId2RemovedPSO4Case.KeySet() AND Status IN ('New','Open')]) {
                
                if(objCase.Core_IPS_Partner_Sup_Owner__c != null) {
                    objCase.Core_IPS_Partner_Sup_Owner__c = null;
                    lstCase2RemovePSO.add(objCase);
                }
                            
            } 
        }
        if(mapProjectId2RemovePSO.size()>0) update mapProjectId2RemovePSO.values();            
        if(lstCase2RemovePSO.size()>0) update lstCase2RemovePSO;
    }
    

/***************************************************************************************************
Version     : 1.0 
Created Date: 14 Feb 2019
Input Parameters: Set of Project Id
Transactions: 
Description : This method is used to create Interested Party records but is not inserted in database, 
              records are inserted in Queueable class
Used in     : Core_IPS_Project_Handler, Core_IPS_Project_Member_Handler
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi Singhal             14/02/2019             DE32193
****************************************************************************************************/ 
    
public static List<Core_IPS_Case_Interested_Party__c> createInterestedParty(Set<Id> projIdSet) {
        List<Core_IPS_Project_Member__c> projMemList=new List<Core_IPS_Project_Member__c>();
        Map<Id,List<Core_IPS_Project_Member__c>> proj_ProjMemMap=new Map<Id,List<Core_IPS_Project_Member__c>>();
        Map<Id,List<Case>> projCaseMap=new Map<Id,List<Case>>();
        List<Core_IPS_Case_Interested_Party__c> externalIPListToBeInserted = new List<Core_IPS_Case_Interested_Party__c>();
        List<case> caseList =new List<case>();
        Set<String> setExistingIP = new Set<String>();
        
        if(projIdSet!=null && projIdSet.size()>0){
            //FLS check added-Venugopal
            if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
                projMemList=[SELECT Id,Core_IPS_Contact__c,Core_User__c,Add_as_Case_Interested_Party__c,Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__c IN :projIdSet AND Core_IPS_Contact__r.Core_IPS_Active__c=true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c=false AND Core_Status__c='Active' AND Core_User__r.IsActive=true AND Add_as_Case_Interested_Party__c=true];  
            }
            //FLS check added-Venugopal
            if(Case.SObjectType.getDescribe().isAccessible()){
                caseList=[Select Id,Core_IPS_Project_Case__c from Case WHERE Core_IPS_Project_Case__c IN :projIdSet and Status!='Closed' and Core_IPS_Customer_Visible__c=true];
            }
            if(caseList!=null && caseList.size()>0){
                for(Case cs: caseList){
                    if(!projCaseMap.containsKey(cs.Core_IPS_Project_Case__c)){
                        projCaseMap.put(cs.Core_IPS_Project_Case__c,new List<Case>());
                    }                   
                    projCaseMap?.get(cs.Core_IPS_Project_Case__c).add(cs);   
                }
            }
            if(projMemList!=null && projMemList.size()>0){
                for(Core_IPS_Project_Member__c projMem: projMemList){
                    if(!proj_ProjMemMap.containsKey(projMem.Core_IPS_Project__c)){
                    proj_ProjMemMap.put(projMem.Core_IPS_Project__c,new List<Core_IPS_Project_Member__c>());
                    }
                    proj_ProjMemMap?.get(projMem.Core_IPS_Project__c).add(projMem);
                }
            }
	 //  Added by Chiru - 20-08-24 - APEX GURU - SOQL FIX
            Map<Id, Case> caseListMap = new Map<Id, Case>();
            if(caseList!=null && caseList.size()>0){
                caseListMap = new Map<Id, Case>(caseList);
            }
            for(Core_IPS_Case_Interested_Party__c objIP : [SELECT Id,User__c,Case__c,Contact__c FROM Core_IPS_Case_Interested_Party__c WHERE Case__c IN :caseListMap.keySet()]) {
            setExistingIP.add(objIP.Contact__c + ';' + objIP.Case__c);
        }
            for(Id projId: projIdSet){
                if(proj_ProjMemMap!=null && proj_ProjMemMap?.get(projId)!=null){
                    for(Core_IPS_Project_Member__c objProjMem : proj_ProjMemMap?.get(projId)){
                            if(projCaseMap!=null && projCaseMap?.get(projId)!=null){
                                for(Case objCase : projCaseMap?.get(projId)) {
                                    if(setExistingIP.contains(objProjMem.Core_IPS_Contact__c + ';' + objCase.Id)) continue;
                                    Core_IPS_Case_Interested_Party__c cip = new Core_IPS_Case_Interested_Party__c();  
                                    cip.Contact__c = objProjMem.Core_IPS_Contact__c; 
                                    cip.User__c = objProjMem.Core_User__c;
                                    cip.Case__c = objCase.Id;
                                    cip.Type__c = 'External';
                                    cip.Active__c = true;
                                    cip.Core_IPS_Project_Interested_Party__c = true;
                                    externalIPListToBeInserted.add(cip);
                                    
                                }  
                            } 
                    }
                }
            }

        }
        if(externalIPListToBeInserted!=null && externalIPListToBeInserted.size()>0){
        return externalIPListToBeInserted;    
        }
        else{
            return null;
        }
          
    }    
}