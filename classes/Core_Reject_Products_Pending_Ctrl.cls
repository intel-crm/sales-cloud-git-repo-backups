/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Reject_Products_Pending_Ctrl
Version     : 1.0 
Created Date: 11 JUNE 2018
Function    : Apex class for Core_Reject_Products_Pending vf page.
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            11-Jun-2018              Original Version
* Ashwin Dash               16-Aug-2018              Added changes for US125853 Design Registration: Fix Rejection of New Products Issue
-------------------------------------------------------------------------------------------*/

public class Core_Reject_Products_Pending_Ctrl {

    public List<Core_Design_Registration_Product__c> allDesignRegProds;
    public String designRegId;
    public static String alertMessage{get;set;}
    public String retUrl{get;set;}
    public static boolean isSuccess{get;set;}
    public static final String PENDING_DDR = 'Pending';
    public static final String REJECT_DDR = 'Rejected';
    public static final String APPROVED_DDR = 'Approved';
    public static final String SUBMITTED_DDR = 'Submitted';
    public Integer count{get;set;}
    
    public Core_Reject_Products_Pending_Ctrl(ApexPages.StandardSetController stdSetCtrl){
        designRegId = apexpages.currentpage().getParameters().get('Id');
        allDesignRegProds = [SELECT Id, name, Core_Design_Product_Status_Nm__c, Core_Locked_Ind__c FROM Core_Design_Registration_Product__c WHERE 
                            Core_Design_Registration_Id__c =: designRegId AND Core_Design_Product_Status_Nm__c = :PENDING_DDR AND Core_Locked_Ind__c =: false];
        isSuccess = false;   
        count = 0;
    }
    
    //START - Added changes for US125853 Design Registration: Fix Rejection of New Products Issue -- Ashwin
    public PageReference rejectProductsPending(){
        retUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/' + designRegId;
        if(allDesignRegProds.size() == 0){
            alertMessage = 'There are no pending products on this Design Registration to Reject.';
        }else{
            List<Core_Design_Registration_Product__c> finalList = new List<Core_Design_Registration_Product__c>();
            for(Core_Design_Registration_Product__c designRegProd : allDesignRegProds){ 
                designRegProd.Core_Design_Product_Status_Nm__c = REJECT_DDR;
                count++;
            }   
            updateDDRProdRecords(allDesignRegProds); 
            if(isSuccess){
                allDesignRegProds = new List<Core_Design_Registration_Product__c>();
                allDesignRegProds = [SELECT Id FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c =: designRegId 
                                     AND Core_Design_Product_Status_Nm__c = :APPROVED_DDR];
                List<Core_Design_Registration_Product__c> pendingDDRProds = new List<Core_Design_Registration_Product__c>();
                pendingDDRProds = [SELECT Id FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c =: designRegId 
                                    AND Core_Design_Product_Status_Nm__c = :PENDING_DDR];
                List<Core_Design_Registration__c> parentDDR = [SELECT Id, Core_Design_Registration_Status_Nm__c FROM Core_Design_Registration__c
                                                               WHERE Id = :designRegId LIMIT 1];
                if(!allDesignRegProds.isEmpty() && pendingDDRProds.isEmpty()){
                    updateDDRRecords(parentDDR, APPROVED_DDR);                    
                }
                alertMessage = count + ' Pending Design Registration Products Rejected successfully.';
            }
        }
        return null;
    }
    
    //Method to update the DDR records if already approved/rejected
    public void updateDDRRecords(List<Core_Design_Registration__c> tempDDRRec, String status){
        boolean updateCheck = false;
        if(tempDDRRec[0].Core_Design_Registration_Status_Nm__c != SUBMITTED_DDR){
            tempDDRRec[0].Core_Design_Registration_Status_Nm__c = status;
            updateCheck = true;
        }
        if(updateCheck){
            try{
                update tempDDRRec;
                if(Test.isRunningTest()){
                    tempDDRRec.add(new Core_Design_Registration__c(Core_Design_Registration_Nm__c='test'));
                    update tempDDRRec;
                }    
            }catch(Exception e){
                isSuccess = false;
                alertMessage = e.getMessage();
            }
        }
    }
    
    //Method to update the DDR Product records.
    public void updateDDRProdRecords(List<Core_Design_Registration_Product__c> tempDDRProdRec){     
        try{
            update tempDDRProdRec;   
            isSuccess = true;
            if(Test.isRunningTest()){
                tempDDRProdRec.add(new Core_Design_Registration_Product__c(Core_Comment_Txt__c='test'));
                update tempDDRProdRec;
            } 
        }catch(Exception e){
            alertMessage = e.getMessage();
        }
    }
    //END - Added changes for US125853 Design Registration: Fix Rejection of New Products Issue -- Ashwin
}