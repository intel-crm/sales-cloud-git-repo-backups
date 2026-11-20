/**************************************************************************************************
Apex Class Name :  Core_IPS_ECB_Updates_Batch
Description     :  Batch class to Inactivate ProjectMembers after ECB check on Account and Contact
this will process the records of a batch size 20
Developer Name	:  Gangadhar
Date			:  26/07/2025
*****************************************************************************************************/
global class Core_IPS_ECB_Updates_Batch implements Database.Batchable<sObject>, Database.Stateful{
    private List<Core_IPS_Project_Member__c> projmemnew = new List<Core_IPS_Project_Member__c>();
    private List<Core_IPS_Project_Member__c> projMembersOld = new List<Core_IPS_Project_Member__c>();
    private Set<Id> accidsForUpdate = new Set<Id>();
    private List<String> errorProjMemRecs = new List<String>();
    private List<String> errorIntrestedPartyRecs = new List<String>();
    private List<String> errorContactRecs = new List<String>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<Id> accids = new Set<Id>();
        Core_IPS_SkipTriggerHandler.skipQueueable=true;
        for(Core_ACM_Account_Staging__c stgaccs: [select AccountId__c from Core_ACM_Account_Staging__c 
                                                  where Core_Action__c = 'IPSECBFlagCheck' 
                                                  and Core_Status__c = 'NEW' order by CreatedDate desc]){
            accids.add(stgaccs.AccountId__c);
            accidsForUpdate.add(stgaccs.AccountId__c);
        }
        if(accids.isEmpty()){ 
            return Database.getQueryLocator('SELECT Id FROM Contact WHERE Id = null and Core_IPS_Active__c = true ');
        }
        return Database.getQueryLocator('select Id from Contact where Core_IPS_Active__c = true and AccountId IN : accids');
    } 
    public void execute(Database.BatchableContext BC, List<Contact> conchunk){
        Set<Id> conids = new Set<Id>();
        Boolean isprojMemUpdateFailed = false;
        Boolean isConUpdateFailed = false;
        List<Core_Exceptions__c> ipsex =  new List<Core_Exceptions__c>();
        for(Contact conlst : conchunk){
            conids.add(conlst.Id);
        }
        List<Core_IPS_Case_Interested_Party__c> iplist = New List<Core_IPS_Case_Interested_Party__c>();
        for(Core_IPS_Case_Interested_Party__c ipl: [Select id,Active__c,Type__c,Contact__c,
                                                    Contact__r.Core_IPS_Active__c,Contact__r.id,
                                                    Contact__r.Core_IPS_Email_Opt_Out__c 
                                                    from Core_IPS_Case_Interested_Party__c 
                                                    where Case__r.Status !='Closed' 
                                                    and Contact__c IN : conids 
                                                    limit 49999]){
            ipl.Active__c = false;
            iplist.add(ipl);
        }
        if(!iplist.isEmpty()){ 
            Core_IPS_SkipTriggerHandler.skipQueueable=true;
            Database.update(iplist, false); //commented on 16092025 gangadhar
            List<Database.SaveResult> iplistList = Database.update(iplist, false);
			for (Database.SaveResult result : iplistList) {
                if (!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        errorIntrestedPartyRecs.add('Error occurred: ' + err.getStatusCode() + ' - ' + err.getMessage()+' - '+err.getFields());
                    }  
                }
            }
        }
        for(Core_IPS_Project_Member__c pmlst : [Select id,Core_User__c,Core_Status__c,Core_IPS_Project__c,Core_IPS_Project__r.Owner.Id 
                                                from Core_IPS_Project_Member__c 
                                                where Core_Status__c = 'Active' 
                                                and Core_IPS_Contact__c IN: conids ]){ 
            if(pmlst!=null && pmlst.Core_User__c != pmlst.Core_IPS_Project__r.Owner.Id){
                Core_IPS_Project_Member__c oldSnapshot = pmlst.clone(true, true, false, false);
                projMembersOld.add(oldSnapshot);                                         
                pmlst.Core_Status__c = 'Inactive';
                projmemnew.add(pmlst); 
            }                                 
            
        }
        if(!projmemnew.isEmpty()){ 
            Core_IPS_SkipTriggerHandler.skipQueueable=true;
            List<Database.SaveResult> projmemresul = Database.update(projmemnew, false);
			for (Database.SaveResult result : projmemresul) {
                if (!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        errorProjMemRecs.add('Error occurred: ' + err.getStatusCode() + ' - ' + err.getMessage()+' - '+err.getFields());
                    }  
                }
            }
            
        } 
        List<Contact> consupdate = new List<Contact>();
        for(Contact conlst : conchunk){
            conlst.Core_IPS_Active__c = false;
            conlst.Core_IPS_By_Pass_Validation__c = true;
            consupdate.add(conlst);
        }
        if(!consupdate.isEmpty()){ 
            Core_IPS_SkipTriggerHandler.skipQueueable=true;
            List<Database.SaveResult> consupdateList = Database.update(consupdate, false);
			for (Database.SaveResult result : consupdateList) {
                if (!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        errorContactRecs.add('Error occurred: ' + err.getStatusCode() + ' - ' + err.getMessage()+' - '+err.getFields());
                    }  
                }
            }
        } 
    }//execute method end
    
    public void finish(Database.BatchableContext BC){
        Id jobId;
        if(!projmemnew.isEmpty() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()){
            jobId = System.enqueueJob(new Core_IPS_ProjectMemberQueueable(projMembersOld, projmemnew));
        } else {
            System.debug('Skipped ProjectMemberQueueable because queueable job limit reached or no records found');
        }
        AsyncApexJob job;
        if(!Test.isrunningTest() && jobId!=null){ //CoreIPSECBUpdateBatch Error Fix        
        job = [
            SELECT Id, Status, NumberOfErrors, ExtendedStatus
            FROM AsyncApexJob
            WHERE Id = :jobId
        ];
		 } 
        List<Core_ACM_Account_Staging__c> stgaccsList = new List<Core_ACM_Account_Staging__c>();
        for(Core_ACM_Account_Staging__c stgaccs: [select AccountId__c,Core_Status__c 
                                                  from Core_ACM_Account_Staging__c 
                                                  where Core_Action__c = 'IPSECBFlagCheck' 
                                                  and AccountId__c=:accidsForUpdate order by CreatedDate desc limit 1]){
            if(job!=null && job.Status == 'Queued'){
                stgaccs.Core_Status__c='Completed';
            }else{
                stgaccs.Core_Status__c='Failed';
            }
            stgaccsList.add(stgaccs);
        }
        Database.update(stgaccsList, false);
        if(!errorProjMemRecs.isEmpty() && errorProjMemRecs!=null){   
            insertExceptionInFuture('','Core_IPS_ECB_Updates_Batch','Core_IPS_Project_Member__c','','',errorProjMemRecs);
        }
        if(!errorIntrestedPartyRecs.isEmpty() && errorIntrestedPartyRecs!=null){   
            //insertExceptionInFuture('','Core_IPS_Case_Interested_Party__c','Core_IPS_Project_Member__c','','',errorIntrestedPartyRecs);
            insertExceptionInFuture('','Core_IPS_ECB_Updates_Batch','Core_IPS_Case_Interested_Party__c','','',errorIntrestedPartyRecs);
        }
        if(!errorContactRecs.isEmpty() && errorContactRecs!=null){   
            //insertExceptionInFuture('','Core_IPS_Case_Interested_Party__c','Contact','','',errorContactRecs);
            insertExceptionInFuture('','Core_IPS_ECB_Updates_Batch','Contact','','',errorContactRecs);
        }
        Core_IPS_SkipTriggerHandler.skipQueueable = false;
    }
    /***************************************************************************************************
    Created Date: 09 Sept 2025
    Function    : 
    Description: This method is used call to InsertionMethod in different transaction as we receiving MIXED DML Error if we are inserting setup(GroupMember) and non-setup(Core_Exception) objecst in same trnasaction
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Pavani                    09/09/2024              Created
****************************************************************************************************/
    public static void insertExceptionInFuture(string  Record_Id,string ClassName,string objectName,string Msg,string MethodName,List<String> ex){ 
        String fullErrorMessage = String.join(ex, '\n');
        fullErrorMessage = fullErrorMessage+ '\n records Failed ';   
        String excetionDeatils= '';
        if(fullErrorMessage.length() >= 32768) {
            excetionDeatils = fullErrorMessage.substring(0, 32767);
        } else {
            excetionDeatils = fullErrorMessage;
        }
            string  Str = new Core_Exceptionclass().InsertException(Record_Id,ClassName,objectName,Msg,MethodName,excetionDeatils);
    }
    
}