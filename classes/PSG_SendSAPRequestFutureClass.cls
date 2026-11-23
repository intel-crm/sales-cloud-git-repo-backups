/****************************************************************************************************
Apex Class Name : PSG_SendSAPRequestFutureClass
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This class is used to send the Bulk SAP requests for bulk DPA/ALN's.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
public without sharing class PSG_SendSAPRequestFutureClass {
    /************************************************************************************************************
	*Method Name : bulkSAPRequestFuture
	*Created Date: 08/13/2021
	*Author: Hari
	*Description : This method sends the SAP requests in asynchronous mode.
	************************************************************************************************************/
    @future(callout=true)
    public static void bulkSAPRequestFuture(Set<Id> dpaAlnIds) {
        bulkSAPRequest(dpaAlnIds);
    }
    
   
    /************************************************************************************************************
	*Method Name : bulkSAPRequest
	*Created Date: 08/13/2021
	*Author: Hari
	*Description : Sends Individual SAP request for all the DPA/ALN id's given as input in synchronous mode.
	************************************************************************************************************/
    public static void bulkSAPRequest(Set<Id> dpaAlnIds) {
        List<core_cpq_dpa_aln__c> dpaAlnList=[Select Id,Name,core_cpq_record_type_identifier__c from core_cpq_dpa_aln__c where Id in  :dpaAlnIds and core_cpq_status_txt__c = 'Approved'];
        //List<core_cpq_dpa_aln__c> dpaAlnListToUpdate=new List<core_cpq_dpa_aln__c>();
        if(!dpaAlnList.isEmpty()){
            Map<Id,core_cpq_psg_log_entry__c> failedDPAWithErrorMap=new Map<Id,core_cpq_psg_log_entry__c>();
            for(core_cpq_dpa_aln__c dpaRec : dpaAlnList){
                PSG_Integration_DPA.LightningResponse lr=PSG_Integration_DPA.sendRequestToSAP(dpaRec.Id,'FutureCall');
                /*if(lr.isSuccess){
                    dpaRec.core_cpq_status_txt__c='Submitted';
                    dpaRec.core_cpq_bypass_validation__c = true;
                    dpaAlnListToUpdate.add(dpaRec);
                }*/
                core_cpq_psg_log_entry__c le=new core_cpq_psg_log_entry__c();
                le.core_cpq_class_name__c='PSG_SendSAPRequestFutureClass';
                le.core_cpq_method_name__c='bulkSAPRequest';
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
            }
            /*if(!dpaAlnListToUpdate.isEmpty()){
                update dpaAlnListToUpdate;
                for(core_cpq_dpa_aln__c dpa: dpaAlnListToUpdate){
                    dpa.core_cpq_bypass_validation__c = false;
                }
                update dpaAlnListToUpdate;
            }*/
            if(!failedDPAWithErrorMap.isEmpty()){
                insert failedDPAWithErrorMap.values();
                //PSG_Utility.createPSGLogEntry('PSG_SendSAPRequestFutureClass','bulkSAPRequestFuture','Expired and Hold ALNs/DPAs while PRID Revision/Deactivation',''+failedDPAWithErrorMap,'core_cpq_dpa_aln__c','High','Outbound Message - Future','','','');
            }
        }
    }
}