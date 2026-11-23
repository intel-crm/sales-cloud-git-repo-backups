/**************************************************************************************
Apex Class Name:  Core_Salesout_Search_Controller
Version     : 1.0 
Created Date: 9/14/15
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              9/14/15                Initial Revision
*************************************************************************************/
public class Core_Salesout_Search_Controller {

    public  static final String  NONE_SELECTED             = '--None--';
    public  static final String  ITP_MEMBERSHIP_TIER       = 'ITP Membership Tier';
    public  static final String  ITP_MEMBERSHIP_TIER_FIELD = 'Core_Current_Membership_Tier__c';
    public  static final String  TRAINING_CREDITS          = 'Training Credits';
    public  static final String  TRAINING_CREDITS_FIELD    = 'Core_Training_Credits__c';
    public  static final String  TOTAL_EARNED_POINTS       = 'Total Earned Points';
    public  static final String  TOTAL_EARNED_POINTS_FIELD = 'Core_Total_Earned_Points__c';

    private static final integer SALESOUT_MAX_RECORDS      = 50000;      // For criteria before creating the final list
    private static final integer ACCESS_CHECK_MAX_RECORDS  = 19000;      // 200 * 100 = 20,000, subtract 1000 for a 5 query overhead.
    private static final integer RESULT_MAX_RECORDS        = 5000;       // For the final list 

    private static final String  COVERED_ACCOUNT_TEXT      = 'Covered Account'; 
    private static final String  COVERED_ACCOUNT_FIELD     = 'Core_Account_Name__r.Core_Covered_Account__c';
    
    public String  searchMessage { get; set; }                      // Actual error message
    public String  searchSeverity { get; set; }                     // Actual error message
    public Boolean searchShowMessage { get; set; }                  // Flag to render error message if user didn't enter value for search criteria    

    // DUMP THESE AFTER UPDATING CAMPAIGN_CREATOR  -  START
    public integer iNoOfPages { get; set; }
    public integer iPageNumber { get; set; }
    public Boolean bMoreRecords { get; set; }
    public String  sColumnSize { get; set; }
    // DUMP THESE AFTER UPDATING CAMPAIGN_CREATOR  -  END

    // Account
    public String acField1 { get; set; }
    public String acField2 { get; set; }
    public String acField3 { get; set; }
    
    public String acOp1 { get; set; }
    public String acOp2 { get; set; }
    public String acOp3 { get; set; }
    
    public String acValue1 { get; set; }
    public String acValue2 { get; set; }
    public String acValue3 { get; set; }
    
    // Program Membership
    public String pmField1 { get; set; }
    public String pmField2 { get; set; }
    public String pmField3 { get; set; }
    
    public String pmOp1 { get; set; }
    public String pmOp2 { get; set; }
    public String pmOp3 { get; set; }
    
    public String pmValue1 { get; set; }
    public String pmValue2 { get; set; }
    public String pmValue3 { get; set; }
    
    // Salesout
    public String soField1 { get; set; }
    public String soField2 { get; set; }
    public String soField3 { get; set; }
    
    public String soOp1 { get; set; }
    public String soOp2 { get; set; }
    public String soOp3 { get; set; }
    
    public String soValue1 { get; set; }
    public String soValue2 { get; set; }
    public String soValue3 { get; set; }

    public List<SelectOption> lstPeriodRange { get; set; }

    public List<SelectOption> lstDefaultField1 {
        get {
            if (lstDefaultField1 == NULL) {
                lstDefaultField1 = new List<SelectOption>();
                lstDefaultField1.add(new SelectOption('Period',  'Period'));
            }
            return lstDefaultField1;
        }
        set {
            lstDefaultField1 = value;                
        }
    }


    public List<SelectOption> lstComparisonOperators {
        get {
            if (lstComparisonOperators == NULL) {
                lstComparisonOperators = new List<SelectOption>();
                lstComparisonOperators.add(new SelectOption('',  NONE_SELECTED));
                lstComparisonOperators.add(new SelectOption('e', 'equals'));
                lstComparisonOperators.add(new SelectOption('n', 'not equal to'));
                lstComparisonOperators.add(new SelectOption('s', 'starts with'));
                lstComparisonOperators.add(new SelectOption('c', 'contains'));
                lstComparisonOperators.add(new SelectOption('k', 'does not contain'));
                lstComparisonOperators.add(new SelectOption('l', 'less than'));
                lstComparisonOperators.add(new SelectOption('g', 'greater than'));
                lstComparisonOperators.add(new SelectOption('m', 'less or equal'));
                lstComparisonOperators.add(new SelectOption('h', 'greater or equal'));
            }
            return lstComparisonOperators;
        }
        set {
            lstComparisonOperators = value;                
        }
    }


