@isTest
private class Core_MDF_EmailTemplateTranslation_Test{
  @isTest
    static void allMethodTest(){
        Profile itAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = itAdminProfile.Id;
        insert usr;
        
        System.runAs(usr){
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            //Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 211', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, true);
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);

            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(2), System.today().addDays(346), 10000, 'Always Connected PC', acc2.Id,'Desktop', true); 

            PartnerFundRequest testPartnerFundRequestObj = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),
                                                                                                                       Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                                       string.valueof(acc2.id),
                                                                                                                       NULL,NULL,'ALBANIA','Consumer',
                                                                                                                       'Desktop','Intel® Corporate Logo',
                                                                                                                       NULL,NULL,
                                                                                                                       'Draft',false,true,
                                                                                                                       'Others','Test Other CP');
            testPartnerFundRequestObj.RequestedAmount=100000000;
            testPartnerFundRequestObj.Core_MDF_ActivityCategory__c='Broadcast';
            testPartnerFundRequestObj.Core_MDF_Activity_Types__c='Podcast';         
            testPartnerFundRequestObj.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            insert testPartnerFundRequestObj;
          
            String result = Core_MDF_EmailTemplateTranslation.getActivityType();
            result = Core_MDF_EmailTemplateTranslation.getActivityRecordTypeName();
            result = Core_MDF_EmailTemplateTranslation.getActivityPriorStatus();
            result = Core_MDF_EmailTemplateTranslation.getActivityStatus();
            
            Core_MDF_EmailTemplateTranslation.activityId = testPartnerFundRequestObj.Id;
            result = Core_MDF_EmailTemplateTranslation.getActivityType();
            result = Core_MDF_EmailTemplateTranslation.getActivityRecordTypeName();
            result = Core_MDF_EmailTemplateTranslation.getActivityPriorStatus();
            result = Core_MDF_EmailTemplateTranslation.getActivityStatus(); 

            System.assert(result != null);        
        }      
    }
}