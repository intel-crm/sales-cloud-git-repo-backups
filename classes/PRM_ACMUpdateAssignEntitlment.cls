/*********************************************************************************************************************
Class Name    : PRM_ACMUpdateAssignEntitlment
Version       : 1.0
Created Date  : July, 2021
Function      : Update Contact Entitltment at Account based on ACM Update, called from finish of PRM_ACMUpdateBatchUtility

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Dinesh Mengade            July, 2021              This class will add Entitlemtns and Remove entitlement based on new Partner role and tier
-----------------------------
NOTE - This class will work for Account which has only one ACM(Account Channel Membership)      
SOQL Consumed - 3 - PRM_VXEnttlmntMatrix__c, Core_Contact_Entitlement__c, PRM_AccountBenefitAssociation__c
-----------------------------
*********************************************************************************************************************/

public with sharing class PRM_ACMUpdateAssignEntitlment{
    
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Contact_Entitlement__c';
    Map<Id, Set<Id>> actIdCtIdMap = new Map<Id, Set<Id>>();
    public Map<Id, String> contactIdRelName = new Map<id, String>();    
    Map<Id, String> actIdRoleTierMap = new Map<Id, String>();
    map<Id,String> tierIdNames = new Map<Id,String>();    
    Map<Id,List<String>> newPartnerRoleMap = new Map<Id, List<String>>();
    List<Core_Contact_Entitlement__c> lstCEEntitlement = new List<Core_Contact_Entitlement__c>();
    public static Map<Id, List<String>> mapConIdtoCommunityName = new Map<Id, List<String>>();
    public List<Core_Contact_Entitlement__c>  AssignEntitlements(PRM_EntitlementResponseWrapper response){             
        actIdCtIdMap = response.actIdCtIdMap;
        contactIdRelName = response.contactIdRelName;        
        actIdRoleTierMap = response.actIdRoleTierMap;
        tierIdNames = response.tierIdNames;              
        newPartnerRoleMap = response.newPartnerRoleMap;
        createEntitlementBasedOnAccountRoleTier(actIdRoleTierMap,tierIdNames,actIdCtIdMap);
        return lstCEEntitlement;
    }
    
    public void createEntitlementBasedOnAccountRoleTier(Map<Id, String> actIdRoleTierMap,map<Id,String> tierIdNames,Map<Id, Set<Id>> actIdCtIdMap){   
        entitlementMatrixRecordsWrapper entMatWrap = getEntitlementMatrixRecords();//benefitIdVxEntListMap     - partnerRoleTierVxEntListMap    
        Map<id, Set<PRM_VXEnttlmntMatrix__c>> accountIdEntitlementIdMap = new Map<Id, Set<PRM_VXEnttlmntMatrix__c>>();        
        
        ABAWrapper aba = getABARecords(actIdRoleTierMap.keySet());
        Map<Id, Set<Id>> actIdBnftSetMap = aba.actIdBnftSetMap;        
	
        for(Id accountId : actIdRoleTierMap.keySet()){
            String newPartnerRole = actIdRoleTierMap.get(accountId).split('-')[0];
            String newTier = tierIdNames.get(actIdRoleTierMap.get(accountId).split('-')[1]);
            accountIdEntitlementIdMap.putAll(createEntitlementWithoutBenefit(newPartnerRole,newTier,entMatWrap.partnerRoleTierVxEntListMap,accountId));            
            if(actIdBnftSetMap.size()>0 && actIdBnftSetMap.containsKey(accountId) && actIdBnftSetMap.get(accountId)!=null){
                for(PRM_VXEnttlmntMatrix__c vx : createEntitlementWithBenefit(newPartnerRole,newTier,entMatWrap.benefitIdVxEntListMap,accountId,actIdBnftSetMap.get(accountId)).get(accountId)){
                    if(accountIdEntitlementIdMap.size()>0 && accountIdEntitlementIdMap.containsKey(accountId) && accountIdEntitlementIdMap.get(accountId)!=null){
                        accountIdEntitlementIdMap.get(accountId).add(vx);
                    }else{
                        accountIdEntitlementIdMap.put(accountId, new Set<PRM_VXEnttlmntMatrix__c>{vx});
                    }
                }
            }
        }
        if(accountIdEntitlementIdMap.size()>0){
            createEntitlementRecords(accountIdEntitlementIdMap,actIdCtIdMap);
        }        
    }
    
    
    public static ABAWrapper getABARecords(set<Id>actIds){
        Map<Id, Set<Id>> actIdBnftSetMap = new Map<Id, Set<Id>>();// active benefits   - Location Account
        Map<Id, Set<Id>> opidActIdBnftIdsetMap = new Map<Id, Set<Id>>();
        
        // get the OPID account ids for location accounts 
        Map<Id, Set<Id>> onepartnerIdLocId = new Map<Id, Set<Id>>();
        for(Account a : [select id, Core_IPA_One_Partner_Id__c from Account where id in : actIds and RecordType.DeveloperName !=  :Label.PRM_Partner_Account_Group_Record_Type]){
            if(onepartnerIdLocId.size()>0 && onepartnerIdLocId.containsKey(a.Core_IPA_One_Partner_Id__c)){
                onepartnerIdLocId.get(a.Core_IPA_One_Partner_Id__c).add(a.Id);
            }else{
                onepartnerIdLocId.put(a.Core_IPA_One_Partner_Id__c, new Set<Id>{a.Id});
            }
        }
        // list of OPID and associated location accounts for adding opid benefits to location account benefits for Entitltment assignment       
        for( PRM_AccountBenefitAssociation__c abaRec :[select id,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c, PRM_Account_Id__c, PRM_Partner_Benefit_Id__c,PRM_Source__c,PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c  from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in :actIds and PRM_Status_Nm__c=:Label.PRM_Active AND PRM_Source__c!='Specialty']){            
             if(abaRec.PRM_Account_Id__r.RecordType.DeveloperName == Label.PRM_Partner_Account_Group_Record_Type){
                    if(opidActIdBnftIdsetMap!=null && !opidActIdBnftIdsetMap.isEmpty() && opidActIdBnftIdsetMap.containsKey(abaRec.PRM_Account_Id__c)){                  
                        opidActIdBnftIdsetMap.get(abaRec.PRM_Account_Id__c).add(abaRec.PRM_Partner_Benefit_Id__c);
                    }else{
                        opidActIdBnftIdsetMap.put(abaRec.PRM_Account_Id__c,new Set<id>{abaRec.PRM_Partner_Benefit_Id__c});
                    } 
                 }else{                     
                    if(actIdBnftSetMap!=null && !actIdBnftSetMap.isEmpty() && actIdBnftSetMap.containsKey(abaRec.PRM_Account_Id__c)){                  
                        actIdBnftSetMap.get(abaRec.PRM_Account_Id__c).add(abaRec.PRM_Partner_Benefit_Id__c);
                    }else{
                        actIdBnftSetMap.put(abaRec.PRM_Account_Id__c,new Set<id>{abaRec.PRM_Partner_Benefit_Id__c});
                    }                     
                }           
        }
        
        // process all the opid benefits (add opid benefits to location account)        
        for(Id onepartnerId : opidActIdBnftIdsetMap.keySet()){
            if(onepartnerIdLocId.size()>0 && onepartnerIdLocId.containsKey(onepartnerId) && onepartnerIdLocId.get(onepartnerId)!=null ) {
                for(Id locationAccountId : onepartnerIdLocId.get(onepartnerId)){
                    if(actIdBnftSetMap.containsKey(locationAccountId)){
                        actIdBnftSetMap.get(locationAccountId).addAll(opidActIdBnftIdsetMap.get(onepartnerId));
                    }
                }
            }
        }       
        ABAWrapper aba = new ABAWrapper();
        aba.actIdBnftSetMap = actIdBnftSetMap;              
        return aba;
    }
    
    
    public void createEntitlementRecords(Map<id, Set<PRM_VXEnttlmntMatrix__c>> accountIdEntitlementIdMap,Map<Id, Set<Id>> actIdCtIdMap){
        Set<id> contactIds = new set<Id>();
        for(Set<Id> contactIdSet : actIdCtIdMap.values()){
            contactIds.addAll(contactIdSet);
        }

        Set<Core_Contact_Entitlement__c> conEntOrgDataSet = new Set<Core_Contact_Entitlement__c>();
       /* list<string> uniqueIdLst=new list<string>();
        for(Core_Contact_Entitlement__c ce1: [select id, Core_Unique_Id__c, Core_Contact_Id__c, Core_Entitlement_Id__c,Core_Status__c,Core_Data_Loaded__c from Core_Contact_Entitlement__c where Core_Contact_Id__c in:contactIds]){ 
            uniqueIdLst.add(ce1.Core_Unique_Id__c);
        }       */ 
        Map<Id,Map<Id,Core_Contact_Entitlement__c>> contactEntitlementMp = getContactEntitlements(contactIds);
        System.debug('contactEntitlementMp -->'+contactEntitlementMp);
        Map<Id, Map<Id,Core_Contact_Entitlement__c>> finalContactEntilementMap = new Map<Id, Map<Id,Core_Contact_Entitlement__c>>();
        Map<Id, Set<PRM_VXEnttlmntMatrix__c>> contactIdEntitlementSetMap = new Map<Id, Set<PRM_VXEnttlmntMatrix__c>>();
        entitlementMatrixRecordsWrapper entMatWrap = getEntitlementMatrixRecords(); 
        System.debug('entMatWrap>>>> '+entMatWrap.communityVxEntListMap);

        Map<Id, Set<PRM_VXEnttlmntMatrix__c>> mapConIdtoEntMatrix = createEntitlementCommunity(entMatWrap.communityVxEntListMap,contactIds);
        for(Id accountId : accountIdEntitlementIdMap.keySet()){
            if(actIdCtIdMap.size()>0 && actIdCtIdMap.containsKey(accountId)){                
                for(Id contactId: actIdCtIdMap.get(accountId)){
                    Set<PRM_VXEnttlmntMatrix__c> tempVxEntMatrixSet = new Set<PRM_VXEnttlmntMatrix__c>();
                    tempVxEntMatrixSet.addAll(accountIdEntitlementIdMap.get(accountId));
                    contactIdEntitlementSetMap.put(contactId,tempVxEntMatrixSet);
                    if(mapConIdtoEntMatrix!= null && mapConIdtoEntMatrix.containsKey(contactId)){
                        contactIdEntitlementSetMap.get(contactId).addAll(mapConIdtoEntMatrix.get(contactId));
                    }                                       
                }                
            }
        }
        
        if(contactIdEntitlementSetMap.size()>0){
            //Map<Id,Core_Contact_Entitlement__c> conEntOrgData = new Map<Id,Core_Contact_Entitlement__c>();
            
            for(Id contactId : contactIdEntitlementSetMap.keySet()){
                //List<Core_Contact_Entitlement__c> newConEntl1 = new List<Core_Contact_Entitlement__c>();//subhadeep new chnage 
                List<String> relationshipArray = contactIdRelName.get(contactId).split('-');
                set<id> contactEntitlementId = new Set<Id>();
                if(contactEntitlementMp.size()>0 && contactEntitlementMp.containsKey(contactId)){
                    contactEntitlementId = contactEntitlementMp.get(contactId).keySet();
                    conEntOrgDataSet.addAll(contactEntitlementMp.get(contactId).values());//subhadeep new chnage
                   // newConEntl1 = contactEntitlementMp.get(contactId).values();//subhadeep new chnage 
                }
                /*subhadeep new chnage ST
                system.debug('sub new list>>>'+newConEntl1);
                Set<string> uniqConEnt = new Set<string> ();
                for(Core_Contact_Entitlement__c conEnt :newConEntl1){
                    if(conEnt.Core_Selected__c)
                    uniqConEnt.add(conEnt.Core_Contact_Id__c+''+conEnt.Core_Entitlement_Id__c);
                }
                system.debug('already exis set#'+uniqConEnt);
                 /subhadeep new chnage END*/
                Map<Id,Core_Contact_Entitlement__c> ceMap = new Map<Id,Core_Contact_Entitlement__c>();       
                if(contactIdEntitlementSetMap.get(contactId) != null){
                    for(PRM_VXEnttlmntMatrix__c vxent : contactIdEntitlementSetMap.get(contactId)){                        
                        Core_Contact_Entitlement__c ce;                        
                        if(vxent != null && (vxent.RecordType.DeveloperName == 'Community_Entitlements' 
                            || (vxent.PRM_Contact_Relationship_Id__r != null && relationshipArray.contains(vxent.PRM_Contact_Relationship_Id__r.name)))){
                            if(contactEntitlementId.contains(vxent.PRM_Entitlement_Id__c)){
                                ce = contactEntitlementMp.get(contactId).get(vxent.PRM_Entitlement_Id__c);
                                if(!ce.Core_Selected__c){
                                    ce.Core_Selected__c = true;
                                    ce.Core_Status__c = 'Pending';
                                    //ce.Core_Data_Loaded__c = true;//subhadeep new change                                
                                }
                            }else{
                                ce = new Core_Contact_Entitlement__c();
                                //if(!uniqConEnt.contains(ce.Core_Contact_Id__c+''+ce.Core_Entitlement_Id__c)){//subhadeep new chnage
                            // string uniqueIdConcate=string.valueOf(contactId)+string.valueOf(vxent.PRM_Entitlement_Id__c); 
                            // if(!uniqueIdLst.contains(uniqueIdConcate)){
                                
                                ce.Core_Contact_Id__c = contactId;
                                ce.Core_Entitlement_Id__c= vxent.PRM_Entitlement_Id__c;
                                ce.Core_Selected__c = true;
                                ce.Core_Status__c ='Pending';             
                            }
                            // add to final map   
                            ceMap.put(ce.Core_Entitlement_Id__c, ce);                        
                        }
                    }   
                 }               
                finalContactEntilementMap.put(contactId,ceMap);
             }
        }
        
        System.debug('Before inactive finalContactEntilementMap -->\n'+finalContactEntilementMap);
        
        // inactive entitlements which are not required for role/tier
        for(Id contactId : contactEntitlementMp.keySet()){
            Set<Id> entitlementsToUpdate = new Set<Id>();
            if(finalContactEntilementMap.size()>0 && finalContactEntilementMap.containsKey(contactId) && finalContactEntilementMap.get(contactId)!=null){
                entitlementsToUpdate = finalContactEntilementMap.get(contactId).keySet();
                conEntOrgDataSet.addAll(contactEntitlementMp.get(contactId).values());//subhadeep change new
            }            
            for(Id entitlementId : contactEntitlementMp.get(contactId).keySet()){//
                Core_Contact_Entitlement__c ce;
                if(!entitlementsToUpdate.contains(entitlementId) && entMatWrap.entitlementIds.contains(entitlementId)){
                    ce = new Core_Contact_Entitlement__c();
                    ce = contactEntitlementMp.get(contactId).get(entitlementId);
                    ce.Core_Status__c = 'Pending';
                    //ce.Core_Data_Loaded__c = true;//subhadeep new change
                    if(ce.Core_Selected__c== true){
                        ce.Core_Selected__c = false;
                    }
                }
                if(ce!=null){
                    if(finalContactEntilementMap.size()>0 && finalContactEntilementMap.containsKey(contactId) && finalContactEntilementMap.get(contactId)!=null){
                        finalContactEntilementMap.get(contactId).put(ce.Core_Entitlement_Id__c,ce);
                    }else{
                        finalContactEntilementMap.put(contactId, new Map<id,Core_Contact_Entitlement__c>{ce.Core_Entitlement_Id__c=>ce});
                    }                                                   
                }
            }
        }
        
        System.debug('finalContactEntilementMap -->\n'+finalContactEntilementMap);
        
        List<SObject> recordsToLoad = new List<SObject>();
        Set<Core_Contact_Entitlement__c> recordsSetToLoad = new Set<Core_Contact_Entitlement__c>();//Subhadeep change new
        for(Map<Id,Core_Contact_Entitlement__c>  mp : finalContactEntilementMap.values()){            
            for(Core_Contact_Entitlement__c ce : mp.values()){                             
                recordsSetToLoad.add(ce);//Subhadeep change new
            }
        }
        //recordsToLoad.addAll(recordsSetToLoad);//Subhadeep change new
        Set<Core_Contact_Entitlement__c> uniqConEntlSet = new Set<Core_Contact_Entitlement__c>();
        system.debug('org data--->'+conEntOrgDataSet);
        for(Core_Contact_Entitlement__c distConEntl :conEntOrgDataSet){
            for(Core_Contact_Entitlement__c setContEntRec :recordsSetToLoad){
                if(distConEntl.Core_Contact_Id__c+''+distConEntl.Core_Entitlement_Id__c+''+distConEntl.Core_Selected__c != setContEntRec.Core_Contact_Id__c+''+setContEntRec.Core_Entitlement_Id__c+''+setContEntRec.Core_Selected__c)
                    uniqConEntlSet.add(setContEntRec);
            }
        }
        system.debug(uniqConEntlSet);
        system.debug('recordsToLoad Set -->'+recordsSetToLoad);
        System.debug('recordsToLoad -->'+recordsToLoad);
        //lstCEEntitlement = recordsToLoad;  //Subhadeep change new
        lstCEEntitlement = new List <Core_Contact_Entitlement__c>(uniqConEntlSet);
             
    }    
    
    public static Map<Id,Map<Id,Core_Contact_Entitlement__c>> getContactEntitlements(Set<id> contactIds){
        Map<Id,Map<Id,Core_Contact_Entitlement__c>> cntEntlmntIdSetMap = new Map<Id,Map<Id,Core_Contact_Entitlement__c>>();
        for(Core_Contact_Entitlement__c ctEntlmntRecord : [select id,Core_Source__c, Core_Contact_Id__c,Core_Contact_Id__r.Core_IPA_Partner_Community__c,Core_Entitlement_Id__c,Core_Entitlement_Id__r.name, Core_Selected__c from Core_Contact_Entitlement__c where Core_Contact_Id__c in :contactIds and Core_Type__c='Entitlement' and (NOT Core_Entitlement_Id__r.Name in :Label.PRM_Employee_Bundle_Entitlements.split(';') )]){
            if(ctEntlmntRecord.Core_Contact_Id__r.Core_IPA_Partner_Community__c!=null && !mapConIdtoCommunityName.containsKey(ctEntlmntRecord.Core_Contact_Id__c)){
                List<String> listIpaCommunities = ctEntlmntRecord.Core_Contact_Id__r.Core_IPA_Partner_Community__c.split(';');
                mapConIdtoCommunityName.put(ctEntlmntRecord.Core_Contact_Id__c, listIpaCommunities);
            }
            if(cntEntlmntIdSetMap!=null && !cntEntlmntIdSetMap.isEmpty() && cntEntlmntIdSetMap.containsKey(ctEntlmntRecord.Core_Contact_Id__c)){              
                cntEntlmntIdSetMap.get(ctEntlmntRecord.Core_Contact_Id__c).put(ctEntlmntRecord.Core_Entitlement_Id__c,ctEntlmntRecord);                
            }else{
                cntEntlmntIdSetMap.put(ctEntlmntRecord.Core_Contact_Id__c,new Map<Id,Core_Contact_Entitlement__c>{ctEntlmntRecord.Core_Entitlement_Id__c=>ctEntlmntRecord});
            }                
        }
        system.debug('cntEntlmntIdSetMap--->'+cntEntlmntIdSetMap);
        return cntEntlmntIdSetMap;
    }
    
    public Map<id, Set<PRM_VXEnttlmntMatrix__c>> createEntitlementWithoutBenefit(String parterRole, String tier, Map<String, List<PRM_VXEnttlmntMatrix__c>> vxMatRecordsWithoutBenefit, Id accountId ){
        Map<id, Set<PRM_VXEnttlmntMatrix__c>> actIdEntIdMp = new Map<id, Set<PRM_VXEnttlmntMatrix__c>>();
        Set<String> keysForEntitlemets = new Set<String>();
        if(tier=='member'){
            keysForEntitlemets.add(parterRole+'-'+tier);
        }else if(tier=='gold'){
            keysForEntitlemets.add(parterRole+'-'+tier);
            keysForEntitlemets.add(parterRole+'-'+'Member');
        }else if(tier=='titanium'){
            keysForEntitlemets.add(parterRole+'-'+tier);
            keysForEntitlemets.add(parterRole+'-'+'Gold');
            keysForEntitlemets.add(parterRole+'-'+'Member');
        }
        Set<PRM_VXEnttlmntMatrix__c> vxEntRecords = new set<PRM_VXEnttlmntMatrix__c>();
        for(String key: keysForEntitlemets){
            if(vxMatRecordsWithoutBenefit.size()>0 && vxMatRecordsWithoutBenefit.containsKey(key)){
                for(PRM_VXEnttlmntMatrix__c vxMat : vxMatRecordsWithoutBenefit.get(key)){
                    vxEntRecords.add(vxMat);
                }
            }            
        }
        actIdEntIdMp.put(accountId,vxEntRecords);
        system.debug('actIdEntIdMp without benefit--->'+actIdEntIdMp);
        return actIdEntIdMp;
    }
    
    public Map<id, Set<PRM_VXEnttlmntMatrix__c>> createEntitlementWithBenefit(String parterRole, String tier, Map<Id, List<PRM_VXEnttlmntMatrix__c>> vxMatRecordsWitBenefit, Id accountId, Set<Id> benefitIds){
        Map<id, Set<PRM_VXEnttlmntMatrix__c>> actIdEntIdMp = new Map<id, Set<PRM_VXEnttlmntMatrix__c>>();
        Set<PRM_VXEnttlmntMatrix__c> vxMat = new Set<PRM_VXEnttlmntMatrix__c>();
        for(Id benefitId : benefitIds){
            if(vxMatRecordsWitBenefit.size()>0 && vxMatRecordsWitBenefit.containsKey(benefitId) && vxMatRecordsWitBenefit.get(benefitId)!=null){
                vxMat.addAll(vxMatRecordsWitBenefit.get(benefitId));
            }
        }
        actIdEntIdMp.put(accountId, vxMat);
         system.debug('actIdEntIdMp with benefit--->'+actIdEntIdMp);
        return actIdEntIdMp;
    }

     /**
     * @Description: fetch Community Entitlements of Contacts
     * @Parameters : Map of Community name and respective Entitlement, Set of Contact Ids
     * @return : return Map of contact ID as a key and Set of Entitlements as values
     */
    public Map<id, Set<PRM_VXEnttlmntMatrix__c>> createEntitlementCommunity(Map<String, PRM_VXEnttlmntMatrix__c> vxMatRecordsCommEnt, Set<Id> contactId){
        Map<Id, Set<PRM_VXEnttlmntMatrix__c>> commentitlementMap = new Map<Id, Set<PRM_VXEnttlmntMatrix__c>>();
        try{
            for(Id conId : contactId){
                if(mapConIdtoCommunityName!= null && mapConIdtoCommunityName.containsKey(conId)){
                    for(String comName : mapConIdtoCommunityName.get(conId)){
                        if(!commentitlementMap.containsKey(conId)){
                            commentitlementMap.put(conId, new Set<PRM_VXEnttlmntMatrix__c>{vxMatRecordsCommEnt.get(comName)});
                        }
                        else{ 
                            commentitlementMap.get(conId).add(vxMatRecordsCommEnt.get(comName));
                        }
                    }
                }
            }
            System.debug('commentitlementMap--> '+commentitlementMap);           
        }catch (Exception ex) {
            String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
            System.debug('##### Exception: ' + exceptionMessage);
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, '', LOG_ENTRY_ERROR,
                                                 'Error', '', '', LOG_ENTRY_OBJECT, '', ex);
        }
        return commentitlementMap;
    }
    
    public entitlementMatrixRecordsWrapper getEntitlementMatrixRecords(){
        Map<Id, List<PRM_VXEnttlmntMatrix__c>> benefitIdVxEntListMap  = new Map<Id, List<PRM_VXEnttlmntMatrix__c>>();//will have record of type entlmnt
        Map<String, List<PRM_VXEnttlmntMatrix__c>> partnerRoleTierVxEntListMap  = new Map<String, List<PRM_VXEnttlmntMatrix__c>>();//will have record of type entlmnt without benefit STring - Partner role+tier
        Map<String, PRM_VXEnttlmntMatrix__c> communityVxEntListMap  = new Map<String, PRM_VXEnttlmntMatrix__c>();
        set<Id> lstCEEntitlementInMatrix=new set<Id>();
        for(PRM_VXEnttlmntMatrix__c vxEntlmnMatRec :
            [select name,Account__r.name,PRM_AGS_Role__c,PRM_Channel_Program_Level_Id__c,PRM_IsActive_Ind__c,PRM_Channel_Program_Level_Id__r.name,
             PRM_Contact_Relationship_Id__r.name,PRM_Entitlement_Id__c,PRM_IPA_Partner_Role_Nm__c,Communities__c, PRM_Partner_Benefit_Id__c, RecordType.DeveloperName
             from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:Label.PRM_ApprovalType  and PRM_IsActive_Ind__c = True
       and PRM_Channel_Program_Id__r.name='Intel Partner Alliance'])// and PRM_Channel_Program_Level_Id__c!=null 
        {
            if(vxEntlmnMatRec.PRM_Entitlement_Id__c!=null){
                lstCEEntitlementInMatrix.add(vxEntlmnMatRec.PRM_Entitlement_Id__c);
            }
                if(vxEntlmnMatRec.RecordType.DeveloperName==Label.PRM_EntitlementWithBenefits){
                    if(benefitIdVxEntListMap!=null && !benefitIdVxEntListMap.isEmpty() && benefitIdVxEntListMap.containsKey(vxEntlmnMatRec.PRM_Partner_Benefit_Id__c)){                   
                        benefitIdVxEntListMap.get(vxEntlmnMatRec.PRM_Partner_Benefit_Id__c).add(vxEntlmnMatRec);                       
                    }else{
                        benefitIdVxEntListMap.put(vxEntlmnMatRec.PRM_Partner_Benefit_Id__c,new List<PRM_VXEnttlmntMatrix__c>{vxEntlmnMatRec});
                    }
                }else if(vxEntlmnMatRec.RecordType.DeveloperName==Label.PRM_EntitlementWithoutBenefits){               
                    if(partnerRoleTierVxEntListMap!=null && !partnerRoleTierVxEntListMap.isEmpty() && partnerRoleTierVxEntListMap.containsKey(vxEntlmnMatRec.PRM_IPA_Partner_Role_Nm__c+'-'+vxEntlmnMatRec.PRM_Channel_Program_Level_Id__r.name)){
                        List<PRM_VXEnttlmntMatrix__c> vxMatRec = partnerRoleTierVxEntListMap.get(vxEntlmnMatRec.PRM_IPA_Partner_Role_Nm__c+'-'+vxEntlmnMatRec.PRM_Channel_Program_Level_Id__r.name);
                        vxMatRec.add(vxEntlmnMatRec);
                        partnerRoleTierVxEntListMap.put(vxEntlmnMatRec.PRM_IPA_Partner_Role_Nm__c+'-'+vxEntlmnMatRec.PRM_Channel_Program_Level_Id__r.name,vxMatRec);
                    }else{
                        partnerRoleTierVxEntListMap.put(vxEntlmnMatRec.PRM_IPA_Partner_Role_Nm__c+'-'+vxEntlmnMatRec.PRM_Channel_Program_Level_Id__r.name,new List<PRM_VXEnttlmntMatrix__c>{vxEntlmnMatRec});
                    }
                }
                else if((vxEntlmnMatRec.RecordType.DeveloperName=='Community_Entitlements')){
                    communityVxEntListMap.put(vxEntlmnMatRec.Communities__c,vxEntlmnMatRec);
                }
            }
                        

        entitlementMatrixRecordsWrapper entMatWrap = new entitlementMatrixRecordsWrapper();
        entMatWrap.benefitIdVxEntListMap = benefitIdVxEntListMap;
        entMatWrap.partnerRoleTierVxEntListMap = partnerRoleTierVxEntListMap;
        entMatWrap.communityVxEntListMap = communityVxEntListMap;
        entMatWrap.entitlementIds=lstCEEntitlementInMatrix;
        return entMatWrap;
    }
    public class EntitlementMatrixRecordsWrapper{
        Map<Id, List<PRM_VXEnttlmntMatrix__c>> benefitIdVxEntListMap{get;set;}
        Map<String, List<PRM_VXEnttlmntMatrix__c>> partnerRoleTierVxEntListMap{get;set;}
        Map<String, PRM_VXEnttlmntMatrix__c> communityVxEntListMap{get;set;}
        set<id> entitlementIds{get;set;}
    }
    
    public class ABAWrapper{
        Map<Id, Set<Id>> actIdBnftSetMap{get;set;}
        Set<String> actIdBenefitIdSet{get;set;}
    }
    
}