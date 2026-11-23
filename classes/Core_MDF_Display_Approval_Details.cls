/****************************************************************************************************************************************
* Class Name  : Core_MDF_Display_Approval_Details 
* Test class     : Core_MDF_Display_Approval_Details _Test
* Created Date: 05-04-2024
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* 
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Display_Approval_Details {
    public static boolean currentStageMapped = false;
    public static integer currentStageIndex = 0; 
    /****************************************************************************************************** 
Method Name:        getApprovalDetails
@return  :          ContentResult - Wrapper which will hold the details of all approval stages of input record.
@parameters:        string recordId
Description:        This method is fetch approval stage details.
Modified By:        Date:      Changes: 
*******************************************************************************************************/  
    @AuraEnabled
    Public static ContentResultBRE getApprovalDetails(string recordId){
        System.debug('*** DEBUG: getApprovalDetails START - recordId: ' + recordId);
        ContentResultBRE result = new ContentResultBRE();
        boolean isApprovalDisplayEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_Approval_Stage_Display_Enabled');
        System.debug('*** DEBUG: isApprovalDisplayEnabled: ' + isApprovalDisplayEnabled);
        string objectName = '';
        try{
            if(isApprovalDisplayEnabled){
                System.debug('*** DEBUG: Approval display is enabled');
                if(string.isNotBlank(recordId)){
                    objectName = Id.ValueOf(recordId).getSObjectType().getDescribe().getName(); 
                    System.debug('*** DEBUG: objectName: ' + objectName);
                    switch on objectName {
                        when 'PartnerFundRequest'{
                            System.debug('*** DEBUG: Processing PartnerFundRequest');
                            result = getPFRDetails(recordId);
                        }
                    }
                } else {
                    System.debug('*** DEBUG: recordId is blank');
                }
            } else {
                System.debug('*** DEBUG: Approval display is disabled');
            }
        }catch(exception ex){
            System.debug('*** DEBUG: Exception in getApprovalDetails: ' + ex.getMessage());
            System.debug('*** DEBUG: Exception stack trace: ' + ex.getStackTraceString());
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        System.debug('*** DEBUG: getApprovalDetails END - result: ' + result);
        return result;
    }
    /****************************************************************************************************** 
Method Name:        getPFRDetails
@return  :          ContentResult - Wrapper which will hold the details of all approval stages of input PFR record.
@parameters:        Id pfrId
Description:        This method is fetch approval stage details of PFR record.
Modified By:        Date:      Changes: 
*******************************************************************************************************/ 
    public static ContentResultBRE getPFRDetails(Id pfrId){
        System.debug('*** DEBUG: getPFRDetails START - pfrId: ' + pfrId);
        ContentResultBRE result = new ContentResultBRE();
        InputData inputRecord = new InputData();
        try{
            System.debug('*** DEBUG: Querying PartnerFundRequest');
            PartnerFundRequest pfr = [SELECT Id,Core_MDF_Program__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Price_reviewer_check_ind__c,Core_MDF_Activity_CreatedByExternalUsr__c,Core_MDF_Activity_Classification_nm__c,
                                      Core_MDF_Approval_Stage__c,Core_MDF_Program_Office_Check_ind__c,Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_Budget_Type_nm__c, Core_MDF_Require_Additional_Review_ind__c,
                                      Core_MDF_CreatedByIntUsrType__c, Core_MDF_Intel_Activity_Owner_Id__c
                                      FROM PartnerFundRequest
                                      WHERE Id =: pfrId];
            
            System.debug('*** DEBUG: PFR Record found: ' + pfr);
            System.debug('*** DEBUG: Activity Classification: ' + pfr.Core_MDF_Activity_Classification_nm__c);
            System.debug('*** DEBUG: Current Approval Stage: ' + pfr.Core_MDF_Approval_Stage__c);
            System.debug('*** DEBUG: Fund Request Status: ' + pfr.Core_MDF_Fund_Request_Status__c);
            System.debug('*** DEBUG: Budget Type: ' + pfr.Core_MDF_Budget_Type_nm__c);
            System.debug('*** DEBUG: Program: ' + pfr.Core_MDF_Program__c);
            
            inputRecord.Program = pfr.Core_MDF_Program__c;
            inputRecord.Status = pfr.Core_MDF_Fund_Request_Status__c;
            inputRecord.SPIFCheck = pfr.Core_MDF_Price_reviewer_check_ind__c;
            inputRecord.CreatedByExternalUser = pfr.Core_MDF_Activity_CreatedByExternalUsr__c;
            inputRecord.PORCheck = pfr.Core_MDF_Program_Office_Check_ind__c;
            inputRecord.BudgetType = pfr.Core_MDF_Budget_Type_nm__c;
            inputRecord.currentApprovalStage = pfr.Core_MDF_Approval_Stage__c;
            inputRecord.AdditionalReview  = pfr.Core_MDF_Require_Additional_Review_ind__c;
            inputRecord.AmountRange=pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c;

            //Based on Core_MDF_Intel_Activity_Owner_Id__c field giving input to BRE to fetch the correct record.
            if(String.isBlank(pfr.Core_MDF_Intel_Activity_Owner_Id__c)){
                inputRecord.IntelOwnerSelected = false;
                System.debug('*** DEBUG: Intel Owner NOT selected');
            }else{
                inputRecord.IntelOwnerSelected = true;
                System.debug('*** DEBUG: Intel Owner selected: ' + pfr.Core_MDF_Intel_Activity_Owner_Id__c);
            }

            if(pfr.Core_MDF_CreatedByIntUsrType__c != null){
                inputRecord.CreatedByInternalUserType = pfr.Core_MDF_CreatedByIntUsrType__c;
                System.debug('*** DEBUG: Created by internal user type: ' + pfr.Core_MDF_CreatedByIntUsrType__c);
            } else {
                System.debug('*** DEBUG: Created by internal user type is null');
            }

            if(pfr.Core_MDF_Activity_Classification_nm__c != null){
                inputRecord.ActivityClassification=pfr.Core_MDF_Activity_Classification_nm__c;
                System.debug('*** DEBUG: Activity Classification set to: ' + pfr.Core_MDF_Activity_Classification_nm__c);
            } else {
                System.debug('*** DEBUG: Activity Classification is null, defaulting to: ' + inputRecord.ActivityClassification);
            }
            
            System.debug('*** DEBUG: Complete InputData object: ' + inputRecord);
            System.debug('*** DEBUG: Current approval stage check - Stage: ' + inputRecord.currentApprovalStage);
            
            if(inputRecord != null && inputRecord.currentApprovalStage!= null && inputRecord.currentApprovalStage!='' && inputRecord.currentApprovalStage!= 'None' ){
                System.debug('*** DEBUG: Current approval stage is valid, calling getBREConfigData');
                List<OutputWrapper> outputWrapList = getBREConfigData(inputRecord);
                System.debug('*** DEBUG: BRE output received: ' + outputWrapList);
                if(outputWrapList != null){
                    System.debug('*** DEBUG: Processing BRE output');
                    result = getOutputContent(outputWrapList,inputRecord);
                    System.debug('*** DEBUG: Final result after processing: ' + result);
                } else {
                    System.debug('*** DEBUG: BRE output is null');
                }
            } else {
                System.debug('*** DEBUG: Current approval stage is invalid or null/empty/None');
                System.debug('*** DEBUG: inputRecord null check: ' + (inputRecord == null));
                System.debug('*** DEBUG: currentApprovalStage null check: ' + (inputRecord.currentApprovalStage == null));
                System.debug('*** DEBUG: currentApprovalStage empty check: ' + (inputRecord.currentApprovalStage == ''));
                System.debug('*** DEBUG: currentApprovalStage None check: ' + (inputRecord.currentApprovalStage == 'None'));
            }
        }catch(Exception ex){
            System.debug('*** DEBUG: Exception in getPFRDetails: ' + ex.getMessage());
            System.debug('*** DEBUG: Exception stack trace: ' + ex.getStackTraceString());
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        System.debug('*** DEBUG: getPFRDetails END - result: ' + result);
        return result;
    }
    /****************************************************************************************************** 
Method Name:        getBREConfigData
@return  :          List<OutputWrapper> - List of BRE records wrapper
@parameters:        InputData - wrapper with incomming record details
Description:        This method is to get BRE records for PFR record.
Modified By:        Date:      Changes: 
*******************************************************************************************************/ 
    public static List<OutputWrapper> getBREConfigData(InputData record){
        System.debug('*** DEBUG: getBREConfigData START');
        System.debug('*** DEBUG: Input record for BRE: ' + record);
        List<OutputWrapper> outputWrapList = new List<OutputWrapper>();
        List<InputData> recordList = new List<InputData>{record};
        InputWrapper inputWrap = new InputWrapper();
        inputWrap.inputs = recordList;
        
        System.debug('*** DEBUG: BRE Input wrapper: ' + JSON.serialize(inputWrap));
        
        try{     
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:BusinessRuleEngine/services/data/v60.0/actions/custom/runDecisionMatrix/Activity_Approval_Details');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody(JSON.serialize(inputWrap));
            
            System.debug('*** DEBUG: BRE Request endpoint: ' + request.getEndpoint());
            System.debug('*** DEBUG: BRE Request body: ' + request.getBody());
            
            HttpResponse response = http.send(request);
            System.debug('*** DEBUG: BRE Response status code: ' + response.getStatusCode());
            System.debug('*** DEBUG: BRE Response body: ' + response.getBody());
            
            if(response.getStatusCode() == 200) {
                outputWrapList = (List<OutputWrapper>) JSON.deserialize(response.getBody(), List<OutputWrapper>.class);
                System.debug('*** DEBUG: BRE outputWrapList deserialized: ' + outputWrapList);
                if(outputWrapList != null && !outputWrapList.isEmpty()) {
                    System.debug('*** DEBUG: BRE returned ' + outputWrapList.size() + ' records');
                    for(Integer i = 0; i < outputWrapList.size(); i++) {
                        System.debug('*** DEBUG: BRE Output[' + i + ']: ' + outputWrapList[i]);
                        if(outputWrapList[i].outputValues != null) {
                            System.debug('*** DEBUG: BRE Output[' + i + '] stages: Stage1=' + outputWrapList[i].outputValues.Stage1 + 
                                       ', Stage2=' + outputWrapList[i].outputValues.Stage2 + 
                                       ', Stage3=' + outputWrapList[i].outputValues.Stage3);
                        }
                    }
                } else {
                    System.debug('*** DEBUG: BRE returned empty or null list');
                }
            } else {
                System.debug('*** DEBUG: BRE call failed with status: ' + response.getStatusCode() + ', body: ' + response.getBody());
            }
        }catch(Exception ex){
            System.debug('*** DEBUG: Exception in getBREConfigData: ' + ex.getMessage());
            System.debug('*** DEBUG: Exception stack trace: ' + ex.getStackTraceString());
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        
        System.debug('*** DEBUG: getBREConfigData END - returning: ' + outputWrapList);
        return outputWrapList;
    }
    /****************************************************************************************************** 
Method Name:        getOutputContent
@return  :          ContentResultBRE - wrapper with stage label & approval percentage details
@parameters:        List<OutputWrapper> outputWrapList - List of BRE records wrapper & InputData record - wrapper with incomming record details
Description:        This method is to populate wrapper with stage label & approval percentage details for PFR record.
Modified By:        Date:      Changes: 
*******************************************************************************************************/ 
    Public static ContentResultBRE getOutputContent(List<OutputWrapper> outputWrapList, InputData inputRecord){
        System.debug('*** DEBUG: getOutputContent START');
        System.debug('*** DEBUG: inputRecord: ' + inputRecord);
        
        OutputData output = new OutputData();
        ContentResultBRE result = new ContentResultBRE();
        List<StageWrapper> StageWrapperList = new List<StageWrapper>();
        
        try{
            if(outputWrapList != NULL && !outputWrapList.isEmpty() && outputWrapList[0].outputValues != NULL){
                output = outputWrapList[0].outputValues;
                System.debug('*** DEBUG: Processing output stages from BRE');
                System.debug('*** DEBUG: All stages - Stage1: ' + output.Stage1 + ', Stage2: ' + output.Stage2 + 
                           ', Stage3: ' + output.Stage3 + ', Stage4: ' + output.Stage4 + ', Stage5: ' + output.Stage5);
                
                if(output.Stage1 != 'None' && output.Stage1 != null){
                    System.debug('*** DEBUG: Processing Stage1: ' + output.Stage1);
                    StageWrapper stage1 =  getStageWrapper(output.Stage1,inputRecord,1);
                    System.debug('*** DEBUG: Stage1 wrapper: ' + stage1);
                    StageWrapperList.add(stage1);
                }
                if(output.Stage2 != 'None' && output.Stage2 != null){
                    System.debug('*** DEBUG: Processing Stage2: ' + output.Stage2);
                    StageWrapper stage2 =  getStageWrapper(output.Stage2,inputRecord,2);
                    System.debug('*** DEBUG: Stage2 wrapper: ' + stage2);
                    StageWrapperList.add(stage2);
                }
                if(output.Stage3 != 'None' && output.Stage3 != null){
                    System.debug('*** DEBUG: Processing Stage3: ' + output.Stage3);
                    StageWrapper stage3 =  getStageWrapper(output.Stage3,inputRecord,3);
                    System.debug('*** DEBUG: Stage3 wrapper: ' + stage3);
                    StageWrapperList.add(stage3);
                }
                if(output.Stage4 != 'None' && output.Stage4 != null){
                    System.debug('*** DEBUG: Processing Stage4: ' + output.Stage4);
                    StageWrapper stage4 =  getStageWrapper(output.Stage4,inputRecord,4);
                    System.debug('*** DEBUG: Stage4 wrapper: ' + stage4);
                    StageWrapperList.add(stage4);
                }
                if(output.Stage5 != 'None' && output.Stage5 != null){
                    System.debug('*** DEBUG: Processing Stage5: ' + output.Stage5);
                    StageWrapper stage5 =  getStageWrapper(output.Stage5,inputRecord,5);
                    System.debug('*** DEBUG: Stage5 wrapper: ' + stage5);
                    stageWrapperList.add(stage5);
                }
                if(output.Stage6 != 'None' && output.Stage6 != null){
                    System.debug('*** DEBUG: Processing Stage6: ' + output.Stage6);
                    StageWrapper stage6 =  getStageWrapper(output.Stage6,inputRecord,6);
                    System.debug('*** DEBUG: Stage6 wrapper: ' + stage6);
                    stageWrapperList.add(stage6);
                }
                if(output.Stage7 != 'None' && output.Stage7 != null){
                    System.debug('*** DEBUG: Processing Stage7: ' + output.Stage7);
                    StageWrapper stage7 =  getStageWrapper(output.Stage7,inputRecord,7);
                    System.debug('*** DEBUG: Stage7 wrapper: ' + stage7);
                    stageWrapperList.add(stage7);
                }
                if(output.Stage8 != 'None' && output.Stage8 != null){
                    System.debug('*** DEBUG: Processing Stage8: ' + output.Stage8);
                    StageWrapper stage8 =  getStageWrapper(output.Stage8,inputRecord,8);
                    System.debug('*** DEBUG: Stage8 wrapper: ' + stage8);
                    stageWrapperList.add(stage8);
                }
                if(output.Stage9 != 'None' && output.Stage9 != null){
                    System.debug('*** DEBUG: Processing Stage9: ' + output.Stage9);
                    StageWrapper stage9 =  getStageWrapper(output.Stage9,inputRecord,9);
                    System.debug('*** DEBUG: Stage9 wrapper: ' + stage9);
                    stageWrapperList.add(stage9);
                }
                if(output.Stage10 != 'None' && output.Stage10 != null){
                    System.debug('*** DEBUG: Processing Stage10: ' + output.Stage10);
                    StageWrapper stage10 =  getStageWrapper(output.Stage10,inputRecord,10);
                    System.debug('*** DEBUG: Stage10 wrapper: ' + stage10);
                    stageWrapperList.add(stage10);
                }
                
                System.debug('*** DEBUG: Total stages processed: ' + StageWrapperList.size());
                System.debug('*** DEBUG: All stage wrappers: ' + StageWrapperList);
            } else {
                System.debug('*** DEBUG: No valid output from BRE - outputWrapList null/empty or outputValues null');
            }
            
            //multiple stages
            if(!StageWrapperList.isEmpty() && StageWrapperList.size() > 1){
                System.debug('*** DEBUG: Multiple stages found: ' + StageWrapperList.size());
                result.stageWrapperList = stageWrapperList;
                result.progressPercentage = ((Double)(currentStageIndex - 1)/(Double)(stageWrapperList.size() - 1))*100;
                System.debug('*** DEBUG: Progress percentage calculated: ' + result.progressPercentage);
            }
            // in case there is only one stage 
            else if(!StageWrapperList.isEmpty() && StageWrapperList.size() == 1){
                System.debug('*** DEBUG: Single stage found: ' + StageWrapperList);
                result.stageWrapperList = stageWrapperList;
                result.progressPercentage = 100;
                System.debug('*** DEBUG: Progress percentage set to 100 for single stage');
            } else {
                System.debug('*** DEBUG: No stages found in StageWrapperList');
            }
        }catch(Exception ex){
            System.debug('*** DEBUG: Exception in getOutputContent: ' + ex.getMessage());
            System.debug('*** DEBUG: Exception stack trace: ' + ex.getStackTraceString());
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        
        System.debug('*** DEBUG: getOutputContent END - result: ' + result);
        return result;
    }
    /****************************************************************************************************** 
Method Name:        getStageWrapper
@return  :          StageWrapper - wrapper with stage details
@parameters:        string stageCode,InputData record,integer stageIndex
Description:        This method is to populate StageWrapper with stage details for PFR record.
Modified By:        Date:      Changes: 
*******************************************************************************************************/ 
    public static StageWrapper getStageWrapper(string stageCode,InputData record,integer stageIndex){
        System.debug('*** DEBUG: getStageWrapper START - stageCode: ' + stageCode + ', stageIndex: ' + stageIndex);
        System.debug('*** DEBUG: Current approval stage from record: ' + record.currentApprovalStage);
        System.debug('*** DEBUG: currentStageMapped: ' + currentStageMapped + ', currentStageIndex: ' + currentStageIndex);
        
        StageWrapper stageWrap = new StageWrapper();
        stageWrap.ApprovalStageCode = stageCode;
        try{
            System.debug('*** DEBUG: Querying Core_MDF_ApprovalStageConfig__c for stageCode: ' + stageCode);
            Core_MDF_ApprovalStageConfig__c approvalConfig = [SELECT Id, Name, Core_MDF_Approval_Stage_Label_txt__c, Core_MDF_Approval_Stage_API_txt__c FROM Core_MDF_ApprovalStageConfig__c WHERE Core_MDF_Approval_Stage_API_txt__c =: stageCode LIMIT 1];
            if(approvalConfig!= null){
                stageWrap.ApprovalStageLabel = approvalConfig.Core_MDF_Approval_Stage_Label_txt__c;
                System.debug('*** DEBUG: Found approval config - Label: ' + approvalConfig.Core_MDF_Approval_Stage_Label_txt__c);
            } else {
                System.debug('*** DEBUG: No approval config found for stageCode: ' + stageCode);
            }
            stageWrap.StageIndex = stageIndex;
            
            if(!currentStageMapped){
                System.debug('*** DEBUG: Checking if this is current stage - stageCode: ' + stageCode + ' vs record.currentApprovalStage: ' + record.currentApprovalStage);
                if(stageCode == record.currentApprovalStage){
                    stageWrap.IsCurrentStage = true;
                    currentStageIndex = stageIndex;
                    currentStageMapped = true;
                    System.debug('*** DEBUG: This is the current stage! Setting currentStageIndex to: ' + currentStageIndex);
                }
                else{
                    stageWrap.IsStepCompleted = true;
                    System.debug('*** DEBUG: This stage is completed');
                }
            } else {
                System.debug('*** DEBUG: Current stage already mapped, this is a future stage');
            }
            
            System.debug('*** DEBUG: Final stage wrapper: ' + stageWrap);
        }catch(Exception ex){
            System.debug('*** DEBUG: Exception in getStageWrapper: ' + ex.getMessage());
            System.debug('*** DEBUG: Exception stack trace: ' + ex.getStackTraceString());
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return stageWrap;
    }
    
    //Wrapper to hold list of input records data to pass to BRE callout
    Public class InputWrapper{
        public List<InputData> inputs;
    }
    //Wrapper to hold list of output data from BRE callout
    Public class OutputWrapper{
        public OutputData outputValues;
    }
    // output data from BRE
    Public class OutputData{
        Public string Stage1;
        Public string Stage2;
        Public string Stage3;
        Public string Stage4;
        Public string Stage5;
        Public string Stage6;
        Public string Stage7;
        Public string Stage8;
        Public string Stage9;
        Public string Stage10;
    }
    //input data from record
    Public class InputData{
        Public string Program;
        Public string BudgetType;
        Public string Status;
        Public Boolean SPIFCheck;
        Public Boolean PORCheck;
        Public Boolean CreatedByExternalUser;
        Public string currentApprovalStage;
        Public Decimal AmountRange; 
        Public Boolean AdditionalReview;
        public string ActivityClassification = 'None';
        public String CreatedByInternalUserType = 'None';
        Public Boolean IntelOwnerSelected = false;
    }
    // result wrapper to use on UI
    Public class ContentResultBRE{
        @AuraEnabled Public Double progressPercentage = 0;
        @AuraEnabled Public List<StageWrapper> stageWrapperList;
    }
    // wrapper with stage details
    Public class StageWrapper{
        @AuraEnabled Public string ApprovalStageCode;
        @AuraEnabled Public string ApprovalStageLabel;
        @AuraEnabled Public Integer StageIndex = 0;        
        @AuraEnabled Public Boolean IsCurrentStage = false;
        @AuraEnabled Public Boolean IsStepCompleted = false;
    }
}