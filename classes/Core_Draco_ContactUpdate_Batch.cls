/**************************************************************************************
Apex Class Name : Core_Draco_ContactUpdate_Batch
Version     : 1.0 
Created Date: 23rd Feb 2023
Description : Batch class for updating the contact (mainly republish) in small batch sizes. 
Test Class  : xxxxxxxxxxxxxxxxxxxxxx
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Akshay[Team Draco]     23 Feb 2023               Original Version
*************************************************************************************/
global class Core_Draco_ContactUpdate_Batch implements Database.Batchable<sObject>,Database.Stateful{
    // Declare the variable which will be used as Input Parameter for the batch
    public Set<Contact> contactSet;
    global Core_Draco_ContactUpdate_Batch(set<Contact> contactSet) {
        this.contactSet = contactSet;
    }
    
    //Start method of the batch. Pass the list of Contacts that need to be updated to the Execute Method of the batch
    global Iterable<sObject> start(Database.BatchableContext context){
        List<Contact> conList = new List<Contact>(contactSet);
        return conList;
    }
    
    //Execute method of the batch. Update Contacts in the chunks as specified in the batch size
    global void execute(Database.BatchableContext context, List<Contact> conList){
        Database.update(conList);
    }
    
    //Finish method of the batch. Placeholder for any further actions
    global void finish(Database.BatchableContext context){
    }
}