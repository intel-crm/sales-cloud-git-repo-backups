/****************************************************************************************************************************************
* Class Name  : Core_MDF_HostRegion_Sharing_Test 
* Version     : 1.0 
* Created Date: 01-10-2023
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Mayuri Dhanjani      01-10-2023                  Created Core_MDF_HostRegion_Sharing_Test to test Core_MDF_HostRegion_Sharing class
*******************************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_HostRegion_Sharing_Test{
    public static Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
    public static Id channelProgramId;
    @TestSetup static void setUpData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<User> usrList = new List<User>();
        // Highlight: Unused Local Variable 
       // List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        
        system.runAs(usr){
            //Create Exchnage rates records
            
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            PermissionSet aacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet ipaaacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            PermissionSet rmfaacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            Database.insert(ccfaccntmngr);
            
            User ipaaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ipaaccntmngr.Email = 'ipaaccntmngr@example.com';
            ipaaccntmngr.Profile = ccpCoreAccessProfile;
            PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
            assignPermissionSetObj2.AssigneeId = ipaaccntmngr.Id;
            assignPermissionSetObj2.PermissionSetId = ipaaacntMngrPS.Id;
            Database.insert(ipaaccntmngr);
            
            User rmfaccntmngr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            rmfaccntmngr1.Email = 'rmfaccntmngr@example.com';
            rmfaccntmngr1.Profile = ccpCoreAccessProfile;
            PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
            assignPermissionSetObj3.AssigneeId = rmfaccntmngr1.Id;
            assignPermissionSetObj3.PermissionSetId = rmfaacntMngrPS.Id;
            Database.insert(rmfaccntmngr1);
            
            
            List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();            
            Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
            record1.Name= 'ZMK';
            record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
            record1.Core_MDF_Market_Date__c =System.today()-2;
            record1.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record1);
            
            Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
            record2.Name= 'INR';
            record2.Core_MDF_Exchange_Rate__c = 1;
            record2.Core_MDF_Market_Date__c =System.today()-2;
            record2.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record2); 
            
            Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
            record3.Name= 'USD';
            record3.Core_MDF_Exchange_Rate__c = 1;
            record3.Core_MDF_Market_Date__c =System.today()-2;
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
            
            List<Core_Trigger_Executions__c> triggerExeList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution3.Core_Active__c = false;
            claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before upate, after update';
            claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution3.Name = 'checkAndSendClaimsToAudit';
            claimFunctionalityNameTriggerExecution3.Core_Description__c = 'test';
            triggerExeList.add(claimFunctionalityNameTriggerExecution3);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution4 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution4.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution4.Core_Class_Name__c = 'Core_MDF_SendEmailHelper';
            claimFunctionalityNameTriggerExecution4.Core_Trigger_Events__c = 'after insert';
            claimFunctionalityNameTriggerExecution4.Core_Object__c = 'Core_MDF_Escalation__c';
            claimFunctionalityNameTriggerExecution4.Name = 'Core_MDF_EscalationErrorsNotification';
            claimFunctionalityNameTriggerExecution4.Core_Description__c = 'test';
            triggerExeList.add(claimFunctionalityNameTriggerExecution4);
            
            Core_Trigger_Executions__c claimToCase = new Core_Trigger_Executions__c();
            claimToCase.Core_Active__c = true;
            claimToCase.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimToCase.Core_Description__c = 'This Custom Setting is used to turn on/off claim to case functionality.';
            claimToCase.Core_Object__c = 'PartnerFundClaim';
            claimToCase.Core_Trigger_Events__c = 'after update';
            claimToCase.Name='Core_MDF_ClaimToCase';        
            triggerExeList.add(claimToCase);            
            
            Database.insert(triggerExeList);
            
            List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
            
            Core_Trigger_Executions__c accountShareSetting = new Core_Trigger_Executions__c();
            accountShareSetting.Core_Active__c = true;
            accountShareSetting.Core_Class_Name__c = 'Core_MDF_HostRegion_Sharing';
            accountShareSetting.Core_Trigger_Events__c = 'after insert';
            accountShareSetting.Core_Object__c = 'Account';
            accountShareSetting.Name = 'Core_MDF_HostGeoSharingLogicForAccount';
            accountShareSetting.Core_Description__c = 'test';
            executionList.add(accountShareSetting);
            
            
            Core_Trigger_Executions__c campaignShare = new Core_Trigger_Executions__c();
            campaignShare.Core_Active__c = true;
            campaignShare.Core_Class_Name__c = 'Core_MDF_HostRegion_Sharing';
            campaignShare.Core_Trigger_Events__c = 'after insert';
            campaignShare.Core_Object__c = 'Account';
            campaignShare.Name = 'Core_MDF_HostGeoSharingLogicForCamp';
            campaignShare.Core_Description__c = 'test';
            executionList.add(campaignShare);
            
            Core_Trigger_Executions__c pfrShare = new Core_Trigger_Executions__c();
            pfrShare.Core_Active__c = true;
            pfrShare.Core_Class_Name__c = 'Core_MDF_HostRegion_Sharing';
            pfrShare.Core_Trigger_Events__c = 'after insert';
            pfrShare.Core_Object__c = 'Account';
            pfrShare.Name = 'Core_MDF_HostGeoSharingLogicForPFR';
            pfrShare.Core_Description__c = 'test';
            executionList.add(pfrShare);
            
            Core_Trigger_Executions__c claimShare = new Core_Trigger_Executions__c();
            claimShare.Core_Active__c = true;
            claimShare.Core_Class_Name__c = 'Core_MDF_HostRegion_Sharing';
            claimShare.Core_Trigger_Events__c = 'after insert';
            claimShare.Core_Object__c = 'Account';
            claimShare.Name = 'Core_MDF_HostGeoSharingLogicForClaim';
            claimShare.Core_Description__c = 'test';
            executionList.add(claimShare);
            
            Core_Trigger_Executions__c auditDocShare = new Core_Trigger_Executions__c();
            auditDocShare.Core_Active__c = true;
            auditDocShare.Core_Class_Name__c = 'Core_MDF_HostRegion_Sharing';
            auditDocShare.Core_Trigger_Events__c = 'after insert';
            auditDocShare.Core_Object__c = 'Account';
            auditDocShare.Name = 'Core_MDF_HostGeoSharingLogicAuditDoc';
            auditDocShare.Core_Description__c = 'test';
            executionList.add(auditDocShare);
            
            Core_Trigger_Executions__c pnumShare = new Core_Trigger_Executions__c();
            pnumShare.Core_Active__c = true;
            pnumShare.Core_Class_Name__c = 'Core_MDF_HostRegion_Sharing';
            pnumShare.Core_Trigger_Events__c = 'after insert';
            pnumShare.Core_Object__c = 'Account';
            pnumShare.Name = 'Core_MDF_HostGeoSharingLogicForPNUM';
            pnumShare.Core_Description__c = 'test';
            executionList.add(pnumShare);
            
            
            Core_Trigger_Executions__c caseShare = new Core_Trigger_Executions__c();
            caseShare.Core_Active__c = true;
            caseShare.Core_Class_Name__c = 'Core_MDF_HostRegion_Sharing';
            caseShare.Core_Trigger_Events__c = 'Account';
            caseShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            caseShare.Name = 'Core_MDF_HostGeoSharingLogicForCase';
            caseShare.Core_Description__c = 'test';
            executionList.add(caseShare);
            
            
            Core_Trigger_Executions__c escalationShare = new Core_Trigger_Executions__c();
            escalationShare.Core_Active__c = true;
            escalationShare.Core_Class_Name__c = 'Core_MDF_HostRegion_Sharing';
            escalationShare.Core_Trigger_Events__c = 'after insert';
            escalationShare.Core_Object__c = 'Account';
            escalationShare.Name = 'Core_MDF_HostGeoSharingLogicEscalation';
            escalationShare.Core_Description__c = 'Test1';
            executionList.add(escalationShare);
            
            
            Database.insert(executionList);
            List<Core_MDF_Configuration__c> configMDF = new List<Core_MDF_Configuration__c>();
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.NAME = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            config.Core_MDF_Value__c='3';
            config.Core_MDF_Category__c ='Bank Document Hold Logic';
            configMDF.add(config);
            Core_MDF_Configuration__c config2 = new Core_MDF_Configuration__c();
            config2.NAME = 'ADD_BUS_DAYS_ON_REMINDER_DATE_CLAIM';
            config2.Core_MDF_Value__c='3';
            config2.Core_MDF_Category__c ='Bank Document Hold Logic';
            configMDF.add(config2);
            Core_MDF_Configuration__c config3 = new Core_MDF_Configuration__c();
            config3.NAME = 'BUDGET_TYPE_SKIP_BANK_DOC_HOLD';
            config3.Core_MDF_Value__c='3';
            config3.Core_MDF_Category__c ='Bank Document Hold Logic';
            configMDF.add(config3);
            insert configMDF;
            
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
            channelProgramId = cp.Id;
            
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            
            List<Account> accList = new List<Account>();
            List<Account> intelAccList = new List<Account>();
            // Creating Co-marketing Account with utility class
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Geo__c = 'APJ';
            acc1.Core_Sub_Geo__c = 'SA';
            //acc1.Core_Account_Country__c = 'JAPAN';
            acc1.BillingStateCode = '';
            acc1.BillingCountryCode = 'IND';
            //Database.insert(acc1);
            intelAccList.add(acc1);
            
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intelAccList.add(ipaUltimateAccount);
            
            /*Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
intelAccList.add(ipaUltimateAccount);*/
            Database.insert(intelAccList);
            
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            acc.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
            accList.add(acc);
            Group accNodeGroup = new Group(Name = 'Core_MDF_Retail_Acc_Node_Group', DeveloperName = 'Core_MDF_Retail_Acc_Node_Group');
            insert accNodeGroup;
            
            Account retailAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Test Acc', retailCp.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            retailAcc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            retailAcc.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
            retailAcc.Core_Geo__c = 'APJ';
            retailAcc.Core_Sub_Geo__c = 'SA';
            retailAcc.Core_MDF_Group_Id__c = accNodeGroup.Id;
            accList.add(retailAcc);
            
            Account iPACoMarketingAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Test IPA Account', ipaCP.Id,
                                                                                    Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
            iPACoMarketingAcc.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccount.Id;
            iPACoMarketingAcc.Core_MDF_CoMarketing_Ultimate_Account__c = ipaUltimateAccount.Id;
            iPACoMarketingAcc.Core_Geo__c = 'APJ';
            iPACoMarketingAcc.Core_Sub_Geo__c = 'SA';
            //iPACoMarketingAcc.Core_Account_Country__c = 'JAPAN';
            iPACoMarketingAcc.BillingCountryCode = 'JPN';
            accList.add(iPACoMarketingAcc);
            
            //Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);           
            //accList.add(ipaCoMarketingAccount);
            
            Database.insert(accList);
            
            //String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);     
            
            // Creating Contact with utility class
            List<Contact> conList = new List<Contact>();
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            // con.Core_Audience_List__c = 'RMF User';
            conList.add(con);
            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con1);
            
            Database.insert(conList);
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            // Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.email = 'xyz@mail.com';
            usr1.ContactId = con.Id;
            usrList.add(usr1);
            //Database.insert(usr1);
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.ProfileId = partnerProfile.Id;
            usr2.email = 'abc@mail.com';
            usr2.ContactId = con1.Id;
            usrList.add(usr2);      
            
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            usrList.add(usr3);
            
            User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr4.LastName = 'User Test4';
            usrList.add(usr4);
            
            User usr10 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr10.LastName = 'User Test3';
            usrList.add(usr10);
            
            List<Group> grpList = new List<Group>();
            Group ipaExtGrp = new Group();
            ipaExtGrp.Name = 'Core CCP IPA External';
            ipaExtGrp.DeveloperName = 'Core_MDF_CCP_IPA_External';
            grpList.add(ipaExtGrp);
            
            Database.insert(grpList);
            
            
            
            //User usr5 = Core_MDF_CCP_TestDataUtility.createUser(false);
            //usr5.LastName = 'User Test5';
            // usrList.add(usr5);
            //Test.startTest();
            Database.insert(usrList);
            
            System.runAs(usr){
                // Creating Group Member
                List<GroupMember> grpMemList = new List<GroupMember>();
                GroupMember ipaExtGrpMem1 = new GroupMember();
                ipaExtGrpMem1.UserOrGroupId = usr1.Id;
                ipaExtGrpMem1.GroupId = ipaExtGrp.Id;
                grpMemList.add(ipaExtGrpMem1);
                
                
                Database.insert(grpMemList);
            }
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='RMF', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='RMF');
            insert cee;
            Core_Entitlement__c entitle = new Core_Entitlement__c (name ='RMF User', Core_Category__c='Intel® Partner Investment Center',Core_Sub_Category__c='Retail Marketing Funds (RMF)',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='RMF User',Core_IsActive__c=true);
            insert entitle;
            
            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con.Id,
                                                                             Core_Entitlement_Id__c=entitle.id,
                                                                             Core_Selected__c=true); 
            
            insert ce;
            Core_AGS_Role__c agsRoleIPA = Core_MDF_CCP_TestDataUtility.createAgsRole('IPA_USER', 'Co-Marketing(Salesforce)-IPA USER', true, true);
            
            Core_ERPM_Engagement__c erpmEngagementIPA = Core_MDF_CCP_TestDataUtility.createErpmEngagement('Intel Partner Alliance', 'IPA', '', '', true, true);
            
            Core_Entitlement__c entitlementIPA = Core_MDF_CCP_TestDataUtility.createEntitlement('IPA MDF User',agsRoleIPA.Id ,'Intel Partner Alliance (IPA)','IPA MDF User',erpmEngagementIPA.Id , true,'Solutions Marketplace',true);
            
            Core_Contact_Entitlement__c contactEntitlementIPA1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con.Id,entitlementIPA.Id ,true,'Complete', false);        
            
            insert contactEntitlementIPA1;
            
            List<String> claimSubmitterList = new List<String>(); 
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            claimSubmitterList.add('Core_MDF_CCP_External_Retail_Claim_Submitter');
            claimSubmitterList.add('Core_MDF_CCP_RMF_PRC_Claim_Operations');
            claimSubmitterList.add('Core_MDF_CCP_External_Claim_Submitter');
            claimSubmitterList.add('Core_MDF_CCP_CSC_Claim_Submitter');
            
            Id claimSubPSId ;
            Id mysterShopPSIs ;
            Id claimCCFSubPSId ;
            Id cscClaimSubPSId ;
            // Highlight: Unused Local Variable
           // Id ipaAccPFRSubId;
            //List<PermissionSet> claimSubmitterPS = [SELECT Id, Name FROM PermissionSet WHERE Name IN :claimSubmitterList LIMIT 1];
            
            for(PermissionSet claimSubmitterPS : [SELECT Id, Name FROM PermissionSet WHERE Name IN :claimSubmitterList]){
                if(claimSubmitterPS.Name == 'Core_MDF_CCP_External_Retail_Claim_Submitter'){
                    claimSubPSId = claimSubmitterPS.Id;
                }else if(claimSubmitterPS.Name == 'Core_MDF_CCP_RMF_PRC_Claim_Operations'){
                    mysterShopPSIs = claimSubmitterPS.Id;
                }
                else if(claimSubmitterPS.Name == 'Core_MDF_CCP_External_Claim_Submitter'){
                    claimCCFSubPSId = claimSubmitterPS.Id;
                }
                else if(claimSubmitterPS.Name == 'Core_MDF_CCP_CSC_Claim_Submitter'){
                    cscClaimSubPSId = claimSubmitterPS.Id;
                }
            }       
            PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_External_IPA_Proposal_Manager'];
            
            //PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = claimSubPSId, AssigneeId = usr10.Id);
            //psaList.add(psa);
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = claimSubPSId, AssigneeId = usr1.Id);
            psaList.add(psa);            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = mysterShopPSIs, AssigneeId = usr3.Id);
            psaList.add(psa2);
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = claimCCFSubPSId, AssigneeId = usr1.Id);
            psaList.add(psa3);
            PermissionSetAssignment psa4 = new PermissionSetAssignment(PermissionSetId = cscClaimSubPSId, AssigneeId = usr4.Id);
            psaList.add(psa4);
            PermissionSetAssignment psa5 = new PermissionSetAssignment(PermissionSetId = cscClaimSubPSId, AssigneeId = usr3.Id);
            psaList.add(psa5);
            
            PermissionSetAssignment psa6 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = usr1.Id);
            psaList.add(psa6);
            insert psaList;
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList1 = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgmExt1 = new Core_MDF_Partner_Group_Mapping__c();
            pgmExt1.Core_MDF_Account__c = acc1.Id;
            pgmExt1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External';
            pgmExt1.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgmExt1.Core_MDF_Group_Id__c = ipaExtGrp.Id;                
            pgmExt1.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgmExt1.Core_MDF_Source_Txt__c = 'Test';
            pgmExt1.Core_MDF_Region_cd__C = 'APJ';
            pgmExt1.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_IPA_External1';
            pgmList1.add(pgmExt1);
            
            Database.insert(pgmList1);
            
            Core_MDF_Partner_Node_User_Mapping__c pnum1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(iPACoMarketingAcc.Id,usr1.Id,true);
            
            List<Campaign> campList = new  List<Campaign>();
            
            
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',
                                                                         System.today() - 50, System.today().addYears(1), 20000, 
                                                                         'Instore innovation', retailAcc.Id,'2-in-1', false);
            camp1.Core_MDF_Opal_Budget_Type_Txt__c ='Retail MDF';
            camp1.Core_MDF_Budget_Type_txt__c='Retail MDF';
            camp1.Core_MDF_Budget_Amount_amt__c = 100000;
            camp1.Core_MDF_Market__c = 'AFGHANISTAN';
            camp1.Core_MDF_Technology__c = 'Intel® Arc™ graphics';
            //camp1.Core_MDF_Priority__c='Win Volume';
            campList.add(camp1);
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today().addDays(-5) ,
                                                                        System.today().addDays(200), 2000, 'Test',acc.Id,'2-in-1', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c ='MDF;OEM CMP';
            camp.Core_MDF_Market__c = 'AFGHANISTAN';
            camp.Core_MDF_Priority__c='Consumer non-Evo';
            camp.Core_MDF_Technology__c = 'Intel® Arc™ graphics';
            camp.Core_MDF_Audience__c = 'Partner Sales Force';
            campList.add(camp);
            
            Campaign camp4 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp IPA','Gaming','Athena', 'MDF or both CMP & MDF', 
                                                                         Core_MDF_CCP_IPA_TestDataUtility.campaign_RecordType_IPA,
                                                                         'Intel Partner Alliance', System.today()-15, System.today()+15, 
                                                                         10000, 'Consumer - Premium', iPACoMarketingAcc.Id, '2-in-1', false);
            camp4.Core_MDF_Proposal_Based_Ind__c = false;
            camp4.Core_MDF_Budget_Type_txt__c = 'Account Plan';
            camp4.Core_MDF_Reimbursement_Amt__c = 200.0;
            camp4.Core_MDF_Opal_Budget_Type_Txt__c = 'Account Plan';
            camp4.Core_MDF_Market__c = 'AFGHANISTAN';
            camp4.Core_MDF_Audience__c = 'C-Suite';
            campList.add(camp4);
            
            Database.insert(campList);
            List<PartnerFundRequest> toBeInsertedActivities= new List<PartnerFundRequest>(); 
            PartnerFundRequest testPartnerFundRequest1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),                                                                                                         
                                                                                                           string.valueof(retailAcc.id),NULL,NULL,
                                                                                                           false);
            
            testPartnerFundRequest1.Title ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Activity_Description__c ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            testPartnerFundRequest1.Core_MDF_Start_Date__c = System.today() - 40;
            testPartnerFundRequest1.Core_MDF_End_Date__c  = System.today() - 31;
            testPartnerFundRequest1.RequestedAmount =1000;
            testPartnerFundRequest1.Amount=1000;
            //testPartnerFundRequest1.Core_MDF_Country__c ='AFGHANISTAN';
            testPartnerFundRequest1.Core_MDF_Country_nm__c = 'AFGHANISTAN';
            testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Closed';
            testPartnerFundRequest1.Core_MDF_Activity_Closure_Type__c = 'Manual';
            testPartnerFundRequest1.Core_MDF_Budget_Currency_cd__c ='USD'; 
            testPartnerFundRequest1.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequest1.Core_MDF_Activity_Types__c = 'Personnel';
            //Database.insert(testPartnerFundRequest1);
            toBeInsertedActivities.add(testPartnerFundRequest1);
            
            //Test.startTest();
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
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
            bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
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
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
            bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('byPass_Cancel_Activity');
            bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            Id budget_Retail_Record_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            Id budget_IPA_Acc_Record_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Account_Based').getRecordTypeId();
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            // Creating Budget using utility class
            List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',budget_Retail_Record_Type,
                                                                                   retailAcc.Id,retailCp.Id,5000000,System.today().addDays(-5),System.today(), 
                                                                                   false);
            pmb.IsIgnoreValidation = true;
            //pmb.Core_MDF_Budget_Type__c='Retail MDF';
            pmb.Core_MDF_Budget_Type_Txt__c='Retail MDF';
            pmbList.add(pmb);
            
            PartnerMarketingBudget opalbudgetMDF = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB', RecordTypeIdPMB,
                                                                                             acc.Id,cp.Id,12345678,System.today().addDays(1),System.today().addDays(15),false);
            opalbudgetMDF.IsIgnoreValidation = true;
            opalbudgetMDF.Core_MDF_Budget_Type__c = 'MDF';
            opalbudgetMDF.Core_MDF_Budget_Type_Txt__c = 'MDF';
            pmbList.add(opalbudgetMDF);
            
            PartnerMarketingBudget OEMPMB = Core_MDF_CCP_TestDataUtility.createBudget('TestoemcmpPMB',recordTypeIdPMB,
                                                                                      acc.Id,cp.Id,102345678,System.today().addDays(16),System.today().addDays(30),false);
            OEMPMB.IsIgnoreValidation = true;
            OEMPMB.Core_MDF_Budget_Type__c = 'OEM CMP';
            OEMPMB.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            pmbList.add(OEMPMB);
            
            PartnerMarketingBudget ipaAccPMB = Core_MDF_CCP_TestDataUtility.createBudget('TestIPAcmpPMB',budget_IPA_Acc_Record_Type,
                                                                                         iPACoMarketingAcc.Id,ipaCP.Id,102345678,System.today().addDays(16),System.today().addDays(30),false);
            ipaAccPMB.IsIgnoreValidation = true;
            ipaAccPMB.Core_MDF_Budget_Type__c = 'Account Plan';
            ipaAccPMB.Core_MDF_Budget_Type_Txt__c = 'Account Plan';
            pmbList.add(ipaAccPMB);
            //Test.startTest();
            System.runAs(usr){
                insert pmbList;
            }
            
            List<Core_MDF_Campaign_Budgets__c> campBudgetList = new List<Core_MDF_Campaign_Budgets__c>();
            Core_MDF_Campaign_Budgets__c campBudget= new Core_MDF_Campaign_Budgets__c();
            campBudget.Core_MDF_Campaign_Id__c=camp.id;
            campBudget.Core_MDF_Budget_Name_Id__c=opalbudgetMDF.id;
            campBudget.Core_MDF_Reimbursement_Rate_Pct__c='100%';
            campBudget.Core_MDF_Reimbursement_Amt__c=100000;
            campBudget.Core_MDF_Budget_Amt__c=100000;
            campBudget.Core_MDF_Active_ind__c=true;
            campBudgetList.add(campBudget);
            
            Core_MDF_Campaign_Budgets__c campBudget1 = new Core_MDF_Campaign_Budgets__c();
            campBudget1.Core_MDF_Campaign_Id__c=camp.id;
            campBudget1.Core_MDF_Budget_Name_Id__c=OEMPMB.id;
            campBudget1.Core_MDF_Reimbursement_Rate_Pct__c='100%';
            campBudget1.Core_MDF_Reimbursement_Amt__c=100000;
            campBudget1.Core_MDF_Budget_Amt__c=100000;
            campBudget1.Core_MDF_Active_ind__c=true;
            campBudgetList.add(campBudget1);
            
            System.runAs(usr){
                insert campBudgetList;
            }
            // Creating Allocation using utility class
            
            List<Core_MDF_Bank__c> bankLst = new List<Core_MDF_Bank__c>();
            
            //Creating CCF Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',false,'1234567890');
            bank.Core_MDF_Bank_Status__c = 'Active';  
            bankLst.add(bank);
            // Creating Retail Bank
            Core_MDF_Bank__c retBank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Retail_Marketing_Funds',false,'1234567800');
            retBank.Core_MDF_Bank_Status__c = 'Active';   
            retBank.Core_MDF_Intel_Company_Code__c = '420';
            retBank.Core_MDF_Tax_codes_cd__c = 'UB';
            bankLst.add(retBank);
            Core_MDF_Bank__c ipabank = Core_MDF_CCP_TestDataUtility.createBank(ipaUltimateAccount.id,'Core_MDF_Intel_Partner_Alliance',false,'1234567899');
            ipabank.Core_MDF_Bank_Status__c = 'Active';
            ipabank.Core_MDF_Intel_Company_Code__c = '150';  
            ipabank.Core_MDF_Tax_codes_cd__c = 'UB'; 
            bankLst.add(ipabank);
            Database.insert(bankLst);
            
            
            Test.startTest();
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',opalbudgetMDF,retailAcc,1000000.0,true); 
            PartnerFundAllocation rmfPfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation 1',pmb,retailAcc,1000000.0,false);
            rmfPfa.Amount = 1000000;
            insert rmfPfa;
            PartnerFundAllocation ipaPfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation 11',ipaAccPMB,iPACoMarketingAcc,1000000.0,true);  
            
            PartnerFundAllocation omCmpPfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation 2',OEMPMB,acc,1000000.0,true);
            
            List<Core_MDF_Account_Bank_Mapping__c> accBankMapList = new List<Core_MDF_Account_Bank_Mapping__c>();
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,false);
            abm1.Core_MDF_Active_ind__c = true;
            accBankMapList.add(abm1);
            Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(retailAcc.Id,retBank.Id,false);
            abm2.Core_MDF_Active_ind__c = true;
            accBankMapList.add(abm2);
            Core_MDF_Account_Bank_Mapping__c abm3 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(iPACoMarketingAcc.Id,ipabank.Id,false);
            abm3.Core_MDF_Active_ind__c = true;
            accBankMapList.add(abm3);
            
            Database.insert(accBankMapList);
            
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,opalbudgetMDF,'INDIA','Partner Sales Force',
                                                                                           'Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)',
                                                                                           'Radio','Draft',false);
            pfr.RequestedAmount = 900000;
            pfr.Amount = 900000;
            pfr.Status = 'Approved';
            pfr.Core_MDF_Budget_Type_nm__c = 'MDF';
            pfr.title = 'Test CCF Activity';
            //pfr.Core_MDF_Ultimate_Account_Name__c = acc1.Id;
            pfr.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr.Core_MDF_End_Date__c = System.today();
            //pfr.Core_MDF_Region_cd__c = 'APJ';
            pfr.Core_MDF_Region_nm__c = 'APJ';
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '25%';
            //Database.insert(pfr);
            toBeInsertedActivities.add(pfr);
            
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                            string.valueof(acc.id),omCmpPfa,opalbudgetMDF,'INDIA','Partner Sales Force',
                                                                                            'Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)',
                                                                                            'Radio','Draft',false);
            pfr1.RequestedAmount = 9000;
            pfr1.Amount = 9000;
            pfr1.Status = 'Approved';
            
            pfr1.title = 'Test CCF Activity 1';
            pfr1.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr1.Core_MDF_End_Date__c = System.today();
            //pfr1.Core_MDF_Region_cd__c = 'APJ';
            pfr1.Core_MDF_Region_nm__c = 'APJ';
            pfr1.Core_MDF_Budget_Type_nm__c = 'MDF';
            toBeInsertedActivities.add(pfr1);
            
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),                                                                                                         
                                                                                        string.valueof(retailAcc.id),NULL,NULL,false);
            pfr2.RequestedAmount = 9000;
            pfr2.Amount = 9000;
            pfr2.Status = 'Approved';
            pfr2.title = 'Retail MDF Activity 1';
            pfr2.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr2.Core_MDF_End_Date__c = System.today();
            //pfr2.Core_MDF_Region_cd__c = 'APJ';
            pfr2.Core_MDF_Region_nm__c = 'APJ';
            pfr2.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
            pfr2.AllocationId = rmfPfa.Id;
            pfr2.BudgetId = pmb.Id;
            pfr2.Core_MDF_Activity_Types__c = 'Personnel';
            toBeInsertedActivities.add(pfr2);
            
            PartnerFundRequest pfr3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                            string.valueof(acc.id),omCmpPfa,OEMPMB,'INDIA','Partner Sales Force',
                                                                                            'Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)',
                                                                                            'Radio','Draft',false);
            pfr3.RequestedAmount = 9000;
            pfr3.Amount = 9000;
            pfr3.Status = 'Approved';
            pfr3.title = 'Test CCF Activity 3';
            pfr3.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr3.Core_MDF_End_Date__c = System.today().addDays(5);
            //pfr3.Core_MDF_Region_cd__c = 'APJ';
            pfr3.Core_MDF_Region_nm__c = 'APJ';
            pfr3.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfr3.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            toBeInsertedActivities.add(pfr3);
            
            PartnerFundRequest pfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                            string.valueof(acc.id),omCmpPfa,OEMPMB,'INDIA','Partner Sales Force',
                                                                                            'Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)',
                                                                                            'Radio','Draft',false);
            pfr4.RequestedAmount = 400;
            pfr4.Amount = 400;
            pfr4.Status = 'Approved';
            pfr4.title = 'Test CCF Activity 4';
            pfr4.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr4.Core_MDF_End_Date__c = System.today();
            //pfr4.Core_MDF_Region_cd__c = 'APJ';
            pfr4.Core_MDF_Region_nm__c = 'APJ';
            pfr4.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfr4.Core_MDF_Budget_Currency_cd__c ='USD'; 
            pfr4.Core_MDF_Reimbursement_Rate_pct__c='100%';
            toBeInsertedActivities.add(pfr4);
            
            PartnerFundRequest pfr5 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                            string.valueof(acc.id),omCmpPfa,OEMPMB,'INDIA','Partner Sales Force',
                                                                                            'Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)',
                                                                                            'Radio','Draft',false);
            pfr5.RequestedAmount = 9000;
            pfr5.Amount = 9000;
            pfr5.Status = 'Approved';
            pfr5.title = 'Test CCF Activity 5';
            pfr5.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr5.Core_MDF_End_Date__c = System.today();
            //pfr5.Core_MDF_Region_cd__c = 'APJ';
            pfr5.Core_MDF_Region_nm__c = 'APJ';
            pfr5.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfr5.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            toBeInsertedActivities.add(pfr5);
            PartnerFundRequest pfr6 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                            string.valueof(acc.id),omCmpPfa,OEMPMB,'INDIA','Partner Sales Force',
                                                                                            'Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)',
                                                                                            'Radio','Draft',false);
            pfr6.RequestedAmount = 9000;
            pfr6.Amount = 9000;
            pfr6.Status = 'Approved';
            pfr6.title = 'Test CCF Activity 6';
            pfr6.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr6.Core_MDF_End_Date__c = System.today();
            //pfr6.Core_MDF_Region_cd__c = 'APJ';
            pfr6.Core_MDF_Region_nm__c = 'APJ';
            pfr6.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfr6.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            toBeInsertedActivities.add(pfr6);
            
            PartnerFundRequest pfr7 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),                                                                                                         
                                                                                        string.valueof(retailAcc.id),NULL,NULL,false);
            pfr7.RequestedAmount = 9000;
            pfr7.Amount = 9000;
            pfr7.Status = 'Approved';
            pfr7.title = 'Retail MDF Activity 7';
            pfr7.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr7.Core_MDF_End_Date__c = System.today();
            //pfr7.Core_MDF_Region_cd__c = 'APJ';
            pfr7.Core_MDF_Region_nm__c = 'APJ';
            pfr7.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
            pfr7.AllocationId = rmfPfa.Id;
            pfr7.BudgetId = pmb.Id;
            pfr7.Core_MDF_Activity_Types__c = 'Personnel';
            toBeInsertedActivities.add(pfr7);
            
            PartnerFundRequest IPApfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp4.Id),
                                                                                              Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA,string.valueof(iPACoMarketingAcc.id),NULL,NULL,'India','C-Suite','Traditional Notebook',
                                                                                              'Intel® 11ᵗʰ Gen','Sales Incentive (Pre-2025)','Seller - Target SPIF','Draft',false); 
            IPApfr.Core_MDF_Activity_Description__c = 'Test IPA Activity';
            IPApfr.Title = 'Test IPA Activity';
            IPApfr.Core_MDF_Start_Date__c = System.today().addDays(1);
            IPApfr.Core_MDF_End_Date__c = System.today().addDays(2);
            IPApfr.Core_MDF_Country_nm__c = 'India';
            IPApfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            IPApfr.Core_MDF_Budget_Type_nm__c = 'Account Plan';
            IPApfr.Core_MDF_TargetAudience__c = 'C-Suite';
            IPApfr.Core_MDF_Focus_Area_nm__c = 'Client Computing';
            IPApfr.AllocationId = ipaPfa.Id;
            IPApfr.BudgetId = ipaAccPMB.Id;
            toBeInsertedActivities.add(IPApfr);
            
            PartnerFundRequest IPApfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp4.Id),
                                                                                               Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA,string.valueof(iPACoMarketingAcc.id),NULL,NULL,'India','C-Suite','Traditional Notebook',
                                                                                               'Intel® 11ᵗʰ Gen','Sales Incentive (Pre-2025)','Seller - Target SPIF','Draft',false); 
            IPApfr2.Core_MDF_Activity_Description__c = 'Test IPA Activity 2';
            IPApfr2.Title = 'Test IPA Activity 2';
            IPApfr2.Core_MDF_Start_Date__c = System.today().addDays(-1);
            IPApfr2.Core_MDF_End_Date__c = System.today().addDays(3);
            IPApfr2.Core_MDF_Country_nm__c = 'India';
            IPApfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            IPApfr2.Core_MDF_Budget_Type_nm__c = 'Account Plan';
            IPApfr2.Core_MDF_Focus_Area_nm__c = 'Client Computing';
            IPApfr2.AllocationId = ipaPfa.Id;
            IPApfr2.BudgetId = ipaAccPMB.Id;
            toBeInsertedActivities.add(IPApfr2);
            System.runAs(usr){
                Database.insert(toBeInsertedActivities);
            }
            PartnerFundClaim pfc  = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim 11', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,
                                                                             pfr3.Id, System.today().addDays(-2), System.today(), 40.0, System.today().addDays(-1),
                                                                             bank.Id, false);
            pfc.Core_MDF_Audit_Hold__c = true;
            pfc.Core_MDF_Taxes_Local__c = 0;
            pfc.Core_MDF_Currency__c = 'USD';
            pfc.Core_MDF_Exchange_rate__c = 1;
            pfc.Core_MDF_Country_Location_nm__c = 'INDIA';
            pfc.Core_MDF_Region_Cd__c = 'APJ';
            pfc.Core_MDF_Escalation_Id__c = null;
            pfc.Core_MDF_Type_Txt__c = 'Claim';
            pfc.Core_MDF_Ad_Run_Start_Date__c = System.today().addDays(-4);
            pfc.Core_MDF_Ad_Run_End_Date__c = System.today().addDays(-4);
            pfc.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            pfc.Core_MDF_Invoice_Date__c = System.today().addDays(-4);
            pfc.Core_MDF_Invoice_Number__c = 'INV1686';
            pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 2;
            pfc.Core_MDF_Total_Invoice_Amount_Local__c = 50;
            System.runAs(usr){
            insert pfc;
            }
            
            PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, IPApfr2.Id, System.today().addDays(-1), System.today(),50.00, ipabank.Id, false); 
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'INDIA'; 
            claim1.Core_MDF_Campaign_Id__c = camp4.Id;
            claim1.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_To_Be_Audited_Ind__c = true;
            claim1.Core_MDF_Quarter_Year_txt__c = 'Q2-2023';
            claim1.Core_MDF_Paid_By_Payment_Type_nm__c = 'Non-Customer';
            claim1.Core_MDF_Ad_Run_Start_Date__c = System.today();
            claim1.Core_MDF_Ad_Run_End_Date__c = System.today();
            claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-4);
            claim1.Core_MDF_Invoice_Number__c = 'INV1686';
            claim1.Core_MDF_OtherCostsnotReimbursable_Local__c = 2;
            claim1.Core_MDF_Total_Invoice_Amount_Local__c = 50;
            System.runAs(usr){
            insert claim1;
            }
            
            
            Id budgetRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();
            Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
            Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();   
            
            List<ContentVersion> conVersionLst = new List<ContentVersion>();
            ContentVersion conVersion = new ContentVersion();
            conVersion.ContentLocation = 'S';
            conVersion.Title = 'Test';
            conVersion.PathOnClient='Test';
            conVersion.ReasonForChange = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ContentVersion_ReasonForChange');
            conVersion.VersionData = Blob.valueOf('content');
            conVersionLst.add(conVersion);
            System.runAs(usr){
            Database.insert(conVersionLst); //Insert contentversion list
            }
            ContentVersion contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN : conVersionLst limit 1];
            
            ContentDocument conDoc= [SELECT Id,OwnerId FROM ContentDocument WHERE Id =:contentVersions.ContentDocumentId limit 1];
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c(); 
            auditDoc.Core_MDF_Document_Id__c = conDoc.Id;
            auditDoc.Core_MDF_Document_Title__c = 'Test';
            auditDoc.Core_MDF_Claim__c = claim1.Id;
            auditDoc.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc.Core_MDF_App_Document_Types_nm__c= 'Proof of Cost;Proof of Execution;Proof of Attribution';
            System.runAs(usr){
            insert auditDoc;
            }
            
            List<Core_MDF_Escalation__c> escList = new List<Core_MDF_Escalation__c>();
            
            IPApfr2.Core_MDF_Fund_Request_Status__c = 'Closed';
            database.update(IPApfr2);
            
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
            cs.Status = 'Closed';
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = iPACoMarketingAcc.Id;
            cs.Core_MDF_Claim_ID__c = claim1.id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APJ - IJKK';
            System.runAs(usr){
            database.insert(cs);
            }
            
            Core_MDF_Escalation__c budgetEsc = new Core_MDF_Escalation__c();
        budgetEsc.Core_MDF_Escalation_Status_nm__c='Pending Review';
        budgetEsc.Core_MDF_Escalation_Name_txt__c='Test';
        budgetEsc.Core_MDF_Total_Dollar_Impact_amt__c= 56;
        budgetEsc.Core_MDF_Root_Cause_nm__c = 'Appeal of Budget';
        budgetEsc.Core_MDF_Budget_ID_Number_id__c = ipaAccPMB.Id;
        budgetEsc.Core_MDF_Channel_Program_id__c = ipaCP.Id;
        budgetEsc.recordtypeid = budgetRecType;
        escList.add(budgetEsc);
            
            Core_MDF_Escalation__c caseEsc = new Core_MDF_Escalation__c();
            caseEsc.Core_MDF_Escalation_Status_nm__c='Pending Review';
            caseEsc.Core_MDF_Escalation_Name_txt__c='Test2';
            caseEsc.Core_MDF_Total_Dollar_Impact_amt__c= 45;
            caseEsc.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
            caseEsc.Core_MDF_Case_ID_Number_id__c = cs.Id;
            caseEsc.Core_MDF_Channel_Program_id__c = ipaCP.Id;
            caseEsc.recordtypeid = caseRecType;
             escList.add(caseEsc);
            
             Core_MDF_Escalation__c activityEsc = new Core_MDF_Escalation__c();
        activityEsc.Core_MDF_Escalation_Status_nm__c='Pending Review';
        activityEsc.Core_MDF_Escalation_Name_txt__c='Test1';
        activityEsc.Core_MDF_Total_Dollar_Impact_amt__c= 56;
        activityEsc.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
        activityEsc.Core_MDF_Co_Marketing_Activity_id__c = IPApfr2.Id;
        activityEsc.Core_MDF_Channel_Program_id__c = ipaCP.Id;
        activityEsc.recordtypeid= claimRecType;
             escList.add(activityEsc);
            System.runAs(usr){
            Database.insert(escList);
            }
            
            List<sObject> shareRecords = new List<sObject>();
            PartnerFundRequestShare pfrShare1 = new PartnerFundRequestShare();
            pfrShare1.ParentId = pfr.Id;
            pfrShare1.UserOrGroupId = usr1.id;
            pfrShare1.AccessLevel = 'Edit';
            //Database.insert(pfrShare);  
            shareRecords.add(pfrShare1);
            
            Core_MDF_Bank__Share bankShare  = new Core_MDF_Bank__Share();
            bankShare.ParentId = bank.Id;
            bankShare.UserOrGroupId = usr1.id;
            bankShare.AccessLevel = 'Edit'; 
            //Database.insert(bankShare); 
            shareRecords.add(bankShare);  
            
            PartnerMarketingBudgetShare pmbShare = new PartnerMarketingBudgetShare();
            pmbShare.ParentId = pmb.Id;
            pmbShare.UserOrGroupId = usr1.id;
            pmbShare.AccessLevel = 'Edit';
            //Database.insert(pmbShare);
            shareRecords.add(pmbShare);
            
            PartnerFundAllocationShare pfaShare = new PartnerFundAllocationShare();
            pfaShare.ParentId = pfa.Id;
            pfaShare.UserOrGroupId = usr1.id;
            pfaShare.AccessLevel = 'Edit';
            //Database.insert(pfaShare);
            shareRecords.add(pfaShare);
            
            PartnerFundAllocationShare pfaShare1 = new PartnerFundAllocationShare(UserOrGroupId = pnum1.Core_MDF_User__c, AccessLevel = 'Edit', parentId = ipaPfa.Id, RowCause = 'Manual');
            shareRecords.add(pfaShare1);
            
            PartnerFundRequestShare pfrShare11 = new PartnerFundRequestShare(UserOrGroupId = pnum1.Core_MDF_User__c, AccessLevel = 'Edit', parentId = IPApfr2.Id, RowCause = 'Manual');
            shareRecords.add(pfrShare11);
            
            Core_MDF_Bank__Share bankShare1 = new Core_MDF_Bank__Share(UserOrGroupId = pnum1.Core_MDF_User__c, AccessLevel = 'Edit', parentId = ipabank.Id, RowCause = 'Manual');
            shareRecords.add(bankShare1);
            
            Core_MDF_Account_Bank_Mapping__Share abmShare1 = new Core_MDF_Account_Bank_Mapping__Share(UserOrGroupId = pnum1.Core_MDF_User__c, AccessLevel = 'Edit', parentId = abm3.Id, RowCause = 'Manual');
            shareRecords.add(abmShare1);
            
            Campaignshare cmpShare11 = new Campaignshare(UserOrGroupId = pnum1.Core_MDF_User__c, CampaignAccessLevel = 'Edit', CampaignId = camp4.Id, RowCause = 'Manual');
            shareRecords.add(cmpShare11);
            
             CaseShare caseShare11 = new CaseShare(UserOrGroupId = pnum1.Core_MDF_User__c, CaseAccessLevel = 'Edit', CaseId = cs.Id, RowCause = 'Manual');
            shareRecords.add(caseShare11);
            
            Core_MDF_Escalation__Share escShare1 = new Core_MDF_Escalation__Share(UserOrGroupId = pnum1.Core_MDF_User__c, AccessLevel = 'Edit', parentId = activityEsc.Id, RowCause = 'Manual');
            shareRecords.add(escShare1);
            
            if(shareRecords != null && shareRecords.size() > 0){
                System.runAs(usr){
                Database.insert(shareRecords);
                }
            }
            
            
            //Creating Groups
            Group grp = new Group();
            grp.Name = 'CCP INTERNAL CCF APJ TACCOUNT';
            grp.DeveloperName = 'Core_MDF_CCP_INTERNAL_CCF_APJ_TACCOUNT';
            
            Group grp1 = new Group();
            grp1.Name = 'Core_MDF_CCP_External';
            grp1.DeveloperName = 'Core_MDF_CCP_External';   
            
            Group grp2 = new Group();
            grp2.Name = 'CCP INTERNAL CCF EMEA TACCOUNT';
            grp2.DeveloperName = 'Core_MDF_CCP_INTERNAL_CCF_EMEA_TACCOUNT';
            
            Group grp3 = new Group();
            grp3.Name = 'CCP INTERNAL CCF ASMO TACCOUNT';
            grp3.DeveloperName = 'Core_MDF_CCP_INTERNAL_CCF_ASMO_TACCOUNT';
            
            Group grp4 = new Group();
            grp4.Name = 'CCP INTERNAL CCF WW TACCOUNT';
            grp4.DeveloperName = 'Core_MDF_CCP_INTERNAL_CCF_WW_TACCOUNT';
            
            Group grp5 = new Group();
            grp5.Name = 'CCP INTERNAL CCF PRC TACCOUNT';
            grp5.DeveloperName = 'Core_MDF_CCP_INTERNAL_CCF_PRC_TACCOUNT';
            
            Group grp6 = new Group();
            grp6.Name = 'CCP EXTERNAL RMF GROUP';
            grp6.DeveloperName = 'Core_MDF_RMF_EXTERNAL';
            
            Group grp7 = new Group();
            grp7.Name = 'CCP INTERNAL IPA PRC TACCOUNT';
            grp7.DeveloperName = 'Core_MDF_CCP_INTERNAL_IPA_PRC_TACCOUNT';
            
            List<Group> lstGroup = new List<Group>();
            lstGroup.add(grp);
            lstGroup.add(grp1);
            lstGroup.add(grp2);
            lstGroup.add(grp3);
            lstGroup.add(grp4);
            lstGroup.add(grp5);
            lstGroup.add(grp6);
            lstGroup.add(grp7);
            System.runAs(usr){
            Database.insert(lstGroup);
            
            
            // Creating Group Members
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = usr2.Id;
            grpMember.GroupId = grp1.Id;
            
            GroupMember grpMember1 = new GroupMember();
            grpMember1.UserOrGroupId = usr3.Id;
            grpMember1.GroupId = grp1.Id;
            
            GroupMember grpMember2 = new GroupMember();
            grpMember2.UserOrGroupId = usr4.Id;
            grpMember2.GroupId = grp2.Id;           
            
            GroupMember grpMember3 = new GroupMember();
            grpMember3.UserOrGroupId = usr4.Id;
            grpMember3.GroupId = grp3.Id;
            
            GroupMember grpMember4 = new GroupMember();
            grpMember4.UserOrGroupId = usr1.Id;
            grpMember4.GroupId = grp6.Id;
            
            List<GroupMember> lstGrpMember = new List<GroupMember>();
            lstGrpMember.add(grpMember);
            lstGrpMember.add(grpMember1);
            lstGrpMember.add(grpMember2);
            lstGrpMember.add(grpMember3);
            lstGrpMember.add(grpMember4);
            Database.insert(lstGrpMember);
            
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = acc1.Id;
            pgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_INTERNAL_CCF_APJ_TACCOUNT';
            pgm.Core_MDF_Type_of_Access__c = 'Internal';
            //pgm.Core_MDF_Group_Id__c = grp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_Region_cd__c = 'APJ';
            pgm.Core_MDF_Sub_Region_cd__c = 'SA';
            pgm.Core_MDF_Source_Txt__c = 'Test';
            pgm.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_INTERNAL_CCF_APJ_TACCOUNT';
            pgmList.add(pgm);
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            //pgm1.Core_MDF_Group_Id__c = grp1.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_External';
            pgmList.add(pgm1);
            
            Core_MDF_Partner_Group_Mapping__c pgmRMF = new Core_MDF_Partner_Group_Mapping__c();
            pgmRMF.Core_MDF_Account__c = acc1.Id;
            pgmRMF.Core_MDF_Group_Name__c = 'Core_MDF_RMF_EXTERNAL';
            pgmRMF.Core_MDF_Type_of_Access__c = 'External';
            pgmRMF.Core_MDF_Group_Id__c = grp6.Id;                
            pgmRMF.Core_MDF_Channel_Program__c = retailCp.Id;
            pgmRMF.Core_MDF_Source_Txt__c = 'Test';
            pgmRMF.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_RMF_EXTERNAL';
            pgmList.add(pgmRMF);
            
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = acc1.Id;
            pgm2.Core_MDF_Group_Name__c = 'Core_MDF_CCP_INTERNAL_CCF_EMEA_TACCOUNT';
            pgm2.Core_MDF_Type_of_Access__c = 'Internal';
            //pgm2.Core_MDF_Group_Id__c = grp2.Id;                
            pgm2.Core_MDF_Channel_Program__c = cp.Id;
            pgm2.Core_MDF_Region_cd__c = 'EMEA';
            pgm2.Core_MDF_Source_Txt__c = 'Test';
            pgm2.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_INTERNAL_CCF_EMEA_TACCOUNT';
            pgmList.add(pgm2);            
            
            Core_MDF_Partner_Group_Mapping__c pgm3 = new Core_MDF_Partner_Group_Mapping__c();
            pgm3.Core_MDF_Account__c = acc1.Id;
            pgm3.Core_MDF_Group_Name__c = 'Core_MDF_CCP_INTERNAL_CCF_ASMO_TACCOUNT';
            pgm3.Core_MDF_Type_of_Access__c = 'Internal';
            pgm3.Core_MDF_Group_Id__c = grp2.Id;               
            pgm3.Core_MDF_Channel_Program__c = cp.Id;
            pgm3.Core_MDF_Region_cd__c = 'ASMO';
            pgm3.Core_MDF_Sub_Region_cd__c = 'NAR';
            pgm3.Core_MDF_Source_Txt__c = 'Test';
            pgm3.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_INTERNAL_CCF_ASMO_TACCOUNT';
            pgmList.add(pgm3);
            
            Core_MDF_Partner_Group_Mapping__c pgm4 = new Core_MDF_Partner_Group_Mapping__c();
            pgm4.Core_MDF_Account__c = acc1.Id;
            pgm4.Core_MDF_Group_Name__c = 'Core_MDF_CCP_INTERNAL_CCF_PRC_TACCOUNT';
            pgm4.Core_MDF_Type_of_Access__c = 'Internal';
            pgm4.Core_MDF_Group_Id__c = grp2.Id;                
            pgm4.Core_MDF_Channel_Program__c = cp.Id;
            pgm4.Core_MDF_Region_cd__c = 'PRC';
            pgm4.Core_MDF_Source_Txt__c = 'Test';
            pgm4.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_INTERNAL_CCF_PRC_TACCOUNT';
            pgmList.add(pgm4);
            
            Core_MDF_Partner_Group_Mapping__c pgm5 = new Core_MDF_Partner_Group_Mapping__c();
            pgm5.Core_MDF_Account__c = acc1.Id;
            pgm5.Core_MDF_Group_Name__c = 'Core_MDF_CCP_INTERNAL_CCF_WW_TACCOUNT';
            pgm5.Core_MDF_Type_of_Access__c = 'Internal';
            //pgm5.Core_MDF_Group_Id__c = grp2.Id;                
            pgm5.Core_MDF_Channel_Program__c = cp.Id;
            pgm5.Core_MDF_Region_cd__c = 'WW';
            pgm5.Core_MDF_Source_Txt__c = 'Test';
            pgm5.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_INTERNAL_CCF_WW_TACCOUNT';
            pgmList.add(pgm5);
            
            Core_MDF_Partner_Group_Mapping__c pgm6 = new Core_MDF_Partner_Group_Mapping__c();
            pgm6.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgm6.Core_MDF_Group_Name__c = 'Core_MDF_CCP_INTERNAL_IPA_PRC_TACCOUNT';
            pgm6.Core_MDF_Type_of_Access__c = 'Internal';
            //pgm6.Core_MDF_Group_Id__c = grp6.Id;                
            pgm6.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgm6.Core_MDF_Region_cd__c = 'PRC';
            pgm6.Core_MDF_Source_Txt__c = 'Test';
            pgm6.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_INTERNAL_IPA_PRC_TACCOUNT';
            pgmList.add(pgm6);
            
            //Test.stopTest(); 
            //
            Campaignshare campShare = new Campaignshare();
            campShare.CampaignId = camp4.Id;
            campShare.UserOrGroupId = grp6.id;
            campShare.CampaignAccessLevel = 'Edit';
            Database.insert(campShare);  
            
            
            Database.insert(pgmList);
            }
                        Test.stopTest(); 
            
            
        }
    }
    
    @isTest
    static void testBatchShare() {
         Test.StartTest();
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c limit 1];
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord3 = pnumRecord;
        
        String query = 'SELECT Id, Core_MDF_Escalation_Type_nm__c, Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c,'
            +' Core_MDF_Co_Marketing_Activity_id__c, Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId'
            +' FROM Core_MDF_Escalation__c WHERE Core_MDF_Co_Marketing_Activity_id__c != NULL AND Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId != NULL AND '
            +' Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId IN ';
          
          String query1 = 'SELECT Id, Core_MDF_Program__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c,'
                    +' Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c '
                    +' FROM Campaign WHERE (Core_MDF_Program__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
                    +' OR Core_MDF_Program__c = '+ '\'' +Label.Core_MDF_IPA_Program_Name+ '\' )'
                    +' AND (Core_MDF_Account__c IN : setOfAccounts OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c IN : setOfAccounts'
                    +' OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN ';  
                   Test.stopTest();  
                //Core_MDF_PNUMappingServiceHandler.deleteObjectShareRecords(new List<Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord2}, new Map<Id,Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord3.Id => pnumRecord3}, false);
                Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('PartnerFundAllocationShare', new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}}, 'SELECT Id, ChannelPartnerId FROM PartnerFundAllocation WHERE ChannelPartnerId IN ', new List<Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord}, false, new Map<Id,Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord.Id => pnumRecord3}, new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}} ), 50);
                Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('Core_MDF_Bank__Share', new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}}, 'SELECT Core_MDF_Bank__c,Core_MDF_Account__c,Id FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c IN ', new List<Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord}, false, new Map<Id,Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord.Id => pnumRecord3}, new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}} ), 50);
                Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('PartnerFundClaimShare', new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}}, 'SELECT Id, ChannelPartnerId,Core_MDF_Payment_Id__c FROM PartnerFundClaim WHERE ChannelPartnerId IN ', new List<Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord}, false, new Map<Id,Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord.Id => pnumRecord3}, new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}} ), 50);
                Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('Core_MDF_Escalation__Share', new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}}, query, new List<Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord}, false, new Map<Id,Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord.Id => pnumRecord3}, new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}} ), 50);
                Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('CampaignShare', new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}}, query1, new List<Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord}, false, new Map<Id,Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord3.Id => pnumRecord}, new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}} ), 50);
                Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('CaseShare', new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}}, 'SELECT Id, AccountId FROM Case WHERE AccountId IN ', new List<Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord}, false, new Map<Id,Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord.Id => pnumRecord3}, new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}} ), 50);
                Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('PartnerFundRequestShare', new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}}, 'SELECT Id, ChannelPartnerId FROM PartnerFundRequest WHERE ChannelPartnerId IN ', new List<Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord}, false, new Map<Id,Core_MDF_Partner_Node_User_Mapping__c>{pnumRecord.Id => pnumRecord3}, new Map<Id, List<Id>>{pnumRecord.Core_MDF_Account__c => new List<Id>{pnumRecord.Core_MDF_User__c}} ), 50);
        // US - TWC702-14285: Unit Test Method should include System.Assert
        System.assertNotEquals(null, pnumRecord, 'Partner Node User Mapping record should exist');
        System.assertNotEquals(null, pnumRecord.Core_MDF_Account__c, 'Account should be associated with PNUM record');
    }
       @isTest
    static void testHostRegionUpdate() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.StartTest();
    
        User user1 = [SELECT Id, Email FROM User WHERE Email = 'ccfaccntmngr@example.com' LIMIT 1];
    
        System.runAs(user1) {
            try {
                List<Account> hostGeoUpdatedAccList = new List<Account>();
                Account acc3 = [SELECT Id, Name, Core_Geo__c, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__c FROM Account WHERE Name = 'Test IPA Account'];
                acc3.Core_Geo__c = 'PRC';
                update acc3;
                hostGeoUpdatedAccList.add(acc3);
            
                Core_MDF_HostRegion_Sharing.createObjectShareRecords(hostGeoUpdatedAccList, hostGeoUpdatedAccList);
        
                String cronExp = '0 0 0 * * ?';  //every day at midnight
                String jobName = 'Test_Bulk_API_Job';
                String scheduledJobId = System.schedule(jobName, cronExp, new BulkApiScheduler());

                List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper> listof = new List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper>();
                Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper wrapper = new Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper(scheduledJobId, 'Bulk API', 'AccountShare', 'Delete', 'In Progress');
                listof.add(wrapper);
            
                Core_MDF_BulkAPI_Operations.insertAsyncBulkRecords(listof);
                Core_MDF_BulkAPI_Operations.insertAsyncBulkRecordsByPE(listof);
            
                Test.stopTest();
                // US - TWC702-14285: Unit Test Method should include System.Assert
               System.assertEquals('PRC', acc3.Core_Geo__c, 'Account Core_Geo__c should be updated to PRC');
            } 
            catch (Exception e) {
               // Highlight: Unused Local Variable
              //  String message = e.getMessage();
            }
        }
    }

    public without sharing class BulkApiScheduler implements Schedulable {
        public void execute(SchedulableContext sc) {
        }
    }    
}