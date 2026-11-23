/****************************************************************************************************************************************
* Class Name  : PMP_OfferingResourceTriggerHelper_Test
* Version     : 1.0 
* Created Date: 07-23-2019
* Modification Log :
*
* Developer      Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shahrukh     07/23/2019                   Test class of PMP_OfferingInsertUpdate
*****************************************************************************************************************************************/

@isTest
public class PMP_OfferingResourceTriggerHelper_Test{

   @testSetup static void setup() {
        // Create common test accounts
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
       
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
                                
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Draft','');
 
    }
    
    @isTest
    public static void createContentDistributionTest(){
            PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
            insert apiKey;
            Account acc1 = [select id from Account where Name=:'TestAccount1'];
                    
            PMP_Company__c cmp1 = [select id from PMP_Company__c where Name=:'TestCompany1']; 
                                    
            PMP_Partner_Offering__c offering1 = [select id,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c  from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
            
            list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
            
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=offering1.id;
            contentlink.ShareType= 'I';
            contentlink.LinkedEntityId = offering1.Id; 
            contentlink.ContentDocumentId=contentDocument[0].Id;
            contentlink.Visibility = 'InternalUsers'; 
            insert contentlink;
            
            Test.startTest();
            
            PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
            
            List<contentDistribution> contDistList = [select id, contentDocumentId from contentDistribution where contentDocumentId=:contentDocument[0].id];
            system.assertNotEquals(contDistList,null);
            
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            
            ContentAsset ca =  new ContentAsset();
            ca.DeveloperName = 'Test'+'_'+String.valueOf(randomInt);
            ca.MasterLabel= String.valueOf(randomInt);
            ca.isVisibleByExternalUsers = TRUE;
            insert ca; 
            
            contentDocument[0].contentAssetId = ca.id;
            update contentDocument[0];
            
            delete getResources; 
            
            Test.stopTest();
                    
        }
}