/****************************************************************************************************
    Apex Class Name : Core_DDR_Product_Handler
    Version         : 1.0 
    Created Date    : 09/21/2017
    Function        : Handler class for the trigger 'Core_DDR_Product_Trigger'
    Modifications   :
    *****************************************************************************************************
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Rajadinakaran             09/21/2017             Created
    *  Mahesh                    6/28/2019             US381642:DDR : DR enhancements
*****************************************************************************************************/
public Class Core_DDR_Product_Handler
{
    /*****
        Shortforms used:
        DR - Design Registration
        DRLI - Design Registration Line Item (DR Product)
    *****/    
    public static string DR_LI_STATUS_PENDING = 'Pending';
    
    public static string DR_STATUS_APPROVED = 'Approved';
    public static string DR_STATUS_REJECTED = 'Rejected';
    public static string DR_STATUS_RESUBMITTED = 'Re-Submitted';
    
    public static string PriceBookName = 'Partner Price Book';
    
    public static void processBeforeInsert(List<Core_Design_Registration_Product__c> oldList, List<Core_Design_Registration_Product__c> newList, 
    Map<Id,Core_Design_Registration_Product__c> oldMap, Map<Id,Core_Design_Registration_Product__c> newMap)
    {
        TargetResalePriceUpdate((List<Core_Design_Registration_Product__c>) newList);
    }
    
    public static void processAfterInsert(List<Core_Design_Registration_Product__c> oldList, List<Core_Design_Registration_Product__c> newList, 
    Map<Id,Core_Design_Registration_Product__c> oldMap, Map<Id,Core_Design_Registration_Product__c> newMap)
    {
        try
        {
            Set<Id> setDRIds = new Set<Id>(); 
            List<Core_Design_Registration__c> lstDRs = new List<Core_Design_Registration__c>();
            List<Core_Design_Registration__c> lstUpdateDRs = new List<Core_Design_Registration__c>();
            List<Core_Design_Registration__c> lstUpdateDRsRejected = new List<Core_Design_Registration__c>();
            
            for(Core_Design_Registration_Product__c iDRLI : newList)
            {
                if(iDRLI.Core_Design_Product_Status_Nm__c == DR_LI_STATUS_PENDING)
                {
                    setDRIds.add(iDRLI.Core_Design_Registration_Id__c);
                }   
            } 
            
            lstDRs = [SELECT Id, Core_Design_Registration_Status_Nm__c FROM Core_Design_Registration__c WHERE Id IN: setDRIds];
            
            // erase rejection reason and comments when resubmitting the DR
            for(Core_Design_Registration__c iDR : lstDRs)
            {
                if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED)
                {
                    iDR.Core_Design_Registration_Status_Nm__c = DR_STATUS_RESUBMITTED;
                    iDR.Core_Rejection_Reason_Nm__c = '';
                    iDR.Core_Rejection_Comment_Txt__c = '';
                    iDR.Core_Approver_Grp_Notification_Sent_Ind__c = FALSE;
                    
                    lstUpdateDRs.add(iDR);
                }
                else if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_REJECTED){
                    iDR.Core_Design_Registration_Status_Nm__c = DR_STATUS_RESUBMITTED;
                    //STARTS-US381642:DDR : DR enhancements
                    // iDR.Core_Rejection_Reason_Nm__c = '';
                    //iDR.Core_Rejection_Comment_Txt__c = '';
                    // ENDS-US381642:DDR : DR enhancements
                    iDR.Core_Approver_Grp_Notification_Sent_Ind__c = FALSE;
                    
                    lstUpdateDRsRejected.add(iDR);
                }
            }
            
            if(lstUpdateDRs.size() > 0)
            {
                //Approval.unlock(lstUpdateDRs, true);
                
                update lstUpdateDRs;
                
                //Approval.lock(lstUpdateDRs, true); 
            }
            else if(lstUpdateDRsRejected.size() > 0){
                //Approval.unLock(lstUpdateDRsRejected, true);
                
                update lstUpdateDRsRejected;
            }
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            system.debug('processAfterInsert->'+myMsg);  
        }        
    }
    
    public static void processBeforeUpdate(List<Core_Design_Registration_Product__c> oldList, List<Core_Design_Registration_Product__c> newList, 
    Map<Id,Core_Design_Registration_Product__c> oldMap, Map<Id,Core_Design_Registration_Product__c> newMap)
    {
        TargetResalePriceUpdate((List<Core_Design_Registration_Product__c>) newList);
    }
    
    public static void TargetResalePriceUpdate(List<Core_Design_Registration_Product__c> newUpdateList){
        Set<id> SetProductId = new Set<id>();
        
        for(Core_Design_Registration_Product__c iDRLI : newUpdateList)
        {
            SetProductId.add(iDRLI.Core_Product_Id__c);
        }
        
        List<PriceBookEntry> PriceBookEntryListPrice = [SELECT id, name, Pricebook2.name, product2id, unitprice FROM PriceBookEntry WHERE product2id IN:SetProductId AND Pricebook2.name =: PriceBookName];
        
        Map<id, Decimal> ListPriceMap = new Map<id, Decimal>();
        
        for(PriceBookEntry ListPrice: PriceBookEntryListPrice){
            ListPriceMap.put(ListPrice.product2id, ListPrice.unitprice);
        }
        
        for(Core_Design_Registration_Product__c iDRLI : newUpdateList)
        {
            iDRLI.Core_Target_Resale_Amt__c = (iDRLI.Core_Target_Resale_Amt__c == null ? (ListPriceMap.get(iDRLI.Core_Product_Id__c) == null ? 0 : ListPriceMap.get(iDRLI.Core_Product_Id__c)) : iDRLI.Core_Target_Resale_Amt__c);
            iDRLI.Core_Product_List_Price_Amt__c = (ListPriceMap.get(iDRLI.Core_Product_Id__c) == null ? 0 : ListPriceMap.get(iDRLI.Core_Product_Id__c));
        }
    }
}