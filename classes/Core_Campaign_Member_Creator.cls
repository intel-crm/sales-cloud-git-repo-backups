/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Campaign_Member_Creator 
Version     : 1.0 
Created Date: 04 SEP 2015
Function    : 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kalpana Choudhary         09/04/2015             
* Brian Matthews            11/16/15         
*****************************************************************************************************************************************************************************************************/
public class Core_Campaign_Member_Creator {

    private static final String  ACCOUNT_OBJECT     = 'Account';
    private static final String  DEFAULT_SORT_FIELD = 'Name';
    private static final Integer SALESOUT_LOW       = 1000;
    private static final Integer SALESOUT_MEDIUM    = 3000;

    Public List<CampaignMember> campaignMemberlist { get; set; }

    public List<Core_Test_Utility.TargetAccountRecord> lstTargetAccountDisplay { get; set; }
    
    public List<Core_Test_Utility.TargetAccountRecord>       lstTargetExport      { get; set; }
    public List<List<Core_Test_Utility.TargetAccountRecord>> thousandTargetExport { get; set; }

    public Id selectedAccountId       { get; set; }
    public String selectedAccountName { get; set; }
    public CampaignMember uCampaignId { get; set; }
    public boolean exportInProcess    { get; set; }

    public List<Core_Test_Utility.ChannelDataSalesoutSummaryRecord> lstSalesoutSummary { get; set; }

    public List<Core_Channel_Salesout__c> channelSalesList { get; set; }
    public List<Core_Test_Utility.ChannelDataSalesoutRecord> cdSalesoutRecord { get; set; }
    
    public List<Core_Channel_Membership__c> programMemberList { get; set; }
    public List<Core_Test_Utility.ChannelDataMembershipRecord> cdMembershipRecord { get; set; }       
    
    public List<Core_Training__c> trainingList { get; set; }
    public List<Core_Test_Utility.ChannelDataTrainingRecord> cdTrainingRecord { get; set; }
    
    public List<Core_Liability_Points__c> liabilityList { get; set; }
    public List<Core_Test_Utility.ChannelDataPointsRecord> cdPointsRecord { get; set; }

    public Boolean allBatchUsed { get; set; }

    // Channel Data Display Declarations - START
    public Boolean showCSV     { get; set; }
    public Boolean showCSV1    { get; set; }
    public Boolean showCSV2    { get; set; }
    public Boolean showCSV3    { get; set; }
    public Boolean showCSV4    { get; set; }
    public boolean showError   { get; set; }
    public boolean showExport  { get; set; }
    public boolean showPeriod  { get; set; }  
    public boolean showSummary { get; set; }  
    
    public Integer soCount    { get; set; }
    public String  soPeriod   { get; set; }
    
    public List<SelectOption> lstPeriodRange { get; set; }    
    
    public boolean loadingData = false;      
    // Channel Data Display Declarations - END


    public Boolean showCampaignSelector { get; set; }

    private Integer iTotalNoOfRecs;                               // To store total number of records
    public Boolean bErrorMessage           { get; set; }          // Flag to render error message if user didn't enter value for search criteria
    public Integer iPageSize               { get; set; }          // To store page size
    public Integer iNoOfPages              { get; set; }          // Keep track of total number of pages
    public Integer iPageNumber             { get; set; }          // Store Page Number
    public String sColumnSize              { get; set; }          // To store the column size of the table
    public transient String sCurrentPageNo { get; set; }          // Store the current page number
    public Boolean bcampMemberPresent      { get; set; }
    public Boolean bcampaignIdPresent      { get; set; }

    public Integer sComponent = 0 ;
    public Integer sComponentUnits = 0;
    public String  sMembershipTier = '';
    
    public String contentType1 { get; set; }

    public String businessID   { get; set; }
    
    public static String soStaticWhereClause { get; set; }

    // This needs to get into the View State, so a full blown property is used to implement it.
    public String soWhereClause { get; set; }
        
    public Boolean bInitialLoadRequired { get; set; }
                
    public static Set<Id> setTargetId {
        get { 
            if (setTargetId == NULL)
                setTargetId = new Set<Id>();
            return setTargetId;
        }                
        set {
            setTargetId = value;
        } 
    }

    public Core_SortedGrid_ColumnHeader sortHeader 
    {
        get 
        {
             if (sortHeader == NULL)
                 sortHeader = new Core_SortedGrid_ColumnHeader(DEFAULT_SORT_FIELD);
                 
             return sortHeader;                
        }        
        set
        {
             sortHeader = value;       
        }
    }

    
    public Boolean isCalculatedField(String fieldName) {
        return (fieldName == 'membershipTier' || fieldName == 'componentsUnitCosts' || fieldName == 'components');
    }

    
    // This can be responsible for around 1/3 of the View State size            
    transient private List<Account> lstAccountQueried;
    
