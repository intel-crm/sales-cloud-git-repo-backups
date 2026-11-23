/********************************************************************************************************************************************************************
* Class Name  : MarketplaceProductDetailsControllerTest 
* Version     : 1.0 
* Created Date: 06-13-2019
* Modification Log :
*
* Developer                           Date             Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Raj                   06/13/2019           Method 'getOfferingDetailsTest' to test getOfferingDetails method of MarketplaceProductDetailsController class
********************************************************************************************************************************************************************/
@isTest
public class MarketplaceProductDetailsControllerTest {
	
    @isTest
    static void getOfferingDetailsTest(){
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        PMP_TestDataUtility.getPMPOfferingCategory(off1.Id);
        PMP_TestDataUtility.getPMPOfferingSpecification(off1.Id);
        String offeringDetails = MarketplaceProductDetailsController.getOfferingDetails(off1.Id);
        Map<String,Object> offDetails = (Map<String, Object>)JSON.deserializeUntyped(offeringDetails);
        
        Map<String,Object> off = (Map<String,Object>)offDetails.get('OfferingDetail');
        System.assertEquals(off1.Name, off.get('Name'));
		
    }
}