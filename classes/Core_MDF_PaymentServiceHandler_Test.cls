/****************************************************************************************************************************************
* Class Name  : Core_MDF_PaymentServiceHandler_Test
* Version     : 1.0 
* Created Date: 02-05-2019
* Modification Log :
* Developer           HA          Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hamza Akhtar                   02-05-2019                    Test class for Core_MDF_PaymentServiceHandler class
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_PaymentServiceHandler_Test {
    
    //Method for creating activity, claim and bank for associating it to a payment record
    @TestSetUp
    static void creatingPaymentRecords() {
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        Map<String,Id> profileToId = new Map<String,Id>();
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','Partner','CCP - Core Access')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_APJ_User',
                            'Core_MDF_CCP_Internal_Payment_Schedule_Admin',
                            'Core_MDF_CCP_Internal_Retail_Payment_Adm',
                             'Core_MDF_CCP_Internal_CCF_Payment_Adm',
                             'Core_MDF_CCP_External_Account_Budget_Administrator',
                             'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager',
                             'View_All_Data')]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
        
        PermissionSet paymentScheduleAdm = nameToPerSet.get('Core_MDF_CCP_Internal_Payment_Schedule_Admin'); 
        PermissionSet apjUser = nameToPerSet.get('Core_MDF_CCP_Internal_APJ_User'); 
        PermissionSet retailpaymentAdm = nameToPerSet.get('Core_MDF_CCP_Internal_Retail_Payment_Adm'); 
        PermissionSet ccfpaymentAdm = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_Payment_Adm'); 
        PermissionSet accbudAdmin = nameToPerSet.get('Core_MDF_CCP_External_Account_Budget_Administrator'); 
        PermissionSet claimcaseRev = nameToPerSet.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'); 
        PermissionSet viewAllData = nameToPerSet.get('View_All_Data'); 
        List<User> usrList = new List<User>();
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        usrList.add(usr);
        
        User payAdm = Core_MDF_CCP_TestDataUtility.createUser(false);
        payAdm.Email='testexmpl2@intel.com';
        payAdm.profileId=profileToId.get('CCP - Core Access');
        payAdm.UserPermissionsMarketingUser=true;
        payAdm.isActive=true;
        usrList.add(payAdm);
        
        Database.insert(usrList);
        
        List<PermissionSetAssignment> permSetAssgnmntList = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = payAdm.Id;
        assignPermissionSetObj.PermissionSetId = ccfpaymentAdm.Id;
        permSetAssgnmntList.add(assignPermissionSetObj);
        
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = payAdm.Id;
        assignPermissionSetObj1.PermissionSetId = retailpaymentAdm.Id;
        permSetAssgnmntList.add(assignPermissionSetObj1);
        
        
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = payAdm.Id;
        assignPermissionSetObj2.PermissionSetId = paymentScheduleAdm.Id;
        permSetAssgnmntList.add(assignPermissionSetObj2);
        
        
        PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
        assignPermissionSetObj3.AssigneeId = payAdm.Id;
        assignPermissionSetObj3.PermissionSetId = apjUser.Id;
        permSetAssgnmntList.add(assignPermissionSetObj3);
        
        
        PermissionSetAssignment assignPermissionSetObj4 = new PermissionSetAssignment();
        assignPermissionSetObj4.AssigneeId = payAdm.Id;
        assignPermissionSetObj4.PermissionSetId = claimcaseRev.Id;
        permSetAssgnmntList.add(assignPermissionSetObj4);
        
        permissionSetAssignment assignPermissionSetObj5 = new PermissionSetAssignment();
        assignPermissionSetObj5.AssigneeId = payAdm.Id;
        assignPermissionSetObj5.PermissionSetId = viewAllData.Id;
        permSetAssgnmntList.add(assignPermissionSetObj5);       

        
        System.runAs(usr) {
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
    bypassFunctionKeys.add('Bypass_Delete_Sharing_Records');
        bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
        bypassFunctionKeys.add('Bypass_Allocation_Reservation');
        bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
        bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
        bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');        
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
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
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Bypass_UpdateActivityFields');
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
        bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
        bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
        bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
        bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
        bypassFunctionKeys.add('Bypass_ShareActivityWithExternalUsers');
        bypassFunctionKeys.add('Bypass_geoLeadApprovalProcess');              
        bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
        bypassFunctionKeys.add('Bypass_Queued_Hold_Email');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Creation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_update');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        }  
        
        System.runAs(usr) {
            Database.insert(permSetAssgnmntList);
            Core_Trigger_Executions__c triggerActive = new Core_Trigger_Executions__c();
            triggerActive.NAME = 'processInboundMessagesERPM';
            triggerActive.Core_Active__c = TRUE;
            triggerActive.Core_Class_Name__c = 'Core_IntegrationInboundMessageHandler';
            triggerActive.Core_Description__c = 'Process inbound ERPM messages from iPaaS';
            triggerActive.Core_Object__c = 'Core_Integration_Inbound_Message__c';
            triggerActive.Core_Trigger_Events__c = 'after insert, after update';
            insert triggerActive;
            
            //Commented for ATHR fix - WW16  
            /*List<Core_MDF_CCP_EmailContentTranslationMap__mdt> metaData = [SELECT Id, Core_MDF_MailSubject__c, Core_MDF_MailBody1__c, 
                                                                           Core_MDF_MailBody2__c,Core_MDF_MailBody3__c, Core_MDF_MailBody4__c, 
                                                                           Core_MDF_MailBody5__c, Core_MDF_MailBody6__c,  Core_MDF_MailBody7__c,
                                                                           Core_MDF_MailFooter1__c, Core_MDF_MailFooter2__c, Core_MDF_MailFooter3__c, 
                                                                           Core_MDF_MailFooter4__c, Core_MDF_MailFooter5__c, Core_MDF_Program__c,  
                                                                           Core_MDF_MailBody8__c,Core_MDF_MailBody9__c, Core_MDF_LocaleKey__c,
                                                                           Core_MDF_Translated_Program__c,Core_MDF_MailBody8_1__c
                                                                           FROM   Core_MDF_CCP_EmailContentTranslationMap__mdt];*/
            //Test.startTest();
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', false); 
            cpList.add(cp);
            cpList.add(cp1);
            Database.insert(cpList);
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Geo__c='APJ';
            insert acc1;
            List<Account> accList =new List<Account>();
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
            accList.add(acc2);
            Account retailAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Retail Acc', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
            retailAcc.Core_Geo__c='APJ';
            accList.add(retailAcc);           
            Database.insert(accList);
            List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,10000,System.today() -5,System.today(), false);
            budget.Core_MDF_Budget_Type_Txt__c='MDF';
            pmbList.add(budget);
            PartnerMarketingBudget  pmbRecord1 = Core_MDF_CCP_TestDataUtility.createRetailBudget('RSABudget',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,retailAcc.Id,cp1.Id,1000000,System.today().addDays(-15),System.today().addDays(15),false, 'RSA MD');
            pmbRecord1.Core_MDF_Budget_Type_Txt__c='RSA MD';
            pmbRecord1.IsIgnoreValidation = true;
            pmbList.add(pmbRecord1);           
            Database.insert(pmbList);
            Id contactRecordTypeIntel = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId();
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
            conRecord1.RecordTypeId = contactRecordTypeIntel;
            insert conRecord1;
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
            usr1.Email='test1@example.com';
            usr1.ContactId = conRecord1.Id;
            usr1.ProfileId = profileToId.get('Partner');
            usr1.isActive = true;
            Database.insert(usr1);
            
            List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
            Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
            agsRoleList.add(agsRoleCCF);
            Core_AGS_Role__c agsRoleCCF_ABA = Core_MDF_CCP_TestDataUtility.createAgsRole('CCP_CCF_External_Account Budget Administrator', 'Co-Marketing(Salesforce)-External Account Budget Administrator-CCF', true, false);
            agsRoleList.add(agsRoleCCF_ABA);
            Database.insert(agsRoleList);
            
            List<Core_ERPM_Engagement__c> erpmEngagementList = new List<Core_ERPM_Engagement__c>();
            Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
            erpmEngagementList.add(erpmEngagementCCF);
            Database.insert(erpmEngagementList);
            
            List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();
            Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',agsRoleCCF.Id ,'Intel® Partner Investment Center','CCF User',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
            entitlementList.add(entitlementCCF);
            Core_Entitlement__c entitlementCCF_ABA= Core_MDF_CCP_TestDataUtility.createEntitlement('Client Account Budget Administrator',agsRoleCCF_ABA.Id ,'Intel® Partner Investment Center','CCF Account Budget Administrator',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
            entitlementList.add(entitlementCCF_ABA);
            Database.insert(entitlementList);
            
            List<Core_Contact_Entitlement__c> contactEntitlementList = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
            contactEntitlementList.add(contactEntitlementCCF);
            Core_Contact_Entitlement__c contactEntitlementCCFABA = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF_ABA.Id ,true,'Complete', false);
            contactEntitlementList.add(contactEntitlementCCFABA);
            Database.insert(contactEntitlementList);
            
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = accbudAdmin.Id, AssigneeId = usr1.Id);
            permissionSetAssignmentList.add(psa1);
            insert permissionSetAssignmentList;
            
    
            Core_MDF_Configuration__c c=new Core_MDF_Configuration__c();
            c.Name='Core_MDF_RecoveryClaimUpdateBatch_Size';
            c.Core_MDF_Value__c='30';
            insert c;
            
            // Creating Groups for PGM
            Group grp = new Group();
            grp.name = 'PGM_TEST';
            //Test.startTest();
            insert grp;

            Group grp1 = new Group();
            grp1.name = 'PGM_TEST_Group2';
            //Test.startTest();
            insert grp1;


            List<GroupMember> gmList = new List<GroupMember>();
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = usr1.Id;
            gmList.add(gm);
            Database.insert(gmList);
            
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = acc1.Id;
            pgm.Core_MDF_Group_Name__c = 'PGM_TEST_Group2';
            pgm.Core_MDF_Type_of_Access__c = 'Internal';
            pgm.Core_MDF_Group_Id__c = grp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_Region_cd__c='WW';
            pgm.Core_MDF_Source_Txt__c = 'test';
            pgm.Core_MDF_AccountIdGroupName__c = acc2.Id+'PGM_TEST_Group2';
            Database.insert(pgm);
           // Highlight: Unused Local Variable - Indira
           // Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id,usr1.Id, true);
            
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,1000,false);
            
            PartnerFundAllocation rsaMdAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('RSAMDalloc',pmbRecord1,retailAcc,20000.0,false);
            pfaList.add(allocation);
            pfaList.add(rsaMdAlloc);
            database.insert(pfaList);
            List<Campaign> campaignList = new List<Campaign>();
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(200), 2000, 'Always Connected PC', acc2.Id,'Desktop', false); 
            camp.Core_MDF_Opal_Budget_Type_Txt__c ='OEM CMP';
            campaignList.add(camp);
            Campaign rsaMDCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm2','Gaming','9ᵗʰ Gen', 'No', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-10), System.today().addDays(10), 100000, 'Instore innovation', retailAcc.Id,'Desktop', false); 
            rsaMDCamp.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            rsaMDCamp.Core_MDF_Activity_Category_Type__c =null;
            rsaMDCamp.Core_MDF_Reimbursement_Rate__c='100%';
            rsaMDCamp.Core_MDF_Technology__c = 'Intel vPro®';
            campaignList.add(rsaMDCamp);
            
            Database.insert(campaignList);
            
            Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
           // Highlight: Unused Local Variable - Indira
           // Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank1.Id, true);
        //    Test.stopTest();
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            PartnerFundRequest indiaActivity5 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(rsaMDCamp.Id),string.valueof(retailAcc.id),
                                System.today().addDays(-4),System.today().addDays(4),false);
            indiaActivity5.Title = 'indiaActivity5';
            indiaActivity5.Core_MDF_Budget_Type_nm__c='Retail MDF';
            indiaActivity5.Core_MDF_Country_nm__c = 'INDIA';
            indiaActivity5.Core_MDF_Reimbursement_Rate_pct__c = '100%';
            indiaActivity5.Core_MDF_Reimbursement_Rate_txt__c='100%';
      indiaActivity5.RequestedAmount =1000;
            indiaActivity5.Amount=1000;
            indiaActivity5.Status = 'Approved';
            indiaActivity5.AllocationId=rsaMdAlloc.id;
            indiaActivity5.Core_MDF_ActivityCategory__c = 'Broadcast (Pre-2025)';
            indiaActivity5.Core_MDF_Activity_Types__c = 'Podcast';
            
            pfrList.add(indiaActivity5);
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           String.valueof(acc2.id),allocation,null,'INDIA',
                                                                                           'Consumer',
                                                                                           'Desktop',
                                                                                           'Intel® Core™ i7 Processor',
                                                                                           'Broadcast (Pre-2025)',
                                                                                           'Podcast',
                                                                                           'Draft',
                                                                                           false);
            pfr.Core_MDF_Start_Date__c = system.today().addDays(-5);
            pfr.Core_MDF_End_Date__c  = system.today();
            pfr.Core_MDF_Budget_Type_nm__c  = 'OEM CMP';
            pfr.Amount = 0;
            pfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
            pfrList.add(pfr);
            Test.startTest();
            Database.insert(pfrList);
            Test.stopTest();
              
            //Test.stopTest();
            //insert pfr;
                      
            List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
            Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
            record2.Name= 'INR';
            record2.Core_MDF_Exchange_Rate__c = 1;
            record2.Core_MDF_Market_Date__c =System.today();
            record2.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            record2.Core_MDF_Unique_Key__c = 'INR'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            newValues.add(record2);
            
            Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
            record3.Name= 'USD';
            record3.Core_MDF_Exchange_Rate__c = 1;
            record3.Core_MDF_Market_Date__c =System.today();
            record3.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            record3.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            newValues.add(record3);
            database.insert(newValues);
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            
           
        }
    }
    
    //Method for bulk testing the payment and claim
    
    @isTest
    static void bulkTesting() {
        PartnerFundRequest pfr = [SELECT Id FROM PartnerFundRequest Where Title ='test'];
        Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c Where Name = 'Test'];
        User usr1 = [Select id from User where Email='testexmpl2@intel.com' LIMIT 1];
        
         list<PartnerFundClaim> claimList = new list<PartnerFundClaim>();
            for(integer i=1; i<=4; i++) {
                PartnerFundClaim newClaim = new PartnerFundClaim();
                newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                    Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                    System.today().addDays(-2), System.today().addDays(-2), 122, 
                                                                    System.today(), bank1.Id, false);
                newClaim.Core_MDF_Currency__c = 'USD';
                newClaim.Core_MDF_Type_Txt__c = 'Claim';
                newClaim.Core_MDF_Taxes_Local__c = 0;
                newClaim.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
                newClaim.Core_MDF_Type_Txt__c = System.Label.Core_MDF_Claim_Type;
                claimList.add(newClaim);
            }
          
          test.startTest();
            insert claimList;
             
        //System.runAs(usr1){
            List<PartnerFundClaim> updatedClaimList = [SELECT Id, Core_MDF_Payment_Id__c, Core_MDF_Status__c, Status FROM PartnerFundClaim LIMIT 2];
       
            List<PartnerFundClaimShare> claimShare = new List<PartnerFundClaimShare>();
            PartnerFundClaimShare pfcShare1=new PartnerFundClaimShare(AccessLevel='Edit',ParentId=updatedClaimList[0].id,RowCause='Manual',UserOrGroupId=usr1.Id);
            PartnerFundClaimShare pfcShare2=new PartnerFundClaimShare(AccessLevel='Edit',ParentId=updatedClaimList[1].id,RowCause='Manual',UserOrGroupId=usr1.Id);
            claimShare.add(pfcShare1);
            claimShare.add(pfcShare2);
            insert claimShare;
            System.runAs(usr1) {
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            payRunRecord.Core_MDF_Program_Txt__c  ='Client CoMarketing Fund';
            payRunRecord.Core_MDF_Budget_Type_nm__c  ='CCF 1.0';
            payRunRecord.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Client_Co_Marketing_Fund_CMP').getRecordTypeId();
            Database.insert(payRunRecord);
            
            Id ccfRecordTypeId = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
            List<Core_MDF_Payment__c> paymentList = new List<Core_MDF_Payment__c>();
            Core_MDF_Payment__c newPayment = new Core_MDF_Payment__c();
            newPayment.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
            newPayment.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
            newPayment.RecordTypeId = ccfRecordTypeId;
            //insert newPayment;
            paymentList.add(newPayment);
            Core_MDF_Payment__c newPayment1 = new Core_MDF_Payment__c();
            newPayment1.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
            newPayment1.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
            newPayment1.RecordTypeId = ccfRecordTypeId;
            //insert newPayment1;
            paymentList.add(newPayment1);
            Database.insert(paymentList);
            /*Map<Id,String> payMap = new Map<Id,String>();
            payMap.put(newPayment1.Id,'1009100025583');
            Core_MDF_Payment_ServiceHandler.populateEFTNbrOnClaims(payMap);*/
                
      Id paidRecordTypeId = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
           Core_MDF_Payment__c oldPayment = new Core_MDF_Payment__c(Core_MDF_Payment_Status_Txt__c = 'Pending Payment', RecordTypeId = paidRecordTypeId, Core_MDF_Budget_Type_Nm__c = Label.Core_MDF_Retail_RSA_MD_Budget_Type);
            insert oldPayment;
            oldPayment.Core_MDF_Payment_Status_Txt__c = Label.Core_MDF_Status_Paid;
            oldPayment.Core_MDF_EFT_Nbr__c = 'EFT123456';
            update oldPayment;
            Map<Id, Core_MDF_Payment__c> oldPaymentMap = new Map<Id, Core_MDF_Payment__c>{oldPayment.Id => oldPayment};
            List<Core_MDF_Payment__c> newPayments = [SELECT Id, Core_MDF_Payment_Status_Txt__c, Core_MDF_EFT_Nbr__c, RecordTypeId, Core_MDF_Program_Txt__c, Core_MDF_Budget_Type_Nm__c FROM Core_MDF_Payment__c WHERE Id = :oldPayment.Id];
            Core_MDF_Payment_ServiceHandler.populatePaymentMap(newPayments, oldPaymentMap);

            Core_MDF_Payment_ServiceHandler.updateEFTNbrOnClaims(updatedClaimList);
            Integer count = 0;
            List<PartnerFundClaim> paymentDueClaimList = new list<PartnerFundClaim>();
            for(PartnerFundClaim pfc : updatedClaimList) {
                count++;
                pfc.Core_MDF_Status__c = 'Pending Payment';
                pfc.Core_MDF_Payment_Id__c = newPayment.Id;
                if(count > 1) {
                    pfc.Core_MDF_Payment_Id__c = newPayment1.Id;
                }
                paymentDueClaimList.add(pfc);
            }
            if(paymentDueClaimList.size() > 0) {
                update paymentDueClaimList;
            }        
                  List<PartnerFundClaim> linkedClaims = [SELECT Id, Core_MDF_Payment_Id__c FROM PartnerFundClaim WHERE Core_MDF_Payment_Id__c != null];
            Map<Id, String> payMap = new Map<Id, String>();
            for (PartnerFundClaim c : linkedClaims) {
                payMap.put(c.Core_MDF_Payment_Id__c, '1009100025583');
            }
      Core_MDF_Payment_ServiceHandler.populateEFTNbrOnClaims(payMap);
        }

        List<Core_MDF_Payment__c> pendingPayment = [SELECT Core_MDF_Payment_Made_Dt__c, Core_MDF_Payment_Status_Txt__c, Core_MDF_Payment_No_Txt__c
                                                    FROM Core_MDF_Payment__c
                                                    WHERE Core_MDF_Payment_Status_Txt__c = 'Pending Payment' LIMIT 50];
        String constructingPayload = '[';
        for(integer index=0; index < pendingPayment.size(); index++) {
            constructingPayload +=  '{"Core_MDF_Payment_No_Txt": "' + pendingPayment[index].Core_MDF_Payment_No_Txt__c + 
                '","Core_MDF_EFT_Nbr": "ABCD123123","Core_MDF_Payment_Made_Dt": "31-Jan-2019",' +
                '"Core_MDF_Payment_Status_Txt": "PAID"},';
        }
        String payload = constructingPayload.removeEnd(',') + ']';
        
      //  test.startTest();
        
        Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
        iim.Core_Payload__c = payload;
        iim.Core_Message_Type__c = 'Payment';
        iim.Core_Source_System__c = 'EDW';
        try {
        insert iim;
        }catch(Exception e) { 
        }
        
        List<PartnerFundClaim> paidFundClaims = [SELECT Id, Core_MDF_Status__c, Status, Core_MDF_Payment_Id__c
                                                 FROM PartnerFundClaim
                                                 LIMIT 50];
        
        System.assert(paidFundClaims[0].Id != NULL);
        test.stopTest();
    }
    
    //covering the invocable method
    @isTest
    static void coverInvocableMethod() {
       
        PartnerFundRequest pfr = [SELECT Id FROM PartnerFundRequest Where Title ='test'];
        Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c Where Name = 'Test'];
        User usr1 = [Select id from User where Email='testexmpl2@intel.com' LIMIT 1];
        list<PartnerFundClaim> claimList = new list<PartnerFundClaim>();
        for(integer i=1; i<=4; i++) {
            PartnerFundClaim newClaim = new PartnerFundClaim();
            newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today().addDays(-2), System.today().addDays(-2), 122, 
                                                                System.today(), bank1.Id, false);
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Type_Txt__c = 'Claim';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            newClaim.Core_MDF_Type_Txt__c = System.Label.Core_MDF_Claim_Type;
            newClaim.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            claimList.add(newClaim);
        }
        test.startTest();
        upsert claimList;
        
        List<PartnerFundClaim> updatedClaimList = [SELECT Id, Core_MDF_Payment_Id__c, Core_MDF_Status__c, Status FROM PartnerFundClaim LIMIT 2];
        List<PartnerFundClaimShare> claimShare = new List<PartnerFundClaimShare>();
            PartnerFundClaimShare pfcShare1=new PartnerFundClaimShare(AccessLevel='Edit',ParentId=updatedClaimList[0].id,RowCause='Manual',UserOrGroupId=usr1.Id);
            PartnerFundClaimShare pfcShare2=new PartnerFundClaimShare(AccessLevel='Edit',ParentId=updatedClaimList[1].id,RowCause='Manual',UserOrGroupId=usr1.Id);
            claimShare.add(pfcShare1);
            claimShare.add(pfcShare2);
            insert claimShare;
        
        System.runAs(usr1) {
        
        Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
        payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
        payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
        payRunRecord.Core_MDF_Program_Txt__c  ='Client CoMarketing Fund';
        payRunRecord.Core_MDF_Budget_Type_nm__c  ='CCF 1.0';
        payRunRecord.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Client_Co_Marketing_Fund_CMP').getRecordTypeId();
        Database.insert(payRunRecord);
        
        Id ccfRecordTypeId = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
        List<Core_MDF_Payment__c> paymentList = new List<Core_MDF_Payment__c>();
        Core_MDF_Payment__c newPayment = new Core_MDF_Payment__c();
        newPayment.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
        newPayment.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
        newPayment.RecordTypeId = ccfRecordTypeId;            
        //insert newPayment;
        paymentList.add(newPayment);
        Core_MDF_Payment__c newPayment1 = new Core_MDF_Payment__c();
        newPayment1.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
        newPayment1.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
        newPayment1.RecordTypeId = ccfRecordTypeId;
        //insert newPayment1;
        paymentList.add(newPayment1);
        Database.insert(paymentList);
        Integer count = 0;
        List<PartnerFundClaim> paymentDueClaimList = new list<PartnerFundClaim>();
        for(PartnerFundClaim pfc : updatedClaimList) {
            count++;
            pfc.Core_MDF_Status__c = 'Pending Payment';
            pfc.Core_MDF_Payment_Id__c = newPayment.Id;
            if(count > 1) {
                pfc.Core_MDF_Payment_Id__c = newPayment1.Id;
            }
            paymentDueClaimList.add(pfc);
        }
        if(paymentDueClaimList.size() > 0) {
            update paymentDueClaimList;
        }
    Map<String,Set<Id>> localeKeyToUserListMap = new Map<String,Set<Id>>();
        localeKeyToUserListMap.put('en_US',new Set<Id>{usr1.Id});
        Map<Id,Map<String,Set<Id>>> paymentIdToUserMapOfMap = new Map<Id,Map<String,Set<Id>>>();
        paymentIdToUserMapOfMap.put(newPayment1.Id,localeKeyToUserListMap);
        Map<Id,String> paymentIdToProgramMap = new Map<Id,String>();
        paymentIdToProgramMap.put(newPayment1.Id,'Datacenter');
        //Core_MDF_SendPaidPaymentEmail.sendEmail(paymentIdToUserMapOfMap,new Set<String>{'Datacenter'},new Set<String>{'en_US'},paymentIdToProgramMap);            
        //Core_MDF_SendPaidPaymentEmailToAdmin.executeBatch(paymentList);
        }
        List<Core_MDF_SendPaidPaymentEmail.EmailParameter> wrapObjList = new List<Core_MDF_SendPaidPaymentEmail.EmailParameter>();
        Core_MDF_SendPaidPaymentEmail.EmailParameter wrapObj = new Core_MDF_SendPaidPaymentEmail.EmailParameter();
        
        List<Core_MDF_Payment__c> payment = [SELECT Id FROM Core_MDF_Payment__c];
        List<Account> acc = [SELECT Id,Name from Account WHERE Name = 'Test Acc New 2' LIMIT 1];
        List<String> accId = new List<String>();
        accId.add(acc[0].Id);
        //wrapObj.claimCPIds = accId;
        wrapObj.paymentId = payment[0].Id;  
        wrapObj.paymentProg = Core_MDF_CCP_ConstantClass.CCF_PROGRAM; 
        wrapObjList.add(wrapObj);
        Core_MDF_SendPaidPaymentEmail.invokeEmailIds(wrapObjList);
        System.assert(wrapObj != NULL);
        Test.stopTest();
    }
    
    //Checking the exception block by updating the incorrect payload
    
    @isTest
    static void updateIncorrectPaymentRecord() { 
         PartnerFundRequest pfr = [SELECT Id FROM PartnerFundRequest Where Title ='test'];
        Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c Where Name = 'Test'];
        
        User usr1 = [Select id from User where Email='testexmpl2@intel.com' LIMIT 1];
         list<PartnerFundClaim> claimList = new list<PartnerFundClaim>();
            for(integer i=1; i<=4; i++) {
                PartnerFundClaim newClaim = new PartnerFundClaim();
                newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                    Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                    System.today().addDays(-2), System.today().addDays(-2), 122, 
                                                                    System.today(), bank1.Id, false);
                newClaim.Core_MDF_Currency__c = 'USD';
                newClaim.Core_MDF_Type_Txt__c = 'Claim';
                newClaim.Core_MDF_Taxes_Local__c = 0;
                newClaim.Core_MDF_Type_Txt__c = System.Label.Core_MDF_Claim_Type;
                newClaim.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
                claimList.add(newClaim);
            }
        test.startTest();
            insert claimList;
            
        List<PartnerFundClaim> updatedClaimList = [SELECT Id, Core_MDF_Payment_Id__c, Core_MDF_Status__c, Status FROM PartnerFundClaim LIMIT 2];
        List<PartnerFundClaimShare> claimShare = new List<PartnerFundClaimShare>();
        PartnerFundClaimShare pfcShare1=new PartnerFundClaimShare(AccessLevel='Edit',ParentId=updatedClaimList[0].id,RowCause='Manual',UserOrGroupId=usr1.Id);
        PartnerFundClaimShare pfcShare2=new PartnerFundClaimShare(AccessLevel='Edit',ParentId=updatedClaimList[1].id,RowCause='Manual',UserOrGroupId=usr1.Id);
        claimShare.add(pfcShare1);
        claimShare.add(pfcShare2);
        insert claimShare;
            
        System.runAs(usr1) {
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            payRunRecord.Core_MDF_Program_Txt__c  ='Client CoMarketing Fund';
            payRunRecord.Core_MDF_Budget_Type_nm__c  ='CCF 1.0';
            payRunRecord.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Client_Co_Marketing_Fund_CMP').getRecordTypeId();
            Database.insert(payRunRecord);
            
            Id ccfRecordTypeId = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
            List<Core_MDF_Payment__c> paymentList = new List<Core_MDF_Payment__c>();    
            Core_MDF_Payment__c newPayment = new Core_MDF_Payment__c();
            newPayment.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
            newPayment.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
            newPayment.RecordTypeId = ccfRecordTypeId;
            //insert newPayment;
            paymentList.add(newPayment);
            Core_MDF_Payment__c newPayment1 = new Core_MDF_Payment__c();
            newPayment1.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
            newPayment1.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
            newPayment1.Core_MDF_Budget_Type_Nm__c = 'CCF 1.0';
            newPayment1.RecordTypeId = ccfRecordTypeId;
            paymentList.add(newPayment1);
            Database.insert(paymentList);
            Integer count = 0;
            List<PartnerFundClaim> paymentDueClaimList = new list<PartnerFundClaim>();
            for(PartnerFundClaim pfc : updatedClaimList) {
                count++;
                pfc.Core_MDF_Status__c = 'Pending Payment';
                pfc.Core_MDF_Payment_Id__c = newPayment.Id;
                if(count > 1) {
                    pfc.Core_MDF_Payment_Id__c = newPayment1.Id;
                }
                paymentDueClaimList.add(pfc);
            }
            if(paymentDueClaimList.size() > 0) {
                update paymentDueClaimList;
            }            
        }
        Core_MDF_Payment__c correctPaymentRecord = [SELECT Id, Core_MDF_Payment_No_Txt__c, Core_MDF_EFT_Nbr__c, Core_MDF_Payment_Made_Dt__c, Core_MDF_Payment_Status_Txt__c 
                                                    FROM Core_MDF_Payment__c 
                                                    WHERE Core_MDF_Payment_Status_Txt__c = 'Pending Payment' LIMIT 1];
       // test.startTest();
        Core_Integration_Inbound_Message__c payLoad = new Core_Integration_Inbound_Message__c();
        payLoad.Core_Payload__c = '[{"Core_MDF_Payment_No_Txt": "' + correctPaymentRecord.Core_MDF_Payment_No_Txt__c + 
            '","Core_MDF_EFT_Nbr": "ABCD123123","Core_MDF_Payment_Made_Dt": "31-January-2019",' +
            '"Core_MDF_Payment_Status_Txt": "Paid"}]';
        payLoad.Core_Message_Type__c = 'Payment';
        payLoad.Core_Source_System__c = 'EDW';
        insert payLoad;
        
        Core_MDF_Payment__c incorrectUpdatedPaymentRecord = [SELECT Core_MDF_Payment_No_Txt__c, Core_MDF_EFT_Nbr__c, Core_MDF_Payment_Made_Dt__c, Core_MDF_Payment_Status_Txt__c 
                                                             FROM Core_MDF_Payment__c
                                                             WHERE Id =: correctPaymentRecord.Id];        
        System.assertEquals('Pending Payment',incorrectUpdatedPaymentRecord.Core_MDF_Payment_Status_Txt__c);
        test.stopTest();
    }
    
    //Check for the dummy payment update
    
    @isTest
    static void dummyPaymentCheck() {  
        PartnerFundRequest pfr = [SELECT Id FROM PartnerFundRequest Where Title ='test'];
        Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c Where Name = 'Test'];
        User usr1 = [Select id from User where Email='testexmpl2@intel.com' LIMIT 1];
         list<PartnerFundClaim> claimList = new list<PartnerFundClaim>();
            for(integer i=1; i<=4; i++) {
                PartnerFundClaim newClaim = new PartnerFundClaim();
                newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                    Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                    System.today().addDays(-2), System.today().addDays(-2), 122, 
                                                                    System.today(), bank1.Id, false);
                newClaim.Core_MDF_Currency__c = 'USD';
                newClaim.Core_MDF_Type_Txt__c = 'Claim';
                newClaim.Core_MDF_Taxes_Local__c = 0;
                newClaim.Core_MDF_Type_Txt__c = System.Label.Core_MDF_Claim_Type;
                newClaim.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
                claimList.add(newClaim);
            }
            test.startTest();
            insert claimList;
            
        PartnerFundClaim testClaim = [SELECT Id,Title from PartnerFundClaim where Title='Test Claim' limit 1];
        Assert.areEqual('Test Claim',testClaim.Title);
        
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            payRunRecord.Core_MDF_Program_Txt__c  ='Client CoMarketing Fund';
            payRunRecord.Core_MDF_Budget_Type_nm__c  ='CCF 1.0';
            payRunRecord.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Client_Co_Marketing_Fund_CMP').getRecordTypeId();
            System.runAs(usr1) {
            Database.insert(payRunRecord);
            }
            List<PartnerFundClaim> updatedClaimList = [SELECT Id, Core_MDF_Payment_Id__c, Core_MDF_Status__c, Status FROM PartnerFundClaim LIMIT 50];
            Id ccfRecordTypeId = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
            List<Core_MDF_Payment__c> paymentList = new List<Core_MDF_Payment__c>();    
            Core_MDF_Payment__c newPayment = new Core_MDF_Payment__c();
            newPayment.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
            newPayment.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
            newPayment.Core_MDF_Budget_Type_Nm__c = 'CCF 1.0';
            newPayment.RecordTypeId = ccfRecordTypeId;
            paymentList.add(newPayment);
            Core_MDF_Payment__c newPayment1 = new Core_MDF_Payment__c();
            newPayment1.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
            newPayment1.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
            newPayment1.Core_MDF_Budget_Type_Nm__c = 'CCF 1.0';
            newPayment1.RecordTypeId = ccfRecordTypeId;
            paymentList.add(newPayment1);
            Database.insert(paymentList);
            Integer count = 0;
            List<PartnerFundClaim> paymentDueClaimList = new list<PartnerFundClaim>();
            for(PartnerFundClaim pfc : updatedClaimList) {
                count++;
                pfc.Core_MDF_Status__c = 'Pending Payment';
                pfc.Core_MDF_Payment_Id__c = newPayment.Id;
                if(count > 1) {
                    pfc.Core_MDF_Payment_Id__c = newPayment1.Id;
                }
                paymentDueClaimList.add(pfc);
            }
            if(paymentDueClaimList.size() > 0) {
                update paymentDueClaimList;
            } 
          
        Core_MDF_Payment__c paymentRecord = [SELECT Id, Core_MDF_Payment_No_Txt__c, Core_MDF_EFT_Nbr__c, Core_MDF_Payment_Made_Dt__c, Core_MDF_Payment_Status_Txt__c 
                                             FROM Core_MDF_Payment__c 
                                             WHERE Core_MDF_Payment_Status_Txt__c = 'Pending Payment' LIMIT 1];      
        
        Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
        iim.Core_Payload__c = '[{"Core_MDF_Payment_No_Txt": "' + paymentRecord.Core_MDF_Payment_No_Txt__c + 
            '","Core_MDF_EFT_Nbr": "123421","Core_MDF_Payment_Made_Dt": "31-Jan-2019",' +
            '"Core_MDF_Payment_Status_Txt": "Paid"}]';
        iim.Core_Message_Type__c = 'Payment';
        iim.Core_Source_System__c = 'EDW';
        insert iim;
        // Highlight: Unused Local Variable - Indira
       /* Core_MDF_Payment__c correctUpdatedPaymentRecord = [SELECT Core_MDF_Payment_No_Txt__c, Core_MDF_EFT_Nbr__c, Core_MDF_Payment_Made_Dt__c, Core_MDF_Payment_Status_Txt__c 
                                                           FROM Core_MDF_Payment__c
                                                           WHERE Id =:paymentRecord.Id]; */
        test.stopTest();   
    }
    
    //Methods to check the Integration Inbound Message payload
    
    @isTest
    static void insertPayLoadForContact() {
        Test.startTest();
        Core_Integration_Inbound_Message__c contactPayLoad = new Core_Integration_Inbound_Message__c();
        contactPayLoad.Core_Message_Type__c = 'Contact';
        contactPayLoad.Core_Source_System__c = 'ERPM';
        insert contactPayLoad;
        System.assert(contactPayLoad.Core_Source_System__c == 'ERPM');
        Test.stopTest();
    }
    
    @isTest
    static void insertPayLoadForAccount() {
        Test.startTest();
        Core_Integration_Inbound_Message__c accountPayLoad = new Core_Integration_Inbound_Message__c();
        accountPayLoad.Core_Message_Type__c = 'Account';
        accountPayLoad.Core_Source_System__c = 'ERPM';
        insert accountPayLoad;
        System.assert(accountPayLoad.Core_Source_System__c == 'ERPM');
        Test.stopTest();
    }
    
    @isTest
    static void insertPayLoadForBlackBox() {
        Test.startTest();
        Core_Integration_Inbound_Message__c blackBoxPayLoad = new Core_Integration_Inbound_Message__c();
        blackBoxPayLoad.Core_Message_Type__c = 'Blackbox';
        blackBoxPayLoad.Core_Source_System__c = 'ERPM';
        insert blackBoxPayLoad;
        System.assert(blackBoxPayLoad.Core_Source_System__c == 'ERPM');
        Test.stopTest();
    }
    
    @isTest
    static void insertPayLoadForAGS() {
        Test.startTest();
        Core_Trigger_Executions__c triggerActive = new Core_Trigger_Executions__c();
        triggerActive.NAME = 'processInboundMessagesAGS';
        triggerActive.Core_Active__c = TRUE;
        triggerActive.Core_Class_Name__c = 'Core_IntegrationInboundMessageHandler';
        triggerActive.Core_Description__c = 'Process inbound AGS messages from iPaaS';
        triggerActive.Core_Object__c = 'Core_Integration_Inbound_Message__c';
        triggerActive.Core_Trigger_Events__c = 'after insert, after update';
        insert triggerActive;
        
        Core_Integration_Inbound_Message__c rolePayLoad = new Core_Integration_Inbound_Message__c();
        rolePayLoad.Core_Message_Type__c = 'Role';
        rolePayLoad.Core_Source_System__c = 'AGS';
        insert rolePayLoad;
        System.assert(rolePayLoad.Core_Source_System__c == 'AGS');
        Test.stopTest();
    }
    
    @isTest
    static void insertPayLoadForQuote() {
        Test.startTest();
        Core_Trigger_Executions__c triggerActive = new Core_Trigger_Executions__c();
        triggerActive.NAME = 'processInboundMessages';
        triggerActive.Core_Active__c = TRUE;
        triggerActive.Core_Class_Name__c = 'Core_IntegrationInboundMessageHandler';
        triggerActive.Core_Description__c = 'Process inbound messages from iPaas';
        triggerActive.Core_Object__c = 'Core_Integration_Inbound_Message__c';
        triggerActive.Core_Trigger_Events__c = 'before insert, before update';
        insert triggerActive;
        
        Core_Integration_Inbound_Message__c quotePayLoad = new Core_Integration_Inbound_Message__c();
        quotePayLoad.Core_Message_Type__c = 'Quote';
        quotePayLoad.Core_Source_System__c = 'EDW';
        insert quotePayLoad;
        System.assert(quotePayLoad.Core_Message_Type__c == 'Quote');
        Test.stopTest();
    }

}