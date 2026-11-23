@isTest
private class Core_Test_Utility_Test
{
    static testMethod void coverageTest()
    {
        // Get a System Admin User
        User sysAdmin = Core_Test_Utility.systemAdminUser;
        
        
        // Accounts
        List<Account> lstAccount = new List<Account>();
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        for(Account act : Core_Test_Utility.createAccount(10)){
            act.recordTypeId = accountRecordTypeIntel;
            lstAccount.add(act);
        }
        
        
        // Accounts  - duplicated functionality
        Core_Test_Utility.Core_Account(10);
        
        
        // ChangeRequests
        Core_Test_Utility.createChangeRequest(lstAccount);
        
        
        // Leads
        Core_Test_Utility.createLead(10);
        
        // Leads - duplicated functionality
        Core_Test_Utility.Core_Lead(10);
        
        
        // Tasks
        Core_Test_Utility.createTask(10);
        
        // Events
        Core_Test_Utility.createEvent(10);
        
        // Opportunities
        List <Opportunity> lstOpportunity = Core_Test_Utility.createOpportunity(10);
        
        // Opporunties - duplicated functionality
        Core_Test_Utility.Core_Opportunity(10);
        
        // Products
        List<Product2> lstProducts = Core_Test_Utility.createProduct(10);
        
        // Price Book Entry
        List<PricebookEntry> lstPriceBookEntry = Core_Test_Utility.createPriceBookEntry(10, lstProducts, Test.getStandardPricebookId());
        
        // Opportunity Products
        Core_Test_Utility.createOpportunityLineItems(10, lstPriceBookEntry, lstOpportunity.get(0));
        
        // Price Book
        Core_Test_Utility.createPriceBook(10);
        
        // Contacts
        Core_Test_Utility.createContacts(10);
        
        // User
        Core_Test_Utility.Core_User(10);
        
        // Core_Country_Reference__c
        Core_Test_Utility.Core_CountryState(10);
        
        // Core_TriggerExecution
        Core_Test_Utility.Core_TriggerExecution(10);
        
        // Core_Feature__c
        Core_Test_Utility.CreateFeature(10);
        
        // Core_Feature_Header__c
        Core_Test_Utility.CreateFeatureHeader(10);
        
        // Core_Feature_Set__c
        Core_Test_Utility.CreateFeatureSet(10);
        
        // Core_Opportunity_Features__c
        Core_Test_Utility.CreateOpportunityFeature(10);
        
        // Core_Channel_Membership
        Core_Test_Utility.Core_Channel_Membership(10);
        
        List<Core_Channel_Salesout__c> lstCS = Core_Test_Utility.Core_Channel_Salesout(10);
        Core_Test_Utility.ChannelDataSalesoutRecord cdsr = new Core_Test_Utility.ChannelDataSalesoutRecord(lstCS[0]);
        
        String   str;
        Integer  i;
        Decimal  num;
        DateTime dt;
        
        str = cdsr.salesType;
        i   = cdsr.invoiceWW;
        i   = cdsr.invoiceQuarter;
        str = cdsr.invoiceQuarterText;
        str = cdsr.rptParentFormFactor;
        str = cdsr.businessID;
        str = cdsr.businessRegion;
        str = cdsr.businessGeo;
        str = cdsr.productLevel1;
        str = cdsr.productLevel2;
        str = cdsr.productLevel4;
        i   = cdsr.component;
        i   = cdsr.componentUnits;
        str = cdsr.distributorName;
        str = cdsr.processorNbr;
        
        Core_Test_Utility.ChannelDataSalesoutSummaryRecord cssr = new Core_Test_Utility.ChannelDataSalesoutSummaryRecord('Branded', 201501, '2015 Q1', 'P1', 20, 200);
        str = cssr.salesType;
        num = cssr.invoiceQuarter;
        str = cssr.invoiceQuarterText;
        str = cssr.productLevel1;
        num = cssr.component;
        num = cssr.componentUnits;
        
        Core_Test_Utility.ChannelDataMembershipRecord csmsr = new Core_Test_Utility.ChannelDataMembershipRecord(Core_Test_Utility.Core_Channel_Membership(1)[0]);
        str = csmsr.currentMembershipTier;
        str = csmsr.businessID;
        dt  = csmsr.renewalTimestamp;
        str = csmsr.renewalStatus;
        str = csmsr.requestedTierStatus;
        dt  = csmsr.statusDate;
        i   = csmsr.pointsDuetoExpireNextQtr;
        i   = csmsr.pointsExpiredinCurrentQtr;
        i   = csmsr.salesNeededtoGold;
        i   = csmsr.salesNeededtoPlatinum;
        i   = csmsr.trainingNeededtoGold;
        i   = csmsr.trainingNeededtoPlatinum;
        
        // Core_Opportunity_Partner__c
        insert lstAccount;
        
        for (Opportunity opp : lstOpportunity)
            opp.AccountId = lstAccount[0].Id;
        
        insert lstOpportunity;
        Core_Test_Utility.createOpportunityPartners(10, lstOpportunity.get(0));
        
        // validateAccountAccess
        Set<Id> setAccount = new Set<Id>();
        for (Account acc : lstAccount)
            setAccount.add(acc.Id);
        Set<Id> validated = Core_Test_Utility.validateAccountAccess(sysAdmin.Id, setAccount);
        
        Core_Test_Utility.TargetAccountRecord tar = new Core_Test_Utility.TargetAccountRecord(lstAccount[0]);
        
        Group testGroup = new Group(Name='utilityTest', DeveloperName='utilityTest');
        insert testGroup;
        
        Core_Test_Utility.isUserGroupMember(null,        testGroup.DeveloperName);
        Core_Test_Utility.isUserGroupMember(sysAdmin.Id, null);
        Core_Test_Utility.isUserGroupMember(sysAdmin.Id, testGroup.DeveloperName);
        Core_Test_Utility.isUserGroupMember(sysAdmin.Id, 'GroupDoesntExist');
    }
}