/****************************************************************************************************************************************
* Class Name  : Core_Partner_Offering_Assignment_Test
* Version     : 1.0 
* Created Date: 21-05-2019
* Developer   : Draco team
* Description : Test class Implementation for Core_Partner_Offering_Assignment  Class  


*****************************************************************************************************************************************/

@isTest(seeAllData=false)
public class PMP_Offering_Sharing_Test {
    
//     static final String PARTNER_CONTENT_VISIBILITY ='Partner Content'; 
//     static final String PUBLISHED_Lifecycle_Status ='Published';
//     static final String RECORD_SHARE_ACCESS_LEVEL = 'Read';
//     static final String ALL_PARTNERS_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_ODM;
//     static final String ALL_PARTNERS_NON_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_Non_ODM;
//     static final String ALL_PARTNERS_GROUP = System.Label.PMP_Group_All_Partner_Users;
//     //static final partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
//     //List<PMP_Partner_Offering__c> offerngs= new List<PMP_Partner_Offering__c>();
    
//       @isTest
//     public static void  OfferingtestMethod ()
//         //@testSetup
//         //static void setup()
//     { 
//         User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
//         //createUserRole();
//         UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
//         adminUser.userRoleId = role.id;
//         update adminUser;
        
//         //Need to run as admin with RoleId, to insert a partner User.
//         System.runAs(adminUser) {
        
//         List<Account> accts = new List<Account>(); 
//         String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        
//         /***********************************Creating Partner,Intel Accounts*****************************/
        
//         Account partnerAccount = new Account(Name ='PartnerAccount',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Group_New__c= 'CCG Sales Group',
//                                              Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId = partnerAccRecTypeId);
        
//         // System.debug('partnerAccount ='+partnerAccount.IsPartner);
        
//         accts.add(partnerAccount);
        
//         Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Group_New__c= 'CCG Sales Group',
//                                               Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId = partnerAccRecTypeId);
//         accts.add(partnerAccount1);
        
//         Account intelAccount = new Account(Name ='IntelAccount',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Group_New__c= 'CCG Sales Group',
//                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
//         Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'System Integrator',Core_Sales_Group_New__c= 'CCG Sales Group',
//                                             Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
//         accts.add(intelAccount);
//         accts.add(intelAccount1);
        
//         PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
//         insert apiKey;
//         //Inserting Accounts
//         //Test.startTest();
//         User currentUser = [ select Id from User where Id = :UserInfo.getUserId()];
//         System.runAs(currentUser) {
//         Database.insert(accts);
//         }
        
        
        
//         /*******************************Updating Accounts as partner******************************/
//         List<Account>accToUpdate = new List<Account>();
//         For(Account acc:accts){
//             acc.IsPartner = true;
//             accToUpdate.add(acc);
//         }
        
//         //Updating account as 
//         Database.update(accToUpdate);
        
//         //System.debug('accToUpdate ='+accToUpdate);
//         //System.debug('partnerAccount.Id ='+partnerAccount.Id);
        
//         /*********************Creating Partner Account Group Record***********************/
//         List<Core_Account_Group_Member__c> accGroupMems = new List<Core_Account_Group_Member__c>();
//         Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
//         accGroupMem1.Core_Partner_Account_Id__c =partnerAccount.Id;
//         accGroupMem1.Core_Intel_Account_Id__c =intelAccount.Id;
//         accGroupMems.add(accGroupMem1);
        
//         Core_Account_Group_Member__c accGroupMem2 = new Core_Account_Group_Member__c();
//         accGroupMem2.Core_Partner_Account_Id__c =partnerAccount1.Id;
//         accGroupMem2.Core_Intel_Account_Id__c =intelAccount1.Id;
//         accGroupMems.add(accGroupMem2);
//         //Inserting Partner Account Group Member Record 
//         Database.insert(accGroupMems);
        
//         /******************Creating Contacts Records*******************/
//          List<Contact> allContacts = new List<Contact>();

       
//         Contact contact1 = new Contact(firstname='Partner', MailingCountry='IOT',
//                                        lastname='Contact1', accountId=intelAccount.id,Email='dellco1234@dell.com');
        
//         allContacts.add(contact1);
        
//         Contact contact2 = new Contact(firstname='Partner',MailingCountry='IOT', 
//                                        lastname='Contact2', accountId=intelAccount1.id,Email='dellco12345@dell.com');
//         allContacts.add(contact2);
//         System.runAs(currentUser) {
//         Database.insert(allContacts);
//         }
        
        
//         List<User> userList = new List<User>();
        
//         // System.debug('currentUser ='+currentUser);
        
//         // UserRole userRole = [Select PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
//         Profile profile = [select Id,name from Profile where Name ='Partner'];
        
//         //List<UserRole> user1 = [select Id from UserRole where PortalType='Partner'];
        
//         User partneruser1 = new User(profileId = profile.id,username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com',email = 'pb@ff.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='lastname',contactId = contact1.id);
//         userList.add(partneruser1);
        
//         User partneruser2 = new User(profileId = profile.id,username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com',email = 'pb@ff.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='lastname',contactId = contact2.id);
//         userList.add(partneruser2);
        
//        // System.runAs(currentUser) {
//           Database.insert(userList);
//         // }
            
       
        
//         // System.debug('userList ='+userList);
        
//         /*****************************Creating company information Record**************************/
        
//         List<PMP_Company__c> companyInfoRec = new List<PMP_Company__c>();
       
//         PMP_Company__c companyInfoRec1 = new PMP_Company__c();
//         companyInfoRec1.PMP_Opid_Sfid_Txt__c = partnerAccount.Id;
//         companyInfoRec1.Name ='companyInfoRec1';
//         companyInfoRec1.PMP_Benefit_Update_Ind__c=False;
//         companyInfoRec1.PMP_Partner_Inactive_Ind__c = False;
//         companyInfoRec1.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
//         companyInfoRec1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
//         companyInfoRec1.PMP_Is_Published_Ind__c=true;
//         Database.insert(companyInfoRec1); 
        
//        // PMP_Company__c companyInfoRec2 = new PMP_Company__c(Name ='companyInfoRec2',PMP_Account_Id__c=intelAccount.Id,PMP_One_Partner_ID__c =partnerAccount.Id);
//         //Database.insert(companyInfoRec2);
        
//         PMP_Company__c companyInfoRec2 = new PMP_Company__c();
//         companyInfoRec2.PMP_Opid_Sfid_Txt__c = partnerAccount1.Id;
//         companyInfoRec2.Name ='companyInfoRec2';
//         companyInfoRec2.PMP_Benefit_Update_Ind__c=False;
//         companyInfoRec2.PMP_Partner_Inactive_Ind__c = False;
//         companyInfoRec2.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
//         companyInfoRec2.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
//         companyInfoRec2.PMP_Is_Published_Ind__c=true;
//         Database.insert(companyInfoRec2); 
        
//         /*****************************Creating Offering Record**************************/
        
//         List<PMP_Partner_Offering__c> offerngs= new List<PMP_Partner_Offering__c>(); 
        
//         PMP_Partner_Offering__c newOffering = new PMP_Partner_Offering__c(OwnerId=partneruser1.Id, Name='offeringtest',PMP_Partner_Offering_Nm__c = 'offeringtest',PMP_Partner_Offering_Visibility_Nm__c='Public Content',PMP_Partner_Offering_Lifecycle_Status_Nm__c='Draft',PMP_Company_Id__c=companyInfoRec1.Id);
//         offerngs.add(newOffering);
        
        
        
//         PMP_Partner_Offering__c newOffering1 = new PMP_Partner_Offering__c(OwnerId=partneruser2.Id, Name='offeringtest2',PMP_Partner_Offering_Nm__c = 'offeringtest2',PMP_Partner_Offering_Visibility_Nm__c='Public Content',PMP_Partner_Offering_Lifecycle_Status_Nm__c='Draft',PMP_Company_Id__c=companyInfoRec2.Id);
//         offerngs.add(newOffering1);
//         PMP_Partner_Offering__c newOffering3 = new PMP_Partner_Offering__c(OwnerId=partneruser2.Id, Name='offeringtest3',PMP_Partner_Offering_Nm__c = 'offeringtest3',PMP_Partner_Offering_Visibility_Nm__c='Public Content',PMP_Partner_Offering_Lifecycle_Status_Nm__c='Draft');
        
//         offerngs.add(newOffering3);
//         PMP_Partner_Offering__c newOffering4 = new PMP_Partner_Offering__c(OwnerId=partneruser2.Id, Name='offeringtest4',PMP_Partner_Offering_Nm__c = 'offeringtest4',PMP_Partner_Offering_Visibility_Nm__c='Public Content',PMP_Partner_Offering_Lifecycle_Status_Nm__c='Draft');
//         offerngs.add(newOffering4);
//         Test.startTest();
//         Database.insert(offerngs);
        
        
        
//          PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
//         jun.PMP_One_Partner_ID__c= partnerAccount.Id;
//         jun.PMP_Marketing_Profile_Id__c= companyInfoRec1.Id;
//         jun.Is_Active__c=false;     
//         insert jun;
        
//         PMP_Company_Info_TriggerHandler.offeringSharingOpidRecursive = False;
        
//         jun.Is_Active__c=true; 
//         update jun;
//         Map<Id,PMP_OPID_MPI_Rel__c> oldMap = new Map<Id,PMP_OPID_MPI_Rel__c>{jun.Id=>jun};
        
//         PMP_OPID_MPI_Rel__c jun1= new PMP_OPID_MPI_Rel__c();
//         jun1.PMP_One_Partner_ID__c= partnerAccount1.Id;
//         jun1.PMP_Marketing_Profile_Id__c= companyInfoRec2.Id;
//         jun1.Is_Active__c=true;     
//         insert jun1;
        
//         PMP_OPID_MPI_Rel__c junction = [SELECT Id,Is_Active__c,PMP_Marketing_Profile_Id__c,PMP_One_Partner_ID__c, PMP_Is_PagAccount_Ind__c FROM PMP_OPID_MPI_Rel__c WHERE PMP_One_Partner_ID__c =: partnerAccount1.Id];
//         Map<Id,PMP_OPID_MPI_Rel__c> newMap = new Map<Id,PMP_OPID_MPI_Rel__c>{junction.Id=>junction};

//         PMP_Offering_Sharing.onAccountMPIUpsertOfferSharing(newMap, null);
//         junction.Is_Active__c=false;
//         Map<Id,PMP_OPID_MPI_Rel__c> newMap1 = new Map<Id,PMP_OPID_MPI_Rel__c>{junction.Id=>junction};
//         PMP_Offering_Sharing.onAccountMPIUpsertOfferSharing(newMap1, null);
//         //Test.startTest();
//         //newOffering3.PMP_Partner_Offering_Dsc__c ='test';
//         newOffering.PMP_Partner_Offering_Dsc__c ='test';
//         newOffering.PMP_Partner_Offering_Start_Dt__c = system.Today()-1;
//         //newOffering3.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
//         //newOffering3.PMP_Partner_Offering_Start_Dt__c = system.Today()-1;
//         try{
//             Database.update(newOffering);
//         }catch(exception e){}
        
//         // System.debug('offerngs ='+offerngs);
//         //Test.stopTest();
        
//         List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
        
        
        
//         /***********************Updating Partner Offering Record***********************/
        
//         for(PMP_Partner_Offering__c offering:offerngs){ 
//             offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = PUBLISHED_Lifecycle_Status;
//             offering.PMP_Partner_Offering_Visibility_Nm__c = 'Public Content';
//             offeringList.add(offering);
//         }
//         //offeringList.add(newOffering3);
//         //Updating Offering
//         //Database.update(offeringList);
        
//         //Test.stopTest();
        
//         //newOffering3.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
//         //newOffering3.PMP_Partner_Offering_Start_Dt__c = system.Today()-1;
//         //Database.update(newOffering3);
        
//         List<PMP_Partner_Offering__c> updatedOffering1 = [SELECT Id,Name From PMP_Partner_Offering__c Where Name='offeringtest'];
//         List<PMP_Partner_Offering__c>updatedOffering2 = [SELECT Id,Name From PMP_Partner_Offering__c Where Name='offeringtest2'];
        
        
//         // System.debug('updatedOffering1'+updatedOffering1); 
        
//         List<Group> lstGrps = new List<Group>();
        
//         /**********************Creating Groups**********************************/
        
//         Group grp1 = new Group(Name ='PMP_001',DeveloperName='PMP_001');
//         Group grp2 = new Group(Name ='PMP_00112',DeveloperName='PMP_00112');
//         lstGrps.add(grp1);
//         lstGrps.add(grp2);
//         Database.insert(lstGrps);
//         //System.debug('grp1 ='+grp1);
//         //System.debug('grp2 ='+grp2);
//         String grpstr;
//         grpstr ='PMP_'+ partnerAccount.Id;
        
//         List<GroupMember> lstGrpMem = new List<GroupMember>();
        
//         GroupMember grpMem = new GroupMember();
//         grpMem.UserOrGroupId = partneruser1.Id;
//         grpMem.GroupId =grp1.Id;    
//         lstGrpMem.add(grpMem);
        
        
//         GroupMember odmGrpMem = new GroupMember();
//         odmGrpMem.UserOrGroupId = grp1.Id; 
//         odmGrpMem.GroupId =ALL_PARTNERS_ODM_GROUP;
//         lstGrpMem.add(odmGrpMem);
        
//         GroupMember grpMem2 = new GroupMember();
//         grpMem2.UserOrGroupId = partneruser2.Id;
//         grpMem2.GroupId =grp2.Id;     
//         lstGrpMem.add(grpMem2);
        
//         GroupMember nonOdmGrpMem = new GroupMember();
//         nonOdmGrpMem.UserOrGroupId = grp2.Id;
//         nonOdmGrpMem.GroupId =ALL_PARTNERS_NON_ODM_GROUP;     
//         lstGrpMem.add(nonOdmGrpMem);
        
        
//         System.runAs (currentUser) {
            
//             Database.saveResult[] srlist = Database.insert(lstGrpMem, false);
//             //System.debug('srlist ='+srlist);
            
//         }
        
//         //Test.stopTest();
//         /************* Creating PMP_Partner_Offering__Share record*****************/
        
//         List<PMP_Partner_Offering__Share> lstPartnerOffering = new List<PMP_Partner_Offering__Share>();
//         PMP_Partner_Offering__Share offeringShare = new PMP_Partner_Offering__Share();
//         offeringShare.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL;
//         offeringShare.UserOrGroupId  = grp1.Id; 
//         //System.debug('UserOrGroupId ='+grp1.Id);
//         offeringShare.ParentId = newOffering.Id;
//         lstPartnerOffering.add(offeringShare);
//         //System.debug('lstPartnerOffering ='+lstPartnerOffering);
        
        
        
        
//         PMP_Partner_Offering__Share updatedOfferingShare = new PMP_Partner_Offering__Share();
//         updatedOfferingShare.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL;
//         updatedOfferingShare.UserOrGroupId  = ALL_PARTNERS_NON_ODM_GROUP;  
//         updatedOfferingShare.ParentId = updatedOffering1[0].Id;
//         lstPartnerOffering.add(updatedOfferingShare);
//         //System.debug('lstPartnerOffering ='+lstPartnerOffering);
        
        
//         /*************************************************************************/
        
//         PMP_Partner_Offering__Share offeringShare2 = new PMP_Partner_Offering__Share();
//         offeringShare2.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL;
//         offeringShare2.UserOrGroupId  = grp2.Id; //pmpGroup.Id;
//         //System.debug('UserOrGroupId ='+grp2.Id);
//         offeringShare2.ParentId = newOffering1.Id;
//         lstPartnerOffering.add(offeringShare2);
//         //System.debug('lstPartnerOffering ='+lstPartnerOffering);
        
        
        
        
//         PMP_Partner_Offering__Share updatedOfferingShare1 = new PMP_Partner_Offering__Share();
//         updatedOfferingShare1.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL;
//         updatedOfferingShare1.UserOrGroupId  = ALL_PARTNERS_GROUP;  
//         updatedOfferingShare1.ParentId = updatedOffering1[0].Id;
//         lstPartnerOffering.add(updatedOfferingShare1);
//         //System.debug('lstPartnerOffering ='+lstPartnerOffering);
//         Database.insert(lstPartnerOffering);
        
//         List<PMP_Partner_Offering__c> offeringToBedeleted = new List<PMP_Partner_Offering__c>();
//         for(PMP_Partner_Offering__c offeringToDelete:updatedOffering1){
//             offeringToDelete.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'New';
//             offeringToDelete.PMP_Partner_Offering_Visibility_Nm__c = 'Public Content';
//             offeringToBedeleted.add(offeringToDelete);
//         }
//         Database.Update(offeringToBedeleted); 
        
//         //System.debug('updatedOffering1 ='+updatedOffering1[0].Id);
        
//         List<PMP_Partner_Offering__Share> offeringShareRecs = new List<PMP_Partner_Offering__Share>([SELECT 
//                                                                                                      UserOrGroupId,ParentId,Id FROM PMP_Partner_Offering__Share
//                                                                                                      where ParentId =:offeringToBedeleted[0].Id]);  //offeringToBedeleted[0].Id  //offringIds
//         List<PMP_Partner_Offering__Share> offeringShareFinalList = new List<PMP_Partner_Offering__Share>();
//         for(PMP_Partner_Offering__Share offeringShareRec : offeringShareRecs){
            
            
//             if((offeringShareRec.UserOrGroupId == ALL_PARTNERS_GROUP)
//                || (offeringShareRec.UserOrGroupId == ALL_PARTNERS_NON_ODM_GROUP)){
//                    offeringShareFinalList.add(offeringShareRec);
//                }
//         }
//         //System.debug('offeringShareFinalList ='+offeringShareFinalList);
//         Database.delete(offeringShareFinalList);  
        
        
//         Map<Id,PMP_Partner_Offering__c>  oldOfferingRecords = new Map<Id,PMP_Partner_Offering__c>();
//         Map<Id,PMP_Partner_Offering__c>  newOfferingRecords = new Map<Id,PMP_Partner_Offering__c>();
//         oldOfferingRecords.put(newOffering.id,newOffering);
//         newOfferingRecords.put(newOffering1.id,newOffering1);
//         //Test.startTest();
//         PMP_Offering_Sharing.sharePartnerOfferingRecords(offerngs,offerngs);
        
//         PMP_Offering_Sharing.sharePartnerOfferingRecords(offeringToBedeleted,offeringToBedeleted);
        
//         //PMP_Offering_Sharing.removeOldMPIOfferingSharing(oldOfferingRecords,newOfferingRecords); 
//         Test.stopTest();
        
//         List<Group> lstGroups = [SELECT Id,DeveloperName,Name FROM Group Limit 100];
//         System.assertEquals(true,lstGroups.size() > 0 ? true : false );
//         //test(offerngs,offerngs);
//         List<PMP_Partner_Offering__c> OfferingList1 = new List<PMP_Partner_Offering__c>();
//         OfferingList1.add(newOffering);
//         OfferingList1.add(newOffering1);
//         PMP_Offering_Sharing.shareOfferingRecords(null, OfferingList1);

//         PMP_Partner_Offering__c offeringData = [SELECT Id, PMP_Company_Id__c FROM PMP_Partner_Offering__c WHERE Name='offeringtest'];
//         Map<Id,PMP_Partner_Offering__c>  oldOfferingRecords1 = new Map<Id,PMP_Partner_Offering__c>{offeringData.Id=>offeringData};
        
            
//         PMP_Partner_Offering__c offeringData1 = [SELECT Id, PMP_Company_Id__c FROM PMP_Partner_Offering__c WHERE Name='offeringtest'];    
//         offeringData1.PMP_Company_Id__c=companyInfoRec2.Id;
//         Map<Id,PMP_Partner_Offering__c>  newOfferingRecords1 = new Map<Id,PMP_Partner_Offering__c>{offeringData1.Id=>offeringData1};
        
//             PMP_Offering_Sharing.removeOldMPIOfferingSharing(oldOfferingRecords1,newOfferingRecords1);
//     }
    
//   }  
//     /*static testmethod void test(List<PMP_Partner_Offering__c> offerngs,List<PMP_Partner_Offering__c> offeringToBedeleted){
// Test.startTest();
// PMP_Offering_Sharing.sharePartnerOfferingRecords(offerngs,offerngs);

// PMP_Offering_Sharing.sharePartnerOfferingRecords(offeringToBedeleted,offeringToBedeleted);
// Test.stopTest();
// }*/
//      public static testMethod void removeOldMPIOfferingSharingTest(){
//         prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
//         rec.Name = 'ABA_Trigger';
//         rec.inactive__c = false;
//         insert rec;
        
//         PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
//         cust.Name='BatchFieldValues';
//         cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
//         cust.PRM_PartnerRole__c= 'Service Provider';
//         cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
//         insert cust;
        
//         ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
//         cpIPA.Name='Intel Partner Alliance';
//         cpIPA.PRM_programCode__c='IPA';
//         insert cpIPA;

//         ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
//         cplTitanium.Name='Titanium';
//         cplTitanium.ProgramId=cpIPA.Id;
//         insert cplTitanium;
        
//         PMP_Static_Constants__c p = new PMP_Static_Constants__c();
//     p.name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
//     p.PMP_Value__c = 'BNFTSMBA';
//     insert p;

//         Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
//         Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
//         Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
//         // Account accObj1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'System Integrator',Core_Sales_Group_New__c= 'CCG Sales Group',
//         //                                    Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
                
//         List<Account> accts = new List<Account>();
//         Account newPagAccount = new Account();//Account
//         newPagAccount.RecordTypeId = recordTypeIdPagAccount;
//         newPagAccount.Name='Greg Thomas';
//         newPagAccount.BillingCity='City';
//         newPagAccount.BillingStreet='Street';
//         newPagAccount.BillingCountry='India';
//         newPagAccount.BillingPostalCode='Postal code';
//         newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
//         accts.add(newPagAccount);
//         insert accts;
        
//        // Account newPagAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
//         //                                      Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId = recordTypeIdPagAccount);
        
//         PMP_Company__c company=new PMP_Company__c();
//         company.Name=accObj.Name;
//         //company.PMP_Account_Id__c=accObj.id;
//         //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
//         company.PMP_Benefit_Update_Ind__c=False;
//         company.PMP_Partner_Inactive_Ind__c = False;
//         company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
//         company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
//         company.PMP_Is_Published_Ind__c=true;
//         insert company;
//         System.assertNotEquals(company, Null);
        
//       /*  PMP_Company__c company1=new PMP_Company__c();
//         company1.Name=accObj1.Name;
//         //company.PMP_Account_Id__c=accObj.id;
//         //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
//         company1.PMP_Benefit_Update_Ind__c=False;
//         company1.PMP_Partner_Inactive_Ind__c = False;
//         company1.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
//         company1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
//         company1.PMP_Is_Published_Ind__c=true;
//         insert company1;
//         System.assertNotEquals(company1, Null);
//        */ 
//         PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
//         acm.PRM_Account_Id__c=newPagAccount.id;
//         acm.PRM_Status_Nm__c='Approved';
//         acm.PRM_Channel_Program_Id__c=cpIPA.Id;
//         acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
//         acm.PRM_Partner_Role__c='Service Provider';
//         insert acm;
        
//         /* PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c(); //Account Channel Membership
//         acm1.PRM_Account_Id__c=newPagAccount1.id;
//         acm1.PRM_Status_Nm__c='Approved';
//         acm1.PRM_Channel_Program_Id__c=cpIPA.Id;
//         acm1.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
//         acm1.PRM_Partner_Role__c='Service Provider';
//         insert acm1;
//         */
//         Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
//         coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
//         coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
//         insert coreAccnt;
        
//        /* Core_Account_Group_Member__c coreAccnt1 = new Core_Account_Group_Member__c();
//         coreAccnt1.Core_Partner_Account_Id__c = newPagAccount1.id;
//         coreAccnt1.Core_Intel_Account_Id__c = accObj1.id; 
//         insert coreAccnt1;
// */       
//         PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
//         jun.PMP_One_Partner_ID__c= newPagAccount.Id;
//         jun.PMP_Marketing_Profile_Id__c= company.Id;
//         jun.Is_Active__c=true;     
//         insert jun;
        
//        /* PMP_OPID_MPI_Rel__c jun1= new PMP_OPID_MPI_Rel__c();
//         jun1.PMP_One_Partner_ID__c= newPagAccount1.Id;
//         jun1.PMP_Marketing_Profile_Id__c= company1.Id;
//         jun1.Is_Active__c=true;     
//         insert jun1;
//       */  
//          List<PMP_Partner_Offering__c> OldOfferings= new List<PMP_Partner_Offering__c>(); 
        
//         PMP_Partner_Offering__c Offering = new PMP_Partner_Offering__c(Name='offeringtest',PMP_Is_ODM_Ind__c=true,PMP_Partner_Offering_Nm__c = 'offeringtest',PMP_Partner_Offering_Visibility_Nm__c='Public Content',PMP_Partner_Offering_Lifecycle_Status_Nm__c='Draft',PMP_Company_Id__c=company.Id);
//         OldOfferings.add(Offering);
//         insert OldOfferings;
//         Map<Id,PMP_Partner_Offering__c>  oldOfferingRecords = new Map<Id,PMP_Partner_Offering__c>();
//         oldOfferingRecords.put(Offering.id,Offering);
        
       
//         Offering.Name = 'offeringtest1';
//         update Offering;
//          Map<Id,PMP_Partner_Offering__c>  newOfferingRecords = new Map<Id,PMP_Partner_Offering__c>();
//         newOfferingRecords.put(Offering.id,Offering);
//        // PMP_Partner_Offering__c newOffering1 = new PMP_Partner_Offering__c(Name='offeringtest2',PMP_Partner_Offering_Nm__c = 'offeringtest2',PMP_Partner_Offering_Visibility_Nm__c='Public Content',PMP_Partner_Offering_Lifecycle_Status_Nm__c='Draft',PMP_Company_Id__c=company1.Id);
//         //offerngs.add(newOffering1);
        

        
        
//         //PMP_Offering_Sharing.removeOldMPIOfferingSharing(oldOfferingRecords,newOfferingRecords);
        
//     }
    
    
}