    public List<SelectOption> lstDateOperators {
        get {
            if (lstDateOperators == NULL) {
                lstDateOperators = new List<SelectOption>();
                lstDateOperators.add(new SelectOption('',  NONE_SELECTED));
                lstDateOperators.add(new SelectOption('e', 'equals'));
                lstDateOperators.add(new SelectOption('n', 'not equal to'));
                lstDateOperators.add(new SelectOption('l', 'less or equal'));
                lstDateOperators.add(new SelectOption('g', 'greater or equal'));
            }
            return lstDateOperators;
        }
        set {
            lstDateOperators = value;                
        }
    }


    public List<SelectOption> lstSalesOutFields {
        get {
            if (lstSalesOutFields == NULL)
            {
                lstSalesOutFields = new List<SelectOption>();
                lstSalesOutFields.add(new SelectOption('', NONE_SELECTED));
                lstSalesOutFields.add(new SelectOption('Core_Product_Level_3__c',     'Product'));
                lstSalesOutFields.add(new SelectOption('Core_Distributor_Name__c',    'Distributor Name'));
                lstSalesOutFields.add(new SelectOption('Core_Business_Country__c',    'Country'));
                lstSalesOutFields.add(new SelectOption('Core_Business_Geo__c',        'Geo'));
                lstSalesOutFields.add(new SelectOption('Core_Form_Factor_Level2__c',  'Formfactor'));
            }
            return lstSalesOutFields;
        }
        set {
            lstSalesOutFields = value;
        }
    }        


    public List<SelectOption> lstProgramMembershipFields {
        get {
            if (lstProgramMembershipFields == NULL)
            {
                lstProgramMembershipFields = new List<SelectOption>();
                lstProgramMembershipFields.add(new SelectOption('',                        NONE_SELECTED));
                lstProgramMembershipFields.add(new SelectOption(ITP_MEMBERSHIP_TIER_FIELD, ITP_MEMBERSHIP_TIER));
                lstProgramMembershipFields.add(new SelectOption(TRAINING_CREDITS_FIELD,    TRAINING_CREDITS));
                lstProgramMembershipFields.add(new SelectOption(TOTAL_EARNED_POINTS_FIELD, TOTAL_EARNED_POINTS));
            }
            return lstProgramMembershipFields;
        }
        set {
            lstProgramMembershipFields = value;
        }
    }        


    public List<SelectOption> lstAccountFields {
        get {
            if (lstAccountFields == NULL)
            {
                lstAccountFields = new List<SelectOption>();
                lstAccountFields.add(new SelectOption('', NONE_SELECTED));
                lstAccountFields.add(new SelectOption('Core_Account_Name__r.Core_Sales_Segment__c',   'Sales Segment'));
                lstAccountFields.add(new SelectOption('Core_Account_Name__r.Industry',                'Industry'));
                lstAccountFields.add(new SelectOption('Core_Account_Name__r.Core_Account_Type__c',    'Account Type'));
                lstAccountFields.add(new SelectOption('Core_Account_Name__r.Owner.Name',              'Account Owner'));
                lstAccountFields.add(new SelectOption('Core_Account_Name__r.Name',                    'Account Name'));
                lstAccountFields.add(new SelectOption('Core_Account_Name__r.Core_GEO__c',             'Account Geo'));
                lstAccountFields.add(new SelectOption('Core_Account_Name__r.Core_Account_Country__c', 'Country'));
                lstAccountFields.add(new SelectOption('Core_Account_Name__r.Core_Covered_Account__c', COVERED_ACCOUNT_TEXT));
            }
            return lstAccountFields;
        }
        set {
            lstAccountFields = value;
        }
    }        


    public String getLabelFromValue(List<SelectOption> lstSelOp, String value) {
        for (SelectOption selOp : lstSelOp)
            if (selOp.getValue() == value)
                return selOp.getLabel();
                
        return '';        
    }


