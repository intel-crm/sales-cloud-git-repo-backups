public without sharing class ER_ENT_PRG_SearchCIMAccount {
    ER_CIM_Request__mdt cimMdt = [Select Id, MasterLabel,API_Key__c, PRM_Async_Id__c, PRM_Calling_System__c, PRM_Restriction_Level__c, PRM_Max_Records__c, PRM_Max_Score__c, PRM_Min_Score__c from ER_CIM_Request__mdt where MasterLabel =: System.Label.PRM_Dupe_Scores];
    public map<id,contact> acctCont = new map<id,contact>();
    public string accCountry;
    
    //PRM_CIMSearchResults__c is a generic object to Capture the cim response
    //Use Object(Data contract) Instead of so many parameters
    public list<PRM_CIMSearchResults__c> getCimResults(String accName,String accAddr,String accPostalCode,String accCity,String accCountry,String accStateProvince,String rcdLimit,String searchScore,String companyWebsite,String regEmail,String AccountType, Boolean fetchEmailDomainBasedAccts,set<id> accountsSfdc,String partnerRole,Boolean isProgramBased)
    {
        
        if(!isProgramBased)
        {
            ER_SearchSalesCloudAccounts.strCountryCode = accCountry;
        }
        else
        {
            //Added by Naresh as part of US637998
            if(!String.isEmpty(regEmail) && (accountsSfdc==null || (accountsSfdc!=null && accountsSfdc.size() == 0))){
                PRM_searchSfdcAccounts.strCountryCode = accCountry;            }
        }
        
        //Response from CIM system is stored in cimResults
        List<PRM_CIMSearchResults__c> cimResults = new list<PRM_CIMSearchResults__c>();
        
        //Matching Domain Search Results from Email Contact Domain is stored in cimResultsDomain
        List<PRM_CIMSearchResults__c> cimResultsDomain = new list<PRM_CIMSearchResults__c>();
             
        
        // Building CIM Request Details        
        ER_ENT_PRG_SearchCIMAccount.RequestDetails requestDetail = new ER_ENT_PRG_SearchCIMAccount.RequestDetails(); 
        ER_ENT_PRG_SearchCIMAccount.PhysicalAddress physicalAdd = new ER_ENT_PRG_SearchCIMAccount.PhysicalAddress();
        
        physicalAdd.PostalCd = accPostalCode;
        physicalAdd.CityNm = accCity;
        physicalAdd.PhysicalStreetAddressTxt = accAddr;
        physicalAdd.Country2Cd = accCountry;
        physicalAdd.CountrySubdivisionCd = accStateProvince;
        
        ER_ENT_PRG_SearchCIMAccount.BusinessOrganization busOrg = new ER_ENT_PRG_SearchCIMAccount.BusinessOrganization();
        busOrg.BusinessOrganizationNm = accName;
        busOrg.PhysicalAddress = physicalAdd;
        
        list<ER_ENT_PRG_SearchCIMAccount.ElectronicAddress> elecAddrList= new list<ER_ENT_PRG_SearchCIMAccount.ElectronicAddress>();
        if(companyWebsite!=null){
            ER_ENT_PRG_SearchCIMAccount.ElectronicAddress elecAddr= new ER_ENT_PRG_SearchCIMAccount.ElectronicAddress();
            elecAddr.ElectronicAddressTypeCd=System.Label.PRM_ELECADDR;
            elecAddr.ElectronicAddressTxt=companyWebsite;
            elecAddrList.add(elecAddr);
            busOrg.ElectronicAddress=elecAddrList;
            //busOrg.ElectronicAddress=elecAddr;
        }
        requestDetail.BusinessOrganization = busOrg;
        if (rcdLimit==null){
            rcdLimit= cimMdt.PRM_Max_Records__c;
        }
        if(searchScore==null){
            searchScore=string.valueof(cimMdt.PRM_Min_Score__c);   
        }
		requestDetail.MaximumNumberOfRecordsToReturn = rcdLimit;
        requestDetail.CallingSourceSystem = cimMdt.PRM_Calling_System__c;
        requestDetail.MandatoryFieldRestrictionLevel = Integer.valueOf(cimMdt.PRM_Restriction_Level__c);
        requestDetail.MinimumSearchScore = Integer.valueOf(searchScore);
        requestDetail.IncludeDefaultAttributesForSourceTypes = False;
        requestDetail.AsynchronousRequestId = cimMdt.PRM_Async_Id__c;
        
        //Building http Request for CIM Callout
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setEndpoint('callout:PRM_CIM_Callout_Credentials');        
        req.setMethod('POST');
        req.setTimeout(Integer.valueOf(System.Label.PRM_Timeout)); //60000
        req.setBody(JSON.serialize(requestDetail));
        
        try
        {
            if(accountsSfdc == null || accountsSfdc.size()==0)
            {
                if(regEmail != null)
                {
                    acctCont = ER_SearchSalesCloudAccounts.getAccounts(regEmail);
                }
            } 
            if (!isProgramBased || (accountsSfdc!=null && accountsSfdc.size() < Integer.valueOf(rcdLimit) || (acctCont!=null && (acctCont.size() < Integer.valueOf(rcdLimit)))))
            {
                HttpResponse response = new Http().send(req);
                
                if(response.getStatusCode() == 200 && String.isNotBlank(response.getBody()))
                {
                    PRM_CIMWrapper respWrap = (PRM_CIMWrapper)JSON.deserialize(response.getBody(),PRM_CIMWrapper.class);
                    if(Test.isRunningTest() && ER_SearchBeforeCreate_Test.IsEmailTest)
                    {
                        respWrap=null;
                    }
                    if(respWrap != null){
                        //respWrap,accountsSfdc,regEmail,partnerRole,isProgramBased
                        cimResults=handleResponse(respWrap,accountsSfdc,regEmail,partnerRole,isProgramBased);
                    }
                }else{
                    cimResults = null;
                    
                }
            }
            
        }       
        catch(Exception e){
            
            PRM_ErrorUtilityClass.logError(e);
            cimResults = null;
        }
        
        // Code for domain based email results
        //cimResults = null;
        try{
            if (fetchEmailDomainBasedAccts && (cimResults==null || cimResults.size() ==0))
            {
                set<id> accIdsSet = new set<id>();
                map<id,PRM_CIMSearchResults__c> accCimDetails = new map<id,PRM_CIMSearchResults__c>();
                if(accountsSfdc!=null && accountsSfdc.size() > 0 && isProgramBased)
                {
                    for(Id acctId : accountsSfdc)
                    {
                        PRM_CIMSearchResults__c srchResultInst = new PRM_CIMSearchResults__c();
                        srchResultInst=PRM_searchSfdcAccounts.instCimSearchResults(null,acctId);
                        cimResultsDomain.add(srchResultInst);
                        accCimDetails.put(acctId,srchResultInst);
                        accIdsSet.add(acctId);    
                    }
                }
                else if(acctCont!=null && acctCont.size()>0)
                {
                    for(Id acctIdSfdc : acctCont.keyset())
                    {
                        PRM_CIMSearchResults__c srchResultInst = new PRM_CIMSearchResults__c();
                        if(!isProgramBased)
                        {
                        	srchResultInst=ER_SearchSalesCloudAccounts.instCimSearchResults(acctIdSfdc);
                        }
                        else
                        {
                            srchResultInst=PRM_searchSfdcAccounts.instCimSearchResults(null,acctIdSfdc);
                        }
                        cimResultsDomain.add(srchResultInst);
                        accCimDetails.put(acctIdSfdc,srchResultInst);
                        accIdsSet.add(acctIdSfdc);
                    }
                }
                
                
                if(cimResultsDomain != null && cimResultsDomain.size() > 0)
                {
                    if(isProgramBased)
                    {
                        List<PRM_SearchAccounts> listOfSortedObj = new List<PRM_SearchAccounts>();
                        listOfSortedObj=PRM_searchSfdcAccounts.getSortedAccountsCim(cimResultsDomain,accIdsSet,partnerRole);
                        cimResultsDomain.clear();
                        for(PRM_SearchAccounts objAccId : listOfSortedObj){
                            if(accCimDetails.containskey(objAccId.AccountId)){
                                cimResultsDomain.add(accCimDetails.get(objAccId.AccountId));
                                
                            }
                        }
                    }
                    
                    cimResults=cimResultsDomain;
                }
                else{
                    cimResults=null;
                }
            }
        }
        catch(Exception excep){
            
            PRM_ErrorUtilityClass.logError(excep);
            cimResults = null;
        }
        return cimResults;
    }
    
    // Mapping CIM results to PRM_CIMSearchResults__c Object 
    public list<PRM_CIMSearchResults__c> handleResponse(PRM_CIMWrapper wrapResp,set<id> accountsSfdc,String regEmail,String partnerRole,Boolean isProgramBased){
        list<PRM_CIMSearchResults__c> cimResultsList = new list<PRM_CIMSearchResults__c>();
        PRM_CIMWrapper respWrap = new PRM_CIMWrapper();
        respWrap.organization = wrapResp.organization;
        respWrap.ErrorCd = wrapResp.ErrorCd;
        respWrap.ErrorDetailsTxt = wrapResp.ErrorDetailsTxt;
        respWrap.ErrorDsc = wrapResp.ErrorDsc;
        respWrap.AsynchronousRequestId = wrapResp.AsynchronousRequestId;
        //map<PRM_CIMWrapper.Organization,integer> organizationMap = new map<PRM_CIMWrapper.Organization,integer>();
        map<string,integer> cimSearchScoreMap = new map<string,integer>();
        map<PRM_CIMWrapper.SourceRecord,string> cimSourceRecordsMap = new map<PRM_CIMWrapper.SourceRecord,string>();
        map<string,PRM_CIMWrapper.Organization> cimOrganizationMap = new map<string,PRM_CIMWrapper.Organization>();
        map<string,list<PRM_CIMWrapper.PhysicalAddress>> cimPhysicalAddrsMap = new map<string,list<PRM_CIMWrapper.PhysicalAddress>>();
        map<string,list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>> cimAddrUsageMap = new map<string,list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>>();
        map<string,PRM_CIMWrapper.PhysicalAddress> cimPhysicalAddrUsageMap = new map<string,PRM_CIMWrapper.PhysicalAddress>();
        map<string,string> validCimAccountMap = new map<string,string>();
        //map<string,Id> validCimSfidMap = new map<string,Id>();
        list<string> validCimSet = new list<string>();
        set<string> validSfidSet = new set<string>();
        //String addressUsageTypeCd;
        //String addressLocationTypeCd;
        String orgVal;
        Integer count =0;
        string respCimId;
        map<string,string> cimPhysicalAddrLocType = new map<string,string>();
        //List<PRM_Registration_Request__c> updateReg = [Select Id, PRM_Dup_Status__c, PRM_DeDup_Criteria__c from PRM_Registration_Request__c where Id =: regRequest.Id];
        if(respWrap.organization != null && respWrap.ErrorDetailsTxt == null){
            //Integer maxVal = respWrap.organization[0].searchScore;
            Integer maxVal = 0;
            Integer counterMax = 0;
            Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
            // Logic for filtering only the valid CIM IDs in salesforce
            set<string> blankSfidsCim = new set<string>();
            
            //REVIST :: Write in below format rather than for int ++
            //Also add if SLSCLD, then only do operations
            /*for(PRM_CIMWrapper.Organization s : respWrap.organization)
            {
                validCimSet.add(s.Snapshot.BusinessOrganization.BusinessOrganizationPartyId);
            }*/
            
            for(Integer s=0; s< respWrap.organization.size(); s++){
                //String cimId =respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId;
                validCimSet.add(respWrap.organization[s].Snapshot.BusinessOrganization.BusinessOrganizationPartyId);
                if(respWrap.organization[s].sourceRecords!=null && respWrap.organization[s].sourceRecords.SourceRecord.isEmpty()){
                    blankSfidsCim.add(respWrap.organization[s].Snapshot.BusinessOrganization.BusinessOrganizationPartyId);	
                }
                for(integer z=0;z<respWrap.organization[s].sourceRecords.SourceRecord.size();z++){
                    if (respWrap.organization[s].sourceRecords.SourceRecord[z].SourceBusinessOrganization.BusinessOrganizationPartyId !=null && respWrap.organization[s].sourceRecords.SourceRecord[z].SourceBusinessOrganization.BusinessOrganizationPartyId!=' ' && respWrap.organization[s].sourceRecords.SourceRecord[z].SourceBusinessOrganization.BusinessOrganizationPartyId.length()>0){
                        validSfidSet.add(respWrap.organization[s].sourceRecords.SourceRecord[z].SourceBusinessOrganization.BusinessOrganizationPartyId); 
                    }
                    else{						
                        blankSfidsCim.add(respWrap.organization[s].Snapshot.BusinessOrganization.BusinessOrganizationPartyId);
                    }
                }
            }
            for(Account a : [Select Id,Name,Core_CIM_ID__c from Account where RecordTypeId =:intelaccountRT and (Core_CIM_ID__c IN: validCimSet or id in:validSfidSet)]){
                validCimAccountMap.put(String.valueof(a.Id),a.Core_CIM_ID__c);
                //validCimAccountMap.put(a.id,a.Id);
            }
            
            // Code for adding the source records
            map<string,list<PRM_CIMWrapper.SourceRecord>> cimAccountSourceMap = new map<string,list<PRM_CIMWrapper.SourceRecord>>();
            for (string accountId: validCimAccountMap.keyset()){
                List<PRM_CIMWrapper.SourceRecord> sourceRcds = new list<PRM_CIMWrapper.SourceRecord>();
                PRM_CIMWrapper.SourceRecord sourceRcd= new PRM_CIMWrapper.SourceRecord();
                sourceRcd.SourceSystemCd='SLSCLD';
                sourceRcd.SourceBusinessOrganization = new PRM_CIMWrapper.SourceBusinessOrganization();
                sourceRcd.SourceBusinessOrganization.BusinessOrganizationPartyId=accountId;
                sourceRcd.SourceBusinessOrganizationNm = new list<PRM_CIMWrapper.SourceBusinessOrganizationNm>();
                sourceRcd.SourcePhysicalAddress = new list<PRM_CIMWrapper.PhysicalAddress>();
                sourceRcd.SourceElectronicAddress = new list<PRM_CIMWrapper.BusinessOrganizationLegalAgreement>();
                sourceRcd.SourceBusinessOrganizationLegalAgreement = new list<PRM_CIMWrapper.BusinessOrganizationLegalAgreement>();
                sourceRcd.SourceBusinessOrganizationNAICS = new list<PRM_CIMWrapper.BusinessOrganizationLegalAgreement>();
                sourceRcd.SourceBusinessOrganizationRoleAssociation = new list<PRM_CIMWrapper.BusinessOrganizationLegalAgreement>();
                sourceRcd.SourceBusinessOrganizationSIC = new list<PRM_CIMWrapper.BusinessOrganizationLegalAgreement>();
                sourceRcd.SourceBusinessOrganizationThirdPartyTrustedSourceInfo = new list<PRM_CIMWrapper.BusinessOrganizationLegalAgreement>();
                sourceRcd.SourceBusinessOrganizationThirdPartyWatchList = new list<PRM_CIMWrapper.BusinessOrganizationLegalAgreement>();
                sourceRcd.SourceBusinessOrganizationEngagementDeduplicationGroupAssociation =null;
                sourceRcd.SourceBusinessOrganizationSalesGroup =null;
                sourceRcd.SourceBusinessOrganizationSourceSystemTestAttribute =null;
                sourceRcd.SourceBusinessOrganizationStatus = new PRM_CIMWrapper.SourceBusinessOrganizationStatus();
                sourceRcd.SourceBusinessOrganizationAdditionalEntity=null;
                
                if (cimAccountSourceMap.containsKey(validCimAccountMap.get(accountId))){
                    List<PRM_CIMWrapper.SourceRecord> sourceRcdsExisting = new list<PRM_CIMWrapper.SourceRecord>();
                    sourceRcdsExisting = cimAccountSourceMap.get(validCimAccountMap.get(accountId));
                    sourceRcdsExisting.add(sourceRcd);
                    cimAccountSourceMap.put(validCimAccountMap.get(accountId),sourceRcdsExisting);
                }else{
                    sourceRcds.add(sourceRcd);
                    cimAccountSourceMap.put(validCimAccountMap.get(accountId),sourceRcds);
                }
                
            }
            
            for(Integer i=0; i< respWrap.organization.size(); i++){
                //orgVal= orgVal+' '+i;
                respCimId = respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId;
                if (blankSfidsCim.contains(respCimId) && cimAccountSourceMap.containsKey(respCimId)){
                    respWrap.organization[i].sourceRecords.SourceRecord.addall(cimAccountSourceMap.get(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId));
                }
                for(integer j=0;j<respWrap.organization[i].sourceRecords.SourceRecord.size();j++){
                    if(validCimAccountMap.containsKey(respWrap.organization[i].sourceRecords.SourceRecord[j].SourceBusinessOrganization.BusinessOrganizationPartyId) || validCimAccountMap.values().contains(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId)){
                       
                        //if(respWrap.organization[i].searchScore > maxVal && respWrap.organization[i].sourceRecords.SourceRecord[j].SourceSystemCd=='SLSCLD'){
                        if(respWrap.organization[i].searchScore >= Integer.valueOf(cimMdt.PRM_Max_Score__c) && respWrap.organization[i].sourceRecords.SourceRecord[j].SourceSystemCd=='SLSCLD'){
                            maxVal = respWrap.organization[i].searchScore;
                            counterMax = counterMax + 1;
                            // Get the map for the organization searchscore and source records
                            //if (counterMax >= 1) {
                            cimSearchScoreMap.put(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId,respWrap.organization[i].searchScore);
                            cimSourceRecordsMap.put(respWrap.organization[i].sourceRecords.SourceRecord[j],respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId);
                            cimOrganizationMap.put(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId,respWrap.organization[i]);
                            cimPhysicalAddrsMap.put(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId,respWrap.organization[i].Snapshot.PhysicalAddress);
                            // }
                        } else
                            // Get the map for the organization searchscore and source records
                            //if((respWrap.organization[i].searchScore >= Integer.valueOf(cimMdt.PRM_Min_Score__c) && respWrap.organization[i].searchScore < Integer.valueOf(cimMdt.PRM_Max_Score__c)) && respWrap.organization[i].sourceRecords.SourceRecord[j].SourceSystemCd=='SLSCLD' && counterMax == 0){
                            if((respWrap.organization[i].searchScore >= Integer.valueOf(cimMdt.PRM_Min_Score__c) && respWrap.organization[i].searchScore < Integer.valueOf(cimMdt.PRM_Max_Score__c)) && respWrap.organization[i].sourceRecords.SourceRecord[j].SourceSystemCd=='SLSCLD'){
                                maxVal = respWrap.organization[i].searchScore;
                                cimSearchScoreMap.put(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId,respWrap.organization[i].searchScore);
                                cimSourceRecordsMap.put(respWrap.organization[i].sourceRecords.SourceRecord[j],respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId);
                                cimOrganizationMap.put(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId,respWrap.organization[i]);
                                cimPhysicalAddrsMap.put(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId,respWrap.organization[i].Snapshot.PhysicalAddress);                        
                            }
                    }
                }
                
            }
            
            // Code for getting the physical address of specified usage types
            map<string,map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>> cimUsagePhyMap = new map<string,map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>>();
            if(cimPhysicalAddrsMap != null && !cimPhysicalAddrsMap.isEmpty()){
                for(string cimID : cimPhysicalAddrsMap.keyset()){
                    map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>  usgPhyAddr = new map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>(); 
                    for (integer phyAddrCount=0;phyAddrCount<cimPhysicalAddrsMap.get(cimID).size();phyAddrCount++){
                        usgPhyAddr.put(cimPhysicalAddrsMap.get(cimID)[phyAddrCount].PhysicalAddressUsageLocationAssociation,cimPhysicalAddrsMap.get(cimID)[phyAddrCount]);
                        cimUsagePhyMap.put(cimID,usgPhyAddr);
                    }
                }}
            //Logic for extracting only the PHYSICAL and BUS Type
            map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,string> usgCimMap = new map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,string>();
            if(cimUsagePhyMap != null && !cimUsagePhyMap.isEmpty()){
                for(string cimIDs : cimUsagePhyMap.keyset()){
                    map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>  usgPhyAddrDet = new map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>(); 
                    usgPhyAddrDet = cimUsagePhyMap.get(cimIDs);
                    for (list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation> listusg: usgPhyAddrDet.keyset()){
                        usgCimMap.put(listusg,cimIDs);
                    }
                }}
            if(usgCimMap != null && !usgCimMap.isEmpty()){
                for (list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation> usgDetList : usgCimMap.keyset()){
                    for (PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation usgDet: usgDetList){
                        
                        
                        if (usgDet.AddressUsageTypeCd == System.Label.PRM_ADDRUSGTYPE && usgDet.AddressLocationTypeCd== System.Label.PRM_ADDRLOCTYPE){
                            map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>  usgPhyAddrDetUsg = new map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>(); 
                            usgPhyAddrDetUsg=cimUsagePhyMap.get(usgCimMap.get(usgDetList));
                            cimPhysicalAddrUsageMap.put(usgCimMap.get(usgDetList),usgPhyAddrDetUsg.get(usgDetList));
                            //addressUsageTypeCd = System.Label.PRM_ADDRUSGTYPE;
                            //addressLocationTypeCd = System.Label.PRM_ADDRLOCTYPE;
                            cimPhysicalAddrLocType.put(usgCimMap.get(usgDetList),System.Label.PRM_ADDRUSGTYPE+','+System.Label.PRM_ADDRLOCTYPE);
                            break;
                        }
                        else if (usgDet.AddressUsageTypeCd == System.Label.PRM_ADDRUSGTYPE_MAIL && usgDet.AddressLocationTypeCd== System.Label.PRM_ADDRLOCTYPE){
                            map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>  usgPhyAddrDetUsg = new map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>(); 
                            usgPhyAddrDetUsg=cimUsagePhyMap.get(usgCimMap.get(usgDetList));
                            cimPhysicalAddrUsageMap.put(usgCimMap.get(usgDetList),usgPhyAddrDetUsg.get(usgDetList));
                            //addressUsageTypeCd = 'MAIL';
                            //addressLocationTypeCd = 'BUS';
                            cimPhysicalAddrLocType.put(usgCimMap.get(usgDetList),System.Label.PRM_ADDRUSGTYPE_MAIL+','+System.Label.PRM_ADDRLOCTYPE);
                        }
                        else if (!cimPhysicalAddrUsageMap.containsKey(usgCimMap.get(usgDetList))){
                            map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>  usgPhyAddrDetUsg = new map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>(); 
                            usgPhyAddrDetUsg=cimUsagePhyMap.get(usgCimMap.get(usgDetList));
                            cimPhysicalAddrUsageMap.put(usgCimMap.get(usgDetList),usgPhyAddrDetUsg.get(usgDetList));
                            //addressUsageTypeCd = usgDet.AddressUsageTypeCd;
                            //addressLocationTypeCd = usgDet.AddressLocationTypeCd; 
                            cimPhysicalAddrLocType.put(usgCimMap.get(usgDetList),usgDet.AddressUsageTypeCd+','+usgDet.AddressLocationTypeCd);
                        }
                        
                    }
                }}
            
            ER_cimDataWrap cimDataWrap = new ER_cimDataWrap();
            cimDataWrap.cimSourceRecordsMap=cimSourceRecordsMap;
            cimDataWrap.cimOrganizationMap=cimOrganizationMap;
            cimDataWrap.cimSearchScoreMap=cimSearchScoreMap;
            cimDataWrap.regReqId=null;
            cimDataWrap.cimPhysicalAddrsMap=cimPhysicalAddrsMap;
            cimDataWrap.cimAddrUsageMap=cimAddrUsageMap;
            cimDataWrap.cimPhysicalAddrUsageMap=cimPhysicalAddrUsageMap;
            cimDataWrap.dupStatus=System.Label.PRM_Partdup;
            cimDataWrap.cimPhyAddrLocType=cimPhysicalAddrLocType;
            cimResultsList=insertCimSearchResults(cimDataWrap,accountsSfdc,regEmail,partnerRole,isProgramBased);
            
        }
        else if(respWrap.organization == null && respWrap.ErrorDetailsTxt!=null && respWrap.ErrorDetailsTxt.contains(System.Label.PRM_ErrorDetails)){
           
            cimResultsList= null;
        }
        // Code added to store the CIM error details in the the registration object
        else if(respWrap.organization == null && respWrap.ErrorDetailsTxt!=null && respWrap.ErrorDsc!=null){
            cimResultsList= null;
        }
        return cimResultsList;
    }
    
    private list<PRM_CIMSearchResults__c> insertCimSearchResults(ER_cimDataWrap cimDataWrap,set<id> accountsSfdc,String regEmail,String partnerRole,Boolean isProgramBased){
        list<PRM_CIMSearchResults__c> searchResultsList = new list<PRM_CIMSearchResults__c>();
        list<PRM_CIMSearchResults__c> sortedSearchResultsList = new list<PRM_CIMSearchResults__c>();
        map<string,PRM_CIMSearchResults__c> accountCimMapUnSorted = new map<string,PRM_CIMSearchResults__c>();
        
        // Get the values from wrapper 
        map<PRM_CIMWrapper.SourceRecord,string> cimSourceRecordsMap=cimDataWrap.cimSourceRecordsMap;
        map<string,PRM_CIMWrapper.Organization> cimOrganizationMap=cimDataWrap.cimOrganizationMap;
        map<string,integer> cimSearchScoreMap=cimDataWrap.cimSearchScoreMap;
        Id regReqId=cimDataWrap.regReqId;
        map<string,list<PRM_CIMWrapper.PhysicalAddress>> cimPhysicalAddrsMap=cimDataWrap.cimPhysicalAddrsMap;
        map<string,list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>> cimAddrUsageMap=cimDataWrap.cimAddrUsageMap;
        map<string,PRM_CIMWrapper.PhysicalAddress> cimPhysicalAddrUsageMap=cimDataWrap.cimPhysicalAddrUsageMap;
        string dupStatus=cimDataWrap.dupStatus;
        try{
            for (PRM_CIMWrapper.SourceRecord sourceRecord : cimSourceRecordsMap.keySet()){
                PRM_CIMSearchResults__c searchResults = new PRM_CIMSearchResults__c();
                PRM_CIMWrapper.organization orgValue = new PRM_CIMWrapper.organization();
                string cimId = cimSourceRecordsMap.get(sourceRecord);
                orgValue = cimOrganizationMap.get(cimId);
                integer searchScore = cimSearchScoreMap.get(cimId);
                ER_cimInstWrap cimInstWrap = new ER_cimInstWrap();
                if(isProgramBased)
                {
                    cimInstWrap.regReqId=regReqId;
                }
                cimInstWrap.searchscore=searchScore;
                cimInstWrap.orgValue=orgValue;
                cimInstWrap.sourceRecord=sourceRecord;
                cimInstWrap.cimId=cimId;
                cimInstWrap.cimPhysicalAddrsMap=cimPhysicalAddrsMap;
                cimInstWrap.cimAddrUsageMap=cimAddrUsageMap;
                cimInstWrap.cimPhysicalAddrUsageMap=cimPhysicalAddrUsageMap; 
                cimInstWrap.cimPhyAddLocType=cimDataWrap.cimPhyAddrLocType;
                searchResults = instantiateCimSearchResultsObj(cimInstWrap);
                searchResultsList.add(searchResults);
                
            }
            //insert searchResultsList;
            
            if(!isProgramBased)
            {
                return searchResultsList; 
            }
            else
            {
                //Insert the accounts searched inside Salesforce
                set<id> accountIdsSearched = new set<id>();
                if(accountsSfdc!=null && accountsSfdc.size()>0){
                    for(Id acctId : accountsSfdc){
                        PRM_CIMSearchResults__c srchResultInst = new PRM_CIMSearchResults__c();
                        srchResultInst=PRM_searchSfdcAccounts.instCimSearchResults(null,acctId);
                        searchResultsList.add(srchResultInst);
                    }
                    
                }else{
                    // Code for getting the email domain from admin registration page
                    if(regEmail!=null){
                        map<id,contact> acctCont=PRM_searchSfdcAccounts.getAccounts(regEmail);
                        for (Id accIdsSrchd : acctCont.keyset()){
                            accountIdsSearched.add(accIdsSrchd);
                            PRM_CIMSearchResults__c srchResultInst = new PRM_CIMSearchResults__c();
                            srchResultInst=PRM_searchSfdcAccounts.instCimSearchResults(null,accIdsSrchd);
                            searchResultsList.add(srchResultInst);
                        }
                    }
                }
                
                for (PRM_CIMSearchResults__c mapaccountIdCim : searchResultsList)
                {
                    accountCimMapUnSorted.put(mapaccountIdCim.PRM_Account_Id__c,mapaccountIdCim);
                }
                List<PRM_SearchAccounts> listOfSortedObj = new List<PRM_SearchAccounts>();
                listOfSortedObj=PRM_searchSfdcAccounts.getSortedAccountsCim(searchResultsList,accountIdsSearched,partnerRole);
                for(PRM_SearchAccounts objAccId : listOfSortedObj){
                    if(accountCimMapUnSorted.containskey(objAccId.AccountId)){
                        if(!sortedSearchResultsList.contains(accountCimMapUnSorted.get(objAccId.AccountId))){
                            sortedSearchResultsList.add(accountCimMapUnSorted.get(objAccId.AccountId));
                        }
                    }
                }
                // Check the result list
                for (PRM_CIMSearchResults__c sorted : sortedSearchResultsList){
                }                
            }
        }
        catch(Exception errCimResults){
            PRM_ErrorUtilityClass.logError(errCimResults);
            searchResultsList = null;
        }
        
        return sortedSearchResultsList;
    }
    
    private PRM_CIMSearchResults__c instantiateCimSearchResultsObj(ER_cimInstWrap cimInstWrap){
        PRM_CIMSearchResults__c searchResultsInst = new PRM_CIMSearchResults__c();
        PRM_CIMWrapper.PhysicalAddress phyAddrUsageDet=new PRM_CIMWrapper.PhysicalAddress();
        searchResultsInst.PRM_RegReq_Id__c = cimInstWrap.regReqId;
        searchResultsInst.PRM_CIM_Id__c = cimInstWrap.cimId;
        searchResultsInst.PRM_SearchScore_Nbr__c = cimInstWrap.searchscore;
        PRM_CIMWrapper.SourceRecord sourceRecord= cimInstWrap.sourceRecord;
        map<string,PRM_CIMWrapper.PhysicalAddress> cimPhysicalAddrUsageMap=cimInstWrap.cimPhysicalAddrUsageMap;
        map<string,list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>> cimAddrUsageMap=cimInstWrap.cimAddrUsageMap;
        map<string,list<PRM_CIMWrapper.PhysicalAddress>> cimPhysicalAddrsMap=cimInstWrap.cimPhysicalAddrsMap;
        id acctid;
        string cimId = cimInstWrap.cimId;
        PRM_CIMWrapper.organization orgValue = cimInstWrap.orgValue;
        if (sourceRecord.SourceBusinessOrganization.BusinessOrganizationPartyId !=null && sourceRecord.SourceBusinessOrganization.BusinessOrganizationPartyId!=' ' && sourceRecord.SourceBusinessOrganization.BusinessOrganizationPartyId.length()>0){
            acctid = (id)sourceRecord.SourceBusinessOrganization.BusinessOrganizationPartyId;
        }
        if(cimPhysicalAddrUsageMap != null && !cimPhysicalAddrUsageMap.isEmpty()){
            phyAddrUsageDet=cimPhysicalAddrUsageMap.get(cimID);
            
            String addrdetails = cimInstWrap.cimPhyAddLocType.get(cimID);
            if(addrdetails !=null){
                List<string> addrVal = addrdetails.split(',');
                searchResultsInst.PRM_AddressType_Nm__c = addrVal[0];
                searchResultsInst.PRM_AddressLoc_Nm__c = addrVal[1];
            }
        }
        if (acctid!=null){
            List<Account> acct = [Select Id from Account where id = :acctid];
            if(acct!=null && !acct.isEmpty()){
                searchResultsInst.PRM_Account_Id__c = acct[0].id; 
            }
            else{
                searchResultsInst.PRM_Account_Id__c = null;
            }
        }
        searchResultsInst.PRM_Account_Nm__c = orgValue.Snapshot.BusinessOrganizationNm[0].BusinessOrganizationNm;
        searchResultsInst.PRM_Country_Cd__c=accCountry;
        
        if (phyAddrUsageDet!=null){
            if (phyAddrUsageDet.PhysicalStreetAddressTxt!=null){
                searchResultsInst.PRM_AddressLine1_Txt__c = phyAddrUsageDet.PhysicalStreetAddressTxt;
            }
            if(phyAddrUsageDet.CityNm!=null){
                searchResultsInst.PRM_City_Nm__c = phyAddrUsageDet.CityNm;
            }
            if(phyAddrUsageDet.CountryNm!=null){
                searchResultsInst.PRM_Country_Nm__c = phyAddrUsageDet.CountryNm;
            }
            if(phyAddrUsageDet.PostalCd!=null){
                searchResultsInst.PRM_Postal_Cd__c = phyAddrUsageDet.PostalCd;
            }
            if(phyAddrUsageDet.CountrySubdivisionCd!=null){
                searchResultsInst.PRM_Subdiv_Cd__c = phyAddrUsageDet.CountrySubdivisionCd;
            }
            if(phyAddrUsageDet.CountrySubdivisionNm!=null){
                searchResultsInst.PRM_Subdiv_Nm__c = phyAddrUsageDet.CountrySubdivisionNm;
            }
        }
        if(orgValue.Snapshot.BusinessOrganizationGoldStatusAssociation.GoldProcessStatusApprovalStatusCd!=null){searchResultsInst.PRM_Gold_Record_Status_Nm__c = orgValue.Snapshot.BusinessOrganizationGoldStatusAssociation.GoldProcessStatusApprovalStatusCd;}
        if(orgValue.Snapshot.BusinessOrganizationTrustedReferenceProcessStatusAssociation.TrustedProcessStatusCd!=null){searchResultsInst.PRM_Gold_Trusted_Source_Nm__c = orgValue.Snapshot.BusinessOrganizationTrustedReferenceProcessStatusAssociation.TrustedProcessStatusCd;}
        if(orgValue.Snapshot.BusinessOrganization.DUNSNumber != null){
            searchResultsInst.PRM_DUNS_Nbr__c = integer.valueof(orgValue.Snapshot.BusinessOrganization.DUNSNumber);}
        return searchResultsInst;
        
    } 
    
    // Wrapper Classes for Input Request
    public class RequestDetails{
        public BusinessOrganization BusinessOrganization;
        public String MaximumNumberOfRecordsToReturn;
        public String CallingSourceSystem;
        public Integer MandatoryFieldRestrictionLevel;
        public Integer MinimumSearchScore;
        public Boolean IncludeDefaultAttributesForSourceTypes;
        public String AsynchronousRequestId;
    }
    
    public class BusinessOrganization{
        public String BusinessOrganizationNm;
        public PhysicalAddress PhysicalAddress;
        public list<ElectronicAddress> ElectronicAddress;
    }
    
    public class PhysicalAddress{
        public String PostalCd;
        public String CityNm;
        public String PhysicalStreetAddressTxt;
        public String Country2Cd;
        public string CountrySubdivisionCd;
    }
    // Wrapper class for the function datas
    
    
    public class ER_cimDataWrap{
        public map<PRM_CIMWrapper.SourceRecord,string> cimSourceRecordsMap;
        public map<string,PRM_CIMWrapper.Organization> cimOrganizationMap;
        public map<string,integer> cimSearchScoreMap;
        public Id regReqId;
        public map<string,list<PRM_CIMWrapper.PhysicalAddress>> cimPhysicalAddrsMap;
        public map<string,list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>> cimAddrUsageMap;
        public map<string,PRM_CIMWrapper.PhysicalAddress> cimPhysicalAddrUsageMap;
        public string dupStatus;
        //String addrssUsageTypeCd;
        //String addrssLocationTypeCd;
        public map<string,string> cimPhyAddrLocType;
    }
    // Wrapper class for electronic address
    public class ElectronicAddress{
        public string ElectronicAddressTypeCd;
        public string ElectronicAddressTxt;
    }
    //Wrapper class for the instantiating sObject
    public class ER_cimInstWrap{
        public Id regReqId;
        public integer searchscore;
        public PRM_CIMWrapper.organization orgValue;
        public PRM_CIMWrapper.SourceRecord sourceRecord;
        public string cimId;
        public map<string,list<PRM_CIMWrapper.PhysicalAddress>> cimPhysicalAddrsMap;
        public map<string,list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>> cimAddrUsageMap;
        public map<string,PRM_CIMWrapper.PhysicalAddress> cimPhysicalAddrUsageMap;
        //String addrUsageTypeCd;
        //String addrLocationTypeCd;
        public map<string,string> cimPhyAddLocType;
    }
}