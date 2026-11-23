/******************************************************************************************************
* Class Name  : Core_MDF_Batch_PaymentFileGenerator  
* Version     : 1.0    
* Created Date: 01-22-2019
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - JV      01/22/2019          Batchable class to generate .xls/.tsv file and 
link generated content with payment run record.                                   
*******************************************************************************************************/

public without sharing class Core_MDF_Batch_PaymentFileGenerator implements Database.Batchable<sObject>, Database.Stateful {
    //To hold Payment Run record instance
    public Core_MDF_Payment_Run__c prunInstance;
    //To hold program name
    public String paymentRunProgram;
    //Map of unique key and payment wrapper
    public Map<String,Core_MDF_PaymentWrapper> resultantWrapperMap = new Map<String,Core_MDF_PaymentWrapper>();
    //Map of unique Key and Payment File Wrapper
    public Map<String,Core_MDF_PaymentFileWrapper> resultantFileWrapperMap = new Map<String,Core_MDF_PaymentFileWrapper>();
    public Map<String,Core_MDF_PaymentWrapper> tempPaymentWrapper = new Map<String,Core_MDF_PaymentWrapper>();
    
    //Exception Flag
    public boolean errorFlag = true;
    public Exception exceptionObject;
    //To hold payment due claims
    public List<PartnerFundClaim> paymentDueClaimsToBeProcessedForPayment;
    // claims Bu Split List to be a stateful variable to be passed in the next batch for insertion
    public List<Core_MDF_Claim_BU_Split__c> claimsBUSplitList = new List<Core_MDF_Claim_BU_Split__c>();
    Map<String,List<PartnerFundClaim>> paymentTypeToClaims= new Map<String,List<PartnerFundClaim>>();
    Map<String,Map<String,Core_MDF_PaymentFileWrapper>> paymentTypeToFileWrapper= new Map<String,Map<String,Core_MDF_PaymentFileWrapper>>();
    Map<Id,Core_MDF_Comarketing_CMF_Map__c> cmpMap = new Map<Id,Core_MDF_Comarketing_CMF_Map__c>();
    public Map<Id,String> claimToCostCenterMap  = new Map<Id,String>();
    public Map<Id, Core_MDF_Account_Node_Attributes__c> accountNodeAttributesMap = new Map<Id, Core_MDF_Account_Node_Attributes__c>();  
    public Map<Id, Core_MDF_Account_Node_Attributes__c> tempAccountNodeAttributesMap = new Map<Id, Core_MDF_Account_Node_Attributes__c>();  
    private static String CoGTMProgram = Core_MDF_CustomLabelConfig.getTextValues('Co_GTM');
    
    // Constructor -  To assign pay run instance, pass the geo and pgm to constructor
    public Core_MDF_Batch_PaymentFileGenerator(Core_MDF_Payment_Run__c prunInstance){
        this.prunInstance = prunInstance;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        // From list of pruns ==> for one prun - based on its geo and program find All claims store it 
        Core_MDF_Payment_Run__c paymentRunInstance = [SELECT Id, Name,Core_MDF_Program_Txt__c, Core_MDF_Payment_Nature_nm__c,Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Program_Id__r.Name, Core_MDF_Geo_Txt__c,Core_MDF_Subgeo_Txt__c, 
                                                      Core_MDF_PaymentJob_Id__c, Core_MDF_ErrorDetails_Txt__c, Core_MDF_Status_Txt__c, Core_MDF_ScheduleRun_Dtm__c 
                                                      ,Core_MDF_Start_Dt__c,RecordType.DeveloperName, Core_MDF_End_Dt__c, Core_MDF_Budget_Type_nm__c,Core_MDF_Files_Name_Txt__c,Core_MDF_Payment_run_for_Accounts__c,Core_MDF_Payment_Types_txt__c FROM Core_MDF_Payment_Run__c WHERE Id =:prunInstance.Id LIMIT 1];
        
        String prunInstanceId = paymentRunInstance.Id;
        prunInstance = paymentRunInstance;
        paymentRunProgram = paymentRunInstance.Core_MDF_Program_Id__r.Name;
        String query = 'SELECT Id, Name,Core_MDF_Payment_Nature_nm__c,Core_MDF_Program_Txt__c, Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c,RecordType.DeveloperName,Core_MDF_Program_Id__r.Name, Core_MDF_Geo_Txt__c,Core_MDF_Subgeo_Txt__c, Core_MDF_PaymentJob_Id__c, Core_MDF_ErrorDetails_Txt__c, Core_MDF_Status_Txt__c, Core_MDF_ScheduleRun_Dtm__c, Core_MDF_Start_Dt__c, Core_MDF_End_Dt__c,Core_MDF_Budget_Type_nm__c, Core_MDF_Payment_run_for_Accounts__c, Core_MDF_Payment_Types_txt__c,Core_MDF_Account_Id__c'+ 
            ' FROM Core_MDF_Payment_Run__c WHERE Id =:prunInstanceId LIMIT 1';
        return Database.getQueryLocator(String.escapeSingleQuotes(query)); 
    }
    
    // process each batch of records
    public void execute(Database.BatchableContext bc, List<Core_MDF_Payment_Run__c> paymentRunRecordsTobeProcessed) {
        Savepoint sp = Database.setSavepoint();
        try{            
            //checking adjustment process is active or not on custom setting
            Core_Trigger_Executions__c adjustmentClaimOffsetCustomSetting = Core_Trigger_Executions__c.getValues(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AdjustmentClaimOffsetProcess'));
            /*if(adjustmentClaimOffsetCustomSetting.Core_Active__c){
                //PD claims after offset Process */
                paymentDueClaimsToBeProcessedForPayment = Core_MDF_AdjustmentClaimOffsetProcess.performClaimAdjustmentProcess(paymentRunRecordsTobeProcessed); 
            //}
            /*else{
                //filter payment due claims for payment process, if adjustments is inactive
                paymentDueClaimsToBeProcessedForPayment = Core_MDF_PaymentUtility.queryPaymentDueClaimsForPayment(paymentRunRecordsTobeProcessed);
            }*/

            // This method updates the Payment Run Status to Inprogress before claim grouping and Payment Record Creation
            Core_MDF_PaymentProcess.updatePaymentRunRecord(new List<Core_MDF_Payment_Run__c>{prunInstance},Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PayRunStatus_Inprogress'));
            
            if(paymentDueClaimsToBeProcessedForPayment!=NULL && paymentDueClaimsToBeProcessedForPayment.size() > 0){
                
                // If Budget Type is retail MDF Or Program is IPA
                if((prunInstance.Core_MDF_Budget_Type_nm__c != NULL && prunInstance.Core_MDF_Budget_Type_nm__c==Label.Core_MDF_RetailMDF_BudgetType)){
                    // For Grouping of Claims For File generation
                    resultantFileWrapperMap = Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(paymentDueClaimsToBeProcessedForPayment, prunInstance, null, null);
                    // Creating Payment wrapper 
                    resultantWrapperMap = Core_MDF_PaymentProcessRetailMdfIPA.createPaymentWrapperMap(resultantFileWrapperMap, prunInstance);
                    // Creating Payment record
                    resultantWrapperMap = Core_MDF_PaymentProcessRetailMdfIPA.createPaymentRecordRetailMDF(prunInstance, resultantWrapperMap, '');
          //claimsBUSplitList = Core_MDF_PaymentProcessRetailMdfIPA.claimsBUSplitList;         
                }
                else if(prunInstance.Core_MDF_Program_Id__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name'))
                {  
                    paymentTypeToClaims = Core_MDF_PaymentUtility.getPaymentTypeToClaimList(paymentDueClaimsToBeProcessedForPayment); 
        tempAccountNodeAttributesMap = Core_MDF_PaymentUtility.getAccountNodeAttributes(paymentDueClaimsToBeProcessedForPayment);
                    for(String key : paymentTypeToClaims.keySet()){
                        
                        Map<String,Core_MDF_PaymentFileWrapper> resultantFileWrapperIpaMap = new Map<String,Core_MDF_PaymentFileWrapper>();
                        resultantFileWrapperMap = new Map<String,Core_MDF_PaymentFileWrapper>();

                        if(key == Core_MDF_PaymentUtility.expense){
                            //For Grouping of Claims For File generation
                            resultantFileWrapperMap.putAll(Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(paymentTypeToClaims.get(key), prunInstance, null, tempAccountNodeAttributesMap));
                            tempPaymentWrapper =createPaymentFileMap(resultantFileWrapperMap,prunInstance, key); 
                            claimToCostCenterMap = Core_MDF_PaymentProcessRetailMdfIPA.getClaimToCostCenterMap();
                        }
                        else if(key == Core_MDF_PaymentUtility.csarCash){
                            //For Grouping of Claims For File generation
                            resultantFileWrapperMap.putAll(Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(paymentTypeToClaims.get(key), prunInstance, null, tempAccountNodeAttributesMap));
                            tempPaymentWrapper = createPaymentFileMap(resultantFileWrapperMap,prunInstance, key);
                        }
                        else if(key == Core_MDF_PaymentUtility.csarCreditMemo){
                            cmpMap = Core_MDF_PaymentUtility.getCMFRecords(paymentTypeToClaims.get(key));
                            if(cmpMap !=null && cmpMap.size() >0)
                            {
                               //For Grouping of Claims For File generation
                            resultantFileWrapperMap.putAll(Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(paymentTypeToClaims.get(key), prunInstance,cmpMap, tempAccountNodeAttributesMap));
                            tempPaymentWrapper =createPaymentFileMap(resultantFileWrapperMap,prunInstance, key);
                            }
                            
                        }

                        resultantWrapperMap.putAll(tempPaymentWrapper);
                        if(resultantFileWrapperMap != null && !resultantFileWrapperMap.isEmpty()){
                            paymentTypeToFileWrapper.put(key, resultantFileWrapperMap);
                        }

                        accountNodeAttributesMap.putAll(tempAccountNodeAttributesMap);

                    }
                }
                else if(prunInstance.Core_MDF_Program_Id__r.Name == CoGTMProgram){
                    //to prepare map of key-claims
                    paymentTypeToClaims = Core_MDF_PaymentUtility.getPaymentTypeToClaimList(paymentDueClaimsToBeProcessedForPayment);
                    
                    //to prepare map of account id-node atribute map
                    tempAccountNodeAttributesMap = Core_MDF_PaymentUtility.getAccountNodeAttributes(paymentDueClaimsToBeProcessedForPayment);
                    for(String key : paymentTypeToClaims.keySet()){
                        resultantFileWrapperMap = new Map<String, Core_MDF_PaymentFileWrapper>();
                        if(key == Core_MDF_PaymentUtility.csarCash){
                            //For Grouping of Claims For File generation
                            resultantFileWrapperMap.putAll(Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(paymentTypeToClaims.get(key), prunInstance, null, tempAccountNodeAttributesMap));
                            tempPaymentWrapper = createPaymentFileMap(resultantFileWrapperMap,prunInstance, key);
                        }
                        else if(key == Core_MDF_PaymentUtility.csarCreditMemo){
                            //need to populate this
                            cmpMap = Core_MDF_PaymentUtility.getCMFRecords(paymentTypeToClaims.get(key));
                            if(cmpMap !=null && cmpMap.size() > 0){
                                //For Grouping of Claims For File generation
                                resultantFileWrapperMap.putAll(Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(paymentTypeToClaims.get(key), prunInstance, cmpMap, tempAccountNodeAttributesMap));
                                tempPaymentWrapper = createPaymentFileMap(resultantFileWrapperMap,prunInstance, key);
                            }
                        }
                        else if(key == Core_MDF_PaymentUtility.cogtmVistex){
                            // This method groups claim depending on Company, Bank and Supplier Number
                            resultantWrapperMap = Core_MDF_PaymentProcess.groupClaimsforPayment(paymentDueClaimsToBeProcessedForPayment);                    
                            // This method creates the Payment Records according to the grouping done
                            resultantWrapperMap = Core_MDF_PaymentProcess.createPaymentRecord(prunInstance,resultantWrapperMap);
                        }
                        else if(key == Core_MDF_PaymentUtility.expense){
                            //For Grouping of Claims For File generation
                            resultantFileWrapperMap.putAll(Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(paymentTypeToClaims.get(key), prunInstance, null, tempAccountNodeAttributesMap));
                            tempPaymentWrapper =createPaymentFileMap(resultantFileWrapperMap,prunInstance, key); 
                            claimToCostCenterMap = Core_MDF_PaymentProcessRetailMdfIPA.getClaimToCostCenterMap();
                        }
                        if(key != Core_MDF_PaymentUtility.cogtmVistex){
                            resultantWrapperMap.putAll(tempPaymentWrapper);
                            if(resultantFileWrapperMap != null && !resultantFileWrapperMap.isEmpty()){
                                paymentTypeToFileWrapper.put(key, resultantFileWrapperMap);
                            }
                            accountNodeAttributesMap.putAll(tempAccountNodeAttributesMap);
                        }
                    }
                }
                else{ //This is for Retail MD and CCP program
                    // This method groups claim depending on Company, Bank and Supplier Number
                    resultantWrapperMap = Core_MDF_PaymentProcess.groupClaimsforPayment(paymentDueClaimsToBeProcessedForPayment);                    
                    // This method creates the Payment Records according to the grouping done
                    resultantWrapperMap = Core_MDF_PaymentProcess.createPaymentRecord(prunInstance,resultantWrapperMap);
                }               
            }errorFlag = false;
        }catch(Exception e){ errorFlag = true;exceptionObject = e;Database.rollback(sp);        }  
    }   
    
public static Map<String,Core_MDF_PaymentWrapper> createPaymentFileMap(Map<String,Core_MDF_PaymentFileWrapper> resultantFileWrapperMap,Core_MDF_Payment_Run__c prunInstance, String paymentFileFormatName)
{
      Map<String,Core_MDF_PaymentWrapper> PaymentWrapperMap  = new Map<String,Core_MDF_PaymentWrapper>() ;
      
        //Creating Payment wrapper 
        PaymentWrapperMap = Core_MDF_PaymentProcessRetailMdfIPA.createPaymentWrapperMap(resultantFileWrapperMap, prunInstance);
        //Creating Payment record
        PaymentWrapperMap = Core_MDF_PaymentProcessRetailMdfIPA.createPaymentRecordRetailMDF(prunInstance, PaymentWrapperMap, paymentFileFormatName);
      return PaymentWrapperMap;
         
}
public void finish(Database.BatchableContext bc) {
        
        try{
            if(errorFlag == false){
                // Batch to Generate Payment File and Update Claims 
                Core_MDF_Batch_UpdatePaymentRunClaims updateClaimStatusBatch = new Core_MDF_Batch_UpdatePaymentRunClaims(resultantWrapperMap, resultantFileWrapperMap,paymentTypeToFileWrapper, paymentDueClaimsToBeProcessedForPayment, prunInstance, claimsBUSplitList,paymentTypeToClaims,claimToCostCenterMap, accountNodeAttributesMap);
                Database.executeBatch(updateClaimStatusBatch, 200);
            }else{
                // This method updates the Payment record with Status and Error field in case of errors/exceptions
                Core_MDF_PaymentProcess.updatePaymentRunStatusAndErrorDetails(new List<Core_MDF_Payment_Run__c>{prunInstance},Label.Core_MDF_PayRunStatus_Error,exceptionObject.getMessage()); Core_MDF_CCP_UtilityClass.logError(exceptionObject);
            }
        }catch(Exception e){ Core_MDF_PaymentProcess.updatePaymentRunStatusAndErrorDetails(new List<Core_MDF_Payment_Run__c>{prunInstance},Label.Core_MDF_PayRunStatus_Error,e.getMessage()); Core_MDF_CCP_UtilityClass.logError(e);
        }       
    }    
}