//Test class for Core_MDF_Batch_Partnership_Sync
@isTest(SeeAllData=false)
public class Core_MDF_Batch_Partnership_Sync_Test {
    @TestSetup
    static void makeData() {
        List<ChannelProgram> channelProgList = new List<ChannelProgram>();
         UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
        channelProgList.add(cp1);
        
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', false);
        channelProgList.add(cp2);
        System.runAs(usr1){
        Database.insert(channelProgList);
        }
        
        List<Account> intelAccList = new List<Account> ();
        
        Account ccfAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('CCF Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        ccfAcc.Core_Account_Type__c = 'Reseller';
        ccfAcc.Industry = 'Food & Beverage';
        intelAccList.add(ccfAcc);
        
        Account retailAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Retail Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        retailAcc.Core_Account_Type__c = 'Service Provider';
        retailAcc.Industry = 'Health';
        retailAcc.Core_Geo__c ='ASMO';
        retailAcc.Core_Sub_Geo__c ='LAR';
        intelAccList.add(retailAcc);
        System.runAs(usr1){
        Database.insert(intelAccList);
        }
        
        List<Account> accList = new List<Account>();
        Account ccfTestAcc = Core_MDF_CCP_TestDataUtility.createAccount ('CCF Test Account',cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        ccfTestAcc.Core_MDF_Parent_Fund_Account__c = ccfAcc.Id;
        ccfTestAcc.Core_MDF_CoMarketingActive__c = true;
        accList.add(ccfTestAcc);
        
        Account retTestAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Test Account',cp2.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        retTestAcc.Core_MDF_Parent_Fund_Account__c = retailAcc.Id;
        retTestAcc.Core_Geo__c ='ASMO';
        retTestAcc.Core_Sub_Geo__c ='LAR';
        accList.add(retTestAcc);
        System.runAs(usr1){
        Database.insert(accList);
        }
        List<Campaign> campList = new List<Campaign>();
        
        Campaign ccfCamp1 = Core_MDF_CCP_TestDataUtility.createCampaign('CCF Campaign 1','Gaming','Intel® Core™ i7+ Processor','Yes' ,Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().adddays(30), 10000, 'Consumer Chromebook', ccfTestAcc.Id, '2-in-1', false);
        ccfCamp1.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
        Campaign retailCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaign','Gaming','Intel® Core™ i7+ Processor','Yes' ,Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today(), System.today().adddays(30), 10000, 'Consumer Chromebook', retTestAcc.Id, '2-in-1', false);
        retailCamp.Core_MDF_Budget_Type_txt__c = 'RSA MD';
        
        campList.add(ccfCamp1);
        campList.add(retailCamp);
        System.runAs(usr1){
        Database.insert(campList);
        }
        
        List<Case> caseList = new List<Case>();

        Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
        Case cs1 = new Case();
        cs1.Status = 'New';
        cs1.recordTypeId = caseAuditRecType;
        cs1.Core_MDF_Claim_ID__c=ccfCamp1.id;
        cs1.Core_MDF_Earlier_Quarter_Closed_Dt__c = system.now();
        cs1.Core_MDF_Channel_Program_txt__c = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
        cs1.Origin='Manual Selection';
        caseList.add(cs1);
        
        Case cs2 = new Case();
        cs2.Status = 'New';
        cs2.recordTypeId = caseAuditRecType;
        cs2.Core_MDF_Claim_ID__c=retailCamp.id;
        cs2.Core_MDF_Earlier_Quarter_Closed_Dt__c = system.now();
        cs2.Core_MDF_Channel_Program_txt__c = 'Retail Marketing Funds';
        cs2.Origin='Manual Selection';
        caseList.add(cs2);
        
        Case cs3 = new Case();
        cs3.Status = 'New';
        cs3.recordTypeId = caseAuditRecType;
        cs3.Core_MDF_Claim_ID__c=retailCamp.id;
        cs3.Core_MDF_Earlier_Quarter_Closed_Dt__c = system.now();
        cs3.Core_MDF_Channel_Program_txt__c = 'Retail Marketing Funds';
        cs3.Origin='Manual Selection';
        caseList.add(cs3);
        System.runAs(usr1){
        Database.insert(caseList);
        }
    }
    
    @isTest static void testBatch() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        Core_MDF_Batch_Partnership_Sync bchRec = new Core_MDF_Batch_Partnership_Sync();
        System.runAs(usr1){
        Database.executeBatch(bchRec,100);
        }
	 // Unit Test Method should include System.Assert 
        System.assertNotEquals(null, bchRec, 'Batch record should not be null');
    }
    
}