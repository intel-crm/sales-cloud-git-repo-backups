/****************************************************************************************************************************************
* Class Name  : PSS_SolutionToOfferingConversionBatch 
* Version     : 1.0 
* Created Date: 06-21-2021
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sooriya                         June-21-2021                  batch class to trigger the solution to offering conversion
* ****************************************************************************************************************************************/
/* PSS_SolutionToOfferingConversionBatch ab = New PSS_SolutionToOfferingConversionBatch();
   Database.executeBatch(ab,1); //script to run this batch (batch size should be 1)
*/
/*IPA2.0: US-TWC729-7976*/
@isTest
global without sharing class PSS_SolutionToOfferingConversionBatch{} /*implements Database.Batchable<sObject> {
global Database.QueryLocator start(Database.BatchableContext bc) {
        // added dummy syntax to override error
       return null;
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        // added dummy syntax to override error
    }

    global void finish(Database.BatchableContext bc) {
        // added dummy syntax to override error
    }
}*/
/*
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        //Query to fetch the solution records with respect to the where condition
        String query= 'SELECT Id,PSS_Partner_Solution_Lifecycle_Status_Nm__c,ArdiraSurvey__Survey__c FROM ArdiraSurvey__Survey_Result__c WHERE ';  
        query += PMP_Utility.getValue('Batch_Class_Solution_to_Offering');
      
        return Database.getQueryLocator(query);
    }
    
    //Execute Method
    global void execute(Database.BatchableContext bc, List<ArdiraSurvey__Survey_Result__c> solutions) {
        for(ArdiraSurvey__Survey_Result__c solution : solutions){
                
            //Method to trigger the solution to offering conversion process
            //In below method OPID and Company validation will happen - The offering will be created only when this validation is cleared
            PSS_SolutionToOfferingRetrigger.convertSolutionToOffering(solution.Id);  
        }    

    }
    
    //Finish Method
    global void finish(Database.BatchableContext bc) {

    }
}
*/