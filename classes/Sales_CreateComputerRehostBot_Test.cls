@isTest
public class Sales_CreateComputerRehostBot_Test {
    /*@isTest
    public static void CreateComputer_Rehost_Bot_Fixed_Test(){
        String errMsg = '';
        Sales_CreateComputer_Rehost_Bot.ComputerInput Input1 = new Sales_CreateComputer_Rehost_Bot.ComputerInput();         
        Sales_CreateComputer_Rehost_Bot.ComputerInput Input3 = new Sales_CreateComputer_Rehost_Bot.ComputerInput();
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord();  
        Sales_Host__c hostRec3 = Sales_TestDataFactory.createComputerRecord(); 
        insert new List<Sales_Host__c>{hostRec1,hostRec3};
            Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec1.Id,  'Sales_License_Product__c'=>prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });  
        Sales_License__c lic3 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec3.Id,  'Sales_License_Product__c'=>prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });  
        insert new List<Sales_License__c>{lic1,lic3};       
            Input1.hostObject = hostRec1;
        Input1.Sales_ComputerName_for_New_Computer = hostRec1.Sales_Computer_Name_Txt__c;
        Input1.ComputerType_for_NewComputer = 'GUARD ID' ;
        Input1.Host_LicenseType = 'FIXED';
        Input1.Guard_ID = 'T000033399';
        Input1.Companion_Server1_ID = 'T000033399';
        Input1.Companion_Server2_ID = 'T000033399';               
        Input3.hostObject = hostRec3;
        Input3.Sales_ComputerName_for_New_Computer = hostRec3.Sales_Computer_Name_Txt__c;
        Input3.ComputerType_for_NewComputer = 'NIC ID' ;
        Input3.Host_LicenseType = 'FIXED';
        Input3.NIC_ID_or_Guard_ID = '123456789999';
        Input3.Companion_Server1_ID = 'T000033399';
        Input3.Companion_Server2_ID = 'T000033399';
        System.Test.startTest();
        try{
            Sales_CreateComputer_Rehost_Bot.createComputerDetails(new List<Sales_CreateComputer_Rehost_Bot.ComputerInput>{Input1}); 
            Sales_CreateComputer_Rehost_Bot.createComputerDetails(new List<Sales_CreateComputer_Rehost_Bot.ComputerInput>{Input3});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
    }
    @isTest
    public static void CreateComputer_Rehost_Bot_Float_Test(){
        String errMsg = '';
        Sales_CreateComputer_Rehost_Bot.ComputerInput Input2 = new Sales_CreateComputer_Rehost_Bot.ComputerInput();                 
        Sales_CreateComputer_Rehost_Bot.ComputerInput Input4 = new Sales_CreateComputer_Rehost_Bot.ComputerInput();
        Core_Product_Ext_Attribute__c prodExt2 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt2.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert prodExt2 ;
        Product2 prod2 = Sales_TestDataFactory.createProduct();
        prod2.put('Core_Product_Ext_Attribute_Id__c',prodExt2.Id);
        insert prod2;
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord();
        Sales_Host__c hostRec4 = Sales_TestDataFactory.createComputerRecord();
        insert new List<Sales_Host__c>{hostRec2,hostRec4};
            Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod2.Id, Test.getStandardPricebookId());
        OrderItem oi1 = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod2.Id, standardPrice.Id);
        Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec2.Id,  'Sales_License_Product__c'=>prod2.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi1.id
                });  
        Sales_License__c lic4 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec4.Id,  'Sales_License_Product__c'=>prod2.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi1.id
                });
        insert new List<Sales_License__c>{lic2,lic4};
            Input2.hostObject = hostRec2;
        Input2.Sales_ComputerName_for_New_Computer = hostRec2.Sales_Computer_Name_Txt__c;
        Input2.ComputerType_for_NewComputer = 'HOST ID' ;
        Input2.Host_LicenseType = 'FLOAT';
        Input2.Host_ID_or_Guard_ID = '000033399';
        Input2.Redundant_Server1_ID = 'S000033399';
        Input2.Redundant_Server2_ID = 'S000033399';               
        Input4.hostObject = hostRec4;
        Input4.Sales_ComputerName_for_New_Computer = hostRec4.Sales_Computer_Name_Txt__c;
        Input4.ComputerType_for_NewComputer = 'NIC ID' ;
        Input4.Host_LicenseType = 'FLOAT';
        Input4.NIC_ID_or_Guard_ID = '123456787777';
        Input4.Redundant_Server1_ID = 'S000033399';
        Input4.Redundant_Server2_ID = 'S000033399';
        System.Test.startTest();
        try{
            Sales_CreateComputer_Rehost_Bot.createComputerDetails(new List<Sales_CreateComputer_Rehost_Bot.ComputerInput>{Input2});
            Sales_CreateComputer_Rehost_Bot.createComputerDetails(new List<Sales_CreateComputer_Rehost_Bot.ComputerInput>{Input4});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
    }*/
}