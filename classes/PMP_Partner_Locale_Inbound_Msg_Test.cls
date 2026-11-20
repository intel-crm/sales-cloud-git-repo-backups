@isTest
private class PMP_Partner_Locale_Inbound_Msg_Test {
//TranslationEOL
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_Partner_Locale_Inbound_Msg.isWorking();
        System.assertEquals(true, result);
    }
   /* 

    public class InboundPayload {
        public String SourceLanguage {get; set;}
        public List<PartnerData> Partners {get; set;}
    } 
    
    public class PartnerData{
        public String PartnerId {get; set;}
        // public String PartnerName {get; set;}
        public String PartnerDescription {get; set;}
        public String TagLine {get; set;}
        public String TargetLanguage {get; set;}
        public Date ModifiedDate {get; set;}
        
    }
    
    @testSetup static void setup(){
        Folder folder = [SELECT Id from Folder WHERE DeveloperName= 'PMP_Marketplace_Images' LIMIT 1];
        
		Document doc = new Document(Name='IntelLogo',FolderId = folder.Id); 
        insert doc;
         List<PMP_Company_Translation__c> transList = new List<PMP_Company_Translation__c>();
        
      
        
          PMP_Company__c testpartnerWc = new PMP_Company__c();
        testpartnerWc.Name = 'testPartnerWc';
        testpartnerWc.PMP_Company_Lifecycle_Status_Nm__c = 'Approved';
        testpartnerWc.PMP_Company_Information_Language_Nm__c='English';
        testpartnerWc.PMP_Translation_Lifecycle_Status_nm__c='Complete';
        testpartnerWc.PMP_Translated_Languages_Txt__c='English';
        testpartnerWc.PMP_Account_Dsc__c=String.valueOf(DateTime.now());
        testpartnerWc.PMP_Account_Tag_Line__c=String.valueOf(DateTime.now());
        testpartnerWc.PMP_Partner_Program_nm__c='ISA';
        testpartnerWc.PMP_Is_Updated_Ind__c = true;
        testpartnerWc.PMP_Is_Working_Copy_Ind__c = true;
       	insert testpartnerWc;
        
    //    List<Id> partnerIds=new List<Id>();
   //     partnerIds.add(testpartnerWc.Id);
   //     PMP_Partner_Locale_Inbound_Msg.publishTranslations(partnerIds);
        
     
         PMP_Company__c testpartner = new PMP_Company__c();
        testpartner.Name = 'testPartner';
        testpartner.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        testpartner.PMP_Company_Information_Language_Nm__c='Simplified Chinese';
        testpartner.PMP_Translation_Lifecycle_Status_nm__c='Complete';
         testpartner.PMP_Translated_Languages_Txt__c='Simplified Chinese';
        testpartner.PMP_Partner_Program_nm__c='ISA';
         testpartner.PMP_Is_Updated_Ind__c = true;
        testpartner.PMP_Is_Published_Ind__c = true;
        testpartner.PMP_Is_Working_Copy_Ind__c = true;
           testpartner.PMP_Working_Copy_Id__c = testpartnerWc.Id;
       	insert testpartner;
        
        
        PMP_Company_Translation__c trans = new PMP_Company_Translation__c();
        trans.PMP_Field_Nm__c=PMP_StaticConstants_Partner.Tagline;
        trans.PMP_English_Txt__c='Test';
        trans.PMP_Company_Information_Id__c=testpartnerWc.Id;
        transList.add(trans);
        
        PMP_Company_Translation__c trans1 = new PMP_Company_Translation__c();
        trans1.PMP_Field_Nm__c=PMP_StaticConstants_Partner.Description;
          trans1.PMP_English_Txt__c='Test';
        trans1.PMP_Company_Information_Id__c=testpartnerWc.Id;
        transList.add(trans1);
        
        
        
        
         PMP_Company_Translation__c trans2 = new PMP_Company_Translation__c();
        trans2.PMP_Field_Nm__c=PMP_StaticConstants_Partner.Tagline;
        trans2.PMP_Company_Information_Id__c=testpartner.Id;
            trans2.PMP_Chinese_Txt__c='Test';
        transList.add(trans2);
        
         PMP_Company_Translation__c trans3 = new PMP_Company_Translation__c();
        trans3.PMP_Field_Nm__c=PMP_StaticConstants_Partner.Description;
            trans3.PMP_Chinese_Txt__c='Test';
        trans3.PMP_Company_Information_Id__c=testpartner.Id;
        transList.add(trans3);                                      
        insert transList;
        
        Core_Integration_Inbound_Message__c inbMsg = new Core_Integration_Inbound_Message__c();
        List<PartnerData> partners = new List<PartnerData>();
            
        PartnerData pd = new PartnerData();
        pd.PartnerId = testpartnerWc.Id;
        pd.PartnerDescription = 'test_description';
        pd.Tagline = 'test_tagline';
        pd.TargetLanguage = 'ZH-CN';
        pd.ModifiedDate =  date.today();
        partners.add(pd);
        
        pd = new PartnerData();
        pd.PartnerId = testpartnerWc.Id;
        pd.PartnerDescription = 'test_description';
        pd.Tagline = 'test_tagline';
        pd.TargetLanguage = 'EN-US';
        pd.ModifiedDate =  date.today();
        partners.add(pd);
        
        pd = new PartnerData();
        pd.PartnerId = testpartnerWc.Id;
        pd.PartnerDescription = 'test_description';
        pd.Tagline = 'test_tagline';
        pd.TargetLanguage = 'JA';
        pd.ModifiedDate =  date.today();
        partners.add(pd);
        
        InboundPayload ibpd = new InboundPayload();
        ibpd.SourceLanguage = 'ZH-CN';
        ibpd.Partners = partners;
        
       // inbMsg.Core_Payload__c = JSON.serialize(ibpd);
        inbMsg.Core_Payload1__c='EN-US';
        insert inbMsg;
        
        Core_Integration_Inbound_Message__c inbMsg1 = new Core_Integration_Inbound_Message__c();  
        List<PartnerData> partners1 = new List<PartnerData>();
            
        PartnerData pd1 = new PartnerData();
        pd1.PartnerId = testpartnerWc.Id;
        pd1.PartnerDescription = 'test_description';
        pd1.Tagline = 'test_tagline';
        pd1.TargetLanguage = 'ZH-CN';
        pd1.ModifiedDate =  date.today();
        partners.add(pd1);
        
        pd1 = new PartnerData();
        pd1.PartnerId = testpartnerWc.Id;
        pd1.PartnerDescription = 'test_description';
        pd1.Tagline = 'test_tagline';
        pd1.TargetLanguage = 'EN-US';
        pd1.ModifiedDate =  date.today();
        partners.add(pd1);
        
        pd1 = new PartnerData();
        pd1.PartnerId = testpartnerWc.Id;
        pd1.PartnerDescription = 'test_description';
        pd1.Tagline = 'test_tagline';
        pd1.TargetLanguage = 'JA';
        pd1.ModifiedDate =  date.today();
        partners.add(pd1);
                
        InboundPayload ibpd1 = new InboundPayload();
        ibpd1.SourceLanguage = 'EN-US';
        ibpd1.Partners = partners;
        
        inbMsg1.Core_Payload__c = JSON.serialize(ibpd1);
        inbMsg1.Core_Payload1__c='JA';
        insert inbMsg1;  
        
        
        Core_Integration_Outbound_Message__c oBMsg = new Core_Integration_Outbound_Message__c();
        oBMsg.Core_MessageType__c = 'Marketplace Translation';
        oBMsg.Core_Payload__c = 'outboundmsg';
        oBMsg.Core_Tags__c = 'Marketplace, Translation, Partner';
        Insert oBMsg;
        
         
        string inboundPayload='{ "SourceLanguage": "JA", "partners": [ { "TargetLanguage": "en-US", "Tagline": "Succesfull",  "PartnerId": testpartnerWc.Id, "PartnerDescription": "Auto trans was successfull", "ModifiedDate": "2020-04-14" }]}'; 
        
       
       Core_Integration_Inbound_Message__c inboundMessage=new Core_Integration_Inbound_Message__c();
        inboundMessage.Core_Source_System__c='GLS';
        inboundMessage.Core_Message_Type__c='Marketplace Translation';
        inboundMessage.Core_Payload1__c='ZH-CN';
        inboundMessage.Core_Outbound_Message__c=oBMsg.Id;
        inboundMessage.Core_Payload__c = JSON.serialize(ibpd);
        insert inboundMessage;
      
       Core_Integration_Inbound_Message__c inboundMessage2=new Core_Integration_Inbound_Message__c();
        inboundMessage2.Core_Source_System__c='GLS';
        inboundMessage2.Core_Message_Type__c='Marketplace Translation';
        inboundMessage2.Core_Payload1__c='ZH-CN';
        inboundMessage2.Core_Payload__c = JSON.serialize(ibpd);
        insert inboundMessage2;
        
        Core_Integration_Inbound_Message__c inboundMessage3=new Core_Integration_Inbound_Message__c();
        inboundMessage3.Core_Source_System__c='GLS';
        inboundMessage3.Core_Message_Type__c='Marketplace Translation';
        inboundMessage3.Core_Payload1__c='JA';
        inboundMessage3.Core_Payload__c = JSON.serialize(ibpd);
        insert inboundMessage3;
        
        
               
         Core_Integration_Inbound_Message__c inboundMessage4=new Core_Integration_Inbound_Message__c();
        inboundMessage4.Core_Source_System__c='GLS';
        inboundMessage4.Core_Message_Type__c='Marketplace Translation';
        inboundMessage4.Core_Payload1__c='EN-US';
        inboundMessage4.Core_Outbound_Message__c=oBMsg.Id;
        inboundMessage4.Core_Payload__c = JSON.serialize(ibpd1);
        insert inboundMessage4;
      
        Core_Integration_Inbound_Message__c inboundMessage5=new Core_Integration_Inbound_Message__c();
        inboundMessage5.Core_Source_System__c='GLS';
        inboundMessage5.Core_Message_Type__c='Marketplace Translation';
        inboundMessage5.Core_Payload1__c='EN-US';
        inboundMessage5.Core_Payload__c = JSON.serialize(ibpd1);
        insert inboundMessage5;
        
        Core_Integration_Inbound_Message__c inboundMessage6=new Core_Integration_Inbound_Message__c();
        inboundMessage6.Core_Source_System__c='GLS';
        inboundMessage6.Core_Message_Type__c='Marketplace Translation';
        inboundMessage6.Core_Payload1__c='ZH-CN';
         inboundMessage6.Core_Processing_Status__c='Failed';
        inboundMessage6.Core_Payload__c = JSON.serialize(ibpd1);
        insert inboundMessage6;                   
        
    }  
    
    
    @isTest static void updateLocaleDetails_Test(){           
       
        Test.startTest();
        
        List<PartnerData> partnersData = new List<PartnerData>();  
        Map<Id,List<PartnerData>> partnerMap = new Map<Id,List<PartnerData>>();
        for(PartnerData pp:partnersData)
        {
            partnerMap.put(pp.PartnerId,partnersData);
            
        }
         // List<PMP_Company__c> publishedPartners = [SELECT Id,PMP_Working_Copy_Id__c FROM PMP_Company__c];
         	List<PMP_Company_Translation__c> updatedTransList1 = [Select Id,Name,PMP_Company_Information_Id__c from PMP_Company_Translation__c LIMIT 10];
    		Core_Integration_Inbound_Message__c inboundMe=new Core_Integration_Inbound_Message__c();
            Map<Id,Core_Integration_Inbound_Message__c> inboundMap3=new Map<Id,Core_Integration_Inbound_Message__c>([SELECT Id,Name,Core_Payload__c,Core_Payload1__c,Core_Processing_Status__c FROM Core_Integration_Inbound_Message__c LIMIT 5]);
         //inboundMap3.put(inboundMe.Id,inboundMe);
        
          
		 PMP_Partner_Locale_Inbound_Msg.targetLanguage='EN-US';       
         PMP_Partner_Locale_Inbound_Msg.updateLocaleDetails(inboundMap3);
        
         
		 PMP_Partner_Locale_Inbound_Msg.targetLanguage='JA';       
         PMP_Partner_Locale_Inbound_Msg.updateLocaleDetails(inboundMap3);
                               
           Map<String,String> workPubIdMap = new Map<String,String>();
        List<Id> approvedId=new List<Id>();
        List<PMP_Company_Translation__c> updatedTransList = [Select Id,Name from PMP_Company_Translation__c LIMIT 10];
         List<PMP_Company__c> publishedPartners = [SELECT Id,PMP_Working_Copy_Id__c FROM PMP_Company__c LIMIT 10];
        for(PMP_Company__c comp: publishedPartners){
            workPubIdMap.put(comp.PMP_Working_Copy_Id__c, comp.Id);
            approvedId.add(comp.Id);
            
        }
         PMP_Partner_Locale_Inbound_Msg.publishTranslations(approvedId);
        
        
        List<Id> CoredIds=new List<Id>();
         List<Id> CoredIds1=new List<Id>();
        List<Core_Integration_Inbound_Message__c> failedMessages=[Select Id,Name,Core_Outbound_Message__c from Core_Integration_Inbound_Message__c LIMIT 10];
        List<Core_Integration_Outbound_Message__c> outboundMsg=[Select Id,Core_MessageType__c,Core_Payload__c,Core_Tags__c From Core_Integration_Outbound_Message__c LIMIT 10];
     
        for(Core_Integration_Inbound_Message__c cc:failedMessages)
        {
             
            if(cc.Core_Outbound_Message__c!=null)
            {
                 CoredIds1.add(outboundMsg[0].Id);
         
            }
           
            CoredIds.add(cc.Id);
        }
        
       	PMP_Partner_Locale_Inbound_Msg.rePublish(failedMessages);
        system.AssertNotEquals(Null,outboundMsg.size(),'failed');
  //        PMP_Partner_Locale_Inbound_Msg.rePublish(NULL);
        
        
        Test.stopTest();
        
        
    }  */ 
   
    
}