    public Boolean isMultiPicklist(String fieldName) {
        if (fieldName == 'Core_Account_Name__r.Core_Sales_Segment__c')
            return true;

        if (fieldName == 'Core_Account_Name__r.Core_Account_Type__c')
            return true;

        return false;
    }


    private Boolean maxLimitExceeded = false;
    private Integer maxLimitCount;


    // Constructor
    public Core_Salesout_Search_Controller(ApexPages.StandardController controller) {

        // Setting the flag to false which is used for showing error message if there are no records retrived for the search criteria
        searchMessage     = '';
        searchSeverity    = 'error';
        searchShowMessage = false;

        Date currentDate  = Date.today();

        // MUST use a Double in the Ceiling function
        Double doubleMonth = currentDate.month();                                                    
        Integer currentQuarter = Integer.valueOf(Math.Ceil(doubleMonth/3));  // MUST USE DOUBLE
        // System.debug(LoggingLevel.Info, '#48 currentQuarter: ' + currentQuarter);
        
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
        soValue1 = lstPeriodRange.get(0).getValue();        
        soField1 = lstDefaultField1.get(0).getValue();
        soOp1    = lstDateOperators.get(1).getValue();

        //System.debug(LoggingLevel.Info, '#60 soValue1: ' + soValue1 + '     soField1: ' + soField1);

    }


    /*
     * Method name  : getWhereClause
     * Description  : Method to add the where clause part based on the value provided by user.
     * Return Type  : VOID
     * Parameter    : String
     */
    private String getWhereClause() {
    
        String whereClause = salesoutPeriodCriteria();

        // Account fields
        if (!String.isblank(acField1))    
            whereClause = addCriteria(acField1, acOp1, acValue1, whereClause);    

        if (!String.isblank(acField2))    
            whereClause = addCriteria(acField2, acOp2, acValue2, whereClause);    

        if (!String.isblank(acField3))    
            whereClause = addCriteria(acField3, acOp3, acValue3, whereClause);    


        // *** Program Member fields *** //


        // Sales Out fields
        //
        // Salesout Period is a required field that requires translation
        //
        if (!String.isblank(soField2))    
            whereClause = addCriteria(soField2, soOp2, soValue2, whereClause);    

        if (!String.isblank(soField3))    
            whereClause = addCriteria(soField3, soOp3, soValue3, whereClause);    

        if (whereClause != NULL)
            whereClause = whereClause.removeEnd(' AND ');

        //System.debug(LoggingLevel.Info, '#66 whereClause: ' + whereClause);
        
        return whereClause;
    }


    // Exposing Salesout WHERE logic for CampaignCreator to help with 
    // aggregate values for Component Count and Component $
    //
    public String getSalesoutWhereClause()
    {
        // Salesout Period is a required field that requires translation
        //
        String whereClause = salesoutPeriodCriteria();

        // Sales Out fields
        //
        if (!String.isblank(soField2))    
            whereClause = addCriteria(soField2, soOp2, soValue2, whereClause);    

        if (!String.isblank(soField3))    
            whereClause = addCriteria(soField3, soOp3, soValue3, whereClause);    

        if (whereClause != NULL)
            whereClause = whereClause.removeEnd(' AND ');

        return whereClause;        
    }


    private String salesoutPeriodCriteria() {
        //System.debug(LoggingLevel.Info, '#61 soValue1: ' + soValue1);
        List<String> str = soValue1.split('-');
        //System.debug(LoggingLevel.Info, '#62 str: ' + str);
  
        integer quarter = (integer.valueof(str.get(0)) * 100) + integer.valueof(str.get(1));

        //System.debug(LoggingLevel.Info, '#63 quarter: ' + quarter);
    
        if (soOp1 == 'e')
            return ' WHERE (Core_Invoice_Quarter__c = ' + quarter + ') AND ';

        if (soOp1 == 'n')
            return ' WHERE (Core_Invoice_Quarter__c != ' + quarter + ') AND ';
                
        if (soOp1 == 'l')
            return ' WHERE (Core_Invoice_Quarter__c <= ' + quarter + ') AND ';
    
        if (soOp1 == 'g')
            return ' WHERE (Core_Invoice_Quarter__c >= ' + quarter + ') AND ';
    
        return '';
    }


