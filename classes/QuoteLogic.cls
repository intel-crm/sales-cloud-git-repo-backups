// not use this class
public class QuoteLogic {
    /*public static void createPRIDRecords(Map<Id,SBQQ__Quote__c> newQuotes){
        //get the quote Ids
        Set<Id> quoteIdSet = new Set<Id>();
        for(SBQQ__Quote__c quote : newQuotes.values()){
            //Adding quoteId to the set when quote is approved and QuoteType is not Bugetary
            if(quote.SBQQ__Status__c=='Approved' && quote.core_cpq_quote_type_nm__c !='Budgetary'){
                quoteIdSet.add(quote.id);
            }                       
        }
        
        System.debug('quoteIdSet>>:'+quoteIdSet);
        Map<Id, List<SBQQ__QuoteLine__c>> quoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
        // get list of all quotes for all quotes where Quotes are aprooved and non-budgetary
        List<SBQQ__QuoteLine__c> quoteLineList = [select id, name, SBQQ__Quote__c,core_cpq_PRID__c, core_cpq_PRID__r.Id,SBQQ__Quote__r.Id,core_cpq_account_nm__c, SBQQ__Discount__c,SBQQ__ContractedPrice__c,
                                                  SBQQ__DiscountSchedule__c,SBQQ__Quote__r.core_cpq_quote_type_nm__c,core_cpq_dollar_change_flag_cb__c,SBQQ__Quote__r.core_cpq_parentaccount__c,SBQQ__Quote__r.SBQQ__Status__c, core_cpq_lower_bound_qty_qty__c,
                                                  core_cpq_upper_bound_qty_nbr__c,SBQQ__PricingMethod__c,core_cpq_quantity_nm__c,core_cpq_product_nm__c,price_suggested_resale_amt__c 
                                                  from SBQQ__QuoteLine__c where SBQQ__Quote__c in :quoteIdSet];
        
        System.debug('quoteLineList>>:'+quoteLineList);
        
        for(SBQQ__QuoteLine__c ql:quoteLineList){
            if(!quoteLineMap.containsKey(ql.SBQQ__Quote__r.Id)){
                quoteLineMap.put(ql.SBQQ__Quote__r.Id, new List<SBQQ__QuoteLine__c>{ql});
            }else{
                quoteLineMap.get(ql.SBQQ__Quote__r.Id).add(ql);
            }
        }
        
        System.debug('quoteLineMap>>:'+quoteLineMap);
        List<price_prid__c>pridList = generatePRID(quoteLineMap);
        System.debug('pridList>>:'+pridList);
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        if(pridList!=null){
            for(SBQQ__QuoteLine__c ql : quoteLineList){
                for(price_prid__c p : pridList){
                    if(ql.SBQQ__PricingMethod__c == p.core_cpq_Type__c && ql.SBQQ__Quote__r.core_cpq_parentaccount__c == p.core_cpq_sap_ecp_nm__c){
                        ql.core_cpq_PRID__c  = p.Id;
                        qlList.add(ql);
                        break;
                    }
                }             
            }
            System.debug('qlList>>:'+qlList);
            if(qlList!=null){
                update qlList;    
            }
            
        }
    }
    
    
    
    /****************************************************************************/
    
