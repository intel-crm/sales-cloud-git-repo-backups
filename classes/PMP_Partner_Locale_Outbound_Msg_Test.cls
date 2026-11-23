@isTest
private class PMP_Partner_Locale_Outbound_Msg_Test {
//IPA2.0 - As part of TWC729-7977 commented the entire class
/*
    public class PartnerWrapMain{
        public String SourceLanguage {get; set;}
        public List<PartnerWrapper> partners {get; set;}
    }
    
    //Wrapper for partner containing relevant fields for translation
    public class PartnerWrapper{
        public String partnerId {get; set;}
        public String partnerDescription {get; set;}
        public String partnerTagline {get; set;}
        public String TargetLanguage {get; set;}
        public Date modifiedDate {get; set;}
    } 

 @testSetup static void setup(){
        Folder folder = [SELECT Id from Folder WHERE DeveloperName= 'PMP_Marketplace_Images' LIMIT 1];
        
		Document doc = new Document(Name='IntelLogo',FolderId = folder.Id); 
        insert doc;
     
        PMP_Company__c testpartnerWc = new PMP_Company__c();
        testpartnerWc.Name = 'testPartnerWc';
        testpartnerWc.PMP_Company_Lifecycle_Status_Nm__c = 'Approved';
        testpartnerWc.PMP_Company_Information_Language_Nm__c='English';
        testpartnerWc.PMP_Translation_Lifecycle_Status_nm__c='Pending';
        testpartnerWc.PMP_Partner_Program_nm__c='OEM';
        testpartnerWc.PMP_Partner_Segment_Nm__c='Internet of Things and Embedded';
       	insert testpartnerWc;
     
         PMP_Company__c testpartnerWc1 = new PMP_Company__c();
        testpartnerWc1.Name = 'testPartnerWc';
        testpartnerWc1.PMP_Company_Lifecycle_Status_Nm__c = 'Admin Review';
        testpartnerWc1.PMP_Company_Information_Language_Nm__c='Simplified Chinese';
        testpartnerWc1.PMP_Translation_Lifecycle_Status_nm__c='Pending';
        testpartnerWc1.PMP_Partner_Program_nm__c='OEM';
        testpartnerWc1.PMP_Partner_Segment_Nm__c='Internet of Things and Embedded';
       	insert testpartnerWc1;
     
        
         PMP_Company__c testpartnerWc2 = new PMP_Company__c();
        testpartnerWc2.Name = 'testPartnerWc';
        testpartnerWc2.PMP_Company_Lifecycle_Status_Nm__c = 'Admin Review';
        testpartnerWc2.PMP_Company_Information_Language_Nm__c='Japanese';
        testpartnerWc2.PMP_Translation_Lifecycle_Status_nm__c='Pending';
        testpartnerWc2.PMP_Partner_Program_nm__c='OEM';
      testpartnerWc2.PMP_Partner_Segment_Nm__c='Internet of Things and Embedded';
       	insert testpartnerWc2;
     
     PMP_Company_Translation__c trans=new PMP_Company_Translation__c();
     trans.Name='Test Trans';
     trans.PMP_Company_Information_Id__c=testpartnerWc.Id;
     trans.PMP_Field_Nm__c='Tagline';  
     trans.PMP_Field_Nm__c='Description'; 
     trans.PMP_English_Txt__c='Description to english';
     insert trans;
     
     PMP_Company_Translation__c trans1=new PMP_Company_Translation__c();
     trans1.Name='Test Trans1';
     trans1.PMP_Company_Information_Id__c=testpartnerWc1.Id;
     trans1.PMP_Field_Nm__c='Tagline';
     trans1.PMP_Field_Nm__c='Description';
     trans1.PMP_Chinese_Txt__c='Description to chinese';
     insert trans1;
     
     PMP_Company_Translation__c trans2=new PMP_Company_Translation__c();
     trans2.Name='Test Trans2';
     trans2.PMP_Company_Information_Id__c=testpartnerWc2.Id;
     trans2.PMP_Field_Nm__c='Tagline';  
     trans2.PMP_Field_Nm__c='Description';  
     trans2.PMP_Japanese_Txt__c='Description to japanese';
     insert trans2;
      
     
      Core_Integration_Outbound_Message__c outMsg = new Core_Integration_Outbound_Message__c();
        outMsg.Core_MessageType__c='Marketplace Translation - Partner';
     	outMsg.Core_Tags__c = 'Marketplace, Translation, Partner';

      	PartnerWrapMain ibpd = new PartnerWrapMain();
        ibpd.SourceLanguage = 'zh-CN';
        ibpd.Partners = new List<PartnerWrapper>();
            
        PartnerWrapper pd = new PartnerWrapper();
        pd.PartnerId = testpartnerWc.Id;
        pd.PartnerDescription = 'test_description';
        pd.partnerTagline = 'test_tagline';
        pd.TargetLanguage = 'EN-US';
        ibpd.Partners.add(pd);
        
        pd = new PartnerWrapper();
        pd.PartnerId = testpartnerWc.Id;
        pd.PartnerDescription = 'test_description';
        pd.partnerTagline = 'test_tagline';
        pd.TargetLanguage = 'ja';
        ibpd.Partners.add(pd);
        
        pd = new PartnerWrapper();
        pd.PartnerId = testpartnerWc.Id;
        pd.PartnerDescription = 'test_description';
        pd.partnerTagline = 'test_tagline';
        pd.TargetLanguage = 'zh-CN';
        ibpd.Partners.add(pd);
        
        outMsg.Core_Payload__c = JSON.serialize(ibpd);
        insert outMsg; 
           
    }
    
    @isTest static void schedulerTest(){ 
          boolean isSuccess = false;
       isSuccess = PMP_Partner_Locale_Outbound_Msg.insertPartnerOutboundMsg();
       Test.startTest();
        PMP_Partner_ScheduleAutoTranslation lsc = new PMP_Partner_ScheduleAutoTranslation();
        
        String sch = '0 0 0/6 1/1 * ? *';
        
        system.schedule('Market Place Locale Test', sch, lsc);
        
        System.assert(isSuccess,'Failed'); 
        Test.stopTest();
    }
    
    @isTest static void insertPartnerOutboundMsgTest(){       
 
        Test.startTest();
        PMP_Partner_Locale_Outbound_Msg.insertPartnerOutboundMsg();    
        List<PMP_Company__c> languages = [select id,name from PMP_Company__c LIMIT 10];
         System.assertNotEquals(Null,languages,'Failed');
        Test.stopTest();
    } 
    
    @isTest static void getLocaleOutboundMsgTest(){       
        
        Test.startTest();
        PMP_Partner_Locale_Outbound_Msg.getLocaleOutboundMsg('en-US','English','zh-CN');  
        PMP_Partner_Locale_Outbound_Msg.getLocaleOutboundMsg('zh-CN','Simplified Chinese','en-US');  
        PMP_Partner_Locale_Outbound_Msg.getLocaleOutboundMsg('JA','Japanese','en-US'); 
        PMP_Partner_Locale_Outbound_Msg.getLocaleOutboundMsg('zh-CN','Simplified Chinese','JA');  
        PMP_Partner_Locale_Outbound_Msg.getLocaleOutboundMsg('en-US','English','JA');
        String response = PMP_Partner_Locale_Outbound_Msg.getLocaleOutboundMsg('JA','Japanese','zh-CN'); 
        Test.stopTest();
        //System.assertNotEquals(Null,response,'Failed');
        System.assertNotEquals(Null, response);
    }
*/
}