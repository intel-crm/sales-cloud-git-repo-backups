/**************************************************************************************
Apex Class Name:  core_OpportunitySupportStatus_Test
Version     : 1.0 
Created Date: 1 August 2023
Function    : Test Class for the core_OpportunitySupportStatus
Modification Log :
* Developer           Date               Description
* ----------------------------------------------------------------------------            
* Hira Khan        Aug 1st, 2023        Original Version
*************************************************************************************/
@isTest
public class core_OpportunitySupportStatus_Test {
 	
    @testSetup
    static void prepareCustomSetting(){
        Account acct = new Account(Name = 'TestDE', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(), Core_Account_Type__c='End Customer');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1),Opportunity_Focus__c='Core',Core_Opportunity_Type__c ='Deal: Sell-through');
        
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
            Core_Opportunity_Forecast__c oSA= new Core_Opportunity_Forecast__c();
            oSA.Core_Opportunity__c = opps.id;
            oSA.Core_Forecast_Quarter__c ='Q4 2023';
            oSA.Core_Forecast__c = 'Commit';
            oSA.Core_Read_Only__c = false;
            insert oSA;

        }
    }

    static testMethod void testSeedsHttpResponseTest1(){                
        List<Core_System_Credentials__c> sysCredList = new List<Core_System_Credentials__c>();
        Core_System_Credentials__c sysCred = new Core_System_Credentials__c();
        sysCred = new Core_System_Credentials__c();
        sysCred.Name = 'Demo Depot Service';
        sysCred.Core_End_Point_URL__c = 'https://eip-crm-seeds.cloudhub.io.dummy/api/seeds';
        sysCredList.add(sysCred);
        insert sysCredList;

        Test.startTest();
        Opportunity oppsidtest = [Select id from Opportunity where Name='Opportunity to Lose 03-24-2015'];
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpResponseGenerator());
        core_OpportunitySupportStatusController.pullSeedsSamples(oppsidtest.Id);  
        System.assertEquals(1, [SELECT COUNT() FROM Core_Opportunity_Forecast__c], 'Expected one Core_Opportunity_Forecast__c record to be inserted.');
        test.stopTest();
    }
    static testMethod void testSamplesHttpResponseTest2(){                
        List<Core_System_Credentials__c> sysCredList = new List<Core_System_Credentials__c>();
        Core_System_Credentials__c sysCred = new Core_System_Credentials__c();
        sysCred = new Core_System_Credentials__c();
        sysCred.Name = 'My Samples Service';
        sysCred.Core_End_Point_URL__c = 'https://eip-crm-proxy.cloudhub.io.dummy/smit/api/eip-crm-sls-sf2mysamples';
        sysCredList.add(sysCred);
        insert sysCredList;

        Test.startTest();
        Opportunity oppsidtest = [Select id from Opportunity where Name='Opportunity to Lose 03-24-2015'];
        System.assertEquals(1, [SELECT COUNT() FROM Opportunity], 'Expected one Opportunity record to be inserted.');
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpResponseGenerator());
        core_OpportunitySupportStatusController.pullSeedsSamples(oppsidtest.Id);        
        test.stopTest();
    }
    static testMethod void testSeedFilter(){
        //Create Seeds Wrapper 
        Opportunity oppId = [Select id,AccountId from Opportunity limit 1];
        List<core_OpportunitySupportStatusController.SeedWebserviceWrapper> lstSeeds = new List<core_OpportunitySupportStatusController.SeedWebserviceWrapper>();
        core_OpportunitySupportStatusController.SeedWebserviceWrapper testSeed = new core_OpportunitySupportStatusController.SeedWebserviceWrapper();
		testSeed.AccountID =oppId.AccountId;
        testSeed.OpportunityID =oppId.id;
        testSeed.OrderNumber =149983;
        testSeed.ProductName= 'Cable Kit OCuLink* 2U 8 Port Switch #1[MM# 958268]';
        testSeed.EstimatedShipDate = '2023-07-10T18:30:00';
        testSeed.RequestedDeliveryDate = '2023-07-13T18:30:00';
        testSeed.LineItemStatus = 'InProgress';
        testSeed.ReturnPickupDate = '2023-07-15T18:30:00';
        testSeed.Requestor = 'GMARUTHX';
        testSeed.RequestedQty = 2;
        testSeed.AccountName = 'TestAccount';
        testSeed.OpportunityName='TestOpps';
        lstSeeds.add(testSeed);
        
        //Create Seeds Search String Array
        list<String> SearchArry = new list<String>();
        SearchArry.add('149983');
        SearchArry.add('Cable Kit OCuLink* 2U 8 Port Switch #1[MM# 958268]');
        SearchArry.add('2023-07-10T18:30:00');
        SearchArry.add('2023-07-13T18:30:00');
        SearchArry.add('InProgress');
        SearchArry.add('2023-07-15T18:30:00');
        SearchArry.add('GMARUTHX');
        SearchArry.add('2');
        SearchArry.add('TestAccount');
        SearchArry.add('TestOpps');
       //Call filter Seeds method
       System.assert(!SearchArry.isEmpty(),'Seeds list should not be empty');
       System.assert(!lstSeeds.isEmpty(),'Seeds Wrapper list should not be empty');
        core_OpportunitySupportStatusController.filterSeeds(SearchArry,lstSeeds);
    }
        static testMethod void testSeedFilterWithEmptySerach(){
        //Create Seeds Wrapper 
        Opportunity oppId = [Select id,AccountId from Opportunity limit 1];
        List<core_OpportunitySupportStatusController.SeedWebserviceWrapper> lstSeeds = new List<core_OpportunitySupportStatusController.SeedWebserviceWrapper>();
        core_OpportunitySupportStatusController.SeedWebserviceWrapper testSeed = new core_OpportunitySupportStatusController.SeedWebserviceWrapper();
       
		testSeed.AccountID =oppId.AccountId;
        testSeed.OpportunityID =oppId.id;
        testSeed.OrderNumber =149983;
        testSeed.ProductName= 'Cable Kit OCuLink* 2U 8 Port Switch #1[MM# 958268]';
        testSeed.EstimatedShipDate = '2023-07-10T18:30:00';
        testSeed.RequestedDeliveryDate = '2023-07-13T18:30:00';
        testSeed.LineItemStatus = 'InProgress';
        testSeed.ReturnPickupDate = '2023-07-15T18:30:00';
        testSeed.Requestor = 'GMARUTHX';
        testSeed.RequestedQty = 2;
        testSeed.AccountName = 'TestAccount';
        testSeed.OpportunityName='TestOpps';
        lstSeeds.add(testSeed);
        
        //Create Seeds Search String Array
        list<String> SearchArry = new list<String>();
        SearchArry.add('');
        SearchArry.add('');
        SearchArry.add('');
        SearchArry.add('');
        SearchArry.add('');
        SearchArry.add('');
        SearchArry.add('');
        SearchArry.add('');
        SearchArry.add('');
        SearchArry.add('');
       //Call filter Seeds method
       System.assert(!SearchArry.isEmpty(),'Seeds list should not be empty');
       System.assert(!lstSeeds.isEmpty(),'Seeds Wrapper list should not be empty');
       core_OpportunitySupportStatusController.filterSeeds(SearchArry,lstSeeds);
    }
    static testMethod void testfilterSamples(){
        
        List<core_OpportunitySupportStatusController.SampleWebserviceWrapper> lstSamples = new List<core_OpportunitySupportStatusController.SampleWebserviceWrapper>();
        //Create Sample Wrapper
        core_OpportunitySupportStatusController.SampleWebserviceWrapper testSamples = new core_OpportunitySupportStatusController.SampleWebserviceWrapper();
        testSamples.RequestProductID='2275';
        testSamples.RequestID='1823';
        testSamples.Line='100';
        testSamples.RequestedEPMName='Intel Portable Cache Module (battery back-up unit) with 256MB DDR2 ECC - single pack';
        testSamples.RDD='2015-07-20 00:00:00';
        testSamples.Status='Requested';
        testSamples.Requester='DAVID A HOOD';
        testSamples.RequestQty='5';
        testSamples.ApprovedQty='0';
        testSamples.GridViewAccountName='TestAccout';
        testSamples.GridViewOpportunityName='TestOpps';
        testSamples.GridViewOpportunityStage='Define';
        testSamples.ApproverName='TestApprover';
        lstSamples.add(testSamples);
        //Create Search String list.
        List<String> searchlst = new List<String>();
        searchlst.add('1823');
        searchlst.add('100');
        searchlst.add('Intel Portable Cache Module (battery back-up unit) with 256MB DDR2 ECC - single pack');
        searchlst.add('2015-07-20 00:00:00');
        searchlst.add('Requested');
        searchlst.add('DAVID A HOOD');
        searchlst.add('5');
        searchlst.add('0');
        searchlst.add('TestAccout');
        searchlst.add('TestOpps');
        searchlst.add('Define');
        searchlst.add('TestApprover');
        //Call Filter Samples
        System.assert(!searchlst.isEmpty(),'String list should not be empty');
        System.assert(!lstSamples.isEmpty(),'Sample Wrapper list should not be empty');
        core_OpportunitySupportStatusController.filterSamples(searchlst, lstSamples);
    }

    static testMethod void testfilterSamplesEmptySearch(){
        
        List<core_OpportunitySupportStatusController.SampleWebserviceWrapper> lstSamples = new List<core_OpportunitySupportStatusController.SampleWebserviceWrapper>();
        //Create Sample Wrapper
        core_OpportunitySupportStatusController.SampleWebserviceWrapper testSamples = new core_OpportunitySupportStatusController.SampleWebserviceWrapper();
        testSamples.RequestProductID='2275';
        testSamples.RequestID='1823';
        testSamples.Line='100';
        testSamples.RequestedEPMName='Intel Portable Cache Module (battery back-up unit) with 256MB DDR2 ECC - single pack';
        testSamples.RDD='2015-07-20 00:00:00';
        testSamples.Status='Requested';
        testSamples.Requester='DAVID A HOOD';
        testSamples.RequestQty='5';
        testSamples.ApprovedQty='0';
        testSamples.GridViewAccountName='TestAccout';
        testSamples.GridViewOpportunityName='TestOpps';
        testSamples.GridViewOpportunityStage='Define';
        testSamples.ApproverName='TestApprover';
        testSamples.OBO = 'test OBO';
        testSamples.ApproverEmail = 'test@test.com';
        testSamples.Socket = 'test Socket';
        testSamples.Media = 'testMedia';
        testSamples.Stepping = 'testStepping';
        testSamples.QDF = 'testQDF';
        testSamples.BoxQuantity = '4';
        testSamples.CustomerName = 'testCustomerName';
        testSamples.CustomerCMFID = 'testCustomerCMFID';
        testSamples.ShiptoCustomerName = 'testShiptoCustomerName';
        testSamples.ShipToCustomerCMFID = 'testShipToCustomerCMFID';
        testSamples.StreetAddress1 = 'testStreetAddress1';
        testSamples.StreetAddress2 = 'testStreetAddress2';
        testSamples.City = 'testCity';
        testSamples.StateName = 'testStateName';
        testSamples.ZipCode = 'testZipCode';
        testSamples.Country = 'testCountry';
        testSamples.ActualShipDtm = 'testActualShipDtm';
        testSamples.TrackingIdForCarrier1Txt = 'testTrackingIdForCarrier1Txt';
        testSamples.TrackingIdForCarrier2Txt = 'testTrackingIdForCarrier2Txty';
        testSamples.ApprovedEPMName = 'testApprovedEPMName';
        testSamples.ApprovedMM = 'testApprovedMM';
        testSamples.RequestedMM = 'testRequestedMM';    
        
        
        core_OpportunitySupportStatusController.SampleOpportunityAssociation  smpleOppAssociation = new core_OpportunitySupportStatusController.SampleOpportunityAssociation();
        smpleOppAssociation.AccountId = 'test AccountId';
        smpleOppAssociation.AccountName = 'test AccountName';
        smpleOppAssociation.AccountCIMID = 'test AccountCIMID';
        smpleOppAssociation.OpportunityId = 'test OpportunityId';
        smpleOppAssociation.OpportunityName = 'test OpportunityName';
        smpleOppAssociation.OpportunityStage = 'test OpportunityStage';
        lstSamples.add(testSamples);
        //Create Search String list.
        List<String> searchlst = new List<String>();
        searchlst.add('');
        searchlst.add('');
        searchlst.add('');
        searchlst.add('');
        searchlst.add('');
        searchlst.add('');
        searchlst.add('');
        searchlst.add('');
        searchlst.add('');
        searchlst.add('');
        searchlst.add('');
        searchlst.add('');
        //Call Filter Samples
        System.assert(!searchlst.isEmpty(),'String list should not be empty');
        System.assert(!lstSamples.isEmpty(),'Sample Wrapper list should not be empty');
        core_OpportunitySupportStatusController.filterSamples(searchlst, lstSamples);
        
    }

}