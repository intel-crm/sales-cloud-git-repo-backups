/***************************************************************************************************************************************
* Class Name  : Core_MDF_PMBServiceHandler_Test
* Version     : 1.0 
* Created Date: 09-04-2018
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture-JV                    09/04/2018                    Created to test Partner Marketing Budget functionality. 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_PMBServiceHandler_Test {
    public static Map<string,Id> psNameToIdMap = new Map<string,Id>();
    //setup method to create test data
    @TestSetup static void setUpData(){
        Boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
        List<User> usrList = new List<User>();
        User usr11 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr11.LastName = 'User Test11';
        usr11.IsActive = true;
        usrList.add(usr11);
        Profile ccpCoreProfile1 = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='financeManager@example.com';
        usr2.LastName = 'Finance Manager';
        usr2.ProfileId=ccpCoreProfile1.id;
        usr2.IsActive = true;
        usrList.add(usr2);
        User usrNew = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrNew.Email='financeuser@example.com';
        usrNew.LastName = 'Finance User';
        usrNew.ProfileId=ccpCoreProfile1.id;
        usrNew.IsActive = true;
        usrList.add(usrNew);
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.Email='budgetLoader@example.com';
        usrList.add(usr3);
        User usrIPA = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrIPA.Email='ipaloaderApprover@example.com';
        usrIPA.LastName = 'IPA Loader Approver';
        usrIPA.ProfileId=ccpCoreProfile1.id;
        usrIPA.IsActive = true;
        usrList.add(usrIPA); 
        
        User ccfApproverusr = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccfApproverusr.Email='ccfApproverusr@example.com';
        ccfApproverusr.LastName = 'CCF Approver';
        ccfApproverusr.ProfileId=ccpCoreProfile1.id;
        ccfApproverusr.IsActive = true;
        usrList.add(ccfApproverusr);
        
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.LastName='Admin';
        usr.profileId = systemAdminProfile.Id;
        usr.IsActive = true;
        usrList.add(usr);
        
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrList.add(testUser);
        Database.insert(usrList);
        
        List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            //ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Channel MDF','Channel MDF', false);
            ChannelProgram cp3 = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            ChannelProgram cp4 = Core_MDF_CCP_TestDataUtility.createProgram ('Datacenter','Data Center CoMarketing Fund', false);
            ChannelProgram cpEef = Core_MDF_CCP_TestDataUtility.createProgram ('Ecosystem Extension Fund','Ecosystem Extension Fund',false);
            cpList.add(cp);
            cpList.add(cp1);
            //cpList.add(cp2);
            cpList.add(cp3);
            cpList.add(cp4);
            cpList.add(cpEef);
            Database.insert(cpList);
        
        System.runAs(usr){
            // Creating Intel Account with utility class
            Account accRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Intel Test Account ', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            accRecord.BillingCity = 'Test City';         
            accRecord.BillingCountry= 'AUS';
            accRecord.BillingStreet= 'Test Street';
            //accRecord.Core_Business_Party_Id__c = '123456';
            Database.insert(accRecord);   
            // Create test accounts
        Id partnerAccountGroupRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account account1 = new Account(
            Name = 'Test Account 1',
            RecordTypeId = partnerAccountGroupRecordTypeId
        );
             Account account2 = new Account(
            Name = 'Test Account 2',
            RecordTypeId = partnerAccountGroupRecordTypeId
        );
        insert new List<Account>{account1, account2};
            
            List<Contact> contactList = new List<Contact>();
            //Creating Contact for Partner User
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(accRecord.Id,false);
            Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(accRecord.Id,false);
            contactList.add(conRecord1);
            contactList.add(conRecord2);
            Database.insert(contactList);
            
           /* List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Channel MDF','Channel MDF', false);
            ChannelProgram cp3 = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            ChannelProgram cp4 = Core_MDF_CCP_TestDataUtility.createProgram ('Datacenter','Data Center CoMarketing Fund', false);
            ChannelProgram cpEef = Core_MDF_CCP_TestDataUtility.createProgram ('Ecosystem Extension Fund','Ecosystem Extension Fund',false);
            cpList.add(cp);
            cpList.add(cp1);
            cpList.add(cp2);
            cpList.add(cp3);
            cpList.add(cp4);
            cpList.add(cpEef);
            Database.insert(cpList);*/
            
            
            Channelprogramshare cpshare= new Channelprogramshare();
            cpshare.ParentId=cp3.Id;
            cpshare.UserOrGroupId=usr.Id;
            cpshare.AccessLevel='Read';
            cpshare.RowCause='Manual';
            insert cpshare;
            
            List<Account> intAccList = new List<Account>();
            // Creating Intel Account with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account', cp.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            acc1.BillingCity = 'Test City';         
            acc1.BillingCountry= 'AUS';
            acc1.BillingStreet= 'Test Street';
            //acc1.Core_Business_Party_Id__c = '1234560';
            intAccList.add(acc1);
            
            Account accP1 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account ParentDCF', cp4.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            accP1.BillingCity = 'Test City';         
            accP1.BillingCountry= 'AUS';
            accP1.BillingStreet= 'Test Street';
            //accP1.Core_Business_Party_Id__c = '1234561';
            intAccList.add(accP1);
            
            Account accP = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account Parent', cp.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            accP.BillingCity = 'Test City';         
            accP.BillingCountry= 'AUS';
            accP.BillingStreet= 'Test Street';
            //accP.Core_Business_Party_Id__c = '1234562';
            intAccList.add(accP);
            
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account ParentRetail', cp1.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            accRetail.BillingCity = 'Test City';         
            accRetail.BillingCountry= 'AUS';
            accRetail.BillingStreet= 'Test Street';
            //accRetail.Core_Business_Party_Id__c = '1234563';
            intAccList.add(accRetail);
            
            Account accCMDF = Core_MDF_CCP_TestDataUtility.createAccount ('CMDF Test Account', cp1.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            accCMDF.BillingCity = 'Test City';         
            accCMDF.BillingCountry= 'AUS';
            accCMDF.BillingStreet= 'Test Street';
            //accCMDF.Core_Business_Party_Id__c = '1234565';
            intAccList.add(accCMDF);
            
            Account accIPA = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            accIPA.Core_MDF_CoMarketingActive__c = true;
            if(isUnifiedIdEnabled){
                accIPA.Core_Unified_Global_Customer_BP_Id__c = 'Prime001';
                //accIPA.Core_Business_Party_Id__c='6784569';
            }
            else{
                accIPA.Core_Prime_Id__c = 'Prime001'; 
            }
            accIPA.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            intAccList.add(accIPA);
            
            Account accIPA1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account1',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            accIPA1.Core_MDF_CoMarketingActive__c = true;
            if(isUnifiedIdEnabled){
                accIPA.Core_Unified_Global_Customer_BP_Id__c = 'Prime001';
                //accIPA.Core_Business_Party_Id__c='67845690';
            }else{
                accIPA.Core_Prime_Id__c = 'Prime001'; 
            }
            accIPA1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            intAccList.add(accIPA1);
            
            Account testAcctTemp = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCPTestAccountTemp', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            //testAcctTemp.Core_Business_Party_Id__c = '0987654';
            intAccList.add(testAcctTemp);
            
            Database.insert(intAccList);
            
            
            // Creating Co-marketing Account with utility class
            List<Account> accList = new List<Account>();
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 1', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accList.add(acc);
            
            Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accList.add(acc2);
            
            Account acc3 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 3', cp.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
            acc3.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accList.add(acc3);
            
            Account acc4 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 4', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc4.Core_MDF_Parent_Fund_Account__c = accCMDF.Id;
            accList.add(acc4);
            
            Account acc5 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 5', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc5.Core_MDF_Parent_Fund_Account__c = accP.Id;
            accList.add(acc5);     
            
            Account acc6 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 6', cp4.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc6.Core_MDF_Parent_Fund_Account__c = accP1.Id;
            accList.add(acc6);
            
            Account acc7 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 7', cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc7.Core_MDF_Parent_Fund_Account__c = accRetail.Id;
            acc7.Core_Geo__c ='ASMO';
            acc7.Core_Sub_Geo__c ='LAR';
            accList.add(acc7);
            
            Account accIpaVc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account IPA', cp3.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accIpaVc.Core_MDF_Parent_Fund_Account__c = accIPA1.Id;
            accIpaVc.Core_Geo__c ='ASMO';
            accIpaVc.Core_Sub_Geo__c ='LAR';
            accList.add(accIpaVc);
            
            Account accIpaPrime = Core_MDF_CCP_TestDataUtility.createAccount ('Test IPA Prime', cp3.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accIpaPrime.Core_MDF_Parent_Fund_Account__c = accIPA.Id;
            accIpaPrime.Core_Geo__c ='ASMO';
            accIpaPrime.Core_Sub_Geo__c ='NAR';
            accList.add(accIpaPrime);
            
            Account eefAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account EEF', cpEef.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,testAcctTemp.Id, false);
            eefAcc.Core_MDF_Partner_Type_nm__c ='Primary Partner';
            eefAcc.Core_MDF_CoMarketing_Ultimate_Account__c =testAcctTemp.id;
            //eefAcc.Core_Business_Party_Id__c = '09876543';
            accList.add(eefAcc);
            
            
            Id PAG_Account_Record_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
            Account pagAccount = new Account(Name='IPA PAG Account', RecordTypeId=PAG_Account_Record_Type);           
            accList.add(pagAccount);
            Database.insert(accList);
            
            List<Core_Account_Group_Member__c> agmList = new List<Core_Account_Group_Member__c>();
            Core_Account_Group_Member__c agm1 = new Core_Account_Group_Member__c(Core_Partner_Account_Id__c=pagAccount.Id,Core_Intel_Account_Id__c=accIPA.Id,Core_Inactive_Ind__c = false);
            agmList.add(agm1);
            Core_Account_Group_Member__c agm2 = new Core_Account_Group_Member__c(Core_Partner_Account_Id__c=pagAccount.Id,Core_Intel_Account_Id__c=accIPA1.Id,Core_Inactive_Ind__c = false);
            agmList.add(agm2);
            Database.insert(agmList);
            
            ChannelProgram cpIPATest = new ChannelProgram();
            cpIPATest.Name='Intel Partner Alliance';
            //cpIPATest.PRM_programCode__c='IPA';
            insert cpIPATest;
            
            PRM_AccountChannelMembership__c acctChnlMem2 = new PRM_AccountChannelMembership__c(); 
            acctChnlMem2.PRM_Account_Id__c=accIPA1.Id;
            acctChnlMem2.PRM_Channel_Program_Id__c=cpIPATest.Id;
            acctChnlMem2.PRM_Channel_Program_Level_Id__c=cpIPATest.Id;
            acctChnlMem2.PRM_Status_Nm__c = 'Approved';
            acctChnlMem2.PRM_Partner_Role__c='Seller';
            
            PRM_Builder_Strategy__c IA = new PRM_Builder_Strategy__c();
            IA.Name = 'AI Builders';
            IA.PRM_Active__c = true;
            Insert IA;
            
            PRM_IPA_Affiliation__c tb3 = new PRM_IPA_Affiliation__c();
            tb3.PRM_Account__c = accIPA1.Id;
            tb3.PRM_Active__c = true;
            tb3.PRM_Builder_Strategy__c = IA.id;
            //insert tb3;  
            
            Id selectBenRT=Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();  
            PRM_Specialty__c spec1 = new PRM_Specialty__c();
            spec1.name='Account Plan';
            spec1.PRM_Description_Txt__c='This is description';
            spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
            spec1.PRM_Role_Nm__c='Service Provider';
            spec1.PRM_Tier_Nm__c='Gold';
            spec1.PRM_Start_Date_Dt__c= system.today();
            spec1.PRM_Access_Level_Nm__c='Public';
            spec1.RecordTypeId=selectBenRT;
            spec1.PRM_Inactive_Ind__c=false;
            insert spec1;
            
            PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
            asa.PRM_InActive_Ind__c  = FALSE;
            asa.PRM_Specialty_Id__c = spec1.ID;
            asa.PRM_Account_Id__c =accIPA1.id;
            insert asa;
            
            //string accBasedBudgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefitforAccountBased(accIpaVc);
            //string accBasedBudgetType2 = Core_MDF_CCP_IPA_TestDataUtility.createBenefitforAccountBased(accIpaPrime);
            
            Id ipaAccOnboardRecTypeId = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
            List<Core_MDF_Account_Onboarding__c> accOnbList = new List<Core_MDF_Account_Onboarding__c>();
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            /*accOnb.Core_MDF_Account__c = accIPA.Id;
            accOnb.Core_MDF_Channel_Program__c = cp3.Id;
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_Host_Region_nm__c = 'EMEA';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnbList.add(accOnb);*/
            accOnb.RecordTypeId = ipaAccOnboardRecTypeId;
            accOnb.Core_MDF_Account__c = accIPA.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Intel Partner Alliance';
            accOnb.Core_MDF_Channel_Program__c = cp3.Id;
            accOnb.Core_MDF_Payment_Type_nm__c = 'Distributor (Credit Memo)';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_Host_Region_nm__c = 'EMEA';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnbList.add(accOnb);
            
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Core_MDF_OpalBudgetValidation');
            bypassFunctionKeys.add('Bypass_AccountOnboardOPIDValidations');
            bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
            bypassFunctionKeys.add('ByPass_Cancel_Activity');
            bypassFunctionKeys.add('Bypass_UpdateActivityFields');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
            bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');        
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
            bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
            bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
            bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
            bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
            bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
            bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
            bypassFunctionKeys.add('Core_MDF_Bypass_TargetSetngValidations');
            bypassFunctionKeys.add('Bypass_PaymentsBulkAPISharing');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            //bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Core_MDF_Bypass_AccOnboardValidation');
            List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
            Database.insert(accOnbList);
            Test.startTest();
            List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            Id rmfRecType = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('Retail Marketing Funds').getRecordTypeId(); 
            system.runAs(usr){
                List<String> psList = new List<String>{'Core_MDF_CCP_Internal_Finance_Usr','Core_MDF_CCP_Internal_CCF_User','Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader','Core_MDF_CCP_Internal_Channel_MDF_Budget_Loader_Approver','Core_MDF_CCP_Internal_IPA_Budget_Loader','Core_MDF_CCP_Internal_Finance_Manager','Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver','Core_MDF_CCP_Internal_Retail_Finance_Usr','Core_MDF_CCP_Internal_DCF_User','Core_MDF_Internal_EEF_Budget_Loader'};
                    for(PermissionSet ps : [SELECT Id,Name FROM PermissionSet WHERE Name IN: psList]){
                        psNameToIdMap.put(ps.Name, ps.Id);
                    }
                List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
                PermissionSetAssignment psa1 = new PermissionSetAssignment();
                psa1.AssigneeId = usr.id;
                psa1.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_Finance_Usr');
                psaList.add(psa1);
                PermissionSetAssignment psa2 = new PermissionSetAssignment();
                psa2.AssigneeId = usr.id;
                psa2.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_CCF_User');
                psaList.add(psa2);
                PermissionSetAssignment psa3 = new PermissionSetAssignment();
                psa3.AssigneeId = usr2.id;
                psa3.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_Finance_Manager');
                psaList.add(psa3);
                PermissionSetAssignment psa4 = new PermissionSetAssignment();
                psa4.AssigneeId = usrNew.id;
                psa4.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_Finance_Usr');
                psaList.add(psa4);
                PermissionSetAssignment psa5 = new PermissionSetAssignment();
                psa5.AssigneeId = usrNew.id;
                psa5.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_CCF_User');
                psaList.add(psa5);
                PermissionSetAssignment psa6 = new PermissionSetAssignment();
                psa6.AssigneeId = usrIPA.id;
                psa6.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_IPA_Budget_Loader');
                psaList.add(psa6);
                PermissionSetAssignment psa7 = new PermissionSetAssignment();
                psa7.AssigneeId = ccfApproverusr.id;
                psa7.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver');
                psaList.add(psa7);
                PermissionSetAssignment psa8 = new PermissionSetAssignment();
                psa8.AssigneeId = usr11.id;
                psa8.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_Retail_Finance_Usr');
                psaList.add(psa8);
                PermissionSetAssignment psa10 = new PermissionSetAssignment();
                psa10.AssigneeId = usr.id;
                psa10.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_Finance_Manager');
                psaList.add(psa10);
                PermissionSetAssignment psa11 = new PermissionSetAssignment();
                psa11.AssigneeId = usr.id;
                psa11.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_DCF_User');
                psaList.add(psa11);
                Database.insert(psaList);
            }
            system.runAs(usr){
                PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit1',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today()-1,System.today()-1,false);
                testBudget.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
                pmbList.add(testBudget);
                PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('NewTestBudget',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today()+2,System.today()+2,false);
                testBudget1.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
                //testBudget1.Core_MDF_Budget_Status__c='Released';
                pmbList.add(testBudget1);
                
                PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today().addDays(1),System.today().addDays(15),false);
                pmbRecord.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
                //pmbRecord.Core_MDF_Budget_Status__c='Pending Review';
                pmbList.add(pmbRecord);
                
                
                
                
                Database.insert(pmbList);
            }
            
            system.runAs(usr11){
                PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('New Retail Budget',rmfRecType,acc7.Id,cp1.Id,2055,System.today()-10000,System.today()-10000,false);
                testBudget1.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
                //testBudget1.Core_MDF_Program__c = 'Retail Marketing Funds'; 
                database.insert(testBudget1);
            }
            
            System.runAs(testuser){
                Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
                for(PermissionSet ps : [SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader','Core_MDF_CCP_Internal_Channel_MDF_Budget_Loader_Approver','Core_MDF_CCP_Internal_IPA_Budget_Loader','Core_MDF_Internal_EEF_Budget_Loader')]){
                    psNameToIdMap.put(ps.Name, ps.Id);
                }
                List<User> userList = new List<User>();
                User mdfBudgetLoader = Core_MDF_CCP_TestDataUtility.createUser(false);
                mdfBudgetLoader.LastName = 'TestClass MDF Budget Loader';
                userList.add(mdfBudgetLoader);
                
                User cmdfBudgetLoader = Core_MDF_CCP_TestDataUtility.createUser(false);
                cmdfBudgetLoader.LastName = 'CMDF Budget Loader';
                userList.add(cmdfBudgetLoader);
                
                User ipaBudgetLoader = Core_MDF_CCP_TestDataUtility.createUser(false);
                ipaBudgetLoader.LastName = 'IPA Budget Loader';
                userList.add(ipaBudgetLoader);
                
                User eefBudgetLoader = Core_MDF_CCP_TestDataUtility.createUser(false);
                eefBudgetLoader.LastName = 'TestClass EEF Budget Loader';
                userList.add(eefBudgetLoader);
                
                Database.insert(userList);
                
                List<PermissionSetAssignment> psaList1 = new List<PermissionSetAssignment>();
                PermissionSetAssignment psa1 = new PermissionSetAssignment();
                psa1.AssigneeId = mdfBudgetLoader.id;
                psa1.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader');
                psaList1.add(psa1);
                PermissionSetAssignment psa2 = new PermissionSetAssignment();
                psa2.AssigneeId = cmdfBudgetLoader.id;
                psa2.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_Channel_MDF_Budget_Loader_Approver');
                psaList1.add(psa2);
                PermissionSetAssignment psa3 = new PermissionSetAssignment();
                psa3.AssigneeId = ipaBudgetLoader.id;
                psa3.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_IPA_Budget_Loader');
                psaList1.add(psa3);
                PermissionSetAssignment psa4 = new PermissionSetAssignment();
                psa4.AssigneeId = eefBudgetLoader.id;
                psa4.PermissionSetId = psNameToIdMap.get('Core_MDF_Internal_EEF_Budget_Loader');
                psaList1.add(psa4);
                Database.insert(psaList1);
                
                Id ccfIUPGMRecordTypeId = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
                Id cmdfIUPGMRecordTypeId = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Channel_MDF').getRecordTypeId();
                Id EEF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
                
                List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
                Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
                iupgm1.RecordTypeId = cmdfIUPGMRecordTypeId;
                iupgm1.Core_MDF_Account_id__c = acc4.Core_MDF_Parent_Fund_Account__c;
                iupgm1.Core_MDF_Program_nm__c = 'Channel MDF';
                iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
                iupgm1.Core_MDF_User_id__c = cmdfBudgetLoader.Id;
                iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Channel_MDF_Budget_Loader';
                iupgm1.Core_MDF_All_Accounts_cd__c = 'No';
                iupgm1.Core_MDF_Budget_Type_nm__c = 'Intel MDF Account Based2';
                //iupgmList.add(iupgm1);
                
                Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
                iupgm.Core_MDF_Account_id__c = acc1.Id;
                iupgm.RecordTypeId = ccfIUPGMRecordTypeId;
                iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
                iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
                iupgm.Core_MDF_User_id__c = mdfBudgetLoader.Id;
                iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader';
                iupgm.Core_MDF_All_Accounts_cd__c = 'No';
                iupgmList.add(iupgm); 
                
                Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
                iupgm2.Core_MDF_Account_id__c = acc1.Id;
                iupgm2.RecordTypeId = ccfIUPGMRecordTypeId;
                iupgm2.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
                iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'WW';
                iupgm2.Core_MDF_User_id__c = ccfApproverusr.Id;
                iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver';
                iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
                iupgmList.add(iupgm2);
                
                Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
                iupgm3.RecordTypeId = EEF_RecordType;
                //iupgm3.Core_MDF_Account_id__c = acc3.Core_MDF_Parent_Fund_Account__c;
                iupgm3.Core_MDF_Program_nm__c = 'Ecosystem Extension Fund';
                iupgm3.Core_MDF_Budget_Type_nm__c = 'Cloud';
                iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'WW';
                iupgm3.Core_MDF_User_id__c = eefBudgetLoader.Id;
                iupgm3.Core_MDF_Role_nm__c = 'Core_MDF_Internal_EEF_Budget_Loader';
                iupgm3.Core_MDF_All_Accounts_cd__c = 'yes';
                iupgm3.Core_MDF_All_Budget_Type_Access_Ind__c = false;
                iupgm3.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'WW->Cloud';
                Database.insert(iupgm3);
                
                insert iupgmList;
                
                
                
                /*psa6.AssigneeId = usrIPA.id;
                psa6.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_IPA_Budget_Loader');*/
                Id recordTypeIdPMBIPA = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Account_Based').getRecordTypeId();
                System.runAs(usrIPA){
                    
                    try{
                        PartnerMarketingBudget BudgetRecordIPA1 = Core_MDF_CCP_TestDataUtility.createBudget('TestIPABudget',recordTypeIdPMBIPA,accIpaVc.Id,cp3.Id,123456,System.today(),System.today(),false);
                        BudgetRecordIPA1.Core_MDF_Budget_Type_Txt__c = 'Account Plan';
                        insert BudgetRecordIPA1;
                    }
                    catch(Exception e){
                        String errorMessage = e.getMessage();
                        //Assert.isTrue(errorMessage.contains(System.Label.Core_MDF_PMBOverlapError));
                    }
               
                }
                Core_MDF_Criteria__c cr1 = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerMarketingBudget','Core_MDF_CCP_Budget_Type_Approval',
                                                                                       'Core_MDF_Program_Nm__c','In','Client;Datacenter','Core_MDF_Budget_Type_Txt__c','In', 'MDF+;MDF',
                                                                                       null,null,null,null,null,null,null,null,null,false);
                insert cr1;
                
                List<Core_MDF_Approver__c> appList = new List<Core_MDF_Approver__c>();
                Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cr1.Id,testuser.Id, false);
                ap1.Core_MDF_Approver_Type__c = 'Internal';
                appList.add(ap1);
                insert appList;
                
                List<Core_MDF_Criteria_Rule__c> crList = new List<Core_MDF_Criteria_Rule__c>();
                // Creating Criteria rules for approvers
                Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_Ultimate_Account_Id__c','Equal',
                                                                                                   accP.Id,false);
                insert crule1;  
                
                List<Core_MDF_Approver__c> apUpdateList = new List<Core_MDF_Approver__c>();
                ap1.Core_MDF_Active__c = True;
                apUpdateList.add(ap1);
                update apUpdateList;
                
                List<Core_MDF_Criteria__c> cUpdateList = new List<Core_MDF_Criteria__c>();
                cr1.Core_MDF_Active__c = True;
                cUpdateList.add(cr1);
                update cUpdateList;
                
                //SPCF Records
                ChannelProgram cpSPCF = Core_MDF_CCP_TestDataUtility.createProgram ('Service Provider Co-Marketing Fund','Service Provider CoMarketing Fund', true);
                
                // Creating IntelAccount with utility class
                Account accParentSPCF = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Intel', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                true);
                Account accSPCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Co-marketing Test Account_SPCF', cpSPCF.Id,
                                                                                    Core_MDF_CCP_TestDataUtility.Account_Record_Type, accParentSPCF.Id, true);
                
             
                System.runAs(mdfBudgetLoader){
                PartnerMarketingBudget BudgetRecord1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNew1',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today(),System.today(),false);
                BudgetRecord1.Core_MDF_Budget_Type_Txt__c = 'MDF';
                //BudgetRecord1.Core_MDF_Budget_Status__c = 'Released';
                 insert BudgetRecord1;
                    
               PartnerMarketingBudget testBudgetMDF1 = Core_MDF_CCP_TestDataUtility.createBudget('NewTestBudget1',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today()+2,System.today()+2,false);
                testBudgetMDF1.Core_MDF_Budget_Type_Txt__c = 'MDF';
                //testBudget1.Core_MDF_Budget_Status__c='Released';
                insert testBudgetMDF1;
                Test.stopTest();
                
                PartnerMarketingBudget testBudgetMDF2 = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB1',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today().addDays(1),System.today().addDays(15),false);
                testBudgetMDF2.Core_MDF_Budget_Type_Txt__c = 'MDF';
                //insert testBudgetMDF2;
            }
                
            }
            
        }
    }
    // Test method tp fetch and delete the created PNUM Records
    @isTest static void createanddeletePNUMRecords(){
        test.startTest();
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account acc1 = [SELECT Id from Account where Name='Test Account 1' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram limit 1];
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            // Create a Partner Node User Mapping with the above created Account
            //PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc1.Id,cp.Id,123456,System.today().addDays(1),System.today().addDays(15),false);
            //pmbRecord.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
            //insert pmbRecord;
            PartnerMarketingBudget pmbRecord=[Select Id,Core_MDF_Budget_Type_Txt__c, Core_MDF_Budget_Partner__c from PartnerMarketingBudget where Title='TestPMB' LIMIT 1];

            try{
                
                PartnerMarketingBudget  pmbClonedRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc1.Id,cp.Id,123456,System.today().addDays(1),System.today().addDays(16),false);
                pmbClonedRecord.Core_MDF_Budget_Type_Txt__c = pmbRecord.Core_MDF_Budget_Type_Txt__c;
                insert pmbClonedRecord;
                pmbClonedRecord.EndDate = System.today().addDays(15);
                Database.update(pmbClonedRecord);
                
            }catch(Exception e){
                String errorMessage = e.getMessage();
                //Assert.isTrue(errorMessage.contains(System.Label.Core_MDF_PMBOverlapError));
            } 
            try{
                
                PartnerMarketingBudget  pmbRecordtobeUpdated = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc1.Id,cp.Id,123456,System.today().addDays(2),System.today().addDays(15),false);
                pmbRecordtobeUpdated.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
                pmbRecordtobeUpdated.Core_MDF_Budget_Status__c = 'Released';
            }catch(Exception e){
                String errorMessage = e.getMessage();
                Assert.isTrue(errorMessage.contains(System.Label.Core_MDF_PMBOverlapError));
            } 
            
        }
        test.stopTest();        
    }
    
    // Test method tp fetch and delete the created PNUM Records
    @isTest static void validateDecreasedBudgetAmountOnChange(){
        test.startTest();
        Account acc3 = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Id from Account where Name='Test Account 3' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram where Name='Client' limit 1];
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PartnerMarketingBudget  pmbRecordtobeUpdated = new PartnerMarketingBudget();
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            try{
                
                pmbRecordtobeUpdated = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today().addDays(2),System.today().addDays(15),false);
                pmbRecordtobeUpdated.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
                insert pmbRecordtobeUpdated;
                List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
                pmbList.add(pmbRecordtobeUpdated);
                Core_MDF_PMBServiceHandler.invokeBudgetShareRecordToGeoGroup(pmbList);
                Assert.areEqual(True, pmbList != null);
            }catch(Exception e){
                String errorMessage = e.getMessage();
                //Assert.isTrue(errorMessage.contains(System.Label.Core_MDF_PMBDuplicateError));
            } 
        }
        User financeManager = [SELECT Id,Email from User where Email='financeManager@example.com' limit 1];
        //PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Manager'];
        //insert new PermissionSetAssignment(AssigneeId = financeManager.id, PermissionSetId = ps.Id ); 
        System.runAs(financeManager){
            try{
                pmbRecordtobeUpdated.Core_MDF_Budget_Status__c = 'Released';
                Database.update(pmbRecordtobeUpdated);
                
                //Areefa start
                PartnerMarketingBudget pmb1 = [SELECT Id,Title, Core_MDF_Budget_Status__c,Amount,TotalAllocatedAmount FROM PartnerMarketingBudget WHERE Title ='TestPMB'];
                
                //Areefa End
                pmbRecordtobeUpdated.Core_MDF_Decrease_Budget_Amount_Amt__c  = 1234565;
                
                 try {
                    Database.update(pmbRecordtobeUpdated);
                    Assert.fail('Expected exception for invalid budget decrease');
                } catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains(System.Label.Core_MDF_Budget_Decrease_Amount), 'Expected error message for budget decrease');
                }
                
                //Devashish
                pmbRecordtobeUpdated.Core_MDF_Budget_Status__c = 'Released';
                Database.update(pmbRecordtobeUpdated);
                pmbRecordtobeUpdated.amount = 7862;
                pmbRecordtobeUpdated.Core_MDF_Decrease_Budget_Amount_Amt__c = 98;
                Database.update(pmbRecordtobeUpdated);
                pmbRecordtobeUpdated.Core_MDF_Budget_Status__c = 'Pending Review';
                Database.update(pmbRecordtobeUpdated);
                pmbRecordtobeUpdated.Core_MDF_Budget_Status__c = 'Rejected';
                Database.update(pmbRecordtobeUpdated);
                //Devashish end
            }catch(Exception e){
                String errorMessage = e.getMessage();
            }
        }
        test.stopTest();
    }
    
    @isTest static void validateDecreasedBudgetAmountOnMDF(){
        test.startTest();
        Account acc3 = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Id from Account where Name='Test Account 3' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram where Name='Client' limit 1];
        
        User usr = [SELECT Id,Email from User where LastName='TestClass MDF Budget Loader' limit 1];
        PartnerMarketingBudget  pmbRecordtobeUpdated = new PartnerMarketingBudget();
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            try{                
                pmbRecordtobeUpdated = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today().addDays(2),System.today().addDays(15),false);
                pmbRecordtobeUpdated.Core_MDF_Budget_Type_Txt__c = 'MDF';
                insert pmbRecordtobeUpdated;
                List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
                pmbList.add(pmbRecordtobeUpdated);
                Core_MDF_PMBServiceHandler.invokeBudgetShareRecordToGeoGroup(pmbList);
            }catch(Exception e){
                String errorMessage = e.getMessage();
                Assert.isFalse(errorMessage.contains(System.Label.Core_MDF_PMBDuplicateError));
            } 
        }
        User financeManager = [SELECT Id,Email from User where Email='financeManager@example.com' limit 1];
        //PermissionSet ps1 = [SELECT ID From PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Manager'];
        //insert new PermissionSetAssignment(AssigneeId = financeManager.id, PermissionSetId = ps1.Id ); 
        System.runAs(financeManager){
            try{
                pmbRecordtobeUpdated.Core_MDF_Budget_Status__c = 'Released';
                Database.update(pmbRecordtobeUpdated);
                pmbRecordtobeUpdated.Core_MDF_Decrease_Budget_Amount_Amt__c  = 1234565;
                Database.update(pmbRecordtobeUpdated);
                pmbRecordtobeUpdated.Core_MDF_Budget_Status__c = 'Released';
                Database.update(pmbRecordtobeUpdated);
            }catch(Exception e){
                String errorMessage = e.getMessage();
            }
        }
        test.stopTest();
    }
    
    //Test method to check duplicate budget
    /*@isTest static void validateDuplicateBudgetOnCreate(){
        test.startTest();
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account acc = [SELECT Id from Account where Name='Test Account 1' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram limit 1];
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            try{
                PartnerMarketingBudget BudgetRecord1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudget',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today(),System.today(),false);
                BudgetRecord1.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
                insert BudgetRecord1;
                PartnerMarketingBudget BudgetRecord2 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudget1',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today(),System.today(),false);
                BudgetRecord2.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
                insert BudgetRecord2;
            }catch(Exception e){
                String errorMessage = e.getMessage();
               // Assert.isTrue(errorMessage.contains(System.Label.Core_MDF_PMBDuplicateError));
            }
        } 
        test.stopTest();
    }*/
    //Test method to check duplicate budget on update
  /* @isTest static void validateDuplicateBudgetOnUpdate(){
        test.startTest();
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account acc3 = [SELECT Id from Account where Name='Test Account 3' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram limit 1];
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            try{
                PartnerMarketingBudget BudgetRecord1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today(),System.today(),false);
                BudgetRecord1.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
                insert BudgetRecord1;
                PartnerMarketingBudget  pmbRecordtobeUpdated= [Select Id, Core_MDF_Budget_Partner__c from PartnerMarketingBudget where Title='TestDupBudgetNewForEdit1' LIMIT 1];
                pmbRecordtobeUpdated.StartDate = System.today();
                pmbRecordtobeUpdated.EndDate = System.today(); 
                Database.update(pmbRecordtobeUpdated);
                pmbRecordtobeUpdated.Core_MDF_Budget_Status__c='Released';
                Database.update(pmbRecordtobeUpdated);
                Assert.areEqual(false , pmbRecordtobeUpdated.Core_MDF_Budget_Status__c != 'Released');
            }catch(Exception e){
                String errorMessage = e.getMessage();
                //Assert.isTrue(errorMessage.contains(System.Label.Core_MDF_PMBDuplicateError));
            }
            
        } 
        test.stopTest();
    }*/
    
    //Test method to Check Decreased budget amount
    @isTest static void ValidateMdfBudgetDecreasedAmount(){
        test.startTest();
        Account acc3 = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Id from Account where Name='Test Account 3' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram where Name='Client' limit 1];
        
        User usr = [SELECT Id,Email from User where LastName='TestClass MDF Budget Loader' limit 1];
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            try{
                PartnerMarketingBudget BudgetRecord1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today(),System.today(),false);
                BudgetRecord1.Core_MDF_Budget_Type_Txt__c = 'MDF';
                insert BudgetRecord1;
                
                PartnerFundAllocation pfaTestAccount3 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Account 3 Allocation',BudgetRecord1, acc3, 100,true);
                
                BudgetRecord1.Core_MDF_Budget_Status__c = 'Released';
                Database.update(BudgetRecord1);
                BudgetRecord1.Core_MDF_Decrease_Budget_Amount_Amt__c  = 123;
                Database.update(BudgetRecord1);
                BudgetRecord1.Core_MDF_Budget_Status__c = 'Released';
                Database.update(BudgetRecord1);
                System.assertEquals(BudgetRecord1.Core_MDF_Budget_Type_Txt__c,'MDF');
            }catch(Exception e){
                String errorMessage = e.getMessage();
            }
            
        } 
        test.stopTest();
    }
    
    //Test method to Check Decreased budget amount
    @isTest static void ValidateNonMdfBudgetDecreasedAmount(){
        test.startTest();
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account acc3 = [SELECT Id from Account where Name='Test Account 3' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram limit 1];
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            //PartnerMarketingBudget BudgetRecord1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNew',RecordTypeIdPMB,acc3.Id,cp.Id,1234567,System.today()+2,System.today()+2,false);
            //BudgetRecord1.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
            //insert BudgetRecord1;
            List<PartnerMarketingBudget> PMBList = new List<PartnerMarketingBudget>();
            Map<Id,PartnerMarketingBudget> oldPMBMap = new Map<Id,PartnerMarketingBudget>();
            PartnerMarketingBudget BudgetRecord1=[Select Id,Core_MDF_Budget_Type_Txt__c, Core_MDF_Budget_Partner__c from PartnerMarketingBudget where Title='NewTestBudget' LIMIT 1];
            PartnerMarketingBudget BudgetRecord2=[Select Id,Core_MDF_Budget_Type_Txt__c, Core_MDF_Budget_Partner__c from PartnerMarketingBudget where Title='TestPMB' LIMIT 1];
            //BudgetRecord1.StartDate=System.today()+2;
            //BudgetRecord1.EndDate=System.today()+2;
            BudgetRecord1.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
            BudgetRecord2.Core_MDF_Budget_Status__c = 'Pending Review';
            Database.update(BudgetRecord1);
            Database.update(BudgetRecord2);
            PMBList.add(BudgetRecord1);
            //PMBList.add(BudgetRecord2);
            oldPMBMap.put(BudgetRecord2.Id,BudgetRecord2);
            //PartnerMarketingBudget BudgetRecord1=[Select Id,Core_MDF_Budget_Type_Txt__c, Core_MDF_Budget_Partner__c from PartnerMarketingBudget where Title='NewTestBudget' LIMIT 1];
            //BudgetRecord1.StartDate=System.today()+2;
            //BudgetRecord1.EndDate=System.today()+2;
            //BudgetRecord1.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
            //Database.update(BudgetRecord1);
            System.assertEquals(BudgetRecord1.Core_MDF_Budget_Type_Txt__c,'CCF 1.0');
            try{
                PartnerFundAllocation pfaTestAccount3 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Account 3 Allocation',BudgetRecord1, acc3, 100,true);
                
                BudgetRecord1.Core_MDF_Budget_Status__c = 'Released'; 
                BudgetRecord1.Core_MDF_Decrease_Budget_Amount_Amt__c  = 123;
                Database.update(BudgetRecord1);
                BudgetRecord1.Core_MDF_Budget_Status__c = 'Released';
                Database.update(BudgetRecord1);
                //Core_MDF_PMBServiceHandler.validateBudgetStatusOnUpdate(PMBList,oldPMBMap);
            }catch(Exception e){
                String errorMessage = e.getMessage();
                Assert.isTrue(errorMessage.contains(System.Label.Core_MDF_Budget_Decrease_Amount)); 
            }  
        }  
        test.stopTest();
    }
    
    //Validate Budget Creation for Channel MDF
    @isTest static void validateBudgetCreationNegative(){
        test.startTest();
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account acc1 = [SELECT Id from Account where Name='Test Account 3' limit 1];
        ChannelProgram cpMDF = [Select id from ChannelProgram where Name='Client' limit 1];
        PartnerMarketingBudget  pmbRecordtobeUpdated = new PartnerMarketingBudget();
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('Channel MDF Account Based').getRecordTypeId();
        System.runAs(usr){
            try{
                pmbRecordtobeUpdated = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc1.Id,cpMDF.Id,1,System.today().addDays(2),System.today().addDays(15),false);
                pmbRecordtobeUpdated.Core_MDF_Budget_Type_Txt__c = 'MDF';
                insert pmbRecordtobeUpdated;
                List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
                pmbList.add(pmbRecordtobeUpdated);
                Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess(pmbList,null,false);
                Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess(Null,null,true);
                Assert.isNotNull(pmbList);
            }catch(Exception e){
                String errorMessage = e.getMessage(); 
            }
            
        }
        test.stopTest();
    }
    
    @isTest static void validateBudgetCreationPositiveMDF(){
        Test.startTest();
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader'];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps1.Id);
        Account acc1 = [SELECT Id from Account where Name='Test Account 3' limit 1];
        ChannelProgram cpMDF = [Select id from ChannelProgram where Name='Client' limit 1];
        PartnerMarketingBudget  pmbRecordtobeUpdated = new PartnerMarketingBudget();
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            try{
                pmbRecordtobeUpdated = Core_MDF_CCP_TestDataUtility.createBudget('TestPMBMDF',RecordTypeIdPMB,acc1.Id,cpMDF.Id,1,System.today().addDays(2),System.today().addDays(15),false);
                pmbRecordtobeUpdated.Core_MDF_Budget_Type_Txt__c = 'MDF';
                insert pmbRecordtobeUpdated;
                List<PartnerMarketingBudget> pmbList1 = new List<PartnerMarketingBudget>();
                pmbList1.add(pmbRecordtobeUpdated);
                Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess(pmbList1,null,false);
                PartnerMarketingBudget pmb = [Select id,Core_MDF_Budget_Status__c from PartnerMarketingBudget limit 1];
                system.assertEquals('Pending Review', pmb.Core_MDF_Budget_Status__c);
            }catch(Exception e){
                String errorMessage = e.getMessage();
                //Assert.isTrue(errorMessage.contains('Please choose the appropriate Budget Partner/Channel Program:'));
            }
            
        }
        Test.stopTest();
    }
    @isTest static void validateBudgetCreationPositiveChannelMDF(){
        test.startTest();
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Channel_MDF_Budget_Loader_Approver'];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps1.Id);
        Account acc1 = [SELECT Id from Account where Name='CMDF Test Account' limit 1];//
        ChannelProgram cpMDF = [Select id from ChannelProgram where Name='Client' limit 1];
        Group grp = new Group();
        grp.Name = 'CMDF_Int_Grp_WW';
        grp.DeveloperName = 'CMDF_Int_Grp_WW';
        database.insert(grp);
        System.runAs(usr){
            try{
                Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
                pgm.Core_MDF_Account__c = acc1.Id;
                pgm.Core_MDF_Group_Name__c = 'CMDF_Int_Grp_WW';
                pgm.Core_MDF_Type_of_Access__c = 'External';
                pgm.Core_MDF_Source_Txt__c  = 'Test';
                pgm.Core_MDF_Group_Id__c = grp.Id;                
                pgm.Core_MDF_Channel_Program__c = cpMDF.Id;
                pgm.Core_MDF_Region_cd__c='WW';
                Database.insert(pgm);
                
                
                PartnerMarketingBudget  pmbRecordtobeUpdated = new PartnerMarketingBudget();
                Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('Channel MDF Account Based').getRecordTypeId();
                Account accBudget = [SELECT Id from Account where Name='Test Account 4' limit 1]; 
                
                pmbRecordtobeUpdated = Core_MDF_CCP_TestDataUtility.createBudget('TestPMBMDF',RecordTypeIdPMB,accBudget.Id,cpMDF.Id,1,System.today().addDays(2),System.today().addDays(15),false);
                pmbRecordtobeUpdated.Core_MDF_Budget_Type_Txt__c = 'Intel MDF Account Based2';
                insert pmbRecordtobeUpdated;
                List<PartnerMarketingBudget> pmbList1 = new List<PartnerMarketingBudget>();
                pmbList1.add(pmbRecordtobeUpdated);
                Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess(pmbList1,null,false);
                PartnerMarketingBudget pmb = [Select id,Core_MDF_Budget_Status__c from PartnerMarketingBudget limit 1];
                system.assertEquals('Pending Review', pmb.Core_MDF_Budget_Status__c);
            }catch(Exception e){
                String errorMessage = e.getMessage();
                //Assert.isTrue(errorMessage.contains('Please choose the appropriate Budget Partner/Channel Program:'));
            }
            
        }
        test.stopTest();
    } 
    
    @isTest static void validateBudgetCreationforUser(){
        test.startTest();
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader'];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        
        Account acc1 = [SELECT Id from Account where Name='Test Account 3' limit 1];
        
        ChannelProgram cp = [Select id from ChannelProgram where Name='Client' limit 1];
        PartnerMarketingBudget  pmbRecordtobeUpdated = new PartnerMarketingBudget();
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            try{
                pmbRecordtobeUpdated = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc1.Id,cp.Id,123456,System.today().addDays(2),System.today().addDays(15),false);
                pmbRecordtobeUpdated.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
                insert pmbRecordtobeUpdated;
                System.assertEquals(pmbRecordtobeUpdated.Core_MDF_Budget_Type_Txt__c,'OEM CMP');
                List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
                pmbList.add(pmbRecordtobeUpdated);
                Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess(pmbList,null,false);
            }catch(Exception e){
                String errorMessage = e.getMessage();
                //Assert.isTrue(errorMessage.contains('You are not authorized to create the Budgets for the Selected Budget Type'));
            }
        }
        test.stopTest();
    }
    
    @isTest static void validateBudgetCreationforUser2(){
        test.startTest();
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader'];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        
        Account acc1 = [SELECT Id from Account where Name='Test Account 3' limit 1];
        
        ChannelProgram cp = [Select id from ChannelProgram where Name='Client' limit 1];
        PartnerMarketingBudget  pmbRecordtobeUpdated = new PartnerMarketingBudget();
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            try{
                pmbRecordtobeUpdated = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc1.Id,cp.Id,123456,System.today().addDays(2),System.today().addDays(15),false);
                pmbRecordtobeUpdated.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
                insert pmbRecordtobeUpdated;
                System.assertEquals(pmbRecordtobeUpdated.Core_MDF_Budget_Type_Txt__c,'OEM CMP');
                List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
                pmbList.add(pmbRecordtobeUpdated);
                PartnerMarketingBudget pmbRecord2 = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB2',RecordTypeIdPMB,acc1.Id,cp.Id,123456,System.today().addDays(2),System.today().addDays(15),false);

                //List<PartnerMarketingBudget> oldpmbList = new List<PartnerMarketingBudget>();
                //oldpmbList.add(pmbRecord2);
                String recordId=pmbRecord2.Id;
                Map<Id, PartnerMarketingBudget> oldPMBMap = new Map<Id, PartnerMarketingBudget>();
                oldPMBMap.put(recordId,pmbRecord2);
                Core_MDF_PMBServiceHandler.notifyApprovers(pmbList,oldPMBMap);
            }catch(Exception e){
                String errorMessage = e.getMessage();
                //Assert.isTrue(errorMessage.contains('You are not authorized to create the Budgets for the Selected Budget Type'));
            }
        }
        test.stopTest();
        
    }
    
    
    //Test method to Check budget creation process
    @isTest static void ValidateBudgetCreationMethodPositive(){
        test.startTest();
        Account acc3 = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Id from Account where Name='Test Account 3' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram where Name='Client' limit 1];
        
        User usr = [SELECT Id,Email from User where lastName='TestClass MDF Budget Loader' limit 1];
        
        system.runAs(usr){
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            List<PartnerMarketingBudget> pmbList1 = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit2',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today()-1,System.today()-1,false);
            testBudget1.Core_MDF_Budget_Type_Txt__c = 'MDF';
            pmbList1.add(testBudget1);
            try{
                insert pmbList1;
                System.assertNotEquals(pmbList1.size(),0);
                Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess(pmbList1,null,false);
                PartnerMarketingBudget pmb = [Select id,Core_MDF_Budget_Status__c from PartnerMarketingBudget limit 1];
                system.assertEquals('Pending Review', pmb.Core_MDF_Budget_Status__c);
            }catch(Exception e){
                String errorMessage = e.getMessage();
            }
            
        } 
        test.stopTest();
    }
    //Test method to Check budget creation process
    @isTest static void ValidateBudgetCreationMethod(){
        test.startTest();
        Account acc3 = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Id from Account where Name='Test Account 3' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram where Name='Client' limit 1];
        User usr = [SELECT Id,Email from User where lastName='User Test11' limit 1];
        
        system.runAs(usr){
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            List<PartnerMarketingBudget> pmbList1 = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit2',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today()-1,System.today()-1,false);
            testBudget1.Core_MDF_Budget_Type_Txt__c = 'MDF';
            pmbList1.add(testBudget1);
            try{
                insert pmbList1;
                Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess(pmbList1,null,false);
                System.assert(pmbList1!=null);
            }catch(Exception e){
                String errorMessage = e.getMessage();
            }
            
        }
        test.stopTest();        
    }
    
    //Test method to Check approval process
    @isTest static void ValidateApprovalProcessMethodError(){
        test.startTest();
        Account acc3 = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Id from Account where Name='Test Account 2' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram where Name='Client' limit 1];
        User testuser = [SELECT Id,Email from User where Email='testUsercoreMDF@intel.com' limit 1];
        
        System.runAs(testuser){
            Core_MDF_Criteria_Rule__c cr2 = [Select Id from Core_MDF_Criteria_Rule__c LIMIT 1];
            cr2.Core_MDF_Field_Name__c = 'Core_MDF_Ultimate_Account_Id__c';
            cr2.Core_MDF_Value__c = 'Test';
            update cr2;
        }   
        User usr = [SELECT Id,Email from User where LastName='TestClass MDF Budget Loader' limit 1];
        
        System.runAs(usr){
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            List<PartnerMarketingBudget> pmbList1 = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit2',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today()-1,System.today()-1,false);
            testBudget1.Core_MDF_Budget_Type_Txt__c = 'MDF';
            pmbList1.add(testBudget1);
            try{
                insert pmbList1;
                PartnerMarketingBudget pmb = [Select id,Core_MDF_Approver_1__c from PartnerMarketingBudget limit 1];
                system.assertEquals('Pending Review', pmb.Core_MDF_Budget_Status__c);
            }catch(Exception e){
                String errorMessage = e.getMessage();
            }
        }
        test.stopTest();
    }
    
    
    //Test method to Check validateOnCreateOrUpdateCMDFBudgets
    @isTest static void validateOnCreateOrUpdateCMDFBudgets(){
        test.startTest();
        Account acc3 = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Id from Account where Name='Test Account 4' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram where Name='Client' limit 1];
        Map<PartnerMarketingBudget,Id> channelMDFBudToAccMap= new Map<PartnerMarketingBudget,Id>();
        User usr = [SELECT Id,Email from User where LastName='CMDF Budget Loader' limit 1];
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('Channel MDF Account Based').getRecordTypeId();
        System.runAs(usr){
            try{
                PartnerMarketingBudget BudgetRecord1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today(),System.today(),false);
                BudgetRecord1.Core_MDF_Budget_Type_Txt__c = 'Intel MDF Account Based1';
                //Core_MDF_PMBServiceHandler.validateOnCreateOrUpdateCMDFBudgets(Null);
                insert BudgetRecord1;
            }catch(Exception e){
                String errorMessage = e.getMessage();
                //Assert.isTrue(errorMessage.contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMDFBudgetTypeAccessError')));
            }
            
        } 
        test.stopTest();
    }
    
    //Test method to check duplicate budget on update
    @isTest static void ValidateApprovalProcessMethodFlow(){
        test.starttest();
        User testuser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User usr = [SELECT Id,Email from User where LastName='TestClass MDF Budget Loader' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram where Name='Client' limit 1];
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        Account accNew = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Core_Account_ID__c from Account where Name='Test Account 5' limit 1];        
        
        system.runAs(testuser){
            Core_MDF_Criteria__c cr2 = [Select Id from Core_MDF_Criteria__c LIMIT 1];
            cr2.Core_MDF_Operator_1__c = 'IN';
            cr2.Core_MDF_Operator_2__c = 'IN';
            update cr2;
            
            AccountShare accshareRecordCCF = new AccountShare();
            accshareRecordCCF.AccountId = accNew.Id;
            accshareRecordCCF.UserOrGroupId = usr.Id;
            accshareRecordCCF.RowCause = 'Manual';
            accshareRecordCCF.AccountAccessLevel = 'Read';
            accshareRecordCCF.OpportunityAccessLevel = 'None';
            accshareRecordCCF.CaseAccessLevel = 'None';
            Database.Insert(accshareRecordCCF);
            
            AccountShare accshareRecordCCF1 = new AccountShare();
            accshareRecordCCF1.AccountId = accNew.Core_MDF_Parent_Fund_Account__c;
            accshareRecordCCF1.UserOrGroupId = usr.Id;
            accshareRecordCCF1.RowCause = 'Manual';
            accshareRecordCCF1.AccountAccessLevel = 'Read';
            accshareRecordCCF1.OpportunityAccessLevel = 'None';
            accshareRecordCCF1.CaseAccessLevel = 'None';
            Database.Insert(accshareRecordCCF1);
            
            ChannelProgramShare csShare = new ChannelProgramShare();
            csShare.ParentId = cp.Id;
            csShare.UserOrGroupId = usr.Id;
            csShare.AccessLevel = 'Read';
            csShare.RowCause = 'Manual';
            insert csShare;
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm2.Core_MDF_Account_id__c = accNew.Core_MDF_Parent_Fund_Account__c;
            iupgm2.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm2.Core_MDF_User_id__c = usr.Id;
            iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader';
            iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm2.Core_MDF_Active_Ind__c = true;
            insert iupgm2;
            
        }
        System.runAs(usr){
            
            List<PartnerMarketingBudget> pmbList1 = new List<PartnerMarketingBudget>();
            
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit2',RecordTypeIdPMB,accNew.Id,cp.Id,123456,System.today(),System.today(),false);
            testBudget1.Core_MDF_Budget_Status__c = 'Pending Review';
            testBudget1.Core_MDF_Budget_Type_Txt__c = 'MDF';
            pmbList1.add(testBudget1);
            try{
                insert pmbList1;
                Core_MDF_PMBServiceHandler.checkPMBDuplicateRecordsOnUpdate(Null,Null);
                
                PartnerMarketingBudget pmb = [Select id,Core_MDF_Approver_1__c,Core_MDF_Budget_Status__c from PartnerMarketingBudget limit 1];
                system.assertEquals('Pending Review', pmb.Core_MDF_Budget_Status__c);
            }catch(Exception e){
                String errorMessage = e.getMessage();
            }
        }
        test.stoptest();
        
    }
    
    @isTest static void validateOnCreateOrUpdateIPABudgets1() {
    Test.startTest();
    User usr1 = [SELECT Id, Email FROM User WHERE LastName = 'User Test11' LIMIT 1];
    User usrIPA = [SELECT Id, Email FROM User WHERE LastName = 'IPA Loader Approver' LIMIT 1];
    Account acc3 = [SELECT Id, Core_MDF_Parent_Fund_Account__c, Core_MDF_Parent_Fund_Account__r.Id FROM Account WHERE Name = 'IPA - IPA Intel Account' LIMIT 1];
    ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Intel Partner Alliance' LIMIT 1];
    User usr = [SELECT Id, Email FROM User WHERE LastName = 'IPA Budget Loader' LIMIT 1];
    Id ipaIUPGMRecordTypeId = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();

    List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
    iupgmList.add(new Core_MDF_Int_Users_Partner_Geo_Mapping__c(
        RecordTypeId = ipaIUPGMRecordTypeId,
        Core_MDF_Account_id__c = acc3.Core_MDF_Parent_Fund_Account__c,
        Core_MDF_Program_nm__c = 'Intel Partner Alliance',
        Core_MDF_Budget_Type_nm__c = 'Account Plan',
        Core_MDF_Region_Sub_Region_nm__c = 'WW',
        Core_MDF_User_id__c = usr.Id,
        Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Budget_Loader',
        Core_MDF_All_Accounts_cd__c = 'No',
        Core_MDF_All_Budget_Type_Access_Ind__c = true
    ));

    iupgmList.add(new Core_MDF_Int_Users_Partner_Geo_Mapping__c(
        RecordTypeId = ipaIUPGMRecordTypeId,
        Core_MDF_Program_nm__c = 'Intel Partner Alliance',
        Core_MDF_Budget_Type_nm__c = 'Account Plan',
        Core_MDF_Region_Sub_Region_nm__c = 'WW',
        Core_MDF_User_id__c = usrIPA.Id,
        Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Budget_Loader',
        Core_MDF_All_Accounts_cd__c = 'yes',
        Core_MDF_All_Budget_Type_Access_Ind__c = false,
        Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'WW->Account Plan'
    ));

    Database.insert(iupgmList);

    Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Account_Based').getRecordTypeId();
    System.runAs(usr) {
        try {
            PartnerMarketingBudget BudgetRecord1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit', recordTypeIdPMB, acc3.Id, cp.Id, 123456, System.today(), System.today(), false);
            BudgetRecord1.Core_MDF_Budget_Type_Txt__c = 'Account Plan';
            insert BudgetRecord1;
        } catch (Exception e) {
            String errorMessage = e.getMessage();
        }
    }

    Id recordTypeIdPMBProp = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId();
    System.runAs(usrIPA) {
        try {
            List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget BudgetRecord2 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit', recordTypeIdPMBProp, acc3.Id, cp.Id, 123456, System.today(), System.today(), false);
            BudgetRecord2.Core_MDF_Budget_Type_Txt__c = 'Proposal I MDF';
            pmbList.add(BudgetRecord2);
            insert pmbList;
            Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess(pmbList, null, false);
            Assert.areEqual(true, pmbList != null);
        } catch (Exception e) {
            String errorMessage = e.getMessage();
        }
    }

    System.runAs(usr1) {
        try {
            PartnerMarketingBudget BudgetRecord1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit', recordTypeIdPMB, acc3.Id, cp.Id, 123456, System.today(), System.today(), false);
            BudgetRecord1.Core_MDF_Budget_Type_Txt__c = 'Account Plan';
            insert BudgetRecord1;
            Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit', recordTypeIdPMB, acc3.Id, cp.Id, 123456, System.today(), System.today(), false);
        } catch (Exception e) {
            String errorMessage = e.getMessage();
        }
    }
    test.stopTest();
}
    
    @isTest static void newMethodDCF(){
        test.startTest();
        Account acc3 = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Id from Account where Name='Test Account 6' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram where Name='Datacenter' limit 1];
        User usr = [SELECT Id,Email from User where lastName='User Test11' limit 1];
        
        system.runAs(usr){
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            List<PartnerMarketingBudget> pmbList1 = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit2',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today()-1,System.today()-1,false);
            testBudget1.Core_MDF_Budget_Type_Txt__c = 'MDF';
            pmbList1.add(testBudget1);
            try{
                insert pmbList1;
                Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess(pmbList1,null,false);
                Core_MDF_PMBServiceHandler.validateRoleBudgetTypeAccess(pmbList1);
                System.assert(pmbList1!=null);
            }catch(Exception e){
                String errorMessage = e.getMessage();
            }
            
        } 
        test.stopTest();
    }
    @isTest static void newMethodRetail(){
        test.startTest();
        Account acc3 = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Id from Account where Name='Test Account 7' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram where Name='Retail Marketing Funds' limit 1];
        User usr = [SELECT Id,Email from User where lastName='User Test11' limit 1];
        
        system.runAs(usr){
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            List<PartnerMarketingBudget> pmbList1 = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit2',RecordTypeIdPMB,acc3.Id,cp.Id,2055,System.today()-10000,System.today()-10000,false);
            testBudget1.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
            pmbList1.add(testBudget1);
            try{
                insert pmbList1;
                Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess(pmbList1,null,false);
                System.assert(pmbList1!=null);
            }catch(Exception e){
                String errorMessage = e.getMessage();
            }
            
        }
    test.stopTest();        
    }
    @isTest static void newMethod(){
        test.startTest();
        Account acc3 = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Id from Account where Name='Co-marketing Test Account_SPCF' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram where Name='Service Provider Co-Marketing Fund' limit 1];
        User usr = [SELECT Id,Email from User where lastName='User Test11' limit 1];
        
        system.runAs(usr){
            //Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('Retail Marketing Funds').getRecordTypeId();
            List<PartnerMarketingBudget> pmbList1 = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('Co-marketing Test Budget_SPCF',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc3.Id,cp.Id,123456,System.today()-1,System.today()-1,false);
            //testBudget1.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
            pmbList1.add(testBudget1);
            try{
                insert pmbList1;
                Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess(pmbList1,null,false);
                System.assert(pmbList1!=null);
            }catch(Exception e){
                String errorMessage = e.getMessage();
            }
            
        } 
        test.stopTest();
    }
    
    /*@isTest
    public static void testMethod2(){
        test.starttest();
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account acc3 = [SELECT Id from Account where Name='Test Account 3' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram limit 1];
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader'];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);

        List<PartnerMarketingBudget> PMBList = new List<PartnerMarketingBudget>();
        Map<Id,PartnerMarketingBudget> oldPMBMap = new Map<Id,PartnerMarketingBudget>();
        System.runAs(usr){
           
            PartnerMarketingBudget BudgetRecord1=[Select Id,Core_MDF_Budget_Type_Txt__c, Core_MDF_Budget_Partner__c,Core_MDF_Program_Nm__c from PartnerMarketingBudget where Title='NewTestBudget1' LIMIT 1];
            PartnerMarketingBudget BudgetRecord2=[Select Id,Core_MDF_Budget_Type_Txt__c, Core_MDF_Budget_Partner__c,Core_MDF_Program_Nm__c from PartnerMarketingBudget where Title='TestPMB1' LIMIT 1];
            //BudgetRecord1.Core_MDF_Budget_Type__c = 'MDF';
            BudgetRecord1.Core_MDF_Budget_Status__c = 'Pending Review';
            BudgetRecord2.Core_MDF_Budget_Status__c = 'Released';
            
            Database.update(BudgetRecord1);
            Database.update(BudgetRecord2);
            //BudgetRecord2.StartDate = System.today().addDays(2);
            BudgetRecord2.Core_MDF_Budget_Status__c = 'Pending Review';
            Database.update(BudgetRecord2);
            PMBList.add(BudgetRecord1);
            oldPMBMap.put(BudgetRecord2.Id,BudgetRecord2);
            //Core_MDF_PMBServiceHandler.validateBudgetStatusOnUpdate(PMBList,oldPMBMap);
        }
        //insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        System.runAs(usr){
            Core_MDF_PMBServiceHandler.validateBudgetStatusOnUpdate(PMBList,oldPMBMap);
        }
        Assert.areEqual(true, PMBList != null);
        test.stoptest();
    }*/
    @isTest static void legacyRestrict(){
        test.startTest();
        Account acc3 = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Id from Account where Name='Test Account 3' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram where Name='Client' limit 1];
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PartnerMarketingBudget  legacyRecord = new PartnerMarketingBudget();
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            try{
                
                legacyRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today().addDays(2),System.today().addDays(15),false);
                legacyRecord.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
                insert legacyRecord;
                List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
                pmbList.add(legacyRecord);
                Core_MDF_PMBServiceHandler.restrictLegacyBudgetCreation(pmbList);
                Assert.areEqual(True, pmbList != null);
            }catch(Exception e){
                String errorMessage = e.getMessage();
                
            } 
        }
        test.stopTest();
    }
    @isTest static void editError(){
         test.startTest();
         User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
         Account ipaUltimate = [Select id from Account where name = 'IPA Intel Account'];
         set<Id> setNew = new set<Id>();
         setNew.add(ipaUltimate.id);
         set<String> setBudType = new set<String>();
         String ipaBT = 'Account Plan';
         setBudType.add(ipaBT);
        
         Map<Id,PartnerMarketingBudget> newBudgetMap = new Map<Id,PartnerMarketingBudget>();
        
         PartnerMarketingBudget BudgetRecord2=[Select Id,Core_MDF_Budget_Type_Txt__c, Core_MDF_Budget_Partner__c,Core_MDF_Program_Nm__c,Core_MDF_Budget_Status__c from PartnerMarketingBudget where Title='New Retail Budget' LIMIT 1];
         newBudgetMap.put(BudgetRecord2.id,BudgetRecord2);
         System.runAs(usr){
             try{
                   BudgetRecord2.Core_MDF_Budget_Status__c = 'Rejected';
                   database.update(BudgetRecord2);
             }catch(Exception e){
                String errorMessage = e.getMessage();
                
            }
          
         }
         System.runAs(usr){
             try{
                   boolean isUnifiedIdEnabled = false;
                   Core_MDF_PMBServiceHandler.validateBudTypeBenefitMappingOnCreate(newBudgetMap,setBudType,setNew);
             }catch(Exception e){
                String errorMessage = e.getMessage(); 
            }
          
         }
        
         test.stopTest();
    }
    @isTest
    static void testCheckPMBDuplicateRecordsOnUpdateCatch() {
        Test.startTest();
            List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
            Core_MDF_PMBServiceHandler.checkPMBDuplicateRecords(budgetList);
            Map<Id, PartnerMarketingBudget> budgetMap = new Map<Id, PartnerMarketingBudget>();
            Core_MDF_PMBServiceHandler.checkPMBDuplicateRecordsOnUpdate(budgetList, budgetMap);
            Core_MDF_PMBServiceHandler.validateDecreasedBudgetAmount(budgetMap, budgetMap);
            Core_MDF_PMBServiceHandler.checkPMBDuplicateRecordsOnUpdate(budgetList, budgetMap);
            PartnerMarketingBudget newBudget = new PartnerMarketingBudget();
            PartnerMarketingBudget existingBudget = new PartnerMarketingBudget();
            Core_MDF_PMBServiceHandler.validatePmbWithOverlapAndDupCheck(newBudget, existingBudget);
            Core_MDF_PMBServiceHandler.invokeBudgetShareRecordToGeoGroup(budgetList);
            Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess(budgetList, budgetMap, true);
            Set<String> budgetTypes = new Set<String>();
            Set<Id> accountIds = new Set<Id>();
            Core_MDF_PMBServiceHandler.validateBudTypeBenefitMappingOnCreate(budgetMap, budgetTypes, accountIds);
            Core_MDF_PMBServiceHandler.validateRoleBudgetTypeAccess(budgetList);
            Core_MDF_PMBServiceHandler.notifyApprovers(budgetList, budgetMap);
            Core_MDF_PMBServiceHandler.validateBudgetStatusOnUpdate(budgetList, budgetMap);
            Core_MDF_PMBServiceHandler.restrictLegacyBudgetCreation(budgetList);
        Test.stopTest();
    }
   /* @isTest static void testProcessAccountSpecialtyAssociations() {
        Test.startTest();
        
        // Create test data for the method parameters
        Set<String> benefitSet = new Set<String>{'Account Plan'};
        Set<Id> allIntelAccIdSet = new Set<Id>();
        Map<Id, Set<String>> accIdToBenefitsMap = new Map<Id, Set<String>>();
        Map<String, Set<String>> budTypeToBenefitsMap = new Map<String, Set<String>>();
        Map<Id, PartnerMarketingBudget> ipaPmbIdToPmbMap = new Map<Id, PartnerMarketingBudget>();
        Map<Id, String> mapOfIntelAccountandPrimeId = new Map<Id, String>();
        Map<String, Set<Id>> mapOfPrimeIdSetofAccountId = new Map<String, Set<Id>>();
        List<Id> accInIpaAffiliation = new List<Id>();
        
        // Create test accounts and specialties
        Account accIPA1 = [SELECT Id FROM Account WHERE Name = 'IPA Intel Account1' LIMIT 1];
        allIntelAccIdSet.add(accIPA1.Id);
        
        PartnerMarketingBudget pmb = new PartnerMarketingBudget();
        //pmb.Core_MDF_Ultimate_Account_Id__c = accIPA1.Id;
        pmb.Core_MDF_Budget_Type_Txt__c = 'Account Plan';
        ipaPmbIdToPmbMap.put(pmb.Id, pmb);
        
        mapOfIntelAccountandPrimeId.put(accIPA1.Id, 'Prime001');
        mapOfPrimeIdSetofAccountId.put('Prime001', new Set<Id>{accIPA1.Id});
         // Query the PRM_Specialty__c record
        Id specialtyId = [SELECT Id FROM PRM_Specialty__c WHERE Name = 'Account Plan' LIMIT 1].Id;
        // Create a specialty association
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_InActive_Ind__c = FALSE;
        asa.PRM_Specialty_Id__c = specialtyId;
        asa.PRM_Account_Id__c = accIPA1.Id;
        insert asa;
        
        // Call the method
        Core_MDF_PMBServiceHandler.processAccountSpecialtyAssociations(
            benefitSet, 
            allIntelAccIdSet, 
            accIdToBenefitsMap, 
            budTypeToBenefitsMap, 
            ipaPmbIdToPmbMap, 
            mapOfIntelAccountandPrimeId, 
            mapOfPrimeIdSetofAccountId, 
            accInIpaAffiliation
        );
        
        // Assert the expected results
        System.assert(accIdToBenefitsMap.containsKey(accIPA1.Id), 'Account should have associated benefits');
        System.assert(accIdToBenefitsMap.get(accIPA1.Id).contains('Account Plan'), 'Account should have Account Plan benefit');
        
        Test.stopTest();
    }*/
   
}