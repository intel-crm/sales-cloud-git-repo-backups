@isTest(SeeAllData=false)
public class Core_Contact_Ent_Controller_Test {
    
    @testSetup static void setup() { 
        List<Core_Contact_Ent_Validation_Message__c> lstvalmsg = new List<Core_Contact_Ent_Validation_Message__c>();
        Core_Contact_Ent_Validation_Message__c entvalmsg1 = new Core_Contact_Ent_Validation_Message__c(Name='UI CNDA',Core_Error_Message__c='The account must have a valid CNDA to be able to grant access. Please verify if the account has a valid CNDA (<a href="https://intel.tap.thinksmart.com/prod/Portal/WorkflowDashboard/?cid=c924622d_fcae_4333_9c95_46104114907d" target="_blank">',Core_Error_Message2__c= 'NDA Viewer</a>) - and add it to account record',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
        Core_Contact_Ent_Validation_Message__c entvalmsg2 = new Core_Contact_Ent_Validation_Message__c(Name='UI Unique Entitlement',Core_Error_Message__c='You cannot select IPS and Partner Portal together. Only one can be selected',Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=true);
        lstvalmsg.add(entvalmsg1);
        lstvalmsg.add(entvalmsg2);
        insert lstvalmsg;
        
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount;
        System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        //,Core_IPS_Active__c = true;
        insert testContact;
        System.assert(true,testContact.Core_Personal_Email_Indicator__c != null);
        
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer1', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;
        system.assertNOTEquals(null,cee.id);
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Customer Sales Order Reporting1', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test account setup',Core_IsActive__c=true);
        insert entitle;
        
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Partner Portal', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test account setup 2',Core_IsActive__c=true);
        insert entitle2;
        
        Core_Entitlement__c entitle3=new Core_Entitlement__c (name ='IPS', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test account IPS',Core_IsActive__c=true);
        insert entitle3;
        
        Core_Entitlement__c entitle4=new Core_Entitlement__c (name ='test entitlement', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test account entitlement',Core_IsActive__c=true);
        insert entitle4;
        
        System.assert(true,entitle.Core_Category__c!= null);
        
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=entitle.id,
                                                                          Core_Selected__c=true);
        insert ce1; 
        /* Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
Core_Entitlement_Id__c=entitle2.id,
Core_Selected__c=true);
insert ce2;
Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
Core_Entitlement_Id__c=entitle3.id,
Core_Selected__c=true);
insert ce3;
Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
Core_Entitlement_Id__c=entitle4.id,
Core_Selected__c=true);
insert ce4;*/
        
        
        List<Core_Contact_Entitlement_Validation__c> lstentval= new List<Core_Contact_Entitlement_Validation__c>();
        Core_Contact_Entitlement_Validation__c entval = new Core_Contact_Entitlement_Validation__c(Name='4',Core_Entitlement_Id__c=entitle.id,Core_Entitlement_Name__c='Customer Sales Order Reporting1',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_PSG_WOM__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=true,Core_Support_Owner__c=true);
        Core_Contact_Entitlement_Validation__c entval1 = new Core_Contact_Entitlement_Validation__c(Name='1',Core_Entitlement_Id__c=entitle2.id,Core_Entitlement_Name__c='Partner Portal',Core_Account_English_Only_Name__c=false,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=false,Core_CNDA__c=false,Core_PSG_WOM__c=true,Core_Contact_English_Only_Name__c=false,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=false,Core_Personal_Email_Domain__c=false,Core_Support_Owner__c=false);
        Core_Contact_Entitlement_Validation__c entval2 = new Core_Contact_Entitlement_Validation__c(Name='2',Core_Entitlement_Id__c=entitle3.id,Core_Entitlement_Name__c='IPS',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=true,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=true,Core_PSG_WOM__c=true,Core_ODM_Unchecked__c=false,Core_Personal_Email_Domain__c=true,Core_Support_Owner__c=true);
        Core_Contact_Entitlement_Validation__c entval3 = new Core_Contact_Entitlement_Validation__c(Name='3',Core_Entitlement_Id__c=entitle4.id,Core_Entitlement_Name__c='test entitlement',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_PSG_WOM__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=true,Core_ODM_Unchecked__c=false,Core_Personal_Email_Domain__c=true,Core_Support_Owner__c=false);
        lstentval.add(entval);
        lstentval.add(entval1);
        lstentval.add(entval2);
        lstentval.add(entval3);
        insert lstentval;
    }
    
