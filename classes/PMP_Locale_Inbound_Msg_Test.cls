@isTest
public class PMP_Locale_Inbound_Msg_Test {
/*
    @isTest
    static void updateLocaleDetails(){
        test.startTest();
        //Create account
        Account testAccount = new Account();
        testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
        testAccount.Name = 'Test Account 19-Jun-19';       
        testAccount.Core_Account_Country__c='India';
        testAccount.Core_Sales_Group_New__c='US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        insert testAccount;
        
        //Create a company
         PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
                                                         PMP_Account_Id__c=testAccount.Id);
        insert testCompany;
        
        //Inserting partner record
        PMP_Partner_Offering__c partnerOffering=new PMP_Partner_Offering__c();
        partnerOffering.Name=String.valueOf(DateTime.now());
        partnerOffering.PMP_Offering_Language_Nm__c='English';
        partnerOffering.PMP_Partner_Offering_Nm__c = partnerOffering.Name;
        partnerOffering.PMP_Partner_Offering_Visibility_Nm__c='Public Content';
        partnerOffering.PMP_Partner_Offering_Dsc__c=String.valueOf(DateTime.now());
        partnerOffering.PMP_Partner_Offering_Tag_Line_Txt__c=String.valueOf(DateTime.now());
        partnerOffering.PMP_Company_Id__c=testCompany.Id;
        partnerOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Approved';
        partnerOffering.PMP_Translated_Languages__c='English';
        partnerOffering.PMP_Partner_Offering_Start_Dt__c=Date.today().addDays(-1);
        insert partnerOffering;
        
      
     
            
            
        //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslation=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslation.Name=partnerOffering.Id+'PMP_Partner_Offering_Nm__c';
        partnerOfferingTranslation.PMP_Partner_Offering_Id__c=partnerOffering.Id;
        partnerOfferingTranslation.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        partnerOfferingTranslation.PMP_English_Txt__c=partnerOffering.Name;
        partnerOfferingTranslation.PMP_Chinese_Txt__c='';
        partnerOfferingTranslation.PMP_Japanese_Txt__c='';
        insert partnerOfferingTranslation;
        
           //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLine=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLine.Name=partnerOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLine.PMP_Partner_Offering_Id__c=partnerOffering.Id;
        partnerOfferingTranslationTagLine.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLine.PMP_English_Txt__c=partnerOffering.Name;
        partnerOfferingTranslationTagLine.PMP_Chinese_Txt__c='';
        partnerOfferingTranslationTagLine.PMP_Japanese_Txt__c='';
        insert partnerOfferingTranslationTagLine;
        
        
         //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLineChinese=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLineChinese.Name=partnerOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineChinese.PMP_Partner_Offering_Id__c=partnerOffering.Id;
        partnerOfferingTranslationTagLineChinese.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineChinese.PMP_English_Txt__c='';
        partnerOfferingTranslationTagLineChinese.PMP_Chinese_Txt__c=partnerOffering.Name;
        partnerOfferingTranslationTagLineChinese.PMP_Japanese_Txt__c='';
        insert partnerOfferingTranslationTagLineChinese;
        
         //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLineJapanese=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLineJapanese.Name=partnerOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineJapanese.PMP_Partner_Offering_Id__c=partnerOffering.Id;
        partnerOfferingTranslationTagLineJapanese.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineJapanese.PMP_English_Txt__c='';
        partnerOfferingTranslationTagLineJapanese.PMP_Chinese_Txt__c='';
        partnerOfferingTranslationTagLineJapanese.PMP_Japanese_Txt__c=partnerOffering.Name;
        insert partnerOfferingTranslationTagLineJapanese;

       

       
        
        
        
        string inboundPayload='{   "Source Language": "en-US",   "Offerings": [          {       "TargetLanguage": "JA",       "TagLine": null,       "SentDate": "2019-08-02",       "OfferingName": null,       "OfferingId": "'+partnerOffering.Id+'",       "OfferingDescription": "<p>A set of chips that provides the interfaces between all of the PC&#39;s subsystems. It provides the buses and electronics to allow the CPU, memory and input/output devices to interact. Most Intel chipsets, which are contained on two to four chips, also include built-in EIDE support. In the past, Intel used the name &quot;Triton&quot; for its chipsets. It also used the name PCIset for PCI-based chipsets. Following is a brief summary of earlier Pentium chipsets.</p><p>975X - For dual core Extreme Edition and Pentium D CPUs. Includes Ethernet and HD Audio. Supports 1066 MHz FSB, 8GB dual channel DDR2 RAM, PCI Express and PCI Express x16 for external graphics.</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Japanese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Japanese",       "TranslatedTagline": "TranslatedTagline in Japanese"     },     {       "TargetLanguage": "zh-CN",       "TagLine": null,       "SentDate": "2019-08-02",       "OfferingName": null,       "OfferingId": "'+partnerOffering.Id+'",       "OfferingDescription": "<p>A set of chips that provides the interfaces between all of the PC&#39;s subsystems. It provides the buses and electronics to allow the CPU, memory and input/output devices to interact. Most Intel chipsets, which are contained on two to four chips, also include built-in EIDE support. In the past, Intel used the name &quot;Triton&quot; for its chipsets. It also used the name PCIset for PCI-based chipsets. Following is a brief summary of earlier Pentium chipsets.</p><p>975X - For dual core Extreme Edition and Pentium D CPUs. Includes Ethernet and HD Audio. Supports 1066 MHz FSB, 8GB dual channel DDR2 RAM, PCI Express and PCI Express x16 for external graphics.</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Chinese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Chinese",       "TranslatedTagline": "TranslatedTagline in Chinese"     }   ] }';
            
            //string inboundPayload='{   "Source Language": "en-US",   "Offerings": [     {       "Target Language": "JA",       "TagLine": "TNZintelonlyoffering002",       "SentDate": "2019-08-02",       "Offering Name": "null",       "OfferingId": "a3s0n0000002FLAAA2",       "Offering Description": "<p>TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Japanese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Japanese",       "TranslatedTagline": "TranslatedTagline in Japanese"     },     {       "Target Language": "zh-CN",       "TagLine": "TNZintelonlyoffering002",       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002FLAAA2",       "Offering Description": "<p>TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Chinese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Chinese",       "TranslatedTagline": "TranslatedTagline in Chinese"     },     {       "Target Language": "JA",       "TagLine": null,       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002ILHAA2",       "Offering Description": "<p>description</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Japanese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Japanese",       "TranslatedTagline": "TranslatedTagline in Japanese"     },     {       "Target Language": "zh-CN",       "TagLine": null,       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002ILHAA2",       "Offering Description": "<p>description</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Chinese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Chinese",       "TranslatedTagline": "TranslatedTagline in Chinese"     },     {       "Target Language": "JA",       "TagLine": null,       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002HBzAAM",       "Offering Description": "<p>A set of chips that provides the interfaces between all of the PC&#39;s subsystems. It provides the buses and electronics to allow the CPU, memory and input/output devices to interact. Most Intel chipsets, which are contained on two to four chips, also include built-in EIDE support. In the past, Intel used the name &quot;Triton&quot; for its chipsets. It also used the name PCIset for PCI-based chipsets. Following is a brief summary of earlier Pentium chipsets.</p><p>975X - For dual core Extreme Edition and Pentium D CPUs. Includes Ethernet and HD Audio. Supports 1066 MHz FSB, 8GB dual channel DDR2 RAM, PCI Express and PCI Express x16 for external graphics.</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Japanese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Japanese",       "TranslatedTagline": "TranslatedTagline in Japanese"     },     {       "TargetLanguage": "zh-CN",       "TagLine": null,       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002HBzAAM",       "Offering Description": "<p>A set of chips that provides the interfaces between all of the PC&#39;s subsystems. It provides the buses and electronics to allow the CPU, memory and input/output devices to interact. Most Intel chipsets, which are contained on two to four chips, also include built-in EIDE support. In the past, Intel used the name &quot;Triton&quot; for its chipsets. It also used the name PCIset for PCI-based chipsets. Following is a brief summary of earlier Pentium chipsets.</p><p>975X - For dual core Extreme Edition and Pentium D CPUs. Includes Ethernet and HD Audio. Supports 1066 MHz FSB, 8GB dual channel DDR2 RAM, PCI Express and PCI Express x16 for external graphics.</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Chinese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Chinese",       "TranslatedTagline": "TranslatedTagline in Chinese"     }   ] }';
            
        
       //Outbound message for invoke failed
        Core_Integration_Outbound_Message__c oBMsg = new Core_Integration_Outbound_Message__c();
        oBMsg.Core_MessageType__c = 'Marketplace Translation';
        oBMsg.Core_Payload__c = 'outboundmsg';
        oBMsg.Core_Tags__c = 'Marketplace, Translation, offering';
        
        Insert oBMsg;
        
        Core_Integration_Inbound_Message__c inboundMessage=new Core_Integration_Inbound_Message__c();
        inboundMessage.Core_Source_System__c='GLS';
        inboundMessage.Core_Message_Type__c='Marketplace Translation';
        inboundMessage.Core_Payload__c=inboundPayload;
        inboundMessage.Core_Payload1__c='JA';
        inboundMessage.Core_Outbound_Message__c=oBMsg.Id;
        insert inboundMessage;
        
        Core_Integration_Inbound_Message__c inboundMessage2=new Core_Integration_Inbound_Message__c();
        inboundMessage2.Core_Source_System__c='GLS';
        inboundMessage2.Core_Message_Type__c='Marketplace Translation';
        inboundMessage2.Core_Payload__c=inboundPayload;
        inboundMessage2.Core_Payload1__c='en-US';
        insert inboundMessage2;
        
        Core_Integration_Inbound_Message__c inboundMessage3=new Core_Integration_Inbound_Message__c();
        inboundMessage3.Core_Source_System__c='GLS';
        inboundMessage3.Core_Message_Type__c='Marketplace Translation';
        inboundMessage3.Core_Payload__c=inboundPayload;
        inboundMessage3.Core_Payload1__c='zh-CN';
        insert inboundMessage3;
        
        system.assertEquals(inboundMessage3.Core_Message_Type__c,'Marketplace Translation','True');
        
         PMP_Locale_Inbound_Msg.targetLanguage='Japanese';
        Map<Id,Core_Integration_Inbound_Message__c> inboundMap=new Map<Id,Core_Integration_Inbound_Message__c>();        
        inboundMap.put(inboundMessage.Id, inboundMessage );
        PMP_Locale_Inbound_Msg.updateLocaleDetails(inboundMap);
        
         PMP_Locale_Inbound_Msg.targetLanguage='English';
        inboundMap=new Map<Id,Core_Integration_Inbound_Message__c>();      
        inboundMap.put(inboundMessage2.Id, inboundMessage2 );
        PMP_Locale_Inbound_Msg.updateLocaleDetails(inboundMap);
        
        PMP_Locale_Inbound_Msg.targetLanguage='Simplified Chinese';
        inboundMap=new Map<Id,Core_Integration_Inbound_Message__c>(); 
        inboundMap.put(inboundMessage3.Id, inboundMessage3);
        PMP_Locale_Inbound_Msg lim=new PMP_Locale_Inbound_Msg();
        PMP_Locale_Inbound_Msg.updateLocaleDetails(inboundMap);
        
        List<Core_Integration_Inbound_Message__c> failedMessages=new  List<Core_Integration_Inbound_Message__c>();
        failedMessages.add(inboundMessage);
        failedMessages.add(inboundMessage2);
        failedMessages.add(inboundMessage3);
        PMP_Locale_Inbound_Msg.rePublish(failedMessages);
        test.stopTest();
        
    }
    
       
     @isTest
    static void updateLocaleDetails_PublishedCopy(){
        test.startTest();
        
        //Create account
        Account testAccount = new Account();
        testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
        testAccount.Name = 'Test Account 19-Jun-19';       
        testAccount.Core_Account_Country__c='India';
        testAccount.Core_Sales_Group_New__c='US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        insert testAccount;
        
        //Create a company
         PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
                                                         PMP_Account_Id__c=testAccount.Id);
        insert testCompany;
        
        //Inserting partner record
        PMP_Partner_Offering__c partnerOffering=new PMP_Partner_Offering__c();
        partnerOffering.Name=String.valueOf(DateTime.now());
        partnerOffering.PMP_Offering_Language_Nm__c='English';
        partnerOffering.PMP_Partner_Offering_Nm__c = partnerOffering.Name;
        partnerOffering.PMP_Partner_Offering_Visibility_Nm__c='Public Content';
        partnerOffering.PMP_Partner_Offering_Dsc__c=String.valueOf(DateTime.now());
        partnerOffering.PMP_Partner_Offering_Tag_Line_Txt__c=String.valueOf(DateTime.now());
        partnerOffering.PMP_Company_Id__c=testCompany.Id;
        partnerOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Approved';
        partnerOffering.PMP_Translated_Languages__c='English';
        partnerOffering.PMP_Partner_Offering_Start_Dt__c=Date.today().addDays(-1);
        insert partnerOffering;
        */
        /*PMP_Partner_Offering__c ppo=[Select PMP_Partner_Offering_Lifecycle_Status_Nm__c from PMP_Partner_Offering__c where Id=:partnerOffering.Id limit 1];
        ppo.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Approved';
        update ppo;
      */
        // system.debug('partnerOffering::'+partnerOffering.Id);
        //Inserting partner record
        /*
        PMP_Partner_Offering__c partnerOffering2=new PMP_Partner_Offering__c();
        partnerOffering2.Name=String.valueOf(DateTime.now());
        partnerOffering2.PMP_Offering_Language_Nm__c='English';
        partnerOffering2.PMP_Partner_Offering_Nm__c =String.valueOf(DateTime.now());
        partnerOffering2.PMP_Partner_Offering_Visibility_Nm__c='Public Content';
        partnerOffering2.PMP_Partner_Offering_Dsc__c=String.valueOf(DateTime.now());
        partnerOffering2.PMP_Partner_Offering_Tag_Line_Txt__c=String.valueOf(DateTime.now());
        partnerOffering2.PMP_Company_Id__c=testCompany.Id;
        partnerOffering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
        partnerOffering2.PMP_Working_Copy_Id__c=partnerOffering.Id;
        partnerOffering2.PMP_Translated_Languages__c='English';
        insert partnerOffering2;
       // System.debug('partnerOffering2:'+partnerOffering2.Id);
       
            
            
        //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslation=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslation.Name=partnerOffering.Id+'PMP_Partner_Offering_Nm__c';
        partnerOfferingTranslation.PMP_Partner_Offering_Id__c=partnerOffering.Id;
        partnerOfferingTranslation.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        partnerOfferingTranslation.PMP_English_Txt__c=partnerOffering.Name;
        partnerOfferingTranslation.PMP_Chinese_Txt__c='';
        partnerOfferingTranslation.PMP_Japanese_Txt__c='';
        insert partnerOfferingTranslation;
        
           //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLine=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLine.Name=partnerOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLine.PMP_Partner_Offering_Id__c=partnerOffering.Id;
        partnerOfferingTranslationTagLine.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLine.PMP_English_Txt__c=partnerOffering.Name;
        partnerOfferingTranslationTagLine.PMP_Chinese_Txt__c='';
        partnerOfferingTranslationTagLine.PMP_Japanese_Txt__c='';
        insert partnerOfferingTranslationTagLine;
        
        
         //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLineChinese=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLineChinese.Name=partnerOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineChinese.PMP_Partner_Offering_Id__c=partnerOffering.Id;
        partnerOfferingTranslationTagLineChinese.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineChinese.PMP_English_Txt__c='';
        partnerOfferingTranslationTagLineChinese.PMP_Chinese_Txt__c=partnerOffering.Name;
        partnerOfferingTranslationTagLineChinese.PMP_Japanese_Txt__c='';
        insert partnerOfferingTranslationTagLineChinese;
        
         //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLineJapanese=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLineJapanese.Name=partnerOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineJapanese.PMP_Partner_Offering_Id__c=partnerOffering.Id;
        partnerOfferingTranslationTagLineJapanese.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineJapanese.PMP_English_Txt__c='';
        partnerOfferingTranslationTagLineJapanese.PMP_Chinese_Txt__c='';
        partnerOfferingTranslationTagLineJapanese.PMP_Japanese_Txt__c=partnerOffering.Name;
        insert partnerOfferingTranslationTagLineJapanese;

       

        */
        
