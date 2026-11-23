/****************************************************************************************************
Apex Class Name : PSG_BatchUpdateCPQuotes_test
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_BatchUpdateCPQuotes.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_BatchUpdateCPQuotes_test {
    @testSetup
    public static void setupData(){
        Account acc = PSG_Test_Utility.createAccount();
        Contact con = PSG_Test_Utility.createContact(acc.Id);
        List<User> sosUserList = PSG_Test_Utility.createSOSUser();
        System.runAs(sosUserList[0]){
            SBQQ.TriggerControl.disable();
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, con.Id, 2);
            Id CPRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('PSG_Quote_Contract_Pricing').getRecordTypeId();
            lstquote[0].core_cpq_quote_type_nm__c='Contract Pricing';
            lstquote[0].core_cpq_Process_flag__c=false;
            lstquote[0].core_cpq_pricing_start_date_dt__c=System.today()-10;
            lstquote[0].core_cpq_status_txt__c = 'Approved';
            lstquote[0].SBQQ__Status__c = 'Approved';
            lstquote[0].core_cpq_active_cb__c = false;
            lstquote[0].core_cpq_reviewer__c = null;
            lstquote[0].RecordTypeId = CPRecordTypeId;
            lstquote[0].core_cpq_original_quote__c=lstquote[1].Id;
            Test.startTest();
            update lstquote;
            System.assert(!lstquote.isEmpty(),'Quotes inserted');
            List<SBQQ__QuoteLine__c> lstquotelines=PSG_Test_Utility.createCpQuoteLines(lstquote[0].Id,1);
            Test.stopTest();
        }
    }
    static testMethod void cpQuoteScheduleTest(){ 
        List<User> lstUsers3 = PSG_Test_Utility.createAdminUser(); 
        System.assert(!lstUsers3.isEmpty(),'User inserted');
        system.runAs(lstUsers3[0]){
            Test.startTest();
            PSG_BatchUpdateCPQuotes cpQuoteBatch = new PSG_BatchUpdateCPQuotes();
            database.executeBatch(cpQuoteBatch);
            PSG_BatchUpdateCPQuotes m = new PSG_BatchUpdateCPQuotes();
            String sch = '20 30 8 10 2 ?';
            String jobID = system.schedule('Merge Job', sch, m);
            Test.stopTest();
        }  
    }

    
    static testMethod void cpQuoteScheduleTest1(){ 
        SBQQ__Quote__c q=[Select Id from SBQQ__Quote__c where core_cpq_original_quote__c != null LIMIT 1];  
        List<User> sosUserList = PSG_Test_Utility.createSOSUser();
        System.runAs(sosUserList[0]){
            q.core_cpq_extended_cp_quote_cb__c=true;
            update q;
            SBQQ__QuoteLine__c ql=[Select Id,core_cpq_PRID__c,SBQQ__Product__c,core_cpq_quote_line_type_txt__c from SBQQ__QuoteLine__c Where SBQQ__Quote__c=:q.Id LIMIT 1];
            price_prid__c prid=new price_prid__c(core_cpq_active_cb__c = true,
                                                                                core_cpq_active_pricing_cb__c = true,
                                                                                core_cpq_device__c =ql.SBQQ__Product__c ,
                                                                                core_cpq_type__c = ql.core_cpq_quote_line_type_txt__c,
                                                                                core_cpq_lower_bound_qty_nbr__c = 10,
                                                                                core_cpq_upper_bound_qty_nbr__c = 20,
                                                                                price_amt__c = 250,
                                                                                core_cpq_price_start_date_dt__c = System.today(),
                                                                                core_cpq_price_end_date_dt__c = System.today()+30,
                                                                                core_cpq_quote__c = q.Id,
                                                                                core_cpq_quoteline__c = ql.Id);
            insert prid;
            ql.core_cpq_PRID__c=prid.Id;
            Update ql;
        }
        List<User> lstUsers3 = PSG_Test_Utility.createAdminUser(); 
        System.assert(!lstUsers3.isEmpty(),'User inserted');
       	system.runAs(lstUsers3[0]){
            Test.startTest();
            PSG_BatchUpdateCPQuotes cpQuoteBatch = new PSG_BatchUpdateCPQuotes();
            database.executeBatch(cpQuoteBatch);
            Test.stopTest();
        } 
    }
    }