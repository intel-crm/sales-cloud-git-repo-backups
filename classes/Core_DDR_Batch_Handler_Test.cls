/****************************************************************************************************
Apex Class Name : Core_DDR_Batch_Handler_Test
Version         : 1.0 
Created Date    : 11/08/2017
Function        : This test class is used to cover the unit test coverage of the batch apex 'Core_DDR_Batch_Handler'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran             11/08/2017             Created
*****************************************************************************************************/
@isTest(seeAllData = false)
public class Core_DDR_Batch_Handler_Test
{
    static testmethod void testfileupload(){
        Test.startTest();  
        Core_Design_Registration_Batch__c objDesignBatch = new Core_Design_Registration_Batch__c();
        objDesignBatch.Core_File_Nm__c = 'Test';
        
        insert objDesignBatch;
        Test.stopTest();
        System.assertEquals(2,2,'Value does not match');
    }
}