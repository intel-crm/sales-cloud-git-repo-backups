@isTest(SeeAllData=false)
public class IUPGM_ApprovalTab_Test {

    @TestSetUp
    static void createTestData(){
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);    
        
        System.runAs(testUser){
            List<user> usrList=new List<User>();
            User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr.LastName = 'MDF Budget Loader';
            usr.profileId = systemAdminProfile.Id;
            usrList.add(usr);
            
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr.LastName = 'MDF Budget Loader1';
            usr.profileId = systemAdminProfile.Id;
            usrList.add(usr1);
            
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr.LastName = 'MDF Budget Loader2';
            usr.profileId = systemAdminProfile.Id;
            usrList.add(usr2);
            UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin' LIMIT 1];
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'testuser1';
            usr3.ManagerId = usr2.Id;
            usr3.UserRoleId = userRole_1.Id;
            //usr3.profileId = systemAdminProfile.Id;
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
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
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
            
            PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                          acc2.id, cp.Id , 10000 ,  Date.newInstance(2021, 01, 01), Date.newInstance(2021, 06, 29) , 
                                                                                          false);
            testBudget.IsIgnoreValidation = true;
            testBudget.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
            system.runAs(usr){
                insert testBudget;
            }
            testBudget.Core_MDF_Budget_Status__c = 'Released';
            system.runAs(usr){
                update testBudget;
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
            ccfCamp.Core_MDF_Opal_Budget_Type_Txt__c= 'CCF 1.0';
            ccfCamp.Core_MDF_Region_cd__c='APJ';
            ccfCamp.Core_MDF_Market__c='INDIA';
            Database.insert(ccfCamp);
            
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc3.Core_Geo__c = 'APJ';
            acc3.Core_Sub_Geo__c = 'IJKK';
            acc3.Core_Account_Country__c = 'JAPAN';
            insert acc3;
            
            Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, false);
            acc4.Core_Geo__c = 'APJ';
            acc4.Core_Sub_Geo__c = 'IJKK';
            insert acc4;
            
            system.runAs(usr2){
                permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Finance_Usr' LIMIT 1];
                insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = ps.Id);
                
            }
            
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                                                           acc4.id, cp1.Id , 10000 , System.today()-60 , System.today() + 60 , 
                                                                                           false);
            
            testBudget1.IsIgnoreValidation = true;
            testBudget1.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
            
            system.runAs(usr2){
               // insert testBudget1;
            }
            Test.startTest();
            testBudget1.Core_MDF_Budget_Status__c = 'Released';
            system.runAs(usr2){
                
               // update testBudget1;
            }
            
            List<Campaign> cmplst = new List<Campaign>();
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 24','Gaming','Athena', 'Yes',
                                                                         Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                         'Client CoMarketing Fund', System.today()-100, //System.today().addDays(-300), 
                                                                         System.today()+100, 10000, 'Instore innovation', 
                                                                         acc4.Id,'Desktop', false);
            
            camp1.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            camp1.Core_MDF_Activity_Category_Type__c =null;
            camp1.Core_MDF_Program__c = 'Retail Marketing Funds';
            camp1.Core_MDF_Reimbursement_Rate__c='100%';
            camp1.Core_MDF_Technology__c = 'ACPC';
            
            cmplst.add(camp1);
            
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
            String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
            
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
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External';
            pgm1.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgm1.Core_MDF_Group_Id__c = ipaGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = ipaCp.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_Region_cd__C = 'APJ';
            pgm1.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_External';
            Database.insert(pgm1);
            
            
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', 'Apollo Lake', 'Planned', false);
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c=true;
            insert ipaCampaignForAP;
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            PermissionSet priceReviewerPS = [SELECT Id FROM PermissionSet WHERE Name =: 'Core_MDF_CCP_Internal_Price_Reviewer' LIMIT 1];
            
            
            List<User> userList = new List<User>();
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            User dcfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            dcfAccountManager.profileId = ccpCoreProfile.Id;
            dcfAccountManager.LastName = 'DCF Acc Manager';
            userList.add(dcfAccountManager);
            
            User ccfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager.profileId = ccpCoreProfile.Id;
            ccfAccountManager.LastName = 'CCF Acc Manager';
            userList.add(ccfAccountManager);
            
            User priceRev = Core_MDF_CCP_TestDataUtility.createUser(false);
            priceRev.profileId = ccpCoreProfile.Id;
            priceRev.LastName = 'Price Reviewer';
            userList.add(priceRev);
            
            
            Database.insert(userList);
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager.Id);
            permissionSetAssignmentList.add(psa1);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = dcfAccManagerPS.Id, AssigneeId = dcfAccountManager.Id);
            permissionSetAssignmentList.add(psa2);
            
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = priceReviewerPS.Id, AssigneeId = priceRev.Id);
            permissionSetAssignmentList.add(psa3);
            
            Database.insert(permissionSetAssignmentList);
            Test.stopTest();  
        }
        
    }
}