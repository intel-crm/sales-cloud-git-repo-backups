/**************************************************************************************
Apex Class Name : PMP_Batch_Group_Management
Version     : 1.0 
Created Date: 20th may, 2019
Description : Creating a public group(if not present) for partner account, adding the appropriate members to the group based on their 
contact entitlemnets and removing the members based contact entitlement removal 
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Raushan                  20/05/2019               Original Version
* Vaibhav                   14/06/2020              Refactored Code v2
* Manikanta 				10/07/2020				Refactored Code v3
* Akshay [Draco]            08/06/2022              Added logic to keep Membership Change Ind Flag to TRUE in case of any APEX Exception
*************************************************************************************/

public without sharing class PMP_Batch_Group_Management {
    
    static final String STR_COMPLETE = 'Complete';
    static final String CORE_MP_STR = System.Label.PMP_Group_Name_Prefix;
    //static final String ALL_PARTNERS_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_ODM;
    //static final String ALL_PARTNERS_NON_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_Non_ODM;
    static final String STR_PUBLIC_GROUP_ROOT = '<OPID>';
    /*This returns MP Contact Entitlement with OPID and Contact*****/  
    public static List<Core_Contact_Entitlement__c> getAllContactEntitlementwithOPID(Set<Id> setAllPartnerAccountsId, Set<String> setEntitlementNames){
    
        /******** Fetching MP entitlemet ids from custom label*********/
        //List<Core_Entitlement__c> lstEntitlementDetails = new List<Core_Entitlement__c>();
        
        /********Getting all contact entitlements for mp related entitlements and for allpartnercontact **********/
        List<Core_Contact_Entitlement__c> lstConEnts = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c, 
                                                                Core_Contact_Id__r.AccountId, Core_Selected__c, 
                                                                Core_Contact_Id__r.Core_IPA_One_Partner_Id__c, 
                                                                Core_Contact_Id__r.Core_IPA_Contact_Segment__c,
                                                        		Core_Entitlement_Id__r.Name
                                                                FROM Core_Contact_Entitlement__c
                                                               WHERE Core_Status__c = :STR_COMPLETE AND Core_Selected__c = true 
                                                               AND Core_Entitlement_Id__r.Name IN :setEntitlementNames 
                                                               AND Core_Contact_Id__r.Core_IPA_One_Partner_Id__c IN : setAllPartnerAccountsId];
        
        // System.debug('$$$lstConEnts'+lstConEnts);
        // System.debug('$$$setAllPartnerAccountsId'+setAllPartnerAccountsId);
        // System.debug('$$$STR_COMPLETE'+STR_COMPLETE);
        return lstConEnts;
    }
        
    /********Method for public Group Creation **********/
    public static List<Group> createPublicGroups(Set<String> publicGroupNameToBeAdded){
        List<Group> lstAllPublicGroup = new List<Group>();
        //List<String> lstGrpDevNames = new List<String>();
        List<Group> lstPublicGroupToBeInserted = new List<Group>();
        List<Group> lstQueriedGrps =new List<Group>();
        try
        {
            //Querying public group for group to be inserted
            lstAllPublicGroup =[SELECT Id,DeveloperName,Name FROM Group WHERE DeveloperName IN :publicGroupNameToBeAdded];
            Map<String, Group> mapDevNameToGroup = new Map<String, Group>();
            for(Group grp : lstAllPublicGroup){
                mapDevNameToGroup.put(grp.DeveloperName, grp);
            }
            
            for(String publicGroup : publicGroupNameToBeAdded){                
                if(!mapDevNameToGroup.containsKey(publicGroup)){
                    Group grp = new Group(); 
                    grp.Name = publicGroup; 
                    grp.DeveloperName  = publicGroup;
                    grp.DoesIncludeBosses = false;
                    lstPublicGroupToBeInserted.add(grp);
                } 
            }
            
            //Inserting public group
            if(lstPublicGroupToBeInserted !=  null && !lstPublicGroupToBeInserted.isEmpty()){
                system.debug('****lstPublicGroupToBeInserted***'+ lstPublicGroupToBeInserted.size());
                Database.saveResult[] srlist=Database.insert(lstPublicGroupToBeInserted, false);
            }
            
            //check if it hives error due to huge size
             lstQueriedGrps = [SELECT Id,DeveloperName,Name FROM Group where DeveloperName IN :publicGroupNameToBeAdded];
        }
        catch(Exception e){
            String exceptionMessage = e.getTypeName() + ': ' + e.getMessage() + ', ' + e.getStackTraceString();
        } 
        return lstQueriedGrps;
    }
	
    public static Map<String,Set<Id>> getPublicGroupExpectedMap(List<Core_Contact_Entitlement__c> lstMPConEnts, 
                                                                List<PMP_Public_Group_Management_Settings__c> lstActivePGMgmSettingsForAddition,
                                                                Map<Id,Id> mapConIdtoUsrId,List<Account> lstAllPartnerAccountScope ) {
        
        Map<String,Set<Id>> mapPGToUserExpectedForAddition = new Map<String,Set<Id>>();
                                                                    
        for(PMP_Public_Group_Management_Settings__c PGMgmsetting : lstActivePGMgmSettingsForAddition) {
        	for(Account acc : lstAllPartnerAccountScope) {
        		if(PGMgmsetting.PMP_Public_Group_Nm__c != NULL) {
        			String strGroupName = trimGroupName(PGMgmsetting.PMP_Public_Group_Nm__c.replace(STR_PUBLIC_GROUP_ROOT,acc.Id));
        			if(!mapPGToUserExpectedForAddition.containsKey(strGroupName)) {
        				mapPGToUserExpectedForAddition.put(strGroupName, new Set<ID>());
        			}
        		}   
        	}
        }
        
        for(PMP_Public_Group_Management_Settings__c PGMgmsetting : lstActivePGMgmSettingsForAddition) {
            for(Core_Contact_Entitlement__c conEnt: lstMPConEnts) {
                //if(!setInactiveIntelAccounts.contains(conEnt.Core_Contact_Id__r.AccountId)){
                    if(PGMgmsetting.PMP_Contributing_Entitlement_Nm__c == conEnt.Core_Entitlement_Id__r.Name && PGMgmsetting.PMP_Contributing_Field_API_Nm__c == null){
                        String strGroupName = trimGroupName(PGMgmsetting.PMP_Public_Group_Nm__c.replace(STR_PUBLIC_GROUP_ROOT,conEnt.Core_Contact_Id__r.Core_IPA_One_Partner_Id__c));
                        if(mapPGToUserExpectedForAddition.containsKey(strGroupName) && mapConIdtoUsrId.containsKey(conEnt.Core_Contact_Id__c)) {
                            //if(mapConIdtoUsrId.containsKey(conEnt.Core_Contact_Id__c)){
                            	mapPGToUserExpectedForAddition.get(strGroupName).add(mapConIdtoUsrId.get(conEnt.Core_Contact_Id__c)); 
                            //}
                        }
                    }
                       
                    if(PGMgmsetting.PMP_Contributing_Entitlement_Nm__c == conEnt.Core_Entitlement_Id__r.Name && PGMgmsetting.PMP_Contributing_Field_API_Nm__c != null){
                        if(conEnt.Core_Contact_Id__r.get(PGMgmsetting.PMP_Contributing_Field_API_Nm__c) != null && conEnt.Core_Contact_Id__r.get(PGMgmsetting.PMP_Contributing_Field_API_Nm__c).toString().contains(PGMgmsetting.PMP_Contributing_Field_Value_Txt__c)){
                        	String strGroupName = trimGroupName(PGMgmsetting.PMP_Public_Group_Nm__c.replace(STR_PUBLIC_GROUP_ROOT,conEnt.Core_Contact_Id__r.Core_IPA_One_Partner_Id__c));
                            if(mapPGToUserExpectedForAddition.containsKey(strGroupName) && mapConIdtoUsrId.containsKey(conEnt.Core_Contact_Id__c)) {
                                //if(mapConIdtoUsrId.containsKey(conEnt.Core_Contact_Id__c)){
                            		mapPGToUserExpectedForAddition.get(strGroupName).add(mapConIdtoUsrId.get(conEnt.Core_Contact_Id__c));
                                //}
                            }
                        }
                    }
                          
                //}
            }
        }
        return mapPGToUserExpectedForAddition;
    }
    
    //This returns a map of Contact Id and User Id
    public static Map<Id,Id> getconIdToUserIdMap(Set<Id> setAllPartnerAccId) {
        Map<Id,Id> mapConIdtoUsrId = new Map<Id,Id>();
        
        List<User> lstPartnerUser = [SELECT Id, Name, ContactId, AccountId, Core_IPA_One_Partner_Id__c, Contact.AccountId FROM User 
                                       WHERE Contact.Core_IPA_One_Partner_Id__c IN : setAllPartnerAccId AND Contact.Core_IPA_One_Partner_Id__c != null];
        
        for(User user : lstPartnerUser) {
            mapConIdtoUsrId.put(user.ContactId,user.Id);
        }
        return mapConIdtoUsrId;
    }
    
    public static void assignRemoveUserstoPublicGroups(List<Group> lstAllPublicGrps,Map<String,Set<Id>> mapPGToUserExpectedForAddition,Map<String,Set<Id>> mapPGToConExpectedForRemoval){
        
        Map<String, Id> mapGrpDevNameToGrpId = new Map<String, Id>();
        List<GroupMember> lstQueriedGrpsMembers = new List<GroupMember>();
        Map<String, Set<Id>>mapGroupToGroupMember = new Map<String, Set<Id>>();
        Map<Id, Set<GroupMember>> mapGroupIdToSetGrpMember = new Map<Id, Set<GroupMember>>();
        Map<Id, Set<GroupMember>> mapUserIdToGrpMember = new Map<Id, Set<GroupMember>>();
        List<GroupMember> lstDeleteGrpMembers = new List<GroupMember>();
        List<GroupMember> lstInsertGrpMembers = new List<GroupMember>();
        Set<GroupMember> setDeleteGrpMembers = new Set<GroupMember>();

        for(Group grp : lstAllPublicGrps){
            mapGrpDevNameToGrpId.put(grp.DeveloperName, grp.Id);
        }
        Set<Id> setUserIds = new Set<Id>();
        for(Set<Id> strGroupName : mapPGToUserExpectedForAddition.values()){
            setUserIds.addAll(strGroupName);
        }
        for(Set<Id> strGroupName : mapPGToConExpectedForRemoval.values()){
            setUserIds.addAll(strGroupName);
        }
        System.debug('$$$$userIDS'+setUserIds);
        if(mapPGToUserExpectedForAddition.keySet() != null && !mapPGToUserExpectedForAddition.keySet().isEmpty()) {
            lstQueriedGrpsMembers = [SELECT Id,GroupId,UserOrGroupID, Group.DeveloperName FROM GroupMember where Group.DeveloperName IN: mapPGToUserExpectedForAddition.keySet() OR UserOrGroupID IN:setUserIds];
        }
		
        System.debug('lstQueriedGrpsMembers*** ='+lstQueriedGrpsMembers);
        for(GroupMember grpMem : lstQueriedGrpsMembers) {
            System.debug('$$$$grpMem'+grpMem);
            mapGrpDevNameToGrpId.put(grpMem.Group.DeveloperName, grpMem.GroupId);
            if(mapGroupToGroupMember.containsKey(grpMem.Group.DeveloperName)){
                mapGroupToGroupMember.get(grpMem.Group.DeveloperName).add(grpMem.UserOrGroupID);    
            }
            else{
                mapGroupToGroupMember.put(grpMem.Group.DeveloperName , new set<Id>{grpMem.UserOrGroupID});                
            }

            if(mapGroupIdToSetGrpMember.containsKey(grpMem.GroupId)){
                mapGroupIdToSetGrpMember.get(grpMem.GroupId).add(grpMem);        
            }
            else{
                mapGroupIdToSetGrpMember.put(grpMem.GroupId, new Set<GroupMember>{grpMem});
            }

            if(mapUserIdToGrpMember.containsKey(grpMem.UserOrGroupID)){
                mapUserIdToGrpMember.get(grpMem.UserOrGroupID).add(grpMem);
            }
            else{
                mapUserIdToGrpMember.put(grpMem.UserOrGroupID, new Set<GroupMember>{grpMem});
            } 
        }

        //check logic to assign users to groups
        for(string grpName : mapPGToUserExpectedForAddition.keyset()){
            for(Id usrId : mapPGToUserExpectedForAddition.get(grpName)){
                if(mapGroupToGroupMember.containsKey(grpName)){
                    if(!mapGroupToGroupMember.get(grpName).contains(usrId) && mapGrpDevNameToGrpId.containsKey(grpName)){
                        if(mapPGToConExpectedForRemoval.containsKey(grpName) && mapPGToConExpectedForRemoval.get(grpName).contains(usrId)) {
                            //if it is present in removal map we dont create group member
                        } else{
                            GroupMember gm = new GroupMember();
                            gm.GroupId = mapGrpDevNameToGrpId.get(grpName);
                            gm.UserOrGroupId = usrId;
                            lstInsertGrpMembers.add(gm);
                        }
                    }
                } else{
                    if(mapPGToConExpectedForRemoval.containsKey(grpName) && mapPGToConExpectedForRemoval.get(grpName).contains(usrId)) {
                            //if it is present in removal map we dont create group member
                        } else {
                            //create a GM record as grp is newly created without any member
                            if(mapGrpDevNameToGrpId.containsKey(grpName)){
                                GroupMember gm = new GroupMember();
                                gm.GroupId = mapGrpDevNameToGrpId.get(grpName);
                                gm.UserOrGroupId = usrId;
                                lstInsertGrpMembers.add(gm);
                            }
                        }
                }
            }
        }
		System.debug('mapGroupToGroupMember*** ='+mapGroupToGroupMember);
        System.debug('mapGrpDevNameToGrpId*** ='+mapGrpDevNameToGrpId);
        System.debug('mapUserIdToGrpMember*** ='+mapUserIdToGrpMember);
        
        System.debug('mapGroupIdToSetGrpMember*** ='+mapGroupIdToSetGrpMember);
        
        for(string grpName : mapGroupToGroupMember.keyset()){
            if(mapPGToUserExpectedForAddition.containsKey(grpName)){
                for(Id usrId : mapGroupToGroupMember.get(grpName)){             
                    if(!mapPGToUserExpectedForAddition.get(grpName).contains(usrId) && mapUserIdToGrpMember.containsKey(usrId)){
                        for(GroupMember grpMem : mapUserIdToGrpMember.get(usrId)){
							if(grpmem.Group.DeveloperName == grpName){
								setDeleteGrpMembers.add(grpmem);
							}
						} 
                    }                               
                }
            }
            //Commented while writing test class check this is required
            /*else{
                System.debug('$$$mapPGToUserExpectedForAddition not contains 2'+grpName);
                //add to remove list as no PAG found for users : TODO CHECK
                if(mapGrpDevNameToGrpId.containsKey(grpName)){
                    System.debug('$$$mapGrpDevNameToGrpId inside if 4'+grpName);
                    System.debug('$$$mapGrpDevNameToGrpId inside if 4 get'+mapGrpDevNameToGrpId.get(grpName));
                    if(mapGroupIdToSetGrpMember.containsKey(mapGrpDevNameToGrpId.get(grpName))){
                        System.debug('$$$mapGrpDevNameToGrpId adding to delete'+mapGrpDevNameToGrpId.get(grpName));
                        setDeleteGrpMembers.addAll(mapGroupIdToSetGrpMember.get(mapGrpDevNameToGrpId.get(grpName)));
                    }
                }
                System.debug('$$$lstDeleteGrpMembers add all 2'+grpName);
            }*/
            if(mapPGToConExpectedForRemoval.containsKey(grpName)){
                for(Id usrId : mapGroupToGroupMember.get(grpName)){
                    if(mapPGToConExpectedForRemoval.get(grpName).contains(usrId) && mapUserIdToGrpMember.containsKey(usrId)){
                        for(GroupMember grpMem : mapUserIdToGrpMember.get(usrId)) {
                            if(grpmem.Group.DeveloperName == grpName){
								setDeleteGrpMembers.add(grpmem);
							}
                        }
                    }
                }
            }
        }
        
        //System.debug('lstInsertGrpMembers*** ='+lstInsertGrpMembers);
        if(lstInsertGrpMembers.size() > 0 && !test.isRunningTest()){
            // Added logic to keep Membership Change Ind Flag to TRUE in case of any APEX Exception by adding Database.SaveResult
            Database.SaveResult[] srList = Database.insert(lstInsertGrpMembers, false);
            System.debug('Insert Group Member - SaveResult List - ' + srList);
            for(Database.SaveResult sr : srList) {
                if(!sr.isSuccess()) {
                    System.debug('Encountered following error: ' + sr);
                    PMP_Batch_Group_Management_Scheduler.lstSaveResultErrors.add(sr);
                    PMP_Batch_Group_Management_Scheduler.setFailedGrpMembrIds.add(sr.getId());
                }
            }
        }  
        
        System.debug('lstDeleteGrpMembers*** ='+setDeleteGrpMembers);
        if(setDeleteGrpMembers.size() > 0){
            lstDeleteGrpMembers.addAll(setDeleteGrpMembers);
            //Database.delete(lstDeleteGrpMembers, false);
            // Added logic to keep Membership Change Ind Flag to TRUE in case of any APEX Exception by adding Database.SaveResult
            Database.DeleteResult[] drList = Database.delete(lstDeleteGrpMembers, false);
            System.debug('Insert Group Member - DeleteResult List - ' + drList);
            for(Database.DeleteResult dr : drList) {
                if(!dr.isSuccess()) {
                    System.debug('Encountered following error: ' + dr);
                    PMP_Batch_Group_Management_Scheduler.lstDeleteResultErrors.add(dr);
                    PMP_Batch_Group_Management_Scheduler.setFailedGrpMembrIds.add(dr.getId());
                }
            }
        }
    }
    
    /*public static Set<Id> getOdmAccounts(List<Account> lstAllPartnerAccount){
        
        Set<Id> setOdmAccName = new Set<Id>();   
        
        String bizOrgLabelValues = System.Label.PMP_Biz_Org_ODM_Values ;
        List<String> lstBizOrgLabelValuesSplit = bizOrgLabelValues.split(';');
        
            for(Account odmPartner: lstAllPartnerAccount){
                for(String typeVal:lstBizOrgLabelValuesSplit){
                    if(odmPartner.Core_Account_Type__c != null && odmPartner.Core_Account_Type__c.contains(typeVal)){
                        setOdmAccName.add(odmPartner.Id);
                        break;
                    }
            
                }
            }
          return setOdmAccName;        
    }
    
    public static Set<Id> getNonOdmAccounts(List<Account> lstAllPartnerAccount){
        Set<Id> setNonOdmAccName = new Set<Id>();
        
        //fetching ODM values from label
        String bizOrgLabelValues = System.Label.PMP_Biz_Org_ODM_Values ;
        List<String> lstBizOrgLabelValuesSplit = bizOrgLabelValues.split(';');       
        boolean isODMAcc = false;
        for(Account nonOdmPartner: lstAllPartnerAccount){
            isODMAcc = false;
            for(String typeVal:lstBizOrgLabelValuesSplit){
                if(nonOdmPartner.Core_Account_Type__c != null && nonOdmPartner.Core_Account_Type__c.contains(typeVal)){
                       isODMAcc = true;
                        break;
                   }
            }    
                   if(nonOdmPartner.Core_Account_Type__c == null || !isODMAcc || String.isBlank(nonOdmPartner.Core_Account_Type__c)){
                       setNonOdmAccName.add(nonOdmPartner.Id);
                       }
             }
        return setNonOdmAccName;
    }*/
    
  /*  public static void assignRemoveGrpsToODMNonODM(List<Group> lstODMGroups, List<Group> lstNonODMGroups, String ODM_GROUP,String NON_ODM_GROUP){
    	
        List<GroupMember> lstDeleteGrpMembers = new List<GroupMember>();
        List<GroupMember> lstInsertGrpMembers = new List<GroupMember>();
        Set<Id> setNonODMGroupIds = new Set<Id>();
        Set<Id> setODMGroupIds = new Set<Id>();
        Set<Id> setAllGroupIds = new Set<Id>();
        
        for(Group grpOdm : lstODMGroups) {
            setODMGroupIds.add(grpOdm.Id);
        }
        for(Group grpNonOdm : lstNonODMGroups) {
            setNonODMGroupIds.add(grpNonOdm.Id);
        }
        
        setAllGroupIds.addAll(setODMGroupIds);
        setAllGroupIds.addAll(setNonODMGroupIds);
        List<GroupMember> lstAllOdmNonODMGrpMembers  = [SELECT Id,UserOrGroupID,GroupId FROM GroupMember WHERE 
                                                        (GroupId = : ODM_GROUP OR GroupId = : NON_ODM_GROUP) 
                                                       	 AND UserOrGroupID IN :setAllGroupIds];
        
        Map<string,Set<Id>> mapODMGroupToPAG = new Map<string,Set<Id>>();
        Map<Id,GroupMember> mapPAGToGrpMemberNonODM = new Map<Id,GroupMember>();
        Map<Id,GroupMember> mapPAGToGrpMemberODM = new Map<Id,GroupMember>();
        Map<string,Set<Id>> mapNonODMGroupToPAG = new Map<string,Set<Id>>();
        
        for(GroupMember gm : lstAllOdmNonODMGrpMembers){
            if(gm.GroupId == ODM_GROUP){
                if(mapODMGroupToPAG.containsKey(gm.GroupId)){
                    mapODMGroupToPAG.get(gm.GroupId).add(gm.UserOrGroupID);
                    mapPAGToGrpMemberODM.put(gm.UserOrGroupID, gm);
                }
                else{
                    Set<Id> grpIdPAG = new Set<Id>();
                    grpIdPAG.add(gm.UserOrGroupID);
                    mapODMGroupToPAG.put(gm.GroupId, grpIdPAG);
                    mapPAGToGrpMemberODM.put(gm.UserOrGroupID, gm);
                }
            }
            if(gm.GroupId == NON_ODM_GROUP){
                if(mapNonODMGroupToPAG.containsKey(gm.GroupId)){
                    mapNonODMGroupToPAG.get(gm.GroupId).add(gm.UserOrGroupID);
                    mapPAGToGrpMemberNonODM.put(gm.UserOrGroupID, gm);                    
                }
                else{
                    Set<Id> grpIdPAG = new Set<Id>();
                    grpIdPAG.add(gm.UserOrGroupID);
                    mapNonODMGroupToPAG.put(gm.GroupId, grpIdPAG);
                    mapPAGToGrpMemberNonODM.put(gm.UserOrGroupID, gm);
                }               
            }       
        }
        
        //Add PAG to Grps
        for(Id odmPAG : setODMGroupIds){
            //logic to add PAG to ODM groups
            if(mapODMGroupToPAG.containsKey(ODM_GROUP)){
                if(!mapODMGroupToPAG.get(ODM_GROUP).contains(odmPAG)){
                    GroupMember gm = new GroupMember();
                    gm.GroupId = ODM_GROUP;
                    gm.UserOrGroupId = odmPAG;
                    lstInsertGrpMembers.add(gm);
                }
            }
            else{
                GroupMember gm = new GroupMember();
                gm.GroupId = ODM_GROUP;
                gm.UserOrGroupId = odmPAG;
                lstInsertGrpMembers.add(gm);
            }
            //logic to remove if grp is added to Non ODM group
            if(mapNonODMGroupToPAG.containsKey(NON_ODM_GROUP) && mapNonODMGroupToPAG.get(NON_ODM_GROUP).contains(odmPAG)){
                if(mapPAGToGrpMemberNonODM.containsKey(odmPAG)){
                    lstDeleteGrpMembers.add(mapPAGToGrpMemberNonODM.get(odmPAG));             
                }
            }
        }
        
        for(Id nonODMPAG : setNonODMGroupIds){
            //logic to add PAG to Non ODM groups
            if(mapNonODMGroupToPAG.containsKey(NON_ODM_GROUP)){
                if(!mapNonODMGroupToPAG.get(NON_ODM_GROUP).contains(nonODMPAG)){
                    GroupMember gm = new GroupMember();
                    gm.GroupId = NON_ODM_GROUP;
                    gm.UserOrGroupId = nonODMPAG;
                    lstInsertGrpMembers.add(gm);
                }
            }
            else{
                GroupMember gm = new GroupMember();
                gm.GroupId = NON_ODM_GROUP;
                gm.UserOrGroupId = nonODMPAG;
                lstInsertGrpMembers.add(gm);
            }
            //logic to remove if grp is added to ODM group
            if(mapODMGroupToPAG.containsKey(ODM_GROUP) && mapODMGroupToPAG.get(ODM_GROUP).contains(nonODMPAG)){
                if(mapPAGToGrpMemberODM.containsKey(nonODMPAG)){
                    lstDeleteGrpMembers.add(mapPAGToGrpMemberODM.get(nonODMPAG));              
                }
            }
        }
        
        if(lstInsertGrpMembers.size() > 0){
            //system.debug('****lstInsertGrpMembersODMNODM***'+ lstInsertGrpMembers.size());
            // Database.insert(lstInsertGrpMembers, false);
            // Added logic to keep Membership Change Ind Flag to TRUE in case of any APEX Exception by adding Database.SaveResult
            Database.SaveResult[] srList = Database.insert(lstInsertGrpMembers, false);
            //System.debug('Insert Group Member - SaveResult List - ' + srList);
            for(Database.SaveResult sr : srList) {
                if(!sr.isSuccess()) {
                    //System.debug('Encountered following error: ' + sr);
                    PMP_Batch_Group_Management_Scheduler.lstSaveResultErrors.add(sr);
                    PMP_Batch_Group_Management_Scheduler.setFailedGrpMembrIds.add(sr.getId());
                }
            }
        }
        if(lstDeleteGrpMembers.size() > 0){
            //system.debug('****lstDeleteGrpMembersODMNODM***'+ lstDeleteGrpMembers.size());
            //Database.delete(lstDeleteGrpMembers, false);
            // Added logic to keep Membership Change Ind Flag to TRUE in case of any APEX Exception by adding Database.SaveResult
            Database.DeleteResult[] drList = Database.delete(lstDeleteGrpMembers, false);
            //System.debug('Insert Group Member - DeleteResult List - ' + drList);
            for(Database.DeleteResult dr : drList) {
                if(!dr.isSuccess()) {
                    //System.debug('Encountered following error: ' + dr);
                    PMP_Batch_Group_Management_Scheduler.lstDeleteResultErrors.add(dr);
                    PMP_Batch_Group_Management_Scheduler.setFailedGrpMembrIds.add(dr.getId());
                }
            }
        }            
    }*/
    
    Public static List<Account> refineIntelAccounts(Set<Id> setIntelAccIds,  Set<String> setEntitlementNames){
        Set<Id> setPAGIntelAcctIds = new Set<Id>();
        Set<Id> setRefinedIntelAccIds = new Set<Id>();
        for(Core_Account_Group_Member__c agm :[SELECT Id, Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                              WHERE Core_Intel_Account_Id__c IN :setIntelAccIds AND Core_Inactive_Ind__c = false ]) {
                                                 setPAGIntelAcctIds.add(agm.Core_Intel_Account_Id__c);
                                              }
        setIntelAccIds.removeAll(setPAGIntelAcctIds);
        for(Core_Contact_Entitlement__c lstConEnts : [SELECT Id,Core_Contact_Id__r.AccountId FROM Core_Contact_Entitlement__c
                                                       WHERE Core_Status__c = :STR_COMPLETE AND Core_Selected__c = true 
                                                       AND Core_Entitlement_Id__r.Name IN: setEntitlementNames 
                                                       AND Core_Contact_Id__r.AccountId IN: setIntelAccIds]) {
                                                          setRefinedIntelAccIds.add(lstConEnts.Core_Contact_Id__r.AccountId); 
                                                       }
        List<Account> lstIntelAccounts = [SELECT Id, Name, Core_Account_Type__c FROM Account WHERE Id IN: setRefinedIntelAccIds];
        return lstIntelAccounts;
    }
    
    public static void removeRolebasedSharing(String ODM_GROUP, String NON_ODM_GROUP, Set<Id> setAllPartnerAccts){
        List<Group> lstRoleGroups  = [SELECT Id, Name, DeveloperName, RelatedId, Type FROM Group WHERE Type = 'Role' AND Id IN (SELECT UserOrGroupID FROM GroupMember WHERE GroupId =: ODM_GROUP OR GroupId =: NON_ODM_GROUP) AND RelatedId IN (SELECT UserRoleId FROM user WHERE Core_IPA_One_Partner_Id__c IN: setAllPartnerAccts)];
        //Set<Id> setRoleIds = new Set<Id>();
        Set<Id> setGrpsToDelFromGrps = new Set<Id>();
        for(Group grp: lstRoleGroups){
            //setRoleIds.add(grp.RelatedId);
            setGrpsToDelFromGrps.add(grp.Id);
        }
        /*List<Group> lstGrps = [SELECT Id, Name, DeveloperName, RelatedId, Type FROM Group WHERE Type = 'Role' AND RelatedId IN (SELECT UserRoleId FROM User WHERE UserRoleId IN: setRoleIds AND (Contact.Core_IPA_One_Partner_Id__c != null OR Contact.Core_IPA_One_Partner_Id__c != ''))];
        for(Group grp: lstGrps){
            setGrpsToDelFromGrps.add(grp.Id);
        }*/
        List<GroupMember> lstGrpMemToDel = [SELECT Id,UserOrGroupID,GroupId FROM GroupMember WHERE UserOrGroupID IN: setGrpsToDelFromGrps AND (GroupId =: ODM_GROUP OR GroupId =: NON_ODM_GROUP)];
        //System.debug('delete if acc becomes part of PAG'+lstGrpMemToDel);
        if(!lstGrpMemToDel.isEmpty()){
            //Database.delete(lstGrpMemToDel);
            // Added logic to keep Membership Change Ind Flag to TRUE in case of any APEX Exception by adding Database.SaveResult
            Database.DeleteResult[] drList = Database.delete(lstGrpMemToDel, false);
            //System.debug('Insert Group Member - DeleteResult List - ' + drList);
            for(Database.DeleteResult dr : drList) {
                if(!dr.isSuccess()) {
                    //System.debug('Encountered following error: ' + dr);
                    PMP_Batch_Group_Management_Scheduler.lstDeleteResultErrors.add(dr);
                    PMP_Batch_Group_Management_Scheduler.setFailedGrpMembrIds.add(dr.getId());
                }
            }
        }
    }
    
    /*******Logics to Sharing Partner/Intel Account with Partner Account Group*************/
    public static void shareAccountwithMainPAGGroup(List<Group> lstAllPublicGrps, Set<Id> setAllPartnerAccId) {
        
        List<AccountShare> sharePartAccountWithAccGroups  = new List<AccountShare>();
        List<AccountShare> lstDelAccShare  = new List<AccountShare>();
        Map<String,Id> mapGrpDevNameToGrpId = new Map<String,Id>(); 
        Map<Id,Set<Id>> mapGroupIdToAccExpected = new Map<Id,set<Id>>();
        Set<Id> setAllAccountIds = new Set<Id>();
        
        for(Group grp : lstAllPublicGrps){
            mapGrpDevNameToGrpId.put(grp.DeveloperName, grp.Id);
        }
        
        for(Account acc: [SELECT Id, Core_IPA_One_Partner_Id__c FROM Account WHERE Core_IPA_One_Partner_Id__c IN : setAllPartnerAccId ]) {
            Id groupId = mapGrpDevNameToGrpId.get(CORE_MP_STR + acc.Core_IPA_One_Partner_Id__c);
            if(mapGroupIdToAccExpected.containsKey(groupId)) {
            	mapGroupIdToAccExpected.get(groupId).add(acc.Id);
            } else {
                mapGroupIdToAccExpected.put(groupId, new set<Id>{acc.Id});
            }
            setAllAccountIds.add(acc.Id);
        }
        
        Map<Id, Set<Id>> mapGroupIdToAccActual = new Map<Id, Set<Id>>();
        Map<Id, Set<AccountShare>> mapAccIdToAccShare= new Map<Id, Set<AccountShare>>();
        for(AccountShare accShare : [SELECT Id, UserOrGroupId, AccountId from AccountShare WHERE UserOrGroupId IN:mapGroupIdToAccExpected.keySet()]){
            if(mapGroupIdToAccActual.containsKey(accShare.UserOrGroupId)){
                mapGroupIdToAccActual.get(accShare.UserOrGroupId).add(accShare.AccountId);
            } else {
                mapGroupIdToAccActual.put(accShare.UserOrGroupId, new Set<Id>{accShare.AccountId});
            }
            if(mapAccIdToAccShare.containsKey(accShare.AccountId)){
                mapAccIdToAccShare.get(accShare.AccountId).add(accShare);
            } else {
                mapAccIdToAccShare.put(accShare.AccountId,new Set<AccountShare>{accShare});
            }
        }
        // System.debug('$$$$mapGroupIdToAccExpected'+mapGroupIdToAccExpected);
        // System.debug('$$$$mapGroupIdToAccActual'+mapGroupIdToAccActual);
        for(Id grpId : mapGroupIdToAccExpected.keySet()) {
            for(Id accId : mapGroupIdToAccExpected.get(grpId)) {
                if((mapGroupIdToAccActual.containsKey(grpId) && !mapGroupIdToAccActual.get(grpId).contains(accId)) || !mapGroupIdToAccActual.containsKey(grpId)) {
                    AccountShare sharePartAccountWithAccGroup = new AccountShare();
                    sharePartAccountWithAccGroup.AccountId = accId;                 
                    sharePartAccountWithAccGroup.UserOrGroupId = grpId;
                    sharePartAccountWithAccGroup.AccountAccessLevel = 'read';
                    sharePartAccountWithAccGroup.OpportunityAccessLevel = 'None';
                    sharePartAccountWithAccGroups.add(sharePartAccountWithAccGroup);
                }
            }
        }
        //System.debug('$$$$mapAccIdToAccShare'+ mapAccIdToAccShare);
        for(Id grpId : mapGroupIdToAccActual.keySet()) {
            for(Id accId : mapGroupIdToAccActual.get(grpId)) {
                if(mapGroupIdToAccExpected.containsKey(grpId) && !mapGroupIdToAccExpected.get(grpId).contains(accId)) {
                    for(AccountShare accShare: mapAccIdToAccShare.get(accId)){
                        if(accShare.UserOrGroupId == grpId){
                            lstDelAccShare.add(accShare);
                        }
                    }
                }
            }
        }
        
      	//System.debug('$$$$lstDelAccShare'+lstDelAccShare);
        
        System.enqueueJob(new PMPBatchQueueableClass(sharePartAccountWithAccGroups, lstDelAccShare));
    }
    
    /******* Implementation of Queueable Interface to PMPBatchQueueableClass*************/ 
    public class PMPBatchQueueableClass implements Queueable {        
        List<AccountShare> lstRecords;
        List<AccountShare> lstDelAccShare;
        public PMPBatchQueueableClass(List<AccountShare> lstRecords, List<AccountShare> lstDelAccShare) {
            this.lstRecords = lstRecords;
            this.lstDelAccShare = lstDelAccShare;
        }
        
        public void execute(QueueableContext context) {
            try{
               	Database.insert(lstRecords, false);
                Database.delete(lstDelAccShare, false);
            }catch(Exception terrException){
                //System.debug('exception getMessage = '+ terrException.getMessage());
            }
        }
    }
    
    public static String trimGroupName(String strGroupName) {
        if(strGroupName != null && strGroupName.length() > 40){
            return strGroupName.substring(0,40);
        } else {
            return strGroupName;
        }
    }

    //ipa 2.0 simplification: sharing all partner users as odm non odm EOL-LATA
 public static void assignRemoveToAllPartnerUsersGroup(List<Group> LstSharingMPPublicGroups, string ALL_PARTNERS_GROUP){
	  set<id> setMPOPIDGroupIds=new set<id>();
      List<GroupMember> lstInsertGrpMembers = new List<GroupMember>();
      Map<string,Set<Id>> mapPartnerGroupToUserOrGrp = new Map<string,Set<Id>>();
     Map<Id,GroupMember> mapPartnerGroupIdToGrp = new Map<Id,GroupMember>();
     system.debug('LstSharingMPPublicGroups'+LstSharingMPPublicGroups);
      system.debug('ALL_PARTNERS_GROUP'+ALL_PARTNERS_GROUP);
     for(Group grp : LstSharingMPPublicGroups) {
            setMPOPIDGroupIds.add(grp.Id);
        }
	List<GroupMember> lstAllPartnerGrpMembers 	= [SELECT Id,UserOrGroupID,GroupId FROM GroupMember WHERE 
                                                        (GroupId = : ALL_PARTNERS_GROUP) 
                                                       	 AND UserOrGroupID IN :setMPOPIDGroupIds];
			for(GroupMember gm : lstAllPartnerGrpMembers){											 
				if(mapPartnerGroupToUserOrGrp.containsKey(gm.GroupId)){
                    mapPartnerGroupToUserOrGrp.get(gm.GroupId).add(gm.UserOrGroupID);
                    mapPartnerGroupIdToGrp.put(gm.UserOrGroupID, gm);
                }
                else{
                    Set<Id> grpId = new Set<Id>();
                    grpId.add(gm.UserOrGroupID);
                    mapPartnerGroupToUserOrGrp.put(gm.GroupId, grpId);// all partner group, pmp_opid group
                    mapPartnerGroupIdToGrp.put(gm.UserOrGroupID, gm); //pmp_opid group, group record
                }														 

 }
   system.debug('lstAllPartnerGrpMembers'+lstAllPartnerGrpMembers);
     
 for(Id opidGrp : setMPOPIDGroupIds){// pmp_opid groups
            //logic to add PAG to ODM groups
            if(mapPartnerGroupToUserOrGrp.containsKey(ALL_PARTNERS_GROUP)){
                if(!mapPartnerGroupToUserOrGrp.get(ALL_PARTNERS_GROUP).contains(opidGrp)){
                      System.debug('Preparing to add new GroupMember (existing group mapping)');
        System.debug('GroupId: ' + ALL_PARTNERS_GROUP + ', UserOrGroupId: ' + opidGrp);
                    GroupMember gm = new GroupMember();
                    gm.GroupId = ALL_PARTNERS_GROUP;
                    gm.UserOrGroupId = opidGrp;
                    lstInsertGrpMembers.add(gm);
                }
            }
            else{
                  System.debug('Preparing to add new GroupMember (new group mapping)');
    System.debug('GroupId: ' + ALL_PARTNERS_GROUP + ', UserOrGroupId: ' + opidGrp);

                GroupMember gm = new GroupMember();
                gm.GroupId = ALL_PARTNERS_GROUP;
                gm.UserOrGroupId = opidGrp;
                lstInsertGrpMembers.add(gm);
            }
			
 }
  System.debug('lstInsertGrpMembers'+lstInsertGrpMembers+'lstInsertGrpMemberssize'+lstInsertGrpMembers.size());
 if(lstInsertGrpMembers.size() > 0 && !test.isRunningTest()){
            Database.SaveResult[] srList = Database.insert(lstInsertGrpMembers, false);
            System.debug('Insert Group Member - SaveResult List - ' + srList);
           // for(Database.SaveResult sr : srList) {
            for (Integer i = 0; i < srList.size(); i++) {
        Database.SaveResult sr = srList[i];
                if(!sr.isSuccess()) {
                     GroupMember failedGM = lstInsertGrpMembers[i];
            System.debug('GroupId: ' + failedGM.GroupId + ', UserOrGroupId: ' + failedGM.UserOrGroupId);
                    //System.debug('Encountered following error: ' + sr);
                    PMP_Batch_Group_Management_Scheduler.lstSaveResultErrors.add(sr);
                    PMP_Batch_Group_Management_Scheduler.setFailedGrpMembrIds.add(sr.getId());
                     for (Database.Error err : sr.getErrors()) {
                        System.debug('Error Message: ' + err.getMessage());
                        System.debug('Status Code: ' + err.getStatusCode());
                        if (err.getFields() != null && !err.getFields().isEmpty()) {
                            System.debug('Fields causing error: ' + String.join(err.getFields(), ', '));
                        }
       			 }
                }
            }
     system.debug('list of errors'+PMP_Batch_Group_Management_Scheduler.lstSaveResultErrors+'\n');
        }
	}

    //IPA 2.0 simplification
    public static void removeUsersFromAllPartnersGrp(list<Core_Account_Group_Member__c> lstPAGInactive,set<string> setMPOPIDGroupIds){
        map<string,boolean> mapAccIdInactive=new  map<string,boolean>();
        map<Id,GroupMember> mapOPIDGrpUser=new  map<Id,GroupMember>();
        List<GroupMember> lstOPIDGrpMembers =new List<GroupMember> (); 
        Set<Id> setIntelAccs=new Set<Id>();
         list<Id> lstUserIds=new list<Id>();
      List<GroupMember>  lstdeleteusersfromopidGrp=new List<GroupMember>();
      for (Core_Account_Group_Member__c pag: lstPAGInactive){
			mapAccIdInactive.put(pag.Core_Partner_Account_Id__c,pag.Core_Inactive_Ind__c);
           setIntelAccs.add(pag.Core_Intel_Account_Id__c);
		}
        for(user usr:[select id,accountId,account.Core_IPA_One_Partner_Id__c,contactId from user 
                    where AccountId in:setIntelAccs and contactId!=null and UserRole.PortalType = 'Partner' 
                    AND UserRole.PortalRole = 'Worker']){
                        lstUserIds.add(usr.id);
        }
	    lstOPIDGrpMembers 	= [SELECT Id,UserOrGroupID,GroupId FROM GroupMember WHERE 
                                                        (GroupId in : setMPOPIDGroupIds) 
                                                       	  AND UserOrGroupID in: lstUserIds];
		for(GroupMember grp:lstOPIDGrpMembers){
             mapOPIDGrpUser.put(grp.GroupId,grp);
		}
														
		 for(string opidGrp : setMPOPIDGroupIds){// pmp_opid groups
			String opid_id  = opidGrp.split('_')[1];
			if(mapAccIdInactive.containskey(opid_id) && mapAccIdInactive.get(opid_id)==TRUE){
					if(mapOPIDGrpUser.containskey(opidGrp) && lstUserIds.contains(mapOPIDGrpUser.get(opidGrp).UserOrGroupID)){
					lstdeleteusersfromopidGrp.add(mapOPIDGrpUser.get(opidGrp));// user from pmp_opid
                }
            }
        }
		 Database.DeleteResult[] drList = Database.delete(lstdeleteusersfromopidGrp, false);
            //System.debug('Insert Group Member - DeleteResult List - ' + drList);
            for(Database.DeleteResult dr : drList) {
                if(!dr.isSuccess()) {
                    //System.debug('Encountered following error: ' + dr);
                    PMP_Batch_Group_Management_Scheduler.lstDeleteResultErrors.add(dr);
                    PMP_Batch_Group_Management_Scheduler.setFailedGrpMembrIds.add(dr.getId());
                }
            }
	 
	}
}