/*-------------------------------------------------------------------------------------------
Apex Class  : Core_DR_Zero_Quantity_msg_Ctrl
Version     : 1.0 
Created Date:   10 Oct 2020
Function    : To show the warning message for zero quantity DR products
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda           10/10/2020             Original version
--------------------------------------------------------------------------------------------*/

public class Core_DR_Zero_Quantity_msg_Ctrl {
    Core_Design_Registration__c currentRecord;
    public Boolean isZeroQuantityProducts {get; set;}
    
    public Core_DR_Zero_Quantity_msg_Ctrl(ApexPages.StandardController controller){
        this.currentRecord = (Core_Design_Registration__c)controller.getRecord();
        system.debug('currentRecord'+currentRecord.id);
        List<Core_Design_Registration_Product__c> ZeroQuntyLst=[Select id from Core_Design_Registration_Product__c where Core_Design_Registration_Id__c =:currentRecord.Id AND Core_Full_Year_Qty__c = 0];
        
        if(ZeroQuntyLst.size() > 0){
            isZeroQuantityProducts=true;
        }
        else{
            isZeroQuantityProducts=false;
        }
        
    }
    
    @auraEnabled
    public static boolean ValidateZeroProducts(Id DRRecordId){
        
        List<Core_Design_Registration_Product__c> ZeroQuntyLst=[Select id from Core_Design_Registration_Product__c where Core_Design_Registration_Id__c =:DRRecordId AND Core_Full_Year_Qty__c = 0];
        
        if(ZeroQuntyLst.size() > 0){
            return true;
        }
        else{
           return false;
        }
        
    }
    
}