/****************************************************************************************************
Apex Class Name : PSG_SendBulkSAPRequestBatch
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This class is used to fetch all the DPA/ALN records which are pending to submit to SAP and send requests.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
/*global class PSG_SendBulkSAPRequestBatch implements Database.Batchable<Sobject>,Database.Stateful,Database.AllowsCallouts{
    Map<Id,core_cpq_psg_log_entry__c> failedDPAWithErrorMap=new Map<Id,core_cpq_psg_log_entry__c>();
    Map<String,core_cpq_psg_log_entry__c> cisToResultMap = new Map<String,core_cpq_psg_log_entry__c>();
    public List<String> cisNoList;
    global Database.QueryLocator start(Database.BatchableContext bc){
        if(cisNoList != null && !cisNoList.isEmpty()){
            return Database.getQueryLocator([select id,Name,core_cpq_record_type_identifier__c from core_cpq_dpa_aln__c where Name IN :cisNoList and core_cpq_status_txt__c ='Approved' ]);
        }
        else{
            return Database.getQueryLocator([select id,Name,core_cpq_record_type_identifier__c from core_cpq_dpa_aln__c where core_cpq_update_from_batch_cb__c = true and core_cpq_status_txt__c ='Approved' ]);
        }
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> sobjLst) {
        List<core_cpq_dpa_aln__c> dpaAlnListToUpdate=new List<core_cpq_dpa_aln__c>();
        for(core_cpq_dpa_aln__c dpaRec :(List<core_cpq_dpa_aln__c>) sobjLst){
            PSG_Integration_DPA.LightningResponse lr=PSG_Integration_DPA.sendRequestToSAP(dpaRec.Id,'FutureCall');
            if(lr.isSuccess){
                //dpaRec.core_cpq_status_txt__c='Submitted';
                dpaRec.core_cpq_update_from_batch_cb__c=false;
                dpaRec.core_cpq_bypass_validation__c = true;
                dpaAlnListToUpdate.add(dpaRec);
            }
            core_cpq_psg_log_entry__c le=new core_cpq_psg_log_entry__c();
            le.core_cpq_class_name__c='PSG_SendBulkSAPRequestBatch';
            le.core_cpq_method_name__c='execute';
            le.core_cpq_severity__c= 'Low';
            le.core_cpq_sobjectname__c='core_cpq_dpa_aln__c';
            if(dpaRec.core_cpq_record_type_identifier__c == 'DPA'){
                le.core_cpq_message__c='DPA Request has been submitted to SAP CHM for processing.';
            }else if(dpaRec.core_cpq_record_type_identifier__c == 'ALN'){
                le.core_cpq_message__c='ALN Request has been submitted to SAP ECC for processing.';
            }
            le.core_cpq_details__c=lr.message;
            le.core_cpq_when__c=System.now();
            le.core_cpq_type__c='Outbound Message';
            if(!lr.isSuccess){
                le.core_cpq_message__c='Failed while submitting to SAP';
                le.core_cpq_type__c='Failure';
            }
            le.core_cpq_sObjectType__c=dpaRec.core_cpq_record_type_identifier__c;
            le.core_cpq_sObjectRecord__c=dpaRec.Name;
            le.core_cpq_sobjectid__c=dpaRec.Id;
            failedDPAWithErrorMap.put(dpaRec.Id,le);
            cisToResultMap.put(dpaRec.Name,le);
        }
        if(!dpaAlnListToUpdate.isEmpty()){
            update dpaAlnListToUpdate;
            for(core_cpq_dpa_aln__c dpa: dpaAlnListToUpdate){
                dpa.core_cpq_bypass_validation__c = false;
            }
            update dpaAlnListToUpdate;
        }
    }              
    global void finish(Database.BatchableContext bc) {
        if(!failedDPAWithErrorMap.isEmpty()){
            insert failedDPAWithErrorMap.values();
            //PSG_Utility.createCoreLogEntry('PSG_SendBulkSAPRequestBatch','execute','Expired,Extended and Hold ALNs/DPAs while PRID Revision/Deactivation',''+failedDPAWithErrorMap,'core_cpq_dpa_aln__c','High','');
        }
        if(cisNoList != null && !cisNoList.isEmpty()){
            AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems From AsyncApexJob WHERE Id = :bc.getJobId()];
            Messaging.EmailFileAttachment csvAttcmnt = new Messaging.EmailFileAttachment();
            String csvname = 'DPA_ALN_BULKUPLOAD.csv';
            String mainContent = '';
            String data = '';
            Integer s = 0;
            data = 'CIS No.,Result,Reason\n';
            for(String cis : cisToResultMap.keySet()){
                String d='';
                if(cisToResultMap.get(cis).core_cpq_type__c == 'Failure'){
                    d = ''+cis+',Failure,"'+cisToResultMap.get(cis).core_cpq_details__c+'"\n';
                }
                else{
                    d = ''+cis+',Success,'+''+'\n';
                    s++;
                }
                data += d;
            }
            mainContent +=  data;
            blob csvBlob = Blob.valueOf(mainContent);
            csvAttcmnt.setFileName (csvname);
        	csvAttcmnt.setBody (csvBlob);
            String dpaAlnBody='<h4 style="color:black">';
            dpaAlnBody += 'Total # of Records Uploaded: '+ job.TotalJobItems +'<br>';
            dpaAlnBody += 'Total # of Successfully Uploaded Records: '+ s +'<br>';
            dpaAlnBody += 'Total # of Failed Records: '+ (job.TotalJobItems - s) +'</h4>';
            EmailTemplate tempId = [SELECT Id, HTMLValue,Subject, Body, Name FROM EmailTemplate WHERE DeveloperName = 'PSG_DPA_ALN_Bulk_Upload_Results'];
            Savepoint sp = Database.setSavepoint();
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
			mail1.setTemplateId(tempId.Id);
            mail1.setTargetObjectId(Userinfo.getUserId());
            mail1.setToAddresses(new List<String>{UserInfo.getUserEmail()});
            mail1.setSaveAsActivity(false);
            mail1.setFileAttachments (new Messaging.EmailFileAttachment []{csvAttcmnt});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail1});
            Database.rollback(sp);
            String emailBody=mail1.getHtmlBody();
            emailBody=emailBody.replace('dpa_aln_body',dpaAlnBody);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId([Select Id,address from OrgWideEmailAddress where address='wsm-postmaster@intel.com' Limit 1][0].Id);
            mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});
            mail.setHtmlBody(emailBody);
            mail.setSubject(tempId.Subject);
            mail.setFileAttachments (new Messaging.EmailFileAttachment []{csvAttcmnt});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
    }
}*/
@isTest
public class PSG_SendBulkSAPRequestBatch{

}