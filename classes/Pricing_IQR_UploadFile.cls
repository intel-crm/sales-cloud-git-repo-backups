/**
* @description       : Controller class is created for Bulk Change Request UI
* @author            : Rahul Maindalkar
* @group             : 
* @last modified on  : 06-12-2025
* @last modified by  : Bharath Chandrashekar
**/
public without sharing class Pricing_IQR_UploadFile {
    
    
    /**
* @description Method is created to get data for Bulk CR CSV template 
* @author Rahul Maindalkar | 08-24-2022  
**/   
    @AuraEnabled(cacheable=true)
    public static List<Pricing_Upload_File_Mapping_CS__c> getUploadMetaData() {
        return [SELECT Id,Pricing_Order_Nbr__c,Pricing_Field_API_Name__c,Pricing_Field_Name__c,Pricing_Object_API_Name__c,Pricing_Object_Name__c
                from Pricing_Upload_File_Mapping_CS__c WHERE Pricing_Object_API_Name__c IN: Label.Pricing_Bulk_Action_Types.split(',') order by Pricing_Order_Nbr__c asc];
    }
    
    /**
* @description Method is created to get the description for the Bulk CR UI
* @author Rahul Maindalkar | 08-24-2022 
**/   
    @AuraEnabled(cacheable=true)
    public static List<IQRBulkUploadDescriptionCS__c> getBulkUploadDescriptions(){
        try {
            return [select id,Name,LabelDescription__c from IQRBulkUploadDescriptionCS__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    /**
* @description Method is created to convert base64 csv data in Map and call Pricing_QLBulkCRValidation Batch 
* @author Rahul Maindalkar | 08-24-2022 
* @param base64Data 
* @param objectName
**/  
    @AuraEnabled
    public static String processRecords(String base64Data, String objectName){
        Map<String, SBQQ__QuoteLine__c> QLMap = New Map<String, SBQQ__QuoteLine__c>();
        objectName=(objectName==null?objectName:String.escapeSingleQuotes(objectName));
        String data = JSON.deserializeUntyped(base64Data).toString();
        data=String.escapeSingleQuotes(data);
        List<String> lstCSVLines = data.split('\n');
        Boolean populateloggedinUser = Pricing_QLBulkCRSendPayloadHelper.WWID_val;
        Set<String> wwIdSet = New Set<String>();
        Map<String, Id> wwIdUserIdMap = New Map<String, Id>();
        integer errorRow = 0;
        try{
            for (Integer i=1;i<lstCSVLines.size();i++) {
                errorRow = i;
                list<String> columnValues = new list<String>();
                columnValues = lstCSVLines[i].split(',');
                SBQQ__QuoteLine__c QL = New SBQQ__QuoteLine__c();
                QL.Pricing_Approved_Start_Date_Dt__c = string.isBlank(((columnValues[2]).replace('"',''))) ? Null : Date.parse((columnValues[2]).replace('"',''));
                QL.Pricing_Approved_End_Date_Dt__c = string.isBlank(((columnValues[3]).replace('"',''))) ? Null : Date.parse((columnValues[3]).replace('"',''));
                QL.Pricing_Revised_Pricing_Start_Date_dt__c = string.isBlank(((columnValues[4]).replace('"',''))) ? Null : Date.parse((columnValues[4]).replace('"',''));
                QL.Pricing_ECAP_Price_Amt__c = string.isBlank(((columnValues[5]).replace('"',''))) ? Null : Decimal.valueOf((columnValues[5]).replace('"',''));
                QL.Pricing_Billing_Start_Date_Dt__c = string.isBlank(((columnValues[6]).replace('"',''))) ? Null :Date.parse((columnValues[6]).replace('"',''));
                QL.Pricing_Billing_End_Date_Dt__c = string.isBlank(((columnValues[7]).replace('"',''))) ? Null :Date.parse((columnValues[7]).replace('"',''));
                QL.Pricing_Approved_Unit_Qty__c = string.isBlank(((columnValues[8]).replace('"',''))) ? Null :Integer.valueof((columnValues[8]).replace('"','')); 
                QL.Pricing_Payable_Quantity__c = string.isBlank(((columnValues[9]).replace('"',''))) ? Null :Integer.valueof((columnValues[9]).replace('"',''));
                QL.Pricing_Backdate_Reason_Txt__c = string.isBlank((columnValues[10]).replace('"',''))? Null : (columnValues[10]).replace('"','');
                QL.Pricing_Meet_Comp_Price_Amt__c = string.isBlank(((columnValues[11]).replace('"',''))) ? Null : Decimal.valueOf((columnValues[11]).replace('"',''));
                QL.Pricing_FSE_Recommended_Price_Nm__c = (string.isBlank((columnValues[12]).replace('"',''))? 'Blank' : (columnValues[12]).replace('"',''));
                QL.Pricing_Deal_Description__c = string.isBlank((columnValues[13]).replace('"',''))? Null : (columnValues[13]).replace('"','');
                QL.Pricing_Additional_T_C_s_Txt__c = string.isBlank((columnValues[14]).replace('"',''))? Null : (columnValues[14]).replace('"','');
                QL.Pricing_Additional_Comments_Txt__c = (columnValues[15]).replace('"','');
                QL.Pricing_Manager__c = Null;
                QLMap.put((columnValues[0]).replace('"',''),QL);
                if(QL.Pricing_FSE_Recommended_Price_Nm__c!='Blank'){
                    wwIdSet.add(QL.Pricing_FSE_Recommended_Price_Nm__c);
                }
            }
            if(!populateloggedinUser){
                for(User userData : [Select Id , Core_WWID__c from User where Core_WWID__c in :wwIdSet]){
                    wwIdUserIdMap.put(userData.Core_WWID__c, userData.Id);
                }
            }
            
            // Calling Batch Apex to Validate and Create Change Request
            if(!Test.isRunningTest()){ 
                Pricing_QLBulkCRValidation.validateBulkCR(QLMap,wwIdUserIdMap);
            }  
        } catch (Exception e) {
            errorRow = errorRow +1;
            return 'Error while uploading File - On Row: '+errorRow+' - '+e;
        }        
        return 'Operation Completed';  
    }
    
    @AuraEnabled
    public static String processCompetitorProductPrice(String base64Data, String objectName){
        Map<String, Pricing_Competitor_Product_Price_Staging__c> CPPSMap = New Map<String, Pricing_Competitor_Product_Price_Staging__c>();
        String data = JSON.deserializeUntyped(base64Data).toString();
        data=String.escapeSingleQuotes(data);
        List<String> lstCSVLines = data.split('\n');
        integer errorRow = 0;
        try{
            for (Integer i=1;i<lstCSVLines.size();i++){
                errorRow = i;
                list<String> columnValues = new list<String>();
                //new code started...
                String input = lstCSVLines[i];
                boolean isReplaceComma = input.contains('"');
                if(isReplaceComma && !test.isRunningTest()){
                    List<String> parts = input.split('"');
                    String updatedString = '';
                    // Safety check
                    if (parts.size() == 3) {
                        String quotedPart = parts[1];       // Data inside quotes
                        String remainingData = parts[2];    // Everything after the quoted part, starts with comma
                        quotedPart = quotedPart.replaceAll(',','#');
                        updatedString = quotedPart+remainingData;
                    }
                    columnValues = updatedString.split(',');
                    columnValues[0]=columnValues[0].replaceAll('#',',');
                }else{
                    columnValues = input.split(',');
                }
                //new code ended
                
                Pricing_Competitor_Product_Price_Staging__c CPPS = new Pricing_Competitor_Product_Price_Staging__c();
                CPPS.Pricing_Competitor_Product_Name_Staging__c = String.isBlank((columnValues[0]).replace('"',''))? Null : ((columnValues[0]).replace('"',''));
                    CPPS.Pricing_List_Price_Staging__c = String.isBlank((columnValues[1]).replace('"',''))? Null : Decimal.valueOf((columnValues[1]).replace('"',''));
                CPPS.Pricing_Region_Staging_Nm__c = String.isBlank((columnValues[2]).replace('"',''))? Null : (columnValues[2]).replace('"','');
                CPPS.Pricing_Median_Meet_Comp_Disty_Staging__c = String.isBlank((columnValues[3]).replace('"',''))? Null : Decimal.valueOf((columnValues[3]).replace('"',''));
                CPPS.Pricing_Application_Staging_Nm__c = String.isBlank((columnValues[4]).replace('"',''))? Null : (columnValues[4]).replace('"','');
                CPPS.Pricing_Final_Meet_Comp_Price_Staging__c = String.isBlank((columnValues[5]).replace('"',''))? Null : Decimal.valueOf((columnValues[5]).replace('"','').trim());
                if((columnValues[0]).replace('"','').trim() != null && (columnValues[0]).replace('"','').trim() != '' ){
                    CPPSMap.put((columnValues[0]).replace('"','').trim(),CPPS);
                }
            }
            Pricing_CompProductPriceBulkBatch bulkCompProductPrice = new Pricing_CompProductPriceBulkBatch(CPPSMap);
            Database.executeBatch(bulkCompProductPrice, Integer.valueOf(Label.Pricing_Bulk_Comp_Product_Price_BatchSize));
        } catch (Exception e) {
            errorRow = errorRow +1;
            Pricing_Tender_Utility.logError(e); 
            return 'Error while uploading File - On Row: '+errorRow+' - '+e;
        }
        return 'Operation Completed';
    }
    
    public static Map<String, String> validateCompetitorProductPrice(List<Pricing_Competitor_Product_Price_Staging__c> compProductPriceList){
        Map<String,Pricing_Competitor_Product_Price_Staging__c> compProductPriceNametoRecordMap = new Map<String, Pricing_Competitor_Product_Price_Staging__c>();
        Map<String,Pricing_Competitor_Product_Price_Staging__c> compProductPriceNametoRecMapSuccess = new Map<String, Pricing_Competitor_Product_Price_Staging__c>();
        Map<string, string> regionValues = getRegionValues();
        Map<string, string> applicationValues = getApplicationValues();
        List<String> compProductPriceNamesList = new List<String>();
        List<String> compProdsList = new List<String>();
        Map<Id, String> compProdPriceIdToProdName = new Map<Id, String>();
        List<Pricing_Competitor_Product_Price_Staging__c> compProductPricetoInsert = new List<Pricing_Competitor_Product_Price_Staging__c>();
        Map<String, String> compProductPriceSuccessErrorMap = new Map<String, String>();
        Set<Id> insertedCompProdIds = new Set<Id>();
        Map<String, Id> compProdPriceNameToProdIdMap = new Map<String, Id>();
        String errorMsg = '';
        String resMsg = '';
        String compProdPriceName = '';
        Decimal finalMeetCompPrice;
        Decimal medianMeetCompDiscount;
        Decimal listPrice;
        String Region = '';
        String Application = '';
        String compProdPriceid;
        
        try{
            for(Pricing_Competitor_Product_Price_Staging__c compProductPrice : compProductPriceList){
                compProductPriceNamesList.add(compProductPrice.Pricing_Competitor_Product_Name_Staging__c);
                compProductPriceNametoRecordMap.put(compProductPrice.Pricing_Competitor_Product_Name_Staging__c, compProductPrice);
            }
            
            for(Pricing_Competitor_Product__c cp : [select Id,Name from Pricing_Competitor_Product__c where Name IN: compProductPriceNamesList 
                                                    and Pricing_Active_cb__c = true and RecordType.Name IN ('Client','Data Center')]){
                                                        compProdsList.add(cp.Name);
                                                    }
            for(String cppName : compProductPriceNametoRecordMap.keySet()){
                
                //Check if Product Name is blank
                if(String.isBlank(cppName)){
                    errorMsg += 'Product is a required field. Please select a value and try again. ; ';                                      
                }
                
                //Check if Region is blank
                if(String.isBlank(compProductPriceNametoRecordMap.get(cppName).Pricing_Region_Staging_Nm__c)){
                    errorMsg += 'Region is a required field. Please select a value and try again. ; ';                                      
                }
                
                //Check if Application is blank
                if(String.isBlank(compProductPriceNametoRecordMap.get(cppName).Pricing_Application_Staging_Nm__c)){
                    errorMsg += 'Application is a required field. Please select a value and try again. ; ';                                      
                }
                
                //Check if Final Meet Comp Price is blank
                if(compProductPriceNametoRecordMap.get(cppName).Pricing_Final_Meet_Comp_Price_Staging__c == null){
                    errorMsg += 'Final Meet Comp Price is a required field. Please select a value and try again. ; ';                                      
                }
                
                
                //Check When Region Invalid Values are entered
                if(!String.isEmpty(compProductPriceNametoRecordMap.get(cppName).Pricing_Region_Staging_Nm__c) && !regionValues.values().contains(compProductPriceNametoRecordMap.get(cppName).Pricing_Region_Staging_Nm__c)){
                    errorMsg += 'Invalid value for Region. Please select a valid value and try again. ; ';                                      
                }
                
                //Check When Application Invalid Values are entered
                if(!String.isEmpty(compProductPriceNametoRecordMap.get(cppName).Pricing_Application_Staging_Nm__c) && !applicationValues.values().contains(compProductPriceNametoRecordMap.get(cppName).Pricing_Application_Staging_Nm__c)){
                    errorMsg += 'Invalid value for Application. Please select a valid value and try again. ; ';                                      
                }
                
                //Check Non Latin Characters
                if(!String.isBlank(cppName)){
                    if(Pricing_Tender_Utility.validateNonLatinChars(cppName)){
                        errorMsg += 'Only Latin languages (ex. English, Spanish, German, etc.) are allowed. Please remove non-Latin characters (ex. Chinese, Hebrew, etc.). ; ';
                    }
                }
                
                //Check invalid competitor product
                if(!compProdsList.contains(cppName)){
                    errorMsg += 'Competitor Product is invalid. Please select a different Competitor Product and try again ; ';
                }
                
                //Check List Price greater than zero
                if((compProductPriceNametoRecordMap.get(cppName).Pricing_List_Price_Staging__c == null)|| (compProductPriceNametoRecordMap.get(cppName).Pricing_List_Price_Staging__c != null && compProductPriceNametoRecordMap.get(cppName).Pricing_List_Price_Staging__c<=0)){
                    errorMsg += 'List Price should always be greater than zero ; ';                                      
                }
                //Check Median Meet Comp Price 
                if((compProductPriceNametoRecordMap.get(cppName).Pricing_Median_Meet_Comp_Disty_Staging__c == null) || (compProductPriceNametoRecordMap.get(cppName).Pricing_Median_Meet_Comp_Disty_Staging__c != null && (compProductPriceNametoRecordMap.get(cppName).Pricing_Median_Meet_Comp_Disty_Staging__c < 0 || compProductPriceNametoRecordMap.get(cppName).Pricing_Median_Meet_Comp_Disty_Staging__c > 100))){
                    errorMsg += 'Median Meet Comp Discount should always be between 0 to 100 ; ';                                      
                }
                //Check Final Meet Comp Price
                if(compProductPriceNametoRecordMap.get(cppName).Pricing_Final_Meet_Comp_Price_Staging__c != null && compProductPriceNametoRecordMap.get(cppName).Pricing_Final_Meet_Comp_Price_Staging__c <= 0 ){
                    errorMsg += 'Final Meet Comp Price should always be greater than zero ; ';                                      
                }
                if(String.isBlank(errorMsg)){
                    compProductPriceNametoRecMapSuccess.put(cppName, compProductPriceNametoRecordMap.get(cppName));
                    Pricing_Competitor_Product_Price_Staging__c cppStageToInsert = new Pricing_Competitor_Product_Price_Staging__c();
                    cppStageToInsert.Pricing_Application_Staging_Nm__c = compProductPriceNametoRecordMap.get(cppName).Pricing_Application_Staging_Nm__c;
                    cppStageToInsert.Pricing_Competitor_Product_Name_Staging__c = cppName;
                    cppStageToInsert.Pricing_List_Price_Staging__c = compProductPriceNametoRecordMap.get(cppName).Pricing_List_Price_Staging__c;
                    cppStageToInsert.Pricing_Median_Meet_Comp_Disty_Staging__c = compProductPriceNametoRecordMap.get(cppName).Pricing_Median_Meet_Comp_Disty_Staging__c;
                    cppStageToInsert.Pricing_Region_Staging_Nm__c = compProductPriceNametoRecordMap.get(cppName).Pricing_Region_Staging_Nm__c;
                    cppStageToInsert.Pricing_Final_Meet_Comp_Price_Staging__c = compProductPriceNametoRecordMap.get(cppName).Pricing_Final_Meet_Comp_Price_Staging__c;
                    compProductPricetoInsert.add(cppStageToInsert);
                }
                else{
                    compProdPriceId = '';
                    compProdPriceName = String.isBlank(cppName) ? String.valueOf('') : cppName.escapeCsv();
                    finalMeetCompPrice = (compProductPriceNametoRecordMap.get(cppName).Pricing_Final_Meet_Comp_Price_Staging__c == null) ? null : compProductPriceNametoRecordMap.get(cppName).Pricing_Final_Meet_Comp_Price_Staging__c;
                    listPrice = (compProductPriceNametoRecordMap.get(cppName).Pricing_List_Price_Staging__c == null) ? null : compProductPriceNametoRecordMap.get(cppName).Pricing_List_Price_Staging__c;
                    medianMeetCompDiscount = (compProductPriceNametoRecordMap.get(cppName).Pricing_Median_Meet_Comp_Disty_Staging__c == null) ? null : compProductPriceNametoRecordMap.get(cppName).Pricing_Median_Meet_Comp_Disty_Staging__c;
                    region = String.isBlank(compProductPriceNametoRecordMap.get(cppName).Pricing_Region_Staging_Nm__c) ? String.valueOf('') : compProductPriceNametoRecordMap.get(cppName).Pricing_Region_Staging_Nm__c;
                    application = String.isBlank(compProductPriceNametoRecordMap.get(cppName).Pricing_Application_Staging_Nm__c) ? String.valueOf('') : compProductPriceNametoRecordMap.get(cppName).Pricing_Application_Staging_Nm__c;
                    resMsg = compProdPriceId + ',' + compProdPriceName + ',' + listPrice + ',' + region + ',' + medianMeetCompDiscount + ',' + application + ',' + finalMeetCompPrice + ',';
                    resMsg += errorMsg.removeEnd('; ');
                    errorMsg = '';
                    compProductPriceSuccessErrorMap.put(cppName, resMsg);
                }    
            }
            if(compProductPricetoInsert.size() > 0){
                insert compProductPricetoInsert;
            }
            
            for(Pricing_Competitor_Product_Price_Staging__c stage: compProductPricetoInsert){
                insertedCompProdIds.add(stage.Id);
            }
            
            for(Pricing_Competitor_Product_Price_Staging__c stageRec: [SELECT Id, Pricing_Competitor_Product_Name_Staging__c 
                                                                       FROM Pricing_Competitor_Product_Price_Staging__c WHERE Id IN: insertedCompProdIds]){
                                                                           compProdPriceNameToProdIdMap.put(stageRec.Pricing_Competitor_Product_Name_Staging__c, stageRec.Id);
                                                                       }
            
            if(String.isBlank(errorMsg)){
                for(String cppName : compProductPriceNametoRecMapSuccess.keySet()){
                    if(String.isBlank(resMsg) || !resMsg.contains(cppName)){
                        if(!compProdPriceNameToProdIdMap.isEmpty()){
                            compProdPriceId = (compProdPriceNameToProdIdMap.get(cppName) == null) ? 
                                String.valueOf('') : compProdPriceNameToProdIdMap.get(cppName);
                        }
                        compProdPriceName = String.isBlank(cppName) ? String.valueOf('') : cppName.escapeCsv();
                        finalMeetCompPrice = (compProductPriceNametoRecordMap.get(cppName).Pricing_Final_Meet_Comp_Price_Staging__c == null) ? null : compProductPriceNametoRecordMap.get(cppName).Pricing_Final_Meet_Comp_Price_Staging__c;
                        listPrice = (compProductPriceNametoRecordMap.get(cppName).Pricing_List_Price_Staging__c == null) ? null : compProductPriceNametoRecordMap.get(cppName).Pricing_List_Price_Staging__c;
                        medianMeetCompDiscount = (compProductPriceNametoRecordMap.get(cppName).Pricing_Median_Meet_Comp_Disty_Staging__c == null) ? null : compProductPriceNametoRecordMap.get(cppName).Pricing_Median_Meet_Comp_Disty_Staging__c;
                        region = String.isBlank(compProductPriceNametoRecordMap.get(cppName).Pricing_Region_Staging_Nm__c) ? String.valueOf('') : compProductPriceNametoRecordMap.get(cppName).Pricing_Region_Staging_Nm__c;
                        application = String.isBlank(compProductPriceNametoRecordMap.get(cppName).Pricing_Application_Staging_Nm__c) ? String.valueOf('') : compProductPriceNametoRecordMap.get(cppName).Pricing_Application_Staging_Nm__c;
                        resMsg = compProdPriceId + ',' + compProdPriceName + ',' + listPrice + ',' + region + ',' + medianMeetCompDiscount + ',' + application + ',' + finalMeetCompPrice + ',';
                        resMsg += 'Success';
                        compProductPriceSuccessErrorMap.put(cppName, resMsg);
                    }
                }
            }
        }  
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
        return compProductPriceSuccessErrorMap;
    }
    
    public static Map<string, string> getRegionValues(){
        Map<string, string> values = new Map<string, string>();
        Schema.DescribeFieldResult fResult = Pricing_Competitor_Product_Price_Staging__c.Pricing_Region_Staging_Nm__c.getDescribe();
        // Retrive the list of picklist values for the field
        List<Schema.PicklistEntry> pickValues = fResult.getPicklistValues();
        for (Schema.PicklistEntry p: pickValues) {            
            values.put(p.getValue(), p.getLabel());
        }
        return values;
    }
    
    public static Map<string, string> getApplicationValues(){
        Map<string, string> values = new Map<string, string>();
        Schema.DescribeFieldResult fResult = Pricing_Competitor_Product_Price_Staging__c.Pricing_Application_Staging_Nm__c.getDescribe();
        // Retrive the list of picklist values for the field
        List<Schema.PicklistEntry> pickValues = fResult.getPicklistValues();
        for (Schema.PicklistEntry p: pickValues) {            
            values.put(p.getValue(), p.getLabel());
        }
        return values;
    }
    
    @AuraEnabled
    public static boolean isDPMUser() { 
        //This method is called by LWC to check weather the logged in user is DPM User
        List<PermissionSetAssignment> pset = [SELECT Id, PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND 
                                              PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_PricingDivisionalTenderPricingManager];
        if(pset.size()>0){
            return true;
        }
        return false;   
    }
}