@isTest
public class Core_IPS_SSLCCase_HandlerTest{
   public static testMethod void EmailProcessTest(){
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        email.subject = 'create a case';
        email.plainTextBody ='{     "subject":"Type of Licensing Issue(from SSLC form)",  "Description":{        "PO:":"&quot;5321365215&quot","License Activation Code/Serial No.:":"123214423<br>NIC/Host/Guard ID: 5123ffdfs","Product Name:":"3rd Generation Intel® Core™ i5 Processors","Description:":"SIO1552959 - [SCIT-SW/NPI/Trumpet/SI2/Q01_0020/IA/W10/FXN] The status of Protected PIN is Not Supported due to Failed to create an protected image when run IA 3.0.0.73 Precheck tool in Client","Contact Name:":"Pooja Khanna","Contact Email":"poojax.khanna@intel.com"   }}';
        envelope.fromAddress = 'testuser@inteltest.com';
        //Custom Setting Data
          Core_IPS_SSLCCase_DefaultData__c ProductData=new Core_IPS_SSLCCase_DefaultData__c();
            ProductData.name='Supported_Product';
            ProductData.Core_IPS_Default_Data__c='Supported_Product';
            ProductData.Core_IPS_Default_data_Id__c=null;
            insert ProductData;
            
            Core_IPS_SSLCCase_DefaultData__c ProjectData=new Core_IPS_SSLCCase_DefaultData__c();
            ProjectData.name='Project';
            ProjectData.Core_IPS_Default_Data__c='Project';
            ProjectData.Core_IPS_Default_data_Id__c=null;
            insert ProjectData;
                    
            Core_IPS_SSLCCase_DefaultData__c CaseTypeData= new Core_IPS_SSLCCase_DefaultData__c();
            CaseTypeData.name='Case Type';
            CaseTypeData.Core_IPS_Default_Data__c='Question';
            insert CaseTypeData;
            
            
            Core_IPS_SSLCCase_DefaultData__c CaseCategoryData= new Core_IPS_SSLCCase_DefaultData__c();
            CaseCategoryData.name='Case Category';
            CaseCategoryData.Core_IPS_Default_Data__c='test';
            CaseCategoryData.Core_IPS_Default_data_Id__c=null;
            insert CaseCategoryData;
            
            Core_IPS_SSLCCase_DefaultData__c CaseSubCategoryData= new Core_IPS_SSLCCase_DefaultData__c();
            CaseSubCategoryData.name='Case Subcategory';
            CaseSubCategoryData.Core_IPS_Default_Data__c='test';
            CaseSubCategoryData.Core_IPS_Default_data_Id__c=null;
            insert CaseSubCategoryData;
            
            Core_IPS_SSLCCase_DefaultData__c IssueSourceData=new Core_IPS_SSLCCase_DefaultData__c();
            IssueSourceData.name='Issue Source';
            IssueSourceData.Core_IPS_Default_Data__c='test';
            insert IssueSourceData;
            
            Core_IPS_SSLCCase_DefaultData__c EnvDetailsData=new Core_IPS_SSLCCase_DefaultData__c();
            EnvDetailsData.name='Case Subcategory Detail'; 
            EnvDetailsData.Core_IPS_Default_Data__c='test';
            insert EnvDetailsData;       
        
        
        // setup controller object
        Core_IPS_SSLCCase_EmailHandler emailHandler= new Core_IPS_SSLCCase_EmailHandler();
        Messaging.InboundEmailResult result = emailHandler.handleInboundEmail(email, envelope);
        
        //Failed Condition
         email.plainTextBody ='{     "subject":"Type of Licensin"g Issue(from SSLC form)",  "Description":{        "PO:":"&quot;5321365215&quot","License Activation Code/Serial No.:":"123214423<br>NIC/Host/Guard ID: 5123ffdfs","Product Name:":"3rd Generation Intel® Core™ i5 Processors","Description:":"SIO1552959 - [SCIT-SW/NPI/Trumpet/SI2/Q01_0020/IA/W10/FXN] The status of Protected PIN is Not Supported due to Failed to create an protected image when run IA 3.0.0.73 Precheck tool in Client","Contact Name:":"Pooja Khanna","Contact Email":"poojaxx.khanna@intel.com"   }}';
       	//email.htmlBody = 'HTML Body Test';
        Messaging.InboundEmailResult failedResult = emailHandler.handleInboundEmail(email, envelope);
        failedResult.message='failed';
        System.assertEquals( result.success  ,true);   
       	            
           }
}