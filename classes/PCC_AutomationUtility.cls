/*************************************************************************************************************************************
Apex Class Name     : PCC_AutomationUtility
Version             : 
Created Date        : Sept 2023
Descrpition         : Utility class for PCC API automation test scripts

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Pratiksha                Sept - 2023        Created class to update status of DR and DRP during automation test script execution
************************************************************************************************************************************************/
@RestResource(urlMapping='/update-status')
global with sharing class PCC_AutomationUtility {
    @HttpPost
    global static String updateFields(String recordId, String updatedFieldValue, String objectName) {
        String result;
        if(objectName == 'Design Registration'){
            try {       
                Core_Design_Registration__c record = [SELECT Id, Core_Design_Registration_Status_Nm__c FROM Core_Design_Registration__c WHERE Id = :recordId WITH USER_MODE LIMIT 1];
                // Update the field
                record.Core_Design_Registration_Status_Nm__c = updatedFieldValue;   
                Database.update(record,false,AccessLevel.User_mode);
                //update record;
                result = 'Record updated successfully';
            } catch(Exception ex) {
                // Handle the exception and return an error message
                result = 'Error updating Design Registration record: ' + ex.getMessage();
            }
        } else {
            try {       
                Core_Design_Registration_Product__c recordDRP = [SELECT Id, Core_Design_Product_Status_Nm__c FROM Core_Design_Registration_Product__c WHERE Id = :recordId WITH USER_MODE LIMIT 1];            
                // Update the field
                recordDRP.Core_Design_Product_Status_Nm__c = updatedFieldValue; 
                Database.update(recordDRP,false,AccessLevel.User_mode);           
                //update recordDRP;            
                result = 'Record updated successfully';
            } catch(Exception ex) {
                // Handle the exception and return an error message
                result = 'Error updating Design Registration Product record: ' + ex.getMessage();
            }
        }
        return result;
    }
}