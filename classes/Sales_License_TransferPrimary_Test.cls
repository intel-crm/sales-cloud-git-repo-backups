/*********************************************************************************************************************
Class Name    : Sales_License_TransferPrimary_Test
Version       : 1.0 
Created Date  : July 2021  
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mohammad Dilshad           2-July-2021              Test class for Sales_License_TransferPrimaryAdmin
* ******************************************************************************************************************/
@isTest
public class Sales_License_TransferPrimary_Test {
    	
    @istest public static void testTransferPrimaryAdmin(){
         String errMsg='';
        Account partnerAccount = Sales_LicenseAdminDelegateTest.createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = Sales_LicenseAdminDelegateTest.createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Contact partnerContact2 = Sales_LicenseAdminDelegateTest.createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
        Contact partnerContact3 = Sales_LicenseAdminDelegateTest.createContactWithDetails(partnerAccount.Id, 'partner3','addhos3','mohammadx.dilshad@mailinator.com');
        User u1 = Sales_LicenseAdminDelegateTest.createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
        User u2 = Sales_LicenseAdminDelegateTest.createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);       
        
            
        try{
            Test.startTest(); 
            //Creating License
            //
            List<User> users = new List<User>{u1,u2};
            insert users;
        
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        Order ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');     
        
            OrderItem ordItm1 = Sales_LicenseAdminDelegateTest.createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id);           
            Sales_License__c a = [Select Id, Sales_License_Order_Product__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id];
            //Creating Host
           	Sales_Host__c h = new Sales_Host__c();
            h.Sales_isActiveHost__c = true;
        	h.Name='AAAAAABC';
            h.Sales_Computer_Name_Txt__c = 'compName1';
            h.Sales_Computer_Type__c = 'HOST ID';
            h.Sales_License_Type__c = 'FLOAT';
            h.Sales_Contact__c = partnerContact.id;
            h.Sales_Companion_Server1_Txt__c='T456666666';
            h.Sales_Companion_Server2_Txt__c='T555555555';
            //h.Sales_Companion_Server1_Txt__c = 'BBBBAAAACCCC';
            insert h;
            h.Sales_Contact__c = partnerContact3.id;
            update h;
            //String companionServerId='BBBBAAAACCCC';
            //Sales_Host__c hostRecord = Sales_LicenseAdminDelegateTest.createHostRecord('Computer1','FIXED','HOST ID',partnerContact.Id,companionServerId,null,null);
            //Creating a License Admin Delegate Relationship Record.
            //
     		Test.startTest();
            Sales_License_Admin_Delegate__c licdlg1 = Sales_LicenseAdminDelegateTest.createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
            	
            
            Sales_License_TransferPrimaryAdmin.updateDelegateAdmin(partnerContact.id, partnerContact3.id);
            Sales_License_TransferPrimaryAdmin.updateLicenseRec(partnerContact.id, partnerContact3.id);
            Sales_License_TransferPrimaryAdmin.updatehostcontact(partnerContact.id, partnerContact3.id);
            Test.stopTest(); 
            }catch(Exception e){
            System.debug('Error msg -->'+e.getMessage());
            errMsg=e.getMessage();
        	} 
        //System.assert(errMsg=='', errMsg);
        }     
    
     @istest public static void testTransferPrimaryAdminfailure(){
        
     		Test.startTest();
            Sales_License_Admin_Delegate__c licdlg1 = Sales_LicenseAdminDelegateTest.createPriAdmDlgAdmRecord(null, null);
            	
            
            Sales_License_TransferPrimaryAdmin.updateDelegateAdmin(null, null);
            Sales_License_TransferPrimaryAdmin.updateLicenseRec(null, null);
            Sales_License_TransferPrimaryAdmin.updatehostcontact(null, null);
            Test.stopTest(); 
            
        //System.assert(errMsg=='', errMsg);
        }
    
    }