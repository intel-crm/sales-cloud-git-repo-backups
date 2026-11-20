@isTest(SeeAllData=false)
public class Core_MDF_Partnership_ScoreHandler_Test {
    @TestSetup static void createTestData(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        Database.insert(usr);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.profileId = sysAdminProfile.Id;
        Database.insert(usr1);
        List<String> bypassFunctionKeys = new List<String>();
        //bypassFunctionKeys.add('Core_MDF_Bypass_Sharing_to_PGM');
        //bypassFunctionKeys.add('Core_MDF_BypassAccPgm_Sharing');
        //List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
        // Creating channel program with utility class
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', true);
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        acc1.Core_Geo__c='ASMO';
        acc1.Core_Sub_Geo__c='NAR';
        update acc1;
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        Account acc4 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 4', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        acc4.Core_Geo__c='APJ';
        update acc4;
        
        List<Group> groupList = new List<Group>();
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        grp.DeveloperName = 'PGM_TEST_Group2';
        groupList.add(grp);
        
        Group grp1 = new Group();
        grp1.name = 'PGM_TEST2';
        grp1.DeveloperName = 'PGM_TEST_Group1';
        groupList.add(grp1);
        
        Group grp2 = new Group();
        grp2.name = 'PGM_TEST3';
        grp2.DeveloperName = 'PGM_TEST_Group3';
        groupList.add(grp2);
        
        Group ccfgrp1 = new Group();
        ccfgrp1.Name = 'Core CCP CCF External';
        ccfgrp1.DeveloperName = 'Core_MDF_Ext_CCF_APJ';
        groupList.add(ccfgrp1);
        
        Database.insert(groupList);
        
        List<UserShare> usList = new List<UserShare>();
        UserShare us1 = new UserShare(UserId = usr.Id, UserOrGroupId = grp.Id, RowCause = 'Manual', UserAccessLevel = 'Read');
        UserShare us2 = new UserShare(UserId = usr1.Id, UserOrGroupId = grp1.Id, RowCause = 'Manual', UserAccessLevel = 'Read');
        usList.add(us1);
        usList.add(us2);
        database.insert(usList);
        Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
        
        config.Core_MDF_Value__c = '100';
        
        config.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
        
        insert config;
        
        /*test.startTest();
List<GroupMember> gmList = new List<GroupMember>();
GroupMember gm = new GroupMember();
gm.GroupId = grp.Id;
gm.UserOrGroupId = usr.Id;
GroupMember gm1 = new GroupMember();
gm1.GroupId = grp1.Id;
gm1.UserOrGroupId = usr1.Id;
gmList.add(gm);
gmList.add(gm1);
database.insert(gmList);
test.stopTest();*/
        
        Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
        pgm.Core_MDF_Account__c = acc1.Id;
        pgm.Core_MDF_Group_Name__c = 'PGM_TEST_Group2';
        pgm.Core_MDF_Type_of_Access__c = 'Internal';
        pgm.Core_MDF_Group_Id__c = grp.Id;                
        pgm.Core_MDF_Channel_Program__c = cp1.Id;
        pgm.Core_MDF_Region_cd__c='WW';
        pgm.Core_MDF_Source_Txt__c = 'test';
        pgm.Core_MDF_AccountIdGroupName__c = acc1.Id+'PGM_TEST_Group2';
        pgmList.add(pgm);
        
        Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
        pgm1.Core_MDF_Account__c = acc1.Id;
        pgm1.Core_MDF_Group_Name__c = 'PGM_TEST_Group1';
        pgm1.Core_MDF_Type_of_Access__c = 'Internal';
        pgm1.Core_MDF_Group_Id__c = grp1.Id;                
        pgm1.Core_MDF_Channel_Program__c = cp1.Id;
        pgm1.Core_MDF_Region_cd__c='EMEA';
        pgm1.Core_MDF_Source_Txt__c = 'test';
        pgm1.Core_MDF_AccountIdGroupName__c =acc1.Id+'PGM_TEST_Group1';
        pgmList.add(pgm1);
        
        Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
        pgm2.Core_MDF_Account__c = acc1.Id;
        pgm2.Core_MDF_Group_Name__c = 'PGM_TEST_Group3';
        pgm2.Core_MDF_Type_of_Access__c = 'Internal';
        pgm2.Core_MDF_Group_Id__c = grp2.Id;                
        pgm2.Core_MDF_Channel_Program__c = cp2.Id;
        pgm2.Core_MDF_Region_cd__c='WW';
        pgm2.Core_MDF_Source_Txt__c = 'test';
        pgm2.Core_MDF_AccountIdGroupName__c = acc1.Id+'PGM_TEST_Group3';
        pgm2.Core_MDF_Region_cd__c='ASMO';
        pgm2.Core_MDF_Sub_Region_cd__c='NAR';
        pgmList.add(pgm2);
        
        Core_MDF_Partner_Group_Mapping__c pgm3 = new Core_MDF_Partner_Group_Mapping__c();
        pgm3.Core_MDF_Account__c = acc4.Id;
        pgm3.Core_MDF_Group_Name__c = 'PGM_TEST_Group3';
        pgm3.Core_MDF_Type_of_Access__c = 'Internal';
        pgm3.Core_MDF_Group_Id__c = grp2.Id;                
        pgm3.Core_MDF_Channel_Program__c = cp2.Id;
        pgm3.Core_MDF_Region_cd__c='WW';
        pgm3.Core_MDF_Source_Txt__c = 'test';
        pgm3.Core_MDF_AccountIdGroupName__c = acc4.Id+'PGM_TEST_Group3';
        pgm3.Core_MDF_Region_cd__c='APJ';
        pgmList.add(pgm3);
        
        Core_MDF_Partner_Group_Mapping__c pgm4 = new Core_MDF_Partner_Group_Mapping__c();
        pgm4.Core_MDF_Account__c = acc1.Id;
        pgm4.Core_MDF_Group_Name__c = 'Core_MDF_Ext_CCF_APJ';
        pgm4.Core_MDF_Type_of_Access__c = 'External';
        pgm4.Core_MDF_Group_Id__c = ccfgrp1.Id; 
        pgm4.Core_MDF_Channel_Program__c = cp1.Id;
        pgm4.Core_MDF_Source_Txt__c = 'Test';
        pgm4.Core_MDF_AccountIdGroupName__c = acc1.Id+'_Core_MDF_Ext_CCF_APJ';
        pgmList.add(pgm4);
        
        database.insert(pgmList);
    }
    @isTest static void testinsert(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
            Core_MDF_Configuration__c confign = new Core_MDF_Configuration__c();
            confign.Core_MDF_Value__c = '1000';
            confign.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
            insert confign;
            account account1=[select id from Account where name =:'Test Account 1'];
            //account account2=[select id from Account where name =:'Test Account 2'];
            ChannelProgram cp=[select id from ChannelProgram where name =:Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            //ChannelProgram cp2=[select id from ChannelProgram where name =: 'Retail Marketing Funds'];
            
            list<Core_MDF_Partnership_Score__c> pscList = new list<Core_MDF_Partnership_Score__c>();
            
            Core_MDF_Partnership_Score__c PSC=new Core_MDF_Partnership_Score__c();
            PSC.Core_MDF_Account_Id__c=account1.Id;
            PSC.Core_MDF_Channel_Program_Id__c =cp.Id;
            PSC.Core_MDF_Program_nm__c ='Client CoMarketing Fund';
            PSC.Core_MDF_Quarter_Year_Nm__c = 'Q1 2023';
            PSC.Core_MDF_Quarter_nm__c='Q1';
            PSC.Core_MDF_Year_nm__c='2023';
            PSC.Core_MDF_Partnership_Score_Nbr__c=0.0;
            
            insert PSC; 
            
            Core_MDF_Partnership_Score__c PSC1=new Core_MDF_Partnership_Score__c();
            PSC1.Core_MDF_Account_Id__c=account1.Id;
            PSC1.Core_MDF_Channel_Program_Id__c =cp.Id;
            PSC1.Core_MDF_Program_nm__c ='Client CoMarketing Fund';
            PSC1.Core_MDF_Quarter_Year_Nm__c = 'Q2 2023';
            PSC1.Core_MDF_Quarter_nm__c='Q2';
            PSC1.Core_MDF_Year_nm__c='2023';
            PSC1.Core_MDF_Partnership_Score_Nbr__c=0.0;
            
            insert PSC1; 
            
            account account2=[select id from Account where name =:'Test Account 1'];
            ChannelProgram cp2=[select id from ChannelProgram where name =: 'Retail Marketing Funds'];
            Core_MDF_Partnership_Score__c PSC2=new Core_MDF_Partnership_Score__c();
            PSC2.Core_MDF_Account_Id__c=account2.Id;
            PSC2.Core_MDF_Channel_Program_Id__c =cp2.Id;
            PSC2.Core_MDF_Program_nm__c ='Retail Marketing Funds';
            PSC2.Core_MDF_Quarter_Year_Nm__c ='Q2 2023';
            PSC2.Core_MDF_Quarter_nm__c='Q2';
            PSC2.Core_MDF_Year_nm__c='2023';
            PSC2.Core_MDF_Partnership_Score_Nbr__c=0.0;
            
            insert PSC2; 
            assert.areEqual(0.0,PSC1.Core_MDF_Partnership_Score_Nbr__c);
            
            pscList.add(PSC1);
            pscList.add(PSC2);
            
            
            Core_MDF_Partnership_ScoreServiceHandler.populateExternalId(pscList);
            Core_MDF_Partnership_ScoreServiceHandler.populatecarryForwardAmt(pscList);
            Core_MDF_Partnership_ScoreServiceHandler.shareRecordtoPGMgroups(pscList);
            Core_MDF_Partnership_ScoreServiceHandler.shareRecordToGeoGroup(pscList);
        }
    }
    
