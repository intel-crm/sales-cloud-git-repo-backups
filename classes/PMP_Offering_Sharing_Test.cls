/****************************************************************************************************************************************
* Class Name  : Core_Partner_Offering_Assignment_Test
* Version     : 1.0 
* Created Date: 21-05-2019
* Developer   : Draco team
* Description : Test class Implementation for Core_Partner_Offering_Assignment  Class  

*****************************************************************************************************************************************/

@isTest(seeAllData=false)
public class PMP_Offering_Sharing_Test {
    
    static final String PARTNER_CONTENT_VISIBILITY ='Partner Content'; 
    static final String PUBLISHED_Lifecycle_Status ='Published';
    static final String RECORD_SHARE_ACCESS_LEVEL = 'Read';
    static final String ALL_PARTNERS_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_ODM;
    static final String ALL_PARTNERS_NON_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_Non_ODM;
    static final String ALL_PARTNERS_GROUP = System.Label.PMP_Group_All_Partner_Users;
    //static final partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
    //List<PMP_Partner_Offering__c> offerngs= new List<PMP_Partner_Offering__c>();
    
@isTest
public static void  OfferingtestMethod ()
 //@testSetup
//static void setup()
{ 

        List<Account> accts = new List<Account>(); 
    	String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
    
        /***********************************Creating Partner,Intel Accounts*****************************/
    
        Account partnerAccount = new Account(Name ='PartnerAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                      Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId = partnerAccRecTypeId);
    
        System.debug('partnerAccount ='+partnerAccount.IsPartner);
        
            accts.add(partnerAccount);
        
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                      Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId = partnerAccRecTypeId);
            accts.add(partnerAccount1);
    
        Account intelAccount = new Account(Name ='IntelAccount',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'CCG Sales Group',
                                      Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'CCG Sales Group',
                                      Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts.add(intelAccount);
        accts.add(intelAccount1);
    
    PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
            insert apiKey;
        //Inserting Accounts
        //Test.startTest();
        Database.insert(accts);
               
      
       
       /*******************************Updating Accounts as partner******************************/
        List<Account>accToUpdate = new List<Account>();
        For(Account acc:accts){
            acc.IsPartner = true;
            accToUpdate.add(acc);
        }
    
        //Updating account as 
        Database.update(accToUpdate);
    
        System.debug('accToUpdate ='+accToUpdate);
        System.debug('partnerAccount.Id ='+partnerAccount.Id);
    
        /*********************Creating Partner Account Group Record***********************/
        List<Core_Account_Group_Member__c> accGroupMems = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
        accGroupMem1.Core_Partner_Account_Id__c =partnerAccount.Id;
        accGroupMem1.Core_Intel_Account_Id__c =intelAccount.Id;
        accGroupMems.add(accGroupMem1);
    
        Core_Account_Group_Member__c accGroupMem2 = new Core_Account_Group_Member__c();
        accGroupMem2.Core_Partner_Account_Id__c =partnerAccount1.Id;
        accGroupMem2.Core_Intel_Account_Id__c =intelAccount1.Id;
        accGroupMems.add(accGroupMem2);
        //Inserting Partner Account Group Member Record 
        Database.insert(accGroupMems);
    
       /******************Creating Contacts Records*******************/
    
        List<Contact> allContacts = new List<Contact>();
        Contact contact1 = new Contact(firstname='Partner', 
                lastname='Contact1', accountId=intelAccount.id,Email='dellco1234@dell.com');
        
        allContacts.add(contact1);
    
        Contact contact2 = new Contact(firstname='Partner', 
                lastname='Contact2', accountId=intelAccount1.id,Email='dellco12345@dell.com');
        allContacts.add(contact2);
               
        Database.insert(allContacts);
    
        User currentUser = [ select Id from User where Id = :UserInfo.getUserId()];
        List<User> userList = new List<User>();
        
        System.debug('currentUser ='+currentUser);
    
           // UserRole userRole = [Select PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
            Profile profile = [select Id,name from Profile where Name ='Partner'];
            User partneruser1 = new User(profileId = profile.id,username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com',email = 'pb@ff.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='lastname',contactId = contact1.id);
            userList.add(partneruser1);
    
            User partneruser2 = new User(profileId = profile.id,username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com',email = 'pb@ff.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='lastname',contactId = contact2.id);
            userList.add(partneruser2);
        System.runAs (currentUser) {
            
            Database.insert(userList);
            
       }
    
        System.debug('userList ='+userList);
    
    	 /*****************************Creating company information Record**************************/
    
    	List<PMP_Company__c> companyInfoRec = new List<PMP_Company__c>();
    	PMP_Company__c companyInfoRec1 = new PMP_Company__c(Name ='companyInfoRec1',PMP_Account_Id__c=intelAccount.Id);
    	Database.insert(companyInfoRec1);
    
        /*****************************Creating Offering Record**************************/
    
        List<PMP_Partner_Offering__c> offerngs= new List<PMP_Partner_Offering__c>(); 
        
        PMP_Partner_Offering__c newOffering = new PMP_Partner_Offering__c(OwnerId=partneruser1.Id, Name='offeringtest',PMP_Partner_Offering_Nm__c = 'offeringtest',PMP_Partner_Offering_Visibility_Nm__c='Partner Content',PMP_Partner_Offering_Lifecycle_Status_Nm__c='Draft',PMP_Company_Id__c=companyInfoRec1.Id);
        offerngs.add(newOffering);
    
        PMP_Partner_Offering__c newOffering1 = new PMP_Partner_Offering__c(OwnerId=partneruser2.Id, Name='offeringtest2',PMP_Partner_Offering_Nm__c = 'offeringtest2',PMP_Partner_Offering_Visibility_Nm__c='Public Content',PMP_Partner_Offering_Lifecycle_Status_Nm__c='Draft');
        offerngs.add(newOffering1);
        PMP_Partner_Offering__c newOffering3 = new PMP_Partner_Offering__c(OwnerId=partneruser2.Id, Name='offeringtest3',PMP_Partner_Offering_Nm__c = 'offeringtest3',PMP_Partner_Offering_Visibility_Nm__c='Public Content',PMP_Partner_Offering_Lifecycle_Status_Nm__c='Draft');
    
        offerngs.add(newOffering3);
        PMP_Partner_Offering__c newOffering4 = new PMP_Partner_Offering__c(OwnerId=partneruser2.Id, Name='offeringtest4',PMP_Partner_Offering_Nm__c = 'offeringtest4',PMP_Partner_Offering_Visibility_Nm__c='Public Content',PMP_Partner_Offering_Lifecycle_Status_Nm__c='Draft');
        offerngs.add(newOffering4);
    Test.startTest();
        Database.insert(offerngs);
        //Test.startTest();
        //newOffering3.PMP_Partner_Offering_Dsc__c ='test';
        newOffering.PMP_Partner_Offering_Dsc__c ='test';
        newOffering.PMP_Partner_Offering_Start_Dt__c = system.Today()-1;
        //newOffering3.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
        //newOffering3.PMP_Partner_Offering_Start_Dt__c = system.Today()-1;
        try{
            Database.update(newOffering);
        }catch(exception e){}
        
        System.debug('offerngs ='+offerngs);
   //Test.stopTest();
    
    List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
    
    
    
    /***********************Updating Partner Offering Record***********************/
    
    for(PMP_Partner_Offering__c offering:offerngs){ 
        offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = PUBLISHED_Lifecycle_Status;
        offering.PMP_Partner_Offering_Visibility_Nm__c = PARTNER_CONTENT_VISIBILITY;
        offeringList.add(offering);
    }
    //offeringList.add(newOffering3);
    //Updating Offering
    //Database.update(offeringList);
    
     //Test.stopTest();
    
    //newOffering3.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
        //newOffering3.PMP_Partner_Offering_Start_Dt__c = system.Today()-1;
        //Database.update(newOffering3);
    
    List<PMP_Partner_Offering__c> updatedOffering1 = [SELECT Id,Name From PMP_Partner_Offering__c Where Name='offeringtest'];
    List<PMP_Partner_Offering__c>updatedOffering2 = [SELECT Id,Name From PMP_Partner_Offering__c Where Name='offeringtest2'];
    
      
        System.debug('updatedOffering1'+updatedOffering1); 
    
    List<Group> lstGrps = new List<Group>();
    
    /**********************Creating Groups**********************************/
    
    Group grp1 = new Group(Name ='PMP_001',DeveloperName='PMP_001');
    Group grp2 = new Group(Name ='PMP_00112',DeveloperName='PMP_00112');
    lstGrps.add(grp1);
    lstGrps.add(grp2);
    Database.insert(lstGrps);
    System.debug('grp1 ='+grp1);
    System.debug('grp2 ='+grp2);
    String grpstr;
    grpstr ='PMP_'+ partnerAccount.Id;

    List<GroupMember> lstGrpMem = new List<GroupMember>();
        
    GroupMember grpMem = new GroupMember();
    grpMem.UserOrGroupId = partneruser1.Id;
    grpMem.GroupId =grp1.Id;    
    lstGrpMem.add(grpMem);
    
    
    GroupMember odmGrpMem = new GroupMember();
    odmGrpMem.UserOrGroupId = grp1.Id; 
    odmGrpMem.GroupId =ALL_PARTNERS_ODM_GROUP;
    lstGrpMem.add(odmGrpMem);
    
    GroupMember grpMem2 = new GroupMember();
    grpMem2.UserOrGroupId = partneruser2.Id;
    grpMem2.GroupId =grp2.Id;     
    lstGrpMem.add(grpMem2);
    
    GroupMember nonOdmGrpMem = new GroupMember();
    nonOdmGrpMem.UserOrGroupId = grp2.Id;
    nonOdmGrpMem.GroupId =ALL_PARTNERS_NON_ODM_GROUP;     
    lstGrpMem.add(nonOdmGrpMem);
    

    System.runAs (currentUser) {
        
        Database.saveResult[] srlist = Database.insert(lstGrpMem, false);
        System.debug('srlist ='+srlist);
        
    }
    
    //Test.stopTest();
    /************* Creating PMP_Partner_Offering__Share record*****************/
        
            List<PMP_Partner_Offering__Share> lstPartnerOffering = new List<PMP_Partner_Offering__Share>();
            PMP_Partner_Offering__Share offeringShare = new PMP_Partner_Offering__Share();
                        offeringShare.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL;
                        offeringShare.UserOrGroupId  = grp1.Id; 
                        System.debug('UserOrGroupId ='+grp1.Id);
                        offeringShare.ParentId = newOffering.Id;
                        lstPartnerOffering.add(offeringShare);
                        System.debug('lstPartnerOffering ='+lstPartnerOffering);
                
                
        
    
            PMP_Partner_Offering__Share updatedOfferingShare = new PMP_Partner_Offering__Share();
                        updatedOfferingShare.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL;
                        updatedOfferingShare.UserOrGroupId  = ALL_PARTNERS_NON_ODM_GROUP;  
                        updatedOfferingShare.ParentId = updatedOffering1[0].Id;
                        lstPartnerOffering.add(updatedOfferingShare);
                        System.debug('lstPartnerOffering ='+lstPartnerOffering);
                    
    
    /*************************************************************************/
    
            PMP_Partner_Offering__Share offeringShare2 = new PMP_Partner_Offering__Share();
                        offeringShare2.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL;
                        offeringShare2.UserOrGroupId  = grp2.Id; //pmpGroup.Id;
                        System.debug('UserOrGroupId ='+grp2.Id);
                        offeringShare2.ParentId = newOffering1.Id;
                        lstPartnerOffering.add(offeringShare2);
                        System.debug('lstPartnerOffering ='+lstPartnerOffering);
            
                
        
    
            PMP_Partner_Offering__Share updatedOfferingShare1 = new PMP_Partner_Offering__Share();
                        updatedOfferingShare1.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL;
                        updatedOfferingShare1.UserOrGroupId  = ALL_PARTNERS_GROUP;  
                        updatedOfferingShare1.ParentId = updatedOffering1[0].Id;
                        lstPartnerOffering.add(updatedOfferingShare1);
                        System.debug('lstPartnerOffering ='+lstPartnerOffering);
                    Database.insert(lstPartnerOffering);
    
   List<PMP_Partner_Offering__c> offeringToBedeleted = new List<PMP_Partner_Offering__c>();
     for(PMP_Partner_Offering__c offeringToDelete:updatedOffering1){
        offeringToDelete.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'New';
        offeringToDelete.PMP_Partner_Offering_Visibility_Nm__c = 'Public Content';
        offeringToBedeleted.add(offeringToDelete);
    }
        Database.Update(offeringToBedeleted); 
    
    System.debug('updatedOffering1 ='+updatedOffering1[0].Id);
    
    List<PMP_Partner_Offering__Share> offeringShareRecs = new List<PMP_Partner_Offering__Share>([SELECT 
                                                                 UserOrGroupId,ParentId,Id FROM PMP_Partner_Offering__Share
                                                                 where ParentId =:offeringToBedeleted[0].Id]);  //offeringToBedeleted[0].Id  //offringIds
    List<PMP_Partner_Offering__Share> offeringShareFinalList = new List<PMP_Partner_Offering__Share>();
    for(PMP_Partner_Offering__Share offeringShareRec : offeringShareRecs){
                
                
                if((offeringShareRec.UserOrGroupId == ALL_PARTNERS_GROUP)
                   || (offeringShareRec.UserOrGroupId == ALL_PARTNERS_NON_ODM_GROUP)){
                      offeringShareFinalList.add(offeringShareRec);
                   }
            }
        System.debug('offeringShareFinalList ='+offeringShareFinalList);
        Database.delete(offeringShareFinalList); 
      
            //Test.startTest();
                PMP_Offering_Sharing.sharePartnerOfferingRecords(offerngs,offerngs);
     
                PMP_Offering_Sharing.sharePartnerOfferingRecords(offeringToBedeleted,offeringToBedeleted);
            Test.stopTest();
        //test(offerngs,offerngs);
             
        }
    /*static testmethod void test(List<PMP_Partner_Offering__c> offerngs,List<PMP_Partner_Offering__c> offeringToBedeleted){
        Test.startTest();
                PMP_Offering_Sharing.sharePartnerOfferingRecords(offerngs,offerngs);
     
                PMP_Offering_Sharing.sharePartnerOfferingRecords(offeringToBedeleted,offeringToBedeleted);
       Test.stopTest();
    }*/
    }