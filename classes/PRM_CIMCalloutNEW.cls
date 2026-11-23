/*********************************************************************************************************************
Apex Class Name  : PRM_CIMCalloutNEW
Version       : 1.0
Created Date  : jan 2022
Function      : Utility to be called from PRM_CIMAccountSearch to make a CIM Callout to get Accounts an sort them

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Sathya                   Jan 2022             Rest API class to get exisitng Accounts from both SFDC and CIM
*********************************************************************************************************************/
public without sharing class PRM_CIMCalloutNEW
{
   /* public map<string,integer> scoreMap=new map<string,integer>();
    public map<Account,list<PartnerRoleInfo>> accountPCRMap=new map<Account,list<PartnerRoleInfo>>();
    public list<PRM_SearchAccountsNew> AllAccounts=new list<PRM_SearchAccountsNew>();
    PRM_CIM_Request__mdt cimMdt ;
    integer recordLimit=20; 
                
    map <string,List<PRM_SearchAccountsNew.AccountLegalAgreement>> AccLegalAgreeMap=new map <string,List<PRM_SearchAccountsNew.AccountLegalAgreement>>();
   
            
    
/***********************************************************************************************************************
        Method:    getCimResults        
        Return:    PRM_SBCSearchResults
        Purpose:   construct CIM request and feed the repsonse to Sorting 
        
************************************************************************************************************************/  

   public /*PRM_SBCSearchResults*/void getCimResults(String accName,Address accAdr,String rcdLimit,integer searchScore,String companyWebsite,set<id> accountsSfdc,String regEmail,PRM_CIM_Request__mdt cimMdt2)
    {
    }
      /*   DateTime reqTime = System.now();
        PRM_CIMCalloutNEW.RequestDetails requestDetail = new PRM_CIMCalloutNEW.RequestDetails();        
        PRM_CIMCalloutNEW.PhysicalAddress physicalAdd = new PRM_CIMCalloutNEW.PhysicalAddress();
        PRM_CIMCalloutNEW.BusinessOrganization busOrg = new PRM_CIMCalloutNEW.BusinessOrganization();
        list<PRM_CIMCalloutNEW.ElectronicAddress> elecAddrList= new list<PRM_CIMCalloutNEW.ElectronicAddress>();
        set<Id> sfdcAccountIds=new set<Id>();
        list<PRM_SearchAccountsNew> sortedAccounts=new list<PRM_SearchAccountsNew>();
        PRM_SBCSearchResults FinalSearchResults ;
        //Fetch custom metadata which stores the  Cim score and minimun no of records to be returned 
        cimMdt = cimMdt2;
        recordLimit=integer.valueof(rcdLimit);
        
                
        
        //Construct Http Request to Send to to CIM
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setEndpoint('callout:PRM_CIM_Callout_Credentials');        
        req.setMethod('POST');
        req.setTimeout(Integer.valueOf(System.Label.PRM_Timeout));     
        
        //Forming Physical Addresses
        physicalAdd.PostalCd = accAdr.PostalCode;
        physicalAdd.CityNm = accAdr.City;
        physicalAdd.PhysicalStreetAddressTxt = accAdr.Addressline1;
        physicalAdd.Country2Cd = accAdr.CountryCode2;
        physicalAdd.CountrySubdivisionCd = accAdr.Statecode2;
           
         //Forming Account Name/BusinessOrganizationNm   
        busOrg.BusinessOrganizationNm = accName;
        busOrg.PhysicalAddress = physicalAdd;
        
        //Forming Electronic Address
        if(string.isNotBlank(companyWebsite)){
            PRM_CIMCalloutNEW.ElectronicAddress elecAddr= new PRM_CIMCalloutNEW.ElectronicAddress();
            elecAddr.ElectronicAddressTypeCd=System.Label.PRM_ELECADDR;
            elecAddr.ElectronicAddressTxt=companyWebsite;
            elecAddrList.add(elecAddr);
            busOrg.ElectronicAddress=elecAddrList;
        }
        
        requestDetail.BusinessOrganization = busOrg;       
        requestDetail.MaximumNumberOfRecordsToReturn = rcdLimit;
        requestDetail.CallingSourceSystem = cimMdt.PRM_Calling_System__c;
        requestDetail.MandatoryFieldRestrictionLevel = Integer.valueOf(cimMdt.PRM_Restriction_Level__c);
        requestDetail.MinimumSearchScore = searchScore;
        requestDetail.IncludeDefaultAttributesForSourceTypes = False;
        requestDetail.AsynchronousRequestId = cimMdt.PRM_Async_Id__c;
        
        //system.debug('---Request Details: '+requestDetail);        
        String reqBody = JSON.serialize(requestDetail);
        req.setBody(reqBody);
        //system.debug('---httpCIMRequest -->'+reqBody);
        HttpResponse response ;
           
        try{
            //Send Request to CIM
             if(Test.isRunningTest()){
                PRM_UIMockHttpResponse mockres=new PRM_UIMockHttpResponse();
                response =mockres.respond(req);
            }
            else{
            response = http.send(req);
            }
            //system.debug('---httpCIMResponse '+response.getStatusCode()+'--'+response.getBody());
            
            if(response.getStatusCode() == 200 && String.isNotBlank(response.getBody())){
                PRM_CIMWrapper respWrap = (PRM_CIMWrapper)JSON.deserialize(response.getBody(),PRM_CIMWrapper.class);
                system.debug('---After Parsing CIM Response::'+respWrap);
                if(respWrap != null && string.isblank(respWrap.ErrorDetailsTxt) && string.isblank(respWrap.ErrorCd) ){
                    //Call below method to process CIM Repsonse and get relevant Info out CIM Response
                    sfdcAccountIds=handleResponse(respWrap,accountsSfdc);
                }
            }
            //add all the Accounts fetched from email domain as well Cim results
            sfdcAccountIds.addall(accountsSfdc);
                                     
            if(sfdcAccountIds.size()>0){                
                FinalSearchResults=getRecordsforSorting(sfdcAccountIds,cimMdt);
            }      
           
        }
        catch(Exception e){
         //system.debug('---Exception in CIM Response '+e.getmessage());
        }
        finally{
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.PRM_Integration_Log__c.fields.PRM_Response_Payload__c.getLength();
            logEntryUtility.addLogEntry(response.getBody() != null ?response.getBody() :'NA',fieldLength);
             for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
               PRM_IPA_Utility.createIntegrationLog(regEmail,PRM_IPA_Constants.CALLOUT_TYPE_OUTBOUND,PRM_IPA_Constants.MODULE_SELF_REGISTRATION,reqBody,logEntryUtility.logEntryList[i],response.getStatusCode(),PRM_IPA_Constants.SYSTEM_NAME_CIM,'PRM_CIMCalloutNEW',reqTime,System.now());   
             }
         }
        return FinalSearchResults;
        
    }
    
/***********************************************************************************************************************
        Method:    handleresponse        
        Return:    set<id>
        Purpose:   Process the CIM response and get relevant info
        
************************************************************************************************************************/

   /* public set<id> handleresponse(PRM_CIMWrapper respWrap,set<id> sfdcAccountId ){
        set<string> cimsfdcId=new set<string>();set<Id> acountIds  =new set<id>(); 
        integer reswrapsize= respWrap.organization.size();     
        //null check before processing response
        if(respWrap.organization != null && respWrap.ErrorDetailsTxt == null){
            //get the SFDC ID, CIM Id and its relevant Score  
            for(Integer s=0; s<reswrapsize ; s++){
                for(integer z=0;z<respWrap.organization[s].sourceRecords.SourceRecord.size();z++){
                    if (string.isNotBlank(respWrap.organization[s].sourceRecords.SourceRecord[z].SourceBusinessOrganization.BusinessOrganizationPartyId )){
                        cimsfdcId.add(respWrap.organization[s].sourceRecords.SourceRecord[z].SourceBusinessOrganization.BusinessOrganizationPartyId); 
                        scoreMap.put(respWrap.organization[s].sourceRecords.SourceRecord[z].SourceBusinessOrganization.BusinessOrganizationPartyId,respWrap.organization[s].searchScore);                    
                    }
                    else{                       
                        cimsfdcId.add(respWrap.organization[s].Snapshot.BusinessOrganization.BusinessOrganizationPartyId); 
                        scoreMap.put(respWrap.organization[s].Snapshot.BusinessOrganization.BusinessOrganizationPartyId,respWrap.organization[s].searchScore);                    
                    }
                }
            }
            acountIds=getSFDCAcounts(cimsfdcId);
        }
        Return acountIds;
    }
    
    
/***********************************************************************************************************************
        Method:    getSFDCAcounts        
        Return:    set<id>
        Purpose:   get the Sfdc Account based on sfdc id as well CIM ids
        
************************************************************************************************************************/

   /* public set<id> getSFDCAcounts(set<string> sfdcCIMId){
        set<id> AccountIds=new set<Id>();
        set<string> AccountName=new set<string>();
        Id intelAccRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();        
        
        //collect System Account Name from metadata
        for(Core_Intel_System_Accounts__mdt mdt :Core_Intel_System_Accounts__mdt.getall().values()){
            AccountName.add(mdt.Account_Name__c);
        }
        for(Account acc :[select id,Core_Covered_Account__c,BillingCountryCode from Account where recordtypeid = : intelAccRT and name NOT in :AccountName and  ( id in: sfdcCIMId or Core_CIM_ID__c in :sfdcCIMId) ]){
            AccountIds.add(acc.Id);
        }
        return AccountIds;
    }
    
/***********************************************************************************************************************
        Method:    arrangeRecordsforSorting        
        Return:    list<SearchResults>
        Purpose:    get the related ACM records and badge
        
************************************************************************************************************************/
/*
    public PRM_SBCSearchResults getRecordsforSorting(set<id> sfdcAccountId,PRM_CIM_Request__mdt cimMdt2 ){
        //get the Badge and its Rank from Metadata
        Map<String,Integer> ipaBadgeMap = getIPABadgeMap();
        //assigm cim request metadata
        cimMdt = cimMdt2;
        set<id> AccountId=sfdcAccountId;
        PRM_SBCSearchResults seachresult;
        list<PRM_SearchAccountsNew>  searcAcc=new list<PRM_SearchAccountsNew>();
        map<string,PRM_SearchAccountsNew> AllAccountsMAP=new map<string,PRM_SearchAccountsNew>();
        AccLegalAgreeMap=getAccountLegalAgreements(sfdcAccountId);
        
        //Fetch ACMs associated to the Accounts
        if(sfdcAccountId!=null){
        for(PRM_AccountChannelMembership__c acm :  [select PRM_Account_Id__c,PRM_Account_Id__r.Core_User_Defined_Website__c,PRM_Account_Id__r.BillingAddress,PRM_Account_Id__r.BillingStreet,PRM_Account_Id__r.BillingCountryCode,PRM_Account_Id__r.BillingCity,PRM_Account_Id__r.BillingState,PRM_Account_Id__r.BillingCountry,PRM_Account_Id__r.BillingPostalCode, Name,PRM_Account_Id__r.Name,PRM_Account_Id__r.ShippingAddress,PRM_Account_Id__r.Core_Account_Legal_Name__c,PRM_Account_Id__r.Core_CIM_ID__c,PRM_Channel_Program_Id__r.name,toLabel(PRM_Partner_Role__c),PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c, PRM_Account_Id__r.Core_Covered_Account__c ,PRM_Channel_Program_Level_Id__r.name,  PRM_Status_Nm__c, PRM_Status_Change_Dt__c  from PRM_AccountChannelMembership__c where PRM_Account_Id__c  in :sfdcAccountId
                                                    //and PRM_Status_Nm__c !='Inactive']){ //ApexGuru - TWC729-7584
                and PRM_Status_Nm__c in ('Pending','Approved')]){
           if( acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance ){
                if(AllAccountsMAP.containskey(acm.PRM_Account_Id__c)){                    
                    PRM_SearchAccountsNew accWrap=AllAccountsMAP.get(string.valueof(acm.PRM_Account_Id__c));
                    accWrap.partnerrolesinfo.add(createPartnerRolInfo(acm));
                    if( string.IsNotBlank(acm.PRM_Channel_Program_Level_Id__r.name) && ipaBadgeMap.get(acm.PRM_Channel_Program_Level_Id__r.name) < ipaBadgeMap.get(accWrap.ipabadge))
                        accWrap.ipabadge=acm.PRM_Channel_Program_Level_Id__r.name;
                }
                else{
                    //get score value of each Account
                    integer scoreval=getScore (acm.PRM_Account_Id__c,acm.PRM_Account_Id__r.Core_CIM_ID__c);
                    //get IPAcheck Rank
                    integer ipacheckrank=ipaCheck(acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,acm.PRM_Account_Id__r.Core_Covered_Account__c);
                    //Remove ACoount Ids with ACM to get hold of Account Ids without ACM
                    AccountId.remove(acm.PRM_Account_Id__c);
                    
                    //create wrapper instance          
                    list<PRM_SearchAccountsNew.PartnerRoleInfo> roleInfo=new list<PRM_SearchAccountsNew.PartnerRoleInfo>();
                    roleInfo.add(new PRM_SearchAccountsNew.PartnerRoleInfo(acm.PRM_Partner_Role__c, acm.PRM_Channel_Program_Level_Id__r.name, acm.PRM_Status_Nm__c,acm.PRM_Status_Change_Dt__c));
                    PRM_SearchAccountsNew AccountWACM=new PRM_SearchAccountsNew(acm.PRM_Account_Id__c,acm.PRM_Account_Id__r.Core_CIM_ID__c,acm.PRM_Account_Id__r,scoreval,acm.PRM_Channel_Program_Level_Id__r.name,0,ipacheckrank,roleInfo);
                    AllAccountsMAP.put(string.valueof(acm.PRM_Account_Id__c),AccountWACM);                    
                    
                }
            }            
        }
        }
        
        //Create instance of PRM_SearchAccountsNew  for the Accounts without ACM
        AllAccountsMAP.putall(AddAccountsWOACM(AccountId));
        if(AllAccountsMAP.size()>0)
        {        
            AllAccounts=AllAccountsMAP.values();
            //system.debug('---AllAccounts '+AllAccounts);
        }
        
        //Apply the sorting
        if(AllAccounts.size()>0)
        searcAcc=doSorting();
        
        //Create final wrapper list
        if(searcAcc.size()>0)
        seachresult=prepareFinalList(searcAcc);
        //system.debug('---seachresult '+seachresult);
        
        return seachresult;
    }
    
/***********************************************************************************************************************
        Method:    getScore        
        Return:    integer
        Purpose:   to get the score based on sfdc id/cim id
        
************************************************************************************************************************/
/*
    public integer getScore(string accid,string cimid){
        integer score;
        if(scoreMap.containskey(accid) && scoreMap.get(accid)!=null ){
            score=scoreMap.get(accid);
        }
        else if(scoreMap.containskey(cimid) && scoreMap.get(cimid)!=null ){
            score=scoreMap.get(cimid);
        }
        return score; 
    }                 
    
/***********************************************************************************************************************
        Method:    createPartnerRolInfo        
        Return:    PartnerRoleInfo 
        Purpose:   create PartnerRoleInfo
        
************************************************************************************************************************/
/*
    public PRM_SearchAccountsNew.PartnerRoleInfo  createPartnerRolInfo(PRM_AccountChannelMembership__c acm){
        PRM_SearchAccountsNew.PartnerRoleInfo roleInfo;
        if(acm!=null)
        roleInfo =new PRM_SearchAccountsNew.PartnerRoleInfo(acm.PRM_Partner_Role__c, acm.PRM_Channel_Program_Level_Id__r.name, acm.PRM_Status_Nm__c,acm.PRM_Status_Change_Dt__c);
        return roleInfo; 
    }
    
    
/***********************************************************************************************************************
        Method:    AddAccountsWOACM        
        Return:    Map<String, PRM_SearchAccountsNew>
        Purpose:   Add PRM_SearchAccountsNew  for the Accounts without ACM
        
************************************************************************************************************************/
/*
    public Map<String, PRM_SearchAccountsNew>   AddAccountsWOACM(set<id> sfdcId){
         Map<String, PRM_SearchAccountsNew> accmap=new  Map<String, PRM_SearchAccountsNew>();
         
        for(Account acc :[select id,Name,Core_User_Defined_Website__c,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_CIM_ID__c,BillingAddress,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalcode,Core_Covered_Account__c,BillingCountryCode from Account where id in: sfdcId ]){
           //get the score 
           integer scoreval=getScore (acc.Id,acc.Core_CIM_ID__c);
           //get IPAcheck Rank
           integer ipacheckrank=ipaCheck(acc.Core_Intel_Partner_Alliance_PartnerGroup__c,acc.Core_Covered_Account__c);
          
           PRM_SearchAccountsNew accWrap=new PRM_SearchAccountsNew(acc.Id,acc.Core_CIM_ID__c,acc,scoreval,null,0,ipacheckrank,null);
           accmap.put(string.valueof(acc.Id),accWrap);
        }
        return accmap; 
    } 
                    
      
/***********************************************************************************************************************
        Method:    doSorting        
        Return:    list<PRM_SearchAccountsNew>
        Purpose:   Sorting the Accounts-IPA (Covered- Uncovered) ,NonIPA (Covered- Uncovered), Email (Covered- Uncovered)
        
************************************************************************************************************************/
/*
    public list<PRM_SearchAccountsNew> doSorting(){
        list<PRM_SearchAccountsNew> sortedAccountResults=new list<PRM_SearchAccountsNew>();
        Integer targetcount=1;
            /*
            count = 0,
            totalrecords=AllAccounts.size(),
            maxrecord=integer.valueof(cimMdt.PRM_Max_Records__c);*/
            
        //system.debug('---totalrecords '+totalrecords+'--'+maxrecord);
        
        //while ((count <=totalrecords ) || (targetcount > =maxrecord)) 
 /*       
        for(PRM_SearchAccountsNew acc :AllAccounts){         
            /*acc.acc.Name+=acc.IPARank==1 ?'<==> IPA Covered ':acc.IPARank==2 ?     '<==> IPA uncovered ':acc.IPARank==3?' <==> NON IPA Covered ':acc.IPARank==4?' <==> NON IPA UnCovered ':null;
            acc.acc.Name+=acc.searchScore;*/
            
   /*         //Check if it has Score
            if(acc.searchscore!=null){
                //Check if score is above Score Bar
                if(acc.searchscore >=cimMdt.Score_Bar__c){
                  targetcount++;
                  acc.priority=1;
                    sortedAccountResults.add(acc);
                }
                else{
                    //Accounts below score bar 
                   if(targetLimit(targetcount))                                                         
                       acc.priority=2;
                    sortedAccountResults.add(acc);
                    targetcount++; 
                }
            }
           /* else if(targetLimit(targetcount)){
                //Accounts matched by Email Domain
               system.debug('---EmailMatch');
               acc.priority=2;
               sortedAccountResults.add(acc); targetcount++;
            }*/
/*            
            
        }
        if(sortedAccountResults.size()>0)
        sortedAccountResults.Sort();
        return sortedAccountResults;
    }
    
    
/***********************************************************************************************************************
        Method:    ipaCheck        
        Return:    integer
        Purpose:  checks if given Account is IPA Covered/ IPA Uncovered / NON IPA
        
************************************************************************************************************************/
/*
    public integer ipaCheck(boolean ipa,boolean coverflag){
        integer retval;
        if(ipa ){
            if(coverflag){
            retval=1;
            }
            else{
            retval=2;
            }
        }
        else{
            if(coverflag){
            retval=3;
            }
            else{
            retval=4;
            }
        }
        return retval;
    }
    
/***********************************************************************************************************************
        Method:    getIPABadgeMap        
        Return:    Map<String,Integer>
        Purpose:  get rank from IPA badge metadata
        
************************************************************************************************************************/
  /*
    public static Map<String,Integer> getIPABadgeMap(){
        Map<String, Integer> mapOfIPABadge = new Map<String, Integer>();
        for(String bageMapping :LabelConfiguration__mdt.getInstance('ChannelProgramLevelRanking').Value__c.split(';')){ 
            List<String> progTier = bageMapping.split(':');
            mapOfIPABadge.put(progTier[0],Integer.valueOf(progTier[1]));        
        }
        return mapOfIPABadge;
    }
    
/***********************************************************************************************************************
        Method:    prepareFinalList        
        Return:    list<SearchResults>
        Purpose:   createFinalWrapper
        
************************************************************************************************************************/
/*
    public PRM_SBCSearchResults prepareFinalList(list<PRM_SearchAccountsNew> sortedaccounts){
        list<PRM_SBCSearchResults.SearchResults> searchresList=new list<PRM_SBCSearchResults.SearchResults>();
        integer count=0;
        //get 2 digit country code
        Map<string,string> countryMap = new map<string,string>();
        for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
            countryMap.put(allCountries.ISO_Code__c,allCountries.Country_Code__c);
        }
        //system.debug('---countryMap '+countryMap);
        for(PRM_SearchAccountsNew sa: sortedaccounts){
            string country2code; 
            country2code=countryMap.containskey(sa.acc.BillingCountryCode)?countryMap.get(sa.acc.BillingCountryCode):sa.acc.BillingCountryCode;
            Address adobj=new Address(sa.acc.Billingstreet,null,sa.acc.BillingCity,country2code,sa.acc.BillingState,sa.acc.BillingPostalCode);
            List<PRM_SearchAccountsNew.AccountLegalAgreement> legalList=new List<PRM_SearchAccountsNew.AccountLegalAgreement>();
            if(AccLegalAgreeMap.containskey(sa.acc.id))
            {    
            legalList=AccLegalAgreeMap.get(sa.acc.id);
            }
            PRM_SBCSearchResults.SearchResults searchaccres=new PRM_SBCSearchResults.SearchResults(sa.acc.Name, adobj, legalList, sa.partnerrolesinfo, string.valueof(sa.AccountId), sa.acc.Core_CIM_ID__c, sa.ipabadge,sa.acc.Core_User_Defined_Website__c);
            searchresList.add(searchaccres);
            count++;
            //get out of loop Once reached max records
            if(count==integer.valueof(cimMdt.PRM_Max_Records__c))
            break;
        }
        PRM_SBCSearchResults sbcsearchresult=new PRM_SBCSearchResults();
        sbcsearchresult.SearchResults=searchresList;
        return sbcsearchresult;
    }
    
      
/***********************************************************************************************************************
        Method:    getAccountLegalAgreements        
        Return:    List<PRM_SearchAccountsNew.AccountLegalAgreement>
        Purpose:   createFinalWrapper
        
************************************************************************************************************************/
/*
    public static map <string,List<PRM_SearchAccountsNew.AccountLegalAgreement>> getAccountLegalAgreements(set<id> acctid){        
        map <string,List<PRM_SearchAccountsNew.AccountLegalAgreement>> Legalagreementmap=new map <string,List<PRM_SearchAccountsNew.AccountLegalAgreement>>();
        for(PRM_AccountLegalAgreemntAssociation__c agreement : [SELECT Name,PRM_Account_Id__c,PRM_Agreement_Sign_Dt__c,PRM_InActive_Ind__c,PRM_Contact__r.Name,PRM_Partner_Agreement_Id__r.Name,PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name FROM PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c in:acctid]){
            if(agreement.PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name=='Intel Partner Alliance' && agreement.PRM_InActive_Ind__c==false){
                if(Legalagreementmap.containskey(agreement.PRM_Account_Id__c)){
                    list< PRM_SearchAccountsNew.AccountLegalAgreement> legalAgreelist=Legalagreementmap.get(agreement.PRM_Account_Id__c);
                    PRM_SearchAccountsNew.AccountLegalAgreement legalAgreement = new PRM_SearchAccountsNew.AccountLegalAgreement(agreement.PRM_Agreement_Sign_Dt__c);             
                    legalAgreelist.add(legalAgreement);  
                }
                else{
                    list< PRM_SearchAccountsNew.AccountLegalAgreement> legalAgreelist=new list< PRM_SearchAccountsNew.AccountLegalAgreement>();                
                    PRM_SearchAccountsNew.AccountLegalAgreement legalAgreement = new PRM_SearchAccountsNew.AccountLegalAgreement(agreement.PRM_Agreement_Sign_Dt__c);             
                    legalAgreelist.add(legalAgreement);
                    Legalagreementmap.put(agreement.PRM_Account_Id__c,legalAgreelist);  
                }
            }
        }
        return Legalagreementmap;
    }
    
  
   
    
/***********************************************************************************************************************
        Method:    targetLimit        
        Return:    integer
        Purpose:  check if final list has reached target limit
        
************************************************************************************************************************/
/*
    public boolean targetLimit(integer currentsize ){
        boolean notyet;
        notyet=currentsize <integer.valueof(cimMdt.PRM_Max_Records__c)?true:false;
        return  notyet;
    }
    
    
/******************Wrapper Classes for CIM Input Request Starts ****************************************************************/
 /*   public class RequestDetails{
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
   
    // Wrapper class for electronic address
    public class ElectronicAddress{
        public string ElectronicAddressTypeCd;
        public string ElectronicAddressTxt;
    }
/******************Wrapper Classes for CIM Input Request Ends ****************************************************************/    
   
}