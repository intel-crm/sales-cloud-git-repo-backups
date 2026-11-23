@isTest(SeeAllData=false)
public class Core_MDF_Approval_Request_Test {
    @TestSetup static void setUpData(){
        //Setting up profile and permission set for User
        Test.startTest();
        Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        
        List<User> lstUser = new List<user>();
        //System Admin
        User systemAdm = Core_MDF_CCP_TestDataUtility.createUser(false);
        systemadm.Email = 'systemadm@example.com';
        lstUser.add(systemAdm);
        //RMF Account Manager
        User rmfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
        rmfaccntmngr.Email = 'rmfaccntmngr@example.com';
        rmfaccntmngr.Profile = ccpCoreAccessProfile;
        lstUser.add(rmfaccntmngr);
        
        User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
        ccfaccntmngr.Profile = ccpCoreAccessProfile;
        lstUser.add(ccfaccntmngr);
        Database.insert(lstUser);
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        Database.insert(testUser);
        
        User testUser1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser1.LastName = 'Test User1';
        testUser1.UserRoleId = usRole.Id;
        testUser1.ManagerId=testUser.id;
        Database.insert(testUser1);
        
        System.runAs(testUser){
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            ChannelProgram ipaCP1 = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            cpList.add(cp);
            cpList.add(cpRetail);
            cpList.add(ipaCP1);
            insert cpList;
            
            // Creating IntelAccount with utility class
            List<Account> accIntelList = new List<Account>();
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                  false);
            Database.insert(acc1Retail);
            
            // Creating Retail Account with utility class
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'APJ';
            accRetail.Core_Sub_Geo__c='SA';
            Database.insert(accRetail);
            
            Account accIPA = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account IPA', ipaCP1.Id,
                                                                         Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accIPA.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            Database.insert(accIPA);
            test.stopTest();
        }
    }
    
    @isTest 
    static void validateApprovalReqsController(){
        List<Account> accList = new List<Account>();
        //Setting up profile and permission set for User
        Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet aacntRMFMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver' LIMIT 1];
        
        ChannelProgram cpRetail = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Retail Marketing Funds'];
        Account accRetail = [select id,Name from Account where Name='Co-marketing Test Account Retail'];
        
        PermissionSet accountManager = [select id from PermissionSet where name='Core_MDF_CCP_Internal_Retail_Account_Manager'];
        
        Test.startTest();
        
        List<User> lstUser = new List<user>();
        //System Admin
        User systemAdm = Core_MDF_CCP_TestDataUtility.createUser(false);
        systemadm.Email = 'systemadm@example.com';
        lstUser.add(systemAdm);
        
        //RMF Account Manager
        User rmfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
        rmfaccntmngr.Email = 'rmfaccntmngr@example.com';
        rmfaccntmngr.Profile = ccpCoreAccessProfile;
        lstUser.add(rmfaccntmngr);
        Database.insert(lstUser);
        
        Group grp1 = new Group();
        grp1.Name = 'JustADummyGroup';
        grp1.DeveloperName = 'JustADummyGroup';
        Database.insert(grp1);
        
        // Creating Group Members
        GroupMember grpMember = new GroupMember();
        grpMember.UserOrGroupId = rmfaccntmngr.Id;
        grpMember.GroupId = grp1.Id;
        
        
        //Assign permission Sets
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = rmfaccntmngr.Id;
        assignPermissionSetObj.PermissionSetId = aacntRMFMngrPS.Id;
        System.runAs(systemAdm){
            Database.insert(assignPermissionSetObj);
            Database.insert(grpMember);
        }
        
        //Create Campaign
        List<Campaign> campList = new List<Campaign>();
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'Yes',
                                                                    Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(16) , 
                                                                    System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', false);
        campList.add(camp);
        insert campList;
        
        Core_MDF_Criteria__c crMulti = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_MultiLvl_V5',
                                                                                   'Core_MDF_Program__c','Equal','Retail Marketing Funds','RequestedAmount','Greater Than', '0',
                                                                                   'Core_MDF_Program__c','Equal','Retail Marketing Funds','RequestedAmount','Greater Than','0','RequestedAmount','Greater Than','0',false);
        crMulti.Core_MDF_Number_Of_Steps__c = '4';
        Database.insert(crMulti);
        
        Core_MDF_Approver__c ap1Retail = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,rmfaccntmngr.Id, false);
        ap1Retail.Core_MDF_Approver_Type__c = 'Internal';
        ap1Retail.Core_MDF_Step_Number__c = 1;
        Database.insert(ap1Retail);
        
        // Retail criteria rules
        List<Core_MDF_Criteria_Rule__c> criteriaRules = new List<Core_MDF_Criteria_Rule__c>();
        
        Core_MDF_Criteria_Rule__c cruleR1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Program__c','Equal', 'Retail Marketing Funds',false);                                                                                  
        //Core_MDF_Criteria_Rule__c cruleR2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'RequestedAmount','Greater Than', '0',false);
        Core_MDF_Criteria_Rule__c cruleR3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Fund_Request_Status__c','Equal', 'Pending Review',false);                                                                                      
        //Core_MDF_Criteria_Rule__c cruleR4 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Approval_Step_Completed__c','Equal', '0',false);
        
        criteriaRules.add(cruleR1);
        //criteriaRules.add(cruleR2);
        criteriaRules.add(cruleR3);
        //criteriaRules.add(cruleR4);
        insert criteriaRules;
        
        ap1Retail.Core_MDF_Active__c = true;
        Database.update(ap1Retail);
        crMulti.Core_MDF_Active__c = true;
        Database.update(crMulti);
        
        Core_MDF_Approver__c ap2Retail = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,rmfaccntmngr.Id, false);
        ap2Retail.Core_MDF_Approver_Type__c = 'Internal';
        ap2Retail.Core_MDF_Step_Number__c = 1;
        Database.insert(ap2Retail);
        
        System.runAs(rmfaccntmngr) {
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(accRetail.id),System.today().addDays(17),System.today().addDays(28),false); 
            
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr.Core_MDF_End_Date__c = System.today().addDays(28);
            pfr.RequestedAmount = 1000;
            pfr.Core_MDF_Country_nm__c = 'INDIA';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            Database.insert(pfr);
            String output = Core_MDF_ApprovalReqsController.ObjectApINameToLabel('PartnerFundRequest');
            String input = Core_MDF_ApprovalReqsController.getObjectAPIName(pfr.id);
            Core_MDF_ApprovalReqsController.getSubmittedRecords(); 
            Core_MDF_Approval_Requests.getFieldsOfSelectedRecords('/'+pfr.id);
            Core_MDF_Approval_Requests.getNewRecords('/'+pfr.id);
            Core_MDF_Approval_Requests.approveRejectActivity(pfr.id,'test','approve',true); 
            Core_MDF_Approval_Requests.verifyApprovalActionValidity(pfr.id);
            
            
            List<ProcessInstanceWorkItem> pi = [select id,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Type,ProcessInstance.TargetObject.Name,CreatedBy.name,CreatedDate from ProcessInstanceWorkItem where ProcessInstance.TargetObject.Name='Test Retail Activity'];
            system.debug('$$$ processId'+pi);
            Core_MDF_ApprovalReqsController.getStandardPageData(pi);
            Core_MDF_ApprovalReqsController.getCustomPageData(pi);
        }  
    }
    
    @isTest
    static void validateObjectApINameToLabel(){
        Core_MDF_Approval_Requests.ObjectApINameToLabel('Campaign');
        String output = Core_MDF_ApprovalReqsController.ObjectApINameToLabel('Campaign');
        String input = Core_MDF_ApprovalReqsController.getObjectAPIName('Campaign');
    }
    
    @isTest static void validateApprovalReqsControllerIPA(){
        List<Account> accList = new List<Account>();
        Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet ipaL1ApproverPermSet = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];
        PermissionSet ipaManagerPermSet = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
        Profile sysAdminProfile = [select id from profile where name='System Administrator' Limit 1];
        ChannelProgram ipaCP = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Intel Partner Alliance'];        
        List<User> lstUser = new List<user>();
        
        //System Admin
        User systemAdm = Core_MDF_CCP_TestDataUtility.createUser(false);
        systemadm.Email = 'systemadm@example.com';
        lstUser.add(systemAdm);
        
        //IPA Account Manager
        User ipaAcctManager = Core_MDF_CCP_TestDataUtility.createUser(false);
        ipaAcctManager.Email = 'ipaAcctMngr@example.com';
        ipaAcctManager.Profile = ccpCoreAccessProfile;
        lstUser.add(ipaAcctManager);
        
        User ipaL1ApproverUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        ipaL1ApproverUser.Email = 'ipaL1Approver@example.com';
        ipaL1ApproverUser.Profile = ccpCoreAccessProfile;
        lstUser.add(ipaL1ApproverUser);
        Database.insert(lstUser);
        
        user sysAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmin.Email = 'systemadmin@example.com';
        sysAdmin.profile = sysAdminProfile;
        Database.insert(sysAdmin);
        
        system.runAs(sysAdmin){
        ipaL1ApproverUser.ManagerId = ipaAcctManager.Id;
        Database.update(ipaL1ApproverUser);
        }
        
        System.debug('USERID CHECK:::'+lstUser + ' USERID CHECK 2:::'+ipaL1ApproverUser.Id + ' USERID CHECK 3:::'+ipaAcctManager.Id);
        
        List<Group> grpList = new List<Group>();
        Group grp1 = new Group();
        grp1.Name = 'JustADummyGroup1';
        grp1.DeveloperName = 'JustADummyGroup1';
        grpList.add(grp1);
        
        Group grp2 = new Group();
        grp2.Name = 'JustADummyGroup2';
        grp2.DeveloperName = 'JustADummyGroup2';
        grpList.add(grp2);
        Database.insert(grpList);
        
        // Creating Group Members
        List<GroupMember> grpMemList = new List<GroupMember>();
        GroupMember grpMember1 = new GroupMember();
        grpMember1.UserOrGroupId = ipaAcctManager.Id;
        grpMember1.GroupId = grp1.Id;
        grpMemList.add(grpMember1);
        
        GroupMember grpMember2 = new GroupMember();
        grpMember2.UserOrGroupId = ipaL1ApproverUser.Id;
        grpMember2.GroupId = grp2.Id;
        grpMemList.add(grpMember2);
        
        //Database.insert(grpMemList);
        
        //Assign permission Sets
        List<PermissionSetAssignment> permSetAssList = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = ipaAcctManager.Id;
        assignPermissionSetObj.PermissionSetId = ipaManagerPermSet.Id;
        permSetAssList.add(assignPermissionSetObj);
        
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = ipaL1ApproverUser.Id;
        assignPermissionSetObj1.PermissionSetId = ipaL1ApproverPermSet.Id;
        permSetAssList.add(assignPermissionSetObj1);
        
        
        System.runAs(systemAdm){
            Database.insert(permSetAssList);
            Database.insert(grpMemList);
        }
        //Create Campaign
        
        Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, true);           
        String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
        
        Core_MDF_Criteria__c crMulti = Core_MDF_CCP_TestDataUtility.createCriteria('Campaign','Core_MDF_IPA_Proposal_AP_v1',
                                                                                   'Core_MDF_Program__c','Equal','Intel Partner Alliance','','', '',
                                                                                   '','','','','','','','','',true);
        
        List<Core_MDF_Approver__c> approverList = new List<Core_MDF_Approver__c>();
        Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,ipaL1ApproverUser.Id, false);
        ap1.Core_MDF_Approver_Type__c = 'Internal';
        ap1.Core_MDF_Step_Number__c = 1;
        ap1.Core_MDF_Approver_2__c = ipaL1ApproverUser.Id;
        ap1.Core_MDF_Approver_3__c = ipaL1ApproverUser.Id;  
        approverList.add(ap1);
        
        Core_MDF_Approver__c ap2 = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,ipaL1ApproverUser.Id, false);
        ap2.Core_MDF_Approver_Type__c = 'Internal';
        approverList.add(ap2);
        Database.insert(approverList);
        
        
        // Retail criteria rules
        List<Core_MDF_Criteria_Rule__c> criteriaRules = new List<Core_MDF_Criteria_Rule__c>();
        Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_Approval_Step_Counter_nbr__c','Equal',
                                                                                           '0',false);   
        /*Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'Core_MDF_Approval_Step_Counter_nbr__c','Greater Than or Equal',
'1',false);*/    
        Core_MDF_Criteria_Rule__c crule3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_Approval_Step_Counter_nbr__c','Less Than or Equal',
                                                                                           '3',false);
        Core_MDF_Criteria_Rule__c crule4 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_Program__c','Equal',
                                                                                           'Intel Partner Alliance',false);
        criteriaRules.add(crule1);
        //criteriaRules.add(crule2);
        criteriaRules.add(crule3);
        criteriaRules.add(crule4);
        insert criteriaRules;
        
        List<Core_MDF_Approver__c> approverListToUpdate = new List<Core_MDF_Approver__c>();
        ap1.Core_MDF_Active__c = true;
        approverListToUpdate.add(ap1);
        Database.update(ap1);
        crMulti.Core_MDF_Active__c = true;
        Database.update(crMulti);
        Database.update(approverListToUpdate);
        
        Test.startTest();
        System.runAs(ipaL1ApproverUser){
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today().adddays(10), System.today().adddays(14),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Review', false);
            ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c = 0;
            ipaCampaignForAP.Core_MDF_Activity_Category_Type__c = 'Digital Media->NonPartner.com';
            database.insert(ipaCampaignForAP);
            
            PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(10),System.today().addDays(14),false);
            pfr.Title = 'Test IPA Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test IPA Activity';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.RequestedAmount =890000; 
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            pfr.Amount=890000;
            Database.insert(pfr);
            
            ipaCampaignForAP.Core_MDF_Approver_1_id__c = ipaAcctManager.Id;
            ipaCampaignForAP.Core_MDF_Approver_2_id__c = ipaAcctManager.Id;
            ipaCampaignForAP.Core_MDF_Approver_3_id__c = ipaAcctManager.Id;
            ipaCampaignForAP.Core_MDF_Approver_4_id__c = ipaAcctManager.Id;
            ipaCampaignForAP.Core_MDF_Approver_5_id__c = ipaAcctManager.Id;
            ipaCampaignForAP.Core_MDF_Approver_6_id__c = ipaAcctManager.Id;
            ipaCampaignForAP.Core_MDF_Approver_7_id__c = ipaAcctManager.Id;
            ipaCampaignForAP.Core_MDF_Approver_8_id__c = ipaAcctManager.Id;
            ipaCampaignForAP.Core_MDF_Approver_9_id__c = ipaAcctManager.Id;
            ipaCampaignForAP.Core_MDF_Approver_10_id__c = ipaAcctManager.Id;
            update ipaCampaignForAP;
            
            String output = Core_MDF_ApprovalReqsController.ObjectApINameToLabel('Campaign');
            String input = Core_MDF_ApprovalReqsController.getObjectAPIName(ipaCampaignForAP.id);
            
            List<Campaign> cmpUpd = new List<Campaign>();
            cmpUpd.add(ipaCampaignForAP);        
            Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
            campOldMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);
            
            Core_MDF_IPA_Campaign_Functionality.onSubmitForApproval(cmpUpd,campOldMap);
            Core_MDF_IPA_Campaign_Functionality.callApprovalProcess(cmpUpd,campOldMap); 
            
            List<Id> apprIds = new List<Id>();
            apprIds.add(ipaL1ApproverUser.Id);
            apprIds.add(ipaAcctManager.Id);
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(ipaCampaignForAP.id);
            app.setNextApproverIds(apprIds);
            Approval.ProcessResult result = Approval.process(app);
            Test.stopTest();
            
            Core_MDF_ApprovalReqsController.getSubmittedRecords();
        }
        List<ProcessInstanceWorkItem> pi = [select id,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Type,ProcessInstance.TargetObject.Name,CreatedBy.name,CreatedDate from ProcessInstanceWorkItem where ProcessInstance.TargetObject.Name='Test Campaign - AP'];
        system.debug('$$$ processIddd'+pi);
        Core_MDF_ApprovalReqsController.getStandardPageData(pi);
        Core_MDF_ApprovalReqsController.getCustomPageData(pi);  
    }
}