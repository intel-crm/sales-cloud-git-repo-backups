@isTest
public class Core_Batch_SyncContact_AGS_Test {
    public static testMethod void contactAGSSync(){
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = false,
                                      Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c ='samplename',
                                      BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                    BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');
        insert testAccount; 
        System.assertNOTEquals(null , testAccount.id);
        List<Contact> lContacts=new List<Contact>();
                                 
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',Core_Enterprise_Id__c ='123456',
                                      AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= null,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false);
        insert testContact;
        System.assertNOTEquals(null , testContact.id);
      
        lContacts.add(testContact);
        System.assertEquals(1, lContacts.size());
      
        Core_Batch_SyncContact_AGS syncCon= new  Core_Batch_SyncContact_AGS();
        Database.executeBatch(syncCon);
        syncCon.execute(null,lContacts);
    }
}