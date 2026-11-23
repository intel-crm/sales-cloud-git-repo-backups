/***********************************************************************************************************************************
* Class Name  : Core_MDF_Queueable_Process_PAF_Claim 
* Version     : 1.0    
* Created Date: 05-24-2021
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - NK      05/24/2021      Queueable class to reserve funds for nodes
*************************************************************************************************************************************/
public class Core_MDF_Queueable_Process_PAF_Claim implements Queueable {
    public Set<Id> allocationIds;
    public Core_MDF_Queueable_Process_PAF_Claim(Set<Id> allocationIds) {
        this.allocationIds = allocationIds;        
    }
    public void execute(QueueableContext context) { 
        If(allocationIds != Null && allocationIds.size()>0 ){
        /* Get the CoMarketing Record Types for Claims */
        //Record Type Info Map
        Map<String,Schema.RecordTypeInfo> claimRecordTypeMap = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName(); 
        // Assign CoMarketing Record Types for Claims
        Set<Id> recordTypeSet = Core_MDF_Claim_Utility.getRecordTypeSet(claimRecordTypeMap);
        //Fetching all claims related to the allocations having status pending available fund or submitted
        //Adding bank hold clause as query was causing lock issue for claims which are being put on bank hold
        // Map<Id,PartnerFundClaim> claimMap = new Map<Id,PartnerFundClaim>([SELECT Id, ChannelPartnerId,Core_MDF_Status__c, Status,Core_MDF_Currency__c, Core_MDF_Type_Txt__c,Core_MDF_Claim_EvalInProgress_Ind__c 
        //                                                                   FROM partnerFundClaim 
        //                                                                   WHERE AllocationId IN: allocationIds 
        //                                                                   AND (RecordTypeId IN:recordTypeSet)
        //                                                                   AND (Core_MDF_Status__c =: Label.Core_MDF_Status_Pending_Available_Fund OR Core_MDF_Status__c =:Label.Core_MDF_Status_Submitted)
        //                                                                   AND (Core_MDF_Bank__r.Core_MDF_ESD_Hold_Indicator__c != true) AND (Core_MDF_Bank__r.Core_MDF_Hold_Payments_from_AP_file_ind__c != 'Yes')
        //                                                                  ]);

        Map<Id,PartnerFundClaim> claimMap = new Map<Id,PartnerFundClaim>([SELECT Id, ChannelPartnerId,Core_MDF_Status__c, Status,Core_MDF_Currency__c, Core_MDF_Type_Txt__c,Core_MDF_Program__c,Core_MDF_Claim_EvalInProgress_Ind__c, Core_MDF_Has_Sub_Claims_Ind__c   //Roshan - Super Claim PIC
                                                                         FROM partnerFundClaim 
                                                                         WHERE AllocationId IN: allocationIds 
                                                                         AND (RecordTypeId IN:recordTypeSet)
                                                                         AND (Core_MDF_Status__c =: Label.Core_MDF_Status_Pending_Available_Fund OR Core_MDF_Status__c =:Label.Core_MDF_Status_Submitted)
                                                                         AND (Core_MDF_Bank__r.Core_MDF_ESD_Hold_Indicator__c = false) 
                                                                         AND (Core_MDF_Bank__r.Core_MDF_Hold_Payments_from_AP_file_ind__c IN ('No', ''))
                                                                        ]);
        
        if(claimMap!=null && claimMap.size()>0){
            Core_MDF_ProcessCCP_Claim.fundReservationCheckOnUpdate(claimMap,null);
        }
        }
    }
}