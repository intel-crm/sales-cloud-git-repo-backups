public without sharing class Sales_GetHostType_Bot {
    public class HostinfoInput {
        @InvocableVariable
        public Sales_Host__c hostinformationObject;
    }
    public class hostinformationOutput {
        @InvocableVariable
        public String hosttype;
    }
    @InvocableMethod(label='Get Host information type')
    public static List<hostinformationOutput> getHostDetails(List<HostinfoInput> inputs) {
        List<hostinformationOutput> outputList = new List<hostinformationOutput>();
        Set<Id> hostinformationIds = new Set<Id>();
        for(HostinfoInput input : inputs){
            hostinformationIds.add(input.hostinformationObject.id);
        }
        hostinformationOutput output = new hostinformationOutput();
        List<hostinformationOutput> hostinfolst = new List<hostinformationOutput>();
        for(Sales_Host__c hostinfoObj : [Select Id,Sales_Computer_Type__c from Sales_Host__c WHERE id IN : hostinformationIds]){
            output.hosttype = hostinfoObj.Sales_Computer_Type__c;
            hostinfolst.add(output);
        }
        return hostinfolst;
    }
}