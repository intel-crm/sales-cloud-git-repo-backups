/*********************************************************************************************************************
Apex Class Name  :PRM_Purge_Registration_Requests
Version       : 1.0
Created Date  : Nov 2021
Function      : Deleting the Registration Records and Mapping the data to Archive Table
*********************************************************************************************************************/
public class PRM_Purge_Registration_Requests {
    @InvocableMethod
  public static void purgeRecords(List<PRM_Registration_Request__c> regReqList){
      Set<Id> regRecordIDsSet = new Set<Id>();
      for(PRM_Registration_Request__c regReq: regReqList){
          regRecordIDsSet.add(regReq.Id);
      }
      //system.debug('--> Inside the method');
      if(regRecordIDsSet != null) {
          try{
              List<PRM_Batch_Entitlement__c> createArchiveDataList = new List<PRM_Batch_Entitlement__c>();
              Id ArchiveRecordtypeId = Schema.SObjectType.PRM_Batch_Entitlement__c.getRecordTypeInfosByName().get(Label.PRM_ArchiveRecordType).getRecordTypeId();
              for(PRM_Registration_Request__c delRegRecs:[SELECT Id,PRM_Status__c,PRM_Salesforce_ID__c,PRM_Email_Verification_Criteria__c,PRM_Contact_Salesforce_Id__c,PRM_Salesforce_ID__r.Name,PRM_Email_ID__c,CreatedDate,CreatedById
                                                          FROM PRM_Registration_Request__c WHERE Id IN: regRecordIDsSet]){
                  if(delRegRecs.PRM_Status__c =='New' && delRegRecs.PRM_Email_Verification_Criteria__c =='PENDING' && ArchiveRecordtypeId != null){
                      PRM_Batch_Entitlement__c archiveRecord = new PRM_Batch_Entitlement__c();
                     // system.debug('--> Record Type Id:'+ArchiveRecordtypeId);
                      archiveRecord.recordtypeId = ArchiveRecordtypeId;
                      
                      archiveRecord.PRM_Account_Id__c = delRegRecs.PRM_Salesforce_ID__c;
                      archiveRecord.PRM_Contact_Id__c	= delRegRecs.PRM_Contact_Salesforce_Id__c;
                      archiveRecord.Account_Name__c = delRegRecs.PRM_Salesforce_ID__r.Name;
                      archiveRecord.Contact_Email__c = delRegRecs.PRM_Email_ID__c;
                      archiveRecord.Date_of_creation_invitation__c = delRegRecs.CreatedDate;
                      archiveRecord.Request_Created_By__c = delRegRecs.CreatedById;
                      archiveRecord.Date_of_purging__c = system.today();
                      archiveRecord.Source__c = 'Self Registration';                                   
                      createArchiveDataList.add(archiveRecord);      
                  }
              }
              // system.debug('--> List Value'+createArchiveDataList);
              if(!createArchiveDataList.isEmpty()){
                  delete regReqList;
                  insert createArchiveDataList;
              } 
          }//end of try
          Catch(Exception e){
              //system.debug('--Exception--->'+e);
          }
      }
  }

}