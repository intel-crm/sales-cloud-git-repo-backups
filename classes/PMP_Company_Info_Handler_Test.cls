@isTest
public class PMP_Company_Info_Handler_Test {
    
   /*  @isTest
    public static void testHandler() {
        Test.startTest();
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Company_Info_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs;
         
        Core_Trigger_Executions__c cs1 = new Core_Trigger_Executions__c (Name = 'MPI_Mem_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs1;
        
        Core_Trigger_Executions__c cs2 = new Core_Trigger_Executions__c (Name = 'MPI_Auto_Benefit_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs2;
        Core_Trigger_Executions__c cs3 = new Core_Trigger_Executions__c (Name = 'OPID_MPI_Validation_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update, Before Update',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs3;
       
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newAccount;
        Set<Id> accIds = new Set<Id> { newAccount.Id };
            
        PMP_Company__c company = new PMP_Company__c();
        company.Name='company1';
        company.PMP_IPA_Badge_Tier_Txt__c='testTier';
        
        company.PMP_Account_Id__c=newAccount.Id;
        insert company;
        
        PMP_Company__c company2 = new PMP_Company__c();
        company2.Name='company2';
        company2.PMP_IPA_Badge_Tier_Txt__c='testTier';
        
        company2.PMP_Account_Id__c=newAccount.Id;
        insert company2;
        
        company2.PMP_IPA_Badge_Tier_Txt__c = 'testTierUpdated';
        update company2;
        
        Test.stopTest();
    } 
*/
    
