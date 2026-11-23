/***************************************************************************************************
* Apex Class Name : Core_IPS_UpdateMapsForNewFields_Batch
* Test Class Name : Core_IPS_UpdateMapsForNewFields_BatchTest
* Description : To update existing MAP records - one time use - call from ananymous window
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ganapati                 17/01/2020              	  Created
  Prasad                   23/4/2020                  fixed PMd issues    
****************************************************************************************************/

public without sharing class  Core_IPS_UpdateMapsForNewFields_Batch implements Database.Batchable<sObject> {
    
    private static final String PAR_HIDDEN = 'Par Hidden';
    private static final String APPROVAL_REQUIRED = 'Approval Required';
    private static final String AUTO_APPROVE = 'Auto Approve';
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Core_IPS_MAP_Count_Supp_acct__c, Core_IPS_MAP_Count_Supp_prod__c, 
        return Database.getQueryLocator(
                'SELECT ID, Core_IPS_MAP_Access_Flag__c, ' +
            ' (Select Id, Core_MAP_Supported_Product__r.Id, Core_MAP_Supported_Product__r.Core_Flag_Status__c, Core_MAP_PAR__c, Core_MAP_PAR__r.RecordType.Name from MAP_Supported_Products__r), ' +
            ' (SELECT ID FROM MAP_Accounts__r) ' +
            ' FROM Core_IPS_MAP_PAR__c ' + 
            'WHERE RecordType.Name = \'MAP\''
        );
    }

    
    public void execute(Database.BatchableContext bc, List<Core_IPS_MAP_PAR__c> records){
        MAP<Id, Core_IPS_MAP_PAR__c> mapRecsMap = new MAP<Id, Core_IPS_MAP_PAR__c>(); 
        List<Core_IPS_MAP_PAR__c> updateMAPLst = new List<Core_IPS_MAP_PAR__c>();
        for(Core_IPS_MAP_PAR__c mapRec : records) {
            Integer parHiddenProdCnt = 0;
            Integer approvalReqProdCnt = 0;
            Integer autoApproveProdCnt = 0;
            mapRec.Core_IPS_MAP_Access_Flag__c = '';
            
            //mapRec.Core_IPS_MAP_Count_Supp_prod__c = mapRec.MAP_Supported_Products__r.size();
            //mapRec.Core_IPS_MAP_Count_Supp_acct__c = mapRec.MAP_Accounts__r.size();
            
            if(mapRec.MAP_Supported_Products__r.size() == 0 ) {
                mapRecsMap.put(mapRec.Id, mapRec);
            }
            
            for(Core_IPS_MAP_Product__c mapProduct : mapRec.MAP_Supported_Products__r) {
                String accessFlag = mapProduct.Core_MAP_Supported_Product__r.Core_Flag_Status__c;
                if(PAR_HIDDEN.equalsIgnoreCase(accessFlag)) {
                    parHiddenProdCnt++;
                } else if(APPROVAL_REQUIRED.equalsIgnoreCase(accessFlag)) {
                    approvalReqProdCnt++;
                }  else if(AUTO_APPROVE.equalsIgnoreCase(accessFlag)) {
                    autoApproveProdCnt++;
                } 
            }
            if(parHiddenProdCnt>0) {
                mapRec.Core_IPS_MAP_Access_Flag__c = PAR_HIDDEN;
            } else if(approvalReqProdCnt > 0) {
                mapRec.Core_IPS_MAP_Access_Flag__c = APPROVAL_REQUIRED;
            } else if(autoApproveProdCnt > 0) {
                mapRec.Core_IPS_MAP_Access_Flag__c = AUTO_APPROVE;
            } else {
                mapRec.Core_IPS_MAP_Access_Flag__c = '';
            }
            if(!mapRecsMap.containsKey(mapRec.Id)) {
                mapRecsMap.put(mapRec.Id, mapRec);
            } else {
                mapRecsMap.remove(mapRec.Id);
                mapRecsMap.put(mapRec.Id, mapRec);
            }
        }
        if( !mapRecsMap.isEmpty() ) {
            update mapRecsMap.values();           
        }
        
    }    
    public void finish(Database.BatchableContext bc){
        system.debug('Batch job finised!');
    }  
}