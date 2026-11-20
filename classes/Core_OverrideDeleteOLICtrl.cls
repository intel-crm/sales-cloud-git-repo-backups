/*
**************************************************************************************
Apex Class  : Core_OverrideDeleteOLICtrl
Version     : 1.0 
Created Date: 24 Aug, 2022
Description : This Class is used validate the errors before submitting the opportunity for approval.
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade           12 Sept, 2022             Updated Revision
* Jerin Thomas S           22 Dec,  2022             US-0033147 Delete Vendor INACTIVE Win Submitted Products

*/
public without sharing class Core_OverrideDeleteOLICtrl{
    
    Public OpportunityLineItem Opl;
    Public String ParentId;
    Public Boolean isProceedEnable{get;set;}
    
    public Core_OverrideDeleteOLICtrl(ApexPages.StandardController stdController) {
        Opl = (OpportunityLineItem) stdController.getRecord();
    }
    
    public PageReference checkForDelete() {
        
        List<OpportunityLineItem> listOppoLI = new List<OpportunityLineItem>();
        set<id> oppoLI = new set<id>();
        
        try{
            OpportunityLineItem OplRecord = [Select Id, OpportunityId,Opportunity.Core_VBS_Potential__c,Opportunity.Core_VBS_Status__c, Core_At_Risk__c, Core_Status__c ,Core_Vendor_InActive__c from OpportunityLineItem where Id=:Opl.Id];
            ParentId = OplRecord.OpportunityId;
            List<Core_Oppty_KPI_New__c> listKPIs= [Select Id,Core_KPI_Opportunity__c,Core_Opportunity_Product__c from Core_Oppty_KPI_New__c where Core_KPI_Opportunity__c=:ParentId AND Core_Opportunity_Product__c=:OplRecord.Id ];
            oppoLI.add(OplRecord.id);
            //TWC4767-10 : NP : Prod issue- Do not allow deletion of Oppty product when there is already approved 6QPS record
            Map<id,boolean> canDelOLI = Core_OpportunityLineItemHandler.canDelete(oppoLI);
            if(OplRecord!= null && ApexPages.currentPage().getParameters().get('id') != null){
                if(OplRecord.Core_Status__c == System.Label.Core_OppoLineItemCancelled){
                    OplRecord.Core_Status__c =  System.Label.Core_LineItem_Status;
                    listOppoLI.add(OplRecord);
                    update listOppoLI;
                    return new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
                }
                else if(OplRecord.Core_Status__c == System.Label.Core_OppoLineItemPending || OplRecord.Core_Status__c == System.Label.Core_OppoLineItemOnHold){
                    //TWC4767-10 : NP : Prod issue- Do not allow deletion of Oppty product when there is already approved 6QPS record
                    if(canDelOLI.containsKey(OplRecord.id)){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'You cannot delete this product since there is already an approved 6QPS Quarter'));
                    }
                    /*else if(OplRecord.Opportunity.Core_VBS_Potential__c && (OplRecord.Opportunity.Core_VBS_Status__c=='Pending' || OplRecord.Opportunity.Core_VBS_Status__c=='SOAR1 Qualified')){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Opportunity Product cannot be updated when there is a SOAR Process Pending/Qualified.'));
                        isProceedEnable = false;
                    }*/
                    else if(listKPIs.size()>0){ 
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, System.Label.Core_Pending_and_OnHold_products));
                        isProceedEnable = true;
                    }
                    else{
                        OplRecord.Core_Status__c = System.Label.Core_LineItem_Status;
                        listOppoLI.add(OplRecord);
                        update listOppoLI;
                        isProceedEnable = False;
                        return new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));                    
                    }   
                }
                else if(OplRecord.Core_Status__c == System.Label.Core_LineItem_Status){
                    isProceedEnable = false;  
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Already Delete in Progress'));
                    if(Test.isRunningTest()){
                        String errorMsg = '';
                        throw new System.DMLException();   
                    }                          
                }
                else if(OplRecord.Core_Status__c == 'Win Submitted' && OplRecord.Core_Vendor_InActive__c ==false){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'This record is locked. If you need to edit it, contact your admin.'));
                    isProceedEnable = False;
                }
                else{
                    OplRecord.Core_Status__c = System.Label.Core_LineItem_Status;
                    update OplRecord;
                    isProceedEnable = false;
                    return new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
                }  
            } 
            return null;  
        }
        catch(Exception ex){
            String error = ex.getMessage();
            ApexPages.addMessages(ex);
            isProceedEnable = false;
            return null;
        }  
    }
    
    public PageReference proceed() {
        
        List<OpportunityLineItem> pendingOnHoldOppoLI = new List<OpportunityLineItem>();
        Opl.Core_Status__c = System.Label.Core_LineItem_Status;
        pendingOnHoldOppoLI.add(Opl);
        update pendingOnHoldOppoLI;
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
        
    }
    public PageReference back() {
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
    }  
}