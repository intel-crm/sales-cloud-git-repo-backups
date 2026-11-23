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
}