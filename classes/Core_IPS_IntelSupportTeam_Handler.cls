/**************************************************************************************************
Apex Class Name :  Core_IPS_IntelSupportTeam_Handler
Description     :  Handler Class used in Intel Support Team Trigger.Test Class-Core_IPS_Add_IntelSupportTeam_Test 
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------    
* Aayushi                              20/04/2018             Created for US102838
*****************************************************************************************************/
public without sharing class Core_IPS_IntelSupportTeam_Handler {
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 23 April 2018
UserStory    : US102838
Input Parameters: 
Output Parameters: None
Transactions: After Insert
Description: This method is used to Add Intel Support Team Members to the Internal Project Group
Used in     : Core_IPS_IntelSupportTeam_Dispatcher
Number of Queries Within this Method: 
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi                        23/04/2018              Created
****************************************************************************************************/
    public static void insertInternalGroupMember(List<Core_IPS_Intel_Support_Team__c>  newList){
        Map<Id,Core_IPS_Project__c> projMap = new Map<Id,Core_IPS_Project__c>();
        List<Core_IPS_Project__c> projList = new List<Core_IPS_Project__c>();
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('internalProjectGroup')) {
            return;
        }
        try{
            if(newList!=null && newList.size()>0){
                List<Core_IPS_Intel_Support_Team__c> istMemberList=new List<Core_IPS_Intel_Support_Team__c>();
                String listGroupMemberStr;  
                List<Id> istMemberProj=new List<Id>();
                for(Core_IPS_Intel_Support_Team__c istMember: newList){
                    if(istMember.Status__c=='Active'){
                        istMemberList.add(istMember);
                        istMemberProj.add(istMember.Core_IPS_Project__c);   
                    }
                }
                if(Core_IPS_Project__c.SObjectType.getDescribe().isAccessible()){
                    projList = [Select id,name,Core_IPS_InternalGroupId__c,Core_IPS_Unique_Project_Number__c from Core_IPS_Project__c where id IN: istMemberProj ];
                }
                if(projList!=null && projList.size()>0){
                    Core_IPS_Project_Handler.internalProjectGroup(projList);   
                }
                if(Core_IPS_Project__c.SObjectType.getDescribe().isAccessible()){
                    projMap = new Map<Id,Core_IPS_Project__c>([Select id,name,Core_IPS_InternalGroupId__c,Core_IPS_Unique_Project_Number__c from Core_IPS_Project__c where id IN: istMemberProj ]);
                }
                if(istMemberList!=null && istMemberList.size()>0){
                    List<GroupMember> listGroupMembersToInsert= new List<GroupMember>();
                    for(Core_IPS_Intel_Support_Team__c istMember:istMemberList){
                        String GroupId=projMap.get(istMember.Core_IPS_Project__c).Core_IPS_InternalGroupId__c;
                        GroupMember GM = new GroupMember();
                        GM.GroupId = GroupId;
                        GM.UserorGroupId = istMember.Core_IPS_User__c;
                        listGroupMembersToInsert.add(GM);
                    }  
                    if(!listGroupMembersToInsert.isEmpty()){
                        listGroupMemberStr = JSON.serialize(listGroupMembersToInsert);
                        insertGroupMember(listGroupMemberStr);
                    }
                }
            }  
        }  catch(Exception ex){   }
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 23 April 2018
UserStory    : US102838
Input Parameters: 
Output Parameters: None
Transactions: After Insert
Description: This method is used to Add Intel Support Team Members to the Internal Project Group since Group Member is
a setup object hence used future to insert.
Used in     : Core_IPS_IntelSupportTeam_Dispatcher
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi                        23/04/2018              Created
****************************************************************************************************/    
    @future
    public static void insertGroupMember(String listGroupMemberStr){
        List<GroupMember> listGroupMembers = (List<GroupMember>)JSON.deserialize(listGroupMemberStr, List<GroupMember>.class);
        if(listGroupMembers!=null && listGroupMembers.size()>0){
            insert listGroupMembers;
        }
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 23 April 2018
UserStory    : US102838
Input Parameters: 
Output Parameters: None
Transactions: After Insert
Description: This method is used to Remove Intel Support Team Members from the Internal Project Group since Group Member is
a setup object hence used future to insert.
Used in     : Core_IPS_IntelSupportTeam_Dispatcher
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi                        27/04/2018              Created
****************************************************************************************************/    
    @future
    public static void delGroupMember(String listGroupMemberStr){
        List<GroupMember> listGroupMembers = (List<GroupMember>)JSON.deserialize(listGroupMemberStr, List<GroupMember>.class);
        if(listGroupMembers!=null && listGroupMembers.size()>0){
            delete listGroupMembers;
        }
    }
    /***************************************************************************************************
Version     : 1.0 
Created Date: 27 April 2018
UserStory    : US102838
Input Parameters: 
Output Parameters: None
Transactions: After Update
Description: This method is used to Add/Remove Intel Support Team Members to the Internal Project Group based on their status
Used in     : Core_IPS_IntelSupportTeam_Dispatcher
Number of Queries Within this Method: 
Number of Queries in Loop: 0
Number of Queries from Called methods:
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi                        23/04/2018              Created
****************************************************************************************************/ 
    public static void manageGroupMembers(List<Core_IPS_Intel_Support_Team__c>  newList,MAp<Id,Core_IPS_Intel_Support_Team__c>  oldMap){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('internalProjectGroup'))        { return;}
        try{
            List<Id> projId=new List<Id>();
            String listGroupMemberStr,listGroupMemberStr1; 
            List<Core_IPS_Intel_Support_Team__c> istMemberListAdd=new List<Core_IPS_Intel_Support_Team__c>();
            List<Core_IPS_Intel_Support_Team__c> istMemberListRemove=new List<Core_IPS_Intel_Support_Team__c>();
            Map<Id,Core_IPS_Project__c> projMap=new Map<Id,Core_IPS_Project__c>();
            if(newList!=null && newList.size()>0){
                for(Core_IPS_Intel_Support_Team__c istMem: newList){
                    if(istMem.Status__c!=oldMap.get(istMem.Id).Status__c){
                        projId.add(istMem.Core_IPS_Project__c);
                        if(istMem.Status__c=='Active'){
                            istMemberListAdd.add(istMem);   
                        }
                        
                        else if(istMem.Status__c=='Inactive'){
                            istMemberListRemove.add(istMem);   
                        }
                    }
                } 
                //Avoid Deeply Nested IF Statements Kamala
                if((projId!=null && projId.size()>0) &&(Core_IPS_Project__c.SObjectType.getDescribe().isAccessible())){
                        projMap = new Map<Id,Core_IPS_Project__c>([Select id,name,Core_IPS_InternalGroupId__c,Core_IPS_Unique_Project_Number__c from Core_IPS_Project__c where id IN: projId ]);
                }   
                if(istMemberListAdd!=null && istMemberListAdd.size()>0){
                    List<GroupMember> listGroupMembersToInsert= new List<GroupMember>();
                    for(Core_IPS_Intel_Support_Team__c istMember:istMemberListAdd){
                        String GroupId=projMap.get(istMember.Core_IPS_Project__c).Core_IPS_InternalGroupId__c;
                        GroupMember GM = new GroupMember();
                        GM.GroupId = GroupId;
                        GM.UserorGroupId = istMember.Core_IPS_User__c;
                        listGroupMembersToInsert.add(GM);
                    }  
                    if(!listGroupMembersToInsert.isEmpty()){
                        listGroupMemberStr = JSON.serialize(listGroupMembersToInsert);
                        insertGroupMember(listGroupMemberStr);
                    }         
                }
                if(istMemberListRemove!=null && istMemberListRemove.size()>0){
                    List<Id> GroupIdList=new List<Id>();
                    List<iD> UserIdList=new List<Id>();
                    List<GroupMember> listGroupMembersToRemove= new List<GroupMember>();
                    for(Core_IPS_Intel_Support_Team__c istMember:istMemberListRemove){
                        GroupIdList.add(projMap.get(istMember.Core_IPS_Project__c).Core_IPS_InternalGroupId__c);
                        UserIdList.add(istMember.Core_IPS_User__c);
                    }
                    if(GroupIdList.size()>0 && UserIdList.size()>0 ){
                        listGroupMembersToRemove=[Select Id from GroupMember where GroupId In :GroupIdList AND UserorGroupId In :UserIdList];  
                    }
                    
                    if(listGroupMembersToRemove!=null && listGroupMembersToRemove.size()>0){
                        listGroupMemberStr1 = JSON.serialize(listGroupMembersToRemove);
                        delGroupMember(listGroupMemberStr1);
                    }
                }
                
            }
        }catch(Exception ex){ }
    }
    /***************************************************************************************************
Version     : 1.0 
Created Date: 27 April 2018
UserStory    : US102838
Input Parameters: 
Output Parameters: None
Transactions: After Update
Description: This method is used to Add/Remove Intel Support Team Members to the Internal Project Group based on their status
Used in     : Core_IPS_IntelSupportTeam_Dispatcher
Number of Queries Within this Method: 
Number of Queries in Loop: 0
Number of Queries from Called methods:
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi                        23/04/2018              Created
****************************************************************************************************/     
    public static void removeGroupMembers(List<Core_IPS_Intel_Support_Team__c>  oldList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('internalProjectGroup'))        { return;}
        try{
            List<Id> projId=new List<Id>();
            Map<Id,Core_IPS_Project__c> projMap=new Map<Id,Core_IPS_Project__c>();
            String listGroupMemberStr1;
            if(oldList!=null && oldList.size()>0){
                for(Core_IPS_Intel_Support_Team__c ist:oldList){
                    projId.add(ist.Core_IPS_Project__c);   
                }
                if(projId!=null && projId.size()>0){
                    projMap = new Map<Id,Core_IPS_Project__c>([Select id,name,Core_IPS_InternalGroupId__c,Core_IPS_Unique_Project_Number__c from Core_IPS_Project__c where id IN: projId ]);
                }
                List<Id> GroupIdList=new List<Id>();
                List<iD> UserIdList=new List<Id>();
                List<GroupMember> listGroupMembersToRemove= new List<GroupMember>();
                for(Core_IPS_Intel_Support_Team__c istMember:oldList){
                    GroupIdList.add(projMap.get(istMember.Core_IPS_Project__c).Core_IPS_InternalGroupId__c);
                    UserIdList.add(istMember.Core_IPS_User__c);
                }
                if(GroupIdList.size()>0 && UserIdList.size()>0 ){
                    listGroupMembersToRemove=[Select Id from GroupMember where GroupId In :GroupIdList AND UserorGroupId In :UserIdList];  
                }
                if(listGroupMembersToRemove!=null && listGroupMembersToRemove.size()>0){
                    listGroupMemberStr1 = JSON.serialize(listGroupMembersToRemove);
                    delGroupMember(listGroupMemberStr1);
                }
            }    
        }catch(Exception ex){}
        
    }   
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 23 May 2018
Input Parameters: 
Transactions: After Insert
Description : This method is used to add the Intel Support Team to Case Internal Interested parties from
the Project. 
Used in     : Core_IPS_Project_Dispatcher

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rakesh Marka                   23/05/2018              User Story--US107411 
* Aayushi Singhal				15/02/2019			 Modified DE32193
****************************************************************************************************/  
    
    // Method to insert a record in InterestedParties using Intel Support Team
    public static void interestedParties_IntelSupportTeam(List<Core_IPS_Intel_Support_Team__c> newList) {
        Map<Id,Core_IPS_Project__c> mapIST2ProjectId;
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('interestedParties_IntelSupportTeam'))
            return;
        
        Set<Id> setProjectId = new Set<Id>();
        List<Core_IPS_Case_Interested_Party__c> interestedPartyList= new List<Core_IPS_Case_Interested_Party__c>();
        if(newList!=null && newList.size()>0){  
            for(Core_IPS_Intel_Support_Team__c cp : newList){ 
                //setProjectId.add(cp.Id); commented by karthick - 28/05/2018
                setProjectId.add(cp.Core_IPS_Project__c); //Added by karthick - 28/05/2018 
            }
        }
        if(setProjectId!=null && setProjectId.size()>0){
            if(Contact.SObjectType.getDescribe().isAccessible()){
                mapIST2ProjectId = new Map<Id,Core_IPS_Project__c>([SELECT Id, Core_IPS_Enable_ISTasInterested_Parties__c FROM Core_IPS_Project__c WHERE Core_IPS_Enable_ISTasInterested_Parties__c=true AND Id IN :setProjectId]);     
            }
        if(mapIST2ProjectId!=null && mapIST2ProjectId.size()>0){
            //start modification for DE32193
           // List<case> lstCase = new List<Case>([SELECT Id from Case WHERE Core_IPS_Project_Case__c IN :mapIST2ProjectId.keySet() and Status!='Closed']);
            interestedPartyList=createInterestedParty(mapIST2ProjectId.keySet());
            if(interestedPartyList!=null && interestedPartyList.size()>0){
                System.enqueueJob(new Core_IPS_insertInterestedPartyQueueable(interestedPartyList));
            }//end DE32193
        }  
    }
    }
    
    // insert Internal Interested party
    public static void insertInterestedParty(List<Core_IPS_Intel_Support_Team__c> lstIntelSupportTeam, List<Case> lstCase) {
        //Modified for DE29283 to avoid timeout
       // System.enqueueJob(new Core_IPS_insertInterestedPartyQueueable(lstIntelSupportTeam,lstCase));
        
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 11 JUNE 2018
Input Parameters: 
Transactions: before Update
Description: This method is used to remove the Intel Support Team users from the case interested parties when the status of the 
user is inactive

Used in     : Core_IPS_IntelSupportTeam_Dispatcher

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rakesh Marka                   11/06/2018              User Story--US107411 
****************************************************************************************************/  
    
    // Removing Interested parties using intel support team status 
    public static void removeRelatedIpsOnStatusChangeForIST(List<Core_IPS_Intel_Support_Team__c> intelSupportTeamList,Map<Id,Core_IPS_Intel_Support_Team__c> oldMap){
        List<case> cistList = new List<case>();
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('removeRelatedIpsOnStatusChangeForIST'))
        {return;}
        
        set<Id> project_map=new set<Id>();     
        Map<id,id> caseMap=new Map<id,id>();
        List<Core_IPS_Case_Interested_Party__c> cipListToBeInserted = new List<Core_IPS_Case_Interested_Party__c>();    
        if(intelSupportTeamList.size()>0){          
            for(Core_IPS_Intel_Support_Team__c cp:intelSupportTeamList){  
                if(oldMap.get(cp.id).Status__c!=cp.Status__c && cp.Status__c=='Inactive'){ 
                    project_map.add(cp.Core_IPS_Project__c);
                    cp.Add_as_Case_Interested_Party__c=false;
                }else if(oldMap.get(cp.id).Add_as_Case_Interested_Party__c  !=cp.Add_as_Case_Interested_Party__c && cp.Add_as_Case_Interested_Party__c==true && oldMap.get(cp.id).Status__c==cp.Status__c && cp.Status__c=='Inactive' ){
                    cp.addError('Cannot enable as Interested Parties when status is Inactive');
                }       
            }
            
        }
        if(project_map.size()>0){
            if(Case.SObjectType.getDescribe().isAccessible()){
                cistList=[select id,CaseNumber,Core_IPS_Project_Case__c from case where Core_IPS_Project_Case__c In:project_map and status!='closed'];      
            }
            if(cistList.size()>0){ 
                for(Core_IPS_Intel_Support_Team__c intelNewList:intelSupportTeamList){     
                    for(case caseList:cistList){   
                        if(caseList.Core_IPS_Project_Case__c==intelNewList.Core_IPS_Project__c){          
                            caseMap.put(caseList.id,intelNewList.Core_IPS_User__c);
                        } 
                    }  
                } 
            } 
        }
        if(caseMap.size()>0 && caseMap!=null){
            delete [select id from Core_IPS_Case_Interested_Party__c where Case__c in : caseMap.keySet() and User__c in:caseMap.values() and Core_IPS_Project_Interested_Party__c=true];
            
        }
        
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 11 JUNE 2018
Input Parameters: 
Transactions: before Update
Description: This method is used add the Intel Support Team to interested parties when the Add_as_Case_Interested_Party__c is checked

Used in     : Core_IPS_IntelSupportTeam_Dispatcher

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rakesh Marka                   13/06/2018              User Story--US107411
* Aayushi Singhal				 15/02/2019				 DE32193
****************************************************************************************************/  
    
    
    // Add_as_Case_Interested_Party__c is checked in Intel support team then add it to the interested Party  
    // Don’t enable Add_as_Case_Interested_Party__c  in Intel Support Team if associated user is not Active.  
    public static void create_InterestedParty_using_checkBox(List<Core_IPS_Intel_Support_Team__c> intelSupportTeamList,Map<Id,Core_IPS_Intel_Support_Team__c> oldMap) {    
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('create_InterestedParty_using_checkBox'))
        {return;}
        Map<Id,Id> project_Map=new Map<Id,Id>();         
        List<case> lstCase =new List<case>();
        List<Core_IPS_Case_Interested_Party__c> cipListToBeInserted = new List<Core_IPS_Case_Interested_Party__c>();  
        Map<Id,Core_IPS_Intel_Support_Team__c> istMap;
        Set<Id> projIdSet=new Set<Id>();
        List<Core_IPS_Case_Interested_Party__c> internalIPList=new List<Core_IPS_Case_Interested_Party__c>();   //created for DE32193
        
        //start modification for DE32193
        if(intelSupportTeamList!=null && intelSupportTeamList.size()>0){ 
            istMap= new Map<Id,Core_IPS_Intel_Support_Team__c>([Select Id,Core_IPS_User__c,Core_IPS_User__r.IsActive,Status__c from Core_IPS_Intel_Support_Team__c where Id In: intelSupportTeamList]);
            if(istMap!=null && istMap.size()>0){
                for(Core_IPS_Intel_Support_Team__c cp:intelSupportTeamList){
                    if(cp.Add_as_Case_Interested_Party__c!=oldMap.get(cp.Id).Add_as_Case_Interested_Party__c && cp.Add_as_Case_Interested_Party__c){
                        if(!istMap.get(cp.Id).Core_IPS_User__r.IsActive){
                            cp.addError('Cannot enable as Interested Parties when User is Not Active');
                        }
                        else if(cp.Status__c=='Inactive'){
                            cp.addError('Cannot enable as Interested Parties when Status is Not Active');
                        }
                        else{                     
                            //project_Map.put(cp.Core_IPS_Project__c,cp.id);
                            projIdSet.add(cp.Core_IPS_Project__c);       
                        }  
                    }
                }
            }
        }
        
       /* if(project_Map.size()>0 && project_Map!=null){
            lstCase = new List<Case>([SELECT Id from Case WHERE Core_IPS_Project_Case__c IN :project_Map.keySet() and Status!='Closed' ]);
        } 
        
        if(lstCase.size()>0){
            insertInterestedParty(intelSupportTeamList, lstCase);
        }  */            
        if(projIdSet!=null && projIdSet.size()>0){
          internalIPList=Core_IPS_IntelSupportTeam_Handler.createInterestedParty(projIdSet);  
        } 
        System.enqueueJob(new Core_IPS_insertInterestedPartyQueueable(internalIPList));
        //end DE32193
    }
    
    /***************************************************************************************************
    Version     : 1.0 
    Input Parameters: List, Map
    Transactions: before update
    Description: This method is to remove ISO from project and Case if IST is inactivated
    Used in     : Core_IPS_IntelSupportTeam_Dispatcher
    Number of Queries Within this Method: 2
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    09/05/2018             Created(US137508)
    ****************************************************************************************************/   
    public static void RemoveISO(List<Core_IPS_Intel_Support_Team__c> newList, Map<Id, Core_IPS_Intel_Support_Team__c> oldMap) {
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('removeISOonProject')) {return;}
        
        String inactiveStatus = Core_IPS_Helper_Utility.getIPSLabel('CoreStatus_Inactive'); 
        Map<Id,Core_IPS_Project__c> mapProjectId2RemoveISO = new Map<Id,Core_IPS_Project__c>();
        Map<Id,Set<Id>> mapProjectId2RemovedISO4Case = new Map<Id,Set<Id>>();
        List<Case> lstCase2RemoveISO = new List<Case>();

        Set<Id> setProjectId = new Set<Id>();
        for(Core_IPS_Intel_Support_Team__c objIST : newList) {
            setProjectId.add(objIST.Core_IPS_Project__c);
        }
        Map<Id,Core_IPS_Project__c> mapProject = new Map<Id,Core_IPS_Project__c>([SELECT Id,Core_IPS_Intel_Support_Owner__c FROM Core_IPS_project__c WHERE Id IN :setProjectId]);        
        for(Core_IPS_Intel_Support_Team__c objIST : newList) {
            
            if(
               (Trigger.isUpdate && objIST.Status__c!=oldMap.get(objIST.Id).Status__c && objIST.Status__c==inactiveStatus)
               ||
               (Trigger.isDelete)
            )
            {
                if(mapProject.containsKey(objIST.Core_IPS_Project__c) && objIST.Core_IPS_User__c==mapProject.get(objIST.Core_IPS_Project__c).Core_IPS_Intel_Support_Owner__c)
                    mapProjectId2RemoveISO.put(objIST.Core_IPS_Project__c, new Core_IPS_Project__c(Id=objIST.Core_IPS_Project__c, Core_IPS_Intel_Support_Owner__c=null));
                
                if(!mapProjectId2RemovedISO4Case.containsKey(objIST.Core_IPS_Project__c)) {
                    mapProjectId2RemovedISO4Case.put(objIST.Core_IPS_Project__c, new Set<Id>());                    
                }
                mapProjectId2RemovedISO4Case.get(objIST.Core_IPS_Project__c).add(objIST.Core_IPS_User__c);
            }            
        }
        if(Case.SObjectType.getDescribe().isAccessible()){
        for(Case objCase : [SELECT Id,Core_Intel_Sup_Owner__c,Core_IPS_Project_Case__c FROM Case WHERE Core_IPS_Project_Case__c IN :mapProjectId2RemovedISO4Case.KeySet() AND Status IN ('New','Open')]) {
            if(mapProjectId2RemovedISO4Case.get(objCase.Core_IPS_Project_Case__c).contains(objCase.Core_Intel_Sup_Owner__c)) {
                objCase.Core_Intel_Sup_Owner__c = null;
                lstCase2RemoveISO.add(objCase);
            } 
        }           
        }
        if(mapProjectId2RemoveISO.size()>0) update mapProjectId2RemoveISO.values();            
        if(lstCase2RemoveISO.size()>0) update lstCase2RemoveISO;
    }
    
