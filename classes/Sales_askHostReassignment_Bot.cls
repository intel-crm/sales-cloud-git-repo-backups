@isTest
public without sharing class Sales_askHostReassignment_Bot {
    /*public class HostOutput {
        @InvocableVariable
        public Boolean isLicenseExist;
    }
    public class HostInput {
        @InvocableVariable
        public Sales_Host__c hostObject;
        @InvocableVariable
        public Id licenseId;
    }
    @InvocableMethod(label='Ask for Host Reassignment')
    public static List<HostOutput> askForhostReassigment(List<HostInput> hostInputs) {
        Set<Id> hostIds = new Set<id>();
        Set<Id> licenseIds = new Set<id>();
        List<HostOutput> hostList = new List<HostOutput>();
        //Map<Id, Id> mapofInputs = new Map<Id, Id>();
        HostOutput output = new HostOutput();
        for(HostInput input: hostInputs){
            hostIds.add(input.hostObject.Id);
            licenseIds.add(input.licenseId);
        }
        Boolean validateLicenseExist = Sales_LicenseGenerationGenericFunctions.askForhostReassigment(hostIds, licenseIds);   
        output.isLicenseExist= validateLicenseExist;
        hostList.add(output);
        return hostList;
    }*/
}