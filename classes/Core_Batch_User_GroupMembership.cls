/**************************************************************************************
Apex Class Name:  Core_Batch_User_GroupMembership
Version     : 1.0 
Created Date: 11/30/2016
Function    : Ensure that users are assigned correctly to groups based on their type.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Aran Wongsaprome            11/30/2016             New
* Zay Montalbo                 5/24/2017             fix: removal of groups
*************************************************************************************/
global class Core_Batch_User_GroupMembership implements Database.Batchable<User> {

    // Compare the user type to the group that it should be assigned to, returning Users not assigned correctly.
    global List<User> CompareGroup(string Field, string Value, string ExpectedGroup){
        System.debug('Entering CompareGroup: ' + Field + ',  ' + Value + ',  ' + ExpectedGroup);
        List<Group> G = [ SELECT id FROM Group WHERE DeveloperName = :ExpectedGroup ];
        if(!G.isEmpty()) {
            id GroupID = G[0].id;
            Set<id> Members = new Set<id>();
            for (GroupMember M : [ SELECT UserOrGroupId FROM GroupMember WHERE groupid = :GroupID ]) {
                Members.add(M.UserOrGroupId);
            }
            if(Field == 'Core_Employee_Type_Code__c' && !Members.isEmpty()) {
                System.debug('Exiting CompareGroup');
                return [
                    SELECT id, Core_Employee_Type_Code__c, Username, alias
                    FROM User
                    WHERE Core_Employee_Type_Code__c = :Value
                    AND Profile.UserLicense.Name = 'Salesforce'
                    AND id NOT IN :Members
                    AND IsActive = true
                ];
            }
        }
        System.debug('Exiting CompareGroup: no results');
        return null;
    }

    // Query each rule until one is found which is not properly applied to users in the system. Otherwise
    // return empty result set.
    global List<User> CompareAllRules() {
        List<User> Users = new List<User>();
        for(Core_User_Group_Rule__c Rule : Core_User_Group_Rule__c.getAll().values()) {
            if(Rule.Core_Field_Name__c == 'Core_Employee_Type_Code__c') {
                Users.addAll(CompareGroup(Rule.Core_Field_Name__c, Rule.Core_Field_Value__c, Rule.Core_Group_Name__c));
                System.debug('Zay - inside Core_Batch_User_Group_Membmership - User List Count - ' + Users.size());
            }
        }
        // For inversion of control unit test, to limit the result set:
        List<User> IOC = new List<User>();
        for(User U : Users) if(U.Alias == 'IOCU') IOC.Add(U);
        return IOC.IsEmpty() ? Users : IOC;
    }

    // This implements the interface batchable.
    global Iterable<User> start(Database.BatchableContext BC) {
        return CompareAllRules();
    }
  
    global Map<Id,GroupMember> createUserGroupMemberMap(String groupId) {
        Map<Id,GroupMember> userGroupMemberMap = new Map<Id,GroupMember>();
        for(GroupMember grpMemObj : [Select Id, UserOrGroupID from GroupMember Where GroupId =:groupId]) {
            userGroupMemberMap.put(grpMemObj.UserOrGroupId, grpMemObj);
        }
        return userGroupMemberMap;
    }
    
    // This implements the interface batchable. It updates the given list of users with correct 
    // group membership based on the mapping rules.
    global void execute(Database.BatchableContext BC, list<User> Users) {
        if(Users.isEmpty()) return;
        System.Debug('Zay - inside batch execute - ' + Users);
        System.debug('Correcting group membership for users:');
        List<GroupMember> Members = new List<GroupMember>();
        List<GroupMember> Remove = new List<GroupMember>();
        Map<Id,GroupMember> employeeIdGroupMemberMap = createUserGroupMemberMap(Label.Core_All_Employees_Group_Id);
        Map<Id,GroupMember> ctwIdGroupMemberMap = createUserGroupMemberMap(Label.Core_All_CTW_Group_Id);
        Map<Id,GroupMember> nonbadgedIdGroupMemberMap = createUserGroupMemberMap(Label.Core_All_Non_Badged_Group_Id);
        
        for(User U : Users) {
            System.debug('Adding ' + U.Username);
            if(U.Core_Employee_Type_Code__c == 'EMP') {
                Members.add(new GroupMember(GroupID=Label.Core_All_Employees_Group_Id, UserOrGroupId=U.ID));
                if(ctwIdGroupMemberMap.containsKey(U.Id)) {
                    Remove.add(ctwIdGroupMemberMap.get(U.Id));
                }
                if(nonbadgedIdGroupMemberMap.containsKey(U.Id)) {
                    Remove.add(nonbadgedIdGroupMemberMap.get(U.Id));
                }
            }
            if(U.Core_Employee_Type_Code__c == 'CTW') {
                Members.add(new GroupMember(GroupID=Label.Core_All_CTW_Group_Id, UserOrGroupId=U.ID));
                if(employeeIdGroupMemberMap.containsKey(U.Id)) {
                    Remove.add(employeeIdGroupMemberMap.get(U.Id));
                }
                if(nonbadgedIdGroupMemberMap.containsKey(U.Id)) {
                    Remove.add(nonbadgedIdGroupMemberMap.get(U.Id));
                }
            }
            if(U.Core_Employee_Type_Code__c == 'Non-Badged') {
                Members.add(new GroupMember(GroupID=Label.Core_All_Non_Badged_Group_Id, UserOrGroupId=U.ID));
                if(ctwIdGroupMemberMap.containsKey(U.Id)) {
                    Remove.add(ctwIdGroupMemberMap.get(U.Id));
                }
                if(employeeIdGroupMemberMap.containsKey(U.Id)) {
                    Remove.add(employeeIdGroupMemberMap.get(U.Id));
                }
            }
        }
        Database.delete(Remove);
        Database.insert(Members);
    }
    
    // This implements the interface batchable. When batch is done, send an email to
    // the user who ran the batch with the result information.
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob Job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id = :BC.getJobId()
        ];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { Job.CreatedBy.Email });
        mail.setSubject('Batch Status: ' + Job.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + Job.TotalJobItems +
            ' items with '+ Job.NumberOfErrors + ' failures.');
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'wsm-postmaster@intel.com'LIMIT 1 ];
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}