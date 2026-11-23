/****************************************************************************************************
Apex Class Name : PSG_CPQuoteLinesBusinessLogic
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Business logic class for Contract pricing Quote Lines trigger operations.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshadeep             08/13/2021                Created
*****************************************************************************************************/

public without sharing class PSG_CPQuoteLinesBusinessLogic {
    /*
    public static Boolean fetchPriceDataRecursiveCheck = false;
    /************************************************************************************************************
    *Method Name : beforeInsertUpdateOperations
    *Created Date: 08/13/2021
    *Author: Harshadeep
    *Description : Performs operations on before context of trigger.
    ************************************************************************************************************/
    /*
    public static void beforeInsertUpdateOperations(List<SBQQ__QuoteLine__c> quoteLineList, Boolean isInsert,Map<id,SBQQ__QuoteLine__c> oldMap){
        if(quoteLineList != null && !quoteLineList.isEmpty()){
            Set<Id> productIdSet = new Set<Id>();
            Set<String> productOPNSet = new Set<String>();
            Map<Id,Boolean> orderFlagInd = new Map<Id,Boolean>();
            //added sayyed
			Map<String,PricebookEntry> uniqueIdToPriceBookEntryMap = new Map<String,PricebookEntry>();
			Map<String,Map<Date,price_forward_cost__c>> productToFWDMapStartDt = new Map<String,Map<Date,price_forward_cost__c>>();
			Map<Id,Boolean> smiFlagInd = new Map<Id,Boolean>();
			Map<Id,Map<Date,price_msvp__c>> productToMSVPMap = new Map<Id,Map<Date,price_msvp__c>>();
			Map<Id,String> prodToolTypeMap = new Map<Id,String>();
			Map<Id,String> authCodeProductMap = new Map<Id,String>(); 
			Set<Id> priceBookIdSet = new Set<Id>();
			Set<String> accountTierSet = new Set<String>(); 
			Set<String> accountAllianceSet = new Set<String>();
			Set<String> geoSet = new Set<String>();
			Map<Id,list<core_cpq_list_price__c>> uniqueIdToListPriceMap = new map<Id,list<core_cpq_list_price__c>>();
            Set<String> existingPartnerProgram = new Set<String>{'PSG Demand Creation - Distribution','PSG Demand Creation - Hybrid','PSG Demand Creation - PSG'};
            Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap = new Map<Id,SBQQ__Quote__c>();
            
            if(isInsert){
               Set<Id> quoteIdSet = new Set<Id>();
              
               Map <Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
                for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                    quoteIdSet.add(quoteLine.SBQQ__Quote__c);
                }
                if(!quoteIdSet.isEmpty()){
                    quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT id, core_cpq_quote_type_nm__c,core_cpq_sap_ecp_nm__c, core_cpq_price_eligibility_date_dt__c,core_cpq_pricing_end_date_dt__c,core_cpq_reviewer__c, core_cpq_pricing_start_date_dt__c,core_cpq_review_date_dt__c FROM SBQQ__Quote__c WHERE Id IN: quoteIdSet]);
                }
                for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                    if(quoteLine.core_cpq_price_eligibility_date_dt__c == null){
                            quoteLine.core_cpq_price_eligibility_date_dt__c  = quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_eligibility_date_dt__c;
                            
                    }
                    if(quoteMap.containsKey(quoteLine.SBQQ__Quote__c)){
                    	quoteLine.core_cpq_sap_ecp_nm__c = quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_sap_ecp_nm__c;
                    }
                    
                    quoteLine.core_cpq_lower_bound_qty_qty__c = quoteLine.SBQQ__Quantity__c == 0 ? 0 : 1;
                    quoteLine.core_cpq_upper_bound_qty_nbr__c = quoteLine.SBQQ__Quantity__c == 0 ? 0 : quoteLine.SBQQ__Quantity__c + quoteLine.core_cpq_lower_bound_qty_qty__c - 1;
                    quoteLine.core_cpq_previous_lower_bound_qty_nbr__c = quoteLine.core_cpq_lower_bound_qty_qty__c;
                    quoteLine.core_cpq_previous_upper_bound_qty_nbr__c = quoteLine.core_cpq_upper_bound_qty_nbr__c;
                    
                    /*if(quoteLine.price_broken_cost_cp__c!=null){
                        quoteLine.price_brokencost_amt__c=(quoteLine.price_broken_cost_cp__c*1).setScale(2);
                    }*/
                    //if(quoteLine.core_cpq_distributor_margin_pct__c==nu)
                    /*quoteLine.core_cpq_distributor_margin_pct__c = quoteLine.core_cpq_distributor_margin_pct__c == null ? 0 : quoteLine.core_cpq_distributor_margin_pct__c.setScale(1);
                    quoteLine.core_cpq_previous_distributor_margin_pct__c = quoteLine.core_cpq_distributor_margin_pct__c;
                    quoteLine.price_suggested_resale_amt__c = (quoteLine.price_suggested_resale_amt__c == null ? 0 : quoteLine.price_suggested_resale_amt__c)?.setScale(2);
                    if(quoteLine.core_cpq_distributor_margin_pct__c != null && quoteLine.price_suggested_resale_amt__c != null){
                        quoteLine.price_brokencost_amt__c = (quoteLine.price_suggested_resale_amt__c - (quoteLine.price_suggested_resale_amt__c * (quoteLine.core_cpq_distributor_margin_pct__c/100)))?.setScale(2);
                        quoteLine.price_previous_brokencost_amt__c = (quoteLine.price_suggested_resale_amt__c - (quoteLine.price_suggested_resale_amt__c * (quoteLine.core_cpq_distributor_margin_pct__c/100)))?.setScale(2);
                    } 
                    if(!quoteLineList.isEmpty()){
                         PSG_QuoteLineBusinessLogic.negativeValueCheck(quoteLine,quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c);
                    }
                    if(quoteLine.core_cpq_product_nm__c != null){
                        quoteLine.SBQQ__Product__c = quoteLine.core_cpq_product_nm__c;
                        productIdSet.add(quoteLine.SBQQ__Product__c);
                        productOPNSet.add(quoteLine.Core_OPN__c);
                    }else if(quoteLine.SBQQ__Product__c != null){
                            quoteLine.core_cpq_product_nm__c=quoteLine.SBQQ__Product__c;
                            productIdSet.add(quoteLine.SBQQ__Product__c);
                        	productOPNSet.add(quoteLine.Core_OPN__c);
                    }
                    if(quoteLine.core_cpq_pricing_end_date_dt__c == null){
                            quoteLine.core_cpq_pricing_end_date_dt__c  = quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_pricing_end_date_dt__c;
                    }
                    if(quoteLine.Core_OPN__c!=null){
                        quoteLine.core_cpq_opn__c=quoteLine.Core_OPN__c;
                    }
                    if(quoteLine.core_cpq_reviewer__c == null){
                            quoteLine.core_cpq_reviewer__c  = quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_reviewer__c;
                    }
                    if(quoteLine.core_cpq_review_date_dt__c == null){
                            quoteLine.core_cpq_review_date_dt__c  = quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_review_date_dt__c;
                    }
                    if(quoteLine.core_cpq_pricing_start_date_dt__c == null){
                            quoteLine.core_cpq_pricing_start_date_dt__c  = quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_pricing_start_date_dt__c;
                    }
                    if(quoteLine.core_cpq_years_nbr__c == null){
                            quoteLine.core_cpq_years_nbr__c  = 1;
                    }
                    quoteLine.core_cpq_unique_id__c = ''+ quoteLine.SBQQ__Quote__c                                                        
                                                        + quoteLine.recordtypeid
                                                        + quoteLine.SBQQ__Product__c ; 
                    
                    if(quoteLine.SBQQ__CustomerPrice__c == null){
                        quoteLine.SBQQ__CustomerPrice__c = 0;
                    }
                    if(quoteLine.SBQQ__NetPrice__c == null){
                        quoteLine.SBQQ__NetPrice__c = 0;
                    }
                    if(quoteLine.SBQQ__PartnerPrice__c == null){
                        quoteLine.SBQQ__PartnerPrice__c = 0;
                    }
                    if(quoteLine.SBQQ__RegularPrice__c == null){
                        quoteLine.SBQQ__RegularPrice__c = 0;
                    }
                    if(quoteLine.SBQQ__UpliftAmount__c == null){
                        quoteLine.SBQQ__UpliftAmount__c = 0;
                    }
                    if(quoteLine.SBQQ__SpecialPrice__c  == null){
                        quoteLine.SBQQ__SpecialPrice__c  = 0;
                    }
                    if(quoteLine.SBQQ__ListPrice__c == null){   
                        quoteLine.SBQQ__ListPrice__c = 0; 
                    }
                    
                }   
                for(product2 prod:[SELECT Id,Core_OPN__c, Core_Item_Orderable_Ind__c FROM Product2 where Id IN : productIdSet]){
                    orderFlagInd.put(prod.Id, prod.Core_Item_Orderable_Ind__c);
                }
				//added sayyed
				if(!quoteIdSet.isEmpty()){
					for(SBQQ__Quote__c quote : [SELECT Id,core_cpq_date_submitted_dt__c,SBQQ__Account__c,core_cpq_end_customer_nm__r.Core_Account_PSG_Tier__c,
												core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c,createddate,core_cpq_price_book_nm__c,core_cpq_account_tier__c,
												SBQQ__Opportunity2__c,SBQQ__PriceBook__c,core_cpq_sap_ecp_nm__c,core_cpq_quote_type_nm__c,
												core_cpq_margin_geo_txt__c from SBQQ__Quote__c where Id IN: quoteIdSet]){
						quoteIdToQuoteMap.put(quote.Id,quote);                        
						if(quote.core_cpq_price_book_nm__c != null){
							priceBookIdSet.add(quote.core_cpq_price_book_nm__c);
							quoteMap.put(quote.Id,quote);
						}
						if(quote.core_cpq_account_tier__c != null){
							accountTierSet.add(quote.core_cpq_account_tier__c);
						}
						if(quote.core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c != null && existingPartnerProgram.contains(quote.core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c)){
							accountAllianceSet.add(quote.core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c);
						}
						if(quote.core_cpq_margin_geo_txt__c != null){
							geoSet.add(quote.core_cpq_margin_geo_txt__c);
						}
					}
				}
                if(!productIdSet.isEmpty()){
			PSG_QuoteLineBusinessLogic.fetchPricingDetails(productIdSet,productOPNSet,uniqueIdToPriceBookEntryMap,productToFWDMapStartDt,
                                                                    smiFlagInd,productToMSVPMap,prodToolTypeMap,authCodeProductMap,priceBookIdSet,accountTierSet,
                                                                    accountAllianceSet,geoSet,uniqueIdToListPriceMap,true);
                }
				
				//*******				                
                for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                    if(orderFlagInd.containsKey(quoteline.SBQQ__Product__c)){
                         quoteLine.core_cpq_orderable_ind__c = orderFlagInd.get(quoteLine.SBQQ__Product__c);
                    }
					//added sayyed
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
                                }
                            }
                        }
						//***************  
                }
            }
            if(!isInsert){
                Set<Id> quoteIdSet = new Set<Id>();
                Map <Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
                for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                    quoteIdSet.add(quoteLine.SBQQ__Quote__c);
                   
                    //if(oldMap.get(quoteLine.Id).core_cpq_distributor_margin_pct__c != quoteLine.core_cpq_distributor_margin_pct__c || oldMap.get(quoteLine.Id).price_suggested_resale_amt__c != quoteLine.price_suggested_resale_amt__c){
                        quoteLine.core_cpq_distributor_margin_pct__c = quoteLine.core_cpq_distributor_margin_pct__c == null ? 0 : quoteLine.core_cpq_distributor_margin_pct__c.setScale(1);
                        quoteLine.core_cpq_previous_distributor_margin_pct__c = quoteLine.core_cpq_distributor_margin_pct__c;
                        quoteLine.price_suggested_resale_amt__c = (quoteLine.price_suggested_resale_amt__c == null ? 0 : quoteLine.price_suggested_resale_amt__c)?.setScale(2);
                        quoteLine.price_brokencost_amt__c = (quoteLine.price_suggested_resale_amt__c - (quoteLine.price_suggested_resale_amt__c * (quoteLine.core_cpq_distributor_margin_pct__c/100)))?.setScale(2);
                        quoteLine.price_previous_brokencost_amt__c = (quoteLine.price_suggested_resale_amt__c - (quoteLine.price_suggested_resale_amt__c * (quoteLine.core_cpq_distributor_margin_pct__c/100)))?.setScale(2);
                    //}
                    if(quoteLine.core_cpq_years_nbr__c == null){
                        quoteLine.core_cpq_years_nbr__c  = 1;
                    }
                    
                    if(quoteLine.SBQQ__CustomerPrice__c == null){
                        quoteLine.SBQQ__CustomerPrice__c = 0;
                    }
                    if(quoteLine.SBQQ__NetPrice__c == null){
                        quoteLine.SBQQ__NetPrice__c = 0;
                    }
                    if(quoteLine.SBQQ__PartnerPrice__c == null){
                        quoteLine.SBQQ__PartnerPrice__c = 0;
                    }
                    if(quoteLine.SBQQ__RegularPrice__c == null){
                        quoteLine.SBQQ__RegularPrice__c = 0;
                    }
                    if(quoteLine.SBQQ__UpliftAmount__c == null){
                        quoteLine.SBQQ__UpliftAmount__c = 0;
                    }
                    if(quoteLine.SBQQ__SpecialPrice__c  == null){
                        quoteLine.SBQQ__SpecialPrice__c  = 0;
                    }
                    if(quoteLine.SBQQ__ListPrice__c  == null){
                        quoteLine.SBQQ__ListPrice__c  = 0;
                    }
                    
                    
                    if(oldMap.get(quoteLine.Id)?.core_cpq_lower_bound_qty_qty__c != quoteLine?.core_cpq_lower_bound_qty_qty__c){
                        quoteLine.core_cpq_previous_lower_bound_qty_nbr__c =  oldMap.get(quoteLine.Id)?.core_cpq_lower_bound_qty_qty__c;
                        quoteLine.SBQQ__Quantity__c = (quoteLine?.core_cpq_upper_bound_qty_nbr__c - quoteLine?.core_cpq_lower_bound_qty_qty__c) + 1;
                    }else if(oldMap.get(quoteLine.Id)?.core_cpq_upper_bound_qty_nbr__c != quoteLine?.core_cpq_upper_bound_qty_nbr__c){
                        quoteLine.core_cpq_previous_upper_bound_qty_nbr__c =  oldMap.get(quoteLine.Id)?.core_cpq_upper_bound_qty_nbr__c;
                        quoteLine.SBQQ__Quantity__c = (quoteLine.core_cpq_upper_bound_qty_nbr__c - quoteLine?.core_cpq_lower_bound_qty_qty__c) + 1;
                    }else if(oldMap.get(quoteLine.Id)?.SBQQ__Quantity__c != quoteLine?.SBQQ__Quantity__c){
                        quoteLine.core_cpq_previous_upper_bound_qty_nbr__c = oldMap.get(quoteLine.Id)?.core_cpq_upper_bound_qty_nbr__c;
                        quoteLine.core_cpq_upper_bound_qty_nbr__c = quoteLine?.SBQQ__Quantity__c == 0 ? 0 : quoteLine?.SBQQ__Quantity__c + quoteLine?.core_cpq_lower_bound_qty_qty__c - 1;
                    }
                    
                }
                if(!quoteIdSet.isEmpty()){
                    quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT id, core_cpq_quote_type_nm__c, core_cpq_price_eligibility_date_dt__c,core_cpq_pricing_end_date_dt__c,core_cpq_reviewer__c, core_cpq_pricing_start_date_dt__c,core_cpq_review_date_dt__c FROM SBQQ__Quote__c WHERE Id IN: quoteIdSet]);
                    for(SBQQ__Quote__c quote : [SELECT Id,core_cpq_date_submitted_dt__c,SBQQ__Status__c,SBQQ__Account__c,core_cpq_end_customer_nm__r.Core_Account_PSG_Tier__c,
                                                core_cpq_end_customer_nm__r.Core_Partner_Alliance_Program__c,createddate,core_cpq_price_book_nm__c,SBQQ__Opportunity2__c,core_cpq_account_tier__c,
                                                SBQQ__PriceBook__c,core_cpq_sap_ecp_nm__c,core_cpq_quote_type_nm__c,
                                                core_cpq_margin_geo_txt__c from SBQQ__Quote__c where Id IN: quoteIdSet]){
                                                    quoteIdToQuoteMap.put(quote.Id,quote);
                                                    priceBookIdSet.add(quote.core_cpq_price_book_nm__c);
                    }                    
                }
                for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                    if(!quoteLineList.isEmpty()){
                         PSG_QuoteLineBusinessLogic.negativeValueCheck(quoteLine,quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_quote_type_nm__c);
                    }
                    if(quoteLine.SBQQ__Product__c != null){
                            quoteLine.core_cpq_product_nm__c=quoteLine.SBQQ__Product__c;
                            productIdSet.add(quoteLine.SBQQ__Product__c);
                        	productOPNSet.add(quoteLine.Core_OPN__c);
                    }
                }
                for(product2 prod:[SELECT Id,Core_OPN__c, Core_Item_Orderable_Ind__c FROM Product2 where Id IN : productIdSet]){
                    orderFlagInd.put(prod.Id, prod.Core_Item_Orderable_Ind__c);
                }
                if(!productIdSet.isEmpty() && !fetchPriceDataRecursiveCheck){
                    PSG_QuoteLineBusinessLogic.fetchPricingDetails(productIdSet,productOPNSet,uniqueIdToPriceBookEntryMap,productToFWDMapStartDt,
                                        smiFlagInd,productToMSVPMap,prodToolTypeMap,authCodeProductMap,priceBookIdSet,accountTierSet,
                                        accountAllianceSet,geoSet,uniqueIdToListPriceMap,true);
                    fetchPriceDataRecursiveCheck = true;
                    
                }                
                for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                    if(orderFlagInd.containsKey(quoteline.SBQQ__Product__c)){
                         quoteLine.core_cpq_orderable_ind__c = orderFlagInd.get(quoteLine.SBQQ__Product__c);
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
                                if(effectiveDate <= (quoteIdToQuoteMap.get(quoteLine.SBQQ__Quote__c)).createddate){
                                    quoteLine.price_msvp_l1_amt__c = (productToMSVPMap.get(quoteLine.SBQQ__Product__c)).get(effectiveDate).price_level_1_amt__c;
                                    quoteLine.price_msvp_l2_amt__c = (productToMSVPMap.get(quoteLine.SBQQ__Product__c)).get(effectiveDate).price_level_2_amt__c;
                                }
                            }
                        }
                    
                    
                                          
                }
            }
            
        }
    }

    /************************************************************************************************************
    *Method Name : afterInsertUpdateOperations
    *Created Date: 08/13/2021
    *Author: Harshadeep
    *Description : Performs operations on after context of trigger.
    ************************************************************************************************************/
    /*public static void afterInsertUpdateOperations(List<SBQQ__QuoteLine__c> quoteLineList,
                                                   Boolean isInsert,Map<Id,SBQQ__QuoteLine__c> oldMap,Map<Id,SBQQ__QuoteLine__c> newMap){
    }
    */
}