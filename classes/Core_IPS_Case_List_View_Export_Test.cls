@isTest(SeeAllData=True)
public class Core_IPS_Case_List_View_Export_Test {
    
    private static final Integer ACCOUNT_COUNT = 1;
    private static final Integer CONTACT_COUNT = 1;
    private static final Integer CASE_COUNT    = 1001;
    
    private static ApexPages.StandardSetController sscController;
    private static Core_IPS_Backend_System__c backendSystem;
    private static PageReference prfPage;
    private static Product2 testProduct;

    /*
    /* Had to go with SeeAllData because of trying to make a callout while a commit is pending
    /*    
    @testSetup static void exportDataSetup() {
        User usrSysAdmin = Core_Test_Utility.systemAdminUser;

        List<Account> lstAccount = Core_Test_Utility.createAccount(ACCOUNT_COUNT);
        System.runAs(usrSysAdmin) {
            insert lstAccount;
        }
        
        List<Contact> lstContact = Core_Test_Utility.createContacts(CONTACT_COUNT);
        for (Integer i=0; i < CONTACT_COUNT; i++) {
            lstContact[i].AccountId = lstAccount[0].id;
        }               
        System.runAs(usrSysAdmin) {
            insert lstContact;
        }

        List<Case> lstCase = new List<Case>();
        Case objCase;
        for (Integer i=0; i < CASE_COUNT; i++) {
            objCase = new Case(Subject='CASE' + i, AccountId=lstAccount[0].id, ContactId=lstContact[0].id);
            lstCase.add(objCase);
        }                                   
        System.runAs(usrSysAdmin) {
            insert lstCase;
        }
    }
    */
    
    static void exportSetup() {
        
        prfPage = Page.Core_IPS_Case_List_View_CSV;
        prfPage.getParameters().put('retUrl', prfPage.getUrl());
        
        List<Case> lstCase = [SELECT Id FROM Case LIMIT 10];
        sscController      = new ApexPages.StandardSetController(lstCase);
    }

    
    @isTest static void exportTest1() {

        exportSetup();
        Test.setMock(HttpCalloutMock.class, new Core_IPS_Case_List_View_Export_Mock());
        
        Test.startTest();

            Test.setCurrentPage(prfPage);
        
            Core_IPS_Case_List_View_Export objCaseListViewExport = new Core_IPS_Case_List_View_Export(sscController);
            
            objCaseListViewExport.StrQuery += ' LIMIT ' + CASE_COUNT;            
            objCaseListViewExport.exportToExcel();
            objCaseListViewExport.exportToCSV();        
            objCaseListViewExport.returnToPage();        
        
        Test.stopTest();

    }
    
    
    @isTest static void exportTest2() {

        exportSetup();
        Test.setMock(HttpCalloutMock.class, new Core_IPS_Case_List_View_Export_Mock());
        
        Test.startTest();

            Test.setCurrentPage(prfPage);
        
            Core_IPS_Case_List_View_Export objCaseListViewExport = new Core_IPS_Case_List_View_Export(sscController);

            objCaseListViewExport.StrQuery += ' LIMIT ' + CASE_COUNT;            

            String strNewLine = objCaseListViewExport.newLine;
            String strBOM     = objCaseListViewExport.BOM;
        
            Core_IPS_Case_List_View_Export.SingleColumn objSingleColumn = new Core_IPS_Case_List_View_Export.SingleColumn();
            objSingleColumn.ascendingLabel  = '';
            objSingleColumn.descendingLabel = '';
            objSingleColumn.selectListItem  = '';
            objSingleColumn.sortDirection   = '';
            objSingleColumn.sortIndex       = 0;
            objSingleColumn.sortable        = true;
            objSingleColumn.type            = '';
                                
        
        Test.stopTest();

    }    

    @isTest static void exportTest3() {

        exportSetup();
        Test.setMock(HttpCalloutMock.class, new Core_IPS_Case_List_View_Export_Mock());
        
        Test.startTest();

            Test.setCurrentPage(prfPage);
        
            Core_IPS_Case_List_View_Export.MAX_EXPORT_ROWS = 1;
            Core_IPS_Case_List_View_Export objCaseListViewExport = new Core_IPS_Case_List_View_Export(sscController);

            objCaseListViewExport.StrQuery += ' LIMIT ' + CASE_COUNT;            

        Test.stopTest();

    }    

    @isTest static void exportTest4() {

        exportSetup();
        Test.setMock(HttpCalloutMock.class, new Core_IPS_Case_List_View_Export_Mock());
        
        Test.startTest();

            Test.setCurrentPage(prfPage);
        
            Core_IPS_Case_List_View_Export.MAX_FIELD_LENGTH = 1;
            Core_IPS_Case_List_View_Export objCaseListViewExport = new Core_IPS_Case_List_View_Export(sscController);

            objCaseListViewExport.StrQuery += ' LIMIT ' + CASE_COUNT;            
            objCaseListViewExport.exportToCSV();        
        
        Test.stopTest();

    }    

    @isTest static void exportTest5() {

        exportSetup();
        Test.setMock(HttpCalloutMock.class, new Core_IPS_Case_List_View_Export_Mock());
        
        Test.startTest();

            Test.setCurrentPage(prfPage);
        
            Core_IPS_Case_List_View_Export objCaseListViewExport = new Core_IPS_Case_List_View_Export(sscController);
            
            /* MAKE AN INVALID QUERY */
            objCaseListViewExport.StrQuery += ' BAD QUERY ';                        
            objCaseListViewExport.exportToExcel();
            objCaseListViewExport.exportToCSV();        
        
        Test.stopTest();

    }    
}