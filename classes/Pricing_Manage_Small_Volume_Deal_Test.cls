@isTest
public class Pricing_Manage_Small_Volume_Deal_Test {
    @testSetup
    public static void setUpData() {
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Manage_Small_Volume_Deal_Test');
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuote(acc.Id,con.Id, 2);
            SBQQ__QuoteLine__c quoteLine = Pricing_Test_Utility.createQuoteLineByStatus(quoteList[0].Id, 'Approved');
            
        }
    }   
        
    static testmethod void testgetAccount() {
        Test.startTest();
        Account acc = [Select Id from Account where Name='Test Account' Limit 1];
        Contact con = [Select Id from Contact where AccountId =: acc.Id Limit 1 ];
        User user = [SELECT Id from User where ContactId =:con.Id];
        Pricing_QuoteProgram_CAPSize__c capSizeRecord = new Pricing_QuoteProgram_CAPSize__c();
        capSizeRecord.Pricing_Account_Id__c = acc.Id;
        capSizeRecord.Name = 'Dell';
        capSizeRecord.Pricing_Active_cb__c = true;
        capSizeRecord.Pricing_Small_Deal_CAP_size_Number__c = 24;
        insert capSizeRecord;
        //List<User> partnerUser = Pricing_Test_Utility.createExternalUser();
        System.runAs(user) {
            Id accId = Pricing_Manage_Small_Volume_Deal.getAccount(user.Id);
            Boolean isChecked = Pricing_Manage_Small_Volume_Deal.isRecordTypeSelectionAllowed(acc.Id);
            String capSize;
            capSize = Pricing_Manage_Small_Volume_Deal.capSizeCheck(acc.Id);
            capSizeRecord.Pricing_Active_cb__c = false;
            update capSizeRecord;
            capSize = Pricing_Manage_Small_Volume_Deal.capSizeCheck(acc.Id);
            
            
        } 
        Test.stopTest();
    }
    
    static testmethod void testGetQuoteTypes1() {
        Test.startTest();
        Account acc = [Select Id from Account where Name='Test Account' Limit 1];
        Contact con = [Select Id from Contact where AccountId =: acc.Id Limit 1 ];
        User user = [SELECT Id from User where ContactId =:con.Id];
        Pricing_Systematic_Tender_Limitation__c capSizeRecord = new Pricing_Systematic_Tender_Limitation__c();
        capSizeRecord.Pricing_Account__c = acc.Id;
        //capSizeRecord.Name = 'Dell';
        capSizeRecord.Pricing_Quote_Type__c = 'Client';
        capSizeRecord.Pricing_Active_cb__c = true;
        capSizeRecord.Pricing_Exception_Quota__c = 24;
        insert capSizeRecord;
        System.runAs(user) {
            String quoteTypeJSON='[{"label":"'+Label.Pricing_Tender_Standard_Quote+'","value":"'+Label.Pricing_Tender_Standard_Quote+'"},{"label":"'+Label.Pricing_Tender_Small_Volume_Quote+'","value":"'+Label.Pricing_Tender_Small_Volume_Quote+'"},{"label":"SSD","value":"SSD"},{"label":"PMem","value":"PMem"},{"label":"'+Label.Pricing_Tender_CCG_Quote+'","value":"'+Label.Pricing_Tender_CCG_Quote+'"}]';
            List<Pricing_Manage_Small_Volume_Deal.QuoteTypeWrapper> quoteTypeObjList = Pricing_Manage_Small_Volume_Deal.getQuoteTypes(quoteTypeJSON,acc.Id);
        }
        Test.stopTest();
    }
     
    static testmethod void testGetQuoteTypes2() {
        Test.startTest();
        Account acc = [Select Id from Account where Name='Test Account' Limit 1];
        Contact con = [Select Id from Contact where AccountId =: acc.Id Limit 1 ];
        User user = [SELECT Id from User where ContactId =:con.Id];
        Pricing_QuoteProgram_CAPSize__c capSizeRecord = new Pricing_QuoteProgram_CAPSize__c();
        capSizeRecord.Pricing_Account_Id__c = acc.Id;
        capSizeRecord.Name = 'Dell';
        capSizeRecord.Pricing_Active_cb__c = true;
        capSizeRecord.Pricing_Small_Deal_CAP_size_Number__c = 3;
        insert capSizeRecord;
        System.runAs(user) {
            Pricing_Manage_Small_Volume_Deal.isTestRunning = true;
            String quoteTypeJSON='[{"label":"'+Label.Pricing_Tender_Standard_Quote+'","value":"'+Label.Pricing_Tender_Standard_Quote+'"},{"label":"'+Label.Pricing_Tender_Small_Volume_Quote+'","value":"'+Label.Pricing_Tender_Small_Volume_Quote+'"},{"label":"SSD","value":"SSD"},{"label":"PMem","value":"PMem"}]';
            List<Pricing_Manage_Small_Volume_Deal.QuoteTypeWrapper> quoteTypeObjList = Pricing_Manage_Small_Volume_Deal.getQuoteTypes(quoteTypeJSON,acc.Id);
        	Pricing_Manage_Small_Volume_Deal.isTestRunning = false;
        }
        Test.stopTest();
    }
        
    static testmethod void testGetQuoteTypes3() {
        Test.startTest();
        boolean isGetSVDSwitch = Pricing_Manage_Small_Volume_Deal.getSVDQuoteActiveStatus();
        Account acc = [Select Id from Account where Name='Test Account' Limit 1];
        Contact con = [Select Id from Contact where AccountId =: acc.Id Limit 1 ];
        User user = [SELECT Id from User where ContactId =:con.Id];
        
        User salesRep = [SELECT Id from User where Email = 'FirstName@intel.com' limit 1];
        AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                          TeamMemberRole = 'Technical Sales',UserId = salesRep.Id);
        insert accTeam;   
        Pricing_UnifiedEndCustomerAccountMapping__c writeInEndCustomer = Pricing_Test_Utility.createWriteInEndCustomer();        
         Id quoteCreateRecordId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Small_Volume_Quote_Create);
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__PrimaryContact__c = con.Id;
        quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
        quote.Pricing_Project_Name_Nm__c = 'Test Project';
        quote.RecordTypeId=quoteCreateRecordId;//Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
        quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'FirstName@intel.com';
        quote.Pricing_End_Customer__c = writeInEndCustomer.Id;
        quote.Pricing_Customer_Nm__c = 'Test End Customer';
        quote.Pricing_ShipmentStDate_Dt__c = system.today();
        quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
        quote.Pricing_Intel_Response_Requested_By_Date__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
        quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
        quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
        quote.Pricing_Region_Nm__c = 'APJ';
        quote.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;  
        if(isGetSVDSwitch == false){
            //insert quote;
        }
        
        Pricing_QuoteProgram_CAPSize__c capSizeRecord = new Pricing_QuoteProgram_CAPSize__c();
        capSizeRecord.Pricing_Account_Id__c = acc.Id;
        capSizeRecord.Name = 'Dell';
        capSizeRecord.Pricing_Active_cb__c = true;
        capSizeRecord.Pricing_Small_Deal_CAP_size_Number__c = 0;
        insert capSizeRecord;
        System.runAs(user) {  
            Pricing_Manage_Small_Volume_Deal.isTestRunning = true;
            String quoteTypeJSON='[{"label":"'+Label.Pricing_Tender_Standard_Quote+'","value":"'+Label.Pricing_Tender_Standard_Quote+'"},{"label":"'+Label.Pricing_Tender_Small_Volume_Quote+'","value":"'+Label.Pricing_Tender_Small_Volume_Quote+'"},{"label":"SSD","value":"SSD"},{"label":"PMem","value":"PMem"}]';
            List<Pricing_Manage_Small_Volume_Deal.QuoteTypeWrapper> quoteTypeObjList = Pricing_Manage_Small_Volume_Deal.getQuoteTypes(quoteTypeJSON,acc.Id);
       		Pricing_Manage_Small_Volume_Deal.isTestRunning = false;
        }
        Test.stopTest();
    }
    
    static testmethod void testgetClient() {
        Test.startTest();
        Account acc = [Select Id from Account where Name='Test Account' Limit 1];
        Contact con = [Select Id from Contact where AccountId =: acc.Id Limit 1 ];
        User user = [SELECT Id from User where ContactId =:con.Id];
        SBQQ__Quote__c quote = [SELECT Id,SBQQ__Account__c,Pricing_Volume_Exception_Quota_Cb__c,SBQQ__Status__c,Pricing_Overall_Quote_Quantity_CPU__c,Pricing_Program_Type_Nm__c from SBQQ__Quote__c limit 1];
        SBQQ__QuoteLine__c ql =  [SELECT Id from SBQQ__QuoteLine__c LIMIT 1];
        Pricing_Systematic_Tender_Limitation__c capSizeRecord = new Pricing_Systematic_Tender_Limitation__c();
        capSizeRecord.Pricing_Account__c = acc.Id;
        //capSizeRecord.Name = 'Dell';
        capSizeRecord.Pricing_Quote_Type__c = 'Client';
        capSizeRecord.Pricing_Active_cb__c = true;
        capSizeRecord.Pricing_Exception_Quota__c = 24;
        insert capSizeRecord;
        //List<User> partnerUser = Pricing_Test_Utility.createExternalUser();
        //System.runAs(user) {
            Id accId = Pricing_Manage_Small_Volume_Deal.getAccount(user.Id);
            Map<String,Boolean> isCheckedRecord = Pricing_Manage_Small_Volume_Deal.isRecordTypeSelectionAllow(acc.Id);
            String capSize;
            Map<String,String> capSizeCheck = new Map<String,String>();
            capSizeCheck = Pricing_Manage_Small_Volume_Deal.capSizeCheckToCreation(new Set<String>{acc.Id}, false);
            capSizeRecord.Pricing_Active_cb__c = false;
            update capSizeRecord;
            capSizeCheck = Pricing_Manage_Small_Volume_Deal.capSizeCheckToCreation(new Set<String>{acc.Id}, false);
            
            
        //} 
        Test.stopTest();
    }
    static testmethod void testgetDataCenter() {
        Test.startTest();
        Account acc = [Select Id from Account where Name='Test Account' Limit 1];
        Contact con = [Select Id from Contact where AccountId =: acc.Id Limit 1 ];
        User user = [SELECT Id from User where ContactId =:con.Id];
        SBQQ__Quote__c quote = [SELECT Id,SBQQ__Account__c,Pricing_Volume_Exception_Quota_Cb__c,SBQQ__Status__c,Pricing_Overall_Quote_Quantity_CPU__c,Pricing_Program_Type_Nm__c from SBQQ__Quote__c limit 1];
        SBQQ__QuoteLine__c ql =  [SELECT Id from SBQQ__QuoteLine__c LIMIT 1];
        Pricing_Systematic_Tender_Limitation__c capSizeRecord = new Pricing_Systematic_Tender_Limitation__c();
        capSizeRecord.Pricing_Account__c = acc.Id;
        //capSizeRecord.Name = 'Dell';
        capSizeRecord.Pricing_Quote_Type__c = 'Data Center';
        capSizeRecord.Pricing_Active_cb__c = true;
        capSizeRecord.Pricing_Exception_Quota__c = 24;
        insert capSizeRecord;
        //List<User> partnerUser = Pricing_Test_Utility.createExternalUser();
        //System.runAs(user) {
            Id accId = Pricing_Manage_Small_Volume_Deal.getAccount(user.Id);
            Map<String,Boolean> isCheckedRecord = Pricing_Manage_Small_Volume_Deal.isRecordTypeSelectionAllow(acc.Id);
            String capSize;
            Map<String,String> capSizeCheck = new Map<String,String>();
            capSizeCheck = Pricing_Manage_Small_Volume_Deal.capSizeCheckToCreation(new Set<String>{acc.Id}, false);
            capSizeRecord.Pricing_Active_cb__c = false;
            update capSizeRecord;
            capSizeCheck = Pricing_Manage_Small_Volume_Deal.capSizeCheckToCreation(new Set<String>{acc.Id}, false);
            
            
        //} 
        Test.stopTest();
    }
      
    static testmethod void testGetQuoteTypes4() {
        Test.startTest();
        Account acc = [Select Id from Account where Name='Test Account' Limit 1];
        Contact con = [Select Id from Contact where AccountId =: acc.Id Limit 1 ];
        User user = [SELECT Id from User where ContactId =:con.Id];
        Pricing_Systematic_Tender_Limitation__c capSizeRecord = new Pricing_Systematic_Tender_Limitation__c();
        capSizeRecord.Pricing_Account__c = acc.Id;
        //capSizeRecord.Name = 'Dell';
        capSizeRecord.Pricing_Quote_Type__c = 'Data Center';
        capSizeRecord.Pricing_Active_cb__c = true;
        capSizeRecord.Pricing_Exception_Quota__c = 24;
        insert capSizeRecord;
        System.runAs(user) {
            String quoteTypeJSON='[{"label":"'+Label.Pricing_Tender_Standard_Quote+'","value":"'+Label.Pricing_Tender_Standard_Quote+'"},{"label":"'+Label.Pricing_Tender_Small_Volume_Quote+'","value":"'+Label.Pricing_Tender_Small_Volume_Quote+'"},{"label":"SSD","value":"SSD"},{"label":"PMem","value":"PMem"}]';
            List<Pricing_Manage_Small_Volume_Deal.QuoteTypeWrapper> quoteTypeObjList = Pricing_Manage_Small_Volume_Deal.getQuoteTypes(quoteTypeJSON,acc.Id);
        }
        Test.stopTest();
    }
     static testmethod void testGetQuoteTypes5() {
        Test.startTest();
        Account acc = [Select Id from Account where Name='Test Account' Limit 1];
        Contact con = [Select Id from Contact where AccountId =: acc.Id Limit 1 ];
        User user = [SELECT Id from User where ContactId =:con.Id];
        Pricing_QuoteProgram_CAPSize__c capSizeRecord = new Pricing_QuoteProgram_CAPSize__c();
        capSizeRecord.Pricing_Account_Id__c = acc.Id;
        capSizeRecord.Name = 'Dell';
       // capSizeRecord.Pricing_Quote_Type__c =  Label.Pricing_Tender_CCG_Quote;
        capSizeRecord.Pricing_Active_cb__c = true;
        capSizeRecord.Pricing_Small_Deal_CAP_size_Number__c = 3;
        insert capSizeRecord;
        System.runAs(user) {
            String quoteTypeJSON='[{"label":"'+Label.Pricing_Tender_Standard_Quote+'","value":"'+Label.Pricing_Tender_Standard_Quote+'"},{"label":"'+Label.Pricing_Tender_Small_Volume_Quote+'","value":"'+Label.Pricing_Tender_Small_Volume_Quote+'"},{"label":"SSD","value":"SSD"},{"label":"PMem","value":"PMem"}]';
            List<Pricing_Manage_Small_Volume_Deal.QuoteTypeWrapper> quoteTypeObjList = Pricing_Manage_Small_Volume_Deal.getQuoteTypes(quoteTypeJSON,acc.Id);
        }
        Test.stopTest();
    }
}