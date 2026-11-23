/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_CommentsDataScrubBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
    public Database.querylocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, (SELECT Id FROM Comments__r where recordtypeid =:commentRecordTypeId),(Select Id,Pricing_Quote_Id__c,Pricing_Quote_Team_Member_Id__c,Pricing_Role_Nm__c from Quote_Teams__r where (Pricing_Role_Nm__c ='Account Executive' OR Pricing_Role_Nm__c ='ITS') and Pricing_Quote_Team_Member_Id__r.isActive= True and Pricing_Grant_Access_Ind__c= True) from SBQQ__Quote__c]);  
    }
    
    public void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> quotesList){
        Set<Id> commsIds = New Set<Id>();
        Set<String> commUserIds = New Set<String>();
        Set<String> sharedcommsIds = New Set<String>();
        List<Pricing_Comments__Share> commentShares = New List<Pricing_Comments__Share>();
        try{
            for(SBQQ__Quote__c quotes : quotesList){
                // Quote Comments 
                for(Pricing_Comments__c comms : quotes.Comments__r){
                    commsIds.add(comms.Id);
                    // Quote Team  
                    for(Pricing_Quote_Team__c team : quotes.Quote_Teams__r){
                        commUserIds.add(comms.Id+'_'+team.Pricing_Quote_Team_Member_Id__c);  
                    }     
                }
            }
            if(commsIds.size()>0){
                for(Pricing_Comments__Share commShare : [SELECT ParentId, UserOrGroupId FROM Pricing_Comments__Share where ParentId in :commsIds]){
                    sharedcommsIds.add(commShare.ParentId+'_'+commShare.UserOrGroupId);  
                }
                if(sharedcommsIds.size()>0){
                    for(string commUser : commUserIds){
                        if(!sharedcommsIds.contains(commUser)){
                            List<string> commsdata = commUser.split('_');
                            commentShares.add(new Pricing_Comments__Share(ParentId = commsdata[0],
                                                                          UserOrGroupId = commsdata[1],
                                                                          AccessLevel = 'edit',
                                                                          RowCause = Schema.Pricing_Comments__Share.RowCause.Manual));
                            
                        }
                    }
                }
                if(commentShares.size()>0){
                    Database.SaveResult[] lsShareResult = Database.insert(commentShares ,false);   
                }
            }
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
    }
    
    public void finish(Database.BatchableContext bc){
        // Get the batch job information
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:bc.getJobId()];     
    }
}