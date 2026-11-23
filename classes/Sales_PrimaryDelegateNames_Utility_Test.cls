/*********************************************************************************************************************
Class Name    : Sales_PrimaryDelegateNames_Utility_Test
Version       : 1.0
Created Date  : Jun 2021
Function      : Test Class for Sales_Primary_DelegateNames_Utility Class
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        24-Jun-2021             Sales_PrimaryDelegateNames_Utility_Test
* *********************************************************************************************************************/
@isTest
public class Sales_PrimaryDelegateNames_Utility_Test {
    @isTest
    public static void testAdditionalScripts_ClearMethod(){      
        String errMsg='';
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');    
        Contact partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');      
        Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
        Sales_License_Admin_Delegate__c licdlg2 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact3.Id);
        try{
            Test.startTest();          
            Sales_License__c lic = new Sales_License__c();
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
            lic.Sales_License_DelegateNames_Txt__c = 'shivamx.vishwakarma@mailinator.com, shivamx.vishwakarma2@mailinator.com';
            insert lic;
            Sales_Primary_DelegateNames_Utility.clearAllLicensePrimary_DelegateNames();                           
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }
    @isTest
    public static void testAdditionalScripts_PopulateMethod1(){      
        String errMsg='';
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');    
        Contact partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');       
        Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
        Sales_License_Admin_Delegate__c licdlg2 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact3.Id);
        try{
            Test.startTest();          
            Sales_License__c lic = new Sales_License__c();
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;                 
            insert lic;        
            Sales_Primary_DelegateNames_Utility.populateAllLicensePrimary_DelegateNames();
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }
    @isTest
    public static void testAdditionalScripts_PopulateMethod2(){      
        String errMsg='';
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');    
        Contact partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');       
        Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
        Sales_License_Admin_Delegate__c licdlg2 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact3.Id);
        try{
            Test.startTest();          
            Sales_License__c lic = new Sales_License__c();
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
            lic.Sales_License_DelegateNames_Txt__c = 'exisitingemail@test.com';
            insert lic;        
            Sales_Primary_DelegateNames_Utility.populateAllLicensePrimary_DelegateNames();
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }
    @isTest
    public static void updateDelegateAdminScenario(){      
        String errMsg='';
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
        Contact partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');           
        Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
        Sales_License_Admin_Delegate__c licdlg3 = createPriAdmDlgAdmRecord(partnerContact2.Id, partnerContact3.Id);
        try{
            Test.startTest();          
            Sales_License__c lic = new Sales_License__c();
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
            lic.Sales_License_DelegateNames_Txt__c = 'shivamx.vishwakarma@mailinator.com';
            insert lic;                         
            licdlg1.Sales_License_DlgAdmin_Contact__c = partnerContact2.Id;
            update licdlg1;
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }
    @isTest 
    public static void record_InActive_Active_Test(){
        String errMsg='';
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');       
        try{
            Test.startTest(); 
            Sales_License__c lic = new Sales_License__c();
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
            insert lic;                                    
            Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
            licdlg1.Sales_License_isActive__c = false;
            update licdlg1;
            licdlg1.Sales_License_isActive__c = true;
            update licdlg1;
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }      
    @isTest 
    public static void revokeAccessTest(){
        String errMsg='';
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
        Contact partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');               
        try{
            Test.startTest();         
            Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
            Sales_License_Admin_Delegate__c licdlg2 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact3.Id);
            Sales_License__c lic = new Sales_License__c();
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
            lic.Sales_License_DelegateNames_Txt__c = 'shivamx.vishwakarma@mailinator.com, shivamx.vishwakarma2@mailinator.com';
            insert lic;            
            delete new List<Sales_License_Admin_Delegate__c>{licdlg1,licdlg2};
                Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }   
    @isTest
    public static void updatePrimaryAdminOnLicense(){      
        String errMsg='';
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');    
        Contact partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');       
        Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
        Sales_License_Admin_Delegate__c licdlg2 = createPriAdmDlgAdmRecord(partnerContact2.Id, partnerContact3.Id);
        try{
            Test.startTest();          
            Sales_License__c lic = new Sales_License__c();
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
            insert lic;   
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact2.Id;
            update lic;
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }
    public static Account createAccount_PartnerandNonpartner_PSGDownstream(String CoreAccountType, String Acctype){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc.Core_PSG_Account__c=true;   
        acc.Name = 'AccName - '+String.valueof((Math.random() * 1000));
        acc.Core_Account_Type__c = CoreAccountType;
        acc.Industry = 'Education';
        acc.Core_Sub_Industry__c = 'Student';
        acc.BillingCity = 'New york';
        acc.BillingState='ME';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'New U';
        acc.BillingPostalCode='04685';
        acc.Type = Acctype;
        acc.Core_Sales_Groups__c = 'PRC Sales Group';       
        insert acc;
        return acc;
    }
    public static Contact createContactWithDetails(Id accId, String fName, String lName, String emailId){
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = fName;
        con.LastName = lName;
        con.Email = emailId;
        con.AccountId = accId;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry = 'India';
        insert con;
        return con;
    }
    public static Sales_License_Admin_Delegate__c createPriAdmDlgAdmRecord(Id primAdmContactId, Id dlgAdmContactId){
        Sales_License_Admin_Delegate__c licAdmDlg1 = new Sales_License_Admin_Delegate__c();
        licAdmDlg1.Sales_License_PrimaryAdmin_Contact__c = primAdmContactId;
        licAdmDlg1.Sales_License_DlgAdmin_Contact__c = dlgAdmContactId;
        licAdmDlg1.Sales_License_isActive__c = true;
        insert licAdmDlg1;
        return licAdmDlg1;
    }
    public static OrderItem createOrderProductWithContact(Id ordId, Id prodId, Id pbEntryId, Id ContactId){
        OrderItem i = new OrderItem();
        i.OrderId = ordId;
        i.Quantity = 1;
        i.UnitPrice = 240;
        i.Product2id = prodId;
        i.SBQQ__Status__c='Draft';
        i.PricebookEntryId=pbEntryId;
        i.Sales_Contact__c = ContactId;
        insert i;
        return i;
    } 
}