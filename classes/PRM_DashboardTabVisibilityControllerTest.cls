@isTest
public class PRM_DashboardTabVisibilityControllerTest{
    
    @testSetup  static void setup(){
        
        PRM_DashboardTabVisibilityController.responseWrapper rr=new PRM_DashboardTabVisibilityController.responseWrapper();
        List<PMP_Dashboard_Tab__mdt> dtList = new List<PMP_Dashboard_Tab__mdt>();
        PMP_Dashboard_Tab__mdt dt = new PMP_Dashboard_Tab__mdt();
        
        dt.DeveloperName = 'Account_Activity';
        dt.PRM_Profile_Txt__c = 'System Administrator,IT Admin';
        dt.PRM_Entitlement_Txt__c = 'Partner Admin Delegate,Partner Admin';
        dtList.add(dt);
        dtList.add(new PMP_Dashboard_Tab__mdt(DeveloperName='Offering_KeyMetric_Enhanced_Benefit',PRM_Entitlement_Txt__c='Employee,Lead Development Representative,Marketing Specialist,Partner Admin,Offering Editor',PMP_Benefit_Code_Txt__c='BFTMKTPLED',PMP_Permission_Set_Name_Txt__c ='PMP_Internal_Intel_Admin,PMP_Internal_Intel_Read_Only'));
        dtList.add(new PMP_Dashboard_Tab__mdt(DeveloperName='Offering_KeyMetric_Basic_Profile_Benefit',PRM_Entitlement_Txt__c='',PMP_Benefit_Code_Txt__c='BFTMKTPLBC',PMP_Permission_Set_Name_Txt__c ='PMP_Internal_Intel_Admin,PMP_Internal_Intel_Read_Only'));
        dtList.add(new PMP_Dashboard_Tab__mdt(Label='Partner Key Metric',DeveloperName='Partner_Key_Metric_Basic_Profile_Benefit',PRM_Entitlement_Txt__c='Employee,Lead Development Representative,Marketing Specialist,Partner Admin',PMP_Benefit_Code_Txt__c='BFTMKTPLBC',PMP_Permission_Set_Name_Txt__c ='PMP_Internal_Intel_Admin,PMP_Internal_Intel_Read_Only'));
        dtList.add(new PMP_Dashboard_Tab__mdt(Label='Partner Key Metric',DeveloperName='Partner_Key_Metric_Enhanced_Benefit',PRM_Entitlement_Txt__c='Employee,Lead Development Representative,Marketing Specialist,Offering Editor,Partner Admin',PMP_Benefit_Code_Txt__c='BFTMKTPLED',PMP_Permission_Set_Name_Txt__c ='PMP_Internal_Intel_Admin,PMP_Internal_Intel_Read_Only'));
        dtList.add(new PMP_Dashboard_Tab__mdt(Label='Lead',DeveloperName='Lead_Basic_Profile_Benefit',PRM_Entitlement_Txt__c='Employee,Lead Development Representative,Marketing Specialist,Partner Admin',PMP_Benefit_Code_Txt__c='BFTMKTPLBC',PMP_Permission_Set_Name_Txt__c ='PMP_Internal_Intel_Admin,PMP_Internal_Intel_Read_Only'));
        dtList.add(new PMP_Dashboard_Tab__mdt(Label='Lead',DeveloperName='Lead_Enhanced_Benefit',PRM_Entitlement_Txt__c='Employee,Lead Development Representative,Marketing Specialist,Partner Admin,Offering Editor',PMP_Benefit_Code_Txt__c='BFTMKTPLED',PMP_Permission_Set_Name_Txt__c ='PMP_Internal_Intel_Admin,PMP_Internal_Intel_Read_Only'));
        dtList.add(new PMP_Dashboard_Tab__mdt(DeveloperName='Offerings_OE_Enhanced_Benefit',PRM_Entitlement_Txt__c='Employee,Lead Development Representative,Marketing Specialist,Partner Admin',PMP_Benefit_Code_Txt__c='BFTMKTPLED',PMP_Permission_Set_Name_Txt__c ='PMP_Internal_Intel_Admin,PMP_Internal_Intel_Read_Only'));
        dtList.add(new PMP_Dashboard_Tab__mdt(DeveloperName='Offerings_OE_Basic_Profile_Benefit',PRM_Entitlement_Txt__c='',PMP_Benefit_Code_Txt__c='BFTMKTPLBC',PMP_Permission_Set_Name_Txt__c ='PMP_Internal_Intel_Admin,PMP_Internal_Intel_Read_Only'));
        dtList.add(new PMP_Dashboard_Tab__mdt(DeveloperName='Sales_Tab',PRM_Entitlement_Txt__c='Partner Admin,Partner Admin Delegate ',PRM_Partner_Role_Txt__c='FPGA Designer,Service Provider'));
        dtList.add(new PMP_Dashboard_Tab__mdt(DeveloperName='Training',PRM_Entitlement_Txt__c='Partner Admin,Employee',PRM_Partner_Role_Txt__c='FPGA Designer,Distributor'));
        dtList.add(new PMP_Dashboard_Tab__mdt(DeveloperName='Renewal',PRM_Entitlement_Txt__c='Partner Admin,Employee,Partner Admin Delegate',PRM_Partner_Role_Txt__c='Original Equipment Manufacturer (OEM);Builder;Solution Integrator',PMP_Benefit_Code_Txt__c='Partner;Prestige'));
        
        
        PMP_Dashboard_Tab__mdt metadata = [Select PRM_Entitlement_Txt__c, PMP_Permission_Set_Name_Txt__c from PMP_Dashboard_Tab__mdt where MasterLabel ='Lead' AND PMP_Benefit_Code_Txt__c='BFTMKTPLBC' AND PMP_Is_Active_Ind__c=True];          
        
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='A&E User'];
        Profile p = [Select Id from Profile Where name='IT Admin'];
        Profile partner = [Select Id from Profile Where name='Partner'];  
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
      	 Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.RecordTypeId = devRecordTypeId;
        testAccount.Name = 'Test PRMDashboard';       
        testAccount.Core_Account_Country__c='India';
        //testAccount.Core_Sales_Groups__c='Americas US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        testAccount.Core_User_Defined_Website__c='www.asdb.com';
        insert testAccount;
        
