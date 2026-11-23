global class Core_IPS_FirstResponseSLATimeCalculator implements Support.MilestoneTriggerTimeCalculator {

    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        Integer slaHour;
        System.debug('inside Core_IPS_FirstResponseSLATimeCalculator');
        Case caseObj = [SELECT Id, AccountId, ProductId, Core_IPS_Project_Case__c,Core_IPS_Supported_Product__c FROM Case WHERE Id=:caseId LIMIT 1];
        System.debug('caseObj-->'+caseObj);
        Asset assetRec = [Select Id, Support_Tier__c, AccountId, Product2Id,Core_Product_EPM_ID__c,Core_Supported_Product__c  from Asset where AccountId =:caseObj.AccountId AND Product2Id =: caseObj.ProductId AND Core_Supported_Product__c =: caseObj.Core_IPS_Supported_Product__c LIMIT 1];
        System.debug('assetRec-->'+assetRec);
        IPS_Support_Tier_SLA_Configuration__mdt slaConfig = [Select EPMID__c, Support_Tier_SLA_Info__c, Label from IPS_Support_Tier_SLA_Configuration__mdt where EPMID__c =: assetRec.Core_Product_EPM_ID__c];
        
        System.debug('slaConfig-->'+slaConfig);
        System.debug('Support_Tier_SLA_Info__c-->'+slaConfig.Support_Tier_SLA_Info__c);

        SlaDetails slaconfigvalue = (SlaDetails) JSON.deserialize(slaConfig.Support_Tier_SLA_Info__c, SlaDetails.Class);
        System.debug('om** slaconfigvalue-->'+slaconfigvalue);
        System.debug('om** slaconfigvalue1-->'+slaconfigvalue.Tier1);
        System.debug('om** slaconfigvalue2-->'+slaconfigvalue.Tier2);
        System.debug('om** slaconfigvalue3-->'+slaconfigvalue.Tier3);
        
        if(assetRec.Support_Tier__c == 'Tier1'){
            slaHour = Integer.valueOf(slaconfigvalue.Tier1);
        }else if(assetRec.Support_Tier__c == 'Tier2'){
            slaHour = Integer.valueOf(slaconfigvalue.Tier2);
        } else{
            slaHour = Integer.valueOf(slaconfigvalue.Tier3);
        }
        //Integer sla = (Integer)slaconfigvalue.(assetRec.Support_Tier__c);
        return slaHour;
    }
    
    Public class SlaDetails{
        public Integer Tier1 {get; set;}
        public Integer Tier2 {get; set;}
        public Integer Tier3 {get; set;}
    }
}