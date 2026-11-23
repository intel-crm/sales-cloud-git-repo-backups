public class PMP_PG_Management_Handler {
    
    static final String COMPLETE_STR = 'Complete';
    static final String CORE_MP_STR = System.Label.PMP_Group_Name_Prefix;
    static final String ALL_PARTNERS_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_ODM;
    static final String ALL_PARTNERS_NON_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_Non_ODM;
    
    /*This returns MP Contact Entitlement with OPID and Contact*****/  
    public static List<Core_Contact_Entitlement__c> getAllContactEntitlementwithOPID(Set<Id> setAllPartnerAccountsId){
    
        List<String> lstEntitlementIds = new List<String>();
        /******** Fetching MP entitlemet ids from custom label*********/
        List<Core_Entitlement__c> lstEntitlementDetails = new List<Core_Entitlement__c>();
        String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
        
        if(!Test.isRunningTest()){
            lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
        }else{
            //Querying Entitlement Detail
            lstEntitlementDetails = [SELECT Id, Name, Core_Display_Name__c FROM Core_Entitlement__c];
            for(Core_Entitlement__c coreEntitlement : lstEntitlementDetails){
                lstEntitlementIds.add(coreEntitlement.Id);
            }
        }
        
        
        /********Getting all contact entitlements for mp related entitlements and for allpartnercontact **********/
        List<Core_Contact_Entitlement__c> conEntList = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c, 
                                                                Core_Contact_Id__r.AccountId, Core_Selected__c, 
                                                                Core_Contact_Id__r.Core_IPA_One_Partner_Id__c, 
                                                                Core_Contact_Id__r.Core_IPA_Contact_Segment__c,
                                                        		Core_Entitlement_Id__r.Name
                                                                FROM Core_Contact_Entitlement__c
                                                               WHERE Core_Status__c = :COMPLETE_STR AND Core_Selected__c = true 
                                                               AND Core_Entitlement_Id__c = :lstEntitlementIds 
                                                               AND Core_Contact_Id__r.Core_IPA_One_Partner_Id__c = : setAllPartnerAccountsId];
        
        System.debug('$$$conEntList'+conEntList);
        System.debug('$$$lstEntitlementIds'+lstEntitlementIds);
        System.debug('$$$setAllPartnerAccountsId'+setAllPartnerAccountsId);
        System.debug('$$$COMPLETE_STR'+COMPLETE_STR);
        return conEntList;
    }
    
    /* Send a refined list of Partner Accounts excluding the ones which doesn't have any
    * contact entitlements
    * */
    public static List<Account> refinePartnerAccounts(List<Core_Contact_Entitlement__c> lstMPConEntList){
        
        List<Account> lstRefinedPartnerAccs = new List<Account>();  
         String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        /********Getting all contact entitlements for mp related entitlements and for allpartnercontact **********/
        Set<Id> setRefinedAccountIds = new Set<Id>();
        for(Core_Contact_Entitlement__c conEnt : lstMPConEntList){
            setRefinedAccountIds.add(conEnt.Core_Contact_Id__r.Core_IPA_One_Partner_Id__c);        
        }
        if(setRefinedAccountIds != null  && !setRefinedAccountIds.isEmpty()){
            lstRefinedPartnerAccs = [SELECT Id,Name,Core_PMP_Membership_Change_Ind__c, Core_Account_Type__c FROM Account 
                                 WHERE RecordTypeId =:partnerAccRecTypeId 
                                 and Core_PMP_Membership_Change_Ind__c=true
                                 and Id in :setRefinedAccountIds];  
        }
        return lstRefinedPartnerAccs;
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
                map < string, Database.Error[] > errorsMap = new map < string, Database.Error[] > ();
                system.debug('****lstPublicGroupToBeInserted***'+ lstPublicGroupToBeInserted.size());
                Database.saveResult[] srlist=Database.insert(lstPublicGroupToBeInserted, false);
                
                for (integer i = 0; i < srlist.size(); i++) {
                    database.saveResult sr = srlist.get(i);
                    if (!sr.isSuccess()) {
                        // inserting Exception error records 
                        errorsMap.put(lstPublicGroupToBeInserted[i].Name , sr.getErrors());
                    }
                    
                }
                system.debug('****errorsMap***'+ errorsMap);
            }
            
            //check if it hives error due to huge size
             lstQueriedGrps = [SELECT Id,DeveloperName,Name FROM Group where DeveloperName IN :publicGroupNameToBeAdded];
        }
        catch(Exception e){
            String exceptionMessage = e.getTypeName() + ': ' + e.getMessage() + ', ' + e.getStackTraceString();
            // inserting the Error into LogEntry object
        } 
        return lstQueriedGrps;
    }
	
    public static Set<Id> getInactiveIntelAccIds(Set<Id> setAllPartnerAccId){
        
        Set<Id> setInactiveIntelAccounts = new Set<Id>();
        List<Core_Account_Group_Member__c> lstPartnerAccountGrpMember = [SELECT Id, Core_Partner_Account_Id__c, 
                                                             Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                             WHERE Core_Inactive_Ind__c =: true
                                                             AND Core_Partner_Account_Id__c IN: setAllPartnerAccId];
                                                             
        for(Core_Account_Group_Member__c pagm : lstPartnerAccountGrpMember){
            setInactiveIntelAccounts.add(pagm.Core_Intel_Account_Id__c);        
        }
        
        return setInactiveIntelAccounts;
    }
    
    public static Map<String,Set<Id>> getPublicGroupExpectedMap(Set<Id> setInactiveIntelAccounts, 
                                                                List<Core_Contact_Entitlement__c> lstMPConEntList, 
                                                                List<PMP_Public_Group_Management_Settings__c> lstActivePGMgmSettingsForAddition,
                                                                Map<Id,Id> mapConIdtoUsrId ) {
        
        Map<String,Set<Id>> mapPGToUserExpectedForAddition = new Map<String,Set<Id>>();
        
        for(PMP_Public_Group_Management_Settings__c PGMgmsetting : lstActivePGMgmSettingsForAddition) {
            for(Core_Contact_Entitlement__c conEnt: lstMPConEntList) {
                if(!setInactiveIntelAccounts.contains(conEnt.Core_Contact_Id__r.AccountId)){
                    if(PGMgmsetting.PMP_Action_Txt__c == 'Add'){
                        String strPagGroupName = CORE_MP_STR + conEnt.Core_Contact_Id__r.Core_IPA_One_Partner_Id__c;
                        if(mapPGToUserExpectedForAddition.containsKey(strPagGroupName)) {
                            if(mapConIdtoUsrId.containsKey(conEnt.Core_Contact_Id__c)){
                                mapPGToUserExpectedForAddition.get(strPagGroupName).add(mapConIdtoUsrId.get(conEnt.Core_Contact_Id__c));  
                            }     
                        } else {
                            if(mapConIdtoUsrId.containsKey(conEnt.Core_Contact_Id__c)){
                                mapPGToUserExpectedForAddition.put(strPagGroupName, new Set<Id>{mapConIdtoUsrId.get(conEnt.Core_Contact_Id__c)});  
                            }
                        }
                    }
                    
                    if(PGMgmsetting.PMP_Contributing_Entitlement_Nm__c == conEnt.Core_Entitlement_Id__r.Name && PGMgmsetting.PMP_Contributing_Field_API_Nm__c == null){
                        String strGroupName = trimGroupName(CORE_MP_STR + conEnt.Core_Contact_Id__r.Core_IPA_One_Partner_Id__c + '_' + PGMgmsetting.PMP_Public_Group_Nm__c);
                        if(mapPGToUserExpectedForAddition.containsKey(strGroupName)) {
                            if(mapConIdtoUsrId.containsKey(conEnt.Core_Contact_Id__c)){
                            	mapPGToUserExpectedForAddition.get(strGroupName).add(mapConIdtoUsrId.get(conEnt.Core_Contact_Id__c)); 
                            }
                        } else {
                            if(mapConIdtoUsrId.containsKey(conEnt.Core_Contact_Id__c)){
                            	mapPGToUserExpectedForAddition.put(strGroupName, new Set<Id>{mapConIdtoUsrId.get(conEnt.Core_Contact_Id__c)});
                            }
                        }
                    }
                       
                    if(PGMgmsetting.PMP_Contributing_Entitlement_Nm__c == conEnt.Core_Entitlement_Id__r.Name && PGMgmsetting.PMP_Contributing_Field_API_Nm__c != null){
                        if(conEnt.Core_Contact_Id__r.get(PGMgmsetting.PMP_Contributing_Field_API_Nm__c) != null && conEnt.Core_Contact_Id__r.get(PGMgmsetting.PMP_Contributing_Field_API_Nm__c).toString().contains(PGMgmsetting.PMP_Contributing_Field_Value_Txt__c)){
                        	String strGroupName = trimGroupName(CORE_MP_STR + conEnt.Core_Contact_Id__r.Core_IPA_One_Partner_Id__c + '_' + PGMgmsetting.PMP_Public_Group_Nm__c);
                            if(mapPGToUserExpectedForAddition.containsKey(strGroupName)) {
                                if(mapConIdtoUsrId.containsKey(conEnt.Core_Contact_Id__c)){
                            		mapPGToUserExpectedForAddition.get(strGroupName).add(mapConIdtoUsrId.get(conEnt.Core_Contact_Id__c));
                                }
                            } else {
                                if(mapConIdtoUsrId.containsKey(conEnt.Core_Contact_Id__c)){
                                	mapPGToUserExpectedForAddition.put(strGroupName, new Set<Id>{mapConIdtoUsrId.get(conEnt.Core_Contact_Id__c)});
                                }
                            }
                        }
                    }
                          
                }
            }
        }
        return mapPGToUserExpectedForAddition;
    }
    
    public static Map<Id,Id> getconIdToUserIdMap(Set<Id> setAllPartnerAccId) {
        Map<Id,Id> mapConIdtoUsrId = new Map<Id,Id>();
        
        List<User> lstPartnerUser = [SELECT Id, Name, ContactId, AccountId, Core_IPA_One_Partner_Id__c, Contact.AccountId FROM User 
                                       WHERE Core_IPA_One_Partner_Id__c IN : setAllPartnerAccId AND Core_IPA_One_Partner_Id__c != null];
        
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
            String strPrefix = CORE_MP_STR +'%';
            lstQueriedGrpsMembers = [SELECT Id,GroupId,UserOrGroupID, Group.DeveloperName FROM GroupMember where Group.DeveloperName LIKE: strPrefix AND UserOrGroupID IN:setUserIds];
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
        for(Id groupId : mapGroupIdToSetGrpMember.keySet()){
            System.debug('mapGroupIdToSetGrpMember$$$$ = ' + groupId + ' '+mapGroupIdToSetGrpMember.get(groupId));
        }
        System.debug('mapGroupIdToSetGrpMember*** ='+mapGroupIdToSetGrpMember);
        
        for(string grpName : mapGroupToGroupMember.keyset()){
            System.debug('$$$grpName 1'+grpName);
            if(mapPGToUserExpectedForAddition.containsKey(grpName)){
                System.debug('$$$mapPGToUserExpectedForAddition contains 2'+grpName);
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
            else{
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
            }
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
        
        System.debug('lstInsertGrpMembers*** ='+lstInsertGrpMembers);

        if(lstInsertGrpMembers.size() > 0){
            system.debug('****lstInsertGrpMembersEmp***'+ lstInsertGrpMembers.size());
            Database.insert(lstInsertGrpMembers, false);
        }  
        
        System.debug('lstDeleteGrpMembers*** ='+lstDeleteGrpMembers);
        if(setDeleteGrpMembers.size() > 0){
            lstDeleteGrpMembers.addAll(setDeleteGrpMembers);
            system.debug('****lstDeleteGrpMembersEmp***'+ lstDeleteGrpMembers.size());
            Database.delete(lstDeleteGrpMembers, false);
        }
    }
    public static void removeInactiveIntelContactsFromPG(Set<Id> setInactiveIntelAccounts){
        String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
        List<String> lstEntitlementIds = new List<String>();
        Set<Id> setInactiveContactIds = new Set<Id>();
        Map<Id, User> mapNonPartnerUser = new Map<Id, User>();
        List<GroupMember> lstQueriedGrpsMembers = new List<GroupMember>();
            
        if(!Test.isRunningTest()){
            lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
        }else{
            //Querying Entitlement Detail
            for(Core_Entitlement__c coreEntitlement : [SELECT Id, Name, Core_Display_Name__c FROM Core_Entitlement__c]){
                lstEntitlementIds.add(coreEntitlement.Id);
            }
        }
        
        List<Core_Contact_Entitlement__c> lstconEntListInactiveAcc = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c, 
                                                                      Core_Contact_Id__r.AccountId, Core_Selected__c, 
                                                                      Core_Contact_Id__r.Core_IPA_One_Partner_Id__c, 
                                                                      Core_Contact_Id__r.Core_IPA_Contact_Segment__c,
                                                                      Core_Entitlement_Id__r.Name
                                                                      FROM Core_Contact_Entitlement__c
                                                                      WHERE Core_Entitlement_Id__c = :lstEntitlementIds 
                                                                      AND Core_Contact_Id__r.AccountId = : setInactiveIntelAccounts];
        
        for(Core_Contact_Entitlement__c conEnt: lstconEntListInactiveAcc){
            setInactiveContactIds.add(conEnt.Core_Contact_Id__c);
        }
        if(!setInactiveContactIds.isEmpty()) {
        	mapNonPartnerUser = new Map<Id, User>([SELECT Id, Name, ContactId, AccountId, Core_IPA_One_Partner_Id__c, Contact.AccountId FROM User 
                                       		WHERE ContactId IN: setInactiveContactIds]);   
        }
        
        if(!mapNonPartnerUser.isEmpty()){
            String strPrefix = CORE_MP_STR +'%';
        	lstQueriedGrpsMembers = [SELECT Id,GroupId,UserOrGroupID, Group.DeveloperName FROM GroupMember where Group.DeveloperName LIKE: strPrefix AND UserOrGroupID IN : mapNonPartnerUser.keySet()];
        }
        
        if(!lstQueriedGrpsMembers.isEmpty()){
            system.debug('****lstQueriedGrpsMembers***'+ lstQueriedGrpsMembers.size());
            Database.delete(lstQueriedGrpsMembers);
        }
        
    }
    public static void deleteMemebersForEntitlementAndAccount(Set<Id> setAllPartnerAccountsId, Set<Id> setInactiveIntelAccounts, 
                                                                List<PMP_Public_Group_Management_Settings__c> lstActivePGMgmSettingsForAddition) {
        
        List<String> lstEntitlementIds = new List<String>();
        List<Core_Contact_Entitlement__c> lstContactEntAll = new List<Core_Contact_Entitlement__c>();
        /******** Fetching MP entitlemet ids from custom label*********/
        List<Core_Entitlement__c> lstEntitlementDetails = new List<Core_Entitlement__c>();
        String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
        Set<Id> setContactId = new Set<Id>();
        Set<Id> setUserId = new Set<Id>();
        Map<string, Id> mapContactIdToUserId = new Map<String,Id>();
        Map<String, Set<Id>>mapGroupToGroupMember = new Map<String, Set<Id>>();
		Map<Id, Set<GroupMember>> mapUserIdToGrpMember = new Map<Id, Set<GroupMember>>();
		Map<Id, Set<GroupMember>> mapGroupIdToSetGrpMember = new Map<Id, Set<GroupMember>>();
		List<GroupMember> lstDeleteGrpMembers = new List<GroupMember>();
                                                                    
        Set<Id> setInactiveContactIds = new Set<Id>();
        Set<Id> setInactiveUserIds = new Set<Id>();
                                                                    
        if(!Test.isRunningTest()){
            lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
        }else{
            //Querying Entitlement Detail
            lstEntitlementDetails = [SELECT Id, Name, Core_Display_Name__c FROM Core_Entitlement__c];
            for(Core_Entitlement__c coreEntitlement : lstEntitlementDetails){
                lstEntitlementIds.add(coreEntitlement.Id);
            }
        }
        
        List<Core_Contact_Entitlement__c> lstConEntNonMP = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c, 
                                                                Core_Contact_Id__r.AccountId, Core_Selected__c, 
                                                                Core_Contact_Id__r.Core_IPA_One_Partner_Id__c, 
                                                                Core_Contact_Id__r.Core_IPA_Contact_Segment__c,
                                                            	Core_Entitlement_Id__r.Name
                                                                FROM Core_Contact_Entitlement__c
                                                               WHERE Core_Status__c = :COMPLETE_STR AND Core_Selected__c = false 
                                                               AND Core_Entitlement_Id__c = :lstEntitlementIds 
                                                               AND Core_Contact_Id__r.Core_IPA_One_Partner_Id__c = : setAllPartnerAccountsId];
        
        if(lstConEntNonMP.size() > 0){
			lstContactEntAll.addAll(lstConEntNonMP);
		}

        
        List<Core_Contact_Entitlement__c> lstconEntListInactiveAcc = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c, 
                                                                Core_Contact_Id__r.AccountId, Core_Selected__c, 
                                                                Core_Contact_Id__r.Core_IPA_One_Partner_Id__c, 
                                                                Core_Contact_Id__r.Core_IPA_Contact_Segment__c,
                                                                Core_Entitlement_Id__r.Name
                                                                FROM Core_Contact_Entitlement__c
                                                               WHERE Core_Entitlement_Id__c = :lstEntitlementIds 
                                                               AND Core_Contact_Id__r.AccountId = : setInactiveIntelAccounts];
        
        if(lstconEntListInactiveAcc.size() > 0){
			//lstContactEntAll.addAll(lstconEntListInactiveAcc);
		}
                                                                    for(Core_Contact_Entitlement__c conEnt: lstconEntListInactiveAcc){
                                                                        setInactiveContactIds.add(conEnt.Core_Contact_Id__c);
                                                                        setContactId.add(conEnt.Core_Contact_Id__c);
                                                                    }
        
        Map<String,Set<Id>> mapGrpsToContactIdRomoveExpected = new Map<String,Set<Id>>();
        
        for(PMP_Public_Group_Management_Settings__c PGMgmsetting : lstActivePGMgmSettingsForAddition) {
            for(Core_Contact_Entitlement__c conEnt: lstContactEntAll) {
                if(PGMgmsetting.PMP_Action_Txt__c == 'Add'){
                    String strPagGroupName = CORE_MP_STR + conEnt.Core_Contact_Id__r.Core_IPA_One_Partner_Id__c;
                    if(mapGrpsToContactIdRomoveExpected.containsKey(strPagGroupName)) {
                        mapGrpsToContactIdRomoveExpected.get(strPagGroupName).add(conEnt.Core_Contact_Id__c); 
                    } else {
                        mapGrpsToContactIdRomoveExpected.put(strPagGroupName, new Set<Id>{conEnt.Core_Contact_Id__c});  
                    }
                }
                
                if(PGMgmsetting.PMP_Contributing_Entitlement_Nm__c == conEnt.Core_Entitlement_Id__r.Name && PGMgmsetting.PMP_Contributing_Field_API_Nm__c == null){
                    String strGroupName = trimGroupName(CORE_MP_STR + conEnt.Core_Contact_Id__r.Core_IPA_One_Partner_Id__c + '_' + PGMgmsetting.PMP_Public_Group_Nm__c);
                    if(mapGrpsToContactIdRomoveExpected.containsKey(strGroupName)) {
                        mapGrpsToContactIdRomoveExpected.get(strGroupName).add(conEnt.Core_Contact_Id__c); 
                    } else {
                        mapGrpsToContactIdRomoveExpected.put(strGroupName, new Set<Id>{conEnt.Core_Contact_Id__c});
                    }
                }
                
                if(PGMgmsetting.PMP_Contributing_Entitlement_Nm__c == conEnt.Core_Entitlement_Id__r.Name && PGMgmsetting.PMP_Contributing_Field_API_Nm__c != null){
                    if(conEnt.Core_Contact_Id__r.get(PGMgmsetting.PMP_Contributing_Field_API_Nm__c) != null && conEnt.Core_Contact_Id__r.get(PGMgmsetting.PMP_Contributing_Field_API_Nm__c).toString().contains(PGMgmsetting.PMP_Contributing_Field_Value_Txt__c)){
                        String strGroupName = trimGroupName (CORE_MP_STR + conEnt.Core_Contact_Id__r.Core_IPA_One_Partner_Id__c + '_' + PGMgmsetting.PMP_Public_Group_Nm__c);
                        if(mapGrpsToContactIdRomoveExpected.containsKey(strGroupName)) {
                            mapGrpsToContactIdRomoveExpected.get(strGroupName).add(conEnt.Core_Contact_Id__c);
                        } else {
                            mapGrpsToContactIdRomoveExpected.put(strGroupName, new Set<Id>{conEnt.Core_Contact_Id__c});
                        }
                    }
                }
				setContactId.add(conEnt.Core_Contact_Id__c);
            }
        }
		
        List<User> lstNonPartnerUser = [SELECT Id, Name, ContactId, AccountId, Core_IPA_One_Partner_Id__c, Contact.AccountId FROM User 
                                       WHERE ContactId IN: setContactId];
        for(User usr : lstNonPartnerUser){
			setUserId.add(usr.Id);
			mapContactIdToUserId.put(usr.ContactId, usr.Id);
            if(setInactiveContactIds.contains(usr.ContactId)){
                setInactiveUserIds.add(usr.Id);
            }
            
		}
        System.debug('setInactiveContactIds$$$$'+setInactiveContactIds);
        System.debug('setInactiveUserIds$$$$'+setInactiveUserIds);
        String strPrefix = CORE_MP_STR +'%';
        List<GroupMember> lstQueriedGrpsMembers = [SELECT Id,GroupId,UserOrGroupID, Group.DeveloperName FROM GroupMember where Group.DeveloperName LIKE: strPrefix AND UserOrGroupID IN : setUserId];
		
        for(GroupMember grpMem : lstQueriedGrpsMembers){
            if(setInactiveUserIds.contains(grpMem.UserOrGroupID)){
                lstDeleteGrpMembers.add(grpMem);
            }            
            if(mapGroupToGroupMember.containsKey(grpMem.Group.DeveloperName)){
                mapGroupToGroupMember.get(grpMem.Group.DeveloperName).add(grpMem.UserOrGroupID);    
            }
            else{
                Set<Id> setUsrId = new Set<id>();
                setUsrId.add(grpMem.UserOrGroupID);
                mapGroupToGroupMember.put(grpMem.Group.DeveloperName , setUsrId);                
            }
            if(mapGroupIdToSetGrpMember.containsKey(grpMem.GroupId)){
                mapGroupIdToSetGrpMember.get(grpMem.GroupId).add(grpMem);
            
            }
            else{
                Set<GroupMember> setGrpMem = new Set<GroupMember>();
                setGrpMem.add(grpMem);
                mapGroupIdToSetGrpMember.put(grpMem.GroupId, setGrpMem);
            }
			if(mapUserIdToGrpMember.containsKey(grpMem.UserOrGroupID)){
                mapUserIdToGrpMember.get(grpMem.UserOrGroupID).add(grpMem);
            
            }
            else{
                Set<GroupMember> setGrpMem = new Set<GroupMember>();
                setGrpMem.add(grpMem);
                mapUserIdToGrpMember.put(grpMem.UserOrGroupID, setGrpMem);
            }
        }
        
        System.debug('mapGrpsToContactIdRomoveExpected*** ='+mapGrpsToContactIdRomoveExpected);
        System.debug('mapGroupToGroupMember*** ='+mapGroupToGroupMember);
        System.debug('mapUserIdToGrpMember*** ='+mapUserIdToGrpMember);
		for(string grpName : mapGroupToGroupMember.keyset()){
            System.debug('1*** ='+mapGrpsToContactIdRomoveExpected.containsKey(grpName));
            if(mapGrpsToContactIdRomoveExpected.containsKey(grpName)){
                System.debug('2*** ='+mapGrpsToContactIdRomoveExpected.get(grpName));
				for(Id contId : mapGrpsToContactIdRomoveExpected.get(grpName)){
                    System.debug('3*** ='+mapContactIdToUserId.containsKey(contId) +' '+ mapUserIdToGrpMember.containsKey(mapContactIdToUserId.get(contId)));
					if(mapContactIdToUserId.containsKey(contId) && mapUserIdToGrpMember.containsKey(mapContactIdToUserId.get(contId))){
						System.debug('4*** ='+mapUserIdToGrpMember.get(mapContactIdToUserId.get(contId)));
                        for(GroupMember grpMem : mapUserIdToGrpMember.get(mapContactIdToUserId.get(contId))){
                            System.debug('5*** ='+grpmem.Group.DeveloperName +' '+ grpName);
							if(grpmem.Group.DeveloperName == grpName){
                                System.debug('6*** ='+grpMem);
                            
                                lstDeleteGrpMembers.add(grpmem);
                            
							}
						}
					
					}				
				}
			}			
		}
		System.debug('lstDeleteGrpMembers*** ='+lstDeleteGrpMembers);
		if(lstDeleteGrpMembers.size() > 0){
            system.debug('****lstDeleteGrpMembers***'+ lstDeleteGrpMembers.size());
            Database.delete(lstDeleteGrpMembers);
        }
        
    }
    
    public static Set<String> getOdmPAGforAccountIds(List<Account> lstAllPartnerAccount){
        
        Set<String> setOdmAccName = new Set<String>();   
        
        String bizOrgLabelValues = System.Label.PMP_Biz_Org_ODM_Values ;
        List<String> lstBizOrgLabelValuesSplit = bizOrgLabelValues.split(';');
        
            for(Account odmPartner: lstAllPartnerAccount){
                for(String typeVal:lstBizOrgLabelValuesSplit){
                    if(odmPartner.Core_Account_Type__c != null && odmPartner.Core_Account_Type__c.contains(typeVal)){
                        setOdmAccName.add(CORE_MP_STR + odmPartner.Id);
                        break;
                    }
            
                }
            }
          return setOdmAccName;        
    }
    
    public static Set<String> getNonOdmPAGAccounts(List<Account> lstAllPartnerAccount){
        Set<String> setNonOdmAccName = new Set<String>();
        
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
                       setNonOdmAccName.add(CORE_MP_STR + nonOdmPartner.Id);
                       }
             }
        return setNonOdmAccName;
    }
    
    public static void assignRemoveMembersToODMNonODM(Set<String> setOdmPAGAccId, Set<String> setNonOdmPartner){
        List<GroupMember> lstDeleteGrpMembers = new List<GroupMember>();
        List<GroupMember> lstInsertGrpMembers = new List<GroupMember>();
        List<String> lstNonODMGroupDevNames = new List<String>();
        List<String> lstOdmGroupDevNames = new List<String>();
        Set<Id> setNonODMGroupIds = new Set<Id>();
        Set<Id> setODMGroupIds = new Set<Id>();
        String groupId =  '';
        
        system.debug('****insideODM***'+ setOdmPAGAccId+'***NODM**'+setNonOdmPartner);
        //logic for Odm
        if(setOdmPAGAccId.size() > 0){
            for(String odm : setOdmPAGAccId){
                //groupId =  CORE_MP_STR + odm;
                lstOdmGroupDevNames.add(odm);           
            }
            system.debug('****lstOdmGroupDevNamesODM***'+lstOdmGroupDevNames);
            List<Group> lstAllODMGroups =[SELECT Id,DeveloperName,Name FROM Group WHERE DeveloperName IN :lstOdmGroupDevNames];    
            system.debug('****lstAllODMGroups***'+ lstAllODMGroups.size());
            for(Group odmGroup : lstAllODMGroups){
                setODMGroupIds.add(odmGroup.Id);                  
            }            
        }        
        //logic for non ODM
        if(setNonOdmPartner.size() > 0){
            for(String nODM : setNonOdmPartner){
                //groupId =  CORE_MP_STR + nODM ;
                lstNonOdmGroupDevNames.add(nODM);            
            }            
            List<Group> lstAllNonODMGroups =[SELECT Id,DeveloperName,Name FROM Group WHERE DeveloperName IN :lstNonOdmGroupDevNames];     
            system.debug('****lstAllNonODMGroups***'+ lstAllNonODMGroups.size());
            for(Group odmGroup : lstAllNonODMGroups){
                setNonODMGroupIds.add(odmGroup.Id);                  
            }        
        }
        List<GroupMember> lstAllOdmNonODMGrpMembers  = [SELECT Id,UserOrGroupID,GroupId FROM GroupMember WHERE 
                                                            GroupId = : ALL_PARTNERS_ODM_GROUP OR GroupId = : ALL_PARTNERS_NON_ODM_GROUP];
                                                            
        Map<string,Set<Id>> mapODMGroupToPAG = new Map<string,Set<Id>>();
        Map<Id,GroupMember> mapPAGToGrpMemberNonODM = new Map<Id,GroupMember>();
        Map<Id,GroupMember> mapPAGToGrpMemberODM = new Map<Id,GroupMember>();
        Map<string,Set<Id>> mapNonODMGroupToPAG = new Map<string,Set<Id>>();
        for(GroupMember gm : lstAllOdmNonODMGrpMembers){
            if(gm.GroupId == ALL_PARTNERS_ODM_GROUP){
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
            if(gm.GroupId == ALL_PARTNERS_NON_ODM_GROUP){
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
            if(mapODMGroupToPAG.containsKey(ALL_PARTNERS_ODM_GROUP)){
                if(!mapODMGroupToPAG.get(ALL_PARTNERS_ODM_GROUP).contains(odmPAG)){
                    GroupMember gm = new GroupMember();
                    gm.GroupId = ALL_PARTNERS_ODM_GROUP;
                    gm.UserOrGroupId = odmPAG;
                    lstInsertGrpMembers.add(gm);
                }
            }
            else{
                GroupMember gm = new GroupMember();
                gm.GroupId = ALL_PARTNERS_ODM_GROUP;
                gm.UserOrGroupId = odmPAG;
                lstInsertGrpMembers.add(gm);
            }
            //logic to remove if grp is added to Non ODM group
            if(mapNonODMGroupToPAG.containsKey(ALL_PARTNERS_NON_ODM_GROUP) && mapNonODMGroupToPAG.get(ALL_PARTNERS_NON_ODM_GROUP).contains(odmPAG)){
                if(mapPAGToGrpMemberNonODM.containsKey(odmPAG)){
                    lstDeleteGrpMembers.add(mapPAGToGrpMemberNonODM.get(odmPAG));             
                }
            }
        }
        
        for(Id nonODMPAG : setNonODMGroupIds){
            //logic to add PAG to Non ODM groups
            if(mapNonODMGroupToPAG.containsKey(ALL_PARTNERS_NON_ODM_GROUP)){
                if(!mapNonODMGroupToPAG.get(ALL_PARTNERS_NON_ODM_GROUP).contains(nonODMPAG)){
                    GroupMember gm = new GroupMember();
                    gm.GroupId = ALL_PARTNERS_NON_ODM_GROUP;
                    gm.UserOrGroupId = nonODMPAG;
                    lstInsertGrpMembers.add(gm);
                }
            }
            else{
                GroupMember gm = new GroupMember();
                gm.GroupId = ALL_PARTNERS_NON_ODM_GROUP;
                gm.UserOrGroupId = nonODMPAG;
                lstInsertGrpMembers.add(gm);
            }
            //logic to remove if grp is added to ODM group
            if(mapODMGroupToPAG.containsKey(ALL_PARTNERS_ODM_GROUP) && mapODMGroupToPAG.get(ALL_PARTNERS_ODM_GROUP).contains(nonODMPAG)){
                if(mapPAGToGrpMemberODM.containsKey(nonODMPAG)){
                    lstDeleteGrpMembers.add(mapPAGToGrpMemberODM.get(nonODMPAG));              
                }
            }
        }
        system.debug('****lstInsertGrpMembersout***'+ lstInsertGrpMembers.size());
        if(lstInsertGrpMembers.size() > 0){
            system.debug('****lstInsertGrpMembersODMNODM***'+ lstInsertGrpMembers.size());
            Database.insert(lstInsertGrpMembers, false);
        }
        system.debug('****lstDeleteGrpMembersout***'+ lstDeleteGrpMembers.size());
        if(lstDeleteGrpMembers.size() > 0){
            system.debug('****lstDeleteGrpMembersODMNODM***'+ lstDeleteGrpMembers.size());
            Database.delete(lstDeleteGrpMembers, false);
        }        
    }
    
    /*******Logics to Sharing Partner Account with Partner Account Group*************/ 
    public static void sharePartAccWithPartAcGrp( Map<Id,Id> mapPartnerAccIdToGroupId){
        //fiter logic added by Vaibhav to include only Account which don't have sharing
        List<AccountShare> lstAccountShare = [SELECT Id, UserOrGroupId, AccountId from AccountShare WHERE AccountId =: mapPartnerAccIdToGroupId.keyset()];
        Map<Id, Set<Id>> mapAccountIdToAccShare = new Map<Id, Set<Id>>();
        for(AccountShare accShare : lstAccountShare){
            Set<Id> setGrpId = new Set<Id>();
            setGrpId.add(accShare.UserOrGroupId);
            mapAccountIdToAccShare.put(accShare.AccountId, setGrpId);
        }        
        List<AccountShare> sharePartAccountWithAccGroups  = new List<AccountShare>();
        for(Id partAccId : mapPartnerAccIdToGroupId.keySet()){
            if(mapAccountIdToAccShare.containsKey(partAccId)){
                if(!mapAccountIdToAccShare.get(partAccId).contains(mapPartnerAccIdToGroupId.get(partAccId))){
                    AccountShare sharePartAccountWithAccGroup = new AccountShare();
                    sharePartAccountWithAccGroup.AccountId = partAccId;                 
                    sharePartAccountWithAccGroup.UserOrGroupId = mapPartnerAccIdToGroupId.get(partAccId);
                    sharePartAccountWithAccGroup.AccountAccessLevel = 'read';
                    sharePartAccountWithAccGroup.OpportunityAccessLevel = 'read';
                    sharePartAccountWithAccGroups.add(sharePartAccountWithAccGroup);
                }
            }            
            else{
                AccountShare sharePartAccountWithAccGroup = new AccountShare();
                sharePartAccountWithAccGroup.AccountId = partAccId;                
                sharePartAccountWithAccGroup.UserOrGroupId = mapPartnerAccIdToGroupId.get(partAccId);
                sharePartAccountWithAccGroup.AccountAccessLevel = 'read';
                sharePartAccountWithAccGroup.OpportunityAccessLevel = 'read';
                sharePartAccountWithAccGroups.add(sharePartAccountWithAccGroup);
            }
        } 
        /******* Calling enqueueJob method *************/ 
        System.enqueueJob(new PMPBatchQueueableClass(sharePartAccountWithAccGroups));
    }
    
    /******* Implementation of Queueable Interface to PMPBatchQueueableClass*************/ 
    public class PMPBatchQueueableClass implements Queueable {        
        List<AccountShare> lstRecords;
        
        public PMPBatchQueueableClass(List<AccountShare> lstRecords) {
            this.lstRecords = lstRecords;
        }
        
        public void execute(QueueableContext context) {
            try{
               	Database.insert(lstRecords, false);
            }catch(Exception terrException){
                System.debug('exception getMessage = '+ terrException.getMessage());
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
}