    private List<Id> lstPersistentTargetId = new List<Id>();

    private Set<Id> setPageTargetId = new Set<Id>();

    public Core_Campaign_Member_Creator(ApexPages.StandardController controller) {
//        System.debug('#77 Core_Campaign_Member_Creator Constructor');
        System.debug('#78 setTargetId.size(): ' + setTargetId.size());

        uCampaignId = new CampaignMember();    

        List<PermissionSetAssignment> lstPermSetAssn = [SELECT PermissionSetId, PermissionSet.Name 
                                                        FROM PermissionSetAssignment 
                                                        WHERE AssigneeId = :userInfo.getUserId()
                                                          AND PermissionSet.Name = :System.Label.Core_Create_and_Edit_Campaign_Permission_Set_Name];

        showCampaignSelector = (lstPermSetAssn != NULL && lstPermSetAssn.size() > 0);
        exportInProcess = false;
        programMemberList = Null;
        contentType1 = 'text/html';

        showCSV = true;        
        resetChannelDataDisplay();
        
        Date currentDate = Date.today();

        // MUST use a Double in the Ceiling function
        Double doubleMonth     = currentDate.month();                                            
        Integer currentQuarter = Integer.valueOf(Math.Ceil(doubleMonth/3));  // MUST USE DOUBLE           
        
        Date quarterEnd        = Date.newInstance(currentDate.year(), currentQuarter * 3, 1);
        quarterEnd             = quarterEnd.addMonths(1);
        quarterEnd             = quarterEnd.addDays(-1);
        
        String strPeriod;        
        lstPeriodRange = new List<SelectOption>();
        for (integer i=0; i < 5; i++) {                
            strPeriod = quarterEnd.year() + '-0' + (quarterEnd.Month() / 3);
            lstPeriodRange.add(new SelectOption(strPeriod, strPeriod));
            quarterEnd = quarterEnd.addMonths(-3);                
        }
        soPeriod = lstPeriodRange.get(0).getValue();                    
        // Channel Data Display - END
                
                
        // Setting the Page size for pagination
        iPageSize = 50;
        allBatchUsed = false;
        // Setting the current page to 1
        sCurrentPageNo = '1';
        
        // Setting the current page to 1
        iPageNumber = 1;
        
        // Setting the total number of pages to 1
        iNoOfPages = 0;
        
        bcampMemberPresent = false;
        bcampaignIdPresent = false;
        
        // Setting the flag to false which is used for showing error message if there are no records retrived for the search criteria
        bErrorMessage = false;
        
        // Setting the column size, as a percent(%) of the columns displayed in the table 
        sColumnSize = '10';
        
        // Setting the list to NULL
        lstTargetAccountDisplay = NULL;
        lstAccountQueried       = NULL;
        setPageTargetId         = new Set<Id>();

        bInitialLoadRequired    = true;

    }


    private void resetChannelDataDisplay() {
        showCSV1   = false;
        showCSV2   = false;
        showCSV4   = false;
        showError  = false;
        showExport = false;
        showPeriod = false;
        
        // true - Summary should be the first to show
        showSummary = true;
    }
    

    public PageReference campaignMember1(){

        bcampMemberPresent = false;
        bcampaignIdPresent = (uCampaignId.campaignId == NULL);
        if (bcampaignIdPresent)
            return null;

        Set<Id> accountSet    = new Set<Id>(lstPersistentTargetId);
        set<Id> contactIdlist = new set<Id>(); 

        system.debug('#01 accountSet.size():' + accountSet.size());
                
        Set<Id> dupeAccountCheck = new Set<Id>();        
        for(CampaignMember cm : [SELECT Id, contactId, Contact.AccountId FROM Campaignmember WHERE CampaignId = :uCampaignId.campaignId])
        {
            contactIdlist.add(cm.ContactId);
            dupeAccountCheck.add(cm.Contact.AccountId);            
        }
//        System.debug('#02 Accounts already with campaign members - dupeAccountCheck.size(): ' + dupeAccountCheck.size());
//        System.debug('#03 Contacts already on campaign - contactIdlist.size(): ' + contactIdlist.size());

        List<Contact> conlist = new list<Contact>();
        campaignMemberlist = new list<CampaignMember>();

        // -Sort by "Core_Primary_Contact__s DESC" so the "true" primary contacts
        // are added first. 
        //
        // -When other contacts are added for the same account, dupeAccountCheck 
        // filters them out.  
        //
        // -Finally, contacts from accounts with no primary contacts, are added last.
        //   
        conlist = [SELECT Id, AccountId, Core_Primary_Contact__c 
                   FROM Contact 
                   WHERE AccountId IN :accountSet 
                   ORDER BY Core_Primary_Contact__c DESC];
                   
        system.debug('#05 conlist:' + conlist);

        for (Contact c : conlist) {
            if(!contactIdlist.contains(c.Id)) 
            {
                if (!dupeAccountCheck.contains(c.AccountId))
                {
                    dupeAccountCheck.add(c.AccountId);
                    CampaignMember cm = new CampaignMember();
                    cm.ContactId = c.Id;
                    cm.CampaignId = uCampaignId.campaignId;
                    campaignMemberlist.add(cm);
                }
            }
        }


        try {
            if(campaignMemberlist.size() > 0){
                 DataBase.Insert(campaignMemberlist);
                 
                 campaignMemberlist = [SELECT Name, contact.Name, Campaign.Name FROM campaignMember WHERE Id IN : campaignMemberlist];
                 bcampMemberPresent = (campaignMemberlist.size() == 0);
                 
                 system.debug('#06 confirmed entries - campaignMemberlist.size():' + campaignMemberlist.size());

                 Pagereference p = new Pagereference('/' + uCampaignId.campaignId);
                 return p;
            } 
            else {
                  bcampMemberPresent = true;
                  return null;
            }
        }     
        catch(Exception ex){
            System.debug('#28 Error on DataBase.Insert(campaignMemberlist): ' + ex);
            return null;
        }     
        
        return null;
    }    
    
    
    public pageReference returnToSearchPage(){
    
        // VERY IMPORTANT: Force a refresh on return from search page to results page
        lstTargetAccountDisplay = NULL;
        lstAccountQueried       = NULL;
        bInitialLoadRequired    = true; 
            
        PageReference pageRef = page.Core_Salesout_Search;
        pageRef.setRedirect(false); 
        return pageRef;
    }
    
    
        
