/****************************************************************************************************
Apex Class Name : PSG_HoldALNOnExpirationBatch
Version         : 1.0 
Created Date    : 01/17/2022
Function        : This class is used to process expired ALN and put them on hold. This will be scheduled to run daily.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Drushti Chauhan             01/17/2022                Created
*****************************************************************************************************/
/*global class PSG_HoldALNOnExpirationBatch implements Database.Batchable<Sobject>,Database.Stateful,Database.AllowsCallouts{
    Map<String,String> failedAlnMap=new Map<String,String>();
    Map<String,Object> valuesMap = (Map<String,Object>)JSON.deserializeUntyped(Label.PSG_DPAALN_ExpireExtend);
    global Database.QueryLocator start(Database.BatchableContext bc){
        Date currplus30days = system.today().addDays(Integer.valueOf(valuesMap.get('ShipEndDate')));
        Date currplus7days=System.today().addDays(Integer.valueOf(valuesMap.get('Expire')));
        Date currentDate = System.today().addDays(Integer.valueOf(valuesMap.get('CurrentDate')));//added by bhawana for freeze period
        return Database.getQueryLocator([Select Id,Name,core_cpq_dpa_aln_no_nbr__c,core_cpq_record_type_identifier__c,core_cpq_change_flag__c,core_cpq_active_quote__r.core_cpq_quote_type_nm__c,core_cpq_account_program__c,core_cpq_account_tier__c,
                                         core_cpq_ship_end_date_dt__c,core_cpq_comment_to_disty_txt__c,core_cpq_active_quote__r.core_cpq_margin_geo_txt__c,core_cpq_active_quote__r.core_cpq_price_book_nm__c,core_cpq_active_quote__r.SBQQ__PriceBook__c,core_cpq_update_from_batch_cb__c,
                                         core_cpq_quote_type_dpa__c,core_cpq_Claimed_Qty_Consumed_Linescount__c from core_cpq_dpa_aln__c where core_cpq_status_txt__c = 'Approved' and (core_cpq_ship_end_date_dt__c = :currentDate or (core_cpq_ship_end_date_dt__c = :currplus30days and core_cpq_record_type_identifier__c='ALN')
                                          															or (core_cpq_ship_end_date_dt__c = :currplus30days and core_cpq_record_type_identifier__c='DPA' and core_cpq_quote_type_dpa__c != 'Contract Pricing') or (core_cpq_record_type_identifier__c='DPA' and core_cpq_ship_end_date_dt__c > :currplus7days and core_cpq_Claimed_Qty_Consumed_Linescount__c>0 ))]);
    }
    global void execute(Database.BatchableContext bc, List<SObject> sobjLst) {
        List<core_cpq_dpa_aln__c> alndpaListToUpdate = new List<core_cpq_dpa_aln__c>();
        List<core_cpq_dpa_aln__c> alndpaList = (List<core_cpq_dpa_aln__c>) sobjLst;
        List<String> dpawithconsumedclaimedqty = new List<String>();
        Set<Id> dpaQtyLimitedlinesSet = new Set<Id>();
        Set<Id> dpaNonQLLinesSet=new Set<Id>();
        Map<String,String> alnMap = new Map<String,String>();
		List<String> dpaList = new List<String>();
		Set<String> dpaWithActivePOS=new Set<String>();
		Map<String,Decimal> openOrderAlnMap = new Map<String,Decimal>();
		Date extendDate= System.today().addDays(Integer.valueOf(valuesMap.get('ShipEndDate'))).addMonths(Integer.valueOf(valuesMap.get('Extend')));
		Date expireDate=System.today().addDays(Integer.valueOf(valuesMap.get('Expire')));
        Date currplus30days = system.today().addDays(Integer.valueOf(valuesMap.get('ShipEndDate')));
        for(core_cpq_dpa_aln__c alndpa : alndpaList){
            if(alndpa.core_cpq_ship_end_date_dt__c == System.today()){
                alndpa.core_cpq_change_flag__c='E';
                alndpa.core_cpq_extend_expire__c='Expire';
                alndpa.core_cpq_status_change_reason__c='Expiring '+alndpa.core_cpq_record_type_identifier__c+' as ship end date expired'; 
                alndpaListToUpdate.add(alndpa);
            }else{
                if(alndpa.core_cpq_record_type_identifier__c == 'ALN'){
                    alnMap.put(alndpa.Id,alndpa.core_cpq_dpa_aln_no_nbr__c);
                }else if(alndpa.core_cpq_quote_type_dpa__c != 'Contract Pricing' && alndpa.core_cpq_record_type_identifier__c == 'DPA' && alndpa.core_cpq_ship_end_date_dt__c == currplus30days){
					dpaList.add(alndpa.Id);
				}
                
                if(alndpa.core_cpq_record_type_identifier__c == 'DPA' && alndpa.core_cpq_Claimed_Qty_Consumed_Linescount__c >  0 && alndpa.core_cpq_ship_end_date_dt__c > expireDate){
                    dpawithconsumedclaimedqty.add(alndpa.Id);
                }
            }
           
        }
        
		if(!dpaList.isEmpty()){
			Set<String> excludeDpaSet = new Set<String>();
			List<String> filteredDpaList = new List<String>();
			for(core_cpq_dpa_aln_line__c dpaLine : [Select id,core_cpq_quoteline_type__c,core_cpq_cis_no_nbr__c from core_cpq_dpa_aln_line__c 
                                                    where core_cpq_quoteline_type__c IN ('VTP','Qty Limited') AND core_cpq_cis_no_nbr__c IN :dpaList]){
                excludeDpaSet.add(dpaLine.core_cpq_cis_no_nbr__c);
			}
			for(String dpaId : dpaList){
				if(!excludeDpaSet.contains(dpaId)){
					filteredDpaList.add(dpaId);
				}
			}
            string query = 'select id,parentId,Field,Parent.core_cpq_cis_no_nbr__c from core_cpq_dpa_aln_line__History where Field = \'core_cpq_claimed_qty_nbr__c\' and CreatedDate = ';
            string LastNdays = String.valueOf(valuesMap.get('LastNdays'));
            query = query +LastNdays +'and parent.core_cpq_cis_no_nbr__c IN :filteredDpaList order by CreatedDate desc';
			List<core_cpq_dpa_aln_line__History> dpaLineHisList= Database.Query(query);
			for(core_cpq_dpa_aln_line__History dpaLineHis : dpaLineHisList){
				dpaWithActivePOS.add(dpaLineHis.Parent.core_cpq_cis_no_nbr__c);
			}
			
			for(String dpaId : filteredDpaList){
				core_cpq_dpa_aln__c dpa=new core_cpq_dpa_aln__c();
				dpa.Id=dpaId;
				dpa.core_cpq_change_flag__c='E';
				dpa.core_cpq_update_from_batch_cb__c=true;
				if(dpaWithActivePOS.contains(dpaId)){					
					dpa.core_cpq_ship_end_date_dt__c=extendDate;
					dpa.core_cpq_status_change_reason__c=String.ValueOf(valuesMap.get('DPAStatuswithPOS'));
                    dpa.core_cpq_comment_to_disty_txt__c=String.ValueOf(valuesMap.get('DPAStatuswithPOS'));
				}else{
					dpa.core_cpq_ship_end_date_dt__c=expireDate;
					dpa.core_cpq_status_change_reason__c=String.ValueOf(valuesMap.get('DPAStatuswithNoPOS'));
                    dpa.core_cpq_comment_to_disty_txt__c=String.ValueOf(valuesMap.get('DPAStatuswithNoPOS'));
				}
				alndpaListToUpdate.add(dpa);
			}
		}
        if(!dpawithconsumedclaimedqty.isEmpty()){            
            for(core_cpq_dpa_aln_line__c line:[Select Id,name,core_cpq_quoteline_type__c,core_cpq_cis_no_nbr__c,core_cpq_claimed_qty_consumed__c  from core_cpq_dpa_aln_line__c where  core_cpq_cis_no_nbr__c IN: dpawithconsumedclaimedqty]){
                if(line.core_cpq_quoteline_type__c=='Qty Limited' && line.core_cpq_claimed_qty_consumed__c==true){
                    dpaQtyLimitedlinesSet.add(line.core_cpq_cis_no_nbr__c);     
                }else{
                    dpaNonQLLinesSet.add(line.core_cpq_cis_no_nbr__c); 
                }
            }
            
            for(String dpaId  : dpawithconsumedclaimedqty){
                if(dpaQtyLimitedlinesSet.contains(dpaId) && !dpaNonQLLinesSet.contains(dpaId)){
                    core_cpq_dpa_aln__c dpa=new core_cpq_dpa_aln__c();
                    dpa.Id=dpaId;
                    dpa.core_cpq_change_flag__c='E';
                    dpa.core_cpq_update_from_batch_cb__c=true;
                    dpa.core_cpq_ship_end_date_dt__c=expireDate;
                    dpa.core_cpq_status_change_reason__c=String.valueOf(valuesMap.get('ClaimedExpireComment'));
                    dpa.core_cpq_comment_to_disty_txt__c=String.valueOf(valuesMap.get('ClaimedExpireComment'));
                    alndpaListToUpdate.add(dpa);                   
                }
            }
        }
        if(!alnMap.isEmpty()){
            PSG_Integration_DPA.LightningResponse lr=PSG_Integration_DPA.getALNOpenQty(alnMap.values());
            if(lr.isSuccess){
                openOrderAlnMap = lr.openOrderQtyMap;
            }
            for(String alnId : alnMap.keySet()){
                String alnNo=alnMap.get(alnId);
                core_cpq_dpa_aln__c aln=new core_cpq_dpa_aln__c();
                aln.Id=alnId;
                aln.core_cpq_change_flag__c='E';
                aln.core_cpq_update_from_batch_cb__c=true;
                if(lr.isSuccess){
                    if(openOrderAlnMap.containsKey(alnNo) && openOrderAlnMap.get(alnNo) > 0 ){					
                        aln.core_cpq_ship_end_date_dt__c=extendDate;
                        aln.core_cpq_status_change_reason__c=String.ValueOf(valuesMap.get('ALNStatuswithPOS')); 
                        aln.core_cpq_comment_to_disty_txt__c=String.ValueOf(valuesMap.get('ALNStatuswithPOS'));
                    }else{
                        aln.core_cpq_ship_end_date_dt__c=expireDate;
                        aln.core_cpq_status_change_reason__c=String.ValueOf(valuesMap.get('ALNStatuswithNoPOS'));
                        aln.core_cpq_comment_to_disty_txt__c=String.ValueOf(valuesMap.get('ALNStatuswithNoPOS'));
                    }
                    alndpaListToUpdate.add(aln);
                }else{
                    failedAlnMap.put(alnId,lr.message);
                }
            }
        }	      
        if(!alndpaListToUpdate.isEmpty()){            
            List<Database.SaveResult> updateResults = Database.update(alndpaListToUpdate,false);
            for(Integer i=0;i<updateResults.size();i++){
                if (!updateResults?.get(i)?.isSuccess() || Test.isRunningTest()){ 
                    Database.Error error =updateResults?.get(i)?.getErrors()?.size()>0 ? updateResults?.get(i)?.getErrors()?.get(0) : null;
                    String failedDML = error?.getMessage();
                    failedAlnMap.put(alndpaListToUpdate[i]?.Id,failedDML);
                }                
            }
        }
        
    }
    global void finish(Database.BatchableContext bc) {
        if(!failedAlnMap.isEmpty()){
            PSG_Utility.createCoreLogEntry('PSG_HoldALNOnExpirationBatch','bulkSAPRequestFuture','Failed ALN/DPA while processing through PSG_HoldALNOnExpirationBatch',''+failedAlnMap
                                           ,'core_cpq_dpa_aln__c','High','');
        }
        
        Database.executeBatch(new PSG_SendBulkSAPRequestBatch(),1);
    }

}*/
@isTest
public class PSG_HoldALNOnExpirationBatch{

}