/****************************************************************************************************
Apex Class Name:  Core_Test_Utility
Version     : 1.0 
Created Date: 06 OCT 2014
Function    : Utility Class for creating data ( used in test classes )
Modification Log :frecz
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             06/10/2014              Original Version
* Kunal Mehta              12/12/2014              Methods to create User and Custom Setting instances
* Brian Matthews           05/27/2015              Added systemAdminUser
* Nick Krisa               07/28/2015              Added createOpportunityPartners
* Kalpana Choudhary        09/04/2015              Added createCampaign 
* Brian Matthews           09/30/2015              Added validateAccountAccess
*                                                  Added checkRecordsEditAccess
* Venu Karumuru            02/10/2017              Removed the use of accountTier
*****************************************************************************************************/
public class Core_Test_Utility {

    public static final String sCompany        = 'test';
    public static final String sEmployee       = 'EMP';
    public static final String sFirstName      = 'test';
    public static final String sPriority       = 'high';
    public static final String sSubject        = 'Call';
    public static final String sStatus         = 'In Progress';
    public static final String sSystemAdminProfileName = 'System Administrator';
    public static final String sTeamMemberRole = 'Team Member (100%)';

    public static final Integer iDurationInMinutes    = 3000;
    public static final Integer iMaxValidationRecords = 200;

    public static List<AccountTeamMember> Core_AccountTeamMember(List<User> lstUser) {
        AccountTeamMember acctTeamMember;
        List<AccountTeamMember> lstAccountTeamMember = new List<AccountTeamMember>();
        
        for (User member : lstUser) {
            acctTeamMember = new AccountTeamMember();
            acctTeamMember.UserId = member.Id;
            acctTeamMember.TeamMemberRole = sTeamMemberRole;        
            lstAccountTeamMember.add(acctTeamMember);
        }
        return lstAccountTeamMember;
    }


    public static List<Core_Account_Team__c> Core_CustomAccountTeam(List<User> lstUser) {
        Core_Account_Team__c acctTeamMember;
        List<Core_Account_Team__c> lstCustomAccountTeamMember = new List<Core_Account_Team__c>();
        
        for (User member : lstUser) {
            acctTeamMember                     = new Core_Account_Team__c();
            acctTeamMember.Core_Team_member__c = member.Id;
            acctTeamMember.Core_Team_Role__c   = sTeamMemberRole;        
            lstCustomAccountTeamMember.add(acctTeamMember);
        }
        return lstCustomAccountTeamMember;
    }


    // Carrying the data as fields assigned from the Account sObject is optimal because there ARE subqueries
    // on the account sObject that can have thousands of records.
    //
    public class TargetAccountRecord implements Comparable
    {
        public ID     Id                   { get; set; }
        public String name                 { get; set; }
        public String firstName            { get; set; }
        public String lastName             { get; set; }
        public String accountType          { get; set; }
        public String salesSegment         { get; set; }
        public String accountTier          { get; set; }
        public String industry             { get; set; }
        public Integer components          { get; set; }
        public Integer componentsUnitCosts { get; set; }
        public String membershipTier       { get; set; }

        public boolean isSelected          { get; set; }
        public String  selectedComponent   { get; set; }
        public String  sortOrder           { get; set; }

        // Overload the constructor #1           
        public TargetAccountRecord(Account acc, String pSelectedComponent, String pSortOrder) {         
            configureProperties(acc);

            // Override the defaults from configureProperties
            selectedComponent = pSelectedComponent;
            sortOrder         = pSortOrder;
        }
 
