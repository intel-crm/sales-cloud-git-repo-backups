/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_Campaign_Test
* Version     : 1.0 
* Created Date: 7-12-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Harika P       7/12/2018                    Created to test block campaign functionality. 
* Accenture - Harika P       7/31/2018                    Commented block campaign creation test as the US95990 is deleted.
* Accenture - Harika P       8/01/2018                    To test Activity Type and Activity Category values are correctly populating from Activity 
                                                          Category -> Type.
* Accenture - Harika P       8/13/2018                    To test US106392 - Change External Campaign Visibility Date
* NP(11630236)               28/2/2020                    Added source for PGM insert
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ProcessCCP_Campaign_Test {      
/****************************************************************************************************************************************
    Method Name:                                             createCampaignRecords
    Description:                                             Creating test data to test Activity Category values are correctly populating from 
                                                             Activity Category -> Type.
    Added By:                                                Accenture – Harika P  -  8/01/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P        8/01/2018                    Created.
*****************************************************************************************************************************************/    
     @isTest static void createCampaignRecords(){
         
         Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
         UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
         // Creating User with utility class 
         User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
         usr.profileId = sysAdminProfile.Id;
         usr.UserRoleId = usRole.Id;
         Database.insert(usr);
             
        //Running as System Admin
        System.runAs(usr){
             // Creating channel program with utility class
             ChannelProgram cp = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c 
                                   FROM ChannelProgram 
                                   WHERE Core_MDF_Technical_Program_Name__c ='Data Center CoMarketing Fund' LIMIT 1];
             //ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-marketing Fund','Data Center CoMarketing Fund', true);
             ChannelProgram rcp = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c 
                                   FROM ChannelProgram 
                                   WHERE Core_MDF_Technical_Program_Name__c ='Retail Marketing Funds' LIMIT 1];
            
            List<Account> ultAccList = new List<Account>();
            // Creating IntelAccount with utility class
            Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intacc.Core_Account_Type__c = 'Reseller';
            intacc.Industry = 'Food & Beverage';
            ultAccList.add(intacc);
            
            Account retaccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account for Retail', 
                                                                                  Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            retaccount.Core_Account_Type__c = 'Service Provider';
            retaccount.Industry = 'Food & Beverage';
            retaccount.Core_Geo__c ='ASMO';
            retaccount.Core_Sub_Geo__c ='LAR';
            ultAccList.add(retaccount);
            
            Database.insert(ultAccList);
            
            List<Account> accList = new List<Account>();
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount('Test Account', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
            accList.add(acc);
            
            Account acc1 = Core_MDF_CCP_TestDataUtility.createAccount('Test Account1', rcp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc1.Core_MDF_Parent_Fund_Account__c = retaccount.Id;
            acc1.Core_Geo__c ='ASMO';
            acc1.Core_Sub_Geo__c ='LAR';
            acc1.Core_MDF_Channel_Program__c = rcp.Id;
            accList.add(acc1);
            
            Database.insert(accList);
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (retaccount.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            con.Core_Audience_List__c = 'RMF User';
            Database.insert(con);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            // Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.email = 'xyz@mail.com';
            usr1.ContactId = con.Id;
            Database.insert(usr1);
            
                        
            Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc1.Id,usr1.Id,true);
            
             // Creating Campaign with utility class
            
             Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp','Reseller','Intel® Corporate Logo', 
                   Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund', System.today().addDays(2), 
                   System.today().addDays(346),5000, 'Hybrid Cloud', acc.Id,'Server',true);
            
              Campaign rcamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp','Reseller','Intel® Corporate Logo', 
                   Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(2), 
                   System.today().addDays(346),5000, 'Hybrid Cloud', acc1.Id,'Server',true);
            
             Campaign cmp =  [SELECT Id, Core_MDF_Activity_Category__c, Core_MDF_Activity_Type__c, Core_MDF_Activity_Category_Type__c from Campaign
                             WHERE Id =:camp.Id LIMIT 1];  
             //System.assertEquals('Digital Media',cmp.Core_MDF_Activity_Category__c);
             //System.assertEquals('Email',cmp.Core_MDF_Activity_Type__c);
             
            System.assertEquals('Broadcast',cmp.Core_MDF_Activity_Category__c);
            System.assertEquals('Podcast',cmp.Core_MDF_Activity_Type__c);
                 
             // Updating Campaign 
             cmp.Core_MDF_Activity_Category_Type__c = 'Print Media->Direct Mail';
             Database.update(cmp);
             Campaign cmp1 =  [SELECT Id, Core_MDF_Activity_Category__c, Core_MDF_Activity_Type__c, Core_MDF_Activity_Category_Type__c from Campaign 
                              WHERE Id =:cmp.Id LIMIT 1]; 
             System.assertEquals('Print Media',cmp1.Core_MDF_Activity_Category__c);
             System.assertEquals('Direct Mail',cmp1.Core_MDF_Activity_Type__c);
              
               
             //Bulk Campaign Creation  
             Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 1','Reseller','Intel® Corporate Logo', 
                   Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund', System.today().addDays(2), 
                   System.today().addDays(346), 10000, 'Hybrid Cloud', acc.Id,'Server',false); 
             Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 2','Reseller','Intel® Corporate Logo', 
                   Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund', System.today().addDays(180), 
                   System.today().addYears(1), 3000, 'Hybrid Cloud', acc.Id,'Server',false); 
             Campaign camp3 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 2','Reseller','Intel® Corporate Logo', 
                   Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund', System.today(), System.today().addYears(1), 
                   3000, 'Hybrid Cloud', acc.Id,'Server',false); 
            
             /*Campaign camp4 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 1','Reseller','Intel® Corporate Logo', 
                   Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(2), 
                   System.today().addDays(346), 10000, 'Hybrid Cloud', acc1.Id,'Server',false); */

            
            Test.startTest();  
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc1.Id,rcp.Id,5000000,System.today().addDays(-5),System.today(), 
                                                                                   true);
            
            System.debug('Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c@@@'+pmb.Core_MDF_Budget_Partner__c);
            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc1,1000000.0,true);
            
            
            Campaign chkCampEdit = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 1','Reseller','Intel® Corporate Logo', 
                   Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(2), 
                   System.today().addDays(346), 10000, 'Hybrid Cloud', acc1.Id,'Server',false); 
            
            chkCampEdit.Core_MDF_Technology__c ='Wifi6';
            chkCampEdit.Name= 'Insert Camp';
            insert chkCampEdit;
            chkCampEdit.Core_MDF_Technology__c ='Thunderbolt';
            chkCampEdit.Name= 'Update Camp';
            update chkCampEdit;
            
            //Insert Activity 
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(chkCampEdit.Id),                                                                                                         
                                                                                                         string.valueof(acc1.id),NULL,NULL,
                                                                                                         false);
            pfr.RequestedAmount = 900000;
            pfr.Amount = 900000;
            pfr.Status = 'Draft';
            pfr.Core_MDF_Fund_Request_Status__c ='Pending Review';
            pfr.AllocationId = pfa.Id;
            pfr.BudgetId = pmb.Id;
            //pfr.Core_MDF_Ultimate_Account_Name__c = acc1.Id;
            pfr.Core_MDF_Start_Date__c = System.today().addDays(2);
            pfr.Core_MDF_End_Date__c = System.today().addDays(7);
            Database.insert(pfr);
            system.debug('pfr@@'+pfr);
            
             camp2.Core_MDF_Activity_Category_Type__c = 'Print Media->Direct Mail';
             List<Campaign> lstCmp = new List<Campaign>();
             lstCmp.add(camp1);
             lstCmp.add(camp2);
             lstCmp.add(camp3);
             //lstCmp.add(camp4);
             Database.insert(lstCmp);
            
             Campaign cmp2 =  [SELECT Id, Core_MDF_Activity_Category__c, Core_MDF_Activity_Type__c, Core_MDF_Activity_Category_Type__c from Campaign 
                              WHERE Id =:camp1.Id LIMIT 1];    

             Campaign cmp3 =  [SELECT Id, Core_MDF_Activity_Category__c, Core_MDF_Activity_Type__c, Core_MDF_Activity_Category_Type__c from Campaign 
                              WHERE Id =:camp2.Id LIMIT 1];    
             System.assertEquals('Print Media',cmp3.Core_MDF_Activity_Category__c);
             System.assertEquals('Direct Mail',cmp3.Core_MDF_Activity_Type__c); 
             
			// Updating Campaign status to cancelled.
             camp2.Core_MDF_Campaign_Status__c = 'Cancelled';
             Database.update(camp2);
             Campaign cmp4 =  [SELECT Id,Status, Core_MDF_Activity_Category__c, Core_MDF_Activity_Type__c, Core_MDF_Activity_Category_Type__c from 
                              Campaign WHERE Id =:camp2.Id LIMIT 1]; 
             System.assertEquals('Cancelled',cmp4.Status);
             
              // Check Campaign3 status is chaned to Inprogress or not.            
             Campaign cmp5 =  [SELECT Id,Status, Core_MDF_Technology__c, Core_MDF_Activity_Category__c, Core_MDF_Activity_Type__c, Core_MDF_Activity_Category_Type__c from 
                              Campaign WHERE Id =:camp3.Id LIMIT 1]; 
             System.assertEquals('In Progress',cmp5.Status);


             Test.stopTest();
     
             }
    }
