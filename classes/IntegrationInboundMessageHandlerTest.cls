@isTest
private class IntegrationInboundMessageHandlerTest {
    @testSetup
    static void createData() {
        Core_Trigger_Executions__c cte = new Core_Trigger_Executions__c();
        cte.Name = 'processInboundMessagesIQR';
        cte.Core_Trigger_Events__c = 'after insert, after update';
        cte.Core_Object__c = 'Core_Integration_Inbound_Message__c';
        cte.Core_Description__c = 'Process inbound IQR messages from Mydeals';
        cte.Core_Class_Name__c = 'Core_IntegrationInboundMessageHandler';
        cte.Core_Active__c = TRUE;
        INSERT cte;
        
        Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
        iim.Core_Source_System__c = 'MyDeals';
        iim.Core_Message_Type__c = 'Tender';
        iim.Core_Payload__c = ':Null :Null';
        
        INSERT iim;
    }
    
    @isTest
    static void bankTest() {
        Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
        iim.Core_Source_System__c = 'EDW';
        iim.Core_Message_Type__c = 'Bank';
        iim.Core_Payload__c = ':Null :Null';
        INSERT iim;
    }
    
    @isTest
    static void paymentTest() {
        Core_Integration_Inbound_Message__c iim1 = new Core_Integration_Inbound_Message__c();
        iim1.Core_Source_System__c = 'EDW';
        iim1.Core_Message_Type__c = 'Payment';
        iim1.Core_Payload__c = ':Null :Null';
        INSERT iim1;
    }
    
    @isTest
    static void marketPlaceTranslation() {
        Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
        iim.Core_Source_System__c = 'EDW';
        iim.Core_Message_Type__c = 'Marketplace_Translation';
        iim.Core_Payload__c = ':Null :Null';
        INSERT iim;
    }
    
    @isTest
    static void marketPlacePartnerTranslation() {
        Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
        iim.Core_Source_System__c = 'EDW';
        iim.Core_Message_Type__c = 'Marketplace Translation - Partner';
        iim.Core_Payload__c = ':Null :Null';
        INSERT iim;
    }
    
    @isTest
    static void tenderTest() {
        
        Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
        iim.Core_Source_System__c = 'MyDeals';
        iim.Core_Message_Type__c = 'Tender';
        iim.Core_Payload__c = ':Null :Null';        
  
        Core_Integration_Inbound_Message__c iim1 = new Core_Integration_Inbound_Message__c();
        iim1.Core_Source_System__c = 'MyDeals';
        iim1.Core_Message_Type__c = 'UpdateClaims';
        iim1.Core_Payload__c = ':Null :Null';
        
        Core_Integration_Inbound_Message__c iim2 = new Core_Integration_Inbound_Message__c();
        iim2.Core_Source_System__c = 'MyDeals';
        iim2.Core_Message_Type__c = 'UpdateDropdowns';
        iim2.Core_Payload__c = ':Null :Null';
        
        List<Core_Integration_Inbound_Message__c> listIntegrationInboundMessages = new List<Core_Integration_Inbound_Message__c>{iim, iim1, iim2};
        INSERT listIntegrationInboundMessages;             
    }
    
    @isTest
    static void tenderTestUpdate() {
  
        Core_Integration_Inbound_Message__c iim = [Select Id From Core_Integration_Inbound_Message__c limit 1];
        iim.Core_Processing_Status__c = 'Pending';
        
        UPDATE iim;
    }
    
    
}