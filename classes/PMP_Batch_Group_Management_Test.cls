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
            //String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
            String CORE_MP_STR = System.Label.PMP_Group_Name_Prefix;
            String ALL_PARTNERS_GROUP= System.Label.Partner_Users_Marketplace;
            List<Account> accts = new List<Account>();   
            
            Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi', Core_PMP_Membership_Change_Ind__c = true);
      
            Account partnerAccount2 = new Account(Name ='PartnerAccount2',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi', Core_PMP_Membership_Change_Ind__c = true);
            
            Account partnerAccount3 = new Account(Name ='PartnerAccount3',Core_Account_Type__c = 'Distributor',
                                                    Core_Sales_Group_New__c= 'CCG Sales Group',
                                                    Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, 
                                                    BillingCity='delhi',BillingCountry='Ind',
                                                    BillingStreet='abc chowk delhi',
                                                    Core_PMP_Membership_Change_Ind__c = true);
            Account partnerAccount4 = new Account(Name ='PartnerAccount4',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
            Account partnerAccount5 = new Account(Name ='PartnerAccount5',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
            Account partnerAccount6 = new Account(Name ='PartnerAccount6',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',Core_PMP_Membership_Change_Ind__c=true);
            Account partnerAccount7 = new Account(Name ='PartnerAccount7',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
            Account partnerAccount8 = new Account(Name ='PartnerAccount8',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
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
            String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount2 = new Account(Name ='IntelAccount2',Core_Account_Type__c = 'System Integrator',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount3 = new Account(Name ='IntelAccount3',Core_Account_Type__c = 'System Integrator',Core_Sales_Group_New__c= 'CCG Sales Group',
                                                Industry='Agriculture', RecordTypeId=intelAccRecTypeId,BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi'); 
            Account intelAccount4 = new Account(Name ='IntelAccount4',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount5 = new Account(Name ='IntelAccount5',Core_Account_Type__c = 'System Integrator',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount6 = new Account(Name ='IntelAccount6',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount7 = new Account(Name ='IntelAccount7',Core_Account_Type__c = 'System Integrator',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi'); 
            Account intelAccount8 = new Account(Name ='IntelAccount8',Core_Account_Type__c = 'System Integrator',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount9 = new Account(Name ='IntelAccount9',Core_Account_Type__c = 'System Integrator',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi'); 
            Account intelAccount10 = new Account(Name ='IntelAccount10',Core_Account_Type__c = 'System Integrator',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
            Account intelAccount11 = new Account(Name ='IntelAccount11',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi', Core_PMP_Membership_Change_Ind__c = true);
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
            accts.add(intelAccount11);
            Account indpIntelAcct1 = new Account(Name ='indpIntelAcct1',Core_Account_Type__c = 'System Integrator',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi', Core_PMP_Membership_Change_Ind__c = true); 
            Account indpIntelAcct2 = new Account(Name ='indpIntelAcct2',Core_Account_Type__c = 'System Integrator',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi', Core_PMP_Membership_Change_Ind__c = true);
      accts.add(indpIntelAcct1);
            accts.add(indpIntelAcct2);
            // Inserting Acounts
            Database.insert(accts);
            
            // System.debug('Accounts = '+ accts);
            List<Account> allPartnerAccount = new List<Account>();
            allPartnerAccount = [SELECT Id,Name,RecordTypeId FROM Account WHERE RecordTypeId=:partnerAccRecTypeId];
            /****** Updating Account As Partner*****/
            List<Account> accToUpdate = new List<Account>();
            For(Account acc:accts){
                acc.IsPartner = true;
                accToUpdate.add(acc);
            }
            Database.update(accToUpdate);
            
            // System.debug('accToUpdate ='+accToUpdate);
            
            /****** Creating Partner account group member record*****/
            List<Core_Account_Group_Member__c> allPag = new List<Core_Account_Group_Member__c>();
            Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
            accGroupMem1.Core_Partner_Account_Id__c =partnerAccount1.Id;
            accGroupMem1.Core_Intel_Account_Id__c =intelAccount1.Id;
            allPag.add(accGroupMem1);
            
            Core_Account_Group_Member__c accGroupMem11 = new Core_Account_Group_Member__c();
            accGroupMem11.Core_Partner_Account_Id__c =partnerAccount1.Id;
            accGroupMem11.Core_Intel_Account_Id__c =intelAccount11.Id;
            allPag.add(accGroupMem11);
            
            Core_Account_Group_Member__c accGroupMem2 = new Core_Account_Group_Member__c();
            
            accGroupMem2.Core_Partner_Account_Id__c =partnerAccount1.Id;
            accGroupMem2.Core_Intel_Account_Id__c =intelAccount2.Id;
            allPag.add(accGroupMem2);
            
            Core_Account_Group_Member__c accGroupMem3 = new Core_Account_Group_Member__c();
            accGroupMem3.Core_Partner_Account_Id__c =partnerAccount3.Id;
            accGroupMem3.Core_Intel_Account_Id__c =intelAccount3.Id;
            allPag.add(accGroupMem3);
            
            Core_Account_Group_Member__c accGroupMem4 = new Core_Account_Group_Member__c();
            accGroupMem4.Core_Partner_Account_Id__c =partnerAccount4.Id;
            accGroupMem4.Core_Intel_Account_Id__c =intelAccount4.Id;
            allPag.add(accGroupMem4);
            
            Core_Account_Group_Member__c accGroupMem5 = new Core_Account_Group_Member__c();
            accGroupMem5.Core_Partner_Account_Id__c =partnerAccount5.Id;
            accGroupMem5.Core_Intel_Account_Id__c =intelAccount5.Id;
            allPag.add(accGroupMem5);
            
            Core_Account_Group_Member__c accGroupMem6 = new Core_Account_Group_Member__c();
            accGroupMem6.Core_Partner_Account_Id__c =partnerAccount6.Id;
            accGroupMem6.Core_Intel_Account_Id__c =intelAccount6.Id;
            accGroupMem6.Core_Inactive_Ind__c = false;
            allPag.add(accGroupMem6);
            
            Core_Account_Group_Member__c accGroupMem7 = new Core_Account_Group_Member__c();
            accGroupMem7.Core_Partner_Account_Id__c =partnerAccount6.Id;
            accGroupMem7.Core_Intel_Account_Id__c =intelAccount7.Id;
            accGroupMem7.Core_Inactive_Ind__c = false;
            allPag.add(accGroupMem7); 
            
            Core_Account_Group_Member__c accGroupMem8 = new Core_Account_Group_Member__c();
            accGroupMem8.Core_Partner_Account_Id__c =partnerAccount7.Id;
            accGroupMem8.Core_Intel_Account_Id__c =intelAccount8.Id;
            accGroupMem8.Core_Inactive_Ind__c = false;
            allPag.add(accGroupMem8);
            
            
            Core_Account_Group_Member__c accGroupMem9 = new Core_Account_Group_Member__c();
            accGroupMem9.Core_Partner_Account_Id__c =partnerAccount7.Id;
            accGroupMem9.Core_Intel_Account_Id__c =intelAccount9.Id;
            accGroupMem9.Core_Inactive_Ind__c = false;
            allPag.add(accGroupMem9); 
            
             Core_Account_Group_Member__c accGroupMem10 = new Core_Account_Group_Member__c();
            accGroupMem10.Core_Partner_Account_Id__c =partnerAccount8.Id;
            accGroupMem10.Core_Intel_Account_Id__c =intelAccount10.Id;
            accGroupMem10.Core_Inactive_Ind__c = false;
            allPag.add(accGroupMem10);
          
            //Inserting Account Group Member Record
            Database.insert(allPag);
            accGroupMem7.Core_Inactive_Ind__c = true;
            update accGroupMem7;
            /****** Creating ERPM_Engagement record*****/
            Core_ERPM_Engagement__c erpmEng1 =new Core_ERPM_Engagement__c(Name  ='Intel Premier Support',Core_IsActive__c=true);
            Database.insert(erpmEng1);
            // System.debug('erpmEngagements ='+erpmEng1);
            
            /****** Creating Contact record*****/
            List<Contact> allContacts = new List<Contact>();
            Contact contact1 = new Contact(firstname='Intel',Core_IPA_Contact_Segment__c ='Client Computing;Data Center',MailingCountry='India',
                    lastname='Contact1', accountId=intelAccount1.id,Email='dellco1234@dell.com');
            allContacts.add(contact1);
            Contact contact2 = new Contact(firstname='Intel', MailingCountry='India',
                    lastname='Contact2', accountId=intelAccount2.id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact2);
            Contact contact7 = new Contact(firstname='Intel', MailingCountry='India',
                    lastname='Contact7', accountId=intelAccount2.id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact7);
            Contact contact3 = new Contact(firstname='Intel', MailingCountry='India',
                    lastname='Contact3', accountId=intelAccount1.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact3);
            Contact contact4 = new Contact(firstname='Intel', MailingCountry='India',
                    lastname='Contact4', accountId=intelAccount7.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact4); 
            Contact contact5 = new Contact(firstname='Intel', MailingCountry='India',
                    lastname='Contact5', accountId=intelAccount8.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact5);
            Contact contact6 = new Contact(firstname='Intel', MailingCountry='India',
                    lastname='Contact6', accountId=intelAccount9.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                           Email='dellco12345@dell.com');
            allContacts.add(contact6); 
            Contact contact8 = new Contact(firstname='Intel', MailingCountry='India',
                    lastname='Contact8', accountId=intelAccount10.id,Email='dellco1234@dell.com');
            allContacts.add(contact8);
            Contact contact9 = new Contact(firstname='Intel', MailingCountry='India',
                    lastname='Contact9', accountId=intelAccount10.id,Email='dellco1234@dell.com');
            allContacts.add(contact9);
            Contact contact10 = new Contact(firstname='Intel', MailingCountry='India',
                    lastname='Contact10', accountId=indpIntelAcct1.id,Email='dellco1234i10@dell.com');
            allContacts.add(contact10);
            Test.startTest();
            Database.insert(allContacts);
            // System.debug('contact1 ='+contact1);
           
            
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
            
            Core_Entitlement__c entitlement6 = new Core_Entitlement__c(Name='Partner Admin Delegate',
                                                                      Core_Display_Name__c='Partner Admin Delegate',Core_ERPM_Engagement_Id__c=erpmEng1.id);
            ent.add(entitlement6);
            
            
            //Inserting entitlement records
            Database.insert(ent);
            
            List<Id> entIds = new List<Id>();
            For(Core_Entitlement__c entitlementId:ent){
                entIds.add(entitlementId.Id);
            }
            /*String ldrEntId = System.Label.Core_Lead_Development_Representative ;
            String partAdminEntId = System.Label.Core_Partner_Admin ;
            String empEntId = System.Label.Core_Employee ;*/
           /****** Creating Contact Entitlement records*****/
            List<Core_Contact_Entitlement__c> lstConEnts = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c conEnt14 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement4.Id,Core_Contact_Id__c=contact1.Id,
                                                                                   Core_Selected__c=true,Core_Status__c='Complete');
            lstConEnts.add(conEnt14);
            Core_Contact_Entitlement__c conEnt15 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement5.Id,Core_Contact_Id__c=contact1.Id,
                                                                                   Core_Selected__c=true,Core_Status__c='Complete');
            lstConEnts.add(conEnt15);
            Core_Contact_Entitlement__c conEnt13 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement3.Id,Core_Contact_Id__c=contact1.Id,
                                                                                   Core_Selected__c=true,Core_Status__c='Complete');
            lstConEnts.add(conEnt13);
            Core_Contact_Entitlement__c conEnt24 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement4.Id,Core_Contact_Id__c=contact2.Id,
                                                                                   Core_Selected__c=true,Core_Status__c='Complete');
            lstConEnts.add(conEnt24);
            Core_Contact_Entitlement__c conEnt25 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement5.Id,Core_Contact_Id__c=contact2.Id,
                                                                                   Core_Selected__c=true,Core_Status__c='Complete');
            lstConEnts.add(conEnt25);
            Core_Contact_Entitlement__c conEnt23 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement6.Id,Core_Contact_Id__c=contact2.Id,
                                                                                   Core_Selected__c=true,Core_Status__c='Complete');
            lstConEnts.add(conEnt23);
            
            Core_Contact_Entitlement__c conEnt34 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement4.Id,Core_Contact_Id__c=contact3.Id,
                                                                                   Core_Selected__c=true,Core_Status__c='Complete');
            lstConEnts.add(conEnt34);
            Core_Contact_Entitlement__c conEnt101 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement4.Id,Core_Contact_Id__c=contact10.Id,
                                                                                   Core_Selected__c=true,Core_Status__c='Complete');
            lstConEnts.add(conEnt101);
            
            database.insert(lstConEnts,false);
           /*List<Core_Contact_Entitlement__c> conEnt = new List<Core_Contact_Entitlement__c>();
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
            database.insert(conEnt,false);*/
            Test.stopTest();
            // Collecting contactids
            
            
            // Getting Current user information
            User currentUser = [select Id from User where Id = :UserInfo.getUserId()];
            List<User> userList = new List<User>();
            
            // System.debug('currentUser ='+currentUser);
            
            System.runAs (currentUser) {
                
                Profile profile = [select Id,name from Profile where Name ='Partner'];
                
                for(Contact con:allContacts){
                    // Creating user
                    User newUser = new User(
                   //UserRoleId = userRole.Id,
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
                }
                //Inserting User
                Database.insert(userList);
                
            }
            // System.debug('userList ='+userList);
            

            String publicGroupName = '';
            //List<Account> partnerAcc = [SELECT ID,Name FROM Account where Name ='PartnerAccount'];
            List<String> partnerAccountId = new List<String>();
            
            //Getting the Partner AccountId
            For(Account acc:allPartnerAccount){
                partnerAccountId.add(acc.Id);
                 
            } 
            //System.debug(partnerAccountId);
            List<Group> lstPublicGroupToBeInserted = new List<Group>();
            for(Id accId:partnerAccountId){
                //Forming Public Group Name
                //publicGroupName = 'Core_MP_'+accId;
                publicGroupName = CORE_MP_STR+accId;
                Group grp = new Group(); 
                    grp.Name = publicGroupName; 
                    grp.DeveloperName  = publicGroupName;
                    grp.DoesIncludeBosses = false;
                    lstPublicGroupToBeInserted.add(grp);
            }
            publicGroupName = CORE_MP_STR+partnerAccount1.Id+'_LeadsOfEmployee';
                Group grpLDR = new Group(); 
                    grpLDR.Name = publicGroupName; 
                    grpLDR.DeveloperName  = publicGroupName;
                    grpLDR.DoesIncludeBosses = false;
                lstPublicGroupToBeInserted.add(grpLDR);
            
            
            Database.insert(lstPublicGroupToBeInserted);
            
            /****** Creating Public Group record record*****/
            List<GroupMember> lstInsertGrpMembers = new List<GroupMember>();
            GroupMember gm = new GroupMember();
            gm.GroupId = lstPublicGroupToBeInserted[0].Id;
            gm.UserOrGroupId = userList[0].id;
            lstInsertGrpMembers.add(gm);
            
            GroupMember gm1 = new GroupMember();
            gm1.GroupId = lstPublicGroupToBeInserted[1].Id;
            gm1.UserOrGroupId = userList[0].id;
            lstInsertGrpMembers.add(gm1);
            
            GroupMember gm2 = new GroupMember();
            gm2.GroupId = lstPublicGroupToBeInserted[0].Id;
            gm2.UserOrGroupId = userList[1].id;
            lstInsertGrpMembers.add(gm2);
            
            GroupMember gm3 = new GroupMember();
            gm3.GroupId = lstPublicGroupToBeInserted[1].Id;
            gm3.UserOrGroupId = userList[1].id;
            lstInsertGrpMembers.add(gm3);
            
            GroupMember gm4 = new GroupMember();
            gm4.GroupId = grpLDR.Id;
            gm4.UserOrGroupId = userList[1].id;
            lstInsertGrpMembers.add(gm4);
      System.runAs(new user(ID = UserInfo.getUserID())){
             Database.insert(lstInsertGrpMembers);
            } 
            
            
            
            //Create Custom setting Data
            List<PMP_Public_Group_Management_Settings__c> lstPGSM = new List<PMP_Public_Group_Management_Settings__c>();
            
            PMP_Public_Group_Management_Settings__c pgms1 = new PMP_Public_Group_Management_Settings__c(
              Name = '1', PMP_Action_Txt__c = 'Add', PMP_Contributing_Entitlement_Nm__c = 'Partner Admin Delegate',
              PMP_Public_Group_Nm__c = 'PMP_<OPID>_Leads' );
            lstPGSM.add(pgms1);
            PMP_Public_Group_Management_Settings__c pgms2 = new PMP_Public_Group_Management_Settings__c(
              Name = '2', PMP_Action_Txt__c = 'Add', PMP_Contributing_Entitlement_Nm__c = 'Partner Admin',
              PMP_Public_Group_Nm__c = 'PMP_<OPID>_Leads' );
            lstPGSM.add(pgms2);
            PMP_Public_Group_Management_Settings__c pgms3 = new PMP_Public_Group_Management_Settings__c(
              Name = '3', PMP_Action_Txt__c = 'Add', PMP_Contributing_Entitlement_Nm__c = 'Employee',
              PMP_Public_Group_Nm__c = 'PMP_<OPID>_LeadsOfEmployee' );
            lstPGSM.add(pgms3);
            PMP_Public_Group_Management_Settings__c pgms4 = new PMP_Public_Group_Management_Settings__c(
              Name = '4', PMP_Action_Txt__c = 'Add', PMP_Contributing_Entitlement_Nm__c = 'Lead Development Representative', PMP_Contributing_Field_API_Nm__c = 'Core_IPA_Contact_Segment__c',
              PMP_Contributing_Field_Value_Txt__c = 'Internet of Things and Embedded', PMP_Public_Group_Nm__c = 'PMP_<OPID>_Internet_of_Things_and_Embedded' );
            lstPGSM.add(pgms4);
            PMP_Public_Group_Management_Settings__c pgms5 = new PMP_Public_Group_Management_Settings__c(
              Name = '5', PMP_Action_Txt__c = 'Add', PMP_Contributing_Entitlement_Nm__c = 'Lead Development Representative', PMP_Contributing_Field_API_Nm__c = 'Core_IPA_Contact_Segment__c',
              PMP_Contributing_Field_Value_Txt__c = 'Client Computing', PMP_Public_Group_Nm__c = 'PMP_<OPID>_Client_Computing' );
            lstPGSM.add(pgms5);
            PMP_Public_Group_Management_Settings__c pgms6 = new PMP_Public_Group_Management_Settings__c(
              Name = '6', PMP_Action_Txt__c = 'Add', PMP_Contributing_Entitlement_Nm__c = 'Lead Development Representative', PMP_Contributing_Field_API_Nm__c = 'Core_IPA_Contact_Segment__c',
              PMP_Contributing_Field_Value_Txt__c = 'Data Center', PMP_Public_Group_Nm__c = 'PMP_<OPID>_Data_Center' );
            lstPGSM.add(pgms6);
            PMP_Public_Group_Management_Settings__c pgms7 = new PMP_Public_Group_Management_Settings__c(
              Name = '7', PMP_Action_Txt__c = 'Add', PMP_Contributing_Entitlement_Nm__c = 'Lead Development Representative', PMP_Contributing_Field_API_Nm__c = 'Core_IPA_Contact_Segment__c',
              PMP_Contributing_Field_Value_Txt__c = 'Storage and Memory', PMP_Public_Group_Nm__c = 'PMP_<OPID>_Storage_and_Memory' );
            lstPGSM.add(pgms7);
            PMP_Public_Group_Management_Settings__c pgms8 = new PMP_Public_Group_Management_Settings__c(
              Name = '8', PMP_Action_Txt__c = 'Add', PMP_Contributing_Entitlement_Nm__c = 'Lead Development Representative', PMP_Contributing_Field_API_Nm__c = 'Core_IPA_Contact_Segment__c',
              PMP_Contributing_Field_Value_Txt__c = 'Programmable Logic', PMP_Public_Group_Nm__c = 'PMP_<OPID>_Programmable_Logic' );
            lstPGSM.add(pgms8);
            PMP_Public_Group_Management_Settings__c pgms9 = new PMP_Public_Group_Management_Settings__c(
              Name = '9', PMP_Action_Txt__c = 'Remove', PMP_Contributing_Entitlement_Nm__c = 'Lead Development Representative', PMP_Contributing_Field_API_Nm__c = '',
              PMP_Public_Group_Nm__c = 'PMP_<OPID>_LeadsOfEmployee' );
            lstPGSM.add(pgms9);
            PMP_Public_Group_Management_Settings__c pgms10 = new PMP_Public_Group_Management_Settings__c(
              Name = '10', PMP_Action_Txt__c = 'Add', PMP_Contributing_Entitlement_Nm__c = 'Employee',
              PMP_Public_Group_Nm__c = 'PMP_<OPID>' );
            lstPGSM.add(pgms10);
            PMP_Public_Group_Management_Settings__c pgms11 = new PMP_Public_Group_Management_Settings__c(
              Name = '11', PMP_Action_Txt__c = 'Add', PMP_Contributing_Entitlement_Nm__c = 'Partner Admin',
              PMP_Public_Group_Nm__c = 'PMP_<OPID>' );
            lstPGSM.add(pgms11);
            PMP_Public_Group_Management_Settings__c pgms12 = new PMP_Public_Group_Management_Settings__c(
              Name = '12', PMP_Action_Txt__c = 'Add', PMP_Contributing_Entitlement_Nm__c = 'Partner Admin Delegate',
              PMP_Public_Group_Nm__c = 'PMP_<OPID>' );            
            lstPGSM.add(pgms12);
            PMP_Public_Group_Management_Settings__c pgms13 = new PMP_Public_Group_Management_Settings__c(
              Name = '13', PMP_Action_Txt__c = 'Add', PMP_Contributing_Entitlement_Nm__c = 'Lead Development Representative',
              PMP_Public_Group_Nm__c = 'PMP_<OPID>' );
            lstPGSM.add(pgms13);
            
            
            Database.insert(lstPGSM, false);
                // Sharing of Partner Account with Partner Account Group
                AccountShare accShare = new AccountShare();
                accShare.AccountId = partnerAccount1.Id;
                accShare.UserOrGroupId = lstPublicGroupToBeInserted[0].Id ;
                accShare.AccountAccessLevel = 'read';
                accShare.OpportunityAccessLevel = 'read';
             //Inserting list of AccountShare Records
               Database.insert(accShare);
            } 
    static testmethod void test(){
        Test.startTest();
        //System.runAs(new user(ID = UserInfo.getUserID())){
        
          //  Id batchId = Database.executeBatch(new PMP_Batch_Group_Management_Scheduler());
          Account acc = [Select id from Account WHERE Name ='PartnerAccount6' Limit 1];
          acc.Core_Account_Type__c = 'Original Design Manufacturer (ODM)';
          acc.Core_PMP_Membership_Change_Ind__c = true;
          update acc;

          Id batchId1 = Database.executeBatch(new PMP_Batch_Group_Management_Scheduler());
         acc.Core_PMP_Membership_Change_Ind__c = false;
          update acc;
          //  String chron = '0 0 * ? * * *' ;
          List<User> lstUsers = [Select Id from User where Contact.Email = 'dellco1234@dell.com' Limit 1];
          List<GroupMember> lstQueriedGrpsMembers = [SELECT Id,GroupId,UserOrGroupID, Group.DeveloperName FROM GroupMember where UserOrGroupID =:lstUsers[0].Id];
          // System.debug('size'+lstQueriedGrpsMembers.size());
        //  System.assertEquals( true , lstQueriedGrpsMembers.size() > 1 ? true : false, 'users are inserted in groups' );
        //    System.schedule('Record Deletion', chron, new PMP_Batch_Group_Management_Scheduler());
            //Core_Mp_Public_Group_Creation.updatePublicGroupMembership();
            //Core_Mp_Public_Group_Creation.refinePartnerAccounts(partnerAccountId,accts);
            
        //}
        // @IsTest
  
        String cronExp = '0 0 0 1 1 ? 2099'; // far future so it doesn't run now
      //  System.schedule('Test Job', cronExp, new PMP_Batch_Group_Management_Scheduler());
        Test.stopTest();
        
    }
	
    static testmethod void test2(){
		
         // Create Partner Account
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
		Account partnerAcc = new Account(Name ='PartnerAccount',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi', Core_PMP_Membership_Change_Ind__c = true);
      
        insert partnerAcc;

        // Create Intel Account with link to partner
        String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account intelAcc = new Account(Name ='IntelAccount',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        insert intelAcc;
        
        // Create Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com', AccountId = intelAcc.Id,MailingCountry='India');
        insert contact;

       		// Getting Current user information
            User currentUser = [select Id from User where Id = :UserInfo.getUserId()];
            User testUser;
            
            // System.debug('currentUser ='+currentUser);
            
            System.runAs (currentUser) {
                
                Profile profile = [select Id,name from Profile where Name ='Partner'];
                
                    // Creating user
                   testUser = new User(
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
                    contactId = contact.Id
                );
                //Inserting User
                insert testUser;
                
            
        // Create Group
        Group testGroup = new Group(Name = 'PMP_' + partnerAcc.Id, DeveloperName = 'PMP_' + partnerAcc.Id, Type = 'Regular');
        insert testGroup;
                
        // Create GroupMember
        GroupMember gm = new GroupMember(GroupId = testGroup.Id, UserOrGroupId = testUser.Id);
        insert gm;
                
        Test.startTest();        
        // Create Core_Account_Group_Member__c record
        Core_Account_Group_Member__c pag = new Core_Account_Group_Member__c(
            Core_Partner_Account_Id__c = partnerAcc.Id,
            Core_Intel_Account_Id__c = intelAcc.Id,
            Core_Inactive_Ind__c = false
        	);
        insert pag;
		pag.Core_Inactive_Ind__c = true;
		update pag;

        // Call the method
        Set<String> groupIdSet = new Set<String>(); //{ testGroup.Id };
        List<Core_Account_Group_Member__c> inactiveList = new List<Core_Account_Group_Member__c>(); //{ pag };

		groupIdSet.add('PMP_' + testGroup.Id);
		inactiveList.add(pag);

        PMP_Batch_Group_Management.removeUsersFromAllPartnersGrp(inactiveList, groupIdSet);
		Test.stopTest();
        // Assert the group member was deleted
        //GroupMember[] checkDeleted = [SELECT Id FROM GroupMember WHERE Id = :gm.Id];
        //System.assertEquals(0, checkDeleted.size(), 'GroupMember should be deleted');
        }
        
    }


}