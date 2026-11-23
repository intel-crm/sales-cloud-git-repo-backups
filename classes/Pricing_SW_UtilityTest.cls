/****************************************************************************************************
Apex Class Name : Pricing_SW_UtilityTest
Version         : 1.0 
Created Date    : 08/13/2024
Function        : Test Data for Pricing_SW.
Modifications   : Test data set up for SBQQ__Quote__c, sbaa__Approval__c,

*****************************************************************************************************/

@isTest
public class Pricing_SW_UtilityTest {
    static List<Account> accountList;
    static Opportunity opp;
    static List<OpportunityTeamMember> teamMembers;

    // Method to create a User
    public static User createUser(String alias, String email, String lastName) {
        User user = new User(
            Alias = alias,
            Email = email,
            EmailEncodingKey = 'UTF-8',
            LastName = lastName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = email
        );
        insert user;
        return user;
    }
    
    // Method to create a Account 
    public static Account createAccount(String name) {
        //Account acc = createAccount('Test Account');
            Account acc = new Account(
                Name = name
                ,RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount)
                ,BillingCountryCode = 'USA'
                ,BIllingStateCode = 'AL'
                ,BillingCity = 'Alabama'
                ,BillingStreet = 'test ' + (Math.random() * 1000)
                ,Core_Sales_Groups__c = 'Americas US Sales Group'
                ,Industry = 'Agriculture'
                ,Core_Sub_Industry__c = 'Crop Production'           
            );
            insert acc;
            return acc;
        }
        
        public static List <Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i
                ,BillingCountryCode = 'USA'
                ,BIllingStateCode = 'AL'
                ,BillingCity = 'Alabama'
                ,BillingStreet = 'test ' + (Math.random() * 1000)
                ,Core_Sales_Groups__c = 'Americas US Sales Group'
                ,Industry = 'Agriculture'
                ,Core_Sub_Industry__c = 'Crop Production'
            ));
        }
        insert accountList;
        return accountList;
    }   
        
    //Method to create an Opportunity record   
    //Opportunity opp = createOpportunity(acc, 'Prospecting', Date.today().addMonths(1));
    public static Opportunity createOpportunity(Account acc, String stageName, Date closeDate) {
        Core_Opp_Bypass_Validation_Rule__c mapBypassValidation = Core_Opp_Bypass_Validation_Rule__c.getInstance();
            mapBypassValidation.Bypass__c = true;
            SBQQ.TriggerControl.disable();
            upsert mapBypassValidation;
            SBQQ.TriggerControl.enable(); 
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = stageName,
            CloseDate = closeDate
            
        );
        insert opp;
        return opp;
        
    }
    
        
    // Method to create multiple Opportunities linked to an Account
    public static List<Opportunity> createOpportunities(Account acc, Integer count, String stageName, Date closeDate) {
        Core_Opp_Bypass_Validation_Rule__c mapBypassValidation = Core_Opp_Bypass_Validation_Rule__c.getInstance();
            mapBypassValidation.Bypass__c = true;
            SBQQ.TriggerControl.disable();
            upsert mapBypassValidation;
            SBQQ.TriggerControl.enable();
        
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < count; i++) {
            opps.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                AccountId = acc.Id,
                StageName = stageName,
                CloseDate = closeDate
            ));
        }
        insert opps;
        return opps;
    }
        
        
    // Method to create a single Opportunity Team Member linked to an Opportunity
    public static OpportunityTeamMember createOpportunityTeamMember(Opportunity opp, User user, String teamMemberRole) {
        OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(
            OpportunityId = opp.Id,
            UserId = user.Id,
            TeamMemberRole = teamMemberRole
        );
        insert oppTeamMember;
        return oppTeamMember;
    }

    // Method to create multiple Opportunity Team Members linked to an Opportunity
    public static List<OpportunityTeamMember> createOpportunityTeamMembers(Opportunity opp, List<User> users, String teamMemberRole) {
        List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
        for (User user : users) {
            oppTeamMembers.add(new OpportunityTeamMember(
                OpportunityId = opp.Id,
                UserId = user.Id,
                TeamMemberRole = teamMemberRole
            ));
        }
        insert oppTeamMembers;
        return oppTeamMembers;
    }    
    public static SBQQ__Quote__c createQuoteWithApproval(Opportunity opp, String status, String approvalStatus, Boolean isPrimary, Id accId) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = opp.Id
            ,SBQQ__Status__c = status
            ,ApprovalStatus__c = approvalStatus
            ,SBQQ__Primary__c = isPrimary
            ,SBQQ__Account__c = accId        
            ,SBQQ__StartDate__c =  system.today()
            ,SBQQ__SubscriptionTerm__c= 12
            ,Pricing_SW_Expiry_Date__c= system.today()+15
            ,Pricing_Quote_Program_Nm__c = 'Software & Services'
        );
        insert quote;
        return quote;
    }
    
    // Utility method to create an Opportunity
    public static Opportunity createOpportunityForPrimary(Id accId, Boolean hasAcceptedPrimaryQuote, String stageName) {
        Core_Opp_Bypass_Validation_Rule__c mapBypassValidation = Core_Opp_Bypass_Validation_Rule__c.getInstance();
            mapBypassValidation.Bypass__c = true;
            SBQQ.TriggerControl.disable();
            upsert mapBypassValidation;
            SBQQ.TriggerControl.enable();
        Opportunity opp = new Opportunity(                
            AccountId = accId
            ,CloseDate = Date.today().addMonths(1)
            ,StageName = stageName
        );
        insert opp;
        
        if (hasAcceptedPrimaryQuote) {
            SBQQ__Quote__c primaryQuote = createQuoteWithApproval(opp, 'Accepted', 'Approved', true, accId);
            opp.SBQQ__PrimaryQuote__c = primaryQuote.Id;
            update opp;
        }
        
        return opp;
    }
    
    // Method to create a single Quote linked to an Opportunity
    //SBQQ__Quote__c quote = createQuote(opp, 'Draft');
    public static SBQQ__Quote__c createQuote(Opportunity opp, String status, Id accId) {            
        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c(Name = 'IQR Software Quote Template');
        insert quoteTemplate;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            //Name = 'Test Quote',
            RecordTypeId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_SW_QuoteCreateRecordTypeId)
            ,SBQQ__Account__c = accId
            ,SBQQ__Primary__c= true
            ,SBQQ__StartDate__c=  system.today()
            ,SBQQ__Opportunity2__c = opp.Id
            ,SBQQ__Status__c = status
            ,SBQQ__SubscriptionTerm__c= 12
            ,Pricing_SW_Expiry_Date__c= system.today()+15
            ,Pricing_Quote_Program_Nm__c = 'Software & Services'
        ); 
          
        insert quote;
        return quote;
    }
    
    // Method to create multiple Quotes linked to an Opportunity
    public static List<SBQQ__Quote__c> createQuotes(Opportunity opp, Integer count, String status, Id accId) {
        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c(Name = 'IQR Software Quote Template');
        Pricing_Sw_Validation_Bypass__c setting = new Pricing_Sw_Validation_Bypass__c();
        setting.By_Pass_Validation__c = true;
        insert setting;
        
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        for (Integer i = 0; i < count; i++) {
            quotes.add(new SBQQ__Quote__c(
                //Name = 'Test Quote ' + i,
                RecordTypeId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_SW_QuoteCreateRecordTypeId)
                ,SBQQ__Account__c = accId
                ,SBQQ__Primary__c= true
                ,SBQQ__StartDate__c=  system.today()
                ,SBQQ__Opportunity2__c = opp.Id
                ,SBQQ__Status__c = Label.Pricing_SW_QuoteStatusDraft
                ,SBQQ__SubscriptionTerm__c= 12
                ,Pricing_SW_Expiry_Date__c= system.today()+15
                ,Pricing_Quote_Program_Nm__c = 'Software & Services'
                ));
        }
        insert quotes;
        return quotes;
    }  
    
    public static List<SBQQ__Quote__c> createQuoteWithStatus(Account testAccount, Opportunity opp, Integer count){
        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c(Name = 'IQR Software Quote Template');
        Core_Opp_Bypass_Validation_Rule__c mapBypassValidation = Core_Opp_Bypass_Validation_Rule__c.getInstance();
            mapBypassValidation.Bypass__c = true;
            SBQQ.TriggerControl.disable();
            upsert mapBypassValidation;
            SBQQ.TriggerControl.enable();
            List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
            Id recordtypeid = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_SW_QuoteCreateRecordTypeId);
            for (Integer i = 1; i <= count; i++) {
                SBQQ__Quote__c quote = new SBQQ__Quote__c(
                    //Name = 'Test Quote ' + i,
                    SBQQ__Opportunity2__c = opp.Id
                    ,SBQQ__Account__c = testAccount.Id
                    ,RecordTypeId =  recordtypeid
                    ,SBQQ__Status__c = Label.Pricing_SW_QuoteStatusDraft
                    ,ApprovalStatus__c = Label.Pricing_SW_QuoteApprovalStatusPending
                    ,SBQQ__StartDate__c=  system.today()
                    ,SBQQ__SubscriptionTerm__c= 12
                    ,Pricing_SW_Expiry_Date__c= system.today()+15
                    ,Pricing_Quote_Program_Nm__c = 'Software & Services'
                );
                quotes.add(quote);
            }

            insert quotes;
        
            // **Fixed the loop to iterate over the inserted quotes instead of an empty list**
            List<SBQQ__Quote__c> updatedQuotes = new List<SBQQ__Quote__c>();
            for(SBQQ__Quote__c quote : quotes){
                SBQQ__QuoteLine__c quoteLine = createQuoteLines(quote);
                // Ensure that setting ApprovalStatus__c here complies with your validation rules
                quote.ApprovalStatus__c = Label.Pricing_SW_QuoteApprovalStatusPending;
                updatedQuotes.add(quote);
            }
        
            try {
                upsert updatedQuotes;
            } catch (DmlException e) {
                // Handle exceptions and possibly log them for debugging
                System.debug('Error updating quotes: ' + e.getMessage());
                throw e; // Re-throw or handle as appropriate
            }
            return updatedQuotes;
    }
    
    //Method to create an Quoteshare record
    public static SBQQ__Quote__Share shareQuoteWithUser(Id quoteId, Id userId){
        SBQQ__Quote__Share quoteShare = new SBQQ__Quote__Share();
        quoteShare.ParentId = quoteId;
        quoteShare.UserOrGroupId = userId;
        quoteShare.AccessLevel = 'Edit';
        quoteShare.RowCause = Schema.SBQQ__Quote__Share.RowCause.Manual;
        insert quoteShare;
        return quoteShare;
        //System.assert(quoteShare.ParentId!=null,'Quote Shared with user');
    }
    
    //Method to create an Document record    
    public static Document createTestDocument() {
        Document doc = new Document(
            Name = 'Pricing_SW_Intel_Logo',
            FolderId = UserInfo.getUserId(), 
            Body = Blob.valueOf('Test Document')
        );
        insert doc;
        return doc;
    }    
    

    public static sbaa__Approval__c createTestApproval(Id QuoteId) {
        sbaa__Approval__c approval = new sbaa__Approval__c(Quote__c = QuoteId, sbaa__ApprovalStep__c = 1, sbaa__RecordField__c = 'Quote__c');            
        insert approval;
        return approval;
    }
    
    
    public static List<sbaa__Approval__c> createTestApproval(List<SBQQ__Quote__c> quotes) {
        List<sbaa__Approval__c> approval = new List<sbaa__Approval__c>();
        Integer counter = 0;
        for (SBQQ__Quote__c quote : quotes) {
            counter += 10;
            approval.add(new sbaa__Approval__c(
                    Quote__c = quote.Id
                    ,sbaa__ApprovalStep__c = counter
                    ,sbaa__RecordField__c = 'Quote__c' + counter
                ));
        }
        counter = 0;
        insert approval;
        return approval;
    }

    /**
     * Creates a test User.
     */
    public static User createUsers(String email, String firstName, String lastName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Username = email,
            Alias = firstName.substring(0, 1) + lastName,
            CommunityNickname = firstName + lastName,
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        return u;
    }

    /**
     * Creates a Quote and associated Approval record. 
     */       
    
    public static sbaa__Approval__c createQuoteAndApproval(Opportunity opportunity, String quoteName, Id accountId, String status, Id approverId, Id groupId, String comments) {
        SBQQ__Quote__c quote = createQuote(opportunity, quoteName, accountId);
        Group gAssignedGroup = [SELECT ID FROM group WHERE DeveloperName = 'Pricing_SW_Level_3_Approvers'];
        sbaa__Approval__c approval = new sbaa__Approval__c(
            Quote__c = quote.Id,
            sbaa__Status__c = status,
            sbaa__AssignedTo__c = approverId, // Assign the User ID directly
            sbaa__AssignedGroupId__c = gAssignedGroup.Id,
            sbaa__ApprovalStep__c = 1, 
            sbaa__RecordField__c = 'Quote__c'
        );
    
        if (comments != null) {
            approval.sbaa__CommentsLong__c = comments;
        }
    
        insert approval;
            // Query the approval again to populate the sbaa__AssignedTo__r relationship
        approval = [SELECT sbaa__AssignedTo__r.Email FROM sbaa__Approval__c WHERE Id = :approval.Id LIMIT 1];
        

        // Query the approval again to ensure relationship fields are populated
        approval = [SELECT sbaa__AssignedGroupId__c FROM sbaa__Approval__c WHERE Id = :approval.Id LIMIT 1];
        
        /*// Safely access and debug the Group Id
        if (approval.sbaa__AssignedTo__r != null) {
            System.debug('Assigned Approver Group Id: ' + approval.sbaa__AssignedGroupId__c);
        } else {
            System.debug('AssignedTo relationship is null.');
        }*/
    
        return approval;
    }

    public static SBQQ__QuoteLine__c createQuoteLines(SBQQ__Quote__c testQuote) {
        Product2 testProduct = createProduct();
        RecordType quoteLineRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'SBQQ__QuoteLine__c' AND DeveloperName = 'Software_Services_Quote_Line' LIMIT 1];
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            RecordTypeId = quoteLineRecordType.Id,
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProduct.Id,
            
            SBQQ__ListPrice__c = 0 ,
            Pricing_Quote_Program_Nm__c='Software & Services'
        );
        insert quoteLine;
        return quoteLine;
    }

    public static Product2 createProduct(){
        // Create a test product for the test with the name "Intel Trust Authority - Custom"
        Product2 p = new Product2();
        p.Name = Label.Pricing_SW_ProductIntelTrustAuthorityCustom;
        p.Core_Product_Org__c = 'Sales';
        p.Core_Product_Type__c = 'Processors';
        p.Core_Sales_Visible_Flag__c = true;
        p.Core_Hierarchy_ID__c = '43';
        p.Core_Group_Code_Short_Name__c = 'DCG~DCAI';
        p.IsActive = true;
        insert p;
        return p;
    }

    public static Account createAccountSW(){
        Account acc = new Account();
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        acc.Name = 'Test Account'+ math.random();
        acc.Core_Account_Type__c = 'Distributor;End Customer';//added
        acc.Industry = 'Banking';
        acc.BillingCity = 'Texas';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'G-2101'; 
        acc.Core_Sales_Groups__c = 'APJ Partner Holding'; 
        acc.Core_Geo__c = 'APJ';
        acc.Core_Sub_Geo__c = 'IJKK';
        acc.Core_PSG_Account__c = true;
        acc.Core_Account_Tier__c ='PSG-Tier 4';
        acc.Core_Partner_Alliance_Program__c ='PSG Demand Creation - PSG';
        acc.Core_Account_BU_Focus__c='PSG-CM;PSG-DISTI';
        
        insert acc;
        System.assert(acc.Id!=null,'New Account created sucessfully');
        return acc;   
    }

    public static Contact createContactSW(Id accId){
        Contact con = new Contact();
        Account acc = new Account();
        acc.Id = accId;
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
        
        con.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId();
        con.FirstName = 'FirstName'+System.now();
        con.LastName = 'LastName';
        con.Email = 'FirstName@intel.com';
        con.AccountId = acc.Id;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry='USA';
        insert con;
        System.assert(con.Id!=null,'New Account created sucessfully');
        return con;
    }

    public static Account createDirectAccountSW(){
        Account directacc = new Account();
        directacc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();      
        directacc.Name = 'Test Account';
        directacc.Core_Account_Type__c = 'Distributor;End Customer';//added
        directacc.Industry = 'Banking';
        directacc.BillingCity = 'Texas';
        directacc.BillingCountry = 'USA';
        directacc.BillingStreet = 'G-2101'; 
        directacc.Core_Sales_Groups__c = 'PRC Sales Group';
        directacc.Core_Geo__c = 'APJ';
        directacc.Core_Sub_Geo__c = 'IJKK';
        directacc.Core_PSG_Account__c = true;
        directacc.Core_Account_Tier__c ='PSG-Tier 4';
        directacc.Core_Direct_Account_Type_Nm__c = 'End Customer Parent';
        directacc.Core_Is_Pricing_Parent_ChkBox__c=true;
        
        insert directacc;
        System.assert(directacc.Id!=null,'New Account created sucessfully');
        return directacc;   
    }

    public static List<User> createBOUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
            UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.PSG_Quote_BO_PermissionSet];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        } 
        
        List<User> lstUser = new List<User>();
        User u = [select id from user where id =: UserInfo.getUserId()];
        System.runAs(u){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user13', Email= 'firstNameBO257@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles',UserRoleId = role.Id, UserName = 'FirstNameBO257@exampleTC.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);                
            }
            
            insert lstUser;
            System.assert(lstUser[0]!=null,'BM1 user is created sucessfully');
            PermissionSetLicense psl=[SELECT Id,DeveloperName from PermissionSetLicense WHERE DeveloperName='SalesforceCPQ_CPQAAPerm' LIMIT 1];
            PermissionSetLicenseAssign psla=new PermissionSetLicenseAssign();
            psla.AssigneeId = lstUser[0].Id;
            psla.PermissionSetLicenseId = psl.Id;
            insert psla;
            list<user> u1 = [Select Id from User where Id =: lstUser];
            list<PackageLicense> pl = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'sbaa' or NamespacePrefix = 'SBQQ']; 
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[0].id);
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[1].id);
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();   
            for(PermissionSet ps : [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User OR Name=:Label.PSG_CPQ_AA_License OR Name = 'AdvancedApprovalsUser' Limit 3]){
                permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps.Id));
            }
            permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps1.Id));
            insert permissionList;
        }  
        return lstUser;
    }

    public static List<SBQQ__Quote__c> createQuoteSW(Id accId,Id conId, Integer numberOfQuotes){
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        pricebook2 pb = createPriceBook('Intel processor');  
        List<User> uL = createSOSUser();
        Opportunity opp = createOpportunity(accId);
        List<String> status = new List<String>();
        status.add('New');
        status.add('Approved');
        status.add('Rejected');
        status.add('In Progress');
        status.add('Pending');
        status.add('Recalled');
        status.add('In Review');
        for(Integer i=0;i<numberOfQuotes;i++){ 
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_New');
            quote.SBQQ__Account__c = accId;
            quote.SBQQ__PrimaryContact__c = conId;
            quote.core_cpq_price_book_nm__c =  pb.Id;
            quote.core_cpq_revision_nbr__c =  1;
            if(numberOfQuotes == 1){
                quote.SBQQ__Status__c = 'Approved';
            }else{
                quote.SBQQ__Status__c = status[i];
            }
            quote.core_cpq_next_approver_nm__c = uL[0].id;
            quote.core_cpq_assigned_to_nm__c = uL[0].id;
            quote.core_cpq_assigned_by_nm__c = uL[0].id;
            quote.core_cpq_assigned_on__c = System.now();
            quote.SBQQ__Distributor__c = accId;
            quote.core_cpq_quote_type_nm__c = 'Design Win';
            quote.core_cpq_end_customer_country_disty_nm__c = 'India';
            quote.core_cpq_active_cb__c = true;
            quote.core_cpq_business_unit_nm__c = 'Military';
            quote.core_cpq_quote_owner_disty_txt__c = 'SOS Korea';
            quote.core_cpq_account_tier__c = 'PSG-Tier 4';
            quote.core_cpq_first_bm_approver__c = uL[0].id;
            quote.core_cpq_revision_nbr__c = 1;
            quote.SBQQ__StartDate__c=Date.today();
            quote.SBQQ__EndDate__c= quote.SBQQ__StartDate__c.addMonths(4);
            quote.core_cpq_price_eligibility_date_dt__c=Date.today();
            quote.core_cpq_pricing_end_date_dt__c=Date.today();
            quote.core_cpq_pricing_start_date_dt__c=Date.today();
            quote.core_cpq_review_date_dt__c=Date.today();
            quote.core_cpq_reviewer__c = uL[0].id;
            quote.core_cpq_Process_flag__c = false;
            lstQuote.add(quote);
            
        }
        insert lstQuote;
        System.assert(lstQuote[0].Id!=null,'Quote List added sucessfully');
        return lstQuote;
        
    }
     

    public static List<SBQQ__QuoteLine__c> createQuoteLinesSW(Id quoteId, Integer numquoteLines){
        List<Product2> products = new List<Product2>();
        for(Integer i=0;i<numquoteLines;i++) {
            Product2 prod = new Product2(Name='TestProduct1'+ i,
                                         Core_Product_Org__c = 'Sales',
                                         Core_Item_Signal_Cd__c='E4',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG',
                                         Core_Item_Orderable_Ind__c = true,
                                         Core_Item_Quotable_Ind__c=true,
                                         Core_OPN__c = 'OPN'+i,
                                         Core_Item_Class_Nm__c='BD',
                                         Core_BU_Operation_Code__c='KP',
                                         IsActive = true);
            products.add(prod);
        }
        insert products;
        for(Product2 prod1 : products){
            prod1.Core_Sales_Visible_Flag__c=true;
            prod1.Core_Item_Orderable_Ind__c=true;
            prod1.Core_Item_Quotable_Ind__c=true;
            prod1.IsActive=true;
        }
        update products;
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        for(Product2 prod1 : products){
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId=PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'PSG_Quote_Line_Create');
            quoteLine.SBQQ__Product__c = prod1.Id;
            quoteLine.SBQQ__Quote__c = quoteId;
            quoteLine.price_suggested_resale_amt__c = 100;
            quoteLine.core_cpq_previous_distributor_margin_pct__c = 10;
            quoteLine.core_cpq_quote_line_type_txt__c = 'Flat';
            quoteLine.core_cpq_requested_qty__c = 10;
            quoteLine.SBQQ__Quantity__c = null;
            quoteLine.core_cpq_lower_bound_qty_qty__c = 5;
            quoteLine.core_cpq_upper_bound_qty_nbr__c = 25;
            quoteLine.price_disty_cost_nbr__c = 100;
            quoteLine.core_cpq_internal_comments_txt__c = 'Hello';
            quoteLine.core_cpq_comments_for_customer_txt__c = 'Hi';
            quoteLine.core_cpq_comments_for_disty_txt__c = 'Yes';
            quoteLine.price_requested_resale_amt__c = 80;
            quoteLine.price_suggested_resale_amt__c = 110;
            quoteLine.price_std_fwd_cost_amt__c = 200;
            quoteLine.price_goal_price_amt__c = 60;
            quoteLine.core_cpq_years_nbr__c  = null;
            quoteLine.core_cpq_distributor_margin_pct__c = 10;
            quoteLine.core_cpq_altera_reg_txt__c = 'ABCDE';
            quoteLine.core_cpq_competitor_price_amt__c = 75;
            quoteLine.core_cpq_competitor_part_txt__c = 'Test';
            quoteLine.core_cpq_margin_exception_txt__c = 'eASIC';
            quoteLine.price_msvp_l1_amt__c = 20;
            quoteLine.price_msvp_l2_amt__c = 25;
            quoteLine.SBQQ__ListPrice__c = 55;
            quoteLine.core_cpq_reg_status__c = 'Pending';
            quoteLine.core_cpq_product_nm__c = prod1.Id;
            quoteLine.core_cpq_quantity_nm__c =1234;
            quoteLine.core_cpq_gp_msvpl2_nm__c = 35;
            quoteLine.core_cpq_opn__c = 'Abc123';
            quoteLine.core_cpq_production_dt__c = System.today();
            quoteLine.Pricing_Quote_Program_Nm__c = 'PSG';
            quoteLine.core_cpq_pricing_start_date_dt__c = System.today() + 5;
            quoteLine.core_cpq_dollar_change_flag_cb__c = false;
            quoteLine.price_brokencost_amt__c = 10;
            quoteLine.price_std_fwd_cost_amt__c = 21;
            quoteLines.add(quoteLine);
        }
        
        insert quoteLines;
        System.assert(quoteLines[0]!=null,'Quote Lines are created sucessfully');
        return quoteLines;
    }
    
    

    public static List<sbaa__Approval__c> createApproval(Id quoteId){
        List<User> uL1 = createBMUser();
        //Added By Bishal Singh 
        List<core_cpq_bm_level__c> bmlist = new List<core_cpq_bm_level__c>();
        core_cpq_bm_level__c bmrecc = new core_cpq_bm_level__c();
        bmrecc.core_cpq_bm_level_nm__c = 'Level 5';
        bmrecc.core_cpq_bm_name__c = uL1[0].Id ;
        bmlist.add(bmrecc);
        insert bmlist;
        
        Group grp = new Group();
        grp.name = 'Test Group1';
        grp.Type = 'Regular'; 
        System.runAs(uL1[0]){
            Insert grp; 
        }
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = uL1[0].Id;
        grpMem1.GroupId = grp.Id;
        
        System.runAs(uL1[0]){
            Insert grpMem1;
        }
        
        Group subGrp  = new Group();
        subGrp.name = 'Test Group2';
        subGrp.Type = 'Regular'; 
        System.runAs(uL1[0]){
            Insert subGrp; 
        }
        GroupMember grpMem2 = new GroupMember();
        grpMem2.UserOrGroupId = subGrp.Id;
        grpMem2.GroupId = grp.Id;
        System.runAs(uL1[0]){
            Insert grpMem2;  
        }
        
        
        
        List<sbaa__Approver__c> approverList = new List<sbaa__Approver__c>();
        approverList.add(new sbaa__Approver__c(Name = 'test approver',sbaa__Unanimous__c=true,sbaa__User__c = uL1[0].Id,
                                               sbaa__GroupId__c = grp.Id));
        insert approverList;
        System.assert( approverList[0].Name!=null,'Approval is created sucessfully');
        
        List<sbaa__ApprovalRule__c> approverRuleList = new List<sbaa__ApprovalRule__c>();
        approverRuleList.add(new sbaa__ApprovalRule__c(Name = 'test approver rule', sbaa__TargetObject__c = 'SBQQ__Quote__c'));
        insert approverRuleList;
        
        //Added by Bishal Singh
        List<sbaa__ApprovalChain__c> approverChainList = new List<sbaa__ApprovalChain__c>();
        approverChainList.add(new sbaa__ApprovalChain__c(Name = 'BM Chain', sbaa__TargetObject__c = 'SBQQ__Quote__c'));
        insert approverChainList;
        
        List<sbaa__Approval__c> approvalList = new List<sbaa__Approval__c>();
        
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c();
        quoteRec.core_cpq_first_bm_approver__c = uL1[0].Id;
        
        sbaa__Approval__c appr1 = new sbaa__Approval__c(sbaa__RecordField__c = 'test',sbaa__ApprovalStep__c=1,sbaa__Status__c ='Requested', 
                                                        sbaa__AssignedTo__c = uL1[0].Id, Quote__c = quoteId, sbaa__Approver__c = approverList[0].Id, sbaa__Rule__c = approverRuleList[0].Id,
                                                        sbaa__DelegatedApprover__c = approverList[0].Id,/* Added By Bishal Singh*/ sbaa__ApprovalChain__c = approverChainList[0].Id);
        approvalList.add(appr1);
        
        sbaa__Approval__c appr2 = new sbaa__Approval__c(sbaa__RecordField__c = 'test2',sbaa__ApprovalStep__c=1,sbaa__Status__c ='Requested', 
                                                        sbaa__AssignedTo__c = uL1[0].Id, Quote__c = quoteId, sbaa__Approver__c = approverList[0].Id, sbaa__Rule__c = approverRuleList[0].Id,
                                                        sbaa__DelegatedApprover__c = approverList[0].Id,/* Added By Bishal Singh*/ sbaa__ApprovalChain__c = approverChainList[0].Id);
        approvalList.add(appr2);
        insert approvalList;
        
        
        approvalList[0].sbaa__Status__c = 'Approved';
        approvalList[0].sbaa__ApprovedBy__c=uL1[0].id;
        update approvalList;
        
        return approvalList;
        
    }
    
    public static List<sbaa__Approver__c> createApprover(Id userid){
        List<sbaa__Approver__c> lstapprover = new List<sbaa__Approver__c>(); 
        List<User> uL = createBMUser(); 
        sbaa__Approver__c approver = new sbaa__Approver__c();
        approver.Name = 'Emea Approver';
        approver.sbaa__User__c = userid; 
        lstapprover.add(approver);
        System.runAs(uL[0]){
            Insert lstapprover; 
        }
        return lstapprover;
    }

     public static List<User> createBMUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
            UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.PSG_Quote_BM_PermissionSet];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        } 
        
        List<User> lstUser = new List<User>();
        User u = [select id from user where id =: UserInfo.getUserId()];
        System.runAs(u){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user13', Email= 'firstNameBM135@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles',UserRoleId = role.Id, UserName = 'FirstNameBMs' + String.valueOf(Math.random())+'@exampleTC.com');
                
                lstUser.add(u1);                
            }
            
            insert lstUser;
            System.assert(lstUser[0]!=null,'BM1 user is created sucessfully');
            PermissionSetLicense psl=[SELECT Id,DeveloperName from PermissionSetLicense WHERE DeveloperName='SalesforceCPQ_CPQAAPerm' LIMIT 1];
            PermissionSetLicenseAssign psla=new PermissionSetLicenseAssign();
            psla.AssigneeId = lstUser[0].Id;
            psla.PermissionSetLicenseId = psl.Id;
            insert psla;
            list<user> u1 = [Select Id from User where Id =: lstUser];
            list<PackageLicense> pl = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'sbaa' or NamespacePrefix = 'SBQQ']; 
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[0].id);
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[1].id);
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(PermissionSet ps : [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User OR Name=:Label.PSG_CPQ_AA_License  OR Name = 'AdvancedApprovalsUser' Limit 3]){
                permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps.Id));
            }
            permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps1.Id));
            insert permissionList;
        }  
        return lstUser;
    }
    
    public static Opportunity createOpportunity(Id accId){
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Id DesignOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Opportunity opp = new Opportunity();
        opp.name = 'test opp'; 
        opp.RecordTypeId = DesignOppRecTypeId;
        opp.AccountId = accId;
        opp.StageName = 'Qualify';
        opp.CloseDate = System.today();
        opp.Opportunity_Focus__c = 'Core';
        opp.Core_Technical_Owner__c = userInfo.getUserId();
        opp.Core_Opportunity_Type__c ='Design: Original';
        insert opp;
        System.assert(opp.Id!=null,' opportunity inserted sucessfully');
        return opp;
    }

    public static List<User> createSOSUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
            UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.PSG_Quote_SOS_PermissionSet];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        } 
        
        List<User> lstUser = new List<User>();
        User u = [select id from user where id =: UserInfo.getUserId() limit 1];
        System.runAs(u){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user13', Email= 'firstNameSOS9562@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles',UserRoleId = role.Id, UserName = 'FirstNameSOS9565Q@exampleTC.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);                
            }
            
            insert lstUser;
            System.assert(lstUser[0]!=null,'BM1 user is created sucessfully');
            PermissionSetLicense psl=[SELECT Id,DeveloperName from PermissionSetLicense WHERE DeveloperName='SalesforceCPQ_CPQAAPerm' LIMIT 1];
            PermissionSetLicenseAssign psla=new PermissionSetLicenseAssign();
            psla.AssigneeId = lstUser[0].Id;
            psla.PermissionSetLicenseId = psl.Id;
            insert psla;
            list<user> u1 = [Select Id from User where Id =: lstUser];
            list<PackageLicense> pl = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'sbaa' or NamespacePrefix = 'SBQQ']; 
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[0].id);
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[1].id);
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(PermissionSet ps :[SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User OR Name=:Label.PSG_CPQ_AA_License OR Name = 'AdvancedApprovalsUser' Limit 3]){
                permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps.Id));
            }
            permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps1.Id));
            insert permissionList;
        }  
        return lstUser;
    }
    
    public static PriceBook2 createPriceBook(String name){
        
        PriceBook2 p = new PriceBook2(
            name = name,
            core_cpq_program__c ='PSG',
            isActive=true
        );
        insert p;
        System.assert(p.Id!=null,'PriceBook Created sucessfully');
        return p;
    }
}