    public pageReference returntoSearchResults(){

        channelSalesList = NULL;
        cdSalesoutRecord = NULL;
    
        programMemberList  = NULL;
        cdMembershipRecord = NULL;
    
        trainingList     = NULL;
        cdTrainingRecord = NULL;
    
        liabilityList  = NULL;
        cdPointsRecord = NULL;

        resetChannelDataDisplay();

        PageReference pageRef = Page.Core_CampaignCreator;
        pageRef.setRedirect(false);
        return pageRef;                          
    }    


    public PageReference simpleSort() {
        iPageNumber = 1;  

        AccountOnlySearch(true);

        return null;
    }

    
    public PageReference initialLoadTargetAccounts() {
        bcampMemberPresent = false;
        bcampaignIdPresent = false;

//        System.debug('#81 Core_Campaign_Member_Creator.setTargetId.size(): ' + setTargetId.size());

        if (bInitialLoadRequired)
        {
            bInitialLoadRequired = false;
            
//            System.debug('#92 initialLoadTargetAccounts : lstAccountQueried IS NULL, re-loading ');
            lstPersistentTargetId.clear();            
            
            for (Id accId : setTargetId) 
                lstPersistentTargetId.add(accId);           
            
            soWhereClause = soStaticWhereClause;

            // Default sort to account 'Name'.
            sortHeader.sortExpression = 'Name';
            sortHeader.sortDirection  = Core_SortedGrid_ColumnHeader.ASCENDING_TEXT;
            
            AccountOnlySearch(true);

        }

        return null;
    }
    
    
    public void AccountOnlySearch(Boolean firstCall) {

        // Clear error messages
        bcampMemberPresent = false;
        bcampaignIdPresent = false;

        Integer iOffset = 0;

        if (firstCall) 
        {
            sortPersistentTargetId();
        
            lstAccountQueried = queryByPageSizeAndOffset(iPageSize, 0);

            if (lstAccountQueried.isEmpty())
                return;
            
            iPageNumber = 1;                        
            iNoOfPages  = Integer.valueOf(lstPersistentTargetId.size() / iPageSize);       // Populating total no of pages to be shown on page
            if (iNoOfPages != 0 && Math.mod(lstPersistentTargetId.size(), iPageSize) > 0)
                iNoOfPages++;
                
            if (iNoOfPages == 0)
                iNoOfPages++;
        }
        else    
        {
            // After a delete, the # of pages may have changed
            iNoOfPages  = Integer.valueOf(lstPersistentTargetId.size() / iPageSize);       // Populating total no of pages to be shown on page
            if (iNoOfPages != 0 && Math.mod(lstPersistentTargetId.size(), iPageSize) > 0)
                iNoOfPages++;
                
            if (iNoOfPages == 0)
                iNoOfPages++;

            iOffset = iPageSize * (iPageNumber - 1);
            lstAccountQueried = queryByPageSizeAndOffset(iPageSize, iOffset);
        }    

//        System.debug('#51 lstAccountQueried: ' + lstAccountQueried);

        lstTargetAccountDisplay = new List<Core_Test_Utility.TargetAccountRecord>();
                
        for (Integer idx=0; idx < lstAccountQueried.size(); idx++)
            lstTargetAccountDisplay.add(new Core_Test_Utility.TargetAccountRecord(lstAccountQueried[idx], sortHeader.sortExpression, sortHeader.sortDirection));
//        System.debug('#52 sortHeader.sortExpression: ' + sortHeader.sortExpression);

        lstTargetAccountDisplay.sort();
//        System.debug('#52 lstTargetAccountDisplay: ' + lstTargetAccountDisplay);
            
    }


