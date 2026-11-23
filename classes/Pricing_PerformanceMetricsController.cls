/**
 * @description       : Class for Performance Metrics Aura Component
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 02-06-2024
 * @last modified by  : Sandeep Chamate
**/
public without sharing class Pricing_PerformanceMetricsController {
    
    //This method takes list of Pricing_Performance_Metric__c that need to be saved and the Pricing_Quote_Line__c Id 
    //to create new records with the data
    @AuraEnabled
    public static boolean savePerformanceMetrics(List<Pricing_Performance_Metric__c> inprec, Id quoteLineId){
        try{
            List<Pricing_Performance_Metric__c> perfMetricsToUpdate = new List<Pricing_Performance_Metric__c>();
            List<Pricing_Performance_Metric__c> perfMetricsToInsert = new List<Pricing_Performance_Metric__c>();
            if(inprec.size()>0 && inprec != null){
                boolean returnSavePM = savePMListCreation(inprec,perfMetricsToUpdate,perfMetricsToInsert,quoteLineId);
                if(!returnSavePM){
                    return false;
                }
                if(!perfMetricsToUpdate.isEmpty())
                {
                    //update perfMetricsToUpdate
                    Pricing_DatabaseOperation.performUpdate(perfMetricsToUpdate,true,false);
                }
                if(!perfMetricsToInsert.isEmpty())
                {
                    //insert perfMetricsToInsert;
                    Pricing_DatabaseOperation.performInsert(perfMetricsToInsert,true,false);
                }
                return true;
            }else{
                return false;
            }
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
            return false;
        }
    }

    public static boolean savePMListCreation(List<Pricing_Performance_Metric__c> inprec,List<Pricing_Performance_Metric__c> perfMetricsToUpdate,List<Pricing_Performance_Metric__c> perfMetricsToInsert,Id quoteLineId){
        for (Pricing_Performance_Metric__c objPM: inprec) {
            if(objPM.Pricing_Comp_SKU_Performance_Nbr__c <= 0 || objPM.Pricing_Intel_SKU_Performance_Nbr__c <= 0){
                return false;
            }
            if (String.isNotBlank(objPM.Id) && objPM.Id != null) {
                perfMetricsToUpdate.add(objPM);
            }
            else{
                Pricing_Performance_Metric__c obj = new Pricing_Performance_Metric__c();
                obj.Pricing_Quote_Line__c = quoteLineId;
                obj.Pricing_Performance_Metric_Nm__c = objPM.Pricing_Performance_Metric_Nm__c;
                obj.Pricing_Weighting_Pct__c = objPM.Pricing_Weighting_Pct__c;
                obj.Pricing_Comp_SKU_Performance_Nbr__c = objPM.Pricing_Comp_SKU_Performance_Nbr__c;
                obj.Pricing_Intel_SKU_Performance_Nbr__c = objPM.Pricing_Intel_SKU_Performance_Nbr__c;
                obj.Pricing_Other_Nm__c = objPM.Pricing_Other_Nm__c;
                perfMetricsToInsert.add(obj);
            }
        }
        return true;
    }
    //This method takes Pricing_Quote_Line__c record Id as input and returns list of Pricing_Performance_Metric__c
    //records available under that Pricing_Quote_Line__c
    @AuraEnabled
    public static List<Pricing_Performance_Metric__c> getPerformanceMetrics(Id recordId) {
        /*List<Pricing_Performance_Metric__c> returningList = new List<Pricing_Performance_Metric__c>();
        try{
            List<Pricing_Performance_Metric__c> pmlist= [SELECT Id,Pricing_Performance_Metric_Nm__c, Pricing_Weighting_Pct__c, Pricing_Intel_SKU_Performance_Nbr__c ,
                                                         Pricing_Comp_SKU_Performance_Nbr__c, Pricing_Other_Nm__c,Pricing_Quote_Line__r.RecordType.Name
                                                         FROM Pricing_Performance_Metric__c WHERE Pricing_Quote_Line__c = :recordId order by Id];
            
            if(pmlist.size()>0){
                for(Pricing_Performance_Metric__c pm: pmlist){
                    Pricing_Performance_Metric__c pmObj = new Pricing_Performance_Metric__c();
                    pmObj.Id = pm.Id;
                    pmObj.Pricing_Performance_Metric_Nm__c = pm.Pricing_Performance_Metric_Nm__c;
                    pmObj.Pricing_Weighting_Pct__c = pm.Pricing_Weighting_Pct__c;
                    pmObj.Pricing_Intel_SKU_Performance_Nbr__c = pm.Pricing_Intel_SKU_Performance_Nbr__c.setScale(2);
                    pmObj.Pricing_Comp_SKU_Performance_Nbr__c = pm.Pricing_Comp_SKU_Performance_Nbr__c.setScale(2);
                    pmObj.Pricing_Other_Nm__c = pm.Pricing_Other_Nm__c;
                    //pmObj.Pricing_Quote_Line__r.RecordType.Name = pm.Pricing_Quote_Line__r.RecordType.Name;
                    returningList.add(pmObj);
                }
                return returningList;  
            }else{
                return returningList;
            }
        }catch(Exception ex){
            system.debug('error--> '+ex.getStackTraceString());
            return returningList;
        }*/
        return [SELECT Id,Pricing_Performance_Metric_Nm__c, Pricing_Weighting_Pct__c, Pricing_Intel_SKU_Performance_Nbr__c ,
                Pricing_Comp_SKU_Performance_Nbr__c, Pricing_Other_Nm__c,Pricing_Quote_Line__r.RecordType.Name
                FROM Pricing_Performance_Metric__c WHERE Pricing_Quote_Line__c = :recordId order by Id];    
    }
    //This method takes QuoteLine record Id as input and returns True if the page layout is ReadOnly
    //Else it returns false
    @AuraEnabled
    public static Boolean isReadOnlyPageLayout(Id recordId){
        Map < ID, Schema.RecordTypeInfo > rtMap = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosById();
        SBQQ__QuoteLine__c  quoteLine = [SELECT Pricing_Status_Nm__c,Pricing_Integration_Status_Nm__c,Pricing_Deal_RFQ_Status_Nm__c,RecordTypeId,SBQQ__Quote__r.Pricing_On_Hold_Cb__c FROM SBQQ__QuoteLine__c 
                                         WHERE Id = :recordId];
        String quoteLineStatus = quoteLine.Pricing_Status_Nm__c;
        Boolean isPartnerUser = false;
        
        List<PermissionSetAssignment> lstcurrentUserPerSet =new List<PermissionSetAssignment>([SELECT Id, PermissionSet.Name, AssigneeId
                                                                                               FROM PermissionSetAssignment
                                                                                               WHERE AssigneeId = :Userinfo.getUserId()]);
        // STORE CURRENT USER'S PERMISSION SETS IN A LIST
        List<String> lstPermissionSets = new List<String>();
        for (PermissionSetAssignment psa : lstcurrentUserPerSet) {
            lstPermissionSets.add(psa.PermissionSet.Name);
            if(Label.Pricing_Tender_PermissionSets_AllExternal.split(':').contains(psa.PermissionSet.Name)) {
                isPartnerUser = true;
        }
        }

        if(quoteLine.SBQQ__Quote__r.Pricing_On_Hold_Cb__c && !isPartnerUser) {
            return true;
        }
        else if(quoteLineStatus == Label.Pricing_Tender_QuoteLine_Status_Draft){
            return false;
        }else if(quoteLineStatus == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && 
           lstPermissionSets.contains(Label.Pricing_Tender_PermissionSets_TenderUser)){
            return false;
        }else if((quoteLineStatus == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && 
                lstPermissionSets.contains(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager) &&
                (!Label.Pricing_Combined_Tender_SVD_Quote_Line_Read_Only.contains(rtMap.get(quoteLine.RecordTypeId).getDeveloperName())))){
                return false;
        }else{
            return true; 
        }
    }
    // This method checks if the user has access to create Pricing_Performance_Metric__c record
    // Returns Boolean True if user has access else it returns false
    @AuraEnabled
    public static Boolean isCreateable(){
        return Schema.sObjectType.Pricing_Performance_Metric__c.isCreateable();
    }
    // This method checks if the user has access to update Pricing_Performance_Metric__c record
    // Returns Boolean True if user has access else it returns false
    @AuraEnabled(cacheable=true)
    public static Boolean isUpdateable(){
        return Schema.sObjectType.Pricing_Performance_Metric__c.isUpdateable();
    }
    // This method checks if the user has access to delete Pricing_Performance_Metric__c record
    // Returns Boolean True if user has access else it returns false
    @AuraEnabled(cacheable=true)
    public static Boolean isDeletable(){
        return Schema.sObjectType.Pricing_Performance_Metric__c.isDeletable();
    }
    //This method is used in Pricing_PerformanceMetrics
    //It takes object name and field name as parameters and returns the list of lables of values in that field 
    @AuraEnabled(cacheable=true)     
    public static List<String> getPickListValues(String objectType, String selectedField) {
        List<String> pkListValues = new List<String>();
        Schema.SObjectType obj = ((SObject)Type.forName(objectType).newInstance()).getSObjectType();
        Schema.DescribeSObjectResult res = obj.getDescribe();
        Schema.DescribeFieldResult result = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> pkle = result.getPicklistValues();
        for( Schema.PicklistEntry pklVal : pkle){
            pkListValues.add(pklVal.getLabel());
        }     
        return pkListValues;
    }
    //This method takes the Pricing_Performance_Metric__c redord Id as input and delets the record
    @AuraEnabled
    public static void deletePerformanceMetrics(Id recordId){
        try{
            List<Pricing_Performance_Metric__c> data = new List<Pricing_Performance_Metric__c>();
            data= [Select Id FROM Pricing_Performance_Metric__c where Id =:recordId];
            if(data.size() > 0){
                //delete data;
                Pricing_DatabaseOperation.performDelete(data,true,false);
            }  
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
    }

    //method to control the visibility of Performance metrics for SSD product type
    @AuraEnabled (cacheable=true)
    public static Boolean showQuoteLineDetail(Id quoteLineId) {
        SBQQ__QuoteLine__c quoteLine = [SELECT Pricing_Program_Type_Nm__c From SBQQ__QuoteLine__c WHERE Id = : quoteLineId];
        Boolean isStandard;
        isStandard = (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote) ? false :(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_SSD_Quote) ? false : (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_PMem_Quote) ? false : (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_NIC_Quote) ? false : (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU) ? false : true;
        return isStandard;
    }
}