/****************************************************************************************************************************************
    Method Name:                                             createTestData
    Description:                                             Creating test data to test Change Member Campaign Visibility Date 
    Added By:                                                Accenture – Harika P  -  8/13/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P         8/13/2018                   Created.
*****************************************************************************************************************************************/   
    @TestSetup static void createTestData() 
    {
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        System.runAs(usr1){
            // Creating channel program with utility class
            List<ChannelProgram> channelProgList = new List<ChannelProgram>();
            
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
            channelProgList.add(cp);
            
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
            channelProgList.add(cp1);
            
            ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            channelProgList.add(cp2);
            Database.insert(channelProgList);
            
            // Creating IntelAccount with utility class
            Test.startTest();
            Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intacc.Core_Account_Type__c = 'Reseller';
            //intacc.Core_Sales_Groups__c = 'Automotive Sales Group';
            intacc.Industry = 'Food & Beverage';
            Database.insert(intacc);
            
            
            Account racc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 2', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            racc.Core_Account_Type__c = 'Service Provider';
            //racc.Core_Sales_Groups__c = 'CCG Sales Group';
            racc.Industry = 'Health';
            racc.Core_Geo__c ='ASMO';
            racc.Core_Sub_Geo__c ='LAR';
            Database.insert(racc);
            
            // Creating Co-marketing Account with utility class
            List<Account> accList = new List<Account>();
            
            Account dcfacc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing DCF Test Account', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dcfacc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
            accList.add(dcfacc);
           
            Account ccfacc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                         cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfacc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
            accList.add(ccfacc);
            
            Account retacc1 = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Test Account', 
                                                                         cp2.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            retacc1.Core_MDF_Parent_Fund_Account__c = racc.Id;
            retacc1.Core_Geo__c ='ASMO';
            retacc1.Core_Sub_Geo__c ='LAR';
            accList.add(retacc1);
          
            Database.insert(accList);
            
            // Creating Contact with utility class
            List<Contact> conList = new List<Contact>();
            
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (intacc.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con);
            
            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact (intacc.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con1);
            
            Database.insert(conList);
            
            Test.stopTest();
            //System.debug('Limit.getQueries():'+Limits.getQueries());
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            List<User> usrList = new List<User>();
            // Creating User with utility class 
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con.Id;
            usrList.add(usr2);        
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            usr3.ProfileId = partnerProfile.Id;
            usr3.ContactId = con1.Id;
            usrList.add(usr3);
            Database.insert(usrList);
            
            List<Group> grpList = new List<Group>();
            // Creating Group
            Group dcfgrp = new Group();
            dcfgrp.Name = 'Core CCP DCF External';
            dcfgrp.DeveloperName = 'Core_CCP_DCF_External';
            grpList.add(dcfgrp);
            
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF External';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_External';
            grpList.add(ccfgrp);
            
            //ASMO Internal group
            Group dcfAsmogrp = new Group();
            dcfAsmogrp.Name = 'Core CCP DCF ASMO INTERNAL';
            dcfAsmogrp.DeveloperName = 'Core_CCP_DCF_ASMO_Internal';
            grpList.add(dcfAsmogrp);
            
            //WW Internal group
            Group dcfWWgrp = new Group();
            dcfWWgrp.Name = 'Core CCP DCF WW INTERNAL';
            dcfWWgrp.DeveloperName = 'Core_CCP_DCF_WW_Internal';
            grpList.add(dcfWWgrp);
            
            //ASMO Internal group
            Group retASMOgrp = new Group();
            retASMOgrp.Name = 'Core CCP Retail ASMO INTERNAL';
            retASMOgrp.DeveloperName = 'Core_CCP_Retail_ASMO_Internal';
            grpList.add(retASMOgrp);
            
            //EMEA Internal group
            Group dcfEMEAgrp = new Group();
            dcfEMEAgrp.Name = 'Core CCP DCF EMEA INTERNAL';
            dcfEMEAgrp.DeveloperName = 'Core_CCP_DCF_EMEA_Internal';
            grpList.add(dcfEMEAgrp);
            
            Database.insert(grpList);
            
            List<GroupMember> grpMemList = new List<GroupMember>();
            // Creating Group Member
            GroupMember dcfGrpMem = new GroupMember();
            dcfGrpMem.UserOrGroupId = usr2.Id;
            dcfGrpMem.GroupId = dcfgrp.Id;
            grpMemList.add(dcfGrpMem);
            GroupMember ccfGrpMem = new GroupMember();
            ccfGrpMem.UserOrGroupId = usr3.Id;
            ccfGrpMem.GroupId = ccfgrp.Id;
            grpMemList.add(ccfGrpMem);
            
            Database.insert(grpMemList);
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = intacc.Id;
            pgm.Core_MDF_Group_Name__c = 'Core_CCP_DCF_External';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = dcfgrp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_DCF_External';
            pgmList.add(pgm);
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = intacc.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_CCP_CCF_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp1.Id;
            pgm1.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_CCF_External';
            pgmList.add(pgm1);
            
            Core_MDF_Partner_Group_Mapping__c geoPgm = new Core_MDF_Partner_Group_Mapping__c();
            geoPgm.Core_MDF_Account__c = intacc.Id;
            geoPgm.Core_MDF_Group_Name__c = 'Core_CCP_DCF_ASMO_Internal';
            geoPgm.Core_MDF_Type_of_Access__c = 'Internal';
            geoPgm.Core_MDF_Region_cd__c = 'ASMO';
            geoPgm.Core_MDF_Group_Id__c = dcfAsmogrp.Id;                
            geoPgm.Core_MDF_Channel_Program__c = cp.Id;
            geoPgm.Core_MDF_Source_Txt__c = 'Test';
            geoPgm.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_DCF_ASMO_Internal';
            pgmList.add(geoPgm);
            
            Core_MDF_Partner_Group_Mapping__c wwPgm = new Core_MDF_Partner_Group_Mapping__c();
            wwPgm.Core_MDF_Account__c = intacc.Id;
            wwPgm.Core_MDF_Group_Name__c = 'Core_CCP_DCF_WW_Internal';
            wwPgm.Core_MDF_Type_of_Access__c = 'Internal';
            wwPgm.Core_MDF_Region_cd__c = 'WW';
            wwPgm.Core_MDF_Group_Id__c = dcfWWgrp.Id;                
            wwPgm.Core_MDF_Channel_Program__c = cp.Id;
            wwPgm.Core_MDF_Source_Txt__c = 'Test';
            wwPgm.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_DCF_WW_Internal';
            pgmList.add(wwPgm);
            
            Core_MDF_Partner_Group_Mapping__c pgmEMEA = new Core_MDF_Partner_Group_Mapping__c();
            pgmEMEA.Core_MDF_Account__c = intacc.Id;
            pgmEMEA.Core_MDF_Group_Name__c = 'Core_CCP_DCF_EMEA_Internal';
            pgmEMEA.Core_MDF_Type_of_Access__c = 'Internal';
            pgmEMEA.Core_MDF_Region_cd__c = 'EMEA';
            pgmEMEA.Core_MDF_Group_Id__c = dcfEMEAgrp.Id;                
            pgmEMEA.Core_MDF_Channel_Program__c = cp.Id;
            pgmEMEA.Core_MDF_Source_Txt__c = 'Test';
            pgmEMEA.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_DCF_EMEA_Internal';
            pgmList.add(pgmEMEA);
            
            Core_MDF_Partner_Group_Mapping__c pgmASMO = new Core_MDF_Partner_Group_Mapping__c();
            pgmASMO.Core_MDF_Account__c = racc.Id;
            pgmASMO.Core_MDF_Group_Name__c = 'Core_CCP_Retail_ASMO_Internal';
            pgmASMO.Core_MDF_Type_of_Access__c = 'Internal';
            pgmASMO.Core_MDF_Region_cd__c = 'ASMO';
            pgmASMO.Core_MDF_Sub_Region_cd__c = 'LAR';
            pgmASMO.Core_MDF_Group_Id__c = retASMOgrp.Id;                
            pgmASMO.Core_MDF_Channel_Program__c = cp2.Id;
            pgmASMO.Core_MDF_Source_Txt__c = 'Test';
            pgmASMO.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_Retail_ASMO_Internal';
            pgmList.add(pgmASMO);
            
            Database.insert(pgmList);
            
        }  
    }