    public void sortPersistentTargetId() {

        List<Account> lstAccounts;
        String sortString;

        if (sortHeader.sortExpression == 'membershipTier') {
            sortString =  'SELECT Id, ' + 
                          ' (SELECT Core_Current_Membership_Tier__c FROM Channel_Memberships__r ORDER BY Core_Status_Date__c DESC LIMIT 1) ';
            sortString += ' FROM Account ';
            sortString += ' WHERE Id IN :lstPersistentTargetId ';
            System.debug('#71 sortString: ' + sortString + '  lstPersistentTargetId.size(): ' + lstPersistentTargetId.size());        

            lstAccounts = Database.query(sortString);
            
            Map<String, Account> mapAccount = new Map<String, Account>();
            for (Account acc: lstAccounts)
            {
                if (acc.Channel_Memberships__r.size() > 0)
                    mapAccount.put(acc.Channel_Memberships__r[0].Core_Current_Membership_Tier__c + acc.Id, acc);
                else    
                    // Membership Tier is blank.
                    mapAccount.put(' ' + acc.Id, acc);
            }
            
            List<String> keyList = new List<String>(mapAccount.keySet()); 
            keyList.sort();
            lstPersistentTargetId.clear();            

            if (sortHeader.sortDirection == Core_SortedGrid_ColumnHeader.ASCENDING_TEXT) {                     
                for (Integer i=0; i < keyList.size(); i++)
                    lstPersistentTargetId.add(mapAccount.get(keyList[i]).Id);
            } else { 
                for (Integer i=keyList.size() - 1; i >= 0; i--)
                    lstPersistentTargetId.add(mapAccount.get(keyList[i]).Id);            
            }        
            
            return;
            
        } 


        // CALCULATED FIELD - Salesout Component Qty
        if (sortHeader.sortExpression == 'components') {
            sortString =  'SELECT Id, ' + 
                          ' (SELECT Core_Component_Units__c FROM Core_Account_Channel_Sales_Out__r ' + soWhereClause + ') '; 
            sortString += ' FROM Account ';
            sortString += ' WHERE Id IN :lstPersistentTargetId ';
            System.debug('#71 sortString: ' + sortString + '  lstPersistentTargetId.size(): ' + lstPersistentTargetId.size());        

            lstAccounts = Database.query(sortString);
            
            String  strComponentSum;
            Integer iComponentSum;
            Map<String, Account> mapAccount = new Map<String, Account>();
            for (Account acc: lstAccounts)
            {
                iComponentSum = 0;
                for(Core_Channel_Salesout__c ccs : acc.Core_Account_Channel_Sales_Out__r)
                    iComponentSum += Integer.valueof(ccs.Core_Component_Units__c);
                                
                strComponentSum = '000000000000000' + iComponentSum;                
                strComponentSum = strComponentSum.right(15);                
                                
                mapAccount.put(strComponentSum + acc.Id, acc);
            }
            
            List<String> keyList = new List<String>(mapAccount.keySet()); 
            keyList.sort();
            lstPersistentTargetId.clear();            

            if (sortHeader.sortDirection == Core_SortedGrid_ColumnHeader.ASCENDING_TEXT) {                     
                for (Integer i=0; i < keyList.size(); i++)
                    lstPersistentTargetId.add(mapAccount.get(keyList[i]).Id);
            } else { 
                for (Integer i=keyList.size() - 1; i >= 0; i--)
                    lstPersistentTargetId.add(mapAccount.get(keyList[i]).Id);            
            }        
            
            return;            
        } 

        
        // CALCULATED FIELD - Salesout Component $
        if (sortHeader.sortExpression == 'componentsUnitCosts') {
            sortString =  'SELECT Id, ' + 
                          ' (SELECT Core_Component__c FROM Core_Account_Channel_Sales_Out__r ' + soWhereClause + ') '; 
            sortString += ' FROM Account ';
            sortString += ' WHERE Id IN :lstPersistentTargetId ';
            System.debug('#71 sortString: ' + sortString + '  lstPersistentTargetId.size(): ' + lstPersistentTargetId.size());        

            lstAccounts = Database.query(sortString);
            
            String  strComponentSum;
            Integer iComponentSum;
            Map<String, Account> mapAccount = new Map<String, Account>();
            for (Account acc: lstAccounts)
            {
                iComponentSum = 0;
                for(Core_Channel_Salesout__c ccs : acc.Core_Account_Channel_Sales_Out__r)
                    iComponentSum += Integer.valueof(ccs.Core_Component__c);
                                
                strComponentSum = '000000000000000' + iComponentSum;                
                strComponentSum = strComponentSum.right(15);                
                                
                mapAccount.put(strComponentSum + acc.Id, acc);
            }
            
            List<String> keyList = new List<String>(mapAccount.keySet()); 
            keyList.sort();
            lstPersistentTargetId.clear();    
            
            if (sortHeader.sortDirection == Core_SortedGrid_ColumnHeader.ASCENDING_TEXT) {                     
                for (Integer i=0; i < keyList.size(); i++)
                    lstPersistentTargetId.add(mapAccount.get(keyList[i]).Id);
            } else { 
                for (Integer i=keyList.size() - 1; i >= 0; i--)
                    lstPersistentTargetId.add(mapAccount.get(keyList[i]).Id);            
            }        
            
            return;            
        } 


        // REGULAR FIELDS
        sortString = 'SELECT Id FROM Account WHERE Id IN :lstPersistentTargetId ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection;        
//        System.debug('#74 sortString: ' + sortString + '  lstPersistentTargetId.size(): ' + lstPersistentTargetId.size());        

        lstAccounts = Database.query(sortString);
//        System.debug('#75 lstAccounts: ' + lstAccounts);        

        lstPersistentTargetId.clear();            
        for (Account acc : lstAccounts)
            lstPersistentTargetId.add(acc.Id);

//        System.debug('#76 lstPersistentTargetId: ' + lstPersistentTargetId);        
                    
    }


