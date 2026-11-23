/**************************************************************************************
Apex Class Name:  Core_MDF_MultiObjectBatchHandler
Version     : 1.0 
Created Date: 01/09/2025
Function    : 
Modification Log :
* Developer                   Date                   Description
*************************************************************************************/
public without sharing class Core_MDF_MultiObjectBatchHandler {
    
   
    
    public class Core_MDF_ObjectQuery {                
        public String objectName;
        public String queryCondition;
        public List<String> fields;
        public Map<String,String> mapOfApprovalStageToRole;
        public Map<String,String> mapOfPnumApprovalStageToRole;
        public Map<String, Map<String, List<String>>> mapOfProgramToApprovalStageToRolesList;
        public Map<String, Map<String, String>> mapOfProgramToGeoBasedToRole;
        public Map<String, Map<String, String>> mapOfProgramToBudgetTypeToQueue; 
        public Map<String, Map<String, String>> mapOfPrgmTOBudgetTypeTOPublicGrp;
        public Core_MDF_ObjectQuery(String objectName,String queryCondition,List<String> fields,Map<String,String> mapOfApprovalStageToRole,Map<String,String> mapOfPnumApprovalStageToRole,Map<String, Map<String, List<String>>> mapOfProgramToApprovalStageToRolesList,Map<String, Map<String, String>> mapOfProgramToGeoBasedToRole,Map<String, Map<String, String>> mapOfProgramToBudgetTypeToQueue,Map<String, Map<String, String>> mapOfPrgmTOBudgetTypeTOPublicGrp) {
            this.objectName = objectName;
            this.queryCondition = queryCondition;
            this.fields = fields;
            this.mapOfApprovalStageToRole = mapOfApprovalStageToRole;
            this.mapOfPnumApprovalStageToRole = mapOfPnumApprovalStageToRole;
            this.mapOfProgramToApprovalStageToRolesList = mapOfProgramToApprovalStageToRolesList;
            this.mapOfProgramToGeoBasedToRole = mapOfProgramToGeoBasedToRole;
            this.mapOfProgramToBudgetTypeToQueue=mapOfProgramToBudgetTypeToQueue;
            this.mapOfPrgmTOBudgetTypeTOPublicGrp=mapOfPrgmTOBudgetTypeTOPublicGrp;
            
        }
    }
    
    public static List<Core_MDF_ObjectQuery> prepareQueries() {
        
        List<Core_MDF_ObjectQuery> objectQueries = new List<Core_MDF_ObjectQuery>();
        List<String> fields = new List<String>();
        Map<String, String> mapOfApprovalStageToRole = new Map<String, String>();
        Map<String, String> mapOfPnumApprovalStageToRole = new Map<String, String>();
        Map<String, Map<String, List<String>>> mapOfProgramToApprovalStageToRolesList = new Map<String, Map<String, List<String>>>();
        Map<String, Map<String, String>> mapOfProgramToGeoBasedToRole = new Map<String, Map<String, String>>();
        Map<String, Map<String, String>> mapOfProgramToBudgetTypeToQueue = new Map<String, Map<String, String>>();
        Map<String, Map<String, String>> mapOfPrgmTOBudgetTypeTOPublicGrp = new Map<String, Map<String, String>>();
        
        
        
        
        for (Core_MDF_CCP_Custom_Metadata_Utility__c setting : [SELECT Id,Core_MDF_Field_1_txt__c,Core_MDF_Field_5_txt__c,Core_MDF_Field_6_txt__c,Core_MDF_Field_7_txt__c,Core_MDF_Field_9_txt__c,Core_MDF_Field_2_txt__c,Core_MDF_Program__c,
                                                                Core_MDF_Field_11_txt__c,Core_MDF_Is_Active_Ind__c,Core_MDF_Field_8_txt__c,Core_MDF_Field_15_txt__c,Core_MDF_Field_16_txt__c,Core_MDF_Field_12_txt__c 
                                                                FROM Core_MDF_CCP_Custom_Metadata_Utility__c WHERE Core_MDF_Category__c = 'Missed_Approver_Email_Notification'  
                                                                AND Core_MDF_Is_Active_Ind__c = true]) {
                                                                    
                                                                    if (!String.isBlank(setting.Core_MDF_Field_5_txt__c)) {
                                                                        fields = setting.Core_MDF_Field_5_txt__c.split(',');
                                                                    }
                                                                    if (!String.isBlank(setting.Core_MDF_Field_7_txt__c)) {
                                                                        mapOfApprovalStageToRole = (Map<String, String>) 
                                                                            JSON.deserialize(setting.Core_MDF_Field_7_txt__c, Map<String, String>.class);
                                                                    }
                                                                    if (!String.isBlank(setting.Core_MDF_Field_9_txt__c)) {
                                                                        mapOfPnumApprovalStageToRole = (Map<String, String>) 
                                                                            JSON.deserialize(setting.Core_MDF_Field_9_txt__c, Map<String, String>.class);
                                                                    }
                                                                    if (!String.isBlank(setting.Core_MDF_Field_8_txt__c)) {
                                                                        mapOfProgramToApprovalStageToRolesList = (Map<String, Map<String, List<String>>>) 
                                                                            JSON.deserialize(setting.Core_MDF_Field_8_txt__c, Map<String, Map<String, List<String>>>.class);
                                                                    }
                                                                    if (!String.isBlank(setting.Core_MDF_Field_15_txt__c)) {
                                                                        mapOfProgramToGeoBasedToRole = (Map<String, Map<String, String>>) 
                                                                            JSON.deserialize(setting.Core_MDF_Field_15_txt__c, Map<String, Map<String, String>>.class);
                                                                    }
                                                                    if (!String.isBlank(setting.Core_MDF_Field_16_txt__c)) {
                                                                        mapOfProgramToBudgetTypeToQueue = (Map<String, Map<String, String>>) 
                                                                            JSON.deserialize(setting.Core_MDF_Field_16_txt__c, Map<String, Map<String, String>>.class);
                                                                    }
                                                                    if (!String.isBlank(setting.Core_MDF_Field_12_txt__c)) {
                                                                        mapOfPrgmTOBudgetTypeTOPublicGrp = (Map<String, Map<String, String>>) 
                                                                            JSON.deserialize(setting.Core_MDF_Field_16_txt__c, Map<String, Map<String, String>>.class);
                                                                    }
                                                                    
                                                                    objectQueries.add(
                                                                        new Core_MDF_ObjectQuery(
                                                                            setting.Core_MDF_Field_1_txt__c,
                                                                            setting.Core_MDF_Field_6_txt__c,
                                                                            fields,
                                                                            mapOfApprovalStageToRole,
                                                                            mapOfPnumApprovalStageToRole,
                                                                            mapOfProgramToApprovalStageToRolesList,
                                                                            mapOfProgramToGeoBasedToRole,
                                                                            mapOfProgramToBudgetTypeToQueue,
                                                                            mapOfPrgmTOBudgetTypeTOPublicGrp
                                                                        )
                                                                    );
                                                                }
        return objectQueries;
    }
    
    /***************************************************************************************************
Method Name:  getRoleRegionCombinations 
Version     : 1.0 
Created Date: 01/09/2025
Function    : Each combination takes one value from each list and joins them with '|'.
Input Parameters: fields List of string lists representing different fields
Output Parameters: Set of strings containing all possible combinations
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rishabh                   01/09/2025             Created
* Rishabh                    01/09/2025             Modified
****************************************************************************************************/
    public static Set<String> getRoleRegionCombinations(List<List<String>> fields) { // to know the how method works--nd refactor
        Set<String> result = new Set<String>();
        result.add(''); // start with empty combination
        
        for (List<String> fieldValues : fields) {
            // If this field list is empty, treat it as a single empty string → don't break combinations
            if (fieldValues == null || fieldValues.isEmpty()) {
                fieldValues = new List<String>{''};
                    }
            
            Set<String> newResult = new Set<String>();
            
            for (String prefix : result) {
                for (String val : fieldValues) {
                    val = val != null ? val.trim() : '';
                    String combo = (String.isBlank(prefix)) ? val : prefix + (String.isNotBlank(val) ? '|' + val : '');
                    newResult.add(combo);
                }
            }
            result = newResult;
        }
        return result;
    }
    /***************************************************************************************************
Method Name:  buildUniqueKey 
Version     : 1.0 
Created Date: 01/09/2025
Function    : Each part is trimmed and concatenated using the '|' character.
Input Parameters: parts List of strings to include in the key
Output Parameters: A single string representing the unique key
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rishabh                   01/09/2025             Created
* Rishabh                    01/09/2025             Modified
****************************************************************************************************/
    public static String buildUniqueKey(List<String> parts) { 
        List<String> safeParts = new List<String>();
        for (String p : parts) {                     // update p varible
            if (p != null && p.trim() != '') {
                safeParts.add(p.trim());
            }
        }
        return String.join(safeParts, '|');
    }
    /***************************************************************************************************
Method Name:  getPublicGroupsWithActiveUsers 
Version     : 1.0 
Created Date: 01/09/2025
Function    : Returns the names (or Ids) of public groups that have at least one active user.
Input Parameters: groupNames (or groupIds) Set of Public Group names (or Ids) to check
Output Parameters: Set of group names (or Ids) that contain at least one active user
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rishabh                   01/09/2025             Created
* Rishabh                    01/09/2025             Modified
****************************************************************************************************/
    public static Set<String> getPublicGroupsWithActiveUsers(Set<String> groupNames) {
        Set<String> result = new Set<String>();
        
        final String USER_PREFIX  = '005';
        
        // Step 1: Get Public Groups by Name
        Map<String, Id> nameToGroupId = new Map<String, Id>();
        for (Group g : [SELECT Id, Name FROM Group WHERE Type = 'Regular' AND Name IN :groupNames]) {
            nameToGroupId.put(g.Name, g.Id);
        }
        
        // Step 2: Collect all user members (direct users only)
        Map<Id, Set<Id>> groupIdToUsers = new Map<Id, Set<Id>>();
        Set<Id> allUserIds = new Set<Id>();
        
        for (GroupMember gm : [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :nameToGroupId.values()
                              ]) {
                                  if (String.valueOf(gm.UserOrGroupId).startsWith(USER_PREFIX)) {
                                      if (!groupIdToUsers.containsKey(gm.GroupId)) {
                                          groupIdToUsers.put(gm.GroupId, new Set<Id>());
                                      }
                                      groupIdToUsers.get(gm.GroupId).add(gm.UserOrGroupId);
                                      allUserIds.add(gm.UserOrGroupId);
                                  }
                              }
        
        // Step 3: Query active users
        Set<Id> activeUsers = new Set<Id>();
        if (!allUserIds.isEmpty()) {
            for (User u : [SELECT Id FROM User WHERE Id IN :allUserIds AND IsActive = true
                          ]) {
                              activeUsers.add(u.Id);
                          }
        }
        
        // Step 4: Return only groups with at least one active user
        for (String gName : nameToGroupId.keySet()) {
            Id gId = nameToGroupId.get(gName);
            if (groupIdToUsers.containsKey(gId)) {
                Set<Id> members = groupIdToUsers.get(gId);
                if (!members.isEmpty()) {
                    Set<Id> intersection = new Set<Id>(members);
                    intersection.retainAll(activeUsers);
                    if (!intersection.isEmpty()) {
                        result.add(gName);
                    }
                }
            }
        }
        
        return result;
    }
    /***************************************************************************************************
Method Name:  getPublicGroupsWithActiveUsers 
Version     : 1.0 
Created Date: 01/09/2025
Function    : Checks both direct users (005) and users inside public groups (00G)(Returns the API names of queues that have at least one active user).
Input Parameters: queueApiNames Set of queue DeveloperNames (API names) to check
Output Parameters: Set of queue API names that contain at least one active user
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rishabh                   01/09/2025             Created
* Rishabh                    01/09/2025             Modified
****************************************************************************************************/
    public static Set<String> getQueuesWithActiveUsers(Set<String> queueApiNames) {
        Set<String> result = new Set<String>();
        
        // Step 1: Get Queue Groups by DeveloperName
        Map<Id, String> queueIdToApiName = new Map<Id, String>();
        for (Group grp : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :queueApiNames]) {
            queueIdToApiName.put(grp.Id, grp.DeveloperName);
        }
        if (queueIdToApiName.isEmpty()) return result;
        
        // Step 2: Get Queue Members
        Map<Id, Set<Id>> queueIdToMemberIds = new Map<Id, Set<Id>>();
        Set<Id> allUserIds = new Set<Id>();
        Set<Id> publicGroupIds = new Set<Id>();
        
        for (GroupMember gm : [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :queueIdToApiName.keySet()]) {
            if (!queueIdToMemberIds.containsKey(gm.GroupId)) {
                queueIdToMemberIds.put(gm.GroupId, new Set<Id>());
            }
            queueIdToMemberIds.get(gm.GroupId).add(gm.UserOrGroupId);
            
            String prefix = String.valueOf(gm.UserOrGroupId).substring(0,3);
            if (prefix == '005') {
                allUserIds.add(gm.UserOrGroupId);
            } else if (prefix == '00G') {
                publicGroupIds.add(gm.UserOrGroupId);
            }
        }
        // Step 4: Expand Public Groups → Users
        Map<Id, Set<Id>> publicGroupToUsers = new Map<Id, Set<Id>>();
        Set<Id> pgUserIds = new Set<Id>();
        if (!publicGroupIds.isEmpty()) {
            for (GroupMember gm : [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :publicGroupIds]) {
                String prefix = String.valueOf(gm.UserOrGroupId).substring(0,3);
                if (prefix == '005') {
                    if (!publicGroupToUsers.containsKey(gm.GroupId)) {
                        publicGroupToUsers.put(gm.GroupId, new Set<Id>());
                    }
                    publicGroupToUsers.get(gm.GroupId).add(gm.UserOrGroupId);
                    pgUserIds.add(gm.UserOrGroupId);
                }
            }
        }
        Set<Id> activeUsers = new Set<Id>();
        Set<Id> allActiveUserPresentInBothPublicOrDirectInQueue = new Set<Id>();
        allActiveUserPresentInBothPublicOrDirectInQueue.addAll(allUserIds);
        allActiveUserPresentInBothPublicOrDirectInQueue.addAll(pgUserIds);
        
        if (!allActiveUserPresentInBothPublicOrDirectInQueue.isEmpty()) {
            for (User u : [SELECT Id FROM User WHERE Id IN :allActiveUserPresentInBothPublicOrDirectInQueue AND IsActive = true]) {
                activeUsers.add(u.Id);
            }
        }
        
        // Step 5: Final Check → Does queue have active users?
        for (Id qId : queueIdToApiName.keySet()) {
            if (!queueIdToMemberIds.containsKey(qId)) continue;
            
            Set<Id> members = queueIdToMemberIds.get(qId);
            Set<Id> expandedUserIds = new Set<Id>();
            
            for (Id mId : members) {
                String prefix = String.valueOf(mId).substring(0,3);
                
                if (prefix == '005') {
                    expandedUserIds.add(mId);
                } else if (prefix == '00G' && publicGroupToUsers.containsKey(mId)) {
                    expandedUserIds.addAll(publicGroupToUsers.get(mId));
                }
            }
            
            Set<Id> activeIntersection = new Set<Id>(expandedUserIds);
            activeIntersection.retainAll(activeUsers);
            
            if (!activeIntersection.isEmpty()) {
                result.add(queueIdToApiName.get(qId));
            }
        }
        
        return result;
    }
    
    
    
}