@isTest
public class PMP_NavigationBarAPIDetails_Test {
    
    @isTest
    public static void getNavBarDetailsTest(){
        
        Test.startTest();
        
        //create users
        UserRole ur = [Select Id,PortalType, PortalAccountId From UserRole where Name='Admin' limit 1];
        User thisUSer=[Select Id,UserRoleId  from User where Id=:UserInfo.getUserId()];
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        thisUSer.UserRoleId=ur.Id;
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account intelAccount;
        Contact conObj;
        User poeUser;
        System.runAs(thisUser){
            update thisUSer; 
            intelAccount = PMP_TestDataUtility.createIntelAccount('Intel Account10B',devRecordTypeId,true);
            conObj = PMP_TestDataUtility.createContact(intelAccount.id,true);
            Profile prf2=[SELECT Id  FROM Profile WHERE name='Partner' limit 1];
            
            
            poeUser = new User(/*UserRoleId  = ur.Id,*/ Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                               EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = prf2.Id,
                               TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                               FirstName='Test'
                              );
            poeUser.ContactId=conObj.Id;
            poeUser.isActive=true;
            insert poeUser;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='PMP_External_Employee'];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = poeUser.Id,
                PermissionSetId = ps.Id
            );
            insert psa;
            
            
            User inteluser = new User(/**UserRoleId  = ur.Id,**/Alias = 'alias', Email='testUsercoreMDFinternal@intel.com',
                                      EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                      LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                      TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test');
            insert inteluser;
            
            System.runAs(inteluser) {
                PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name='PMP_Internal_Intel_Admin'];
                PermissionSetAssignment psa1 = new PermissionSetAssignment(
                    AssigneeId = inteluser.Id,
                    PermissionSetId = ps1.Id
                );
                insert psa1;
                
                
            }
            
            //partner acc start
            devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
            //Account partnerAccount = PMP_TestDataUtility.createIntelAccount('Partner Account10',devRecordTypeId,true);
            Account partnerAccount = new Account();
            partnerAccount.RecordTypeId = devRecordTypeId;
            partnerAccount.Name = 'Partner Account10';       
            partnerAccount.Core_Account_Country__c='India';
            partnerAccount.Core_Sales_Group_New__c='US Sales Group';
            partnerAccount.Core_Account_Type__c='ODM';
            partnerAccount.BillingStreet='Bangalore Central';
            partnerAccount.BillingCity='Bangalore';
            partnerAccount.BillingCountry='IND';
            partnerAccount.BillingState='KA';
            partnerAccount.BillingPostalCode='560029';
            partnerAccount.Industry='Agriculture';
            insert partnerAccount;
            //partner acc end
            
            
            ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
            cpIPA.Name='Intel Partner Alliance';
            cpIPA.PRM_programCode__c='IPA';
            insert cpIPA;
            
            ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
            cplTitanium.Name='Titanium';
            cplTitanium.ProgramId=cpIPA.Id;
            insert cplTitanium;
            
            
            PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
            acm.PRM_Account_Id__c=partnerAccount.Id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cpIPA.Id;
            acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
            acm.PRM_Partner_Role__c='Service Provider';
			acm.PRM_Status_Reason_Txt__c='Testing';
            insert acm;
            
            PMP_Company__c cmp1=new PMP_Company__c();
            cmp1.Name=intelAccount.Name;
            cmp1.PMP_Benefit_Update_Ind__c=False;
            cmp1.PMP_Partner_Inactive_Ind__c = False;
            cmp1.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
            cmp1.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile; //IPA2.0 - TWC729-7885
            cmp1.PMP_Is_Published_Ind__c=true;
            insert cmp1;
            
            Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
            coreAccnt.Core_Partner_Account_Id__c = partnerAccount.Id;
            coreAccnt.Core_Intel_Account_Id__c = intelAccount.Id; 
            insert coreAccnt;
            
            
            PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
            jun.PMP_One_Partner_ID__c= partnerAccount.Id;
            jun.PMP_Marketing_Profile_Id__c= cmp1.Id;
            jun.Is_Active__c=true;     
            insert jun;
            /*PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering','Public Content', 
                                                                                   'TestDuplicate',cmp1.Id, true,'Published','');*/
            
            
            System.assertNotEquals(PMP_NavigationBarAPIDetails.getNavBarDetails(poeUser.Email), null,'response cannot be empty');
            System.assertNotEquals(PMP_NavigationBarAPIDetails.getNavBarDetails(inteluser.Email), null,'response cannot be empty');
            System.assertNotEquals(PMP_NavigationBarAPIDetails.getNavBarDetails(Null), null,'response cannot be empty');
            System.assertNotEquals(PMP_NavigationBarAPIDetails.getNavBarDetails('TestEmail'), null,'response cannot be empty');
            
            
        }
        Test.stopTest();
    }
}