/****************************************************************************************************
    Apex Class Name : Core_DDR_Cancel_Product_Controller
    Version         : 1.0 
    Created Date    : 09/28/2017
    Function        : Used to cancel a single DR Product(Unlock the product & Lock again)
    VF Page         : Core_DDR_Cancel_Product
    Modifications   :
    *****************************************************************************************************
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Rajadinakaran             09/28/2017             Created
*****************************************************************************************************/

public Class Core_DDR_Cancel_Product_Controller
{
    /******
        ShortForms Used:
        ----------------
        DR - Design Registration
        OLI/ OppLI - Opportunity Line Item
    ******/
    public string callAlertFunc{get;set;}
    
    public Core_DDR_Cancel_Product_Controller(ApexPages.StandardController controller) 
    {
        
    }
    
    public PageReference cancelDDRProduct() 
    {
        try
        {
            List<Core_Design_Registration_Product__c> lstDDRProducts = new List<Core_Design_Registration_Product__c>();
            List<OpportunityLineItem> lstOppLI = new List<OpportunityLineItem>();
            
            Set<Id> setDDRProdId = new Set<Id>();
            
            //Getting the current page ID to cancel the cuurent DR Product
            Id DDRProdId = ApexPages.currentPage().getParameters().get('id');
            
            setDDRProdId.add(DDRProdId);
            
            lstDDRProducts = [SELECT id, Core_Design_Product_Status_Nm__c FROM Core_Design_Registration_Product__c WHERE ID IN: setDDRProdId LIMIT 1];
            
            //Unlocking the record to update the status
            Approval.unlock(lstDDRProducts, true);   
            
            for(Core_Design_Registration_Product__c iDRLI : lstDDRProducts)
            {
                if(iDRLI.Core_Design_Product_Status_Nm__c == 'Cancelled'){
                    callAlertFunc='<script> alreadyCancelled() </script>';
                    return null;
                }
                else{
                    iDRLI.Core_Design_Product_Status_Nm__c = 'Cancelled';
                }
            }
            
            //update the cancelled record
            update lstDDRProducts;
            
            //Locking the DR Product record after cancelled.
            Approval.lock(lstDDRProducts, true);
            
            lstOppLI = [SELECT Id, Name, Core_Design_Registration_Product_Id__c, Core_Status__c FROM OpportunityLineItem WHERE Core_Design_Registration_Product_Id__c =: setDDRProdId];
            
            if(lstOppLI.size() > 0)
            {
                for(OpportunityLineItem iOLI : lstOppLI)
                {
                    iOLI.Core_Status__c = 'Cancelled'  ;
                    iOLI.Core_Loss_Cancel_Reason__c = 'Cancelled - Duplicate';
                }
                
                //update(Cancel) the opportunity line related to the DR line item
                update lstOppLI;
            }  
            
            callAlertFunc='<script> succuessCancelled() </script>';
            return null;            
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);  
            
            return null;
        }
    }
}