    public String addCriteria(String fld, String op, String value, String whereClause) {
        if (String.isblank(fld) || String.isblank(op) || String.isblank(value))
            return whereClause;

        if (String.isblank(whereClause))
            whereClause = ' WHERE ';
            
        if (value == 'true' || value == 'false')
            return addBooleanCriteria(fld, op, value, whereClause);

        if (op == 'e')
            return whereClause + ' ' + fld + ' = \'' + value + '\' AND ';

        if (op == 'n')
            return whereClause + ' ' + fld + ' != \'' + value + '\' AND ';
            
        if (op == 's') {
            if (isMultiPicklist(fld))
                return whereClause + ' ' + fld + ' INCLUDES (\'' + value + '\') AND ';
            else
                return whereClause + ' ' + fld + ' LIKE \'' + value + '%\' AND ';
        }
    
        if (op == 'c') {
            if (isMultiPicklist(fld))
                return whereClause + ' ' + fld + ' INCLUDES (\'' + value + '\') AND ';
            else
                return whereClause + ' ' + fld + ' LIKE \'%' + value + '%\' AND ';
        }
    
        if (op == 'k') {
            if (isMultiPicklist(fld))
                return whereClause + ' ' + fld + ' EXCLUDES (\'' + value + '\') AND ';
            else    
                return whereClause + ' (NOT ' + fld + ' LIKE = \'%' + value + '%\') AND ';
        }

        if (isMultiPicklist(fld) && ((op == 'l') || (op == 'g') || (op == 'm') || (op == 'h'))) {
            searchShowMessage = true;
            searchMessage     = 'Please use "equals", "not equal to", "starts with", "contains" or "does not contain" for searching multi-select picklist field: "' + getLabelFromValue(lstAccountFields, fld) + '".';
            searchSeverity    = 'error';
            return NULL;
        }

        if (op == 'l')
            return whereClause + ' ' + fld + ' < \'' + value + '\' AND ';
    
        if (op == 'g')
            return whereClause + ' ' + fld + ' > \'' + value + '\' AND ';
    
        if (op == 'm')
            return whereClause + ' ' + fld + ' >= \'' + value + '\' AND ';
    
        if (op == 'h')
            return whereClause + ' ' + fld + ' <= \'' + value + '\' AND ';    

        return whereClause;
    }


    public String addNumericCriteria(String fld, String op, String value, String whereClause, List<SelectOption> fieldList) {
        if (String.isblank(fld) || String.isblank(op) || String.isblank(value))
            return whereClause;

        if (String.isblank(whereClause))
            whereClause = ' WHERE ';
            
        if (value == 'true' || value == 'false')
            return addBooleanCriteria(fld, op, value, whereClause);

        if (op == 'e')
            return whereClause + ' ' + fld + ' = ' + value + ' AND ';

        if (op == 'n')
            return whereClause + ' ' + fld + ' != ' + value + ' AND ';
            
        // Throw error message for string operators    
        if ((op == 's') || (op == 'c') || (op == 'k')) {
            searchShowMessage = true;
            searchMessage     = 'Please use "equals", "not equal to", "less than", "less or equal", "greater than" or "greater or equal" for searching numeric field: "' + getLabelFromValue(fieldList, fld) + '".';
            searchSeverity    = 'error';
            return NULL;    
        }
    
        if (op == 'l')
            return whereClause + ' ' + fld + ' < ' + value + ' AND ';
    
        if (op == 'g')
            return whereClause + ' ' + fld + ' > ' + value + ' AND ';
    
        if (op == 'm')
            return whereClause + ' ' + fld + ' >= ' + value + ' AND ';
    
        if (op == 'h')
            return whereClause + ' ' + fld + ' <= ' + value + ' AND ';    

        return whereClause;
    }


    private String addBooleanCriteria(String fld, String op, String value, String whereClause) {
       
        //System.debug(LoggingLevel.Info, '#49 addBooleanCriteria value: ' + value);        
        if (op == 'e')
            return whereClause + ' ' + fld + ' = ' + value + ' AND ';

        if (op == 'n')
            return whereClause + ' ' + fld + ' != ' + value + ' AND ';
            
        // default to "equal"    
        return whereClause + ' ' + fld + ' = ' + value + ' AND ';
    }


