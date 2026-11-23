@isTest
public class PRM_OPIDSyncRequest_Test {
     @testSetup
    private static void createData(){
        test.startTest();
         Account intelAccount = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group',
                                           Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi',Core_OnePartnerID__c ='12345678',
                                           ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
        insert intelAccount;
        
        test.stopTest();
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Tom Cruise';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount1;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=intelAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        //acm.PRM_Channel_Program_Level_Id__c=cp.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;
        
        OPID_Sync_Request__c opidsyncreq= new OPID_Sync_Request__c(); //OPID Sync Request
        opidsyncreq.OPID_Account__c=intelAccount.id;
        opidsyncreq.Status__c='In Progress';
        insert opidsyncreq;
    }
    
 @isTest static void createSyncReqMethod(){
        test.startTest();
		Account acc = [SELECT id,Core_OnePartnerID__c FROM Account WHERE Core_OnePartnerID__c ='12345678' LIMIT 1];       
        String accountId = PRM_OPIDSyncRequest.getAccountDetails(acc.Id);
      	PRM_OPIDSyncRequest.createSyncRequest(acc.Id);
        test.stopTest();
     	System.assertNotEquals(null, accountId);
    }  
}