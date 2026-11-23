/****************************************************************************************************
Apex Class Name : PSG_Integration_DPA
Version         : 1.0 
Created Date    : 01/06/2021
Function        : Class is used to submit DPA/ALN record to SAP.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari                  01/06/2021                 Created
*****************************************************************************************************/
@isTest
public without sharing class PSG_Integration_DPA{
    /*
    public static String COMMENTS_MESSAGE='..... Please refer to Salesforce for full comments';
    /************************************************************************************************************
    *Method Name : sendRequestToSAP
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Submits SAP request.
    ************************************************************************************************************/
    /*@AuraEnabled
    public static PSG_Integration_DPA.LightningResponse sendRequestToSAP(Id dpaId,String action){
        PSG_Integration_DPA.LightningResponse lr=new PSG_Integration_DPA.LightningResponse();
        lr.isSuccess=true;
        try{
            core_cpq_dpa_aln__c dpaObj=getDpaRecord(dpaId);
            List<core_cpq_dpa_aln_line__c> dpalines;
            Integer i=1;
            if(action == 'modify'){
                dpalines = getModifyDpaLines(dpaId);
            }else{
                dpalines = getDpaLines(dpaId);
                if(dpaObj.core_cpq_change_flag__c=='N' || dpaObj.core_cpq_change_flag__c == 'R'){
                    for(core_cpq_dpa_aln_line__c line : dpalines ){
                        line.core_cpq_line_no_to_sap__c=i;
                        i++;
                    }
                }
            }
            List<core_cpq_dpa_aln_line__c> dpalinesDuplicateList = getDupDpaLines(dpaId,dpaObj);
            Boolean checkValidation=true;
            if((dpaObj.core_cpq_change_flag__c!='H' && !(dpaObj.core_cpq_change_flag__c == 'E' && dpaObj.core_cpq_ship_end_date_dt__c== System.today())) && !dpaObj.core_cpq_active_quote__r.core_cpq_active_cb__c){
                lr.isSuccess=false;
                lr.message='Related Quote '+dpaObj.core_cpq_active_quote__r.Name+' is Inactive. Review the Quote state to proceed further.';
                checkValidation=false;
            }
            if((dpaObj.core_cpq_change_flag__c=='H' || dpaObj.core_cpq_change_flag__c=='M' || (dpaObj.core_cpq_change_flag__c == 'E' && dpaObj.core_cpq_ship_end_date_dt__c<= System.today())) && checkValidation){
                checkValidation=false;
            }
            if(checkValidation){
                lr=validateDpaRec(dpaId,action);
            }
            if(!lr.isSuccess){
                return lr;
            }else{
                if(dpaObj.core_cpq_record_type_identifier__c == 'ALN' && dpaObj.core_cpq_change_flag__c == 'N'){
                    dpaObj.core_cpq_ship_start_date_dt__c=System.today();
                }
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Apigee_Create_DPA_ALN');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                String payLoad=createJSON(dpaObj,dpalines);
                req.setBody(payLoad);
                if(dpaObj.core_cpq_record_type_identifier__c == 'ALN'){ 
                	Http http = new Http();
                	HTTPResponse res = http.send(req);
                System.debug('SAP Response Code==>'+res.getStatusCode());
                System.debug('SAP Response==>'+res.getBody());
                if(res.getStatusCode() == Integer.ValueOf(System.Label.PSG_DPAALNSuccessCode)){
                    if(dpaObj.core_cpq_record_type_identifier__c == 'DPA'){
                        lr.message='DPA Request has been submitted to SAP CHM for processing.';
                    }else if(dpaObj.core_cpq_record_type_identifier__c == 'ALN'){
                        lr.message='ALN Request has been submitted to SAP ECC for processing.';
                    }
                    core_cpq_psg_log_entry__c le=new core_cpq_psg_log_entry__c();
                    le.core_cpq_class_name__c='PSG_Integration_DPA';
                    le.core_cpq_method_name__c='sendRequestToSAP';
                    le.core_cpq_severity__c= 'Low';
                    le.core_cpq_sobjectname__c='core_cpq_dpa_aln__c';
                    le.core_cpq_message__c=lr.message;
                    String details='Payload sent to SAP : \n\n'+payLoad+' \n\n Response from SAP server : \n\n'+res.getBody();
                    le.core_cpq_details__c=details.length() >= 131070 ? details.substring(0,131070) : details;
                    le.core_cpq_when__c=System.now();
                    le.core_cpq_type__c='Outbound Message';
                    le.core_cpq_sObjectType__c=dpaObj.core_cpq_record_type_identifier__c;
                    le.core_cpq_sObjectRecord__c=dpaObj.Name;
                    le.core_cpq_sobjectid__c=dpaObj.Id;
                    if(action!='FutureCall'){
                        if(dpaObj.core_cpq_change_flag__c=='E' && dpaObj.core_cpq_ship_end_date_dt__c > System.today()){
                            dpaObj.core_cpq_status_change_reason__c = 'Extended through UI';
                        }else if(dpaObj.core_cpq_change_flag__c=='E' && dpaObj.core_cpq_ship_end_date_dt__c <= System.today()){
                            dpaObj.core_cpq_status_change_reason__c = 'Expired through UI';
                        }
                        dpaObj.core_cpq_status_txt__c='Submitted';
                        dpaObj.core_cpq_sap_status_txt__c='';
                        dpaObj.core_cpq_sync_comments_txt__c='';
                        update dpaObj;
                        if(dpaObj.core_cpq_change_flag__c=='N' || dpaObj.core_cpq_change_flag__c == 'R'){
                            update dpalines;
                        }
                        insert le;
                    }else{
                        lr.message=le.core_cpq_details__c;
                    }
                    
                }
            }
                else{
                    core_cpq_psg_log_entry__c le=new core_cpq_psg_log_entry__c();
                    le.core_cpq_class_name__c='PSG_Integration_DPA';
                    le.core_cpq_method_name__c='sendRequestToSAP';
                    le.core_cpq_severity__c= 'Low';
                    le.core_cpq_sobjectname__c='core_cpq_dpa_aln__c';
                    String dpaNumber = dpaObj.Name;
                    le.core_cpq_message__c='DPA record no '+ dpaNumber +' was submitted but not send to SAP';
                    le.core_cpq_when__c=System.now();
                    le.core_cpq_type__c='Outbound Message';
                    le.core_cpq_sObjectType__c=dpaObj.core_cpq_record_type_identifier__c;
                    le.core_cpq_sObjectRecord__c=dpaObj.Name;
                    le.core_cpq_sobjectid__c=dpaObj.Id;
                    insert le;
                    lr.isSuccess=false;
                    if(dpaObj.core_cpq_record_type_identifier__c == 'DPA'){
                        lr.message='DPA Request failed to submit to SAP CHM.';
                    }else if(dpaObj.core_cpq_record_type_identifier__c == 'ALN'){
                        lr.message='ALN Request failed to submit to SAP ECC.';
                    }
                }                
                return lr;
            }
        }catch(Exception e){
            lr.isSuccess=false;
            lr.message=e.getMessage();
            if(action!='FutureCall'){
                PSG_Utility.logError(e);
            }
            return lr;
        }
    }
    
    /************************************************************************************************************
    *Method Name : changeBeforeSendToSap
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Updates change flag before submitting to SAP.
    ************************************************************************************************************/
    /*@AuraEnabled
    public static void  changeBeforeSendToSap(Id dpaId,String action){
        List<core_cpq_dpa_aln__c>dpaObj=[SELECT Id,core_cpq_change_flag__c from core_cpq_dpa_aln__c WHERE Id=:dpaId]; 
        try{
            if(action =='hold'){
                dpaObj[0].core_cpq_change_flag__c = 'H';
                dpaObj[0].core_cpq_status_change_reason__c = 'Put on HOLD through UI';
                if(!dpaObj.isEmpty()){
                    update dpaObj;
                }   
            }
        }catch(Exception e){
            PSG_Utility.logError(e);
        }               
    }
    
    /************************************************************************************************************
    *Method Name : modifyLineBeforeSendToSap
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Updates lines before submitting to SAP.
    ************************************************************************************************************/
    /*@AuraEnabled
    public static void  modifyLineBeforeSendToSap(Id dpaId,String action){
        List<core_cpq_dpa_aln__c>dpaObj=[SELECT Id,core_cpq_change_flag__c from core_cpq_dpa_aln__c WHERE Id=:dpaId];
        try{
            if(action =='modify'){
                dpaObj[0]. core_cpq_change_flag__c = 'M';
                dpaObj[0].core_cpq_status_change_reason__c = 'Lines modified through UI';
                if(!dpaObj.isEmpty()){
                    update dpaObj;
                }   
            }
        }catch(Exception e){
            PSG_Utility.logError(e);
        }               
    }    
    
    /************************************************************************************************************
    *Method Name : createJSON
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Creates JSON to submit to SAP.
    ************************************************************************************************************/
    /*public static String createJSON(core_cpq_dpa_aln__c dpaObj,List<core_cpq_dpa_aln_line__c> dpalines){
        Boolean sendSibel = false;
        Boolean isALN = false;
        if(dpaObj.core_cpq_siebel_cis_no_txt__c != null){
            sendSibel = true;
        }
        if(dpaObj.core_cpq_record_type_identifier__c == 'ALN'){
            isALN = true;
        }
        Map<String,FieldDetail> dpaMapping=getDpaMapping(sendSibel,isALN);
        Map<String,FieldDetail> dpaLineMapping=getDpaLineMapping();
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeFieldName('DpaInterfaceAltera');
        jsGen.writeStartObject();
        for(String f:dpaMapping.keySet()){
            if(dpaMapping.get(f).fieldType != 'Reference' && dpaMapping.get(f).fieldApiName == ''){
                jsGen.writeStringField(f,'');
            }else{
                Object fieldValue;
                if(dpaMapping.get(f).fieldType == 'Reference'){
                    if(dpaMapping.get(f).fieldApiName.contains('|')){
                        List<String> fieldAPINames=dpaMapping.get(f).fieldApiName.split('\\|');
                        if(dpaObj.getSobject(fieldAPINames[0].split('\\.')[0])!=null && dpaObj.getSobject(fieldAPINames[0].split('\\.')[0]).get(fieldAPINames[0].split('\\.')[1]) != null){
                            fieldValue=dpaObj.getSobject(fieldAPINames[0].split('\\.')[0]).get(fieldAPINames[0].split('\\.')[1]);
                        }else if(dpaObj.getSobject(fieldAPINames[1].split('\\.')[0]) != null){
                            fieldValue=dpaObj.getSobject(fieldAPINames[1].split('\\.')[0]).get(fieldAPINames[1].split('\\.')[1]);
                        }
                    }else{
                        fieldValue=dpaObj.getSobject(dpaMapping.get(f).fieldApiName.split('\\.')[0])==null?null:dpaObj.getSobject(dpaMapping.get(f).fieldApiName.split('\\.')[0]).get(dpaMapping.get(f).fieldApiName.split('\\.')[1]);
                    }
                }else{
                    fieldValue=dpaObj.get(dpaMapping.get(f).fieldApiName);
                }
                if(dpaMapping.get(f).fieldType=='Text'){
               
String fValue = fieldValue == null ? '' : (String) fieldValue;
                    Integer maxLength=dpaMapping.get(f).maxLength==null?0:dpaMapping.get(f).maxLength;
                    String message=dpaMapping.get(f).message==null?'':dpaMapping.get(f).message;
                    if(maxLength!=0 && fValue.length()>maxLength){
                        jsGen.writeStringField(f, fValue.substring(0, maxLength)+message);
                    }else{
                        jsGen.writeStringField(f,fValue);
                    }                    
                }else if(dpaMapping.get(f).fieldType=='Reference'){
                    jsGen.writeStringField(f,fieldValue==null?'':(String)fieldValue);
                }else if(dpaMapping.get(f).fieldType=='Number'){
                    jsGen.writeStringField(f,fieldValue==null?'':String.valueOf(fieldValue));
                }else if(dpaMapping.get(f).fieldType=='Date'){
                    Date d=(Date)fieldValue;
                    jsGen.writeStringField(f,d==null?'':d.month()+'/'+d.day()+'/'+d.year()+' 00:00:00.000');
                }
            }
        }
        jsGen.writeFieldName('ListOfDpaLineItemsInterfaceAltera');
        jsGen.writeStartObject();
        jsGen.writeFieldName('DpaLineItemsInterfaceAltera');
        jsGen.writeStartArray();
        if(!dpalines.isEmpty()){
            for(core_cpq_dpa_aln_line__c dpaLine:dpalines){
                jsGen.writeStartObject();
                for(String f:dpaLineMapping.keySet()){
                    if(dpaLineMapping.get(f).fieldType != 'Reference' && dpaLineMapping.get(f).fieldApiName == ''){
                        jsGen.writeStringField(f,'');
                    }else{
                        Object fieldValue;
                        if(dpaLineMapping.get(f).fieldType == 'Reference'){
                            if(dpaLineMapping.get(f).fieldApiName.contains('|')){
                                List<String> fieldAPINames=dpaLineMapping.get(f).fieldApiName.split('\\|');
                                if(dpaLine.getSobject(fieldAPINames[0].split('\\.')[0])!=null && dpaLine.getSobject(fieldAPINames[0].split('\\.')[0]).get(fieldAPINames[0].split('\\.')[1]) != null){
                                    fieldValue=dpaLine.getSobject(fieldAPINames[0].split('\\.')[0]).get(fieldAPINames[0].split('\\.')[1]);
                                }else if(dpaLine.getSobject(fieldAPINames[1].split('\\.')[0]) != null){
                                    fieldValue=dpaLine.getSobject(fieldAPINames[1].split('\\.')[0]).get(fieldAPINames[1].split('\\.')[1]);
                                }
                            }else{
                                fieldValue=dpaLine.getSobject(dpaLineMapping.get(f).fieldApiName.split('\\.')[0])==null?null:dpaLine.getSobject(dpaLineMapping.get(f).fieldApiName.split('\\.')[0]).get(dpaLineMapping.get(f).fieldApiName.split('\\.')[1]);
                            }
                        }else{
                            fieldValue=dpaLine.get(dpaLineMapping.get(f).fieldApiName);
                        }
                        if(dpaLineMapping.get(f).fieldType=='Text'){
                            jsGen.writeStringField(f,fieldValue==null?'':(String)fieldValue);
                        }else if(dpaLineMapping.get(f).fieldType=='Reference'){
                            jsGen.writeStringField(f,fieldValue==null?'':(String)fieldValue);
                        }else if(dpaLineMapping.get(f).fieldType=='Number'){
                            jsGen.writeStringField(f,fieldValue==null?'':String.valueOf(fieldValue));
                        }
                    }              
                }
                jsGen.writeEndObject();
            }
        }
        jsGen.writeEndArray();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.close();
        return jsGen.getAsString();         
    }
    
    /************************************************************************************************************
    *Method Name : getDpaMapping
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : mapping for DPA/ALN.
    ************************************************************************************************************/
    /*public static Map<String,FieldDetail> getDpaMapping(Boolean sendSeible,Boolean isALN){
        Map<String,FieldDetail> dpaMapping=new Map<String,FieldDetail>();
        dpaMapping.put('ApprovalDt',new FieldDetail('core_cpq_quote_approved_dt__c','Date'));
        dpaMapping.put('ApprovedBy',new FieldDetail('core_cpq_aln_approver__c','Text'));
        dpaMapping.put('SAPDPANo',new FieldDetail('core_cpq_dpa_aln_no_nbr__c','Text'));
        dpaMapping.put('SAPDPAStatus',new FieldDetail('core_cpq_sap_status_txt__c','Text'));
        dpaMapping.put('CMCode',new FieldDetail('core_cpq_cm_code__c','Text'));
        dpaMapping.put('HeaderComments',new FieldDetail('core_cpq_comments_txt__c','Text',400,COMMENTS_MESSAGE));
        dpaMapping.put('CreatedDt',new FieldDetail('core_cpq_created_date_txt__c','Date'));
        if(sendSeible){
            dpaMapping.put('DPANo',new FieldDetail('core_cpq_siebel_cis_no_txt__c','Text'));
        }else{
            dpaMapping.put('DPANo',new FieldDetail('Name','Text'));            
        }
        
        dpaMapping.put('DPAException',new FieldDetail('',''));
        dpaMapping.put('DistyCustNo',new FieldDetail('core_cpq_sap_distributor_code__c','Number'));
        dpaMapping.put('EndCustCode',new FieldDetail('core_cpq_sap_end_customer_code__c','Text'));
        dpaMapping.put('MarketBusinessGroup',new FieldDetail('',''));
        dpaMapping.put('MarketEndProductName',new FieldDetail('',''));
        dpaMapping.put('MarketSegmentName',new FieldDetail('',''));
        dpaMapping.put('MarketSubSegmentName',new FieldDetail('',''));
        dpaMapping.put('MarketVerticalSegmentName',new FieldDetail('',''));
        dpaMapping.put('QuoteNo',new FieldDetail('core_cpq_active_quote__r.core_cpq_siebel_quote_no_txt__c|core_cpq_active_quote__r.Name','Reference'));
        dpaMapping.put('RFQ_Number',new FieldDetail('',''));
        dpaMapping.put('RepContact',new FieldDetail('core_cpq_disty_submitted_user__r.Name','Reference'));
        dpaMapping.put('SalesLocation',new FieldDetail('core_cpq_disty_submitted_user__r.Country','Reference'));
        dpaMapping.put('SalesRepName',new FieldDetail('core_cpq_disty_submitted_user__r.CommunityNickName','Reference'));
        dpaMapping.put('ShipExpDt',new FieldDetail('core_cpq_ship_end_date_dt__c','Date'));
        dpaMapping.put('ShipStartDt',new FieldDetail('core_cpq_ship_start_date_dt__c','Date'));
        dpaMapping.put('SyncComments',new FieldDetail('core_cpq_sync_comments_txt__c','Text'));
        dpaMapping.put('Type',new FieldDetail('core_cpq_record_type_identifier__c','Text'));
        dpaMapping.put('PAT_Type',new FieldDetail('core_cpq_aln_type__c','Text'));
        dpaMapping.put('SubmitterEmail',new FieldDetail('core_cpq_disty_submitter_email__c','Text'));
        dpaMapping.put('PAT_Geo',new FieldDetail('',''));
        dpaMapping.put('ShipCustCode',new FieldDetail('core_cpq_fnal_ship_to_customer_code__c','Text'));
        dpaMapping.put('Quote_Revision',new FieldDetail('core_cpq_quote_revision_no__c','Number'));
        dpaMapping.put('BaanParent',new FieldDetail('core_cpq_sap_end_customer_code__c','Text'));
        dpaMapping.put('ExchangeRate',new FieldDetail('',''));
        dpaMapping.put('ReplaceALN',new FieldDetail('core_cpq_replace_aln_txt__c','Text'));
        dpaMapping.put('QuoteCurrency',new FieldDetail('',''));
        dpaMapping.put('ChangeFlag',new FieldDetail('core_cpq_change_flag__c','Text'));
        dpaMapping.put('SAPCMCountry',new FieldDetail('core_cpq_cm_country_txt__c','Text'));
        if(isALN){
            dpaMapping.put('SAPCMCountry',new FieldDetail('core_cpq_final_ship_to_country_pl__c','Text'));
        }else{
            dpaMapping.put('SAPCMCountry',new FieldDetail('core_cpq_cm_country_txt__c','Text'));
        }
        return dpaMapping;
    }
    
    /************************************************************************************************************
    *Method Name : getDpaLineMapping
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Mapping for DPA/ALN Line.
    ************************************************************************************************************/
    /*public static Map<String,FieldDetail> getDpaLineMapping(){
        Map<String,FieldDetail> dpaLineMapping=new Map<String,FieldDetail>();
        dpaLineMapping.put('ApprovedQty',new FieldDetail('core_cpq_approved_qty_nbr__c','Number'));
        dpaLineMapping.put('UpperBoundQty',new FieldDetail('core_cpq_upper_bound_qty_nbr__c','Number'));
        dpaLineMapping.put('BrokenCost',new FieldDetail('price_broken_cost_disty_amt__c','Number'));
        dpaLineMapping.put('LineComments',new FieldDetail('',''));
        dpaLineMapping.put('DPANo',new FieldDetail('Name','Text'));
        dpaLineMapping.put('DistyValueAdded',new FieldDetail('price_disty_value_added_amt__c','Number'));
        dpaLineMapping.put('LineNumber',new FieldDetail('core_cpq_line_no_to_sap__c','Number'));
        dpaLineMapping.put('ProductName',new FieldDetail('core_cpq_device_nm__r.Core_OPN__c','Reference'));
        dpaLineMapping.put('ClaimedQty',new FieldDetail('core_cpq_claimed_qty_nbr__c','Number'));
        dpaLineMapping.put('WebRegistrationNo',new FieldDetail('',''));
        dpaLineMapping.put('PATLineId',new FieldDetail('',''));
        dpaLineMapping.put('MarginProgram',new FieldDetail('core_cpq_margin_program__c','Text'));
        dpaLineMapping.put('SuggestedPrice',new FieldDetail('core_cpq_resale_amt__c','Number'));
        dpaLineMapping.put('ClaimedAmount',new FieldDetail('',''));
        dpaLineMapping.put('PriceRowId',new FieldDetail('core_cpq_prid__r.core_cpq_src_sys_id__c|core_cpq_prid__r.Name','Reference'));
        dpaLineMapping.put('BookPrice',new FieldDetail('',''));
        dpaLineMapping.put('ResaleUSD',new FieldDetail('core_cpq_resale_amt__c','Number'));
        dpaLineMapping.put('ResaleYEN',new FieldDetail('',''));
        dpaLineMapping.put('DistyMargin',new FieldDetail('core_cpq_disty_margin_pct__c','Number'));
        return dpaLineMapping;
    }
    
    /************************************************************************************************************
    *Method Name : getDpaRecord
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Retrieves all the dpa information.
    ************************************************************************************************************/
    /*public static core_cpq_dpa_aln__c getDpaRecord(Id dpaId){
        return [SELECT Id,core_cpq_quote_approved_dt__c,core_cpq_status_txt__c,core_cpq_quote_revision_no__c,core_cpq_aln_approver__c,core_cpq_sap_status_txt__c,createddate,
                core_cpq_comments_txt__c,Name,core_cpq_active_quote__c,core_cpq_ship_end_date_dt__c,core_cpq_ship_start_date_dt__c,
                core_cpq_sync_comments_txt__c,core_cpq_aln_type__c,core_cpq_disty_submitter_email__c,core_cpq_fnal_ship_to_customer_code__c,core_cpq_final_ship_to_country_pl__c,
                core_cpq_replace_aln_txt__c,core_cpq_sap_distributor_code__c,core_cpq_cm_country_txt__c,core_cpq_record_type_identifier__c,
                core_cpq_cm_code__c,RecordType.DeveloperName,core_cpq_active_quote__r.Name,core_cpq_created_date_txt__c,core_cpq_end_customer_parent_code__c,core_cpq_active_quote__r.core_cpq_active_cb__c,
                core_cpq_duration_nbr__c,core_cpq_sap_end_customer_nm__c,core_cpq_change_flag__c,core_cpq_sap_end_customer_code__c,
                core_cpq_disty_submitted_user__r.Name,core_cpq_disty_submitted_user__r.Country,core_cpq_disty_submitted_user__r.CommunityNickName,core_cpq_siebel_cis_no_txt__c,
                core_cpq_sap_distributor_nm__c,core_cpq_dpa_aln_no_nbr__c,core_cpq_active_quote__r.core_cpq_siebel_quote_no_txt__c from core_cpq_dpa_aln__c WHERE Id=:dpaId];
    }
    
    /************************************************************************************************************
    *Method Name : getDpaLines
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : returns all the lines related to DPA/ALN.
    ************************************************************************************************************/
    /*public static List<core_cpq_dpa_aln_line__c> getDpaLines(Id dpaId){
        return [SELECT Id,core_cpq_approved_qty_nbr__c,core_cpq_upper_bound_qty_nbr__c,Name,price_disty_value_added_amt__c,core_cpq_line_no_to_sap__c,
                core_cpq_line_no_nbr__c,core_cpq_device_nm__c,core_cpq_claimed_qty_nbr__c,core_cpq_margin_program__c,core_cpq_resale_amt__c,
                core_cpq_prid__c,price_broken_cost_disty_amt__c,core_cpq_disty_margin_pct__c,core_cpq_prid__r.Name,core_cpq_device_nm__r.Core_OPN__c,
                core_cpq_dollar_change_flag__c,core_cpq_quote_item_line_no__r.core_cpq_active_Pricing__c,
                core_cpq_prid__r.core_cpq_active_cb__c,core_cpq_quote_item_line_no__r.core_cpq_quote_line_type_txt__c,
                core_cpq_quote_item_line_no__r.price_suggested_resale_amt__c,core_cpq_prid__r.price_amt__c,
                core_cpq_quote_item_line_no__r.core_cpq_dollar_change_flag_cb__c,core_cpq_prid__r.core_cpq_src_sys_id__c,price_disty_cost_amt__c from  core_cpq_dpa_aln_line__c WHERE core_cpq_cis_no_nbr__c=:dpaId];
        
    }
    
    /************************************************************************************************************
    *Method Name : getModifyDpaLines
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : returns modified dpa/aln line records.
    ************************************************************************************************************/
    /*public static List<core_cpq_dpa_aln_line__c> getModifyDpaLines(Id dpaId){
        return [SELECT Id,core_cpq_approved_qty_nbr__c,core_cpq_upper_bound_qty_nbr__c,Name,price_disty_value_added_amt__c,core_cpq_line_no_to_sap__c,
                core_cpq_line_no_nbr__c,core_cpq_device_nm__c,core_cpq_claimed_qty_nbr__c,core_cpq_margin_program__c,core_cpq_resale_amt__c,
                core_cpq_prid__c,price_broken_cost_disty_amt__c,core_cpq_disty_margin_pct__c,core_cpq_prid__r.Name,core_cpq_device_nm__r.Core_OPN__c,
                core_cpq_dollar_change_flag__c,core_cpq_quote_item_line_no__r.core_cpq_active_Pricing__c,
                core_cpq_prid__r.core_cpq_active_cb__c,core_cpq_quote_item_line_no__r.core_cpq_quote_line_type_txt__c,core_cpq_prid__r.price_amt__c,core_cpq_quote_item_line_no__r.price_suggested_resale_amt__c,
                core_cpq_quote_item_line_no__r.core_cpq_dollar_change_flag_cb__c,core_cpq_prid__r.core_cpq_src_sys_id__c,price_disty_cost_amt__c from  core_cpq_dpa_aln_line__c WHERE core_cpq_cis_no_nbr__c=:dpaId AND core_cpq_isModified__c=true];
    }
    
    /************************************************************************************************************
    *Method Name : getDupDpaLines
    *Created Date: 08/13/2021
    *Author: Shreyash
    *Description : Returns all the duplicate dpa/aln line records.
    ************************************************************************************************************/
    /*public static List<core_cpq_dpa_aln_line__c> getDupDpaLines(Id dpaId,core_cpq_dpa_aln__c dpaObj){
        return [SELECT Id,core_cpq_approved_qty_nbr__c,core_cpq_upper_bound_qty_nbr__c,Name,price_disty_value_added_amt__c,core_cpq_line_no_to_sap__c,
                core_cpq_line_no_nbr__c,core_cpq_device_nm__c,core_cpq_claimed_qty_nbr__c,core_cpq_margin_program__c,core_cpq_resale_amt__c,
                core_cpq_prid__c,price_broken_cost_disty_amt__c,core_cpq_disty_margin_pct__c,core_cpq_prid__r.Name,core_cpq_device_nm__r.Core_OPN__c,core_cpq_cis_no_nbr__r.Name,core_cpq_prid__r.core_cpq_src_sys_id__c,price_disty_cost_amt__c from  core_cpq_dpa_aln_line__c 
                WHERE core_cpq_cis_no_nbr__c != :dpaId and core_cpq_cis_no_nbr__r.core_cpq_sap_end_customer_nm__c = :dpaObj.core_cpq_sap_end_customer_nm__c
                and core_cpq_cis_no_nbr__r.core_cpq_sap_distributor_nm__c = :dpaObj.core_cpq_sap_distributor_nm__c and core_cpq_cis_no_nbr__r.core_cpq_active_quote__c = :dpaObj.core_cpq_active_quote__c
                and core_cpq_cis_no_nbr__r.core_cpq_record_type_identifier__c = :dpaObj.core_cpq_record_type_identifier__c and core_cpq_cis_no_nbr__r.core_cpq_status_txt__c = 'Submitted'];
        
    }
    
    /************************************************************************************************************
	*Method Name : validateDpaRec
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Performs all the required validations before submitting to SAP.
    ************************************************************************************************************/
    /*@AuraEnabled
    public static PSG_Integration_DPA.LightningResponse validateDpaRec(Id dpaId,String action){
        PSG_Integration_DPA.LightningResponse lr=new PSG_Integration_DPA.LightningResponse();
        core_cpq_dpa_aln__c dpaObj=getDpaRecord(dpaId);
        List<core_cpq_dpa_aln_line__c> dpalines;
        List<core_cpq_dpa_aln_line__c> dpalinesDuplicateList = getDupDpaLines(dpaObj.Id,dpaObj);
        lr.isSuccess=true;
        lr.message='';
        if(action == 'modify'){
            dpalines = getModifyDpaLines(dpaObj.Id);
        }
        else{
            dpalines = getDpaLines(dpaObj.Id);
        }
        
        Set<String> errorMsgSet = new Set<String>();
        if(action=='Extend'){
            if(!dpaObj.core_cpq_active_quote__r.core_cpq_active_cb__c){
                lr.isSuccess=false;
                errorMsgSet.add('Related Quote '+dpaObj.core_cpq_active_quote__r.Name+' is Inactive. Review the Quote state to proceed further.');
            }
        }
        if(dpaObj.core_cpq_change_flag__c=='R' && action != 'Expire' && action != 'Extend' && action != 'hold' && action !='modify'){
            List<core_cpq_dpa_aln__c> parentALN= [Select Id,core_cpq_status_txt__c from core_cpq_dpa_aln__c Where core_cpq_status_txt__c='Hold' and core_cpq_dpa_aln_no_nbr__c=:dpaObj.core_cpq_replace_aln_txt__c and core_cpq_record_type_identifier__c = 'ALN'];
            if(parentALN.isEmpty()){
                lr.isSuccess=false;   
                errorMsgSet.add('Only ALN in Hold state can be replaced.');
            }
        }
        if(dpaObj.core_cpq_ship_start_date_dt__c == null || dpaObj.core_cpq_ship_end_date_dt__c == null|| dpaObj.core_cpq_duration_nbr__c == null || dpaObj.core_cpq_sap_end_customer_nm__c == null || dpaObj.core_cpq_sap_distributor_nm__c == null || (dpaObj.core_cpq_record_type_identifier__c == 'ALN' && dpaObj.core_cpq_aln_type__c == null)){
            lr.isSuccess=false;
            errorMsgSet.add('Please fill all the mandatory fields in '+dpaObj.core_cpq_record_type_identifier__c+' Ship Start Date/Ship End Date/SAP Distributor/SAP End Customer/Duration/ALN Type(for ALN)');
        }/*else if(dpaObj.core_cpq_ship_start_date_dt__c < system.today() && dpaObj.core_cpq_change_flag__c == 'N'  &&  dpaObj.core_cpq_status_txt__c!='Approved'){
			lr.isSuccess=false;   
			errorMsgSet.add('Ship Start Date cannot be lesser than today');
		}*/
        /*if(dpaObj.core_cpq_record_type_identifier__c=='ALN' && dpalines.size()>1){
            lr.isSuccess=false;
            errorMsgSet.add('Only one line from a Quote shall be used to request for ALN');
        }
        if(action =='modify' && dpalines.isEmpty()){
            lr.isSuccess=false;
            errorMsgSet.add('No Change Detected in DPA/ALN Lines');
        }
        if(!dpalines.isEmpty()){
            for(core_cpq_dpa_aln_line__c dpaLine:dpalines){
                if(!dpalinesDuplicateList.isEmpty() && action != 'Expire' && action != 'Extend' && action != 'hold' && action !='modify'){
                    for(core_cpq_dpa_aln_line__c dpaLineDuplicate:dpalinesDuplicateList){
                        if(dpaObj.core_cpq_record_type_identifier__c == 'DPA' && dpaLine.core_cpq_device_nm__c == dpaLineDuplicate.core_cpq_device_nm__c && dpaLine.core_cpq_prid__c == dpaLineDuplicate.core_cpq_prid__c && dpaLine.price_disty_value_added_amt__c == dpaLineDuplicate.price_disty_value_added_amt__c ){
                            errorMsgSet.add('DPA request <'+dpaLineDuplicate.core_cpq_cis_no_nbr__r.Name+'> for the same Disty Exists');
                            lr.isSuccess=false;
                            break;
                        }
                        if(dpaObj.core_cpq_record_type_identifier__c == 'ALN' && dpaLine.core_cpq_device_nm__c == dpaLineDuplicate.core_cpq_device_nm__c && dpaLine.core_cpq_prid__c == dpaLineDuplicate.core_cpq_prid__c ){
                            errorMsgSet.add('ALN request <'+dpaLineDuplicate.core_cpq_cis_no_nbr__r.Name+'> for the same Disty Exists');
                            lr.isSuccess=false;
                            break;
                        }
                    }   
                }
                if(dpaLine.core_cpq_approved_qty_nbr__c == null || dpaLine.core_cpq_disty_margin_pct__c == null ){
                    errorMsgSet.add('Please fill all the mandatory fields in DPA ALN Line Approved Qty/Disty Margin %.');
                    lr.isSuccess=false;
                }
                if(dpaLine.core_cpq_quote_item_line_no__r?.core_cpq_dollar_change_flag_cb__c == true){
                    errorMsgSet.add(dpaObj.core_cpq_record_type_identifier__c+' can\'t be approved for the Quote Lines with $ Change Flag Set');
                    lr.isSuccess=false;
                }else if(dpaLine.core_cpq_prid__r != null && !dpaLine.core_cpq_prid__r.core_cpq_active_cb__c){
                    errorMsgSet.add(dpaObj.core_cpq_record_type_identifier__c+' can\'t be submitted to SAP as related PRID is Inactive');
                    lr.isSuccess=false;
                }
                if(dpaObj.core_cpq_record_type_identifier__c=='ALN' && dpaLine.core_cpq_quote_item_line_no__r?.core_cpq_quote_line_type_txt__c == 'Step' ){
                    errorMsgSet.add('ALN request is not allowed for Quotes with Step Pricing type');
                    lr.isSuccess=false;
                }
                if(dpaLine.core_cpq_quote_item_line_no__r?.core_cpq_quote_line_type_txt__c == 'AVP' && dpaLine.core_cpq_quote_item_line_no__r?.core_cpq_active_Pricing__c == false ){
                    errorMsgSet.add(dpaObj.core_cpq_record_type_identifier__c+' request can\'t be approved as the Quote Line with VTP hasn\'t been reviewed. Make sure the PRID is reviewed prior to '+dpaObj.core_cpq_record_type_identifier__c+' request');
                    lr.isSuccess=false;
                }
                // BC > DC Check
                Decimal distyCost=dpaLine.price_disty_cost_amt__c!=null?dpaLine.price_disty_cost_amt__c:0;
                if(dpaLine.price_broken_cost_disty_amt__c >= distyCost){
                    errorMsgSet.add(dpaObj.core_cpq_record_type_identifier__c+' request can\'t be Submitted to SAP as one of the line(s) has Broken Cost greater than Disty Cost');
                    lr.isSuccess=false;
                }
                // DPA/ALN SuggResale = PRIDSuggResale Check
                if(dpaObj.core_cpq_change_flag__c=='N' || dpaObj.core_cpq_change_flag__c=='R' || (dpaObj.core_cpq_change_flag__c=='E' && dpaObj.core_cpq_ship_end_date_dt__c > System.today())){
                    if((dpaLine.core_cpq_prid__c != null && dpaLine.core_cpq_prid__r.price_amt__c != dpaLine.core_cpq_resale_amt__c) || dpaLine.core_cpq_quote_item_line_no__r?.price_suggested_resale_amt__c != dpaLine.core_cpq_resale_amt__c){
                        errorMsgSet.add(dpaObj.core_cpq_record_type_identifier__c+' can\'t be submitted to SAP as of Suggested Resale mismatched between PRID/QL with CIS Line');
                        lr.isSuccess=false;
                    }
                }
            }
        }
        if(!lr.isSuccess && !errorMsgSet.isEmpty()){
            lr.message=String.join(new List<String>(errorMsgSet), ',');
        }
        return lr;
    }
    
    public static LightningResponse getALNOpenQty(List<string> alnList){
        LightningResponse lr=new LightningResponse();
        Map<String,Decimal> alnToOpenQtyMap=new Map<String,Decimal>(); 
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Apigee_ALN_Order_Qty');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            String payLoad='{ "FullDetails": "N", "ListOfALNs": { "ALN" : [';
            for(Integer i=0;i<alnList.size();i++){
                payLoad=payLoad + '"'+alnList[i]+'"';
                if(i<alnList.size()-1){
                   payLoad=payLoad+',';
                }
            }
            payLoad=payLoad+'] } }';
            req.setBody(payLoad);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() == Integer.valueOf(Label.PSG_ALN_SuccessCode)){
                Object o=JSON.deserializeUntyped(res.getBody());
                Map<String,Object> resMap=(Map<String,Object>)o;
                Map<String,Object> ListofALNs=(Map<String,Object>)resMap?.get('ListofALNs');
                List<Object> alnDetailList=new List<Object>();
                try{
                    alnDetailList=(List<Object>)ListofALNs?.get('ALNDetails');
                }catch(System.TypeException e){
                    alnDetailList.add((Object)ListofALNs?.get('ALNDetails'));
                }
                for(Object alnObj : alnDetailList){
                    Map<String,Object> alnMap=(Map<String,Object>)alnObj;
                    String alnNo=alnMap.get('ALN')!=null? String.valueOf(alnMap.get('ALN')):'';
                    Decimal alnOpenQty =Decimal.valueOf(String.valueOf((''+alnMap.get('OpenALNQty')).trim()));
                    alnToOpenQtyMap.put(alnNo,alnOpenQty);                    
                }
                lr.isSuccess=true;
                lr.openOrderQtyMap=alnToOpenQtyMap;
                String msg='Request Body : '+payLoad+'/n Response Body : '+res.getBody();
                PSG_Utility.createCoreLogEntry('PSG_Integration_DPA','getALNOpenQty','ALN open Order Qty fetch request',(msg.length()>131072?msg.substring(0,131050):msg)
                                          ,'core_cpq_dpa_aln__c','Info','');
            }else{
                PSG_Utility.createCoreLogEntry('PSG_Integration_DPA','getALNOpenQty','Failed ALN request while processing through PSG_Integration_DPA.getALNOpenQty',''+alnList+'/n '+res.getBody()
                                          ,'core_cpq_dpa_aln__c','High','');
                lr.isSuccess=false;
                lr.message='Error while fetching Open Order backlog from SAP ECC : '+res.getBody();
            }
        }catch(Exception e){
            lr.isSuccess=false;
            lr.message=e.getMessage();
            PSG_Utility.createCoreLogEntry('PSG_Integration_DPA','getALNOpenQty','Failed ALN request while processing through PSG_Integration_DPA.getALNOpenQty',''+alnList+'/n '+e
                                           ,'core_cpq_dpa_aln__c','High','');
        }  
        return lr;
    }
    
    public class FieldDetail{
        public String fieldApiName;
        public String fieldType;
        public Integer maxLength;
        public String message;
        public FieldDetail(String fieldApiName,String fieldType,Integer maxLength,String message){
            this.fieldApiName=fieldApiName;
            this.fieldType=fieldType;
            this.maxLength=maxLength;
            this.message=message;
        }
        public FieldDetail(String fieldApiName,String fieldType){
            this.fieldApiName=fieldApiName;
            this.fieldType=fieldType;
        }
    }
    
    public class LightningResponse{
        @AuraEnabled 
        public Boolean isSuccess;
        @AuraEnabled 
        public String message;
        @AuraEnabled
        public Map<String,Decimal> openOrderQtyMap;
    }*/ 
}