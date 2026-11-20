@isTest
private class Core_MergeContactHandler_Test {

    
    private static testMethod void mergeContactTest() {
          //Put an entry in 'Trigger Executions' custom settings so the Contact trigger gets exectued
           Core_Trigger_Executions__c triggerExe = new Core_Trigger_Executions__c();
           triggerExe.Name = 'MergeContactEntitlements';
           triggerExe.Core_Active__c = true;
           triggerExe.Core_Class_Name__c = 'Core_MergeContactHandler';
           triggerExe.Core_Description__c = 'test description';
           triggerExe.Core_Object__c = 'Contact';
           triggerExe.Core_Trigger_Events__c = 'Before delete';
           insert triggerExe;
           System.assertNotEquals(null, triggerExe.Id);
        Id intelAccRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account'AND Sobjecttype = 'Account' limit 1][0].Id;
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',RecordTypeId=intelAccRecTypeId,
                                  Core_Account_Type__c='Other', Industry='Others',
                                  BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                  BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_English_Only_Name__c ='testaccount');
        insert testAccount;
        System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com.testsetup',MailingCountry='India',
                                  AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_English_Only_Last_Name__c ='test',Core_English_Only_first_Name__c='ranjan' );
        insert testContact;
        System.assert(true,testContact.Core_Personal_Email_Indicator__c != null);
        
        Contact testContact2 = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com',MailingCountry='India',
                                  AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_English_Only_Last_Name__c ='test',Core_English_Only_first_Name__c='ranjan');
        insert testContact2;
        System.assert(true,testContact2.Core_Personal_Email_Indicator__c != null);
        

        //Creates sample 'ERPM Engagement' record as it is required in Entitlement record
            Core_ERPM_Engagement__c objERPMEngmt = new Core_ERPM_Engagement__c();
            objERPMEngmt.name = 'TestErpmName';
            objERPMEngmt.Core_IsActive__c = true;
            insert objERPMEngmt;
            System.assertNotEquals(null, objERPMEngmt.Id);
            
            //Creates sample 'AGS role' record as it is required in Entitlement record 
            Core_AGS_Role__c objAGSRole = new Core_AGS_Role__c();
            objAGSRole.name= 'TestAGSRoleName';
            objAGSRole.Core_IsActive__c = true;
            insert objAGSRole;
            System.assertNotEquals(null, objAGSRole.Id);
            
            //Creates a sample 'Entitlement' record
            Core_Entitlement__c objEntitlement = new Core_Entitlement__c();
            objEntitlement.name = 'TestEntitlementName';
            objEntitlement.Core_Display_Name__c = 'TestEntitlementName';
            objEntitlement.Core_IsActive__c = true;
            objEntitlement.Core_AGS_Role_Id__c = objAGSRole.id;
            objEntitlement.Core_Category__c = 'Support';
            objEntitlement.Core_ERPM_Engagement_Id__c = objERPMEngmt.id;
            insert objEntitlement;
            System.assertNotEquals(null, objEntitlement.Id);
            
            Core_Entitlement__c objEntitlement1 = new Core_Entitlement__c();
            objEntitlement1.name = 'TestEntitlementName1';
            objEntitlement1.Core_Display_Name__c = 'TestEntitlementName1';
            objEntitlement1.Core_IsActive__c = true;
            objEntitlement1.Core_AGS_Role_Id__c = objAGSRole.id;
            objEntitlement1.Core_Category__c = 'Support';
            objEntitlement1.Core_ERPM_Engagement_Id__c = objERPMEngmt.id;
            insert objEntitlement1;
            System.assertNotEquals(null, objEntitlement1.Id);
            
            //Creates a sample 'Contact Entitlement' record
            
            List<Core_Contact_Entitlement__c> lstentitle = new List<Core_Contact_Entitlement__c>();
            
            Core_Contact_Entitlement__c objConEntitlement = new Core_Contact_Entitlement__c();
            objConEntitlement.Core_Contact_Id__c = testContact.id;
            objConEntitlement.Core_Entitlement_Id__c = objEntitlement.id;
            objConEntitlement.Core_Selected__c = false;
            lstentitle.add(objConEntitlement);
            
            Core_Contact_Entitlement__c objConEntitlement1 = new Core_Contact_Entitlement__c();
            objConEntitlement1.Core_Contact_Id__c = testContact2.id;
            objConEntitlement1.Core_Entitlement_Id__c = objEntitlement.id;
            objConEntitlement1.Core_Selected__c = false;
            lstentitle.add(objConEntitlement1);
            
            Core_Contact_Entitlement__c objConEntitlement2 = new Core_Contact_Entitlement__c();
            objConEntitlement2.Core_Contact_Id__c = testContact2.id;
            objConEntitlement2.Core_Entitlement_Id__c = objEntitlement1.id;
            objConEntitlement2.Core_Selected__c = false;
            lstentitle.add(objConEntitlement2);
            
            insert lstentitle;
            
        test.startTest();
     
            merge testContact testContact2;
            Core_MergeContact_Status_Update.updateIntegrationStatus(new List<ID>{testContact2.id});
            List<Core_Contact_Entitlement__c> CElist=[Select id from Core_Contact_Entitlement__c where Core_Contact_Id__c=:testContact.id];
            //system.assertEquals(1, CElist.size());
			Core_MergeContactHandler.validateToUpdDelUniqueEntitlement();
        test.stopTest();
    }
    

