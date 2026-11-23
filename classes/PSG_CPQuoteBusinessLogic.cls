/****************************************************************************************************
Apex Class Name : PSG_CPQuoteBusinessLogic
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Business Logic class for PSG Contract Pricing quotes.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pooja                     01/05/2021               Created
*****************************************************************************************************/
@isTest
public without sharing class PSG_CPQuoteBusinessLogic {
    /*
    public static Map<Id,String> distyToPGMap=new Map<Id,String>();
    static{   
        for(Core_MDF_Partner_Group_Mapping__c grpMapRec: [SELECT Id, Core_MDF_Account__c, Core_MDF_Group_Name__c FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Channel_Program__r.Name='PSG Distributor']){
            distyToPGMap.put(grpMapRec.Core_MDF_Account__c,grpMapRec.Core_MDF_Group_Name__c);
        }
    }
    /************************************************************************************************************
    *Method Name : beforeInsertUpdateOperations
    *Created Date: 08/13/2021
    *Author: Pooja
    *Description : Performs operations on before context of trigger.
    ************************************************************************************************************/
    /*
    public static void beforeInsertUpdateOperations(List<SBQQ__Quote__c> quoteList,Map<Id,SBQQ__Quote__c> oldMap,Boolean isInsert){
        Set<Id> reviewerIdSet = new Set<Id>();
        Set<Id> bmreviewerSet = new Set<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>(); 
        Set<Id> accSet = new Set<Id>();
        
        map<String,SBQQ__Quote__c> existingCPQuotes = new map<String,SBQQ__Quote__c>();
        Id inCancelRecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c','PSG_Quote_Cancelled');
        
        Map<Id, String> pbToDistyRegionMap = new Map<Id, String>();
        for(Pricebook2 pbRec: [SELECT Id, Name FROM Pricebook2]){
            pbToDistyRegionMap.put(pbRec.Id, pbRec.Name);
        }
        
        if(quoteList != null && !quoteList.isEmpty()){
            if(isInsert){
                for(SBQQ__Quote__c quote : quoteList){
                    
                    if(pbToDistyRegionMap.containsKey(quote.core_cpq_price_book_nm__c) && quote.core_cpq_price_book_nm__c != null){
                        quote.core_cpq_disty_region__c = pbToDistyRegionMap.get(quote.core_cpq_price_book_nm__c);
                    }
                    
                    if(quote.core_cpq_reviewer__c != null ){
                        reviewerIdSet.add(quote.core_cpq_reviewer__c);
                    }
                    if(quote.core_cpq_end_customer_nm__c!= null){
                        accSet.add(quote.core_cpq_end_customer_nm__c);
                    }
                    quote.core_cpq_quote_owner_name__c = UserInfo.getUserId();
                    quote.core_cpq_quote_owner_disty_txt__c = userInfo.getName();
                    quote.OwnerId = userInfo.getUserId();
                    
                    if(quote.SBQQ__Status__c != null){
                        quote.core_cpq_status_txt__c = quote.SBQQ__Status__c;
                    }else if(quote.core_cpq_status_txt__c != null){
                        quote.SBQQ__Status__c = quote.core_cpq_status_txt__c;
                    }
                    
                    if(quote.core_cpq_end_customer_nm__c != null){
                        quote.SBQQ__Account__c = quote.core_cpq_end_customer_nm__c;
                    }
                    if(quote.core_cpq_price_book_nm__c != null){
                        quote.SBQQ__PricebookId__c = quote.core_cpq_price_book_nm__c;
                    }
                     
                }
                if(!reviewerIdSet.isEmpty()){
                    for(PermissionSetAssignment psa : [SELECT PermissionSet.Name,AssigneeId FROM PermissionSetAssignment 
                                                       WHERE AssigneeId IN :reviewerIdSet AND PermissionSet.Name =:Label.PSG_Quote_BM_PermissionSet LIMIT :Limits.getLimitDmlRows()]){ 
                                                           bmreviewerSet.add(psa.AssigneeId);
                                                       }
                }
                
                if(!accSet.isEmpty()){ 
                    accountMap =  new Map<Id,Account>([SELECT Id,Core_Direct_Pricing_Parent_Id__r.Core_Sub_Geo__c,Core_Direct_Pricing_Parent_Id__r.Core_Direct_Parent_Account_Tier_Nm__c,
                                                       Core_Direct_Pricing_Parent_Id__r.Core_Geo__c,Core_Partner_Alliance_Program__c,
                                                       Core_Direct_Pricing_Parent_Id__c,Core_Account_Tier__c,Name,Core_Geo__c,
                                                       Core_Sub_Geo__c, tolabel(BillingCountryCode) from Account where Id IN : accSet LIMIT :Limits.getLimitDmlRows()]);  
                }
                
                //set<Id> quoteIds = new set<Id>();
                set<Id> ecpIds = new set<Id>();
                
                for(SBQQ__Quote__c quote : quoteList){
                    if(quote.core_cpq_reviewer__c!= null  && !(bmreviewerSet.contains(quote.core_cpq_reviewer__c)) && quote.core_cpq_active_cb__c ==true ){
                        quote.addError('Only Business Manager can be assigned as reviewer');
                    }
                    if(quote.core_cpq_end_customer_nm__c != null && accountMap.containsKey(quote.core_cpq_end_customer_nm__c)){
                        quote.core_cpq_ec_country__c = accountMap.get(quote.core_cpq_end_customer_nm__c).BillingCountrycode;
                        quote.core_cpq_sap_ecp_nm__c = accountMap.get(quote.core_cpq_end_customer_nm__c).Core_Direct_Pricing_Parent_Id__c;
						//TWC3133-5964 Geo Change
						quote.core_cpq_ec_region_txt__c = (AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c == 'INDIA') ? 'APJ' : accountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c; //Sayed
                        quote.core_cpq_end_customer_list_view__c = accountMap.get(quote.core_cpq_end_customer_nm__c).name;
					    ecpIds.add(quote.core_cpq_sap_ecp_nm__c);
                    }
                }
                
                
                for(SBQQ__Quote__c extQuote : [SELECT Id ,Name, core_cpq_sap_ecp_nm__c,core_cpq_end_customer_nm__c, core_cpq_sap_ecp_nm__r.Name  FROM SBQQ__Quote__c WHERE core_cpq_sap_ecp_nm__c =: ecpIds and core_cpq_active_cb__c = true and core_cpq_Process_flag__c = false and core_cpq_quote_type_nm__c ='Contract Pricing' LIMIT :Limits.getLimitDmlRows()]){
                    existingCPQuotes.put(extQuote.core_cpq_sap_ecp_nm__c, extQuote);                    
                }
                
                for(SBQQ__Quote__c quote : quoteList){
                    if(!existingCPQuotes.isEmpty() && existingCPQuotes.containsKey(quote.core_cpq_sap_ecp_nm__c) && quote.core_cpq_revision_nbr__c == 1){
                        quote.addError('An active Contract Pricing Quote ' +existingCPQuotes.get(quote.core_cpq_sap_ecp_nm__c).Name+ ' already exists for ' +existingCPQuotes.get(quote.core_cpq_sap_ecp_nm__c).core_cpq_sap_ecp_nm__r.Name);
                    }
                }               
                
            }  
        }
        Boolean isUpdate = !isInsert;
        if(isUpdate){
            Map <Id, SBQQ__Quote__c> QuoteToQuoteLineChangeMap = new Map<Id, SBQQ__Quote__c>();
            try{
                List<SBQQ__QuoteLine__c> quoteLinesList = new List<SBQQ__QuoteLine__c>();
                for(SBQQ__Quote__c quote : quoteList){
                    
                    if((oldMap.get(quote.Id).core_cpq_price_eligibility_date_dt__c != quote.core_cpq_price_eligibility_date_dt__c) || (oldMap.get(quote.Id).core_cpq_pricing_end_date_dt__c != quote.core_cpq_pricing_end_date_dt__c)
                       || (oldMap.get(quote.Id).core_cpq_pricing_start_date_dt__c != quote.core_cpq_pricing_start_date_dt__c) || (oldMap.get(quote.Id).core_cpq_review_date_dt__c != quote.core_cpq_review_date_dt__c)
                       ||(oldMap.get(quote.Id).core_cpq_reviewer__c != quote.core_cpq_reviewer__c)){
                           QuoteToQuoteLineChangeMap.put(quote.Id, quote);  
                       }
                    
                    if(quote.core_cpq_reviewer__c != null ){
                        reviewerIdSet.add(quote.core_cpq_reviewer__c);
                    }
                    if(oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c){
                        quote.core_cpq_status_txt__c = quote.SBQQ__Status__c;
                    }
                    
                    if(oldMap.get(quote.Id).core_cpq_end_customer_nm__c != quote.core_cpq_end_customer_nm__c){
                        quote.SBQQ__Account__c = quote.core_cpq_end_customer_nm__c;
                    }
                    
                    if(oldmap.get(quote.Id).core_cpq_price_book_nm__c != quote.core_cpq_price_book_nm__c){
                        if(pbToDistyRegionMap.containsKey(quote.core_cpq_price_book_nm__c) && quote.core_cpq_price_book_nm__c != null){
                            quote.core_cpq_disty_region__c = pbToDistyRegionMap.get(quote.core_cpq_price_book_nm__c);
                        }
                        if(quote.core_cpq_price_book_nm__c != null){
                       		quote.SBQQ__PricebookId__c = quote.core_cpq_price_book_nm__c;
                    	}
                    }
                    
                    if(quote.core_cpq_active_cb__c==TRUE && quote.core_cpq_Process_flag__c==TRUE && oldMap.get(quote.Id).core_cpq_active_cb__c != quote.core_cpq_active_cb__c && oldMap.get(quote.Id).core_cpq_Process_flag__c != quote.core_cpq_Process_flag__c){
                        PSG_QuoteBusinessLogic.createPRIDRecords(quote.Id);
                    }
                    
                    if(oldMap.get(quote.Id).ApprovalStatus__c != quote.ApprovalStatus__c && quote.ApprovalStatus__c == 'Pending'){
                        quote.SBQQ__Status__c = 'In Review';
                        quote.core_cpq_status_txt__c = 'In Review';
                    }else if(oldMap.get(quote.Id).ApprovalStatus__c != quote.ApprovalStatus__c && quote.ApprovalStatus__c == 'Approved'){
                        quote.SBQQ__Status__c = 'Approved';
                        quote.core_cpq_status_txt__c = 'Approved';
                        quote.core_cpq_quote_approved_date_dt__c = System.today();

                        quote.core_cpq_active_cb__c=false;  
                        quote.core_cpq_Process_flag__c=false;
                    }else if(oldMap.get(quote.Id).ApprovalStatus__c != quote.ApprovalStatus__c && quote.ApprovalStatus__c == 'Rejected'){
                        quote.SBQQ__Status__c = 'Rejected';
                        quote.core_cpq_status_txt__c = 'Rejected';
                    }
                    
                    if( quote.SBQQ__Status__c != oldMap.get(quote.Id).SBQQ__Status__c && quote.SBQQ__Status__c == 'Approved' && quote.core_cpq_pricing_start_date_dt__c!=null){   
                        quote.core_cpq_active_cb__c=false; 
                        quote.core_cpq_Process_flag__c=false; 
                        quote.core_cpq_disty_group_name__c= distyToPGMap.get(quote.SBQQ__Distributor__c); 
                    }    
                    
                    if(quote.SBQQ__Status__c == 'Approved' && quote.SBQQ__Distributor__c != oldMap.get(quote.Id).SBQQ__Distributor__c && quote.SBQQ__Distributor__c != null){
                        quote.core_cpq_disty_group_name__c= distyToPGMap.get(quote.SBQQ__Distributor__c);
                    }
                    if(quote.ApprovalStatus__c == 'Recalled'){
                        quote.SBQQ__Status__c        = 'In Progress';
                        quote.core_cpq_status_txt__c = 'In Progress';
                    }
                    
                    if(quote.SBQQ__Status__c != oldMap.get(quote.Id).SBQQ__Status__c && quote.SBQQ__Status__c == 'Cancelled'){
                        quote.RecordTypeId = inCancelRecordTypeId;
                        quote.core_cpq_active_cb__c = false;
                    }
                    
                    if(quote.core_cpq_end_customer_nm__c!= null && quote.core_cpq_end_customer_nm__c != oldMap.get(quote.Id).core_cpq_end_customer_nm__c){
                        accSet.add(quote.core_cpq_end_customer_nm__c);
                    }
                    if(quote.SBQQ__Status__c != oldMap.get(quote.Id).SBQQ__Status__c && quote.SBQQ__Status__c == Label.PSG_Quote_Status_Approved){
                        quote.core_cpq_quote_approved_date_dt__c = System.today();
                        quote.core_cpq_approved_by_nm__c = userInfo.getUserId();
                    }

                    //Added by Bishal Singh - TWC3133-4238
                    if((oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c) && quote.SBQQ__Status__c == 'Rejected'){
                        quote.core_cpq_quote_rejected_date__c = System.today();
                    }
                    //Added by Bishal Singh - TWC3133-4238
                    if((oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c) && oldMap.get(quote.Id).SBQQ__Status__c == 'Rejected' && oldMap.get(quote.Id).core_cpq_quote_rejected_date__c != null){
                        quote.core_cpq_quote_rejected_date__c = null;
                    }
                    
                }            
                if(!reviewerIdSet.isEmpty()){
                    for(PermissionSetAssignment psa : [SELECT PermissionSet.Name,AssigneeId FROM PermissionSetAssignment 
                                                       WHERE AssigneeId IN :reviewerIdSet AND PermissionSet.Name =:Label.PSG_Quote_BM_PermissionSet LIMIT :Limits.getLimitDmlRows()]){ 
                                                           bmreviewerSet.add(psa.AssigneeId);
                                                       }
                }
                
                if(!accSet.isEmpty()){ 
                    accountMap =  new Map<Id,Account>([SELECT Id,Core_Direct_Pricing_Parent_Id__r.Core_Sub_Geo__c,Core_Direct_Pricing_Parent_Id__r.Core_Direct_Parent_Account_Tier_Nm__c,
                                                       Core_Direct_Pricing_Parent_Id__r.Core_Geo__c,Core_Partner_Alliance_Program__c,
                                                       Core_Direct_Pricing_Parent_Id__c,Core_Account_Tier__c,Name,Core_Geo__c,
                                                       Core_Sub_Geo__c, tolabel(BillingCountryCode) from Account where Id IN : accSet LIMIT :Limits.getLimitDmlRows()]);  
                }
                if(!QuoteToQuoteLineChangeMap.isEmpty()){
                    for(SBQQ__QuoteLine__c quoteLines : [SELECT id, core_cpq_price_eligibility_date_dt__c, core_cpq_reviewer__c, core_cpq_reviewer__r.Name,core_cpq_pricing_start_date_dt__c,core_cpq_pricing_end_date_dt__c ,core_cpq_review_date_dt__c, 
                                                         Name,SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :QuoteToQuoteLineChangeMap.keySet() LIMIT :Limits.getLimitDmlRows()]){
                                                             quoteLines.core_cpq_pricing_start_date_dt__c = QuoteToQuoteLineChangeMap.get(quoteLines.SBQQ__Quote__c).core_cpq_pricing_start_date_dt__c;
                                                             quoteLines.core_cpq_price_eligibility_date_dt__c = QuoteToQuoteLineChangeMap.get(quoteLines.SBQQ__Quote__c).core_cpq_price_eligibility_date_dt__c;
                                                             quoteLines.core_cpq_review_date_dt__c = QuoteToQuoteLineChangeMap.get(quoteLines.SBQQ__Quote__c).core_cpq_review_date_dt__c;
                                                             quoteLines.core_cpq_reviewer__c = QuoteToQuoteLineChangeMap.get(quoteLines.SBQQ__Quote__c).core_cpq_reviewer__c;
                                                             if(QuoteToQuoteLineChangeMap.get(quoteLines.SBQQ__Quote__c).core_cpq_extended_cp_quote_cb__c == false){
                                                                 quoteLines.core_cpq_pricing_end_date_dt__c = QuoteToQuoteLineChangeMap.get(quoteLines.SBQQ__Quote__c).core_cpq_pricing_end_date_dt__c;
                                                             }
                                                             quoteLinesList.add(quoteLines);                         
                                                         }
                }
                
                if(!quoteLinesList.isEmpty()){
                    update quoteLinesList;
                }
            }catch(Exception e){
                PSG_Utility.logError(e);
            }
            //set<Id> quoteIds = new set<Id>();
            set<Id> ecpIds = new set<Id>();
            
            for(SBQQ__Quote__c quote : quoteList){
                if(quote.core_cpq_reviewer__c!= null  && !(bmreviewerSet.contains(quote.core_cpq_reviewer__c)) && quote.core_cpq_active_cb__c ==true){
                    quote.addError('Only Business Manager can be assigned as reviewer');
                }
                if(quote.core_cpq_end_customer_nm__c != null && accountMap.containsKey(quote.core_cpq_end_customer_nm__c)){
                    quote.core_cpq_ec_country__c = accountMap.get(quote.core_cpq_end_customer_nm__c).BillingCountrycode;
                    quote.core_cpq_sap_ecp_nm__c = accountMap.get(quote.core_cpq_end_customer_nm__c).Core_Direct_Pricing_Parent_Id__c; 
					//TWC3133-5964 Geo Change
					quote.core_cpq_ec_region_txt__c = (AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c == 'INDIA') ? 'APJ' : accountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c;	//Sayed	
                    quote.core_cpq_end_customer_list_view__c = accountMap.get(quote.core_cpq_end_customer_nm__c).name;
                }else if(quote.core_cpq_end_customer_nm__c == null){
						quote.core_cpq_ec_region_txt__c = '';
				}
                if(quote.core_cpq_end_customer_nm__c!= null && quote.core_cpq_end_customer_nm__c != oldMap.get(quote.Id).core_cpq_end_customer_nm__c || (quote.core_cpq_active_cb__c != oldMap.get(quote.Id).core_cpq_active_cb__c && quote.core_cpq_active_cb__c)){
                    ecpIds.add(quote.core_cpq_sap_ecp_nm__c);
                }
            }
            
            if(!ecpIds.isEmpty()){
                for(SBQQ__Quote__c extQuote : [SELECT Id ,Name, core_cpq_sap_ecp_nm__c,core_cpq_end_customer_nm__c,core_cpq_sap_ecp_nm__r.Name, SBQQ__Status__c  FROM SBQQ__Quote__c WHERE core_cpq_sap_ecp_nm__c =: ecpIds and core_cpq_active_cb__c = true and core_cpq_Process_flag__c = false and core_cpq_quote_type_nm__c ='Contract Pricing' and id NOT IN: quoteList LIMIT :Limits.getLimitDmlRows()]){
                    existingCPQuotes.put(extQuote.core_cpq_sap_ecp_nm__c, extQuote);                    
                }
                
                if(!existingCPQuotes.isEmpty()){
                    for(SBQQ__Quote__c quote : quoteList){
                        if(/*!existingCPQuotes.isEmpty() && existingCPQuotes.containsKey(quote.core_cpq_sap_ecp_nm__c) /* && (oldMap.get(quote.Id).core_cpq_end_customer_nm__c == existingCPQuotes.get(quote.core_cpq_sap_ecp_nm__c).core_cpq_end_customer_nm__c)){
                            //  quote.addError('Already exists ' + existingCPQuotes.get(quote.core_cpq_sap_ecp_nm__c).Name);
                            quote.addError('An active Contract Pricing Quote ' +existingCPQuotes.get(quote.core_cpq_sap_ecp_nm__c).Name+ ' already exists for ' +existingCPQuotes.get(quote.core_cpq_sap_ecp_nm__c).core_cpq_sap_ecp_nm__r.Name);
                        }
                    }
                }
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : afterInsertUpdateOperations
    *Created Date: 08/13/2021
    *Author: Pooja
    *Description : Performs operations on after context of trigger.
    ************************************************************************************************************/
    /*public static void afterInsertUpdateOperations(List<SBQQ__Quote__c> quoteList,Map<Id,SBQQ__Quote__c> oldMap,Boolean isInsert){
        Map <Id, SBQQ__Quote__c> QuoteToQuoteLineChangeMap = new Map<Id, SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> quoteLinesList = new List<SBQQ__QuoteLine__c>();
        set<Id> cancelledquotes = new set<Id>();
        if(quoteList != null && !quoteList.isEmpty()){
            if(!isInsert){
                /*List<SBQQ__Quote__c> quoteListToShare = new List<SBQQ__Quote__c>();
                List<SBQQ__Quote__c> quoteListToUnShare = new List<SBQQ__Quote__c>();*/
                /*for(SBQQ__Quote__c quote : quoteList){
                    /*if(quote.SBQQ__Status__c=='Approved' && quote.core_cpq_active_cb__c==true &&  quote.core_cpq_Process_flag__c==true){
                        quoteListToShare.add(quote);
                    }
                    if((quote.SBQQ__Status__c!='Approved' && quote.SBQQ__Status__c!= oldMap.get(quote.id).SBQQ__Status__c )|| !quote.core_cpq_active_cb__c || !quote.core_cpq_Process_flag__c){
                        quoteListToUnShare.add(quote);
                    }*/
                    /*if(quote.SBQQ__Status__c!= oldMap.get(quote.id).SBQQ__Status__c && quote.SBQQ__Status__c == 'Cancelled'){
                        cancelledquotes.add(quote.id);
                    }
                }
                try{
                    list<price_prid__c> pridUpdateLst= new List<price_prid__c>();
                    if(!cancelledquotes.isEmpty()){
                        for(price_prid__c prid:[select name,core_cpq_active_cb__c,core_cpq_quoteline__r.core_cpq_dollar_change_flag_cb__c from price_prid__c 
                                                where core_cpq_quote__r.id IN : cancelledquotes and core_cpq_quoteline__r.core_cpq_dollar_change_flag_cb__c = false]){
                                                    if(prid.core_cpq_active_cb__c){
                                                        prid.core_cpq_active_cb__c=FALSE; 
                                                    }                                               
                                                    pridUpdateLst.add(prid);     
                                                }
                        if(!pridUpdateLst.isEmpty()){
                            update pridUpdateLst;
                        }
                    }
                }catch(Exception e){
                    PSG_Utility.logError(e);
                }
                /*shareCPQuotes(quoteListToShare);
                unshareCPQuotes(quoteListToUnShare);
            }
            
            Boolean isUpdate = !isInsert;
            if(isUpdate){
                Map<String,String> quoteIdToNewStatusMap = new Map<String,String>();
                Map<String,String> quoteIdToOldStatusMap = new Map<String,String>();
                Set<Id> quoteToUpdateDPAALNSet = new Set<Id>();
                Map<String,String> newCPTOOldCPMap=new Map<String,String>();
                Map<String,String>idToOldGroupMap = new Map<String,String>();
                Map<String,String>idToNewGroupMap = new Map<String,String>();
                if(quoteList != null && !quoteList.isEmpty()){
                    for(SBQQ__Quote__c quote : quoteList){
                        if(quote.core_cpq_extended_cp_quote_cb__c!= oldMap.get(quote.id).core_cpq_extended_cp_quote_cb__c && quote.core_cpq_extended_cp_quote_cb__c == true && quote.core_cpq_pricing_end_date_dt__c!= oldMap.get(quote.id).core_cpq_pricing_end_date_dt__c ){
                            QuoteToQuoteLineChangeMap.put(quote.Id, quote);  
                        }
                        if(quote.core_cpq_active_cb__c != oldMap.get(quote.Id).core_cpq_active_cb__c && !quote.core_cpq_active_cb__c){
                            quoteToUpdateDPAALNSet.add(quote.Id);
                        }                        
                        if( quote.SBQQ__Status__c=='Approved' && oldMap.get(quote.Id).core_cpq_active_cb__c != quote.core_cpq_active_cb__c && oldMap.get(quote.Id).core_cpq_Process_flag__c != quote.core_cpq_Process_flag__c && quote.core_cpq_revision_nbr__c>1 && quote.core_cpq_quote_type_nm__c == 'Contract Pricing' && quote.core_cpq_active_cb__c==true && quote.core_cpq_Process_flag__c==true){
                            newCPTOOldCPMap.put(quote.core_cpq_original_quote__c,quote.id);
                        }
                        if(oldMap.get(quote.Id).core_cpq_disty_group_name__c != quote.core_cpq_disty_group_name__c){
                            if(oldMap.get(quote.Id).core_cpq_disty_group_name__c!=null)
                            	idToOldGroupMap.put(quote.Id,oldMap.get(quote.Id)?.core_cpq_disty_group_name__c);
                            if(quote.core_cpq_disty_group_name__c!=null)
                            	idToNewGroupMap.put(quote.Id,quote.core_cpq_disty_group_name__c);
                        }
			 if(oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c){
                            quoteIdToNewStatusMap.put(quote.Id,quote.SBQQ__Status__c);
                            quoteIdToOldStatusMap.put(quote.Id,oldMap.get(quote.Id).SBQQ__Status__c);
                        }
                    }
                }
                if(!quoteIdToNewStatusMap.isEmpty() || !quoteIdToOldStatusMap.isEmpty()){
                    PSG_QuoteHistoryTracking.createHistory(quoteIdToNewStatusMap,quoteIdToOldStatusMap);
                }
                
                if(!QuoteToQuoteLineChangeMap.isEmpty()){
                    for(SBQQ__QuoteLine__c quoteLines : [select id, name, core_cpq_dollar_change_flag_cb__c, core_cpq_pricing_end_date_dt__c,SBQQ__Quote__c from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :QuoteToQuoteLineChangeMap.keySet()]){
                        if(quoteLines.core_cpq_dollar_change_flag_cb__c == false){                                             
                            quoteLines.core_cpq_pricing_end_date_dt__c = QuoteToQuoteLineChangeMap.get(quoteLines.SBQQ__Quote__c).core_cpq_pricing_end_date_dt__c;
                            quoteLinesList.add(quoteLines);
                        }
                    }
                }
                if(!quoteLinesList.isEmpty()){
                    update quoteLinesList;
                }
                if(!quoteToUpdateDPAALNSet.isEmpty()){
                    PRIDBusinessLogic.updateUnderlyingDPAALN(quoteToUpdateDPAALNSet,false);
                }
                
                if(!newCPTOOldCPMap.isEmpty()){
                    PSG_CPQuoteBusinessLogic.ReplaceParentQuoteInTP(newCPTOOldCPMap);
                }
                if(!idToOldGroupMap.isEmpty() || !idToNewGroupMap.isEmpty()){
                    PSG_QuoteBusinessLogic.shareUnshareWithDisty(idToOldGroupMap,idToNewGroupMap,'Quote');
                }
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : ReplaceParentQuoteInTP
    *Created Date: 08/13/2021
    *Author: Ranjit
    *Description : Replace the inactive parentQuote In TP quotes with Latest Revised Parent Quote. 
    ************************************************************************************************************/
    /*public static void ReplaceParentQuoteInTP(Map<String,String> newCPDWTOOldCPDWMap){
        List<SBQQ__QuoteLine__c> TPQLList = [SELECT core_cpq_parent_quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.core_cpq_quote_type_nm__c='Transfer Pricing' and  SBQQ__Quote__r.core_cpq_active_cb__c=true and core_cpq_parent_quote__c IN:newCPDWTOOldCPDWMap.keyset()];
        List<SBQQ__QuoteLine__c> TPQLUpdateList = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c ql : TPQLList){
            if(newCPDWTOOldCPDWMap.containskey(ql.core_cpq_parent_quote__c)){
                ql.core_cpq_parent_quote__c=newCPDWTOOldCPDWMap.get(ql.core_cpq_parent_quote__c);
                TPQLUpdateList.add(ql);
            }
        }
        if(!TPQLUpdateList.isEmpty()){
            SBQQ.TriggerControl.disable();
            //PSG_Constants.isQuoteLineTriggerActive=false;
            List<Database.SaveResult> updateResults = Database.update(TPQLUpdateList,false);
            //PSG_Constants.isQuoteLineTriggerActive=true;
            PSG_QuoteBusinessLogic.processDMLResult('PSG_QuoteAsyncOperations', 'ReplaceParentQuoteInTP','Error while replacing parent quote on TP QLs','SBQQ__QuoteLine__c','High',updateResults,TPQLUpdateList);
            SBQQ.TriggerControl.enable();
        }
    }
    
    /************************************************************************************************************
    *Method Name : shareCPQuotes
    *Created Date: 08/13/2021
    *Author: Pooja
    *Description : Gives access to the disty users.
    ************************************************************************************************************/
    /*public static void shareCPQuotes(List<SBQQ__Quote__c> quoteList){
        if(quoteList != null && !quoteList.isEmpty()){
            Set<Id> accountIdSet = new Set<Id>();
            Map<id,String> uniqueCombinationAccRegion = new Map<id,String>();
            Map<String,Set<Id>> distyAccountToUserIdMap = new Map<String,Set<Id>>();
            for(SBQQ__Quote__c quote : quoteList){
                if(quote.SBQQ__Distributor__c != null){
                    accountIdSet.add(quote.SBQQ__Distributor__c);
                }
            }
            if(!accountIdSet.isEmpty()){
                for(user distyUser : [SELECT Id,Contact.accountId FROM User WHERE Contact.accountId IN: accountIdSet and IsActive = true]){
                    if(distyAccountToUserIdMap.containsKey(distyUser.Contact.accountId)) {
                        distyAccountToUserIdMap.get(distyUser.Contact.accountId).add(distyUser.Id);
                    } else {
                        distyAccountToUserIdMap.put(distyUser.Contact.accountId, new Set<Id>{distyUser.Id});
                    }
                }
                try{ 
                    List<SBQQ__Quote__share> qouteSharelist = new List<SBQQ__Quote__share>();
                    for(SBQQ__Quote__c quote : quoteList){
                        if(distyAccountToUserIdMap.containsKey(quote.SBQQ__Distributor__c)){
                            for(Id userId :distyAccountToUserIdMap.get(quote.SBQQ__Distributor__c)){
                                if(quote.ownerId != userId){
                                    qouteSharelist.add(new SBQQ__Quote__Share(ParentId = quote.id,
                                                                              UserOrGroupId = userid ,
                                                                              AccessLevel = 'edit',
                                                                              RowCause = Schema.SBQQ__Quote__Share.RowCause.Manual));
                                }                                          
                            }
                        }
                    }
                    if(!qouteSharelist.isEmpty()){
                        Insert qouteSharelist;  
                    }
                }catch(Exception e){
                    PSG_Utility.logError(e);
                }
            }
        }
    }*/
    
    /************************************************************************************************************
    *Method Name : unshareCPQuotes
    *Created Date: 08/13/2021
    *Author: Pooja
    *Description : removes access to the cp quote. 
    ************************************************************************************************************/
    /*public static void unshareCPQuotes(List<SBQQ__Quote__c> quoteList){
        if(quoteList != null && !quoteList.isEmpty()){
            set<Id> quoteIdSet = new set<Id>();
            for(SBQQ__Quote__c quote:quoteList){
                quoteIdSet.add(quote.id);
            }
            List<SBQQ__Quote__Share> quoteSharedList = [SELECT Id 
                                                        FROM SBQQ__Quote__Share 
                                                        WHERE ParentId IN :quoteIdSet 
                                                        AND RowCause = 'Manual'];
            if(!quoteSharedList.isEmpty()){
                delete quoteSharedList;  
            }
        }
    }
    */
    
}