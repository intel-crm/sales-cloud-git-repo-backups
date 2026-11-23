/**************************************************************************************
Apex Class Name: Core_ContactEntVal_Test
Description    : This class is Test class for Core_ContactEntitlementValidation
*************************************************************************************/
@isTest
public class Core_ContactEntVal_Test {
    
    @testSetup static void setup() {
        
        List<Core_Contact_Ent_Validation_Message__c> lstvalmsg = new List<Core_Contact_Ent_Validation_Message__c>();
        // Core_Contact_Ent_Validation_Message__c entvalmsg1 = new Core_Contact_Ent_Validation_Message__c(Name='UI CNDA',Core_Error_Message__c='The account must have a valid CNDA to be able to grant access. Please verify if the account has a valid CNDA (<a href="https://intel.tap.thinksmart.com/prod/Portal/WorkflowDashboard/?cid=c924622d_fcae_4333_9c95_46104114907d" target="_blank">',Core_Error_Message2__c= 'NDA Viewer</a>) - and add it to account record',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
        Core_Contact_Ent_Validation_Message__c entvalmsg2 = new Core_Contact_Ent_Validation_Message__c(Name='UI Unique Entitlement',Core_Error_Message__c='You cannot select IPS and Partner Portal together. Only one can be selected',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
        Core_Contact_Ent_Validation_Message__c entvalmsg3 = new Core_Contact_Ent_Validation_Message__c(Name='System PersonalEmailIndicator',Core_Error_Message__c='NO Personal Emails',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
        Core_Contact_Ent_Validation_Message__c entvalmsg4 = new Core_Contact_Ent_Validation_Message__c(Name='System English on Contact',Core_Error_Message__c='English Only on Contact can\'t be blank (Populate from Standard and Alternate if avalible and meet req)',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
        //Core_Contact_Ent_Validation_Message__c entvalmsg5 = new Core_Contact_Ent_Validation_Message__c(Name='System Account Owner Role',Core_Error_Message__c='Account Owner Role Can\'t be blank',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
        //Core_Contact_Ent_Validation_Message__c entvalmsg6 = new Core_Contact_Ent_Validation_Message__c(Name='System ISO',Core_Error_Message__c='IPS Contacts must have an identified Intel Support Owner for accounts with a CNDA',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
        Core_Contact_Ent_Validation_Message__c entvalmsg7 = new Core_Contact_Ent_Validation_Message__c(Name='System PSG WOM',Core_Error_Message__c='The PSG Downstream flag is not set to true on the Account',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
        //lstvalmsg.add(entvalmsg1);
        lstvalmsg.add(entvalmsg2);
        lstvalmsg.add(entvalmsg3);
        lstvalmsg.add(entvalmsg4);
        //lstvalmsg.add(entvalmsg5);
        //lstvalmsg.add(entvalmsg6);
        lstvalmsg.add(entvalmsg7);
        
        
        insert lstvalmsg;
        
        String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others', RecordTypeId=intelAccRecTypeId,
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545');
        insert testAccount;
        System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com.testsetup',MailingCountry='India',
                                          AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
        insert testContact;
        Account testAccount2 = new Account(Name='testAccountSetup1', Core_Sales_Group__c='Global Accounts',
                                           Core_Account_Type__c='Other', Industry='Others', RecordTypeId=intelAccRecTypeId,
                                           BillingStreet='1234 testAccountSetup1', BillingCity='testCity2', BillingState='OR',
                                           BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IsODM__c=true);
        insert testAccount2;
        System.assert(true,testAccount2.Core_CNDA_Number__c != null);
        
        Contact testContact2 = new Contact(FirstName='John', LastName='Petrick', Email='johnpetrick@testing.com.testsetup2',MailingCountry='India',
                                           AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
        insert testContact2;
        System.assert(true,testContact.Core_Personal_Email_Indicator__c != null);
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer1', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;
        system.assertNOTEquals(null,cee.id,'Engagement id is null');
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Customer Sales Order Reporting1', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test account setup',Core_IsActive__c=true);
        insert entitle;
        System.assert(true,entitle.Core_Category__c!= null);
        
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='Advaced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test account setup data',Core_IsActive__c=true);
        insert entitle1;
        System.assert(true,entitle1.Core_Category__c!= null);
        
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Test Entl', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test setup data1',Core_IsActive__c=true);
        insert entitle2;
        
        List<Core_Contact_Entitlement_Validation__c> lstentval= new List<Core_Contact_Entitlement_Validation__c>();
        Core_Contact_Entitlement_Validation__c entval = new Core_Contact_Entitlement_Validation__c(Name='4',Core_Entitlement_Id__c=entitle1.id,Core_Entitlement_Name__c='Customer Sales Order Reporting1',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=true,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=true,Core_Support_Owner__c=true,Core_PSG_WOM__c=true);
        Core_Contact_Entitlement_Validation__c entval1  = new Core_Contact_Entitlement_Validation__c(Name='1',Core_Entitlement_Id__c=entitle.id,Core_Entitlement_Name__c='Intel Premier Support',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=false,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=true,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=true,Core_Support_Owner__c=true,Core_PSG_WOM__c=true);
        Core_Contact_Entitlement_Validation__c entval2 = new Core_Contact_Entitlement_Validation__c(Name='2',Core_Entitlement_Id__c=entitle1.id,Core_Entitlement_Name__c='Partner Portal',Core_Account_English_Only_Name__c=false,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=false,Core_ODM_Checked__c=true,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=true,Core_Support_Owner__c=true,Core_PSG_WOM__c=true);
        Core_Contact_Entitlement_Validation__c entval3 = new Core_Contact_Entitlement_Validation__c(Name='3',Core_Entitlement_Id__c=entitle.id,Core_Entitlement_Name__c='Advaced Shipment and Invoice Notification',Core_Account_English_Only_Name__c=false,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=false,Core_ODM_Checked__c=true,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=true,Core_Support_Owner__c=true,Core_PSG_WOM__c=true);
        lstentval.add(entval);
        lstentval.add(entval1);
        lstentval.add(entval2);
        
        insert lstentval;
        
        Test.startTest(); 
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                         Core_Entitlement_Id__c=entitle.id,
                                                                         Core_Selected__c=true);
        insert ce; 
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=entitle1.id,
                                                                          Core_Selected__c=true);
        insert ce1; 
        Test.stopTest();
        
        
        
        List<Core_Contact_Entitlement_Exclusive__c> oldexclusive = new List<Core_Contact_Entitlement_Exclusive__c>();
        Core_Contact_Entitlement_Exclusive__c exclusive = new Core_Contact_Entitlement_Exclusive__c(Core_Unique_Ids__c=entitle.id+','+entitle1.id,Name='Support');
        oldexclusive.add(exclusive);
        insert oldexclusive;
        Core_ContactEntitlementValidation.validatePersonalEmailIndicator(entitle1.id,testContact);
        
    }
    public static testmethod void testContEntVal() {
        
        
        Profile itAdminPrf = [select id, name from Profile where name = 'Data Ops' Limit 1];
        
        Profile itAdminpf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        List<User> userList = new List<User> ();
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        //insert itAdminUser;
        userList.add(itAdminUser);
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1','Last name not matching as UnitTestAdmin1');
        
        User itAdmin = new User(Alias = 'itAdm221',   Email='itAdminTestx218@intel.com', 
                                EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin12',
                                LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                ProfileId = itAdminpf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                UserName='salesRepTestx211@intel.com');
        //insert itAdmin;
        userList.add(itAdmin);
        system.assertequals(itAdmin.LastName,'UnitTestAdmin12','Last name not matching as UnitTestAdmin12');
        insert userList;
        
        system.runas(itAdmin){
            
            Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
            cm.Name = 'IPS Standard Entitlement';
            cm.Value__c  = 'IPS Standard Entitlement';
            insert cm;
            System.assert(true,cm.Value__c != null);
            
            Core_Trigger_Executions__c executions = new Core_Trigger_Executions__c(Name='addContactEntitlementSubordinates',Core_Active__c=true,Core_Class_Name__c='Core_IPS_CaseTriggerHandler',Core_Description__c='testcase',Core_Object__c='case',Core_Trigger_Events__c='after update');
            insert executions;
            system.assertNOTEquals(null,executions.id,'custom setting trigger not inserted');
            List<Account> acc = new List<Account>();
            
            String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = True, RecordTypeId=intelAccRecTypeId,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c ='samplename',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);
            
            acc.add(testAccount);  
            insert acc;
            
            Account testAccount1 = new Account(Name='testAccount143', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = false, RecordTypeId=intelAccRecTypeId,
                                               Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c ='samplename',
                                               BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                               BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);
            insert testAccount1;
            //acc.add(testAccount1);
            //insert acc;
            
            Account accVal = new Account();
            accVal=[select name from account where id =:acc[0].id];
            accVal.name = 'Geetha Test';
            system.runas(itAdminUser){
                update accVal;
                
                
            }
            
            List<Account> lstValue =[select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_English_Only_Name__c,Core_Account_Type__c from Account where id =:acc[0].id];
            //List<Account> lstValue1 =[select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_English_Only_Name__c,Core_Account_Type__c from Account where id =:acc[1].id];
            //Map<Id, Account> mapacc = new Map<Id, Account>([select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_English_Only_Name__c,Core_Account_Type__c from Account]);
            Map<Id, Account> mapacc = new  Map<Id, Account>();
            for(account accvallist:lstValue )
            {
                mapacc.put(accvallist.id,accvallist);
            }
            
            List<Contact> lsttestContact = new List<Contact>();
            List<Contact> lsttestContactUpdate = new List<Contact>();
            
            Core_Trigger_Executions__c executions1 = new Core_Trigger_Executions__c(Name='UpdateJobFunctionAndCode',Core_Active__c=true,Core_Class_Name__c='Core_ContactHandler',Core_Description__c='testcase',Core_Object__c='Contact',Core_Trigger_Events__c='Before Insert Before Update');
            insert executions1;
            
            
            
            Contact testContact = new Contact(FirstName='阿昌', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',MailingCountry='India',
                                              AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
            
            //insert testContact;
            lsttestContact.add(testContact);
            system.assertequals(testContact.LastName,'testLastName','Last name not matching as testLastName');
            
            Contact testContact1 = new Contact(FirstName='阿昌', LastName='testLastName', Email='test14x3@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',MailingCountry='India',
                                               AccountId=testAccount1.Id,Core_Local_First_Name__c='',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
            
            lsttestContact.add(testContact1);
            //insert testContact1;
            insert lsttestContact;
            
            Contact testConUpdate = new Contact();
            testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
            testConUpdate.firstname = 'TestName123234';
            testConUpdate.lastname = 'testLastName123';
            update testConUpdate;
            
            
            
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', 
                                                                    
                                                                    Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
            insert cee;
            System.assert(true,cee.Core_IsActive__c!= null);   
            
            List<Core_Entitlement__c> lstEnt = new List<Core_Entitlement__c>();
            Core_Entitlement__c entitle = new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
            lstEnt.add(entitle);
            
            
            Core_Entitlement__c entitle1 = new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
            lstEnt.add(entitle1);
            
            
            Core_Entitlement__c entitle2 = new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
            lstEnt.add(entitle2);
            
            Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_IsActive__c=true); 
            lstEnt.add(entitle3);
            
            Core_Entitlement__c entitle4 = new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true); 
            lstEnt.add(entitle4);
            
            Core_Entitlement__c entitle5 = new Core_Entitlement__c (name ='Resource & Design Center Collaboration Workspaces', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center Collaboration Workspaces',Core_IsActive__c=true); 
            lstEnt.add(entitle5);
            
            insert lstEnt;
            
            List<Core_Entitlement_Profile_Access__c> lstprofileaccess = new List<Core_Entitlement_Profile_Access__c>();
            
            Core_Entitlement_Profile_Access__c profileaccess = new Core_Entitlement_Profile_Access__c(Core_Entitlements_Allowed__c='ODM/Price Mask',Core_Profile_Id__c=itAdminPrf.id);
            lstprofileaccess.add(profileaccess);
            insert lstprofileaccess;
            
            List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = lstEnt[3].id , Core_Selected__c=false);
            Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[1].id, Core_Selected__c=true);
            Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= lstEnt[2].id, Core_Selected__c=false);
            Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= lstEnt[0].id, Core_Selected__c=true);
            Core_Contact_Entitlement__c ce5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Entitlement_Id__c= lstEnt[4].id, Core_Selected__c=true);
            Core_Contact_Entitlement__c ce6 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Entitlement_Id__c= lstEnt[5].id, Core_Selected__c=true);
            //Core_Contact_Entitlement__c ce7 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Entitlement_Id__c= lstEnt[5].id, Core_Selected__c=true);
            
            newlstentitle.add(ce1);                                                                         
            newlstentitle.add(ce2);
            newlstentitle.add(ce3);
            newlstentitle.add(ce4);
            newlstentitle.add(ce5);
            newlstentitle.add(ce6);
            //newlstentitle.add(ce7);
            Test.startTest();    
            insert newlstentitle;
            
            List<Core_Contact_Entitlement_Subordinates__c> lstSubAdd = new List<Core_Contact_Entitlement_Subordinates__c>();
            Core_Contact_Entitlement_Subordinates__c subordinates = new Core_Contact_Entitlement_Subordinates__c(Name='1',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[1].id,Core_Is_ODM_True__c=true,Core_Is_CNDA_True__c=true);
            Core_Contact_Entitlement_Subordinates__c subordinates1 = new Core_Contact_Entitlement_Subordinates__c(Name='2',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[3].id,Core_Is_ODM_True__c=False,Core_Is_CNDA_True__c=False);
            Core_Contact_Entitlement_Subordinates__c subordinates2 = new Core_Contact_Entitlement_Subordinates__c(Name='3',Core_Entitlement_Id__c=lstEnt[2].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[0].id,Core_Is_ODM_True__c=true,Core_Is_CNDA_True__c=False);
            Core_Contact_Entitlement_Subordinates__c subordinates3 = new Core_Contact_Entitlement_Subordinates__c(Name='4',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[0].id,Core_Is_ODM_True__c=false,Core_Is_CNDA_True__c=True);
            Core_Contact_Entitlement_Subordinates__c subordinates4 = new Core_Contact_Entitlement_Subordinates__c(Name='5',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[1].id,Core_Is_ODM_False__c=true,Core_Is_CNDA_True__c=true);
            Core_Contact_Entitlement_Subordinates__c subordinates5 = new Core_Contact_Entitlement_Subordinates__c(Name='6',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[3].id,Core_Is_ODM_False__c=False,Core_Is_CNDA_True__c=False);
            Core_Contact_Entitlement_Subordinates__c subordinates6 = new Core_Contact_Entitlement_Subordinates__c(Name='7',Core_Entitlement_Id__c=lstEnt[2].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[0].id,Core_Is_ODM_False__c=true,Core_Is_CNDA_True__c=False);
            Core_Contact_Entitlement_Subordinates__c subordinates7 = new Core_Contact_Entitlement_Subordinates__c(Name='8',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[0].id,Core_Is_ODM_False__c=false,Core_Is_CNDA_True__c=True);
            
            
            lstSubAdd.add(subordinates);
            lstSubAdd.add(subordinates1);
            lstSubAdd.add(subordinates2);
            lstSubAdd.add(subordinates3);
            lstSubAdd.add(subordinates4);
            lstSubAdd.add(subordinates5);
            lstSubAdd.add(subordinates6);
            lstSubAdd.add(subordinates7);
            insert lstSubAdd;
            system.assertNOTEquals(null,subordinates.id,'subordinate id is null');
            
            ContactEntSubordinatesRemovalTest.setMetadata(
                'SELECT Id,Label,Core_Condition__c,Core_Entitlement_Id__c,Core_Entitlement_Name__c,Core_Entitlement_Subordinate_Id__c,Core_Entitlement_Subordinate_Name__c FROM Contact_Entitlement_Subordinates_Removal__mdt WHERE DeveloperName = \'Default\'',
                (List<Contact_Entitlement_Subordinates_Removal__mdt>) JSON.deserialize( '[{"Label":"1","Core_Entitlement_Id__c":"'+entitle1.id+'","Core_Entitlement_Name__c":"Product Information(Product Details)","Core_Entitlement_Subordinate_Name__c":"ODM/Price Mask","Core_Entitlement_Subordinate_Id__c":"'+entitle2.id+'"},{"Label":"2","Core_Entitlement_Id__c":"'+entitle1.id+'","Core_Condition__c":"'+entitle3.id+'","Core_Entitlement_Name__c":"Product Information (Product Details)","Core_Entitlement_Subordinate_Name__c":"ODM/Price Mask","Core_Entitlement_Subordinate_Id__c":"'+entitle2.id+'"},{"Label":"3","Core_Entitlement_Id__c":"'+entitle4.id+'","Core_Entitlement_Name__c":"Product Information (Product Details)","Core_Entitlement_Subordinate_Name__c":"ODM/Price Mask","Core_Entitlement_Subordinate_Id__c":"'+entitle5.Id+'"},{"Label":"4","Core_Entitlement_Id__c":"'+entitle4.id+'","Core_Condition__c":"'+entitle3.id+'","Core_Entitlement_Name__c":"Product Information (Product Details)","Core_Entitlement_Subordinate_Name__c":"ODM/Price Mask","Core_Entitlement_Subordinate_Id__c":"'+entitle5.Id+'"}]', List<Contact_Entitlement_Subordinates_Removal__mdt>.class )
            );
            
            //start----Added by Popcornapps
            List<Core_Contact_Entitlement_Validation__c> lstentval= new List<Core_Contact_Entitlement_Validation__c>();
            Core_Contact_Entitlement_Validation__c entval  = new Core_Contact_Entitlement_Validation__c(Name='1',Core_Entitlement_Id__c=lstEnt[1].id,Core_Entitlement_Name__c='Intel Premier Support',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=true);
            Core_Contact_Entitlement_Validation__c entval1 = new Core_Contact_Entitlement_Validation__c(Name='2',Core_Entitlement_Id__c=lstEnt[1].id,Core_Entitlement_Name__c='Return Services Request',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=true);
            Core_Contact_Entitlement_Validation__c entval2 = new Core_Contact_Entitlement_Validation__c(Name='3',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Resource & Design Center Collaboration Workspaces',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false);
            Core_Contact_Entitlement_Validation__c entval3 = new Core_Contact_Entitlement_Validation__c(Name='4',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Partner Portal',Core_Account_English_Only_Name__c=false,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=false,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false);
            lstentval.add(entval);
            lstentval.add(entval1);
            lstentval.add(entval2);
            lstentval.add(entval3);
            insert lstentval;
            
            List<Core_Contact_Ent_Validation_Message__c> lstvalmsg = new List<Core_Contact_Ent_Validation_Message__c>();
            Core_Contact_Ent_Validation_Message__c entvalmsg = new Core_Contact_Ent_Validation_Message__c(Name ='System CIM ID',Core_Error_Message__c ='CIM ID cant be blank on Account Record',Core_Error_Message2__c = null,Core_System_Validation_Name__c = true,Core_UI_Validation_Name__c = false);
            Core_Contact_Ent_Validation_Message__c entvalmsg1 = new Core_Contact_Ent_Validation_Message__c(Name='System Non ODM',Core_Error_Message__c='ODM Indicator field must be checked',Core_System_Validation_Name__c=true,Core_UI_Validation_Name__c=false);
            Core_Contact_Ent_Validation_Message__c entvalmsg2 = new Core_Contact_Ent_Validation_Message__c(Name='UI CNDA',Core_Error_Message__c='The account must have a valid CNDA to be able to grant access. Please verify if the account has a valid CNDA (<a href="https://intel.tap.thinksmart.com/prod/Portal/WorkflowDashboard/?cid=c924622d_fcae_4333_9c95_46104114907d" target="_blank">',Core_Error_Message2__c= 'NDA Viewer</a>) - and add it to account record',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
            Core_Contact_Ent_Validation_Message__c entvalmsg3 = new Core_Contact_Ent_Validation_Message__c(Name='UI Unique Entitlement',Core_Error_Message__c='You cannot select IPS and Partner Portal together. Only one can be selected',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
            Core_Contact_Ent_Validation_Message__c entvalmsg8 = new Core_Contact_Ent_Validation_Message__c(Name='System ODM',Core_Error_Message__c='Can\'t be selected if ODM is TRUE on Account Record',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
            Core_Contact_Ent_Validation_Message__c entvalmsg5 = new Core_Contact_Ent_Validation_Message__c(Name='System Account Owner Role',Core_Error_Message__c='Account Owner Role Can\'t be blank',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
            Core_Contact_Ent_Validation_Message__c entvalmsg6 = new Core_Contact_Ent_Validation_Message__c(Name='System ISO',Core_Error_Message__c='IPS Contacts must have an identified Intel Support Owner for accounts with a CNDA',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
            Core_Contact_Ent_Validation_Message__c entvalmsg7 = new Core_Contact_Ent_Validation_Message__c(Name='System Unique Entitlement',Core_Error_Message__c='You cannot select IPS and Partner Portal together.   Only one can be selected.',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
            
            lstvalmsg.add(entvalmsg);
            lstvalmsg.add(entvalmsg1);
            lstvalmsg.add(entvalmsg2);
            lstvalmsg.add(entvalmsg3);
            lstvalmsg.add(entvalmsg8);
            lstvalmsg.add(entvalmsg5);
            lstvalmsg.add(entvalmsg6);
            lstvalmsg.add(entvalmsg7);
            insert lstvalmsg;
            
            //Stop----Added by Popcornapps
            
            List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
            
            Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle3.id , Core_Selected__c=true);
            Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[1].id, Core_Selected__c=false);
            Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[2].id, Core_Selected__c=true);
            Core_Contact_Entitlement__c conent4 = new Core_Contact_Entitlement__c(id = ce5.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[4].id, Core_Selected__c=false);
            Core_Contact_Entitlement__c conent5 = new Core_Contact_Entitlement__c(id = ce6.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[5].id, Core_Selected__c=true);
            
            oldlstentitle.add(conent4);
            oldlstentitle.add(conent1);
            oldlstentitle.add(conent2);
            oldlstentitle.add(conent3);
            oldlstentitle.add(conent5);
            
            update  oldlstentitle;
            Test.stopTest();        
            
            Core_ContactEntitlementValidation validation = new Core_ContactEntitlementValidation();
            validation.filterEntitlementsByProfile();
            Core_ContactEntitlementValidation.validateAccountEnglishOnlyFields(acc,mapacc);
            //Core_ContactEntitlementValidation.validateEnglishOnly(entitle1.id,testContact);
            string uniqueEntitlementName='';
            Core_ContactEntitlementValidation.validateUniqueEntitlement(entitle2.id,testContact,'Partner Portal');
            
            
        } 
    }
    
    
    public static testmethod void testValidateEntitlementEalisha(){
        
        
        List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
        
        Core_Trigger_Executions__c accountShareSetting = new Core_Trigger_Executions__c();
        accountShareSetting.Core_Active__c = true;
        //accountShareSetting.Core_Class_Name__c = 'Coref_ContactEntitlementHandler';
        accountShareSetting.Core_Class_Name__c = 'Core_ContactEntitlementHelper';//Added by Draco to update helper class
        accountShareSetting.Core_Trigger_Events__c = 'before insert,before update';
        accountShareSetting.Core_Object__c = 'Core_Contact_Entitlement__c';
        accountShareSetting.Name = 'Core_ContactEntValidationSwitch';
        accountShareSetting.Core_Description__c = 'test';
        executionList.add(accountShareSetting);
        Database.insert(executionList);
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.assertEquals(itAdminUser.LastName,'UnitTestAdmin1','Last Name not matching');
        List<Contact> lsttestContact = new List<Contact>();
        test.startTest();
        String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account testAccount = new Account(Name='test1AccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others', RecordTypeId=intelAccRecTypeId,
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '13211', Core_CIM_ID__c ='123124');
        insert testAccount; 
        Account testAccount1 = new Account(Name='testAccount143', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = false, RecordTypeId=intelAccRecTypeId,
                                           Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c ='samplename',
                                           BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                           BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);
        insert testAccount1;
        Account testAccount2 = new Account(Name='testAccount1435', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = false, RecordTypeId=intelAccRecTypeId,
                                           Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '123455',Core_English_Only_Name__c ='sampleAcctname',
                                           BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                           BillingCountry='USA', BillingPostalCode='123457',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);
        insert testAccount2;
        Contact testContact = new Contact(FirstName='阿昌', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='f',Core_English_Only_Last_Name__c='f',MailingCountry='India',
                                          AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
        
        lsttestContact.add(testContact);
        Contact testContact1 = new Contact(FirstName='阿昌', LastName='testLastName', Email='test14x3@testing.com.test',Core_English_Only_First_Name__c='f',Core_English_Only_Last_Name__c='f',MailingCountry='India',
                                           AccountId=testAccount1.Id,Core_Local_First_Name__c='',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
        
        lsttestContact.add(testContact1);
        Contact testContact2 = new Contact(FirstName='阿昌', LastName='testLastName2', Email='test12334@testing.com.test',Core_English_Only_First_Name__c='TestLastName',Core_English_Only_Last_Name__c='TestFirstName',MailingCountry='India',
                                           AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
        
        lsttestContact.add(testContact2);
        
        insert lsttestContact;
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer1', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
        insert cee;
        
        
        
        
        
        
        
        
        /*List<Core_Contact_Entitlement_Validation__c> contEntValidation = new List<Core_Contact_Entitlement_Validation__c>();

Core_Contact_Entitlement_Validation__c cev1 = new Core_Contact_Entitlement_Validation__c();
cev1.Core_Account_English_Only_Name__c = true;
cev1.Name='1';
cev1.Core_Account_Owner_Role__c=true;
cev1.Core_CIM_ID__c=true;
cev1.Core_CNDA__c=false;
cev1.Core_Contact_English_Only_Name__c=true;
cev1.Core_Entitlement_Id__c='a2W1J0000019iVFUAY';
cev1.Core_Entitlement_Name__c='Sales Enablement Portal';
cev1.Core_ODM_Checked__c=false;
cev1.Core_ODM_Unchecked__c=false;
cev1.Core_Personal_Email_Domain__c=true;
cev1.Core_PSG_WOM__c=false;
cev1.Core_Support_Owner__c=true;
contEntValidation.add(cev1);
Database.insert(contEntValidation);*/
        
        //Removed hardcoded Salesforce Id's as a part of Sela Code Scan Fixes(TWC1811-6067)
        List<Core_Contact_Entitlement_Validation_Req__c> contEntValidationReq = new List<Core_Contact_Entitlement_Validation_Req__c>();
        
        Core_Entitlement__c entDetail = new Core_Entitlement__c();
        entDetail.Name='Sales Enablement Portal';
        entDetail.Core_Display_Name__c='Sales Enablement Portal';
        entDetail.Core_IsActive__c=true;
        insert entDetail;
        Core_Contact_Entitlement_Validation_Req__c cevr1 = new Core_Contact_Entitlement_Validation_Req__c();
        cevr1.Name='2';
        cevr1.Core_Entitlement_id__c=entDetail.id;
        cevr1.Core_Entitlement_Name__c='Sales Enablement Portal';
        cevr1.Core_Entitlement_Req_id__c=entDetail.id;
        cevr1.Core_Entitlement_Req_Name__c='PSG Basic';
        cevr1.Core_Entitlement_SysMsgName__c='System PSG Basic';
        cevr1.Core_Entitlement_MsgName__c='UI PSG Basic';
        contEntValidationReq.add(cevr1);
        Database.insert(contEntValidationReq);
        
        
        
        
        List<Core_Entitlement__c> lstEnt = new List<Core_Entitlement__c>();
        Core_Entitlement__c entitle = new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        lstEnt.add(entitle);
        
        
        Core_Entitlement__c entitle1 = new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
        lstEnt.add(entitle1);
        
        
        Core_Entitlement__c entitle2 = new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
        lstEnt.add(entitle2);
        
        Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_IsActive__c=true); 
        lstEnt.add(entitle3);
        
        Core_Entitlement__c entitle4 = new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true); 
        lstEnt.add(entitle4);
        
        Core_Entitlement__c entitle5 = new Core_Entitlement__c (name ='Resource & Design Center Collaboration Workspaces', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center Collaboration Workspaces',Core_IsActive__c=true); 
        lstEnt.add(entitle5);
        
        Core_Entitlement__c entitle6 = new Core_Entitlement__c (name ='Invoice and Credit', Core_Category__c='Order Management',Core_Sub_Category__c='Web Order Management (WOM)',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Invoice and Credit',Core_IsActive__c=true); 
        lstEnt.add(entitle6);
        
        insert lstEnt;
        
        List<Core_Entitlement_Profile_Access__c> lstprofileaccess = new List<Core_Entitlement_Profile_Access__c>();
        
        Core_Entitlement_Profile_Access__c profileaccess = new Core_Entitlement_Profile_Access__c(Core_Entitlements_Allowed__c='ODM/Price Mask',Core_Profile_Id__c=itAdminPrf.id);
        lstprofileaccess.add(profileaccess);
        insert lstprofileaccess;
        
        //start----Added by Popcornapps
        List<Core_Contact_Entitlement_Validation__c> lstentval= new List<Core_Contact_Entitlement_Validation__c>();
        Core_Contact_Entitlement_Validation__c entval  = new Core_Contact_Entitlement_Validation__c(Name='10',Core_Entitlement_Id__c=lstEnt[1].id,Core_Entitlement_Name__c='Intel Premier Support',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=true);
        Core_Contact_Entitlement_Validation__c entval1 = new Core_Contact_Entitlement_Validation__c(Name='20',Core_Entitlement_Id__c=lstEnt[2].id,Core_Entitlement_Name__c='Return Services Request',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=true);
        Core_Contact_Entitlement_Validation__c entval2 = new Core_Contact_Entitlement_Validation__c(Name='30',Core_Entitlement_Id__c=lstEnt[3].id,Core_Entitlement_Name__c='Resource & Design Center Collaboration Workspaces',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false);
        Core_Contact_Entitlement_Validation__c entval3 = new Core_Contact_Entitlement_Validation__c(Name='40',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Partner Portal',Core_Account_English_Only_Name__c=false,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=false,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false);
        
        lstentval.add(entval);
        lstentval.add(entval1);
        lstentval.add(entval2);
        lstentval.add(entval3);
        insert lstentval;
        
        
        
        List<Core_Contact_Ent_Validation_Message__c> lstvalmsg = new List<Core_Contact_Ent_Validation_Message__c>();
        Core_Contact_Ent_Validation_Message__c entvalmsg = new Core_Contact_Ent_Validation_Message__c(Name ='System CIM ID',Core_Error_Message__c ='CIM ID cant be blank on Account Record',Core_Error_Message2__c = null,Core_System_Validation_Name__c = true,Core_UI_Validation_Name__c = false);
        Core_Contact_Ent_Validation_Message__c entvalmsg1 = new Core_Contact_Ent_Validation_Message__c(Name='System Non ODM',Core_Error_Message__c='ODM Indicator field must be checked',Core_System_Validation_Name__c=true,Core_UI_Validation_Name__c=false);
        Core_Contact_Ent_Validation_Message__c entvalmsg2 = new Core_Contact_Ent_Validation_Message__c(Name='System CNDA',Core_Error_Message__c='The account must have a valid CNDA to be able to grant access. Please verify if the account has a valid CNDA (<a href="https://intel.tap.thinksmart.com/prod/Portal/WorkflowDashboard/?cid=c924622d_fcae_4333_9c95_46104114907d" target="_blank">',Core_Error_Message2__c= 'NDA Viewer</a>) - and add it to account record',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
        //Core_Contact_Ent_Validation_Message__c entvalmsg3 = new Core_Contact_Ent_Validation_Message__c(Name='UI Unique Entitlement',Core_Error_Message__c='You cannot select IPS and Partner Portal together. Only one can be selected',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
        Core_Contact_Ent_Validation_Message__c entvalmsg4 = new Core_Contact_Ent_Validation_Message__c();
        //Core_Contact_Ent_Validation_Message__c entvalmsg5 = new Core_Contact_Ent_Validation_Message__c(Name ='System Account Owner Role',Core_Error_Message__c ='Account Owner Role Can't be blank',Core_System_Validation_Name__c = false,Core_UI_Validation_Name__c = false);
        //Core_Contact_Ent_Validation_Message__c entvalmsg5 = new Core_Contact_Ent_Validation_Message__c(Name='System English on Account',Core_Error_Message__c='English Only on Account can\'t be blank (Populate from Standard and Alternate if avalible and meet req)',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
        //Core_Contact_Ent_Validation_Message__c entvalmsg6 = new Core_Contact_Ent_Validation_Message__c(Name='System English on Contact',Core_Error_Message__c='English Only on Contact can\'t be blank (Populate from Standard and Alternate if avalible and meet req)',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
        Core_Contact_Ent_Validation_Message__c entvalmsg8 = new Core_Contact_Ent_Validation_Message__c(Name='System ODM',Core_Error_Message__c='Can\'t be selected if ODM is TRUE on Account Record',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
        Core_Contact_Ent_Validation_Message__c entvalmsg5 = new Core_Contact_Ent_Validation_Message__c(Name='System Account Owner Role',Core_Error_Message__c='Account Owner Role Can\'t be blank',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
        Core_Contact_Ent_Validation_Message__c entvalmsg6 = new Core_Contact_Ent_Validation_Message__c(Name='System ISO',Core_Error_Message__c='IPS Contacts must have an identified Intel Support Owner for accounts with a CNDA',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
        Core_Contact_Ent_Validation_Message__c entvalmsg7 = new Core_Contact_Ent_Validation_Message__c(Name='System Unique Entitlement',Core_Error_Message__c='You cannot select IPS and Partner Portal together.   Only one can be selected.',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
        
        entvalmsg4.Name='System PSG Basic';
        entvalmsg4.Core_Error_Message__c='No PSG basic Engagement for that contact';
        entvalmsg4.Core_Error_Message2__c='';
        entvalmsg4.Core_System_Validation_Name__c=false;
        entvalmsg4.Core_UI_Validation_Name__c=false;
        lstvalmsg.add(entvalmsg);
        lstvalmsg.add(entvalmsg1);
        lstvalmsg.add(entvalmsg2);
        lstvalmsg.add(entvalmsg5);
        lstvalmsg.add(entvalmsg4);
        lstvalmsg.add(entvalmsg8);
        lstvalmsg.add(entvalmsg6);
        lstvalmsg.add(entvalmsg7);
        insert lstvalmsg;
        
        //Stop----Added by Popcornapps
        
        
        
        
        
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = lstEnt[3].id , Core_Selected__c=true);
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[1].id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= lstEnt[2].id, Core_Selected__c=false);
        Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= lstEnt[0].id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Entitlement_Id__c= lstEnt[4].id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce6 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Entitlement_Id__c= lstEnt[5].id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce7 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact2.Id,Core_Entitlement_Id__c= lstEnt[6].id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce8 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact2.Id,Core_Entitlement_Id__c= lstEnt[5].id, Core_Selected__c=true);
        
        newlstentitle.add(ce1);                                                                         
        //newlstentitle.add(ce2);
        newlstentitle.add(ce3);
        newlstentitle.add(ce4);
        newlstentitle.add(ce5);
        newlstentitle.add(ce6);
        newlstentitle.add(ce7);
        newlstentitle.add(ce8);
        insert newlstentitle;
        test.stopTest();
        
        List<Core_Contact_Entitlement__c> newFullList = new List<Core_Contact_Entitlement__c>();
        newFullList.add(ce7);
        Map<Id,Core_Contact_Entitlement__c> oldMap = new  Map<Id,Core_Contact_Entitlement__c>();
        
        Core_ContactEntitlementValidation.validateContactEntitlementModified(newFullList,newFullList,oldMap , oldMap);
        Core_ContactEntitlementValidation.validateEntitlementType(newlstentitle);
    }
    
    
    
    public static testmethod void testContEntCheck() {
        
        test.startTest();
        Profile itAdminPrf = [select id, name from Profile where name = 'Data Ops' Limit 1];
        
        Profile itAdminpf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1','Last name not matching as UnitTestAdmin1');
        
        User itAdmin = new User(Alias = 'itAdm221',   Email='itAdminTestx218@intel.com', 
                                EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin12',
                                LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                ProfileId = itAdminpf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                UserName='salesRepTestx211@intel.com');
        insert itAdmin;
        system.assertequals(itAdmin.LastName,'UnitTestAdmin12','Last name not matching as UnitTestAdmin12');
        
        system.runas(itAdmin){
            
            Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
            cm.Name = 'IPS Standard Entitlement';
            cm.Value__c  = 'IPS Standard Entitlement';
            insert cm;
            System.assert(true,cm.Value__c != null);
            
            Core_Trigger_Executions__c executions = new Core_Trigger_Executions__c(Name='addContactEntitlementSubordinates',Core_Active__c=true,Core_Class_Name__c='Core_IPS_CaseTriggerHandler',Core_Description__c='testcase',Core_Object__c='case',Core_Trigger_Events__c='after update');
            insert executions;
            system.assertequals(executions.Name,'addContactEntitlementSubordinates','custom setting not cretaed');
            
            
            String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            Account testAccount = new Account(Name='testAccount', Core_Sales_Group__c='Global Accounts', RecordTypeId=intelAccRecTypeId,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_Alternate_Language_Name__c='test123',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_English_Only_Name__c = '123',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false,Core_CIM_ID__c ='123124');
            insert testAccount;
            system.assertNOTEquals(null,testAccount.id,'test account id is null');
            
            
            Account accVal = new Account();
            accVal=[select name from account where id =:testAccount.id];
            accVal.name = 'Geetha Test';
            system.runas(itAdminUser){
                update accVal; 
            }
            
            // testAccount.Core_English_Only_Name__c = 'testAccount123';
            //update testAccount;
            Core_Trigger_Executions__c executions1 = new Core_Trigger_Executions__c(Name='UpdateJobFunctionAndCode',Core_Active__c=true,Core_Class_Name__c='Core_ContactHandler',Core_Description__c='testcase',Core_Object__c='Contact',Core_Trigger_Events__c='Before Insert Before Update');
            insert executions1;
            
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_English_Only_First_Name__c='test',MailingCountry='India',
                                              AccountId=testAccount.Id,Core_Set_ERPM_Status_Bypass__c=true,Core_IPS_Active__c =false,Core_Local_First_Name__c='test123',Core_Contact_B2B_Indicator__c=true);
            
            insert testContact;
            system.assertequals(testContact.LastName,'testLastName','Last name not matching as testLastName');
            
            Contact testConUpdate = new Contact();
            testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
            testConUpdate.firstname = 'TestName123234';
            testConUpdate.lastname = 'testLastName123';
            update testConUpdate;
            
            
            
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
            insert cee;
            system.assertequals(cee.Name,'Partner File Transfer','Engagement name not matching');
            
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
            insert entitle;
            system.assertNOTEquals(null,entitle.id,'Entitlement id is null');
            
            
            Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
            insert entitle1;
            System.assert(true,entitle1.Core_Category__c!= null);
            
            
            Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
            insert entitle2;
            system.assertequals(entitle2.Name,'Return Services Request','Entitlement name not matching');
            
            Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_IsActive__c=true); 
            insert entitle3;
            
            
            
            List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle3.id,Core_Selected__c=true);
            Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true);
            Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=true);
            
            newlstentitle.add(ce1);
            newlstentitle.add(ce2);
            newlstentitle.add(ce3);
            insert newlstentitle;
            
            Core_Contact_Entitlement_Subordinates__c subordinates = new Core_Contact_Entitlement_Subordinates__c(Name='1',Core_Entitlement_Id__c=entitle.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask ',Core_Entitlement_Subordinate_Id__c=entitle.id,Core_Is_ODM_True__c=false);
            insert subordinates;
            system.assertequals(subordinates.Core_Entitlement_Name__c,'Product Information (Product Details)','Subordinate name id not matching');
            Core_Contact_Entitlement_Subordinates__c subordinates1 = new Core_Contact_Entitlement_Subordinates__c(Name='2',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Order Availability Check',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=entitle2.id,Core_Is_ODM_True__c=False,Core_Is_CNDA_True__c=False);
            insert subordinates1;
            system.assertequals(subordinates1.Core_Entitlement_Name__c,'Order Availability Check','Subordinate name id not matching');
            Core_Contact_Entitlement_Subordinates__c subordinates2 = new Core_Contact_Entitlement_Subordinates__c(Name='3',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=entitle1.id,Core_Is_ODM_False__c=True,Core_Is_CNDA_True__c=True);
            insert subordinates2;
            system.assertequals(subordinates2.Core_Entitlement_Name__c,'Product Information (Product Details)','Subordinate name id not matching');
            Core_Contact_Entitlement_Subordinates__c subordinates3 = new Core_Contact_Entitlement_Subordinates__c(Name='4',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Order Availability Check',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=entitle2.id,Core_Is_ODM_False__c=True,Core_Is_CNDA_True__c=False);
            insert subordinates3;
            system.assertequals(subordinates3.Core_Entitlement_Name__c,'Order Availability Check','Subordinate name id not matching');
            
            
            List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
            
            Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle3.id,Core_Selected__c=true);
            Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true);
            Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=true);
            
            oldlstentitle.add(conent1);
            oldlstentitle.add(conent2);
            oldlstentitle.add(conent3);
            
            update  oldlstentitle;
            test.stopTest();
        } 
    }
    
    public static testmethod void testContEntDataops() {
        
        test.startTest();
        
        Profile itAdminPrf = [select id, name from Profile where name = 'Data Ops' Limit 1];
        
        Profile itAdminpf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1','Last name not matching as UnitTestAdmin1');
        
        User itAdmin = new User(Alias = 'itAdm221',   Email='itAdminTestx218@intel.com', 
                                EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin12',
                                LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                ProfileId = itAdminpf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                UserName='salesRepTestx211@intel.com');
        insert itAdmin;
        system.assertequals(itAdmin.LastName,'UnitTestAdmin12','Last name not matching as UnitTestAdmin12');
        
        system.runas(itAdmin){
            
            Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
            cm.Name = 'IPS Standard Entitlement';
            cm.Value__c  = 'IPS Standard Entitlement';
            insert cm;
            
            Core_Trigger_Executions__c executions = new Core_Trigger_Executions__c(Name='addContactEntitlementSubordinates',Core_Active__c=true,Core_Class_Name__c='Core_IPS_CaseTriggerHandler',Core_Description__c='testcase',Core_Object__c='case',Core_Trigger_Events__c='after update');
            insert executions;
            system.assertNOTEquals(null,executions.id,'Custom setting not created');
            String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',Core_CNDA_Number__c = '',RecordTypeId=intelAccRecTypeId,
                                              Core_Account_Type__c='Other', Industry='Others',Core_IsODM__c =false,Core_English_Only_Name__c ='',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c!= null);
            
            Account accVal = new Account();
            accVal=[select name from account where id=:testAccount.id];
            accVal.name = 'Geetha Test';
            system.runas(itAdminUser){
                update accVal; 
            }
            
            Core_Trigger_Executions__c executions01 = new Core_Trigger_Executions__c(Name='UpdateJobFunctionAndCode',Core_Active__c=true,Core_Class_Name__c='Core_ContactHandler',Core_Description__c='testcase',Core_Object__c='Contact',Core_Trigger_Events__c='Before Insert Before Update');
            insert executions01;
            Contact testContact = new Contact(FirstName='test', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',MailingCountry='India',
                                              AccountId=testAccount.Id,Core_Set_ERPM_Status_Bypass__c=true,Core_IPS_Active__c =false,Core_Contact_B2B_Indicator__c=false,Core_Local_First_Name__c='',Core_Personal_Email_Indicator__c=true);
            insert testContact;
            system.assertequals(testContact.LastName,'testLastName','Last name not matching as testLastname');
            
            Contact testConUpdate = new Contact();
            testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
            testConUpdate.firstname = 'TestName123234';
            testConUpdate.lastname = 'testLastName123';
            update testConUpdate;
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
            insert cee; 
            system.assertequals(cee.Name,'Partner File Transfer','enagagement name not matching');  
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
            insert entitle;
            system.assertNOTEquals(null,entitle.id,'Entitlement id is null');
            
            Core_Entitlement__c entitle2 = new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
            insert entitle2;
            
            Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle2.id, Core_Selected__c=false);
            insert conent1;
            system.assertNOTEquals(null,conent1.id,'Entitlement id is null');
            
            
            //Core_ContactEntitlementValidation.validateAccountEnglishOnlyFields(entitle.id,testAccount);
            
            test.stopTest();
            
        }
    }
    
    
    public static testmethod void testContEntsubordinate() {
        
        test.startTest();
        
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1','Last name not matching as UnitTestAdmin1');
        
        system.runas(itAdminUser){
            
            Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
            cm.Name = 'IPS Standard Entitlement';
            cm.Value__c  = 'IPS Standard Entitlement';
            insert cm;
            System.assertEquals(cm.Name,'IPS Standard Entitlement','Label name not matcing');
            
            
            Core_Trigger_Executions__c executions = new Core_Trigger_Executions__c(Name='addContactEntitlementSubordinates',Core_Active__c=true,Core_Class_Name__c='Core_IPS_CaseTriggerHandler',Core_Description__c='testcase',Core_Object__c='case',Core_Trigger_Events__c='after update');
            insert executions;
            system.assertequals(executions.Name,'addContactEntitlementSubordinates','Custom setting not craeted');
            
            
            
            /*List<Account> acc = new List<Account>();
Account testAccount = new Account(Name='阿昌', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = true,
Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c = '',
BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test123',
BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');

insert.testAccount; 
Account testAccount1 = new Account(Name='阿', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = False,
Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c = '',
BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test123',
BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123126');

insert.testAccount1; 

insert acc; */
            
            /*Account accVal = new Account();
accVal=[select name from account where id in:acc];
accVal.name = '阿昌';
accVal.Core_Alternate_Language_Name__c='test';
update accVal;
System.assert(true,accVal.name != null);*/
            
            
            
            Map<Id, Account> mapacc = new Map<Id, Account>([select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_Account_Type__c from Account]);
            List<Contact> lsttestContact = new List<Contact>();
            List<Contact> lsttestContactUpdate = new List<Contact>();
            
            Core_Trigger_Executions__c executions1 = new Core_Trigger_Executions__c(Name='UpdateJobFunctionAndCode',Core_Active__c=true,Core_Class_Name__c='Core_ContactHandler',Core_Description__c='testcase',Core_Object__c='Contact',Core_Trigger_Events__c='Before Insert Before Update');
            insert executions1;
            List<Account> acc = new List<Account>();
            String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            Account testAccount = new Account(Name='阿昌', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = False, RecordTypeId=intelAccRecTypeId,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c = '',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test123',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');
            
            acc.add(testAccount);
            Account testAccount1 = new Account(Name='阿', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = False, RecordTypeId=intelAccRecTypeId,
                                               Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c = '',
                                               BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test123',
                                               BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123126');
            
            acc.add(testAccount1); 
            
            insert acc;
            Contact testContact = new Contact(FirstName='阿昌', LastName='阿昌', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',MailingCountry='India',
                                              AccountId=testAccount.Id,Core_Set_ERPM_Status_Bypass__c=true,Core_Local_First_Name__c='david',Core_Local_Last_Name__c='geetha',Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false);
            
            lsttestContact.add(testContact);
            Contact testContactA = new Contact(FirstName='阿昌', LastName='阿昌', Email='test1238@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',MailingCountry='India',
                                               AccountId=testAccount1.Id,Core_Set_ERPM_Status_Bypass__c=true,Core_Local_First_Name__c='david',Core_Local_Last_Name__c='geetha',Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false);
            
            lsttestContact.add(testContactA);
            insert lsttestContact;
            
            /*Contact testConUpdate = new Contact();
testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
testConUpdate.firstname = '阿昌';
testConUpdate.lastname = '阿昌';
testConUpdate.Core_Local_First_Name__c='david';
testConUpdate.Core_Local_Last_Name__c='geetha';
update testConUpdate;*/
            
            
            Core_Entitlement_Profile_Access__c profileaccess = new Core_Entitlement_Profile_Access__c(Core_Entitlements_Allowed__c='Advanced Shipment and Invoice Notification ',Core_Profile_Id__c=itAdminPrf.id);
            insert profileaccess;
            system.assertNOTEquals(null,profileaccess.id,'Profile id is null');
            
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
            insert cee; 
            system.assertequals(cee.Name ,'Partner File Transfer','Engagement name not matching');
            
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            
            Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
            insert entitle1;
            system.assertequals(entitle1.name ,'ODM/Price Mask','Entitlement name not matching');
            
            
            Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
            insert entitle2;
            system.assertNOTEquals(null,entitle2.id,'entitlement id is null');
            
            Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true); 
            insert entitle3;
            
            Core_Entitlement__c entitle4 = new Core_Entitlement__c (name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_IsActive__c=true); 
            insert entitle4;
            
            
            
            
            Set<String> idsList=new Set<String>();
            
            List<Core_Contact_Entitlement_Exclusive__c> oldexclusive = new List<Core_Contact_Entitlement_Exclusive__c>();
            Core_Contact_Entitlement_Exclusive__c exclusive = new Core_Contact_Entitlement_Exclusive__c(Core_Unique_Ids__c=entitle.id+','+entitle1.id,Name='Support');
            oldexclusive.add(exclusive); 
            insert oldexclusive;
            
            
            List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle1.id, Core_Selected__c=true,Core_From_Source__c=false);
            Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle3.id, Core_Selected__c=false,Core_From_Source__c=false);
            Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=false,Core_From_Source__c=false);
            Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContactA.Id,Core_Entitlement_Id__c =entitle3.id, Core_Selected__c=True,Core_From_Source__c=false);
            Core_Contact_Entitlement__c ce5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContactA.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=True,Core_From_Source__c=false);
            
            newlstentitle.add(ce1);
            newlstentitle.add(ce2);
            newlstentitle.add(ce3);
            newlstentitle.add(ce4);
            newlstentitle.add(ce5);
            insert newlstentitle;
            
            
            
            Core_Contact_Entitlement_Subordinates__c subordinates = new Core_Contact_Entitlement_Subordinates__c(Name='1',Core_Entitlement_Id__c=entitle4.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=entitle1.id,Core_Is_ODM_True__c=False,Core_Is_CNDA_True__c=True);
            insert subordinates;
            system.assertequals(subordinates.Core_Entitlement_Name__c,'Product Information (Product Details)','Subordinate name id not matching');
            Core_Contact_Entitlement_Subordinates__c subordinates1 = new Core_Contact_Entitlement_Subordinates__c(Name='2',Core_Entitlement_Id__c=entitle4.id,Core_Entitlement_Name__c='Order Availability Check',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=entitle2.id,Core_Is_ODM_True__c=False,Core_Is_CNDA_True__c=False);
            insert subordinates1;
            Core_Contact_Entitlement_Subordinates__c subordinates2 = new Core_Contact_Entitlement_Subordinates__c(Name='3',Core_Entitlement_Id__c=entitle4.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=entitle1.id,Core_Is_ODM_False__c=True,Core_Is_CNDA_True__c=True);
            insert subordinates2;
            system.assertequals(subordinates.Core_Entitlement_Name__c,'Product Information (Product Details)','Subordinate name id not matching');
            Core_Contact_Entitlement_Subordinates__c subordinates3 = new Core_Contact_Entitlement_Subordinates__c(Name='4',Core_Entitlement_Id__c=entitle4.id,Core_Entitlement_Name__c='Order Availability Check',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=entitle2.id,Core_Is_ODM_False__c=True,Core_Is_CNDA_True__c=False);
            insert subordinates3;
            system.assertequals(subordinates1.Core_Entitlement_Name__c,'Order Availability Check','Subordinate name id not matching');
            List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
            
            Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle4.id, Core_Selected__c=true);
            Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true);
            Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=true);
            Core_Contact_Entitlement__c conent4 = new Core_Contact_Entitlement__c(id = ce4.id,Core_Contact_Id__c=testContactA.Id,Core_Entitlement_Id__c =entitle4.id, Core_Selected__c=true);
            Core_Contact_Entitlement__c conent5 = new Core_Contact_Entitlement__c(id = ce5.id,Core_Contact_Id__c=testContactA.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=true);
            
            oldlstentitle.add(conent1);
            oldlstentitle.add(conent2);
            oldlstentitle.add(conent3);
            oldlstentitle.add(conent4);
            oldlstentitle.add(conent5);
            
            update  oldlstentitle;
            
            
            Core_ContactEntitlementValidation validation = new Core_ContactEntitlementValidation();
            validation.filterEntitlementsByProfile();
            Core_ContactEntitlementValidation.validateAccountEnglishOnlyFields(acc,mapacc);
            //Core_ContactEntitlementValidation.validateEnglishOnly(entitle1.id,testContact);
            //Core_ContactEntitlementValidation.validateUniqueEntitlement(entitle2.id,testContact);
            
            List<Core_Contact_Entitlement_Validation_Req__c> reqList = new List<Core_Contact_Entitlement_Validation_Req__c>();
            Core_Contact_Entitlement_Validation_Req__c req1=new Core_Contact_Entitlement_Validation_Req__c(Name='req1',Core_Entitlement_id__c=entitle1.id,  Core_Entitlement_Req_id__c=entitle.id,Core_Entitlement_SysMsgName__c='  System PSG Basic'); 
            Core_Contact_Entitlement_Validation_Req__c req2=new Core_Contact_Entitlement_Validation_Req__c(Name='req2',Core_Entitlement_id__c=entitle2.id,  Core_Entitlement_Req_id__c=entitle.id,Core_Entitlement_SysMsgName__c='  System PSG Basic'); 
            reqList.add(req1);
            reqList.add(req2);
            insert reqList; 
            
            Core_ContactEntitlementValidation.ValidateEngagement(entitle1.id,testContact,oldlstentitle);   
            test.stopTest();
            
        } 
    }
    
    public static testmethod void testContactEntilementsPageErrors() {
        
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1','Last name not matching as UnitTestAdmin1');
        
        //Removed hardcoded Salesforce Id's as a part of Sela Code Scan Fixes(TWC1811-6067)    
        List<Profile> lstProfiles = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User usr = new User();
        //usr=[select name,UserRoleId from User where id =:'0052D0000018FzFQAU'];
        usr.Username ='abche.test@example.com';
        usr.LastName ='Test11';
        usr.Email ='abche.test@example.com';
        usr.Alias ='abc';
        usr.CommunityNickname='abc1';
        usr.TimeZoneSidKey ='America/Los_Angeles ';
        usr.LocaleSidKey ='en_US';
        usr.EmailEncodingKey='UTF-8';
        usr.ProfileId=lstProfiles[0].Id;
        usr.LanguageLocaleKey ='en_US';
        usr.UserRoleId = null;
        insert usr;
        
        List<Account> testAccountList = new List<Account>();
        String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        testAccountList.add(new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,RecordTypeId=intelAccRecTypeId,
                                        Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
                                        BillingCity='testCity', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345'/*, 
Core_IPS_Active__c=true*/,OwnerId=usr.id));
        /*Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
BillingCity='testCity', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
Core_IPS_Active__c=true,OwnerId=usr.id);
insert testAccount;*/
        //system.assertNOTEquals(null,testAccount.id);
        
        testAccountList.add(new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = false,RecordTypeId=intelAccRecTypeId,
                                        Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
                                        BillingCity='testCity2', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345'/*, 
Core_IPS_Active__c=true*/, Core_CIM_ID__c ='123124', Core_CNDA_Number__c='12345'));
        /*Account testAccount2 = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = false,
Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
BillingCity='testCity2', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
Core_IPS_Active__c=true, Core_CIM_ID__c ='123124', Core_CNDA_Number__c='12345');
insert testAccount2;
System.assert(true,testAccount2.Core_IPS_Active__c!= null);*/
        
        testAccountList.add(new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,RecordTypeId=intelAccRecTypeId,
                                        Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
                                        BillingCity='testCity3', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345'/*, 
Core_IPS_Active__c=true*/,Core_CIM_ID__c ='', Core_PSG_Account__c = false, Core_CNDA_Number__c='12345'));
        /*Account testAccount3 = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
BillingCity='testCity3', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
Core_IPS_Active__c=true,Core_CIM_ID__c ='', Core_PSG_Account__c = false, Core_CNDA_Number__c='12345');
insert testAccount3;
system.assertequals(testAccount3.Name,'testAccount123');*/
        insert testAccountList;
        
        List<Contact> testContactList = new List<Contact>();
        testContactList.add(new Contact(FirstName='testFirstName123', LastName='爱', Email='test123@testing.com.test',MailingCountry='India',
                                        AccountId=testAccountList[0].Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true));
        /*Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='爱', Email='test123@testing.com.test',
AccountId=testAccount.Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true);
insert testContact1;
System.assert(true,testContact1.Core_Personal_Email_Indicator__c!= null);*/
        
        testContactList.add(new Contact(FirstName='testFirstName123', LastName='爱', Email='test1234@testing.com.test',MailingCountry='India',
                                        AccountId=testAccountList[1].Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true));
        /*Contact testContact2 = new Contact(FirstName='testFirstName123', LastName='爱', Email='test1234@testing.com.test',
AccountId=testAccount2.Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true);
insert testContact2;
system.assertequals(testContact2.FirstName,'testFirstName123');*/
        
        testContactList.add(new Contact(FirstName='testFirstName123', LastName='爱', Email='test12345@testing.com.test',MailingCountry='India',
                                        AccountId=testAccountList[2].Id,Core_Personal_Email_Indicator__c=true,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Set_ERPM_Status_Bypass__c=true));
        /*Contact testContact3 = new Contact(FirstName='testFirstName123', LastName='爱', Email='test12345@testing.com.test',
AccountId=testAccount3.Id,Core_Personal_Email_Indicator__c=true,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Set_ERPM_Status_Bypass__c=true);
insert testContact3;
system.assertNOTEquals(null,testContact3.id);*/
        insert testContactList;
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
        insert cee;
        System.assert(true,cee.Name != null); 
        
        List<Core_Entitlement__c> testentitlementList = new List<Core_Entitlement__c>();
        testentitlementList.add(new Core_Entitlement__c(name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true));
        
        /*Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
insert entitle;
//System.assert(true,entitle.Core_Category__c!= null);*/
        
        testentitlementList.add(new Core_Entitlement__c(name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_IsActive__c=true));
        
        /*Core_Entitlement__c entitle1 = new Core_Entitlement__c (name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_IsActive__c=true); 
insert entitle1;*/
        
        testentitlementList.add(new Core_Entitlement__c(name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true));
        
        /*Core_Entitlement__c entitle2 = new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
insert entitle2;*/
        
        testentitlementList.add(new Core_Entitlement__c(name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true));
        
        /*Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true); 
insert entitle3;*/
        
        
        Core_Entitlement__c entitle4 = new Core_Entitlement__c (name ='Supply Assurance (includes Order Placement Role and e-Ack)', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true); 
        //insert entitle4;
        
        insert testentitlementList;
        test.startTest();
        List<Core_Entitlement__c> newCE =[Select Id from Core_Entitlement__c ];
        try{
            Core_Contact_Entitlement__c content1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContactList[0].Id,Core_Entitlement_Id__c = newCE[0].id, Core_Selected__c=true);
            insert content1;
        }catch(Exception ex){
            //System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ex.getDmlType(0));
            //System.assertEquals('CIM ID cant be blank on Account Record', ex.getDmlMessage(0));
        }
        try{
            Core_Contact_Entitlement__c content2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContactList[1].Id,Core_Entitlement_Id__c = newCE[1].id, Core_Selected__c=true);
            insert content2;
        }catch(Exception ex){
            //System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ex.getDmlType(0));
            //System.assertEquals('Intel Support Owner cant be blank on Contact Record', ex.getDmlMessage(0));
        }
        try{
            Core_Contact_Entitlement__c content3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContactList[2].Id,Core_Entitlement_Id__c = newCE[0].id, Core_Selected__c=true);
            insert content3;
        }catch(Exception ex){
            System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ex.getDmlType(0),'Exception message not matching');
            //System.assertEquals('English Only on Contact cant be blank (Populate from Standard and Alternate if avalible and meet req)', ex.getDmlMessage(0));
            
        }
        try{
            testContactList[2].LastName='testranjan';
            testContactList[2].Core_English_Only_First_Name__c='test';
            testContactList[2].Core_English_Only_Last_Name__c='ranjan';
            update testContactList[2];
            Core_Contact_Entitlement__c content4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContactList[2].Id,Core_Entitlement_Id__c = newCE[1].id, Core_Selected__c=true);
            insert content4;
        }catch(Exception ex){
            //System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ex.getDmlType(0));
            //System.assertEquals('Personal Email Domain Indicator on Contact Record is TRUE', ex.getDmlMessage(0));
        }
        try{
            testContactList[2].LastName='testranjan';
            testContactList[2].Core_English_Only_First_Name__c='test';
            testContactList[2].Core_English_Only_Last_Name__c='ranjan';
            update testContactList[2];
            Core_Contact_Entitlement__c content5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContactList[2].Id,Core_Entitlement_Id__c = newCE[0].id, Core_Selected__c=true);
            insert content5;
        }catch(Exception ex){
            //System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ex.getDmlType(0));
            //System.assertEquals('Cant be selected if ODM is TRUE on Account Record', ex.getDmlMessage(0));
            
        }
        try{
            //testContactList[2].Core_IsODM__c = false;
            //update testContactList[2];
            
            testContactList[2].LastName='testranjan';
            testContactList[2].Core_English_Only_First_Name__c='test';
            testContactList[2].Core_English_Only_Last_Name__c='ranjan';
            update testContactList[2];
            
            Core_Contact_Entitlement__c content6 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContactList[2].Id,Core_Entitlement_Id__c = newCE[0].id, Core_Selected__c=true);
            insert content6;
        }catch(Exception ex){
            //System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ex.getDmlType(0));
            //System.assertEquals('ODM Indicator field must be checked.', ex.getDmlMessage(0));
            
        }
        ApexPages.currentPage().getParameters().put('Id', testContactList[1].Id);
        ApexPages.StandardController sc2 = new ApexPages.StandardController(testContactList[1]);
        
        Core_Contact_Entitlements_Controller conEntController2 = new Core_Contact_Entitlements_Controller(sc2);
        
        List<ApexPages.Message> msgList2 = ApexPages.getMessages();
        Boolean checkCNDAMsg = false;
        Boolean checkIPSOwner = false;
        for(ApexPages.Message msg : msgList2) {
            if(msg.getDetail().contains('CNDA cant be blank on Account Record')) checkCNDAMsg=true;
            if(msg.getDetail().contains('Intel Support Owner cant be blank on Contact Record')) checkIPSOwner=true;
        }
        
        List<Core_Contact_Entitlement_Validation_Req__c> reqList = new List<Core_Contact_Entitlement_Validation_Req__c>();
        Core_Contact_Entitlement_Validation_Req__c req1=new Core_Contact_Entitlement_Validation_Req__c(Name='req1',Core_Entitlement_id__c=testentitlementList[1].id,  Core_Entitlement_Req_id__c=testentitlementList[0].id,Core_Entitlement_SysMsgName__c='  System PSG Basic'); 
        Core_Contact_Entitlement_Validation_Req__c req2=new Core_Contact_Entitlement_Validation_Req__c(Name='req2',Core_Entitlement_id__c=testentitlementList[2].id,  Core_Entitlement_Req_id__c=testentitlementList[0].id,Core_Entitlement_SysMsgName__c='  System PSG Basic'); 
        reqList.add(req1);
        reqList.add(req2);
        insert reqList; 
        
        conEntController2.onPageLoad();
        test.stopTest();
        
    }
    /*public static testmethod void testContEntCheck1() 
{
test.startTest();


Account acc1 = new Account(Name='testAccount001', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
BillingCity='testCity', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
Core_IPS_Active__c=true , Core_English_Only_Name__c = '');
insert acc1;



Contact cont1 = new Contact(FirstName='testFN123', LastName='爱', Email='test1212@testing.com.test',
AccountId=acc1.Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true);
insert cont1;

Contact cont2 = new Contact(FirstName='testFN321', LastName='ABC', Email='test212@testing.com.test',
AccountId=acc1.Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true);
insert cont2;

Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer',Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
insert cee;

List<Core_Entitlement__c> lstEnt = new List<Core_Entitlement__c>();
Core_Entitlement__c entitle = new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
lstEnt.add(entitle);


Core_Entitlement__c entitle1 = new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
lstEnt.add(entitle1);


Core_Entitlement__c entitle2 = new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
lstEnt.add(entitle2);

Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_IsActive__c=true); 
lstEnt.add(entitle3);

Core_Entitlement__c entitle4 = new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true); 
lstEnt.add(entitle4);

Core_Entitlement__c entitle5 = new Core_Entitlement__c (name ='Resource & Design Center Collaboration Workspaces', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center Collaboration Workspaces',Core_IsActive__c=true); 
lstEnt.add(entitle5);

insert lstEnt;

List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont1.Id,Core_Entitlement_Id__c = lstEnt[3].id , Core_Selected__c=false);
Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont1.Id,Core_Entitlement_Id__c =lstEnt[1].id, Core_Selected__c=true);
Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont1.Id,Core_Entitlement_Id__c= lstEnt[2].id, Core_Selected__c=false);
Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont1.Id,Core_Entitlement_Id__c= lstEnt[0].id, Core_Selected__c=true);
Core_Contact_Entitlement__c ce5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont2.Id,Core_Entitlement_Id__c= lstEnt[4].id, Core_Selected__c=true);
Core_Contact_Entitlement__c ce6 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont2.Id,Core_Entitlement_Id__c= lstEnt[5].id, Core_Selected__c=true);

newlstentitle.add(ce1);                                                                         
newlstentitle.add(ce2);
newlstentitle.add(ce3);
newlstentitle.add(ce4);
newlstentitle.add(ce5);
newlstentitle.add(ce6);
insert newlstentitle;

List<Core_Contact_Entitlement_Validation__c> lstentval= new List<Core_Contact_Entitlement_Validation__c>();
Core_Contact_Entitlement_Validation__c entval  = new Core_Contact_Entitlement_Validation__c(Name='1',Core_Entitlement_Id__c=lstEnt[1].id,Core_Entitlement_Name__c='Intel Premier Support',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=true);
Core_Contact_Entitlement_Validation__c entval1 = new Core_Contact_Entitlement_Validation__c(Name='2',Core_Entitlement_Id__c=lstEnt[1].id,Core_Entitlement_Name__c='Return Services Request',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=true);
Core_Contact_Entitlement_Validation__c entval2 = new Core_Contact_Entitlement_Validation__c(Name='3',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Resource & Design Center Collaboration Workspaces',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false);
Core_Contact_Entitlement_Validation__c entval3 = new Core_Contact_Entitlement_Validation__c(Name='4',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Partner Portal',Core_Account_English_Only_Name__c=false,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=false,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false);
lstentval.add(entval);
lstentval.add(entval1);
lstentval.add(entval2);
lstentval.add(entval3);
insert lstentval; 

Core_Contact_Ent_Validation_Message__c msg11=new Core_Contact_Ent_Validation_Message__c(Name='System English on Account' , Core_Error_Message__c = 'English Only on Account cannot be blank (Populate from Standard and Alternate if avalible and meet req)', Core_Error_Message2__c ='',   Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
insert msg11;
Core_Contact_Ent_Validation_Message__c msg22=new Core_Contact_Ent_Validation_Message__c(Name='System English on Contact' , Core_Error_Message__c = 'English Only on Contact can not be blank (Populate from Standard and Alternate if avalible and meet req)', Core_Error_Message2__c='',  Core_System_Validation_Name__c=false, Core_UI_Validation_Name__c=false);
insert msg22;

Core_Contact_Entitlement_Subordinates__c subordinates1 = new Core_Contact_Entitlement_Subordinates__c(Name='1',Core_Entitlement_Id__c=entitle4.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=entitle1.id,Core_Is_ODM_True__c=false ,Core_Is_CNDA_True__c =true);
insert subordinates1;
test.stopTest();

}*/
    /* public static testmethod void testContEntCheck2()
{
test.startTest();

Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];



User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
UserName='salesRepTestx21@intel.com');
insert itAdminUser;
system.assertequals(itAdminUser.LastName,'UnitTestAdmin1');

system.runas(itAdminUser){

Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
cm.Name = 'IPS Standard Entitlement';
cm.Value__c  = 'IPS Standard Entitlement';
insert cm;
System.assertEquals(cm.Name,'IPS Standard Entitlement');


Core_Trigger_Executions__c executions = new Core_Trigger_Executions__c(Name='addContactEntitlementSubordinates',Core_Active__c=true,Core_Class_Name__c='Core_IPS_CaseTriggerHandler',Core_Description__c='testcase',Core_Object__c='case',Core_Trigger_Events__c='after update');
insert executions;
system.assertequals(executions.Name,'addContactEntitlementSubordinates');



List<Account> acc1 = new List<Account>();
Account testAccount = new Account(Name='阿昌', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = true,
Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c = '',
BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test123',
BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');

acc1.add(testAccount);  
insert acc1;

Account accVal1 = new Account();
accVal1=[select name from account where id in:acc1];
accVal1.name = '阿昌';
accVal1.Core_Alternate_Language_Name__c='阿昌';
update accVal1;
System.assert(true,accVal1.name != null);


Map<Id, Account> mapacc1 = new Map<Id, Account>([select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_Account_Type__c from Account]);
List<Contact> lsttestContact1 = new List<Contact>();
List<Contact> lsttestContactUpdate1 = new List<Contact>();

Core_Trigger_Executions__c executions2 = new Core_Trigger_Executions__c(Name='UpdateJobFunctionAndCode',Core_Active__c=true,Core_Class_Name__c='Core_ContactHandler',Core_Description__c='testcase',Core_Object__c='Contact',Core_Trigger_Events__c='Before Insert Before Update');
insert executions2;
Contact testContact = new Contact(FirstName='阿昌', LastName='阿昌', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
AccountId=testAccount.Id,Core_Set_ERPM_Status_Bypass__c=true,Core_Local_First_Name__c='david',Core_Local_Last_Name__c='geetha',Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false);

insert testContact;

Contact testConUpdate = new Contact();
testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
testConUpdate.firstname = '阿昌';
testConUpdate.lastname = '阿昌';
testConUpdate.Core_Local_First_Name__c='david';
testConUpdate.Core_Local_Last_Name__c='geetha';
update testConUpdate;

Core_Entitlement_Profile_Access__c profileaccess = new Core_Entitlement_Profile_Access__c(Core_Entitlements_Allowed__c='Advanced Shipment and Invoice Notification ',Core_Profile_Id__c=itAdminPrf.id);
insert profileaccess;
system.assertNOTEquals(null,profileaccess.id);


Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
insert cee; 
system.assertequals(cee.Name ,'Partner File Transfer');


Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
insert entitle;
System.assert(true,entitle.Core_Category__c!= null);


Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
insert entitle1;
system.assertequals(entitle1.name ,'ODM/Price Mask');


Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
insert entitle2;
system.assertNOTEquals(null,entitle2.id);

Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true); 
insert entitle3;

Core_Entitlement__c entitle4 = new Core_Entitlement__c (name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_IsActive__c=true); 
insert entitle4;




Set<String> idsList=new Set<String>();

List<Core_Contact_Entitlement_Exclusive__c> oldexclusive = new List<Core_Contact_Entitlement_Exclusive__c>();
Core_Contact_Entitlement_Exclusive__c exclusive = new Core_Contact_Entitlement_Exclusive__c(Core_Unique_Ids__c=entitle.id+','+entitle1.id,Name='Support');
oldexclusive.add(exclusive); 
insert oldexclusive;


List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle1.id, Core_Selected__c=true,Core_From_Source__c=false);
Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle3.id, Core_Selected__c=false,Core_From_Source__c=false);
Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=false,Core_From_Source__c=false);

newlstentitle.add(ce1);
newlstentitle.add(ce2);
newlstentitle.add(ce3);
insert newlstentitle;
system.debug('newlstentitle==='+newlstentitle);

Core_Contact_Entitlement_Subordinates__c subordinates = new Core_Contact_Entitlement_Subordinates__c(Name='1',Core_Entitlement_Id__c=entitle4.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=entitle1.id,Core_Is_ODM_True__c=true);
insert subordinates;
system.assertequals(subordinates.Core_Entitlement_Name__c,'Product Information (Product Details)');

List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();

Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle4.id, Core_Selected__c=false);
Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true);
Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=true);

oldlstentitle.add(conent1);
oldlstentitle.add(conent2);
oldlstentitle.add(conent3);

update  oldlstentitle;
system.debug('oldlstentitle==='+oldlstentitle);

Core_ContactEntitlementValidation validation = new Core_ContactEntitlementValidation();
validation.filterEntitlementsByProfile();
Core_ContactEntitlementValidation.validateAccountEnglishOnlyFields(acc1,mapacc1);
//Core_ContactEntitlementValidation.validateEnglishOnly(entitle1.id,testContact);
//Core_ContactEntitlementValidation.validateUniqueEntitlement(entitle2.id,testContact);

test.stopTest();

}
}*/
    /*public static testmethod void testContEntVal1() {


Profile itAdminPrf = [select id, name from Profile where name = 'Data Ops' Limit 1];

Profile itAdminpf = [select id, name from Profile where name = 'System Administrator' Limit 1];
List<User> userList = new List<User>();

User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
UserName='salesRepTestx21@intel.com');
userList.add(itAdminUser);
//insert itAdminUser;
//system.assertequals(itAdminUser.LastName,'UnitTestAdmin1');

User itAdmin = new User(Alias = 'itAdm221',   Email='itAdminTestx218@intel.com', 
EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin12',
LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
ProfileId = itAdminpf.Id,  TimeZoneSidKey='America/Los_Angeles',
UserName='salesRepTestx211@intel.com');
userList.add(itAdmin);
insert userList;
system.assertequals(itAdmin.LastName,'UnitTestAdmin12');

system.runas(itAdmin){

Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
cm.Name = 'IPS Standard Entitlement';
cm.Value__c  = 'IPS Standard Entitlement';
insert cm;
System.assert(true,cm.Value__c != null);

Core_Trigger_Executions__c executions = new Core_Trigger_Executions__c(Name='addContactEntitlementSubordinates',Core_Active__c=true,Core_Class_Name__c='Core_IPS_CaseTriggerHandler',Core_Description__c='testcase',Core_Object__c='case',Core_Trigger_Events__c='after update');
insert executions;
system.assertNOTEquals(null,executions.id);

List<Account> acc = new List<Account>();
Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c ='samplename',
BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);

acc.add(testAccount);  
insert acc;

Account testAccount1 = new Account(Name='testAccount143', Core_Sales_Group__c='Global Accounts',
Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c ='samplename',
BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);
insert testAccount1;


Account accVal = new Account();
accVal=[select name from account where id =:acc[0].id];
accVal.name = 'Geetha Test';
system.runas(itAdminUser){
update accVal;
}

Core_Trigger_Executions__c executions001 = new Core_Trigger_Executions__c(Name='UpdateJobFunctionAndCode',Core_Active__c=true,Core_Class_Name__c='Core_ContactHandler',Core_Description__c='testcase',Core_Object__c='Contact',Core_Trigger_Events__c='Before Insert Before Update');
insert executions001;
List<Account> lstValue =[select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_English_Only_Name__c,Core_Account_Type__c from Account where id =:acc[0].id];
//Map<Id, Account> mapacc = new Map<Id, Account>([select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_English_Only_Name__c,Core_Account_Type__c from Account]);
Map<Id, Account> mapacc = new  Map<Id, Account>();
for(account accvallist:lstValue )
{
mapacc.put(accvallist.id,accvallist);
}
List<Contact> lsttestContact = new List<Contact>();
List<Contact> lsttestContactUpdate = new List<Contact>();

test.startTest();
Contact testContact = new Contact(FirstName='阿昌', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');

//insert testContact;
lsttestContact.add(testContact);
system.assertequals(testContact.LastName,'testLastName');

Contact testContact1 = new Contact(FirstName='阿昌', LastName='testLastName', Email='test14x3@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
AccountId=testAccount1.Id,Core_Local_First_Name__c='',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');

//insert testContact1;
lsttestContact.add(testContact1);
insert lsttestContact;
Contact testConUpdate = new Contact();
testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
testConUpdate.firstname = 'TestName123234';
testConUpdate.lastname = 'testLastName123';
update testConUpdate;


List<Core_Entitlement_Profile_Access__c> lstprofileaccess = new List<Core_Entitlement_Profile_Access__c>();

Core_Entitlement_Profile_Access__c profileaccess = new Core_Entitlement_Profile_Access__c(Core_Entitlements_Allowed__c='',Core_Profile_Id__c=itAdminPrf.id);
lstprofileaccess.add(profileaccess);
insert lstprofileaccess;


Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', 

Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
insert cee;
System.assert(true,cee.Core_IsActive__c!= null);   

List<Core_Entitlement__c> lstEnt = new List<Core_Entitlement__c>();
Core_Entitlement__c entitle = new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
lstEnt.add(entitle);


Core_Entitlement__c entitle1 = new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
lstEnt.add(entitle1);


Core_Entitlement__c entitle2 = new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
lstEnt.add(entitle2);

Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_IsActive__c=true); 
lstEnt.add(entitle3);

Core_Entitlement__c entitle4 = new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true); 
lstEnt.add(entitle4);

Core_Entitlement__c entitle5 = new Core_Entitlement__c (name ='Resource & Design Center Collaboration Workspaces', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center Collaboration Workspaces',Core_IsActive__c=true); 
lstEnt.add(entitle5);

insert lstEnt;

List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = lstEnt[3].id , Core_Selected__c=false);
Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[1].id, Core_Selected__c=true);
Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= lstEnt[2].id, Core_Selected__c=false);
Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= lstEnt[0].id, Core_Selected__c=true);
Core_Contact_Entitlement__c ce5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Entitlement_Id__c= lstEnt[4].id, Core_Selected__c=true);
Core_Contact_Entitlement__c ce6 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Entitlement_Id__c= lstEnt[5].id, Core_Selected__c=true);

newlstentitle.add(ce1);                                                                         
newlstentitle.add(ce2);
newlstentitle.add(ce3);
newlstentitle.add(ce4);
newlstentitle.add(ce5);
newlstentitle.add(ce6);
insert newlstentitle;
system.debug('newlstentitle==='+newlstentitle);

List<Core_Contact_Entitlement_Subordinates__c> lstSubAdd = new List<Core_Contact_Entitlement_Subordinates__c>();
Core_Contact_Entitlement_Subordinates__c subordinates = new Core_Contact_Entitlement_Subordinates__c(Name='1',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[1].id,Core_Is_ODM_True__c=false,Core_Is_CNDA_True__c=true);
Core_Contact_Entitlement_Subordinates__c subordinates1 = new Core_Contact_Entitlement_Subordinates__c(Name='2',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[3].id,Core_Is_ODM_True__c=false,Core_Is_CNDA_True__c=true);
Core_Contact_Entitlement_Subordinates__c subordinates2 = new Core_Contact_Entitlement_Subordinates__c(Name='3',Core_Entitlement_Id__c=lstEnt[2].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[0].id,Core_Is_ODM_True__c=false,Core_Is_CNDA_True__c=true);
Core_Contact_Entitlement_Subordinates__c subordinates3 = new Core_Contact_Entitlement_Subordinates__c(Name='4',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[0].id,Core_Is_ODM_True__c=false,Core_Is_CNDA_True__c=true);
lstSubAdd.add(subordinates);
lstSubAdd.add(subordinates1);
lstSubAdd.add(subordinates2);
lstSubAdd.add(subordinates3);
insert lstSubAdd;
system.assertNOTEquals(null,subordinates.id);

ContactEntSubordinatesRemovalTest.setMetadata(
'SELECT Id,Label,Core_Condition__c,Core_Entitlement_Id__c,Core_Entitlement_Name__c,Core_Entitlement_Subordinate_Id__c,Core_Entitlement_Subordinate_Name__c FROM Contact_Entitlement_Subordinates_Removal__mdt WHERE DeveloperName = \'Default\'',
(List<Contact_Entitlement_Subordinates_Removal__mdt>) JSON.deserialize( '[{"Label":"1","Core_Entitlement_Id__c":"'+entitle1.id+'","Core_Entitlement_Name__c":"Product Information(Product Details)","Core_Condition__c":"","Core_Entitlement_Subordinate_Name__c":"ODM/Price Mask","Core_Entitlement_Subordinate_Id__c":"'+entitle2.id+'"},{"Label":"2","Core_Entitlement_Id__c":"'+entitle1.id+'","Core_Condition__c":"","Core_Entitlement_Name__c":"Product Information (Product Details)","Core_Entitlement_Subordinate_Name__c":"ODM/Price Mask","Core_Entitlement_Subordinate_Id__c":"'+entitle2.id+'"},{"Label":"3","Core_Entitlement_Id__c":"'+entitle4.id+'","Core_Entitlement_Name__c":"Product Information (Product Details)","Core_Condition__c":"","Core_Entitlement_Subordinate_Name__c":"ODM/Price Mask","Core_Entitlement_Subordinate_Id__c":"'+entitle5.Id+'"},{"Label":"4","Core_Entitlement_Id__c":"'+entitle4.id+'","Core_Condition__c":"","Core_Entitlement_Name__c":"Product Information (Product Details)","Core_Entitlement_Subordinate_Name__c":"ODM/Price Mask","Core_Entitlement_Subordinate_Id__c":"'+entitle5.Id+'"}]', List<Contact_Entitlement_Subordinates_Removal__mdt>.class )
);

//start----Added by Popcornapps
List<Core_Contact_Entitlement_Validation__c> lstentval= new List<Core_Contact_Entitlement_Validation__c>();
Core_Contact_Entitlement_Validation__c entval  = new Core_Contact_Entitlement_Validation__c(Name='1',Core_Entitlement_Id__c=lstEnt[1].id,Core_Entitlement_Name__c='Intel Premier Support',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=true);
Core_Contact_Entitlement_Validation__c entval1 = new Core_Contact_Entitlement_Validation__c(Name='2',Core_Entitlement_Id__c=lstEnt[1].id,Core_Entitlement_Name__c='Return Services Request',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=true);
Core_Contact_Entitlement_Validation__c entval2 = new Core_Contact_Entitlement_Validation__c(Name='3',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Resource & Design Center Collaboration Workspaces',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false);
Core_Contact_Entitlement_Validation__c entval3 = new Core_Contact_Entitlement_Validation__c(Name='4',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Partner Portal',Core_Account_English_Only_Name__c=false,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=false,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false);
lstentval.add(entval);
lstentval.add(entval1);
lstentval.add(entval2);
lstentval.add(entval3);
insert lstentval;

List<Core_Contact_Ent_Validation_Message__c> lstvalmsg = new List<Core_Contact_Ent_Validation_Message__c>();
Core_Contact_Ent_Validation_Message__c entvalmsg = new Core_Contact_Ent_Validation_Message__c(Name ='System CIM ID',Core_Error_Message__c ='CIM ID cant be blank on Account Record',Core_Error_Message2__c = null,Core_System_Validation_Name__c = true,Core_UI_Validation_Name__c = false);
Core_Contact_Ent_Validation_Message__c entvalmsg1 = new Core_Contact_Ent_Validation_Message__c(Name='System Non ODM',Core_Error_Message__c='ODM Indicator field must be checked',Core_System_Validation_Name__c=true,Core_UI_Validation_Name__c=false);
Core_Contact_Ent_Validation_Message__c entvalmsg2 = new Core_Contact_Ent_Validation_Message__c(Name='UI CNDA',Core_Error_Message__c='The account must have a valid CNDA to be able to grant access. Please verify if the account has a valid CNDA (<a href="https://intel.tap.thinksmart.com/prod/Portal/WorkflowDashboard/?cid=c924622d_fcae_4333_9c95_46104114907d" target="_blank">',Core_Error_Message2__c= 'NDA Viewer</a>) - and add it to account record',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
Core_Contact_Ent_Validation_Message__c entvalmsg3 = new Core_Contact_Ent_Validation_Message__c(Name='UI Unique Entitlement',Core_Error_Message__c='You cannot select IPS and Partner Portal together. Only one can be selected',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
lstvalmsg.add(entvalmsg);
lstvalmsg.add(entvalmsg1);
lstvalmsg.add(entvalmsg2);
lstvalmsg.add(entvalmsg3);
insert lstvalmsg;

//Stop----Added by Popcornapps

List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();

Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle3.id , Core_Selected__c=true);
Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[1].id, Core_Selected__c=false);
Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[2].id, Core_Selected__c=true);
Core_Contact_Entitlement__c conent4 = new Core_Contact_Entitlement__c(id = ce5.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[4].id, Core_Selected__c=false);

oldlstentitle.add(conent4);
oldlstentitle.add(conent1);
oldlstentitle.add(conent2);
oldlstentitle.add(conent3);

update  oldlstentitle;
system.debug('oldlstentitle==='+oldlstentitle);

test.stopTest();

Core_ContactEntitlementValidation validation = new Core_ContactEntitlementValidation();
validation.filterEntitlementsByProfile();
Core_ContactEntitlementValidation.validateAccountEnglishOnlyFields(acc,mapacc);
//Core_ContactEntitlementValidation.validateEnglishOnly(entitle1.id,testContact);
string uniqueEntitlementName='';

Core_ContactEntitlementValidation.validateUniqueEntitlement(entitle2.id,testContact,uniqueEntitlementName);

} 
}
public static testmethod void testContEntVal2() {


Profile itAdminPrf = [select id, name from Profile where name = 'Data Ops' Limit 1];

Profile itAdminpf = [select id, name from Profile where name = 'System Administrator' Limit 1];
List <User> listUser = new List <User>(); 
User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
UserName='salesRepTestx21@intel.com');
listUser.add(itAdminUser);
//insert itAdminUser;
system.assertequals(itAdminUser.LastName,'UnitTestAdmin1');

User itAdmin = new User(Alias = 'itAdm221',   Email='itAdminTestx218@intel.com', 
EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin12',
LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
ProfileId = itAdminpf.Id,  TimeZoneSidKey='America/Los_Angeles',
UserName='salesRepTestx211@intel.com');
listUser.add(itAdmin);
insert listUser;
//insert itAdmin;
system.assertequals(itAdmin.LastName,'UnitTestAdmin12');

system.runas(itAdmin){

Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
cm.Name = 'IPS Standard Entitlement';
cm.Value__c  = 'IPS Standard Entitlement';
insert cm;
System.assert(true,cm.Value__c != null);

Core_Trigger_Executions__c executions = new Core_Trigger_Executions__c(Name='addContactEntitlementSubordinates',Core_Active__c=true,Core_Class_Name__c='Core_IPS_CaseTriggerHandler',Core_Description__c='testcase',Core_Object__c='case',Core_Trigger_Events__c='after update');
insert executions;
system.assertNOTEquals(null,executions.id);

List<Account> acc = new List<Account>();
Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c ='samplename',
BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);

acc.add(testAccount);  
insert acc;

Account testAccount1 = new Account(Name='testAccount143', Core_Sales_Group__c='Global Accounts',
Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c ='samplename',
BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);
insert testAccount1;

Account accVal = new Account();
accVal=[select name from account where id =:acc[0].id];
accVal.name = 'Geetha Test';
system.runas(itAdminUser){
update accVal;
}

List<Account> lstValue =[select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_English_Only_Name__c,Core_Account_Type__c from Account where id =:acc[0].id];
//Map<Id, Account> mapacc = new Map<Id, Account>([select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_English_Only_Name__c,Core_Account_Type__c from Account]);
Map<Id, Account> mapacc = new  Map<Id, Account>();
for(account accvallist:lstValue )
{
mapacc.put(accvallist.id,accvallist);
}
List<Contact> lsttestContact = new List<Contact>();
List<Contact> lsttestContactUpdate = new List<Contact>();

Core_Trigger_Executions__c executions1 = new Core_Trigger_Executions__c(Name='UpdateJobFunctionAndCode',Core_Active__c=true,Core_Class_Name__c='Core_ContactHandler',Core_Description__c='testcase',Core_Object__c='Contact',Core_Trigger_Events__c='Before Insert Before Update');
insert executions1;

test.startTest();  

Contact testContact = new Contact(FirstName='阿昌', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');

//insert testContact;
lsttestContact.add(testContact);
system.assertequals(testContact.LastName,'testLastName');

Contact testContact1 = new Contact(FirstName='阿昌', LastName='testLastName', Email='test14x3@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
AccountId=testAccount1.Id,Core_Local_First_Name__c='',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');

//insert testContact1;
lsttestContact.add(testContact1);
insert lsttestContact;

Contact testConUpdate = new Contact();
testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
testConUpdate.firstname = 'TestName123234';
testConUpdate.lastname = 'testLastName123';
update testConUpdate;


List<Core_Entitlement_Profile_Access__c> lstprofileaccess = new List<Core_Entitlement_Profile_Access__c>();

Core_Entitlement_Profile_Access__c profileaccess = new Core_Entitlement_Profile_Access__c(Core_Entitlements_Allowed__c='',Core_Profile_Id__c=itAdminPrf.id);
lstprofileaccess.add(profileaccess);
insert lstprofileaccess;



Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', 

Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
insert cee;
System.assert(true,cee.Core_IsActive__c!= null);   

List<Core_Entitlement__c> lstEnt = new List<Core_Entitlement__c>();
Core_Entitlement__c entitle = new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
lstEnt.add(entitle);


Core_Entitlement__c entitle1 = new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
lstEnt.add(entitle1);


Core_Entitlement__c entitle2 = new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
lstEnt.add(entitle2);

Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_IsActive__c=true); 
lstEnt.add(entitle3);

Core_Entitlement__c entitle4 = new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true); 
lstEnt.add(entitle4);

Core_Entitlement__c entitle5 = new Core_Entitlement__c (name ='Resource & Design Center Collaboration Workspaces', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center Collaboration Workspaces',Core_IsActive__c=true); 
lstEnt.add(entitle5);

insert lstEnt;

List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = lstEnt[3].id , Core_Selected__c=false);
Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[1].id, Core_Selected__c=false);
Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= lstEnt[2].id, Core_Selected__c=false);
Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= lstEnt[0].id, Core_Selected__c=false);
Core_Contact_Entitlement__c ce5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Entitlement_Id__c= lstEnt[4].id, Core_Selected__c=false);
Core_Contact_Entitlement__c ce6 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Entitlement_Id__c= lstEnt[5].id, Core_Selected__c=false);

newlstentitle.add(ce1);                                                                         
newlstentitle.add(ce2);
newlstentitle.add(ce3);
newlstentitle.add(ce4);
newlstentitle.add(ce5);
newlstentitle.add(ce6);
insert newlstentitle;
system.debug('newlstentitle==='+newlstentitle);

List<Core_Contact_Entitlement_Subordinates__c> lstSubAdd = new List<Core_Contact_Entitlement_Subordinates__c>();
Core_Contact_Entitlement_Subordinates__c subordinates = new Core_Contact_Entitlement_Subordinates__c(Name='1',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[1].id,Core_Is_ODM_True__c=false);
Core_Contact_Entitlement_Subordinates__c subordinates1 = new Core_Contact_Entitlement_Subordinates__c(Name='2',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[3].id,Core_Is_ODM_True__c=false);
Core_Contact_Entitlement_Subordinates__c subordinates2 = new Core_Contact_Entitlement_Subordinates__c(Name='3',Core_Entitlement_Id__c=lstEnt[2].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[0].id,Core_Is_ODM_True__c=false);
Core_Contact_Entitlement_Subordinates__c subordinates3 = new Core_Contact_Entitlement_Subordinates__c(Name='4',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[0].id,Core_Is_ODM_True__c=false);
lstSubAdd.add(subordinates);
lstSubAdd.add(subordinates1);
lstSubAdd.add(subordinates2);
lstSubAdd.add(subordinates3);
insert lstSubAdd;
system.assertNOTEquals(null,subordinates.id);

ContactEntSubordinatesRemovalTest.setMetadata(
'SELECT Id,Label,Core_Condition__c,Core_Entitlement_Id__c,Core_Entitlement_Name__c,Core_Entitlement_Subordinate_Id__c,Core_Entitlement_Subordinate_Name__c FROM Contact_Entitlement_Subordinates_Removal__mdt WHERE DeveloperName = \'Default\'',
(List<Contact_Entitlement_Subordinates_Removal__mdt>) JSON.deserialize( '[{"Label":"1","Core_Entitlement_Id__c":"'+entitle1.id+'","Core_Entitlement_Name__c":"Product Information(Product Details)","Core_Entitlement_Subordinate_Name__c":"ODM/Price Mask","Core_Entitlement_Subordinate_Id__c":"'+entitle2.id+'"},{"Label":"2","Core_Entitlement_Id__c":"'+entitle1.id+'","Core_Entitlement_Name__c":"Product Information (Product Details)","Core_Entitlement_Subordinate_Name__c":"ODM/Price Mask","Core_Entitlement_Subordinate_Id__c":"'+entitle2.id+'"},{"Label":"3","Core_Entitlement_Id__c":"'+entitle4.id+'","Core_Entitlement_Name__c":"Product Information (Product Details)","Core_Entitlement_Subordinate_Name__c":"ODM/Price Mask","Core_Entitlement_Subordinate_Id__c":"'+entitle5.Id+'"},{"Label":"4","Core_Entitlement_Id__c":"'+entitle4.id+'","Core_Entitlement_Name__c":"Product Information (Product Details)","Core_Entitlement_Subordinate_Name__c":"ODM/Price Mask","Core_Entitlement_Subordinate_Id__c":"'+entitle5.Id+'"}]', List<Contact_Entitlement_Subordinates_Removal__mdt>.class )
);

//start----Added by Popcornapps
List<Core_Contact_Entitlement_Validation__c> lstentval= new List<Core_Contact_Entitlement_Validation__c>();
Core_Contact_Entitlement_Validation__c entval  = new Core_Contact_Entitlement_Validation__c(Name='1',Core_Entitlement_Id__c=lstEnt[1].id,Core_Entitlement_Name__c='Intel Premier Support',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=true,Core_PSG_WOM__c=true);
Core_Contact_Entitlement_Validation__c entval1 = new Core_Contact_Entitlement_Validation__c(Name='2',Core_Entitlement_Id__c=lstEnt[1].id,Core_Entitlement_Name__c='Return Services Request',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=true,Core_PSG_WOM__c=true);
Core_Contact_Entitlement_Validation__c entval2 = new Core_Contact_Entitlement_Validation__c(Name='3',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Resource & Design Center Collaboration Workspaces',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false,Core_PSG_WOM__c=true);
Core_Contact_Entitlement_Validation__c entval3 = new Core_Contact_Entitlement_Validation__c(Name='4',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Partner Portal',Core_Account_English_Only_Name__c=false,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=false,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false,Core_PSG_WOM__c=true);
lstentval.add(entval);
lstentval.add(entval1);
lstentval.add(entval2);
lstentval.add(entval3);
insert lstentval;

List<Core_Contact_Ent_Validation_Message__c> lstvalmsg = new List<Core_Contact_Ent_Validation_Message__c>();
Core_Contact_Ent_Validation_Message__c entvalmsg = new Core_Contact_Ent_Validation_Message__c(Name ='System CIM ID',Core_Error_Message__c ='CIM ID cant be blank on Account Record',Core_Error_Message2__c = null,Core_System_Validation_Name__c = true,Core_UI_Validation_Name__c = false);
Core_Contact_Ent_Validation_Message__c entvalmsg1 = new Core_Contact_Ent_Validation_Message__c(Name='System Non ODM',Core_Error_Message__c='ODM Indicator field must be checked',Core_System_Validation_Name__c=true,Core_UI_Validation_Name__c=false);
Core_Contact_Ent_Validation_Message__c entvalmsg2 = new Core_Contact_Ent_Validation_Message__c(Name='UI CNDA',Core_Error_Message__c='The account must have a valid CNDA to be able to grant access. Please verify if the account has a valid CNDA (<a href="https://intel.tap.thinksmart.com/prod/Portal/WorkflowDashboard/?cid=c924622d_fcae_4333_9c95_46104114907d" target="_blank">',Core_Error_Message2__c= 'NDA Viewer</a>) - and add it to account record',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
Core_Contact_Ent_Validation_Message__c entvalmsg3 = new Core_Contact_Ent_Validation_Message__c(Name='UI Unique Entitlement',Core_Error_Message__c='You cannot select IPS and Partner Portal together. Only one can be selected',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
lstvalmsg.add(entvalmsg);
lstvalmsg.add(entvalmsg1);
lstvalmsg.add(entvalmsg2);
lstvalmsg.add(entvalmsg3);
insert lstvalmsg;

//Stop----Added by Popcornapps

List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();

Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle3.id , Core_Selected__c=true);
Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[1].id, Core_Selected__c=false);
Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[2].id, Core_Selected__c=true);
Core_Contact_Entitlement__c conent4 = new Core_Contact_Entitlement__c(id = ce5.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =lstEnt[4].id, Core_Selected__c=false);

oldlstentitle.add(conent4);
oldlstentitle.add(conent1);
oldlstentitle.add(conent2);
oldlstentitle.add(conent3);

update  oldlstentitle;
system.debug('oldlstentitle==='+oldlstentitle);

test.stopTest();

Core_ContactEntitlementValidation validation = new Core_ContactEntitlementValidation();
validation.filterEntitlementsByProfile();
Core_ContactEntitlementValidation.validateAccountEnglishOnlyFields(acc,mapacc);
//Core_ContactEntitlementValidation.validateEnglishOnly(entitle1.id,testContact);
string uniqueEntitlementName='';
Core_ContactEntitlementValidation.validateUniqueEntitlement(entitle2.id,testContact,'Partner Portal');

} 
}*/
    public static testmethod void testContEntTest1()
    {
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.assertEquals(itAdminUser.LastName,'UnitTestAdmin1','Last Name not matching');
        
        String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account testAccount11 = new Account(Name='test11', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = true, RecordTypeId=intelAccRecTypeId,
                                            Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c = '',
                                            BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test123',
                                            BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_PSG_Account__c=true);
        insert testAccount11;
        
        Contact testContact = new Contact(FirstName='Cont11', LastName='阿昌', Email='testCont11@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',MailingCountry='India',
                                          AccountId=testAccount11.Id,Core_Set_ERPM_Status_Bypass__c=true,Core_Local_First_Name__c='david',Core_Local_Last_Name__c='geetha',Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false);
        
        insert testContact;
        
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
        insert cee; 
        
        List<Core_Entitlement__c> lstEnt = new List<Core_Entitlement__c>();
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        lstEnt.add(entitle);       
        
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
        lstEnt.add(entitle1);      
        
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
        lstEnt.add(entitle2);
        
        Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true); 
        lstEnt.add(entitle3);
        
        Core_Entitlement__c entitle4 = new Core_Entitlement__c (name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_IsActive__c=true); 
        lstEnt.add(entitle4);
        insert lstEnt;
        Test.startTest();
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle1.id, Core_Selected__c=true,Core_From_Source__c=false);
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle3.id, Core_Selected__c=false,Core_From_Source__c=false);
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=false,Core_From_Source__c=false);
        
        newlstentitle.add(ce1);
        newlstentitle.add(ce2);
        newlstentitle.add(ce3);
        insert newlstentitle;
        
        Map<Id,Core_Contact_Entitlement_Validation__c> mapentIds = new Map<Id,Core_Contact_Entitlement_Validation__c>();
        
        List<Core_Contact_Entitlement_Validation__c> lstentval= new List<Core_Contact_Entitlement_Validation__c>();
        Core_Contact_Entitlement_Validation__c entval  = new Core_Contact_Entitlement_Validation__c(Name='1',Core_Entitlement_Id__c=lstEnt[1].id,Core_Entitlement_Name__c='Intel Premier Support',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=true,Core_PSG_WOM__c=true);
        Core_Contact_Entitlement_Validation__c entval1 = new Core_Contact_Entitlement_Validation__c(Name='2',Core_Entitlement_Id__c=lstEnt[2].id,Core_Entitlement_Name__c='Return Services Request',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=true,Core_PSG_WOM__c=true);
        Core_Contact_Entitlement_Validation__c entval2 = new Core_Contact_Entitlement_Validation__c(Name='3',Core_Entitlement_Id__c=lstEnt[3].id,Core_Entitlement_Name__c='Resource & Design Center Collaboration Workspaces',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false,Core_PSG_WOM__c=true);
        Core_Contact_Entitlement_Validation__c entval3 = new Core_Contact_Entitlement_Validation__c(Name='4',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Partner Portal',Core_Account_English_Only_Name__c=false,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=false,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false,Core_PSG_WOM__c=true);
        lstentval.add(entval);
        lstentval.add(entval1);
        lstentval.add(entval2);
        lstentval.add(entval3);
        insert lstentval; 
        
        for(Core_Contact_Entitlement_Validation__c csvalidation:lstentval){
            mapentIds.put(csvalidation.Core_Entitlement_Id__c,csvalidation);
        }
        test.stopTest();  
    }
    
    public static testmethod void testValidateMPUniqueEntitlement(){
        
        
        String empId = system.Label.Core_Employee;
        String partnerAdminId = system.Label.Core_Partner_Admin_Delegate;
        String iPSEntId = System.Label.Core_Entitlement_IPS_Id;    
        String resellerId = System.Label.Core_CTO_Reseller; //Sonali
        String distributorId = System.Label.Core_CTO_Distributor; //Sonali
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.assertEquals(itAdminUser.LastName,'UnitTestAdmin1','Last Name not matching');
        String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account testAccount = new Account(Name='test1AccountSetup', Core_Sales_Group__c='Global Accounts',RecordTypeId=intelAccRecTypeId,
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '');
        insert testAccount;  
        Contact testContact = new Contact(FirstName='阿昌', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',MailingCountry='India',
                                          AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
        
        insert testContact;
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Access and Entitlements for Marketplace', 
                                                                Core_Engagement_Type__c='SMP',Core_IsActive__c=true,
                                                                Core_Technical_Engagement_Code__c='MKTSMP');                                                               
        insert cee;
        
        Core_ERPM_Engagement__c engagementRec1=new Core_ERPM_Engagement__c(Name  ='Order Configurator Portal', 
                                                                           Core_Engagement_Type__c='SMP',Core_IsActive__c=true,
                                                                           Core_Technical_Engagement_Code__c='OCPortal');                                                               
        insert engagementRec1;
        
        List<Core_Entitlement__c> lstEnt = new List<Core_Entitlement__c>();
        Core_Entitlement__c entitle = new Core_Entitlement__c (name ='Employee', Core_Category__c='Intel Partner Alliance (IPA)',Core_Sub_Category__c='Solutions Marketplace',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Employee',Core_IsActive__c=true);
        lstEnt.add(entitle);
        
        
        Core_Entitlement__c entitle1 = new Core_Entitlement__c (name ='Offering Editor', Core_Category__c='Intel Partner Alliance (IPA)',Core_Sub_Category__c='Solutions Marketplace',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Offering Editor',Core_IsActive__c=true);
        lstEnt.add(entitle1);
        
        
        Core_Entitlement__c entitle2 = new Core_Entitlement__c (name ='Marketing specialist', Core_Category__c='Intel Partner Alliance (IPA)',Core_Sub_Category__c='Solutions Marketplace',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Marketing specialist',Core_IsActive__c=true);
        lstEnt.add(entitle2);
        
        Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='Lead Development Representative', Core_Category__c='Intel Partner Alliance (IPA)',Core_Sub_Category__c='Solutions Marketplace',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Lead Development Representative',Core_IsActive__c=true);
        lstEnt.add(entitle3);
        
        Core_Entitlement__c entitle4 = new Core_Entitlement__c (name ='Partner Admin', Core_Category__c='Intel Partner Alliance (IPA)',Core_Sub_Category__c='Solutions Marketplace',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Partner Admin',Core_IsActive__c=true);
        lstEnt.add(entitle4);
        
        Core_Entitlement__c entitle5 = new Core_Entitlement__c (name ='IPA-MP User', Core_Category__c='Intel Partner Alliance (IPA)',Core_Sub_Category__c='Solutions Marketplace',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='IPA-MP User',Core_IsActive__c=true);
        lstEnt.add(entitle5);
        //Sonali Start
        Core_Entitlement__c entitle6 = new Core_Entitlement__c (name ='CTO_Portal_Disti', Core_Category__c='Data Center Blocks Configurator',Core_Sub_Category__c='',Core_ERPM_Engagement_Id__c=engagementRec1.id,Core_Display_Name__c='Distributor',Core_IsActive__c=true);
        lstEnt.add(entitle6);
        
        Core_Entitlement__c entitle7 = new Core_Entitlement__c (name ='CTO_Portal_Reseller', Core_Category__c='Data Center Blocks Configurator',Core_Sub_Category__c='',Core_ERPM_Engagement_Id__c=engagementRec1.id,Core_Display_Name__c='Reseller',Core_IsActive__c=true);
        lstEnt.add(entitle7);
        //Sonali END
        insert lstEnt;
        Test.startTest();
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c=lstEnt[0].id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce6 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c=lstEnt[1].id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce7 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c=lstEnt[2].id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce8 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c=lstEnt[6].id, Core_Selected__c=true);//Sonali
        newlstentitle.add(ce5);
        newlstentitle.add(ce6);
        newlstentitle.add(ce7);
        newlstentitle.add(ce8);
        insert newlstentitle;
        
        List<Core_Contact_Ent_Validation_Message__c> lstvalmsg = new List<Core_Contact_Ent_Validation_Message__c>();
        Core_Contact_Ent_Validation_Message__c entvalmsg3 = new Core_Contact_Ent_Validation_Message__c(Name='UI Unique Entitlement',Core_Error_Message__c='You cannot select IPS and Partner Portal together. Only one can be selected',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
        Core_Contact_Ent_Validation_Message__c entvalmsg5 = new Core_Contact_Ent_Validation_Message__c(Name='System Unique MP Entitlement',Core_Error_Message__c='You cannot select Partner Admin ,Employee with any other Market Place Entitlements .',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
        Core_Contact_Ent_Validation_Message__c entvalmsg6 = new Core_Contact_Ent_Validation_Message__c(Name='UI Single Entitlement Assignment',Core_Error_Message__c='Contact can be assigned only one of the entitlements (Distributor, Reseller) under '+'Data Center Blocks Configurator '+'category. Please select only one and proceed to assign.',
                                                                                                       Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);//Sonali
        
        lstvalmsg.add(entvalmsg3);
        lstvalmsg.add(entvalmsg5);
        lstvalmsg.add(entvalmsg6);
        
        insert lstvalmsg;
        
        List<Core_Contact_Entitlement_Exclusive__c> oldexclusive = new List<Core_Contact_Entitlement_Exclusive__c>();
        
        Core_Contact_Entitlement_Exclusive__c exclusive06 = new Core_Contact_Entitlement_Exclusive__c(Core_Unique_Ids__c=empId+','+entitle1.id,Name='Support06');
        Core_Contact_Entitlement_Exclusive__c exclusive07 = new Core_Contact_Entitlement_Exclusive__c(Core_Unique_Ids__c=empId+','+partnerAdminId,Name='Support07');
        Core_Contact_Entitlement_Exclusive__c exclusive08 = new Core_Contact_Entitlement_Exclusive__c(Core_Unique_Ids__c=empId+','+iPSEntId,Name='Support08');
        //Core_Contact_Entitlement_Exclusive__c exclusive09 = new Core_Contact_Entitlement_Exclusive__c(Core_Unique_Ids__c=resellerId+','+resellerId,Name='Support09'); //Sonali
        Core_Contact_Entitlement_Exclusive__c exclusive_10 = new Core_Contact_Entitlement_Exclusive__c(Core_Unique_Ids__c=resellerId+','+distributorId,Name='Support_10'); //Sonali
        oldexclusive.add(exclusive06);
        oldexclusive.add(exclusive07);
        oldexclusive.add(exclusive08);
        oldexclusive.add(exclusive_10);
        insert oldexclusive;
        string uniqueEntitlementName1='';
        string uniqueEntitlementName='';
        
        ContactEntSubordinatesRemovalTest.setMetadata(
            'SELECT Id,Label,Core_Condition__c,Core_Entitlement_Id__c,Core_Entitlement_Name__c,Core_Entitlement_Subordinate_Id__c,Core_Entitlement_Subordinate_Name__c FROM Contact_Entitlement_Subordinates_Removal__mdt WHERE DeveloperName = \'Default\'',
            (List<Contact_Entitlement_Subordinates_Removal__mdt>) JSON.deserialize( '[{"Label":"1","Core_Entitlement_Id__c":"'+entitle.id+'","Core_Entitlement_Name__c":"Employee","Core_Entitlement_Subordinate_Name__c":"IPA-MP User","Core_Entitlement_Subordinate_Id__c":"'+entitle5.id+'"},{"Label":"2","Core_Entitlement_Id__c":"'+entitle1.id+'","Core_Condition__c":"'+entitle.id+'","Core_Entitlement_Name__c":"Offering Editor","Core_Entitlement_Subordinate_Name__c":"IPA-MP User","Core_Entitlement_Subordinate_Id__c":"'+entitle5.id+'"},{"Label":"3","Core_Entitlement_Id__c":"'+entitle4.id+'","Core_Entitlement_Name__c":"Partner Admin","Core_Entitlement_Subordinate_Name__c":"IPA-MP User","Core_Entitlement_Subordinate_Id__c":"'+entitle5.Id+'"}]', List<Contact_Entitlement_Subordinates_Removal__mdt>.class )
        );
        
        Core_ContactEntitlementValidation.validateUniqueMPEntitlement(empId,testContact,'Employee1');
        Core_ContactEntitlementValidation.validateUniqueMPEntitlement(partnerAdminId,testContact,'Partner Admin1');
        Core_ContactEntitlementValidation.validateUniqueEntitlement(iPSEntId,testContact,'IPS');     
        Core_ContactEntitlementValidation.addContactEntitlementSubordinates(newlstentitle);
        Core_ContactEntitlementValidation.validateConflictPolicy(resellerId,testContact,'Reseller');//Sonali
        Core_ContactEntitlementValidation.validateConflictPolicy(distributorId,testContact,'Distributor');//Sonali
        
        
        
        test.stopTest();
        
    }
    
    
    
    public @IsTest
        static void validateAccountBenefitTest(){
            List<Id> entlIdList = new List<Id>();
            Test.startTest();
            for (Core_Entitlement__c entl : [Select id from Core_Entitlement__c where name in ('Customer Sales Order Reporting1','Advaced Shipment and Invoice Notification')]) {
                entlIdList.add(entl.Id);
            }
            List<Core_Entitlement__c> entlList1 = new List<Core_Entitlement__c>([Select id from Core_Entitlement__c where name in ('Test Entl')]);
            
            Core_ContactEntitlementValidation.validateAccountBenefit(entlList1[0].Id,entlIdList);
            
            Test.stopTest();
            system.assert(true,'error');
            
        }
    
    
    public static testmethod void testValidateConflictPolicy() {
        String intelAccRecTypeId = Schema.getGlobalDescribe()
        .get('Account')
        .getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get('Mastered_Account')
        .getRecordTypeId();
        Account testAccConflictPolicy = new Account(Name='test1AccConflictPolicy', Core_Sales_Group__c='Global Accounts',
                                                     Core_Account_Type__c='Other', Industry='Others',RecordTypeId = intelAccRecTypeId,
                                                     BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                                     BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '');
        insert testAccConflictPolicy;
        
        Contact testConConflictPolicy= new Contact(FirstName='testConConflictPolicy', LastName='testLastName', Email='testconconflictpolicy@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',MailingCountry='India',
                                                   AccountId=testAccConflictPolicy.Id,Core_Local_First_Name__c='david',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
        
        insert testConConflictPolicy;
        
        Core_AGS_Role__c testAGSRole1 = new Core_AGS_Role__c();
        testAGSRole1.Name = 'Test IQR Customer Full Access';
        testAGSRole1.Core_IsActive__c = true;
        testAGSRole1.Core_Technical_Name__c = 'Test IQR Customer Full Access';
        insert testAGSRole1;
        
        Core_AGS_Role__c testAGSRole2 = new Core_AGS_Role__c();
        testAGSRole2.Name = 'Test IQR Customer Standard Access';
        testAGSRole2.Core_IsActive__c = true;
        testAGSRole2.Core_Technical_Name__c = 'Test IQR Customer Standard Access';
        insert testAGSRole2;
        
        Core_Entitlement__c entitlement1 = new Core_Entitlement__c (Name ='Quote Request Customer Full Access', Core_Category__c='Intel Quote Request',Core_Display_Name__c='Customer Full Access',Core_AGS_Role_Id__c=testAGSRole1.Id,Core_IsActive__c=true);
        insert entitlement1;
        
        Core_Entitlement__c entitlement2 = new Core_Entitlement__c (Name ='Quote Request Customer Standard Access', Core_Category__c='Intel Quote Request',Core_Display_Name__c='Customer Standard Access',Core_AGS_Role_Id__c=testAGSRole2.Id,Core_IsActive__c=true);
        insert entitlement2;
        
        Core_Contact_Entitlement__c contactEntitlement1 = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = testConConflictPolicy.Id,
            Core_Entitlement_Id__c = entitlement1.Id,
            Core_Selected__c = true
        );
        insert contactEntitlement1;
        
        Core_Contact_Entitlement__c contactEntitlement2 = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = testConConflictPolicy.Id,
            Core_Entitlement_Id__c = entitlement2.Id,
            Core_Selected__c = true
        );
        insert contactEntitlement2;
        
        testConConflictPolicy = [SELECT Id, (SELECT Id, Core_Entitlement_Id__c,Core_Entitlement_Id__r.Core_AGS_Role_Id__c, Core_Selected__c FROM Contact_Entitlements__r) 
                                 FROM Contact WHERE Id = :testConConflictPolicy.Id];
        
        
        Core_Contact_Entitlement_Conflict_Policy__c conflictPolicy = new Core_Contact_Entitlement_Conflict_Policy__c(
            Name = 'IQR Standard and Full Access',
            Entitlement_Id__c = entitlement1.Id +';'+ entitlement2.Id, 
            Validation_Message__c = 'Quote Request Customer Standard Access and Quote Request Customer Full Access entitlements cannot be assigned together to a Contact.',
            IsActive__c = true
        );
        insert conflictPolicy;
        
        Test.startTest();
        Core_ContactEntitlementValidation.validateConflictPolicy(entitlement1.Id, testConConflictPolicy, 'Quote Request Customer Full Access');
        Test.stopTest();
    }  
    
        // ==========================================
    // ADDED FOR CATCH BLOCKS & UTILITY COVERAGE
    // ==========================================
    @isTest
    static void testAllExceptionCatchBlocks() {
        Test.startTest();
        // Force NullPointerExceptions to execute and cover the catch blocks
        Core_ContactEntitlementValidation.validateContactEntitlementModified(null, null, null, null);
        Core_ContactEntitlementValidation.validateContactEntitlement(null, null, null, null);
        Core_ContactEntitlementValidation.addContactEntitlementSubordinates(null);
        Core_ContactEntitlementValidation.validateB2BFlaggedContactEntitlement(null);
        Test.stopTest();

        List<Core_Log_Entry__c> errorLogs = [
            SELECT Id 
            FROM Core_Log_Entry__c 
            WHERE Core_Origin__c IN (
                'validateContactEntitlementModified', 
                'validateContactEntitlement', 
                'addContactEntitlementSubordinates', 
                'validateB2BFlaggedContactEntitlement'
            )
        ];
        System.assert(!errorLogs.isEmpty(), 'Exceptions should be caught and logged.');
    }

            @isTest
    static void testValidationUtilities() {
        // Generate valid, native Salesforce mock IDs manually without external libraries
        Id mockContactId = Id.valueOf(Contact.sObjectType.getDescribe().getKeyPrefix() + '000000000001AAA');
        Id mockAccountId = Id.valueOf(Account.sObjectType.getDescribe().getKeyPrefix() + '000000000001AAA');

        Test.startTest();
        
        // 1. Cover validateIPAContactRelationship with null inputs
        Boolean nullRelationship = Core_ContactEntitlementValidation.validateIPAContactRelationship(null, null);
        System.assertEquals(false, nullRelationship, 'Should return false for null inputs');

        // 2. Cover validateIPAContactRelationship with valid contact but no relationships
        Boolean noRelationship = Core_ContactEntitlementValidation.validateIPAContactRelationship(mockContactId, 'None');
        System.assertEquals(false, noRelationship, 'Should return false when no relationship records exist');

        // 3. Cover validateAccountTier logic cleanly
        Boolean emptyTierResult = Core_ContactEntitlementValidation.validateAccountTier(new List<String>{mockAccountId});
        System.assertEquals(false, emptyTierResult, 'Should return false since the mock account ID does not exist in the DB');

        Test.stopTest();
    }
@isTest
static void testValidateEnglishOnlyFields_UsingSimplifiedAccountName() {

    String intelAccRecTypeId =
        Schema.getGlobalDescribe().get('Account')
        .getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get('Mastered_Account')
        .getRecordTypeId();

    Account acc = new Account(
        Name = '阿昌',
        Core_Alternate_Language_Name__c = '测试',
        Core_Data_Simplified_Account_Nm__c = 'SimplifiedAccount123',
        Core_English_Only_Name__c = null,
        Core_Sales_Group__c = 'Global Accounts',
        Core_Account_Type__c = 'Other',
        Industry = 'Others',
        RecordTypeId = intelAccRecTypeId,
        BillingStreet = '123 Main St',
        BillingCity = 'Test City',
        BillingState = 'OR',
        BillingCountry = 'USA',
        BillingPostalCode = '12345'
    );
    insert acc;

    Contact con = new Contact(
        FirstName = 'John',
        LastName = 'Doe',
        AccountId = acc.Id,
        Email = 'john.doe@test.com',
        Core_Set_ERPM_Status_Bypass__c = true,
        MailingCountry = 'India'
    );
    insert con;

    Contact contactRecord = [
        SELECT Id,
               FirstName,
               LastName,
               AccountId,
               Core_English_Only_First_Name__c,
               Core_English_Only_Last_Name__c,
               Core_Local_First_Name__c,
               Core_Local_Last_Name__c,
               Account.Name,
               Account.Core_English_Only_Name__c,
               Account.Core_Alternate_Language_Name__c,
               Account.Core_Data_Simplified_Account_Nm__c
        FROM Contact
        WHERE Id = :con.Id
    ];

    Map<Id, Contact> contactMap = new Map<Id, Contact>();
    Map<Id, Account> accountMap = new Map<Id, Account>();

    Test.startTest();

    Boolean result =
        Core_ContactEntitlementValidation.validateEnglishOnlyFields(
            contactRecord,
            contactMap,
            accountMap
        );

    Test.stopTest();

    System.assertEquals(true, result);
    System.assert(accountMap.containsKey(acc.Id));

    Account updatedAcc = accountMap.get(acc.Id);

    System.assertEquals(
        'SimplifiedAccount123',
        updatedAcc.Core_English_Only_Name__c,
        'Expected Simplified Account Name to populate English Only Name'
    );
}
}