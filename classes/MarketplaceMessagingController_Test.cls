@isTest
public class MarketplaceMessagingController_Test {
    
    
    
    @isTest		
    public static void getMessageTest(){
        
        Test.startTest();
        MarketplaceMessagingController.Message msg = new MarketplaceMessagingController.Message();
        //Inserting partner record
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
                                                                               'TestDuplicate',cmp1.Id, true,'Draft','');
        
        Profile profileName= [Select Id from profile where Name='System Administrator']; 
        User newUser=PMP_TestDataUtility.createTestUser(profileName);    
        
        //Creating Partner Messages for the above partner 
        PMP_Partner_Offering_Message__c msg1=new PMP_Partner_Offering_Message__c();
        msg1.PMP_Message_By_Id__c=newUser.Id;//'0050n000001wOL9AAM';
        String dateTimeSt='2019-06-16T03:29:59.006Z';
        msg1.PMP_Message_Dtm__c=(DateTime)json.deserialize(('"'+dateTimeSt+'"'),datetime.class);
        msg1.PMP_Message_Txt__c='In vestibulum risus ipsum, et venenatis justo semper sed.';
        msg1.PMP_Message_Type__c='Message';
        msg1.PMP_Partner_Offering_Id__c =offering1.Id;
        insert msg1;
        
        PMP_Partner_Offering_Message__c msg2=new PMP_Partner_Offering_Message__c();
        msg2.PMP_Message_By_Id__c=newUser.Id;
        dateTimeSt='2019-06-16T03:29:59.006Z';
        msg2.PMP_Message_Dtm__c=(DateTime)json.deserialize(('"'+dateTimeSt+'"'),datetime.class);
        msg2.PMP_Message_Txt__c='In vestibulum risus ipsum, et venenatis justo semper sed.';
        msg2.PMP_Message_Type__c='Message';
        msg2.PMP_Partner_Offering_Id__c=offering1.id;
        insert msg2;
        
        MarketplaceMessagingController.getMessage(offering1.id,false);
        
        Test.stopTest();  
        
        
        
        
    }
    
    @isTest		
    public static void getMessageTestPartner(){
        
        Test.startTest();
        Profile profileName= [Select Id from profile where Name='System Administrator']; 
        User newUser=PMP_TestDataUtility.createTestUser(profileName);  
        
        MarketplaceMessagingController.Message msg = new MarketplaceMessagingController.Message();
        //Inserting partner record
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        
        
        PMP_Company_Message__c companyMessage=new PMP_Company_Message__c();
        String dateTimeSt='2019-06-16T03:29:59.006Z';
        companyMessage.PMP_Message_Txt__c='In vestibulum risus ipsum, et venenatis justo semper sed.';
        companyMessage.PMP_Message_Type__c='Message';
        companyMessage.PMP_Message_By_Id__c=newUser.Id;
        companyMessage.PMP_Company_Id__c=cmp1.Id;
        companyMessage.PMP_Message_Dtm__c=(DateTime)json.deserialize(('"'+dateTimeSt+'"'),datetime.class);
        //companyMessage.PMP_Company_Lifecycle_Status_Nm__c=
        insert companyMessage;
        
        
        PMP_Company_Message__c companyMessage2=new PMP_Company_Message__c();
        dateTimeSt='2019-06-16T03:29:59.006Z';
        companyMessage2.PMP_Message_Txt__c='In vestibulum risus ipsum, et venenatis justo semper sed.';
        companyMessage2.PMP_Message_Type__c='Message';
        companyMessage2.PMP_Message_By_Id__c=newUser.Id;
        companyMessage2.PMP_Company_Id__c=cmp1.Id;
        companyMessage2.PMP_Message_Dtm__c=(DateTime)json.deserialize(('"'+dateTimeSt+'"'),datetime.class);
        //companyMessage.PMP_Company_Lifecycle_Status_Nm__c=
        insert companyMessage2;
        
        MarketplaceMessagingController.getMessage(cmp1.id,true);
        //MarketplaceMessagingController.getMessage(companyMessage2.id,true);
        
        Test.stopTest();         
    }
    
    @isTest
    public static void getUserNameTest(){
        MarketplaceMessagingController.getUserName();
    }
    @isTest
    public static void postMessageTest(){
        Test.startTest();

        Profile profileName= [Select Id from profile where Name='System Administrator']; 
        User newUser=PMP_TestDataUtility.createTestUser(profileName);  
        
        PMP_Partner_Offering__c partnerOffering=new PMP_Partner_Offering__c();
        partnerOffering.Name=String.valueOf(DateTime.now());
        insert partnerOffering;
        
        Map<String,String> jsonMessage=new Map<String,String>();
        jsonMessage.put('author','Roberto Fuller');
        jsonMessage.put('userID',newUser.Id);
        jsonMessage.put('timestamp','2019-06-16T03:29:59.006Z');
        jsonMessage.put('message','Hello World!');
        jsonMessage.put('type','message');
        
        MarketplaceMessagingController.postMessage((String)partnerOffering.Id,jsonMessage,false); 
        Test.stopTest();
    }
    
    @isTest
    public static void postMessagePartnerTest(){
        Test.startTest();
        Profile profileName= [Select Id from profile where Name='System Administrator']; 
        User newUser=PMP_TestDataUtility.createTestUser(profileName);  
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        
        Map<String,String> jsonMessage=new Map<String,String>();
        jsonMessage.put('author','Roberto Fuller');
        jsonMessage.put('userID',newUser.Id);
        jsonMessage.put('timestamp','2019-06-16T03:29:59.006Z');
        jsonMessage.put('message','Hello World!');
        jsonMessage.put('type','message'); 
        
        MarketplaceMessagingController.postMessage((String)cmp1.Id,jsonMessage,true); 
        Test.stopTest(); 
    }
}