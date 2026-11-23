/**************************************************************************************
Apex Class Name:  Core_ContactHandler
Version     : 1.0 
Created Date: 02 NOV 2015
Function    : Methods to handle Contact Trigger functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Venu Karumuru				11/02/2015              Added Method UpdateJobFunction() that updates Job Function based on the value in Job Function Code
* Venu Karumuru				11/02/2015				Added Method UpdateJobFunctionCode() that updates Job Function Code based on the value in Job Function
*************************************************************************************/

public class Core_ContactHandler {
	public static boolean runOnce = false;
    /*
     * Method name  : UpdateJobFunction
     * Description  : Method to update Job Function based on the value in Job Function Code
     * Return Type  : void
     * Parameter    : map<Id, Contact>, map<Id, Contact>
     */

	 public static void UpdateJobFunction(map<Id, Contact> mapOld, map<Id, Contact> mapNew) {
         if(!runOnce) {
             Set<Id> setContactIds = new Set<Id>(); // Contacts whose Job Function Code got updated
             
             // Get the list of Contact Ids to be updated
             for (Contact contact :mapNew.values()) {
                 if (mapOld == null || mapOld.get(contact.Id) == null) { 
                     if (contact.Core_Job_Function_Code__c != null) // New Contacts that have Job Function Code
                         setContactIds.add(contact.Id);
                 }
                 
                 if (mapOld != null && mapOld.get(contact.Id).Core_Job_Function_Code__c != contact.Core_Job_Function_Code__c) // Updated Contacts whose Job Function Code got updated
                     setContactIds.add(contact.Id);
             }
             
             
             System.debug('### UpdateJobFunction() 01 ### Job Function Contact Count: ' + setContactIds.size());
             
             // Stop and Return if there are no Contacts to process
             if (setContactIds.size() == 0)
                 return;
             
             
             // Get the mappings between Job Function names and codes from the custom settings list
             Map<String, Core_Job_Function_Reference__c> mapJobFunctionReference = Core_Job_Function_Reference__c.getAll();
             
             // Store the mappings between Job Function Code and Job Function Name
             Map<String, String> mapJobCodeJobName = new Map<String, String>();
             
             for (Core_Job_Function_Reference__c jobFunctionReference :mapJobFunctionReference.values()) {
                 if (jobFunctionReference.Core_Active__c == true) // Use only Active mappings
                     mapJobCodeJobName.put(jobFunctionReference.Core_Job_Function_Code__c, jobFunctionReference.Core_Job_Function_Name__c);
             }
             
             System.debug('### UpdateJobFunction() 02 ### Job Function Code - Job Function Name: ' + mapJobCodeJobName);
             
             
             // Get the list of contacts to be updated
             List<Contact> lstContacts = [SELECT Id, Core_Job_Function__c, Core_Job_Function_Code__c FROM Contact WHERE Id IN :setContactIds];
             
             // Set the Job Function
             for (Contact contact: lstContacts) {
                 contact.Core_Job_Function__c = mapJobCodeJobName.get(contact.Core_Job_Function_Code__c);
             }
             
             runOnce = true;
             
             // Update the Contacts
             update lstContacts;
         }
     }


	/*
     * Method name  : UpdateJobFunctionCode
     * Description  : Method to update Job Function Code based on the value in Job Function
     * Return Type  : void
     * Parameter    : map<Id, Contact>, map<Id, Contact>
     */

	 public static void UpdateJobFunctionCode(map<Id, Contact> mapOld, map<Id, Contact> mapNew) {
         if(!runOnce) {
             Set<Id> setContactIds = new Set<Id>(); // Contacts whose Job Function got updated
             
             // Get the list of Contact Ids to be updated
             for (Contact contact :mapNew.values()) {
                 if (mapOld == null || mapOld.get(contact.Id) == null) { 
                     if (contact.Core_Job_Function__c != null) // New Contacts that have Job Function
                         setContactIds.add(contact.Id);
                 }
                 
                 if (mapOld != null && mapOld.get(contact.Id).Core_Job_Function__c != contact.Core_Job_Function__c) // Updated Contacts whose Job Function got updated
                     setContactIds.add(contact.Id);
             }
             
             
             System.debug('### UpdateJobFunctionCode() 01 ### Job Function Contact Count: ' + setContactIds.size());
             
             // Stop and Return if there are no Contacts to process
             if (setContactIds.size() == 0)
                 return;
             
             // Get the mappings between Job Function names and codes from the custom settings list
             Map<String, Core_Job_Function_Reference__c> mapJobFunctionReference = Core_Job_Function_Reference__c.getAll();
             
             // Store the mappings between Job Function Name and Job Function Code
             Map<String, String> mapJobNameJobCode = new Map<String, String>();
             
             for (Core_Job_Function_Reference__c jobFunctionReference :mapJobFunctionReference.values()) {
                 if (jobFunctionReference.Core_Active__c == true) // Use only Active mappings
                     mapJobNameJobCode.put(jobFunctionReference.Core_Job_Function_Name__c, jobFunctionReference.Core_Job_Function_Code__c);
             }
             System.debug('### UpdateJobFunctionCode() 02 ### Job Function Name - Job Function Code: ' + mapJobNameJobCode);
             
             
             // Get the list of contacts to be updated
             List<Contact> lstContacts = [SELECT Id, Core_Job_Function__c, Core_Job_Function_Code__c FROM Contact WHERE Id IN :setContactIds];
             
             // Set the Job Function
             for (Contact contact: lstContacts) {
                 contact.Core_Job_Function_Code__c = mapJobNameJobCode.get(contact.Core_Job_Function__c);
             }
             runOnce = true;
             
             // Update the Contacts
             update lstContacts;
         }
     }
}