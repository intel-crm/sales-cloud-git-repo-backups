/****************************************************************************************************
Apex Class Name : PSG_ForwardCostBusinessLogic_Test
Version         : 1.0 
Created Date    : 01/06/2021
Function        : Test class for PSG_ForwardCostBusinessLogic
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                  01/06/2021                 Created
*****************************************************************************************************/
@isTest
public class PSG_ForwardCostBusinessLogic_Test {
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
    
    static testmethod void forwardCost(){
        List<Product2> products = [Select Id, Name from Product2 where IsActive = true and Core_Product_Type__c ='Intel® FPGAs' and Core_Product_Org__c ='Sales' limit 10];
        list<user> lstusers = [SELECT Id FROM User limit 1];
        System.runAs(lstUsers[0]){
            if(!Products.isEmpty())
            {
                Id psgFCRecordTypeId =  Schema.SObjectType.price_forward_cost__c.getRecordTypeInfosByDeveloperName().get(Label.PSG_Forward_Cost_Record_Type).getRecordTypeId();
                price_forward_cost__c testProd1 = new price_forward_cost__c(
                    RecordTypeId = psgFCRecordTypeId,
                    Name = 'test',   
                    price_forward_cost_amt__c = 100, 
                    core_cpq_fc_start_date_dt__c = System.Today(),
                    core_cpq_fc_end_date_dt__c = System.Today().addDays(1));
                try{
                    insert testProd1;
                }catch(Exception e){}
                price_forward_cost__c testProd2 = new price_forward_cost__c(
                    RecordTypeId = psgFCRecordTypeId,
                    Name = 'test1',
                    core_cpq_product_nm__c = Products[0].Id,
                    price_forward_cost_amt__c = 100,
                    core_cpq_fc_start_date_dt__c = System.Today(),
                    core_cpq_fc_end_date_dt__c = System.Today().addDays(1));
                try{
                    insert testProd2;
                }catch(Exception e){}
                Test.startTest();
                price_forward_cost__c testProd = new price_forward_cost__c(
                    RecordTypeId = psgFCRecordTypeId,
                    Name = null,   
                    price_forward_cost_amt__c = 100,
                    core_cpq_product_opn_txt__c = '1SG000',
                    core_cpq_fc_start_date_dt__c = System.Today(),
                    core_cpq_fc_end_date_dt__c = System.Today().addDays(1));
                try{
                    insert testProd;
                }catch(Exception e){}
                testProd.Name='Test Fc';
                insert testProd;
                System.assertEquals(testProd.Name, 'Test Fc');
                testProd = [SELECT Id, core_cpq_product_nm__c,core_cpq_product_opn_txt__c FROM price_forward_cost__c WHERE Id =: testProd.Id];
                String oldOPN = testProd.core_cpq_product_opn_txt__c;
                testProd.core_cpq_product_nm__c = Products[1].Id;
                update testProd;
                testProd = [SELECT Id, core_cpq_product_nm__c,core_cpq_product_opn_txt__c FROM price_forward_cost__c WHERE Id =: testProd.Id];
                testProd.core_cpq_product_opn_txt__c = oldOPN;
                update testProd;
                Test.stopTest();
            }
        }
    }
}