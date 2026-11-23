/****************************************************************************************************************************************
* Class Name  : PMP_OfferingTriggerHelper_Test
* Version     : 1.0 
* Created Date: 08-06-2019
* Modification Log :
*
* Developer              Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shahrukh              07/23/2019                   Test class of PMP_OfferingTriggerHelper
  Yashasvi Aggarwal     10/11/2021                   Test class of PMP_OfferingTriggerHelper
*****************************************************************************************************************************************/

@isTest
public class PMP_OfferingTriggerHelper_Test{

//    @testSetup static void setup() {
//         // Create common test accounts
        
//         Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
//         Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
       
//         User u1=PMP_TestDataUtility.createUser(true);
       
//        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c();
//         cs.Name ='PMP_OPID_MPI_OfferingSharing_Handler';
//         cs.Core_Active__c = true;
//         cs.Core_Class_Name__c ='PMP_OfferingTriggerHandler';
//         cs.Core_Description__c ='Switch used for toggling partner offering sharing from OPID MPI Relationship object and Partner offering';
//         cs.Core_Object__c = 'PMP_offering_sharing';
//         cs.Core_Trigger_Events__c ='after update, after insert';
//         insert cs;

       
//         PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
//         PMP_Company__c cmp2 = PMP_TestDataUtility.createCompanyInformation('TestCompany2', acc1.Id, true);
                                
//         PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
//                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
//         PMP_Partner_Offering_Category__c offCategory = PMP_TestDataUtility.getPMPOfferingCategory(offering1.id);
        
//         PMP_Partner_Offering_Specification__c offSpecs = PMP_TestDataUtility.getPMPOfferingSpecification(offering1.id);
        
//         PMP_Partner_Offering_Translation__c offTranslation = PMP_TestDataUtility.createOfferingTranslation(offering1.id,'testTranslation');
//         if(offTranslation!=null){
//            insert offTranslation ;
//         }
        
//         PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Intel Only Content', 
//                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
//         PMP_Partner_Offering__c offering3 = PMP_TestDataUtility.createOffering('TestDuplicateOffering3','Public Content', 
//                                                                                  'TestDuplicate',cmp1.Id, true,'Draft',''); 
//         PMP_Partner_Offering__c offering4 = PMP_TestDataUtility.createOffering('TestDuplicateOffering4','Public Content', 
//                                                                                  'TestDuplicate',cmp1.Id, true,'Draft',''); 
//         PMP_Partner_Offering_Category__c offCategory2 = PMP_TestDataUtility.getPMPOfferingCategory(offering2.id);
        
//         PMP_Partner_Offering_Specification__c offSpecs2 = PMP_TestDataUtility.getPMPOfferingSpecification(offering2.id);
        
//          document document = new Document();
//         document.Body = Blob.valueOf('Some Text');
//         document.ContentType = 'application/pdf';
//         document.DeveloperName = 'my_document';
//         document.IsPublic = true;
//         document.Name = 'IntelLogo';
//         document.FolderId = [select id from folder where name = 'PMP_Marketplace_Images'].id;
//         insert document;
        
//         document document1 = new Document();
//         document1.Body = Blob.valueOf('Some Text');
//         document1.ContentType = 'application/pdf';
//         document1.DeveloperName = 'my_document1';
//         document1.IsPublic = true;
//         document1.Name = 'Marketplace Offering Submitted';
//         document1.FolderId = document.FolderId;
//         insert document1;
        
        
//     }
    
//     @isTest
//     public static void fetchOfferingDetailTest(){
//             PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
//             insert apiKey;
//             Account acc1 = [select id from Account where Name=:'TestAccount1'];
                    
//             PMP_Company__c cmp1 = [select id from PMP_Company__c where Name=:'TestCompany1']; 
//             PMP_Company__c cmp2 = [select id from PMP_Company__c where Name=:'TestCompany2'];
        
//             PMP_Partner_Offering__c offering1 = [select id,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c,LastModifiedById  from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
            
//             PMP_Partner_Offering__c offering2 = [select id,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c,LastModifiedById  from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
            
//             PMP_Partner_Offering_Category__c offCategory = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering1.Id];
            
//             PMP_Partner_Offering_Specification__c offSpecs = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering1.Id];
//             PMP_Partner_Offering_Specification__c offSpecs2 = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering2.Id];
                        
//             PMP_Partner_Offering_Translation__c offTrans = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =:offering1.Id];
            
//             list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
            
//             PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
//             offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
//             offering1.PMP_Partner_Offering_Start_Dt__c = system.today();
//             offering1.PMP_Partner_Offering_Nm__c = 'Test';
//             offering1.PMP_Featured_Offering_Ind__c = true;
//         	offering1.PMP_Company_Id__c = cmp2.Id;
//             Test.startTest();
//             update offering1;
            
            
//             List<PMP_Partner_Offering__c> publishedOfferings = [select id,PMP_Working_Copy_Id__c,PMP_Featured_Offering_Ind__c from PMP_Partner_Offering__c where PMP_Working_Copy_Id__c=:offering1.Id];
//             System.assertNotEquals(publishedOfferings,null);
            
//             if(publishedOfferings.size()>0){
//                 System.assertEquals(publishedOfferings[0].PMP_Featured_Offering_Ind__c,offering1.PMP_Featured_Offering_Ind__c);
//             }
//             offering1.PMP_Working_Copy_Id__c = offering2.Id;
//             offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Admin Review';
//             update offering1;
            
//             offSpecs.PMP_Is_Pre_Release_Item_Ind__c = false;
//             update offSpecs;
        
//             offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
//             offering1.PMP_Is_Published_Ind__c = false;
//             offering1.PMP_Pre_Release_Check_Nm__c ='No';
//             //offering1.PMP_Pre_Release_Item_Count_Num__c = PMP_StaticConstants_MasterData.Zero;
//             update offering1;
            
//             offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
//             offering2.PMP_Is_Published_Ind__c = true;
//             offering2.PMP_Working_Copy_Id__c = offering1.Id;
//             update offering2;
//             offering2.PMP_Partner_Offering_Nm__c = 'Test Published';
            
//             //update offering2;
//             offering1.PMP_Partner_Offering_Visibility_Nm__c = 'Intel Only Content';
//             offering1.PMP_Is_Published_Ind__c = true;
//             update offering1;
            
//             list<PMP_Partner_Offering__c> offlist = new list<PMP_Partner_Offering__c>();
//             offlist.add(offering1);
            
//             PMP_OfferingTriggerHelper.updateOfferings(offlist);
            
//             Test.stopTest();
                    
//         }
        
//     //method to test the clearPlatformCache method
//     @isTest
//     public static void clearPlatformCacheTest(){
//         Set<Id> offeringIds= new Set<Id>();
      
//         List<PMP_Partner_Offering__c> offeringList = [select id,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c  from PMP_Partner_Offering__c LIMIT 10];
//         offeringList[0].PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
//         update offeringList;
//         PMP_Marketplace_Event__c eve=new PMP_Marketplace_Event__c();
//         eve.Name='Test Event';
//         eve.PMP_Marketplace_Event_Start_Dt__c=System.Now()-1;
//         eve.PMP_Marketplace_Event_End_Dt__c=System.Now()+1;
//         eve.PMP_Marketplace_Event_Tagline__c = 'tagline';
//         eve.PMP_Marketplace_Desc__c = 'desc';
//         eve.PMP_Event_Banner_Language__c = 'English';
//         eve.PMP_Event_Learn_More_Link_Txt__c = 'www.google.com';
//         eve.PMP_Event_Marquee_Desc_Txt__c = 'marquee';
//         insert eve;
//         PMP_Marketplace_Event_Offering__c eveOff=new PMP_Marketplace_Event_Offering__c();
//         eveOff.PMP_Offering_Id__c=offeringList[0].Id;
//         eveOff.PMP_Event_Id__c=eve.Id;
//         insert eveoff;
        
//         String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
//         string key = 'OfferingDetail'+offeringList[0].id+'enUS';
        
//         offeringIds.add(offeringList[0].id);
//         Cache.Org.put(partitionInput+'.'+key, 'TestString',86400);
//         Cache.Org.put(partitionInput+'.'+'OfferingDetail'+offeringList[0].id+'ja', 'TestString',86400);
//         Test.startTest();
//         system.assertEquals(Cache.Org.contains(partitionInput+'.'+ key),true);
//         // system.debug('limit before' +Limits.getQueries());
//         PMP_OfferingTriggerHelper.clearPlatformCache(offeringIds);
//         PMP_OfferingTriggerHelper.clearfeaturedPlatformCache(offeringList);
//         PMP_OfferingTriggerHelper.clearfeaturedPlatformCache(null);
//         PMP_OfferingTriggerHelper.clearPlatformCache(null);
//         // system.debug('limit after' +Limits.getQueries());
//         system.assertEquals(Cache.Org.contains(partitionInput+'.'+ key),false);
//         Test.stopTest();
//     }
//     //method to test the replaceEventApprovedOfferings method
//     @isTest
//     public static void replaceEventApprovedOfferingsTest(){
//         Set<Id> offeringIds = new Set<Id>();
  
//         PMP_Partner_Offering__c offering3 = [select id,PMP_Is_Published_Ind__c,PMP_Pre_Release_Item_Count_Num__c,PMP_Working_Copy_Id__c,PMP_Partner_Offering_Lifecycle_Status_Nm__c,LastModifiedById  from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering3'];
//         PMP_Partner_Offering_Specification__c offSpecs3 = PMP_TestDataUtility.getPMPOfferingSpecification(offering3.id);
//         PMP_Partner_Offering__c offering4 = [select id,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c,LastModifiedById,PMP_Partner_Offering_Lifecycle_Status_Nm__c  from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering4'];
//         offering3.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Approved';
//         update offering3;
//         offSpecs3.PMP_Is_Pre_Release_Item_Ind__c=true;
//         update offSpecs3;
//         // System.debug('offering3' + offering3.PMP_Pre_Release_Item_Count_Num__c);
//         offering4.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
//         offering4.PMP_Working_Copy_Id__c=offering3.id;
//        // update offering4;
//         PMP_Marketplace_Event__c eve=new PMP_Marketplace_Event__c();
//         eve.Name='Test Event';
//         eve.PMP_Marketplace_Event_Start_Dt__c=System.Now()-1;
//         eve.PMP_Marketplace_Event_End_Dt__c=System.Now()+1;
//         eve.PMP_Marketplace_Event_Tagline__c = 'tagline';
//         eve.PMP_Marketplace_Desc__c = 'desc';
//         eve.PMP_Event_Banner_Language__c = 'English';
//         eve.PMP_Event_Learn_More_Link_Txt__c = 'www.google.com';
//         eve.PMP_Event_Marquee_Desc_Txt__c = 'marquee';
//         insert eve;
//         PMP_Marketplace_Event_Offering__c eveOff=new PMP_Marketplace_Event_Offering__c();
//         eveOff.PMP_Offering_Id__c=offering3.Id;
//         eveOff.PMP_Event_Id__c=eve.Id;
//         insert eveoff;
//         offeringIds.add(offering3.Id);
//         Test.startTest();
//         PMP_OfferingTriggerHelper.replaceEventApprovedOfferings(offeringIds);
        
//         offering3.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Retired';
//         update offering3;
//         PMP_OfferingTriggerHelper.replaceEventApprovedOfferings(offeringIds);
//         PMP_OfferingTriggerHelper.updateretiredofferings(offeringIds);
//         PMP_OfferingTriggerHelper.updateretiredofferings(null);
//         Test.stopTest();
//         system.assertNotEquals(offering3.Id, null);
//     }
    
//     @isTest
//     public static void removePublicOfferingDetailTest(){
//             PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
//             insert apiKey;
//       		Set<Id> offeringIds = new Set<Id>();

//             Account acc1 = [select id from Account where Name=:'TestAccount1'];
                    
//             PMP_Company__c cmp1 = [select id from PMP_Company__c where Name=:'TestCompany1']; 
                                    
//             PMP_Partner_Offering__c offering1 = [select id,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c,LastModifiedById  from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
            
//             PMP_Partner_Offering__c offering2 = [select id,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c,LastModifiedById  from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
            
//             PMP_Partner_Offering_Category__c offCategory = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering1.Id];
            
//             PMP_Partner_Offering_Specification__c offSpecs = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering1.Id];
//             PMP_Partner_Offering_Specification__c offSpecs2 = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering2.Id];
                        
//             PMP_Partner_Offering_Translation__c offTrans = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =:offering1.Id];
            
//             list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
            
//             PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
//             List<PMP_Partner_Offering_Resource__c> getreslist = new List<PMP_Partner_Offering_Resource__c>();
//         	getreslist.add(getResources);
//             offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
//             offering1.PMP_Partner_Offering_Start_Dt__c = system.today();
//             offering1.PMP_Partner_Offering_Nm__c = 'Test';
//             offering1.PMP_Featured_Offering_Ind__c = true;
//             Test.startTest();
//             update offering1;
            
            
//             List<PMP_Partner_Offering__c> publishedOfferings = [select id,PMP_Working_Copy_Id__c,PMP_Featured_Offering_Ind__c from PMP_Partner_Offering__c where PMP_Working_Copy_Id__c=:offering1.Id];
//             System.assertNotEquals(publishedOfferings,null);
            
//             if(publishedOfferings.size()>0){
//                 System.assertEquals(publishedOfferings[0].PMP_Featured_Offering_Ind__c,offering1.PMP_Featured_Offering_Ind__c);
//             }
//             offering1.PMP_Working_Copy_Id__c = offering2.Id;
//             offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Admin Review';
//             update offering1;
            
//             offSpecs.PMP_Is_Pre_Release_Item_Ind__c = true;
//             update offSpecs;
        
//             offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
//             offering1.PMP_Is_Published_Ind__c = false;
//             offering1.PMP_Pre_Release_Check_Nm__c ='Yes';
//             //offering1.PMP_Pre_Release_Item_Count_Num__c = PMP_StaticConstants_MasterData.Zero;
//         	offering1.PMP_Pre_Release_Check_Nm__c = PMP_StaticConstants_MasterData.Yes;
//             update offering1;
            
//             offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
//             offering2.PMP_Is_Published_Ind__c = true;
//             offering2.PMP_Working_Copy_Id__c = offering1.Id;
//         	offering2.PMP_Featured_Offering_Ind__c = true;
//             update offering2;
//             offering2.PMP_Partner_Offering_Nm__c = 'Test Published';
//             offeringIds.add(offering2.Id);
//             //update offering2;
//             offering1.PMP_Partner_Offering_Visibility_Nm__c = 'Intel Only Content';
//             offering1.PMP_Is_Published_Ind__c = true;
//             update offering1;
            
//         	map<Id,Id> offIdsMap = new map<Id,Id>();
//         	offIdsMap.put(offering2.PMP_Working_Copy_Id__c, offering2.PMP_Working_Copy_Id__c);
//         	map<Id,Boolean> offIdsMap1 = new map<Id,Boolean>();
//         	offIdsMap1.put(offering2.Id, offering2.PMP_Featured_Offering_Ind__c);
//             list<PMP_Partner_Offering__c> offlist = new list<PMP_Partner_Offering__c>();
//             offlist.add(offering1);
            
//             PMP_OfferingTriggerHelper.cloneOffering(offlist,null);
//         	PMP_OfferingTriggerHelper.updateRemovePublicOfferings(offList);
//         	PMP_OfferingTriggerHelper.updateRemovePublicOfferings(null);
//         	PMP_OfferingTriggerHelper.deleteImageFiles(getreslist);
//         	PMP_OfferingTriggerHelper.updateRemovePublicofferingList(offList);
//             PMP_OfferingTriggerHelper.createResources(offList, offeringIds, offIdsMap);
//         	PMP_OfferingTriggerHelper.createResourcesDocumentLink(offList, offeringIds, offIdsMap);
//         	PMP_OfferingTriggerHelper.createResourcesDocumentLink(null, null, null);
//         	PMP_OfferingTriggerHelper.createResources(null, null, null);
//         	PMP_OfferingTriggerHelper.syncFeaturedOffering(offIdsMap1);
//         	PMP_OfferingTriggerHelper.syncFeaturedOffering(null);
//         	PMP_OfferingTriggerHelper.createSpecifications(null,null,null);
//         	PMP_OfferingTriggerHelper.createTranslations(null,null,null);
//         	PMP_OfferingTriggerHelper.createCategories(null,null,null);
//         	PMP_OfferingTriggerHelper.updateWorkingCopyPostPublished(null);
//         	PMP_OfferingTriggerHelper.updateOfferings(null);
//             Test.stopTest();
                    
//         }
      
}