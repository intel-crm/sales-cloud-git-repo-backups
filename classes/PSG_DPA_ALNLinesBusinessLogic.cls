/**************************************************************************************
Apex Class Name : PSG_DPA_ALNLinesBusinessLogic
Version     : 1.0 
Created Date: 18th Aug 2021
Description : Controller class to handle trigger functionality on DPA/ALN line object.
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shreyash                 20/03/2020             Original Version
*************************************************************************************/
@isTest
public without sharing class PSG_DPA_ALNLinesBusinessLogic {
    
    /*public static Map<String,core_cpq_distributor_margin__c> familyHunterDistyMarginMap = new Map<String,core_cpq_distributor_margin__c>();
    public static Map<String,core_cpq_distributor_margin__c> familyFarmerDistyMarginMap = new Map<String,core_cpq_distributor_margin__c>();
    public static Map<String,core_cpq_distributor_margin__c> hunterDistyMarginMap = new Map<String,core_cpq_distributor_margin__c>();
    public static Map<String,core_cpq_distributor_margin__c> farmerDistyMarginMap = new Map<String,core_cpq_distributor_margin__c>();
    public static boolean fetchDM = false;
        
    /************************************************************************************************************
    *Method Name : beforeInsertUpdateOperations
    *Created Date: 20/03/2020
    *Author: Shreyash
    *Description : Performs operations on before context of trigger.
    ************************************************************************************************************/
    /*public static void beforeInsertUpdateOperations(List<core_cpq_dpa_aln_line__c> dpa_alnLineList,Map<Id,core_cpq_dpa_aln_line__c > oldMap,Boolean isInsert){
        try{
            Boolean isUpdate = !isInsert;
            if(isInsert){
                Set<Id> dpaIdSet = new Set<Id>();
                Set<Id> quoteLineIdSet = new Set<Id>();
                Set<Id> pridSet = new Set<Id>();
                //Set<Id> productIdSet = new Set<Id>();
                Set<String> accountAllianceSet = new Set<String>();
                Set<String> accountTierSet = new Set<String>();
                Set<String> geoSet = new Set<String>();
                Set<Id> priceBookIdSet = new Set<Id>();
                Map <Id, core_cpq_dpa_aln__c> dpaMap = new Map<Id, core_cpq_dpa_aln__c>();
                Map <Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
                Map <Id, price_prid__c> pridMap = new Map<Id, price_prid__c>();
                //List<Id> productIdList = new List<Id>();
                Set<String> existingPartnerProgram = new Set<String>{'PSG Demand Creation - Distribution','PSG Demand Creation - Hybrid','PSG Demand Creation - PSG'};
                for(core_cpq_dpa_aln_line__c  dpa_aln_line : dpa_alnLineList){          
                    if(dpa_aln_line.core_cpq_cis_no_nbr__c != null){
                        dpaIdSet.add(dpa_aln_line.core_cpq_cis_no_nbr__c);
                    }
                    if(dpa_aln_line.core_cpq_quote_item_line_no__c != null){
                        quoteLineIdSet.add(dpa_aln_line.core_cpq_quote_item_line_no__c);
                    }
                    if(dpa_aln_line.core_cpq_prid__c != null){
                        pridSet.add(dpa_aln_line.core_cpq_prid__c);
                    }
                    /*if(dpa_aln_line.core_cpq_device_nm__c != null){
                        productIdSet.add(dpa_aln_line.core_cpq_device_nm__c);
                    }*/
                /*}
                if(!dpaIdSet.isEmpty()){
                    dpaMap = new Map<Id, core_cpq_dpa_aln__c>([SELECT id, core_cpq_ship_end_date_dt__c, core_cpq_ship_start_date_dt__c,core_cpq_duration_nbr__c,Name,core_cpq_record_type_identifier__c,core_cpq_account_tier__c,
                                                               core_cpq_active_quote__r.SBQQ__PriceBook__c,core_cpq_account_program__c,core_cpq_active_quote__c,core_cpq_active_quote__r.core_cpq_margin_geo_txt__c,
                                                               core_cpq_active_quote__r.core_cpq_price_book_nm__c,core_cpq_active_quote__r.core_cpq_quote_type_nm__c FROM core_cpq_dpa_aln__c WHERE Id IN: dpaIdSet]);
                }
                if(!dpaMap.isEmpty()){
                    for(core_cpq_dpa_aln__c dpaAln : dpaMap.values()){
                        if(dpaAln.core_cpq_active_quote__r.core_cpq_quote_type_nm__c != 'Contract Pricing'){
                            if(dpaAln.core_cpq_account_program__c != null){
                                accountAllianceSet.addAll(dpaAln.core_cpq_account_program__c.split(';'));
                            }
                            if(dpaAln.core_cpq_account_tier__c != null){
                                accountTierSet.add(dpaAln.core_cpq_account_tier__c);
                            }
                            if(dpaAln.core_cpq_active_quote__r.core_cpq_margin_geo_txt__c != Null){
                                geoSet.add(dpaAln.core_cpq_active_quote__r.core_cpq_margin_geo_txt__c);
                            }else{
                                geoSet.add('');
                            }
                            if(dpaAln.core_cpq_active_quote__r.core_cpq_price_book_nm__c != Null){
                                priceBookIdSet.add(dpaAln.core_cpq_active_quote__r.core_cpq_price_book_nm__c);
                            }
                        }
                    }
                    //Changes made for Too many query rows 50001 error 
                    if(!accountAllianceSet.isEmpty() || !accountTierSet.isEmpty() || !geoSet.isEmpty() || !priceBookIdSet.isEmpty()){
                        fetchDistyMarginRecords(accountAllianceSet,accountTierSet,geoSet,priceBookIdSet);
                    }
                    
                }
                if(!quoteLineIdSet.isEmpty()){
                    quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT id,core_cpq_PRID__c,core_cpq_distributor_margin_pct__c,core_cpq_product_nm__c,price_broken_cost_cp__c,Name,
                                                                   core_cpq_requested_qty__c,core_cpq_lower_bound_qty_qty__c,core_cpq_upper_bound_qty_nbr__c,SBQQ__Quantity__c,core_cpq_registerable_flag__c,core_cpq_design_reg_status__c,core_cpq_master_ddr__c,
                                                                   SBQQ__ListPrice__c,price_brokencost_amt__c,price_suggested_resale_amt__c,core_cpq_disty_value_add_dpa__c,core_cpq_product_family_txt__c FROM SBQQ__QuoteLine__c WHERE Id IN: quoteLineIdSet]);
                }
                if(!pridSet.isEmpty()){
                    pridMap = new Map<Id,price_prid__c>([Select id,core_cpq_prid_validity_date_dt__c from price_prid__c Where Id IN: pridSet]);
                }
                /*if(!productIdSet.isEmpty()){
                    for(Product2 prod : [Select id from Product2 where IsActive = true and Core_Item_Quotable_Ind__c = true and Id IN :productIdSet]){
                        productIdList.add(prod.Id);
                    }
                }*/
                
                /*for(core_cpq_dpa_aln_line__c  dpa_aln_line : dpa_alnLineList){
                    if(quoteLineMap.containsKey(dpa_aln_line.core_cpq_quote_item_line_no__c)){
                        dpa_aln_line.core_cpq_prid__c = quoteLineMap.get(dpa_aln_line.core_cpq_quote_item_line_no__c).core_cpq_PRID__c;
                        dpa_aln_line.core_cpq_disty_margin_pct__c = quoteLineMap.get(dpa_aln_line.core_cpq_quote_item_line_no__c).core_cpq_distributor_margin_pct__c?.setScale(1);
                        dpa_aln_line.core_cpq_device_nm__c = quoteLineMap.get(dpa_aln_line.core_cpq_quote_item_line_no__c).core_cpq_product_nm__c;
                        if(dpa_aln_line.core_cpq_requested_qty_nbr__c==null){
                        	dpa_aln_line.core_cpq_requested_qty_nbr__c = quoteLineMap.get(dpa_aln_line.core_cpq_quote_item_line_no__c).core_cpq_requested_qty__c;
                        }
                        dpa_aln_line.core_cpq_lower_bound_qty_nbr__c = quoteLineMap.get(dpa_aln_line.core_cpq_quote_item_line_no__c).core_cpq_lower_bound_qty_qty__c;
                        dpa_aln_line.core_cpq_upper_bound_qty_nbr__c = quoteLineMap.get(dpa_aln_line.core_cpq_quote_item_line_no__c).core_cpq_upper_bound_qty_nbr__c;
                        dpa_aln_line.core_cpq_quoted_qty_nbr__c = quoteLineMap.get(dpa_aln_line.core_cpq_quote_item_line_no__c).SBQQ__Quantity__c;
                        dpa_aln_line.core_list_unit_price__c = quoteLineMap.get(dpa_aln_line.core_cpq_quote_item_line_no__c).SBQQ__ListPrice__c;
                        dpa_aln_line.price_broken_cost_disty_amt__c = quoteLineMap.get(dpa_aln_line.core_cpq_quote_item_line_no__c).price_brokencost_amt__c?.setScale(2);
                        dpa_aln_line.core_cpq_resale_amt__c = quoteLineMap.get(dpa_aln_line.core_cpq_quote_item_line_no__c).price_suggested_resale_amt__c?.setScale(2);
                        if(dpaMap.containsKey(dpa_aln_line.core_cpq_cis_no_nbr__c) && dpaMap.get(dpa_aln_line.core_cpq_cis_no_nbr__c).core_cpq_record_type_identifier__c=='DPA' && dpa_aln_line.price_disty_value_added_amt__c==null){
                            dpa_aln_line.price_disty_value_added_amt__c = quoteLineMap.get(dpa_aln_line.core_cpq_quote_item_line_no__c).core_cpq_disty_value_add_dpa__c;
                        }
                        if(dpaMap.get(dpa_aln_line.core_cpq_cis_no_nbr__c).core_cpq_active_quote__r.core_cpq_quote_type_nm__c != 'Contract Pricing'){
                            String prodFamily = quoteLineMap.get(dpa_aln_line.core_cpq_quote_item_line_no__c).core_cpq_product_family_txt__c;
                            price_prid__c prid = new price_prid__c();
                            if(dpa_aln_line.core_cpq_prid__c != Null){
                                prid = pridMap.get(dpa_aln_line.core_cpq_prid__c);
                            }
                            updateDistiMargin(dpaMap,dpa_aln_line,quoteLineMap,prodFamily,prid,existingPartnerProgram);
                        }
                    }
                    if(dpaMap.containsKey(dpa_aln_line.core_cpq_cis_no_nbr__c)){
                        dpa_aln_line.core_cpq_ship_start_date_dt__c  = dpaMap.get(dpa_aln_line.core_cpq_cis_no_nbr__c).core_cpq_ship_start_date_dt__c;
                        dpa_aln_line.core_cpq_ship_exp_date_dt__c = dpaMap.get(dpa_aln_line.core_cpq_cis_no_nbr__c).core_cpq_ship_end_date_dt__c;
                        dpa_aln_line.core_cpq_duration_nbr__c = dpaMap.get(dpa_aln_line.core_cpq_cis_no_nbr__c).core_cpq_duration_nbr__c;
                    }
                }
            }
            if(isUpdate){
                //Set<Id> dpaIdSet = new Set<Id>(); 
                //Map <Id, core_cpq_dpa_aln__c> dpaMap = new Map<Id, core_cpq_dpa_aln__c>();
                //Map <Id, SBQQ__QuoteLine__c> quoteLineToChangeDistyPercentMap = new Map<Id, SBQQ__QuoteLine__c>();
                /*for(core_cpq_dpa_aln_line__c  dpa_aln_line : dpa_alnLineList){          
                    if(dpa_aln_line.core_cpq_cis_no_nbr__c != null){
                        dpaIdSet.add(dpa_aln_line.core_cpq_cis_no_nbr__c);
                    }
                }
                if(!dpaIdSet.isEmpty()){
                    dpaMap = new Map<Id, core_cpq_dpa_aln__c>([SELECT id,core_cpq_active_quote__r.core_cpq_quote_type_nm__c  FROM core_cpq_dpa_aln__c WHERE Id IN: dpaIdSet]);
                }*/
                /*for(core_cpq_dpa_aln_line__c  dpa_aln_line : dpa_alnLineList){
                    if((oldMap.get(dpa_aln_line.Id).core_cpq_disty_margin_pct__c != dpa_aln_line.core_cpq_disty_margin_pct__c) ){//added
                        dpa_aln_line.core_cpq_disty_margin_pct__c= dpa_aln_line.core_cpq_disty_margin_pct__c == null ? 0 : dpa_aln_line.core_cpq_disty_margin_pct__c?.setScale(1);
                        if(dpa_aln_line.core_cpq_resale_amt__c == null){dpa_aln_line.core_cpq_resale_amt__c = 0;}
                        dpa_aln_line.price_broken_cost_disty_amt__c = (dpa_aln_line.core_cpq_resale_amt__c -(dpa_aln_line.core_cpq_resale_amt__c * (dpa_aln_line.core_cpq_disty_margin_pct__c/100)))?.setScale(2);
                    }
                }
                for(core_cpq_dpa_aln_line__c  dpa_aln_line : dpa_alnLineList){          
                    if((oldMap.get(dpa_aln_line.Id).core_cpq_ship_exp_date_dt__c != dpa_aln_line.core_cpq_ship_exp_date_dt__c) || (oldMap.get(dpa_aln_line.Id).core_cpq_ship_start_date_dt__c != dpa_aln_line.core_cpq_ship_start_date_dt__c )  ){
                        dpa_aln_line.core_cpq_duration_nbr__c=dpa_aln_line.core_cpq_ship_start_date_dt__c.monthsBetween(dpa_aln_line.core_cpq_ship_exp_date_dt__c);
                    }
                    if((oldMap.get(dpa_aln_line.Id).core_cpq_duration_nbr__c != dpa_aln_line.core_cpq_duration_nbr__c) ){
                        dpa_aln_line.core_cpq_ship_exp_date_dt__c= dpa_aln_line.core_cpq_ship_start_date_dt__c.addMonths((integer)dpa_aln_line.core_cpq_duration_nbr__c);
                    }
                }
            }
        }catch(Exception ex){
            PSG_Utility.logError(ex);
        }
    }
	/************************************************************************************************************
    *Method Name : beforeDeleteOperations
    *Created Date: 20/03/2020
    *Author: Shreyash
    *Description : Performs operations on before context of trigger.
    ************************************************************************************************************/
    /*public static void beforeDeleteOperations(List<core_cpq_dpa_aln_line__c> dpa_alnLineList,Map<Id,core_cpq_dpa_aln_line__c > oldMap,Boolean isDelete){
        if(isDelete){
            Set<Id> dpaIdSet = new Set<Id>();
            //Set<Id> quoteLineIdSet = new Set<Id>();
            Map <Id, core_cpq_dpa_aln__c> dpaMap = new Map<Id, core_cpq_dpa_aln__c>();
            //Map <Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
            for(core_cpq_dpa_aln_line__c  dpa_aln_line : dpa_alnLineList){          
                if(dpa_aln_line.core_cpq_cis_no_nbr__c != null){
                    dpaIdSet.add(dpa_aln_line.core_cpq_cis_no_nbr__c);
                }
            }
            if(!dpaIdSet.isEmpty()){
                dpaMap = new Map<Id, core_cpq_dpa_aln__c>([SELECT id,core_cpq_last_updated_in_sap__c  FROM core_cpq_dpa_aln__c WHERE Id IN: dpaIdSet]);
            }
            for(core_cpq_dpa_aln_line__c  dpa_aln_line : dpa_alnLineList){
                if(dpaMap.containsKey(dpa_aln_line.core_cpq_cis_no_nbr__c) && Label.PSG_System_User != UserInfo.getUserId()){
                    if(dpaMap.get(dpa_aln_line.core_cpq_cis_no_nbr__c).core_cpq_last_updated_in_sap__c != null){
                        dpa_aln_line.addError('Cannot delete a line which is submitted to SAP');
                    }
                }
            }           
        }
    }
    /************************************************************************************************************
    *Method Name : fetchDistyMarginRecords
    *Created Date: 01/05/2023
    *Author: Adarsh Parashar
    *Description : Method to fetch Distributor Margin records.
    ************************************************************************************************************/
    /*public static void fetchDistyMarginRecords(Set<String> accountAllianceSet,Set<String> accountTierSet,Set<String> geoSet,Set<Id> priceBookIdSet){
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
                            /*distyMargin.core_cpq_Registered_Product_Txt__c +
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
            
    }
    /************************************************************************************************************
    *Method Name : updateDistiMargin
    *Created Date: 01/05/2023
    *Author: Adarsh Parashar
    *Description : Updates Disti margin on DPA/ALN Lines.
    ************************************************************************************************************/
    /*public static core_cpq_distributor_margin__c updateDistiMargin(Map<Id,core_cpq_dpa_aln__c> dpaMap,core_cpq_dpa_aln_line__c dpaAlnLine,
                                         Map<Id,SBQQ__QuoteLine__c> quoteLineMap,String productFamily,price_prid__c prid,
                                         Set<String> existingPartnerProgram){      
        core_cpq_distributor_margin__c dmRecord=null;                                     
        if(dpaMap.containsKey(dpaAlnLine.core_cpq_cis_no_nbr__c)){
            core_cpq_dpa_aln__c dpaAln  = dpaMap.get(dpaAlnLine.core_cpq_cis_no_nbr__c);
            Set<String> uniqueStrSet = new Set<String>();
            String accProgram=(dpaAln.core_cpq_account_program__c != null?dpaAln.core_cpq_account_program__c:'');
            for(String localPartnerProgram : accProgram.split(';')){
                String uniqueStr = '';
                if(dpaMap.get(dpaAlnLine.core_cpq_cis_no_nbr__c).core_cpq_active_quote__r.core_cpq_margin_geo_txt__c != null){
                    uniqueStr = uniqueStr+dpaMap.get(dpaAlnLine.core_cpq_cis_no_nbr__c).core_cpq_active_quote__r.core_cpq_margin_geo_txt__c;
                }
                if(dpaMap.get(dpaAlnLine.core_cpq_cis_no_nbr__c).core_cpq_account_tier__c != null){
                    uniqueStr = uniqueStr+dpaMap.get(dpaAlnLine.core_cpq_cis_no_nbr__c).core_cpq_account_tier__c;
                }
                if(existingPartnerProgram.contains(localPartnerProgram)){
                    uniqueStr = uniqueStr+localPartnerProgram;
                }
                if(dpaMap.get(dpaAlnLine.core_cpq_cis_no_nbr__c).core_cpq_active_quote__r.SBQQ__PriceBook__c != null){
                    uniqueStr = uniqueStr+dpaMap.get(dpaAlnLine.core_cpq_cis_no_nbr__c).core_cpq_active_quote__r.SBQQ__PriceBook__c;
                }                
                if(quoteLineMap.get(dpaAlnLine.core_cpq_quote_item_line_no__c).core_cpq_design_reg_status__c == 'Approved' || quoteLineMap.get(dpaAlnLine.core_cpq_quote_item_line_no__c).core_cpq_master_ddr__c != null){
                    uniqueStr = uniqueStr + 'Yes';                    
                }else{
                    uniqueStr = uniqueStr + 'No';
                }                
                uniqueStr = uniqueStr + quoteLineMap.get(dpaAlnLine.core_cpq_quote_item_line_no__c).core_cpq_registerable_flag__c;                
                if(String.isNotBlank(uniqueStr)){
                    uniqueStrSet.add(uniqueStr);
                }   
            }
            for(String uniqueStr2 : uniqueStrSet){
                String dmType='Hunter';
                if(prid != null && prid?.core_cpq_prid_validity_date_dt__c != null && prid?.core_cpq_prid_validity_date_dt__c < System.today()){
                    dmType='Farmer';
                }
                if(dmType=='Hunter' && familyHunterDistyMarginMap.containsKey(uniqueStr2+'Hunter'+productFamily)){
                    dmRecord=familyHunterDistyMarginMap.get(uniqueStr2+'Hunter'+productFamily);
                }else if(dmType=='Hunter' && hunterDistyMarginMap.containsKey(uniqueStr2+'Hunter')){
                    dmRecord=hunterDistyMarginMap.get(uniqueStr2+'Hunter');
                }else if(familyFarmerDistyMarginMap.containsKey(uniqueStr2+'Farmer'+productFamily)){
                    dmRecord=familyFarmerDistyMarginMap.get(uniqueStr2+'Farmer'+productFamily);
                }else if(farmerDistyMarginMap.containsKey(uniqueStr2+'Farmer')){
                    dmRecord=farmerDistyMarginMap.get(uniqueStr2+'Farmer');
                }               
                if(dmRecord!=null)
                    break;
            }          
            dpaAlnLine.core_cpq_distributor_margin__c=dmRecord?.id;
            dpaAlnLine.core_cpq_disty_margin_pct__c = (dmRecord!=null?dmRecord.core_cpq_Disty_Margin_Pct__c.setScale(1):0);
            dpaAlnLine.core_cpq_distributor_margin_type__c =(dmRecord!=null?dmRecord.core_cpq_dm_type__c:null); 
            dpaAlnLine.core_cpq_Last_DM_Refresh_Date__c=System.today();
            if(dpaAlnLine.core_cpq_disty_margin_pct__c != null && dpaAlnLine.core_cpq_resale_amt__c != null){
                dpaAlnLine.price_broken_cost_disty_amt__c = (Decimal)(dpaAlnLine.core_cpq_resale_amt__c - (dpaAlnLine.core_cpq_resale_amt__c * (dpaAlnLine.core_cpq_disty_margin_pct__c/100)))?.setScale(2);
            }
        }
        return dmRecord;
    }*/
}