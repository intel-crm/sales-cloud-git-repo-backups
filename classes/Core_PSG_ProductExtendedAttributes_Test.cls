@isTest
public class Core_PSG_ProductExtendedAttributes_Test {
    @isTest static void insertProduct(){
        test.startTest();
        Product2 product5 = new Product2();
        product5.Name='testProduct';
        product5.Core_Item_Class_Nm__c = 'IC';
        product5.Core_Item_Signal_Cd__c='';
        insert product5;
        
        Core_Product_Ext_Attribute__c extendedAttribute = new Core_Product_Ext_Attribute__c();
        extendedAttribute.Core_Product_Id__c=product5.id;
        extendedAttribute.Core_Prod_Tool_Type_Nm__c='BASE';
        extendedAttribute.Core_SW_Lic_Type_Nm__c='FIXED';
        extendedAttribute.Core_SW_Lic_Enforcement_Method_Nm__c='File';
        extendedAttribute.Core_SW_Prod_Web_Dsc__c='Desc';
        extendedAttribute.Core_SW_Prod_Max_Rehost_Cnt__c=0;
        extendedAttribute.Core_SW_Lic_File_Data_Encryption_Std_Cd__c='3DES';
        //extendedAttribute.Core_SW_Lic_Group_Id__c=lg.id;
        extendedAttribute.Core_SW_Lic_Generator_Parameter_Txt__c='-a';
        
        List<Core_Product_Ext_Attribute__c> extendedAttributeList = new List<Core_Product_Ext_Attribute__c>();
        extendedAttributeList.add(extendedAttribute);
        
        insert extendedAttribute;
        
        test.stopTest(); 
    }
    
}