        // Overload the constructor #2           
        public TargetAccountRecord(Account acc) {         
            configureProperties(acc);
        }
        
        
        private void configureProperties(Account acc) {
            Id           = acc.Id;
            name         = acc.name;
            firstName    = acc.owner.firstName;
            lastName     = acc.owner.lastName;
            accountType  = acc.Core_Account_Type__c;
            salesSegment = acc.Core_Sales_Segment__c;
            // This field has been converted from single picklist to multi-picklist as part of PSG onboard
            // accountTier  = acc.Core_Account_Tier__c; // Commented this to support the conversion
            industry     = acc.industry;

            isSelected        = false;
            selectedComponent = 'components';
            sortOrder         = Core_SortedGrid_ColumnHeader.ASCENDING_TEXT;
            
            components          = 0; 
            componentsUnitCosts = 0;
            for(Core_Channel_Salesout__c ccs : acc.Core_Account_Channel_Sales_Out__r){
                components          = components + Integer.valueof(ccs.Core_Component_Units__c);
                componentsUnitCosts = componentsUnitCosts + Integer.valueof(ccs.Core_Component__c);
            }

            if (acc.Channel_Memberships__r != NULL && acc.Channel_Memberships__r.size() > 0)
                membershipTier  = acc.Channel_Memberships__r[0].Core_Current_Membership_Tier__c;
            else        
                membershipTier = '';
        }
        
        
        public Integer compareTo(Object compareTo) 
        {      
            TargetAccountRecord rec = (TargetAccountRecord)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer greaterValue;
            Integer lesserValue;
            
            if(sortOrder == Core_SortedGrid_ColumnHeader.ASCENDING_TEXT) {
                greaterValue = 1;
                lesserValue  = -1;
            } else {
                greaterValue = -1;
                lesserValue  = 1;
            }    
            
            if (rec.selectedComponent == 'components') {
                if (components > rec.components) 
                    return greaterValue;
                    
                if (components < rec.components) 
                    return lesserValue;

                return 0;                   
            } 
            
            if (rec.Selectedcomponent == 'componentsUnitCosts') {
                if (componentsUnitCosts > rec.componentsUnitCosts) 
                    return greaterValue;
                    
                if (componentsUnitCosts < rec.componentsUnitCosts)
                    return lesserValue;

                return 0;                
            } 
            
            if (rec.Selectedcomponent == 'accountName') {
                if (name > rec.name) 
                    return greaterValue;
                    
                if (name < rec.name)
                    return lesserValue;

                return 0;                
            } 
            
            if (rec.Selectedcomponent == 'membershipTier') {
                if (membershipTier > rec.membershipTier) 
                    return greaterValue;
                    
                if (membershipTier < rec.membershipTier)
                    return lesserValue;

                return 0;                
            }   
            
            return 0;    
        }                
    }


    // There is NO sObject for Salesout summary
    //
    public class ChannelDataSalesoutSummaryRecord {
        public String  salesType           { get; set; }
        public Decimal invoiceQuarter      { get; set; }
        public String  invoiceQuarterText  { get; set; }
        public String  productLevel1       { get; set; }
        public Decimal component           { get; set; }
        public Decimal componentUnits      { get; set; }
        
        public ChannelDataSalesoutSummaryRecord (String pSalesType, Decimal pInvoiceQuarter, String pInvoiceQuarterText, String pProductLevel1, Decimal pComponent, Decimal pComponentUnits) {
            salesType          = pSalesType;
            invoiceQuarter     = pInvoiceQuarter;
            invoiceQuarterText = pInvoiceQuarterText;
            productLevel1      = pProductLevel1;
            component          = pComponent;
            componentUnits     = pComponentUnits;
        }
    } 


    // Carrying the data from the sObject is optimal because there are no subqueries
    //
    public class ChannelDataSalesoutRecord {
        private Core_Channel_Salesout__c cdsInstance; 

        public String  salesType           { get { return cdsInstance.Core_Sales_Type__c;} }
        public Integer invoiceWW           { get { return Integer.valueOf(cdsInstance.Core_Invoice_WW__c);} }
        public Integer invoiceQuarter      { get { return Integer.valueOf(cdsInstance.Core_Invoice_Quarter__c);} }
        public String  invoiceQuarterText  { get { return cdsInstance.Core_Invoice_Quarter_Text__c;} }
        public String  rptParentFormFactor { get { return cdsInstance.Core_Rpt_Parent_Form_Factor__c;} }
        public String  businessID          { get { return cdsInstance.Core_Business_ID__c;} }
        public String  businessRegion      { get { return cdsInstance.Core_Business_Region__c;} }
        public String  businessGeo         { get { return cdsInstance.Core_Business_Geo__c;} }
        public String  productLevel1       { get { return cdsInstance.Core_Product_Level_1__c;} }
        public String  productLevel2       { get { return cdsInstance.Core_Product_Level_2__c;} }
        public String  productLevel4       { get { return cdsInstance.Core_Product_Level_4__c;} }
        public Integer component           { get { return Integer.valueOf(cdsInstance.Core_Component__c);} }
        public Integer componentUnits      { get { return Integer.valueOf(cdsInstance.Core_Component_Units__c);} }
        public String  distributorName     { get { return cdsInstance.Core_Distributor_Name__c;} }
        public String  processorNbr        { get { return cdsInstance.Core_Processor_Nbr__c;} }
        
        public ChannelDataSalesoutRecord (Core_Channel_Salesout__c css) {
            cdsInstance = css;
        }
    } 


