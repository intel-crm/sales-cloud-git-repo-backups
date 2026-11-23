/****************************************************************************************************** 
Class Name:         Core_MDF_PFR_Utility
@parameters:        N/A
Description:        Utility Class for PartnerFundRequest to fetch Various metadata Records
Added By:           SS   24-12-2019
Modified By:        Date:           Changes:

*******************************************************************************************************/
public without sharing class Core_MDF_PFR_Utility {
    /****************************************************************************************************** 
    Method Name:        insertPFR
    @return  :          void
    @parameters:        PartnerFundRequest
    Description:        inserts the PFR Record
    Added By:           SB - 03/22/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static void insertPFR(PartnerFundRequest pfrRecord){
        if(pfrRecord != NULL){
            try{
              insert pfrRecord;  
            }catch(DmlException e){
                System.debug('=== DETAILED ERROR ANALYSIS ===');
            System.debug('Full Error Message: ' + e.getMessage());
            System.debug('Error Type: ' + e.getDmlType(0));
            System.debug('Error Status Code: ' + e.getDmlStatusCode(0));
            System.debug('Error Fields: ' + e.getDmlFieldNames(0));
            System.debug('Error Index: ' + e.getDmlIndex(0));
            System.debug('Stack Trace: ' + e.getStackTraceString());
            System.debug('Amount: ' + pfrRecord.Amount);
            System.debug('Status: ' + pfrRecord.Core_MDF_Fund_Request_Status__c);
            System.debug('AllocationId: ' + pfrRecord.AllocationId);
            System.debug('BudgetId: ' + pfrRecord.BudgetId);
            String errorMsg = e.getMessage();
            System.debug('Contains __: ' + errorMsg.contains('__'));
            System.debug('Contains namespace pattern: ' + Pattern.matches('.*[a-zA-Z0-9]+__.*', errorMsg));
            
            if(errorMsg.contains('INVALID_FIELD_FOR_INSERT_UPDATE')) {
                System.debug('*** FIELD VALIDATION ERROR ***');
            }
            
            throw e;
            }
            
        }
    }
    
    /****************************************************************************************************** 
    Method Name:        updatePFR
    @return  :          void
    @parameters:        PartnerFundRequest
    Description:        updates the PFR Record
    Added By:           SB - 03/22/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
   public static void updatePFR(PartnerFundRequest pfrRecord){ 
    if(pfrRecord != NULL){ 
        try {
            if(pfrRecord.Amount == null && pfrRecord.Core_MDF_Proposal_Based_Ind__c==true) {
                pfrRecord.Amount = 0;
                System.debug('Set Amount to 0 for proposal-based PFR');
            }
        
            update pfrRecord; 
        
            
        } catch (DmlException e) {
            System.debug('=== DETAILED ERROR ANALYSIS ===');
            System.debug('Full Error Message: ' + e.getMessage());
            System.debug('Error Type: ' + e.getDmlType(0));
            System.debug('Error Status Code: ' + e.getDmlStatusCode(0));
            System.debug('Error Fields: ' + e.getDmlFieldNames(0));
            System.debug('Error Index: ' + e.getDmlIndex(0));
            System.debug('Stack Trace: ' + e.getStackTraceString());
            System.debug('Amount: ' + pfrRecord.Amount);
            System.debug('Status: ' + pfrRecord.Core_MDF_Fund_Request_Status__c);
            System.debug('AllocationId: ' + pfrRecord.AllocationId);
            System.debug('BudgetId: ' + pfrRecord.BudgetId);
            String errorMsg = e.getMessage();
            System.debug('Contains __: ' + errorMsg.contains('__'));
            System.debug('Contains namespace pattern: ' + Pattern.matches('.*[a-zA-Z0-9]+__.*', errorMsg));
            
            if(errorMsg.contains('INVALID_FIELD_FOR_INSERT_UPDATE')) {
                System.debug('*** FIELD VALIDATION ERROR ***');
            }
            
            throw e;
        }
    } 
}
    /****************************************************************************************************** 
    Method Name:        validateCountryAccess
    @return  :          Void 
    @parameters:        PartnerFundRequest 
    Description:        Throws error if the User does not have the access to the geo and creates activity for the same 
    Added By:           SS - 03/31/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static Map<PartnerFundRequest, Boolean> validateCountryAccess(Set<PartnerFundRequest> pfrRecordSet){
        // Get Activity Internal User IUPGMData Data
        Set <Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmSet = activityInternalUserIUPGMData();
        //Get Country Geo Map Data
        Map<String , String> countryGeoMap = new Map <String , String>();
        for (Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : [SELECT Id, MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c 
                                                                         FROM Core_MDF_CCP_Country_Geo_Mapping__mdt]){
            countryGeoMap.put(countryGeoMetaData.MasterLabel , countryGeoMetaData.Core_MDF_Geo__c );
        }
        // Variable Used for Return parmeter
        Map<PartnerFundRequest, Boolean> pfrWithoutCountryAccessMap = new Map<PartnerFundRequest, Boolean>();
        if(pfrRecordSet != NULL && pfrRecordSet.size() > 0){
            // For Loop to Check Each PFR Record
            for(PartnerFundRequest pfrRecord : pfrRecordSet){
                Boolean belongsToIUPGM = false;
                // Check if the User has Any IUPGM Data else put Actvity in countryAccessMap
                if(iupgmSet != NULL && iupgmSet.size()> 0){
                    // Loop to check which iupgm data matches with Activity
                    for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmSet){
                        // If the User has the data whether it matches with Activity Data Else put Actvity in countryAccessMap
                        system.debug('Here-->64'+iupgm.Core_MDF_Channel_Program_id__c);
                        system.debug('Here-->65'+iupgm.Core_MDF_Account_id__c);
                        system.debug('Here-->66'+pfrRecord.Campaign.Core_MDF_Account__r.Core_MDF_Channel_Program__c);
                        system.debug('Here-->67'+pfrRecord.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c);
                        if(iupgm.Core_MDF_Channel_Program_id__c == pfrRecord.Campaign.Core_MDF_Account__r.Core_MDF_Channel_Program__c &&
                          iupgm.Core_MDF_Account_id__c == pfrRecord.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c){
                            system.debug('Here-->66'+pfrWithoutCountryAccessMap);
                            Set<String> iupgmGeoSet = new Set<String>();
                            List<String> pfrGeoList = new List<String>();
                            iupgmGeoSet.addAll(iupgm.Core_MDF_Region_cd__c.split(';'));
                            // Check if the User has WW access if not than check for the Geo
                            if(!iupgmGeoSet.contains('WW')){
                                // If Geo Set does match with activity geo
                                for(String country : pfrRecord.Core_MDF_Country_nm__c.split(';')){                                    
                                    if(countryGeoMap.containsKey(country) && iupgmGeoSet.contains(countryGeoMap.get(country))){//If country Geo does matches
                                        belongsToIUPGM = true;
                                        break;
                                    }                                
                                }
                                if(belongsToIUPGM){
                                    break;
                                }
                            }
                            else{//If user is WW user, So No Error                                 
                                belongsToIUPGM = true;
                                break;
                            }
                        }                        
                    }
                }
                if(belongsToIUPGM){
                    pfrWithoutCountryAccessMap.put(pfrRecord , false);
                }
                else{
                    pfrWithoutCountryAccessMap.put(pfrRecord , true);
                }
            }
        }
        return pfrWithoutCountryAccessMap;
    }
    /****************************************************************************************************** 
    Method Name:        activityInternalUserIUPGMData
    @return  :          Set<String> 
    @parameters:        PartnerFundRequest 
    Description:        Throws error if the User does not have the access to the geo and creates activity for the same 
    Added By:           SS - 03/31/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static Set<Core_MDF_Int_Users_Partner_Geo_Mapping__c> activityInternalUserIUPGMData(){
        Set<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmSet = new set<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c activityUserIUPGM : [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Active_Ind__c ,
                                                                           Core_MDF_is_User_Active_ind__c, Core_MDF_Region_cd__c, Core_MDF_User_id__c,
                                                                           Core_MDF_Channel_Program_id__c
                                                        FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                        WHERE Core_MDF_Active_Ind__c = true AND
                                                        Core_MDF_User_id__c =: UserInfo.getUserId() AND
                                                        Core_MDF_is_User_Active_ind__c = true AND
                                                        Core_MDF_Region_cd__c != NULL]){
            iupgmSet.add(activityUserIUPGM);                           
        }
        return iupgmSet;
    }
    /***************************************************************************************************** 
    Method Name:        isAccountManager
    @return  :          Boolean
    @parameters:        
    Description:        This method is used to check if the "Account Manager" Custom permission is assigned to the User
    Added By:           Accenture SB
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static Boolean isAccountManager(){
        return isCustomPermissionAssigned('Core_MDF_Internal_Account_Manager');
    }

    /***************************************************************************************************** 
    Method Name:        isCustomPermissionAssigned
    @return  :          Boolean
    @parameters:        String - Custom Permission Name
    Description:        This method is used to check if the Custom permission is assigned to the User
    Added By:           Accenture SB
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static Boolean isCustomPermissionAssigned(String customPermissionNameStr){
        if(customPermissionNameStr != NULL && String.isNotBlank(customPermissionNameStr)){
            return FeatureManagement.checkPermission(customPermissionNameStr);
        }
        else{
            return false;
        }
    }
}