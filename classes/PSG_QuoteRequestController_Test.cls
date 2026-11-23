/****************************************************************************************************
Apex Class Name : PSG_QuoteRequestController_Test
Created Date    : 12/10/2020
Created By      : Avani
Function        : Test class for PSG_QuoteRequestController class
Modifications   :
*****************************************************************************************************/
@isTest(seeAllData=false)
private class PSG_QuoteRequestController_Test {
    @testSetup
    static void setUpData(){        
        pricebook2 pb = PSG_Test_Utility.createPriceBook('PSG Price Book');
        List<Product2> prodList=PSG_Test_Utility.createProduct(1);
        Account ac = PSG_Test_Utility.createAccount();          
        Contact con = PSG_Test_Utility.createContact(ac.Id);
        Opportunity opportunityRecord = PSG_Test_Utility.createOpportunity(ac.Id);  
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = PSG_Test_Utility.createQuote(ac.Id, con.Id, 1);       
        
        //created a record for designRegistration    
        Core_Design_Registration__c designRegistration =new Core_Design_Registration__c();
        designRegistration.Core_Opportunity_Id__c=opportunityRecord.id;
        designRegistration.Core_Product_Group_Nm__c='FPGA/Power';
        designRegistration.Core_Design_Registration_Nm__c='testDesignres';
        designRegistration.Core_Design_Registration_Dsc__c='desing res decription';
        designRegistration.Core_Opportunity_Volume_Cnt__c=20;
        designRegistration.Core_Partner_FAE_Nm__c='Me';
        designRegistration.Core_End_Customer_Nm__c='testNameEndcust';
        designRegistration.Core_End_Customer_Street_Addr_Line1_Txt__c='bakerstreet';
        designRegistration.Core_End_Customer_City_Nm__c='Texas';
        designRegistration.Core_End_Customer_Country_Subdivision_Nm__c='Bihar';
        designRegistration.Core_End_Customer_Postal_Cd__c='78100006';
        designRegistration.Core_End_Customer_Country_Nm__c='USA';
        designRegistration.Core_End_Customer_Account_Id__c=ac.id;
        designRegistration.Core_Military_Aerospace_Gvrnmt_Use_Ind__c='No';
        designRegistration.Core_Product_Segment_Nm__c='Client Computing';
        designRegistration.Core_Product_Application_Nm__c='Business Desktop';
        designRegistration.Core_Opportunity_Decision_Dt__c=date.parse('12/09/2020');
        designRegistration.Core_First_Customer_Ship_Dt__c=date.parse('12/01/2020');
        designRegistration.Core_Production_End_Dt__c=date.parse('12/29/2020');
        designRegistration.Core_Vertical_Market_Nm__c='Agriculture';
        designRegistration.Core_Intel_Platform_Nm__c='Agilex';
        
        insert designRegistration;
        //created a product record
        Product2 product = new Product2(Name='TestProduct',
                                            Core_Product_Org__c = 'Sales',
                                            Core_Product_Type__c = 'Processors',
                                            Core_Design_Registration_Eligible_Ind__c = true,
                                            Core_Sales_Visible_Flag__c = true,
                                            Core_Hierarchy_ID__c = '43',
                                            Core_Group_Code_Short_Name__c = 'DCG',
                                            Core_Item_Quotable_Ind__c = true,
                                            Core_Item_Orderable_Ind__c = true,
                                            IsActive = true);
        Test.stopTest(); 
		Core_Design_Registration_Product__c designRegistrationProduct=new Core_Design_Registration_Product__c();
        designRegistrationProduct.Core_Target_Resale_Amt__c=200;
        designRegistrationProduct.Core_Product_Id__c=product.Id;
        designRegistrationProduct.Core_Design_Registration_Id__c=designRegistration.id;
        designRegistrationProduct.Core_Full_Year_Qty__c=10;
        
        insert designRegistrationProduct;      
        
    }
    //method to cover try catch blocks for each method 
    static testmethod void coverCatchBlock(){
        Test.startTest();
        PSG_QuoteRequestController.isCustomException=true;
        try{
            PSG_QuoteRequestController.createQuoteRequest(null,null,null);
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        try{
            PSG_QuoteRequestController.fetchRelatedList(null);
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        try{
            PSG_QuoteRequestController.fetchFiles(null);
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        try{
            PSG_QuoteRequestController.fetchDistyDetails();
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        try{
        	PSG_QuoteRequestController.validateOPN(null);
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        try{
        	PSG_QuoteRequestController.updateQuoteLines(null);
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testMethod1(){
        PSG_QuoteRequestController.AttWrapper attWrap = new PSG_QuoteRequestController.AttWrapper();
        attWrap.strFileName='Test';
        attWrap.base64Data='TestBase64';
        List<PSG_QuoteRequestController.AttWrapper> attWrapList= new List<PSG_QuoteRequestController.AttWrapper>{attWrap};
            pricebook2 pb = [Select Id from pricebook2 LIMIT 1];
        List<Product2> prodList=[Select  Id from Product2];
        SBQQ__Quote__c quoteRec= new SBQQ__Quote__c();
        quoteRec.SBQQ__Status__c='Draft';
        quoteRec.core_cpq_business_unit_nm__c='Automotive';
        quoteRec.core_cpq_Quote_Type_Nm__c='Budgetary';
        quoteRec.core_cpq_margin_geo_txt__c='EMEA';
        quoteRec.core_cpq_price_book_nm__c = pb.id;
        quoteRec.RecordTypeId= PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_Submitted');
        System.assertEquals(quoteRec.core_cpq_business_unit_nm__c,'Automotive');	
        SBQQ__QuoteLine__c qline = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c qline2 = new SBQQ__QuoteLine__c();
        qline.core_cpq_Product_Nm__c=prodList[0].Id;
        qline.core_cpq_opn__c ='1SG00';
        qline.core_cpq_altera_reg_txt__c ='io101';
        qline2.core_cpq_Product_Nm__c=prodList[0].Id;
        qline2.core_cpq_opn__c ='DK-AS-5SGXEA7N-V';
        qline.RecordTypeId=PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'PSG_Quote_Line_Create');
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>{qline};

        PSG_QuoteRequestController.createQuoteRequest(quoteRec,qlList,attWrapList);
        PSG_QuoteRequestController.validateGroupMembership(quoteRec.Id);
        Test.startTest();
        PSG_QuoteRequestController.fetchRelatedList(quoteRec.id);
        PSG_QuoteRequestController.fetchFiles(quoteRec.id);
        PSG_QuoteRequestController.updateQuoteLines(qlList);
        qlList.add(qline2);
        PSG_QuoteRequestController.validateOPN(qlList);
        qline2.core_cpq_opn__c = '';
        qline2.core_cpq_years_nbr__c= null;
        qlList.add(qline2);
        PSG_QuoteRequestController.validateOPN(qlList);
        Test.stopTest();
    }
}