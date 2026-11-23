/****************************************************************************************************************************************
* Class Name  : Core_MDF_UpdateAllocationIdOnPFR 
* Version     : 1.0 
* Created Date: 11-5-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       7/22/2018          Updating Allocation and Budget on existing PFRs
*****************************************************************************************************************************************/
public class Core_MDF_UpdateAllocationIdOnPFR implements Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    
    //Create String to strore ids of processed records
    /*public String mailBodyForProcessed = '';
    
    //Create String to strore ids of un-processed records
    public String mailBodyForUnprocessed = '';
    
    //Will be used in to separate the Ids
    public static String commaStr = ', ';*/
    
    //Will be used in the query
    public static String spaceStr = ' ';
    
    //Will be used in the mailbody
    /*public static String equalStr = ' = ';
    
    //Will be used in the query
    public static String singleQuoteStr = '\'';*/
    
    /***************************************************************************************************** 
    Method Name :   start
    @return     :   List<PartnerFundRequest>
    @parameters :   Database.BatchableContext
    Description :   US212854 - Updating Allocation on existing PFRs
    Added By    :   Accenture - SB 
    Modified By :                      Date:11/09/2018                     Changes:None                               
    ******************************************************************************************************/  
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            //SELECT Id, Core_MDF_Start_Date__c, Core_MDF_End_Date__c, CampaignId, ChannelPartnerId, RecordTypeId, AllocationId,
            //       ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c
            //FROM PartnerFundRequest
            //WHERE AllocationId = NULL AND
            //      CampaignId != NULL
            Label.Core_MDF_UpdateAllocationIdOnPFR_Query1 + spaceStr +
            Label.Core_MDF_UpdateAllocationIdOnPFR_Query2 + spaceStr +
            Label.Core_MDF_UpdateAllocationIdOnPFR_Query3 + spaceStr + 
            Label.Core_MDF_UpdateAllocationIdOnPFR_Query4 + spaceStr +
            Label.Core_MDF_UpdateAllocationIdOnPFR_Query5 + spaceStr +
            ' AND Core_MDF_Fund_Request_Status__c != ' + '\'' + 'Pending Review' + '\'' + 
            ' AND Core_MDF_Fund_Request_Status__c != ' + '\'' + 'Cancelled' + '\'' + 
            ' AND Core_MDF_Start_Date__c != NULL' +
            ' AND Core_MDF_End_Date__c != NULL' + 
            ' AND ChannelPartnerId != NULL' +          
            ' ORDER BY CreatedDate'
        );
    }
    
    /***************************************************************************************************** 
    Method Name :   execute
    @return     :   void
    @parameters :   Database.BatchableContext,List<PartnerFundRequest>
    Description :   US212854 - Updating Allocation on existing PFRs
    Added By    :   Accenture - SB 
    Modified By :                      Date:11/09/2018                     Changes:None                               
    ******************************************************************************************************/ 
    
    public void execute(Database.BatchableContext bc, List<PartnerFundRequest> scope){
        // process each batch of records
        //fundAllocationCreation(scope);              
    }
    
    /***************************************************************************************************** 
    Method Name :   finish
    @return     :   void
    @parameters :   Database.BatchableContext
    Description :   US212854 - Updating Allocation on existing PFRs
    Added By    :   Accenture - SB 
    Modified By :                      Date:11/09/2018                     Changes:None                               
    ******************************************************************************************************/
    
    public void finish(Database.BatchableContext bc){
        /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses  = new List<String>();
        toAddresses.add(Label.Core_MDF_UpdateAllocationIdOnPFR_EmailTo);
        mail.setToAddresses(toAddresses);
        mail.setSubject(Label.Core_MDF_UpdateAllocationIdOnPFR_EmailSubject);
        mailBodyForProcessed.removeEnd(commaStr);
        mailBodyForUnprocessed.removeEnd(commaStr);
        mail.setPlainTextBody(Label.Core_MDF_UpdateAllocationIdOnPFR_EmailBody1 + spaceStr + 
                              mailBodyForProcessed + '\n\n' + Label.Core_MDF_UpdateAllocationIdOnPFR_EmailBody2 + 
                              Label.Core_MDF_UpdateAllocationIdOnPFR_EmailBody1 + spaceStr + mailBodyForUnprocessed);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});*/
    }
    
    /***************************************************************************************************** 
    Method Name :   fundAllocationCreation
    @return     :   Allocation Id
    @parameters :   PartnerFundRequest object
    Description :   US212854 - Updating Allocation on existing PFRs
    Added By    :   Accenture - SB 
    Modified By :                      Date:11/09/2018                     Changes:None                               
    ******************************************************************************************************/
    /*public void fundAllocationCreation(List<PartnerFundRequest> pfrList)
    { 
        try{
            //This will return the sobject
            Schema.DescribeSObjectResult resSchema = PartnerFundAllocation.sObjectType.getDescribe();
            
            //Create Map to hold recordtype information related to PartnerFundAllocation
            Map<String,Schema.RecordTypeInfo>  recordTypeInfo = resSchema.getRecordTypeInfosByDeveloperName();
            
            //Create Id to store CCF recordtype Id
            Id ccfPFARecordTypeId = recordTypeInfo.get(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Zero_Bdgt_Alloctn_Rcrd_Type_CCF')).getRecordTypeId();
            
            //Create Id to store DCF recordtype Id
            Id dcfPFARecordTypeId = recordTypeInfo.get(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Zero_Bdgt_Alloctn_Rcrd_Type_DCF')).getRecordTypeId();

            resSchema = NULL;
            recordTypeInfo = NULL;
            resSchema = PartnerFundRequest.sObjectType.getDescribe();
            recordTypeInfo = resSchema.getRecordTypeInfosByDeveloperName();
            
            //Create Id to store CCF recordtype Id of PartnerFundRequest
            Id ccfPFRRecordTypeId = recordTypeInfo.get(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_CCF')).getRecordTypeId();
            
            //Create Id to store DCF recordtype Id of PartnerFundRequest
            Id dcfPFRRecordTypeId = recordTypeInfo.get(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_DCF')).getRecordTypeId();
            
            //Map of PFRId and PMB
            Map<Id,PartnerMarketingBudget> pFRIdPMBMap = new Map<Id,PartnerMarketingBudget>();

            //List of PFRs which will be updated
            List<PartnerFundRequest> pfrListToBeUpdated = new List<PartnerFundRequest>();

            //Map of pfrId and AllocationId
            Map<Id,Id> pfrIdAllocationIdMap = new Map<Id,Id>();
            
            //Map of pfrId and CampaignId
            Map<Id,Id> pfrIdCampaignIdMap = new Map<Id,Id>();

            Map<Id,PartnerFundRequest> pfrMapToBeUpdated = new Map<Id,PartnerFundRequest>();

            //Set of AccountIds from PFR
            Set<Id> accountIdSet = new Set<Id>();

            //Map of pfrId and PFR record itself
            Map<Id,PartnerFundRequest> pFRIdPFRMap = new Map<Id,PartnerFundRequest>();
            for(PartnerFundRequest pfrRecord : pfrList){
                pfrIdCampaignIdMap.put(pfrRecord.Id, pfrRecord.CampaignId); //this will be used in a query below
                accountIdSet.add(pfrRecord.ChannelPartnerId); //this will be used in a query below
                pFRIdPFRMap.put(pfrRecord.Id, pfrRecord);
            }
            
            //Map<CampaignId, AccountId>;
            Map<Id,Id> campaignIdAccountIdMap = new Map<Id,Id>();
            for(Campaign campaignRecord : [SELECT Id, Core_MDF_Account__c
                                           FROM Campaign
                                           WHERE Id IN: pfrIdCampaignIdMap.values()]){
                campaignIdAccountIdMap.put(campaignRecord.Id, campaignRecord.Core_MDF_Account__c);
            }

            if(campaignIdAccountIdMap.size() > 0){
                //SELECT Id, Title FROM PartnerMarketingBudget WHERE StartDate <= pfr.Core_MDF_Start_Date__c.format(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Date_Format')) AND EndDate >= pfr.Core_MDF_End_Date__c.format(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Date_Format')) AND Core_MDF_Budget_Partner__c = campaignList[0].Core_MDF_Account__c AND Core_MDF_Budget_Status__c = 'Released'
                //Create string to hold dynamic query to retrieve budget details
                Map<Id,List<PartnerMarketingBudget>> accountIdPMBsMap = new Map<Id,List<PartnerMarketingBudget>>();
                for(PartnerMarketingBudget pmb : [SELECT Id, Title,Core_MDF_Budget_Partner__c, StartDate, EndDate, 
                                                         Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c
                                                  FROM PartnerMarketingBudget 
                                                  WHERE Core_MDF_Budget_Partner__c IN :campaignIdAccountIdMap.values()]){
                    if(accountIdPMBsMap.containsKey(pmb.Core_MDF_Budget_Partner__c)){
                        accountIdPMBsMap.get(pmb.Core_MDF_Budget_Partner__c).add(pmb);
                    }
                    else{
                        accountIdPMBsMap.put(pmb.Core_MDF_Budget_Partner__c, new List<PartnerMarketingBudget>{pmb});
                    }
                }
                
                Map<Id,List<PartnerFundRequest>> pMBIdPFRsMap = new Map<Id,List<PartnerFundRequest>>();
                
                //populate pFRIdPMBMap and pMBIdPFRsMap
                if(accountIdPMBsMap.size() > 0){
                    for(PartnerFundRequest pfrRecord : pfrList){
                        Datetime sd = pfrRecord.Core_MDF_Start_Date__c;
                        Datetime ed = pfrRecord.Core_MDF_End_Date__c;
                        String startDate = sd.format(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Date_Format'));            
                        String endDate = ed.format(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Date_Format'));
                        if(pfrIdCampaignIdMap.get(pfrRecord.Id) != NULL && 
                           campaignIdAccountIdMap.get(pfrIdCampaignIdMap.get(pfrRecord.Id)) != NULL && 
                           accountIdPMBsMap.get(campaignIdAccountIdMap.get(pfrIdCampaignIdMap.get(pfrRecord.Id))) != NULL){
                            
                            for(PartnerMarketingBudget pmb : accountIdPMBsMap.get(campaignIdAccountIdMap.get(pfrIdCampaignIdMap.get(pfrRecord.Id)))){
                                if(pmb.StartDate <= Date.valueOf(startDate) && pmb.EndDate >= Date.valueOf(endDate) && 
                                   pfrRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c == pmb.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c){
                                    if(pMBIdPFRsMap.containsKey(pmb.Id)){
                                        pMBIdPFRsMap.get(pmb.Id).add(pfrRecord);
                                    }
                                    else{
                                        pMBIdPFRsMap.put(pmb.Id, new List<PartnerFundRequest>{pfrRecord});
                                    }
                                    pFRIdPMBMap.put(pfrRecord.Id,pmb);
                                    //pFRIdPFRMap.remove(pfrRecord.Id);
                                }
                            }
                        }
                        else if(accountIdPMBsMap.get(campaignIdAccountIdMap.get(pfrIdCampaignIdMap.get(pfrRecord.Id))) == NULL){
                            mailBodyForUnprocessed += pfrRecord.Id + equalStr + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_UpdateAllocatnIdOnPFR_NoBgt_Fnd') + commaStr;
                        }
                    }
                }
                
                Map<Id,Id> pFRIdPFAIdMap = new Map<Id,Id>();
                for(PartnerFundAllocation pfa : [SELECT Id, BudgetId, ChannelPartnerId
                                                 FROM PartnerFundAllocation
                                                 WHERE BudgetId IN: pMBIdPFRsMap.keySet() AND
                                                       ChannelPartnerId IN :accountIdSet
                                                 ORDER BY LastModifiedDate DESC]){
                    for(PartnerFundRequest pfr : pMBIdPFRsMap.get(pfa.BudgetId)){
                        if(pfa.ChannelPartnerId == pfr.ChannelPartnerId){
                            pfrMapToBeUpdated.put(pfr.Id,new PartnerFundRequest(Id = pfr.Id, AllocationId = pfa.Id));
                            pfrIdAllocationIdMap.put(pfr.Id, pfa.Id);
                            pFRIdPMBMap.remove(pfr.Id);
                            pFRIdPFRMap.remove(pfr.Id);
                        }
                    }
                }
                                
                Map<Id,PartnerFundAllocation> pFRIdPFAMap = new Map<Id,PartnerFundAllocation>();
                Map<String,PartnerFundAllocation> budgetIdAccountIdPFAMap = new Map<String,PartnerFundAllocation>();
                Map<String,List<PartnerFundRequest>> budgetIdAccountIdPFRListMap = new Map<String,List<PartnerFundRequest>>();
                if(pFRIdPMBMap.size() > 0){
                    for(Id pfrId : pFRIdPMBMap.keySet()){
                        PartnerFundRequest pfrRecord = pFRIdPFRMap.get(pfrId);
                        String budgetIdAccountIdStr = pFRIdPMBMap.get(pfrId).Id;
                        if(pfrRecord != NULL){
                            budgetIdAccountIdStr += pfrRecord.ChannelPartnerId;
                            if(!(budgetIdAccountIdPFAMap.containsKey(budgetIdAccountIdStr))){                            
                                budgetIdAccountIdPFRListMap.put(budgetIdAccountIdStr, new List<PartnerFundRequest>{pfrRecord});
                                if(dcfPFRRecordTypeId.equals(pfrRecord.RecordTypeId)){
                                    budgetIdAccountIdPFAMap.put(budgetIdAccountIdStr, 
                                                                new PartnerFundAllocation(Title = pFRIdPMBMap.get(pfrId).Title,
                                                                                        Amount = 0,
                                                                                        BudgetId = pFRIdPMBMap.get(pfrId).Id,
                                                                                        ChannelPartnerId = pfrRecord.ChannelPartnerId,
                                                                                        RecordTypeId = dcfPFARecordTypeId)); 
                                } 
                                else if(ccfPFRRecordTypeId.equals(pfrRecord.RecordTypeId)){                            
                                    budgetIdAccountIdPFAMap.put(budgetIdAccountIdStr, 
                                                                new PartnerFundAllocation(Title = pFRIdPMBMap.get(pfrId).Title,
                                                                                        Amount = 0,
                                                                                        BudgetId = pFRIdPMBMap.get(pfrId).Id,
                                                                                        ChannelPartnerId = pfrRecord.ChannelPartnerId,
                                                                                        RecordTypeId = ccfPFARecordTypeId));                   
                                }
                            }
                            else{
                                budgetIdAccountIdPFRListMap.get(budgetIdAccountIdStr).add(pfrRecord);
                            }
                        }
                    }
                    
                    if(budgetIdAccountIdPFAMap.values().size() > 0){
                        //insert the Allocations created above
                        insert budgetIdAccountIdPFAMap.values();
                        for(String budgetIdAccountIdStr : budgetIdAccountIdPFAMap.keySet()){
                            for(PartnerFundRequest pfrRecord : budgetIdAccountIdPFRListMap.get(budgetIdAccountIdStr)){
                                pfrMapToBeUpdated.put(pfrRecord.Id,new PartnerFundRequest(Id = pfrRecord.Id, 
                                                                                   AllocationId = budgetIdAccountIdPFAMap.get(budgetIdAccountIdStr).Id));
                                pfrIdAllocationIdMap.put(pfrRecord.Id, budgetIdAccountIdPFAMap.get(budgetIdAccountIdStr).Id);
                                pFRIdPFRMap.remove(pfrRecord.Id);
                            }
                        }
                        budgetIdAccountIdPFRListMap = NULL;
                        budgetIdAccountIdPFRListMap = NULL;
                    }
                }                
            }
            for(PartnerFundRequest pfrRecord : pfrList){
                if (pFRIdPFRMap.containsKey(pfrRecord.Id)) {
                    pfrRecord.Core_MDF_Log__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_UpdateAllocatnIdOnPFR_NoBgt_Fnd');
                    pfrMapToBeUpdated.put(pfrRecord.Id, pfrRecord);
                    mailBodyForUnprocessed += pfrRecord.Id + equalStr + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_UpdateAllocatnIdOnPFR_NoBgt_Fnd') + commaStr;
                }
            }
            List<Database.SaveResult> updateResults = Database.update(pfrMapToBeUpdated.values(), false);
            for(Integer i=0; i < updateResults.size(); i++){
                if (updateResults.get(i).isSuccess() && pfrIdAllocationIdMap.get(updateResults.get(i).getId()) != NULL){
                    updateResults.get(i).getId();
                    mailBodyForProcessed += updateResults.get(i).getId() + commaStr;
                }
                else if (!updateResults.get(i).isSuccess()){
                    // Operation failed, so get all errors
                    Database.Error error = updateResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    pfrList.get(i);//failed record from the list
                    if(!mailBodyForUnprocessed.contains(pfrList.get(i).Id))
                        mailBodyForUnprocessed += pfrList.get(i).Id + equalStr + failedDML + commaStr;
                }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }*/
}