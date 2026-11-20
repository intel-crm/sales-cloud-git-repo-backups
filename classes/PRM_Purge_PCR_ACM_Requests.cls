/*********************************************************************************************************************
Apex Class Name  :PRM_Purge_PCR_ACM_Requests
Version       : 1.0
Created Date  : Nov 2021
Functionality      : Deleting the PCR,ACM and Mapping the data to Archive Table
Test Class: PRM_Purge_Registration_Requests_Test - validateACRandACMRecords() -Method
*********************************************************************************************************************/
public with sharing class PRM_Purge_PCR_ACM_Requests {
    public static Final String ORIGIN  = 'PRM_Purge_PCR_ACM_Requests';
    public static Final String SEVERITY  = 'Critical';
    public static Final String PROJECT  = 'IPA';
    public static void purgeRecords(List<PRM_Account_Contact_Relationship__c> acrRecsList){
        Set<Id> acrRecordIDsSet = new Set<Id>();
        try{
            for(PRM_Account_Contact_Relationship__c acrRecs: acrRecsList){
                acrRecordIDsSet.add(acrRecs.Id);
            }
            Set<Id> accountIdsSet = new Set<Id>();
            List<SObject> deleteACRandACMRecords = new List<SObject>();
            List<PRM_Batch_Entitlement__c> createArchiveDataList = new List<PRM_Batch_Entitlement__c>();
            Id ArchiveRecordtypeId = Schema.SObjectType.PRM_Batch_Entitlement__c.getRecordTypeInfosByName().get(Label.PRM_ArchiveRecordType).getRecordTypeId();
            //Id RegRecordTypeId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByName().get('Email Verification Request').getRecordTypeId();
            Map<Id, Contact> contactValMap = new Map<Id, Contact>();
            if(acrRecordIDsSet != null) {
                //Iterating PCR Records for deletion
                for(PRM_Account_Contact_Relationship__c delRecs: [SELECT Id,
                    PRM_Account_Id__c,
                    PRM_Contact_Id__c,
                    CreatedById,
                    CreatedDate,
                    LastModifiedDate,                                            
                    PRM_Account_Id__r.Name,
                    PRM_Contact_Id__r.Email,
                    PRM_Status_Nm__c 
                    FROM PRM_Account_Contact_Relationship__c 
                    WHERE Id IN: acrRecordIDsSet
                ]){
                    if(delRecs.PRM_Status_Nm__c =='Pending Action' && ArchiveRecordtypeId != null){
                        PRM_Batch_Entitlement__c archiveRecord = new PRM_Batch_Entitlement__c();
                        accountIdsSet.add(delRecs.PRM_Account_Id__c);
                        archiveRecord.recordtypeId = ArchiveRecordtypeId;
                        
                        archiveRecord.PRM_Account_Id__c = delRecs.PRM_Account_Id__c;
                        archiveRecord.PRM_Contact_Id__c  = delRecs.PRM_Contact_Id__c;
                        archiveRecord.Account_Name__c = delRecs.PRM_Account_Id__r.Name;
                        archiveRecord.Contact_Email__c = delRecs.PRM_Contact_Id__r.Email;
                        archiveRecord.Date_of_creation_invitation__c = delRecs.LastModifiedDate;
                        archiveRecord.Request_Created_By__c = delRecs.CreatedById;
                        archiveRecord.Date_of_purging__c = system.today();
                        archiveRecord.Source__c = 'Partner Invite';  
                        contactValMap.put(delRecs.PRM_Account_Id__c, delRecs.PRM_Contact_Id__r);
                        createArchiveDataList.add(archiveRecord);
                        deleteACRandACMRecords.add(delRecs);
                    }
                }
                //Getting ACM Records for deletion based on PCR Records
                Integer purgeDays = Integer.valueOf(System.Label.PRM_PurgeDays);
                DateTime acmRecCreateddate = Datetime.now().addDays(-purgeDays);
                for(PRM_AccountChannelMembership__c acmRecstoDel: [SELECT Id, 
                    PRM_Account_Id__c,
                    PRM_Status_Nm__c,
                    PRM_Account_Id__r.Name,
                    CreatedDate,
                    LastModifiedDate,                                           
                    CreatedById
                    FROM PRM_AccountChannelMembership__c 
                    WHERE PRM_Account_Id__c IN:accountIdsSet AND PRM_Status_Nm__c ='Pending'
                    AND LastModifiedDate <= :acmRecCreateddate
                ]){
                    PRM_Batch_Entitlement__c acmArchiveRec = new PRM_Batch_Entitlement__c();
                    if(ArchiveRecordtypeId != null){
                        acmArchiveRec.recordtypeId = ArchiveRecordtypeId;
                    }
                    if(!contactValMap.keySet().isEmpty() && !contactValMap.values().isEmpty()){
                        acmArchiveRec.PRM_Contact_Id__c = contactValMap.get(acmRecstoDel.PRM_Account_Id__c).Id;
                        acmArchiveRec.Contact_Email__c = contactValMap.get(acmRecstoDel.PRM_Account_Id__c).Email;
                    }
                    acmArchiveRec.PRM_Account_Id__c = acmRecstoDel.PRM_Account_Id__c;
                    acmArchiveRec.Account_Name__c = acmRecstoDel.PRM_Account_Id__r.Name;
                    acmArchiveRec.Date_of_creation_invitation__c = acmRecstoDel.LastModifiedDate;
                    acmArchiveRec.Request_Created_By__c = acmRecstoDel.CreatedById;
                    acmArchiveRec.Date_of_purging__c = system.today();
                    acmArchiveRec.Source__c = 'Admin Invite'; 
                    createArchiveDataList.add(acmArchiveRec); deleteACRandACMRecords.add(acmRecstoDel);
                }
                //Deleting all required purge records and error logging for same
                if(!deleteACRandACMRecords.isEmpty()){List<Database.DeleteResult> deleteList = Database.delete(deleteACRandACMRecords, false); 
                    integer index = 0;
                    for (Database.DeleteResult sr : deleteList){                    
                        if (!sr.isSuccess()){Id sId;String sObjectType = '';String tags = '';for(Database.Error err : sr.getErrors()){sId =deleteACRandACMRecords[index].Id;if(sId != null){sObjectType =  sId.getSObjectType().getDescribe().getName();}Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, err.getMessage(), '', sId, sObjectType, tags);}}
                    }
                }
                //Inserting batch entitlement records for Archived Data Report
                if(!createArchiveDataList.isEmpty()){
                    List<Database.UpsertResult> sbObjectList = Database.upsert(createArchiveDataList, false); 
                    integer index = 0;
                    for (Database.UpsertResult sr : sbObjectList){                    
                        if (!sr.isSuccess()){Id sId; String sObjectType = '';String tags = '';for(Database.Error err : sr.getErrors()){sId =createArchiveDataList[index].Id;if(sId != null){sObjectType =  sId.getSObjectType().getDescribe().getName();}Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, err.getMessage(), '', sId, sObjectType, tags);}}
                    }
                }
            }
        }Catch(Exception ex){Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, ex.getMessage(), '', '', '', '');
        }
    }
}