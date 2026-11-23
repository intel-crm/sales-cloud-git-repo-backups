/**
 * @description       : This method takes list of Pricing_Performance_Metric__c that need to be saved and the Pricing_Quote_Line__c Id to create new records with the data
 * @author            : Rakshitha BR
 * @group             : Intel
 * @last modified on  : 04-13-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_PerformanceMetrics_Mock {
    
    
    /**
    * @description using savePerformanceMetrics method to remove sall the queries and DML
    * @author Rakshitha BR | 04-13-2022 
    * @param inprec 
    * @param quoteLineId 
    * @return boolean 
    **/
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
                    Pricing_Performance_Metric_DML.updatePerformanceMetric(perfMetricsToUpdate);
                }
                if(!perfMetricsToInsert.isEmpty())
                {
                   Pricing_Performance_Metric_DML.insertPerformanceMetric(perfMetricsToInsert);
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

    /**
    * @description Using savePMListCreation to remove sall the queries and DML
    * @author Rakshitha BR | 04-13-2022 
    * @param inprec 
    * @param perfMetricsToUpdate 
    * @param perfMetricsToInsert 
    * @param quoteLineId 
    * @return boolean 
    **/
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
    @AuraEnabled(cacheable=true)
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
        return Pricing_Performance_Metric_Selector.newInstance().selectByQuoteLineIds(recordId);
    }
    
    /**
    * @description This method takes QuoteLine record Id as input and returns True if the page layout is ReadOnlyElse it returns false
    * @author Rakshitha BR| 04-13-2022 
    * @param recordId 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean isReadOnlyPageLayout(Id recordId){
        Map < ID, Schema.RecordTypeInfo > rtMap = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosById();
        SBQQ__QuoteLine__c  quoteLine = Pricing_QuoteLines_Selector.newInstance().selectByQuoteLineIds(new Set<Id>{recordId})[0];
        String quoteLineStatus = quoteLine.Pricing_Status_Nm__c;
        String integrationStatus = quoteLine.Pricing_Integration_Status_Nm__c;
        String dealRFQStatus = quoteLine.Pricing_Deal_RFQ_Status_Nm__c;
        Set < String > quoteLineReadOnlyDealRFQStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_ReadOnly_DealRFQStatus).split(':'));
        List<PermissionSetAssignment> lstcurrentUserPerSet =new List<PermissionSetAssignment>(Pricing_PermissionSetAssignment_Selector.newInstance().selectbyUserId(UserInfo.getUserId()));
        // STORE CURRENT USER'S PERMISSION SETS IN A LIST
        List<String> lstPermissionSets = new List<String>();
        for (PermissionSetAssignment psa : lstcurrentUserPerSet) {
            lstPermissionSets.add(psa.PermissionSet.Name);
        }
        if(quoteLineStatus == Label.Pricing_Tender_QuoteLine_Status_Draft){
            return false;
        }else if(quoteLineStatus == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && 
           lstPermissionSets.contains(Label.Pricing_Tender_PermissionSets_TenderUser)){
            return false;
        }else if((quoteLineStatus == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && 
                lstPermissionSets.contains(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager) &&
                (rtMap.get(quoteLine.RecordTypeId).getDeveloperName() != Label.Pricing_Tender_QuoteLine_RecordType_ReadOnly || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() != Label.Pricing_SVD_Quote_Line_Read_Only))){
                return false;
        }else{
            return true; 
        }
    }
    
    /**
    * @description This method checks if the user has access to create Pricing_Performance_Metric__c recordReturns Boolean True if user has access else it returns false
    * @author Rakshitha BR | 04-13-2022 
    * @return Boolean 
    **/
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
        Schema.SObjectType obj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = obj.getDescribe();
        Schema.DescribeFieldResult result = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> pkle = result.getPicklistValues();
        for( Schema.PicklistEntry pklVal : pkle){
            pkListValues.add(pklVal.getLabel());
        }     
        return pkListValues;
    }
   
    /**
    * @description This method takes the Pricing_Performance_Metric__c redord Id as input and delets the record
    * @author Rakshitha BR | 04-13-2022 
    * @param recordId 
    **/
    @AuraEnabled
    public static void deletePerformanceMetrics(Id recordId){
        try{
            List<Pricing_Performance_Metric__c> data = new List<Pricing_Performance_Metric__c>();
            data = Pricing_Performance_Metric_Selector.newInstance().selectByrecordIds(recordId);
            if(data.size() > 0){
                Pricing_Performance_Metric_DML.deletePerformanceMetric(data);
            }  
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
    }

    
    /**
    * @description method to control the visibility of Performance metrics for SSD product type
    * @author Rakshitha BR | 04-13-2022 
    * @param quoteLineId 
    * @return Boolean 
    **/
    @AuraEnabled (cacheable=true)
    public static Boolean showQuoteLineDetail(Id quoteLineId) {
        SBQQ__QuoteLine__c quoteLine = Pricing_QuoteLines_Selector.newInstance().selectByQuoteLineIds(new Set<Id>{quoteLineId})[0];
        Boolean isStandard;
        isStandard = (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_SSD_Quote) ? false : (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_PMem_Quote) ? false : (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_NIC_Quote) ? false : true;
        return isStandard;
    }
}