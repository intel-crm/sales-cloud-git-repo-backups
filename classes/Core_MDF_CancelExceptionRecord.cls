/****************************************************************************************************************************************
* Class Name  : Core_MDF_CancelExceptionRecord 
* Version     : 1.0 
* Created Date: 05-06-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Varun Kumar                    05-06-2019                    Created Core_MDF_CancelExceptionRecord class to implement Cancel functionality on Exception
*****************************************************************************************************************************************/
public without sharing class Core_MDF_CancelExceptionRecord {

    /****************************************************************************************************** 
    Class Name:         cancelExceptionWrapper
    @parameters:        N/A
    Description:        Wrapper which will hold return values of all the validation check to cancel exception
    Added By:           VK Accenture - 05-06-2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public class cancelExceptionWrapper{
        @AuraEnabled
        public Boolean isDenied=false;
        @AuraEnabled
        public Boolean isCancelled=false;
        @AuraEnabled
        public Boolean isPendingReview=false;
        @AuraEnabled
        public Boolean isApproved=false;
        @AuraEnabled 
        public Boolean isReviewer=false;
        @AuraEnabled
        public Boolean isSubmitter=false;
        @AuraEnabled
        public Boolean isUserEligibleToCancel=false;
        @AuraEnabled
        public Boolean isSubmitterCancellingApproved=false;
        @AuraEnabled
        public Boolean isDraft=false;
    } 

    /****************************************************************************************************** 
    Method Name:        isUserEligibiletoCancel
    @return  :          Wrapper which will hold the values of all the variables.
    @parameters:        NA
    Description:        This method is used to check if user has the permission to cancel exception.
    Added By:           VK Accenture - 05/06/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static cancelExceptionWrapper isUserEligibiletoCancel(Id recordId){
        cancelExceptionWrapper exptWrap = new cancelExceptionWrapper();
        Boolean hasAllAccountCancelPermission = false;
        try {
           //Check custom permission for Cancellation
            Boolean hasCustomPermission = FeatureManagement.checkPermission(Label.Core_MDF_ExceptionCancellationAccess);
            hasAllAccountCancelPermission = isCancellationAllowed(recordId);
            if(hasCustomPermission && hasAllAccountCancelPermission){exptWrap.isUserEligibleToCancel = true;
            }
            else{
                exptWrap.isUserEligibleToCancel = false;
            }
            
            return exptWrap;
        } 
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);return null;}
    }
    
    /****************************************************************************************************** 
    Method Name:        checkExceptionEligibility
    @return  :          Wrapper which will hold the values of all the variables.
    @parameters:        Exception Id
    Description:        This method is used to check different validations to cancel exception
    Added By:           VK Accenture - 05/06/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static cancelExceptionWrapper checkExceptionEligibility (Id exceptionId){

        cancelExceptionWrapper exceptionWrap = new cancelExceptionWrapper();
        
        try{
            List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
            Core_MDF_Exception__c exceptionVar = [SELECT Core_MDF_Exception_Status_nm__c 
                                                  FROM Core_MDF_Exception__c 
                                                  WHERE Id =: exceptionId];
            exceptionList.add(exceptionVar);
            String exceptionUserpermissionSet = Label.Core_MDF_Exception_User_Permission_Set;
            List<String> exceptionUserpermissionSetList = exceptionUserpermissionSet.split(',');
            List<PermissionSetAssignment> pSet = [SELECT PermissionSet.Name 
                                                  FROM PermissionSetAssignment 
                                                  WHERE AssigneeId =: UserInfo.getUserId() AND 
                                                  PermissionSet.Name IN : exceptionUserpermissionSetList];
            system.debug('pSet-->'+pSet);
            if(pSet != NULL && pSet.size() > 0){
                for(PermissionSetAssignment lstpset : pSet){
                    if(Label.Core_MDF_Exception_Reviewer_Permission_Set.containsIgnoreCase(lstpset.PermissionSet.Name)){
                        exceptionWrap.isReviewer=TRUE;
                    }
                    else if(Label.Core_MDF_Exception_Submitter_Permission_Set.containsIgnoreCase(lstpset.PermissionSet.Name)){
                        exceptionWrap.isSubmitter=TRUE;
                    }
                }
            }
            system.debug('exceptionWrap-->'+exceptionWrap);
            if(exceptionVar != NULL){
                if((Label.Core_MDF_Exception_Denied_Status).containsIgnoreCase(exceptionVar.Core_MDF_Exception_Status_nm__c)){
                    exceptionWrap.isDenied = true;
                } 
                else if((Label.Core_MDF_Exception_Cancelled_Status).containsIgnoreCase(exceptionVar.Core_MDF_Exception_Status_nm__c)){
                    exceptionWrap.isCancelled = true;
                }
                else if((Label.Core_MDF_Exception_PendingReview_Status).containsIgnoreCase(exceptionVar.Core_MDF_Exception_Status_nm__c)){
                    exceptionWrap.isPendingReview = true;
                }
                else if(((Label.Core_MDF_Exception_Approved_Status).containsIgnoreCase(exceptionVar.Core_MDF_Exception_Status_nm__c)) && exceptionWrap.isReviewer){
                    exceptionWrap.isApproved = true;
                }
                else if(((Label.Core_MDF_Exception_Approved_Status).containsIgnoreCase(exceptionVar.Core_MDF_Exception_Status_nm__c)) && exceptionWrap.isSubmitter){
                    exceptionWrap.isSubmitterCancellingApproved = true;
                }
                else if(exceptionVar.Core_MDF_Exception_Status_nm__c=='Draft'){
                    exceptionWrap.isDraft= true;
                }
            }
            
            if((!exceptionWrap.isDenied) && (!exceptionWrap.isCancelled) && (!exceptionWrap.isSubmitterCancellingApproved)){
                if((exceptionWrap.isPendingReview) && ((exceptionWrap.isSubmitter) || (exceptionWrap.isReviewer))){
                    
                    List<ProcessInstanceWorkitem>  piList = new List<ProcessInstanceWorkitem>();
                    
                    //Unlocking the record
                    Approval.UnlockResult[] urList = Approval.unlock(exceptionList, false);
                    //Removing the record from the Approval Process
                    for(ProcessInstance pi : [SELECT Id, TargetObjectId,(SELECT Id FROM Workitems)
                                              FROM ProcessInstance
                                              WHERE TargetObjectId =: exceptionId]){
                    //Avoid Deeply Nested IF Statements       
                    piList.addAll((pi.Workitems.size() > 0) ? pi.Workitems : null);
                    }
                    //Avoid Deeply Nested IF Statements
                    List<Database.DeleteResult> deleteResults = (piList.size() > 0) ? Database.delete(piList) : null;

                    exceptionVar.Core_MDF_Exception_Status_nm__c = 'Cancelled';
                    Database.update (exceptionVar);
                }
                else if(exceptionWrap.isApproved){
                    exceptionVar.Core_MDF_Exception_Status_nm__c = 'Cancelled';
                    Database.update (exceptionVar);
                }else if (exceptionWrap.isDraft){
                    exceptionVar.Core_MDF_Exception_Status_nm__c = 'Cancelled';
                    Database.update (exceptionVar);
                }   
            }
            return exceptionWrap;
        }
        catch(AuraHandledException e){Core_MDF_CCP_UtilityClass.logError(e);
                                      throw e;
                                     }
    }
    
    Public static Boolean isCancellationAllowed(Id exceptionId){
        Boolean isExceptionReviewer = false;
        try{
            List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
            exceptionList = [SELECT Core_MDF_Exception_Status_nm__c,Core_MDF_Select_All_Accounts_ind__c,Core_MDF_Program_nm__c 
                             FROM Core_MDF_Exception__c 
                             WHERE Id =: exceptionId Limit 1];
            if(!exceptionList[0].Core_MDF_Select_All_Accounts_ind__c){
                isExceptionReviewer = true;
            }else{
                isExceptionReviewer = FeatureManagement.checkPermission('Core_MDF_ExceptionReviewer');
            }
             return isExceptionReviewer;  
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);return null;}
    }
 
}