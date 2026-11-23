/****************************************************************************************************************************************
* Class Name  : PMP_OfferingDetailsController_Test
* Version     : 1.0 
* Created Date: 11-22-2018
* Modification Log :
*
* Developer      Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team     11/22/2018                    Test class of Core_PMP_CreateOfferingsTest
*****************************************************************************************************************************************/

@isTest
public class PMP_OfferingDetailsController_Test {

   @testSetup static void setup() {
        // Create common test accounts
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        acc1.Core_Sales_Group__c = 'Global Accounts';
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
       
       Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
       Account acc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
       acc2.Core_Sales_Group__c = 'Global Accounts';
       
       
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
                                
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Draft','');
       
        PMP_Partner_Offering_Category__c offCategory = PMP_TestDataUtility.getPMPOfferingCategory(offering1.id);
        
        PMP_Partner_Offering_Specification__c offSpecs = PMP_TestDataUtility.getPMPOfferingSpecification(offering1.id);
        
        PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Draft','');
                                                                                 
        PMP_Partner_Offering_Category__c offCategory2 = PMP_TestDataUtility.getPMPOfferingCategory(offering2.id);
        
        PMP_Partner_Offering_Specification__c offSpecs2 = PMP_TestDataUtility.getPMPOfferingSpecification(offering2.id);
        
        List<PMP_Partner_Offering_Translation__c> translationList = new List<PMP_Partner_Offering_Translation__c>();
        
        PMP_Partner_Offering_Translation__c offTranslation = PMP_TestDataUtility.createOfferingTranslation(offering1.id,'testTranslation');
        if(offTranslation!=null){
           offTranslation.PMP_English_Txt__c = 'Test';
           offTranslation.PMP_Chinese_Txt__c = 'Test';
           offTranslation.PMP_Japanese_Txt__c = 'Test';
           offTranslation.PMP_Field_Nm__c = 'PMP_Partner_Offering_Nm__c';
           translationList.add(offTranslation);
        }
        
        PMP_Partner_Offering_Translation__c offTranslation2 = PMP_TestDataUtility.createOfferingTranslation(offering1.id,'testTranslation');
        if(offTranslation2!=null){
           offTranslation2.PMP_English_Txt__c = 'Test';
           offTranslation2.PMP_Chinese_Txt__c = 'Test';
           offTranslation2.PMP_Japanese_Txt__c = 'Test';
           offTranslation2.PMP_Field_Nm__c = 'PMP_Partner_Offering_Dsc__c';
           translationList.add(offTranslation2);
        }
        
        PMP_Partner_Offering_Translation__c offTranslation3 = PMP_TestDataUtility.createOfferingTranslation(offering1.id,'testTranslation');
        if(offTranslation3!=null){
           offTranslation3.PMP_English_Txt__c = 'Test';
           offTranslation3.PMP_Chinese_Txt__c = 'Test';
           offTranslation3.PMP_Japanese_Txt__c = 'Test';
           offTranslation3.PMP_Field_Nm__c = 'PMP_Partner_Offering_Tag_Line_Txt__c';
           translationList.add(offTranslation3);
        }
        
        if(!translationList.isEmpty()){
            insert translationList;
        }
        
        //Gireesh
        PMP_OfferingDetailsController.offeringSpecValueMap off=new PMP_OfferingDetailsController.offeringSpecValueMap();
       off.masterCategory='';
       off.valueList=new List<string>();

        
    }
    
    @isTest
    public static void fetchOfferingDetailTest(){
            PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
            insert apiKey;
        Account acc1 = [select id from Account where Name=:'TestAccount1'];
        Account acc2 = [select id from Account where Name=:'TestPartnerAccount1'];
                    
            PMP_Company__c cmp1 = [select id from PMP_Company__c where Name=:'TestCompany1']; 
                                    
            PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
            
            PMP_Partner_Offering__c offering2 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
            
            PMP_Partner_Offering_Category__c offCategory = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering1.Id];
            