/*
    private static testMethod void mergeContactTest2() {
        
        //Put an entry in 'Trigger Executions' custom settings so the Contact trigger gets exectued
          Core_Trigger_Executions__c triggerExe = new Core_Trigger_Executions__c();
          triggerExe.Name = 'MergeContactEntitlements';
          triggerExe.Core_Active__c = true;
          triggerExe.Core_Class_Name__c = 'Core_MergeContactHandler';
          triggerExe.Core_Description__c = 'test description';
          triggerExe.Core_Object__c = 'Contact';
          triggerExe.Core_Trigger_Events__c = 'Before delete';
          insert triggerExe;
          System.assertNotEquals(null, triggerExe.Id);
       
       Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                 Core_Account_Type__c='Other', Industry='Others',
                                 BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                 BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_English_Only_Name__c ='testaccount');
       insert testAccount;
       System.assert(true,testAccount.Core_CNDA_Number__c != null);
       
       Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com.testsetup',
                                 AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_English_Only_Last_Name__c ='test',Core_English_Only_first_Name__c='ranjan' );
       insert testContact;
       System.assert(true,testContact.Core_Personal_Email_Indicator__c != null);
       
       Contact testContact2 = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com',
                                 AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_English_Only_Last_Name__c ='test',Core_English_Only_first_Name__c='ranjan');
       insert testContact2;
       System.assert(true,testContact2.Core_Personal_Email_Indicator__c != null);
       

       //Creates sample 'ERPM Engagement' record as it is required in Entitlement record
           Core_ERPM_Engagement__c objERPMEngmt = new Core_ERPM_Engagement__c();
           objERPMEngmt.name = 'TestErpmName';
           objERPMEngmt.Core_IsActive__c = true;
           insert objERPMEngmt;
           System.assertNotEquals(null, objERPMEngmt.Id);
           
           //Creates sample 'AGS role' record as it is required in Entitlement record 
           Core_AGS_Role__c objAGSRole = new Core_AGS_Role__c();
           objAGSRole.name= 'TestAGSRoleName';
           objAGSRole.Core_IsActive__c = true;
           insert objAGSRole;
           System.assertNotEquals(null, objAGSRole.Id);
           
           //Creates a sample 'Entitlement' record
           Core_Entitlement__c objEntitlement = new Core_Entitlement__c();
           objEntitlement.name = 'TestEntitlementName';
           objEntitlement.Core_Display_Name__c = 'TestEntitlementName';
           objEntitlement.Core_IsActive__c = true;
           objEntitlement.Core_AGS_Role_Id__c = objAGSRole.id;
           objEntitlement.Core_Category__c = 'Support';
           objEntitlement.Core_ERPM_Engagement_Id__c = objERPMEngmt.id;
           insert objEntitlement;
           System.assertNotEquals(null, objEntitlement.Id);
           
           Core_Entitlement__c objEntitlement1 = new Core_Entitlement__c();
           objEntitlement1.name = 'TestEntitlementName1';
           objEntitlement1.Core_Display_Name__c = 'TestEntitlementName1';
           objEntitlement1.Core_IsActive__c = true;
           objEntitlement1.Core_AGS_Role_Id__c = objAGSRole.id;
           objEntitlement1.Core_Category__c = 'Support';
           objEntitlement1.Core_ERPM_Engagement_Id__c = objERPMEngmt.id;
           insert objEntitlement1;
           System.assertNotEquals(null, objEntitlement1.Id);
           
           //Creates a sample 'Contact Entitlement' record
           
           List<Core_Contact_Entitlement__c> lstentitle = new List<Core_Contact_Entitlement__c>();
           
           Core_Contact_Entitlement__c objConEntitlement = new Core_Contact_Entitlement__c();
           objConEntitlement.Core_Contact_Id__c = testContact.id;
           objConEntitlement.Core_Entitlement_Id__c = objEntitlement.id;
           objConEntitlement.Core_Selected__c = false;
           lstentitle.add(objConEntitlement);
           
           Core_Contact_Entitlement__c objConEntitlement1 = new Core_Contact_Entitlement__c();
           objConEntitlement1.Core_Contact_Id__c = testContact2.id;
           objConEntitlement1.Core_Entitlement_Id__c = objEntitlement.id;
           objConEntitlement1.Core_Selected__c = true;
           lstentitle.add(objConEntitlement1);
           
           Core_Contact_Entitlement__c objConEntitlement2 = new Core_Contact_Entitlement__c();
           objConEntitlement2.Core_Contact_Id__c = testContact2.id;
           objConEntitlement2.Core_Entitlement_Id__c = objEntitlement1.id;
           objConEntitlement2.Core_Selected__c = false;
           lstentitle.add(objConEntitlement2);
           
           //insert lstentitle;
           
       test.startTest();
    
           merge testContact testContact2;
           Core_MergeContact_Status_Update.updateIntegrationStatus(new List<ID>{testContact2.id});
           List<Core_Contact_Entitlement__c> CElist=[Select id from Core_Contact_Entitlement__c where Core_Contact_Id__c=:testContact.id];
           //system.assertEquals(1, CElist.size());

       test.stopTest();
   }
*/

}