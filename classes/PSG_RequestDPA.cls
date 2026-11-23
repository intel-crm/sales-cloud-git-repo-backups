/****************************************************************************************************
Apex Class Name : PSG_RequestDPA
Version         : 1.0 
Created Date    : 07/07/2021
Function        : This class is Controller class to create DPA/ALNs from Disty portal. 
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshadeep                  07/07/2021                 Created
*****************************************************************************************************/
@isTest
public without sharing class PSG_RequestDPA {
		/****************************************************************************************************************
    * Method Name:createDPA
    * Date: 07/07/2021    
    * Description: Method creates DPA and DPALines requested from disty portal.
    ***************************************************************************************************************************/
    /*@AuraEnabled(cacheable = false)
    public static Id createDPA(List < SBQQ__QuoteLine__c > oldQuoteLineList, Map < String, SBQQ__QuoteLine__c > quoteLineMap,Map < String, SBQQ__Quote__c > quoteMap) {

        List < SBQQ__QuoteLine__c > quoteLineInsert = new List < SBQQ__QuoteLine__c > ();
        List < core_cpq_dpa_aln__c > dpaToInsert = new List < core_cpq_dpa_aln__c > ();
        List < core_cpq_dpa_aln_line__c > dpaLinesToInsert = new List < core_cpq_dpa_aln_line__c > ();
        try {
            Id DPARecordTypeId = PSG_Utility.getRecordTypeId('core_cpq_dpa_aln__c', 'PSG_DPA');
            Id DPALinesRecordTypeId = PSG_Utility.getRecordTypeId('core_cpq_dpa_aln_line__c', 'PSG_DPA_Lines');
            core_cpq_dpa_aln__c dpa = new core_cpq_dpa_aln__c();
            Id quoteId = quoteMap.values().Id;
            List < SBQQ__Quote__c > quoteList = [SELECT Id, SBQQ__Distributor__c from SBQQ__Quote__c where Id =: quoteId];
            Id quoteDistributorId = quoteList[0].SBQQ__Distributor__c;
            List < Account > sapDistributorAccount = [Select Id, Name from Account where RecordType.Name = 'Direct Account'
                and Core_Direct_Account_Type_Nm__c = 'Sold To'
                and (Core_Nielsen_ID__c = 'D' OR Core_Nielsen_ID__c = 'P') 
                and ParentId =: quoteDistributorId limit 1
            ];
            List<Core_MDF_Partner_Group_Mapping__c>  pgMapList=[Select Id,PSG_SAP_Distributor_for_ALN__c,PSG_SAP_Distributor_for_DPA__c from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Account__c = :quoteDistributorId and Core_MDF_Channel_Program__r.Name='PSG Distributor' and Core_MDF_Channel_Program__r.isActive=true];
            for (SBQQ__Quote__c quoterec: quoteMap.values()) {
                dpa.core_cpq_active_quote__c = quoterec.Id;
                dpa.core_cpq_status_txt__c = 'New';
                dpa.core_cpq_disty_submitted_user__c = UserInfo.getUserId();
                dpa.RecordTypeId = DPARecordTypeId;
                dpa.core_cpq_record_type_identifier__c = 'DPA';
                dpa.core_cpq_submitter_comments_txt__c = quoterec.core_cpq_dpa_Comments__c;
                dpa.core_cpq_cm_name_txt__c = quoterec.core_cpq_cm_name_disty_nm__c;
                dpa.core_cpq_cm_state_txt__c = quoterec.core_cpq_cm_state_txt__c;
                dpa.core_cpq_cm_country_disty__c = quoterec.core_cpq_cm_country_disty_nm__c;
                if (!pgMapList.isEmpty() && pgMapList[0].PSG_SAP_Distributor_for_DPA__c!=null) {
                    dpa.core_cpq_sap_distributor_nm__c = pgMapList[0].PSG_SAP_Distributor_for_DPA__c;
                }else if(!sapDistributorAccount.isEmpty()){
                    dpa.core_cpq_sap_distributor_nm__c = sapDistributorAccount[0].Id;
                }
                dpaToInsert.add(dpa);
            }
            if (dpaToInsert != null) {
                insert dpaToInsert;
            }
            for (SBQQ__QuoteLine__c quoteLineRec: oldQuoteLineList) {
                core_cpq_dpa_aln_line__c dpaLines = new core_cpq_dpa_aln_line__c();
                if (quoteLineRec.core_cpq_dollar_change_flag_cb__c) {
                    throw new AuraHandledException('DPA cannot be requested for QL with $ Change flag Set to true');
                }
                Decimal distyCost=quoteLineRec.price_disty_cost_nbr__c!=null?quoteLineRec.price_disty_cost_nbr__c:0;
                if (quoteLineRec.price_brokencost_amt__c > distyCost){
                    throw new AuraHandledException('DPA can\'t be requested as one of the lines has Broken Cost greater than Disty Cost');
                }
                dpaLines.core_cpq_cis_no_nbr__c = dpaToInsert[0].Id;
                dpaLines.RecordTypeId = DPALinesRecordTypeId;
                dpaLines.core_cpq_quote_item_line_no__c = quoteLineRec.Id;
                dpaLines.core_cpq_device_nm__c = quoteLineRec.core_cpq_product_nm__c;
                if(dpaLines.core_cpq_requested_qty_nbr__c==null){
                	dpaLines.core_cpq_requested_qty_nbr__c = quoteLineRec.core_cpq_requested_qty__c;
            	}
                if(dpaLines.price_disty_value_added_amt__c==null){
                	dpaLines.price_disty_value_added_amt__c = quoteLineRec.core_cpq_disty_value_add_dpa__c;
                }
                dpaLines.core_cpq_lower_bound_qty_nbr__c = quoteLineRec.core_cpq_lower_bound_qty_qty__c;
                dpaLines.core_cpq_upper_bound_qty_nbr__c = quoteLineRec.core_cpq_upper_bound_qty_nbr__c;
                dpaLines.core_cpq_quoted_qty_nbr__c = quoteLineRec.SBQQ__Quantity__c;
                dpaLines.core_list_unit_price__c = quoteLineRec.SBQQ__ListPrice__c;
                dpaLines.price_broken_cost_disty_amt__c = quoteLineRec.price_brokencost_amt__c;
                dpaLines.core_cpq_resale_amt__c = quoteLineRec.price_suggested_resale_amt__c?.setScale(2);
                dpaLines.core_cpq_prid__c = quoteLineRec.core_cpq_PRID__c;
                dpaLinesToInsert.add(dpaLines);
                quoteLineInsert.add(quoteLineRec);
            }
            if (dpaLinesToInsert != null) {
                insert dpaLinesToInsert;
            }
        } catch (AuraHandledException ex) {
            
            PSG_Utility.logError(ex);
            throw ex;
        } catch (Exception ex) {
            PSG_Utility.logError(ex);
            throw ex;
        }

        return dpaToInsert[0].Id;
    }
	/****************************************************************************************************************
    * Method Name:createALN
    * Date: 07/07/2021    
    * Description: Method creates ALN and ALNLines requested from disty portal.
    ***************************************************************************************************************************/
    /*@AuraEnabled(cacheable = false)
    public static Id createALN(List < SBQQ__QuoteLine__c > oldQuoteLineList, Map < String, SBQQ__QuoteLine__c > quoteLineMap, Map < String, SBQQ__Quote__c > quoteMap) {
        List < core_cpq_dpa_aln__c > alnToInsert = new List < core_cpq_dpa_aln__c > ();
        List < core_cpq_dpa_aln_line__c > alnLinesToInsert = new List < core_cpq_dpa_aln_line__c > ();
        core_cpq_dpa_aln__c aln = new core_cpq_dpa_aln__c();
        try {
            Id ALNRecordTypeId = PSG_Utility.getRecordTypeId('core_cpq_dpa_aln__c', 'PSG_ALN');
            Id ALNLinesRecordTypeId = PSG_Utility.getRecordTypeId('core_cpq_dpa_aln_line__c', 'PSG_ALN_Lines');
            Id quoteId = quoteMap.values().Id;
            List < SBQQ__Quote__c > quoteList = [SELECT Id, SBQQ__Distributor__c from SBQQ__Quote__c where Id =: quoteId];
            Id quoteDistributorId = quoteList[0].SBQQ__Distributor__c;
            List < Account > sapDistributorAccount = [Select Id, Name from Account where RecordType.Name = 'Direct Account'
                and Core_Direct_Account_Type_Nm__c = 'Sold To'
                and Core_Nielsen_ID__c = 'L'
                and ParentId =: quoteDistributorId limit 1
            ];
			List<Core_MDF_Partner_Group_Mapping__c>  pgMapList=[Select Id,PSG_SAP_Distributor_for_ALN__c,PSG_SAP_Distributor_for_DPA__c from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Account__c = :quoteDistributorId and Core_MDF_Channel_Program__r.Name='PSG Distributor' and Core_MDF_Channel_Program__r.isActive=true ];
            for (SBQQ__Quote__c quoterec: quoteMap.values()) {
                aln.core_cpq_active_quote__c = quoterec.Id;
                aln.core_cpq_status_txt__c = 'New';
                aln.core_cpq_disty_submitted_user__c = UserInfo.getUserId();
                aln.RecordTypeId = ALNRecordTypeId;
                aln.core_cpq_record_type_identifier__c = 'ALN';
                aln.core_cpq_submitter_comments_txt__c = quoterec.core_cpq_dpa_Comments__c;
                aln.core_cpq_final_ship_to_customer_disty__c = quoterec.core_cpq_final_ship_to_customer_dpa__c;
                aln.core_cpq_final_ship_to_country_disty__c = quoterec.core_cpq_final_ship_to_country__c;
                if (!pgMapList.isEmpty() && pgMapList[0].PSG_SAP_Distributor_for_ALN__c!=null) {
                    aln.core_cpq_sap_distributor_nm__c = pgMapList[0].PSG_SAP_Distributor_for_ALN__c;
                }else if(!sapDistributorAccount.isEmpty()){
                    aln.core_cpq_sap_distributor_nm__c = sapDistributorAccount[0].Id;
                }
                alnToInsert.add(aln);
            }
            if (alnToInsert != null) {
                insert alnToInsert;
            }
            for (SBQQ__QuoteLine__c quoteLineRec: oldQuoteLineList) {
                core_cpq_dpa_aln_line__c alnLines = new core_cpq_dpa_aln_line__c();
                if (quoteLineRec.core_cpq_dollar_change_flag_cb__c) {
                    throw new AuraHandledException('ALN cannot be requested for QL with $ Change flag Set to true');
                }
                Decimal distyCost=quoteLineRec.price_disty_cost_nbr__c!=null?quoteLineRec.price_disty_cost_nbr__c:0;
                if (quoteLineRec.price_brokencost_amt__c > distyCost){
                    throw new AuraHandledException('ALN can\'t be requested as one of the lines has Broken Cost greater than Disty Cost');
                }
                alnLines.core_cpq_cis_no_nbr__c = alnToInsert[0].Id;
                alnLines.RecordTypeId = ALNLinesRecordTypeId;
                alnLines.core_cpq_quote_item_line_no__c = quoteLineRec.Id;
                alnLines.core_cpq_device_nm__c = quoteLineRec.core_cpq_product_nm__c;
                if(alnLines.core_cpq_requested_qty_nbr__c==null){
                alnLines.core_cpq_requested_qty_nbr__c = quoteLineRec.core_cpq_requested_qty__c;
            	}
                alnLines.core_cpq_lower_bound_qty_nbr__c = quoteLineRec.core_cpq_lower_bound_qty_qty__c;
                alnLines.core_cpq_upper_bound_qty_nbr__c = quoteLineRec.core_cpq_upper_bound_qty_nbr__c;
                alnLines.core_cpq_quoted_qty_nbr__c = quoteLineRec.SBQQ__Quantity__c;
                alnLines.core_list_unit_price__c = quoteLineRec.SBQQ__ListPrice__c;
                alnLines.price_broken_cost_disty_amt__c = quoteLineRec.price_brokencost_amt__c;
                alnLines.core_cpq_resale_amt__c = quoteLineRec.price_suggested_resale_amt__c?.setScale(2);
                alnLines.core_cpq_prid__c = quoteLineRec.core_cpq_PRID__c;
                alnLinesToInsert.add(alnLines);
            }
            if (alnLinesToInsert != null) {
                insert alnLinesToInsert;
            }

        } catch (Exception ex) {
            PSG_Utility.logError(ex);
            throw ex;
        }

        return alnToInsert[0].Id;
    }*/
}