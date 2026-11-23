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
        try{
            if(String.isNotEmpty(objectName) && recordIdList.size() > 0){
                
                switch on objectName {
                    
                    when 'PartnerFundRequest'{
                        Core_MDF_GeoBasedGenericSharing.createShareForPFR(recordIdList);                    
                    }
                    
                    /*when 'Core_MDF_Bank__c'{
                        Core_MDF_GeoBasedGenericSharing.createShareForBank(recordIdList);
                    }*/
                    
                }
                
            }
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
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
       
        

        List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
        
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        
        String region = '';
        String subRegion = ''; 

        try{
            //Iterate over Country Geo Mapping metadat to prepare countryGeoMap
            
             List<String> budgetTypeBasedProg = new List<string>{Label.Core_MDF_IPA_Program_Name,Label.Core_MDF_EEF_Program_Name,Label.Core_MDF_Co_GTM_program_name};
            //Iterate over pfrIdList to form accountIdProgramIdGeoSubGeoActivityIdListMap
            // US949836 : New Budget Type field changes replaced txt field with new global picklist field
            for(PartnerFundRequest pfr : [SELECT Id, ChannelPartnerId, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Region_nm__c,Core_MDF_Host_Region_txt__c,Core_MDF_Sub_Region_nm__c,Core_MDF_Proposal_Based_Ind__c,
                                          ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Country_nm__c,Core_MDF_Campaign_Ultimate_Account_Id__c, 
                                          ChannelPartner.Core_MDF_Channel_Program__r.Name, Core_MDF_Program__c, Core_MDF_Budget_Type_nm__c,Campaign.Core_MDF_Proposal_Based_Ind__c
                                          FROM PartnerFundRequest WHERE Id IN : pfrIdList]){
            	// US - TWC702-14285: Flatten nested IFs (no logic change)                            
            	if(pfr.ChannelPartnerId == NULL || pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c == NULL || pfr.ChannelPartner.Core_MDF_Channel_Program__c == NULL) continue;
                                                  
                                                  
            		//Budget Type based sharing program
            		// US - TWC702-14285: Flatten nested IFs (no logic change)
            		if(budgetTypeBasedProg.contains(pfr.Core_MDF_Program__c)){      
                		if(String.isBlank(pfr.Core_MDF_Region_nm__c)) continue;
                                if(pfr.Core_MDF_Program__c == Label.Core_MDF_Co_GTM_program_name){
                                	for(String geo : pfr.Core_MDF_Region_nm__c.split(';')){
                                        	recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfr.Id, geo, subRegion, pfr.ChannelPartner.Core_MDF_Channel_Program__r.Name, pfr.Core_MDF_Budget_Type_nm__c));
                                                          
                                                                
                                                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfr.id, geo,pfr.Core_MDF_Sub_Region_nm__c,pfr.Core_MDF_Program__c,pfr.Core_MDF_Budget_Type_nm__c,
                                                                                                                            pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
                                        }
                                }
                                else{
                                	region = (String.isNotBlank(pfr.Core_MDF_Host_Region_txt__c)) ? pfr.Core_MDF_Host_Region_txt__c : pfr.Core_MDF_Region_nm__c;
                                        subRegion = pfr.Core_MDF_Sub_Region_nm__c;
                                                          
                                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfr.Id, region, subRegion, pfr.ChannelPartner.Core_MDF_Channel_Program__r.Name, pfr.Core_MDF_Budget_Type_nm__c));
                                                         
                                                          
                                        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfr.id, region,pfr.Core_MDF_Sub_Region_nm__c,pfr.Core_MDF_Program__c,pfr.Core_MDF_Budget_Type_nm__c,
                                                                                                                    pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
                                                           
                                        //Share the activity with Primary Account users (Campaign Account)
                                        if(pfr.Core_MDF_Program__c == Label.Core_MDF_EEF_Program_Name){
                                        	recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfr.id, region,pfr.Core_MDF_Sub_Region_nm__c,pfr.Core_MDF_Program__c,pfr.Core_MDF_Budget_Type_nm__c,
                                                                                                                    pfr.Core_MDF_Campaign_Ultimate_Account_Id__c));
                                        }
                                }
                                                          
                        }      
                        else{ 
                        	//US1098882: Replaced Core_MDF_Region_cd__c with Core_MDF_Region_nm__c && Core_MDF_Sub_Region_cd__c with Core_MDF_Sub_Region_nm__c
                		if(String.isBlank(pfr.Core_MDF_Region_nm__c)) continue;
                                                          
                                String geo = (String.isNotBlank(pfr.Core_MDF_Host_Region_txt__c)) ? pfr.Core_MDF_Host_Region_txt__c : pfr.Core_MDF_Region_nm__c;
                                String subGeo = pfr.Core_MDF_Sub_Region_nm__c;
                                                          
                                                          
                                                          
                                // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                                                                            
                                                          
                                                          
                                recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfr.Id, geo, subGeo, pfr.ChannelPartner.Core_MDF_Channel_Program__r.Name));
                                                           
                                                          
                                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfr.id, geo, pfr.Core_MDF_Sub_Region_nm__c, pfr.Core_MDF_Program__c,
                                                                                                                        pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c)); 
                                                          
                                                         
                                                             
                                                      
                                                      
                        }//end of ipa else
                        //end of account check            
                }
            
            
            	if(recordPGMShareList != null && recordPGMShareList.size() >0){
                	Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('PartnerFundRequest', recordPGMShareList);
            	}
            	if(recordGeoShareList != NULL && recordGeoShareList.size() >0){ 
                                     
                	Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroup('PartnerFundRequest',recordGeoShareList);
            	}
            
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
    /*public static void createShareForBank(List<Id> bankIdList){
        //Key=Channel Program, value=Bank Program
        Map<String,String> channelProgramBankProgramMap = new Map<String,String>();
        
        //Key=Bank Program, value=Channel Program
        Map<String,String> bankProgramChannelProgramNameMap = new Map<String,String>();
        
        //key=Bank Program, value=Channel Program Id
        Map<String,String> bankProgramChannelProgramIdMap = new Map<String,String>();        
        
        //key=2 digit country code, value=Geo
        Map<String,String> countryCodeGeoMap = new Map<String,String>();
        
        //key=2 digit country code, value=SubGeo
        Map<String,String> countryCodeSubGeoMap = new Map<String,String>();
        
        List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
        
        List<Core_MDF_RecordGeoShare> recordGeoShareForBudgetTypeList = new List<Core_MDF_RecordGeoShare>();
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        
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
                                             List<String> bankProgramList = bank.Core_MDF_Program__c.split(Label.Core_MDF_Semicolon);
                                             
                                             for(String bankProgram : bankProgramList){
                                                 if(bank.Core_MDF_Account__c != NULL && 
                                                    countryCodeGeoMap.containsKey(bank.Core_MDF_Bank_Location__c)){                        
                                                        
                                                        if(countryCodeSubGeoMap.containsKey(bank.Core_MDF_Bank_Location__c)){//if SubGeo is present
                                                            if(bankProgramChannelProgramNameMap.get(bankProgram) ==Label.Core_MDF_IPA_Program_Name){
                                                                
                                                                recordGeoShareForBudgetTypeList.add(new Core_MDF_RecordGeoShare(bank.Id,countryCodeGeoMap.get(bank.Core_MDF_Bank_Location__c),countryCodeSubGeoMap.get(bank.Core_MDF_Bank_Location__c), bankProgramChannelProgramNameMap.get(bankProgram)));
                                                            }
                                                            else{
                                                                recordGeoShareList.add(new Core_MDF_RecordGeoShare(bank.Id,countryCodeGeoMap.get(bank.Core_MDF_Bank_Location__c),countryCodeSubGeoMap.get(bank.Core_MDF_Bank_Location__c), bankProgramChannelProgramNameMap.get(bankProgram)));
                                                            }
                                                            recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(bank.ID,countryCodeGeoMap.get(bank.Core_MDF_Bank_Location__c),countryCodeSubGeoMap.get(bank.Core_MDF_Bank_Location__c), bankProgramChannelProgramNameMap.get(bankProgram),bank.Core_MDF_Account__c));                                                        
                                                        }
                                                    }                    
                                             }
                                         }
            
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Bank__c', recordPGMShareList);
            }
            if(recordGeoShareList != NULL && recordGeoShareList.size() >0){
                Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroup('Core_MDF_Bank__c',recordGeoShareList);
            }
            
            if(recordGeoShareForBudgetTypeList != NULL && !recordGeoShareForBudgetTypeList.isEmpty()){
                shareRecordToGeoGroup('Core_MDF_Bank__c',recordGeoShareForBudgetTypeList);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }*/
    
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
                                                                   FROM Core_MDF_CCP_Country_Geo_Mapping__mdt LIMIT 1000];
            
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
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        return countryWrapperMap;
    }
    
    public static void shareRecordToGeoGroup(String objectName, List<Core_MDF_RecordGeoShare> recordGeoShareLst){
        List<Core_MDF_RecordGeoShare> updatedRecordGeoShareLst = createBudgetTypeShareRecords(recordGeoShareLst);
        Map<Id,List<Id>> recordGeoShareMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> recordGeoShareMapRO = new Map<Id,List<Id>>();
        //To create a map of the record and the respective groups it should be shared for Edit and Read Only.
        if(updatedRecordGeoShareLst != NULL && !updatedRecordGeoShareLst.isEmpty()){
            for(Core_MDF_RecordGeoShare rec : updatedRecordGeoShareLst){
                
                if(recordGeoShareMap.containsKey(rec.recordId)){recordGeoShareMap.get(rec.recordId).addAll(rec.groupId);
                                                               }
                else{
                    recordGeoShareMap.put(rec.recordId, rec.groupId.clone());
                }
                if(recordGeoShareMapRO.containsKey(rec.recordId)){recordGeoShareMapRO.get(rec.recordId).addAll(rec.groupId_RO);
                                                                 }
                else{
                    recordGeoShareMapRO.put(rec.recordId, rec.groupId_RO.clone());
                }
            }
            
            // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
            // to share the Record to the respective Group with Edit Access
            if(recordGeoShareMap != NULL && recordGeoShareMap.size()>0){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMap, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
            // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
            // to share the Record to the respective Group with Read Access
            if(recordGeoShareMapRO != NULL && recordGeoShareMapRO.size()>0){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInstRead = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMapRO, 'Read');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInstRead);
            }
        }
    }
    
    public static List<Core_MDF_RecordGeoShare> createBudgetTypeShareRecords(List<Core_MDF_RecordGeoShare> recordGeoShareLst){
        Set<String> programSet = new Set<string>();
        Set<String> groupNames = new Set<String>();
        Map<String, Set<String>> programGeoSubGeoRWGroupsMap = new Map<String, Set<String>>();
        Map<String, Set<String>> programGeoRWGroupsMap = new Map<String, Set<String>>();
        Map<String, Set<String>> programRWGroupsMap = new Map<String, Set<String>>();
        Map<String, Set<String>> programGeoSubGeoROGroupsMap = new Map<String, Set<String>>();
        Map<String, Set<String>> programGeoROGroupsMap = new Map<String, Set<String>>();
        Map<String, Set<String>> programROGroupsMap = new Map<String, Set<String>>();
        //Map to store the GroupName and their corresponding Id.
        Map<string,Id> grpNametoIdMap = new Map<string,Id>();
        
        for(Core_MDF_RecordGeoShare shareRec : recordGeoShareLst)
        {
            programSet.add(shareRec.program);
        }
        
        //to get all the groups of the incoming programs
        for(Core_MDF_ProgramGeoGroupMap__mdt rec : [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,
                                                    Core_MDF_Sub_Region__c,Core_MDF_Check_SubGeo__c,Core_MDF_Budget_Type_txt__c
                                                    FROM Core_MDF_ProgramGeoGroupMap__mdt WHERE Core_MDF_Program__c IN :programSet]){
        	// US - TWC702-14285: Flatten nested IFs (no logic change)                                          
        	if(rec.Core_MDF_Region__c != NULL && rec.Core_MDF_Check_SubGeo__c && rec.Core_MDF_Sub_Region__c != NULL){
            		//Create a String with Program + Geo + SubGeo
            		String programGeoSubGeoStr = '';
            		programGeoSubGeoStr = rec.Core_MDF_Program__c + '-' + rec.Core_MDF_Region__c + '-' + rec.Core_MDF_Sub_Region__c;
            		if(programGeoSubGeoRWGroupsMap.containsKey(programGeoSubGeoStr)){
                		Set<String> groupSet = programGeoSubGeoRWGroupsMap.get(programGeoSubGeoStr);
                
                		groupSet.add(rec.Core_MDF_Group_Name__c);
                		programGeoSubGeoRWGroupsMap.put(programGeoSubGeoStr, groupSet);
            		}
            		else{
                		Set<String> groupSet = new Set<String>();
                		groupSet.add(rec.Core_MDF_Group_Name__c);
                		programGeoSubGeoRWGroupsMap.put(programGeoSubGeoStr, groupSet);
            		}
            
            		if(programGeoSubGeoROGroupsMap.containsKey(programGeoSubGeoStr)){
                		Set<String> groupSet = programGeoSubGeoROGroupsMap.get(programGeoSubGeoStr);
                		groupSet.add(rec.Core_MDF_Group_Name_RO__c);
                		programGeoSubGeoROGroupsMap.put(programGeoSubGeoStr, groupSet);
            		}
            		else{
                		Set<String> groupSet = new Set<String>();
                		groupSet.add(rec.Core_MDF_Group_Name_RO__c);
                		programGeoSubGeoROGroupsMap.put(programGeoSubGeoStr, groupSet);
            		}
            
            		groupNames.add(rec.Core_MDF_Group_Name__c);
            		groupNames.add(rec.Core_MDF_Group_Name_RO__c);
        	}
        	// US - TWC702-14285: Flatten nested IFs (no logic change)
        	else if(rec.Core_MDF_Region__c != NULL){
            		//Program + Geo
            		String programGeoStr = '';
            		programGeoStr = rec.Core_MDF_Program__c + '-' + rec.Core_MDF_Region__c;
            		if(programGeoRWGroupsMap.containsKey(programGeoStr)){
                		Set<String> groupSet = programGeoRWGroupsMap.get(programGeoStr);
                		groupSet.add(rec.Core_MDF_Group_Name__c);
                		programGeoRWGroupsMap.put(programGeoStr, groupSet);
            		}
            		else{
                		Set<String> groupSet = new Set<String>();
                		groupSet.add(rec.Core_MDF_Group_Name__c);
                		programGeoRWGroupsMap.put(programGeoStr, groupSet);
            		}
            
            		if(programGeoROGroupsMap.containsKey(programGeoStr)){
                		Set<String> groupSet = programGeoROGroupsMap.get(programGeoStr);
                		groupSet.add(rec.Core_MDF_Group_Name_RO__c);
                		programGeoROGroupsMap.put(programGeoStr, groupSet);
            		}
            		else{
                		Set<String> groupSet = new Set<String>();
                		groupSet.add(rec.Core_MDF_Group_Name_RO__c);
                		programGeoROGroupsMap.put(programGeoStr, groupSet);
            		}
            
            		groupNames.add(rec.Core_MDF_Group_Name__c);
            		groupNames.add(rec.Core_MDF_Group_Name_RO__c);
        	}
        	// US - TWC702-14285: Flatten nested IFs (no logic change)
        	else if(rec.Core_MDF_Program__c != NULL){
            		//Program
            		String programStr = '';
            		programStr = rec.Core_MDF_Program__c + '-';
            
            		if(programRWGroupsMap.containsKey(programStr)){
                		Set<String> groupSet = programRWGroupsMap.get(programStr);
                		groupSet.add(rec.Core_MDF_Group_Name__c);
                		programRWGroupsMap.put(programStr, groupSet);
            		}
            		else{
                		Set<String> groupSet = new Set<String>();
                		groupSet.add(rec.Core_MDF_Group_Name__c);
                		programRWGroupsMap.put(programStr, groupSet);
            		}
            		if(programROGroupsMap.containsKey(programStr)){
                		Set<String> groupSet = programROGroupsMap.get(programStr);
                		groupSet.add(rec.Core_MDF_Group_Name_RO__c);
                		programROGroupsMap.put(programStr, groupSet);
            		}
            		else{
                		Set<String> groupSet = new Set<String>();
                		groupSet.add(rec.Core_MDF_Group_Name_RO__c);
                		programROGroupsMap.put(programStr, groupSet);
            		}
            		groupNames.add(rec.Core_MDF_Group_Name__c);
            		groupNames.add(rec.Core_MDF_Group_Name_RO__c);
        	}
    	}
    
        //Fetch Group Ids
        for(Group grp:[SELECT Id, DeveloperName FROM Group where DeveloperName IN :groupNames]){
            grpNametoIdMap.put(grp.DeveloperName, grp.Id);
        }
        
        //To Loop thro each RecordGeoShare record and store the groups that it should be shared with
        for(Core_MDF_RecordGeoShare record: recordGeoShareLst){
            //to store rw group id's
            List<Id> grpLst = new List<Id>();
            //to store ro group id's
            List<Id> grpLstRO = new List<Id>();
            
            if(programGeoSubGeoRWGroupsMap.containsKey(record.program + '-' + record.geo + '-' + record.subGeo)){
                for(String groupName : programGeoSubGeoRWGroupsMap.get(record.program + '-' + record.geo + '-' + record.subGeo)){
                    grpLst.add(grpNametoIdMap.get(groupName));
                }
            }
            
            if(programGeoRWGroupsMap.containsKey(record.program + '-' + record.geo)){
                for(String groupName : programGeoRWGroupsMap.get(record.program + '-' + record.geo)){
                    grpLst.add(grpNametoIdMap.get(groupName));
                }
            }
            
            if(programRWGroupsMap.containsKey(record.program + '-')){
                for(String groupName : programRWGroupsMap.get(record.program + '-')){
                    grpLst.add(grpNametoIdMap.get(groupName));
                }
            }
            
            if(programGeoSubGeoROGroupsMap.containsKey(record.program + '-' + record.geo + '-' + record.subGeo)){
                for(String groupName : programGeoSubGeoROGroupsMap.get(record.program + '-' + record.geo + '-' + record.subGeo)){
                    grpLstRO.add(grpNametoIdMap.get(groupName));
                }
            }
            
            if(programGeoROGroupsMap.containsKey(record.program + '-' + record.geo)){
                for(String groupName : programGeoROGroupsMap.get(record.program + '-' + record.geo)){
                    grpLstRO.add(grpNametoIdMap.get(groupName));
                }
            }
            
            if(programROGroupsMap.containsKey(record.program + '-')){
                for(String groupName : programROGroupsMap.get(record.program + '-')){
                    grpLstRO.add(grpNametoIdMap.get(groupName));
                }
            }
            
            if(grpLst != NULL && !grpLst.isEmpty()){
                record.groupId = grpLst;
            }
            if(grpLstRO != NULL && !grpLstRO.isEmpty()){
                record.groupId_RO = grpLstRO;
            }
        }
        return recordGeoShareLst;
    }
}