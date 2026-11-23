/****************************************************************************************************
Apex Class Name : PSG_CPQuoteLinesBusinessLogic_Test
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_CPQuoteLinesBusinessLogic.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshadeep             08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_CPQuoteLinesBusinessLogic_Test {
    /*
    @testSetup
    public static void setUpData(){
        SBQQ.TriggerControl.disable();
        List<User> lstUsers3 = PSG_Test_Utility.createBOUser();
        if(!lstUsers3.isEmpty()){
            System.assert(!lstUsers3.isEmpty(), 'User created');
            system.runAs(lstUsers3[0]){ 
                Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
                Account acc = PSG_Test_Utility.createAccount();
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
                acc.Core_PSG_Account__c=true;
                acc.Core_Direct_Pricing_Parent_Id__c=a2.id;
                acc.Core_Direct_Legal_Parent_Id__c=a1.Id;
                update acc;
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                PSG_Test_Utility.CreatePriceBook('PSG Price Book');
                List<Product2> lstProd = PSG_Test_Utility.CreateProduct(1);
               
                Test.StartTest();
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createCpQuote(acc.Id, con.Id, 1);
                List<price_msvp__c> msvpList = PSG_Test_Utility.createMSVP(lstprod[0].Id);
                Test.StopTest(); 
            }   
        }
    }
    public static testmethod void testData1(){
        SBQQ.TriggerControl.disable();
        List<User> lstUsers3 = PSG_Test_Utility.createBOUser();
        if(!lstUsers3.isEmpty()){
            System.assert(!lstUsers3.isEmpty(), 'User created');
            system.runAs(lstUsers3[0]){ 
                List<SBQQ__Quote__c> lstquote   = [select id, core_cpq_price_eligibility_date_dt__c, core_cpq_pricing_end_date_dt__c,core_cpq_review_date_dt__c,core_cpq_pricing_start_date_dt__c from SBQQ__Quote__c limit 1];
                List<SBQQ__QuoteLine__c> lstquoteLines = PSG_Test_Utility.createCpQuoteLines(lstquote[0].id, 2); 
             //   lstquoteLines[0].core_cpq_years_nbr__c = null;
              //  update lstquoteLines;
                Test.StartTest();
                List<Product2> lstprod = [select id,Core_OPN__c from Product2];
                for(Product2 prod : lstprod){
                    prod.Core_OPN__c = 'TESTXYZ123' + Math.random();
                }
                update lstprod;
                lstquoteLines[0].core_cpq_price_eligibility_date_dt__c = lstquote[0].core_cpq_price_eligibility_date_dt__c;
                lstquoteLines[0].core_cpq_pricing_end_date_dt__c = lstquote[0].core_cpq_pricing_end_date_dt__c;
                lstquoteLines[0].core_cpq_review_date_dt__c = lstquote[0].core_cpq_review_date_dt__c;
                lstquoteLines[0].core_cpq_pricing_start_date_dt__c =lstquote[0].core_cpq_pricing_start_date_dt__c;
                lstquotelines[0].price_disty_cost_nbr__c = null;
                lstquotelines[0].SBQQ__ListPrice__c = null;
                lstquotelines[0].SBQQ__CustomerPrice__c = null;
                lstquotelines[0].SBQQ__NetPrice__c = null;
                lstquotelines[0].SBQQ__PartnerPrice__c = null;
                lstquotelines[0].SBQQ__RegularPrice__c = null;
                lstquotelines[0].SBQQ__UpliftAmount__c = null;
                lstquotelines[0].SBQQ__SpecialPrice__c = null;
                lstquotelines[0].core_cpq_years_nbr__c = null;
                List<Product2> lstprod1 = [select id from Product2 limit 1];
                lstquotelines[0].SBQQ__Product__c = lstProd1[0].Id;
                lstquotelines[0].core_cpq_lower_bound_qty_qty__c = 1;
                lstquotelines[0].core_cpq_upper_bound_qty_nbr__c = 10;
                lstquoteLines[0].core_cpq_product_nm__c = lstprod[0].id;
                //lstquoteLines[0].price_suggested_resale_amt__c=15;
            	//lstquoteLines[0].core_cpq_distributor_margin_pct__c=1;
                update lstquoteLines[0];
               
                lstquoteLines[1].core_cpq_product_nm__c = lstprod[0].id;
                update lstquoteLines[1];
                Test.StopTest(); 
            }
        }
    }
    */
}