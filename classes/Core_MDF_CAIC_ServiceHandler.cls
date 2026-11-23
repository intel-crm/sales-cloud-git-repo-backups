/****************************************************************************************************************************************
* Class Name        : Core_MDF_BankServiceHandler
* Created Date      : 03/10/2020 
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - NZ       03/10/2020       Service Class for handling trigger related functions on CIAC object.
*****************************************************************************************************************************************/
public without sharing class Core_MDF_CAIC_ServiceHandler{
    /***************************************************************************************************** 
    Method Name:        afterUpdateBankRecords
    @return  :          void
    @parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
    Description:       
    Added By:           Accenture - NZ - 03/10/2020 
    Modified By:        Date:       Changes: 
    *****************************************************************************************************/
    public static void beforeInsertCIACRec(List<Core_MDF_CoMarketing_Activity_Inc_Rule__c> newCIACList){
        
        if (newCIACList != NULL && newCIACList.size() > 0)
        {
            ciacDuplicateData(newCIACList);   
        }
    }
    /***************************************************************************************************** 
    Method Name:        CIACDuplicateData
    @return  :          void
    @parameters:        newBankList - Trigger.new for Core_MDF_Bank__c
    Description:       
    Added By:           Accenture - NZ - 03/10/2020 
    Modified By:        Date:       Changes: 
    *****************************************************************************************************/
    public static void ciacDuplicateData(List<Core_MDF_CoMarketing_Activity_Inc_Rule__c> newCIACList){

        Set<Core_MDF_CoMarketing_Activity_Inc_Rule__c> duplicateCaic = new Set<Core_MDF_CoMarketing_Activity_Inc_Rule__c>();
        Set<String> actCategoryStrSet = new Set<String>();
        Set<String> actTypeStrSet = new Set<String>();
        Set<String> brandStrSet = new Set<String>();
        Set<String> cpStrSet = new Set<String>();
        Set<String> prodTypeStrSet = new Set<String>();
        Set<String> technologyStrSet = new Set<String>();
        Map<String, Core_MDF_CoMarketing_Activity_Inc_Rule__c> ciacIdCatTypeBrandPrgmStrMap = new Map<String,Core_MDF_CoMarketing_Activity_Inc_Rule__c>();
        Set<String> dupStr = new Set<String>();
        List<String>actCategoryStrList = new List<String>();
        for(Core_MDF_CoMarketing_Activity_Inc_Rule__c caic : newCIACList){
            cpStrSet.add(caic.Core_MDF_Channel_Program_Id__c);
            /*actCategoryStrSet.add((caic.Core_MDF_Activity_Category_Nm__c).split(';'));
            /*actTypeStrSet.add(caic.Core_MDF_Activity_Type_Nm__c);
            brandStrSet.add(caic.Core_MDF_Brand_Nm__c);
            cpStrSet.add(caic.Core_MDF_Channel_Program_Id__c);
            prodTypeStrSet.add(caic.Core_MDF_Product_Type_Txt__c);
            technologyStrSet.add(caic.Core_MDF_Technology_Nm__c);*/
            ciacIdCatTypeBrandPrgmStrMap.put(caic.Core_MDF_Activity_Category_Nm__c+caic.Core_MDF_Activity_Type_Nm__c+caic.Core_MDF_Brand_Nm__c+caic.Core_MDF_Channel_Program_Id__c+caic.Core_MDF_Product_Type_Txt__c+caic.Core_MDF_Technology_Nm__c,caic);
            //ciacIdCatTypeBrandPrgmStrMap.put(caic.Core_MDF_Activity_Category_Nm__c,caic);
            System.debug('NZ-->ciacIdCatTypeBrandPrgmStrMap: '+ciacIdCatTypeBrandPrgmStrMap);
        }
        for(Core_MDF_CoMarketing_Activity_Inc_Rule__c CIACRec : [SELECT id,Core_MDF_Activity_Category_Nm__c,Core_MDF_Activity_Type_Nm__c,
                                                                       Core_MDF_Brand_Nm__c,Core_MDF_Channel_Program_Id__c,Core_MDF_Effective_Dt__c,
                                                                       Core_MDF_Incentive_Pct__c,Core_MDF_Ineffective_Dt__c,Core_MDF_Product_Type_Txt__c,
                                                                       Core_MDF_Technology_Nm__c 
                                                                       FROM Core_MDF_CoMarketing_Activity_Inc_Rule__c
                                                                       WHERE Core_MDF_Channel_Program_Id__c IN :cpStrSet ]){
            dupStr.add(CIACRec.Core_MDF_Activity_Category_Nm__c+CIACRec.Core_MDF_Activity_Type_Nm__c+CIACRec.Core_MDF_Brand_Nm__c+CIACRec.Core_MDF_Channel_Program_Id__c+CIACRec.Core_MDF_Product_Type_Txt__c+CIACRec.Core_MDF_Technology_Nm__c);
            
            System.debug('NZ-->dupStr:'+dupStr);
        }
        for(String chk:ciacIdCatTypeBrandPrgmStrMap.Keyset()){
            System.debug('NZ-->dupStr.contains(chk):'+dupStr.contains(chk));
            /*if(dupStr.contains(chk)){
                duplicateCaic.add(ciacIdCatTypeBrandPrgmStrMap.get(chk));
            }*/
            if(dupStr.contains(chk)){
                duplicateCaic.add(ciacIdCatTypeBrandPrgmStrMap.get(chk));
            }
            //if()
            System.debug('NZ-->duplicateCaic: '+duplicateCaic);
        }
        for(Core_MDF_CoMarketing_Activity_Inc_Rule__c caic : newCIACList){
            if(duplicateCaic.contains(caic)){
             //   caic.addError('Duplicate Incentive');
            }
        }
    }
    /***************************************************************************************************** 
    Method Name:        CIACDuplicateData
    @return  :          void
    @parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
    Description:       
    Added By:           Accenture - NZ - 03/10/2020 
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    /*public static void CIACDuplicateData(List<Core_MDF_CoMarketing_Activity_Inc_Rule__c> newCIACList){
        
        List<String> actCategorySet;
        Set<String> actTypeStr;
        Set<String> actBrandStr;
        Set<String> actChannelPrgmStr;
        Set<String> effectiveDateStr;
        Set<String> inEffectiveDateStr;
        Set<String> productTypeStr;
        Set<String> technologyStr;
        Set<String> dupStr;
        Map<String, Core_MDF_CoMarketing_Activity_Inc_Rule__c> ciacIdCatTypeBrandPrgmStrDupMap = new Map<String,Core_MDF_CoMarketing_Activity_Inc_Rule__c>();

        Map<String, Core_MDF_CoMarketing_Activity_Inc_Rule__c> ciacIdCatTypeBrandPrgmStrMap = new Map<String,Core_MDF_CoMarketing_Activity_Inc_Rule__c>();
        for(Core_MDF_CoMarketing_Activity_Inc_Rule__c CIAC : newCIACList){
            System.debug('NZ-->beforeInsert:Service HDNLER: '+CIAC.Core_MDF_Activity_Category_Nm__c);
            if(CIAC.Core_MDF_Activity_Category_Nm__c != null ){
                System.debug('NZ-->in null chk');
                String str = CIAC.Core_MDF_Activity_Category_Nm__c;
                System.debug('str: '+str);
                actCategorySet.add(str);
                System.debug('NZ-->out null chk');
            }
            //actCategorySet.add(CIAC.Core_MDF_Activity_Type_Nm__c);
            
            /*actBrandStr.add(CIAC.Core_MDF_Brand_Nm__c);
            actChannelPrgmStr.add(CIAC.Core_MDF_Channel_Program_Id__c);
            ciacIdCatTypeBrandPrgmStrMap.put(CIAC.Core_MDF_Activity_Category_Nm__c+CIAC.Core_MDF_Activity_Type_Nm__c+CIAC.Core_MDF_Brand_Nm__c+CIAC.Core_MDF_Channel_Program_Id__c,CIAC);
        }

        //List<Core_MDF_CoMarketing_Activity_Inc_Rule__c> CIACRec = new List<Core_MDF_CoMarketing_Activity_Inc_Rule__c>();
        for(Core_MDF_CoMarketing_Activity_Inc_Rule__c CIACRec : [SELECT id,Core_MDF_Activity_Category_Nm__c,Core_MDF_Activity_Type_Nm__c,
                                                                       Core_MDF_Brand_Nm__c,Core_MDF_Channel_Program_Id__c,Core_MDF_Effective_Dt__c,
                                                                       Core_MDF_Incentive_Pct__c,Core_MDF_Ineffective_Dt__c,Core_MDF_Product_Type_Txt__c,
                                                                       Core_MDF_Technology_Nm__c 
                                                                       FROM Core_MDF_CoMarketing_Activity_Inc_Rule__c
                                                                       WHERE Core_MDF_Activity_Category_Nm__c IN :actCategorySet 
                                                                       AND Core_MDF_Activity_Type_Nm__c IN :actTypeStr
                                                                       AND Core_MDF_Brand_Nm__c IN :actBrandStr
                                                                       AND Core_MDF_Channel_Program_Id__c IN :actChannelPrgmStr]){
                                                                          
        dupStr.add(CIACRec.Core_MDF_Activity_Category_Nm__c+CIACRec.Core_MDF_Activity_Type_Nm__c+CIACRec.Core_MDF_Brand_Nm__c+CIACRec.Core_MDF_Channel_Program_Id__c);
        //ciacIdCatTypeBrandPrgmStrMapDup.put(Core_MDF_Activity_Category_Nm__c+Core_MDF_Activity_Type_Nm__c+Core_MDF_Brand_Nm__c+Core_MDF_Channel_Program_Id__c,CIAC);
        
        }


        for(String chk:ciacIdCatTypeBrandPrgmStrMap.Keyset()){
            if(dupStr.contains(chk)){
                System.debug('error');
            } 
        }
        
    }*/
    
}