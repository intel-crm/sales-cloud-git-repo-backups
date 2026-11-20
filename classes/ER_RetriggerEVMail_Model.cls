/**************************************************************************************************************
Apex Class Name:  ER_RetriggerEVMail_Model
Version     : 1.0 
Created Date: 08 March 2022
Function    : Model class for EV Retrigger
Modification Log :
* Developer             		Date              Description
* ----------------------------------------------------------------------------                 
* Manjunatha Hegde	         03/08/2022      	Initial version
***************************************************************************************************************/
global class ER_RetriggerEVMail_Model {
    
    public class ER_RetriggerEVMail_Input{
        public String LoginID{get;set;}
        public String Email{get;set;}
        public Boolean IsProgramBased{get;set;}
        public String Name{get;set;}
    }
    
    global class ER_RetriggerEV_Response{
        public String Message{get;set;}    
        public Boolean IsSuccess{get;set;}
        public Integer StatusCode{get;set;}
    }
    
}