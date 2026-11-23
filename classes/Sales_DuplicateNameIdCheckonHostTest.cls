@isTest
public class Sales_DuplicateNameIdCheckonHostTest {
  @isTest
    public static void Sales_DuplicateNameIdCheckonHost_Test(){
        String errMsg = '';
        String res='';
        Sales_DuplicateNameIdCheckonHost.ContactInput Input1 = new Sales_DuplicateNameIdCheckonHost.ContactInput();
        Sales_DuplicateNameIdCheckonHost.ContactInput Input2 = new Sales_DuplicateNameIdCheckonHost.ContactInput();
        Sales_DuplicateNameIdCheckonHost.ContactInput Input3 = new Sales_DuplicateNameIdCheckonHost.ContactInput();
        List<Sales_DuplicateNameIdCheckonHost.ComputerOutput> result;         
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id}); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','NEUTRAL');
        Core_Product_Ext_Attribute__c prodExt2 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt2.put('Core_SW_Lic_Type_Nm__c','FIXED');
        Core_Product_Ext_Attribute__c prodExt3 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt3.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert new List<Core_Product_Ext_Attribute__c>{prodExt1,prodExt2,prodExt3};
            Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        Product2 prod2 = Sales_TestDataFactory.createProduct();
        prod2.put('Core_Product_Ext_Attribute_Id__c',prodExt2.Id);
        Product2 prod3 = Sales_TestDataFactory.createProduct();
        prod3.put('Core_Product_Ext_Attribute_Id__c',prodExt3.Id);
        insert new List<Product2>{prod1,prod2,prod3};       
            Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con2.Id}); 
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con2.Id}); 
        Sales_Host__c hostRec3 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_License_Type__c' => 'FLOAT', 'Sales_Contact__c'=>con2.Id});
        insert new List<Sales_Host__c>{hostRec1,hostRec2,hostRec3};
         System.Test.startTest();
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
            Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
                'Sales_License_Host_Node_Id__c' => hostRec1.Id, 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                    }); 
        Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec2.Id, 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod2.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                }); 
        Sales_License__c lic3 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec3.Id, 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod3.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });         
        insert new List<Sales_License__c>{lic1,lic2,lic3};       
            Input1.sContactId = con2.Id;  
        Input1.computername = hostRec1.Sales_Computer_Name_Txt__c;
        Input1.computerid = hostRec1.Name;
        Input2.sContactId = con2.Id;  
        Input2.computername = hostRec2.Sales_Computer_Name_Txt__c;
        Input2.computerid = hostRec2.Name;
        Input3.sContactId = con2.Id;  
        Input3.computername = hostRec3.Sales_Computer_Name_Txt__c;
        Input3.computerid = hostRec3.Name;
        try{
            result=Sales_DuplicateNameIdCheckonHost.getHostDetails(new List<Sales_DuplicateNameIdCheckonHost.ContactInput>{Input1});   
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
}