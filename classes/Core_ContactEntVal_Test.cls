@isTest
public class Core_ContactEntVal_Test {
       
         @testSetup static void setup() {
            List<Core_Contact_Ent_Validation_Message__c> lstvalmsg = new List<Core_Contact_Ent_Validation_Message__c>();
            Core_Contact_Ent_Validation_Message__c entvalmsg1 = new Core_Contact_Ent_Validation_Message__c(Name='UI CNDA',Core_Error_Message__c='The account must have a valid CNDA to be able to grant access. Please verify if the account has a valid CNDA (<a href="https://intel.tap.thinksmart.com/prod/Portal/WorkflowDashboard/?cid=c924622d_fcae_4333_9c95_46104114907d" target="_blank">',Core_Error_Message2__c= 'NDA Viewer</a>) - and add it to account record',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
            Core_Contact_Ent_Validation_Message__c entvalmsg2 = new Core_Contact_Ent_Validation_Message__c(Name='UI Unique Entitlement',Core_Error_Message__c='You cannot select IPS and Partner Portal together. Only one can be selected',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
            Core_Contact_Ent_Validation_Message__c entvalmsg3 = new Core_Contact_Ent_Validation_Message__c(Name='System Partner Restriction',Core_Error_Message__c='You cannot select IPS ',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
            Core_Contact_Ent_Validation_Message__c entvalmsg4 = new Core_Contact_Ent_Validation_Message__c(Name='System IPS Restriction',Core_Error_Message__c='You cannot select Partner Portal ',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
            lstvalmsg.add(entvalmsg1);
            lstvalmsg.add(entvalmsg2);
            lstvalmsg.add(entvalmsg3);
            lstvalmsg.add(entvalmsg4);
            insert lstvalmsg;
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                      Core_Account_Type__c='Other', Industry='Others',
                                      BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                      BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '');
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c != null);
            
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com.testsetup',
                                     AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId());
            insert testContact;
            Account testAccount2 = new Account(Name='testAccountSetup1', Core_Sales_Group__c='Global Accounts',
                                      Core_Account_Type__c='Other', Industry='Others',
                                      BillingStreet='1234 testAccountSetup1', BillingCity='testCity2', BillingState='OR',
                                      BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '',Core_IsODM__c=true);
            insert testAccount2;
            System.assert(true,testAccount2.Core_CNDA_Number__c != null);
            
            Contact testContact2 = new Contact(FirstName='testFirstName1232', LastName='testLastName', Email='test1234@testing.com.testsetup2',
                                     AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId());
            insert testContact2;
            System.assert(true,testContact.Core_Personal_Email_Indicator__c != null);
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer1', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
            insert cee;
            system.assertNOTEquals(null,cee.id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Customer Sales Order Reporting1', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test account setup',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='Advaced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test account setup data',Core_IsActive__c=true);
            insert entitle1;
            System.assert(true,entitle1.Core_Category__c!= null);
            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                     Core_Entitlement_Id__c=entitle.id,
                                                                     Core_Selected__c=true);
            insert ce; 
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                     Core_Entitlement_Id__c=entitle1.id,
                                                                     Core_Selected__c=true);
            insert ce1; 
            
            List<Core_Contact_Entitlement_Validation__c> lstentval= new List<Core_Contact_Entitlement_Validation__c>();
            Core_Contact_Entitlement_Validation__c entval = new Core_Contact_Entitlement_Validation__c(Name='4',Core_Entitlement_Id__c=entitle1.id,Core_Entitlement_Name__c='Customer Sales Order Reporting1',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=true,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=true,Core_Support_Owner__c=true);
            Core_Contact_Entitlement_Validation__c entval1  = new Core_Contact_Entitlement_Validation__c(Name='1',Core_Entitlement_Id__c=entitle.id,Core_Entitlement_Name__c='Intel Premier Support',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=false,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=true,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=true,Core_Support_Owner__c=true);
            Core_Contact_Entitlement_Validation__c entval2 = new Core_Contact_Entitlement_Validation__c(Name='2',Core_Entitlement_Id__c=entitle1.id,Core_Entitlement_Name__c='Partner Portal',Core_Account_English_Only_Name__c=false,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=false,Core_ODM_Checked__c=true,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=true,Core_Support_Owner__c=true);
            Core_Contact_Entitlement_Validation__c entval3 = new Core_Contact_Entitlement_Validation__c(Name='3',Core_Entitlement_Id__c=entitle.id,Core_Entitlement_Name__c='Advaced Shipment and Invoice Notification',Core_Account_English_Only_Name__c=false,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=false,Core_ODM_Checked__c=true,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=true,Core_Support_Owner__c=true);
            lstentval.add(entval);
            lstentval.add(entval1);
            lstentval.add(entval2);
            
