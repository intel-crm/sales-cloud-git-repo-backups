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
public class Core_OppProductsAtRisk_Ctrl {
    
    /*
    * Method name  : getOppRecord
    * Description  : Method to query the opportunity record
    * Return Type  : Opportunity
    * Parameter    : String oppId
    */
    public static Opportunity getOppRecord(String oppId){
        return [select Id, Core_At_Risk__c, Core_At_Risk_Created_Date__c, Core_Support_Requested__c from Opportunity where Id =: oppId];
    }
    
    /*
    * Method name  : getOppProductList
    * Description  : Method to query the opportunity products
    * Return Type  : List<OpportunityLineItem>
    * Parameter    : String oppId
    */
    public static List<OpportunityLineItem> getOppProductList(String oppId){
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
        oppProductList = [select Id, Product2.Name, Core_BU_Short_Name__c, Core_At_Risk__c, Core_Risk_Reason1__c, Core_Risk_Reason2__c, Core_Risk_Priority__c, Core_Risk_Category__c, Core_At_Risk_Status__c from OpportunityLineItem where OpportunityId =: oppId order by Product2.Name asc];
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
            Map<String, List<String>> dependentFieldMap = getFieldDependencies('OpportunityLineItem', 'Core_Risk_Category__c', 'Core_At_Risk_Status__c', noValue);
            List<String> dependentValueList;
            List<String> finalDepValueList;
            for(OpportunityLineItem oppProduct : oppProductList){
                oppProductWrap = new OppProductWrapper();
                oppProductWrap.oppLineItemId = oppProduct.Id;
                oppProductWrap.productName = oppProduct.Product2.Name;
                oppProductWrap.buShortName = oppProduct.Core_BU_Short_Name__c;
                oppProductWrap.atRisk = oppProduct.Core_At_Risk__c;
                oppProductWrap.riskReason1 = oppProduct.Core_Risk_Reason1__c;
                oppProductWrap.riskReason2 = oppProduct.Core_Risk_Reason2__c;
                oppProductWrap.riskPriority = oppProduct.Core_Risk_Priority__c;
                if(oppProduct.Core_Risk_Category__c == null || oppProduct.Core_Risk_Category__c == ''){
                    oppProductWrap.riskCategory = noValue;
                }else{
                    oppProductWrap.riskCategory = oppProduct.Core_Risk_Category__c;
                }
                if(oppProduct.Core_At_Risk_Status__c == null || oppProduct.Core_At_Risk_Status__c == ''){
                    oppProductWrap.riskStatus = noValue;
                }else{
                    oppProductWrap.riskStatus = oppProduct.Core_At_Risk_Status__c;
                }
                finalDepValueList = new List<String>();
                if(oppProductWrap.riskCategory <> noValue){
                    dependentValueList = new List<String>();
                    dependentValueList = dependentFieldMap.get(oppProductWrap.riskCategory);
                    if(oppProductWrap.riskCategory.equalsIgnoreCase('Support Requested')){
                        finalDepValueList.add(dependentValueList[0]);
                        if(oppProductWrap.riskStatus.equalsIgnoreCase(noValue)){
                            finalDepValueList.add(dependentValueList[1]);
                        }else if(oppProductWrap.riskStatus.equalsIgnoreCase('In-Progress')){
                            finalDepValueList.add(dependentValueList[1]);
                            finalDepValueList.add(dependentValueList[2]);
                            finalDepValueList.add(dependentValueList[3]);
                        }else if(oppProductWrap.riskStatus.equalsIgnoreCase('Support Granted By HQ') || oppProductWrap.riskStatus.equalsIgnoreCase('Support Not Granted By HQ')){
                            finalDepValueList.add(dependentValueList[2]);
                            finalDepValueList.add(dependentValueList[3]);
                            finalDepValueList.add(dependentValueList[4]);
                            finalDepValueList.add(dependentValueList[5]);
                        }else if(oppProductWrap.riskStatus.equalsIgnoreCase('Support Provided') || oppProductWrap.riskStatus.equalsIgnoreCase('Support Not Provided')){
                            finalDepValueList.add(dependentValueList[4]);
                            finalDepValueList.add(dependentValueList[5]);
                        }else{
                            finalDepValueList.add(dependentValueList[1]);
                        }
                    }else{
                        finalDepValueList.addAll(dependentValueList);
                    }
                }else{
                    finalDepValueList.add(noValue);
                }
                oppProductWrap.riskStatusValues = finalDepValueList;
                oppProductWrap.isDisabled = oppProduct.Core_At_Risk__c;
                oppProductWrapList.add(oppProductWrap);
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
            if(oppProdWrap.atRisk <> productMap.get(oppProdWrap.oppLineItemId).Core_At_Risk__c){
                flag = true;
            }else if(oppProdWrap.riskReason1 <> productMap.get(oppProdWrap.oppLineItemId).Core_Risk_Reason1__c){
                flag = true;
            }else if(oppProdWrap.riskReason2 <> productMap.get(oppProdWrap.oppLineItemId).Core_Risk_Reason2__c){
                flag = true;
            }else if(oppProdWrap.riskPriority <> productMap.get(oppProdWrap.oppLineItemId).Core_Risk_Priority__c){
                flag = true;
            }else if(oppProdWrap.riskCategory <> productMap.get(oppProdWrap.oppLineItemId).Core_Risk_Category__c){
                flag = true;
            }else if(oppProdWrap.riskStatus <> productMap.get(oppProdWrap.oppLineItemId).Core_At_Risk_Status__c){
                flag = true;
            }
            if(flag){
                oppLineItem = new OpportunityLineItem();
                oppLineItem.Id = oppProdWrap.oppLineItemId;
                oppLineItem.Core_At_Risk__c = oppProdWrap.atRisk;
                if(oppProdWrap.riskReason1 == noValue){
                    oppLineItem.Core_Risk_Reason1__c = '';
                }else{
                    oppLineItem.Core_Risk_Reason1__c = oppProdWrap.riskReason1;
                }
                if(oppProdWrap.riskReason2 == noValue){
                    oppLineItem.Core_Risk_Reason2__c = '';
                }else{
                    oppLineItem.Core_Risk_Reason2__c = oppProdWrap.riskReason2;
                }
                if(oppProdWrap.riskPriority == noValue){
                    oppLineItem.Core_Risk_Priority__c = '';
                }else{
                    oppLineItem.Core_Risk_Priority__c = oppProdWrap.riskPriority;
                }
                if(oppProdWrap.riskCategory == noValue){
                    oppLineItem.Core_Risk_Category__c = '';
                }else{
                    oppLineItem.Core_Risk_Category__c = oppProdWrap.riskCategory;
                }
                if(oppProdWrap.riskStatus == noValue){
                    oppLineItem.Core_At_Risk_Status__c = '';
                }else{
                    oppLineItem.Core_At_Risk_Status__c = oppProdWrap.riskStatus;
                }
                finalProdList.add(oppLineItem);
            }
        }
        try{
            update finalProdList;
        }catch(DmlException e){
            //Get All DML Messages
            String msg = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            throw new AuraHandledException(msg);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        Opportunity opp = getOppRecord(oppRecord.Id);
        if(opp.Core_At_Risk__c <> oppRecord.Core_At_Risk__c || opp.Core_Support_Requested__c <> oppRecord.Core_Support_Requested__c){
            try{
                update oppRecord;
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
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
        allOpts.sort();
        return allOpts;
    }
    
    /*
    * Method name  : getFieldDependencies
    * Description  : Method to dependent picklist field's values
    * Return Type  : Map<String, List<String>>
    * Parameter    : String objectName, String controllingField, String dependentField, String noValue
    */
    @auraEnabled
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
            
            System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);
            
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
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 2) == 2)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                }
                
                baseCount += 4;
            }            
        } 
        
        System.debug('ControllingInfo: ' + controllingInfo);
        
        return controllingInfo;
    }
    
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
        public String riskReason2{get;set;}
        @auraEnabled
        public String riskPriority{get;set;}
        @auraEnabled
        public String riskCategory{get;set;}
        @auraEnabled
        public String riskStatus{get;set;}
        @auraEnabled
        public List<String> riskStatusValues{get;set;}
        @auraEnabled
        public Boolean isDisabled{get;set;}
    }
    
    public class MyPickListInfo{
        public String validFor;
    }
}