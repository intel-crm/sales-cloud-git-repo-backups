/****************************************************************************************************************************************
* Class Name  : Core_MDF_ListViewController_Test  
* Version     : 1.0 
* Created Date: 05/06/2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Sai Sugathri N   05-06-2019                   Created Core_MDF_ListViewController_Test to test the external export functionality.
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_ListViewController_Test 
{ 
    /****************************************************************************************************************************************
Method Name:                                             testExportExcelExternal
Description:                                             Testing the export to excel and csv functionality of ListViewController class.
Added By:                                                Accenture – Sai Sugathri N  - 05-06-2019
Modified By:                  Date:                      Changes: 
Accenture – Sai Sugathri N   05-06-2019                  Created.
*****************************************************************************************************************************************/
   
        @TestSetup static void testExportToExcelExternal() {
    
         UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();
         
        
        
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
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            acc1.Core_MDF_CoMarketingAgency__c=true;
            Database.insert(acc1);
            
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            Database.insert(acc); 
            
           
             // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            Database.insert(con);
        
            
            
          Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
        // Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.Email='testextexport@example.com';
            usr1.ProfileId = partnerProfile.Id;
            usr1.ContactId = con.Id;
            usr1.isActive = true;
            Database.insert(usr1);
        
            Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1.Id,'External',acc1.Id,cp.Id,'CCF_EXTERNAL_ALL',true);        
        
            Group extGrp = [SELECT Id FROM Group WHERE Group.DeveloperName like '%CCF_EXTERNAL_ALL%' ORDER BY CreatedDate desc LIMIT 1];
            
            GroupMember gm = new GroupMember();
            gm.GroupId=extGrp.Id;
            gm.UserOrGroupId=usr1.Id;
            Database.insert(gm);

            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today() ,
                                                                        System.today().addDays(200), 2000, 'Unite',acc.Id,'2-in-1', true);
            
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today(),System.today().addDays(110), 
                                                                                   true);
            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
            
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Core™ i7+ Processor','Broadcast',
                                                                                           'Radio','Draft',false);
            pfr.RequestedAmount = 900000;
            pfr.Amount = 900000;
            pfr.Status = 'Approved';
            pfr.AllocationId = pfa.Id;
            pfr.BudgetId = pmb.Id;
            pfr.Core_MDF_Start_Date__c = system.today();
            pfr.Core_MDF_End_Date__c = system.today();
            Database.insert(pfr);

            // Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');
            
            PartnerFundRequestShare pfrShare = new PartnerFundRequestShare();
            pfrShare.ParentId = pfr.Id;
            pfrShare.UserOrGroupId = usr1.id;
            pfrShare.AccessLevel = 'Edit';
            Database.insert(pfrShare);  
            
            Core_MDF_Bank__Share bankShare  = new Core_MDF_Bank__Share();
            bankShare.ParentId = bank.Id;
            bankShare.UserOrGroupId = usr1.id;
            bankShare.AccessLevel = 'Edit'; 
            Database.insert(bankShare);
                        
        }
    }
    
    @isTest static void testExportExcelExternal(){  
        Test.StartTest();
        
       
        User extUser = [SELECT Id,Email from User where Email='testextexport@example.com' limit 1];
         
            System.runAs(extUser){
                   
                Test.setMock(HttpCalloutMock.class, new Core_MDF_ExportToExcel_Mock());
                PageReference pageRef = Page.Core_MDF_ListView_Export_CSV;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('ObjName','Core_MDF_Bank__c');
                Core_MDF_ExternalListViewExport lvc = new Core_MDF_ExternalListViewExport();
                Core_MDF_Bank__c ac = new Core_MDF_Bank__c();

                ListView lv = [SELECT Id, Name, DeveloperName FROM ListView  WHERE sObjectType = 'Core_MDF_Bank__c' AND Name='All'];
                Core_MDF_ExternalListViewExport.listViewFilter(lv.Id, 'Core_MDF_Bank__c');
                Core_MDF_ExternalListViewExport.fetchKeys(lv.Id, 'Core_MDF_Bank__c');
                List<sObject> bankRecords = new List<sObject>();
                System.debug(bankRecords);
                bankRecords = Core_MDF_ExternalListViewExport.fetchRecords(lv.Id, 'Core_MDF_Bank__c');          
                System.assert(bankRecords.size() == 0,'Bank record size is 0');
                Core_MDF_ExternalListViewExport.listValues('Core_MDF_Bank__c');
                Core_MDF_ExternalListViewExport.listViewWrapper listViewInstance = new Core_MDF_ExternalListViewExport.listViewWrapper();
                
                 
                        
                //listViewInstance.oListViewWrapper lvio = new listViewInstance.oListViewWrapper();
                String label1 = listViewInstance.label;
                String developerName = listViewInstance.developerName;
                String listViewId = listViewInstance.listViewId;
            
                //lvc.exportToExcel();
                //lvc.exportToCSV();
                
                Core_MDF_ExternalListViewExport.SingleColumn singleColumnInstance = new Core_MDF_ExternalListViewExport.SingleColumn();
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
                
            Test.StopTest(); 
        
        }
        
        
    }
}