/***************************************************************************
Class Name    : PSG_QuotewithopptyInactive_Batch
Version       : 1.0
Created Date  : 4 April 2023           
Modification Log :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------
* Ranjit        04/04/2023                          
*****************************************************************************************************************************************/
/*global class PSG_QuotewithopptyInactive_Batch implements Database.Batchable<Sobject>, Database.Stateful,Schedulable {
    global Map<Id,String> failedrecordMap = new Map<Id,String>();
    Map<String,Object> valuesMap = (Map<String,Object>)JSON.deserializeUntyped(Label.PSG_Quote_Auto_Expire);
    global Date currentdateminus5years=system.today().addYears(Integer.valueOf(valuesMap.get('BudgetaryApprovedYears')));
    String DistributorListid=(String)valuesMap.get('Distributor');
    List<String>DistributorList=DistributorListid.split(',');
    global Date DesignWinApprovedYears=system.today().addMonths(Integer.valueOf(valuesMap.get('DesignWinApprovedYears')));
	String stageName = (String)valuesMap.get('QuoteAutoExpiryOppStageName');
	List<String> StageNames = stageName.split(','); 
    
    public Database.QueryLocator start(Database.BatchableContext BC){      
        return Database.getQueryLocator([Select id,name,core_cpq_altera_internal_comments_txt__c,core_cpq_comments_to_disty_txt__c,SBQQ__Opportunity2__r.StageName,core_cpq_quote_type_nm__c,SBQQ__Opportunity2__c,core_cpq_active_cb__c from SBQQ__Quote__c  
                                         where core_cpq_active_cb__c =true and Pricing_Quote_Program_Nm__c ='PSG' and core_cpq_status_txt__c ='Approved' and (( core_cpq_quote_type_nm__c ='Budgetary'
                                         and ((SBQQ__Opportunity2__c <> null and SBQQ__Opportunity2__r.StageName IN :StageNames) or core_cpq_quote_approved_date_dt__c <=:currentdateminus5years))
                                        or ( core_cpq_quote_type_nm__c ='Design Win' and core_cpq_quote_approved_date_dt__c<=:DesignWinApprovedYears and SBQQ__Distributor__c NOT IN: DistributorList))]);
    }
    
    public void execute(Database.BatchableContext BC,List<sObject> records){
        Map<Id,SBQQ__Quote__c> quoteToDeactivateMap=new Map<Id,SBQQ__Quote__c>();
        List<SBQQ__Quote__c> DWquotelist=new List<SBQQ__Quote__c>();
        List<Database.SaveResult> result= new List<Database.SaveResult>();
        for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)records){
            if(quote.core_cpq_quote_type_nm__c=='Budgetary'){
                String InternalComments=quote.core_cpq_altera_internal_comments_txt__c!=null?quote.core_cpq_altera_internal_comments_txt__c:'';
                 String DistyComments=quote.core_cpq_comments_to_disty_txt__c!=null?quote.core_cpq_comments_to_disty_txt__c:'';
                quote.core_cpq_active_cb__c=false;
                if(quote.SBQQ__Opportunity2__c != null && (quote.SBQQ__Opportunity2__r.StageName == 'Lost' || quote.SBQQ__Opportunity2__r.StageName == 'Production Lost' || quote.SBQQ__Opportunity2__r.StageName == 'Cancelled' || quote.SBQQ__Opportunity2__r.StageName == 'Production Cancelled' )){
                  	quote.core_cpq_altera_internal_comments_txt__c=String.ValueOf(valuesMap.get('BUDCommentwithoppty')) + InternalComments;
                    quote.core_cpq_comments_to_disty_txt__c=String.ValueOf(valuesMap.get('BUDCommentwithoppty'))+DistyComments;
                }else{                    
                    quote.core_cpq_altera_internal_comments_txt__c=String.ValueOf(valuesMap.get('BUDCommentforexpire'))+InternalComments;
                    quote.core_cpq_comments_to_disty_txt__c=String.ValueOf(valuesMap.get('BUDCommentforexpire'))+DistyComments;
                }                
                quoteToDeactivateMap.put(quote.Id,quote);   
            }else if(quote.core_cpq_quote_type_nm__c=='Design Win'){
                DWquotelist.add(quote);
            }
        }
        
        
        // Logic for Design Win Quotes
        if(!DWquotelist.isEmpty()){
            Map<String,List<SBQQ__QuoteLine__c>> dwinQuoteToQLMap=new Map<String,List<SBQQ__QuoteLine__c>>();
            Map<String,List<SBQQ__QuoteLine__c>> pridtoTPQLMap=new Map<String,List<SBQQ__QuoteLine__c>>();
            List<SBQQ__QuoteLine__c> dwinQlList=[Select Id,SBQQ__Quote__c,core_cpq_PRID__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in :DWquotelist and core_cpq_PRID__c<> null and core_cpq_PRID__r.core_cpq_active_cb__c=true and core_cpq_dollar_change_flag_cb__c=false];
            List<SBQQ__QuoteLine__c> tpQLList=new List<SBQQ__QuoteLine__c> ();
            Set<String> prids=new Set<String>();
            Set<String> tpQuoteIds=new Set<String>();
            Set<String> pridwithPos=new Set<String>(); 
            Set<String> quotewithDPAALNIDSet=new Set<String>();
            Date PRIDPOSDuration=system.today().addMonths(Integer.valueOf(valuesMap.get('PRIDPOSDuration')));
            Integer DPAALNShipEndDateYears = Integer.valueOf(valuesMap.get('DPAALNShipEndDateYears'));
            if(!dwinQlList.isEmpty()){
                for(SBQQ__QuoteLine__c ql:dwinQlList){
                    prids.add(ql.core_cpq_PRID__c);
                    if(dwinQuoteToQLMap.containsKey(ql.SBQQ__Quote__c)){
                        dwinQuoteToQLMap.get(ql.SBQQ__Quote__c).add(ql);
                    }else{
                        dwinQuoteToQLMap.put(ql.SBQQ__Quote__c,new List<SBQQ__QuoteLine__c>{ql});
                    }
                }
                if(!prids.isEmpty()){
                    for(price_prid__History pridHis:[SELECT Id,Parent.Id from price_prid__History where Field='core_cpq_prid_pos__c' and parent.Id In :prids and CreatedDate >=:PRIDPOSDuration]){
                        pridwithPos.add(pridHis.Parent.Id);
                    }
                    tpQLList=[SELECT Id,Name,SBQQ__Quote__c,core_cpq_PRID__c,SBQQ__Quote__r.core_cpq_altera_internal_comments_txt__c from SBQQ__QuoteLine__c where core_cpq_PRID__c IN:prids and SBQQ__Quote__r.core_cpq_quote_type_nm__c ='Transfer Pricing' and  SBQQ__Quote__r.core_cpq_active_cb__c =true and SBQQ__Quote__r.core_cpq_status_txt__c ='Approved'];
                    for(SBQQ__QuoteLine__c ql:tpQLList){
                        tpQuoteIds.add(ql.SBQQ__Quote__c);
                        if(pridtoTPQLMap.containsKey(ql.core_cpq_PRID__c)){
                            pridtoTPQLMap.get(ql.core_cpq_PRID__c).add(ql);
                        }else{
                            pridtoTPQLMap.put(ql.core_cpq_PRID__c,new List<SBQQ__QuoteLine__c>{ql});
                        }
                    }                  
                }
            }
            
            for(core_cpq_dpa_aln__c dpa:[SELECT Id,core_cpq_active_quote__c from core_cpq_dpa_aln__c where(core_cpq_active_quote__c IN:tpQuoteIds or core_cpq_active_quote__c IN : DWquotelist) and core_cpq_ship_end_date_dt__c>=:system.today().addMonths(DPAALNShipEndDateYears) and ((core_cpq_record_type_identifier__c='DPA' and core_cpq_status_txt__c='Approved') or core_cpq_record_type_identifier__c='ALN')]){
                quotewithDPAALNIDSet.add(dpa.core_cpq_active_quote__c);
            }   
            
            for(SBQQ__Quote__c quote : DWquotelist){
                Boolean isActive=false;
                Map<Id,SBQQ__Quote__c> tpQuoteMap=new Map<Id,SBQQ__Quote__c>();
                if(quotewithDPAALNIDSet.contains(quote.Id)){
                    isActive=true;
                }
                if(!isActive && dwinQuoteToQLMap.containsKey(quote.Id)){
                    for(SBQQ__QuoteLine__c ql : dwinQuoteToQLMap.get(quote.Id)){
                        if(pridwithPos.contains(ql.core_cpq_PRID__c)){
                            isActive=true;
                            break;
                        }                        
                        if(pridtoTPQLMap.containsKey(ql.core_cpq_PRID__c)){
                            for(SBQQ__QuoteLine__c tpQl : pridtoTPQLMap.get(ql.core_cpq_PRID__c)){
                                if(quotewithDPAALNIDSet.contains(tpQl.SBQQ__Quote__c)){
                                    isActive=true;
                                    break;
                                }else{
                                    SBQQ__Quote__c tpQuote=new SBQQ__Quote__c();
                                    tpQuote.Id=tpQl.SBQQ__Quote__c;
                                    tpQuote.core_cpq_altera_internal_comments_txt__c=tpQl.SBQQ__Quote__r.core_cpq_altera_internal_comments_txt__c;
                                    tpQuoteMap.put(tpQuote.Id,tpQuote);
                                }
                            }
                            if(isActive){
                                break;
                            }
                        }
                    }
                }  
                if(!isActive){
                    String Internalcomments=quote.core_cpq_altera_internal_comments_txt__c!=null?quote.core_cpq_altera_internal_comments_txt__c:'';
                    String Distycomments=quote.core_cpq_comments_to_disty_txt__c!=null?quote.core_cpq_comments_to_disty_txt__c:'';
                    quote.core_cpq_active_cb__c=false;                  
                    quote.core_cpq_altera_internal_comments_txt__c=String.ValueOf(valuesMap.get('DWComment'))+Internalcomments;
                    quote.core_cpq_comments_to_disty_txt__c=String.ValueOf(valuesMap.get('DWComment'))+Distycomments;
                    quoteToDeactivateMap.put(quote.Id,quote);
                    if(!tpQuoteMap.isEmpty()){
                        for(SBQQ__Quote__c quote1 : tpQuoteMap.values()){
                            String InternalTPcomments=quote1.core_cpq_altera_internal_comments_txt__c!=null?quote1.core_cpq_altera_internal_comments_txt__c:'';
                            String DistyTPcomments=quote1.core_cpq_comments_to_disty_txt__c!=null?quote1.core_cpq_comments_to_disty_txt__c:'';
                            quote1.core_cpq_active_cb__c=false;                  
                            quote1.core_cpq_altera_internal_comments_txt__c=String.ValueOf(valuesMap.get('DWComment'))+InternalTPcomments;
                            quote1.core_cpq_comments_to_disty_txt__c=String.ValueOf(valuesMap.get('DWComment'))+DistyTPcomments;
                            quoteToDeactivateMap.put(quote1.Id,quote1);
                        }
                    }                   
                }
            }
        }
         
        if(!quoteToDeactivateMap.isEmpty()){
            SBQQ.TriggerControl.disable();
            result=Database.update(quoteToDeactivateMap.values(),false);
            for(Integer i=0;i<result.size(); i++){
                Database.SaveResult sr = result[i];
                if (!sr.isSuccess()) {
                    String msg=PSG_QuotewithopptyInactive_Batch.getErrorAsString(sr.getErrors());
                    failedrecordMap.put(sr.getId(),msg);
                }                        
            }
            SBQQ.TriggerControl.enable();
        }    
    }
    
    public void finish(Database.BatchableContext BC){        
        if(!failedrecordMap.isEmpty()){
            PSG_Utility.createCoreLogEntry('PSG_QuotewithopptyInactive_Batch','PSG_QuotewithopptyInactive_Batch','Failed Record while processing through PSG_QuotewithopptyInactive_Batch',''+failedrecordMap
                                           ,'SBQQ__Quote__c','High','');
        }        
        SBQQ.TriggerControl.enable();
    }
    global void execute(SchedulableContext sc) {
        Id jobId=Database.executeBatch(new PSG_QuotewithopptyInactive_Batch(), Integer.valueOf(valuesMap.get('BatchSize')));
    }
    
    public static String getErrorAsString(Database.Error[] errors){
        List<String> errorList=new List<String>();
        for(Database.Error error:errors){
            if(error.getMessage()!=null){
                errorList.add(error.getMessage());
            }
        }
        return String.join(errorList, ';');
    }
}*/
@isTest
public class PSG_QuotewithopptyInactive_Batch{

}