    public void loadTargetList() {
    
        thousandTargetExport = new List<List<Core_Test_Utility.TargetAccountRecord>>();
        lstTargetExport      = new List<Core_Test_Utility.TargetAccountRecord>();
        
        List<Account> lstAccount = queryByPageSizeAndOffset(48000, 0);
        
        Core_Test_Utility.TargetAccountRecord rec;
        Integer idx = 0;
        for (Account acc : lstAccount) {
        
            rec = new Core_Test_Utility.TargetAccountRecord(acc);
        
            if (idx > 999) {
                idx = 0;
                
                if (lstTargetExport.size() > 0)
                    thousandTargetExport.add(lstTargetExport);
                    
                lstTargetExport = new List<Core_Test_Utility.TargetAccountRecord>();            
            }
            
            lstTargetExport.add(rec);
            idx++;
        }

        if (lstTargetExport.size() > 0)
            thousandTargetExport.add(lstTargetExport);

    }

    
    private String buildQuery() {
        // Building query with the fields from the field set
        String query = 'SELECT Name, Owner.Name,ownerId,Owner.firstName,Owner.LastName, Core_Account_Type__c, Core_Sales_Segment__c, Core_Account_Tier__c, Industry, ' + 
                       ' (SELECT Core_Component__c, Core_Component_Units__c FROM Core_Account_Channel_Sales_Out__r ' + soWhereClause + '), ' + 
                       ' (SELECT Core_Current_Membership_Tier__c FROM Channel_Memberships__r ORDER BY Core_Status_Date__c DESC LIMIT 1) ';
        query += ' FROM Account ';
        query += ' WHERE Id IN :setPageTargetId ';
//        system.debug('#65 query:' + query);
        return query;
    }

    
    private List<Account> queryByPageSizeAndOffset(integer pPageSize, integer pOffset) {

        Integer maxRecord = Math.Min(lstPersistentTargetId.size(), pOffset + pPageSize);
//        System.debug('#37 maxRecord: ' + maxRecord);

        setPageTargetId.clear();
        for (Integer Idx = pOffset; idx < maxRecord; idx++)
            setPageTargetId.add(lstPersistentTargetId.get(idx));
            
//        system.debug('#66 setPageTargetId.size(): ' + setPageTargetId.size());
            
        // Building query and adding the where clause part to the query
        String query = buildQuery();               

        if (!isCalculatedField(sortHeader.sortExpression))                
            query += ' ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection;

        System.debug('#38 query: ' + query);

        List<Account> lstAcc;
        
        try {
            
            lstAcc = Database.query(query);
            system.debug('#39 ***lstAcc.size(): ' + lstAcc.size());
            
        } catch (Exception err) {
            ApexPages.Message pageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage());
            ApexPages.addMessage(pageMessage);

            lstAcc= new List<Account>();
        }
                
