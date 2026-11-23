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
    public static boolean autoapproval = false;
    
    public ER_DupCheck_CIMCallout(PRM_Registration_Request__c regRequest,Integer countReattempt,String rcdLimit,String searchScore,String companyWebsite, Boolean cimCall)
    {
        this.regRequest = regRequest;
        this.countReattempt = countReattempt;
        this.rcdLimit = rcdLimit;
        this.searchScore= searchScore;
        this.companyWebsite = companyWebsite;
        this.cimCall = cimCall;
        System.debug('@@ cimCall'+cimCall);
        system.debug('@@Constructor req request::'+this.regRequest);
        regEmail=regRequest.PRM_Email_ID__c;
        system.debug('accountsSize -->' + acctCont);
        system.debug('rcdLimit -->' + rcdLimit); 
        if (regRequest.PRM_Salesforce_ID__c!=null){
            reqAcctId = regRequest.PRM_Salesforce_ID__c;
        }    
    }
public void execute(QueueableContext currentContext) {
    System.debug('@@ EXECUTE STARTED for: ' + regRequest.Id);

    try {
        // Step 1: Re-fetch the registration record
        PRM_Registration_Request__c regRequestUpdate = [
            SELECT Id,
                   PRM_Account_Name__c,
                   PRM_Email_ID__c,
                   PRM_First_Name__c,
                   PRM_Last_Name__c,
                   PRM_Country__c,
                   PRM_State_Province__c,
                   PRM_Account_URL__c,
                   PRM_Salesforce_ID__c,
                   PRM_Dup_Status__c,
                   PRM_DeDup_Criteria__c,
                   PRM_CIMStatusDetails__c
            FROM PRM_Registration_Request__c
            WHERE Id = :regRequest.Id
            LIMIT 1
        ];

        // Step 2: Short-circuit if matched with SF ID
        if (regRequestUpdate.PRM_Salesforce_ID__c != null) {
            regRequestUpdate.PRM_Dup_Status__c = System.Label.PRM_Fulldup;
            regRequestUpdate.PRM_DeDup_Criteria__c = System.Label.PRM_Fail;
            regRequestUpdate.PRM_CIMStatusDetails__c = 'Matched by Salesforce ID';
            update regRequestUpdate;
            System.debug(' Matched by Salesforce ID, skipping RELTO.');
            return;
        }

        // Step 3: Validate required fields
        if (String.isBlank(regRequestUpdate.PRM_Account_Name__c) ||
            String.isBlank(regRequestUpdate.PRM_Email_ID__c) ||
            String.isBlank(regRequestUpdate.PRM_Last_Name__c)) {
            
            regRequestUpdate.PRM_Dup_Status__c = System.Label.PRM_Error;
            regRequestUpdate.PRM_DeDup_Criteria__c = System.Label.PRM_Fail;
            regRequestUpdate.PRM_CIMStatusDetails__c = 'Missing required fields';
            update regRequestUpdate;
            System.debug(' Missing required fields. Skipping duplicate check.');
            return;
        }

        // Step 4: Get country/state wrapper
        PRM_AdminRegistrationDuplicateDetails.CountryStateWrapperForSBR csWrp =
            PRM_AdminRegistrationDuplicateDetails.getCountryOrStateForSBR(
                regRequestUpdate.PRM_Country__c,
                regRequestUpdate.PRM_State_Province__c
            );

        // Step 5: Build fieldset for RELTO
        List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fDetailsList =
            PRM_AdminRegistrationDuplicateDetails.createFDetailsList(
                regRequestUpdate.PRM_Account_Name__c,
                csWrp.country,
                csWrp.state,
                regRequestUpdate.PRM_Account_URL__c
            );

        // Step 6: Call UCD/RELTO API
        UCD_GenericAcctSearch_SBR.AccountSearchDataModelWithError accFinalDetails =
            UCD_GenericAcctSearch_SBR.getAcctResults(fDetailsList, '');

        List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel> accDetails =
            accFinalDetails.accountSearchModel;

        // Step 7: Evaluate RELTO result
        if (accDetails == null || accDetails.isEmpty()) {
            regRequestUpdate.PRM_Dup_Status__c = System.Label.PRM_Nodup;
            regRequestUpdate.PRM_DeDup_Criteria__c = System.Label.PRM_Success;
            regRequestUpdate.PRM_CIMStatusDetails__c = 'No duplicates found.';
            System.debug(' No duplicates found.');
        } else {
            regRequestUpdate.PRM_Dup_Status__c = System.Label.PRM_Fulldup;
            regRequestUpdate.PRM_DeDup_Criteria__c = System.Label.PRM_Fail;
            regRequestUpdate.PRM_CIMStatusDetails__c = accDetails.size() + ' potential duplicate(s) found.';
            System.debug(' Duplicates found: ' + accDetails.size());
        }

        update regRequestUpdate;
        System.debug(' Record updated: ' + regRequestUpdate.Id);

    } catch (Exception e) {
        System.debug(' Exception during duplicate check: ' + e.getMessage());

        PRM_Registration_Request__c errorReg = new PRM_Registration_Request__c(
            Id = regRequest.Id,
            PRM_Dup_Status__c = System.Label.PRM_Error,
            PRM_DeDup_Criteria__c = System.Label.PRM_Fail,
            PRM_CIMStatusDetails__c = 'Exception: ' + e.getMessage()
        );
        update errorReg;
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
            system.debug('@@ Inside main if');
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
            system.debug('validSfidSet -- > '+validSfidSet);
            system.debug('validCimSet---> '+validCimSet);
            for(Account a : [Select Id,Name,Core_CIM_ID__c from Account where RecordTypeId =:intelaccountRT and (Core_CIM_ID__c IN: validCimSet or id in:validSfidSet)]){
                validCimAccountMap.put(String.valueof(a.Id),a.Core_CIM_ID__c);
            }
            
            system.debug('MAP VALUES --> '+validCimAccountMap);
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
                        system.debug('Search Score '+respWrap.organization[i].sourceRecords.SourceRecord[j].SourceSystemCd);
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
                            system.debug('CIM ID----> '+respWrap.organization[i].Snapshot.BusinessOrganization.BusinessOrganizationPartyId);
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
                        //system.debug('FOUND VALUES--> ' +usgDet.AddressUsageTypeCd+' '+usgDet.AddressLocationTypeCd) ;
                    }
                }}
            if(usgCimMap != null && !usgCimMap.isEmpty()){
                for (list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation> usgDetList : usgCimMap.keyset()){
                    for (PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation usgDet: usgDetList){                        
                        if (usgDet.AddressUsageTypeCd == System.Label.PRM_ADDRUSGTYPE && usgDet.AddressLocationTypeCd== System.Label.PRM_ADDRLOCTYPE){
                            map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>  usgPhyAddrDetUsg = new map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>(); 
                            usgPhyAddrDetUsg=cimUsagePhyMap.get(usgCimMap.get(usgDetList));
                            system.debug('PHY VALUES--> ' +usgPhyAddrDetUsg.get(usgDetList));
                            cimPhysicalAddrUsageMap.put(usgCimMap.get(usgDetList),usgPhyAddrDetUsg.get(usgDetList));
                            cimPhysicalAddrLocType.put(usgCimMap.get(usgDetList),System.Label.PRM_ADDRUSGTYPE+','+System.Label.PRM_ADDRLOCTYPE);
                            break;
                        }
                        else if (usgDet.AddressUsageTypeCd == System.Label.PRM_ADDRUSGTYPE_MAIL && usgDet.AddressLocationTypeCd== System.Label.PRM_ADDRLOCTYPE){
                            map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>  usgPhyAddrDetUsg = new map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>(); 
                            usgPhyAddrDetUsg=cimUsagePhyMap.get(usgCimMap.get(usgDetList));
                            system.debug('MAIL VALUES--> ' +usgPhyAddrDetUsg.get(usgDetList));
                            cimPhysicalAddrUsageMap.put(usgCimMap.get(usgDetList),usgPhyAddrDetUsg.get(usgDetList));
                            cimPhysicalAddrLocType.put(usgCimMap.get(usgDetList),System.Label.PRM_ADDRUSGTYPE_MAIL+','+System.Label.PRM_ADDRLOCTYPE);
                        }
                        else if (!cimPhysicalAddrUsageMap.containsKey(usgCimMap.get(usgDetList))){
                            map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>  usgPhyAddrDetUsg = new map<list<PRM_CIMWrapper.PhysicalAddressUsageLocationAssociation>,PRM_CIMWrapper.PhysicalAddress>(); 
                            usgPhyAddrDetUsg=cimUsagePhyMap.get(usgCimMap.get(usgDetList));
                            system.debug('OTHR VALUES--> ' +usgPhyAddrDetUsg.get(usgDetList));
                            cimPhysicalAddrUsageMap.put(usgCimMap.get(usgDetList),usgPhyAddrDetUsg.get(usgDetList));
                            cimPhysicalAddrLocType.put(usgCimMap.get(usgDetList),usgDet.AddressUsageTypeCd+','+usgDet.AddressLocationTypeCd);
                        }
                        
                    }
                }}
            system.debug('cimSourceRecordsMap '+cimSourceRecordsMap.size());
            system.debug('cimSourceRecordsMapVAL '+cimSourceRecordsMap);
            system.debug('cimSearchScoreMapVAL '+cimSearchScoreMap);
            system.debug('maxval  '+ maxval);
            if(maxVal < Integer.valueOf(cimMdt.PRM_Min_Score__c)){
                updateReg[0].PRM_Dup_Status__c = System.Label.PRM_Nodup;
                updateReg[0].PRM_DeDup_Criteria__c = System.Label.PRM_Success;
                system.debug('dupcheck- nodup-'+updateReg[0].PRM_Dup_Status__c);
            }
            //else if(maxVal >= Integer.valueOf(cimMdt.PRM_Min_Score__c) && maxVal < Integer.valueOf(cimMdt.PRM_Max_Score__c) && (acctConts==null || acctConts.size()==0)){
            else if(maxVal >= Integer.valueOf(cimMdt.PRM_Min_Score__c) && maxVal < Integer.valueOf(cimMdt.PRM_Max_Score__c)){
                updateReg[0].PRM_Dup_Status__c = System.Label.PRM_Partdup;
                updateReg[0].PRM_DeDup_Criteria__c = System.Label.PRM_Fail;
                system.debug('dupcheck- Partdup-'+updateReg[0].PRM_Dup_Status__c);
                
            }
            else{
                updateReg[0].PRM_Dup_Status__c = System.Label.PRM_Fulldup;
                updateReg[0].PRM_DeDup_Criteria__c = System.Label.PRM_Fail;
                system.debug('dupcheck- fulldup-'+updateReg[0].PRM_Dup_Status__c);
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
            system.debug('@@ Inside else if');
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
            system.debug('@@ Update Record: '+updateReg);
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
        
        System.debug('cimDataWrap >> '+cimDataWrap);
        System.debug('cimSearchScoreMap >>> '+cimSearchScoreMap);
        try{
            //system.debug('Inside method Search Results');
            for (PRM_CIMWrapper.SourceRecord sourceRecord : cimSourceRecordsMap.keySet()){
                PRM_CIMSearchResults__c searchResults = new PRM_CIMSearchResults__c();
                PRM_CIMWrapper.organization orgValue = new PRM_CIMWrapper.organization();
                //list<PRM_CIMWrapper.PhysicalAddress> physicaladdrs = new list<PRM_CIMWrapper.PhysicalAddress>();
                //orgValue = organizationKey;
                string cimId = cimSourceRecordsMap.get(sourceRecord);
                system.debug('insertCimSearchResults CIM ID--> '+cimId);
                orgValue = cimOrganizationMap.get(cimId);
                integer searchScore = cimSearchScoreMap.get(cimId);
                //physicaladdrs = cimPhysicalAddrsMap.get(cimId);
                system.debug('insertCimSearchResults searchScore--> '+searchScore);
                //PRM_CIMWrapper.SourceRecord sourceRecord = new PRM_CIMWrapper.SourceRecord();
                //sourceRecord = organizationSourceMap.get(organizationKey);
                system.debug('Inside method Search Results');
                System.debug('System.Label.PRM_Fulldup >>> '+System.Label.PRM_Fulldup);
                System.debug('cimMdt.PRM_Max_Score__c >>> '+cimMdt.PRM_Max_Score__c);
                System.debug('dupStatus >>> '+dupStatus);
                System.debug('searchScore >>> '+searchScore);
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
                system.debug('Inside insertCIMResults');
                searchResultsList.add(searchResults);
            }
            system.debug('searchResultsList '+searchResultsList.size());
            system.debug('searchResultsList '+searchResultsList);
            
            Database.SaveResult[] insertReslt = Database.insert(searchResultsList,false);
            for (Database.SaveResult sr : insertReslt) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted records ID:-> ' + sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error while inserting records');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that caused this error: ' + err.getFields());
                    }
                }
            }
            integer countAcc = 0;
            for(PRM_CIMSearchResults__c searchResults : searchResultsList)
                
            {
                
                System.debug('Account Id: ' + searchResults.PRM_Account_Id__c);
                System.debug('searchResults Id: ' + searchResults.id);
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
            system.debug('Error Insert CIM Results :: '+errCimResults.getMessage());
            PRM_ErrorUtilityClass.logError(errCimResults);
        }
    }
    
    // Instantiating the CIM Search Results Object
    private PRM_CIMSearchResults__c instantiateCimSearchResultsObj(ER_SearchCIMAccounts.ER_cimInstWrap cimInstWrap){
        PRM_CIMSearchResults__c searchResultsInst = new PRM_CIMSearchResults__c();
        system.debug('regReqId '+ cimInstWrap.regReqId);
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
            system.debug('PHY ADDR -->'+phyAddrUsageDet);
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