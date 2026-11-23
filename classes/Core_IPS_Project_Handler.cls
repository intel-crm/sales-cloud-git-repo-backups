public class Core_IPS_Project_Handler{
    

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
*Aayushi                     11/07/2017              Modified
*Sugandha                    10/05/2018              Modified(UserStory US104746 Iteration 11)
****************************************************************************************************/   
    public static void PreventDelete(List<Core_IPS_Project__c> oldList){
        /*added by Aayushi 07-11-2017 US79852*/
        Core_IPS_Labels__c IpsLabels = Core_IPS_Labels__c.getValues('CoreStatus_Draft');
        String status=IpsLabels.Value__c;
        if(oldList<> null && oldList.size()>0){
            //List<Core_IPS_Project__c> ProjectList = [Select id,Core_Status__c from Core_IPS_Project__c where id IN: oldList];
            Map<Id,Core_IPS_Project__c> ProjectMap = new Map<Id,Core_IPS_Project__c>([Select id,Core_Status__c from Core_IPS_Project__c where id IN: oldList]); 
            system.debug('project - Map'+ProjectMap);
            if(ProjectMap <> null && ProjectMap.size()>0){
                for(Core_IPS_Project__c Project: oldList){
                    system.debug('project - id'+Project.id);
                    system.debug('Project - Status'+Project.Core_Status__c);
                    /*Modified by Aayushi 2-11-17 US79852*/
                    if(ProjectMap.get(Project.id).Core_Status__c <> status)
                        Project.adderror('Cannot delete this when status is Submitted Pending or Active');
                }
            }     
        }
    }
    
    //Used for creating public group for project and stamping group id on project.
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
    public static void ManagePublicGroups(List<Core_IPS_Project__c> newList){
        if(newList!=null && newList.size()>0){          
            List<Core_IPS_Project__c> projListToInsert = new List<Core_IPS_Project__c>();
            String label=Core_IPS_Helper_Utility.getIPSLabel('ProjectGroupPrefix');
            List<Group> groupList = new List<Group>();
            List<Id> projIdList = new List<Id>();
            for(Core_IPS_Project__c proj: newList){
                projIdList.add(proj.id);
            }
            List<Core_IPS_Project__c> projList = [Select id,name,Core_IPS_GroupId__c,Core_IPS_Unique_Project_Number__c,Core_IPS_Group_Name__c from Core_IPS_Project__c where id IN: projIdList ];
            if(projList <> null && projList.size()>0){
                for(Core_IPS_Project__c project: projList){
                    if(project.Core_IPS_GroupId__c == null || project.Core_IPS_GroupId__c == ''){
                        Group grp = new Group();
                        if(project.name <> null){
                            grp.name = project.Core_IPS_Unique_Project_Number__c; 
                            //Added the below line by kishore on 4/21  for the DE19807 
                            grp.doesIncludeBosses = false; 
                        }
                        groupList.add(grp);
                    }
                }
                if(groupList <> null && groupList.size() > 0)
                    insert groupList;
                for(Core_IPS_Project__c project: projList){
                    for(Group grp: groupList){
                        String projectName;
                        if(project.name <> null){
                            projectName = project.Core_IPS_Unique_Project_Number__c;
                        }
                        if((project.Core_IPS_GroupId__c == null || project.Core_IPS_GroupId__c == '') && (grp.name == projectName)){
                            project.Core_IPS_GroupId__c = grp.id;
                            project.Core_IPS_Group_Name__c = grp.name;
                            //pr
                        }
                    }
                    projListToInsert.add(project);
                }
                if(projListToInsert <> null && projListToInsert.size() > 0){
                    update projListToInsert;
                } 
            }            
        }
    }
    
    
    //Used for sharing and unsharing projects with the public group.
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
* Aayushi                    20/12/2017              Modified
* Aayushi                    25/04/2018              Modified
****************************************************************************************************/
    public static void externalProjectAccessControl(Map<Id,Core_IPS_Project__c> oldMap,List<Core_IPS_Project__c> newList){
        Map<Id,Id> grantAccessRecords = new Map<Id,Id>();
        Map<Id,Id> grantInternalAccessRecords = new Map<Id,Id>();       //added by Aayushi to share projects with Intel Support Team US102838
        Map<Id,Id> revokeAccessRecords = new Map<Id,Id>();
        for(core_ips_project__c project: newList){
            if(project.Core_Status__c=='Active' && oldMap.get(project.id).Core_Status__c!='Active'){
                grantAccessRecords.put(project.id,project.Core_IPS_GroupId__c);
            }
            //start added by Aayushi to share projects with Intel Support Team US102838
            if(project.Core_IPS_InternalGroupId__c!=null){
            grantInternalAccessRecords.put(project.id,project.Core_IPS_InternalGroupId__c);
            } //end
            /* commented by Aayushi US90170*/
            /*   if(project.Core_Status__c=='Inactive' && oldMap.get(project.id).Core_Status__c=='Active'){
revokeAccessRecords.put(project.id,project.Core_IPS_GroupId__c);
}*/
        }
        if(grantAccessRecords.size()>0)
            /*Changes made by Raj Kommera as part of defect fix  DE34809,Changed access from read to edit*/
            core_sharingUtility.provideAccess('Core_IPS_Project__c','Core_IPS_Project__Share','Edit',grantAccessRecords);
        if(revokeAccessRecords.size()>0){}
        core_sharingUtility.revokeAccess('Core_IPS_Project__c','Core_IPS_Project__Share',revokeAccessRecords);
        //start added by Aayushi to share projects with Intel Support Team US102838
        if(grantInternalAccessRecords.size()>0){
            core_sharingUtility.provideAccess('Core_IPS_Project__c','Core_IPS_Project__Share','Edit',grantInternalAccessRecords);
        } //end
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 08 Mar 2015
Function    : Recalculates Sharing for owner id change
Input Parameters: oldMap,newList
Output Parameters: None
Transactions: After Update
Description: This method is used to recalculate Sharing when Owner ID is changed
Used in     : Core_IPS_Account_Dispatcher
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/07/2015              Created
****************************************************************************************************/
    public static void recalculateSharing(Map<Id,Core_IPS_Project__c> oldMap,List<Core_IPS_Project__c> newList){
        Map<Id,Id> grantAccessRecords = new Map<Id,Id>();
        Map<Id,Id> grantInternalAccessRecords = new Map<Id,Id>();
        List<Id> projectIdList;
        for(Core_IPS_Project__c project: newList){
            projectIdList = new List<Id>();
            if(oldMap.get(project.id).OwnerId <> project.OwnerId){
                projectIdList.add(project.id);
                if(project.Core_Status__c=='Active')
                    grantAccessRecords.put(project.id,project.Core_IPS_GroupId__c);  
                if(project.Core_IPS_InternalGroupId__c!=null){
                    grantInternalAccessRecords.put(project.id,project.Core_IPS_InternalGroupId__c);  
                }
            }
        }       
        List<Core_IPS_Account__c> accountJOList = [Select id,Core_Account__c,Core_Status__c,Core_IPS_Project__c from Core_IPS_Account__c where Core_IPS_Project__c IN: projectIdList];  
        system.debug('acc jo &&&&&&'+accountJOList);
        if(accountJOList <> null && accountJOList.size()>0)
            Core_IPS_Account_Handler.addAccountFAEtoProject(accountJOList);
        if(grantAccessRecords.size()>0)
            core_sharingUtility.provideAccess('Core_IPS_Project__c','Core_IPS_Project__Share','Read',grantAccessRecords);
        if(grantInternalAccessRecords.size()>0){
            core_sharingUtility.provideAccess('Core_IPS_Project__c','Core_IPS_Project__Share','Edit',grantInternalAccessRecords);
        }
    }
    
    
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
*
***************************************************************************************************/ 
    /*Commented by Sugandha for US104746 
    public static void DuplicateRecordprevention(List<Core_IPS_Project__c> newList){
        if(newList <> null && newList.size()>0){
            List<Core_IPS_Project__c> ExistingProjects = [Select id,Name from Core_IPS_Project__c];
            if(ExistingProjects <> null && ExistingProjects.size()>0){
                for(Core_IPS_Project__c NewProject: newList){
                    for(Core_IPS_Project__c ExistingProject: ExistingProjects){
                        if(ExistingProject.Name == NewProject.Name)
                            NewProject.adderror('The Project Name is already in use. Please choose another');                
                    }
                }
            }
        }
    }*/
    /***************************************************************************************************
Version     : 1.0 
Created Date: 07 Nov 2017
Feature#    : F7876
UserStory#  : US79853
Input Parameters: oldMap,newList,newMap
Output Parameters: None
Transactions: Before Update, After Update
Description: This method is used to change the status of the project to submitted pending
Used in     : Core_IPS_Project_Dispatcher
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods:0
Number of times called: Twice for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi                     11/11/2017             Created
* Aayushi                    11/03/2017              Modified
***************************************************************************************************/ 
    public static void activateProject(Map<Id,Core_IPS_Project__c> oldMap, List<Core_IPS_Project__c> newList,Map<Id,Core_IPS_Project__c> newMap){
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('activateProject'))
            return;
        try{
            String draftStatus,activeStatus,inactiveStatus,submitPStatus,spToActiveError,projProdMemError,privateProject_activateError;
            List<Core_IPS_Labels__c> IpsLabelList = Core_IPS_Labels__c.getall().values();
            draftStatus = Core_IPS_Helper_Utility.getIPSLabel('CoreStatus_Draft'); 
            activeStatus = Core_IPS_Helper_Utility.getIPSLabel('CoreStatus_Active'); 
            inactiveStatus = Core_IPS_Helper_Utility.getIPSLabel('CoreStatus_Inactive'); 
            submitPStatus = Core_IPS_Helper_Utility.getIPSLabel('CoreStatus_SP');
            spToActiveError = Core_IPS_Helper_Utility.getIPSLabel('CoreStatus_SPtoActive_Error');
            projProdMemError = Core_IPS_Helper_Utility.getIPSLabel('Core_OneProjProdMem_Error'); 
            privateProject_activateError = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_PrivateProj_ActivateError');           //added for US258266
            List<Core_IPS_Product__c> UpdateIPSProductList = new List<Core_IPS_Product__c>();
            List<Core_IPS_Project__c> projectList = [select id, Name, core_status__c, Core_Number_of_Accounts__c, Core_Number_of_Products__c,Core_Number_of_Users__c,core_ips_Private__c, (Select id,Status__c,Core_IPS_IsAutoApprove__c, Core_Supported_Product__c, Core_Supported_Product__r.Core_Flag_Status__c, Core_IPS_Project__c,Core_IsSubmitted_Header__c from IPS_Products__r) from core_ips_project__c where id IN :newList]; 
            //start added for US258266
            List<PermissionSetAssignment> permissionSetId=new List<PermissionSetAssignment>();
            permissionSetId= [Select AssigneeId,Assignee.Name,Assignee.ProfileId,PermissionSet.Name,PermissionSetId FROM PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() AND  PermissionSetId =: System.Label.Core_IPS_SupportOrgAdmin_Permission_Set];
            //end
            
            if(projectList <> null && projectList.size()>0 && draftStatus!=null && activeStatus!=null && inactiveStatus!=null && submitPStatus!=null && spToActiveError!=null && projProdMemError!=null){
                for(Core_IPS_Project__c project: projectList){
                    
                    Core_IPS_Project__c oldProject =  oldMAp.get(project.Id);
                    Core_IPS_Project__c newProject =  newMap.get(project.Id);
                    
                    if(Trigger.isBefore){
                        if((oldProject.Core_Status__c==draftStatus ||oldProject.Core_Status__c==inactiveStatus) && newProject.Core_Status__c==activeStatus){                       
                            //added If Else for US258266
                            if(project.core_ips_Private__c && !(permissionSetId.size()>0||System.Label.Core_IPS_Support_Org_Admin_Profileid.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15)) || System.Label.Core_IPS_AdminAndSupport_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15)) || System.Label.Core_IPS_Data_Migration_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15)))){
                                NewProject.adderror(privateProject_activateError);    
                            }
                            
                            else{
                            NewProject.core_status__c = submitPStatus;
                        }
                        }
                        if(!Core_IPS_Project_Controller.checkCodeChange && oldProject.Core_Status__c==submitPStatus && newProject.Core_Status__c==activeStatus){
                            NewProject.adderror(spToActiveError); 
                        }
                    }
                    if(Trigger.isAfter){
                        if((oldProject.Core_Status__c==draftStatus||oldProject.Core_Status__c==inactiveStatus) && newProject.Core_Status__c==submitPStatus){
                            if(NewProject.Core_Number_of_Accounts__c == 0 || NewProject.Core_Number_of_Products__c ==0 || NewProject.Core_Number_of_Users__c == 0){
                                NewProject.addError( projProdMemError);
                            } 
                            
                            for(Core_IPS_Product__c IPSProductRecord: project.IPS_Products__r){
                                IPSProductRecord.Core_IsSubmitted_Header__c = true;
                                //modified IF and added OR condition by Aayushi US105154
                                if(IPSProductRecord.Core_Supported_Product__r.Core_Flag_Status__c == 'Auto Approve' || IPSProductRecord.Core_Supported_Product__r.Core_Flag_Status__c == 'General (ALL Access!)'){
                                    IPSProductRecord.Core_IPS_IsAutoApprove__c = true;
                                    IPSProductRecord.Status__c = 'Auto Approve';
                                }
                                UpdateIPSProductList.add(IPSProductRecord);
                                
                            }        
                        }
                    } 
                }
                if(Trigger.isAfter){
                    update UpdateIPSProductList;
                    
                }
                
            }
        }
        catch(Exception e){
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'Project', 'Core_IPS_Project_Handler');System.debug('Core_IPS_Project_Handler-->activateProject-->Exception--->'+e.getMessage()+'At Line Number-->'+e.getLineNumber());}
    }  
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 20 April 2018
Feature#    : 
UserStory#  : US102838
Input Parameters: newList
Output Parameters: None
Transactions: 
Description: This method is used to create a Project group for Intel Support Team Members
Used in     : Core_IPS_Project_Dispatcher and 
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods:0
Number of times called: once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi                     20/04/2018             Created US102838
***************************************************************************************************/  
    public static void internalProjectGroup(List<Core_IPS_Project__c> newList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('internalProjectGroup'))        { return;}
        if(newList!=null && newList.size()>0){          
            List<Core_IPS_Project__c> projListUpdate = new List<Core_IPS_Project__c>();
            String label=Core_IPS_Helper_Utility.getIPSLabel('ProjectGroupPrefixInternal');
            List<Group> groupList = new List<Group>();
            List<Id> projIdList = new List<Id>();
            for(Core_IPS_Project__c proj: newList){
                projIdList.add(proj.id);
            }
            List<Core_IPS_Project__c> projList = [Select id,name,Core_IPS_InternalGroupId__c,Core_IPS_Unique_Project_Number__c from Core_IPS_Project__c where id IN: projIdList ];
            if(projList <> null && projList.size()>0){
                for(Core_IPS_Project__c proj: projList){
                    if(proj.Core_IPS_InternalGroupId__c==null || proj.Core_IPS_InternalGroupId__c==''){
                        Group grp = new Group();
                        if(proj.name <> null){
                            grp.name = label+proj.Core_IPS_Unique_Project_Number__c; 
                            grp.doesIncludeBosses = false; 
                        }
                        groupList.add(grp);
                    }
                }
                if(groupList <> null && groupList.size() > 0){
                    insert groupList;
                    
                }
                
                for(Core_IPS_Project__c proj: projList){
                    
                    for(Group grp: groupList){
                        String groupName;
                        if(proj.name != null){
                            groupName = label+proj.Core_IPS_Unique_Project_Number__c;
                        }
                        if((proj.Core_IPS_InternalGroupId__c == null || proj.Core_IPS_InternalGroupId__c == '') && (grp.name == groupName)){
                            proj.Core_IPS_InternalGroupId__c = grp.id;
                        }
                    }
                    
                    projListUpdate.add(proj);
                }
                if(projListUpdate!=null && projListUpdate.size()>0){
                    System.debug('projListUpdate-->'+projListUpdate);
                    update projListUpdate;
                }
            } 
        }
    }
    
 /***************************************************************************************************
    Version     : 1.0 
    Created Date: 24/04/2018
    Function    : 
    Input Parameters: List
    Output Parameters: None
    Transactions: After Insert
    Description: This method is used When a single Account exists on a Project, it should not be possible to 
                 enter text in the MPNDA field and then save the record if the Account does not have a CNDA on 
                 its Account record.                  
    Used in     : Core_IPS_Account_Dispatcher
    Number of Queries Within this Method: 1 
    Number of Queries in Loop: 0
    Number of Queries from Called methods:0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Aayushi                        24/04/2018         Created - US103460
    ****************************************************************************************************/    
    public static void preventMPNDAforNonNDAAccount(List<Core_IPS_Project__c> newList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('preventMPNDAforNonNDAAccount')) {return;}
        if(newList!=null && newList.size()>0){
            List<Id> projId=new List<Id>();
            Core_IPS_Labels__c ipsLabels = Core_IPS_Labels__c.getValues('Core_IPS_MPNDAValue_Error');
            String mpndaError=ipsLabels.Value__c;
            List<Core_IPS_Account__c> accList=new List<Core_IPS_Account__c>();
            for(Core_IPS_Project__c proj: newList){
                projId.add(proj.Id);
            }
            if(projId!=null && projId.size()>0){
             accList=[Select Id,Core_IPS_Project__c,Core_Account__r.Core_CNDA_Number__c from Core_IPS_Account__c where Core_IPS_Project__c In :projId];
            }
            if(accList!=null && accList.size()>0){
                for(Core_IPS_Project__c proj: newList){
                for(Core_IPS_Account__c acc: accList) {
                    if(proj.Core_MPNDA__c!=null && (acc.Core_Account__r.Core_CNDA_Number__c==null || acc.Core_Account__r.Core_CNDA_Number__c=='') &&  !System.Label.Core_IPS_Data_Migration_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15))){
                     proj.addError(mpndaError);   
                    }
                } 
                }
            }
        }
        
    } 

 /***************************************************************************************************
    Version     : 1.0 
    Created Date: 23/05/2018
    Function    : 
    Input Parameters: List
    Output Parameters: None
    Transactions: After Update
    Description: This method is used Whenever the enable interested parties checkoxs on the Project is checked then the respective checkbox related members or IST
                 will be added to the interested parties.          
    Used in     : Core_IPS_Project_Dispatcher
    Number of Queries Within this Method: 1 
    Number of Queries in Loop: 0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Rakesh Marka                        23/05/2018         Created - US80116 
    * Rakesh Marka                        11/06/2018         Modified- US107411
    * Aayushi Singhal                     15/02/2019         Modified DE32193
    ****************************************************************************************************/    
    //Method to add interested parties record based on checkbox check 
    public static void insertRecord_InterestedParties(List<Core_IPS_Project__c> newList,Map<Id,Core_IPS_Project__c> oldMap){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('insertRecord_InterestedParties')) { return;}
        
        //System.debug('Project  handler insertRecord_InterestedParties'+UserInfo.getName());
        Set<Id> setProjectforIST = new Set<Id>();
        Set<Id> setProjectforProjMember = new Set<Id>();   
        set<Id> setProjectforProjMemberDisabled=new Set<Id>(); 
        set<Id> setProjectforISTDisabled=new Set<Id>();  
        //start added for DE32193
        List<Core_IPS_Case_Interested_Party__c> internalIPList=new List<Core_IPS_Case_Interested_Party__c>();
        List<Core_IPS_Case_Interested_Party__c> externalIPList=new List<Core_IPS_Case_Interested_Party__c>();
        List<Core_IPS_Case_Interested_Party__c> IPList=new List<Core_IPS_Case_Interested_Party__c>();
        //end
        
        if(newList.size()>0){
            
            for(Core_IPS_Project__c proj:newList){   
                if(oldMap.get(proj.Id).Core_IPS_EnableMemberasInterestedParties__c!=proj.Core_IPS_EnableMemberasInterestedParties__c && proj.Core_IPS_EnableMemberasInterestedParties__c==true){ 
                    setProjectforProjMember.add(proj.Id);
                }else if(oldMap.get(proj.Id).Core_IPS_EnableMemberasInterestedParties__c!=proj.Core_IPS_EnableMemberasInterestedParties__c && proj.Core_IPS_EnableMemberasInterestedParties__c==false){
                    setProjectforProjMemberDisabled.add(proj.Id); 
                }
                if(oldMap.get(proj.Id).Core_IPS_Enable_ISTasInterested_Parties__c!=proj.Core_IPS_Enable_ISTasInterested_Parties__c && proj.Core_IPS_Enable_ISTasInterested_Parties__c==true){   
                    setProjectforIST.add(proj.Id);
                }else if(oldMap.get(proj.Id).Core_IPS_Enable_ISTasInterested_Parties__c!=proj.Core_IPS_Enable_ISTasInterested_Parties__c && proj.Core_IPS_Enable_ISTasInterested_Parties__c==false){
                    setProjectforISTDisabled.add(proj.Id);
                }
            }
            
            
            if(setProjectforIST.size()>0) {
                List<Core_IPS_Intel_Support_Team__c> enableintelsupportMemberList=new List<Core_IPS_Intel_Support_Team__c>();
                //Commented for DE32193
               //List<case> lstCase = new List<Case>([SELECT Id from Case WHERE Core_IPS_Project_Case__c IN :setProjectforIST and Status!='Closed']);    
                List<Core_IPS_Intel_Support_Team__c> lstIntelSupportTeam = new List<Core_IPS_Intel_Support_Team__c>([SELECT Id,Core_IPS_User__c,Add_as_Case_Interested_Party__c,Core_IPS_Project__c,Status__c FROM Core_IPS_Intel_Support_Team__c WHERE Core_IPS_Project__c IN :setProjectforIST AND Status__c='Active' AND Core_IPS_User__r.IsActive=true]); //update by amritesh - DE18983 - 03/09/2018
                for(Core_IPS_Intel_Support_Team__c intelsupportMemList:lstIntelSupportTeam) {               
                    intelsupportMemList.Add_as_Case_Interested_Party__c=true;
                    //intelsupportMemList.Status__c='Active'; 
                    enableintelsupportMemberList.add(intelsupportMemList); 
                }
                Core_IPS_IntelSupportTeam_Dispatcher.ISTUpdatedfromProject=true;
                update enableintelsupportMemberList;
                //start modified DE32193
                //Core_IPS_IntelSupportTeam_Handler.create_InterestedParty_using_checkBox(lstIntelSupportTeam , null);
                internalIPList=Core_IPS_IntelSupportTeam_Handler.createInterestedParty(setProjectforIST);
                //end
            }
            if(setProjectforISTDisabled.size()>0 && setProjectforISTDisabled!=null){
                List<Core_IPS_Intel_Support_Team__c> disableintelsupportMemberList=new List<Core_IPS_Intel_Support_Team__c>();            
                List<Core_IPS_Intel_Support_Team__c> lstIntelSupportTeam = new List<Core_IPS_Intel_Support_Team__c>([SELECT Id,Core_IPS_User__c,Add_as_Case_Interested_Party__c,Core_IPS_Project__c,Status__c FROM Core_IPS_Intel_Support_Team__c WHERE Core_IPS_Project__c IN :setProjectforISTDisabled]);
                for(Core_IPS_Intel_Support_Team__c intelsupportMemList:lstIntelSupportTeam){
                    intelsupportMemList.Add_as_Case_Interested_Party__c=false;
                    //intelsupportMemList.Status__c='Active'; 
                    disableintelsupportMemberList.add(intelsupportMemList); 
                }
                update disableintelsupportMemberList;
            }
            
            if(setProjectforProjMember.size()>0) {
                List<Core_IPS_Project_Member__c> projectMemberToUpdate=new List<Core_IPS_Project_Member__c>();
               //Commented for DE32193
               // List<case> lstCase = new List<Case>([SELECT Id from Case WHERE Core_IPS_Project_Case__c IN :setProjectforProjMember and Status!='Closed']);
                List<Core_IPS_Project_Member__c> lstProjMember = new List<Core_IPS_Project_Member__c>([SELECT Id,Core_IPS_Contact__c,Core_User__c,Add_as_Case_Interested_Party__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__c IN :setProjectforProjMember AND Core_IPS_Contact__r.Core_IPS_Active__c=true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c=false AND Core_Status__c='Active' AND Core_User__r.IsActive=true]); //update by amritesh - DE18977 - 03/09/2018
                for(Core_IPS_Project_Member__c projMemList:lstProjMember){                  
                    projMemList.Add_as_Case_Interested_Party__c=true;
                    //projMemList.Core_Status__c='Active'; 
                    projectMemberToUpdate.add(projMemList);
                } 
                Core_IPS_Project_Member_Dispatcher.ProjMemUpdatedfromProject=true;
                update projectMemberToUpdate;
                // start modified DE32193
               // Core_IPS_Project_Member_Handler.insertInterestedParty(lstProjMember, lstCase);
               externalIPList=Core_IPS_Project_Member_Handler.createInterestedParty(setProjectforProjMember);
                //end
                                
            }
            if(setProjectforProjMemberDisabled.size()>0 && setProjectforProjMemberDisabled!=null){
                List<Core_IPS_Project_Member__c> disabledProjMemList=new List<Core_IPS_Project_Member__c>();
                List<Core_IPS_Project_Member__c> lstProjMember = new List<Core_IPS_Project_Member__c>([SELECT Id,Core_IPS_Contact__c,Core_User__c,Add_as_Case_Interested_Party__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__c IN :setProjectforProjMemberDisabled]);
                for(Core_IPS_Project_Member__c projMemList:lstProjMember){                  
                    projMemList.Add_as_Case_Interested_Party__c=false;
                    //projMemList.Core_Status__c='Active'; 
                    disabledProjMemList.add(projMemList);
                }
                update disabledProjMemList;
            }
            //start added DE32193
            if(externalIPList!=null && externalIPList.size()>0){
                IPList.addAll(externalIPList);
            }
            if(internalIPList!=null && internalIPList.size()>0){
                IPList.addAll(internalIPList);
            }
            if(IPList.size()>0){
                System.enqueueJob(new Core_IPS_insertInterestedPartyQueueable(IPList));
            }//end
        }
    }
