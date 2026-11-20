/***************************************************************************************************
* @Name Core_IPS_Status_Ownership_Ctrl_Util
* @Test Class Name : Core_IPS_Status_Ownership_Ctrl_Util_Test
* @ Description : This class is being used for creating the Status & Ownership Duration records(STOWD).
* @User Story - TWC777-2882
* @Created Date 25/11/2024 
* @Author: Accellor
***************************************************************************************************/

public without sharing class Core_IPS_Status_Ownership_Ctrl_Util {
    
    /*Start - TWC777-2514 - 08/08/2024 - Vishal - STOWD - Custom Implementation - Method invoked to create the Status & Ownership Records on Case update*/
    public static Boolean hasHandlerExecuted = false;
    public static void handleBeforeUpdate(List<Case> newCases, Map<Id, Case> oldCaseMap){
        
        if(Core_Trigger_Executions__c.getValues('isCustomSTOWDEnabled') != null && !Core_Trigger_Executions__c.getValues('isCustomSTOWDEnabled').Core_Active__c){
            return;
        }
        
        Map<String,STOWD_Tracking_Field__mdt> obj = STOWD_Tracking_Field__mdt.getAll();
        List<Id> caseObjIds = new List<Id>();
        for (Case newCase : newCases) {
            Case oldCase = oldCaseMap.get(newCase.Id);
            if (((obj.get('Case_Create_Status').IsActive__c) && newCase.Status != oldCase.Status && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId() && obj.containsKey('Case_Create_Status') && obj.get('Case_Create_Status').FieldType__c == 'Status' && obj.get('Case_Create_Status').RecordType__c == 'IPS Case Create') ||
                ((obj.get('Case_Create_Owner').IsActive__c) && newCase.OwnerId != oldCase.OwnerId && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId() && obj.containsKey('Case_Create_Owner') && obj.get('Case_Create_Owner').FieldType__c == 'OwnerId'  && obj.get('Case_Create_Owner').RecordType__c == 'IPS Case Create') ||
                ((obj.get('Case_Create_Escalated_Level').IsActive__c) && newCase.Core_IPS_Escalated_Level__c != oldCase.Core_IPS_Escalated_Level__c && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId() && obj.containsKey('Case_Create_Escalated_Level') && obj.get('Case_Create_Escalated_Level').FieldType__c == 'Core_IPS_Escalated_Level__c' && obj.get('Case_Create_Escalated_Level').RecordType__c == 'IPS Case Create') ||
                ((obj.get('Case_Create_Sub_Status').IsActive__c) && newCase.Core_Sub_Status__c != oldCase.Core_Sub_Status__c && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId() && obj.containsKey('Case_Create_Sub_Status') && obj.get('Case_Create_Sub_Status').FieldType__c == 'Core_Sub_Status__c'  && obj.get('Case_Create_Sub_Status').RecordType__c == 'IPS Case Create') || 
                ((obj.get('Case_Create_Queue').IsActive__c) && newCase.Core_IPS_Assigned_Queue__c != oldCase.Core_IPS_Assigned_Queue__c && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId() && obj.containsKey('Case_Create_Queue') && obj.get('Case_Create_Queue').FieldType__c == 'Core_IPS_Assigned_Queue__c' && obj.get('Case_Create_Queue').RecordType__c == 'IPS Case Create')) {
                    caseObjIds.add(newCase.Id);  
                }else if (((obj.get('Closed_Case_Status').IsActive__c) && newCase.Status != oldCase.Status && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Closed Case').getRecordTypeId() && obj.containsKey('Closed_Case_Status') && obj.get('Closed_Case_Status').FieldType__c == 'Status' && obj.get('Closed_Case_Status').RecordType__c == 'IPS Closed Case') ||
                          ((obj.get('Closed_Case_Owner').IsActive__c) && newCase.OwnerId != oldCase.OwnerId && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Closed Case').getRecordTypeId() && obj.containsKey('Closed_Case_Owner') && obj.get('Closed_Case_Owner').FieldType__c == 'OwnerId'  && obj.get('Closed_Case_Owner').RecordType__c == 'IPS Closed Case') ||
                          ((obj.get('Closed_Case_Escalated_Level').IsActive__c) && newCase.Core_IPS_Escalated_Level__c != oldCase.Core_IPS_Escalated_Level__c && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Closed Case').getRecordTypeId() && obj.containsKey('Closed_Case_Escalated_Level') && obj.get('Closed_Case_Escalated_Level').FieldType__c == 'Core_IPS_Escalated_Level__c'  && obj.get('Closed_Case_Escalated_Level').RecordType__c == 'IPS Closed Case') ||
                          ((obj.get('Closed_Case_Sub_Status').IsActive__c) && newCase.Core_Sub_Status__c != oldCase.Core_Sub_Status__c && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Closed Case').getRecordTypeId() && obj.containsKey('Closed_Case_Sub_Status') && obj.get('Closed_Case_Sub_Status').FieldType__c == 'Core_Sub_Status__c'  && obj.get('Closed_Case_Sub_Status').RecordType__c == 'IPS Closed Case') || 
                          ((obj.get('Closed_Case_Queue').IsActive__c) && newCase.Core_IPS_Assigned_Queue__c != oldCase.Core_IPS_Assigned_Queue__c && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Closed Case').getRecordTypeId() && obj.containsKey('Closed_Case_Queue') && obj.get('Closed_Case_Queue').FieldType__c == 'Core_IPS_Assigned_Queue__c' && obj.get('Closed_Case_Queue').RecordType__c == 'IPS Closed Case')) {
                              caseObjIds.add(newCase.Id);  
                          }else if (((obj.get('GEC_Case_Status').IsActive__c) && newCase.Status != oldCase.Status && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId() && obj.containsKey('GEC_Case_Status') && obj.get('GEC_Case_Status').FieldType__c == 'Status' && obj.get('GEC_Case_Status').RecordType__c == 'IPS GEC ReadOnly') ||
                                    ((obj.get('GEC_Case_Owner').IsActive__c) && newCase.OwnerId != oldCase.OwnerId && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId() && obj.containsKey('GEC_Case_Owner') && obj.get('GEC_Case_Owner').FieldType__c == 'OwnerId'  && obj.get('GEC_Case_Owner').RecordType__c == 'IPS GEC ReadOnly') ||
                                    ((obj.get('GEC_Case_Escalated_Level').IsActive__c) && newCase.Core_IPS_Escalated_Level__c != oldCase.Core_IPS_Escalated_Level__c && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId() && obj.containsKey('GEC_Case_Escalated_Level') && obj.get('GEC_Case_Escalated_Level').FieldType__c == 'Core_IPS_Escalated_Level__c'  && obj.get('GEC_Case_Escalated_Level').RecordType__c == 'IPS GEC ReadOnly') ||
                                    ((obj.get('GEC_Case_Sub_Status').IsActive__c) && newCase.Core_Sub_Status__c != oldCase.Core_Sub_Status__c && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId() && obj.containsKey('GEC_Case_Sub_Status') && obj.get('GEC_Case_Sub_Status').FieldType__c == 'Core_Sub_Status__c'  && obj.get('GEC_Case_Sub_Status').RecordType__c == 'IPS GEC ReadOnly') || 
                                    ((obj.get('GEC_Case_Queue').IsActive__c) && newCase.Core_IPS_Assigned_Queue__c != oldCase.Core_IPS_Assigned_Queue__c && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId() && obj.containsKey('GEC_Case_Queue') && obj.get('GEC_Case_Queue').FieldType__c == 'Core_IPS_Assigned_Queue__c' && obj.get('GEC_Case_Queue').RecordType__c == 'IPS GEC ReadOnly')) {
                                        caseObjIds.add(newCase.Id);  
                                    }else if (((obj.get('No_Contact_Case_Status').IsActive__c) && newCase.Status != oldCase.Status && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId() && obj.containsKey('No_Contact_Case_Status') && obj.get('No_Contact_Case_Status').FieldType__c == 'Status' && obj.get('No_Contact_Case_Status').RecordType__c == 'IPS No Assigned Contact Case') ||
                                              ((obj.get('No_Contact_Case_Owner').IsActive__c) && newCase.OwnerId != oldCase.OwnerId && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId() && obj.containsKey('No_Contact_Case_Owner') && obj.get('No_Contact_Case_Owner').FieldType__c == 'OwnerId'  && obj.get('No_Contact_Case_Owner').RecordType__c == 'IPS No Assigned Contact Case') ||
                                              ((obj.get('No_Contact_Case_Escalated_Level').IsActive__c) && newCase.Core_IPS_Escalated_Level__c != oldCase.Core_IPS_Escalated_Level__c && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId() && obj.containsKey('No_Contact_Case_Escalated_Level') && obj.get('No_Contact_Case_Escalated_Level').FieldType__c == 'Core_IPS_Escalated_Level__c'  && obj.get('No_Contact_Case_Escalated_Level').RecordType__c == 'IPS No Assigned Contact Case') ||
                                              ((obj.get('No_Contact_Case_Sub_Status').IsActive__c) && newCase.Core_Sub_Status__c != oldCase.Core_Sub_Status__c && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId() && obj.containsKey('No_Contact_Case_Sub_Status') && obj.get('No_Contact_Case_Sub_Status').FieldType__c == 'Core_Sub_Status__c'  && obj.get('No_Contact_Case_Sub_Status').RecordType__c == 'IPS No Assigned Contact Case') || 
                                              ((obj.get('No_Contact_Case_Queue').IsActive__c) && newCase.Core_IPS_Assigned_Queue__c != oldCase.Core_IPS_Assigned_Queue__c && newCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId() && obj.containsKey('No_Contact_Case_Queue') && obj.get('No_Contact_Case_Queue').FieldType__c == 'Core_IPS_Assigned_Queue__c' && obj.get('No_Contact_Case_Queue').RecordType__c == 'IPS No Assigned Contact Case')) {
                                                  caseObjIds.add(newCase.Id);  
                                              } 
        }
        if(!caseObjIds.isEmpty()){
            createStatusOwnershipRecord(caseObjIds);
        }
        
    }
    /*End - TWC777-2514 - 08/08/2024 - Vishal - STOWD - Custom Implementation - Method invoked to create the Status & Ownership Records on Case update*/
    
    /*Start - TWC777-2303 - 07/05/2024 - Vishal - Below method is added to create the Status & Ownership record on Case Update scenarios*/
    public static void  createStatusOwnershipRecord(List<Id> caseIds){
        try{
            /*Start - TWC777-3027 - 15/01/2025 - Vishal - Code added to fix the From date issue in Status & Ownership records. This will also fix the issue in Rollup summary fields data*/
            Map<String,STOWD_Tracking_Field__mdt> obj = STOWD_Tracking_Field__mdt.getAll();
            Set<String> caseHistSet = new Set<String>();
            for(String key: obj.keyset() ){
                caseHistSet.add(obj.get(key).FieldType__c);
            }
            caseHistSet.add('Owner'); // Owner field is explicitly added in the list because it is not present in the metadata and in the CaseHistory we need Owner field instead of OwnerID.
            /*End - TWC777-3027 - 15/01/2025 - Vishal - Code added to fix the From date issue in Status & Ownership records. This will also fix the issue in Rollup summary fields data*/
            
            
            DateTime nowDateTime = DateTime.now();
            List<Case> caseObjList = new List<Case>();
            //FLS Added as Part of code refactor
            if(Case.SObjectType.getDescribe().isAccessible() && !caseIds.isEmpty()){
                //Below query is added to assign Owner.Name value to newly created Status & Ownership record as we get only OwnerId in CaseList from Trigger
                /*Start - TWC777-3027 - 15/01/2025 - Vishal - Added where condition for the CaseHistories*/
                caseObjList = [SELECT id, caseNumber, Owner.Name, Status, Core_Sub_Status__c, Core_IPS_Assigned_Queue__c, Core_IPS_Escalated_Level__c, LastModifiedDate, (SELECT CreatedDate,Id FROM Histories WHERE Field IN: caseHistSet order by Createddate DESC limit 1) FROM Case WHERE Id IN : caseIds WITH SECURITY_ENFORCED];  /***/  
                /*End - TWC777-3027 - 15/01/2025 - Vishal - Added where condition for the CaseHistories*/
            }
            List<Status_Ownership_Duration__c> statusOwnershipList = new List<Status_Ownership_Duration__c>();
            if(!caseObjList.isEmpty()){
                for(Case caseobj : caseObjList){
                    Status_Ownership_Duration__c statusOwnershipObj = new Status_Ownership_Duration__c();
                    CaseHistory caseHistory = new CaseHistory();
                    if(!caseobj.Histories.isEmpty()){
                        caseHistory = caseobj.Histories;
                    }
                    //statusOwnershipObj.From__c = caseHistory.Createddate;
                    statusOwnershipObj.From__c = caseHistory.Createddate!=null ?  caseHistory.Createddate : caseobj.LastModifiedDate;
                    statusOwnershipObj.Until__c = nowDateTime;  
                    Long diffMilliseconds = statusOwnershipObj.Until__c.getTime() - statusOwnershipObj.From__c.getTime();
                    Long diffSeconds = diffMilliseconds / 1000;  
                    statusOwnershipObj.Calculated_Business_Seconds__c = diffSeconds;
                    statusOwnershipObj.Parent__c = caseobj.Id;
                    statusOwnershipObj.Owner__c = caseobj.Owner.Name;
                    statusOwnershipObj.Status__c = caseobj.Status;
                    statusOwnershipObj.Sub_Status__c = caseobj.Core_Sub_Status__c;
                    statusOwnershipObj.Last_Assigned_Queue__c = caseobj.Core_IPS_Assigned_Queue__c;
                    statusOwnershipObj.Escalated_Level__c = caseobj.Core_IPS_Escalated_Level__c;
                    statusOwnershipList.add(statusOwnershipObj);
                }
                if(Schema.sObjectType.Status_Ownership_Duration__c.isCreateable() && !statusOwnershipList.isEmpty() && hasHandlerExecuted == false){
                    insert statusOwnershipList;
                    hasHandlerExecuted = true;
                }
            }
        }catch(Exception e){
            Core_IPS_ExceptionHandling.logEntryWithException(e,'Core_IPS_Status_Ownership_Ctrl_Util','STOWD');
        }
    } 
    /*End - TWC777-2303 - 07/05/2024 - Vishal - Below method is added to create the Status & Ownership record on Case Update scenarios*/
    
    
}