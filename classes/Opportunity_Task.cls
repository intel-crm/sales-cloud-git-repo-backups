public class Opportunity_Task {
    
    public static void taskCreation(){
        //Activity act = new Activity();
        //act.Core_Task_Type__c = 'Complete Current and Future State Analysis';
        
        Task tak = new Task();
        //tak.RecordTypeId = '012o0000000Gn1AAAS';
        tak.OwnerId = [select id from user where FirstName ='Narayani'].id;
        tak.Core_Task_Type__c = 'Complete Current and Future State Analysis';
        tak.WhatId='006Df00000K2E7kIAF';
        insert tak;
    }

}