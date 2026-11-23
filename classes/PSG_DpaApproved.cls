/****************************************************************************************************
Apex Class Name : PSG_DpaApproved
Version         : 1.0 
Created Date    : 11/17/2022
Function        : This class is used as vf controller for DPA/ALN Approved Email.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ranjit                     11/17/2022               Created
*****************************************************************************************************/
global without sharing class PSG_DpaApproved {
    global Id dpaId {get;set;}
    global core_cpq_dpa_aln__c dpa{
        get{
            List<core_cpq_dpa_aln__c> dpaList = [select core_cpq_aln_approved_date__c,core_cpq_active_quote__r.core_cpq_quote_type_nm__c,
                                       core_cpq_active_quote__r.name,core_cpq_cis_no_nbr__c,Name,core_cpq_dpa_approved_date__c,
                                       core_cpq_comments_txt__c,core_cpq_created_date_txt__c,core_cpq_ship_start_date_dt__c,core_cpq_aln_Rejection_Date_dt__c,core_cpq_dpa_Rejection_Date_dt__c,
                                       core_cpq_ship_end_date_dt__c,core_cpq_previous_ship_end_date__c,core_cpq_sap_distributor__c,core_cpq_sap_end_customer_disty__c,
                                       core_cpq_dpa_aln_no_nbr__c,core_cpq_submitter_disty__c,core_cpq_sap_cm_txt__c,core_cpq_active_quote__r.core_cpq_revision_nbr__c,core_cpq_active_quote__r.core_cpq_sap_ecp_nm__r.Name,
                                       core_cpq_aln_type__c,core_cpq_final_ship_to_country_pl__c,core_cpq_final_ship_to_customer_nm__r.name,core_cpq_active_quote__r.core_cpq_end_customer_nm__r.Name,createddate from core_cpq_dpa_aln__c where Id = :dpaId LIMIT 1];
            return !dpaList.isEmpty()?dpaList[0]:null;
        }
        set;
    }
    global List<core_cpq_dpa_aln_line__c> dpaLines{        
        get{
            List<core_cpq_dpa_aln_line__c> dpaLine = [select Name,core_cpq_cis_no_nbr__c,core_cpq_approved_qty_nbr__c,core_cpq_device_nm__r.name,core_cpq_device_nm__r.Core_OPN__c,	
                                                      price_disty_cost_amt__c,price_broken_cost_disty_amt__c,core_cpq_resale_amt__c,core_cpq_cis_no_nbr__r.core_cpq_aln_type__c,
                                                      price_disty_value_added_amt__c,core_cpq_disty_margin_pct__c,core_cpq_quoteline_type__c ,core_cpq_claimed_qty_nbr__c,core_cpq_quote_item_line_no__r.Name
                                                      from core_cpq_dpa_aln_line__c where core_cpq_cis_no_nbr__c = :dpaId];
            for(core_cpq_dpa_aln_line__c dpa : dpaLine)
            {
                dpa.price_disty_value_added_amt__c = (dpa.price_disty_value_added_amt__c== null) ? 0 : dpa.price_disty_value_added_amt__c;
            }
            return dpaLine;    
        }
        set;
    }
    
}