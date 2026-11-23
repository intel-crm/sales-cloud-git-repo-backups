/****************************************************************************************************************************************
    * Class Name  : Core_MDF_CheckStatusAndDate 
    * Version     : 1.0 
    * Created Date: 11-19-2018
    * Modification Log :
    * Developer                     Date                          Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * ashar                       11/19/2018                    Contains the bussiness logic of trigger to throw error
    *****************************************************************************************************************************************/
    public with sharing class Core_MDF_CheckStatusAndDateDu{
        
    /***************************************************************************************************** 
        Method Name :   checkValidClaims
        @return     :   NULL
        @parameters :   Map of old Activity record and Map of new Activity record
        Description :   It throws the error if Activity Claim Submitter is trying to cancel Activity 
                        record wiht In-Progres status and which has valid claims.
        Added By    :   Accenture - AS 
        Modified By :                      Date:11/19/2018                     Changes:None                               
    ******************************************************************************************************/  

        public static void checkValidClaims(Map<Id,PartnerFundRequest> oldMap,Map<Id,PartnerFundRequest> newMap){
            
            //Creating Map which will hold pfrId and list of claimIds
            Map<Id,List<Id>> activityClaimMap = new Map<Id,List<Id>>();
            List<String> claimStatusStrList = Label.Core_MDF_InactiveStatusForClaim.split(';');
            try{
                for(PartnerFundClaim claim : [SELECT Id,Core_MDF_Status__c,RequestId,Request.Core_MDF_Fund_Request_Status__c 
                                              FROM PartnerFundClaim
                                              WHERE RequestId IN :oldMap.keySet() AND 
                                                  Core_MDF_Status__c <>: claimStatusStrList AND 
                                                    Core_MDF_Type_Txt__c =: Label.Core_MDF_Claim_Type]){
                    
                    //Fill the map based on the query                             
                    if(activityClaimMap.containsKey(claim.RequestId)){
                        activityClaimMap.get(claim.RequestId).add(claim.Id);
                    }
                    else{
                        activityClaimMap.put(claim.RequestId,new List<Id>{claim.Id});
                    } 
                }

                //PermissionSetList
                List<String>  permissionSetName = Label.Core_MDF_ClaimCaseReviewer.split(',');

                //Checking if user has Auditor permission
                List<PermissionSetAssignment> permSetList = [SELECT Id, PermissionSetId, AssigneeId 
                                                             FROM PermissionSetAssignment
                                                             WHERE PermissionSet.Name IN :permissionSetName AND
                                                                   AssigneeId =: UserInfo.getUserId()];
                
                if(permSetList.size() > 0){
                    for(Id pfrId : activityClaimMap.keySet()){
                        if((newMap.get(pfrId)).Core_MDF_Fund_Request_Status__c.Equals( Label.Core_MDF_PFRStatus) && 
                        (oldMap.get(pfrId)).Core_MDF_Fund_Request_Status__c.Equals(Label.Core_MDF_pfrInprogress)){ 
                            Trigger.newMap.get(pfrId).addError(Label.Core_MDF_ValidClaimError);
                        }
                    }
                } 
            }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}    
        }

    /***************************************************************************************************** 
        Method Name :   checkClaimDate
        @return     :   NULL
        @parameters :   Map of old Activity record and Map of new Activity record
        Description :   It throws the error if Activity Claim Submitter is trying change the end date 
                        and start date and it reaches out of date range of Claims.
        Added By    :   Accenture - AS 
        Modified By :                      Date:11/30/2018                     Changes:None                               
    ******************************************************************************************************/  

        public static void checkClaimDate(Map<Id,PartnerFundRequest> oldMap,Map<Id,PartnerFundRequest> newMap){
            
            //Creating Map which will hold pfrId and list of PartnerFundClaim
            Map<Id,List<PartnerFundClaim>> activityClaimMap = new Map<Id,List<PartnerFundClaim>>(); 
            List<String> claimStatusStrList = Label.Core_MDF_InactiveStatusForClaim.split(';');
            try{
                //Populating activityClaimMap with valid claim records only
                for(PartnerFundClaim claim : [SELECT Id,Title,Core_MDF_Ad_Run_End_Date__c,Core_MDF_Ad_Run_Start_Date__c,RequestId 
                                              FROM PartnerFundClaim
                                              WHERE RequestId IN :oldMap.keySet() AND 
                                                    Core_MDF_Status__c <>: claimStatusStrList AND
                                                    Core_MDF_Type_Txt__c =: Label.Core_MDF_Claim_Type]){
                    
                    if(activityClaimMap.containsKey(claim.RequestId)){
                        activityClaimMap.get(claim.RequestId).add(claim);
                    }
                    else{
                        activityClaimMap.put(claim.RequestId,new List<PartnerFundClaim>{claim});
                    } 
                }

                //PermissionSetList
                List<String>  permissionSetName = Label.Core_MDF_ClaimCaseReviewer.split(',');

                //Checking if user has Auditor permission
                List<PermissionSetAssignment> permSetList = [SELECT Id, PermissionSetId, AssigneeId 
                                                             FROM PermissionSetAssignment
                                                             WHERE PermissionSet.Name IN :permissionSetName AND
                                                                   AssigneeId =: UserInfo.getUserId()];

                if(permSetList.size() > 0){                                                  
                    for(Id pfrId : newMap.keySet()){

                        //Check for activity records with valid claims only
                        if(activityClaimMap.keySet().contains(pfrId)){
                            //Throw error when the claim goes out of date range
                            for(PartnerFundClaim pfc : activityClaimMap.get(pfrId)){
            
                                if(newMap.get(pfrId).Core_MDF_Start_Date__c > pfc.Core_MDF_Ad_Run_Start_Date__c ||
                                    newMap.get(pfrId).Core_MDF_End_Date__c < pfc.Core_MDF_Ad_Run_End_Date__c){
            
                                    Trigger.newMap.get(pfrId).addError(Label.Core_MDF_ClaimDateError); 
                                }
                            }
                        }    
                    }
                }
            }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        }

    }