/***************************************************************************************************
    Version     : 1.0 
    Input Parameters: List
    Transactions: before insert
    Description: This method is to make 'Add to Case Interested Parties' set if 'Enable IST as Interested Parties' is checked on Project
    Used in     : Core_IPS_IntelSupportTeam_Dispatcher
    Number of Queries Within this Method: 1
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Aayushi                    07/01/2018             Created(DE18984)
    ****************************************************************************************************/ 
    public static void setAddToCaseIP(List<Core_IPS_Intel_Support_Team__c> newList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('setAddToCaseIP')) {return;} 
        
        try{
            Set<Id> listISTProj=new Set<Id>();
            for(Core_IPS_Intel_Support_Team__c ist: newList){
                listISTProj.add(ist.Core_IPS_Project__c);  
            }
            if(listISTProj!=null && listISTProj.size()>0){
                Map<Id,Core_IPS_Project__c> mapProj= new Map<Id,Core_IPS_Project__c>([Select Id,Core_IPS_Enable_ISTasInterested_Parties__c from Core_IPS_Project__c where Id In: listISTProj]);
                
                for(Core_IPS_Intel_Support_Team__c ist: newList){
                    if(mapProj.get(ist.Core_IPS_Project__c).Core_IPS_Enable_ISTasInterested_Parties__c){
                        ist.Add_as_Case_Interested_Party__c=true;   
                    }
                    
                }  
            }
        }catch(Exception ex){}
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 14 Feb 2019
Input Parameters: Set of Project Id
Transactions: 
Description : This method is used to create Interested Party records but is not inserted in database, 
			  records are inserted in Queueable class
