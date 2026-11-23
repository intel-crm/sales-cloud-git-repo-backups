@isTest
public with sharing class Product_RetrieveProdDataTest {
    @isTest 
    static void testMethod1() {
		Product_RetrieveProdData.getProdData();
	}
	@isTest 
    static void testMethod2() {
        Product2 prodCopy = new Product2();
        prodCopy.Core_iPaaS_Load_ID__c = '273232332';
        prodCopy.Core_Unique_ID__c = '76787788';
        prodCopy.Core_Hierarchy_ID__c ='43';
        prodCopy.Core_Product_Org__c = 'Sales';
        prodCopy.Name = 'Dummy';
        insert prodCopy;
        test.startTest();
        Product_RetrieveProdData.getLastRefreshDate();
        test.stopTest();
	}
    @isTest 
    static void testMethod3() {
        Product_RetrieveProdData.getReportId();
	}
    @isTest 
    static void testMethod4() {
        Product_RetrieveProdData.hasPermissionSet();
	}
}