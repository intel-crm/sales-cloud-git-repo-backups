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
        //if(programIdSet!=null && ultimateAccId != null){
        if (programIdSet == null || ultimateAccId == null) {//ATHR Fix WW19
            return pgmKeyGrpIdWrapper;
        }

            for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Group_Id__c,Id, Name, Core_MDF_Account__c, Core_MDF_Group_Name__c,
                                                         Core_MDF_Type_of_Access__c,Core_MDF_Works_For__c, Core_MDF_Channel_Program__c, Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c,Core_MDF_BudgetType_nm__c/*Core_MDF_Budget_Type_nm__c*/,Core_MDF_Channel_Program__r.Name
                                                         FROM Core_MDF_Partner_Group_Mapping__c 
                                                         WHERE Core_MDF_Account__c IN : ultimateAccId AND Core_MDF_Channel_Program__c IN : programIdSet AND
                                                         Core_MDF_Inactive_Ind__c = false AND Core_MDF_Group_Id__c != NULL AND Core_MDF_Type_of_Access__c IN:IntExtTypeList])
            {
                
                if(pgm.Core_MDF_Type_of_Access__c == INTERNAL && pgm.Core_MDF_BudgetType_nm__c == null){   
                    //ATHR Fix WW19   
                    String accountIdProgramIdKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;  
                    if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        accountIdProgramIdKey = +pgm.Core_MDF_Sub_Region_cd__c;
                    }           
                    intAccPGMKeyGroupIDMap.put(accountIdProgramIdKey, pgm.Core_MDF_Group_Id__c);
                    /*if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        String accountIdProgramIdSubGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                        intAccPGMKeyGroupIDMap.put(accountIdProgramIdSubGeo, pgm.Core_MDF_Group_Id__c); 
                    }   
                    else{
                        String accountIdProgramIdGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                        intAccPGMKeyGroupIDMap.put(accountIdProgramIdGeo, pgm.Core_MDF_Group_Id__c);     
                    }*/
                } 
                if(pgm.Core_MDF_Type_of_Access__c == INTERNAL && pgm.Core_MDF_BudgetType_nm__c != null){
                    //ATHR Fix WW19
                    String accountIdProgramIdBudgetTypeKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                    if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        accountIdProgramIdBudgetTypeKey = + pgm.Core_MDF_BudgetType_nm__c;
                    }
                    intAccPGMKeyGroupIDMap.put(accountIdProgramIdBudgetTypeKey,pgm.Core_MDF_Group_Id__c);
                    /*if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        String accountIdProgramIdSubGeoBudgetType = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                        intAccPGMKeyGroupIDMap.put(accountIdProgramIdSubGeoBudgetType,pgm.Core_MDF_Group_Id__c);
                    }
                    else{
                        String accountIdProgramIdGeoBudgetType = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                        intAccPGMKeyGroupIDMap.put(accountIdProgramIdGeoBudgetType,pgm.Core_MDF_Group_Id__c);
                        
                    }*/
                    
                } 
                
                if(pgm.Core_MDF_Type_of_Access__c == INTERNAL && pgm.Core_MDF_Region_cd__c == 'WW'){
                    //ATHR Fix WW19
                    String accountIdProgramIdKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                    if(pgm.Core_MDF_BudgetType_nm__c != null){
                        accountIdProgramIdKey = +pgm.Core_MDF_BudgetType_nm__c;
                    }
                    intAccPGMKeyGroupIDMap.put(accountIdProgramIdKey,pgm.Core_MDF_Group_Id__c);
                    /*if(pgm.Core_MDF_BudgetType_nm__c == null){
                        String accountIdProgramId = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                        intAccPGMKeyGroupIDMap.put(accountIdProgramId,pgm.Core_MDF_Group_Id__c);
                    }else{ // for WW with budget type
                        String accountIdProgramIdBudget = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c+pgm.Core_MDF_BudgetType_nm__c;
                        intAccPGMKeyGroupIDMap.put(accountIdProgramIdBudget,pgm.Core_MDF_Group_Id__c);
                    }*/
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
        //}
        
        return pgmKeyGrpIdWrapper;
        
    }
/***************************************************************************************************** 
Method Name    :       fetchExternalPGMRecords
Description   :        To return a map of PGM records
Added By      :        Accenture - JK - 10/05/2024
Modified By   :        Date:       Changes: 
******************************************************************************************************/
public static List<Core_MDF_Partner_Group_Mapping__c> fetchExternalPGMRecords(Set<String> programName,Set<Id> accountIds,Set<Id> pgmIds,Set<Id> groupIds, List<String> groupNames,boolean ComarketingInd){
    String query ='Select Id,Core_MDF_Account__c,Core_MDF_Account__r.Name,Core_MDF_Group_Id__c,Core_MDF_Group_Name__c,'+
    'Core_MDF_All_Access_Group_Id__c,Core_MDF_All_Access_Group_Nm__c,Core_MDF_CoMarketingActive_Ind__c,Core_MDF_Channel_Program__c,'+
    'Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Channel_Program_Name_Txt__c,Core_MDF_Virtual_Corp_nm__c,'+
    'Core_MDF_Inactive_Ind__c, Core_MDF_Account__r.Core_MDF_CoMarketingAgency__c,Core_MDF_AccountProgramId_Txt__c,Core_MDF_Type_of_Access__c '+
    'from Core_MDF_Partner_Group_Mapping__c where '+' Core_MDF_Type_of_Access__c = \'External\'';
    if(programName != null){
        String programQuery = ' AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c IN '+':programName';
        query += programQuery;// +':programName';
    }
    if(accountIds != null){
        String accountQuery = ' AND Core_MDF_Account__c IN '+ ':accountIds';
        query += accountQuery ;//+ ':accountIds';
    }
    if(ComarketingInd != null){
        String comarketingIndQuery = ' AND Core_MDF_CoMarketingActive_Ind__c =';
        query += comarketingIndQuery+':ComarketingInd';
    }
    if(groupIds != null){
        String groupQuery = ' AND Core_MDF_Group_Id__c IN ';
        query += groupQuery + ':groupIds';
    }
    if(pgmIds != null){
        String pgmIdQuery = ' AND Id IN ';
        query += pgmIdQuery + ':pgmIds';
    }
    if(groupNames != null){
        String groupNameQuery = ' AND Core_MDF_Group_Name__c IN';
        query += groupNameQuery + ':groupNames';
    }
    List<Core_MDF_Partner_Group_Mapping__c> pgmRecords = Database.Query(query);
    return pgmRecords;
}
    public class pgmKeyGroupIdWrapper{
        @AuraEnabled public Map<String,Id> intPGMKeyGroupIdMap { get; set; }
        @AuraEnabled public Map<String,Id> extPGMKeyGroupIdMap { get; set; }
    }
    
}