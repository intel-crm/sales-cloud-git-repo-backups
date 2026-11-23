/*********************************************************************************************************************
Class Name    : PSG_Chatbot_CRUD_Test
Version       : 1.0
Created Date  : 20 Dec 2022

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Ranjit Kumar      12-20-2022                  Test Class for PSG_Chatbot_CRUDClass
* *********************************************************************************************************************/


@istest
public class PSG_Chatbot_CRUD_Test {
    
    static testMethod void Test_CreatePortalRequest() {
        // Create test user
        profile pr=[SELECT Id FROM Profile WHERE Name='System Administrator'];
        PermissionSetLicense pset = [select id from PermissionSetLicense where MasterLabel ='Salesforce CPQ License'];
        User u = new user();
        u.FirstName = 'test';
        u.LastName = 'user';
        u.Email = 'xyztest247392638@intel.com';
        u.Username = 'xyztest@testabc.com';
        u.Alias = 'testu';
        u.CommunityNickname = 'test.user';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = pr.id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
       
            Account acc = PSG_Test_Utility.createAccount();           
            Contact con = PSG_Test_Utility.createContact(acc.Id);  
            List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
          List<Account> accsToUpdate=new List<Account>();
          Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
             update accsToUpdate;
             Opportunity opp = PSG_Test_Utility.createOpportunity(accsToUpdate[0].Id);
             system.runAS(u){
                
                SBQQ.TriggerControl.disable();
                SBQQ__Quote__c quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].Id,opp.id);
                quote.core_cpq_end_customer_nm__c=accsToUpdate[0].Id;
                 insert quote;
                 SBQQ__Quote__c quote2 =[select id,name from SBQQ__Quote__c where id =:quote.id limit 1];
                Test.startTest();
                 SBQQ.TriggerControl.disable();
                List<SBQQ__QuoteLine__c> lstquoteLines = PSG_Test_Utility.createQuoteLines(quote2.id, 1);
                SBQQ__QuoteLine__c quoteline2 =[select id,name from SBQQ__QuoteLine__c where id =:lstquoteLines[0].Id limit 1];
                List<core_cpq_dpa_aln__c> lstdpa = PSG_Test_Utility.createDPARecord(quote2,acc.Id);
                core_cpq_dpa_aln__c dpa2 =[select id,name from core_cpq_dpa_aln__c where id =:lstdpa[0].Id limit 1]; 
                List<core_cpq_dpa_aln_line__c> lstdpaalnLines = PSG_Test_Utility.createDPALinesWithoutInsert(dpa2.id, 1);
                lstdpaalnLines[0].core_cpq_quote_item_line_no__c=lstquoteLines[0].Id;
                lstdpaalnLines[0].price_broken_cost_disty_amt__c=2;
                insert lstdpaalnLines; 
                 core_cpq_dpa_aln_line__c dpaline2 =[select id,name from core_cpq_dpa_aln_line__c where id =:lstdpaalnLines[0].Id limit 1];
                 Test.stopTest();
                
        // Create input
        PSG_Chatbot_CRUDClass.input quoteInput = new PSG_Chatbot_CRUDClass.input();
        quoteInput.Quote = quote2.Name;
        quoteInput.Operation = 'Quote';
        quoteInput.Fieldname = 'core_cpq_active_cb__c';
        quoteInput.Objectname = 'SBQQ__Quote__c';
        quoteInput.RequestType = 'Quote Deactivation';
        quoteInput.Active = 'false';
        quoteInput.Userid = u.Id;
        
        PSG_Chatbot_CRUDClass.input quoteLineInput = new PSG_Chatbot_CRUDClass.input();
        quoteLineInput.Quote = quote2.Name;
        quoteLineInput.Operation = 'QuoteLine';
        quoteLineInput.Fieldname = 'price_requested_resale_amt__c';
        quoteLineInput.Objectname = 'SBQQ__QuoteLine__c';
        quoteLineInput.RequestType = 'Field Update';
        quoteLineInput.RequestedResale = 54;
        quoteLineInput.QuoteLine = quoteline2;
        quoteLineInput.Userid = u.Id;
                 
