/**************************************************************************************
Apex Class Name:  Core_IPS_Backend_TestClass_Utility
Version     : 1.0 
Created Date: 03 09 2015
Function    : To insert and get the records from relative objects
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Kareem Unnisa                      03/09/2015              Original Version
*************************************************************************************/
@isTest
public Class Core_IPS_Backend_TestClass_Utility{

        public static Core_IPS_Product_Organization__c getSupportOrg(){
            Core_IPS_Product_Organization__c ProductOrganization = new Core_IPS_Product_Organization__c(
            Core_IPS_Support_Org_Name__c = 'ccg',
            Core_Organization_Description__c = 'TestDescription'        
        );
        return ProductOrganization;
        }

        public static Core_IPS_Master_Issue_Category__c getMasterIssueCategory()
        {
            Core_IPS_Master_Issue_Category__c masterIssue = new Core_IPS_Master_Issue_Category__c();
            masterIssue.Core_Description__c='Media';
            masterIssue.Core_Status__c='Active';
            masterIssue.Core_Type__c='Case Category';
           
            return masterIssue;
        }
        public static Core_IPS_Environment_Variables__c getEnvidetialsForSuppOrg()
        {
           Core_IPS_Environment_Variables__c envi = new Core_IPS_Environment_Variables__c();
           envi.name = 'operating system';
           envi.Core_Answers__c ='chrome';
           envi.Core_Datatype__c='picklist';
           envi.Core_Description__c='description';
           return envi;
        }
                          
        public static Product2 getProduct(){
            Product2 productRecord = new Product2(
                Name = 'Skylake',
                Core_Sales_Visible_Flag__c = false,
                Core_IPS_Visible_Flag_External__c = true,
                IsActive = true
            );
            return productRecord;
        }                            

        public static Core_IPS_Supported_Product__c getSupportedProduct()
        {
            Core_IPS_Supported_Product__c suppProd = new Core_IPS_Supported_Product__c(
            Core_EOIS__c = false,
            Core_Supported_Product_Name__c = 'skylake'
        );
            return suppProd;
        }
        
        public static Core_IPS_Backend_System__c getBackendSystem()
        {
            Core_IPS_Backend_System__c backSystem = new Core_IPS_Backend_System__c();
            backSystem.Core_IPS_Backend_Connection_String__c='Test Connection';
            backSystem.Core_IPS_Backend_System_Name__c='Test System';
            backSystem.Core_IPS_Backend_System_URL__c='https://test.com';
            backSystem.Core_IPS_Cloud_Internal_URL__c='https://testCloud.com';
            backSystem.Core_IPS_Deactivated__c=false;
            
            return backSystem;
        }

        public static Core_IPS_Backend_Supported_Product_Map__c getBackendId()
        {
            Core_IPS_Backend_Supported_Product_Map__c back = new Core_IPS_Backend_Supported_Product_Map__c();
            back.Core_IPS_Deactivated__c=false;
            return back;
        }

        public static Core_IPS_Backend_Env_Details_Map__c getBackendEnvironmentMap()
        {
            Core_IPS_Backend_Env_Details_Map__c enviMap = new Core_IPS_Backend_Env_Details_Map__c();
            return enviMap;
        }
        public static Core_IPS_Backend_Case_Categories_Map__c getCaseCategories()
        {    
            Core_IPS_Backend_Case_Categories_Map__c categoriesCase = new Core_IPS_Backend_Case_Categories_Map__c();
            return categoriesCase;
        }       
        Public static Core_IPS_Product_Issue_Category__c getCategory()
        {
            Core_IPS_Master_Issue_Category__c masterIssue = new Core_IPS_Master_Issue_Category__c();
            masterIssue.name = 'Test';
            masterIssue.Core_Status__c = 'Active';
            masterIssue.Core_Type__c ='Case Category';
            insert masterIssue;
            
            Core_IPS_Product_Issue_Category__c issueCat =new Core_IPS_Product_Issue_Category__c ();
            
            issuecat.Core_Issue_Category_Name__c = masterIssue.id;
            issuecat.Core_Status__c = 'Active';
            issuecat.Core_Type__c ='Case Category';
            return issuecat;
        }

        public static Core_IPS_Environment_Details__c getCaseEnvironmentalDetails()
        {
            Core_IPS_Environment_Details__c envidet=new Core_IPS_Environment_Details__c();
            envidet.Core_Answer__c='chrome';
            envidet.Core_Question__c='operating system';
           return envidet;
        }
        
        public static Core_IPS_Case_Attachments__c getAttachment()
        {
            Core_IPS_Case_Attachments__c att=new Core_IPS_Case_Attachments__c();
            att.Core_Category__c='category';
            att.Core_File_Description__c='test';
            att.Core_File_GUID__c = 'test1234';
            att.Core_File_Name__c = 'testfile.txt';
            return att;
        }

        public static Core_IPS_Case_Comments__c getCaseComment()
        {
            Core_IPS_Case_Comments__c comm=new Core_IPS_Case_Comments__c();
            comm.Core_IPS_Rich_Comment__c='test comment';
            comm.Core_IPS_Comment__c = 'test comment';
            // added for case comments 
            comm.Core_IPS_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
            return comm;
        }       
        
        //------------------ log entries ------------------
        public static Core_Log_Entry__c getLogEntry()
        {
        Core_Log_Entry__c log = new Core_Log_Entry__c();
        log.Core_Details__c='core details';
        log.Core_Message__c='sample log entry';
        log.Core_Origin__c='test';
        log.Core_Project__c='test project';
        log.Core_Scope__c='class';
        log.Core_Severity__c='critical';
        log.Core_sObjectId__c=null;
        
        log.Core_When__c=date.today();
        return log;
        }
        
   /*****************************************************************************************************
    @Method Info : getListOfLogEntries Method returns List Of Log entries that are eligible to reprocess.
    @param : number of records to be created 'NumOfRec', List of Case records 'caseRecords'
    @Added by : tanvix.chauhan on 05 26 2016
    *****************************************************************************************************/
    
    public static List<Core_Log_Entry__c> getListOfLogEntries(integer NumOfRec, List<Case> caseRecords){
        List<Core_Log_Entry__c> ListOfLogEntries = new List<Core_Log_Entry__c> ();
        
        for(Case c: caseRecords){
            for(Integer i=1;i<=NumOfRec;i++){
                Core_Log_Entry__c LogEntryRecord = new Core_Log_Entry__c(
                    Core_Message__c = 'Log Entry '+i,
                    Core_Project__c = 'IPS Cloud',
                    Core_Origin__c= 'PromoteCase',
                    Core_sObjectType__c= 'sf:Case',
                    Core_sObjectId__c = c.id,
                    Core_Severity__c = 'error',
                    Core_When__c = Datetime.now()
                 
                );
                ListOfLogEntries.add(LogEntryRecord);
            }
        }
        return ListOfLogEntries;
    }
    
    /****************************************************************************************
    @Method Info : getListOfCases Method returns list of Case Records
    @param : Number of records to be created 'NumOfRec', recordType, product, backend system
    @Added by : tanvix.chauhan on 05 26 2016
    *****************************************************************************************/
    
    public static List<Case> getListOfCases(integer NumOfRec, String recordType, Product2 prodRec, Core_IPS_Backend_System__c backend){
        List<Case> ListOfCase = new List<Case> ();
        Id recType = Case.getSObjectType().getDescribe().getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        
        for(Integer i=1;i<=NumOfRec;i++){
            Case CaseRecord = new Case(
                Status = 'New',
                RecordTypeId = recType,
                Core_Severity__c = 'Medium',
                Subject = 'TestSubject '+i,
                Description = 'TestDescription',
                Core_CaseType__c = 'Question',
                productID = prodRec.id,
                Core_IPS_Backend_System__c = backend.id
        
            );
            ListOfCase.add(CaseRecord);
        }
        return ListOfCase;
    }    

}