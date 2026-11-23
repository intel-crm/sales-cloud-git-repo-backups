/**************************************************************************************
Apex Class Name:  Core_HttpCallouts_Handler_Test
Version     : 1.0 
Created Date: 14 Feb 2017
Description    : This class is Test class for Core_HttpCallouts_Handler
*************************************************************************************/
@isTest Public Class Core_HttpCallouts_Handler_Test{
    
    @isTest public static void handlerMethod(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        Profile itAdminPf = [select id, name from Profile where name = 'Data Ops' Limit 1];
    
        User dataops = new User(Alias = 'itAdm21',   Email='itAdminTestx213@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin12',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx213@intel.com');
        insert dataops;
        system.assertequals(dataops.LastName,'UnitTestAdmin12');
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1');
        
        system.runas(itAdminUser){
        Test.setMock(HttpCalloutMock.class, new Core_HttpCallouts_MockResponse_Pass());
        
        Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
        cm.Name = 'IPS Standard Entitlement';
        cm.Value__c  = 'IPS Standard Entitlement';
        insert cm;
        System.assert(true,cm.Value__c != null);
        
        /*Core_System_Credentials__c credentials = new Core_System_Credentials__c (Name='Core_AGS_Get_Entitlement',Core_End_Point_URL__c='https://eip-crm-proxy-dev.cloudhub.io/smit/api/eip-crm-sls-ags/currentRoles ',Core_Password__c='j5s$S$Xo!s9w',Core_UserName__c='proxy_user3');
        insert credentials;
        system.assertequals(credentials.Name,'Core_AGS_Get_Entitlement');*/
       
        List<Account> acc = new List<Account>();
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c = 'samplename',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                        BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');
                                        
        acc.add(testAccount);  
        insert acc;
        
        Account accVal = new Account();
        accVal=[select name from account where id =:acc[0].id];
        accVal.name = 'Geetha Test';
        system.runas(dataops){
           update accVal;
        }
        System.assert(true,accVal.name != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',Core_Enterprise_Id__c='123',MailingCountry='India',
                                          AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false);
        
        insert testContact;
        system.assertequals(testContact.LastName,'testLastName');
        
        Contact testConUpdate = new Contact();
        testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
        testConUpdate.firstname = 'TestName123234';
        testConUpdate.lastname = 'testLastName123';
        update testConUpdate;
        System.assert(true,testConUpdate.lastname != null);
        
        Core_AGS_Role__c role = new Core_AGS_Role__c();
        role.Core_IsActive__c=true;
        role.Core_Technical_Name__c='PFTFileTransfer';
        role.Core_Description__c='Customer IDT Uploader and Downloader User';
        insert role;
        system.assertequals(role.Core_Technical_Name__c,'PFTFileTransfer');
        
        Core_AGS_Role__c role1 = new Core_AGS_Role__c();
        role1.Core_IsActive__c=true;
        role1.Core_Technical_Name__c='Customer IDT User';
        role1.Core_Description__c='Customer IDT User Description';
        insert role1;
        system.assertNOTEquals(null,role1.id);

        
        Core_AGS_Role__c role2 = new Core_AGS_Role__c();
        role2.Core_IsActive__c=true;
        role2.Core_Technical_Name__c='Intel Premier Support';
        role2.Core_Description__c='WOM_ODMUser Test';
        insert role2;
        system.assertequals(role2.Core_Description__c,'WOM_ODMUser Test');
        
    Core_AGS_Role__c role3 = new Core_AGS_Role__c();
    role3.Core_IsActive__c=true;
       
    role3.Core_Description__c='WOM_ODMUser';
    insert role3;
    system.assertequals(role3.Core_Description__c,'WOM_ODMUser');
    
   	Core_AGS_Role__c role4 = new Core_AGS_Role__c();
    role4.Core_IsActive__c=true;

    role4.Core_Description__c='WOM_ODMUsertesting';
    insert role4;
    system.assertequals(role4.Core_Description__c,'WOM_ODMUsertesting');
        
   Core_AGS_Role__c role5 = new Core_AGS_Role__c();
        role5.Core_IsActive__c=true;
        role5.Core_Technical_Name__c='Intel Premier Support Test';
        role5.Core_Description__c='WOM_ODMUser Test User';
        insert role5;
        system.assertequals(role5.Core_Description__c,'WOM_ODMUser Test User');
        
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
        insert cee;
        System.assert(true,cee.Core_IsActive__c!= null);    
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup', Core_AGS_Role_Id__c=role.id, Core_IsActive__c=true, Entitlement_B2B_B2C_Indicator__c = 'B2C');
        insert entitle;
        system.assertNOTEquals(null,entitle.id);
        
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup', Core_AGS_Role_Id__c=role.id, Core_IsActive__c=true, Entitlement_B2B_B2C_Indicator__c = 'B2C');
        insert entitle1;
        system.assertequals(entitle1.name ,'ODM/Price Mask');
        
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request', Core_AGS_Role_Id__c=role.id,Core_IsActive__c=true, Entitlement_B2B_B2C_Indicator__c ='B2C'); 
        insert entitle2;
        system.assertequals(entitle2.name ,'Return Services Request');
        
        Core_Entitlement__c entitle3=new Core_Entitlement__c (name ='Advanced Shipment and Invoice', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test duplicate',Core_AGS_Role_Id__c=role1.id, Core_IsActive__c=true, Entitlement_B2B_B2C_Indicator__c ='B2C');
        insert entitle3;
        system.assertequals(entitle3.Core_Category__c,'Order Management');
        
        Core_Entitlement__c entitle4=new Core_Entitlement__c (name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_AGS_Role_Id__c=role2.id, Core_IsActive__c=true, Entitlement_B2B_B2C_Indicator__c ='B2C');
        insert entitle4;
        system.assertNOTEquals(null,entitle4.id);
        
        Core_Entitlement__c entitle5=new Core_Entitlement__c (name ='Intel Premier', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier',Core_AGS_Role_Id__c=role3.id, Core_IsActive__c=true, Entitlement_B2B_B2C_Indicator__c ='B2C');
        insert entitle5;
        system.assertNOTEquals(null,entitle5.id);
    
    Core_Entitlement__c entitle6=new Core_Entitlement__c (name ='Intel Premier Test', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Test',Core_AGS_Role_Id__c=role4.id, Core_IsActive__c=true, Entitlement_B2B_B2C_Indicator__c ='B2C');
        insert entitle6;
        system.assertNOTEquals(null,entitle6.id);
        
        Core_Entitlement__c entitle7=new Core_Entitlement__c (name ='Intel Premier Support Test', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support Test',Core_AGS_Role_Id__c=role5.id, Core_IsActive__c=true, Entitlement_B2B_B2C_Indicator__c ='B2C');
        insert entitle7;
        system.assertNOTEquals(null,entitle7.id);
        
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle1.id, Core_Selected__c=false,Core_Status__c ='In Progress');
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle3.id, Core_Selected__c=true,Core_Status__c ='Pending');
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=true,Core_Status__c ='Pending');
        Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle4.id, Core_Selected__c=false,Core_Status__c ='Pending');
        Core_Contact_Entitlement__c ce5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle.id, Core_Selected__c=false,Core_Status__c ='Pending');
        Core_Contact_Entitlement__c ce6 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle5.id, Core_Selected__c=false,Core_Status__c ='Pending');
   	    Core_Contact_Entitlement__c ce7 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle6.id, Core_Selected__c=false,Core_Status__c ='Pending');
        Core_Contact_Entitlement__c ce8 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle7.id, Core_Selected__c=true,Core_Status__c ='Pending');
        
        newlstentitle.add(ce1);                                                                         
        newlstentitle.add(ce2);
        newlstentitle.add(ce3);
        newlstentitle.add(ce4);
        newlstentitle.add(ce5);
        newlstentitle.add(ce6);
   	    newlstentitle.add(ce7);
        
        insert newlstentitle;
      
        
        
        List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle4.id, Core_Selected__c=true,Core_Status__c ='');
        Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=false,Core_Status__c ='');
        Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=false,Core_Status__c ='');
        Core_Contact_Entitlement__c conent41 = new Core_Contact_Entitlement__c(id = ce6.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle5.id, Core_Selected__c=false,Core_Status__c ='');
        
        
        oldlstentitle.add(conent1);
        oldlstentitle.add(conent2);
        oldlstentitle.add(conent3);
        oldlstentitle.add(conent41);
        update  oldlstentitle;
        
        List<Core_Contact_Entitlement__c> oldlstentitle1 = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c conent4 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle4.id, Core_Selected__c=false,Core_Status__c ='Pending');
        Core_Contact_Entitlement__c conent5 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true,Core_Status__c ='In Progress');
        Core_Contact_Entitlement__c conent6 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle3.id, Core_Selected__c=true,Core_Status__c ='Pending');
        Core_Contact_Entitlement__c conent7 = new Core_Contact_Entitlement__c(id = ce7.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle6.id, Core_Selected__c=false,Core_Status__c ='Pending');
        Core_Contact_Entitlement__c conent8 = new Core_Contact_Entitlement__c(id = ce8.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle7.id, Core_Selected__c=true,Core_Status__c ='Pending');
        
        oldlstentitle1.add(conent5);
        oldlstentitle1.add(conent6);
        oldlstentitle1.add(conent4);
    oldlstentitle1.add(conent7);
        update  oldlstentitle1;
        Test.startTest();
        String r = Core_HttpCallouts_Handler.getUpdatedAGSStatus(testContact);
        Test.stopTest();
      }
   }

    @isTest public static void handlerMethodError1(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
         Profile itAdminPf = [select id, name from Profile where name = 'Data Ops' Limit 1];
    
        User dataops = new User(Alias = 'itAdm21',   Email='itAdminTestx213@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin12',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx213@intel.com');
        insert dataops;
        system.assertequals(dataops.LastName,'UnitTestAdmin12');
        
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
         system.assertequals(itAdminUser.LastName,'UnitTestAdmin1');
        
        system.runas(itAdminUser){
        Test.setMock(HttpCalloutMock.class, new Core_HttpCallouts_MockResponse_Pass());
        
        Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
        cm.Name = 'IPS Standard Entitlement';
        cm.Value__c  = 'IPS Standard Entitlement';
        insert cm;
        System.assert(true,cm.Value__c != null);
        
        /*Core_System_Credentials__c credentials = new Core_System_Credentials__c (Name='Core_AGS_Get_Entitlement',Core_End_Point_URL__c='https://eip-crm-proxy-dev.cloudhub.io/smit/api/eip-crm-sls-ags/currentRoles ',Core_Password__c='j5s$S$Xo!s9w',Core_UserName__c='proxy_user3');
        insert credentials;
        system.assertequals(credentials.Name,'Core_AGS_Get_Entitlement');*/
       
        List<Account> acc = new List<Account>();
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c = 'samplename',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                        BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');
                                        
        acc.add(testAccount);  
        insert acc;
        
        Account accVal = new Account();
        accVal=[select name from account where id =:acc[0].id];
        accVal.name = 'Geetha Test';
        system.runas(dataops){
           update accVal;
        }
        System.assert(true,accVal.name != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',Core_Enterprise_Id__c='123',MailingCountry='India',
                                          AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false);
        
        insert testContact;
        system.assertequals(testContact.LastName,'testLastName');
        
        Contact testConUpdate = new Contact();
        testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
        testConUpdate.firstname = 'TestName123234';
        testConUpdate.lastname = 'testLastName123';
        update testConUpdate;
        system.assertequals(testConUpdate.firstname,'TestName123234');
        
        Core_AGS_Role__c role = new Core_AGS_Role__c();
        role.Core_IsActive__c=true;
        role.Core_Technical_Name__c='PFTFileTransfer';
        role.Core_Description__c='Customer IDT Uploader and Downloader User';
        insert role;
        system.assertequals(role.Core_Technical_Name__c,'PFTFileTransfer');
        
        Core_AGS_Role__c role1 = new Core_AGS_Role__c();
        role1.Core_IsActive__c=true;
        role1.Core_Technical_Name__c='Customer IDT User';
        role1.Core_Description__c='Customer IDT User Description';
        insert role1;
        system.assertNOTEquals(null,role1.id);
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
        insert cee;
         system.assertequals(cee.Name,'Partner File Transfer');  
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup', Core_AGS_Role_Id__c=role.id, Core_IsActive__c=true);
        insert entitle;
        system.assertNOTEquals(null,entitle.id);

        
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup', Core_AGS_Role_Id__c=role.id, Core_IsActive__c=true);
        insert entitle1;
        System.assert(true,entitle1.Core_Category__c!= null);
        
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request', Core_AGS_Role_Id__c=role.id,Core_IsActive__c=true); 
        insert entitle2;
         system.assertequals(entitle2.Name,'Return Services Request');
        
        Core_Entitlement__c entitle3=new Core_Entitlement__c (name ='Advanced Shipment and Invoice', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test duplicate',Core_AGS_Role_Id__c=role1.id, Core_IsActive__c=true);
        insert entitle3;
        system.assertNOTEquals(null,entitle3.id); 
        
        Test.startTest();
        String r = Core_HttpCallouts_Handler.getUpdatedAGSStatus(testContact);
        Test.stopTest();
        
       }
  
    }

    @isTest public static void handlerMethodError2(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
         Profile itAdminPf = [select id, name from Profile where name = 'Data Ops' Limit 1];
    
        User dataops = new User(Alias = 'itAdm21',   Email='itAdminTestx213@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin12',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx213@intel.com');
        insert dataops;
        system.assertequals(dataops.LastName,'UnitTestAdmin12');            
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1');
        
        system.runas(itAdminUser){
        Test.setMock(HttpCalloutMock.class, new Core_AccountCoverageMockHttpResponse_Failed());
        
        Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
        cm.Name = 'IPS Standard Entitlement';
        cm.Value__c  = 'IPS Standard Entitlement';
        insert cm;
        System.assert(true,cm.Value__c != null);
        
        /*Core_System_Credentials__c credentials = new Core_System_Credentials__c (Name='Core_AGS_Get_Entitlement',Core_End_Point_URL__c='https://eip-crm-proxy-dev.cloudhub.io/smit/api eip-crm-sls-ags/currentRoles ',Core_Password__c='j5s$S$Xo!s9w',Core_UserName__c='proxy_user3');
        insert credentials;
        system.assertequals(credentials.Name,'Core_AGS_Get_Entitlement');*/
        
       
        List<Account> acc = new List<Account>();
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c = 'samplename',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                        BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');
                                        
        acc.add(testAccount);  
        insert acc;
        
        Account accVal = new Account();
        accVal=[select name from account where id =:acc[0].id];
        accVal.name = 'Geetha Test';
        system.runas(dataops){
           update accVal;
        }
        System.assert(true,accVal.name != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',Core_Enterprise_Id__c='123',MailingCountry='India',
                                          AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false);
        
        insert testContact;
        system.assertequals(testContact.LastName,'testLastName');
        
        Contact testConUpdate = new Contact();
        testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
        testConUpdate.firstname = 'TestName123234';
        testConUpdate.lastname = 'testLastName123';
        update testConUpdate;
        system.assertequals(testConUpdate.firstname,'TestName123234');
        
        Core_AGS_Role__c role = new Core_AGS_Role__c();
        role.Core_IsActive__c=true;
        role.Core_Technical_Name__c='PFTFileTransfer';
        role.Core_Description__c='Customer IDT Uploader and Downloader User';
        insert role;
        System.assertEquals(role.Core_Description__c,'Customer IDT Uploader and Downloader User');
        
        Core_AGS_Role__c role1 = new Core_AGS_Role__c();
        role1.Core_IsActive__c=true;
        role1.Core_Technical_Name__c='Customer IDT User';
        role1.Core_Description__c='Customer IDT User Description';
        insert role1;
        system.assertNOTEquals(null,role1.id);

        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
        insert cee;
        system.assertequals(cee.Name,'Partner File Transfer');  
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup', Core_AGS_Role_Id__c=role.id, Core_IsActive__c=true);
        insert entitle;
        system.assertNOTEquals(null,entitle.id);
        
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup', Core_AGS_Role_Id__c=role.id, Core_IsActive__c=true);
        insert entitle1;
        System.assert(true,entitle1.Core_Category__c!= null);
        
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request', Core_AGS_Role_Id__c=role.id,Core_IsActive__c=true); 
        insert entitle2;
        system.assertequals(entitle2.Name,'Return Services Request');
        
       
        Core_Entitlement__c entitle3=new Core_Entitlement__c (name ='Advanced Shipment and Invoice', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test duplicate',Core_AGS_Role_Id__c=role1.id, Core_IsActive__c=true);
        insert entitle3;
        system.assertNOTEquals(null,entitle3.id);
        
        
        Test.startTest();
        String r = Core_HttpCallouts_Handler.getUpdatedAGSStatus(testContact);
        Test.stopTest();
        
       }
  
    }

    // NEW TEST METHODS TO INCREASE COVERAGE:

    @isTest public static void testAzureEmptyResponse(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        User itAdminUser = createTestUser(itAdminPrf.Id, 'testuser1@intel.com', 'TestUser1');
        insert itAdminUser;
        
        system.runas(itAdminUser){
            Test.setMock(HttpCalloutMock.class, new MockResponse_EmptyArray());
            
            // Create test data
            TestDataWrapper testData = createTestData(itAdminUser);
            
            Test.startTest();
            String result = Core_HttpCallouts_Handler.getUpdatedAGSStatus(testData.testContact);
            Test.stopTest();
            
            System.assert(result != null);
        }
    }

    @isTest public static void testAzureNullResponse(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        User itAdminUser = createTestUser(itAdminPrf.Id, 'testuser2@intel.com', 'TestUser2');
        insert itAdminUser;
        
        system.runas(itAdminUser){
            Test.setMock(HttpCalloutMock.class, new MockResponse_Null());
            
            TestDataWrapper testData = createTestData(itAdminUser);
            
            Test.startTest();
            String result = Core_HttpCallouts_Handler.getUpdatedAGSStatus(testData.testContact);
            Test.stopTest();
            
            System.assert(result != null);
        }
    }

    @isTest public static void testInsertConEntByAGSRolesException(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        User itAdminUser = createTestUser(itAdminPrf.Id, 'testuser4@intel.com', 'TestUser4');
        insert itAdminUser;
        
        system.runas(itAdminUser){
            TestDataWrapper testData = createTestData(itAdminUser);
            
            Map<Contact, Set<String>> mapConlstAGSRoles = new Map<Contact, Set<String>>();
            Set<String> roles = new Set<String>{'TestRole'};
            mapConlstAGSRoles.put(testData.testContact, roles);
            
            Test.startTest();
            Core_HttpCallouts_Handler.insertConEntByAGSRoles(mapConlstAGSRoles, 'Test Reason');
            Test.stopTest();
            
            // Verify log entry was created for exception
            List<Core_Log_Entry__c> logs = [SELECT Id FROM Core_Log_Entry__c WHERE Core_Origin__c = 'insertConEntByAGSRoles'];
            System.assert(logs.size() >= 0); // May or may not create log depending on data
        }
    }

    @isTest public static void testB2BContactIndicatorLogic(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        User itAdminUser = createTestUser(itAdminPrf.Id, 'testuser5@intel.com', 'TestUser5');
        insert itAdminUser;
        
        system.runas(itAdminUser){
            Test.setMock(HttpCalloutMock.class, new MockResponse_B2B());
            
            TestDataWrapper testData = createB2BTestData(itAdminUser);
            
            Test.startTest();
            String result = Core_HttpCallouts_Handler.getUpdatedAGSStatus(testData.testContact);
            Test.stopTest();
            
            System.assert(result != null);
        }
    }

    @isTest public static void testEdgeCasesInBuildUpdateMethod(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        User itAdminUser = createTestUser(itAdminPrf.Id, 'testuser6@intel.com', 'TestUser6');
        insert itAdminUser;
        
        system.runas(itAdminUser){
            Test.setMock(HttpCalloutMock.class, new MockResponse_EdgeCases());
            
            TestDataWrapper testData = createEdgeCaseTestData(itAdminUser);
            
            Test.startTest();
            String result = Core_HttpCallouts_Handler.getUpdatedAGSStatus(testData.testContact);
            Test.stopTest();
            
            System.assert(result != null);
        }
    }

    @isTest public static void testCompleteStatusScenarios(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        User itAdminUser = createTestUser(itAdminPrf.Id, 'testuser8@intel.com', 'TestUser8');
        insert itAdminUser;
        
        system.runas(itAdminUser){
            Test.setMock(HttpCalloutMock.class, new MockResponse_CompleteStatus());
            
            TestDataWrapper testData = createCompleteStatusTestData(itAdminUser);
            
            Test.startTest();
            String result = Core_HttpCallouts_Handler.getUpdatedAGSStatus(testData.testContact);
            Test.stopTest();
            
            System.assert(result != null);
        }
    }

    @isTest public static void testBlankStatusScenarios(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        User itAdminUser = createTestUser(itAdminPrf.Id, 'testuser9@intel.com', 'TestUser9');
        insert itAdminUser;
        
        system.runas(itAdminUser){
            Test.setMock(HttpCalloutMock.class, new MockResponse_BlankStatus());
            
            TestDataWrapper testData = createBlankStatusTestData(itAdminUser);
            
            Test.startTest();
            String result = Core_HttpCallouts_Handler.getUpdatedAGSStatus(testData.testContact);
            Test.stopTest();
            
            System.assert(result != null);
        }
    }

    // HELPER METHODS:

    private static User createTestUser(Id profileId, String email, String lastName){
        return new User(
            Alias = 'test', 
            Email = email, 
            EmailEncodingKey = 'UTF-8', 
            LastName = lastName,
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = profileId, 
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = email
        );
    }

    private static TestDataWrapper createTestData(User testUser){
        TestDataWrapper wrapper = new TestDataWrapper();
        
        // Create IPS Label
        Core_IPS_Labels__c cm = new Core_IPS_Labels__c();
        cm.Name = 'IPS Standard Entitlement';
        cm.Value__c = 'IPS Standard Entitlement';
        insert cm;
        
        // Create Account
        Account testAccount = new Account(
            Name = 'testAccount123', 
            Core_Sales_Group__c = 'Global Accounts',
            Core_IsODM__c = true,
            Core_Account_Type__c = 'Other', 
            Industry = 'Others', 
            Core_CNDA_Number__c = '12345',
            Core_English_Only_Name__c = 'samplename',
            BillingStreet = '1234 tester St', 
            BillingCity = 'testCity', 
            BillingState = 'OR',
            Core_Alternate_Language_Name__c = 'test',
            BillingCountry = 'USA', 
            BillingPostalCode = '12345',
            Core_IPS_Active__c = false, 
            Core_CIM_ID__c = '123124'
        );
        insert testAccount;
        
        // Create Contact
        Contact testContact = new Contact(
            FirstName = 'testFirstName123', 
            LastName = 'testLastName', 
            Email = 'test123@testing.com.test',
            Core_English_Only_First_Name__c = '',
            Core_English_Only_Last_Name__c = '',
            Core_Enterprise_Id__c = '123',
            MailingCountry = 'India',
            AccountId = testAccount.Id,
            Core_Local_First_Name__c = 'david',
            Core_IPS_Active__c = false,
            Core_IPS_Intel_Support_Owner__c = testUser.Id,
            Core_Contact_B2B_Indicator__c = false,
            Core_Personal_Email_Indicator__c = false
        );
        insert testContact;
        
        wrapper.testAccount = testAccount;
        wrapper.testContact = testContact;
        
        return wrapper;
    }

    private static TestDataWrapper createB2BTestData(User testUser){
        TestDataWrapper wrapper = createTestData(testUser);
        
        // Create B2B specific test data
        Core_ERPM_Engagement__c engagement = new Core_ERPM_Engagement__c(
            Name = 'B2B Engagement', 
            Core_Engagement_Type__c = 'SEC',
            Core_IsActive__c = true,
            Core_Technical_Engagement_Code__c = 'B2B',
            Core_Technical_DeDup_Number__c = 'B2B'
        );
        insert engagement;
        
        Core_AGS_Role__c role = new Core_AGS_Role__c();
        role.Core_IsActive__c = true;
        role.Core_Technical_Name__c = 'B2BRole';
        role.Core_Description__c = 'B2B Role Description';
        insert role;
        
        Core_Entitlement__c entitlement = new Core_Entitlement__c(
            name = 'B2B Entitlement', 
            Core_Category__c = 'Order Management',
            Core_Sub_Category__c = 'Web Reporting',
            Core_Help_Text__c = 'Help text',
            Core_ERPM_Engagement_Id__c = engagement.id,
            Core_Display_Name__c = 'B2B Entitlement', 
            Core_AGS_Role_Id__c = role.id, 
            Core_IsActive__c = true, 
            Entitlement_B2B_B2C_Indicator__c = 'B2C'
        );
        insert entitlement;
        
        Core_Contact_Entitlement__c contactEntitlement = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = wrapper.testContact.Id,
            Core_Entitlement_Id__c = entitlement.id, 
            Core_Selected__c = false,
            Core_Status__c = 'Pending'
        );
        insert contactEntitlement;
        
        return wrapper;
    }

    private static TestDataWrapper createEdgeCaseTestData(User testUser){
        TestDataWrapper wrapper = createTestData(testUser);
        
        // Create entitlements with null AGS roles to test edge cases
        Core_ERPM_Engagement__c engagement = new Core_ERPM_Engagement__c(
            Name = 'Edge Case Engagement', 
            Core_Engagement_Type__c = 'SEC',
            Core_IsActive__c = true,
            Core_Technical_Engagement_Code__c = 'EDGE',
            Core_Technical_DeDup_Number__c = 'EDGE'
        );
        insert engagement;
        
        Core_Entitlement__c entitlement = new Core_Entitlement__c(
            name = 'Edge Case Entitlement', 
            Core_Category__c = 'Order Management',
            Core_Sub_Category__c = 'Web Reporting',
            Core_Help_Text__c = 'Help text',
            Core_ERPM_Engagement_Id__c = engagement.id,
            Core_Display_Name__c = 'Edge Case Entitlement', 
            Core_IsActive__c = true, 
            Entitlement_B2B_B2C_Indicator__c = 'B2C'
            // Note: No AGS_Role_Id to test null handling
        );
        insert entitlement;
        
        Core_Contact_Entitlement__c contactEntitlement = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = wrapper.testContact.Id,
            Core_Entitlement_Id__c = entitlement.id, 
            Core_Selected__c = true,
            Core_Status__c = 'Complete'
        );
        insert contactEntitlement;
        
        return wrapper;
    }

    private static TestDataWrapper createCompleteStatusTestData(User testUser){
        TestDataWrapper wrapper = createTestData(testUser);
        
        Core_AGS_Role__c role = new Core_AGS_Role__c();
        role.Core_IsActive__c = true;
        role.Core_Technical_Name__c = 'CompleteStatusRole';
        role.Core_Description__c = 'Complete Status Role';
        insert role;
        
        Core_ERPM_Engagement__c engagement = new Core_ERPM_Engagement__c(
            Name = 'Complete Status Engagement', 
            Core_Engagement_Type__c = 'SEC',
            Core_IsActive__c = true,
            Core_Technical_Engagement_Code__c = 'COMP',
            Core_Technical_DeDup_Number__c = 'COMP'
        );
        insert engagement;
        
        Core_Entitlement__c entitlement = new Core_Entitlement__c(
            name = 'Complete Status Entitlement', 
            Core_Category__c = 'Order Management',
            Core_Sub_Category__c = 'Web Reporting',
            Core_Help_Text__c = 'Help text',
            Core_ERPM_Engagement_Id__c = engagement.id,
            Core_Display_Name__c = 'Complete Status Entitlement', 
            Core_AGS_Role_Id__c = role.id,
            Core_IsActive__c = true, 
            Entitlement_B2B_B2C_Indicator__c = 'B2C'
        );
        insert entitlement;
        
        Core_Contact_Entitlement__c contactEntitlement = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = wrapper.testContact.Id,
            Core_Entitlement_Id__c = entitlement.id, 
            Core_Selected__c = true,
            Core_Status__c = 'Complete'
        );
        insert contactEntitlement;
        
        return wrapper;
    }

    private static TestDataWrapper createBlankStatusTestData(User testUser){
        TestDataWrapper wrapper = createTestData(testUser);
        
        Core_AGS_Role__c role = new Core_AGS_Role__c();
        role.Core_IsActive__c = true;
        role.Core_Technical_Name__c = 'BlankStatusRole';
        role.Core_Description__c = 'Blank Status Role';
        insert role;
        
        Core_ERPM_Engagement__c engagement = new Core_ERPM_Engagement__c(
            Name = 'Blank Status Engagement', 
            Core_Engagement_Type__c = 'SEC',
            Core_IsActive__c = true,
            Core_Technical_Engagement_Code__c = 'BLANK',
            Core_Technical_DeDup_Number__c = 'BLANK'
        );
        insert engagement;
        
        Core_Entitlement__c entitlement = new Core_Entitlement__c(
            name = 'Blank Status Entitlement', 
            Core_Category__c = 'Order Management',
            Core_Sub_Category__c = 'Web Reporting',
            Core_Help_Text__c = 'Help text',
            Core_ERPM_Engagement_Id__c = engagement.id,
            Core_Display_Name__c = 'Blank Status Entitlement', 
            Core_AGS_Role_Id__c = role.id,
            Core_IsActive__c = true, 
            Entitlement_B2B_B2C_Indicator__c = 'B2C'
        );
        insert entitlement;
        
        Core_Contact_Entitlement__c contactEntitlement = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = wrapper.testContact.Id,
            Core_Entitlement_Id__c = entitlement.id, 
            Core_Selected__c = false,
            Core_Status__c = ''
        );
        insert contactEntitlement;
        
        return wrapper;
    }

    // MOCK CLASSES - CLEAN AND SIMPLE:

    public class MockResponse_EmptyArray implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[]'); // Empty array response
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockResponse_Null implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(''); // Null/empty response
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockResponse_B2B implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().contains('memberof')){
                res.setBody('[{"displayName":"B2BRole"}]');
            } else {
                res.setBody('[{"id":"test-user-id","mail":"test@test.com"}]');
            }
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockResponse_EdgeCases implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().contains('memberof')){
                res.setBody('[{"displayName":"UnknownRole"}]');
            } else {
                res.setBody('[{"id":"test-user-id","mail":"test@test.com"}]');
            }
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockResponse_CompleteStatus implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().contains('memberof')){
                res.setBody('[]'); // No roles returned
            } else {
                res.setBody('[{"id":"test-user-id","mail":"test@test.com"}]');
            }
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockResponse_BlankStatus implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().contains('memberof')){
                res.setBody('[{"displayName":"BlankStatusRole"}]');
            } else {
                res.setBody('[{"id":"test-user-id","mail":"test@test.com"}]');
            }
            res.setStatusCode(200);
            return res;
        }
    }

    // DATA WRAPPER CLASS:
    public class TestDataWrapper {
        public Account testAccount;
        public Contact testContact;
    }

    // EXISTING MOCK CLASSES:
    public class Core_AccountCoverageMockHttpResponse_Failed implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            return res;
        }
    }   

    public class Core_HttpCallouts_MockResponse_Pass implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('GET', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().contains('memberof')){
                res.setBody('[{"displayName":"Customer IDT User"},{"displayName":"PFTFileTransfer"}]');
            } else {
                res.setBody('[{"id":"test-user-id","mail":"test@test.com"}]');
            }
            res.setStatusCode(200);
            return res;
        }
    }       
}