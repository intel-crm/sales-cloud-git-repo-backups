/***************************************************************************************************** 
Class Name    :   Core_MDF_PGM_Utility
Created By    :    Accenture - AN - 03/28/2024
Modified By   :    Date:       Changes: 
******************************************************************************************************/

public without sharing class Core_MDF_PGM_Utility {
    Public static string INTERNAL = Core_MDF_CCP_ConstantClass.INTERNAL;
    Public static string EXTERNAL = Core_MDF_CCP_ConstantClass.EXTERNAL;
    Public static string INTERNAL_EXTERNAL = Core_MDF_CCP_ConstantClass.INTERNAL_EXTERNAL;
    Public static list<String> intExtList = INTERNAL_EXTERNAL.split(';');
    /***************************************************************************************************** 
Method Name    :       getAccPGMKeyGrpIdMap
Description   :        To return a map with corresponding with keys and group Ids
Added By      :        Accenture - AN - 03/28/2024
Modified By   :        Date:       Changes: 
******************************************************************************************************/
    //AccessType
    public static pgmKeyGroupIdWrapper getAccPGMKeyGrpIdMap(List<Id> ultimateAccId,List<Id> programIdSet, String accessType){
        //Map used to determine subgeo based internal group; key - AccId+ProgramId+Geo+SubGeo and Value - GroupId
        Map<String,Id> intAccPGMKeyGroupIDMap = new Map<String,Id>();
        Map<String,Id> extAccPGMKeyGroupIDMap = new Map<String,Id>();
        pgmKeyGroupIdWrapper pgmKeyGrpIdWrapper = new pgmKeyGroupIdWrapper();
        accessType = accessType!=null?accessType.toUpperCase():accessType;
        String pgmAccessType = !String.isBlank(accessType) && intExtList.contains(accessType)? accessType:INTERNAL_EXTERNAL;
        List<String> IntExtTypeList = pgmAccessType.split(';');
        if(programIdSet!=null && ultimateAccId != null){
            for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Group_Id__c,Id, Name, Core_MDF_Account__c, Core_MDF_Group_Name__c,
                                                         Core_MDF_Type_of_Access__c,Core_MDF_Works_For__c, Core_MDF_Channel_Program__c, Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c,Core_MDF_BudgetType_nm__c/*Core_MDF_Budget_Type_nm__c*/,Core_MDF_Channel_Program__r.Name
                                                         FROM Core_MDF_Partner_Group_Mapping__c 
                                                         WHERE Core_MDF_Account__c IN : ultimateAccId AND Core_MDF_Channel_Program__c IN : programIdSet AND
                                                         Core_MDF_Inactive_Ind__c = false AND Core_MDF_Group_Id__c != NULL AND Core_MDF_Type_of_Access__c IN:IntExtTypeList])
            {
                
                if(pgm.Core_MDF_Type_of_Access__c == INTERNAL && pgm.Core_MDF_BudgetType_nm__c == null){                                        
                    if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        String accountIdProgramIdSubGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                        intAccPGMKeyGroupIDMap.put(accountIdProgramIdSubGeo, pgm.Core_MDF_Group_Id__c); 
                    }   
                    else{
                        String accountIdProgramIdGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                        intAccPGMKeyGroupIDMap.put(accountIdProgramIdGeo, pgm.Core_MDF_Group_Id__c);     
                    }
                } 
                if(pgm.Core_MDF_Type_of_Access__c == INTERNAL && pgm.Core_MDF_BudgetType_nm__c != null){
                    if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        String accountIdProgramIdSubGeoBudgetType = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                        intAccPGMKeyGroupIDMap.put(accountIdProgramIdSubGeoBudgetType,pgm.Core_MDF_Group_Id__c);
                    }
                    else{
                        String accountIdProgramIdGeoBudgetType = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                        intAccPGMKeyGroupIDMap.put(accountIdProgramIdGeoBudgetType,pgm.Core_MDF_Group_Id__c);
                        
                    }
                    
                } 
                
                if(pgm.Core_MDF_Type_of_Access__c == INTERNAL && pgm.Core_MDF_Region_cd__c == 'WW'){
                    if(pgm.Core_MDF_BudgetType_nm__c == null){
                        String accountIdProgramId = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                        intAccPGMKeyGroupIDMap.put(accountIdProgramId,pgm.Core_MDF_Group_Id__c);
                    }else{ // for WW with budget type
                        String accountIdProgramIdBudget = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c+pgm.Core_MDF_BudgetType_nm__c;
                        intAccPGMKeyGroupIDMap.put(accountIdProgramIdBudget,pgm.Core_MDF_Group_Id__c);
                    }
                }
                
                if(pgm.Core_MDF_Type_of_Access__c == EXTERNAL){
                    String accountIdProgramId = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                    extAccPGMKeyGroupIDMap.put(accountIdProgramId,pgm.Core_MDF_Group_Id__c);
                }
            }
            if(intAccPGMKeyGroupIDMap!=null){
                pgmKeyGrpIdWrapper.intPGMKeyGroupIdMap = intAccPGMKeyGroupIDMap;
            }
            if(extAccPGMKeyGroupIDMap!=null){
                pgmKeyGrpIdWrapper.extPGMKeyGroupIdMap = extAccPGMKeyGroupIDMap;
            }
        }
        
        return pgmKeyGrpIdWrapper;
        
    }
    public class pgmKeyGroupIdWrapper{
        @AuraEnabled public Map<String,Id> intPGMKeyGroupIdMap { get; set; }
        @AuraEnabled public Map<String,Id> extPGMKeyGroupIdMap { get; set; }
    }
    
}