/*@isTest(SeeAllData=true)
public class UCD_ACM_UnifiedDataControllerTest {
    
    
        public static testMethod void fieldsetwrapperTest(){
        List<UCD_ACM_UnifiedDataController.accountWrap> WrapList = new List<UCD_ACM_UnifiedDataController.accountWrap>();
        UCD_ACM_UnifiedDataController.accountWrap wrap1 = new UCD_ACM_UnifiedDataController.accountWrap();
        wrap1.customerProcessEngg = null;
        wrap1.complianceWatchList = null;
 
            
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standtee', Email='standarduser@testorg.intel.com', 
                          EmailEncodingKey='UTF-8', LastName='UCDTesting', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.intel.com');
        insert u;
        
        system.runAs(u){
        List<Account> accListNew = new List<Account>();
        Account acc1 = new Account();
        acc1.name = 'Sample';
        acc1.Core_Account_Tier__c = '';
        acc1.Industry = '';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE;
        acc1.core_deactivated__c = FALSE;
        acc1.BillingCountry = 'India';
        //acc1.BillingState = 'Tamil Nadu';
        acc1.Core_CIM_ID__c = '123312';
        acc1.BillingCity='test';
        acc1.BillingStreet='test3';
        acc1.OwnerId = u.id;
        insert acc1;
            
            
        
         UCD_ACM_UnifiedDataController.getUnifiedData(acc1.id); 
            
        }  
        }

    
}*/

@isTest
public class UCD_ACM_UnifiedDataControllerTest {
    
        public static testMethod void fieldsetwrapperTest(){
        List<UCD_ACM_UnifiedDataController.accountWrap> WrapList = new List<UCD_ACM_UnifiedDataController.accountWrap>();
        UCD_ACM_UnifiedDataController.accountWrap wrap1 = new UCD_ACM_UnifiedDataController.accountWrap();
        wrap1.customerProcessEngg = null;
        wrap1.complianceWatchList = null;
        
           /*Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standtee', Email='standarduser@testorg.intel.com', 
                          EmailEncodingKey='UTF-8', LastName='UCDTesting', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.intel.com');
        insert u;
        
      system.runAs(u){ */
        List<Account> accListNew = new List<Account>();
        


        Account acc1 = new Account();
        acc1.Name = 'Sample';
        acc1.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        acc1.BillingCountryCode	= 'IND';
        acc1.BillingCountry	= 'IND';
        acc1.BillingCity = 'Amravati';
        acc1.BillingStateCode = 'MH';
        acc1.BillingStreet = 'TestStreet';
        acc1.Core_Business_Party_Id__c = '1234';
        acc1.ShippingCountryCode = 'IND';
        acc1.Core_Account_Tier__c = '';
        acc1.Industry = '';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE;
        acc1.core_deactivated__c = FALSE;
        acc1.Core_CIM_ID__c = '123312';

        insert acc1;

        List<Business_Types__c> businessTypes = new List<Business_Types__c>();
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price Exception','DIR_PRC_EXCPT1'));
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Supply Demand Revenue','SD_REV1'));
        insert businessTypes;
            
        List<Account_Business_Types__c> accountBusinessTypes = new List<Account_Business_Types__c>();
        For(Business_Types__c businessType : businessTypes){
            accountBusinessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createAccountBusinessType(acc1.Id,businessType.Id));
        }
        insert accountBusinessTypes;  
        
        
         UCD_ACM_UnifiedDataController.getUnifiedData(acc1.id); 
            
       }  
        }