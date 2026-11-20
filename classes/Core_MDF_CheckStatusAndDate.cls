/****************************************************************************************************************************************
    * Class Name  : Core_MDF_CheckStatusAndDate 
    * Version     : 1.0 
    * Created Date: 11-19-2018
    * Modification Log :
    * Developer                     Date                          Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * ashar                       11/19/2018                    Contains the bussiness logic of trigger to throw error
    *****************************************************************************************************************************************/
    public with sharing class Core_MDF_CheckStatusAndDate{
            
        /***************************************************************************************************** 
Method Name :   checkValidClaims
@return     :   NULL
@parameters :   Map of old Activity record and Map of new Activity record
Description :   It throws the error if Activity Claim Submitter is trying to cancel Activity 
record wiht In-Progres status and which has valid claims.
Added By    :   Accenture - AS 
Modified By :                      Date:11/19/2018                     Changes:None                               
******************************************************************************************************/  
        private static string pfrCancelledStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status');    
        private static boolean isValidUserToCancelActvity = FeatureManagement.checkPermission('Core_MDF_Allowed_Permission_Set_for_Cancel_Activity');
        public static void checkValidClaims(Map<Id,PartnerFundRequest> oldMap,Map<Id,PartnerFundRequest> newMap){
        
            //Creating Map which will hold pfrId and list of claimIds
            Map<Id,List<PartnerFundClaim>> activityClaimMap = new Map<Id,List<PartnerFundClaim>>(); 
            List<String> claimStatusStrList = Label.Core_MDF_InactiveStatusForClaim.split(';');
            Set<Id> pfrCancelledIdSet = new Set<Id>();
            Set<Id> pfrDateChangedIdSet = new Set<Id>();
            Set<Id> pfrRejectedIdSet = new Set<Id>();
            Set<Id> pfrIdSet = new Set<Id>();
            Map<Id,String> pfrIdToErrorMap = new Map<Id,String>(); 
            Map<Id,List<PartnerFundClaim>> pfrIdPfcMap = new Map<Id,List<PartnerFundClaim>>();
             String errorMsg ='';
            try{
                 
                //PermissionSetList
                List<String>  permissionSetName = Label.Core_MDF_ClaimCaseReviewer.split(',');
                
                //Checking if user has Auditor permission
                List<PermissionSetAssignment> permSetList = [SELECT Id, PermissionSetId, AssigneeId 
                                                             FROM PermissionSetAssignment
                                                             WHERE PermissionSet.Name IN :permissionSetName AND
                                                             AssigneeId =: UserInfo.getUserId()];
                
                for(PartnerFundRequest pfr :oldMap.values()){
                    if(((oldMap != null && oldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c.Equals(Label.Core_MDF_pfrInprogress) 
                         && newMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c.Equals(pfrCancelledStatus))) 
                         && !(System.Label.Core_MDF_Is_ValidationBypassed == 'TRUE' && System.Label.Core_MDF_VRBypassByUser.contains(UserInfo.getUserName())) && isValidUserToCancelActvity){
                           pfrCancelledIdSet.add(pfr.Id);                                                      
                       }else if(oldMap != null && (oldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == newMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c && newMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c.Equals(Label.Core_MDF_pfrInprogress)) 
                                && (oldMap.get(pfr.Id).Core_MDF_Start_Date__c != newMap.get(pfr.Id).Core_MDF_Start_Date__c 
                                || oldMap.get(pfr.Id).Core_MDF_End_Date__c != newMap.get(pfr.Id).Core_MDF_End_Date__c) ){
                           pfrDateChangedIdSet.add(pfr.Id);                  
                       }else if(oldMap != null && (oldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c.Equals(Label.Core_MDF_pfrInprogress)
                                                   && newMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c.Equals(pfrCancelledStatus))){
                            pfrRejectedIdSet.add(pfr.Id);                                 
                       }
                }
                pfrIdSet.addAll(pfrCancelledIdSet);
                pfrIdSet.addAll(pfrDateChangedIdSet);
                pfrIdSet.addAll(pfrRejectedIdSet);
               
                for(PartnerFundClaim claim : [SELECT Id,Core_MDF_Status__c,RequestId,Request.Core_MDF_Fund_Request_Status__c, Title,Core_MDF_Ad_Run_End_Date__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Type_Txt__c 
                                              FROM PartnerFundClaim
                                              WHERE RequestId IN :pfrIdSet /*AND 
                                                Core_MDF_Status__c <>: claimStatusStrList AND 
                                                Core_MDF_Type_Txt__c =: Label.Core_MDF_Claim_Type*/]){

                                                    if(pfrIdToErrorMap.containsKey(claim.RequestId)){
                                                       continue;
                                                    }else{
                                                        //checks cancelled,denied claims
                                                        errorMsg = checkCancelledCalimValidation(pfrCancelledIdSet,claim);
                                                        if(errorMsg!=''){
                                                            pfrIdToErrorMap.put(claim.RequestId,errorMsg);
                                                            continue;
                                                        }
                                                        
                                                        //the map based on the query    
                                                        //date validations between claim and activity 
                                                        if(!claimStatusStrList.contains(claim.Core_MDF_Status__c) && claim.Core_MDF_Type_Txt__c == Label.Core_MDF_Claim_Type){   
                                                           
                                                            errorMsg = checkClaimDateValidation(pfrDateChangedIdSet,claim,oldMap,newMap);
                                                            if(errorMsg!=''){
                                                                pfrIdToErrorMap.put(claim.RequestId,errorMsg);continue;
                                                            }
                                                             //case reviewer rejection validation
                                                            errorMsg = checkRejectedCalimValidation(pfrRejectedIdSet,claim,permSetList);
                                                            if(errorMsg!=''){
                                                                pfrIdToErrorMap.put(claim.RequestId,errorMsg);
                                                            }
                                                        }
                                                    }

                                                }
               
                

                for(Id pfrId : pfrIdSet){
                    if(pfrIdToErrorMap.containsKey(pfrId)){
                        errorMsg = pfrIdToErrorMap.get(pfrId);
                        Trigger.newMap.get(pfrId).addError(errorMsg);
                    }
                    /*for(PartnerFundClaim claim : activityClaimMap.get(pfrId)){
                        if(pfrCancelledIdSet.contains(pfrId) && claim.Core_MDF_Status__c != pfrCancelledStatus){
                          Trigger.newMap.get(pfrId).addError(Label.Core_MDF_Cancel_Activity_Error_Message);
                          break;
                        }
                        if(!claimStatusStrList.contains(claim.Core_MDF_Status__c) && claim.Core_MDF_Type_Txt__c == Label.Core_MDF_Claim_Type){
                            if(pfrDateChangedIdSet.contains(pfrId) &&
                              (newMap.get(pfrId).Core_MDF_Start_Date__c > claim.Core_MDF_Ad_Run_Start_Date__c ||
                           		newMap.get(pfrId).Core_MDF_End_Date__c < claim.Core_MDF_Ad_Run_End_Date__c)){
                               	Trigger.newMap.get(pfrId).addError(Label.Core_MDF_ClaimDateError); 
                                break;
                            }
                            if(pfrRejectedIdSet.contains(pfrId) && permSetList.size() > 0){
                                Trigger.newMap.get(pfrId).addError(Label.Core_MDF_ValidClaimError);
                                break;
                            }
                        }                                              
                    }*/
                }
                

                
            }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}    
        }
        
       
        public static String checkCancelledCalimValidation( Set<Id> pfrCancelledIdSet,PartnerFundClaim claim){
            if(pfrCancelledIdSet.contains(claim.RequestId) && claim.Core_MDF_Status__c != pfrCancelledStatus){
                return (Label.Core_MDF_Cancel_Activity_Error_Message);
            }else{
                return '';
            }
            
        }
        public static String checkClaimDateValidation(Set<Id> pfrDateChangedIdSet,PartnerFundClaim claim,Map<Id,PartnerFundRequest> oldMap,Map<Id,PartnerFundRequest> newMap){
            if(pfrDateChangedIdSet.contains(claim.RequestId) &&
                              (newMap.get(claim.RequestId).Core_MDF_Start_Date__c > claim.Core_MDF_Ad_Run_Start_Date__c ||
                           		newMap.get(claim.RequestId).Core_MDF_End_Date__c < claim.Core_MDF_Ad_Run_End_Date__c)){
               return (Label.Core_MDF_ClaimDateError);
            }else{
                return '';                     
            }
        }
 		public static String checkRejectedCalimValidation(Set<Id> pfrRejectedIdSet,PartnerFundClaim claim,List<PermissionSetAssignment> permSetList){
            if(pfrRejectedIdSet.contains(claim.RequestId) && permSetList.size() > 0){
                return (Label.Core_MDF_ValidClaimError);
            }else{
                return '';                     
            }
        }
    }