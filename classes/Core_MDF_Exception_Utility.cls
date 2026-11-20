/****************************************************************************************************** 
Class Name:         Core_MDF_Exception_Utility
@parameters:        N/A
Description:        Utility Class for Exception to fetch Various metadata Records or PGM Records
Added By:           SS   02-01-2020
Modified By:        Date:           Changes:

*******************************************************************************************************/
public without sharing class Core_MDF_Exception_Utility {
    static final String STR_WW ='WW';
    static final String STR_No ='No';
    static final String RMF_Program= Core_MDF_CCP_ConstantClass.RMF_PROGRAM;
    /****************************************************************************************************** 
    Method Name:        getIUPGMDataForExceptionUser
    @return  :          Map of ExceptionUser Ids and Associated Region
    @parameters:        Exception Users Ids
    Description:        returns which excepption user belongs to which group
    Added By:           SS - 02/01/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static ExceptionUserIUPGMWrapper getIUPGMDataForExceptionUser(){
        
        Set<String> exptUserAccountProgramGeoStrSet = new Set<String>();
        Set<String> exptUserAccountProgramStrSet = new Set<String>();
        
        ExceptionUserIUPGMWrapper exceptUsrIUPGMWrap = new ExceptionUserIUPGMWrapper();
        
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c exceptionUserIUPGM : [SELECT Id,Core_MDF_Program_nm__c,Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c, Core_MDF_Active_Ind__c ,Core_MDF_is_User_Active_ind__c, Core_MDF_Region_cd__c, Core_MDF_User_id__c 
                                                                            FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                            WHERE Core_MDF_Active_Ind__c = true AND 
                                                                            Core_MDF_User_id__c =: UserInfo.getUserId() AND
                                                                            Core_MDF_is_User_Active_ind__c = true AND
                                                                            (Core_MDF_Program_nm__c in ('Retail Marketing Funds') OR Core_MDF_Region_cd__c != NULL)]){
                                                                                if(exceptionUserIUPGM.Core_MDF_Program_nm__c == RMF_Program){
                                                                                    exptUserAccountProgramStrSet.add((String)exceptionUserIUPGM.Core_MDF_Account_id__c + '-' + exceptionUserIUPGM.Core_MDF_Program_nm__c + '-' + exceptionUserIUPGM.Core_MDF_All_Accounts_cd__c);
                                                                               }
                                                                                else{
                                                                                    String accIdPrgAllAccount;
                                                                                    if(exceptionUserIUPGM.Core_MDF_Region_cd__c != NULL){
                                                                                        if(exceptionUserIUPGM.Core_MDF_All_Accounts_cd__c == STR_No){
                                                                                            accIdPrgAllAccount = (String)exceptionUserIUPGM.Core_MDF_Account_id__c + '-' + exceptionUserIUPGM.Core_MDF_Program_nm__c + '-' + exceptionUserIUPGM.Core_MDF_All_Accounts_cd__c;
                                                                                        }else{
                                                                                            accIdPrgAllAccount = exceptionUserIUPGM.Core_MDF_Program_nm__c + '-' + exceptionUserIUPGM.Core_MDF_All_Accounts_cd__c;
                                                                                        }
                                                                                        for(String geoStr : exceptionUserIUPGM.Core_MDF_Region_cd__c.split(';')){
                                                                                            exptUserAccountProgramGeoStrSet.add(accIdPrgAllAccount+ '-' + geoStr);
                                                                                            
                                                                                        }
                                                                                        exptUserAccountProgramStrSet.add(accIdPrgAllAccount);
                                                                                    }
                                                                                }
                                                                            }                                         
        exceptUsrIUPGMWrap.exptUserIUPGMAccountProgramGeoStrSet = exptUserAccountProgramGeoStrSet;
        exceptUsrIUPGMWrap.exptUserIUPGMAccountProgramStrSet =  exptUserAccountProgramStrSet;
        return exceptUsrIUPGMWrap;
    }
    /****************************************************************************************************** 
Method Name:        ExceptionUserIUPGMWrapper
Description:        Wrapper of IUPGM Account and Geo which excepption user belongs to which group
Added By:           SS - 02/01/2020
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    public class ExceptionUserIUPGMWrapper
    {   
        public Set< String > exptUserIUPGMAccountProgramGeoStrSet;
        public Set< String > exptUserIUPGMAccountProgramStrSet;
    }
}