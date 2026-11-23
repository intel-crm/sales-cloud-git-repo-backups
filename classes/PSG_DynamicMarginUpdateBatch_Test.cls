/***************************************************************************
Class Name    : PSG_DynamicMarginUpdateBatch_Test
Version       : 1.0
Created Date  : 4 September 2023           
Modification Log :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------
* Ranjit              4th September 2023                        
*****************************************************************************************************************************************/
@IsTest
public class PSG_DynamicMarginUpdateBatch_Test {
    @testSetup
    public static void setUpData(){
        user u=[select id from user where profile.name='System Administrator' and isactive=true limit 1];
      
            system.runAs(u){    
                Account acc = PSG_Test_Utility.createAccount();           
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                PriceBook2 p=PSG_Test_Utility.CreatePriceBook('PSG Price Book');
                List<Product2> lstProd = PSG_Test_Utility.CreateProduct(1);               
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, con.Id, 1);
                lstquote[0].core_cpq_margin_geo_txt__c = 'ASMO';
                lstquote[0].core_cpq_price_book_nm__c=p.Id;
                lstquote[0].SBQQ__Status__c='In Progress';
                lstquote[0].core_cpq_account_program__c='PSG Demand Creation - PSG';
                update lstquote;
                core_cpq_distributor_margin__c distyMargin = new core_cpq_distributor_margin__c();
                distyMargin.core_cpq_Active_Cb__c = true;
                distyMargin.core_cpq_Account_Tier_Txt__c= 'PSG-Tier 4';
                distyMargin.core_cpq_Price_Book__c = p.Id;
                distyMargin.core_cpq_Disty_Margin_Pct__c= 20;
                distyMargin.core_cpq_Partner_Program_Txt__c= 'PSG Demand Creation - PSG';
                distyMargin.core_cpq_Margin_GEO_Txt__c= 'APJ';
                distyMargin.core_cpq_Effective_Date_Dt__c= System.today()-1;
                distyMargin.core_cpq_end_date__c=System.today()+100;
                distyMargin.core_cpq_dm_type__c = 'Hunter';
                distyMargin.core_cpq_Registered_Product_Txt__c = True;
                distyMargin.core_cpq_Approved_Registration_Txt__c= 'No';
                insert distyMargin;
                Test.startTest();
                List<SBQQ__QuoteLine__c> lstquoteLines = PSG_Test_Utility.createQuoteLines(lstquote[0].id, 1);
                Test.stopTest();
            }   
        
        
    }
    @isTest
    private static void batchupdatetest(){
        PriceBook2 p=[select id from PriceBook2 limit 1];
        core_cpq_distributor_margin__c distyMargin2 = new core_cpq_distributor_margin__c();
        distyMargin2.core_cpq_Active_Cb__c = true;
        distyMargin2.core_cpq_Account_Tier_Txt__c= 'PSG-Tier 4';
        distyMargin2.core_cpq_Price_Book__c = p.Id;
        distyMargin2.core_cpq_Disty_Margin_Pct__c= 20;
        distyMargin2.core_cpq_Partner_Program_Txt__c= 'PSG Demand Creation - PSG';
        distyMargin2.core_cpq_Margin_GEO_Txt__c= 'ASMO';
        distyMargin2.core_cpq_Effective_Date_Dt__c= System.today()-1;
        distyMargin2.core_cpq_end_date__c=System.today()+100;
        distyMargin2.core_cpq_dm_type__c = 'Hunter';
        distyMargin2.core_cpq_Registered_Product_Txt__c = True;
        distyMargin2.core_cpq_Approved_Registration_Txt__c= 'No';
        insert distyMargin2;
        core_cpq_distributor_margin__c Dmrecord=[select id from core_cpq_distributor_margin__c limit 1];
        SBQQ__Quote__c quote=[select id from SBQQ__Quote__c limit 1];
        SBQQ__QuoteLine__c Quoteline=[select id from SBQQ__QuoteLine__c limit 1];
        Test.startTest();
        Quoteline.core_cpq_distributor_margin__c=Dmrecord.id;
        update Quoteline;
        PSG_DynamicMarginUpdateBatch batch = new PSG_DynamicMarginUpdateBatch();
        Database.executeBatch(batch);
        //PSG_DynamicMarginUpdateBatch m = new PSG_DynamicMarginUpdateBatch();
        //String sch = '20 30 8 10 2 ?';
        //String jobID = system.schedule('Update Job', sch, m);        
        Test.stopTest();
    }
    
    @isTest
    private static void batchupdatetest2(){
        PriceBook2 p=[select id from PriceBook2 limit 1];
        core_cpq_distributor_margin__c distyMargin2 = new core_cpq_distributor_margin__c();
        distyMargin2.core_cpq_Active_Cb__c = true;
        distyMargin2.core_cpq_Account_Tier_Txt__c= 'PSG-Tier 4';
        distyMargin2.core_cpq_Price_Book__c = p.Id;
        distyMargin2.core_cpq_Disty_Margin_Pct__c= 20;
        distyMargin2.core_cpq_Partner_Program_Txt__c= 'PSG Demand Creation - PSG';
        distyMargin2.core_cpq_Margin_GEO_Txt__c= 'ASMO';
        distyMargin2.core_cpq_Effective_Date_Dt__c= System.today()-1;
        distyMargin2.core_cpq_end_date__c=System.today()+100;
        distyMargin2.core_cpq_dm_type__c = 'Hunter';
        distyMargin2.core_cpq_Registered_Product_Txt__c = True;
        distyMargin2.core_cpq_Approved_Registration_Txt__c= 'No';
        distyMargin2.core_cpq_product_family_txt__c='test';
        insert distyMargin2;
        core_cpq_distributor_margin__c distyMargin3=distyMargin2.clone(false,false,false,false);
        distyMargin3.core_cpq_dm_type__c='Farmer';
        insert distyMargin3;
        core_cpq_distributor_margin__c Dmrecord=[select id from core_cpq_distributor_margin__c limit 1];
        SBQQ__Quote__c quote=[select id from SBQQ__Quote__c limit 1];
        quote.core_cpq_account_program__c=null;
        update quote;
        SBQQ__QuoteLine__c Quoteline=[select id from SBQQ__QuoteLine__c limit 1];
        Test.startTest();
        Quoteline.core_cpq_distributor_margin__c=Dmrecord.id;
        update Quoteline;
        PSG_DynamicMarginUpdateBatch batch = new PSG_DynamicMarginUpdateBatch();
        Database.executeBatch(batch);
        //PSG_DynamicMarginUpdateBatch m = new PSG_DynamicMarginUpdateBatch();
        //String sch = '20 30 8 10 2 ?';
        //String jobID = system.schedule('Update Job', sch, m);        
        Test.stopTest();
        
    }
    
    
}