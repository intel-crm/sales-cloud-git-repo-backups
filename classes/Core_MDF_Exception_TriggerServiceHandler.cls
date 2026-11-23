/*
* Class Name        : Core_MDF_Exception_TriggerServiceHandler
* Created Date      : 19-06-2019
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SS        19-06-2019          Exception Trigger Service Handler which handles the sharing of the Exception with appropriate users          
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Exception_TriggerServiceHandler {
    static Boolean flag = false;
    /****************************************************************************************************************************************
    * Method Name           : shareExceptionRecordsWithUsersForUpdate
    * Created Date          : 19-06-2019
    * Modification Log
    * Developer            Date               Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    Accenture SS         19-06-2019          Exception Trigger Service Handler method for update scenario which handles setting the flag to true
    *****************************************************************************************************************************************/
    public static void shareExceptionRecordsWithUsersForUpdate(Map <Id , Core_MDF_Exception__c> newExceptionMap ){
        flag = true;
        System.debug('newExceptionMap.keySet()'+newExceptionMap.keySet());
        List<Core_MDF_Exception__Share> exceptionShareList = new List<Core_MDF_Exception__Share>();
        for(Core_MDF_Exception__Share exceptionShareRecord : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                              FROM Core_MDF_Exception__Share
                                                              WHERE ParentId IN :newExceptionMap.keySet() AND
                                                                    RowCause =: Label.Core_MDF_RowCause_Manual]){
            exceptionShareList.add(exceptionShareRecord);
        }
        if(exceptionShareList != NULL && exceptionShareList.size() > 0){
            delete exceptionShareList;
        }
        shareExceptionRecordsWithInternalUsers(newExceptionMap);
        
    }
    
    /****************************************************************************************************************************************
    * Method Name           : shareExceptionRecordsWithInternalUsers
    * Created Date          : 17-09-2019
    * Modification Log
    * Developer            Date               Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    Accenture SB         17-09-2019          Exception Trigger Service Handler which handles the sharing of the Exception with appropriate Internal users          
    *****************************************************************************************************************************************/
        
    
    
    public static void shareExceptionRecordsWithInternalUsers( Map<Id , Core_MDF_Exception__c> newExceptionMap )
    {
        try{
            Set<Id> intelAccountIdSet = new Set<Id>();
            Set<Id> programIdSet = new Set<Id>();
            Set<String> geoSet = new Set<String>();

            Set<Core_MDF_Exception__c> exceptionWithErrorSet = new Set<Core_MDF_Exception__c>();
            
            Map<String,Set<String>> geoSubGeoSetMap = new Map<String,Set<String>>();

            // Map of ChannelProgramId+AccountId with Set of exception // For Single Account Exception
            Map< String, Set<Core_MDF_Exception__c>> channelPrgIdAccIdExptListMap = new Map< String, Set<Core_MDF_Exception__c>>();
            
            // Map of ChannelProgramId and Set of exception // For Select All Accounts Exception
            Map< String, Set<Core_MDF_Exception__c>> allAccChannelProgramExptListMap = new Map< String, Set<Core_MDF_Exception__c>>();
            
            //key=ChannelProgramId+AccountId+Geo, value=Set<ExceptionRecord>
            Map<String, Set<Core_MDF_Exception__c>> channelPrgIdAccIdGeoExptSetMap = new Map<String, Set<Core_MDF_Exception__c>>();

            //key=ChannelProgramId+AccountId+Geo+SubGeo, value=Set<ExceptionRecord>
            Map<String, Set<Core_MDF_Exception__c>> channelPrgIdAccIdGeoSubGeoExptSetMap = new Map<String, Set<Core_MDF_Exception__c>>();

            //for WW -> key=ChannelProgramId+AccountId, value=Set<ExceptionRecord>
            Map<String, Set<Core_MDF_Exception__c>> channelPrgIdAccIdWWExptSetMap = new Map<String, Set<Core_MDF_Exception__c>>();
            
            //key=ChannelProgramId+AccountId, value=Set<ExceptionRecord>
            Map<String, Set<Core_MDF_Exception__c>> channelPrgIdAccIdExptSetMap = new Map<String, Set<Core_MDF_Exception__c>>();
            
            //key=ChannelProgramId+Geo, value=Set<ExceptionRecord>
            Map<String, Set<Core_MDF_Exception__c>> channelPrgIdGeoExptSetMap = new Map<String, Set<Core_MDF_Exception__c>>();

            //key=ChannelProgramId+Geo+SubGeo, value=Set<ExceptionRecord>
            Map<String, Set<Core_MDF_Exception__c>> channelPrgIdGeoSubGeoExptSetMap = new Map<String, Set<Core_MDF_Exception__c>>();

            //for WW -> key=ChannelProgramId, value=Set<ExceptionRecord>
            Map<String, Set<Core_MDF_Exception__c>> channelPrgIdWWExptSetMap = new Map<String, Set<Core_MDF_Exception__c>>();
            
            //key=ChannelProgramId, value=Set<ExceptionRecord>
            Map<String, Set<Core_MDF_Exception__c>> channelPrgIdExptSetMap = new Map<String, Set<Core_MDF_Exception__c>>();
            
            //key=ChannelProgramId+AccountId+Geo, value=Set<GroupId>
            Map<String, Set<String>> channelPrgIdAccIdGeoGroupIdSetMap = new Map<String, Set<String>>();
            
            //key=ChannelProgramId+AccountId+WW, value=Set<GroupId>
            Map<String, Set<String>> channelPrgIdAccIdWWGroupIdSetMap = new Map<String, Set<String>>();
            
            //key=ChannelProgramId+AccountId, value=Set<GroupId>
            Map<String, Set<String>> channelPrgIdAccIdGroupIdSetMap = new Map<String, Set<String>>();
            
            //key=ChannelProgramId+Geo, value=Set<GroupId>
            Map<String, Set<String>> channelPrgIdGeoGroupIdSetMap = new Map<String, Set<String>>();
            
            //key=ChannelProgramId, value=Set<GroupId>
            Map<String, Set<String>> channelPrgIdGroupIdSetMap = new Map<String, Set<String>>();
            
            //Set which stores Exception Channel Program Id's
            Set<String> exceptionChannelPrgIdsSet = new Set<String>();

            //Fetch associated channel partner Core_MDF Name
            Map<String,  String> channelProgramNameMap = new Map<String,  String>();

            // Map of Channel Program Id and Channel Program Name
            Map<String,  String> channelProgramNameIdMap = new Map< String,  String >();

            //key=country, value=geo
            Map<String,String> countryGeoMap = new Map<String,String>();

            //key=country, value=SubGeo
            Map<String,String> countrySubGeoMap = new Map<String,String>();
            
            //key = exception id, value = true to throw error
            Map<Id , Boolean> exceptionIdAccountErrorCheckMap = new Map<Id , Boolean>();

            Boolean blnAllAccountsFlag = false;

            String pgmQueryStr = '';

            String strAccountWHEREClause = '';

            //Construct Share Records
            Set< Core_MDF_Exception__Share > exptShareSet = new Set< Core_MDF_Exception__Share >();

            Set<String> exceptionIdGroupIdStrSet = new Set<String>();

            List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
            
            //This contains the mapping of account Id and its related programs. This will be fetched from the Account Hierarchy
            Map<Id, Set<String>> accountIdProgramStrSetMap = new Map<Id, Set<String>>();

            //Boolean loggedInUserIsWWUserFlag = false;
			Set<String> loggedInWWUserAccountProgramStrSet = new Set<String>();
            Set<String> loggedInUserAccountProgramGeoStrSet = new Set<String>();
			Set<String> loggedInUserProgramGeoStrSet = new Set<String>();
            Set<Id> loggedInUserAccountIdSet = new Set<Id>();

            Core_MDF_Exception_Utility.ExceptionUserIUPGMWrapper exptUserIUPGMWrap = Core_MDF_Exception_Utility.getIUPGMDataForExceptionUser();
			loggedInWWUserAccountProgramStrSet = exptUserIUPGMWrap.exptWWUserIUPGMAccountProgramStrSet;
			loggedInUserAccountProgramGeoStrSet = exptUserIUPGMWrap.exptUserIUPGMAccountProgramGeoStrSet;
			loggedInUserProgramGeoStrSet = exptUserIUPGMWrap.exptUserIUPGMProgramGeoStrSet;
			loggedInUserAccountIdSet = exptUserIUPGMWrap.exptUserIUPGMAccountIdSet;
      
      
            List<String> accountManagerPermissionSets = Label.Core_MDF_CCP_Account_Manager_CCF_DCF.split(',');
            /* String exceptionReviewerPermissionSetsString = Label.Core_MDF_Exception_Reviewer_Permission_Set;
            Boolean exceptionReviewerFlag = false;
            for(PermissionSetAssignment permissionSet : [SELECT PermissionSet.Name,PermissionSet.Label
                                                         FROM PermissionSetAssignment
                                                         WHERE AssigneeId =: UserInfo.getUserId()]){
                String permissionSetName = permissionSet.PermissionSet.Name;
                if(permissionSetName != NULL){
                    if(exceptionReviewerPermissionSetsString != NULL && exceptionReviewerPermissionSetsString.containsIgnoreCase(permissionSetName)){exceptionReviewerFlag = true;break;
                    }
                }
            } */

            for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem : ([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c, Core_MDF_Entitlement_Name__c
                                                                    FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt])){
                channelProgramNameMap.put(bpem.Core_MDF_Bank_Program_Name__c , bpem.Core_MDF_Channel_Program__c);                    
            }

            //Get Channel program Id and Core_MDF name
            for (ChannelProgram cpList : [SELECT Id, Name
                                        FROM ChannelProgram
                                        WHERE Name =: channelProgramNameMap.values()
                                        ORDER BY CreatedDate] ){                                            
                channelProgramNameIdMap.put( cpList.Name , cpList.Id );
            }

            //Get the Map of Country code and Geo using Country Geo Mapping Metadata
            for(Core_MDF_CCP_Country_Geo_Mapping__mdt cgm : [SELECT MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c
                                                            FROM Core_MDF_CCP_Country_Geo_Mapping__mdt]){
                countryGeoMap.put(cgm.MasterLabel,cgm.Core_MDF_Geo__c);
                countrySubGeoMap.put(cgm.MasterLabel,cgm.Core_MDF_Sub_Geo__c);
                if(cgm.Core_MDF_Geo__c != '0'){
                    if(geoSubGeoSetMap.containsKey(cgm.Core_MDF_Geo__c)){
                        if(!geoSubGeoSetMap.get(cgm.Core_MDF_Geo__c).contains(cgm.Core_MDF_Sub_Geo__c)){
                            Set<String> subGeoStringSet = new Set<String>();
                            subGeoStringSet = geoSubGeoSetMap.get(cgm.Core_MDF_Geo__c);
                            subGeoStringSet.add(cgm.Core_MDF_Sub_Geo__c);
                            geoSubGeoSetMap.put(cgm.Core_MDF_Geo__c, subGeoStringSet);
                        }                    
                    }
                    else{
                        Set<String> subGeoStringSet = new Set<String>();
                        subGeoStringSet.add(cgm.Core_MDF_Sub_Geo__c);
                        geoSubGeoSetMap.put(cgm.Core_MDF_Geo__c, subGeoStringSet);
                    }
                }
            }
			// To check whether the user has geo access for which he is creating exception
			Map <Core_MDF_Exception__c, Boolean> exceptionIdCountryErrorCheckMap = new Map <Core_MDF_Exception__c, Boolean>();
			for(Core_MDF_Exception__c expt : newExceptionMap.values()){
                if(expt.Core_MDF_Program_nm__c != NULL){
					//exceptionChannelprogram = channelProgramNameMap.get(expt.Core_MDF_Program_nm__c.replaceAll('-',''));
					programIdSet.add(channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)));
				}
                if(expt.Core_MDF_Account_id__c != NULL){
					intelAccountIdSet.add(expt.Core_MDF_Account_id__c);
				}
				if(expt.Core_MDF_Select_All_Accounts_ind__c){
					blnAllAccountsFlag = true;
				}  
            }
            List<Account> accountList = [SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__c, Core_MDF_Channel_Program__r.Name
                                        FROM Account 
                                        WHERE Core_MDF_CoMarketing_Ultimate_Account__c IN :intelAccountIdSet AND 
                                        Core_MDF_Channel_Program__c IN :programIdSet
                                        ];

            for(Account fetchVirtualAccount : accountList){
                if(accountIdProgramStrSetMap.containsKey(fetchVirtualAccount.Core_MDF_CoMarketing_Ultimate_Account__c)){accountIdProgramStrSetMap.get(fetchVirtualAccount.Core_MDF_CoMarketing_Ultimate_Account__c).add(fetchVirtualAccount.Core_MDF_Channel_Program__c);
                }
                else{
                    accountIdProgramStrSetMap.put(fetchVirtualAccount.Core_MDF_CoMarketing_Ultimate_Account__c, new Set<String>{
                        fetchVirtualAccount.Core_MDF_Channel_Program__r.Name});
                }
            }
			// Check if any error related to Account or Program or Country associated to user is present on the record or not
			for(Core_MDF_Exception__c expt : newExceptionMap.values()){
                System.debug('exptUserIUPGMWrap: ' + exptUserIUPGMWrap);
				validateException(expt, exptUserIUPGMWrap, countryGeoMap,  channelProgramNameMap.get(expt.Core_MDF_Program_nm__c), accountIdProgramStrSetMap);
            }
            //for loop to build Maps for sharing
            for(Core_MDF_Exception__c expt : newExceptionMap.values()){
                //Boolean noErrorOnException = false;
				// Check if any error is associated to geo or program on the exception or not.
				//noErrorOnException = checkExceptionAccountProgramAndGeo( expt , exceptionIdCountryErrorCheckMap, accountIdProgramStrSetMap, channelProgramNameMap.get(expt.Core_MDF_Program_nm__c));
                
                //if(noErrorOnException){
                    // Add all the ids channel program ids in the set
                    exceptionChannelPrgIdsSet.add(channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)));
                    if(expt.Core_MDF_Account_id__c != NULL){// If the exception has one account selected   
                        //Account       Country
                        //Single        Multi            
                        if(expt.Core_MDF_Country_Region_nm__c != NULL){//Check if it is Multi Select Country
                            Map<Id,Set<String>> exptIdGeoSetMap = new Map<Id,Set<String>>();
                            Map<Id,Set<String>> exptIdGeoSubgeoSetMap = new Map<Id,Set<String>>();

                            //exceptionId, Set<APJSA,EMEACER>
                            for(String countryStr : expt.Core_MDF_Country_Region_nm__c.split(';')){//Split the Countries and iterate over them
                                if(countryGeoMap.containsKey(countryStr)){
                                    // && !exptIdGeoSubgeoSetMap.get(expt.Id).contains(countryGeoMap.get(countryStr)+countrySubGeoMap.get(countryStr))
                                    Set< Core_MDF_Exception__c > exptSet = new Set< Core_MDF_Exception__c >{expt};
                                    if(countrySubGeoMap.containsKey(countryStr)){
                                        String geoSubGeoStr = countryGeoMap.get(countryStr) + countrySubGeoMap.get(countryStr);
                                        if(exptIdGeoSubgeoSetMap.containsKey(expt.Id)){
                                            if(!exptIdGeoSubgeoSetMap.get(expt.Id).contains(geoSubGeoStr)){
                                                /* Set<String> existingGeoSubGeoSet = exptIdGeoSubgeoSetMap.get(expt.Id);
                                                existingGeoSubGeoSet.add(geoSubGeoStr);
                                                exptIdGeoSubgeoSetMap.put(expt.Id, existingGeoSubGeoSet); */
                                                exptIdGeoSubgeoSetMap.get(expt.Id).add(geoSubGeoStr);
                                                recordGeoShareList.add(new Core_MDF_RecordGeoShare(expt.Id, countryGeoMap.get(countryStr), countrySubGeoMap.get(countryStr), (String)channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)));
                                            }
                                        }
                                        else{
                                            Set<String> existingGeoSubGeoSet = new Set<String>();
                                            existingGeoSubGeoSet.add(geoSubGeoStr);
                                            exptIdGeoSubgeoSetMap.put(expt.Id, existingGeoSubGeoSet);
                                            recordGeoShareList.add(new Core_MDF_RecordGeoShare(expt.Id, countryGeoMap.get(countryStr), countrySubGeoMap.get(countryStr), (String)channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)));
                                        }
                                        
                                        String channelprgIdAccIdGeoSubGeoKey = '';
                                        channelprgIdAccIdGeoSubGeoKey = (String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)) + (String)expt.Core_MDF_Account_id__c + countryGeoMap.get(countryStr) + countrySubGeoMap.get(countryStr);

                                        //Geo and SubGeo
                                        if(channelPrgIdAccIdGeoSubGeoExptSetMap.containsKey(channelprgIdAccIdGeoSubGeoKey)){//if already the key exists, then add the Exception to the already existing Exception Set.
                                            channelPrgIdAccIdGeoSubGeoExptSetMap.get(channelprgIdAccIdGeoSubGeoKey).add(expt);
                                        }
                                        else{//otherwise add the exception to the new set and then add it to the Map
                                            channelPrgIdAccIdGeoSubGeoExptSetMap.put(channelprgIdAccIdGeoSubGeoKey, exptSet );
                                        }

                                        
                                    }
                                    
                                    // Constructing Map Key with ChannelProgramId, AccountId and Single Geo
                                    String channelprgIdAccIdGeoKey = '';
                                    if(exptIdGeoSetMap.containsKey(expt.Id)){Set<String> existingGeoSet = exptIdGeoSetMap.get(expt.Id);existingGeoSet.add(countryGeoMap.get(countryStr));exptIdGeoSetMap.put(expt.Id, existingGeoSet);
                                    }
                                    else{
                                        Set<String> existingGeoSet = new Set<String>();
                                        existingGeoSet.add(countryGeoMap.get(countryStr));
                                        exptIdGeoSetMap.put(expt.Id, existingGeoSet);
                                    }
                                    channelprgIdAccIdGeoKey = (String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)) + (String)expt.Core_MDF_Account_id__c + countryGeoMap.get(countryStr);   
                                    
                                    //Only Geo
                                    if(channelPrgIdAccIdGeoExptSetMap.containsKey(channelprgIdAccIdGeoKey)){//if already the key exists, then add the Exception to the already existing Exception Set.
                                        channelPrgIdAccIdGeoExptSetMap.get(channelprgIdAccIdGeoKey).add(expt);
                                    }
                                    else{//otherwise add the exception to the new set and then add it to the Map
                                        channelPrgIdAccIdGeoExptSetMap.put(channelprgIdAccIdGeoKey, exptSet );
                                    }
                                    System.debug('channelPrgIdAccIdGeoExptSetMap'+channelPrgIdAccIdGeoExptSetMap);

                                    //for WW
                                    channelprgIdAccIdGeoKey = (String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)) + (String)expt.Core_MDF_Account_id__c;
                                    if(channelPrgIdAccIdWWExptSetMap.containsKey(channelprgIdAccIdGeoKey)){//if already the key exists, then add the Exception to the already existing Exception Set.
                                        channelPrgIdAccIdWWExptSetMap.get(channelprgIdAccIdGeoKey).add(expt);
                                    }
                                    else{//otherwise add the exception to the new set and then add it to the Map
                                        channelPrgIdAccIdWWExptSetMap.put(channelprgIdAccIdGeoKey, exptSet );
                                    }
                                    System.debug('channelPrgIdAccIdWWExptSetMap: ' + channelPrgIdAccIdWWExptSetMap);
                                }

                            }
                        }
                        //Account       Country
                        //Single        All
                        else if(expt.Core_MDF_Select_All_Country_ind__c){//Check if it is All Country
                            Set< Core_MDF_Exception__c > exptSet = new Set< Core_MDF_Exception__c >{expt};
                            // Constructing Map Key with ChannelProgramId and AccountId
                            String channelprgIdAccIdKey = (String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)) + (String)expt.Core_MDF_Account_id__c;

                            recordGeoShareList.addAll(getRecordShareList(expt.Id, (String)channelProgramNameMap.get(expt.Core_MDF_Program_nm__c), geoSubGeoSetMap));

                            if(channelPrgIdAccIdExptSetMap.containsKey(channelprgIdAccIdKey)){ channelPrgIdAccIdExptSetMap.get(channelprgIdAccIdKey).add(expt);
                            }
                            else{
                                channelPrgIdAccIdExptSetMap.put(channelprgIdAccIdKey, exptSet );
                            }
                        }
                    }
                    
                    //Account       Country
                    //All           Multi
                    else if(expt.Core_MDF_Select_All_Accounts_ind__c){// If the exception has All Account Selected
                        if(expt.Core_MDF_Country_Region_nm__c != NULL){//Check if it is Multi Select Country
                            Map<Id,Set<String>> exptIdGeoSetMap = new Map<Id,Set<String>>();
                            Map<Id,Set<String>> exptIdGeoSubgeoSetMap = new Map<Id,Set<String>>();
                            for(String countryStr : expt.Core_MDF_Country_Region_nm__c.split(';')){//Split the Countries and iterate over them
                                if(countryGeoMap.containsKey(countryStr)){
                                    Set< Core_MDF_Exception__c > exptSet = new Set< Core_MDF_Exception__c >{expt};
                                    if(countrySubGeoMap.containsKey(countryStr)){  
                                        String geoSubGeoStr = countryGeoMap.get(countryStr) + countrySubGeoMap.get(countryStr);
                                        if(exptIdGeoSubgeoSetMap.containsKey(expt.Id)){
                                            if(!exptIdGeoSubgeoSetMap.get(expt.Id).contains(geoSubGeoStr)){ exptIdGeoSubgeoSetMap.get(expt.Id).add(geoSubGeoStr);

                                                recordGeoShareList.add(new Core_MDF_RecordGeoShare(expt.Id, countryGeoMap.get(countryStr), countrySubGeoMap.get(countryStr), (String)channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)));
                                            }
                                        }
                                        else{
                                            Set<String> existingGeoSubGeoSet = new Set<String>();
                                            existingGeoSubGeoSet.add(geoSubGeoStr);
                                            exptIdGeoSubgeoSetMap.put(expt.Id, existingGeoSubGeoSet);
                                            recordGeoShareList.add(new Core_MDF_RecordGeoShare(expt.Id, countryGeoMap.get(countryStr), countrySubGeoMap.get(countryStr), (String)channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)));
                                        }

                                        String channelprgIdGeoSubGeoKey = '';
                                        channelprgIdGeoSubGeoKey = (String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)) + countryGeoMap.get(countryStr) + countrySubGeoMap.get(countryStr);

                                        //Geo and SubGeo
                                        if(channelPrgIdGeoSubGeoExptSetMap.containsKey(channelprgIdGeoSubGeoKey)){//if already the key exists, then add the Exception to the already existing Exception Set.
                                            channelPrgIdGeoSubGeoExptSetMap.get(channelprgIdGeoSubGeoKey).add(expt);
                                        }
                                        else{//otherwise add the exception to the new set and then add it to the Map
                                            channelPrgIdGeoSubGeoExptSetMap.put(channelprgIdGeoSubGeoKey, exptSet);
                                        }
                                    }

                                    // Constructing Map Key with ChannelProgramId and Single Geo
                                    String channelprgIdGeoKey = '';
                                    if(exptIdGeoSetMap.containsKey(expt.Id)){Set<String> existingGeoSet = exptIdGeoSetMap.get(expt.Id);existingGeoSet.add(countryGeoMap.get(countryStr));exptIdGeoSetMap.put(expt.Id, existingGeoSet);
                                    }
                                    else{
                                        Set<String> existingGeoSet = new Set<String>();
                                        existingGeoSet.add(countryGeoMap.get(countryStr));
                                        exptIdGeoSetMap.put(expt.Id, existingGeoSet);
                                    }
                                    channelprgIdGeoKey = (String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)) + countryGeoMap.get(countryStr);
                                    
                                    //Geo only
                                    if(channelPrgIdGeoExptSetMap.containsKey(channelprgIdGeoKey)){//if already the key exists, then add the Exception to the already existing Exception Set.
                                        channelPrgIdGeoExptSetMap.get(channelprgIdGeoKey).add(expt);
                                    }
                                    else{//otherwise add the exception to the new set and then add it to the Map
                                        channelPrgIdGeoExptSetMap.put(channelprgIdGeoKey, exptSet);
                                    }
                                    
                                    //for WW
                                    channelprgIdGeoKey = (String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_nm__c));
                                    if(channelPrgIdWWExptSetMap.containsKey(channelprgIdGeoKey)){//if already the key exists, then add the Exception to the already existing Exception Set.
                                        channelPrgIdWWExptSetMap.get(channelprgIdGeoKey).add(expt);
                                    }
                                    else{//otherwise add the exception to the new set and then add it to the Map
                                        channelPrgIdWWExptSetMap.put(channelprgIdGeoKey, exptSet);
                                    }
                                }
                            }
                        }
                        //Account       Country
                        //All           All
                        else if(expt.Core_MDF_Select_All_Country_ind__c){//Check if it is All Country
                            Set< Core_MDF_Exception__c > exptSet = new Set< Core_MDF_Exception__c >{expt};
                            // Constructing Map Key with ChannelProgramId
                            String channelprgIdKey = (String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_nm__c));

                            recordGeoShareList.addAll(getRecordShareList(expt.Id, (String)channelProgramNameMap.get(expt.Core_MDF_Program_nm__c), geoSubGeoSetMap));

                            if(channelPrgIdExptSetMap.containsKey(channelprgIdKey)){ channelPrgIdExptSetMap.get(channelprgIdKey).add(expt);
                            }
                            else{
                                channelPrgIdExptSetMap.put(channelprgIdKey, exptSet );
                            }
                        }
                    }
                }
            //}

            
            if(!blnAllAccountsFlag){ strAccountWHEREClause = ' AND Core_MDF_Account__c IN :intelAccountIdSet';
            }

            pgmQueryStr = 'SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__c, Core_MDF_Group_Id__c, ' +
                          'Core_MDF_Group_Name__c, Core_MDF_Type_of_Access__c, Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c ' +
                          'FROM Core_MDF_Partner_Group_Mapping__c ' +
                          'WHERE Core_MDF_Channel_Program__c IN :exceptionChannelPrgIdsSet ' +
                          'AND Core_MDF_Type_of_Access__c = ' + '\'' + 'Internal' + '\' ' +
                          'AND Core_MDF_Region_cd__c != NULL ' +
                          'AND Core_MDF_Group_Id__c != NULL' + String.escapeSingleQuotes(strAccountWHEREClause);
            
            for( Core_MDF_Partner_Group_Mapping__c pgm : Database.query(pgmQueryStr)){                                                             
                if(pgm.Core_MDF_Region_cd__c != 'WW'){//if PGM is not for Worldwide (WW)
					if(pgm.Core_MDF_Sub_Region_cd__c == NULL){//Sub Region is NULL
                        //Account       Country
                        //Single        Multi                      
                        String programIdAccountIdGeoStr = (String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c + pgm.Core_MDF_Region_cd__c;
						System.debug('programIdAccountIdGeoStr: ' + programIdAccountIdGeoStr);
						if(channelPrgIdAccIdGeoExptSetMap.containsKey(programIdAccountIdGeoStr)){                          
							for(Core_MDF_Exception__c expt : channelPrgIdAccIdGeoExptSetMap.get(programIdAccountIdGeoStr)){
							system.debug('pgm.Core_MDF_Group_Id__c: ' + pgm.Core_MDF_Group_Id__c);
								if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){
                                    exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);
                                    exptShareSet.add(createExceptionShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                            System.debug('exptShareSet'+exptShareSet);
                        }
                        //Account       Country
                        //Single        All
                        String programIdAccountIdStr = (String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c;
                        //channelPrgIdAccIdExptSetMap
                        if(channelPrgIdAccIdExptSetMap.containsKey(programIdAccountIdStr)){
                            for(Core_MDF_Exception__c expt : channelPrgIdAccIdExptSetMap.get(programIdAccountIdStr)){
                                System.debug('exceptionIdCountryErrorCheckMap'+exceptionIdCountryErrorCheckMap);
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){
                                    exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);
                                    exptShareSet.add(createExceptionShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                                }
                                
                            }
                        }
						System.debug('exptShareSet-->'+exptShareSet);
                        //Account       Country
                        //All           Multi
                        String programIdGeoStr = (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                        if(channelPrgIdGeoExptSetMap.containsKey(programIdGeoStr)){
                            for(Core_MDF_Exception__c expt : channelPrgIdGeoExptSetMap.get(programIdGeoStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){
                                    exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);
                                    exptShareSet.add(createExceptionShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                        }
						System.debug('exptShareSet-->'+exptShareSet);
                        //Account       Country
                        //All           All
                        String programIdStr = (String)pgm.Core_MDF_Channel_Program__c;
                        if(channelPrgIdExptSetMap.containsKey(programIdStr)){
                            for(Core_MDF_Exception__c expt : channelPrgIdExptSetMap.get(programIdStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){
                                    exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);
                                    exptShareSet.add(createExceptionShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                        }
                    }
                    else{//Sub Region is NOT NULL
                        //Account       Country
                        //Single        Multi
                        String programIdAccountIdGeoSubGeoStr = (String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                        System.debug('programIdAccountIdGeoSubGeoStr: ' + programIdAccountIdGeoSubGeoStr);
                        System.debug('channelPrgIdAccIdGeoSubGeoExptSetMap: ' + channelPrgIdAccIdGeoSubGeoExptSetMap);
                        if(channelPrgIdAccIdGeoSubGeoExptSetMap.containsKey(programIdAccountIdGeoSubGeoStr)){
                            for(Core_MDF_Exception__c expt : channelPrgIdAccIdGeoSubGeoExptSetMap.get(programIdAccountIdGeoSubGeoStr)){
                                System.debug('pgm.Core_MDF_Group_Id__c: ' + pgm.Core_MDF_Group_Id__c);
                           if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptShareSet.add(createExceptionShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                        }
          
                        //Account       Country
                        //Single        All
                        String programIdAccountIdStr = (String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c;
                        //channelPrgIdAccIdExptSetMap
                        if(channelPrgIdAccIdExptSetMap.containsKey(programIdAccountIdStr)){
                            for(Core_MDF_Exception__c expt : channelPrgIdAccIdExptSetMap.get(programIdAccountIdStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptShareSet.add(createExceptionShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                        }

                        //Account       Country
                        //All           Multi
                        String programIdGeoSubGeoStr = (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                        if(channelPrgIdGeoSubGeoExptSetMap.containsKey(programIdGeoSubGeoStr)){
                            for(Core_MDF_Exception__c expt : channelPrgIdGeoSubGeoExptSetMap.get(programIdGeoSubGeoStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptShareSet.add(createExceptionShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                        }

                        //Account       Country
                        //All           All
                        String programIdStr = (String)pgm.Core_MDF_Channel_Program__c;
                        if(channelPrgIdExptSetMap.containsKey(programIdStr)){
                            for(Core_MDF_Exception__c expt : channelPrgIdExptSetMap.get(programIdStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptShareSet.add(createExceptionShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                        }
                    }
                }                
                else{//if PGM is for Worldwide (WW)
                    //Account       Country
                    //Single        Multi
                    String programIdAccountIdWW = (String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c;
                    System.debug('exptShareSet PGM'+exptShareSet);
                    if(channelPrgIdAccIdWWExptSetMap.containsKey(programIdAccountIdWW)){
                        for(Core_MDF_Exception__c expt : channelPrgIdAccIdWWExptSetMap.get(programIdAccountIdWW)){
                            if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptShareSet.add(createExceptionShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                            }
                        }
                    }
					System.debug('exptShareSet'+exptShareSet);
                    //Account       Country
                    //All           Multi
                    String programIdWWStr = (String)pgm.Core_MDF_Channel_Program__c;
                    if(channelPrgIdWWExptSetMap.containsKey(programIdWWStr)){
                        for(Core_MDF_Exception__c expt : channelPrgIdWWExptSetMap.get(programIdWWStr)){
                            if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptShareSet.add(createExceptionShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                            }
                        }
                    }
                }
                
                //Account       Country
                //Single        All
				String programIdAccountIdStr = (String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c;
                if(channelPrgIdAccIdExptSetMap.containsKey(programIdAccountIdStr)){
                    for(Core_MDF_Exception__c expt : channelPrgIdAccIdExptSetMap.get(programIdAccountIdStr)){
                        if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptShareSet.add(createExceptionShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                        }
                    }
                }
				System.debug('exptShareSet'+exptShareSet);

                //Account       Country
                //All           All
                String programIdStr = (String)pgm.Core_MDF_Channel_Program__c;
                if(channelPrgIdExptSetMap.containsKey(programIdStr)){
                    for(Core_MDF_Exception__c expt : channelPrgIdExptSetMap.get(programIdStr)){
                        if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptShareSet.add(createExceptionShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                        }
                    }
                }
            }
            
            //Insert Share Records For the Exception
            if(exptShareSet != NULL && exptShareSet.size() > 0){
                List < Core_MDF_Exception__Share > exptShareList = new List< Core_MDF_Exception__Share >();
                exptShareList.addAll(exptShareSet);
                database.insert(exptShareList , true);
            }
            
            Map<Id,Core_MDF_Exception_Case_Mapping__c> ecmMap = new Map<Id,Core_MDF_Exception_Case_Mapping__c>();
			List<Core_MDF_Exception_Case_Mapping__Share> ecmShareList = new List<Core_MDF_Exception_Case_Mapping__Share>();
            for(Core_MDF_Exception_Case_Mapping__c ecmRecord : [SELECT Id, Core_MDF_Exception_id__c
                                                                FROM Core_MDF_Exception_Case_Mapping__c
                                                                WHERE Core_MDF_Exception_id__c IN :newExceptionMap.keySet()]){
				ecmMap.put(ecmRecord.Id, ecmRecord);
			}
            if(ecmMap != NULL && ecmMap.size() > 0){
				for(Core_MDF_Exception_Case_Mapping__Share ecmShareRecord : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
																			FROM Core_MDF_Exception_Case_Mapping__Share
                                                                            WHERE ParentId IN :ecmMap.keySet() AND RowCause = 'Manual']){
					ecmShareList.add(ecmShareRecord);
				}
				if(ecmShareList != NULL && ecmShareList.size() > 0){
                    delete ecmShareList;
				}
        
				shareECMRecordWithusers(ecmMap);
			}
      
            if(recordGeoShareList != NULL && recordGeoShareList.size() >0){
                Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroup('Core_MDF_Exception__c', recordGeoShareList);
            }

        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    /****************************************************************************************************************************************
    * Method Name           : createExceptionShareInternal
    * Created Date          : 17-09-2019
    * Modification Log
    * Developer            Date               Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    Accenture SN         17-09-2019          Exception Share creations          
    *****************************************************************************************************************************************/
    public static Core_MDF_Exception__Share createExceptionShareInternal(String exceptionId, String ugId){
        Core_MDF_Exception__Share expShare = new Core_MDF_Exception__Share();
        expShare.ParentId = exceptionId;
        expShare.RowCause = 'Manual';
        expShare.AccessLevel = 'Read';
        expShare.UserOrGroupId = ugId;
        return expShare;
    }

    /***************************************************************************************************** 
    Method Name:        getRecordShareList
    @return  :          List<Core_MDF_RecordGeoShare>
    @parameters:        Id - recordId
                        String - Name of the Program
                        Map<String,Set<String>> - Map of Geo and its related SubGeos
    Description:        This method is used to fetch the Record Geo Share List. This will be used for the records which does not have any Country.
    Added By:           Accenture SB
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static List<Core_MDF_RecordGeoShare> getRecordShareList(Id recordId, String programName, Map<String,Set<String>> geoSubGeoSetMap){
        List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
        for(String geoStr : geoSubGeoSetMap.keySet()){
            for(String subGeoStr : geoSubGeoSetMap.get(geoStr)){
                recordGeoShareList.add(new Core_MDF_RecordGeoShare(recordId, geoStr, subGeoStr, programName));
            }
        }
        return recordGeoShareList;
    }
    
    /****************************************************************************************************************************************
    * Method Name           : shareECMRecordWithusers
    * Created Date          : 12-09-2019
    * Modification Log
    * Developer            Date             Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    Accenture SN        12-09-2019      This method will share the ECM records with internal users.      
    *****************************************************************************************************************************************/
    public static void shareECMRecordWithusers(Map <Id , Core_MDF_Exception_Case_Mapping__c> ecmIdMap){
        Map<Id,List<Id>> exceptionIdECMIdListMap = new Map<Id,List<Id>>();
        List<Core_MDF_Exception_Case_Mapping__Share> ecmShareList = new List<Core_MDF_Exception_Case_Mapping__Share>();
        try{
            //Fetch all the exceptions
            for(Core_MDF_Exception_Case_Mapping__c ecm : ecmIdMap.values()){
                if(exceptionIdECMIdListMap.containsKey(ecm.Core_MDF_Exception_id__c)){
                    exceptionIdECMIdListMap.get(ecm.Core_MDF_Exception_id__c).add(ecm.Id);
                }
                else{
                    exceptionIdECMIdListMap.put(ecm.Core_MDF_Exception_id__c, new List<Id>{(ecm.Id)});
                }
            }
            //Form all the Exception Share records
            for(Core_MDF_Exception__Share exceptionShareRecord : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                                  FROM Core_MDF_Exception__Share
                                                                  WHERE ParentId IN :exceptionIdECMIdListMap.keySet() AND
                                                                        RowCause = 'Manual']){
                String strGroupId = exceptionShareRecord.UserOrGroupId;
                if(strGroupId.startsWithIgnoreCase('00G')){
                    for(Id ecmRecordId : exceptionIdECMIdListMap.get(exceptionShareRecord.ParentId)){
                        ecmShareList.add(createECMShare(ecmRecordId, exceptionShareRecord.UserOrGroupId));
                    } 
                }               
            }
            //Insert all Exception Share records
            if(ecmShareList != NULL && ecmShareList.size() > 0){
                insert ecmShareList;
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /****************************************************************************************************************************************
    * Method Name           : createECMShare
    * Created Date          : 12-09-2019
    * Modification Log
    * Developer              Date               Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    Accenture SN         12-09-2019         ECM Share creations          
    *****************************************************************************************************************************************/
    public static Core_MDF_Exception_Case_Mapping__Share createECMShare(String ecmId, String ugId){
        Core_MDF_Exception_Case_Mapping__Share ecmShare = new Core_MDF_Exception_Case_Mapping__Share();
        ecmShare.ParentId = ecmId;
        ecmShare.RowCause = 'Manual';
        ecmShare.AccessLevel = 'Read';
        ecmShare.UserOrGroupId = ugId;
        return ecmShare;
    }
	/****************************************************************************************************************************************
    * Method Name           : validateException
    * Created Date          : 01/14/2020
    * Modification Log
    * Developer              Date               Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
            
    *****************************************************************************************************************************************/
	private static void validateException(Core_MDF_Exception__c excpt, Core_MDF_Exception_Utility.ExceptionUserIUPGMWrapper excptUserData, Map<String,String> countryGeoMap, String programName, Map<Id, Set<String>> accountIdProgramStrSetMap ){
		Boolean isExceptionReviewerFlag = isExceptionReviewer();
        if(!isExceptionReviewerFlag){
			//Check All Accounts condition on exception
			if(validateExceptionAccountAccess(excpt, isExceptionReviewerFlag, excptUserData.exptUserIUPGMAccountIdSet)){
				// Check All Country condition or multi geo condition on exception exptUserIUPGMWrap.exptUserIUPGMAccountProgramGeoStrSet
				if(validateExceptionCountryAccess (excpt, programName, excptUserData.exptWWUserIUPGMAccountProgramStrSet, excptUserData.exptUserIUPGMAccountProgramGeoStrSet,countryGeoMap)){
					// Check if any error is associated or program on the exception or not.
					validateExceptionAccountProgramAccess(excpt, accountIdProgramStrSetMap, programName);
				}
			}
		}
        else{
            // Check if any error is associated or program on the exception or not.
			validateExceptionAccountProgramAccess(excpt, accountIdProgramStrSetMap, programName);
        }
	}
	/****************************************************************************************************************************************
    * Method Name           : validateExceptionAccountAccess
    * Created Date          : 01/14/2020
    * Modification Log
    * Developer              Date               Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
            
    *****************************************************************************************************************************************/
	private static Boolean validateExceptionAccountAccess(Core_MDF_Exception__c excpt, Boolean excptReviewerCheck, Set<Id> accountIdSet ){
		if(excpt.Core_MDF_Select_All_Accounts_ind__c){//if All Accounts selected
			if(!excptReviewerCheck){
                excpt.addError(Label.Core_MDF_ExceptionSelectAllAccounts_Error);
                return false;
			}
		}
		else{
            if(!accountIdSet.contains(excpt.Core_MDF_Account_id__c) && !excptReviewerCheck){
                excpt.addError(Label.Core_MDF_ExceptionAccountAccessError);
                return false;
			}
		}
		return true;
    }
	/****************************************************************************************************************************************
    * Method Name           : validateExceptionCountryAccess
    * Created Date          : 01/14/2020
    * Modification Log
    * Developer              Date               Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
            
    *****************************************************************************************************************************************/
	private static Boolean validateExceptionCountryAccess(Core_MDF_Exception__c excpt, String exceptionChannelprogram, Set<String> accountProgramStrSet, 
                                                       Set<String> accountProgramGeoStrSet, Map<String , String> countryGeoMap){
        Map< Core_MDF_Exception__c , Boolean>exceptionIdCountryErrorCheckMap = new Map< Core_MDF_Exception__c , Boolean>();
        String accountIdProgramGeoStr = '';
		if(excpt.Core_MDF_Account_id__c != NULL){
			//Constructing key first to check all country condition
			accountIdProgramGeoStr = excpt.Core_MDF_Account_id__c + '-' + exceptionChannelprogram.replaceAll('-', '') ;
            System.debug('SB -> accountIdProgramGeoStr: ' + accountIdProgramGeoStr);
			exceptionIdCountryErrorCheckMap.put(excpt, false);
			if(!accountProgramStrSet.contains(accountIdProgramGeoStr)){
				if(excpt.Core_MDF_Select_All_Country_ind__c){
					excpt.addError(Label.Core_MDF_ExceptionSelectAllCountry_Error);
					return false;
				}
				else{
					for(String countryStr : excpt.Core_MDF_Country_Region_nm__c.split(';')){
						//Updating key to check multiple country condition
						accountIdProgramGeoStr = excpt.Core_MDF_Account_id__c + '-' + exceptionChannelprogram.replaceAll('-', '') + '-' + countryGeoMap.get(countryStr);
						System.debug('accountIdProgramGeoStr: ' + accountIdProgramGeoStr);
                        System.debug('accountProgramGeoStrSet:1 ' + accountProgramGeoStrSet);
						if(accountProgramGeoStrSet.contains(accountIdProgramGeoStr)){
                            System.debug('accountIdProgramGeoStr:2 ' + accountIdProgramGeoStr);
							if(!exceptionIdCountryErrorCheckMap.get(excpt)){
                                exceptionIdCountryErrorCheckMap.put(excpt, false);
							}
						}
						else{
                            exceptionIdCountryErrorCheckMap.put(excpt, true);
						}
					}
				}
			}
            if(exceptionIdCountryErrorCheckMap.get(excpt)){
				System.debug('accountIdProgramGeoStr:2 ' + accountIdProgramGeoStr);
				excpt.addError(Label.Core_MDF_Exception_MultiGeo_Error);
                return false;
			}
		}
		return true;
	}
	/****************************************************************************************************************************************
    * Method Name           : ValidateExceptionAccountProgramAccess
    * Created Date          : 01/14/2020
    * Modification Log
    * Developer              Date               Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
            
    *****************************************************************************************************************************************/
	private static Boolean validateExceptionAccountProgramAccess(Core_MDF_Exception__c excpt, 
                                                              Map<Id, Set<String>> accIdProgramStrSetMap, String excptChannelProgram )
    {
        System.debug('SB -> excptChannelProgram: ' + excptChannelProgram);
        System.debug('SB -> accIdProgramStrSetMap: ' + accIdProgramStrSetMap);
		if(accIdProgramStrSetMap.size() == 0 && !accIdProgramStrSetMap.containsKey(excpt.Core_MDF_Account_id__c) && !excpt.Core_MDF_Select_All_Accounts_ind__c){
			excpt.addError(Label.Core_MDF_ExceptionAccountProgramError);
			return false;
		}
		else if(accIdProgramStrSetMap != NULL && accIdProgramStrSetMap.size() > 0 &&   
				accIdProgramStrSetMap.containsKey(excpt.Core_MDF_Account_id__c) && 
				!accIdProgramStrSetMap.get(excpt.Core_MDF_Account_id__c).contains(excptChannelProgram)){
			excpt.addError(Label.Core_MDF_ExceptionAccountProgramError);
			return false;
		}
        return true;
	}
	
	/***************************************************************************************************** 
    Method Name:        isExceptionReviewer
    @return  :          Boolean
    @parameters:        
    Description:        This method is used to check if the "Exception Reviewer" Custom permission is assigned to the User
    Added By:           Accenture SB
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static Boolean isExceptionReviewer(){
        return isCustomPermissionAssigned('Core_MDF_ExceptionReviewer');
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