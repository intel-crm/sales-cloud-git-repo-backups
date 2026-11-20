/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-09-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class PRM_SendInviteEmail_Batch implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts{

        List<IPA_Batch_Configurations__mdt> listBatchConfigItems = [
        SELECT 
        Id,
        DeveloperName,
        Record_Limit__c,
        PRM_SchedulingTimeMins__c,
        PRM_StandardEmailBulk__c
        FROM IPA_Batch_Configurations__mdt 
    WHERE DeveloperName =: 'PRM_BulkBatchConfigurableItems'
    LIMIT 1];
    global static final String LOG_ENTRY_ORIGIN   = 'PRM_BulkDataUpload_Batch';
    global static final String LOG_ENTRY_PROJECT  = 'Bulk Data Upload';
    global static final String LOG_ENTRY_SCOPE    = 'PRM_BulkDataUpload_Batch';
    global static final String LOG_ENTRY_SEVERITY = 'error';
    public Contact contId;
    public String strTags;
    public String evToken;
    Set<Id> contactId = new Set<Id>();   
    List<PRM_Batch_Entitlement__c> beRecordsToUpdate = new List<PRM_Batch_Entitlement__c>();
  
    global Database.QueryLocator start(Database.BatchableContext BC){
    String query = 'Select id,PRM_Contact_Id__c,PRM_EV_Token__c,PRM_IdentityAttribute__c,PRM_Status_Nm__c,Source__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c,PRM_Contact_Id__r.Core_Enterprise_Id__c,PRM_Contact_Id__r.Email,CreatedDate from PRM_Batch_Entitlement__c where PRM_Status_Nm__c=\'New\' AND (Source__c=\'Admin Invite Email\' OR Source__c=\'Bulk Invite Email\') LIMIT 10';
    return  Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<PRM_Batch_Entitlement__c> scope) {// Cyclomatic Complexity of 22 = > less than 10
        //List<String> nonIPApartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
    
    Map<Id,Contact> contactMap = new Map<Id,Contact>();
        String logEntryMsgString='';
        logEntryMsgString+='\nPRM_SendInviteEmail_Batch execute method invoked at:'+System.Now().format('MM/dd/YYYY HH:MM:SS','PST')+' PST dt@@@';
        logEntryMsgString+='\n\nScope for execute method:'+scope;
  
    for(PRM_Batch_Entitlement__c be :scope){
      contactId.add(be.PRM_Contact_Id__c);
    }
    if(contactId != null && !contactId.IsEmpty()){
      for(Contact con :[Select id,Core_IPA_PartnerRole__c,Core_Enterprise_Id__c,Email,Core_Preferred_Language__c,MailingCountryCode,AccountId,Account.Name,Account.AccountNumber,FirstName,LastName,Core_Do_Not_Contact__c,Account.BillingCountryCode,Core_ERPM_Integration_Status__c,CreatedDate from Contact where id IN :contactId]){
        contactMap.put(con.Id, con);
      }
    }
    beRecordsToUpdate.addAll(sendInviteEmail(scope, contactMap));   
	try{
	    if(beRecordsToUpdate != null && !beRecordsToUpdate.isEmpty()) {
	      update beRecordsToUpdate;
	    } 
        }catch(Exception exp){
            logEntryMsgString+='\n\nException occurred:'+exp.getMessage() + '-' + exp.getStackTraceString();
           PRM_IPA_Utility.createLogEntry(logEntryMsgString, LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT ,LOG_ENTRY_SCOPE , LOG_ENTRY_SEVERITY , strTags); 
        }
	}
    global void finish(Database.BatchableContext BC) {
       if(contactId!=null && contactId.size()>0 && System.Label.PRM_Tracker_Enabled=='true'){
            Set<String> contactIds = (Set<String>)JSON.deserialize(JSON.serialize(this.contactId), Set<String>.class);
            system.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps (null,contactIds,null,'PRM_SendInviteEmail_Batch','Admin'));
        }
  }
  public static List<PRM_Batch_Entitlement__c> sendInviteEmail(List<PRM_Batch_Entitlement__c> scope, Map<Id,Contact> contactMap){
    List<PRM_Batch_Entitlement__c> beRecordsToUpdate = new List<PRM_Batch_Entitlement__c>();
    for(PRM_Batch_Entitlement__c be :scope){
      //String contPartnerRoles = be.PRM_Contact_Id__r.Core_IPA_PartnerRole__c;
      DateTime dt = be.CreatedDate;
      String evToken = be.PRM_EV_Token__c == '' ? null:be.PRM_EV_Token__c;      
      if(system.now() >= dt.addMinutes(5) || Test.isRunningTest()){
          if(be.Source__c=='Admin Invite Email'){
            PRM_Contact_AGS_CallbackHandler.sendEmailToContact(contactMap.get(be.PRM_Contact_Id__c), evToken, be.PRM_IdentityAttribute__c);
          }
          else if(be.Source__c=='Bulk Invite Email'){
            PRM_BulkDataUpload_Batch.emailToContact(contactMap.get(be.PRM_Contact_Id__c), evToken, null);
          }
          be.PRM_Status_Nm__c = 'Success';
          be.PRM_Status_Reason_Txt__c ='PRM_SendInviteEmail_Batch : Entitlement insertion/removal succeeded';//TWC729-8089 : Adding reason text : NJ
          if(!beRecordsToUpdate.contains(be)) {
            beRecordsToUpdate.add(be);
          }
      }
    }   
    return beRecordsToUpdate;
  }
}