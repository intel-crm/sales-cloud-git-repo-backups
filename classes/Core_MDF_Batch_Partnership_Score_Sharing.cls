/****************************************************************************************************
Apex Class Name : Core_MDF_Batch_Partnership_Score_Sharing
Version         : 1.0 
Created Date    : 
Function        : 
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*               02/05/2022            Created
*****************************************************************************************************/
global Class Core_MDF_Batch_Partnership_Score_Sharing implements Database.Batchable<sObject>
{   
    
    List<Core_MDF_Partnership_Score__c> partnershipScoreSharingList = new List<Core_MDF_Partnership_Score__c>();
    global Core_MDF_Batch_Partnership_Score_Sharing(){}
    //Constructor to receive list of partnership records
    global Core_MDF_Batch_Partnership_Score_Sharing(List<Core_MDF_Partnership_Score__c> partnershipScoreList){
        this.partnershipScoreSharingList=partnershipScoreList;
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        
        String query = 'Select Core_MDF_Account_Id__c,Core_MDF_Account_Id__r.Core_Geo__c,Core_MDF_Account_Id__r.Core_Sub_Geo__c,Core_MDF_Channel_Program_Id__c,Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Channel_Program_Id__r.Name from Core_MDF_Partnership_Score__c '+
            'where Core_MDF_IsRecordShared_ind__c=False';
        //Adding Id filter to have only records which are sent from trigger
        if(!(partnershipScoreSharingList.isEmpty())){
            
            query+=' and Id IN : partnershipScoreSharingList'; 
        }
        return Database.getQueryLocator(String.escapeSingleQuotes(query));
        
    }
    
    global void execute(Database.BatchableContext BC, List<Core_MDF_Partnership_Score__c> listOfPartnershipScore)
    {
        try
        {
            Core_MDF_Partnership_ScoreServiceHandler.shareRecordtoPGMgroups(listOfPartnershipScore);
            Core_MDF_Partnership_ScoreServiceHandler.shareRecordToGeoGroup(listOfPartnershipScore);
            Core_MDF_Partnership_ScoreServiceHandler.updatePartnershipScoreShareFlag(listOfPartnershipScore);
        }
        catch(Exception e){throw e;}
    }   
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
}