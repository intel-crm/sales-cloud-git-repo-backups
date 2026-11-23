/**************************************************************************************
Apex Class Name:  Core_CloneDWGCtrl
Version     : 1.0 
Created Date: 05 March 2019
Function    : class for cloning sobjects
Modification Log :
* Developer                       Date                    Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar               05/03/2019              Original Version
*************************************************************************************/

public class Core_CloneDWGCtrl {
       
    @AuraEnabled
    public static map<string,Object> cloneAnySobjet(String recordId){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String objectAPIName = 'Core_Goal__c';
        String keyPrefix = recordId.substring(0,3);
        for( Schema.SObjectType obj : schemaMap.Values() ){
            String prefix = obj.getDescribe().getKeyPrefix();
            if(prefix == keyPrefix){
                objectAPIName = obj.getDescribe().getName();
                break;
            }
        }
        Set <String> fieldMap = schemaMap.get(objectAPIName).getDescribe().fields.getMap().keySet();
        String soqlQuery = 'SELECT ' ; 
        for (String s :fieldMap ){
            if(schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap().get(s).getDescribe().isAccessible()){
                soqlQuery +=  + s+',';
            }
        }
        soqlQuery =  soqlQuery.removeEnd(',');
        soqlQuery += ' FROM ' +objectAPIName +' WHERE ID = \'' + recordId +'\'' ;
        System.debug('soqlQuery'+soqlQuery);
        SObject record = Database.query(soqlQuery);
        SObject clondedParentRecordID = record.clone();
        String representation = JSON.serialize(clondedParentRecordID);
        Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(representation);
        for(String data : dataMap.keyset()){
            if(data.equalsIgnoreCase('Core_Goal_Status__c')){
                dataMap.put(data, 'Draft');
            }
            if(data.equalsIgnoreCase('recordTypeId')){
                dataMap.put(data, null);
            }
            
            if(data.equalsIgnoreCase('Core_Goal_Approved_Date__c')){

                dataMap.put(data, null);
            }
            if(data.equalsIgnoreCase('Core_Goal_Approved_By__c')){
                dataMap.put(data, null);
            }
            if(data.equalsIgnoreCase('Core_Goal_Approver__c')){
                dataMap.put(data, null);
            }
            if(data.equalsIgnoreCase('Core_Goal_Claim_Date__c')){
                dataMap.put(data, null);
            }
        }
        dataMap.remove('attributes');
        
        return dataMap;  
    }
}