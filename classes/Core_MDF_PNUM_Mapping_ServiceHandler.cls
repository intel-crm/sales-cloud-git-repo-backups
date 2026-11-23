/****************************************************************************************************************************************
* Class Name  : Core_MDF_PNUM_Mapping_ServiceHandler
* Version     : 1.0
* Created Date: 09-02-2022
* Modification Log :
* Developer             Date                Description
------------------------------------------------------------------------------------------------------------------------------------------
*Accenture - NK         09-02-2022          Service Class for handling trigger related functions on Partner Node User Mapping object.
******************************************************************************************************************************************/

public without sharing class Core_MDF_PNUM_Mapping_ServiceHandler {
    //This variable will store the Account Id and List of User Id to which the Account needs to be shared
    public static Map<Id, List<Id>> accountIdUserIdListMap = new Map<Id, List<Id>>();
    //set of account id
    public static Set < Id > accountIdSet = new Set < Id >();
    //set of user id
    public static Set < Id > userIdSet = new Set < Id >();
    //Map of account id to program
    public static Map<Id,String> mapOfAccIdToProgram = new Map<Id,String>();
    //Map of account node to it's ultimate account
    public static Map<Id,Id> accNodeToUltimateAccMap = new Map<Id,Id>();
    //Map of user id to contact id
    public static Map<Id,Id> mapOfUserIdToContactId = new Map<Id,Id>();
    //Map of account node to it's program
    public static Map<Id,Id> accNodeToProgramMap = new Map<Id,Id>();
    
    /************************************************************************************************************ 
    Method Name:        addUsersToNodeGroup
    Parameters:         newPNUMList (Trigger.New from PNUM trigger)
    Description:        Method to add users to respective node group on PNUM creation
    @Added By:          Accenture-NK  - 09-02-2022
    Modified By:        Date:      - Changes: 
    *************************************************************************************************************/     
    public static Map<Id,GroupMember> addUsersToNodeGroup(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMList){
        Map<Id,Id> accIdToGroupIdMap = new Map<Id,Id>();
        Set<Id> accIdSet = new Set<Id>();
        Map<Id,GroupMember> pnumIdTogroupMemList = new Map<Id,GroupMember>();

        for(Core_MDF_Partner_Node_User_Mapping__c pnum :newPNUMList ){
            accIdSet.add(pnum.Core_MDF_Account__c);
        }
        for(Account acc : [Select id,Core_MDF_External_Group_Id__c from Account where id in:accIdSet and Core_MDF_External_Group_Id__c != null]){
            accIdToGroupIdMap.put(acc.Id,Acc.Core_MDF_External_Group_Id__c);
        }
        
        for(Core_MDF_Partner_Node_User_Mapping__c pnum :newPNUMList ){
            if(pnum.Core_MDF_Active_Ind__c){
                GroupMember groupMem = new GroupMember();
                groupMem.UserOrGroupId = pnum.Core_MDF_User__c;
                groupMem.GroupId = accIdToGroupIdMap.get(pnum.Core_MDF_Account__c);
                pnumIdTogroupMemList.put(pnum.Id, groupMem);
            }
        }
       
        return pnumIdTogroupMemList;
    }

    /************************************************************************************************************ 
    Method Name:        removeUsersFromNodeGroup
    Parameters:         newPNUMList (Trigger.New from PNUM trigger)
    Description:        Method to remove users from respective node group on PNUM deletion/inactivation.
    @Added By:          Accenture-NK  - 09-02-2022
    Modified By:        Date:      - Changes: 
    *************************************************************************************************************/ 
    public static Map<Id,Id> removeUsersFromNodeGroup(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMList){
        Map<String,Id> userIdGroupIdToPnumIdMap = new Map<String,Id>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> pnumIdSet = new Set<Id>();
        Map<Id,Id> pnumIdToGrmMemberIdDeleteMap = new Map<Id,Id>();

        for(Core_MDF_Partner_Node_User_Mapping__c pnum :newPNUMList ){
            pnumIdSet.add(pnum.Id);          
        }

        Set<id> grpIdSet = new Set<Id>();
        for(Core_MDF_Partner_Node_User_Mapping__c pnum :[SELECT Id, Core_MDF_User__c, Core_MDF_Account__r.Core_MDF_External_Group_Id__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Id IN: pnumIdSet AND Core_MDF_Account__r.Core_MDF_External_Group_Id__c != null] ){
            userIdSet.add(pnum.Core_MDF_User__c);  
            String UsrIdGrpId = String.valueOf(pnum.Core_MDF_User__c) + String.valueOf(pnum.Core_MDF_Account__r.Core_MDF_External_Group_Id__c);
            userIdGroupIdToPnumIdMap.put(UsrIdGrpId, pnum.Id);
            grpIdSet.add(pnum.Core_MDF_Account__r.Core_MDF_External_Group_Id__c);
        }
        
        for(GroupMember groupMem : [Select Id, UserOrGroupId, GroupId from GroupMember where UserOrGroupId in:userIdSet and GroupId in:grpIdSet]){
            string uniqueKey = String.valueOf(groupMem.UserOrGroupId)+String.valueOf(groupMem.GroupId);
            if(userIdGroupIdToPnumIdMap.containsKey(uniqueKey)){
                pnumIdToGrmMemberIdDeleteMap.put(userIdGroupIdToPnumIdMap.get(uniqueKey), groupMem.Id);
            }
        }
        
        
        return pnumIdToGrmMemberIdDeleteMap;
    }

    /************************************************************************************************************ 
    Method Name:        removeAndAddUsersToNodeGroup
    Parameters:         newPNUMList (Trigger.New from PNUM trigger), 
    Description:        Method to remove and add users to respective node group on PNUM update.
    @Added By:          Accenture-JB  - 02/22/2022
    Modified By:        Date:      - Changes: 
    *************************************************************************************************************/ 
    public static void removeAndAddUsersToNodeGroup(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMList, List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMList){
        
        Map<Id,Id> pnumIdToGrmMemberIdDeleteMap = removeUsersFromNodeGroup(oldPNUMList);
        Map<Id,GroupMember> GroupMemberList= addUsersToNodeGroup(newPNUMList);
        if(pnumIdToGrmMemberIdDeleteMap != null && (!pnumIdToGrmMemberIdDeleteMap.isEmpty())){ 
            System.enqueueJob(new Core_MDF_Remove_GroupMembers_Queueable(GroupMemberList, pnumIdToGrmMemberIdDeleteMap));
        }
        else if(GroupMemberList != null && !GroupMemberList.isEmpty()){
            System.enqueueJob(new Core_MDF_Add_GroupMembers_Queueable(GroupMemberList));
        }
    }

    /************************************************************************************************************ 
    Method Name:        addUsersToNodeGroupOnInsert
    Parameters:         newPNUMList (Trigger.New from PNUM trigger), 
    Description:        Method to add users to respective node group on PNUM insert.
    @Added By:          Accenture-JB  - 02/22/2022
    Modified By:        Date:      - Changes: 
    *************************************************************************************************************/ 
    public static void addUsersToNodeGroupOnInsert(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMList){
       
        Map<Id,GroupMember> GroupMemberList= addUsersToNodeGroup(newPNUMList);
        if(GroupMemberList != null && !GroupMemberList.isEmpty()){
            System.enqueueJob(new Core_MDF_Add_GroupMembers_Queueable(GroupMemberList));
        }
    }

    /************************************************************************************************************ 
    Method Name:        removeUsersFromNodeGroupOnDelete
    Parameters:         newPNUMList (Trigger.New from PNUM trigger), 
    Description:        Method to remove users from respective node group on PNUM deletion/inactivation.
    @Added By:          Accenture-JB  - 02/22/2022
    Modified By:        Date:      - Changes: 
    *************************************************************************************************************/ 
    public static void removeUsersFromNodeGroupOnDelete(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMList){
        
         Map<Id,Id> pnumIdToGrmMemberIdDeleteMap = removeUsersFromNodeGroup(oldPNUMList);
        
        if(pnumIdToGrmMemberIdDeleteMap!= null && !pnumIdToGrmMemberIdDeleteMap.isEmpty()){
            System.enqueueJob(new Core_MDF_Remove_GroupMembers_Queueable(null, pnumIdToGrmMemberIdDeleteMap));
        }
    }

     public static void checkDuplicateRecords(List<Core_MDF_Partner_Node_User_Mapping__c> newRecordsList, Map<Id, Core_MDF_Partner_Node_User_Mapping__c> oldRecordsMap){
        
        Set<Id> accountIdSet = new Set<Id>();

        for(Core_MDF_Partner_Node_User_Mapping__c pnumRecord : newRecordsList) {
            accountIdSet.add(pnumRecord.Core_MDF_Account__c);
        }

        Map<Id, Map<Id,Core_MDF_Partner_Node_User_Mapping__c>> accountIdtoUserIdAndPnumRecordMap = new Map<Id, Map<Id,Core_MDF_Partner_Node_User_Mapping__c>>();

        // Map of PNUM Id to PNUM record which contains only active Users
        Map<Id, Core_MDF_Partner_Node_User_Mapping__c> pnumIdToPnumRecordMap = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>([SELECT Core_MDF_Account__c, Core_MDF_User__c, Core_MDF_Active_Ind__c
                                                                                                                    FROM Core_MDF_Partner_Node_User_Mapping__c
                                                                                                                    WHERE (Core_MDF_User__r.IsActive = true or Core_MDF_User__r.Partner_License_Reclaimed__c = true)
                                                                                                                    AND Core_MDF_Account__c IN: accountIdSet limit 30000]);//Added limit for Unhandled exception fix
        
        for(Core_MDF_Partner_Node_User_Mapping__c pnumRecord : pnumIdToPnumRecordMap.values()) {

            if(accountIdtoUserIdAndPnumRecordMap.containsKey(pnumRecord.Core_MDF_Account__c)) {
                accountIdtoUserIdAndPnumRecordMap.get(pnumRecord.Core_MDF_Account__c).put(pnumRecord.Core_MDF_User__c, pnumRecord);
            }else{
                accountIdtoUserIdAndPnumRecordMap.put(pnumRecord.Core_MDF_Account__c, new Map<Id,Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord.Core_MDF_User__c => pnumRecord});
            }
        }

        //Only in Insert Scenario
        Boolean hasErrorInsert = false;

        for(Core_MDF_Partner_Node_User_Mapping__c pnuMappingRecord : newRecordsList) {

            if(oldRecordsMap == null) {
                
                //if(accountIdtoUserIdAndPnumRecordMap.get(pnuMappingRecord.Core_MDF_Account__c) != null && accountIdtoUserIdAndPnumRecordMap.get(pnuMappingRecord.Core_MDF_Account__c).keySet().contains(pnuMappingRecord.Core_MDF_User__c)) {
                    if (accountIdtoUserIdAndPnumRecordMap.get(pnuMappingRecord.Core_MDF_Account__c) == null || !accountIdtoUserIdAndPnumRecordMap.get(pnuMappingRecord.Core_MDF_Account__c).keySet().contains(pnuMappingRecord.Core_MDF_User__c)) {//ATHR Fix WW19
                        continue; 
                    }
                    String pnumRecordId = accountIdtoUserIdAndPnumRecordMap.get(pnuMappingRecord.Core_MDF_Account__c).get(pnuMappingRecord.Core_MDF_User__c).Id;
                    if(accountIdtoUserIdAndPnumRecordMap.get(pnuMappingRecord.Core_MDF_Account__c).get(pnuMappingRecord.Core_MDF_User__c).Core_MDF_Active_Ind__c){
                        hasErrorInsert = true;
                        pnuMappingRecord.addError(System.Label.Core_MDF_PNUMDuplicateError + ' ' + (String.isNotBlank(pnumRecordId) ? pnumRecordId : ''));
                    }else{
                        hasErrorInsert = true;
                        pnuMappingRecord.addError('Inactive PNUM record already exist with this Account and User Details ' + (String.isNotBlank(pnumRecordId) ? pnumRecordId : ''));
                    }
                //}

                //Add newly inserted records to the PNUM Map
                if(!hasErrorInsert && accountIdtoUserIdAndPnumRecordMap.containsKey(pnuMappingRecord.Core_MDF_Account__c)) {
                    accountIdtoUserIdAndPnumRecordMap.get(pnuMappingRecord.Core_MDF_Account__c).put(pnuMappingRecord.Core_MDF_User__c, pnuMappingRecord);
                }else if(!hasErrorInsert){
                    accountIdtoUserIdAndPnumRecordMap.put(pnuMappingRecord.Core_MDF_Account__c, new Map<Id,Core_MDF_Partner_Node_User_Mapping__c>{pnuMappingRecord.Core_MDF_User__c => pnuMappingRecord});
                }
                hasErrorInsert = false;

            }else if(accountIdtoUserIdAndPnumRecordMap.get(pnuMappingRecord.Core_MDF_Account__c) != null &&
            (oldRecordsMap.get(pnuMappingRecord.Id).Core_MDF_User__c != pnuMappingRecord.Core_MDF_User__c || oldRecordsMap.get(pnuMappingRecord.Id).Core_MDF_Account__c != pnuMappingRecord.Core_MDF_Account__c) &&
            accountIdtoUserIdAndPnumRecordMap.get(pnuMappingRecord.Core_MDF_Account__c).keySet().contains(pnuMappingRecord.Core_MDF_User__c)) {
                        
                if(accountIdtoUserIdAndPnumRecordMap.get(pnuMappingRecord.Core_MDF_Account__c).get(pnuMappingRecord.Core_MDF_User__c).Core_MDF_Active_Ind__c){              
                    pnuMappingRecord.addError(System.Label.Core_MDF_PNUMDuplicateError + ' ' +accountIdtoUserIdAndPnumRecordMap.get(pnuMappingRecord.Core_MDF_Account__c).get(pnuMappingRecord.Core_MDF_User__c).Id);
                }else{
                    pnuMappingRecord.addError('Inactive PNUM record already exist with this Account and User Details ' + accountIdtoUserIdAndPnumRecordMap.get(pnuMappingRecord.Core_MDF_Account__c).get(pnuMappingRecord.Core_MDF_User__c).Id);
                }
            }
        }
    }


    /*****************************************************************************************************
    Method Name:        validateAccountUserAccess
    @return  :          N/A
    @parameters:        List of PNUM
    Description:           This method used to validate account user access corresponding to program
    Added By:           Accenture - AD - 14/07/2020
    Modified By:        Date:       Changes:
    ******************************************************************************************************/
    public static void validateAccountUserAccess(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList) {
        
        //Map of contact entitlement to list of contacts
        Map<String,List<Id>> mapOfCntctEntitlementToListOfContact = new Map<String,List<Id>>();
        //Map of program to contact entitlement
        Map<String,String> mapOfProgramToCntctEntitlement = new Map<String,String>();
    
        //quering channel program metadata and preparing map
        for(Core_MDF_ChannelProgram__mdt metaData:[Select Id,Core_MDF_Technical_Program_Name__c,Core_MDF_Contact_Entitlement_Nm__c 
                                                from Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c IN :mapOfAccIdToProgram.values()]){
            mapOfProgramToCntctEntitlement.put(metaData.Core_MDF_Technical_Program_Name__c,metaData.Core_MDF_Contact_Entitlement_Nm__c);
        }
        //quering existing contact entitlement and preparing map
        for(Core_Contact_Entitlement__c cntctEntitlement : [select Id,Core_Entitlement_Id__r.Name, Core_Contact_Id__c  from Core_Contact_Entitlement__c where Core_Contact_Id__c IN : mapOfUserIdToContactId.values()]){
            if(mapOfCntctEntitlementToListOfContact.containsKey(cntctEntitlement.Core_Entitlement_Id__r.Name)){
                mapOfCntctEntitlementToListOfContact.get(cntctEntitlement.Core_Entitlement_Id__r.Name).add(cntctEntitlement.Core_Contact_Id__c);
            }else{
                mapOfCntctEntitlementToListOfContact.put(cntctEntitlement.Core_Entitlement_Id__r.Name, new List<Id>{cntctEntitlement.Core_Contact_Id__c});
            }
        }
        //invoke method to display error if user and selected program is not matched
        displayErrorForInvalidUser(newPNUMappingList,mapOfAccIdToProgram,mapOfProgramToCntctEntitlement,
                                mapOfCntctEntitlementToListOfContact,mapOfUserIdToContactId);
    }
    /*****************************************************************************************************
    Method Name:        displayErrorForInvalidUser
    @return  :          N/A
    @parameters:        Maps
    Description:        This method used to display error if user and selected program is not matched
    Added By:           Accenture - AD - 14/07/2020
    Modified By:        Date:       Changes:
    ******************************************************************************************************/
    public static void displayErrorForInvalidUser(List < Core_MDF_Partner_Node_User_Mapping__c > newPNUMappingList,
                                                Map < Id, String > mapOfAccIdToProgram,
                                                Map < String, String > mapOfProgramToCntctEntitlement,
                                                Map < String, List < Id >> mapOfCntctEntitlementToListOfContact,
                                                Map < Id, Id > mapOfUserIdToContactId) {
    //Looping all incoming PNUM's
    for (Core_MDF_Partner_Node_User_Mapping__c pnum: newPNUMappingList) {
        if(!pnum.Core_MDF_Active_Ind__c){
            continue;
        }
        //List of contact id
        List < Id > listOfContacts = new List < Id > ();
        //hold contact entitlement name
        String contactEntitlement = null;
        //hold account program
        String program = mapOfAccIdToProgram.containsKey(pnum.Core_MDF_Account__c) ? mapOfAccIdToProgram.get(pnum.Core_MDF_Account__c) : null;
        //hold contact entitlement name corresonding to program
        if (!String.isBlank(program)) {
            contactEntitlement = mapOfProgramToCntctEntitlement.containsKey(program) ? mapOfProgramToCntctEntitlement.get(program) : null;
        }
        //hold list of contacts corresponding to contact entitlement
        if (!String.isBlank(contactEntitlement)) {
            listOfContacts = mapOfCntctEntitlementToListOfContact.containsKey(contactEntitlement) ? mapOfCntctEntitlementToListOfContact.get(contactEntitlement) : null;
        }
        /**check user does not belongs to user list
         * If user does not have corresponding entitlement, show error
         **/
        if (mapOfUserIdToContactId != null && mapOfUserIdToContactId.size() > 0 &&
            (listOfContacts == null || (listOfContacts.size() > 0 &&
                !listOfContacts.contains(mapOfUserIdToContactId.get(pnum.Core_MDF_User__c))))) {
            pnum.addError(Label.Core_MDF_InvalidProgramAccessToUser);
        }
    }
    }

    /*****************************************************************************************************
    Method Name:        validateCrossAccUserAccess
    @return  :          N/A
    @parameters:        Maps
    Description:        This method used to validate cross account and user access
    Added By:           Accenture - AD - 14/07/2020
    Modified By:        Date:       Changes:
    ******************************************************************************************************/

    public static void validateCrossAccUserAccess(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList) {
        
        //Map of user to list of corresponding groups
        Map<Id,List<String>> userToGroupsMap = new Map<Id,List<String>>();
        //Map of ultimate account and program to it's group
        Map<String,String> ultimateAccToGroupMap = new Map<String,String>();
        //External Access Type
        String extAccessType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PGM_Ext_AccessType');
        system.debug('newPNUMappingList::'+newPNUMappingList);
        //quering existing PGM and preparing map
        for (Core_MDF_Partner_Group_Mapping__c  pgm : [Select id,Core_MDF_Account__c,Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c 
                                                       from Core_MDF_Partner_Group_Mapping__c 
                                                       where Core_MDF_Type_of_Access__c =: extAccessType 
                                                       and Core_MDF_Inactive_Ind__c = false 
                                                       and Core_MDF_Account__c IN: (accNodeToUltimateAccMap.values()) 
                                                       and Core_MDF_Channel_Program__c IN: (accNodeToProgramMap.values())]){
            //acc+progrm  > group name
            ultimateAccToGroupMap.put(pgm.Core_MDF_Account__c+'-'+pgm.Core_MDF_Channel_Program__c,pgm.Core_MDF_Group_Name__c);
        }
        system.debug('ultimateAccToGroupMap::'+ultimateAccToGroupMap);
        //quering existing Group Member and preparing map
        for(GroupMember groupMember : [Select Id,UserOrGroupId,GroupId,Group.DeveloperName from GroupMember where UserOrGroupId IN : userIdSet]){
            if(userToGroupsMap.containsKey(groupMember.UserOrGroupId)){
                userToGroupsMap.get(groupMember.UserOrGroupId).add(groupMember.Group.DeveloperName);
            }else{
                userToGroupsMap.put(groupMember.UserOrGroupId, new List<String>{groupMember.Group.DeveloperName});
            }
        }
        system.debug('userToGroupsMap::'+userToGroupsMap);
        //Looping all incoming PNUM's
        //Showing error if account group and user group does not match
        for(Core_MDF_Partner_Node_User_Mapping__c pnum : newPNUMappingList){
            if(!pnum.Core_MDF_Active_Ind__c){
                continue;
            }
            //get ultimate account based on account
            Id ultimateAccount = accNodeToUltimateAccMap.containsKey(pnum.Core_MDF_Account__c) ? accNodeToUltimateAccMap.get(pnum.Core_MDF_Account__c) : null;
            system.debug('ultimateAccount::'+ultimateAccount);
            //get account channel program based on account
            Id accountProgram = accNodeToProgramMap.containsKey(pnum.Core_MDF_Account__c) ? accNodeToProgramMap.get(pnum.Core_MDF_Account__c) : null;
            system.debug('accountProgram::'+accountProgram);
            //get group name based on ultimate account and program
            String groupName = ultimateAccToGroupMap.containsKey(ultimateAccount+'-'+accountProgram) ? ultimateAccToGroupMap.get(ultimateAccount+'-'+accountProgram) : null;
            system.debug('groupName::'+groupName);
            //get list of groups corresponding to user
            List<String> groupList = userToGroupsMap.containsKey(pnum.Core_MDF_User__c) ? userToGroupsMap.get(pnum.Core_MDF_User__c) : null;
            system.debug('groupList::'+groupList);
            system.debug('check1::'+groupList == null);
            system.debug('check2::'+!String.isBlank(groupName));
            system.debug('check3::'+!groupList.contains(groupName));
            if(groupList == null || (!String.isBlank(groupName) && groupList!=null && groupList.size()>0 && !groupList.contains(groupName))){
            pnum.addError(Label.Core_MDF_CrossAccountToUserMappingError);
            }
        }
    }

    /*****************************************************************************************************
    Method Name:        prepareCommonMapData
    @return  :          N/A
    @parameters:        Maps
    Description:        This method used to prepare comman map and set data
    Added By:           Accenture - AD - 14/07/2020
    Modified By:        Date:       Changes:
    ******************************************************************************************************/
    public static void prepareCommonMapData(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList) {
        //Looping all incoming PNUM's
        for(Core_MDF_Partner_Node_User_Mapping__c pnum : newPNUMappingList){
            accountIdSet.add(pnum.Core_MDF_Account__c);
            userIdSet.add(pnum.Core_MDF_User__c);
        }
        //quering existing contacts and preparing map
        for(User user : [select Id , ContactId from User where Id IN : userIdSet]){
            mapOfUserIdToContactId.put(user.Id,user.ContactId);
        }        
        //quering existing account and preparing map
        for ( Account acc : [Select Id, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_CoMarketing_Ultimate_Account__c from Account where Id IN: (accountIdSet)]){
            mapOfAccIdToProgram.put(acc.Id,acc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
            accNodeToUltimateAccMap.put(acc.Id,acc.Core_MDF_CoMarketing_Ultimate_Account__c);
            accNodeToProgramMap.put(acc.Id,acc.Core_MDF_Channel_Program__c);
        }
    }
 
    /*****************************************************************************************************
    Method Name:        validateAccountUserMapping
    @return  :          N/A
    @parameters:        Maps
    Description:        This method used to validate account user access corresponding to program and as well as cross account user access
    Added By:           Accenture - AD - 14/07/2020
    Modified By:        Date:       Changes:
    ******************************************************************************************************/
    public static void validateAccountUserMapping(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList) {
        //preparing map data
        prepareCommonMapData(newPNUMappingList);
        //validate cross account user mapping
        validateCrossAccUserAccess(newPNUMappingList);
        //validate account user access corresponding to program
        validateAccountUserAccess(newPNUMappingList);
    }

    /*****************************************************************************************************
    Method Name:        addOrUpdateGeneralizeMap
    @return  :          void
    @parameters:        newPNUMappingList - This will contain all the new pnum records to be inserted.
    Description:        Whenever a record is inserted to the Node User Mapping object, the generalize accountIdUserIdListMap Map
    should be updated.
    Added By:           Accenture - JV - 08/08/2018
    Modified By:        Date:       Changes:
    ******************************************************************************************************/
    public static void addOrUpdateGeneralizeMap(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList, Map<Id, Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingMap) {
        try{
            for(Core_MDF_Partner_Node_User_Mapping__c pNUMappingRecord : newPNUMappingList) {
                if(pNUMappingRecord.Core_MDF_Active_Ind__c){
                    if(accountIdUserIdListMap.containsKey(pNUMappingRecord.Core_MDF_Account__c)) {
                        accountIdUserIdListMap.get(pNUMappingRecord.Core_MDF_Account__c).add(pNUMappingRecord.Core_MDF_User__c);
                    }else{
                        accountIdUserIdListMap.put(pNUMappingRecord.Core_MDF_Account__c, new List<Id>{pNUMappingRecord.Core_MDF_User__c});
                    }
                }
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
        // JV- Accenture : Add the exception into Core_Log_Entry Object
    }

    /*****************************************************************************************************
    Method Name:        createObjectShareRecords
    @return  :          void
    @parameters:        newPNUMappingMap - Trigger.newMap for Core_MDF_Partner_Node_User_Mapping__c
    Description:        Whenever a record is added in the Node User Mapping object, call the respective methods to create
    Share records for Account, PFA , PFR and banks.
    Added By:           Accenture - SB - 07/23/2018
    Modified By:        Date:       Changes:
    ******************************************************************************************************/
    public static void createObjectShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        try{
            //Call the method for creation of AccountShare records
                    //createAccountShareRecords(newPNUMappingMap);
                    addOrUpdateGeneralizeMap(newPNUMappingMap.values(), null);
                    if(accountIdUserIdListMap.size() > 0) {
                        //createCaseShareRecords(newPNUMappingMap);
                        createEscalationShareRecords(newPNUMappingMap);
                        //createCampaignShareRecords(newPNUMappingMap);
                    }  
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
        // JV- Accenture : Add the exception into Core_Log_Entry Object
    }

    /*****************************************************************************************************
    Method Name:        createCaseShareRecords
    @return  :          void
    @parameters:        None
    Description:        Whenever a record is added in the Node User Mapping object, the Case records
    associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
    Added By:           JV - 28/Nov/2018
    Accenture – Shridhar K       01/08/2019     Updated createCaseShareRecords to share case records only with claim submitter.
    Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
    ******************************************************************************************************/
   /*public static void createCaseShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
            
        String query = 'SELECT Id,AccountId FROM Case WHERE AccountId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Case', accountIdUserIdListMap, query, newPNUMappingMap), 50);
        
        
    }*/

    /*****************************************************************************************************
    Method Name:        createEscalationShareRecords
    @return  :          void
    @parameters:        None
    Description:        Whenever a record is added in the Node User Mapping object, the Escalation(Late claim type - RMF program) records
    associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
    Added By:           Accenture - Varun Dnyaneshwar - 08/06/2020
    ******************************************************************************************************/
    public static void createEscalationShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Id, Core_MDF_Escalation_Type_nm__c, Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c,'
            +' Core_MDF_Co_Marketing_Activity_id__c, Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId'
            +' FROM Core_MDF_Escalation__c WHERE Core_MDF_Escalation_Type_nm__c =  '+ '\'' +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_Status_Type')+ '\' '
            +' AND Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
            +' AND Core_MDF_Co_Marketing_Activity_id__c != NULL AND Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId != NULL AND '
            +' Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Core_MDF_Escalation__c', accountIdUserIdListMap, query, newPNUMappingMap), 50);
        
        
    }

    /*****************************************************************************************************
    Method Name:        createCampaignShareRecords
    @return  :          void
    @parameters:        None
    Description:        Whenever a record is added in the Node User Mapping object, the Campaign records
    associated with the Account record should be shared with the List of User Ids to which the Account record is shared for RMF Program.
    Added By:           Accenture - HP - 04/08/2020
    Modified By:        Accenture - HP - 04/08/2020
    ******************************************************************************************************/
    /*public static void createCampaignShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
    String query = 'SELECT Id, Core_MDF_Program__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c,'
                    +' Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c '
                    +' FROM Campaign WHERE (Core_MDF_Program__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
                    +' OR Core_MDF_Program__c = '+ '\'' +Label.Core_MDF_IPA_Program_Name+ '\' )'
                    +' AND (Core_MDF_Account__c IN : setOfAccounts OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c IN : setOfAccounts'
                    +' OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN ';
    Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Campaign', accountIdUserIdListMap, query, newPNUMappingMap), Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_PNUMBatchSizeForCampaign'));
    }*/

    /*****************************************************************************************************
    Method Name:        deleteObjectShareRecords
    @return  :          void
    @parameters:        oldPNUMappingMap, newPNUMappingMap, isDeleteDuringEdit
    Description:        Whenever a record is deleted from the Node User Mapping object, the AccountShare records, Partner
    Fund Allocation Share records and the Partner Fund Allocation Share records created because of
    it should be deleted.
    Added By:           Accenture - SB - 07/31/2018
    Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
    ******************************************************************************************************/
     public static void deleteObjectShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, boolean isDeleteDuringEdit) {
        List<Id> accountIdList = new List<Id>();
        try{
            for(Core_MDF_Partner_Node_User_Mapping__c pnuMappingRecord : oldPNUMappingList) {
                if(accountIdUserIdListMap.containsKey(pnuMappingRecord.Core_MDF_Account__c)) {
                    accountIdUserIdListMap.get(pnuMappingRecord.Core_MDF_Account__c).add(pnuMappingRecord.Core_MDF_User__c);
                }else{
                    accountIdUserIdListMap.put(pnuMappingRecord.Core_MDF_Account__c, new List<Id>{
                        pnuMappingRecord.Core_MDF_User__c}
                                            );
                }
            }
            // deleting share records
            Map<Id, List<Id>> tempAccountIdUserIdListMap = new Map<Id, List<Id>>(accountIdUserIdListMap);
            
            accountIdUserIdListMap.clear();
            if(isDeleteDuringEdit){
                addOrUpdateGeneralizeMap(newPNUMappingMap.values(), null);
            }
            
            // creating share records
            
            
            if(tempAccountIdUserIdListMap.size() > 0) {
                //deleteCaseShareRecords(oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap, tempAccountIdUserIdListMap);
                deleteEscalationShareRecords(oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap, tempAccountIdUserIdListMap);
                //deleteCampaignShareRecords(oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap, tempAccountIdUserIdListMap);
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
        // JV- Accenture : Add the exception into Core_Log_Entry Object
        
        accountIdUserIdListMap.clear();
    }


    /*****************************************************************************************************
    Method Name:        deleteCaseShareRecords
    @return  :          void
    @parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
    User Ids to which the Account record is shared.
    Description:        Whenever a record is deleted from the Node User Mapping object, the Case Share
    records created because of it should be deleted.
    Added By:           JV - 11/28/2018
    Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
    ******************************************************************************************************/
    /*public static void deleteCaseShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
            
        String query = 'SELECT Id, AccountId FROM Case WHERE AccountId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('CaseShare', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 50);
        
        
    }*/

    /*****************************************************************************************************
    Method Name:        deleteEscalationShareRecords
    @return  :          void
    @parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
    User Ids to which the Account record is shared.
    Description:        Whenever a record is deleted from the Node User Mapping object, the Escalation Share
    records created because of it should be deleted.
    Added By:           Accenture - Varun Dnyaneshwar - 10/06/2020
    ******************************************************************************************************/
    public static void deleteEscalationShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, Core_MDF_Escalation_Type_nm__c, Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c,'
            +' Core_MDF_Co_Marketing_Activity_id__c, Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId'
            +' FROM Core_MDF_Escalation__c WHERE Core_MDF_Escalation_Type_nm__c =  '+ '\'' +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_Status_Type')
            + '\' '
            +' AND Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
            +' AND Core_MDF_Co_Marketing_Activity_id__c != NULL AND Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId != NULL AND '
            +' Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('Core_MDF_Escalation__Share', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 50);
        
        
    }
    /*****************************************************************************************************
    Method Name:        deleteCampaignShareRecords
    @return  :          void
    @parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
    User Ids to which the Account record is shared for RMF Program.
    Description:        Whenever a record is deleted from the Node User Mapping object, the Campaign Share
    records created because of it should be deleted.
    Added By:           Accenture - HP - 04/08/2020
    Modified By:        Accenture - HP - 04/08/2020
    ******************************************************************************************************/
    /*public static void deleteCampaignShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        String query = 'SELECT Id, Core_MDF_Program__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c,'
                        +' Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c '
                        +' FROM Campaign WHERE (Core_MDF_Program__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
                        +' OR Core_MDF_Program__c = '+ '\'' +Label.Core_MDF_IPA_Program_Name+ '\' )'
                        +' AND (Core_MDF_Account__c IN : setOfAccounts OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c IN : setOfAccounts'
                        +' OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('CampaignShare', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_PNUMBatchSizeForCampaign'));
    }*/

    /*****************************************************************************************************
    Method Name:        StopRecurrsion
    @return  :          Boolean
    @parameters:        oldPNUMappingMap & newPNUMappingMap -
    Description:
    Added By:           Accenture - Krishna Kulkarni - 10/04/2019
    Modified By:        Date:       Changes:
    ******************************************************************************************************/
    public static Boolean isAccountUserUpdated(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingMap, 
    Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        try{
            //To stop recursion - If same account & user but error message changed then block & return false
            
            for(Id pnumId : oldPNUMappingMap.keySet()) {
                if(newPNUMappingMap.containsKey(pnumId)) {
                    
                    if((oldPNUMappingMap.get(pnumId).Core_MDF_Account__c == newPNUMappingMap.get(pnumId).Core_MDF_Account__c) && 
                    (oldPNUMappingMap.get(pnumId).Core_MDF_User__c == newPNUMappingMap.get(pnumId).Core_MDF_User__c) && (oldPNUMappingMap.get(pnumId).Core_MDF_Error_Details_txt__c != newPNUMappingMap.get(pnumId).Core_MDF_Error_Details_txt__c) && (newPNUMappingMap.get(pnumId).Core_MDF_Error_Details_txt__c != null) && (newPNUMappingMap.get(pnumId).Core_MDF_Error_Details_txt__c.length() > 0)) {return false;
                                                                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                                                                                                            }
                }
            }
           
            return true;       }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}        
        
    }

    /*****************************************************************************************************
    Method Name:        clearErrorField
    @return  :          void
    @parameters:        newPNUMappingMap
    Description:        Whenever a record is updated from the Node User Mapping object, Error Field needs to be clear
    Added By:           Accenture - KK - 12/12/2019
    ******************************************************************************************************/
    public static void clearErrorField(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        try{
            if(newPNUMappingMap != null) {
                for(Core_MDF_Partner_Node_User_Mapping__c pnuMappingRecord : newPNUMappingMap.values()) {
                    pnuMappingRecord.Core_MDF_Error_Details_txt__c = '';
                }
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
    }
    
 }