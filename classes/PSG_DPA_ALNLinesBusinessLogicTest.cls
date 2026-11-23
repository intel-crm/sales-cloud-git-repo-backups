/****************************************************************************************************
Apex Class Name : PSG_DPA_ALNLinesBusinessLogicTest
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_DPA_ALNLinesBusinessLogic.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshadeep             08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_DPA_ALNLinesBusinessLogicTest {
    @testSetup
    public static void setUpData(){
        SBQQ.TriggerControl.disable();
        List<User> lstUsers3 = PSG_Test_Utility.createSOSUser();
        if(!lstUsers3.isEmpty()){
            system.runAs(lstUsers3[0]){    
                Account acc = PSG_Test_Utility.createAccount();
                Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
				acc.RecordTypeId = accRecordTypeId;
                acc.Core_Direct_Account_Type_Nm__c ='End Customer Parent';
                acc.Core_Is_Pricing_Parent_ChkBox__c=true;
                acc.Core_Direct_Account_Active_Ind__c=true;
                update acc;
                Account acct = PSG_Test_Utility.createDistyAccount();
                User distyUser = PSG_Test_Utility.createDistyTestUser(acct.Id);
                Account acc2 = PSG_Test_Utility.createAccount();
                Id accRecordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
				acc2.RecordTypeId = accRecordTypeId2;
                acc.Core_Direct_Account_Type_Nm__c ='End Customer Parent';
                acc2.Core_Direct_Pricing_Parent_Id__c = acc.Id;
                acc2.Core_Direct_Legal_Parent_Id__c = acc.Id;
                acc2.Core_PSG_Account__c = true;
                update acc2;
                
                Contact con = PSG_Test_Utility.createContact(acc2.Id);
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc2.Id);
                PriceBook2 p=PSG_Test_Utility.CreatePriceBook('PSG Price Book');
                List<Product2> lstProd = PSG_Test_Utility.CreateProduct(1);               
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc2.Id, con.Id, 1);
                lstquote[0].core_cpq_margin_geo_txt__c = 'ASMO';
                lstquote[0].core_cpq_price_book_nm__c=p.Id;
                lstquote[0].Pricing_Quote_Program_Nm__c = 'Tender';
                lstquote[0].core_cpq_disty_group_name__c='PSG_MOUSER';
                lstquote[0].core_cpq_sap_ecp_nm__c = acc.Id;
                lstquote[0].core_cpq_end_customer_nm__c =acc2.Id;
                lstquote[0].core_cpq_active_cb__c = false;
                update lstquote[0];
                
                update lstquote;
                Test.StartTest();
                List<SBQQ__QuoteLine__c> lstquoteLines = PSG_Test_Utility.createQuoteLines(lstquote[0].id, 1);
                
                List<core_cpq_dpa_aln__c> lstdpa = PSG_Test_Utility.createDPARecord(lstquote[0],acc.Id);
                lstdpa[0].core_cpq_account_program__c = 'PSG Demand Creation - PSG';
                update lstdpa;
                core_cpq_distributor_margin__c distyMargin = new core_cpq_distributor_margin__c();
                distyMargin.core_cpq_Active_Cb__c = true;
                distyMargin.core_cpq_Account_Tier_Txt__c= 'PSG-Tier 4';
                distyMargin.core_cpq_Price_Book__c = p.Id;
                distyMargin.core_cpq_Disty_Margin_Pct__c= 20;
                distyMargin.core_cpq_Partner_Program_Txt__c= 'PSG Demand Creation - PSG';
                distyMargin.core_cpq_Margin_GEO_Txt__c= 'ASMO';
                distyMargin.core_cpq_Effective_Date_Dt__c= System.today()-1;
                distyMargin.core_cpq_end_date__c=System.today()+100;
                distyMargin.core_cpq_dm_type__c = 'Hunter';
                distyMargin.core_cpq_Registered_Product_Txt__c = True;
                distyMargin.core_cpq_Approved_Registration_Txt__c= 'No';
                insert distyMargin;
                List<core_cpq_dpa_aln_line__c> lstdpaalnLines = PSG_Test_Utility.createDPALinesWithoutInsert(lstdpa[0].id, 1);
                lstdpaalnLines[0].core_cpq_quote_item_line_no__c=lstquoteLines[0].Id;
                insert lstdpaalnLines;
                Test.StopTest(); 
                
            }   
        }
    }
   public static testmethod void testData1(){
       SBQQ.TriggerControl.disable();
       Test.StartTest();
       List<User> lstUsers = PSG_Test_Utility.createSOSUser();
       Account acc = [select id from Account limit 1];
       List<SBQQ__Quote__c> lstquote   = [select id from SBQQ__Quote__c limit 1];
       List<SBQQ__QuoteLine__c> lstquoteLines = [SELECT id,core_cpq_PRID__c,Name FROM SBQQ__QuoteLine__c limit 1];
       System.runAs(lstUsers[0]){
           
           List<core_cpq_dpa_aln__c> lstDPA = [select id FROM core_cpq_dpa_aln__c limit 1 ];
           List<core_cpq_dpa_aln_line__c> lstdpaalnLines=[select id FROM core_cpq_dpa_aln_line__c limit 1 ];
           List<price_prid__c> pridList = PSG_Test_Utility.createPrid(acc.Id,null,null,null);
           pridList[0].core_cpq_prid_validity_date_dt__c = Date.newInstance(2030,01,10);
           update pridList;
           lstdpaalnLines[0].core_cpq_quote_item_line_no__c = lstquoteLines[0].id;
           lstdpaalnLines[0].core_cpq_disty_margin_pct__c = 10;
           lstdpaalnLines[0].core_cpq_resale_amt__c = 30;
           lstdpaalnLines[0].core_cpq_duration_nbr__c = 12;
           lstdpaalnLines[0].price_broken_cost_disty_amt__c = 1;
           lstdpaalnLines[0].core_cpq_ship_exp_date_dt__c = Date.newInstance(2022, 07, 15);
           lstdpaalnLines[0].core_cpq_prid__c = pridList[0].Id;
           
           update lstdpaalnLines[0];
           Test.StopTest(); 
           delete lstdpaalnLines;
           
       }       
    }
}