    public class ChannelDataMembershipRecord {
        private Core_Channel_Membership__c cmInstance;
         
        public String   currentMembershipTier     { get { return cmInstance.Core_Current_Membership_Tier__c;} }
        public String   businessID                { get { return cmInstance.Core_Business_ID__c;} }
        public DateTime renewalTimestamp          { get { return DateTime.valueOf(cmInstance.Core_Renewal_Timestamp__c);} }
        public String   renewalStatus             { get { return cmInstance.Core_Renewal_Status__c;} }
        public String   requestedTierStatus       { get { return cmInstance.Core_Requested_Tier_Status__c;} }
        public DateTime statusDate                { get { return DateTime.valueOf(cmInstance.Core_Status_Date__c);} }
        public Integer  pointsDuetoExpireNextQtr  { get { return Integer.valueOf(cmInstance.Core_Points_Due_to_Expire_Next_Qtr__c);} }
        public Integer  pointsExpiredinCurrentQtr { get { return Integer.valueOf(cmInstance.Core_Points_Expired_in_Current_Qtr__c);} }
        public Integer  salesNeededtoGold         { get { return Integer.valueOf(cmInstance.Core_Sales_Needed_to_Gold__c);} }
        public Integer  salesNeededtoPlatinum     { get { return Integer.valueOf(cmInstance.Core_Sales_Needed_to_Platinum__c);} }
        public Integer  trainingNeededtoGold      { get { return Integer.valueOf(cmInstance.Core_Training_Needed_to_Gold__c);} }
        public Integer  trainingNeededtoPlatinum  { get { return Integer.valueOf(cmInstance.Core_Training_Needed_to_Platinum__c);} }

        public ChannelDataMembershipRecord(Core_Channel_Membership__c ccm) {
            cmInstance = ccm;
        }
    }


    public class ChannelDataTrainingRecord {
        private Core_Training__c ctInstance;
    
        public String   firstName            { get { return ctInstance.Core_First_Name__c;} }
        public String   lastName             { get { return ctInstance.Core_Last_Name__c;} }
        public String   roleCode             { get { return ctInstance.Core_Role_Code__c;} }
        public Datetime trainingCompleteDate { get { return ctInstance.Core_Training_Complete_Date__c;} }
        public Integer  trainingCredits      { get { return Integer.valueOf(ctInstance.Core_Training_Credits__c);} }
        public Integer  trainingID           { get { return Integer.valueOf(ctInstance.Core_Training_ID__c);} }
        public String   trainingTitle        { get { return ctInstance.Core_Training_Title__c;} }

        public ChannelDataTrainingRecord(Core_Training__c ct) {
            ctInstance = ct;
        }
    }


    public class ChannelDataPointsRecord {
        private Core_Liability_Points__c clpInstance;
    
        public Integer totalAvailablePoints { get { return Integer.valueOf(clpInstance.Core_Total_Available_Points__c);} }
        public Integer totalBalancePoints   { get { return Integer.valueOf(clpInstance.Core_Total_Balance_Points__c);} }
        public Integer totalExpiredPoints   { get { return Integer.valueOf(clpInstance.Core_Total_Expired_Points__c);} }
        public Integer totalEarnedPoints    { get { return Integer.valueOf(clpInstance.Core_Total_Earned_Points__c);} }
        public Integer totalRedeemedPoints  { get { return Integer.valueOf(clpInstance.Core_Total_Redeemed_Points__c);} }
                             
        public ChannelDataPointsRecord(Core_Liability_Points__c clp) {
            clpInstance = clp;
        }
    }


    // Checking read/write access to an account will verify territory, account owner, 
    // and any other sharing rule granting account R/W access.
    //
    public static Set<Id> validateAccountAccess(Id userId, Set<Id> setAcctIds)
    {
        //System.debug('#80 setAcctIds.size(): ' + setAcctIds.size());    

        Set<Id> setTargetId     = new Set<Id>();        
        Set<Id> setValidationId = new Set<Id>();
        for (Id acctId : setAcctIds)
        {
            setValidationId.add(acctId);
            
            if (setValidationId.size() == iMaxValidationRecords)
            {
                checkRecordEditAccess(userId, setValidationId, setTargetId);                       
                setValidationId.clear();            
            }  
        }

        //System.debug('#81 setValidationId.size(): ' + setValidationId.size());    

        if (setValidationId.size() > 0)        
            checkRecordEditAccess(userId, setValidationId, setTargetId);       
        
        setAcctIds.removeAll(setTargetId);    
        System.debug('#82 setAcctIds.size(): ' + setAcctIds.size());    
        System.debug('#83 setTargetId.size(): ' + setTargetId.size());    
        
        // Qualify Team Members       
        List<AccountTeamMember> lstTeamMembers = [SELECT AccountId
                                                  FROM AccountTeamMember
                                                  WHERE AccountId IN :setAcctIds
                                                    AND UserId = :userId
                                                    AND isDeleted = False];

        //System.debug('#84 lstTeamMembers.size(): ' + lstTeamMembers.size());    
        
        for (AccountTeamMember atm : lstTeamMembers)
            setTargetId.add(atm.AccountId);                     

        //System.debug('#85 setTargetId.size(): ' + setTargetId.size());    

        return setTargetId;
    }


