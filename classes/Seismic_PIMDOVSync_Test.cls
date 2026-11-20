/****************************************************************************************************************************************
* Class Name  : Seismic_PIMDOVSync_Test 
* Version     : 1.0 
* Created Date: 05/15/2023  
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            05/15/2023               		Apex Test Classes for entire Seismic_PIMDOVSync Inteface 
* Sandeep Joshi            09/04/2023               		Updated to address Seismic API changes 
*****************************************************************************************************************************************/

@isTest
private class Seismic_PIMDOVSync_Test {
        
    @isTest 
    static void initialize_Test() {
        //Test Data
        Seismic_PIM_Secrets__c config = new Seismic_PIM_Secrets__c(Name = 'Key', Value__c = 'Value');
        insert config;
        
        Test.startTest();
        
        Boolean flg = Seismic_PIMDOVSync.initialize();
        
        Test.stopTest();
        
        System.assertEquals(true, flg, 'Was expecting TRUE testInitialize');
    } 
        
    //Test method for Seismic_PIMResponseWrapper
    @isTest 
    static void Seismic_PIMResponseWrapper_Test() {
        Test.startTest();
        
        //Test Data
        Seismic_PIMDOVSync.config = new Map<String, String>();
        Seismic_PIMDOVSync.config.put('PIM_client_id','192ac5e8-e44f-42c3-8444-017ee3bcefc4');
        Seismic_PIMDOVSync.config.put('PIM_client_secret','0Lt8Q~HvzaXvAwLpKM78FiZ6F0m7eu70QoSCsaD6');
        Seismic_PIMDOVSync.config.put('PIM_Token_endPoint','https://apis-sandbox.intel.com/v1/auth/token');
        Seismic_PIMDOVSync.config.put('PIM_ContentHierarchy_endpoint','https://apis-sandbox.intel.com/pim/v1/services/synapticaLayer/hierarchies/10305');
          
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PIM_Token');
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        //Test Token Positive
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        String response = Seismic_PIMResponseWrapper.getPIMToken();
        System.assertNotEquals(null,response, 'The callout returned a null response. Seismic_PIMResponseWrapper.getPIMToken Positive Test');// Verify mock response is not null
        
        //Test Token Negative
        mock.setStatusCode(208);
        Test.setMock(HttpCalloutMock.class, mock);
        String response2 = Seismic_PIMResponseWrapper.getPIMToken();
        System.assertNotEquals(null,response2, 'The callout returned a null response. Seismic_PIMResponseWrapper.getPIMToken Negative Test');// Verify mock response is not null
        
        
        //Test Identify users
        //Create the mock response based on a static resource
        StaticResourceCalloutMock mock2 = new StaticResourceCalloutMock();
        mock2.setStaticResource('PIM_Response');
        mock2.setHeader('Content-Type', 'application/json;charset=UTF-8');
        mock2.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock2);
        List<Seismic_PIMResponseWrapper.Seismic_PIMCategory> result = Seismic_PIMResponseWrapper.getContentHierarchy('','');
        
        System.assertNotEquals(null,result, 'The callout returned a null response. getContentHierarchy' + result);// Verify response is not null
        //System.assertEquals(200,Seismic_PIMResponseWrapper.statusCode(), 'The status code is not 200. getContentHierarchy' + result.getStatusCode());// Verify status code is 200
        
        Seismic_PIMResponseWrapper.Seismic_PIMCategory cat = new Seismic_PIMResponseWrapper.Seismic_PIMCategory();
        cat.displayName = '';
        cat.guid = '';
        cat.intelLabel = '';
        cat.taggingPath = '';
        
