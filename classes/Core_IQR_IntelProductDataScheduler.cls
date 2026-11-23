/********************************************************************************************************************************************************************
Apex Class Name:  Core_IQR_StageDelete
Version     : 1.0 
Created Date: 25/01/2022
Function    : Batch class to initiate deletion of IQR STaging records which were created older than days provided in custom label from today

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya Dayananda              25/01/2022              
*******************************************************************************************************************************************************************/
public class Core_IQR_IntelProductDataScheduler {
	@InvocableMethod
    public static void Core_IQR_IntelProductDataScheduler() {  
        
    	try{          
        	Database.executeBatch(new Core_IQR_IntelProductData());  
            
        }
        catch(exception e){
        	system.debug('**exception** -->'+ e);
        }
    }
}