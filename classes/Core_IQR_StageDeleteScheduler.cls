/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_PSG_UpdateSignalCodeFromStaging
Version     : 1.0 
Created Date: 07 Sept 2021
Function    : CLass to call a Batch which updates Signal Code from PSG Staging table to Product Table
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya Dayananda             07 Sept 2021            Original Version

*****************************************************************************************************************************************************************************************************/
public class Core_IQR_StageDeleteScheduler {
    
    @InvocableMethod
    public static void stageDeleteScheduler() { 
        try{          
        	Database.executeBatch(new Core_IQR_StageDelete());         
        }
        catch(exception e){
        	system.debug('**exception** -->'+ e);
        }
    }

}