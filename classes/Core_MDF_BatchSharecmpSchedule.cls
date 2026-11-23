/****************************************************************************************************************************************
* Class Name  : Core_MDF_BatchSharecmpSchedule 
* Version     : 1.0 
* Created Date: 08-08-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Raj D        8/8/2018                    Scheduler class for Core_MDF_BatchShareCampVisibility class
* Accenture  - Shridhar     09/05/2018                  Added Core_MDF_Channel_Program__c in SOQL querry.
* Accenture - Shridhar K        2/08/2019                   Co-marketing recordType check is modified to handle new recordType dynamically 
*****************************************************************************************************************************************/
public without sharing class Core_MDF_BatchSharecmpSchedule implements Schedulable{
    //Added without sharing as part of ATHR fix
    
    // Execute schedule class
    public void execute(SchedulableContext sc) {
        
        //Record Type Check in below SOQL query is added by Shridhar
                        
        String queryStr = 'SELECT Id, Name, Type, RecordTypeId, Status, StartDate, EndDate,Core_MDF_Partner_Mapping_Txt__c,'+
            'IsActive, OwnerId, Core_MDF_External_Visibility_Date__c,'+
            'Core_MDF_Program__c, Core_MDF_Account__c,Core_MDF_Channel_Program__c FROM Campaign WHERE Core_MDF_External_Visibility_Date__c >= LAST_N_DAYS:5';
        queryStr += ' AND Core_MDF_External_Visibility_Date__c <= TODAY AND RecordType.DeveloperName IN: recTypeDeveloperName';
        
        
       // Executing batch class for handling sharing of Campaigns
        Core_MDF_BatchShareCampVisibility cmpBatch = new Core_MDF_BatchShareCampVisibility(queryStr);
        Id batchId = Database.executeBatch(cmpBatch, 200);       
    }    
    
}