    public static void checkRecordEditAccess(Id userId, Set<Id> inputIds, Set<Id> validatedIds)
    {
        // Need to know if Accounts have Read-Write access.  This goes beyond what "WITH SHARING" offers.
        // UserRecordAccess Object only supports 200 records at a time.
        List<UserRecordAccess> lstAccountAccess = [SELECT RecordId 
                                                   FROM UserRecordAccess              
                                                   WHERE UserId = :userId
                                                     AND RecordId IN :inputIds
                                                     AND HasEditAccess = TRUE];
            
        // Rifle through the Account records and obtain their associated Opportunity_Partner Ids.    
        for (UserRecordAccess recordAccess : lstAccountAccess) // Account Ids
            validatedIds.add(recordAccess.RecordId);

    }


    public static Boolean isUserGroupMember(Id userId, String groupDeveloperName)
    {
        if (String.isblank(groupDeveloperName))
            return false;
        
        if (String.isblank(userId))
            return false;
        
        List<Group> smgGroups = [SELECT Id 
                                 FROM Group
                                 WHERE DeveloperName = :groupDeveloperName];    
            
        if (smgGroups.size() == 0)
            return false;
        
        Group smgGroup = smgGroups.get(0);
        
        Integer countGroupMember = [SELECT count()
                                    FROM GroupMember
                                    WHERE UserOrGroupId = :userId
                                      AND GroupId = :smgGroup.Id];
        
        return countGroupMember > 0;
    }


    /*
    * Finds a system Admin User who is not the current user, and return their User sObject
    */
    private static user pSystemAdminUser;    
    public static User systemAdminUser {    
        get {
        
            if (pSystemAdminUser == NULL)
            {
                List <User> usersList = new List <User>();
    
                // Fetching a different System admin
                usersList = [SELECT Id, Name 
                             FROM User 
                             WHERE isActive = TRUE 
                               AND Core_Employee_Type_Code__c = :sEmployee
                               AND Profile.Name = :sSystemAdminProfileName LIMIT 5];
                               
                for (User sysAdminUser: usersList) {
                    if (sysAdminUser.Id != UserInfo.getUserId())
                    {
                        pSystemAdminUser = sysAdminUser;
                        break;
                    }
                }
            }        
            
            System.Debug('System Admin User: ' + pSystemAdminUser.Name);
            return pSystemAdminUser;
        }        
    }


    public static List<Core_Channel_Salesout__c> Core_Channel_Salesout(Integer size) {
    
        String numberString; 
    
        List <Core_Channel_Salesout__c> lstSalesout = new List <Core_Channel_Salesout__c> ();
        For(integer i = 0; i <size; i++) {
            Core_Channel_Salesout__c cs = new Core_Channel_Salesout__c();
            cs.Core_Sales_Type__c             = 'Sales Type ' + i;
            cs.Core_Business_ID__c            = 'Business ID ' + i;            
            cs.Core_Rpt_Parent_Form_Factor__c = 'Form Factor ' + i;
            cs.Core_Rpt_Parent_Form_Factor__c = 'Product Platform ' + i;
            cs.Core_Product_Level_1__c        = 'Product Operation ' + i;
            cs.Core_Product_Level_2__c        = 'Product Family ' + i;
            cs.Core_Processor_Nbr__c          = 'Product Code ' + i;
            cs.Core_Component_Units__c        = i * 10;
            cs.Core_Component__c              = i * 100;
            cs.Core_Distributor_Name__c       = 'Distributor ' + i;

            numberString                      = '20150' + Math.mod(i, 4); 
            cs.Core_Invoice_Quarter__c        = Double.ValueOf(numberString);

            lstSalesout.add(cs);
        }
        return lstSalesout;
    }


