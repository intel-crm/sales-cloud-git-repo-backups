/*********************************************************************************************************************
Class Name    : Sales_CreateOptionProdEvalutionLicTest
Created By 	  : Srishty Sharma 
Created Date  : July 2021
Function      : Test Class For Sales_CreateOptionProdEvalutionLicCtrl

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           17-July-2021             Test Class For Sales_CreateOptionProdEvalutionLicCtrl
* *********************************************************************************************************************/
@isTest
public class Sales_CreateOptionProdEvalutionLicTest {
    @isTest
    private static void testGetProductOption(){
        String dummyProductId = Sales_TestDataFactory.getFakeId(Product2.SObjectType);
        Test.startTest();
        List<SBQQ__ProductOption__c> returnedList = Sales_CreateOptionProdEvalutionLicCtrl.getOptnProdList(dummyProductId);
        Test.stopTest();
        System.assertEquals(0, returnedList.size(), 'Size should be zero as no test data is present');
    }
}