/****************************************************************************************************
Apex Class Name : PSG_TransferSubmitterBatch
Version         : 1.0 
Created Date    : 2/1/2024
Function        : This BatchClass is used to transfer the records from one submitter to another.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bishal Singh               2/1/2024                Created
*****************************************************************************************************/

/*public without sharing class PSG_TransferSubmitterBatch implements Database.Batchable<sObject>, Database.Stateful {    
    private Id fromPreviousSubmitter;
    private Id toNewSubmitter;
    private String fromPreviousSubmitterName;
    private String userChoice;
    private String toNewSubmitterName;
    private Integer index = 0;
    private List<String> objectAPINameList = new List<String>{'Quote','DPAs_ALNs'};
    private Map<String, List<RecordWrapper>> errorMap = new Map<String, List<RecordWrapper>>();
    private Map<String, List<RecordWrapper>> successresultMap = new Map<String, List<RecordWrapper>>();
    private Map<String,String> objToLabelMap = new Map<String,String>{
                                                        'Quote' => 'Quote',
                                                        'DPAs_ALNs' => 'DPAs & ALNs'
                                                    };    

    public PSG_TransferSubmitterBatch(Id fromPreviousSubmitter, Id toNewSubmitter,String fromPreviousSubmitterName,String toNewSubmitterName,String userChoice){
        this.fromPreviousSubmitter = fromPreviousSubmitter;
        this.toNewSubmitter = toNewSubmitter;
        this.fromPreviousSubmitterName = fromPreviousSubmitterName;
        this.toNewSubmitterName = toNewSubmitterName;
        this.userChoice = userChoice;
    }

    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        if(userChoice != 'Both'){
            objectAPINameList=new List<String>{userChoice};
        }
        String query;
        if (objectAPINameList[index] == 'Quote') {
            query= 'SELECT Id, Name, SubmittedUser__c, SubmittedUser__r.Name, core_cpq_requestor_nm__c ' +
                'FROM SBQQ__Quote__c ' +
                'WHERE Pricing_Quote_Program_Nm__c =\'PSG\' AND core_cpq_requestor_nm__c = :fromPreviousSubmitter AND core_cpq_active_cb__c=True ' +
                'ORDER BY CreatedDate DESC';
        }else if(objectAPINameList[index] == 'DPAs_ALNs'){
            query= 'Select Id,Name,core_cpq_disty_submitted_user__c,core_cpq_disty_submitted_user__r.Name ' + 
                'FROM core_cpq_dpa_aln__c ' +
                'WHERE core_cpq_disty_submitted_user__c = :fromPreviousSubmitter AND core_cpq_ship_end_date_dt__c> TODAY AND core_cpq_status_txt__c NOT IN(\'Replaced\',\'Rejected\')' +
                'ORDER By CreatedDate desc';
        }        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchContext, List<sObject> records) {
        String objectName = objectAPINameList[index];
        try {
            processRecords(records,objectName);
        } catch (Exception e) {
            PSG_Utility.createCoreLogEntry('PSG_TransferSubmitterBatch', 'execute', 'Transferring Submitter from: ' + fromPreviousSubmitter + ' to: ' + toNewSubmitter,
                                        'Error Occurred While transferring Submitter on ' + objectName + ': ' + e.getMessage(), objectName, 'High','');
            List<RecordWrapper> errorList = errorMap.containsKey(objectName) ? errorMap.get(objectName) : new List<RecordWrapper>();
            for(sObject rec : records){
                errorList.add(new RecordWrapper((Id) rec.get('Id'), (String) rec.get('Name'),'Failure', 'Failed due to batch failure'));
            }            
            errorMap.put(objectName,errorList);
        }
    }

    public void finish(Database.BatchableContext batchContext) {
        if(index + 1 == objectAPINameList.size()) {
            String tableBody = 'Records Transfer Summary from ' + '<b>' + fromPreviousSubmitterName + '</b>' + ' to ' + '<b>' + toNewSubmitterName + '</b>' + '<br></br> <table class="t">';
            tableBody += '<tr><th class="t2">Object Name</th><th class="t2">Total Records</th><th class="t2">Success</th><th class="t2">Failure</th></tr>';
            for (String obj : objectAPINameList) {
                Integer failures = (errorMap.containsKey(obj)) ? errorMap.get(obj).size() : 0;
                Integer success = (successresultMap.containsKey(obj)) ? successresultMap.get(obj).size() : 0;
                Integer totalCount=success+failures;
                tableBody += '<tr><td class="t1">' + objToLabelMap.get(obj) + '</td><td class="t1">' + totalCount + '</td><td class="t1">' + success + '</td><td class="t1">' + failures + '</td></tr>';
            }
            tableBody += '</table>';    
            sendEmailToUsers(tableBody);
        }else {
            PSG_TransferSubmitterBatch tsBatch = new PSG_TransferSubmitterBatch(fromPreviousSubmitter, toNewSubmitter,fromPreviousSubmitterName,toNewSubmitterName,userChoice);
            tsBatch.index = index + 1;
            tsBatch.errorMap = errorMap;
            tsBatch.successresultMap=successresultMap;
            tsBatch.fromPreviousSubmitter = fromPreviousSubmitter;
            tsBatch.toNewSubmitter = toNewSubmitter;
            Database.executeBatch(tsBatch,Integer.Valueof(Label.PSG_SubmitterTransferbatchSize));
        }
    } 
    
    
    /************************************************************************************************************
    *Method Name : processRecords
    *Created Date: 2/1/2024
    *Author: Ranjit Kumar
    *Description : process records and transfer it to new submitter.
    ************************************************************************************************************/
    /*private void processRecords(List<sObject> records,String objName) {
        List<SObject> recordsToUpdate = new List<SObject>();
        for (sObject record : records) {
            if(objName=='Quote'){
                record.put('core_cpq_requestor_nm__c',toNewSubmitter);
            }else{
                record.put('core_cpq_disty_submitted_user__c',toNewSubmitter);
            }
            recordsToUpdate.add(record);
        }
        if (!recordsToUpdate.isEmpty()) {
            SBQQ.TriggerControl.disable();
            //PSG_Constants.isQuoteTriggerActive=false;
            //PSG_Constants.isDPAALNTriggerActive=false;
            List<Database.SaveResult> results = Database.update(recordsToUpdate, false);
            SBQQ.TriggerControl.enable();
            //PSG_Constants.isQuoteTriggerActive=true;
            //PSG_Constants.isDPAALNTriggerActive=true;
            processSaveResults(results, recordsToUpdate,objName);
        }
    }

    /************************************************************************************************************
    *Method Name : processSaveResults
    *Created Date: 2/1/2024
    *Author: Bishal Singh
    *Description : Process the result and map the error and success result based on Object API Name.
    ************************************************************************************************************/
    /*private void processSaveResults(List<Database.SaveResult> results, List<sObject> records, String objectName) {
        List<RecordWrapper> errorList = errorMap.containsKey(objectName) ? errorMap.get(objectName) : new List<RecordWrapper>();
        List<RecordWrapper> successList = successresultMap.containsKey(objectName) ? successresultMap.get(objectName) : new List<RecordWrapper>();
        for (Integer i = 0; i < results.size(); i++) {
            Database.SaveResult sr = results[i];
            if (!sr.isSuccess()) {
                /*String msg = PSG_QuotewithopptyInactive_Batch.getErrorAsString(sr.getErrors());
                Id recordId = (Id) records[i].get('Id');
                String recordName = (String) records[i].get('Name');    
                errorList.add(new RecordWrapper(recordId, recordName,'Failure', msg));*/
            /*}else{
                Id recordId = (Id) records[i].get('Id');
                String recordName = (String) records[i].get('Name');    
                successList.add(new RecordWrapper(recordId, recordName,'Success',' '));
            }            
        }
        errorMap.put(objectName, errorList);
        successresultMap.put(objectName, successList);        
    }
    
    /************************************************************************************************************
    *Method Name : generateCSVFile
    *Created Date: 2/1/2024
    *Author: Bishal Singh
    *Description : Generate the CSV Files for the error records along with error message.
    ************************************************************************************************************/
    /*private Messaging.EmailFileAttachment generateCSVFile(String objName){
        List<RecordWrapper> successList = successresultMap.containsKey(objName)?successresultMap.get(objName):new List<RecordWrapper>();
        List<RecordWrapper> errList = errorMap.containsKey(objName)?errorMap.get(objName):new List<RecordWrapper>();    
        String csvContent = 'Id,Record Number,Result,Error Message\n'; 
        if(!errList.isempty() || !successList.isempty()){
            for (RecordWrapper rw : errList) {
                csvContent = csvContent + '' + rw.recordId + ',' + rw.name + ',' + rw.result + ',' + rw.message + '\n';
            }             
            for (RecordWrapper rw : successList) {
                csvContent = csvContent + '' + rw.recordId + ',' + rw.name + ',' + rw.result + '\n';                
            }
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('text/csv');
            attach.setFilename(objToLabelMap.get(objName) +'.csv');
            attach.setInline(true);
            attach.Body = (Blob.valueOf(csvContent));
            return attach;
        }
        return null;        
    }        
    
    public class RecordWrapper {
        public String recordId;
        public String name;
        public String result;
        public String message;
        
        public RecordWrapper(String recordId, String name,String result,String message) {
            this.recordId = recordId;
            this.name = name;
            this.result = result;
            this.message = message;
        }
    }

    /************************************************************************************************************
    *Method Name : sendEmailToUsers
    *Created Date: 2/1/2024
    *Author: Bishal Singh
    *Description : Send email to the users, to notify them the transfer result.
    ************************************************************************************************************/
    /*private void sendEmailToUsers(String tableBody){
        OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address='wsm-postmaster@intel.com' LIMIT 1];
		EmailTemplate template = [SELECT Id, HTMLValue,Subject, Body, Name FROM EmailTemplate WHERE DeveloperName = 'PSG_Transfer_Details_Status'];
        Messaging.SingleEmailMessage getEmail = Messaging.renderStoredEmailTemplate(template.Id, null, UserInfo.getUserId());
        String body = getEmail.getHtmlBody();
        body = body.replace('TABLE_BODY', tableBody);
        Map<String,List<String>> userToEmailMap=new  Map<String,List<String>>();
        List<Id> userId = new List<Id>{fromPreviousSubmitter,toNewSubmitter,UserInfo.getUserId()};
            for(User u :[Select Id,Email from user where Id in :userId ]){
                if(u.Id==UserInfo.getUserId()){
                    userToEmailMap.put('RequestorEmail',new List<String>{u.Email});
                }else{
                    List<String> distyEmails=userToEmailMap.containsKey('DistyEmails')?userToEmailMap.get('DistyEmails'):new List<String>();
                    distyEmails.add(u.Email);
                    userToEmailMap.put('DistyEmails',distyEmails);
                }
            }
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> attachlist = new List<Messaging.EmailFileAttachment>();
        for(String objName : objectAPINameList){
            if(errorMap.containsKey(objName) || successresultMap.containsKey(objName)){
                attachlist.add(generateCSVFile(objName));
            }
        }
        for(String key : userToEmailMap.keyset()){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
            message.setTemplateID(template.Id);
            message.setToAddresses(userToEmailMap.get(key));
            message.setSubject(getEmail.getSubject());
            message.setHtmlBody(body);
            if(key=='RequestorEmail'){ 
                message.setFileAttachments(attachlist);
            } 
            messages.add(message);
        }     
        if(!messages.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    } 
}*/
@isTest
public class PSG_TransferSubmitterBatch{

}