    public static List<Core_Channel_Membership__c> Core_Channel_Membership(Integer size) {
    
        String numberString; 
        Integer iTier;
    
        List <Core_Channel_Membership__c> lstMembership = new List <Core_Channel_Membership__c> ();
        For(integer i = 0; i <size; i++) { 
            Core_Channel_Membership__c cm      = new Core_Channel_Membership__c();
            cm.Core_Business_ID__c             = '10000000' + i;
            
            iTier = Math.mod(i, 3);            
            if (iTier == 0)            
                cm.Core_Current_Membership_Tier__c = 'UNREGISTERED';
            else if (iTier == 1)                
                cm.Core_Current_Membership_Tier__c = 'GOLD';
            else
                cm.Core_Current_Membership_Tier__c = 'PLATINUM';

            cm.Core_Renewal_Status__c          = 'active';
            cm.Core_Status_Date__c             = DateTime.now();
            lstMembership.add(cm);
        }
        return lstMembership;
    }

    public static List <Account> createAccount(Integer size) {
        List <Account> accountList = new List <Account> ();
        For(integer i = 0; i <size; i++) {
            Account accountInstance = new Account();
            accountInstance.name = 'Test ' + (Math.random() * 1000);
            accountInstance.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test ' + (Math.random() * 1000);
            accountInstance.Core_Sales_Groups__c = 'Americas US Sales Group';
            accountInstance.Industry = 'Agriculture';
            accountInstance.Core_Sub_Industry__c = 'Crop Production';
            accountList.add(accountInstance);
        }
        return accountList;
    }

    public static List <Core_Change_Request__c> createChangeRequest(List <Account> accountList) {
        List <Core_Change_Request__c> changeRequestList = new List <Core_Change_Request__c> ();

        For(integer i = 0; i <accountList.size(); i++) {
            Core_Change_Request__c changeRequestInstance = new Core_Change_Request__c();
            //Added for covering all required fields -- Ashwin
            changeRequestInstance.Core_Account_Access_Level__c = 'Read';
            changeRequestInstance.Core_Account_Team_Role__c = 'Team Member';
            changeRequestInstance.Core_Case_Access_Level__c = 'Edit';
            changeRequestInstance.Core_Opportunity_Access_Level__c = 'Edit';
            changeRequestInstance.Core_Change_Details__c = 'testing';
            changeRequestInstance.Core_Account__c = accountList.get(i).Id;
            changeRequestInstance.Core_Status__c = 'Pending';
            changeRequestList.add(changeRequestInstance);
        }
        return changeRequestList;
    }

    public static List <Lead> createLead(Integer size) {
        List <Lead> leadList = new List <Lead> ();
        for (integer i = 0; i <size; i++) {
            Lead leadInstance = new Lead();
            leadInstance.FirstName = sFirstName;
            leadInstance.lastName = String.valueOf(i);
            leadInstance.Company = sCompany;
            leadInstance.CountryCode = 'USA';
            leadInstance.StateCode = 'AL';
            leadInstance.City = 'Alabama';
            leadInstance.Street = 'test';
            leadInstance.status = 'Sales Accepted Lead';
            leadInstance.leadSource = 'Email';
            leadInstance.email = 'test@' + i + '.com';
            leadInstance.Core_Last_Activity_Date__c = NULL;
            leadInstance.PostalCode = '577101';
            leadList.add(leadInstance);
        }
        return leadList;
    }
 
    public static List <Task> createTask(Integer size) {
        List <Task> taskList = new List <Task> ();
        for (integer i = 0; i <size; i++) {
            Task taskInstance = new Task();
            taskInstance.ActivityDate = System.Today().addDays(1);
            taskInstance.Priority = sPriority;
            taskInstance.status = sStatus;
            taskInstance.Subject = sSubject;
            taskList.add(taskInstance);

        }
        return taskList;
    }

    public static List <Event> createEvent(Integer size) {
        List <Event> eventList = new List <Event> ();
        for (integer i = 0; i <size; i++) {
            Event eventInstance = new Event();
            eventInstance.ActivityDateTime = System.Now().addHours(1);
            eventInstance.Subject = sSubject;
            eventInstance.DurationInMinutes = iDurationInMinutes;
            eventList.add(eventInstance);

        }
        return eventList;
    }

    public static List <Opportunity> createOpportunity(Integer size) {
        List <Opportunity> opportunityList = new List <Opportunity> ();
        for (integer i = 0; i <size; i++) {
            Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName = 'Qualify';
            opportunityInstance.Name = 'Test' + i;
            opportunityList.add(opportunityInstance);

        }
        return opportunityList;
    }


