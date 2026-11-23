/*********************************************************************************************************************
Class Name    : PRM_ACMUpdateUtility
Version       : 1.0
Created Date  : July, 2021
Function      : Update Account channel membership at OPID OR Account wihout OPID based on IPA Membership

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Dinesh Mengade            July, 2021              This class will update ACM and assign benefits based on new Partner role and tier
-----------------------------
NOTE - This class will work for Account which has only one ACM(Account Channel Membership)
SOQL Consumed - 6 -PRM_IPA_Membership__c, ChannelProgramLevel, PRM_AccountChannelMembership__c, PRM_Account_Contact_Relationship__c, PRM_VXBnftMatrix__c, PRM_AccountBenefitAssociation__c
-----------------------------
*********************************************************************************************************************/

public without sharing class PRM_ACMUpdateUtility{//implements Database.Batchable<SObject>,Database.Stateful
    
    @TestVisible
    private static final string ORIGIN = 'PRM_ACMUpdateBatchUtility';
    private static final string SEVERITY = 'Critical';
    private static final string PROJECT = 'IPA';
    private static final string ERROR_MESSAGE = 'Too many DML rows';
    static String logEntry='';
        
    static List<Contact> contactList = new  List<Contact>();
    static List<Id> actSpecificABAList = new List<Id>();
    static List<PRM_AccountBenefitAssociation__c> finalABAList = new List<PRM_AccountBenefitAssociation__c>();
    static List<PRM_IPA_Membership__c> pendingChangeRequests = new List<PRM_IPA_Membership__c>();
    static List<String> removeBenefitsList = new List<String>(); // added globally
    static List<String> addBenefitsList = new List<String>(); // added globally
    static Set<id> contactIdSet = new Set<id>();
    static Map<Id,List<PRM_AccountChannelMembership__c>> finalAcmMap = new Map<Id,List<PRM_AccountChannelMembership__c>>();
    static Map<Id,String> accountIdRecTypemap = new Map<Id,String>(); // keep the accounts with record type to assign benefits
    static Map<Id, Set<Id>> actIdCtIdMap = new Map<Id, Set<Id>>();
    static Map<Id, String> OPIDContIdMap= new Map<Id, String>();
    static Map<Id, String> contactIdRelName = new Map<id, String>();
    static Map<Id, Id> ctIdActIdMp = new Map<Id, Id>();
    static Map<Id, String> actIdRoleTierMap = new Map<Id, String>(); 
    static Map<Id, String> actIdRoleTier = new Map<Id, String>();// keep account id and new partner role tier
    static Map<Id,String> tierIdNames = new Map<Id,String>();
    static Map<Id,List<String>> newPartnerRoleMap = new Map<Id, List<String>>();
    static Map<Id, String> accIdOldNewPartnerRoleMap = new Map<Id, String>();
    static Map<Id, String> oldAcmIdPartnerRole = new  Map<Id, String>();
    static Map<Id,Id> acmIdActId = new Map<Id,Id>();
    static Map<id, List<PRM_AccountChannelMembership__c>> opidACMListMap  = new Map<id, List<PRM_AccountChannelMembership__c>>();
    static Map<String, String> actIdCPLMap = new Map<String, String>(); //act id | oldPartnerRole | new CPL
    static Map<String, String> actIdCommentsMap = new Map<String, String>();
    static Map<Id,List<PRM_AccountChannelMembership__c>> opidChildACMMap = new Map<Id,List<PRM_AccountChannelMembership__c>>();
    static Map<id, Id> opidCPLMap  = new Map<Id,Id>();
    Static Map<id,List<String>> actIdPartnerRoleMap = new Map<Id, List<String>>();
    static Map<Id,String> ctIdSegmentMap = new Map<Id, String>();
    Static map<Id, String> actIdPartnerSegmentMap = new Map<Id, String>();
    String partRole= '';
    static List<Core_Contact_Entitlement__c> entitlementsTOUpsert = new List<Core_Contact_Entitlement__c>();    
    static prm_skip_trigger__c sk;
    static Map<String, Integer> tierRank = new Map<String, Integer>{'Member'=>1,'Gold'=>2,'Titanium'=>3};
    String tempKey;
    String tierId;
    String tierName;
    String key;
    public static boolean isPartnerRoleChanged=false;
    public static boolean isRTAInitiated = false;
    //
    List<Sobject> updateAccountandContact = new List<Sobject>();  
    set<Id> locationACMForProfileResponse= new set<Id>();
    public contactEntilementResponse assignBenefits(List<PRM_IPA_Membership__c> changeRequests){  
        // logEntryMsg+='\n@@@PRM_ACMUpdateUtility assignBenefits:'+changeRequests;  
        isRTAInitiated = true;  
        setRolesAndTiers(changeRequests);            
        contactEntilementResponse cresp =  new contactEntilementResponse();
        cresp.updateAccountandContact = updateAccountandContact;
        cresp.entitlementsTOUpsert = entitlementsTOUpsert;
        cresp.memResponseWrapper = memResponseWrapper;
        //cresp.locationAccountRecord = locationACMForProfileResponse;
        return cresp;
    }
    
    public static Map<Id, MembershipWrapper> memResponseWrapper = new Map<Id,MembershipWrapper>();
    public class MembershipWrapper{
        public Id AccountId{get;set;} 
        public Id memId{get;set;}               
        public String errorMessage{get;set;}
    }
    
    
    public class contactEntilementResponse{
        public List<Sobject> updateAccountandContact{get;set;}
        public List<Sobject> entitlementsTOUpsert{get;set;}
        public List<Sobject> locationAccountRecord{get;set;}
        public Map<Id, MembershipWrapper> memResponseWrapper{get;set;}
    }
    
    //PROCESS ACM's and UPDATE BENEFITS ON ACCOUN, ROLE ON CONTACT
    public void setRolesAndTiers(list<PRM_IPA_Membership__c> memList){// update method name settingRoleTier
        
        try{
            //get ids for Member, GOld, Titanium tiers
            
            tierIdNames = getIPACPL(Label.PRM_Intel_Partner_Alliance);
            List<PRM_IPA_Membership__c> membershipList  = new List<PRM_IPA_Membership__c>();
        Map<id, PRM_AccountChannelMembership__c> opidSourceACMMap = new Map<id, PRM_AccountChannelMembership__c>();
        Map<id, String> opidOldTierMap = new Map<id, String>();
        MembershipWrapper mem = new MembershipWrapper(); 
        Map<id, Id> locCPLMap  = new Map<Id,Id>();        
            
            for(PRM_IPA_Membership__c ipameme : memList){
                if((System.label.PointsOptInEligiblePartners.split(',').contains(ipameme.PRM_Old_Partner_Role__c) && !System.label.PointsOptInEligiblePartners.split(',').contains(ipameme.PRM_Partner_Role__c)) || 
                (!System.label.PointsOptInEligiblePartners.split(',').contains(ipameme.PRM_Old_Partner_Role__c) && System.label.PointsOptInEligiblePartners.split(',').contains(ipameme.PRM_Partner_Role__c))){
                    isPartnerRoleChanged=true;    
                }            
                ipameme.PRM_Status__c=Label.PRM_Label_complete;
                membershipList.add(ipameme);
                
                PRM_AccountChannelMembership__c acm  = new PRM_AccountChannelMembership__c();
                acm.Id = ipameme.PRM_Account_Channel_Membership__c;
                acm.PRM_Partner_Role__c = ipameme.PRM_Partner_Role__c;
                acm.PRM_Channel_Program_Level_Id__c = ipameme.PRM_Partner_Tier__c;
                acm.PRM_Comments__c = ipameme.PRM_Comments__c;
                
                opidSourceACMMap.put(ipameme.PRM_Account_Id__c, acm);           
                acmIdActId.put(ipameme.PRM_Account_Channel_Membership__c,ipameme.PRM_Account_Id__c);
                accIdOldNewPartnerRoleMap.put(ipameme.PRM_Account_Id__c, ipameme.PRM_Old_Partner_Role__c);
                Map<Id,List<PRM_AccountChannelMembership__c>> acmMp = getAcmListMap(ipameme, acm);
                for(String Id:acmMp.keySet() ){
                    finalAcmMap.put(id, acmMp.get(Id));
                    //system.debug('finalAcmMap'+finalAcmMap);
                }
                
                oldAcmIdPartnerRole.put(ipameme.PRM_Account_Channel_Membership__c, ipameme.PRM_Old_Partner_Role__c);
                accountIdRecTypemap.put(ipameme.PRM_Account_Id__c, ipameme.PRM_Account_Record_Type__c);
                actIdRoleTier.put(ipameme.PRM_Account_Id__c, ipameme.PRM_Partner_Role__c+'-'+ipameme.PRM_Partner_Tier__c);
                actIdCPLMap.put(ipameme.PRM_Account_Id__c+'-'+ipameme.PRM_Old_Partner_Role__c, ipameme.PRM_Partner_Tier__c);
                //PROCESS IPAMembership(Change Requests) RECORDS BASED on ACCOUNT RECORD TYPE
                if(ipameme.PRM_Account_Record_Type__c==Label.PRM_Partner_Account_Group_Record_Type){
                actIdCommentsMap.put(ipameme.PRM_Account_Id__c+'-'+ipameme.PRM_Old_Partner_Role__c, ipameme.PRM_Comments__c);
                    opidCPLMap.put(ipameme.PRM_Account_Id__c, ipameme.PRM_Partner_Tier__c);
                    mem.AccountId = ipameme.PRM_Account_Id__c;
                    mem.memId = ipameme.Id;
                    mem.errorMessage = ''; 
                }else{
                locCPLMap.put(ipameme.PRM_Account_Id__c, ipameme.PRM_Partner_Tier__c);
                //system.debug('Adding actIdRoleTierMap -->'+actIdRoleTierMap);
                    actIdRoleTierMap.put(ipameme.PRM_Account_Id__c, ipameme.PRM_Partner_Role__c+'-'+ipameme.PRM_Partner_Tier__c);
                    mem.AccountId = ipameme.PRM_Account_Id__c;
                    mem.memId = ipameme.Id;
                    mem.errorMessage = '';
                }
                
                if(newPartnerRoleMap!=null && !newPartnerRoleMap.isEmpty() && newPartnerRoleMap.containsKey(ipameme.PRM_Account_Id__c)){
                    newPartnerRoleMap.get(ipameme.PRM_Account_Id__c).add(ipameme.PRM_Old_Partner_Role__c+'-'+ipameme.PRM_Partner_Role__c);
                }else{
                    newPartnerRoleMap.put(ipameme.PRM_Account_Id__c, new List<String>{ipameme.PRM_Old_Partner_Role__c+'-'+ipameme.PRM_Partner_Role__c});
                }
                if(ipameme.PRM_Account_Record_Type__c=='Mastered_Account'){
                    locationACMForProfileResponse.add(ipameme.PRM_Account_Id__c);
                }
                
                if(mem.AccountId!=null){
                    if(!memResponseWrapper.containsKey(ipameme.PRM_Account_Id__c)){
                        memResponseWrapper.put(ipameme.PRM_Account_Id__c, mem);
                    }
                }
            }
            
            //system.debug('newPartnerRoleMap -->'+newPartnerRoleMap);
            //system.debug('opidCPLMap -->'+opidCPLMap);
            //system.debug('actIdCPLMap -->'+actIdCPLMap);
        Map<id,List<PRM_AccountChannelMembership__c>> acmRecMap=new Map<id,List<PRM_AccountChannelMembership__c>>();
        Set<Id> accIdsEligibleForRTA = new Set<Id>();
        
            //based on oPID's get the child account acms
        if(!opidCPLMap.isEmpty() || !newPartnerRoleMap.isEmpty()){ 
            for(PRM_AccountChannelMembership__c acmRecord : [select id, PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Account_Id__c, PRM_Channel_Program_Level_Id__c, PRM_Partner_Role__c,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Status_Nm__c,PRM_Onepartner_Id__c from PRM_AccountChannelMembership__c where (PRM_Account_Id__r.Core_IPA_One_Partner_Id__c  in : opidCPLMap.keySet() or PRM_Account_Id__c IN: newPartnerRoleMap.keyset()) order by PRM_Status_Nm__c desc]){
                if(acmRecMap.containsKey(acmRecord.PRM_Account_Id__c)){
                             acmRecMap.get(acmRecord.PRM_Account_Id__c).add(acmRecord);
                }
                else{
                    acmRecMap.put(acmRecord.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>{acmRecord});
                }
                if(oldAcmIdPartnerRole.containsKey(acmRecord.id) && oldAcmIdPartnerRole.get(acmRecord.id) == acmRecord.PRM_Partner_Role__c){
                    opidOldTierMap.put(acmRecord.PRM_Account_Id__c, acmRecord.PRM_Channel_Program_Level_Id__c);
                }
                
                String accId = acmRecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c;
                if(String.isBlank(accId)){
                    accId =  acmRecord.PRM_Account_Id__c;   
                }
                if(acmRecord.PRM_Status_Nm__c=='Approved'){
                    if(newPartnerRoleMap.containsKey(accId) && getOldPartnerRole(newPartnerRoleMap.get(accId)).contains(acmRecord.PRM_Partner_Role__c)){
                        accIdsEligibleForRTA.add(acmRecord.PRM_Account_Id__c);    
                    }
                    if(!memResponseWrapper.containsKey(accId)){
                        memResponseWrapper.put(acmRecord.PRM_Account_Id__c, memResponseWrapper.get(acmRecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c));
                    }
                    locationACMForProfileResponse.add(acmRecord.PRM_Account_Id__c);
                    //PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
                    accountIdRecTypemap.put(acmRecord.PRM_Account_Id__c, acmRecord.PRM_Account_Id__r.RecordType.DeveloperName);
                    oldAcmIdPartnerRole.put(acmRecord.Id, acmRecord.PRM_Partner_Role__c);
                    
                    if(getOldPartnerRole(newPartnerRoleMap.get(accId)).contains(acmRecord.PRM_Partner_Role__c)){// changes
                        for( String str : newPartnerRoleMap.get(accId)){
                            if(newPartnerRoleMap!=null && !newPartnerRoleMap.isEmpty() && newPartnerRoleMap.containsKey(acmRecord.PRM_Account_Id__c)){
                                List<String> lst = newPartnerRoleMap.get(acmRecord.PRM_Account_Id__c);// lst varible name
                                if(!lst.contains(str)){
                                    lst.add(str);
                                    newPartnerRoleMap.put(acmRecord.PRM_Account_Id__c, lst);
                                }
                            }else{
                                newPartnerRoleMap.put(acmRecord.PRM_Account_Id__c, new List<String>{str});
                            }
                            
                            List<String> strList = str.split('-');
                            if(acmRecord.PRM_Partner_Role__c == strList[0]){
                                if(newPartnerRoleMap!=null && !newPartnerRoleMap.containsKey(acmRecord.PRM_Account_Id__c)){
                                    newPartnerRoleMap.put(acmRecord.PRM_Account_Id__c, new List<String>{acmRecord.PRM_Partner_Role__c+'-'+' '});//+'-'+ipameme.PRM_Partner_Role__c});
                                }
                                String tier = String.IsNotBlank(acmRecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)? opidCPLMap.get(acmRecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c):locCPLMap.get(acmRecord.PRM_Account_Id__c);
                                actIdRoleTierMap.put(acmRecord.PRM_Account_Id__c, strList[1]+'-'+tier);// added newly tierIdNames.get()locCPLMap
                                /*acmRecord.PRM_Partner_Role__c = strList[1];
                                acmRecord.PRM_Channel_Program_Level_Id__c = actIdCPLMap.get( acmRecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c+'-'+strList[0]);//split[1];
                                if(opidChildACMMap!=null && !opidChildACMMap.isEmpty() && opidChildACMMap.containsKey(acmRecord.PRM_Account_Id__c)){//PRM_Account_Id__c
                                opidChildACMMap.get(acmRecord.PRM_Account_Id__c).add(acmRecord);
                                }else{
                                opidChildACMMap.put(acmRecord.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acmRecord});
                                }*/
                                acmIdActId.put(acmRecord.Id,acmRecord.PRM_Account_Id__c);
                                break;
                            }
                        }
                    }
                    
                }
            }
            //system.debug('actIdRoleTier -->'+actIdRoleTier);
            //system.debug('/// acmRecMap -->'+acmRecMap);
            List<String> strList1=new list<string>();
            if(acmRecMap!=null && !acmRecMap.isEmpty()){
                for(id accId : acmRecMap.keySet()){
                    if(accIdsEligibleForRTA.contains(accId)){
                        Boolean Flag = False;
                        for(PRM_AccountChannelMembership__c acmRec : acmRecMap.get(accId)){
                            String accIdKey = acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c;
                            if(String.isBlank(acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)){
                                accIdKey = acmRec.PRM_Account_Id__c;
                            }
                            string str1= actIdRoleTier.get(accIdKey);
                            strList1 = str1.split('-');
                            if(acmRecMap.get(accId).size() > 1){
                            if(acmRec.PRM_Account_Id__c != acmRec.PRM_Onepartner_Id__c){
                                if(acmRec.PRM_Partner_Role__c==strList1[0]){
                                    if((acmRec.PRM_Status_Nm__c=='Inactive' 
                                        || acmRec.PRM_Status_Nm__c=='Pending')){
                                            acmRec.PRM_Status_Nm__c='Approved';
                                            //system.debug('acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c'+acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c);
                                            String tier = String.IsNotBlank(acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)? opidCPLMap.get(acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c):locCPLMap.get(acmRec.PRM_Account_Id__c);
                                            acmRec.PRM_Channel_Program_Level_Id__c = tier;
                                            acmRec.PRM_Partner_Role__c = strList1[0];
                                            Flag = True;
                                            partRole = strList1[0];
                                        }
                                }
                                    else if(acmRec.PRM_Partner_Role__c != strList1[0] && actIdCPLMap.containsKey(accIdKey+'-'+acmRec.PRM_Partner_Role__c) && !Flag){                             
                                        String tier = String.IsNotBlank(acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)? opidCPLMap.get(acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c):locCPLMap.get(acmRec.PRM_Account_Id__c);
                                        acmRec.PRM_Channel_Program_Level_Id__c = tier;
                                        acmRec.PRM_Partner_Role__c = strList1[0];
                                    }
                                    else{
                                        //system.debug('Inside else if'+ acmRec.id);
                                        acmRec.PRM_Status_Nm__c= 'Inactive';
                                    }

                            }    
                        }
                            else{
                                if(acmRec.PRM_Account_Id__c != acmRec.PRM_Onepartner_Id__c){
                                String tier = String.IsNotBlank(acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)? opidCPLMap.get(acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c):locCPLMap.get(acmRec.PRM_Account_Id__c);    
                                acmRec.PRM_Channel_Program_Level_Id__c = tier;
                acmRec.PRM_Partner_Role__c = strList1[0];
                                }
                            }
                            
                            
                            if(acmRec.PRM_Account_Id__c != acmRec.PRM_Onepartner_Id__c){
                                if(opidChildACMMap!=null && !opidChildACMMap.isEmpty() && opidChildACMMap.containsKey(acmRec.PRM_Account_Id__c)){//PRM_Account_Id__c
                                    opidChildACMMap.get(acmRec.PRM_Account_Id__c).add(acmRec);
                                }else{
                                    opidChildACMMap.put(acmRec.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acmRec});
                                }
                                acmIdActId.put(acmRec.Id,acmRec.PRM_Account_Id__c);
                            }else{                                
                                if(acmRec.PRM_Partner_Role__c==strList1[0] && (acmRec.PRM_Status_Nm__c=='Inactive' 
                                        || acmRec.PRM_Status_Nm__c=='Pending') && opidSourceACMMap.containsKey(acmRec.PRM_Account_Id__c) && opidSourceACMMap.get(acmRec.PRM_Account_Id__c).id != acmRec.id){
                                        acmRec.PRM_Status_Nm__c='Approved';
                                        String tier = String.IsNotBlank(acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)? opidCPLMap.get(acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c):locCPLMap.get(acmRec.PRM_Account_Id__c);        
                                        acmRec.PRM_Channel_Program_Level_Id__c = tier;
                                        
                                        PRM_AccountChannelMembership__c sourceACM = opidSourceACMMap.get(acmRec.PRM_Account_Id__c);
                                        sourceACM.PRM_Status_Nm__c='Inactive';
                                        sourceACM.PRM_Channel_Program_Level_Id__c = opidOldTierMap.get(acmRec.PRM_Account_Id__c);
                                        sourceACM.PRM_Partner_Role__c = oldAcmIdPartnerRole.get(sourceACM.id);
                                        
                                        if(finalAcmMap.containsKey(acmRec.PRM_Account_Id__c)){
                                            finalAcmMap.get(acmRec.PRM_Account_Id__c).add(acmRec);      
                                        }else{
                                            finalAcmMap.put(acmRec.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>{acmRec});        
                                        }   
                                            
                                        acmIdActId.put(acmRec.Id,acmRec.PRM_Account_Id__c);                                                                             
                                }
                                   
                            }   
                            
                        }
                    }
                }
            }
            
        }
            for(String Id:opidChildACMMap.keySet() ){
                finalAcmMap.put(id, opidChildACMMap.get(Id));
            }
            //system.debug('finalAcmMap -->'+finalAcmMap);
            //filter duplicates
            List<PRM_AccountChannelMembership__c> acmsTobeUpdated = new List<PRM_AccountChannelMembership__c>();
            for(List<PRM_AccountChannelMembership__c> acmList : finalAcmMap.values()){
                for(PRM_AccountChannelMembership__c acm : acmList){
                    if(!acmsTobeUpdated.contains(acm)){
                        acmsTobeUpdated.add(acm);
                    }
                }
            }
           
            //system.debug('acmsTobeUpdated -->'+acmsTobeUpdated);
            ////system.debug('newPartnerRoleMap -->'+newPartnerRoleMap);
            
            // get all the ACR record with old partner role matching
            Set<String> roleSet = new Set<String>();
            for(Id id : newPartnerRoleMap.keyset()){
                for(String strLst : getOldPartnerRole(newPartnerRoleMap.get(id))){//oldPartnerRoleMap
                    roleSet.add(strLst);
                }
            }
            
            ////system.debug('roleSet -->'+roleSet);
            //List<Contact> contactList = new  List<Contact>();
            //added by LATA for INC11127372 && scenario:- Role/Tier Automation - Entitlements are getting added to the contact with status = Pending Action as part of role/tier automation.

            for(PRM_Account_Contact_Relationship__c acrRec : [select id,PRM_Relationship_Id__r.name,PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c, PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Contact_Id__c, PRM_Contact_Id__r.Core_IPA_PartnerRole__c , PRM_Partner_Role__c,PRM_Account_Id__c,PRM_Contact_Id__r.Core_IPA_Contact_Segment__c from PRM_Account_Contact_Relationship__c where (PRM_Account_Id__c in :newPartnerRoleMap.keySet() OR PRM_Account_Id__r.Core_IPA_One_Partner_Id__c in:opidCPLMap.keySet()) and PRM_InActive_Ind__c=false and PRM_Status_Nm__c='Complete' and  PRM_Partner_Role__c in :roleSet]){
               //Create contIdOPIDAccountMap contact id as key & OPID account as value
                if(acrRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c<>null){
                    OPIDContIdMap.put(acrRec.PRM_Contact_Id__c,acrRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c);
                }
                
                //for(Account actRecord : [select id,Core_IPA_Partner_Role__c, Core_IPA_Partner_Segment__c from Account where id in :newPartnerRoleMap.keySet()]){
                if(!actIdPartnerSegmentMap.containsKey(acrRec.PRM_Account_Id__c)){
                    actIdPartnerSegmentMap.put(acrRec.PRM_Account_Id__c, acrRec.PRM_Account_Id__r.Core_IPA_Partner_Segment__c);
                }
                if(!ctIdSegmentMap.containsKey(acrRec.PRM_Contact_Id__c)){
                    ctIdSegmentMap.put(acrRec.PRM_Contact_Id__c, acrRec.PRM_Contact_Id__r.Core_IPA_Contact_Segment__c);
                }
                
                if(!String.isEmpty(String.valueOf(acrRec.PRM_Account_Id__r.Core_IPA_Partner_Role__c))){
                    List<String> roles = String.valueOf(acrRec.PRM_Account_Id__r.Core_IPA_Partner_Role__c).split(';');
                    actIdPartnerRoleMap.put(acrRec.PRM_Account_Id__c, roles);
                }
                //}
                //----
                if(contactIdRelName!=null && !contactIdRelName.isEMpty() && contactIdRelName.containsKey(acrRec.PRM_Contact_Id__c)){
                    String str = contactIdRelName.get(acrRec.PRM_Contact_Id__c);
                    str+='-'+acrRec.PRM_Relationship_Id__r.name;
                    contactIdRelName.put(acrRec.PRM_Contact_Id__c, str);
                    
                }else{
                    contactIdRelName.put(acrRec.PRM_Contact_Id__c, acrRec.PRM_Relationship_Id__r.name);
                }
                
                if(newPartnerRoleMap!=null && !newPartnerRoleMap.isEmpty() && contactIdRelName.containsKey(acrRec.PRM_Contact_Id__c)){  // && newPartnerRoleMap.containsKey(acrRec.PRM_Account_Id__c)
                    List<String> newRolList = new List<String>();
                    if(newPartnerRoleMap.containsKey(acrRec.PRM_Account_Id__c)){
                        newRolList =newPartnerRoleMap.get(acrRec.PRM_Account_Id__c);
                    }else if(newPartnerRoleMap.containsKey(acrRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)){
                        newRolList = newPartnerRoleMap.get(acrRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c);
                    }
                    if(newRolList!=null && newRolList.size()>0 && !newRolList.isEmpty()){
                        for(String str : newRolList){
                            List<String> strList = str.split('-');
                            if(strList[0]==acrRec.PRM_Partner_Role__c){
                                contactIdSet.add(acrRec.PRM_Contact_Id__c);
                                Contact con = new Contact();
                                con.id = acrRec.PRM_Contact_Id__c;
                                con.Core_IPA_PartnerRole__c = strList[1];
                                //con.Core_Republish_OBM_s__c = true;
                                if(!contactList.contains(con)){
                                    contactList.add(con);
                                }
                                if(actIdCtIdMap!=null && !actIdCtIdMap.isEmpty() &&actIdCtIdMap.containsKey(acrRec.PRM_Account_Id__c)){
                                    actIdCtIdMap.get(acrRec.PRM_Account_Id__c).add(acrRec.PRM_Contact_Id__c);
                                }else{
                                    actIdCtIdMap.put(acrRec.PRM_Account_Id__c, new Set<id>{acrRec.PRM_Contact_Id__c});
                                }
                                ctIdActIdMp.put(acrRec.PRM_Contact_Id__c,acrRec.PRM_Account_Id__c);
                            }
                        }
                    }
                }
            }
            
            //upsertData(membershipList);
            upsertData(contactList);
            upsertData(acmsTobeUpdated);
            
            //get all Auto assign benefit matrix records
            
            Map<String, List<PRM_VXBnftMatrix__c>> partnerRolVxBftMat = new Map<String, List<PRM_VXBnftMatrix__c>>();
            Map<String, List<PRM_VXBnftMatrix__c>> manualPartnerRolVxBftMat = new Map<String, List<PRM_VXBnftMatrix__c>>();
            //Set<Id> automaticBenefits = new Set<id>(); // automatic benefits
            //Map<Id, Set<String>> benefitIdAccountType = new Map<Id, Set<String>>();
            for(PRM_VXBnftMatrix__c vxbnfRec : [select PRM_Channel_Program_Level_Id__r.name,PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c, PRM_Partner_Role_Nm__c from PRM_VXBnftMatrix__c  where (PRM_Approval_Type_Nm__c =:Label.PRM_ApprovalType or PRM_Approval_Type_Nm__c = 'manual') and PRM_IsActive_Ind__c = true]){
                if(vxbnfRec.PRM_Approval_Type_Nm__c ==Label.PRM_ApprovalType){
                    if(partnerRolVxBftMat.size()>0 && partnerRolVxBftMat.containsKey(vxbnfRec.PRM_Partner_Role_Nm__c+'-'+vxbnfRec.PRM_Channel_Program_Level_Id__r.name)){
                        partnerRolVxBftMat.get(vxbnfRec.PRM_Partner_Role_Nm__c+'-'+vxbnfRec.PRM_Channel_Program_Level_Id__r.name).add(vxbnfRec);
                    }else{
                        partnerRolVxBftMat.put(vxbnfRec.PRM_Partner_Role_Nm__c+'-'+vxbnfRec.PRM_Channel_Program_Level_Id__r.name, new List<PRM_VXBnftMatrix__c>{vxbnfRec});
                    }
                }else{
                    if(manualPartnerRolVxBftMat.size()>0 && manualPartnerRolVxBftMat.containsKey(vxbnfRec.PRM_Partner_Role_Nm__c+'-'+vxbnfRec.PRM_Channel_Program_Level_Id__r.name)){
                        manualPartnerRolVxBftMat.get(vxbnfRec.PRM_Partner_Role_Nm__c+'-'+vxbnfRec.PRM_Channel_Program_Level_Id__r.name).add(vxbnfRec);
                    }else{
                        manualPartnerRolVxBftMat.put(vxbnfRec.PRM_Partner_Role_Nm__c+'-'+vxbnfRec.PRM_Channel_Program_Level_Id__r.name, new List<PRM_VXBnftMatrix__c>{vxbnfRec});
                    }
                }
            }
            
            ////system.debug('partnerRolVxBftMat -->'+partnerRolVxBftMat);
            ////system.debug('accountIdRecTypemap -->'+accountIdRecTypemap);
            
            // get all the ABA records for actIds
            //Map<Id,List<Id>> abaListMap = new Map<Id,List<Id>>(); // account id, ABA record
            Map<Id,List<PRM_AccountBenefitAssociation__c>> actIdabaListMap = new Map<Id,List<PRM_AccountBenefitAssociation__c>>(); // account id, ABA record
            //Map<Id, set<PRM_AccountBenefitAssociation__c>> actbenefitId = new map<Id,Set<PRM_AccountBenefitAssociation__c>>(); // to inactivate manual benefit
            
            Map<id, set<PRM_AccountBenefitAssociation__c>> accountIdSpecialtyABA = new Map<id, set<PRM_AccountBenefitAssociation__c>>();
            
            for(PRM_AccountBenefitAssociation__c abaRec : [select id,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c, PRM_Partner_Benefit_Id__c,PRM_Source__c,PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c  from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in :accountIdRecTypemap.keySet() ]){
                if(abaRec.PRM_Source__c=='Tier' || abaRec.PRM_Source__c == NULL){
                    if(actIdabaListMap.size()>0 && actIdabaListMap.containsKey(abaRec.PRM_Account_Id__c)){
                        actIdabaListMap.get(abaRec.PRM_Account_Id__c).add(abaRec);
                        //system.debug('actIdabaListMap-->'+actIdabaListMap);
                    }else{
                        actIdabaListMap.put(abaRec.PRM_Account_Id__c, new List<PRM_AccountBenefitAssociation__c>{abaRec});
                        //system.debug('actIdabaListMap-->'+actIdabaListMap);
                    }
                }
                if(abaRec.PRM_Source__c =='Select Benefit'){
                    if(accountIdSpecialtyABA.size()>0 && accountIdSpecialtyABA.containsKey(abaRec.PRM_Account_Id__c)){
                        accountIdSpecialtyABA.get(abaRec.PRM_Account_Id__c).add(abaRec);
                    }else{
                        accountIdSpecialtyABA.put(abaRec.PRM_Account_Id__c, new Set<PRM_AccountBenefitAssociation__c>{abaRec});
                    }
                }
            }
            
            //system.debug('actIdabaListMap -->'+actIdabaListMap);
          //  PRM_ProfileResponseApexForABA.UpsertResponseWithoutBenefit(actIdabaListMap);
            Map<Id, List<PRM_AccountBenefitAssociation__c>> actSpecificABAListMp = new  Map<Id, List<PRM_AccountBenefitAssociation__c>>();
            
            //system.debug('finalAcmMap -->'+finalAcmMap);
            
            //if account tier is gold add benefit upto gold if degrade inactive benefit for higher tier
            //if account tier is titanium add benefits upto titanium
            //if account tier is member add benefit upto member
            for(PRM_AccountChannelMembership__c acm : acmsTobeUpdated){
                Id AccountId = acmIdActId.get(acm.Id);
                //system.debug(' aba list -->'+actIdabaListMap.get(AccountId));            //-----
                String key = acm.PRM_Partner_Role__c+'-'+tierIdNames.get(acm.PRM_Channel_Program_Level_Id__c);
                benefitsWrapper bnWrap = setupAddRemoveBenefits(key,acm);
                addBenefitsList = bnWrap.addBenefitsList;
                removeBenefitsList = bnWrap.removeBenefitsList;
                //system.debug(' addBenefitsList -->'+addBenefitsList);
                //system.debug('removeBenefitsList -->'+removeBenefitsList);
                if(actIdabaListMap.size()>0 && actIdabaListMap.containsKey(AccountId)){
                    actSpecificABAList = getListOfBenefits(actIdabaListMap.get(AccountId));// get benefits specific to act
                    
                    List<String> containsBnft = new List<String>();
                    if(partnerRolVxBftMat.size()>0 && partnerRolVxBftMat.containsKey(Key)){
                        for(PRM_VXBnftMatrix__c vxBnft : partnerRolVxBftMat.get(key)){
                            if(!actSpecificABAList.contains(vxBnft.PRM_Partner_Benefit_Id__c)
                               &&(accountIdRecTypemap.get(AccountId) == vxBnft.PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c
                                  || vxBnft.PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c == 'Both') && !containsBnft.contains(vxBnft.PRM_Partner_Benefit_Id__c))
                            {
                                PRM_AccountBenefitAssociation__c aba  = new PRM_AccountBenefitAssociation__c();
                                aba.PRM_Account_Id__c = AccountId;
                                aba.PRM_Partner_Benefit_Id__c = vxBnft.PRM_Partner_Benefit_Id__c;
                                aba.PRM_Status_Nm__c = 'Active';
                                aba.PRM_Source__c ='Tier';
                                actSpecificABAListMp.putAll(getAccountSpecificABA(actSpecificABAListMp, aba, AccountId));
                            }
                        }
                    }
                }
            }
            //system.debug('actSpecificABAListMp -->'+actSpecificABAListMp);
            //system.debug('addBenefitsList -->'+addBenefitsList);
            //system.debug('partnerRolVxBftMat -->'+partnerRolVxBftMat);
            
            Map<id, List<String>> actIdBnftIdListToActive = new Map<id, List<String>>();
            Map<String, boolean> pointOptInCheckMap = new Map<String, boolean>(); // account id -> boolean (update profile reponse  - point opt in che - true)
            Map<id, set<String>> containsBnftMp = new Map<id,set<String>>(); // keeeping this map - not to add duplicate benefits to same account
            for(String str : addBenefitsList){
                //system.debug('Str -->'+str);
                String actId = str.split(';')[0];
                String roleTier = str.split(';')[1];
                actSpecificABAList = getListOfBenefits(actIdabaListMap.get(actId)) ;//abaListMap.get(actId)
                List<Id> abaListEligibleActive=new list<Id>();
             //   abaListEligibleActive=PRM_ProfileResponseApexForABA.getABAAlreadyEligible(actSpecificABAList);
                if(partnerRolVxBftMat!=null && !partnerRolVxBftMat.isEmpty() && partnerRolVxBftMat.containsKey(roleTier)){
                    for(PRM_VXBnftMatrix__c vxBnft : partnerRolVxBftMat.get(roleTier)){
                        if((actSpecificABAList!=null && !actSpecificABAList.contains(vxBnft.PRM_Partner_Benefit_Id__c)) /*|| (abaListEligibleActive!=null && abaListEligibleActive.contains(vxBnft.PRM_Partner_Benefit_Id__c))*/){
                            if((accountIdRecTypemap.get(actId) == vxBnft.PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c || vxBnft.PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c == 'Both') && ((!containsBnftMp.containsKey(actId)) || (containsBnftMp.containsKey(actId) && !containsBnftMp.get(actId).contains(vxBnft.PRM_Partner_Benefit_Id__c)))){
                                PRM_AccountBenefitAssociation__c aba  = new PRM_AccountBenefitAssociation__c();
                                aba.PRM_Account_Id__c = actId;
                                aba.PRM_Partner_Benefit_Id__c = vxBnft.PRM_Partner_Benefit_Id__c;
                                aba.PRM_Status_Nm__c = Label.PRM_Active;
                                aba.PRM_Source__c =Label.PRM_Source;
                                if(containsBnftMp.size()>0 && containsBnftMp.containsKey(actId) && containsBnftMp.get(actId)!=null){
                                    containsBnftMp.get(actId).add(vxBnft.PRM_Partner_Benefit_Id__c);
                                }else{
                                    containsBnftMp.put(actId, new Set<String>{vxBnft.PRM_Partner_Benefit_Id__c});
                                }
                                if(Label.PRM_benefits_for_point_not_eligible_flag.split(';').contains(vxBnft.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c)){pointOptInCheckMap.put(actId, true);}
                                actSpecificABAListMp.putAll(getAccountSpecificABA(actSpecificABAListMp, aba, actId));
                            }
                        }else{
                             // add here the benefits which needs to be activated but are inactive
                        
                                if(actIdBnftIdListToActive!=null && !actIdBnftIdListToActive.isEmpty() && actIdBnftIdListToActive.containsKey(actId)){
                                    actIdBnftIdListToActive.get(actId).add(vxBnft.PRM_Partner_Benefit_Id__c);
                                }else{
                                    actIdBnftIdListToActive.put(actId, new List<String>{vxBnft.PRM_Partner_Benefit_Id__c});
                                }
                        
                        }
                    }
                }
            }
            
            //system.debug('actIdBnftIdListToActive -->'+actIdBnftIdListToActive);
            //system.debug('actSpecificABAListMp -->'+actSpecificABAListMp);
            List<PRM_AccountBenefitAssociation__c> abaTempList = new List<PRM_AccountBenefitAssociation__c>();
            for(List<PRM_AccountBenefitAssociation__c> abaTmp : actIdabaListMap.values()){
                abaTempList.addAll(abaTmp);
            }
            
            //system.debug('abaTempList -->'+abaTempList);
            
            for(PRM_AccountBenefitAssociation__c abaRec : abaTempList){
                if(actIdBnftIdListToActive!=null && !actIdBnftIdListToActive.isEmpty() && actIdBnftIdListToActive.containsKey(abaRec.PRM_Account_Id__c)){
                    for(String bnftId : actIdBnftIdListToActive.get(abaRec.PRM_Account_Id__c)){
                        if(abaRec.PRM_Partner_Benefit_Id__c == bnftId && abaRec.PRM_Status_Nm__c=='Inactive'){
                            abaRec.PRM_Status_Nm__c=Label.PRM_Active;
                            abaRec.PRM_Status_Reason_Txt__c=Label.PRM_ACM_ABA_Automation_Reason;
                            abaRec.PRM_Source__c =Label.PRM_Source;//Updating Source as Tier while reactivating inactive benefits - TWC729-3613
                            if(!finalABAList.contains(abaRec)){
                                finalABAList.add(abaRec);
                            }
                        }
                    }
                }
            }
            
            //system.debug('finalABAList -->'+finalABAList);
            
            //iterate orver benefit matrix
            Map<String, List<String>> removeActBnftRecMap = new Map<String, List<String>>();
            List<String> removeActBnftRecLst = new List<String>();
            for(String str : removeBenefitsList){
                String accountId = str.split(';')[0];
                String roleTier = str.split(';')[1];
                if(actIdabaListMap.containsKey(accountId)){
                    if(partnerRolVxBftMat!=null && !partnerRolVxBftMat.isEmpty() && partnerRolVxBftMat.containsKey(roleTier)){
                        for(PRM_VXBnftMatrix__c vx : partnerRolVxBftMat.get(roleTier)){
                            if(!removeActBnftRecLst.contains(accountId+'-'+vx.PRM_Partner_Benefit_Id__c)){
                                removeActBnftRecLst.add(accountId+'-'+vx.PRM_Partner_Benefit_Id__c);
                            }
                        }
                    }
                }
            }
            
            //system.debug('removeActBnftRecLst -->'+removeActBnftRecLst);
            
            for(String str : removeActBnftRecLst){
                List<String>  strList = str.split('-');
               if(actIdabaListMap.size()>0 && actIdabaListMap.containsKey(strList[0])){
                    for(PRM_AccountBenefitAssociation__c aba : actIdabaListMap.get(strList[0])){
                        List<Id> bnftIds = new List<Id>();
                        if(actIdBnftIdListToActive.containsKey(aba.PRM_Account_Id__c)){
                            bnftIds = actIdBnftIdListToActive.get(aba.PRM_Account_Id__c);
                        }
                         if(actIdRoleTierMap.containsKey(aba.PRM_Account_Id__c)){
                            tempKey =  actIdRoleTierMap.get(aba.PRM_Account_Id__c);
                            tierId = tempKey.split('-')[1];
                            tierName = tierIdNames.get(tierId);
                            key = tempKey.split('-')[0] + '-' + tierName;
                         }
                        //system.debug('tempKey:'+tempKey);
                        //system.debug('key:'+key);
                      //  //system.debug('ben Matrix:'+manualPartnerRolVxBftMat.get(key).toString());
                        Boolean isManualBenEligible = checkIfManualBenefitEligible(manualPartnerRolVxBftMat, key, aba.PRM_Partner_Benefit_Id__c); 
                        
                        if(aba.PRM_Partner_Benefit_Id__c == strList[1] && aba.PRM_Status_Nm__c != Label.PRM_Status_Inactive){
                            if(!isManualBenEligible && !finalABAList.contains(aba) && !bnftIds.contains(aba.PRM_Partner_Benefit_Id__c)){
                                aba.PRM_Status_Nm__c = Label.PRM_Status_Inactive;
                                //system.debug('aba.PRM_Partner_Benefit_Id__c:'+aba.PRM_Partner_Benefit_Id__c);
                                aba.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
                                finalABAList.add(aba);
                            }
                        }
                    }
                }
           }
            
            //system.debug('finalABAList -->'+finalABAList);
            
            //create segregated map of accouts wih benefits
            //system.debug('actSpecificABAListMp -->'+actSpecificABAListMp);
            
            for(List<PRM_AccountBenefitAssociation__c> aba : actSpecificABAListMp.values()){
                for(PRM_AccountBenefitAssociation__c abaRec : aba){
                    abaRec.PRM_Status_Nm__c = Label.PRM_Active;
                    abaRec.PRM_Status_Reason_Txt__c=Label.PRM_ACM_ABA_Automation_Reason;
                    if(!finalABAList.contains(abaRec)){
                        finalABAList.add(abaRec);
                    }
                }
            }
            // inactivating manualbenefits
            List<String> actIdBnftIdAdded = new List<String>(); // accountId+BenefitId - benefits which will be added at account
           list<string> mpBenfitsCode=new list<string>();
       mpBenfitsCode.addAll(Label.PRM_SkipMPBenefits.split(';'));   
           //system.debug('mpBenfitsCode-->'+mpBenfitsCode);
            for(PRM_AccountBenefitAssociation__c abaRecord : finalABAList){
                actIdBnftIdAdded.add(abaRecord.PRM_Account_Id__c+'-'+abaRecord.PRM_Partner_Benefit_Id__c);
            }
            
            Set<String> actIdBenftIdPresent =  new Set<String>();
        Set<Id> opidsToMPIdeactivation = new Set<Id>();
        for(List<PRM_AccountBenefitAssociation__c> abaRecordList : actIdabaListMap.values()){
                for(PRM_AccountBenefitAssociation__c abaRecord : abaRecordList){
                    List<Id> bnftIds = new List<Id>();
                    if(actIdBnftIdListToActive.containsKey(abaRecord.PRM_Account_Id__c)){
                        bnftIds = actIdBnftIdListToActive.get(abaRecord.PRM_Account_Id__c);
                    }
                    if(actIdRoleTierMap.containsKey(abaRecord.PRM_Account_Id__c)){
                     tempKey =  actIdRoleTierMap.get(abaRecord.PRM_Account_Id__c);
                     tierId = tempKey.split('-')[1];
                     tierName = tierIdNames.get(tierId);
                     key = tempKey.split('-')[0] + '-' + tierName;
                    }
                    //system.debug('tempKey:'+tempKey);
                    //system.debug('key:'+key);
                   // //system.debug('ben Matrix:'+manualPartnerRolVxBftMat.get(key).toString());
                    Boolean isManualBenEligible = checkIfManualBenefitEligible(manualPartnerRolVxBftMat, key, abaRecord.PRM_Partner_Benefit_Id__c); 
                if(((actSpecificABAListMp.containsKey(abaRecord.PRM_Account_Id__c) && actSpecificABAListMp.get(abaRecord.PRM_Account_Id__c).toString().contains(abaRecord.PRM_Partner_Benefit_Id__c)) || !isManualBenEligible) && !actIdBnftIdAdded.contains(abaRecord.PRM_Account_Id__c+'-'+abaRecord.PRM_Partner_Benefit_Id__c) && !bnftIds.contains(abaRecord.PRM_Partner_Benefit_Id__c)  /*&& !mpBenfitsCode.contains(abaRecord.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c)*/){
                        // inactivate this record                        
                    if (mpBenfitsCode.contains(abaRecord.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c) ) {
                        opidsToMPIdeactivation.add(abaRecord.PRM_Account_Id__c);
                    }                        
                        abaRecord.PRM_Status_Nm__c = Label.PRM_Status_Inactive;
                        abaRecord.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
                        //system.debug('abaRecord.PRM_Partner_Benefit_Id__c-->'+abaRecord.PRM_Partner_Benefit_Id__c);
                        //system.debug('actIdBnftIdAdded-->'+actIdBnftIdAdded);
                        if(!finalABAList.contains(abaRecord)){
                            finalABAList.add(abaRecord);
                        }
                    }
                }
            }
            //actIdabaListMap
            
            //system.debug('finalABAList -->'+finalABAList); 
            finalABAList.addAll(updateASARecords(accountIdRecTypemap.keySet(), accountIdSpecialtyABA,accIdOldNewPartnerRoleMap));
            //system.debug('finalABAList -->'+finalABAList);            
            //profileResponseOnBenefitUpdate(locationACMForProfileResponse);
            updateContactAndAccountSegment(newPartnerRoleMap,ctIdActIdMp);
        //sk = prm_skip_trigger__c.getInstance('ABA_Trigger');
        //sk.inactive__c = true;
        //update sk;
        PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = true;
        upsertData(finalABAList);
            proccessEntitlement();
          //  PRM_accBenefitAssociationUtility.profileResponseOnBenefitUpdate(finalABAList); //---->when aba status changed--->pr-->change
            //system.debug('Heap size -->'+Limits.getHeapSize());
        if (!opidsToMPIdeactivation.isEmpty()) {
            List<PMP_OPID_MPI_Rel__c> opidMps = [SELECT Id,Is_Active__c FROM PMP_OPID_MPI_Rel__c WHERE PMP_One_Partner_ID__c IN:opidsToMPIdeactivation AND Is_Active__c = TRUE ];
            //system.debug('opidMps -->'+opidMps);
            if (!opidMps.isEmpty()) {
                for (PMP_OPID_MPI_Rel__c opidmp : opidMps) {
                    opidmp.Is_Active__c = FALSE;
                }
                
                update opidMps;
            }
        }
        }catch(Exception ex){
            //system.debug('Error -->'+ex.getMessage());
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, ex.getMessage(), '', null, null, '');
        }finally{
            sk = prm_skip_trigger__c.getInstance('ABA_Trigger');
            sk.inactive__c = false;
            update sk;
        }
    }
    
    private static boolean checkIfManualBenefitEligible(Map<String, List<PRM_VXBnftMatrix__c>> manualPartnerRolVxBftMat, String key, id benfitId){
              List<String> keyList = new List<String>();
        Boolean isEligible = false;
        if(string.isNotBlank(key) && key.contains('-')){
        String tierName = key.split('-')[1];
        Integer rank = tierRank.get(tierName);
       
        if(rank == 3){
                                           keyList.add(key);
            keyList.add(key.split('-')[0] + '-' +label.PRM_Tier_Gold );
            keyList.add(key.split('-')[0] + '-' +label.PRM_Program_Level_Member );
        }else if(rank == 2){
              keyList.add(key);           
            keyList.add(key.split('-')[0] + '-' +label.PRM_Program_Level_Member );   
        }else{
                                           keyList.add(key);             
        }
      }
        for(String key1: keyList){
            if(manualPartnerRolVxBftMat.containsKey(key1) && manualPartnerRolVxBftMat.get(key1).toString().contains(benfitId)){
                isEligible = true;
            }
        }
       
        return isEligible;
    }
    
    // update Account and Contact segment on Partner role update
    public List<Sobject> updateContactAndAccountSegment(Map<Id,List<String>> newPartnerRoleMap, Map<Id, Id> ctIdActIdMp){
        //system.debug('newPartnerRoleMap -->'+newPartnerRoleMap);
        //system.debug('ctIdActIdMp -->'+ctIdActIdMp);                
        String AccountPartnerSegment;
        String ContactPartnerSegment;        
        Map<String,String> segTypeMap = new Map<String,String>();
        Map<id,Account> accMap = new Map<id,Account>();
        for(Account acc : [select id, Core_IPA_Partner_Segment__c,Core_IPA_Partner_Role__c from Account where id IN: newPartnerRoleMap.keySet()])
        {
            accMap.put(acc.id,acc);
        }
        for(PRM_PartnerRoleTypeMappings__mdt segTypeReq : [Select Id,PRM_Partner_Role__c,PRM_Partner_Segment__c
                                                                from PRM_PartnerRoleTypeMappings__mdt where PRM_Partner_Segment__c != null])
        {
            segTypeMap.put(segTypeReq.PRM_Partner_Role__c,segTypeReq.PRM_Partner_Segment__c);
        }
        //system.debug('segTypeMap -->'+segTypeMap);
        Account acc;
        Map<String, boolean> pointFlagCheckMap = new Map<String, boolean>();
        for(Id accountId:newPartnerRoleMap.keySet()){
            AccountPartnerSegment='';
            for(String oldNewRole : newPartnerRoleMap.get(accountId)){
                String newRole =  oldNewRole.split('-')[1];
                AccountPartnerSegment+=(segTypeMap.get(newRole)!=null?segTypeMap.get(newRole):'');
                if(label.PRM_RolesEligibleForPointsBenefits.split(';').contains(newRole)){
                    pointFlagCheckMap.put(accountId,true);
                    //system.debug('newRole-->'+newRole);
                    //system.debug('pointFlagCheckMap-->'+pointFlagCheckMap);
                    }
                    else{
                        pointFlagCheckMap.put(accountId,false);
                        //system.debug('newRole-->'+newRole);
                        //system.debug('pointFlagCheckMap-->'+pointFlagCheckMap);
                    }
            }
            acc =  accMap.get(accountId);
            acc.Id = accountId;
            acc.Core_IPA_Partner_Segment__c =AccountPartnerSegment;
            if(!updateAccountandContact.contains(acc)){updateAccountandContact.add(acc);}
        }
        PRM_ProfileResponse.fromPointsCalculation=true;
        if(isPartnerRoleChanged==true){

        PRM_ProfileResponseApexForABA.updateProfileResponse(pointFlagCheckMap);
            
        }
        //PRM_ProfileResponseApexForABA.updateProfileResponse(pointFlagCheckMap);
        //system.debug(' '+updateAccountandContact);
        
        Contact ct;
        for(Id contactId: ctIdActIdMp.keySet()){
            ContactPartnerSegment='';
            for(String oldNewRole : newPartnerRoleMap.get(ctIdActIdMp.get(contactId))){
                String newRole =  oldNewRole.split('-')[1];
                ContactPartnerSegment+=(segTypeMap.get(newRole)!=null?segTypeMap.get(newRole):'');
            }
            ct = new contact();
            ct.Id = contactId;
            ct.Core_IPA_Contact_Segment__c = ContactPartnerSegment;
            if(!updateAccountandContact.contains(ct)){updateAccountandContact.add(ct);}
        }
        //system.debug('updateAccountandContact -->'+updateAccountandContact);
        
        return updateAccountandContact;
        
    }
        
    //COMMON METHOD TO INSERT OR UPDATE LIST OF RECORDS
    public static void upsertData(List<SObject> newLst) {   
         List<Id> conQueueFullLst=new List<Id>(); 
        // //system.debug('newLst -->'+newLst);
        if(newLst!=null && !newLst.isEmpty()) {
            Database.UpsertResult[] urList = Database.upsert(newLst, false);
            Integer index = 0;
            for(Database.UpsertResult ur : urList){
                if(!ur.isSuccess()){ 
                    Id accountId;
                    Id failedRecordId;
                    if(newLst[index] instanceof PRM_AccountChannelMembership__c){
                        PRM_AccountChannelMembership__c acm =(PRM_AccountChannelMembership__c) newLst[index];
                        accountid = acm.PRM_Account_Id__c;
                        failedRecordId=acm.Id;
                    }
                    if(newLst[index] instanceof Account){
                        Account act = (Account)newLst[index];
                        accountId = act.Id;
                        failedRecordId=act.Id;
                    }
                    if(newLst[index] instanceof Contact){
                        Contact ct = (Contact)newLst[index]; 
                        accountId = ct.AccountId;
                        failedRecordId=ct.Id;
                        conQueueFullLst.add(ct.Id);
                        //system.debug('conQueueFullLst-->'+conQueueFullLst);
                    }
                    
                    if(newLst[index] instanceof PRM_AccountBenefitAssociation__c){
                       PRM_AccountBenefitAssociation__c aba =(PRM_AccountBenefitAssociation__c)newLst[index];
                        accountId = aba.PRM_Account_Id__c;
                        failedRecordId=aba.PRM_Partner_Benefit_Id__c;
                    }
                    //system.debug('accountId -->'+accountId);
                    //system.debug('failedRecordId -->'+failedRecordId);
                    
                    Id sId;
                    string sObjectType = '';
                    string tags = '';
                    for(Database.Error err : ur.getErrors()){
                        
                        //system.debug('Error -->'+err.getMessage());
                        if(memResponseWrapper.size()>0 && memResponseWrapper.containsKey(accountId) && !String.valueOf(err.getMessage()).contains('duplicate')){
                            MembershipWrapper m = memResponseWrapper.get(accountId);
                            m.errorMessage = 'Record failed for Account : '+accountId+' with Id : '+failedRecordId;                            
                            memResponseWrapper.put(accountId, m);
                            
                        }                        
                        sId = newLst[index].Id;
                        if(sId != null)
                        {
                            sObjectType = sId.getSObjectType().getDescribe().getName();
                        }                        
                        Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, err.getMessage(), '', sId, sObjectType, tags);
                    }
                }
                index++;
                
            }
                   //PRM_RepublishContactsForRoleTier.UpdateRepublishOnContact(conQueueFullLst);//subhadeep Lata changes
        }
       
    }
    
    // UPDATE ACCOUNT SPECIALTY ASSOCIATION IF NOT APPLICABLE
    public List<PRM_AccountBenefitAssociation__c> updateASARecords(set<Id> accountIds,Map<id, set<PRM_AccountBenefitAssociation__c>> accountIdSpecialtyABA, Map<Id, String> accIdOldNewPartnerRoleMap){
        
        // //system.debug('accountIds -->'+accountIds);
        
        List<PRM_Account_Specialty_Association__c> asaToUpdateList = new List<PRM_Account_Specialty_Association__c>();
        Map<id,Set<id>> actIdspecialtyIds = new Map<Id,Set<id>>();
        set<Id> specialtyIds = new Set<Id>();
        for(PRM_Account_Specialty_Association__c asaRec : [select id,PRM_Account_Id__c, PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Specialty_Id__c,PRM_InActive_Ind__c,  PRM_Specialty_Id__r.PRM_Role_Nm__c,PRM_Partner_Role__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__c in :accountIds and PRM_InActive_Ind__c=false]){// and PRM_Specialty_Type__c='Specialty'
            specialtyIds.add(asaRec.PRM_Specialty_Id__c);
            List<String> speciRole = asaRec.PRM_Specialty_Id__r.PRM_Role_Nm__c.split(';');
            String oldPartnerRole = asaRec.PRM_Account_Id__r.Core_IPA_Partner_Role__c != null ?
                asaRec.PRM_Account_Id__r.Core_IPA_Partner_Role__c.split(';')[0] :
                accIdOldNewPartnerRoleMap.get(asaRec.PRM_Account_Id__c);
            if(speciRole.size()>0 && !speciRole.contains(oldPartnerRole)){
                asaRec.PRM_InActive_Ind__c = true;
                asaRec.PRM_Status_Reason_Txt__c = Label.PRM_ACM_ABA_Automation_Reason;
                asaToUpdateList.add(asaRec);
            }else{
                if(actIdRoleTierMap.get(asaRec.PRM_Account_Id__c) != null && actIdRoleTierMap.get(asaRec.PRM_Account_Id__c).contains('-')){
                    asaRec.PRM_Partner_Role__c=actIdRoleTierMap.get(asaRec.PRM_Account_Id__c).split('-')[0];
                }else{
                    asaRec.PRM_Partner_Role__c = oldPartnerRole;
                }
                asaToUpdateList.add(asaRec);
                if(actIdspecialtyIds.size()>0 && actIdspecialtyIds.containsKey(asaRec.PRM_Account_Id__c) && actIdspecialtyIds.get(asaRec.PRM_Account_Id__c)!=null){
                    actIdspecialtyIds.get(asaRec.PRM_Account_Id__c).add(asaRec.PRM_Specialty_Id__c);
                }else{
                    actIdspecialtyIds.put(asaRec.PRM_Account_Id__c, new Set<Id>{asaRec.PRM_Specialty_Id__c});
                }
            }
            
        }
        
        Map<Id, set<Id>> specialtyIdBenefitIds  = getSepcialtyBenefitGroupBnftIds(specialtyIds);
        Map<Id, set<Id>> accountApplicableBenefits = new Map<Id, set<Id>>();
        
        // check applicable benefits for specialty at account
        for(Id accountId : actIdspecialtyIds.keySet()){
            Set<id> benefitIds =  new set<id>();
            for(Id specialtyId : actIdspecialtyIds.get(accountId)){
                if(specialtyIdBenefitIds.size()>0 && specialtyIdBenefitIds.containsKey(specialtyId) && specialtyIdBenefitIds.get(specialtyId)!=null){
                    benefitIds.addAll(specialtyIdBenefitIds.get(specialtyId));
                }
            }
            if(benefitIds.size()>0){
                accountApplicableBenefits.put(accountId,benefitIds);
            }
        }
        //system.debug('specialtyIdBenefitIds -->'+specialtyIdBenefitIds);
        //system.debug('accountApplicableBenefits -->'+accountApplicableBenefits);
        // inactive benefits which are not applicable
        List<PRM_AccountBenefitAssociation__c> benefitsToInactive = new List<PRM_AccountBenefitAssociation__c>();
        for(id accountId : accountIdSpecialtyABA.keySet()){
            Set<Id> bnftIds = new Set<Id>();
            if(accountApplicableBenefits.size()>0 && accountApplicableBenefits.containsKey(accountId) && accountApplicableBenefits.get(accountId)!=null ){
                bnftIds = accountApplicableBenefits.get(accountId);
                //system.debug('bnftIds -->'+bnftIds);
            }
            for(PRM_AccountBenefitAssociation__c aba : accountIdSpecialtyABA.get(accountId)){
                if(!bnftIds.contains(aba.PRM_Partner_Benefit_Id__c)){
                    aba.PRM_Status_Nm__c = Label.PRM_Status_Inactive;
                    aba.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
                    benefitsToInactive.add(aba);
                }
            }
            
        }
        //system.debug('benefitsToInactive -->'+benefitsToInactive);
        //system.debug('asaToUpdateList -->'+asaToUpdateList);
        
        if(asaToUpdateList!=null && !asaToUpdateList.isEmpty()){
            upsertData(asaToUpdateList);
        }
        return benefitsToInactive;
    }
    
    public Map<Id, set<Id>> getSepcialtyBenefitGroupBnftIds(Set<Id> specialtyIds){
        
        // get specialtyBenefitgroup
        Map<Id, Id> specialtyIdBenefitGroupId = new Map<Id, Id>();
        for(PRM_Specialty_Benefit_Group_Association__c spbga : [select id, PRM_Specialty_Id__c,  PRM_Benefit_Group_Id__c from PRM_Specialty_Benefit_Group_Association__c where PRM_Specialty_Id__c in:specialtyIds order by PRM_Specialty_Id__c] ){
            specialtyIdBenefitGroupId.put(spbga.PRM_Specialty_Id__c, spbga.PRM_Benefit_Group_Id__c);
        }
        //system.debug('specialtyIdBenefitGroupId -->'+specialtyIdBenefitGroupId);
        
        // get benefits of benefit group
        Map<Id, set<Id>> specialtyIdBenefitIds = new map<Id, Set<Id>>();
        for( PRM_Benefit_Group_Benefit_Association__c bgba : [select PRM_Benefit_Id__c, PRM_Benefit_Group_Id__c from PRM_Benefit_Group_Benefit_Association__c where PRM_Benefit_Group_Id__c in :specialtyIdBenefitGroupId.values()]){
            if(specialtyIdBenefitIds.size()>0 && specialtyIdBenefitIds.containsKey(bgba.PRM_Benefit_Group_Id__c) && specialtyIdBenefitIds.get(bgba.PRM_Benefit_Group_Id__c)!=null){
                specialtyIdBenefitIds.get(bgba.PRM_Benefit_Group_Id__c).add(bgba.PRM_Benefit_Id__c);
            }else{
                specialtyIdBenefitIds.put(bgba.PRM_Benefit_Group_Id__c,new Set<Id>{bgba.PRM_Benefit_Id__c});
            }
        }
        Map<id, Set<id>> specIdBnftIdMap = new Map<id, Set<id>>();
        for(id specId : specialtyIdBenefitGroupId.keySet()){
            if(specialtyIdBenefitIds.size()>0 && specialtyIdBenefitIds.containsKey(specialtyIdBenefitGroupId.get(specId)) && specialtyIdBenefitIds.get(specialtyIdBenefitGroupId.get(specId))!=null){
                specIdBnftIdMap.put(specId,specialtyIdBenefitIds.get(specialtyIdBenefitGroupId.get(specId)));
            }
        }
        //system.debug('specIdBnftIdMap -->'+specIdBnftIdMap);
       
        return specIdBnftIdMap;
    }
    
    //RETURN BENEFIT LIST specifi to ACCOUNT
    public static List<String> getListOfBenefits(List<PRM_AccountBenefitAssociation__c> abaList){
        List<String> benefits = new List<String>();
        if(abaList!=null && !abaList.isEmpty()){
            for(PRM_AccountBenefitAssociation__c abaRec : abaList){
                benefits.add(abaRec.PRM_Partner_Benefit_Id__c);
            }
        }
        return benefits;
    }
    
    //GET OLD PARTNER ROLES
    public static List<String> getOldPartnerRole(List<String> newPartnerRoleMapValues){
        List<String> oldPartnerRoles = new List<String>();
        for(String roles : newPartnerRoleMapValues){
            oldPartnerRoles.add(roles.split('-')[0]);
        }
        return oldPartnerRoles;
    }
    
    //SETUP BENEFITS TO ADD OR REMOVE
    public static benefitsWrapper setupAddRemoveBenefits(String key,PRM_AccountChannelMembership__c acm){
        String key1;
        String key2;
        String key3;
        String keyToRemove1;
        String keyToRemove2;
        String keyToRemove3;
        
        Integer rank = tierRank.get(tierIdNames.get(acm.PRM_Channel_Program_Level_Id__c));
        
        ////system.debug('Key -->'+key);
        //remove all benefits with respect to old partner role
        if(oldAcmIdPartnerRole!=null && oldAcmIdPartnerRole.containsKey(acm.Id) && (oldAcmIdPartnerRole.get(acm.Id)!=acm.PRM_Partner_Role__c || acm.PRM_Status_Nm__c == 'Inactive')){
            keyToRemove1 = acmIdActId.get(acm.Id)+';'+oldAcmIdPartnerRole.get(acm.Id)+'-'+Label.PRM_Program_Level_Member;
            keyToRemove2= acmIdActId.get(acm.Id)+';'+oldAcmIdPartnerRole.get(acm.Id)+'-'+Label.PRM_Tier_Gold;
            keyToRemove3= acmIdActId.get(acm.Id)+';'+oldAcmIdPartnerRole.get(acm.Id)+'-'+Label.PRM_Tier_Titanium;
            if(!removeBenefitsList.contains(keyToRemove1)){
                removeBenefitsList.add(keyToRemove1);
            }
            if(!removeBenefitsList.contains(keyToRemove2)){
                removeBenefitsList.add(keyToRemove2);
            }
            if(!removeBenefitsList.contains(keyToRemove3)){
                removeBenefitsList.add(keyToRemove3);
            }
            
        }
        // common for MEMBER, GOLD, TITANIUM
        key1 = acmIdActId.get(acm.Id)+';'+acm.PRM_Partner_Role__c+'-'+Label.PRM_Program_Level_Member;
        if(!addBenefitsList.contains(key1) && acm.PRM_Status_Nm__c != 'Inactive'){
            addBenefitsList.add(key1);
        }
        
        if(rank==1 || rank ==2){
            keyToRemove2= acmIdActId.get(acm.Id)+';'+acm.PRM_Partner_Role__c+'-'+Label.PRM_Tier_Titanium;
            if(!removeBenefitsList.contains(keyToRemove2)){
                removeBenefitsList.add(keyToRemove2);
            }
        }
        if((rank==2 || rank==3) && acm.PRM_Status_Nm__c != 'Inactive'){
            key2 = acmIdActId.get(acm.Id)+';'+acm.PRM_Partner_Role__c+'-'+Label.PRM_Tier_Gold;
            if(!addBenefitsList.contains(key2)){
                addBenefitsList.add(key2);
            }
        }
        if(rank==1){
            keyToRemove1= acmIdActId.get(acm.Id)+';'+acm.PRM_Partner_Role__c+'-'+Label.PRM_Tier_Gold;
            if(!removeBenefitsList.contains(keyToRemove1)){
                removeBenefitsList.add(keyToRemove1);
            }
            
        }else if(rank == 3 && acm.PRM_Status_Nm__c != 'Inactive'){
            key3 = acmIdActId.get(acm.Id)+';'+acm.PRM_Partner_Role__c+'-'+Label.PRM_Tier_Titanium;
            if(!addBenefitsList.contains(key3)){
                addBenefitsList.add(key3);
            }
        }
        //system.debug('addBenefitsList -->'+addBenefitsList);
        //system.debug('removeBenefitsList -->'+removeBenefitsList);
        
        benefitsWrapper bnwrap = new benefitsWrapper();
        bnwrap.removeBenefitsList=removeBenefitsList;
        bnwrap.addBenefitsList=addBenefitsList;
        return bnwrap;
    }
    
    public static Map<id, List<PRM_AccountBenefitAssociation__c>> getAccountSpecificABA(Map<id, List<PRM_AccountBenefitAssociation__c>> actSpecificABAListMp, PRM_AccountBenefitAssociation__c aba, Id accountId){
        if(actSpecificABAListMp!=null && !actSpecificABAListMp.isEmpty() && actSpecificABAListMp.containsKey(accountId)){//acmIdActId.get(acm.Id)
            List<PRM_AccountBenefitAssociation__c> abaList = actSpecificABAListMp.get(accountId);//acmIdActId.get(acm.Id)
            if(!abaList.contains(aba)){
                abaList.add(aba);
                actSpecificABAListMp.put(accountId,abaList);//acmIdActId.get(acm.Id)
            }
        }else{
            actSpecificABAListMp.put(accountId, new List<PRM_AccountBenefitAssociation__c>{aba});//acmIdActId.get(acm.Id)
        }
        return actSpecificABAListMp;
    }
    
    // CREATE LIST MAP OF ACM's
    public static Map<id, List<PRM_AccountChannelMembership__c>> getAcmListMap(PRM_IPA_Membership__c ipameme,PRM_AccountChannelMembership__c acm) {
        if(opidACMListMap!=null && !opidACMListMap.isEmpty() && opidACMListMap.containsKey(ipameme.PRM_Account_Id__c)) {//PRM_Account_Id__c
            opidACMListMap.get(ipameme.PRM_Account_Id__c).add(acm);// reduce lines
        }else{
            opidACMListMap.put(ipameme.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acm});
        }
        return opidACMListMap;
    }
    
    // GET ALL CHANNEL PROGRAM LEVEL RECORD BASED ON PROGRAM
    public static Map<Id, String> getIPACPL(string program){
        Map<id, String> tierIdsCPL =  new Map<id, String>();
        for(ChannelProgramLevel cpl :[select id, name from ChannelProgramLevel where  Program.PRM_programCode__c= 'IPA']){ // label to be used
            tierIdsCPL.put(cpl.Id,cpl.Name);
            
        }
        //system.debug('tierIdsCPL'+tierIdsCPL);
        return tierIdsCPL;
    }
    
    // Assign Entitlement once ACM Updation is done
    public static void proccessEntitlement(){
        PRM_EntitlementResponseWrapper entWrap = new PRM_EntitlementResponseWrapper();
        entWrap.accountIdRecTypemap = accountIdRecTypemap;
        entWrap.actIdCtIdMap = actIdCtIdMap;
        entWrap.actIdRoleTierMap = actIdRoleTierMap;
        entWrap.contactIdRelName = contactIdRelName;
        entWrap.contactIdSet = contactIdSet;
        entWrap.ctIdActIdMp = ctIdActIdMp;
        entWrap.tierIdNames = tierIdNames;
        entWrap.newPartnerRoleMap = newPartnerRoleMap;
        entWrap.OPIDContIdMap=OPIDContIdMap;
        PRM_ACMUpdateAssignEntitlment assignEnt = new PRM_ACMUpdateAssignEntitlment();
        entitlementsTOUpsert  = assignEnt.AssignEntitlements(entWrap);
    }
    
    //BENEFITS WRAPPER
    public class benefitsWrapper{
        List<String> removeBenefitsList{get;set;}
        List<String> addBenefitsList{get;set;}
    }
    
}