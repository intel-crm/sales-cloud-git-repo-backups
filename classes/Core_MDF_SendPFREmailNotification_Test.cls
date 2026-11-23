@isTest
public class Core_MDF_SendPFREmailNotification_Test {
    
    @TestSetup 
    static void createTestData(){
       
        

        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);    
        testUser.LastName = 'User Test';
        testUser.UserRoleId = usRole.Id;
        Database.insert(testUser);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps1.Id);
        
        System.runAs(testUser){
            
            List<String> bypassFunctionKeys = new List<String>();
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_UpdateActivityFields');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            List<User> usrList=new List<User>();
            
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            PermissionSet aacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet rmfacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            Database.insert(ccfaccntmngr);    
                        
            
            User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr.LastName = 'TestUser';
            usr.Email = 'rmfaccntmngr@example.com';
            usr.isActive = true;
            usr.Profile = ccpCoreAccessProfile;
            PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
            
            assignPermissionSetObj2.AssigneeId = usr.Id;
            assignPermissionSetObj2.PermissionSetId = rmfacntMngrPS.Id;
            usrList.add(usr);   
            
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrList.add(usr1);
            
            User intelowner = Core_MDF_CCP_TestDataUtility.createUser(false);
            intelowner.LastName = 'Intel Owner';
            intelowner.isActive = true;
            usrList.add(intelowner);
            
            database.insert(usrList);
            
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Datacenter','Data Center CoMarketing Fund', false);
            cpList.add(Cp);
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            cpList.add(cpRetail);
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
            cpList.add(ccfCp);
            database.insert(cpList);
            
            List<Account> accList = new List<Account>();

            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Account_Type__c = 'Reseller';            
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            accList.add(acc1);
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                  false);
            acc1Retail.Core_Account_Type__c = 'Reseller';
            acc1Retail.Industry = 'Food & Beverage';
            acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
            acc1Retail.Core_Geo__c = 'APJ';            
            acc1Retail.Core_Sub_Geo__c = 'IJKK';
            accList.add(acc1Retail);
            
            database.insert(accList);
            
            List<Account> accCoMarketingList = new List<Account>();
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accCoMarketingList.add(acc);
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'APJ';
            accRetail.Core_Sub_Geo__c = 'IJKK';
            accCoMarketingList.add(accRetail);
            database.insert(accCoMarketingList);
            
            
            List<Campaign> campList = new List<Campaign>();
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 'Yes',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund',System.today(),//Date.newInstance(2021, 01, 01) , Date.newInstance(2021, 06, 29)
                                                                        System.today().addDays(120), 2000, 'Unite', acc.Id,'2-in-1', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
            camp.Core_MDF_Technology__c = 'Intel® Agilex™';
            campList.add(camp);
            Campaign MDFcamp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampOpal','Consumer','Intel® Corporate Logo', 'MDF or both CMP & MDF',
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund',System.today(),
                                                                            System.today().addDays(120), 2000, 'Unite', acc.Id,'2-in-1', false);
            
            MDFcamp.Core_MDF_Technology__c = 'Intel® Agilex™';
            MDFcamp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
            campList.add(MDFcamp);
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(-3), 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', false);
            camp1.Core_MDF_Opal_Budget_Type_Txt__c = 'RSA MD';
            campList.add(camp1);
            
            database.insert(campList);
            
            test.starttest();
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,12345678,System.today()-1,System.today()-1,false);
            pmbRecord.Core_MDF_Budget_Type__c='MDF';
            pmbRecord.Core_MDF_Budget_Type_Txt__c='MDF';
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, acc, 99999,false);
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                                                                                            'Intel® Core™ i9 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            pfr2.Title = 'Test Activity2';
            pfr2.Core_MDF_Activity_Description__c = 'Test Activity2';
            pfr2.Core_MDF_Start_Date__c = System.today().addDays(5);//Date.newInstance(2021, 01, 01);
            pfr2.Core_MDF_End_Date__c = System.today().addDays(35);//Date.newInstance(2021, 06, 29);
            pfr2.RequestedAmount = 16000;
            pfr2.Core_MDF_Channel_Partner_Led__c = True;
            pfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr2.Core_MDF_Budget_Type_nm__c='MDF';
            pfr2.Core_MDF_Activity_Closure_Type__c='Manual';
            pfrList.add(pfr2);
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance.Id);
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance1.Id);
            PermissionSet psbudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psbudLoader.Id);
            
            
            PartnerMarketingBudget opalbudget = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,acc.Id,cp.Id,12345678,System.today().addDays(1),System.today().addDays(15),false);
            opalbudget.Core_MDF_Budget_Type__c='MDF';
            opalbudget.Core_MDF_Budget_Type_Txt__c='MDF';
            insert opalbudget;
            
            test.stopTest();
            PartnerFundAllocation pfaRecordOpal = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudget, acc, 199999, false);
            insert pfaRecordOpal;
            
            
            PartnerFundRequest MDFpfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecordOpal,opalbudget,'INDIA','Small Business','Desktop',
                                                                                              'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            MDFpfr.Title = 'Test Activity';
            MDFpfr.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr.Core_MDF_Start_Date__c = System.today().addDays(5);//Date.newInstance(2022, 01, 01);
            MDFpfr.Core_MDF_End_Date__c = System.today().addDays(35);//Date.newInstance(2022, 06, 06);
            MDFpfr.Core_MDF_Budget_Amount_Local_amt__c=1001;
            MDFpfr.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr.Core_MDF_Approval_Step_Completed__c = 1;
            MDFpfr.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            MDFpfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            MDFpfr.Core_MDF_Activity_Closure_Type__c='Manual';
            MDFpfr.Core_MDF_PriorValueOfStatus__c='Planned';
            MDFpfr.RequestedAmount = 1001;
            pfrList.add(MDFpfr);
            
            PartnerFundRequest RetailPfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today(),System.today(),false); 
            RetailPfr.Title ='Retail RSA MD Activity';
            RetailPfr.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
            RetailPfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
            RetailPfr.RequestedAmount =1000;
            RetailPfr.Amount=1000;
            RetailPfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
            RetailPfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
            RetailPfr.Core_MDF_Budget_Currency_cd__c ='USD';
            RetailPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            RetailPfr.Core_MDF_Activity_First_Approver_txt__c = usr.Id;
            RetailPfr.Core_MDF_Activity_Types__c = '';
            pfrList.add(RetailPfr);
            
            Database.insert(pfrList);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner'];
            List<Core_Trigger_Executions__c> customSettingList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c te1 = new Core_Trigger_Executions__c();
            te1.Name = 'Core_MDF_Account_node_share';
            te1.Core_Active__c=true;
            te1.Core_Class_Name__c='Core_Account';
            te1.Core_Object__c='Account';
            te1.Core_Description__c='method is used Create PNUM based External sharing group';
            te1.Core_Trigger_Events__c='After Insert';
            customSettingList.add(te1);
            Core_Trigger_Executions__c te2 = new Core_Trigger_Executions__c();
            te2.Name = 'Bypass_External_Group_Creation';
            te2.Core_Active__c=false;
            te2.Core_Class_Name__c='Core_AccountHandler';
            te2.Core_Object__c='Account';
            te2.Core_Description__c='method is used Create PNUM based External sharing group';
            te2.Core_Trigger_Events__c='After Insert';
            customSettingList.add(te2);
            Core_Trigger_Executions__c te3 = new Core_Trigger_Executions__c();
            te3.Name = 'Bypass_AcctUserMapping_Obj_Share';
            te3.Core_Active__c=false;
            te3.Core_Class_Name__c='Core_MDF_PNUMappingTriggerHandler';
            te3.Core_Object__c='Core_MDF_Partner_Node_User_Mapping__c';
            te3.Core_Description__c='Bypass_AcctUserMapping_Obj_Share';
            te3.Core_Trigger_Events__c='After Insert';
            customSettingList.add(te3);
            database.insert(customSettingList);
            
            Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 3', Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
            intacc.Core_MDF_Active_Ind__c = true;
            insert intacc;
            
            Account ccfAccount = Core_MDF_CCP_TestDataUtility.createAccount('Test Acc New 8', ccfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfAccount.Core_MDF_Parent_Fund_Account__c = intacc.id;
            ccfAccount.Core_MDF_CoMarketing_Ultimate_Account__c = intacc.Id;
            insert ccfAccount;
            
            Contact externalContact = Core_MDF_CCP_TestDataUtility.createContact(intacc.Id,false);
            externalContact.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            insert externalContact;
            
            
            User extUser = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUser.LastName = 'Claim Submitter';
            extUser.ProfileId = partnerProfile.Id;
            extUser.email = 'xyz@mail.com';
            extUser.ContactId = externalContact.Id;
            extUser.isActive = true;
            insert extUser;
            
            PermissionSet ccfExternal = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCF_USER' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = extUser.id, PermissionSetId = ccfExternal.Id);
            PermissionSet ccfExternalSubmitter = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Activity_Submitter' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = extUser.id, PermissionSetId = ccfExternalSubmitter.Id);
            
            AccountShare accShare = new AccountShare();
            accShare.AccountId = ccfAccount.Id;
            accShare.UserOrGroupId = extUser.Id;
            accShare.AccountAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'None';
            accShare.CaseAccessLevel = 'None';
            accShare.RowCause = 'Manual';
            insert accShare;
            
            
            Campaign ccfCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp','Reseller','Intel® Corporate Logo','MDF or both CMP & MDF', 
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-25,System.today()+30, 5000, 'Hybrid Cloud', ccfAccount.Id,'Server', false);
            ccfCamp.Core_MDF_Opal_Budget_Type_Txt__c= 'MDF';
            insert ccfCamp;
            
            PartnerFundRequest MDFpfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(ccfCamp.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(ccfAccount.id),null,null,'INDIA','Small Business','Desktop',
                                                                                               'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            MDFpfr1.Title = 'Test Opal Activity';
            MDFpfr1.Core_MDF_Activity_Description__c = 'Test Activity 1';
            MDFpfr1.Core_MDF_Start_Date__c = System.today()-25;
            MDFpfr1.Core_MDF_End_Date__c = System.today()+30;
            MDFpfr1.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr1.Core_MDF_Intel_Activity_Owner_Id__c = intelowner.id;
            insert MDFpfr1;
            
        }
    }
    
    @isTest
    public static void sendEmailToRMFUser(){
        User user = [SELECT Id,email FROM User WHERE email = 'rmfaccntmngr@example.com' limit 1];
        PartnerFundRequest pfr=[select id,Core_MDF_Fund_Request_Status__c,Core_MDF_Activity_Closure_Type__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Budget_Type_nm__c from  PartnerFundRequest where title='Retail RSA MD Activity' LIMIT 1];
        Test.startTest();
        pfr.Core_MDF_PriorValueOfStatus__c='Pending Approval';
        pfr.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        pfr.Core_MDF_Approval_Step_Completed__c = 0;
        System.runAs(user){
            update pfr;
        }
        Test.stopTest();
     // US - TWC702-14285: Unit Test Method should include System.Assert
    System.assertEquals('Revision Required', pfr.Core_MDF_Fund_Request_Status__c, 'Partner Fund Request status should be updated to Revision Required');
    System.assertEquals(0, pfr.Core_MDF_Approval_Step_Completed__c, 'Approval step should be reset to 0');
    }
    
    @isTest
    public static void sendEmailInt(){
        User user = [SELECT Id,email FROM User WHERE email = 'ccfaccntmngr@example.com' limit 1];
        PartnerFundRequest pfr=[select id,Core_MDF_Fund_Request_Status__c,Core_MDF_Activity_Closure_Type__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Budget_Type_nm__c from  PartnerFundRequest where title='Test Activity' LIMIT 1];
        Test.startTest();
        pfr.Core_MDF_Fund_Request_Status__c = 'Revision Required';
         System.runAs(user){
            update pfr;
        }
        Test.stopTest();
        // US - TWC702-14285: Unit Test Method should include System.Assert
        System.assertEquals('Revision Required', pfr.Core_MDF_Fund_Request_Status__c, 'Partner Fund Request status should be updated to Revision Required');
    }
}