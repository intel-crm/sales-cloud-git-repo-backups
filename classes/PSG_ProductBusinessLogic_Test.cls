/****************************************************************************************************
Apex Class Name : PSG_ProductBusinessLogic_Test
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_ProductBusinessLogic.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_ProductBusinessLogic_Test {
    @isTest
    private static void testRelatedRecordsUpdateOnInsert(){
        List<Product2> prods=new  List<Product2>();
        List<price_forward_cost__c> pfcs=new List<price_forward_cost__c>();
        List<price_msvp__c> msvps=new List<price_msvp__c>();
        List<PriceBookEntry> pbes=new List<PriceBookEntry>();
        Product2 p=new Product2();
        p.core_OPN__c='INTELPROD';
        p.Name='Intel Prod 1';
        p.Core_Hierarchy_ID__c='59';
        p.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p.IsActive=true;
        p.Core_Product_org__c = 'Sales';
        insert p;
        price_forward_cost__c pfc= new price_forward_cost__c();
        pfc.core_cpq_product_nm__c=p.Id;
        pfc.Name='Forward Cost';
        pfc.core_cpq_product_opn_txt__c='INTELPROD';
        insert pfc;        
        price_msvp__c msvp=new price_msvp__c();
        msvp.core_cpq_product_nm__c=p.Id;
        msvp.core_cpq_isactive__c=true;
        msvp.core_cpq_effective_date_dt__c=System.today().addDays(10);
        insert msvp;
        price_msvp__c msvp1=new price_msvp__c();
        msvp1.core_cpq_product_nm__c=p.Id;
        msvp1.core_cpq_isactive__c=true;
        msvp.core_cpq_effective_date_dt__c=System.today().addDays(20);
        insert msvp1;
        PriceBook2 pb=PSG_Test_Utility.createPricebook('Intel Pricebook 1');
        PriceBook2 pb1=PSG_Test_Utility.createPricebook('Intel Pricebook 2');
        Test.startTest();
        pbes.add(new PriceBookEntry (Product2Id =p.Id  , Pricebook2Id= Test.getStandardPricebookId(),price_disty_cost__c= 36,UnitPrice=235,IsActive = true));
        pbes.add(new PriceBookEntry (Product2Id =p.Id  , Pricebook2Id= pb.Id,price_disty_cost__c= 36,UnitPrice=235,IsActive = true));
        pbes.add(new PriceBookEntry (Product2Id =p.Id  , Pricebook2Id= pb1.Id,price_disty_cost__c= 36,UnitPrice=235,IsActive = true));
        insert pbes;
        core_cpq_list_price__c newLP=new core_cpq_list_price__c();
        newLP.Pricebookentry__c=pbes[1].Id;
        newLP.core_cpq_product_name__c=p.Id;
        newLP.core_cpq_Price_Book__c=pb.Id;
        newLP.core_cpq_unique_id__c=''+25+'.0'+25+'.0'+p.Id+pbes[1].Id;
        insert newLP;
        Product2 p1=new Product2();
        p1.core_OPN__c='INTELPROD';
        p1.Name='Intel Prod 2';
        p1.Core_Hierarchy_ID__c='43';
        p1.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p1.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p1.IsActive=true;
        p1.Core_Product_org__c = 'Sales';
        insert p1;
        p1.IsActive=false;
        update p1;
        p1.IsActive=true;
        update p1;
        System.assert(p1!=null, 'Product inserted');
        Test.stopTest();
    }
    @isTest
    private static void testRelatedRecordsUpdateOnUpdate(){
        List<Product2> prods=new  List<Product2>();
        List<price_forward_cost__c> pfcs=new List<price_forward_cost__c>();
        List<price_msvp__c> msvps=new List<price_msvp__c>();
        List<PriceBookEntry> pbes=new List<PriceBookEntry>();
        Product2 p=new Product2();
        p.core_OPN__c='INTELPROD';
        p.Name='Intel Prod 1';
        p.Core_Hierarchy_ID__c='59';
        p.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p.IsActive=true;
        p.Core_Product_org__c = 'Sales';
        prods.add(p);
        Product2 p1=new Product2();
        p1.core_OPN__c='INTELPROD1';
        p1.Name='Intel Prod 2';
        p1.Core_Hierarchy_ID__c='43';
        p1.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p1.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p1.IsActive=true;
        p1.Core_Product_org__c = 'Sales';
        prods.add(p1);
        insert prods;
        price_forward_cost__c pfc= new price_forward_cost__c();
        pfc.core_cpq_product_nm__c=p.Id;
        pfc.Name='Forward Cost';
        pfc.core_cpq_product_opn_txt__c='INTELPROD';
        insert pfc;
        price_forward_cost__c pfc1= new price_forward_cost__c();
        pfc1.core_cpq_product_nm__c=p1.Id;
        pfc1.Name='Forward Cost';
        pfc1.core_cpq_product_opn_txt__c='INTELPROD1';
        insert pfc1;
        Test.startTest();
        price_msvp__c msvp=new price_msvp__c();
        msvp.core_cpq_product_nm__c=p.Id;
        msvp.core_cpq_isactive__c=true;
        msvp.core_cpq_effective_date_dt__c=System.today().addDays(10);
        insert msvp;
        price_msvp__c msvp1=new price_msvp__c();
        msvp1.core_cpq_product_nm__c=p.Id;
        msvp1.core_cpq_isactive__c=true;
        msvp.core_cpq_effective_date_dt__c=System.today().addDays(20);
        insert msvp1;
        System.assert(msvp1!=null, 'MSVP inserted');
        PriceBook2 pb=PSG_Test_Utility.createPricebook('Intel Pricebook 1');
        PriceBook2 pb1=PSG_Test_Utility.createPricebook('Intel Pricebook 2');
        pbes.add(new PriceBookEntry (Product2Id =p.Id  , Pricebook2Id= Test.getStandardPricebookId(),price_disty_cost__c= 36,UnitPrice=235,IsActive = true));
        pbes.add(new PriceBookEntry (Product2Id =p.Id  , Pricebook2Id= pb.Id,price_disty_cost__c= 36,UnitPrice=235,IsActive = true));
        pbes.add(new PriceBookEntry (Product2Id =p.Id  , Pricebook2Id= pb1.Id,price_disty_cost__c= 36,UnitPrice=235,IsActive = true));
        pbes.add(new PriceBookEntry (Product2Id =p1.Id  , Pricebook2Id= Test.getStandardPricebookId(),price_disty_cost__c= 36,UnitPrice=235,IsActive = true));
        insert pbes;
        core_cpq_list_price__c lp=new core_cpq_list_price__c();
        lp.core_cpq_list_price_amt__c=500;
        lp.core_cpq_lowerbound_qty__c=1;
        lp.core_cpq_upperbound_qty__c=25;
        lp.core_cpq_product_name__c=pbes[1].Product2Id;
        lp.Pricebookentry__c=pbes[1].Id;
        lp.core_cpq_Price_Book__c=pbes[1].Pricebook2Id;
        insert lp;
        p1.IsActive=true;
        update p1;
        list<price_forward_cost__c> associatedFC=PSG_ProductBusinessLogic.fetchFCRelatedList(p1.id,'core_cpq_fc_start_date_dt__c','ASC');
        system.Assert(associatedFC.size()>0);
        Test.stopTest();
    }
}