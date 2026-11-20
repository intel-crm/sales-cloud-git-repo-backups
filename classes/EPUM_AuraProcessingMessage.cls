/******************************************************************************************************
* Class Name  : Core_EPUM_AuraProcessingMessage 
* Version     : 1.0 
* Created Date: 04-13-2020
* Modification Log :
* Developer  Hemavathi        
* Date   04/13/2020
* Description : This class is used for displaying AuraProcessingMessages
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
public class EPUM_AuraProcessingMessage {
        
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String errorMsg; //error msg
        @AuraEnabled public String successMsg; //success msg
        
        public EPUM_AuraProcessingMessage(){
            isSuccess = true;
            errorMsg = '';
            successMsg = '';
        }
}