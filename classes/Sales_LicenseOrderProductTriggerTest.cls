/*********************************************************************************************************************
Test Class Name    	: Sales_LicenseOrderProductTriggerTest
Version       		: 1.0
Created Date  		: Jul 2021

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        July 2021             	Test Class for Sales_LicenseOrderProductTriggerUtility
* *********************************************************************************************************************/
@isTest
public class Sales_LicenseOrderProductTriggerTest {
	
    /******************************
* Developer Name : Shivam Vishwakarma
* Test method: updateExpiryDate_Test - Test method for Apex Class.MethodName -> Sales_LicenseOrderProductTriggerUtility.updateExpiryDate
* ****************************/
    @isTest static void updateExpiryDate_Test(){
        String errMsg = '';
        //Test Setup   
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord();    
       	insert lic1;
        Sales_License_Order_Product__c licOP1 = Sales_TestDataFactory.createLicenseOrderProductRecord();
        licOP1.Sales_License__c = lic1.Id;
        System.Test.startTest();
        try{
           insert licOP1;
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
        
    }
    
}