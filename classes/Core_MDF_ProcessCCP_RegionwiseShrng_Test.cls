/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_RegionwiseShrng_Test 
* Version     : 1.0 
* Created Date: 9-06-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Harika P        9/06/2018                    Created to test campaign related object records once campaign is modified or inserted. 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ProcessCCP_RegionwiseShrng_Test {
    /****************************************************************************************************************************************
Method Name:                                   createCampaignRecords
Description:                                   Creating sharing records of Core_MDF_Regionwise_Campaign_Budget__c to test it for external users 
Added By:                                      Accenture – Harika P  -  9/06/2018
Modified By:                  Date:            Changes: 
Accenture – Harika P        9/06/2018          Created.
*****************************************************************************************************************************************/
    @isTest static void createCampaignRecords(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        UserRole ur = [Select Id, Name From UserRole WHERE Name = 'Admin' LIMIT 1];
        usr.UserRoleId =ur.Id ;
        usr.profileId = sysAdminProfile.Id;
        Database.insert(usr);
        System.runAs(usr){
            
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intacc.Core_Account_Type__c = 'Reseller';
            intacc.Core_Sales_Groups__c = 'Automotive Sales Group';
            intacc.Industry = 'Food & Beverage';
            intacc.Core_MDF_Channel_Program__c = cp.Id;
            Database.insert(intacc);
            
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', 
                                                                      cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
            Database.insert(acc);
            
            Test.startTest();
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('CCFTestCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today().addDays(5) , 
                                                                        System.today().addDays(120), 2000, 'Unite', acc.Id,'2-in-1', true);
            list<Core_MDF_Regionwise_Campaign_Budget__c> rWise = Core_MDF_CampGridController.regionalData(camp.Id);
            for(Core_MDF_Regionwise_Campaign_Budget__c rcb : rWise){
                System.assert(camp.Core_MDF_Market__c.contains(rcb.Core_MDF_Region__c));
            }  
            
            // Update CCF Campaign
            camp.Core_MDF_Market__c = 'INDIA;INDONESIA';
            Database.update(camp);
            rWise = Core_MDF_CampGridController.regionalData(camp.Id);
            Core_MDF_CampGridController.SaveRegionWiseData(rWise);
            for(Core_MDF_Regionwise_Campaign_Budget__c rcb : rWise){
                System.assert(camp.Core_MDF_Market__c.contains(rcb.Core_MDF_Region__c));
            }
            
            // Creating campaigns when Start Date and End Date are in consecutive calendar years using utility class
            // CCF Campaign
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('CCFTestCamp1','Consumer','Intel® Corporate Logo', 
                                                                         Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(5) , 
                                                                         System.today().addYears(1), 2000, 'Unite', acc.Id,'2-in-1', true);
            list<Core_MDF_Regionwise_Campaign_Budget__c> rWise1 = Core_MDF_CampGridController.regionalData(camp1.Id);
            for(Core_MDF_Regionwise_Campaign_Budget__c rcb : rWise1){
                System.assert(camp1.Core_MDF_Market__c.contains(rcb.Core_MDF_Region__c));
            }  
            
            // Update CCF Campaign
            camp1.Core_MDF_Market__c = 'INDIA;INDONESIA';
            Database.update(camp1);
            rWise1 = Core_MDF_CampGridController.regionalData(camp1.Id);
            Core_MDF_CampGridController.SaveRegionWiseData(rWise1);
            for(Core_MDF_Regionwise_Campaign_Budget__c rcb : rWise1){
                System.assert(camp1.Core_MDF_Market__c.contains(rcb.Core_MDF_Region__c));
            }
            
            Test.stopTest();            
        }   
    }
}