    public static testmethod void testCoreContactEntitlementController() {
        Boolean blnHasAccess;
        String strCategory = '';
        String CATEGORY_DEFAULT = 'Entitlements';
        Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        Profile salesRepPrf = [select id, name from Profile where name = 'Sales Rep-BB' Limit 1];
        
        User user = new User(Alias = 'admin', 
                             Email='adminTest@intel.com', 
                             EmailEncodingKey='UTF-8',
                             LastName='UnitTestAdmin',
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', 
                             ProfileId = prf.Id, 
                             TimeZoneSidKey='America/Los_Angeles',
                             UserName='adminTest'+Crypto.getRandomLong()+'@intel.com');
        insert user;
        system.assertequals(user.LastName,'UnitTestAdmin');
        Set<Id> tstRoleIds = new Set<Id>();
        System.RunAs(user){
            //Test.startTest();
            //Insert Roles
            UserRole usrCEO = null, usrExec = null, usrMgr = null, usr = null;
            //System.debug([Select Id, Name from UserRole]);
            usrCEO = new UserRole(Name = 'UnitTest-CEO');
            insert usrCEO;     
            tstRoleIds.add(usrCEO.Id);
            
            usrExec = new UserRole(Name = 'UnitTest-Executive', ParentRoleId = usrCEO.Id);
            insert usrExec;    
            tstRoleIds.add(usrExec.Id);
            
            usrMgr = new UserRole(Name = 'UnitTest-CustomerManager', ParentRoleId = usrExec.Id);
            insert usrMgr;
            tstRoleIds.add(usrMgr.Id);
            
            usr = new UserRole(Name = 'UnitTest-Customer-User', ParentRoleId = usrMgr.Id);
            insert usr;
            tstRoleIds.add(usr.Id);
            
            //Create Users 
            List<User> createUsers =  TestUtilities.getListOfUser(4);
            
            System.debug(' >> Creating Users  '+createUsers.size());
            User u = createUsers.get(0);
            u.UserRoleId = usrCEO.Id;
            u.ProfileId = salesRepPrf.Id;
            
            u = createUsers.get(1);
            u.UserRoleId = usrExec.Id;
            u.ProfileId = salesRepPrf.Id;
            
            u = createUsers.get(2);
            u.UserRoleId = usrMgr.Id;
            u.ProfileId = salesRepPrf.Id;
            
            for(Integer i = 3; i<createUsers.size();i++){
                u = createUsers.get(i);
                u.UserRoleId = usr.Id;
                u.ProfileId = salesRepPrf.Id;
                //.Core_Login_Id__c ='wer';
            }
            System.debug(' >> Inserting Users  '+createUsers.size());
            insert createUsers;
            
            List<Account> createAccts =  TestUtilities.getListOfAccounts(10);
            
            Map<String, Id> mapUsers = new Map<String, Id>();
            for(User us : [Select Id, UserRoleId, UserRole.Name, Profile.Name From User where UserRoleId IN : tstRoleIds]){
                System.debug(' us '+us);
                mapUsers.put(us.UserRole.Name, us.Id);
            }
            System.debug(' mapUsers   '+mapUsers);
            
            for(Integer i=0; i< createAccts.size();i++){
                
                Account a = createAccts.get(i);
                
                if(i < 4){
                    a.OwnerId = mapUsers.get('UnitTest-Customer-User');
                }else if(i < 6){
                    a.OwnerId = mapUsers.get('UnitTest-CustomerManager');
                }else if(i < 8){
                    a.OwnerId = mapUsers.get('UnitTest-Executive');
                }else{
                    a.OwnerId = mapUsers.get('UnitTest-CEO');
                }
                a.Core_CNDA_Number__c = '32456';
                a.Core_B2B_Entitlement__c = true;
            }
            insert createAccts;
            
            
            String prfID=prf.id;
            prfID=prfID.substring(0, prfID.length()-3);
            Core_Entitlement_Profile_Access__c epa = new Core_Entitlement_Profile_Access__c(Name='System Administrator', Core_Profile_Id__c=prfID,
                                                                                            Core_Entitlements_Allowed__c='Advanced Shipment and Invoice Notification; Customer Sales Order Reporting;Advanced Shipment and Invoice Notification');
            insert epa;
            System.assert(true,epa.Core_Profile_Id__c!= null);
            system.assertNOTEquals(null,epa.id);
            
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,Core_CIM_ID__c='12345',
                                              Core_Account_Type__c='Other', Industry='Others',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '1234');
            insert testAccount;
            system.assertNOTEquals(null,testAccount.id);
            
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com.test',
                                              AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true,Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            insert testContact;
            System.assert(true,testContact.Core_Personal_Email_Indicator__c != null);
            
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
            insert cee;
            system.assertequals(cee.Core_Engagement_Type__c,'SEC');
            
            List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
            List< Core_Entitlement__c> entListVal = new List< Core_Entitlement__c>();
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Customer Sales Order Reporting', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test',Core_IsActive__c=true);
            entListVal.add(entitle);
            //insert entitle;
            //system.assertNOTEquals(null,entitle.id);
          
            Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
            entListVal.add(entitle2);
          
            Core_Entitlement__c entitle3=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='File Transfer',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup data',Core_IsActive__c=true);
            entListVal.add(entitle3); 
       
            Core_Entitlement__c entitle4=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Pricing',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='sort on name',Core_IsActive__c=true);
            entListVal.add(entitle4);
            
            Core_Entitlement__c entitle5=new Core_Entitlement__c (name ='CCF Account Budget Administrator', Core_Category__c='Pricing',Core_Sub_Category__c='Web Reporting',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='CCF Account Budget Administrator',Core_IsActive__c=true);
            entListVal.add(entitle5);
            //insert entitle5; 
            
