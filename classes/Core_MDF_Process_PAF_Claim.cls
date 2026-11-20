/****************************************************************************************************************************************
    * Class Name        : Core_MDF_Process_PAF_Claim 
    * Version           : 1.0 
    * Created Date      : 16-Nov-2018
    * Modification Log  :
    * Developer               Date                          Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Accenture           16-Nov-2018                 Class to process the list of Claims in Pending Available Funds Status to be sent to
      Gaurav                                                      Fund Reservation Method 
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Process_PAF_Claim{
    /****************************************************************************************************** 
    Method Name:        fetchClaimsByAllocationIds
    @return  :          void
    @parameters:        Set<Id>
    Description:        Method to fetch List of Claims in the Pending Available Funds to be sent to Fund Reservations
    Added By:           Accenture GR 
    Modified By:        Date:       Changes: 
  Accenture- VD    05-02-2019  Created Set for recordType and created variable for SPCF record
    *******************************************************************************************************/
    public static void fetchClaimsByAllocationIds(Set<Id> allocationIds){
         /* Get the CoMarketing Record Types for Claims */
            //Record Type Info Map
            //Map<String,Schema.RecordTypeInfo> claimRecordTypeMap = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName(); 
          // Assign CoMarketing Record Types for Claims
          // Set<Id> recordTypeSet = Core_MDF_Claim_Utility.getRecordTypeSet(claimRecordTypeMap);
        
        Map<Id,PartnerFundClaim> claimMap = new Map<Id,PartnerFundClaim>([SELECT Id, ChannelPartnerId,Core_MDF_Status__c, Status,Core_MDF_Currency__c, Core_MDF_Type_Txt__c,Core_MDF_Program__c,Core_MDF_Has_Sub_Claims_Ind__c,Core_MDF_Claim_EvalInProgress_Ind__c 
                                                                          FROM partnerFundClaim 
                                                                          WHERE AllocationId IN: allocationIds 
                                                                          //AND (RecordTypeId IN:recordTypeSet)
                                                                          AND (Core_MDF_Status__c =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Available_Fund') OR Core_MDF_Status__c =:Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted'))
                                                                          ]);

        if(claimMap!=null && claimMap.size()>0){
            Core_MDF_ProcessCCP_Claim.fundReservationCheckOnUpdate(claimMap,null);
         }

    }

}