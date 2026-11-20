@isTest
public with sharing class MarketplaceTopicsImageUploaderTest {    
        @isTest
        static void testdeleteImage(){
          
           Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
            
           Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
           
           PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
                                    
        //    PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
        //                                                                              'TestDuplicate',cmp1.Id, true,'Draft','');
                                                                                 
           List<contentDocument> contentDocuments=PMP_TestDataUtility.createContentDocument(true);
           
           if(!contentDocuments.isEmpty()){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDocuments[0].Id;
                cdl.LinkedEntityId = cmp1.Id;
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers'; 
                insert cdl;
                system.assertNotEquals('',MarketplaceTopicsImageUploader.getImages(cmp1.Id));
           }
           test.startTest();
           //system.assertEquals(true,MarketplaceTopicsImageUploader.deleteImage(contentDocuments[0].Id, offering1.Id));
            test.stopTest();
        }
        
        @isTest
        static void testgetContentDocument(){
            test.startTest();
            List<contentDocument> contentDocuments=PMP_TestDataUtility.createContentDocument(true);
            system.assertNotEquals(null,MarketplaceTopicsImageUploader.getContentDocument(contentDocuments[0].Id));
            test.stopTest();
        }
        
        @isTest static void updateBannerMapping_Test(){
            list<Topic> listTopics = new List<Topic>();                                                                                 
            Topic topic = new Topic(Name='My Random Test Topic1');
            listTopics.add(topic);
                  
        
        PMP_Marketplace_Topic__c event = new PMP_Marketplace_Topic__c();
        event.PMP_Topic_Id__c = listTopics[0].Id;
        event.PMP_Is_Active_Ind__c = true;
        event.PMP_Marketplace_Topic_Name__c = listTopics[0].Name;
        event.PMP_Topic_Chinese_Nm__c ='chinese title';
        event.PMP_Topic_Japanese_Nm__c ='japanese title';
        event.PMP_Topic_English_Dsc__c = 'English Desc';
        event.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
        event.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

       

        
            insert event;
            
            ContentDocument doc = PMP_SearchTestDataFactory.createContentDocument(true)[0];
            ContentAsset ca= new ContentAsset();
            ca.DeveloperName = 'en_US' + doc.Id;
            ca.MasterLabel = 'en_US'  + doc.Id;
            ca.isVisibleByExternalUsers = TRUE;
            ca.language = 'en_US';
            insert ca;
            doc.ContentAssetId = ca.Id;
            update doc;
            
            event.PMP_Event_Banner_Language_Mapping__c= JSON.serialize(new Map<String,String>{'en_US'=>ca.DeveloperName});
            update event; 
            
            
            ContentDocument doc1 = PMP_SearchTestDataFactory.createContentDocument(true)[0];
            
            Test.startTest();
            //MarketplaceTopicsImageUploader.updateBannerMapping(event.Id,'English',doc1.Id);
            
            Test.stopTest();
            
            //ContentAsset ca1 = [SELECT DeveloperName FROM ContentAsset WHERE ContentDocumentId =: doc1.Id LIMIT 1];
            event = [SELECT PMP_Event_Banner_Language_Mapping__c FROM PMP_Marketplace_Topic__c WHERE id =: event.Id];
            //system.assertEquals(((Map<String,String>)JSON.deserialize(event.PMP_Event_Banner_Language_Mapping__c,Map<String,String>.class)).get('en_US'), ca1.DeveloperName);
        }
        
        @isTest static void deleteBannerMapping_Test(){
            list<Topic> listTopics = new List<Topic>();                                                                                 
            Topic topic = new Topic(Name='My Random Test Topic1');
            listTopics.add(topic);
                  
        
        PMP_Marketplace_Topic__c event = new PMP_Marketplace_Topic__c();
        event.PMP_Topic_Id__c = listTopics[0].Id;
        event.PMP_Is_Active_Ind__c = true;
        event.PMP_Marketplace_Topic_Name__c = listTopics[0].Name;
        event.PMP_Topic_Chinese_Nm__c ='chinese title';
        event.PMP_Topic_Japanese_Nm__c ='japanese title';
        event.PMP_Topic_English_Dsc__c = 'English Desc';
        event.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
        event.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

       

        
            insert event;
    
            ContentDocument doc = PMP_SearchTestDataFactory.createContentDocument(true)[0];
            ContentAsset ca= new ContentAsset();
            ca.DeveloperName = 'en_US' + doc.Id;
            ca.MasterLabel = 'en_US'  + doc.Id;
            ca.isVisibleByExternalUsers = TRUE;
            ca.language = 'en_US';
            insert ca;
            doc.ContentAssetId = ca.Id;
            update doc;
            
            event.PMP_Event_Banner_Language_Mapping__c= JSON.serialize(new Map<String,String>{'en_US'=>ca.DeveloperName});
            update event; 
            
            Test.startTest();
            //MarketplaceTopicsImageUploader.deleteBannerMapping(event.Id,doc.Id);
            Test.stopTest();
            
            event = [SELECT PMP_Event_Banner_Language_Mapping__c FROM PMP_Marketplace_Topic__c WHERE id =: event.Id];
            //system.assertEquals(((Map<String,String>)JSON.deserialize(event.PMP_Event_Banner_Language_Mapping__c,Map<String,String>.class)).get('en_US'),NULL);
        }
        
        @isTest
        static void test_updateContDocOwnerInfo(){
            test.startTest();
            Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
            
            Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
            
            PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
            
            List<contentDocument> contentDocuments=PMP_TestDataUtility.createContentDocument(true);  
                    
            if(!contentDocuments.isEmpty()){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDocuments[0].Id;
                cdl.LinkedEntityId = cmp1.Id;
                cdl.ShareType = 'I';
                cdl.Visibility = 'InternalUsers'; 
                insert cdl;
            }
            test.stopTest();
            system.assertEquals(true,MarketplaceTopicsImageUploader.updateContDocOwnerInfo(cmp1.Id));
        }
        @isTest
        static void testValidate(){
          test.startTest();
           Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
           Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
           PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        //    PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
        //                                                                              'TestDuplicate',cmp1.Id, true,'Draft','');
           List<contentDocument> contentDocuments=PMP_TestDataUtility.createContentDocument(true);
           if(!contentDocuments.isEmpty()){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDocuments[0].Id;
                cdl.LinkedEntityId = cmp1.Id;
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers'; 
                insert cdl;
                system.assertNotEquals('',MarketplaceTopicsImageUploader.getImages(cmp1.Id));
           }
        //    PMP_Partner_Offering_Resource__c offeringResourceVideo = PMP_TestDataUtility.createOfferingResourceInstance('res2','www.intel.com',offering1.Id,'Video','');
            
        //  MarketplaceTopicsImageUploader.ValidationWrapper vw = MarketplaceTopicsImageUploader.validateVideo(offering1.Id, contentDocuments[0].Id);
         MarketplaceTopicsImageUploader.ValidationWrapper vw = MarketplaceTopicsImageUploader.validateVideo( contentDocuments[0].Id);
           //system.assertEquals(true,);
        }
    }