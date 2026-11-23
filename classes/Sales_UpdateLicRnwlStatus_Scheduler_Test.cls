/******************************************************
Component Name    : Sales_UpdateLicRnwlStatus_Scheduler_Test
Created Date      : April 2022


Modification Log :
Developer                       Date                    Description
Bharath Indla                04/07/2022                 Test Class for Sales_UpdateLicRnwlStatus_Queuable and Scheduler Class

*****************************************************/

@isTest
public class Sales_UpdateLicRnwlStatus_Scheduler_Test {
/*
     static testMethod void testschedule() {
        String errMsg='';                
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Web_Displayable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);           
        insert prodExt1 ; 
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        
        try{
            Test.startTest();                            
            Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Product__c' => prod1.Id , 
                'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });    
			lic.Sales_License_Expiration_Date_Dt__c = System.Today() - 2 ;
            lic.Sales_License_Maintenance_Exp_Dt__c = System.Today() - 2 ;
            insert lic;
           // System.debug('licenses to Update -'+lic);
			String sch = '0 0 5 * * ?';
			Id jobId =System.schedule('Sales_UpdateLicRnwlStatus_Scheduler', sch, new Sales_UpdateLicRnwlStatus_Scheduler() );
             Test.stopTest();            
        }catch(Exception e){
            //System.debug('Error msg -->'+e.getMessage());
            errMsg=e.getMessage();
        }
    }
*/
}