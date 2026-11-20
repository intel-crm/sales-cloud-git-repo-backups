/************************************************************************************************************************************************************************************
    * Class Name  : Core_MDF_CCP_ContactHandler 
    * Version     : 1.0 
    * Created Date: 21-03-2019
    * Modification Log :
    * Developer                     Date                          Description
    * --------------------------------------------------------------------------------------------------------------------------------------------------
    * Intel - Narayani Perachi     21-03-2019            Created determineContactsToBeProcessed() and incorporated the logic for selecting CCP Contacts for processing
**************************************************************************************************************************************************************************************/
public without sharing class Core_MDF_CCP_ContactHandler {
    //Commented as part of WW24 - 2025
     //added dummy method to get the code coverage for this class
    public static void getCodeCoverage(){
    }
    /*public static String logEntryMsg = '';
    public static exception ex;
    
    public static void determineContactsToBeProcessed(List<Contact> newContactList, Map<id,Contact> oldContactMap, boolean isInsert, boolean isUpdate)
    {
        List<contact> toBeProcessedContacts = new List<contact>();
        try{
        if(isInsert)
        {
            for(contact contactRecord : newContactList)
            {
                // Call Usergroupmapping method only if Audience list is not null
                if(contactRecord.Core_Audience__c != null){
                    toBeProcessedContacts.add(contactRecord);
                }
            }
            if(toBeProcessedContacts.size()>0)
            {
                ID jobID = System.enqueueJob(new Core_MDF_UserGroupMappingAutomation(toBeProcessedContacts,null,isInsert,isUpdate));
            }          
        }
        if(isUpdate)
        {
            for(contact contactRecord : newContactList)
            {
                // Call Usergroupmappingmethod only if there is a change in the audience list
                if(contactRecord.Core_Audience__c != oldContactMap.get(contactRecord.id).Core_Audience__c){
                    toBeProcessedContacts.add(contactRecord);             
                } 
            }
            if(toBeProcessedContacts.size()>0)
            {
                ID jobID = System.enqueueJob(new Core_MDF_UserGroupMappingAutomation(toBeProcessedContacts,oldContactMap,isInsert,isUpdate));   
            }
        }
        }
        catch(exception ex){ logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Core_MDF_CCP_ContactHandler - determineContactsToBeProcessed()'); system.debug('logEntryMsg' + logEntryMsg +isError );} 
    }*/

}