    public static List <Product2> createProduct(Integer size) {
        List <Product2> lstProducts = new List <Product2> ();
        product2 productInstance;
        for (integer i = 0; i <size; i++) {
            productInstance = new Product2();
            productInstance.name = 'Test 1';
            productInstance.Core_Division_Code__c = '000';
            productInstance.Core_Division_Code_Short_Name__c = 'BBB';
            productInstance.Core_Group_Code__c = '111';
            productInstance.Core_Group_Code_Short_Name__c = 'AAA';
            lstProducts.add(productInstance);
        }
        return lstProducts;
    }

    public static List <PricebookEntry> createPriceBookEntry(Integer size, List <Product2> lstProducts, Id priceBookInstanceId) {
        List <PricebookEntry> lstPriceBookEntry = new List <PricebookEntry> ();
        PricebookEntry priceBookEntryInstance;
        for (integer i = 0; i <size; i++) {
            priceBookEntryInstance = new PricebookEntry();
            priceBookEntryInstance.Product2Id = lstProducts.get(i).Id;
            priceBookEntryInstance.PriceBook2Id = priceBookInstanceId;
            priceBookEntryInstance.UnitPrice = 20.00;
            priceBookEntryInstance.UseStandardPrice = false;
            priceBookEntryInstance.isactive = true;
            lstPriceBookEntry.add(priceBookEntryInstance);
        }
        return lstPriceBookEntry;
    }

    public static List <OpportunityLineItem> createOpportunityLineItems(Integer size, List <PricebookEntry> lstPriceBookEntry, Opportunity opportunityInstance) {
        List <OpportunityLineItem> lstOpportunityLineItem = new List <OpportunityLineItem> ();
        OpportunityLineItem OpportunityLineItemInstance;
        for (integer i = 0; i <size; i++) {
            OpportunityLineItemInstance = new OpportunityLineItem();
            OpportunityLineItemInstance.OpportunityId = opportunityInstance.Id;
            OpportunityLineItemInstance.PricebookEntryId = lstPriceBookEntry.get(i).Id;
            OpportunityLineItemInstance.Quantity = 1;
            OpportunityLineItemInstance.UnitPrice = lstPriceBookEntry.get(i).UnitPrice;
            opportunityLineItemInstance.Core_Status__c = 'Pending';
            OpportunityLineItemInstance.Core_Division_Code__c = '11111';
            OpportunityLineItemInstance.Core_Group_Code__c = '55555';
            OpportunityLineItemInstance.Core_Division__c = 'Division 1';
            OpportunityLineItemInstance.Core_Group__c = 'Group 1';
            lstOpportunityLineItem.add(OpportunityLineItemInstance);

        }
        return lstOpportunityLineItem;
    }

    public static List <PriceBook2> createPriceBook(Integer size) {

        List <PriceBook2> lstPriceBook = new List <PriceBook2> ();
        PriceBook2 priceBookInstance;

        for (Integer i = 0; i <size; i++) {
            priceBookInstance = new PriceBook2();
            priceBookInstance.Name = 'Test' + i;
            priceBookInstance.Description = 'test';
            lstPriceBook.add(priceBookInstance);
        }

        return lstPriceBook;
    }


    public static List <Contact> createContacts(Integer size) {

        List <Contact> lstContacts = new List <Contact> ();
        Contact contactInstance;

        for (Integer i = 0; i <size; i++) {
            contactInstance = new Contact();
            contactInstance.FirstName = 'test';
            contactInstance.LastName = i + '';
            contactInstance.email = 'test@test' + i + '.com';
            lstContacts.add(contactInstance);
        }

        return lstContacts;
    }

    public static List <Account> Core_Account(Integer iNoOfRecords) {
        List <Account> lstAccount = new List <Account> {};
        for (integer iRecNo = 0; iRecNo <iNoOfRecords; iRecNo++) {
            Account sobjAcc = new Account();
            sobjAcc.name = 'Account' + iRecNo;
            sobjAcc.BillingStreet = '123 Fake St';
            sobjAcc.BillingCity = 'Springfield';
            sobjAcc.BillingCountry = 'USA';
            sobjAcc.Core_Sales_Groups__c = 'Americas US Sales Group';
            lstAccount.add(sobjAcc);
        }
        return lstAccount;
    }

