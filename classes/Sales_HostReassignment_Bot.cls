@isTest
public with sharing class Sales_HostReassignment_Bot {
    /*public class HostOutput {
        @InvocableVariable
        public String outputString;
    }
    public class HostInput {
        @InvocableVariable
        public Sales_Host__c hostObject;
        @InvocableVariable
        public Id activationCode;
    }
    @InvocableMethod(label='Host Reassignment')
    public static List<HostOutput> hostReassigment(List<HostInput> hostInputs) {
        List<HostOutput> hostList = new List<HostOutput>();
        Map<Id, Id> mapofInputs = new Map<Id, String>();
        for(HostInput input: hostInputs){
            mapofInputs.put(input.hostObject.Id, input.activationCode);
        }
        String isReturnMsg = Sales_LicenseGenerationGenericFunctions.hostReassigmentLogic(mapofInputs);
        HostOutput output = new HostOutput();
        output.outputString = isReturnMsg;
        hostList.add(output);
        return hostList;
    }*/
}