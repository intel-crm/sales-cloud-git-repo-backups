/*********************************************************************************************************************
Class Name    : Sales_CreateLicenseContactUserBatch
Version       : 1.0
Created Date  : September 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain           6-Sept-2021             Batch class to create Sales_License_ContactUser__c records for associating PSG users to related contacts
* *********************************************************************************************************************/

public class Sales_CreateLicenseContactUserBatch implements Database.Batchable<sObject> {
    private static final string ORIGIN = 'Sales_CreateLicenseContactUserBatch';
    private static final string SEVERITY = 'Critical';
    private static final string PROJECT = 'PSG_Sales';
    
    //Get all the new PermissionSetAssignment records created for PSG permission set assignments to users
    public Database.QueryLocator start(Database.BatchableContext bc) {
    	String query = 'SELECT Id, AssigneeId, Assignee.Email, Assignee.ContactId FROM PermissionSetAssignment where PermissionSetId IN '+System.label.Sales_PSGInternalPermissionSetIds + ' and SystemModstamp = LAST_N_DAYS:'+System.label.Sales_NoOfDaysForPermissionSetAssignment;
        return Database.getQueryLocator(query);    
    }
	
    public void execute(Database.BatchableContext bc, List<PermissionSetAssignment> permissionSetAssignmentList) {        
        try{
            //Create Sales_License_ContactUser__c records
        	Sales_CreateLicenseContactUser_Utility.createLicenseContactUsers(permissionSetAssignmentList);	    
        }catch(Exception ex){
            //Create a Core_Log_Entry__c record in case of any exception
            Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT,null,SEVERITY,'An exception occurred',ex.getMessage(), '', '', '', ex);
        }
        
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
}