/***************************************************************************************************
    Version     : 1.0 
    Created Date: 26/06/2018
    Function    : 
    Input Parameters: List
    Output Parameters: None
    Transactions: 
    Description: This method is used to update Project sharing for Private projects.          
    Used in     : Core_IPS_Project_Dispatcher
    Number of Queries Within this Method: 1 
    Number of Queries in Loop: 0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Aayushi                     02/11/2018         Created - US113701
    ****************************************************************************************************/    
    public static void updatePrivateProjectSharing(List<Core_IPS_Project__c> newList,Map<Id,Core_IPS_Project__c> oldMap){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updatePrivateProjectSharing')) {return;} 
        try{
        if(newList!=null && newList.size()>0 && oldMap!=null && oldMap.size()>0){
            Map<Id,Core_IPS_Project__c> removeProjSharing=new Map<Id,Core_IPS_Project__c>();
            List<Core_IPS_Project__c> projList=new List<Core_IPS_Project__c>();
            List<Id> projGroup=new List<Id>();
            for(Core_IPS_Project__c proj: newList){
                if(proj.Core_IPS_Private__c!=oldMap.get(proj.Id).Core_IPS_Private__c && proj.Core_IPS_Private__c){
                    removeProjSharing.put(proj.Id,proj);
                    if(proj.Core_IPS_GroupId__c!=null)
                    projGroup.add(proj.Core_IPS_GroupId__c);
                    if(proj.Core_IPS_InternalGroupId__c!=null)
                    projGroup.add(proj.Core_IPS_InternalGroupId__c);
                    
                }
                
                else if(proj.Core_IPS_Private__c!=oldMap.get(proj.Id).Core_IPS_Private__c && !proj.Core_IPS_Private__c){
                    projList.add(proj);
                }
            }
            
            if(projList!=null && projList.size()>0){
                List<Core_IPS_Account__c> projAccountList = [Select id,Core_Account__c,Core_Status__c,Core_IPS_Project__c from Core_IPS_Account__c where Core_IPS_Project__c IN: projList];  
                if(projAccountList <> null && projAccountList.size()>0)
                    Core_IPS_Account_Handler.addAccountFAEtoProject(projAccountList);
            }
            
            if(removeProjSharing!=null && removeProjSharing.size()>0){
                List<Core_IPS_Project__Share> projShare=[Select Id from Core_IPS_Project__Share where RowCause='Manual' and ParentId IN: removeProjSharing.keySet() and USerOrGroupId NOT IN: projGroup];    
                if(projShare!=null && projShare.size()>0){
                    Database.delete(projShare);
                }
            }
        }
        }catch(Exception e){System.debug('Exception-->'+e.getMessage()+e.getLineNumber());} 
    }
    
     /***************************************************************************************************
    Version     : 1.0 
    Created Date: 25/11/2018
    Function    : 
    Input Parameters: List
    Output Parameters: None
    Transactions: 
    Description: This method is used to add Private Project Owner to IST          
    Used in     : Core_IPS_Project_Dispatcher
    Number of Queries Within this Method: 1 
    Number of Queries in Loop: 0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Gourav                     15/11/2018         Created - US113672
    ****************************************************************************************************/    
    public static void addInternalProjOwnerToIST(List<Core_IPS_Project__c> newList,Map<Id,Core_IPS_Project__c> oldMap){
    
        if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('addInternalProjOwnerToIST')) {
            return;
        }
        try {
            List<Core_IPS_Intel_Support_Team__c> lstIST2Upsert = new List<Core_IPS_Intel_Support_Team__c>();
            List<Core_IPS_Project__c> projScopeList = new List<Core_IPS_Project__c>();
            Set<Id> ownerIDs = new Set<Id>();
            Map<Id, Set<Id>> mapActiveExistingOwnerIDs = new Map<Id, Set<Id>>();
            Map<Id, Map<Id, Core_IPS_Intel_Support_Team__c>> mapInactiveExistingOwnerIDs = new Map <Id, Map<Id, Core_IPS_Intel_Support_Team__c>>();
            Map<Id,User> mUser = new Map<Id,User>() ;                    
            
            //creating scope list for update as per condition
            for (Core_IPS_Project__c proj: newList) {
                if (proj.Core_IPS_Private__c == true && String.valueOf(proj.OwnerId).startsWith('005') && 
                    (oldMap == null || (oldMap != null && proj.Core_IPS_Private__c != oldMap.get(proj.Id).Core_IPS_Private__c) ||
                     (oldMap != null && proj.OwnerId != oldMap.get(proj.Id).OwnerId))) {
                         projScopeList.add(proj);
                         ownerIDs.add(proj.OwnerId);
                     }
            }
            
            List<String> userTypeList = new List<String>();
            //Getting internal users for IST Members addition based on UserType
            if (String.isNotBlank(Label.UserType_Standard)) {
                    userTypeList.add(Label.UserType_Standard);
            }
            mUser =new Map<Id,User>([SELECT Id FROM user WHERE usertype in: userTypeList and Id in: ownerIDs ]);
            
            if (projScopeList != null && projScopeList.size() > 0 && mUser != null && mUser.size()>0) {
                //Getting existing ProjOwner IDs to avoid duplicate addition of IST
                for (Core_IPS_Intel_Support_Team__c istMem: [Select Id, Core_IPS_Project__c, status__c, Core_IPS_User__c from Core_IPS_Intel_Support_Team__c where Core_IPS_User__c in: ownerIDs and Core_IPS_Project__c in: projScopeList]) {
                    System.debug('--------------------------->>>Inside IST list');
                    if (istMem.Status__c == 'Active') {
                        if (!mapActiveExistingOwnerIDs.containsKey(istMem.Core_IPS_Project__c)) {
                            mapActiveExistingOwnerIDs.put(istMem.Core_IPS_Project__c, new Set<Id>());
                        }
                        mapActiveExistingOwnerIDs.get(istMem.Core_IPS_Project__c).add(istMem.Core_IPS_User__c);
                        
                    } else {
                        //inactiveISTProjList.add(istMem);
                        if (!mapInactiveExistingOwnerIDs.containsKey(istMem.Core_IPS_Project__c)) {
                            mapInactiveExistingOwnerIDs.put(istMem.Core_IPS_Project__c, new Map <Id, Core_IPS_Intel_Support_Team__c>());
                        }
                        mapInactiveExistingOwnerIDs.get(istMem.Core_IPS_Project__c).put(istMem.Core_IPS_User__c, istMem);
                    }
                }
                
                for (Core_IPS_Project__c proj : projScopeList) {
                    if(mapActiveExistingOwnerIDs !=null && mapActiveExistingOwnerIDs.containsKey(proj.Id) && mapActiveExistingOwnerIDs.get(proj.Id).contains(proj.OwnerId)){
                        System.debug('>>> Owner Existing already as IST : ' + proj.OwnerId);
                        continue;
                    }
                    else if(mapInactiveExistingOwnerIDs !=null && mapInactiveExistingOwnerIDs.containsKey(proj.Id) && mapInactiveExistingOwnerIDs.get(proj.Id).containsKey(proj.OwnerId)) {
                        Core_IPS_Intel_Support_Team__c istUpdateRec = mapInactiveExistingOwnerIDs.get(proj.Id).get(proj.OwnerId);                                                             
                        istUpdateRec.Status__c = 'Active';
                        lstIST2Upsert.add(istUpdateRec);
                    } else {
                            Core_IPS_Intel_Support_Team__c istInsertRec = new Core_IPS_Intel_Support_Team__c();
                            istInsertRec.Core_IPS_Project__c = proj.id;
                            istInsertRec.Core_IPS_User__c = proj.OwnerId;
                            istInsertRec.Status__c = 'Active';
                            lstIST2Upsert.add(istInsertRec);
                                 
                    }
                }
                
            }
            if(lstIST2Upsert.size()>0){ 
                upsert lstIST2Upsert;
            }
            
        } catch (Exception e) {
            System.debug('Exception-->' + e.getMessage() + e.getLineNumber());
        }
        
    }
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 27/12/2018
    Function    : 
    Input Parameters: List
    Output Parameters: None
    Transactions: 
    Description: This method is used to add Default Case Owner on Private Project to IST during Project Activation         
    Used in     : Core_IPS_Project_Dispatcher
    Number of Queries Within this Method: 1 
    Number of Queries in Loop: 0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Aayushi                     11/01/2018         Created - US250915
    ****************************************************************************************************/
    public static void addDefaultCaseOwnerToIST(List<Core_IPS_Project__c> newList,Map<Id,Core_IPS_Project__c> oldMap){
        
        if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('addDefaultCaseOwnerToIST')) {
            return;
        }
        try {
        Set<Id> projId=new Set<Id>();
        List<Core_Ips_Product__c> projProdList=new List<Core_Ips_Product__c>();
        for(Core_IPS_Project__c proj: newList){
            if(oldMap.get(proj.Id).Core_Status__c!=proj.Core_Status__c && proj.Core_Status__c=='Active' && proj.Core_IPS_Private__c){
             projId.add(proj.Id);   
            }
        }
        if(projId!=null && projId.size()>0){
         projProdList=[Select Id,Core_IPS_Product_Case_Owner__c,Core_IPS_Project__c from Core_Ips_Product__c where Core_IPS_Project__c In: projId] ;
            if(projProdList!=null && projProdList.size()>0){
                Core_IPS_ProductTriggerHandler.addDefaultCaseOwnerToIST(projProdList, null);
            }   
        }
            
    }
    catch (Exception e) {
            System.debug('Exception-->' + e.getMessage() + e.getLineNumber());
        }
    }
}