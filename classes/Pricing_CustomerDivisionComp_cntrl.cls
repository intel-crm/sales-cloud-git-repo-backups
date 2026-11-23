public without sharing class Pricing_CustomerDivisionComp_cntrl {
    @AuraEnabled(cacheable=true)
    public static List<Pricing_Account_Division__c> getCustomerDivision(String recordId) {
        return [SELECT id, Name FROM Pricing_Account_Division__c WHERE Pricing_Account__c IN (SELECT SBQQ__Account__c FROM SBQQ__Quote__c WHERE id =: recordId)
               AND Pricing_Active_ind__c = true];
    }
    @AuraEnabled(cacheable=true)
    public static String getCustomerDivisionValue(String recordId) {
        SBQQ__Quote__c quoteCS =[SELECT Id, Pricing_Account_Division_Nm__c FROM SBQQ__Quote__c WHERE id =: recordId];
        if(quoteCS.Pricing_Account_Division_Nm__c != null){
        return quoteCS.Pricing_Account_Division_Nm__c;
        }else {
            return '';
        }
    }
    @AuraEnabled
    public static void updateQuoteCustomerDivision(String recordId , String accountDivision){
        
        SBQQ__Quote__c quote = [Select Id, Pricing_Account_Division_Nm__c,Pricing_Status_Precedence_Number__c from SBQQ__Quote__c where Id =:recordId];
        if(quote != null && (quote.Pricing_Status_Precedence_Number__c < 45 || quote.Pricing_Status_Precedence_Number__c == null)){
        	quote.Pricing_Account_Division_Nm__c = accountDivision;
        }else{
            throw new AuraHandledException(Label.Pricing_CustomerDivision_Error_Message);
        }
        try {
            update quote; 
        } catch (Exception e) {
            Pricing_Tender_Utility.logError(e);
        }
        
    }
    @AuraEnabled
    public static Boolean getstatusPrecedenceNumber(String recordId){
        try{
        List<SBQQ__Quote__c> quote =[SELECT Id, Pricing_Status_Precedence_Number__c,Pricing_On_Hold_Cb__c FROM SBQQ__Quote__c WHERE id =: recordId];
        if(quote.size()>0 && quote[0].Pricing_Status_Precedence_Number__c >= 45){
            return true;
        }else {
            return false;
        }
        }
        catch(exception ex) {
            Pricing_Tender_Utility.logError(ex);
            return false; 
        }
    }
}