/****************************************************************************************************************
	Class Name : CallQuoteTeamMemberShareQueueable    
	Version     : 1.0 
    Created Date: 18 Dec 2024    
    Description: This class is to process Opportunity records based on specific conditions and
				 trigger external business logic for further operations. 
    Modification Log :
    * Developer             Date              Description
    * ----------------------------------------------------------------------------------------------------------                 
    * Leela                12/18/2024       Queueable class is called from Opporunity Team Member Handler class.
******************************************************************************************************************/ 
public class Core_CallQuoteTeamMemberShareQueueable implements Queueable {
    private Set<Id> oppIds;
    
    public Core_CallQuoteTeamMemberShareQueueable(Set<Id> oppIds){
        this.oppIds = oppIds;
    }
    
    public void execute(QueueableContext context) {
        try{
            Set<Id> PCCOppId = new Set<Id>();
            Set<Id> SWOppIdSet = new Set<Id>();
			List<Opportunity> OpptyList = [SELECT Id,CRM_SW_Flag_Ind__c,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c FROM Opportunity WHERE Id IN:oppIds];
			for(Opportunity opp : OpptyList) {
            if(opp.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && opp.Core_Coverage_Type_Nm__c == 'Deal Registration'){
				PCCOppId.add(opp.Id);
            }
            if(opp.CRM_SW_Flag_Ind__c){
                SWOppIdSet.add(opp.Id);
            }
        }
         List<Id> SWOppId = new List<Id>(SWOppIdSet);
         if(!PCCOppId.isEmpty()){
            Pricing_FinancialIncentive_BusinessLogic.createQuoteSharesForFI(PCCOppId);
        }
        if(!SWOppId.isEmpty()){
            Pricing_SW_QuoteBusinessLogic.createQuoteSharesForSW(SWOppId);
        }   
        }
        catch (Exception ex){ PMP_Utility.logError(ex, 'Core_CallQuoteTeamMemberShareQueueable'); }
            //System.debug('Error occured:' +e.getMessage()); 
    }
}