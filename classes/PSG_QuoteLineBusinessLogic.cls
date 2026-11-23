/****************************************************************************************************
Apex Class Name : PSG_QuoteLineBusinessLogic
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Business Logic class for Quote Line Trigger PSG Operations.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay                     01/05/2021               Created
*****************************************************************************************************/
public without sharing class PSG_QuoteLineBusinessLogic{
    
    public static Map<String,Set<String>> revisionTriggerQLFieldMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> updationFieldQLMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> revisionFieldsQLMap = new Map<String,Set<String>>();
    
    public static Map<String,Set<String>> revisionTriggerPridFieldMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> updationFieldPridMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> revisionFieldsPridMap = new Map<String,Set<String>>();
    public static Map<Id,String> userIdToRoleMap = new Map<Id,String>();
    public static Boolean isInternal = false;
    public static Boolean isGoalPriceMandatory = false;  
    public static Boolean fetchPriceDataRecursiveCheck = false;
    public static Boolean updateDistiMarginValue = false;
    //public static Map<String,Map<Date,core_cpq_distributor_margin__c>> productToDistyMarginMap = new Map<String,Map<Date,core_cpq_distributor_margin__c>>();
    //public static Map<String,core_cpq_distributor_margin__c> familyToDistyMarginMap = new Map<String,core_cpq_distributor_margin__c>();
    public static Map<String,core_cpq_distributor_margin__c> familyHunterDistyMarginMap = new Map<String,core_cpq_distributor_margin__c>();
    public static Map<String,core_cpq_distributor_margin__c> familyFarmerDistyMarginMap = new Map<String,core_cpq_distributor_margin__c>();
    public static Map<String,core_cpq_distributor_margin__c> hunterDistyMarginMap = new Map<String,core_cpq_distributor_margin__c>();
    public static Map<String,core_cpq_distributor_margin__c> farmerDistyMarginMap = new Map<String,core_cpq_distributor_margin__c>();
    public static Boolean triggeredOnQuoteApproval = False;
    static{
        for(PSG_PRID_Mapping__mdt pridRec :[SELECT Id,PSG_PRID_Type__c,psg_revision_trigger_field_prid__c,psg_cpq_revision_trigger_field_ql__c,
                                            core_cpq_updation_trigger_field_prid__c,psg_updation_trigger_field_ql__c,psg_revision_fields_QL__c,
                                            psg_revision_fields_prid__c from PSG_PRID_Mapping__mdt where PSG_Active__c = true]){
            revisionTriggerQLFieldMap.put(pridRec.PSG_PRID_Type__c,(String.isNotBlank(pridRec.psg_cpq_revision_trigger_field_ql__c) ? new Set<String>((pridRec.psg_cpq_revision_trigger_field_ql__c).split(':')) : new Set<String>()));                                 
            updationFieldQLMap.put(pridRec.PSG_PRID_Type__c,(String.isNotBlank(pridRec.psg_updation_trigger_field_ql__c) ? new Set<String>((pridRec.psg_updation_trigger_field_ql__c).split(':')) : new Set<String>()));
            revisionFieldsQLMap.put(pridRec.PSG_PRID_Type__c,(String.isNotBlank(pridRec.psg_revision_fields_QL__c) ? new Set<String>((pridRec.psg_revision_fields_QL__c).split(':')) : new Set<String>()));
            revisionTriggerPridFieldMap.put(pridRec.PSG_PRID_Type__c,(String.isNotBlank(pridRec.psg_revision_trigger_field_prid__c) ? new Set<String>((pridRec.psg_revision_trigger_field_prid__c).split(':')) : new Set<String>()));
            updationFieldPridMap.put(pridRec.PSG_PRID_Type__c,(String.isNotBlank(pridRec.core_cpq_updation_trigger_field_prid__c) ? new Set<String>((pridRec.core_cpq_updation_trigger_field_prid__c).split(':')) : new Set<String>())); 
            revisionFieldsPridMap.put(pridRec.PSG_PRID_Type__c,(String.isNotBlank(pridRec.psg_revision_fields_prid__c) ? new Set<String>((pridRec.psg_revision_fields_prid__c).split(':')) : new Set<String>())); 
        }
        /*for(core_cpq_distributor_margin__c distyMargin : [Select Id,core_cpq_Partner_Program_Txt__c,core_cpq_Disty_Margin_Pct__c,core_cpq_Margin_GEO_Txt__c,core_cpq_Active_Cb__c,core_cpq_product_family_txt__c,core_Design_Reg_Approved_Date__c FROM core_cpq_distributor_margin__c where core_cpq_Active_Cb__c = true AND core_cpq_product_family_txt__c != NULL AND core_Design_Reg_Approved_Date__c != NULL]){
            String uniqueKey = '';
            uniqueKey =  uniqueKey + distyMargin.core_cpq_product_family_txt__c + '_' + distyMargin.core_cpq_Margin_GEO_Txt__c + '_' + distyMargin.core_cpq_Partner_Program_Txt__c;
            if(!familyToDistyMarginMap.containsKey(uniqueKey)){
                familyToDistyMarginMap.put(uniqueKey,distyMargin);
            }
        }*/
    }
    
    /************************************************************************************************************
    *Method Name : beforeInsertUpdateOperations
    *Created Date: 08/13/2021
    *Author: Vijay
    *Description : Performs operations on before context of trigger.
    ************************************************************************************************************/
    public static void beforeInsertUpdateOperations(List<SBQQ__QuoteLine__c> quoteLineList,
                                                    Boolean isInsert,Map<id,SBQQ__QuoteLine__c> oldMap){
                                                       
        if(quoteLineList != null && !quoteLineList.isEmpty()){ 
                Set<Id> quoteIdSet = new Set<Id>();
                Set<Id> productIdSet = new Set<Id>();
                Set<String> productOPNSet = new Set<String>();
                Set<Id> drpIdSet = new Set<Id>();
                Set<String> drpDistyIdSet = new Set<String>();
            
                Set<Id> priceBookIdSet = new Set<Id>();
                Set<Id> quoteLineIdSet = new Set<Id>();
                Set<String> opnSet = new Set<String>();
                Set<String> productId2Set = new Set<String>();
                Map<String,PricebookEntry> uniqueIdToPriceBookEntryMap = new Map<String,PricebookEntry>();
                Map<String,Map<Date,price_forward_cost__c>> productToFWDMapStartDt = new Map<String,Map<Date,price_forward_cost__c>>();
                Map<Id,Boolean> smiFlagInd = new Map<Id,Boolean>();
                Map<Id,Boolean> orderFlagInd = new Map<Id,Boolean>();
                Map<Id,Map<Date,price_msvp__c>> productToMSVPMap = new Map<Id,Map<Date,price_msvp__c>>();
                Map<Id,String> prodToolTypeMap = new Map<Id,String>();
                Map<Id,String> authCodeProductMap = new Map<Id,String>(); 
                Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>();               
                Map<Id,list<core_cpq_list_price__c>> uniqueIdToListPriceMap = new map<Id,list<core_cpq_list_price__c>>();
                Set<String> accountTierSet = new Set<String>(); 
                Set<String> accountAllianceSet = new Set<String>();
                Set<String> geoSet = new Set<String>();
                Map<Id,String> quoteIdToEcMap = new Map<Id,String>();
                Map<Id,Boolean> psgrestrictedprodMap = new Map<Id,Boolean>();
                Map<Id,List<id>> pridToparentquotemap= new Map<Id,List<id>>();
                Set<String> QuotePRIDSet=new Set<String>();
                Set<Id> QLparentQuoteIdSet = new Set<Id>();
                Boolean isUpdate = !isInsert;
                Map<String,String> quoteLineApiToPridApiMap = new Map<String,String>{
                    'price_suggested_resale_amt__c' => 'price_amt__c',
                    'SBQQ__Quantity__c' => 'core_cpq_quantity_eau_nbr__c',
                    'core_cpq_upper_bound_qty_nbr__c' => 'core_cpq_upper_bound_qty_nbr__c',
                    'core_cpq_lower_bound_qty_qty__c' => 'core_cpq_lower_bound_qty_nbr__c',
                    'core_cpq_pricing_start_date_dt__c' => 'core_cpq_price_start_date_dt__c',
                    'core_cpq_pricing_end_date_dt__c' => 'core_cpq_price_end_date_dt__c',
                    'core_cpq_price_eligibility_date_dt__c' => 'core_cpq_prid_eligiblity_date_dt__c',
                    'core_cpq_review_date_dt__c' => 'core_cpq_prid_review_date_dt__c',
                    'core_cpq_reviewer__c' => 'core_cpq_prid_reviewer__c',
                    'core_cpq_active_Pricing__c' => 'core_cpq_active_pricing_cb__c',
                    'core_cpq_comments_txt__c' => 'core_cpq_comments_txt__c'
                };
                Map<String,String> quoteLineApiToLabelMap = new Map<String,String>{
                    'price_suggested_resale_amt__c' => 'Suggested Resale Price',
                    'SBQQ__Quantity__c' => 'Quantity(EAU)',
                    'core_cpq_upper_bound_qty_nbr__c' => 'Upper Bound Qty',
                    'core_cpq_lower_bound_qty_qty__c' => 'Lower Bound Qty',
                    'core_cpq_pricing_start_date_dt__c' => 'Price Start Date',
                    'core_cpq_pricing_end_date_dt__c' => 'Price End Date',
                    'core_cpq_price_eligibility_date_dt__c' => 'PED',
                    'core_cpq_review_date_dt__c' => 'Review Date',
                    'core_cpq_reviewer__c' => 'Reviewer',
                    'core_cpq_active_Pricing__c' => 'Active Pricing',
                    'core_cpq_comments_txt__c' => 'PRID COMMENTS'
                };
                Map<String,String> quoteLineApiToTypeMap = new Map<String,String>{
                    'SBQQ__Quantity__c' => 'integer',
                    'core_cpq_upper_bound_qty_nbr__c' => 'integer',
                    'core_cpq_lower_bound_qty_qty__c' => 'integer',
                    'core_cpq_pricing_start_date_dt__c' => 'date',
                    'core_cpq_pricing_end_date_dt__c' => 'date',
                    'core_cpq_price_eligibility_date_dt__c' => 'date',
                    'core_cpq_review_date_dt__c' => 'date'
                };
                Map<String,String> quoteLineApiToDefaultValueMap = new Map<String,String>{
                    'price_suggested_resale_amt__c' => '0',
                    'SBQQ__Quantity__c' => '0',
                    'core_cpq_upper_bound_qty_nbr__c' => '0',
                    'core_cpq_lower_bound_qty_qty__c' => '0',
                    'core_cpq_pricing_start_date_dt__c' => null,
                    'core_cpq_pricing_end_date_dt__c' => null,
                    'core_cpq_price_eligibility_date_dt__c' => null,
                    'core_cpq_review_date_dt__c' => null,
                    'core_cpq_reviewer__c' => null
                };
                Map<String,String> pridApiToDefaultValueMap = new Map<String,String>{
                    'price_amt__c' => '0',
                    'core_cpq_quantity_eau_nbr__c' => '0',
                    'core_cpq_upper_bound_qty_nbr__c' => '0',
                    'core_cpq_lower_bound_qty_nbr__c' => '0',
                    'core_cpq_pricing_start_date_dt__c' => null,
                    'core_cpq_price_start_date_dt__c' => null,
                    'core_cpq_prid_eligiblity_date_dt__c' => null,
                    'core_cpq_prid_review_date_dt__c' => null,
                    'core_cpq_prid_reviewer__c' => null
                }; 
                Map<String,String> pridApiToTypeMap = new Map<String,String>{
                    'core_cpq_price_start_date_dt__c' => 'date',
                    'core_cpq_price_end_date_dt__c' => 'date',
                    'core_cpq_prid_eligiblity_date_dt__c' => 'date',
                    'core_cpq_prid_review_date_dt__c' => 'date'
                };
                if(userIdToRoleMap.isEmpty()){
                    for(PermissionSetAssignment psa : [SELECT Id,AssigneeId,PermissionSet.Name,PermissionSet.Profile.Name,Assignee.Contact.AccountId 
                                                       FROM PermissionSetAssignment WHERE AssigneeId =: userInfo.getUserId() AND 
                                                       (PermissionSet.Name =: Label.PSG_Quote_SOS_PermissionSet OR 
                                                        PermissionSet.Name =: Label.PSG_Quote_BO_PermissionSet OR 
                                                        PermissionSet.Name =: Label.PSG_Quote_BM_PermissionSet OR 
                                                        PermissionSet.Name =: Label.PSG_PermissionSets_PSG_Distributor)]){
                        if(psa.PermissionSet.Name == Label.PSG_PermissionSets_PSG_Distributor){
                            userIdToRoleMap.put(psa.AssigneeId,'Disty');
                        }                                                            
                        if(psa.PermissionSet.Name == Label.PSG_Quote_SOS_PermissionSet){
                            userIdToRoleMap.put(psa.AssigneeId,'SOS');
                            isGoalPriceMandatory = true;
                            isInternal = true;
                        }else if(psa.PermissionSet.Name == Label.PSG_Quote_BM_PermissionSet){
                            userIdToRoleMap.put(psa.AssigneeId,'BM');
                            isInternal = true;
                        }else if(psa.PermissionSet.Name == Label.PSG_Quote_BO_PermissionSet){
                            userIdToRoleMap.put(psa.AssigneeId,'BO');
                            isInternal = true;
                        }
                    }
                }
                Set<String> existingPartnerProgram = new Set<String>{'PSG Demand Creation - Distribution','PSG Demand Creation - Hybrid','PSG Demand Creation - PSG'};
                if(isInsert){
                    
                    Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap = new Map<Id,SBQQ__Quote__c>();
                    Map<Id,SBQQ__Quote__c> quoteIdToDMQuoteMap = new Map<Id,SBQQ__Quote__c>();
                    Set<Id> PRIDSet = new Set<Id>();
                    Set<id> drpId = new Set<id>();
                    Set<id> prodId = new Set<id>();
                    Set<id> qId = new Set<id>();
                    Boolean errorCheck = false;
                    for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                        if(!quoteLineList.isEmpty()){
                            negativeValueCheck(quoteLine,null);
                        }
                        quoteLine.price_suggested_resale_amt__c = quoteLine.price_suggested_resale_amt__c ==null?0: quoteLine.price_suggested_resale_amt__c.setScale(2);
                        quoteLine.price_previous_suggested_resale_amt__c=quoteLine.price_suggested_resale_amt__c;
                        quoteLine.core_cpq_distributor_margin_pct__c = quoteLine.core_cpq_distributor_margin_pct__c==null ? 0 : (quoteLine.core_cpq_distributor_margin_pct__c)?.setScale(1);
                        quoteLine.core_cpq_previous_distributor_margin_pct__c = (quoteLine.core_cpq_distributor_margin_pct__c);
                        quoteLine.core_cpq_previous_margin_exception_txt__c  = quoteLine.core_cpq_margin_exception_txt__c;
                        quoteIdSet.add(quoteLine.SBQQ__Quote__c);
                        quoteLineIdSet.add(quoteLine.Id);
                        if(String.isNotBlank(quoteLine.core_cpq_qcp_error_nm__c) && !System.isQueueable()){
                            String errorMessage = quoteLine.core_cpq_qcp_error_nm__c;
                            quoteLine.addError(errorMessage.replace(':', '\n'));
			    errorCheck = true;
                            //break;
			    }else{
			    	quoteLine.core_cpq_qcp_error_nm__c=''; 	
                        }
                        if(quoteLine.price_suggested_resale_amt__c != null && quoteLine.price_msvp_l2_amt__c != null){
                            quoteLine.core_cpq_gp_msvpl2_nm__c = (quoteLine.price_suggested_resale_amt__c - quoteLine.price_msvp_l2_amt__c)?.setScale(2);
                        }
                        if(quoteLine.SBQQ__Quantity__c == null){
                            quoteLine.SBQQ__Quantity__c = 1;
                            quoteLine.core_cpq_upper_bound_qty_nbr__c = 1;
                        }
                        if(quoteLine.core_cpq_production_dt__c != null){
                            quoteLine.core_cpq_price_eligibility_date_dt__c = quoteLine.core_cpq_production_dt__c;
                        }else if(quoteLine.core_cpq_price_eligibility_date_dt__c != null){
                            quoteLine.core_cpq_production_dt__c = quoteLine.core_cpq_price_eligibility_date_dt__c;
                        }                        
                        if(quoteLine.core_cpq_years_nbr__c == null){
                            quoteLine.core_cpq_years_nbr__c = 1;
                        }
                        if(quoteLine.core_cpq_origin_txt__c == null){
                            quoteLine.core_cpq_origin_txt__c = 'Direct';
                        }
                        quoteLine.core_cpq_revision_request_category_nm__c = 'Choose Category';
                        if(quoteLine.core_cpq_product_nm__c != null){
                            quoteLine.SBQQ__Product__c = quoteLine.core_cpq_product_nm__c;
                        }else if(quoteLine.SBQQ__Product__c != null){
                            quoteLine.core_cpq_product_nm__c=quoteLine.SBQQ__Product__c;
                        }
                        if(quoteline.core_cpq_PRID__c != null){
                            PRIDSet.add(quoteline.core_cpq_PRID__c);
                        }
                        if(quoteLine.SBQQ__Product__c != null){
                            productIdSet.add(quoteLine.SBQQ__Product__c);
                            productOPNSet.add(quoteLine.Core_OPN__c);
                        }else if(quoteLine.core_cpq_opn__c != null){
                            opnSet.add(quoteLine.core_cpq_opn__c); 
                        } 
                        if(quoteLine.core_cpq_design_registration_product__c != null){
                            drpIdSet.add(quoteLine.core_cpq_design_registration_product__c);
                        }else if(quoteLine.core_cpq_altera_reg_txt__c != null){
                            drpDistyIdSet.add(quoteLine.core_cpq_altera_reg_txt__c); 
                        }
                        if(userIdToRoleMap.containsKey(userInfo.getUserId()) && 
                        userIdToRoleMap.get(userInfo.getUserId()) == 'SOS' && quoteLine.price_suggested_resale_amt__c == null){
                            quoteLine.price_suggested_resale_amt__c = (quoteLine.price_goal_price_amt__c)?.setScale(2);
                        }
                        if(userIdToRoleMap.containsKey(userInfo.getUserId()) && userIdToRoleMap.get(userInfo.getUserId()) == 'Disty'
                           && quoteLine.SBQQ__Quantity__c != null){
                               quoteLine.core_cpq_lower_bound_qty_qty__c = 1;
                               quoteLine.core_cpq_upper_bound_qty_nbr__c = quoteLine.SBQQ__Quantity__c + quoteLine.core_cpq_lower_bound_qty_qty__c - 1;   
                        }
                        if(quoteLine.core_cpq_design_registration_product__c != null){
                            drpId.add(quoteLine.core_cpq_design_registration_product__c);
                        }
                        if(quoteLine.SBQQ__Product__c != null){
                            prodId.add(quoteLine.SBQQ__Product__c);
                        }
                        
                        qId.add(quoteLine.SBQQ__Quote__c);
                        if(quoteLine.core_cpq_parent_quote__c != null){
                            QLparentQuoteIdSet.add(quoteLine.core_cpq_parent_quote__c);
                        }
                        if(errorCheck){
                                                                        break;
                                                                        }
                    }
                    Map<Id,price_prid__c> pridMap = new Map<Id,price_prid__c>();
                    if(!PRIDSet.isEmpty()){
                        pridMap = new Map<Id,price_prid__c>([SELECT Id,core_cpq_type__c,core_cpq_quantity_eau_nbr__c,
                                                             core_cpq_lower_bound_qty_nbr__c,core_cpq_upper_bound_qty_nbr__c,
                                                             price_amt__c,core_cpq_price_start_date_dt__c,core_cpq_price_end_date_dt__c,
                                                             core_cpq_prid_reviewer__c,core_cpq_prid_review_date_dt__c,core_cpq_active_pricing_cb__c,
                                                             core_cpq_prid_eligiblity_date_dt__c,core_cpq_sap_ecp_nm__c,core_cpq_prid_validity_date_dt__c from price_prid__c where Id IN: PRIDSet]);
                    }
                    String queryStr = '';
                    String productType = 'Intel® FPGAs';
                    String productOrg = 'Sales';
                    if(!opnSet.isEmpty()){
                        queryStr = 'SELECT Id,Core_OPN__c, Core_Item_Orderable_Ind__c,IsActive,Core_Item_Quotable_Ind__c, Core_Product_Org__c FROM Product2 where Core_OPN__c IN : opnSet and isActive = true and Core_Item_Quotable_Ind__c = true and Core_Product_Type__c =: productType and Core_Product_Org__c =: productOrg';
                    }
                    if(!productIdSet.isEmpty()){
                        if(String.isBlank(queryStr)){
                            queryStr = 'SELECT Id,Core_OPN__c, Core_Item_Orderable_Ind__c,IsActive,Core_Item_Quotable_Ind__c,Core_Product_Org__c FROM Product2 where Id IN : productIdSet';
                        }else{
                            queryStr += ' OR Id IN: productIdSet';                    
                        }
                    }
                    Map<String,Id> opnToProductIdMap = new Map<String,Id>();
                    Map<Id,String> productIdToOPNMap = new Map<Id,String>();
                    Set<Id> productsRegisterable = new Set<Id>();
                    if(String.isNotBlank(queryStr)){
                        for(Product2 prod : Database.query(queryStr)){
                            if(productIdSet.contains(prod.Id)){
                                productIdToOPNMap.put(prod.Id,prod.Core_OPN__c);
                            }
                            if(opnSet.contains(prod.Core_OPN__c)){
                                opnToProductIdMap.put(prod.Core_OPN__c,prod.Id);
                                productIdSet.add(prod.Id);
                            }
                            if(prod.IsActive  && prod.Core_Item_Quotable_Ind__c){
                                productsRegisterable.add(prod.Id);
                            }
                            orderFlagInd.put(prod.Id, prod.Core_Item_Orderable_Ind__c);
                        }
                    }
                    for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                        if(quoteLine.SBQQ__Product__c == null && quoteLine.core_cpq_product_nm__c== null && opnToProductIdMap.containsKey(quoteLine.core_cpq_opn__c)){
                            quoteLine.SBQQ__Product__c=opnToProductIdMap.get(quoteLine.core_cpq_opn__c);
                            quoteLine.core_cpq_product_nm__c=opnToProductIdMap.get(quoteLine.core_cpq_opn__c);
                            prodId.add(opnToProductIdMap.get(quoteLine.core_cpq_opn__c));
                        }
                        
                    }
                    Map<id,Core_Design_Registration_Product__c> drpDensityMap = new Map<id,Core_Design_Registration_Product__c>();
                    Map<id,product2> prodDensityMap=new Map<id,product2>();
                    Map<id,SBQQ__Quote__c> quoteDDRMap = new Map<id,sbqq__quote__c>([SELECT Id, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Core_Design_Registration_Id__c, SBQQ__Opportunity2__r.Core_Design_Registration_Id__r.Name, core_cpq_quote_type_nm__c from SBQQ__Quote__c WHERE Id IN :qId ]);  
                      //PSG System user validation pass bypass
                     
                         
                    if(!prodId.isEmpty() && Label.PSG_System_User != UserInfo.getUserId()){
                        prodDensityMap = new Map<id,product2>([SELECT Id, Name, Core_OPN__c, Core_Product_Density_Value__c, Core_Item_Orderable_Ind__c, Core_Item_Quotable_Ind__c, Core_Product_Type_Nm__c, Core_BU_Operation_Code__c, Core_Item_Class_Nm__c,Core_Hierarchy_ID__c,
                                                               Core_Code_Name__c,Core_Product_Series__c,Core_Product_Group__c,Core_Product_Org__c,Core_Product_Family__c from PRODUCT2 where id IN :prodId ]);
                        if(!prodDensityMap.isEmpty()){
                            for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                                if(prodDensityMap.containsKey(quoteLine.SBQQ__Product__c)){
                                    if(quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteDDRMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c !='Budgetary'){
                                        if(quoteLine.SBQQ__Product__c!=null && prodDensityMap.containsKey(quoteLine.SBQQ__Product__c) && !prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Orderable_Ind__c){
                                            quoteLine.addError('Selected Opn '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' is not Orderable and can only be added to Budgetary Quote');
                                        }
                                    } 
                                    if(quoteLine.SBQQ__Product__c!=null && !prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Quotable_Ind__c){
                                        quoteLine.addError('Selected Opn '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' is not Quotable and cannot be added');
                                    }
                                    if(quoteLine.SBQQ__Product__c!=null){
                                        if(quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && (prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Type_Nm__c == NULL || prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Org__c != 'Sales')){
                                            quoteLine.addError('Selected Opn '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' does not have the required configuration for FPGA Product Type/Product Org. Please contact Product Marketing or your system admin'); 
                                        }
                                        
                                        if(quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteDDRMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c =='Tools' && prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Type_Nm__c != 'Tool'){
                                            quoteLine.addError('Selected Opn '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' is not a Tools product and cannot be added to a Tools Quote.');
                                        }
                                            
                                        
                                        // New Logic According to User Story TWC3133-2759
                                        if(quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteDDRMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c =='Tools' && prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Type_Nm__c == 'Tool'){
                                            if(!((prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c=='HF' &&  prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c == 'BD') || 
                                                 (prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c=='HJ' &&  prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c == 'SV') ||
                                                 (prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c=='PS' &&  prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c == 'SV'))){
                                                     quoteLine.addError('Selected OPN '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' does not have the required configuration for Product Class/Operation Code. Please contact Product Marketing or your system admin');
                                                 }
                                        }else if(quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteDDRMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c =='Design Win' && prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Type_Nm__c == 'Tool'){
                                            if(!((prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c=='KP' &&  prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c == 'BD')||
                                                 (prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c=='PS' &&  prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c == 'SV'))){
                                                     quoteLine.addError('Selected Tools OPN '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' cannot be added to Design Win Quote. Please create Tools Quote to proceed.'+' (Note: The only Tools product that can be added to Design Win Quotes are specific PAC Cards and eASIC NREs)');
                                                 }
                                        }else if(quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteDDRMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c =='Transfer Pricing' && prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Type_Nm__c == 'Tool'){
                                            if(!(prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c=='KP' &&  prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c == 'BD')){
                                                quoteLine.addError('Selected Tools OPN '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' cannot be added to Transfer Pricing Quote. Please create Tools Quote to proceed.'+' (Note: The only Tools product that can be added to Transfer Pricing Quotes are specific PAC Cards)');
                                            }
                                        }
                                    }
                                }
                            }                            
                        }
                    }
                    
                    // Added to check PSG Restricted Product on Product extended attribute // start
                    for(Core_Product_Ext_Attribute__c Restrictedprod : [Select Id,Core_Product_Id__c,PSG_Restricted_Product__c from Core_Product_Ext_Attribute__c where Core_Product_Id__c IN: productIdSet LIMIT :Limits.getLimitDmlRows()]){
                                                                         psgrestrictedprodMap.put(Restrictedprod.Core_Product_Id__c, Restrictedprod.PSG_Restricted_Product__c);
                                                                     }
                    for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                        if(!psgrestrictedprodMap.isEmpty() && psgrestrictedprodMap.containsKey(quoteLine.SBQQ__Product__c)){    
                            quoteLine.core_cpq_PSG_Restricted_Product__c = psgrestrictedprodMap.get(quoteLine.SBQQ__Product__c);
                        } 
                        
                    }
                    // end
                    // PRID is not linked with the Associated parent Quote check
                    if(!QLparentQuoteIdSet.isEmpty()){
                        for(SBQQ__QuoteLine__c quoteline:[select id,SBQQ__Quote__c,core_cpq_PRID__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in:QLparentQuoteIdSet]){
                            if(quoteline.core_cpq_PRID__c <> null){
                                QuotePRIDSet.add(quoteline.SBQQ__Quote__c + '' + quoteline.core_cpq_PRID__c);
                            }
                        }
                        
                    }
                    system.debug('QuotePRIDSet-->'+QuotePRIDSet);
                    if(!drpId.isEmpty() && Label.PSG_System_User != UserInfo.getUserId()){
                        drpDensityMap = new Map<id,Core_Design_Registration_Product__c>([SELECT Id, Name, Core_Design_Registration_Id__c, Core_Product_Id__r.Core_Product_Density_Value__c,core_cpq_OPN_Concatenation_txt__c   FROM Core_Design_Registration_Product__c WHERE Id IN :drpId ]);
                         
                          
                        if(!drpDensityMap.isEmpty()){
                            for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                                if(!quoteDDRMap.isEmpty() && quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteDDRMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Opportunity2__c !=null){
                                    if(drpDensityMap.containsKey(quoteLine.core_cpq_design_registration_product__c)){
                                        if(quoteDDRMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Opportunity2__r.Core_Design_Registration_Id__c != drpDensityMap.get(quoteLine.core_cpq_design_registration_product__c).Core_Design_Registration_Id__c){
                                            quoteLine.addError(quoteLine.Name +': Design Registration Product selected does not match the assigned Quote Design Registration');
                                        }
                                    }
                                }
                                if(!quoteDDRMap.isEmpty() && quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteDDRMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Opportunity2__c == null && drpDensityMap.containsKey(quoteLine.core_cpq_design_registration_product__c) && quoteLine.core_cpq_design_registration_product__c != null ){
                                    quoteLine.addError(Label.PSG_DRP_Error_Message);
                                }  
                                /*if(quoteLine.SBQQ__Product__c != null && quoteLine.core_cpq_design_registration_product__c != null){ 
                                    String concatOPN='';
                                    if(prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Hierarchy_ID__c == '59'){
                                        concatOPN=(prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Code_Name__c==null?'':prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Code_Name__c)+' - '+(prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Density_Value__c==null?'':prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Density_Value__c);
                                    }else if(prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Hierarchy_ID__c == '43'){
                                        concatOPN=(prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Series__c==null?'':prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Series__c)+' - '+(prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Group__c==null?'':prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Group__c);
                                    }
                                    
                                    if(concatOPN != '' && drpDensityMap.containsKey(quoteLine.core_cpq_design_registration_product__c) && concatOPN.trim() != drpDensityMap.get(quoteLine.core_cpq_design_registration_product__c).core_cpq_OPN_Concatenation_txt__c.trim()){
                                        quoteLine.addError(Label.PSG_QL_DRP_ConcatOPN_Error.replace('PRODUCT_OPN_HERE',prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c));
                                    }
                                }*/
                            }                        
                        }
                    }
                    
                    
                    
                    String queryStr2 = '';
                    if(!drpDistyIdSet.isEmpty()){
                        queryStr2 = 'SELECT Id,Name FROM Core_Design_Registration_Product__c WHERE Name IN :drpDistyIdSet';
                    }
                    if(!drpIdSet.isEmpty()){
                        if(String.isBlank(queryStr2)){
                            queryStr2 = 'SELECT Id,Name FROM Core_Design_Registration_Product__c WHERE Id IN :drpIdSet';
                        }else{
                            queryStr2 += ' OR Id IN: drpIdSet';                    
                        }
                    }
                    Map<String,Id> drpDistyToDrpIdMap = new Map<String,Id>();
                    Map<Id,String> drpIdTodrpDistyMap = new Map<Id,String>();
                    if(String.isNotBlank(queryStr2)){
                        for(Core_Design_Registration_Product__c drp : Database.query(queryStr2)){
                            if(drpIdSet.contains(drp.Id)){
                                drpIdTodrpDistyMap.put(drp.Id,drp.Name);
                            }
                            if(drpDistyIdSet.contains(drp.Name)){
                                drpDistyToDrpIdMap.put(drp.Name,drp.Id);
                            }    
                        }
                    }
                    Set<Id> oppIdSet = new Set<Id>();
                    if(!quoteIdSet.isEmpty()){
                        for(SBQQ__Quote__c quote : [SELECT Id,core_cpq_date_submitted_dt__c,SBQQ__Account__c,core_cpq_end_customer_nm__r.Core_Account_PSG_Tier__c,
                                                    core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c,createddate,core_cpq_price_book_nm__c,core_cpq_account_tier__c,SBQQ__Opportunity2__r.Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c,
                                                    SBQQ__Opportunity2__c,SBQQ__PriceBook__c,core_cpq_sap_ecp_nm__c,core_cpq_quote_type_nm__c, core_cpq_end_customer_nm__r.Core_Geo__c, SBQQ__Opportunity2__r.Core_Design_Registration_Id__r.core_cpq_approved_date__c,
                                                    core_cpq_margin_geo_txt__c,core_cpq_account_program__c,core_cpq_ddr_nm__c from SBQQ__Quote__c where Id IN: quoteIdSet LIMIT :Limits.getLimitDmlRows()]){
                            quoteIdToQuoteMap.put(quote.Id,quote);
                            if(quote.core_cpq_quote_type_nm__c == 'Design Win' && quote.SBQQ__Opportunity2__c != null){
                                oppIdSet.add(quote.SBQQ__Opportunity2__c);
                            }                         
                            if(quote.core_cpq_price_book_nm__c != null){
                                priceBookIdSet.add(quote.core_cpq_price_book_nm__c);
                                quoteMap.put(quote.Id,quote);
                            }
                            if(quote.core_cpq_account_tier__c != null){
                                accountTierSet.add(quote.core_cpq_account_tier__c);
                            }
                            //Changes made for ParterAlliance : value coming with ; - Bishal Singh
                            if(quote.core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c != null){
                                accountAllianceSet.addAll(quote.core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c.split(';'));
                            }
                            if(quote.core_cpq_margin_geo_txt__c != null){
                                geoSet.add(quote.core_cpq_margin_geo_txt__c);
                            }
                            if(quote.core_cpq_end_customer_nm__c != null && quote.core_cpq_end_customer_nm__r?.Core_Geo__c != null){
                                quoteIdToEcMap.put(quote.Id, quote.core_cpq_end_customer_nm__r.Core_Geo__c);
                            }
                        }
                    }
                    
                    Map<Id,Set<Id>> oppToExistingOPNMap = new Map<Id,Set<Id>>();
                    Map<Id,String> OPNToQuoteNameMap = new Map<Id,String>();
                    Map<Id,String> OPNToOptyNameMap = new Map<Id,String>();
                    if(!oppIdSet.isEmpty()){
                        for(SBQQ__QuoteLine__c quoteLine : [SELECT Id,SBQQ__Product__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,SBQQ__Quote__r.Name,
                                                            SBQQ__Quote__r.core_cpq_quote_type_nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.SBQQ__Opportunity2__c 
                                                            IN: oppIdSet and SBQQ__Quote__r.core_cpq_quote_type_nm__c = 'Design Win' and 
                                                            SBQQ__Quote__r.core_cpq_active_cb__c = true and SBQQ__Quote__c Not IN :quoteIdSet LIMIT :Limits.getLimitDmlRows()]){
                            if(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c != null){                             
                                if(!oppToExistingOPNMap.containsKey(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c)){
                                    oppToExistingOPNMap.put(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c,new Set<Id>{quoteLine.SBQQ__Product__c});
                                    OPNToQuoteNameMap.put(quoteLine.SBQQ__Product__c,quoteLine.SBQQ__Quote__r.Name);
                                    OPNToOptyNameMap.put(quoteLine.SBQQ__Product__c,quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name);
                                }else{
                                    oppToExistingOPNMap.get(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c).add(quoteLine.SBQQ__Product__c);
                                    OPNToQuoteNameMap.put(quoteLine.SBQQ__Product__c,quoteLine.SBQQ__Quote__r.Name);
                                    OPNToOptyNameMap.put(quoteLine.SBQQ__Product__c,quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name);
                                }
                            }
                        }
                    }
                    if(!productIdSet.isEmpty()){
                        fetchPricingDetails(productIdSet,productOPNSet,uniqueIdToPriceBookEntryMap,productToFWDMapStartDt,
                                            smiFlagInd,productToMSVPMap,prodToolTypeMap,authCodeProductMap,priceBookIdSet,accountTierSet,
                                            accountAllianceSet,geoSet,uniqueIdToListPriceMap);
                    } 
                    try{
                    for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                        String prodFamily = '';
                        price_prid__c prid = new price_prid__c();
                        if(quoteLine.SBQQ__Product__c != null){
                            prodFamily = prodDensityMap.get(quoteLine.SBQQ__Product__c)?.Core_Product_Family__c;
                        }
                        if(quoteLine.core_cpq_PRID__c != null){
                            prid = pridMap.get(quoteLine.core_cpq_PRID__c);                            
                        }
                        if(quoteLine.SBQQ__Product__c != null && prodToolTypeMap.containsKey(quoteLine.SBQQ__Product__c)){
                            quoteLine.core_cpq_Tool_Type__c = prodToolTypeMap.get(quoteLine.SBQQ__Product__c);
                        }
                        if(quoteLine.SBQQ__Product__c != null && authCodeProductMap.containsKey(quoteLine.SBQQ__Product__c)){
                            quoteLine.core_cpq_authcode_product_txt__c = authCodeProductMap.get(quoteLine.SBQQ__Product__c);
                        }
                        /*if(quoteLine.core_cpq_opn__c != null && opnToProductIdMap.containsKey(quoteLine.core_cpq_opn__c)){
                            quoteLine.SBQQ__Product__c = opnToProductIdMap.get(quoteLine.core_cpq_opn__c);
                        }*/
                        if(quoteLine.SBQQ__Product__c != null && productIdToOPNMap.containsKey(quoteLine.SBQQ__Product__c)){     
                            quoteLine.core_cpq_opn__c = productIdToOPNMap.get(quoteLine.SBQQ__Product__c);
                        }
                        if(quoteLine.core_cpq_altera_reg_txt__c != null && drpDistyToDrpIdMap.containsKey(quoteLine.core_cpq_altera_reg_txt__c)){
                            quoteLine.core_cpq_design_registration_product__c = drpDistyToDrpIdMap.get(quoteLine.core_cpq_altera_reg_txt__c);
                        }
                        if(quoteLine.core_cpq_design_registration_product__c != null && drpIdTodrpDistyMap.containsKey(quoteLine.core_cpq_design_registration_product__c)){     
                            quoteLine.core_cpq_altera_reg_txt__c = drpIdTodrpDistyMap.get(quoteLine.core_cpq_design_registration_product__c);
                        }
                        if(smiFlagInd.containsKey(quoteLine.SBQQ__Product__c)){
                            quoteLine.core_cpq_smi_flag_ind__c = smiFlagInd.get(quoteLine.SBQQ__Product__c);
                        }
                        if(orderFlagInd.containsKey(quoteline.SBQQ__Product__c)){
                            quoteLine.core_cpq_orderable_ind__c = orderFlagInd.get(quoteLine.SBQQ__Product__c);
                        }
                        if(quoteLine.core_cpq_quote_type__c == 'Transfer Pricing' &&  quoteLine.core_cpq_parent_quote__c != null && quoteLine.core_cpq_PRID__c != null && (!QuotePRIDSet.contains(quoteLine.core_cpq_parent_quote__c + ''+ quoteLine.core_cpq_PRID__c))){
           
                            quoteLine.adderror('PRID is not linked with the Associated Parent Quote.');    
                        }
                        if(quoteIdToQuoteMap.containsKey(quoteLine.SBQQ__Quote__c)){
                            quoteLine.core_cpq_account_nm__c = quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Account__c;
                            quoteLine.core_cpq_sap_ecp_nm__c = quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_sap_ecp_nm__c;
                            if(quoteLine.core_cpq_PRID__c != null && pridMap.containsKey(quoteLine.core_cpq_PRID__c) && quoteLine.core_cpq_sap_ecp_nm__c != pridMap.get(quoteLine.core_cpq_PRID__c).core_cpq_sap_ecp_nm__c){
                                quoteLine.core_cpq_PRID__c =null;
                            }
                        }
                        if(quoteLine.Core_OPN__c != null){
                            Boolean forwardCostMatchFound = false;
                            if(productToFWDMapStartDt.containsKey(quoteline.Core_OPN__c)){
                                for(Date fcStartDate : productToFWDMapStartDt.get(quoteline.Core_OPN__c).keySet()){
                                    if(fcStartDate <= quoteLine.core_cpq_price_eligibility_date_dt__c &&
                                      (productToFWDMapStartDt.get(quoteLine.Core_OPN__c).get(fcStartDate)).core_cpq_fc_end_date_dt__c
                                       >= quoteLine.core_cpq_price_eligibility_date_dt__c){
                                          quoteLine.price_std_fwd_cost_amt__c = (productToFWDMapStartDt.get(quoteLine.Core_OPN__c).get(fcStartDate)).price_forward_cost_amt__c; 
                                          forwardCostMatchFound = true;
                                          break;
                                    }
                                }
                            }
                            if(!forwardCostMatchFound){
                                quoteLine.price_std_fwd_cost_amt__c = 0; 
                            }
                        }
                        //if(!quoteLine.isClone()){
                            /*if(quoteIdToEcMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteIdToQuoteMap.containsKey(quoteLine.SBQQ__Quote__c) && familyToDistyMarginMap.containsKey(prodDensityMap.get(quoteLine.SBQQ__Product__c)?.Core_Product_Family__c +'_'+ quoteIdToEcMap.get(quoteLine.SBQQ__Quote__c) +'_'+ quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_account_program__c)
                               && quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_ddr_nm__c != null && quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c)?.SBQQ__Opportunity2__r?.Core_Design_Registration_Id__r?.Core_Design_Registration_Status_Nm__c == 'Approved'
                               && quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c)?.SBQQ__Opportunity2__r?.Core_Design_Registration_Id__r?.core_cpq_approved_date__c >= familyToDistyMarginMap.get(prodDensityMap.get(quoteLine.SBQQ__Product__c)?.Core_Product_Family__c +'_'+ quoteIdToEcMap.get(quoteLine.SBQQ__Quote__c) +'_'+ quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_account_program__c).core_Design_Reg_Approved_Date__c){
                                        quoteLine.core_cpq_distributor_margin_pct__c = (familyToDistyMarginMap.get(prodDensityMap.get(quoteLine.SBQQ__Product__c)?.Core_Product_Family__c +'_'+ quoteIdToEcMap.get(quoteLine.SBQQ__Quote__c) +'_'+ quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_account_program__c).core_cpq_Disty_Margin_Pct__c)?.setScale(1);
                                        quoteLine.core_cpq_previous_distributor_margin_pct__c = (familyToDistyMarginMap.get(prodDensityMap.get(quoteLine.SBQQ__Product__c)?.Core_Product_Family__c +'_'+ quoteIdToEcMap.get(quoteLine.SBQQ__Quote__c) +'_'+ quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_account_program__c).core_cpq_Disty_Margin_Pct__c)?.setScale(1);
                                        if(quoteLine.core_cpq_distributor_margin_pct__c != null && quoteLine.price_suggested_resale_amt__c != null){
                                            quoteLine.price_brokencost_amt__c = (quoteLine.price_suggested_resale_amt__c - (quoteLine.price_suggested_resale_amt__c * (quoteLine.core_cpq_distributor_margin_pct__c/100)))?.setScale(2);
                                            quoteLine.price_previous_brokencost_amt__c = (quoteLine.price_suggested_resale_amt__c - (quoteLine.price_suggested_resale_amt__c * (quoteLine.core_cpq_distributor_margin_pct__c/100)))?.setScale(2);
                                        } 
                            }
                            else{*/
                                updateDistiMargin(quoteIdToQuoteMap,quoteLine,productsRegisterable,prodFamily,prid,
                                          existingPartnerProgram,smiFlagInd,orderFlagInd);
                            //}                            
                        //}
                        
                        if(quoteIdToQuoteMap.containsKey(quoteLine.SBQQ__Quote__c) && uniqueIdToPriceBookEntryMap.containsKey(''+quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c  + quoteLine.SBQQ__Product__c)){
                            quoteLine.price_disty_cost_nbr__c = uniqueIdToPriceBookEntryMap.get(''+quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).price_disty_cost__c;
                            quoteLine.SBQQ__PricebookEntryId__c = uniqueIdToPriceBookEntryMap.get(''+quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).Id;                           
                            quoteLine.core_cpq_multiple_qty_nbr__c = uniqueIdToPriceBookEntryMap.get(''+quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).core_cpq_multiple_order_quantity__c;
                            quoteLine.core_cpq_minimum_qty__c = uniqueIdToPriceBookEntryMap.get(''+quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).core_cpq_minimum_order_qty__c;
                            string key = uniqueIdToPriceBookEntryMap.get(''+quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).Id;
                            if(!uniqueIdToListPriceMap.isEmpty() && uniqueIdToListPriceMap.containsKey(key)){
                                for(core_cpq_list_price__c lp : uniqueIdToListPriceMap.get(key)){
                                    if(quoteLine.SBQQ__Quantity__c >= lp.core_cpq_lowerbound_qty__c && quoteLine.SBQQ__Quantity__c <= lp.core_cpq_upperbound_qty__c){
                                        quoteLine.SBQQ__ListPrice__c = lp.core_cpq_list_price_amt__c;
                                    }
                                }
                            }
                        }else{
                            quoteLine.price_disty_cost_nbr__c = 0;
                            quoteLine.SBQQ__ListPrice__c = 0; 
                        }         
                        if(productToMSVPMap.containsKey(quoteLine.SBQQ__Product__c)){
                            for(Date effectiveDate : (productToMSVPMap.get(quoteLine.SBQQ__Product__c)).keySet()){
                                if(effectiveDate <= (quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c)).createddate){
                                    quoteLine.price_msvp_l1_amt__c = (productToMSVPMap.get(quoteLine.SBQQ__Product__c)).get(effectiveDate).price_level_1_amt__c;
                                    quoteLine.price_msvp_l2_amt__c = (productToMSVPMap.get(quoteLine.SBQQ__Product__c)).get(effectiveDate).price_level_2_amt__c;
                                    break;
                                }
                            }
                        }
                          //PSG System user validation pass bypass
                        
                        if(Label.PSG_System_User != UserInfo.getUserId() && quoteIdToQuoteMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c == 'Design Win' 
                           && quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Opportunity2__c != null &&
                           oppToExistingOPNMap.containsKey(quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Opportunity2__c)
                        &&  oppToExistingOPNMap.get(quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Opportunity2__c).
                             contains(quoteLine.SBQQ__Product__c) && OPNToOptyNameMap.get(quoteLine.SBQQ__Product__c) != null){
                                
                                quoteLine.addError('OPN '+ quoteLine.Core_OPN__c + ' already exist in an another Active Design Win Quote '+
                                OPNToQuoteNameMap.get(quoteLine.SBQQ__Product__c)+' for the same Opportunity '+
                                OPNToOptyNameMap.get(quoteLine.SBQQ__Product__c));
                         
                    }
                        if(quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c)?.core_cpq_quote_type_nm__c != 'Budgetary'){
                            if(quoteLine.core_cpq_quote_line_type_txt__c == 'AVP'){
                                quoteLine.core_cpq_unique_id__c = ''+ quoteLine.SBQQ__Quote__c                                                           
                                    + quoteLine.recordtypeId
                                    + quoteLine.SBQQ__Product__c
                                    + quoteLine.core_cpq_quote_line_type_txt__c 
                                    + quoteLine.core_cpq_lower_bound_qty_qty__c?.intValue() 
                                    + quoteLine.core_cpq_upper_bound_qty_nbr__c?.intValue()
                                    +quoteLine.core_cpq_price_eligibility_date_dt__c;
                            }else{
                                quoteLine.core_cpq_unique_id__c = ''+ quoteLine.SBQQ__Quote__c                                                           
                                    + quoteLine.recordtypeId
                                    + quoteLine.SBQQ__Product__c
                                    + quoteLine.core_cpq_quote_line_type_txt__c 
                                    + quoteLine.core_cpq_lower_bound_qty_qty__c?.intValue() 
                                    + quoteLine.core_cpq_upper_bound_qty_nbr__c?.intValue();
                            }
                        }else{
                            quoteLine.core_cpq_unique_id__c =null;
                        }
                        quoteLine.core_cpq_disti_margin_onload__c = quoteLine.core_cpq_distributor_margin_pct__c;           
                        quoteLine.core_cpq_disti_margin_changed__c = false;
                                                          
                    }
                    //added for unique bug Oninsert
                    Map<id,List<SBQQ__QuoteLine__c>> quoteToQuoteLineMap=new Map<id,List<SBQQ__QuoteLine__c>>();
                    if(!qId.isEmpty()){
                        for(SBQQ__QuoteLine__c quoteLineRec : [SELECT Id,SBQQ__Quote__c,core_cpq_unique_id__c,recordtypeId,SBQQ__Product__c,
                                                                core_cpq_quote_line_type_txt__c,core_cpq_lower_bound_qty_qty__c
                                                                from SBQQ__QuoteLine__c where SBQQ__Quote__c IN: qId LIMIT :Limits.getLimitDmlRows()]){
                                if(!quoteToQuoteLineMap.containsKey(quoteLineRec.SBQQ__Quote__c)){
                                    quoteToQuoteLineMap.put(quoteLineRec.SBQQ__Quote__c,new List<SBQQ__QuoteLine__c>{quoteLineRec});
                                }else{
                                    quoteToQuoteLineMap.get(quoteLineRec.SBQQ__Quote__c).add(quoteLineRec);
                                }                                        
                        }
                    }
                          //PSG System user validation pass bypass
                         if(Label.PSG_System_User != UserInfo.getUserId()){
                        
                    Set<String> uniqueIdSet = new Set<String>();    
                             for(SBQQ__QuoteLine__c quoteLineRec : quoteLineList){
                                 if(quoteLineRec.core_cpq_unique_id__c != null){
                                     if(uniqueIdSet.contains(quoteLineRec.core_cpq_unique_id__c)){
                                         quoteLineRec.addError('Duplicated Lines found. Please remove and try again.');
                                     }else{
                                         uniqueIdSet.add(quoteLineRec.core_cpq_unique_id__c);
                                     }
                                     if(quoteToQuoteLineMap.containsKey(quoteLineRec.SBQQ__Quote__c)){
                                         for(SBQQ__QuoteLine__c quoteLineDBRec : quoteToQuoteLineMap.get(quoteLineRec.SBQQ__Quote__c)){
                                             if((quoteLineDBRec.core_cpq_unique_id__c == quoteLineRec.core_cpq_unique_id__c)){
                                                 quoteLineRec.addError('Duplicated Lines found. Please remove and try again.');
                                             }
                                         }
                                     }
                                 }
                                 
                             }  
                    }
                }
                    catch(Exception ex){
                        PSG_Utility.logError(ex);
                        
                        throw ex;
                       /* for(Integer i=0;i<quoteLineList.size()-1;i++){
                        for(Integer j=i+1;j<quoteLineList.size();j++){
                            if(quoteLineList[i].core_cpq_unique_id__c==quoteLineList[j].core_cpq_unique_id__c && quoteLineList[i].core_cpq_unique_id__c!=null && quoteLineList[j].core_cpq_unique_id__c!=null ){
                                quoteLineList[i].addError('Duplicates Exists for Line No'+(i+1));
                                break;
                                }
                        }
                    }*/
                        
                    }
                    
                }
                if(isUpdate){
                    
                    Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap = new Map<Id,SBQQ__Quote__c>();
                    Map<Id,String> quoteIdToQuoteTypeMap = new Map<Id,String>();
                    List<SBQQ__Quote__c> qlist = new List<SBQQ__Quote__c>();
                    Set<Id> quoteId = new Set<Id>();    
                    Set<Id> quoteLineId = new Set<Id>();  
                    Set<Id> PRIDSet = new Set<Id>();
                    
                    Map<Id,Decimal> quoteLinetoSourceIntelMarginMap = new Map<Id,Decimal>();
                    Map<Id,Decimal> quoteLinetoSourceDistiMarginMap = new Map<Id,Decimal>();
                    Map<Id,Decimal> quoteLinetoSourcePeakAnnualMap = new Map<Id,Decimal>();
                    Set<Id> selectedPRIDSet = new Set<Id>(); 
                    Set<Id> sourceIdSet = new Set<Id>();

                    Set<Id> quoteLineIdPRIDBlankSet = new Set<Id>();
                    Set<Id> reviewerIdSet = new Set<Id>();
                    Set<id> drpId = new Set<id>();
                    Set<id> prodId = new Set<id>();
                    Boolean IsDistyProdUpdate=false;
                    for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                        if(!quoteLineList.isEmpty()){
                            negativeValueCheck(quoteLine,null);
                        }
                        quoteLineIdSet.add(quoteLine.Id);
                        quoteLine.price_suggested_resale_amt__c = quoteLine.price_suggested_resale_amt__c ==null?0: quoteLine.price_suggested_resale_amt__c.setScale(2);
                        quoteLine.price_previous_suggested_resale_amt__c=quoteLine.price_suggested_resale_amt__c;
                        quoteLine.core_cpq_distributor_margin_pct__c= quoteLine.core_cpq_distributor_margin_pct__c == null ? 0 : (quoteLine.core_cpq_distributor_margin_pct__c)?.setScale(1);
                        quoteLine.core_cpq_previous_distributor_margin_pct__c = (quoteLine.core_cpq_distributor_margin_pct__c);
                        quoteLine.core_cpq_previous_margin_exception_txt__c  = quoteLine.core_cpq_margin_exception_txt__c;
                        if(quoteLine.SBQQ__Quantity__c == null){
                            quoteLine.SBQQ__Quantity__c = 1;
                            quoteLine.core_cpq_upper_bound_qty_nbr__c = 1;
                        }
                        if(quoteLine.SBQQ__Source__c != null){
                            sourceIdSet.add(quoteLine.SBQQ__Source__c);
                        }  
                        if(quoteLine.price_suggested_resale_amt__c != null && quoteLine.price_msvp_l2_amt__c != null){
                            quoteLine.core_cpq_gp_msvpl2_nm__c = (quoteLine.price_suggested_resale_amt__c - quoteLine.price_msvp_l2_amt__c)?.setScale(2);
                        }
                        
                         
                        
                        if(userIdToRoleMap.containsKey(userInfo.getUserId()) && 
                        userIdToRoleMap.get(userInfo.getUserId()) == 'SOS' 
                        && quoteline.price_goal_price_amt__c != oldMap.get(quoteLine.Id).price_goal_price_amt__c){
                            quoteline.price_suggested_resale_amt__c = (quoteline.price_goal_price_amt__c)?.setScale(2);
                        }
                        quoteIdSet.add(quoteLine.SBQQ__Quote__c);
                        if(isInternal){
                            quoteId.add(quoteLine.SBQQ__Quote__c);
                        }
                        if(quoteline.core_cpq_PRID__c != null){
                            PRIDSet.add(quoteline.core_cpq_PRID__c);
                        }
                        if((oldMap.get(quoteLine.Id).core_cpq_PRID__c != quoteline.core_cpq_PRID__c) && quoteline.core_cpq_PRID__c == null){
                            quoteLineIdPRIDBlankSet.add(quoteline.Id);
                        }
                        if(quoteLine.core_cpq_product_nm__c != oldMap.get(quoteLine.Id).core_cpq_product_nm__c){
                            quoteLine.SBQQ__Product__c = quoteLine.core_cpq_product_nm__c;
                        }
                        
                        
                        if(quoteLine.SBQQ__Product__c != null){
                            quoteLine.core_cpq_product_nm__c = quoteLine.SBQQ__Product__c;
                            productIdSet.add(quoteLine.SBQQ__Product__c);
                            productOPNSet.add(quoteLine.Core_OPN__c);
                        }
                        
                        if((oldMap.get(quoteLine.Id).core_cpq_production_dt__c != quoteline.core_cpq_production_dt__c) ){
                            quoteLine.core_cpq_price_eligibility_date_dt__c = quoteLine.core_cpq_production_dt__c;
                        }else if((oldMap.get(quoteLine.Id).core_cpq_price_eligibility_date_dt__c != quoteline.core_cpq_price_eligibility_date_dt__c)){
                            quoteLine.core_cpq_production_dt__c = quoteLine.core_cpq_price_eligibility_date_dt__c;
                        }
                        if(String.isNotBlank(quoteLine.core_cpq_qcp_error_nm__c) && !System.isQueueable() && Label.PSG_System_User != UserInfo.getUserId() && oldMap.get(quoteLine.Id).core_cpq_follow_on_process_cb__c == quoteLine.core_cpq_follow_on_process_cb__c){
                            String errorMessage = quoteLine.core_cpq_qcp_error_nm__c;
                            quoteLine.addError(errorMessage.replace(':', '\n'));
                            break;
                        }
                        if(quoteLine.SBQQ__Product__c != null){ //&& quoteLine.SBQQ__Product__c != oldMap.get(quoteLine.Id).SBQQ__Product__c){
                            productId2Set.add(quoteLine.SBQQ__Product__c);
                        }else if(quoteLine.core_cpq_opn__c != null && quoteLine.core_cpq_opn__c != oldMap.get(quoteLine.Id).core_cpq_opn__c){
                            opnSet.add(quoteLine.core_cpq_opn__c); 
                        }
                        //added for opn bug by ranjit
                        if(quoteLine.SBQQ__Product__c != null && quoteLine.core_cpq_opn__c != oldMap.get(quoteLine.Id).core_cpq_opn__c && quoteLine.SBQQ__Product__c == oldMap.get(quoteLine.Id).SBQQ__Product__c){
                            opnSet.add(quoteLine.core_cpq_opn__c);
                            IsDistyProdUpdate=true;
                        }
                        if(quoteLine.core_cpq_design_registration_product__c != null && quoteLine.core_cpq_design_registration_product__c != oldMap.get(quoteLine.Id).core_cpq_design_registration_product__c){
                            drpIdSet.add(quoteLine.core_cpq_design_registration_product__c);
                        }else if(quoteLine.core_cpq_altera_reg_txt__c != null && quoteLine.core_cpq_altera_reg_txt__c != oldMap.get(quoteLine.Id).core_cpq_altera_reg_txt__c){
                            drpDistyIdSet.add(quoteLine.core_cpq_altera_reg_txt__c); 
                        }
                        
                        if(quoteLine.core_cpq_PRID__c != null){
                            selectedPRIDSet.add(quoteLine.core_cpq_PRID__c);
                        }
                        if(quoteLine.core_cpq_reviewer__c != null){
                            reviewerIdSet.add(quoteLine.core_cpq_reviewer__c);
                        }
                        
                        //Added by Bishal Singh - PRB10058342
                        if(quoteLine.core_cpq_lower_bound_qty_qty__c == null && (oldMap.get(quoteLine.Id).core_cpq_lower_bound_qty_qty__c == quoteLine.core_cpq_lower_bound_qty_qty__c)){
                            quoteLine.core_cpq_previous_lower_bound_qty_nbr__c = 1;
                            quoteLine.core_cpq_lower_bound_qty_qty__c = 1;
                        }
                        
                        if(quoteLine.core_cpq_upper_bound_qty_nbr__c == null && (oldMap.get(quoteLine.Id).core_cpq_upper_bound_qty_nbr__c == quoteLine.core_cpq_upper_bound_qty_nbr__c)){
                            quoteLine.core_cpq_previous_upper_bound_qty_nbr__c = 1;
                            quoteLine.core_cpq_upper_bound_qty_nbr__c = quoteLine.SBQQ__Quantity__c == 0 ? 0 : quoteLine.SBQQ__Quantity__c + quoteLine.core_cpq_lower_bound_qty_qty__c - 1;
                        }
                        
                        if(quoteLine.SBQQ__Quantity__c == null && (oldMap.get(quoteLine.Id).SBQQ__Quantity__c == quoteLine.SBQQ__Quantity__c)){
                            quoteLine.core_cpq_lower_bound_qty_qty__c = 1;
                            quoteLine.core_cpq_upper_bound_qty_nbr__c = 1;
                        }
                        
                        if(quoteLine.core_cpq_reviewer__c != oldMap.get(quoteLine.Id).core_cpq_reviewer__c){
                            if(oldMap.get(quoteLine.Id).core_cpq_reviewer__c != null){
                                reviewerIdSet.add(quoteLine.core_cpq_reviewer__c);
                            }
                        }
                        quoteId.add(quoteLine.SBQQ__Quote__c);
                        if(quoteLine.core_cpq_design_registration_product__c != null){
                            drpId.add(quoteLine.core_cpq_design_registration_product__c);
                        }
                        if(quoteLine.SBQQ__Product__c != null){
                            prodId.add(quoteLine.SBQQ__Product__c);
                        }
                        quoteLineId.add(quoteLine.Id);
                        if(quoteLine.core_cpq_parent_quote__c != null){
                            QLparentQuoteIdSet.add(quoteLine.core_cpq_parent_quote__c);
                        }
                        
                    }
                    Map<id,SBQQ__Quote__c> quoteDDRMap = new Map<id,SBQQ__Quote__c>([SELECT Id, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Core_Design_Registration_Id__c, SBQQ__Opportunity2__r.Core_Design_Registration_Id__r.Name, core_cpq_quote_type_nm__c from SBQQ__Quote__c WHERE Id IN :quoteId ]);
                    Map<id,Core_Design_Registration_Product__c> drpDensityMap;
                    Map<id,Product2> prodDensityMap=new Map<id,Product2>();
                    if(!prodId.isEmpty() && Label.PSG_System_User != UserInfo.getUserId()){
                        if(IsDistyProdUpdate){
                           prodDensityMap = new Map<id,product2>([SELECT Id, Name, Core_OPN__c, Core_Product_Density_Value__c, Core_Item_Orderable_Ind__c, Core_Item_Quotable_Ind__c, Core_Product_Type_Nm__c, Core_BU_Operation_Code__c, Core_Item_Class_Nm__c, Core_Product_Org__c, Core_Product_Family__c from PRODUCT2 where Core_OPN__c IN :opnSet and Isactive=true]); 
                           
                        }else{
                           prodDensityMap = new Map<id,product2>([SELECT Id, Name, Core_OPN__c, Core_Product_Density_Value__c, Core_Item_Orderable_Ind__c, Core_Item_Quotable_Ind__c, Core_Product_Type_Nm__c, Core_BU_Operation_Code__c, Core_Item_Class_Nm__c, Core_Product_Org__c, Core_Product_Family__c from PRODUCT2 where id IN :prodId ]);  
                        }
                        
                        for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                              
                            
                          if(oldMap.get(quoteLine.Id).core_cpq_follow_on_process_cb__c == quoteLine.core_cpq_follow_on_process_cb__c){
                                if(!quoteDDRMap.isEmpty()){
                                    if(quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteDDRMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c !='Budgetary'){
                                        if(quoteLine.SBQQ__Product__c!=null && prodDensityMap.containsKey(quoteLine.SBQQ__Product__c) && !prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Orderable_Ind__c){
                                            quoteLine.addError('Selected Opn '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' Orderable flag is not Active');
                                        }
                                    } 
                                    if(quoteLine.SBQQ__Product__c!=null && prodDensityMap.containsKey(quoteLine.SBQQ__Product__c) && !prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Quotable_Ind__c){
                                        quoteLine.addError('Selected Opn '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' Quotable flag is not Active');
                                    }
                                    if(quoteLine.SBQQ__Product__c!=null && quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && prodDensityMap.containsKey(quoteLine.SBQQ__Product__c)){
                                        if(quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && (prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Type_Nm__c == NULL || prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Org__c != 'Sales')){
                                            quoteLine.addError('Selected Opn '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' FPGA Product Type should not be null And Product Org should be Sales'); 
                                        }
                                       
                                        if(quoteDDRMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c =='Tools' && prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Type_Nm__c != 'Tool'){
                                            quoteLine.addError('Selected Opn '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' - FPGA Product Type should be Tool for Tools Quote.');
                                        }
                                       /* if((quoteDDRMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c =='Design Win' || quoteDDRMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c =='Transfer Pricing') && prodDensityMap.containsKey(quoteLine.SBQQ__Product__c) && prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Type_Nm__c == 'Tool'){
                                            if(prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c != 'KP'){
                                                quoteLine.addError('Selected Opn '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' Operation(OP) Code should be KP.');
                                            }
                                            if(prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c != 'BD'){
                                                quoteLine.addError('Selected Opn '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' Item Class should be BD.');
                                            
                                        }
                                    }
                                        */
                                    
                                        if(quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteDDRMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c =='Tools' && prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Type_Nm__c == 'Tool'){
                                            if(!((prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c=='HF' &&  prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c == 'BD') || 
                                                 (prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c=='HJ' &&  prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c == 'SV') ||
                                                 (prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c=='PS' &&  prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c == 'SV'))){
                                                     
                                                     quoteLine.addError('Selected OPN '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' does not have the required configuration for Product Class/Operation Code. Please contact Product Marketing or your system admin');
                                                 }
                                        }else if(quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteDDRMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c =='Design Win' && prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Type_Nm__c == 'Tool'){
                                                   
                                            if(!((prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c=='KP' &&  prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c == 'BD')||
                                                 (prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c=='PS' &&  prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c == 'SV'))){
                                                     
                                                     quoteLine.addError('Selected Tools OPN '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' cannot be added to Design Win Quote. Please create Tools Quote to proceed.'+' (Note: The only Tools product that can be added to Design Win Quotes are specific PAC Cards and eASIC NREs)');
                                                 }
                                        }else if(quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteDDRMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c =='Transfer Pricing' && prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Product_Type_Nm__c == 'Tool'){
                                                  
                                            if(!(prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_BU_Operation_Code__c=='KP' &&  prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_Item_Class_Nm__c == 'BD')){
                                                
                                                quoteLine.addError('Selected Tools OPN '+ prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c + ' cannot be added to Transfer Pricing Quote. Please create Tools Quote to proceed.'+' (Note: The only Tools product that can be added to Transfer Pricing Quotes are specific PAC Cards)');
                                            }
                                        }
 
                                        
                                        
                                        
                                }
                            }
                        }
                    }
                    }
                    
                    // Added to check PSG Restricted Product on Product extended attribute // start
                    for(Core_Product_Ext_Attribute__c Restrictedprod : [Select Id,Core_Product_Id__c,PSG_Restricted_Product__c from Core_Product_Ext_Attribute__c where Core_Product_Id__c IN: productIdSet LIMIT :Limits.getLimitDmlRows()]){
                                                                         psgrestrictedprodMap.put(Restrictedprod.Core_Product_Id__c, Restrictedprod.PSG_Restricted_Product__c);
                                                                     }
                    for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                        if(!psgrestrictedprodMap.isEmpty() && psgrestrictedprodMap.containsKey(quoteLine.SBQQ__Product__c)){    
                            quoteLine.core_cpq_PSG_Restricted_Product__c = psgrestrictedprodMap.get(quoteLine.SBQQ__Product__c);
                        }
                        
                    }
                    // end
                    // PRID is not linked with the Associated parent Quote check
                    if(!QLparentQuoteIdSet.isEmpty()){
                        for(SBQQ__QuoteLine__c quoteline:[select id,SBQQ__Quote__c,core_cpq_PRID__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in:QLparentQuoteIdSet]){
                            if(quoteline.core_cpq_PRID__c <> null){
                                QuotePRIDSet.add(quoteline.SBQQ__Quote__c + '' + quoteline.core_cpq_PRID__c);
                            }
                        }
                        
                    }
                    if(!drpId.isEmpty() && Label.PSG_System_User != UserInfo.getUserId()){
                        drpDensityMap = new Map<id,Core_Design_Registration_Product__c>([SELECT Id, Name, Core_Design_Registration_Id__c, Core_Product_Id__r.Core_Product_Density_Value__c,core_cpq_OPN_Concatenation_txt__c   FROM Core_Design_Registration_Product__c WHERE Id IN :drpId ]);
                    
                        if(!drpDensityMap.isEmpty()){
                            for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                                if(oldMap.get(quoteLine.Id).core_cpq_follow_on_process_cb__c == quoteLine.core_cpq_follow_on_process_cb__c){
                                    if(!quoteDDRMap.isEmpty() && quoteDDRMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteDDRMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Opportunity2__c !=null){
                                        if(drpDensityMap.containsKey(quoteLine.core_cpq_design_registration_product__c)){                                    
                                            if(quoteDDRMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Opportunity2__r.Core_Design_Registration_Id__c != drpDensityMap.get(quoteLine.core_cpq_design_registration_product__c).Core_Design_Registration_Id__c){
                                                quoteLine.addError('Selected Opn '+prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c +' Design Registraion and Quote Design Registration is not matching');
                                            }
                                        }
                                    }                                  
                                    // Commented OPN Concatenation March 30 ,2022
                                    /*if(quoteLine.core_cpq_design_registration_product__c != null && drpDensityMap.containsKey(quoteLine.core_cpq_design_registration_product__c) && quoteLine.core_cpq_OPN_Concatenation_txt__c.trim() != drpDensityMap.get(quoteLine.core_cpq_design_registration_product__c).core_cpq_OPN_Concatenation_txt__c.trim()){
                                        quoteLine.addError(Label.PSG_QL_DRP_ConcatOPN_Error.replace('PRODUCT_OPN_HERE',prodDensityMap.get(quoteLine.SBQQ__Product__c).Core_OPN__c));
                                    }*/
                                }
                            }                        
                        }
                    }

                    if(!sourceIdSet.isEmpty()){
                        for(SBQQ__QuoteLine__c quoteLine : [SELECT id, SBQQ__Source__c, SBQQ__Source__r.core_cpq_intel_margin_pct__c, SBQQ__Source__r.core_cpq_distributor_margin_pct__c, SBQQ__Source__r.price_peak_annual_resale_amt__c, 
                                                            core_cpq_intel_margin_pct__c, core_cpq_distributor_margin_pct__c, price_peak_annual_resale_amt__c, core_cpq_intel_margin_difference__c, core_cpq_disty_margin_difference__c, 
                                                            core_cpq_peak_annual_resale_Difference__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Source__c IN: sourceIdSet LIMIT :Limits.getLimitDmlRows()] ){
                            quoteLinetoSourceIntelMarginMap.put(quoteline.SBQQ__Source__c, quoteline.SBQQ__Source__r.core_cpq_intel_margin_pct__c);
                            quoteLinetoSourceDistiMarginMap.put(quoteline.SBQQ__Source__c, quoteline.SBQQ__Source__r.core_cpq_distributor_margin_pct__c);
                            quoteLinetoSourcePeakAnnualMap.put(quoteline.SBQQ__Source__c, quoteline.SBQQ__Source__r.price_peak_annual_resale_amt__c);
                        }
                    }
                    /*Map<Id,price_prid__c> pridMap = new Map<Id,price_prid__c>();
                    if(!PRIDSet.isEmpty()){
                        pridMap = new Map<Id,price_prid__c>([SELECT Id,core_cpq_type__c,core_cpq_quantity_eau_nbr__c,
                                                             core_cpq_lower_bound_qty_nbr__c,core_cpq_upper_bound_qty_nbr__c,
                                                             price_amt__c,core_cpq_price_start_date_dt__c,core_cpq_price_end_date_dt__c,
                                                             core_cpq_prid_reviewer__c,core_cpq_prid_review_date_dt__c,core_cpq_active_pricing_cb__c,
                                                             core_cpq_prid_eligiblity_date_dt__c,core_cpq_prid_validity_date_dt__c from price_prid__c where Id IN: PRIDSet]);
                    }*/
                    if(!quoteId.isEmpty()){
                        for(SBQQ__Quote__c quote : [SELECT Id,core_cpq_date_submitted_dt__c,SBQQ__Status__c,SBQQ__Account__c,core_cpq_end_customer_nm__r.Core_Account_PSG_Tier__c,
                                                    core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c,createddate,core_cpq_price_book_nm__c,SBQQ__Opportunity2__c,core_cpq_account_tier__c,SBQQ__Opportunity2__r.Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c,
                                                    SBQQ__PriceBook__c,SBQQ__PricebookId__c,core_cpq_sap_ecp_nm__c,core_cpq_quote_type_nm__c,core_cpq_end_customer_nm__r.Core_Geo__c,core_cpq_end_customer_nm__c,core_cpq_account_program__c,core_cpq_ddr_nm__c,SBQQ__Opportunity2__r.Core_Design_Registration_Id__r.core_cpq_approved_date__c,
                                                    core_cpq_margin_geo_txt__c from SBQQ__Quote__c where Id IN: quoteId LIMIT :Limits.getLimitDmlRows()]){
                            quoteIdToQuoteMap.put(quote.Id,quote);
                            if(quote.core_cpq_end_customer_nm__c != null && quote.core_cpq_end_customer_nm__r.Core_Geo__c != null){
                                   quoteIdToEcMap.put(quote.Id,quote.core_cpq_end_customer_nm__r.Core_Geo__c);                         
                            }
                            // added for Apex error
                            if(quote.core_cpq_price_book_nm__c != null){
                                priceBookIdSet.add(quote.core_cpq_price_book_nm__c);
                                quoteMap.put(quote.Id,quote);
                            }
                            if(quote.core_cpq_account_tier__c != null){
                                accountTierSet.add(quote.core_cpq_account_tier__c);
                            }
                            if(quote.core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c != null){
                                accountAllianceSet.addAll(quote.core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c.split(';'));
                            }
                            if(quote.core_cpq_margin_geo_txt__c != null){
                                geoSet.add(quote.core_cpq_margin_geo_txt__c);
                            }else{
                                geoSet.add('');
                            }                            
                            //added
                        }
                    }              
                    Map<String,price_prid__c> ecpOpnToPrIdrecMap = new Map<String,price_prid__c>();
                    Map<String,price_prid__c> ecpOpnLowerUpperToPrIdrecMap = new Map<String,price_prid__c>();
                    Map<Id,price_prid__c> selectedPRIDMap = new Map<Id,price_prid__c>();
                    if(!selectedPRIDSet.isEmpty()){
                        String query = 'SELECT Id';
                        if(!quoteLineApiToPridApiMap.isEmpty()){
                            query = query +','+ String.join(new List<String>(quoteLineApiToPridApiMap.Values()),',');
                        }
                        query = query + ',core_cpq_prid_validity_date_dt__c FROM price_prid__c WHERE Id IN : selectedPRIDSet AND core_cpq_active_cb__c = true';
                        if(String.isNotBlank(query)){
                           for(price_prid__c pridRec : DataBase.query(query)){
                            selectedPRIDMap.put(pridRec.Id,pridRec); 
                            if(pridRec.get('core_cpq_prid_reviewer__c') != null){
                                reviewerIdSet.add((Id)pridRec.get('core_cpq_prid_reviewer__c')); 
                            }                           
                        } 
                        }
                        
                    }
                    Map<Id,String> reviewerIdToNameMap = new Map<Id,String>();
                    if(reviewerIdSet != null){
                        for(User u1 : [SELECT Id,Name from User where Id IN : reviewerIdSet]){
                            reviewerIdToNameMap.put(u1.Id,u1.Name);
                        }
                    }
                    if(!productIdSet.isEmpty() && !fetchPriceDataRecursiveCheck){
                        fetchPricingDetails(productIdSet,productOPNSet,uniqueIdToPriceBookEntryMap,productToFWDMapStartDt,
                                            smiFlagInd,productToMSVPMap,prodToolTypeMap,authCodeProductMap,priceBookIdSet,accountTierSet,
                                            accountAllianceSet,geoSet,uniqueIdToListPriceMap);
                        fetchPriceDataRecursiveCheck = true;
                    }
                    String queryStr = '';
                    String productType = 'Intel® FPGAs';
                    String productOrg = 'Sales';
                    if(!opnSet.isEmpty()){
                        queryStr = 'SELECT Id,Core_OPN__c, Core_Item_Orderable_Ind__c,IsActive,Core_Item_Quotable_Ind__c,Core_Product_Org__c FROM Product2 where ( Core_OPN__c IN : opnSet and isActive = true and Core_Item_Quotable_Ind__c = true and Core_Product_Type__c =: productType and Core_Product_Org__c =: productOrg )';
                    }
                    if(!productId2Set.isEmpty()){
                        if(String.isBlank(queryStr)){
                            queryStr = 'SELECT Id,Core_OPN__c, Core_Item_Orderable_Ind__c,IsActive,Core_Item_Quotable_Ind__c,Core_Product_Org__c FROM Product2 where Id IN : productIdSet';
                        }else{
                            queryStr += ' OR Id IN: productId2Set';                    
                        }
                    }
                    Map<String,Id> opnToProductIdMap = new Map<String,Id>();
                    Map<Id,String> productIdToOPNMap = new Map<Id,String>();
                    Set<Id> productsRegisterable = new Set<Id>();                   
                    if(String.isNotBlank(queryStr)){
                        for(Product2 prod : Database.query(queryStr)){
                            if(productId2Set.contains(prod.Id)){
                                productIdToOPNMap.put(prod.Id,prod.Core_OPN__c);
                            }
                            if(opnSet.contains(prod.Core_OPN__c)){
                                opnToProductIdMap.put(prod.Core_OPN__c,prod.Id);                                
                            }
                            if(prod.IsActive  && prod.Core_Item_Quotable_Ind__c){
                                productsRegisterable.add(prod.Id);
                            }
                            orderFlagInd.put(prod.Id, prod.Core_Item_Orderable_Ind__c);
                        }
                    }
                    
                    
                    String queryStr2 = '';
                    
                    if(!drpDistyIdSet.isEmpty()){
                        queryStr2 = 'SELECT Id,Name FROM Core_Design_Registration_Product__c WHERE Name IN :drpDistyIdSet';
                    }
                    if(!drpIdSet.isEmpty()){
                        if(String.isBlank(queryStr2)){
                            queryStr2 = 'SELECT Id,Name FROM Core_Design_Registration_Product__c WHERE Id IN :drpIdSet';
                        }else{
                            queryStr2 += ' OR Id IN: drpIdSet';                    
                        }
                    }
                    Map<String,Id> drpDistyToDrpIdMap = new Map<String,Id>();
                    Map<Id,String> drpIdTodrpDistyMap = new Map<Id,String>();
                    
                    if(String.isNotBlank(queryStr2)){
                        for(Core_Design_Registration_Product__c drp : Database.query(queryStr2)){
                            if(drpIdSet.contains(drp.Id)){
                                drpIdTodrpDistyMap.put(drp.Id,drp.Name);
                            }
                            if(drpDistyIdSet.contains(drp.Name)){
                                drpDistyToDrpIdMap.put(drp.Name,drp.Id);
                            }    
                        }
                    }
                    Set<Id> oppIdSet = new Set<Id>();
                    if(!quoteIdSet.isEmpty()){
                        for(SBQQ__Quote__c quote : [SELECT Id,core_cpq_date_submitted_dt__c,SBQQ__Account__c,core_cpq_end_customer_nm__r.Core_Account_PSG_Tier__c,
                                                    core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c,createddate,core_cpq_price_book_nm__c,core_cpq_account_tier__c,
                                                    SBQQ__Opportunity2__c,SBQQ__PriceBook__c,core_cpq_sap_ecp_nm__c,core_cpq_quote_type_nm__c,
                                                    core_cpq_margin_geo_txt__c from SBQQ__Quote__c where Id IN: quoteIdSet LIMIT :Limits.getLimitDmlRows()]){
                            if(quote.core_cpq_quote_type_nm__c == 'Design Win' && quote.SBQQ__Opportunity2__c != null){
                                oppIdSet.add(quote.SBQQ__Opportunity2__c);
                            }
                             quoteIdToQuoteTypeMap.put(quote.Id,quote.core_cpq_quote_type_nm__c);                        
                                                       
                        }
                    }
                    Map<Id,Set<Id>> oppToExistingOPNMap = new Map<Id,Set<Id>>();
                    Map<Id,String> OPNToQuoteNameMap = new Map<Id,String>();
                    Map<Id,String> OPNToOptyNameMap = new Map<Id,String>();
                    if(!oppIdSet.isEmpty()){
                        for(SBQQ__QuoteLine__c quoteLine : [SELECT Id,SBQQ__Product__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,SBQQ__Quote__r.Name,
                                                            SBQQ__Quote__r.core_cpq_quote_type_nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.SBQQ__Opportunity2__c 
                                                            IN: oppIdSet and SBQQ__Quote__r.core_cpq_quote_type_nm__c = 'Design Win' and 
                                                            SBQQ__Quote__r.core_cpq_active_cb__c = true and Id not in :quoteLineList and SBQQ__Quote__c Not IN :quoteIdSet LIMIT :Limits.getLimitDmlRows()]){
                            if(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c != null){                             
                                if(!oppToExistingOPNMap.containsKey(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c)){
                                    oppToExistingOPNMap.put(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c,new Set<Id>{quoteLine.SBQQ__Product__c});
                                    OPNToQuoteNameMap.put(quoteLine.SBQQ__Product__c,quoteLine.SBQQ__Quote__r.Name);
                                    OPNToOptyNameMap.put(quoteLine.SBQQ__Product__c,quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name);
                                }else{
                                    oppToExistingOPNMap.get(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c).add(quoteLine.SBQQ__Product__c);
                                    OPNToQuoteNameMap.put(quoteLine.SBQQ__Product__c,quoteLine.SBQQ__Quote__r.Name);
                                    OPNToOptyNameMap.put(quoteLine.SBQQ__Product__c,quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name);
                                }
                            }
                        }
                    }
                    for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                        Decimal intelMargin = quoteline.core_cpq_intel_margin_pct__c != null ? quoteline.core_cpq_intel_margin_pct__c : 0;
                        Decimal sourceIntelMargin = quoteLinetoSourceIntelMarginMap.get(quoteLine.SBQQ__Source__c) != null ? quoteLinetoSourceIntelMarginMap.get(quoteLine.SBQQ__Source__c) : 0;
                        quoteline.core_cpq_intel_margin_difference__c = intelMargin - sourceIntelMargin;
                        Decimal distiMargin = quoteline.core_cpq_distributor_margin_pct__c != null ? quoteline.core_cpq_distributor_margin_pct__c.setScale(1) : 0;
                        Decimal sourceDistiMargin = quoteLinetoSourceDistiMarginMap.get(quoteLine.SBQQ__Source__c) != null ? quoteLinetoSourceDistiMarginMap.get(quoteLine.SBQQ__Source__c) : 0;
                        quoteline.core_cpq_disty_margin_difference__c = distiMargin - sourceDistiMargin;
                        Decimal peakAnnual = quoteline.price_peak_annual_resale_amt__c != null ? quoteline.price_peak_annual_resale_amt__c : 0;
                        Decimal sourcePeakAnnual = quoteLinetoSourcePeakAnnualMap.get(quoteLine.SBQQ__Source__c) != null ? quoteLinetoSourcePeakAnnualMap.get(quoteLine.SBQQ__Source__c) :0;
                        quoteline.core_cpq_peak_annual_resale_Difference__c = peakAnnual - sourcePeakAnnual;
                        if(smiFlagInd.containsKey(quoteLine.SBQQ__Product__c)){
                            quoteLine.core_cpq_smi_flag_ind__c = smiFlagInd.get(quoteLine.SBQQ__Product__c);
                        }
                        if(orderFlagInd.containsKey(quoteline.SBQQ__Product__c)){
                            quoteLine.core_cpq_orderable_ind__c = orderFlagInd.get(quoteLine.SBQQ__Product__c);
                        }
                        if(quoteLine.core_cpq_opn__c != null && quoteLine.core_cpq_opn__c != oldMap.get(quoteLine.Id).core_cpq_opn__c && opnToProductIdMap.containsKey(quoteLine.core_cpq_opn__c)){
                            quoteLine.SBQQ__Product__c = opnToProductIdMap.get(quoteLine.core_cpq_opn__c);
                        }
                        if(quoteLine.SBQQ__Product__c != null && quoteLine.SBQQ__Product__c != oldMap.get(quoteLine.Id).SBQQ__Product__c && productIdToOPNMap.containsKey(quoteLine.SBQQ__Product__c)){     
                            quoteLine.core_cpq_opn__c = productIdToOPNMap.get(quoteLine.SBQQ__Product__c);
                        }
                        //added for opn bug by ranjit
                        if(quoteLine.SBQQ__Product__c != null && quoteLine.core_cpq_product_nm__c!=null && quoteLine.core_cpq_opn__c!=oldMap.get(quoteLine.id).core_cpq_opn__c && opnToProductIdMap.containsKey(quoteLine.core_cpq_opn__c)){
                            
                            quoteLine.SBQQ__Product__c=opnToProductIdMap.get(quoteLine.core_cpq_opn__c);
                            quoteLine.core_cpq_product_nm__c=opnToProductIdMap.get(quoteLine.core_cpq_opn__c);
                            quoteLine.core_cpq_design_registration_product__c = null;
                        }
                        if(quoteLine.core_cpq_altera_reg_txt__c != null && quoteLine.core_cpq_altera_reg_txt__c != oldMap.get(quoteLine.Id).core_cpq_altera_reg_txt__c && drpDistyToDrpIdMap.containsKey(quoteLine.core_cpq_altera_reg_txt__c)){
                            quoteLine.core_cpq_design_registration_product__c = drpDistyToDrpIdMap.get(quoteLine.core_cpq_altera_reg_txt__c);
                        }
                        if(quoteLine.core_cpq_design_registration_product__c != null && quoteLine.core_cpq_design_registration_product__c != oldMap.get(quoteLine.Id).core_cpq_design_registration_product__c && drpIdTodrpDistyMap.containsKey(quoteLine.core_cpq_design_registration_product__c)){     
                            quoteLine.core_cpq_altera_reg_txt__c = drpIdTodrpDistyMap.get(quoteLine.core_cpq_design_registration_product__c);
                        }
                        if(quoteLine.core_cpq_altera_reg_txt__c != oldMap.get(quoteLine.Id).core_cpq_altera_reg_txt__c && String.IsBlank((quoteLine.core_cpq_altera_reg_txt__c))){
                            quoteLine.core_cpq_design_registration_product__c = null;
                        }
                        if(quoteLine.core_cpq_design_registration_product__c != oldMap.get(quoteLine.Id).core_cpq_design_registration_product__c && quoteLine.core_cpq_design_registration_product__c == null){
                             quoteLine.core_cpq_altera_reg_txt__c = '';
                        }  
                        quoteLine.core_cpq_disti_margin_onload__c = quoteLine.core_cpq_distributor_margin_pct__c;
                        quoteLine.core_cpq_disti_margin_changed__c = false;
                        String prodFamily = '';
                        price_prid__c prid = new price_prid__c();
                        if(quoteLine.SBQQ__Product__c != null){
                            prodFamily = quoteLine.core_cpq_product_family_txt__c;
                        }
                        if(quoteLine.core_cpq_PRID__c != null){
                            prid = selectedPRIDMap.get(quoteLine.core_cpq_PRID__c);                            
                        }
                        
                        if(quoteLine.core_cpq_quote_type__c == 'Transfer Pricing' &&  quoteLine.core_cpq_parent_quote__c != null && quoteLine.core_cpq_PRID__c != null && (!QuotePRIDSet.contains(quoteLine.core_cpq_parent_quote__c + ''+ quoteLine.core_cpq_PRID__c))){
                            quoteLine.adderror('PRID is not linked with the Associated Parent Quote.');    
                        }
                        
                   
                        if(productToFWDMapStartDt.containsKey(quoteline.Core_OPN__c)){
                            Boolean forwardCostMatchFound = false;
                            for(Date fcStartDate : productToFWDMapStartDt.get(quoteline.Core_OPN__c).keySet()){
                                if(fcStartDate <= quoteLine.core_cpq_price_eligibility_date_dt__c &&
                                  (productToFWDMapStartDt.get(quoteLine.Core_OPN__c).get(fcStartDate)).core_cpq_fc_end_date_dt__c
                                   >= quoteLine.core_cpq_price_eligibility_date_dt__c){
                                      quoteLine.price_std_fwd_cost_amt__c = (productToFWDMapStartDt.get(quoteLine.Core_OPN__c).get(fcStartDate)).price_forward_cost_amt__c; 
                                      forwardCostMatchFound = true;
                                      break;
                                }
                            }
                            if(!forwardCostMatchFound && quoteIdToQuoteMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Status__c != 'Approved'){
                                quoteLine.price_std_fwd_cost_amt__c = 0;
                            }   
                        }
                        //Changes Made for TWC3133-4135 -Bishal Singh
                        if(updateDistiMarginValue || quoteLine.core_cpq_design_registration_product__c!=oldmap.get(quoteLine.Id).core_cpq_design_registration_product__c
                          || (!triggeredOnQuoteApproval && oldMap.get(quoteLine.Id).core_cpq_PRID__c != quoteline.core_cpq_PRID__c) || (quoteLine.core_cpq_master_ddr__c != oldMap.get(quoteLine.Id).core_cpq_master_ddr__c )){
                            updateDistiMargin(quoteIdToQuoteMap,quoteLine,productsRegisterable,prodFamily,prid,
                                              existingPartnerProgram,smiFlagInd,orderFlagInd);
                        }
                        if((quoteLine.price_suggested_resale_amt__c!=oldmap.get(quoteLine.Id).price_suggested_resale_amt__c || quoteLine.core_cpq_distributor_margin_pct__c!=oldmap.get(quoteLine.Id).core_cpq_distributor_margin_pct__c) && quoteLine.core_cpq_distributor_margin_pct__c != null && quoteLine.price_suggested_resale_amt__c != null){
                            quoteLine.price_brokencost_amt__c = (quoteLine.price_suggested_resale_amt__c - (quoteLine.price_suggested_resale_amt__c * (quoteLine.core_cpq_distributor_margin_pct__c/100)))?.setScale(2);
                            quoteLine.price_previous_brokencost_amt__c = (quoteLine.price_suggested_resale_amt__c - (quoteLine.price_suggested_resale_amt__c * (quoteLine.core_cpq_distributor_margin_pct__c/100)))?.setScale(2);
                        }
                        if(quoteIdToQuoteMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Status__c != 'Approved' && quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c == 'Design Win'){
                            String finalStr = '';
                            Boolean isPridRevision = false;
                            Boolean isPridUpdation = false;
                            if(revisionTriggerQLFieldMap.containsKey(quoteLine.core_cpq_quote_line_type_txt__c)){
                                for(String qlField : revisionTriggerQLFieldMap.get(quoteLine.core_cpq_quote_line_type_txt__c)){
                                    String pridField = quoteLineApiToPridApiMap.get(qlField);
                                    if(selectedPRIDMap.containsKey(quoteLine.core_cpq_PRID__c) 
                                    && quoteLine.get(qlField) != (selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField)){
                                        isPridRevision = true;
                                    }
                                }
                            }
                            if(isPridRevision && revisionFieldsQLMap.containsKey(quoteLine.core_cpq_quote_line_type_txt__c)){
                                for(String qlField : revisionFieldsQLMap.get(quoteLine.core_cpq_quote_line_type_txt__c)){
                                    String pridField = quoteLineApiToPridApiMap.get(qlField);
                                    if(selectedPRIDMap.containsKey(quoteLine.core_cpq_PRID__c) 
                                    && quoteLine.get(qlField) != (selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField)){
                                        String pridValue = '';
                                        String qlValue = '';
                                        if(quoteLine.get(qlField) == null){
                                            qlValue = quoteLineApiToDefaultValueMap.get(qlField);
                                        }else{
                                            if(quoteLineApiToTypeMap.get(qlField)=='integer'){
                                                qlValue = '' + Integer.valueOf(((Decimal)quoteLine.get(qlField)));
                                            }else if(quoteLineApiToTypeMap.get(qlField)=='date'){
                                                qlValue = '' + ((Date)(quoteLine.get(qlField))).format();
                                            }else if(qlField == 'core_cpq_reviewer__c' && reviewerIdToNameMap.containsKey((Id)quoteLine.get(qlField))){
                                                qlValue = '' + reviewerIdToNameMap.get((Id)quoteLine.get(qlField));
                                            }else{
                                                qlValue = '' + quoteLine.get(qlField);
                                            }
                                        }
                                        if((selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField) == null){
                                            pridValue = pridApiToDefaultValueMap.get(pridField);
                                        }else{
                                            if(pridApiToTypeMap.get(pridField)=='date'){
                                                pridValue = '' + ((Date)(selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField)).format();
                                            }else if(pridField == 'core_cpq_prid_reviewer__c' && reviewerIdToNameMap.containsKey((Id)(selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField))){
                                                pridValue = ''+reviewerIdToNameMap.get((Id)((selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField)));
                                            }else{
                                                pridValue = ''+(selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField);
                                            }
                                        }
                                        if(String.isNotBlank(finalStr)){
                                            finalStr = finalStr +', '+ quoteLineApiToLabelMap.get(qlField) +' changed from ' + pridValue + ' to ' + qlValue;
                                        }else{
                                            finalStr = finalStr + quoteLineApiToLabelMap.get(qlField) +' changed from ' + pridValue + ' to ' + qlValue;
                                        }
                                    }
                                }
                            }else if(updationFieldQLMap.containsKey(quoteLine.core_cpq_quote_line_type_txt__c)){
                                for(String qlField : updationFieldQLMap.get(quoteLine.core_cpq_quote_line_type_txt__c)){
                                    String pridField = quoteLineApiToPridApiMap.get(qlField);
                                    if(selectedPRIDMap.containsKey(quoteLine.core_cpq_PRID__c) 
                                    && quoteLine.get(qlField) != (selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField)){
                                        isPridUpdation = true;
                                        String pridValue = '';
                                        String qlValue = '';
                                        if(quoteLine.get(qlField) == null){
                                            qlValue = quoteLineApiToDefaultValueMap.get(qlField);
                                        }else{
                                            if(quoteLineApiToTypeMap.get(qlField)=='integer'){
                                                qlValue = '' + Integer.valueOf(((Decimal)quoteLine.get(qlField)));
                                            }else if(quoteLineApiToTypeMap.get(qlField)=='date'){
                                                qlValue = '' + ((Date)(quoteLine.get(qlField))).format();
                                            }else if(qlField == 'core_cpq_reviewer__c' && reviewerIdToNameMap.containsKey((Id)quoteLine.get(qlField))){
                                                qlValue = '' + reviewerIdToNameMap.get((Id)quoteLine.get(qlField));
                                            }else{
                                                qlValue = '' + quoteLine.get(qlField);
                                            }
                                        }
                                        if((selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField) == null){
                                            pridValue = pridApiToDefaultValueMap.get(pridField);
                                        }else if(pridField == 'core_cpq_prid_reviewer__c' && reviewerIdToNameMap.containsKey((Id)(selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField))){
                                            pridValue = ''+reviewerIdToNameMap.get((Id)((selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField)));
                                        }else if(pridApiToTypeMap.get(pridField)=='date'){//added for date format
                                            pridValue = ''+((Date)(selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField)).format();
                                        }
                                        else{
                                            pridValue = ''+(selectedPRIDMap.get(quoteLine.core_cpq_PRID__c)).get(pridField);
                                        }
                                        if(String.isNotBlank(finalStr)){
                                            finalStr = finalStr +', '+ quoteLineApiToLabelMap.get(qlField) +' changed from ' + pridValue + ' to ' + qlValue;
                                        }else{
                                            finalStr = finalStr + quoteLineApiToLabelMap.get(qlField) +' changed from ' + pridValue + ' to ' + qlValue;
                                        }
                                    }
                                }
                            }
                            if(String.isNotBlank(finalStr)){
                                if(isPridRevision){
                                    finalStr = 'PRID Revision. ' +finalStr;
                                    if(finalStr.length() > 255){
                                        quoteLine.core_cpq_prid_alert__c = finalStr.substring(0,254);
                                    }else{
                                        quoteLine.core_cpq_prid_alert__c = finalStr;
                                    }
                                }else if(isPridUpdation){
                                    finalStr = 'PRID Updation. ' +finalStr;
                                    if(finalStr.length() > 255){
                                        quoteLine.core_cpq_prid_alert__c = finalStr.substring(0,254);
                                    }else{
                                        quoteLine.core_cpq_prid_alert__c = finalStr;
                                    }
                                }
                            }
                        }
                        if(quoteLine.Core_OPN__c != null){
                            Boolean forwardCostMatchFound = false;
                            if(productToFWDMapStartDt.containsKey(quoteline.Core_OPN__c)){
                                for(Date fcStartDate : productToFWDMapStartDt.get(quoteline.Core_OPN__c).keySet()){
                                    if(fcStartDate <= quoteLine.core_cpq_price_eligibility_date_dt__c &&
                                      (productToFWDMapStartDt.get(quoteLine.Core_OPN__c).get(fcStartDate)).core_cpq_fc_end_date_dt__c
                                       >= quoteLine.core_cpq_price_eligibility_date_dt__c){
                                          quoteLine.price_std_fwd_cost_amt__c = (productToFWDMapStartDt.get(quoteLine.Core_OPN__c).get(fcStartDate)).price_forward_cost_amt__c; 
                                          forwardCostMatchFound = true;
                                          break;
                                    }
                                }
                            }
                            if(!forwardCostMatchFound && quoteIdToQuoteMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Status__c != 'Approved'){
                                quoteLine.price_std_fwd_cost_amt__c = 0;
                            }
                        }
                        if(quoteIdToQuoteMap.containsKey(quoteLine.SBQQ__Quote__c) && uniqueIdToPriceBookEntryMap.containsKey(''+quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c  + quoteLine.SBQQ__Product__c)){
                            quoteLine.price_disty_cost_nbr__c = uniqueIdToPriceBookEntryMap.get(''+quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).price_disty_cost__c;
                            quoteLine.SBQQ__PricebookEntryId__c = uniqueIdToPriceBookEntryMap.get(''+quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).Id;                           
                            quoteLine.core_cpq_multiple_qty_nbr__c = uniqueIdToPriceBookEntryMap.get(''+quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).core_cpq_multiple_order_quantity__c;
                            quoteLine.core_cpq_minimum_qty__c = uniqueIdToPriceBookEntryMap.get(''+quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).core_cpq_minimum_order_qty__c;
                            string key = uniqueIdToPriceBookEntryMap.get(''+quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).Id;
                            if(!uniqueIdToListPriceMap.isEmpty() && uniqueIdToListPriceMap.containsKey(key)){
                                for(core_cpq_list_price__c lp : uniqueIdToListPriceMap.get(key)){
                                    if(quoteLine.SBQQ__Quantity__c >= lp.core_cpq_lowerbound_qty__c && quoteLine.SBQQ__Quantity__c <= lp.core_cpq_upperbound_qty__c){
                                        quoteLine.SBQQ__ListPrice__c = lp.core_cpq_list_price_amt__c;
                                    }
                                }
                            }
                        }else if(quoteIdToQuoteMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Status__c != 'Approved'){
                            //quoteLine.price_disty_cost_nbr__c = 0;
                            //quoteLine.SBQQ__ListPrice__c = 0; 
                            if(quoteLine.price_disty_cost_nbr__c == null){
                                quoteLine.price_disty_cost_nbr__c = 0;
                            }
                            if(quoteLine.SBQQ__ListPrice__c == null){   
                                quoteLine.SBQQ__ListPrice__c = 0; 
                            }
                        }                       
                        if(productToMSVPMap.containsKey(quoteLine.SBQQ__Product__c)){
                            for(Date effectiveDate : (productToMSVPMap.get(quoteLine.SBQQ__Product__c)).keySet()){
                                if((quoteIdToQuoteMap.containsKey(quoteLine.SBQQ__Quote__c)) && effectiveDate <= (quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c)).createddate){
                                    quoteLine.price_msvp_l1_amt__c = (productToMSVPMap.get(quoteLine.SBQQ__Product__c)).get(effectiveDate).price_level_1_amt__c;
                                    quoteLine.price_msvp_l2_amt__c = (productToMSVPMap.get(quoteLine.SBQQ__Product__c)).get(effectiveDate).price_level_2_amt__c;
                                    break;
                                }
                            }
                        }
                        if((quoteLine.SBQQ__Product__c != oldMap.get(quoteLine.Id).SBQQ__Product__c
                        || quoteLine.core_cpq_quote_line_type_txt__c != oldMap.get(quoteLine.Id).core_cpq_quote_line_type_txt__c
                        || quoteLine.core_cpq_lower_bound_qty_qty__c != oldMap.get(quoteLine.Id).core_cpq_lower_bound_qty_qty__c
                        || quoteLine.core_cpq_upper_bound_qty_nbr__c != oldMap.get(quoteLine.Id).core_cpq_upper_bound_qty_nbr__c
                        || quoteLine.core_cpq_price_eligibility_date_dt__c != oldMap.get(quoteLine.Id).core_cpq_price_eligibility_date_dt__c) && quoteIdToQuoteTypeMap.get(quoteLine.SBQQ__Quote__c)!='Budgetary'
                        ){
                            if(quoteLine.core_cpq_quote_line_type_txt__c == 'AVP'){
                                quoteLine.core_cpq_unique_id__c = ''+ quoteLine.SBQQ__Quote__c                                                           
                                    + quoteLine.recordtypeId
                                    + quoteLine.SBQQ__Product__c
                                    + quoteLine.core_cpq_quote_line_type_txt__c 
                                    + quoteLine.core_cpq_lower_bound_qty_qty__c?.intValue() 
                                    + quoteLine.core_cpq_upper_bound_qty_nbr__c?.intValue()
                                    +quoteLine.core_cpq_price_eligibility_date_dt__c;
                            }else{
                                quoteLine.core_cpq_unique_id__c = ''+ quoteLine.SBQQ__Quote__c                                                           
                                    + quoteLine.recordtypeId
                                    + quoteLine.SBQQ__Product__c
                                    + quoteLine.core_cpq_quote_line_type_txt__c 
                                    + quoteLine.core_cpq_lower_bound_qty_qty__c?.intValue() 
                                    + quoteLine.core_cpq_upper_bound_qty_nbr__c?.intValue();
                            }                                                                    
                        }
                        
                    } 
                    //added for unique bug
                    Map<id,List<SBQQ__QuoteLine__c>> quoteToQuoteLineMap=new Map<id,List<SBQQ__QuoteLine__c>>();
                    if(!quoteId.isEmpty()){
                        for(SBQQ__QuoteLine__c quoteLineRec : [SELECT Id,SBQQ__Quote__c,core_cpq_unique_id__c,recordtypeId,SBQQ__Product__c,
                                                                core_cpq_quote_line_type_txt__c,core_cpq_lower_bound_qty_qty__c
                                                                from SBQQ__QuoteLine__c where SBQQ__Quote__c IN: quoteId AND Id NOT IN : quoteLineId LIMIT :Limits.getLimitDmlRows()]){
                                if(!quoteToQuoteLineMap.containsKey(quoteLineRec.SBQQ__Quote__c)){
                                        quoteToQuoteLineMap.put(quoteLineRec.SBQQ__Quote__c,new List<SBQQ__QuoteLine__c>{quoteLineRec});
                                }else{
                                    quoteToQuoteLineMap.get(quoteLineRec.SBQQ__Quote__c).add(quoteLineRec);
                                }
                        }
                    }
                    Set<String> uniqueIdSet = new Set<String>();
                    /*List<UserRecordAccess> parentQuoteAccess = new List<UserRecordAccess>();
                    if(!QLparentQuoteIdSet.isEmpty()){
                        parentQuoteAccess = [select RecordId, HasReadAccess from UserRecordAccess Where UserId =: UserInfo.getUserId() and RecordId IN: QLparentQuoteIdSet];
                    }
                    for(UserRecordAccess rec : parentQuoteAccess){
                        if(rec.HasReadAccess == false){
                            (rec.RecordId).addError('You do not have access to the attached Parent Quote.');
                        }
                    }*/
            //PSG System user validation pass bypass
            if(Label.PSG_System_User != UserInfo.getUserId()){
                    for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                        if(oldMap.get(quoteLine.Id).core_cpq_follow_on_process_cb__c == quoteLine.core_cpq_follow_on_process_cb__c){
                            if(quoteIdToQuoteMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c == 'Design Win' &&
                               quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Opportunity2__c != null &&
                               oppToExistingOPNMap.containsKey(quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Opportunity2__c)
                               &&  oppToExistingOPNMap.get(quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__Opportunity2__c).
                               contains(quoteLine.SBQQ__Product__c) && OPNToOptyNameMap.get(quoteLine.SBQQ__Product__c) != null && quoteLine.SBQQ__PricebookEntryId__c == oldMap.get(quoteLine.Id).SBQQ__PricebookEntryId__c){
                                   if(oldMap.get(quoteLine.Id).core_cpq_follow_on_process_cb__c == quoteLine.core_cpq_follow_on_process_cb__c){
                                       quoteLine.addError('OPN '+ quoteLine.Core_OPN__c + ' already exist in an another Active Design Win Quote '+
                                                          OPNToQuoteNameMap.get(quoteLine.SBQQ__Product__c)+' for the same Opportunity '+
                                                          OPNToOptyNameMap.get(quoteLine.SBQQ__Product__c));
                                   }
                               }
                        if(quoteLine.core_cpq_unique_id__c != null){
                            if(uniqueIdSet.contains(quoteLine.core_cpq_unique_id__c)){
                                quoteLine.addError('Duplicated Lines found. Please remove and try again.');
                                
                            }else{
                                uniqueIdSet.add(quoteLine.core_cpq_unique_id__c);
                            }
                            if(quoteLine.SBQQ__Product__c != oldMap.get(quoteLine.Id).SBQQ__Product__c
                               || quoteLine.core_cpq_quote_line_type_txt__c != oldMap.get(quoteLine.Id).core_cpq_quote_line_type_txt__c
                               || quoteLine.core_cpq_lower_bound_qty_qty__c != oldMap.get(quoteLine.Id).core_cpq_lower_bound_qty_qty__c
                               || quoteLine.core_cpq_upper_bound_qty_nbr__c != oldMap.get(quoteLine.Id).core_cpq_upper_bound_qty_nbr__c
                              ){
                                  if(quoteToQuoteLineMap.containsKey(quoteline.SBQQ__Quote__c)){
                                      for(SBQQ__QuoteLine__c quoteLineDBRec : quoteToQuoteLineMap.get(quoteline.SBQQ__Quote__c)){
                                          if((quoteLineDBRec.core_cpq_unique_id__c == quoteLine.core_cpq_unique_id__c)){
                                              quoteLine.addError('Duplicated Lines found. Please remove and try again.');
                                              //quoteLine.addError('Duplicate Lines found for OPN '+quoteLine.core_cpq_opn__c);
                                              //break;
                                          }
                                      }
                                  }
                              }
                        }
            }
                    }   
                }
                updateDistiMarginValue = false;
             }
        }
                                                        
    }
    
    /************************************************************************************************************
  *Method Name : updateDistiMargin
  *Created Date: 08/13/2021
  *Author: Vijay
  *Description : Updates Disti margin on Quote Lines.
  ************************************************************************************************************/
    public static void updateDistiMargin(Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap,SBQQ__QuoteLine__c quoteLine,
                                         Set<Id> productsRegisterable, String productFamily,price_prid__c prid,
                                         Set<String> existingPartnerProgram,Map<Id,Boolean> smiFlagInd,Map<Id,Boolean> orderFlagInd){
        if(quoteIdToQuoteMap.containsKey(quoteLine.SBQQ__Quote__c)){
            SBQQ__Quote__c quote  = quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c);            
            Set<String> uniqueStrSet = new Set<String>();
            if(quote.core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c != null){
                for(String localPartnerProgram : (quote.core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c).split(';')){
                    String uniqueStr = '';
                    if(quote.core_cpq_margin_geo_txt__c != null){
                        uniqueStr = uniqueStr+quote.core_cpq_margin_geo_txt__c;
                    }
                    if(quote.core_cpq_account_tier__c != null){
                        uniqueStr = uniqueStr+quote.core_cpq_account_tier__c;
                    }
                    if(existingPartnerProgram.contains(localPartnerProgram)){
                        uniqueStr = uniqueStr+localPartnerProgram;
                    }
                    if(quote.SBQQ__PriceBook__c != null){
                        uniqueStr = uniqueStr+quote.SBQQ__PriceBook__c;
                    }
                    //Changes Made for TWC3133-4135 -Bishal Singh
                    if(quoteLine.core_cpq_design_reg_status__c == 'Approved' || quoteLine.core_cpq_master_ddr__c !=null){
                        uniqueStr = uniqueStr + 'Yes';
                    }else{
                        uniqueStr = uniqueStr + 'No';
                    }                    
                    uniqueStr = uniqueStr + quoteLine.core_cpq_registerable_flag__c;
                    
                    if(String.isNotBlank(uniqueStr)){
                        uniqueStrSet.add(uniqueStr);
                    }   
                }
            }else{
                String uniqueStr = '';
                if(quote.core_cpq_margin_geo_txt__c != null ){
                    uniqueStr = uniqueStr+quote.core_cpq_margin_geo_txt__c;
                }
                if(quote.core_cpq_account_tier__c != null){
                    uniqueStr = uniqueStr+quote.core_cpq_account_tier__c;
                }
                if(quote.SBQQ__PriceBook__c != null){
                    uniqueStr = uniqueStr+quote.SBQQ__PriceBook__c;
                }
                //Changes Made for TWC3133-4135 -Bishal Singh
                if(quoteLine.core_cpq_design_reg_status__c == 'Approved' || quoteLine.core_cpq_master_ddr__c !=null){
                    uniqueStr = uniqueStr + 'Yes';
                }else{
                    uniqueStr = uniqueStr + 'No';
                }  
                uniqueStr = uniqueStr + quoteLine.core_cpq_registerable_flag__c;
                if(String.isNotBlank(uniqueStr)){
                    uniqueStrSet.add(uniqueStr);
                }
            }
            
           
            core_cpq_distributor_margin__c dmRec=null; 
            for(String uniqueStr2 : uniqueStrSet){
                String dmType='Hunter';
                if(prid != null && prid.core_cpq_prid_validity_date_dt__c != null && prid.core_cpq_prid_validity_date_dt__c < System.today()){
                    dmType='Farmer';
                }
                if(productsRegisterable.contains(quoteLine.SBQQ__Product__c)){
                    if(dmType=='Hunter' && familyHunterDistyMarginMap.containsKey(uniqueStr2+'Hunter'+productFamily)){
                        dmRec=familyHunterDistyMarginMap.get(uniqueStr2+'Hunter'+productFamily);
                    }else if(dmType=='Hunter' && hunterDistyMarginMap.containsKey(uniqueStr2+'Hunter')){
                        dmRec=hunterDistyMarginMap.get(uniqueStr2+'Hunter');
                    }else if(familyFarmerDistyMarginMap.containsKey(uniqueStr2+'Farmer'+productFamily)){
                        dmRec=familyFarmerDistyMarginMap.get(uniqueStr2+'Farmer'+productFamily);   
                    }else if(farmerDistyMarginMap.containsKey(uniqueStr2+'Farmer')){
                        dmRec=farmerDistyMarginMap.get(uniqueStr2+'Farmer');
                    }
                } 
				if(dmRec!=null)
                    break;
            }
            quoteLine.core_cpq_distributor_margin__c=dmRec?.id;
            quoteLine.core_cpq_config_dm_pct__c=(dmRec!=null?dmRec.core_cpq_Disty_Margin_Pct__c.setScale(1):0);
            quoteLine.core_cpq_distributor_margin_type__c=(dmRec!=null?dmRec.core_cpq_dm_type__c:null);                	
            quoteLine.core_cpq_distributor_margin_pct__c=(dmRec!=null?dmRec.core_cpq_Disty_Margin_Pct__c.setScale(1):0);
            quoteLine.core_cpq_previous_distributor_margin_pct__c = (dmRec!=null?dmRec.core_cpq_Disty_Margin_Pct__c.setScale(1):0);
            quoteLine.core_cpq_Last_DM_Refresh_Date__c=System.today();
            quoteLine.core_cpq_margin_exception_txt__c=null;
            quoteLine.core_cpq_previous_margin_exception_txt__c=null; 
            if(quoteLine.core_cpq_distributor_margin_pct__c != null && quoteLine.price_suggested_resale_amt__c != null){
                quoteLine.price_brokencost_amt__c = (Decimal)(quoteLine.price_suggested_resale_amt__c - (quoteLine.price_suggested_resale_amt__c * (quoteLine.core_cpq_distributor_margin_pct__c/100)))?.setScale(2);
                quoteLine.price_previous_brokencost_amt__c = (Decimal)(quoteLine.price_suggested_resale_amt__c - (quoteLine.price_suggested_resale_amt__c * (quoteLine.core_cpq_distributor_margin_pct__c/100)))?.setScale(2);
            }
        }
    }
    
    /************************************************************************************************************
  *Method Name : afterInsertUpdateOperations
  *Created Date: 08/13/2021
  *Author: Vijay
  *Description : Performs operations on after context of trigger.
  ************************************************************************************************************/
    public static void afterInsertUpdateOperations(List<SBQQ__QuoteLine__c> quoteLineList,
                                                    Boolean isInsert,Map<Id,SBQQ__QuoteLine__c> oldMap,Map<Id,SBQQ__QuoteLine__c> newMap){
        if(quoteLineList != null && !quoteLineList.isEmpty()){ 
            if(isInsert){
                Set<Id> quoteIdSet = new Set<Id>();
                for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                    quoteIdSet.add(quoteLine.SBQQ__Quote__c);
                }
                Set<String> existingOPNSet = new Set<String>();
                Set<String> duplicateOPNSet = new Set<String>();
                if(!quoteIdSet.isEmpty()){
                    for(SBQQ__QuoteLine__c quoteLine : [SELECT Id,core_cpq_opn__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN: quoteIdSet LIMIT :Limits.getLimitDmlRows()]){
                        if(quoteLine.core_cpq_opn__c != null){
                            if(existingOPNSet.contains(quoteLine.core_cpq_opn__c)){
                                duplicateOPNSet.add(quoteLine.core_cpq_opn__c);
                            }else{
                                existingOPNSet.add(quoteLine.core_cpq_opn__c);
                            }
                        }   
                    }
                }
        //PSG System user validation pass bypass
                     if(Label.PSG_System_User != UserInfo.getUserId()){
                for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                      
                         
           if(userIdToRoleMap.containsKey(userInfo.getUserId()) && userIdToRoleMap.get(userInfo.getUserId()) == 'Disty' && duplicateOPNSet.contains(quoteLine.core_cpq_opn__c)){
                        quoteLine.addError('Same OPN cannot be added more than once. Please remove the duplicate line to proceed.');
                    }
                    }
                }
            }
        }
    }
    
    /************************************************************************************************************
  *Method Name : negativeValueCheck
  *Created Date: 08/13/2021
  *Author: Harshadeep
  *Description : Validates for any negative Qty and Pricing attributes for Quote Lines on the Disty portal 
  ************************************************************************************************************/
    public static void negativeValueCheck(SBQQ__QuoteLine__c quoteLine, String cpQuote){        
        Set<Id> negativePricingAttrSet = new Set<Id>();
        Set<Id> negativeQtyAttrSet     = new Set<Id>();
        //String cpQuote = [SELECT Id, SBQQ__Quote__r.core_cpq_quote_type_nm__c FROM SBQQ__QuoteLine__c WHERE Id =: quoteLine.Id].SBQQ__Quote__r.core_cpq_quote_type_nm__c ;
        
        if(quoteLine.price_goal_price_amt__c < 0 || quoteLine.price_suggested_resale_amt__c < 0 || quoteLine.price_requested_resale_amt__c < 0 || quoteLine.price_brokencost_amt__c < 0){
            negativePricingAttrSet.add(quoteLine.Id);
        }
        
        if(quoteLine.core_cpq_lower_bound_qty_qty__c < 0 || quoteLine.core_cpq_upper_bound_qty_nbr__c < 0 || quoteLine.core_cpq_requested_qty__c < 0 || quoteLine.SBQQ__Quantity__c < 0 || quoteLine.core_cpq_years_nbr__c < 0){
            negativeQtyAttrSet.add(quoteLine.Id);
        }
        
   //PSG System user validation pass bypass
        if(Label.PSG_System_User != UserInfo.getUserId()){
        
        if(userIdToRoleMap.get(userInfo.getUserId()) == 'Disty' || cpQuote == 'Contract Pricing'){
            if(!negativePricingAttrSet.isEmpty()){
                quoteLine.addError('One of the following Pricing Attributes has a negative value: Goal Price, Suggested Resale, Requested Resale, Broken Cost');
            }
            else if(!negativeQtyAttrSet.isEmpty()){
                quoteLine.addError('One of the following Quantity Attributes has a negative value: Lower Bound Qty, Upper Bound Qty, Quantity, Requested Qty, # Years');
            }
        }
        }
    }
    
    /************************************************************************************************************
  *Method Name : fetchPricingDetails
  *Created Date: 08/13/2021
  *Author: Vijay
  *Description : Fetches all pricing related object records.
  ************************************************************************************************************/
    public static void fetchPricingDetails(Set<Id> productIdSet,Set<String> productOPNSet,Map<String,PricebookEntry> uniqueIdToPriceBookEntryMap,
                                           Map<String,Map<Date,price_forward_cost__c>> productToFWDMapStartDt,
                                           Map<Id,Boolean> smiFlagInd,Map<Id,Map<Date,price_msvp__c>> productToMSVPMap,
                                           Map<Id,String> prodToolTypeMap,Map<Id,String> authCodeProductMap,Set<Id> priceBookIdSet,
                                           Set<String> accountTierSet,Set<String> accountAllianceSet,Set<String> geoSet,
                                          Map<Id,list<core_cpq_list_price__c>> uniqueIdToListPriceMap){                                   
        for(price_msvp__c msvpRec : [SELECT Id, price_level_1_amt__c, price_level_2_amt__c,core_cpq_product_nm__c,
                                     core_cpq_effective_date_dt__c,CreatedDate FROM price_msvp__c WHERE core_cpq_product_nm__c 
                                     IN: productIdSet and core_cpq_isactive__c = True LIMIT :Limits.getLimitDmlRows()]){                           
            if(!productToMSVPMap.containsKey(msvpRec.core_cpq_product_nm__c)){
                Map<Date,price_msvp__c> temp = new Map<Date,price_msvp__c>();
                temp.put(msvpRec.core_cpq_effective_date_dt__c,msvpRec);
                productToMSVPMap.put(msvpRec.core_cpq_product_nm__c,temp);
            }else{
                productToMSVPMap.get(msvpRec.core_cpq_product_nm__c).put(msvpRec.core_cpq_effective_date_dt__c,msvpRec);
            }
        }
        for(price_forward_cost__c fcprod : [SELECT price_forward_cost_amt__c,core_cpq_fc_end_date_dt__c,core_cpq_product_opn_txt__c,
                                            core_cpq_fc_start_date_dt__c FROM price_forward_cost__c WHERE core_cpq_product_opn_txt__c 
                                            IN: productOPNSet and core_cpq_fc_active_cb__c = true LIMIT :Limits.getLimitDmlRows()]){
            if(!productToFWDMapStartDt.containsKey(fcprod.core_cpq_product_opn_txt__c)){
                Map<Date,price_forward_cost__c> tempStartDate = new Map<Date,price_forward_cost__c>();
                tempStartDate.put(fcprod.core_cpq_fc_start_date_dt__c, fcprod);
                productToFWDMapStartDt.put(fcprod.core_cpq_product_opn_txt__c,tempStartDate);
            }else{
                productToFWDMapStartDt.get(fcprod.core_cpq_product_opn_txt__c).put(fcprod.core_cpq_fc_start_date_dt__c,fcprod);
            }
        }                    
        for(Core_Product_Ext_Attribute__c prodLicense : [Select Id,Core_Product_Id__c,
                                                         Core_Prod_QTE_Slow_Moving_Inventory_Ind__c, Core_Prod_Tool_Type_Nm__c, Core_SW_Lic_Authorization_Cd__c from 
                                                         Core_Product_Ext_Attribute__c where Core_Product_Id__c 
                                                         IN: productIdSet LIMIT :Limits.getLimitDmlRows()]){
            smiFlagInd.put(prodLicense.Core_Product_Id__c, prodLicense.Core_Prod_QTE_Slow_Moving_Inventory_Ind__c);
            prodToolTypeMap.put(prodLicense.Core_Product_Id__c, prodLicense.Core_Prod_Tool_Type_Nm__c);
            authCodeProductMap.put(prodLicense.Core_Product_Id__c, prodLicense.Core_SW_Lic_Authorization_Cd__c);
        }
            String query = 'Select Id,core_cpq_Price_Book__c,core_cpq_Account_Tier_Txt__c,core_cpq_Approved_Registration_Txt__c,core_cpq_Partner_Program_Txt__c,core_cpq_Effective_Date_Dt__c,core_cpq_Disty_Margin_Pct__c,core_cpq_Registered_Product_Txt__c,core_cpq_Margin_GEO_Txt__c,core_cpq_Active_Cb__c,core_cpq_product_family_txt__c,core_cpq_dm_type__c,core_cpq_end_date__c FROM core_cpq_distributor_margin__c where ';
        String whereStr = '';
            Date currDay = System.today();
        if(!geoSet.isEmpty()){
            whereStr = 'core_cpq_Margin_GEO_Txt__c IN:geoSet';
        }
        if(!accountTierSet.isEmpty()){
            if(String.isBlank(whereStr)){
                whereStr = 'core_cpq_Account_Tier_Txt__c IN: accountTierSet';
            }else{
                whereStr = whereStr + ' AND core_cpq_Account_Tier_Txt__c IN: accountTierSet';
            }
        }
        if(!accountAllianceSet.isEmpty()){
            if(String.isBlank(whereStr)){
                whereStr = 'core_cpq_Partner_Program_Txt__c IN:accountAllianceSet';
            }else{
                whereStr = whereStr + ' AND core_cpq_Partner_Program_Txt__c IN:accountAllianceSet';
            }
        }
        if(!priceBookIdSet.isEmpty()){
            if(String.isBlank(whereStr)){
                whereStr = 'core_cpq_Price_Book__c IN: priceBookIdSet';
            }else{
                whereStr = whereStr + ' AND core_cpq_Price_Book__c IN: priceBookIdSet';
            }
        }
        if(String.isBlank(whereStr)){
                query = query + ' core_cpq_Active_Cb__c = true AND core_cpq_Effective_Date_Dt__c <= :currDay AND core_cpq_end_date__c >= :currDay ORDER BY core_cpq_Effective_Date_Dt__c DESC';
        }else{
                query = query + String.escapeSingleQuotes(whereStr) + ' AND core_cpq_Active_Cb__c = true AND core_cpq_Effective_Date_Dt__c <= :currDay AND core_cpq_end_date__c >= :currDay ORDER BY core_cpq_Effective_Date_Dt__c DESC';
        }
        if(String.isNotBlank(query)){
            for(core_cpq_distributor_margin__c distyMargin : DataBase.Query(query)){
            String uniqueStr = '';                                                 
            uniqueStr = uniqueStr +
                        (String.isNotBlank(distyMargin.core_cpq_Margin_GEO_Txt__c) ?  distyMargin.core_cpq_Margin_GEO_Txt__c : '')+
                        (String.isNotBlank(distyMargin.core_cpq_Account_Tier_Txt__c) ?  distyMargin.core_cpq_Account_Tier_Txt__c : '')+ 
                        ((distyMargin.core_cpq_Partner_Program_Txt__c == 'N/A')? '' : distyMargin.core_cpq_Partner_Program_Txt__c)  + 
                        (String.isNotBlank(''+distyMargin.core_cpq_Price_Book__c) ? (''+distyMargin.core_cpq_Price_Book__c) : '') + 
                        (String.isNotBlank(distyMargin.core_cpq_Approved_Registration_Txt__c) ? distyMargin.core_cpq_Approved_Registration_Txt__c : '') +//+distyMargin.core_cpq_Registered_Product_Txt__c; /**To fix Disty Margin % bug commented this "core_cpq_Registered_Product_Txt__c" to match the quote unique String*/
                            distyMargin.core_cpq_Registered_Product_Txt__c +
                            (String.isNotBlank(distyMargin.core_cpq_dm_type__c) ?  distyMargin.core_cpq_dm_type__c : '');    
                
                if(distyMargin.core_cpq_product_family_txt__c != NULL){
                    String uniqueStr1 = uniqueStr + distyMargin.core_cpq_product_family_txt__c;
                    if(!familyHunterDistyMarginMap.containsKey(uniqueStr1) && distyMargin.core_cpq_dm_type__c == 'Hunter'){
                        familyHunterDistyMarginMap.put(uniqueStr1,distyMargin);
                    }else if(!familyFarmerDistyMarginMap.containsKey(uniqueStr1) && distyMargin.core_cpq_dm_type__c == 'Farmer'){
                        familyFarmerDistyMarginMap.put(uniqueStr1,distyMargin);
                    }
                }else if(distyMargin.core_cpq_dm_type__c == 'Hunter' && !hunterDistyMarginMap.containsKey(uniqueStr)){
                    hunterDistyMarginMap.put(uniqueStr,distyMargin);
                }else if(distyMargin.core_cpq_dm_type__c == 'Farmer' && !farmerDistyMarginMap.containsKey(uniqueStr)){
                    farmerDistyMarginMap.put(uniqueStr,distyMargin);
                }
        } 
        }
       
        if(!priceBookIdSet.isEmpty()){
            Set<Id> priceBookentryIdSet = new Set<Id>();
            for(PricebookEntry pbe : [SELECT Id,UnitPrice,price_disty_cost__c ,core_cpq_minimum_order_qty__c,core_cpq_multiple_order_quantity__c,
                                      Product2Id ,Pricebook2Id FROM PricebookEntry WHERE IsActive = true and Product2Id IN: productIdSet 
                                      AND Pricebook2Id IN: priceBookIdSet LIMIT :Limits.getLimitDmlRows()]){
                uniqueIdToPriceBookEntryMap.put(''+pbe.Pricebook2Id + pbe.Product2Id , pbe);
                priceBookentryIdSet.add(pbe.Id);
            }
            //if(!priceBookentryIdSet.isEmpty()){
                for(core_cpq_list_price__c lp : [SELECT Id,Pricebookentry__c, core_cpq_lowerbound_qty__c, core_cpq_upperbound_qty__c, 
                    core_cpq_list_price_amt__c from core_cpq_list_price__c  WHERE Pricebookentry__c IN: priceBookentryIdSet LIMIT :Limits.getLimitDmlRows()]){
                    if (uniqueIdToListPriceMap.containsKey(lp.Pricebookentry__c)){
                        uniqueIdToListPriceMap.get(lp.Pricebookentry__c).add(lp);
                    }else{                                      
                        uniqueIdToListPriceMap.put(lp.Pricebookentry__c, new  List <core_cpq_list_price__c> { lp });
                    }
                } 
            //}                       
        }
    }
    /************************************************************************************************************
  *Method Name : fetchQLwithRestrcitedProduct
  *Created Date: 08/10/2023
  *Author: Ranjit
  *Description : Fetches all QL Records which contains PSG Restricted Product.
  ************************************************************************************************************/
    @Future
    Public static void fetchQLwithRestrcitedProduct(Map<Id,Boolean> prodIdToRegFlagMap){

        Map<Id,Boolean> ProductIdMap=prodIdToRegFlagMap;
        Map<Id,SBQQ__QuoteLine__c> QLMaptoUpdate= new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,String> failedrecordMap = new Map<Id,String>();
        List<Database.SaveResult> result= new List<Database.SaveResult>();
        
        List<SBQQ__QuoteLine__c> QLList=[Select id,SBQQ__Product__c,Name,core_cpq_PSG_Restricted_Product__c,SBQQ__Quote__r.Name from SBQQ__QuoteLine__c where SBQQ__Product__c in:ProductIdMap.keyset() and (SBQQ__Quote__r.core_cpq_status_txt__c ='In Progress' or SBQQ__Quote__r.core_cpq_status_txt__c ='In Review' or SBQQ__Quote__r.core_cpq_status_txt__c ='Pending')  and SBQQ__Quote__r.core_cpq_quote_type_nm__c <> 'Contract Pricing' and core_cpq_quote_active_cb__c=true];
        for(SBQQ__QuoteLine__c ql:QLList){
            ql.core_cpq_PSG_Restricted_Product__c=ProductIdMap.get(ql.SBQQ__Product__c);
            QLMaptoUpdate.put(ql.Id,ql);
        }
        
        if(!QLMaptoUpdate.isEmpty()){
           result=Database.update(QLMaptoUpdate.values(),false);
            for(Integer i=0;i<result.size(); i++){
                Database.SaveResult sr = result[i];
                if (!sr.isSuccess()) {
                    String msg=PSG_QuotewithopptyInactive_Batch.getErrorAsString(sr.getErrors());
                    failedrecordMap.put(sr.getId(),msg);
                }                        
            }
        }
        
        if(!failedrecordMap.isEmpty()){
            PSG_Utility.createCoreLogEntry('PSG_QuoteLineBusinessLogic','PSG_QuoteLineBusinessLogic','Failed Record while processing through fetchQLwithRestrcitedProduct Method',''+failedrecordMap
                                           ,'SBQQ__QuoteLine__c','High','');
        } 
    }
}