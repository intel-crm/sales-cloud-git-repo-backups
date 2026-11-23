@isTest(SeeAllData=false)
public with sharing class Core_MDF_UpdateActivityFields_Test {
    @TestSetUp
    static void createTestData(){
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);    
        testUser.LastName = 'User Test';
        testUser.UserRoleId = usRole.Id;
        Database.insert(testUser);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps1.Id);
        
        System.runAs(testUser){
            // Creating User with utility class 
            
            List<String> bypassFunctionKeys = new List<String>();
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('byPassMDFPFAChangesMethod');
            bypassFunctionKeys.add('byPassRetailCampSharingOnPFAChange');
            bypassFunctionKeys.add('byPassValidateAccountHierarchy');
            
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            List<User> usrList1=new List<User>();
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            PermissionSet aacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            Database.insert(ccfaccntmngr);
            
            
            
            List<user> usrList=new List<User>();
            User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr.LastName = 'MDF Budget Loader';
            usr.profileId = systemAdminProfile.Id;
            usrList.add(usr);
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'MDF Budget Loader1';
            usr1.profileId = systemAdminProfile.Id;
            usrList.add(usr1);
            
            UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin' LIMIT 1];
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'testuser1';
            usr3.ManagerId = usr1.Id;
            usr3.UserRoleId = userRole_1.Id;
            usrList.add(usr3);
            
            User usr6 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr6.LastName = 'User Test6';
            usr6.IsActive = true;
            usrList.add(usr6);
            Database.insert(usrList);
            
            system.runAs(usr3){
                PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
                insert new PermissionSetAssignment(AssigneeId = usr3.id, PermissionSetId = psFinance.Id);
                PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
                insert new PermissionSetAssignment(AssigneeId = usr3.id, PermissionSetId = psFinance1.Id);
                PermissionSet psbudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
                insert new PermissionSetAssignment(AssigneeId = usr3.id, PermissionSetId = psbudLoader.Id);
            }
            
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', 
                                                                           Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            
            insert acc1;
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2',
                                                                                 cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                                 acc1.Id, false);
            acc2.Core_Geo__c = '';  
            acc2.Core_Sub_Geo__c = '';
            insert acc2;
            
            system.runAs(usr){
                PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
                insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
                PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
                insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance1.Id);
                
            }
            
            system.runAs(usr1){
                PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
                insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance.Id);
                PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
                insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance1.Id);
                PermissionSet psbudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
                insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psbudLoader.Id);
                
            }
            
            PartnerMarketingBudget testBudgetOEM = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetDataOEM',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                             acc2.id, cp.Id , 1000000 ,  System.today().addDays(-30) ,System.today().addDays(30),
                                                                                             false);
            testBudgetOEM.IsIgnoreValidation = true;
            testBudgetOEM.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            testBudgetOEM.Core_MDF_Budget_Type__c='OEM CMP';
            system.runAs(usr1){
                insert testBudgetOEM;
            }
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFAOEM',testBudgetOEM, acc2, 100000,true);
            
            
            
            Campaign camp = new Campaign(); 
            camp.Name = 'Test Camp 12';
            camp.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
            camp.Core_MDF_Program__c = 'Client CoMarketing Fund';
            camp.StartDate = System.today()-6;
            camp.EndDate = System.today().adddays(30);
            camp.Core_MDF_First_Year_Budget_Amount__c=10000;
            camp.Core_MDF_Priority__c='Commercial vPro';
            camp.Core_MDF_Account__c = acc2.id;
            camp.Core_MDF_Product_Type__c= 'Desktop'; 
            camp.Core_MDF_External_Visibility_Date__c=System.today()-6;
            camp.Core_MDF_Region_cd__c='APJ';
            camp.Core_MDF_Market__c='INDIA';
            insert camp;
            
            Campaign ccfCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp CCF','Gaming','Intel® Core™ i7 Processor', 'Yes',
                                                                           Core_MDF_CCP_TestDataUtility.campaign_RecordType_CCF, 
                                                                           'Client CoMarketing Fund', System.today()-6, //System.today().addDays(-300), 
                                                                           System.today()+30, 10000, 'Always Connected PC', //date.valueOf('2020-12-30')
                                                                           acc2.Id,'Desktop', false);
            ccfCamp.Core_MDF_Opal_Budget_Type_Txt__c= 'MDF';
            ccfCamp.Core_MDF_Region_cd__c='APJ';
            ccfCamp.Core_MDF_Market__c='INDIA';
            Database.insert(ccfCamp);
            
            Campaign ccfCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp CCF1','Gaming','Intel® Core™ i7 Processor', 'MDF or both CMP & MDF',
                                                                               Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                               'Client CoMarketing Fund', System.today()-6, 
                                                                               System.today()+30, 100000, 'Always Connected PC',
                                                                               acc2.Id,'Desktop', false);
            ccfCampaign.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
            ccfCampaign.Core_MDF_Region_cd__c='APJ';
            ccfCampaign.Core_MDF_Market__c='INDIA';
            Database.insert(ccfCampaign);
            
            Core_MDF_Campaign_Budgets__c campBudget= new Core_MDF_Campaign_Budgets__c();
            campBudget.Core_MDF_Campaign_Id__c=ccfCamp.id;
            campBudget.Core_MDF_Budget_Name_Id__c=testBudgetOEM.id;
            campBudget.Core_MDF_Reimbursement_Rate_Pct__c='100%';
            campBudget.Core_MDF_Reimbursement_Amt__c=100000;
            campBudget.Core_MDF_Budget_Amt__c=100000;
            campBudget.Core_MDF_Active_ind__c=true;
            Database.insert(campBudget);
            
            //Code for Retail begins
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc3.Core_Geo__c = 'APJ';
            acc3.Core_Sub_Geo__c = 'IJKK';
            acc3.BillingStateCode = ''; //US-14285
            acc3.BillingCountryCode = '';//US-14285
            insert acc3;
            
            Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, false);
            acc4.Core_Geo__c = 'APJ';
            acc4.Core_Sub_Geo__c = 'IJKK';
            insert acc4;
            
            
            
            system.runAs(usr1){
                permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Finance_Usr' LIMIT 1];
                insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
                
            }
            
            PartnerMarketingBudget testBudgetRetail = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                                                                acc4.id, cp1.Id , 10000 , System.today()-60 , System.today() + 60 , 
                                                                                                false);
            
            testBudgetRetail.IsIgnoreValidation = true;
            testBudgetRetail.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
            
            system.runAs(usr1){
                insert testBudgetRetail;
            }
            Test.startTest();
            testBudgetRetail.Core_MDF_Budget_Status__c = 'Released';
            system.runAs(usr1){
                
                update testBudgetRetail;
            }
            
            
            List<Campaign> cmplst = new List<Campaign>();
            Campaign campRetail = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 24','Gaming','Athena', 'Yes',
                                                                              Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                              'Client CoMarketing Fund', System.today()-100, //System.today().addDays(-300), 
                                                                              System.today()+100, 10000, 'Instore innovation', 
                                                                              acc4.Id,'Desktop', false);
            
            campRetail.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            campRetail.Core_MDF_Activity_Category_Type__c =null;
            campRetail.Core_MDF_Program__c = 'Retail Marketing Funds';
            campRetail.Core_MDF_Reimbursement_Rate__c='100%';
            campRetail.Core_MDF_Technology__c = 'ACPC';
            
            cmplst.add(campRetail);
            
            //Campaign for Japan cycle
            Campaign camp6 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 45','Gaming','Athena', 'Yes',
                                                                         Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                         'Client CoMarketing Fund', system.today()+ 2, //System.today().addDays(-300), 
                                                                         System.today()+230, 10000, 'Instore innovation', 
                                                                         acc4.Id,'Desktop', false);
            
            camp6.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            camp6.Core_MDF_Activity_Category_Type__c =null;
            camp6.Core_MDF_Program__c = 'Retail Marketing Funds';
            camp6.Core_MDF_Reimbursement_Rate__c='100%';
            camp6.Core_MDF_Technology__c = 'ACPC';
            
            //insert camp6;
            cmplst.add(camp6);
            
            insert cmplst;
            
            //Code for IPA starts
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account ipaUltimateAccount2 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account2',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
                
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
            ipaCoMarketingAccount.Core_Geo__c = '';
            ipaCoMarketingAccount.Core_Sub_Geo__c = '';
            insert ipaCoMarketingAccount;
         
            String budgetType = Core_MDF_CCP_ConstantClass.BCA_MDF_BUDGET_TYPE;

            
            Group ipaGrp = new Group();
            ipaGrp.Name = 'Core CCP IPA Internal';
            ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_Internal';
            Database.insert(ipaGrp);
            
            GroupMember ipaGrpMem = new GroupMember();
            ipaGrpMem.UserOrGroupId = usr.Id;
            ipaGrpMem.GroupId = ipaGrp.Id;
            system.runAs(usr){
                Database.insert(ipaGrpMem);
            }
            
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', 'Apollo Lake', 'Planned', false);
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c=true;
            ipaCampaignForAP.Core_MDF_Technology__c=''; //US-14285
            insert ipaCampaignForAP;
           
            
            PartnerFundRequest pfrRec = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(ccfCampaign.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                              testBudgetOEM,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Joint Event','Draft',false);
            pfrRec.AllocationId=pfaRecord.Id; 
            pfrRec.Title = 'Test PFR CCF';
            pfrRec.RequestedAmount = 250;
            pfrRec.Core_MDF_ActivityCategory__c='Event';
            pfrRec.Core_MDF_Activity_Types__c = 'Joint Event';
            pfrRec.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfrRec.BudgetId=testBudgetOEM.Id;
            pfrRec.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfrRec.Core_MDF_Competitive_Elements__c='Yes';
            pfrRec.Core_MDF_Start_Date__c = system.today()-2;
            pfrRec.Core_MDF_End_Date__c = system.today()-2 ;
            insert pfrRec;
            
            PartnerFundRequest testRetailPFR = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(campRetail.Id),string.valueof(acc4.id),system.today() + 20,system.today() + 21,false); 
            testRetailPFR.Title = 'Test PFR Retail';
            testRetailPFR.RequestedAmount = 100;
            testRetailPFR.Core_MDF_Fund_Request_Status__c ='Planned';
            testRetailPFR.Core_MDF_Country_nm__c = 'AFGHANISTAN'+';BANGLADESH';
            testRetailPFR.Core_MDF_Region_nm__c = 'APJ';
            testRetailPFR.Core_MDF_TargetAudience__c='';
            testRetailPFR.Core_MDF_Activity_Types__c=''; //US-14285
            database.insert(testRetailPFR);
            Test.stopTest();  
        }
        
    }
    @isTest
    static void notifyExternalUsersTest(){
        User usr1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        System.runAs(usr1){
            test.startTest();
            PartnerFundRequest pfrRec = [select id from PartnerFundRequest where Title ='Test PFR CCF']; 
            
            Map<Id,Id> PfrIdMemberId = new Map<Id,Id>();
            Id usrId = usr1.Id;
            PfrIdMemberId.put(pfrRec.Id,usrId);
            Core_MDF_UpdateActivityFields.notifyExternalUsers(PfrIdMemberId);
            System.assert(PfrIdMemberId!=null);
            Test.stopTest();
        }
    }
    
    @isTest static void getActivityRejectionCommentsTest(){
        User usr1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        Test.startTest();
        date sdate = date.today();        
        System.runAs(usr1){
            
            PartnerFundRequest pfr=[select id,OwnerId from PartnerFundRequest where Title='Test PFR Retail'];
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            
            
            
            List<Core_MDF_UpdateActivityFields.flowInputs> testList=new List<Core_MDF_UpdateActivityFields.flowInputs>();
            Core_MDF_UpdateActivityFields.flowInputs testObj=new Core_MDF_UpdateActivityFields.flowInputs();
            testObj.pfrId=pfr.Id;
            testObj.memberId=pfr.OwnerId;
            testList.add(testObj);
            Core_MDF_UpdateActivityFields.getActivityRejectionComments(testList);
            System.assert(testList!=null);
        }
        Test.stopTest();
    }
    
    @isTest
    static void getActivityRejectionCommentsTest2(){
        
        
        User usr1 = [SELECT Id, Username, UserRoleId FROM User WHERE LastName='testuser1' LIMIT 1];
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner'];
        ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
        User usr2 = [SELECT Id, Username, UserRoleId FROM User WHERE LastName='User Test6' LIMIT 1];
        
        User usr3 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        test.startTest();
        System.runAs(usr3){
            Account acc2 = [select id from account where name = 'Test Account 2']; 
            Campaign camp = [select id from Campaign where name = 'Test Camp CCF' limit 1];
            PartnerMarketingBudget testBudgetOEM = [select id from PartnerMarketingBudget where Title ='TestBudgetDataOEM'];
            Campaign ccfCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp CCF1','Gaming','Intel® Core™ i7 Processor', 'MDF or both CMP & MDF',
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                           'Client CoMarketing Fund', System.today()-6, //System.today().addDays(-300), 
                                                                           System.today()+30, 100000, 'Always Connected PC', //date.valueOf('2020-12-30')
                                                                           acc2.Id,'Desktop', false);
            ccfCamp.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
            ccfCamp.Core_MDF_Region_cd__c='APJ';
            ccfCamp.Core_MDF_Market__c='INDIA';
            Database.insert(ccfCamp);
            
            PartnerFundRequest pfrRec = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(ccfCamp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                              null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Joint Event','Draft',false);                                    
            pfrRec.RequestedAmount = 250;
            pfrRec.Core_MDF_ActivityCategory__c='Event';
            pfrRec.Core_MDF_Activity_Types__c = 'Joint Event';
            pfrRec.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfrRec.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            pfrRec.Core_MDF_Competitive_Elements__c='Yes';
            pfrRec.Core_MDF_Start_Date__c = system.today();
            pfrRec.Core_MDF_End_Date__c = system.today()+30;
            pfrRec.Core_MDF_Member_Acceptor_Id__c=usr1.id;
            pfrRec.Core_MDF_Activity_CreatedByExternalUsr__c=true;
            pfrRec.Core_MDF_Intel_Activity_Owner_Id__c=usr2.id;
            insert pfrRec;
            
            
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
            app.setObjectId(pfrRec.id);
            PartnerFundRequest pfr=[select OwnerId from PartnerFundRequest where id=:pfrRec.Id ];
            app.setSubmitterId(pfrRec.OwnerId);
            app.setProcessDefinitionNameOrId('Core_MDF_OPAL_Approval_Process_V9'); 
            app.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(app);
            
            //Id piw = [Select Id from ProcessInstanceWorkitem 
                      //where ProcessInstance.TargetObjectId = :pfrRec.id].id;
            
            
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Some comments if needed');
            req.setAction('Reject');
            
            
            //req.setWorkitemId(piw);
            
            //Approval.ProcessResult resultReject = Approval.process(req);
            
            List<Core_MDF_UpdateActivityFields.flowInputs> testList=new List<Core_MDF_UpdateActivityFields.flowInputs>();
            Core_MDF_UpdateActivityFields.flowInputs testObj=new Core_MDF_UpdateActivityFields.flowInputs();
            testObj.pfrId=pfrRec.Id;
            testObj.memberId=pfrRec.Core_MDF_Member_Acceptor_Id__c;
            testObj.program=pfrRec.Core_MDF_Program__c;
            testObj.proposalBasedIndicator=pfrRec.Core_MDF_Proposal_Based_Ind__c;
            testObj.createdByExternal=pfrRec.Core_MDF_Activity_CreatedByExternalUsr__c;
            testObj.createdById=pfrRec.OwnerId;
            testObj.pfrStatus=pfrRec.Core_MDF_Fund_Request_Status__c;
            testList.add(testObj);
            
            Core_MDF_UpdateActivityFields.getActivityRejectionComments(testList);
            Core_MDF_UpdateActivityFields.notifyExternalUsers(null);
            Core_MDF_UpdateActivityFields.getActivityRejectionComments(null);
            List<Core_MDF_FlowInputWrapper> flowWrapperList = new List<Core_MDF_FlowInputWrapper>();
            Core_MDF_FlowInputWrapper flowWrap = new Core_MDF_FlowInputWrapper(pfrRec.Core_MDF_Activity_CreatedByExternalUsr__c,
                pfrRec.CreatedById, pfrRec.Core_MDF_Member_Acceptor_Id__c, pfrRec.Id, pfrRec.Core_MDF_Fund_Request_Status__c,
                pfrRec.Core_MDF_Program__c, pfrRec.Core_MDF_Proposal_Based_Ind__c);
            flowWrapperList.add(flowWrap);
            
            List<Core_MDF_UpdateActivityFields.notificationWrapperInput> notifyWrapList = new List<Core_MDF_UpdateActivityFields.notificationWrapperInput>();
            Core_MDF_UpdateActivityFields.notificationWrapperInput notifyWrap = new Core_MDF_UpdateActivityFields.notificationWrapperInput();
            notifyWrap.flowInputWrapperList = flowWrapperList;
            notifyWrapList.add(notifyWrap);
            Core_MDF_UpdateActivityFields.sendNotificationOnRRPA(notifyWrapList);
        }
        test.stopTest();
    }
}