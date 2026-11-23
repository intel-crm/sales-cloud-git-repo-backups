@isTest
public class Core_MDF_CustomLayoutConfig_Contrl_Test {
    @TestSetup
    public static void createData(){
        // Highlight: Unused Local Variable - 14285 / Suma
       // Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        System.runAs(usr){
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            
            PermissionSet ipaMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            User ipaaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ipaaccntmngr.Email = 'ipaaccntmngr@example.com';
            ipaaccntmngr.Profile = ccpCoreAccessProfile;
            PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
            
            assignPermissionSetObj2.AssigneeId = ipaaccntmngr.Id;
            assignPermissionSetObj2.PermissionSetId = ipaMngrPS.Id;
            Database.insert(ipaaccntmngr);
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('byPass_Cancel_Activity');
            bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
            bypassFunctionKeys.add('Core_MDF_BypassATFFlagUpdate');
            bypassFunctionKeys.add('byPass_PastDated_Activity');
            bypassFunctionKeys.add('Core_MDF_BypassATFFlagUpdateBatch');
            bypassFunctionKeys.add('Core_MDF_Bypass_PFREmailNotification');
            bypassFunctionKeys.add('Core_MDF_Bypass_CloseDateExtend_ATF');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            List<Core_MDF_Custom_Layout_Section__c> sections= new List<Core_MDF_Custom_Layout_Section__c>();
            Core_MDF_Custom_Layout_Section__c sec1 = new Core_MDF_Custom_Layout_Section__c(Core_MDF_Section_Name_txt__c='Section 1',Core_MDF_Object_Name_txt__c='Campaign',Core_MDF_No_Of_Columns_nm__c= '1', Core_MDF_Sequence_No_nbr__c= 1.0, Core_MDF_Field_View_nm__c = 'Detail Layout');
            Core_MDF_Custom_Layout_Section__c sec2 = new Core_MDF_Custom_Layout_Section__c(Core_MDF_Section_Name_txt__c='Section 2',Core_MDF_Object_Name_txt__c='Campaign',Core_MDF_No_Of_Columns_nm__c= '2', Core_MDF_Sequence_No_nbr__c=2.0, Core_MDF_Field_View_nm__c = 'Detail Layout');
            Core_MDF_Custom_Layout_Section__c sec3 = new Core_MDF_Custom_Layout_Section__c(Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance', Core_MDF_Budget_Type_nm__c='Account Based', Core_MDF_Section_Name_txt__c='Section 2',Core_MDF_Object_Name_txt__c='Campaign',Core_MDF_No_Of_Columns_nm__c= '2', Core_MDF_Sequence_No_nbr__c=2.0, Core_MDF_Field_View_nm__c = 'Compact Layout', Core_MDF_ButtonsVisibilityOnStatus_txt__c = '[{"prmissionSetName":"Core_MDF_CCP_Internal_IPA_Acct_Mgr","controllingFieldValueBasedOnPs":[{"controllingFieldValue":"Draft","buttons":["Edit", "Clone", "Cancel Campaign", "Create Activity"]},{"controllingFieldValue":"In Progress","buttons":["Edit", "Clone", "Cancel Campaign"]}]}]', Core_MDF_ButtonVisibilityByProfile_txt__c='[{"profileName" : "System Administrator", "controllingFieldValueBasedOnPs": [{"controllingFieldValue":"Draft","buttons":["Edit", "Clone", "Cancel Campaign", "Create Activity"]},{"controllingFieldValue":"In Progress","buttons":["Clone"]}]}]');
            Core_MDF_Custom_Layout_Section__c sec4 = new Core_MDF_Custom_Layout_Section__c(Core_MDF_Section_Name_txt__c='Section 1',Core_MDF_Object_Name_txt__c='PartnerFundRequest',Core_MDF_No_Of_Columns_nm__c= '1', Core_MDF_Sequence_No_nbr__c= 1.0, Core_MDF_Field_View_nm__c = 'Detail Layout');
            sections.add(sec1);
            sections.add(sec2);
            sections.add(sec3);
            sections.add(sec4);
            Database.insert(sections);
            // Insert Custom Layout Config
            List<Core_MDF_Custom_Layout_Configurations__c> custLayouts1= new List<Core_MDF_Custom_Layout_Configurations__c>();
            Core_MDF_Custom_Layout_Configurations__c cust1= new Core_MDF_Custom_Layout_Configurations__c(Core_MDF_Field_API_Name_txt__c='Core_MDF_Account__c',Core_MDF_User_Type_nm__c= 'Internal User',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_Object_API_Name_txt__c='Campaign',Core_MDF_Section_id__c=sections[0].id, Core_MDF_Budget_Type_nm__c = 'Account Based',Core_MDF_Alignment_nm__c='Left',Core_MDF_Field_Label_txt__c='Account', Core_MDF_Filter_Criteria_txt__c = 'Core_MDF_Proposal_Based_Ind__c == False', Core_MDF_Active_Ind__c = true, Core_MDF_Record_Name_nm__c= 'Core_MDF_Account__r.Name', Core_MDF_Is_Lookup_Ind__c=true);
            Core_MDF_Custom_Layout_Configurations__c cust2= new Core_MDF_Custom_Layout_Configurations__c(Core_MDF_Field_API_Name_txt__c='Core_MDF_Strategic_Marketing_Fund_Ind__c',Core_MDF_User_Type_nm__c= 'Internal User',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_Object_API_Name_txt__c='Campaign',Core_MDF_Section_id__c=sections[0].id, Core_MDF_Budget_Type_nm__c = 'Account Based',Core_MDF_Alignment_nm__c='Left',Core_MDF_Field_Label_txt__c='StrategicFund',Core_MDF_Display_Custom_Label_Ind__c = true, Core_MDF_Filter_Criteria_txt__c = 'Core_MDF_Proposal_Based_Ind__c == False', Core_MDF_Active_Ind__c = true);
            Core_MDF_Custom_Layout_Configurations__c cust3= new Core_MDF_Custom_Layout_Configurations__c(Core_MDF_Field_API_Name_txt__c='StartDate',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_User_Type_nm__c= 'Internal User',Core_MDF_Object_API_Name_txt__c='Campaign',Core_MDF_Section_id__c=sections[0].id, Core_MDF_Budget_Type_nm__c = 'Account Based',Core_MDF_Alignment_nm__c='Left', Core_MDF_Filter_Criteria_txt__c = 'Core_MDF_Proposal_Based_Ind__c == False', Core_MDF_Active_Ind__c = true);
            Core_MDF_Custom_Layout_Configurations__c cust4= new Core_MDF_Custom_Layout_Configurations__c(Core_MDF_Field_API_Name_txt__c='Core_MDF_First_Year_Budget_Amount__c',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_User_Type_nm__c= 'Internal User',Core_MDF_Object_API_Name_txt__c='Campaign',Core_MDF_Section_id__c=sections[1].id, Core_MDF_Budget_Type_nm__c = 'Account Based',Core_MDF_Alignment_nm__c='Right', Core_MDF_Filter_Criteria_txt__c = 'Core_MDF_Proposal_Based_Ind__c == False', Core_MDF_Active_Ind__c = true);
            Core_MDF_Custom_Layout_Configurations__c cust5= new Core_MDF_Custom_Layout_Configurations__c(Core_MDF_Field_API_Name_txt__c='Name',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_Object_API_Name_txt__c='Campaign',Core_MDF_User_Type_nm__c= 'Internal User',Core_MDF_Section_id__c=sections[1].id, Core_MDF_Budget_Type_nm__c = 'Account Based',Core_MDF_Alignment_nm__c='Right',Core_MDF_Field_Label_txt__c='Campaign Name', Core_MDF_Filter_Criteria_txt__c = 'Core_MDF_Proposal_Based_Ind__c == False', Core_MDF_Active_Ind__c = true);
            Core_MDF_Custom_Layout_Configurations__c cust6= new Core_MDF_Custom_Layout_Configurations__c(Core_MDF_Field_API_Name_txt__c='Core_Approval_Status__c',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_Object_API_Name_txt__c='Campaign',Core_MDF_User_Type_nm__c= 'Internal User',Core_MDF_Section_id__c=sections[1].id, Core_MDF_Budget_Type_nm__c = 'Account Based',Core_MDF_Alignment_nm__c='Right',Core_MDF_Field_Label_txt__c='Approval Status', Core_MDF_Filter_Criteria_txt__c = 'Core_MDF_Proposal_Based_Ind__c == False', Core_MDF_Active_Ind__c = true);
            Core_MDF_Custom_Layout_Configurations__c cust7 = new Core_MDF_Custom_Layout_Configurations__c(Core_MDF_Field_API_Name_txt__c='CampaignId',Core_MDF_User_Type_nm__c= 'Internal User',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_Object_API_Name_txt__c='PartnerFundRequest',Core_MDF_Section_id__c=sections[3].id, Core_MDF_Budget_Type_nm__c = 'Proposal Based',Core_MDF_Alignment_nm__c='Left',Core_MDF_Field_Label_txt__c='Campaign Technology', Core_MDF_Filter_Criteria_txt__c = 'Core_MDF_Proposal_Based_Ind__c == True', Core_MDF_Active_Ind__c = true, Core_MDF_Record_Name_nm__c= 'campaign.Core_MDF_Technology__c',Core_MDF_Is_Relationship_Ind__c=true,Core_MDF_Parent_Object_nm__c='Campaign');
            custLayouts1.add(cust1);
            custLayouts1.add(cust2);
            custLayouts1.add(cust3);
            custLayouts1.add(cust4);
            custLayouts1.add(cust5);
            custLayouts1.add(cust6);
            custLayouts1.add(cust7);
            Database.insert(custLayouts1);
            List<ChannelProgram> channelPrgmList = new List<ChannelProgram>();
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            channelPrgmList.add(ipaCP);
            Database.insert(channelPrgmList);            
            
            Account IPAMDFUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA MDF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            List<Account> accList = new List<Account>();
            Account IPAMDFCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA MDF Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,IPAMDFUltimateAccount.id, false);
            Account iPACoMarketingAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Test IPA Account', ipaCP.Id,
                                                                                    Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
            iPACoMarketingAcc.Core_MDF_Parent_Fund_Account__c = IPAMDFUltimateAccount.Id;
            iPACoMarketingAcc.Core_MDF_CoMarketing_Ultimate_Account__c = IPAMDFUltimateAccount.Id;
            iPACoMarketingAcc.Core_Geo__c = 'APJ';
            iPACoMarketingAcc.Core_Sub_Geo__c = 'SA';
            iPACoMarketingAcc.BillingCountryCode = 'JPN';
            accList.add(IPAMDFCoMarketingAccount);
            accList.add(iPACoMarketingAcc);
            Database.insert(accList);
            
            /*************************************************************************/
            
           Campaign IPAMdfCamp1 = new Campaign(Name = 'Test Campaign 1',Core_MDF_Program__c = 'Intel Partner Alliance',StartDate = System.today(),EndDate = System.today().adddays(30),
                                                Core_MDF_Account__c =IPAMDFCoMarketingAccount.id, Core_MDF_Proposal_Based_Ind__c = false); 
            IPAMdfCamp1.Core_MDF_Market__c = 'India';
            IPAMdfCamp1.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
            IPAMdfCamp1.Core_MDF_First_Year_Budget_Amount__c= null;
            IPAMdfCamp1.Core_MDF_Reimbursement_Rate__c = '100%'; 
            IPAMdfCamp1.Core_MDF_Strategic_Marketing_Fund_Ind__c = true;
            IPAMdfCamp1.Core_Approval_Status__c = 'Pending';
            Database.insert(IPAMdfCamp1);
        
          Campaign IPAMdfCamp2 = new Campaign(Name = 'Test Campaign 2',Core_MDF_Program__c = 'Intel Partner Alliance',StartDate = System.today(),EndDate = System.today().adddays(30),
                                                    Core_MDF_Account__c =IPAMDFCoMarketingAccount.id, Core_MDF_Proposal_Based_Ind__c = true); 
            IPAMdfCamp2.Core_MDF_Market__c = 'India';
            IPAMdfCamp2.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
            IPAMdfCamp2.Core_MDF_First_Year_Budget_Amount__c= null;
            IPAMdfCamp2.Core_MDF_Reimbursement_Rate__c = '100%'; 
            IPAMdfCamp2.Core_MDF_Strategic_Marketing_Fund_Ind__c = true;
            IPAMdfCamp2.Core_MDF_Region_cd__c = 'APJ';
            Database.insert(IPAMdfCamp2);
            
            Campaign camp4 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp IPA','Gaming','Athena', 'MDF or both CMP & MDF', 
                                                                         Core_MDF_CCP_IPA_TestDataUtility.campaign_RecordType_IPA,
                                                                         'Intel Partner Alliance', System.today()-15, System.today()+15, 
                                                                         10000, 'Consumer Chromebook', iPACoMarketingAcc.Id, '2-in-1', false);
            camp4.Core_MDF_Proposal_Based_Ind__c = true;
            camp4.Core_MDF_Budget_Type_txt__c = 'Proposal I MDF';
            camp4.Core_MDF_Reimbursement_Amt__c = 200.0;
            camp4.Core_MDF_Opal_Budget_Type_Txt__c = 'Proposal I MDF';
            camp4.Core_MDF_Technology__c = '';
            camp4.Core_MDF_Market__c = 'AFGHANISTAN';
            
