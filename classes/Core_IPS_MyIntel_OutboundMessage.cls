/*********************************************
* Name : Core_IPS_MyIntel_OutboundMessage 
* Author : Chandra Shekar Pallikonda
* Date Created : 11/5/2021
* Description : This is being used in process builder
* Version Updates : 
*   
************************************************/
public class Core_IPS_MyIntel_OutboundMessage {
    /******************
     * Method Name: createPlatformEventMyIntel
     * Input Param: 
     * Author: Chandra Shekar Pallikonda
     * Description : This method is used to create Platform event Once a Case is created.
     * ***************/
    public static void createPlatformEventMyIntel(List<Id> cases){
        List<Core_MyIntel_Outbound_Integration__e> eventList = new List<Core_MyIntel_Outbound_Integration__e>();
        List<Core_IPS_MyIntel_Outbound_Message__c> outbountMessageList = new List<Core_IPS_MyIntel_Outbound_Message__c>();
        if(!cases.isEmpty() && cases != null) {
            for(Id caseId : cases){
                Core_IPS_MyIntel_Outbound_Message__c outboundMessage = new Core_IPS_MyIntel_Outbound_Message__c();
                outboundMessage.Core_IPS_Case_ID__c = caseId;
                outbountMessageList.add(outboundMessage);
            }
        }
        try{
            if(Core_IPS_MyIntel_Outbound_Message__c.SObjectType.getDescribe().isCreateable()){
                if(outbountMessageList.size() > 0){
                    //insert outbountMessageList;
                    for(Core_IPS_MyIntel_Outbound_Message__c message : outbountMessageList){
                        Core_MyIntel_Outbound_Integration__e event = new Core_MyIntel_Outbound_Integration__e();
                        event.Outbound_Message_ID__c = message.Id;
                        eventList.add(event);
                	}
                }
            }
            if(eventList.size() > 0){
                List<Database.SaveResult> results;// = EventBus.publish(eventList);
                for (Database.SaveResult result : results) {
                    if (result.isSuccess()) {
                        System.debug('Successfully published event.');
                    } else {
                        for(Database.Error error : result.getErrors()) {
                            System.debug('Error Occured: '+error.getStatusCode() +' - '+error.getMessage());
                        }
                    }  
                }
            }
        } catch(Exception e) {
            System.debug('Error occured '+ e.getMessage() +' at line number '+e.getLineNumber());
        }
    }

}