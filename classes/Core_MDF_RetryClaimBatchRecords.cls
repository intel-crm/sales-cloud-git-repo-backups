/******************************************************************************************************
* Class Name  : Core_MDF_RetryClaimBatchRecords 
* Version     : 1.0 
* Created Date: 21-Dec-2020
* Modification Log :
* Developer           Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture-Vaishali  21-Dec-2020         
*******************************************************************************************************/
public class Core_MDF_RetryClaimBatchRecords {
    
    /***************************************************************************************
Class Name:         claimBatchwrapper
Description:        This wrapper class will hold the values of all the variables
Added By: Vaishali  Accenture - 21-Dec-2020
Modified By:        Date:      Changes: 
****************************************************************************************/    
    public class claimBatchwrapper{
        @AuraEnabled
        public Boolean isClaimBatchRecStatusFailed = false;
        @AuraEnabled
        public List<Core_MDF_Claim_Batch_Stage__c> claimBatchRecList = new List<Core_MDF_Claim_Batch_Stage__c>();
        @AuraEnabled
        public String exceptionDetails;
    }
    
    /*********************************************************************************************************
Method Name:        checkClaimBatchRecordStatus
@parameters:        claimBatch Or ClaimBatchRecord Id
@return  :          Wrapper which will hold the values of all the variables.
Description:        This method will check if the record id which we are getting is of claim batch or claim batch record, based on Id, 
					it will method to check if it has any failed claim batch records
Added By: Vaishali  Accenture - 21-Dec-2020
Modified By:        Date:      Changes: 
**********************************************************************************************************/
    @AuraEnabled 
    public static claimBatchwrapper checkClaimBatchRecordStatus(Id claimBatchOrClaimBatchRecId){
        
        claimBatchwrapper wrapperInstance = new claimBatchwrapper();
        
        if(string.valueOf(claimBatchOrClaimBatchRecId).startsWith('a4O')){
            wrapperInstance = hasAnyClaimBatchRecordsInFailedStatus(claimBatchOrClaimBatchRecId);
        }
        else{
            wrapperInstance = isClaimBatchRecordInFailedStatus(claimBatchOrClaimBatchRecId);
        } 
        return wrapperInstance;
    }
    
    /*********************************************************************************************************
Method Name:        hasAnyClaimBatchRecordInFailedStatus
@parameters:        claim Batch Id
@return  :          Wrapper which will hold the values of all the variables.
Description:        This method will get list of all batch records associated with batch id and check if it 
					has any claim batch records in failed status.
Added By: Vaishali  Accenture - 21-Dec-2020
Modified By:        Date:      Changes: 
**********************************************************************************************************/
    
    public static claimBatchwrapper hasAnyClaimBatchRecordsInFailedStatus(Id claimBatchOrClaimBatchRecId){
        
        claimBatchwrapper wrapperInstance = new claimBatchwrapper();
        
        try{
            wrapperInstance.claimBatchRecList = [select id from Core_MDF_Claim_Batch_Stage__c where Core_MDF_Batch_ID__c =: claimBatchOrClaimBatchRecId 
                                                 and Core_MDF_Processing_Status_Nm__c='Failed'];        
            
            if(wrapperInstance.claimBatchRecList != Null && wrapperInstance.claimBatchRecList.size()>0){
                wrapperInstance.isClaimBatchRecStatusFailed = true;
            }
            
            return wrapperInstance;
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e); wrapperInstance.exceptionDetails= 'Exception: '+e.getMessage();return wrapperInstance;}
    }
    
    /*********************************************************************************************************
Method Name:        isClaimBatchRecordInFailedStatus
@parameters:        Claim batch record ID
@return  :          Wrapper which will hold the values of all the variables.
Description:        This method will check if claim batch record is in failed status.
Added By: Vaishali  Accenture - 21-Dec-2020
Modified By:        Date:      Changes: 
**********************************************************************************************************/    
    public static claimBatchwrapper isClaimBatchRecordInFailedStatus(Id claimBatchOrClaimBatchRecId){
        
        claimBatchwrapper wrapperInstance = new claimBatchwrapper();
        
        try{
            Core_MDF_Claim_Batch_Stage__c claimBatchRec = [Select id,Core_MDF_Processing_Status_Nm__c from Core_MDF_Claim_Batch_Stage__c where id=:claimBatchOrClaimBatchRecId 
                                                           AND Core_MDF_Processing_Status_Nm__c = 'Failed'];
            
            if(claimBatchRec != Null){
                wrapperInstance.isClaimBatchRecStatusFailed = true;
                wrapperInstance.claimBatchRecList.add(claimBatchRec);
            }
            return wrapperInstance;
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e); wrapperInstance.exceptionDetails= 'Exception: '+e.getMessage();return wrapperInstance;}
    }
    
    /*********************************************************************************************************
Method Name:        updateClaimBatchRecordStatus
@parameters:        List of claim batch records to be updated
@return  :          String
Description:        This method will update claim batch records status to Submitted
Added By: Vaishali  Accenture - 21-Dec-2020
Modified By:        Date:      Changes: 
**********************************************************************************************************/   
    
    @InvocableMethod
    public static void updateClaimBatchRecordStatus(List<Core_MDF_Claim_Batch_Stage__c> claimBatchRecListToBeUpdated){
       // try{
            if(claimBatchRecListToBeUpdated!=null && claimBatchRecListToBeUpdated.size()>0){
                for(Core_MDF_Claim_Batch_Stage__c claimBatChRec : claimBatchRecListToBeUpdated){
                    claimBatChRec.Core_MDF_Processing_Status_Nm__c ='Submitted';
                }
                Database.update(claimBatchRecListToBeUpdated);
            }
            //return null;
        //}        
        //catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e); return 'Exception: '+e.getMessage();}  
    }
}