    private Boolean validUserInputs() {
        if ((!String.isblank(acField1) || !String.isblank(acOp1) || !String.isblank(acValue1)) &&
            (String.isblank(acField1) || String.isblank(acOp1) || String.isblank(acValue1)))
        {
            searchShowMessage = true;                        
            searchMessage     = 'Invalid Account search criteria';                  
            searchSeverity    = 'error';
            return false;  
        }  
        
        if ((!String.isblank(acField2) || !String.isblank(acOp2) || !String.isblank(acValue2)) &&
            (String.isblank(acField2) || String.isblank(acOp2) || String.isblank(acValue2)))
        {
            searchShowMessage = true;                        
            searchMessage     = 'Invalid Account search criteria';                  
            searchSeverity    = 'error';
            return false;  
        }  
        
        if ((!String.isblank(acField3) || !String.isblank(acOp3) || !String.isblank(acValue3)) &&
            (String.isblank(acField3) || String.isblank(acOp3) || String.isblank(acValue3)))
        {
            searchShowMessage = true;                        
            searchMessage     = 'Invalid Account search criteria';                  
            searchSeverity    = 'error';
            return false;  
        }  
        
        if ((!String.isblank(pmField1) || !String.isblank(pmOp1) || !String.isblank(pmValue1)) &&
            (String.isblank(pmField1) || String.isblank(pmOp1) || String.isblank(pmValue1)))
        {
            searchShowMessage = true;                        
            searchMessage     = 'Invalid Program Membership search criteria';                  
            searchSeverity    = 'error';
            return false;  
        }  
        
        if ((!String.isblank(pmField2) || !String.isblank(pmOp2) || !String.isblank(pmValue2)) &&
            (String.isblank(pmField2) || String.isblank(pmOp2) || String.isblank(pmValue2)))
        {
            searchShowMessage = true;                        
            searchMessage     = 'Invalid Program Membership search criteria';                  
            searchSeverity    = 'error';
            return false;  
        }  
        
        if ((!String.isblank(pmField3) || !String.isblank(pmOp3) || !String.isblank(pmValue3)) &&
            (String.isblank(pmField3) || String.isblank(pmOp3) || String.isblank(pmValue3)))
        {
            searchShowMessage = true;                        
            searchMessage     = 'Invalid Program Membership search criteria';                  
            searchSeverity    = 'error';
            return false;  
        }  
        
        // soFiel1 - "Period" : Is automatically loaded.  soOp1 must be user supplied.
        //
        //System.Debug(LoggingLevel.Info, '#67 validUserInputs : soOp1: ' + soOp1);
        if (String.isblank(soOp1))
        {
            searchShowMessage = true;                        
            searchMessage     = 'A Salesout Period Operator must be selected';                  
            searchSeverity    = 'error';
            return false;  
        }  
        
        if ((!String.isblank(soField2) || !String.isblank(soOp2) || !String.isblank(soValue2)) &&
            (String.isblank(soField2) || String.isblank(soOp2) || String.isblank(soValue2)))
        {
            searchShowMessage = true;                        
            searchMessage     = 'Invalid Sales Out search criteria';                  
            searchSeverity    = 'error';
            return false;  
        }  
        
        if ((!String.isblank(soField3) || !String.isblank(soOp3) || !String.isblank(soValue3)) &&
            (String.isblank(soField3) || String.isblank(soOp3) || String.isblank(soValue3)))
        {
            searchShowMessage = true;                        
            searchMessage     = 'Invalid Sales Out search criteria';                  
            searchSeverity    = 'error';
            return false;  
        }  
        
        return true;          
    }


    public Boolean accountFieldValidation() {
        //System.debug(LoggingLevel.Info, '#22 acField1: ' + acField1 + ';  acField2: ' + acField2 + ';  acField3: ' + acField3);
        if ((acField1 == COVERED_ACCOUNT_FIELD && (acValue1 != 'true' && acValue1 != 'false')) ||
            (acField2 == COVERED_ACCOUNT_FIELD && (acValue2 != 'true' && acValue2 != 'false')) ||
            (acField3 == COVERED_ACCOUNT_FIELD && (acValue3 != 'true' && acValue3 != 'false'))) {        
            searchShowMessage = true;                        
            searchMessage     = 'Covered Account value must be "true" or "false"';                  
            searchSeverity    = 'error';
            return false;  
        }

        return true;
    }


