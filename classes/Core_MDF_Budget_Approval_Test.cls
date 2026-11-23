@isTest
public class Core_MDF_Budget_Approval_Test {
    public static Map<string,Id> psNameToIdMap = new Map<string,Id>();
    //setup method to create test data
    @TestSetup static void setUpData(){
        List<User> usrList = new List<User>();
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.LastName='Admin';
        usr.profileId = systemAdminProfile.Id;
        usr.IsActive = true;
        usrList.add(usr);
        Database.insert(usrList);
        System.runAs(usr){
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
            cpList.add(cp);
            Database.insert(cpList);
            List<Account> intAccList = new List<Account>();
            // Creating Intel Account with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account', cp.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            acc1.BillingCity = 'Test City';         
            acc1.BillingCountry= 'AUS';
            acc1.BillingStreet= 'Test Street';
            intAccList.add(acc1);
            Database.insert(intAccList);
            Test.startTest();
            // Creating Co-marketing Account with utility class
            List<Account> accList = new List<Account>();
            Account acc3 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 3', cp.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
            acc3.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accList.add(acc3);
            
            Account acc4 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 4', cp.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
            acc4.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accList.add(acc4);
            Database.insert(accList);
            
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Core_MDF_OpalBudgetValidation');
            bypassFunctionKeys.add('Bypass_AccountOnboardOPIDValidations');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
            
            Test.stopTest();
            List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            system.runAs(usr){
                List<String> psList = new List<String>{'Core_MDF_CCP_Internal_Finance_Usr','Core_MDF_CCP_Internal_CCF_User','Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader','Core_MDF_CCP_Internal_Channel_MDF_Budget_Loader','Core_MDF_CCP_Internal_IPA_Budget_Loader','Core_MDF_CCP_Internal_Finance_Manager','Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver'};
                    for(PermissionSet ps : [SELECT Id,Name FROM PermissionSet WHERE Name IN: psList]){
                        psNameToIdMap.put(ps.Name, ps.Id);
                    }
                List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = usr.id;
                psa.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader');
                psaList.add(psa);
                PermissionSetAssignment psa1 = new PermissionSetAssignment();
                psa1.AssigneeId = usr.id;
                psa1.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_Finance_Usr');
                psaList.add(psa1);
                PermissionSetAssignment psa2 = new PermissionSetAssignment();
                psa2.AssigneeId = usr.id;
                psa2.PermissionSetId = psNameToIdMap.get('Core_MDF_CCP_Internal_CCF_User');
                psaList.add(psa2);
                Database.insert(psaList);
                
            }
            System.runAs(usr){
                PartnerMarketingBudget pmbRecordtobeUpdated = Core_MDF_CCP_TestDataUtility.createBudget('TestPMBMDF',RecordTypeIdPMB,acc3.Id,cp.Id,1000,System.today().addDays(2),System.today().addDays(8),false);
                pmbRecordtobeUpdated.Core_MDF_Budget_Type_Txt__c = 'MDF';
                insert pmbRecordtobeUpdated;
                /* PartnerMarketingBudget pmbRecordtobeUpdated1 = Core_MDF_CCP_TestDataUtility.createBudget('TestPMBMDF New',RecordTypeIdPMB,acc3.Id,cp.Id,1000,System.today().addDays(16),System.today().addDays(21),false);
                pmbRecordtobeUpdated1.Core_MDF_Budget_Type_Txt__c = 'MDF';
                insert pmbRecordtobeUpdated1; */
            }
        }
    }
    
    @isTest
    public static void loadBudgetecordTest(){
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account acc1 = [SELECT Id from Account where Name='Test Account 4' limit 1];
        ChannelProgram cpMDF = [Select id from ChannelProgram where Name='Client' limit 1];
        Test.startTest();
        PartnerMarketingBudget  pmbRecordtobeUpdated = new PartnerMarketingBudget();
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            PartnerMarketingBudget pmb = [Select id,OwnerId,Core_MDF_Budget_Status__c from PartnerMarketingBudget limit 1];
            system.assertEquals('Pending Review', pmb.Core_MDF_Budget_Status__c);
            Core_MDF_Budget_Approval.UserPermissionApproval userPA= Core_MDF_Budget_Approval.loadBudgetecord(pmb.id);
            Core_MDF_Budget_Approval.approveRejectBudget(userPA);
            userPA.btnAction = 'Approve';
            userPA.btnActionComment = 'Approved By Budget Approver';
            Core_MDF_Budget_Approval.approveRejectBudget(userPA);
            System.runAs(usr){
            /*PartnerMarketingBudget  pmbRecordtobeUpdated1 = new PartnerMarketingBudget();
            pmbRecordtobeUpdated1 = Core_MDF_CCP_TestDataUtility.createBudget('TestPMBMDF New',RecordTypeIdPMB,acc1.Id,cpMDF.Id,2000,System.today().addDays(16),System.today().addDays(21),false);
            pmbRecordtobeUpdated1.Core_MDF_Budget_Type_Txt__c = 'MDF+';
            insert pmbRecordtobeUpdated1;*/
            PartnerMarketingBudget pmb1 = [Select id,Core_MDF_Budget_Status__c from PartnerMarketingBudget limit 1];
            Core_MDF_Budget_Approval.UserPermissionApproval userPA1= Core_MDF_Budget_Approval.loadBudgetecord(pmb1.id);
            userPA1.btnAction = 'Approve';
            userPA1.btnActionComment = 'Approved By Budget Approver';
            Core_MDF_Budget_Approval.approveRejectBudget(userPA1);
        }
        Test.stopTest();
    }
    @isTest
    static void handleException(){  
        User usr1 = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        test.startTest();
        Core_MDF_Budget_Approval.UserPermissionApproval res=new Core_MDF_Budget_Approval.UserPermissionApproval();
        String errorMsg='';
        System.runAs(usr1){
            try{
                Core_MDF_Budget_Approval.loadBudgetecord(null);
                Core_MDF_Budget_Approval.approveRejectBudget(null);
                res=Core_MDF_Budget_Approval.loadBudgetecord('123');
            }
            catch(Exception ex){
                errorMsg=ex.getMessage();
            }
        }
        test.stopTest();
    }
}