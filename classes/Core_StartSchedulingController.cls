/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_StartSchedulingController
Version     : 1.0 
Created Date: 26 NOV 2020
Function    : Handles Start Scheduling button functionalityon 6QPS component
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             11/26/2020              Original Version

*****************************************************************************************************************************************************************************************************/

public without sharing class Core_StartSchedulingController {
    
    public static final Set<String> Core_Status = new Set<String>{'Lost','Cancelled','Deleted','On Hold','Production Lost','Production Cancelled'};
    /*
    * Method name  : checkOldFCRecords
    * Description  : This Method used to check already existing scheduling for those line items.
    * Return Type  : boolean
    * Parameter    : String opportunityId
    */ 
    @AuraEnabled
    public static boolean checkOldFCRecords(String opportunityId){
        boolean giveWarning= false;
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> oliIdSet = new Set<Id>();
        List<opportunity> opp = [select id, Core_Opportunity_Type__c,Core_First_Customer_Ship_Date__c,(select id,name,OpportunityId,Product2Id,Core_Vendor__c from OpportunityLineItems) from opportunity where id =:opportunityId];
        if(opp.size() > 0 ){
            for(opportunity o : opp){
                if(o.OpportunityLineItems.size()>0){
                    for(OpportunityLineItem oli : o.OpportunityLineItems){
                        opptyIdSet.add(oli.OpportunityId);
                        oliIdSet.add(oli.Id);
                    }
                }
            }
        }
        List<Core_Opp_FC_Prod_Schedule__c> fps = [SELECT id, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Opportunity__c, Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c, Core_Opp_Line_Item_RecordID__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_Line_Item_RecordID__c IN :oliIdSet AND Core_Opp_FC_isdeleted__c = false ORDER BY Core_Opp_FC_Product__r.Name,Core_Opp_FC_Quarter_Date__c];
        if(fps.size() > 0){
            giveWarning = true;
        }
        return giveWarning;
    }
    
    /*
    * Method name  : showQuarters
    * Description  : This Method used to show the eligible quarters on the UI.
    * Return Type  : forecastWrapper
    * Parameter    : String opportunityId 
    */ 
    @AuraEnabled
    public static forecastWrapper showQuarters(String opportunityId){
        boolean checkBlankDates = false;
        Date referenceDate;
        Integer numberOfFutureQuarters = 5;
        forecastWrapper frwrpr = new forecastWrapper();
        frwrpr.message = '';
        frwrpr.qrtrsValues = new List<String>();
        List<opportunity> opp = [select id, Core_Opportunity_Type__c,Core_First_Customer_Ship_Date__c,(select id,name,OpportunityId,Product2Id,Core_Vendor__c from OpportunityLineItems) from opportunity where id =:opportunityId];
        String firstValue = '';
        frwrpr.qrtrsValues.add(firstValue);
        if(opp.size()>0){
            if(opp[0].Core_Opportunity_Type__c.contains('Deal')){
                referenceDate = system.today();
                checkBlankDates = true;
            }
            if(opp[0].Core_Opportunity_Type__c.contains('Design')){
                if(opp[0].Core_First_Customer_Ship_Date__c != NULL){
                    referenceDate = opp[0].Core_First_Customer_Ship_Date__c;
                    checkBlankDates = true;
                }
            }            
            if(referenceDate != NULL && checkBlankDates){
                
                for(integer i =-1;i<=numberOfFutureQuarters;i++){
                    String qrtrs = getQuarter(referenceDate.addMonths(3*i));
                    frwrpr.qrtrsValues.add(qrtrs);
                }
            }
            else{
                frwrpr.message = 'Please enter First Customer Ship Date';
            }
        }
        return frwrpr;
    }
    public static String getQuarter(Date quarterDate){
        String qtName = String.valueOf(quarterDate.year()) + '-';
        Integer tempQt = 0;
        if(quarterDate.month() <= 3){
            tempQt = 1;
        }else if(quarterDate.month() <= 6){
            tempQt = 2;
        }else if(quarterDate.month() <= 9){
            tempQt = 3;
        }else{
            tempQt = 4;
        }
        qtName = qtName + 'Q' + tempQt;
        return qtName;
    }    
    
    /*
    * Method name  : submitData
    * Description  : This Method used to create Forecast records on selection of Start date and number of quarters.
    * Return Type  : forecastWrapper
    * Parameter    : date startDate,integer selectedQuarters, String opportunityId
    */ 
    @AuraEnabled
    public static forecastWrapper submitData(string startDate,integer selectedQuarters, String opportunityId){
        String message= null;
        Decimal qty = 0;
        boolean allowSave= false;
        Date referenceDate;
        boolean checkOLIExists = false;
        String approvalStatus = '';
        Decimal qtr = 0.00;
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> oliIdSet = new Set<Id>();
        forecastWrapper frwrpr = new forecastWrapper(); 
        frwrpr.allowSave = false;
        frwrpr.giveWarning = false;
        frwrpr.message = '';
        Map<Id, OpportunityLineItem> oliPresentMap = new Map<Id, OpportunityLineItem>();
        Map<Id, OpportunityLineItem> oliMap = new Map<Id, OpportunityLineItem>();
        List<Core_Opp_FC_Prod_Schedule__c> forecastRecList = new List<Core_Opp_FC_Prod_Schedule__c>();        
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> opptyLineItemVsFCMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        List<Integer> approvedList = new List<Integer>();
        List<Core_Opp_FC_Prod_Schedule__c> Fcp = new List<Core_Opp_FC_Prod_Schedule__c>();
        List<String> divisionLogic = (Label.Core_FC_ForecastDivision).split(';');
        
        List<opportunity> opp = [select id, Core_Opportunity_Type__c,Core_First_Customer_Ship_Date__c,StageName,(select id,name,OpportunityId,Product2Id,Core_Vendor__c,quantity,Core_PW_Sales_Price__c,Core_PW_Quantity__c,Core_Status__c,UnitPrice from OpportunityLineItems) from opportunity where id =:opportunityId];//TWC3123-4884 added Core_PW_Sales_Price__c,Core_PW_Quantity__c,StageName
        if(opp.size() > 0 ){
            for(opportunity o : opp){
                if(o.OpportunityLineItems.size()>0){
                    for(OpportunityLineItem oli : o.OpportunityLineItems){
                        opptyIdSet.add(oli.OpportunityId);
                        oliIdSet.add(oli.Id);
                    }
                }
            }
        }
        
        if(opp[0].Core_Opportunity_Type__c.contains('Deal')){
            referenceDate = system.today();
            
        }
        else if(opp[0].Core_Opportunity_Type__c.contains('Design')){
            referenceDate = opp[0].Core_First_Customer_Ship_Date__c;
            
        }
        
        
        if(opptyIdSet.size()>0){
            oliPresentMap = new Map<Id, OpportunityLineItem>([SELECT id, Quantity, UnitPrice,Core_BU_Short_Name__c,Core_BU_Product_Segment__c,OpportunityId, Core_Vendor__c, Core_Status__c,Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :opptyIdSet]);
        }
        if(oliPresentMap != null && !oliPresentMap.isEmpty()){
            Fcp = [SELECT id, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Opportunity__c, Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c, Core_Opp_Line_Item_RecordID__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c IN : opptyIdSet and Core_Is_Post_Win__c=false];//TWC3123-4884 Core_Is_Post_Win__c=falseto exclude Post Win records
        }
        Date qtrDate;
        for(OpportunityLineItem oli : opp[0].OpportunityLineItems){
            
            Decimal considerSalesPrice;//TWC3123-4911 
            
            //date fc_Qtr_date;
            //String[] qtrs = startDate.split('\\-');
            date fc_Qtr_date = getFcQuarterDate(startDate);
            /*if(qtrs[1].contains('1')){
                fc_Qtr_date = Date.newInstance(integer.valueof(qtrs[0]),1,1);
            }
            else if(qtrs[1].contains('2')){
                fc_Qtr_date = Date.newInstance(integer.valueof(qtrs[0]),4,1);
            }
            else if(qtrs[1].contains('3')){
                fc_Qtr_date = Date.newInstance(integer.valueof(qtrs[0]),7,1);
            }
            else{
                fc_Qtr_date = Date.newInstance(integer.valueof(qtrs[0]),10,1);
            }*/
            for(integer i=0;i<selectedQuarters;i++){
                approvalStatus = '';
                
                 if(opp[0].Core_Opportunity_Type__c.contains('Deal')){
                    
                    qty = 0;
                    considerSalesPrice = oli.UnitPrice;
                }
                else if(opp[0].Core_Opportunity_Type__c.contains('Design')){
                    //TWC3123-4911 start If Opp Stage is 'Production Win' or 'Design Win' or Post-Win Product it will take Core_PW_Quantity__c and Core_PW_Sales_Price__c for calculation
                    if((opp[0].StageName == 'Production Win' || opp[0].StageName == 'Design Win') && oli.Core_Status__c!='Post-Win')  {
                         if(oli.Core_PW_Quantity__c!=null){
                              qty =((oli.Core_PW_Quantity__c)/(Integer.valueOf(divisionLogic[i]))).round(System.RoundingMode.HALF_UP);
                          }
                         if(oli.Core_PW_Sales_Price__c!=null){
                              considerSalesPrice = oli.Core_PW_Sales_Price__c;
                         }
                     }
                    //If Opp Stage is not in 'Production Win' or 'Design Win' it will take Quantity and UnitPrice for calculation
                    else{
                        if(oli.Quantity!=null){
                              qty = ((oli.Quantity)/(Integer.valueOf(divisionLogic[i]))).round(System.RoundingMode.HALF_UP);
                          }
                        if(oli.UnitPrice!=null){
                            considerSalesPrice = oli.UnitPrice;
                        }
                                         
                    }  
             }//TWC3123-4911 end
            system.debug('Inside considerSalesPrice is"'+considerSalesPrice);    
        
            forecastRecList.add(new Core_Opp_FC_Prod_Schedule__c(Core_FC_Opportunity_Product__c=oli.id,Core_Opp_FC_Opportunity__c = oli.OpportunityId, Core_Opp_FC_Quarter_Date__c= fc_Qtr_date ,Core_Opp_Line_Item_RecordID__c = oli.Id, Core_Opp_FC_Product__c = oli.Product2Id, Core_Opp_FC_Quantity__c = qty, Core_Opp_FC_isdeleted__c = false, Core_FC_Vendor__c = oli.Core_Vendor__c, Core_Opp_FC_Prod_Sales_Price__c = considerSalesPrice, Core_Opp_FC_Approval_Status__c = approvalStatus, Core_FC_BU_Product_Segment__c = oliPresentMap.get(oli.Id).Core_BU_Product_Segment__c,Core_FC_BU_Short_Name__c = oliPresentMap.get(oli.Id).Core_BU_Short_Name__c));//changed Core_Opp_FC_Prod_Sales_Price__c = oliPresentMap.get(oli.Id).UnitPrice to considerSalesPrico 
                fc_Qtr_date = fc_Qtr_date.addMonths(3);
                
            }
            qtrDate = fc_Qtr_date;
        }
        Set<Id> fcIdSet = new Set<Id>();
        List<Core_Opp_FC_Prod_Schedule__c> toLockRecords = new List<Core_Opp_FC_Prod_Schedule__c>();
        try{
            date fc_Qtr_date = getFcQuarterDate(startDate);
            opportunity saveOpp = new Opportunity();
            saveOpp.id = opportunityId;
            saveOpp.Core_Quarter_Start_Date__c = fc_Qtr_date;
            saveOpp.Core_Number_of_Quarters__c = selectedQuarters;
            update saveOpp;
            delete Fcp;
            Database.SaveResult[] srList = Database.insert(forecastRecList); //insert forecastRecList; // database.saveresult exception 
            for (Database.SaveResult sr : srList){
                fcIdSet.add(sr.getId());
            }
            if(!fcIdSet.isEmpty()){
                for(Core_Opp_FC_Prod_Schedule__c fc1 : [SELECT id, Name, Core_Opp_FC_Approval_Status__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Id IN : fcIdSet]){
                    if(fc1.Core_Opp_FC_Approval_Status__c == 'Approved' || fc1.Core_Opp_FC_Approval_Status__c == 'Submitted'){
                        toLockRecords.add(fc1);
                    }
                }
                Approval.LockResult[] lrList = Approval.lock(toLockRecords,false);
            }
            
        }
        catch(Exception e){
            System.debug('Insert Exception - '+e.getMessage());
        }
        system.debug('frwrpr main-->'+frwrpr);
        return frwrpr;
    }
    public static date getFcQuarterDate(string startDate){
        date fc_Qtr_date;
        String[] qtrs = startDate.split('\\-');
        
        if(qtrs[1].contains('1')){
            fc_Qtr_date = Date.newInstance(integer.valueof(qtrs[0]),1,1);
        }
        else if(qtrs[1].contains('2')){
            fc_Qtr_date = Date.newInstance(integer.valueof(qtrs[0]),4,1);
        }
        else if(qtrs[1].contains('3')){
            fc_Qtr_date = Date.newInstance(integer.valueof(qtrs[0]),7,1);
        }
        else{
            fc_Qtr_date = Date.newInstance(integer.valueof(qtrs[0]),10,1);
        } 
        return fc_Qtr_date;
    }
    
    public class ForecastWrapper{
        @AuraEnabled
        public string message{get;set;}
        @AuraEnabled
        public boolean allowSave{get;set;}
        @AuraEnabled
        public boolean giveWarning{get;set;}
        @AuraEnabled
        public List<String> qrtrsValues{get;set;}
        
    }
}