    /*
     * Method name  : Search
     * Description  : Method to search opportunity records when users enters the search criteria to search.
     * Return Type  : None
     * Parameter    : PageReference
     */
    public PageReference search() {
        
        //System.debug(LoggingLevel.Info, '#24 Search - START');

        maxLimitExceeded  = false;      
        searchShowMessage = false;    

        if (!validUserInputs())
            return NULL;

        if (!accountFieldValidation())
            return NULL;

        //System.debug(LoggingLevel.Info, '#25 Validation Passed');

        String salesoutQuery;
        salesOutQuery = 'SELECT Core_Account_Name__c FROM Core_Channel_Salesout__c ';    
        salesOutQuery += getWhereClause();
        salesoutQuery += ' LIMIT ' + SALESOUT_MAX_RECORDS;

        System.debug(LoggingLevel.Info, '#56 salesoutQuery: ' + salesoutQuery);

        List<Core_Channel_Salesout__c> lstSalesout = Database.query(salesoutQuery);

        System.debug(LoggingLevel.Info, '#57 lstSalesout.size(): ' + lstSalesout.size());

        maxLimitExceeded = (lstSalesout.size() == SALESOUT_MAX_RECORDS);

        if (maxLimitExceeded) {
            searchShowMessage = true;
            searchMessage     = 'Maximum limit of ' + RESULT_MAX_RECORDS + ' reached, please refine your criteria (Initial count exceeded).';
            searchSeverity    = 'error';
            return NULL;
        }


        Set<Id> setSalesoutId = new Set<Id>();
        for (Core_Channel_Salesout__c so : lstSalesout)
            setSalesoutId.add(so.Core_Account_Name__c);


        if (!String.isblank(pmField1) || !String.isblank(pmField2) || !String.isblank(pmField3))    
        {
            setSalesoutId = applyProgramMembershipCriteria(setSalesoutId);
            if (searchShowMessage == true)
                return NULL;
        }

        // Taking an OR in case something else has set maxLimitExceeded to true.
        //        
        maxLimitExceeded = maxLimitExceeded || (setSalesoutId.size() > ACCESS_CHECK_MAX_RECORDS);
        if (maxLimitExceeded) {
            searchShowMessage = true;
            searchMessage     = 'Maximum limit of ' + RESULT_MAX_RECORDS + ' accounts reached, please refine your criteria (Filtered count exceeded).';
            searchSeverity    = 'error';
            return NULL;
        }

        // Qualify Account Owners, Account Team Members, Territory Members, Sharing Rules       
        Set<Id> setTargetId = Core_Test_Utility.validateAccountAccess(Id.valueOf(userInfo.getUserId()), setSalesoutId);        
        //System.debug(LoggingLevel.Info, '#58 After validateAccountAccess setTargetId.size(): ' + setTargetId.size());


        // Taking an OR in case something else has set maxLimitExceeded to true.
        //        
        maxLimitExceeded = maxLimitExceeded || (setTargetId.size() > RESULT_MAX_RECORDS);
        if (maxLimitExceeded) {
            searchShowMessage = true;
            searchMessage     = 'Maximum limit of ' + RESULT_MAX_RECORDS + ' accounts reached, please refine your criteria (Final count exceeded).';
            searchSeverity    = 'error';
            return NULL;
        }

        if (setTargetId.size() == 0)        
        {
            searchShowMessage = true;                        
            searchMessage     = 'Records found: 0';                  
            searchSeverity    = 'info';
            return NULL;  
        }


        Core_Campaign_Member_Creator.soStaticWhereClause = getSalesoutWhereClause();

        Core_Campaign_Member_Creator.setTargetId.clear();    
        Core_Campaign_Member_Creator.setTargetId.addAll(setTargetId);
                          
        //System.debug(LoggingLevel.Info, '#44 Core_Campaign_Member_Creator.setTargetId.size():' + Core_Campaign_Member_Creator.setTargetId.size());
                
        PageReference pageRef = Page.Core_CampaignCreator;
        pageRef.setRedirect(false);
        return pageRef;                  

    }