   @isTest
    public static void testHandler1(){
    
       // system.debug('limitQueries1:'+Limits.getQueries());
      
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        //createUserRole();
        UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
        adminUser.userRoleId = role.id;
        update adminUser;
      //  assignRole(adminUser, role.id );
        
        //Need to run as admin with RoleId, to insert a partner User.
        System.runAs(adminUser) {
        
          /**** Fetching Record TypeId from custom label******/
            String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        List<Account> accts = new List<Account>();   
           
            Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Company_Info_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs;
         
        Core_Trigger_Executions__c cs1 = new Core_Trigger_Executions__c (Name = 'MPI_Mem_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs1;
        
        Core_Trigger_Executions__c cs2 = new Core_Trigger_Executions__c (Name = 'MPI_Auto_Benefit_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs2;
        Core_Trigger_Executions__c cs3 = new Core_Trigger_Executions__c (Name = 'OPID_MPI_Validation_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update, Before Update',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs3;
       
        Core_Trigger_Executions__c cs4 = new Core_Trigger_Executions__c (Name = 'PMP_Companyinfosharing_handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update and create Partners');
        insert cs4;
            
            Core_Trigger_Executions__c cs5 = new Core_Trigger_Executions__c (Name = 'PMP_OPID_MPI_OfferingSharing_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Partner_Offering__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update and create Offering');
        insert cs5;
            
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                      Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        accts.add(partnerAccount1);
        Account partnerAccount2 = new Account(Name ='PartnerAccount2',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                      Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        accts.add(partnerAccount2);
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Distributor',
                                            Core_Sales_Group_New__c= 'CCG Sales Group',
                                            Industry='Agriculture', BillingCity='delhi',
                                            BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts.add(intelAccount1);
        Account intelAccount2 = new Account(Name ='IntelAccount2',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                      Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts.add(intelAccount2);
        Database.insert(accts);
               
        List<Account> intelAccId1 = [SELECT ID,Name FROM Account where Name ='IntelAccount1'];
        List<Account> intelAccId2 = [SELECT ID,Name FROM Account where Name ='IntelAccount2'];
        List<Account> partnerAccountIdVar1 = [SELECT ID,Name FROM Account where Name ='PartnerAccount1'];
        List<Account> partnerAccountIdVar2 = [SELECT ID,Name FROM Account where Name ='PartnerAccount2'];
        
        List<Account>accToUpdate = new List<Account>();
        For(Account acc:accts){
            acc.IsPartner = true;
            accToUpdate.add(acc);
        }
        Database.update(accToUpdate);
        // System.debug('accToUpdate ='+accToUpdate);
        // system.debug('limitQueries1:'+Limits.getQueries());
        List<Core_Account_Group_Member__c>accGrpMembers = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
        accGroupMem1.Core_Partner_Account_Id__c =partnerAccountIdVar1[0].Id;
        accGroupMem1.Core_Intel_Account_Id__c =intelAccId1[0].Id;
        accGrpMembers.add(accGroupMem1);
    
        Core_Account_Group_Member__c accGroupMem2 = new Core_Account_Group_Member__c();
        accGroupMem2.Core_Partner_Account_Id__c =partnerAccountIdVar2[0].Id;
        accGroupMem2.Core_Intel_Account_Id__c =intelAccId2[0].Id;
        accGrpMembers.add(accGroupMem2);
        
        Database.insert(accGrpMembers);
       
        List<Contact> contacts = new List<Contact>();
        Contact contact1 = new Contact(firstname='Partner', 
                lastname='Contact1', accountId=intelAccId1[0].id,Email='dellco12341@dell.com',mailingcountry='India');
        contacts.add(contact1);
        Contact contact2 = new Contact(firstname='Partner', 
                lastname='Contact2', accountId=intelAccId2[0].id,Email='dellco12342@dell.com',mailingcountry='India');
        contacts.add(contact2); 
        Contact contact3 = new Contact(firstname='Partner', 
                lastname='Contact3', accountId=intelAccId1[0].id,Email='dellco123421`@dell.com',mailingcountry='India');
        contacts.add(contact3);     
        Database.insert(contacts);
        // system.debug('limitQueries1:'+Limits.getQueries());
    List<User> userList = new List<User>();
        /*User currentUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        List<User> userList = new List<User>();
        System.debug('currentUser = '+currentUser);
        
        System.runAs (currentUser) {
          */  
            UserRole userRole = [Select Id, PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
            // system.debug('userRole ' + userRole);
            
            
            Profile profile = [select Id,name from Profile where Name ='Partner'];
            
            User newUser1 = new User(
                //UserRoleId = userRole.Id,
                profileId = profile.id, 
                username = 'testUser1'+String.valueOf(Math.random())+'@CoreMD.com', 
                email = 'pb1@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname', 
                contactId = contact1.id
            );
            User newUser2 = new User(
                //UserRoleId = userRole.Id,
                profileId = profile.id, 
                username = 'testUser2'+String.valueOf(Math.random())+'@CoreMD.com', 
                email = 'pb2@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname', 
                contactId = contact2.id
            );
            
             User newUser3 = new User(
                //UserRoleId = userRole.Id,
                profileId = profile.id, 
                username = 'testUser1'+String.valueOf(Math.random())+'@CoreMD.com', 
                email = 'pb1@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname', 
                contactId = contact3.id
            );
            userList.add(newUser1);
            userList.add(newUser2);
            userList.add(newUser3);
            Database.insert(userList);
            List<Group> lstGrps = new List<Group>();
            
             Group grp1 = new Group(Name ='PMP_001',DeveloperName='PMP_001');
             Group grp2 = new Group(Name ='PMP_00112',DeveloperName='PMP_00112');
             lstGrps.add(grp1);
             lstGrps.add(grp2);
             Database.insert(lstGrps);
            
            List<GroupMember> lstGrpMem = new List<GroupMember>();
            GroupMember grpMem = new GroupMember();
            grpMem.UserOrGroupId = newUser1.Id;
            grpMem.GroupId =grp1.Id;     //pmpGroup.Id;
            lstGrpMem.add(grpMem);
            // System.debug('newUser1.Id ='+newUser1.Id);
              GroupMember grpMem2 = new GroupMember();
            grpMem2.UserOrGroupId = newUser3.Id;
            grpMem2.GroupId =grp1.Id;     //pmpGroup.Id;
            lstGrpMem.add(grpMem2);
            // System.debug('newUser3.Id ='+newUser1.Id);
            
            List<GroupMember> listGm = [Select Id,GroupId from GroupMember where GroupId=:grp1.Id];
            // System.debug('listGm ='+listGm);
            
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = newUser2.Id;
            grpMem1.GroupId =grp2.Id;     //pmpGroup.Id;
            lstGrpMem.add(grpMem1);
            Database.insert(lstGrpMem);
            // System.debug('userList = '+ userList);
    
            List<PMP_Company__c> compinfo= new List<PMP_Company__c>(); 
             //IPA: Benefit changes
             //PMP_Company__c newcompany1 = new PMP_Company__c(OwnerId=newUser1.Id, Name='companyinformationtest1',
                                                           //PMP_Account_Industry__c='Agriculture',PMP_Is_Published_Ind__c=true,/*PMP_Is_Working_Copy_Ind__c=true,*/PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced);
             PMP_Company__c newcompany1 = new PMP_Company__c(OwnerId=newUser1.Id, Name='companyinformationtest1',
                                                           PMP_Account_Industry__c='Agriculture',PMP_Is_Published_Ind__c=true,/*PMP_Is_Working_Copy_Ind__c=true,*/PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile);
            
            
            
            // system.debug('limitQueriestotalLImit1:'+Limits.getLimitQueries());
            //PMP_Company__c newcompany = new PMP_Company__c(Name='companyinformationtest',
                                                           //PMP_Account_Industry__c='Agriculture',/*PMP_Is_Working_Copy_Ind__c=true,*/PMP_Is_Published_Ind__c=true,PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced);
             PMP_Company__c newcompany = new PMP_Company__c(Name='companyinformationtest',
                                                           PMP_Account_Industry__c='Agriculture',/*PMP_Is_Working_Copy_Ind__c=true,*/PMP_Is_Published_Ind__c=true,PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile);
            
            
            
           /*  PMP_Company__c newcompany2 = new PMP_Company__c(Name='companyinformationtest2',
                                                           PMP_Account_Industry__c='Agriculture',PMP_Working_Copy_Id__c=newcompany.Id,PMP_Is_Published_Ind__c=true,PMP_Is_Working_Copy_Ind__c=true);
           
            */
            compinfo.add(newcompany);
            compinfo.add(newcompany1);
            /*compinfo.add(newcompany2);*/
            Database.insert(compinfo);
            // system.debug('limitQueries1:'+Limits.getQueries());
            PMP_Partner_Offering__c newOffering = new PMP_Partner_Offering__c(Name='offeringtest',PMP_Partner_Offering_Nm__c = 'offeringtest',PMP_Partner_Offering_Visibility_Nm__c='Public Content',PMP_Partner_Offering_Lifecycle_Status_Nm__c='Draft',PMP_Company_Id__c=newcompany1.Id);
            insert newOffering;
            
            newOffering.PMP_Company_Id__c=newcompany.Id;
            update newOffering;
            Test.startTest();

            PMP_OPID_MPI_Rel__c jun1= new PMP_OPID_MPI_Rel__c();
            jun1.PMP_One_Partner_ID__c= partnerAccountIdVar1[0].Id;
            jun1.PMP_Marketing_Profile_Id__c= newcompany1.Id;
            jun1.Is_Active__c=true;     
            insert jun1;
            // system.debug('limitQueries1:'+Limits.getQueries());
            
            PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
            jun.PMP_One_Partner_ID__c= partnerAccountIdVar2[0].Id;
            jun.PMP_Marketing_Profile_Id__c= newcompany.Id;
            jun.Is_Active__c=true;     
            insert jun;

            //system.debug('limitQueries1:'+Limits.getQueries());
            
            /*PMP_OPID_MPI_Rel__c jun2= new PMP_OPID_MPI_Rel__c();
            jun2.PMP_One_Partner_ID__c= partnerAccountIdVar1[0].Id;
            jun2.PMP_Marketing_Profile_Id__c= newcompany2.Id;
            jun2.Is_Active__c=true;     
            insert jun2;
            */
            List<PMP_Company__Share> partCompanyInfoShareList = new List<PMP_Company__Share>();
            PMP_Company__Share partCompanyInfoShare = new PMP_Company__Share();
                        partCompanyInfoShare.AccessLevel  = 'Edit';
                        partCompanyInfoShare.UserOrGroupId  = grp1.Id;
                        partCompanyInfoShare.ParentId = newcompany.Id;
                        partCompanyInfoShareList.add(partCompanyInfoShare);
            
           /* PMP_Company__Share partCompanyInfoShare1 = new PMP_Company__Share();
                        partCompanyInfoShare1.AccessLevel  = 'Read';
                        partCompanyInfoShare1.UserOrGroupId  = grp1.Id;
                        partCompanyInfoShare1.ParentId = newcompany2.Id;
                        partCompanyInfoShareList.add(partCompanyInfoShare1);*/
            Database.insert(partCompanyInfoShareList);
       
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PMP_External_Partner_Admin'];
            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = newUser3.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
            //Updating Account on the Company Info
            newcompany1.OwnerId = newUser3.Id;//newUser2.Id
            
          
            Database.update(newcompany1);
           
            newcompany1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
            Database.update(newcompany1);
            // system.debug('limitQueries21:'+Limits.getQueries());
            //system.debug('limitQueriestotalLImit2:'+Limits.getLimitQueries());
            Test.stopTest();
            //system.debug('limitQueries2:'+Limits.getQueries());
            System.assertNotEquals(ps.Id, null);
    }
  }
}