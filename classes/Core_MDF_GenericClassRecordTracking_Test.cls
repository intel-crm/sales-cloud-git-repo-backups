@isTest(SeeAllData=false)
public class Core_MDF_GenericClassRecordTracking_Test {
    @isTest
    static void insertingTrackRec(){
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        List<User> usrList=new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'TestUser123';
        usr.profileId = systemAdminProfile.Id;
        usrList.add(usr);
        Database.insert(usrList);
        System.runAs(usr){
        
        List<String> bypassFunctionKeys = new List<String>();
            //adding bypass feature to bypass access validation
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
        Account accIntel = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account accCoMarketing = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        accCoMarketing.Core_MDF_Parent_Fund_Account__c = accIntel.Id;
        
        
        accCoMarketing.Core_MDF_CoMarketing_Ultimate_Account__c = accIntel.Id;
        Database.insert(accCoMarketing);
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-15, System.today()+15, 10000, 'Consumer Chromebook', accCoMarketing.Id, '2-in-1', true);
        
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','','Draft',true);
           
        Test.startTest();
        
        Core_MDF_Generic_Class_Record_Tracking.insertingTrackRecord(pfr.Id,'PartnerFundRequest','Activity Approval By Mobile');
        // US - TWC702-14285: Unit Test Method should include System.Assert
        Assert.isNotNull(pfr.Id, 'PartnerFundRequest Id should not be null after insert');
        Test.stopTest();
        }
        
    }
}