         //Published copy
        //Inserting partner record
        /*PMP_Partner_Offering__c partnerOfferingP=new PMP_Partner_Offering__c();
        partnerOfferingP.Name=String.valueOf(DateTime.now());
        partnerOfferingP.PMP_Offering_Language_Nm__c='English';
        partnerOfferingP.PMP_Partner_Offering_Nm__c = partnerOffering.Name;
        partnerOfferingP.PMP_Partner_Offering_Visibility_Nm__c='Public Content';
        partnerOfferingP.PMP_Partner_Offering_Dsc__c=String.valueOf(DateTime.now());
        partnerOfferingP.PMP_Partner_Offering_Tag_Line_Txt__c=String.valueOf(DateTime.now());
        partnerOfferingP.PMP_Company_Id__c=testCompany.Id;
        partnerOfferingP.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Approved';
        partnerOfferingP.PMP_Translated_Languages__c='English';
        partnerOfferingP.PMP_Partner_Offering_Start_Dt__c=Date.today().addDays(-1);
        insert partnerOfferingP;*/
        
		/*
        //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationP=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationP.Name=partnerOffering.Id+'PMP_Partner_Offering_Nm__c';
        partnerOfferingTranslationP.PMP_Partner_Offering_Id__c=partnerOffering2.Id;
        partnerOfferingTranslationP.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        partnerOfferingTranslationP.PMP_English_Txt__c=partnerOffering.Name;
        partnerOfferingTranslationP.PMP_Chinese_Txt__c='';
        partnerOfferingTranslationP.PMP_Japanese_Txt__c='';
        insert partnerOfferingTranslationP;
        
           //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLineP=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLineP.Name=partnerOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineP.PMP_Partner_Offering_Id__c=partnerOffering2.Id;
        partnerOfferingTranslationTagLineP.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineP.PMP_English_Txt__c=partnerOffering.Name;
        partnerOfferingTranslationTagLineP.PMP_Chinese_Txt__c='';
        partnerOfferingTranslationTagLineP.PMP_Japanese_Txt__c='';
        insert partnerOfferingTranslationTagLineP;
        
        
         //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLineChineseP=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLineChineseP.Name=partnerOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineChineseP.PMP_Partner_Offering_Id__c=partnerOffering2.Id;
        partnerOfferingTranslationTagLineChineseP.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineChineseP.PMP_English_Txt__c='';
        partnerOfferingTranslationTagLineChineseP.PMP_Chinese_Txt__c=partnerOffering.Name;
        partnerOfferingTranslationTagLineChineseP.PMP_Japanese_Txt__c='';
        insert partnerOfferingTranslationTagLineChineseP;
        
         //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLineJapaneseP=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLineJapaneseP.Name=partnerOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineJapaneseP.PMP_Partner_Offering_Id__c=partnerOffering2.Id;
        partnerOfferingTranslationTagLineJapaneseP.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineJapaneseP.PMP_English_Txt__c='';
        partnerOfferingTranslationTagLineJapaneseP.PMP_Chinese_Txt__c='';
        partnerOfferingTranslationTagLineJapaneseP.PMP_Japanese_Txt__c=partnerOffering.Name;
        insert partnerOfferingTranslationTagLineJapaneseP;
        
        PMP_Product_API_Key__c apiKey=new PMP_Product_API_Key__c();
        apiKey.Name='API_Key';
        apiKey.PMP_API_KEY__c='efm9JpXElhgutg8t8HuHTYWc4tVvcvWk';
        insert apiKey;
        
        
         List<Id> offeringIds=new List<Id>();
        offeringIds.add(partnerOffering.Id);
        PMP_Locale_Inbound_Msg.publishTranslations(offeringIds,'Japanese');
        
		

        string inboundPayload='{   "Source Language": "en-US",   "Offerings": [          {       "TargetLanguage": "JA",       "TagLine": null,       "SentDate": "2019-08-02",       "OfferingName": null,       "OfferingId": "'+partnerOffering.Id+'",       "OfferingDescription": "<p>A set of chips that provides the interfaces between all of the PC&#39;s subsystems. It provides the buses and electronics to allow the CPU, memory and input/output devices to interact. Most Intel chipsets, which are contained on two to four chips, also include built-in EIDE support. In the past, Intel used the name &quot;Triton&quot; for its chipsets. It also used the name PCIset for PCI-based chipsets. Following is a brief summary of earlier Pentium chipsets.</p><p>975X - For dual core Extreme Edition and Pentium D CPUs. Includes Ethernet and HD Audio. Supports 1066 MHz FSB, 8GB dual channel DDR2 RAM, PCI Express and PCI Express x16 for external graphics.</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Japanese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Japanese",       "TranslatedTagline": "TranslatedTagline in Japanese"     },     {       "TargetLanguage": "zh-CN",       "TagLine": null,       "SentDate": "2019-08-02",       "OfferingName": null,       "OfferingId": "'+partnerOffering.Id+'",       "OfferingDescription": "<p>A set of chips that provides the interfaces between all of the PC&#39;s subsystems. It provides the buses and electronics to allow the CPU, memory and input/output devices to interact. Most Intel chipsets, which are contained on two to four chips, also include built-in EIDE support. In the past, Intel used the name &quot;Triton&quot; for its chipsets. It also used the name PCIset for PCI-based chipsets. Following is a brief summary of earlier Pentium chipsets.</p><p>975X - For dual core Extreme Edition and Pentium D CPUs. Includes Ethernet and HD Audio. Supports 1066 MHz FSB, 8GB dual channel DDR2 RAM, PCI Express and PCI Express x16 for external graphics.</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Chinese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Chinese",       "TranslatedTagline": "TranslatedTagline in Chinese"     }   ] }';
            
            //string inboundPayload='{   "Source Language": "en-US",   "Offerings": [     {       "Target Language": "JA",       "TagLine": "TNZintelonlyoffering002",       "SentDate": "2019-08-02",       "Offering Name": "null",       "OfferingId": "a3s0n0000002FLAAA2",       "Offering Description": "<p>TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Japanese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Japanese",       "TranslatedTagline": "TranslatedTagline in Japanese"     },     {       "Target Language": "zh-CN",       "TagLine": "TNZintelonlyoffering002",       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002FLAAA2",       "Offering Description": "<p>TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Chinese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Chinese",       "TranslatedTagline": "TranslatedTagline in Chinese"     },     {       "Target Language": "JA",       "TagLine": null,       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002ILHAA2",       "Offering Description": "<p>description</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Japanese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Japanese",       "TranslatedTagline": "TranslatedTagline in Japanese"     },     {       "Target Language": "zh-CN",       "TagLine": null,       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002ILHAA2",       "Offering Description": "<p>description</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Chinese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Chinese",       "TranslatedTagline": "TranslatedTagline in Chinese"     },     {       "Target Language": "JA",       "TagLine": null,       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002HBzAAM",       "Offering Description": "<p>A set of chips that provides the interfaces between all of the PC&#39;s subsystems. It provides the buses and electronics to allow the CPU, memory and input/output devices to interact. Most Intel chipsets, which are contained on two to four chips, also include built-in EIDE support. In the past, Intel used the name &quot;Triton&quot; for its chipsets. It also used the name PCIset for PCI-based chipsets. Following is a brief summary of earlier Pentium chipsets.</p><p>975X - For dual core Extreme Edition and Pentium D CPUs. Includes Ethernet and HD Audio. Supports 1066 MHz FSB, 8GB dual channel DDR2 RAM, PCI Express and PCI Express x16 for external graphics.</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Japanese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Japanese",       "TranslatedTagline": "TranslatedTagline in Japanese"     },     {       "TargetLanguage": "zh-CN",       "TagLine": null,       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002HBzAAM",       "Offering Description": "<p>A set of chips that provides the interfaces between all of the PC&#39;s subsystems. It provides the buses and electronics to allow the CPU, memory and input/output devices to interact. Most Intel chipsets, which are contained on two to four chips, also include built-in EIDE support. In the past, Intel used the name &quot;Triton&quot; for its chipsets. It also used the name PCIset for PCI-based chipsets. Following is a brief summary of earlier Pentium chipsets.</p><p>975X - For dual core Extreme Edition and Pentium D CPUs. Includes Ethernet and HD Audio. Supports 1066 MHz FSB, 8GB dual channel DDR2 RAM, PCI Express and PCI Express x16 for external graphics.</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Chinese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Chinese",       "TranslatedTagline": "TranslatedTagline in Chinese"     }   ] }';
            
        Core_Integration_Inbound_Message__c inboundMessage=new Core_Integration_Inbound_Message__c();
        inboundMessage.Core_Source_System__c='GLS';
        inboundMessage.Core_Message_Type__c='Marketplace Translation';
        inboundMessage.Core_Payload__c=inboundPayload;
        inboundMessage.Core_Payload1__c='Japanese';
        insert inboundMessage;
        
        Core_Integration_Inbound_Message__c inboundMessage2=new Core_Integration_Inbound_Message__c();
        inboundMessage2.Core_Source_System__c='GLS';
        inboundMessage2.Core_Message_Type__c='Marketplace Translation';
        inboundMessage2.Core_Payload__c=inboundPayload;
        inboundMessage2.Core_Payload1__c='English';
        insert inboundMessage2;
        
        Core_Integration_Inbound_Message__c inboundMessage3=new Core_Integration_Inbound_Message__c();
        inboundMessage3.Core_Source_System__c='GLS';
        inboundMessage3.Core_Message_Type__c='Marketplace Translation';
        inboundMessage3.Core_Payload__c=inboundPayload;
        inboundMessage3.Core_Payload1__c='Simplified Chinese';
        insert inboundMessage3;
        
        system.assertEquals(inboundMessage3.Core_Message_Type__c,'Marketplace Translation','True');
        List<PMP_Languages__mdt> meta=[Select Locale_Nm__c, Language_Code__c FROM PMP_Languages__mdt LIMIT 10];
         // system.debug('meta:1'+meta);
        PMP_Locale_Inbound_Msg.targetLanguage='Japanese';
        Map<Id,Core_Integration_Inbound_Message__c> inboundMap=new Map<Id,Core_Integration_Inbound_Message__c>();        
        inboundMap.put(inboundMessage.Id, inboundMessage );
        PMP_Locale_Inbound_Msg.updateLocaleDetails(inboundMap);
        
         PMP_Locale_Inbound_Msg.targetLanguage='English';
        inboundMap=new Map<Id,Core_Integration_Inbound_Message__c>();      
        inboundMap.put(inboundMessage2.Id, inboundMessage2 );
        PMP_Locale_Inbound_Msg.updateLocaleDetails(inboundMap);
        
        PMP_Locale_Inbound_Msg.targetLanguage='Simplified Chinese';
        inboundMap=new Map<Id,Core_Integration_Inbound_Message__c>(); 
        inboundMap.put(inboundMessage3.Id, inboundMessage3);
        PMP_Locale_Inbound_Msg lim=new PMP_Locale_Inbound_Msg();
        PMP_Locale_Inbound_Msg.updateLocaleDetails(inboundMap);
        
        test.stopTest();
        
    }
    
    
    @isTest
    static void updateLocaleDetailsEmptyInbound(){
        test.startTest();
        Map<Id,Core_Integration_Inbound_Message__c> inboundMap=new Map<Id,Core_Integration_Inbound_Message__c>(); 
        PMP_Locale_Inbound_Msg lim=new PMP_Locale_Inbound_Msg();
        PMP_Locale_Inbound_Msg.updateLocaleDetails(inboundMap);
        test.stopTest();
        system.assertEquals('1','1','True');
    }
    
    
    @isTest
    static void updateLocaleDetailsTargetLanguage(){
        test.startTest();
        //Create account
        Account testAccount = new Account();
        testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
        testAccount.Name = 'Test Account 19-Jun-19';       
        testAccount.Core_Account_Country__c='India';
        testAccount.Core_Sales_Group_New__c='US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        insert testAccount;
        
        //Create a company
         PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
                                                         PMP_Account_Id__c=testAccount.Id);
        insert testCompany;
        
        //Inserting partner record
        PMP_Partner_Offering__c partnerOffering=new PMP_Partner_Offering__c();
        partnerOffering.Name=String.valueOf(DateTime.now());
        partnerOffering.PMP_Offering_Language_Nm__c='Japanese';
        partnerOffering.PMP_Partner_Offering_Nm__c = partnerOffering.Name;
        partnerOffering.PMP_Partner_Offering_Visibility_Nm__c='Public Content';
        partnerOffering.PMP_Partner_Offering_Dsc__c=String.valueOf(DateTime.now());
        partnerOffering.PMP_Partner_Offering_Tag_Line_Txt__c=String.valueOf(DateTime.now());
        partnerOffering.PMP_Company_Id__c=testCompany.Id;
        partnerOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Approved';
        partnerOffering.PMP_Translated_Languages__c='English';
        partnerOffering.PMP_Partner_Offering_Start_Dt__c=Date.today().addDays(-1);
        insert partnerOffering;
        
      
     
            
            
        //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslation=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslation.Name=partnerOffering.Id+'PMP_Partner_Offering_Nm__c';
        partnerOfferingTranslation.PMP_Partner_Offering_Id__c=partnerOffering.Id;
        partnerOfferingTranslation.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        partnerOfferingTranslation.PMP_English_Txt__c=partnerOffering.Name;
        partnerOfferingTranslation.PMP_Chinese_Txt__c='';
        partnerOfferingTranslation.PMP_Japanese_Txt__c='';
        insert partnerOfferingTranslation;
        
           //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLine=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLine.Name=partnerOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLine.PMP_Partner_Offering_Id__c=partnerOffering.Id;
        partnerOfferingTranslationTagLine.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLine.PMP_English_Txt__c=partnerOffering.Name;
        partnerOfferingTranslationTagLine.PMP_Chinese_Txt__c='';
        partnerOfferingTranslationTagLine.PMP_Japanese_Txt__c='';
        insert partnerOfferingTranslationTagLine;
        
        
         //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLineChinese=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLineChinese.Name=partnerOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineChinese.PMP_Partner_Offering_Id__c=partnerOffering.Id;
        partnerOfferingTranslationTagLineChinese.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineChinese.PMP_English_Txt__c='';
        partnerOfferingTranslationTagLineChinese.PMP_Chinese_Txt__c=partnerOffering.Name;
        partnerOfferingTranslationTagLineChinese.PMP_Japanese_Txt__c='';
        insert partnerOfferingTranslationTagLineChinese;
        
         //partner offering 
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLineJapanese=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLineJapanese.Name=partnerOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineJapanese.PMP_Partner_Offering_Id__c=partnerOffering.Id;
        partnerOfferingTranslationTagLineJapanese.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLineJapanese.PMP_English_Txt__c='';
        partnerOfferingTranslationTagLineJapanese.PMP_Chinese_Txt__c='';
        partnerOfferingTranslationTagLineJapanese.PMP_Japanese_Txt__c=partnerOffering.Name;
        insert partnerOfferingTranslationTagLineJapanese;

       

       
        
        
        
        string inboundPayload='{   "Source Language": "en-US",   "Offerings": [          {       "TargetLanguage": "JA",       "TagLine": null,       "SentDate": "2019-08-02",       "OfferingName": null,       "OfferingId": "'+partnerOffering.Id+'",       "OfferingDescription": "<p>A set of chips that provides the interfaces between all of the PC&#39;s subsystems. It provides the buses and electronics to allow the CPU, memory and input/output devices to interact. Most Intel chipsets, which are contained on two to four chips, also include built-in EIDE support. In the past, Intel used the name &quot;Triton&quot; for its chipsets. It also used the name PCIset for PCI-based chipsets. Following is a brief summary of earlier Pentium chipsets.</p><p>975X - For dual core Extreme Edition and Pentium D CPUs. Includes Ethernet and HD Audio. Supports 1066 MHz FSB, 8GB dual channel DDR2 RAM, PCI Express and PCI Express x16 for external graphics.</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Japanese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Japanese",       "TranslatedTagline": "TranslatedTagline in Japanese"     },     {       "TargetLanguage": "zh-CN",       "TagLine": null,       "SentDate": "2019-08-02",       "OfferingName": null,       "OfferingId": "'+partnerOffering.Id+'",       "OfferingDescription": "<p>A set of chips that provides the interfaces between all of the PC&#39;s subsystems. It provides the buses and electronics to allow the CPU, memory and input/output devices to interact. Most Intel chipsets, which are contained on two to four chips, also include built-in EIDE support. In the past, Intel used the name &quot;Triton&quot; for its chipsets. It also used the name PCIset for PCI-based chipsets. Following is a brief summary of earlier Pentium chipsets.</p><p>975X - For dual core Extreme Edition and Pentium D CPUs. Includes Ethernet and HD Audio. Supports 1066 MHz FSB, 8GB dual channel DDR2 RAM, PCI Express and PCI Express x16 for external graphics.</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Chinese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Chinese",       "TranslatedTagline": "TranslatedTagline in Chinese"     }   ] }';
            
            //string inboundPayload='{   "Source Language": "en-US",   "Offerings": [     {       "Target Language": "JA",       "TagLine": "TNZintelonlyoffering002",       "SentDate": "2019-08-02",       "Offering Name": "null",       "OfferingId": "a3s0n0000002FLAAA2",       "Offering Description": "<p>TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Japanese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Japanese",       "TranslatedTagline": "TranslatedTagline in Japanese"     },     {       "Target Language": "zh-CN",       "TagLine": "TNZintelonlyoffering002",       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002FLAAA2",       "Offering Description": "<p>TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002TNZintelonlyoffering002</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Chinese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Chinese",       "TranslatedTagline": "TranslatedTagline in Chinese"     },     {       "Target Language": "JA",       "TagLine": null,       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002ILHAA2",       "Offering Description": "<p>description</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Japanese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Japanese",       "TranslatedTagline": "TranslatedTagline in Japanese"     },     {       "Target Language": "zh-CN",       "TagLine": null,       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002ILHAA2",       "Offering Description": "<p>description</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Chinese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Chinese",       "TranslatedTagline": "TranslatedTagline in Chinese"     },     {       "Target Language": "JA",       "TagLine": null,       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002HBzAAM",       "Offering Description": "<p>A set of chips that provides the interfaces between all of the PC&#39;s subsystems. It provides the buses and electronics to allow the CPU, memory and input/output devices to interact. Most Intel chipsets, which are contained on two to four chips, also include built-in EIDE support. In the past, Intel used the name &quot;Triton&quot; for its chipsets. It also used the name PCIset for PCI-based chipsets. Following is a brief summary of earlier Pentium chipsets.</p><p>975X - For dual core Extreme Edition and Pentium D CPUs. Includes Ethernet and HD Audio. Supports 1066 MHz FSB, 8GB dual channel DDR2 RAM, PCI Express and PCI Express x16 for external graphics.</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Japanese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Japanese",       "TranslatedTagline": "TranslatedTagline in Japanese"     },     {       "TargetLanguage": "zh-CN",       "TagLine": null,       "SentDate": "2019-08-02",       "Offering Name": null,       "Offering Id": "a3s0n0000002HBzAAM",       "Offering Description": "<p>A set of chips that provides the interfaces between all of the PC&#39;s subsystems. It provides the buses and electronics to allow the CPU, memory and input/output devices to interact. Most Intel chipsets, which are contained on two to four chips, also include built-in EIDE support. In the past, Intel used the name &quot;Triton&quot; for its chipsets. It also used the name PCIset for PCI-based chipsets. Following is a brief summary of earlier Pentium chipsets.</p><p>975X - For dual core Extreme Edition and Pentium D CPUs. Includes Ethernet and HD Audio. Supports 1066 MHz FSB, 8GB dual channel DDR2 RAM, PCI Express and PCI Express x16 for external graphics.</p>",       "TranslatedOfferingName": "TranslatedOfferingName in Chinese",       "TranslatedOfferingDescription": "TranslatedOfferingDescription in Chinese",       "TranslatedTagline": "TranslatedTagline in Chinese"     }   ] }';
            
        
       //Outbound message for invoke failed
        Core_Integration_Outbound_Message__c oBMsg = new Core_Integration_Outbound_Message__c();
        oBMsg.Core_MessageType__c = 'Marketplace Translation';
        oBMsg.Core_Payload__c = 'outboundmsg';
        oBMsg.Core_Tags__c = 'Marketplace, Translation, offering';
        
        Insert oBMsg;
        
        Core_Integration_Inbound_Message__c inboundMessage=new Core_Integration_Inbound_Message__c();
        inboundMessage.Core_Source_System__c='GLS';
        inboundMessage.Core_Message_Type__c='Marketplace Translation';
        inboundMessage.Core_Payload__c=inboundPayload;
        inboundMessage.Core_Payload1__c='JA';
        inboundMessage.Core_Outbound_Message__c=oBMsg.Id;
        insert inboundMessage;
        
        Core_Integration_Inbound_Message__c inboundMessage2=new Core_Integration_Inbound_Message__c();
        inboundMessage2.Core_Source_System__c='GLS';
        inboundMessage2.Core_Message_Type__c='Marketplace Translation';
        inboundMessage2.Core_Payload__c=inboundPayload;
        inboundMessage2.Core_Payload1__c='en-US';
        insert inboundMessage2;
        
        Core_Integration_Inbound_Message__c inboundMessage3=new Core_Integration_Inbound_Message__c();
        inboundMessage3.Core_Source_System__c='GLS';
        inboundMessage3.Core_Message_Type__c='Marketplace Translation';
        inboundMessage3.Core_Payload__c=inboundPayload;
        inboundMessage3.Core_Payload1__c='zh-CN';
        insert inboundMessage3;
        
        system.assertEquals(inboundMessage3.Core_Message_Type__c,'Marketplace Translation','True');
        // system.debug(inboundMessage.Core_Payload__c);
         PMP_Locale_Inbound_Msg.targetLanguage='Japanese';
        Map<Id,Core_Integration_Inbound_Message__c> inboundMap=new Map<Id,Core_Integration_Inbound_Message__c>();        
        inboundMap.put(inboundMessage.Id, inboundMessage );
        PMP_Locale_Inbound_Msg.updateLocaleDetails(inboundMap);
        
         PMP_Locale_Inbound_Msg.targetLanguage='English';
        inboundMap=new Map<Id,Core_Integration_Inbound_Message__c>();      
        inboundMap.put(inboundMessage2.Id, inboundMessage2 );
        PMP_Locale_Inbound_Msg.updateLocaleDetails(inboundMap);
        
        PMP_Locale_Inbound_Msg.targetLanguage='Simplified Chinese';
        inboundMap=new Map<Id,Core_Integration_Inbound_Message__c>(); 
        inboundMap.put(inboundMessage3.Id, inboundMessage3);
        PMP_Locale_Inbound_Msg lim=new PMP_Locale_Inbound_Msg();
        PMP_Locale_Inbound_Msg.updateLocaleDetails(inboundMap);
        
        List<Core_Integration_Inbound_Message__c> failedMessages=new  List<Core_Integration_Inbound_Message__c>();
        failedMessages.add(inboundMessage);
        failedMessages.add(inboundMessage2);
        failedMessages.add(inboundMessage3);
        PMP_Locale_Inbound_Msg.rePublish(failedMessages);
        test.stopTest();
        
    }
*/
}