/**************************************************************************************
Apex Class Name : Core_Batch_A_E_PermSet_Mgmt_Test
Version     : 1.0 
Created Date:  03/04/2020
Description : Test class for Core_Batch_A_E_PermSet_Mgmt
* Modification Log :
* Developer                   Date                     Description
* ----------------------------------------------------------------------------
* Pratiksha M                03/04/2020             Original Version
*************************************************************************************/

@isTest(seeAllData=false)
public class Core_Batch_A_E_PermSet_Mgmt_Test {
/****************************************************************************************************************************************
Method Name:	setupMethod                                   
Description:    Method created to create setup data.                               
Added By:  		Accenture – PM  -  03/04/2020
Modified By:           Date:                    Changes: 
Accenture – PM        03/04/2020                Created.
*****************************************************************************************************************************************/       
    @TestSetup static void setupMethod(){
        
        //Role
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        
        // Creating User with utility class 
        User usr01 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr01.profileId = sysAdminProfile.Id;
        usr01.UserRoleId = usRole.Id;
        Database.insert(usr01);
        
        //Running as System Admin
        System.runAs(usr01){
            
            //Create Account
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,Core_CIM_ID__c='12345',
                                              Core_Account_Type__c='Other', Industry='Others',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '1234');
            insert testAccount;
            
            //Creating Contact on above account
            List<Contact> lstContact = new List<Contact>();
            Contact cont = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',
                                          Email='test123@dell.com',MailingCountry='India',
                                          AccountId=testAccount.id);
            
            lstContact.add(cont);
                        
            Contact cont1 = new Contact(Salutation = 'Mr',FirstName = 'Test1',LastName='Contact1',
                                          Email='test12@dell.com',MailingCountry='India',
                                          AccountId=testAccount.id);
            
            lstContact.add(cont1);
            
            Contact cont2 = new Contact(Salutation = 'Mr',FirstName = 'Test2',LastName='Contact2',
                                          Email='test1@dell.com',MailingCountry='India',
                                          AccountId=testAccount.id);
            lstContact.add(cont2);
            
            Contact cont3 = new Contact(Salutation = 'Mr',FirstName = 'Test3',LastName='Contact3',
                                          Email='test3@dell.com',MailingCountry='India',
                                          AccountId=testAccount.id);
            lstContact.add(cont3);
            
            Database.insert(lstContact);
            
            //Creating Partner Profile
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            //Creating Group 
            List<Group> lstGrp = new List<Group>();
            Group groupCreated = new Group(Name='DDR Partner Users1', DeveloperName = 'Core_DDR_Partner_Users1');
            lstGrp.add(groupCreated);
            Group groupCreated1 = new Group(Name='Leads Partner Users1', DeveloperName = 'Core_Leads_Partner_Users1');
            lstGrp.add(groupCreated1);            
            Database.insert(lstGrp);
            
            //Creating user for above contact
            List<User> lstUser = new List<User>();
            User usr = Core_MDF_CCP_TestDataUtility.createUser(false);           
            usr.LastName = 'User Test1';
            usr.ProfileId = partnerProfile.Id;
            usr.Email = 'test123@dell.com';
            usr.ContactId = cont.Id;
            lstUser.add(usr);
            
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test2';
            usr1.ProfileId = partnerProfile.Id;
            usr1.Email = 'test12@dell.com';
            usr1.ContactId = cont1.Id;
            lstUser.add(usr1);
            
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test3';
            usr2.ProfileId = partnerProfile.Id;
            usr2.Email = 'test1@dell.com';
            usr2.ContactId = cont2.Id;
            lstUser.add(usr2);
            
            Database.insert(lstUser);
            
            //Create Permission sets
            List<PermissionSet> lstPSName = new List<PermissionSet>();
            PermissionSet ps1 = new PermissionSet(Name='Core_MDF_CCF_USER1', Label='CCP CCF USER1');
            PermissionSet ps2 = new PermissionSet(Name='Core_MDF_DCF_USER1', Label='CCP DCF USER1');
            PermissionSet ps3 = new PermissionSet(Name='Core_MDF_CCF_Boost_USER1', Label='CCP CCF Boost USER1');
            PermissionSet ps4 = new PermissionSet(Name='Core_MDF_CCP_SPCF_USER1', Label='CCP SPCF USER1');
            PermissionSet ps5 = new PermissionSet(Name='Core_MDF_CCP_Clubbed_PS1', Label='CCP Clubbed PS1');
            PermissionSet ps6 = new PermissionSet(Name='Core_MDF_CCP_Clubbed_PS2', Label='CCP Clubbed PS2');
            lstPSName.add(ps1);
            lstPSName.add(ps2);
            lstPSName.add(ps3);
            lstPSName.add(ps4);
            lstPSName.add(ps5);
            lstPSName.add(ps6);
            database.insert(lstPSName);
            
