/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_PGM_Trigger_Test 
* Version     : 1.0 
* Created Date: 17-10-2019
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - NP(11630236) 		    17-10-2019					  Test class for Core_MDF_PGM_Trigger
* Intel - NP(11630236)			17-01-2020					  Made changes to incorporate the new user validation rule on PGM
**************************************************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class Core_MDF_PGM_Trigger_Test {

    @isTest
    static void createPGMRecords(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        usr.FirstName ='PGMTestClass';
        usr.LastName ='User';
        //system.debug('usr.FirstName,'+ usr.FirstName  + usr.LastName);
        Database.insert(usr);

        Map<string,id> accessToGroupIdMap = new Map<string,id>();
        ChannelProgram cpId = [select id from ChannelProgram limit 1];
        Account accId = [select id from Account limit 1];

        //Create Master Group map
        for(Group record: [select id, developername from group limit 2]){
            accessToGroupIdMap.put('Internal',record.id);
            accessToGroupIdMap.put('External',record.id);
        }

        //Create a PGM record
        Core_MDF_Partner_Group_Mapping__c pgmRecord1 = new Core_MDF_Partner_Group_Mapping__c();
        pgmRecord1.Core_MDF_Account__c = accId.id;
        pgmRecord1.Core_MDF_Channel_Program__c = cpId.id;
        pgmRecord1.Core_MDF_Type_of_Access__c ='Internal';
        pgmRecord1.Core_MDF_Group_Name__c = 'Core_MDF_PGM_Trigger_Test_Account_Group';
        
        //Insert PGM record to fire Before and After Insert
        System.runAs(usr){
            Database.insert(pgmRecord1);}
        Core_MDF_Partner_Group_Mapping__c pgmGroupId = [select id,Core_MDF_Group_Id__c from Core_MDF_Partner_Group_Mapping__c limit 1];
        
        //Trigger should get the Group id and update on the PGM record
        System.assertNotEquals(null, pgmGroupId.id);

        //Update the PGM record to fire Before and After Update
        pgmRecord1.Core_MDF_Type_of_Access__c ='External';
        System.runAs(usr){
            Database.update(pgmRecord1);}

        //Delete the PGM record to fire AfterDelete()
        System.runAs(usr){
            Database.delete(pgmRecord1);}

    }

    @TestSetup
    static void createTestRecords(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        Database.insert(usr);

        System.runAs(usr){
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
    
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('PGM Trigger testing Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);      
        acc1.Core_Account_Type__c = 'Reseller';
        acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
        acc1.Industry = 'Food & Beverage';
        acc1.Core_MDF_Channel_Program__c = cp1.Id;
        Database.insert(acc1);

        //Create Master and Sub groups
        List<Group> groupRecords = new List<Group>();
        Group group1 = new Group();
        group1.developername = 'Core_MDF_PGM_Trigger_Test_Account_Group';
        group1.name='PGM Trigger Test Account Group';

        Group group2 = new Group();
        group2.developername = 'Core_MDF_Test_PGM_Trigger_CCF_Internal_All';
        group2.name='Test PGM Trigger CCF Internal All';

        Group group3 = new Group();
        group3.developername = 'Core_MDF_Test_PGM_Trigger_DCF_Internal_All';
        group3.name='Test PGM Trigger DCF Internal All';

        groupRecords.add(group1);groupRecords.add(group2);groupRecords.add(group3);

        Database.insert(groupRecords);
        }      
    }

}