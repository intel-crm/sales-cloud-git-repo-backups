public class Core_MDF_Batch_PaymentFilesGeneration implements  Database.Batchable<Core_MDF_PaymentFileWrapper>,Database.AllowsCallouts,Database.stateful {
    
    public Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap = new Map<String, Core_MDF_PaymentWrapper>();
    public Core_MDF_Payment_Run__c prunInstance;
    public String paymentRunProgram;
    public Map<String,Map<String,Core_MDF_PaymentFileWrapper>> paymentTypeToFileWrapper= new Map<String,Map<String,Core_MDF_PaymentFileWrapper>>();
    public List<Core_MDF_PaymentFileWrapper> paymentFileWrapperMap;
    public List<PartnerFundClaim> listOfClaims = new List<PartnerFundClaim>();
    public String uniqueKey;
    public String query;
    public Boolean errorFlag;
    public Exception exceptionObject;
    public Integer versionNum =0;
    
    public Core_MDF_Batch_PaymentFilesGeneration(String uniqueKey, List<PartnerFundClaim> listOfClaims,Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap, Core_MDF_Payment_Run__c prunInstance, String paymentRunProgram,Map<String,Map<String,Core_MDF_PaymentFileWrapper>> paymentTypeToFileWrapper, List<Core_MDF_PaymentFileWrapper> paymentFileWrapperMap ){
        this.uniqueKey = uniqueKey;
        this.listOfClaims = listOfClaims;        
        this.paymentWrapperMap = paymentWrapperMap;
        this.prunInstance = prunInstance;
        this.paymentRunProgram = paymentRunProgram;
        this.paymentTypeToFileWrapper = paymentTypeToFileWrapper;
        this.paymentFileWrapperMap = paymentFileWrapperMap;
        
    }
    public Iterable<Core_MDF_PaymentFileWrapper> start(Database.BatchableContext bc) {
       return paymentFileWrapperMap;

   }

   public void  execute(Database.BatchableContext bc, List<Core_MDF_PaymentFileWrapper> scope)
     {
        versionNum++;
        //return scope;
        try
        { 
            System.debug('Heap Size Before:'+Limits.getHeapSize());
            System.debug('Limit Heap Size:'+Limits.getLimitHeapSize());

            switch on uniqueKey {

             When 'Expense'
             {
                Core_MDF_Payment_FileHelper.generateIPAPaymentFileForExpense(scope,prunInstance,paymentRunProgram,versionNum);
             }
             
             When 'CSAR Cash'
             {
                //Core_MDF_Payment_FileHelper.generateIPAPaymentFileForExpense(paymentFileWrapperMap,prunInstance,paymentRunProgram);
             }
            
             When 'CSAR Credit Memo'
             {
                Core_MDF_Payment_FileHelper.generateIPAPaymentFileForCreditMemo(paymentFileWrapperMap,prunInstance,paymentRunProgram); 
             } 
        }
    }
    catch(Exception e)
    {
        errorFlag = true;
        exceptionObject = e;
        Core_MDF_CCP_UtilityClass.logError(exceptionObject);
    }
        
}

public void finish(Database.BatchableContext bc) {

    if(errorFlag == true)
    {
        if(listOfClaims != NULL && listOfClaims.size()>0){
            Core_MDF_Batch_RollbackPaymentRunChanges rollbackPRunChangeBatch = new Core_MDF_Batch_RollbackPaymentRunChanges(listOfClaims, paymentWrapperMap);
                Database.executeBatch(rollbackPRunChangeBatch, 200);
            }
            // Update the Payment Run Status to failed
            Core_MDF_PaymentProcess.updatePaymentRunStatusAndErrorDetails(new List<Core_MDF_Payment_Run__c>{prunInstance},Label.Core_MDF_PayRunStatus_Error,exceptionObject.getMessage()); 
            Core_MDF_CCP_UtilityClass.logError(exceptionObject);
    }
   
}
}