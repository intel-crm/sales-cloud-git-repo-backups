/******************************************************************************************************************************************
Class Name  : ER_SearchCMFService
Test Class Name : ER_SearchCMFService_Test, Coverage:93%
Version     : 1.0 
Created Date: 15 Nov 2023
Function    : Utility class to handle email delivery logic, Email logs creation.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Hemant                 15/11/2023              Original version 
*****************************************************************************************************************************************/
@IsTest
public class ER_SearchCMFService_Test {
    @testSetUp
    public static void setupRecord(){
        List<ER_Customer_Master_File_Group__c> cmfGroupList= new List<ER_Customer_Master_File_Group__c>();
        for(Integer i=0; i<5;i++){
            ER_Customer_Master_File_Group__c cmfGroup= new ER_Customer_Master_File_Group__c();
            cmfGroup.Name= 'testName'+i;
            cmfGroupList.add(cmfGroup);
        }
        Database.Insert(cmfGroupList);
        ER_Customer_Master_File__c cmf= new ER_Customer_Master_File__c();
        cmf.Name='testCmfName';
        cmf.ER_CMF_Name__c='testCMF';
        cmf.ER_Sales_Disti_Chnl_Code__c='EU02';
        Database.Insert(cmf);
        List<ER_CMFGroupAssociation__c> cmfAssocList = new  List<ER_CMFGroupAssociation__c>();
        for(ER_Customer_Master_File_Group__c cmfgroup:cmfGroupList){
            ER_CMFGroupAssociation__c cmfAssoc= new ER_CMFGroupAssociation__c();
            cmfAssoc.ER_Customer_Master_File__c=cmf.Id;
           cmfAssoc.ER_Customer_Master_File_Group__c=cmfgroup.Id;
            cmfAssocList.add(cmfAssoc);
        }
        Database.Insert(cmfAssocList);
    }
    @IsTest
    public static void getCMFTest(){
        ER_Customer_Master_File_Group__c cmfGroup=[Select Name from ER_Customer_Master_File_Group__c where Name='testName0' Limit 1];
        List<ER_SearchCMFService.RequestCMFModel> input=new List<ER_SearchCMFService.RequestCMFModel>();
        ER_SearchCMFService.RequestCMFModel reqCMFModel= new ER_SearchCMFService.RequestCMFModel();
        reqCMFModel.cmfId='6000001486';
        reqCMFModel.cmfName='OTCTAXEMEA SH 17';
        reqCMFModel.salesOrgCode='EU02';
        reqCMFModel.salesDistiChannelCode='02';
        reqCMFModel.pageFirstRec=0;
        input.add(reqCMFModel);
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Call the method to test
        Test.startTest();
        Object result = ER_SearchCMFService.getCMF(cmfGroup.id, input);
        //System.assertNotEquals(null, result, 'Result should not be null');
        Test.stopTest();
        // Perform assertions on the result
        // System.assertNotEquals(null, result, 'Result should not be null');
    }
    @IsTest
    public static void saveCMFDataTest(){
        ER_Customer_Master_File_Group__c cmfGroup=[Select Name from ER_Customer_Master_File_Group__c where Name='testName0' Limit 1];
        List<ER_SearchCMFService.JsonParser> input=new  List<ER_SearchCMFService.JsonParser>();
        ER_SearchCMFService.JsonParser reqCMFModel= new ER_SearchCMFService.JsonParser();
            reqCMFModel.DirectCustomerProfileId = '0000110127';
            reqCMFModel.DirectCustomerProfileTrimId = '110127';
            reqCMFModel.DirectCustomerProfileNm = 'EASTRONICS LIMITED';
            reqCMFModel.NielsenId = '';
            reqCMFModel.DistributionChannelCd ='02';
            reqCMFModel.DistributionChannelNm ='Industrial Disti';
            reqCMFModel.SalesOfficeCd = '0008';
            reqCMFModel.SalesOfficeNm ='MMEAR';
            reqCMFModel.DivisionCd = '01';
            reqCMFModel.GeographyCd = 'ASMO';
            reqCMFModel.SalesGroupCd ='041';
            reqCMFModel.SalesGroupNm = 'Israel';
            reqCMFModel.SalesOrganizationCd = 'EU01';
            reqCMFModel.SalesOrganizationGroupCd = 'EU';
            reqCMFModel.DirectCustomerRevenueReportingClassificationCd = 'E6';
            reqCMFModel.DirectCustomerRevenueReportingClassificationNm = 'EASTRONICS';
            reqCMFModel.CustomerSupplyAllocationClassificationCd = '626';
            reqCMFModel.CustomerSupplyAllocationClassificationNm = 'CEG DISTIS (626)';
            reqCMFModel.CustomerGroupTwoCd = 'W50';
            reqCMFModel.CustomerGroupThreeCd = '';
            reqCMFModel.CustomerGroupFourCd = '';
            reqCMFModel.CustomerGroupFiveCd = '';
            reqCMFModel.PartnerCustomerProfileId = '0000110127';
            reqCMFModel.DirectCustomerRelationshipFunctionalRoleCd = 'AG';
            reqCMFModel.DirectCustomerRelationshipFunctionalRoleNm ='Sold-to party';
            reqCMFModel.DirectCustomerPriceGroupCd = '';
            reqCMFModel.DirectCustomerRoleCd = '0001';
            reqCMFModel.CentralDeleteInd = 'N';
            reqCMFModel.EnglishPhysicalStreetAddressLine3 = 'C/O NEWTRONIX SYSTEM INC.';
            reqCMFModel.EnglishPhysicalStreetAddressLine4 = 'TEST';
            reqCMFModel.CustomerCentralOrderBlockCd = null;
            reqCMFModel.CustomerCentralBillingBlockCd = null;
            reqCMFModel.CustomerCentralDeliveryBlockCd = null;
            reqCMFModel.DirectCustomerBusinessRoutingCd = '';
            reqCMFModel.DirectCustomerBusinessRoutingNm = 'Rest of Intel';
            reqCMFModel.IntelUltimateBusinessPartyId= '';
            reqCMFModel.SalesAreaOrderBlockCd = null;
            reqCMFModel.SalesAreaOrderBlockNm = null;
            reqCMFModel.SalesAreaBillingBlockCd = null;
            reqCMFModel.SalesAreaBillingBlockNm = null;
            reqCMFModel.SalesAreaDeliveryBlockCd = null;
            reqCMFModel.SalesAreaDeliveryBlockNm = null;
            reqCMFModel.SalesAreaSalesBlockInd = 'N';
            reqCMFModel.CountryCd = 'BR';
            reqCMFModel.CountryNm = 'Brazil';
            reqCMFModel.CityNm = 'Plainview';
            reqCMFModel.PostalCd = '';
            reqCMFModel.CountrySubdivisionCd = 'BR';
            reqCMFModel.CountrySubdivisionNm = 'BRAZIL';
            reqCMFModel.PhysicalStreetAddressTxt = '151 Fairchild Ave1';
            reqCMFModel.PhysicalAddressCareOfNm = 'TEST';
            reqCMFModel.PaymentTermCd = 'AB';
            reqCMFModel.CurrencyCd = 'USD';
            reqCMFModel.InternationalCommerceTermCd = 'CIP';
            reqCMFModel.InternationalCommerceTermCd2 = 'PORT OF ENTRY';
            reqCMFModel.DirectCustomerCategoryCd = '';
            reqCMFModel.DirectCustomerKeywordTxt = 'EASTRONICS';
            reqCMFModel.CreateAgentId = 'CM_ADMIN';
            reqCMFModel.CreateDtm = '2007-11-06T00:00:00';
            reqCMFModel.ChangeAgentId = '';
            reqCMFModel.ChangeDtm ='2023-07-03T11:01:33';
        
        
        input.add(reqCMFModel);
        ER_SearchCMFService.saveCMFData(String.valueOf(cmfGroup.Id), input);
    }
    
    // Inner class to mock HTTP response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"elements": "response"}');
            res.setStatusCode(200);
            return res;
        }
    }
}