        PSG_Chatbot_CRUDClass.input quoteLineInput1 = new PSG_Chatbot_CRUDClass.input();
        quoteLineInput1.Quote = quote2.Name;
        quoteLineInput1.Operation = 'QuoteLine';
        quoteLineInput1.Fieldname = 'SBQQ__Quantity__c';
        quoteLineInput1.Objectname = 'SBQQ__QuoteLine__c';
        quoteLineInput1.RequestType = 'Field Update';
        quoteLineInput1.EAU = 54;
        quoteLineInput1.QuoteLine = quoteline2;
        quoteLineInput1.Userid = u.Id;        
        
        PSG_Chatbot_CRUDClass.input dpalineInput = new PSG_Chatbot_CRUDClass.input();
        dpalineInput.DPA = dpa2.Name;
        dpalineInput.Operation = 'DPA & ALN Line';
        dpalineInput.Fieldname = 'core_cpq_requested_qty_nbr__c';
        dpalineInput.Objectname = 'core_cpq_dpa_aln_line__c';
        dpalineInput.RequestType = 'Field Update';
        dpalineInput.RequestedQty = 1000;
        dpalineInput.DPAlines = dpaline2;
        dpalineInput.Userid = u.Id;
                 
        PSG_Chatbot_CRUDClass.input dpalineInput2 = new PSG_Chatbot_CRUDClass.input();
        dpalineInput2.DPA = dpa2.Name;
        dpalineInput2.Operation = 'DPA & ALN Line';
        dpalineInput2.Fieldname = 'core_cpq_disty_margin_pct__c';
        dpalineInput2.Objectname = 'core_cpq_dpa_aln_line__c';
        dpalineInput2.RequestType = 'Field Update';
        dpalineInput2.DistyMargin = 5;
        dpalineInput2.DPAlines = dpaline2;
        dpalineInput2.Userid = u.Id;         
        
        PSG_Chatbot_CRUDClass.input dpaInput = new PSG_Chatbot_CRUDClass.input();
        dpaInput.DPA = dpa2.Name;
        dpaInput.Operation = 'DPA & ALN';
        dpaInput.Fieldname = 'core_cpq_ship_end_date_dt__c';
        dpaInput.Objectname = 'core_cpq_dpa_aln__c';
        dpaInput.RequestType = 'Field Update';
        dpaInput.ShipEndDate = system.today();
        dpaInput.DPAlines = lstdpaalnLines[0];
        dpaInput.Userid = u.Id;         
                 
        
        // Create input list
        List<PSG_Chatbot_CRUDClass.input> inputList = new List<PSG_Chatbot_CRUDClass.input>{quoteInput};
        List<PSG_Chatbot_CRUDClass.input> inputList1 = new List<PSG_Chatbot_CRUDClass.input>{quoteLineInput};
        List<PSG_Chatbot_CRUDClass.input> inputList2 = new List<PSG_Chatbot_CRUDClass.input>{quoteLineInput1}; 
        List<PSG_Chatbot_CRUDClass.input> inputList3 = new List<PSG_Chatbot_CRUDClass.input>{dpaInput};
        List<PSG_Chatbot_CRUDClass.input> inputList4 = new List<PSG_Chatbot_CRUDClass.input>{dpalineInput};
        List<PSG_Chatbot_CRUDClass.input> inputList5 = new List<PSG_Chatbot_CRUDClass.input>{dpalineInput2};    
        // Call getDetails
            PSG_Chatbot_CRUDClass.getDetails(inputList);
            PSG_Chatbot_CRUDClass.getDetails(inputList1);
            PSG_Chatbot_CRUDClass.getDetails(inputList2); 
            PSG_Chatbot_CRUDClass.getDetails(inputList3);
            PSG_Chatbot_CRUDClass.getDetails(inputList4);
            PSG_Chatbot_CRUDClass.getDetails(inputList5);     
        
        // Verify records
        List<core_cpq_portalrequest__c> portalReqList = [SELECT Id,core_cpq_bot_field_name__c, core_cpq_bot_Object_Name__c, 
                                                        core_cpq_record_number__c, core_cpq_request_type__c, 
                                                        core_cpq_value__c,core_cpq_Status__c
                                                        FROM core_cpq_portalrequest__c 
                                                        WHERE core_cpq_requested_by__c = :u.Id];
        
        System.assert(portalReqList.size()>0);
        
      }

}
}