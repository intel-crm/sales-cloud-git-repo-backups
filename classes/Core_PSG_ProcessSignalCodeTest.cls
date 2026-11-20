@isTest
public class Core_PSG_ProcessSignalCodeTest {
	 /*@isTest static void processSignalCodeTest(){
     
        List<Product2> prodList = new List<Product2>();
        Product2 pr1=new Product2();
        pr1.Name='Test';
        pr1.Description='Test';
        pr1.Core_OPN__c= '1234';
         pr1.Core_Item_Signal_Cd__c = 'HB';
         pr1.Core_Item_Class_Nm__c = 'IC';
        pr1.Core_Item_Id__c ='12345';
        pr1.isActive = true;
         pr1.Core_Product_Type__c = 'Intel® FPGAs';
         pr1.Core_Product_Org__c = 'Sales';
        insert pr1;
        
        Product2 pr=new Product2();
        pr.Name='Test';
        pr.Description='Test';
        pr.Core_OPN__c= '1234567';
        pr.Core_Item_Id__c ='123456';
         pr.Core_Product_Type__c = 'Intel® FPGAs';
         pr.Core_Product_Org__c = 'Sales';
        pr.isActive = true;
        insert pr;
        List<String> prodList1 = new List<String>();
         prodList1.add(pr1.Core_OPN__c);
         prodList1.add(pr.Core_OPN__c);
         
        Core_PIR_Ext_Attributes__c PIRRecord = new Core_PIR_Ext_Attributes__c();
        PIRRecord.Core_Processing_Status__c='Pending';
        PIRRecord.Core_Part__c='1234';
        PIRRecord.Core_Component_Product_Class__c='IC';
        PIRRecord.Core_Signal_code__c='HB';
               
        insert PIRRecord;
        
        Core_PIR_Ext_Attributes__c PIRRecord2 = new Core_PIR_Ext_Attributes__c();
        PIRRecord2.Core_Processing_Status__c='Pending';
        PIRRecord2.Core_Part__c='123411';
        PIRRecord2.Core_Component_Product_Class__c='IC';
        PIRRecord2.Core_Signal_code__c='HB';
        insert PIRRecord2;
        
        Core_PIR_Ext_Attributes__c PIRRecord3 = new Core_PIR_Ext_Attributes__c();
        PIRRecord3.Core_Processing_Status__c='Pending';
        PIRRecord3.Core_Part__c='1234'; 
        PIRRecord3.Core_Component_Product_Class__c='IC';
        PIRRecord3.Core_Signal_code__c='HB';
        insert PIRRecord3;
         
             
         Test.startTest();

            Core_PSG_ProcessSignalCodeFromStaging obj = new Core_PSG_ProcessSignalCodeFromStaging();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
         
     }*/
}