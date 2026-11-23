/******************************************************************************************************************************************
Class Name  : Core_Integration_RDC_AccountRest 
Version     : 1.0 
Created Date: 20 June 2017
Function    : Apex class to expose REST service

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         20/6/2017               Created REST API to retrieve RDC Accounts
* Rajesh kumar              23/7/2017               US107422-Added logic for updated RDC flag to Accounts. 
*****************************************************************************************************************************************/
@RestResource(urlMapping='/RDC/Accounts')
global class Core_Integration_RDC_AccountRest{  
    
    //String  Variables for creating Log Entry
    public static final string LOG_ENTRY_ORIGIN = 'AdobeDAM';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_SCOPE = 'RDCAccounts';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Account';
    public static string LOG_ENTRY_SEVERITY;
    public static string LOG_ENTRY_Message;
    
    //Main Wrapper class for RDC Acounts
    global class AccountWrapper{
        global List<processedAccounts> BUS_ACCOUNTS;
    }
    
    //Child Wrapper class for RDC Accounts
    global class processedAccounts{
        public string ACCT_ID = '';
        public String CIMID = '';
        public String ACCT_ENG_NM = '';
        public String CTRY_CD = '';
        public String REGION = '';
        public String ACCT_NM = '';
        public Boolean ACCT_RDC =False; // US107422-Initialize RDC flag set to false added by-rajesh 
    }
    
    @HttpGet
    //Main Method to retrieve RDC Accounts
    global static AccountWrapper getRDCAccounts() { 
        String subGeo;
        String countryCode;
        boolean hasError; 
        Integer totalAccounts; 
        string logId;
        AccountWrapper wrapAccounts = new AccountWrapper();
        List<processedAccounts> listAccounts = new List<processedAccounts>();
        
        //Creating a list and map for the 2 letter country codes 
        List<Core_Country_Code_Mapping__c> lcs  =   Core_Country_Code_Mapping__c.getall().values();
        Map<String,String> mapCountryCode       =   new  Map<String,String>();
        for(Core_Country_Code_Mapping__c ccm : lcs){
            mapCountryCode.put(ccm.ISO_Code__c,cCM.Country_Code__c);
        }
        
        hasError = false;
        totalAccounts = 0;//For tracking the total no of Accounts 
        Exception exceptionObj = null;
        
        try{ 
            for(Account acctRec: [SELECT Name,Id,Core_CIM_ID__c,Core_English_Only_Name__c,
                                  BillingCountry,Core_Sub_Geo__c,Core_Geo__c,Core_RDC_Content_Restriction__c
                                  FROM Account WHERE  Core_B2B_Entitlement__c = true and Core_CNDA_Number__c!= null  ORDER BY Name limit 50000])
            {   
                countryCode = mapcountrycode.get(acctRec.BillingCountry);
                processedAccounts wrapAccount   = new processedAccounts();
                subGeo                          = acctRec.Core_Sub_Geo__c;
                wrapAccount.ACCT_NM             = acctRec.Name;
                wrapAccount.ACCT_ID             = acctRec.id;
                wrapAccount.ACCT_RDC            = acctRec.Core_RDC_Content_Restriction__c; //US107422-Added  RDC Content Restriction flag added to accounts.
                wrapAccount.CIMID               = acctRec.Core_CIM_ID__c;
                wrapAccount.ACCT_ENG_NM         = acctRec.Core_English_Only_Name__c ;
                wrapAccount.CTRY_CD             = countryCode;
                wrapAccount.REGION              = acctRec.Core_Geo__c+ '-'+ subGeo; 
                
                listAccounts.add(wrapAccount);
                //Increment the total count of Accounts for tracking in log Entry
                totalAccounts +=1;
            }            
            wrapAccounts.BUS_ACCOUNTS = listAccounts;            
        }
        catch(Exception ex) {
            exceptionObj = ex;
            system.debug('Message'+ ex);  
            hasError = true;
        }
        finally{
            LOG_ENTRY_SEVERITY = ( hasError == true ?  LOG_ENTRY_ERROR : LOG_ENTRY_INFO ); 
            LOG_ENTRY_Message =' Total Records processed '+String.valueOf(totalAccounts);
            //Creating a Log Entry record
            logId = Core_Log_Entry.core_Log_Entry(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY, 
                                                  LOG_ENTRY_Message,'',null, LOG_ENTRY_OBJECT, '', exceptionObj);            
            System.debug(' Log ID '+logId);
        }       
        return wrapAccounts;  
    }
}