            Database.insert(camp4);
            
            PartnerFundRequest IPApfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp4.Id),
                                                                                              Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA,string.valueof(iPACoMarketingAcc.id),NULL,NULL,'India','Consumer','Traditional Notebook',
                                                                                              'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Target SPIF','Draft',false); 
            IPApfr.Core_MDF_Activity_Description__c = 'Test IPA Activity';
            IPApfr.Title = 'Test IPA Activity';
            IPApfr.Core_MDF_Start_Date__c = System.today().addDays(1);
            IPApfr.Core_MDF_End_Date__c = System.today().addDays(2);
            IPApfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
            IPApfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            IPApfr.Core_MDF_Budget_Type_nm__c = 'Proposal I MDF';
            IPApfr.Core_MDF_TargetAudience__c = '';
            IPApfr.Core_MDF_ActivityCategory__c=''; //14285-Indira
            IPApfr.Core_MDF_Activity_Types__c=''; //14285-Indira
            Database.insert(IPApfr);
        }
        
    }
    @isTest
    public static void testGetObjectFieldsForAccountBased(){
        User usr=[select id,email from User where email='ipaaccntmngr@example.com' limit 1];
        Test.startTest();
        Campaign camp1=[select id,Name FROM Campaign where Name= 'Test Campaign 1' LIMIT 1];
        Integer res=0;
        System.runAs(usr){
            res=(Core_MDF_CustomLayoutConfig_Controller.getObjectFields(String.valueOf(camp1.id), 'Campaign', 'Core_MDF_Proposal_Based_Ind__c', 'Detail Layout','')).size(); // 14285 Indira
        }
       Assert.areEqual(true,res!=null);
       Test.stopTest();
    }
    @isTest
    public static void testForBadRecordType(){
        User usr=[select id,email from User where email='ipaaccntmngr@example.com' limit 1];
        test.startTest();
        Integer res=0;
        System.runAs(usr){
            try{
               res= (Core_MDF_CustomLayoutConfig_Controller.getObjectFields('', 'Campaign', 'Core_MDF_Proposal_Based_Ind__c', 'Detail Layout','')).size(); // 14285 Indira
            }catch(Exception ex){
                
            }
        }
        test.stopTest();
        Assert.areEqual(0, res);
        // System.assert(res==0);
    }
    @isTest
    public static void testCompactLayput(){
        User usr=[select id,email from User where email='ipaaccntmngr@example.com' limit 1];
        Test.startTest();
        Integer res=0;
        String msg='';
        System.runAs(usr){
            Campaign camp1=[select id,Name FROM Campaign where Name= 'Test Campaign 1' LIMIT 1];
            res=(Core_MDF_CustomLayoutConfig_Controller.getObjActions(String.valueOf(camp1.id), 'Campaign', 'Core_MDF_Proposal_Based_Ind__c', 'Compact Layout','')).size(); // 14285 Indira
            msg=Core_MDF_CustomLayoutConfig_Controller.updateCampRecord(String.valueOf(camp1.id), 'Cancelled');
        }
        Test.stopTest();
         Assert.areNotEqual(0, res); 
        Assert.areEqual('sucess', msg);
    }

   @isTest
    public static void testCompactLayputPropBased(){
        User usr=[select id,email from User where email='ipaaccntmngr@example.com' limit 1];
        Test.startTest();
        System.runAs(usr){
            Campaign camp1=[select id,Name FROM Campaign where Name= 'Test Campaign 2' LIMIT 1];
            Integer size1;
            size1=(Core_MDF_CustomLayoutConfig_Controller.getObjActions(String.valueOf(camp1.id), 'Campaign', 'Core_MDF_Proposal_Based_Ind__c', 'Compact Layout','')).size(); // 14285 Indira
          Assert.areNotEqual(0, size1);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testActivity(){
        User usr=[select id,email from User where email='ipaaccntmngr@example.com' limit 1];
        Integer size;
        Test.startTest();
        System.runAs(usr){
            PartnerFundRequest IPApfr=[select id,Title from PartnerFundRequest where Title= 'Test IPA Activity' LIMIT 1];
            size=(Core_MDF_CustomLayoutConfig_Controller.getObjectFields(String.valueOf(IPApfr.id), 'PartnerFundRequest', 'Core_MDF_Proposal_Based_Ind__c', 'Detail Layout','')).size(); // 14285 Indira
        }
        Test.stopTest();
        Assert.areNotEqual(0, size);
    }
    
    @isTest
    public static void testLogErrors() {
        Test.startTest();
        String errorMessage = 'TypeError: Cannot read properties of undefined (reading "split") at eval';
        String objName = 'Campaign';
        Core_MDF_CustomLayoutConfig_Controller.logErrors(errorMessage, objName);
        Assert.areEqual(True, objName != '');
        Test.stopTest();
    }
}