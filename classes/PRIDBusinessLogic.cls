/****************************************************************************************************
Apex Class Name : PRIDBusinessLogic
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This class is used for all the PSG PRID functionalities.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay                     08/13/2021                Created
*****************************************************************************************************/
public without sharing class  PRIDBusinessLogic{
    public static Map<String,Set<String>> revisionTriggerQLFieldMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> updationFieldQLMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> revisionFieldsQLMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> revisionFieldsQLToQLMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> revisionTriggerPridFieldMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> updationFieldPridMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> revisionFieldsPridMap = new Map<String,Set<String>>();
    public static Map<String,price_prid__c> ecpOpnWithPRID=new Map<String,price_prid__c>();
    public static set<string> ecpOpnSet=new set<string>();    
    public static Boolean triggeredOnQuoteApproval=false;
    public static Boolean isPRIDTriggered=false;
    static{
        for(PSG_PRID_Mapping__mdt pridRec :[SELECT Id,PSG_PRID_Type__c,psg_revision_trigger_field_prid__c,psg_revision_fields_for_ql_ql__c,psg_cpq_revision_trigger_field_ql__c,core_cpq_updation_trigger_field_prid__c,psg_updation_trigger_field_ql__c,psg_revision_fields_QL__c,psg_revision_fields_prid__c from PSG_PRID_Mapping__mdt where PSG_Active__c = true LIMIT :Limits.getLimitDMLRows()]){
            if(String.isNotBlank(pridRec.psg_cpq_revision_trigger_field_ql__c)){
                revisionTriggerQLFieldMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_cpq_revision_trigger_field_ql__c).split(':')));   
            }else{
                revisionTriggerQLFieldMap.put(pridRec.PSG_PRID_Type__c,new Set<String>()); 
            }
            if(String.isNotBlank(pridRec.psg_updation_trigger_field_ql__c)){
                updationFieldQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_updation_trigger_field_ql__c).split(':')));
            }else{
                updationFieldQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>());
            } 
            if(String.isNotBlank(pridRec.psg_revision_fields_QL__c)){
                revisionFieldsQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_revision_fields_QL__c).split(':')));
            }else{
                revisionFieldsQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>());
            } 
            if(String.isNotBlank(pridRec.psg_revision_fields_for_ql_ql__c)){
                revisionFieldsQLToQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_revision_fields_for_ql_ql__c).split(':')));
            }else{
                revisionFieldsQLToQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>());
            }
            if(String.isNotBlank(pridRec.psg_revision_trigger_field_prid__c)){
                revisionTriggerPridFieldMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_revision_trigger_field_prid__c).split(':'))); 
            }else{
                revisionTriggerPridFieldMap.put(pridRec.PSG_PRID_Type__c,new Set<String>()); 
            }  
            if(String.isNotBlank(pridRec.core_cpq_updation_trigger_field_prid__c)){
                updationFieldPridMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.core_cpq_updation_trigger_field_prid__c).split(':'))); 
            }else{
                updationFieldPridMap.put(pridRec.PSG_PRID_Type__c,new Set<String>()); 
            }  
            if(String.isNotBlank(pridRec.psg_revision_fields_prid__c)){
                revisionFieldsPridMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_revision_fields_prid__c).split(':'))); 
            }else{
                revisionFieldsPridMap.put(pridRec.PSG_PRID_Type__c,new Set<String>()); 
            } 
        }
    }
    
    /************************************************************************************************************
    *Method Name : beforeInsertUpdateOperations
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : method perform all the operation on before insert and update trigger call.
    ************************************************************************************************************/
    public static void beforeInsertUpdateOperations(List<price_prid__c> pridList,Map<Id,price_prid__c> oldMap,Boolean isInsert){
        Set<String> uniqueCombinationSet = new Set<String>();
        Set<String> existingCombinationSet = new Set<String>();
        Boolean isUpdate = !isInsert;
        if(isInsert){
            for(price_prid__c prid : pridList){
                String uniqueCombination = '';
                prid.core_cpq_active_pricing_cb__c = false;
		//Hari -> TWC3133-917 [PRID] Track PRID De-Activation
                prid.Inactivation_Reason__c='';
                if(prid.core_cpq_active_cb__c){
                    uniqueCombination = '';
                    String ecp = '';
                    String pro = '';
                    if(prid.core_cpq_sap_ecp_nm__c != null){
                        ecp = String.valueOf(prid.core_cpq_sap_ecp_nm__c).substring(0, 15);
                    }
                    if(prid.core_cpq_device__c != null){
                        pro = String.valueOf(prid.core_cpq_device__c).substring(0, 15);
                    }
                    if(prid.core_cpq_type__c  == Label.PSG_PRID_Type_Step || prid.core_cpq_type__c == Label.PSG_PRID_Type_AVP){
                        uniqueCombination = '' + ecp + pro + 
                            + prid.core_cpq_lower_bound_qty_nbr__c + prid.core_cpq_upper_bound_qty_nbr__c;
                    }else{
                        uniqueCombination = '' + ecp + pro;
                    }
                }
                if(prid.core_cpq_price_start_date_dt__c == null || prid.core_cpq_price_start_date_dt__c < System.today()){
                    prid.core_cpq_price_start_date_dt__c = System.today();
                }
                if(prid.core_cpq_price_end_date_dt__c == null){
                    prid.core_cpq_price_end_date_dt__c = Date.valueOf(Label.PSG_PRID_PriceEndDate);
                }
                if(prid.core_cpq_prid_validity_date_dt__c == null){                    
                    Date d=System.today().addMonths(Integer.valueOf(Label.PSG_PRID_Validity_Months));
                    Integer quarterEndMonth = ((d.month() - 1) / 3 + 1) * 3;
                    //prid.core_cpq_prid_validity_date_dt__c = currDate.addMonths(Integer.valueOf(Label.PSG_PRID_Validity_Months));
                    prid.core_cpq_prid_validity_date_dt__c=Date.newInstance(d.year(), quarterEndMonth, Date.daysInMonth(d.year(), quarterEndMonth));
                }
                prid.price_amt__c=prid.price_amt__c?.setScale(2);
            }
        }
        if(isUpdate){
            for(price_prid__c prid : pridList){
                String uniqueCombination = '';
                prid.price_amt__c=prid.price_amt__c?.setScale(2);
                if(prid.core_cpq_active_cb__c && (prid.core_cpq_active_cb__c != oldMap.get(prid.Id).core_cpq_active_cb__c)){
                    //Hari -> TWC3133-917 [PRID] Track PRID De-Activation
		    prid.Inactivation_Reason__c='';
                    uniqueCombination = '';
                    String ecp = '';
                    String pro = '';
                    if(prid.core_cpq_sap_ecp_nm__c != null){
                        ecp = String.valueOf(prid.core_cpq_sap_ecp_nm__c).substring(0, 15);
                    }
                    if(prid.core_cpq_device__c != null){
                        pro = String.valueOf(prid.core_cpq_device__c).substring(0, 15);
                    }
                    if(prid.core_cpq_type__c  == Label.PSG_PRID_Type_Step || prid.core_cpq_type__c == Label.PSG_PRID_Type_AVP){
                        uniqueCombination = '' + ecp + pro + 
                            + prid.core_cpq_lower_bound_qty_nbr__c + prid.core_cpq_upper_bound_qty_nbr__c;
                    }else{
                        uniqueCombination = '' + ecp + pro;
                    }
                }
                if(prid.core_cpq_active_pricing_cb__c != oldMap.get(prid.Id).core_cpq_active_pricing_cb__c){
                    if(prid.core_cpq_active_pricing_cb__c){
                        prid.core_cpq_price_start_date_dt__c = System.today();
                        prid.core_cpq_price_end_date_dt__c = Date.valueOf(Label.PSG_PRID_PriceEndDate);
                    }else{
                        prid.core_cpq_price_end_date_dt__c = System.today() - 1;
                    }
                }
                if(prid.core_cpq_type__c=='AVP' && prid.core_cpq_active_pricing_cb__c==TRUE && prid.core_cpq_active_cb__c==TRUE && (prid.core_cpq_active_cb__c != oldMap.get(prid.Id).core_cpq_active_cb__c || prid.core_cpq_active_pricing_cb__c != oldMap.get(prid.Id).core_cpq_active_pricing_cb__c)){
                    ecpOpnSet.add(prid.core_cpq_ecp_opn_number__c);        
                }                
            }
            if(!ecpOpnSet.isEmpty()){
                for(price_prid__c existingPrid: [select Id, name, core_cpq_ecp_opn_number__c,core_cpq_active_cb__c, core_cpq_active_pricing_cb__c from price_prid__c where
                                                 core_cpq_ecp_opn_number__c=:ecpOpnSet LIMIT :Limits.getLimitDMLRows()]){
                                                     if(existingPrid.core_cpq_active_pricing_cb__c==TRUE && existingPrid.core_cpq_active_cb__c==TRUE){
                                                     ecpOpnWithPRID.put(existingPrid.core_cpq_ecp_opn_number__c,existingPrid);
                                                 }
                                              }
            }
            if(!ecpOpnWithPRID.isEmpty()){                
                for(price_prid__c prid:pridList){
                    if(ecpOpnWithPRID.containsKey(prid.core_cpq_ecp_opn_number__c)){
                        prid.addError('There can be only one Active Pricing for ECP/OPN combination for an active PRID');
                    }
                }
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : afterInsertUpdateOperations
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : method perform all the operation on after insert and update trigger call.
    ************************************************************************************************************/
    public static void afterInsertUpdateOperations(List<price_prid__c> pridList,Map<Id,price_prid__c> oldMap,Boolean isInsert,Map<Id,price_prid__c> newMap){
        Set<Id> updateUnderlyingQLpridSet = new Set<Id>();
        Boolean isUpdate = !isInsert;
        List<SBQQ__QuoteLine__c> dollarChangeQuoteLineList = new List<SBQQ__QuoteLine__c>();
        Set<Id> quoteLinesToIgnoreUpdateSet = new Set<Id>();
        Set<String> ecpOPNCombinationSet = new Set<String>();
        Map<String,price_PRID__c> ecpOPNToNewPridMap = new Map<String,price_PRID__c>();
        Map<String,Set<String>> ecpOPNToStepUniqueCombMap = new Map<String,Set<String>>();
        Map<String,Set<String>> ecpOPNToAVPUniqueCombMap = new Map<String,Set<String>>();
        Set<Id> pridDeactivationSet = new Set<Id>();
        List<price_prid__c> pridDeactivationList = new List<price_prid__c>();
        Map<String,String> quoteLineApiToPridApiMap = new Map<String,String>{
                'price_suggested_resale_amt__c' => 'price_amt__c',
                'SBQQ__Quantity__c' => 'core_cpq_quantity_eau_nbr__c',
                'core_cpq_upper_bound_qty_nbr__c' => 'core_cpq_upper_bound_qty_nbr__c',
                'core_cpq_lower_bound_qty_qty__c' => 'core_cpq_lower_bound_qty_nbr__c',
                'core_cpq_pricing_start_date_dt__c' => 'core_cpq_price_start_date_dt__c',
                'core_cpq_pricing_end_date_dt__c' => 'core_cpq_price_end_date_dt__c',
                'core_cpq_review_date_dt__c' => 'core_cpq_prid_review_date_dt__c',
                'core_cpq_reviewer__c' => 'core_cpq_prid_reviewer__c',
                'core_cpq_active_Pricing__c' => 'core_cpq_active_pricing_cb__c',
                'core_cpq_comments_txt__c' => 'core_cpq_comments_txt__c',
                'core_cpq_price_eligibility_date_dt__c' => 'core_cpq_prid_eligiblity_date_dt__c'
                };
        Map<String,String> pridApiToQuoteLineApiMap = new Map<String,String>{
             'price_amt__c' => 'price_suggested_resale_amt__c',
             'core_cpq_quantity_eau_nbr__c' => 'SBQQ__Quantity__c',
             'core_cpq_upper_bound_qty_nbr__c' => 'core_cpq_upper_bound_qty_nbr__c',
             'core_cpq_lower_bound_qty_nbr__c' => 'core_cpq_lower_bound_qty_qty__c',
             'core_cpq_price_start_date_dt__c' => 'core_cpq_pricing_start_date_dt__c',
             'core_cpq_price_end_date_dt__c' => 'core_cpq_pricing_end_date_dt__c',
             'core_cpq_prid_review_date_dt__c' => 'core_cpq_review_date_dt__c',
             'core_cpq_prid_reviewer__c' => 'core_cpq_reviewer__c',
             'core_cpq_active_pricing_cb__c' => 'core_cpq_active_Pricing__c',
             'core_cpq_comments_txt__c' => 'core_cpq_comments_txt__c',
             'core_cpq_prid_eligiblity_date_dt__c' => 'core_cpq_price_eligibility_date_dt__c'  
             };
                                                                               
        Boolean quoteLineInitiated = false;
	//Hari -> TWC3133-917 [PRID] Track PRID De-Activation
        Map<String,String> uniToNameMap=new Map<String,String>();
        if(isInsert){
            for(price_prid__c prid : pridList){
                if(prid.core_cpq_active_cb__c && prid.core_cpq_ecp_opn_number__c != null){
                    ecpOPNCombinationSet.add(prid.core_cpq_ecp_opn_number__c);
                    ecpOPNToNewPridMap.put(prid.core_cpq_ecp_opn_number__c,prid);
                    if(prid.core_cpq_type__c=='Step'){
                        if(ecpOPNToStepUniqueCombMap.containsKey(prid.core_cpq_ecp_opn_number__c)){
                            ecpOPNToStepUniqueCombMap.get(prid.core_cpq_ecp_opn_number__c).add(prid.core_cpq_unique_combination_nm__c);
                        }else{
                            ecpOPNToStepUniqueCombMap.put(prid.core_cpq_ecp_opn_number__c,new Set<String>{prid.core_cpq_unique_combination_nm__c});
                        }
                    }else if(prid.core_cpq_type__c=='AVP'){
                        if(ecpOPNToAVPUniqueCombMap.containsKey(prid.core_cpq_ecp_opn_number__c)){
                            ecpOPNToAVPUniqueCombMap.get(prid.core_cpq_ecp_opn_number__c).add(prid.core_cpq_unique_combination_nm__c);
                        }else{
                            ecpOPNToAVPUniqueCombMap.put(prid.core_cpq_ecp_opn_number__c,new Set<String>{prid.core_cpq_unique_combination_nm__c});
                        }
                    }
		    		//Hari -> TWC3133-917 [PRID] Track PRID De-Activation
                    uniToNameMap.put(prid.core_cpq_unique_combination_nm__c,prid.Name);
                }
            }                                         
            if(!ecpOPNCombinationSet.isEmpty()){
                for(price_prid__c prid : [SELECT Id,core_cpq_unique_combination_nm__c,core_cpq_ecp_opn_number__c,core_cpq_type__c,core_cpq_cps_cb__c from price_prid__c where core_cpq_ecp_opn_number__c IN : ecpOPNCombinationSet AND core_cpq_active_cb__c = true AND Id NOT IN:newMap.keySet() LIMIT :Limits.getLimitDMLRows()]){                     
                    if(ecpOPNCombinationSet.contains(prid.core_cpq_ecp_opn_number__c)){
                        Boolean deactivatePRID=false;
                        String newPRIDNo='';
                        price_PRID__c newPRID=ecpOPNToNewPridMap.get(prid.core_cpq_ecp_opn_number__c);
                        if((prid.core_cpq_type__c != newPRID.core_cpq_type__c) || (prid.core_cpq_type__c == newPRID.core_cpq_type__c && prid.core_cpq_cps_cb__c != newPRID.core_cpq_cps_cb__c)){
                            deactivatePRID=true;
                            newPRIDNo=newPRID.Name;
                        }else{
                            if(newPRID.core_cpq_type__c=='Step' && ecpOPNToStepUniqueCombMap.containsKey(prid.core_cpq_ecp_opn_number__c) && ecpOPNToStepUniqueCombMap.get(prid.core_cpq_ecp_opn_number__c).contains(prid.core_cpq_unique_combination_nm__c)){
                                deactivatePRID=true;
                                newPRIDNo=uniToNameMap.get(prid.core_cpq_unique_combination_nm__c);
                            }else if(newPRID.core_cpq_type__c=='AVP' && ecpOPNToAVPUniqueCombMap.containsKey(prid.core_cpq_ecp_opn_number__c) && ecpOPNToAVPUniqueCombMap.get(prid.core_cpq_ecp_opn_number__c).contains(prid.core_cpq_unique_combination_nm__c)){
                                deactivatePRID=true;
                                newPRIDNo=uniToNameMap.get(prid.core_cpq_unique_combination_nm__c);
                            }
                        }
                        
                        if(deactivatePRID){
                            pridDeactivationSet.add(prid.Id);
                            prid.core_cpq_active_cb__c = false;
                            prid.core_cpq_update_underlying_quotelines_cb__c = true;
                            prid.core_cpq_cps_cb__c=false;
                            prid.Inactivation_Reason__c='Replaced by '+newPRIDNo;
                            pridDeactivationList.add(prid);
                        }
                    }
                }
                if(!pridDeactivationList.isEmpty()){
                    update pridDeactivationList;
                }
            }
                                                           
        }
        if(isUpdate){
            Boolean updateBatchTriggerField = true;
            set<Id> pricingTypeSet=new set<Id>();
            Map<Id,price_prid__c> pridQuoteMap=new Map<Id,price_prid__c>([Select Id,core_cpq_quote__r.core_cpq_extended_cp_quote_cb__c,core_cpq_price_end_date_dt__c from price_prid__c where Id in : pridList]);
            for(price_prid__c prid : pridList){
                if(prid.core_cpq_type__c=='AVP' && prid.core_cpq_update_underlying_quotelines_cb__c == oldMap.get(prid.Id).core_cpq_update_underlying_quotelines_cb__c && !prid.core_cpq_update_underlying_quotelines_cb__c
                  && prid.core_cpq_active_pricing_cb__c != oldMap.get(prid.Id).core_cpq_active_pricing_cb__c){
                    pricingTypeSet.add(prid.Id);
                }
                if((prid.core_cpq_update_underlying_quotelines_cb__c != oldMap.get(prid.Id).core_cpq_update_underlying_quotelines_cb__c) && prid.core_cpq_update_underlying_quotelines_cb__c){
                    updateUnderlyingQLpridSet.add(prid.Id);
                    quoteLineInitiated = true;
                    if(prid.core_cpq_quoteline__c != null){}
                }
                if(!prid.core_cpq_active_cb__c && prid.core_cpq_active_cb__c != oldMap.get(prid.Id).core_cpq_active_cb__c){
                    pridDeactivationSet.add(prid.Id);
                }
                
                if(!triggeredOnQuoteApproval){
                    Boolean isPridRevision = false;
                    Boolean isPridRevisionTriggered = false;
                    Boolean isPridUpdation = false; 
                    if(revisionTriggerPridFieldMap.containsKey(prid.core_cpq_type__c)){
                        for(String pridField : revisionTriggerPridFieldMap.get(prid.core_cpq_type__c)){
                            if(prid.get(pridField) != oldMap.get(prid.Id).get(pridField)){
                                isPridRevisionTriggered = true;
                            }
                        }
                    }
                    if(isPridRevisionTriggered && revisionFieldsPridMap.containsKey(prid.core_cpq_type__c)){
                        for(String pridField : revisionFieldsPridMap.get(prid.core_cpq_type__c)){
                            if(prid.get(pridField) != oldMap.get(prid.Id).get(pridField)){
                                isPridRevision = true;
                            }
                        }
                    }
                    if(updationFieldPridMap.containsKey(prid.core_cpq_type__c)){
                        for(String pridField : updationFieldPridMap.get(prid.core_cpq_type__c)){
                            if(prid.get(pridField) != oldMap.get(prid.Id).get(pridField)){
                                isPridUpdation = true;
                            }
                        }
                    }
                    
                    if(isPridRevision || isPridUpdation){
                        updateUnderlyingQLpridSet.add(prid.Id);
                    }
                }
                
            }
            if(!pricingTypeSet.isEmpty()){
                List<SBQQ__QuoteLine__c> quoteToUpdate=new List<SBQQ__QuoteLine__c>();
                List<SBQQ__QuoteLine__c> quoteLst=[select core_cpq_PRID__r.core_cpq_active_pricing_cb__c,core_cpq_dollar_change_flag_cb__c from SBQQ__QuoteLine__c where core_cpq_PRID__r.Id IN :pricingTypeSet and core_cpq_quote_line_type_txt__c='AVP'];
                for(SBQQ__QuoteLine__c quoteLine:quoteLst){
                    if(quoteLine.core_cpq_PRID__r.core_cpq_active_pricing_cb__c==FALSE){
                        //quoteLine.core_cpq_dollar_change_flag_cb__c=TRUE;
                        quoteLine.core_cpq_active_Pricing__c=FALSE;
                        quoteToUpdate.add(quoteLine);
                    }
                    if(quoteLine.core_cpq_PRID__r.core_cpq_active_pricing_cb__c==TRUE){
                        quoteLine.core_cpq_active_Pricing__c=TRUE;
                        quoteToUpdate.add(quoteLine);
                    }
                }
                if(!quoteToUpdate.isEmpty()){
                    SBQQ.TriggerControl.disable();
                    List<Database.SaveResult> result=Database.update(quoteToUpdate,false);
                    SBQQ.TriggerControl.enable();
                    Map<String,String>  qlToErrorMap=new Map<String,String>();
                    for(Integer i=0;i<result.size(); i++){
                        Database.SaveResult sr = result[i];
                        if (!sr.isSuccess()) {
                            String msg=PSG_QuotewithopptyInactive_Batch.getErrorAsString(sr.getErrors());
                            qlToErrorMap.put(sr.getId(),msg);
                        }                        
                    }
                    if(!qlToErrorMap.isEmpty()){
                        PSG_Utility.createCoreLogEntry('PRIDBusinessLogic','afterInsertUpdateOperations','Failed to update QLs on Active Pricing update on PRID',''+qlToErrorMap
                                           ,'SBQQ__QuoteLine__c','High','');
                    }
                }
                updateUnderlyingDPAALN(pricingTypeSet,true);
            }
            
            
                                                           
            if(!pridDeactivationSet.isEmpty()){
                dollarChangeQuoteLineList = [SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.core_cpq_quote_type_nm__c,core_cpq_dollar_change_flag_cb__c,core_cpq_lower_bound_qty_qty__c,price_suggested_resale_amt__c,core_cpq_quote_line_type_txt__c,
                                                                                            core_cpq_PRID__r.price_amt__c,core_cpq_PRID__r.core_cpq_lower_bound_qty_nbr__c,SBQQ__Quantity__c,
                                                                                            core_cpq_pricing_start_date_dt__c,core_cpq_pricing_end_date_dt__c,
                                                                                            core_cpq_PRID__r.core_cpq_upper_bound_qty_nbr__c,core_cpq_upper_bound_qty_nbr__c,core_cpq_PRID__r.core_cpq_quantity_eau_nbr__c,core_cpq_PRID__r.core_cpq_quoteline__c 
                                                                                            ,core_cpq_PRID__r.core_cpq_price_start_date_dt__c,core_cpq_PRID__r.Name,
                                                                                            core_cpq_PRID__r.core_cpq_price_end_date_dt__c
                                                                                            FROM SBQQ__QuoteLine__c  where core_cpq_PRID__c 
                                                                                            IN: pridDeactivationSet and ((SBQQ__Quote__r.core_cpq_active_cb__c = true and SBQQ__Quote__r.core_cpq_quote_type_nm__c<>'Contract Pricing')
                                                                                                                         or (SBQQ__Quote__r.core_cpq_quote_type_nm__c='Contract Pricing' and SBQQ__Quote__r.SBQQ__Status__c = 'Approved' )) LIMIT :Limits.getLimitDMLRows() ];
                if(!dollarChangeQuoteLineList.isEmpty()){
                    updateUnderlyingDPAALN(pridDeactivationSet,true);
                }
                if((dollarChangeQuoteLineList.size() > Integer.valueOf(Label.PSG_FollowOnQLBatchLimit) && !System.isBatch()) || Test.isRunningTest()){
                    PSG_BatchUpdateQuoteLines updateQLBatch = new PSG_BatchUpdateQuoteLines();
                    updateQLBatch.onlyDollarChangeUpdate = true;
                    updateQLBatch.quoteLinesToIgnoreUpdateSet = new Set<Id>();
                    updateQLBatch.quoteLineApiToPridApiMap = quoteLineApiToPridApiMap;
                    updateQLBatch.pridApiToQuoteLineApiMap = pridApiToQuoteLineApiMap;
                    updateQLBatch.quoteLineInitiated = quoteLineInitiated;
                    updateQLBatch.quoteLineListToProcess=dollarChangeQuoteLineList;
                    Database.executeBatch(updateQLBatch,10);
                    updateBatchTriggerField = false;
                }else{
                    updateUnderlyingQL(quoteLineApiToPridApiMap,new Set<Id>(),dollarChangeQuoteLineList,true,quoteLineInitiated,pridApiToQuoteLineApiMap);
                } 
            }                                     
            List<SBQQ__QuoteLine__c> underlyingQuoteLineList = new List<SBQQ__QuoteLine__c>();
            if(!updateUnderlyingQLpridSet.isEmpty()){
                String query = 'SELECT Id,core_cpq_quote_line_type_txt__c,core_cpq_PRID__c,core_cpq_PRID__r.Name,SBQQ__Quote__c,SBQQ__Quote__r.core_cpq_quote_type_nm__c';
                if(!quoteLineApiToPridApiMap.isEmpty()){
                    query = query +','+ String.join(new List<String>(quoteLineApiToPridApiMap.keySet()),',');
                    for(String pridField : quoteLineApiToPridApiMap.Values()){
                        query = query +','+ 'core_cpq_PRID__r.'+pridField;
                    }
                }                                           
                                                               
                query=query + ' FROM SBQQ__QuoteLine__c WHERE '+
                    ' core_cpq_PRID__c IN: updateUnderlyingQLpridSet '+
                    ' and '+
                    ' core_cpq_PRID__r.core_cpq_active_cb__c = true '+
                    ' and '+
                    ' core_cpq_quote_line_type_txt__c != null '+
                    ' and '+
                    ' core_cpq_dollar_change_flag_cb__c!=true '+
                    ' and ('+
                    //' (SBQQ__Quote__r.core_cpq_quote_type_nm__c = \'Contract Pricing\' and SBQQ__Quote__r.SBQQ__Status__c = \'Approved\' and ((core_cpq_active_cb__c = true and core_cpq_Process_flag__c = true) OR (core_cpq_active_cb__c = false and core_cpq_Process_flag__c = false))) '+
                    //' or '+
                    ' ( SBQQ__Quote__r.core_cpq_quote_type_nm__c != \'Contract Pricing\' and SBQQ__Quote__r.core_cpq_quote_type_nm__c!=\'Transfer Pricing\' and SBQQ__Quote__r.core_cpq_active_cb__c =true)'+
                    ' or '+
                    ' (SBQQ__Quote__r.core_cpq_quote_type_nm__c = \'Transfer Pricing\' and SBQQ__Quote__r.core_cpq_active_cb__c =true and core_cpq_parent_quote_active_flag__c=true)'+
                    ')';
                underlyingQuoteLineList = DataBase.query(query);                                       
                if(!updateUnderlyingQLpridSet.isEmpty()){
                    Set<Id> revisionPRIDSet=new Set<Id>();
                    Set<Id> extendedPRIDSet=new Set<Id>();
                    Map<Id,Date> pridToExtensionDateMap = new Map<Id,Date>();
                    for(Id pridId:updateUnderlyingQLpridSet){
                        if(pridQuoteMap.containsKey(pridId) && pridQuoteMap.get(pridId).core_cpq_quote__r.core_cpq_extended_cp_quote_cb__c ){
                            extendedPRIDSet.add(pridId);            
                            pridToExtensionDateMap.put(pridId,pridQuoteMap.get(pridId).core_cpq_price_end_date_dt__c);
                        }else{
                            revisionPRIDSet.add(pridId);
                        }
                    } 
                    if(!revisionPRIDSet.isEmpty() && triggeredOnQuoteApproval){
                        updateUnderlyingDPAALN(revisionPRIDSet,true); 
                    }
                    if(!extendedPRIDSet.isEmpty()){
                        extendUnderlyingDPAALN(extendedPRIDSet,pridToExtensionDateMap);
                    }
                    if((underlyingQuoteLineList.size() >  Integer.valueOf(Label.PSG_FollowOnQLBatchLimit) && !System.isBatch()) || Test.isRunningTest()){
                        PSG_BatchUpdateQuoteLines updateQLBatch = new PSG_BatchUpdateQuoteLines();
                        updateQLBatch.onlyDollarChangeUpdate = false;
                        updateQLBatch.quoteLinesToIgnoreUpdateSet = new Set<Id>();
                        updateQLBatch.quoteLineApiToPridApiMap = quoteLineApiToPridApiMap;
                        updateQLBatch.pridApiToQuoteLineApiMap = pridApiToQuoteLineApiMap;
                        updateQLBatch.quoteLineInitiated = quoteLineInitiated;
                        updateQLBatch.quoteLineListToProcess=underlyingQuoteLineList;
                        Database.executeBatch(updateQLBatch,10);
                        updateBatchTriggerField = false;
                    }else{
                        updateUnderlyingQL(quoteLineApiToPridApiMap,quoteLinesToIgnoreUpdateSet,underlyingQuoteLineList,false,quoteLineInitiated,pridApiToQuoteLineApiMap);
                    }
                } 
            }
            List<price_prid__c> pridListToUpdate = new List<price_prid__c>();
            for(price_prid__c prid : pridList){
                if((prid.core_cpq_update_underlying_quotelines_cb__c 
                    != oldMap.get(prid.Id).core_cpq_update_underlying_quotelines_cb__c) && prid.core_cpq_update_underlying_quotelines_cb__c){
                        if(prid.core_cpq_update_underlying_quotelines_cb__c && updateBatchTriggerField){
                            pridListToUpdate.add(new price_prid__c(Id = prid.Id,core_cpq_update_underlying_quotelines_cb__c = false));
                        }
                    }
            }
            if(!pridListToUpdate.isEmpty()){
                update pridListToUpdate;
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : extendUnderlyingDPAALN
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Extends all the underlying Approved DPA & ALN records when processing extended CP quotes.
    ************************************************************************************************************/
    public static void extendUnderlyingDPAALN(Set<Id> pridIds,Map<Id,Date> pridToEndDateMap){
        Map<Id,String> dpaIdToRecNameMap=new Map<Id,String>();
        Map<Id,String> dpaIdToTypeMap=new Map<Id,String>();
        Map<Id,Date> dpaIdToEndDateMap=new Map<Id,Date>();
        List<core_cpq_dpa_aln__c> dpaAlnList=new List<core_cpq_dpa_aln__c>();
        for(core_cpq_dpa_aln_line__c dpaLine: [Select Id,core_cpq_cis_no_nbr__c,core_cpq_cis_no_nbr__r.core_cpq_record_type_identifier__c,core_cpq_prid__c,core_cpq_prid__r.Name from core_cpq_dpa_aln_line__c where core_cpq_prid__c in :pridIds and core_cpq_cis_no_nbr__r.core_cpq_update_from_batch_cb__c = false and core_cpq_cis_no_nbr__r.core_cpq_status_txt__c = 'Approved' and core_cpq_cis_no_nbr__r.core_cpq_ship_end_date_dt__c > TODAY  LIMIT :Limits.getLimitDMLRows()]){
            dpaIdToRecNameMap.put(dpaLine.core_cpq_cis_no_nbr__c,dpaLine.core_cpq_prid__r.Name);
            dpaIdToEndDateMap.put(dpaLine.core_cpq_cis_no_nbr__c,pridToEndDateMap.get(dpaLine.core_cpq_prid__c));
            dpaIdToTypeMap.put(dpaLine.core_cpq_cis_no_nbr__c,dpaLine.core_cpq_cis_no_nbr__r.core_cpq_record_type_identifier__c);
        }
        Set<Id> dpaAlnIds=new Set<Id>();
        if(!dpaIdToRecNameMap.keySet().isEmpty()){
            for(Id dpaId: dpaIdToRecNameMap.keySet()){
                core_cpq_dpa_aln__c dpa=new core_cpq_dpa_aln__c();
                dpa.Id=dpaId;
                if(System.isBatch() || System.isQueueable()){
                    dpa.core_cpq_update_from_batch_cb__c=true;
                }
                if(dpaIdToEndDateMap.containsKey(dpaId)){
                    dpaAlnIds.add(dpaId);
                    dpa.core_cpq_ship_end_date_dt__c=dpaIdToEndDateMap.get(dpaId);
                    dpa.core_cpq_change_flag__c='E';
                    dpa.core_cpq_bypass_validation__c = true;
                    dpa.core_cpq_status_change_reason__c=dpaIdToTypeMap.get(dpaId)+' Extended by '+dpaIdToRecNameMap.get(dpaId);
                    dpaAlnList.add(dpa);
                } 
            }
            update dpaAlnList;
            for(core_cpq_dpa_aln__c dpa: dpaAlnList){
                dpa.core_cpq_bypass_validation__c = false;
            }
            update dpaAlnList;
            if(!System.isBatch() && !System.isQueueable()){
                PSG_SendSAPRequestFutureClass.bulkSAPRequestFuture(dpaAlnIds);
            }
        }      
    }
    
    /************************************************************************************************************
    *Method Name : updateUnderlyingDPAALN
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Expire DPA & Hold ALN when CP quote are processed.
    ************************************************************************************************************/
    public static void updateUnderlyingDPAALN(Set<Id> pridOrQuoteIds,Boolean isPRIDTriggerd){
        Map<Id,String> dpaIdToRecNameMap=new Map<Id,String>();
        Map<Id,String> dpaIdToTypeMap=new Map<Id,String>();
        List<core_cpq_dpa_aln__c> dpaAlnList=new List<core_cpq_dpa_aln__c>();
        if(isPRIDTriggerd){
            for(core_cpq_dpa_aln_line__c dpaLine: [Select Id,core_cpq_cis_no_nbr__c,core_cpq_cis_no_nbr__r.core_cpq_record_type_identifier__c,core_cpq_prid__r.Name from core_cpq_dpa_aln_line__c where core_cpq_prid__c in :pridOrQuoteIds and core_cpq_cis_no_nbr__r.core_cpq_update_from_batch_cb__c = false and core_cpq_cis_no_nbr__r.core_cpq_status_txt__c = 'Approved' and core_cpq_cis_no_nbr__r.core_cpq_ship_end_date_dt__c > TODAY  LIMIT :Limits.getLimitDMLRows()]){
                dpaIdToRecNameMap.put(dpaLine.core_cpq_cis_no_nbr__c,dpaLine.core_cpq_prid__r.Name);
                dpaIdToTypeMap.put(dpaLine.core_cpq_cis_no_nbr__c,dpaLine.core_cpq_cis_no_nbr__r.core_cpq_record_type_identifier__c);
            }
        }else{
            for(core_cpq_dpa_aln__c dpa:[Select Id,core_cpq_record_type_identifier__c,core_cpq_active_quote__r.Name from core_cpq_dpa_aln__c where core_cpq_active_quote__c in :pridOrQuoteIds and core_cpq_update_from_batch_cb__c = false and core_cpq_status_txt__c = 'Approved' and core_cpq_ship_end_date_dt__c > TODAY  LIMIT :Limits.getLimitDMLRows()]){
                dpaIdToRecNameMap.put(dpa.Id,dpa.core_cpq_active_quote__r.Name);
                dpaIdToTypeMap.put(dpa.Id,dpa.core_cpq_record_type_identifier__c);
            }
        }
        Set<Id> dpaAlnIds=new Set<Id>();
        if(!dpaIdToRecNameMap.keySet().isEmpty()){
            for(Id dpaId: dpaIdToRecNameMap.keySet()){
                dpaAlnIds.add(dpaId);
                core_cpq_dpa_aln__c dpa=new core_cpq_dpa_aln__c();
                dpa.Id=dpaId;
                String msg=dpaIdToRecNameMap.get(dpaId).contains('PRID')?' revised/deactivated':' deactivated';
                if(dpaIdToTypeMap.get(dpaId)=='DPA'){
                    dpa.core_cpq_ship_end_date_dt__c=System.today();
                    dpa.core_cpq_change_flag__c='E';
                    dpa.core_cpq_status_change_reason__c='Expired as '+dpaIdToRecNameMap.get(dpaId)+(dpaIdToRecNameMap.get(dpaId).contains('PRID')?' revised/deactivated':' deactivated');                    
                }else{
                    dpa.core_cpq_change_flag__c='H';
		    		dpa.core_cpq_status_change_reason__c='Put on Hold as '+dpaIdToRecNameMap.get(dpaId)+(dpaIdToRecNameMap.get(dpaId).contains('PRID')?' revised/deactivated':' deactivated');                
                }
                dpa.core_cpq_bypass_validation__c = true;
                if(System.isBatch() || System.isQueueable()){
                    dpa.core_cpq_update_from_batch_cb__c=true;
                }
                dpaAlnList.add(dpa);
            }
            update dpaAlnList;
            for(core_cpq_dpa_aln__c dpa: dpaAlnList){
                dpa.core_cpq_bypass_validation__c = false;
            }
            update dpaAlnList;
            if(!System.isBatch() && !System.isQueueable()){
                PSG_SendSAPRequestFutureClass.bulkSAPRequestFuture(dpaAlnIds);
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : updateUnderlyingQL
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Update underlying QL whenever a PRID deactivation or PRID revision triggered.
    ************************************************************************************************************/
    public static void updateUnderlyingQL(Map<String,String> quoteLineApiToPridApiMap,Set<Id> quoteLinesToIgnoreUpdateSet,List<sObject> scope,Boolean onlyDollarChange,Boolean quoteLineInitiated,Map<String,String> pridApiToQuoteLineApiMap){
        
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        List<price_prid__c> pridList = new List<price_prid__c>();
        Map<Id,price_prid__c> pridUpdateMap = new Map<Id,price_prid__c>();
        try{
            for(sObject sobj : scope){
                SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)sobj;
                if(!quoteLinesToIgnoreUpdateSet.contains(quoteLine.Id)){
                    Boolean byPassCheckForQuantity = false;
                    if(onlyDollarChange){
                        quoteLine.core_cpq_dollar_change_flag_cb__c = true;
                        quoteLine.core_cpq_follow_on_process_cb__c = true;
                        quoteLineList.add(quoteLine);
                    }else if(quoteLineInitiated){
                        Boolean isPridRevision = false;
                        Boolean isPridUpdation = false;
                        Boolean isPridRevisionTriggered = false;
                        if(revisionTriggerQLFieldMap.containsKey(quoteLine.core_cpq_quote_line_type_txt__c)){
                            for(String qlField : revisionTriggerQLFieldMap.get(quoteLine.core_cpq_quote_line_type_txt__c)){
                                String pridField = quoteLineApiToPridApiMap.get(qlField);
                                if((quoteLine.getSObject('core_cpq_PRID__r')) != null && quoteLine.get(qlField) != (quoteLine.getSObject('core_cpq_PRID__r')).get(pridField)){
                                    isPridRevisionTriggered = true;
                                }
                            }
                        }
                        if(isPridRevisionTriggered && revisionFieldsQLToQLMap.containsKey(quoteLine.core_cpq_quote_line_type_txt__c)){
                            for(String qlField : revisionFieldsQLToQLMap.get(quoteLine.core_cpq_quote_line_type_txt__c)){
                                String pridField = quoteLineApiToPridApiMap.get(qlField);
                                if((quoteLine.getSObject('core_cpq_PRID__r')) != null && quoteLine.get(qlField) != (quoteLine.getSObject('core_cpq_PRID__r')).get(pridField)){
                                    quoteLine.put(qlField,(quoteLine.getSObject('core_cpq_PRID__r')).get(pridField));
                                    isPridRevision = true;
                                }
                            }
                        }
                        if(isPridRevision || isPridUpdation){
                            quoteLine.core_cpq_follow_on_process_cb__c = true;//added
                            quoteLineList.add(quoteLine);
                        }
                    }else{
                        Boolean isPridRevision = false;
                        Boolean isPridUpdation = false;
                        Boolean isPridRevisionTriggered = false;
                        if(revisionTriggerPridFieldMap.containsKey(quoteLine.core_cpq_quote_line_type_txt__c)){
                            for(String pridField : revisionTriggerPridFieldMap.get(quoteLine.core_cpq_quote_line_type_txt__c)){
                                String qlField = pridApiToQuoteLineApiMap.get(pridField);
                                if((quoteLine.getSObject('core_cpq_PRID__r')) != null && quoteLine.get(qlField) != (quoteLine.getSObject('core_cpq_PRID__r')).get(pridField)){
                                    isPridRevisionTriggered = true;
                                }
                            }
                        }
                        if(isPridRevisionTriggered && revisionFieldsPridMap.containsKey(quoteLine.core_cpq_quote_line_type_txt__c)){
                            for(String pridField : revisionFieldsPridMap.get(quoteLine.core_cpq_quote_line_type_txt__c)){
                                String qlField = pridApiToQuoteLineApiMap.get(pridField);
                                if((quoteLine.getSObject('core_cpq_PRID__r')) != null && quoteLine.get(qlField) != (quoteLine.getSObject('core_cpq_PRID__r')).get(pridField)){
                                    isPridRevision = true;
                                    quoteLine.put(qlField,(quoteLine.getSObject('core_cpq_PRID__r')).get(pridField));
                                }
                            }
                        }
                        if(updationFieldPridMap.containsKey(quoteLine.core_cpq_quote_line_type_txt__c)){
                            for(String pridField : updationFieldPridMap.get(quoteLine.core_cpq_quote_line_type_txt__c)){
                                String qlField = pridApiToQuoteLineApiMap.get(pridField);
                                if((quoteLine.getSObject('core_cpq_PRID__r')) != null && quoteLine.get(qlField) != (quoteLine.getSObject('core_cpq_PRID__r')).get(pridField)){
                                    isPridUpdation = true;
                                    quoteLine.put(qlField,(quoteLine.getSObject('core_cpq_PRID__r')).get(pridField));
                                }
                            }
                        }
                        if(isPridRevision || isPridUpdation){
                            quoteLine.core_cpq_follow_on_process_cb__c = true;//added
                            quoteLineList.add(quoteLine);
                        }
                    }
                    if(!pridUpdateMap.containsKey(quoteLine.core_cpq_PRID__c) && !Test.isRunningTest()){
                        pridUpdateMap.put(quoteLine.core_cpq_PRID__c,new price_prid__c(Id = quoteLine.core_cpq_PRID__c,
                                                                                       core_cpq_update_underlying_quotelines_cb__c = false));
                    } 
                }                                                          
            }
            if(!quoteLineList.isEmpty()){
                List<SBQQ__QuoteLine__c> succList=new List<SBQQ__QuoteLine__c>();
                List<SBQQ__QuoteLine__c> failedList=new List<SBQQ__QuoteLine__c>();
                SBQQ.TriggerControl.disable();
                List<Database.SaveResult> updateResults = Database.update (quoteLineList,false);
                for(Integer i=0;i<updateResults.size();i++){
                    if(!updateResults[i].isSuccess()){
                        failedList.add(quoteLineList[i]);
                    }else{
                        succList.add(quoteLineList[i]);
                    }
                }
                for(SBQQ__QuoteLine__c quoteLine : succList){
                    quoteLine.core_cpq_follow_on_process_cb__c = false;
                }
                if(!succList.isEmpty()){
                    Database.update (succList,false);
                }
                SBQQ.TriggerControl.enable();
                if(!failedList.isEmpty()){
            		PSG_Utility.createCoreLogEntry('PRIDBusinessLogic', 'updateUnderlyingQL', 'Error while procesing underlying Qls on PRID revision or deactivation', 'QLs Failed to Update => '+failedList+'\n\n PRID triggered : '+pridUpdateMap.values(), 'SBQQ__QuoteLine__c', 'High', '');
                }
            }
            if(!pridUpdateMap.isEmpty()){
                Database.update(pridUpdateMap.values()); 
            } 
        }catch(Exception e){
            PSG_Utility.createCoreLogEntry('PRIDBusinessLogic', 'updateUnderlyingQL', 'Unexpected exception', 'Exception => '+e, 'SBQQ__QuoteLine__c', 'High', '');
        }
        finally{
            SBQQ.TriggerControl.enable();
        }        
    }
    
    /************************************************************************************************************
    *Method Name : pridPosLogic
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Returns PRID_POS_Stage__c records where Price_PRID__c is not empty.
    ************************************************************************************************************/
    public static List<PRID_POS_Stage__c> pridPosLogic(){
        return [select  Price_PRID__c, core_cpq_pos_quantity__c 
                from PRID_POS_Stage__c where Price_PRID__c <> null];
    }
}