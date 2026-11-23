/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
* @last modified on  : 06-10-2025
* @last modified by  : Deepthi Kambam
**/
@isTest
public without sharing class Pricing_Test_Utility {
    Public static PermissionSet permissionRec;
    Static{
        permissionRec = [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User Limit 1];
    }
    //Method to create an Account record
    public static Account createAccount(){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        acc.Name = 'Test Account';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = 'Banking';
        acc.BillingCity = 'Texas';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'G-210';
        acc.Core_Sales_Groups__c = 'Americas Partner Led';
        insert acc;
        return acc;
    }
    
    public static Opportunity createOpportunity(){
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' Limit 1];
        Id newOppRecTypeId = [select Id,DeveloperName from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opps = new Opportunity(Name = 'test opp', Core_Product_Application__c ='Business Mobility', Core_Opportunity_Type__c='Deal: Sell-to',
            RecordTypeId = newOppRecTypeId, AccountId = acct.Id, Opportunity_Focus__c='Growth',Core_Product_Segment__c='Client Computing', 
            Core_Consumption_Market__c = 'Education', Description = 'test', Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity', StageName = 'Qualify',
            CloseDate = System.Today().addDays(24), Desired_End_State__c='Test OppName',Technology_and_Readiness_Gaps__c='Design',Business_Need__c='Yes',
            Technical_Need__c ='Approved');
        return opps;
    }
    
    // This method creates Account Team Members and Account Share Settings
    Public static List<AccountTeamMember> createAccountTeamMember(Id accId, Id userId){
        List<AccountTeamMember> lstAccountTeamMember = new List<AccountTeamMember>();
        AccountShare accShare = new AccountShare(AccountId = accId, AccountAccessLevel ='Edit', OpportunityAccessLevel ='Edit',
                                                 CaseAccessLevel='Edit', UserOrGroupId = userId);
        insert accShare;        
        AccountTeamMember accountTeamMember = new AccountTeamMember(AccountId = accId, TeamMemberRole = 'Team Member (100%)',
                                                                    AccountAccessLevel ='Edit', OpportunityAccessLevel ='Edit',
                                                                    CaseAccessLevel='Edit', UserId = userId);
        lstAccountTeamMember.add(accountTeamMember);        
        
        insert lstAccountTeamMember;
        return lstAccountTeamMember;
    }
    
    //This method create a Contact record
    public static Contact createContact(Id accId){
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'FirstName';
        con.LastName = 'LastName';
        con.Email = 'FirstName@intel.com';
        con.AccountId = accId;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry = 'India';
        insert con;
        return con;
    }
    
    //This method creates list of contacts
    public static List<Contact> createTestContact(Id accId , Integer count){
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<count;i++){
            Contact con = new Contact();
            con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);     
            con.FirstName = 'FirstName';
            con.LastName = 'LastName '+i;
            con.Email = 'FirstName'+i+'@intel.com';
            con.AccountId = accId;
            con.MailingCountry = 'India';
            conList.add(con);
        }
        insert conList;
        return conList;
    }
    
    public static PriceBook2 createPriceBook(){
        PriceBook2 p = new PriceBook2(
            name = 'DCG Price Book',
            isActive=true
        );
        insert p;
        return p;
    }
    
    public static Pricing_UnifiedEndCustomerAccountMapping__c createUnifiedEndCustomer(Id accId){
        Pricing_UnifiedEndCustomerAccountMapping__c uniEndCustomerL1 = new Pricing_UnifiedEndCustomerAccountMapping__c();
        uniEndCustomerL1.Name = 'End Customer 1';
        uniEndCustomerL1.Pricing_Active_cb__c = true;
        uniEndCustomerL1.Pricing_Account_Nm__c = accId;
        uniEndCustomerL1.Pricing_Unified_EndCustomer_Id__c = '1111';
        insert uniEndCustomerL1;
        
        Pricing_UnifiedEndCustomerCountryMapping__c uniEndCustomerL2 = new Pricing_UnifiedEndCustomerCountryMapping__c();
        uniEndCustomerL2.Name = 'End Customer 1';
        uniEndCustomerL2.Pricing_Unified_EndCustomer_Act_Mapping__c = uniEndCustomerL1.Id;
        uniEndCustomerL2.Pricing_Country_Nm__c = 'Afghanistan';
        uniEndCustomerL2.Pricing_Unified_Country_EndCustomer_Id__c = '2222';
        insert uniEndCustomerL2;
        return uniEndCustomerL1;
    }
    
    public static Pricing_UnifiedEndCustomerAccountMapping__c createWriteInEndCustomer(){
        Pricing_UnifiedEndCustomerAccountMapping__c uniEndCustomerL1 = new Pricing_UnifiedEndCustomerAccountMapping__c();
        uniEndCustomerL1.Name = 'Write In End Customer';
        uniEndCustomerL1.Pricing_Active_cb__c = true;
        insert uniEndCustomerL1;
        return uniEndCustomerL1;
    }
    
    //This method creates Quotes by taking Account Id,Contact Id and numer as parameters
    public static List<SBQQ__Quote__c> createQuote(Id accId,Id conId, Integer numberOfQuotes){
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        User salesRep = [SELECT Id from User where Email = 'FirstName@intel.com' limit 1];
        AccountTeamMember accTeam = new AccountTeamMember(AccountId = accId,
                                                          TeamMemberRole = 'Technical Sales',UserId = salesRep.Id);
        insert accTeam;   
        List<User> accExecUserList = Pricing_Test_Utility.createAEUser();
        Pricing_UnifiedEndCustomerAccountMapping__c writeInEndCustomer = createWriteInEndCustomer();        
        
        Id quoteCreateRecordId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
        for(Integer i=0;i<numberOfQuotes;i++){ 
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = accId;
            quote.SBQQ__PrimaryContact__c = conId;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project'+i;
            quote.RecordTypeId=quoteCreateRecordId;//Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'FirstName@intel.com';
            quote.Pricing_End_Customer__c = writeInEndCustomer.Id;
            quote.Pricing_Customer_Nm__c = 'Test End Customer';
            quote.Pricing_ShipmentStDate_Dt__c = system.today();
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = accExecUserList[0].Email;
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_Intel_Response_Requested_By_Date__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(6);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';
            quote.Pricing_Quote_Program_Nm__c = system.label.Pricing_Tender_Quote_Program;           
            quote.Pricing_End_Customer_URL__c = 'www.test.com';
            lstQuote.add(quote);
        }
        insert lstQuote;
        return lstQuote;
    }
    
    //This method creates Quotes by taking Account Id,Contact Id and numer as parameters
    public static List<SBQQ__Quote__c> createQuoteWithParam(Id accId,Id conId, Integer numberOfQuotes, String salesRepEmail, String accountExecutiveEmail){
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();    
        Pricing_UnifiedEndCustomerAccountMapping__c endCustomer = createUnifiedEndCustomer(accId);
        for(Integer i=0;i<numberOfQuotes;i++){ 
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = accId;
            quote.SBQQ__PrimaryContact__c = conId;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project'+i;
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = salesRepEmail;
            quote.Pricing_End_Customer__c = endCustomer.Id;
            quote.Pricing_Customer_Nm__c = '';
            quote.Pricing_ShipmentStDate_Dt__c = system.today();
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = accountExecutiveEmail;
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_Intel_Response_Requested_By_Date__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(6);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'India';
            quote.Pricing_Region_Nm__c = 'APJ';      
            quote.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
            quote.SBQQ__Opportunity2__c = createOpportunity().Id;
            quote.Pricing_End_Customer_URL__c = 'www.test.com';
            lstQuote.add(quote);
        }
        insert lstQuote;
        return lstQuote;
    }
    
     public static Pricing_UnifiedEndCustomerAccountMapping__c createL1ObjPartial(Id accId){
        Pricing_UnifiedEndCustomerAccountMapping__c uniEndCustomerL1 = new Pricing_UnifiedEndCustomerAccountMapping__c();
        uniEndCustomerL1.Name = 'End Customer Partial';
        uniEndCustomerL1.Pricing_Active_cb__c = true;
        uniEndCustomerL1.Pricing_Account_Nm__c = accId;
        uniEndCustomerL1.Pricing_Unified_EndCustomer_Id__c = '1456';
        insert uniEndCustomerL1;
        return uniEndCustomerL1;
     }
    
    
    //This method creates product
    //Specifying number as parameter creates number of products
    public static List<Product2> createProduct(Integer numOfProducts){
        List<Product2> product = new List<Product2>();
        
        for(Integer i=0;i<numOfProducts;i++){
            product.add(new Product2(Name = 'Test Product' + i)); 
        }
        
        insert product;
        return product;
    }
    
    public static Product2 createWINProduct(){
        try{
            Product2 product = new Product2(Name = 'Write In Product',
                                            Core_Product_Org__c = 'Sales',
                                            Core_Product_Type__c = 'Processors',
                                            Core_Sales_Visible_Flag__c = true,
                                            Core_Hierarchy_ID__c = '43',
                                            Core_Group_Code_Short_Name__c = 'DCG~DCAI',
                                            IsActive = true); 
            insert product;
            return product;
        }catch(Exception exp){
            return null;
        }
        
    }
    
    //This method creates Quote Lines 
    //Quoted Id and Integer value is provided as parameters
    public static List<SBQQ__QuoteLine__c> createQuoteLines(Id quoteId, Integer numquoteLines){
        List<Product2> products = new List<Product2>();
        for(Integer i=0;i<numquoteLines;i++) {
            Product2 prod = new Product2(Name='TestProduct' + i,
                                         Core_Product_Org__c = 'Sales',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG~DCAI',
                                         Core_Processor_Number_Nm__c = 'P6500',
                                         IsActive = true);
            products.add(prod);
        }
        insert products;
       
        Id quoteLineCreateRecordId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Tender_QuoteLine_RecordType_Create);
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        for(Product2 prod1:products){
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId=quoteLineCreateRecordId;//Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLine.Pricing_Product_Nm__c = prod1.Id;
            quoteLine.SBQQ__Product__c = prod1.Id;
            quoteLine.Pricing_End_Date_dt__c = Date.today().addMonths(12);
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
            quoteLine.SBQQ__Quote__c = quoteId;
            quoteLine.Pricing_Deal_RFQ_Id__c = '23421';
            quoteLine.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
            quoteLine.Pricing_Status_Nm__c =system.label.Quote_Pricing_Status;
            quoteLine.Pricing_Consumption_Platform__c = 'Test platform 1,test platform 2';
            quoteLine.Pricing_Consumption_Region__c = 'ASMO';
            quoteLine.Pricing_Project_Nm__c = 'test project';
            quoteLine.Pricing_Ready_for_Review_cb__c = false;
            quoteLines.add(quoteLine);
        }
        
        insert quoteLines;
        return quoteLines;
    }
    public static SBQQ__QuoteLine__c createWINQuoteLines(Id quoteId){
        try{
            Product2 products = createWINProduct();
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLine.Pricing_Product_Nm__c = products.Id;
            quoteLine.SBQQ__Product__c = products.Id;
            //quoteLine.SBQQ__ProductName__c = Label.Pricing_Tender_Write_In_Product;
            quoteLine.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLine.Pricing_Systems_qty__c = 6; 
            quoteLine.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLine.Pricing_CPUs_per_system_qty__c = 1;
            quoteLine.Pricing_Single_System_Price_Amt__c = 4;
            quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLine.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLine.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLine.Pricing_Other_Product_Nm__c = 'Test Tender';
            quoteLine.Pricing_Other_Competitor_Product_Nm__c = 'Test Tender Prod';
            quoteLine.Pricing_Market_Segment_Nm__c = 'Non Embedded';
            quoteLine.Pricing_Rejection_Reason__c = 'Duplicate Request';
            quoteLine.SBQQ__Quote__c = quoteId;
            quoteLine.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
            insert quoteLine;
            return quoteLine;
        }catch(Exception exp){
            return null;
        }
        
    }
    
    //This method create Performance Metrics record by taking Quote Line Id as parameter    
    public static List<Pricing_Performance_Metric__c> createPerformanceMetrics(Id quoteLineId){        
        List<Pricing_Performance_Metric__c> performanceMetric = new List<Pricing_Performance_Metric__c>();
        for (Integer i=0;i<3;i++) { 
            Pricing_Performance_Metric__c perMetric = new Pricing_Performance_Metric__c();
            perMetric.Pricing_Performance_Metric_Nm__c = 'LS Dyna';
            perMetric.Pricing_Weighting_Pct__c = 1;
            perMetric.Pricing_Comp_SKU_Performance_Nbr__c = 1;
            perMetric.Pricing_Intel_SKU_Performance_Nbr__c = 1;
            perMetric.Pricing_Quote_Line__c = quoteLineId;
            performanceMetric.add(perMetric);
        }
        return performanceMetric;
    }
    
    //This method creates an User
    public static List<User> createUser(){
        Set<String> profileNameSet = new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};            
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'newUser', Email= 'FirstName@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
            }
            insert lstUser;
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>(); 
            for(user userId : lstUser){
                if(userId.Profile.Name == Label.Pricing_Tender_Profiles_SalesRepBB){
                    permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                    permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
                }
                if(userId.Profile.Name == Label.Pricing_Tender_Profiles_Partner){
                    permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                    permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps2.Id));
                }          
            }
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }  
        return lstUser;
    }
    
    //This Method Creates Field Service Engineer user by assigning particular permisssions
    public static List<User> createFSEUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            User u1 = new User();
            for(Id profileId : userProfileIdSet){
                 u1 = new User(Alias = 'newUser', Email= 'firstNameFSE@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstNameFSE@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
                
            }
            try{
                insert lstUser;
            }
            catch(Exception ex){
                u1.UserName = 'NewFSEUserUnique@Intel.com' + Math.floor(Math.random() * 1000);    
                insert lstUser;
            } 
            //insert lstUser;
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
            } 
            if(!permissionList.isEmpty()){
                insert permissionList;
            }   
        }  
        return lstUser;
    }
    
    //This Method Creates Field Service Engineer user by assigning particular permisssions
    public static List<User> createFSEUserWithParam(String emailValue,String lastNameValue,String userNameValue){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'newUser', Email = emailValue,
                                   EmailEncodingKey='UTF-8', LastName = lastNameValue, LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = emailValue + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
                
            }
            insert lstUser;
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
            }  
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }  
        return lstUser;
    }
    
    
    //This Method Creates Field Service Engineer user by assigning particular permisssions
    public static List<User> createSalesRepUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        //System.runAs(thisUser){
        User u1 = new User();
        for(Id profileId : userProfileIdSet){
             u1 = new User(Alias = 'newUser', Email= 'firstNameSalesRep@intel.com',
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profileId,
                               TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstNameSalesRep@Intel.com' + Math.floor(Math.random() * 1000));
            
            lstUser.add(u1);
            
        }
        try{
            insert lstUser;
        }
        catch(Exception ex){
             u1.UserName = 'NewFSEUserUnique@Intel.com' + Math.floor(Math.random() * 1000);   
            insert lstUser;
        } 
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
        } 
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        //}  
        return lstUser;
    }
    
    //This method creates Community User by assigning particular permissions
    public static List<User> createCommunityUser(){
        List<User> lstUser = new List<User>();
        List<User> lstUser2 = createAdminUser();
        
        System.runAs(lstUser2[0]){
            Account acc = createAccount();
            Contact con = createContact(acc.Id);
            Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_Partner}; 
                Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_PartnerCommunityUser].id;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
            Set<Id> userProfileIdSet=new Set<Id>();
            for(Profile proId : [SELECT id  FROM Profile  WHERE Name IN: profileNameSet]){
                userProfileIdSet.add(proId.Id);
            }
            
            
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            // System.runAs(thisUser){
            
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'newUser', Email= 'firstName@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US',ProfileId = p,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
                
            }
            insert lstUser;
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps.Id));
            }
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }
        //}  
        return lstUser;
    }
    
    //This method creates Admin User
    public static List<User> createAdminUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
        UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            User u1 = new User();
            for(Id profileId : userProfileIdSet){
                 u1 = new User(Alias = 'newUser', Email = 'firstName@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='testing admin', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId, UserRoleId = role.Id,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
            }
            try{
                insert lstUser;
            }
            catch(Exception ex){
                u1.UserName = 'NewAdminUserUnique@Intel.com' + Math.floor(Math.random() * 1000);
                insert lstUser;
            } 
            //insert lstUser;
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userRec : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userRec.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userRec.Id, PermissionSetId = ps.Id));
            }
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }  
        return lstUser;
    }

    //This method creates Admin User With param by assigning particular permissions
    public static List<User> createAdminUserWithParam(String userName){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
        UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'newUser', Email = userName+'@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='testing admin', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId, UserRoleId = role.Id,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = userName+'@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
            }
            insert lstUser;
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userRec : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userRec.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userRec.Id, PermissionSetId = ps.Id));
            }
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }  
        return lstUser;
    }
    public static List<User> createAdminUser2(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u1 = new User();
        System.runAs(thisUser){
            for(Id profileId : userProfileIdSet){
                u1 = new User(Alias = 'newUser', Email= 'firstName@intel.com',
                              EmailEncodingKey='UTF-8', LastName='testing admin', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = profileId,
                              TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
                
            }  
            try{
                insert lstUser;
            }
            catch(Exception ex){
                u1.UserName = 'NewAdminUser@Intel.com' + Math.floor(Math.random() * 1000);    
                insert lstUser;
            } 
            //insert lstUser;
        }
        return lstUser;
    }

    public static User createPartnerUser(Id accountId){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
        
        Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_Partner].id;        
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'FirstName2';
        con.LastName = 'LastName2';
        con.Email = 'FirstName2@intel.com';
        con.AccountId = accountId;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry = 'India';
        insert con;
        
        User user = new User(alias = 'test123', email='partner@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='FirstName@Intel.com');
        insert user;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = permissionRec.Id));
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id));
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        return user;        
    }
    
    public static Contact createPrimaryContact(Id accountId){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
        
        Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_Partner].id;        
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'primarycontact2';
        con.LastName = 'primarycontactLastName2';
        con.Email = 'primarycontact@noemail.com';
        con.AccountId = accountId;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry = 'India';
        //con.CurrencyIsoCode = 'USD';
        insert con;
        
        User user = new User(alias = 'test123', email='primarycontact@noemail.com', Core_WWID__c='123456', //CH
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='FirstNameprimarycontact@Intel.com');
        insert user;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = permissionRec.Id));
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id));
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        return con;        
    }
    
    public static Contact createPrimaryContactWithParam(Id accountId, String contactString){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
        
        Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_Partner].id;        
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'primarycontact2';
        con.LastName = 'primarycontactLastName2';
        con.Email = 'primaryContact2@noemail.com';
        con.AccountId = accountId;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry = 'India';
        //con.CurrencyIsoCode = 'USD';
        insert con;
        
        User user = new User(alias = 'test123', email=contactString+'@noemail.com', Core_WWID__c='123456', //CH
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username=contactString+'@Intel.com');
        insert user;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = permissionRec.Id));
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id));
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        return con;        
    }
    
    public static List<Contact> createPrimaryContact(Id accountId,Integer numberOfRec){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
        
        Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_Partner].id;  
        List<User> userList = new List<User>(); 
        List<Contact> contactList = new List<Contact>(); 
        for(Integer i=0; i < numberOfRec; i++){
            Contact con = new Contact();
            con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
            con.FirstName = 'primarycontact2'+i;
            con.LastName = 'primarycontactLastName2'+i;
            con.Email = 'primarycontact'+i+'@noemail.com';
            //'FirstName@test.com' + Math.floor(Math.random() * 1000);
            con.AccountId = accountId;
            con.Core_Primary_Contact__c = true;
            con.MailingCountry = 'India';
            //con.CurrencyIsoCode = 'USD';
            
            contactList.add(con);
        }
        insert contactList;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(Integer i=0; i<numberOfRec; i++){
            User user = new User(alias = 'test123', email='primarycontact'+i+'@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, IsActive =true,
                                 ContactId = contactList[i].Id,
                                 timezonesidkey='America/Los_Angeles', username='FirstNameprimarycontact'+i+'@Intel.com');
            userList.add(user);
        }
        insert userList;
        
        for(Integer i=0; i<numberOfRec; i++){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userList[i].id, PermissionSetId = permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userList[i].id, PermissionSetId = ps.Id));
        }
        
        insert permissionList;
        return contactList;        
    }
    
    public static List<Contact> createPrimaryContactAPI(Id accountId,Integer numberOfRec){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
        
        Id p = [select id from profile where name ='B2B API Partner'].id;  
        List<User> userList = new List<User>(); 
        List<Contact> contactList = new List<Contact>(); 
        for(Integer i=0; i < numberOfRec; i++){
            Contact con = new Contact();
            con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
            con.FirstName = 'primarycontact2'+i;
            con.LastName = 'primarycontactLastName2'+i;
            con.Email = 'primarycontact'+i+'@noemail.com';
            //'FirstName@test.com' + Math.floor(Math.random() * 1000);
            con.AccountId = accountId;
            con.Core_Primary_Contact__c = true;
            con.MailingCountry = 'India';
            //con.CurrencyIsoCode = 'USD';
            
            contactList.add(con);
        }
        insert contactList;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(Integer i=0; i<numberOfRec; i++){
            User user = new User(alias = 'test123', email='primarycontact'+i+'@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, IsActive =true,
                                 ContactId = contactList[i].Id,
                                 timezonesidkey='America/Los_Angeles', username='FirstNameprimarycontact'+i+'@Intel.com');
            userList.add(user);
        }
        insert userList;
        
        for(Integer i=0; i<numberOfRec; i++){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userList[i].id, PermissionSetId = permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userList[i].id, PermissionSetId = ps.Id));
        }
        
        insert permissionList;
        return contactList;        
    }
    //This method creates partner user by assigning particular permissions
    public static List<User> createExternalUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        for(Id profileId : userProfileIdSet){
            User u1 = new User(Alias = 'newUser', Email= 'firstName@intel.com',
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US',ProfileId = profileId,
                               TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstNameExternal@Intel.com' + Math.floor(Math.random() * 1000));
            
            lstUser.add(u1);
            
        }
        insert lstUser;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps.Id));
        } 
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        return lstUser;
    }
    
    public static List<User> createPartner(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB}; 
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        for(Id profileId : userProfileIdSet){
            User u1 = new User(Alias = 'newUser', Email= 'firstName@intel.com',
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US',ProfileId = profileId,
                               TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
            
            lstUser.add(u1);            
        }
        insert lstUser;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps.Id));
        } 
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        return lstUser;
    }
    
    //This method creates pricing manager user by assigning particular permissions
    public static List<User> createPricingMangerUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
             User u1 = new User();
            for(Id profileId : userProfileIdSet){
                 u1 = new User(Alias = 'newUser', Email= 'firstName@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
            }
            try{
                insert lstUser;
            }
            catch(Exception ex){
                u1.UserName = 'NewRPMUser@Intel.com' + Math.floor(Math.random() * 1000);    
                insert lstUser;
            } 
            //insert lstUser;
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
            }   
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }  
        return lstUser;
    }
    
    //This method creates pricing manager user by assigning particular permissions
    public static List<User> createPricingMangerUser2(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            User u1 = new User();
            for(Id profileId : userProfileIdSet){
                 u1 = new User(Alias = 'newUser', Email= 'firstNameRPM@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName_RPM@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
            }
            try{
                insert lstUser;
            }
            catch(Exception ex){
                u1.UserName = 'NewRPMUserUnique@Intel.com' + Math.floor(Math.random() * 1000);    
                insert lstUser;
            } 
            //insert lstUser;
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
            }   
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }  
        return lstUser;
    }
    
    public static List<User> createDPMUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_PricingDivisionalTenderPricingManager];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'dpm', Email= 'dpm@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='DPM', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
            }
            insert lstUser;
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
            }   
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }  
        return lstUser;
    }
    
    public static List<User> createAEUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        //System.runAs(thisUser){
         User u1 = new User();
        for(Id profileId : userProfileIdSet){
             u1 = new User(Alias = 'newUser', Email= 'firstNameAE@intel.com',
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                               TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstNameAE@Intel.com' + Math.floor(Math.random() * 1000));
            
            lstUser.add(u1);
            
        }
        try{
            insert lstUser;
        }
        catch(Exception ex){
            u1.UserName = 'NewAEUserUnique@Intel.com' + Math.floor(Math.random() * 1000);    
            insert lstUser;
        } 
        //insert lstUser;
        List<PermissionSetAssignment> PermissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            PermissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
            PermissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
        }
        if(!PermissionList.isEmpty()){
            insert PermissionList;
        }
        //}  
        return lstUser;
    }   
    
    public static List<User> createAEUserWithParam(String emailValue){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        //System.runAs(thisUser){
        
        for(Id profileId : userProfileIdSet){
            User u1 = new User(Alias = 'newUser', Email = emailValue,
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                               TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstNameAE@Intel.com' + Math.floor(Math.random() * 1000));
            
            lstUser.add(u1);
            
        }
        insert lstUser;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
        }  
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        //}  
        return lstUser;
    } 
    
    public static void updateQuoteLineStatus(Id quoteLineId, string status){
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Pricing_Status_Nm__c FROM SBQQ__QuoteLine__c WHERE Id=:quoteLineId];
        quoteLine.Pricing_Status_Nm__c = status;
        update quoteLine;
    } 
    
    public static void shareQuoteWithUser(Id quoteId, Id userId){
        SBQQ__Quote__Share quoteShare = new SBQQ__Quote__Share();
        quoteShare.ParentId = quoteId;
        quoteShare.UserOrGroupId = userId;
        quoteShare.AccessLevel = 'Edit';
        quoteShare.RowCause = Schema.SBQQ__Quote__Share.RowCause.Manual;
        insert quoteShare;
    }
    
    public static User createPartnerAdminUser(Id accountId){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_PartnerAdministrator];
        
        Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_Partner].id;        
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'FirstName2';
        con.LastName = 'LastName2';
        con.Email = 'FirstName2@intel.com';
        con.AccountId = accountId;
        con.MailingCountry = 'India';
        con.Core_Primary_Contact__c = true;
        
        insert con;
        
        User user = new User(alias = 'test123', email='partner@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='FirstName@Intel.com');
        insert user;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = permissionRec.Id));
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id));
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        return user;        
    }
    
    public static List<User> createITSUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_Permission_Set_IT_Specialist];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'newUser', Email= 'firstNameITS@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstNameITS@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
            }
            insert lstUser;
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
            }   
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }  
        return lstUser;    
    }
    
    public static List<Contact> createDrafterLimitedContact(Id accountId,Integer numberOfRec){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderDrafterLimited];
        
        Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_Partner].id;  
        List<User> userList = new List<User>(); 
        List<Contact> contactList = new List<Contact>(); 
        for(Integer i=0; i < numberOfRec; i++){
            Contact con = new Contact();
            con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
            con.FirstName = 'primarydrlmtcontact2'+i;
            con.LastName = 'primarycontactLastName2'+i;
            con.Email = 'drafterLimited'+i+'@noemail.com';
            //'FirstName@test.com' + Math.floor(Math.random() * 1000);
            con.AccountId = accountId;
            con.Core_Primary_Contact__c = true;
            con.MailingCountry = 'India';
            //con.CurrencyIsoCode = 'USD';
            
            contactList.add(con);
        }
        insert contactList;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(Integer i=0; i<numberOfRec; i++){
            User user = new User(alias = 'test123', email='drafterLimited'+i+'@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, IsActive =true,
                                 ContactId = contactList[i].Id,
                                 timezonesidkey='America/Los_Angeles', username='drLmtdprimarycontact'+i+'@Intel.com');
            userList.add(user);
        }
        insert userList;
        
        for(Integer i=0; i<numberOfRec; i++){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userList[i].id, PermissionSetId = permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userList[i].id, PermissionSetId = ps.Id));
        }
        
        insert permissionList;
        return contactList;        
    }
    
    
    public static void createTemplate(id fold1er){
        /* 
Folder temp = [SELECT Id, ParentId, Name, DeveloperName, Type FROM Folder where name='CPQ Email Templates'];
EmailTemplate e1 = new EmailTemplate (developerName = 'SBAA_CPQ_Tender_QuoteLine_Approved2',  TemplateType= 'Text', Name = 'SBAA CPQ Tender QuoteLine Approved',isActive=true,FolderId=temp.id); // plus any other fields that you want to set
EmailTemplate e2 = new EmailTemplate (developerName = 'SBAA_CPQ_Tender_QuoteLine_Reject2',  TemplateType= 'Text', Name = 'SBAA CPQ Tender QuoteLine Reject', isActive=true,FolderId=temp.id); // plus any other fields that you want to set
List<EmailTemplate> emailList = new List<EmailTemplate>();
emailList.add(e1);
emailList.add(e2);
insert emailList ;

EmailTemplate et = new EmailTemplate(); 
et.isActive = true; 
et.Name = 'Pricing_QuoteSubmittedNotification'; 
et.DeveloperName = 'testTemplate' + System.now().getTime(); 
et.TemplateType = 'text'; 
et.FolderId = UserInfo.getUserId(); 
et.Body = ''; 

insert et; 
*/
    }
     Public static  List<Pricing_Competitor_Product_Price__c> createCompetitorProductPrice(){
         
         Id compRecordId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c','Pricing_Data_Center');
          Pricing_Competitor_Product__c compProduct1 = new Pricing_Competitor_Product__c(Name='TestCompProduct1',   RecordTypeId = compRecordId, Pricing_Active_cb__c = true);
                    insert compProduct1;
          Pricing_Competitor_Product__c compProduct2 = new Pricing_Competitor_Product__c(Name='TestCompProduct2',   RecordTypeId = compRecordId, Pricing_Active_cb__c = true);
                    insert compProduct2;
                           
                List<Pricing_Competitor_Product_Price__c> compProductsPriceList = new List<Pricing_Competitor_Product_Price__c>();
                    Pricing_Competitor_Product_Price__c compProductPrice;
                    compProductPrice = new Pricing_Competitor_Product_Price__c(Pricing_Competitor_Product__c=compProduct1.Id,Pricing_Region_Nm__c='APJ',Pricing_Final_Meet_Comp_Price__c = 20,Pricing_Application_Nm__c = 'Enterprise');
                    compProductsPriceList.add(compProductPrice);
                    compProductPrice = new Pricing_Competitor_Product_Price__c(Pricing_Competitor_Product__c=compProduct2.Id,Pricing_Region_Nm__c='APJ',Pricing_Final_Meet_Comp_Price__c = 250,Pricing_Application_Nm__c = 'Enterprise');
                    compProductsPriceList.add(compProductPrice);    

                insert compProductsPriceList;
                return compProductsPriceList;
     }
    Public static  List<Pricing_Competitor_Product_Price_Staging__c> createCompetitorProductPriceStaging(){
        
        Id compRecordId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c','Pricing_Data_Center');
        Pricing_Competitor_Product__c compProduct1 = new Pricing_Competitor_Product__c(Name='TestCompProduct1',   RecordTypeId = compRecordId, Pricing_Active_cb__c = true);
        insert compProduct1;
        Pricing_Competitor_Product__c compProduct2 = new Pricing_Competitor_Product__c(Name='TestCompProduct2',   RecordTypeId = compRecordId, Pricing_Active_cb__c = true);
        insert compProduct2;
        
        List<Pricing_Competitor_Product_Price_Staging__c> compProductsPriceList = new List<Pricing_Competitor_Product_Price_Staging__c>();
        Pricing_Competitor_Product_Price_Staging__c compProductPrice;
        compProductPrice = new Pricing_Competitor_Product_Price_Staging__c(Pricing_Competitor_Product_Name_Staging__c=compProduct1.Name,Pricing_Region_Staging_Nm__c='APJ',Pricing_Final_Meet_Comp_Price_Staging__c = 20,Pricing_Application_Staging_Nm__c = 'Enterprise',Pricing_List_Price_Staging__c = 10,Pricing_Median_Meet_Comp_Disty_Staging__c=10);
        compProductsPriceList.add(compProductPrice);
        compProductPrice = new Pricing_Competitor_Product_Price_Staging__c(Pricing_Competitor_Product_Name_Staging__c=compProduct2.Name,Pricing_Region_Staging_Nm__c='APJ',Pricing_Final_Meet_Comp_Price_Staging__c = 250,Pricing_Application_Staging_Nm__c = 'Enterprise',Pricing_List_Price_Staging__c = 10,Pricing_Median_Meet_Comp_Disty_Staging__c=10);
        compProductsPriceList.add(compProductPrice);    
        
        insert compProductsPriceList;
        return compProductsPriceList;
    }
    Public static Pricing_Quote_Hold_Status_Age__c createQuoteHoldStatusAge(Id quoteId,String comments,String role){
        Pricing_Quote_Hold_Status_Age__c quoteHoldAge = new Pricing_Quote_Hold_Status_Age__c();
            quoteHoldAge.Name = 'Test Quote Age';
            quoteHoldAge.Pricing_QuoteOnHold__c = quoteId;
            quoteHoldAge.Pricing_QuoteOnHold_Start_Time__c = system.today();
            quoteHoldAge.Pricing_QuoteOnHold_End_Time__c = system.today() + 2;
            quoteHoldAge.Pricing_Is_On_Hold__c = true;
        	quoteHoldAge.Pricing_Quote_On_Hold_Comment__c = comments;
            quoteHoldAge.Pricing_QuoteOnHold_User_Role__c = 'role';
            insert quoteHoldAge;
        return quoteHoldAge;
   }

    Public static Group createGroupRecord(){
        Group grp = new Group();
            grp.name = 'Test_Group1';
            grp.Type = 'Regular';
            grp.DeveloperName = 'Test_Group1'; 
            Insert grp;
        return grp;
   }

    Public static ChannelProgram createChannelProgramRecord(){
        ChannelProgram chProg = new ChannelProgram();
            chProg.Name = Label.Pricing_Tender_PGM_Channel;
            chProg.isActive = true;
            insert chProg;
        return chProg;
    }

    public static List<Core_MDF_Partner_Group_Mapping__c> createPGMRecord(Account acc,Group grp,ChannelProgram chProg, Integer numberOfPGMRecs){
        try{
        list <Core_MDF_Partner_Group_Mapping__c> partnerGroupList = new list<Core_MDF_Partner_Group_Mapping__c>();
        for(Integer i=0;i<numberOfPGMRecs;i++){
            Core_MDF_Partner_Group_Mapping__c partnerGroup = new Core_MDF_Partner_Group_Mapping__c();
            partnerGroup.Core_MDF_Account__c = acc.Id;
            partnerGroup.Core_MDF_Group_Name__c = grp.DeveloperName;
            partnerGroup.Core_MDF_Type_of_Access__c = Label.Pricing_Tender_PGM_Type;
            partnerGroup.Core_MDF_Channel_Program__c=chProg.id;
            partnerGroup.Core_MDF_AccountIdGroupName__c='Test Group1';
            partnerGroup.Core_MDF_Group_Id__c=grp.id;
            partnerGroupList.add(partnerGroup);
        }
        insert partnerGroupList;
        return partnerGroupList;
        }catch(Exception e){
                        return null;
        }
    }

   //methods for Financial Incentive
   public static Product_Additional_Attribute__c createDealRegProduct(){
        try{
            Product2 prod = new Product2(Name='Deal Reg Product',
                                         Core_Product_Org__c = 'Sales',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG~DCAI',
                                         Core_Processor_Number_Nm__c = 'P6500',
                                         Core_VerticalSegment__c = 'Mobile',
                                         IsActive = true);
            insert prod;
            Product_Additional_Attribute__c dealprod = new Product_Additional_Attribute__c();
            dealprod.Name = 'Deal Reg Product';
            dealprod.Product__c = prod.Id;
            dealprod.Eligible_for_Deal_Reg__c = true;
            dealprod.Programs_Eligible__c = 'PDI';
            insert dealprod;
            return dealprod;
        }catch(Exception exp){
            return null;
        }
    }

    public static List<OpportunityLineItem> createOpportunityProduct(Id oppId, Integer noOfRecs){
        try{
            List<OpportunityLineItem> oppItemList = new List<OpportunityLineItem>();
            Product_Additional_Attribute__c dealRegProd = createDealRegProduct();
            PricebookEntry testPBE = new PricebookEntry();
            testPBE.UnitPrice = 1;
            testPBE.isActive  = TRUE;
            testPBE.Pricebook2Id = Test.getStandardPricebookId();
            testPBE.Product2Id = dealRegProd.Product__c;      
            testPBE.UseStandardPrice = false;
            insert testPBE;

            for(Integer i=0; i < noOfRecs; i++) {
                OpportunityLineItem oppRec = new OpportunityLineItem();
                oppRec.OpportunityId = oppId;
                oppRec.PricebookEntryId = testPBE.Id;
                oppRec.Product2Id = dealRegProd.Product__c;
                oppRec.Quantity = 1;
                oppRec.UnitPrice = testPBE.UnitPrice;
                oppRec.Core_Status__c = 'Pending';
                oppRec.Core_Division_Code__c = '11111';
                oppRec.Core_Group_Code__c = '55555';
                oppRec.Core_Division__c = 'Division 1';
                oppRec.Core_Group__c = 'Group 1';
                //oppRec.TotalPrice = 200;
                oppItemList.add(oppRec);
            }
            insert oppItemList;
            return oppItemList;
        }catch(Exception exp) {
            return null;
        }
    }
    
    public static Core_Design_Registration__c createDesignRegistration(){
        Core_Design_Registration__c designReg = new Core_Design_Registration__c();
        designReg.Core_Design_Registration_Nm__c = 'Test Design';
        designReg.Core_Product_Group_Nm__c = 'Embedded/IOT';
        designReg.Core_Design_Registration_Dsc__c = 'Test Design';
        designReg.Core_Opportunity_Volume_Cnt__c = 20;
        designReg.Core_Partner_FAE_Nm__c = 'Test Partner';
        designReg.Core_End_Customer_Street_Addr_Line1_Txt__c = '101 nagar';
        designReg.Core_End_Customer_Nm__c = 'test End customer';
        designReg.Core_End_Customer_City_Nm__c = 'houston';
        designReg.Core_End_Customer_Country_Subdivision_Nm__c = 'test';
        designReg.Core_End_Customer_Postal_Cd__c = '49423';
        designReg.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'No';
        designReg.Core_Opportunity_Decision_Dt__c = system.today().addDays(2);
        designReg.Core_First_Customer_Ship_Dt__c = designReg.Core_Opportunity_Decision_Dt__c.addDays(7);
        designReg.Core_Production_End_Dt__c = designReg.Core_First_Customer_Ship_Dt__c.addDays(7);
        designReg.Core_Product_Segment_Nm__c = 'Embedded / IOT';
        designReg.Core_Product_Application_Nm__c = 'Gateway';
        designReg.Core_Vertical_Market_Nm__c = 'Education';
        designReg.PCC_Deal_Description__c = 'test Description';
        designReg.PCC_Competition_Assumptions__c = 'test competition';
        designReg.PCC_End_Customer_Use__c = 'test customer';
        designReg.PCC_Current_EndCustomer_Product_Provider__c = 'test provider';
        designReg.PCC_Consumption_Countries__c = 'test consumption';
        designReg.PCC_Partner_Reference_ID__c = '123test';
        designReg.PCC_End_Customer_Country__c = 'India';
        insert designReg;
        return designReg;
	}
    
    public static List<SBQQ__Quote__c> createFIQuoteWithParam(Id accId,Id conId, Integer numberOfQuotes, String salesRepEmail, String accountExecutiveEmail){
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();    
        Pricing_UnifiedEndCustomerAccountMapping__c endCustomer = createUnifiedEndCustomer(accId);
        for(Integer i=0;i<numberOfQuotes;i++){ 
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = accId;
            quote.SBQQ__PrimaryContact__c = conId;
            quote.Pricing_Project_Name_Nm__c = 'Test Project'+i;
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c','Pricing_Financial_Incentive_Quote_Submitted');
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = salesRepEmail;
            quote.Pricing_End_Customer__c = endCustomer.Id;
            quote.Pricing_Customer_Nm__c = '';
            quote.Pricing_ShipmentStDate_Dt__c = system.today();
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = accountExecutiveEmail;
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';      
            quote.Pricing_Quote_Program_Nm__c = 'Financial Incentive';
            quote.SBQQ__Opportunity2__c = createOpportunity().Id;
            quote.Pricing_Consumption_Countries__c = 'test comments';
            quote.Pricing_Current_EndCustomer_Product_Prvd__c = 'test comments';
            quote.Pricing_Competition_Assumptions__c = 'test comments';
            quote.Pricing_Deal_description__c = 'test comments';
            quote.Pricing_End_Customer_URL__c = 'www.test.com';
            lstQuote.add(quote);
        }
        insert lstQuote;
        return lstQuote;
    }
    
    public static List<SBQQ__QuoteLine__c> createFIQuoteLines(Id quoteId, Integer numquoteLines){
        List<Product2> products = new List<Product2>();
        for(Integer i=0;i<numquoteLines;i++) {
            Product2 prod = new Product2(Name='TestProduct' + i,
                                         Core_Product_Org__c = 'Sales',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG~DCAI',
                                         Core_Processor_Number_Nm__c = 'P6500',
                                         IsActive = true);
            products.add(prod);
        }
        insert products;
       
     
        Id quoteLineCreateRecordId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Financial_Incentive_Quote_Line_Edit);
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        Integer count = 0;
        for(Product2 prod1:products){
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId=quoteLineCreateRecordId;//Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLine.Pricing_Product_Nm__c = prod1.Id;
            quoteLine.SBQQ__Product__c = prod1.Id;
            quoteLine.Pricing_Quote_Line_Number__c = 'Test'+count;
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
            quoteLine.SBQQ__Quote__c = quoteId;
            quoteLine.Pricing_Deal_RFQ_Id__c = '23421';
            quoteLine.Pricing_Quote_Program_Nm__c = 'Financial Incentive';
            quoteLine.Pricing_Status_Nm__c =system.label.Quote_Pricing_Status;
            quoteLine.Pricing_Consumption_Platform__c = 'Test platform 1,test platform 2';
            quoteLine.Pricing_Consumption_Region__c = 'ASMO';
            quoteLine.Pricing_FI_Net_RPU_Amt__c = 10;
            quoteLines.add(quoteLine);
            count++;
        }
        
        insert quoteLines;
        return quoteLines;
    }
    public static SBQQ__QuoteLine__c createQuoteLineByStatus(Id quoteId, String quoteLineStatus){
        try{
            Product2 prod = new Product2(Name='TestProduct',
                                         Core_Product_Org__c = 'Sales',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG~DCAI',
                                         Core_Processor_Number_Nm__c = 'P6500',
                                         IsActive = true);

        insert prod;
       
        Id quoteLineCreateRecordId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Tender_QuoteLine_RecordType_Create);
        
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
            quoteLine.SBQQ__Quote__c = quoteId;
            quoteLine.Pricing_Deal_RFQ_Id__c = '';
            quoteLine.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
            quoteLine.Pricing_Status_Nm__c = quoteLineStatus;
            quoteLine.Pricing_Consumption_Platform__c = 'Test platform 1,test platform 2';
            quoteLine.Pricing_Consumption_Region__c = 'ASMO';
            quoteLine.Pricing_Project_Nm__c = 'test project';

        insert quoteLine;
        return quoteLine;
        }catch(Exception exp){
            return null;
        }        
    }
    public static Pricing_Approval_Price_Rules__c createApprovalPriceRule(Id accId){
        try{
            //Account acc = Pricing_Test_Utility.createAccount();
            Pricing_Approval_Price_Rules__c rule = new Pricing_Approval_Price_Rules__c(
                Pricing_Rule_Name__c = 'Test Rule',
                Pricing_Approval_Status__c = 'Pending',
                Pricing_End_Date__c = Date.today().addMonths(1),
                Pricing_Rule_Start_Date__c = Date.today(),
                Pricing_Rule_End_Date__c = Date.today().addMonths(12),
                Pricing_Quote_Type__c = 'Client',
                Pricing_Account__c = accId,
                Pricing_End_Customer_Country__c = 'India',
                Pricing_Form_Factor__c = 'AIO',
                Pricing_Intel_Account_Exec_Email_Txt__c = 'exec@example1.com',
                Pricing_Intel_Sales_Rep_Email_Txt__c = 'rep@example1.com',
                Pricing_Market_Segment_values_Nm__c = 'Corp',
                Pricing_Is_Enabled__c = true
            );
            insert rule;
            return rule;
        }catch(Exception exp){
            return null;
        }
    }
    
    public static Pricing_Product_Floor_Price__c createFloorPriceRec(Id ruleId){
        Product2 prod = new Product2(Name='TestProduct',
                                     Core_Product_Org__c = 'Sales',
                                     Core_Product_Type__c = 'Processors',
                                     Core_Sales_Visible_Flag__c = true,
                                     Core_Hierarchy_ID__c = '43',
                                     Core_Group_Code_Short_Name__c = 'DCG~DCAI',
                                     Core_Processor_Number_Nm__c = 'P6500',
                                     IsActive = true);
        
        insert prod;
        Pricing_Product_Floor_Price__c floorPrice = new Pricing_Product_Floor_Price__c();
        floorPrice.Pricing_Product__c = prod.Id;
        floorPrice.Pricing_Active__c = true;
        floorPrice.Pricing_Approved_ECAP_Price__c = 123;
        floorPrice.Pricing_Approval_Price_Rules__c = ruleId;
        insert floorPrice;
        return floorPrice;
    }
}