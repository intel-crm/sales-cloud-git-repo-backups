/**************************************************************************************
Apex Class Name : Core_AssignRemove_PermissionSet
Version     : 1.0 
Created Date: 15th March 2020
Description : Invocable class assign and remove permission set from Process builder
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Vaibhav                  15/03/2020             Original Version
*************************************************************************************/

global class Core_AssignRemove_PermissionSet{
    @InvocableMethod(label='Assign Remove A&E Permission Set' description='Assigns and Removes Permission Sets for A&E ')
    global static void AssignRemove_PermissionSet(List<ID> contactEntitlementId) {
    Set<Id> contactIdSet = new Set<Id>();
    Set<String> permissionSetNameSet = new Set<String>();
    Set<Id> userIdSet = new Set<Id>();
    Map<String,String> contactIdUserIdMap = new Map<String,String>();
    List<PermissionSetAssignment> psaInsertList = new List<PermissionSetAssignment>();
    
    List<Core_Contact_Entitlement__c> contactEntitlementList = [SELECT Id, Core_Contact_Id__c, Core_Selected__c, Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c, Core_Entitlement_Id__r.Core_Display_Name__c FROM Core_Contact_Entitlement__c WHERE Id =: contactEntitlementId AND Core_Status__c = 'Complete' AND Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c != null];
    
    for(Core_Contact_Entitlement__c ent : contactEntitlementList){
        contactIdSet.add(ent.Core_Contact_Id__c);
        permissionSetNameSet.add(ent.Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c);
    }
    
    
    List<User> userList = [Select Id, ContactId from User where ContactId =: contactIdSet];
    for(User usr : userList){
        userIdSet.add(usr.Id);
        contactIdUserIdMap.put(usr.ContactId, usr.Id);
    }
    
    //Need map of contact and permission set needed
    Map<string,Set<string>> userPermissionSetExpectedMap = new Map<string,Set<string>>();
    for(Core_Contact_Entitlement__c ent : contactEntitlementList){
        if(ent.Core_Selected__c == True){
            if(userPermissionSetExpectedMap.containskey(contactIdUserIdMap.get(ent.Core_Contact_Id__c))){
                userPermissionSetExpectedMap.get(contactIdUserIdMap.get(ent.Core_Contact_Id__c)).add(ent.Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c);
            }
            else{
                Set<String> psNameSet = new Set<String>();
                psNameSet.add(ent.Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c);
                userPermissionSetExpectedMap.put(contactIdUserIdMap.get(ent.Core_Contact_Id__c), psNameSet);
            }
        }
        else{
        
        }
        
    }   
    system.debug('****userPermissionSetExpectedMap***'+userPermissionSetExpectedMap);
    
    List<PermissionSet> psforEntitlementList = [Select Id, Name from PermissionSet where Name =: permissionSetNameSet]; 
    Map<String,String> permissionSetNameIdMap = new Map<String,String>();
    for(PermissionSet ps : psforEntitlementList){
        if(!permissionSetNameIdMap.containsKey(ps.Name)){
            permissionSetNameIdMap.put(ps.Name, ps.Id);
        }
    }
    
    List<PermissionSetAssignment> userPSAList = [select AssigneeId, PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment WHERE Assignee.ContactId =: contactIdSet];
    Map<string,Set<string>> userPermissionSetAssignedMap = new Map<string,Set<string>>();   
    for(PermissionSetAssignment psa : userPSAList){
        if(userPermissionSetAssignedMap.containskey(psa.AssigneeId)){
            userPermissionSetAssignedMap.get(psa.AssigneeId).add(psa.PermissionSet.Name);           
        }
        else{
            Set<String> psNameSet = new Set<String>();
            psNameSet.add(psa.PermissionSet.Name);
            userPermissionSetAssignedMap.put(psa.AssigneeId, psNameSet);
        }
    }
    system.debug('****userPermissionSetAssignedMap***'+userPermissionSetAssignedMap);
    
    for(User usr : userList){
        if(userPermissionSetExpectedMap.containsKey(usr.Id)){
            for(string psName: userPermissionSetExpectedMap.get(usr.Id)){
                //Check for PS
                if(userPermissionSetAssignedMap.containsKey(usr.Id)){
                    if(!userPermissionSetAssignedMap.get(usr.Id).contains(psName)){
                        //create PSA
                        PermissionSetAssignment psa = new PermissionSetAssignment();
                        psa.AssigneeId = usr.Id;
                        psa.PermissionSetId = permissionSetNameIdMap.get(psName);
                        psaInsertList.add(psa);
                    }           
                }
                else{
                    //Create PSA for user
                    PermissionSetAssignment psa = new PermissionSetAssignment();
                    psa.AssigneeId = usr.Id;
                    psa.PermissionSetId = permissionSetNameIdMap.get(psName);
                    psaInsertList.add(psa);
                }
            }
        }
    }
    system.debug('****psaInsertList***'+psaInsertList);
    if(psaInsertList.size() > 0){
        //Use DB 
        //insert psaInsertList;
    }
}
}