/****************************************************************************************************
Apex Class Name : PSG_MSVPBusinessLogic_Test
Version         : 1.0 
Created Date    : 01/06/2021
Function        : test class for PSG_MSVPBusinessLogic
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Raju Malepalli                  01/06/2021                 Created
*****************************************************************************************************/
@isTest
public class PSG_MSVPBusinessLogic_Test {
    @testSetup
    public static void setUpData(){
        List<User> lstUsers2 = PSG_Test_Utility.createAdminUser();  
        System.runAs(lstUsers2[0]){
            Test.startTest();
            PriceBook2 pb = PSG_Test_Utility.createPriceBook('psg-test');
            List<Product2> products = PSG_Test_Utility.createProduct(3);
            System.assertEquals(products[0].Name,'Test Product0');
            System.assertEquals(products[0].IsActive,true);
            Test.stopTest();
        }
    }
    
    static testmethod void MSVP(){
        List<Product2> Products = [Select Id, Name from Product2 limit 10];
        list<user> lstusers = [SELECT Id FROM User limit 1];
        System.runAs(lstUsers[0]){
            if(!Products.isEmpty())
            {
                Id psgMSVPRecordTypeId =  Schema.SObjectType.price_msvp__c.getRecordTypeInfosByDeveloperName().get(Label.PSG_MSVP_Record_Type).getRecordTypeId();
                price_msvp__c testProd1 = new price_msvp__c(RecordTypeId = psgMSVPRecordTypeId,
                                                            core_cpq_product_nm__c = Products[1].Id,
                                                            price_10ku_y_amt__c = 100,
                                                            price_1ku_y_amt__c = 20,
                                                            core_cpq_product_opn__c = '1SG000',
                                                            price_2_5ku_y_amt__c = 25,
                                                            price_250u_y_amt__c = 30,
                                                            price_500u_y_amt__c = 35,
                                                            price_5ku_y_amt__c = 45,
                                                            price_level_1_amt__c = 35,
                                                            price_level_2_amt__c = 32,
                                                            price_prototype_amt__c = 20,
                                                            core_cpq_effective_date_dt__c = System.Today()-10,
                                                            core_cpq_isactive__c = true
                                                           );
                insert testProd1;
                price_msvp__c testProd2 = new price_msvp__c(RecordTypeId = psgMSVPRecordTypeId,
                                                            price_10ku_y_amt__c = 100,
                                                            price_1ku_y_amt__c = 20,
                                                            core_cpq_product_opn__c = '1SG000',
                                                            price_2_5ku_y_amt__c = 25,
                                                            price_250u_y_amt__c = 30,
                                                            price_500u_y_amt__c = 35,
                                                            price_5ku_y_amt__c = 45,
                                                            price_level_1_amt__c = 35,
                                                            price_level_2_amt__c = 32,
                                                            price_prototype_amt__c = 20,
                                                            core_cpq_effective_date_dt__c = System.Today()+1,
                                                            core_cpq_isactive__c = true
                                                           );
                insert testProd2;
                price_msvp__c testProd = new price_msvp__c(RecordTypeId = psgMSVPRecordTypeId,
                                                           core_cpq_product_nm__c = Products[1].Id,
                                                           price_10ku_y_amt__c = 100,
                                                           price_1ku_y_amt__c = 20,
                                                           core_cpq_product_opn__c = '1SG000',
                                                           price_2_5ku_y_amt__c = 25,
                                                           price_250u_y_amt__c = 30,
                                                           price_500u_y_amt__c = 35,
                                                           price_5ku_y_amt__c = 45,
                                                           price_level_1_amt__c = 35,
                                                           price_level_2_amt__c = 32,
                                                           price_prototype_amt__c = 20,
                                                           core_cpq_effective_date_dt__c = System.Today()+10,
                                                           core_cpq_isactive__c = true
                                                          );
                insert testProd;  
                price_msvp__c testProd4 = new price_msvp__c(RecordTypeId = psgMSVPRecordTypeId,
                                                           core_cpq_product_nm__c = Products[1].Id,
                                                           price_10ku_y_amt__c = 100,
                                                           price_1ku_y_amt__c = 20,
                                                           core_cpq_product_opn__c = '1SG000',
                                                           price_2_5ku_y_amt__c = 25,
                                                           price_250u_y_amt__c = 30,
                                                           price_500u_y_amt__c = 35,
                                                           price_5ku_y_amt__c = 45,
                                                           price_level_1_amt__c = 35,
                                                           price_level_2_amt__c = 32,
                                                           price_prototype_amt__c = 20,
                                                           core_cpq_effective_date_dt__c = System.Today(),
                                                           core_cpq_isactive__c = true
                                                          );
                insert testProd4;  
                price_msvp__c testProd5 = new price_msvp__c(RecordTypeId = psgMSVPRecordTypeId,
                                                           core_cpq_product_nm__c = Products[1].Id,
                                                           price_10ku_y_amt__c = 100,
                                                           price_1ku_y_amt__c = 20,
                                                           core_cpq_product_opn__c = '1SG000',
                                                           price_2_5ku_y_amt__c = 25,
                                                           price_250u_y_amt__c = 30,
                                                           price_500u_y_amt__c = 35,
                                                           price_5ku_y_amt__c = 45,
                                                           price_level_1_amt__c = 35,
                                                           price_level_2_amt__c = 32,
                                                           price_prototype_amt__c = 20,
                                                           core_cpq_effective_date_dt__c = System.Today(),
                                                           core_cpq_isactive__c = true
                                                          );
                insert testProd5;  
                testProd5.core_cpq_product_nm__c=Products[0].Id;
                update testProd5;
                price_msvp__c testProd3 = new price_msvp__c();
                testProd3.Id = null;
                insert testProd3;
                Test.startTest();
                System.assert(testProd.Id!=null,'Test Product insert successfull');
                testProd2 = [SELECT Id, core_cpq_product_nm__c,core_cpq_product_opn__c FROM price_msvp__c WHERE Id =: testProd.Id];
                String oldOPN = testProd2.core_cpq_product_opn__c;
                testProd2.core_cpq_product_nm__c = Products[2].Id;
                update testProd;
                System.assert(testProd.Id!=null,'Test Product update successfull');
                testProd2 = [SELECT Id, core_cpq_product_nm__c,core_cpq_product_opn__c FROM price_msvp__c WHERE Id =: testProd2.Id];
                testProd2.core_cpq_product_opn__c = oldOPN;
                update testProd2;
                System.assert(testProd2.Id!=null,'Test Product update successfull');
                Test.stopTest();
            }
        }
        
    }
}