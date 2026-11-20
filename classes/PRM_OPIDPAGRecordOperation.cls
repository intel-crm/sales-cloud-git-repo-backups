/**************************************************************************************************************
Apex Class Name:  PRM_OPIDPAGRecordOperation
Version     : 1.0 
Created Date: 28 May 2020
Function    : This class used for updating the PAGRecord based on ACM,PPSegment and PPSpeciality of each child Salesforce Account
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Prasant Sahu         05/28/2020        Initial version
* Srishty Sharma       10/23/2020        US821813:OPID upgrade recommendation record removal from recommendation table - detachment of location account from OPID. 
***************************************************************************************************************/
public without sharing class PRM_OPIDPAGRecordOperation {
    List<Core_OnePartner_Inbound_Message__c> updatedList = new List<Core_OnePartner_Inbound_Message__c>();
    Map<String,String> pagAccountMapError = new Map<String,String>();
    Map<String,String> pagAccountIDDetails = new Map<String,String>();
    Map<String,String> asaMapError = new Map<String,String>();
    Map<String,String> aiaMapError = new Map<String,String>();
    Map<String,String> acmMapError = new Map<String,String>();
    Map<String,String> cagMapError = new Map<String,String>();
    Map<String,String> abaMapError = new Map<String,String>();
    // added as part of TWC729-5300
    //public static boolean ipaRefresh=Boolean.valueOf(label.PRM_IPARefresh); //IPA2.0-TWC727-2861 // IPA Switch Removal
    Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId(); //OPID Recommendation //TWC729-6800 EOL activities
    Map<Id, PRM_Tracker__c> listOfAvailableMilestoneRecords = new Map<Id, PRM_Tracker__c>();
    List<PRM_Tracker__c> tList=new List<PRM_Tracker__c>();

    List<PRM_AccountChannelMembership__c> listOfInactiveACM = new List<PRM_AccountChannelMembership__c>();
    List<PRM_AccountChannelMembership__c> acmsToUpdate = new List<PRM_AccountChannelMembership__c>();
    List<PRM_AccountChannelMembership__c> updatedListACM = new List<PRM_AccountChannelMembership__c>();
    List<PRM_AccountBenefitAssociation__c> updatedBenfits = new List<PRM_AccountBenefitAssociation__c>();
    List<Account> listOfAccountsToUpdate = new List<Account>();
    List<PRM_Account_Specialty_Association__c> listOfObjectToUpdate = new List<PRM_Account_Specialty_Association__c>();
    List<PRM_IPA_Affiliation__c> listOfAIAToUpdate = new List<PRM_IPA_Affiliation__c>();// AIA 
    Map<String,Core_OnePartner_Inbound_Message__c> opidAcc = new Map<String,Core_OnePartner_Inbound_Message__c>();
    Map<Id, List<Account>> mapOfParentIdAccounts = new Map<Id, List<Account>>();
    Map<Id, List<Core_Account_Group_Member__c>> mapOfParentIdCAGs = new Map<Id, List<Core_Account_Group_Member__c>>();
    Map<String, List<PRM_Account_Specialty_Association__c>> mapOfParentIdASAs = new Map<String, List<PRM_Account_Specialty_Association__c>>();
    Map<Id,Id> mapOfChildParent = new Map<Id, Id>();
    
    //public static boolean iparefresh = boolean.valueOf(Label.PRM_IPARefresh);
    
    public PRM_OPIDPAGRecordOperation(List<Core_OnePartner_Inbound_Message__c> updatedList,Map<String,String> pagAccountMapError,Map<String,String> pagAccountIDDetails,Map<String,String> asaMapError,Map<String,String> acmMapError,Map<String,String> cagMapError,Map<String,String> aiaMapError){
        this.updatedList = updatedList;
        this.pagAccountMapError = pagAccountMapError;
        this.pagAccountIDDetails = pagAccountIDDetails;
        this.asaMapError = asaMapError;
        this.acmMapError = acmMapError;
        this.cagMapError = cagMapError;
        this.aiaMapError = aiaMapError;
    }
    
    public PRM_OPIDPAGRecordOperation(){
        
    }
    public PRM_OPIDPAGRecordOperation(List<Core_OnePartner_Inbound_Message__c> updatedList){
        this.updatedList = updatedList;
    }
    
    public PRM_OPIDErrorWrapper rollUpAccounts(List<Account> accounts, List<String> logEntryMsgList,List<Core_Account_Group_Member__c> listOfCAG){
        //TWC729-4717 - getting instance of metadata
        Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('PRM_Tracker_steps__mdt');
        Map<String,Object> memUpdateMdt = customMetadata.getInstance('MEM_UPDATED');
        List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
        //TWC729-4717 - initializing acm List for successful and unsuccessful upsert 
        map<Id, PRM_AccountChannelMembership__c> acmMapAfterUpsert = new  map<Id, PRM_AccountChannelMembership__c>();
        list<PRM_Value_Exchange_Recommendation__c> opidRecList = new list<PRM_Value_Exchange_Recommendation__c>();//TWC729-6800 EOL activities
        set<Id> acmIdSet = new set<Id>();
        set<Id> opidAccIdSet = new set<Id>();
        set<Id> opidRecIds = new set<Id>();
        
        String logEntryMsg='';
        logEntryMsg+='\n*****RollUpAccounts Method Starts here...*******';      
        PRM_OPIDErrorWrapper errorWrapper = new PRM_OPIDErrorWrapper();
        Set<Id> childAccIds = new Set<Id>();
        if(accounts != null){
            Map<id,List<id>> mapOfParentandChildAcc = new Map<id,list<id>>();    
            Set<Id> setOfAccountID = new Set<Id>();
            for(Account acc : accounts){
                setOfAccountID.add(acc.id);
            }
            //List<Core_Account_Group_Member__c> listOfCAG = [SELECT Core_Partner_Account_Id__c,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,  Core_Partner_Account_Id__r.Core_OnePartnerID__c, Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c,  Core_Partner_Account_Id__r.Core_Account_Type__c,Core_Intel_Account_Id__r.Core_OnePartnerID__c, Core_Intel_Account_Id__r.Core_IPA_Partner_Segment__c,  Core_Intel_Account_Id__r.Core_Account_Type__c FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c in :setOfAccountID and Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true and Core_Inactive_Ind__c = false WITH SECURITY_ENFORCED]; 
            logEntryMsg+='\n*** CAGs found for rollup/rolldown:\n'+listOfCAG+'***';//DE101897:Added by Srishty
            if(listOfCAG != null){
            for(Core_Account_Group_Member__c cagObj : listOfCAG){
                List<Account> accList;
                List<Core_Account_Group_Member__c> cags;
                    List<id> childAcc = mapOfParentandChildAcc.get(cagObj.Core_Partner_Account_Id__c);
                    childAccIds.add(cagObj.Core_Intel_Account_Id__c);
                    mapOfChildParent.put(cagObj.Core_Intel_Account_Id__c, cagObj.Core_Partner_Account_Id__c);
                    if(childAcc != null){
                        childAcc.add(cagObj.Core_Intel_Account_Id__c);
                    }else{
                        childAcc = new List<id>();
                        childAcc.add(cagObj.Core_Intel_Account_Id__c);
                        mapOfParentandChildAcc.put(cagObj.Core_Partner_Account_Id__c, childAcc); 
                    }
                    
                    if(mapOfParentIdCAGs.containsKey(cagObj.Core_Partner_Account_Id__c)){
                        mapOfParentIdCAGs.get(cagObj.Core_Partner_Account_Id__c).add(cagObj);
                    }else{
                        cags = new List<Core_Account_Group_Member__c>();
                        cags.add(cagObj);
                        mapOfParentIdCAGs.put(cagObj.Core_Partner_Account_Id__c, cags);
                    }
                    
                    if(!mapOfParentIdAccounts.containsKey(cagObj.Core_Partner_Account_Id__c)){
                        Account parentAcc = new Account();          
                        parentAcc.Id = cagObj.Core_Partner_Account_Id__c;
                        parentAcc.Core_OnePartnerID__c = cagObj.Core_Partner_Account_Id__r.Core_OnePartnerID__c;
                        //if(!iparefresh)parentAcc.Core_IPA_Partner_Segment__c = cagObj.Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c; // IPA Switch Removal
                        parentAcc.Core_Account_Type__c = cagObj.Core_Partner_Account_Id__r.Core_Account_Type__c;
                        accList = new List<Account>();
                        accList.add(parentAcc);
                        mapOfParentIdAccounts.put(cagObj.Core_Partner_Account_Id__c, accList);
                    }
                    
                    Account childAccount = new Account();          
                    childAccount.Id = cagObj.Core_Intel_Account_Id__c;
                    childAccount.Core_OnePartnerID__c = cagObj.Core_Intel_Account_Id__r.Core_OnePartnerID__c;
                    // if(!iparefresh)childAccount.Core_IPA_Partner_Segment__c = cagObj.Core_Intel_Account_Id__r.Core_IPA_Partner_Segment__c; // IPA Switch Removal
                    childAccount.Core_Account_Type__c = cagObj.Core_Intel_Account_Id__r.Core_Account_Type__c;            
                    mapOfParentIdAccounts.get(cagObj.Core_Partner_Account_Id__c).add(childAccount);          
                    
                }
            }
            
            Map<Id, List<PRM_AccountChannelMembership__c>> mapOfParentAcm = new Map<Id, List<PRM_AccountChannelMembership__c>>();
            Map<Id, List<PRM_AccountChannelMembership__c>> mapOfChildAcm = new Map<Id, List<PRM_AccountChannelMembership__c>>();
            List<PRM_AccountChannelMembership__c> acmList;
            for(PRM_AccountChannelMembership__c acm: [select id, PRM_Account_Id__c, PRM_Partner_Role__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c, PRM_Channel_Program_Level_Id__r.name, PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :mapOfParentandChildAcc.keyset() or PRM_Account_Id__c in :childAccIds WITH SECURITY_ENFORCED]){
                if(mapOfParentandChildAcc.containsKey(acm.PRM_Account_Id__c)) {
                    if(mapOfParentAcm.containsKey(acm.PRM_Account_Id__c)){
                        mapOfParentAcm.get(acm.PRM_Account_Id__c).add(acm);
                    }else{
                        acmList = new List<PRM_AccountChannelMembership__c>();
                        acmList.add(acm);
                        mapOfParentAcm.put(acm.PRM_Account_Id__c, acmList);
                   }
                }else{
                    string parentId = mapOfChildParent.get(acm.PRM_Account_Id__c);
                    if(mapOfChildAcm.containsKey(parentId)){
                        mapOfChildAcm.get(parentId).add(acm);
                    }else{
                        acmList = new List<PRM_AccountChannelMembership__c>();
                        acmList.add(acm);
                        mapOfChildAcm.put(parentId, acmList);
                    }          
                }
                
            }
            
            List<PRM_Account_Specialty_Association__c> asaList;
            /*if(!ipaRefresh || test.isrunningtest()){// IPA2.0-TWC727-2861
            for(PRM_Account_Specialty_Association__c asa: [select PRM_Specialty_Id__c, PRM_Account_Id__c, PRM_InActive_Ind__c,PRM_Partner_Role__c,PRM_Status_Reason_Txt__c from PRM_Account_Specialty_Association__c where (PRM_Account_Id__c in :childAccIds or  PRM_Account_Id__c in :mapOfParentandChildAcc.keyset()) and PRM_Specialty_Id__r.PRM_InActive_Ind__c = false WITH SECURITY_ENFORCED]){
                String parentId = null;
                if(mapOfParentandChildAcc.containsKey(asa.PRM_Account_Id__c)) {
                    parentId = asa.PRM_Account_Id__c;
                }else{
                    parentId = mapOfChildParent.get(asa.PRM_Account_Id__c);
                }
                
                
                if(mapOfParentIdASAs.containsKey(parentId)){
                    mapOfParentIdASAs.get(parentId).add(asa);
                }else{
                    asaList = new List<PRM_Account_Specialty_Association__c>();
                    asaList.add(asa);
                    mapOfParentIdASAs.put(parentId, asaList);
                }                                    
                
            }
            } */ // IPA Switch Removal
            
            
            if(!mapOfParentandChildAcc.isEmpty()){
                List<PRM_AccountChannelMembership__c> childAcms;
                logEntryMsg+='\n*** Rollup Process started:***';
                for(id parentID : mapOfParentandChildAcc.keySet()){
                    acmList = null;
                    acmList = mapOfParentAcm.get(parentID);
                    childAcms = mapOfChildAcm.get(parentID);
                    if(acmList != null){
                        if(childAcms != null){
                            acmList.addAll(childAcms);
                        }
                    }else if(childAcms != null){
                        acmList = childAcms;
                    }
                    
                    logEntryMsg+='\n*** OPID account for Rollup:'+ parentID+'***';
                    logEntryMsg+=rollUpOPIDAccount(parentID, mapOfParentandChildAcc.get(parentID),errorWrapper, acmList);
                }
                if(!listOfAccountsToUpdate.isEmpty()){
                    Database.UpsertResult[] parentACCErrHandle = null;
                    parentACCErrHandle = Database.upsert(listOfAccountsToUpdate,false);
                    logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(listOfAccountsToUpdate, parentACCErrHandle,'Account');
                   
                    pagAccountMapError = PRM_OPIDProcessUtility.getErrorMessageForOPID(listOfAccountsToUpdate,parentACCErrHandle);
                  
                    errorWrapper.putPAGError(pagAccountMapError);
                }
                
                Database.UpsertResult[] acmErrorHandle = null;
                //upsert updatedList;
                if(!updatedListACM.isEmpty()){
                    acmErrorHandle = Database.upsert(updatedListACM,false);
                    for(Database.UpsertResult sr : acmErrorHandle){
                        if(!sr.isSuccess()){
                            for(Database.Error err : sr.getErrors()){
                                Core_Log_Entry.logEntryWithDetails('PRM_OPIDPAGRecordOperation', 'IPA','opidOutboundMssg', 'exception','Exception occured while inserting ACM',err.getMessage() , sr.getId(), 'PRM_AccountChannelMembership__c', 'ACM');
                            }
                        }else{
                            acmIdSet.add(sr.getId());
                        }
                    }
                    for(PRM_AccountChannelMembership__c acm : updatedListACM){
                        //TWC729-4717 - updating map for sucessful upsert
                        if(acmIdSet.contains(acm.Id)){
                            acmMapAfterUpsert.put(acm.PRM_Account_Id__c , acm);

                        }
                        //TWC729-4717 - updating set for unsucessful upsert
                        opidAccIdSet.add(acm.PRM_Account_Id__c);
                    }
                    if(acmMapAfterUpsert != null && !acmMapAfterUpsert.isempty()){
                        assignBenefitsOnRollUp(acmMapAfterUpsert);
                    }
                    logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(updatedListACM, acmErrorHandle,'PRM_AccountChannelMembership__c');
                    acmMapError = PRM_OPIDProcessUtility.getErrorMessageForACMupsert(updatedListACM,acmErrorHandle);
                    errorWrapper.putACMError(acmMapError);
                }        
                Database.SaveResult[] acmUpdateErrorhandle = null;
                
                //update acmsToUpdate;
                if (!acmsToUpdate.isEmpty()){
                    acmUpdateErrorhandle = Database.update(acmsToUpdate,false);
                    for(Database.saveResult sr : acmUpdateErrorhandle){
                        if(!sr.isSuccess()){
                            for(Database.Error err : sr.getErrors()){
                                Core_Log_Entry.logEntryWithDetails('PRM_OPIDPAGRecordOperation', 'IPA','opidOutboundMssg', 'exception','Exception occured while inserting ACM',err.getMessage() , sr.getId(), 'PRM_AccountChannelMembership__c', 'ACM');
                            }
                        }
                    }
                   
                    logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(acmsToUpdate, acmUpdateErrorhandle,'PRM_AccountChannelMembership__c');
                    acmMapError = PRM_OPIDProcessUtility.getErrorMessageForACM(acmsToUpdate,acmUpdateErrorhandle);
                    errorWrapper.putACMError(acmMapError);
                    
                    
                }
                Database.UpsertResult[] asaErrorHandle = null;
                if(listOfObjectToUpdate.size() > 0){
                    //upsert listOfObjectToUpdate;
                    asaErrorHandle = Database.upsert(listOfObjectToUpdate,false);
                    logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(listOfObjectToUpdate, asaErrorHandle,'PRM_Account_Specialty_Association__c');
                    /*if(!ipaRefresh || test.isrunningtest()){ //IPA2.0-TWC727-2861
                    asaMapError = PRM_OPIDProcessUtility.getErrorMessageForASAupsert(listOfObjectToUpdate,asaErrorHandle);
                    errorWrapper.putASAError(asaMapError);
                    }*/ // IPA Switch Removal
                }     
                
                // AIA Start
                    logEntryMsg+= updateOrCreateIPAAffiliation(mapOfParentandChildAcc,setOfAccountID,childAccIds,errorWrapper);
                //AIA End
                
               
                if(!abaMapError.isEmpty()){
                    logEntryMsg+=PRM_OPIDProcessUtility.updateABAErrorsInBoundTable(abaMapError,opidAcc);
                }
            }
            
            logEntryMsg+=deleteACMsonPAGAcc(listOfCAG, accounts,errorWrapper);
        }

        
        logEntryMsg+='\n*****RollUpAccounts Method Ends here...*******';
        logEntryMsgList.add(logEntryMsg);
        return errorWrapper;
    }

    // AIA Start
    /**
        *  @description      : Get IPA Affiliations of OPID account and Intel Account
        *  @name             : getIPAAffiliation
        *  @param            : Set<Id> childAccIds,Set<Id> opidAccountId
        * @userstory         : TWC729-7521 
    **/
    public Map<String, Set<PRM_IPA_Affiliation__c>> getIPAAffiliation (Set<Id> childAccIds,Set<Id> opidAccountId){
        Map<String, Set<PRM_IPA_Affiliation__c>> mapOfAccAff = new Map<String, Set<PRM_IPA_Affiliation__c>>();
        for(PRM_IPA_Affiliation__c aia : [select id,PRM_Builder_Strategy__c, PRM_Account__c, PRM_Active__c,PRM_Notes__c from PRM_IPA_Affiliation__c where PRM_Account__c in :childAccIds or  PRM_Account__c in :opidAccountId WITH SECURITY_ENFORCED]){
            if(mapOfAccAff.containsKey(aia.PRM_Account__c)){
                mapOfAccAff.get(aia.PRM_Account__c).add(aia);
            }else{
                Set<PRM_IPA_Affiliation__c> aiaSet = new Set<PRM_IPA_Affiliation__c>();
                aiaSet.add(aia);
                mapOfAccAff.put(aia.PRM_Account__c,aiaSet);
            }
        }
        return mapOfAccAff;
    }
    /**
        *  @description      : Update IPA Affiliations on OPID account based on IPA Affiliations associated to corresponding Intel Account
        *  @name             : updateOrCreateIPAAffiliation
        *  @param            : Map<id,List<id>> mapOfParentandChildAcc,Set<Id> opidAccountIds, Set<Id> childAccIds
        *  @throws exception : NONE
        * @userstory         : TWC729-7521 
    **/
    public String updateOrCreateIPAAffiliation (Map<id,List<id>> mapOfParentandChildAcc,Set<Id> opidAccountIds, Set<Id> childAccIds,PRM_OPIDErrorWrapper errorWrapper){
        Map<String, Set<PRM_IPA_Affiliation__c>> mapOfAccAff = new Map<String, Set<PRM_IPA_Affiliation__c>>();
        Map<String,Set<PRM_IPA_Affiliation__c>> opidAccAffMap = new Map<String,Set<PRM_IPA_Affiliation__c>>();
        Map<String,Set<PRM_IPA_Affiliation__c>> childAccAffMap = new Map<String,Set<PRM_IPA_Affiliation__c>>();
        Set<PRM_IPA_Affiliation__c> childAffiliation = new Set<PRM_IPA_Affiliation__c>();
        Set<PRM_IPA_Affiliation__c> activeChildAffiliation = new Set<PRM_IPA_Affiliation__c>();
        Set<PRM_IPA_Affiliation__c> opidAffiliation = new Set<PRM_IPA_Affiliation__c>();
        List<PRM_IPA_Affiliation__c> affiliationToUpsert = new List<PRM_IPA_Affiliation__c>();
        String logEntryMsg;
        logEntryMsg+='***UpdateOrCreateIPAAffiliation Start***';
        try{
            if(opidAccountIds!=null || childAccIds!=null){
                mapOfAccAff = getIPAAffiliation(childAccIds,opidAccountIds);
            }
            logEntryMsg+='***mapOfAccAff : '+mapOfAccAff+' ***';
            if(mapOfAccAff!=null && !mapOfAccAff.isEmpty()){
                for(String acc: mapOfAccAff.keySet()){
                    Set<PRM_IPA_Affiliation__c> aiaSet = mapOfAccAff.get(acc);
                    if(opidAccountIds.contains(acc)){
                        opidAccAffMap.put(acc,aiaSet);
                    }else if(childAccIds.contains(acc)){
                        childAccAffMap.put(acc,aiaSet);
                    }
                }
            }
            if(mapOfParentandChildAcc!=null && !mapOfParentandChildAcc.isEmpty()){
                for(Id opid: mapOfParentandChildAcc.keySet()){
                    Set<String> updatedBuilderStrat = new Set<String>();
                    Set<String> opidBuildStratSet = new Set<String>();
                    Set<String> childBuildStratSet = new Set<String>();
                    List<Id> childAccounts = mapOfParentandChildAcc.get(opid);
                    opidAffiliation = opidAccAffMap.get(opid);
                    if(opidAffiliation!=null){
                        opidBuildStratSet = getBuilderStrategy(opidAffiliation) ;
                    }
                    for(Id child: childAccounts){
                        if(childAccAffMap.containsKey(child)){
                           childAffiliation.addAll(childAccAffMap.get(child));
                        }
                    }

                    if(childAffiliation!=null && opidBuildStratSet!=null){
                        childBuildStratSet =  getBuilderStrategy(childAffiliation) ;
                        for(PRM_IPA_Affiliation__c childAia: childAffiliation){
                            if(!opidBuildStratSet.contains(childAia.PRM_Builder_Strategy__c) && childAia.PRM_Active__c && !updatedBuilderStrat.contains(childAia.PRM_Builder_Strategy__c)){
                                PRM_IPA_Affiliation__c aiaObj = new PRM_IPA_Affiliation__c();
                                aiaObj.PRM_Account__c = opid;
                                aiaObj.PRM_Builder_Strategy__c = childAia.PRM_Builder_Strategy__c; 
                                aiaObj.PRM_Active__c = true;
                                aiaObj.PRM_Notes__c ='Roll up to 1PID from Intel account';//TWC729-8089 : Adding reason text : NJ
                                updatedBuilderStrat.add(childAia.PRM_Builder_Strategy__c);
                                affiliationToUpsert.add(aiaObj);
                            }
                            if(childAia.PRM_Active__c){
                                activeChildAffiliation.add(childAia);
                            }
                        }
                    }
                    if(opidAffiliation!=null && childBuildStratSet!=null){
                        for(PRM_IPA_Affiliation__c opidAia : opidAffiliation){
                            if(!childBuildStratSet.contains(opidAia.PRM_Builder_Strategy__c) && opidAia.PRM_Active__c){
                                opidAia.PRM_Active__c = false;
                                opidAia.PRM_notes__c='Roll down from 1PID';//TWC729-8089 : Adding reason text : NJ
                            }else if(childBuildStratSet.contains(opidAia.PRM_Builder_Strategy__c) && !opidAia.PRM_Active__c){
                                opidAia.PRM_Active__c = true;
                                opidAia.PRM_notes__c='Roll up to 1PID from Intel account';//TWC729-8089 : Adding reason text : NJ
                            }
                            affiliationToUpsert.add(opidAia);
                        }
                    }
                }
            }
            logEntryMsg+='***affiliationToUpsert : '+affiliationToUpsert+' ***';
            listOfAIAToUpdate.addAll(affiliationToUpsert);
            Database.UpsertResult[] aiaErrorHandle = null;
            if(listOfAIAToUpdate.size()>0){
                aiaErrorHandle = Database.upsert(listOfAIAToUpdate,false);
                logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(listOfAIAToUpdate, aiaErrorHandle,'PRM_IPA_Affiliation__c');
                aiaMapError = PRM_OPIDProcessUtility.getErrorMessageForAIAupsert(listOfAIAToUpdate,aiaErrorHandle);
                errorWrapper.putAIAError(aiaMapError);
            }        
            
        }catch(Exception ex){
            logEntryMsg+='***Exception : '+ex;
        }
        return logEntryMsg;
        
    }    

    public Set<String> getBuilderStrategy(Set<PRM_IPA_Affiliation__c> afflSet){
        Set<String> affBuildStrat = new Set<String>();
        for(PRM_IPA_Affiliation__c aia: afflSet){
            affBuildStrat.add(aia.PRM_Builder_Strategy__c);
        }
        return affBuildStrat;
    }
    // AIA End
    @TestVisible
    private String deleteACMsonPAGAcc(List<Core_Account_Group_Member__c> listOfCAG, List<Account> pagAccList,PRM_OPIDErrorWrapper errorWrapper){
        List<Account> accIds = new List<Account>();
        List<Id> allAccIds = new List<Id>();                    
        String logEntryMsg='';
        logEntryMsg+='\n*****deleteACMsonPAGAcc Method Start here...*******';
        boolean isNotPresent = true;
        Map<Id,Id> mapOfIntelAccPAGAcc = new Map<Id,Id>();
        if(!listOfCAG.isEmpty()){
            for(Account pagAcc: pagAccList){                
                isNotPresent = true;
                allAccIds.add(pagAcc.id);
                for(Core_Account_Group_Member__c cag: listOfCAG){
                    mapOfIntelAccPAGAcc.put(cag.Core_Intel_Account_Id__c, cag.Core_Partner_Account_Id__c);
                    allAccIds.add(cag.Core_Intel_Account_Id__c);
                    if(pagAcc.id == cag.Core_Partner_Account_Id__c){
                        isNotPresent = false;
                    }
                }
                if(isNotPresent == true){
                    logEntryMsg+='\n***Removing Segment, Speciality & Biz Org type values as no associated intel accounts found for OPID:'+pagAcc.id +'***';
                    //if(!iparefresh)pagAcc.Core_IPA_Partner_Segment__c = ''; // IPA Switch Removal
                    pagAcc.Core_Account_Type__c = '';accIds.add(pagAcc);
                }
                pagAccountIDDetails.put(pagAcc.Core_OnePartnerID__c, pagAcc.id);
            }
        }else{
            for(Account pagAcc: pagAccList){
                logEntryMsg+='\n***Removing Segment, Speciality & Biz Org type values as no associated intel accounts found for OPID: '+pagAcc.id +'***';
                allAccIds.add(pagAcc.id);
               // if(!iparefresh)pagAcc.Core_IPA_Partner_Segment__c = '';
                pagAcc.Core_Account_Type__c = '';
                pagAccountIDDetails.put(pagAcc.Core_OnePartnerID__c, pagAcc.id);
            }
            accIds.addAll(pagAccList);
        }
        //Error handling code for pagUpdate start
        Database.UpsertResult[] pagAccErrorHandle = null;
        if(pagAccList.size() > 0){
            //update pagAccList;
            pagAccErrorHandle = Database.upsert(pagAccList,false);
            logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(pagAccList, pagAccErrorHandle,'Account');
            pagAccountMapError = PRM_OPIDProcessUtility.getErrorMessageForOPID(pagAccList, pagAccErrorHandle);
            errorWrapper.putPAGError(pagAccountMapError);
        }
        
        //pagUpdate End
        
       
        List<PRM_Account_Specialty_Association__c> listOfASAs = [select Id, PRM_Specialty_Id__c, PRM_Account_Id__c, PRM_InActive_Ind__c,PRM_Partner_Role__c,PRM_Status_Reason_Txt__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__c in :allAccIds and PRM_InActive_Ind__c = false and PRM_Specialty_Id__r.PRM_InActive_Ind__c=false WITH SECURITY_ENFORCED];
        Map<Id, List<String>> mapOfPAGAccIdIntelAccASA = new Map<Id, List<String>>();
        Map<Id, List<PRM_Account_Specialty_Association__c>> mapOfPAGAccIdASAs = new Map<Id, List<PRM_Account_Specialty_Association__c>>();
        List<PRM_Account_Specialty_Association__c> asaToUpdate = new List<PRM_Account_Specialty_Association__c>();
        String parentId;
        List<PRM_Account_Specialty_Association__c> asaList;
        List<String> asaStringList;
        
        logEntryMsg+='\n**** Values in listOfASAs List :\n '+listOfASAs+'***';//DE101897:Added by Srishty
        /* if(!ipaRefresh || test.isrunningtest()){ //IPA2.0-TWC727-2861
        for(PRM_Account_Specialty_Association__c asa: listOfASAs){
            if(pagAccList.toString().contains(asa.PRM_Account_Id__c)){                
                if(mapOfPAGAccIdASAs.containsKey(asa.PRM_Account_Id__c)){
                    asaList = mapOfPAGAccIdASAs.get(asa.PRM_Account_Id__c);
                }else{
                    asaList = new List<PRM_Account_Specialty_Association__c>();
                }
                asaList.add(asa);
                mapOfPAGAccIdASAs.put(asa.PRM_Account_Id__c, asaList);
            }else{
                parentId = '';
                parentId = mapOfIntelAccPAGAcc.get(asa.PRM_Account_Id__c);
                if(mapOfPAGAccIdIntelAccASA.containsKey(parentId)){
                    asaStringList = mapOfPAGAccIdIntelAccASA.get(parentId);
                }else{
                    asaStringList = new List<String>();
                }
                asaStringList.add(asa.PRM_Specialty_Id__c + '-' + asa.PRM_Partner_Role__c);
                
                mapOfPAGAccIdIntelAccASA.put(parentId, asaStringList);
            }                                               
        }
        boolean inactivateAsa;
        for(Id pagAccId: mapOfPAGAccIdASAs.keySet()){
            List<PRM_Account_Specialty_Association__c> pagAsaList = mapOfPAGAccIdASAs.get(pagAccId);
            for(PRM_Account_Specialty_Association__c asa: pagAsaList){
                List<String> childAsaList = mapOfPAGAccIdIntelAccASA.get(pagAccId);

                if(childAsaList!= null && !childAsaList.isEmpty()){
                    inactivateAsa = true;
                    for(String asaString: childAsaList){
                        if(asaString.equals(asa.PRM_Specialty_Id__c + '-' + asa.PRM_Partner_Role__c)){
                            inactivateAsa = false;
                        }
                    }
                    if(inactivateAsa == true){
                        logEntryMsg+='\n***Inactivating ASA for OPID Acc:'+pagAccId +' for Speciality-Partner Role :'+asa.PRM_Specialty_Id__c + '-' + asa.PRM_Partner_Role__c+' as no ASA found on child accounts***';
                        asa.PRM_InActive_Ind__c = true;
                        asa.PRM_Status_Reason_Txt__c  = System.Label.PRM_ASA_Inactive_StatReason;
                        asaToUpdate.add(asa);                       
                    }
                }
                else{
                    logEntryMsg+='\n***Inactivating ASA for OPID Acc:'+pagAccId +' for Speciality-Partner Role :'+asa.PRM_Specialty_Id__c + '-' + asa.PRM_Partner_Role__c+' as no ASA found on child accounts***';
                    asa.PRM_InActive_Ind__c = true;
                    asa.PRM_Status_Reason_Txt__c  = System.Label.PRM_ASA_Inactive_StatReason;
                    asaToUpdate.add(asa);                    
                }
                
            }
            
            
        }
        }   */ // IPA Switch Removal 
        //delete Speciality benefits and ErrorHandleing
        Database.SaveResult[] asaErrorHandle = null;
        if(asaToUpdate.size() > 0){
            //update asaToUpdate;            
            asaErrorHandle = Database.update(asaToUpdate,false);
            logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(asaToUpdate, asaErrorHandle,'PRM_Account_Specialty_Association__c');
            /*if(!ipaRefresh || test.isrunningtest()){//IPA2.0-TWC727-2861
            asaMapError =  PRM_OPIDProcessUtility.getErrorMessageForASA(asaToUpdate,asaErrorHandle);
            errorWrapper.putASAError(asaMapError);            
                }*/ // IPA Switch Removal
        }
        if(accIds.size() > 0){
            List<PRM_AccountChannelMembership__c> listACM = [Select Id,PRM_Account_Id__c,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :accIds WITH SECURITY_ENFORCED];
            for(PRM_AccountChannelMembership__c acm: listACM){
                acm.PRM_Status_Nm__c = 'Inactive';
                acm.PRM_Status_Reason_Txt__c = System.Label.PRM_ACM_INACTIVE;
            }            
            //Update ACM error handel
            Database.SaveResult[] acmErrorHandle = null;
            //update listACM;
            if(listACM.size() > 0) {                
                acmErrorHandle = Database.update(listACM,false);
                logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(listACM, acmErrorHandle,'PRM_AccountChannelMembership__c');
                acmMapError = PRM_OPIDProcessUtility.getErrorMessageForACM(listACM,acmErrorHandle);
                errorWrapper.putACMError(acmMapError);                
            }
            //ACM update 
        }
        logEntryMsg+='\n*****deleteACMsonPAGAcc Method Ends here...*******';
        return logEntryMsg;
    }
    
    
    
    
    /**
* This method will used for rollup the OPIDAccount based on ACM,PPSegment and PPSpeciality of each child Salesforce Account
* @param ID parentSfID
* @param List<ID> childSfIDs
*/
    public String rollUpOPIDAccount(Id parentSfID, List<Id> childSfIDs,PRM_OPIDErrorWrapper errorWrapper, List<PRM_AccountChannelMembership__c> listOfACM){
        String logEntryMsg='';
        List<String> logEntryMsgList = new List<String>();
        logEntryMsg+='\n*** Intel account ids associated to OPID account : '+childSfIDs+'***';
        if(childSfIDs != null && parentSfID != null){
            Map<String, PRM_AccountChannelMembership__c> mapParentACM = new Map<String, PRM_AccountChannelMembership__c>();            
            Map<String,List<PRM_HigestBadgeFromACMs>> mapOfGrpdAcmsByPtnrRole = new Map<String,List<PRM_HigestBadgeFromACMs>>();
            
            //ACM based IPAbadge update at parentSFOPID
            Set<Id> setOfAccountID = new Set<Id>(childSfIDs);
            setOfAccountID.add(parentSfID);
            
            
            // List<PRM_AccountChannelMembership__c> listOfACM = [select id, PRM_Account_Id__c, PRM_Partner_Role__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c, PRM_Channel_Program_Level_Id__r.name, PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :setOfAccountID WITH SECURITY_ENFORCED]; 
            if(listOfACM != null){
                //List<PRM_AccountChannelMembership__c> parentACMsList = new List<PRM_AccountChannelMembership__c>();
                for(PRM_AccountChannelMembership__c acm : listOfACM){
                    
                    //TWC729-4151: Add null check for Partner Role                  
                    if(acm.PRM_Account_Id__c == parentSfID  && string.isNotBlank(acm.PRM_Partner_Role__c)){
                       mapParentACM.put(acm.PRM_Partner_Role__c, acm);
                        logEntryMsg+='\n*** OPID Account ACM found with Partner Role : '+acm.PRM_Partner_Role__c+', Tier: '+acm.PRM_Channel_Program_Level_Id__r.name+', & Status:'+acm.PRM_Status_Nm__c+'***';
                        
                    }else if(acm.PRM_Status_Nm__c == 'Approved' && string.isNotBlank(acm.PRM_Partner_Role__c)){
                        logEntryMsg+='\n*** Intel Account ACM found with Partner Role : '+acm.PRM_Partner_Role__c+', Tier: '+acm.PRM_Channel_Program_Level_Id__r.name+', & Status:'+acm.PRM_Status_Nm__c+'***';
                        List<PRM_HigestBadgeFromACMs> acmList = null;
                        if(!mapOfGrpdAcmsByPtnrRole.isEmpty()){
                            acmList = mapOfGrpdAcmsByPtnrRole.get(acm.PRM_Partner_Role__c);
                            if(acmList == null){
                                acmList = new List<PRM_HigestBadgeFromACMs>();}                        
                            acmList.add(new PRM_HigestBadgeFromACMs(acm));                        
                        }else{
                            acmList = new List<PRM_HigestBadgeFromACMs>();
                            acmList.add(new PRM_HigestBadgeFromACMs(acm));                       
                        }
                        if(acmList != null && acmList.size() > 0){
                            mapOfGrpdAcmsByPtnrRole.put(acm.PRM_Partner_Role__c,acmList);
                        }
                    }
                } 
            }
            
          
            
            //Updated ACMBadgeForOPIDAccount updatedIPABadge details only populate on the case of new PartnerRole inserted otherwise it is null.
            String newPartnerRoleDetails = updateOrInsertACMBadgeForOPIDAccount(mapParentACM,mapOfGrpdAcmsByPtnrRole,parentSfID,errorWrapper,logEntryMsgList);
            if(logEntryMsgList.size()>0){
                logEntryMsg+= logEntryMsgList[0];
                logEntryMsgList.clear();
            }
            OPIDUpdateWrapper updatedOPIDWrapper = getPPSpeOrSegForOPIDAccount(childSfIDs,parentSfID,logEntryMsgList);
            if(logEntryMsgList.size()>0){
               logEntryMsg+= logEntryMsgList[0];
            }
            
            /*       //Inactive benifits

if(listOfInactiveACM.size() > 0){
inactivateBenefitAsPerACM(listOfInactiveACM,parentSfID,errorWrapper);
} */
            
           
            String updateBadge = udateBadgeTier(parentSfID, mapParentACM.values());
            logEntryMsg+='\n*** Badge tier to be updated on account: '+updateBadge+'****';
                    
            //Update OPID Account
            if(updatedOPIDWrapper != null){
                updateOPIDAccount(updatedOPIDWrapper,newPartnerRoleDetails,updateBadge,errorWrapper);
            }
            
            //Segments related update at OPID level
                     
            // Set<String> parentIdSet = new Set<String>();
            //parentIdSet.add(parentSfID);
            logEntryMsg+=rollupSpecialityAssociation(parentSfID,errorWrapper);    
            
        }
        logEntryMsg+='\n*********rollUpOPIDAccount Method ends here...***********';
        return logEntryMsg;
    }
    
    private String udateBadgeTier(Id parentSfID, List<PRM_AccountChannelMembership__c> listOfACM){
        //List<PRM_AccountChannelMembership__c> listOfACM = [select id, PRM_Account_Id__c, PRM_Partner_Role__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c, PRM_Channel_Program_Level_Id__r.name, PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: parentSfID WITH SECURITY_ENFORCED]; 
        List<PRM_HigestBadgeFromACMs> listOfBadges = new List<PRM_HigestBadgeFromACMs>();
        String badgeName = null;
        if(listOfACM != null){
            for(PRM_AccountChannelMembership__c acm : listOfACM){
                if(acm.PRM_Status_Nm__c == 'Approved'){
                    listOfBadges.add(new PRM_HigestBadgeFromACMs(acm));
                }
            }
            
            //Sorted based on batch available for parent record
            listOfBadges.sort();
            
            if(!listOfBadges.isEmpty()){
                PRM_AccountChannelMembership__c highestBadgeACM = listOfBadges[0].acm;
                badgeName = highestBadgeACM.PRM_Channel_Program_Level_Id__r.name;
            }
        }
        return badgeName;
    }
    
    private void updateOPIDAccount(OPIDUpdateWrapper updatedOPIDWrapper,String newPartnerRoleDetails,String updateBadge,PRM_OPIDErrorWrapper errorWrapper ){
        Account parentAcc = updatedOPIDWrapper.acc;
        if(parentAcc != null){
            boolean updateRequired = false;
            if(updatedOPIDWrapper.bizOrgType != null){
                parentAcc.Core_Account_Type__c = updatedOPIDWrapper.bizOrgType;
                updateRequired = true;
            }
            if(updatedOPIDWrapper.ppSegment != null){
                //if(!iparefresh)parentAcc.Core_IPA_Partner_Segment__c = updatedOPIDWrapper.ppSegment;
                updateRequired = true;
            }
            

            
            if(updateBadge != null){
                parentAcc.Core_IPA_Badge_Tier__c = updateBadge;
                parentAcc.PRM_IPA_Badge_Tier_Date__c = System.now();
                updateRequired = true;
            }
            
            //Database.UpsertResult[] parentACCErrHandle = null;
            List<Account> listOfAccount = new List<Account>();
            listOfAccount.add(parentAcc);
            pagAccountIDDetails.put(parentAcc.Core_OnePartnerID__c, parentAcc.id);
            if(updateRequired){
                //update parentAcc;
               
                /*   parentACCErrHandle = Database.upsert(listOfAccount,false);

pagAccountMapError = PRM_OPIDProcessUtility.getErrorMessageForOPID(listOfAccount,parentACCErrHandle);

errorWrapper.putPAGError(pagAccountMapError); */
                listOfAccountsToUpdate.add(parentAcc);
            }
        }
    }
    
    
    
    private String updateOrInsertACMBadgeForOPIDAccount(Map<String, PRM_AccountChannelMembership__c> mapParentACM, Map<String,List<PRM_HigestBadgeFromACMs>> mapOfGrpdAcmsByPtnrRole,ID parentSfID,PRM_OPIDErrorWrapper errorWrapper,List<String> logEntryMsgList){
        String logEntryMsg='';
        String addedPartnerRole = null;
        // List<PRM_AccountChannelMembership__c> updatedList = new List<PRM_AccountChannelMembership__c>();
        //List<PRM_AccountChannelMembership__c> acmsToUpdate = new List<PRM_AccountChannelMembership__c>();
        
        //Update OPID Accounts ACM if the Child account is removed
        for(String partnerRole: mapParentACM.keyset()){
            if(mapOfGrpdAcmsByPtnrRole.get(partnerRole) == null){
                logEntryMsg+='\n***ACM added for inactivation as no ACM found on child accounts for partner role: ' + partnerRole + '***';
                PRM_AccountChannelMembership__c acm = mapParentACM.get(partnerRole);
                acm.PRM_Status_Nm__c = 'Inactive';
                acm.PRM_Status_Reason_Txt__c = System.Label.PRM_ACM_INACTIVE;
                
                listOfInactiveACM.add(acm);
                
                acmsToUpdate.add(acm);
            }
        }
        ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name =:System.Label.PRM_Intel_Partner_Alliance LIMIT 1];                
        for(String parnerRole : mapOfGrpdAcmsByPtnrRole.keySet()){
            PRM_AccountChannelMembership__c parentACM = mapParentACM.get(parnerRole);
            List<PRM_HigestBadgeFromACMs> listOfBadge = mapOfGrpdAcmsByPtnrRole.get(parnerRole);
            
            //Sorting based on badge valuation.
            listOfBadge.sort();
            PRM_AccountChannelMembership__c updatedACM = listOfBadge[0].acm;
       
            if(parentACM != null){
                //Existing parent ACM based on partner role update
                String existingBadge = parentACM.PRM_Channel_Program_Level_Id__r.name;
                String updatedBadge = updatedACM.PRM_Channel_Program_Level_Id__r.name;
                
                Map<String,Integer> metaObj = PRM_HigestBadgeFromACMs.getIPABadgeMap();
                Integer existingBadgeRank = metaObj.get(existingBadge);
                Integer updatedBadgeRank = metaObj.get(updatedBadge);
                
                //Message added for update case
                
                String statusMessage=PRM_OPIDProcessUtility.acmUpdateStatusMessage(existingBadge,updatedBadge);                
                
                //ACM active and inactive check during rollup
                if(!parentACM.PRM_Status_Nm__c.equals('Inactive') && existingBadge != updatedBadge && existingBadgeRank > updatedBadgeRank){
                    logEntryMsg+='\n***Updating ACM on OPID Account for partner role: ' + parnerRole + ' with tier from'+existingBadge+' to '+updatedBadge+' ***';
                    parentACM.PRM_Channel_Program_Level_Id__c = updatedACM.PRM_Channel_Program_Level_Id__c;    
                    if(statusMessage != null){
                        parentACM.PRM_Status_Reason_Txt__c = statusMessage;
                    }
                    updatedListACM.add(parentACM);
                }else if(parentACM.PRM_Status_Nm__c.equals('Inactive')){
                    logEntryMsg+='\n***Approving an inactive ACM on OPID Account for partner role: ' + parnerRole +' ***';
                    parentACM.PRM_Channel_Program_Level_Id__c = updatedACM.PRM_Channel_Program_Level_Id__c;
                    parentACM.PRM_Status_Nm__c = updatedACM.PRM_Status_Nm__c;
                    if(statusMessage != null){
                        parentACM.PRM_Status_Reason_Txt__c = statusMessage;
                    }
                    updatedListACM.add(parentACM);
                }
                //Update ACM for triggering Points Redemption batch for same tier accounts
                else if(!parentACM.PRM_Status_Nm__c.equals('Inactive') && existingBadge == updatedBadge){
          updatedListACM.add(parentACM);//For Points redemption batch to pick up the record

                }
                
                addedPartnerRole = addedPartnerRole != null ? addedPartnerRole + ';'+ updatedACM.PRM_Partner_Role__c : updatedACM.PRM_Partner_Role__c;
            }else{
                logEntryMsg+='\n***Creating an ACM on OPID Account for partner role: ' + parnerRole +' ***';
                
                //TWC729-4151: Add check for Partner program should be Intel_Partner_Alliance                
                //ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name =:System.Label.PRM_Intel_Partner_Alliance LIMIT 1];                
                if(updatedACM.PRM_Channel_Program_Id__c == cp.id){    
                //New ACM creation based on partner role, which is not present in parent ACM details.
                PRM_AccountChannelMembership__c newParentACM = new PRM_AccountChannelMembership__c();
                newParentACM.PRM_Account_Id__c = parentSfID;
                newParentACM.PRM_Channel_Program_Level_Id__c = updatedACM.PRM_Channel_Program_Level_Id__c;
                newParentACM.PRM_Channel_Program_Id__c = updatedACM.PRM_Channel_Program_Id__c;
                newParentACM.PRM_Partner_Role__c = updatedACM.PRM_Partner_Role__c;
                newParentACM.PRM_Status_Nm__c = updatedACM.PRM_Status_Nm__c;
                String statusMsg = System.Label.PRM_ACM_INSERT;
                    
                if(statusMsg.contains('{Tier}')){
                    statusMsg = statusMsg.replace('{Tier}', updatedACM.PRM_Channel_Program_Level_Id__r.name);
                    newParentACM.PRM_Status_Reason_Txt__c = statusMsg;
                }
                updatedListACM.add(newParentACM);
                }        
                
                //Capturing new partnerrole details to populate in BizOrgType of Parent OPIDAccount.
                addedPartnerRole = addedPartnerRole != null ? addedPartnerRole + ';'+ updatedACM.PRM_Partner_Role__c : updatedACM.PRM_Partner_Role__c;
            }
            
            
        }
        
        //Update/Insert new record to the parent for its badge type
        /*   Database.UpsertResult[] acmErrorHandle = null;
if(updatedList.size() > 0){
//upsert updatedList;
acmErrorHandle = Database.upsert(updatedList,false);
acmMapError = PRM_OPIDProcessUtility.getErrorMessageForACMupsert(updatedList,acmErrorHandle);
errorWrapper.putACMError(acmMapError);
}        
Database.SaveResult[] acmUpdateErrorhandle = null;
if(acmsToUpdate.size() > 0){
//update acmsToUpdate;
acmUpdateErrorhandle = Database.update(acmsToUpdate,false);
acmMapError = PRM_OPIDProcessUtility.getErrorMessageForACM(acmsToUpdate,acmUpdateErrorhandle);
errorWrapper.putACMError(acmMapError);
} */
        
        
        //Inactive benifits
        /*   if(listOfInactiveACM.size() > 0){
inactivateBenefitAsPerACM(listOfInactiveACM,parentSfID,errorWrapper);
} */
        logEntryMsgList.add(logEntryMsg);
        return addedPartnerRole;
    }
    
    private OPIDUpdateWrapper getPPSpeOrSegForOPIDAccount(List<ID> childSfIDs, ID parentSfID,List<String> logEntryMsgList){
        OPIDUpdateWrapper opidUpdateWrapper = null;
        String logEntryMsg='';
        logEntryMsg+='\n*****getPPSpeOrSegForOPIDAccount Method Start here...******';
        String ppSegmentsForOPID = null;
        String ppSpecialityForOPID = null;
        String bizOrgTypesForOPID = null;
        if(childSfIDs != null && parentSfID != null){
            //Fetch account details including Parent and its Child account
            Set<ID> setOfAccountID = new Set<ID>(childSfIDs);
            setOfAccountID.add(parentSfID);
            
            Map<id,Account> mapOfAccountObject = new Map<Id,Account>();    
            mapOfAccountObject.putAll(mapOfParentIdAccounts.get(parentSfID));
            Set<String> ppSegments = new Set<String>();
            //Set<String> ppSpeciality = new Set<String>();
            Set<String> bizOrgTypes = new Set<String>();
            for(Account acc : mapOfAccountObject.values()){
                if(acc.id != parentSfID){
                    ppSegments.addAll(getListOfPicklistValues(acc.Core_IPA_Partner_Segment__c)); 
                    bizOrgTypes.addAll(getListOfPicklistValues(acc.Core_Account_Type__c));                   
                }
            }
            
            //Parent Account
            Account parentAcc = mapOfAccountObject.get(parentSfID);
                                        //if(!iparefresh)parentAcc.Core_IPA_Partner_Segment__c = '';
            parentAcc.Core_Account_Type__c = '';
            
                                        //if(!iparefresh)ppSegmentsForOPID = getUpdatedString(ppSegments,parentAcc.Core_IPA_Partner_Segment__c);
            bizOrgTypesForOPID = getUpdatedString(bizOrgTypes,parentAcc.Core_Account_Type__c);
            logEntryMsg+='\n*** Updated Segment, Speciality, Biz org Type:'+ppSegmentsForOPID+','+ ppSpecialityForOPID+','+bizOrgTypesForOPID+'***';
            opidUpdateWrapper = new opidUpdateWrapper(parentAcc,ppSpecialityForOPID,ppSegmentsForOPID,bizOrgTypesForOPID);            
        }
        logEntryMsg+='\n*****getPPSpeOrSegForOPIDAccount Method Ends here...******';
        logEntryMsgList.add(logEntryMsg);
        return opidUpdateWrapper;
    }
    
    private Set<String> getListOfPicklistValues(String str){
        Set<String> stringSet = new Set<String>();
        if(String.isNotBlank(str) && str.indexOf(';') > 0){
            stringSet.addAll(str.split(';'));
        }else{
            stringSet.add(str);
        }
        return stringSet;
    }
    
    private String getUpdatedString(Set<String> setOfString, String parentString){
        for(String str : setOfString){
            if(String.isNotBlank(str)){
                if(!String.isNotBlank(parentString)){
                    parentString = str;
                }
                if(!parentString.contains(str)){
                    parentString = parentString +';'+str;
                }
            }            
        }
        return parentString;
    } 
    
    public class OPIDUpdateWrapper{
        Account acc;
        String ppSpeciality;
        String ppSegment;
        String bizOrgType;
        
        public OPIDUpdateWrapper(Account acc,String ppSpeciality, String ppSegment, String bizOrgType){
            this.ppSpeciality = ppSpeciality;
            this.ppSegment = ppSegment;
            this.bizOrgType = bizOrgType; 
            this.acc = acc;
        }
    }
    
    
    public PRM_OPIDErrorWrapper rolldownChannelMembership(PRM_OPIDErrorWrapper errorWrapper,List<String> logEntryMsgList, List<Core_Account_Group_Member__c> allCAGList){
        String logEntryMsg = '';
        logEntryMsg+='\n*****rolldownChannelMembership Method Start here...******';
        if(errorWrapper == null){
            errorWrapper = new PRM_OPIDErrorWrapper();
        }        
        //querying Core_Account_Group_Member__c corresponding to the OPID accounts
        //List<Core_Account_Group_Member__c> allCAGList = [Select Id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c IN: pagList and Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true and Core_Inactive_Ind__c = false WITH SECURITY_ENFORCED];
        logEntryMsg+='\n*** Rolldown process started...***';
        logEntryMsg+='\n***List of Core Account Group Member corresponding to the  OPID accounts'+allCAGList+'***'; 
        Map<Id, Id> mapOfIntelAccPAGAcc = new Map<Id, Id>();
        for(Core_Account_Group_Member__c cag: allCAGList){
            mapOfIntelAccPAGAcc.put(cag.Core_Intel_Account_Id__c, cag.Core_Partner_Account_Id__c);
        }
        Map<String, Decimal> mapOfBadgeNameTier = new Map<String, Decimal>();
    for(String bageMapping :LabelConfiguration__mdt.getInstance('ChannelProgramLevelRanking').Value__c.split(';')){ 
            List<String> progTier = bageMapping.split(':');
            mapOfBadgeNameTier.put(progTier[0],Integer.valueOf(progTier[1]));        
        }
        //TWC729-4151: Add null check for Partner Role
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        if(!mapOfIntelAccPAGAcc.isEmpty()){
           acmList = [Select id, PRM_Account_Id__c,PRM_Account_Id__r.recordtypeid, PRM_Channel_Program_Level_Id__r.Name, PRM_Partner_Role__c,PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Status_Nm__c =:System.Label.PRM_Status AND PRM_Partner_Role__c != null  AND  (PRM_Account_Id__c IN :mapOfIntelAccPAGAcc.keyset() or PRM_Account_Id__c IN :mapOfIntelAccPAGAcc.values()) WITH SECURITY_ENFORCED];    
        }
        
        
        Id pagRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Map<String,PRM_AccountChannelMembership__c> mapOfPartnerRoleACM;
        Map<String,Map<String,PRM_AccountChannelMembership__c>>  mapOfPAGAccACM =  new Map<String,Map<String,PRM_AccountChannelMembership__c>>();
        Map<String,List<PRM_AccountChannelMembership__c>> mapOfIntelAccACMList =  new Map<String,List<PRM_AccountChannelMembership__c>>();
        List<PRM_AccountChannelMembership__c> childAcmList;
        for(PRM_AccountChannelMembership__c acm: acmList){
            if(acm.PRM_Account_Id__r.recordtypeid == pagRecordType){
                if(mapOfPAGAccACM.containskey(acm.PRM_Account_Id__c)){
                    mapOfPartnerRoleACM = mapOfPAGAccACM.get(acm.PRM_Account_Id__c);
                }else{
                    mapOfPartnerRoleACM = new Map<String,PRM_AccountChannelMembership__c>();
                }
                mapOfPartnerRoleACM.put(acm.PRM_Partner_Role__c, acm);
                mapOfPAGAccACM.put(acm.PRM_Account_Id__c,mapOfPartnerRoleACM);
            }else{
                if(mapOfIntelAccACMList.containskey(acm.PRM_Account_Id__c)){
                    childAcmList = mapOfIntelAccACMList.get(acm.PRM_Account_Id__c);
                }else{
                    childAcmList = new List<PRM_AccountChannelMembership__c>();
                }        
                childAcmList.add(acm);
                mapOfIntelAccACMList.put(acm.PRM_Account_Id__c,childAcmList);      
            }
            
        }
        String parentId;
        Map<String,PRM_AccountChannelMembership__c> mapOfPartnerRoleACMList;
        PRM_AccountChannelMembership__c parentACM;
        List<PRM_AccountChannelMembership__c> acmsToUpdate = new List<PRM_AccountChannelMembership__c>();
        for(Id accId: mapOfIntelAccACMList.keyset()){
            List<PRM_AccountChannelMembership__c> intelAccAcmList = mapOfIntelAccACMList.get(accId);
            for(PRM_AccountChannelMembership__c acm: intelAccAcmList){
                parentId = '';
                if(mapOfIntelAccPAGAcc.containskey(accId)){
                    parentId = mapOfIntelAccPAGAcc.get(accId);
                    if(String.IsNotBlank(parentId) && mapOfPAGAccACM.containskey(parentId)){
                        mapOfPartnerRoleACMList = mapOfPAGAccACM.get(parentId);
                        if(mapOfPartnerRoleACMList.containsKey(acm.PRM_Partner_Role__c)){
                        parentACM = mapOfPartnerRoleACMList.get(acm.PRM_Partner_Role__c);
                        if(parentACM != null && mapOfBadgeNameTier.get(parentACM.PRM_Channel_Program_Level_Id__r.Name) < mapOfBadgeNameTier.get(acm.PRM_Channel_Program_Level_Id__r.Name)){
                            acm.PRM_Channel_Program_Level_Id__c = parentACM.PRM_Channel_Program_Level_Id__c;
                            String statusMessage = PRM_OPIDProcessUtility.acmUpdateStatusMessage(acm.PRM_Channel_Program_Level_Id__r.name, parentACM.PRM_Channel_Program_Level_Id__r.name);
                            acm.PRM_Status_Reason_Txt__c = statusMessage;
                            acmsToUpdate.add(acm);
                        } 
                    }
                }
            }
        }
        }
        Database.SaveResult[] acmErrorHandle = null;
        if(acmsToUpdate.size() > 0){
            //update acmsToUpdate;
            acmErrorHandle = Database.update(acmsToUpdate,false);
            logEntryMsg+= PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(acmsToUpdate,acmErrorHandle,'PRM_AccountChannelMembership__c');
            acmMapError = PRM_OPIDProcessUtility.getErrorMessageForACM(acmsToUpdate,acmErrorHandle);
            errorWrapper.putACMError(acmMapError);
        }
        logEntryMsg+='\n*****rolldownChannelMembership Method Ends here...******';
        logEntryMsgList.add(logEntryMsg);
        return errorWrapper;
    }
    //US821813:OPID upgrade recommendation record removal from recommendation table - detachment of location account from OPID.
    public Map<String,List<Core_OnePartner_Inbound_Message__c>> inactivateCoreAccGrpMembers(List<Core_OnePartner_Inbound_Message__c> inboundMsgList,List<String> logEntryMsgList){
        Set<Core_Account_Group_Member__c> cagsSetToUpdate = new Set<Core_Account_Group_Member__c>();
        List<Core_Account_Group_Member__c> cagsToUpdate = new List<Core_Account_Group_Member__c>();
        List<Account> accToUpdate = new List<Account>();
        String logEntryMsg='';
        logEntryMsg+='\n*****inactivateCoreAccGrpMembers Method Start here...******';
        Map<String,List<Core_OnePartner_Inbound_Message__c>> inbMsgsToDiscard = new Map<String,List<Core_OnePartner_Inbound_Message__c>>();
        //Map<String,Core_OnePartner_Inbound_Message__c> opidInboundMsgMap = new Map<String,Core_OnePartner_Inbound_Message__c>();
        PRM_OPIDErrorWrapper errorWrapper = new PRM_OPIDErrorWrapper();
        
        if(!inboundMsgList.isEmpty()){
            //Map<String,String> mapOfAccIdOPID = new Map<String, String>();
            Set<String> accOpid = new Set<String>();
            Map<String,List<Core_OnePartner_Inbound_Message__c>> mapofInboundMessage = new Map<String,List<Core_OnePartner_Inbound_Message__c>>();
            List<Core_OnePartner_Inbound_Message__c> inbMsgList;
            for(Core_OnePartner_Inbound_Message__c inboundMsg: inboundMsgList){
                //mapOfAccIdOPID.put(inboundMsg.Core_SalesCloud_AccountID__c, String.valueOf(inboundMsg.Core_OnePartnerID__c.intValue()));
                      
                if (mapofInboundMessage.containsKey(inboundMsg.Core_SalesCloud_AccountID__c)){
                    inbMsgList = mapofInboundMessage.get(inboundMsg.Core_SalesCloud_AccountID__c);          
                }else{
                    inbMsgList = new List<Core_OnePartner_Inbound_Message__c>();
                }    
                inbMsgList.add(inboundMsg);
                mapofInboundMessage.put(inboundMsg.Core_SalesCloud_AccountID__c,inbMsgList);
            }   
           
            Map<String, Core_Account_Group_Member__c> mapOfSfIdCAG = new Map<String, Core_Account_Group_Member__c>();
            for(Core_Account_Group_Member__c cag:[Select Id, Core_Inactive_Ind__c,Core_Intel_Account_Id__c,PRM_RelationshipStartDate__c,PRM_RelationshipEndDate__c,Core_Intel_Account_Id__r.Core_Customer_Aggregation_Type__c, Core_Partner_Account_Id__r.Core_OnePartnerID__c,Delink_Association_User__c,Comments__c from Core_Account_Group_Member__c where Core_Inactive_Ind__c = false and Core_Intel_Account_Id__c IN : mapofInboundMessage.keySet() WITH SECURITY_ENFORCED]){
                logEntryMsg+='\n***CAG record found for deactivation: '+cag+' ***';
                
                /*if(mapOfAccIdOPID.get(cag.Core_Intel_Account_Id__c) ==  cag.Core_Partner_Account_Id__r.Core_OnePartnerID__c){
cag.Core_Inactive_Ind__c = true;
cagsToUpdate.add(cag);
opidInboundMsgMap.put(cag.Core_Partner_Account_Id__c, mapofInboundMessage.get(cag.Core_Intel_Account_Id__c));
}*/        
                mapOfSfIdCAG.put(cag.Core_Intel_Account_Id__c, cag);
                
            }
            logEntryMsg+='\n***Map of CAG for SF Acc Id as key: '+mapOfSfIdCAG+' ***';
            logEntryMsg+='\n***Looping on inbound msgs to process CAG***';
            Core_Account_Group_Member__c cagToProcess;
            List<Core_OnePartner_Inbound_Message__c> discardedInbMsgList;
            Set<Account> listOfUpdateAccount = new Set<Account>();
            Set<ID> accountIdPAG = new Set<ID>();
            Id delinkAssociationUser;// TWC729-6959 delinking
            //For each sfid, get all the detachment records and check for corresponding CAG, if no CAG found then it should be discarded
            for(String sfId: mapofInboundMessage.keySet()){
                inbMsgList = mapofInboundMessage.get(sfId);
                cagToProcess = mapOfSfIdCAG.get(sfId);
                logEntryMsg+='\n***CAG to be processed: '+cagToProcess+' ***';
                for(Core_OnePartner_Inbound_Message__c inboundMsg: inbMsgList){
                    //No CAG found, discard the record
                    if(cagToProcess == null){
                        if (inbMsgsToDiscard.containsKey(inboundMsg.Core_SalesCloud_AccountID__c)){
                            discardedInbMsgList = inbMsgsToDiscard.get(inboundMsg.Core_SalesCloud_AccountID__c);  
                            
                        }else{
                            discardedInbMsgList = new List<Core_OnePartner_Inbound_Message__c>();
                        }    
                        discardedInbMsgList.add(inboundMsg);
                        inbMsgsToDiscard.put(inboundMsg.Core_SalesCloud_AccountID__c,discardedInbMsgList);
                        logEntryMsg+='\n***Discarding inbound msg with id: '+ inboundMsg.id+' as no CAG found for intel acc'+inboundMsg.Core_SalesCloud_AccountID__c+' ***';
                        //CAG is found and the acc id, OPID mapping matches, inactivate the CAG as it is for detachment and add to list to update later
                        //UTKARSH - TWC727-102 - Added relationship start date check in else if to filter out old opid data.
                    }else if((inboundMsg.Core_OnePartnerID__c != null && String.IsNotBlanK(cagToProcess.Core_Partner_Account_Id__r.Core_OnePartnerID__c) && cagToProcess.Core_Partner_Account_Id__r.Core_OnePartnerID__c.equals(String.valueOf(inboundMsg.Core_OnePartnerID__c.intValue())) && (inboundMsg.Core_Status_Effective_End_Date_Time__c != null || cagToProcess.PRM_RelationshipStartDate__c == null || cagToProcess.PRM_RelationshipStartDate__c < inboundMsg.Core_Effective_End_Date_Time__c))){
                        cagToProcess.Core_Inactive_Ind__c = true;
                        cagToProcess.PRM_RelationshipEndDate__c = inboundMsg.Core_Effective_End_Date_Time__c;
                        cagToProcess.Comments__c=inboundMsg.Comments__c; //TWC729-6959 delinking 
                        
                        //For OPID Account Deactivation
                        if(inboundMsg.Core_Status_Effective_End_Date_Time__c  != null)
                        {
                            cagToProcess.Core_Partner_Account_Id__r.Core_Deactivated__c = true;
                            delinkAssociationUser = inboundMsg.Delink_Association_User__c;// TWC729-6959 delinking
                            cagToProcess.Core_Partner_Account_Id__r.Core_Deactivation_Reason__c ='Deactivated as part of OPID Deactivation '+System.now();//// TWC729-6959 delinking
                            cagToProcess.Core_Partner_Account_Id__r.UCD_Primary_Account__c = null;//TWC729-6959 delinking
                            cagToProcess.Core_Partner_Account_Id__r.Exception_Comments__c = inboundMsg.Comments__c;// TWC729-6959 delinking
                            cagToProcess.Delink_Association_User__c = inboundMsg.Delink_Association_User__c;// TWC729-6959 delinking
                            accountIdPAG.add(cagToProcess.Core_Partner_Account_Id__c);
                            listOfUpdateAccount.add(cagToProcess.Core_Partner_Account_Id__r);
                            accOpid.add(String.valueOf((inboundMsg.Core_OnePartnerID__c.intValue())));
                            logEntryMsg+='\n***OPID IS deactivated with end date: '+inboundMsg.Core_Status_Effective_End_Date_Time__c;
                        }
                        cagsSetToUpdate.add(cagToProcess);
                        logEntryMsg+='\n***Inactivating CAG with id: '+cagToProcess.id+' ***';
                        //CAG found for same sfid, but OPID in inbound msg is different, add to discard list as no CAG for same mapping, each sfid will always have only one record
                    }else{
                        if (inbMsgsToDiscard.containsKey(inboundMsg.Core_SalesCloud_AccountID__c)){
                            discardedInbMsgList = inbMsgsToDiscard.get(inboundMsg.Core_SalesCloud_AccountID__c);          
                        }else{
                            discardedInbMsgList = new List<Core_OnePartner_Inbound_Message__c>();
                        }    
                        if(String.IsBlanK(cagToProcess.Core_Partner_Account_Id__r.Core_OnePartnerID__c)){
                            inboundMsg.Error_Description__c = System.label.PRM_NoOPID_On_PAG_Error;
                            logEntryMsg+='\nInbound message with Id:'+inboundMsg.Id+' failed due to '+System.label.PRM_NoOPID_On_PAG_Error;
                        }
                        else if(cagToProcess.PRM_RelationshipStartDate__c > inboundMsg.Core_Effective_End_Date_Time__c){
                            inboundMsg.Core_Status__c = System.Label.PRM_INBOUNDMSG_PROCESS_FAILED;
                            inboundMsg.Error_Description__c = System.label.PRM_OPIDErrorMsg;
                            logEntryMsg+='\nInbound message with Id:'+inboundMsg.Id+' failed due to '+System.label.PRM_OPIDErrorMsg;
                        }else{
                            logEntryMsg+='\nInbound message with Id:'+inboundMsg.Id+' discarded as OPID value on Parent Acc on CAG record is different';
                        }
                        if(!discardedInbMsgList.contains(inboundMsg)){                          
                        discardedInbMsgList.add(inboundMsg);
                        }
                        inbMsgsToDiscard.put(inboundMsg.Core_SalesCloud_AccountID__c,discardedInbMsgList);
                    }        
                }
                
            }

            //map<String,List<Core_Account_Group_Member__c>> allCAGmap = new  map<String,List<Core_Account_Group_Member__c>>();
            //List<Core_Account_Group_Member__c> cagList;
            //ToInactivate Benefits associated with OPID
            List<PRM_AccountBenefitAssociation__c> updateBenefitList = new  List<PRM_AccountBenefitAssociation__c>();
            for(PRM_AccountBenefitAssociation__c aba : [Select Id,Name,PRM_Account_Id__c,PRM_Partner_Benefit_Id__c,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accountIdPAG]){
                aba.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;    
                aba.PRM_Status_Reason_Txt__c = System.Label.PRM_ABA_INACTIVE_STATUS;   
                updateBenefitList.add(aba);                    
            }
            if((updateBenefitList != null && !updateBenefitList.IsEmpty())){
                //To skip the MP benefit validation
                PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = true;
                Database.update(updateBenefitList,false);
            }

            //  AIA Start
            
                List<PRM_IPA_Affiliation__c> updateIpaAffiliation = new List<PRM_IPA_Affiliation__c>();
                Set<PRM_IPA_Affiliation__c> affiliationToInactivate = new Set<PRM_IPA_Affiliation__c>();
                Map<String,Set<PRM_IPA_Affiliation__c>> opidIpaAffiliation = getIPAAffiliation(null,accountIdPAG);
                
                for(String acc: opidIpaAffiliation.keySet()){
                    affiliationToInactivate.addAll(opidIpaAffiliation.get(acc));
                }
                for(PRM_IPA_Affiliation__c aia: affiliationToInactivate){
                    aia.PRM_Active__c = false;
                    aia.PRM_Notes__c='Roll down from 1PID';//TWC729-8089 : Adding reason text : NJ
                    updateIpaAffiliation.add(aia);
                }
                Database.UpsertResult[] aiaErrorHandle = null;
                if(updateIpaAffiliation.size()>0){
                    aiaErrorHandle = Database.upsert(updateIpaAffiliation,false);
                    logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(updateIpaAffiliation, aiaErrorHandle,'PRM_IPA_Affiliation__c');
                    aiaMapError = PRM_OPIDProcessUtility.getErrorMessageForAIAupsert(updateIpaAffiliation,aiaErrorHandle);
                    errorWrapper.putAIAError(aiaMapError);
                }
            //}
            //  AIA End
            
                        
            //To inactivate all the location accouts associated with inactive OPID
            for(Core_Account_Group_Member__c cag : [Select Id, Core_Inactive_Ind__c,Core_Intel_Account_Id__c,PRM_RelationshipStartDate__c,PRM_RelationshipEndDate__c, Core_Partner_Account_Id__r.Core_OnePartnerID__c,
            Delink_Association_User__c from Core_Account_Group_Member__c where Core_Inactive_Ind__c = false and Core_Partner_Account_Id__r.Core_OnePartnerID__c IN:accOpid and Id NOT in:cagsSetToUpdate])
            {
                cag.Core_Inactive_Ind__c = true;
                cag.Delink_Association_User__c = delinkAssociationUser;// TWC729-6959 delinking
                cagsSetToUpdate.add(cag);
            }
            accToUpdate.addAll(listOfUpdateAccount);
            set<Id> accOpidSuccess=new set<Id>();
            Database.UpsertResult[] opidnewAcc = null;
            if(accToUpdate.size() > 0){
                opidnewAcc = Database.upsert(accToUpdate,false);
                    for(Database.upsertResult result:opidnewAcc) {
                        if (result.isSuccess() ){
                            accOpidSuccess.add(result.getId());
                    }
                }    
                logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(accToUpdate, opidnewAcc, 'Account');
            }
            
            cagsToUpdate.addAll(cagsSetToUpdate);
            Database.SaveResult[] cagErrorHandle = null;
            list<Core_Account_Group_Member__c> cagsToUpdateUponOPID=new list<Core_Account_Group_Member__c>();
            if(cagsToUpdate.size() > 0){
                //update cagsToUpdate;             
                cagErrorHandle = Database.update(cagsToUpdate,false);   
                logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(cagsToUpdate, cagErrorHandle,'Core_Account_Group_Member__c');
                cagMapError = PRM_OPIDProcessUtility.getErrorMessageForCAG(cagsToUpdate, cagErrorHandle);
                errorWrapper.putCAGError(cagMapError);
                Integer recordid = 0;//US821813
                Set<String> succssPAGInactiveSet =new Set<String>(); //US821813
                for(Database.SaveResult sr : cagErrorHandle) {//US821813
                    if (sr.isSuccess()) { //US821813:
                        String accIdOPID =(String)(cagsToUpdate[recordid].Core_Intel_Account_Id__c+';'+cagsToUpdate[recordid].Core_Partner_Account_Id__c);
                        succssPAGInactiveSet.add(accIdOPID);//US821813
                    }
                    recordid++;
                }//loop end here
                try {
                    if(succssPAGInactiveSet.size()>0){
                       logEntryMsg+=updateVXRecommendationAndVXData(succssPAGInactiveSet); //US821813: Calling method for VX Data/Recommendation . 
                    }
                    
                }
                catch(Exception e){
                    logEntryMsg+='***EXCEPTION OCCURED***Error :'+e+'***';
                }
                
                
            }
        }
        //Error handling
        errLogForProcInMessage(errorWrapper); 
        logEntryMsg+='\n*****inactivateCoreAccGrpMembers Method End here...******';
        logEntryMsgList.add(logEntryMsg);
        return inbMsgsToDiscard;
    }
    
    /*US821813: OPID upgrade recommendation record removal from recommendation table - detachment of location account from OPID.
* Created by : Srishty Sharma
* Date : 26oct 2020
* Description : This method will recieve list of inactivated PAG record and will VX recommendation on the basis of OPID+AccId inactivated record combination.
* In VX Data , from record OPID will be removed and other location account for same OPID will also be removed from VX recommendation object and
* thier coresponding VX Data record will be updated with current date in Changed Date field.  
*/        
    public static String updateVXRecommendationAndVXData(Set<String> succssPAGInactiveSet){
        String logEntryMsg='';
        logEntryMsg+='\n********updateVXRecommendationAndVXData Method Start Here**********';
        List<PRM_Value_Exchange_Recommendation__c> vxRecommendationDeleteList =new List<PRM_Value_Exchange_Recommendation__c>(); //TWC729-6800 EOL activities
        List<PRM_Value_Exchange_Data__c> vxDataUpdateList =new List<PRM_Value_Exchange_Data__c>();
        Set<Id> opidSet =new Set<Id>();//set of OPID as part of inactive PAG  
        Set<Id> accIdSet =new Set<Id>();//set of AccId as part of inactive PAG 
        
        for(String accIdOPID:succssPAGInactiveSet){
            Id accId =(Id)accIdOPID.split(';')[0];
            Id opid =(Id)accIdOPID.split(';')[1];
            accIdSet.add(accId);
            opidSet.add(opid);
        }
        for(PRM_Value_Exchange_Data__c vxData :[Select Id,PRM_Account_Id__c,PRM_One_Partner_Id__c from PRM_Value_Exchange_Data__c where PRM_One_Partner_Id__c IN :opidSet OR PRM_Account_Id__c IN:accIdSet Order by PRM_One_Partner_Id__c ]){
            String accIdOPID =(String)(vxData.PRM_Account_Id__c+';'+vxData.PRM_One_Partner_Id__c);
            if(succssPAGInactiveSet.contains(accIdOPID)){
                vxData.PRM_One_Partner_Id__c=null;
                vxDataUpdateList.add(vxData);//Adding VX Data with same cobination of ACC and OPID whose PAG got inactive and updating OPID field as null
            }
            else if(opidSet.contains(vxData.PRM_One_Partner_Id__c) && !succssPAGInactiveSet.contains(accIdOPID)){
                vxData.PRM_Change_Date_Dt__c=System.now();
                vxDataUpdateList.add(vxData);//updating vx data with current change date for those OPID whose PAG is inactive and VX recommrndation deleted. 
            }
        }//loop ends here
        if(!vxDataUpdateList.isEmpty()){
            logEntryMsg+='\n***ValueExchangeData update List on the basis of dissociation of Account from OPID Account'+vxDataUpdateList+'***';
            update vxDataUpdateList;//Updating VX Data on the basis of combination of OPID and Accuont ID which got dissocaited.
        }
        logEntryMsg+='\n********updateVXRecommendationAndVXData Method Ends Here**********';
        return logEntryMsg;
     }
    
    
    //Rollup related to Segments
    public String rollupSpecialityAssociation(String parentId,PRM_OPIDErrorWrapper errorWrapper){
        String logEntryMsg='';
        logEntryMsg+='\n*********rollupSpecialityAssociation Method Start here..********';
        logEntryMsg+='\n***OPID AccID :'+parentId+' ***';
        //List<Core_Account_Group_Member__c> listOfCAG = [SELECT Core_Partner_Account_Id__c,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c  FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c in :accIds and Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true and Core_Inactive_Ind__c = false WITH SECURITY_ENFORCED]; 
        List<Core_Account_Group_Member__c> listOfCAG = mapOfParentIdCAGs.get(parentId);
        if(listOfCAG != null && listOfCAG.size() > 0){
            Map<String,Set<String>> mapOfParentChild = new Map<String,Set<String>>();
            Set<String> setOfAccIDs = new Set<String>();
            for(Core_Account_Group_Member__c cagObj : listOfCAG){
                setOfAccIDs.add(cagObj.Core_Partner_Account_Id__c);
                setOfAccIDs.add(cagObj.Core_Intel_Account_Id__c);
                Set<String> setOfChild = mapOfParentChild.get(cagObj.Core_Partner_Account_Id__c);
                if(setOfChild != null){
                    setOfChild.add(cagObj.Core_Intel_Account_Id__c);
                }else{
                   setOfChild = new Set<String>();
                    setOfChild.add(cagObj.Core_Intel_Account_Id__c);
                    mapOfParentChild.put(cagObj.Core_Partner_Account_Id__c,setOfChild);
                }
            }
            
            //List of segments associated  with AccountIDs
            Map<String,Set<String>> mapOfSegmentsForAcc = new Map<String,Set<String>>();
            Map<String,List<PRM_Account_Specialty_Association__c>> mapOfParentSeg = new Map<String,List<PRM_Account_Specialty_Association__c>>();
            if(setOfAccIDs.size() > 0){
                //List<PRM_Account_Specialty_Association__c> listOfASAs = [select PRM_Specialty_Id__c, PRM_Account_Id__c, PRM_InActive_Ind__c,PRM_Partner_Role__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__c in :setOfAccIDs WITH SECURITY_ENFORCED];
                List<PRM_Account_Specialty_Association__c> listOfASAs = mapOfParentIdASAs.get(parentId);
                                            /*if(listOfASAs != null  && (!ipaRefresh || test.isrunningtest())){ //IPA2.0-TWC727-2861
                    for(PRM_Account_Specialty_Association__c asaObj : listOfASAs){
                        String acctId = asaObj.PRM_Account_Id__c;
                        
                        if(mapOfParentChild.containsKey(acctId)){
                            List<PRM_Account_Specialty_Association__c> setOfSegment = mapOfParentSeg.get(acctId);
                            if(setOfSegment != null && setOfSegment.size() > 0){
                                setOfSegment.add(asaObj);
                            }else{
                                setOfSegment = new List<PRM_Account_Specialty_Association__c>();
                                setOfSegment.add(asaObj);
                                mapOfParentSeg.put(asaObj.PRM_Account_Id__c,setOfSegment);
                            }
                        }else{
                            if(!asaObj.PRM_InActive_Ind__c){
                                Set<String> setOfSegment = mapOfSegmentsForAcc.get(acctId);
                                if(setOfSegment != null && setOfSegment.size() > 0){
                                    setOfSegment.add(asaObj.PRM_Specialty_Id__c+'-'+asaObj.PRM_Partner_Role__c);
                                }else{
                                    setOfSegment = new Set<String>();
                                    setOfSegment.add(asaObj.PRM_Specialty_Id__c+'-'+asaObj.PRM_Partner_Role__c);
                                    mapOfSegmentsForAcc.put(asaObj.PRM_Account_Id__c,setOfSegment);
                                } 
                            }
                        }
                    }
                } */ // IPA Switch Removal
            }            
            if(!mapOfParentChild.isEmpty() && !mapOfSegmentsForAcc.isEmpty()){
              logEntryMsg+=updateOrCreateSegementAtOPID(mapOfParentChild,mapOfParentSeg,mapOfSegmentsForAcc,errorWrapper);
            }           
        }
        logEntryMsg+='\n*********rollupSpecialityAssociation Method Ends here..********';
        return logEntryMsg;
    }
    
    
    private String updateOrCreateSegementAtOPID(Map<String,Set<String>> mapOfParentChild,Map<String,List<PRM_Account_Specialty_Association__c>> mapOfParentSeg,Map<String,Set<String>> mapOfSegmentsForAcc,PRM_OPIDErrorWrapper errorWrapper){
        // List<PRM_Account_Specialty_Association__c> listOfObjectToUpdate = new List<PRM_Account_Specialty_Association__c>();
        String logEntryMsg='';
        logEntryMsg+='\n***Entered update / creation of OPID Segment Method***';
        List<String> logEntryMsgList =new List<String>();
        for(String parentId : mapOfParentChild.keySet()){
            List<PRM_Account_Specialty_Association__c> parentSegments = mapOfParentSeg.get(parentId);
            Set<String> setOfChild = mapOfParentChild.get(parentId);
            Set<String> distinctSegmentForParent = getDistinctSegmentForParent(setOfChild,mapOfSegmentsForAcc);
            listOfObjectToUpdate.addAll(updateSegmentDetailsAtOPID(parentId,parentSegments,distinctSegmentForParent,logEntryMsgList));
            if(logEntryMsgList.size()>0){
               logEntryMsg+= logEntryMsgList[0];
            }
        }
        
        /* Database.UpsertResult[] asaErrorHandle = null;
if(listOfObjectToUpdate.size() > 0){
//upsert listOfObjectToUpdate;
asaErrorHandle = Database.upsert(listOfObjectToUpdate,false);
asaMapError = PRM_OPIDProcessUtility.getErrorMessageForASAupsert(listOfObjectToUpdate,asaErrorHandle);
errorWrapper.putASAError(asaMapError);
} */
        logEntryMsg+='\n***Exit update/creation of OPID Segment Method***';
        return logEntryMsg;
    }
    
    public Set<String> getDistinctSegmentForParent(Set<String> setOfChild,Map<String,Set<String>> mapOfSegmentsForAcc){
        Set<String> uniqueSegments = new Set<String>();
        for(String childID : setOfChild){
            Set<String> childsegment = mapOfSegmentsForAcc.get(childID);
            if(childsegment != null){
                uniqueSegments.addAll(childsegment); 
            }
        }        
        return uniqueSegments;
    }
    
    private List<PRM_Account_Specialty_Association__c> updateSegmentDetailsAtOPID(String parentId,List<PRM_Account_Specialty_Association__c> parentSegments, Set<String> distinctSegmentForParent,List<String>logEntryMsgList){
        String logEntryMsg='';
        List<PRM_Account_Specialty_Association__c> listOfASAObject = new List<PRM_Account_Specialty_Association__c>();
        Set<String> prntSegmentSet = new Set<String>();
        
        
        //Inactive opertion for exisiting Segment for OPID
                                   /* if(parentSegments != null && (!ipaRefresh || test.isrunningtest())){ //IPA2.0-TWC727-2861
            for(PRM_Account_Specialty_Association__c asaObj : parentSegments){
                logEntryMsg+='\n*********ASA found on OPID Account for partner role: '+ asaObj.PRM_Partner_Role__c + ' & Speciality: '+asaObj.PRM_Specialty_Id__c+ ' ***';
                String segmentId = asaObj.PRM_Specialty_Id__c;
                String partnerRole = asaObj.PRM_Partner_Role__c;
                String segPartnerRole = segmentId + '-' + partnerRole;
                prntSegmentSet.add(segPartnerRole);
                                            if(distinctSegmentForParent.add(segPartnerRole)){ // //Specialty issue fix - TWC729 - 8038
                    logEntryMsg+='\n*********Inactivating ASA on OPID Account for partner role: '+ asaObj.PRM_Partner_Role__c + ' & Speciality: '+asaObj.PRM_Specialty_Id__c+ ' as no ASA found on child account***';
                    asaObj.PRM_InActive_Ind__c = true; 
                    asaObj.PRM_Status_Reason_Txt__c = System.Label.PRM_ASA_Inactive_StatReason;//'ASA inactivated as part of OPID process';
                }else{
                    if(asaObj.PRM_InActive_Ind__c){
                        logEntryMsg+='\n*********Activating ASA on OPID Account for partner role: '+ asaObj.PRM_Partner_Role__c + ' & Speciality: '+asaObj.PRM_Specialty_Id__c+ '***';
                        asaObj.PRM_InActive_Ind__c = false; 
                        asaObj.PRM_Status_Reason_Txt__c = System.Label.PRM_ASA_active_StatReason;//'ASA added as part of OPID process';
                    }
                }
                listOfASAObject.add(asaObj);
            }
        }  */ // IPA Switch Removal     
        // Add new segment at OPID level
        for(String segPartnerRole : distinctSegmentForParent){
            String segmentId = segPartnerRole.left(segPartnerRole.indexOf('-'));
            String partnerRole = segPartnerRole.right(segPartnerRole.length() - segPartnerRole.indexOf('-') - 1);
                                     /*  if(prntSegmentSet.add(segPartnerRole) && (!ipaRefresh || test.isrunningtest())){// IPA2.0-TWC727-2861
                
                PRM_Account_Specialty_Association__c asaObj = new PRM_Account_Specialty_Association__c();
                asaObj.PRM_Account_Id__c = parentId;
                asaObj.PRM_Specialty_Id__c = segmentId;
                asaObj.PRM_Partner_Role__c = partnerRole;
                asaObj.PRM_Status_Reason_Txt__c = System.Label.PRM_ASA_active_StatReason;//'ASA added as part of OPID process';
                logEntryMsg+='\n****Creating ASA on OPID Account for partner role: '+ asaObj.PRM_Partner_Role__c + ' & Speciality: '+segmentId+ '***';
                listOfASAObject.add(asaObj);
            } */ // IPA Switch Removal
        }
        logEntryMsgList.add(logEntryMsg);
        return listOfASAObject;
    }
    
    
    
    
    public void errLogForProcInMessage(PRM_OPIDErrorWrapper errorWrapper){
        String logEntryMsg;
        try{
            pagAccountMapError= errorWrapper.getPAGError();
            asaMapError = errorWrapper.getASAError();
            acmMapError = errorWrapper.getACMError();
            cagMapError = errorWrapper.getCAGError();
            aiaMapError = errorWrapper.getAIAError();
                
            for(Core_OnePartner_Inbound_Message__c inboundMessage : updatedList){            
                inboundMessage.Core_Status__c = System.Label.PRM_INBOUNDMSG_PROCESSED;
                String opIDvalue = String.valueOf(inboundMessage.Core_OnePartnerID__c.intValue());
                String intelAccId = inboundMessage.Core_SalesCloud_AccountID__c;
            
                if(pagAccountMapError != null  && pagAccountMapError.containsKey(opIDvalue)){
                    inboundMessage.Core_Status__c = System.Label.PRM_POST_PROCESSING_FAILED;
                    inboundMessage.Error_Description__c = pagAccountMapError.get(opIDvalue);
                    pagAccountMapError.remove(opIDvalue);
                }
                //Update Error status
                updateErrorStatus(inboundMessage,opIDvalue);
                
            }
                
            //Verification for each error list to fetch any leftout SalesforceAccount to report the error
            Set<String> setOfPagIntelAccount = new Set<String>();
            if(!asaMapError.isEmpty()){
                setOfPagIntelAccount.addAll(asaMapError.keySet());
            }else if(!acmMapError.isEmpty()){
                setOfPagIntelAccount.addAll(acmMapError.keySet());
            }else if(!cagMapError.isEmpty()){
                setOfPagIntelAccount.addAll(cagMapError.keySet());
            }else if(!aiaMapError.isEMpty()){
                setOfPagIntelAccount.addAll(aiaMapError.keySet());
            }
            
            //Error handling for those Inbound message for PAG account, which are failed process during ACM, ASA and CAG update.
            if(setOfPagIntelAccount != null && !setOfPagIntelAccount.isEmpty()){
                Map<String,String> mapOfOpids = getPagAccountDetails(setOfPagIntelAccount);
                if(mapOfOpids != null && !mapOfOpids.isEmpty()){
                    for(Core_OnePartner_Inbound_Message__c inboundMessage : updatedList){
                        String opIDvalue = String.valueOf(inboundMessage.Core_OnePartnerID__c.intValue());                
                        if(mapOfOpids.containsKey(opIDvalue)){
                            String intelAccount = mapOfOpids.get(opIDvalue);
                            updateErrorStatus(inboundMessage, intelAccount);
                        }
                    }
                }
            }
                
            //Update error message at InboundMessage level
            if(updatedList != null && !updatedList.isEmpty()){
                    integer index = 0;
                    List<PRM_Tracker__c> trackerList= new List<PRM_Tracker__c>();
                    List<Database.SaveResult> saveResultList = Database.update(updatedList, false);
                    logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(updatedList, saveResultList,'Core_OnePartner_Inbound_Message__c');
                    //Set<Core_OnePartner_Inbound_Message__c> tempSet = new Set<Core_OnePartner_Inbound_Message__c>();
                    for(Database.SaveResult result: saveResultList){
                        if(result.isSuccess()){
                            Core_OnePartner_Inbound_Message__c recordFromList=updatedList.get(index);
                            if(recordFromList.Core_SalesCloud_AccountID__c!=null && recordFromList.Core_Status__c!=System.Label.PRM_INBOUNDMSG_PROCESSED){
                                PRM_Tracker__c tracker = new PRM_Tracker__c();
                                tracker.PRM_Type__c = 'OPID Updates';
                                tracker.PRM_Location_Account__c = recordFromList.Core_SalesCloud_AccountID__c;
                                tracker.PRM_Completed__c = false;
                                if((recordFromList.Core_Effective_End_Date_Time__c != null && recordFromList.Core_Effective_End_Date_Time__c.date() <= Date.Today()) || recordFromList.Core_Status_Effective_End_Date_Time__c != null){
                                    tracker.PRM_Milestone__c = 'DLK_INBND_POST_FLD';
                                    tracker.PRM_Milestone_Display_Name__c ='OPID Delink Post Processing Failed';
                                }else{
                                    tracker.PRM_Milestone__c = 'INBND_POST_FLD';
                                    tracker.PRM_Milestone_Display_Name__c ='OPID Creation/Association Post Processing Failed';
                                }
                                trackerList.add(tracker);
                            }
                        }
                        index++;
                    }
                    if (!trackerList.isEmpty()) {
                        List<Database.SaveResult> insertTrackerResult = new List<Database.SaveResult>();
                        insertTrackerResult = Database.insert(trackerList,false);
                        logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(trackerList, insertTrackerResult,'PRM_Tracker__c');
                    }
                //}
            }
        }catch(Exception ex){
            logEntryMsg+=ex.getMessage();
        }
        finally{
            Core_Log_Entry.logEntryWithDetails('OPID Inbound Batch', 'IPA','OPID Inbound Batch','Medium','',logEntryMsg ,'', '', '');
        }
    }
    
    @TestVisible
    private Map<String,String> getPagAccountDetails(Set<String> setOfPagIntelAcc){
        Id pagRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        List<Account> listOfPAGAcc = [select id,Core_OnePartnerID__c from Account where id in :setOfPagIntelAcc and recordtypeid =:pagRecordType WITH SECURITY_ENFORCED];
        Map<String,String> mapOfOPIDs = new Map<String,String>();
        if(listOfPAGAcc != null){
            for(Account acc : listOfPAGAcc){
                mapOfOPIDs.put(acc.Core_OnePartnerID__c,acc.id);
            }
        }
        return mapOfOPIDs;
    }
    
    private void updateErrorStatus(Core_OnePartner_Inbound_Message__c inboundMessage, String intelAccId){
        if(asaMapError != null && asaMapError.containsKey(intelAccId)){
            inboundMessage.Core_Status__c = System.Label.PRM_POST_PROCESSING_FAILED;
            inboundMessage.Error_Description__c = asaMapError.get(intelAccId);
        }
        
        if(acmMapError != null && acmMapError.containsKey(intelAccId)){
            inboundMessage.Core_Status__c = System.Label.PRM_POST_PROCESSING_FAILED;
            inboundMessage.Error_Description__c = acmMapError.get(intelAccId);
        }
        
        /*  if(abaMapError != null && abaMapError.containsKey(intelAccId)){
inboundMessage.Core_Status__c = System.Label.PRM_POST_PROCESSING_FAILED;
inboundMessage.Error_Description__c = abaMapError.get(intelAccId);
} */
        
        if(cagMapError != null && cagMapError.containsKey(intelAccId)){
            inboundMessage.Core_Status__c = System.Label.PRM_POST_PROCESSING_FAILED;
            inboundMessage.Error_Description__c = cagMapError.get(intelAccId);
        }

        if(aiaMapError != null && aiaMapError.containsKey(intelAccId)){
            inboundMessage.Core_Status__c = System.Label.PRM_POST_PROCESSING_FAILED;
            inboundMessage.Error_Description__c = aiaMapError.get(intelAccId);
        }
    }
    
    
    public String inactivateBenefitAsPerACM(Set<String> setOfOPIDAcc){
        String logEntryMsg='';
        logEntryMsg+='\n*****inactivateBenefitAsPerACM Method Start here...******';
        String pagRecordId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Map<String, List<PRM_AccountChannelMembership__c>> mapOfParentACMs = new Map<String, List<PRM_AccountChannelMembership__c>>();
        //Map<String, List<PRM_AccountBenefitAssociation__c>> mapOfABAAtParents = new Map<String, List<PRM_AccountBenefitAssociation__c>>();
        Map<String,String> mapOfPtnrRoleTier = new Map<String,String>(); 
        // Map<String,Core_OnePartner_Inbound_Message__c> opidAcc = new Map<String,Core_OnePartner_Inbound_Message__c>();
        //Set<String> setOfOPID = new Set<String>();
        
        // for(Core_OnePartner_Inbound_Message__c inboundMsg : listOfCAGAccRemoved){
        //     setOfOPID.add(String.valueOf(inboundMsg.Core_OnePartnerID__c.intValue()));
        // }
        
        //List<Account> listOfOPIDAcc = [Select Id, name, Core_OnePartnerID__c from Account where Core_OnePartnerID__c in :setOfOPID and RecordTypeId = :pagRecordId WITH SECURITY_ENFORCED];        
        // for(Account acc : listOfOPIDAcc){
        //     for(Core_OnePartner_Inbound_Message__c inboundMsg : listOfCAGAccRemoved){
        //         String opId = String.valueOf(inboundMsg.Core_OnePartnerID__c.intValue());
        //         if(acc.Core_OnePartnerID__c == opId){
        //             opidAcc.put(acc.id,inboundMsg);
        //         }
        //     }            
        // }
        // Inactive ACMs
        List<PRM_AccountChannelMembership__c> listOfInactiveACM = [select id, PRM_Account_Id__c, PRM_Partner_Role__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c, PRM_Channel_Program_Level_Id__r.name, PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :setOfOPIDAcc WITH SECURITY_ENFORCED]; 
        Set<String> setOfPartnerRole = new Set<String>();
        for(PRM_AccountChannelMembership__c acm : listOfInactiveACM){
            if(mapOfParentACMs.containskey(acm.PRM_Account_Id__c)){
                mapOfParentACMs.get(acm.PRM_Account_Id__c).add(acm);
                setOfPartnerRole.add(acm.PRM_Partner_Role__c);
            }else{
                List<PRM_AccountChannelMembership__c> newAcm = new List<PRM_AccountChannelMembership__c>();
                newAcm.add(acm);
                mapOfParentACMs.put(acm.PRM_Account_Id__c,newAcm);
                setOfPartnerRole.add(acm.PRM_Partner_Role__c);
            }
        }
        // if(mapOfParentACMs.size() > 0){
        //     //Active ABA
        //     List<PRM_AccountBenefitAssociation__c> listOfBenefits = [SELECT Id, PRM_Account_Id__c, PRM_Partner_Benefit_Id__c, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c  FROM PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in :mapOfParentACMs.keySet() WITH SECURITY_ENFORCED];
        //     for(PRM_AccountBenefitAssociation__c aba : listOfBenefits){
        //         if(mapOfABAAtParents.containskey(aba.PRM_Account_Id__c)){
        //             mapOfABAAtParents.get(aba.PRM_Account_Id__c).add(aba);
        //         }else{
        //             List<PRM_AccountBenefitAssociation__c> newAba = new List<PRM_AccountBenefitAssociation__c>();
        //             newAba.add(aba);
        //             mapOfABAAtParents.put(aba.PRM_Account_Id__c,newAba);
        //         }
        //     }
        // } 
        Map<String,Set<String>> actAccBenefitMtrx  = new Map<String,Set<String>>();
        Map<String,Set<String>> accBenefitMtrx = new Map<String,Set<String>>();
        Map<String,Integer> tierAndRankMap = new Map<String,Integer>{System.Label.PRM_Member => 1, System.Label.PRM_Tier_Gold => 2, System.Label.PRM_Tier_Titanium => 3};
        List<PRM_VXBnftMatrix__c> listOfAssBenefits = [SELECT Id, PRM_Partner_Benefit_Id__c, PRM_Partner_Role_Nm__c, PRM_Channel_Program_Level_Id__r.name,PRM_Channel_Program_Level_Id__c,PRM_IsActive_Ind__c FROM PRM_VXBnftMatrix__c where PRM_Partner_Role_Nm__c in :setOfPartnerRole and PRM_IsActive_Ind__c = true WITH SECURITY_ENFORCED];
        
        for(List<PRM_AccountChannelMembership__c> listOfACM : mapOfParentACMs.values()){
            //Approved ACM benefits map
            for(PRM_AccountChannelMembership__c acm : listOfACM){
                if(acm.PRM_Status_Nm__c=='Approved'){
                    for(PRM_VXBnftMatrix__c bnfMtx : listOfAssBenefits){
                        if(acm.PRM_Partner_Role__c.equals(bnfMtx.PRM_Partner_Role_Nm__c) && tierAndRankMap.get(acm.PRM_Channel_Program_Level_Id__r.name)  >  tierAndRankMap.get(bnfMtx.PRM_Channel_Program_Level_Id__r.name)   /*&& acm.PRM_Channel_Program_Level_Id__c.equals(bnfMtx.PRM_Channel_Program_Level_Id__c)*/){
                            if(actAccBenefitMtrx.containsKey(acm.PRM_Account_Id__c)){
                                actAccBenefitMtrx.get(acm.PRM_Account_Id__c).add(bnfMtx.PRM_Partner_Benefit_Id__c);
                            }else{
                                Set<String> beniftIDSet = new Set<String>();
                                beniftIDSet.add(bnfMtx.PRM_Partner_Benefit_Id__c);
                                actAccBenefitMtrx.put(acm.PRM_Account_Id__c,beniftIDSet);
                            }
                        }
                    }        
                }
            }
            
            for(PRM_AccountChannelMembership__c acm : listOfACM){
                if(acm.PRM_Status_Nm__c=='Inactive'){
                    for(PRM_VXBnftMatrix__c bnfMtx : listOfAssBenefits){
                        //TWC729-4151: Add null check for Partner role
                        if(acm.PRM_Partner_Role__c != null && acm.PRM_Partner_Role__c.equals(bnfMtx.PRM_Partner_Role_Nm__c) /*&& acm.PRM_Channel_Program_Level_Id__c.equals(bnfMtx.PRM_Channel_Program_Level_Id__c)*/){
                            Set<String> actBnftMtrx = actAccBenefitMtrx.get(acm.PRM_Account_Id__c);
                            
                            String validInactiveBnft = null;
                            if(actBnftMtrx != null && actBnftMtrx.size() > 0){
                                if(actBnftMtrx.add(bnfMtx.PRM_Partner_Benefit_Id__c)){
                                    validInactiveBnft = bnfMtx.PRM_Partner_Benefit_Id__c;
                                }
                            }else{
                                validInactiveBnft = bnfMtx.PRM_Partner_Benefit_Id__c;
                            }
                            
                            if(accBenefitMtrx.containsKey(acm.PRM_Account_Id__c)){
                                accBenefitMtrx.get(acm.PRM_Account_Id__c).add(validInactiveBnft);
                            }else{
                                Set<String> beniftIDSet = new Set<String>();
                                beniftIDSet.add(validInactiveBnft);
                                accBenefitMtrx.put(acm.PRM_Account_Id__c,beniftIDSet);
                            }
                        }
                    }
                }
            }            
        }
        
        // List<PRM_AccountBenefitAssociation__c> updatedBenfits = new List<PRM_AccountBenefitAssociation__c>();
        //Agate-TWC729-2470 Added logic to bypass the inactivation of market place benefits on OPID level
        //     String benefitnamesonUpdate = System.Label.IPA_Benefit_Validation_onUpdate;
        //     Set<String> benefitNamesUpdatetSet=new Set<String>();
        // for(String str: benefitnamesonUpdate.split(';')){
        //   benefitNamesUpdatetSet.add(str);
        // }
        //Agate-TWC729-2470-End
        List<PRM_AccountBenefitAssociation__c> listOfBenefits = [SELECT Id, PRM_Account_Id__c, PRM_Partner_Benefit_Id__c, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c,PRM_Source__c,PRM_Partner_Benefit_Id__r.name FROM PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in :accBenefitMtrx.keySet() WITH SECURITY_ENFORCED];  //Agate-TWC729-2470 Added PRM_Partner_Benefit_Id__r.name in the select Query
        for(PRM_AccountBenefitAssociation__c aba : listOfBenefits){
            //if(!benefitNamesUpdatetSet.contains(aba.PRM_Partner_Benefit_Id__r.name)){   //Agate-TWC729-2470
            Set<String> setOfbenefitIds = accBenefitMtrx.get(aba.PRM_Account_Id__c);            
            if(!setOfbenefitIds.add(aba.PRM_Partner_Benefit_Id__c)){
                //aba.PRM_Status_Nm__c = 'Inactive';
                //aba.PRM_Status_Reason_Txt__c = System.Label.PRM_ABA_INACTIVE_STATUS;
                if(aba.PRM_Source__c == System.Label.PRM_ProgramLevel){
                    aba.PRM_Source__c='';
                    aba.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                    aba.PRM_Status_Reason_Txt__c = System.Label.PRM_ABA_INACTIVE_STATUS;
                }else{
                    aba.PRM_Source__c= System.Label.PRM_Source_Specialty;
                }
                logEntryMsg+='\n***Inactive ABA :- '+aba+'***';
                updatedBenfits.add(aba);
                
            }
         //}  //Agate-TWC729-2470
        }
        Database.SaveResult[] abaErrorHandle = null;
        if(updatedBenfits.size() > 0){
            //update updatedBenfits ;   Commenting this as part of Agate-TWC729-2470
            PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = true;
            abaErrorHandle = Database.update(updatedBenfits,false);
            abaMapError = PRM_OPIDProcessUtility.getErrorMessageForABA(updatedBenfits,abaErrorHandle); 
            logEntryMsg+= PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(updatedBenfits, abaErrorHandle,'PRM_AccountBenefitAssociation__c');
        } 
        if(!abaMapError.isEmpty()){
            PRM_OPIDProcessUtility.updateABAErrorsInBoundTable(abaMapError,opidAcc);
        } 
        logEntryMsg+='\n*****inactivateBenefitAsPerACM Method Ends here...******';
        return logEntryMsg;//for log entries
    } 

    public static void assignBenefitsOnRollUp(Map<Id,PRM_AccountChannelMembership__c> updatedParentACMMap){
        if(updatedParentACMMap != null && !updatedParentACMMap.isempty()){
            //fetching the benefits can be assigned if the partner role on opid is member tier
            List<PRM_AccountBenefitAssociation__c> abaToInsertList = new List<PRM_AccountBenefitAssociation__c>();
            Map<String, List<PRM_VXBnftMatrix__c>> autoPartnerRolVxBftMat = new Map<String, List<PRM_VXBnftMatrix__c>>();
                                        String tier = 'Partner' ; //!iparefresh?'Member':'Partner' ;// IPA Switch Removal
                                        List<PRM_VXBnftMatrix__c> matrixRecords = [SELECT Id, 
                                            PRM_Channel_Program_Id__c,
                                            PRM_Channel_Program_Level_Id__r.Name, 
                                            PRM_Channel_Program_Level_Id__c,
                                            PRM_Approval_Type_Nm__c, 
                                            PRM_Partner_Benefit_Id__c,
                                            PRM_Partner_Benefit_Id__r.Name,
                                            PRM_Partner_Role_Nm__c,
                                            PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c 
                                            FROM PRM_VXBnftMatrix__c 
                                            WHERE PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance 
                                            AND PRM_IsActive_Ind__c = True 
                                            AND PRM_Channel_Program_Level_Id__r.Name = :tier
                                            AND PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group' 
                                            AND PRM_Approval_Type_Nm__c =: System.Label.PRM_ApprovalType];
                                        for(PRM_VXBnftMatrix__c vebm : matrixRecords){
                    if(autoPartnerRolVxBftMat.size()>0 && autoPartnerRolVxBftMat.containsKey(vebm.PRM_Partner_Role_Nm__c+'-'+vebm.PRM_Channel_Program_Level_Id__c)){
                        autoPartnerRolVxBftMat.get(vebm.PRM_Partner_Role_Nm__c+'-'+vebm.PRM_Channel_Program_Level_Id__c).add(vebm);
                    }else{
                        autoPartnerRolVxBftMat.put(vebm.PRM_Partner_Role_Nm__c+'-'+vebm.PRM_Channel_Program_Level_Id__c, new List<PRM_VXBnftMatrix__c>{vebm});
                    }
            }
            //fetching the existing aba on opid and storing in a map.
            Map<String,PRM_AccountBenefitAssociation__c> existingABAMap = new Map<String,PRM_AccountBenefitAssociation__c>();
            for(PRM_AccountBenefitAssociation__c abaRec : [select id,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c, PRM_Partner_Benefit_Id__c,PRM_Source__c,PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c  from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in: updatedParentACMMap.keyset()]){
                existingABAMap.put(abaRec.PRM_Partner_Benefit_Id__c+'-'+abaRec.PRM_Account_Id__c, abaRec);
            }
            //
            if(autoPartnerRolVxBftMat != null && !autoPartnerRolVxBftMat.isEmpty()){
                for(PRM_AccountChannelMembership__c acm : updatedParentACMMap.values()){
                    String key = acm.PRM_Partner_Role__c+'-'+acm.PRM_Channel_Program_Level_Id__c;
                    if(autoPartnerRolVxBftMat.containskey(key)){
                        for(PRM_VXBnftMatrix__c vebm : autoPartnerRolVxBftMat.get(key)){
                            if(!existingABAMap.containskey(vebm.PRM_Partner_Benefit_Id__c+'-'+acm.PRM_Account_Id__c)){
                                PRM_AccountBenefitAssociation__c aba  = new PRM_AccountBenefitAssociation__c();
                                aba.PRM_Account_Id__c = acm.PRM_Account_Id__c;
                                aba.PRM_Partner_Benefit_Id__c = vebm.PRM_Partner_Benefit_Id__c;
                                aba.PRM_Status_Nm__c = 'Active';
                                aba.PRM_Source__c ='Tier';
                                abaToInsertList.add(aba);
                            }
                            else{
                                if(existingABAMap.get(vebm.PRM_Partner_Benefit_Id__c+'-'+acm.PRM_Account_Id__c).PRM_Status_Nm__c == 'Inactive'){
                                    PRM_AccountBenefitAssociation__c aba  = existingABAMap.get(vebm.PRM_Partner_Benefit_Id__c+'-'+acm.PRM_Account_Id__c);
                                    aba.PRM_Status_Nm__c = 'Active';
                                    abaToInsertList.add(aba);
                                }
                            }
                        }
                    }
                }
                if(abaToInsertList != null && !abaToInsertList.isempty()){
                                                Database.upsert(abaToInsertList, false);
                }
            }
        }
    }   
    

    //method take account ids and checks if it has approved acm and no cags and creates parameter for createinboundrecord method
    public static void accountEligibleForOPID(Map<Id,Account> accForInbound,Boolean fromDQBatch,Map <Id,PRM_AccountChannelMembership__c> acmFromDQbatch){
        //IPA change to accomodate late Global BPid stamping
        List<String> accountIds = new List<String>();
        Map<Id,PRM_AccountChannelMembership__c> AcmWithOPIDCheckMap = new Map<Id,PRM_AccountChannelMembership__c>();
        Map<String,account> ucdNonGlblAccMap = new Map<String,account>();
        Map<Id,Id> accCagMap = new Map<Id,Id>();
        List<Core_OnePartner_Inbound_Message__c> listOfInboundOnePartner = new List<Core_OnePartner_Inbound_message__c>();
        Set<String> parentUcdSet= new Set<String>();
        Map<String,Core_Account_Group_Member__c> parentCagRec = new Map<String,Core_Account_Group_Member__c>();
        //query approved acm for the list of account ids
        if(accForInbound!=null && !accForInbound.isEmpty()){
            for(Account acc: accForInbound.values()){
                parentUcdSet.add(acc.Core_Parent_Business_Party_Id__c);
            }
            if(!fromDQBatch){
                List<PRM_AccountChannelMembership__c> acmList = [Select id,PRM_Account_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in: accForInbound.keySet() and PRM_Status_Nm__c='Approved'];
                for(PRM_AccountChannelMembership__c acm:acmList){
                    AcmWithOPIDCheckMap.put(acm.PRM_Account_Id__c,acm);
                }
            }else if(acmFromDQbatch!=null && !acmFromDQbatch.isEmpty()){
                AcmWithOPIDCheckMap.putAll(acmFromDQbatch);
            }
        }
        if(AcmWithOPIDCheckMap!=null && !AcmWithOPIDCheckMap.isEmpty()){
            //query active cags for the account ids
            List<Core_Account_Group_Member__c> cagList =[select id,Core_Intel_Account_Id__c,Core_Business_Party_Id__c ,Core_Partner_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Partner_Account_Id__r.Name from Core_Account_Group_Member__c where 
                                                        (Core_Intel_Account_Id__c in:AcmWithOPIDCheckMap.keyset() OR Core_Intel_account_Id__c in: parentUcdSet)
                                                        and Core_Intel_Account_Id__r.Core_Business_Party_Id__c != null  
                                                        and Core_Intel_Account_Id__r.Core_IPA_One_Partner_Id__c = null 
                                                        and Core_Intel_Account_Id__r.RecordType.name ='Intel Account' ];
            for(Core_Account_Group_Member__c cag: cagList){
                if(parentUcdSet.contains(cag.Core_Business_Party_Id__c)){
                    parentCagRec.put(cag.Core_Business_Party_Id__c,cag);
                }else{
                    accCagMap.put(cag.Core_Intel_Account_Id__c,cag.id);
                }
            }
        }
        //if active cag is not there then add to ucdNonGlblAccMap
        if(accCagMap!=null && !accCagMap.isEmpty()){
            for(String acc: accCagMap.keySet()){
                if(!accCagMap.containsKey(acc) && accForInbound.containsKey(acc) ){
                    ucdNonGlblAccMap.put(accForInbound.get(acc).Core_Business_Party_Id__c,accForInbound.get(acc));
                }
            }
        }
        if(ucdNonGlblAccMap!=null && !ucdNonGlblAccMap.isEmpty()){
            PRM_ACMTriggerHandlerNew.CreateInboundRecord(parentCagRec,ucdNonGlblAccMap,listOfInboundOnePartner,AcmWithOPIDCheckMap,null); // TWC729-6744 .- UCD                
        }  
    }
    
    //inbound creation if unified id stamped after acm
     @InvocableMethod(label='Create Inbound For OPID')
    public static void createInboundBasedUnifiedId(list<account> salesAcc){
	 Map<String,Core_Account_Group_Member__c> parentCagRec=new Map<String,Core_Account_Group_Member__c>();
	 Map<String,account> ucdNonGlblAccMap=new Map<String,account>();
	 Map<Id,PRM_AccountChannelMembership__c> AcmWithOPIDCheckMap=new  Map<Id,PRM_AccountChannelMembership__c>();
     list<Core_OnePartner_Inbound_Message__c> listOfInboundOnePartner =  new list<Core_OnePartner_Inbound_Message__c>();   
	 set<string> parentUcdSet=new set<string>();
     set<id> salesAccIds=new set<id>(); 
     Map<String,account> mapOfAccIdWithAcc=new Map<String,account>();
     for (account acc: salesAcc){
			salesAccIds.add(acc.id);
            parentUcdSet.add(acc.Core_Parent_Business_Party_Id__c);
            ucdNonGlblAccMap.put(acc.Core_Business_Party_Id__c,acc);
	}
     list<Core_Account_Group_Member__c> lstPagRecords =[SELECT Id,
                                                      Name,
                                                      Core_Partner_Account_Id__c, 
                                                      Core_Intel_Account_Id__c,
                                                      Core_Business_Party_Id__c,                        // TWC729-6744 UCD Change
                                                      Core_Partner_Account_Id__r.Core_OnePartnerID__c,  // TWC729-6744 UCD Change
                                                      Core_Partner_Account_Id__r.Name,                  // TWC729-6744 UCD Change
                                                      Core_Inactive_Ind__c 
                                                      FROM Core_Account_Group_Member__c 
                                               		  WHERE (Core_Intel_Account_Id__c in : salesAccIds 
                                                      or  Core_Business_Party_Id__c in: parentUcdSet) 
                                                      and Core_Inactive_Ind__c=false];
        
    for (Core_Account_Group_Member__c agm: lstPagRecords){
         if(parentUcdSet.contains(agm.Core_Business_Party_Id__c))  
            parentCagRec.put(agm.Core_Business_Party_Id__c,agm);
	 
    }
	for(PRM_AccountChannelMembership__c acm: [select PRM_Status_Nm__c, PRM_Account_Id__c from 
                                              PRM_AccountChannelMembership__c where PRM_Account_Id__c 
                                              in: salesAccIds and PRM_Status_Nm__c='Approved']){
		AcmWithOPIDCheckMap.put(acm.PRM_Account_Id__c,acm);
	}
	if(AcmWithOPIDCheckMap!=null && ucdNonGlblAccMap!=null)
	PRM_ACMTriggerHandlerNew.CreateInboundRecord(parentCagRec,ucdNonGlblAccMap,listOfInboundOnePartner,AcmWithOPIDCheckMap,null);
}
}