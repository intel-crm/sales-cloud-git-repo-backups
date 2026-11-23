/**************************************************************************************
Apex Class Name : PMP_Batch_Group_Management_Test
Version     : 1.0 
Created Date: 20th may, 2019
Description : Test class for Core_Mp_Public_Group_Creation
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Raushan                  20/05/2019               Original Version
*************************************************************************************/

@isTest(SeeAllData=false)
public class PMP_Batch_Group_Management_Test{
    
    @testSetup 
        static void setup() {
            
            /**** Fetching Record TypeId from custom label******/
            String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
            String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
            List<Account> accts = new List<Account>();   
            
            Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
      
            Account partnerAccount2 = new Account(Name ='PartnerAccount2',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
            
            Account partnerAccount3 = new Account(Name ='PartnerAccount3',Core_Account_Type__c = 'Distributor',
                                            Core_Sales_Groups__c= 'CCG Sales Group',
                                            Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, 
                                            BillingCity='delhi',BillingCountry='Ind',
                                            BillingStreet='abc chowk delhi');
            Account partnerAccount4 = new Account(Name ='PartnerAccount4',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
            Account partnerAccount5 = new Account(Name ='PartnerAccount5',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
            Account partnerAccount6 = new Account(Name ='PartnerAccount6',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',Core_PMP_Membership_Change_Ind__c=true);
            Account partnerAccount7 = new Account(Name ='PartnerAccount7',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
            Account partnerAccount8 = new Account(Name ='PartnerAccount8',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
            
            
            //System.debug('partnerAccount test class ='+partnerAccount);
            accts.add(partnerAccount1);
            accts.add(partnerAccount2);
            accts.add(partnerAccount3);
            accts.add(partnerAccount4);
            accts.add(partnerAccount5);
            accts.add(partnerAccount6);
            accts.add(partnerAccount7);
            accts.add(partnerAccount8);
           
            Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount2 = new Account(Name ='IntelAccount2',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount3 = new Account(Name ='IntelAccount3',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'CCG Sales Group',
                                                Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi'
                                                ); 
            Account intelAccount4 = new Account(Name ='IntelAccount4',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount5 = new Account(Name ='IntelAccount5',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount6 = new Account(Name ='IntelAccount6',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount7 = new Account(Name ='IntelAccount7',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi'); 
            Account intelAccount8 = new Account(Name ='IntelAccount8',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount9 = new Account(Name ='IntelAccount9',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi'); 
            Account intelAccount10 = new Account(Name ='IntelAccount10',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            
            accts.add(intelAccount1);
            accts.add(intelAccount2);
            accts.add(intelAccount3);
            accts.add(intelAccount4);
            accts.add(intelAccount5);
            accts.add(intelAccount6);
            accts.add(intelAccount7);
            accts.add(intelAccount8);
            accts.add(intelAccount9);
            accts.add(intelAccount10);
            
            // Inserting Acounts
            Database.insert(accts);
            
            System.debug('Accounts = '+ accts);
            List<Account> allPartnerAccount = new List<Account>();
            allPartnerAccount = [SELECT Id,Name,RecordTypeId FROM Account WHERE RecordTypeId=:partnerAccRecTypeId];
            /****** Updating Account As Partner*****/
            List<Account> accToUpdate = new List<Account>();
            For(Account acc:accts){
                acc.IsPartner = true;
                accToUpdate.add(acc);
            }
            Database.update(accToUpdate);
            
            System.debug('accToUpdate ='+accToUpdate);
            
            /****** Creating Partner account group member record*****/
            List<Core_Account_Group_Member__c> allPag = new List<Core_Account_Group_Member__c>();
            Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
            accGroupMem1.Core_Partner_Account_Id__c =partnerAccount1.Id;
            accGroupMem1.Core_Intel_Account_Id__c =intelAccount1.Id;
            //accGroupMem1.Core_Partner_Account_Id__r.Core_PMP_Membership_Change_Ind__c = true;
            accGroupMem1.Core_MDA_Ind__c = true;
            allPag.add(accGroupMem1);
            
            Core_Account_Group_Member__c accGroupMem2 = new Core_Account_Group_Member__c();
            
            accGroupMem2.Core_Partner_Account_Id__c =partnerAccount2.Id;
            accGroupMem2.Core_Intel_Account_Id__c =intelAccount2.Id;
            accGroupMem2.Core_MDA_Ind__c = true;
            allPag.add(accGroupMem2);
            
            Core_Account_Group_Member__c accGroupMem3 = new Core_Account_Group_Member__c();
            accGroupMem3.Core_Partner_Account_Id__c =partnerAccount3.Id;
            accGroupMem3.Core_Intel_Account_Id__c =intelAccount3.Id;
            accGroupMem3.Core_MDA_Ind__c = true;
            allPag.add(accGroupMem3);
            
            Core_Account_Group_Member__c accGroupMem4 = new Core_Account_Group_Member__c();
            accGroupMem4.Core_Partner_Account_Id__c =partnerAccount4.Id;
            accGroupMem4.Core_Intel_Account_Id__c =intelAccount4.Id;
            accGroupMem4.Core_MDA_Ind__c = true;
            allPag.add(accGroupMem4);
            
            Core_Account_Group_Member__c accGroupMem5 = new Core_Account_Group_Member__c();
            accGroupMem5.Core_Partner_Account_Id__c =partnerAccount5.Id;
            accGroupMem5.Core_Intel_Account_Id__c =intelAccount5.Id;
            accGroupMem5.Core_MDA_Ind__c = true;
            allPag.add(accGroupMem5);
            
            Core_Account_Group_Member__c accGroupMem6 = new Core_Account_Group_Member__c();
            accGroupMem6.Core_Partner_Account_Id__c =partnerAccount6.Id;
            accGroupMem6.Core_Intel_Account_Id__c =intelAccount6.Id;
            accGroupMem6.Core_Inactive_Ind__c = false;
            accGroupMem6.Core_MDA_Ind__c = true;
            allPag.add(accGroupMem6);
            
            Core_Account_Group_Member__c accGroupMem7 = new Core_Account_Group_Member__c();
            accGroupMem7.Core_Partner_Account_Id__c =partnerAccount6.Id;
            accGroupMem7.Core_Intel_Account_Id__c =intelAccount7.Id;
            accGroupMem7.Core_Inactive_Ind__c = false;
            accGroupMem7.Core_MDA_Ind__c = false;
            allPag.add(accGroupMem7); 
            
            Core_Account_Group_Member__c accGroupMem8 = new Core_Account_Group_Member__c();
            accGroupMem8.Core_Partner_Account_Id__c =partnerAccount7.Id;
            accGroupMem8.Core_Intel_Account_Id__c =intelAccount8.Id;
            accGroupMem8.Core_Inactive_Ind__c = false;
            accGroupMem8.Core_MDA_Ind__c = false;
            allPag.add(accGroupMem8);
            
            
            Core_Account_Group_Member__c accGroupMem9 = new Core_Account_Group_Member__c();
            accGroupMem9.Core_Partner_Account_Id__c =partnerAccount7.Id;
            accGroupMem9.Core_Intel_Account_Id__c =intelAccount9.Id;
            accGroupMem9.Core_Inactive_Ind__c = false;
            accGroupMem9.Core_MDA_Ind__c = false;
            allPag.add(accGroupMem9); 
            
             Core_Account_Group_Member__c accGroupMem10 = new Core_Account_Group_Member__c();
            accGroupMem10.Core_Partner_Account_Id__c =partnerAccount8.Id;
            accGroupMem10.Core_Intel_Account_Id__c =intelAccount10.Id;
            accGroupMem10.Core_Inactive_Ind__c = false;
            accGroupMem10.Core_MDA_Ind__c = false;
            allPag.add(accGroupMem10);
          
            //Inserting Account Group Member Record
            Database.insert(allPag);
            accGroupMem7.Core_Inactive_Ind__c = true;
            update accGroupMem7;
            /****** Creating ERPM_Engagement record*****/
            Core_ERPM_Engagement__c erpmEng1 =new Core_ERPM_Engagement__c(Name  ='Intel Premier Support',Core_IsActive__c=true);
            Database.insert(erpmEng1);
            System.debug('erpmEngagements ='+erpmEng1);
            
            /****** Creating Contact record*****/
            List<Contact> allContacts = new List<Contact>();
            Contact contact1 = new Contact(firstname='Intel', 
                    lastname='Contact1', accountId=intelAccount1.id,Email='dellco1234@dell.com');
            allContacts.add(contact1);
            Contact contact2 = new Contact(firstname='Intel', 
                    lastname='Contact2', accountId=intelAccount2.id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact2);
            Contact contact7 = new Contact(firstname='Intel', 
                    lastname='Contact7', accountId=intelAccount2.id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact7);
            Contact contact3 = new Contact(firstname='Intel', 
                    lastname='Contact3', accountId=intelAccount6.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact3);
            Contact contact4 = new Contact(firstname='Intel', 
                    lastname='Contact4', accountId=intelAccount7.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact4); 
            Contact contact5 = new Contact(firstname='Intel', 
                    lastname='Contact5', accountId=intelAccount8.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact5);
            Contact contact6 = new Contact(firstname='Intel', 
                    lastname='Contact6', accountId=intelAccount9.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact6); 
            Contact contact8 = new Contact(firstname='Intel', 
                    lastname='Contact8', accountId=intelAccount10.id,Email='dellco1234@dell.com');
            allContacts.add(contact8);
            Contact contact9 = new Contact(firstname='Intel', 
                    lastname='Contact9', accountId=intelAccount10.id,Email='dellco1234@dell.com');
            allContacts.add(contact9);
            Test.startTest();
            Database.insert(allContacts);
            System.debug('contact1 ='+contact1);
           
            
            /****** Creating Entitlement detail records*****/
            
            List<Core_Entitlement__c> ent = new List<Core_Entitlement__c>();

            Core_Entitlement__c entitlement1 = new Core_Entitlement__c(Name='Marketing Specialist',
                                                                      Core_Display_Name__c='Marketing Specialist',Core_ERPM_Engagement_Id__c=erpmEng1.id);
            ent.add(entitlement1);
             
           Core_Entitlement__c entitlement2 = new Core_Entitlement__c(Name='Offering Editor',
                                                                      Core_Display_Name__c='Offering Editor',Core_ERPM_Engagement_Id__c=erpmEng1.id);
            ent.add(entitlement2);
            
            Core_Entitlement__c entitlement3 = new Core_Entitlement__c(Name='Lead Development Representative',
                                                                      Core_Display_Name__c='Lead Development Representative',Core_ERPM_Engagement_Id__c=erpmEng1.id);
            ent.add(entitlement3);
             Core_Entitlement__c entitlement4 = new Core_Entitlement__c(Name='Employee',
                                                                      Core_Display_Name__c='Employee',Core_ERPM_Engagement_Id__c=erpmEng1.id);
            ent.add(entitlement4);
            Core_Entitlement__c entitlement5 = new Core_Entitlement__c(Name='Partner Admin',
                                                                      Core_Display_Name__c='Partner Admin',Core_ERPM_Engagement_Id__c=erpmEng1.id);
            ent.add(entitlement5);
            
            //Inserting entitlement records
            Database.insert(ent);
            
            List<Id> entIds = new List<Id>();
            For(Core_Entitlement__c entitlementId:ent){
                entIds.add(entitlementId.Id);
            }
            String ldrEntId = System.Label.Core_Lead_Development_Representative ;
            String partAdminEntId = System.Label.Core_Partner_Admin ;
            String empEntId = System.Label.Core_Employee ;
           /****** Creating Contact Entitlement records*****/
           List<Core_Contact_Entitlement__c> conEnt = new List<Core_Contact_Entitlement__c>();
                   //for(Core_Entitlement__c entId:ent){
                   Core_Contact_Entitlement__c contactEntitlement1 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement2.Id,Core_Contact_Id__c=contact1.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete');
                   Core_Contact_Entitlement__c contactEntitlement2 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=ldrEntId,Core_Contact_Id__c=contact2.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete');
                   Core_Contact_Entitlement__c contactEntitlement10 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=ldrEntId,Core_Contact_Id__c=contact7.Id,
                                                                                           Core_Selected__c=false,Core_Status__c='Complete');
                   Core_Contact_Entitlement__c contactEntitlement3 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement2.Id,Core_Contact_Id__c=contact2.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete');
                   Core_Contact_Entitlement__c contactEntitlement4 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement3.Id,Core_Contact_Id__c=contact2.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete');
                   Core_Contact_Entitlement__c contactEntitlement5 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement3.Id,Core_Contact_Id__c=contact3.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete');
                   Core_Contact_Entitlement__c contactEntitlement6 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement3.Id,Core_Contact_Id__c=contact4.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete'); 
                   Core_Contact_Entitlement__c contactEntitlement7 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement3.Id,Core_Contact_Id__c=contact5.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete');
                   Core_Contact_Entitlement__c contactEntitlement8 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement3.Id,Core_Contact_Id__c=contact6.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete'); 
                   Core_Contact_Entitlement__c contactEntitlement9 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=System.Label.Core_Partner_Admin,Core_Contact_Id__c=contact1.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete');
                   Core_Contact_Entitlement__c contactEntitlement11 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=System.Label.Core_Partner_Admin,Core_Contact_Id__c=contact2.Id,
                                                                                           Core_Selected__c=false,Core_Status__c='Complete');
                   Core_Contact_Entitlement__c contactEntitlement12 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=System.Label.Core_Employee,Core_Contact_Id__c=contact1.Id,
                                                                                           Core_Selected__c=true,Core_Status__c='Complete');
                   Core_Contact_Entitlement__c contactEntitlement13 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=System.Label.Core_Employee,Core_Contact_Id__c=contact2.Id,
                                                                                           Core_Selected__c=false,Core_Status__c='Complete');
                   conEnt.add(contactEntitlement1);
                   conEnt.add(contactEntitlement2);
                   conEnt.add(contactEntitlement3);
                   conEnt.add(contactEntitlement4);
                   conEnt.add(contactEntitlement5);
                   conEnt.add(contactEntitlement6);
                   conEnt.add(contactEntitlement7);
                   conEnt.add(contactEntitlement8);
                   conEnt.add(contactEntitlement9);
                   conEnt.add(contactEntitlement10);
                   conEnt.add(contactEntitlement11);
                   conEnt.add(contactEntitlement12);
                   conEnt.add(contactEntitlement13);
            //Inserting Contact Entitlement Record    
            database.insert(conEnt,false);
            Test.stopTest();
            // Collecting contactids
            Set<Id> contactsId = new Set<Id>();
            for(Core_Contact_Entitlement__c conIds:conEnt){
                contactsId.add(conIds.Core_Contact_Id__c);
            }
            System.debug('contactsId ='+contactsId);
            
            // Getting Current user information
            User currentUser = [select Id from User where Id = :UserInfo.getUserId()];
            List<User> userList = new List<User>();
            
            System.debug('currentUser ='+currentUser);
            
            System.runAs (currentUser) {
                
                //UserRole userRole = [Select PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
                Profile profile = [select Id,name from Profile where Name ='Partner'];
                
                for(Id conId:contactsId){
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
                    contactId = conId
                );
                    userList.add(newUser);
                }
                //Inserting User
                Database.insert(userList);
                
            }
            System.debug('userList ='+userList);
            

            String publicGroupName = '';
            //List<Account> partnerAcc = [SELECT ID,Name FROM Account where Name ='PartnerAccount'];
            List<String> partnerAccountId = new List<String>();
            
            //Getting the Partner AccountId
            For(Account acc:allPartnerAccount){
                partnerAccountId.add(acc.Id);
                 
            } 
            System.debug(partnerAccountId);
            for(Id accId:partnerAccountId){
                //Forming Public Group Name
                publicGroupName = 'Core_MP_'+accId;
                //publicGroupName = 'PMP_'+accId;
            }
            
            System.debug('publicGroupName ='+publicGroupName);
            
            /****** Creating Public Group record record*****/
            
            Group grp = new Group(Name =publicGroupName,DeveloperName=publicGroupName);
            //Inserting Public Group
            Database.insert(grp);
            System.debug('Group ='+grp);
            
            /****** Creating Public Group Member record*****/
            GroupMember gm = new GroupMember(GroupId =grp.id,UserOrGroupId=userList[0].Id);
            
            System.runAs(new user(ID = UserInfo.getUserID())){
            Database.insert(gm);
            } 
            System.debug('Group Member ='+gm);
            
            Set<Id> conIdsWithSelectedFalse = new Set<Id>();
            Set<Id> userToBeRemoved = new Set<Id>();
            List<Core_Contact_Entitlement__c> contactEntitlementToBeUpdated = new List<Core_Contact_Entitlement__c>();
            
            // Sharing of Partner Account with Partner Account Group
            AccountShare accShare = new AccountShare();
            accShare.AccountId = partnerAccount1.Id;
            accShare.UserOrGroupId = grp.Id ;
            accShare.AccountAccessLevel = 'read';
            accShare.OpportunityAccessLevel = 'read';
         //Inserting list of AccountShare Records
           Database.insert(accShare);
            } 
    static testmethod void test(){
        Test.startTest();
        //System.runAs(new user(ID = UserInfo.getUserID())){
        
            Id batchId = Database.executeBatch(new PMP_Batch_Group_Management_Scheduler());
            String chron = '0 0 * ? * * *' ;
            System.schedule('Record Deletion', chron, new PMP_Batch_Group_Management_Scheduler());
            //Core_Mp_Public_Group_Creation.updatePublicGroupMembership();
            //Core_Mp_Public_Group_Creation.refinePartnerAccounts(partnerAccountId,accts);
            
        //}
        Test.stopTest();
        
    }

}