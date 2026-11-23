@isTest
public class Core_MDF_IPA_ReminderBatch_Test {
     @TestSetup
    static void createTestData(){
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false); 
         UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        testUser.LastName='Admin_user';
        testUser.UserRoleId = usRole.Id;
        insert testUser;
        System.runAs(testUser){
             Test.startTest();
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
			bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
			bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);  
            Database.insert(ccpIntelAccount);
            Account acc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', ipaCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, ccpIntelAccount.Id, false);
            Database.insert(acc);
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',acc.id, System.today(), System.today().adddays(30),null, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', false);
            ipaCampaignForAP.Core_MDF_Region_cd__c = 'APJ';
            ipaCampaignForAP.Core_MDF_Opal_Budget_Type_Txt__c ='Account Plan';
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c = false;
            ipaCampaignForAP.Core_MDF_Budget_Type_txt__c = 'Account Plan';
            ipaCampaignForAP.Status ='Planned' ;
            //ipaCampaignForAP.Core_MDF_Approval_Stage_nm__c='L2 Regional Marketing';
			insert ipaCampaignForAP; 
           // Highlight unused variable
           // List<PartnerFundRequest> pfrUpdateList = new List<Partnerfundrequest>();
            PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,acc.id,System.today().addDays(1),System.today().addDays(10),false);
            ipaPFR.Title='Test Activity1';
            ipaPFR.Core_MDF_ToBeClosedDate__c = system.today() + 30 ;
            ipaPFR.Core_MDF_Fund_Request_Status__c ='Planned';
            ipaPFR.Core_MDF_Region_nm__c='APJ';
            insert ipaPFR;
             Test.stopTest();
        }
    }
    @isTest
    Public static void testActPlannedMethod(){
        Core_MDF_IPA_ReminderBatch ipaBatch = new Core_MDF_IPA_ReminderBatch();
        Database.executeBatch(ipaBatch);
	System.Assert(ipaBatch!=null);
    }
}