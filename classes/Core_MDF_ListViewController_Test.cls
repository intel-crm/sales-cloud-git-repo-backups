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
         
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_Program_Adm',
                            'Core_MDF_CCP_Internal_Claim_Case_Reviewer',
                            'Core_MDF_CCP_External_Claim_Submitter',
                            'Core_MDF_CCP_External_Retail_Claim_Submitter',
                            'Core_MDF_CCP_Internal_APJ_User',
                            'Core_MDF_CCP_Internal_Payment_Schedule_Admin',
                            'Core_MDF_CCP_Internal_Retail_Payment_Adm',
                            'View_All_Data',
                            'Core_MDF_CCP_Internal_CCF_Payment_Adm',
                            'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader',
                            'Core_MDF_CCP_Internal_DCF_MDF_Payment_Admin')]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
        
        /*PermissionSet progAdmPS = nameToPerSet.get('Core_MDF_CCP_Internal_Program_Adm');
        PermissionSet clmCaseUsr = nameToPerSet.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer');
        PermissionSet clmSubmitterUser = nameToPerSet.get('Core_MDF_CCP_External_Claim_Submitter');
        PermissionSet clmRetailSubmitter = nameToPerSet.get('Core_MDF_CCP_External_Retail_Claim_Submitter');
        PermissionSet paymentAdmGeoPS = nameToPerSet.get('Core_MDF_CCP_Internal_APJ_User'); 
        PermissionSet paymentAdmSchedulePS = nameToPerSet.get('Core_MDF_CCP_Internal_Payment_Schedule_Admin'); 
        PermissionSet paymentAdmRMFPS = nameToPerSet.get('Core_MDF_CCP_Internal_Retail_Payment_Adm'); 
        PermissionSet viewAllDataPS = nameToPerSet.get('View_All_Data'); 
        PermissionSet ccpPSadmin = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_Payment_Adm'); */
        PermissionSet ccpMDFBudgetLoaderPS = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader'); 
        //PermissionSet ccpDCFMDFPayAdminPS = nameToPerSet.get('Core_MDF_CCP_Internal_DCF_MDF_Payment_Admin');
        //PermissionSet cmdfPayAdminPS = nameToPerSet.get('Core_MDF_CCP_Internal_Channel_MDF_Payment_Adm');

        PermissionSetAssignment assignMDFBudgetLoaderPermissionSet = new PermissionSetAssignment();
        assignMDFBudgetLoaderPermissionSet.AssigneeId = usr.Id;
        assignMDFBudgetLoaderPermissionSet.PermissionSetId = ccpMDFBudgetLoaderPS.Id; 
        system.runAs(usr){
            Database.insert(assignMDFBudgetLoaderPermissionSet);
        }
        
        List<Group> groupList = new List<Group>();

        // Creating Groups for PGM
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        groupList.add(grp);

        Database.insert(groupList);

        // Adding Users in group
        List<GroupMember> gmList = new List<GroupMember>();
        GroupMember gm = new GroupMember();
        gm.GroupId = grp.Id;
        gm.UserOrGroupId = usr.Id;

        gmList.add(gm);
        system.runAs(usr){
          insert gmList;
        }
        
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
           // acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
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
          
            //Creating PGM records
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = acc1.Id;
            pgm.Core_MDF_Group_Name__c = 'PGM_TEST';
            pgm.Core_MDF_Type_of_Access__c = 'Internal';
            pgm.Core_MDF_Group_Id__c = grp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_Region_cd__c='WW';
            pgm.Core_MDF_Source_Txt__c = 'test';
            pgm.Core_MDF_AccountIdGroupName__c = acc1.Id+'PGM_TEST';

            database.insert(pgm);
            
            //creating custom setting records
            Core_MDF_List_View_Group_Mapping__c cstStng = new Core_MDF_List_View_Group_Mapping__c();
            cstStng.Core_MDF_Active_ind__c = true;
            cstStng.Core_MDF_Whitelisted_Object__c = true;
            cstStng.Core_MDF_SObject_txt__c = 'Core_MDF_Bank__c';
            cstStng.Core_MDF_Label_txt__c = 'Bank';
            cstStng.Core_MDF_Visible_to_all_users_ind__c = true;
            cstStng.Name= 'Record 55';
            database.insert(cstStng);

            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmMDF = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmMDF.Core_MDF_Account_id__c = acc1.id;
            iupgmMDF.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgmMDF.Core_MDF_Channel_Program_id__c = cp.id;
            iupgmMDF.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmMDF.Core_MDF_User_id__c = usr.id;
            iupgmMDF.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader';
            iupgmMDF.Core_MDF_Region_cd__c = 'WW';
            iupgmMDF.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            system.runAs(usr){
                Database.insert(iupgmMDF);
            }
            
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
            
            GroupMember gm1 = new GroupMember();
            gm1.GroupId=extGrp.Id;
            gm1.UserOrGroupId=usr1.Id;
            Database.insert(gm1);

            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','Yes', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today() ,
                                                                        System.today().addDays(200), 2000, 'Consumer Chromebook',acc.Id,'2-in-1', true);
            
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget MDF', Core_MDF_CCP_TestDataUtility.budget_Record_Type, acc.Id, cp.Id, 5000000, System.today().addDays(-5), System.today().addDays(50), false);
            pmb.Core_MDF_Budget_Type_Txt__c = 'MDF';
            
            Database.insert(pmb);
            /*PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today(),System.today().addDays(110), 
                                                                                   true);*/
            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
            test.startTest();
            // Creating activities using utility class
          //  PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
            //                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
              //                                                                             string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                //                                                                           'Desktop','10ᵗʰ Gen','Broadcast',
                  //                                                                         'Radio','Draft',false);
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfa,pmb,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);                                                                        
            pfr.RequestedAmount = 900000;
            pfr.Amount = 900000;
            pfr.Status = 'Approved';
            pfr.AllocationId = pfa.Id;
            pfr.BudgetId = pmb.Id;
            pfr.Core_MDF_Start_Date__c = system.today();
            pfr.Core_MDF_End_Date__c = system.today();
           // Database.insert(pfr);

            // Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');
            
            PartnerFundRequestShare pfrShare = new PartnerFundRequestShare();
            pfrShare.ParentId = pfr.Id;
            pfrShare.UserOrGroupId = usr1.id;
            pfrShare.AccessLevel = 'Edit';
          //  Database.insert(pfrShare);  
            
            Core_MDF_Bank__Share bankShare  = new Core_MDF_Bank__Share();
            bankShare.ParentId = bank.Id;
            bankShare.UserOrGroupId = usr1.id;
            bankShare.AccessLevel = 'Edit'; 
            Database.insert(bankShare);
            assert.areEqual('Edit',bankShare.AccessLevel);
            test.stopTest();
                        
        }
    }
    
    @isTest static void testExportExcelExternal(){  
        
       
        User extUser = [SELECT Id,Email from User where Email='testextexport@example.com' limit 1];
         
            System.runAs(extUser){
              Test.StartTest();

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
                
                bankRecords = Core_MDF_ExternalListViewExport.fetchRecords(lv.Id, 'Core_MDF_Bank__c');          
                assert.isTrue(bankRecords.size() == 0,'Bank record size is 0');
                Core_MDF_ExternalListViewExport.listValues('Core_MDF_Bank__c');
                Core_MDF_ExternalListViewExport.listViewWrapper listViewInstance = new Core_MDF_ExternalListViewExport.listViewWrapper();
                
                                             Test.StopTest(); 

                        
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
                
        
        }
        
        
    }
}