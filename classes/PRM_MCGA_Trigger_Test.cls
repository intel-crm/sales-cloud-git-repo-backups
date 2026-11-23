/***************************************************************************************************************************************
Apex Class Name     : PRM_MCGA_Trigger_Test 
Version             : 1.0
Created Date        : March 2020
Function            : Test class for PRM_MCGA_Trigger_Handler,PRM_MCGA_Trigger_Utility.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        9-June-2020                     US651041-add the contacts form the group into the message log on assigning the contact group to the message
*************************************************************************************************************************************/
@isTest
public class PRM_MCGA_Trigger_Test {
    public static final  Id adhocRecordTypeId=Schema.SObjectType.PRM_Message__c.getRecordTypeInfosByName().get('Adhoc').getRecordTypeId();
     public static final Id eventRecordTypeId=Schema.SObjectType.PRM_Message__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();

    @testSetup
    public static void testData(){
        PRM_Contact_Group__c cntGr = new PRM_Contact_Group__c();
        cntGr.Name = 'IPA Contact Gr';
        insert cntGr;
        PRM_Contact_Group__c cntGr2 = new PRM_Contact_Group__c();
        cntGr2.Name = 'IPA Contact Gr 2';
        insert cntGr2;
        Account testAcc = new Account();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        testAcc.RecordTypeId=intelAccRecTypeId;
        testAcc.Name='John Wick1';
        testAcc.Core_IPA_Partner_Role__c='Service Provider';
        testAcc.BillingCity='City';
        testAcc.BillingStreet='Beacker Street';
        testAcc.BillingCountry='India';
        testAcc.BillingPostalCode='Postal code1';
        testAcc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAcc.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        insert testAcc;
        
        //TestData for Contact
        List<Contact> conListData =new List<Contact>();
        Contact con1 = new Contact();  //Contact
        con1.AccountId=testAcc.Id;
        con1.lastName='Grill';
        con1.FirstName='Adam';
        con1.email='AdamGrill@rediff.com';
        con1.Core_Job_Function__c='Branch Manager';
        con1.Core_eRPM_Language_Code__c='Eng';
        con1.Core_IPA_PartnerRole__c = 'Service Provider';
        con1.Core_Login_Id__c = 'abc';
        con1.MailingCountry='USA';
        conListData.add(con1);
        //TestData for Contact 
        Contact con2 =new Contact();
        con2.Email='test@intel.com';
        con2.AccountId=testAcc.Id;
        con2.FirstName='Test';
        con2.LastName='User';
        con2.Core_Job_Function__c='Branch Manager';
        con2.Core_eRPM_Language_Code__c='Eng';
        con2.Core_IPA_PartnerRole__c = 'Service Provider';
        con2.Core_Login_Id__c = 'Test';
        con2.MailingCountry='USA';
        conListData.add(con2);
        insert conListData;
        //contact group contact association
        List<PRM_Contact_Group_Contact_Association__c> cgcaList =new List<PRM_Contact_Group_Contact_Association__c>();
        PRM_Contact_Group_Contact_Association__c cgca1= new PRM_Contact_Group_Contact_Association__c();
        cgca1.PRM_Contact_Group_Id__c=cntGr.Id;
        cgca1.PRM_Contact_Id__c=conListData[0].Id;
        cgca1.PRM_Start_Date_Dt__c=System.today();
        cgcaList.add(cgca1);
        PRM_Contact_Group_Contact_Association__c cgca2= new PRM_Contact_Group_Contact_Association__c();
        cgca2.PRM_Contact_Group_Id__c=cntGr.Id;
        cgca2.PRM_Contact_Id__c=conListData[1].Id;
        cgca2.PRM_Start_Date_Dt__c=System.today();	
        cgcaList.add(cgca2);
        PRM_Contact_Group_Contact_Association__c cgca3 = new PRM_Contact_Group_Contact_Association__c();//CGCA for C1 with CG2
        cgca3.PRM_Contact_Group_Id__c = cntGr2.Id;
        cgca3.PRM_Contact_Id__c = conListData[0].Id;
        cgca2.PRM_Start_Date_Dt__c=System.today();
        cgca3.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca3);
        insert cgcaList;
        
       
        //Message Creation
        List<PRM_Message__c> msgList= new List<PRM_Message__c>();
        PRM_Message__c msg1= new PRM_Message__c();
        msg1.PRM_Title_Txt__c='Gold Member is Upgraded to Titanium';
       // msg1.PRM_Type_Nm__c='Adhoc';
       msg1.RecordTypeId = adhocRecordTypeId;
        msgList.add(msg1);
        
