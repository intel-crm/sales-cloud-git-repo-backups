/***********************************************************************************************************************************
* Class Name  : Core_MDF_UpdateClaimOnBankHold 
* Version     : 1.0    
* Created Date: 05-27-2021
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - NK      05/27/2021      This Class is called from process builder Core_MDF_PB_Bank_Status_Update 
									  to Update related claims when bank is put on hold.
*************************************************************************************************************************************/
public class Core_MDF_UpdateClaimOnBankHold {
    
    public class BatchInputs{
        // Bank hold reason
        @InvocableVariable(label = 'Reason')
        public String reason;
        @InvocableVariable(label = 'BankIds')
        public List<id> bankIds;
    } 
    @InvocableMethod()
    public static void executeBatchMethod(List<BatchInputs> processInput) {
        if(processInput != Null && processInput.size()>0){
            BatchInputs inputs = processInput.get(0);
            if(inputs.bankIds != Null && inputs.bankIds.size()>0){
                try{
                    //Batch size from custom settings
                    Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('BATCH_UPDATE_CLAIM_ON_BANK_HOLD_LIMIT');
                    Database.executeBatch(new Core_MDF_Batch_UpdateClaimOnBankHold(inputs.bankIds,inputs.reason),Integer.valueOf(config.Core_MDF_Value__c));  
                }catch (Exception exce) {
                    Core_MDF_CCP_UtilityClass.logError(exce);
                    throw new NewException('Application error');
                }
            }
        }
    }
    
    public class NewException extends Exception {}
}