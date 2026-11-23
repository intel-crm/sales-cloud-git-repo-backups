/******************************************************************************************************************************************************************************************************
* Class Name  : IPA_MarqueeMarketplaceController_Test
* Version     : 1.0 
* Created Date: 27th Jul, 2019
* Modification Log :
* Developer                             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Raj Yadav                            07/27/2019               Test class for IPA_MarqueeMarketplaceController.
******************************************************************************************************************************************************************************************************/
@isTest
public class IPA_MarqueeMarketplaceController_Test {

    static testMethod void getBaseUrlForLaunguageCodePositiveTest(){
        Test.startTest();
        String url = IPA_MarqueeMarketplaceController.getBaseUrlForLaunguageCode('Fr_fr',null);
        List<PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt> urlRecords = (List<PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt>)JSON.deserialize(url, List<PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt>.class);
        Test.stopTest();
        System.assertNotEquals(urlRecords[0].BaseURL__c, Null);
    }
    
    static testMethod void getBaseUrlForLaunguageCodeNegativeTest(){
        Test.startTest();
        String url = IPA_MarqueeMarketplaceController.getBaseUrlForLaunguageCode(null,null);
        List<PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt> urlRecords = (List<PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt>)JSON.deserialize(url, List<PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt>.class);
         Test.stopTest();
        System.assertNotEquals(urlRecords[0].BaseURL__c, Null);
    }

    @isTest
    static void getBaseUrlForUrlLangCode(){
        Test.startTest();
        String url = IPA_MarqueeMarketplaceController.getBaseUrlForLaunguageCode(null,'Fr_fr');
		List<PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt> urlRecords = (List<PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt>)JSON.deserialize(url, List<PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt>.class);
        Test.stopTest();
        System.assertNotEquals(urlRecords[0].BaseURL__c, Null);        
    }


	/*static testMethod void testGetCallOutDetails (){
        Test.startTest();
        List<PMP_CallOut_Details__mdt> call = new List<PMP_CallOut_Details__mdt>(IPA_MarqueeMarketplaceController.getCallOutDetails());
        PMP_CallOut_Details__mdt callOutList = [SELECT Id, DeveloperName,MasterLabel FROM PMP_CallOut_Details__mdt
												WHERE DeveloperName Like 'Coveo%' LIMIT 1];
		Test.stopTest();
		System.assert(callOutList != null);
    }*/
}