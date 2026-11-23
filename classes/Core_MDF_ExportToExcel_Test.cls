/****************************************************************************************************************************************
* Class Name  : Core_MDF_ExportToExcel_Test 
* Version     : 1.0 
* Created Date: 05/01/2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar   05-01-2019                   
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_ExportToExcel_Test { 
/****************************************************************************************************************************************
    Method Name:                                             testExportExcel
    Description:                                             Testing export to excel and csv functionality
    Added By:                                                Accenture – Accenture – Shridhar   05-01-2019                   
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar       05-01-2019                   
*****************************************************************************************************************************************/

    @TestSetup static void testExportExcel() {        
        
         UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        // Highlight: Unused Local Variable - 14285 // Suma
        //List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();

        System.runAs(usr){
            
            //Creating Trigger Excecution Custom Setting record to 
            Core_Trigger_Executions__c claimToCase = new Core_Trigger_Executions__c();
            claimToCase.Core_Active__c = true;
            claimToCase.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimToCase.Core_Description__c = 'This Custom Setting is used to turn on/off claim to case functionality.';
            claimToCase.Core_Object__c = 'PartnerFundClaim';
            claimToCase.Core_Trigger_Events__c = 'after update';
            claimToCase.Name='Core_MDF_ClaimToCase';        
            Database.insert(claimToCase);
                        
            //Create Exchnage rates records
            List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();            
            Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
            record1.Name= 'ZMK';
            record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
            record1.Core_MDF_Market_Date__c = System.today()-2;
            record1.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record1);
            
            Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
            record2.Name= 'INR';
            record2.Core_MDF_Exchange_Rate__c = 1;
            record2.Core_MDF_Market_Date__c = System.today()-2;
            record2.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record2); 
            
            Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
            record3.Name= 'USD';
            record3.Core_MDF_Exchange_Rate__c = 1;
            record3.Core_MDF_Market_Date__c = System.today()-2;
            record3.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record3); 
            
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount bObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount cObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listvar = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
            
            aObj.inputCurrency ='ZMK';
            aObj.inputAmount = 250.00;
            aObj.inputDate= date.newInstance(2018, 11, 13);
            bObj.inputCurrency ='INR';
            bObj.inputAmount = 350.00;
            bObj.inputDate= date.newInstance(2018, 11, 12);
            cObj.inputCurrency ='USD';
            cObj.inputAmount = 350.00;
            cObj.inputDate= date.newInstance(2018, 11, 12);
            listvar.add(aObj);
            listvar.add(bObj);
            listvar.add(cObj);
            Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);
            
            database.insert(newValues);                     
            
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Core_Sales_Groups__c = 'CCG Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            acc1.Core_MDF_CoMarketingAgency__c=true;
            Database.insert(acc1);
            System.assert(acc1.id!=null);
            
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            List<Account> lstAcc = new List<Account>();
            lstAcc.add(acc);            
            lstAcc.add(acc2);
            Database.insert(lstAcc); 
            
            //creating custom setting records
            Core_MDF_List_View_Group_Mapping__c cstStng = new Core_MDF_List_View_Group_Mapping__c();
            cstStng.Core_MDF_Active_ind__c = true;
            cstStng.Core_MDF_Whitelisted_Object__c = true;
            cstStng.Core_MDF_SObject_txt__c = 'Account';
            cstStng.Core_MDF_Label_txt__c = 'Account';
            cstStng.Core_MDF_Visible_to_all_users_ind__c = true;
            cstStng.Name= 'Record 55';
            database.insert(cstStng);
            
        }            
    }
    
    @isTest static void testExportToExcel(){ 
       
        Test.startTest();
       
            Test.setMock(HttpCalloutMock.class, new Core_MDF_ExportToExcelAccount_Mock());
            PageReference pageRef = Page.Core_MDF_ExportToExcel;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ObjName','Account');
            
            Core_MDF_ExportToExcel ete = new Core_MDF_ExportToExcel();
            
            Account accountInstance = new Account();
            // Highlight: Unused Local Variable - 14285 // Suma                
           // String bom = ete.bom;
            //String newLine = ete.newLine;
            
            ete.exportToExcel();
            ete.exportToCSV();
            PageReference pr = ete.returnToPage();
            System.assert(pr != null);
           // Highlight: Unused Local Variable - 14285 // Suma
        	// String fieldToString = ete.fieldToString(null,null,false,null);
            //String fieldToString1 = ete.fieldToString(accountInstance,'Core_Account_Team_Audit_Due_Date__c', true,'date');
            accountInstance.Core_Account_Team_Audit_Due_Date__c = System.today();
           // Highlight: Unused Local Variable - 14285 // Suma
        	// String fieldToString2 = ete.fieldToString(accountInstance,'Core_Account_Team_Audit_Due_Date__c', true,'datetime');
            ete.loadData(null);
            ete.scrubDataFields(null,null);
            ete.fieldToString(accountInstance,'Core_Account_Team_Audit_Due_Date__c', null,null);
                            
            Core_MDF_ExportToExcel.SingleColumn singleColumnInstance = new Core_MDF_ExportToExcel.SingleColumn();
           String ascendingLabel = singleColumnInstance.ascendingLabel;
            String descendingLabel = singleColumnInstance.descendingLabel;
            String sortDirection = singleColumnInstance.sortDirection;
            Integer sortIndex = singleColumnInstance.sortIndex;
            Boolean sortable = singleColumnInstance.sortable;
            String selectListItem = singleColumnInstance.selectListItem;    
            Boolean hidden = singleColumnInstance.hidden;
            String fieldNameOrPath = singleColumnInstance.fieldNameOrPath;             
            String type = singleColumnInstance.type;                   
            String label = singleColumnInstance.label;
            Boolean isDateType = singleColumnInstance.isDateType;

            Test.setMock(HttpCalloutMock.class, new Core_MDF_MockHttpNullResponse());
            PageReference pageRef1 = Page.Core_MDF_ExportToExcel;
            Test.setCurrentPage(pageRef1);
            ApexPages.currentPage().getParameters().put('ObjName','PartnerFundClaim');    
            //Core_MDF_ExportToExcel ete1 = new Core_MDF_ExportToExcel();                      
        
       Test.stopTest(); 
    }
}