        PRM_Message__c msg2= new PRM_Message__c();
        msg2.PRM_Title_Txt__c='Member is Upgraded to Gold';
       // msg2.PRM_Type_Nm__c='Adhoc';
       msg2.RecordTypeId = adhocRecordTypeId;
        msgList.add(msg2);
        
        PRM_Message__c msg3 = new PRM_Message__c();
        msg3.PRM_Title_Txt__c='Titanium Member is Upgraded';
       	msg3.RecordTypeId = eventRecordTypeId;
        msgList.add(msg3);
        
        insert msgList;
        
      
    }
    
    @isTest
    public static void createMessageLogForContactTest(){
        
        Id cntId=[Select Id from PRM_Contact_Group__c limit 1][0].Id;
        Id msgId1=[Select Id from PRM_Message__c limit 1][0].Id;
        Id msgId2=[Select Id from PRM_Message__c][1].Id;
        List<PRM_Message_Contact_Group_Association__c> mcgaList = new List<PRM_Message_Contact_Group_Association__c>();
        PRM_Message_Contact_Group_Association__c mcga1= new PRM_Message_Contact_Group_Association__c();
        mcga1.PRM_Contact_Group_Id__c=cntId;
        mcga1.PRM_Message_Id__c=msgId1;
        mcgaList.add(mcga1);
        PRM_Message_Contact_Group_Association__c mcga2= new PRM_Message_Contact_Group_Association__c();
        mcga2.PRM_Contact_Group_Id__c=cntId;
        mcga2.PRM_Message_Id__c=msgId2;
        mcgaList.add(mcga2);
        Test.startTest();
        insert mcgaList;
        Test.stopTest();
        List<AggregateResult> countMessageLog= [Select count(Id)Total from PRM_Message_log__c];
        System.assertEquals(4, countMessageLog[0].get('Total'));
    } 
    
     @isTest
    public static void createMessageLogForContactTestSecondSenario(){
        
        Id cntId=[Select Id from PRM_Contact_Group__c limit 1][0].Id;
        Id cntId2=[Select Id from PRM_Contact_Group__c  where Name='IPA Contact Gr 2'][0].Id;
        Id msgId3=[Select Id from PRM_Message__c where RecordTypeId =:eventRecordTypeId][0].Id;
        Id msgId1=[Select Id from PRM_Message__c where RecordTypeId =:adhocRecordTypeId][0].Id;
        
        List<PRM_Message_Contact_Group_Association__c> mcgaList = new List<PRM_Message_Contact_Group_Association__c>();
        PRM_Message_Contact_Group_Association__c mcga1= new PRM_Message_Contact_Group_Association__c();
        mcga1.PRM_Contact_Group_Id__c=cntId;
        mcga1.PRM_Message_Id__c=msgId3;
        mcgaList.add(mcga1);
        PRM_Message_Contact_Group_Association__c mcga2= new PRM_Message_Contact_Group_Association__c();
        mcga2.PRM_Contact_Group_Id__c=cntId2;
        mcga2.PRM_Message_Id__c=msgId3;
        mcgaList.add(mcga2);
        PRM_Message_Contact_Group_Association__c mcga3= new PRM_Message_Contact_Group_Association__c();
        mcga3.PRM_Contact_Group_Id__c=cntId2;
        mcga3.PRM_Message_Id__c=msgId1;
        mcgaList.add(mcga3);
        PRM_Message_Contact_Group_Association__c mcga4= new PRM_Message_Contact_Group_Association__c();
        mcga4.PRM_Contact_Group_Id__c=cntId;
        mcga4.PRM_Message_Id__c=msgId1;
        mcgaList.add(mcga4);
        Test.startTest();
        insert mcgaList;
        Test.stopTest();
        List<AggregateResult> countMessageLog= [Select count(Id)Total from PRM_Message_log__c];
        System.assertEquals(2, countMessageLog[0].get('Total'));
    } 
}