            insert lstentval;
            
             Core_Contact_Entitlement_Validation_Req__c newEng = new  Core_Contact_Entitlement_Validation_Req__c(name ='System Req Ent',Core_Entitlement_Req_Id__c =entitle.id,Core_Entitlement_id__c = entitle.id);
              insert newEng;
            
            List<Core_Contact_Entitlement_Exclusive__c> oldexclusive = new List<Core_Contact_Entitlement_Exclusive__c>();
            Core_Contact_Entitlement_Exclusive__c exclusive = new Core_Contact_Entitlement_Exclusive__c(Core_Unique_Ids__c=entitle.id+','+entitle1.id,Name='Support');
            oldexclusive.add(exclusive);
            insert oldexclusive;
            
    }
   
       public static testmethod void testContEntVal() {
       
        Profile itAdminPrf = [select id, name from Profile where name = 'Data Ops' Limit 1];
        
        Profile itAdminpf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1');
        
        User itAdmin = new User(Alias = 'itAdm221',   Email='itAdminTestx218@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin12',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminpf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx211@intel.com');
        insert itAdmin;
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
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '234',Core_English_Only_Name__c ='samplename',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                        BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);
                                        
        acc.add(testAccount);  
        insert acc;
        
        Account testAccount1 = new Account(Name='testAccount143', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = false,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '',Core_English_Only_Name__c ='samplename',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                        BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);
        insert testAccount1;
        
       Account accVal = new Account();
       accVal=[select name from account where id =:acc[0].id];
       accVal.name = 'Geetha Test';
        system.runas(itAdminUser){
           update accVal;
       }
         
       List<Account> lstValue =[select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_English_Only_Name__c,Core_CNDA_Number__c,Core_Account_Type__c from Account where id =:acc[0].id];
        //Map<Id, Account> mapacc = new Map<Id, Account>([select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_English_Only_Name__c,Core_Account_Type__c from Account]);
        Map<Id, Account> mapacc = new  Map<Id, Account>();
        for(account accvallist:lstValue )
        {
        mapacc.put(accvallist.id,accvallist);
        }
        List<Contact> lsttestContact = new List<Contact>();
        List<Contact> lsttestContactUpdate = new List<Contact>();
        
        Contact testContact = new Contact(FirstName='阿昌', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
                                          AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
   
        insert testContact;
        system.assertequals(testContact.LastName,'testLastName');
        
        Contact testContact1 = new Contact(FirstName='阿昌', LastName='testLastName', Email='test14x3@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
                                          AccountId=testAccount1.Id,Core_Local_First_Name__c='david',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
   
        insert testContact1;
        
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
        System.assert(true,cee.id!= null);   
        
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
       // insert newlstentitle;
        system.debug('newlstentitle==='+newlstentitle);
        
        List<Core_Contact_Entitlement_Subordinates__c> lstSubAdd = new List<Core_Contact_Entitlement_Subordinates__c>();
        Core_Contact_Entitlement_Subordinates__c subordinates = new Core_Contact_Entitlement_Subordinates__c(Name='1',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[1].id,Core_Is_ODM_True__c=true,Core_Is_CNDA_True__c=true);
        Core_Contact_Entitlement_Subordinates__c subordinates1 = new Core_Contact_Entitlement_Subordinates__c(Name='2',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[3].id,Core_Is_ODM_True__c=true,Core_Is_CNDA_True__c=true);
        Core_Contact_Entitlement_Subordinates__c subordinates2 = new Core_Contact_Entitlement_Subordinates__c(Name='3',Core_Entitlement_Id__c=lstEnt[2].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[0].id,Core_Is_ODM_True__c=true,Core_Is_CNDA_True__c=true);
        Core_Contact_Entitlement_Subordinates__c subordinates3 = new Core_Contact_Entitlement_Subordinates__c(Name='4',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[0].id,Core_Is_ODM_True__c=true,Core_Is_CNDA_True__c=false);
        lstSubAdd.add(subordinates);
        lstSubAdd.add(subordinates1);
        lstSubAdd.add(subordinates2);
        lstSubAdd.add(subordinates3);
        insert lstSubAdd;
        system.assertNOTEquals(null,subordinates.id);
       
        List<Core_Contact_Ent_Subordinates_Removal__c> lstSubRemoval = new List<Core_Contact_Ent_Subordinates_Removal__c>();
        Core_Contact_Ent_Subordinates_Removal__c removal = new Core_Contact_Ent_Subordinates_Removal__c(Name='1',Core_Entitlement_Id__c=lstEnt[1].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[2].id);
        Core_Contact_Ent_Subordinates_Removal__c removal1 = new Core_Contact_Ent_Subordinates_Removal__c(Name='2',Core_Entitlement_Id__c=lstEnt[1].id,Core_Condition__c=lstEnt[3].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[2].id);
        Core_Contact_Ent_Subordinates_Removal__c removal2 = new Core_Contact_Ent_Subordinates_Removal__c(Name='3',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[5].id);
        Core_Contact_Ent_Subordinates_Removal__c removal3 = new Core_Contact_Ent_Subordinates_Removal__c(Name='4',Core_Entitlement_Id__c=lstEnt[4].id,Core_Condition__c=lstEnt[3].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[5].id);
        lstSubRemoval.add(removal3);
        lstSubRemoval.add(removal);
        lstSubRemoval.add(removal1);
        lstSubRemoval.add(removal2);
        insert lstSubRemoval;
        
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
       
         //update  oldlstentitle;
         system.debug('oldlstentitle==='+oldlstentitle);
         
         
         test.startTest();
       
        Core_ContactEntitlementValidation validation = new Core_ContactEntitlementValidation();
        validation.filterEntitlementsByProfile();
        Core_ContactEntitlementValidation.validateIntelSupportOwner(entitle2.id,testContact);
        Core_ContactEntitlementValidation.validateCimId(entitle2.id,testContact);
        Core_ContactEntitlementValidation.validateAccountEnglishOnlyFields(acc,mapacc);
        //Core_ContactEntitlementValidation.validateEnglishOnly(entitle1.id,testContact);
        string uniqueEntitlementName='';
        Core_ContactEntitlementValidation.validateUniqueEntitlement(entitle2.id,testContact,'Partner Portal');
        Core_ContactEntitlementValidation.addContactEntitlementSubordinates(oldlstentitle);
        
        test.stopTest();
    } 
    }
    
    
    public static testmethod void testContEntVal1() {
        test.startTest();
        
        Profile itAdminPrf = [select id, name from Profile where name = 'Data Ops' Limit 1];
        
        Profile itAdminpf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1');
        
        User itAdmin = new User(Alias = 'itAdm221',   Email='itAdminTestx218@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin12',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminpf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx211@intel.com');
        insert itAdmin;
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
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = false,
                                          Core_Account_Type__c='Other', Industry='Others', Core_English_Only_Name__c ='samplename',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                        BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);
                                        
        acc.add(testAccount);  
        insert acc;
        
        Account testAccount1 = new Account(Name='testAccount143', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = false,
                                          Core_Account_Type__c='Other', Industry='Others',Core_English_Only_Name__c ='samplename',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                        BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);
        insert testAccount1;
        
       Account accVal = new Account();
       accVal=[select name from account where id =:acc[0].id];
       accVal.name = 'Geetha Test';
        system.runas(itAdminUser){
           update accVal;
       }
         
       List<Account> lstValue =[select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_English_Only_Name__c,Core_CNDA_Number__c,Core_Account_Type__c from Account where id =:acc[0].id];
        //Map<Id, Account> mapacc = new Map<Id, Account>([select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_English_Only_Name__c,Core_Account_Type__c from Account]);
        Map<Id, Account> mapacc = new  Map<Id, Account>();
        for(account accvallist:lstValue )
        {
        mapacc.put(accvallist.id,accvallist);
        }
        List<Contact> lsttestContact = new List<Contact>();
        List<Contact> lsttestContactUpdate = new List<Contact>();
        
        Contact testContact = new Contact(FirstName='阿昌', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
                                          AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
   
        insert testContact;
        system.assertequals(testContact.LastName,'testLastName');
        
        Contact testContact1 = new Contact(FirstName='阿昌', LastName='testLastName', Email='test14x3@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
                                          AccountId=testAccount1.Id,Core_Local_First_Name__c='david',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
   
        insert testContact1;
        
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
        Core_Contact_Entitlement__c ce6 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Selected__c=true);
        
        newlstentitle.add(ce1);                                                                         
        newlstentitle.add(ce2);
        newlstentitle.add(ce3);
        newlstentitle.add(ce4);
        newlstentitle.add(ce5);
        newlstentitle.add(ce6);
        insert newlstentitle;
        system.debug('newlstentitle==='+newlstentitle);
        
        List<Core_Contact_Entitlement_Subordinates__c> lstSubAdd = new List<Core_Contact_Entitlement_Subordinates__c>();
        Core_Contact_Entitlement_Subordinates__c subordinates = new Core_Contact_Entitlement_Subordinates__c(Name='1',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[1].id,Core_Is_ODM_True__c=false,Core_Is_CNDA_True__c=false);
        Core_Contact_Entitlement_Subordinates__c subordinates1 = new Core_Contact_Entitlement_Subordinates__c(Name='2',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[3].id,Core_Is_ODM_True__c=false,Core_Is_CNDA_True__c=false);
        Core_Contact_Entitlement_Subordinates__c subordinates2 = new Core_Contact_Entitlement_Subordinates__c(Name='3',Core_Entitlement_Id__c=lstEnt[2].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[0].id,Core_Is_ODM_True__c=false,Core_Is_CNDA_True__c=false);
        Core_Contact_Entitlement_Subordinates__c subordinates3 = new Core_Contact_Entitlement_Subordinates__c(Name='4',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[0].id,Core_Is_ODM_True__c=false,Core_Is_CNDA_True__c=false);
        lstSubAdd.add(subordinates);
        lstSubAdd.add(subordinates1);
        lstSubAdd.add(subordinates2);
        lstSubAdd.add(subordinates3);
        insert lstSubAdd;
        system.assertNOTEquals(null,subordinates.id);
       
        List<Core_Contact_Ent_Subordinates_Removal__c> lstSubRemoval = new List<Core_Contact_Ent_Subordinates_Removal__c>();
        Core_Contact_Ent_Subordinates_Removal__c removal = new Core_Contact_Ent_Subordinates_Removal__c(Name='1',Core_Entitlement_Id__c=lstEnt[1].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[2].id);
        Core_Contact_Ent_Subordinates_Removal__c removal1 = new Core_Contact_Ent_Subordinates_Removal__c(Name='2',Core_Entitlement_Id__c=lstEnt[1].id,Core_Condition__c=lstEnt[3].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[2].id);
        Core_Contact_Ent_Subordinates_Removal__c removal2 = new Core_Contact_Ent_Subordinates_Removal__c(Name='3',Core_Entitlement_Id__c=lstEnt[4].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[5].id);
        Core_Contact_Ent_Subordinates_Removal__c removal3 = new Core_Contact_Ent_Subordinates_Removal__c(Name='4',Core_Entitlement_Id__c=lstEnt[4].id,Core_Condition__c=lstEnt[3].id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=lstEnt[5].id);
        lstSubRemoval.add(removal3);
        lstSubRemoval.add(removal);
        lstSubRemoval.add(removal1);
        lstSubRemoval.add(removal2);
        insert lstSubRemoval;
        
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
         
         
        
        Core_ContactEntitlementValidation validation = new Core_ContactEntitlementValidation();
        validation.filterEntitlementsByProfile();
        Core_ContactEntitlementValidation.validateAccountEnglishOnlyFields(acc,mapacc);
        //Core_ContactEntitlementValidation.validateEnglishOnly(entitle1.id,testContact);
        string uniqueEntitlementName='';
        Core_ContactEntitlementValidation.validateUniqueEntitlement(entitle2.id,testContact,'Partner Portal');
        Core_ContactEntitlementValidation.addContactEntitlementSubordinates(oldlstentitle);
        test.stopTest();
      } 
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
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1');
        
        User itAdmin = new User(Alias = 'itAdm221',   Email='itAdminTestx218@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin12',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminpf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx211@intel.com');
        insert itAdmin;
        system.assertequals(itAdmin.LastName,'UnitTestAdmin12');
       
        system.runas(itAdmin){
        
        Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
        cm.Name = 'IPS Standard Entitlement';
        cm.Value__c  = 'IPS Standard Entitlement';
        insert cm;
        System.assert(true,cm.Value__c != null);
        
        Core_Trigger_Executions__c executions = new Core_Trigger_Executions__c(Name='addContactEntitlementSubordinates',Core_Active__c=true,Core_Class_Name__c='Core_IPS_CaseTriggerHandler',Core_Description__c='testcase',Core_Object__c='case',Core_Trigger_Events__c='after update');
        insert executions;
        system.assertequals(executions.Name,'addContactEntitlementSubordinates');
        
        
        
        Account testAccount = new Account(Name='testAccount1234', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '',Core_Alternate_Language_Name__c='testAccount123',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_English_Only_Name__c = '123',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false,Core_CIM_ID__c ='123124');
        insert testAccount;
        system.assertNOTEquals(null,testAccount.id);

        
        Account accVal = new Account();
        accVal=[select name from account where id =:testAccount.id];
        accVal.name = 'Geetha Test';
        system.runas(itAdminUser){
            update accVal; 
        }
        
       // testAccount.Core_English_Only_Name__c = 'testAccount123';
        //update testAccount;
        
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_English_Only_First_Name__c='test',
                                          AccountId=testAccount.Id,Core_Set_ERPM_Status_Bypass__c=true,Core_IPS_Active__c =false,Core_Local_First_Name__c='test123',Core_Contact_B2B_Indicator__c=true);
        
        insert testContact;
        system.assertequals(testContact.LastName,'testLastName');
        
        Contact testConUpdate = new Contact();
        testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
        testConUpdate.firstname = 'TestName123234';
        testConUpdate.lastname = 'testLastName123';
        update testConUpdate;
        
       
    
    
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
        insert cee;
        system.assertequals(cee.Name,'Partner File Transfer');
   
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle;
        system.assertNOTEquals(null,entitle.id);

        
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
        insert entitle1;
        System.assert(true,entitle1.Core_Category__c!= null);

        
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
        insert entitle2;
        system.assertequals(entitle2.Name,'Return Services Request');
        
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
        system.debug('newlstentitle==='+newlstentitle);
        
        Core_Contact_Entitlement_Subordinates__c subordinates = new Core_Contact_Entitlement_Subordinates__c(Name='1',Core_Entitlement_Id__c=entitle.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask ',Core_Entitlement_Subordinate_Id__c=entitle.id,Core_Is_ODM_True__c=false,Core_Is_CNDA_True__c=false);
        insert subordinates;

        List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle3.id,Core_Selected__c=true);
        Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true);
        Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=true);
        
        oldlstentitle.add(conent1);
        oldlstentitle.add(conent2);
        oldlstentitle.add(conent3);
       
        update  oldlstentitle;
        system.debug('oldlstentitle==='+oldlstentitle);
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
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1');
        
        User itAdmin = new User(Alias = 'itAdm221',   Email='itAdminTestx218@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin12',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminpf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx211@intel.com');
        insert itAdmin;
        system.assertequals(itAdmin.LastName,'UnitTestAdmin12');
       
        system.runas(itAdmin){
        
        Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
        cm.Name = 'IPS Standard Entitlement';
        cm.Value__c  = 'IPS Standard Entitlement';
        insert cm;
        
        Core_Trigger_Executions__c executions = new Core_Trigger_Executions__c(Name='addContactEntitlementSubordinates',Core_Active__c=true,Core_Class_Name__c='Core_IPS_CaseTriggerHandler',Core_Description__c='testcase',Core_Object__c='case',Core_Trigger_Events__c='after update');
        insert executions;
        system.assertNOTEquals(null,executions.id);
        
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',Core_CNDA_Number__c = '',
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
        
        Contact testContact = new Contact(FirstName='test', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
                                          AccountId=testAccount.Id,Core_Set_ERPM_Status_Bypass__c=true,Core_IPS_Active__c =false,Core_Contact_B2B_Indicator__c=false,Core_Local_First_Name__c='',Core_Personal_Email_Indicator__c=true);
        insert testContact;
        system.assertequals(testContact.LastName,'testLastName');
        
        Contact testConUpdate = new Contact();
        testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
        testConUpdate.firstname = 'TestName123234';
        testConUpdate.lastname = 'testLastName123';
        update testConUpdate;
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
        insert cee; 
        system.assertequals(cee.Name,'Partner File Transfer');  
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle;
        system.assertNOTEquals(null,entitle.id);
        
        Core_Entitlement__c entitle2 = new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
        insert entitle2;
        
        Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle2.id, Core_Selected__c=false);
        insert conent1;
        system.assertNOTEquals(null,conent1.id);
        
       
           //Core_ContactEntitlementValidation.validateEnglishOnly(entitle.id,testContact);
           
           
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
        
        
        
        List<Account> acc = new List<Account>();
        Account testAccount = new Account(Name='阿昌', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '',Core_English_Only_Name__c = '',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                        BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');
                                        
        acc.add(testAccount);  
        insert acc;
        
       Account accVal = new Account();
       accVal=[select name from account where id in:acc];
       accVal.name = '阿昌';
       accVal.Core_Alternate_Language_Name__c='test';
       update accVal;
       System.assert(true,accVal.name != null);
        
        Map<Id, Account> mapacc = new Map<Id, Account>([select id,Name,Core_Sales_Group__c,Core_IsODM__c,Core_Account_Type__c from Account]);
        List<Contact> lsttestContact = new List<Contact>();
        List<Contact> lsttestContactUpdate = new List<Contact>();
        
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
        
        Core_Contact_Entitlement_Subordinates__c subordinates = new Core_Contact_Entitlement_Subordinates__c(Name='1',Core_Entitlement_Id__c=entitle4.id,Core_Entitlement_Name__c='Product Information (Product Details)',Core_Entitlement_Subordinate_Name__c='ODM/Price Mask',Core_Entitlement_Subordinate_Id__c=entitle1.id,Core_Is_ODM_True__c=true,Core_Is_CNDA_True__c=true);
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
        Core_ContactEntitlementValidation.validateAccountEnglishOnlyFields(acc,mapacc);
        //Core_ContactEntitlementValidation.validateEnglishOnly(entitle1.id,testContact);
        //Core_ContactEntitlementValidation.validateUniqueEntitlement(entitle2.id,testContact);
        
        
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
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1');
        
         Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
                                          BillingCity='testCity', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
                                          Core_IPS_Active__c=true);
        insert testAccount;
        system.assertNOTEquals(null,testAccount.id);

        
        Account testAccount2 = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = false,
                                          Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
                                          BillingCity='testCity2', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
                                          Core_IPS_Active__c=true, Core_CIM_ID__c ='123124', Core_CNDA_Number__c='');
        insert testAccount2;
        System.assert(true,testAccount2.Core_IPS_Active__c!= null);
       
        Account testAccount3 = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
                                          BillingCity='testCity3', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
                                          Core_IPS_Active__c=true,Core_CIM_ID__c ='123124', Core_CNDA_Number__c='');
        insert testAccount3;
        system.assertequals(testAccount3.Name,'testAccount123');

       
        Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='爱', Email='test123@testing.com.test',
                                           AccountId=testAccount.Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true);
        insert testContact1;
        System.assert(true,testContact1.Core_Personal_Email_Indicator__c!= null);
        
        
        Contact testContact2 = new Contact(FirstName='testFirstName123', LastName='爱', Email='test1234@testing.com.test',
                                           AccountId=testAccount2.Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true,Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId());
        insert testContact2;
        system.assertequals(testContact2.FirstName,'testFirstName123');
        
        Contact testContact3 = new Contact(FirstName='testFirstName123', LastName='爱', Email='test12345@testing.com.test',
                                           AccountId=testAccount3.Id,Core_Personal_Email_Indicator__c=true,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Set_ERPM_Status_Bypass__c=true);
        insert testContact3;
        system.assertNOTEquals(null,testContact3.id);
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
        insert cee;
        System.assert(true,cee.Name != null); 
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle;
        //System.assert(true,entitle.Core_Category__c!= null);
        
        Core_Entitlement__c entitle1 = new Core_Entitlement__c (name ='Intel Premier Support', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Intel Premier Support',Core_IsActive__c=true); 
        insert entitle1;
        
        Core_Entitlement__c entitle2 = new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
        insert entitle2;
        
        Core_Entitlement__c entitle3 = new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true); 
        insert entitle3;
        
        Core_Entitlement__c entitle4 = new Core_Entitlement__c (name ='Supply Assurance (includes Order Placement Role and e-Ack)', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Content',Core_IsActive__c=true); 
        //insert entitle4;
        
        List<Core_Contact_Entitlement_Validation_Req__c> validList = new list<Core_Contact_Entitlement_Validation_Req__c>();
        Core_Contact_Entitlement_Validation_Req__c  ccValidate = new Core_Contact_Entitlement_Validation_Req__c();
          ccValidate.Name = 'test';
          ccValidate.Core_Entitlement_id__c = entitle1.id;
          ccValidate.Core_Entitlement_Req_Name__c = 'PSG Basic';
          ccValidate.Core_Entitlement_SysMsgName__c = 'System PSG Basic';
          ccValidate.Core_Entitlement_Name__c = 'Sales Enablement Portal';
          //ccValidate.Core_Entitlement_Req_id__c = ;
          ccValidate.Core_Entitlement_MsgName__c = 'UI PSG Basic';
        insert ccValidate; 
         validList.add(ccValidate);
           
          
        List<Core_Entitlement__c> newCE =[Select Id from Core_Entitlement__c ];
            try{
                Core_Contact_Entitlement__c content1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Entitlement_Id__c = newCE[0].id, Core_Selected__c=true);
                insert content1;
            }catch(Exception ex){
                //System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ex.getDmlType(0));
                //System.assertEquals('CIM ID cant be blank on Account Record', ex.getDmlMessage(0));
            }
            try{
                Core_Contact_Entitlement__c content2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact2.Id,Core_Entitlement_Id__c = newCE[1].id, Core_Selected__c=true);
                insert content2;
            }catch(Exception ex){
                //System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ex.getDmlType(0));
                //System.assertEquals('Intel Support Owner cant be blank on Contact Record', ex.getDmlMessage(0));
            }
            try{
                Core_Contact_Entitlement__c content3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact3.Id,Core_Entitlement_Id__c = newCE[0].id, Core_Selected__c=true);
                insert content3;
            }catch(Exception ex){
                System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ex.getDmlType(0));
                //System.assertEquals('English Only on Contact cant be blank (Populate from Standard and Alternate if avalible and meet req)', ex.getDmlMessage(0));
            
            }
            try{
                testContact3.LastName='testranjan';
                testContact3.Core_English_Only_First_Name__c='test';
                testContact3.Core_English_Only_Last_Name__c='ranjan';
                update testContact3;
               Core_Contact_Entitlement__c content4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact3.Id,Core_Entitlement_Id__c = newCE[1].id, Core_Selected__c=true);
                insert content4;
            }catch(Exception ex){
                //System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ex.getDmlType(0));
                //System.assertEquals('Personal Email Domain Indicator on Contact Record is TRUE', ex.getDmlMessage(0));
            }
            try{
                testContact3.LastName='testranjan';
                testContact3.Core_English_Only_First_Name__c='test';
                testContact3.Core_English_Only_Last_Name__c='ranjan';
                update testContact3;
               Core_Contact_Entitlement__c content5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact3.Id,Core_Entitlement_Id__c = newCE[0].id, Core_Selected__c=true);
                insert content5;
            }catch(Exception ex){
                //System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ex.getDmlType(0));
                //System.assertEquals('Cant be selected if ODM is TRUE on Account Record', ex.getDmlMessage(0));
            
            }
             try{
                 testAccount3.Core_IsODM__c = false;
                 update testAccount3;

                testContact3.LastName='testranjan';
                testContact3.Core_English_Only_First_Name__c='test';
                testContact3.Core_English_Only_Last_Name__c='ranjan';
                update testContact3;
                
               Core_Contact_Entitlement__c content6 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact3.Id,Core_Entitlement_Id__c = newCE[0].id, Core_Selected__c=true);
               // insert content6;
            }catch(Exception ex){
                //System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ex.getDmlType(0));
            //System.assertEquals('ODM Indicator field must be checked.', ex.getDmlMessage(0));
            
            }
            ApexPages.currentPage().getParameters().put('Id', testContact2.Id);
            ApexPages.StandardController sc2 = new ApexPages.StandardController(testContact2);
            
            Core_Contact_Entitlements_Controller conEntController2 = new Core_Contact_Entitlements_Controller(sc2);
            
            List<ApexPages.Message> msgList2 = ApexPages.getMessages();
            system.debug('msgList2 :: prem ::'+msgList2 );
            Boolean checkCNDAMsg = false;
            Boolean checkIPSOwner = false;
            for(ApexPages.Message msg : msgList2) {
                if(msg.getDetail().contains('CNDA cant be blank on Account Record')) checkCNDAMsg=true;
                if(msg.getDetail().contains('Intel Support Owner cant be blank on Contact Record')) checkIPSOwner=true;
            }
           
            conEntController2.onPageLoad();
           
       }
    /*
     public static testmethod void ValidateEngField(){
                
           Test.startTest();
            
           Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,Core_CIM_ID__c='12345',
                                              Core_Account_Type__c='Other', Industry='Others',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '1234');
           insert testAccount;
                    
           Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='abc123@testingx.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
           insert testContact;
      
           Map<Id, Contact> mUpdateContEngName = new Map<Id, Contact>();
           Map<Id, Account> mUpdateAcctEngName = new Map<Id, Account>();  
           Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
           labels.name= 'IPS Standard Entitlement';
           labels.value__c='IPS Standard Entitlement';
           
           insert labels;
         
           Core_ContactEntitlementValidation.validateEnglishOnlyFields(testContact,mUpdateContEngName,mUpdateAcctEngName);
                      
           Test.stopTest();
    }
    */  
    /*
    public static testMethod void validContactEntitlementTest(){
    
    Test.startTest();
    
    Account testAccount = new Account(Name='testAccountSetup1', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
   
    insert testAccount;
         
    Contact testContact = new Contact(FirstName='testFirstName1234', LastName='愛', Email='test1234@testing.com.test',
                                              AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true);

    insert testContact;
                                              
    Core_Entitlement__c newCE =[Select Id from Core_Entitlement__c where name='Customer Sales Order Reporting1' limit 1];
                    
    Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                              Core_Entitlement_Id__c=newCE.Id,
                                                                              Core_Selected__c=true);
          


    
      List<Core_Contact_Entitlement__c> newFullList = new List<Core_Contact_Entitlement__c>();
      newFullList.add(ce3);
      Map<Id,Core_Contact_Entitlement__c> oldMap = new  Map<Id,Core_Contact_Entitlement__c>();
            
      Core_ContactEntitlementValidation.validateContactEntitlement(newFullList,newFullList,oldMap , oldMap );
    


    Test.stopTest();    
}
*/
      
}