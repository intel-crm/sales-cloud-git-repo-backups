public with sharing class Core_OpportunityContactRoleHandler {
    //TWC3123-5659 - Devashish
    public static void checkPCCLockOnOppty(List<OpportunityContactRole> newOCRList) {
        Set<String> oppIds = new Set<String>();                     
        for(OpportunityContactRole ocr:newOCRList) {
            oppIds.add(ocr.OpportunityId);
        }
        if(oppIds.size() > 0){
            List<Opportunity> OpptyList = [SELECT Id, name, SBQQ__PrimaryQuote__c, Core_Coverage_Type_Nm__c, Core_Opportunity_Coverage_Nm__c FROM Opportunity WHERE Id IN:oppIds AND Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity' AND Core_Coverage_Type_Nm__c ='Deal Registration']; 
            Boolean lock = Core_CRM_Utility.lockOpportunity(OpptyList);
            if(lock) {
                for(OpportunityContactRole ocr:newOCRList) {
                    ocr.adderror(System.Label.Core_LockPCCOppty);
                }
            }
        }
        
    }
    
    public static void checkPrimaryContactRole(List<OpportunityContactRole> newOCRList,boolean isInsert) {
        Set<String> oppIds = new Set<String>();
        
        for(OpportunityContactRole ocr : newOCRList) {
            /*if(ocr.IsPrimary == True && ocr.Role <> null && ocr.Role <> 'Business Decision Maker' && ocr.CRM_Opportunity_Coverage__c == 'Intel-Led Opportunity' && !Test.isRunningTest()) {
                ocr.adderror(Core_CRM_Utility.getCRMLabel('CRM_PrimConRole_NoBusDecMaker_ErrMsg'));
            }*/
            if(ocr.CRM_Opportunity_Coverage__c == 'Intel-Led Opportunity' && ocr.IsPrimary == True) {
                if(!isInsert){
                    if(ocr.Role <> 'Business Decision Maker' && !Test.isRunningTest())
                        ocr.adderror(Core_CRM_Utility.getCRMLabel('CRM_PrimConRole_NoBusDecMaker_ErrMsg'));
                }
                else{ 
                    oppIds.add(ocr.OpportunityId);
                }
            }
        }
        if(oppIds.size() > 0){
            map<Id,Opportunity> OpptyMap = new map<Id,Opportunity>([SELECT Id, name, Core_IsClone__c, Core_Renewed_Opportunity_Ind__c,Core_Lead_Conversion_Flag__c FROM Opportunity WHERE Id IN:oppIds]); 
            for(OpportunityContactRole ocr:newOCRList) {
                boolean bypass = (ocr.Role==null && OpptyMap.get(ocr.OpportunityId).Core_IsClone__c == true || OpptyMap.get(ocr.OpportunityId).Core_Renewed_Opportunity_Ind__c == true ||OpptyMap.get(ocr.OpportunityId).Core_Lead_Conversion_Flag__c == true );
                if(ocr.Role <> 'Business Decision Maker' && !bypass && !Test.isRunningTest() )
                    ocr.adderror(Core_CRM_Utility.getCRMLabel('CRM_PrimConRole_NoBusDecMaker_ErrMsg'));
            }
        }
    }
}