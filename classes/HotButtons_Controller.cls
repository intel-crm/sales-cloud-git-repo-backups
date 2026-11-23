/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-19-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class HotButtons_Controller {

    /*public static List<ProgressData> getAllProgressRecords(String accountPlanID) {
        // Query all Progress_Record__c records
        //List<Core_Hot_Buttons__c> hotButtonRecords = [SELECT Id, Name, Core_Current_Value__c, Core_Target_Value__c FROM Core_Hot_Buttons__c Where Account_PlanId__c =:accountPlanID];
        
        // Create a list to hold the progress data for each record
        List<ProgressData> progressDataList = new List<ProgressData>();

        // Loop through records and prepare progress data
        //for (Core_Hot_Buttons__c record : hotButtonRecords) {
            //Integer targetValue = record.Core_Target_Value__c != null ? Integer.ValueOf(record.Core_Target_Value__c) : 0;
            //Integer currentValue = record.Core_Current_Value__c != null ? Integer.ValueOf(record.Core_Current_Value__c) : 0;
            
            // Calculate the progress for each record
            Decimal progressPercentage = 0;
            if (targetValue > 0) {
                progressPercentage = (Decimal)currentValue / targetValue * 100;
            }
            
            // Add progress data to the list
            progressDataList.add(new ProgressData(record.Id, record.Name, targetValue, currentValue, progressPercentage));
        }
        
        return progressDataList;
    }*/

    // Inner class to hold progress data for each record
    public class ProgressData {
        @AuraEnabled public String recordId;
        @AuraEnabled public String recordName;
        @AuraEnabled public Integer targetValue;
        @AuraEnabled public Integer currentValue;
        @AuraEnabled public Decimal progressPercentage;

        public ProgressData(String recordId, String recordName, Integer targetValue, Integer currentValue, Decimal progressPercentage) {
            this.recordId = recordId;
            this.recordName = recordName;
            this.targetValue = targetValue;
            this.currentValue = currentValue;
            this.progressPercentage = progressPercentage;
        }
    }
}