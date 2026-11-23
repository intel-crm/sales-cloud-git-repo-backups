@isTest
public class PCC_DDIPaymentEligibilityInfoAPI_Test {
    
     @testsetup
    static void testSetup(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true Limit 1 ];
        system.runas(sysadm){
            
            Product2 pr = new Product2();
            pr.Name = 'Test data 1';
            pr.IsActive = true;
            pr.Core_Design_Registration_Eligible_Ind__c = true;
            pr.Core_Avail_for_New_Designs__c = true;
            pr.Core_Sales_Visible_Flag__c = true;
            insert pr;
            
            
            Product_MM_Attribute_Mapping__c pmam = new Product_MM_Attribute_Mapping__c();
            pmam.Ordering_Code__c = 'QQ80723058DB';
            pmam.Name = '99APD0'; 
            //pmam.MMID__c = '949344QQ80723058DB Q 47W';
            pmam.L4_Product__c = pr.Id;
            pmam.Eligible_for_DDI_Payment__c ='Yes';
            pmam.DDI_focused__c = 'Tier 1';
            pmam.Payment_Expiration_Date__c = System.today();
            //Assert.isNotNull(pmam);
            insert pmam;
            
        }
 }
	 
    @isTest 
    static void testgetpaymentInfoprice() {
        
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        system.runas(sysadm){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/ddr-payment-eligibility'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('mmid', '99APD0');
        
        RestContext.request = req;
        RestContext.response = res; 
        
        
        Test.startTest();
        PCC_DDIPaymentEligibilityInfoAPI.getPaymentEligibility();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
            }
    }
    
    @isTest 
    static void testpaymentInfopriceorderingcode() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/ddr-payment-eligibility'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('orderingcd', 'QQ80723058DB');
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_DDIPaymentEligibilityInfoAPI.getPaymentEligibility();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
    @isTest 
    static void testgetpaymentInfopriceoldmmid() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/ddr-payment-eligibility'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('orderingCd', 'QQ80723058DB');
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_DDIPaymentEligibilityInfoAPI.getPaymentEligibility();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
    @isTest 
    static void testgetpaymentInfopricenommid() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/ddr-payment-eligibility'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        //req.addParameter('oldmmid', 'QQ80723058DB Q 47W');
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
       PCC_DDIPaymentEligibilityInfoAPI.getPaymentEligibility();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
    @isTest 
    static void testgetpaymentInfopricewrongmmid() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/ddr-payment-eligibility'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('mmid', '123456');
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_DDIPaymentEligibilityInfoAPI.getPaymentEligibility();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    

}