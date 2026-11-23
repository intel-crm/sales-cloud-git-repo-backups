/*************************************************************************************************************************************************************************
* Class Name  : PMP_CloneOfferingController_Test 
* Version     : 1.0 
* Created Date: 01/17/2020
* Modification Log :
*
* Developer         Modification Log                        Date                                                         Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Raj Y    M-01    : Original version                    01/17/2020                                             Test Class for PMP_CloneOfferingController
**************************************************************************************************************************************************************************/
@isTest
public class PMP_CloneOfferingController_Test {

//    @testSetup static void setup() {
//         // Create common test accounts
        
//         Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
//         Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
       
//        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
//        Account acc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
       
       
       
//         PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
                                
//         PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
//                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','Test');
                                                                                 
       
//         PMP_Partner_Offering_Category__c offCategory = PMP_TestDataUtility.getPMPOfferingCategory(offering1.id);
        
//         PMP_Partner_Offering_Specification__c offSpecs = PMP_TestDataUtility.getPMPOfferingSpecification(offering1.id);
        
//         PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
//                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','Test');
                                                                                 
//         PMP_Partner_Offering_Category__c offCategory2 = PMP_TestDataUtility.getPMPOfferingCategory(offering2.id);
        
//         PMP_Partner_Offering_Specification__c offSpecs2 = PMP_TestDataUtility.getPMPOfferingSpecification(offering2.id);
        
//         List<PMP_Partner_Offering_Translation__c> translationList = new List<PMP_Partner_Offering_Translation__c>();
        
//         PMP_Partner_Offering_Translation__c offTranslation = PMP_TestDataUtility.createOfferingTranslationsWithFieldNames(offering1.id,'testTranslation','PMP_Partner_Offering_Nm__c','TranslationTest');
//         if(offTranslation!=null){
//            translationList.add(offTranslation);
//         }
        
//         PMP_Partner_Offering_Translation__c offTranslation2 = PMP_TestDataUtility.createOfferingTranslationsWithFieldNames(offering1.id,'testTranslation','PMP_Partner_Offering_Dsc__c','Test');
//         if(offTranslation2!=null){
//            translationList.add(offTranslation2);
//         }
        
//         PMP_Partner_Offering_Translation__c offTranslation3 = PMP_TestDataUtility.createOfferingTranslationsWithFieldNames(offering1.id,'testTranslation','PMP_Partner_Offering_Tag_Line_Txt__c','TestTagLine');
//         if(offTranslation3!=null){
//            translationList.add(offTranslation3);
//         }
        
//         if(!translationList.isEmpty()){
//             insert translationList;
//         }
        
//     }
    
//     static testMethod void cloneOfferingResourcesTest(){
//         Test.startTest();
//         //creating offerings
//         PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoffering', 'Public Content','off desc',null,true,'draft','taglineTest' );
//         PMP_Partner_Offering__c clonedOffering = PMP_TestDataUtility.createOffering('clonedOffering', 'Public Content','off desc',null,true,'draft','taglineTest' );
        
//         //create contentDocument
//         List<ContentDocument> docs = PMP_TestDataUtility.createContentDocument(true);
        
//         //create offeringResources
//         PMP_Partner_Offering_Resource__c offRes1 = PMP_TestDataUtility.createResources('Web Page', 'http://www.abc.com', offering.Id, 'Web Page', null);
//         PMP_Partner_Offering_Resource__c offRes2 = PMP_TestDataUtility.createResources('Image', null, offering.Id, 'Image', docs[0].Id);
        
//         List<PMP_Partner_Offering_Resource__c> clonedResources = PMP_CloneOfferingController.cloneOfferingResources(offering.Id, clonedOffering.Id);
        
//         System.assertEquals(2, clonedResources.size());
//         Test.stopTest();
        
//     }
    
//     @isTest
//     public static void cloneOfferingTest(){
//         PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
//         insert apiKey;
//         //Account acc1 = [select id from Account where Name=:'TestAccount1'];
        
//         //PMP_Company__c cmp1 = [select id from PMP_Company__c where Name=:'TestCompany1']; 
        
//         PMP_Partner_Offering__c offering1 = [select id,PMP_Partner_Offering_Nm__c from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
        
//         PMP_Partner_Offering__c offering2 = [select id,PMP_Partner_Offering_Nm__c from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
        
//         //PMP_Partner_Offering_Category__c offCategory = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering1.Id];
        
//         //PMP_Partner_Offering_Specification__c offSpecs = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering1.Id];
        
//         //List<PMP_Partner_Offering_Translation__c> offTrans = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =:offering1.Id];
        
//         list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
        
//         PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering2.id);
        
//         offering1.PMP_Working_Copy_Id__c = offering2.id;
//         update offering1;
//         pmp_partner_offering__c clonedOffering=offering1.clone(false,true,true,false);
//         clonedOffering.PMP_Category_nm__c='Solution';
//         pmp_partner_offering__c publishedClonedOffering = new pmp_partner_offering__c();
//         publishedClonedOffering = clonedOffering.clone(false,true,true,false);
//         publishedClonedOffering.PMP_Is_Not_Available_On_MP_Ind__c = true;
//         publishedClonedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
//         publishedClonedOffering.PMP_Partner_Offering_LifecycleStatus_Txt__c= publishedClonedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c;        
//         insert clonedOffering; //inserting newly cloned offering and returning it back to client side.
        
//         publishedClonedOffering.PMP_Working_Copy_Id__c = clonedOffering.id;
//         insert publishedClonedOffering;
//         PMP_Category__c category= new PMP_Category__c(); 
//         category.Name='Solution';
//         category.PMP_Category_Chinese_Nm__c='askljkfihsdk';
//         category.PMP_Category_Japanese_Nm__c='jpasd8dajn';
//         category.PMP_Partner_Product_Category_Cd__c='IPA_TYPE_Sol';
//         category.PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_TYPE';
//         category.PMP_Active_Ind__c=true;
//         //category.Core_PMP_Locale__c = locale;
//         insert category; //Avoid insert - insert in the test class where it is used, in this way it will be more generic
        
//         PMP_Category__c categorySub= new PMP_Category__c(); 
//         categorySub.Name='Partner Solutions New';
//         categorySub.PMP_Category_Chinese_Nm__c='askljkfihsdk';
//         categorySub.PMP_Category_Japanese_Nm__c='jpasd8dajn';
//         categorySub.PMP_Partner_Product_Category_Cd__c='TPS_900039';
//         categorySub.PMP_Partner_Product_Parent_Category_Cd__c='IPA_TYPE_Sol';
//         categorySub.PMP_Active_Ind__c=true;
//         categorySub.PMP_Parent_Category_Id__c=category.Id;
//         insert categorySub;
        
//         PMP_Category__c categorySub1= new PMP_Category__c(); 
//         categorySub1.Name='Partner Solutions';
//         categorySub1.PMP_Category_Chinese_Nm__c='askljkfihsdk';
//         categorySub1.PMP_Category_Japanese_Nm__c='jpasd8dajn';
//         categorySub1.PMP_Partner_Product_Category_Cd__c='TPS_900039';
//         categorySub1.PMP_Partner_Product_Parent_Category_Cd__c='IPA_TYPE_Sol';
//         categorySub1.PMP_Active_Ind__c=true;
//         categorySub1.PMP_Parent_Category_Id__c=category.Id;
//         insert categorySub1;
        
        
//         PMP_Partner_Offering_Category__c offeringCat1 = new PMP_Partner_Offering_Category__c();
//         offeringCat1.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE';
//         offeringCat1.PMP_Category_Id__c = category.Id; 
//         offeringCat1.Name = category.Name;
//         offeringCat1.PMP_Offering_Category_External_Key__c   = category.PMP_Partner_Product_Category_Cd__c;
//         offeringCat1.PMP_Offering_Id__c   = clonedOffering.Id;
//         insert offeringCat1;      
        
//         PMP_Partner_Offering_Category__c offeringCat = new PMP_Partner_Offering_Category__c();
//         offeringCat.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|IPA_TYPE_Sol';
//         offeringCat.PMP_Category_Id__c = categorySub.Id; 
//         offeringCat.Name = categorySub.Name;
//         offeringCat.PMP_Offering_Category_External_Key__c   = categorySub.PMP_Partner_Product_Category_Cd__c;
//         offeringCat.PMP_Offering_Id__c   = clonedOffering.Id;
//         insert offeringCat;      
//         Test.startTest();
        
//         String Resp = PMP_OfferingDetailsController.cloneOfferingDetail(offering1.Id,'en_US');
//         system.assertNotEquals(Null,Resp);

//         List<PMP_Partner_Offering_Translation__c> translationList= new List<PMP_Partner_Offering_Translation__c>();
//         PMP_Partner_Offering_Translation__c offTranslation = PMP_TestDataUtility.createOfferingTranslationsWithFieldNames(clonedOffering.id,'testTranslation','PMP_Partner_Offering_Nm__c','TranslationTest1');
//         if(offTranslation!=null){
//             translationList.add(offTranslation);
//         }
        
//         PMP_Partner_Offering_Translation__c offTranslation2 = PMP_TestDataUtility.createOfferingTranslationsWithFieldNames(clonedOffering.id,'testTranslation','PMP_Partner_Offering_Dsc__c','Test1');
//         if(offTranslation2!=null){
//             translationList.add(offTranslation2);
//         }
        
//         PMP_Partner_Offering_Translation__c offTranslation3 = PMP_TestDataUtility.createOfferingTranslationsWithFieldNames(clonedOffering.id,'testTranslation','PMP_Partner_Offering_Tag_Line_Txt__c','TestTagLine1');
//         if(offTranslation3!=null){
//             translationList.add(offTranslation3);
//         }
        
//         if(!translationList.isEmpty()){
//             insert translationList;
//         }
//         String Resp1 = PMP_OfferingDetailsController.cloneOfferingDetail(clonedOffering.Id,'en_US');
        
//         system.assertNotEquals(Null,Resp1);
        
//         Test.stopTest();
        
//     }
    
}