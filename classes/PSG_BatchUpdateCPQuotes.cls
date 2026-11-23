/****************************************************************************************************
Apex Class Name : PSG_BatchUpdateCPQuotes
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This class is used to process both the Approved CP quotes and Extended CP Quotes. This will be scheduled to run daily.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
/*global class PSG_BatchUpdateCPQuotes implements Database.Batchable<Sobject>, Database.Stateful,Schedulable{
    Map<Id,Exception> failedQuoteMap=new Map<Id,Exception>();
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, SBQQ__Status__c,core_cpq_extended_cp_quote_cb__c,core_cpq_original_quote__c, core_cpq_Process_flag__c, core_cpq_quote_type_nm__c, core_cpq_pricing_start_date_dt__c,core_cpq_pricing_end_date_dt__c,core_cpq_active_cb__c 
                                        from SBQQ__Quote__c where core_cpq_quote_type_nm__c = 'Contract Pricing' and SBQQ__Status__c = 'Approved' and 
                                         ((core_cpq_pricing_start_date_dt__c <= TODAY and core_cpq_Process_flag__c = false and core_cpq_active_cb__c = false) or (core_cpq_extended_cp_quote_cb__c = true) or (core_cpq_pricing_end_date_dt__c < TODAY and core_cpq_active_cb__c = true))
                                         ]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> sobjLst) {
        SBQQ.TriggerControl.disable();
        List<SBQQ__Quote__c> quoteList = (List<SBQQ__Quote__c>) sobjLst;
        List<price_PRID__c> pridListToUpdate = new List<price_PRID__c>();
        List<SBQQ__Quote__c> quoteListToUpdate = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> parentQuoteListToUpdate = new List<SBQQ__Quote__c>();
        Map<String,List<SBQQ__QuoteLine__c>> quoteIdToQLList=new Map<String,List<SBQQ__QuoteLine__c>>();        
        for(SBQQ__QuoteLine__c ql:[Select Id,core_cpq_PRID__c,core_cpq_pricing_end_date_dt__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN :quoteList and core_cpq_dollar_change_flag_cb__c=false and core_cpq_PRID__c != null]){
            if(quoteIdToQLList.containsKey(ql.SBQQ__Quote__c)){
                quoteIdToQLList.get(ql.SBQQ__Quote__c).add(ql);
            }else{
                quoteIdToQLList.put(ql.SBQQ__Quote__c,new List<SBQQ__QuoteLine__c>{ql});
            }                
        }        
        Set<Id> parentQuoteIdSet=new Set<Id>();
        try{
            for(SBQQ__Quote__c quote : quoteList){
                if(quote.core_cpq_extended_cp_quote_cb__c){
                    if(quoteIdToQLList.containsKey(quote.Id)){
                        for(SBQQ__QuoteLine__c ql:quoteIdToQLList.get(quote.Id)){
                            price_PRID__c prid=new price_PRID__c();
                            prid.Id=ql.core_cpq_PRID__c;
                            prid.core_cpq_quote__c=ql.SBQQ__Quote__c;
                            prid.core_cpq_quoteline__c=ql.Id;
                            prid.core_cpq_price_end_date_dt__c=ql.core_cpq_pricing_end_date_dt__c;
                            prid.core_cpq_update_underlying_quotelines_cb__c=true;
                            pridListToUpdate.add(prid);
                        }
                        quote.core_cpq_extended_cp_quote_cb__c=false;
                        quoteListToUpdate.add(quote);
                    }                    
                }else if(quote.core_cpq_pricing_start_date_dt__c <= System.today() && !quote.core_cpq_Process_flag__c && !quote.core_cpq_active_cb__c){
                    if(quote.core_cpq_original_quote__c != null){
                        parentQuoteIdSet.add(quote.core_cpq_original_quote__c);
                    }
                    quote.core_cpq_Process_flag__c = true;
                    quote.core_cpq_active_cb__c = true;
                    quoteListToUpdate.add(quote);
                }else if(quote.core_cpq_pricing_end_date_dt__c < System.today() && quote.core_cpq_active_cb__c){
                    quote.core_cpq_active_cb__c = false;
                    quoteListToUpdate.add(quote);  
                }
            }
           
            for(Id qId: parentQuoteIdSet ){
                SBQQ__Quote__c quote = new SBQQ__Quote__c();
                quote.Id=qId;
                quote.core_cpq_active_cb__c = false;
                parentQuoteListToUpdate.add(quote);
            }
            
            if(!pridListToUpdate.isEmpty()){
                update pridListToUpdate;
            }
            update quoteListToUpdate;
            if(!parentQuoteListToUpdate.isEmpty()){
                update parentQuoteListToUpdate;
            }
        }catch(Exception e){
            failedQuoteMap.put((String)sobjLst[0].get('Id'),e);
        }finally {
            SBQQ.TriggerControl.enable();
        }
    }              
    global void finish(Database.BatchableContext bc) {
        if(!failedQuoteMap.isEmpty()){
            PSG_Utility.createCoreLogEntry('PSG_BatchUpdateCPQuotes','bulkSAPRequestFuture','Failed CP Quotes while processing through PSG_BatchUpdateCPQuotes',''+failedQuoteMap
                                         ,'SBQQ__Quote__c','High','');
        }
        //Database.executeBatch(new PSG_SendBulkSAPRequestBatch(),1);
        Database.executeBatch(new PSG_HoldALNOnExpirationBatch(),1);
    }
    global void execute(SchedulableContext sc) {
        Id jobId=Database.executeBatch(new PSG_BatchUpdateCPQuotes(), 1);
    }
}*/
@isTest
public class PSG_BatchUpdateCPQuotes{

}