/**************************************************************************************
Apex Class Name : PMP_PAG_Dashboard_Test
Version     : 1.0 
Description : Test class for PMP_PAG_Dashboard_Handler
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Raushan                                			Original Version
*************************************************************************************/




@isTest(SeeAllData=false)
public class PMP_Marketplace_Metric_Test {
    
    @testSetup 
    static void setup() {
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        //Id pagDashboardRecTypeId = Schema.SObjectType.PMP_Marketplace_Metric__c.getRecordTypeInfosByName().get('Pag Dashboards').getRecordTypeId();
        List<Account> accList = new List<Account>();
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',
                                              BillingStreet='abc chowk delhi');
        accList.add(partnerAccount1);
        Account partnerAccount2 = new Account(Name ='PartnerAccount2',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',
                                              BillingStreet='abc chowk delhi');
        accList.add(partnerAccount2);
        //Database.insert(accList);
        
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        accList.add(intelAccount1);
        Account intelAccount2 = new Account(Name ='IntelAccount2',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        accList.add(intelAccount2);
        Account intelAccount3 = new Account(Name ='IntelAccount3',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'CCG Sales Group',
                                                Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        accList.add(intelAccount3);
        Database.insert(accList);
		
		
		List<Contact> allContacts = new List<Contact>();
            Contact contact1 = new Contact(firstname='Intel', 
                    lastname='Contact1', accountId=intelAccount1.id,Email='dellco1234@dell.com',Core_IPA_Contact_Segment__c ='Client Computing');
            allContacts.add(contact1);
            Contact contact2 = new Contact(firstname='Intel', 
                    lastname='Contact2', accountId=intelAccount1.id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact2);
            
            
            Contact contact3 = new Contact(firstname='Intel', 
                    lastname='Contact3', accountId=intelAccount2.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact3);
        	
        	Contact contact4 = new Contact(firstname='Intel', 
                    lastname='Contact4', accountId=intelAccount1.Id,
                                           Email='dellco12345@dell.com');
            allContacts.add(contact4);
			
			Database.insert(allContacts,false);
        
        	User currentUser = [select Id from User where Id = :UserInfo.getUserId()];
        	List<User> userList = new List<User>();
        	System.runAs (currentUser) {
                
                //UserRole userRole = [Select PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
                Profile profile = [select Id,name from Profile where Name ='Partner'];
                User usr1 = new User(profileId = profile.id,username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com',
                                       email = 'pb@ff.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                       timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='Contact1',contactId = contact1.Id);
                
                User usr2 = new User(profileId = profile.id,username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com',
                                       email = 'pb@ff.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                       timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='Contact2',contactId = contact2.Id);
                
                User usr3 = new User(profileId = profile.id,username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com',
                                       email = 'pb@ff.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                       timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='Contact3',contactId = contact3.Id);
                User usr4 = new User(profileId = profile.id,username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com',
                                       email = 'pb@ff.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                       timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='Contact4',contactId = contact4.Id);

                
                userList.add(usr1);
                userList.add(usr2);
                userList.add(usr3);
                userList.add(usr4);
                /*for(Contact con:allContacts){
                    // Creating user
                    User newUser = new User(
                   // UserRoleId = userRole.Id,
                    profileId = profile.id, 
                    username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com', 
                    email = 'pb@ff.com', 
                    emailencodingkey = 'UTF-8', 
                    localesidkey = 'en_US', 
                    languagelocalekey = 'en_US', 
                    timezonesidkey = 'America/Los_Angeles', 
                    alias='nuser', 
                    lastname='lastname', 
                    contactId = con.Id
                );
                    userList.add(newUser);
                }*/
                //Inserting User
                Database.insert(userList);
                
            }
			System.debug('1. usercon12='+userList[0].lastname);
			System.debug('2. usercon12='+userList[1].lastname);
			System.debug('3. usercon13='+userList[2].lastname);
			System.debug('4. usercon14='+userList[3].lastname);
			/****** Creating ERPM_Engagement record*****/
            Core_ERPM_Engagement__c erpmEng1 =new Core_ERPM_Engagement__c(Name  ='Intel Premier Support',Core_IsActive__c=true);
            Database.insert(erpmEng1);
			
			
			List<Core_Entitlement__c> ent = new List<Core_Entitlement__c>();

            Core_Entitlement__c entitlement1 = new Core_Entitlement__c(Name='Marketing Specialist',
                                                                      Core_Display_Name__c='Marketing Specialist',Core_ERPM_Engagement_Id__c=erpmEng1.id);
            ent.add(entitlement1);
             
           Core_Entitlement__c entitlement2 = new Core_Entitlement__c(Name='Offering Editor',
                                                                      Core_Display_Name__c='Offering Editor',Core_ERPM_Engagement_Id__c=erpmEng1.id);
            ent.add(entitlement2);
			Database.insert(ent);
			
			String ldrEntId = System.Label.Core_Lead_Development_Representative ;
           String partAdminEntId = System.Label.Core_Partner_Admin ;
           /****** Creating Contact Entitlement records*****/
           List<Core_Contact_Entitlement__c> conEnt = new List<Core_Contact_Entitlement__c>();
                   //for(Core_Entitlement__c entId:ent){
                   Core_Contact_Entitlement__c contactEntitlement1 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement2.Id,Core_Contact_Id__c=contact1.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete');
                   Core_Contact_Entitlement__c contactEntitlement2 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=ldrEntId,Core_Contact_Id__c=contact1.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete');
                   Core_Contact_Entitlement__c contactEntitlement3 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=partAdminEntId,Core_Contact_Id__c=contact1.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete');
                   
                   Core_Contact_Entitlement__c contactEntitlement4 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement1.Id,Core_Contact_Id__c=contact2.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete');
           conEnt.add(contactEntitlement1);
		   conEnt.add(contactEntitlement2);
		   conEnt.add(contactEntitlement3);
		   conEnt.add(contactEntitlement4);
		   
		   Database.insert(conEnt);
         List<Group> grpNames = new List<Group>();
        System.runAs(currentUser){
            
        //List<Group> grpNames = new List<Group>();
        String grpName = 'PMP_'+partnerAccount1.Id;
        String leadGroupName = 'PMP_'+partnerAccount1.Id+'_Leads';
        String segmentGroup = 'PMP_'+partnerAccount1.Id+'_'+contact1.Core_IPA_Contact_Segment__c;
        System.debug('grpName ='+grpName);
        Group grp = new Group(Name =grpName);
        Group grp1 = new Group(Name =leadGroupName);
        Group grp2 = new Group(Name =segmentGroup);
        grpNames.add(grp);
        grpNames.add(grp1);
        grpNames.add(grp2);
        Database.insert(grpNames);
       // User u1 = [Select Id,Name From User Where Id=usr1.id];
        //User u2 = [Select Id,Name From User Where Id=usr2.id];
        //User u3 = [Select Id,Name From User Where Id=usr3.id];
        List<GroupMember> groupMembers = new List<GroupMember> ();
        GroupMember gm1 = new GroupMember(GroupId =grp.id,UserOrGroupId=userList[0].Id);
        GroupMember gm2 = new GroupMember(GroupId =grp.id,UserOrGroupId=userList[1].Id);
        GroupMember gm3 = new GroupMember(GroupId =grp.id,UserOrGroupId=userList[2].Id);
        GroupMember gm4 = new GroupMember(GroupId =grp1.id,UserOrGroupId=userList[1].Id);
		GroupMember gm6 = new GroupMember(GroupId =grp1.id,UserOrGroupId=userList[3].Id);
        GroupMember gm5 = new GroupMember(GroupId =grp2.id,UserOrGroupId=userList[0].Id);
        
        groupMembers.add(gm1);
        groupMembers.add(gm2);
        groupMembers.add(gm3);
        groupMembers.add(gm4);
        groupMembers.add(gm5);
        groupMembers.add(gm6);
        
        Database.insert(groupMembers,false);
            
        System.debug('userorgroup id ='+gm4.UserOrGroupId);
        System.debug('group id ='+gm4.GroupId);
        
    }
        
        /****** Creating Partner account group member record*****/
            List<Core_Account_Group_Member__c> allPag = new List<Core_Account_Group_Member__c>();
            Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
            accGroupMem1.Core_Partner_Account_Id__c =partnerAccount1.Id;
            accGroupMem1.Core_Intel_Account_Id__c =intelAccount1.Id;
            //accGroupMem1.Core_Partner_Account_Id__r.Core_PMP_Membership_Change_Ind__c = true;
            accGroupMem1.Core_MDA_Ind__c = true;
            allPag.add(accGroupMem1);
            
            Core_Account_Group_Member__c accGroupMem2 = new Core_Account_Group_Member__c();
            
            accGroupMem2.Core_Partner_Account_Id__c =partnerAccount1.Id;
            accGroupMem2.Core_Intel_Account_Id__c =intelAccount2.Id;
            accGroupMem2.Core_MDA_Ind__c = true;
            allPag.add(accGroupMem2);
            
            Core_Account_Group_Member__c accGroupMem3 = new Core_Account_Group_Member__c();
            accGroupMem3.Core_Partner_Account_Id__c =partnerAccount2.Id;
            accGroupMem3.Core_Intel_Account_Id__c =intelAccount3.Id;
            accGroupMem3.Core_MDA_Ind__c = true;
            allPag.add(accGroupMem3);
        Database.insert(allPag);
        AccountShare acctShare = new AccountShare(AccountId =partnerAccount1.Id,UserOrGroupId =grpNames[0].Id,AccountAccessLevel ='Read',OpportunityAccessLevel ='Read');
        Database.insert(acctShare);
        List<PMP_Marketplace_Metric__c> pagDashboardRecs = new List<PMP_Marketplace_Metric__c>();
        PMP_Marketplace_Metric__c pagDash1 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_PAG_NOT_CREATED');
        PMP_Marketplace_Metric__c pagDash2 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_PARTNER_ACCT_NOT_SHARED');
        PMP_Marketplace_Metric__c pagDash3 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_PARTNER_ACCT_WRONGLY_SHARED');
        PMP_Marketplace_Metric__c pagDash4 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_NON_ELG_PAG_ADDED_IN_ODM');
        PMP_Marketplace_Metric__c pagDash5 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_NON_ELG_PAG_ADDED_IN_NON_ODM');
        PMP_Marketplace_Metric__c pagDash6 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_PAG_ADDED_IN_BOTH_ODM_AND_NON_ODM');
        PMP_Marketplace_Metric__c pagDash7 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_LEAD_GRP_NOT_CREATED');
        PMP_Marketplace_Metric__c pagDash8 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_USERS_IN_MULTIPLE_LEAD_GRPS');
        PMP_Marketplace_Metric__c pagDash9 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_ELIGIBLE_USER_NOT_IN_LEAD_GRPS');
        PMP_Marketplace_Metric__c pagDash10 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_NON_ELIGIBLE_USER_IN_LEAD_GRPS');
        PMP_Marketplace_Metric__c pagDash11 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_SEGMENT_GRP_NOT_CREATED');
        PMP_Marketplace_Metric__c pagDash12 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_WRONGLY_ADDED_USER_IN_PARTNER_GRP');
        PMP_Marketplace_Metric__c pagDash13 = new PMP_Marketplace_Metric__c(PMP_Metric_API_Nm__c ='METRIC_USER_NOT_ADDED_IN_PAG');
        pagDashboardRecs.add(pagDash1);
        pagDashboardRecs.add(pagDash2);
        pagDashboardRecs.add(pagDash3);
        pagDashboardRecs.add(pagDash4);
        pagDashboardRecs.add(pagDash5);
        pagDashboardRecs.add(pagDash6);
        pagDashboardRecs.add(pagDash7);
        pagDashboardRecs.add(pagDash8);
        pagDashboardRecs.add(pagDash9);
        pagDashboardRecs.add(pagDash10);
        pagDashboardRecs.add(pagDash11);
        pagDashboardRecs.add(pagDash12);
        pagDashboardRecs.add(pagDash13);
        
        database.insert(pagDashboardRecs);
      }
      static testmethod void test(){
            Test.startTest();
                //PMP_Group_Validation.pagGroupValidation();
                
            Id batchId = Database.executeBatch(new PMP_Marketplace_Metric_Schedular());
            String chron = '0 0 12 */7 * ?' ;
            System.schedule('Pag Dashboard', chron, new PMP_Marketplace_Metric_Schedular());
            Test.stopTest();
        }


}