    public static void queueOwnerMapping(){
		Map<String, String>  allCriteriaToQueueMap  =  new Map<String, String>();
		String mtdtUniqueStr =  '';
		String quoteUniqueStr =  '';
	 
		
		/* GEO + COUNTRY + STATE + ACCOUNTNAME */
		
		
		Map<String, Id> sosQueueMap = new Map<String, Id>();   //map contains SOS Queue Names*/
		Map<String, String> mtdtQueueMap = new Map <String, String>();
            for(QueueSobject sosQueue: [SELECT Id, QueueId, Queue.Name, Queue.DeveloperName FROM QueueSobject WHERE Queue.DeveloperName like 'psg__%']){
                    sosQueueMap.put(sosQueue.Queue.Name,sosQueue.QueueId);
                }
	 
			for(PSG_Queue_Owner_Mapping__mdt queueRec: [SELECT Id, DeveloperName, PSG_Disti_GEO__c, PSG_Account_Country__c, PSG_Account_Name__c,
												       PSG_Account_State__c, PSG_SOS_Queue_Name__c FROM PSG_Queue_Owner_Mapping__mdt] ){
							

				/*   APJ | India | Delhi, Mumbai | Cisco */
				
				String countryStr =  queueRec.PSG_Account_Country__c;
                if(countryStr == null){countryStr ='';} 
				List<String> countryList = countryStr.split(',');
                system.debug('Country List>>>>' + countryList);                                     
				
				String stateStr =  queueRec.PSG_Account_State__c;
                if(stateStr == null){stateStr ='';}                                            
				List<String> stateList = stateStr.split(',');
                system.debug('State List>>>>' + stateList);   
				
				String accStr =  queueRec.PSG_Account_Name__c;                 
                if(accStr == null){accStr ='';}                                          
				List<String> accList = accStr.split(',');
                system.debug('AccOunt List>>>>' + accList);   				
				
				for(String str1: countryList){
					for(String str2: stateList){
						for(String str3: accList){
                            
							String uniqueStr = queueRec.PSG_Disti_GEO__c + str1 + str2 + str3;	
							mtdtQueueMap.put(uniqueStr, queueRec.PSG_SOS_Queue_Name__c);
             
						}
					}
				}										   
			}
        system.debug('QueueMap>>>' + mtdtQueueMap);
}
    
    
    
    
    
    
    
    
    
    
    