    public static List <Lead> Core_Lead(Integer iNoOfRecords) {
        List <Lead> lstLead = new List <Lead> {};
        for (integer iRecNo = 0; iRecNo <iNoOfRecords; iRecNo++) {
            Lead sobjAcc = new Lead();
            sobjAcc.Company = 'Lead';
            sobjAcc.LastName = 'Lead';
            lstLead.add(sobjAcc);
        }
        return lstLead;
    }

    public static List <User> Core_User(Integer iNoOfRecords) {
        List <User> lstUser = new List <User> {};
        for (integer iRecNo = 0; iRecNo <iNoOfRecords; iRecNo++) {
            User sobjUser = new User();
            sobjUser.Firstname = 'test';
            sobjUser.LastName = 'sample' + iRecNo;
            sobjUser.userName = 'testusersample.' + iRecNo + '@intel.com.crm';
            sobjUser.email = 'testsample.' + iRecNo + '@intel.com';
            sobjUser.alias = 'samp' + iRecNo;
            sobjUser.communityNickName = 'sam' + iRecNo;
            sobjUser.profileId = '00eo0000000ui0bAAA';
            sobjUser.LANGUAGELOCALEKEY = 'en_US';
            sobjUser.LOCALESIDKEY = 'en_US';
            sobjUser.TIMEZONESIDKEY = 'America/Los_Angeles';
            sobjUser.EMAILENCODINGKEY = 'ISO-8859-1';
            sobjUser.Core_Employee_Type_Code__c = 'EMP';
            lstUser.add(sobjUser);
        }
        return lstUser;
    }

    public static List <Core_Country_Reference__c> Core_CountryState(Integer iNoOfRecords) {
        List <Core_Country_Reference__c> lstCS = new List <Core_Country_Reference__c> {};
        for (integer iRecNo = 0; iRecNo <iNoOfRecords; iRecNo++) {
            Core_Country_Reference__c sobjCS = new Core_Country_Reference__c();
            sobjCS.Name = 'TEST' + iRecNo;
            lstCS.add(sobjCS);
        }
        return lstCS;
    }

    public static List <Core_Trigger_Executions__c> Core_TriggerExecution(Integer iNoOfRecords) {
        List <Core_Trigger_Executions__c> lstTrigExecution = new List <Core_Trigger_Executions__c> {};
        for (integer iRecNo = 0; iRecNo <iNoOfRecords; iRecNo++) {
            Core_Trigger_Executions__c sobjTriggerExecution = new Core_Trigger_Executions__c();
            sobjTriggerExecution.Name = 'TEST' + iRecNo;
            sobjTriggerExecution.Core_Object__c = 'TEST' + iRecNo;
            sobjTriggerExecution.Core_Trigger_Events__c = 'TEST' + iRecNo;
            sobjTriggerExecution.Core_Description__c = 'THIS IS TEST CLASS' + iRecNo;
            sobjTriggerExecution.Core_Class_Name__c = 'TEST CLASS' + iRecNo;
            sobjTriggerExecution.Core_Active__c = True;
            lstTrigExecution.add(sobjTriggerExecution);
        }
        return lstTrigExecution;
    }

    public static List <Opportunity> Core_Opportunity(Integer iNoOfRecords) {
        List <Opportunity> lstOpportunity = new List <Opportunity> {};
        for (integer iRecNo = 0; iRecNo <iNoOfRecords; iRecNo++) {
            Opportunity sobjOppRec = new Opportunity();
            sobjOppRec.CloseDate = system.today();
            sobjOppRec.Name = 'Opportunity' + iRecNo;
            sobjOppRec.StageName = 'Qualify';
            sobjOppRec.Core_Intel_Platform__c = 'GRIZZLY LAKE';
            sobjOppRec.Core_Sales_Group__c = 'Global Accounts';
            lstOpportunity.add(sobjOppRec);
        }
        return lstOpportunity;
    }

    public static List <Core_Feature__c> CreateFeature(Integer iNoOfRecords) {
        List <Core_Feature__c> lstFeature = new List <Core_Feature__c> {};
        for (integer iRecNo = 0; iRecNo <iNoOfRecords; iRecNo++) {
            Core_Feature__c sobjFeature = new Core_Feature__c();
            sobjFeature.Core_Feature_Type__c = 'Entry SPP (US$)';
            sobjFeature.Core_Feature_Value__c = 'value' + iRecNo;
            //if(iRecNo == 3)
            // sobjFeature.Core_Multi_Select__c = TRUE;
            lstFeature.add(sobjFeature);
        }
        return lstFeature;
    }