        Contact testContact = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',
                                          Email='testcontact'+String.valueOf(Math.random())+'@CorePRM.com',
                                          AccountId=testAccount.Id,Phone='123456498',MailingCountry='India',Core_IPA_PartnerRole__c='Distributor');
        insert testContact; 
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        
        
        prm_skip_trigger__c bm1 = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm1.Name='BatchFieldValues';
        bm1.inactive__c = false;
        insert bm1; 
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Partner University';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Account_Type_Nm__c = 'Both';
        insert pb;
        
            
        List<PRM_PartnerBenefit__c> pbList = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pbTest5 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest5.Name = 'Points Redemption';
        pbTest5.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pbTest5.PRM_Channel_Program_Id__c= cp.id;
        pbTest5.PRM_InActive_Ind__c = false;
        pbTest5.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest5);
        
        
        PRM_PartnerBenefit__c pbTest6 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest6.Name = 'Points Accruals View';
        pbTest6.PRM_Benefit_Cd__c = 'BFTPTSVIEW';
        pbTest6.PRM_Channel_Program_Id__c= cp.id;
        pbTest6.PRM_InActive_Ind__c = false;
        pbTest6.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest6);
        insert pbList;
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        insert cr2;
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name=System.Label.PRM_WorksFor;
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = true;
        cr1.PRM_Mandatory_Relationship_Ind__c = false;
        cr1.PRM_InActive_Ind__c = false;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        insert cr1;
        
        PRM_ContactRelationships__c cr3=new PRM_ContactRelationships__c();
        cr3.Name=System.Label.PRM_WorksFor;
        cr3.PRM_Contact_Relationship_Cd__c='PRIMCONTDEL';
        cr3.PRM_Default_Relationship_Ind__c = true;
        cr3.PRM_Mandatory_Relationship_Ind__c = false;
        cr3.PRM_InActive_Ind__c = false;
        cr3.PRM_Channel_Program_Id__c=cp.Id;
        insert cr3;
        
        
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=testContact.Id;
        acctContRel.PRM_Relationship_Id__c=cr2.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        //acctContRel.Core_User_Defined_Website__c='www.asdb.com';
         acctContRel.PRM_Status_Nm__c = 'Complete';
         acctContRel.PRM_Status_Reason_Txt__c = 'Reason';
        insert acctContRel;    
       
        List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Partner Admin';
        ed.Core_Display_Name__c='Partner Admin';
        
        //ed.Core_ERPM_Engagement_Id__c=ee.id;
        entList.add(ed);
        insert entList;
       
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
        ce.Core_Entitlement_Id__c=entList[0].Id ;
        ce.Core_Contact_Id__c =testContact.Id ;
        ce.Core_Status__c='Complete';
        ce.Core_Selected__c=true;
        insert ce;    
        
        List<PRM_Partner_Subscription__c> subsList =new List<PRM_Partner_Subscription__c>();
        PRM_Partner_Subscription__c sub1=new PRM_Partner_Subscription__c(Name ='Points Communications',PRM_Subscription_Cd__c='	POINTCOM',PRM_Subscription_Dsc__c='Points Communications');
        PRM_Partner_Subscription__c sub2=new PRM_Partner_Subscription__c(Name ='Product and Solution Communications',PRM_Subscription_Cd__c='PRDSOLCOM',PRM_Subscription_Dsc__c='Product and Solution Communications');
        PRM_Partner_Subscription__c sub3=new PRM_Partner_Subscription__c(Name ='Events Communications',PRM_Subscription_Cd__c='EVENTCOM',PRM_Subscription_Dsc__c='Events Communications');
        PRM_Partner_Subscription__c sub4=new PRM_Partner_Subscription__c(Name ='Membership Communications',PRM_Subscription_Cd__c='MEMBCOM',PRM_Subscription_Dsc__c='Membership Communications');
        PRM_Partner_Subscription__c sub5=new PRM_Partner_Subscription__c(Name ='Partner Research Communications',PRM_Subscription_Cd__c='PARRESCOM',PRM_Subscription_Dsc__c='Partner Research Communications');
        PRM_Partner_Subscription__c sub6=new PRM_Partner_Subscription__c(Name ='Training and Webinar Communications',PRM_Subscription_Cd__c='TRAWEBCOM',PRM_Subscription_Dsc__c='Training and Webinar Communications');
        subsList.add(sub1);
        subsList.add(sub2);
        subsList.add(sub3);
        subsList.add(sub4);
        subsList.add(sub5);
        subsList.add(sub6);
        insert subsList;
        
        list<account> accLst=new list<account>();
        Account testAccountOPID= new Account();
        testAccountOPID.RecordTypeId = recordTypeIdPagAccount;
        testAccountOPID.Name = 'Test Dashboard OPID';       
        testAccountOPID.Core_Account_Country__c='India';
        //testAccountOPID.Core_Sales_Groups__c='US Sales Group';
        testAccountOPID.Core_Account_Type__c='ODM opid';
        testAccountOPID.BillingStreet='Bangalore city';
        testAccountOPID.BillingCity='Bangalore';
        testAccountOPID.BillingCountry='IND';
        testAccountOPID.BillingState='KA';
        testAccountOPID.BillingPostalCode='568829';
        testAccountOPID.Industry='Agriculture';
		testAccountOPID.Core_User_Defined_Website__c='www.ab.com';
        accLst.add(testAccountOPID);
    
        
        Account testAccount1 = new Account();
        testAccount1.RecordTypeId = devRecordTypeId;
        testAccount1.Name = 'Test Dashboard2';       
        testAccount1.Core_Account_Country__c='India';
        //testAccount1.Core_Sales_Groups__c='US Sales Group';
        testAccount1.Core_Account_Type__c='ODM';
        testAccount1.BillingStreet='Bangalore Central';
        testAccount1.BillingCity='Bangalore';
        testAccount1.BillingCountry='IND';
        testAccount1.BillingState='KA';
        testAccount1.BillingPostalCode='560029';
        testAccount1.Industry='Agriculture';
	testAccount1.Core_User_Defined_Website__c='www.asdb.com';
        accLst.add(testAccount1);
        
         Account testAccount2 = new Account();
        testAccount2.RecordTypeId = devRecordTypeId;
        testAccount2.Name='John Wick';
        testAccount2.BillingCity='City';
        testAccount2.BillingStreet='Street';
        testAccount2.BillingCountry='India';
        testAccount2.BillingPostalCode='Postal code';
        testAccount2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount2.Industry='Construction';
        //testAccount2.OwnerId = UserInfo.getUserId();
	 testAccount2.Core_User_Defined_Website__c='www.asdb.com';
        accLst.add(testAccount2);
  		
        
       // test.startTest();
        insert accLst;
        
        Contact testContact1 = new Contact(Salutation = 'Mr',FirstName = 'Partnr',LastName='Contact',
                                           Email='testpartnrcontact'+String.valueOf(Math.random())+'@CorePRM.com',
                                           AccountId=testAccount1.Id,MailingCountry='India',Phone='123456498');
        insert testContact1;
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMPM.com',FirstName='TestUtility', Contact = testContact);
        insert testUser;
        User testUser1 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDM@intel.com',
                                  EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_US', ProfileId = p.Id,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDM.com',FirstName='TestUtility1', Contact = testContact1);
        insert testUser1;
        
        List<Contact> contList=new List<contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount2.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_IPA_PartnerRole__c='Distributor';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.MailingCountry='India';
        insert cont;        
       /* UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'Partner'];       
        User partnerUser = new User(UserRoleId = portalRole.Id,FirstName='MrTest',LastName='User',alias='t2user',Email='mrtestuser@mailinator.com',UserName='test2usr@xyz.com', ContactId=cont.Id,ProfileId=profile1.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);*/
        
    }
    
    @isTest static void Tabs_Test()
    {    
         Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.RecordTypeId = devRecordTypeId;
        testAccount.Name = 'Test PRMDashboard1';       
        testAccount.Core_Account_Country__c='India';
        //testAccount.Core_Sales_Groups__c='US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central Park';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='568029';
        testAccount.Industry='Agriculture';
        testAccount.Core_User_Defined_Website__c='www.asdb123.com';
        insert testAccount;
        
         Contact testContact = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',
                                          Email='testcontact'+String.valueOf(Math.random())+'@CorePRM.com',
                                          AccountId=testAccount.Id,Phone='123456498',MailingCountry='India',Core_IPA_PartnerRole__c='Distributor');
        insert testContact; 

		User user = [SELECT id,AccountId,firstName,Core_IPA_One_Partner_Id__c,ContactId from User where firstName='TestUtility'];
        
       /* UserRole portalRoleTest = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1Test = [Select Id from Profile where name = 'Partner'];       
         User user = new User(UserRoleId = portalRoleTest.Id,FirstName='MrTestTest',LastName='UserTest',alias='t2Test',Email='mrtusertest@mailinator.com',UserName='test2usrtest@xyz.com', ContactId=testContact.Id,
                              emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London',ProfileId=profile1Test.Id);//, UserRoleId = r.id);*/
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
            ee.Name = 'Intel Partner Alliance';
            ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
            ee.Core_Engagement_Type__c = 'SEC';
            insert ee;

            List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
            Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
            ed.Name='Partner Admin Delegate';
            ed.Core_Display_Name__c='Partner Admin Del';
            ed.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed);

 		Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
        ce.Core_Entitlement_Id__c=entList[0].Id ;
        ce.Core_Contact_Id__c =testContact.Id ;
        ce.Core_Status__c='Complete';
        ce.Core_Selected__c=true;
        insert ce;    

 		PRM_PartnerBenefit__c PB1 = [select Id, Name, PRM_Benefit_Cd__c, PRM_Channel_Program_Id__c  from PRM_PartnerBenefit__c where PRM_InActive_Ind__c=false AND PRM_Benefit_Cd__c='BFTPTSVIEW' ];

		PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba.PRM_Account_Id__c = testAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = PB1.id;
        aba.PRM_Status_Nm__c ='Active';
        aba.PRM_Status_Reason_Txt__c='aba01';
        PRM_aba_TriggerHandler.executeTrigger = false;
        insert aba;
        PRM_aba_TriggerHandler.executeTrigger = true;
        system.runAs(user)
        {                       
            Test.startTest();
            PermissionSet ps = [SELECT id ,Name from PermissionSet where Name ='PRM_Internal_Intel_Admin'];            
            PermissionSetAssignment perm = new PermissionSetAssignment();
            perm.AssigneeId = user.Id;
            perm.PermissionSetId = ps.Id;
            insert perm;
			
			PRM_DashboardTabVisibilityController.isTrainingUser();
            PRM_DashboardTabVisibilityController.isAccountActivity();
            PRM_DashboardTabVisibilityController.isSalesUser();
            //sandhya PRM_DashboardTabVisibilityController.isPartner();
            //sandhya PRM_DashboardTabVisibilityController.isPartnerKeyMetric();
            //sandhya PRM_DashboardTabVisibilityController.isOfferingsOE();
            //sandhya PRM_DashboardTabVisibilityController.isOfferingKeyMetric();
            PRM_DashboardTabVisibilityController.isLead();
            PRM_DashboardTabVisibilityController.isPartnerKeyMetricExt();
            //PRM_DashboardTabVisibilityController.showPointsTab();
            PRM_DashboardTabVisibilityController.checkRelation();
           
            PRM_DashboardTabVisibilityController.responseWrapper rr=PRM_DashboardTabVisibilityController.getResponse();
            String tabname = 'Account Activity';
            PRM_DashboardTabVisibilityController.checkTabVisibility(tabName);
            PRM_DashboardTabVisibilityController.metadataCheck(tabName);
            Test.stopTest();
        }
        System.assertEquals('TestUtility',user.firstName,'User name should match');
    }
    
    @isTest static void showPointsTabTest() {
        
        UserRole portalRole = new UserRole(DeveloperName ='MyCustomRole',Name = 'My Role',PortalType='None');
        insert portalRole;
        ChannelProgram chprg = [Select Id,name,PRM_programCode__c from ChannelProgram where name='Intel Partner Alliance' Limit 1];
        PRM_ContactRelationships__c crel=[Select id,name,PRM_Contact_Relationship_Cd__c,PRM_Default_Relationship_Ind__c,PRM_Mandatory_Relationship_Ind__c,
                                          PRM_InActive_Ind__c,PRM_Channel_Program_Id__c from PRM_ContactRelationships__c where PRM_Contact_Relationship_Cd__c='WORKSFOR'];
        PRM_PartnerBenefit__c PB1 = [select Id, Name, PRM_Benefit_Cd__c, PRM_Channel_Program_Id__c  from PRM_PartnerBenefit__c where PRM_InActive_Ind__c=false AND PRM_Benefit_Cd__c='BFTPTSVIEW' ];
        PRM_PartnerBenefit__c PB2 = [select Id, Name, PRM_Benefit_Cd__c, PRM_Channel_Program_Id__c  from PRM_PartnerBenefit__c where PRM_InActive_Ind__c=false AND PRM_Benefit_Cd__c='BFTPTSREDM' ];
        //system.debug('crel'+crel);
        Profile portalProfile = [SELECT Id,Name FROM Profile WHERE Name ='Partner' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test@test.com',
            Alias = 'batman1',
            Email='bruce1.wayne1@intel.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce11',
            Lastname='Wayne11',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago');        
        insert portalAccountOwner1;
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account parent1 = new Account();
        Account accObj1 = new Account();
        Account accObj2 = new Account();
        Contact conObj1 = new Contact();
        Contact conObj2 = new Contact();
        User user1 =null;
        
        System.runAs(portalAccountOwner1){
            parent1.RecordTypeId = opidAccRecordTypeId;
            parent1.Name='Cello Ltd';
            parent1.BillingCity='New City';
            parent1.BillingStreet='New Street';
            parent1.BillingCountry='India';
            parent1.BillingPostalCode='999999';
            //parent1.Core_Account_Type__c = 'Original Equipment Manufacturer (OEM)';
            parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
            parent1.Industry='Construction';  
            Test.startTest();
            insert parent1;
            accObj1.RecordTypeId = devRecordTypeId;
            accObj1.Name='test';
            accObj1.BillingStreet='1417 R Street';
            accObj1.BillingCity='Apple Valley';
            accObj1.BillingCountry='USA';    
            accObj1.BillingState='MN';
            accObj1.OwnerId=portalAccountOwner1.Id;
            accObj1.BillingPostalCode='55124';
          	accObj1.Core_IPA_One_Partner_Id__c =parent1.Id;
            accObj1.Core_User_Defined_Website__c = 'test.com';
            insert accObj1;   
            
            conObj1.FirstName = 'TestPartner';
            conObj1.LastName = 'Michel John';
            conObj1.AccountId = accObj1.Id;
            conObj1.Core_IPA_PartnerRole__c='Distributor';
            conObj1.Email = 'test123456@intel.com';
            conObj1.MailingCountry='India';
            
            
            insert conObj1;
            //system.debug('Conid'+conObj1.Id);
            //system.debug('con obj'+conObj1);
            
        
            
            user1 = new User(
                Username = System.now().millisecond() + 'test123451@test.com',               
                ContactId = conObj1.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test123456@intel.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'MP_Solutions'+Date.today().day()+Datetime.now().second(),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US');
            
            insert user1; 
            //system.debug('user1id'+user1.ContactId);
            
            
            Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
            ee.Name = 'Intel Partner Alliance';
            ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
            ee.Core_Engagement_Type__c = 'SEC';
            insert ee;
            List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
            Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
            ed.Name='Partner Admin Delegate';
            ed.Core_Display_Name__c='Partner Admin Del';
            ed.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed);
            Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
            ed1.Name='Employee';
            ed1.Core_Display_Name__c='Employee';
            ed1.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed1);
            insert entList;
            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
            ce.Core_Entitlement_Id__c=entList[0].Id ;
            ce.Core_Contact_Id__c =conObj1.Id ;
            ce.Core_Status__c='complete';
            ce.Core_Selected__c = true;
            ce.Core_Source__c = 'Entitlement';
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
            ce1.Core_Entitlement_Id__c=entList[1].Id ;
            ce1.Core_Contact_Id__c =conObj1.Id ;
            ce1.Core_Status__c='complete';
            ce1.Core_Selected__c = true;
            ce1.Core_Source__c = 'Entitlement';
            
            insert ce;
            insert ce1;
            
            PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
            acctContRel.PRM_Account_Id__c=accObj1.Id;
            acctContRel.PRM_Contact_Id__c=conObj1.Id;
            acctContRel.PRM_Relationship_Id__c=crel.Id;
            acctContRel.PRM_InActive_Ind__c=false;
            acctContRel.PRM_Status_Nm__c = 'Complete';
            acctContRel.PRM_execute_trigger__c=true;
            acctContRel.PRM_Status_Reason_Txt__c = 'Reason';
            insert acctContRel;  
            //system.debug('acr con'+acctContRel.PRM_Contact_Id__c);
            //system.debug('acr'+acctContRel);
        	
        
		prm_skip_trigger__c bm = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm.Name='ABA_Trigger';
   		bm.inactive__c = false;
        insert bm;
            
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba.PRM_Account_Id__c = accObj1.Id;
        aba.PRM_Partner_Benefit_Id__c = PB1.id;
        aba.PRM_Status_Nm__c ='Active';
        aba.PRM_Status_Reason_Txt__c='aba02';
        PRM_aba_TriggerHandler.executeTrigger = false;
        insert aba;
        PRM_aba_TriggerHandler.executeTrigger = true;
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba1.PRM_Account_Id__c = parent1.Id;
        aba1.PRM_Partner_Benefit_Id__c = PB2.id;
        aba1.PRM_Status_Nm__c ='Active';
        aba1.PRM_Status_Reason_Txt__c='aba032';
        PRM_aba_TriggerHandler.executeTrigger = false;
        insert aba1;
        PRM_aba_TriggerHandler.executeTrigger = true;
        
        PRM_AccountBenefitAssociation__c aba2 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba2.PRM_Account_Id__c = accObj2.Id;
        aba2.PRM_Partner_Benefit_Id__c = PB1.id;
        aba2.PRM_Status_Reason_Txt__c='ab02';
        aba2.PRM_Status_Nm__c ='Active';
        PRM_aba_TriggerHandler.executeTrigger = false;
        insert aba2;
        PRM_aba_TriggerHandler.executeTrigger = true;

        
        PRM_Points_Data__c pd1 = new PRM_Points_Data__c();
        pd1.PRM_Account_Id__c = accObj1.Id;
        pd1.Name = 'Test1';   
        pd1.DQ_Flag__c=true;
        insert pd1;
       pd1.DQ_Flag__c=false;
        update pd1; 
        
        PRM_Points_Data__c pd2 = new PRM_Points_Data__c();
        pd2.PRM_Account_Id__c = accObj2.Id;
        pd2.Name = 'Test2';
        pd2.DQ_Flag__c=false;
        insert pd2;
    }
           
           
        system.runAs(user1) {
            //PRM_DashboardTabVisibilityController.isTrainingUser();
            //PRM_DashboardTabVisibilityController.isAccountActivity();
            //PRM_DashboardTabVisibilityController.isSalesUser();
            //PRM_DashboardTabVisibilityController.isPartner();
            //PRM_DashboardTabVisibilityController.isPartnerKeyMetric();
            //PRM_DashboardTabVisibilityController.isOfferingsOE();
            //PRM_DashboardTabVisibilityController.isOfferingKeyMetric();
            //PRM_DashboardTabVisibilityController.isLead();
            PRM_DashboardTabVisibilityController.showPointsTab();  
            //PRM_DashboardTabVisibilityController.checkRelation();
            //PRM_DashboardTabVisibilityController.profileCheck();
            //PRM_DashboardTabVisibilityController.getResponse();
            Test.stopTest();
            
        }
        
        System.assertEquals('Partner',portalProfile.Name,'User Should be assigned with Partner profile');
        
        
    }
    
	@isTest
	 static void showPointsTabTest1() {
        
        UserRole portalRole = new UserRole(DeveloperName ='MyCustomRole',Name = 'My Role',PortalType='None');
        insert portalRole;
        ChannelProgram chprg = [Select Id,name,PRM_programCode__c from ChannelProgram where name='Intel Partner Alliance' Limit 1];
        PRM_ContactRelationships__c crel=[Select id,name,PRM_Contact_Relationship_Cd__c,PRM_Default_Relationship_Ind__c,PRM_Mandatory_Relationship_Ind__c,
                                          PRM_InActive_Ind__c,PRM_Channel_Program_Id__c from PRM_ContactRelationships__c where PRM_Contact_Relationship_Cd__c='WORKSFOR'];
        PRM_PartnerBenefit__c PB1 = [select Id, Name, PRM_Benefit_Cd__c, PRM_Channel_Program_Id__c  from PRM_PartnerBenefit__c where PRM_InActive_Ind__c=false AND PRM_Benefit_Cd__c='BFTPTSVIEW' ];
       PRM_PartnerBenefit__c PB2 = [select Id, Name, PRM_Benefit_Cd__c, PRM_Channel_Program_Id__c  from PRM_PartnerBenefit__c where PRM_InActive_Ind__c=false AND PRM_Benefit_Cd__c='BFTPTSREDM' ];  
        
        //system.debug('crel'+crel);
        Profile portalProfile = [SELECT Id,Name FROM Profile WHERE Name ='Partner' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test@test345.com',
            Alias = 'batman1',
            Email='bruce1.wayne11S@intel.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce11',
            Lastname='Wayne11',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago');        
        insert portalAccountOwner1;
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account parent1 = new Account();
        Account accObj1 = new Account();
        Account accObj2 = new Account();
        Contact conObj1 = new Contact();
        Contact conObj2 = new Contact();
        User user1 =null;
        
        System.runAs(portalAccountOwner1){
            parent1.RecordTypeId = opidAccRecordTypeId;
            parent1.Name='Cello Ltd';
            parent1.BillingCity='New City';
            parent1.BillingStreet='New Street';
            parent1.BillingCountry='India';
            parent1.BillingPostalCode='999999';
            //parent1.Core_Account_Type__c = 'Original Equipment Manufacturer (OEM)';
            parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
            parent1.Industry='Construction';  
            Test.startTest();
            insert parent1;
            accObj1.RecordTypeId = devRecordTypeId;
            accObj1.Name='test';
            accObj1.BillingStreet='1417 R Street';
            accObj1.BillingCity='Apple Valley';
            accObj1.BillingCountry='USA';    
            accObj1.BillingState='MN';
            accObj1.OwnerId=portalAccountOwner1.Id;
            accObj1.BillingPostalCode='55124';
          accObj1.Core_IPA_One_Partner_Id__c =parent1.Id;
            accObj1.Core_User_Defined_Website__c = 'test.com';
            insert accObj1;   
            
            conObj1.FirstName = 'TestPartner';
            conObj1.LastName = 'Michel John';
            conObj1.AccountId = accObj1.Id;
            conObj1.Core_IPA_PartnerRole__c='Distributor';
            conObj1.Email = 'test123456@intel.com';
            conObj1.MailingCountry='India';
            insert conObj1;
            //system.debug('Conid'+conObj1.Id);
            //system.debug('con obj'+conObj1);
            
        
            
            user1 = new User(
                Username = System.now().millisecond() + 'test123451@test.com',               
                ContactId = conObj1.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test123456@intel.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'MP_Solutions'+Date.today().day()+Datetime.now().second(),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US');
            
            insert user1; 
            //system.debug('user1id'+user1.ContactId);
            
            
            Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
            ee.Name = 'Intel Partner Alliance';
            ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
            ee.Core_Engagement_Type__c = 'SEC';
            insert ee;
            List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
            Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
            ed.Name='Partner Admin Delegate';
            ed.Core_Display_Name__c='Partner Admin Del';
            ed.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed);
            
           
           Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
            ed1.Name='Employee';
            ed1.Core_Display_Name__c='Employee';
            ed1.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed1);
            insert entList;
            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
            ce.Core_Entitlement_Id__c=entList[0].Id ;
            ce.Core_Contact_Id__c =conObj1.Id ;
            ce.Core_Status__c='complete';
            ce.Core_Selected__c = true;
            ce.Core_Source__c = 'Entitlement';
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
            ce1.Core_Entitlement_Id__c=entList[1].Id ;
            ce1.Core_Contact_Id__c =conObj1.Id ;
            ce1.Core_Status__c='complete';
            ce1.Core_Selected__c = true;
            ce1.Core_Source__c = 'Entitlement';
            
            insert ce;
            insert ce1;
            
            PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
            acctContRel.PRM_Account_Id__c=accObj1.Id;
            acctContRel.PRM_Contact_Id__c=conObj1.Id;
            acctContRel.PRM_Relationship_Id__c=crel.Id;
            acctContRel.PRM_InActive_Ind__c=false;
            acctContRel.PRM_Status_Nm__c = 'Complete';
            acctContRel.PRM_execute_trigger__c=true;
            acctContRel.PRM_Status_Reason_Txt__c='Reason';
            insert acctContRel;  
            //system.debug('acr con'+acctContRel.PRM_Contact_Id__c);
            //system.debug('acr'+acctContRel);
        	
        
		prm_skip_trigger__c bm = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm.Name='ABA_Trigger';
   		bm.inactive__c = false;
        insert bm;
            
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba.PRM_Account_Id__c = accObj1.Id;
        aba.PRM_Partner_Benefit_Id__c = PB1.id;
        aba.PRM_Status_Nm__c ='Active';
        aba.PRM_Status_Reason_Txt__c='aba003';
        PRM_aba_TriggerHandler.executeTrigger = false;
        insert aba;
        PRM_aba_TriggerHandler.executeTrigger = true;
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba1.PRM_Account_Id__c = parent1.Id;
        aba1.PRM_Partner_Benefit_Id__c = PB2.id;
        aba1.PRM_Status_Nm__c ='Active';
        aba1.PRM_Status_Reason_Txt__c='aba202';
        PRM_aba_TriggerHandler.executeTrigger = false;
        insert aba1;
        PRM_aba_TriggerHandler.executeTrigger = true;
        
        PRM_AccountBenefitAssociation__c aba2 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba2.PRM_Account_Id__c = accObj2.Id;
        aba2.PRM_Partner_Benefit_Id__c = PB1.id;
        aba2.PRM_Status_Nm__c ='Active';
        aba2.PRM_Status_Reason_Txt__c='aba0022';
        PRM_aba_TriggerHandler.executeTrigger = false;
        insert aba2;
        PRM_aba_TriggerHandler.executeTrigger = true;

        
        PRM_Points_Data__c pd1 = new PRM_Points_Data__c();
        pd1.PRM_Account_Id__c = accObj1.Id;
        pd1.Name = 'Test1';   
        pd1.DQ_Flag__c=true;
        insert pd1;
                     
        PRM_Points_Data__c pd2 = new PRM_Points_Data__c();
        pd2.PRM_Account_Id__c = accObj2.Id;
        pd2.Name = 'Test2';
        pd2.DQ_Flag__c=false;
        insert pd2;
    }
            
        system.runAs(user1) {
            PRM_DashboardTabVisibilityController.showPointsTab();  
            Test.stopTest();
            
            
        }
        
        System.assertEquals('Partner',portalProfile.Name,'User Should be assigned with Partner profile');
        
        
    }
    
    
   @isTest static void showPointsTabTest2() {
        
        UserRole portalRole = new UserRole(DeveloperName ='MyCustomRole',Name = 'My Role',PortalType='None');
        insert portalRole;
        ChannelProgram chprg = [Select Id,name,PRM_programCode__c from ChannelProgram where name='Intel Partner Alliance' Limit 1];
        PRM_ContactRelationships__c crel=[Select id,name,PRM_Contact_Relationship_Cd__c,PRM_Default_Relationship_Ind__c,PRM_Mandatory_Relationship_Ind__c,
                                          PRM_InActive_Ind__c,PRM_Channel_Program_Id__c from PRM_ContactRelationships__c where PRM_Contact_Relationship_Cd__c='WORKSFOR'];
        PRM_PartnerBenefit__c PB1 = [select Id, Name, PRM_Benefit_Cd__c, PRM_Channel_Program_Id__c  from PRM_PartnerBenefit__c where PRM_InActive_Ind__c=false AND PRM_Benefit_Cd__c='BFTPTSREDM' ];
        //PRM_PartnerBenefit__c PB2 = [select Id, Name, PRM_Benefit_Cd__c, PRM_Channel_Program_Id__c  from PRM_PartnerBenefit__c where PRM_InActive_Ind__c=false AND PRM_Benefit_Cd__c='BFTPTSREDM' ];
        //system.debug('crel'+crel);
        Profile portalProfile = [SELECT Id,Name FROM Profile WHERE Name ='Partner' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2avch@test.com',
            Alias = 'batman1',
            Email='bruce1.wayne1@intel.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce11',
            Lastname='Wayne11',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago');        
        insert portalAccountOwner1;
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account parent1 = new Account();
        Account accObj1 = new Account();
        Account accObj2 = new Account();
        Contact conObj1 = new Contact();
        Contact conObj2 = new Contact();
        User user1 =null;
        
        System.runAs(portalAccountOwner1){
            parent1.RecordTypeId = opidAccRecordTypeId;
            parent1.Name='Cello Ltd';
            parent1.BillingCity='New City';
            parent1.BillingStreet='New Street';
            parent1.BillingCountry='India';
            parent1.BillingPostalCode='999999';
            //parent1.Core_Account_Type__c = 'Original Equipment Manufacturer (OEM)';
            parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
            parent1.Industry='Construction';  
            Test.startTest();
            insert parent1;
            accObj1.RecordTypeId = devRecordTypeId;
            accObj1.Name='test';
            accObj1.BillingStreet='1417 R Street';
            accObj1.BillingCity='Apple Valley';
            accObj1.BillingCountry='USA';    
            accObj1.BillingState='MN';
            accObj1.OwnerId=portalAccountOwner1.Id;
            accObj1.BillingPostalCode='55124';
          accObj1.Core_IPA_One_Partner_Id__c =parent1.Id;
            accObj1.Core_User_Defined_Website__c = 'test.com';
            insert accObj1;   
            
            conObj1.FirstName = 'TestPartner';
            conObj1.LastName = 'Michel John';
            conObj1.AccountId = accObj1.Id;
            conObj1.Core_IPA_PartnerRole__c='Distributor';
            conObj1.Email = 'test123456bc@intel.com';
            conObj1.MailingCountry='India';
            insert conObj1;
            //system.debug('Conid'+conObj1.Id);
            //system.debug('con obj'+conObj1);
            
        
            
            user1 = new User(
                Username = System.now().millisecond() + 'test123451nc@test.com',               
                ContactId = conObj1.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test123456@intel.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'MP_Solutions'+Date.today().day()+Datetime.now().second(),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US');
            
            insert user1; 
            //system.debug('user1id'+user1.ContactId);
            
            
            Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
            ee.Name = 'Intel Partner Alliance';
            ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
            ee.Core_Engagement_Type__c = 'SEC';
            insert ee;
            List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
            Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
            ed.Name='Partner Admin Delegate';
            ed.Core_Display_Name__c='Partner Admin Del';
            ed.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed);
            Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
            ed1.Name='Employee';
            ed1.Core_Display_Name__c='Employee';
            ed1.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed1);
            insert entList;
            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
            ce.Core_Entitlement_Id__c=entList[0].Id ;
            ce.Core_Contact_Id__c =conObj1.Id ;
            ce.Core_Status__c='complete';
            ce.Core_Selected__c = true;
            ce.Core_Source__c = 'Entitlement';
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
            ce1.Core_Entitlement_Id__c=entList[1].Id ;
            ce1.Core_Contact_Id__c =conObj1.Id ;
            ce1.Core_Status__c='complete';
            ce1.Core_Selected__c = true;
            ce1.Core_Source__c = 'Entitlement';
            
            insert ce;
            insert ce1;
            
            PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
            acctContRel.PRM_Account_Id__c=accObj1.Id;
            acctContRel.PRM_Contact_Id__c=conObj1.Id;
            acctContRel.PRM_Relationship_Id__c=crel.Id;
            acctContRel.PRM_InActive_Ind__c=false;
            acctContRel.PRM_Status_Nm__c = 'Complete';
            acctContRel.PRM_execute_trigger__c=true;
            acctContRel.PRM_Status_Reason_Txt__c='Reason';
            insert acctContRel;  
            ////system.debug('acr con'+acctContRel.PRM_Contact_Id__c);
            //system.debug('acr'+acctContRel);
        	
        
		prm_skip_trigger__c bm = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm.Name='ABA_Trigger';
   		bm.inactive__c = false;
        insert bm;
            
            PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
            aba.PRM_Account_Id__c = accObj1.Id;
            aba.PRM_Partner_Benefit_Id__c = PB1.id;
            aba.PRM_Status_Nm__c ='Active';
            aba.PRM_Status_Reason_Txt__c='aba004';
            PRM_aba_TriggerHandler.executeTrigger = false;
            insert aba;
            PRM_aba_TriggerHandler.executeTrigger = true;
            
            PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
            aba1.PRM_Account_Id__c = parent1.Id;
            aba1.PRM_Partner_Benefit_Id__c = PB1.id;
            aba1.PRM_Status_Nm__c ='Active';
            aba1.PRM_Status_Reason_Txt__c='aba102';
            PRM_aba_TriggerHandler.executeTrigger = false;
            insert aba1;
            PRM_aba_TriggerHandler.executeTrigger = true;
            
            PRM_AccountBenefitAssociation__c aba2 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
            aba2.PRM_Account_Id__c = accObj1.Id;
            aba2.PRM_Partner_Benefit_Id__c = PB1.id;
            aba2.PRM_Status_Nm__c ='Active';
            aba2.PRM_Status_Reason_Txt__c='aba1202';
            PRM_aba_TriggerHandler.executeTrigger = false;
            insert aba2;
            PRM_aba_TriggerHandler.executeTrigger = true;
            
            
            PRM_Points_Data__c pd1 = new PRM_Points_Data__c();
            pd1.PRM_Account_Id__c = accObj1.Id;
            pd1.Name = 'Test1';   
            pd1.DQ_Flag__c=true;
            insert pd1;
            
          
            PRM_Points_Data__c pd2 = new PRM_Points_Data__c();
            pd2.PRM_Account_Id__c = accObj2.Id;
            pd2.Name = 'Test2';
            pd2.DQ_Flag__c=true;
            insert pd2;
           
        }
        
        system.runAs(user1) {
            PRM_DashboardTabVisibilityController.showPointsTab();  
            Test.stopTest();
            
        }
        
        System.assertEquals('Partner',portalProfile.Name,'User Should be assigned with Partner profile');
        
        
    }
     
     @isTest static void showPointsTabTest3() {
        
        UserRole portalRole = new UserRole(DeveloperName ='MyCustomRole',Name = 'My Role',PortalType='None');
        insert portalRole;
        ChannelProgram chprg = [Select Id,name,PRM_programCode__c from ChannelProgram where name='Intel Partner Alliance' Limit 1];
        PRM_ContactRelationships__c crel=[Select id,name,PRM_Contact_Relationship_Cd__c,PRM_Default_Relationship_Ind__c,PRM_Mandatory_Relationship_Ind__c,
                                          PRM_InActive_Ind__c,PRM_Channel_Program_Id__c from PRM_ContactRelationships__c where PRM_Contact_Relationship_Cd__c='WORKSFOR'];
        PRM_PartnerBenefit__c PB1 = [select Id, Name, PRM_Benefit_Cd__c, PRM_Channel_Program_Id__c  from PRM_PartnerBenefit__c where PRM_InActive_Ind__c=false AND PRM_Benefit_Cd__c='BFTPTSVIEW' ];
        //system.debug('crel'+crel);
        Profile portalProfile = [SELECT Id,Name FROM Profile WHERE Name ='Partner' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2avch@test.com',
            Alias = 'batman1',
            Email='bruce1.wayne1@intel.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce11',
            Lastname='Wayne11',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago');        
        insert portalAccountOwner1;
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account accObj1 = new Account();
        Account accObj2 = new Account();
        Contact conObj1 = new Contact();
        Contact conObj2 = new Contact();
        User user1 =null;
        
        System.runAs(portalAccountOwner1){
            
            Test.startTest();
            accObj1.RecordTypeId = devRecordTypeId;
            accObj1.Name='test';
            accObj1.BillingStreet='1417 R Street';
            accObj1.BillingCity='Apple Valley';
            accObj1.BillingCountry='USA';    
            accObj1.BillingState='MN';
            accObj1.OwnerId=portalAccountOwner1.Id;
            accObj1.BillingPostalCode='55124';
            insert accObj1;   
            
            conObj1.FirstName = 'TestPartner';
            conObj1.LastName = 'Michel John';
            conObj1.AccountId = accObj1.Id;
            conObj1.Email = 'test123456bc@intel.com';
            conObj1.MailingCountry='India';
            
            
            insert conObj1;
            //system.debug('Conid'+conObj1.Id);
            //system.debug('con obj'+conObj1);
            
        
            
            user1 = new User(
                Username = System.now().millisecond() + 'test123451nc@test.com',               
                ContactId = conObj1.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test123456@intel.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'MP_Solutions'+Date.today().day()+Datetime.now().second(),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US');
            
            insert user1; 
            //system.debug('user1id'+user1.ContactId);
            
            
            Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
            ee.Name = 'Intel Partner Alliance';
            ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
            ee.Core_Engagement_Type__c = 'SEC';
            insert ee;
            List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
            Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
            ed.Name='Partner Admin Delegate';
            ed.Core_Display_Name__c='Partner Admin Del';
            ed.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed);
            Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
            ed1.Name='Employee';
            ed1.Core_Display_Name__c='Employee';
            ed1.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed1);
            insert entList;
            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
            ce.Core_Entitlement_Id__c=entList[0].Id ;
            ce.Core_Contact_Id__c =conObj1.Id ;
            ce.Core_Status__c='complete';
            ce.Core_Selected__c = true;
            ce.Core_Source__c = 'Entitlement';
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
            ce1.Core_Entitlement_Id__c=entList[1].Id ;
            ce1.Core_Contact_Id__c =conObj1.Id ;
            ce1.Core_Status__c='complete';
            ce1.Core_Selected__c = true;
            ce1.Core_Source__c = 'Entitlement';
            
            insert ce;
            insert ce1;
            
            PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
            acctContRel.PRM_Account_Id__c=accObj1.Id;
            acctContRel.PRM_Contact_Id__c=conObj1.Id;
            acctContRel.PRM_Relationship_Id__c=crel.Id;
            acctContRel.PRM_InActive_Ind__c=false;
            acctContRel.PRM_Status_Nm__c = 'Complete';
            acctContRel.PRM_execute_trigger__c=true;
            acctContRel.PRM_Status_Reason_Txt__c ='Reason';
            insert acctContRel;  
            ////system.debug('acr con'+acctContRel.PRM_Contact_Id__c);
            //system.debug('acr'+acctContRel);
        	
		prm_skip_trigger__c bm = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm.Name='ABA_Trigger';
   		bm.inactive__c = false;
        insert bm;
            
            PRM_AccountBenefitAssociation__c aba2 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
            aba2.PRM_Account_Id__c = accObj1.Id;
            aba2.PRM_Partner_Benefit_Id__c = PB1.id;
            aba2.PRM_Status_Nm__c ='Active';
            aba2.PRM_Status_Reason_Txt__c='aba004';
            PRM_aba_TriggerHandler.executeTrigger = false;
            insert aba2;
            PRM_aba_TriggerHandler.executeTrigger = true;
            
            PRM_Points_Data__c pd1 = new PRM_Points_Data__c();
            pd1.PRM_Account_Id__c = accObj1.Id;
            pd1.Name = 'Test1';   
            pd1.DQ_Flag__c=true;
            insert pd1;
          
            PRM_Points_Data__c pd2 = new PRM_Points_Data__c();
            pd2.PRM_Account_Id__c = accObj2.Id;
            pd2.Name = 'Test2';
            pd2.DQ_Flag__c=true;
            insert pd2;
        }
        system.runAs(user1) {
            PRM_DashboardTabVisibilityController.showPointsTab();  
            Test.stopTest();
        }
        System.assertEquals('Partner',portalProfile.Name,'User Should be assigned with Partner profile');
    }
     
 
    
    @isTest static void Tabs1_Test() {
        
                
        User user = [SELECT id,firstName from User where FirstName='TestUtility1'];
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =:Label.PRM_Internal_Intel_Admin];
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = user.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        user.Email = 'TestUtility1@example.com';
        update user;
        
        PMP_Dashboard_Tab__mdt metadata = [Select PRM_Entitlement_Txt__c, PMP_Permission_Set_Name_Txt__c from PMP_Dashboard_Tab__mdt where MasterLabel ='Lead' AND PMP_Benefit_Code_Txt__c='BFTMKTPLBC' AND PMP_Is_Active_Ind__c=True];
        PRM_DashboardTabVisibilityController.benefitCode.add('BFTMKTPLBC');
        
        String tabname1 = 'Lead';
        PRM_DashboardTabVisibilityController.metadataCheck(tabName1);
        
        //system.debug('***metadata***'+metadata);
        System.runAs(user){
            Test.startTest();
            PRM_DashboardTabVisibilityController.profileCheck();
            PRM_DashboardTabVisibilityController.isCheckAgreementDetails();
            PRM_DashboardTabVisibilityController.isTrainingUser();
            PRM_DashboardTabVisibilityController.isAccountActivity();
            PRM_DashboardTabVisibilityController.isSalesUser();
           //sandhya  PRM_DashboardTabVisibilityController.isPartner();
            //sandhya PRM_DashboardTabVisibilityController.isPartnerKeyMetric();
           //sandhya PRM_DashboardTabVisibilityController.isOfferingsOE();
            //sandhya PRM_DashboardTabVisibilityController.isOfferingKeyMetric();
            PRM_DashboardTabVisibilityController.isLead();
            PRM_DashboardTabVisibilityController.isPartnerKeyMetricExt();
            PRM_DashboardTabVisibilityController.showPointsTab();
            PRM_DashboardTabVisibilityController.checkRelation();
            PRM_DashboardTabVisibilityController.getResponse();
            
            
            String tabname = 'Account Activity';
            PRM_DashboardTabVisibilityController.checkTabVisibility(tabName);
            PRM_DashboardTabVisibilityController.metadataCheck(tabName);
            
            
            Test.stopTest();
            System.assertEquals('TestUtility1',user.firstName,'User name should match');
        } 
    }
    @isTest static void testWithPortalUser() {        
        //Create portal account owner
        UserRole portalRole = new UserRole(DeveloperName ='MyCustomRole',Name = 'My Role',PortalType='None');
        insert portalRole;
        Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        ChannelProgram chprg = [Select Id,name,PRM_programCode__c from ChannelProgram where name='Intel Partner Alliance' Limit 1];
        PRM_ContactRelationships__c crel=[Select id,name,PRM_Contact_Relationship_Cd__c,PRM_Default_Relationship_Ind__c,PRM_Mandatory_Relationship_Ind__c,
                                          PRM_InActive_Ind__c,PRM_Channel_Program_Id__c from PRM_ContactRelationships__c where PRM_Contact_Relationship_Cd__c='WORKSFOR'];
        
        PRM_PartnerBenefit__c PB = [select Id, Name, PRM_Benefit_Cd__c, PRM_Channel_Program_Id__c  from PRM_PartnerBenefit__c where PRM_InActive_Ind__c=false AND PRM_Benefit_Cd__c='BFTPTSVIEW' ];
        //system.debug('crel'+crel);
        Profile portalProfile = [SELECT Id,Name FROM Profile WHERE Name ='Partner' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'testabc2@test.com',
            Alias = 'batman',
            Email='bruce.wayne1@intel.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce1',
            Lastname='Wayne1',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago');
        insert portalAccountOwner1;       
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account parent1 = new Account();
        Account accObj1 = new Account();
        Account accObj2 = new Account();
        Contact conObj1 = new Contact();
        User user1 =null;
        
        System.runAs(portalAccountOwner1)
        {
             
        parent1.RecordTypeId = opidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        //parent1.Core_Account_Type__c = 'Original Equipment Manufacturer (OEM)';
        parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        parent1.Industry='Construction';   
        insert parent1;
            accObj1.RecordTypeId = devRecordTypeId;
            accObj1.Name='test';
            accObj1.BillingStreet='1417 R Street';
            accObj1.BillingCity='Apple Valley';
            accObj1.BillingCountry='USA';    
            accObj1.BillingState='MN';
            accObj1.OwnerId=portalAccountOwner1.Id;
            accObj1.BillingPostalCode='55124';
            accObj1.Core_IPA_One_Partner_Id__c =parent1.Id;
	    accObj1.Core_User_Defined_Website__c = 'test.com';
            insert accObj1;   
            
            accObj2.RecordTypeId = devRecordTypeId;
            accObj2.Name='test2';
            accObj2.BillingStreet='1418 R Street';
            accObj2.BillingCity='Apple Valley';
            accObj2.BillingCountry='USA';    
            accObj2.BillingState='MN';
            accObj2.BillingPostalCode='55123';
            accObj2.Core_User_Defined_Website__c = 'test.com';
            insert accObj2; 
            
            
            conObj1.FirstName = 'TestPartner';
            conObj1.LastName = 'Michel John';
            conObj1.AccountId = accObj2.Id;
            conObj1.Core_IPA_PartnerRole__c='Distributor';
            conObj1.Email = 'test123456@intel.com';
            conObj1.MailingCountry='India';
            
            Test.startTest();
            insert conObj1;
            /*//system.debug('Conid'+conObj1.Id);
            //system.debug('con obj'+conObj1);
            PRM_ContactRelationships__c crcode = new PRM_ContactRelationships__c();
            crcode.PRM_Contact_Relationship_Cd__c = 'PRIMCONTDEL';*/
            //insert crcode;
            
            Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
            ee.Name = 'Intel Partner Alliance';
            ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
            ee.Core_Engagement_Type__c = 'SEC';
            insert ee;
            List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
            Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
            ed.Name='Partner Admin Delegate';
            ed.Core_Display_Name__c='Partner Admin Del';
            ed.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed);
            Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
            ed1.Name='Employee';
            ed1.Core_Display_Name__c='Employee';
            ed1.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed1);
           
             
            insert entList;
            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
            ce.Core_Entitlement_Id__c=entList[0].Id ;
            ce.Core_Contact_Id__c =conObj1.Id ;
            ce.Core_Status__c='complete';
            ce.Core_Selected__c = true;
            ce.Core_Source__c = 'Entitlement';
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
            ce1.Core_Entitlement_Id__c=entList[1].Id ;
            ce1.Core_Contact_Id__c =conObj1.Id ;
            ce1.Core_Status__c='complete';
            ce1.Core_Selected__c = true;
            ce1.Core_Source__c = 'Entitlement';
            
            insert ce;
            insert ce1;
            
            
            //Create user
        prm_skip_trigger__c bm1 = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm1.Name='ABA_Trigger';
   		bm1.inactive__c = false;
        insert bm1; 
            
        PRM_AccountBenefitAssociation__c aba2 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba2.PRM_Account_Id__c = accObj2.Id;
        aba2.PRM_Partner_Benefit_Id__c = PB.id;
        aba2.PRM_Status_Nm__c ='Active';
        aba2.PRM_Status_Reason_Txt__c='aba005';
        PRM_aba_TriggerHandler.executeTrigger = false;
        insert aba2;
        PRM_aba_TriggerHandler.executeTrigger = true;
            
            user1 = new User(
                Username = System.now().millisecond() + 'test123451@test.com',               
                ContactId = conObj1.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test123456@intel.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'MP_Solutions'+Date.today().day()+Datetime.now().second(),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US');
            
            insert user1; 
            //system.debug('user1id'+user1.ContactId);
            PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
            acctContRel.PRM_Account_Id__c=accObj2.Id;
            acctContRel.PRM_Contact_Id__c=conObj1.Id;
            acctContRel.PRM_Relationship_Id__c=crel.Id;
            acctContRel.PRM_InActive_Ind__c=false;
            acctContRel.PRM_Status_Nm__c = 'Complete';
            acctContRel.PRM_execute_trigger__c=true;
            acctContRel.PRM_Status_Reason_Txt__c='Reason';
            insert acctContRel;  
            //system.debug('acr con'+acctContRel.PRM_Contact_Id__c);
            //system.debug('acr'+acctContRel);
            
            ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
            cplTest.Name='Partner';
            cplTest.ProgramId=chprg.Id;
            insert cplTest;
        
            
            PRM_AccountChannelMembership__c acctChnlMemTest=PRM_TestUtility.getMembership(); //Account Channel Membership
            acctChnlMemTest.PRM_Account_Id__c=accObj1.Id;
            acctChnlMemTest.PRM_Channel_Program_Id__c=chprg.Id;
            acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
            acctChnlMemTest.PRM_Partner_Role__c='Distributor';
            acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
            acctChnlMemTest.PRM_Status_Reason_Txt__c = 'Test class';
            insert acctChnlMemTest;
            
            PRM_Value_Exchange_Data__c vxData = new PRM_Value_Exchange_Data__c();
        vxData.PRM_Sales_Amount_Report_Nbr__c = 12000;
        vxData.PRM_Training_Credit_Points_Report_Nbr__c = 20000;
        vxData.PRM_Account_Id__c = accObj1.id;
        vxData.PRM_One_Partner_Id__c = parent1.id;
        vxData.PRM_Change_Date_Dt__c = System.today();
        vxData.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData.PRM_From_Dt__c = Date.Today().addYears(-3);
        vxData.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData.PRM_Tier_Id__c = cplTest.Id;
        vxData.PRM_To_Dt__c = Date.Today().addYears(-2);
        vxData.PRM_Sales_Calculation_Group_Txt__c = 'Component';
        vxData.PRM_Training_Credit_Points_Count_Nbr__c = 100;
        vxData.PRM_Sales_Amount_Nbr__c=10000;
        insert vxData;
                
        }      
        system.runAs(user1) {
            PRM_DashboardTabVisibilityController.isTrainingUser();
            PRM_DashboardTabVisibilityController.isAccountActivity();
            PRM_DashboardTabVisibilityController.isSalesUser();
            //sandhya PRM_DashboardTabVisibilityController.isPartner();
            //sandhya PRM_DashboardTabVisibilityController.isPartnerKeyMetric();
           //sandhya PRM_DashboardTabVisibilityController.isOfferingsOE();
           //sandhya PRM_DashboardTabVisibilityController.isOfferingKeyMetric();
            PRM_DashboardTabVisibilityController.isLead();
            //PRM_DashboardTabVisibilityController.showPointsTab();  
            PRM_DashboardTabVisibilityController.checkRelation();
            PRM_DashboardTabVisibilityController.profileCheck();
            Test.stopTest();
            
            PRM_DashboardTabVisibilityController.isPartnerKeyMetricExt();
           String tabname = 'Account Activity';
            PRM_DashboardTabVisibilityController.checkTabVisibility(tabName);
            PRM_DashboardTabVisibilityController.metadataCheck(tabName);

        }
        
        System.assertEquals('Partner',portalProfile.Name,'User Should be assigned with Partner profile');
        
    }
    
    
    @isTest public static void wrapperTest(){
        PRM_DashboardResponseWrapper wrap = new PRM_DashboardResponseWrapper();
        wrap.link = '';
        wrap.userType = 'Employee';
        wrap.LoggedInuserType = 'External';
        wrap.legalAgreementCheck = false;
        wrap.showManagePartnerBtn = false;
        wrap.showManageStorefrontBtn = true;
        wrap.partnerKeyMetricExtLink = '';
        wrap.link = '/ipa/s/post-launch-non-primary';
        wrap.tabAccess.put('tab',true);
                
        PRM_DashboardResponseWrapper wrap2 = new PRM_DashboardResponseWrapper();
        wrap2.userType = 'Partner';
        wrap2.LoggedInuserType = 'Internal';
        wrap2.legalAgreementCheck = false;
        wrap2.link = '/ipa/s/post-launch-primary';
        wrap2.showManagePartnerBtn = true;
        wrap2.showManageStorefrontBtn = false;
        wrap2.tabAccess.put('tab',false);    
        
        
       // System.assertEquals('Employee',resWrap.userType,'Match');
         System.assertEquals('Partner',wrap2.userType,'Match');
    }
    
    @isTest public static void test4() {
        
        boolean flag;
        boolean metaFlag;
        Set<Id> accId = new Set<Id>();
        Set<Id> userContactId = new Set<Id>();
        String tabname = 'Account Activity';
        Set<String> entitlements = new Set<String>();
        Set<String> benefitCode = new Set<String>();
        user u = [select id,FirstName, AccountId,Email, contactId, Core_IPA_One_Partner_Id__c from user where email='testUsercoreMDM@intel.com' limit 1];
        PMP_Dashboard_Tab__mdt mdt = new PMP_Dashboard_Tab__mdt();
                
        List<PMP_Dashboard_Tab__mdt> metaData = [Select PRM_Entitlement_Txt__c, MasterLabel, PMP_Benefit_Code_Txt__c, PMP_Permission_Set_Name_Txt__c from PMP_Dashboard_Tab__mdt where MasterLabel =:tabName AND PMP_Is_Active_Ind__c=True];         
        
        Test.startTest();
        accId = PRM_DashboardTabVisibilityController.accIds;
        entitlements = PRM_DashboardTabVisibilityController.contactEntitlements;
        userContactId= PRM_DashboardTabVisibilityController.loggedInUserContactId; 
        PRM_DashboardTabVisibilityController.checkTabVisibility(tabName);
        PRM_DashboardTabVisibilityController.metadataCheck(tabName);
        Test.stopTest();
        System.assertEquals('TestUtility1',u.FirstName,'Match');
        
    }
    
    //@isTest 
    // public static void showRenewalTabCheckTest(){
    //     Test.startTest();
    //     List<PMP_Dashboard_Tab__mdt> dtList = new List<PMP_Dashboard_Tab__mdt>();
    //     PMP_Dashboard_Tab__mdt dt = new PMP_Dashboard_Tab__mdt();
    //     dt.DeveloperName = 'Account_Activity';
    //     dt.PRM_Profile_Txt__c = 'System Administrator,IT Admin';
    //     dt.PRM_Entitlement_Txt__c = 'Partner Admin Delegate,Partner Admin';
    //     dt.PMP_Benefit_Code_Txt__c= 'Partner;Prestige';
    //     dtList.add(dt);
    //     dtList.add(new PMP_Dashboard_Tab__mdt(DeveloperName='Renewal',PRM_Entitlement_Txt__c='Partner Admin,Employee,Partner Admin Delegate',PRM_Partner_Role_Txt__c='Original Equipment Manufacturer (OEM);Builder;Solution Integrator',PMP_Benefit_Code_Txt__c='Partner;Prestige'));
        
    //     Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        
    //     Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
    //     Account parent1 = new Account();
    //     parent1.RecordTypeId = opidAccRecordTypeId;
    //     parent1.Name='Cello Ltdq123';
    //     parent1.BillingCity='New City';
    //     parent1.BillingStreet='New Street';
    //     parent1.BillingCountry='India';
    //     parent1.BillingPostalCode='999992';
    //     parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
    //     parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
    //     parent1.Industry='Construction';
    //     parent1.Core_User_Defined_Website__c='www.abc.com';
    //     Parent1.Core_Geo__c='ASMO';
    //     insert parent1;
        
    //     Account testAccount = new Account();
    //     testAccount.RecordTypeId = recordTypeIdAccount;
    //     testAccount.Name='John WickTest 123';
    //     testAccount.BillingCity='City';
    //     testAccount.BillingStreet='Street';
    //     testAccount.BillingCountry='India';
    //     testAccount.BillingPostalCode='123214';
    //     testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
    //     testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
    //     testAccount.Industry='Construction';
    //     testAccount.OwnerId = UserInfo.getUserId();
    //     testAccount.Core_User_Defined_Website__c = 'www.abc.com';
    //     testAccount.Core_IPA_One_Partner_Id__c=parent1.id;
    //     testAccount.Core_Geo__c = 'ASMO';
    //     insert testAccount;
        
    //     Contact cont = new Contact();  //Contact
    //     cont.AccountId=testAccount.Id;
    //     cont.lastName='GrillTest';
    //     cont.FirstName='Adam';
    //     cont.email='AdamGrill@rediff123.com';
    //     cont.Core_Job_Function__c='Branch Manager';
    //     cont.Core_IPA_PartnerRole__c='Distributor';
    //     cont.Core_eRPM_Language_Code__c='Eng';
    //     cont.MailingCountry='India';
    //     insert cont;
    //       /*  Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
    //         ee.Name = 'Intel Partner Alliance';
    //         ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
    //         ee.Core_Engagement_Type__c = 'SEC';
    //         insert ee;
    //         List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
    //         Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
    //         ed.Name='Partner Admin Delegate';
    //         ed.Core_Display_Name__c='Partner Admin Del';
    //         ed.Core_ERPM_Engagement_Id__c=ee.id;
    //         entList.add(ed);
    //         Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
    //         ed1.Name='Employee';
    //         ed1.Core_Display_Name__c='Employee';
    //         ed1.Core_ERPM_Engagement_Id__c=ee.id;
    //         entList.add(ed1);
           
             
    //         insert entList;
            
    //         Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
    //         ce.Core_Entitlement_Id__c=entList[0].Id ;
    //         ce.Core_Contact_Id__c =cont.Id ;
    //         ce.Core_Status__c='complete';
    //         ce.Core_Selected__c = true;
    //         ce.Core_Source__c = 'Entitlement';
    //         Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
    //         ce1.Core_Entitlement_Id__c=entList[1].Id ;
    //         ce1.Core_Contact_Id__c =cont.Id ;
    //         ce1.Core_Status__c='complete';
    //         ce1.Core_Selected__c = true;
    //         ce1.Core_Source__c = 'Entitlement';
            
    //         insert ce;
    //         insert ce1;*/
        
    //     Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        
    //     User partnerUser = new User(FirstName='MrTest123',LastName='User',alias='t2user',Email='mrtestuser12@mailinator.com',
    //                                 UserName='test2usr23@xyz.com', ContactId=cont.Id,ProfileId=communityUsrProfile.Id,
    //                                 emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);
        
    //     insert partnerUser;
    //     Id userId=partnerUser.Id;
        
    //     ChannelProgram chprg = [Select Id,name,PRM_programCode__c from ChannelProgram where name='Intel Partner Alliance' Limit 1];
        
    //     ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
    //     cplTest.Name='Partner'; //Update
    //     cplTest.ProgramId=chprg.Id;
    //     insert cplTest;
    //     //added old tier record for test coverage
	// 	ChannelProgramLevel cplTest1 = new ChannelProgramLevel(); //Channel Program Level
    //     cplTest1.Name='Gold'; //Update
    //     cplTest1.ProgramId=chprg.Id;
    //     insert cplTest1;
        
    //     list<PRM_AccountChannelMembership__c> acmLst=new list<PRM_AccountChannelMembership__c>();
    //     PRM_AccountChannelMembership__c acctChnlMemTest=PRM_TestUtility.getMembership(); //Account Channel Membership
    //     acctChnlMemTest.PRM_Account_Id__c=testAccount.Id;
    //     acctChnlMemTest.PRM_Channel_Program_Id__c=chprg.Id;
    //     acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
    //     acctChnlMemTest.PRM_Partner_Role__c='Distributor';
    //     acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
    //     acctChnlMemTest.PRM_Status_Reason_Txt__c = 'Test class';
    //     acmLst.add(acctChnlMemTest);
                
    //     PRM_AccountChannelMembership__c acctChnlMemTest1=PRM_TestUtility.getMembership(); //Account Channel Membership
    //     acctChnlMemTest1.PRM_Account_Id__c=testAccount.Id;
    //     acctChnlMemTest1.PRM_Channel_Program_Id__c=chprg.Id;
    //     acctChnlMemTest1.PRM_Channel_Program_Level_Id__c=cplTest1.Id;
    //     acctChnlMemTest1.PRM_Partner_Role__c='Solution Integrator';
    //     acctChnlMemTest1.PRM_Status_Nm__c = 'Approved';
    //     acctChnlMemTest1.PRM_Status_Reason_Txt__c = 'Test class';
    //     acmLst.add(acctChnlMemTest1);
    //     insert acmLst;
        
    //     PRM_ValueExchange__c vx7 = new PRM_ValueExchange__c();
    //     vx7.Name = 'Gold-Manufacturer-NA';
    //     vx7.PRM_Channel_Program_Level_Id__c =  cplTest.Id;
    //     vx7.PRM_Country_Market_Type_Nm__c = 'NA';
    //     vx7.PRM_Partner_Role_Nm__c = 'Distributor';
    //     vx7.PRM_Renewal_Content__c='abc';
    //     vx7.PRM_Dynamic_Content_Visibility__c='xyz';
    //     vx7.PRM_Program_Id__c = chprg.Id;
    //     vx7.PRM_Start_Date_Dt__c = System.today();
    //     insert vx7;
        
    //     PRM_ContactRelationships__c crel=[Select id,name,PRM_Contact_Relationship_Cd__c,PRM_Default_Relationship_Ind__c,PRM_Mandatory_Relationship_Ind__c,
    //                                       PRM_InActive_Ind__c,PRM_Channel_Program_Id__c from PRM_ContactRelationships__c where PRM_Contact_Relationship_Cd__c='WORKSFOR'];
        
    //     PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
    //     acctContRel.PRM_Account_Id__c=testAccount.Id;
    //     acctContRel.PRM_Contact_Id__c=cont.Id;
    //     acctContRel.PRM_Relationship_Id__c=crel.Id;
    //     acctContRel.PRM_Status_Nm__c='Complete';
    //     acctContRel.PRM_InActive_Ind__c=false;
    //     acctContRel.PRM_Status_Reason_Txt__c ='Reason';
    //     PRM_AcctContRel_TriggerHandler.executeTrigger = false;
    //     insert acctContRel;
    //     PRM_AcctContRel_TriggerHandler.executeTrigger = true;
        
        
        
    //    /* Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
    //     ed.Name='Employee';
    //     ed.Core_Display_Name__c='Employee';
    //     insert ed;
    //     Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
    //     ce.Core_Entitlement_Id__c=ed.Id ;
    //     ce.Core_Contact_Id__c =cont.Id ;
    //     ce.Core_Status__c='Complete';
    //     ce.Core_Selected__c=true;
    //     insert ce;*/
          
       
    //     list<PRM_Value_Exchange_Data__c> vxDataLst=new list<PRM_Value_Exchange_Data__c>();
    //     PRM_Value_Exchange_Data__c vxData = new PRM_Value_Exchange_Data__c();
    //     vxData.PRM_Sales_Amount_Report_Nbr__c = 12000;
    //     vxData.PRM_Training_Credit_Points_Report_Nbr__c = 20000;
    //     vxData.PRM_Account_Id__c = testAccount.id;
    //     vxData.PRM_One_Partner_Id__c = parent1.id;
    //     vxData.PRM_Change_Date_Dt__c = System.today();
    //     vxData.PRM_Country_Market_Type_Nm__c = 'Emerging';
    //     vxData.PRM_From_Dt__c = Date.Today().addYears(-3);
    //     vxData.PRM_Partner_Role_Nm__c = 'Distributor';
    //     vxData.PRM_Tier_Id__c = cplTest.Id;
    //     vxData.PRM_To_Dt__c = Date.Today().addYears(-2);
    //     vxData.PRM_Sales_Calculation_Group_Txt__c = 'Component';
    //     vxData.PRM_Training_Credit_Points_Count_Nbr__c = 100;
    //    // vxData.PRM_TimePeriod_Nm__c='Q4 2019 - Q3 2020';
    //     vxData.PRM_Sales_Amount_Nbr__c=10000;
    //     vxDataLst.add(vxData);
               
    //     PRM_Value_Exchange_Data__c vxData1 = new PRM_Value_Exchange_Data__c();
    //     vxData1.PRM_Sales_Amount_Report_Nbr__c = 12000;
    //     vxData1.PRM_Training_Credit_Points_Report_Nbr__c = 20000;
    //     vxData1.PRM_Account_Id__c = testAccount.id;
    //     vxData1.PRM_One_Partner_Id__c = parent1.id;
    //     vxData1.PRM_Change_Date_Dt__c = System.today();
    //     vxData1.PRM_Country_Market_Type_Nm__c = 'Mature';
    //     vxData1.PRM_From_Dt__c = Date.Today().addYears(-3);
    //     vxData1.PRM_Partner_Role_Nm__c = 'Distributor';
    //     vxData1.PRM_Tier_Id__c = cplTest1.Id;
    //     vxData1.PRM_To_Dt__c = Date.Today().addYears(-2);
    //     vxData1.PRM_Sales_Calculation_Group_Txt__c = 'Component';
    //     vxData1.PRM_Training_Credit_Points_Count_Nbr__c = 100;
    //    // vxData.PRM_TimePeriod_Nm__c='Q4 2019 - Q3 2020';
    //     vxData1.PRM_Sales_Amount_Nbr__c=10000;
    //     vxDataLst.add(vxData1);
        
    //     insert vxDataLst;
        
    //    /* Core_Account_Group_Member__c cag2 = new Core_Account_Group_Member__c();
    //     cag2.Core_Intel_Account_Id__c = testAccount.Id;
    //     cag2.Core_Partner_Account_Id__c = parent1.id;
    //     cag2.Core_Inactive_Ind__c=false;
	// 	 insert cag2; */
        
    //     Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
    //         ee.Name = 'Intel Partner Alliance';
    //         ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
    //         ee.Core_Engagement_Type__c = 'SEC';
    //         insert ee;
    //         List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
    //         Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
    //         ed.Name='Partner Admin Delegate';
    //         ed.Core_Display_Name__c='Partner Admin Del';
    //         ed.Core_ERPM_Engagement_Id__c=ee.id;
    //         entList.add(ed);
    //         Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
    //         ed1.Name='Employee';
    //         ed1.Core_Display_Name__c='Employee';
    //         ed1.Core_ERPM_Engagement_Id__c=ee.id;
    //         entList.add(ed1);
        
        
    //         insert entList;
            
    //         Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
    //         ce.Core_Entitlement_Id__c=entList[0].Id ;
    //         ce.Core_Contact_Id__c =cont.Id ;
    //         ce.Core_Status__c='complete';
    //         ce.Core_Selected__c = true;
    //         ce.Core_Source__c = 'Entitlement';
    //         Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
    //         ce1.Core_Entitlement_Id__c=entList[1].Id ;
    //         ce1.Core_Contact_Id__c =cont.Id ;
    //         ce1.Core_Status__c='complete';
    //         ce1.Core_Selected__c = true;
    //         ce1.Core_Source__c = 'Entitlement';
            
    //         insert ce;
    //         insert ce1;

       
    //     system.runAs(partnerUser){
    //     PRM_DashboardTabVisibilityController.showRenewalTabCheck();
    //     PRM_DashboardTabVisibilityController.getRenewalContent();
    //     }
    //     Test.stopTest();
            
    // }
    
    
    // @isTest 
    // public static void showRenewalTabCheckTest1(){
        
    //     List<PMP_Dashboard_Tab__mdt> dtList = new List<PMP_Dashboard_Tab__mdt>();
    //     PMP_Dashboard_Tab__mdt dt = new PMP_Dashboard_Tab__mdt();
    //     dt.DeveloperName = 'Account_Activity';
    //     dt.PRM_Profile_Txt__c = 'System Administrator,IT Admin';
    //     dt.PRM_Entitlement_Txt__c = 'Partner Admin Delegate,Partner Admin';
    //     dtList.add(dt);
    //     dtList.add(new PMP_Dashboard_Tab__mdt(DeveloperName='Renewal',PRM_Entitlement_Txt__c='Partner Admin,Employee,Partner Admin Delegate',PRM_Partner_Role_Txt__c='Original Equipment Manufacturer (OEM);Distributor;Solution Integrator',PMP_Benefit_Code_Txt__c='Partner;Prestige'));
        
    //     Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        
    //     Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
    //     Account parent1 = new Account();
    //     parent1.RecordTypeId = opidAccRecordTypeId;
    //     parent1.Name='Cello Ltdq123';
    //     parent1.BillingCity='New City';
    //     parent1.BillingStreet='New Street';
    //     parent1.BillingCountry='India';
    //     parent1.BillingPostalCode='999992';
    //     parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
    //     parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
    //     parent1.Industry='Construction';
    //     parent1.Core_User_Defined_Website__c='www.abc.com';
    //     Parent1.Core_Geo__c='ASMO';
    //     insert parent1;
        
    //     Account testAccount = new Account();
    //     testAccount.RecordTypeId = recordTypeIdAccount;
    //     testAccount.Name='John WickTest 123';
    //     testAccount.BillingCity='City';
    //     testAccount.BillingStreet='Street';
    //     testAccount.BillingCountry='India';
    //     testAccount.BillingPostalCode='123214';
    //     testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
    //     testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
    //     testAccount.Industry='Construction';
    //     testAccount.OwnerId = UserInfo.getUserId();
    //     testAccount.Core_User_Defined_Website__c = 'www.abc.com';
    //     testAccount.Core_IPA_One_Partner_Id__c=parent1.id;
    //     testAccount.Core_Geo__c = 'ASMO';
    //     insert testAccount;
    //     Core_Account_Group_member__c cag = new Core_Account_Group_Member__c();
    //     cag.Core_Partner_Account_Id__c = parent1.id;
    //     cag.Core_Intel_Account_Id__c = testAccount.id;
    //     insert cag;
        
    //     Contact cont = new Contact();  //Contact
    //     cont.AccountId=testAccount.Id;
    //     cont.lastName='GrillTest';
    //     cont.FirstName='Adam';
    //     cont.email='AdamGrill@rediff123.com';
    //     cont.Core_Job_Function__c='Branch Manager';
    //     cont.Core_IPA_PartnerRole__c='Distributor';
    //     cont.Core_eRPM_Language_Code__c='Eng';
    //     cont.MailingCountry='India';
    //     insert cont;
    //       /*  Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
    //         ee.Name = 'Intel Partner Alliance';
    //         ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
    //         ee.Core_Engagement_Type__c = 'SEC';
    //         insert ee;
    //         List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
    //         Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
    //         ed.Name='Partner Admin Delegate';
    //         ed.Core_Display_Name__c='Partner Admin Del';
    //         ed.Core_ERPM_Engagement_Id__c=ee.id;
    //         entList.add(ed);
    //         Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
    //         ed1.Name='Employee';
    //         ed1.Core_Display_Name__c='Employee';
    //         ed1.Core_ERPM_Engagement_Id__c=ee.id;
    //         entList.add(ed1);
           
             
    //         insert entList;
            
    //         Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
    //         ce.Core_Entitlement_Id__c=entList[0].Id ;
    //         ce.Core_Contact_Id__c =cont.Id ;
    //         ce.Core_Status__c='complete';
    //         ce.Core_Selected__c = true;
    //         ce.Core_Source__c = 'Entitlement';
    //         Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
    //         ce1.Core_Entitlement_Id__c=entList[1].Id ;
    //         ce1.Core_Contact_Id__c =cont.Id ;
    //         ce1.Core_Status__c='complete';
    //         ce1.Core_Selected__c = true;
    //         ce1.Core_Source__c = 'Entitlement';
            
    //         insert ce;
    //         insert ce1;*/
        
    //     Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        
    //     User partnerUser = new User(FirstName='MrTest123',LastName='User',alias='t2user',Email='mrtestuser12@mailinator.com',
    //                                 UserName='test2usr23@xyz.com', ContactId=cont.Id,ProfileId=communityUsrProfile.Id,
    //                                 emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);
        
    //     insert partnerUser;
    //     Id userId=partnerUser.Id;
        
    //     ChannelProgram chprg = [Select Id,name,PRM_programCode__c from ChannelProgram where name='Intel Partner Alliance' Limit 1];
        
    //     ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
    //     cplTest.Name='Prestige';
    //     cplTest.ProgramId=chprg.Id;
    //     insert cplTest;
    //     //added old tier record for test coverage
	// 	ChannelProgramLevel cplTest1 = new ChannelProgramLevel(); //Channel Program Level
    //     cplTest1.Name='Gold'; //Update
    //     cplTest1.ProgramId=chprg.Id;
    //     insert cplTest1;
        
    //     list<PRM_AccountChannelMembership__c> acmLst=new list<PRM_AccountChannelMembership__c>();
    //     PRM_AccountChannelMembership__c acctChnlMemTest=PRM_TestUtility.getMembership(); //Account Channel Membership
    //     acctChnlMemTest.PRM_Account_Id__c=testAccount.Id;
    //     acctChnlMemTest.PRM_Channel_Program_Id__c=chprg.Id;
    //     acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
    //     acctChnlMemTest.PRM_Partner_Role__c='Distributor';
    //     acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
    //     acctChnlMemTest.PRM_Status_Reason_Txt__c = 'Test class';
    //     acmLst.add(acctChnlMemTest);
                
    //    PRM_AccountChannelMembership__c acctChnlMemTest1=PRM_TestUtility.getMembership(); //Account Channel Membership
    //     acctChnlMemTest1.PRM_Account_Id__c=testAccount.Id;
    //     acctChnlMemTest1.PRM_Channel_Program_Id__c=chprg.Id;
    //     acctChnlMemTest1.PRM_Channel_Program_Level_Id__c=cplTest1.Id;
    //     acctChnlMemTest1.PRM_Partner_Role__c='Solution Integrator';
    //     acctChnlMemTest1.PRM_Status_Nm__c = 'Approved';
    //     acctChnlMemTest1.PRM_Status_Reason_Txt__c = 'Test class';
    //     acmLst.add(acctChnlMemTest1);
    //     insert acmLst;
        
    //     string renewalcombo='Gold-Manufacturer-NA';
        
    //     PRM_ValueExchange__c vx7 = new PRM_ValueExchange__c();
    //     vx7.Name = renewalcombo;
    //     vx7.PRM_Channel_Program_Level_Id__c =  cplTest.Id;
    //     vx7.PRM_Country_Market_Type_Nm__c = 'NA';
    //     vx7.PRM_Partner_Role_Nm__c = 'Distributor';
    //     vx7.PRM_Renewal_Content__c='abc';
    //     vx7.PRM_Dynamic_Content_Visibility__c='xyz';
    //     vx7.PRM_Program_Id__c = chprg.Id;
    //     vx7.PRM_Start_Date_Dt__c = System.today();
    //     insert vx7;
        
    //     PRM_ContactRelationships__c crel=[Select id,name,PRM_Contact_Relationship_Cd__c,PRM_Default_Relationship_Ind__c,PRM_Mandatory_Relationship_Ind__c,
    //                                       PRM_InActive_Ind__c,PRM_Channel_Program_Id__c from PRM_ContactRelationships__c where PRM_Contact_Relationship_Cd__c='WORKSFOR'];
        
    //     PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
    //     acctContRel.PRM_Account_Id__c=testAccount.Id;
    //     acctContRel.PRM_Contact_Id__c=cont.Id;
    //     acctContRel.PRM_Relationship_Id__c=crel.Id;
    //     acctContRel.PRM_Status_Nm__c='Complete';
    //     acctContRel.PRM_InActive_Ind__c=false;
    //     acctContRel.PRM_Status_Reason_Txt__c ='Reason';
    //     PRM_AcctContRel_TriggerHandler.executeTrigger = false;
    //     insert acctContRel;
    //     PRM_AcctContRel_TriggerHandler.executeTrigger = true;
        
        
        
    //   /*  Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
    //     ed.Name='Employee';
    //     ed.Core_Display_Name__c='Employee';
    //     insert ed;
    //     Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
    //     ce.Core_Entitlement_Id__c=ed.Id ;
    //     ce.Core_Contact_Id__c =cont.Id ;
    //     ce.Core_Status__c='Complete';
    //     ce.Core_Selected__c=true;
    //     insert ce;*/
          
       
    //     list<PRM_Value_Exchange_Data__c> vxDataLst=new list<PRM_Value_Exchange_Data__c>();
    //     PRM_Value_Exchange_Data__c vxData = new PRM_Value_Exchange_Data__c();
    //     vxData.PRM_Sales_Amount_Report_Nbr__c = 12000;
    //     vxData.PRM_Training_Credit_Points_Report_Nbr__c = 20000;
    //     vxData.PRM_Account_Id__c = testAccount.id;
    //     vxData.PRM_One_Partner_Id__c = parent1.id;
    //     vxData.PRM_Change_Date_Dt__c = System.today();
    //     vxData.PRM_Country_Market_Type_Nm__c = 'Emerging';
    //     vxData.PRM_From_Dt__c = Date.Today().addYears(-3);
    //     vxData.PRM_Partner_Role_Nm__c = 'Distributor';
    //     vxData.PRM_Tier_Id__c = cplTest.Id;
    //     vxData.PRM_To_Dt__c = Date.Today().addYears(-2);
    //     vxData.PRM_Sales_Calculation_Group_Txt__c = 'Component';
    //     vxData.PRM_Training_Credit_Points_Count_Nbr__c = 100;
    //    // vxData.PRM_TimePeriod_Nm__c='Q4 2019 - Q3 2020';
    //     vxData.PRM_Sales_Amount_Nbr__c=10000;
    //     vxDataLst.add(vxData);
               
    //     PRM_Value_Exchange_Data__c vxData1 = new PRM_Value_Exchange_Data__c();
    //     vxData1.PRM_Sales_Amount_Report_Nbr__c = 12000;
    //     vxData1.PRM_Training_Credit_Points_Report_Nbr__c = 20000;
    //     vxData1.PRM_Account_Id__c = testAccount.id;
    //     vxData1.PRM_One_Partner_Id__c = parent1.id;
    //     vxData1.PRM_Change_Date_Dt__c = System.today();
    //     vxData1.PRM_Country_Market_Type_Nm__c = 'Mature';
    //     vxData1.PRM_From_Dt__c = Date.Today().addYears(-3);
    //     vxData1.PRM_Partner_Role_Nm__c = 'Distributor';
    //     vxData1.PRM_Tier_Id__c = cplTest1.Id;
    //     vxData1.PRM_To_Dt__c = Date.Today().addYears(-2);
    //     vxData1.PRM_Sales_Calculation_Group_Txt__c = 'Component';
    //     vxData1.PRM_Training_Credit_Points_Count_Nbr__c = 100;
    //    // vxData.PRM_TimePeriod_Nm__c='Q4 2019 - Q3 2020';
    //     vxData1.PRM_Sales_Amount_Nbr__c=10000;
    //     vxDataLst.add(vxData1);

    //     Test.startTest();
    //     insert vxDataLst;
        
    //    /* Core_Account_Group_Member__c cag2 = new Core_Account_Group_Member__c();
    //     cag2.Core_Intel_Account_Id__c = testAccount.Id;
    //     cag2.Core_Partner_Account_Id__c = parent1.id;
    //     cag2.Core_Inactive_Ind__c=false;
	// 	 insert cag2; */
        
        
        
      
    //     system.runAs(partnerUser){
    //     PRM_DashboardTabVisibilityController.showRenewalTabCheck();
    //     PRM_DashboardTabVisibilityController.getRenewalContent();
    //     }
    //     Test.stopTest();
            
    // }
    @isTest
    public static void isTandCAccepted(){
       boolean isTandC=false;
         List<PMP_Dashboard_Tab__mdt> dtList = new List<PMP_Dashboard_Tab__mdt>();
        PMP_Dashboard_Tab__mdt dt = new PMP_Dashboard_Tab__mdt();
        dt.DeveloperName = 'Account_Activity';
        dt.PRM_Profile_Txt__c = 'System Administrator,IT Admin';
        dt.PRM_Entitlement_Txt__c = 'Partner Admin Delegate,Partner Admin';
        dtList.add(dt);
        dtList.add(new PMP_Dashboard_Tab__mdt(DeveloperName='Renewal',PRM_Entitlement_Txt__c='Partner Admin,Employee,Partner Admin Delegate',PRM_Partner_Role_Txt__c='Original Equipment Manufacturer (OEM);Distributor;Solution Integrator',PMP_Benefit_Code_Txt__c='Partner;Prestige'));
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        
        Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account parent1 = new Account();
        parent1.RecordTypeId = opidAccRecordTypeId;
        parent1.Name='Cello Ltdq123';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999992';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        parent1.Industry='Construction';
        parent1.Core_User_Defined_Website__c='www.abc.com';
        Parent1.Core_Geo__c='ASMO';
        insert parent1;
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John WickTest 123';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='123214';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.Industry='Construction';
        testAccount.OwnerId = UserInfo.getUserId();
        testAccount.Core_User_Defined_Website__c = 'www.abc.com';
        testAccount.Core_IPA_One_Partner_Id__c=parent1.id;
        testAccount.Core_Geo__c = 'ASMO';
        insert testAccount;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='GrillTest';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff123.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_IPA_PartnerRole__c='Distributor';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.MailingCountry='India';
        insert cont;
        user u = [select id,FirstName, AccountId,Email, contactId, Core_IPA_One_Partner_Id__c from user where email='testUsercoreMDM@intel.com' limit 1];
        Test.startTest();
        system.runAs(u){
            isTandC= PRM_DashboardTabVisibilityController.isTAndCAccepted (cont.id);
        }
        Test.stopTest();
    
    
}
@isTest
    public static void testisStepOneCompleted(){
        boolean isStepOneCompleted=false;
         List<PMP_Dashboard_Tab__mdt> dtList = new List<PMP_Dashboard_Tab__mdt>();
        PMP_Dashboard_Tab__mdt dt = new PMP_Dashboard_Tab__mdt();
        dt.DeveloperName = 'Account_Activity';
        dt.PRM_Profile_Txt__c = 'System Administrator,IT Admin';
        dt.PRM_Entitlement_Txt__c = 'Partner Admin Delegate,Partner Admin';
        dtList.add(dt);
        dtList.add(new PMP_Dashboard_Tab__mdt(DeveloperName='Renewal',PRM_Entitlement_Txt__c='Partner Admin,Employee,Partner Admin Delegate',PRM_Partner_Role_Txt__c='Original Equipment Manufacturer (OEM);Distributor;Solution Integrator',PMP_Benefit_Code_Txt__c='Partner;Prestige'));
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        
        Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account parent1 = new Account();
        parent1.RecordTypeId = opidAccRecordTypeId;
        parent1.Name='Cello Ltdq123';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999992';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        parent1.Industry='Construction';
        parent1.Core_User_Defined_Website__c='www.abc.com';
        Parent1.Core_Geo__c='ASMO';
        insert parent1;
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John WickTest 123';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='123214';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.Industry='Construction';
        testAccount.OwnerId = UserInfo.getUserId();
        testAccount.Core_User_Defined_Website__c = 'www.abc.com';
        testAccount.Core_IPA_One_Partner_Id__c=parent1.id;
        testAccount.Core_Geo__c = 'ASMO';
        insert testAccount;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='GrillTest';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff123.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_IPA_PartnerRole__c='Distributor';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.MailingCountry='India';
        insert cont;
        user u = [select id,FirstName, AccountId,Email, contactId, Core_IPA_One_Partner_Id__c from user where email='testUsercoreMDM@intel.com' limit 1];
        Test.startTest();
        system.runAs(u){
            isStepOneCompleted= PRM_DashboardTabVisibilityController.isStepOneCompleted ();
        }
        Test.stopTest();
         
}
}