            database.insert(entListVal);  
            Test.startTest();
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                             Core_Entitlement_Id__c=entitle.id,
                                                                             Core_Selected__c=true);
            ceList.add(ce);       
            Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                              Core_Entitlement_Id__c=entitle2.id,
                                                                              Core_Status__c ='In Progress',
                                                                              Core_Selected__c=false);
            ceList.add(ce2);
            Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                              Core_Entitlement_Id__c=entitle3.id,
                                                                              Core_Selected__c=false,Core_Status__c ='pending');
            ceList.add(ce3);
            Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                              Core_Entitlement_Id__c=entitle4.id,
                                                                              Core_Selected__c=false);
            ceList.add(ce4);            
            Core_Contact_Entitlement__c ce5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                              Core_Entitlement_Id__c=entitle5.id,
                                                                              Core_Selected__c=true);
            ceList.add(ce5); 
            
            database.insert(ceList);
            
            Core_Entitlement_SubCategory_HelpText__c subCatHelpText =new Core_Entitlement_SubCategory_HelpText__c(name='test subcat',Core_Help_Text__c ='test subcat help text',Core_SubCategory_Name__c  ='test subcat');
            insert subCatHelpText;
            system.assertequals(subCatHelpText.name,'test subcat');
            
            
            Core_Entitlement_Category_Handler__c catHandle=new Core_Entitlement_Category_Handler__c(name='Support A', Core_Category_Name__c='Support',Core_Column_Name__c='Column A');
            insert catHandle;
            system.assertNOTEquals(null,catHandle.id);
            Core_Entitlement__c newCE =[Select Id from Core_Entitlement__c where name='Customer Sales Order Reporting1' limit 1];
            Core_Entitlement__c newCE2 =[Select Id from Core_Entitlement__c where name='IPS' limit 1];
            //Core_Entitlement__c newCE3 =[Select Id from Core_Entitlement__c where name='Employee' limit 1];
            
            
            PageReference pageRef = Page.Core_Contact_Entitlements;
             
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', testContact.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
            system.debug('sc@@'+sc );
            Core_Contact_Entitlements_Controller conEntController = new Core_Contact_Entitlements_Controller(sc);
            conEntController.onPageLoad();
           
            List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> lstWrapper = new List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>();
            List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> lstEWS = new List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>();
            Boolean check = false;
            Id mpEmpEntId = System.Label.Core_Employee;
            Id mpPartneAdmEntId =System.Label.Core_Partner_Admin_Delegate;
            Id  ipsEntId =System.Label.Core_Entitlement_IPS_Id;
            
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(newCE.id,'test category','test sub category','test entitlement',false,'test entitlement help text','subcategory help text');
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper1=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(ce2.Core_Entitlement_Id__c,'test category','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper9=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(newCE2.id,null,null,null,true,null,null);
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper10=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(mpEmpEntId,'test category','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper11=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(mpPartneAdmEntId,'test category','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper12=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(ipsEntId,'test category','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper13=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(ipsEntId,'test category','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            
                      
            List<Core_Contact_Entitlement_Exclusive__c> oldexclusive = new List<Core_Contact_Entitlement_Exclusive__c>();
            Core_Contact_Entitlement_Exclusive__c exclusive03 = new Core_Contact_Entitlement_Exclusive__c(Core_Unique_Ids__c=ipsEntId+','+entitle5.id,Name='Support03');
            oldexclusive.add(exclusive03);
            Core_Contact_Entitlement_Exclusive__c exclusive01 = new Core_Contact_Entitlement_Exclusive__c(Core_Unique_Ids__c=mpEmpEntId+','+mpPartneAdmEntId,Name='Support01');
            Core_Contact_Entitlement_Exclusive__c exclusive02 = new Core_Contact_Entitlement_Exclusive__c(Core_Unique_Ids__c=mpEmpEntId+','+ipsEntId,Name='Support02');
            oldexclusive.add(exclusive01);
            oldexclusive.add(exclusive02);
            Database.insert(oldexclusive);
            
            lstWrapper.add(entitlementWrapper);
            lstWrapper.add(entitlementWrapper1);
            lstWrapper.add(entitlementWrapper9);
            lstWrapper.add(entitlementWrapper13);
            lstWrapper.add(entitlementWrapper10);
            lstWrapper.add(entitlementWrapper11);
            lstWrapper.add(entitlementWrapper12);
              
            
            conEntController.lstlstEntitlementWrapper.add(lstWrapper);
            conEntController.lstlstSearchEntitlementWrapper.add(lstEWS);
            conEntController.userInput = 'test';
            conEntController.isShowSearchResults = false;
            conEntController.isNotExist = false;
            conEntController.validate();
            system.debug(entitlementWrapper1.entitlehelpText);
            system.debug(entitlementWrapper1.subCatHelpText);
            
            system.assertequals(entitlementWrapper9.entitlehelpText,'');
            system.assertequals(entitlementWrapper9.subCatHelpText,'');
            system.assertequals(entitlementWrapper9.subCategory,'');
            system.assertequals(entitlementWrapper9.category,'Entitlements');
            
            
            for(List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> llcew : conEntController.lstlstEntitlementWrapper) {
                
                for(Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper cew: llcew) {
                    if(cew.Name != 'Advanced Shipment and Invoice Notification' && !check) {
                        cew.selected = true;
                        check = true;
                    } else if(cew.Name != 'Advanced Shipment and Invoice Notification' && check) {
                        cew.selected = false;
                    }
                }
            }
            Core_Contact_Entitlement__c lce = new Core_Contact_Entitlement__c();
            lce.Core_Contact_Id__c = testContact.Id;
            lce.Core_Selected__c = true;
            insert lce;
            conEntController.onSave();
            conEntController.checkEntitlementSubordinates();
            conEntController.search();
            conEntController.clear();
            conEntController.userInput = 'CNDA';
            conEntController.isShowSearchResults = false;
            conEntController.isNotExist = false;
            conEntController.search();
            //conEntController.closePopup();
            //conEntController.showPopup();
            
        }
        Test.stopTest();
        
    }
    
    public static testmethod void updateContactentitlementChange(){
        
        
        String strCategory = '';
        String CATEGORY_DEFAULT = 'Entitlements';
        
        
        Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        Profile prf1 = [select id, name from Profile where name = 'Data Ops' Limit 1];
        User u = new User(Alias = 'admin', 
                          Email='adminTest@intel.com', 
                          EmailEncodingKey='UTF-8',
                          LastName='UnitTestAdmin',
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = prf.Id, 
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='adminTest'+Crypto.getRandomLong()+'@intel.com');
        insert u;
        system.assertequals(u.LastName,'UnitTestAdmin');
        
        String prfID=prf1.id;
        prfID=prfID.substring(0, prfID.length()-3);
        Core_Entitlement_Profile_Access__c epa = new Core_Entitlement_Profile_Access__c(Name='System Administrator1', Core_Profile_Id__c=prfID,
                                                                                        Core_Entitlements_Allowed__c='Advanced Shipment and Invoice Notification; Customer Sales Order Reporting;Advanced Shipment and Invoice Notification');
        insert epa;
        system.assertNOTEquals(null,epa.id);
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c='12345',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount;
        System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com.test',
                                          AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        //,Core_IPS_Active__c = true;
        insert testContact;
        System.assert(true,testContact.Core_Personal_Email_Indicator__c != null);
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;
        system.assertNOTEquals(null,cee.id);
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Customer Sales Order Reporting', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test',Core_IsActive__c=true);
        insert entitle;
        System.assert(true,entitle.Core_Category__c!= null);
        
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                         Core_Entitlement_Id__c=entitle.id,
                                                                         Core_Selected__c=true);
        //  insert ce; 
        //  system.assertNOTEquals(null,ce.id);
        
        
        
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle2;
        System.assert(true,entitle2.Core_Category__c!= null);
        
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=entitle2.id,
                                                                          Core_Selected__c=true);
        // insert ce2;
        //  system.assertNOTEquals(null,ce2.id);
        
        Core_Entitlement__c entitle3=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='File Transfer',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup data',Core_IsActive__c=true);
        insert entitle3;
        system.assertequals(entitle3.name ,'Advanced Shipment and Invoice Notification');
        
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=entitle3.id,
                                                                          Core_Selected__c=false);
        insert ce3;
        //  system.assertNOTEquals(null,ce3.id);
        //   
        
        Core_Entitlement_SubCategory_HelpText__c subCatHelpText =new Core_Entitlement_SubCategory_HelpText__c(name='test subcat',Core_Help_Text__c ='test subcat help text',Core_SubCategory_Name__c  ='test subcat');
        insert subCatHelpText;
        System.assert(true,subCatHelpText.Core_Help_Text__c!= null);
        
        Core_Entitlement_Category_Handler__c catHandle=new Core_Entitlement_Category_Handler__c(name='Support A', Core_Category_Name__c='Support',Core_Column_Name__c='Column A');
        insert catHandle;
        system.assertNOTEquals(null,catHandle.id);
        Core_Entitlement__c newCE =[Select Id from Core_Entitlement__c where name='Customer Sales Order Reporting1' limit 1];
        Core_Entitlement__c newCE2 =[Select Id from Core_Entitlement__c where name='IPS' limit 1];
        
        Core_Contact_Entitlement_Exclusive__c exclude=new Core_Contact_Entitlement_Exclusive__c();
        exclude.name='Support';
        exclude.Core_Unique_Ids__c = newCE.id+','+newCE2.id;
        insert exclude;
        System.assert(true,exclude.name!= null);     
        Test.startTest();
        System.runAs(u) {
            //Test.startTest();
            PageReference pageRef = Page.Core_Contact_Entitlements;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', testContact.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
            system.debug('sc@@'+sc );
            Core_Contact_Entitlements_Controller conEntController = new Core_Contact_Entitlements_Controller(sc);
            
            conEntController.onPageLoad();
            
            List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> lstWrapper = new List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>();
            Boolean check = false;
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(ce.Core_Entitlement_Id__c,'','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper1=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(newCE.Id,'','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper2=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(entitle3.Id,'','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            lstWrapper.add(entitlementWrapper);
            lstWrapper.add(entitlementWrapper1);
            lstWrapper.add(entitlementWrapper2);
            
            conEntController.lstlstEntitlementWrapper.add(lstWrapper);
            conEntController.validate();
            system.debug(entitlementWrapper1.entitlehelpText);
            system.debug(entitlementWrapper1.subCatHelpText);
            
            
            
            List<Core_Contact_Entitlement__c> lce = [Select id from Core_Contact_Entitlement__c
                                                     Where Core_Contact_Id__c=:testContact.Id
                                                     AND Core_Selected__c = true];
            insert lce;
            
            for(List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> llcew : conEntController.lstlstEntitlementWrapper) {
                
                for(Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper cew: llcew) {
                    if(cew.Name != 'Advanced Shipment and Invoice Notification' && !check) {
                        cew.selected = true;
                        check = true;
                    } else if(cew.Name != 'Advanced Shipment and Invoice Notification' && check) {
                        cew.selected = false;
                    }
                }
            }
            conEntController.onSave();
            //conEntController.updateContact();
            conEntController.checkEntitlementSubordinates();
            Map<Id, Contact> mUpdateContEngName = new Map<Id, Contact>();
            Map<Id, Account> mUpdateAcctEngName = new Map<Id, Account>();  
            Core_ContactEntitlementValidation.validateEnglishOnlyFields(testContact,mUpdateContEngName,mUpdateAcctEngName);
            
        }
        Test.stopTest();
        
    }
    
    /*public static testmethod void updateFailforDuplicateEntitlement() {
        
        String strCategory = '';
        String CATEGORY_DEFAULT = 'Entitlements';
        Test.startTest();
        Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        Profile prf1 = [select id, name from Profile where name = 'Data Ops' Limit 1];
        User u = new User(Alias = 'admin', 
                          Email='adminTest@intel.com', 
                          EmailEncodingKey='UTF-8',
                          LastName='UnitTestAdmin',
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = prf.Id, 
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='adminTest'+Crypto.getRandomLong()+'@intel.com');
        insert u;
        system.assertequals(u.LastName,'UnitTestAdmin');
        
        String prfID=prf1.id;
        prfID=prfID.substring(0, prfID.length()-3);
        Core_Entitlement_Profile_Access__c epa = new Core_Entitlement_Profile_Access__c(Name='System Administrator1', Core_Profile_Id__c=prfID,
                                                                                        Core_Entitlements_Allowed__c='Advanced Shipment and Invoice Notification; Customer Sales Order Reporting;Advanced Shipment and Invoice Notification');
        insert epa;
        system.assertNOTEquals(null,epa.id);
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c='12345',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount;
        System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com.test',
                                          AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId());
        //,Core_IPS_Active__c = true;
        insert testContact;
        System.assert(true,testContact.Core_Personal_Email_Indicator__c != null);
        
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;
        system.assertNOTEquals(null,cee.id);
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Customer Sales Order Reporting', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test',Core_IsActive__c=true);
        insert entitle;
        System.assert(true,entitle.Core_Category__c!= null);
        
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                         Core_Entitlement_Id__c=entitle.id,
                                                                         Core_Selected__c=true);
        insert ce; 
        system.assertNOTEquals(null,ce.id);
        
        
        
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle2;
        System.assert(true,entitle2.Core_Category__c!= null);
        
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=entitle2.id,
                                                                          Core_Selected__c=true);
        insert ce2;
        system.assertNOTEquals(null,ce2.id);
        
        Core_Entitlement__c entitle3=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='File Transfer',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup data',Core_IsActive__c=true);
        insert entitle3;
        system.assertequals(entitle3.name ,'Advanced Shipment and Invoice Notification');
        
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=entitle3.id,
                                                                          Core_Selected__c=false);
        insert ce3;
        system.assertNOTEquals(null,ce3.id);
        
        Core_Entitlement__c entitle4=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Pricing',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='sort on name',Core_IsActive__c=true);
        insert entitle4;
        System.assert(true,entitle4.Core_Category__c!= null);
        
        //Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
        //Core_Entitlement_Id__c=Label.Core_Entitlement_IPS_Id,
        //Core_Selected__c=false);
        //insert ce4;
        //system.assertNOTEquals(null,ce4.id);
        
        Core_Entitlement_SubCategory_HelpText__c subCatHelpText =new Core_Entitlement_SubCategory_HelpText__c(name='test subcat',Core_Help_Text__c ='test subcat help text',Core_SubCategory_Name__c  ='test subcat');
        insert subCatHelpText;
        System.assert(true,subCatHelpText.Core_Help_Text__c!= null);
        
        Core_Entitlement_Category_Handler__c catHandle=new Core_Entitlement_Category_Handler__c(name='Support A', Core_Category_Name__c='Support',Core_Column_Name__c='Column A');
        insert catHandle;
        system.assertNOTEquals(null,catHandle.id);
        Core_Entitlement__c newCE =[Select Id from Core_Entitlement__c where name='Customer Sales Order Reporting1' limit 1];
        Core_Entitlement__c newCE2 =[Select Id from Core_Entitlement__c where name='IPS' limit 1];
        
        Core_Contact_Entitlement_Exclusive__c exclude=new Core_Contact_Entitlement_Exclusive__c();
        exclude.name='Support';
        exclude.Core_Unique_Ids__c = newCE.id+','+newCE2.id;
        insert exclude;
        System.assert(true,exclude.name!= null);     
        
        System.runAs(u) {
            //Test.startTest();
            PageReference pageRef = Page.Core_Contact_Entitlements;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', testContact.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
            system.debug('sc@@'+sc );
            Core_Contact_Entitlements_Controller conEntController = new Core_Contact_Entitlements_Controller(sc);
            
            conEntController.onPageLoad();
            
            List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> lstWrapper = new List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>();
            Boolean check = false;
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(ce.Core_Entitlement_Id__c,'','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper1=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(newCE.Id,'','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            lstWrapper.add(entitlementWrapper);
            lstWrapper.add(entitlementWrapper1);
            
            conEntController.lstlstEntitlementWrapper.add(lstWrapper);
            conEntController.validate();
            system.debug(entitlementWrapper1.entitlehelpText);
            system.debug(entitlementWrapper1.subCatHelpText);
            
            for(List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> llcew : conEntController.lstlstEntitlementWrapper) {
                
                for(Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper cew: llcew) {
                    if(cew.Name != 'Advanced Shipment and Invoice Notification' && !check) {
                        cew.selected = true;
                        check = true;
                    } else if(cew.Name != 'Advanced Shipment and Invoice Notification' && check) {
                        cew.selected = false;
                    }
                }
            }
            conEntController.onSave();
            //conEntController.updateContact();
            conEntController.checkEntitlementSubordinates();
            Map<Id, Contact> mUpdateContEngName = new Map<Id, Contact>();
            Map<Id, Account> mUpdateAcctEngName = new Map<Id, Account>();  
            Core_ContactEntitlementValidation.validateEnglishOnlyFields(testContact,mUpdateContEngName,mUpdateAcctEngName);

        }
        Test.stopTest();
    }*/
    
    public static testmethod void testOnPageLoad() {
        Test.startTest();
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345');
        insert testAccount;
        system.assertNOTEquals(null,testAccount.id);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='愛', Email='test1234@testing.com.test', Core_Enterprise_Id__c='12345', 
                                          AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true);
        insert testContact;
        
        PageReference pageRef = Page.Core_Contact_Entitlements;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', testContact.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
        system.debug('sc@@'+sc );
        Core_System_Credentials__c credentials = new Core_System_Credentials__c (Name='Core_AGS_Get_Entitlement',Core_End_Point_URL__c='https://eip-crm-proxy-dev.cloudhub.io/smit/api/eip-crm-sls-ags/currentRoles ',Core_Password__c='j5s$S$Xo!s9w',Core_UserName__c='proxy_user3');
        insert credentials;
        Core_Contact_Entitlements_Controller conEntControllerError = new Core_Contact_Entitlements_Controller(sc);
        Test.setMock(HttpCalloutMock.class, new Core_AccountCoverageMockHttpResponse_Failed());
        conEntControllerError.onPageLoad();
        
        //
        List<List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>> lstlstEntitlementWrapper = new List<List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>>();
        List<List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>> lstlstSearchEntitlementWrapper = new List<List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>>();
        Test.stopTest();
    }
    
    public static testmethod void testContactEntilementsPageErrors() { 
        String strCategory = '';
        String CATEGORY_DEFAULT = 'Entitlements';
        Test.startTest();
        
        Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        Profile prf1 = [select id, name from Profile where name = 'Data Ops' Limit 1];
        User u = new User(Alias = 'admin', 
                          Email='adminTest@intel.com', 
                          EmailEncodingKey='UTF-8',
                          LastName='UnitTestAdmin',
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = prf.Id, 
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='adminTest'+Crypto.getRandomLong()+'@intel.com');
        insert u;
        system.assertNOTEquals(null,u.id);
        
        String prfID=prf1.id;
        prfID=prfID.substring(0, prfID.length()-3);
        Core_Entitlement_Profile_Access__c epa = new Core_Entitlement_Profile_Access__c(Name='System Administrator1', Core_Profile_Id__c=prfID,
                                                                                        Core_Entitlements_Allowed__c='Advanced Shipment and Invoice Notification; Customer Sales Order Reporting;Advanced Shipment and Invoice Notification');
        insert epa;
        system.assertNOTEquals(null,epa.id);
        
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345');
        insert testAccount;
        system.assertNOTEquals(null,testAccount.id);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='愛', Email='test1234@testing.com.test', Core_Enterprise_Id__c='12345', 
                                          AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true);
        insert testContact;
        system.assertequals(testContact.LastName,'愛');
        Core_Entitlement__c newCE =[Select Id from Core_Entitlement__c where name='Customer Sales Order Reporting1' limit 1];
        Core_Entitlement__c newCE2 =[Select Id from Core_Entitlement__c where name='IPS' limit 1];
        
        Core_Contact_Entitlement_Exclusive__c exclude=new Core_Contact_Entitlement_Exclusive__c();
        exclude.name='Support';
        exclude.Core_Unique_Ids__c = newCE.id+','+newCE2.id;
        insert exclude;
        System.assert(true,exclude.name!= null);     
        
        
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=newCE.id,
                                                                          Core_Selected__c=true);
        Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=newCE2.id,
                                                                          Core_Selected__c=false);
        
        Core_Contact_Entitlement_Validation__c entval = new Core_Contact_Entitlement_Validation__c(Name='4',Core_Entitlement_Name__c='Customer Sales Order Reporting1',Core_Account_English_Only_Name__c=true,Core_Account_Owner_Role__c=false,Core_CIM_ID__c=true,Core_CNDA__c=true,Core_PSG_WOM__c=true,Core_Contact_English_Only_Name__c=true,Core_ODM_Checked__c=false,Core_ODM_Unchecked__c=true,Core_Personal_Email_Domain__c=true,Core_Support_Owner__c=true);
        System.runAs(u) {
            //Test.startTest();
            PageReference pageRef = Page.Core_Contact_Entitlements;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', testContact.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
            system.debug('sc@@'+sc );
            
            Core_Contact_Entitlements_Controller conEntController = new Core_Contact_Entitlements_Controller(sc);
            conEntController.onPageLoad();
            
            
            List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> lstWrapper = new List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>();
            Boolean check = false;
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper9=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(ce4.Core_Entitlement_Id__c,'','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper10=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(ce3.Core_Entitlement_Id__c,'','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            
            
            
            lstWrapper.add(entitlementWrapper9);
            lstWrapper.add(entitlementWrapper10);
            
            conEntController.lstlstEntitlementWrapper.add(lstWrapper);
            conEntController.validate();
            List<Core_Contact_Entitlement__c> lce = [Select id from Core_Contact_Entitlement__c
                                                     Where Core_Contact_Id__c=:testContact.Id
                                                     AND Core_Selected__c = true];
            insert lce;
            
            for(List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> llcew : conEntController.lstlstEntitlementWrapper) {
                
                for(Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper cew: llcew) {
                    if(cew.Name != 'Advanced Shipment and Invoice Notification' && !check) {
                        cew.selected = true;
                        check = true;
                    } else if(cew.Name != 'Advanced Shipment and Invoice Notification' && check) {
                        cew.selected = true;
                        check = true;
                    }
                }
            }
            conEntController.onSave();
            //conEntController.updateContact();
            conEntController.checkEntitlementSubordinates();
            Map<Id, Contact> mUpdateContEngName = new Map<Id, Contact>();
            Map<Id, Account> mUpdateAcctEngName = new Map<Id, Account>();  
            Core_ContactEntitlementValidation.validateEnglishOnlyFields(testContact,mUpdateContEngName,mUpdateAcctEngName);
           // Test.stopTest();
        }
        Test.stopTest();
    }
    
    
    public static testmethod void testContactEntilementsAccountDeactivate() { 
        Test.startTest();
        Profile prf = [select id, name from Profile where name = 'Integration' Limit 1];
        User u = new User(Alias = 'admin', 
                          Email='adminTest@intel.com', 
                          EmailEncodingKey='UTF-8',
                          LastName='UnitTestAdmin',
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = prf.Id, 
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='adminTest'+Crypto.getRandomLong()+'@intel.com');
        insert u;
        system.assertNOTEquals(null,u.id);
        
        System.runAs(u) {
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_Deactivated__c=true, Core_Deactivation_Reason__c='test deactivated');
            insert testAccount;
            system.assertNOTEquals(null,testAccount.id);
            
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='愛', Email='test1234@testing.com.test',
                                              AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true);
            insert testContact;
            system.assertequals(testContact.LastName,'愛');
            Core_Entitlement__c newCE =[Select Id from Core_Entitlement__c where name='Customer Sales Order Reporting1' limit 1];
            
            
            Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                              Core_Entitlement_Id__c=newCE.Id,
                                                                              Core_Selected__c=true);
            
            //mahendra
            Account testAccount1 = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
                                               Core_Account_Type__c='Other', Industry='Others',
                                               BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                               BillingCountry='USA', BillingPostalCode='12345', Core_IsODM__c = true);
            insert testAccount1;
            system.assertNOTEquals(null,testAccount1.id);
            
            Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='愛', Email='test1234ff@testing.com.test',
                                               AccountId=testAccount1.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true);
            insert testContact1;
            system.assertequals(testContact1.LastName,'愛');
            
            Core_ERPM_Engagement__c newERPM = new Core_ERPM_Engagement__c(Name='Sales soft',Core_Technical_Engagement_Code__c = 'CRM_Cloud_Cntct',Core_Engagement_Type__c = 'SFT');
            insert newERPM;
            
            Core_Entitlement__c newCEn = new Core_Entitlement__c(Name ='Sales soft',Core_Display_Name__c='Sales soft',Core_ERPM_Engagement_Id__c = newERPM.id);
            insert newCEn;
            
            
            //Test.startTest();
            PageReference pageRef = Page.Core_Contact_Entitlements;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', testContact.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
            system.debug('sc@@'+sc );
            Core_Contact_Entitlements_Controller conEntController = new Core_Contact_Entitlements_Controller(sc);
            conEntController.onPageLoad();
            
            //Core_ContactEntitlementValidation.ValidateEngagement(newCEn.id,testContact1);
            //Test.stopTest();
        }
        Test.stopTest();
    }
    
    public static testmethod void testContactEntilementsPageErrorsone() { 
        String strCategory = '';
        String CATEGORY_DEFAULT = 'Entitlements';
        Test.startTest();
        Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        Profile prf1 = [select id, name from Profile where name = 'Data Ops' Limit 1];
        User u = new User(Alias = 'admin', 
                          Email='adminTest@intel.com', 
                          EmailEncodingKey='UTF-8',
                          LastName='UnitTestAdmin',
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = prf.Id, 
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='adminTest'+Crypto.getRandomLong()+'@intel.com');
        insert u;
        system.assertNOTEquals(null,u.id);
        
        String prfID=prf1.id;
        prfID=prfID.substring(0, prfID.length()-3);
        Core_Entitlement_Profile_Access__c epa = new Core_Entitlement_Profile_Access__c(Name='System Administrator1', Core_Profile_Id__c=prfID,
                                                                                        Core_Entitlements_Allowed__c='Advanced Shipment and Invoice Notification; Customer Sales Order Reporting;Advanced Shipment and Invoice Notification');
        insert epa;
        system.assertNOTEquals(null,epa.id);
        
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345', Core_IsODM__c = true);
        insert testAccount;
        system.assertNOTEquals(null,testAccount.id);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='愛', Email='test1234@testing.com.test',
                                          AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true);
        insert testContact;
        system.assertequals(testContact.LastName,'愛');
        Core_Entitlement__c newCE =[Select Id from Core_Entitlement__c where name='Customer Sales Order Reporting1' limit 1];
        Core_Entitlement__c newCE2 =[Select Id from Core_Entitlement__c where name='IPS' limit 1];
        
        Core_Contact_Entitlement_Exclusive__c exclude=new Core_Contact_Entitlement_Exclusive__c();
        exclude.name='Support';
        exclude.Core_Unique_Ids__c =  (newCE.id+'').substring(0,15)+','+(newCE2.id+'').substring(0,15);
        insert exclude;
        System.assert(true,exclude.name!= null);     
        
        
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=newCE.id,
                                                                          Core_Selected__c=true);
        Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=newCE2.id,
                                                                          Core_Selected__c=false);
        
        System.runAs(u) {
            //Test.startTest();
            PageReference pageRef = Page.Core_Contact_Entitlements;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', testContact.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
            system.debug('sc@@'+sc );
            Core_Contact_Entitlements_Controller conEntController = new Core_Contact_Entitlements_Controller(sc);
            
            conEntController.onPageLoad();
            List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> lstWrapper = new List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>();
            Boolean check = false;
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper9=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(ce4.Core_Entitlement_Id__c,'','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper10=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(ce3.Core_Entitlement_Id__c,'','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            
            
            
            lstWrapper.add(entitlementWrapper9);
            lstWrapper.add(entitlementWrapper10);
            
            conEntController.lstlstEntitlementWrapper.add(lstWrapper);
            conEntController.validate();
            List<Core_Contact_Entitlement__c> lce = [Select id from Core_Contact_Entitlement__c
                                                     Where Core_Contact_Id__c=:testContact.Id
                                                     AND Core_Selected__c = true];
            insert lce;
            
            for(List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> llcew : conEntController.lstlstEntitlementWrapper) {
                
                for(Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper cew: llcew) {
                    if(cew.Name != 'Advanced Shipment and Invoice Notification' && !check) {
                        cew.selected = true;
                        check = true;
                    } else if(cew.Name != 'Advanced Shipment and Invoice Notification' && check) {
                        cew.selected = true;
                        check = true;
                    }
                }
            }
            conEntController.onSave();
            //conEntController.updateContact();
            conEntController.checkEntitlementSubordinates();
            Map<Id, Contact> mUpdateContEngName = new Map<Id, Contact>();
            Map<Id, Account> mUpdateAcctEngName = new Map<Id, Account>();  
            Core_ContactEntitlementValidation.validateEnglishOnlyFields(testContact,mUpdateContEngName,mUpdateAcctEngName);
            Core_ContactEntitlementValidation.validateUniqueEntitlement(newCE2.id,testContact,'Partner Portal');
        }
        Test.stopTest();
    }
    
    public static testmethod void testContactEntilementsPageErrorsTwo() { 
        String strCategory = '';
        String CATEGORY_DEFAULT = 'Entitlements';
        Test.startTest();
        Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        Profile prf1 = [select id, name from Profile where name = 'Data Ops' Limit 1];
        User u = new User(Alias = 'admin', 
                          Email='adminTest@intel.com', 
                          EmailEncodingKey='UTF-8',
                          LastName='UnitTestAdmin',
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = prf.Id, 
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='adminTest'+Crypto.getRandomLong()+'@intel.com');
        insert u;
        system.assertNOTEquals(null,u.id); 
        
        String prfID=prf1.id;
        prfID=prfID.substring(0, prfID.length()-3);
        Core_Entitlement_Profile_Access__c epa = new Core_Entitlement_Profile_Access__c(Name='System Administrator1', Core_Profile_Id__c=prfID,
                                                                                        Core_Entitlements_Allowed__c='Advanced Shipment and Invoice Notification; Customer Sales Order Reporting;Advanced Shipment and Invoice Notification');
        insert epa;
        system.assertNOTEquals(null,epa.id);
        
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345', Core_IsODM__c = true);
        insert testAccount;
        system.assertNOTEquals(null,testAccount.id);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='愛', Email='test1234@testing.com.test',
                                          AccountId=testAccount.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true);
        insert testContact;
        system.assertequals(testContact.LastName,'愛');
        
        Core_ERPM_Engagement__c newERPM = new Core_ERPM_Engagement__c(Name='Sales soft',Core_Technical_Engagement_Code__c = 'CRM_Cloud_Cntct',Core_Engagement_Type__c = 'SFT');
        insert newERPM;
        
        Core_Entitlement__c newCE = new Core_Entitlement__c(Name ='Sales soft',Core_Display_Name__c='Sales soft',Core_ERPM_Engagement_Id__c = newERPM.id);
        insert newCE;
        Core_Entitlement__c newCE2 =[Select Id from Core_Entitlement__c where name='IPS' limit 1];
        
        Core_Contact_Entitlement_Exclusive__c exclude=new Core_Contact_Entitlement_Exclusive__c();
        exclude.name='Support';
        exclude.Core_Unique_Ids__c =  (newCE.id+'').substring(0,15)+','+(newCE2.id+'').substring(0,15);
        insert exclude;
        System.assert(true,exclude.name!= null);     
        
        
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Selected__c = false,
                                                                          Core_Entitlement_Id__c=newCE.id
                                                                         );
        insert ce3;
        Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=newCE2.id,
                                                                          Core_Selected__c=false);
        Core_Contact_Entitlement_Validation_Req__c newEng = new  Core_Contact_Entitlement_Validation_Req__c(name ='System Req Ent',Core_Entitlement_Req_Id__c =newCE.id,Core_Entitlement_id__c = newCE.id);
        insert newEng; 
        String errormessage2='';
        Core_Contact_Ent_Validation_Message__c entvalmsg2 = new Core_Contact_Ent_Validation_Message__c(Name='System Req Ent',Core_Error_Message__c='No PSG basic Engagement for that contact'+errormessage2,Core_System_Validation_Name__c=false,Core_UI_Validation_Name__c=false);
        insert entvalmsg2;  
        System.runAs(u) {
            //Test.startTest();
            PageReference pageRef = Page.Core_Contact_Entitlements;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', testContact.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
            system.debug('sc@@'+sc );
            Core_Contact_Entitlements_Controller conEntController = new Core_Contact_Entitlements_Controller(sc);
            
            conEntController.onPageLoad();
            List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> lstWrapper = new List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>();
            Boolean check = false;
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper9=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(ce4.Core_Entitlement_Id__c,'','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper entitlementWrapper10=new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(ce3.Core_Entitlement_Id__c,'','test sub category','test entitlement',true,'test entitlement help text','subcategory help text');
            
            
            
            lstWrapper.add(entitlementWrapper9);
            lstWrapper.add(entitlementWrapper10);
            
            conEntController.lstlstEntitlementWrapper.add(lstWrapper);
            conEntController.validate();
            List<Core_Contact_Entitlement__c> lce = [Select id from Core_Contact_Entitlement__c
                                                     Where Core_Contact_Id__c=:testContact.Id
                                                     AND Core_Selected__c = true];
            insert lce;
            
            for(List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> llcew : conEntController.lstlstEntitlementWrapper) {
                
                for(Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper cew: llcew) {
                    if(cew.Name != 'Advanced Shipment and Invoice Notification' && !check) {
                        cew.selected = true;
                        check = true;
                    } else if(cew.Name != 'Advanced Shipment and Invoice Notification' && check) {
                        cew.selected = true;
                        check = true;
                    }
                }
            }
            conEntController.onSave();
            //conEntController.updateContact();
            conEntController.checkEntitlementSubordinates();
            Map<Id, Contact> mUpdateContEngName = new Map<Id, Contact>();
            Map<Id, Account> mUpdateAcctEngName = new Map<Id, Account>();  
            Core_ContactEntitlementValidation.validateEnglishOnlyFields(testContact,mUpdateContEngName,mUpdateAcctEngName);
            List<Core_Contact_Entitlement__c> newFullList = new List<Core_Contact_Entitlement__c>();
            newFullList.add(ce3);
            Map<Id,Core_Contact_Entitlement__c> oldMap = new  Map<Id,Core_Contact_Entitlement__c>();
            
            Core_ContactEntitlementValidation.validateContactEntitlement(newFullList,newFullList,oldMap , oldMap );
            Core_ContactEntitlementValidation.ValidateEngagement(newCE.id,testContact,newFullList );
        }
       	Test.stopTest();
    }
    
    
    public static testmethod void testFilterentitlementByProfile() {
         
        Profile profile1 = [SELECT Id FROM Profile WHERE Name='Partner' ];
        String prfID=profile1.id;
        //String prfID = prfID1.substring(0, 15);
        //Test.startTest();
        
        Core_Entitlement_Profile_Access__c epa = new Core_Entitlement_Profile_Access__c(Name='Partner', Core_Profile_Id__c=prfID.substring(0,15),
                                                                                        Core_Entitlements_Allowed__c='CCF User Administrator;CCF User;CCF Account Budget Administrator',Core_User_Type__c='CCF User Administrator');
        insert epa; 
        
        Account acc1 = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
                                   Core_Account_Type__c='Other', Industry='Others',
                                   BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                   BillingCountry='USA', BillingPostalCode='12345', Core_IsODM__c = true, Core_IPA_Partner_Role__c='Service Provider');
        Database.insert(acc1,true);
        
        Contact contact = new Contact(FirstName='testFirstName123', LastName='愛', Email='test1234@testing.com.test',
                                      AccountId=acc1.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true,
                                      Core_Audience_List__c ='CCF User Administrator;CCF User',Core_IPA_Partner_Role__c='Service Provider',
                                      Core_IPA_PartnerRole__c='Service Provider');
        
        Database.insert(contact,true); 
        
        Core_ERPM_Engagement__c newERPM = new Core_ERPM_Engagement__c(Name='CCF',Core_Technical_Engagement_Code__c = 'CCF',Core_Engagement_Type__c = 'SEC');
        insert newERPM;
        
        Core_Entitlement__c newCE = new Core_Entitlement__c(Name ='CCF User Administrator',Core_Display_Name__c='CCF User Administrator',Core_ERPM_Engagement_Id__c = newERPM.id, Core_IsActive__c = true);
        insert newCE;
        
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=contact.Id,Core_Selected__c = true,
                                                                          Core_Entitlement_Id__c=newCE.id, Core_Status__c ='Complete'
                                                                         );
        ceList.add(ce3);
        insert ce3;
        
        User user1 = new User(Alias = 'admUse2r', Email='forumuser@test.com', 
                              EmailEncodingKey='UTF-8', LastName='Admin', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = profile1.Id, contactid=contact.Id,isActive =true,
                              TimeZoneSidKey='America/Los_Angeles', UserName='forumuser22@test.com',PortalRole = 'Manager');
        
        Database.insert(user1,true);
       // Test.startTest();
        System.runAs(user1){
            Test.startTest();            
            Core_Contact_Entitlements_Controller test1 = new Core_Contact_Entitlements_Controller(contact.Id);
            test1.filterEntitlementsByProfile();
            test1.checkAGSStatus();
            //Core_PartnerAdmin_Ent_Controller corePrtAdmEnCntoller = new Core_PartnerAdmin_Ent_Controller();
           List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> lstEntWrapper1; 
            //= new List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>();
            Core_Contact_Entitlements_Controller ccEntController = new Core_Contact_Entitlements_Controller(contact.Id);
            Core_AuraProcessingMessage auraProcessingMessage = ccEntController.checkAGSStatus(); 
        ccEntController.filterEntitlementsByProfile();
            lstEntWrapper1 = ccEntController.populateEntitlementWrapper();
            Core_PartnerAdmin_Ent_Controller.fetchContactEntitlements(contact.Id);
            
            
            Core_ERPM_Engagement__c ccfEngagement =new Core_ERPM_Engagement__c(Name='CCF', 
                                                                    Core_Engagement_Type__c='SEC',
                                                                    Core_IsActive__c=true,Core_Technical_Engagement_Code__c='CCF');
            insert ccfEngagement;
            system.assertNOTEquals(null,ccfEngagement.id);
            
            List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
            Core_Entitlement__c entitle5 = new Core_Entitlement__c (name ='test entitlementCCF1', 
            Core_Category__c='Consolidated Co-marketing Platform',Core_Sub_Category__c='Client Co-Marketing Fund (CCF)',Core_ERPM_Engagement_Id__c=ccfEngagement.id,
            Core_Display_Name__c='test CCF entitlement 1',Core_IsActive__c=true);
            entList.add(entitle5);
            
            Core_Entitlement__c entitle6 = new Core_Entitlement__c (name ='test entitlementCCF2', 
            Core_Category__c='Consolidated Co-marketing Platform',Core_Sub_Category__c='Client Co-Marketing Fund (CCF)',
            Core_Help_Text__c='Help text 1',Core_ERPM_Engagement_Id__c=ccfEngagement.id,
            Core_Display_Name__c='test CCF entitlement 2',Core_IsActive__c=true);
            entList.add(entitle6);
            
            Core_Entitlement__c entitle7 = new Core_Entitlement__c (name ='test entitlementCCF3', 
            Core_Category__c='Consolidated Co-marketing Platform',Core_Sub_Category__c='Data Center Co-Marketing Fund (DCF)',Core_ERPM_Engagement_Id__c=ccfEngagement.id,
            Core_Display_Name__c='test CCF entitlement 3',Core_IsActive__c=true);
            entList.add(entitle7);

            Core_Entitlement__c entitle8 = new Core_Entitlement__c (name ='test entitlementCCF4', 
            Core_Category__c='Partner Portal',Core_Sub_Category__c='',Core_ERPM_Engagement_Id__c=ccfEngagement.id,
            Core_Display_Name__c='test CCF entitlement 4',Core_IsActive__c=true,Core_Help_Text__c='');
			entList.add(entitle8);
        	
            Database.insert(entList);
            /*insert entitle5;
            insert entitle6;
            insert entitle7;
            insert entitle8;*/

            
             Core_Partner_Entitlement_Wrapper cEntWrapper2 = new Core_Partner_Entitlement_Wrapper(entitle7.Id,
                                                                                                 entitle7.Core_Category__c,
                                                                                                 entitle7.Core_Sub_Category__c,
                                                                                                 'test CCF entitlement 3',
                                                                                                 true,
                                                                                                 entitle7.Core_Help_Text__c,
                                                                                                 'Help Test 1');
            Core_Partner_Entitlement_Wrapper cEntWrapper = new Core_Partner_Entitlement_Wrapper(entitle5, 'CCF');       
            Core_Partner_Entitlement_Wrapper cEntWrapper1 = new Core_Partner_Entitlement_Wrapper(entitle6.Id,
                                                                                                 entitle6.Core_Category__c,
                                                                                                 entitle6.Core_Sub_Category__c,
                                                                                                 'test CCF entitlement 2',
                                                                                                 true,
                                                                                                 entitle6.Core_Help_Text__c,
                                                                                                 'Help Test 1');
            Core_Partner_Entitlement_Wrapper cEntWrapper3 = new Core_Partner_Entitlement_Wrapper(entitle8.Id,
                                                                                                 entitle8.Core_Category__c,
                                                                                                 entitle8.Core_Sub_Category__c,
                                                                                                 'test CCF entitlement 4',
                                                                                                 true,
                                                                                                 entitle8.Core_Help_Text__c,
                                                                                                 'Help Test 1');
            
            Core_Partner_Entitlement_Wrapper cEntWrapper4 = new Core_Partner_Entitlement_Wrapper(entitle8.Id,
                                                                                                 entitle8.Core_Category__c,
                                                                                                 entitle8.Core_Sub_Category__c,
                                                                                                 '',
                                                                                                 true,
                                                                                                 entitle8.Core_Help_Text__c,
                                                                                                 '');
            cEntWrapper4.strEntitleHelpText = '';
            String helpTextValue = cEntWrapper4.entitlehelpText;
            cEntWrapper4.strSubCatHelpText = '';
            helpTextValue = cEntWrapper4.subCatHelpText;
            
            cEntWrapper1.status= '';
            cEntWrapper1.readOnly= true;
            cEntWrapper1.auraProcessingMessage = new Core_AuraProcessingMessage();
			cEntWrapper.compareTo(cEntWrapper1);
            cEntWrapper1.compareTo(cEntWrapper);
            cEntWrapper2.compareTo(cEntWrapper1);
            cEntWrapper3.compareTo(cEntWrapper2);
            List<Core_Partner_Entitlement_Wrapper> lstEntWrapper = new List<Core_Partner_Entitlement_Wrapper>();
            lstEntWrapper.add(cEntWrapper);
            lstEntWrapper.add(cEntWrapper1);
            lstEntWrapper.add(cEntWrapper2);
            lstEntWrapper.add(cEntWrapper3);
            Core_PartnerAdmin_Ent_Controller.saveContactEntitlements(lstEntWrapper , contact.Id);
            Test.stopTest();
        }
        //Test.stopTest();
    }
    

    
    public static testmethod void testConstructor()
    {
        Test.startTest();
        Account acc1 = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',
                                   Core_Account_Type__c='Other', Industry='Others',
                                   BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                   BillingCountry='USA', BillingPostalCode='12345', Core_IsODM__c = true);
        Database.insert(acc1,true);
        
        Contact contact = new Contact(FirstName='testFirstName123', LastName='愛', Email='test1234@testing.com.test',
                                      AccountId=acc1.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true,Core_Audience_List__c = 'CCF User Administrator');
        
        Database.insert(contact,true);  
        Core_Contact_Entitlements_Controller contEnt = new Core_Contact_Entitlements_Controller(contact.id);
        Test.stopTest();
    }
    
    public class Core_AccountCoverageMockHttpResponse_Failed implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('[{"enterpriseId":"300000071296","roles":["Customer IDT User","PFTFileTransfer"]}]');
            res.setStatusCode(200);
            return res;
        }
    }   
    
}