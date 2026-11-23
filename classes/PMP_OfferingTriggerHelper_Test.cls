/****************************************************************************************************************************************
* Class Name  : PMP_OfferingTriggerHelper_Test
* Version     : 1.0 
* Created Date: 08-06-2019
* Modification Log :
*
* Developer      Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shahrukh     07/23/2019                   Test class of PMP_OfferingTriggerHelper
*****************************************************************************************************************************************/

@isTest
public class PMP_OfferingTriggerHelper_Test{

   @testSetup static void setup() {
        // Create common test accounts
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
       
        User u1=PMP_TestDataUtility.createUser(true);

       
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
                                
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Draft','');
        PMP_Partner_Offering_Category__c offCategory = PMP_TestDataUtility.getPMPOfferingCategory(offering1.id);
        
        PMP_Partner_Offering_Specification__c offSpecs = PMP_TestDataUtility.getPMPOfferingSpecification(offering1.id);
        
        PMP_Partner_Offering_Translation__c offTranslation = PMP_TestDataUtility.createOfferingTranslation(offering1.id,'testTranslation');
        if(offTranslation!=null){
           insert offTranslation ;
        }
        
        PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Intel Only Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Draft','');
         PMP_Partner_Offering__c offering3 = PMP_TestDataUtility.createOffering('TestDuplicateOffering3','Public Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Draft','');                                                                         
        PMP_Partner_Offering_Category__c offCategory2 = PMP_TestDataUtility.getPMPOfferingCategory(offering2.id);
        
        PMP_Partner_Offering_Specification__c offSpecs2 = PMP_TestDataUtility.getPMPOfferingSpecification(offering2.id);
        
         document document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'IntelLogo';
        document.FolderId = [select id from folder where name = 'PMP_Marketplace_Images'].id;
        insert document;
        
        document document1 = new Document();
        document1.Body = Blob.valueOf('Some Text');
        document1.ContentType = 'application/pdf';
        document1.DeveloperName = 'my_document1';
        document1.IsPublic = true;
        document1.Name = 'Marketplace Offering Submitted';
        document1.FolderId = document.FolderId;
        insert document1;
        
        
    }
    
    @isTest
    public static void fetchOfferingDetailTest(){
            PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
            insert apiKey;
            Account acc1 = [select id from Account where Name=:'TestAccount1'];
                    
            PMP_Company__c cmp1 = [select id from PMP_Company__c where Name=:'TestCompany1']; 
                                    
            PMP_Partner_Offering__c offering1 = [select id,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c  from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
            
            PMP_Partner_Offering__c offering2 = [select id,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c  from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
            
            PMP_Partner_Offering_Category__c offCategory = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering1.Id];
            
            PMP_Partner_Offering_Specification__c offSpecs = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering1.Id];
            
            PMP_Partner_Offering_Translation__c offTrans = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =:offering1.Id];
            
            list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
            
            PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
            offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
            offering1.PMP_Partner_Offering_Start_Dt__c = system.today();
            offering1.PMP_Partner_Offering_Nm__c = 'Test';
            offering1.PMP_Featured_Offering_Ind__c = true;
            Test.startTest();
            update offering1;
            
            
            List<PMP_Partner_Offering__c> publishedOfferings = [select id,PMP_Working_Copy_Id__c,PMP_Featured_Offering_Ind__c from PMP_Partner_Offering__c where PMP_Working_Copy_Id__c=:offering1.Id];
            System.assertNotEquals(publishedOfferings,null);
            
            if(publishedOfferings.size()>0){
                System.assertEquals(publishedOfferings[0].PMP_Featured_Offering_Ind__c,offering1.PMP_Featured_Offering_Ind__c);
            }
            offering1.PMP_Working_Copy_Id__c = offering2.Id;
            offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Admin Review';
            update offering1;
            
        	offSpecs.PMP_Is_Pre_Release_Item_Ind__c = false;
        	update offSpecs;
        
            offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
            offering1.PMP_Is_Published_Ind__c = false;
        	offering1.PMP_Pre_Release_Check_Nm__c ='No';
        	//offering1.PMP_Pre_Release_Item_Count_Num__c = PMP_StaticConstants_MasterData.Zero;
            update offering1;
            
            offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
            offering2.PMP_Is_Published_Ind__c = true;
            update offering2;
        	offering2.PMP_Partner_Offering_Nm__c = 'Test Published';
            
            update offering2;
      		PMP_Partner_Offering__c offObj = new PMP_Partner_Offering__c();
                offObj.PMP_Partner_Offering_End_Dt__c = Date.today().addDays(365);
                offObj.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
                offObj.PMP_Partner_Offering_Sync_Status_Nm__c = null;
                offObj.PMP_Partner_Offering_Start_Dt__c = date.today();
                offObj.PMP_Offering_Status_Update_Dt__c = date.today().addDays(-4);
                offObj.PMP_Intel_Admin_Id__c = userinfo.getuserid();
                //offObj.ownerid = u1.id;
                offObj.PMP_Partner_Offering_Dsc__c = 'Sample';
                offObj.PMP_Review_Comment_Txt__c = 'Sample Text';
                offObj.PMP_Partner_Offering_Visibility_Nm__c = 'Public Content';
                
                offObj.PMP_Is_Published_Ind__c = true;
        		insert  offObj;
        		offObj.PMP_Partner_Offering_Dsc__c=' UPDATE PUBLISHED';
        		update offObj;
        
                //PMP_OfferingTriggerHelper instance = new PMP_OfferingTriggerHelper();
                
                offObj.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Draft';
                offObj.PMP_Is_Published_Ind__c = true;
                update offObj;
                offObj.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
                update offObj;
                
        
        	//instance.updatePublishedOfferingList(offering1);
            
            Test.stopTest();
                    
        }
        
    @isTest
    public static void clearPlatformCacheTest(){
        List<PMP_Partner_Offering__c> offeringList = [select id,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c  from PMP_Partner_Offering__c ];
        String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
        string key = offeringList[0].id+'enUS';
        Cache.Org.put(partitionInput+'.'+key, 'TestString',86400);
        Cache.Org.put(partitionInput+'.'+offeringList[0].id+'ja', 'TestString',86400);
        Test.startTest();
        system.assertEquals(Cache.Org.contains(partitionInput+'.'+ key),true);
        system.debug('limit before' +Limits.getQueries());
        PMP_OfferingTriggerHelper.clearPlatformCache(offeringList );
        system.debug('limit after' +Limits.getQueries());
        system.assertEquals(Cache.Org.contains(partitionInput+'.'+ key),false);
        Test.stopTest();
    }
   
}