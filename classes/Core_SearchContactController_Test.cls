@isTest(seeAllData=false)
public class Core_SearchContactController_Test {

    static Logginglevel logLevel = Logginglevel.DEBUG;
    static Profile profile1 = [SELECT Id FROM Profile WHERE Name='Partner' ];
    static final String DELL_CCF_EXTERNAL_GROUP_NAME = 'Core_CCP_Dell_CCF_External';
    
    @testSetup    
    public static void prepareTestData(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        UserRole ur = [Select Id, Name From UserRole WHERE Name = 'Admin' LIMIT 1];
        usr.UserRoleId =ur.Id ;
        usr.LastName = 'SysAdmin';
        usr.profileId = sysAdminProfile.Id;
        Database.insert(usr);
        
        system.runAs(usr) {
            
        
        
        String prfID = profile1.id;
        Account acc1 = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
                                   Core_Account_Type__c='Other', Industry='Others',
                                   BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                   BillingCountry='USA', BillingPostalCode='12345', Core_IsODM__c = true);
        Database.insert(acc1,true);
        
        Account acc2 = new Account(Name='testAccount234', Core_Sales_Group__c='Global Accounts',
                                   Core_Account_Type__c='Other', Industry='Others',
                                   BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                   BillingCountry='USA', BillingPostalCode='12345', Core_IsODM__c = true);
        Database.insert(acc2,true);
        
        Account acc3 = new Account(Name='testAccount345', Core_Sales_Group__c='Global Accounts',
                                   Core_Account_Type__c='Other', Industry='Others',
                                   BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                   BillingCountry='USA', BillingPostalCode='12345', Core_IsODM__c = true);
        Database.insert(acc3,true);
        
        /*Group groupFound = null;
        List<Group> groupFoundList = [Select Id, Name from Group where DeveloperName = :DELL_CCF_EXTERNAL_GROUP_NAME];
        if(groupFoundList !=null && groupFoundList.size() > 0){
            groupFound = groupFoundList[0];
        }
        System.debug(logLevel,'Group found = '+ groupFound);*/
        
        Group groupCreated = new Group(Name='Core_CCP_Dell_CCF_External');
        Database.insert(groupCreated,true);
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
        cprogram.Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund';
        Database.insert(cprogram);
        
        List<Core_MDF_Partner_Group_Mapping__c> pgMappingRecords = new List<Core_MDF_Partner_Group_Mapping__c>();
        
        Id groupId = groupCreated.Id; //groupFound
        Core_MDF_Partner_Group_Mapping__c pgMappingRec1 = new Core_MDF_Partner_Group_Mapping__c();
        Core_MDF_Partner_Group_Mapping__c pgMappingRec2 = new Core_MDF_Partner_Group_Mapping__c();

        if(groupCreated != null){ //groupFound
            pgMappingRec1.Core_MDF_Account__c = acc1.Id;
            pgMappingRec1.Core_MDF_Group_Name__c = groupCreated.Name; //groupFound
            System.debug(logLevel, 'groupCreated Id = '+ groupId); 
            pgMappingRec1.Core_MDF_Group_Id__c = groupId +'';
            pgMappingRec1.Core_MDF_Type_of_Access__c = 'External';
            pgMappingRec1.Core_MDF_Channel_Program__c = cprogram.Id;        
            pgMappingRecords.add(pgMappingRec1);
            
            
            pgMappingRec2.Core_MDF_Account__c = acc2.Id;
            pgMappingRec2.Core_MDF_Group_Name__c = groupCreated.Name; //groupFound
            pgMappingRec2.Core_MDF_Group_Id__c = groupId +'';
            pgMappingRec2.Core_MDF_Type_of_Access__c = 'External';
            pgMappingRec2.Core_MDF_Channel_Program__c = cprogram.Id;  
            pgMappingRec2.Core_MDF_Works_For__c = acc3.Id;
            pgMappingRecords.add(pgMappingRec2);
            
            Database.insert(pgMappingRecords);
        }
        
        
        System.debug(logLevel,'72 : pgMappingRecords = '+ pgMappingRecords);
        }
    }
    
    public static testmethod void testfetchContactbyEmail(){
        
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        List<Account> accList = [Select Id, Name from Account where Name = 'testAccount123' LIMIT 1];
        
        if(accList != null && accList.size() > 0){
            Account acc1 = accList[0];
            Contact contact = new Contact(FirstName='testFirstName123', LastName='TestLastName', Email='test1234@testing.com.test',
                                          AccountId=acc1.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true,
                                          Core_Audience_List__c ='CCF User Administrator;CCF User');
            
            Database.insert(contact,true);
            
            User user1 = new User(Alias = 'admUse2r', Email='forumuser@test.com', 
                                  EmailEncodingKey='UTF-8', LastName='Admin', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = profile1.Id, contactid=contact.Id,isActive =true,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='forumuser22@test.com',PortalRole = 'Manager');
            
            Database.insert(user1,true);
            System.debug(logLevel, 'user1 = ' + user1);
            Group groupFound = null;
            List<Group> groupFoundList = [Select Id, Name from Group where DeveloperName = :DELL_CCF_EXTERNAL_GROUP_NAME];
            if(groupFoundList !=null && groupFoundList.size() > 0){
                groupFound = groupFoundList[0];
            }
            System.debug(logLevel,'Group found = '+ groupFound);
            
            insertGroupMember(groupFound.id , user1.id);
            assert.areEqual(true,contact.Core_Personal_Email_Indicator__c);
            
            //GroupMember grpmember = new GroupMember (GroupId=g.id,UserOrGroupId=user1.id);
            //Database.insert(grpmember,true);
        }
        }
    }
    
    public static testmethod void testfetchContactbyEmailForAgency(){
        
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Group groupFound = null;
        List<Group> groupFoundList = [Select Id, Name from Group where DeveloperName = :DELL_CCF_EXTERNAL_GROUP_NAME];
        if(groupFoundList !=null && groupFoundList.size() > 0){
            groupFound = groupFoundList[0];
        }
        System.debug(logLevel,'Group found = '+ groupFound);
        
        Id groupId = groupFound.Id; //groupFound
        
        List<Account> accList = [Select Id, Name from Account where Name = 'testAccount234' LIMIT 1];

        if(accList != null && accList.size() > 0){
            
            Account acc1 = accList[0];
            Contact contact = new Contact(FirstName='testFirstName123', LastName='TestLastName', Email='test1234@testing.com.test',
                                          AccountId=acc1.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true,
                                          Core_Audience_List__c ='CCF User Administrator;CCF User');
            
            Database.insert(contact,true);
            
            User user1 = new User(Alias = 'admUse2r', Email='forumuser@test.com', 
                                  EmailEncodingKey='UTF-8', LastName='Admin', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = profile1.Id, contactid=contact.Id,isActive =true,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='forumuser22@test.com',PortalRole = 'Manager');
            
            Database.insert(user1,true);
            System.debug(logLevel, 'user1 = ' + user1);
            
            insertGroupMember(groupFound.id , user1.id);
            assert.areEqual(true,contact.Core_Personal_Email_Indicator__c);
        }
            
        //GroupMember grpmember = new GroupMember (GroupId=g.id,UserOrGroupId=user1.id);
        //Database.insert(grpmember,true);
        }
    }
    
    
    @future
    public static void insertGroupMember(Id groupId, Id userId){
        List<Core_MDF_Partner_Group_Mapping__c>  pgMappingList = [SELECT Core_MDF_Account__c,
                                                                  Core_MDF_Channel_Program__c,Core_MDF_Group_Id__c,
                                                                  Core_MDF_Group_Name__c,Core_MDF_Type_of_Access__c,
                                                                  Core_MDF_Works_For__c FROM Core_MDF_Partner_Group_Mapping__c
                                                                  ];
        
        System.debug('149 : pgMappingList = '+ pgMappingList);
        GroupMember grpmember = new GroupMember (GroupId= groupId, UserOrGroupId=userId);
        Database.insert(grpmember,true);
        List<Core_SerachContactController.ContactUser> conUsrList  = Core_SerachContactController.fetchContactbyEmail('test1234@testing.com.test', userId);
    }

}