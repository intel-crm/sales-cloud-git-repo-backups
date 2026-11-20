public class ER_DupCheck_CIMCallout implements Queueable, Database.AllowsCallouts 
{
    public PRM_Registration_Request__c regRequest;
    PRM_CIM_Request__mdt cimMdt = [Select Id, MasterLabel,API_Key__c, PRM_Async_Id__c, PRM_Calling_System__c, PRM_Restriction_Level__c, PRM_Max_Records__c, PRM_Max_Score__c, PRM_Min_Score__c from PRM_CIM_Request__mdt where MasterLabel =: System.Label.PRM_Dupe_Scores];
    public Integer countReattempt; 
    public string rcdLimit;
    Public string searchScore;
    public string companyWebsite;
    public list<PRM_CIMSearchResults__c> listOfCimSearchResults = new list<PRM_CIMSearchResults__c>();
    public map<id,contact> acctCont = new map<id,contact>();
    public String regEmail;
    public list<PRM_CIMSearchResults__c> searchResultsDomList = new list<PRM_CIMSearchResults__c>();
    Public string reqAcctId;
    public boolean isReqAcc;
    public String billingCountryForCallout;
    public boolean isSameRequestedAccount=false;
    public Boolean cimCall;
    
    public ER_DupCheck_CIMCallout(PRM_Registration_Request__c regRequest,Integer countReattempt,String rcdLimit,String searchScore,String companyWebsite, Boolean cimCall)
    {
        this.regRequest = regRequest;
        this.countReattempt = countReattempt;
        this.rcdLimit = rcdLimit;
        this.searchScore= searchScore;
        this.companyWebsite = companyWebsite;
        this.cimCall = cimCall;
        regEmail=regRequest.PRM_Email_ID__c;
        if (regRequest.PRM_Salesforce_ID__c!=null){
            reqAcctId = regRequest.PRM_Salesforce_ID__c;
        }     
    }
    
    public void execute(QueueableContext currentContext){
        
        //Building http Request for CIM Callout
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setEndpoint('callout:PRM_CIM_Callout_Credentials');        
        req.setMethod('POST');
        req.setTimeout(Integer.valueOf(System.Label.PRM_Timeout));    
        
        Map<String,String> countryMap = new map<String,String>();
        for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
            countryMap.put(allCountries.ISO_Code__c, allCountries.Country_Code__c);
        }
        
        if(regRequest.PRM_Country__c!=null && regRequest.PRM_Country__c.length() == 3 && countryMap != null && countryMap.containsKey(regRequest.PRM_Country__c)){
            billingCountryForCallout = countryMap.get(regRequest.PRM_Country__c);
        }
        
        List<PRM_Registration_Request__c> updateReg = [Select Id, PRM_Dup_Status__c, PRM_DeDup_Criteria__c,PRM_CIMStatusDetails__c from PRM_Registration_Request__c where Id =: regRequest.Id];
        
        // Building CIM Request Details        
        ER_SearchCIMAccounts.RequestDetails requestDetail = new ER_SearchCIMAccounts.RequestDetails(); 
        ER_SearchCIMAccounts.PhysicalAddress physicalAdd = new ER_SearchCIMAccounts.PhysicalAddress();
        ER_SearchCIMAccounts.BusinessOrganization busOrg = new ER_SearchCIMAccounts.BusinessOrganization();
        
        // Get the details from Account object for existing Account scenario
        if (regRequest.PRM_Salesforce_ID__c!=null){
            reqAcctId = regRequest.PRM_Salesforce_ID__c;
            Account acc =[select name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Website from account where id =:regRequest.PRM_Salesforce_ID__c];
            physicalAdd.PhysicalStreetAddressTxt=acc.BillingStreet;
            physicalAdd.PostalCd = acc.BillingPostalCode;
            physicalAdd.CityNm = acc.BillingCity;
            physicalAdd.Country2Cd = countryMap.get(acc.BillingCountry);
            physicalAdd.CountrySubdivisionCd = acc.BillingState;
            busOrg.BusinessOrganizationNm = acc.Name;
        }else{
            busOrg.BusinessOrganizationNm = regRequest.PRM_Account_Name__c;
            physicalAdd.PostalCd = regRequest.PRM_Zip_Postal_Code__c;
            physicalAdd.CityNm = regRequest.PRM_City__c;
            if (regRequest.PRM_Address_Line_2__c!=null && regRequest.PRM_Address_Line_2__c!=''){
                physicalAdd.PhysicalStreetAddressTxt = regRequest.PRM_Address_Line_1__c+' '+regRequest.PRM_Address_Line_2__c; 
            }else{
                physicalAdd.PhysicalStreetAddressTxt = regRequest.PRM_Address_Line_1__c;
            }
            if(billingCountryForCallout!=null){
                physicalAdd.Country2Cd=billingCountryForCallout;
            }else{
                physicalAdd.Country2Cd = regRequest.PRM_Country__c;
            }
            physicalAdd.CountrySubdivisionCd = regRequest.PRM_State_Province__c;
        }        
        busOrg.PhysicalAddress = physicalAdd;
        
        
        list<ER_SearchCIMAccounts.ElectronicAddress> elecAddrList= new list<ER_SearchCIMAccounts.ElectronicAddress>();
        if(companyWebsite!=null){
            ER_SearchCIMAccounts.ElectronicAddress elecAddr= new ER_SearchCIMAccounts.ElectronicAddress();
            elecAddr.ElectronicAddressTypeCd=System.Label.PRM_ELECADDR;
            elecAddr.ElectronicAddressTxt=companyWebsite;
            elecAddrList.add(elecAddr);
            busOrg.ElectronicAddress=elecAddrList;
        }
        else{
            ER_SearchCIMAccounts.ElectronicAddress elecAddr= new ER_SearchCIMAccounts.ElectronicAddress();
            elecAddr.ElectronicAddressTypeCd=System.Label.PRM_ELECADDR;
            elecAddr.ElectronicAddressTxt=regRequest.PRM_Account_URL__c;
            elecAddrList.add(elecAddr);
            busOrg.ElectronicAddress=elecAddrList;
        }
        requestDetail.BusinessOrganization = busOrg;
        if (rcdLimit==null){
            rcdLimit=cimMdt.PRM_Max_Records__c;
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
        
        String reqBody = JSON.serialize(requestDetail);
        
        req.setBody(reqBody);
        
        try {
            HttpResponse response = http.send(req);
            
            if(response.getStatusCode() == 200 && String.isNotBlank(response.getBody())){
                PRM_CIMWrapper respWrap = (PRM_CIMWrapper)JSON.deserialize(response.getBody(),PRM_CIMWrapper.class);
                if(Test.isRunningTest() && ER_SearchBeforeCreate_Test.IsEmailTest)
                {
                    respWrap=null;
                }
                if(respWrap != null){
                    handleResponse(respWrap, updateReg);
                }
            }
            else{
                countReattempt=countReattempt+1;
                if(countReattempt==3){
                    updateReg[0].PRM_Dup_Status__c = System.Label.PRM_Error;
                    updateReg[0].PRM_DeDup_Criteria__c = System.Label.PRM_Fail;
                    updateReg[0].PRM_CIMStatusDetails__c = response.getBody();
                    update updateReg;                    
                }
                else if(countReattempt ==null || countReattempt <3){
                    if(!Test.isRunningTest())
                    {
                        Id queueId = System.enqueueJob(new ER_DupCheck_CIMCallout(regRequest,countReattempt,rcdLimit,searchScore,companyWebsite,true));
                    }
                }                  
            }          
        }   
        catch(Exception e){
            countReattempt=countReattempt+1;
            if(countReattempt==3){
                updateReg[0].PRM_Dup_Status__c = System.Label.PRM_Error;
                updateReg[0].PRM_DeDup_Criteria__c = System.Label.PRM_Fail;
                if(e.getMessage().contains('System.CalloutException')){
                    updateReg[0].PRM_CIMStatusDetails__c = 'CIM Call Out Error';
                }
                else{
                    updateReg[0].PRM_CIMStatusDetails__c = e.getMessage();
                }
                update updateReg;
                PRM_ErrorUtilityClass.logError(e);
                
            }
            else if(countReattempt ==null || countReattempt <3){
                if(!Test.isRunningTest())
                {
                    Id queueId = System.enqueueJob(new ER_DupCheck_CIMCallout(regRequest,countReattempt,rcdLimit,searchScore,companyWebsite,true));
                }
            }
        }
        
    }
    
    public void handleResponse(PRM_CIMWrapper wrapResp,List<PRM_Registration_Request__c> updateReg){
        PRM_CIMWrapper respWrap = new PRM_CIMWrapper();
        respWrap.organization = wrapResp.organization;
        respWrap.ErrorCd = wrapResp.ErrorCd;
        respWrap.ErrorDetailsTxt = wrapResp.ErrorDetailsTxt;
        respWrap.ErrorDsc = wrapResp.ErrorDsc;
        respWrap.AsynchronousRequestId = wrapResp.AsynchronousRequestId;
        map<string,integer> cimSearchScoreMap = new map<string,integer>();
        map<PRM_CIMWrapper.SourceRecord,string> cimSourceRecordsMap = new map<PRM_CIMWrapper.SourceRecord,string>();
        map<string,PRM_CIMWrapper.Organization> cimOrganizationMap = new map<string,PRM_CIMWrapper.Organization>();
        map<string,list<PRM_CIMWrapper.PhysicalAddress>> cimPhysicalAddrsMap = new map<string,list<PRM_CIMWrapper.PhysicalAddress>>();
        map<string,list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>> cimAddrUsageMap = new map<string,list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>>();
        map<string,PRM_CIMWrapper.PhysicalAddress> cimPhysicalAddrUsageMap = new map<string,PRM_CIMWrapper.PhysicalAddress>();
        map<string,string> validCimAccountMap = new map<string,string>();
        list<string> validCimSet = new list<string>();
        set<string> validSfidSet = new set<string>();
        String orgVal;
        Integer count =0;
        string respCimId;
        map<string,string> cimPhysicalAddrLocType = new map<string,string>();
        
        if(respWrap.organization != null && respWrap.ErrorDetailsTxt == null){
            Integer maxVal = 0;
            Integer counterMax = 0;
            Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
            // Logic for filtering only the valid CIM IDs in salesforce
            set<string> blankSfidsCim = new set<string>();
            for(Integer s=0; s< respWrap.organization.size(); s++){
                validCimSet.add(respWrap.organization[s].Snapshot.BusinessOrganization.BusinessOrganizationPartyId);
                if(respWrap.organization[s].sourceRecords.SourceRecord.size()==0){
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
                respCimId = respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId;
                if (blankSfidsCim.contains(respCimId) && cimAccountSourceMap.containsKey(respCimId)){
                    respWrap.organization[i].sourceRecords.SourceRecord.addall(cimAccountSourceMap.get(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId));
                }
                for(integer j=0;j<respWrap.organization[i].sourceRecords.SourceRecord.size();j++){
                    if(validCimAccountMap.containsKey(respWrap.organization[i].sourceRecords.SourceRecord[j].SourceBusinessOrganization.BusinessOrganizationPartyId) || validCimAccountMap.values().contains(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId)){
                        if(respWrap.organization[i].searchScore >= Integer.valueOf(cimMdt.PRM_Max_Score__c) && respWrap.organization[i].sourceRecords.SourceRecord[j].SourceSystemCd=='SLSCLD'){
                            //Code for setting status based on existing account
                            if (reqAcctId==null){
                                maxVal = respWrap.organization[i].searchScore;
                            }else{
                                if(reqAcctId!=null && reqAcctId<>respWrap.organization[i].sourceRecords.SourceRecord[j].SourceBusinessOrganization.BusinessOrganizationPartyId){
                                    maxVal = respWrap.organization[i].searchScore;
                                }
                            }
                            counterMax = counterMax + 1;
                            // Get the map for the organization searchscore and source records
                            cimSearchScoreMap.put(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId,respWrap.organization[i].searchScore);
                            cimSourceRecordsMap.put(respWrap.organization[i].sourceRecords.SourceRecord[j],respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId);
                            cimOrganizationMap.put(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId,respWrap.organization[i]);
                            cimPhysicalAddrsMap.put(respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId,respWrap.organization[i].Snapshot.PhysicalAddress);
                            //}
                        } else
                            // Get the map for the organization searchscore and source records
                            if((respWrap.organization[i].searchScore >= Integer.valueOf(cimMdt.PRM_Min_Score__c) && respWrap.organization[i].searchScore < Integer.valueOf(cimMdt.PRM_Max_Score__c)) && respWrap.organization[i].sourceRecords.SourceRecord[j].SourceSystemCd=='SLSCLD'){
                                //Code for setting status based on existing account
                                if(reqAcctId==null && respWrap.organization[i].searchScore >=maxval){
                                    maxVal = respWrap.organization[i].searchScore;
                                }
                                else{
                                    if (reqAcctId!=null && reqAcctId<>respWrap.organization[i].sourceRecords.SourceRecord[j].SourceBusinessOrganization.BusinessOrganizationPartyId){
                                        maxVal = respWrap.organization[i].searchScore;
                                    }
                                }
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
                            cimPhysicalAddrLocType.put(usgCimMap.get(usgDetList),System.Label.PRM_ADDRUSGTYPE+','+System.Label.PRM_ADDRLOCTYPE);
                            break;
                        }
                        else if (usgDet.AddressUsageTypeCd == System.Label.PRM_ADDRUSGTYPE_MAIL && usgDet.AddressLocationTypeCd== System.Label.PRM_ADDRLOCTYPE){
                            map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>  usgPhyAddrDetUsg = new map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>(); 
                            usgPhyAddrDetUsg=cimUsagePhyMap.get(usgCimMap.get(usgDetList));
                            cimPhysicalAddrUsageMap.put(usgCimMap.get(usgDetList),usgPhyAddrDetUsg.get(usgDetList));
                            cimPhysicalAddrLocType.put(usgCimMap.get(usgDetList),System.Label.PRM_ADDRUSGTYPE_MAIL+','+System.Label.PRM_ADDRLOCTYPE);
                        }
                        else if (!cimPhysicalAddrUsageMap.containsKey(usgCimMap.get(usgDetList))){
                            map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>  usgPhyAddrDetUsg = new map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>(); 
                            usgPhyAddrDetUsg=cimUsagePhyMap.get(usgCimMap.get(usgDetList));
                            cimPhysicalAddrUsageMap.put(usgCimMap.get(usgDetList),usgPhyAddrDetUsg.get(usgDetList));
                            cimPhysicalAddrLocType.put(usgCimMap.get(usgDetList),usgDet.AddressUsageTypeCd+','+usgDet.AddressLocationTypeCd);
                        }
                        
                    }
                }}
            if(maxVal < Integer.valueOf(cimMdt.PRM_Min_Score__c)){
                updateReg[0].PRM_Dup_Status__c = System.Label.PRM_Nodup;
                updateReg[0].PRM_DeDup_Criteria__c = System.Label.PRM_Success;
            }
            //else if(maxVal >= Integer.valueOf(cimMdt.PRM_Min_Score__c) && maxVal < Integer.valueOf(cimMdt.PRM_Max_Score__c) && (acctConts==null || acctConts.size()==0)){
            else if(maxVal >= Integer.valueOf(cimMdt.PRM_Min_Score__c) && maxVal < Integer.valueOf(cimMdt.PRM_Max_Score__c)){
                updateReg[0].PRM_Dup_Status__c = System.Label.PRM_Partdup;
                updateReg[0].PRM_DeDup_Criteria__c = System.Label.PRM_Fail;
                
            }
            else{
                updateReg[0].PRM_Dup_Status__c = System.Label.PRM_Fulldup;
                updateReg[0].PRM_DeDup_Criteria__c = System.Label.PRM_Fail;
            }
            //Insert into the CIM Search Result Object
            ER_SearchCIMAccounts.ER_cimDataWrap cimDataWrap = new ER_SearchCIMAccounts.ER_cimDataWrap();
            cimDataWrap.cimSourceRecordsMap=cimSourceRecordsMap;
            cimDataWrap.cimOrganizationMap=cimOrganizationMap;
            cimDataWrap.cimSearchScoreMap=cimSearchScoreMap;
            cimDataWrap.regReqId=regRequest.Id;
            cimDataWrap.cimPhysicalAddrsMap=cimPhysicalAddrsMap;
            cimDataWrap.cimAddrUsageMap=cimAddrUsageMap;
            cimDataWrap.cimPhysicalAddrUsageMap=cimPhysicalAddrUsageMap;
            cimDataWrap.dupStatus=updateReg[0].PRM_Dup_Status__c;
            cimDataWrap.cimPhyAddrLocType=cimPhysicalAddrLocType;
            insertCimSearchResults(cimDataWrap);
            
        }
        else if(respWrap.organization == null && respWrap.ErrorDetailsTxt!=null && respWrap.ErrorDetailsTxt.contains(System.Label.PRM_ErrorDetails)){
            updateReg[0].PRM_Dup_Status__c = System.Label.PRM_Nodup;
            updateReg[0].PRM_DeDup_Criteria__c = System.Label.PRM_Success;
        }
        // Code added to store the CIM error details in the the registration object
        else if(respWrap.organization == null && respWrap.ErrorDetailsTxt!=null && respWrap.ErrorDsc!=null){
            updateReg[0].PRM_Dup_Status__c = System.Label.PRM_Error;
            updateReg[0].PRM_DeDup_Criteria__c = System.Label.PRM_Fail;
            updateReg[0].PRM_CIMStatusDetails__c = respWrap.ErrorDetailsTxt + ' - ' + respWrap.ErrorDsc;
        }
        if(updateReg != null && !updateReg.isEmpty() && updateReg[0].PRM_DeDup_Criteria__c != System.Label.PRM_Pending){
            if(isSameRequestedAccount==true){
                updateReg[0].PRM_Dup_Status__c = System.Label.PRM_Nodup;
                updateReg[0].PRM_DeDup_Criteria__c = System.Label.PRM_Success; 
            }
            update updateReg;
        }
    }
    
    // Method for inserting into SearchResults object
    private void insertCimSearchResults(ER_SearchCIMAccounts.ER_cimDataWrap cimDataWrap){
        list<PRM_CIMSearchResults__c> searchResultsList = new list<PRM_CIMSearchResults__c>();
        list<PRM_CIMSearchResults__c> searchResultsList1 = new list<PRM_CIMSearchResults__c>();
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
                //list<PRM_CIMWrapper.PhysicalAddress> physicaladdrs = new list<PRM_CIMWrapper.PhysicalAddress>();
                //orgValue = organizationKey;
                string cimId = cimSourceRecordsMap.get(sourceRecord);
                orgValue = cimOrganizationMap.get(cimId);
                integer searchScore = cimSearchScoreMap.get(cimId);
                //physicaladdrs = cimPhysicalAddrsMap.get(cimId);
                //PRM_CIMWrapper.SourceRecord sourceRecord = new PRM_CIMWrapper.SourceRecord();
                //sourceRecord = organizationSourceMap.get(organizationKey);
                ER_SearchCIMAccounts.ER_cimInstWrap cimInstWrap = new ER_SearchCIMAccounts.ER_cimInstWrap();
                cimInstWrap.regReqId=regReqId;
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
            
            Database.SaveResult[] insertReslt = Database.insert(searchResultsList,false);
            for (Database.SaveResult sr : insertReslt) {
                if (sr.isSuccess()) {
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                    }
                }
            }
            integer countAcc = 0;
            for(PRM_CIMSearchResults__c searchResults : searchResultsList)
                
            {
                
                if(string.valueOf(searchResults.PRM_Account_Id__c)==reqAcctId && countAcc==0){
                    isSameRequestedAccount=true;
                    countAcc=countAcc+1;
                }else{
                    if(string.valueOf(searchResults.PRM_Account_Id__c)!=reqAcctId){
                        isSameRequestedAccount=false; 
                        countAcc=countAcc+1;}  
                }
            }
            
            
        }
        catch(Exception errCimResults){
            PRM_ErrorUtilityClass.logError(errCimResults);
        }
    }
    
    // Instantiating the CIM Search Results Object
    private PRM_CIMSearchResults__c instantiateCimSearchResultsObj(ER_SearchCIMAccounts.ER_cimInstWrap cimInstWrap){
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
            /*searchResultsInst.PRM_AddressType_Nm__c = System.Label.PRM_ADDRUSGTYPE;
searchResultsInst.PRM_AddressLoc_Nm__c = System.Label.PRM_ADDRLOCTYPE; */
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
        if(billingCountryForCallout!=null){
            searchResultsInst.PRM_Country_Cd__c=billingCountryForCallout;
        }
        else{
            if(regRequest.PRM_Country__c!=null && regRequest.PRM_Country__c!='' && regRequest.PRM_Country__c!=' '){
                searchResultsInst.PRM_Country_Cd__c=regRequest.PRM_Country__c.substring(0,2);  
            }else{
                searchResultsInst.PRM_Country_Cd__c=regRequest.PRM_Country__c;
            }
        }
        /*if (phyAddrUsageDet!=null && phyAddrUsageDet.PhysicalStreetAddressTxt!=null){
searchResultsInst.PRM_AddressLine1_Txt__c = phyAddrUsageDet.PhysicalStreetAddressTxt;}
if (phyAddrUsageDet!=null && phyAddrUsageDet.CityNm!=null){searchResultsInst.PRM_City_Nm__c = phyAddrUsageDet.CityNm;}

if (phyAddrUsageDet!=null && phyAddrUsageDet.CountryNm!=null){searchResultsInst.PRM_Country_Nm__c = phyAddrUsageDet.CountryNm;}
if (phyAddrUsageDet!=null && phyAddrUsageDet.PostalCd!=null){searchResultsInst.PRM_Postal_Cd__c = phyAddrUsageDet.PostalCd;}
if (phyAddrUsageDet!=null && phyAddrUsageDet.CountrySubdivisionCd!=null){searchResultsInst.PRM_Subdiv_Cd__c = phyAddrUsageDet.CountrySubdivisionCd;}
if (phyAddrUsageDet!=null && phyAddrUsageDet.CountrySubdivisionNm!=null){searchResultsInst.PRM_Subdiv_Nm__c = phyAddrUsageDet.CountrySubdivisionNm;}*/
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
    
}