public without sharing class Core_MDF_BudgetAddUp {
    /**********************************************************************************************************************************************
     Method Name : PFRCampaignBudgetWrapper
    
    **********************************************************************************************************************************************/
    
    
        /***************************************************************************************************** 
        Method Name : loadPFRRecord
        @return     : Object
        @parameters : PFR Record
        Description : US106541 - Create Activity initial screen
        Added By    : Nuzhath Zaiba
        Modified By :                      Date:07/25/2018                    Changes:None                                
        ******************************************************************************************************/
        
        @AuraEnabled (cacheable = true)
        public static PFRCampaignBudgetWrapper fetchBudgetCampaignPFRDetails(String recordId){
            String pfrId = null;
            if(recordId != null){
                pfrId = checkIfCampIdorPFRId(recordId);
            }

            PFRCampaignBudgetWrapper pfrCampaignBudgetWrapperInst = new PFRCampaignBudgetWrapper();
            PartnerFundRequest pfrInst = [SELECT id, Core_MDF_Start_Date__c, Core_MDF_End_Date__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,
                                                ChannelPartner.Core_MDF_Channel_Program__c/*,Core_MDF_Budget_Type_txt__c*/
                                                FROM PartnerFundRequest
                                                where id =: pfrId ];
            System.debug('NZ--> pfrInst: '+pfrInst);
            
            if(pfrInst != NULL){
                PartnerMarketingBudget pmb = [SELECT Id, Amount, StartDate, EndDate,Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c
                                              FROM PartnerMarketingBudget
                                              WHERE StartDate <= :pfrInst.Core_MDF_Start_Date__c AND 
                                                    EndDate >= :pfrInst.Core_MDF_End_Date__c AND 
                                                    Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__c = :pfrInst.ChannelPartner.Core_MDF_Channel_Program__c AND
                                                    Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c  =: pfrInst.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c 
                                             LIMIT 1];
                
                if(pmb != NULL){
                    pfrCampaignBudgetWrapperInst.budgetAmount = pmb.Amount;
                }       
                
                Decimal pfrAmnt = 0;
                Map<Id, CampaignPFRWrapper> campPFRWrapperMap = new Map<Id, CampaignPFRWrapper>();
                for(PartnerFundRequest pfrRecord : [SELECT Id, Title, Core_MDF_Program__c,Core_MDF_Start_Date__c, Core_MDF_End_Date__c,Campaign.Id, Campaign.Name,
                                                      Campaign.StartDate, Campaign.EndDate, Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,
                                                      Core_MDF_Ultimate_Account_Name__c, RequestedAmount,Core_MDF_Fund_Request_Status__c,Core_MDF_PFRDetailLink__c
                                                    FROM PartnerFundRequest
                                                    WHERE ChannelPartner.Core_MDF_Channel_Program__c =: pfrInst.ChannelPartner.Core_MDF_Channel_Program__c AND
                                                     Core_MDF_Start_Date__c >: pmb.StartDate AND
                                                     Core_MDF_End_Date__c <: pmb.EndDate AND
                                                     ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c =: pfrInst.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c AND
                                                     Core_MDF_Fund_Request_Status__c != 'Cancelled'
                                                     ORDER BY CampaignId]){
                    if(pfrRecord.Campaign.Id != NULL && pfrRecord.Campaign.Name != NULL){
                        //check if pfrCampaignBudgetWrapperInst has the Campaign record
                        if(campPFRWrapperMap.containsKey(pfrRecord.Campaign.Id)){
                            CampaignPFRWrapper campaignPFRWrapperInst = campPFRWrapperMap.get(pfrRecord.Campaign.Id);
                            campaignPFRWrapperInst.pfrList.add(pfrRecord);
                            campPFRWrapperMap.put(pfrRecord.Campaign.Id, campaignPFRWrapperInst);
                            campaignPFRWrapperInst.totalAmountInCampaign += pfrRecord.RequestedAmount;
                            campaignPFRWrapperInst.campaignName = pfrRecord.Campaign.Name + '     : $' + campaignPFRWrapperInst.totalAmountInCampaign;
                        }
                        else{
                            CampaignPFRWrapper campaignPFRWrapperInst = new CampaignPFRWrapper();
                            campaignPFRWrapperInst.campaignId = 'https://intel--crmdevccp.lightning.force.com/'+pfrRecord.CampaignId;
                            System.debug('NZ-->campaignId: '+campaignPFRWrapperInst.campaignId);
                            campaignPFRWrapperInst.pfrList.add(pfrRecord);
                            campPFRWrapperMap.put(pfrRecord.Campaign.Id, campaignPFRWrapperInst);
                            campaignPFRWrapperInst.totalAmountInCampaign = pfrRecord.RequestedAmount;
                            campaignPFRWrapperInst.campaignName = pfrRecord.Campaign.Name + '               : $' + campaignPFRWrapperInst.totalAmountInCampaign;
                        }
                        pfrAmnt += pfrRecord.RequestedAmount;
                    }
                }
                System.debug('SB--> pfrAmnt: ' + pfrAmnt);
                pfrCampaignBudgetWrapperInst.usedBudgetAmount = pfrAmnt;
                System.debug('SB--> pfrCampaignBudgetWrapperInst.usedBudgetAmount: ' + pfrCampaignBudgetWrapperInst.usedBudgetAmount);
                pfrCampaignBudgetWrapperInst.remainingBudgetAmount = pfrCampaignBudgetWrapperInst.budgetAmount - pfrAmnt;
                pfrCampaignBudgetWrapperInst.remainingBudgetAmount = pfrCampaignBudgetWrapperInst.remainingBudgetAmount.setscale(2);
                pfrCampaignBudgetWrapperInst.campaignIdPFRWrapperList = campPFRWrapperMap.values();
            }
            
            for(CampaignPFRWrapper cpfrWrapper : pfrCampaignBudgetWrapperInst.campaignIdPFRWrapperList){
                //System.debug('SB--> pfrCampaignBudgetWrapperInst.campaignIdPFRWrapperMap.Id: ' + campaignId);
                System.debug('SB--> cpfrWrapper.totalAmountInCampaign: ' + cpfrwrapper.totalAmountInCampaign);
                System.debug('SB--> cpfrWrapper.campaignName: ' + cpfrwrapper.campaignName);
                for(PartnerFundRequest pfr : cpfrWrapper.pfrList){
                    System.debug('SB--> pfrCampaignBudgetWrapperInst.campaignIdPFRWrapperMap.pfr: ' + pfr);
                } 
            }
            return pfrCampaignBudgetWrapperInst;
        } 

        public static String checkIfCampIdorPFRId(String recordId){
            
            String pfrId;
            if(recordId.startsWith('701')){
                PartnerFundRequest pfr = [SELECT id 
                         FROM PartnerFundRequest 
                         WHERE  CampaignId = :recordId
                                LIMIT 1];
                pfrId = pfr.Id;
            }else{
                pfrId = recordId;
            }
            return pfrId;
            
        }
           
        public class PFRCampaignBudgetWrapper{
        
            @AuraEnabled 
            public Decimal budgetAmount = 0;
            @AuraEnabled 
            public Decimal usedBudgetAmount = 0;
            @AuraEnabled 
            public Decimal remainingBudgetAmount = 0;
            @AuraEnabled 
            public List<CampaignPFRWrapper> campaignIdPFRWrapperList = new List<CampaignPFRWrapper>();
        }
        //NZ - Check if we can scale this for Campaign as well by passing the Campaign Id.
        //NZ - Check if Localization needs to be applied on the Activity Status
        //NZ - Scrolling needs to be there
        //NZ - Amount Round Off needs to be there
        //Query pending
        //Amo
        //
        //public class totalPFRAmountPFRListInnerWrapper
        public class CampaignPFRWrapper{
            @AuraEnabled 
            public String campaignName = '';
            @AuraEnabled
            public String campaignId = 'https://intel--crmdevccp.lightning.force.com/lightning/r/Campaign/' ;
            @AuraEnabled
            public Decimal totalAmountInCampaign = 0;
            @AuraEnabled 
            public List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        }
    }