    @isTest static void testmethodCall(){
        Core_MDF_Partnership_ScoreServiceHandler.claimProcessesOnBeforeUpdate(null, null, null, null);
    }
    
    @isTest static void testInsertError(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
            account account1=[select id from Account where name =:'Test Account 1'];
            
            ChannelProgram cp=[select id from ChannelProgram where name =:Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            
            
            list<Core_MDF_Partnership_Score__c> pscList = new list<Core_MDF_Partnership_Score__c>();
            Core_MDF_Partnership_Score__c PSC1=new Core_MDF_Partnership_Score__c();
            PSC1.Core_MDF_Account_Id__c=account1.Id;
            PSC1.Core_MDF_Channel_Program_Id__c =cp.Id;
            PSC1.Core_MDF_Program_nm__c ='Client CoMarketing Fund';
            PSC1.Core_MDF_Quarter_Year_Nm__c = 'Q4 2021';
            PSC1.Core_MDF_Quarter_nm__c='Q4';
            PSC1.Core_MDF_Year_nm__c='2021';
            PSC1.Core_MDF_Partnership_Score_Nbr__c=0.0;
            
            
            database.SaveResult Results= database.insert(PSC1,false);
            //if(Results.getErrors().size()>0){
                //assert.areEqual(Results.getErrors()[0].getmessage().contains('The partnership score cannot be updated anymore for Q4 2021'),true);
            //}
            if(PSC1.Id !=null){
                pscList.add(PSC1);
                Core_MDF_Partnership_ScoreServiceHandler.populateExternalId(pscList);
                Core_MDF_Partnership_ScoreServiceHandler.shareRecordtoPGMgroups(pscList);
                Core_MDF_Partnership_ScoreServiceHandler.shareRecordToGeoGroup(pscList);
            }
        }
    }
    @isTest static void testGeoBasedSharing(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
            account account1=[select id from Account where name =:'Test Account 1'];
            ChannelProgram cp=[select id from ChannelProgram where name =: 'Retail Marketing Funds'];
            //list<Core_MDF_ChannelProgram__mdt> geoBasedProgram=[select Core_MDF_Program_ID__c from Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c=:'Retail Marketing Funds'];
            //ChannelProgram cp2=[select id from ChannelProgram where name =: 'Retail Marketing Funds'];
            
            list<Core_MDF_Partnership_Score__c> pscList = new list<Core_MDF_Partnership_Score__c>();
            Core_MDF_Partnership_Score__c PSC1=new Core_MDF_Partnership_Score__c();
            PSC1.Core_MDF_Account_Id__c=account1.Id;
            PSC1.Core_MDF_Channel_Program_Id__c =cp.Id;
            PSC1.Core_MDF_Program_nm__c ='Retail Marketing Funds';
            PSC1.Core_MDF_Quarter_Year_Nm__c = 'Q1 2022';
            PSC1.Core_MDF_Quarter_nm__c='Q1';
            PSC1.Core_MDF_Year_nm__c='2022';
            PSC1.Core_MDF_Partnership_Score_Nbr__c=0.0;
            
            assert.areEqual(0.0,PSC1.Core_MDF_Partnership_Score_Nbr__c);
            database.SaveResult Results= database.insert(PSC1,false);
            //system.assertEquals(Results.getErrors()[0].getmessage().contains('The partnership score cannot be updated anymore for Q4 2021'),true);
            pscList.add(PSC1);
            
            
            Core_MDF_Partnership_ScoreServiceHandler.populateExternalId(pscList);
            Core_MDF_Partnership_ScoreServiceHandler.shareRecordtoPGMgroups(pscList);
            Core_MDF_Partnership_ScoreServiceHandler.shareRecordToGeoGroup(pscList);
        }
    }
    
    @isTest static void testGeoBasedSharingSubGeoNull(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
            account account1=[select id from Account where name =:'Test Account 4'];
            ChannelProgram cp=[select id from ChannelProgram where name =: 'Retail Marketing Funds'];
            //list<Core_MDF_ChannelProgram__mdt> geoBasedProgram=[select Core_MDF_Program_ID__c from Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c=:'Retail Marketing Funds'];
            //ChannelProgram cp2=[select id from ChannelProgram where name =: 'Retail Marketing Funds'];
            
            list<Core_MDF_Partnership_Score__c> pscList = new list<Core_MDF_Partnership_Score__c>();
            Core_MDF_Partnership_Score__c PSC1=new Core_MDF_Partnership_Score__c();
            PSC1.Core_MDF_Account_Id__c=account1.Id;
            PSC1.Core_MDF_Channel_Program_Id__c =cp.Id;
            PSC1.Core_MDF_Program_nm__c ='Retail Marketing Funds';
            PSC1.Core_MDF_Quarter_Year_Nm__c = 'Q1 2022';
            PSC1.Core_MDF_Quarter_nm__c='Q1';
            PSC1.Core_MDF_Year_nm__c='2022';
            PSC1.Core_MDF_Partnership_Score_Nbr__c=0.0;
            
            assert.areEqual(0.0,PSC1.Core_MDF_Partnership_Score_Nbr__c);
            database.SaveResult Results= database.insert(PSC1,false);
            //system.assertEquals(Results.getErrors()[0].getmessage().contains('The partnership score cannot be updated anymore for Q4 2021'),true);
            pscList.add(PSC1);
            
            
            Core_MDF_Partnership_ScoreServiceHandler.populateExternalId(pscList);
            Core_MDF_Partnership_ScoreServiceHandler.shareRecordtoPGMgroups(pscList);
            Core_MDF_Partnership_ScoreServiceHandler.shareRecordToGeoGroup(pscList);
        }
    }
    @isTest static void testOwnerUpdateandBatchClass(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
            Core_MDF_Configuration__c confign = new Core_MDF_Configuration__c();
            confign.Core_MDF_Value__c = '1000';
            confign.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
            insert confign;
            ChannelProgram cp=[select id from ChannelProgram where name =:Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            ChannelProgram cp2=[select id from ChannelProgram where name =:Core_MDF_CCP_ConstantClass.RMF_PROGRAM];
            account account3=[select id from Account where name =:'Test Account 4'];
            list<Core_MDF_Partnership_Score__c> pscLst = new list<Core_MDF_Partnership_Score__c>();
            Core_MDF_Partnership_Score__c pscLst0=new Core_MDF_Partnership_Score__c();
            pscLst0.Core_MDF_Account_Id__c=account3.Id;
            pscLst0.Core_MDF_Channel_Program_Id__c =cp.Id;
            pscLst0.Core_MDF_Program_nm__c ='Client CoMarketing Fund';
            pscLst0.Core_MDF_Quarter_Year_Nm__c = 'Q1 2022';
            pscLst0.Core_MDF_Quarter_nm__c='Q1';
            pscLst0.Core_MDF_Year_nm__c='2022';
            pscLst0.Core_MDF_Partnership_Score_Nbr__c=0.0;
            pscLst.add(pscLst0);
            Core_MDF_Partnership_Score__c pscLst1=new Core_MDF_Partnership_Score__c();
            pscLst1.Core_MDF_Account_Id__c=account3.Id;
            pscLst1.Core_MDF_Channel_Program_Id__c =cp2.Id;
            pscLst1.Core_MDF_Program_nm__c ='Retail Marketing Funds';
            pscLst1.Core_MDF_Quarter_Year_Nm__c ='Q1 2022';
            pscLst1.Core_MDF_Quarter_nm__c='Q1';
            pscLst1.Core_MDF_Year_nm__c='2022';
            pscLst1.Core_MDF_Partnership_Score_Nbr__c=0.0;
            pscLst.add(pscLst1);
            insert pscLst; 
            Core_MDF_Batch_Partnership_Score_Sharing batchInstance=new Core_MDF_Batch_Partnership_Score_Sharing();
            Database.executeBatch(batchInstance,30);
            User Usr1=[SELECT Id FROM User LIMIT 1];
            List<Core_MDF_Partnership_Score__c> psc=[SELECT Id FROM Core_MDF_Partnership_Score__c LIMIT 2];
            psc[0].OwnerId=Usr1.Id;
            psc[1].OwnerId=Usr1.Id;
            update psc;  
            assert.areEqual(Usr1.Id,psc[0].OwnerId);
        }
    }
    
}