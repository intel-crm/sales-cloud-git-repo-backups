/***************************************************************************************************** 
Class Name :    Core_MDF_CustomMultiSelectPicklist_test
Description:    This is the test class for Core_MDF_CustomMultiSelectPicklist APEX class
Added By   :    Vivek 
Modified By:                      Date:09/13/2019                     Changes:None  
******************************************************************************************************/

@isTest
public class Core_MDF_CustomMultiSelectPicklist_test {

    static testmethod void getMultiselectOptionstest() 
    {	
        List<User> listUser = new List<User>();
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'TestUser123';
        usr.profileId = systemAdminProfile.Id; 
        listUser.add(usr);
        Database.insert(listUser);
        system.runAs(usr){
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            insert acc1;
            acc1.Core_MDF_CoMarketingActive__c = true;
            update acc1;
            
            List<Contact> listContact = new List<Contact>();
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
            Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
            
            listContact.add(conRecord1);
            listContact.add(conRecord2);
            
            Database.insert(listContact);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
           
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance1.Id);
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,200000,System.today() -20,System.today().addDays(40), false);
            budget.Core_MDF_Budget_Type_Txt__c='OEM CMP';
            insert budget;
            budget.IsIgnoreValidation = true;
            update budget;
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,200.0,true);
            //added SupportslegacyProgram='Yes'
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', true); 
            
            PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                            String.valueof(acc2.id),allocation,null,'INDIA',
                                                                                            'Consumer',
                                                                                            'Desktop',
                                                                                            'Intel® Core™ i7+ Processor',
                                                                                            'Broadcast',
                                                                                            'Podcast',
                                                                                            'Draft',
                                                                                             false);
                                                                                                  
            
            testPartnerFundRequest.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequest.Core_MDF_End_Date__c  = system.today();
            testPartnerFundRequest.Core_MDF_Country_nm__c = 'India';
            testPartnerFundRequest.Core_MDF_ActivityCategory__c='';
            testPartnerFundRequest.Core_MDF_Activity_Types__c='';
            insert testPartnerFundRequest;
            Assert.areEqual('India', testPartnerFundRequest.Core_MDF_Country_nm__c);
            Core_MDF_CustomMultiSelectPicklist.fetchmultipicklist('PartnerFundRequest', 'Core_MDF_Country_nm__c', testPartnerFundRequest.Id);
            Core_MDF_CustomMultiSelectPicklist.fetchmultipicklist('PartnerFundRequest', 'Core_MDF_Country_n__c ', null);
        }
    }
        
}