/**
* @File Name : CRM_Opp_ApprovalChecklistController.cls
* @Description : 
* @Author : Beatles - Accenture
* @Last Modified By :
* @Last Modified On : February 5, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | February 5, 2025 | Aashna Anand  | Initial Version
**/

public without sharing class CRM_Opp_ApprovalChecklistController {
    
    public static final Set<String> openStages = new Set<String>{'Define','Develop','Design'};
        
    @AuraEnabled(cacheable=true)
    public static checklistTextWrapper getCustomLabels() {

        checklistTextWrapper wrpr = new checklistTextWrapper();
        wrpr.Partner              = Core_CRM_Utility.getCRMLabel('CRM_CheckList_Partner'); 
        wrpr.ManufacturingRegion  = Core_CRM_Utility.getCRMLabel('CRM_CheckList_ManuRegion');
        wrpr.ExcludefromKPIs      = Core_CRM_Utility.getCRMLabel('CRM_CheckList_ExcludeFromKPIs');
        wrpr.StatusUpdate         = Core_CRM_Utility.getCRMLabel('CRM_CheckList_StatusUpdate');
        wrpr.DecisionDate         = Core_CRM_Utility.getCRMLabel('CRM_CheckList_DecisionDate');
        wrpr.Vendor               = Core_CRM_Utility.getCRMLabel('CRM_CheckList_Vendor');
        wrpr.OppDescription       = Core_CRM_Utility.getCRMLabel('CRM_CheckList_OppDescription');
        wrpr.DescOfContri         = Core_CRM_Utility.getCRMLabel('CRM_CheckList_DescOfContri');
        wrpr.CompArchConversion   = Core_CRM_Utility.getCRMLabel('CRM_CheckList_CompArchConversion');
        wrpr.OppSolutions         = Core_CRM_Utility.getCRMLabel('CRM_CheckList_OppSolutions');
        wrpr.ProductionEndDate    = Core_CRM_Utility.getCRMLabel('CRM_CheckList_ProdEndDate');	
        wrpr.FirstCustShipDate    = Core_CRM_Utility.getCRMLabel('CRM_CheckList_FirstCustShipDate');
        wrpr.Volume               = Core_CRM_Utility.getCRMLabel('CRM_CheckList_Volume');
        wrpr.DescriptiveFeatures  = Core_CRM_Utility.getCRMLabel('CRM_CheckList_DescFeatures');
        wrpr.QuantityValidate     = Core_CRM_Utility.getCRMLabel('CRM_CheckList_QuantityValidate');
        wrpr.riskURL              = Core_CRM_Utility.getCRMLabel('AtRisk_URL');   
        return wrpr;
    }
    
    @AuraEnabled
    public static checklistWrapper fetchData(Id oppId) {
        
        String POP = '%'+Label.Core_Performance_indicator+'%';
        String POP1 = '%'+Label.Core_Performance_indicator1+'%';
        String POP2 = '%'+Label.Core_Performance_indicator2+'%';
        List<String> DWPOPFileNames = new List<String>();
        List<String> PWPOPFileNames = new List<String>();
        checklistWrapper wrpr = new checklistWrapper();
                
        Opportunity currentOpp = [select id,Core_Decimal_Check__c,Core_Quantity_count__c,Opportunity_Focus__c,Account.RecordType.name, Core_Opportunity_Type__c,
                                  Core_Product_At_Risk__c,Core_Military_Aerospace_Govmt_End_Use__c,Core_Compliance_Status__c,Core_Production_End_Date__c,
                                  Core_First_Customer_Ship_Date__c,StageName,Core_Oppty_Check_BU_Short_Name__c,Core_Write_In_Product_Count__c,
                                  Core_Competitive_Architecture__c,Description, Core_MAG_Account__c, Core_Status_Update__c,Core_Manufacturing_Geo__c,
                                  Core_Volume__c,Core_Solution_Type__c,Core_Solution_Detail__c,Core_Combined_Solution_Detail__c,Core_Exclude_From_KPIs__c,
                                  CloseDate,Core_Solution_Area_Count__c,Core_Opportunity_Coverage_Nm__c,Desired_End_State__c,Technology_and_Readiness_Gaps__c,
                                  Business_Need__c,Technical_Need__c,FAD_Start_Date__c,FAD_End_Date__c,Competitor_Threat_Mitigation__c,RecordType.DeveloperName  
                                  from Opportunity where id =: oppId limit 1];
        
        List<OpportunityLineItem> opptyLineItemsList= [SELECT id, Name, Core_Vendor__r.RecordType.name, Core_Status__c, Core_BU_Short_Name__c, 
                                                       Core_Write_In_Product_Flag__c, Core_Vendor__c FROM OpportunityLineItem WHERE OpportunityId = :oppId];
        
        //--------------firstCustomerShipDate check
        boolean firstCustomerShipConditionCheck = (currentOpp.Core_First_Customer_Ship_Date__c != null && String.valueOf(currentOpp.Core_First_Customer_Ship_Date__c) != '' && currentOpp.Core_First_Customer_Ship_Date__c > System.Today());
        wrpr.firstCustomerShipDate = (firstCustomerShipConditionCheck == true) ? true : false ;
        
        //--------------DecisionDateCheck check
        wrpr.DecisionDateCheck = (currentOpp.CloseDate < System.Today() || currentOpp.CloseDate > System.Today().addDays(365))? true : false;
        
        //--------------excludeKPIflag check
        /*if(currentOpp.Core_Exclude_From_KPIs__c){
            wrpr.ExludeKPIflag=true;
        }else if(currentOpp.Core_Exclude_From_KPIs__c=false){
            wrpr.ExludeKPIflag=false;
        }*/
        wrpr.ExludeKPIflag = (currentOpp.Core_Exclude_From_KPIs__c == true)?true:false;
        
        //--------------ExcludeVolume check ::ByPass/Stage Gate Validation for PCC - migrated to JS      
        //wrpr.ExcludeVolume = (currentOpp.Core_Opportunity_Coverage_Nm__c==Core_CRM_Utility.getCRMLabel('Core_OpportunitySellerProgram'))? true : false;
        
        //--------------Note_Attachmentsize check
        DWPOPFileNames.add(POP);
        DWPOPFileNames.add(POP1);
        DWPOPFileNames.add(POP2);
        wrpr.Note_Attachmentsize = checkPOPFiles(oppId,DWPOPFileNames);
        
        //--------------PW_Note_Attachmentsize check
        if(Label.Core_Performance_indicator3.contains(',')){
            PWPOPFileNames = Label.Core_Performance_indicator3.split(',');
        }else{
            PWPOPFileNames.add(Label.Core_Performance_indicator3); 
        }
        wrpr.PW_Note_Attachmentsize = checkPOPFiles(oppId,PWPOPFileNames);
        
        //--------------Opptypartnersize check
        Integer Opptupartnersize=[select count() from Core_Opportunity_Partner__c where Core_Opportunity__c =:oppId]; 
        wrpr.Opptypartnersize = (Opptupartnersize > 0) ? true : false;
        
        //--------------MAGFlag check
        boolean magConditionCheck = currentOpp.Core_Military_Aerospace_Govmt_End_Use__c != null && 
            ((currentOpp.Core_Military_Aerospace_Govmt_End_Use__c == 'Yes' || currentOpp.Core_MAG_Account__c == true) && 
             ((String.valueOf(currentOpp.Core_Compliance_Status__c) == '' || currentOpp.Core_Compliance_Status__c == null) || 
              (currentOpp.Core_Compliance_Status__c != 'Approved' && currentOpp.Core_Compliance_Status__c != 'Approved with Guardrails' && 
               currentOpp.Core_Compliance_Status__c != 'N/A')));        
        wrpr.MAGFlag = (magConditionCheck == true) ? false : true;
        
        //--------------ProductionDate check
        wrpr.ProductionDate = productionDateCheck(currentOpp.Core_First_Customer_Ship_Date__c, currentOpp.Core_Production_End_Date__c);
        
        //--------------InactiveOppAccount check
        wrpr.InactiveOppAccount = (currentOpp.Account.RecordType.name=='Inactive Account') ? true : false; 
        
        //--------------QuantityValidate check 
        wrpr.QuantityValidate = (currentOpp.Core_Decimal_Check__c==False) ? True : false;
        
        //--------------DescriptiveFeature check :: There is not at least one Descriptive Feature added
        Integer DescriptiveFeaturesize=[select count() from Core_Opportunity_Features__c where Core_Opportunity__c =:oppId];
        wrpr.DescriptiveFeature = (DescriptiveFeaturesize == 0) ? false : true;
        
        //--------------isOppotySolutionAdded check :: TWC3123-4164 - Added Opportunity Solution Check.
        wrpr.isOppotySolutionAdded = (currentOpp.Core_Solution_Area_Count__c > 0) ? True : False;
        
        //--------------isDescriptionOfContribution check :: TWC3123-4822 - Added Description of Contribution Check.           
        Integer oppTMCount= [SELECT count() from OpportunityTeamMember WHERE OpportunityId = :oppId and Core_Description_of_Contribution__c = NULL];
        wrpr.isDescriptionOfContribution = (oppTMCount > 0) ? False : True; 
        
        //--------------OPPORTUNITYLINEITEM object related check are consolidated into one wrapper and method.
        wrpr.OliWrapper = opportunityLineItemChecks(opptyLineItemsList);
        
        boolean commonCheck = (wrpr.OliWrapper.BUShortName==true && wrpr.MAGFlag==true && wrpr.OliWrapper.WriteInProducts==true && wrpr.Note_Attachmentsize==true && currentOpp.Core_Competitive_Architecture__c != null && currentOpp.Description != null && currentOpp.Core_Status_Update__c !=null && !currentOpp.Core_Product_At_Risk__c);
        
        if(openStages.contains(currentOpp.StageName)) { //checking for Design, Develop, Design          
            if(currentOpp.Core_Opportunity_Type__c.containsIgnoreCase('Design')) { //checking for Design Opportunity Type
                if(commonCheck == true && wrpr.DescriptiveFeature == true && wrpr.firstCustomerShipDate == true && wrpr.ProductionDate==true && wrpr.Opptypartnersize==true && currentOpp.Core_Manufacturing_Geo__c != null){ 
                    wrpr.Completeflag = true; 
                    wrpr.ARReviewtheList = false;
                }else{
                    wrpr.Completeflag = false; 
                    wrpr.ARReviewtheList = true; 
                }
            }else{
                if(commonCheck == true && currentOpp.Core_Solution_Type__c !=null && currentOpp.Core_Combined_Solution_Detail__c !=null && wrpr.OliWrapper.Vendorsize==true && wrpr.Opptypartnersize==true ){
                    wrpr.Completeflag=true; 
                    wrpr.ARReviewtheList=false;      
                }else{
                    wrpr.Completeflag=false;
                    wrpr.ARReviewtheList=true; 
                }
            }
        }
        
        return wrpr;
    }
    
    //Method - OPPORTUNITYLINEITEM object related check are consolidated into one wrapper and method.
    public static oliChecklistWrapper opportunityLineItemChecks(List<OpportunityLineItem> oliList) {
        oliChecklistWrapper oliWrpr = new oliChecklistWrapper();
        
        Integer opplineitemvendorsize = 0;
        Integer BUShortNamesize = 0;
        Integer ToBeDeletedsize = 0;
        Integer writeInProductSize = 0;
        Integer InactiveVendorAccountSize = 0;
        
        if(!oliList.isempty()) {
            for(OpportunityLineItem opline : oliList) {
                if(opline.Core_Vendor__c == null || String.valueOf(opline.Core_Vendor__c) == '') {
                    opplineitemvendorsize++;
                }
                if(opline.Core_BU_Short_Name__c == null || opline.Core_BU_Short_Name__c == '') {
                    BUShortNamesize++;
                }
                if(opline.core_status__c == 'To Be Deleted') {
                    ToBeDeletedsize++;
                }
                if(opline.Core_Write_In_Product_Flag__c) {
                    writeInProductSize++;
                }
                if(opline.Core_Vendor__r.RecordType.name=='Inactive Account') {
                    InactiveVendorAccountSize++;
                }
            }
            oliWrpr.Vendorsize = (opplineitemvendorsize > 0) ? false : true;
            
            oliWrpr.BUShortName = (BUShortNamesize == 0) ? true : false;
            
            oliWrpr.ToBeDeletedPrd = (ToBeDeletedsize > 0) ? true : false;
            
            oliWrpr.WriteInProducts = (writeInProductSize == 0) ? true : false;            
            
            oliWrpr.InactiveVendorAccount = (InactiveVendorAccountSize>0) ? true : false;
            
        }
        else{
            oliWrpr.BUShortName = true;    //Modified the logic for getting the BU ShortName and displaying green if no Oppty Line Items present
            oliWrpr.ToBeDeletedPrd= false;
            oliWrpr.WriteInProducts=true;  //Modified the logic for getting the Write In Product and displaying green if no Oppty Line Items present
        }
        return oliWrpr;
    }
    
    //Method - The 'Opportunity Type' contains "Design" AND the 'Production End Date' = NULL or is prior to the current date (i.e. date is in the past) or is prior to the 'First Customer Ship Date' (i.e. Production End Date is before First Customer Ship Date).//
    public static boolean productionDateCheck(date FirstCustomerShipDate, date ProductionEndDate) {
        boolean productionDate = false;
        if(FirstCustomerShipDate != null && String.valueOf(FirstCustomerShipDate) != '') {
            if(ProductionEndDate == null || ProductionEndDate < system.today() || ProductionEndDate < FirstCustomerShipDate) {
                productionDate = false;
            }else{
                productionDate = true;
            }
        }else{
            productionDate = false;
        }
        return productionDate;
    }
    
    //Method -to check PoP files names for both DW AND PW
    public static boolean checkPOPFiles (Id oppId, List<String> POPFileNames) {        
        List<Attachment> attachsize1=[select id,Name from Attachment where parentId=:oppId AND Name LIKE :POPFileNames];
        List<Note> Notesize1=[select id,Title from Note where parentId=: oppId AND Title Like:POPFileNames];
        List<ContentDocumentLink > contentdocSize1=[SELECT ContentDocumentId,ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId=:oppId AND ContentDocument.Title Like:POPFileNames];
        List<Task> taskList1 = [SELECT id, Subject, Core_Task_Type__c FROM Task WHERE (Subject LIKE:POPFileNames OR Core_Task_Type__c LIKE:POPFileNames) AND WhatId = :oppId];
        
        if((attachsize1 != null && !attachsize1.isEmpty()) || (Notesize1 != null && !Notesize1.isEmpty()) || (contentdocSize1 != null && !contentdocSize1.isEmpty()) || (taskList1 != null && !taskList1.isEmpty())){         
            return true;
            
        }else{
            return false;  
        }        
    }
    
    public class checklistWrapper {     
        @AuraEnabled
        public boolean MAGFlag= false;
        @AuraEnabled
        public boolean Note_Attachmentsize= false;
        @AuraEnabled
        public boolean DescriptiveFeature= false;
        @AuraEnabled
        public boolean firstCustomerShipDate= false;
        @AuraEnabled
        public boolean ProductionDate= false;
        @AuraEnabled
        public boolean Opptypartnersize= false;
        @AuraEnabled
        public boolean DecisionDateCheck=false;
        @AuraEnabled
        public boolean ExludeKPIflag=false;
        /*@AuraEnabled
        public boolean ExcludeVolume = false; migrated to JS*/
        @AuraEnabled
        public boolean PW_Note_Attachmentsize = false;
        @AuraEnabled
        public boolean InactiveOppAccount = false;
        @AuraEnabled
        public boolean QuantityValidate = false;
        @AuraEnabled
        public boolean isDescriptionOfContribution = false;
        @AuraEnabled
        public boolean isOppotySolutionAdded = false;
        @AuraEnabled
        public boolean Completeflag = false;
        @AuraEnabled
        public boolean ARReviewtheList = false;
        @AuraEnabled
        public oliChecklistWrapper OliWrapper {get;set;}
    }
    
    public class oliChecklistWrapper{
        @AuraEnabled
        public boolean BUShortName = false;
        @AuraEnabled
        public boolean WriteInProducts= false;
        @AuraEnabled
        public boolean Vendorsize= false;
        @AuraEnabled
        public boolean ToBeDeletedPrd = false;
        @AuraEnabled
        public boolean InactiveVendorAccount = false;
    }

    public class checklistTextWrapper{
        @AuraEnabled
        public string QuantityValidate;
        @AuraEnabled
        public string DescriptiveFeatures;
        @AuraEnabled
        public string Volume;
        @AuraEnabled
        public string FirstCustShipDate;
        @AuraEnabled
        public string ProductionEndDate;
        @AuraEnabled
        public string OppSolutions;
        @AuraEnabled
        public string CompArchConversion;
        @AuraEnabled
        public string DescOfContri;
        @AuraEnabled
        public string OppDescription;
        @AuraEnabled
        public string StatusUpdate;
        @AuraEnabled
        public string Partner;
        @AuraEnabled
        public string ManufacturingRegion;
        @AuraEnabled
        public string ExcludefromKPIs;
        @AuraEnabled
        public string DecisionDate;
        @AuraEnabled
        public string Vendor;
        @AuraEnabled
        public string riskURL;

    }
}