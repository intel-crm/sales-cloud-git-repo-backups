/****************************************************************************************************
Apex Class Name : PSG_ApprovalBusinessLogic
Version         : 1.0 
Function        : This class is Helper class for Approvals Object Trigger Operations.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pooja		                  4/11/2021               Created
*****************************************************************************************************/
@isTest
public without sharing class PSG_ApprovalBusinessLogic{
    /*public static Map<Id,String> userIDToLevelMap = new Map<Id,String>();
    public static Map<String,core_cpq_bm_approval_threshold__c> uniqueValueToThresholdsMap = new Map<String,core_cpq_bm_approval_threshold__c>();
    
    static{
        for(core_cpq_bm_level__c bmLevelRec : [SELECT Id,core_cpq_bm_level_nm__c,core_cpq_bm_name__c from 
                                               core_cpq_bm_level__c ]){
            userIDToLevelMap.put(bmLevelRec.core_cpq_bm_name__c,bmLevelRec.core_cpq_bm_level_nm__c);
        }
        for(core_cpq_bm_approval_threshold__c approvalThresholdRec : [SELECT Id,core_cpq_bm_level_txt__c,core_cpq_business_unit_nm__c,
                                                                      core_cpq_intel_margin_pct__c,price_peak_annual_amt__c from 
                                                                      core_cpq_bm_approval_threshold__c]){
            uniqueValueToThresholdsMap.put(''+approvalThresholdRec.core_cpq_business_unit_nm__c + approvalThresholdRec.core_cpq_bm_level_txt__c,approvalThresholdRec);
        }
    }
    /************************************************************************************************************
	*Method Name : beforeInsertUpdateOperations
	*Created Date: 08/13/2021
	*Author: Pooja
	*Description : Method performs are the operations in before context.
	************************************************************************************************************/
    /*public static void beforeInsertUpdateOperations(List<sbaa__Approval__c> approvalList,Boolean isInsert,
                                                    Map<Id, sbaa__Approval__c> oldMap){
		try{                 
			if(!isInsert){
				Set<Id> approverIdSet = new Set<Id>(); 
				Set<Id> quoteIdSet = new Set<Id>();  
				Set<Id> approvalRuleIdSet = new Set<Id>();
				Map<Id,String> approvalIdToApprovalNameMap = new Map<Id,String>();
				Set<String> bizOpsApprovalRuleNameSet = new Set<String>{'BizOps Approval Rule - APJ','BizOps Approval Rule - ASMO','BizOps Approval Rule - EMEA','BizOps Approval Rule - PRC'};
				for(sbaa__Approval__c appr: approvalList){
					if(oldMap.get(appr.Id).sbaa__Status__c != appr.sbaa__Status__c && appr.sbaa__Status__c == 'Approved' ){
						if(appr.sbaa__AssignedTo__c != null){
							approverIdSet.add(appr.sbaa__AssignedTo__c);
						}
						if(appr.Quote__c != null){
							quoteIdSet.add(appr.Quote__c);
						}
						if(appr.sbaa__Rule__c != null){
							approvalRuleIdSet.add(appr.sbaa__Rule__c);
						}
					}            
				}
				if(!approvalRuleIdSet.isEmpty()){
					for(sbaa__ApprovalRule__c rule : [SELECT Id,Name from sbaa__ApprovalRule__c where Id IN: approvalRuleIdSet]){
						approvalIdToApprovalNameMap.put(rule.Id,rule.Name);
					}
				}
				Map<Id,Decimal> quoteMaxPeakAnnualResaleMap = new Map<Id,Decimal>();
				Map<Id,Decimal> quoteMaxIntelMarginMap = new Map<Id,Decimal>();
				Map<Id,String> quoteToBusinessUnitMap = new Map<Id,String>();
				Map<Id,Id> quoteToNextApproverMap = new Map<Id,Id>();
				Map<Id,Id> quoteToActualNextApproverMap = new Map<Id,Id>();
				Set<Id> negativeMarginQuoteIdSet = new Set<Id>();
				Set<Id> fwdCostQuoteIdSet = new Set<Id>(); 
                Set<Id> changeFlagQuoteIdSet = new Set<Id>();
				Set<Id> tpQuoteIdSet = new Set<Id>(); 
                Set<Id> ecpActiveQuoteIdSet = new Set<Id>();
                Set<Id> qleFieldsQuoteIdSet = new Set<Id>();
                Map<Id,String> QL = new Map<Id,String>();
				if(!quoteIdSet.isEmpty()){
					for(SBQQ__QuoteLine__c quoteLine : [SELECT Id,Name,SBQQ__Quote__c,SBQQ__Quote__r.core_cpq_negative_margin_quote_Value__c,SBQQ__Quote__r.core_cpq_next_approver_nm__c,price_peak_annual_resale_amt__c,core_cpq_intel_margin_pct__c, SBQQ__Quote__r.core_cpq_sap_ecp_nm__r.Core_Direct_Account_Active_Ind__c,
														price_std_fwd_cost_amt__c, core_cpq_product_nm__r.Core_Product_Type_Nm__c, SBQQ__Quote__r.core_cpq_business_unit_nm__c, SBQQ__Quote__r.core_cpq_quote_type_nm__c, SBQQ__Quote__r.core_cpq_first_bm_approver__c, core_cpq_dollar_change_flag_cb__c
                                                        from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN : quoteIdSet ]){
						if(!quoteMaxPeakAnnualResaleMap.containsKey(quoteLine.SBQQ__Quote__c)){                                 
							quoteMaxPeakAnnualResaleMap.put(quoteLine.SBQQ__Quote__c,quoteLine.price_peak_annual_resale_amt__c);
						}else if(quoteLine.price_peak_annual_resale_amt__c > quoteMaxPeakAnnualResaleMap.get(quoteLine.SBQQ__Quote__c)){
							quoteMaxPeakAnnualResaleMap.put(quoteLine.SBQQ__Quote__c,quoteLine.price_peak_annual_resale_amt__c);
						}
						if(!quoteMaxIntelMarginMap.containsKey(quoteLine.SBQQ__Quote__c)){                                  
							quoteMaxIntelMarginMap.put(quoteLine.SBQQ__Quote__c,quoteLine.core_cpq_intel_margin_pct__c);
						}else if(quoteLine.core_cpq_intel_margin_pct__c < quoteMaxIntelMarginMap.get(quoteLine.SBQQ__Quote__c)){
							quoteMaxIntelMarginMap.put(quoteLine.SBQQ__Quote__c,quoteLine.core_cpq_intel_margin_pct__c);
						}
						if(!quoteToBusinessUnitMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteLine.SBQQ__Quote__r.core_cpq_business_unit_nm__c != null){
							quoteToBusinessUnitMap.put(quoteLine.SBQQ__Quote__c,quoteLine.SBQQ__Quote__r.core_cpq_business_unit_nm__c);
						}
						if(!quoteToNextApproverMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteLine.SBQQ__Quote__r.core_cpq_first_bm_approver__c  != null && quoteLine.SBQQ__Quote__r.core_cpq_next_approver_nm__c  == null){
							quoteToNextApproverMap.put(quoteLine.SBQQ__Quote__c,quoteLine.SBQQ__Quote__r.core_cpq_first_bm_approver__c);
						}
						else if(!quoteToNextApproverMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteLine.SBQQ__Quote__r.core_cpq_next_approver_nm__c  != null){
							quoteToNextApproverMap.put(quoteLine.SBQQ__Quote__c,quoteLine.SBQQ__Quote__r.core_cpq_next_approver_nm__c);
						}  
															
						if(!quoteToActualNextApproverMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteLine.SBQQ__Quote__r.core_cpq_next_approver_nm__c  != null){
							quoteToActualNextApproverMap.put(quoteLine.SBQQ__Quote__c,quoteLine.SBQQ__Quote__r.core_cpq_next_approver_nm__c);
						}
						
						if(quoteLine.SBQQ__Quote__r.core_cpq_negative_margin_quote_Value__c > 0){
							negativeMarginQuoteIdSet.add(quoteLine.SBQQ__Quote__c);
						}
						
						if(quoteLine.SBQQ__Quote__r.core_cpq_quote_type_nm__c == 'Transfer Pricing'){
							tpQuoteIdSet.add(quoteLine.SBQQ__Quote__c);
						}
						
						if(quoteLine.price_std_fwd_cost_amt__c <= 0 && quoteLine.core_cpq_product_nm__r.Core_Product_Type_Nm__c == 'Component'){
							fwdCostQuoteIdSet.add(quoteLine.SBQQ__Quote__c);
                            QL.put(quoteLine.SBQQ__Quote__c,quoteLine.Name);
						}
                        if(quoteLine.core_cpq_dollar_change_flag_cb__c == true){
                            changeFlagQuoteIdSet.add(quoteLine.SBQQ__Quote__c);                                    
                        }
                        if(quoteLine.SBQQ__Quote__r.core_cpq_sap_ecp_nm__r.Core_Direct_Account_Active_Ind__c == false){
                            ecpActiveQuoteIdSet.add(quoteLine.SBQQ__Quote__c);                                               
                        }
					}
				}
         

                for(sbaa__Approval__c appr: approvalList){
					if(oldMap.get(appr.Id).sbaa__Status__c != appr.sbaa__Status__c && appr.sbaa__Status__c == 'Approved'){
                        if(appr.sbaa__AssignedTo__c != null && !userIDToLevelMap.containsKey(appr.sbaa__AssignedTo__c) && !bizOpsApprovalRuleNameSet.contains(approvalIdToApprovalNameMap.get(appr.sbaa__Rule__c))){
                            appr.addError(Label.PSG_BM_Level_Error);
                        }
                        if(ecpActiveQuoteIdSet.contains(appr.Quote__c)){
                            appr.addError('Quote can not be approved as the associated ECP is no longer active. Contact Support Team for any assistance.');
                        }
                        if(qleFieldsQuoteIdSet.contains(appr.Quote__c)){
                            appr.addError('One of the Quote Line has Mandatory field missing OR If Dwin Quote, PRID isn\'t tagged');
                        }
						if(fwdCostQuoteIdSet.contains(appr.Quote__c)){
							appr.addError(QL.get(appr.Quote__c) + ' has $0 or blank Forward Cost ');
						}
                        if(changeFlagQuoteIdSet.contains(appr.Quote__c)){
                            appr.addError(QL.get(appr.Quote__c) +' has $ Change Flag turned on');
                        }
						if(negativeMarginQuoteIdSet.contains(appr.Quote__c) && !tpQuoteIdSet.contains(appr.Quote__c)){
                            if(!quoteToActualNextApproverMap.containsKey(appr.Quote__c)){
							if((((approvalIdToApprovalNameMap.containsKey(appr.sbaa__Rule__c) && bizOpsApprovalRuleNameSet.contains(approvalIdToApprovalNameMap.get(appr.sbaa__Rule__c))) && ( ( quoteToNextApproverMap.containsKey(appr.Quote__c) && ( !userIDToLevelMap.containsKey(quoteToNextApproverMap.get(appr.Quote__c)) || (userIDToLevelMap.containsKey(quoteToNextApproverMap.get(appr.Quote__c)) && userIDToLevelMap.get(quoteToNextApproverMap.get(appr.Quote__c)) != 'Level 5'))  && ( appr.sbaa__AssignedTo__c == null || quoteToNextApproverMap.get(appr.Quote__c) == appr.sbaa__AssignedTo__c ))) ) || ( appr.sbaa__AssignedTo__c != null &&(!userIDToLevelMap.containsKey(appr.sbaa__AssignedTo__c) || (userIDToLevelMap.containsKey(appr.sbaa__AssignedTo__c) && userIDToLevelMap.get(appr.sbaa__AssignedTo__c) != 'Level 5'))))){
								appr.addError('You are not entitled to approve Quote with negative margin');
							}
                            }
                        }else if(appr.sbaa__AssignedTo__c != null && ((quoteToNextApproverMap.containsKey(appr.Quote__c) 
						&& quoteToNextApproverMap.get(appr.Quote__c) == appr.sbaa__AssignedTo__c ) || !quoteToActualNextApproverMap.containsKey(appr.Quote__c) )){
                            
							if(userIDToLevelMap.containsKey(appr.sbaa__AssignedTo__c)){
								String level = userIDToLevelMap.get(appr.sbaa__AssignedTo__c);
                                
								if(String.isNotBlank(level) && quoteToBusinessUnitMap.containsKey(appr.Quote__c) && 
									uniqueValueToThresholdsMap.containsKey(''+quoteToBusinessUnitMap.get(appr.Quote__c)+level)){
									core_cpq_bm_approval_threshold__c thresholdRec = uniqueValueToThresholdsMap.get(''+quoteToBusinessUnitMap.get(appr.Quote__c)+level);
									

                                    if((quoteMaxPeakAnnualResaleMap.containsKey(appr.Quote__c) && quoteMaxPeakAnnualResaleMap.get(appr.Quote__c) > thresholdRec.price_peak_annual_amt__c) ||
									(quoteMaxIntelMarginMap.containsKey(appr.Quote__c) && quoteMaxIntelMarginMap.get(appr.Quote__c) < thresholdRec.core_cpq_intel_margin_pct__c)){  
										

                                        appr.addError('Approval Thresholds for the Quote:' + '\n' + 'Peak Annual Resale $: ' + thresholdRec.price_peak_annual_amt__c  + '\n' +
													  'Intel Margin: ' + thresholdRec.core_cpq_intel_margin_pct__c + '%' + '\n' + 'You didn\'t meet the threshold limits for approving this Quote. Please route to next level of approval');  
									}
								}
							}
						}  
					}         
				}
			}
		}
		catch(Exception ex){
			PSG_Utility.logError(ex);
		}    
	}
    /************************************************************************************************************
	*Method Name : afterInsertUpdateOperations
	*Created Date: 08/13/2021
	*Author: Pooja
	*Description : Method performs are the operations in after context.
	************************************************************************************************************/
    /*public static void afterInsertUpdateOperations(List<sbaa__Approval__c> approvalList,Boolean isInsert,
                                                Map<Id, sbaa__Approval__c> oldMap,Boolean isContractPricing){
        Boolean isUpdate = !isInsert;
                                                   
        List<Id> listOfApprovalsToSendEmail = new List<Id>();
        
		try{
			if(isInsert){
				for(sbaa__Approval__c appr: approvalList){
                    if((appr.sbaa__Status__c == 'Requested')){
						listOfApprovalsToSendEmail.add(appr.id);
					}
                }
                
				if(!listOfApprovalsToSendEmail.isEmpty()){
                    Pricing_SendAdvanceApprovalEmail.sendNotification(listOfApprovalsToSendEmail,Label.PSG_orgWideEmailAddress, 'PSG_Quote_Approval_Request_EmailTemplate');
                }
			}
			if(isUpdate){   
                Set<Id> quoteIdSet = new Set<Id>();
                Map<Id,Id> quoteIdToNextApproverMap = new Map<Id,Id>();
                Set<Id> approvalRuleIdSet = new Set<Id>();
                List<Id> recalledApprovalList=new List<Id>();
                List<Id> requestApprovalList=new List<Id>();
                Map<Id,String> approvalIdToApprovalNameMap = new Map<Id,String>(); 
                Set<Id> CPquoteids = new Set<Id>();
				Set<String> bizOpsApprovalRuleNameSet = new Set<String>{'BizOps Approval Rule - APJ','BizOps Approval Rule - ASMO','BizOps Approval Rule - EMEA','BizOps Approval Rule - PRC'};                            
				for(sbaa__Approval__c appr: approvalList){
				
					if(oldMap.get(appr.Id).sbaa__DelegatedApprover__c != appr.sbaa__DelegatedApprover__c && appr.Quote__c != null && appr.sbaa__DelegatedApprover__c != null && appr.Quote__r.core_cpq_first_bm_approver__c  != null){
						appr.Quote__r.core_cpq_first_bm_approver__c  = appr.sbaa__DelegatedApprover__c;
					}
					if(oldMap.get(appr.Id).sbaa__Status__c != appr.sbaa__Status__c && appr.sbaa__Status__c == 'Approved' ){
						if(appr.Quote__c != null){
							quoteIdSet.add(appr.Quote__c);
						}
						if(appr.sbaa__Rule__c != null){
							approvalRuleIdSet.add(appr.sbaa__Rule__c);
						}
					}
                    if(oldMap.get(appr.Id).sbaa__Status__c != appr.sbaa__Status__c && oldMap.get(appr.Id).sbaa__Status__c == 'Requested' &&  appr.sbaa__Status__c=='Recalled'){
                        recalledApprovalList.add(appr.Id);
                    }
                    if((oldMap.get(appr.Id).sbaa__Status__c != appr.sbaa__Status__c && oldMap.get(appr.Id).sbaa__Status__c == 'Assigned' &&  appr.sbaa__Status__c=='Requested') ||(oldMap.get(appr.Id).sbaa__AssignedTo__c != appr.sbaa__AssignedTo__c && appr.sbaa__Status__c=='Requested' &&  appr.sbaa__AssignedTo__c!=null)){
                        requestApprovalList.add(appr.Id);
                    }
                    
				}
                
                if(!isContractPricing){
				if(!approvalRuleIdSet.isEmpty()){
					for(sbaa__ApprovalRule__c rule : [SELECT Id,Name from sbaa__ApprovalRule__c where Id IN: approvalRuleIdSet ]){
						approvalIdToApprovalNameMap.put(rule.Id,rule.Name);
					}
				}
				Set<Id> negativeMarginQuoteIdSet = new Set<Id>();
				Set<Id> fwdCostQuoteIdSet = new Set<Id>();
                Set<Id> changeFlagQuoteIdSet = new Set<Id>();
                Set<Id> ecpActiveQuoteIdSet = new Set<Id>();
				if(!quoteIdSet.isEmpty()){
					for(SBQQ__QuoteLine__c quoteLine : [SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.core_cpq_negative_margin_quote_Value__c,SBQQ__Quote__r.core_cpq_next_approver_nm__c,price_peak_annual_resale_amt__c, SBQQ__Quote__r.core_cpq_sap_ecp_nm__r.Core_Direct_Account_Active_Ind__c,
														price_std_fwd_cost_amt__c, core_cpq_intel_margin_pct__c,SBQQ__Quote__r.core_cpq_business_unit_nm__c, SBQQ__Quote__r.core_cpq_first_bm_approver__c, core_cpq_dollar_change_flag_cb__c  from SBQQ__QuoteLine__c 
														WHERE SBQQ__Quote__c IN : quoteIdSet]){
						if(!quoteIdToNextApproverMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteLine.SBQQ__Quote__r.core_cpq_next_approver_nm__c != null){                               
							quoteIdToNextApproverMap.put(quoteLine.SBQQ__Quote__c,quoteLine.SBQQ__Quote__r.core_cpq_next_approver_nm__c );
						}
						if(quoteLine.SBQQ__Quote__r.core_cpq_negative_margin_quote_Value__c > 0){
							negativeMarginQuoteIdSet.add(quoteLine.SBQQ__Quote__c);
						}
						if(quoteLine.price_std_fwd_cost_amt__c <= 0){
							fwdCostQuoteIdSet.add(quoteLine.SBQQ__Quote__c);
						}
                        if(quoteLine.core_cpq_dollar_change_flag_cb__c == true){
                            changeFlagQuoteIdSet.add(quoteLine.SBQQ__Quote__c);                                    
                        }
                        if(quoteLine.SBQQ__Quote__r.core_cpq_sap_ecp_nm__r.Core_Direct_Account_Active_Ind__c == false){
                            ecpActiveQuoteIdSet.add(quoteLine.SBQQ__Quote__c);                                               
                        }
					}
				}
				Map<Id,Id> userIdToApproverIdMap = new Map<Id,Id>();
				if(!quoteIdToNextApproverMap.isEmpty()){
					for(sbaa__Approver__c approverRec : [SELECT Id,sbaa__User__c from sbaa__Approver__c where sbaa__User__c IN : quoteIdToNextApproverMap.values()]){
						userIdToApproverIdMap.put(approverRec.sbaa__User__c,approverRec.Id);
					}
				}
				List<sbaa__Approval__c> clonedApprovalList = new List<sbaa__Approval__c>();
				Map<Id,SBQQ__Quote__c> nextApproverToUpdateMap = new Map<Id,SBQQ__Quote__c>();
				for(sbaa__Approval__c appr: approvalList){ 
					if(oldMap.get(appr.Id).sbaa__Status__c != appr.sbaa__Status__c && appr.sbaa__Status__c == 'Approved'){
                        if((approvalIdToApprovalNameMap.containsKey(appr.sbaa__Rule__c)) && bizOpsApprovalRuleNameSet.contains(approvalIdToApprovalNameMap.get(appr.sbaa__Rule__c))){
                        	if(negativeMarginQuoteIdSet.contains(appr.Quote__c) && quoteIdToNextApproverMap.get(appr.Quote__c) != null && quoteIdToNextApproverMap.get(appr.Quote__c) != appr.sbaa__AssignedTo__c){						
								sbaa__Approval__c clonedAppr = appr.clone(false, true, false, false);
								clonedAppr.sbaa__AssignedTo__c = quoteIdToNextApproverMap.get(appr.Quote__c);
								clonedAppr.sbaa__ApprovedBy__c = null;
								clonedAppr.sbaa__Status__c = 'Requested';
								if(userIdToApproverIdMap.containsKey(clonedAppr.sbaa__AssignedTo__c)){
									clonedAppr.sbaa__Approver__c = userIdToApproverIdMap.get(clonedAppr.sbaa__AssignedTo__c);
								}
								clonedApprovalList.add(clonedAppr);
                                
                                SBQQ__Quote__c quote = new SBQQ__Quote__c();
                                quote.id = appr.Quote__c;
                                quote.core_cpq_next_approver_nm__c = null;
                                nextApproverToUpdateMap.put(quote.id, quote);
							}
						}else if(quoteIdToNextApproverMap.get(appr.Quote__c) !=null && quoteIdToNextApproverMap.containsKey(appr.Quote__c) 
						&& quoteIdToNextApproverMap.containsKey(appr.Quote__c) && quoteIdToNextApproverMap.get(appr.Quote__c) != appr.sbaa__AssignedTo__c){
							sbaa__Approval__c clonedAppr = appr.clone(false, true, false, false);
							clonedAppr.sbaa__AssignedTo__c = quoteIdToNextApproverMap.get(appr.Quote__c);
							clonedAppr.sbaa__ApprovedBy__c = null;
							clonedAppr.sbaa__Status__c = 'Requested';
							if(userIdToApproverIdMap.containsKey(clonedAppr.sbaa__AssignedTo__c)){
								clonedAppr.sbaa__Approver__c = userIdToApproverIdMap.get(clonedAppr.sbaa__AssignedTo__c);
							}
							clonedApprovalList.add(clonedAppr);
							
							SBQQ__Quote__c quote = new SBQQ__Quote__c();
							quote.id = appr.Quote__c;
							quote.core_cpq_next_approver_nm__c = null;
							nextApproverToUpdateMap.put(quote.id, quote);
						} 
					}
                    
				}  
				
				if(!nextApproverToUpdateMap.isEmpty()){
					update nextApproverToUpdateMap.values();
				}
				
				if(!clonedApprovalList.isEmpty()){
					insert clonedApprovalList;
				} 
                }
                                
                if(!recalledApprovalList.isEmpty()){
                    Pricing_SendAdvanceApprovalEmail.sendNotification(recalledApprovalList,Label.PSG_orgWideEmailAddress, 'PSG_Quote_Recall_Notification');
                }
                
                if(!requestApprovalList.isEmpty()){
                    Pricing_SendAdvanceApprovalEmail.sendNotification(requestApprovalList,Label.PSG_orgWideEmailAddress, 'PSG_Quote_Approval_Request_EmailTemplate');
                }
               
			}
		}
		catch(Exception ex){
		  PSG_Utility.logError(ex);
		}
    } 
    /************************************************************************************************************
	*Method Name : sendEmailNotification
	*Created Date: 08/13/2021
	*Author: Pooja
	*Description : Method performs sending of email on submission of quote request.
	************************************************************************************************************/
    //Hari - Commented part of clean up 
    /*public static void sendEmailNotification(List<sbaa__Approval__c> approvalList){
		Map<Id,Id> objectIdToUserIdMap = new Map<Id,Id>();
		Map<Id,Id> approvalIdToApproverMap = new Map<Id,Id>();
		Map<Id,Id> approvalIdToDelegateMap = new Map<Id,Id>();
		Map<Id,Set<Id>> queueToUserIdSetMap = new Map<Id,Set<Id>>();
		Set<Id> groupIdSet = new Set<Id>();
		Set<Id> approversIdSet = new Set<Id>();
		for(sbaa__Approval__c approval : approvalList){
			if(approval.sbaa__Approver__c != null){
				approvalIdToApproverMap.put(approval.Id,approval.sbaa__Approver__c);
			} 
			if(approval.sbaa__DelegatedApprover__c != null){
				approvalIdToDelegateMap.put(approval.Id,approval.sbaa__DelegatedApprover__c);
			} 
		}
		if(!approvalIdToApproverMap.isEmpty()){
			approversIdSet.addAll(approvalIdToApproverMap.values());
		}
		if(!approvalIdToDelegateMap.isEmpty()){
			approversIdSet.addAll(approvalIdToDelegateMap.values());
		}
		Map<Id,Id> approverIdToUserIdMap = new Map<Id,Id>();
		Map<Id,Id> approverIdToQueueIdMap = new Map<Id,Id>();
		if(!approversIdSet.isEmpty()){
			for(sbaa__Approver__c approver : [SELECT Id,sbaa__User__c,sbaa__GroupId__c from sbaa__Approver__c where Id
											  IN : approversIdSet]){                              
				if(approver.sbaa__User__c != null)  {                             
					approverIdToUserIdMap.put(approver.Id,approver.sbaa__User__c);  
				}
				if(approver.sbaa__GroupId__c != null)   {                             
					approverIdToQueueIdMap.put(approver.Id,approver.sbaa__GroupId__c);  
				}
			}
		}
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		Schema.DescribeSObjectResult r =  gd.get('User').getDescribe();
		String userPrefix = r.getKeyPrefix();
		Map<Id,Set<Id>> groupIdToUserIdMap = new Map<Id,Set<Id>>();
		Map<Id,Map<Id,Set<Id>>> groupToGroupMap = new Map<Id,Map<Id,Set<Id>>>();
		if(!approverIdToQueueIdMap.isEmpty()){
			for(GroupMember member : [Select UserOrGroupId,GroupId From GroupMember where GroupId IN: approverIdToQueueIdMap.values()]){
				if((''+member.UserOrGroupId).startsWithIgnoreCase(userPrefix)){
					if(!groupIdToUserIdMap.containsKey(member.GroupId)){
						groupIdToUserIdMap.put(member.GroupId,new Set<Id>{member.UserOrGroupId});
					}else{
						groupIdToUserIdMap.get(member.GroupId).add(member.UserOrGroupId);
					}
				}else{
					Map<Id,Set<Id>> tempMap = new Map<Id,Set<Id>>();
					tempMap.put(member.UserOrGroupId,new Set<Id>());
					groupToGroupMap.put(member.GroupId,tempMap);
				}
			}
		}
		
		if(!groupToGroupMap.isEmpty()){
			Set<Id> intermediateGroupIdSet = new Set<Id>();
			for(Id grpId : groupToGroupMap.keySet()){
				for(Id intermediateGrpId : groupToGroupMap.get(grpId).keySet()){
					intermediateGroupIdSet.add(intermediateGrpId);
				}
			}
			Map<Id,Set<Id>> intermediateGrpToUserIdSetMap = new Map<Id,Set<Id>>();
			if(!intermediateGroupIdSet.isEmpty()){
				for(GroupMember member : [Select UserOrGroupId,GroupId From GroupMember where GroupId IN: intermediateGroupIdSet]){
					if((''+member.UserOrGroupId).startsWithIgnoreCase(userPrefix)){
						if(!intermediateGrpToUserIdSetMap.containsKey(member.GroupId)){
							intermediateGrpToUserIdSetMap.put(member.GroupId,new Set<Id>{member.UserOrGroupId});
						}else{
							intermediateGrpToUserIdSetMap.get(member.GroupId).add(member.UserOrGroupId);
						}
					}
				}
			}
			for(Id grpId : groupToGroupMap.keySet()){
				for(Id intermediateGrpId : groupToGroupMap.get(grpId).keySet()){
					if(intermediateGrpToUserIdSetMap.containsKey(intermediateGrpId)){
						Map<Id,Set<Id>> tempMap = new Map<Id,Set<Id>>();
						tempMap.put(intermediateGrpId,intermediateGrpToUserIdSetMap.get(intermediateGrpId));
						groupToGroupMap.put(grpId,tempMap);
					}
				}
			}
		}
		Map<Id,Set<Id>> finalApproverRecIdToUserIdMap = new Map<Id,Set<Id>>();
		for(Id approverRecId : approversIdSet){
			if(approverIdToUserIdMap.containsKey(approverRecId)){
				finalApproverRecIdToUserIdMap.put(approverRecId,new Set<Id>{approverIdToUserIdMap.get(approverRecId)});
			}else if(approverIdToQueueIdMap.containsKey(approverRecId)){
				if(groupIdToUserIdMap.containsKey(approverIdToQueueIdMap.get(approverRecId))){
					finalApproverRecIdToUserIdMap.put(approverRecId,groupIdToUserIdMap.get(approverIdToQueueIdMap.get(approverRecId)));
				}
				if(groupToGroupMap.containsKey(approverIdToQueueIdMap.get(approverRecId))){
					for(Id grpId : groupToGroupMap.get(approverIdToQueueIdMap.get(approverRecId)).keySet()){
						if(!finalApproverRecIdToUserIdMap.containsKey(approverRecId)){
							finalApproverRecIdToUserIdMap.put(approverRecId,groupToGroupMap.get(approverIdToQueueIdMap.get(approverRecId)).get(grpId));
						}else{
							finalApproverRecIdToUserIdMap.get(approverRecId).addAll(groupToGroupMap.get(approverIdToQueueIdMap.get(approverRecId)).get(grpId));
						}
					}

				}
			}
		}
		
		String emailTemplateName = Label.PSG_Disty_Quote_Request_Email_Template_Name;
		Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {};
		OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address='wsm-postmaster@intel.com' ];
		List<EmailTemplate> emailTemplateList = new List<EmailTemplate>([SELECT Id,Subject,Description,HtmlValue,DeveloperName,
																		 Body from EmailTemplate where 
																		 DeveloperName ='PSG_Quote_Approval_Request_EmailTemplate' LIMIT 1]);
		if(!emailTemplateList.isEmpty()){
			for(sbaa__Approval__c approval : approvalList){
				List<Id> userIdListToSendEmail = new List<Id>();
				if(approvalIdToApproverMap.containsKey(approval.Id) 
				&& finalApproverRecIdToUserIdMap.containsKey(approvalIdToApproverMap.get(approval.Id))){
					userIdListToSendEmail.addALL(finalApproverRecIdToUserIdMap.get(approvalIdToApproverMap.get(approval.Id)));
				}
				if(approvalIdToDelegateMap.containsKey(approval.Id)
				&& finalApproverRecIdToUserIdMap.containsKey(approvalIdToDelegateMap.get(approval.Id))){
					userIdListToSendEmail.addALL(finalApproverRecIdToUserIdMap.get(approvalIdToDelegateMap.get(approval.Id)));
				}
					
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				if(!userIdListToSendEmail.isEmpty()){
					message.setTargetObjectId(userIdListToSendEmail[0]);

				}else{

				}
				message.setToAddresses(userIdListToSendEmail); 
				message.setCcAddresses(new List<String>{UserInfo.getUserEmail()});
				message.setWhatId(approval.Id);
				message.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
				message.setUseSignature(false); 
				message.setBccSender(false);  
				message.setSaveAsActivity(false); 
				message.setTemplateID(emailTemplateList[0].Id); 
				messages.add(message);

			}
			if(!messages.isEmpty()){
			}
		}
    }*/
    

    /************************************************************************************************************
	*Method Name : getApprovalList
	*Created Date: 08/13/2021
	*Author: Pooja
	*Description : Method to get pending quotes for approval for a user.
	************************************************************************************************************/
    /*@AuraEnabled
    public static List<sbaa__Approval__c> getApprovalList() {
        Set<String> groupApiNamesSet=new Set<String>{'ags_busops_ap','ags_busops_na','ags_busops_asmo','ags_busops_eu','ags_busops_prc'};
        Set<String> groupIdSet = new Set<String>();
        for (GroupMember gm : [select group.Id,group.name,group.DeveloperName from GroupMember where UserOrGroupId = :UserInfo.getUserId()]){
            if(groupApiNamesSet.contains(gm.group.DeveloperName)){
                groupIdSet.add(gm.group.Id);
            }
        }
        List<sbaa__Approver__c> approverList=[SELECT Id,Name from sbaa__Approver__c WHERE sbaa__GroupId__c in :groupIdSet];
        return [SELECT Name, sbaa__Approver__c,sbaa__Approver__r.Name, sbaa__Status__c,sbaa__AssignedTo__c,
                sbaa__AssignedTo__r.Name, Quote__c, Quote__r.Name , Quote__r.core_cpq_active_cb__c,Quote__r.core_cpq_end_customer_disty_view_nm__c ,Quote__r.core_cpq_quote_type_nm__c, Quote__r.core_cpq_name_nm__c, Quote__r.SubmittedDate__c,Quote__r.SubmittedUser__r.Name
               from sbaa__Approval__c WHERE sbaa__Status__c = 'Requested'and Quote__r.SBQQ__Status__c='In Review' and Quote__r.core_cpq_active_cb__c= true and (sbaa__AssignedTo__c=: UserInfo.getUserId() or sbaa__Approver__c in :approverList) /*and Quote__r.SubmittedDate__c!= null and Quote__r.SubmittedUser__r.Name!= null*//* ORDER BY CreatedDate DESC];
    }*/

}