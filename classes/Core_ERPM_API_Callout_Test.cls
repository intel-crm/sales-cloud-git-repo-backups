@isTest
public class Core_ERPM_API_Callout_Test {
    
    @testSetup 
    public static void DataSetup() {
        //Insert Account
		String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account acc = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c = 'samplename',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',RecordTypeId=intelAccRecTypeId,  
                                            BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');
        insert acc; 
        
        //Insert Contact
        Contact con = new Contact();
        con.FirstName = 'RDCAck2';
        con.LastName = 'RDCAck2';
        con.AccountId = acc.Id;
        con.Email = 'test_rdcuser44@mailinator.com';
        con.Phone = '323253';
        con.MailingCountry='India';
        con.Core_Preferred_Language__c= 'ENG';
        con.Core_Profession__c = 'CONSULTANT';
        con.Core_Job_Function__c = 'CONSLT' ; 
        con.Core_Do_Not_Contact__c = FALSE;
        insert con;
        PRM_Partner_Subscription__c partSub = new PRM_Partner_Subscription__c();
       	partSub.PRM_Subscription_Cd__c = 'PAR';
        partSub.name = 'abc';
        insert partSub;
        
        PRM_ContactSubscriptionAssociation__c conSub = new PRM_ContactSubscriptionAssociation__c();
        conSub.PRM_Contact_Id__c = con.id;
        conSub.PRM_Partner_Subscription_Id__c = partSub.Id;
        conSub.PRM_Status_Nm__c = 'Active';
        conSub.PRM_Status_Reason_Txt__c = 'NA';
        insert conSub;
    }
    
    @isTest 
    public static void ERPM_API_Callout_Test() {
        List<String> listofDetails = new List<String>();
        Contact con = [SELECT id from Contact WHERE Email = 'test_rdcuser44@mailinator.com' limit 1];
        String someString = con.Id + '-->' + 'Resource & Design Center for Secure Content'+'-->'+'True';
        listofDetails.add(someString);
        
        Test.startTest();
        Core_ERPM_API_Callout.assignERPMEngagements(listofDetails);
        Test.stopTest();
    }
}