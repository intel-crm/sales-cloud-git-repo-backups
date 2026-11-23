/****************************************************************************************************************************************
* Class Name  : Core_MDF_PGDMServiceHandler_Test
* Version     : 1.0
* Created Date: 16-Mar-2020
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       16-Mar-2020       Test class to cover service handler class
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_PGDMServiceHandler_Test {
    @TestSetup static void setUpData(){
        
        List<Group> groupList = new List<Group>();
        List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
        
        test.starttest();
        // Creating Intel Account with utility class
        List<Account> acctList = new List<Account>();
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acctList.add(acc1);
        acctList.add(acc2);
        
        database.insert(acctList);
        
        Id level2ProfileId = [SELECT Id FROM Profile WHERE Name='Comarketing Support L2' LIMIT 1].Id;
       
        List<User> usrList = new List<User>();
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='testUsercoreMDF@intel.com';
        usr1.ProfileId = level2ProfileId;
        usr1.isActive = true;
        usrList.add(usr1);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='sysadm@example.com';
        usr1.isActive = true;
        usrList.add(usr2);
        system.debug('usrsListVD'+usrList);
        Database.insert(usrList);
                        
        // Creating Channel program
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
        channelProgramList.add(cp);
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
        channelProgramList.add(cp1);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Service Provider Co-Marketing Fund','Service Provider CoMarketing Fund', false);
        channelProgramList.add(cp2);

        Database.insert(channelProgramList);
    
        //Creating groups For PGM
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        groupList.add(grp);
        
        Group grp1 = new Group();
        grp1.name = 'PGM_TEST1';
        groupList.add(grp1);
        
        Group grp2 = new Group();
        grp2.name = 'PGM_TEST2';
        groupList.add(grp2);
                
        Group grp3 = new Group();
        grp3.name = 'PGM_TEST3';
        groupList.add(grp3);
        
        Database.insert(groupList);
        
        Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
        pgm.Core_MDF_Account__c = acc1.Id;
        pgm.Core_MDF_Group_Name__c = 'PGM_TEST';
        pgm.Core_MDF_Type_of_Access__c = 'External';
        pgm.Core_MDF_Channel_Program__c = cp.Id;
        database.insert(pgm);
        
        Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
        pgm1.Core_MDF_Account__c = acc1.Id;
        pgm1.Core_MDF_Group_Name__c = 'PGM_TEST1';
        pgm1.Core_MDF_Type_of_Access__c = 'External';
        pgm1.Core_MDF_Channel_Program__c = cp1.Id;
        database.insert(pgm1); 
        
        Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
        pgm2.Core_MDF_Account__c = acc2.Id;
        pgm2.Core_MDF_Group_Name__c = 'PGM_TEST2';
        pgm2.Core_MDF_Type_of_Access__c = 'External';
        pgm2.Core_MDF_Channel_Program__c = cp1.Id;
        database.insert(pgm2);
        
        test.stoptest();
    }   
    @isTest static void insertDomainRecTest(){
        
        test.startTest();
        User usr =[SELECT Id,Email from User where Email ='testUsercoreMDF@intel.com' limit 1];
        User user2 =[SELECT Id,Email from User where Email ='sysadm@example.com' limit 1];
        ChannelProgram cp3 = [Select Name from ChannelProgram where Name = 'Service Provider Co-Marketing Fund' LIMIT 1];
        Group grp3 = [Select name from Group where name='PGM_TEST3' LIMIT 1] ;
        Account acc1 = [Select Name from Account where name='Test Acc New 1'];
        
        system.runAs(usr){
            Core_MDF_Partner_Group_Mapping__c pGM1 =[SELECT id from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Group_Name__c='PGM_TEST'];
            Core_MDF_Partner_Group_Mapping__c pGM2 =[SELECT id from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Group_Name__c='PGM_TEST1'];
            
            
            Core_MDF_Partner_Group_Domain_Mapping__c pGDM1 = new Core_MDF_Partner_Group_Domain_Mapping__c();
            pGDM1.Core_MDF_Partner_Group_Mapping_Id__c=pGM1.Id;
            pGDM1.Name='abcd.com';
            database.insert(pGDM1);           
            
            List<Core_MDF_Partner_Group_Domain_Mapping__c> PGDMList= [SELECT id,Core_MDF_Partner_Group_Mapping_Id__c,Name from Core_MDF_Partner_Group_Domain_Mapping__c
                                                                      where Core_MDF_Partner_Group_Mapping_Id__c=: pGM2.Id];
            
            system.assertEquals('abcd.com',PGDMList[0].Name);
            
            try{
                Core_MDF_Partner_Group_Domain_Mapping__c pGDM3 = new Core_MDF_Partner_Group_Domain_Mapping__c();
                pGDM3.Core_MDF_Partner_Group_Mapping_Id__c=pGM1.Id;
                pGDM3.Name='abcd.com';
                database.insert(pGDM3);             
            } 
            catch(Exception e){
                String errorMessage = e.getMessage();
                System.assert(errorMessage.contains(System.Label.Core_MDF_PGDMDuplicateError)); 
            }
        }
        //system.runAs(user2){
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = acc1.Id;
            pgm.Core_MDF_Group_Name__c = grp3.Name;
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Channel_Program__c = cp3.Id;
            database.insert(pgm);
       // }
        system.runAs(usr){
            Core_MDF_Partner_Group_Mapping__c pGM3 =[SELECT id from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Group_Name__c='PGM_TEST3'];
            
            Core_MDF_Partner_Group_Domain_Mapping__c pGDM4 = new Core_MDF_Partner_Group_Domain_Mapping__c();
            pGDM4.Core_MDF_Partner_Group_Mapping_Id__c=pGM3.Id;
            pGDM4.Name='abcd.com';
            database.insert(pGDM4); 
        }
        
        test.stoptest();
    }

    @isTest static void dupChkForOtherAcctTest(){
        test.startTest();
        User user1 =[SELECT Id,Email from User where Email ='testUsercoreMDF@intel.com' limit 1];                
        system.runAs(user1){
            Core_MDF_Partner_Group_Mapping__c pGM3 =[SELECT id from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Group_Name__c='PGM_TEST2'];
            
            try{
                Core_MDF_Partner_Group_Domain_Mapping__c pGDM3 = new Core_MDF_Partner_Group_Domain_Mapping__c();
                pGDM3.Core_MDF_Partner_Group_Mapping_Id__c=pGM3.Id;
                pGDM3.Name='abcd.com';
                database.insert(pGDM3);             
            } 
            catch(Exception e){
                String errorMessage = e.getMessage();
                System.assert(errorMessage.contains(System.Label.Core_MDF_PGDMDuplicateError)); 
            } 
        }                
        test.stopTest();
    }
    
    @isTest static void chkNullTest(){        
        Core_MDF_PGDMServiceHandler.checkDuplicatePGDMRecords(null);      
    }
}