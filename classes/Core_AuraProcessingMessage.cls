/******************************************************************************************************
* Class Name  : Core_AuraProcessingMessage 
* Version     : 1.0 
* Created Date: 05-08-2019
* Modification Log :
* Developer  Sandip Ghosh          
* Date   05/08/2019
* Description : This class is used for returning error message/ success message
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
public class Core_AuraProcessingMessage {
        
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String errorMsg; //error msg
        @AuraEnabled public String successMsg; //success msg
        
        public Core_AuraProcessingMessage(){
            isSuccess = true;
            errorMsg = '';
            successMsg = '';
        }
}