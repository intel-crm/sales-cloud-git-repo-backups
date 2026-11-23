global without sharing class Core_MDF_PartnerShipScoreToDetail implements Database.Batchable<sObject>  {
    global Database.QueryLocator start(Database.BatchableContext batchContext){
        string program ='Retail Marketing Funds';
        string status='Review Completed';
         String strQuery = 'select id,Core_MDF_Score_Nbr__c,'+
             'Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c,'+
             'Core_MDF_Case_Id__r.Core_MDF_Region_SubRegion_txt__c,'+
             'Core_MDF_Case_Id__r.Core_Account_Geo__c,'+
             'Core_MDF_Manual_Recovery_Amount_USD_Amt__c ,'+
             'Core_MDF_Case_Id__r.Core_MDF_Claim_Amount_USD__c'+
             'from Core_MDF_Scorecard__c '+
      		 'WHERE Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c='+program+
			 'AND Core_MDF_Case_Id__r.Core_MDF_Status__c ='+ status+
             ' Core_MDF_Score_Nbr__c <> null';
        
         system.debug('Size in line 16'+strQuery.length());
         return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext BC,  List<Core_MDF_Partnership_Score__c> scope) {
        system.debug('Hi');
    }
    global void finish(Database.BatchableContext BC) {}
    
}