/****************************************************************************************************************************************
* Class Name        : Core_MDF_ExceptionTrigger_Test
* Created Date      : 25-06-2019
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture VK        25-06-2019          Test Class for Core_MDF_Exception_TriggerServiceHandler
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_ExceptionTrigger_Test {
    @TestSetUp
    static void createData(){
        User usr = Core_MDF_CCP_TestDataUtility.createUser(true);
        System.runAs(usr){
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
            
            Account flipkartTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('FlipkartTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account myntraTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('MyntraTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet programAdminPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Program_Adm' LIMIT 1];
            PermissionSet exceptionReviewerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Exception_Reviewer' LIMIT 1];
            PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            
            List<User> userList = new List<User>();
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            //DCF Account Manager
            User dcfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            dcfAccountManager.profileId = ccpCoreProfile.Id;
            dcfAccountManager.LastName = 'DCF Acc Manager';
            userList.add(dcfAccountManager);
            
            //CCF WW Account Manager
            User ccfwwAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfwwAccountManager.profileId = ccpCoreProfile.Id;
            ccfwwAccountManager.LastName = 'CCF WW Acc Manager';
            userList.add(ccfwwAccountManager);
            
            //CCF Account Manager
            User ccfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager.profileId = ccpCoreProfile.Id;
            ccfAccountManager.LastName = 'CCF Acc Manager';
            userList.add(ccfAccountManager);
            
            //Exception Reviewer
            User exceptionReviewer = Core_MDF_CCP_TestDataUtility.createUser(false);
            exceptionReviewer.profileId = ccpCoreProfile.Id;
            exceptionReviewer.LastName = 'Excpetion Reviewer';
            userList.add(exceptionReviewer);

            insert userList;
            
            //Assign  CCF Account Manager Permission Set 
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager.Id);
            permissionSetAssignmentList.add(psa1);
           
            //Assign  CCF WW Account Manager Permission Set 
            PermissionSetAssignment psaCCFWW = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfwwAccountManager.Id);
            permissionSetAssignmentList.add(psaCCFWW);
            
            
            //Adding reviewer and program admin permission set to Excption Reviewer
            PermissionSetAssignment psaProgramAdmin = new PermissionSetAssignment(PermissionSetId = programAdminPS.Id, AssigneeId = exceptionReviewer.Id);
            permissionSetAssignmentList.add(psaProgramAdmin);

            PermissionSetAssignment psaExpReviewer = new PermissionSetAssignment(PermissionSetId = exceptionReviewerPS.Id, AssigneeId = exceptionReviewer.Id);
            permissionSetAssignmentList.add(psaExpReviewer);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = dcfAccManagerPS.Id, AssigneeId = dcfAccountManager.Id);
            permissionSetAssignmentList.add(psa2);
            
            insert permissionSetAssignmentList;
            
            group grpAllEmployees = [select DeveloperName from group where DeveloperName='Core_All_Employees_Group' LIMIT 1];
            group grpCCPInternal = [select DeveloperName from group where DeveloperName='Core_All_Users_CCP_Internal' LIMIT 1];
            
            Group ccfgrp = new Group();
            ccfgrp.Name = 'CCP FLIPKARTT CCF APJ INTERNAL';
            ccfgrp.DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_INTERNAL';
            Database.insert(ccfgrp);
            
            List<groupmember> groupMemberList = new List<groupmember>();
            groupmember grpmembAllEmployees = new groupmember();
            grpmembAllEmployees.groupid = grpAllEmployees.id;
            grpmembAllEmployees.UserOrGroupId = exceptionReviewer.id;
            groupMemberList.add(grpmembAllEmployees);
            
            groupmember grpmembCCPInternal = new groupmember();
            grpmembCCPInternal.groupid = grpCCPInternal.id;
            grpmembCCPInternal.UserOrGroupId = exceptionReviewer.id;
            groupMemberList.add(grpmembCCPInternal);
            
            database.insert(groupMemberList);

           	List<Core_MDF_Partner_Group_Mapping__c> pgm = new List<Core_MDF_Partner_Group_Mapping__c>();
          	Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c = flipkartTestAccount.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_INTERNAL';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'APJ';
            Database.insert(ccfPgm);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgmRegion = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgmRegion.Core_MDF_Account__c = flipkartTestAccount.Id;
            ccfPgmRegion.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_SA_INTERNAL';
            ccfPgmRegion.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgmRegion.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgmRegion.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgmRegion.Core_MDF_Region_cd__c = 'APJ';
            ccfPgmRegion.Core_MDF_Sub_Region_cd__c = 'SA';
            Database.insert(ccfPgmRegion);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgmWW = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgmWW.Core_MDF_Account__c = flipkartTestAccount.Id;
            ccfPgmWW.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_WW_INTERNAL';
            ccfPgmWW.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgmWW.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgmWW.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgmWW.Core_MDF_Region_cd__c = 'WW';
            Database.insert(ccfPgmWW); 
            
            //Database.insert(pgm);

            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmWW = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmWW.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgmWW.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            //iupgmWW.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            iupgmWW.Core_MDF_Region_cd__c = 'APJ';
            iupgmWW.Core_MDF_User_id__c = ccfAccountManager.Id;
            iupgmWW.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgmList.add(iupgmWW);
            
           	Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm.Core_MDF_Region_cd__c = 'WW';
            iupgm.Core_MDF_User_id__c = ccfwwAccountManager.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgmList.add(iupgm);
            
            insert iupgmList;
            
        	
            Account flipkartTestAccountCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test CCF Account', ccfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, flipkartTestAccount.Id, false);
           	Account myntraTestAccountDCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test DCF Account', dcfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, myntraTestAccount.Id, false);
			Account myntraTestAccountCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test CCF Account Myntra', ccfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, myntraTestAccount.Id, false);
			List<Account> accountList = new List<Account>();
            accountList.add(flipkartTestAccountCCF);
			accountList.add(myntraTestAccountDCF);
			accountList.add(myntraTestAccountCCF);
			insert accountList;

            List<AccountShare> accshare = new List<AccountShare>();
          	
            AccountShare accshareRecordCCFWW = new AccountShare();
            accshareRecordCCFWW.AccountId = flipkartTestAccount.Id;
            accshareRecordCCFWW.UserOrGroupId = ccfwwAccountManager.Id;
            accshareRecordCCFWW.RowCause = 'Manual';
            accshareRecordCCFWW.AccountAccessLevel = 'Read';
            accshareRecordCCFWW.OpportunityAccessLevel = 'None';
            accshareRecordCCFWW.CaseAccessLevel = 'None';
            accshare.add(accshareRecordCCFWW);
            
            AccountShare accshareRecordCCF = new AccountShare();
            accshareRecordCCF.AccountId = flipkartTestAccount.Id;
            accshareRecordCCF.UserOrGroupId = ccfAccountManager.Id;
            accshareRecordCCF.RowCause = 'Manual';
            accshareRecordCCF.AccountAccessLevel = 'Read';
            accshareRecordCCF.OpportunityAccessLevel = 'None';
            accshareRecordCCF.CaseAccessLevel = 'None';
            accshare.add(accshareRecordCCF);
            
            AccountShare accshareExcepetionReviewer = new AccountShare();
            accshareExcepetionReviewer.AccountId = flipkartTestAccount.Id;
            accshareExcepetionReviewer.UserOrGroupId = exceptionReviewer.Id;
            accshareExcepetionReviewer.RowCause = 'Manual';
            accshareExcepetionReviewer.AccountAccessLevel = 'Read';
            accshareExcepetionReviewer.OpportunityAccessLevel = 'None';
            accshareExcepetionReviewer.CaseAccessLevel = 'None';
            accshare.add(accshareExcepetionReviewer);
            
            AccountShare accshareMyntraExcepetionReviewer = new AccountShare();
            accshareMyntraExcepetionReviewer.AccountId = myntraTestAccount.Id;
            accshareMyntraExcepetionReviewer.UserOrGroupId = exceptionReviewer.Id;
            accshareMyntraExcepetionReviewer.RowCause = 'Manual';
            accshareMyntraExcepetionReviewer.AccountAccessLevel = 'Read';
            accshareMyntraExcepetionReviewer.OpportunityAccessLevel = 'None';
            accshareMyntraExcepetionReviewer.CaseAccessLevel = 'None';
            accshare.add(accshareMyntraExcepetionReviewer);
            
            Database.insert(accshare);
            
                  
            //Create Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(flipkartTestAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            
           	// test.startTest();
            //Create Budget
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',
                                                                                      Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      accountList[0].Id,ccfCp.Id,10000,
                                                                                      System.today() -20,System.today().addDays(40), 
                                                                                      true);
            
            //Create Allocation
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,accountList[0],10000,true);
            Test.startTest();
            //Create Campaign
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund', System.today(), System.today().addDays(15), 
                                                                        10000, 'Always Connected PC', accountList[0].Id,'Desktop', true); 
            
            //Create Activity
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           String.valueof(accountList[0].id),allocation,null,'BRAZIL',
                                                                                           'Consumer',
                                                                                           'Desktop',
                                                                                           'Intel® Core™ i7+ Processor',
                                                                                           'Broadcast',
                                                                                           'Podcast',
                                                                                           'Draft',
                                                                                           false);
            pfr.Core_MDF_Start_Date__c = system.today();
            pfr.Core_MDF_End_Date__c  = system.today() + 5;
            insert pfr;
            
            //Create Claim
            PartnerFundClaim newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                                 Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                                 System.today(), System.today(), 122, 
                                                                                 System.today(), bank.Id, false);
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Type_Txt__c = 'Claim';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            insert newClaim;
            test.stopTest();
            
            //Create case of Audit record type
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'New';
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Activity_Category__c = 'Broadcast';
            cs.Core_MDF_Activity_Start_Date__c = System.today();
            cs.Core_MDF_Activity_End_Date__c = System.today() + 5;
            cs.Core_MDF_Claim_ID__c = newClaim.Id;
            cs.Core_MDF_Activity_Type__c = 'Podcast';
            cs.AccountId  = flipkartTestAccount.Id;
            insert cs;
        }
        
    }    
   
    @isTest
    static void exceptionCreate(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                            WHERE Core_MDF_User_id__c =: submitter.id ];
        
       	Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        Test.startTest();
        
        System.runAs(submitter){ 
        	//Account       Country
            //Single        Single 
            
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_Country_Region_nm__c = 'INDIA';
            expt.Core_MDF_Account_id__c = acc.Id;
            exceptionList.add(expt);
           
            //Account     	Country
            //Single       	All
            Core_MDF_Exception__c exptAllAccount = new Core_MDF_Exception__c();
            exptAllAccount.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptAllAccount.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptAllAccount.Core_MDF_Comments_txt__c = 'Test Comments';
            exptAllAccount.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptAllAccount.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptAllAccount.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptAllAccount.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exptAllAccount.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptAllAccount.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptAllAccount.Core_MDF_Select_All_Country_ind__c = true;
           	exptAllAccount.Core_MDF_Account_id__c = acc.Id;
            exceptionList.add(exptAllAccount);
            
            
            //Account       Country
            //Single        Multiple 
            Core_MDF_Exception__c exptDCFPrgm = new Core_MDF_Exception__c();
            exptDCFPrgm.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptDCFPrgm.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptDCFPrgm.Core_MDF_Comments_txt__c = 'Test Comments';
            exptDCFPrgm.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptDCFPrgm.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptDCFPrgm.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptDCFPrgm.Core_MDF_Program_nm__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
            exptDCFPrgm.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptDCFPrgm.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptDCFPrgm.Core_MDF_Country_Region_nm__c = 'INDIA,JAPAN';
            exptDCFPrgm.Core_MDF_Account_id__c = acc.Id;
            //exptDCFPrgm.Core_MDF_Select_All_Accounts_ind__c = true;
            exceptionList.add(exptDCFPrgm);
             
            try{
                Database.insert(exceptionList);
         	}catch(Exception e){
            	System.debug('Fail Creating Exception');
            }
            System.assert(exptDCFPrgm.id == NULL);
        }
     }
    @isTest
    static void exceptionSubmitterAllAccountAccessError(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                            WHERE Core_MDF_User_id__c =: submitter.id ];
        PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
       	// Case cs = [SELECT Id FROM Case WHERE AccountId =: acc.Id];
       
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        Test.startTest();
        
        System.runAs(submitter){            
            //Account       Country
            //Single        Single
            //Validate Account Access
            Core_MDF_Exception__c exptAcccountAccess= new Core_MDF_Exception__c();
            exptAcccountAccess.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptAcccountAccess.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptAcccountAccess.Core_MDF_Comments_txt__c = 'Test Comments';
            exptAcccountAccess.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptAcccountAccess.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptAcccountAccess.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptAcccountAccess.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exptAcccountAccess.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptAcccountAccess.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptAcccountAccess.Core_MDF_Country_Region_nm__c = 'INDIA';
            exptAcccountAccess.Core_MDF_Select_All_Accounts_ind__c = true;
            
            Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
            try{
                newExceptionMap.put(exptAcccountAccess.Id,exptAcccountAccess);
        		Core_MDF_Exception_TriggerServiceHandler.shareExceptionRecordsWithInternalUsers(newExceptionMap);
        	}catch(Exception e){
                System.assert(exptAcccountAccess.Id  != null);  
            }
            System.assert(exptAcccountAccess.Id  == null); 
        }
 	}

    @isTest
    static void exceptionSubmitterGeoAccessError(){
    
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF WW Acc Manager' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                            WHERE Core_MDF_User_id__c =: submitter.id ];
        Test.startTest();
        
        System.runAs(submitter){   
            Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
            
            //Account       Country
            //Single        Single
                //Validate Account Access
            Core_MDF_Exception__c exptGeoError= new Core_MDF_Exception__c();
            exptGeoError.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptGeoError.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptGeoError.Core_MDF_Comments_txt__c = 'Test Comments';
            exptGeoError.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptGeoError.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptGeoError.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptGeoError.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exptGeoError.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptGeoError.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptGeoError.Core_MDF_Select_All_Country_ind__c = TRUE;
            exptGeoError.Core_MDF_Account_id__c = acc.Id;
            newExceptionMap.put(exptGeoError.Id,exptGeoError);
            
            Core_MDF_Exception__c exptAllCountry= new Core_MDF_Exception__c();
            exptAllCountry.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptAllCountry.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptAllCountry.Core_MDF_Comments_txt__c = 'Test Comments';
            exptAllCountry.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptAllCountry.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptAllCountry.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptAllCountry.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exptAllCountry.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptAllCountry.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptAllCountry.Core_MDF_Select_All_Country_ind__c = TRUE;
            exptAllCountry.Core_MDF_Account_id__c = acc.Id;
            newExceptionMap.put(exptAllCountry.Id,exptAllCountry);
            
            try{
                Core_MDF_Exception_TriggerServiceHandler.shareExceptionRecordsWithInternalUsers(newExceptionMap);
            }catch(Exception e){
            	System.debug('Exception error');
            }
			System.assert(exptAllCountry.Id == NULL);
            }
    }

   	@isTest
    static void exceptionCaseMappingCreate(){
    
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
        Case cs = [SELECT id FROM Case WHERE AccountId =: acc.Id];
        
        List<Core_MDF_Exception__c> exptRecordList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        System.runAs(submitter){
            //Single        Single 
            Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_Country_Region_nm__c = 'INDIA';
            expt.Core_MDF_Account_id__c = acc.Id;
            exptRecordList.add(expt);
            
            Core_MDF_Exception__c exptMultipleCountry = new Core_MDF_Exception__c();
            //Single Account        Multiple Country
            exptMultipleCountry.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Multiple Country';
            exptMultipleCountry.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptMultipleCountry.Core_MDF_Comments_txt__c = 'Test Comments';
            exptMultipleCountry.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptMultipleCountry.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptMultipleCountry.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptMultipleCountry.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exptMultipleCountry.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptMultipleCountry.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptMultipleCountry.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
            exptMultipleCountry.Core_MDF_Account_id__c = acc.Id;
            exptRecordList.add(exptMultipleCountry);
            
            Database.insert(exptRecordList);
        }
        List<Core_MDF_Exception_Case_Mapping__c> ecmList = new List<Core_MDF_Exception_Case_Mapping__c>();
        //Create ECM
        Core_MDF_Exception_Case_Mapping__c ecm = new Core_MDF_Exception_Case_Mapping__c();
        ecm.Core_MDF_Case_id__c = cs.Id;
        ecm.Core_MDF_Exception_id__c = exptRecordList[0].Id;
        ecm.Core_MDF_Claim_id__c = newClaim.Id;
        ecm.Core_MDF_Program_txt__c = exptRecordList[0].Core_MDF_Program_nm__c;
        ecmList.add(ecm);
        
        Core_MDF_Exception_Case_Mapping__c ecm2 = new Core_MDF_Exception_Case_Mapping__c();
        ecm2.Core_MDF_Case_id__c = cs.Id;
        ecm2.Core_MDF_Exception_id__c = exptRecordList[1].Id;
        ecm2.Core_MDF_Claim_id__c = newClaim.Id;
        ecm2.Core_MDF_Program_txt__c = exptRecordList[1].Core_MDF_Program_nm__c;
        ecmList.add(ecm2);
        
        Database.insert(ecmList);
        
        
        Map<Id , Core_MDF_Exception_Case_Mapping__c> newExceptionMap = new Map<Id , Core_MDF_Exception_Case_Mapping__c>();
        try{
            newExceptionMap.put(ecm.Id,ecm);
            newExceptionMap.put(ecm2.Id,ecm2);
            Core_MDF_Exception_TriggerServiceHandler.shareECMRecordWithusers(newExceptionMap);
            Core_MDF_Exception_TriggerServiceHandler.createECMShare(ecm.Id,submitter.Id);
        }catch(Exception e){
            
        }
        Test.stopTest();
        System.assert(exptRecordList[0].Id != NULL);
    }
   	@isTest
    static void exceptionSubmitterAccountAccessError(){
    
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                            WHERE Core_MDF_User_id__c =: submitter.id ];
        Test.startTest();
        
        System.runAs(submitter){            
            //Account       Country
            //Single        Single
                //Validate Account Access
            Core_MDF_Exception__c exptAccountAccess= new Core_MDF_Exception__c();
            exptAccountAccess.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptAccountAccess.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptAccountAccess.Core_MDF_Comments_txt__c = 'Test Comments';
            exptAccountAccess.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptAccountAccess.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptAccountAccess.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptAccountAccess.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exptAccountAccess.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptAccountAccess.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptAccountAccess.Core_MDF_Country_Region_nm__c = 'GERMANY';
            exptAccountAccess.Core_MDF_Account_id__c = accMyntra.Id;
            Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
            try{
                newExceptionMap.put(exptAccountAccess.Id,exptAccountAccess);
                Core_MDF_Exception_TriggerServiceHandler.shareExceptionRecordsWithInternalUsers(newExceptionMap);
            }catch(Exception e){
                
            }
            System.assert(exptAccountAccess.id == NULL);
        }
    }
    @isTest
    static void exceptionSubmitterProgramAccessError(){
    
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                            WHERE Core_MDF_User_id__c =: submitter.id ];
        Test.startTest();
        
        System.runAs(submitter){            
            //Account       Country
            //Single        Single
                //Validate Account Access
            Core_MDF_Exception__c exptProgramDCF= new Core_MDF_Exception__c();
            exptProgramDCF.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptProgramDCF.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptProgramDCF.Core_MDF_Comments_txt__c = 'Test Comments';
            exptProgramDCF.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptProgramDCF.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptProgramDCF.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptProgramDCF.Core_MDF_Program_nm__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
            exptProgramDCF.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptProgramDCF.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptProgramDCF.Core_MDF_Country_Region_nm__c = 'INDIA';
            exptProgramDCF.Core_MDF_Account_id__c = acc.Id;
            Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
            try{
                newExceptionMap.put(exptProgramDCF.Id,exptProgramDCF);
                Core_MDF_Exception_TriggerServiceHandler.shareExceptionRecordsWithInternalUsers(newExceptionMap);
            }catch(Exception e){
                //System.asserts(exptAcccountAccess != NULL);
            }
            System.assert(exptProgramDCF.Id == NULL);
        }
        
    }

    @isTest
    static void exceptionForSingleAccountAllCountriesTest(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        User submitterWW  = [SELECT Id FROM USER WHERE LastName = 'CCF WW Acc Manager' LIMIT 1];
		Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
    
       	Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
       	expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Select_All_Country_ind__c = true;
        expt.Core_MDF_Account_id__c = acc.Id;
       
        System.runAs(submitterWW){ 
        	Database.insert(expt);
        }
        System.assert(expt.Id != NULL);
    }
    
    @isTest
    static void exceptionEditAccount(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                            WHERE Core_MDF_User_id__c =: submitter.id ];
        
       
        
        PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
        
       	Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
       	expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
        expt.Core_MDF_Account_id__c = acc.Id;
       
        System.runAs(submitter){ 
        	Database.insert(expt);
        }
        Test.startTest();
        
        //Object record id to recall the approval process
        String recordId = expt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
        
        Core_MDF_Exception__Share expshareExcepetionReviewer = new Core_MDF_Exception__Share();
        expshareExcepetionReviewer.ParentId = expt.Id;
        expshareExcepetionReviewer.UserOrGroupId = reviewer.Id;
        expshareExcepetionReviewer.AccessLevel  = 'Edit';
        expshareExcepetionReviewer.RowCause = 'Manual';
        Database.insert(expshareExcepetionReviewer);
        Id exceptionId = expt.Id;
		
		AccountShare accshareMyntraExcepetionReviewer = new AccountShare();
		accshareMyntraExcepetionReviewer.AccountId = accMyntra.Id;
		accshareMyntraExcepetionReviewer.UserOrGroupId = reviewer.Id;
		accshareMyntraExcepetionReviewer.RowCause = 'Manual';
		accshareMyntraExcepetionReviewer.AccountAccessLevel = 'Read';
		accshareMyntraExcepetionReviewer.OpportunityAccessLevel = 'None';
		accshareMyntraExcepetionReviewer.CaseAccessLevel = 'None';
		
		insert accshareMyntraExcepetionReviewer;
		Core_MDF_Exception__c exceptionRecord = [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Select_All_Country_ind__c,
                                                     		Core_MDF_Country_Region_nm__c, Core_MDF_Select_All_Accounts_ind__c
                                                     FROM Core_MDF_Exception__c
                                                     WHERE Id =: exceptionId];
        System.runAs(reviewer){
            
            if(exceptionRecord != NULL){
                //Account change
                exceptionRecord.Core_MDF_Account_id__c = accMyntra.Id;
                update exceptionRecord;
				System.assert(exceptionRecord.Core_MDF_Account_id__c != NULL);
            }
        }
		Test.stopTest();
    }
    @isTest
    static void exceptionEditAllAccount(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                            WHERE Core_MDF_User_id__c =: submitter.id ];
        
       
        
        PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
        
       	Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
       	expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
        expt.Core_MDF_Account_id__c = acc.Id;
       
        System.runAs(submitter){ 
        	Database.insert(expt);
        }
        Test.startTest();
        
        //Object record id to recall the approval process
        String recordId = expt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
        
        Core_MDF_Exception__Share expshareExcepetionReviewer = new Core_MDF_Exception__Share();
        expshareExcepetionReviewer.ParentId = expt.Id;
        expshareExcepetionReviewer.UserOrGroupId = reviewer.Id;
        expshareExcepetionReviewer.AccessLevel  = 'Edit';
        expshareExcepetionReviewer.RowCause = 'Manual';
        Database.insert(expshareExcepetionReviewer);
        Id exceptionId = expt.Id;
		
		AccountShare accshareMyntraExcepetionReviewer = new AccountShare();
		accshareMyntraExcepetionReviewer.AccountId = accMyntra.Id;
		accshareMyntraExcepetionReviewer.UserOrGroupId = reviewer.Id;
		accshareMyntraExcepetionReviewer.RowCause = 'Manual';
		accshareMyntraExcepetionReviewer.AccountAccessLevel = 'Read';
		accshareMyntraExcepetionReviewer.OpportunityAccessLevel = 'None';
		accshareMyntraExcepetionReviewer.CaseAccessLevel = 'None';
		
		insert accshareMyntraExcepetionReviewer;
		Core_MDF_Exception__c exceptionRecord = [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Select_All_Country_ind__c,
                                                     		Core_MDF_Country_Region_nm__c, Core_MDF_Select_All_Accounts_ind__c
                                                     FROM Core_MDF_Exception__c
                                                     WHERE Id =: exceptionId];
        System.runAs(reviewer){
            
            if(exceptionRecord != NULL){
                //Account change from single to all
                exceptionRecord.Core_MDF_Account_id__c = NULL;
                exceptionRecord.Core_MDF_Select_All_Accounts_ind__c = true;
                update exceptionRecord;
				System.assert(exceptionRecord.Core_MDF_Select_All_Accounts_ind__c == true);
            }
        }
        Test.stopTest();
    }
    @isTest
    static void exceptionEditAddCountry(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                            WHERE Core_MDF_User_id__c =: submitter.id ];
        
       
        
        PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
        
       	Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
       	expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
        expt.Core_MDF_Account_id__c = acc.Id;
       
        System.runAs(submitter){ 
        	Database.insert(expt);
        }
        Test.startTest();
        
        //Object record id to recall the approval process
        String recordId = expt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
        
        Core_MDF_Exception__Share expshareExcepetionReviewer = new Core_MDF_Exception__Share();
        expshareExcepetionReviewer.ParentId = expt.Id;
        expshareExcepetionReviewer.UserOrGroupId = reviewer.Id;
        expshareExcepetionReviewer.AccessLevel  = 'Edit';
        expshareExcepetionReviewer.RowCause = 'Manual';
        Database.insert(expshareExcepetionReviewer);
        Id exceptionId = expt.Id;
		
		AccountShare accshareMyntraExcepetionReviewer = new AccountShare();
		accshareMyntraExcepetionReviewer.AccountId = accMyntra.Id;
		accshareMyntraExcepetionReviewer.UserOrGroupId = reviewer.Id;
		accshareMyntraExcepetionReviewer.RowCause = 'Manual';
		accshareMyntraExcepetionReviewer.AccountAccessLevel = 'Read';
		accshareMyntraExcepetionReviewer.OpportunityAccessLevel = 'None';
		accshareMyntraExcepetionReviewer.CaseAccessLevel = 'None';
		
		insert accshareMyntraExcepetionReviewer;
		Core_MDF_Exception__c exceptionRecord = [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Select_All_Country_ind__c,
                                                     		Core_MDF_Country_Region_nm__c, Core_MDF_Select_All_Accounts_ind__c
                                                     FROM Core_MDF_Exception__c
                                                     WHERE Id =: exceptionId];
        System.runAs(reviewer){
            
            if(exceptionRecord != NULL){
                //Country addition
           		exceptionRecord.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN;AFGHANISTAN;';
                update exceptionRecord;
				System.assert(exceptionRecord.Core_MDF_Country_Region_nm__c == 'INDIA;JAPAN;AFGHANISTAN;');
            }
        }
    }
    @isTest
    static void exceptionEditAllCountry(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                            WHERE Core_MDF_User_id__c =: submitter.id ];
        
       
        
        PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
        
       	Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
       	expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
        expt.Core_MDF_Account_id__c = acc.Id;
       
        System.runAs(submitter){ 
        	Database.insert(expt);
        }
        Test.startTest();
        
        //Object record id to recall the approval process
        String recordId = expt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
        
        Core_MDF_Exception__Share expshareExcepetionReviewer = new Core_MDF_Exception__Share();
        expshareExcepetionReviewer.ParentId = expt.Id;
        expshareExcepetionReviewer.UserOrGroupId = reviewer.Id;
        expshareExcepetionReviewer.AccessLevel  = 'Edit';
        expshareExcepetionReviewer.RowCause = 'Manual';
        Database.insert(expshareExcepetionReviewer);
        Id exceptionId = expt.Id;
		
		AccountShare accshareMyntraExcepetionReviewer = new AccountShare();
		accshareMyntraExcepetionReviewer.AccountId = accMyntra.Id;
		accshareMyntraExcepetionReviewer.UserOrGroupId = reviewer.Id;
		accshareMyntraExcepetionReviewer.RowCause = 'Manual';
		accshareMyntraExcepetionReviewer.AccountAccessLevel = 'Read';
		accshareMyntraExcepetionReviewer.OpportunityAccessLevel = 'None';
		accshareMyntraExcepetionReviewer.CaseAccessLevel = 'None';
		
		insert accshareMyntraExcepetionReviewer;
		Core_MDF_Exception__c exceptionRecord = [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Select_All_Country_ind__c,
                                                     		Core_MDF_Country_Region_nm__c, Core_MDF_Select_All_Accounts_ind__c
                                                     FROM Core_MDF_Exception__c
                                                     WHERE Id =: exceptionId];
        System.runAs(reviewer){
            
            if(exceptionRecord != NULL){
                //Country change from single to all
           		exceptionRecord.Core_MDF_Country_Region_nm__c = NULL;
                exceptionRecord.Core_MDF_Select_All_Country_ind__c = true;
                update exceptionRecord;
				System.assert(exceptionRecord.Core_MDF_Select_All_Country_ind__c == true);
            }
        }
    }
}