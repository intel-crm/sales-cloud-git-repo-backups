/****************************************************************************************************************************************
* Class Name  : Core_MDF_BatchShareCampVisibility_Test 
* Version     : 1.0 
* Created Date: 8-13-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Harika P        8/17/2018          Created to test Batch class to periodically share Campaign records based on Member visibility date
* Intel - NP(11630236)		  27/08/2019         Created list to update common objects instead of individual inserts	
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_BatchShareCampVisibility_Test 
{
/****************************************************************************************************************************************
    Method Name:                                             createTestData
    Description:                                             Creating Test data for Batch Class.
    Added By:                                                Accenture – Harika P  -  8/17/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P          8/17/2018                  Created.
*****************************************************************************************************************************************/    
    @TestSetup static void createTestData() 
    {
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        List<Account> accList = new List<Account>(); List<Contact> conList = new List<Contact>();List<User> userList= new List<User>();
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        System.runAs(usr1){
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account intAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,false);
            intAcc.Core_Account_Type__c = 'Reseller';
            //intAcc.Core_Sales_Groups__c = 'Automotive Sales Group';
            intAcc.Industry = 'Food & Beverage';
            Database.insert(intAcc);
            
            // Creating Co-marketing Account with utility class
            Account dcfAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing DCF Test Account', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dcfAcc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
            accList.add(dcfAcc);
            Account ccfAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                         cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfAcc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
            accList.add(ccfAcc);
            Database.insert(accList);
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (intAcc.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con);
            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact (intAcc.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con1);
            Database.insert(conList);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 50000];
            
            // Creating User with utility class 
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con.Id;
            userList.add(usr2);        
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            usr3.ProfileId = partnerProfile.Id;
            usr3.ContactId = con1.Id;
            userList.add(usr3);
            Database.insert(userList);
            
            // Creating Group
            Group dcfGrp = new Group();
            dcfGrp.Name = 'Core CCP DCF External';
            dcfGrp.DeveloperName = 'Core_CCP_DCF_External';
            Database.insert(dcfGrp);
            Group ccfGrp = new Group();
            ccfGrp.Name = 'Core CCP CCF External';
            ccfGrp.DeveloperName = 'Core_CCP_CCF_External';
            Database.insert(ccfGrp);
            
            // Creating Group Member
            GroupMember dcfGrpMem = new GroupMember();
            dcfGrpMem.UserOrGroupId = usr2.Id;
            dcfGrpMem.GroupId = dcfGrp.Id;
            Database.insert(dcfGrpMem);
            GroupMember ccfGrpMem = new GroupMember();
            ccfGrpMem.UserOrGroupId = usr3.Id;
            ccfGrpMem.GroupId = ccfGrp.Id;
            Database.insert(ccfGrpMem);
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = intAcc.Id;
            pgm.Core_MDF_Group_Name__c = 'Core_CCP_DCF_External';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = dcfGrp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            Database.insert(pgm);
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = intAcc.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_CCP_CCF_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = ccfGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp1.Id;
            Database.insert(pgm1);
            
            //Creating Campaign
            Campaign campc1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 1','Reseller','Intel® Corporate Logo', 
                              Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund',System.today().addDays(5) , 
                              System.today().addYears(1), 5000, 'Hybrid Cloud', dcfAcc.Id,'Server', false);
            campc1.Core_MDF_External_Visibility_Date__c = System.today();
            Database.insert(campc1);       
            
        }  
    }    
/****************************************************************************************************************************************
    Method Name:                                             testSchedulerMethod
    Description:                                             Testing the Batch Sharing and Unsharing Functionality based on Member Visibility Date.
    Added By:                                                Accenture – Harika P  -  09/13/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P          09/13/2018                 Created.
*****************************************************************************************************************************************/
    @isTest static void testSchedulerMethod()
    {  
        User usr1 = [SELECT Id FROM User WHERE LastName = 'User Test1' LIMIT 50000];
        
        System.runAs(usr1){
            List<Group> dcfGrp = [SELECT Id FROM Group WHERE Name ='Core CCP DCF External' LIMIT 50000];
            List<Group> ccfGrp = [SELECT Id FROM Group WHERE Name ='Core CCP CCF External' LIMIT 50000];
            Campaign cmp = [SELECT Id, Name FROM Campaign WHERE Name ='Test Camp 1' LIMIT 1];
                    
            String cronExp = '0 0 * ? * * *';
            Test.startTest();
            String shareCamp = System.schedule('Test Campaign Share', cronExp, new Core_MDF_BatchSharecmpSchedule());
            List<Id> grpIdList= new List<Id>();
            
            for(CampaignShare shareList : [SELECT Id, CampaignId, UserOrGroupId FROM CampaignShare WHERE CampaignId =: cmp.Id LIMIT 50000 ]){
                grpIdList.add(string.valueof(shareList.UserOrGroupId));
            }
            Test.stopTest();
            System.debug('grpIdList' + grpIdList);            
            System.debug('dcfGrp[0].Id' + dcfGrp[0].Id);            
            System.assert(grpIdList.contains(dcfGrp[0].Id));
            System.assert(!grpIdList.contains(ccfGrp[0].Id));
        } 
        
        
    }
    
    
}