    private Set<Id> applyProgramMembershipCriteria(Set<Id> setSalesoutId) {

        System.debug(LoggingLevel.DEBUG, '#22 applyProgramMembershipCritteria  setSalesoutId:' + setSalesoutId.size() + '  pmField1: ' + pmField1);

        if (pmField1 == ITP_MEMBERSHIP_TIER_FIELD)
            setSalesoutId = applyMemberCriteria(pmField1,    pmOp1, pmValue1, setSalesoutId);    
        else if (pmField1 == TRAINING_CREDITS_FIELD)
            setSalesoutId = applyTrainingCriteria(pmField1,  pmOp1, pmValue1, setSalesoutId);    
        else if (pmField1 == TOTAL_EARNED_POINTS_FIELD)
            setSalesoutId = applyLiabilityCriteria(pmField1, pmOp1, pmValue1, setSalesoutId);               

        if (maxLimitExceeded || searchShowMessage)
            return setSalesoutId;

        if (pmField2 == ITP_MEMBERSHIP_TIER_FIELD)
            setSalesoutId = applyMemberCriteria(pmField2,    pmOp2, pmValue2, setSalesoutId);    
        else if (pmField2 == TRAINING_CREDITS_FIELD)
            setSalesoutId = applyTrainingCriteria(pmField2,  pmOp2, pmValue2, setSalesoutId);    
        else if (pmField2 == TOTAL_EARNED_POINTS_FIELD)
            setSalesoutId = applyLiabilityCriteria(pmField2, pmOp2, pmValue2, setSalesoutId);               

        if (maxLimitExceeded || searchShowMessage)
            return setSalesoutId;

        if (pmField3 == ITP_MEMBERSHIP_TIER_FIELD)
            setSalesoutId = applyMemberCriteria(pmField3,    pmOp3, pmValue3, setSalesoutId);    
        else if (pmField3 == TRAINING_CREDITS_FIELD)
            setSalesoutId = applyTrainingCriteria(pmField3,  pmOp3, pmValue3, setSalesoutId);    
        else if (pmField3 == TOTAL_EARNED_POINTS_FIELD)
            setSalesoutId = applyLiabilityCriteria(pmField3, pmOp3, pmValue3, setSalesoutId);               

        return setSalesoutId;
    }
    

    private Set<Id> applyMemberCriteria(String pmField, String pmOp, String pmValue, Set<Id> setSalesoutId) {
        Set<Id> resultIds = new Set<Id>();

        // Find the account that have a MATCH on the search criteria
        // 
        String membersQuery;
        membersQuery = 'SELECT Core_Account_Name__c, Core_Current_Membership_Tier__c ' + 
                       'FROM Core_Channel_Membership__c ' + 
                       'WHERE Core_Account_Name__c IN :setSalesoutId AND ';
        membersQuery = addCriteria(pmField, pmOp, pmValue, membersQuery);    
        membersQuery = membersQuery.removeEnd(' AND ');
        membersQuery = membersQuery + ' LIMIT ' + ACCESS_CHECK_MAX_RECORDS;

        System.debug(LoggingLevel.DEBUG, '#31 membersQuery: ' + membersQuery);

        List<Core_Channel_Membership__c> lstMembers = Database.query(membersQuery);

        if (lstMembers == NULL || (lstMembers.size() == 0))
            return resultIds;

        maxLimitExceeded = (lstMembers.size() == ACCESS_CHECK_MAX_RECORDS);
        if (maxLimitExceeded) 
            return resultIds;
        
        for (Core_Channel_Membership__c cm : lstMembers)
            resultIds.add(cm.Core_Account_Name__c);        

        // Store the MATCHING criteria                
        String membershipTier = lstMembers[0].Core_Current_Membership_Tier__c;        
                                           
        // Find the accounts that have a MATCH on the search criteria that is THEIR MOST RECENT record.
        // Step 1: Get all reords for the accounts with a matching entry, and sort by the most recent 
        // 
        membersQuery = 'SELECT Core_Account_Name__c, Core_Current_Membership_Tier__c, Core_Status_Date__c ' + 
                       'FROM Core_Channel_Membership__c ' + 
                       'WHERE Core_Account_Name__c IN :resultIds ' + 
                       'ORDER BY Core_Account_Name__c, Core_Status_Date__c DESC';
                       
        System.debug('#49 membersQuery: ' + membersQuery);
                
        lstMembers = Database.query(membersQuery);
        System.debug('#50 lstMembers: ' + lstMembers.size());
            
        // Clear previous results, to be used for the final result set.            
        resultIds.clear();    

        // The data is sorted by Account and Status date DESC, so the first occurence of an account
        // is the most recent and it will be used to determine eligibility/
        //            
        Id currentAccount;
        for (integer i=0; i < lstMembers.size(); i++)
        {
             if (currentAccount != lstMembers[i].Core_Account_Name__c)
             {
                 currentAccount = lstMembers[i].Core_Account_Name__c;
                 System.debug('#51 currentAccount: ' + currentAccount + '   lstMembers[i].Core_Account_Name__c:' + lstMembers[i].Core_Account_Name__c);
                 if (lstMembers[i].Core_Current_Membership_Tier__c == membershipTier)
                 {
                    System.debug('#52 lstMembers[i].Core_Current_Membership_Tier__c: ' + lstMembers[i].Core_Current_Membership_Tier__c + '   membershipTier:' + membershipTier);
                    resultIds.add(currentAccount);                          
                 }
             }
        }        
                                
        return resultIds;        
    }    