            PMP_Partner_Offering_Specification__c offSpecs = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering1.Id];
            
            list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
            
            PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
            
            List<PMP_Partner_Offering_Translation__c> offTrans = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =:offering1.Id];
            
            
      
            offering1.PMP_Working_Copy_Id__c = offering2.id;
            update offering1;
            
            Core_Account_Group_Member__c pagMem = new Core_Account_Group_Member__c();
            //Added by Gireesh
            pagMem.Core_Partner_Account_Id__c = acc2.Id;
            pagMem.Core_Intel_Account_Id__c = acc1.Id;
            insert pagMem;
            
            Test.startTest();
            
        string offerings = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'en_US','en_US',true);
        string offeringsChinese = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'zh_CN','en_US',true);
        string offeringsJapanese = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'ja_JP','en_US',true);
           // string offeringsNoLang = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null,'en_US');
            //string offeringsNoLang = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null);
            System.assertNotEquals(offerings,'');
            
            List<Id> offeringIds = new List<Id>();
            offeringIds.add(offering1.Id);
            
            map<String,String> fetchOfferingDetailsMap = PMP_OfferingDetailsController.fetchOfferingDetails(offeringIds,false,false,false);
            Test.stopTest();
                    
        }
        
        @isTest
    public static void cloneOfferingTest(){
            PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
            insert apiKey;
        Account acc1 = [select id from Account where Name=:'TestAccount1'];
        Account acc2 = [select id from Account where Name=:'TestPartnerAccount1'];
                    
            PMP_Company__c cmp1 = [select id from PMP_Company__c where Name=:'TestCompany1']; 
                                    
            PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
            
            PMP_Partner_Offering__c offering2 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
            
            PMP_Partner_Offering_Category__c offCategory = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering1.Id];
            
            PMP_Partner_Offering_Specification__c offSpecs = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering1.Id];
            
            list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
            
            PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
            
            PMP_Partner_Offering_Resource__c getResources1 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering2.id);
            
            List<PMP_Partner_Offering_Translation__c> offTrans = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =:offering1.Id];
            
            
      
            offering1.PMP_Working_Copy_Id__c = offering2.id;
            update offering1;
            
           /* Core_Account_Group_Member__c pagMem = new Core_Account_Group_Member__c();
            //Added by Gireesh
            pagMem.Core_Partner_Account_Id__c = acc2.Id;
            pagMem.Core_Intel_Account_Id__c = acc1.Id;
            insert pagMem;*/
            
            Test.startTest();

            PMP_OfferingDetailsController.cloneOfferingDetail(offering2.Id,'en_US');
            
            offering1.PMP_Partner_Offering_Nm__c = 'Test record for having length greater than 255 as we need to cover a block in test class. Adding random paragraph, Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text';
            update offering1;
            
            PMP_OfferingDetailsController.cloneOfferingDetail(offering2.Id,'en_US');
            
            Test.stopTest();
                    
        }
        
     @isTest static void testFetchOfferingDetailNotPreview(){
        PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
        list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
        PMP_Partner_Offering_Resource__c resource1 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        resource1.PMP_Resource_Type_Nm__c = 'Thumbnail Image';
        update resource1;    
        PMP_Partner_Offering_Resource__c resource2 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        Test.startTest();
        string response=PMP_OfferingDetailsController.fetchOfferingDetailNotPreview(offering1.Id, true, true, false,'en_US','en_US',true);
        Test.stopTest();
    }
    
 @isTest static void testGetOfferingDetail(){
     PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
        list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
        PMP_Partner_Offering_Resource__c resource1 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        resource1.PMP_Resource_Type_Nm__c = 'Thumbnail Image';
        update resource1;    
        PMP_Partner_Offering_Resource__c resource2 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
     Test.startTest();
        String response=PMP_OfferingDetailsController.getOfferingDetail(offering1.Id, true, true, false,'en_US','en_US',true);
     String response1=PMP_OfferingDetailsController.getOfferingDetail(offering1.Id, true, true, false,'en_US','en_US',false);
        Test.stopTest();
 }
    @isTest Static void testPlatformCache(){
        PMP_Partner_Offering__c offeringCache = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Intel® Solutions Marketplace Profile'].Id;
      //  PMP_StaticConstants_Offering.guestProfiles = new String[]{'Intel® Solutions Marketplace Profile'};					
     	User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason1@gmail.com',
                           Username = 'testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                           ProfileId = profileId, 
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           ); 
        
      //  User usr = [select ProfileId from User where ProfileId=:profileId LIMIT 1];
        insert usr;
        System.runAs(usr){
        //System.debug('Current User-'+userInfo.getUserId());
        	Test.startTest();
        	
         	String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
        	Boolean isPreview = true;
        	
            string key = offeringCache.id+'enUS';
        	String cacheFlag = PMP_Utility.getValue('Cache_Flag');
               
        	Cache.Org.put(partitionInput+'.'+key, 'TestString',86400);
        	Cache.Org.put(partitionInput+'.'+offeringCache.id+'ja', 'TestString',86400);
        	Cache.Org.contains(partitionInput+'.'+ key); 
        	System.assertEquals(Cache.Org.contains(partitionInput+'.'+ key),true);
            PMP_OfferingDetailsController.fetchOfferingDetail(offeringCache.Id,false,true,false,'en_US','en_US',false);
            PMP_OfferingDetailsController.fetchOfferingDetail(offeringCache.Id,false,true,false,'en_US','en_US',true);
            Test.stopTest();
        
        }
        	
    }
}