public without sharing class Core_OpptyController {
    
    public Id oppId {get;set;}
    public List<opportunityLineItem> getopp(){
    list<opportunityLineItem> oliList = new list<opportunityLineItem>();
        		
        oliList = [select Product2.Name,Core_Status__c,Core_Claim_Date__c,Quantity,UnitPrice,TotalPrice from opportunityLineItem where Opportunity.id =:oppId];//oppId
        return oliList;
    }
}