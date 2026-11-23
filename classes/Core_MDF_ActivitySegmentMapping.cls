/*
* Class Name      : Core_MDF_ActivitySegmentMapping
* Test Class Name : Core_MDF_ActivitySegmentMappingTest
* Desc        :
* 
* Modification Log:
* Weezer - Ramapriya R      24/07/2024            Modified getProductMappingForSegment to get products mapped to specific segment                  
*/

public with sharing class Core_MDF_ActivitySegmentMapping {
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getLabelValueMap() {
        Map<String,String> customsLabels = new Map<String,String>();
        try {
            List<String> labels = new List<String>();
            labels.add('Core_MDF_SPIF_Programs');
            customsLabels = Core_MDF_CustomLabelConfig.getBulkTextValues(labels);
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;}
        return customsLabels;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getUltimateAccountId(String accountId) {
        String ultimateAccid = null;
        try {
            SystemOperations sysOp = new SystemOperations();
            ultimateAccid = sysOp.getUltimateAccountId(accountId);
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;}
        return ultimateAccid;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductMappingForAccount(String accountId, String program ) {
        List<Product2> productList = new List<Product2>();
        try {
            program = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(program);
            SystemOperations sysOp = new SystemOperations();
            accountId = sysOp.getUltimateAccountId(accountId);
            List<Core_MDF_Account_Product_Mapping__c> apmList = sysOp.getProductMappingsForAccount(accountId, program);
           
            for(Core_MDF_Account_Product_Mapping__c apm : apmList) {
                Product2 prdObj = new Product2();
                prdObj.Id = apm.Core_MDF_Product__c;
                prdObj.Name = apm.Core_MDF_Product__r.Name;
                prdObj.Core_Product_Family__c = apm.Core_MDF_Product_Family_nm__c;
                productList.add(prdObj);
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;}
        
        return productList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductMappingForSegment(String segment, String accountId, String program){
        List<Product2> productList = new List<Product2>();
        try {
            program = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(program);
            List<Core_MDF_Account_Product_Mapping__c> apmListForAcc = new List<Core_MDF_Account_Product_Mapping__c>();
            if(String.isNotBlank(segment) && String.isNotBlank(accountId)) {
                SystemOperations sysOp = new SystemOperations();
                apmListForAcc = sysOp.getProductMappingsForAccount(accountId, program);
                List<Core_MDF_Account_Product_Mapping__c> apmList = sysOp.getAccountProductMappings(segment, accountId, program);
                for(Core_MDF_Account_Product_Mapping__c apm : apmList) {
                    Product2 prdObj = new Product2();
                    prdObj.Id = apm.Core_MDF_Product__c;
                    prdObj.Name = apm.Core_MDF_Product__r.Name;
                    prdObj.Core_Product_Family__c = apm.Core_MDF_Product_Family_nm__c;
                    productList.add(prdObj);
                }
            }
            if(String.isBlank(accountId) || (apmListForAcc != null && apmListForAcc.isEmpty())) {
                productList = getProductMappingForSegment(segment);
            }
        }
        catch(Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp); return null;
        }
        return productList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductMappingForSegment(String segment){
        
        List<Product2> productList = new List<Product2>();
        try{
            /*if('Processors'.equalsIgnoreCase(segment)){
                productList = [SELECT Id,Core_Processor_Number_Nm__c, Core_Product_Family__c, Name
                               FROM Product2 
                               WHERE Core_Product_Type__c =: segment
                               AND (Core_Product_Status__c like '%AC%' OR Core_Product_Status__c LIKE '%PA%' OR Core_Product_Status__c LIKE '%EN%')
                               AND isactive = true AND Core_Hierarchy_ID__c = '43' AND Core_End_of_Intel_Service_Flag__c = false
                               AND Core_Sales_Visible_Flag__c = true
                               ORDER BY Core_Product_Family__c, Name];
            }else{
                productList = [SELECT Id, Core_Product_Family__c, Name
                               FROM Product2 
                               WHERE Core_Product_Type__c =: segment
                               AND isactive = true AND Core_Hierarchy_ID__c = '43' AND Core_End_of_Intel_Service_Flag__c = false
                               AND Core_Sales_Visible_Flag__c = true
                               ORDER BY Core_Product_Family__c, Name];
           }*/
            //to get the list of products for a given segment
            productList = Core_MDF_AccountProductMappingController.retrieveProductsUsingDynamicQuery(segment);
            return productList;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;} 
        
    }
    //Localisation Fix  Changes
    @AuraEnabled(cacheable=true)
    public static List<SegmentPicklistWrapper> getSegmentValues(){
        try{
            List<SegmentPicklistWrapper> segmentWrapperList = new List<SegmentPicklistWrapper>();
            Schema.DescribeFieldResult fieldResult = Core_MDF_Activity_Segment_Mapping__c.Core_MDF_Segment_Name_nm__c.getDescribe();
            List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry p: pList) {
                SegmentPicklistWrapper spw = new SegmentPicklistWrapper();
                spw.segmentLabel = p.getLabel();
                spw.segmentApi = p.getValue();
                segmentWrapperList.add(spw); 
            }
            return segmentWrapperList;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;} 
    }
    
    @AuraEnabled
    public static InitialDetailWrapper  getFieldsToDisplay(String program, String activityType){			  
        try{
            Core_MDF_ActivitySegmentMapping.InitialDetailWrapper InitialDetail = new Core_MDF_ActivitySegmentMapping.InitialDetailWrapper();
            List<Core_MDF_CCP_SegmentField__c> fieldList = [SELECT Core_MDF_Activity_Type_txt__c, Core_MDF_Data_Type_txt__c, Core_MDF_Field_API_Name_txt__c,
                                                               Core_MDF_Field_Label_Name_txt__c, Core_MDF_Order_nbr__c, Core_MDF_Program_nm__c, Core_MDF_Active_ind__c,
                                                               Core_MDF_Maximum_Length_nbr__c
                                                               FROM Core_MDF_CCP_SegmentField__c
                                                               WHERE Core_MDF_Program_nm__c =: program AND
                                                               Core_MDF_Activity_Type_txt__c =: activityType AND
                                                               Core_MDF_Active_ind__c = TRUE
                                                               ORDER By Core_MDF_Order_nbr__c];
            InitialDetail.SegmentFields = fieldList;
            InitialDetail.UserType = UserInfo.getUserType();
            return InitialDetail;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;} 
    }
    
    @AuraEnabled
    public static SegmentWrapper returnSegments(Id recordId){
        try{
            Core_MDF_ActivitySegmentMapping.SegmentWrapper wrapper = new Core_MDF_ActivitySegmentMapping.SegmentWrapper();
            if(recordId != NULL){
                String recId = String.valueof(recordId);
                if(recId.startsWith('0RJ')) {
                    wrapper = getSegmentForActivity(recordId);
                } else if(recId.startsWith('0RB')) {
                    wrapper = getSegmentForClaims(recordId);
                }
            }
            return wrapper;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;} 
    }
    
    @AuraEnabled
    public static SegmentWrapper getSegmentForClaims(Id claimId){
        try{
            Core_MDF_ActivitySegmentMapping.SegmentWrapper wrapper = new Core_MDF_ActivitySegmentMapping.SegmentWrapper();
            	List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            	Id RequestId;
                if(claimId!=null){
            	//PartnerFundClaim claim = [SELECT Id, RequestId FROM PartnerFundClaim WHERE Id =: claimId];
            	 	claimList = [SELECT Id, RequestId FROM PartnerFundClaim WHERE Id =: claimId];
                }
            	if(!claimList.isEmpty()){
                    wrapper = getSegmentForActivity(claimList[0].RequestId);
       			 }
            return wrapper;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;} 
    }
    
    @AuraEnabled
    public static SegmentWrapper getSegmentForActivity(Id activityId){
        
        try{
            Map<String, List<Core_MDF_Segment_Product_Mapping__c>> productMap = new Map<String, List<Core_MDF_Segment_Product_Mapping__c>>();
            Core_MDF_ActivitySegmentMapping.InitialDetailWrapper InitialDetails = new Core_MDF_ActivitySegmentMapping.InitialDetailWrapper();
            Core_MDF_ActivitySegmentMapping.SegmentWrapper wrapper = new Core_MDF_ActivitySegmentMapping.SegmentWrapper();
            List<Core_MDF_CCP_SegmentField__c> segmentFieldResult = new List<Core_MDF_CCP_SegmentField__c>();
            List<Core_MDF_Segment_Product_Mapping__c> prodList = new List<Core_MDF_Segment_Product_Mapping__c>();
            List<Core_MDF_Activity_Segment_Mapping__c> asmList = [SELECT Id, Core_MDF_Segment_Name_nm__c, Core_MDF_Activity_Type_txt__c,
                                                                  toLabel(Core_MDF_Segment_Name_nm__c) Core_MDF_Segment_Name,
                                                                  Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c, Core_MDF_SPIF_Notes_internal_only_txt__c,
                                                                  Core_MDF_Partner_Fund_Request_id__r.Core_MDF_Activity_Types__c,
                                                                  Core_MDF_Partner_Fund_Request_id__r.Core_MDF_Program__c,
                                                              	  Core_MDF_Partner_Fund_Request_id__r.Core_MDF_Tactics_nm__c,
                                                              	  Core_MDF_Minimum_Forecast_Volume_nbr__c,Core_MDF_Estimated_Share_of_SPIF_amt__c,
                                                                  Core_MDF_Maximum_Bundled_Volume_nbr__c,Core_MDF_Maximum_Cost_of_Bundle_nbr__c, Core_MDF_SPIF_Notes_txt__c 
                                                                  FROM Core_MDF_Activity_Segment_Mapping__c
                                                                  WHERE Core_MDF_Partner_Fund_Request_id__c =: activityId AND Core_MDF_Active_ind__c = true];
            for(Core_MDF_Segment_Product_Mapping__c spm : [SELECT Id, Core_MDF_Product_id__c, Core_MDF_Active_Ind__c, Core_MDF_Activity_Segment_Mapping_id__c,
                                                           Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Segment_Name_nm__c, Core_MDF_Product_Name_txt__c, Core_MDF_Product_Family__c 
                                                           FROM Core_MDF_Segment_Product_Mapping__c
                                                           WHERE Core_MDF_Active_Ind__c = TRUE AND
                                                           Core_MDF_Activity_Segment_Mapping_id__c IN: asmList]){
                                                               
                                                               if(productMap.containsKey(spm.Core_MDF_Activity_Segment_Mapping_id__c)){
                                                                   productMap.get(spm.Core_MDF_Activity_Segment_Mapping_id__c).add(spm);
                                                               }else{
                                                                   productMap.put(spm.Core_MDF_Activity_Segment_Mapping_id__c, new List<Core_MDF_Segment_Product_Mapping__c>{spm});
                                                               }
                                                               
                                                               prodList.add(spm);
                                                           }
           if(asmList != NULL && asmList.Size() > 0){

        
        String tactics = asmList[0].Core_MDF_Partner_Fund_Request_id__r.Core_MDF_Tactics_nm__c;
           Boolean tacticsHasIncentive=false;
           //Ramapriya - when selected tactics contain Incentive set tacticsHasIncentive to True
           if (tactics != null && String.isNotBlank(tactics)) {
               List<String> tacticsList = tactics.split(';');
               
               tacticsHasIncentive = tacticsList.contains(System.Label.Core_MDF_Spif_Tactics) ?true:false;
           }
        
           //  Ramapriya - Deactivating ASM records, when Activity Type is Outcome Based and Tactics doesn't contain Incentive
        if(asmList[0].Core_MDF_Partner_Fund_Request_id__r.Core_MDF_Activity_Types__c==System.Label.Core_MDF_Outcome_Based_CatType && !tacticsHasIncentive){

            List<Core_MDF_Activity_Segment_Mapping__c> asmToUpdate = new List<Core_MDF_Activity_Segment_Mapping__c>();
           
               for(Core_MDF_Activity_Segment_Mapping__c asm : asmList){
                   Core_MDF_Activity_Segment_Mapping__c asmUpdate = new Core_MDF_Activity_Segment_Mapping__c();
                   asmUpdate.Id = asm.Id;
                   asmUpdate.Core_MDF_Active_ind__c = false;
                   asmToUpdate.add(asmUpdate);
               }
               
               if(!asmToUpdate.isEmpty()){
                   SystemOperations sysOp = new SystemOperations();
                   sysOp.upsertActivitySegments(asmToUpdate);
               }
        }
          else{
           InitialDetails = getFieldsToDisplay(asmList[0].Core_MDF_Partner_Fund_Request_id__r.Core_MDF_Program__c,
                                                           asmList[0].Core_MDF_Partner_Fund_Request_id__r.Core_MDF_Activity_Types__c);
            segmentFieldResult = InitialDetails.SegmentFields;
          }
        }
                                                                  
            wrapper.fieldsToDisplay = segmentFieldResult;
            wrapper.segmentList = asmList;
            wrapper.segmentProductMap = productMap;
            wrapper.productList = prodList;
            wrapper.userType = UserInfo.getUserType();
            return wrapper;

          

        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;} 
    }
	@auraEnabled
    public static string getRecordTypeLabelByName(String recTypeName){
        String recTypeLabel='';       
        try {          
                List<RecordType> recList = [SELECT Name 
                                            FROM RecordType                                                  
                                            WHERE (SobjectType='PartnerFundRequest' and DeveloperName =: recTypeName)
                                            LIMIT 1];
                if(recList != null && !recList.isEmpty()){
                    recTypeLabel = recList[0].Name;
                }
            }
         catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e); return null;}
        return recTypeLabel;
    }
        
    @future
    public static void createUpdateSegmentAndProductMappingRecords(Id pfrId, String segmentProductString) {
        try{
            List<Core_MDF_SegmentParser> parsedSegmentList = new List<Core_MDF_SegmentParser>();
            Map<String, Core_MDF_SegmentParser> segParseMap = new Map<String, Core_MDF_SegmentParser>();
            Map<String, Core_MDF_Segment_Product_Mapping__c> newSegmentIdProdIdMap = new Map<String, Core_MDF_Segment_Product_Mapping__c>();
            Map<String, Core_MDF_Segment_Product_Mapping__c> existingSegmentIdProdIdMap = new Map<String, Core_MDF_Segment_Product_Mapping__c>();        
            Map<String, Core_MDF_Activity_Segment_Mapping__c> existingSegmentsNameMap = new Map<String, Core_MDF_Activity_Segment_Mapping__c>();
            Map<String, Core_MDF_Activity_Segment_Mapping__c> newSegmentNameMap = new Map<String, Core_MDF_Activity_Segment_Mapping__c>();
            Map<Id, List<Core_MDF_Segment_Product_Mapping__c>> existingSegmentProductsLstMap = new Map<Id, List<Core_MDF_Segment_Product_Mapping__c>>();
            Map<Id, Core_MDF_Activity_Segment_Mapping__c> existingSegmentsMap = new Map<Id, Core_MDF_Activity_Segment_Mapping__c>([select Id, Core_MDF_Partner_Fund_Request_id__c, Core_MDF_Segment_Name_nm__c, Core_MDF_Active_ind__c,Core_MDF_Minimum_Forecast_Volume_nbr__c,Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c,Core_MDF_Estimated_Share_of_SPIF_amt__c, Core_MDF_Maximum_Bundled_Volume_nbr__c, Core_MDF_SPIF_Notes_internal_only_txt__c, Core_MDF_SPIF_Notes_txt__c   from Core_MDF_Activity_Segment_Mapping__c where Core_MDF_Partner_Fund_Request_id__c = :pfrId]);
            SystemOperations sysOp = new SystemOperations();
            if(!existingSegmentsMap.isEmpty()) {
                for(Id segmentId : existingSegmentsMap.keySet()) {
                    Core_MDF_Activity_Segment_Mapping__c asm = new Core_MDF_Activity_Segment_Mapping__c();
                    asm.Id = segmentId;
                    asm.Core_MDF_Segment_Name_nm__c= existingSegmentsMap.get(segmentId).Core_MDF_Segment_Name_nm__c; 
                    asm.Core_MDF_Minimum_Forecast_Volume_nbr__c= existingSegmentsMap.get(segmentId).Core_MDF_Minimum_Forecast_Volume_nbr__c; 
                    asm.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c= existingSegmentsMap.get(segmentId).Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c; 
                    asm.Core_MDF_Estimated_Share_of_SPIF_amt__c= existingSegmentsMap.get(segmentId).Core_MDF_Estimated_Share_of_SPIF_amt__c;  
                    asm.Core_MDF_Maximum_Bundled_Volume_nbr__c= existingSegmentsMap.get(segmentId).Core_MDF_Maximum_Bundled_Volume_nbr__c;  
                    asm.Core_MDF_SPIF_Notes_internal_only_txt__c= existingSegmentsMap.get(segmentId).Core_MDF_SPIF_Notes_internal_only_txt__c; 
                    asm.Core_MDF_SPIF_Notes_txt__c= existingSegmentsMap.get(segmentId).Core_MDF_SPIF_Notes_txt__c; 
                    asm.Core_MDF_Active_ind__c = false;
                    existingSegmentsNameMap.put(segmentId, asm);
                }
                for(Core_MDF_Segment_Product_Mapping__c segProdMap :  [select Id, Core_MDF_Active_Ind__c, Core_MDF_Activity_Segment_Mapping_id__c, Core_MDF_Product_id__c from Core_MDF_Segment_Product_Mapping__c where Core_MDF_Activity_Segment_Mapping_id__c IN :existingSegmentsMap.keySet()]) {
                    String keyStr1 = ''+segProdMap.Core_MDF_Activity_Segment_Mapping_id__c+'$'+segProdMap.Core_MDF_Product_id__c;                    
                    Core_MDF_Segment_Product_Mapping__c spm = new Core_MDF_Segment_Product_Mapping__c();
                    spm.Id = segProdMap.Id;
                    spm.Core_MDF_Active_ind__c = false;
                    spm.Core_MDF_Product_id__c = segProdMap.Core_MDF_Product_id__c;
                    existingSegmentIdProdIdMap.put(keyStr1, spm);
                }
            }
            if(String.isNotBlank(segmentProductString)){
                parsedSegmentList = Core_MDF_SegmentParser.parse(segmentProductString);
            }
            if(parsedSegmentList != NULL) {
                for(Core_MDF_SegmentParser segParse : parsedSegmentList) {
                    Core_MDF_Activity_Segment_Mapping__c asm = new Core_MDF_Activity_Segment_Mapping__c();
                    asm.Core_MDF_Minimum_Forecast_Volume_nbr__c = null;
                    asm.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = null;
                    asm.Core_MDF_Estimated_Share_of_SPIF_amt__c = null;
                    asm.Core_MDF_Maximum_Cost_of_Bundle_nbr__c = null;
                    asm.Core_MDF_Maximum_Bundled_Volume_nbr__c = null;
                    if(!existingSegmentsNameMap.isEmpty() && existingSegmentsNameMap.containsKey(segParse.segmentId) ) {
                        asm.Id = existingSegmentsNameMap.get(segParse.segmentId).Id;
                        asm.Core_MDF_Segment_Name_nm__c = segParse.Core_MDF_Segment_Name_nm;
                        if(segParse.Core_MDF_Minimum_Forecast_Volume_nbr != null) {
                            existingSegmentsNameMap.get(segParse.segmentId).Core_MDF_Minimum_Forecast_Volume_nbr__c = decimal.valueOf(segParse.Core_MDF_Minimum_Forecast_Volume_nbr);
                        }                
                        if(segParse.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr != null) {
                            existingSegmentsNameMap.get(segParse.segmentId).Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = decimal.valueOf(segParse.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr);
                        }                
                        if(segParse.Core_MDF_Estimated_Share_of_SPIF_amt != null) {
                            existingSegmentsNameMap.get(segParse.segmentId).Core_MDF_Estimated_Share_of_SPIF_amt__c = decimal.valueOf(segParse.Core_MDF_Estimated_Share_of_SPIF_amt).setScale(2,System.RoundingMode.HALF_UP);
                        }            
                        if(segParse.Core_MDF_Maximum_Cost_of_Bundle_nbr != null) {
                            existingSegmentsNameMap.get(segParse.segmentId).Core_MDF_Maximum_Cost_of_Bundle_nbr__c = decimal.valueOf(segParse.Core_MDF_Maximum_Cost_of_Bundle_nbr);
                        }
                        if(segParse.Core_MDF_Maximum_Bundled_Volume_nbr != null) {
                            existingSegmentsNameMap.get(segParse.segmentId).Core_MDF_Maximum_Bundled_Volume_nbr__c = decimal.valueOf(segParse.Core_MDF_Maximum_Bundled_Volume_nbr);
                        }
                        existingSegmentsNameMap.get(segParse.segmentId).Core_MDF_SPIF_Notes_internal_only_txt__c = segParse.Core_MDF_SPIF_Notes_internal_only_txt;
                        existingSegmentsNameMap.get(segParse.segmentId).Core_MDF_SPIF_Notes_txt__c = segParse.Core_MDF_SPIF_Notes_txt;
                        existingSegmentsNameMap.get(segParse.segmentId).Core_MDF_Active_ind__c = true;
                    }
                    else {
                        asm.Core_MDF_Partner_Fund_Request_id__c = pfrId;
                        asm.Core_MDF_Segment_Name_nm__c = segParse.Core_MDF_Segment_Name_nm;
                        if(segParse.Core_MDF_Minimum_Forecast_Volume_nbr != null){
                            asm.Core_MDF_Minimum_Forecast_Volume_nbr__c = decimal.valueOf(segParse.Core_MDF_Minimum_Forecast_Volume_nbr);
                        }                
                        if(segParse.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr != null){
                            asm.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = decimal.valueOf(segParse.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr);
                        }                
                        if(segParse.Core_MDF_Estimated_Share_of_SPIF_amt != null){
                            asm.Core_MDF_Estimated_Share_of_SPIF_amt__c = decimal.valueOf(segParse.Core_MDF_Estimated_Share_of_SPIF_amt).setScale(2,System.RoundingMode.HALF_UP);
                        }            
                        if(segParse.Core_MDF_Maximum_Cost_of_Bundle_nbr != null){
                            asm.Core_MDF_Maximum_Cost_of_Bundle_nbr__c = decimal.valueOf(segParse.Core_MDF_Maximum_Cost_of_Bundle_nbr);
                        }
                        if(segParse.Core_MDF_Maximum_Bundled_Volume_nbr != null){
                            asm.Core_MDF_Maximum_Bundled_Volume_nbr__c = decimal.valueOf(segParse.Core_MDF_Maximum_Bundled_Volume_nbr);
                        }
                        asm.Core_MDF_SPIF_Notes_internal_only_txt__c = segParse.Core_MDF_SPIF_Notes_internal_only_txt;
                        asm.Core_MDF_SPIF_Notes_txt__c = segParse.Core_MDF_SPIF_Notes_txt;
                        asm.Core_MDF_Active_ind__c = TRUE;
                        newSegmentNameMap.put(segParse.segmentId, asm);
                    }			
                    segParseMap.put(segParse.segmentId, segParse);				
                }
                if(existingSegmentsNameMap != null && !existingSegmentsNameMap.isEmpty()) {
                    newSegmentNameMap.putAll(existingSegmentsNameMap);
                }
            }
            
            if(newSegmentNameMap!=null && !newSegmentNameMap.isEmpty()) { 
                sysOp.upsertActivitySegments(newSegmentNameMap.values());
            }
            
            if(newSegmentNameMap != null && !newSegmentNameMap.isEmpty() && segParseMap != null && !segParseMap.isEmpty()) {
                for(String asmName : newSegmentNameMap.keySet()){
                    if(segParseMap.containsKey(asmName) && segParseMap.get(asmName) != null ) {
                        for(Id productId : segParseMap.get(asmName).productIdSet){ 
                            String keyStr2 = ''+newSegmentNameMap.get(asmName).Id+'$'+productId;
                            Core_MDF_Segment_Product_Mapping__c spm = new Core_MDF_Segment_Product_Mapping__c();
                            if(existingSegmentIdProdIdMap.containsKey(keyStr2)) {
                                spm.Id = existingSegmentIdProdIdMap.get(keyStr2).Id;
                                spm.Core_MDF_Product_id__c = String.valueOf(productId);
                                spm.Core_MDF_Active_Ind__c = TRUE;
                                existingSegmentIdProdIdMap.put(keyStr2,spm);
                            }
                            else {
                                spm.Core_MDF_Activity_Segment_Mapping_id__c = newSegmentNameMap.get(asmName).Id;
                                spm.Core_MDF_Product_id__c = String.valueOf(productId);
                                spm.Core_MDF_Active_Ind__c = TRUE;
                                newSegmentIdProdIdMap.put(keyStr2, spm);
                            }
                            
                        }
                    }
                }
                if(existingSegmentIdProdIdMap!=null && !existingSegmentIdProdIdMap.isEmpty()){ 
                    newSegmentIdProdIdMap.putAll(existingSegmentIdProdIdMap);
                }
            }
            if(newSegmentIdProdIdMap != NULL && !newSegmentIdProdIdMap.isEmpty()){
                sysOp.upsertActivitySegmentsProductMapping(newSegmentIdProdIdMap.values());
            }
    } catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e); } 
    }
    
    public class SegmentWrapper{
        @AuraEnabled
        public List<Core_MDF_Activity_Segment_Mapping__c> segmentList;        
        
        @AuraEnabled
        public Map<String, List<Core_MDF_Segment_Product_Mapping__c>> segmentProductMap;
        
        @AuraEnabled
        public List<Core_MDF_Segment_Product_Mapping__c> productList;
        
        @AuraEnabled
        public List<Core_MDF_CCP_SegmentField__c> fieldsToDisplay;
        
         @AuraEnabled
        public String userType {get;set;}
        
    }

    public class SegmentPicklistWrapper{
        @AuraEnabled public String segmentLabel {get;set;}
        @AuraEnabled public String segmentApi {get;set;}
    }

    public without sharing class SystemOperations {

        public void upsertActivitySegments(List<Core_MDF_Activity_Segment_Mapping__c> recList) {
            try {
                upsert recList;
            } catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e); } 
            
        }
        
        public void upsertActivitySegmentsProductMapping(List<Core_MDF_Segment_Product_Mapping__c> recList) {           
            try {
                upsert recList;
            } catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e); } 
        }
        
        public List<Core_MDF_Account_Product_Mapping__c> getAccountProductMappings(String segment, String accountId, String program) {
            Map<string,Core_MDF_Account_Product_Mapping__c> productIdToApmMap = new Map<string,Core_MDF_Account_Product_Mapping__c>();
            List<Core_MDF_Account_Product_Mapping__c> apmList = new List<Core_MDF_Account_Product_Mapping__c>();
            set<Id> inActiveProdIdSet = new set<Id>();
            for(Core_MDF_Account_Product_Mapping__c apm: [SELECT Id, Name, Core_MDF_Account__c,  Core_MDF_Product_Type_txt__c,Core_MDF_Product__c, Core_MDF_Product__r.Name,Core_MDF_Active_ind__c,
                                                          Core_MDF_Product_Family_nm__c,Core_MDF_All_Account_Ind__c 
                                                          FROM Core_MDF_Account_Product_Mapping__c 
                                                          WHERE (Core_MDF_Account__c =: accountId OR Core_MDF_All_Account_Ind__c = true) 
                                                          AND Core_MDF_Product_Type_txt__c =: segment 
                                                          AND Core_MDF_Program_Account_Map__c = :program]){
                                                              if(apm.Core_MDF_All_Account_Ind__c && string.isBlank(apm.Core_MDF_Account__c) && apm.Core_MDF_Active_ind__c){
                                                                  productIdToApmMap.put(apm.Core_MDF_Product__c,apm);
                                                              }else{
                                                                  if(apm.Core_MDF_Active_ind__c){
                                                                      apmList.add(apm);
                                                                  }else{
                                                                      inActiveProdIdSet.add(apm.Core_MDF_Product__c);
                                                                  }
                                                              }
                                                          }
            
            
            if(apmList.isEmpty()){
                if(productIdToApmMap != null && !productIdToApmMap.isEmpty()){
                    for(Core_MDF_Account_Product_Mapping__c apm:  productIdToApmMap.values()){
                        /*if(!inActiveProdIdSet.contains(apm.Core_MDF_Product__c)){
                            apmList.add(apm);
                        }*/
			apmList.add(apm);
                    } 
                } 
            } 
            
            return apmList;
        }
        
        public List<Core_MDF_Account_Product_Mapping__c> getProductMappingsForAccount(String accountId, String program) {
            Map<string,Core_MDF_Account_Product_Mapping__c> productIdToApmMap = new Map<string,Core_MDF_Account_Product_Mapping__c>();
            List<Core_MDF_Account_Product_Mapping__c> apmList = new List<Core_MDF_Account_Product_Mapping__c>();
            
            for(Core_MDF_Account_Product_Mapping__c apm: [SELECT Id, Name, Core_MDF_Account__c,  Core_MDF_Product_Type_txt__c, Core_MDF_Product__r.Name, Core_MDF_Product_Family_nm__c,Core_MDF_All_Account_Ind__c
                                                          FROM Core_MDF_Account_Product_Mapping__c 
                                                          WHERE Core_MDF_Active_ind__c = true 
                                                          AND (Core_MDF_Account__c = :accountId OR Core_MDF_All_Account_Ind__c	= true) 
                                                          AND Core_MDF_Program_Account_Map__c = :program]){
                                                              if(apm.Core_MDF_All_Account_Ind__c){
                                                                  productIdToApmMap.put(apm.Core_MDF_Product__c,apm);
                                                              }else{
                                                                  apmList.add(apm);
                                                              }   
                                                          }
            
            if(apmList.isEmpty()){
                apmList = (productIdToApmMap != null && !productIdToApmMap.isEmpty()) ? productIdToApmMap.values() : new List<Core_MDF_Account_Product_Mapping__c>();
            }  
            
            return apmList;
        }
        
        public String getUltimateAccountId(String accountId) {
            Account accObj = [SELECT id, Core_MDF_CoMarketing_Ultimate_Account__c from Account where ID = :accountId];
            return accObj.Core_MDF_CoMarketing_Ultimate_Account__c;
        }
    }
   public class InitialDetailWrapper{
       @AuraEnabled
       public List<Core_MDF_CCP_SegmentField__c> SegmentFields {get;set;}
        @AuraEnabled
        public String UserType {get;set;}	
    }
}