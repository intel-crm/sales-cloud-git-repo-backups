@isTest
public class UCD_ACM_DZPCreateIPAEntitlement_Test {
    @TestSetup 
    static void createTestData() {
        Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        ipaUltimateAccount.Core_Prime_Id__c = ipaUltimateAccount.Id;
        ipaUltimateAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        update ipaUltimateAccount;
        ChannelProgram cp = PRM_TestUtility.getChannelPrograms();
        insert cp;
        PRM_AccountChannelMembership__c membership1 = new PRM_AccountChannelMembership__c();
        membership1.PRM_Account_Id__c=ipaUltimateAccount.Id;
        membership1.PRM_Status_Nm__c = 'Approved';
        membership1.PRM_Channel_Program_Id__c=cp.Id;
        membership1.PRM_Partner_Role__c='Service Provider';
        membership1.PRM_Status_Reason_Txt__c = 'Auto Granted IPA for DZP';
        insert(membership1);
        Contact con = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
        insert(con);
        PRM_Bulk_Data_Upload__c bulkRec = new PRM_Bulk_Data_Upload__c();
        bulkRec.PRM_AccountId__c = ipaUltimateAccount.id;
        bulkRec.PRM_Comments__c = 'Auto Granted IPA for DZP';
        bulkRec.PRM_ContactEmail__c = con.email;
        bulkRec.PRM_Contact_Id__c = con.id;
        bulkRec.PRM_First_Name__c = con.FirstName;
        bulkRec.PRM_Last_Name__c = con.LastName;
        bulkRec.PRM_IPA_Partner_Role__c = 'Builder';
        bulkrec.PRM_Mailing_Country__c = 'USA';
        bulkRec.PRM_Object__c = 'Contact';
        bulkRec.PRM_OperationType__c = 'Insert';
        bulkrec.PRM_Partner_Relationship__c = 'Employee';
        bulkrec.PRM_Status_Reason__c = 'Auto Granted IPA for DZP';
        bulkrec.PRM_Status__c = 'New';
        bulkrec.PRM_Suppress_Email__c = true;
        bulkrec.PRM_Upload_Type__c = 'Auto Granted IPA for DZP';
        insert bulkrec;
    }
    
    @isTest 
    static void checkPCTCustomPermAssigned(){
        List<PRM_Bulk_Data_Upload__c> dataload = [Select PRM_AccountId__c,PRM_Comments__c,PRM_ContactEmail__c,PRM_Contact_Id__c,PRM_First_Name__c,PRM_Last_Name__c,PRM_IPA_Partner_Role__c,PRM_Mailing_Country__c,PRM_Object__c,PRM_OperationType__c,PRM_Partner_Relationship__c,PRM_Status_Reason__c,PRM_Status__c,PRM_Suppress_Email__c,PRM_Upload_Type__c from PRM_Bulk_Data_Upload__c];
        UCD_ACM_DZPCreateIPAEntitlement.UCD_ACM_DZPCreateIPAEntitlement(dataload);
    }
}