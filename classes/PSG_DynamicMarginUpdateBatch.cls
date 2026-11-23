/***************************************************************************
Class Name    : PSG_DynamicMarginUpdateBatch
Version       : 1.0
Created Date  : 18 August 2023           
Modification Log :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------
* Ranjit        08/18/2023                          
*****************************************************************************************************************************************/
/*global class PSG_DynamicMarginUpdateBatch implements Database.Batchable<Sobject>, Database.Stateful,Schedulable {
    
    global Map<Id,String> failedrecordMap = new Map<Id,String>();
    
    public Database.QueryLocator start(Database.BatchableContext BC){        
        return Database.getQueryLocator([Select id,Name,price_previous_brokencost_amt__c,price_suggested_resale_amt__c,core_cpq_PRID__c,core_cpq_PRID__r.core_cpq_prid_validity_date_dt__c,SBQQ__Quote__r.core_cpq_account_program__c,SBQQ__Quote__r.SBQQ__PriceBook__c,SBQQ__Quote__r.core_cpq_account_tier__c,SBQQ__Quote__r.core_cpq_margin_geo_txt__c,core_cpq_registerable_flag__c,core_cpq_design_reg_status__c,core_cpq_product_family_txt__c,
                                         core_cpq_distributor_margin__c,core_cpq_distributor_margin_type__c,core_cpq_config_dm_pct__c,core_cpq_DM_End_Date__c,core_cpq_margin_exception_txt__c,core_cpq_distributor_margin_pct__c,price_brokencost_amt__c,SBQQ__Quote__r.Name,SBQQ__Quote__r.core_cpq_quote_type_nm__c,core_cpq_master_ddr__c  
                                         From SBQQ__QuoteLine__c where SBQQ__Quote__r.core_cpq_quote_type_nm__c <> 'Contract Pricing' and SBQQ__Quote__r.Pricing_Quote_Program_Nm__c='PSG' 
                                         and SBQQ__Quote__r.core_cpq_active_cb__c=true and SBQQ__Quote__r.core_cpq_status_txt__c='In Progress' and core_cpq_DM_Validity_Check__c=false]);
    }
    
    public void execute(Database.BatchableContext BC,List<sObject> records){
        try{
            Map<Id,SBQQ__QuoteLine__c> quotelinetoUpdateMap= new Map<Id,SBQQ__QuoteLine__c>();
            List<Database.SaveResult> result= new List<Database.SaveResult>();
            Set<String> marginGeoSet=new Set<String>();
            Set<String> accTierSet=new Set<String>();
            Set<String> partnerProgramSet=new Set<String>();
            Set<String> pbSet=new Set<String>();
            for(SBQQ__QuoteLine__c quoteLine : (List<SBQQ__QuoteLine__c>)records){
                if(quoteLine.SBQQ__Quote__r.core_cpq_margin_geo_txt__c!=null){
                    marginGeoSet.add(quoteLine.SBQQ__Quote__r.core_cpq_margin_geo_txt__c);
                }else{
                    marginGeoSet.add('');
                }
                if(quoteLine.SBQQ__Quote__r.core_cpq_account_tier__c!=null)
                    accTierSet.add(quoteLine.SBQQ__Quote__r.core_cpq_account_tier__c);
                if(quoteLine.SBQQ__Quote__r.core_cpq_account_program__c!=null)
                    partnerProgramSet.addAll(quoteLine.SBQQ__Quote__r.core_cpq_account_program__c.split(';'));
                if(quoteLine.SBQQ__Quote__r.SBQQ__PriceBook__c!=null){
                    pbSet.add(quoteLine.SBQQ__Quote__r.SBQQ__PriceBook__c);
                }
            }
            Map<String,Map<String,core_cpq_distributor_margin__c>> dmMap=fetchDMRecords(marginGeoSet,accTierSet,partnerProgramSet,pbSet);
            for(SBQQ__QuoteLine__c quoteLine : (List<SBQQ__QuoteLine__c>)records){
                Set<String> uniqueStrSet = new Set<String>();
                String accProgram=(quoteLine.SBQQ__Quote__r.core_cpq_account_program__c != null?quoteLine.SBQQ__Quote__r.core_cpq_account_program__c:'');
                for(String localPartnerProgram : accProgram.split(';')){
                    String uniqueStr='';
                    if(quoteLine.SBQQ__Quote__r.core_cpq_margin_geo_txt__c != null){
                        uniqueStr = uniqueStr+quoteLine.SBQQ__Quote__r.core_cpq_margin_geo_txt__c;
                    }
                    if(quoteLine.SBQQ__Quote__r.core_cpq_account_tier__c != null){
                        uniqueStr = uniqueStr+quoteLine.SBQQ__Quote__r.core_cpq_account_tier__c;
                    }
                    uniqueStr = uniqueStr+localPartnerProgram;
                    if(quoteLine.SBQQ__Quote__r.SBQQ__PriceBook__c != null){
                        uniqueStr = uniqueStr+quoteLine.SBQQ__Quote__r.SBQQ__PriceBook__c;
                    }
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
                for(String uniqueStr : uniqueStrSet){ 
                    String dmType='Hunter';
                    if(quoteLine.core_cpq_PRID__c != null && quoteLine.core_cpq_PRID__r?.core_cpq_prid_validity_date_dt__c != null && quoteLine.core_cpq_PRID__r?.core_cpq_prid_validity_date_dt__c < System.today()){
                        dmType='Farmer';
                    }
                    if(dmType=='Hunter' && dmMap.get('familyHunterDMMap').containsKey(uniqueStr+'Hunter'+quoteLine.core_cpq_product_family_txt__c)){
                        dmRec=dmMap.get('familyHunterDMMap').get(uniqueStr+'Hunter'+quoteLine.core_cpq_product_family_txt__c);
                    }else if(dmType=='Hunter' && dmMap.get('hunterDMMap').containsKey(uniqueStr+'Hunter')){
                        dmRec=dmMap.get('hunterDMMap').get(uniqueStr+'Hunter');
                    }else if(dmMap.get('familyFarmerDMMap').containsKey(uniqueStr+'Farmer'+quoteLine.core_cpq_product_family_txt__c)){
                        dmRec=dmMap.get('familyFarmerDMMap').get(uniqueStr+'Farmer'+quoteLine.core_cpq_product_family_txt__c); 
                    }else if(dmMap.get('farmerDMMap').containsKey(uniqueStr+'Farmer')){
                        dmRec=dmMap.get('farmerDMMap').get(uniqueStr+'Farmer');
                    }
                    if(dmRec!=null)
                        break;                    
                }
                
                SBQQ__QuoteLine__c ql=new SBQQ__QuoteLine__c();
                ql.Id=quoteLine.Id;
                ql.core_cpq_distributor_margin__c=dmRec!=null?dmRec.id:null;
                ql.core_cpq_config_dm_pct__c=dmRec!=null?dmRec.core_cpq_Disty_Margin_Pct__c.setScale(1):0;
                ql.core_cpq_distributor_margin_type__c=dmRec!=null?dmRec.core_cpq_dm_type__c:null;
                ql.core_cpq_Last_DM_Refresh_Date__c=system.today();
                if(quoteLine.core_cpq_margin_exception_txt__c==null){
                    ql.core_cpq_distributor_margin_pct__c=dmRec!=null?dmRec.core_cpq_Disty_Margin_Pct__c.setScale(1):0;
                    ql.core_cpq_previous_distributor_margin_pct__c = dmRec!=null?dmRec.core_cpq_Disty_Margin_Pct__c.setScale(1):0;
                    if(quoteLine.price_suggested_resale_amt__c !=null){
                        ql.price_brokencost_amt__c = (Decimal)(quoteLine.price_suggested_resale_amt__c - (quoteLine.price_suggested_resale_amt__c * (quoteLine.core_cpq_distributor_margin_pct__c/100)))?.setScale(2);
                    	ql.price_previous_brokencost_amt__c = (Decimal)(quoteLine.price_suggested_resale_amt__c - (quoteLine.price_suggested_resale_amt__c * (quoteLine.core_cpq_distributor_margin_pct__c/100)))?.setScale(2);
                    }else{
                        ql.price_brokencost_amt__c=null;
                        ql.price_previous_brokencost_amt__c=null;
                    }                    
                }
                quotelinetoUpdateMap.put(ql.Id,ql);
            }
            
            if(!quotelinetoUpdateMap.isEmpty()){
                SBQQ.TriggerControl.disable();
                result=Database.update(quotelinetoUpdateMap.values(),false);
                SBQQ.TriggerControl.enable();
                for(Integer i=0;i<result.size(); i++){
                    Database.SaveResult sr = result[i];
                    if (!sr.isSuccess()) {
                        String msg=PSG_QuotewithopptyInactive_Batch.getErrorAsString(sr.getErrors());
                        failedrecordMap.put(sr.getId(),msg);
                    }                        
                }
            }
        }catch(Exception e){
            PSG_Utility.createCoreLogEntry('PSG_DynamicMarginUpdateBatch','PSG_DynamicMarginUpdateBatch','Exception while processing through PSG_DynamicMarginUpdateBatch',''+e
                                           ,'SBQQ__QuoteLine__c','High','');
        }finally{
            SBQQ.TriggerControl.enable();
        }        
    }
    
    
    public void finish(Database.BatchableContext BC){        
        if(!failedrecordMap.isEmpty()){
            PSG_Utility.createCoreLogEntry('PSG_DynamicMarginUpdateBatch','PSG_DynamicMarginUpdateBatch','Failed Record while processing through PSG_DynamicMarginUpdateBatch',''+failedrecordMap
                                           ,'SBQQ__QuoteLine__c','High','');
        }      
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new PSG_DynamicMarginUpdateBatch(), Integer.valueOf(Label.PSG_NonQL_FileUploadBulkLimit));
    }
    
    public Map<String,Map<String,core_cpq_distributor_margin__c>> fetchDMRecords(Set<String> marginGeoSet,Set<String> accTierSet,Set<String> partnerProgramSet,Set<String> pbSet){
        Map<String,core_cpq_distributor_margin__c> familyHunterDMMap=new Map<String,core_cpq_distributor_margin__c>();
        Map<String,core_cpq_distributor_margin__c> familyFarmerDMMap=new Map<String,core_cpq_distributor_margin__c>();
        Map<String,core_cpq_distributor_margin__c> hunterDMMap=new Map<String,core_cpq_distributor_margin__c>();
        Map<String,core_cpq_distributor_margin__c> farmerDMMap=new Map<String,core_cpq_distributor_margin__c>();
        String query = 'Select Id,core_cpq_Price_Book__c,core_cpq_Account_Tier_Txt__c,core_cpq_Approved_Registration_Txt__c,core_cpq_Partner_Program_Txt__c,core_cpq_Effective_Date_Dt__c,core_cpq_Disty_Margin_Pct__c,core_cpq_Registered_Product_Txt__c,core_cpq_Margin_GEO_Txt__c,core_cpq_Active_Cb__c,core_cpq_product_family_txt__c,core_cpq_dm_type__c,core_cpq_end_date__c FROM core_cpq_distributor_margin__c where ';
        String whereStr = '';
        Date currDay = System.today();
        
        if(!marginGeoSet.isEmpty()){
            whereStr = 'core_cpq_Margin_GEO_Txt__c IN:marginGeoSet';
        }
        if(!accTierSet.isEmpty()){
            if(String.isBlank(whereStr)){
                whereStr = 'core_cpq_Account_Tier_Txt__c IN: accTierSet';
            }else{
                whereStr = whereStr + ' AND core_cpq_Account_Tier_Txt__c IN: accTierSet';
            }
        }
        if(!partnerProgramSet.isEmpty()){
            if(String.isBlank(whereStr)){
                whereStr = 'core_cpq_Partner_Program_Txt__c IN:partnerProgramSet';
            }else{
                whereStr = whereStr + ' AND core_cpq_Partner_Program_Txt__c IN:partnerProgramSet';
            }
        }
        if(!pbSet.isEmpty()){
            if(String.isBlank(whereStr)){
                whereStr = 'core_cpq_Price_Book__c IN: pbSet';
            }else{
                whereStr = whereStr + ' AND core_cpq_Price_Book__c IN: pbSet';
            }
        }
        if(String.isBlank(whereStr)){
            query = query + ' core_cpq_Active_Cb__c = true AND core_cpq_Effective_Date_Dt__c <= :currDay AND core_cpq_end_date__c >= :currDay ORDER BY core_cpq_Effective_Date_Dt__c DESC';
        }else{
            query = query + whereStr + ' AND core_cpq_Active_Cb__c = true AND core_cpq_Effective_Date_Dt__c <= :currDay AND core_cpq_end_date__c >= :currDay ORDER BY core_cpq_Effective_Date_Dt__c DESC';
        }
        
        for(core_cpq_distributor_margin__c distyMargin : DataBase.Query(query)){
            String uniqueStr = '';                                                 
            uniqueStr = uniqueStr +
                (String.isNotBlank(distyMargin.core_cpq_Margin_GEO_Txt__c) ?  distyMargin.core_cpq_Margin_GEO_Txt__c : '')+
                (String.isNotBlank(distyMargin.core_cpq_Account_Tier_Txt__c) ?  distyMargin.core_cpq_Account_Tier_Txt__c : '')+ 
                ((distyMargin.core_cpq_Partner_Program_Txt__c == 'N/A')? '' : distyMargin.core_cpq_Partner_Program_Txt__c)  + 
                (String.isNotBlank(''+distyMargin.core_cpq_Price_Book__c) ? (''+distyMargin.core_cpq_Price_Book__c) : '') + 
                (String.isNotBlank(distyMargin.core_cpq_Approved_Registration_Txt__c) ? distyMargin.core_cpq_Approved_Registration_Txt__c : '') +
                distyMargin.core_cpq_Registered_Product_Txt__c +
                (String.isNotBlank(distyMargin.core_cpq_dm_type__c) ?  distyMargin.core_cpq_dm_type__c : ''); 
            if(distyMargin.core_cpq_product_family_txt__c != NULL){
                String uniqueStr1 = uniqueStr + distyMargin.core_cpq_product_family_txt__c;
                if(!familyHunterDMMap.containsKey(uniqueStr1) && distyMargin.core_cpq_dm_type__c == 'Hunter'){
                    familyHunterDMMap.put(uniqueStr1,distyMargin);
                }else if(!familyFarmerDMMap.containsKey(uniqueStr1) && distyMargin.core_cpq_dm_type__c == 'Farmer'){
                    familyFarmerDMMap.put(uniqueStr1,distyMargin);
                }
            }else if(distyMargin.core_cpq_dm_type__c == 'Hunter' && !hunterDMMap.containsKey(uniqueStr)){
                hunterDMMap.put(uniqueStr,distyMargin);
            }else if(distyMargin.core_cpq_dm_type__c == 'Farmer' && !farmerDMMap.containsKey(uniqueStr)){
                farmerDMMap.put(uniqueStr,distyMargin);
            }
        }
        
        return new Map<String,Map<String,core_cpq_distributor_margin__c>>{
                    'familyHunterDMMap' => familyHunterDMMap,
                    'familyFarmerDMMap' => familyFarmerDMMap,
                    'hunterDMMap' => hunterDMMap,
                    'farmerDMMap' => farmerDMMap
                };
	}
}*/
@isTest
public class PSG_DynamicMarginUpdateBatch{

}