        return lstAcc; 
    }


    public PageReference channelSalesData(){
        if (selectedAccountId == NULL) 
            return NULL;

        selectedAccountName = [SELECT Name FROM Account WHERE Id = :selectedAccountId].Name;        

        resetChannelDataDisplay();

        loadProgramData();
        loadSummary();

        Pagereference p = page.Core_ChannelData;
        p.setRedirect(false);
        return p;    
    }
    

    public void loadSummary() { 

        String cdWhereClause;
        if (String.isblank(soWhereClause)) 
            cdWhereClause = 'WHERE Core_Account_Name__c = :selectedAccountId ';
        else        
            cdWhereClause = soWhereClause + ' AND Core_Account_Name__c = :selectedAccountId ';
        
        string soQuery = 'SELECT Core_Sales_Type__c, Core_Invoice_Quarter__c, Core_Invoice_Quarter_Text__c, Core_Product_Level_1__c, Core_Component__c, Core_Component_Units__c ' +
                         'FROM Core_Channel_Salesout__c ' +
                         cdWhereClause + 
                         'ORDER BY Core_Sales_Type__c, Core_Invoice_Quarter__c, Core_Product_Level_1__c ';
        System.debug('#02 Summary soQuery: '  + soQuery);

        List<Core_Channel_Salesout__c> soSummary = Database.query(soQuery);

        lstSalesoutSummary = new List<Core_Test_Utility.ChannelDataSalesoutSummaryRecord>();

        String  salesType;
        Decimal quarter;
        String  quarterText;
        String  product;
        Decimal component      = 0;
        Decimal componentUnits = 0;

        String  sumSalesType;
        Decimal sumQuarter;
        String  sumQuarterText;
        Decimal sumComponent      = 0;
        Decimal sumComponentUnits = 0;

        for (Core_Channel_Salesout__c cs : soSummary) {
            if (String.isblank(salesType)) {
                salesType    = cs.Core_Sales_Type__c;
                quarter      = cs.Core_Invoice_Quarter__c;
                quarterText  = cs.Core_Invoice_Quarter_Text__c;
                product      = cs.Core_Product_Level_1__c;
                
                sumSalesType   = cs.Core_Sales_Type__c;
                sumQuarter     = cs.Core_Invoice_Quarter__c;
                sumQuarterText = cs.Core_Invoice_Quarter_Text__c;
            }                        
                        
            if ((cs.Core_Sales_Type__c != salesType) || (cs.Core_Invoice_Quarter__c != quarter) || (cs.Core_Product_Level_1__c != product)) {
                lstSalesoutSummary.add(new Core_Test_Utility.ChannelDataSalesoutSummaryRecord(salesType, quarter, quarterText, product, component, componentUnits));  
             
                sumComponent      += component;
                sumComponentUnits += componentUnits;             
                                                 
                if ((cs.Core_Sales_Type__c != salesType) || (cs.Core_Invoice_Quarter__c != quarter)) {
                    lstSalesoutSummary.add(new Core_Test_Utility.ChannelDataSalesoutSummaryRecord('', NULL, '', '', sumComponent, sumComponentUnits));                      
                    lstSalesoutSummary.add(new Core_Test_Utility.ChannelDataSalesoutSummaryRecord('', NULL, '', '', NULL, NULL));  

                    sumSalesType      = cs.Core_Sales_Type__c;
                    sumQuarter        = cs.Core_Invoice_Quarter__c;
                    sumQuarterText    = cs.Core_Invoice_Quarter_Text__c;
                    sumComponent      = 0;
                    sumComponentUnits = 0;
                }                    
             
                salesType      = cs.Core_Sales_Type__c;
                quarter        = cs.Core_Invoice_Quarter__c;  
                quarterText    = cs.Core_Invoice_Quarter_Text__c;  
                product        = cs.Core_Product_Level_1__c;
                component      = 0;
                componentUnits = 0; 
                                
                System.debug('#51 salesType: ' + salesType);             
            }
            
            component      += cs.Core_Component__c;
            componentUnits += cs.Core_Component_Units__c;             
        }

        if (!String.isblank(salesType)) {
            lstSalesoutSummary.add(new Core_Test_Utility.ChannelDataSalesoutSummaryRecord(salesType, quarter, quarterText, product, component, componentUnits));  

            sumComponent      += component;
            sumComponentUnits += componentUnits;             
                                             
            lstSalesoutSummary.add(new Core_Test_Utility.ChannelDataSalesoutSummaryRecord('', NULL, '', '', sumComponent, sumComponentUnits));                      
            lstSalesoutSummary.add(new Core_Test_Utility.ChannelDataSalesoutSummaryRecord('', NULL, '', '', NULL, NULL));  
        }
        
        showCSV = (lstSalesoutSummary.size() > 0);                       
        
    }


    public void loadSalesoutData() {

        String strQuarterCriteria = '';

        if (showPeriod) 
        {
            System.debug('#86 soPeriod: ' + soPeriod);
        
            List<String> str = soPeriod.split('-');  
            integer quarter = (integer.valueof(str.get(0)) * 100) + integer.valueof(str.get(1));        
            System.debug('#87 quarter: ' + quarter);

            strQuarterCriteria += ' AND Core_Invoice_Quarter__c = :quarter';
        }

        String cdWhereClause;
        if (String.isblank(soWhereClause)) 
            cdWhereClause = 'WHERE Core_Account_Name__c = :selectedAccountId ' + strQuarterCriteria;
        else        
            cdWhereClause = soWhereClause + ' AND Core_Account_Name__c = :selectedAccountId ' + strQuarterCriteria;

        // FOR HIGH VOLUME ACCOUNTS - Don't run the data query unless the user has FIRST been shown the period selector.
        //
        if (!showPeriod) {        
            String soCountQuery = 'SELECT Count() '  + 
                                  'FROM Core_Channel_Salesout__c ' + 
                                  cdWhereClause;
    
            soCount = Database.countQuery(soCountQuery);
        }
    
    
        // FOR HIGH VOLUME ACCOUNTS - Don't run the data query unless the user has FIRST been shown the period selector.
        //
        if (soCount <= SALESOUT_MEDIUM || showPeriod) { 
    
            String soQuery = 'SELECT Id, Core_Sales_Type__c, Core_Invoice_WW__c, Core_Invoice_Quarter__c, Core_Invoice_Quarter_Text__c, Core_Rpt_Parent_Form_Factor__c,' + 
                             'Core_Business_ID__c, Core_Business_Region__c, Core_Business_Geo__c, ' +
                             'Core_Product_Level_1__c, Core_Product_Level_2__c, Core_Product_Level_4__c, ' +
                             'Core_Component__c, Core_Component_Units__c, Core_Distributor_Name__c, Core_Processor_Nbr__c ' + 
                             'FROM Core_Channel_Salesout__c ' + 
                             cdWhereClause + 
                             ' ORDER BY Core_Sales_Type__c, Core_Invoice_Quarter__c, Core_Rpt_Parent_Form_Factor__c, Core_Business_ID__c, Core_Product_Level_1__c ';
        
            System.debug('#88 soQuery: ' + soQuery);
    
            channelSalesList = Database.Query(soQuery);
    
            showCSV = (channelSalesList != NULL && channelSalesList.size() > 0);                       
            if (showCSV)
            {
                cdSalesoutRecord = new List<Core_Test_Utility.ChannelDataSalesoutRecord>();
                for (Core_Channel_Salesout__c ccs : channelSalesList)
                  cdSalesoutRecord.add(new Core_Test_Utility.ChannelDataSalesoutRecord(ccs));
                  
                System.debug('#10 loaded cdSalesoutRecord.size(): ' + cdSalesoutRecord.size());                       
            }        
        }
    }


    public void loadProgramData() {
        programMemberList = [SELECT Id, Core_Current_Membership_Tier__c, Core_Business_ID__c, Core_Renewal_Timestamp__c, Core_Renewal_Status__c, 
                                    Core_Requested_Tier_Status__c, Core_Status_Date__c, Core_CIM_ID__c,
                                    Core_Points_Due_to_Expire_Next_Qtr__c, 
                                    Core_Points_Expired_in_Current_Qtr__c,
                                    Core_Sales_Needed_to_Gold__c, 
                                    Core_Sales_Needed_to_Platinum__c,
                                    Core_Training_Needed_to_Gold__c, 
                                    Core_Training_Needed_to_Platinum__c
                             FROM Core_Channel_Membership__c 
                             WHERE Core_Account_Name__c = :selectedAccountId
                             ORDER BY Core_Status_Date__c DESC];
        showCSV1 = (programMemberList != NULL && programMemberList.size() > 0);                       
        if (showCSV1)
        {
            cdMembershipRecord = new List<Core_Test_Utility.ChannelDataMembershipRecord>();
            for (Core_Channel_Membership__c cm : programMemberList)
              cdMembershipRecord.add(new Core_Test_Utility.ChannelDataMembershipRecord(cm));    
              
            businessId = programMemberList[0].Core_Business_ID__c;              
            System.debug('#11 loaded cdMembershipRecord.size(): ' + cdMembershipRecord.size());                       
        }


        trainingList = [SELECT Id, Core_First_Name__c, Core_Last_Name__c, Core_Role_Code__c, Core_Training_Complete_Date__c, Core_Training_Credits__c, Core_Training_ID__c, Core_Training_Title__c
                        FROM Core_Training__c 
                        WHERE Core_Account__c = :selectedAccountId
                        ORDER BY Core_Training_Complete_Date__c DESC];
        showCSV2 = (trainingList != NULL && trainingList.size() > 0);                                   
        if (showCSV2)
        {
            cdTrainingRecord = new List<Core_Test_Utility.ChannelDataTrainingRecord>();
            for (Core_Training__c ct : trainingList)                    
                cdTrainingRecord.add(new Core_Test_Utility.ChannelDataTrainingRecord(ct));
            System.debug('#12 loaded cdTrainingRecord.size(): ' + cdTrainingRecord.size());                       
        }


        liabilityList = [SELECT Id, Core_Total_Available_Points__c, Core_Total_Balance_Points__c, Core_Total_Expired_Points__c, 
                                Core_Total_Earned_Points__c, Core_Total_Redeemed_Points__c
                         FROM Core_Liability_Points__c
                         WHERE Core_Account__c = :selectedAccountId];
        showCSV4 = (liabilityList != NULL && liabilityList.size() > 0);                                   
        if (showCSV4) {
            cdPointsRecord = new List<Core_Test_Utility.ChannelDataPointsRecord>();
            for (Core_Liability_Points__c clp : liabilityList)       
                cdPointsRecord.add(new Core_Test_Utility.ChannelDataPointsRecord(clp));
            System.debug('#13 loaded cdPointsRecord.size(): ' + cdPointsRecord.size());                       
        }        
    }


    public PageReference displayDetail() {              
        showSummary = false;

        loadSalesoutData();

        if (soCount > SALESOUT_LOW)
        {
            System.debug('#14 soCount > ' + SALESOUT_LOW + '; ' + soCount);                       

            showError  = true;
            showExport = true;
            
            if (soCount > SALESOUT_MEDIUM)
                showPeriod = true;            
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Press "Export to Excel" to view Salesout Data for accounts with more than ' + SALESOUT_LOW + ' Salesout line items.');
            ApexPages.addMessage(myMsg);                                              
        }

        PageReference pageRef = page.Core_ChannelData;
        pageRef.setRedirect(false); 
        return pageRef;                          
    }    


    public PageReference displaySummary() {              

        showSummary = true;

        showError   = false;
        showExport  = false;
        showPeriod  = false;

        PageReference pageRef = page.Core_ChannelData;
        pageRef.setRedirect(false); 
        return pageRef;                          
    }    


    Public PageReference exportCSV(){

        showSummary = false;

        // FOR HIGH VOLUME ACCOUNTS - The user can select a period, so you'll have to load the data.
        if (showPeriod)
            loadSalesoutData();
        
        Pagereference p = page.Core_Channel_Data_Export;
        p.setRedirect(false);        
        return p;
    }


    Public PageReference exportSummary(){

        showSummary = true;

        Pagereference p = page.Core_Channel_Data_Export;
        p.setRedirect(false);        
        return p;
    }


    public PageReference exportTargetList(){
        loadTargetList();

        Pagereference p = page.Core_Target_Accounts_Export;
        p.setRedirect(false);        
        return p;        
    }


    public PageReference deleteRecord(){
    
        Id targetId;
        for (Core_Test_Utility.TargetAccountRecord accRec : lstTargetAccountDisplay){
            if (accRec.IsSelected) {                
                for (Integer idx=0; idx < lstPersistentTargetId.size(); idx++) {                
                    targetId = lstPersistentTargetId[idx];
                    if (targetId == accRec.Id) {
                        lstPersistentTargetId.remove(idx);
                    }
                }
            }                
        }
        
        AccountOnlySearch(false);
        
        return null;    
    }
   
   
    public PageReference next() {
        if (iPageNumber == 0) {
            iPageNumber += 2;
        } else {
            iPageNumber += 1;
        }

        AccountOnlySearch(false);

        return null;
    } 


    /*
     * Method name  : previous
     * Description  : Method to populate the previous set of opportunity records
     * Return Type  : None
     * Parameter    : PageReference
     */
    public PageReference previous() {
        iPageNumber--;
        if (iPageNumber < 0)
            return null;

        if (iPageNumber == 0)
            iPageNumber = 1;
            
        AccountOnlySearch(false);
        return null;
    }


    /*
     * Method name  : first
     * Description  : Method to go to the first page
     * Return Type  : None
     * Parameter    : PageReference
     */
    public PageReference first() {
        iPageNumber = 1;  

        AccountOnlySearch(true);

        return null;
    }


    /*
     * Method name  : last
     * Description  : Method to go to the last page
     * Return Type  : None
     * Parameter    : PageReference
     */
    public PageReference last() {
        iPageNumber = iNoOfPages;

        AccountOnlySearch(false);
            
        return null;
    }


 /*           
    public pageReference exportToReports(){
        List<Account> accountList = new list<Account>();
        
        for(Account acc : lstAccountQueried)
            accountList.add(acc);
 
        Core_Batch_Create_Sharing coreSharing = new Core_Batch_Create_Sharing(accountList);
        if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){
            database.executeBatch(coreSharing, 10);
            exportInProcess = true;
        }
        else{
            allBatchUsed = true;
        }
        
        return null;
    }      
*/


}