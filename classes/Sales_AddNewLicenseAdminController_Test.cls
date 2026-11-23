/*********************************************************************************************************************
Class Name    : Sales_AddNewLicenseAdminController_Test
Version       : 1.0
Created Date  : July 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           20-Jan-2021             Test class for Sales_AddNewLicenseAdminController 
* *********************************************************************************************************************/
@isTest
public class Sales_AddNewLicenseAdminController_Test {
    static testmethod void testCreateContact(){
        String errMsg;
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id ,
                    'Sales_License_DlgAdmin_Email_Txt__c' => con1.Email
                    }); 
        insert licAdmDlg;
        test.startTest();
        try{
            Id DelegateId=Sales_AddNewLicenseAdminController.createNewLicenseAdmDelegate(licAdmDlg);
            Sales_AddNewLicenseAdminController.isCommunity();
        }
        catch(exception e){
            errMsg=e.getMessage();
        }
        System.assert(errMsg==errMsg, errMsg);
        test.stopTest();
    }
    static testmethod void testCreateContact1(){
        String errMsg;
        Account intelAccount=Sales_TestFactory_Utility.createAccount();
        Contact con=new Contact();
        con.FirstName='Test';
        con.LastName ='Test1';
        con.Email='abc@gmail.com';
        con.AccountId=intelAccount.id;
        con.MailingCountry =intelAccount.BillingCountry;
        insert con;
        Sales_License_Admin_Delegate__c licAdmDlg = new Sales_License_Admin_Delegate__c();
        licAdmDlg.Sales_License_DlgAdmin_Contact__c = con.id;
        licAdmDlg.Sales_License_DlgAdmin_Email_Txt__c = 'abc@gmail.com';
        licAdmDlg.Sales_License_DlgAdmin_FirstName_Txt__c = 'admin';
        licAdmDlg.Sales_License_DlgAdmin_LastName_Txt__c = 'delegate';                
        insert licAdmDlg;
        test.startTest();
        try{
            Sales_AddNewLicenseAdminController.createNewLicenseAdmDelegate(licAdmDlg);
            Sales_AddNewLicenseAdminController.isCommunity();
        }
        catch(exception e){
            errMsg=e.getMessage();
        }
        System.assert(errMsg==errMsg, errMsg);
        test.stopTest();
    }
}