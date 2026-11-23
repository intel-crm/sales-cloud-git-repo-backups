/***************************************************************************************************************************************
Apex Class Name     : PRM_DQBatchForContactWithoutEntitlement
Version             : 1.0
Created Date        : March 2026
Function            : Batch class to assign pending Contact Entitlements
Maximum Batch Size  : 10
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Utkarsh                       22-March-2026                    This class process the contact object records which are IPA but entitlements are not assigned. 
                        
*************************************************************************************************************************************/
global class PRM_DQBatchForContactWithoutEntitlement
    implements Database.Batchable<SObject>, Database.Stateful {

    global set<Id> contactsWithoutEntitlement = new set<Id>();
    global string logentires;
    public List<Contact> contList= new List<Contact>();
    public Set<Id> contactIds = new Set<Id>();
    public Set<Id> accountIds = new Set<Id>();
    public Set<Id> contactsWithEntitlement = new Set<Id>();
    public List<Contact> contactsToProcess = new List<Contact>();
    public List<PRM_Account_Contact_Relationship__c> acrToProcess = new List<PRM_Account_Contact_Relationship__c>();
    public List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
    public List<PRM_IPA_DQ_Logs__c> dqLogList = new List<PRM_IPA_DQ_Logs__c>();
    public String logEntryMsgString='';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Datetime dt = Datetime.valueOfGmt(Label.PRM_EntitlementDQBatchPickupDate.replace('T', ' ').replace('Z', ''));
        system.debug('dt-->'+dt);

        return Database.getQueryLocator([
            SELECT Id, Name, Email,Core_IPA_PartnerRole__c,LastModifiedDate,CreatedDate
            FROM Contact
            WHERE (CreatedDate > :dt
               OR LastModifiedDate > :dt) AND (Core_IPA_PartnerRole__c != null OR Core_IPA_PartnerRole__c != '')
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        
        String agsEntitlement = System.Label.PRM_EntitlementTypeAGS;
        String sfdcEntitlement = System.Label.PRM_EntitlementTypeSFDC;
        logEntryMsgString+='Inside execute method, scope: '+scope;
        try{
            for(Contact con : scope) {
                contactIds.add(con.Id);
            }
            System.debug('contactIds : '+ contactIds.size());
            if(contactIds != null && !contactIds.isEmpty()){
                for(Core_Contact_Entitlement__c ce : [
                    SELECT Id, Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Entitlement_Type__c,Core_From_Source__c FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c IN :contactIds AND (Core_Entitlement_Type__c =:agsEntitlement OR Core_Entitlement_Type__c =:sfdcEntitlement)
                ]){
                    contactsWithEntitlement.add(ce.Core_Contact_Id__c);
                }
                System.debug('contactsWithEntitlement : '+ contactsWithEntitlement.size());
            }
            for(Contact con : scope) {
                if(!contactsWithEntitlement.contains(con.Id)) {
                    contactsToProcess.add(con);
                    contactsWithoutEntitlement.add(con.Id);
                }
            }
            System.debug('contactsWithoutEntitlement : '+ contactsWithoutEntitlement.size());
            if(contactsWithoutEntitlement != null && !contactsWithoutEntitlement.isEmpty()){
                for(PRM_Account_Contact_Relationship__c acr : [
                    SELECT Id, PRM_Contact_Id__c,PRM_Account_Id__c,PRM_execute_trigger__c,PRM_InActive_Ind__c,PRM_Partner_Role__c,PRM_Partner_Role_UI__c,PRM_Relationship_Id__c,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c
                    FROM PRM_Account_Contact_Relationship__c
                    WHERE PRM_Contact_Id__c IN :contactsWithoutEntitlement
                ]) {
                    accountIds.add(acr.PRM_Account_Id__c);
                    acrToProcess.add(acr);
                }
                
            }
            if(contactsWithoutEntitlement!= null && !contactsWithoutEntitlement.isEmpty()){
                contList = [Select id,name,Core_IPA_PartnerRole__c from Contact Where Id IN:contactsWithoutEntitlement];
            }
            system.debug('contList-->'+contList.size());
            System.debug('accountIds : '+ accountIds.size());
            System.debug('acrToProcess : '+ acrToProcess.size());
            if(accountIds != null && !accountIds.isEmpty()){
                acmList = [SELECT Id, PRM_Account_Id__c, PRM_Channel_Program_Level_Id__c, PRM_Channel_Program_Id__c, PRM_Partner_Role__c, PRM_Status_Nm__c FROM PRM_AccountChannelMembership__c WHERE PRM_Channel_Program_Id__r.Name = :System.Label.PRM_Intel_Partner_Alliance AND PRM_Status_Nm__c = :System.Label.PRM_Status AND PRM_Account_Id__c IN :accountIds];
            }
            System.debug('acmList : '+ acmList.size());
            
            PRM_IPA_DQ_Logs__c dqLog = new PRM_IPA_DQ_Logs__c();
            dqLog.PRM_Object_Name__c='Contact Entitlement' ;
            dqLog.PRM_Message__c = 'Records will be updated as part of PRM_DQBatchForContactWithoutEntitlement processing.';
            dqLog.PRM_Apex_Class_Name__c = 'PRM_DQBatchForContactWithoutEntitlement';
            dqLogList.add(dqLog);
        }
        catch(Exception ex){
            logEntryMsgString='\n errors:'+ex;
            System.debug('Contacts without entitlement in this batch: '+ contactsToProcess.size());
        }
    }

    global void finish(Database.BatchableContext bc) {
        
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
                    if((acrToProcess != null && !acrToProcess.isEmpty()) && (acmList != null && !acmList.isEmpty())){
                        PRM_AcctContRel_TriggerHandlerNew.insertContactEntitlement(acrToProcess,null,acmList);
                    }
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
                Core_Log_Entry.logEntryWithDetails('PRM_DQBatchForContactWithoutEntitlement', 'IPA', 'PRM_DQBatchForContactWithoutEntitlement', 'Medium','Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', '');
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