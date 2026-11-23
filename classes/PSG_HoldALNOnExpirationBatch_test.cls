/****************************************************************************************************
Apex Class Name : PSG_HoldALNOnExpirationBatch_test
Version         : 1.0 
Created Date    : 01/18/2022
Function        : Test class for PSG_HoldALNOnExpirationBatch.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Drushti Chauhan              01/18/2022                Created
*****************************************************************************************************/
@isTest
public class PSG_HoldALNOnExpirationBatch_test {

    /*@testSetup
    public static void setupData() {
        // Create Parent Account
        Account acc1 = PSG_Test_Utility.createAccount();
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
        acc1.Core_Direct_Account_Type_Nm__c = 'End Customer Parent';
        acc1.Core_Is_Pricing_Parent_ChkBox__c = true;
        acc1.Core_Direct_Account_Active_Ind__c = true;
        update acc1;

        // Create Child Account
        Account acc = PSG_Test_Utility.createAccount();
        acc.Core_Direct_Pricing_Parent_Id__c = acc1.id;
        acc.Core_Direct_Legal_Parent_Id__c = acc1.id;
        update acc;

        // Create Contact
        Contact con = PSG_Test_Utility.createContact(acc.Id);

        // Create Admin User
        List<User> boUserList = PSG_Test_Utility.createBOUser();
        
        System.runAs(boUserList[0]) {
            SBQQ.TriggerControl.disable();
            
            // Create Quotes
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, con.id, 2);
            lstquote[0].core_cpq_end_customer_nm__c = acc.id;
            lstquote[0].core_cpq_sap_ecp_nm__c = acc1.id;
            update lstquote;
            
            // Create ALNs and DPAs
            List<core_cpq_dpa_aln__c> dpaalnList = new List<core_cpq_dpa_aln__c>();
            core_cpq_dpa_aln__c dpa = new core_cpq_dpa_aln__c();
            core_cpq_dpa_aln__c aln = new core_cpq_dpa_aln__c();
            core_cpq_dpa_aln__c aln1 = new core_cpq_dpa_aln__c();
            
            aln.RecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_ALN').getRecordTypeId();
            aln.core_cpq_active_quote__c = lstquote[0].Id;
            aln.core_cpq_record_type_identifier__c = 'ALN';
            aln.core_cpq_change_flag__c = 'N';
            aln.core_cpq_status_txt__c = 'Approved';
            aln.core_cpq_ship_end_date_dt__c = System.today();
            dpaalnList.add(aln);
            
            dpa.RecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_DPA').getRecordTypeId();
            dpa.core_cpq_active_quote__c = lstquote[0].Id;            
            dpa.core_cpq_status_txt__c = 'Approved';
            dpa.core_cpq_ship_end_date_dt__c = System.today() + 30;
            dpa.core_cpq_record_type_identifier__c = 'DPA';
            dpa.core_cpq_change_flag__c = 'N';
            dpaalnList.add(dpa);
            
            aln1.RecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_ALN').getRecordTypeId();
            aln1.core_cpq_active_quote__c = lstquote[0].Id;
            aln1.core_cpq_record_type_identifier__c = 'ALN';
            aln1.core_cpq_change_flag__c = 'N';
            aln1.core_cpq_status_txt__c = 'Approved';
            aln1.core_cpq_ship_end_date_dt__c = System.today() + 30;
            dpaalnList.add(aln1);
            
            Test.startTest();
            insert dpaalnList;
            
            // Create Quote Lines
            List<SBQQ__QuoteLine__c> lstquoteLines = PSG_Test_Utility.createQuoteLines(lstquote[1].Id, 2);
            lstquoteLines[0].price_disty_cost_nbr__c = 100;
            update lstquoteLines;    
            
            // Create DPA Lines
            List<core_cpq_dpa_aln_line__c> lstdpaalnLines = PSG_Test_Utility.createDPALinesWithoutInsert(dpaalnList[1].id, 1);
            lstdpaalnLines[0].core_cpq_quote_item_line_no__c = lstquoteLines[0].Id;
            lstdpaalnLines[0].price_broken_cost_disty_amt__c = 0;
            insert lstdpaalnLines;
            
            Test.stopTest();
        }
    }

    static testMethod void cpQuoteScheduleTest() { 
        List<User> lstUsers2 = PSG_Test_Utility.createAdminUser();
        System.runAs(lstUsers2[0]) {
            Test.startTest();
            PSG_HoldALNOnExpirationBatch holdalnBatch = new PSG_HoldALNOnExpirationBatch();
            database.executeBatch(holdalnBatch);
            Test.stopTest();
        }        
    }
    
    static testMethod void claimqtyconsumedtest() { 
        List<User> lstUsers2 = PSG_Test_Utility.createAdminUser();
        System.runAs(lstUsers2[0]) {
            List<core_cpq_dpa_aln__c> lstDPA = [SELECT Id FROM core_cpq_dpa_aln__c LIMIT 1];
            List<core_cpq_dpa_aln_line__c> lstdpaalnLines = [SELECT Id, core_cpq_quote_item_line_no__c FROM core_cpq_dpa_aln_line__c LIMIT 1];
            List<SBQQ__QuoteLine__c> ql = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Id = :lstdpaalnLines[0].core_cpq_quote_item_line_no__c LIMIT 1];
            ql[0].core_cpq_quote_line_type_txt__c = 'Qty Limited';
            
            Test.startTest();
            update ql;
            lstdpaalnLines[0].core_cpq_approved_qty_nbr__c = 10;
            lstdpaalnLines[0].core_cpq_claimed_qty_nbr__c = 10;
            update lstdpaalnLines;
            PSG_HoldALNOnExpirationBatch holdalnBatch = new PSG_HoldALNOnExpirationBatch();
            database.executeBatch(holdalnBatch);
            Test.stopTest();
        }        
    }*/
}