    /*
     * Method name  : CreateFeatureHeader
     * Description  : method to return the instances of Core_Feature_Header
     * Return Type  : List<Core_Feature_Header__c>
     * Parameter    : Size of records
     */
    public static List <Core_Feature_Header__c> CreateFeatureHeader(Integer iNoOfRecords) {
        List <Core_Feature_Header__c> lstFeatureHeader = new List <Core_Feature_Header__c> {};
        for (integer iRecNo = 0; iRecNo <iNoOfRecords; iRecNo++) {
            Core_Feature_Header__c sobjFeatureHeader = new Core_Feature_Header__c();
            sobjFeatureHeader.Core_Header_Name__c = 'Type' + iRecNo;
            sobjFeatureHeader.Core_Header_Type__c = 'Type' + iRecNo;
            lstFeatureHeader.add(sobjFeatureHeader);
        }
        return lstFeatureHeader;
    }

    /*
     * Method name  : CreateFeatureSet
     * Description  : method to return the instances of Core_Feature_Set
     * Return Type  : List<Core_Feature_Set__c>
     * Parameter    : Size of records
     */
    public static List <Core_Feature_Set__c> CreateFeatureSet(Integer iNoOfRecords) {
        List <Core_Feature_Set__c> lstFeatureSet = new List <Core_Feature_Set__c> {};
        for (integer iRecNo = 0; iRecNo <iNoOfRecords; iRecNo++) {
            Core_Feature_Set__c sobjFeatureHeader = new Core_Feature_Set__c();
            sobjFeatureHeader.Core_Active__c = True;
            lstFeatureSet.add(sobjFeatureHeader);
        }
        return lstFeatureSet;
    }

    /*
     * Method name  : CreateOpportunityFeature
     * Description  : method to return the instances of Core_Opportunity_Features
     * Return Type  : List<Core_Opportunity_Features__c>
     * Parameter    : Size of records
     */
    public static List <Core_Opportunity_Features__c> CreateOpportunityFeature(Integer iNoOfRecords) {
        List <Core_Opportunity_Features__c> lstOpportunityFeature = new List <Core_Opportunity_Features__c> {};
        for (integer iRecNo = 0; iRecNo <iNoOfRecords; iRecNo++) {
            Core_Opportunity_Features__c sobjFeatureHeader = new Core_Opportunity_Features__c();
            lstOpportunityFeature.add(sobjFeatureHeader);
        }
        return lstOpportunityFeature;
    }
    
   /*
    * Method name  : createOpportunityPartner 
    * Description  : method to return test Opportunity Partners
    * Return Type  : List<Core_Opportunity_Partner__c>
    * Parameter    : Size of records
    */
    public static List<Core_Opportunity_Partner__c> createOpportunityPartners(Integer size, Opportunity oppInstance) 
    {
        List<Core_Opportunity_Partner__c> lstOppPartner = new List<Core_Opportunity_Partner__c>();
        Core_Opportunity_Partner__c partnerInstance;
        for (Integer i = 0; i < size; i++) {
            partnerInstance = new Core_Opportunity_Partner__c();
            partnerInstance.Core_Opportunity__c = oppInstance.Id;
            partnerInstance.Core_Partner_Type__c = '';
            partnerInstance.Core_Partner_Role__c = 'Vendor';
            lstOppPartner.add(partnerInstance);
        }
        return lstOppPartner;
    }
 
    public static List <Campaign> createCampaign(Integer size) {
        List <Campaign> campaignList = new List <Campaign> ();
        For(integer i = 0; i <size; i++) {
            Campaign campaignInstance = new Campaign();
            campaignInstance.name = 'Test ' + i;
            campaignInstance.Isactive = true;
            campaignList.add(campaignInstance);
        }
        return campaignList;
    }
    
    @future
    public static void createEmailTemplate(){      
        List<EmailTemplate> listEmailTemp = new List<EmailTemplate>();
        EmailTemplate eml1 = new EmailTemplate (developerName = 'DWG_No_Longer_Achieved_Need_to_be_Recalled', FolderId = UserInfo.getUserId() , TemplateType= 'Text', Name = 'DWG_No_Longer_Achieved_Need_to_be_Recalled');
        listEmailTemp.add(eml1);
        EmailTemplate eml2 = new EmailTemplate (developerName = 'DWG_Ready_to_Submit_Notification', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'DWG_Ready_to_Submit_Notification'); 
        listEmailTemp.add(eml2);
        insert listEmailTemp;
    }
   
}