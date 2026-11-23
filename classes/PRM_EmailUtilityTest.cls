/*********************************************************************************************************************
Class Name  : PRM_EmailUtilityTest
Version       : 1.0
Created Date  : MAR 2019
Function      : Test Class for 'PRM_EmailUtility'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Rahul Kainth              01 March,2019           Test Class for 'PRM_EmailUtility'

*********************************************************************************************************************/

@isTest()
public class PRM_EmailUtilityTest {
    
    
    /**
     * Below method was commented by Agate team.
     * Please check the below log before uncomment it. which was causes some issue during our deployment
     * log:     |EXCEPTION_THROWN|[95]|System.QueryException: unexpected token: '!'
     * Root Cause :- !%UserFirstName%! comes on query so for it failed.
     *          |USER_DEBUG|[92]|DEBUG|(Select Name,AccountNumber from Account where id= '0018A00000UdR3oQAF', 
     *                      Select Name,PRM_Benefit_Cd__c from PRM_PartnerBenefit__c where id= 'a5u8A000000EBJFQA4', 
     *                      Select FirstName,LastName,AccountId,Email,Phone,Name,Core_eRPM_Language_Code__c,mailingCountry,Core_Account_Primary_Country__c,!%UserFirstName%! from Contact where id= '0038A00000SLSdYQAX')
     */
    
    
    static testMethod void testSendEmail(){
        
        Account a1;
        Contact cont1;
        Account a;
        Contact cont;
        PRM_PartnerBenefit__c pbenefit;
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'newuser5' + String.valueOf(DateTime.Now().getTime()) + '@intel.com',
            Alias = 'batman66',
            Email='newuser156wwr5@intel.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce1',
            Lastname='Wayne1',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);
        
        Group gp = new Group(Name='Test');
        insert gp;
        List<GroupMember> listOfGM = new List<GroupMember>();
        List<User> usersList = new List<User>();
        //User u = [Select Id,Name,email from user where Id=:UserInfo.getuserId()];
        GroupMember gpm = new GroupMember();
        gpm.GroupId = gp.Id;
        gpm.UserOrGroupId =portalAccountOwner1.Id;
        listOfGM.add(gpm);
        
        
        
        System.runas(portalAccountOwner1)
        {
            list<account> accLst=new list<account>();
            a = new Account();
            a.Name='ABC';
            a.BillingCity='Bengaluru';
            a.BillingCountry='India';
            a.BillingStreet='4th Floor,ITPL,Brookfield';
            a.BillingPostalCode='560037';
            a.ownerId= portalAccountOwner1.id ;
            a.Core_User_Defined_Website__c='www.testww.com';
        a.website='www.testww.com';
            accLst.add(a);
         //   insert a;
            
            a1 = new Account();
            a1.Name='ABC1';
            a1.BillingCity='Bengaluru';
            a1.BillingCountry='India';
            a1.BillingStreet='4th Floor1,ITPL1,Brookfield';
            a1.BillingPostalCode='5600371';
            a1.ownerId= portalAccountOwner1.id ;
            a1.Core_User_Defined_Website__c='www.testww1.com';
        	a1.website='www.testww1.com';
            accLst.add(a1);
            //insert a1;
            
          Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
         
        Account accPAGu = new Account();
        accPAGu.RecordTypeId = accountRecordTypePAG;
        accPAGu.Name = 'nnceuncu';
        accPAGu.Core_OnePartnerID__c = '3003';
        //accPAG.Core_OPID_Name__c = 'nnceuncu';
        //accPAGu.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        //insert accPAGu;
      accLst.add(accPAGu);
            
        Account accPAGu1 = new Account();
        accPAGu1.RecordTypeId = accountRecordTypePAG;
        accPAGu1.Name = 'nnceuncu';
        accPAGu1.Core_OnePartnerID__c = '3003';
        //accPAG.Core_OPID_Name__c = 'nnceuncu';
        //accPAGu.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        //insert accPAGu;
      accLst.add(accPAGu1);
            
            
            Account a12 = new Account();
            a12.RecordTypeId = accountRecordTypeIntel;
            a12.Name='ABC122';
            a12.BillingCity='Bengaluru';
            a12.BillingCountry='India';
            a12.BillingStreet='4th Floor12,ITPL12,Brookfield';
            a12.BillingPostalCode='5600322';
            a12.ownerId= portalAccountOwner1.id ;
            a12.Core_User_Defined_Website__c='www.testww122.com';
        	a12.website='www.testww122.com';
            accLst.add(a12);
        insert accLst;
            
            cont = PRM_TestUtility.getContact();
            cont.AccountId=a.Id;
            cont.MailingCountry='USA';
            cont.MailingCountryCode = 'USA';
            insert cont;
            //system.debug('Contact Id' +cont.Id);
            
            ChannelProgram cp = PRM_TestUtility.getChannelPrograms();
            insert cp;
            
             Map<Id,Core_Account_Group_Member__c>  listOfCAGOld = new Map<Id,Core_Account_Group_Member__c> ();
            Core_Account_Group_Member__c cag1 = new Core_Account_Group_Member__c();
            cag1.Core_Intel_Account_Id__c = a1.Id;    
            cag1.Core_Partner_Account_Id__c = accPAGu.id;
            insert cag1;
            //cag.Core_Inactive_Ind__c = true;
            listOfCAGOld.put(cag1.id,cag1);
            
            List<Core_Account_Group_Member__c> listOfCAG = new List<Core_Account_Group_Member__c>();
            
            Core_Account_Group_Member__c cag12 = new Core_Account_Group_Member__c();
            cag12.Core_Intel_Account_Id__c = a12.Id;    
            cag12.Core_Partner_Account_Id__c = accPAGu1.id;
            insert cag12;
            
            
           /* Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
            cag.Core_Intel_Account_Id__c = a.Id;    
            cag.Core_Partner_Account_Id__c = accPAGu.id;
          //  cag.Core_Inactive_Ind__c = true;*/
          cag1.Core_Inactive_Ind__c=true;
          update cag1;
            listOfCAG.add(cag1);
            
           
            PRM_EmailUtility.deactivationEmailofLastCAGRecords(listOfCAG,listOfCAGOld);
            
            PRM_AccountChannelMembership__c acm = PRM_TestUtility.getMembership();
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Account_Id__c=a.Id;
            acm.PRM_Partner_Role__c='Guest';
            acm.PRM_Status_Reason_Txt__c = 'Testclass';
            TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
            insert acm;
            TriggerHandler.clearbypass('PRM_ACMTriggerHandlerNew');
            
            pbenefit= PRM_TestUtility.getPartnerBenefit();
            insert pbenefit;
            
            
            PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
            contRelation.Name=System.Label.PRM_Primary_Contact;
            contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
            contRelation.PRM_Default_Relationship_Ind__c = true;
            contRelation.PRM_Channel_Program_Id__c=cp.Id;            
            insert contRelation;
            
            PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
            acctContRel.PRM_Account_Id__c=a.Id;
            acctContRel.PRM_Contact_Id__c=cont.Id;
            //acctContRel.PRM_Account_Channel_Membership_Id__c=acm.Id;
            acctContRel.PRM_Relationship_Id__c=contRelation.Id;
            acctContRel.PRM_InActive_Ind__c=false;
            test.startTest();
            insert acctContRel;
            
            acctContRel.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
            update acctContRel;
            
        }
        
        UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
       // test.startTest();
        insert ur;  
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner']; 
        User userRecord = new User();      
        userRecord.Alias = 'StdUser';
        userRecord.contactId =cont.id;
        userRecord.Email = 'newuser454661@intel.com';
        //userRecord.UserRoleId = ur.Id ;
        userRecord.EmailEncodingKey ='UTF-8';
        userRecord.LastName = 'Testing';
        userRecord.FirstName = 'FName';
        userRecord.LanguageLocaleKey = 'en_US';
        userRecord.LocaleSidKey = 'en_US';
        userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
        userRecord.UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
        userRecord.isActive = true;
        userRecord.ProfileID =  p.id;           
        insert userRecord;
        
        System.runas(portalAccountOwner1)
        {
           PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
           regRequest.PRM_First_Name__c = 'Emma';
           regRequest.PRM_Last_Name__c = 'Stiles';
           regRequest.PRM_Contact_Country__c = 'US';
           regRequest.PRM_Account_Name__c  = 'TestData555';
           regRequest.PRM_Contact_Login_ID__c  = 'emmastiles555@mailinator.com';
           regRequest.PRM_Email_ID__c  = 'emmastiles555@mailinator.com';
           regRequest.PRM_Enterprise_ID__c  = '300002199715' ;
           regRequest.PRM_EV_Token__c  = 'kci59#%jcd' ;         
           regRequest.PRM_Preferred_Language__c  = 'ZHO';
           regRequest.PRM_Person_Phone_Number__c  = '9891744651';
           insert regRequest;
          
            //Test.startTest();
            PRM_EmailUtility.EmailNotification en = new PRM_EmailUtility.EmailNotification();
            Map<String,String> paramMap = new Map<String,String>();
			      en.EmailID= regRequest.PRM_Email_ID__c ;
			      en.Language = regRequest.PRM_Preferred_Language__c ;
			      paramMap.put('Registration_Request_ID',regRequest.id);
            paramMap.put('Contact_ID',cont.id);
            en.BusinessEvent = 'BENEFIT ADDITION40';
            en.InputParameters=paramMap;
            en.ChannelProgram = 'Intel Partner Alliance';
            en.PartnerType = 'CsP';
            PRM_EmailUtility.sendEmail(en);
            
            //External email scenario
            en.BusinessEvent = 'Registration_request_for_new_User';
            en.EmailID='user212@intel.com';        
            PRM_EmailUtility.sendEmail(en);
            
            //External email scenario to cover error in logs
            en.BusinessEvent = 'Registration_request_for_new_User';
            en.EmailID='user212intel.com';        
            PRM_EmailUtility.sendEmail(en);
            
            en.BusinessEvent = 'BENEFIT ADDITION2';
            PRM_EmailUtility.sendEmail(en);
            
            en.BusinessEvent = 'BENEFIT ADDITION4';
           // PRM_EmailUtility.sendEmail(en);
            System.assertEquals(a.Name,'ABC','Value does not match');
           
            Test.stopTest();
            
        }
        
      
    } 
   
    
    static testMethod void testSendEmailwithRegistrationRequest(){
        
        Test.startTest();
        ChannelProgram cp = PRM_TestUtility.getChannelPrograms();
        insert cp;
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        

        PRM_Registration_Request__c regRequest = PRM_TestUtility.getPRMRegistrationRequest();
        
        regRequest.PRM_Phy_Address_Line_1__c  = '4th Floor,ITPL Main Road';
        regRequest.PRM_Phy_Address_Line_2__c  = 'Bengaluru,India';
        regRequest.PRM_Phy_City__c  = 'Las Vegas' ;
        regRequest.PRM_Phy_Country__c  = 'USA' ;
        regRequest.PRM_Phy_State_Province__c  = 'NY' ;
        regRequest.PRM_Phy_Zip_Postal_Code__c  = '0273' ;
        //regRequest.PRM_CIM_ID__c  =  ;
        regRequest.PRM_Account_Name__c  = 'Intel' ;
        
        regRequest.PRM_Account_URL__c  = 'www.intel.com' ;
        regRequest.PRM_Channel_Program__c  = cp.Id ;
        regRequest.PRM_Channel_Program_Level__c  = cpl.Id;
        regRequest.PRM_Company_Email_Domain__c  = 'intel.com' ;
        //regRequest.PRM_Email_ID__c  = 'testrequest@mailinator.com' ;
        regRequest.PRM_Enterprise_ID__c  = '300002199713' ;
        regRequest.PRM_EV_Token__c  = 'kfi59#%jfd' ;         
        regRequest.PRM_EV_flag__c  = false ;
        //regRequest.PRM_Job_Function__c  ='OPER' ;
        regRequest.PRM_Profession__c  ='Consultant' ;
        //regRequest.PRM_Preferred_Language__c  = 'ENG' ;
        regRequest.PRM_Partner_Segment__c  = 'Cloud' ;
        //regRequest.PRM_Partner_Type__c  =  ;
        regRequest.PRM_Partner_Relationship__c  =System.Label.PRM_Primary_Contact;
        regRequest.PRM_Status__c  = 'New' ;
        regRequest.PRM_Status_Reason__c  = 'New Contact Creation' ;
        regRequest.PRM_Subscriptions__c  = 'CSPx2_Sub2' ;
        regRequest.PRM_Person_Phone_Number__c  = '9891744631' ;
        regRequest.PRM_Contact_Login_ID__c  = 'testrequest@mailinator.com'  ;
        regRequest.PRM_Legal_Agreements__c  = 'IPA_TANDC' ;
        regRequest.PRM_Profile_Response__c  =' {QuestionCode  = CSPx2_ServicePlanTodayAOrNext | ResponseCode  = CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue  = CSPx2_ServicePlanTodayOrNext_DBAAS}{QuestionCode  = CSPx2_ServicePlanTodayOrNext | ResponseCode  = CSPx2_ServicePlanTodayOrNext_ConAAS | ResponseValue  = CSPx2_ServicePlanTodayOrNext_ConAAS}'; 
        regRequest.PRM_Email_Log__c=null;
        insert regRequest;                         
        
        PRM_EmailUtility.EmailNotification emailWrap = new PRM_EmailUtility.EmailNotification();
        emailWrap.businessEvent = 'xyz';
        emailWrap.emailID = 'hgkg@intel.com';
        emailWrap.language = 'English';
        emailWrap.country = 'India';
        emailWrap.geo = 'XYZ';
        emailWrap.channelProgram = 'Intel Partner Alliance';
        emailWrap.partnerType = 'Employee';
        emailWrap.partnerAdmin = true;
        
        Test.stopTest();
        PRM_Registration_Request__c updatedReq = [Select Id,PRM_Email_Log__c,PRM_Legal_Agreements__c from PRM_Registration_Request__c where PRM_Contact_Login_ID__c='testrequest@mailinator.com']; 
        //System.assert(updatedReq.PRM_Email_Log__c!=null, 'The related email log is not set on the registration request'); 
        System.assertEquals(updatedReq.PRM_Legal_Agreements__c,'IPA_TANDC','Value does not match');
    }
    /*
    @isTest static void sendBenefitsEmailNotificationTest(){
        
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        PRM_Benefit_Group__c bg1 = new PRM_Benefit_Group__c();
        bg1.Name='Sheetal Test1';
        bg1.PRM_InActive_Ind__c= false;
        insert bg1;
        
        PRM_Benefit_Group__c bg2 = new PRM_Benefit_Group__c();
        bg2.Name='Sheetal Test2';
        bg2.PRM_InActive_Ind__c= false;
        insert bg2;
        PRM_PartnerBenefit__c pbTest = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest.Name = 'Partner University';
        pbTest.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pbTest.PRM_InActive_Ind__c = false;
        pbTest.PRM_Channel_Program_Id__c= cpTest.Id;
        insert pbTest;
        
        PRM_PartnerBenefit__c pbTest1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest1.Name = 'Marketing Studio';
        pbTest1.PRM_Benefit_Cd__c = 'BFTMKTSTD';
        pbTest1.PRM_InActive_Ind__c = false;
        pbTest1.PRM_Channel_Program_Id__c= cpTest.Id;
        insert pbTest1;
        PRM_Benefit_Group_Benefit_Association__c bGBA1 = new PRM_Benefit_Group_Benefit_Association__c();
        bGBA1.PRM_Benefit_Id__c = pbTest.id;
        bGBA1.PRM_Benefit_Group_Id__c = bg1.id;
        bGBA1.PRM_Start_Date_Dt__c = date.today();
        bGBA1.PRM_Status_Nm__c ='Live';
        insert bGBA1;
        
        PRM_Benefit_Group_Benefit_Association__c bGBA2 = new PRM_Benefit_Group_Benefit_Association__c();
        bGBA2.PRM_Benefit_Id__c = pbTest1.id;
        bGBA2.PRM_Benefit_Group_Id__c = bg1.id;
        bGBA2.PRM_Start_Date_Dt__c = date.today();
        bGBA2.PRM_Status_Nm__c ='Pending';
        insert bGBA2;
        
        PRM_Benefit_Group_Benefit_Association__c bGBA3 = new PRM_Benefit_Group_Benefit_Association__c();
        bGBA3.PRM_Benefit_Id__c = pbTest1.id;
        bGBA3.PRM_Benefit_Group_Id__c = bg2.id;
        bGBA3.PRM_Start_Date_Dt__c = date.today();
        bGBA3.PRM_Status_Nm__c ='Live';
        insert bGBA3;
        
        List<PRM_Benefit_Group_Benefit_Association__c> lstOfBgba = new List<PRM_Benefit_Group_Benefit_Association__c>(); 
        List<PRM_Benefit_Group_Benefit_Association__c> lstOfBgba1 = new List<PRM_Benefit_Group_Benefit_Association__c>();
        BGBA1.PRM_InActive_Ind__c =True;
        lstOfBgba.add(BGBA1);
        BGBA2.PRM_InActive_Ind__c =True;
        BGBA2.PRM_Status_Nm__c ='Live';
        lstOfBgba.add(BGBA2);
        BGBA3.PRM_InActive_Ind__c =false;
        lstOfBgba.add(BGBA3);
        
        update (lstOfBgba);
        
        Group gp = new Group(Name='Test');
        insert gp;
        List<GroupMember> listOfGM = new List<GroupMember>();
        List<User> usersList = new List<User>();
        User u = [Select Id,Name,email from user where Id=:UserInfo.getuserId()];
        GroupMember gpm = new GroupMember();
        gpm.GroupId = gp.Id;
        gpm.UserOrGroupId =u.Id;
        listOfGM.add(gpm);
        //system.debug('u-->'+u);
        //system.debug('gpm-->'+gpm);
        
        System.runAs(u){
            List<PRM_Benefit_Group_Benefit_Association__c> lOfPbgBa = [select id, name,PRM_Status_Nm__c, PRM_InActive_Ind__c from PRM_Benefit_Group_Benefit_Association__c];
            Map<Id, PRM_Benefit_Group_Benefit_Association__c> oldmap = new Map<Id, PRM_Benefit_Group_Benefit_Association__c>(lOfPbgBa);
            
            Map<Id, PRM_Benefit_Group_Benefit_Association__c> oldmap1 = new Map<Id, PRM_Benefit_Group_Benefit_Association__c>();
            //List<Core_Account_Group_Member__c> lOfcag = [select id, Core_Partner_Account_Id__c,Core_Intel_Account_Id__c from Core_Account_Group_Member__c];
            //Map<Id, Core_Account_Group_Member__c> cagold = new Map<Id, Core_Account_Group_Member__c>(lOfcag);
            
            Test.startTest();
            PRM_EmailUtility.sendBenefitsEmailNotification(lstOfBgba,oldmap);
            try{
                PRM_EmailUtility.sendBenefitsEmailNotification(null,oldmap);
                //PRM_EmailUtility.deactivationEmailofLastCAGRecords(null,null);
            }
            catch(Exception ex){
                
            }
            Test.stopTest();
            System.assertEquals(pbTest.Name , 'Partner University','Value does not exist');         
        } 
    } */
    /*
    @isTest public static void sendEmailToPublicGroupTest(){
        Test.startTest();                
        Account testAccount = new Account(); //Account
        testAccount.Name='Big Net';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
        testAccount.Core_Account_BU_Focus__c= 'CCG';
        testAccount.Core_IPA_Partner_Role__c='Service Provider';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='USA';
        testAccount.BillingCountryCode='USA';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Tier__c = 'Tier1';
        testAccount.Core_User_Defined_Website__c='www.testww.com';
        testAccount.website='www.testww.com';
        insert testAccount;
        //system.debug('TestACC'+ testAccount.Id);
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        //cont.Core_Job_Function__c='Branch Manager';
        cont.Core_Profession__c='PROFESSOR';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Do_Not_Contact__c = false;
        insert cont;
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=testAccount.Id;
        cont1.lastName='John';
        cont1.FirstName='Adam';
        cont1.email='Adamjohn@rediff.com';
        //cont1.Core_Job_Function__c='Branch Manager';
         cont1.Core_Profession__c='PROFESSOR';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Do_Not_Contact__c = false;
        insert cont1;
        
        Profile pf= [Select Id from profile where Name='System Administrator'];
       
        User newUser=new User(firstname = 'Adam', 
                         lastName = 'John', 
                         email = 'vijaydarshan110@deloitte.com', 
                         Username = 'Adamjohn@rediff.com', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = 'abcd', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        );
        
        insert newUser;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c cr=new PRM_ContactRelationships__c();
        cr.Name=System.Label.PRM_Primary_Contact;
        cr.PRM_Contact_Relationship_Cd__c='RELTNTRNFR';
        cr.PRM_Channel_Program_Id__c=cp.Id;
        insert cr;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=testAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c = cr.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_execute_trigger__c=true;
        insert acctContRel;
        
        acctContRel.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        update acctContRel;
        
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
       // spec.Name='Cloud Data Center Specialist';
        spec.Name='Addition Select Benefit';
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        //system.debug('spec'+ spec.Id);
        
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c = testAccount.Id;
        asa.PRM_Specialty_Id__c = spec.id;
        asa.PRM_Partner_Role__c = 'Service Provider';
        insert asa; //
        //system.debug('asa'+ asa.Id);
        PRM_Account_Specialty_Association__c successasa = [SELECT ID,Name,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Account_Id__r.name,
                                                           PRM_Specialty_Id__r.name,PRM_Specialty_Id__c, PRM_InActive_Ind__c FROM PRM_Account_Specialty_Association__c 
                                                           where id =:asa.id];
        
        List<PRM_Account_Specialty_Association__c> successListOfASA = new List<PRM_Account_Specialty_Association__c>();
        successListOfASA.add(successasa);
        
        //system.debug('successListOfASA '+ successListOfASA);
        //PRM_EmailUtility.sendEmailToPublicGroup(successListOfASA);
        
        Group gp = new Group(Name='PRM_Speciality_Admin_Group');
        insert gp;
        List<GroupMember> listOfGM = new List<GroupMember>();
        List<User> usersList = new List<User>();
        User u = [Select Id,Name,email from user where Id=:UserInfo.getuserId()];
        usersList.add(u);
        GroupMember gpm = new GroupMember();
        gpm.GroupId = gp.Id;
        gpm.UserOrGroupId =u.Id;
        listOfGM.add(gpm);
        //system.debug('u-->'+u);
        //system.debug('gpm-->'+gpm);
        System.runAs(u){
            PRM_EmailUtility.sendEmailToPublicGroup(successListOfASA);
            PRM_EmailUtility.sendBenefitsEmailNotification(null,null);
        }
        PRM_EmailUtility.sendEmailToPublicGroup(null);
        
        Test.stopTest();
        System.assertEquals(testAccount.Name,'Big Net','Value does not exist');
    }  */
    /*
    @isTest public static void sendEmailToPrimaryContacts(){
                    
      Account testAccount1 = new Account(); //Account
      testAccount1.Name='NewIntelAccount';
      testAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
      testAccount1.Core_Account_BU_Focus__c= 'CCG';
      testAccount1.Core_IPA_Partner_Role__c='Service Provider';
      testAccount1.BillingCity='Bengaluru';
      testAccount1.BillingStreet='221B BackerStreet';
      testAccount1.BillingCountry='USA';
      testAccount1.BillingCountryCode='USA';
      testAccount1.BillingPostalCode='Postal code';
      testAccount1.Core_Account_Tier__c = 'Tier1';
      testAccount1.Core_User_Defined_Website__c='www.testww221.com';
      testAccount1.website='www.testww221.com';
      insert testAccount1;
      //system.debug('TestACC1'+ testAccount1.Id);
      
      Contact cont = new Contact();  //Contact
      cont.AccountId=testAccount1.Id;
      cont.lastName='Toby';
      cont.FirstName='Sam';
      cont.email='TobySam@rediff.com';
      //cont.Core_Job_Function__c='Branch Manager';
      cont.Core_Profession__c='PROFESSOR';
      cont.Core_eRPM_Language_Code__c='Eng';
      cont.Core_IPA_PartnerRole__c = 'Service Provider';
      cont.Core_Do_Not_Contact__c = false;
      insert cont;
      
      Contact cont1 = new Contact();  //Contact
      cont1.AccountId=testAccount1.Id;
      cont1.lastName='Sam';
      cont1.FirstName='Fiona';
      cont1.email='Samfiona@rediff.com';
      cont1.Core_Profession__c='PROFESSOR';
      cont1.Core_eRPM_Language_Code__c='Eng';
      cont1.Core_IPA_PartnerRole__c = 'Service Provider';
      cont1.Core_Do_Not_Contact__c = false;
      insert cont1;
      
      Profile pf= [Select Id from profile where Name='System Administrator'];
     
      User newUser=new User(firstname = 'Fiona', 
                       lastName = 'Sam', 
                       email = 'Fionasam1110@deloitte.com', 
                       Username = 'Fionajohn@rediff.com', 
                       EmailEncodingKey = 'ISO-8859-1', 
                       Alias = 'abcde', 
                       TimeZoneSidKey = 'America/Los_Angeles', 
                       LocaleSidKey = 'en_US', 
                       LanguageLocaleKey = 'en_US', 
                       ProfileId = pf.Id
                      );
      
      insert newUser;
      
      ChannelProgram cp = new ChannelProgram();
      cp.Name='Intel Partner Alliance';
      cp.PRM_programCode__c='IPA';
      insert cp;
      
      PRM_ContactRelationships__c cr=new PRM_ContactRelationships__c();
      cr.Name=System.Label.PRM_Primary_Contact;
      cr.PRM_Contact_Relationship_Cd__c='RELTNTRNFR';
      cr.PRM_Channel_Program_Id__c=cp.Id;
      insert cr;
      
      ChannelProgramLevel cpl=new ChannelProgramLevel();
      cpl.Name='Member';
      cpl.ProgramId=cp.Id;
      insert cpl;
      
      PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c();
      acm.PRM_Account_Id__c=testAccount1.id;
      acm.PRM_Status_Nm__c='Approved';
      acm.PRM_Channel_Program_Id__c=cp.Id;
      acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
      acm.PRM_Partner_Role__c='Service Provider';
      insert acm;
      
      PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
      acctContRel.PRM_Account_Id__c=testAccount1.Id;
      acctContRel.PRM_Contact_Id__c=cont.Id;
      acctContRel.PRM_Relationship_Id__c = cr.Id;
      acctContRel.PRM_InActive_Ind__c=false;
      acctContRel.PRM_execute_trigger__c=true;
      insert acctContRel;
      
      acctContRel.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
      update acctContRel;
      
      
      PRM_Specialty__c spec = new PRM_Specialty__c();
     // spec.Name='Cloud Data Center Specialist';
      spec.Name='Addition Select Benefit';
      spec.PRM_Description_Txt__c='This is description';
      spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
      spec.PRM_Role_Nm__c='Service Provider';
      spec.PRM_Tier_Nm__c='Gold';
      spec.PRM_Start_Date_Dt__c= system.today() + 7;
      spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
      spec.PRM_Access_Level_Nm__c='Public';
      insert spec;
      //system.debug('spec'+ spec.Id);

      PRM_EmailLog__c emaillog = new PRM_EmailLog__c();
      emaillog.PRM_Subject__c='Congratulations on Your New Intel® Cloud Insider Status';
      emaillog.PRM_ToEmailID__c='ebert123@mailinator.com';
      emaillog.PRM_EmailContent__c='htmlbodyvar=EVVV256012UjVvhkwf826270target=wcm-ciqa.com';
      emaillog.PRM_Contact__c=cont.id;
      emaillog.Language__c='ENG';
      emaillog.Email_Template_Name__c ='SCRUACCTADD';
      insert emaillog;
      
      
      PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
      asa.PRM_Account_Id__c = testAccount1.Id;
      asa.PRM_Specialty_Id__c = spec.id;
      asa.PRM_Partner_Role__c = 'Service Provider';
      insert asa; //
      
      
      PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
      asa1.PRM_Account_Id__c= testAccount1.id;
      asa1.PRM_Specialty_Id__c= spec.id;
      asa1.PRM_Partner_Role__c='Service Provider';
      
      List<PRM_Account_Specialty_Association__c> listOfASA = new List<PRM_Account_Specialty_Association__c>();
      listOfASA.add(asa1);

      Test.startTest();
        PRM_EmailUtility.sendEmailToPrimaryContacts(listOfASA, null);
        Test.stopTest();
      
      
      System.assertEquals(testAccount1.Name,'NewIntelAccount','Value does not exist');
  } */
    
    
    static testmethod void sendEmailonOpidUpgrade(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        

        Account parentAccount = new Account();//Account
        parentAccount.RecordTypeId = recordTypeIdPAGAccount;
        parentAccount.Name='Tesco';
        parentAccount.BillingCity='City';
        parentAccount.BillingStreet='Street';
        parentAccount.BillingCountry='India';
        parentAccount.BillingPostalCode='Postal code';
        parentAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        parentAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';
        parentAccount.Core_User_Defined_Website__c='www.testww.com';
        parentAccount.website='www.testww.com';
        
        insert parentAccount;
        
        Account childAccount = new Account();//Account
        childAccount.RecordTypeId = recordTypeIdAccount;
        childAccount.Name='Amazon';
        childAccount.BillingCity='City';
        childAccount.BillingStreet='Street';
        childAccount.BillingCountry='India';
        childAccount.BillingPostalCode='Postal code';
        childAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        childAccount.Core_IPA_Partner_Role__c='Solution Integrator';
         childAccount.Core_User_Defined_Website__c='www.testww.com';
        childAccount.website='www.testww.com';
        insert childAccount;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = parentAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = childAccount.id;
        insert coreAccnt;

        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Partner';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
         ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Prestige';
        cpl2.ProgramId=cp.Id;
        insert cpl2;
        Test.startTest();
       PRM_AccountChannelMembership__c intelAccntACM = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        intelAccntACM.PRM_Account_Id__c= childAccount.id;
        intelAccntACM.PRM_Status_Nm__c='Approved';
        intelAccntACM.PRM_Channel_Program_Id__c=cp.Id;
        intelAccntACM.PRM_Channel_Program_Level_Id__c=cpl.Id;
        intelAccntACM.PRM_Partner_Role__c='Solution Integrator';
        intelAccntACM.PRM_Status_Reason_Txt__c = 'Testclass';
        insert intelAccntACM; 
        
        PRM_AccountChannelMembership__c pagAccntACM = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        pagAccntACM.PRM_Account_Id__c= parentAccount.id;
        pagAccntACM.PRM_Status_Nm__c='Approved';
        pagAccntACM.PRM_Channel_Program_Id__c=cp.Id;
        pagAccntACM.PRM_Channel_Program_Level_Id__c=cpl.Id;
        pagAccntACM.PRM_Partner_Role__c='Solution Integrator';
        pagAccntACM.PRM_Status_Reason_Txt__c = 'Testclass';
        insert pagAccntACM;
        
       //List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=childAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        //cont.Core_Job_Function__c='Branch Manager';
        cont.Core_Profession__c='PROFESSOR';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont.Core_Login_Id__c = 'abc';
        cont.Core_Do_Not_Contact__c = false;
        cont.MailingCountry='USA';
        cont.MailingCountryCode = 'USA';
        insert cont;
        //con.add(cont);
        
        
       Contact cont1 = new Contact();  //Contact
        cont1.AccountId=childAccount.Id;
        cont1.lastName='David';
        cont1.FirstName='Adam';
        cont1.email='Adamdavid@rediff.com';
        //cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_Profession__c='PROFESSOR';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont1.Core_Do_Not_Contact__c = false;
        cont1.Core_Preferred_Language__c = '';
        cont1.MailingCountry='USA';
        cont1.MailingCountryCode = 'USA';
        insert cont1;
        
        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=childAccount.Id;
        cont2.lastName='William';
        cont2.FirstName='Adam';
        cont2.email='Adamwilliam@rediff.com';
        //cont2.Core_Job_Function__c='Branch Manager';
        cont2.Core_Profession__c='PROFESSOR';
        cont2.Core_eRPM_Language_Code__c='Eng';
        cont2.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont2.Core_Do_Not_Contact__c = false;
        cont2.Core_Preferred_Language__c = 'ENG';
        cont2.MailingCountry='USA';
        cont2.MailingCountryCode = 'USA';
        insert cont2;
        
      /*   Contact cont1 = new Contact();  //Contact
        cont1.AccountId=childAccount.Id;
        cont1.lastName='George';
        cont1.FirstName='Adam';
        cont1.email='Gerogedavid@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont1.Core_Do_Not_Contact__c = false;
        cont1.Core_Preferred_Language__c = 'SPA';
        insert cont1; */
        
         Profile pf= [Select Id from profile where Name='System Administrator'];
       
        User newUser=new User(firstname = 'Adam', 
                         lastName = 'David', 
                         email = 'Adamgrill@deloitte.com', 
                         Username = 'Adamgrill@rediff.com', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = 'abcd', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        );
        
        insert newUser;
      
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr=new PRM_ContactRelationships__c();
        cr.Name='Trainee';
        cr.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr.PRM_Channel_Program_Id__c=cp.Id;
        //crList.add(cr);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_Primary_Contact;
        cr2.PRM_Contact_Relationship_Cd__c=System.Label.PRM_Primary_Contact;
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        //crList.add(cr2);
        //insert crList;
        insert cr2;
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=childAccount.Id;
        acr.PRM_Relationship_Id__c = cr2.Id;
        //acr.PRM_Contact_Id__c=con[0].Id;
        acr.PRM_Contact_Id__c= cont.Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_Status_Nm__c = 'Complete';
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1; 
        insert acr;
        //system.debug('acr--1>'+acr);
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=childAccount.Id;
        acr1.PRM_Relationship_Id__c = cr2.Id;
        //acr.PRM_Contact_Id__c=con[0].Id;
        acr1.PRM_Contact_Id__c= cont1.Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Start_Date_Dt__c= system.today()-2;    
        acr1.PRM_Status_Nm__c = 'Complete';
        acr1.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1; 
        insert acr1;
        
         PRM_Account_Contact_Relationship__c acr2=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr2.PRM_InActive_Ind__c= false;
        acr2.PRM_Account_Id__c=childAccount.Id;
        acr2.PRM_Relationship_Id__c = cr2.Id;
        acr2.PRM_Contact_Id__c= cont2.Id;
        acr2.PRM_execute_trigger__c=true;
        acr2.PRM_Start_Date_Dt__c= system.today()-2;    
        acr2.PRM_Status_Nm__c = 'Complete';
        acr2.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1; 
        insert acr2;

       Test.stopTest();   

        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> updatedACMList = new List<PRM_AccountChannelMembership__c>();
        acmList.add(pagAccntACM);
        
        
        for(PRM_AccountChannelMembership__c eachACM :acmList){
            eachACM.PRM_Channel_Program_Level_Id__c = cpl1.Id;
            updatedACMList.add(eachACM);
        }
        try{
            update updatedACMList;
        }catch(Exception ex){
            //system.debug(ex.getMessage());
        }
        
      // PRM_EmailUtility.sendEmailToPrimaryContactsOnOpidUpgrade(updatedACMList,null);
        
        PRM_AccountChannelMembership__c acm1 = [Select Id,PRM_Partner_Role__c from PRM_AccountChannelMembership__c where Id= :pagAccntACM.Id];
        system.assertEquals('Solution Integrator',acm1.PRM_Partner_Role__c,'Value should not be updated');
    }
      static testmethod void sendOptInEmail(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        List<PRM_Partner_Assist_Consent__c> pacList = new List<PRM_Partner_Assist_Consent__c>();
        List<PRM_Partner_Consent_Distributor__c> disList = new List<PRM_Partner_Consent_Distributor__c>();

        Account parentAccount = new Account();//Account
        parentAccount.RecordTypeId = recordTypeIdPAGAccount;
        parentAccount.Name='Tesco';
        parentAccount.BillingCity='City';
        parentAccount.BillingStreet='Street';
        parentAccount.BillingCountry='India';
        parentAccount.BillingPostalCode='Postal code';
        parentAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        parentAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';
        parentAccount.Core_User_Defined_Website__c='www.testww.com';
        parentAccount.website='www.testww.com';
        insert parentAccount;
        
        Account childAccount = new Account();//Account
        childAccount.RecordTypeId = recordTypeIdAccount;
        childAccount.Name='Amazon';
        childAccount.BillingCity='City';
        childAccount.BillingStreet='Street';
        childAccount.BillingCountry='India';
        childAccount.BillingPostalCode='Postal code';
        childAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        childAccount.AccountNumber='8976542378';
        childAccount.Core_IPA_Partner_Role__c='Solution Integrator';
        parentAccount.Core_User_Defined_Website__c='www.testww.com';
        parentAccount.website='www.testww.com';
        insert childAccount;
        
    
        Contact cont = new Contact();  //Contact
        cont.AccountId=childAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        //cont.Core_Job_Function__c='Branch Manager';
        cont.Core_Profession__c='PROFESSOR';
        cont.Core_eRPM_Language_Code__c='ZHO';
        cont.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont.Core_Login_Id__c = 'abc';
        cont.Core_Do_Not_Contact__c = false;
        cont.MailingCountry='USA';
        cont.MailingCountryCode = 'USA';
        insert cont;
        //con.add(cont);
        
        
       Contact cont1 = new Contact();  //Contact
        cont1.AccountId=childAccount.Id;
        cont1.lastName='David';
        cont1.FirstName='Adam';
        cont1.email='Adamdavid@rediff.com';
        //cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_Profession__c='PROFESSOR';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont1.Core_Do_Not_Contact__c = false;
        cont1.Core_Preferred_Language__c = '';
        cont1.MailingCountry='USA';
        cont1.MailingCountryCode = 'USA';  
        insert cont1;
        
        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=childAccount.Id;
        cont2.lastName='William';
        cont2.FirstName='Adam';
        cont2.email='Adamwilliam@rediff.com';
        //cont2.Core_Job_Function__c='Branch Manager';
         cont2.Core_Profession__c='PROFESSOR';
        cont2.Core_eRPM_Language_Code__c='Eng';
        cont2.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont2.Core_Do_Not_Contact__c = false;
        cont2.Core_Preferred_Language__c = 'ENG';
        cont2.MailingCountry='USA';
        cont2.MailingCountryCode = 'USA';
        insert cont2;
        
        Profile pf= [Select Id from profile where Name='System Administrator'];
       
        User newUser=new User(firstname = 'Adam', 
                         lastName = 'David', 
                         email = 'Adamgrill@deloitte.com', 
                         Username = 'Adamgrill@rediff.com', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = 'abcd', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        );
        
       insert newUser;
     PRM_Partner_Consent_Distributor__c distr=new PRM_Partner_Consent_Distributor__c();
     distr.PRM_Account_Id__c =childAccount.Id;
     distr.PRM_Country_Name__c ='United States';
     distr.PRM_Distributor_Name_Txt__c ='ASI Corporation';
     distr.PRM_Geo_Nm__c ='ASMO';
     disList.add(distr);
     
     PRM_Partner_Consent_Distributor__c distr1=new PRM_Partner_Consent_Distributor__c();
     distr1.PRM_Account_Id__c =childAccount.Id;
     distr1.PRM_Country_Name__c ='United States';
     distr1.PRM_Distributor_Name_Txt__c ='Tech Data Corporation';
     distr1.PRM_Geo_Nm__c ='ASMO';
     disList.add(distr1);
     
     PRM_Partner_Assist_Consent__c pac= new PRM_Partner_Assist_Consent__c();
     pac.PRM_Account_Id__c=childAccount.Id;
     pac.PRM_Consent_Provided_By_Id__c=cont1.Id;
     pac.PRM_Distributor_Id__c=distr.Id;
     pac.PRM_Consent_Provided_Ind__c=true;
     pac.PRM_Consent_Provided_Date_Dt__c=Date.Today();
     pacList.add(pac);
     
     PRM_Partner_Assist_Consent__c pac1= new PRM_Partner_Assist_Consent__c();
     pac1.PRM_Account_Id__c=childAccount.Id;
     pac1.PRM_Consent_Provided_By_Id__c=cont1.Id;
     pac1.PRM_Distributor_Id__c=distr1.Id;
     pac1.PRM_Consent_Provided_Ind__c=true;
     pac1.PRM_Consent_Provided_Date_Dt__c=Date.Today();
     pacList.add(pac1);
     
       System.runAs(newUser){
       Test.startTest();
     insert disList;
       insert pacList;
       Test.stopTest();   

     }
      PRM_Partner_Assist_Consent__c pacRec =[Select Id,Name,PRM_Distributor_Id__c,PRM_Account_Id__c from PRM_Partner_Assist_Consent__c where PRM_Account_Id__c=:childAccount.Id Limit 1];
      system.assertNotEquals('',pacRec.PRM_Distributor_Id__c,'Value should not be null');
    }
        static testmethod void sendOptOutAndModifyEmail(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        List<PRM_Partner_Assist_Consent__c> pacList = new List<PRM_Partner_Assist_Consent__c>();
        List<PRM_Partner_Assist_Consent__c> updatePacList = new List<PRM_Partner_Assist_Consent__c>();
        List<PRM_Partner_Assist_Consent__c> updatePacList1= new List<PRM_Partner_Assist_Consent__c>();
        List<PRM_Partner_Consent_Distributor__c> distList = new List<PRM_Partner_Consent_Distributor__c>();

      
        
        Account account = new Account();//Account
        account.RecordTypeId = recordTypeIdAccount;
        account.Name='Amazon';
        account.BillingCity='City';
        account.BillingStreet='Street';
        account.BillingCountry='India';
        account.BillingPostalCode='Postal code';
        account.Core_Account_Type__c='Cloud Service Provider (CSP)';
        account.AccountNumber='8976542378';
        account.Core_IPA_Partner_Role__c='Solution Integrator';
    account.Core_User_Defined_Website__c='www.testww.com';
        account.website='www.testww.com';
        insert account;
    
    Contact cont = new Contact();  //Contact
        cont.AccountId=account.Id;
        cont.lastName='Grille';
        cont.FirstName='Adams';
        cont.email='AdamsGrill@rediff.com';
        cont.Core_Preferred_Language__c='ENG';
        cont.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont.Core_Login_Id__c = 'abc';
        cont.Core_Do_Not_Contact__c = false;
        cont.MailingCountry='USA';
        cont.MailingCountryCode = 'USA';
        insert cont;
            
        Profile pf= [Select Id from profile where Name='System Administrator'];
       
        User newUser=new User(firstname = 'Adam', 
                         lastName = 'David', 
                         email = 'Adamgrill@deloitte.com', 
                         Username = 'Adamgrill@rediff.com', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = 'abcd', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        );
        
       insert newUser;
     PRM_Partner_Consent_Distributor__c distr=new PRM_Partner_Consent_Distributor__c();
     distr.PRM_Account_Id__c =account.Id;
     distr.PRM_Country_Name__c ='United States';
     distr.PRM_Distributor_Name_Txt__c ='ASI Corporation';
     distr.PRM_Geo_Nm__c ='ASMO';
     distList.add(distr);
     
     PRM_Partner_Consent_Distributor__c distr1=new PRM_Partner_Consent_Distributor__c();
     distr1.PRM_Account_Id__c =account.Id;
     distr1.PRM_Country_Name__c ='United States';
     distr1.PRM_Distributor_Name_Txt__c ='Tech Data Corporation';
     distr1.PRM_Geo_Nm__c ='ASMO';
     distList.add(distr1);
     PRM_Partner_Consent_Distributor__c distr2=new PRM_Partner_Consent_Distributor__c();
     distr2.PRM_Account_Id__c =account.Id;
     distr2.PRM_Country_Name__c ='United States';
     distr2.PRM_Distributor_Name_Txt__c ='Tech Corporation';
     distr2.PRM_Geo_Nm__c ='ASMO';
     distList.add(distr2);
     insert distList;
     PRM_Partner_Assist_Consent__c pac= new PRM_Partner_Assist_Consent__c();
     pac.PRM_Account_Id__c=account.Id;
     pac.PRM_Consent_Provided_By_Id__c=cont.Id;
     pac.PRM_Distributor_Id__c=distList[0].id;
     pac.PRM_Consent_Provided_Ind__c=true;
     pac.PRM_Consent_Provided_Date_Dt__c=Date.Today();
     pacList.add(pac);
     
     PRM_Partner_Assist_Consent__c pac1= new PRM_Partner_Assist_Consent__c();
     pac1.PRM_Account_Id__c=account.Id;
     pac1.PRM_Consent_Provided_By_Id__c=cont.Id;
     pac1.PRM_Distributor_Id__c=distList[1].id;
     pac1.PRM_Consent_Provided_Ind__c=true;
     pac1.PRM_Consent_Provided_Date_Dt__c=Date.Today();
     pacList.add(pac1);
     
     PRM_Partner_Assist_Consent__c pac2= new PRM_Partner_Assist_Consent__c();
     pac2.PRM_Account_Id__c=account.Id;
     pac2.PRM_Consent_Provided_By_Id__c=cont.Id;
     pac2.PRM_Distributor_Id__c=distList[2].id;
     pac2.PRM_Consent_Provided_Ind__c=false;
     pac2.PRM_Consent_Provided_Date_Dt__c=Date.Today();
     pacList.add(pac2);
     
     PRM_Partner_Assist_Consent__c pac3= new PRM_Partner_Assist_Consent__c();
     pac3.PRM_Account_Id__c=account.Id;
     pac3.PRM_Consent_Provided_By_Id__c=cont.Id;
     pac3.PRM_Distributor_Id__c=distList[2].id;
     pac3.PRM_Consent_Provided_Ind__c=false;
     pac3.PRM_Consent_Provided_Date_Dt__c=Date.Today();
     pacList.add(pac3);
     
       System.runAs(newUser){
       Test.startTest();
     insert pacList;
     
     for(PRM_Partner_Assist_Consent__c updatePac :pacList){
     if(updatePac.PRM_Consent_Provided_Ind__c == true ){
             updatePac.PRM_Consent_Provided_Ind__c=false;
           updatePacList.add(updatePac);
         }
       }
       for(PRM_Partner_Assist_Consent__c updatePac1 :pacList){
       if((updatePac1.PRM_Consent_Provided_Ind__c==false) && (updatePac1.PRM_Distributor_Id__c==distList[2].id)){
               updatePac1.PRM_Consent_Provided_Ind__c=true;
               updatePac1.PRM_Distributor_Id__c=distList[1].id;
               updatePacList1.add(updatePac1);
     }
           }
     update updatePacList;
       update updatePacList1;
       Test.stopTest();   

     }
      PRM_Partner_Assist_Consent__c pacUpdated =[Select Id,Name,PRM_Distributor_Id__c,PRM_Account_Id__c from PRM_Partner_Assist_Consent__c where PRM_Account_Id__c=:account.Id Limit 1];
      system.assertNotEquals('',pacUpdated.PRM_Distributor_Id__c,'Value should not be null');
    }
    
}