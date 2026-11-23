/**************************************************************************************
Apex Class Name : Core_Batch_A_E_PermSet_Mgmt
Version     : 1.0 
Created Date: 12th March 2020
Description : Utility class assign and remove permission set
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Vaibhav                  12/03/2020             Original Version
* Subhadeep                25/02/2022             Draco team changes made for multiple P set assignment for single entitlement
*************************************************************************************/
global without sharing class Core_Batch_A_E_PermSet_Mgmt implements Database.Batchable<sObject>, Database.Stateful{
    global List<Core_Entitlement__c> lstEntitlementDetails;  
    global Map<String,List<String>> mapPermissionsetEntitlement = new Map<String,List<String>>();
    global Set<String> setEntitlementName = new Set<String>(); 
    global Set<String> setPSName = new Set<String>();
    global Set<String> setPGName = new Set<String>();
    global List<String> lstPSLabel = new List<String>();
    global List<String> lstPGLabel = new List<String>();
    global Map<String,Integer> mapInsertPScount = new Map<String,Integer>();
    global Map<String,Integer> mapDeletePScount = new Map<String,Integer>();   
    global Map<String,String> mapPermissionSetNameId = new Map<String,String>();
    global Map<String,String> mapPermissionSetNameLabel = new Map<String,String>();
    global Map<String,String> mapPSNamePGName = new Map<String,String>();
    global Map<String,String> mapEntitlePGName = new Map<String,String>();
    global Map<String,String> mapPublicGroupNameId = new Map<String,String>();
    global Map<String,String> mapPublicGroupNameLabel = new Map<String,String>();   
    global Map<String,Integer> mapInsertPGcount = new Map<String,Integer>();
    global Map<String,Integer> mapDeletePGcount = new Map<String,Integer>();  
    global DateTime dtWhen;
    global Core_Batch_A_E_PermSet_Mgmt(){
        dtWhen = system.now();
        entDataFormation();
    }
    global Database.QueryLocator start(Database.BatchableContext BC){   
        String queryUser = 'SELECT Id, Name, ContactId, Contact.Name, CreatedDate FROM User WHERE IsActive = TRUE AND Profile.Name = \'Partner\' AND ContactId IN (SELECT Core_Contact_Id__c FROM Core_Contact_Entitlement__c WHERE Core_Entitlement_Id__r.Core_Display_Name__c = : setEntitlementName AND Core_Status__c = \'Complete\' AND Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c != null)';   
        return Database.getQueryLocator(queryUser);
    }
    global void execute(Database.BatchableContext BC, List<User> lstUserRecords){
        Set<Id> setUserContactId = new Set<Id>();
        Map<String,String> mapUserContact = new Map<String,String>();
        Map<String,String> mapContactIdUserId = new Map<String,String>();
        List<PermissionSetAssignment> lstPSAInsert = new List<PermissionSetAssignment>();
        List<GroupMember> lstGMInsert = new List<GroupMember>();
        List<Id> lstPSADelete = new List<Id>();
        List<Id> lstGMDelete = new List<Id>();
        for(User usr : lstUserRecords){
            setUserContactId.add(usr.ContactId);
            mapUserContact.put(usr.Id, usr.ContactId);
            mapContactIdUserId.put(usr.ContactId, usr.Id);
        }
        List<Core_Contact_Entitlement__c> lstContactEntitlement = [SELECT 
                                                                   Core_Contact_Id__c, Core_Selected__c, 
                                                                   Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c, 
                                                                   Core_Entitlement_Id__r.Core_Public_Group_API_Nm__c,
                                                                   Core_Entitlement_Id__r.Core_Display_Name__c 
                                                                   FROM Core_Contact_Entitlement__c 
                                                                   WHERE Core_Contact_Id__c =: setUserContactId 
                                                                   AND Core_Entitlement_Id__r.Core_Display_Name__c =: setEntitlementName 
                                                                   AND Core_Status__c = 'Complete'
                                                                   AND Core_Selected__c = True 
                                                                   AND Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c != null];
        //Need map of contact and permission set needed
        Map<string,Set<string>> mapExpectedUserPermissionSet = new Map<string,Set<string>>();
        Map<string,Set<string>> mapExpectedUserPublicGroup = new Map<string,Set<string>>();
        for(Core_Contact_Entitlement__c ent : lstContactEntitlement){       
            if(mapExpectedUserPermissionSet.containskey(mapContactIdUserId.get(ent.Core_Contact_Id__c))){
                //------START-----Changes made for multiple P set assignment for single entitlement
                //mapExpectedUserPermissionSet.get(mapContactIdUserId.get(ent.Core_Contact_Id__c)).add(ent.Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c);
                mapExpectedUserPermissionSet.get(mapContactIdUserId.get(ent.Core_Contact_Id__c)).addAll(ent.Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c.split(';'));
                //------END-----Changes made for multiple P set assignment for single entitlement
            }
            else{
                Set<String> setPSName = new Set<String>();
                //------START-----Changes made for multiple P set assignment for single entitlement
                //setPSName.add(ent.Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c);
                setPSName.addAll(ent.Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c.split(';'));
                //------END-----Changes made for multiple P set assignment for single entitlement
                mapExpectedUserPermissionSet.put(mapContactIdUserId.get(ent.Core_Contact_Id__c), setPSName);
            } 
            //Public Group Expected Map
            if(ent.Core_Entitlement_Id__r.Core_Public_Group_API_Nm__c != null){
                if(mapExpectedUserPublicGroup.containskey(mapContactIdUserId.get(ent.Core_Contact_Id__c))){
                    mapExpectedUserPublicGroup.get(mapContactIdUserId.get(ent.Core_Contact_Id__c)).addAll(ent.Core_Entitlement_Id__r.Core_Public_Group_API_Nm__c.split(';'));                    
                }
                else{
                    Set<String> setPGName = new Set<String>();
                    //setPGName.add(ent.Core_Entitlement_Id__r.Core_Public_Group_API_Nm__c);
                    setPGName.addAll(ent.Core_Entitlement_Id__r.Core_Public_Group_API_Nm__c.split(';'));
                    mapExpectedUserPublicGroup.put(mapContactIdUserId.get(ent.Core_Contact_Id__c), setPGName);                    
                }
            }            
        }   
        //Map of user and permission set from existing PSA records
        List<PermissionSetAssignment> lstUserPSA = [SELECT Id,AssigneeId, PermissionSetId, PermissionSet.Name 
                                                    FROM PermissionSetAssignment 
                                                    WHERE AssigneeId =:  mapUserContact.keySet()];
        Map<string,Set<string>> mapAssignedUserPermissionSet = new Map<string,Set<string>>();
        Map<String,String> mapUserIdPermissionId = new Map<String,String>();
        //Map of User and Permission Sets assigned from existing PSA records
        for(PermissionSetAssignment psa : lstUserPSA){
            if(mapAssignedUserPermissionSet.containskey(psa.AssigneeId)){
                mapAssignedUserPermissionSet.get(psa.AssigneeId).add(psa.PermissionSet.Name);           
            }
            else{
                Set<String> setPSName = new Set<String>();
                setPSName.add(psa.PermissionSet.Name);
                mapAssignedUserPermissionSet.put(psa.AssigneeId, setPSName);
            }
            mapUserIdPermissionId.put(psa.PermissionSetId + '_PSA_' + psa.AssigneeId,psa.Id);
        }
        //Map of User and Public group from existing Group Member records
        List<GroupMember> lstGroupMember = [SELECT Id, GroupId, UserOrGroupId, Group.DeveloperName  
                                            FROM GroupMember
                                            WHERE UserOrGroupId =: mapUserContact.keySet()
                                            AND Group.DeveloperName =: mapPublicGroupNameId.keySet()];
        Map<string,Set<string>> mapAssignedUserPublicGroup = new Map<string,Set<string>>();
        Map<String,String> mapUserIdGroupMemberId = new Map<String,String>();
        for(GroupMember gpMember : lstGroupMember){
            if(mapAssignedUserPublicGroup.containskey(gpMember.UserOrGroupId)){
                mapAssignedUserPublicGroup.get(gpMember.UserOrGroupId).add(gpMember.Group.DeveloperName);           
            }
            else{
                Set<String> setPGName = new Set<String>();
                setPGName.add(gpMember.Group.DeveloperName);
                mapAssignedUserPublicGroup.put(gpMember.UserOrGroupId, setPGName);
            }
            mapUserIdGroupMemberId.put(gpMember.GroupId + '_GM_' + gpMember.UserOrGroupId,gpMember.Id);
        }
 
        Integer count;
        Integer countDelete;
        for(User usr : lstUserRecords){
            //Create records for PS assignment
            if(mapExpectedUserPermissionSet.containsKey(usr.Id)){
                for(string psName: mapExpectedUserPermissionSet.get(usr.Id)){
                    //Check for PS
                    if(mapAssignedUserPermissionSet.containsKey(usr.Id)){
                        if(!mapAssignedUserPermissionSet.get(usr.Id).contains(psName)){
                            //create PSA
                            PermissionSetAssignment psa = new PermissionSetAssignment();
                            psa.AssigneeId = usr.Id;
                            psa.PermissionSetId = mapPermissionSetNameId.get(psName);
                            lstPSAInsert.add(psa);
                            if(mapInsertPScount.containsKey(psName)){
                                count = mapInsertPScount.get(psName) + 1;                                                           
                                mapInsertPScount.remove(psName);
                                mapInsertPScount.put(psName, count);                               
                            }                            
                        }           
                    }
                    else{
                        //Create PSA for user
                        PermissionSetAssignment psa = new PermissionSetAssignment();
                        psa.AssigneeId = usr.Id;
                        psa.PermissionSetId = mapPermissionSetNameId.get(psName);
                        lstPSAInsert.add(psa);
                        if(mapInsertPScount.containsKey(psName)){
                            count = mapInsertPScount.get(psName) + 1;                                                            
                            mapInsertPScount.remove(psName);
                            mapInsertPScount.put(psName, count);
                        }
                    }
                }
            }
            //Get records for PS Removal
            if(mapAssignedUserPermissionSet.containsKey(usr.Id)){
                for(string psName: mapAssignedUserPermissionSet.get(usr.Id)){
                    if(mapExpectedUserPermissionSet.containsKey(usr.Id) && !mapExpectedUserPermissionSet.get(usr.Id).contains(psName)){                       
                        if(mapPermissionSetNameId.containsKey(psName) && mapUserIdPermissionId.containsKey(mapPermissionSetNameId.get(psName) + '_PSA_' + usr.Id)){                    
                            lstPSADelete.add(mapUserIdPermissionId.get(mapPermissionSetNameId.get(psName) + '_PSA_' + usr.Id));
                            if(mapDeletePScount.containsKey(psName)){
                                countDelete = mapDeletePScount.get(psName) + 1;                                                         
                                mapDeletePScount.remove(psName);
                                mapDeletePScount.put(psName, countDelete);
                            }
                        }                      
                    } 
                    else if(!mapExpectedUserPermissionSet.containsKey(usr.Id) && mapPermissionSetNameId.containsKey(psName) && mapUserIdPermissionId.containsKey(mapPermissionSetNameId.get(psName) + '_PSA_' + usr.Id)){
                        lstPSADelete.add(mapUserIdPermissionId.get(mapPermissionSetNameId.get(psName) + '_PSA_' + usr.Id));
                        if(mapDeletePScount.containsKey(psName)){
                            countDelete = mapDeletePScount.get(psName) + 1;                                                         
                            mapDeletePScount.remove(psName);
                            mapDeletePScount.put(psName, countDelete);
                        }
                    }
                } 
            }
            //Create Records for Public Group Assignment
            if(mapExpectedUserPublicGroup.containsKey(usr.Id)){
                for(String sPGName : mapExpectedUserPublicGroup.get(usr.Id)){
                    if(mapAssignedUserPublicGroup.containsKey(usr.Id)){
                        if(!mapAssignedUserPublicGroup.get(usr.Id).contains(sPGName)){
                            //Create Group Member
                            GroupMember grpmem = new GroupMember();
                            grpmem.UserOrGroupId = usr.Id;
                            grpmem.GroupId = mapPublicGroupNameId.get(sPGName);
                            lstGMInsert.add(grpmem);
                            if(mapInsertPGcount.containsKey(sPGName)){
                                count = mapInsertPGcount.get(sPGName) + 1;                                                           
                                mapInsertPGcount.remove(sPGName);
                                mapInsertPGcount.put(sPGName, count);                               
                            }                            
                        }                        
                    }
                    else{
                        GroupMember grpmem = new GroupMember();
                        grpmem.UserOrGroupId = usr.Id;
                        grpmem.GroupId = mapPublicGroupNameId.get(sPGName);
                        lstGMInsert.add(grpmem);
                        if(mapInsertPGcount.containsKey(sPGName)){
                            count = mapInsertPGcount.get(sPGName) + 1;                                                           
                            mapInsertPGcount.remove(sPGName);
                            mapInsertPGcount.put(sPGName, count);                               
                        }    
                    }
                }
            }
            //Get Records for Public Group Removal
            if(mapAssignedUserPublicGroup.containsKey(usr.Id)){
                for(String sPGName : mapAssignedUserPublicGroup.get(usr.Id)){
                    if(mapExpectedUserPublicGroup.containsKey(usr.Id) && !mapExpectedUserPublicGroup.get(usr.Id).contains(sPGName)){
                        if(mapPublicGroupNameId.containsKey(sPGName) && mapUserIdGroupMemberId.containsKey(mapPublicGroupNameId.get(sPGName) + '_GM_' + usr.Id)){
                            lstGMDelete.add(mapUserIdGroupMemberId.get(mapPublicGroupNameId.get(sPGName) + '_GM_' + usr.Id)); 
                            if(mapDeletePGcount.containsKey(sPGName)){
                                countDelete = mapDeletePGcount.get(sPGName) + 1;                                                         
                                mapDeletePGcount.remove(sPGName);
                                mapDeletePGcount.put(sPGName, countDelete);
                            }
                        }
                    }
                    else if(!mapExpectedUserPublicGroup.containsKey(usr.Id) && mapPublicGroupNameId.containsKey(sPGName) && mapUserIdGroupMemberId.containsKey(mapPublicGroupNameId.get(sPGName)+'_GM_'+usr.Id)){
                        lstGMDelete.add(mapUserIdGroupMemberId.get(mapPublicGroupNameId.get(sPGName) + '_GM_' + usr.Id));
                        if(mapDeletePGcount.containsKey(sPGName)){
                            countDelete = mapDeletePGcount.get(sPGName) + 1;                                                         
                            mapDeletePGcount.remove(sPGName);
                            mapDeletePGcount.put(sPGName, countDelete);
                        }
                    }                    
                }
            }
        }
        //insert PS
        if(lstPSAInsert.size() > 0){                           
            List<Database.SaveResult> insertPSA = Database.insert(lstPSAInsert, false);
        }
        //Remove PS
        if(lstPSADelete.size() > 0){          
            Database.DeleteResult[] deletePSA = Database.delete(lstPSADelete,false); 
        }
        //Insert Group Member
        if(lstGMInsert.size() > 0){
            List<Database.SaveResult> insertGM = Database.insert(lstGMInsert, false);
        }
        //Remove Group Member
        if(lstGMDelete.size() > 0){
            Database.DeleteResult[] deleteGM = Database.delete(lstGMDelete,false); 
        }
    }
    global void finish(Database.BatchableContext BC){
        List<Core_Log_Entry__c> lstLogEntryRecords = createLogEntryRecords();
        List<Database.SaveResult> resultsCreateLogRecords = Database.insert(lstLogEntryRecords, false);
 
    }
    private List<Core_Log_Entry__c> createLogEntryRecords(){
        List<Core_Log_Entry__c> lstLogEntry = new List<Core_Log_Entry__c>();
        map<String,integer> mapInsertPSLabelCount = new map<String,integer>();
        map<String,integer> mapDeletePSLabelCount = new map<String,integer>();
        map<String,integer> mapInsertPGLabelCount = new map<String,integer>();
        map<String,integer> mapDeletePGLabelCount = new map<String,integer>();     
        String strAssignDetails;
        String strRemovalDetails;
        lstPSLabel.sort();
        lstPGLabel.sort();
        for(String psName : setPSName){
            if(mapInsertPScount.containsKey(psName) && mapPermissionSetNameLabel.containsKey(psName)){
                mapInsertPSLabelCount.put(mapPermissionSetNameLabel.get(psName),mapInsertPScount.get(psName));
            }
            if(mapDeletePScount.containsKey(psName) && mapPermissionSetNameLabel.containsKey(psName)){
                mapDeletePSLabelCount.put(mapPermissionSetNameLabel.get(psName),mapDeletePScount.get(psName));
            }
        }
        for(String pgName : setPGName){
            if(mapInsertPGcount.containsKey(pgName) && mapPublicGroupNameLabel.containsKey(pgName)){
                mapInsertPGLabelCount.put(mapPublicGroupNameLabel.get(pgName),mapInsertPGcount.get(pgName));
            }
            if(mapDeletePGcount.containsKey(pgName) && mapPublicGroupNameLabel.containsKey(pgName)){
                mapDeletePGLabelCount.put(mapPublicGroupNameLabel.get(pgName),mapDeletePGcount.get(pgName));
            }
        }
        for(String psLabel : lstPSLabel){
            if(mapInsertPSLabelCount.containsKey(psLabel)){
                if(strAssignDetails != null){
                    strAssignDetails = strAssignDetails + ' \r\n ' + psLabel + ': ' + mapInsertPSLabelCount.get(psLabel);
                }
                else
                {
                    strAssignDetails = 'List of Permission Sets -' + ' \r\n ' + psLabel + ': ' + mapInsertPSLabelCount.get(psLabel);
                }                
            }
            if(mapDeletePSLabelCount.containsKey(psLabel)){
                if(strRemovalDetails != null){
                    strRemovalDetails = strRemovalDetails + ' \r\n '+ psLabel + ': ' + mapDeletePSLabelCount.get(psLabel);
                }
                else
                {
                    strRemovalDetails = 'List of Permission Sets -' + ' \r\n ' + psLabel + ': ' + mapDeletePSLabelCount.get(psLabel);
                }
            }
        }
        strAssignDetails = strAssignDetails + '\r\n \r\n' + 'List of Public Groups-';
        strRemovalDetails = strRemovalDetails + '\r\n \r\n' + 'List of Public Groups-';
        for(String pgLabel : lstPGLabel){
            if(mapInsertPGLabelCount.containsKey(pgLabel)){
               strAssignDetails = strAssignDetails + ' \r\n ' + pgLabel + ': ' + mapInsertPGLabelCount.get(pgLabel); 
            } 
            if(mapDeletePGLabelCount.containsKey(pgLabel)){
                strRemovalDetails = strRemovalDetails + ' \r\n ' + pgLabel+': ' + mapDeletePGLabelCount.get(pgLabel);
            }
        }
        DateTime dtnow = system.now();
        decimal duration = ((dtnow.getTime())/1000) - ((dtWhen.getTime())/1000);
        // Create Assign log Entry
        Core_Log_Entry__c assignCLE = new Core_Log_Entry__c ();
        assignCLE.Core_Origin__c = 'A&E Batch for Assignment/Removal of Permission Set';
        assignCLE.Core_Project__c = 'A&E';
        assignCLE.Core_Scope__c = 'Permission Set assignment';
        assignCLE.Core_Severity__c = 'Information';
        assignCLE.Core_Message__c = 'Batch for permission set Assignment';
        assignCLE.Core_When__c = dtWhen;
        assignCLE.Core_Details__c = 'Duration: ' + duration + ' seconds\r\n  \r\n ' + strAssignDetails;
        lstLogEntry.add(assignCLE);
        // Create Removal log Entry
        Core_Log_Entry__c removalCLE = new Core_Log_Entry__c ();
        removalCLE.Core_Origin__c = 'A&E Batch for Assignment/Removal of Permission Set';
        removalCLE.Core_Project__c = 'A&E';
        removalCLE.Core_Scope__c = 'Permission Set Removal';
        removalCLE.Core_Severity__c = 'Information';
        removalCLE.Core_Message__c = 'Batch for permission set Removal';
        removalCLE.Core_When__c = dtWhen;
        removalCLE.Core_Details__c= 'Duration: ' + duration + ' seconds\r\n \r\n' + strRemovalDetails;
        lstLogEntry.add(removalCLE);        
        return(lstLogEntry);
    }
    private void entDataFormation(){
        lstEntitlementDetails = [SELECT Id, Core_Display_Name__c, 
                                 Core_Permission_Set_API_Nm__c,Core_Public_Group_API_Nm__c 
                                 FROM Core_Entitlement__c 
                                 WHERE Core_Permission_Set_API_Nm__c != null];     
        for(Core_Entitlement__c ent : lstEntitlementDetails){
            if(ent.Core_Permission_Set_API_Nm__c.contains(';')){
                for(String psAPIName : ent.Core_Permission_Set_API_Nm__c.split(';')){
                    if(mapPermissionsetEntitlement.containskey(psAPIName)){
                        mapPermissionsetEntitlement.get(psAPIName).add(ent.Core_Display_Name__c);
                        setEntitlementName.add(ent.Core_Display_Name__c);
                        setPSName.add(psAPIName);
                    }
                    else{
                        List<String> psNameList = new List<String>();
                        psNameList.add(ent.Core_Display_Name__c);
                        mapPermissionsetEntitlement.put(psAPIName, psNameList);
                        setEntitlementName.add(ent.Core_Display_Name__c);
                        setPSName.add(psAPIName);
                    }
                    if(ent.Core_Public_Group_API_Nm__c != null){
                        setPGName.addAll(ent.Core_Public_Group_API_Nm__c.split(';'));
                    }
                    mapInsertPScount.put(psAPIName,0);
                    mapDeletePScount.put(psAPIName,0);
                }
            } else{
                if(mapPermissionsetEntitlement.containskey(ent.Core_Permission_Set_API_Nm__c)){
                    mapPermissionsetEntitlement.get(ent.Core_Permission_Set_API_Nm__c).add(ent.Core_Display_Name__c);
                    setEntitlementName.add(ent.Core_Display_Name__c);
                    setPSName.add(ent.Core_Permission_Set_API_Nm__c);
                }
                else{
                    List<String> psNameList = new List<String>();
                    psNameList.add(ent.Core_Display_Name__c);
                    mapPermissionsetEntitlement.put(ent.Core_Permission_Set_API_Nm__c, psNameList);
                    setEntitlementName.add(ent.Core_Display_Name__c);
                    setPSName.add(ent.Core_Permission_Set_API_Nm__c);
                }
                if(ent.Core_Public_Group_API_Nm__c != null){
                    setPGName.addAll(ent.Core_Public_Group_API_Nm__c.split(';'));
                }
                mapInsertPScount.put(ent.Core_Permission_Set_API_Nm__c,0);
                mapDeletePScount.put(ent.Core_Permission_Set_API_Nm__c,0);
            } 
        }
        List<PermissionSet> lstPSforEntitlement = [SELECT Id, Name, Label FROM PermissionSet 
                                                   WHERE Name =: mapPermissionsetEntitlement.keySet()];
        for(PermissionSet ps : lstPSforEntitlement){
            if(!mapPermissionSetNameId.containsKey(ps.Name)){
                mapPermissionSetNameId.put(ps.Name, ps.Id);
            }
            if(!mapPermissionSetNameLabel.containsKey(ps.Name)){
                mapPermissionSetNameLabel.put(ps.Name, ps.Label);
            }
            if(!lstPSLabel.contains(ps.Label)){
                lstPSLabel.add(ps.Label);
            }
        }
        List<Group> lstPGforEntitlement = [SELECT Id, Name, DeveloperName 
                                           FROM Group where DeveloperName =: setPGName];
        for(Group gp : lstPGforEntitlement){
            if(!mapPublicGroupNameId.containsKey(gp.DeveloperName)){
                mapPublicGroupNameId.put(gp.DeveloperName, gp.Id);
            }
            if(!mapPublicGroupNameLabel.containsKey(gp.DeveloperName)){
                mapPublicGroupNameLabel.put(gp.DeveloperName, gp.Name);
            }
            if(!lstPGLabel.contains(gp.Name)){
                lstPGLabel.add(gp.Name);
            }
            mapInsertPGcount.put(gp.DeveloperName,0);
            mapDeletePGcount.put(gp.DeveloperName,0);
        }                    
    }
}