@isTest
public class Core_ERPM_API_Callout_Test {
    
    @testSetup 
    public static void DataSetup() {
        //Insert Account
        Account acc = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c = 'samplename',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                            BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');
        insert acc; 
        
        //Insert Contact
        Contact con = new Contact();
        con.FirstName = 'RDCAck2';
        con.LastName = 'RDCAck2';
        con.AccountId = acc.Id;
        con.Email = 'test_rdcuser44@mailinator.com';
        con.Phone = '323253';
        con.Core_Preferred_Language__c= 'ENG';
        con.Core_Profession__c = 'CONSULTANT';
        con.Core_Job_Function__c = 'CONSLT' ; 
        con.Core_Do_Not_Contact__c = FALSE;
        //con.Core_Login_Status__c = 'Active';
        insert con;
        
        Contact con1 = new Contact();
        con1.FirstName = 'RDCAck3';
        con1.LastName = 'RDCAck3';
        con1.AccountId = acc.Id;
        con1.Email = 'test_rdcuser43@mailinator.com';
        con1.Phone = '323253';
        con1.Core_Preferred_Language__c= 'ENG';
        con1.Core_Profession__c = 'CONSULTANT';
        con1.Core_Job_Function__c = 'CONSLT' ; 
        con1.Core_Do_Not_Contact__c = TRUE;
        insert con1;
        
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
        
        PRM_ContactSubscriptionAssociation__c conSub1 = new PRM_ContactSubscriptionAssociation__c();
        conSub1.PRM_Contact_Id__c = con1.id;
        conSub1.PRM_Partner_Subscription_Id__c = partSub.Id;
        conSub1.PRM_Status_Nm__c = 'Inactive';
        conSub1.PRM_Status_Reason_Txt__c = 'NA';
        insert conSub1;
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