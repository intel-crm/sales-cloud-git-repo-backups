public without sharing class GanapatiTestWithoutSharing {
    public static Core_IPS_MAP_PAR__c updateMAPRecord(Core_IPS_MAP_PAR__c mapRecord) {
        System.debug('mapRec :::'+mapRecord);
        update mapRecord;
        return mapRecord;
    } 
}