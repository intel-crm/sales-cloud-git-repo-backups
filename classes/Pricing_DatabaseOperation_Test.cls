/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-18-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_DatabaseOperation_Test {
    static testmethod void testPerformDML(){
        List<String> lobValuesList = Label.Pricing_LOB_Values.split(',');
        Product2 prod = new Product2(Name='TestProduct',
                                     Core_Product_Org__c = 'Sales',
                                     Core_Product_Type__c = 'Processors',
                                     Core_Sales_Visible_Flag__c = true,
                                     Core_Hierarchy_ID__c = '43',
                                     Core_Line_of_Business__c = lobValuesList[0],
                                     Core_Processor_Number_Nm__c  = '6220',
                                     IsActive = true);
        Pricing_DatabaseOperation.performInsert(new List<SObject>{prod},true,false);
        Pricing_DatabaseOperation.performUpsert(new List<SObject>{prod},true,true);
        Pricing_DatabaseOperation.performUpdate(new List<SObject>{prod},true,false);
        Pricing_DatabaseOperation.performDelete(new List<SObject>{prod},true,false);
        System.assert(prod.id!=null);
    }
    
    static testmethod void testPerformDMLException(){
        List<String> lobValuesList = Label.Pricing_LOB_Values.split(',');
        Product2 prod = new Product2(Name='TestProduct',
                                     Core_Product_Org__c = 'Sales',
                                     Core_Product_Type__c = 'Processors',
                                     Core_Sales_Visible_Flag__c = true,
                                     Core_Hierarchy_ID__c = '43',
                                     Core_Line_of_Business__c = lobValuesList[0],
                                     Core_Processor_Number_Nm__c  = '6220',
                                     IsActive = true);
        Pricing_DatabaseOperation.performInsert(new List<SObject>{prod},true,null);
        Pricing_DatabaseOperation.performUpsert(new List<SObject>{prod},true,null);
        Product2 prod2 = new Product2( 
            						 Name='TestProduct',
                                     Core_Product_Org__c = 'Sales',
                                     Core_Product_Type__c = 'Processors',
                                     Core_Sales_Visible_Flag__c = true,
                                     Core_Hierarchy_ID__c = '43',
                                     Core_Line_of_Business__c = lobValuesList[0],
                                     Core_Processor_Number_Nm__c  = '6220',
                                     IsActive = true);
        Pricing_DatabaseOperation.performUpdate(new List<SObject>{prod2},true,null);
        Pricing_DatabaseOperation.performDelete(new List<SObject>{prod2},true,null);
        System.assert(prod2.id==null);
    }
}