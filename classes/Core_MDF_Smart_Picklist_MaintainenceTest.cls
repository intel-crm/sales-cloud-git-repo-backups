@isTest(SeeAllData=false)
public class Core_MDF_Smart_Picklist_MaintainenceTest {
    @TestSetup
    static void createTestUser() {
        
        // Create a test user with the System Administrator profile
       User sysAdminUser = Core_MDF_CCP_TestDataUtility.createUser(false);
       sysAdminUser.LanguageLocaleKey = 'en_US';
       insert sysAdminUser;
      
    }
    
     /*@isTest static void CreateTreeData(){
         List<string> result = new List<string >();
         List<core_MDF_Picklist_Maintainance__mdt> objList = [select Core_MDF_Picklist_Maintanance__c from core_MDF_Picklist_Maintainance__mdt where Core_MDF_Picklist_Maintanance__c='Case' ];
          for(core_MDF_Picklist_Maintainance__mdt obj : objList){
         result.add(obj.Core_MDF_Picklist_Maintanance__c);
         
	     }
         for( String obj: result )
         { 
         List<Core_MDF_Smart_Picklist_Maintainence.Wrapper> treeData= new List<Core_MDF_Smart_Picklist_Maintainence.Wrapper>();
         treeData=Core_MDF_Smart_Picklist_Maintainence.getTreeGridData();
         List<Core_MDF_Smart_Picklist_Maintainence.Items> RecType= new List<Core_MDF_Smart_Picklist_Maintainence.Items>();
         RecType=Core_MDF_Smart_Picklist_Maintainence.GetRecordType(obj);
         System.assertNotEquals(null,treeData,'treeData should not be null');
        
   		 }
    }*/
    @isTest
    static void testgetProgramData(){
        List<String> programList = new List<String>();
        programList = Core_MDF_Smart_Picklist_Maintainence.getProgramData();
        System.assertNotEquals(null, programList, 'List of Program values should not be null');
        System.assertNotEquals(0, programList.size(), 'List of Program values should not be empty');
    }
    @isTest
    static void testgetObjectData(){
        Map<String, String> objectMap = new Map<String,String>();
        Map<String,String> objMap2 = new Map<String,String>();
        String programName = 'Co-Marketing Platform';
        String programName2 = 'XYZ';
        objectMap =  Core_MDF_Smart_Picklist_Maintainence.getObjectData(programName);
        System.assertNotEquals(null,objectMap,'Map of object values should not be null');
        try{
        Core_MDF_Smart_Picklist_Maintainence.getObjectData(null);
        }
        catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            //System.assertEquals('expected text', ex.getMessage());
        }  
        
        
    }
    @isTest
    static void testgetFieldData(){
        try{
        Map<String, String> fieldsDataMap = new Map<String,String>();
        String programName = 'Co-Marketing Platform';
        String objName = 'Core_MDF_Custom_Picklist__c';
        fieldsDataMap = Core_MDF_Smart_Picklist_Maintainence.getFieldData(objName, programName);
        System.assertNotEquals(null,fieldsDataMap,'Map of fields should not be null');
        Core_MDF_Smart_Picklist_Maintainence.getFieldData(null, null);
        }
        catch(Exception e){
             Core_MDF_CCP_UtilityClass.logError(e);
        }
        
    }
    @isTest
    static void testgetPickListValuesData(){
        List<String> picklistValues = new List<String>();
        String objName = 'Core_MDF_Custom_Picklist__c';
        String fldName = 'Core_MDF_Focus_Area_nm__c';
        picklistValues=Core_MDF_Smart_Picklist_Maintainence.getPickListValuesData(objName,fldName);
        try{
        Core_MDF_Smart_Picklist_Maintainence.getPickListValuesData(null,null);
        }
        catch(Exception e){
             Core_MDF_CCP_UtilityClass.logError(e);
        }
        
    }
    @isTest
    static void testFieldAttributesDetails(){
       Core_MDF_Smart_Picklist_Maintainence.fieldDetailsWrapper fdw = new Core_MDF_Smart_Picklist_Maintainence.fieldDetailsWrapper();
       String programName = 'Co-Marketing Platform';
       String objName = 'Core_MDF_Custom_Picklist__c';
       String fldName = 'Core_MDF_Focus_Area_nm__c';
       fdw = Core_MDF_Smart_Picklist_Maintainence.fieldAttributesDetails(programName, objName, fldName);
       System.assertNotEquals(null,fdw,'fieldAttributes should be empty');
       System.assertNotEquals(true, fdw.isLabelNameSameAsAPIName, 'isLabelApiName is sets as false');
       System.assertNotEquals(false, fdw.sorted, 'Sort should not be false');
       System.assertNotEquals(null, fdw.recordTypeTabName, 'RecordTypeTabName should not be null');
       System.assertNotEquals(false, fdw.gvsReferenceInd, 'RefersGVS should not be false');
       System.assertNotEquals(null, fdw.globalValueSetName, 'GlobalValueSetName should not be null');   
        
    }
    @isTest
    static void testgetDependentfields(){
        Map<String,String> dependentfieldsMap = new Map<String,String>();
        Map<String,String> dependentfieldsMap2 = new Map<String,String>();
        String objName = 'Core_MDF_Custom_Picklist__c';
        String fldName = 'Core_MDF_Focus_Area_nm__c';
        dependentfieldsMap = Core_MDF_Smart_Picklist_Maintainence.getDependentfields(objName, fldName);
        System.assertEquals(0,dependentfieldsMap.size(),'dependentfieldsMap is empty');
        String fldName2 = 'Core_MDF_Controlling_Field_nm__c';
        dependentfieldsMap2 = Core_MDF_Smart_Picklist_Maintainence.getDependentfields(objName, fldName2);
        System.assertNotEquals(null,dependentfieldsMap2,'dependentfieldsMap2 is not empty');
        //System.assertEquals(true,dependentfieldsMap2.containsKey('Core_MDF_Focus_Area_nm__c'),'dependentfieldsMap2 has this expected field');  
    }
     // Mock HTTP response class to simulate the HTTP callout
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
          
            //if(req.getEndpoint()=='https://intel--crmdevccp.sandbox.my.salesforce.com'){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"customValue": [{"valueName": "Client Computing", "label": "Client Computing"}, {"valueName": "Data Center", "label": "Data Center"},{"valueName": "Networking & Intelligent Edge", "label": "Networking & Intelligent Edge"},{"valueName": "FC1", "label": "FC1"},{"valueName":"FC2", "label":"FC2"}]}');
            //res.setBody('{"records": [{"Metadata": {"customValue": [{"label": "Client Computing", "valueName": "Client Computing", "isActive": true, "default": false},{"label": "Data Center", "valueName": "Data Center", "isActive": true, "default": false},{"label": "Networking & Intelligent Edge", "valueName": "Networking & Intelligent Edge", "isActive": true, "default": false}]}]}');
            res.setBody('{"records": [{"Metadata": {"customValue": [{"label": "Client Computing", "valueName": "Client Computing", "isActive": true, "default": false},{"label": "Data Center", "valueName": "Data Center", "isActive": true, "default": false},{"label": "Networking & Intelligent Edge", "valueName": "Networking & Intelligent Edge", "isActive": true, "default": false}]}}]}');
            res.setStatusCode(200);
            return res;
            
        }
    }
     public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"picklistFieldValues" : {"Core_MDF_Controlling_Field_nm__c" : {"controllerValues" : { },"defaultValue" : null,"values" : [ {"attributes" : null,"label" : "MDF","validFor" : [ ],"value" : "MDF"}, {"attributes" : null, "label" : "MDF+","validFor" : [ ],"value" : "MDF+" }, {"attributes" : null, "label" : "OEM CMP","validFor" : [ ],"value" : "OEM CMP"}, {"attributes" : null,"label" : "CCF 1.0","validFor" : [ ],"value" : "CCF 1.0"} ]}');
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    static void testgetRTdetailsBasedOnObjectSelection(){
        List<Core_MDF_Smart_Picklist_Maintainence.rtWrapper> rtW = new List<Core_MDF_Smart_Picklist_Maintainence.rtWrapper>();
        String objName = 'Core_MDF_Custom_Picklist__c';
        String fldName = 'Core_MDF_Focus_Area_nm__c';
        rtw = Core_MDF_Smart_Picklist_Maintainence.getRTdetailsBasedOnObjectSelection(objName, fldName);
        System.assertNotEquals(null,rtw,'RtWrapper should not be null');
        
        
    }
    @isTest
    static void testgetDependentPicklistValues(){
        String objName = 'Core_MDF_Custom_Picklist__c';
        String fldName = 'Core_MDF_Controlling_Field_nm__c';
        Id recordtypeId = Schema.SObjectType.Core_MDF_Custom_Picklist__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance_Proposal_Based').getRecordTypeId(); 
        Map<String,List<String>> dependentPicklistValuesMap = new Map<String,List<String>>();
        try{
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        dependentPicklistValuesMap = Core_MDF_Smart_Picklist_Maintainence.getDependentPicklistValues(objName, fldName, recordtypeId);
         System.assertNotEquals(null,dependentPicklistValuesMap,'dependentPicklistValuesMap should not be null');
        }
        catch(exception e){
             Core_MDF_CCP_UtilityClass.logError(e);
        }
             
    }
    @isTest
    static void testgetPicklistValFromGVS(){
        String gvsName = 'Core_MDF_Focus_Area';
        List<Core_MDF_Smart_Picklist_Maintainence.PickListWrapper> plw = new List<Core_MDF_Smart_Picklist_Maintainence.PickListWrapper>();
        List<Core_MDF_Smart_Picklist_Maintainence.PickListWrapper> plw2 = new List<Core_MDF_Smart_Picklist_Maintainence.PickListWrapper>();
        
        try{
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            Test.startTest();
            plw= Core_MDF_Smart_Picklist_Maintainence.getPicklistValFromGVS(gvsName);
            Test.stopTest();
            System.assertEquals(3, plw.size(), 'Expected number of picklist values');
            Core_MDF_Smart_Picklist_Maintainence.PickListWrapper firstPicklistValue = plw[0];
        System.assertEquals('Client Computing', firstPicklistValue.label);
        System.assertEquals('Client Computing', firstPicklistValue.value);
        System.assertEquals(false, firstPicklistValue.isDefaultValue);
        System.assertEquals(true, firstPicklistValue.isActive);
        plw2 = Core_MDF_Smart_Picklist_Maintainence.getPicklistValFromGVS(null);    
        }
        catch(exception e){
             Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    @isTest
    static void testGetRecordType(){
        String objName = 'Core_MDF_Custom_Picklist__c';
        List<Core_MDF_Smart_Picklist_Maintainence.Items> rtDetails = new List<Core_MDF_Smart_Picklist_Maintainence.Items>();
        rtDetails = Core_MDF_Smart_Picklist_Maintainence.GetRecordType(objName);
        System.assertNotEquals(null,rtDetails,'Record Type Details should not be null');
    }
    @isTest
    static void testgetRTdetailsBasedOnObjectSelectionException(){
        try{
            Core_MDF_Smart_Picklist_Maintainence.getRTdetailsBasedOnObjectSelection(null,null);
                
        }
        catch(Exception e){
             String message = e.getMessage();
             assert.isTrue(message.contains('Script-thrown exception'));
             Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    @isTest
    static void testgetPicklistValFromGVSException(){
        try{
            Core_MDF_Smart_Picklist_Maintainence.getPicklistValFromGVS(null);  
        }
        catch(Exception e){
              String message = e.getMessage();
               assert.isTrue(message.contains('Script-thrown exception'));
             Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    @isTest
    static void testfieldAttributesDetailsException(){
        try{
            Core_MDF_Smart_Picklist_Maintainence.fieldAttributesDetails(null,null,null);  
        }
        catch(Exception e){
            String message = e.getMessage();
              assert.isTrue(message.contains('Script-thrown exception'));
             Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    @isTest
    static void testGetDependentfieldsWithException(){
        try{
         Core_MDF_Smart_Picklist_Maintainence.getDependentfields(null, null);       
   		 }
    catch(Exception e){
             String message = e.getMessage();
               assert.isTrue(message.contains('Script-thrown exception'));
             Core_MDF_CCP_UtilityClass.logError(e);
        }
	}
 	@isTest
    static void testGetProgramDataWithException(){
       //try {
         
        try{
         Core_MDF_Smart_Picklist_Maintainence.getProgramData();
       }
       catch(Exception e){
            // Verify that the expected exception is thrown
            String message = e.getMessage();
               assert.isTrue(message.contains('Script-thrown exception'));
             Core_MDF_CCP_UtilityClass.logError(e);
        }
	}
    private class MockHttpResponseGenerator1 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Simulate an exception response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setStatus('Internal Server Error');
            return res;
        }
    }
    @isTest
    static void testGetFieldDataWithException(){
        try{
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Test.startTest();
        Core_MDF_Smart_Picklist_Maintainence.getFieldData(null,null);
        Test.stopTest();
        }
        catch(Exception e){
            String message = e.getMessage();
              assert.isTrue(message.contains('Script-thrown exception'));
             Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
     @isTest
    static void testGeObjectDataWithException(){
        try{
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Test.startTest();
        Core_MDF_Smart_Picklist_Maintainence.getObjectData('');
        Test.stopTest();
        }
        catch(Exception e){
            String message = e.getMessage();
             assert.isTrue(message.contains('Script-thrown exception'));
             Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

     
}