/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_ChannelData_Single_Controller
Created Date:     Oct 12, 2015
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              09/12/2015             
*****************************************************************************************************************************************************************************************************/
public class Core_ChannelData_Single_Controller {
    /*final public integer SALESOUT_LOW    = 1000;
    final public integer SALESOUT_MEDIUM = 3000;     // Original: 3000.  SET TO 1000 for DEV TESTING!  12/28 - FIXED.

    public Id selectedAccountId       { get; set; }
    public String selectedAccountName { get; set; }

    public String contentType1 { get; set; }
    public String businessID   { get; set; }

    public Integer soCount     { get; set; }
    public String  soPeriod    { get; set; }
    
    public List<SelectOption> lstPeriodRange { get; set; }

    public boolean showCSV     { get; set; }
    public boolean showCSV1    { get; set; }
    public boolean showCSV2    { get; set; }
    public boolean showCSV4    { get; set; }
    public boolean showError   { get; set; }
    public boolean showExport  { get; set; }
    public boolean showPeriod  { get; set; }
    public boolean showSummary { get; set; }

    public boolean loadingData = false;

    public Account account { get; set; }

    public List<Core_Test_Utility.ChannelDataSalesoutSummaryRecord> lstSalesoutSummary { get; set; }

    private List<Core_Channel_Salesout__c> channelSalesList;
    public  List<Core_Test_Utility.ChannelDataSalesoutRecord> cdSalesoutRecord { 

        get {
            System.debug('#66 get cdSalesoutRecord');

            // This loads salesout data on a quarterly basis - it is required!
            if (!loadingData && showPeriod)
            {
                System.debug('#67 loadSalesoutData');            
                loadingData = true;
                loadSalesoutData();
                loadingData = false;
            }
            return cdSalesoutRecord;
        }
        set; 

    }

    private List<Core_Channel_Membership__c> programMemberList;
    public  List<Core_Test_Utility.ChannelDataMembershipRecord> cdMembershipRecord { get; set; }    
    
    private List<Core_Training__c> trainingList;
    public  List<Core_Test_Utility.ChannelDataTrainingRecord> cdTrainingRecord { get; set; }

    private List<Core_Liability_Points__c> liabilityList;
    public  List<Core_Test_Utility.ChannelDataPointsRecord> cdPointsRecord { get; set; }


    public Core_ChannelData_Single_Controller(ApexPages.StandardController controller) {
        System.debug('#01 Core_Channel_Data_Single_Controller Constructor');

        showCSV     = false;
        showCSV1    = false;
        showCSV2    = false;
        showCSV4    = false;
        showError   = false;
        showExport  = false;
        showPeriod  = false;
        
        // True - because the screen should open in summary mode (i.e. low record volume).
        showSummary = true;
        
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
        
        Id accountId = ApexPages.currentPage().getParameters().get('id');
        if (accountId != NULL)
            account = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
        else    
            account = (Account)controller.getRecord();

        Set<Id> setAcctIds = new Set<Id>();
        setAcctIds.add(account.Id);
        System.debug('#03 setAcctIds: ' + setAcctIds);
        
        Set<Id> accessIds = Core_Test_Utility.validateAccountAccess(UserInfo.getUserId(), setAcctIds);
        System.debug('#04 accessIds: ' + accessIds);
        
        showError = (accessIds.size() == 0);
        if (showError)
        {        
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Access to Salesout data is closely controlled.');
            ApexPages.addMessage(myMsg);                                              
            return;            
        }          

        contentType1 = 'text/html';
        
        selectedAccountId   = account.Id;
        selectedAccountName = [SELECT Name FROM Account WHERE Id = :selectedAccountId].Name;

        System.debug('#09 selectedAccountName: ' + selectedAccountName);                       
                    
        loadProgramData();
        loadSummary();
    } 
     

    public void loadSummary() { 
        List<Core_Channel_Salesout__c> soSummary = [SELECT Core_Sales_Type__c, Core_Invoice_Quarter__c, Core_Invoice_Quarter_Text__c, 
                                                           Core_Product_Level_1__c, Core_Component__c, Core_Component_Units__c 
                                                    FROM Core_Channel_Salesout__c  
                                                    WHERE Core_Account_Name__c = :selectedAccountId
                                                    ORDER BY Core_Sales_Type__c, Core_Invoice_Quarter__c, Core_Product_Level_1__c];

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
                    sumQuartertext    = cs.Core_Invoice_Quarter_Text__c;
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


    public void loadDetail() {         
        
        // loadSalesoutData loads the soCount property.
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
            return;            
        }                                            
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

        String soQuery = 'SELECT Count() '  + 
                         'FROM Core_Channel_Salesout__c ' + 
                         'WHERE Core_Account_Name__c = :selectedAccountId ' + strQuarterCriteria;
    
        soCount = Database.countQuery(soQuery);

        if (soCount <= SALESOUT_MEDIUM || showPeriod) { 
    
            soQuery = 'SELECT Id, Core_Sales_Type__c, Core_Invoice_WW__c, Core_Invoice_Quarter__c, Core_Invoice_Quarter_Text__c, Core_Rpt_Parent_Form_Factor__c, ' +
                      'Core_Business_ID__c, Core_Business_Region__c, Core_Business_Geo__c, ' + 
                      'Core_Product_Level_1__c, Core_Product_Level_2__c, Core_Product_Level_4__c, ' + 
                      'Core_Component__c, Core_Component_Units__c, Core_Distributor_Name__c, Core_Processor_Nbr__c ' + 
                      'FROM Core_Channel_Salesout__c ' + 
                      'WHERE Core_Account_Name__c = :selectedAccountId ' + strQuarterCriteria + 
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

        loadDetail();

        PageReference pageRef = page.Core_ChannelData_Single;
        pageRef.getParameters().put('Id', account.Id);        
        pageRef.setRedirect(false); 
        return pageRef;                          
    }    


    public PageReference displaySummary() {              

        showSummary = true;

        showError   = false;
        showExport  = false;
        showPeriod  = false;

        PageReference pageRef = page.Core_ChannelData_Single;
        pageRef.getParameters().put('Id', account.Id);        
        pageRef.setRedirect(false); 
        return pageRef;                          
    }    


    public PageReference exportCSV(){    
   
       System.debug('#33 exportCSV->soPeriod: ' + soPeriod);

       showSummary = false;
   
       PageReference pageRef = page.Core_Channel_Data_Export_Single;
       pageRef.getParameters().put('Id', account.Id);        
       pageRef.setRedirect(false);        
       return pageRef;
    }        
    
    
    public PageReference exportSummary(){    
   
       System.debug('#43 exportSummary->soPeriod: ' + soPeriod);
 
       showSummary = true;
   
       PageReference pageRef = page.Core_Channel_Data_Export_Single;
       pageRef.getParameters().put('Id', account.Id);        
       pageRef.setRedirect(false);        
       return pageRef;
    }        
    
    
    public PageReference returntoAccount() {      
        
        PageReference pageRef = new ApexPages.StandardController(account).view();                            
        pageRef.setRedirect(true); 
        return pageRef;                          
    } */  

}