            //Create Records for ERPM Engagement
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name ='CCF', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='CCF');
            insert cee;
            
            //create Records for Entitlements
            List< Core_Entitlement__c> entListVal = new List< Core_Entitlement__c>();
            Core_Entitlement__c entitle1 = new Core_Entitlement__c (name ='CCF User', Core_Category__c='Intel® Partner Investment Center',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='CCF User',Core_IsActive__c=true,Core_Permission_Set_API_Nm__c='Core_MDF_CCF_USER1;Core_MDF_CCP_SPCF_USER1',Core_Public_Group_API_Nm__c='Core_DDR_Partner_Users1');
            entListVal.add(entitle1);
          
            Core_Entitlement__c entitle2 = new Core_Entitlement__c (name ='DCF User', Core_Category__c='Intel® Partner Investment Center',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='DCF User',Core_IsActive__c=true,Core_Permission_Set_API_Nm__c='Core_MDF_DCF_USER1');
            entListVal.add(entitle2); 
       
            Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='SPCF User', Core_Category__c='Intel® Partner Investment Center',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='SPCF User',Core_IsActive__c=true,Core_Permission_Set_API_Nm__c='Core_MDF_CCP_SPCF_USER1',Core_Public_Group_API_Nm__c='Core_Leads_Partner_Users1');
            entListVal.add(entitle3);
            
            Core_Entitlement__c entitle4 = new Core_Entitlement__c (name ='CCF Boost USer', Core_Category__c='Intel® Partner Investment Center',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='CCF Boost User',Core_IsActive__c=true,Core_Permission_Set_API_Nm__c='Core_MDF_CCF_Boost_USER1');
            entListVal.add(entitle4); 
            
            Core_Entitlement__c entitle5 = new Core_Entitlement__c (name ='CCF Boost USer1', Core_Category__c='Intel® Partner Investment Center',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='CCF Boost User1',Core_IsActive__c=true,Core_Permission_Set_API_Nm__c='Core_MDF_CCF_Boost_USER1');
            entListVal.add(entitle5); 
            
            database.insert(entListVal);  
            
            //Create records for Contact Entitlements
            List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
            
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont.Id,
                                                                             Core_Entitlement_Id__c=entitle1.id,
                                                                             Core_Status__c ='Complete',
                                                                             Core_Selected__c=true);
            ceList.add(ce1);       
            Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont.Id,
                                                                              Core_Entitlement_Id__c=entitle2.id,
                                                                              Core_Status__c ='Complete',
                                                                              Core_Selected__c=true);
            ceList.add(ce2);
            Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont.Id,
                                                                              Core_Entitlement_Id__c=entitle3.id,
                                                                              Core_Selected__c=false,
                                                                              Core_Status__c ='Complete');
            ceList.add(ce3);           
            Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont2.Id,
                                                                              Core_Entitlement_Id__c=entitle3.id,
                                                                              Core_Selected__c=false,
                                                                              Core_Status__c ='Complete');
            ceList.add(ce4);
            Core_Contact_Entitlement__c ce5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont2.Id,
                                                                              Core_Entitlement_Id__c=entitle4.id,
                                                                              Core_Status__c ='Complete',
                                                                              Core_Selected__c=false);
            ceList.add(ce5);
            Core_Contact_Entitlement__c ce6 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont1.Id,
                                                                              Core_Entitlement_Id__c=entitle1.id,
                                                                              Core_Status__c ='Complete',
                                                                              Core_Selected__c=true);
            ceList.add(ce6);
            database.insert(ceList);
            
            //create records for PermissionSetAssignment
            List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>();
            PermissionSetAssignment psa1 = new PermissionSetAssignment (PermissionSetId = ps4.id,
                                                                       AssigneeId = usr.id);
            lstPSA.add(psa1);
            PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = ps3.id,
                                                                       AssigneeId = usr.id);
            lstPSA.add(psa2);
            PermissionSetAssignment psa3 = new PermissionSetAssignment (PermissionSetId = ps4.id,
                                                                       AssigneeId = usr2.id);
            lstPSA.add(psa3);
            PermissionSetAssignment psa4 = new PermissionSetAssignment (PermissionSetId = ps3.id,
                                                                       AssigneeId = usr2.id);
            lstPSA.add(psa4);
            
            database.insert(lstPSA);
            
            //Create Records for GroupMember
            List<GroupMember> lstGrpMem = new List<GroupMember>();
            GroupMember grpmem = new GroupMember (GroupId = groupCreated1.id , UserOrGroupId = usr2.id);
            lstGrpMem.add(grpmem);
            GroupMember grpmem1 = new GroupMember (GroupId = groupCreated1.id , UserOrGroupId = usr.id);
            lstGrpMem.add(grpmem1);
            Database.insert(lstGrpMem);
        }        
    }
    
    @isTest public static void testBatch(){
        Test.startTest();
        Core_Batch_A_E_PermSet_Mgmt testBatch = new Core_Batch_A_E_PermSet_Mgmt();
        Id idBatch = database.executebatch(testBatch);
        Test.stopTest();
        system.assertEquals(true, idBatch != null? true : false , 'Batch executed successfully');
    }
    
    @isTest public static void testScheduler(){
        Test.startTest();
        Core_Batch_A_E_PermSet_Mgmt_Scheduler sh1 = new Core_Batch_A_E_PermSet_Mgmt_Scheduler();      
        String sch = '0 0 23 * * ?';
        String jobId = system.schedule('Test check', sch, sh1);
        Test.stopTest();
        system.assertEquals(true, jobId != null? true : false , 'Scheduled successfully');
        //system.debug('batch scheduler  -->'+ jobId != null? true : false);

    }
    
}