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
       ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
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
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        
        List<User> listUser = new List<User>();
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = listContact[0].Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        listUser.add(usr1);
        //Database.insert(usr1);
        
       
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='test123@example.com';
        usr2.ContactId = listContact[1].Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
        listUser.add(usr2);
        //Database.insert(usr2);
        
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.Email = 'sysadmin@example.com';
        listUser.add(usr3);
        //Database.insert(listUser);
        
        //Login as claim claim Case reviewer
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User ccrUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccrUser.Email='testCCR@example.com';
        ccrUser.ProfileId = p.id;
        listUser.add(ccrUser);
        Database.insert(listUser);        
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,200000,System.today() -20,System.today().addDays(40), true);
        
        budget.IsIgnoreValidation = true;
        update budget;
        
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,200.0,true);
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', true); 
        
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
        insert testPartnerFundRequest;
        system.assert(testPartnerFundRequest.Core_MDF_Country_nm__c == 'India');
        Core_MDF_CustomMultiSelectPicklist.fetchmultipicklist('PartnerFundRequest', 'Core_MDF_Country_nm__c', testPartnerFundRequest.Id);
        Core_MDF_CustomMultiSelectPicklist.fetchmultipicklist('PartnerFundRequest', 'Core_MDF_Country_n__c ', null);
        
    }
        
}