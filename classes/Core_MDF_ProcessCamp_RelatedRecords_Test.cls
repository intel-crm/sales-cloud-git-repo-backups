/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCamp_RelatedRecords_Test 
* Version     : 1.0 
* Created Date: 8-30-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Harika P        8/30/2018                    Created to test campaign related object records once campaign is modified or inserted. 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ProcessCamp_RelatedRecords_Test {
    /****************************************************************************************************************************************
Method Name:                                             createOrUpdateCampaignRecords
Description:                                             Creating test data to test campaign related object records 
Added By:                                                Accenture – Harika P  -  8/30/2018
Modified By:                  Date:                      Changes: 
Accenture – Harika P        8/30/2018                    Created.
*****************************************************************************************************************************************/
    @isTest static void createOrUpdateCampaignRecords(){
        
        // Get profile details
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        Database.insert(usr);
        
        
        // code block under runAs mehod will be run as usr
        System.runAs(usr){
            // Creating channel program with utility class
            List<ChannelProgram> channelProgList = new List<ChannelProgram>();
            
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
            channelProgList.add(cp);
            
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
            channelProgList.add(cp1);
            
            Database.insert(channelProgList);
              Test.startTest();
            // Creating IntelAccount with utility class
            List<Account> accIntelList = new List<Account>();
            
            // Call utility class to create first intel account records
            Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account',
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intacc.Core_Account_Type__c = 'Reseller';
            intacc.Core_Sales_Groups__c = 'Automotive Sales Group';
            intacc.Industry = 'Food & Beverage';
            intacc.Core_MDF_Channel_Program__c = cp.Id;
            accIntelList.add(intacc);
            
            // Call utility class to create second intel account records
            Account intacc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account1', 
                                                                               Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intacc1.Core_Account_Type__c = 'Reseller';
            intacc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            intacc1.Industry = 'Food & Beverage';
            intacc1.Core_MDF_Channel_Program__c = cp1.Id;
            accIntelList.add(intacc1);
            
            Database.insert(accIntelList);
            
            // Creating Co-marketing Account with utility class
            List<Account> accList = new List<Account>();
            
            // Call utility class to create third intel account records
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', 
                                                                      cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
            accList.add(acc);
            
            
            // Call utility class to create fourth intel account records
            Account acc1 = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account1', 
                                                                       cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc1.Core_MDF_Parent_Fund_Account__c = intacc1.Id;
            accList.add(acc1);
            
            // Insert account records
            Database.insert(accList);
            
            // Creating campaigns when Start Date and End Date are in same calendar year using utility class
            // CCF Campaign
          
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('CCFTestCamp','Consumer','Intel® Corporate Logo',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today().addDays(5) , 
                                                                        System.today().addDays(120), 2000, 'Unite', acc.Id,'2-in-1', true);
            list<Core_MDF_Regionwise_Campaign_Budget__c> rWise = Core_MDF_CampGridController.regionalData(camp.Id);
            List<String> rWiseList= new List<String>();
            for(Core_MDF_Regionwise_Campaign_Budget__c rcb : rWise){
                System.assert(camp.Core_MDF_Market__c.contains(rcb.Core_MDF_Region__c));
            }  
            
            // Update CCF Campaign
            camp.Core_MDF_Market__c = 'INDIA;INDONESIA';
            Database.update(camp);
            
            // invoke regionalData method
            rWise = Core_MDF_CampGridController.regionalData(camp.Id);
            
            // call SaveRegionWiseData method from class
            Core_MDF_CampGridController.SaveRegionWiseData(rWise);
            List<String> rWise1List= new List<String>();
            for(Core_MDF_Regionwise_Campaign_Budget__c rcb : rWise){
                System.assert(camp.Core_MDF_Market__c.contains(rcb.Core_MDF_Region__c));
            }
            
            // DCF Campaign
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('DCFTestCamp','Reseller','Intel® Corporate Logo', 
                                                                         Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund',System.today().addDays(5) , 
                                                                         System.today().addDays(120), 5000, 'Hybrid Cloud', acc1.Id, 'Server',true);
            Campaign campxc1 = [SELECT Name, Id, Core_MDF_Activity_Category_Type__c, Core_MDF_Activity_Category__c FROM Campaign WHERE 
                                Name = 'DCFTestCamp' LIMIT 1];
            list<Core_MDF_Categorywise_Campaign_Budget__c>cWise = Core_MDF_CampGridController.categoryData(campxc1.Id);
            List<String> cWiseList = new List<String>();
            for(Core_MDF_Categorywise_Campaign_Budget__c ccb : cWise){
                System.assert(campxc1.Core_MDF_Activity_Category__c.contains(ccb.Core_MDF_Activity_Category__c));
            }
            
            // Update DCF Campaign
            campxc1.Core_MDF_Activity_Category_Type__c = 'Broadcast->Podcast;Print Media->Collateral - Other';
            Database.update(campxc1);
            cWise = Core_MDF_CampGridController.categoryData(campxc1.Id);
            Campaign campxc44 = [SELECT Name, Id, Core_MDF_Activity_Category_Type__c, Core_MDF_Activity_Category__c FROM Campaign WHERE 
                                 Name = 'DCFTestCamp' LIMIT 1];
            
            // call SaveCategoryWiseData method from class
            Core_MDF_CampGridController.SaveCategoryWiseData(cWise);
            List<String> cWise1List = new List<String>();
            for(Core_MDF_Categorywise_Campaign_Budget__c ccb : cWise){
                System.assert(campxc44.Core_MDF_Activity_Category__c.contains(ccb.Core_MDF_Activity_Category__c));
            }
            
            // Creating campaigns when Start Date and End Date are in consecutive calendar years using utility class
            // CCF Campaign
            Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('CCFTestCamp1','Consumer','Intel® Corporate Logo', 
                                                                         Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today().addDays(5) , 
                                                                         System.today().addYears(1), 2000, 'Unite', acc.Id,'2-in-1', true);
            list<Core_MDF_Regionwise_Campaign_Budget__c> rWise2 = Core_MDF_CampGridController.regionalData(camp2.Id);
            List<String> rWise2List = new List<String>();
            for(Core_MDF_Regionwise_Campaign_Budget__c rcb : rWise2){
                System.assert(camp2.Core_MDF_Market__c.contains(rcb.Core_MDF_Region__c));
            }  
            
            // Update CCF Campaign
            camp2.Core_MDF_Market__c = 'INDIA;INDONESIA';
            Database.update(camp2);
            rWise2 = Core_MDF_CampGridController.regionalData(camp2.Id);
            
            // call SaveRegionWiseData method from class
            Core_MDF_CampGridController.SaveRegionWiseData(rWise2);
            List<String> rWise3List= new List<String>();
            for(Core_MDF_Regionwise_Campaign_Budget__c rcb : rWise2){
                System.assert(camp2.Core_MDF_Market__c.contains(rcb.Core_MDF_Region__c));
            }
            Test.stopTest();
            
            // DCF Campaign
            Campaign camp3 = Core_MDF_CCP_TestDataUtility.createCampaign('DCFTestCamp1','Reseller','Intel® Corporate Logo', 
                                                                         Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund',System.today().addDays(5) , 
                                                                         System.today().addYears(1), 5000, 'Hybrid Cloud', acc1.Id, 'Server',true);
            Campaign campxc3 = [SELECT Name, Id, Core_MDF_Activity_Category_Type__c, Core_MDF_Activity_Category__c FROM Campaign WHERE 
                                Name = 'DCFTestCamp1' LIMIT 1];
            list<Core_MDF_Categorywise_Campaign_Budget__c> cWise2 = Core_MDF_CampGridController.categoryData(campxc3.Id);
            List<String> cWise2List = new List<String>();
            for(Core_MDF_Categorywise_Campaign_Budget__c ccb : cWise2){
                System.assert(campxc3.Core_MDF_Activity_Category__c.contains(ccb.Core_MDF_Activity_Category__c));
            } 
            
            
            // Update DCF Campaign
            campxc3.Core_MDF_Activity_Category_Type__c = 'Broadcast->Podcast;Print Media->Collateral - Other';
            Database.update(campxc3);
            Campaign campxc11 = [SELECT Name, Id, Core_MDF_Activity_Category_Type__c, Core_MDF_Activity_Category__c FROM Campaign WHERE 
                                 Name = 'DCFTestCamp1' LIMIT 1];
            list<Core_MDF_Categorywise_Campaign_Budget__c> cWise3 = Core_MDF_CampGridController.categoryData(campxc11.Id);
            
            // call SaveCategoryWiseData method from class
            Core_MDF_CampGridController.SaveCategoryWiseData(cWise3);
            List<String> cWise3List = new List<String>();
            for(Core_MDF_Categorywise_Campaign_Budget__c ccb : cWise3){
                System.assert(campxc11.Core_MDF_Activity_Category__c.contains(ccb.Core_MDF_Activity_Category__c));
            }
            
            // call checkSObjectEditPermission method from Core_MDF_CampGridController class
            Core_MDF_CampGridController.checkSObjectEditPermission('Core_MDF_Categorywise_Campaign_Budget__c');
            
            // call SavecampaignRecord method from class
            Core_MDF_CampGridController.SavecampaignRecord(campxc3.Id);
            
            
        }   
    }
}