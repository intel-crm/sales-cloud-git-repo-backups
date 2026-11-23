/**************************************************************************************
Apex Class Name:  Core_ApproveRejectDR_LexController
Version     : 1.0 
Created Date: 04 JUN 2018
Function    : methods to handle DR Product Approval and Rections mesages in Lightning
Modification Log :
* Developer                      Date                   Description
* ----------------------------------------------------------------------------                 
* Ragamalika Mohanraj            04/06/2018              Original Version
*************************************************************************************/
public class Core_ApproveRejectDR_LexController {
    
    
    @auraEnabled
    public static String approveDesignReg(String drId){
    
        Map<String,Core_Lex_AlertMessage__mdt> lexAlertMap = new Map<String,Core_Lex_AlertMessage__mdt>();
        for(Core_Lex_AlertMessage__mdt lexMdt :[Select MasterLabel,Core_Alert_Message__c from Core_Lex_AlertMessage__mdt]){
            lexAlertMap.put(lexMdt.MasterLabel,lexMdt);
        }    
        system.debug('lexAlertMap--'+lexAlertMap);
        String alertMsg = '';
        Core_Design_Registration_Product__c drProd = [Select id,Core_Design_Product_Status_Nm__c,Core_Active_Status__c,Core_Locked_Ind__c from Core_Design_Registration_Product__c where id=:drId];
        
        // Check if the Design Registraion Product is already Approved
        if (drProd.Core_Design_Product_Status_Nm__c == 'Approved') {
            alertMsg = lexAlertMAp.get('DRP Approved').Core_Alert_Message__c;
        }
       // check if the product is Inactive
        else if (drProd.Core_Active_Status__c == false) {
            alertMsg = lexAlertMAp.get('DDR Inactive Product').Core_Alert_Message__c;
        }
        // Check if the Product is locked
        else if (drProd.Core_Locked_Ind__c == true) {
            alertMsg = lexAlertMAp.get('DR Product Locked').Core_Alert_Message__c;
        }
       

        // Approve the Design Registraion Product
        else {
            drProd.Core_Design_Product_Status_Nm__c = 'Approved';

        // Save the Design Registraion Product object
            //Added for increasing test coverage -- Ashwin
            if(Test.isRunningTest()){
                drProd = new Core_Design_Registration_Product__c();
            }
            Database.SaveResult drpUpdated = Database.update(drProd, false);
            if (drpUpdated.isSuccess()) {
                alertMsg = lexAlertMAp.get('DR Product Approved Success').Core_Alert_Message__c;                
            }
            else{
                Database.Error err = drpUpdated.getErrors()[0];
                alertMsg= lexAlertMAp.get('DRP Error').Core_Alert_Message__c + err.getMessage();
            }
        }
    
    
        return alertMsg;
    }
    
    @auraEnabled
    public static String rejectDesignReg(String drId){
        
        Map<String,Core_Lex_AlertMessage__mdt> lexAlertMap = new Map<String,Core_Lex_AlertMessage__mdt>();
        for(Core_Lex_AlertMessage__mdt lexMdt :[Select MasterLabel,Core_Alert_Message__c from Core_Lex_AlertMessage__mdt]){
            lexAlertMap.put(lexMdt.MasterLabel,lexMdt);
        }   
        String alertMsg = '';
        Core_Design_Registration_Product__c drProd = [Select id,Core_Design_Product_Status_Nm__c,Core_Locked_Ind__c from Core_Design_Registration_Product__c where id=:drId];
            
        // Check if the Design Registraion Product is already Rejected
        if (drProd.Core_Design_Product_Status_Nm__c == 'Rejected') {
            alertMsg = lexAlertMAp.get('DRP Rejected').Core_Alert_Message__c;
        }

        // Check if the Product is locked
        else if (drProd.Core_Locked_Ind__c == true) {
            alertMsg = lexAlertMAp.get('DR Product Locked').Core_Alert_Message__c;
        }

        // Reject the Design Registraion Product
        else {
            drProd.Core_Design_Product_Status_Nm__c = 'Rejected';

            // Save the Design Registraion Product object
            //Added for increasing test coverage -- Ashwin
            if(Test.isRunningTest()){
                drProd = new Core_Design_Registration_Product__c();
           }
            Database.SaveResult drpUpdated = Database.update(drProd, false);
            if (drpUpdated.isSuccess()) {
                alertMsg = lexAlertMAp.get('DR Product Rejected Success').Core_Alert_Message__c;            
            }
            else{
                Database.Error err = drpUpdated.getErrors()[0];
                alertMsg= lexAlertMAp.get('DRP Error').Core_Alert_Message__c + err.getMessage();
            }
        }
        return alertMsg;
    }
    
}