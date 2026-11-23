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
    * Ashwin Dash               16-Aug-2018            Added changes for US125853 Design Registration: Fix Cancellation of products
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
    public static final String APPROVED_DDR = 'Approved';
    public static final String SUBMITTED_DDR = 'Submitted';

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
            Set<Id> setDDRId = new Set<Id>();//Added changes for US125853 Design Registration: Fix Cancellation of products
            
            //Getting the current page ID to cancel the cuurent DR Product
            Id DDRProdId = ApexPages.currentPage().getParameters().get('id');
            
            setDDRProdId.add(DDRProdId);
            //Added changes for US125853 Design Registration: Fix Cancellation of products
            lstDDRProducts = [SELECT id, Core_Design_Product_Status_Nm__c, Core_Design_Registration_Id__c FROM Core_Design_Registration_Product__c WHERE ID IN: setDDRProdId LIMIT 1];
            
               
            
            for(Core_Design_Registration_Product__c iDRLI : lstDDRProducts)
            {   
                setDDRId.add(iDRLI.Core_Design_Registration_Id__c);//Added changes for US125853 Design Registration: Fix Cancellation of products
                if(iDRLI.Core_Design_Product_Status_Nm__c == 'Cancelled'){
                    callAlertFunc='<script> alreadyCancelled() </script>';
                    return null;
                }
                else{
                    iDRLI.Core_Design_Product_Status_Nm__c = 'Cancelled';
                    iDRLI.Core_Locked_Ind__c = true;
                    
                    //Added by Raj on 02/20 for record type
                    iDRLI.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID; 
                }
            }
            
            //START - Added changes for US125853 Design Registration: Fix Cancellation of products
            Id canceldProdId = lstDDRProducts[0].id;
            List<Core_Design_Registration_Product__c> lstDDRProds = new List<Core_Design_Registration_Product__c>();
            List<Core_Design_Registration__c> parentDDRrec = new List<Core_Design_Registration__c>();
            lstDDRProds = [SELECT id, Core_Design_Product_Status_Nm__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c IN: setDDRId AND Id != :canceldProdId];
            parentDDRrec = [SELECT id, Core_Design_Registration_Status_Nm__c FROM Core_Design_Registration__c WHERE Id IN :setDDRId LIMIT 1];
            for(Core_Design_Registration_Product__c ddrp : lstDDRProds){
                if(ddrp.Core_Design_Product_Status_Nm__c == APPROVED_DDR && parentDDRrec[0].Core_Design_Registration_Status_Nm__c != SUBMITTED_DDR){
                    parentDDRrec[0].Core_Design_Registration_Status_Nm__c = APPROVED_DDR;
                }
            }           
            //END - Added changes for US125853 Design Registration: Fix Cancellation of products
            
            //Unlocking the record to update the status
            //Approval.unlock(lstDDRProducts, true);
            
            //update the cancelled record
            update lstDDRProducts;
            
            //Locking the DR Product record after cancelled.
            //Approval.lock(lstDDRProducts, true);
            
            lstOppLI = [SELECT Id, Name, Core_Design_Registration_Product_Id__c, Core_Status__c FROM OpportunityLineItem WHERE Core_Design_Registration_Product_Id__c =: setDDRProdId];
            
            if(lstOppLI.size() > 0)
            {
                for(OpportunityLineItem iOLI : lstOppLI)
                {
                    if(iOLI.Core_Status__c == 'Production Win'){
                        iOLI.Core_Status__c = 'Production Cancelled'; 
                    }
                    else{
                        iOLI.Core_Status__c = 'Cancelled'  ;
                    }
                    iOLI.Core_Loss_Cancel_Reason__c = 'Cancelled - Design Reg. Product Swap';
                }               
                //update(Cancel) the opportunity line related to the DR line item
                update lstOppLI;
            }
            callAlertFunc='<script> succuessCancelled() </script>';
            update parentDDRrec;//Added changes for US125853 Design Registration: Fix Cancellation of products
            return null;            
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            System.debug('myMsg=>'+myMsg);          
            return null;
        }
    }
}