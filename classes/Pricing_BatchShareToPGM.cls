public class Pricing_BatchShareToPGM implements Database.Batchable<sObject> {
    Set<Id> accIds = new Set<Id>();
    Set<Id> pgmIds = new Set<Id>();
    public Pricing_BatchShareToPGM(Set<Id> accIds,Set<Id> pgmIds){
        this.accIds=accIds;
        this.pgmIds=pgmIds;
    }
    
    public Database.querylocator start(Database.BatchableContext bc){
        Set<Id> recordTypeId = new Set<Id>();
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_RecordType_Edit));
        recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_RecordType_ReadOnly));
        recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_RecordType_Create));
        recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_RecordType_Submitted));
        recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Small_Volume_Quote_Create));
        return Database.getQueryLocator([SELECT Id,SBQQ__Account__c from SBQQ__Quote__c WHERE SBQQ__Account__c IN :accIds AND RecordTypeId IN:recordTypeId]);
    }
    
    public void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> quoteList){
        if(quoteList!=null && !quoteList.isEmpty()){
            Map<Id, SBQQ__Quote__c> pvtMap = new Map<Id, SBQQ__Quote__c>((List<SBQQ__Quote__c>)quoteList);
            Map<Id, SBQQ__Quote__Share> aEsharedQuotes=new map<Id, SBQQ__Quote__Share>();
            Map<Id, Pricing_Comments__Share> aEsharedComments=new map<Id, Pricing_Comments__Share>();
            List<SBQQ__Quote__Share> quoteShares = new List<SBQQ__Quote__Share>();
            List<Pricing_Comments__Share> commentShares = new List<Pricing_Comments__Share>();
            Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
            List<Id> quoteRecordTypes=new List<Id>();
            
            // Get list of accountId's
            Set<Id> accountIds = new Set<Id>();
            for(SBQQ__Quote__c quote : pvtMap.values()){
                accountIds.add(quote.SBQQ__Account__c);
            }
            
            Map<Id,Set<Id>> accountToGroupIdMap = new  Map<Id,Set<Id>>();
            Set<Id> externalGroupIdSet = new  Set<Id>();
            // Get the Map of Quote and Comments
            Map<Id,SBQQ__Quote__c> mapQuotesWithComments = new Map<Id,SBQQ__Quote__c>([SELECT Id, (SELECT Id FROM Comments__r where recordtypeid =: commentRecordTypeId) from SBQQ__Quote__c WHERE Id IN:pvtMap.keySet()]);
            for(Core_MDF_Partner_Group_Mapping__c partnerGroup : [select Id,Core_MDF_Account__c,Core_MDF_Channel_Program_Name_Txt__c,Core_MDF_Channel_Program__c,Core_MDF_AccountIdGroupName__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c from Core_MDF_Partner_Group_Mapping__c where
                                                                  Core_MDF_Channel_Program_Name_Txt__c =: Label.Pricing_Tender_PGM_Channel and   Core_MDF_Account__c in : accountIds and Core_MDF_Group_Id__c!=null and id in :pgmIds]){
                                                                      if(!accountToGroupIdMap.containsKey(partnerGroup.Core_MDF_Account__c)){
                                                                          accountToGroupIdMap.put(partnerGroup.Core_MDF_Account__c,new Set<Id>{partnerGroup.Core_MDF_Group_Id__c});
                                                                      }
                                                                      else {
                                                                          accountToGroupIdMap.get(partnerGroup.Core_MDF_Account__c).add(partnerGroup.Core_MDF_Group_Id__c);
                                                                      }
                                                                      if(partnerGroup.Core_MDF_Type_of_Access__c == 'External'){
                                                                          externalGroupIdSet.add(partnerGroup.Core_MDF_Group_Id__c);
                                                                      }
                                                                  }
            
            for(SBQQ__Quote__c pvt : pvtMap.values()){
                List<Pricing_Comments__c> comments;
                if(accountToGroupIdMap.containsKey(pvt.SBQQ__Account__c) && !(accountToGroupIdMap.get(pvt.SBQQ__Account__c)).isEmpty()){ 
                    // looping through each Account teamember and add that member Id to the UserOrGroupId
                    for(id userId : accountToGroupIdMap.get(pvt.SBQQ__Account__c)){
                        quoteShares.add(new SBQQ__Quote__Share(ParentId = pvt.Id,
                                                               UserOrGroupId = userId,
                                                               AccessLevel = 'edit',
                                                               RowCause = (externalGroupIdSet.contains(userId) ? Schema.SBQQ__Quote__Share.RowCause.Pricing_Partner_Group_Mapping__c : Schema.SBQQ__Quote__Share.RowCause.Pricing_Account_Team_Group__c)));
                        
                        // Get the child comments from Map object for a Quote Id(one quote can have multiple comments)
                        comments = mapQuotesWithComments.get(pvt.Id).Comments__r;
                        if(!comments.isEmpty()){
                            // looping through each Comment for each team member
                            for(Pricing_Comments__c comment : comments){
                                Pricing_Comments__Share commentsShare = new Pricing_Comments__Share();
                                
                                commentShares.add(new Pricing_Comments__Share(ParentId = comment.Id,
                                                                              UserOrGroupId = userId,
                                                                              AccessLevel = 'edit',
                                                                              RowCause = (externalGroupIdSet.contains(userId) ? Schema.SBQQ__Quote__Share.RowCause.Pricing_Partner_Group_Mapping__c : Schema.SBQQ__Quote__Share.RowCause.Pricing_Account_Team_Group__c)));
                            }
                        }
                    }   
                } 
            }
            if(!quoteShares.isEmpty()){
                Database.SaveResult[] lsShareResult = Database.insert(quoteShares ,false);
            }
            if(!commentShares.isEmpty()){
                Database.SaveResult[] lsShareResult = Database.insert(commentShares ,false);
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        // Get the batch job information
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        
    } 
}
/*public static void getListOfQuoteForShare(List<Core_MDF_Partner_Group_Mapping__c> pgmList){
Set<Id> accIds = new Set<Id>();
Set<Id> pgmIds = new Set<Id>();
for(Core_MDF_Partner_Group_Mapping__c pgmRecord: pgmList){
if(pgmRecord.Core_MDF_Account__c!=null && pgmRecord.Core_MDF_Channel_Program_Name_Txt__c == Label.Pricing_Tender_PGM_Channel){
accIds.add(pgmRecord.Core_MDF_Account__c);
pgmIds.add(pgmRecord.Id);
}
}
if(!accIds.isEmpty()){
database.executebatch(new Pricing_BatchShareToPGM(accIds,pgmIds),100);
}        
}*/
//Core_MDF_PGM_ServiceHandler.getListOfQuoteForShare((List<Core_MDF_Partner_Group_Mapping__c>) Trigger.new);