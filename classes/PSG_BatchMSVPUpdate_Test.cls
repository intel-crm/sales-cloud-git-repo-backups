/****************************************************************************************************
Apex Class Name : PSG_BatchMSVPUpdate_Test
Version         : 1.0 
Created Date    : 01/06/2021
Function        : test class for PSG_BatchMSVPUpdate.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Raju Malepalli                  01/06/2021                 Created
*****************************************************************************************************/
@isTest
public class PSG_BatchMSVPUpdate_Test {
    /*@testSetup
    public static void setupData(){
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
    
    public static testMethod void msvpUpdateTest(){
        List<Product2> Products = [Select Id, Name from Product2 limit 10]; 
        List<User> lstUsers3 = PSG_Test_Utility.createAdminUser();
        List<price_msvp__c> msvpList = new List<price_msvp__c>();
        if(!Products.isEmpty()){
            System.assert(!Products.isEmpty(),'');
            Id psgMSVPRecordTypeId =  Schema.SObjectType.price_msvp__c.getRecordTypeInfosByDeveloperName().get(Label.PSG_MSVP_Record_Type).getRecordTypeId();
            for(Integer i=0; i<10; i++){
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
                                                           core_cpq_effective_date_dt__c = System.Today().AddDays(i),
                                                           core_cpq_isactive__c = true
                                                          );
                msvpList.add(testProd);
            }
            
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
                                                        core_cpq_effective_date_dt__c = System.Today().AddDays(-10),
                                                        core_cpq_isactive__c = true
                                                       );
            insert testProd1;
            price_msvp__c testProd0 = new price_msvp__c(RecordTypeId = psgMSVPRecordTypeId,
                                                        core_cpq_product_nm__c = Products[2].Id,
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
                                                        core_cpq_effective_date_dt__c = System.Today().AddDays(-25),
                                                        core_cpq_isactive__c = true
                                                       );
            insert testProd0;
            price_msvp__c testProd4 = new price_msvp__c(RecordTypeId = psgMSVPRecordTypeId,
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
                                                        core_cpq_effective_date_dt__c = System.Today().AddDays(-15),
                                                        core_cpq_isactive__c = true
                                                       );
            insert testProd4;
            for(Integer i=1; i<10; i++){
                price_msvp__c testProd2 = new price_msvp__c(RecordTypeId = psgMSVPRecordTypeId,
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
                                                            core_cpq_effective_date_dt__c = System.today().AddDays(-i),
                                                            core_cpq_isactive__c = true
                                                           );
                msvpList.add(testProd2);
            }
            if(!msvpList.isEmpty()){
                insert msvpList;
            }
        }
        system.runAs(lstUsers3[0]){
            Test.startTest();
            PSG_BatchMSVPUpdate msvpBatch = new PSG_BatchMSVPUpdate();
            database.executeBatch(msvpBatch);
            String cronExp = '0 0 12 * * ?';
            system.schedule('Run_Apprpover_creation_batch123'+system.now(), cronExp, new PSG_BatchMSVPUpdate());
            Test.stopTest();            
        }
    }*/
}