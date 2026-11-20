/********************************************************************************************************************
    Class Name: Core_OppLineItem_Batch_Helper
    Version     : 1.0 
    Created Date: 15 Sept 2020
    Function    : Class to recalculate opportunity line item BU Short name 
    *******************************************************************************************************************/
public without sharing class Core_OppLineItem_Batch_Helper {
    
    private static String extKeyABCD, extKeyABC, extKeyBCD, extKeyACD, extKeyABD, extKeyAB, extKeyBC, extKeyCD, extKeyAD, extKeyAC, extKeyBD, extKeyA, extKeyB, extKeyC, extKeyD;
    private static Core_BU_Mapping_Table__c tempBuMap;
    private static Core_BU_Mapping_Table__c tempFinalBuMap;
    private static Set<Core_BU_Mapping_Table__c> tempBuMapSet;
    
    public static WrapperHelper prepareBuMappingTable(){
        Map<String, Core_BU_Mapping_Table__c> extKeyWithBuMap = new Map<String, Core_BU_Mapping_Table__c>();
        Map<String, Set<Core_BU_Mapping_Table__c>> extKeyWithDivShortNmBuMap = new Map<String, Set<Core_BU_Mapping_Table__c>>();
        Map<String, Set<Core_BU_Mapping_Table__c>> DivShortNmBuMapSetMap = new Map<String, Set<Core_BU_Mapping_Table__c>>();
        Core_BU_Mapping_Table__c blankBuMapRecord = null;
        //Map of externalkey and weightage in which externalkey is Core_Product_Application__c+Core_Product_Segment__c+Core_Division_Shortname__c+Core_Product_Type__c
        Map<String, Double> extKeyWeightageMap = new Map<String, Double>();
        //Map of externalkey and maximum weightage
        Map<String, Double> extKeyWeightageMap1 = new Map<String, Double>();
        String spaceStr = 'spaceCheck';
        String extKeyDivABD, extKeyDivAB, extKeyDivBD, extKeyDivAD, extKeyDivA, extKeyDivB, extKeyDivD;
        String extKey, tempKey;
        List<Core_BU_Mapping_Table__c> listOfBUShortName = [SELECT Id,Core_BU_Segment__c,Core_BU_Shortname__c,Core_Division_Shortname__c,Core_Product_Application__c,Core_Product_Segment__c,Core_Weightage__c,Name,Core_Product_Type__c FROM Core_BU_Mapping_Table__c where isDeleted=false order by LastModifiedDate desc];
        if(!listOfBUShortName.isEmpty()){
            for(Core_BU_Mapping_Table__c buMap : listOfBUShortName){
                extKey = extKeyDivABD = extKeyDivAB = extKeyDivBD = extKeyDivAD = extKeyDivA = extKeyDivB = extKeyDivD = '';
                //Let's say A = Core_Product_Application__c
                if(buMap.Core_Product_Application__c <> null && buMap.Core_Product_Application__c <> ''){
                    tempKey = getExactValue(buMap.Core_Product_Application__c);
                    extKey = extKey + tempKey + ';';
                    if(buMap.Core_Division_Shortname__c <> null && buMap.Core_Division_Shortname__c <> ''){
                        extKeyDivABD = extKeyDivABD + tempKey + ';';
                        extKeyDivAB = extKeyDivAB + tempKey + ';';
                        extKeyDivAD = extKeyDivAD + tempKey + ';';
                        extKeyDivA = tempKey;
                    }
                }
                //Let's say B = Core_Product_Segment__c
                if(buMap.Core_Product_Segment__c <> null && buMap.Core_Product_Segment__c <> ''){
                    tempKey = getExactValue(buMap.Core_Product_Segment__c);
                    extKey = extKey + tempKey + ';';
                    if(buMap.Core_Division_Shortname__c <> null && buMap.Core_Division_Shortname__c <> ''){
                        extKeyDivABD = extKeyDivABD + tempKey + ';';
                        extKeyDivAB = extKeyDivAB + tempKey + ';';
                        extKeyDivBD = extKeyDivBD + tempKey + ';';
                        extKeyDivB = tempKey;
                    }
                }
                //Let's say C = Core_Division_Shortname__c
                if(buMap.Core_Division_Shortname__c <> null && buMap.Core_Division_Shortname__c <> ''){
                    extKey = extKey + getExactValue(buMap.Core_Division_Shortname__c) + ';';
                    DivShortNmBuMapSetMap = prepareMapOfBURecList(extKey, buMap, DivShortNmBuMapSetMap);
                }
                //Let's say D = Core_Product_Type__c
                if(buMap.Core_Product_Type__c <> null && buMap.Core_Product_Type__c <> ''){
                    tempKey = getExactValue(buMap.Core_Product_Type__c);
                    extKey = extKey + tempKey + ';';
                    if(buMap.Core_Division_Shortname__c <> null && buMap.Core_Division_Shortname__c <> ''){
                        extKeyDivABD = extKeyDivABD + tempKey + ';';
                        extKeyDivBD = extKeyDivBD + tempKey + ';';
                        extKeyDivAD = extKeyDivAD + tempKey + ';';
                        extKeyDivD = tempKey;
                    }
                }
                if(extKey <> ''){
                    extKey = extKey.removeEnd(';');
                    if(!extKeyWeightageMap.containskey(extKey) || (extKeyWeightageMap.containskey(extKey) && buMap.Core_Weightage__c > extKeyWeightageMap.get(extKey))){
                        extKeyWeightageMap.put(extKey, buMap.Core_Weightage__c);
                        extKeyWithBuMap.put(extKey, buMap);
                    }
                    if(buMap.Core_Division_Shortname__c <> null && buMap.Core_Division_Shortname__c <> ''){
                        if(extKeyDivABD <> ''){
                            extKeyDivABD = extKeyDivABD.removeEnd(';');
                            extKeyWithDivShortNmBuMap = prepareMapOfBURecList(extKeyDivABD, buMap, extKeyWithDivShortNmBuMap);
                        }
                        if(extKeyDivAB <> ''){
                            extKeyDivAB = extKeyDivAB.removeEnd(';');
                            extKeyWithDivShortNmBuMap = prepareMapOfBURecList(extKeyDivAB, buMap, extKeyWithDivShortNmBuMap);
                        }
                        if(extKeyDivBD <> ''){
                            extKeyDivBD = extKeyDivBD.removeEnd(';');
                            extKeyWithDivShortNmBuMap = prepareMapOfBURecList(extKeyDivBD, buMap, extKeyWithDivShortNmBuMap);
                        }
                        if(extKeyDivAD <> ''){
                            extKeyDivAD = extKeyDivAD.removeEnd(';');
                            extKeyWithDivShortNmBuMap = prepareMapOfBURecList(extKeyDivAD, buMap, extKeyWithDivShortNmBuMap);
                        }
                        if(extKeyDivA <> ''){
                            extKeyWithDivShortNmBuMap = prepareMapOfBURecList(extKeyDivA, buMap, extKeyWithDivShortNmBuMap);
                        }
                        if(extKeyDivB <> ''){
                            extKeyWithDivShortNmBuMap = prepareMapOfBURecList(extKeyDivB, buMap, extKeyWithDivShortNmBuMap);
                        }
                        if(extKeyDivD <> ''){
                            extKeyWithDivShortNmBuMap = prepareMapOfBURecList(extKeyDivD, buMap, extKeyWithDivShortNmBuMap);
                        }
                    }
                }else{
                    if(!extKeyWeightageMap1.containskey(spaceStr) || (extKeyWeightageMap1.containskey(spaceStr) && buMap.Core_Weightage__c > extKeyWeightageMap1.get(spaceStr))){
                        extKeyWeightageMap1.put(spaceStr, buMap.Core_Weightage__c);
                        blankBuMapRecord = buMap;
                    }
                }
            }
        }
        WrapperHelper wrap = new WrapperHelper(extKeyWithBuMap, extKeyWithDivShortNmBuMap, DivShortNmBuMapSetMap, blankBuMapRecord);
        return wrap;
    }
    
    public static Core_BU_Mapping_Table__c buShortNmUpdateLogic(OpportunityLineItem oppLineItem, WrapperHelper wrap){
        extKeyABCD = extKeyABC = extKeyBCD = extKeyACD = extKeyABD = extKeyAB = extKeyBC = extKeyCD = extKeyAD = extKeyAC = extKeyBD = extKeyA = extKeyB = extKeyC = extKeyD = '';
        tempBuMap = null;
        tempFinalBuMap = null;
        tempBuMapSet = new Set<Core_BU_Mapping_Table__c>();
        //Let's say A = Core_Product_Application__c
        if(oppLineItem.Core_Product_Application__c <> null && oppLineItem.Core_Product_Application__c <> ''){
            extKeyA = getExactValue(oppLineItem.Core_Product_Application__c);
            extKeyABCD = extKeyABCD + extKeyA + ';';
            extKeyABC = extKeyABC + extKeyA + ';';
            extKeyACD = extKeyACD + extKeyA + ';';
            extKeyABD = extKeyABD + extKeyA + ';';
            extKeyAB = extKeyAB + extKeyA + ';';
            extKeyAC = extKeyAC + extKeyA + ';';
            extKeyAD = extKeyAD + extKeyA + ';';
        }
        //Let's say B = Core_Product_Segment__c
        if(oppLineItem.Core_Product_Segment__c <> null && oppLineItem.Core_Product_Segment__c <> ''){
            extKeyB = getExactValue(oppLineItem.Core_Product_Segment__c);
            extKeyABCD = extKeyABCD + extKeyB + ';';
            extKeyABC = extKeyABC + extKeyB + ';';
            extKeyBCD = extKeyBCD + extKeyB + ';';
            extKeyABD = extKeyABD + extKeyB + ';';
            extKeyAB = extKeyAB + extKeyB + ';';
            extKeyBC = extKeyBC + extKeyB + ';';
            extKeyBD = extKeyBD + extKeyB + ';';
        }
        //Let's say C = Core_product2_division__c
        if(oppLineItem.Core_product2_division__c <> null && oppLineItem.Core_product2_division__c <> ''){
            extKeyC = getExactValue(oppLineItem.Core_product2_division__c);
            extKeyABCD = extKeyABCD + extKeyC + ';';
            extKeyABC = extKeyABC + extKeyC + ';';
            extKeyBCD = extKeyBCD + extKeyC + ';';
            extKeyACD = extKeyACD + extKeyC + ';';
            extKeyAC = extKeyAC + extKeyC + ';';
            extKeyBC = extKeyBC + extKeyC + ';';
            extKeyCD = extKeyCD + extKeyC + ';';
        }
        //Let's say D = Core_Product_Type__c
        if(oppLineItem.Core_Product_Type__c <> null && oppLineItem.Core_Product_Type__c <> ''){
            extKeyD = getExactValue(oppLineItem.Core_Product_Type__c);
            extKeyABCD = extKeyABCD + extKeyD + ';';
            extKeyBCD = extKeyBCD + extKeyD + ';';
            extKeyACD = extKeyACD + extKeyD + ';';
            extKeyABD = extKeyABD + extKeyD + ';';
            extKeyCD = extKeyCD + extKeyD + ';';
            extKeyAD = extKeyAD + extKeyD + ';';
            extKeyBD = extKeyBD + extKeyD + ';';
        }
        
        /**************************************Four Fields Check Starts**************************************/
        if(extKeyABCD <> ''){
            extKeyABCD = extKeyABCD.removeEnd(';');
            tempFinalBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyABCD);
        }
        if(tempFinalBuMap == null && oppLineItem.Core_product2_division__c <> null && extKeyABD <> ''){
            extKeyABD = extKeyABD.removeEnd(';');
            if(wrap.extKeyWithDivShortNmBuMap.containskey(extKeyABD)){
                tempFinalBuMap = getBuMapRec(oppLineItem.Core_product2_division__c, wrap.extKeyWithDivShortNmBuMap.get(extKeyABD));
            }
        }
        /**************************************Four Fields Check Ends**************************************/
        
        /**************************************Three Fields Check Starts**************************************/
        if(tempFinalBuMap == null){
            if(extKeyABC <> ''){
                extKeyABC = extKeyABC.removeEnd(';');
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyABC);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            if(extKeyBCD <> ''){
                extKeyBCD = extKeyBCD.removeEnd(';');
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyBCD);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            if(extKeyACD <> ''){
                extKeyACD = extKeyACD.removeEnd(';');
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyACD);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            if(extKeyABD <> ''){
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyABD);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            
            if(!tempBuMapSet.isEmpty()){
                tempFinalBuMap = getBuMapRec(null, tempBuMapSet);
                tempBuMapSet.clear();
            }            
        }
        
        if(tempFinalBuMap == null && oppLineItem.Core_product2_division__c <> null){
            if(extKeyAB <> ''){
                extKeyAB = extKeyAB.removeEnd(';');
                if(wrap.extKeyWithDivShortNmBuMap.containskey(extKeyAB)){
                    tempBuMapSet.addAll(wrap.extKeyWithDivShortNmBuMap.get(extKeyAB));
                }
            }
            if(extKeyAD <> ''){
                extKeyAD = extKeyAD.removeEnd(';');
                if(wrap.extKeyWithDivShortNmBuMap.containskey(extKeyAD)){
                    tempBuMapSet.addAll(wrap.extKeyWithDivShortNmBuMap.get(extKeyAD));
                }
            }
            if(extKeyBD <> ''){
                extKeyBD = extKeyBD.removeEnd(';');
                if(wrap.extKeyWithDivShortNmBuMap.containskey(extKeyBD)){
                    tempBuMapSet.addAll(wrap.extKeyWithDivShortNmBuMap.get(extKeyBD));
                }
            }
            
            if(!tempBuMapSet.isEmpty()){
                tempFinalBuMap = getBuMapRec(oppLineItem.Core_product2_division__c, tempBuMapSet);
                tempBuMapSet.clear();
            }
        }
        /**************************************Three Field Check Ends**************************************/
        
        /**************************************Two Field Check Starts**************************************/
        if(tempFinalBuMap == null){            
            if(extKeyAB <> ''){
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyAB);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            if(extKeyAC <> ''){
                extKeyAC = extKeyAC.removeEnd(';');
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyAC);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            if(extKeyAD <> ''){
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyAD);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            if(extKeyBC <> ''){
                extKeyBC = extKeyBC.removeEnd(';');
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyBC);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            if(extKeyBD <> ''){
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyBD);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            if(extKeyCD <> ''){
                extKeyCD = extKeyCD.removeEnd(';');
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyCD);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            
            if(!tempBuMapSet.isEmpty()){
                tempFinalBuMap = getBuMapRec(null, tempBuMapSet);
                tempBuMapSet.clear();
            }
        }
        
        if(tempFinalBuMap == null && oppLineItem.Core_product2_division__c <> null){
            if(extKeyA <> ''){
                if(wrap.extKeyWithDivShortNmBuMap.containskey(extKeyA)){
                    tempBuMapSet.addAll(wrap.extKeyWithDivShortNmBuMap.get(extKeyA));
                }
            }
            if(extKeyB <> ''){
                if(wrap.extKeyWithDivShortNmBuMap.containskey(extKeyB)){
                    tempBuMapSet.addAll(wrap.extKeyWithDivShortNmBuMap.get(extKeyB));
                }
            }
            if(extKeyD <> ''){
                if(wrap.extKeyWithDivShortNmBuMap.containskey(extKeyD)){
                    tempBuMapSet.addAll(wrap.extKeyWithDivShortNmBuMap.get(extKeyD));
                }
            }
            
            if(!tempBuMapSet.isEmpty()){
                tempFinalBuMap = getBuMapRec(oppLineItem.Core_product2_division__c, tempBuMapSet);
                tempBuMapSet.clear();
            }
        }
        /**************************************Two Field Check Ends**************************************/
        
        /**************************************One Field Check Starts**************************************/
        if(tempFinalBuMap == null){
            if(oppLineItem.Core_product2_division__c <> null && !wrap.DivShortNmBuMapSetMap.isEmpty()){
                for(String divShortNm : wrap.DivShortNmBuMapSetMap.keySet()){
                    if(oppLineItem.Core_product2_division__c.containsIgnoreCase(divShortNm)){
                        tempBuMapSet.addAll(wrap.DivShortNmBuMapSetMap.get(divShortNm));
                    }
                }
            }
            
            if(extKeyA <> ''){
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyA);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            if(extKeyB <> ''){
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyB);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            if(extKeyC <> ''){
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyC);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            if(extKeyD <> ''){
                tempBuMap = getBuMapRecord(wrap.extKeyWithBuMap, extKeyD);
                if(tempBuMap <> null){
                    tempBuMapSet.add(tempBuMap);
                }
            }
            
            if(!tempBuMapSet.isEmpty()){
                tempFinalBuMap = getBuMapRec(null, tempBuMapSet);
                tempBuMapSet.clear();
            }
        }                
        /**************************************One Field Check Ends**************************************/
        //Check the blank BU Map record only if all the above scenario's doesn't satisfy
        if(tempFinalBuMap == null && wrap.blankBuMapRecord <> null){
            tempFinalBuMap = wrap.blankBuMapRecord;
        }
        return tempFinalBuMap;
    }
    
    public static String getExactValue(String rawValue){
        return rawValue.trim().toLowerCase();
    }
    
    public static Map<String, Set<Core_BU_Mapping_Table__c>> prepareMapOfBURecList(String extKey, Core_BU_Mapping_Table__c buMapRec, Map<String, Set<Core_BU_Mapping_Table__c>> extKeyWithBuMapDivShortNm){
        Set<Core_BU_Mapping_Table__c> tempSet;
        if(extKeyWithBuMapDivShortNm.containsKey(extKey)){
            tempSet = extKeyWithBuMapDivShortNm.get(extKey);
        }else{
            tempSet = new Set<Core_BU_Mapping_Table__c>();
        }
        tempSet.add(buMapRec);
        extKeyWithBuMapDivShortNm.put(extKey, tempSet);
        return extKeyWithBuMapDivShortNm;
    }
    
    public static Core_BU_Mapping_Table__c getBuMapRecord(Map<String, Core_BU_Mapping_Table__c> extKeyWithBuMap, String extKey){
        if(extKeyWithBuMap.containskey(extKey)){
            return extKeyWithBuMap.get(extKey);
        }else{
            return null;
        }
    }
    
    public static Core_BU_Mapping_Table__c getBuMapRec(String divShortName, Set<Core_BU_Mapping_Table__c> buMapRecSet){
        Core_BU_Mapping_Table__c tempRec = null;
        for(Core_BU_Mapping_Table__c buMapRec : buMapRecSet){
            if(divShortName == null || (divShortName <> null && buMapRec.Core_Division_Shortname__c.containsIgnoreCase(divShortName))){
                if(tempRec == null){
                    tempRec = buMapRec;
                }else{
                    if(buMapRec.Core_Weightage__c > tempRec.Core_Weightage__c){
                        tempRec = buMapRec;
                    }
                }
            }
        }
        return tempRec;
    }
    
    public class WrapperHelper{
        //Map of externalkey and BU Mapping record in which externalkey is Core_Product_Segment__c+Core_Product_Type__c
        public Map<String, Core_BU_Mapping_Table__c> extKeyWithBuMap;
        public Map<String, Set<Core_BU_Mapping_Table__c>> extKeyWithDivShortNmBuMap;
        public Map<String, Set<Core_BU_Mapping_Table__c>> DivShortNmBuMapSetMap;
        public Core_BU_Mapping_Table__c blankBuMapRecord;
        public WrapperHelper(Map<String, Core_BU_Mapping_Table__c> extKeyWithBuMap, Map<String, Set<Core_BU_Mapping_Table__c>> extKeyWithDivShortNmBuMap, Map<String, Set<Core_BU_Mapping_Table__c>> DivShortNmBuMapSetMap, Core_BU_Mapping_Table__c blankBuMapRecord){
            this.extKeyWithBuMap = extKeyWithBuMap;
            this.extKeyWithDivShortNmBuMap = extKeyWithDivShortNmBuMap;
            this.DivShortNmBuMapSetMap = DivShortNmBuMapSetMap;
            this.blankBuMapRecord = blankBuMapRecord;
        }
    }
}