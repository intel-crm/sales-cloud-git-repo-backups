/***************************************************************************************************
* Apex Class Name: Core_IPS_File_AssignSPAccount_Cont_Test
* Version     : 1.0 
* Created Date: Nov 7th 2015
* Function    : Controller Test Class
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vaibhav Dubey              11/07/2015              Created
* Malhotra, Abhimanyu S      01/23/2016              Rewrite
****************************************************************************************************/
@isTest
public class Core_IPS_File_AssignSPAccount_Cont_Test{
    private static Account Accnt; 
    private static Core_IPS_Supported_Product__c SuppProd;
    private static Core_IPS_File_AssignSPAccount_Controller FileAssign;
    private static Core_IPS_File_Upload_Master__c FileUplMaster;
    private static String Prefix;  
/***************************************************************************************************
Method Name:  init
Method Type: Test Data preparation Method
Version     : 1.0 
Created Date: 23rd Jan 2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/23/2016              Create
****************************************************************************************************/
    private static void init(){       
        //Account 
        Accnt = new Account();
        Accnt.Name = 'Test Account';
        Accnt.BillingCountryCode = 'USA';
        Accnt.BillingStateCode = 'AL';
        Accnt.BillingCity = 'Alabama';
        Accnt.BillingStreet = 'street';
        Accnt.Core_IPS_Active__c = true;
        Database.insert(Accnt);
        system.assert(Accnt.Id != null);
        //Support Org
        Core_IPS_Product_Organization__c ProdOrg;
        ProdOrg = TestUtilities.getSupportOrg();
        Database.insert(ProdOrg);
        system.assert(ProdOrg.Id != null);
        //Product
        Product2 Prod = new Product2();
        Prod = TestUtilities.getProduct();
        Database.insert(Prod);
        system.assert(Prod.Id != null);            
        //Supported Product    
        SuppProd = TestUtilities.getSupportedProduct();
        SuppProd.Core_Product_Organization__c = ProdOrg.Id; 
        SuppProd.Core_Product__c = Prod.id;
        SuppProd.Core_Supported_Product_Name__c = Prod.Name;
        SuppProd.Core_EOIS__c = false;
        Database.insert(SuppProd);
        system.assert(SuppProd.Id != null);  
        //File Upload Master
        FileUplMaster = TestUtilities.getFileUploadMasterRecord();
        Database.insert(FileUplMaster);
        system.assert(FileUplMaster.Id != null); 
        //Prefix
        Schema.Describesobjectresult IPSFileUploadPage = Schema.Sobjecttype.Core_IPS_File_Upload_Master__c;
        Prefix = IPSFileUploadPage.getKeyPrefix();  
        // Custom Setting
        List<Core_IPS_Error_Code__c> lstIPSErrorCodes = new List<Core_IPS_Error_Code__c>();
        for (Integer i = 0; i < 4; i++) {
            Core_IPS_Error_Code__c IPSErrorCode = new Core_IPS_Error_Code__c();
            //Rowcause_Owner
            if (i == 0) {    
                IPSErrorCode.Name = 'F100';
                IPSErrorCode.Core_Error_Message__c = 'Supported Product and Account, both can not be blank';
                lstIPSErrorCodes.add(IPSErrorCode);
            }
            if (i == 1) {    
                IPSErrorCode.Name = 'F101';
                IPSErrorCode.Core_Error_Message__c = 'Record entered at Row No:';
                lstIPSErrorCodes.add(IPSErrorCode);
            }
            if (i == 2) {    
                IPSErrorCode.Name = 'F102';
                IPSErrorCode.Core_Error_Message__c = 'already associated to this File';
                lstIPSErrorCodes.add(IPSErrorCode);
            }
            if (i == 3) {    
                IPSErrorCode.Name = 'F103';
                IPSErrorCode.Core_Error_Message__c = 'Similar record has been added multiple times';
                lstIPSErrorCodes.add(IPSErrorCode);
            }
        }
        Database.insert(lstIPSErrorCodes);
    }
    
/***************************************************************************************************
Method Name:  AssignSPAcc
Method Type: Test Method
Version     : 1.0 
Created Date: 01/23/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/23/2016              Create
****************************************************************************************************/  
    public static TestMethod void AssignSPAcc(){  
        Integer LogCount;
        init();   
        Test.startTest();
        //commented for Classic EOL: Tejaswini
    /*    PageReference pf = page.Core_IPS_File_AssignSPAccount;
        Test.setCurrentPage(pf); */
        ApexPages.currentPage().getParameters().put('Id',FileUplMaster.id);
        ApexPages.StandardController cont = new ApexPages.StandardController(FileUplMaster);
        FileAssign = new Core_IPS_File_AssignSPAccount_Controller(cont);
        for(Core_IPS_File_AssignSPAccount_Controller.Wrapper wrp : FileAssign.wrplist)
        {
            wrp.fps.Core_Account__c = Accnt.id ;
            wrp.fps.Core_Supported_Product__c = SuppProd.id ;
        }  
        String nextPage = FileAssign.saveRecord().getUrl();   
        Test.stopTest();
        LogCount = [select count() from Core_IPS_File_Assignment__c];
        system.assertEquals(1,LogCount); 
        System.assertEquals('/'+ FileUplMaster.id, nextPage);
    }
/***************************************************************************************************
Method Name:  AssignSPAccNoId
Method Type: Test Method
Version     : 1.0 
Created Date: 01/23/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/23/2016              Create
****************************************************************************************************/    
    public static TestMethod void AssignSPAccNoId(){   
        Integer LogCount;
        init();   
        Test.startTest();
        //commented for Classic EOL: Tejaswini
    /*    PageReference pf = page.Core_IPS_File_AssignSPAccount;
        Test.setCurrentPage(pf); */
        ApexPages.currentPage().getParameters().put('Id',FileUplMaster.id);
        ApexPages.StandardController cont = new ApexPages.StandardController(FileUplMaster);
        FileAssign = new Core_IPS_File_AssignSPAccount_Controller(cont);
        FileAssign.IPSFileUploadID = null;
        for(Core_IPS_File_AssignSPAccount_Controller.Wrapper wrp : FileAssign.wrplist)
        {
            wrp.fps.Core_Account__c = Accnt.id ;
            wrp.fps.Core_Supported_Product__c = SuppProd.id ;
        }  
        String nextPage = FileAssign.saveRecord().getUrl();   
        Test.stopTest();
        LogCount = [select count() from Core_IPS_File_Assignment__c];
        system.assertEquals(1,LogCount);       
        System.assertEquals('/' + prefix + '/o', nextPage);
    }
/***************************************************************************************************
Method Name:  AssignSPAccDuplicateEntry
Method Type: Test Method
Version     : 1.0 
Created Date: 01/23/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/23/2016              Create
****************************************************************************************************/        
    public static TestMethod void AssignSPAccDuplicateEntry(){ 
        PageReference ResultPgRef;
        init(); 
        Test.startTest();  
        //commented for Classic EOL: Tejaswini
    /*    PageReference pf = page.Core_IPS_File_AssignSPAccount;
        Test.setCurrentPage(pf); */
        ApexPages.currentPage().getParameters().put('Id',FileUplMaster.id);
        ApexPages.StandardController cont = new ApexPages.StandardController(FileUplMaster);
        FileAssign = new Core_IPS_File_AssignSPAccount_Controller(cont);
        FileAssign.addRow();
        for(Core_IPS_File_AssignSPAccount_Controller.Wrapper wrp : FileAssign.wrplist)
        {
            wrp.fps.Core_Account__c = Accnt.id ;
            wrp.fps.Core_Supported_Product__c = SuppProd.id ;
        }    
        ResultPgRef = FileAssign.saveRecord();
        Test.stopTest();
        system.assertEquals(ResultPgRef, null);
        // get the list of ApexPages.Message
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for(ApexPages.Message msg : msgList) {
            System.assert(msg.getSummary()!= null);
            System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
        }        
    }
/***************************************************************************************************
Method Name:  AssignSPAccDuplicateDB
Method Type: Test Method
Version     : 1.0 
Created Date: 01/23/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/23/2016              Create
****************************************************************************************************/        
    public static TestMethod void AssignSPAccDuplicateDB(){  
        PageReference ResultPgRef;
        init(); 
        Test.startTest();
        Core_IPS_File_Assignment__c CIPSFA = new Core_IPS_File_Assignment__c();
        CIPSFA.Core_Account__c = Accnt.id;
        CIPSFA.Core_Supported_Product__c = SuppProd.id;
        CIPSFA.Core_IPS_File_Upload_Master__c = FileUplMaster.id;
        insert CIPSFA;
        //commented for Classic EOL: Tejaswini
    /*    PageReference pf = page.Core_IPS_File_AssignSPAccount;
        Test.setCurrentPage(pf); */
        ApexPages.currentPage().getParameters().put('Id',FileUplMaster.id);
        ApexPages.StandardController cont = new ApexPages.StandardController(FileUplMaster);
        FileAssign = new Core_IPS_File_AssignSPAccount_Controller(cont);
        for(Core_IPS_File_AssignSPAccount_Controller.Wrapper wrp : FileAssign.wrplist)
        {
            wrp.fps.Core_Account__c = Accnt.id ;
            wrp.fps.Core_Supported_Product__c = SuppProd.id ;
        }    
        ResultPgRef = FileAssign.saveRecord();
        Test.stopTest();
        system.assertEquals(ResultPgRef, null);
        // get the list of ApexPages.Message
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for(ApexPages.Message msg : msgList) {
            System.assert(msg.getSummary()!= null);
            System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
        }             
    }
/***************************************************************************************************
Method Name:  AssignSPAccBlankLines
Method Type: Test Method
Version     : 1.0 
Created Date: 01/23/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/23/2016              Create
****************************************************************************************************/          
    public static TestMethod void AssignSPAccBlankLines(){  
        PageReference ResultPgRef;
        init(); 
        Test.startTest();
        //commented for Classic EOL: Tejaswini
    /*    PageReference pf = page.Core_IPS_File_AssignSPAccount;
        Test.setCurrentPage(pf); */
        ApexPages.currentPage().getParameters().put('Id',FileUplMaster.id);
        ApexPages.StandardController cont = new ApexPages.StandardController(FileUplMaster);
        FileAssign = new Core_IPS_File_AssignSPAccount_Controller(cont);
        ResultPgRef = FileAssign.saveRecord();
        Test.stopTest();
        system.assertEquals(ResultPgRef, null);
        // get the list of ApexPages.Message
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for(ApexPages.Message msg : msgList) {
            System.assert(msg.getSummary()!= null);
            System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
        }             
    }   
/***************************************************************************************************
Method Name:  AssignSPAccDeleteEntry
Method Type: Test Method
Version     : 1.0 
Created Date: 01/23/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/23/2016              Create
****************************************************************************************************/           
    public static TestMethod void AssignSPAccDeleteEntry(){ 
        Integer LogCount;    
        Integer Index = 0;    
        PageReference ResultPgRef;
        init(); 
        Test.startTest();   
        //commented for Classic EOL: Tejaswini
    /*    PageReference pf = page.Core_IPS_File_AssignSPAccount;
        Test.setCurrentPage(pf); */
        ApexPages.currentPage().getParameters().put('Id',FileUplMaster.id);
        ApexPages.StandardController cont = new ApexPages.StandardController(FileUplMaster);
        FileAssign = new Core_IPS_File_AssignSPAccount_Controller(cont);
        FileAssign.addRow();    
        for(Core_IPS_File_AssignSPAccount_Controller.Wrapper wrp : FileAssign.wrplist)
        {
            Index++;
            if (Index == 1){
                wrp.flag = true; 
            }
        }    
        FileAssign.delRow();
        for(Core_IPS_File_AssignSPAccount_Controller.Wrapper wrp : FileAssign.wrplist)
        {
            wrp.fps.Core_Account__c = Accnt.id ;
            wrp.fps.Core_Supported_Product__c = SuppProd.id ;
        }    
        String nextPage = FileAssign.saveRecord().getUrl();   
        Test.stopTest();
        LogCount = [select count() from Core_IPS_File_Assignment__c];
        system.assertEquals(1,LogCount); 
        System.assertEquals('/'+ FileUplMaster.id, nextPage);  
    }                 
/***************************************************************************************************
Method Name:  AssignSPAccCancelEntry
Method Type: Test Method
Version     : 1.0 
Created Date: 01/23/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/23/2016              Create
****************************************************************************************************/               
    public static TestMethod void AssignSPAccCancelEntry(){  
        PageReference ResultPgRef;
        init(); 
        Test.startTest();
        //commented for Classic EOL: Tejaswini
    /*    PageReference pf = page.Core_IPS_File_AssignSPAccount;
        Test.setCurrentPage(pf); */
        ApexPages.currentPage().getParameters().put('Id',FileUplMaster.id);
        ApexPages.StandardController cont = new ApexPages.StandardController(FileUplMaster);
        FileAssign = new Core_IPS_File_AssignSPAccount_Controller(cont);
        String nextPage = FileAssign.cancelRecord().getUrl();                   
        Test.stopTest();
        System.assertEquals('/' + FileUplMaster.Id, nextPage);
        
    }   
/***************************************************************************************************
Method Name:  AssignSPAccCancelEntryNoId
Method Type: Test Method
Version     : 1.0 
Created Date: 01/23/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/23/2016              Create
****************************************************************************************************/                 
    public static TestMethod void AssignSPAccCancelEntryNoId(){  
        PageReference ResultPgRef;
        init(); 
        Test.startTest();
        //commented for Classic EOL: Tejaswini
    /*    PageReference pf = page.Core_IPS_File_AssignSPAccount;
        Test.setCurrentPage(pf); */
        ApexPages.currentPage().getParameters().put('Id',FileUplMaster.id);
        ApexPages.StandardController cont = new ApexPages.StandardController(FileUplMaster);
        FileAssign = new Core_IPS_File_AssignSPAccount_Controller(cont);
        FileAssign.IPSFileUploadID = null;
        String nextPage = FileAssign.cancelRecord().getUrl();                   
        Test.stopTest();
        System.assertEquals('/' + prefix + '/o', nextPage);  
    }       
    
}