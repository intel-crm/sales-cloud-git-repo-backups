/**************************************************************************************************************
Apex Class Name:  PRM_ProcessRollUpDownOPIDRecords
Version     : 1.0 
Created Date: 27 May 2020
Function    : This batch takes input OPID and CAG list and rollup/rolldown on PAG Account
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Anish Patole         05/27/2020        Initial version
* Srishty Sharma       11/17/2020        US835505:Implementation of logging mechanism for OPID Inbound Batch
***************************************************************************************************************/
global class PRM_ProcessRollUpDownOPIDRecords implements  Database.Batchable<sObject>,Database.stateful {
    
    global List<String> intelAccountIds = new List<String>();  
    global Map<id,Core_Account_Group_Member__c> cagsToUpsertMap = new  Map<id,Core_Account_Group_Member__c>();      
    global String logEntryMsg='';
    /*Error Log Entry */
    public static final String LOG_ENTRY_ORIGIN = 'OPID Inbound Batch';
    public static final String LOG_ENTRY_PROJECT = 'IPA';
    public static final String LOG_ENTRY_SCOPE = 'OPID Inbound Batch';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public List<Core_OnePartner_Inbound_Message__c> inbndMsgList = new List<Core_OnePartner_Inbound_Message__c>();
    
    global PRM_ProcessRollUpDownOPIDRecords(Set<String> intelAccountIds,Map<Id,Core_Account_Group_Member__c> cagsToUpsertMap) {     
        if(intelAccountIds != null){
            this.intelAccountIds = new List<String>(intelAccountIds);
        }      
        if(cagsToUpsertMap != null){
            this.cagsToUpsertMap = new Map<Id,Core_Account_Group_Member__c>(cagsToUpsertMap);
        }        
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //added by Anish - start 
       // String pagRecordId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        //String query= 'Select Id, name, Core_OnePartnerID__c from Account where Core_OnePartnerID__c in :opids and RecordTypeId = :pagRecordId';
        String query = 'Select id,Core_Status__c,Core_CIM_ID__c,Core_OnePartnerID__c,Core_SalesCloud_AccountID__c,Core_PrimeID__c,Core_PAG_Grouping_Method__c,Core_Prime_Account_Name__c,Core_OnePartner_Account_Name__c, Error_Description__c, Core_Effective_End_Date_Time__c, Core_Effective_Start_Date_Time__c,Core_Status_Effective_End_Date_Time__c from Core_OnePartner_Inbound_Message__c where Core_Status__c = \'LOAD COMPLETE\' order by Core_OnePartnerID__c, Core_Effective_End_Date_Time__c DESC NULLS LAST';
        return Database.getQueryLocator(query);        
        // String query = 'SELECT Core_Partner_Account_Id__r.name ,Core_Intel_Account_Id__r.name, Core_IPA_Partner_Segment__c, Core_IPA_Partner_Speciality__c, Core_Account_Type__c FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c != null  ';
        
        //added by Anish - end
        
    }
    
    global void execute(Database.BatchableContext bc, List<Core_OnePartner_Inbound_Message__c> inboundMsgList){ 
        try{logEntryMsg+='\n*****SECOND BATCH EXECUTION STARTS HERE*******';
            Set<String> opids = new Set<String>();   
            Set<String> listOfAccountsRemoved = new Set<String>();
            //if(inboundMsgList.size()>0){
                for(Core_OnePartner_Inbound_Message__c inbMsg: inboundMsgList){          
                    opids.add(String.valueOf(inbMsg.Core_OnePartnerID__c.intValue())); 
                    if(inbMsg.Core_Effective_End_Date_Time__c != null && inbMsg.Core_Effective_End_Date_Time__c.date() <= Date.Today()){                    
                        listOfAccountsRemoved.add(String.valueOf(inbMsg.Core_OnePartnerID__c.intValue()));                                      
                    }
                    inbndMsgList.add(inbMsg);
                }
           // }
            
            String pagRecordId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
            List<Account> accounttoUpdate = [Select Id, name, Core_OnePartnerID__c from Account where Core_OnePartnerID__c in :opids and RecordTypeId = :pagRecordId];
            List<Core_Account_Group_Member__c> listOfCAG = [SELECT Core_Partner_Account_Id__c,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,  Core_Partner_Account_Id__r.Core_OnePartnerID__c, Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c,  Core_Partner_Account_Id__r.Core_Account_Type__c,Core_Intel_Account_Id__r.Core_OnePartnerID__c, Core_Intel_Account_Id__r.Core_IPA_Partner_Segment__c,  Core_Intel_Account_Id__r.Core_Account_Type__c FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__r.Core_OnePartnerID__c in :opids and Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true and Core_Inactive_Ind__c = false WITH SECURITY_ENFORCED]; 
            PRM_OPIDErrorWrapper errorWrapper = null;
            PRM_OPIDPAGRecordOperation opidAGRecOp = new PRM_OPIDPAGRecordOperation(inboundMsgList); 
            List<String> logEntryMsgList = new List<String>();
            errorWrapper = opidAGRecOp.rollUpAccounts(accounttoUpdate,logEntryMsgList,listOfCAG); 
            if(logEntryMsgList.size()>0){
                logEntryMsg+=logEntryMsgList[0];
            }
            logEntryMsgList = new List<String>();
            errorWrapper = opidAGRecOp.rolldownChannelMembership(errorWrapper,logEntryMsgList,listOfCAG);
            if(logEntryMsgList.size()>0){
                logEntryMsg+=logEntryMsgList[0];
            }
            opidAGRecOp.errLogForProcInMessage(errorWrapper);
            
            //Inactivate ABA based on inactivated ACM at OPID record taking reference of inactivated listofCAG record
            if(!listOfAccountsRemoved.isEmpty())
            {                
                logEntryMsg+=opidAGRecOp.inactivateBenefitAsPerACM(listOfAccountsRemoved);
            }
                if((logEntryMsg.length() > Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength() || Test.isRunningTest()) && logEntryMsg!=''){
                    //if(logEntryMsg!=''){// this block will create error log records on the basis of length of logEntryMsg and Field limit.
                        PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
                        Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
                        logEntryUtility.addLogEntry(logEntryMsg,fieldLength);
                        for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
                            Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,logEntryMsg.split('@@@')[0] ,logEntryUtility.logEntryList[i] , '', '', '');
                        }//loop ends here..
                    //}   
                    logEntryMsg = '';
                }
        }catch(Exception e){ PRM_ProcessInboundOPIDRecords processInbRecords = new PRM_ProcessInboundOPIDRecords();
            logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processException(e);
            processInbRecords.updateStatus(inboundMsgList,null, null, null, e.getMessage() + ': ' + e.getStackTraceString());
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        //added by Anish - start 
   //     AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,  TotalJobItems, CreatedBy.Email FROM AsyncApexJob
     //                       WHERE Id = :bc.getJobId()];
       
        //added by Anish - end

        //TWC729-7132 OPID Association Success Email
           logEntryMsg+=PRM_OPIDProcessUtility.opidAssociationEmail(intelAccountIds,inbndMsgList,cagsToUpsertMap);
                 
        logEntryMsg+='\n*****SECOND BATCH ENDS HERE...******';
        if(logEntryMsg!=''){// this block will create error log records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsg,fieldLength);
            for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
                Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,logEntryMsg.split('@@@')[0] ,logEntryUtility.logEntryList[i] , '', '', '');
            }//loop ends here..
        }
        
    }
}