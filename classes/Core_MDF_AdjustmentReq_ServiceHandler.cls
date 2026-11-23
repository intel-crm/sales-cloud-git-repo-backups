/*  
* Class Name  : Core_MDF_AdjustmentReq_ServiceHandler 
* Version     : 1.0 - DevCCP
* Modification Log :
* Developer               Date                          Description 
* -----------------------------------------------------------------------------------------------------------------------------------------------------
*  Intel - Areefa                 31-May-2019           Created Core_MDF_AdjustmentReq_ServiceHandler for creating negative claims
*  Accenture - TS               3-APR-2021             Created "getMetricesAPIFields" for assigning metric field values on adjustment claim creations 
------------------------------------------------------------------------------------------------------------------------------------------------------- */
public without sharing class Core_MDF_AdjustmentReq_ServiceHandler {
    
    public static Map<Id,PartnerFundClaim> claimMap;
    public static Map<String,String> claimReasonTypeMap = new Map<String,String>();
    public static String errorMessage = ''; 
    public static Set<ID> claimIdSet = new Set<Id>();
    public static List<Core_MDF_Adjustment_Request__c> adjustmentRequestList = new List<Core_MDF_Adjustment_Request__c>();
    public static List<PartnerFundClaim> adjClaimList =  new List<PartnerFundClaim>();
    public static Map<PartnerFundClaim,Core_MDF_Adjustment_Request__c> adjClaimToAdjReqMap = new Map<PartnerFundClaim,Core_MDF_Adjustment_Request__c>();
    public static Map<Core_MDF_Adjustment_Request__c, PartnerFundClaim> adjRequestIdToAdjClaimMap = new Map<Core_MDF_Adjustment_Request__c, PartnerFundClaim>();
    public static Map<Id,Id> refClaimIdToClaimOwnerIdMap = new Map<Id,Id>();
    public static Map<Id,String> listOfUsersWithsObjReadAccess=new Map<Id,String>();
    //public static Set<Id> claimIdsForRefOwnerId=new Set<Id>();
    
    /****************************************************************************************************** 
Method Name:        claimAdjustmentAmountValidation
@return  :          List<Core_MDF_Adjustment_Request__c>
@parameters:        List<Core_MDF_Adjustment_Request__c>
Description:        This method is used to validate Total amount of adjustment Requests against Reference Claim's Amount .
Added By:           Pranav  - 30/Jun/2020
*******************************************************************************************************/
    
    public static List<Core_MDF_Adjustment_Request__c> claimAdjustmentAmountValidation(List<Core_MDF_Adjustment_Request__c> newadjList)
    {
        // Map to store Reference Claim Id and sum of its Existing Adjustment Amounts
        Map<Id, Double> totalAmountofExistingAdjReqOfClaimMap = new Map<Id, Double>(); 
        
        // List to store all the adjustments that passes the Sum of Adjustment Amount validation
        List<Core_MDF_Adjustment_Request__c> adjustmentReqtobeprocessed = new List<Core_MDF_Adjustment_Request__c>();
        
        // Iterating over new Adjustment Requests and storing the reference Claim Id in a set
        Set<Id> setOfclaimIds = new Set<Id>();
        for(Core_MDF_Adjustment_Request__c adjrecord: newadjList)
        {
            setOfclaimIds.add(adjrecord.Core_MDF_Reference_Claim_Nbr__c);            
        }
        
        // Aggregated Sum of Existing Adjustment Amount grouped by Reference Claim 
        List<AggregateResult> sumofExistingAdjReq =[Select Sum(Core_MDF_Amount_Amt__c) sumOfAdjAmount, Core_MDF_Reference_Claim_Nbr__c from Core_MDF_Adjustment_Request__c where Core_MDF_Reason_Cd__c !=: Label.Core_MDF_AdjReq_EscalationType and Core_MDF_Adjustment_Status_nm__c !=: Label.Core_MDF_Status_Cancelled and Core_MDF_Reference_Claim_Nbr__c IN :setOfclaimIds Group BY Core_MDF_Reference_Claim_Nbr__c];
        
        
        for(AggregateResult existingadj : sumofExistingAdjReq)
        {
            ID referenceClaim =(Id)existingadj.get('Core_MDF_Reference_Claim_Nbr__c'); 
            Decimal sumOfAdjAmount=(decimal)existingadj.get('sumOfAdjAmount'); 
            totalAmountofExistingAdjReqOfClaimMap.put(referenceClaim,sumOfAdjAmount);
        }
     
        
        // Map to store Claim Id and its Sum of Reimbursement Amount and Total Claim's Offseted Amount field value
        // Claim Amount = Reimbursement Amount + Total Offset Amount
        Map<Id, Double> claimAmtMap = new Map<Id, Double>();
        for(partnerfundclaim pfc : [Select id , Amount , Core_MDF_Total_Claim_Offsets__c from Partnerfundclaim where Id IN: (setOfclaimIds)])
        {
            claimAmtMap.put(pfc.id, pfc.Amount + pfc.Core_MDF_Total_Claim_Offsets__c);
        }
        
        // Validating sum of Existing adjustments and new adjustment amount against Claim's amount
        for(Core_MDF_Adjustment_Request__c newadj : newadjList)
        {
            // If New Adjustment Request is NOT having reason as Escalations and ByPass Amount validation is false then proceed with Amount Validation
            if(newadj.Core_MDF_Reason_Cd__c != label.Core_MDF_AdjReq_EscalationType  && !(newadj.Core_MDF_Bypass_Amt_Val_Ind__c))
            {
                // If Reference Claim of the New Adjustment Request contains at least one adjustment Request record in totalAmountofExistingAdjReqOfClaimMap 
                if(totalAmountofExistingAdjReqOfClaimMap.containsKey(newadj.Core_MDF_Reference_Claim_Nbr__c))
                {
                    if((newadj.Core_MDF_Amount_Amt__c + totalAmountofExistingAdjReqOfClaimMap.get(newadj.Core_MDF_Reference_Claim_Nbr__c))> 
                       claimAmtMap.get(newadj.Core_MDF_Reference_Claim_Nbr__c))
                    {
                        
                        newadj.addError(label.Core_MDF_AdjAmt_greaterthan_Claim);
                    }
                    else
                    {
                        adjustmentReqtobeprocessed.add(newadj);
                    }  
                }
                // If Reference Claim of the New Adjustment Request does not contain any adjustment Requests record in totalAmountofExistingAdjReqOfClaimMap
                else
                {
                    if(newadj.Core_MDF_Amount_Amt__c > claimAmtMap.get(newadj.Core_MDF_Reference_Claim_Nbr__c))
                    {
                        newadj.addError(label.Core_MDF_AdjAmt_greaterthan_Claim);
                    }
                    else
                    {
                        adjustmentReqtobeprocessed.add(newadj);
                    }
                }
            }
            // If New Adjustment Request is having reason as Escalations then Add the Adjustment Request directly in the list
            else
            {
                adjustmentReqtobeprocessed.add(newadj);
            }
        }
        return adjustmentReqtobeprocessed;
    }
    /****************************************************************************************************** 
Method Name:        getMetricesAPIFields
@return  :          Set<String>
Description:        This method is used to return unique metrices API names on claims module.
Added By:           TS  - 5-APR-2021
*******************************************************************************************************/
    public static Set<String> getMetricesAPIFields(){
        Set<String> matricesAPISet = new Set<String>();
        //Query from CCP KPI Metrics Metadata and capture all unique metrices api names on claims to a set
        for(CCP_Activity_Type_dependent_fields__mdt metrics : [Select id,Core_MDF_Module__c,Core_MDF_Object_API_Field_Name__c from CCP_Activity_Type_dependent_fields__mdt where Core_MDF_Module__c=:Label.Core_MDF_PFCText]){
            if(metrics.Core_MDF_Object_API_Field_Name__c!=null){
                matricesAPISet.add(metrics.Core_MDF_Object_API_Field_Name__c);
            }
        }
        return matricesAPISet;
    }
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
        //Clearing all the static variables
      adjustmentRequestList = new List<Core_MDF_Adjustment_Request__c>();
      adjClaimList =  new List<PartnerFundClaim>();
      adjClaimToAdjReqMap = new Map<PartnerFundClaim,Core_MDF_Adjustment_Request__c>();
      adjRequestIdToAdjClaimMap = new Map<Core_MDF_Adjustment_Request__c, PartnerFundClaim>();
      Set<String> matricesAPISet = new Set<String>();
      List<PartnerFundClaim> claimsList = new List<PartnerFundClaim>();
        
      String metricfieldsForQuery='';
     
        Set<String> adjReasonSet = new Set<String>();
        List<Core_MDF_AdjustmentOrEscalationClaim__mdt> reasonAndTypeList = new List<Core_MDF_AdjustmentOrEscalationClaim__mdt>();
        // Get all the Adjustment request where Adjustment Claim is null 
        List<Core_MDF_Adjustment_Request__c> adjReqToBeProcessed = new List<Core_MDF_Adjustment_Request__c>();
        //Don't migrate this code with try/catch block, put your changes on top of devint code - START
        try{
            for(Core_MDF_Adjustment_Request__c adjReq : adjustmentRequestLst){
            if(adjReq.Core_MDF_Adjustment_Claim_Nbr__c == null ){
                adjReqToBeProcessed.add(adjReq);
            }
        }
        for(Core_MDF_Adjustment_Request__c adjReq : adjReqToBeProcessed)
        {
            claimIdSet.add(adjReq.Core_MDF_Reference_Claim_Nbr__c);
            adjReasonSet.add(adjReq.Core_MDF_Reason_Cd__c);
        }
        
        matricesAPISet=getMetricesAPIFields(); //Calling this method to get all metrices API Names From Claim Module
        if(matricesAPISet != null && matricesAPISet.size()>0){
          metricfieldsForQuery = string.join(new List<String>(matricesAPISet),',');
        }
        // 2. Query all claims - Changed into dynamic query as we have to assign metrices field values dynamically on auto created claim by referring its reference claim 
        if(claimIdSet!=null && claimIdSet.size()>0){
            String query ='SELECT Id,Title,Owner.isActive,Request.Title,Core_MDF_Program__c,Core_MDF_Activity_Status_nm__c,Request.Core_MDF_Activity_Number__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_AccountCompany__c,Core_MDF_Claim_Ref_Number__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_VAT_Opt_In__c,Core_MDF_VAT_Eligibility_Ind__c, Core_MDF_Applicable_VAT_Percentage_nm__c, Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Country_Location_nm__c,Core_MDF_Ad_Run_End_Date__c, Core_MDF_Media_Vehicle__c,Core_MDF_Invoice_Date__c,Core_MDF_Bank__r.Name,RecordTypeId,Core_MDF_Processing_Preference_nm__c';
        //Check if metricfieldsForQuery is not null
        if(!String.isBlank(metricfieldsForQuery)){
          query+= ',' +metricfieldsForQuery;
        }
		query += ' FROM PartnerFundClaim WHERE Id IN :claimIdSet AND Core_MDF_Activity_Status_nm__c = \'In-Progress\' ';
        claimsList=Database.query(query);   
        claimMap = new Map<Id,PartnerFundClaim> (claimsList);                      
        }
        if (adjReqToBeProcessed != null && !adjReqToBeProcessed.isEmpty()) {
            for (Core_MDF_Adjustment_Request__c ar : adjReqToBeProcessed) { 
                if (claimMap.get(ar.Core_MDF_Reference_Claim_Nbr__c) == null) {
                	ar.addError('Adjustment can be created on claims associated to activities that are in an "In Progress" state only');
                }       
            }
        }
        //3. Retrived all metadata
        if(adjReasonSet!=null && adjReasonSet.size()>0){
            reasonAndTypeList = [SELECT Core_MDF_Reason_txt__c,Core_MDF_Type_txt__c FROM Core_MDF_AdjustmentOrEscalationClaim__mdt WHERE Core_MDF_Reason_txt__c IN :adjReasonSet];
        }
        
        //4. Mapping Type and reason
        for(Core_MDF_AdjustmentOrEscalationClaim__mdt reasonType : reasonAndTypeList){
            claimReasonTypeMap.put(reasonType.Core_MDF_Reason_txt__c,reasonType.Core_MDF_Type_txt__c);
        }    
        // 5. Preparing list of Negative and Postive AdjustmentRequest
        List<Core_MDF_Adjustment_Request__c> negativeAdjustmentLst = new List<Core_MDF_Adjustment_Request__c>(); // List holds negtive Adjustment
        List<Core_MDF_Adjustment_Request__c> postiveAdjustmentLst = new List<Core_MDF_Adjustment_Request__c>();  // List holds postive Adjustment       
        List<Core_MDF_Adjustment_Request__c> positiveAdjustmentCRRType = new List<Core_MDF_Adjustment_Request__c>(); //List holds positive adjustments without escalationId
        Set<Id> claimIdsForRefOwnerId=new Set<Id>();
       
        for( Core_MDF_Adjustment_Request__c adjReq : adjReqToBeProcessed ){
            if(claimReasonTypeMap.get(adjReq.Core_MDF_Reason_Cd__c).equals(Label.Core_MDF_Claim_Adjustment_Type)){ 
                negativeAdjustmentLst.add(adjReq);
                claimIdsForRefOwnerId.add(adjReq.Core_MDF_Reference_Claim_Nbr__c);
            }
            else{
                if(adjReq.Core_MDF_Reason_Cd__c == 'Claim Review Results (Positive)'){
                    positiveAdjustmentCRRType.add(adjReq);
                    postiveAdjustmentLst.add(adjReq);
                    claimIdsForRefOwnerId.add(adjReq.Core_MDF_Reference_Claim_Nbr__c);
                }
                else{
                    postiveAdjustmentLst.add(adjReq);
                }
               
            }
        }
        
   
        //For Unique reference claims, an Adjustments or Escalations can be created
        //Commented because of post payment audit chages for Vat Implementation(both +ve and -ve claims created for same reference claim)
        //if(adjReqToBeProcessed.size() == claimIdSet.size()){
        
        if(negativeAdjustmentLst.size() > 0 || positiveAdjustmentCRRType.size() > 0){
            if(claimIdsForRefOwnerId!=null && claimIdsForRefOwnerId.size()>0){
                refClaimIdToClaimOwnerIdMap=getReferenceClaimWithOwnerIds(claimIdsForRefOwnerId); //To get a map of reference Claim Id with value as its owner Id.
            }
            String sObjType=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PartnerFundClaim');
            //To check if reference claim owners are having Read access on Claim Object
            if(refClaimIdToClaimOwnerIdMap!=null){
                listOfUsersWithsObjReadAccess=Core_MDF_Claim_Utility.getListOfUsersWithsObjTypeAccess(refClaimIdToClaimOwnerIdMap.values(),sObjType); 
            }
        }
        if(negativeAdjustmentLst != null && negativeAdjustmentLst.size() > 0 ){
            createNegativeAdjustments(negativeAdjustmentLst);
        }
        if(postiveAdjustmentLst != null && postiveAdjustmentLst.size() > 0){
            createPositiveAdjustments(postiveAdjustmentLst);
        }
        /* }else{
            for(Core_MDF_Adjustment_Request__c adjReq : adjReqToBeProcessed)
            {
            adjReq.addError(Label.Core_MDF_DuplicateRefClaimForAdjustement);
            }
        }*/
      
        //Inserting adjustment claim and displaying error if any
        if(adjustmentRequestList!=null && adjustmentRequestList.size()>0 &&
           adjClaimList!=null && adjClaimList.size()>0 &&
           adjClaimToAdjReqMap!=null && adjClaimToAdjReqMap.size()>0 &&
           adjRequestIdToAdjClaimMap!=null && adjRequestIdToAdjClaimMap.size()>0){               
              
               insertAdjClaimAndDisplayErrorOnAdjRequest(adjustmentRequestList,adjClaimList,adjClaimToAdjReqMap,adjRequestIdToAdjClaimMap);
           
           }
        }
        catch(Exception e){
           
          string errorMessage = Core_MDF_CCP_UtilityClass.getErrorDetails(e);
           
			            
            if(!String.isBlank(errorMessage) && errorMessage.contains(Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt)){
                adjustmentRequestList[0].addError(Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt);
            }
            else if(!String.isBlank(errorMessage) && errorMessage.contains('Claim cannot be created on an activity in Closed/Cancelled status')){
                adjustmentRequestList[0].addError('Claim cannot be created on an activity in Closed/Cancelled status');
            }
            else if(!String.isBlank(errorMessage) && errorMessage.contains(Label.Core_MDF_CampaignCAPAmount_wrt_ClaimAmount_ErrMsg)){
                adjustmentRequestList[0].addError(Label.Core_MDF_CampaignCAPAmount_wrt_ClaimAmount_ErrMsg);
            }
            else if(!String.isBlank(errorMessage) && errorMessage.contains(Label.Core_MDF_ClaimExceedsCapRemainder_ErrorMsg)){
                adjustmentRequestList[0].addError(Label.Core_MDF_Escalation_Approval_Error_Message);
            }
            else{
                adjustmentRequestList[0].addError(Label.Core_MDF_ApplicationErrorMessage); 
               //adjustmentRequestList[0].addError(errorMessage); 
            }
        }
        
        
     //Don't migrate above code with try/catch block, put your changes on top of devint code - END
    } 
    
    //Common method to setBasicClaimFields
    public static PartnerFundClaim setBasicClaimFields(PartnerFundClaim claim){             
        try{
            
            PartnerFundClaim newClaim = claimMap.get(claim.Id).clone(true);
            newClaim.Id= null;                                                                         // To Create Negative claim,make Existing claim ID as 'null'
            newClaim.Core_MDF_Claim_Ref_Number__c = null;                                              // Claim comments
            newClaim.Core_MDF_Claim_Comments__c =null;                                                 // comments as null
            newClaim.Core_MDF_OtherCostsnotReimbursable_Local__c=0.00;                                 // Other Cost
            newClaim.Core_MDF_Taxes_Local__c=0.00;                                                     // Tax
            newClaim.Core_MDF_Invoice_Number__c= '0';                                                  // Invoice number
            newClaim.Status = Label.Core_MDF_Status_Submitted;                                         // Submitted 
            newClaim.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;                // Pending Available Fund 
            newClaim.Core_MDF_Currency__c = Label.Core_MDF_PFR_Output_Currency;                        // USD
            newClaim.Core_MDF_Claim_Previous_Status__c = Label.Core_MDF_Status_Submitted;              // Previous Status = Submitted
            //claim.Core_MDF_Campaign_Id__c = claim.Core_MDF_Campaign_Id__c;              // Added for Campaign CAP Validation we need campaign field
            newClaim.Core_MDF_VAT_Opt_In__c = claim.Core_MDF_VAT_Opt_In__c;                // Updating VAT Opt In Value with Reference Claim VAT Opt In Field
            newClaim.Core_MDF_Applicable_VAT_Percentage_nm__c = claim.Core_MDF_Applicable_VAT_Percentage_nm__c;  
            
            return newClaim; }catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    public static Map<Id,Id> getReferenceClaimWithOwnerIds(Set<Id> claimIds){
        Map<Id,Id> mapOfRefClaimIdsWithOwnerIds = new Map<Id,Id>();
		if(claimIds!=null && claimIds.size()>0){
            List<PartnerFundClaim> partnerFundClaimList = [Select Id,OwnerId from partnerFundClaim where Id IN:claimIds];
            for(PartnerFundClaim pfc : partnerFundClaimList){
                mapOfRefClaimIdsWithOwnerIds.put(pfc.Id,pfc.OwnerId);
            }
        }
        return mapOfRefClaimIdsWithOwnerIds;
  }
    
    //Negative Claim:
    public static void createNegativeAdjustments(List<Core_MDF_Adjustment_Request__c> negativeAdjustmentList)  
    {        
        
	//Roshan - Added changes for "Reclaiming SF Partner License"
        //Map of exisitng user
        Map<Id,User> userIdToUserMap =New Map<Id,User>([Select id,LanguageLocaleKey,Partner_License_Reclaimed__c from User where Id IN:refClaimIdToClaimOwnerIdMap.values()]);
        try
        {
            for(Core_MDF_Adjustment_Request__c adjReq : negativeAdjustmentList ){
                PartnerFundClaim newNegativeClaim = setBasicClaimFields(claimMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c));  
                newNegativeClaim.Core_MDF_Type_Txt__c = claimReasonTypeMap.get(adjReq.Core_MDF_Reason_Cd__c);           // Type
                newNegativeClaim.Core_MDF_Total_Invoice_Amount_Local__c = adjReq.Core_MDF_Amount_Amt__c;// Map Adjustment Request Amount to Claim Tot Invoice Amount
                // To populate Owner Language Locale over claim field by referring to LanguageLocaleKey of reference claim owner.
                if(refClaimIdToClaimOwnerIdMap.containsKey(adjReq.Core_MDF_Reference_Claim_Nbr__c)){
                    //To check if reference claim owner is Active
                    if(!claimMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c).Owner.isActive && !userIdToUserMap.get(refClaimIdToClaimOwnerIdMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c)).Partner_License_Reclaimed__c){
                        String referenceOwnerInactive = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Ref_Claim_Owner_Inactive');
                        adjReq.addError(referenceOwnerInactive);  
                    }
                    else{
                        //To check if reference claim owner is having read access on claim object
                        if(listOfUsersWithsObjReadAccess.containsKey(refClaimIdToClaimOwnerIdMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c))== false){
                            String referenceOwnerInvalid =  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Ref_Claim_Owner_Invalid');
                            adjReq.addError(referenceOwnerInvalid);
                        }
                        else{
                        //to store owner's language locale key
                        newNegativeClaim.Core_MDF_Owner_LanguageLocaleKey_Cd__c =
                        userIdToUserMap.containsKey(refClaimIdToClaimOwnerIdMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c)) ?
                        userIdToUserMap.get(refClaimIdToClaimOwnerIdMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c)).LanguageLocaleKey : Label.Core_English_Language_Locale_Key;
                        }  
                    }
                  }               
                newNegativeClaim = negativeClaim(newNegativeClaim);                                
                adjClaimList.add(newNegativeClaim); 
                // Attach newly created NegativeClaim object to an AdjRequest
                adjRequestIdToAdjClaimMap.put(adjReq, newNegativeClaim);
                //Attach AdjRequest to NegativeClaim object 
                adjClaimToAdjReqMap.put(newNegativeClaim, adjReq);              
            }
            adjustmentRequestList.addAll(negativeAdjustmentList);
            
        } catch(Exception e){
            //Exception 
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    
    //Negative  claim  creation method 
    public static PartnerFundClaim negativeClaim(PartnerFundClaim claim){
        try{
            claim.Core_MDF_Bank__c = null;
            String adjTitlePrefix = Label.Core_MDF_Adjustment_Title;                 // Title = [Adjustment] Name_Of_claim
            claim.Title = adjTitlePrefix + ' ' + claim.Title;     
            Double amt = claim.Core_MDF_Total_Invoice_Amount_Local__c;
            claim.Core_MDF_Total_Invoice_Amount_Local__c = - (claim.Core_MDF_Total_Invoice_Amount_Local__c);
            claim.Amount = - (amt); 
            return claim; }catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    
    //Postive Claim:
    public static void createPositiveAdjustments(List<Core_MDF_Adjustment_Request__c> postiveAdjustmentLst)  
    {
         
        for( Core_MDF_Adjustment_Request__c adjReq : postiveAdjustmentLst ){
            
           
            PartnerFundClaim newPositiveClaim = setBasicClaimFields(claimMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c));
            newPositiveClaim.Core_MDF_Type_Txt__c = claimReasonTypeMap.get(adjReq.Core_MDF_Reason_Cd__c); 
            newPositiveClaim.Core_MDF_Total_Invoice_Amount_Local__c = adjReq.Core_MDF_Amount_Amt__c;                // Map Adjustment Request Amount to Claim Tot Invoice Amount
            newPositiveClaim = positiveClaim(newPositiveClaim, adjReq.Core_MDF_Reason_Cd__c); 
         
            //set CRR positive indicator as true if its a Claim Review Result Positive type of claim
            if(adjReq.Core_MDF_Reason_Cd__c == 'Claim Review Results (Positive)'){
                newPositiveClaim.Core_MDF_CRR_Positive_Ind__c = true;
                //To check if reference claim owner is Inactive
                if(claimMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c).Owner.isActive == false){
                    String referenceOwnerInactive = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Ref_Claim_Owner_Inactive');
                    adjReq.addError(referenceOwnerInactive);                
                }
                else{
                    //To check if reference claim owner is having read access on claim object
                    if(listOfUsersWithsObjReadAccess.containsKey(refClaimIdToClaimOwnerIdMap.get(adjReq.Core_MDF_Reference_Claim_Nbr__c))==false){
                        String referenceOwnerInvalid =  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Ref_Claim_Owner_Invalid');
                        adjReq.addError(referenceOwnerInvalid);
                    }
                }
            }
            // Map Adjustment Object EscalationId to Claim Object Escaltion Id
            if(adjReq.Core_MDF_Escalation_Id__c != null){
                newPositiveClaim.Core_MDF_Escalation_Id__c  = adjReq.Core_MDF_Escalation_Id__c;                     // Escaltion Id 
            } 
            
            adjClaimList.add(newPositiveClaim);            
            // postiveAdjReqClaimMap  holds (Adjustement Request Id, claim :which we constructed above)
            adjRequestIdToAdjClaimMap.put(adjReq, newPositiveClaim);
            //Attach AdjRequest to Positive Claim object 
            adjClaimToAdjReqMap.put(newPositiveClaim, adjReq);
        }
    
        adjustmentRequestList.addAll(postiveAdjustmentLst);
    
    }
    //Positive  claim  creation method 
    public static PartnerFundClaim positiveClaim(PartnerFundClaim claim, string reason){
        try{
            if(reason.equals(Label.Core_MDF_AdjReq_EscalationType))
            {
                String escalationTitlePrefix = Label.Core_MDF_Escalation_Title ;                           // Title = [Escalation] Name_Of_claim
                claim.Title = escalationTitlePrefix + ' ' + claim.Title;   
            }
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
        
        Map<Id,Core_MDF_Adjustment_Request__c> adjRequestToAdjClaimMap = new Map<Id,Core_MDF_Adjustment_Request__c>();
        Set<Id> adjustmentClaimIdsWithOffset = new Set<Id>();
        Set<Id> adjustmentClaims = new Set<Id>();
        List<Core_MDF_Claim_Offset__c> offsetRecordList = new List<Core_MDF_Claim_Offset__c>();
       // List<PartnerFundClaim> adjClaimList = new List<PartnerFundClaim>();
        List<PartnerFundClaim> listOfClaimsToBeCancelled = new List<PartnerFundClaim>();
        
        for( Core_MDF_Adjustment_Request__c adjReq : newAdjRequestMap.values() ){
            
            if(oldAdjRequestMap.get(adjReq.Id).Core_MDF_Adjustment_Status_nm__c != newAdjRequestMap.get(adjReq.Id).Core_MDF_Adjustment_Status_nm__c && Label.Core_MDF_Status_Cancelled.equals(newAdjRequestMap.get(adjReq.Id).Core_MDF_Adjustment_Status_nm__c)){
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
                                                                 Map<Core_MDF_Adjustment_Request__c, PartnerFundClaim> adjRequestIdToAdjClaimMap)
    {
        //Map of Adjustmemnt request to corresponding error       
        Map<Core_MDF_Adjustment_Request__c,String> adjReqToErrorMessageMap = new Map<Core_MDF_Adjustment_Request__c,String>();
        //Set of succeed adjustment claims Id
        Set<Id> succeedAdjClaimIdSet = new Set<Id>();        
        //Inserting Negative/Positive claims 
          Database.saveResult[] finalAdjClaimResultList = database.insert(adjClaimList, true); 
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
        Savepoint sp = Database.setSavepoint();
        try{  
        List<PartnerFundClaim> listOfClaimsToBeCancelled = new List<PartnerFundClaim>(); 
        Map<Id,Core_MDF_Adjustment_Request__c> adjReqIdToAdjReqMap = new Map<Id,Core_MDF_Adjustment_Request__c>();
        Set<Id> adjustmentClaims = new Set<Id>();
        Set<Id> VatToBeCancelled = new Set<Id>();
        for(Core_MDF_Adjustment_Request__c adjReq : newAdjRequestMap.values()){
            if(oldAdjRequestMap.get(adjReq.Id).Core_MDF_Adjustment_Status_nm__c != newAdjRequestMap.get(adjReq.Id).Core_MDF_Adjustment_Status_nm__c && Label.Core_MDF_Status_Cancelled.equals(newAdjRequestMap.get(adjReq.Id).Core_MDF_Adjustment_Status_nm__c)){
                adjReqIdToAdjReqMap.put(adjReq.Id,adjReq);
                adjustmentClaims.add(adjReq.Core_MDF_Adjustment_Claim_Nbr__c);
            }
        }
        
        Map<Id,PartnerFundClaim> partnerFundClaimMap = new Map<Id,PartnerFundClaim>([Select id,Core_MDF_Type_Txt__c,Core_MDF_Status__c,Core_MDF_VAT_Eligibility_Ind__c from PartnerFundClaim where id in : adjustmentClaims]);
        
        for(Core_MDF_Adjustment_Request__c adjRequest : adjReqIdToAdjReqMap.values()){
            if(partnerFundClaimMap.get(adjRequest.Core_MDF_Adjustment_Claim_Nbr__c).Core_MDF_Type_Txt__c.equals(Label.Core_MDF_Negative_Claim)){
                if(partnerFundClaimMap.get(adjRequest.Core_MDF_Adjustment_Claim_Nbr__c).Core_MDF_Status__c != Label.Core_MDF_Status_Cancelled){
                    PartnerFundClaim claimToBeCancelled = new PartnerFundClaim(id = adjReqIdToAdjReqMap.get(adjRequest.Id).Core_MDF_Adjustment_Claim_Nbr__c);
                    claimToBeCancelled.Core_MDF_Claim_Previous_Status__c = partnerFundClaimMap.get(adjRequest.Core_MDF_Adjustment_Claim_Nbr__c).Core_MDF_Status__c;
                    claimToBeCancelled.Core_MDF_Status__c = Label.Core_MDF_Status_Cancelled;
                    //claimToBeCancelled.Core_MDF_VAT_Hold_Ind__c=false; // If Adj get cancelling, Corresponding Claim and VAt also should get cancel and VAt hold should be false
                    claimToBeCancelled.Status = Label.Core_MDF_Status_Rejected;
                    listOfClaimsToBeCancelled.add(claimToBeCancelled);
                    if(partnerFundClaimMap.get(adjRequest.Core_MDF_Adjustment_Claim_Nbr__c).Core_MDF_VAT_Eligibility_Ind__c){ VatToBeCancelled.add(claimToBeCancelled.Id);}
                   
                }
            }
        }
        if(listOfClaimsToBeCancelled!=null && listOfClaimsToBeCancelled.size()>0){            
            Database.update(listOfClaimsToBeCancelled); 
            if(VatToBeCancelled!=null && VatToBeCancelled.size()>0){Core_MDF_PFC_Cancel.cancelVatInformation(VatToBeCancelled);}
          }}catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); Database.rollback(sp); }
    }
}