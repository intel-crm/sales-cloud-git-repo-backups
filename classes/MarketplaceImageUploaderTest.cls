/****************************************************************************************************************************************
* Class Name  : MarketplaceImageUploaderTest 
* Version     : 1.0 
* Created Date: 06-04-2019 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team                          06-04-2019                    Test class of MarketplaceImageUploader apex class
*****************************************************************************************************************************************/
@isTest
public class MarketplaceImageUploaderTest {
    
    @isTest
    static void testdeleteImage(){
       
       Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
       Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
       
       PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
                                
       PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Draft','');
                                                                             
       List<contentDocument> contentDocuments=PMP_TestDataUtility.createContentDocument(true);
       
       if(!contentDocuments.isEmpty()){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contentDocuments[0].Id;
            cdl.LinkedEntityId = offering1.Id;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            
            system.assertNotEquals('',MarketplaceImageUploader.getImages(offering1.Id));
       }
       
       
       
       system.assertEquals(true,MarketplaceImageUploader.deleteImage(contentDocuments[0].Id));
    }
    
    @isTest
    static void testgetContentDocument(){
        List<contentDocument> contentDocuments=PMP_TestDataUtility.createContentDocument(true);
        system.assertNotEquals(null,MarketplaceImageUploader.getContentDocument(contentDocuments[0].Id));
    }
    
    @isTest static void updateBannerMapping_Test(){
        PMP_Marketplace_Event__c event = new PMP_Marketplace_Event__c(Name='Test Event',PMP_Event_Banner_Language__c='English',
                                                                      
                                                                     PMP_Marketplace_Event_Tagline__c='tag',PMP_Marketplace_Event_Start_Dt__c=System.today(),
                                                                     PMP_Marketplace_Event_End_Dt__c=SYSTEM.today());
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
        MarketplaceImageUploader.updateBannerMapping(event.Id,'English',doc1.Id);
        
        Test.stopTest();
        
        ContentAsset ca1 = [SELECT DeveloperName FROM ContentAsset WHERE ContentDocumentId =: doc1.Id LIMIT 1];
        event = [SELECT PMP_Event_Banner_Language_Mapping__c FROM PMP_Marketplace_Event__c WHERE id =: event.Id];
        system.assertEquals(((Map<String,String>)JSON.deserialize(event.PMP_Event_Banner_Language_Mapping__c,Map<String,String>.class)).get('en_US'), ca1.DeveloperName);
    }
    
    @isTest static void deleteBannerMapping_Test(){
        PMP_Marketplace_Event__c event = new PMP_Marketplace_Event__c(Name='Test Event',PMP_Event_Banner_Language__c='English',
                                                                      PMP_Event_Banner_Language_Mapping__c=JSON.serialize(new Map<String,String>{'zh_CN'=>'Test'}),
                                                                     PMP_Marketplace_Event_Tagline__c='tag',PMP_Marketplace_Event_Start_Dt__c=System.today(),
                                                                     PMP_Marketplace_Event_End_Dt__c=SYSTEM.today());
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
        MarketplaceImageUploader.deleteBannerMapping(event.Id,doc.Id);
        Test.stopTest();
        
        event = [SELECT PMP_Event_Banner_Language_Mapping__c FROM PMP_Marketplace_Event__c WHERE id =: event.Id];
        system.assertEquals(((Map<String,String>)JSON.deserialize(event.PMP_Event_Banner_Language_Mapping__c,Map<String,String>.class)).get('en_US'),NULL);
    }
}