public class PaginationCheck {
    @AuraEnabled(Cacheable = true)
    public static List<k_v_f_detail_value_exchange_sfdcs__x> getExternalSalesDetails(){
       List<k_v_f_detail_value_exchange_sfdcs__x> lst = new List<k_v_f_detail_value_exchange_sfdcs__x>();
        for(k_v_f_detail_value_exchange_sfdcs__x sales : [select id,business_organization_nbr__c, business_organization_party_id__c, change_ts__c, DisplayUrl, 
                                                          disti_nm__c, end_dt__c, ExternalId, forecast_product_nbr__c, 
                                                          form_factor_txt__c, hash_id__c, intel_brand_nm__c, invoice_dt__c, 
                                                          invoice_nbr__c, item_id__c, old_material_id__c, one_partner_customer_aggregation_id__c, 
                                                          product_sold_qty__c, sales_type_cd__c, sales_volume_united_states_dollar_amt__c, 
                                                          start_dt__c from k_v_f_detail_value_exchange_sfdcs__x order by id limit 200]){
                                                              lst.add(sales);
                                                          }
        return lst;
    }
}