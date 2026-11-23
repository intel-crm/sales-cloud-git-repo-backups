/****************************************************************************************************
Apex Class Name : PSG_UpdateDPAClaim
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This class is used to update Claimed Quantity on DPA Line when request came from SAP. 
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
/*@RestResource(urlMapping='/v1/SyncDPAClaim/*')
global without sharing class PSG_UpdateDPAClaim {
   
    /************************************************************************************************************
    *Method Name : UpdateDPA
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Updates Claimed Quantity on DPA Line record matching with DPA No and Product Name.
    ************************************************************************************************************/
    /*@HttpPost
    global static void UpdateDPA() {
        List<core_cpq_dpa_aln_line__c> dpaLines=new List<core_cpq_dpa_aln_line__c>();
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        Boolean isSuccess=true;
        String strReq = req.requestBody.toString();
        JSONGenerator jsGen=JSON.createGenerator(true);
        jsGen.writeStartObject();
        try{
            Boolean isValid=true;
            Object o=JSON.deserializeUntyped(strReq);
            Map<String,Object> reqWrapper = (Map<String,Object>)o;
            Map<String,Object> DpaInterfaceAltera = (Map<String,Object>)reqWrapper?.get('DpaInterfaceAltera');
            Map<String,Object> ListOfDpaLineItemsInterfaceAltera = (Map<String,Object>)DpaInterfaceAltera?.get('ListOfDpaLineItemsInterfaceAltera');
            Object DpaLineItemsInterfaceAltera =ListOfDpaLineItemsInterfaceAltera?.get('DpaLineItemsInterfaceAltera');
            String dpaName=DpaInterfaceAltera?.get('DPANo')==null?null:String.valueOf(DpaInterfaceAltera?.get('DPANo'));
            //String QuoteNo=DpaInterfaceAltera?.get('QuoteNo')==null?null:String.valueOf(DpaInterfaceAltera?.get('QuoteNo'));
            Map<String,DpaLineItemsInterfaceAltera> lineMap=new Map<String,DpaLineItemsInterfaceAltera>();
            Set<String> prodOPNs=new Set<String>();
            List<DpaLineItemsInterfaceAltera> lineItems=new List<DpaLineItemsInterfaceAltera>();
            try{
                for(Object o1 : (List<Object>)DpaLineItemsInterfaceAltera){
                    lineItems.add(getWrapperType((Map<String,Object>)o1));
                }
            }Catch(System.TypeException e){
                lineItems.add(getWrapperType((Map<String,Object>)DpaLineItemsInterfaceAltera));
            }
            if(String.isBlank(dpaName)){
                isValid=false;
                jsGen.writeBooleanField('success', false);
                jsGen.writeStringField('message', 'Required field DPANo missing.');
            }
            /*if(isValid){
                String msg='';
                for(DpaLineItemsInterfaceAltera item : lineItems){                    
                    if(String.isBlank(item.ProductName) || String.isBlank(item.ClaimedQty)){
                        isValid=false;
                        if(msg!='')
                        	msg=msg+',';
                        msg=msg+' Line Number '+item.LineNumber+': Required parameters missing ProductName/ClaimedQty';
                    }
                }
                if(msg!=''){
                    jsGen.writeBooleanField('success', false);
                    jsGen.writeStringField('message', msg);
                }
            }*/
            /*if(isValid){
                for(DpaLineItemsInterfaceAltera item : lineItems){
                    if(!String.isBlank(item.ProductName) && !String.isBlank(item.ClaimedQty)){
                        prodOPNs.add(item.ProductName);
                        lineMap.put(item.ProductName+'_'+item.LineNumber,item);
                    }                    
                }
                dpaLines=[SELECT Id,Name,core_cpq_claimed_qty_nbr__c,core_cpq_record_type_identifier__c,core_cpq_device_nm__r.core_OPN__c,core_cpq_line_no_to_sap__c from core_cpq_dpa_aln_line__c where core_cpq_device_nm__r.core_OPN__c in :prodOPNs and (core_cpq_cis_no_nbr__r.core_cpq_cis__c=:dpaName or core_cpq_cis_no_nbr__r.core_cpq_siebel_cis_no_txt__c=:dpaName)];
                if(!dpaLines.isEmpty()){
                    for(core_cpq_dpa_aln_line__c line: dpaLines){
                        if(lineMap.containsKey(line.core_cpq_device_nm__r.core_OPN__c+'_'+line.core_cpq_line_no_to_sap__c))
                        	line.core_cpq_claimed_qty_nbr__c=Decimal.valueOf(lineMap.get(line.core_cpq_device_nm__r.core_OPN__c+'_'+line.core_cpq_line_no_to_sap__c)?.ClaimedQty);
                    }
                    update dpaLines;
                    jsGen.writeBooleanField('success', true);
                    jsGen.writeStringField('message', 'Updated claimed qty on lines Successfully.');
                }else{
                    isSuccess=false;
                    jsGen.writeBooleanField('success', false);
                    jsGen.writeStringField('message', 'No Lines found to update with provided details.');
                }
            }            
        }catch(Exception e){
            isSuccess=false;
            jsGen.writeBooleanField('success', false);
            jsGen.writeStringField('message', 'Line Number '+e.getLineNumber()+' : '+e.getMessage());
        }
        jsGen.writeEndObject();
        jsGen.close();
        res.responseBody = Blob.valueof(jsGen.getAsString());
        Id lineId=!dpaLines.isEmpty()?dpaLines[0].Id:null;
        String lineType=!dpaLines.isEmpty()?dpaLines[0].core_cpq_record_type_identifier__c:null;
        String lineName=!dpaLines.isEmpty()?dpaLines[0].Name:null;
        PSG_Utility.createPSGLogEntry('PSG_UpdateDPAClaim', 'UpdateDPA', 'Request from SAP for Claimed Qty Updation',
                                      'Request from SAP : \n\n'+strReq+'Response sent to SAP : \n\n '+jsGen.getAsString(),
                                      'core_cpq_dpa_aln_line__c', 'High','Inbound Message',lineId,lineType,lineName);
        
    }
    
    public static DpaLineItemsInterfaceAltera getWrapperType(Map<String,Object> objMap){
        DpaLineItemsInterfaceAltera dpaLineItem=new DpaLineItemsInterfaceAltera();
        dpaLineItem.ClaimedAmount=objMap?.get('ClaimedAmount')==null?null:String.valueOf(objMap?.get('ClaimedAmount'));
        dpaLineItem.ClaimedQty=objMap?.get('ClaimedQty')==null?null:String.valueOf(objMap?.get('ClaimedQty'));
        dpaLineItem.LineNumber=objMap?.get('LineNumber')==null?null:Integer.valueOf(objMap?.get('LineNumber'));
        dpaLineItem.ProductName=objMap?.get('ProductName')==null?null:String.valueOf(objMap?.get('ProductName'));
        return dpaLineItem;
    }
    
    public class DpaLineItemsInterfaceAltera {
        public Integer LineNumber;
        public String ProductName;
        public String ClaimedQty;
        public String ClaimedAmount;
    } 
}*/
@isTest
public class PSG_UpdateDPAClaim{

}