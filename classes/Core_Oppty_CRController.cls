public with sharing class Core_Oppty_CRController {
    public Core_Oppty_CRController() {

    }

    @AuraEnabled (cacheable=true)
    public static List <OpportunityLineItem> getQpptyLines(Id dealId) { 
        /*Core_Design_Registration__c dealReg = [Select Id, Name, Core_Opportunity_Id__c from Core_Design_Registration__c where Id =:dealId];
         String oppId = dealReg.Core_Opportunity_Id__c;*/
        Core_Design_Registration_Product__c drp = [Select Id, Name, Core_Design_Registration_Id__c,Core_Design_Registration_Id__r.Core_Opportunity_Id__c from Core_Design_Registration_Product__c where Id =:dealId];
        String drId = drp.Core_Design_Registration_Id__r.Core_Opportunity_Id__c;
        List <OpportunityLineItem> opLinesLst = new List <OpportunityLineItem>();
        /*if(drId != null){
            opLinesLst=[SELECT Id, Name, Description, Core_Account_Name__c, Core_Status__c, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.Pricing_Status_Nm__c,
                        Product2Id, Product2.Name,Core_Design_Registration_Product_Id__c,sbaa__ApprovalStatus__c,Core_Claim_Date__c, 
                        Core_PW_Approved_By__c,Core_QL_Start_Dt__c,Core_QL_End_Dt__c,Core_QL_Unit_Qty__c 
                        FROM OpportunityLineItem 
                        WHERE OpportunityId =:drId AND SBQQ__QuoteLine__r.Pricing_Status_Nm__c = 'Approved'];
        }*/
        return opLinesLst;
    }
}