/****************************************************************************************************************************************
    Method Name:                                             createCampaign
    Description:                                             Created to test CCF/DCF group members will see their respective campaigns only.
    Added By:                                                Accenture – Harika P  -  8/13/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P         8/13/2018                   Created.
*****************************************************************************************************************************************/    
    @isTest static  void createCampaign()
    {
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test1' LIMIT 1];
        System.runAs(user){
            Account intacc;
            Account dcfacc;
            Account ccfacc;
            Account retacc;
            for(Account acc: [SELECT Id,Name,Core_MDF_Parent_Fund_Account__c FROM Account LIMIT 50000]){
                if(acc.Name == 'Test Account 1'){
                  intacc = acc;
                }
                if(acc.Name == 'Co-marketing DCF Test Account'){
                  dcfacc = acc;
                }
                if(acc.Name == 'Co-marketing CCF Test Account'){
                  ccfacc = acc;
                }    
                if(acc.Name == 'Co-marketing Retail Test Account'){
                  retacc = acc;
                }   
                
            }
           
            User usr1;
            User usr2;
            User usr3;
            
            for(User usr: [SELECT Id,LastName FROM User WHERE LastName='User Test1' OR LastName='User Test2' OR LastName='User Test3' LIMIT 50000]){
                if(usr.LastName == 'User Test1' ){
                    usr1 = usr;
                }
                if(usr.LastName == 'User Test2'){
                    usr2 = usr;
                }
                if(usr.LastName == 'User Test3'){
                    usr3 = usr;
                }
            }
            
            Id dcfgrp;
            Id ccfgrp;
            Id retgrp;
            for(Group grp:[SELECT Id,Name FROM Group WHERE Name = 'Core CCP DCF External' OR Name = 'Core CCP CCF External' OR Name ='Core_CCP_Retail_ASMO_Internal' LIMIT 50000]){
                if(grp.Name == 'Core CCP DCF External'){
                    dcfgrp = grp.Id;
                }
                if(grp.Name == 'Core CCP CCF External'){
                    dcfgrp = grp.Id;
                } 
                if(grp.Name == 'Core_CCP_Retail_ASMO_Internal'){
                    retgrp = grp.Id;
                } 
            }
            
            // Creating Campaign with utility class
            Test.startTest();
            Campaign campc1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 1','Reseller','Intel® Corporate Logo',
                  Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund',System.today().addDays(5) , 
                  System.today().addYears(1), 5000, 'Hybrid Cloud', dcfacc.Id,'Server', false);
            campc1.Core_MDF_External_Visibility_Date__c = System.today();
            Database.insert(campc1);
            
            List<String> grpIdList= new List<String>();
            for(CampaignShare cmpshr : [SELECT Id, CampaignId, UserOrGroupId FROM CampaignShare WHERE CampaignId =: campc1.Id LIMIT 50000]){
                grpIdList.add(string.valueof(cmpshr.UserOrGroupId));
            }
            
            //Since the external visibility date is today the above campaign should be shared with DCF external group
            //and it should not shared with CCF external group
            System.debug('grpIdList:' + grpIdList);          
            System.assert(grpIdList.contains(dcfgrp));
            System.assert(!grpIdList.contains(ccfgrp));
            
            Campaign campc2 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 2','Reseller','Intel® Corporate Logo', 
                  Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund',System.today().addDays(5) , 
                  System.today().addYears(1), 5000, 'Hybrid Cloud', dcfacc.Id, 'Server',false);
            campc2.Core_MDF_External_Visibility_Date__c = System.today().addDays(2);
            Database.insert(campc2);
            List<String> grpIdList1= new List<String>();
            for(CampaignShare cmpshr1 : [SELECT Id, CampaignId, UserOrGroupId FROM CampaignShare WHERE CampaignId =: campc2.Id LIMIT 50000]){
                grpIdList1.add(string.valueof(cmpshr1.UserOrGroupId));
            }

            //Since the external visibility date is future date, the above campaign should not be shared with DCF external group
            //and CCF external group            
            System.debug('grpIdList1:' + grpIdList1);
            System.assert(!grpIdList1.contains(dcfgrp));
            System.assert(!grpIdList1.contains(ccfgrp));
            
            // Updating Campaign 
            campc1.Core_MDF_External_Visibility_Date__c = System.today().addDays(2);
            Database.update(campc1);
            List<String> grpIdList2= new List<String>();
            for(CampaignShare cmpunshr : [SELECT Id, CampaignId, UserOrGroupId FROM CampaignShare WHERE CampaignId =: campc1.Id LIMIT 50000]){
                grpIdList2.add(string.valueof(cmpunshr.UserOrGroupId));
            } 
            //Since the external visibility date is updated to future date, the above campaign sharing should be removed for external users.
            System.debug('grpIdList2:' + grpIdList2);
            System.assert(!grpIdList2.contains(dcfgrp));
            System.assert(!grpIdList2.contains(ccfgrp));
            Test.stopTest();
            System.debug('Limit.getQueries():'+Limits.getQueries());
        }
    }
}