Used in     : Core_IPS_Project_Handler, Core_IPS_IntelSupportTeam_Handler

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi Singhal             14/02/2019       		 DE32193
****************************************************************************************************/ 
    
    public static List<Core_IPS_Case_Interested_Party__c> createInterestedParty(Set<Id> projIdSet) {
        List<Core_IPS_Intel_Support_Team__c> istList=new List<Core_IPS_Intel_Support_Team__c>();
        Map<Id,List<Core_IPS_Intel_Support_Team__c>> projISTMap=new Map<Id,List<Core_IPS_Intel_Support_Team__c>>();
        Map<Id,List<Case>> projCaseMap=new Map<Id,List<Case>>();
        List<Core_IPS_Case_Interested_Party__c> internalIPListToBeInserted = new List<Core_IPS_Case_Interested_Party__c>();
        List<case> caseList =new List<case>();
        Set<String> setExistingIP = new Set<String>();
       
        if(projIdSet!=null && projIdSet.size()>0){
            if(Core_IPS_Intel_Support_Team__c.SObjectType.getDescribe().isAccessible()){
                istList=[Select Id,Core_IPS_User__c,Add_as_Case_Interested_Party__c,Core_IPS_Project__c,Status__c FROM Core_IPS_Intel_Support_Team__c WHERE Core_IPS_Project__c IN :projIdSet AND Status__c='Active' AND Core_IPS_User__r.IsActive=true and Add_as_Case_Interested_Party__c=true]; 
            }
            if(Core_IPS_Intel_Support_Team__c.SObjectType.getDescribe().isAccessible()){
                caseList=[Select Id,Core_IPS_Project_Case__c from Case WHERE Core_IPS_Project_Case__c IN :projIdSet and Status!='Closed' ];
            }
            if(caseList!=null && caseList.size()>0){
                for(Case cs: caseList){
                    if(!projCaseMap.containsKey(cs.Core_IPS_Project_Case__c)){
                    projCaseMap.put(cs.Core_IPS_Project_Case__c,new List<Case>());
                    }
                    projCaseMap.get(cs.Core_IPS_Project_Case__c).add(cs);   
                }
            }
            if(istList!=null && istList.size()>0){
                for(Core_IPS_Intel_Support_Team__c ist: istList){
                    if(!projISTMap.containsKey(ist.Core_IPS_Project__c)){
                        projISTMap.put(ist.Core_IPS_Project__c,new List<Core_IPS_Intel_Support_Team__c>());
                    }
                    projISTMap.get(ist.Core_IPS_Project__c).add(ist);
                }
            }
            if(Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isAccessible()){
                //  Added by Chiru - 20-08-24 - APEX GURU - SOQL FIX
                Map<Id, case> caseListMap = new Map<Id, case>();
                if(caseList!=null && caseList.size()>0){
                    caseListMap = new Map<Id, case>(caseList);
                }
                for(Core_IPS_Case_Interested_Party__c objIP : [SELECT Id,User__c,Case__c FROM Core_IPS_Case_Interested_Party__c WHERE Case__c IN :caseListMap.keyset()]) {
            setExistingIP.add(objIP.User__c + ';' + objIP.Case__c);
                }
            }
            for(Id projId: projIdSet){
                if(projISTMap!=null && projISTMap.get(projId)!=null){
                    for(Core_IPS_Intel_Support_Team__c objIST : projISTMap.get(projId)){
                            if(projCaseMap!=null && projCaseMap.get(projId)!=null){
                                for(Case objCase : projCaseMap.get(projId)) {
                                    if(setExistingIP.contains(objIST.Core_IPS_User__c + ';' + objCase.Id)) continue;
                                    Core_IPS_Case_Interested_Party__c cip = new Core_IPS_Case_Interested_Party__c();                
                                    cip.User__c = objIST.Core_IPS_User__c;
                                    cip.Case__c = objCase.Id;
                                    cip.Type__c = 'Internal';
                                    cip.Active__c = true;
                                    cip.Core_IPS_Project_Interested_Party__c = true;
                                    internalIPListToBeInserted.add(cip);
                                    
                                }  
                            } 
                    }
                }
            }
        }
        if(internalIPListToBeInserted!=null && internalIPListToBeInserted.size()>0){
        return internalIPListToBeInserted;    
        }
        else{
            return null;
        }
          
    }
}