public without sharing class PRM_UpdateEntitlementBatch implements Database.Batchable<Sobject>, Database.stateful{
    public String logEntryMsg='';
    public static final String LOG_ENTRY_ORIGIN = 'Entitlment Update Batch';
    public static final String LOG_ENTRY_PROJECT = 'IPA';
    public static final String LOG_ENTRY_SCOPE = 'ACM Entitlement Batch';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public List<Sobject> sobjectToUpsert = new List<Sobject>();//before its was List<Sobject> SObjectLst = new List<core_contact_entitlement_c>(); but it was giving collection store error at line 28 & 30 so changed now its working fine
    public Set<Id> conQueueFullLst=new Set<Id>();
    public string jobStarted;
    PRM_ACMUpdateBatchUtility acm = new PRM_ACMUpdateBatchUtility();
    public  set<Id> accIdAssocSet=new set<Id>();
    public  set<Id> accIdRemoveSet=new set<Id>();
    public List<Account> accountsToUpdate = new List<Account>();
    public static Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('PRM_Tracker_steps__mdt');
    public PRM_UpdateEntitlementBatch(List<Sobject> sobjectList){  
        
        sobjectToUpsert.addAll(sobjectList); ////before sobjectToUpsert=sobjectList---> but it was not updating all entitlements so changed today_30_11_21, now working fine
    }
    
    public Iterable<Sobject> start(Database.BatchableContext bc){        
        return sobjectToUpsert;
    }
    
    public void execute(Database.BatchableContext bc, List<Sobject> sobjectList){                
        List<Core_Contact_Entitlement__c> contactEntitlementToUpsert = new List<Core_Contact_Entitlement__c>();
        List<Contact> contactsToUpdate = new List<COntact>();        
        try{
            for(Sobject sobjectRecord : sobjectList){
                if(sobjectRecord instanceof account){
                    accountsToUpdate.add((account) sobjectRecord);
                }else if(sobjectRecord instanceof contact){
                    contactsToUpdate.add((contact)sobjectRecord);
                }else if(sobjectRecord instanceof Core_Contact_Entitlement__c){
                    contactEntitlementToUpsert.add((Core_Contact_Entitlement__c)sobjectRecord);
                }
            }
            if(accountsToUpdate.size()>0){
                PRM_ACMUpdateUtility.upsertData(accountsToUpdate);
            }
            if(contactsToUpdate.size()>0){
                PRM_ACMUpdateUtility.upsertData(contactsToUpdate);
            }
            if(contactEntitlementToUpsert.size()>0){
                Set<string> conIdEntId = new set<string>();
                List<Core_Contact_Entitlement__c> newLstToUpsertCE = new List<Core_Contact_Entitlement__c>();
                for(Core_Contact_Entitlement__c cConEnt :contactEntitlementToUpsert){
                    if(!conIdEntId.contains(cConEnt.Core_Contact_Id__c+''+cConEnt.Core_Entitlement_Id__c)){
                        //Core_Contact_Entitlement__c newConEntl = new Core_Contact_Entitlement__c();
                        newLstToUpsertCE.add(cConEnt);
                        conQueueFullLst.add(cConEnt.Core_Contact_Id__c);
                        conIdEntId.add(cConEnt.Core_Contact_Id__c+''+cConEnt.Core_Entitlement_Id__c);
                    }
                }
                PRM_ACMUpdateUtility.upsertData(newLstToUpsertCE);    
                List<PRM_Tracker__c> trackerListAssoc = new List<PRM_Tracker__c>();
                List<PRM_Tracker__c> trackerListRemove = new List<PRM_Tracker__c>();
                List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
                PRM_Tracker__c tr=new PRM_Tracker__c();
                PRM_Tracker__c tr1=new PRM_Tracker__c();
                for (Core_Contact_Entitlement__c ceList: [select id,Core_Source__c,Core_Status__c, Core_Contact_Id__c,Core_Contact_Id__r.AccountId,Core_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c,Core_Contact_Id__r.Core_IPA_Partner_Community__c,Core_Entitlement_Id__c,Core_Entitlement_Id__r.name, Core_Selected__c from Core_Contact_Entitlement__c
                                                          where id in: newLstToUpsertCE and Core_Type__c='Entitlement']) {
                                                              
                                                              if(ceList.Core_Selected__c==true && ceList.Core_Status__c=='Pending'  && !accIdAssocSet.contains(ceList.Core_Contact_Id__r.AccountId)){
                                                                  
                            /*tr=PRM_IPA_Utility.createTrackerInstance('OPID Updates','ENT_UPD_ASSOC',null,ceList.Core_Contact_Id__r.AccountId,ceList.Core_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c,ceList.Core_Contact_Id__r.AccountId,'','',true,'','', PRM_Tracker_steps__mdt.getInstance('ENT_UPD_ASSOC').PRM_Milestone_Display_Name__c  );*/
                            tr=PRM_IPA_Utility.createTrackerInstance('OPID Updates','ENT_UPD_ASSOC',null,ceList.Core_Contact_Id__r.AccountId,ceList.Core_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c,ceList.Core_Contact_Id__r.AccountId,'','',true,'','', String.valueOf(customMetadata.getInstance('ENT_UPD_ASSOC').get('PRM_Milestone_Display_Name__c')));
                                                                  tr.prm_skip_tracker__c=true;
                                                                  tr.prm_entitlement_id__c  = tr.prm_entitlement_id__c+';'+ceList.Core_Entitlement_Id__c;
                                                                  trackerListAssoc.add(tr);
                                                                  accIdAssocSet.add(ceList.Core_Contact_Id__r.AccountId);
                                                              }
                                                              
                                                              else if(ceList.Core_Selected__c==false && ceList.Core_Status__c=='Pending' && !accIdRemoveSet.contains(ceList.Core_Contact_Id__r.AccountId)){
                                                                  
                             /*tr1=PRM_IPA_Utility.createTrackerInstance('OPID Updates','ENT_UPD_REM',null,ceList.Core_Contact_Id__r.AccountId,ceList.Core_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c,ceList.Core_Contact_Id__r.AccountId,'','',true,'','', PRM_Tracker_steps__mdt.getInstance('ENT_UPD_REM').PRM_Milestone_Display_Name__c  );*/
                             tr1=PRM_IPA_Utility.createTrackerInstance('OPID Updates','ENT_UPD_REM',null,ceList.Core_Contact_Id__r.AccountId,ceList.Core_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c,ceList.Core_Contact_Id__r.AccountId,'','',true,'','', String.valueOf(customMetadata.getInstance('ENT_UPD_REM').get('PRM_Milestone_Display_Name__c')));
                                                                  tr1.prm_entitlement_id__c	= tr1.prm_entitlement_id__c+';'+ceList.Core_Entitlement_Id__c;
                                                                  tr1.prm_skip_tracker__c=true;
                                                                  accIdRemoveSet.add(ceList.Core_Contact_Id__r.AccountId);
                                                                  trackerListRemove.add(tr1);
                                                                  
                                                              }
                                                          }
                if(!trackerListAssoc.isEmpty() || !trackerListRemove.isEmpty()){
                    trackerList.addall(trackerListAssoc);
                    trackerList.addall(trackerListRemove);
                    //if(!trackerList.isEmpty()){  ATHR fix, condition can be removed since we are adding data into list, so it will not be empty
                        Database.saveResult[] insertTracker = Database.insert(trackerList, false);
                        for (Database.saveResult sr : insertTracker ) {
                            if(!sr.isSuccess()){
                                Core_Log_Entry.logEntryWithDetails('PRM_updateEntitlementBatch', 'IPA', 'Tracker record', 'exception', 'Exception occured while inserting PRM_Tracker__c', sr.getErrors()[0].getMessage(), sr.getId(), 'PRM_Tracker__c', 'PRM_Tracker__c');
                            }
                        }
                    //}
                }
                
            }
               logEntryMsg+='\n@@@ accountsToUpdate -->\n'+accountsToUpdate+'contactsToUpdate -->\n'+contactsToUpdate+'contactEntitlementToUpsert -->\n'+contactEntitlementToUpsert;

        }catch(Exception ex){
            logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processException(ex);//Added error log statement
        }                
    }     
       
    public void finish(Database.BatchableContext bc){
        AsyncApexJob a = [select Id, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems, CreatedBy.Email from AsyncApexJob 
        where Id =: bc.getJobId()];
        if(a.status=='Completed'){
            acm.sendMail('BATCH_JOB_NOTIFICATION', 'Benefit and Entitlement batch execution finished as part of Role/Tier Automation. Batch Job started at '+jobStarted,'Batch Execution finished');
           
            logEntryMsg+='\n@@@ Entitlement assignment batch job finished mail will trigger with template:BATCH_JOB_NOTIFICATION and status:'+a.status;
        }
        else{
            acm.sendMail('BATCH_JOB_NOTIFICATION', 'Entitlements Batch execution failed as part of Role Tier Automation. Please contact support team for updating benefits manually. Batch Job started at '+jobStarted,'Batch Execution Failed');
            logEntryMsg+='\n@@@ Entitlement assignment batch job Failed mail will trigger with template:BATCH_JOB_NOTIFICATION and status:'+a.status;
        }
         logEntryMsg+='\n@@@Second Batch Ends\n';
        
    
     PRM_RepublishContactsForRoleTier.UpdateRepublishOnContact(new List<Id>(conQueueFullLst));
    }
}