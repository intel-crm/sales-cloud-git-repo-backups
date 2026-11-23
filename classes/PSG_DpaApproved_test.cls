/****************************************************************************************************
Apex Class Name : PSG_DpaApproved_test
Version         : 1.0 
Created Date    : 02/09/2022
Function        : Test class for PSG_DpaApproved.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Drushti Chauhan              02/09/2022                Created
*****************************************************************************************************/
@isTest
public class PSG_DpaApproved_test {
    /*@testSetup
    public static void setupData(){
        Account acc1 = PSG_Test_Utility.createAccount();
		Opportunity opp1 = PSG_Test_Utility.createOpportunity(acc1.id);     
	}
    public static testmethod void testData1(){
        Account acc = [SELECT id from account limit 1];
        Opportunity opp = [SELECT id from opportunity limit 1];
		List<User> adminList = PSG_Test_Utility.createAdminUser();
            System.runAs(adminList[0]){
            SBQQ.TriggerControl.disable();
			SBQQ__Quote__c quote = PSG_Test_Utility.createQuoteRecord(acc.id,opp.id);
			core_cpq_dpa_aln__c aln = new core_cpq_dpa_aln__c();  
			aln.RecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_DPA').getRecordTypeId();
			aln.core_cpq_active_quote__c = quote.Id;
			aln.core_cpq_record_type_identifier__c = 'DPA';
			aln.core_cpq_status_txt__c = 'Approved';
			aln.core_cpq_change_flag__c = 'N';
            aln.core_cpq_dpa_approved_date__c = '1/28/2022';
            aln.core_cpq_dpa_approved_date__c = '1/28/2022';
            aln.core_cpq_comments_txt__c = 'test';     
			Test.startTest();
			insert aln;
            PSG_DpaApproved extension = new PSG_DpaApproved();
            extension.dpaId = aln.id;
			List<core_cpq_dpa_aln_line__c> dpaLinesToInsert = PSG_Test_Utility.createDPALines(aln.id,1);
            List<core_cpq_dpa_aln_line__c> dline = [select Name,core_cpq_cis_no_nbr__c,core_cpq_approved_qty_nbr__c,core_cpq_device_nm__r.name,core_cpq_device_nm__r.Core_OPN__c,
                                                      price_disty_cost_amt__c,price_broken_cost_disty_amt__c,core_cpq_resale_amt__c,core_cpq_cis_no_nbr__r.core_cpq_aln_type__c,
                                                      price_disty_value_added_amt__c,core_cpq_disty_margin_pct__c,core_cpq_quoteline_type__c ,core_cpq_claimed_qty_nbr__c,core_cpq_quote_item_line_no__r.Name
                                                      from core_cpq_dpa_aln_line__c where core_cpq_cis_no_nbr__c = :aln.id];
			Test.stopTest();
			//extension.dpaLines = dline;
			aln=extension.dpa;
            System.assertEquals(dline.size(), extension.dpaLines.size()); 
		}

    }*/
}