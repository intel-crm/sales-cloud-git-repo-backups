@isTest
public class MarketplaceMessagingController_Test {
    /*
    @isTest
    public static void getMessageOfferingTest(){
        Account acc = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        PMP_Company__c cmp = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc.Id, true);
        PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
                                                                               'TestDuplicate',cmp.Id, true,'Draft','');
        PMP_Partner_Offering_Message__c message=new PMP_Partner_Offering_Message__c();
        String dateTimeSt='2019-06-16T03:29:59.006Z';
        message.PMP_Message_Dtm__c=(DateTime)json.deserialize(('"'+dateTimeSt+'"'),datetime.class);
        message.PMP_Message_Txt__c='In vestibulum risus ipsum, et venenatis justo semper sed.';
        message.PMP_Message_Type__c='Message';
        message.PMP_Partner_Offering_Id__c =offering.Id;
        insert message;
        Test.startTest();
        MarketplaceMessagingController.getMessage(offering.id,'Offering');
        Test.stopTest();
        System.assertNotEquals(offering.id, null);
    }
    */
     /*@isTest//IPA2.0: US-TWC729-7976
    public static void getMessageSolutionTest(){
        ArdiraSurvey__Survey__c survey=new ArdiraSurvey__Survey__c();
        survey.ArdiraSurvey__CNav_Pagination__c='Section';
        survey.Name='Solution Survey';
        survey.ArdiraSurvey__Status__c='Closed';
        insert survey;
        Profile profileName= [Select Id from profile where Name='System Administrator']; 
        User newUser=PMP_TestDataUtility.createTestUser(profileName); 
        insert newUser;
        ArdiraSurvey__Survey_Result__c result=new ArdiraSurvey__Survey_Result__c();
        result.ArdiraSurvey__Survey__c=survey.id;
        result.ArdiraSurvey__Assigned_To_User__c=newUser.id;
        insert result;
        PSS_Solution_message__c solutionmessage=new PSS_Solution_message__c();
        String dateTimeSt='2019-06-16T03:29:59.006Z';
        solutionmessage.PSS_Message_dt__c=(DateTime)json.deserialize(('"'+dateTimeSt+'"'),datetime.class);
        solutionmessage.PSS_Message_Txt__c='In vestibulum risus ipsum, et venenatis justo semper sed.';
        solutionmessage.PSS_Message_Type_Nm__c='Message';
        solutionmessage.PSS_Ardira_Survey_Result_Id__c =result.Id;
        insert solutionmessage;
        Test.startTest();
        MarketplaceMessagingController.getMessage(result.id,'Solution');
        Test.stopTest();
        System.assertNotEquals(result.id, null);
    }*/
    @isTest
    public static void getMessagePartnerTest(){
      Account account = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
      PMP_Company__c company = PMP_TestDataUtility.createCompanyInformation('TestCompany1', account.Id, true);
          Profile profileName= [Select Id from profile where Name='System Administrator']; 
        User newUser=PMP_TestDataUtility.createTestUser(profileName); 
        insert newUser;
 		PMP_Company_Message__c companymessage=new PMP_Company_Message__c();
        String dateTimeSt='2019-06-16T03:29:59.006Z';
        companymessage.PMP_Message_Dtm__c=(DateTime)json.deserialize(('"'+dateTimeSt+'"'),datetime.class);
        companymessage.PMP_Message_Txt__c='In vestibulum risus ipsum, et venenatis justo semper sed.';
        companymessage.PMP_Message_Type__c='Message';
        companymessage.PMP_Message_By_Id__c =newUser.Id;
        companymessage.PMP_Company_Id__c=company.id;
        insert companymessage;
        Test.startTest();
        MarketplaceMessagingController.getMessage(company.id,'partner');
        Test.stopTest();
        System.assertNotEquals(company.id, null);
    }
    @isTest
    public static void postMessageOfferingTest(){
          /*ArdiraSurvey__Survey__c survey=new ArdiraSurvey__Survey__c();//IPA2.0: US-TWC729-7976
        survey.ArdiraSurvey__CNav_Pagination__c='Section';
        survey.Name='Solution Survey';
        survey.ArdiraSurvey__Status__c='Closed';
        insert survey;*/
        
        Profile profileName= [Select Id from profile where Name='System Administrator']; 
        User newUser=PMP_TestDataUtility.createTestUser(profileName); 
        insert newUser;
        /*ArdiraSurvey__Survey_Result__c result=new ArdiraSurvey__Survey_Result__c();//IPA2.0: US-TWC729-7976
        result.ArdiraSurvey__Survey__c=survey.id;
        result.ArdiraSurvey__Assigned_To_User__c=newUser.id;
        insert result;*/
        Account acc = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        PMP_Company__c cmp = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc.Id, true);
       // PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
        //                                                                       'TestDuplicate',cmp.Id, true,'Draft','');
        Map<String,String> jsonMessage=new Map<String,String>();
        jsonMessage.put('author','Roberto Fuller');
        jsonMessage.put('userID',newUser.Id);
        jsonMessage.put('timestamp','2019-06-16T03:29:59.006Z');
        jsonMessage.put('message','Hello World!');
        jsonMessage.put('type','message');
        Test.startTest();
        // Boolean response = MarketplaceMessagingController.postMessage(offering.Id,jsonMessage,'Offering'); 
        //Boolean solutioresponse= MarketplaceMessagingController.postMessage(result.Id,jsonMessage,'Solution');//IPA2.0: US-TWC729-7976
        Boolean companyresponse=MarketplaceMessagingController.postMessage(cmp.Id,jsonMessage,'Partner');
        Test.stopTest();
        // System.assertNotEquals(offering.Id, null);
    }

}