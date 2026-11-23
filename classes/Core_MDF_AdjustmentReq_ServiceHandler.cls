/*  
* Class Name  : Core_MDF_AdjustmentReq_ServiceHandler 
* Version     : 1.0 - DevCCP
* Modification Log :
* Developer               Date                          Description 
* -----------------------------------------------------------------------------------------------------------------------------------------------------
*  Intel - Areefa                 31-May-2019                   Created Core_MDF_AdjustmentReq_ServiceHandler for creating negative claims
------------------------------------------------------------------------------------------------------------------------------------------------------- */
public without sharing class Core_MDF_AdjustmentReq_ServiceHandler {
    
    public static Map<Id,PartnerFundClaim> claimMap;
    public static Map<String,String> claimReasonTypeMap = new Map<String,String>();
    public static String errorMessage = ''; 
    public static Set<ID> claimIdSet = new Set<Id>();
    /****************************************************************************************************** 
Method Name:        CreateAdjustmentRequest
@return  :          NA
@parameters:        List<Core_MDF_Adjustment_Request__c>
Description:        This method is used to create and save new adjustment claim .
Added By:           Intel  - Areefa  - 31/May/2019
Modified By:        Intel  - Sarah   - 09/Jun/2019
Modified By:        Intel  - Areefa  - 25/Jun/2019
Modified By:        Intel  - Areefa  - 01/Jul/2019  - Escalation Id stamp to Postive claims
*******************************************************************************************************/
    
    public static void createAdjustment(List<Core_MDF_Adjustment_Request__c> adjustmentRequestLst)
    {
        //1. Get all Claim Ids       
        
        Set<String> adjReasonSet = new Set<String>();
        
        for(Core_MDF_Adjustment_Request__c adjReq : adjustmentRequestLst)
        {
            adjReq.Core_MDF_Adjustment_Status_nm__c = Label.Core_MDF_Status_Approved;
            claimIdSet.add(adjReq.Core_MDF_Reference_Claim_Nbr__c);
            adjReasonSet.add(adjReq.Core_MDF_Reason_Cd__c);
        }
        
        // 2. Query all claims  
        claimMap = new Map<Id,PartnerFundClaim> ([SELECT Id,Title,Request.Title,Request.Core_MDF_Activity_Number__c,Core_MDF_AccountCompany__c,Core_MDF_Claim_Ref_Number__c,Core_MDF_Reimbursement_Percent__c,
                                                  Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Country_Location_nm__c,Core_MDF_Ad_Run_End_Date__c, Core_MDF_Media_Vehicle__c,Core_MDF_Invoice_Date__c,Core_MDF_Bank__r.Name,RecordTypeId
                                                  FROM PartnerFundClaim
                                                  WHERE Id IN :claimIdSet]);
        //3. Retrived all metadata  
        List<Core_MDF_AdjustmentOrEscalationClaim__mdt> reasonAndTypeList = [SELECT Core_MDF_Reason_txt__c,Core_MDF_Type_txt__c  
                                                                             FROM Core_MDF_AdjustmentOrEscalationClaim__mdt
                                                                             WHERE Core_MDF_Reason_txt__c IN :adjReasonSet];
        
        //4. Mapping Type and reason
        for(Core_MDF_AdjustmentOrEscalationClaim__mdt reasonType : reasonAndTypeList){
            claimReasonTypeMap.put(reasonType.Core_MDF_Reason_txt__c,reasonType.Core_MDF_Type_txt__c);
        }    
        // 5. Preparing list of Negative and Postive AdjustmentRequest
        List<Core_MDF_Adjustment_Request__c> negativeAdjustmentLst = new List<Core_MDF_Adjustment_Request__c>(); // List holds negtive Adjustment
        List<Core_MDF_Adjustment_Request__c> postiveAdjustmentLst = new List<Core_MDF_Adjustment_Request__c>();  // List holds postive Adjustment        
        for( Core_MDF_Adjustment_Request__c adjReq : adjustmentRequestLst )
        {
            if(claimReasonTypeMap.get(adjReq.Core_MDF_Reason_Cd__c).equals(Label.Core_MDF_Claim_Adjustment_Type)){ 
                negativeAdjustmentLst.add(adjReq);
            }
            else{
                postiveAdjustmentLst.add(adjReq);
            }
        }
        //For Unique reference claims, an Adjustments or Escalations can be created
        if(adjustmentRequestLst.size() == claimIdSet.size()){
            if(negativeAdjustmentLst != null && negativeAdjustmentLst.size() > 0 ){
                createNegativeAdjustments(negativeAdjustmentLst);
            }
            if(postiveAdjustmentLst != null && postiveAdjustmentLst.size() > 0){
                createPositiveAdjustments(postiveAdjustmentLst);
            }
        }else{
            for(Core_MDF_Adjustment_Request__c adjReq : adjustmentRequestLst)
            {
                adjReq.addError(Label.Core_MDF_DuplicateRefClaimForAdjustement);
            }
        }
    } 
    
    //Common method to setBasicClaimFields
    public static PartnerFundClaim setBasicClaimFields(PartnerFundClaim claim){             
        try{
            claim = claimMap.get(claim.Id);
            claim.Id= null;                                                                         // To Create Negative claim,make Existing claim ID as 'null'
            claim.Core_MDF_Claim_Ref_Number__c = null;                                              // Claim comments
            claim.Core_MDF_Claim_Comments__c =null;                                                 // comments as null
            claim.Core_MDF_OtherCostsnotReimbursable_Local__c=0.00;                                 // Other Cost
            claim.Core_MDF_Taxes_Local__c=0.00;                                                     // Tax
            claim.Core_MDF_Invoice_Number__c= '0';                                                  // Invoice number
            claim.Status = Label.Core_MDF_Status_Submitted;                                         // Submitted 
            claim.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;                // Pending Available Fund 
            claim.Core_MDF_Currency__c = Label.Core_MDF_PFR_Output_Currency;                        // USD
            claim.Core_MDF_Claim_Previous_Status__c = Label.Core_MDF_Status_Submitted;              // Previous Status = Submitted           
            return claim; }catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    
    //Negative Claim:
    public static void createNegativeAdjustments(List<Core_MDF_Adjustment_Request__c> negativeAdjustmentList)  
    {        
        //To hold adjustment claims
        List<PartnerFundClaim> adjClaimList = new List<PartnerFundClaim>();
        
        //Map of adjustment claims
        Map<Core_MDF_Adjustment_Request__c, PartnerFundClaim> adjRequestIdToAdjClaimMap = new Map<Core_MDF_Adjustment_Request__c, PartnerFundClaim>();
        //Map of adjustmenmt claim to adjustment request
        Map<PartnerFundClaim,Core_MDF_Adjustment_Request__c> adjClaimToAdjReqMap = new Map<PartnerFundClaim,Core_MDF_Adjustment_Request__c>();
        //Map of exisiting reference claim
        Map<Id,Id> refClaimIdToClaimOwnerIdMap = new Map<Id,Id>();
        
        List<PartnerFundClaim> partnerFundClaimList = [Select Id,OwnerId from partnerFundClaim where Id IN:claimIdSet];
        for(PartnerFundClaim pfc : partnerFundClaimList){
            refClaimIdToClaimOwnerIdMap.put(pfc.Id,pfc.OwnerId);
        }
        
        //Map of exisitng user
        Map<Id,User> userIdToUserMap =New Map<Id,User>([Select id,LanguageLocaleKey from User where Id IN:refClaimIdToClaimOwnerIdMap.values()]);
        try
        {
            for( Core_MDF_Adjustment_Request__c adjReq : negativeAdjustmentList ){
                PartnerFundClaim newNegativeClaim = setBasicClaimFields(claimMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c));  
                newNegativeClaim.Core_MDF_Type_Txt__c = claimReasonTypeMap.get(adjReq.Core_MDF_Reason_Cd__c);           // Type
                newNegativeClaim.Core_MDF_Total_Invoice_Amount_Local__c = adjReq.Core_MDF_Amount_Amt__c;// Map Adjustment Request Amount to Claim Tot Invoice Amount
                // To populate Owner Language Locale over claim field by referring to LanguageLocaleKey of reference claim owner.
                if(refClaimIdToClaimOwnerIdMap.containsKey(adjReq.Core_MDF_Reference_Claim_Nbr__c)){
                    //to store owner's language locale key
                    newNegativeClaim.Core_MDF_Owner_LanguageLocaleKey_Cd__c =
                        userIdToUserMap.containsKey(refClaimIdToClaimOwnerIdMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c)) ?
                        userIdToUserMap.get(refClaimIdToClaimOwnerIdMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c)).LanguageLocaleKey : Label.Core_English_Language_Locale_Key;
                }               
                newNegativeClaim = negativeClaim(newNegativeClaim);                                
                adjClaimList.add(newNegativeClaim);	
                // Attach newly created NegativeClaim object to an AdjRequest
                adjRequestIdToAdjClaimMap.put(adjReq, newNegativeClaim);
                //Attach AdjRequest to NegativeClaim object 
                adjClaimToAdjReqMap.put(newNegativeClaim, adjReq);				
            }
            //Inserting adjustment claim and displaying error if any
            if(negativeAdjustmentList!=null && negativeAdjustmentList.size()>0 &&
               adjClaimList!=null && adjClaimList.size()>0 &&
               adjClaimToAdjReqMap!=null && adjClaimToAdjReqMap.size()>0 &&
               adjRequestIdToAdjClaimMap!=null && adjRequestIdToAdjClaimMap.size()>0){
            insertAdjClaimAndDisplayErrorOnAdjRequest(negativeAdjustmentList,adjClaimList,
                                            		adjClaimToAdjReqMap,adjRequestIdToAdjClaimMap);
            }
          
        } catch(Exception e){
            //Exception 
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    //Negative  claim  creation method 
    public static PartnerFundClaim negativeClaim(PartnerFundClaim claim){
        try{
            String adjTitlePrefix = Label.Core_MDF_Adjustment_Title ;                 // Title = [Adjustment] Name_Of_claim
            claim.Title = adjTitlePrefix + ' ' + claim.Title;     
            Double amt = claim.Core_MDF_Total_Invoice_Amount_Local__c;
            claim.Core_MDF_Total_Invoice_Amount_Local__c = - (claim.Core_MDF_Total_Invoice_Amount_Local__c);
            claim.Amount = - (amt); 
            return claim; }catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    //Postive Claim:
    public static void createPositiveAdjustments(List<Core_MDF_Adjustment_Request__c> postiveAdjustmentLst)  
    {
        
        List<PartnerFundClaim> postiveAdjustment = new List<PartnerFundClaim>();
        Map<Core_MDF_Adjustment_Request__c, PartnerFundClaim> postiveAdjReqClaimMap = new Map<Core_MDF_Adjustment_Request__c, PartnerFundClaim>();
        //Map of adjustmenmt claim to adjustment request
        Map<PartnerFundClaim,Core_MDF_Adjustment_Request__c> adjClaimToAdjReqMap = new Map<PartnerFundClaim,Core_MDF_Adjustment_Request__c>();
        for( Core_MDF_Adjustment_Request__c adjReq : postiveAdjustmentLst ){
            
            PartnerFundClaim newPositiveClaim = setBasicClaimFields(claimMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c));
            
            newPositiveClaim.Core_MDF_Type_Txt__c = claimReasonTypeMap.get(adjReq.Core_MDF_Reason_Cd__c);           // Type
            newPositiveClaim.Core_MDF_Total_Invoice_Amount_Local__c = adjReq.Core_MDF_Amount_Amt__c;                // Map Adjustment Request Amount to Claim Tot Invoice Amount
            newPositiveClaim = positiveClaim(newPositiveClaim); 
            system.debug('adjReq.Core_MDF_Escalation_Id__c -->' +adjReq.Core_MDF_Escalation_Id__c);
            // Map Adjustment Object EscalationId to Claim Object Escaltion Id
            if(adjReq.Core_MDF_Escalation_Id__c != null){
                newPositiveClaim.Core_MDF_Escalation_Id__c  = adjReq.Core_MDF_Escalation_Id__c;                     // Escaltion Id 
            } 
            
            postiveAdjustment.add(newPositiveClaim);            
            // postiveAdjReqClaimMap  holds (Adjustement Request Id, claim :which we constructed above)
            postiveAdjReqClaimMap.put(adjReq, newPositiveClaim);
            //Attach AdjRequest to Positive Claim object 
            adjClaimToAdjReqMap.put(newPositiveClaim, adjReq);
        }
        //Inserting adjustment claim and displaying error if any
        if(postiveAdjustmentLst!=null && postiveAdjustmentLst.size()>0 &&
           postiveAdjustment!=null && postiveAdjustment.size()>0 &&
           adjClaimToAdjReqMap!=null && adjClaimToAdjReqMap.size()>0 &&
           postiveAdjReqClaimMap!=null && postiveAdjReqClaimMap.size()>0){
               insertAdjClaimAndDisplayErrorOnAdjRequest(postiveAdjustmentLst,postiveAdjustment,
                                                         adjClaimToAdjReqMap,postiveAdjReqClaimMap);
           }
    }
    
    
    //Positive  claim  creation method 
    public static PartnerFundClaim positiveClaim(PartnerFundClaim claim){
        try{
            String escalationTitlePrefix = Label.Core_MDF_Escalation_Title ;                           // Title = [Escalation] Name_Of_claim
            claim.Title = escalationTitlePrefix + ' ' + claim.Title;     
            if(claim.Core_MDF_Reimbursement_Percent__c != null){
                String reimbursementPercent = claim.Core_MDF_Reimbursement_Percent__c.removeEnd('%');                
                // Calculate the total invoice amount from Reimbursement Rate and Requested adjustment Amount
                claim.Core_MDF_Total_Invoice_Amount_Local__c  = ((claim.Core_MDF_Total_Invoice_Amount_Local__c  *100)/double.valueOf(reimbursementPercent)); 
            }                     
            claim.Core_MDF_IsClaimReviewEscalation_Ind__c  = true;      // Claim of type escalation            
            return claim; } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    } 
    
    /***************************************************************************************************** 
    Method Name:        cancelAdjustmentRequest 
    @return  :          void 
    @parameters:        
    Description:        This method is used to check if any offset exists during Adjustment Request Cancellation
    Added By:           Accenture - AH - 02/03/2020
    Modified By:        Date:       Changes:  
    ******************************************************************************************************/    
    public static void cancelAdjustmentRequest(Map<Id,Core_MDF_Adjustment_Request__c> oldAdjRequestMap, Map<Id,Core_MDF_Adjustment_Request__c> newAdjRequestMap){
        system.debug('inside cancel::');
        Map<Id,Core_MDF_Adjustment_Request__c> adjRequestToAdjClaimMap = new Map<Id,Core_MDF_Adjustment_Request__c>();
        Set<Id> adjustmentClaimIdsWithOffset = new Set<Id>();
        Set<Id> adjustmentClaims = new Set<Id>();
        List<Core_MDF_Claim_Offset__c> offsetRecordList = new List<Core_MDF_Claim_Offset__c>();
        List<PartnerFundClaim> adjClaimList = new List<PartnerFundClaim>();
        List<PartnerFundClaim> listOfClaimsToBeCancelled = new List<PartnerFundClaim>();
        
        for( Core_MDF_Adjustment_Request__c adjReq : newAdjRequestMap.values() ){
            if(oldAdjRequestMap.get(adjReq.Id).Core_MDF_Adjustment_Status_nm__c != newAdjRequestMap.get(adjReq.Id).Core_MDF_Adjustment_Status_nm__c && newAdjRequestMap.get(adjReq.Id).Core_MDF_Adjustment_Status_nm__c.equals(Label.Core_MDF_Status_Cancelled)){
                adjRequestToAdjClaimMap.put(adjReq.Id,adjReq);
                adjustmentClaims.add(adjReq.Core_MDF_Adjustment_Claim_Nbr__c);  
            }
        }
        
        Map<Id,PartnerFundClaim> partnerFundClaimMap = new Map<Id,PartnerFundClaim>([Select id,Core_MDF_Type_Txt__c,Core_MDF_Status__c from PartnerFundClaim where id in : adjustmentClaims]);
        
        if(adjRequestToAdjClaimMap!=null && adjRequestToAdjClaimMap.size()>0 && partnerFundClaimMap!=null && partnerFundClaimMap.size()>0){
            offsetRecordList = [select id,Core_MDF_Adjustment_Claim_Nbr__c,Core_MDF_Adjustment_Claim_Nbr__r.Core_MDF_Status__c,Core_MDF_Adjustment_Claim_Nbr__r.Core_MDF_Type_Txt__c  from Core_MDF_Claim_Offset__c where Core_MDF_Adjustment_Claim_Nbr__c IN : adjustmentClaims ];
        }
        
        if(offsetRecordList!=null && offsetRecordList.size()>0){
            for (Core_MDF_Claim_Offset__c claimOffsetRecord : offsetRecordList){
                adjustmentClaimIdsWithOffset.add(claimOffsetRecord.Core_MDF_Adjustment_Claim_Nbr__c);
            }
        }
        
        for(Core_MDF_Adjustment_Request__c adjRequest : adjRequestToAdjClaimMap.values()){
            if(partnerFundClaimMap.get(adjRequest.Core_MDF_Adjustment_Claim_Nbr__c).Core_MDF_Type_Txt__c.equals(Label.Core_MDF_Negative_Claim)){
                if(adjustmentClaimIdsWithOffset!=null && adjustmentClaimIdsWithOffset.size()>0 && adjustmentClaimIdsWithOffset.contains(adjRequestToAdjClaimMap.get(adjRequest.Id).Core_MDF_Adjustment_Claim_Nbr__c)){
                    adjRequest.addError(Label.Core_MDF_AdjustmentRequest_Cancel_Error);
                }
            }else{
                adjRequest.addError(Label.Core_MDF_AdjustmentRequest_Cancel_Reason_Error);
            }
        }
    } 
    /***************************************************************************************************** 
    Method Name:        insertAdjClaimAndDisplayErrorOnAdjRequest 
    @return  :          void 
    @parameters:        
    Description:        This method is used insert adjustment claim and display error on adjustment request if any
    Added By:           Accenture - AD - 02/18/2020
    Modified By:        Date:       Changes:  
    ******************************************************************************************************/    
    public static void insertAdjClaimAndDisplayErrorOnAdjRequest(List<Core_MDF_Adjustment_Request__c> adjustmentRequestList,
                                                       List<PartnerFundClaim> adjClaimList,
                                                       Map<PartnerFundClaim,Core_MDF_Adjustment_Request__c> adjClaimToAdjReqMap,
                                                       Map<Core_MDF_Adjustment_Request__c, PartnerFundClaim> adjRequestIdToAdjClaimMap){
           	 //Map of Adjustmemnt request to corresponding error
        	Map<Core_MDF_Adjustment_Request__c,String> adjReqToErrorMessageMap = new Map<Core_MDF_Adjustment_Request__c,String>();
            //Set of succeed adjustment claims Id
        	Set<Id> succeedAdjClaimIdSet = new Set<Id>();
            //Inserting Negative/Positive claims
            Database.saveResult[] finalAdjClaimResultList = database.insert(adjClaimList, false);
			for(Integer index=0;index<adjClaimList.size();index++){
                if(finalAdjClaimResultList[index] !=null && adjClaimList[index]!=null){
					Database.saveResult adjClaim = finalAdjClaimResultList[index];
					PartnerFundClaim negClaim = adjClaimList[index];
                    //If negative claim  inserted, adding to set
                     if (adjClaim.Id !=null && adjClaim.isSuccess()){
                        succeedAdjClaimIdSet.add(negClaim.Id);
                    }else{
                        //creating map of adjustment request to error
                        if(negClaim.Id== null && !adjReqToErrorMessageMap.containsKey(adjClaimToAdjReqMap.get(negClaim))){
                            //adding error
                            adjClaimToAdjReqMap.get(negClaim).addError(adjClaim.getErrors().get(0).getMessage());
                        }				
                    }
            	}
               }
            //Looping adjustment request list and assign adjustment claim id to adjustment request
            for( Core_MDF_Adjustment_Request__c adjReq : adjustmentRequestList )
            {
                // Get Negative/Positive claim Id 
                PartnerFundClaim newAdjClaim = adjRequestIdToAdjClaimMap.containsKey(adjReq) ? adjRequestIdToAdjClaimMap.get(adjReq) : null;
                if(newAdjClaim!=null && succeedAdjClaimIdSet.contains(newAdjClaim.Id)){
                    //Assign Negative/Positive claim Id to Adjustement request
                    adjReq.Core_MDF_Adjustment_Claim_Nbr__c = newAdjClaim.Id;
                }
            }
    }
    
    	/***************************************************************************************************** 
    Method Name:        cancelClaimOnAdjCancel 
    @return  :          void 
    @parameters:        
    Description:        This method is used to cancel claim if Adj Req is Cancelled
    Added By:           Accenture - KK - 25/02/2020
    Modified By:        Date:       Changes:  
    ******************************************************************************************************/    
    public static void cancelClaimOnAdjCancel(Map<Id,Core_MDF_Adjustment_Request__c> oldAdjRequestMap,Map<Id,Core_MDF_Adjustment_Request__c> newAdjRequestMap){
		List<PartnerFundClaim> listOfClaimsToBeCancelled = new List<PartnerFundClaim>(); 
        Map<Id,Core_MDF_Adjustment_Request__c> adjReqIdToAdjReqMap = new Map<Id,Core_MDF_Adjustment_Request__c>();
        Set<Id> adjustmentClaims = new Set<Id>();
        for(Core_MDF_Adjustment_Request__c adjReq : newAdjRequestMap.values()){
            if(oldAdjRequestMap.get(adjReq.Id).Core_MDF_Adjustment_Status_nm__c != newAdjRequestMap.get(adjReq.Id).Core_MDF_Adjustment_Status_nm__c && newAdjRequestMap.get(adjReq.Id).Core_MDF_Adjustment_Status_nm__c.equals(Label.Core_MDF_Status_Cancelled)){
            	adjReqIdToAdjReqMap.put(adjReq.Id,adjReq);
                adjustmentClaims.add(adjReq.Core_MDF_Adjustment_Claim_Nbr__c);
            }
        }
        
        Map<Id,PartnerFundClaim> partnerFundClaimMap = new Map<Id,PartnerFundClaim>([Select id,Core_MDF_Type_Txt__c,Core_MDF_Status__c from PartnerFundClaim where id in : adjustmentClaims]);
        
        for(Core_MDF_Adjustment_Request__c adjRequest : adjReqIdToAdjReqMap.values()){
            if(partnerFundClaimMap.get(adjRequest.Core_MDF_Adjustment_Claim_Nbr__c).Core_MDF_Type_Txt__c.equals(Label.Core_MDF_Negative_Claim)){
                if(partnerFundClaimMap.get(adjRequest.Core_MDF_Adjustment_Claim_Nbr__c).Core_MDF_Status__c != Label.Core_MDF_Status_Cancelled){
                    PartnerFundClaim claimToBeCancelled = new PartnerFundClaim(id = adjReqIdToAdjReqMap.get(adjRequest.Id).Core_MDF_Adjustment_Claim_Nbr__c);
                    claimToBeCancelled.Core_MDF_Claim_Previous_Status__c = partnerFundClaimMap.get(adjRequest.Core_MDF_Adjustment_Claim_Nbr__c).Core_MDF_Status__c;
                    claimToBeCancelled.Core_MDF_Status__c = Label.Core_MDF_Status_Cancelled;
                    claimToBeCancelled.Status = Label.Core_MDF_Status_Rejected;
                    listOfClaimsToBeCancelled.add(claimToBeCancelled);   
                }
            }
        }
        if(listOfClaimsToBeCancelled!=null && listOfClaimsToBeCancelled.size()>0){
            Database.update(listOfClaimsToBeCancelled);
        }
    }
}