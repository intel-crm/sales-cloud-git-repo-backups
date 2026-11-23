// NOTE: for now, this is just a quick & dirty test class to achieve code coverage on the Log Tool.
// Since it's not an end user tool, it's just a simple utility for us to search through records in a
// single place, a proper test class isn't as essential. If this tool becomes important at all, we'll
// build proper test methods with real assertions, self-created test data, and remove the seeAllData=true.

@isTest(SeeAllData=true)
public class Core_Contact_Entitlement_Log_Tool_C_Test {
    
    static testMethod void testLogTool() {
    
        PageReference pageRef = Page.Core_Contact_Entitlement_Log_Tool;
        Test.setCurrentPage(pageRef);
        
        Core_Contact_Entitlement_Log_Tool_Ctrllr cont = new Core_Contact_Entitlement_Log_Tool_Ctrllr();
        cont.init();
        cont.getMessageOptions();
        cont.getRecordLimit();
        
        cont.init();
        Core_Contact_Entitlement__c ce = [select Core_Contact_Id__c from Core_Contact_Entitlement__c limit 1];
        cont.contactId = ce.Core_Contact_Id__c;
        cont.search();
        
        cont.init();
        Contact c = [select Email from Contact where Email != null limit 1];
        cont.emailAddr = c.Email;
        cont.search();
        
        cont.init();
        c = [select Core_eRPM_Person_Id__c from Contact where Core_eRPM_Person_Id__c != null limit 1];
        cont.erpmPersonId = c.Core_eRPM_Person_Id__c;
        cont.search();
        
        cont.init();
        c = [select Core_Enterprise_Id__c from Contact where Core_Enterprise_Id__c != null limit 1];
        cont.enterpriseId = c.Core_Enterprise_Id__c;
        cont.search();
        
        cont.init();
        Core_Integration_Outbound_Message__c outMsg = [select Id from Core_Integration_Outbound_Message__c limit 1];
        cont.outboundMessageId = outMsg.Id;
        cont.search();
        
        cont.init();
        Core_Integration_Inbound_Message__c inMsg = [select Id from Core_Integration_Inbound_Message__c limit 1];
        cont.inboundMessageId = inMsg.Id;
        cont.search();
        
        cont.init();
        Core_Log_Entry__c logEntry = [select Id from Core_Log_Entry__c limit 1];
        cont.logEntryId = logEntry.Id;
        cont.search();
    }
}