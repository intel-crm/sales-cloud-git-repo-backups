/***************************************************************************************************** 
Class Name :    Core_Intel_customLookupController_Test
Description:    This is the test class for Core_Intel_customLookupController class
Added By   :    Accenture - SKS 
Modified By:                      Date:07/31/2018                     Changes:None  
******************************************************************************************************/    
@isTest
public class Core_Intel_customLookupController_Test
{
   
    @isTest
    private static void testfetchLookUpValues()
    {
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);

        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(2), System.today().addDays(346), 10000, 'Always Connected PC',acc2.Id,'Laptop',false); 
        camp.Core_MDF_External_Visibility_Date__c= System.today();
        insert camp;
              
        String searchKeyWord ='Test Camp 12',  objectName='Campaign', sAdditionalFilter='startDate=2019-01-01';
        List < sObject > result = Core_Intel_customLookupController.fetchLookUpValues (searchKeyWord,objectName,sAdditionalFilter);
                     
        System.assert(result != null);
    } 
    
    @isTest
    private static void testfetchLookUpValues1()
    {
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(2), System.today().addDays(346), 10000, 'Always Connected PC',acc2.Id,'Laptop',false); 
        camp.Core_MDF_External_Visibility_Date__c= System.today();
        insert camp;

        Test.startTest();
        Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
        con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
        insert con;
        
        Test.stopTest();
        System.debug('Limit.getQueries():'+Limits.getQueries());
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner'];
        
        // Creating User with utility class 
       
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test2';
        usr2.ProfileId = partnerProfile.Id;
        usr2.ContactId = con.Id;
        usr2.portalRole = 'Manager';

        insert usr2;
        
        system.runAs(usr2){
            List < sObject > result = Core_Intel_customLookupController.fetchLookUpValues ('Test Camp 12', 'Campaign',' startDate=2018-07-25');
            System.assert(result != null);
            result = Core_Intel_customLookupController.fetchLookUpValues ('Test Account 3', 'Account',' Name!=null ');
        }
    }

    @isTest
    private static void testfetchLookUpValues2()
    {
        // Creating channel program with utility class
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
       
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
             
        String searchKeyWord ='Dell CCF Virtual Corp',  objectName='Account', sAdditionalFilter='isPartner=true';
        List < sObject > result = Core_Intel_customLookupController.fetchLookUpValues (searchKeyWord,objectName,sAdditionalFilter);
        System.assert(result != null);
        result = Core_Intel_customLookupController.fetchLookUpValues ('Test','User','IsActive=true');
    } 
    
    @isTest
    private static void testfetchLookUpValues3()
    {
        // Creating channel program with utility class
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
       
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 5', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 6', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);

        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 15','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(2), System.today().addDays(346), 10000, 'Always Connected PC',acc2.Id,'Laptop',false); 
        camp.Core_MDF_External_Visibility_Date__c= System.today();
        insert camp;
              
        String searchKeyWord ='Test Camp 13',  objectName='Campaign', sAdditionalFilter='';
        List < sObject > result = Core_Intel_customLookupController.fetchLookUpValues (searchKeyWord,objectName,sAdditionalFilter);
                     
        System.assert(result != null);
    }
}