public without sharing class Core_IPS_Opportunity_Handler{

    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 07 Dec 2015
    Function    : 
    Input Parameters: 
    Output Parameters: None
    Transactions: After Insert, After Update
    Description: This method is used to Add IPS Enabled contacts to Project members object 
                 All the accounts added with All Core_member type are added to project member object
    Used in     : Core_IPS_Account_Dispatcher
    Number of Queries Within this Method: 2
    Number of Queries in Loop: 0
    Number of Queries from Called methods:1
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        12/07/2015              Created
    *
    ***************************************************************************************************/ 
    public static void DuplicateRecordprevention(List<Core_IPS_Opportunity__c> newList){
        if(newList <> null && newList.size()>0){
            List<Core_IPS_Opportunity__c> ExistingOpportunities = new List<Core_IPS_Opportunity__c>();
            if(Core_IPS_Opportunity__c.SObjectType.getDescribe().isAccessible()){
                ExistingOpportunities = [Select id,Core_IPS_Project__c,Core_Opportunity__c from Core_IPS_Opportunity__c where Core_IPS_Project__c =: newList[0].Core_IPS_Project__c];       
            }
            if(ExistingOpportunities <> null && ExistingOpportunities.size()>0){
                for(Core_IPS_Opportunity__c NewOpportunity: newList){
                    for(Core_IPS_Opportunity__c ExistingOpportunity: ExistingOpportunities){
                        if(ExistingOpportunity.Core_Opportunity__c == NewOpportunity.Core_Opportunity__c)
                            NewOpportunity.adderror('Cannot add the same Opportunity twice');                
                    }
                }
            }
        }
    }
}