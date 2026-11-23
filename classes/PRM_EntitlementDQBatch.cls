/***************************************************************************************************************************************
Apex Class Name     : PRM_EntitlementDQBatch
Version             : 1.0
Created Date        : March 2026
Function            : Batch class to assign pending Contact Entitlements
Maximum Batch Size  : 10
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Utkarsh                       22-March-2026                    Start Method returns all the Benefit_Entitlement object records. 
                        based on the entitlements 
*************************************************************************************************************************************/
global class PRM_EntitlementDQBatch implements Database.Batchable<sObject>,Database.Stateful{
    global set<string> contids=new set<string>();
    global string logentires;
    global set<id> accIdSetAssoc=new set<Id>();
    global set<id> accIdSetRemove=new set<Id>();
    public List<PRM_IPA_DQ_Logs__c> dqLogList = new List<PRM_IPA_DQ_Logs__c>();
    public String logEntryMsgString='';
    public List<Contact> contList= new List<Contact>();
    public List<PRM_Batch_Entitlement__c> beListwithInProgressStatus = new List<PRM_Batch_Entitlement__c>();
        
   
    /*This method fetches all the batch entitlements records which has status as New and In progress*/
    global static Database.QueryLocator start(Database.BatchableContext context){
        
        Datetime dt = Datetime.valueOfGmt(Label.PRM_EntitlementDQBatchPickupDate.replace('T', ' ').replace('Z', ''));
        system.debug('dt-->'+dt);
        
        return Database.getQueryLocator([
        SELECT Id, Name,PRM_Status_Nm__c,
               PRM_Account_Id__c,
               PRM_Contact_Id__c,
               PRM_Contact_Id__r.AccountId,
               PRM_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c,
               PRM_Contact_Id__r.Core_Login_Status__c,
               PRM_Entitlement_Id__c,
               PRM_IsRemove_Ind__c,
               PRM_Contact_Id__r.PRM_Wechat_Union_Id__c
        FROM PRM_Batch_Entitlement__c
        WHERE (PRM_Status_Nm__c = 'New'
             OR PRM_Status_Nm__c = 'In Progress')
        AND (PRM_Contact_Id__r.Core_Login_Status__c != NULL
             OR PRM_Contact_Id__r.PRM_Wechat_Union_Id__c != NULL) AND CreatedDate > :dt
        ]);
    }
    /*This method passes all batch entitlements record fetch by query locator to PRM_EntitlementDQUtility class*/
    global void execute(Database.BatchableContext context, List<PRM_Batch_Entitlement__c> scope){
        List<PRM_Batch_Entitlement__c> beListwithNewStatus = new List<PRM_Batch_Entitlement__c>();
        List<PRM_Batch_Entitlement__c> tempBeList = new List<PRM_Batch_Entitlement__c>();
        List<PRM_Batch_Entitlement__c> finalBeList = new List<PRM_Batch_Entitlement__c>();
        Set<Id> setContactId = new Set<Id>();
        system.debug('scope-->'+scope);
        System.debug('Number of scope records: ' + scope.size());
        
        logEntryMsgString+='Inside execute method, scope: '+scope;
        for(PRM_Batch_Entitlement__c be: scope){
            if(!be.PRM_IsRemove_Ind__c){
            contids.add(be.PRM_Contact_Id__c);
            }
            if(be.PRM_Status_Nm__c == 'New'){
                beListwithNewStatus.add(be);
            }
            if(be.PRM_Status_Nm__c == 'In Progress'){
                beListwithInProgressStatus.add(be);
            }
            setContactId.add(be.PRM_Contact_Id__c);
            system.debug('setContactId-->'+setContactId.size());
            
        }
        if(setContactId!= null && !setContactId.isEmpty()){
            contList = [Select id,name,Core_IPA_PartnerRole__c from Contact Where Id IN:setContactId];
        }
        system.debug('contList-->'+contList.size());
        //Update the Status of the Batch Entitelments records from New to In-Progress
        tempBeList = PRM_EntitlementUtility.updateBatchEntitelmentStatus(beListwithNewStatus);
        beListwithInProgressStatus.addAll(tempBeList);
        system.debug('beListwithInProgressStatus-->'+beListwithInProgressStatus.size());
        
        PRM_EntitlementUtility.accIdAssocSet.addAll(accIdSetAssoc);
        PRM_EntitlementUtility.accIdRemoveSet.addAll(accIdSetRemove);
        accIdSetAssoc.clear();
        accIdSetRemove.clear();
        
        accIdSetAssoc.addAll(PRM_EntitlementUtility.accIdAssocSet);
        accIdSetRemove.addAll(PRM_EntitlementUtility.accIdRemoveSet);
       
        if(getlogentries.logentries!=null)
        this.logentires=getlogentries.logentries;
        system.debug('---logentry '+getlogentries.logentries);
        system.debug('---logenry '+ this.logentires);
        
        PRM_IPA_DQ_Logs__c dqLog = new PRM_IPA_DQ_Logs__c();
        dqLog.PRM_Object_Name__c='Contact Entitlement' ;
        dqLog.PRM_Message__c = 'Records will be updated as part of PRM_EntitlementDQBatch processing.';
        dqLog.PRM_Apex_Class_Name__c = 'PRM_EntitlementDQBatch';
        dqLogList.add(dqLog);
    }
    global void finish(Database.BatchableContext context){
        
        Decimal threshold=0;
        Map<String, Map<String, Object>> dqObjectsMap = getCustomMetadataRecords();
        try{
            if(dqObjectsMap != null && !dqObjectsMap.isEmpty()){
                if(dqObjectsMap.containsKey('Threshold')){
                    threshold = Decimal.valueOf(String.valueOf(dqObjectsMap.get('Threshold').get('Threshold__c')));
                }
            }
            if(contList!= null && !contList.isEmpty()){
                logEntryMsgString+='\n contList: '+contList;
                if(contList.size() < threshold){
                    PRM_EntitlementUtility.assignContactEntitlements(beListwithInProgressStatus);
                }
                else{
                    PRM_IPADQFixBatch IPADQBatch = new PRM_IPADQFixBatch();
                    IPADQBatch.sendWarningEmail(contList,'Contact Entitlement');
                }
            }
            List<Database.SaveResult> dqResultList = Database.insert(dqLogList,false);
            for(Database.SaveResult dqResult: dqResultList){
                if(!dqResult.isSuccess()){
                    for (Database.Error err : dqResult.getErrors()) {
                        logEntryMsgString+= 'Message: ' + err.getMessage() + '\n'  + 'Fields: ' + err.Fields.toString() + '\n' + 'StatusCode: ' + err.getStatusCode() + '\n';
                    }
                }
            }
            if(contids.size()>0 && System.Label.PRM_Tracker_Enabled=='true')
            System.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps (null,contids,this.logentires,'PRM_EntitlementDQUtility','Admin'));
        }
        catch(Exception ex){
            logEntryMsgString='\n errors:'+ex;
        }
        string jobInitiatedDateTime = System.Now().format('MM/dd/YYYY HH:MM:SS','PST');
        if(logEntryMsgString!=''){// this block will create Log Entry records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
            for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
                Core_Log_Entry.logEntryWithDetails('PRM_EntitlementDQBatch', 'IPA', 'PRM_EntitlementDQBatch', 'Medium','Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', '');
            }//loop ends here..
        }
        
    }
    public  Map<String, Map<String, Object>> getCustomMetadataRecords (){
        Map<String, Map<String, Object>> dqObjectsMap = new Map<String, Map<String, Object>>();
        Core_CustomMetadataObjectController customMetadataController = new Core_CustomMetadataObjectController('DQ_Objects_mdt');
        dqObjectsMap = customMetadataController.getAll();
        return dqObjectsMap;
    }   
}