/**************************************************************************************
Apex Class Name:  Core_ContactEntitlementHandler_Test
Version     : 1.0 
Created Date: 20 Jan 2017
Description    : This class is Test class for Core_ContactEntitlementHandler
*************************************************************************************/
@isTest
public class Core_ContactEntitlementHandler_Test{
    
    static testMethod void conEntitlements(){
        
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
     
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        
       
       system.runas(itAdminUser){
        Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
        cm.Name = 'IPS Standard Entitlement';
        cm.Value__c  = 'IPS Standard Entitlement';
        insert cm;
        
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                          AccountId=testAccount.Id,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id);
        insert testContact;
        
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;   
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle;
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
        insert entitle1;
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
        insert entitle2;
        
        
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=false,Core_Data_Loaded__c=true);
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true,Core_Data_Loaded__c=true);
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=true,Core_Data_Loaded__c=true);
        newlstentitle.add(ce1);
        newlstentitle.add(ce2);
        newlstentitle.add(ce3);
        insert newlstentitle;
        system.debug('newlstentitle==='+newlstentitle);

        List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=true);
        Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=false);
        Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=false);
        
        oldlstentitle.add(conent1);
        oldlstentitle.add(conent2);
        oldlstentitle.add(conent3);
       
        update  oldlstentitle;
         system.debug('oldlstentitle==='+oldlstentitle);
        
    }
}

 static testMethod void testconEntitlements(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
       
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.runas(itAdminUser){
       
        Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
        cm.Name = 'IPS Standard Entitlement';
        cm.Value__c  = 'IPS Standard Entitlement';
        insert cm;
        
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = true, Core_CIM_ID__c ='123124');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                          AccountId=testAccount.Id,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id);
        insert testContact;
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;   
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle;
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
        insert entitle1;
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
        insert entitle2;
        
        
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=false);
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=true);
        newlstentitle.add(ce1);
        newlstentitle.add(ce2);
        newlstentitle.add(ce3);
        insert newlstentitle;
        system.debug('newlstentitle==='+newlstentitle);

        List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=true);
        Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=false);
        Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=false);
        
        oldlstentitle.add(conent1);
        oldlstentitle.add(conent2);
        oldlstentitle.add(conent3);
       
        update  oldlstentitle;
         system.debug('oldlstentitle==='+oldlstentitle);
      }
    }
    
    static testMethod void conEntitlementsnegative(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
       
        
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
         system.runas(itAdminUser){
          
        Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
        cm.Name = 'IPS Standard Entitlement';
        cm.Value__c  = 'IPS Standard Entitlement';
        insert cm;
        
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                          AccountId=testAccount.Id,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id);
        insert testContact;
        
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;   
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle;
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
        insert entitle1;
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
        insert entitle2;
        
        
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=true);

        newlstentitle.add(ce1);
        newlstentitle.add(ce2);
        newlstentitle.add(ce3);
        insert newlstentitle;
        system.debug('newlstentitle==='+newlstentitle);

        List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=false);
        Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=false);
        Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=false);        
        oldlstentitle.add(conent1);
        oldlstentitle.add(conent2);
        oldlstentitle.add(conent3);
       
        
             
        update  oldlstentitle;
         system.debug('oldlstentitle==='+oldlstentitle);
      }
    }
    
    static testMethod void shareAssetsToCustomersTest() {
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS External Customer');
        
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        List<User> listOfUser = TestUtilities.getListOfUser(1);
        listOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        insert listOfUser;
        System.runAs(listOfUser.get(0)){
            Core_Trigger_Executions__c  TriggerExecutionEAC = new Core_Trigger_Executions__c();
            TriggerExecutionEAC.Name = 'shareAssetsToCustomers';
            TriggerExecutionEAC.Core_Active__c = true;
            TriggerExecutionEAC.Core_Class_Name__c ='Core_ContactEntitlementHandler';
            TriggerExecutionEAC.Core_Description__c = 'This method shares assets to customers';
            TriggerExecutionEAC.Core_Object__c = 'Core_Contact_Entitlement__c';
            TriggerExecutionEAC.Core_Trigger_Events__c = 'After Update';
            insert TriggerExecutionEAC;
            
            Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
            cm.Name = 'IPS Standard Entitlement';
            cm.Value__c  = 'IPS Standard Entitlement';
            insert cm;
        }
        List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
        listOfAccounts[0].Core_IPS_Active__c = true;
        System.runAs(listOfUser.get(0)){
            insert listOfAccounts;
        }     
        List<Asset> assetList = TestUtilities.getAssetList(1);
        for(Asset asst : assetList){
            asst.accountId = listOfAccounts.get(0).Id;
        }
        System.runAs(listOfUser.get(0)){
        	insert assetList;
        }
        List<Contact> lstCo11 = TestUtilities.getListOfContact(2);        
        System.runAs(listOfUser.get(0)){
            lstCo11.get(0).AccountId = listOfAccounts.get(0).Id; 
            lstCo11.get(0).Core_IPS_Active__c = true;
            lstCo11.get(1).AccountId = listOfAccounts.get(0).Id; 
            lstCo11.get(1).Email = 'lstCo11@email.com'; 
            lstCo11.get(1).Core_IPS_Active__c = true;
            //Insert Users
            insert lstCo11[0] ;             
        }
        
        Test.startTest();
        // Create Users
        List<User> lstUser = TestUtilities.getListOfUser(2);
        lstUser[0].ProfileID = profiles.get('IPS External Customer');       
        lstUser[0].contactId = lstCo11.get(0).Id;
        
        System.runAs(listOfUser.get(0)) {
            insert lstUser[0];
            insert lstCo11[1] ; 
            
        	lstUser[1].ProfileID = profiles.get('IPS External Customer');       
        	lstUser[1].contactId = lstCo11.get(1).Id;
            insert lstUser[1];
        } 
        System.runAs(listOfUser.get(0)) {
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle;
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=lstCo11.get(0).Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=false);
        newlstentitle.add(ce1);
        insert newlstentitle;
        
        ce1.Core_Status__c = 'Complete';
        update ce1;
            }
    }
}