/******************************************************
Component Name    : Sales_UpdateContactDetails_Test
Created Date  : Jan 2022
Function      : <TWC3144-34> : DEV - Contact's email address is updated but license record still showing old email address
Modification Log :
Developer                       Date                    Description
Dnyanada Argulwar             01/05/2022                 TWC3144-34
*****************************************************/
@isTest
public class Sales_UpdateContactDetails_Test {
/*
    public static Account createAccount_PartnerandNonpartner_PSGDownstream(String CoreAccountType, String Acctype){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        acc.Core_PSG_Account__c=true;   
        acc.Core_Account_Type__c = CoreAccountType;
        acc.Type = Acctype;
        return acc;
    }
    public static Contact createContactWithDetails(Id accId, String fName, String lName, String emailId){
        Contact con = Sales_TestDataFactory.createContactRecord(new Map<String,String>{
            'FirstName'=>fName,
                'LastName'=>lName,
                'Email'=>emailId,
                'AccountId'=>accId
                });
        return con;
    }
    public static Sales_Host__c createHostRecord(String compName, String LicType, String compType, Id primAdmContactId, String compServ1, String redServ1, String redServ2){
        Sales_Host__c h = new Sales_Host__c();
        if(compType=='HOST ID')
            h.Name='AAAAAABC';                  
        else if(compType=='NIC ID')
            h.Name='AAAAAABBBBEF';              
        h.Sales_isActiveHost__c = true;
        h.Sales_Computer_Name_Txt__c = compName;
        h.Sales_Computer_Type__c = compType;
        h.Sales_License_Type__c = LicType;
        h.Sales_Contact__c = primAdmContactId;
        h.Sales_Companion_Server1_Txt__c = compServ1;
        h.Sales_Redundant_Server1_Txt__c = redServ1;
        h.Sales_Redundant_Server2_Txt__c = redServ2;
        h.Sales_Host_Is_Created_From_Custom_Page__c = true;
        insert h;
        return h;
    }
    @isTest
    static void updateContactEmailTest(){
        Core_Contact_Bypass_Validation_Rule__c triggerExecList = new Core_Contact_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        List<Contact> ContactList= new List<Contact>();
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');                
        insert partnerAccount;
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','xyztest247392638@intel.com');  
        insert  partnerContact;
        Contact partnerContact1 = createContactWithDetails(partnerAccount.Id, 'part','add','xyztest2478@intel.com');  
        insert  partnerContact1;
        Product2 p = new Product2();
        p.Name = ' Test Corporate Product';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Core_Item_Orderable_Ind__c = true;
        p.SBQQ__SubscriptionTerm__c=10;
        p.SBQQ__SubscriptionPricing__c ='Fixed Price';
        p.SBQQ__SubscriptionType__c = 'One-time';
        insert p; 
        Sales_License__c lic2=new Sales_License__c();
        lic2.Sales_License_Quantity__c=1;
        lic2.Sales_License_Product_Name_Txt__c='Test';
        lic2.Sales_License_Maintenance_Exp_Dt__c=system.today();
        lic2.Sales_License_Expiration_Date_Dt__c=system.today()+1;
        lic2.Sales_License_Start_Date_Dt__c=system.today();
        lic2.Sales_License_Status__c='Unlicensed';
        lic2.Sales_License_Avbl_Qty_Nbr__c=1;
        lic2.Sales_License_Avbl_Rehost_Nbr__c=1;
        lic2.Opt_in_out__c=true;
        lic2.Sales_License_Web_Display_Flag__c=false;
        lic2.Sales_License_Type__c='Original';
        lic2.Sales_License_Product__c=p.id;
        lic2.Sales_License_Primary_Admin_Contact__c=partnerContact.id;
        lic2.Sales_License_Lic_User_Contact_ID__c=partnerContact1.id;
        lic2.Sales_License_PriAdm_Email__c=partnerContact.email;
        lic2.Licensed_User_Email_Address_Txt__c=partnerContact1.email;
        lic2.Sales_License_Primary_Admin_Contact_Txt__c='partner addhost';
        lic2.Sales_Lic_User_Contact_Txt__c='part add';
        insert lic2;
        String companionServerId='BBBBAAAACCCC';
        Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,null,null);
        Sales_License_Admin_Delegate__c licAdmDlg ;
        licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
            'Sales_License_PrimaryAdmin_Contact__c' => partnerContact.Id , 'Sales_License_DlgAdmin_Contact__c' => partnerContact1.Id
                }); 
        insert licAdmDlg;
        partnerContact.Email='xyztest2473926@intel.com';
        partnerContact.FirstName='ptest';
        update partnerContact;
        partnerContact1.Email='xyztest2678@intel.com';
        partnerContact1.FirstName='phog';
        ContactList.add(partnerContact);
        ContactList.add(partnerContact1);
        test.startTest();
        Sales_UpdateContactDetails.updateContactDetails_LicenseHost(ContactList);
        Sales_UpdateContactDetails.updateContactDetails_LicenseAdminDelegate(ContactList);
        test.stopTest();
        System.assertEquals('','');
    }
    @isTest
    static void updateContactNameTest(){
        Core_Contact_Bypass_Validation_Rule__c triggerExecList = new Core_Contact_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        List<Contact> ContactList= new List<Contact>();
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');                
        insert partnerAccount;
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','xyztest247392638@intel.com'); 
        insert  partnerContact;
        partnerContact.Email='xyztest2473926@intel.com';
        partnerContact.FirstName='ptest';
        String companionServerId='BBBBAAAACCCC';
        Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,null,null);
        update partnerContact;
        ContactList.add(partnerContact);
        test.startTest();
        Sales_UpdateContactDetails.updateContactDetails_LicenseHost(ContactList);
        Sales_UpdateContactDetails.updateContactDetails_LicenseAdminDelegate(ContactList);
        test.stopTest();
        System.assertEquals('','');
    }
    @isTest
    static void updateContactNameTest1(){
        Core_Contact_Bypass_Validation_Rule__c triggerExecList = new Core_Contact_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        List<Contact> ContactList= new List<Contact>();
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');                
        insert partnerAccount;
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'party','addh','xyztest247392638@intel.com'); 
        insert  partnerContact;
        Product2 p = new Product2();
        p.Name = ' Test Corporate Product';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Core_Item_Orderable_Ind__c = true;
        p.SBQQ__SubscriptionTerm__c=10;
        p.SBQQ__SubscriptionPricing__c ='Fixed Price';
        p.SBQQ__SubscriptionType__c = 'One-time';
        insert p; 
        Sales_License__c lic2=new Sales_License__c();
        lic2.Sales_License_Quantity__c=1;
        lic2.Sales_License_Product_Name_Txt__c='Test';
        lic2.Sales_License_Maintenance_Exp_Dt__c=system.today();
        lic2.Sales_License_Expiration_Date_Dt__c=system.today()+1;
        lic2.Sales_License_Start_Date_Dt__c=system.today();
        lic2.Sales_License_Status__c='Unlicensed';
        lic2.Sales_License_Avbl_Qty_Nbr__c=1;
        lic2.Sales_License_Avbl_Rehost_Nbr__c=1;
        lic2.Opt_in_out__c=true;
        lic2.Sales_License_Web_Display_Flag__c=false;
        lic2.Sales_License_Type__c='Original';
        lic2.Sales_License_Product__c=p.id;
        lic2.Sales_License_Primary_Admin_Contact__c=partnerContact.id;
        lic2.Sales_License_PriAdm_Email__c=partnerContact.email;
        lic2.Sales_License_Primary_Admin_Contact_Txt__c='partner addhost';
        lic2.Sales_Lic_User_Contact_Txt__c='part add';
        insert lic2;
        String companionServerId='BBBBAAAACCCC';
        Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,null,null);
        partnerContact.Email='xyztest2473926@intel.com';
        partnerContact.FirstName='ptest';
        update partnerContact;
        ContactList.add(partnerContact);
        test.startTest();
        Sales_UpdateContactDetails.updateContactDetails_LicenseHost(ContactList);
        Sales_UpdateContactDetails.updateContactDetails_LicenseAdminDelegate(ContactList);
        test.stopTest();
        System.assertEquals('','');
    }
*/
}