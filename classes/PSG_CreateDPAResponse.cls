/****************************************************************************************************
Apex Class Name : PSG_CreateDPAResponse
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This class is used to update the DPA/ALN record when requested by SAP.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
/*@RestResource(urlMapping='/v1/CreateDPAResponse/*')
global without sharing class PSG_CreateDPAResponse {
    
    /************************************************************************************************************
    *Method Name : UpdateDPA
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Updates the status of DPA/ALN record based on the request from SAP.
    ************************************************************************************************************/
    /*@HttpPost
    global static void UpdateDPA() {
        List<core_cpq_dpa_aln__c> dpaList=new List<core_cpq_dpa_aln__c> ();
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        String strReq = req.requestBody.toString();
        Boolean isSuccess=true;
        JSONGenerator jsGen=JSON.createGenerator(true);
        jsGen.writeStartObject();
        try{
            Map<String,Map<String,String>> changeFlagToStatusMap=new Map<String,Map<String,String>>();
            for(PSG_DPA_ALN_Response_Mapping__mdt mdtRec : PSG_DPA_ALN_Response_Mapping__mdt.getAll().values()){
                if(mdtRec.psg_isactive__c){
                    if(changeFlagToStatusMap.containsKey(mdtRec.psg_change_flag__c)){
                        Map<String,String> sapToSfStatusMap=changeFlagToStatusMap.get(mdtRec.psg_change_flag__c);
                        sapToSfStatusMap.put(mdtRec.psg_sap_status__c,mdtRec.psg_dpa_aln_status__c);
                        changeFlagToStatusMap.put(mdtRec.psg_change_flag__c,sapToSfStatusMap);
                    }else{
                        changeFlagToStatusMap.put(mdtRec.psg_change_flag__c,new Map<String,String>{mdtRec.psg_sap_status__c => mdtRec.psg_dpa_aln_status__c});
                    }
                }
            }
            CreateSAPRequestWrapper reqWrapper=(CreateSAPRequestWrapper) System.JSON.deserialize(strReq, CreateSAPRequestWrapper.class);
            String dpaName=reqWrapper?.ListOfDpaInterfaceAltera?.DpaInterfaceAltera?.DPANo;
            String sapStatus=reqWrapper?.ListOfDpaInterfaceAltera?.DpaInterfaceAltera?.SAPDPAStatus;
            String syncComments=reqWrapper?.ListOfDpaInterfaceAltera?.DpaInterfaceAltera?.SyncComments;
            String sapDpaNo=reqWrapper?.ListOfDpaInterfaceAltera?.DpaInterfaceAltera?.SAPDPANo;
            dpaName=dpaName==null?'':dpaName;
            sapStatus=sapStatus==null?'':sapStatus;
            syncComments=syncComments==null?'':syncComments;
            sapDpaNo=sapDpaNo==null?'':sapDpaNo;      
            dpaList=[SELECT Id,Name,core_cpq_status_txt__c,core_cpq_change_flag__c,core_cpq_replace_aln_txt__c,core_cpq_sap_status_txt__c,core_cpq_sync_comments_txt__c,core_cpq_dpa_aln_no_nbr__c,core_cpq_record_type_identifier__c from core_cpq_dpa_aln__c WHERE core_cpq_cis__c=:dpaName or core_cpq_siebel_cis_no_txt__c=:dpaName];
            List<core_cpq_dpa_aln__c> dpaListToUpdate= new List<core_cpq_dpa_aln__c>();    
            if(!dpaList.isEmpty()){
                core_cpq_dpa_aln__c dpaObj=dpaList[0];
                dpaObj.core_cpq_sap_status_txt__c=sapStatus;
                dpaObj.core_cpq_sync_comments_txt__c=syncComments;
                dpaObj.core_cpq_dpa_aln_no_nbr__c=sapDpaNo;
                if(dpaObj.core_cpq_change_flag__c!=null && changeFlagToStatusMap.containsKey(dpaObj.core_cpq_change_flag__c)){
                    Map<String,String> sapToSfStatusMap=changeFlagToStatusMap.get(dpaObj.core_cpq_change_flag__c);
                    if(sapStatus == '' || sapToSfStatusMap.containsKey(sapStatus) ){
                        String sfStatus=sapStatus == '' ? sapToSfStatusMap.get('NULL') : sapToSfStatusMap.get(sapStatus);
                        dpaObj.core_cpq_status_txt__c=sfStatus;
                        Date d=date.today();
                        if(dpaObj.core_cpq_record_type_identifier__c=='DPA' && dpaObj.core_cpq_status_txt__c=='Approved'){
                            dpaObj.core_cpq_dpa_approved_date__c=d.format();
                        }else if(dpaObj.core_cpq_record_type_identifier__c=='ALN' && dpaObj.core_cpq_status_txt__c=='Approved'){
                            dpaObj.core_cpq_aln_approved_date__c=d.format();
                        }
                        if(dpaObj.core_cpq_change_flag__c == 'R' && dpaObj.core_cpq_replace_aln_txt__c != null && dpaObj.core_cpq_status_txt__c=='Approved'){
                            dpaListToUpdate=[SELECT Id,core_cpq_status_txt__c from core_cpq_dpa_aln__c WHERE core_cpq_dpa_aln_no_nbr__c=:dpaObj.core_cpq_replace_aln_txt__c];   
                            if(!dpaListToUpdate.isEmpty())
                                dpaListToUpdate[0].core_cpq_status_txt__c='Replaced';
                            	dpaListToUpdate[0].core_cpq_status_Change_reason__c='Replaced by ALN - '+dpaObj.Name;
                            	dpaListToUpdate[0].core_cpq_bypass_validation__c=true;
                        }
                        dpaObj.core_cpq_last_updated_in_sap__c=DateTime.now();
                        dpaObj.core_cpq_bypass_validation__c=true;
                        dpaListToUpdate.add(dpaObj);
                        if(!dpaListToUpdate.isEmpty()){
                            update dpaListToUpdate;
                            for(core_cpq_dpa_aln__c dpa: dpaListToUpdate){
                                dpa.core_cpq_bypass_validation__c = false;
                            }
                            update dpaListToUpdate;
                        }
                        jsGen.writeBooleanField('success', true);
                        jsGen.writeStringField('message', 'Updated '+dpaObj.core_cpq_record_type_identifier__c+' Record : '+dpaName+' Successfully');
                    }else{
                        isSuccess=false;
                        jsGen.writeBooleanField('success', false);
                        jsGen.writeStringField('message', 'Unable to find mapping for changeflag : '+dpaObj.core_cpq_change_flag__c+' and SAPStatus : '+sapStatus);
                    }
                }else{
                    isSuccess=false;
                    jsGen.writeBooleanField('success', false);
                    jsGen.writeStringField('message', 'Changeflag was empty for '+dpaObj.core_cpq_record_type_identifier__c+' record or no mapping found for changeflag : '+dpaObj.core_cpq_change_flag__c);
                }
            }else{
                isSuccess=false;
                jsGen.writeBooleanField('success', false);
                jsGen.writeStringField('message', 'Unable to find DPA/ALN record : '+dpaName);
            }
        }catch(Exception e){
            isSuccess=false;
            jsGen.writeBooleanField('success', false);
            jsGen.writeStringField('message',e.getMessage());
        }
        jsGen.writeEndObject();
        jsGen.close();
        res.responseBody = Blob.valueof(jsGen.getAsString());
        Id dpaId=!dpaList.isEmpty()?dpaList[0].Id:null;
        String dpaType=!dpaList.isEmpty()?dpaList[0].core_cpq_record_type_identifier__c:null;
        String dpaNo=!dpaList.isEmpty()?dpaList[0].Name:null;
        PSG_Utility.createPSGLogEntry('PSG_CreateDPAResponse', 'UpdateDPA', 'Request from SAP for DPA/ALN Updation', 
                                      'Request from SAP : \n\n'+strReq+'Response sent to SAP : \n\n '+jsGen.getAsString(),
                                      'core_cpq_dpa_aln__c', 'High','Inbound Message',dpaId,dpaType,dpaNo);
    }
    
    
    public class CreateSAPRequestWrapper {
        public ListOfDpaInterfaceAltera ListOfDpaInterfaceAltera;
    }
    public class ListOfDpaInterfaceAltera {
        public DpaInterfaceAltera DpaInterfaceAltera;
    }
    public class DpaInterfaceAltera {
        public String SAPDPANo;
        public String SAPDPAStatus;
        public String DPANo;
        public String SyncComments;
        public String Type;
    }
}*/
@isTest
public class PSG_CreateDPAResponse{

}