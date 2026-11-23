@isTest
global class Core_IQR_UpdateProductsTest {
@testSetup static void setup(){

		Product2 product2Obj = new Product2 (
			Core_Product_Name_EPM_ID__c = 'test value', 
			Core_Product_Org__c ='Sales', 
			Core_Sales_Visible_Flag__c = TRUE, 
			Core_Max_TDP__c = 'test value', 
			Core_CoreCount__c = 'test value', 
			Name = 'test value'
		);
		insert product2Obj;
		 
	}

	@isTest static void testMethod1() {
		// code_block	
	}

	@isTest static void testMethod2() {
		// code_block	
	}
}