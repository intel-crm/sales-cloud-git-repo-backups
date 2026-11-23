@isTest
public class ContactEntTest_Ealisha {
public static testmethod void testValidateEntitlement_Ealisha(){
    
    
    List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
            
            Core_Trigger_Executions__c accountShareSetting = new Core_Trigger_Executions__c();
            accountShareSetting.Core_Active__c = true;
            accountShareSetting.Core_Class_Name__c = 'Core_ContactEntitlementHandler';
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
		List<Contact> lsttestContact = new List<Contact>();
     Account testAccount = new Account(Name='test1AccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '');
        insert testAccount; 
		 Account testAccount1 = new Account(Name='testAccount143', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = false,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c ='samplename',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                        BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_B2B_Entitlement__c=true);
        insert testAccount1;
 Contact testContact = new Contact(FirstName='阿昌', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
                                          AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
        
        lsttestContact.add(testContact);
		Contact testContact1 = new Contact(FirstName='阿昌', LastName='testLastName', Email='test14x3@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
                                          AccountId=testAccount1.Id,Core_Local_First_Name__c='',Core_Set_ERPM_Status_Bypass__c=false,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,Core_ERPM_Integration_Status__c='Pending');
   
        lsttestContact.add(testContact1);
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
         
         
           List<Core_Contact_Entitlement_Validation_Req__c> contEntValidationReq = new List<Core_Contact_Entitlement_Validation_Req__c>();
            
            Core_Contact_Entitlement_Validation_Req__c cevr1 = new Core_Contact_Entitlement_Validation_Req__c();
            cevr1.Name='2';
            cevr1.Core_Entitlement_id__c='a2W1J0000019iVF';
            cevr1.Core_Entitlement_Name__c='Sales Enablement Portal';
            cevr1.Core_Entitlement_Req_id__c='a2W1J00000035lG';
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
        
        insert lstEnt;
            
        List<Core_Entitlement_Profile_Access__c> lstprofileaccess = new List<Core_Entitlement_Profile_Access__c>();
        
        Core_Entitlement_Profile_Access__c profileaccess = new Core_Entitlement_Profile_Access__c(Core_Entitlements_Allowed__c='ODM/Price Mask',Core_Profile_Id__c=itAdminPrf.id);
        lstprofileaccess.add(profileaccess);
        insert lstprofileaccess;
        
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
		Core_Contact_Ent_Validation_Message__c entvalmsg4 = new Core_Contact_Ent_Validation_Message__c();
            entvalmsg4.Name='System PSG Basic';
            entvalmsg4.Core_Error_Message__c='No PSG basic Engagement for that contact';
            entvalmsg4.Core_Error_Message2__c='';
            entvalmsg4.Core_System_Validation_Name__c=false;
            entvalmsg4.Core_UI_Validation_Name__c=false;
        lstvalmsg.add(entvalmsg);
        lstvalmsg.add(entvalmsg1);
        lstvalmsg.add(entvalmsg2);
        lstvalmsg.add(entvalmsg3);
		lstvalmsg.add(entvalmsg4);
        insert lstvalmsg;
        
        //Stop----Added by Popcornapps





    
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
}
}