    //Core_cpq_ECP_nm__c,core_cpq_Inactive_cb__c,core_cpq_Device__c,core_cpq_Price_Eligiblity_Date_dt__c,core_cpq_Price_End_Date_dt__c,core_cpq_Price_Start_Date_dt__c,
    //core_cpq_Product_Component__c
    //core_cpq_Quantity_EAU_nbr__c,core_cpq_Review_Date_dt__c,core_cpq_reviewer__c,price_Suggested_Resale_amt__c,core_cpq_Type__c,core_cpq_Upper_Bound_Qty_nbr__c
    /*public static List<price_prid__c> generatePRID(Map<Id, List<SBQQ__QuoteLine__c>> quoteLineMap){
        
        List<SBQQ__QuoteLine__c> lstQl = new List<SBQQ__QuoteLine__c>();
        List<price_prid__c> pridList = new List<price_prid__c>();
        
        for(Id id:quoteLineMap.keySet()){           
            lstQl.addAll(quoteLineMap.get(id));           
        }
        
        System.debug('lstQl>>:'+lstQl);
        /// get existing PRID's
        Map<Id, price_prid__c> oldPRIDs = new Map<Id,price_prid__c>([select id,core_cpq_sap_ecp_nm__c,core_cpq_sap_ecp_nm__r.name,core_cpq_active_cb__c,core_cpq_Device__c,core_cpq_Device__r.name,core_cpq_Quantity_EAU_nbr__c,core_cpq_prid_reviewer__c,
                                                                     price_amt__c,core_cpq_Type__c, core_cpq_Lower_Bound_Qty_nbr__c,core_cpq_Upper_Bound_Qty_nbr__c from price_prid__c where core_cpq_active_cb__c =true]);
        
        System.debug('oldPRIDs>>:'+oldPRIDs);
        
        Map<String, price_prid__c> uniqueOldPRIDs = new Map<String,price_prid__c>();
        
        
        Set<Id> toBeInactive = new Set<Id>();
        
        for(Id id :oldPRIDs.keySet()){
            String uname=''+oldPRIDs.get(id).core_cpq_sap_ecp_nm__r.name+oldPRIDs.get(id).core_cpq_Device__r.name;
            uniqueOldPRIDs.put(uname,oldPRIDs.get(id));
        }
        System.debug('uniqueOldPRIDs>>:'+uniqueOldPRIDs);
        
        if(lstQl!=null && lstQl.size()>0){
            price_prid__c pr;
            for(SBQQ__QuoteLine__c ql: lstQl){
                String un =''+ql.SBQQ__Quote__r.core_cpq_parentaccount__c+ql.core_cpq_product_nm__c;
                
                if(uniqueOldPRIDs.containsKey(un)){
                    toBeInactive.add(uniqueOldPRIDs.get(un).Id); // adding old PRID to be inactivate late
                }
                
                pr = new price_prid__c();
                pr.core_cpq_sap_ecp_nm__c =  ql.SBQQ__Quote__r.core_cpq_parentaccount__c;// ecp
                pr.core_cpq_active_cb__c = true;
                pr.core_cpq_Device__c =  ql.core_cpq_product_nm__c;                
                pr.core_cpq_Quantity_EAU_nbr__c =  ql.core_cpq_quantity_nm__c;
                pr.core_cpq_prid_reviewer__c = userinfo.getUserId();
                pr.price_amt__c = ql.price_suggested_resale_amt__c;
                pr.core_cpq_Type__c = ql.SBQQ__PricingMethod__c;
                pr.core_cpq_Lower_Bound_Qty_nbr__c = ql.core_cpq_lower_bound_qty_qty__c;
                pr.core_cpq_Upper_Bound_Qty_nbr__c = ql.core_cpq_upper_bound_qty_nbr__c;
                pridList.add(pr);
            }
            insert pridList;
            System.debug('pridList>>:'+pridList);
            // inactivateing PRIDs
            List<price_prid__c> inactiveList = new List<price_prid__c>();
            for(Id id: toBeInactive){
                price_prid__c p = new price_prid__c();
                p = oldPRIDs.get(id);
                p.core_cpq_active_cb__c =  false;
                inactiveList.add(p);     
            }
            update inactiveList;
            System.debug('inactiveList>>:'+inactiveList);
            //once PRID is inactivated we have to check QL which are tagged to inactive PRID and need to Update those to new PRID's - ON QL need to update isChanged flag
            List<SBQQ__QuoteLine__c> updateQlList = new List<SBQQ__QuoteLine__c>();
            //get all the QL for inactive PRID
            Map<Id, SBQQ__QuoteLine__c> mapOfQlToBeInactive = new Map<Id, SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c ql: lstQl){
                if(ql.core_cpq_PRID__r.Id !=null){
                    mapOfQlToBeInactive.put(ql.core_cpq_PRID__r.Id, ql);     
                }                
            }
            System.debug('mapOfQlToBeInactive>>:'+mapOfQlToBeInactive);
            //update($IsChanged = true) QL
            if(inactiveList !=null){
                for(price_prid__c prid: inactiveList){
                    SBQQ__QuoteLine__c quoteLine  = new SBQQ__QuoteLine__c();
                    quoteLine = mapOfQlToBeInactive.get(prid.Id);
                    quoteLine.core_cpq_dollar_change_flag_cb__c = true;
                    updateQlList.add(quoteLine);
                }
                update updateQlList;
            }
            System.debug('updateQlList>>:'+updateQlList);
            
        }              
        return [select id,core_cpq_sap_ecp_nm__c,core_cpq_sap_ecp_nm__r.name,core_cpq_active_cb__c,core_cpq_Device__c,core_cpq_Device__r.Core_OPN__c,core_cpq_Device__r.name,core_cpq_Quantity_EAU_nbr__c,core_cpq_prid_reviewer__c,
                price_amt__c,core_cpq_Type__c, core_cpq_Lower_Bound_Qty_nbr__c,core_cpq_Upper_Bound_Qty_nbr__c from price_prid__c where core_cpq_active_cb__c =true];
    }*/
}