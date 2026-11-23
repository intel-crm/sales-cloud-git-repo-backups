@IsTest
public class PCC_LineItemControllerTest {

    @TestSetup
    static void setup() {

        PCC_Deal_Change_Request__c changeRequest = new PCC_Deal_Change_Request__c();
        changeRequest.PCC_Approval_Status__c = 'Submitted';
        changeRequest.PCC_Change_Request_Approver__c =  UserInfo.getUserId();
        insert changeRequest;
        
        PCC_Change_Request_Field_Mapping__c  myCS = new PCC_Change_Request_Field_Mapping__c();
        myCS.name ='detail';
        myCS.PCC_Field_API_Name__c = 'PCC_View_Details__c';
        myCS.PCC_Object_Name__c='PCC_Deal_Change_Request_Line_Item__c';
        myCS.PCC_Active__c = true;
        myCS.FieldType__c=  'url';
        myCS.Label__c ='View Details';
        myCS.Enable_for_PSAM_Screen__c=true;
        myCS.isParent__c=true;
        myCS.Enable_for_Query__c=true;
        myCS.WrapperFieldName__c ='fghg';
        myCS.FeatureName__c ='psamapprovalscreen';
        insert myCS;
        
        PCC_Deal_Change_Request_Line_Item__c lineItem = new PCC_Deal_Change_Request_Line_Item__c();
        lineItem.PCC_Change_Request__c = changeRequest.id;
        insert lineItem;
  }

    @IsTest
    static void testGetLineItems() {
        // Get a parentId from the test setup
        Id parentId = [SELECT Id FROM PCC_Deal_Change_Request__c LIMIT 1].Id;

        Test.startTest();
        List<Map<String,String>> result = PCC_LineItemController.getLineItems(parentId);
        Test.stopTest();

        // Perform some assertions
        System.assertNotEquals(null, result, 'Expected some line items');
    }

    @IsTest
    static void testUpdateLineItemsStatus() {
        // Get a recordId and lineItemIds from the test setup
        Id recordId = [SELECT Id FROM PCC_Deal_Change_Request__c LIMIT 1].Id;
        List<Id> lineItemIds = new List<Id>();
        for(PCC_Deal_Change_Request_Line_Item__c lineItem : [SELECT Id FROM PCC_Deal_Change_Request_Line_Item__c WHERE PCC_Change_Request__c = :recordId LIMIT 1]) {
            lineItemIds.add(lineItem.Id);
        }

        // Test here
        Test.startTest();
        PCC_LineItemController.updateLineItemsStatus(lineItemIds, 'Approved', 'Test Comment', recordId);
        Test.stopTest();
        
        // Perform some assertions
        for(PCC_Deal_Change_Request_Line_Item__c lineItem : [SELECT Id, PCC_Approval_Status__c, PCC_PSAM_Comment__c FROM PCC_Deal_Change_Request_Line_Item__c WHERE Id IN :lineItemIds]) {
            System.assertEquals('Approved', lineItem.PCC_Approval_Status__c, 'Expected approval status to match');
        }
    }

    @IsTest
    static void testGetColumns() {
        Test.startTest();
        List<PCC_Change_Request_Field_Mapping__c> result = PCC_LineItemController.getColumns();
        Test.stopTest();

        // Perform some assertions
        System.assertNotEquals(null, result, 'Expected some columns');
    }
}