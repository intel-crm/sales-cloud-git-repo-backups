/*
* Class Name      : Core_MDF_ActivitySegmentMapping
* Test Class Name : Core_MDF_ActivitySegmentMappingTest
* Desc 		   :
* 
* Modification Log:
*/

public with sharing class SegmentMapping {
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductMappingForSegment(String segment){
        
        List<Product2> productList = new List<Product2>();
        try{
            if('Processors'.equalsIgnoreCase(segment)){
                productList = [SELECT Id,Core_Processor_Number_Nm__c, Core_Product_Family__c, Name
                               FROM Product2 
                               WHERE Core_Product_Type__c =: segment
                               AND (Core_Product_Status__c like '%AC%' OR Core_Product_Status__c LIKE '%PA%' OR Core_Product_Status__c LIKE '%EN%')
                               AND isactive = true AND Core_Hierarchy_ID__c = '43'
                               ORDER BY Core_Product_Family__c];
            }else{
                productList = [SELECT Id, Core_Product_Family__c, Name
                               FROM Product2 
                               WHERE Core_Product_Type__c =: segment
                               AND isactive = true AND Core_Hierarchy_ID__c = '43'
                               ORDER BY Core_Product_Family__c];
            }
            
            return productList;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;} 
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SegmentPicklistWrapper> getSegmentValues(){
    //public static List<String> getSegmentValues(){
        try{
            //List<String> options = new List<String>();
            List<SegmentPicklistWrapper> segmentWrapperList = new List<SegmentPicklistWrapper>();
            Schema.DescribeFieldResult fieldResult = Core_MDF_Activity_Segment_Mapping__c.Core_MDF_Segment_Name_nm__c.getDescribe();
            List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry p: pList) {
                SegmentPicklistWrapper spw = new SegmentPicklistWrapper();
                spw.segmentLabel = p.getLabel();
                spw.segmentApi = p.getValue();
                segmentWrapperList.add(spw); 
                //options.add(p.getValue());
                //options.add(p.getLabel());
            }
            //return options;
            return segmentWrapperList;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;} 
    }
    
    @AuraEnabled
    public static List<Core_MDF_CCP_Segment_Field__mdt> getFieldsToDisplay(String program, String activityType){
        try{
            List<Core_MDF_CCP_Segment_Field__mdt> fieldList = [SELECT Core_MDF_Activity_Type_txt__c, Core_MDF_Data_Type_txt__c, Core_MDF_Field_API_Name_txt__c,
                                                               Core_MDF_Field_Label_Name_txt__c, Core_MDF_Order_nbr__c, Core_MDF_Program_nm__c, Core_MDF_Active_ind__c,
                                                               Core_MDF_Maximum_Length_nbr__c
                                                               FROM Core_MDF_CCP_Segment_Field__mdt
                                                               WHERE Core_MDF_Program_nm__c =: program AND
                                                               Core_MDF_Activity_Type_txt__c =: activityType AND
                                                               Core_MDF_Active_ind__c = TRUE
                                                               ORDER By Core_MDF_Order_nbr__c];
            return fieldList;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;} 
    }
    
    @AuraEnabled
    public static SegmentWrapper returnSegments(Id recordId){
        try{
            SegmentMapping.SegmentWrapper wrapper = new SegmentMapping.SegmentWrapper();
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
            SegmentMapping.SegmentWrapper wrapper = new SegmentMapping.SegmentWrapper();
            PartnerFundClaim claim = [SELECT Id, RequestId FROM PartnerFundClaim WHERE Id =: claimId];
            wrapper = getSegmentForActivity(claim.RequestId);
            return wrapper;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;} 
    }
    
    @AuraEnabled
    public static SegmentWrapper getSegmentForActivity(Id activityId){
        
        try{
            Map<String, List<Core_MDF_Segment_Product_Mapping__c>> productMap = new Map<String, List<Core_MDF_Segment_Product_Mapping__c>>();
            SegmentMapping.SegmentWrapper wrapper = new SegmentMapping.SegmentWrapper();
            List<Core_MDF_Segment_Product_Mapping__c> prodList = new List<Core_MDF_Segment_Product_Mapping__c>();
            //List<String> spifActTypeList = System.Label.Core_MDF_SPIF_Activity_Types.split(';');
            List<Core_MDF_Activity_Segment_Mapping__c> asmList = [SELECT Id, Core_MDF_Segment_Name_nm__c, Core_MDF_Activity_Type_txt__c,
                                                                  toLabel(Core_MDF_Segment_Name_nm__c) Core_MDF_Segment_Name,
                                                                  Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c, Core_MDF_SPIF_Notes_internal_only_txt__c,
                                                                  Core_MDF_Partner_Fund_Request_id__r.Core_MDF_Activity_Types__c,
                                                                  Core_MDF_Partner_Fund_Request_id__r.Core_MDF_Program__c,
                                                                  Core_MDF_Minimum_Forecast_Volume_nbr__c,Core_MDF_Estimated_Share_of_SPIF_amt__c,
                                                                  Core_MDF_Maximum_Bundled_Volume_nbr__c,Core_MDF_Maximum_Cost_of_Bundle_nbr__c, Core_MDF_SPIF_Notes_txt__c,Core_MDF_Num_of_Expected_Participants__c,Core_MDF_Num_of_Potential_Winners__c 
                                                                  FROM Core_MDF_Activity_Segment_Mapping__c
                                                                  WHERE Core_MDF_Partner_Fund_Request_id__c =: activityId AND Core_MDF_Active_ind__c = true]; //AND Core_MDF_Partner_Fund_Request_id__r.Core_MDF_Activity_Types__c IN :spifActTypeList
            for(Core_MDF_Segment_Product_Mapping__c spm : [SELECT Id, Core_MDF_Product_id__c, Core_MDF_Active_Ind__c, Core_MDF_Activity_Segment_Mapping_id__c,
                                                           Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Segment_Name_nm__c, Core_MDF_Product_Name_txt__c, Core_MDF_Product_Family__c 
                                                           FROM Core_MDF_Segment_Product_Mapping__c
                                                           WHERE Core_MDF_Active_Ind__c = TRUE AND
                                                           Core_MDF_Activity_Segment_Mapping_id__c IN: asmList]){
                                                               /*if(productMap.containsKey(spm.Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Segment_Name_nm__c)){
                                                                   productMap.get(spm.Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Segment_Name_nm__c).add(spm);
                                                               }else{
                                                                   productMap.put(spm.Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Segment_Name_nm__c, new List<Core_MDF_Segment_Product_Mapping__c>{spm});
                                                               }*/
                                                               if(productMap.containsKey(spm.Core_MDF_Activity_Segment_Mapping_id__c)){
                                                                   productMap.get(spm.Core_MDF_Activity_Segment_Mapping_id__c).add(spm);
                                                               }else{
                                                                   productMap.put(spm.Core_MDF_Activity_Segment_Mapping_id__c, new List<Core_MDF_Segment_Product_Mapping__c>{spm});
                                                               }
                                                             /*  if(productMap.containsKey(spm.Core_MDF_Segment_Name)){
                                                                   productMap.get(spm.Core_MDF_Segment_Name).add(spm);
                                                               }else{
                                                                   productMap.put(spm.Core_MDF_Segment_Name, new List<Core_MDF_Segment_Product_Mapping__c>{spm});
                                                               }*/
                                                               
                                                               prodList.add(spm);
                                                           }
            
            if(asmList != NULL && asmList.Size() > 0){
                wrapper.fieldsToDisplay = getFieldsToDisplay(asmList[0].Core_MDF_Partner_Fund_Request_id__r.Core_MDF_Program__c,
                                                             asmList[0].Core_MDF_Partner_Fund_Request_id__r.Core_MDF_Activity_Types__c); 
            }                                                        
            
            wrapper.segmentList = asmList;
            wrapper.segmentProductMap = productMap;
            wrapper.productList = prodList;
            return wrapper;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return null;} 
    }
    
    @future
    public static void createUpdateSegmentAndProductMappingRecords(Id pfrId, String segmentProductString) {
        try{
            System.debug('segmentProductString '+segmentProductString);
            List<Core_MDF_SegmentParser> parsedSegmentList = new List<Core_MDF_SegmentParser>();
            Map<String, Core_MDF_SegmentParser> segParseMap = new Map<String, Core_MDF_SegmentParser>();
            Map<String, Core_MDF_Segment_Product_Mapping__c> newSegmentIdProdIdMap = new Map<String, Core_MDF_Segment_Product_Mapping__c>();
            Map<String, Core_MDF_Segment_Product_Mapping__c> existingSegmentIdProdIdMap = new Map<String, Core_MDF_Segment_Product_Mapping__c>();        
            Map<String, Core_MDF_Activity_Segment_Mapping__c> existingSegmentsNameMap = new Map<String, Core_MDF_Activity_Segment_Mapping__c>();
            Map<String, Core_MDF_Activity_Segment_Mapping__c> newSegmentNameMap = new Map<String, Core_MDF_Activity_Segment_Mapping__c>();
            Map<Id, List<Core_MDF_Segment_Product_Mapping__c>> existingSegmentProductsLstMap = new Map<Id, List<Core_MDF_Segment_Product_Mapping__c>>();
            Map<Id, Core_MDF_Activity_Segment_Mapping__c> existingSegmentsMap = new Map<Id, Core_MDF_Activity_Segment_Mapping__c>([select Id, Core_MDF_Partner_Fund_Request_id__c, Core_MDF_Segment_Name_nm__c, Core_MDF_Active_ind__c,Core_MDF_Minimum_Forecast_Volume_nbr__c,Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c,Core_MDF_Estimated_Share_of_SPIF_amt__c, Core_MDF_Maximum_Bundled_Volume_nbr__c, Core_MDF_SPIF_Notes_internal_only_txt__c, Core_MDF_SPIF_Notes_txt__c,Core_MDF_Num_of_Expected_Participants__c,Core_MDF_Num_of_Potential_Winners__c   from Core_MDF_Activity_Segment_Mapping__c where Core_MDF_Partner_Fund_Request_id__c = :pfrId]);
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
                   // asm.Core_MDF_Num_of_Potential_Winners__c = existingSegmentsMap.get(segmentId).Core_MDF_Num_of_Potential_Winners__c; 
                   //	asm.Core_MDF_Num_of_Expected_Participants__c = existingSegmentsMap.get(segmentId).Core_MDF_Num_of_Expected_Participants__c; 
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
            if(String.isNotBlank(segmentProductString)) {
                parsedSegmentList = Core_MDF_SegmentParser.parse(segmentProductString);
                System.debug('parsedSegmentList '+parsedSegmentList);
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
                        if(segParse.Core_MDF_Minimum_Forecast_Volume_nbr != null) {
                            asm.Core_MDF_Minimum_Forecast_Volume_nbr__c = decimal.valueOf(segParse.Core_MDF_Minimum_Forecast_Volume_nbr);
                        }                
                        if(segParse.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr != null) {
                            asm.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = decimal.valueOf(segParse.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr);
                        }                
                        if(segParse.Core_MDF_Estimated_Share_of_SPIF_amt != null) {
                            asm.Core_MDF_Estimated_Share_of_SPIF_amt__c = decimal.valueOf(segParse.Core_MDF_Estimated_Share_of_SPIF_amt).setScale(2,System.RoundingMode.HALF_UP);
                        }            
                        if(segParse.Core_MDF_Maximum_Cost_of_Bundle_nbr != null) {
                            asm.Core_MDF_Maximum_Cost_of_Bundle_nbr__c = decimal.valueOf(segParse.Core_MDF_Maximum_Cost_of_Bundle_nbr);
                        }
                        if(segParse.Core_MDF_Maximum_Bundled_Volume_nbr != null) {
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
                for(String asmName : newSegmentNameMap.keySet()) {
                    if(segParseMap.containsKey(asmName) && segParseMap.get(asmName) != null ) {
                        for(Id productId : segParseMap.get(asmName).productIdSet) { 
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
                if(existingSegmentIdProdIdMap!=null && !existingSegmentIdProdIdMap.isEmpty()) { 
                    newSegmentIdProdIdMap.putAll(existingSegmentIdProdIdMap);
                }
            }
            System.debug('Anish22'+newSegmentIdProdIdMap);
            if(newSegmentIdProdIdMap != NULL && !newSegmentIdProdIdMap.isEmpty()) {
                sysOp.upsertActivitySegmentsProductMapping(newSegmentIdProdIdMap.values());
            }
		} catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e); } 
    }
    
    public class SegmentWrapper {
        @AuraEnabled
        public List<Core_MDF_Activity_Segment_Mapping__c> segmentList;        
        
        @AuraEnabled
        public Map<String, List<Core_MDF_Segment_Product_Mapping__c>> segmentProductMap;
        
        @AuraEnabled
        public List<Core_MDF_Segment_Product_Mapping__c> productList;
        
        @AuraEnabled
        public List<Core_MDF_CCP_Segment_Field__mdt> fieldsToDisplay;
    }

    public class SegmentPicklistWrapper{
        @AuraEnabled public string segmentLabel {get;set;}
        @AuraEnabled public string segmentApi {get;set;}
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
    }
}