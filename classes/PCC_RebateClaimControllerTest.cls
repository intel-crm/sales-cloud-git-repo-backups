@isTest
private class PCC_RebateClaimControllerTest {
    
    @testSetup static void setup() {
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        
        system.runas(sysadm){
            
            List<account>  lstAcc = Core_Test_Utility.createAccount(1);
            lstAcc[0].Name='Test Test';
            lstAcc[0].recordTypeId = accountRecordTypeIntel;
            lstAcc[0].Core_Business_Party_Id__c='1223';
            insert lstAcc;
            
            Contact c1 = PRM_TestUtility.getContact();
            c1.AccountId = LstAcc[0].Id;
            c1.Email='test.user@intel.com';
            c1.Core_Preferred_Language__c = 'ENG';
            c1.Core_eRPM_Language_Code__c = 'ENG';
            c1.RecordTypeId = contactRecordType;
            c1.Core_IPA_Partner_Role__c = 'Service Provider';
            c1.Email = 'test.test@test.com';
            c1.Core_Central_Block__c=false;
            insert c1;
            
            Profile profile1 = [Select Id from Profile where name = 'Partner'];
            
            User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='test.test@intel.com',
                                     EmailEncodingKey='UTF-8',LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMPM.com',
                                     FirstName='TestUtility', ContactId = c1.id, ProfileId = profile1.Id);
            insert testUser;
            
            
            Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
            ee.Name = 'Intel Partner Alliance';
            ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
            ee.Core_Engagement_Type__c = 'SEC';
            insert ee;
            
            Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
            ed1.Name='Partner Portal- Deal Reg';
            ed1.Core_Display_Name__c='Partner Portal- Deal Reg';
            ed1.Core_ERPM_Engagement_Id__c=ee.id;
            insert ed1;
            
            
            Core_Contact_Entitlement__c cce1=new Core_Contact_Entitlement__c(); // Contact Entitlement
            cce1.Core_Contact_Id__c=c1.Id;
            cce1.Core_Entitlement_Id__c = ed1.id;
            cce1.Core_Status__c='Complete';
            cce1.Core_Selected__c = true;
            cce1.Core_Source__c = 'Entitlement';
            insert cce1;            
        }
      
    }
    
    @isTest
    static void testGetPartnerAccounts() {
        Test.startTest();
        List<Map<String,String>> listofMapofAccounts= PCC_RebateClaimController.getPartnerAccounts();
        Test.stopTest();
        System.assertNotEquals(listofMapofAccounts.size(),0,'size should not be zero');
    }
    
    @isTest
    static void testGetFieldSetLabels() {
        Test.startTest();
        Map<String,List<String>> fieldMap = PCC_RebateClaimController.getFieldSetLabels();
        Test.stopTest();
        System.assertNotEquals(fieldMap.size(),0,'size should not be zero');
    }
    
    @isTest
    static void testGetProcessedRCRecords() {
        User us= [Select Id FROM User WHERE Email='test.test@intel.com' LIMIT 1];
        System.runas(us){
            List<Account> acc = [SELECT Id FROM Account WHERE Name='TEST TEST' LIMIT 1];
            Id recTypeParentId = Schema.SObjectType.PCC_Rebate_Claim_Stage__c.getRecordTypeInfosByDeveloperName().get('Header').getRecordTypeId();
            Id recTypeChildId = Schema.SObjectType.PCC_Rebate_Claim_Stage__c.getRecordTypeInfosByDeveloperName().get('Line_Items').getRecordTypeId();
            
            PCC_Rebate_Claim_Stage__c headerRecord = new PCC_Rebate_Claim_Stage__c();
            headerRecord.PCC_Partner__c = acc[0].Id;
            headerRecord.recordTypeId = recTypeParentId;
            insert headerRecord;
            PCC_Rebate_Claim_Stage__c stageRec = new PCC_Rebate_Claim_Stage__c(
                PCC_Parent_Record__c = headerRecord.Id,
                PCC_Quote_Line_Number__c='Q-16045-027-1',
                PCC_Country__c='USA',
                PCC_Invoice_Date__c=String.valueof(Date.today()),
                PCC_Status__c='Pending',
                PCC_Product__c = 'Intel® Core™ i7-4930K Processor (12M Cache, up to 3.90 GHz)',
                PCC_Quantity__c = String.valueof(10),
                recordTypeId = recTypeChildId,
                PCC_Partner__c = acc[0].Id
            );
            insert stageRec;
            Test.startTest();
            PCC_RebateClaimController.RebateClaimWrapper rcw = PCC_RebateClaimController.getProcessedRCRecords(headerRecord.Id);
            Test.stopTest();
            System.assertEquals(rcw.rebateClaimList.size(),1,'Size should be 1');
        }
    }
    
    @isTest
    static void testCreateStageRecordsfromCSV() {
        String base64Data='"Quote Line Number,Product Name,Claim Quantity,OEM,Consumption Countries,Invoice Number,Invoice Date\\r\\nQ-15415-007-001,\\"Intel® Core™ i3-7100U Processor (3M Cache, 2.40 GHz)\\",2,Samsung,USA:UK:Canada,I-0171,3/22/2024,Pending,\\r\\n"';
        test.startTest();
        PCC_RebateClaimController.ResultWrapper rec = PCC_RebateClaimController.createStageRecordsfromCSV(base64Data,'test.test@test.com' ,'testFile.csv',false);  
        Test.stopTest();
        System.assertEquals(rec.status,'success','Status should be success');
    }
    @isTest
    static void testgetQuoteQuantity() {
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        
        system.runas(sysadm){
           
            List<Account> acc = [SELECT Id FROM Account WHERE Name='TEST TEST' LIMIT 1];
            List<Contact> con = [Select Id from Contact Where accountid=:acc[0].Id LIMIT 1];
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedEndCustomer.name='Write In End Customer';
            insert unifiedEndCustomer;
             
            Id newOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
            List<Opportunity> opptyList = new List<Opportunity>();
             opptyList.add(new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId, Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity', Core_Coverage_Type_Nm__c= 'Deal Registration',Core_Lead_Conversion_Flag__c = false,
                    AccountId = acc[0].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Approval_Status__c= 'Approved', Core_Technical_Owner__c = sysadm.Id, Core_Sales_Group__c='Regional Sales', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='ALDER LAKE D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $',Core_FC_Recall_Count__c=null,OwnerId= UserInfo.getUserId()));         
                    insert opptyList;
        opptyList[0].Core_Status_Update__c = 'Test 13';
        opptyList[0].StageName= 'Design Win';
               update opptyList[0];     
              
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = acc[0].Id;
            quote.SBQQ__PrimaryContact__c = con[0].Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote.Pricing_Customer_Nm__c = 'FMH';
            quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';
            quote.SBQQ__Status__c = 'Submitted';
            quote.SBQQ__Opportunity2__c = opptyList[0].Id;
            quoteList.add(quote);
            insert quoteList;  
            Id quoteLineCreateRecordId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Tender_QuoteLine_RecordType_Create);
            Product2 prod = new Product2(Name='TestProduct',
            Core_Product_Org__c = 'Sales',
            Core_Product_Type__c = 'Processors',
            Core_Sales_Visible_Flag__c = true,
            Core_Hierarchy_ID__c = '43',
            Core_Group_Code_Short_Name__c = 'DCG~DCAI',
            Core_Processor_Number_Nm__c = 'P6500',
            IsActive = true);
            insert prod;
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId=quoteLineCreateRecordId;//Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLine.Pricing_Product_Nm__c = prod.Id;
            quoteLine.SBQQ__Product__c = prod.Id;
            quoteLine.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLine.Pricing_Systems_qty__c = 6; 
            quoteLine.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLine.Pricing_CPUs_per_system_qty__c = 1;
            quoteLine.Pricing_Single_System_Price_Amt__c = 4;
            quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLine.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLine.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLine.Pricing_Other_Competitor_Product_Nm__c = 'Test Tender Prod';
            quoteLine.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Non_Embedded;
            quoteLine.Pricing_Market_Segment_values_Nm__c ='';
            quoteLine.SBQQ__Quote__c = quoteList[0].Id;
            quoteLine.Pricing_Deal_RFQ_Id__c = '23421';
            quoteLine.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
            quoteLine.Pricing_Status_Nm__c =system.label.Quote_Pricing_Status;
            quoteLine.Pricing_Consumption_Platform__c = 'Test platform 1,test platform 2';
            quoteLine.Pricing_Consumption_Region__c = 'ASMO';
            quoteLine.Pricing_Quote_Line_Number__c='Q-100-11-test';
            quoteLine.Pricing_Status_Nm__c='Won';
            quoteLine.Pricing_Approved_Start_Date_Dt__c= System.today().addDays(-30);
            quoteLine.Pricing_Approved_End_Date_Dt__c =System.today();
            quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c = System.today().addDays(-30);
            quoteLine.Pricing_Approved_End_Date_Dup_Dt__c = System.today();
            quoteLine.Pricing_Approved_Unit_Dup_Qty__c=100;
            insert quoteLine;
           
           
            PCC_Rebate_Claim__c rcInstance = new PCC_Rebate_Claim__c();
            rcInstance.PCC_Claim_Status__c = 'Draft'; 
            insert rcInstance; 
            PCC_Rebate_Claim_Line_Item__c rc_line = new PCC_Rebate_Claim_Line_Item__c();
            rc_line.PCC_Rebate_Claim__c = rcInstance.Id;
            rc_line.PCC_Quote_Line_Number__c =  quoteLine.Id;   
            rc_line.PCC_Quantity__c= 1;
            rc_line.PCC_Invoice__c= '2000'; 
            rc_line.PCC_OEM_Name__c = 'DELL';
            rc_line.PCC_Status__c = 'Submitted';
            rc_line.PCC_Invoice_Date__c = System.today();
            rc_line.PCC_Claimed_Rebate_Amount__c = 50000;
            insert rc_line;
          
            
            List<String> lstQuote= new List<String>();
            lstQuote.add('Q-100-11-test');
            lstQuote.add('Q-test');
            test.startTest();
            List<PCC_RebateClaimController.QuantityResult>  listQR = PCC_RebateClaimController.getQuoteQuantity(lstQuote);
            PCC_RebateClaimController.getQLswithoutRebate();  
            test.stopTest();
            System.assertEquals(listQR.size(),1,'Size should be 1');
        }
    }
    @isTest
    static void testGetConfigShowMarquee() {
        Test.startTest();
        PCC_RebateClaimController.QLWrapper result = PCC_RebateClaimController.getConfigShowMarquee();
        Test.stopTest();

        // Assert the results
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    @isTest
    static void testgetQLswithoutRebate() {
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        
        system.runas(sysadm){
           
            List<Account> acc = [SELECT Id FROM Account WHERE Name='TEST TEST' LIMIT 1];
            List<Contact> con = [Select Id from Contact Where accountid=:acc[0].Id LIMIT 1];
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedEndCustomer.name='Write In End Customer';
            insert unifiedEndCustomer;
             
            Id newOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
            List<Opportunity> opptyList = new List<Opportunity>();
             opptyList.add(new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId, Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity', Core_Coverage_Type_Nm__c= 'Deal Registration',Core_Lead_Conversion_Flag__c = false,
                    AccountId = acc[0].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Approval_Status__c= 'Approved', Core_Technical_Owner__c = sysadm.Id, Core_Sales_Group__c='Regional Sales', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='ALDER LAKE D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $',Core_FC_Recall_Count__c=null,OwnerId= UserInfo.getUserId()));         
                    insert opptyList;
        opptyList[0].Core_Status_Update__c = 'Test 13';
        opptyList[0].StageName= 'Design Win';
               update opptyList[0];     
              
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = acc[0].Id;
            quote.SBQQ__PrimaryContact__c = con[0].Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote.Pricing_Customer_Nm__c = 'FMH';
            quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';
            quote.SBQQ__Status__c = 'Submitted';
            quote.SBQQ__Opportunity2__c = opptyList[0].Id;
            quoteList.add(quote);
            insert quoteList;  
            Id quoteLineCreateRecordId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Tender_QuoteLine_RecordType_Create);
            Product2 prod = new Product2(Name='TestProduct',
            Core_Product_Org__c = 'Sales',
            Core_Product_Type__c = 'Processors',
            Core_Sales_Visible_Flag__c = true,
            Core_Hierarchy_ID__c = '43',
            Core_Group_Code_Short_Name__c = 'DCG~DCAI',
            Core_Processor_Number_Nm__c = 'P6500',
            IsActive = true);
            insert prod;
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId=quoteLineCreateRecordId;//Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLine.Pricing_Product_Nm__c = prod.Id;
            quoteLine.SBQQ__Product__c = prod.Id;
            quoteLine.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLine.Pricing_Systems_qty__c = 6; 
            quoteLine.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLine.Pricing_CPUs_per_system_qty__c = 1;
            quoteLine.Pricing_Single_System_Price_Amt__c = 4;
            quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLine.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLine.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLine.Pricing_Other_Competitor_Product_Nm__c = 'Test Tender Prod';
            quoteLine.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Non_Embedded;
            quoteLine.Pricing_Market_Segment_values_Nm__c ='';
            quoteLine.SBQQ__Quote__c = quoteList[0].Id;
            quoteLine.Pricing_Deal_RFQ_Id__c = '23421';
            quoteLine.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
            quoteLine.Pricing_Status_Nm__c =system.label.Quote_Pricing_Status;
            quoteLine.Pricing_Consumption_Platform__c = 'Test platform 1,test platform 2';
            quoteLine.Pricing_Consumption_Region__c = 'ASMO';
            quoteLine.Pricing_Quote_Line_Number__c='Q-100-11-test';
            quoteLine.Pricing_Status_Nm__c='Won';
            quoteLine.Pricing_Approved_Start_Date_Dt__c= System.today().addDays(-30);
            quoteLine.Pricing_Approved_End_Date_Dt__c =System.today();
            quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c = System.today().addDays(-30);
            quoteLine.Pricing_Approved_End_Date_Dup_Dt__c = System.today();
            quoteLine.Pricing_Approved_Unit_Dup_Qty__c=100;
            insert quoteLine;
           
           
            PCC_Rebate_Claim__c rcInstance = new PCC_Rebate_Claim__c();
            rcInstance.PCC_Claim_Status__c = 'Draft'; 
            insert rcInstance; 
            PCC_Rebate_Claim_Line_Item__c rc_line = new PCC_Rebate_Claim_Line_Item__c();
            rc_line.PCC_Rebate_Claim__c = rcInstance.Id;
            rc_line.PCC_Quote_Line_Number__c =  quoteLine.Id;   
            rc_line.PCC_Quantity__c= 1;
            rc_line.PCC_Invoice__c= '2000'; 
            rc_line.PCC_OEM_Name__c = 'DELL';
            rc_line.PCC_Status__c = 'Submitted';
            rc_line.PCC_Invoice_Date__c = System.today();
            rc_line.PCC_Claimed_Rebate_Amount__c = 50000;
            insert rc_line;
            
            test.startTest();
            List<PCC_RebateClaimController.QLsResult> listQR =  PCC_RebateClaimController.getQLswithoutRebate();  
            test.stopTest();
            System.assertEquals(listQR.size(),1,'Size should be 1');
        }
    }
    @isTest
    static void testIsQLonRCVisible() {
        Test.startTest();
        Boolean result = PCC_RebateClaimController.isQLonRCVisible();
        Test.stopTest();
        // Assert the results
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
     @isTest
    static void testgetQuoteLineItems() {
         user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        
        system.runas(sysadm){
           
            List<Account> acc = [SELECT Id FROM Account WHERE Name='TEST TEST' LIMIT 1];
            List<Contact> con = [Select Id from Contact Where accountid=:acc[0].Id LIMIT 1];
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedEndCustomer.name='Write In End Customer';
            insert unifiedEndCustomer;
             
            Id newOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
            List<Opportunity> opptyList = new List<Opportunity>();
             opptyList.add(new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId, Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity', Core_Coverage_Type_Nm__c= 'Deal Registration',Core_Lead_Conversion_Flag__c = false,
                    AccountId = acc[0].Id, StageName = 'Qualify',Core_Approval_Status__c= 'Approved', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysadm.Id, Core_Sales_Group__c='Regional Sales', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='ALDER LAKE D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $',Core_FC_Recall_Count__c=null,OwnerId= UserInfo.getUserId()));         
                    insert opptyList;
                   
        //update opps;
        opptyList[0].Core_Status_Update__c = 'Test 13';
        opptyList[0].StageName= 'Design Win';
               update opptyList[0];             
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = acc[0].Id;
            quote.SBQQ__PrimaryContact__c = con[0].Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote.Pricing_Customer_Nm__c = 'FMH';
            quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';
            quote.SBQQ__Status__c = 'Submitted';
            quote.SBQQ__Opportunity2__c = opptyList[0].Id;
            quoteList.add(quote);
            insert quoteList;  
            Id quoteLineCreateRecordId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Tender_QuoteLine_RecordType_Create);
            Product2 prod = new Product2(Name='TestProduct',
            Core_Product_Org__c = 'Sales',
            Core_Product_Type__c = 'Processors',
            Core_Sales_Visible_Flag__c = true,
            Core_Hierarchy_ID__c = '43',
            Core_Group_Code_Short_Name__c = 'DCG~DCAI',
            Core_Processor_Number_Nm__c = 'P6500',
            IsActive = true);
            insert prod;
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId=quoteLineCreateRecordId;//Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLine.Pricing_Product_Nm__c = prod.Id;
            quoteLine.SBQQ__Product__c = prod.Id;
            quoteLine.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLine.Pricing_Systems_qty__c = 6; 
            quoteLine.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLine.Pricing_CPUs_per_system_qty__c = 1;
            quoteLine.Pricing_Single_System_Price_Amt__c = 4;
            quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLine.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLine.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLine.Pricing_Other_Competitor_Product_Nm__c = 'Test Tender Prod';
            quoteLine.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Non_Embedded;
            quoteLine.Pricing_Market_Segment_values_Nm__c ='';
            quoteLine.SBQQ__Quote__c = quoteList[0].Id;
            quoteLine.Pricing_Deal_RFQ_Id__c = '23421';
            quoteLine.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
            quoteLine.Pricing_Status_Nm__c =system.label.Quote_Pricing_Status;
            quoteLine.Pricing_Consumption_Platform__c = 'Test platform 1,test platform 2';
            quoteLine.Pricing_Consumption_Region__c = 'ASMO';
            quoteLine.Pricing_Quote_Line_Number__c='Q-100-11-test';
            quoteLine.Pricing_Status_Nm__c='Won';
            quoteLine.Pricing_Approved_Start_Date_Dt__c= System.today().addDays(-30);
            quoteLine.Pricing_Approved_End_Date_Dt__c =System.today().addDays(30);
            quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c = System.today().addDays(-30);
            quoteLine.Pricing_Approved_End_Date_Dup_Dt__c = System.today().addDays(30);
            insert quoteLine;
            
            PCC_Rebate_Claim__c rcInstance = new PCC_Rebate_Claim__c();
            rcInstance.PCC_Claim_Status__c = 'Submitted'; 
            insert rcInstance; 
            PCC_Rebate_Claim_Line_Item__c rc_line = new PCC_Rebate_Claim_Line_Item__c();
            rc_line.PCC_Rebate_Claim__c = rcInstance.Id;
            rc_line.PCC_Quote_Line_Number__c =  quoteLine.Id;   
            rc_line.PCC_Quantity__c= 100;
            rc_line.PCC_Invoice__c= '2000'; 
            rc_line.PCC_OEM_Name__c = 'DELL';
            rc_line.PCC_Status__c = 'Submitted';
            rc_line.PCC_Invoice_Date__c = System.today();
            rc_line.PCC_Claimed_Rebate_Amount__c = 50000;
            insert rc_line;
            
        Test.startTest();
        PCC_RebateClaimController.QWrapper result = PCC_RebateClaimController.getQuoteLineItems();
        Test.stopTest();
        System.assertEquals(1, result.qlList.size(), 'size is 1');
    }
    }
    @isTest
    static void testCreateStageRecordsfromCSVForFailure() {
        String base64Data='"Quote Line Number,Product Name,Claim Quantity,OEM,Consumption Countries,Invoice Number,Invoice Date\\r\\nQ-15415-007-001,\\"Intel® Core™ i3-7100U Processor (3M Cache, 2.40 GHz)\\",278966623,Samsung,USA:UK:Canada,I-0171,3/22/2024 67,Pending,\\r\\n"';
        String base64Data1='"Quote Line Number,Product Name,Claim Quantity,OEM,Consumption Countries,Invoice Number,Invoice Date\\r\\nQ-15415-007-001testtesttest,\\"Intel® Core™ i3-7100U Processor (3M Cache, 2.40 GHz)test test\\",278966623,SamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsungSamsung, ,I-0171, ,Pending,\\r\\n"';
        String base64Data2='"Quote Line Number,Product Name,Claim Quantity,OEM,Consumption Countries,Invoice Number,Invoice Date\\r\\n,\\"\\", ,,USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada:USA:UK:Canada, , ,Pending,\\r\\n"';
        test.startTest();
        PCC_RebateClaimController.ResultWrapper rec = PCC_RebateClaimController.createStageRecordsfromCSV(base64Data,'test.test@test.com' ,'testFile.csv',false);  
     // PCC_RebateClaimController.ResultWrapper rec1 = PCC_RebateClaimController.createStageRecordsfromCSV(base64Data1,'test.test@test.com' ,'testFile.csv',false);  
     // PCC_RebateClaimController.ResultWrapper rec2 = PCC_RebateClaimController.createStageRecordsfromCSV(base64Data2,'test.test@test.com' ,'testFile.csv',false);  
        Test.stopTest();
        System.assertEquals(rec.status,'success','Status should be success');
    }
}