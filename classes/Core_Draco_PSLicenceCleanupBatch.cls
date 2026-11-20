/**************************************************************************************
Apex Class Name : Core_Draco_PSLicenceCleanupBatch
Version     : 1.0 
Created Date: 28th May 2024
Description : Utility class cleanup Permission Set License from the user record who does not have permission set assigned
* Modification Log :
* Developer                 Date               		Description
* ----------------------------------------------------------------------------
* Akshay                  28-May-2024             	Original Version
*************************************************************************************/
global without sharing class Core_Draco_PSLicenceCleanupBatch implements Database.Batchable<sObject>, Database.Stateful{
	
    global Database.QueryLocator start(Database.BatchableContext BC){   
        List<String> PSLicenseNameList = System.Label.Core_Draco_PSLicenceCleanup.split(';'); //Get the list of PS Licence we want to cleanup from the Core_Draco_PSLicenceCleanup custom label
        String query = '';
        if(Test.isRunningTest()){
            query = 'SELECT id, AssigneeId, PermissionSetLicenseId, PermissionSetLicense.DeveloperName FROM PermissionSetLicenseAssign WHERE PermissionSetLicense.DeveloperName IN :PSLicenseNameList LIMIT 200';
        } else{
            query = 'SELECT id, AssigneeId, PermissionSetLicenseId, PermissionSetLicense.DeveloperName FROM PermissionSetLicenseAssign WHERE PermissionSetLicense.DeveloperName IN :PSLicenseNameList';
        }
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<PermissionSetLicenseAssign> lstPSLicenseAssign){
        set<Id> assigneeIds = new set<Id>();
        set<Id> psLicenseIds = new set<Id>();
		map<Id, List<Id>> pslaToAssigneeMap = new map<Id, List<Id>>();        
        // Collect all AssigneeIds
        for(PermissionSetLicenseAssign psla : lstPSLicenseAssign){
            assigneeIds.add(psla.AssigneeId);
            psLicenseIds.add(psla.PermissionSetLicenseId);
            if(!pslaToAssigneeMap.containsKey(psla.PermissionSetLicenseId)){
                pslaToAssigneeMap.put(psla.PermissionSetLicenseId, new List<Id>());
            }
            pslaToAssigneeMap.get(psla.PermissionSetLicenseId).add(psla.AssigneeId);
        }
        
        // Query to get Permission Sets associated with PS Licenses
        List<PermissionSet> psList = [SELECT Id, LicenseId FROM PermissionSet WHERE LicenseId IN :psLicenseIds];
        Map<Id, set<Id>> licenseToPSSetMap = new Map<Id, set<Id>>(); 
        for(PermissionSet ps : psList){
            if(!licenseToPSSetMap.containsKey(ps.LicenseId)){
                licenseToPSSetMap.put(ps.LicenseId, new Set<Id>());
            }
            licenseToPSSetMap.get(ps.LicenseId).add(ps.Id);
        }
        
        // Query to get Permission Set Assignments for the collected AssigneeIds
        List<PermissionSetAssignment> psaList = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :assigneeIds];
    	
        // Map to track users with valid Permission Set Assignments
        Map<Id, set<Id>> userToPSSetMap = new Map<Id, set<Id>>();
        for(PermissionSetAssignment psa : psaList){
            if(!userToPSSetMap.containsKey(psa.AssigneeId)){
                userToPSSetMap.put(psa.AssigneeId, new Set<Id>());
            }
            userToPSSetMap.get(psa.AssigneeId).add(psa.PermissionSetId);
        }
        
        // List to store records to delete
        List<PermissionSetLicenseAssign> recordsToDelete = new List<PermissionSetLicenseAssign>();
        
        // Identify the records to delete
        for(PermissionSetLicenseAssign psla : lstPSLicenseAssign){
            Id assigneeId = psla.AssigneeId;
            Id licenseId = psla.PermissionSetLicenseId;
            // Check if user has any of the permission sets associated with the license
            Boolean hasValidPermissionSet = false;
            if(licenseToPSSetMap.containsKey(licenseId)){
                for(Id psId : licenseToPSSetMap.get(licenseId)){
                    if(userToPSSetMap.containsKey(assigneeId) && userToPSSetMap.get(assigneeId).contains(psId)){
                        hasValidPermissionSet = true;
                        break;
                    }
                }
            }
            if(!hasValidPermissionSet){
                recordsToDelete.add(psla);
            }
        }
        
        // Delete the identified records
        System.debug('Identified following records to delete: ' + recordsToDelete);
        Database.delete (recordsToDelete, false);
    }
    
    global void finish(Database.BatchableContext BC){}
}