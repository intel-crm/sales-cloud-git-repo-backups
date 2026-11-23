@isTest
public class Core_MDF_checkSObjectCRUDPermission_Test {

    @testSetup
    static void setup()
    { 
        
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
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
            
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
                        
            
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            Set<String> psNameSet = new Set<String> ();
            Map<string,String>  psNameVsIdMap = new Map<string,String>();
            psNameSet.add('Core_MDF_CCP_Internal_Co_GTM_Account_Manager');
            psNameSet.add('Core_MDF_CCP_Internal_Generic_Access');
            psNameVsIdMap = getPermissionSetIdbyName(psNameSet);
            String cogtmAcctMgrPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Co_GTM_Account_Manager');
            String genricAccessPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Generic_Access');
            User cogtmaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            cogtmaccntmngr.Email = 'cogtmaccntmngr@example.com';
            cogtmaccntmngr.Profile = ccpCoreAccessProfile;
            Database.insert(cogtmaccntmngr);
            
            List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
            psAssignList.add(new PermissionSetAssignment(AssigneeId = cogtmaccntmngr.id, PermissionSetId =cogtmAcctMgrPsId));   
            psAssignList.add(new PermissionSetAssignment(AssigneeId = cogtmaccntmngr.id, PermissionSetId =genricAccessPsId));   
            insert psAssignList;
                        
            ChannelProgram coGTMCP = Core_MDF_CCP_TestDataUtility.createProgram ('Co-GTM','CoGTM', true);
            
            List<Account> accList = new List<Account>();
            Account accIntel = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Account coGTMCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account Co-GTM', coGTMCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
            coGTMCoMarketingAccount.Core_MDF_Parent_Fund_Account__c = accIntel.Id;
            coGTMCoMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c = accIntel.Id;
            Database.insert(coGTMCoMarketingAccount);
            coGTMCoMarketingAccount.IsPartner = true;
            accList.add(coGTMCoMarketingAccount);
            
            Id pmb_RecordType_CoGTM = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id pfa_RecordType_CoGTM = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id campaign_RecordType_CoGTM = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id pfr_RecordType_CoGTM = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            
            PartnerMarketingBudget  coGTMPMB = Core_MDF_CCP_TestDataUtility.createBudget('CoGTMPMB', pmb_RecordType_CoGTM, coGTMCoMarketingAccount.Id, coGTMCP.Id, 1000000, System.today().addDays(-10), System.today().addDays(40),false);
            coGTMPMB.Core_MDF_Budget_Type_Txt__c = 'Co-Engineering';
            insert coGTMPMB;
            
            PartnerFundAllocation coGTMPFA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('CoGTMPFA',coGTMPMB,coGTMCoMarketingAccount,100000.0,true);
            
            Campaign coGTMCampaign = new Campaign();
            coGTMCampaign.Name = 'Test CoGTM Camp';
            coGTMCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Co-Engineering';
            coGTMCampaign.Core_MDF_Proposal_Based_Ind__c = true;
            coGTMCampaign.Core_MDF_Program__c = 'CoGTM';
            coGTMCampaign.Status = 'Draft';
            coGTMCampaign.Core_MDF_Account__c = coGTMCoMarketingAccount.id;
            coGTMCampaign.RecordTypeId = campaign_RecordType_CoGTM;
            coGTMCampaign.StartDate = System.today().addDays(-5);
            coGTMCampaign.EndDate = System.today().addDays(15);
            coGTMCampaign.Core_MDF_Reimbursement_Amt__c = 1000200;
            coGTMCampaign.Core_MDF_Activity_Category_Type__c = 'Innovation ->Engineering';
            Database.insert(coGTMCampaign);
            
            PartnerFundRequest coGTMPFR = new PartnerFUndRequest();
            coGTMPFR.CampaignId=coGTMCampaign.id;
            coGTMPFR.RecordTypeId = pfr_RecordType_CoGTM;
            coGTMPFR.ChannelPartnerId = coGTMCoMarketingAccount.id;
            coGTMPFR.Core_MDF_ActivityCategory__c='Innovation';
            coGTMPFR.Core_MDF_Activity_Types__c='Engineering';
            coGTMPFR.Core_MDF_Start_Date__c=System.today().addDays(-5);
            coGTMPFR.Core_MDF_End_Date__c =System.today().addDays(2);
            coGTMPFR.Title ='Test CoGTM PFR';
            coGTMPFR.Status = 'Draft';
            coGTMPFR.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            coGTMPFR.RequestedAmount = 1000200;
            coGTMPFR.AllocationId = coGTMPFA.Id;
            coGTMPFR.BudgetId = coGTMPMB.Id;
            Database.insert(coGTMPFR);
        }
        
    }
    
    static Map<string,String> getPermissionSetIdbyName(Set<String> psNameSet){
        Map<string,String>  resultMap = new Map<string,String>();
        for(permissionSet ps: [SELECT Id , Name FROM PermissionSet WHERE Name IN:psNameSet]){
             resultMap.put(ps.Name, ps.Id);
            
        }
    	return resultMap;
    }
    
    @isTest
    static void testCreatePermission(){
        Boolean result1=false;
        User usr = [select id,email from User where email='cogtmaccntmngr@example.com' limit 1];
        test.startTest();
        System.runAs(usr){
            String objectName = 'PartnerFundRequest';
            result1 = Core_MDF_checkSObjectCRUDPermission.checkSObjectCreatePermission(objectName);
        }
        test.stopTest();
        Assert.areEqual(true, result1);
    }

    @isTest 
    static void testEditPermission(){
        Boolean result2=false;
        test.startTest();
        User usr = [select id,email from User where email='cogtmaccntmngr@example.com' limit 1];
        System.runAs(usr){
            String objectName = 'PartnerFundRequest';
            result2 = Core_MDF_checkSObjectCRUDPermission.checkSObjectEditPermission(objectName); 
           }
        test.stopTest();
        Assert.areEqual(true, result2);
        
    }
    
    @isTest 
    static void testDeletePermission(){
        Boolean result2=false;
        test.startTest();
        User usr = [select id,email from User where email='cogtmaccntmngr@example.com' limit 1];
        System.runAs(usr){
            String objectName = 'PartnerFundRequest';
            result2 = Core_MDF_checkSObjectCRUDPermission.checkSObjectDeletePermission(objectName);  
        }
        test.stopTest();
        Assert.areEqual(true, result2);
    }
    
    @isTest
    static void loadActivityRecordTest(){
        test.startTest();
        User usr = [select id,email from User where email='cogtmaccntmngr@example.com' limit 1];
        PartnerFundRequest pfrRecord;
        System.runAs(usr){
            PartnerFundRequest pfrNew=[Select id,Title from PartnerFundRequest where Title = 'Test CoGTM PFR'];
            pfrRecord=Core_MDF_checkSObjectCRUDPermission.loadActivityRecord(pfrNew.Id);
        }
        test.stopTest();
        Assert.areEqual(true, pfrRecord.Core_MDF_Proposal_Based_Ind__c);
      }
        
    @isTest 
    static void testgetActivityRecordTypeDevname(){
     	test.startTest();
        User usr = [select id,email from User where email='cogtmaccntmngr@example.com' limit 1];
        String result;
        PartnerFundRequest pfrNew=[Select id,Title from PartnerFundRequest where Title = 'Test CoGTM PFR'];
        System.runAs(usr){
			
           result=Core_MDF_checkSObjectCRUDPermission.getActivityRecordTypeDevname(pfrNew.Id);
        }
       	test.stopTest();
        Assert.areEqual('Core_MDF_Co_GTM', result);
      }
    @isTest
    static void getActRecordTypeDevNamePropIndTest(){
        
        Map<String, boolean> result=new Map<String, boolean>();
        test.startTest();
        User usr = [select id,email from User where email='cogtmaccntmngr@example.com' limit 1];
        PartnerFundRequest pfrNew=[Select id,Title from PartnerFundRequest where Title = 'Test CoGTM PFR'];
        System.runAs(usr){
			result=Core_MDF_checkSObjectCRUDPermission.getActRecordTypeDevNamePropInd(pfrNew.Id);            
        }
        test.stopTest();
        Assert.isTrue(result.containsKey('Core_MDF_Co_GTM'));
    }
    
    @isTest 
    static void loadActivityRecordNegative(){
        Boolean result=false;
        test.startTest();
        User usr = [select id,email from User where email='cogtmaccntmngr@example.com' limit 1];
        PartnerFundRequest pfrNew=[Select id,Title from PartnerFundRequest where Title = 'Test CoGTM PFR'];
        System.runAs(usr){
           try{
                Core_MDF_checkSObjectCRUDPermission.loadActivityRecord(null);
            }catch(Exception e){
                system.assert(e!=null);
            }
   		}
        test.stopTest();
   }
   
    @isTest 
    static void getActivityRecordTypeDevnameNegative(){
        test.startTest();
        User usr = [select id,email from User where email='cogtmaccntmngr@example.com' limit 1];
        System.runAs(usr){
          try{
                Core_MDF_checkSObjectCRUDPermission.getActivityRecordTypeDevname(null);
            }catch(Exception e){
                system.assert(e!=null);
            }
   		}
        test.stopTest();
    }
   
    @isTest 
    static void testcheckForEditAccess(){
        Boolean hasAccess=false;
        test.startTest();
        User usr = [select id,email from User where email='cogtmaccntmngr@example.com' limit 1];
        PartnerFundRequest pfrNew=[Select id,Title from PartnerFundRequest where Title = 'Test CoGTM PFR'];
        System.runAs(usr){
            hasAccess=Core_MDF_checkSObjectCRUDPermission.checkForEditAccess('PartnerFundRequest', 'Core_MDF_Co_GTM', 'Planned', pfrNew.Id, true, System.today());
            Core_MDF_checkSObjectCRUDPermission.checkRecordEditAccess(pfrNew.id);
            
        }
        test.stopTest();
        Assert.areEqual(false, hasAccess);
    }
     
    @isTest
    static void testReadPermission(){
        Boolean result1=false;
        test.startTest();
        User usr = [select id,email from User where email='cogtmaccntmngr@example.com' limit 1];
        System.runAs(usr){
            String objectName = 'Core_MDF_PIC_Review__c';
            result1 = Core_MDF_checkSObjectCRUDPermission.checkSObjectReadPermission(objectName);
        }
        test.stopTest();
        Assert.areEqual(true, result1);
    }
}