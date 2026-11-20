/**************************************************************************************
Apex Class Name:  Core_OppProductsAtRisk_Ctrl
Version     : 1.0 
Created Date: 30 January 2020
Function    : Opportunity products at risk functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             30/01/2020              Original Version
*************************************************************************************/
public without sharing class Core_OppProductsAtRisk_Ctrl {
    
    /*
    * Method name  : showAtRisk --TWC3123-5794--
    * Description  : Method to return boolean value; false if PCC DEAL REG have FI Products, True for Intel-Led and PCC design and deal REG if atleast one product is non-FI
    * Return Type  : boolean
    * Parameter    : Id oppId
    */
    @AuraEnabled
    public static boolean showAtRisk(Id oppId){
       
        return Core_CRM_Utility.PCCDealReg_showTab(oppId);
       
    }
    
    /*
    * Method name  : getOppRecord
    * Description  : Method to query the opportunity record
    * Return Type  : Opportunity
    * Parameter    : String oppId
    */
    public static Opportunity getOppRecord(String oppId){
        return [select Id, Core_At_Risk__c,Core_Opportunity_Owner_Geo__c from Opportunity where Id =: oppId WITH SECURITY_ENFORCED];
    }
    
    /*
    * Method name  : getOppProductList
    * Description  : Method to query the opportunity products
    * Return Type  : List<OpportunityLineItem>
    * Parameter    : String oppId
    */
    public static List<OpportunityLineItem> getOppProductList(String oppId){
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
        try{
            oppProductList = [select Id, Core_IsPCCOpportunity_cb__c, Core_Financial_Incentive_Eligible_cb__c , Product2.Name,Core_Status__c, Core_BU_Short_Name__c, Core_At_Risk__c, Core_Risk_Reason1__c, Core_Risk_Reason2__c, Core_Risk_Priority__c, Core_Risk_Category__c, Core_At_Risk_Status__c, Core_Product_Risk_Owner__c, Core_Risk_Create_Date__c, Core_Risk_End_Date__c, Core_Risk_Detail__c from OpportunityLineItem where OpportunityId =: oppId AND Core_Status__c NOT IN('Production Win Approved', 'Production Win')  WITH SECURITY_ENFORCED order by Product2.Name asc];//
        }
        catch(Exception e){
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'An exception has been thrown for:Class.Core_OppProductsAtRisk_Ctrl.getOppProductList',Core_Details__c = e.getMessage(), Core_Origin__c='Core_OppProductsAtRisk_Ctrl', Core_Severity__c='Info', Core_When__c=System.Now(), Core_Project__c = 'Unicorn');
                    Database.insert(logEntry, false);
        }
        return oppProductList;
    }
    
    /*
    * Method name  : getOpportunityProducts
    * Description  : Method to get the opportunity products wrapped in OpportunityProductAtRiskWrapper class
    * Return Type  : OpportunityProductAtRiskWrapper
    * Parameter    : String oppId, String noValue
    */
    
    @auraEnabled
    public static OpportunityProductAtRiskWrapper getOpportunityProducts(String oppId, String noValue){
        OpportunityProductAtRiskWrapper oppProductAtRiskWrap = new OpportunityProductAtRiskWrapper();
        oppProductAtRiskWrap.oppRecord = getOppRecord(oppId);
        
        List<OpportunityLineItem> oppProductList = getOppProductList(oppId);
        List<OppProductWrapper> oppProductWrapList = new List<OppProductWrapper>();
        OppProductWrapper oppProductWrap;
        if(!oppProductList.isEmpty()){
            Set<String> riskReasonSet = new Set<String>(getPicklistValues('OpportunityLineItem', 'Core_Risk_Reason1__c'));
            Set<String> riskPrioritySet = new Set<String>(getPicklistValues('OpportunityLineItem', 'Core_Risk_Priority__c'));
            Set<String> riskStatusSet = new Set<String>(getPicklistValues('OpportunityLineItem', 'Core_At_Risk_Status__c'));
            
            for(OpportunityLineItem oppProduct : oppProductList){
            // PCC related changes TWC4767-1769
            if ((oppProduct.Core_IsPCCOpportunity_cb__c== true &&  oppProduct.Core_Financial_Incentive_Eligible_cb__c == false  ) || (oppProduct.Core_IsPCCOpportunity_cb__c== false))
            {
                
                oppProductWrap = new OppProductWrapper();
                oppProductWrap.oppLineItemId = oppProduct.Id;
                oppProductWrap.productName = oppProduct.Product2.Name;
                oppProductWrap.buShortName = oppProduct.Core_BU_Short_Name__c;
                oppProductWrap.atRisk = oppProduct.Core_At_Risk__c;
                oppProductWrap.prdstatus= oppProduct.Core_Status__c;

                oppProductWrap.isRiskReasonInActive = false;
                oppProductWrap.riskReason1 = oppProduct.Core_Risk_Reason1__c;
                if(oppProduct.Core_Risk_Reason1__c <> null && oppProduct.Core_Risk_Reason1__c <> '' && !riskReasonSet.contains(oppProduct.Core_Risk_Reason1__c)){//TWC3123-5299  combined if
                    oppProductWrap.isRiskReasonInActive = true;
                }
                
                oppProductWrap.isRiskPriorityInActive = false;
                oppProductWrap.riskPriority = oppProduct.Core_Risk_Priority__c;
                if(oppProduct.Core_Risk_Priority__c <> null && oppProduct.Core_Risk_Priority__c <> '' && !riskPrioritySet.contains(oppProduct.Core_Risk_Priority__c)){//TWC3123-5299  combined if
                    oppProductWrap.isRiskPriorityInActive = true;
                }
                
                oppProductWrap.isRiskStatusInActive = false;
                if(oppProduct.Core_At_Risk_Status__c == null || oppProduct.Core_At_Risk_Status__c == ''){
                    oppProductWrap.riskStatus = noValue;
                }else{
                    oppProductWrap.riskStatus = oppProduct.Core_At_Risk_Status__c;
                    if(!riskStatusSet.contains(oppProduct.Core_At_Risk_Status__c)){
                        oppProductWrap.isRiskStatusInActive = true;
                    }
                }
                oppProductWrap.prodRiskOwner = oppProduct.Core_Product_Risk_Owner__c;
                oppProductWrap.riskCreateDate = oppProduct.Core_Risk_Create_Date__c;
                oppProductWrap.riskEndDate = oppProduct.Core_Risk_End_Date__c;
                oppProductWrap.riskDetail = oppProduct.Core_Risk_Detail__c;
                oppProductWrap.isDisabled = oppProduct.Core_At_Risk__c;
                oppProductWrapList.add(oppProductWrap);
                
            }
            }
        }
        oppProductAtRiskWrap.oppProductList = oppProductWrapList;
        return oppProductAtRiskWrap;
    }
    
    /*
    * Method name  : save
    * Description  : Method to save the changes in the opportunity products
    * Return Type  : void
    * Parameter    : Opportunity oppRecord, List<OppProductWrapper> oppProductList, String noValue
    */
    @auraEnabled
    public static void save(Opportunity oppRecord, List<OppProductWrapper> oppProductList, String noValue){
        List<OpportunityLineItem> productList = getOppProductList(oppRecord.Id);
        Map<String,OpportunityLineItem> productMap = new Map<String,OpportunityLineItem>();
        for(OpportunityLineItem oppProd : productList){
            productMap.put(oppProd.Id,oppProd);
        }
        List<OpportunityLineItem> finalProdList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem;
        boolean flag;
        for(OppProductWrapper oppProdWrap : oppProductList){
            flag = false;
            OpportunityLineItem dbOppProd = productMap.get(oppProdWrap.oppLineItemId);
            
            if(dbOppProd != null) {
                if(oppProdWrap.atRisk != dbOppProd.Core_At_Risk__c){
                    flag = true;
                }else if(oppProdWrap.riskReason1 != dbOppProd.Core_Risk_Reason1__c){
                    flag = true;
                }else if(oppProdWrap.riskPriority != dbOppProd.Core_Risk_Priority__c){
                    flag = true;
                }else if(oppProdWrap.riskStatus != dbOppProd.Core_At_Risk_Status__c){
                    flag = true;
                }else if(oppProdWrap.prodRiskOwner != dbOppProd.Core_Product_Risk_Owner__c){
                    flag = true;
                }else if(oppProdWrap.riskCreateDate != dbOppProd.Core_Risk_Create_Date__c){
                    flag = true;
                }else if(oppProdWrap.riskEndDate != dbOppProd.Core_Risk_End_Date__c){
                    flag = true;
                }else if(oppProdWrap.riskDetail != dbOppProd.Core_Risk_Detail__c){
                    flag = true;
                }            
                
                String prdstatus = dbOppProd.Core_Status__c;
            
                if(flag && prdstatus != System.Label.Core_LineItem_Status){
                    oppLineItem = new OpportunityLineItem();
                    oppLineItem.Id = oppProdWrap.oppLineItemId;
                    oppLineItem.Core_At_Risk__c = oppProdWrap.atRisk;
                    if(oppProdWrap.riskReason1 == noValue){
                        oppLineItem.Core_Risk_Reason1__c = '';
                    }else{
                        oppLineItem.Core_Risk_Reason1__c = oppProdWrap.riskReason1;
                    }
                    if(oppProdWrap.riskPriority == noValue){
                        oppLineItem.Core_Risk_Priority__c = '';
                    }else{
                        oppLineItem.Core_Risk_Priority__c = oppProdWrap.riskPriority;
                    }
                    if(oppProdWrap.riskStatus == noValue){
                        oppLineItem.Core_At_Risk_Status__c = '';
                    }else{
                        oppLineItem.Core_At_Risk_Status__c = oppProdWrap.riskStatus;
                    }
                    oppLineItem.Core_Product_Risk_Owner__c = oppProdWrap.prodRiskOwner;
                    oppLineItem.Core_Risk_Create_Date__c = oppProdWrap.riskCreateDate;
                    oppLineItem.Core_Risk_End_Date__c = oppProdWrap.riskEndDate;
                    oppLineItem.Core_Risk_Detail__c = oppProdWrap.riskDetail;
                    finalProdList.add(oppLineItem);
                }
            } else {
                Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'An exception has been thrown for:Class.Core_OppProductsAtRisk_Ctrl.save',Core_Details__c = 'Trying to access the Opportunitylineitem record which is not present in database.', Core_Origin__c='Core_OppProductsAtRisk_Ctrl', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Unicorn');
                    Database.insert(logEntry, false);
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        Opportunity opp = getOppRecord(oppRecord.Id);
        if(opp.Core_At_Risk__c <> oppRecord.Core_At_Risk__c){
            oppRecord.Core_Bypass_At_Risk_Validation__c = true;
        }
        
        try{
            //TWC3123-5299 added if-isUpdateable
            if (Schema.sObjectType.Opportunity.isUpdateable()) {
                update oppRecord;
             }
             //TWC3123-5299 added if-isUpdateable
            if (Schema.sObjectType.OpportunityLineItem.isUpdateable()) {
                update finalProdList;
            }
            oppRecord.Core_Bypass_At_Risk_Validation__c = false;
            //TWC3123-5299 added if-isUpdateable
            if (Schema.sObjectType.Opportunity.isUpdateable()) {
                update oppRecord;
            }
        }catch(DmlException e){
            //Get All DML Messages
            String msg = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            Database.rollback(sp);
            throw new AuraHandledException(msg);
        }catch(Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*
    * Method name  : getPicklistValues
    * Description  : Method to fetch the picklist values
    * Return Type  : List<String>
    * Parameter    : String objName, string fld
    */
    @auraEnabled
    public static List<String> getPicklistValues(String objName, string fld) {
        List<String> allOpts = new List<String>();
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : values){
            allOpts.add(a.getValue());
        }
        //allOpts.sort();
        return allOpts;
    }
    
    @AuraEnabled
    public static String getProdRiskOwner(String oppId/*OpportunityLineItem opplineItem*/, string RiskReason) {
      
        
        String prodRiskOwner='';
        Opportunity opp=getOppRecord(oppId);
        if(RiskReason =='Risk - Supply: Sample'){
            if(opp.Core_Opportunity_Owner_Geo__c== Core_Product_Risk_Owner_values__c.getValues('Risk - Supply: Sample - AMR').Core_Opportunity_Region__c){
                prodRiskOwner= Core_Product_Risk_Owner_values__c.getValues('Risk - Supply: Sample - AMR').Core_Product_Risk_Owner_Email__c;
            }else if(opp.Core_Opportunity_Owner_Geo__c== Core_Product_Risk_Owner_values__c.getValues('Risk - Supply: Sample - APJ').Core_Opportunity_Region__c){
                prodRiskOwner= Core_Product_Risk_Owner_values__c.getValues('Risk - Supply: Sample - APJ').Core_Product_Risk_Owner_Email__c;
            }else if(opp.Core_Opportunity_Owner_Geo__c== Core_Product_Risk_Owner_values__c.getValues('Risk - Supply: Sample - EMEA').Core_Opportunity_Region__c){
                prodRiskOwner= Core_Product_Risk_Owner_values__c.getValues('Risk - Supply: Sample - EMEA').Core_Product_Risk_Owner_Email__c;
            }else if(opp.Core_Opportunity_Owner_Geo__c== Core_Product_Risk_Owner_values__c.getValues('Risk - Supply: Sample - PRC').Core_Opportunity_Region__c){
                prodRiskOwner= Core_Product_Risk_Owner_values__c.getValues('Risk - Supply: Sample - PRC').Core_Product_Risk_Owner_Email__c;
            }
            /*else if(opp.Core_Opportunity_Owner_Geo__c.equalsIgnoreCase(Core_Product_Risk_Owner_values__c.getValues('Risk - Supply: Sample - INDIA').Core_Opportunity_Region__c)){
                prodRiskOwner= Core_Product_Risk_Owner_values__c.getValues('Risk - Supply: Sample - INDIA').Core_Product_Risk_Owner_Email__c;
            }*/
        }else if(RiskReason =='Risk - Supply: System Build'){
            prodRiskOwner= Core_Product_Risk_Owner_values__c.getValues('Risk - Supply: System Build').Core_Product_Risk_Owner_Email__c;
        }
              
        return prodRiskOwner;
    }
    //Start TWC3123-4920 
    @auraEnabled
    public static SeedSampleDetails getSeedSampleURL(){
     map<String,Core_System_Credentials__c> mapStringToCS = new map<String,Core_System_Credentials__c>();

        // Set the reference to the system url name to system credentials 
        for(Core_System_Credentials__c sobjCS : Core_System_Credentials__c.getAll().Values()){
            mapStringToCS.put(sobjCS.Name, sobjCS);
        }
        SeedSampleDetails getDetails = new SeedSampleDetails();
        getDetails.SeedURL = mapStringToCS.get(System.Label.Core_DemoDepotOrder).Core_End_Point_URL__c + System.Label.Core_aceOppID + '=';
        getDetails.SampleURL = mapStringToCS.get('My Samples Request Placement').Core_End_Point_URL__c +'&OpportunityId=';
       return getDetails; 
    }
    public class SeedSampleDetails{

        @AuraEnabled
        public String SeedURL;
        @AuraEnabled
        public String SampleURL;
    }
    //End TWC3123-4920 

    /*
    * Method name  : getFieldDependencies
    * Description  : Method to dependent picklist field's values
    * Return Type  : Map<String, List<String>>
    * Parameter    : String objectName, String controllingField, String dependentField, String noValue
    */
    /*@auraEnabled
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField, String noValue){
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        List<String> dependentList = new List<String>();
        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            dependentList = new List<String>();
            dependentList.add(noValue);
            controllingInfo.put(currControllingValue.getLabel(), dependentList);
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);
            
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            
            
            
            Integer baseCount = 0;
            
            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;
                
                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }
                
                if((val & 8) == 8)
                {
                    
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4)
                {

                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 2) == 2)
                {

                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1)
                {
          
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                }
                
                baseCount += 4;
            }            
        } 
        
        
        
        return controllingInfo;
    }*/
    
    public class OpportunityProductAtRiskWrapper{
        @auraEnabled
        public Opportunity oppRecord{get;set;}
        @auraEnabled
        public List<OppProductWrapper> oppProductList{get;set;}
    }
    
    public class OppProductWrapper{
        @auraEnabled
        public String oppLineItemId{get;set;}
        @auraEnabled
        public String productName{get;set;}
        @auraEnabled
        public String buShortName{get;set;}
        @auraEnabled
        public Boolean atRisk{get;set;}
        @auraEnabled
        public String riskReason1{get;set;}
        @auraEnabled
        public String riskPriority{get;set;}
        @auraEnabled
        public String riskStatus{get;set;}
        @auraEnabled
        public String prodRiskOwner{get;set;}
        @auraEnabled
        public DateTime riskCreateDate{get;set;}
        @auraEnabled
        public DateTime riskEndDate{get;set;}
        @auraEnabled
        public String riskDetail{get;set;}
        @auraEnabled
        public Boolean isDisabled{get;set;}
        @auraEnabled
        public Boolean isRiskReasonInActive{get;set;}
        @auraEnabled
        public Boolean isRiskPriorityInActive{get;set;}
        @auraEnabled
        public Boolean isRiskStatusInActive{get;set;}
        @auraEnabled
        public String prdstatus{get;set;}
    }
    
    /*public class MyPickListInfo{
        public String validFor;
    }*/
}