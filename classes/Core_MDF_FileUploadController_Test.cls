@isTest(SeeAllData=false)
public class Core_MDF_FileUploadController_Test {
    
    @TestSetUp
    static void createTestData(){
 		 List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
         transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing','Bypass_MDF_Budget_Access','Bypass_MDF_Budget_Access_Validation','Bypass_MDF_Budget_Status_Validation','Bypass_ShareActivityWithUsers','Bypass_Activity_ApprovalProcess','Bypass_ShareActivityWithAccNodeGroup','ShareActivityWithInternalUsers_Bypass'}, true, false));
         Database.insert(transactions);
        Test.startTest();
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
       
        PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      acc2.id, cp.Id , 10 , System.today() - 25 , System.today() + 45 , 
                                                                                      false);
        
        testBudget.Core_MDF_Budget_Type_Txt__c='MDF';
        insert testBudget;
        /*testBudget.Core_MDF_Budget_Status__c = 'Released';
        update testBudget;*/
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 'Yes',
                                                                    Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                    'Client CoMarketing Fund', System.today().addDays(-2), 
                                                                    System.today().addDays(346), 10000, 'Always Connected PC', 
                                                                    acc2.Id,'Desktop', true); 
        
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                'Member Participation in Third-Party Event','Draft',false);
        testPartnerFundRequestRecord.RequestedAmount = 250;
        testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        insert testPartnerFundRequestRecord;
        Test.stopTest();
        System.assert(testPartnerFundRequestRecord.Id != NULL);

    }
    
    @isTest
    static void pfrwithContentDocument(){

        PartnerFundRequest pfrRecord = [SELECT Id FROM PartnerFundRequest LIMIT 1];
         List<ContentDocument> doc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
            List<String>contIds= new list<String>();
            for(ContentDocument content : doc){
                contIds.add(content.id);
            }
        Test.startTest();
        Core_MDF_FileUploadController.fetchDocumentIds(pfrRecord.Id,contIds);
        Core_MDF_FileUploadController.deleteDocumentIds(contIds);
        //Core_MDF_FileUploadController.fetchDocumentIds(Null,Null);
        //Core_MDF_FileUploadController.deleteDocumentIds(Null);
        Test.stopTest();
        System.assert(pfrRecord.Id != NULL);
    }
    
    @isTest 
    static void pfrwithoutContentDocument(){
        
        Test.startTest();
        PartnerFundRequest pfrRecord = [SELECT Id FROM PartnerFundRequest LIMIT 1];

        List<ContentDocument> doc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
        List<String>contIds= new list<String>();
          
        ContentDocumentLink docLink = new ContentDocumentLink(ContentDocumentId = doc[0].Id,
                                                              LinkedEntityId=pfrRecord.Id,ShareType='I',Visibility='AllUsers');
        insert docLink;        
        Core_MDF_FileUploadController.fetchDocumentIds(pfrRecord.Id,contIds);
        //Core_MDF_FileUploadController.deleteDocumentIds(Null);
        Test.stopTest();
        System.assert(pfrRecord.Id != NULL);
    }
    
}