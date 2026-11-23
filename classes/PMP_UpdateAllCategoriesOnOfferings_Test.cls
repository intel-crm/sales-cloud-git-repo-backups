/****************************************************************************************************************************************
* Class Name  : PMP_UpdateAllCategoriesOnOfferings_Test
* Version     : 1.0 
* Created Date: 09-01-2020
* Modification Log :
*
* Developer      Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shahrukh     09-01-2020                   Test class of PMP_UpdateAllCategoriesOnOfferings
*****************************************************************************************************************************************/

@isTest
public class PMP_UpdateAllCategoriesOnOfferings_Test {

//    @testSetup static void setup() {
//         // Create common test accounts
        
//         Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
//         Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
       
//         Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
//         Account acc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
       
       
       
//         PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
                                
//         PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
//                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
       
//         PMP_Partner_Offering_Category__c offCategory = PMP_TestDataUtility.getPMPOfferingCategory(offering1.id);

//         PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
//                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
                                                                                 
//         PMP_Partner_Offering_Category__c offCategory2 = PMP_TestDataUtility.getPMPOfferingCategory(offering2.id);
          
//     }
       
//    @isTest
//     public static void cloneOfferingTest(){
//             PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
//             insert apiKey;
//             Account acc1 = [select id from Account where Name=:'TestAccount1'];
//             Account acc2 = [select id from Account where Name=:'TestPartnerAccount1'];
                    
//             PMP_Company__c cmp1 = [select id from PMP_Company__c where Name=:'TestCompany1']; 
                                    
//             PMP_Partner_Offering__c offering1 = [select id,PMP_Partner_Offering_Lifecycle_Status_Nm__c from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
            
//             PMP_Partner_Offering__c offering2 = [select id,PMP_Partner_Offering_Lifecycle_Status_Nm__c from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
            
//             PMP_Partner_Offering_Category__c offCategory1 = [select id,PMP_Offering_Id__c,PMP_Ancestor_Category_Cd__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering1.Id];
//             offCategory1.PMP_Ancestor_Category_Cd__c = 'NPP_01_Type|Test';
            
//             PMP_Partner_Offering_Category__c offCategory2 = [select id,PMP_Offering_Id__c,PMP_Ancestor_Category_Cd__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering2.Id];
//             offCategory2.PMP_Ancestor_Category_Cd__c = 'NPP_01_Type|Test';
            
//             List<PMP_Partner_Offering_Category__c> offCatList = new List<PMP_Partner_Offering_Category__c>();
//             offCatList.add(offCategory1);
//             offCatList.add(offCategory2);
//             update offCatList;
            
//             offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
//             offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
            
//             List<PMP_Partner_Offering__c> offList = new List<PMP_Partner_Offering__c>();
//             offList.add(offering1);
//             offList.add(offering2);
//             update offList;
            
            
//             Test.startTest();
//             PMP_UpdateAllCategoriesOnOfferings uaco = new PMP_UpdateAllCategoriesOnOfferings();
//             Id batchId = Database.executeBatch(uaco);
            
//             Test.stopTest();
//             PMP_Partner_Offering__c offeringResult = [select id,PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_All_Categories_Txt__c from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
            
//             system.assertNotEquals(offeringResult.PMP_All_Categories_Txt__c,Null,'Successful');
        
            
                    
//         }
        
}