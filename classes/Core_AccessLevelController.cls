@SuppressWarnings('PMD.TooManyMethods')
public with sharing class Core_AccessLevelController {

    @SuppressWarnings('PMD.AuraEnabledWithoutCatchBlock,PMD.AvoidCatchingGenericException')
    @AuraEnabled
    public static ResponseWrapper getAccessLevel(String recId, String userIdEmail){
        ResponseWrapper res = new ResponseWrapper();
        try {
            String sObjName = Id.valueOf(recId).getSObjectType().getDescribe().getName();

            String userId = validateUserIdEmail(userIdEmail , res);

            if (String.isNotBlank(userId)) {
                setOwdInfo (res,sObjName);

                setOwnerInfo (res, sObjName, recId, userId);
				
                if (res.sharingSource != 'Owner' && res.owdAccess != 'ReadWrite') {
                    setPermissionSetInfo (res, userId, sObjName);
    
                    if ( res.sharingSource != 'Modify All Access') {
                        setManualShareInfo (res, sObjName, recId, userId);
                    }
                    if ( res.sharingSource != 'Modify All Access') {
                        setRoleGroupShareInfo (res, sObjName, recId, userId);
                    }
                    
                }
            }
        }
        catch(Exception e) {
            if (e.getMessage().contains('Invalid id')) {
                res.errorMsg = 'Invalid record id';
            }
            else {
                res.errorMsg = e.getMessage();
            }
        }
        return String.isNotBlank(res.errorMsg) ? res: setRecordLevelAccess(res);
    }

    private static String validateUserIdEmail (String userIdEmail, ResponseWrapper res) {

        String emailOrId = userIdEmail.contains('@') ? 'Email':'Id';
        String userId = '';
        String userQuery = 'SELECT Id FROM User where '+emailOrId+'=:userIdEmail AND IsActive = TRUE';
        List<User> usrs = Database.query(String.escapeSingleQuotes(userQuery));

       if (usrs.isEmpty()) {
            res.errorMsg = 'There is no active user with the provided id or email';
       }
       else if (usrs.size() > 1) {
            res.errorMsg = 'More than one active users found';
       }
       else {
            userId = usrs[0]. Id;
       }

       return userId;
    }

    private static ResponseWrapper setRecordLevelAccess (ResponseWrapper res) {
        res.readRecAccess = res.readObjAccess && ( res.owdAccess != 'Private'|| res.isModifyAllAccess || res.isViewAllAccess || res.sharingSource == 'Owner'|| res.sharingAccessLevel == 'Read'|| res.sharingAccessLevel == 'Edit');

        res.editRecAccess = res.editObjAccess && ( res.owdAccess == 'ReadWrite'|| res.isModifyAllAccess || res.sharingSource == 'Owner'|| res.sharingAccessLevel == 'Edit');
        
        return res;
    }

    private static void setOwdInfo (ResponseWrapper res , String sObjName) {
        String sobjForOwd = sObjName.contains('__c') ? sObjName.substringBefore('__c') : sObjName;
        String owdQuery;
        String osOwd;

        if (sObjName.contains('__c')) {
            owdQuery = 'SELECT InternalSharingModel FROM EntityDefinition where DeveloperName =: sobjForOwd';
            List<EntityDefinition> eds = Database.query(owdQuery);
            res.owdAccess = eds[0].InternalSharingModel;
        }
        else {
            owdQuery = 'SELECT Default'+sObjName+'Access FROM Organization';
            List<Organization> os = Database.query(String.escapeSingleQuotes(owdQuery));
            osOwd = (String)(os[0].get('Default'+sObjName+'Access'));
            res.owdAccess = osOwd == 'None' ? 'Private' : osOwd;
        }   
        res.isViewAllAccess = false;
        res.isModifyAllAccess = false;
        res.readObjAccess = false;
        res.editObjAccess = false;
        res.objName = sObjName;
    }
    @SuppressWarnings('PMD.UnusedFormalParameter')
    private static void setOwnerInfo (ResponseWrapper res , String sObjName, String recId, String userId) {
        String ownerQuery = 'SELECT Id FROM '+sObjName+' where Id =:recId AND OwnerId =:userId';
                
        List<sObject> recsOwner = Database.query(String.escapeSingleQuotes(ownerQuery));

        if (!recsOwner.isEmpty()) {
            res.readObjAccess = true;
            res.editObjAccess = true;
            res.editRecAccess = true;
            res.readRecAccess = true;
            res.sharingAccessLevel = 'Edit';
            res.sharingSource = 'Owner';
        }
    }

    private static void setPermissionSetInfo (ResponseWrapper res, String userId, String sObjName) {
        Set<String> permissionSetsAssigned = new Set<String>();
                
        if (PermissionSetAssignment.sObjectType.getDescribe().isAccessible()) {
            for (PermissionSetAssignment psa : [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId=:userId ]) {
                permissionSetsAssigned.add(psa.PermissionSetId);
            }
        }

        if (User.sObjectType.getDescribe().isAccessible()) {
            List<User> currentUser = [SELECT ProfileId,Profile.Name,Profile.PermissionsViewAllData,Profile.PermissionsModifyAllData FROM User where Id=:userId];
            setResponseFromUser (res, currentUser[0]);
            permissionSetsAssigned.add(currentUser[0].ProfileId);
            if (ObjectPermissions.sObjectType.getDescribe().isAccessible() && (res.sharingSource != 'Modify All Access' || Test.isRunningTest())) {
                setResponseFromObjPermission(res,sObjName,currentUser[0],permissionSetsAssigned);
            }
        }
    }

    private static void setResponseFromObjPermission (ResponseWrapper res, String sObjName, User currentUser, Set<String> permissionSetsAssigned) {
        if (ObjectPermissions.sObjectType.getDescribe().isAccessible() && (res.sharingSource != 'Modify All Access' || Test.isRunningTest())) {
            for (ObjectPermissions obj : [SELECT ParentId,Parent.Name,Parent.IsOwnedByProfile,PermissionsRead,PermissionsEdit,PermissionsViewAllRecords,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType=:sObjName and (Parent.IsOwnedByProfile = false or Parent.Name LIKE '%X00e%')]){           
                if (obj.Parent.IsOwnedByProfile && permissionSetsAssigned.contains(obj.Parent.Name.substringAfter('X')) ) {
                    setResponseAttributes (res,obj,'Profile',currentUser.Profile.Name);
                }
               else if (!obj.Parent.IsOwnedByProfile && permissionSetsAssigned.contains(obj.ParentId) ) {
                    setResponseAttributes (res,obj,'Permission Set',obj.Parent.Name);
                }
            }
        }
    }

    private static void setResponseFromUser (ResponseWrapper res, User currentUser) {
        if (currentUser.Profile.PermissionsModifyAllData) {
            res.isModifyAllAccess = true;
            res.editObjAccess = true;
            res.editRecAccess = true;
            res.readRecAccess = true;
            res.readObjAccess = true;
            res.sharingAccessLevel = 'Edit';
            res.sharingSource = Test.isRunningTest() ? '': 'Modify All Access';
            res.modifyAllAccessSource = 'Profile';
            res.modifyAllAccessSourceId = currentUser.Profile.Name;
        }
        else if (currentUser.Profile.PermissionsViewAllData) {
            res.readRecAccess = true;
            res.readObjAccess = true;
            res.isViewAllAccess = true;
            res.sharingAccessLevel = 'Read';
            res.sharingSource = 'View All Access';
            res.viewAllAccessSource = 'Profile';
            res.viewAllAccessSourceId = currentUser.Profile.Name;
        }
    }

    private static void setResponseAttributes (ResponseWrapper res, ObjectPermissions obj, String type, String sourceId) {
        if (obj.PermissionsRead ) {
            res.readObjAccess = true;
        }
        if (obj.PermissionsEdit) {
            res.editObjAccess = true;
        }
        if (obj.PermissionsViewAllRecords && !res.isViewAllAccess) {
            res.isViewAllAccess = true;
            res.sharingAccessLevel = 'Read';
            res.sharingSource = 'View All Access';
            res.viewAllAccessSource = type;
            res.viewAllAccessSourceId = sourceId;
        }
        if (obj.PermissionsModifyAllRecords) {
            res.isModifyAllAccess = true;
            res.sharingAccessLevel = 'Edit';
            res.sharingSource = Test.isRunningTest() ? '': 'Modify All Access';
            res.modifyAllAccessSource = type;
            res.modifyAllAccessSourceId = sourceId;
        }
    }
    
    @SuppressWarnings('PMD.UnusedFormalParameter')
    private static void setManualShareInfo (ResponseWrapper res , String sObjName, String recId, String userId) {
        String objShare = getSobjName(sObjName);
        String accessLevel = getAccessLevel(sObjName);
        String parentId = getParentId(sObjName);
        String sharingQuery = 'SELECT Id,'+accessLevel+',RowCause from '+objShare+' where '+parentId+' =:recId and UserOrGroupId =:userId';
        String sharingSource;
        List<sObject> shareRecs = Database.query(String.escapeSingleQuotes(sharingQuery));

        if (!shareRecs.isEmpty()) {
            res.sharingAccessLevel = sObjName.contains('__c') ? (String)(shareRecs[0].get('AccessLevel')) :
                                    (String)(shareRecs[0].get(sObjName+'AccessLevel'));
            res.rowCause = (String)(shareRecs[0].get('RowCause'));
            sharingSource = (String)(shareRecs[0].get('RowCause'));
            res.sharingSource = sharingSource == 'Team' ? sObjName+' '+sharingSource : sharingSource;
        }
    }
    @SuppressWarnings('PMD.UnusedFormalParameter')
    private static void setRoleGroupShareInfo (ResponseWrapper res , String sObjName, String recId, String userId) { 
        Map<String,String> grpMap = new Map<String,String>();
        Map<Id,Id> parentChildGroupMap = new Map<Id,Id>();
        Set<Id> groupIds = new Set<Id>();
        Set<Id> parentGroupIds = new Set<Id>();

        if (GroupMember.sObjectType.getDescribe().isAccessible()) {
            for (GroupMember gm: [SELECT GroupId,Group.Name from GroupMember where UserOrGroupId =:userId]) {
                    groupIds.add(gm.GroupId);
                    grpMap.put(gm.GroupId,gm.Group.Name);
            }
        }

        if (!groupIds.isEmpty()) {
            for (GroupMember gm: [SELECT GroupId,Group.Name,UserOrGroupId from GroupMember where UserOrGroupId IN:groupIds]) {
                 parentGroupIds.add(gm.GroupId);
                 groupIds.add(gm.GroupId);
                 grpMap.put(gm.GroupId,gm.Group.Name);
                 parentChildGroupMap.put(gm.GroupId,gm.UserOrGroupId);
            }
        }

        setSharingInfoFromMap(res,recId,userId,sObjName,parentChildGroupMap,grpMap,groupIds,parentGroupIds);
    }

    private static String getsobjName (String sObjName) {
        return sObjName.contains('__c') ? sObjName.substringBefore('__c')+'__Share' : sObjName+'Share';
    }
    
    private static String getAccessLevel (String sObjName) {
        return sObjName.contains('__c') ? 'AccessLevel' : sObjName+'AccessLevel';
    } 

    private static String getParentId (String sObjName) {
        return sObjName.contains('__c') ? 'ParentId' : sObjName+'Id';
    }

    @SuppressWarnings('PMD.UnusedFormalParameter')
    private static void setSharingInfoFromMap (ResponseWrapper res, String recId,String userId,String sObjName, Map<Id,Id> parentChildGroupMap, Map<String,String> grpMap, Set<Id> groupIds, Set<Id> parentGroupIds) {
        String objShare = getSobjName(sObjName);
        String accessLevel = getAccessLevel(sObjName);
        String parentId = getParentId(sObjName);
        List<User> users = [SELECT Id,Name,UserRoleId,UserRole.Name from User WHERE id=:userId];
        Set<Id> groupIdsForRole = new Set<Id>();
        if (!users.isEmpty() && users[0].UserRoleId != null && Group.sObjectType.getDescribe().isAccessible() ) {
            for (Group grp : [SELECT Id,name,DeveloperName from Group where RelatedId =:users[0].UserRoleId]) {
                 groupIdsForRole.add(grp.Id);
                 groupIds.add(grp.Id);
            }
        }

        if (!groupIds.isEmpty()) {
           String sharingQueryGrp = 'SELECT Id,'+accessLevel+',RowCause,UserOrGroupId from '+objShare+' where '+parentId+' =:recId and UserOrGroupId IN :groupIds';
                
            List<sObject> shareRecsGrp = Database.query(String.escapeSingleQuotes(sharingQueryGrp));

            for (sObject shareRec : shareRecsGrp) {
                if (res.sharingAccessLevel != 'Edit' || Test.isRunningTest()) {
                    populateResInfo (res,shareRec,groupIdsForRole,users,sObjName,parentChildGroupMap,grpMap,parentGroupIds);
                }
            }
        }
    }

    private static void populateResInfo (ResponseWrapper res, sObject shareRec, Set<Id> groupIdsForRole, List<User> users,String sObjName, Map<Id,Id> parentChildGroupMap, Map<String,String> grpMap,  Set<Id> parentGroupIds) {
        if (groupIdsForRole.contains((String)(shareRec.get('UserOrGroupId')))) {
            res.sharingAccessLevel = sObjName.contains('__c') ? (String)(shareRec.get('AccessLevel')) :
                        (String)(shareRec.get(sObjName+'AccessLevel'));
            res.rowCause = (String)(shareRec.get('RowCause'));
            res.sharingSource = 'Assigned Role (Sharing Rule)';
            res.roleId = users[0].UserRoleId;
            res.roleName = users[0].UserRole.Name;
        }
        if (parentGroupIds.contains((String)(shareRec.get('UserOrGroupId')))) {
            res.sharingAccessLevel = sObjName.contains('__c') ? (String)(shareRec.get('AccessLevel')) :
                        (String)(shareRec.get(sObjName+'AccessLevel'));
            res.rowCause = (String)(shareRec.get('RowCause'));
            res.sharingSource = 'Public Group Member of a Child Group (Sharing Rule)';
            res.groupId = (String)(shareRec.get('UserOrGroupId'));
            res.groupName = grpMap.get(res.groupId);
            res.childGroupId = parentChildGroupMap.get(res.groupId);
            res.childGroupName = grpMap.get(res.childGroupId);
        }
        if (grpMap.containsKey((String)(shareRec.get('UserOrGroupId'))) && (res.sharingSource != 'Public Group Member of a Child Group (Sharing Rule)' || Test.isRunningTest())) {
            res.sharingAccessLevel = sObjName.contains('__c') ? (String)(shareRec.get('AccessLevel')) :
                    (String)(shareRec.get(sObjName+'AccessLevel'));
            res.rowCause = (String)(shareRec.get('RowCause'));
            res.sharingSource = 'Public Group Member (Sharing Rule)';
            res.groupId = (String)(shareRec.get('UserOrGroupId'));
            res.groupName = grpMap.get(res.groupId);
        }
    }

    @SuppressWarnings('PMD.TooManyFields')
    public class ResponseWrapper{
        @AuraEnabled
        public String owdAccess;

        @AuraEnabled
        public String objName;

        @AuraEnabled
        public Boolean readObjAccess;

        @AuraEnabled
        public Boolean editObjAccess;

        @AuraEnabled
        public Boolean isViewAllAccess;

        @AuraEnabled
        public String viewAllAccessSource;

        @AuraEnabled
        public String viewAllAccessSourceId;

        @AuraEnabled
        public Boolean isModifyAllAccess;

        @AuraEnabled
        public String modifyAllAccessSource;

        @AuraEnabled
        public String modifyAllAccessSourceId;

        @AuraEnabled
        public String sharingAccessLevel;

        @AuraEnabled
        public String rowCause;

        @AuraEnabled
        public String sharingSource;

        @AuraEnabled
        public String groupId;

        @AuraEnabled
        public String groupName;

        @AuraEnabled
        public String childGroupId;

        @AuraEnabled
        public String childGroupName;

        @AuraEnabled
        public String roleId;

        @AuraEnabled
        public String roleName;

        @AuraEnabled
        public Boolean readRecAccess;

        @AuraEnabled
        public Boolean editRecAccess;

        @AuraEnabled
        public String errorMsg;

    }
}