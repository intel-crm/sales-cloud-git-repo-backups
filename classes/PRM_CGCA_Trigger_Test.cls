/***************************************************************************************************************************************
Apex Class Name     : PRM_CGCA_Trigger 
Version             : 1.0
Created Date        : March 2020
Function            : PRM_CGCA_Trigger on PRM_Contact_Group_Contact_Association__c
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty,Vijaya                       19-June-2020                     US695552-Create trigger on contact group contact association
*************************************************************************************************************************************/
@isTest
public class PRM_CGCA_Trigger_Test {
    @testSetup
    public static void testData(){
        PRM_Contact_Group__c cntGr = new PRM_Contact_Group__c();
        cntGr.Name = 'IPA Contact Gr';
        insert cntGr;
        PRM_Contact_Group__c cntGr2 = new PRM_Contact_Group__c();
        cntGr2.Name = 'IPA Contact Gr 2';
        insert cntGr2;
        Account testAcc = new Account();
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
        //con1.Core_IPA_Partner_Role__c = 'Service Provider';
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
        //con2.Core_IPA_Partner_Role__c = 'Service Provider';
        con2.Core_IPA_PartnerRole__c = 'Service Provider';
        con2.Core_Login_Id__c = 'Test';
        con2.MailingCountry='USA';
        conListData.add(con2);
        insert conListData;
        
        //contact group contact association
        List<PRM_Contact_Group_Contact_Association__c> cgcaList =new List<PRM_Contact_Group_Contact_Association__c>();
        PRM_Contact_Group_Contact_Association__c cgca1= new PRM_Contact_Group_Contact_Association__c();//CGCA for C1 with CG1
        cgca1.PRM_Contact_Group_Id__c=cntGr.Id;
        cgca1.PRM_Contact_Id__c=conListData[0].Id;
        cgca1.PRM_Start_Date_Dt__c=System.today();
        cgca1.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca1);
        PRM_Contact_Group_Contact_Association__c cgca2= new PRM_Contact_Group_Contact_Association__c();//CGCA for C2 with CG1
        cgca2.PRM_Contact_Group_Id__c=cntGr.Id;
        cgca2.PRM_Contact_Id__c=conListData[1].Id;
        cgca2.PRM_Start_Date_Dt__c=System.today();
        cgca1.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca2);
        PRM_Contact_Group_Contact_Association__c cgca3 = new PRM_Contact_Group_Contact_Association__c();//CGCA for C1 with CG2
        cgca3.PRM_Contact_Group_Id__c = cntGr2.Id;
        cgca3.PRM_Contact_Id__c = conListData[0].Id;
        cgca2.PRM_Start_Date_Dt__c=System.today();
        cgca3.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca3);
        insert cgcaList;
        
        Id adhocRecordTypeId=Schema.SObjectType.PRM_Message__c.getRecordTypeInfosByName().get('Adhoc').getRecordTypeId();
        Id eventRecordTypeId=Schema.SObjectType.PRM_Message__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        //Message Creation
        List<PRM_Message__c> msgList= new List<PRM_Message__c>();
        PRM_Message__c msg1= new PRM_Message__c();
        msg1.PRM_Title_Txt__c='Gold Member is Upgraded';
        msg1.RecordTypeId = adhocRecordTypeId;
        msgList.add(msg1);
        
        PRM_Message__c msg2= new PRM_Message__c();
        msg2.PRM_Title_Txt__c='Titanium member is Upgraded';
        msg2.RecordTypeId = adhocRecordTypeId;
        msgList.add(msg2);
        
        insert msgList;
        
        List<PRM_Message_log__c> messageLogList = new List<PRM_Message_log__c>();
        //system.debug('Message Id '+msgList[0].id);
        PRM_Message_log__c msgLog1 = new PRM_Message_log__c();//M1C1
        msgLog1.PRM_Message_Id__c = msgList[0].id;
        msgLog1.PRM_Contact_Id__c = conListData[0].id;
        msgLog1.PRM_Inactive_Ind__c = false;
        messageLogList.add(msgLog1);
        
        PRM_Message_log__c msgLog2 = new PRM_Message_log__c();//M2C2
        msgLog2.PRM_Message_Id__c = msgList[1].id;
        msgLog2.PRM_Contact_Id__c = conListData[1].id;
        msgLog2.PRM_Inactive_Ind__c = false;
        messageLogList.add(msgLog2);
        
        PRM_Message_log__c msgLog3 = new PRM_Message_log__c();//M1C2
        msgLog3.PRM_Message_Id__c = msgList[0].id;
        msgLog3.PRM_Contact_Id__c = conListData[1].id;
        msgLog3.PRM_Inactive_Ind__c = false;
        messageLogList.add(msgLog3);
        
        insert messageLogList; 
        
        
    }
    
    
    @isTest
    public static void createMessageLogForContactTestPostive(){
        Id cntId=[Select Id from PRM_Contact_Group__c limit 1][0].Id;
        Id cont1=[Select Id from Contact where FirstName = 'Adam' limit 1].Id;
        Id cont2=[Select Id from Contact where FirstName = 'Test' limit 1].Id;
        List<PRM_Contact_Group_Contact_Association__c> updatedcgcaList = new List<PRM_Contact_Group_Contact_Association__c>();
        
        Test.startTest();
         for(PRM_Contact_Group_Contact_Association__c eachCGCA : [Select Id, PRM_InActive_Ind__c from PRM_Contact_Group_Contact_Association__c where PRM_Contact_Id__c =:cont1]){
             eachCGCA.PRM_InActive_Ind__c = true ;
             updatedcgcaList.add(eachCGCA);
        }
        if(updatedcgcaList.size() > 0){
            update updatedcgcaList;
        }
        Test.stopTest();
       Integer countResult=Database.countQuery('Select count() from PRM_Message_Log__c where PRM_InActive_Ind__c=true');
        System.assertEquals(1, countResult);
    }
     @isTest
    public static void createMessageLogForContactTestNegative(){
        Id cntId=[Select Id from PRM_Contact_Group__c limit 1][0].Id;
        Id cont1=[Select Id from Contact where FirstName = 'Adam' limit 1].Id;
        Id cont2=[Select Id from Contact where FirstName = 'Test' limit 1].Id;
        List<PRM_Contact_Group_Contact_Association__c> updatedcgcaList = new List<PRM_Contact_Group_Contact_Association__c>();
        
        Test.startTest();
         for(PRM_Contact_Group_Contact_Association__c eachCGCA : [Select Id, PRM_InActive_Ind__c from PRM_Contact_Group_Contact_Association__c where PRM_Contact_Id__c =:cont1 AND PRM_Contact_Group_Id__c=:cntId]){
             eachCGCA.PRM_InActive_Ind__c = true ;
             updatedcgcaList.add(eachCGCA);
        }
        if(updatedcgcaList.size() > 0){
            update updatedcgcaList;
        }
        Test.stopTest();
         Integer countResult=Database.countQuery('Select count() from PRM_Message_Log__c where PRM_InActive_Ind__c=true');
        System.assertEquals(0, countResult);
    }
    
    
}