@isTest
public class Core_IPS_TriggerLevelException_Test {
    public static TestMethod void TestMethod1(){
        Test.startTest();
        List<Core_IPS_Backend_TriggerLevel_Exception__e> backendIntegrationEventsList = new List<Core_IPS_Backend_TriggerLevel_Exception__e>();
                Core_IPS_Backend_TriggerLevel_Exception__e backEndOutboundIntegrationEvent = new Core_IPS_Backend_TriggerLevel_Exception__e();
                backEndOutboundIntegrationEvent.Core_IPS_Description__c = 'Test Descritipon';
                backEndOutboundIntegrationEvent.Core_IPS_Status__c = 'Test Status';
                backendIntegrationEventsList.add(backEndOutboundIntegrationEvent);
                List<Database.SaveResult> results = EventBus.publish(backendIntegrationEventsList);
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) {// if Operation failed, so get all errors 
                        //System.debug('Successfully published event.');
                     //else {
                        for(Database.Error err : sr.getErrors()) {
                            /*System.debug('Error returned: ' +
                                         err.getStatusCode() +
                                         ' - ' +
                                         err.getMessage());*/
                            throw new StringException('Event Publishing exception '+ err.getMessage());//ATHR fix Gangadhar
                        }
                		}
                    //}  
                }
        Test.stopTest();
        System.AssertEquals(results != null, true); //TWC745-7213- Assert added
    }
}