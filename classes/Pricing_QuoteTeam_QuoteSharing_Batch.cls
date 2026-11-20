public without sharing class Pricing_QuoteTeam_QuoteSharing_Batch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator([SELECT id,Pricing_Role_Nm__c,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Team_Member_Id__r.Email,Pricing_Quote_Id__c,Pricing_Quote_Id__r.Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Grant_Access_Ind__c 
                                         FROM Pricing_Quote_Team__c WHERE Pricing_Grant_Access_Ind__c=false AND Pricing_Quote_Id__c!=null]);      
    }    
    public void execute(Database.BatchableContext bc, List<Pricing_Quote_Team__c> quoteTeamMembers){
        Map<Id,Pricing_Quote_Team__c> quoteTeamMap = new Map<Id,Pricing_Quote_Team__c>();
        for(Pricing_Quote_Team__c qtm : quoteTeamMembers){
            quoteTeamMap.put(qtm.Id, qtm);
        }
        if(quoteTeamMap.size() > 0){
           Pricing_QuoteTeam_Trigger_Handler.createQuoteSharesForQTM(quoteTeamMap); 
        }        
    } 
    public void finish(database.BatchableContext bc) {
        
    }
}