        Test.stopTest();
    }     
    
    //Test method for Seismic_CustomPropertiesResponseWrapper
    @isTest 
    static void Seismic_CustomPropertiesResponseWrapper_Test() {
        Test.startTest();
        //Test Data
        Seismic_PIMDOVSync.config = new Map<String, String>();
        Seismic_PIMDOVSync.config.put('Seismic_client_id','bfbabaaa-d71a-48e5-8679-e7a6b8d9fa9a');
        Seismic_PIMDOVSync.config.put('Seismic_client_secret','b0ba2a35-6ecf-4bdc-a63c-a8c2f3a658fa');
        Seismic_PIMDOVSync.config.put('Seismic_user_id','5600d223-ed35-48fb-8096-a1e78866426f');
        Seismic_PIMDOVSync.config.put('Seismic_Token_endPoint','https://auth.seismic.com/tenants/inteldev/connect/token');
        Seismic_PIMDOVSync.config.put('Seismic_CustomProperties_endPoint','https://api.seismic.com/custom-property/v1/customProperties');
        Seismic_PIMDOVSync.config.put('IsTest','False');
        
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Seismic_Token');
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        //Test Token Positive
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        String response = Seismic_CustomPropertiesResponseWrapper.getSeismicToken();
        System.assertNotEquals(null,response, 'The callout returned a null response. Seismic_CustomPropertiesResponseWrapper.getSeismicToken Positive Test');// Verify mock response is not null
        
        //Test Token Negative
        mock.setStatusCode(208);
        Test.setMock(HttpCalloutMock.class, mock);
        String response2 = Seismic_CustomPropertiesResponseWrapper.getSeismicToken();
        System.assertNotEquals(null,response2, 'The callout returned a null response. Seismic_CustomPropertiesResponseWrapper.getSeismicToken Negative Test');// Verify mock response is not null
        
        //Test Identify users
        //Create the mock response based on a static resource
        StaticResourceCalloutMock mock2 = new StaticResourceCalloutMock();
        mock2.setStaticResource('Seismic_CustomPro_Response');
        mock2.setHeader('Content-Type', 'application/json;charset=UTF-8');
        mock2.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock2);
        Seismic_CustomPropertiesResponseWrapper result = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperties('');
        System.assertNotEquals(null,result, 'The callout returned a null response. getSeismicCustomProperties' + result);// Verify response is not null
        
        //Create the mock response based on a static resource
        StaticResourceCalloutMock mock3 = new StaticResourceCalloutMock();
        mock3.setStaticResource('Seismic_CustomPro_Response2');
        mock3.setHeader('Content-Type', 'application/json;charset=UTF-8');
        mock3.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock3);
        Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem result2 = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty('','');
        System.assertNotEquals(null,result2, 'The callout returned a null response. getSeismicCustomProperties' + result2);// Verify response is not null
        
        //Create the mock response based on a static resource
        Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem customPropertyItem;
        StaticResourceCalloutMock mock4 = new StaticResourceCalloutMock();
        mock4.setStaticResource('Seismic_CustomPro_Response2');
        mock4.setHeader('Content-Type', 'application/json;charset=UTF-8');
        mock4.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock4);
        Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem result3 = Seismic_CustomPropertiesResponseWrapper.updateSeismicCustomProperty('','',customPropertyItem);
        System.assertNotEquals(null,result3, 'The callout returned a null response. getSeismicCustomProperties' + result3);// Verify response is not null
        
        Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem itm = new Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem();
        itm.id = '';
        itm.kind = '';
        itm.name = '';
        itm.propertyType = '';
        itm.order = 0;
        itm.propertyHint = '';
        itm.lastUpdateUserId = '';
        itm.lastUpdateDateTime = '';
        itm.tenantId = '';
        itm.etag = '';
        itm.timestamp = '';
        itm.domainOfValues = null;
        itm.settings = null;
        itm.scopes = null;
        itm.teamSites = null; 
        
        Seismic_CustomPropertiesResponseWrapper wrapper = new Seismic_CustomPropertiesResponseWrapper();
        wrapper.continuationToken = '';
        wrapper.cursor = '';
        wrapper.kind = '';
        wrapper.count = 0;
        wrapper.totalCount = 0;
        wrapper.items = null;
        
        Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertySettings st = new Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertySettings();
        st.editability = '';
        st.IsSearchable = false;
        st.searchFacetOrder = 0;
        st.showInDocCenter = false;
        st.showInDocCenterFilter = false;
        st.showInFilter = false;
        st.suggestionsEnabled = false;
        
        Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV dv = new Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV();
        dv.id = '';
        dv.value = '';
        dv.order = 0;
        
        //System.assertEquals(200,Seismic_PIMResponseWrapper.statusCode(), 'The status code is not 200. getContentHierarchy' + result.getStatusCode());// Verify status code is 200
        Test.stopTest();
    }   
    
    //Test method for Seismic_PIMDOVSync
    @isTest 
    static void Seismic_PIMDOVSync_Test() {
        Test.startTest();
        
        //Test Data
        Seismic_PIMDOVSync.config = new Map<String, String>();
        Seismic_PIMDOVSync.config.put('PIM_client_id','192ac5e8-e44f-42c3-8444-017ee3bcefc4');
        Seismic_PIMDOVSync.config.put('PIM_client_secret','0Lt8Q~HvzaXvAwLpKM78FiZ6F0m7eu70QoSCsaD6');
        Seismic_PIMDOVSync.config.put('PIM_Token_endPoint','https://apis-sandbox.intel.com/v1/auth/token');
        Seismic_PIMDOVSync.config.put('PIM_ContentHierarchy_endpoint','https://apis-sandbox.intel.com/pim/v1/services/synapticaLayer/hierarchies/10305');
        Seismic_PIMDOVSync.config.put('Seismic_client_id','bfbabaaa-d71a-48e5-8679-e7a6b8d9fa9a');
        Seismic_PIMDOVSync.config.put('Seismic_client_secret','b0ba2a35-6ecf-4bdc-a63c-a8c2f3a658fa');
        Seismic_PIMDOVSync.config.put('Seismic_user_id','5600d223-ed35-48fb-8096-a1e78866426f');
        Seismic_PIMDOVSync.config.put('Seismic_Token_endPoint','https://auth.seismic.com/tenants/inteldev/connect/token');
        Seismic_PIMDOVSync.config.put('Seismic_CustomProperties_endPoint','https://api.seismic.com/custom-property/v1/customProperties');
        Seismic_PIMDOVSync.config.put('IsTest','True');
        
        //Create the mock response based on a static resource
        StaticResourceCalloutMock mock3 = new StaticResourceCalloutMock();
        mock3.setStaticResource('Seismic_CustomPro_Response2');
        mock3.setHeader('Content-Type', 'application/json;charset=UTF-8');
        mock3.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock3);
        Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem result2 = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty('10305','10305');
        System.assertNotEquals(null,result2, 'The callout returned a null response. getSeismicCustomProperties' + result2);// Verify response is not null
        
        StaticResourceCalloutMock mock2 = new StaticResourceCalloutMock();
        mock2.setStaticResource('PIM_Response');
        mock2.setHeader('Content-Type', 'application/json;charset=UTF-8');
        mock2.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock2);
        Seismic_PIMDOVSync.listHierarchy = Seismic_PIMResponseWrapper.getContentHierarchy('10305','10305');
        System.assertNotEquals(null, Seismic_PIMDOVSync.listHierarchy, 'The callout returned a null response. getContentHierarchy' +  Seismic_PIMDOVSync.listHierarchy);// Verify response is not null
        
    	Seismic_PIMDOVSync.listHierarchy = new List<Seismic_PIMResponseWrapper.Seismic_PIMCategory>();
        Seismic_PIMResponseWrapper.Seismic_PIMCategory cat = new Seismic_PIMResponseWrapper.Seismic_PIMCategory();
        cat.displayName = 'AMD';
        cat.guid = 'etm-2c87bb974b0b4a2bba5503c95a3cd723';
        cat.intelLabel = 'AMD';
        cat.taggingPath = 'DAM Competition Products/AMD';
        Seismic_PIMDOVSync.listHierarchy.add(cat);
        
        Seismic_PIMResponseWrapper.Seismic_PIMCategory cat2 = new Seismic_PIMResponseWrapper.Seismic_PIMCategory();
        cat2.displayName = 'DesktopX';
        cat2.guid = 'etm-e4f6d07a61b045aa91e68d3342315746';
        cat2.intelLabel = 'DesktopX';
        cat2.taggingPath = 'DAM Competition Products/DesktopX';
        Seismic_PIMDOVSync.listHierarchy.add(cat2);
        
        Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV dvd = new Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV();
        dvd.id = '';
        dvd.value = '';
        dvd.order = 0;
        
        List<Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV> dvs = new List<Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV>();
        dvs.add(dvd);
        Seismic_PIMDOVSync.listCustomProperty.domainOfValues = dvs;
        
             
        //'SELECT HierarchyID__c, Hierarchy_Name__c, Seismic_Name__c, L1__c, L2__c, L3__c, L4__c, L5__c, L1_ID__c, L2_ID__c, L3_ID__c, L4_ID__c, L5_ID__c FROM '
        Seismic_PIMConfig__c mconfig = new Seismic_PIMConfig__c(Key__c = 'Seismic_SDFC_SYNC', Value__c = 'True');
        insert mconfig;
        
        Seismic_PIMActiveHierarchy__c pim = new Seismic_PIMActiveHierarchy__c(HierarchyID__c = '1', Hierarchy_Name__c = 'Competitor Products', Seismic_Name__c = 'Competitor Products', L1_ID__c = 'fb317790-19ed-5699-959b-740907a4d419', L2_ID__c = 'fb317790-19ed-5699-959b-740907a4d419', L3_ID__c = 'fb317790-19ed-5699-959b-740907a4d419', L4_ID__c='fb317790-19ed-5699-959b-740907a4d419', L5_ID__c='fb317790-19ed-5699-959b-740907a4d419', Process__c = true);
        insert pim;
        
        Seismic_PIMDOVSync.main(); 
        
        Seismic_DOV__c dv = new Seismic_DOV__c(DOV_ID__c = 'fb317790-19ed-5699-959b-740907a4d419', Name = 'Desktop', PIM_GUID__c = 'etm-e4f6d07a61b045aa91e68d3342315746', Property_Name__c = 'Competitor Products L1');
        insert dv;
                
        Seismic_PIMDOVSync.main();        
        
        Test.stopTest();
    }     
   
    
    @isTest
    static void Seismic_PIMDOVSyncNotification_Test(){        
        Test.startTest();
        List<Seismic_PIMDOVSync.Seismic_DOVAction> dovActionList = new List<Seismic_PIMDOVSync.Seismic_DOVAction>();
        Seismic_PIMDOVSync.Seismic_DOVAction dov = new Seismic_PIMDOVSync.Seismic_DOVAction();
        dov.propertyName = '';
        dov.dovName = '';
        dov.action = '';
        dovActionList.add(dov);
        Seismic_PIMDOVSync_Notification.sendSummary(dovActionList, 'Test Exception Block');
        Seismic_PIMDOVSync_Notification.senderrorEmail('Test Exception Block', 'Test Exception Block');
        Test.stopTest();
    }
}