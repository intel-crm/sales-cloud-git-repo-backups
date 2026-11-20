public without sharing class Core_MDF_Budget_Approval {
    /*****************************************************************************************************
    Method Name : loadBudgetecord
    @return     : Object
    @parameters : Budget Record
    Description : 
    Added By    : Saikat Manna on 5-Jul-2023
    Modified By :                  Date:                   Changes:
    ******************************************************************************************************/
    @AuraEnabled
    public static UserPermissionApproval loadBudgetecord(String budgetId){
        UserPermissionApproval userPermissionApprovalBudget = new UserPermissionApproval();
        PartnerMarketingBudget budgetval= new PartnerMarketingBudget();
        try{
            List<PartnerMarketingBudget> budgetvalList = [SELECT Id, Core_MDF_Program_Nm__c, Core_MDF_Ultimate_Account_Id__c, 
                                                          Core_MDF_Budget_Type_Txt__c, recordtype.developername, Core_MDF_Budget_Status__c 
                                                          FROM PartnerMarketingBudget 
                                                          WHERE Id =: budgetId LIMIT 1];
            if(budgetvalList != null && !budgetvalList.isEmpty()){
                budgetval = budgetvalList[0];
            }
            userPermissionApprovalBudget.budgetInstance = budgetval;
            if(budgetval != null && budgetval.Core_MDF_Budget_Status__c == Core_MDF_CCP_ConstantClass.Budget_PENDING_REVIEW){
                ProcessInstanceWorkItem piwitm;
                List<ProcessInstanceWorkItem> piwitmList = [SELECT ProcessInstance.TargetObjectId, Id 
                                                            FROM ProcessInstanceWorkItem
                                                            WHERE ProcessInstance.Status = 'Pending' 
                                                            AND ProcessInstance.TargetObjectId =: budgetId LIMIT 1];
                if(piwitmList != null && !piwitmList.isEmpty()){
                    piwitm = piwitmList[0];
                }
                if(piwitm != null){
                    //Avoid Deeply Nested If
                    userPermissionApprovalBudget.processInstanceWorkItemInstance = piwitm;
                    // Check custom permissions using boolean variable
                    Boolean hasCustomPermission = isCustomPermissionAssigned('Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver') 
                           || isCustomPermissionAssigned('Core_MDF_CCP_Internal_DCF_MDF_Budget_Approver')
                           || isCustomPermissionAssigned('Core_MDF_CCP_Internal_IPA_Budget_Approver')
                           || isCustomPermissionAssigned('Core_MDF_Internal_EEF_Budget_Approver')
                           || isCustomPermissionAssigned('Core_MDF_CCP_Internal_Co_GTM_Budget_Approver');
                    userPermissionApprovalBudget.isCustomPermissionAssigned = hasCustomPermission;
                    userPermissionApprovalBudget.isBudgetApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(budgetval, UserInfo.getUserId());
                }
            } 
        }    
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(e.getMessage());}  
        return userPermissionApprovalBudget;
    }

    /*****************************************************************************************************
    Method Name: isCustomPermissionAssigned
    @return    : Boolean
    @parameters: String - Custom Permission Name
    Description: This method is used to check if the Custom permission is assigned to the User
    Added By   : Saikat Manna on 6-Jul-2023
    Modified By:                   Date:                    Changes:
    ******************************************************************************************************/
    public static Boolean isCustomPermissionAssigned(String customPermissionNameStr){
        Boolean userHasPer = false;
        if(customPermissionNameStr != NULL && String.isNotBlank(customPermissionNameStr)){
            userHasPer = FeatureManagement.checkPermission(customPermissionNameStr);
        }
        return userHasPer;
    }
    /*****************************************************************************************************
    Method Name : approveRejectBudget (Handle the submit or reject actions)
    Added By    : Saikat Manna on 7-Jul-2023
    Modified By :                      Date:                    Changes:
    ******************************************************************************************************/
    @AuraEnabled
    public static String approveRejectBudget(UserPermissionApproval mapValues){
        List<Approval.ProcessWorkitemRequest> processWorkItemReqList = new  List<Approval.ProcessWorkitemRequest>();

        String message = '';
        String budgetId = '';
        try{
            String comment = String.isNotBlank(mapValues.btnActionComment) ? mapValues.btnActionComment : '';
            String action = mapValues.btnAction;
            String piwitmId = mapValues.processInstanceWorkItemInstance.Id;
            budgetId = mapValues.budgetInstance.Id;

            PartnerMarketingBudget pmb = [SELECT Id, Core_MDF_Program_Nm__c, Core_MDF_Ultimate_Account_Id__c, 
                                          Core_MDF_Budget_Type_Txt__c, recordtype.developername, Core_MDF_Budget_Status__c 
                                          FROM PartnerMarketingBudget 
                                          WHERE Id =: budgetId LIMIT 1];
            if(pmb != null && pmb.Core_MDF_Budget_Status__c == Core_MDF_CCP_ConstantClass.Budget_PENDING_REVIEW){
                Approval.ProcessWorkitemRequest aprReq = new Approval.ProcessWorkitemRequest();
                aprReq.setComments(comment);
                aprReq.setAction(action);
                aprReq.setWorkitemId(piwitmId);
                processWorkItemReqList.add(aprReq);

                List<Approval.ProcessResult> processResultList = Approval.process(processWorkItemReqList);
                if(processResultList!=null && !processResultList.isEmpty()){
                    for(Approval.ProcessResult processResult:processResultList){
                        //Avoid Deeply Nested IF Statements
                        Boolean isValidResult = processResult != null;
                        Boolean isSuccess = isValidResult && processResult.isSuccess();
                        Boolean isFailure = isValidResult && !processResult.isSuccess();           
                        message = isSuccess ? 'SUCCESS' : message;           
                        // Use ternary to handle error logging
                        String errorlog = isFailure ? 'Approval failed for activiy ->' + processResult.getEntityId() + ';' : '';
                        String errorDetails = '';                       
                        // Handle errors in a loop - this still needs some form of condition
                        for(Database.Error errDet : (isFailure ? processResult.getErrors() : new List<Database.Error>())){
                            errorDetails += errDet.getMessage();
                            message = errDet.getMessage();
                        }
                        Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog + errorDetails,'approveRejectActivity Method');return message;
                    }
                }
            } else {
                return 'FAILED';
            }
        }
        catch (Exception e) {
            string logerror = '';
            logerror += 'BudgetIDs->' + budgetId + ',->';
            logerror += e.getLineNumber() + '->';
            logerror += e.getMessage() + '->';
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(logerror, 'approveRejectActivity Method');
            message = e.getMessage();
            return message;
        }
        return message;
    }

    /*****************************************************************************************************
    Method Name : UserPermissionApproval (Created a Wrapper to reduce the server side call)
    Added By    : Saikat Manna on 5-Jul-2023
    Modified By :                   Date:                    Changes:
    ******************************************************************************************************/
    public class UserPermissionApproval{
        @AuraEnabled
        public Boolean isBudgetApprover = false;
        @AuraEnabled
        public Boolean isCustomPermissionAssigned  = false; 
        @AuraEnabled
        public PartnerMarketingBudget budgetInstance {get; set;}
        @AuraEnabled
        public ProcessInstanceWorkItem processInstanceWorkItemInstance {get; set;}
        @AuraEnabled
        public String btnAction {get; set;}
        @AuraEnabled
        public String btnActionComment {get; set;}
    }
}