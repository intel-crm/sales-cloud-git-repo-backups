/****************************************************************************************************
Apex Class Name : PSG_QuoteLineBusinessLogic_Test
Version         : 1.0 
Created Date    : 4/26/2021
Function        : Test class for PSG_QuoteLineBusinessLogic
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijaykanth                 4/26/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_QuoteLineBusinessLogic_Test {
    @testSetup
    public static void setUpData(){
        SBQQ.TriggerControl.disable();
        List<User> lstUsers3 = PSG_Test_Utility.createSOSUser();
        if(!lstUsers3.isEmpty()){
            System.assert(!lstUsers3.isEmpty(),'User');
            List<PermissionSetAssignment> pas=new List<PermissionSetAssignment>();
            for(PermissionSet p : [Select Id from PermissionSet where Name=:Label.PSG_Quote_BO_PermissionSet or Name=:Label.PSG_Quote_BM_PermissionSet or Name=:Label.PSG_PermissionSets_PSG_Distributor ]){
                PermissionSetAssignment pa=new PermissionSetAssignment();
                pa.AssigneeId=lstUsers3[0].Id;
                pa.PermissionSetId=p.Id;
                pas.add(pa);
            }
            insert pas;
            system.runAs(lstUsers3[0]){    
                Test.startTest();
                System.assert(!lstUsers3.isEmpty(), '');     
                PSG_Test_Utility.CreatePriceBook('ASMO');
                Account dc = PSG_Test_Utility.createDirectAccount();
                Account acc = PSG_Test_Utility.createAccount();
                acc.Core_Direct_Pricing_Parent_Id__c=dc.id;
                acc.Core_Direct_Legal_Parent_Id__c=dc.id;
                update acc;
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                Opportunity oppty = PSG_Test_Utility.createOpportunity(acc.Id);
                List<User> uSOS = PSG_Test_Utility.createSOSUser();
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
                List<Product2> lstprod = PSG_Test_Utility.createProduct(2);
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 1);
                List<price_msvp__c> msvpList = PSG_Test_Utility.createMSVP(lstprod[0].Id);
                List<price_forward_cost__c> fwdcostList = PSG_Test_Utility.createfwdcost(lstprod[0].Id);
                Test.stopTest();
                pricebook2 pb = [Select Id from pricebook2 limit 1];
                List<core_cpq_list_price__c> lp = PSG_Test_Utility.createlp(lstprod[0].Id, pb.Id);
                List<price_prid__c> prid = PSG_Test_Utility.CreatePrid(acc.Id, null, null, lstprod[0].Id);
                List<price_prid__c> prid1 = PSG_Test_Utility.CreatePrid(PSG_Test_Utility.createAccount().Id, null, null, lstprod[0].Id);
                Core_Design_Registration__c designRegistration =new Core_Design_Registration__c();                
                designRegistration.Core_Opportunity_Id__c=oppty.id;                
                designRegistration.Core_Product_Group_Nm__c='FPGA/Power';
                designRegistration.Core_Design_Registration_Nm__c='testDesignres';
                designRegistration.Core_Design_Registration_Dsc__c='desing res decription';
                designRegistration.Core_Opportunity_Volume_Cnt__c=20;
                designRegistration.Core_Partner_FAE_Nm__c='Me';
                designRegistration.Core_End_Customer_Nm__c='testNameEndcust';
                designRegistration.Core_End_Customer_Street_Addr_Line1_Txt__c='bakerstreet';
                designRegistration.Core_End_Customer_City_Nm__c='Texas';
                designRegistration.Core_End_Customer_Country_Subdivision_Nm__c='Bihar';
                designRegistration.PCC_End_Customer_Country__c='India';
                designRegistration.Core_End_Customer_Postal_Cd__c='78100006';
                designRegistration.PCC_Digital_Identifier__c = 'WeChat';
                designRegistration.Core_End_Customer_Country_Nm__c='USA';
                designRegistration.PCC_Digital_Identifier_Value__c='abc';
                designRegistration.Core_End_Customer_Account_Id__c=acc.id;
                designRegistration.PCC_Industry__c = 'Consulting';
                designRegistration.PCC_Sub_Industry__c='Consulting';
                designRegistration.Core_Military_Aerospace_Gvrnmt_Use_Ind__c='No';
                
                designRegistration.Core_Product_Segment_Nm__c='Client Computing';
                designRegistration.Core_Product_Application_Nm__c='Business Desktop';
                designRegistration.Core_Opportunity_Decision_Dt__c=system.today();
                designRegistration.Core_First_Customer_Ship_Dt__c=System.today().adddays(2);
                designRegistration.Core_Production_End_Dt__c=System.today().addYears(2);
                designRegistration.Core_Vertical_Market_Nm__c='Agriculture';
                designRegistration.Core_Intel_Platform_Nm__c='KASEYVILLE';
                
                insert designRegistration;
                Product2 product = new Product2(Name='TestProduct',
                                                Core_Product_Org__c = 'Sales',
                                                Core_Product_Type__c = 'Processors',
                                                Core_Design_Registration_Eligible_Ind__c = true,
                                                Core_Sales_Visible_Flag__c = true,
                                                Core_Hierarchy_ID__c = '43',
                                                Core_Group_Code_Short_Name__c = 'DCG',
                                                Core_Item_Quotable_Ind__c = true,
                                                Core_Item_Orderable_Ind__c = true,
                                                Core_Item_Class_Nm__c = 'IC',
                                                IsActive = true);
                
                Core_Design_Registration_Product__c designRegistrationProduct=new Core_Design_Registration_Product__c();
                designRegistrationProduct.Core_Target_Resale_Amt__c=200;
                designRegistrationProduct.Core_Product_Id__c=product.Id;
                designRegistrationProduct.Core_Design_Registration_Id__c=designRegistration.id;
                designRegistrationProduct.Core_Full_Year_Qty__c=10;
                designRegistrationProduct.Core_Design_Product_Status_Nm__c= 'Approved';  
                designRegistrationProduct.Core_Submission_Type__c='M2M';
                insert designRegistrationProduct;
                
                Core_Product_Ext_Attribute__c l1 = new Core_Product_Ext_Attribute__c();
                l1.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
                l1.Core_Prod_Tool_Type_Nm__c = 'CORPORATE';
                l1.Core_SW_Lic_Type_Nm__c = 'FIXED';
                l1.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
                l1.Core_SW_Prod_Web_Dsc__c='Test';
                l1.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
                l1.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
                l1.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
                insert l1;
                
            }
        }
    }
    
    @isTest
    private static void testMethod1(){
        List<User> lstUsers3 = PSG_Test_Utility.createSOSUser(); 
        if(!lstUsers3.isEmpty()){   
            system.runAs(lstUsers3[0]){ 
                System.assert(!lstUsers3.isEmpty(),'User');
                SBQQ.TriggerControl.disable();                
                Account acc=[Select Id from Account LIMIT 1];
                List<Product2> lstprod=[Select Id from Product2];
                PriceBook2 pb=[Select Id from PriceBook2 LIMIT 1];
                List<price_PRID__C> prid=[Select Id from price_PRID__C];
                List<SBQQ__Quote__c> lstquote=[Select Id from SBQQ__Quote__c];
                List<Core_Design_Registration_Product__c> designRegistrationProduct=[Select Id from Core_Design_Registration_Product__c where Core_Design_Product_Status_Nm__c= 'Approved' LIMIT 1];
                
                if(lstquote[0] != null){
                    Test.startTest();
                    lstquote[0].core_cpq_price_book_nm__c = pb.Id;
                    PSG_Test_Utility.createDistiMargin(pb.Id,1);
                    lstquote[0].SBQQ__Status__c = 'Draft';                    
                    Update lstquote[0];
                    List<SBQQ__QuoteLine__c> lstquoteLines = PSG_Test_Utility.createQuoteLinesWithoutInsert(lstquote[0].Id,new Set<Id>{lstprod[0].Id,lstprod[1].Id},prid[0].Id);
                    insert lstquoteLines;
                    List<SBQQ__QuoteLine__c> lstquoteLines1 = [Select Id,core_cpq_design_registration_product__c,core_cpq_PRID__c,price_suggested_resale_amt__c,SBQQ__Quantity__c,SBQQ__Source__c from SBQQ__QuoteLine__c];
                    lstquoteLines[1].core_cpq_design_registration_product__c = designRegistrationProduct[0].Id;
                    lstquoteLines[1].core_cpq_PRID__c = prid[1].Id;
                    lstquoteLines[0].price_suggested_resale_amt__c = 456;
                    lstquoteLines[0].SBQQ__Quantity__c = 456;
                    lstquoteLines[0].core_cpq_design_registration_product__c = designRegistrationProduct[0].Id;
                    lstquoteLines[1].SBQQ__Source__c = lstquoteLines[0].Id;
                    Database.update(lstquoteLines,false);
                    //update lstquoteLines1;
                    lstquote[0].SBQQ__Status__c = 'Approved';
                    Update lstquote[0];
                    Test.stopTest();
                }
            }            
        }
    }
    @isTest
    private static void testMethod2(){
        List<User> lstUsers2 = PSG_Test_Utility.createBMUser();
        Map<Id,Boolean> prodIdToRegFlagMap=new Map<Id,Boolean>();
        if(!lstUsers2.isEmpty()){   
            system.runAs(lstUsers2[0]){ 
                System.assert(!lstUsers2.isEmpty(),'User');
                SBQQ.TriggerControl.disable();
                Account acc = [Select Id from Account WHERE Core_Direct_Pricing_Parent_Id__c!= NULL LIMIT 1];
                List<Product2> lstprod = [Select Id from Product2];
                Core_Product_Ext_Attribute__c prodext=[select id from Core_Product_Ext_Attribute__c limit 1];
                Opportunity oppty = PSG_Test_Utility.createOpportunity(acc.Id);
                SBQQ__Quote__c quote1 = PSG_Test_Utility.createQuoteRecord(acc.Id, oppty.Id);
                insert quote1;
                prodext.Core_Product_Id__c=lstprod[0].Id;
                update prodext;
                Test.startTest();
                List<SBQQ__QuoteLine__c> lstquoteLines1 = PSG_Test_Utility.createQuoteLinesWithoutInsert(quote1.Id,new Set<Id>{lstprod[0].Id},null);
                insert lstquoteLines1;
                SBQQ__Quote__c quote2 = PSG_Test_Utility.createQuoteRecord(acc.Id, oppty.Id);
                insert quote2;
                List<SBQQ__QuoteLine__c> lstquoteLines2 = PSG_Test_Utility.createQuoteLinesWithoutInsert(quote2.Id,new Set<Id>{lstprod[1].Id},null);
                insert lstquoteLines2;
                lstquoteLines2[0].SBQQ__Product__c = lstprod[0].Id;                
                Database.update(lstquoteLines2[0],false) ;
                prodIdToRegFlagMap.put(lstprod[0].Id,true);
                PSG_QuoteLineBusinessLogic.fetchQLwithRestrcitedProduct(prodIdToRegFlagMap);
                Test.stopTest();
            }
        }
    }
}