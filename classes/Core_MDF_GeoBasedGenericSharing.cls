/****************************************************************************************************************************************
* Class Name        : Core_MDF_GeoBasedGenericSharing
* Created Date      : 07/29/2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       08/05/2019         Generic Class for Sharing
*****************************************************************************************************************************************/
public without sharing class Core_MDF_GeoBasedGenericSharing {
    /***************************************************************************************************** 
    Method Name   :        checkObjectAndPgm
    @return       :        void
    @parameters   :        String and List of Id's
    Description   :        Check the object name and call the respective method to create share record
    Added By      :        Accenture - VK - 08/05/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/ 
    public static void checkObjectAndPgm(String objectName, List<Id> recordIdList){
        
        if(String.isNotEmpty(objectName) && recordIdList.size() > 0){
            
            switch on objectName {
                
                when 'PartnerFundRequest'{
                    Core_MDF_GeoBasedGenericSharing.createShareForPFR(recordIdList);                    
                }
                
                when 'Core_MDF_Bank__c'{
                    Core_MDF_GeoBasedGenericSharing.createShareForBank(recordIdList);
                }
                
            }
            
        }
    }
    
    /***************************************************************************************************** 
    Method Name   :        createShareForPFR
    @return       :        void
    @parameters   :        List of Activity Id's
    Description   :        Creates share record for activity based on geo
    Added By      :        Accenture - VK - 08/05/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public static void createShareForPFR(List<Id> pfrIdList){
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();
        
        Set<String> geoSet = new Set<String>();
        
        //key=country, value=geo
        Map<String,String> countryGeoMap = new Map<String,String>();
        
        //key=country, value=subgeo
        Map<String,String> countrySubGeoMap = new Map<String,String>();
        
        //key=accId+ProgramId+Geo, value=List<ActivityId>
        Map<String,List<Id>> accountIdProgramIdGeoActivityIdListMap = new Map<String,List<Id>>();
        
        //key=accId+ProgramId+Geo+SubGeo, value=List<ActivityId>
        Map<String,List<Id>> accountIdProgramIdGeoSubGeoActivityIdListMap = new Map<String,List<Id>>();
        
        //for WW -> key=accId+ProgramId, value=List<ActivityId>
        Map<String,List<Id>> accountIdProgramIdActivityIdListMap = new Map<String,List<Id>>();
        
        List<PartnerFundRequestShare> pfrShareList = new List<PartnerFundRequestShare>();
        try{
            //Iterate over Country Geo Mapping metadat to prepare countryGeoMap
            for(Core_MDF_CCP_Country_Geo_Mapping__mdt cgm : [SELECT MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c  
                                                             FROM Core_MDF_CCP_Country_Geo_Mapping__mdt]){
                countryGeoMap.put(cgm.MasterLabel,cgm.Core_MDF_Geo__c);
                countrySubGeoMap.put(cgm.MasterLabel,cgm.Core_MDF_Sub_Geo__c);
            }
            
            //Iterate over pfrIdList to form accountIdProgramIdGeoSubGeoActivityIdListMap
            for(PartnerFundRequest pfr : [SELECT Campaign.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c, Core_MDF_Region_cd__c,
                                          ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Country_nm__c, Core_MDF_Sub_Region_cd__c 
                                          FROM PartnerFundRequest WHERE Id IN : pfrIdList]){
                if(pfr.Campaign.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c != NULL && pfr.ChannelPartner.Core_MDF_Channel_Program__c != NULL){
                    accountIdSet.add(pfr.Campaign.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c); 
                    programIdSet.add(pfr.ChannelPartner.Core_MDF_Channel_Program__c);
                    if(String.isNotBlank(pfr.Core_MDF_Region_cd__c)){
                        //for(String countryString : pfr.Core_MDF_Country_nm__c.split(';')){
                        String geo = pfr.Core_MDF_Region_cd__c;
                        String subGeo = pfr.Core_MDF_Sub_Region_cd__c;
                        
                        geoSet.add(geo);
                        String accountIdProgramIdGeo = (String)pfr.Campaign.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c + (String)pfr.ChannelPartner.Core_MDF_Channel_Program__c + geo;
                        
                        //Only Geo
                        if(accountIdProgramIdGeoActivityIdListMap.containsKey(accountIdProgramIdGeo)){ accountIdProgramIdGeoActivityIdListMap.get(accountIdProgramIdGeo).add(pfr.Id);
                        }
                        else{
                            accountIdProgramIdGeoActivityIdListMap.put(accountIdProgramIdGeo, new List<Id>{pfr.Id});
                        }
                        
                        //Geo and SubGeo
                        if(String.isNotBlank(subGeo)){
                            String accountIdProgramIdGeoSubGeo = (String)pfr.Campaign.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c + (String)pfr.ChannelPartner.Core_MDF_Channel_Program__c + geo + subGeo;
                            if(accountIdProgramIdGeoSubGeoActivityIdListMap.containsKey(accountIdProgramIdGeoSubGeo)){ accountIdProgramIdGeoSubGeoActivityIdListMap.get(accountIdProgramIdGeoSubGeo).add(pfr.Id);
                            }
                            else{
                                accountIdProgramIdGeoSubGeoActivityIdListMap.put(accountIdProgramIdGeoSubGeo, new List<Id>{pfr.Id});
                            }
                        }
                        //for WW
                        accountIdProgramIdGeo = accountIdProgramIdGeo.left(36);
                        if(accountIdProgramIdActivityIdListMap.containsKey(accountIdProgramIdGeo)){ accountIdProgramIdActivityIdListMap.get(accountIdProgramIdGeo).add(pfr.Id);
                        }
                        else{
                            accountIdProgramIdActivityIdListMap.put(accountIdProgramIdGeo, new List<Id>{pfr.Id});
                        }
                    }
                }
            }
            System.debug('accountIdSet: ' + accountIdSet);
            System.debug('programIdSet: ' + programIdSet);
            System.debug('geoSet: ' + geoSet);
            System.debug('accountIdProgramIdGeoSubGeoActivityIdListMap: ' + accountIdProgramIdGeoSubGeoActivityIdListMap);
            System.debug('accountIdProgramIdGeoActivityIdListMap: ' + accountIdProgramIdGeoActivityIdListMap);
            System.debug('accountIdProgramIdActivityIdListMap: ' + accountIdProgramIdActivityIdListMap);
            Core_MDF_CCP_GenericUtility.createShareRecordsForInternal('PartnerFundRequest', accountIdSet, programIdSet, geoSet, 
                                                                      accountIdProgramIdGeoSubGeoActivityIdListMap, accountIdProgramIdGeoActivityIdListMap, 
                                                                      accountIdProgramIdActivityIdListMap);
            
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /***************************************************************************************************** 
    Method Name   :        createShareForBank
    @return       :        void
    @parameters   :        List of Bank Id's
    Description   :        Creates share record for Bank based on geo
    Added By      :        Accenture - VK - 08/05/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public static void createShareForBank(List<Id> bankIdList){
        //Key=Channel Program, value=Bank Program
        Map<String,String> channelProgramBankProgramMap = new Map<String,String>();

        //Key=Bank Program, value=Channel Program
        Map<String,String> bankProgramChannelProgramNameMap = new Map<String,String>();
        
        //key=Bank Program, value=Channel Program Id
        Map<String,String> bankProgramChannelProgramIdMap = new Map<String,String>();
        
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> channelProgramIdSet = new Set<Id>();
        Set<String> geoSet = new Set<String>();
        
        //key=2 digit country code, value=Geo
        Map<String,String> countryCodeGeoMap = new Map<String,String>();
        
        //key=2 digit country code, value=SubGeo
        Map<String,String> countryCodeSubGeoMap = new Map<String,String>();
        
        //Key=AccId+ProgramId+Geo, value=List<BankId>
        Map<String,List<Id>> accountIdChannelProgramIdGeoBankIdsMap = new Map<String,List<Id>>();
        
        //Key=AccId+ProgramId+Geo+SubGeo, value=List<BankId>
        Map<String,List<Id>> accountIdChannelProgramIdGeoSubGeoBankIdsMap = new Map<String,List<Id>>();
        
        //For WW -> Key=AccId+ProgramId, value=List<BankId>
        Map<String,List<Id>> accountIdChannelProgramIdBankIdsMap = new Map<String,List<Id>>(); 

        List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
        
        try{
            //Iterate over BankProgram Entitlement Metadata to prepare channelProgramBankProgramMap
            for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem : ([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c
                                                                       FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt])){
                channelProgramBankProgramMap.put(bpem.Core_MDF_Channel_Program__c, bpem.Core_MDF_Bank_Program_Name__c);
                bankProgramChannelProgramNameMap.put(bpem.Core_MDF_Bank_Program_Name__c, bpem.Core_MDF_Channel_Program__c);
            }
            
            //Iterate over Channel Program to prepare bankProgramChannelProgramIdMap
            for(ChannelProgram cp : [SELECT Id, Name
                                     FROM ChannelProgram
                                     WHERE Name IN :channelProgramBankProgramMap.keySet()]){
                if(channelProgramBankProgramMap.get(cp.Name) != NULL){
                    bankProgramChannelProgramIdMap.put(channelProgramBankProgramMap.get(cp.Name),cp.Id);
                    //channelProgramIdSet.add(cp.Id);
                }
            }
            
            //Get the Map of Country code and Geo using Country Geo Mapping Metadata
            for(Core_MDF_CCP_Country_Geo_Mapping__mdt cgm : [SELECT Core_MDF_Code_2_Digits__c,Core_MDF_Geo__c, Core_MDF_Sub_Geo__c
                                                             FROM Core_MDF_CCP_Country_Geo_Mapping__mdt]){
                countryCodeGeoMap.put(cgm.Core_MDF_Code_2_Digits__c,cgm.Core_MDF_Geo__c);
                countryCodeSubGeoMap.put(cgm.Core_MDF_Code_2_Digits__c,cgm.Core_MDF_Sub_Geo__c);
            }
            
            //Iterate over BankId List to prepare required Set and Map
            for(Core_MDF_Bank__c bank : [SELECT Core_MDF_Account__c, Core_MDF_Program__c, Core_MDF_Bank_Location__c
                                         FROM Core_MDF_Bank__c
                                         WHERE Id IN : bankIdList]){
                accountIdSet.add(bank.Core_MDF_Account__c); 
        geoSet.add(countryCodeGeoMap.get(bank.Core_MDF_Bank_Location__c));
                List<String> bankProgramList = bank.Core_MDF_Program__c.split(Label.Core_MDF_Semicolon);
                
                for(String bankProgram : bankProgramList){
                    if(!channelProgramIdSet.contains(bankProgramChannelProgramIdMap.get(bankProgram))){
                        channelProgramIdSet.add(bankProgramChannelProgramIdMap.get(bankProgram));
                    }
                    if(bank.Core_MDF_Account__c != NULL && 
                       countryCodeGeoMap.containsKey(bank.Core_MDF_Bank_Location__c)){                        
                        
                        if(countryCodeSubGeoMap.containsKey(bank.Core_MDF_Bank_Location__c)){//if SubGeo is present
                            String accountIdProgramIdGeoSubGeo = (String)bank.Core_MDF_Account__c + bankProgramChannelProgramIdMap.get(bankProgram) + countryCodeGeoMap.get(bank.Core_MDF_Bank_Location__c) + countryCodeSubGeoMap.get(bank.Core_MDF_Bank_Location__c);

                            recordGeoShareList.add(new Core_MDF_RecordGeoShare(bank.Id,countryCodeGeoMap.get(bank.Core_MDF_Bank_Location__c),countryCodeSubGeoMap.get(bank.Core_MDF_Bank_Location__c), bankProgramChannelProgramNameMap.get(bankProgram)));
                            
                            //Geo and SubGeo
                            if(accountIdChannelProgramIdGeoSubGeoBankIdsMap.containsKey(accountIdProgramIdGeoSubGeo)){ accountIdChannelProgramIdGeoSubGeoBankIdsMap.get(accountIdProgramIdGeoSubGeo).add(bank.Id);
                            }
                            else{
                                accountIdChannelProgramIdGeoSubGeoBankIdsMap.put(accountIdProgramIdGeoSubGeo, new List<String>{bank.Id});
                            }
                        }

                        String accountIdProgramIdGeo = (String)bank.Core_MDF_Account__c + bankProgramChannelProgramIdMap.get(bankProgram) + countryCodeGeoMap.get(bank.Core_MDF_Bank_Location__c);
                        
                        //Only Geo
                        if(accountIdChannelProgramIdGeoBankIdsMap.containsKey(accountIdProgramIdGeo)){ accountIdChannelProgramIdGeoBankIdsMap.get(accountIdProgramIdGeo).add(bank.Id);
                        }
                        else{
                            accountIdChannelProgramIdGeoBankIdsMap.put(accountIdProgramIdGeo, new List<String>{bank.Id});
                        }
                        
                        //for WW
                        accountIdProgramIdGeo = (String)bank.Core_MDF_Account__c + bankProgramChannelProgramIdMap.get(bankProgram);
                        if(accountIdChannelProgramIdBankIdsMap.containsKey(accountIdProgramIdGeo)){ accountIdChannelProgramIdBankIdsMap.get(accountIdProgramIdGeo).add(bank.Id);
                        }
                        else{
                            accountIdChannelProgramIdBankIdsMap.put(accountIdProgramIdGeo, new List<String>{bank.Id});
                        }
                    }
                    
                }
            }
            
            Core_MDF_CCP_GenericUtility.createShareRecordsForInternal('Core_MDF_Bank__c', accountIdSet, channelProgramIdSet, geoSet, 
                                                                      accountIdChannelProgramIdGeoSubGeoBankIdsMap, accountIdChannelProgramIdGeoBankIdsMap, 
                                                                      accountIdChannelProgramIdBankIdsMap);
            if(recordGeoShareList != NULL && recordGeoShareList.size() >0){                        
                Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroup('Core_MDF_Bank__c',recordGeoShareList);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    public class CountryGeoSubGeoWrapper{
        public String country;
        public String geo;
        public String subGeo;
        public String countryCode;
    }
    
    /***************************************************************************************************** 
    Method Name   :        getCountryGeoMap
    @return       :        Map of Country and CountryGeoSubGeoWrapper
    @parameters   :        NULL
    Description   :        Prepares the country-geo-subGeo mapping
    Added By      :        Accenture - VK - 08/05/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public static Map<String,countryGeoSubGeoWrapper> getCountryGeoMap(){
        
        Map<String,countryGeoSubGeoWrapper> countryWrapperMap = new Map<String,countryGeoSubGeoWrapper>();
        
        try{
            List<Core_MDF_CCP_Country_Geo_Mapping__mdt> cgmList = [SELECT MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c, Core_MDF_Code_2_Digits__c
                                                                   FROM Core_MDF_CCP_Country_Geo_Mapping__mdt];
            
            if(cgmList != NULL && cgmList.size() > 0){
                for(Core_MDF_CCP_Country_Geo_Mapping__mdt mdt : cgmList){
                    countryGeoSubGeoWrapper countryGeoSubGeoInst = new countryGeoSubGeoWrapper();
                    countryGeoSubGeoInst.country = mdt.MasterLabel;
                    countryGeoSubGeoInst.geo = mdt.Core_MDF_Geo__c;
                    countryGeoSubGeoInst.subGeo = mdt.Core_MDF_Sub_Geo__c;
                    countryGeoSubGeoInst.countryCode = mdt.Core_MDF_Code_2_Digits__c;
                    countryWrapperMap.put(countryGeoSubGeoInst.country, countryGeoSubGeoInst);
                }
            }                                                 
            return countryWrapperMap;
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);return NULL;}
    }
}