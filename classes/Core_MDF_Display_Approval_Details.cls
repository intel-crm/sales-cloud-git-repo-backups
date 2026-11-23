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
        ContentResultBRE result = new ContentResultBRE();
        boolean isApprovalDisplayEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_Approval_Stage_Display_Enabled');
        string objectName = '';
        try{
            if(isApprovalDisplayEnabled){
            if(string.isNotBlank(recordId)){
                objectName = Id.ValueOf(recordId).getSObjectType().getDescribe().getName(); 
                switch on objectName {
                    when 'PartnerFundRequest'{
                        result = getPFRDetails(recordId);
                    }
                }
            }
            }
        }catch(exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
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
        ContentResultBRE result = new ContentResultBRE();
        InputData inputRecord = new InputData();
        try{
        PartnerFundRequest pfr = [SELECT Id,Core_MDF_Program__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Price_reviewer_check_ind__c,Core_MDF_Activity_CreatedByExternalUsr__c,Core_MDF_Activity_Classification_nm__c,
                                  Core_MDF_Approval_Stage__c,Core_MDF_Program_Office_Check_ind__c,Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_Budget_Type_nm__c, Core_MDF_Require_Additional_Review_ind__c,
                                  Core_MDF_CreatedByIntUsrType__c, Core_MDF_Intel_Activity_Owner_Id__c
                                  FROM PartnerFundRequest
                                  WHERE Id =: pfrId];
        
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
        }else{
            inputRecord.IntelOwnerSelected = true;
        }

        if(pfr.Core_MDF_CreatedByIntUsrType__c != null){
            inputRecord.CreatedByInternalUserType = pfr.Core_MDF_CreatedByIntUsrType__c;
        }

        if(pfr.Core_MDF_Activity_Classification_nm__c != null){
             inputRecord.ActivityClassification=pfr.Core_MDF_Activity_Classification_nm__c;
         }
        if(inputRecord != null && inputRecord.currentApprovalStage!= null && inputRecord.currentApprovalStage!='' && inputRecord.currentApprovalStage!= 'None' ){
            List<OutputWrapper> outputWrapList = getBREConfigData(inputRecord);
            if(outputWrapList != null){
                result = getOutputContent(outputWrapList,inputRecord);
            }
        }
        }catch(Exception ex){            
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
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
        List<OutputWrapper> outputWrapList = new List<OutputWrapper>();
        List<InputData> recordList = new List<InputData>{record};
            InputWrapper inputWrap = new InputWrapper();
        inputWrap.inputs = recordList;
        try{     
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:BusinessRuleEngine/services/data/v60.0/actions/custom/runDecisionMatrix/Activity_Approval_Details');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody(JSON.serialize(inputWrap));
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                outputWrapList = (List<OutputWrapper>) JSON.deserialize(response.getBody(), List<OutputWrapper>.class);
            }             
        }catch(Exception ex){            
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        
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
        OutputData output = new OutputData();
        ContentResultBRE result = new ContentResultBRE();
        List<StageWrapper> StageWrapperList = new List<StageWrapper>();
        try{
        if(outputWrapList != NULL && !outputWrapList.isEmpty() && outputWrapList[0].outputValues != NULL){
            output = outputWrapList[0].outputValues;
            if(output.Stage1 != 'None' && output.Stage1 != null){
                StageWrapper stage1 =  getStageWrapper(output.Stage1,inputRecord,1);
                StageWrapperList.add(stage1);
            }
            if(output.Stage2 != 'None' && output.Stage2 != null){
                StageWrapper stage2 =  getStageWrapper(output.Stage2,inputRecord,2);
                StageWrapperList.add(stage2);
            }
            if(output.Stage3 != 'None' && output.Stage3 != null){
                StageWrapper stage3 =  getStageWrapper(output.Stage3,inputRecord,3);
                StageWrapperList.add(stage3);
            }
            if(output.Stage4 != 'None' && output.Stage4 != null){
                StageWrapper stage4 =  getStageWrapper(output.Stage4,inputRecord,4);
                StageWrapperList.add(stage4);
            }
            if(output.Stage5 != 'None' && output.Stage5 != null){
                StageWrapper stage5 =  getStageWrapper(output.Stage5,inputRecord,5);
                stageWrapperList.add(stage5);
            }
            if(output.Stage6 != 'None' && output.Stage6 != null){
                StageWrapper stage6 =  getStageWrapper(output.Stage6,inputRecord,6);
                stageWrapperList.add(stage6);
            }
            if(output.Stage7 != 'None' && output.Stage7 != null){
                StageWrapper stage7 =  getStageWrapper(output.Stage7,inputRecord,7);
                stageWrapperList.add(stage7);
            }
            if(output.Stage8 != 'None' && output.Stage8 != null){
                StageWrapper stage8 =  getStageWrapper(output.Stage8,inputRecord,8);
                stageWrapperList.add(stage8);
            }
            if(output.Stage9 != 'None' && output.Stage9 != null){
                StageWrapper stage9 =  getStageWrapper(output.Stage9,inputRecord,9);
                stageWrapperList.add(stage9);
            }
            if(output.Stage10 != 'None' && output.Stage10 != null){
                StageWrapper stage10 =  getStageWrapper(output.Stage10,inputRecord,10);
                stageWrapperList.add(stage10);
            }
            
        }      
        //multiple stages
        if(!StageWrapperList.isEmpty() && StageWrapperList.size() > 1){
            result.stageWrapperList = stageWrapperList;
            result.progressPercentage = ((Double)(currentStageIndex - 1)/(Double)(stageWrapperList.size() - 1))*100;
        }
        // in case there is only one stage 
        else if(!StageWrapperList.isEmpty() && StageWrapperList.size() == 1){
            result.stageWrapperList = stageWrapperList;
            result.progressPercentage = 100;
        }
        }catch(Exception ex){            
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
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
        StageWrapper stageWrap = new StageWrapper();
        stageWrap.ApprovalStageCode = stageCode;
        try{
            //Core_MDF_ApprovalStageConfig__c approvalConfig = Core_MDF_ApprovalStageConfig__c.getValues(stageCode);
            Core_MDF_ApprovalStageConfig__c approvalConfig = [SELECT Id, Name, Core_MDF_Approval_Stage_Label_txt__c, Core_MDF_Approval_Stage_API_txt__c FROM Core_MDF_ApprovalStageConfig__c WHERE Core_MDF_Approval_Stage_API_txt__c =: stageCode LIMIT 1];
            if(approvalConfig!= null){
                stageWrap.ApprovalStageLabel = approvalConfig.Core_MDF_Approval_Stage_Label_txt__c;
            }
            stageWrap.StageIndex = stageIndex;
            if(!currentStageMapped){
                if(stageCode == record.currentApprovalStage){
                    stageWrap.IsCurrentStage = true;
                    currentStageIndex = stageIndex;
                    currentStageMapped = true;
                }
                else{
                    stageWrap.IsStepCompleted = true;
                }
            }
        }catch(Exception ex){            
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