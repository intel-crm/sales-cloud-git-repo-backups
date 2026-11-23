/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_CtgrywiseShrng_Test 
* Version     : 1.0 
* Created Date: 9-06-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Harika P        9/06/2018                   Created to test campaign related object records once campaign is modified or inserted. 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ProcessCCP_CtgrywiseShrng_Test {
/****************************************************************************************************************************************
    Method Name:                                   createCampaignRecords
    Description:                                   Creating sharing records of Core_MDF_Categorywise_Campaign_Budget__c to test it for external users 
    Added By:                                      Accenture – Harika P  -  9/06/2018
    Modified By:                  Date:            Changes: 
    Accenture – Harika P        9/06/2018          Created.
*****************************************************************************************************************************************/
    @isTest static void createCampaignRecords(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        UserRole ur = [Select Id, Name From UserRole WHERE Name = 'Admin' LIMIT 1];
        usr.profileId = sysAdminProfile.Id;
        usr.UserRoleId =ur.Id ;        
        Database.insert(usr);
        System.runAs(usr){
            // Creating channel program with utility class
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account intacc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account1', 
                                                                               Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intacc1.Core_Account_Type__c = 'Reseller';
            intacc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            intacc1.Industry = 'Food & Beverage';
            intacc1.Core_MDF_Channel_Program__c = cp1.Id;
            Database.insert(intacc1);
            
            // Creating Co-marketing Account with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account1', 
                                                                       cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc1.Core_MDF_Parent_Fund_Account__c = intacc1.Id;
            Database.insert(acc1);
            
            // Creating campaigns when Start Date and End Date are in same calendar year using utility class
            // DCF Campaign
            Test.startTest();
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('DCFTestCamp','Reseller','Intel® Corporate Logo', 
                  Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund',System.today().addDays(5) ,
                  System.today().addDays(120), 5000, 'Hybrid Cloud', acc1.Id, 'Server',true);
            Campaign campxc1 = [SELECT Name, Id, Core_MDF_Activity_Category_Type__c, Core_MDF_Activity_Category__c FROM Campaign WHERE 
                               Name = 'DCFTestCamp' LIMIT 50000];
            list<Core_MDF_Categorywise_Campaign_Budget__c>cWise = Core_MDF_CampGridController.categoryData(campxc1.Id);
            for(Core_MDF_Categorywise_Campaign_Budget__c ccb : cWise){
                System.assert(campxc1.Core_MDF_Activity_Category__c.contains(ccb.Core_MDF_Activity_Category__c));
            }
            
            // Update DCF Campaign
            campxc1.Core_MDF_Activity_Category_Type__c = 'Broadcast->Podcast;Print Media->Collateral - Other';
            Database.update(campxc1);
            cWise = Core_MDF_CampGridController.categoryData(campxc1.Id);
            Campaign campxc2 = [SELECT Name, Id, Core_MDF_Activity_Category_Type__c, Core_MDF_Activity_Category__c FROM Campaign WHERE 
                               Name = 'DCFTestCamp' LIMIT 50000];
            Core_MDF_CampGridController.SaveCategoryWiseData(cWise);
            for(Core_MDF_Categorywise_Campaign_Budget__c ccb : cWise){
                System.assert(campxc2.Core_MDF_Activity_Category__c.contains(ccb.Core_MDF_Activity_Category__c));
            }
            
            // Creating campaigns when Start Date and End Date are in consecutive calendar years using utility class
            // DCF Campaign
            Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('DCFTestCamp1','Reseller','Intel® Corporate Logo', 
                  Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund',System.today().addDays(5) , 
                  System.today().addYears(1), 5000, 'Hybrid Cloud', acc1.Id, 'Server',true);
            Campaign campxc3 = [SELECT Name, Id, Core_MDF_Activity_Category_Type__c, Core_MDF_Activity_Category__c FROM Campaign WHERE 
                               Name = 'DCFTestCamp1' LIMIT 50000];
            list<Core_MDF_Categorywise_Campaign_Budget__c> cWise1 = Core_MDF_CampGridController.categoryData(campxc3.Id);
            for(Core_MDF_Categorywise_Campaign_Budget__c ccb : cWise1){
                System.assert(campxc3.Core_MDF_Activity_Category__c.contains(ccb.Core_MDF_Activity_Category__c));
            }
            
            // Update DCF Campaign
            campxc3.Core_MDF_Activity_Category_Type__c = 'Broadcast->Podcast;Print Media->Collateral - Other';
            Database.update(campxc3);
            Campaign campxc4 = [SELECT Name, Id, Core_MDF_Activity_Category_Type__c, Core_MDF_Activity_Category__c FROM Campaign WHERE 
                               Name = 'DCFTestCamp1' LIMIT 50000];
            list<Core_MDF_Categorywise_Campaign_Budget__c> cWise2 = Core_MDF_CampGridController.categoryData(campxc4.Id);
            Core_MDF_CampGridController.SaveCategoryWiseData(cWise2);
            for(Core_MDF_Categorywise_Campaign_Budget__c ccb : cWise2){
                System.assert(campxc4.Core_MDF_Activity_Category__c.contains(ccb.Core_MDF_Activity_Category__c));
            }
            Test.stopTest();
            
        }   
    }
}