    private Set<Id> applyTrainingCriteria(String pmField, String pmOp, String pmValue, Set<Id> setSalesoutId) {
        Set<Id> resultIds = new Set<Id>();

        String membersQuery;
        membersQuery = 'SELECT Core_Account__c FROM Core_Training__c WHERE Core_Account__c IN :setSalesoutId AND ';
        membersQuery = addNumericCriteria(pmField, pmOp, pmValue, membersQuery, lstProgramMembershipFields);    // Value must be handled as a numeric
        membersQuery = membersQuery.removeEnd(' AND ');
        membersQuery = membersQuery + ' LIMIT ' + ACCESS_CHECK_MAX_RECORDS;

        System.debug(LoggingLevel.DEBUG, '#92 membersQuery: ' + membersQuery);

        List<Core_Training__c> lstMembers = Database.query(membersQuery);

        if (lstMembers == NULL || lstMembers.size() == 0)
            return resultIds;

        maxLimitExceeded = maxLimitExceeded || (lstMembers.size() == ACCESS_CHECK_MAX_RECORDS);
        if (maxLimitExceeded)
            return resultIds;                

        for (Core_Training__c cm : lstMembers)
            resultIds.add(cm.Core_Account__c);        
                
        return resultIds;        
    }
    

    private Set<Id> applyLiabilityCriteria(String pmField, String pmOp, String pmValue, Set<Id> setSalesoutId) {
        Set<Id> resultIds = new Set<Id>();
                
        // Throw error message for string operators    
        if ((pmOp == 's') || (pmOp == 'c') || (pmOp == 'k')) {
            searchShowMessage = true;
            searchMessage     = 'Please use "equals", "not equal to", "less than", "less or equal", "greater than" or "greater or equal" for searching numeric field: "' + getLabelFromValue(lstProgramMembershipFields, pmField) + '".';
            searchSeverity    = 'error';
            return resultIds;    
        }
        
        String membersQuery;
        membersQuery = 'SELECT Core_Account__c FROM Core_Liability_Points__c WHERE Core_Account__c IN :setSalesoutId AND ';
        membersQuery = addCriteria(pmField, pmOp, pmValue, membersQuery);    // Even though this is a numeric, it must be handled as a STRING.
        membersQuery = membersQuery.removeEnd(' AND ');
        membersQuery = membersQuery + ' LIMIT ' + ACCESS_CHECK_MAX_RECORDS;

        System.debug(LoggingLevel.Info, '#33 membersQuery: ' + membersQuery);

        List<Core_Liability_Points__c> lstMembers = Database.query(membersQuery);

        if (lstMembers == NULL || lstMembers.size() == 0)
            return resultIds;

        maxLimitExceeded = maxLimitExceeded || (lstMembers.size() == ACCESS_CHECK_MAX_RECORDS);
        if (maxLimitExceeded)
            return resultIds;                

        for (Core_Liability_Points__c cm : lstMembers)
            resultIds.add(cm.Core_Account__c);        
                
        return resultIds;        
    }
    

    public pagereference clearFilters() {
    
        PageReference pageRef = Page.Core_Salesout_Search;
        pageRef.setRedirect(true);
        return pageRef;
    }
       
}