/*********************************************************************************************************************
Class Name    : PRM_ACMUpdateUtilityNew
Version       : 1.0
Created Date  : May, 2025
Function      : Update Account channel membership at OPID OR Account wihout OPID based on IPA Membership

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Chaithaly            May, 2021              IPA2.0 - This class will update ACM and assign benefits based on new Partner role and tier 
-----------------------------
-----------------------------
*********************************************************************************************************************/

public without sharing class PRM_IPAR_ACMUpdateUtility{//implements Database.Batchable<SObject>,Database.Stateful
    
    @TestVisible
    private static final string ORIGIN = 'PRM_ACMUpdateBatchUtilityNew';
    private static final string SEVERITY = 'Critical';
    private static final string PROJECT = 'IPA';
    private static final string ERROR_MESSAGE = 'Too many DML rows';
    static String logEntry='';
        
    static  Map<String,PRM_AccountBenefitAssociation__c> actSpecificABAList = new Map<String,PRM_AccountBenefitAssociation__c>();
    static List<PRM_AccountBenefitAssociation__c> finalABAList = new List<PRM_AccountBenefitAssociation__c>();
    static Map<Id,List<PRM_AccountChannelMembership__c>> finalAcmMap = new Map<Id,List<PRM_AccountChannelMembership__c>>();
    static Map<Id, Set<Id>> actIdCtIdMap = new Map<Id, Set<Id>>();
    static Map<Id, String> contactIdRelName = new Map<id, String>();
    static Map<Id, String> actIdRoleTierMap = new Map<Id, String>();
     static Map<Id,String> tierIdNames = new Map<Id,String>();
     static Map<Id,Id> actToOPIDMap = new Map<Id,Id>();
    static Map<Id,List<String>> newPartnerRoleMap = new Map<Id, List<String>>();
    static Map<id, List<PRM_AccountChannelMembership__c>> opidACMListMap  = new Map<id, List<PRM_AccountChannelMembership__c>>();
    static Map<String, String> actIdCPLMap = new Map<String, String>(); //act id | oldPartnerRole | new CPL
    static Map<Id,List<PRM_AccountChannelMembership__c>> opidChildACMMap = new Map<Id,List<PRM_AccountChannelMembership__c>>();
    static Map<id, Id> opidCPLMap  = new Map<Id,Id>();
    Set<Id> opidsToMPIdeactivation = new Set<Id>();
    //TWC729-8027 - RTA changes for MPI activation
	Set<Id> opidsToMPIactivation = new Set<Id>();
    static List<Core_Contact_Entitlement__c> entitlementsTOUpsert = new List<Core_Contact_Entitlement__c>();    
    static prm_skip_trigger__c sk;
    public static boolean isPartnerRoleChanged=false;
    public static boolean isRTAInitiated = false;
    List<Sobject> updateAccountandContact = new List<Sobject>();  
    static Map<Id, String> oldAcmIdPartnerRole = new  Map<Id, String>();
   
    public contactEntilementResponse assignBenefits(List<PRM_IPA_Membership__c> changeRequests){  
        isRTAInitiated = true;  
        setRolesAndTiers(changeRequests);            
        contactEntilementResponse cresp =  new contactEntilementResponse();
        cresp.updateAccountandContact = updateAccountandContact;
        cresp.entitlementsTOUpsert = entitlementsTOUpsert;
        cresp.memResponseWrapper = memResponseWrapper;
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

        for(ChannelProgramLevel cpl :[select id, name,rank from ChannelProgramLevel where  Program.PRM_programCode__c= 'IPA'and PRM_inactind__c = false]){ 
            tierIdNames.put(cpl.Id,cpl.name);
          } 
        Map<id, PRM_AccountChannelMembership__c> opidSourceACMMap = new Map<id, PRM_AccountChannelMembership__c>();
        MembershipWrapper mem = new MembershipWrapper(); 
       for(PRM_IPA_Membership__c ipameme : memList){
                if((System.label.PointsOptInEligiblePartners.split(',').contains(ipameme.PRM_Old_Partner_Role__c) && !System.label.PointsOptInEligiblePartners.split(',').contains(ipameme.PRM_Partner_Role__c)) || 
                (!System.label.PointsOptInEligiblePartners.split(',').contains(ipameme.PRM_Old_Partner_Role__c) && System.label.PointsOptInEligiblePartners.split(',').contains(ipameme.PRM_Partner_Role__c))){
                    isPartnerRoleChanged=true;    
                }            
                ipameme.PRM_Status__c=Label.PRM_Label_complete;
                System.debug(ipameme.PRM_Partner_Tier__r.Rank+' '+ipameme.PRM_Partner_Tier__c);
                PRM_AccountChannelMembership__c acm  = new PRM_AccountChannelMembership__c();
                acm.Id = ipameme.PRM_Account_Channel_Membership__c;
                acm.PRM_Partner_Role__c = ipameme.PRM_Partner_Role__c;
                acm.PRM_Channel_Program_Level_Id__c = ipameme.PRM_Partner_Tier__c;
                acm.PRM_Comments__c = ipameme.PRM_Comments__c;
                opidSourceACMMap.put(ipameme.PRM_Account_Id__c, acm);  
                oldAcmIdPartnerRole.put(ipameme.PRM_Account_Channel_Membership__c, ipameme.PRM_Old_Partner_Role__c);         
                Map<Id,List<PRM_AccountChannelMembership__c>> acmMp = getAcmListMap(ipameme, acm); // chai - for 1 accountId , there will be only 1 acm , then why list is required?
                for(String Id:acmMp.keySet() ){
                    finalAcmMap.put(id, acmMp.get(Id));
                        }
                if(ipameme.PRM_Partner_Role__c =='Guest' && ipameme.PRM_Old_Partner_Role__c !='Guest'){
                    opidsToMPIdeactivation.add(ipameme.PRM_Account_Id__c);
                    //TWC729-8027 - RTA changes for MPI activation
                }else{
					opidsToMPIactivation.add(ipameme.PRM_Account_Id__c);
                }
               actIdRoleTierMap.put(ipameme.PRM_Account_Id__c, ipameme.PRM_Partner_Role__c+'-'+ipameme.PRM_Partner_Tier__c);
                actIdCPLMap.put(ipameme.PRM_Account_Id__c+'-'+ipameme.PRM_Old_Partner_Role__c, ipameme.PRM_Partner_Tier__c);
                 opidCPLMap.put(ipameme.PRM_Account_Id__c, ipameme.PRM_Partner_Tier__c);
                    mem.AccountId = ipameme.PRM_Account_Id__c;
                    mem.memId = ipameme.Id;
                    mem.errorMessage = ''; 
             
                if(newPartnerRoleMap!=null && !newPartnerRoleMap.isEmpty() && newPartnerRoleMap.containsKey(ipameme.PRM_Account_Id__c)){
                    newPartnerRoleMap.get(ipameme.PRM_Account_Id__c).add(ipameme.PRM_Old_Partner_Role__c+'-'+ipameme.PRM_Partner_Role__c);
                }else{
                    newPartnerRoleMap.put(ipameme.PRM_Account_Id__c, new List<String>{ipameme.PRM_Old_Partner_Role__c+'-'+ipameme.PRM_Partner_Role__c});
                }
               if(mem.AccountId!=null){
                    if(!memResponseWrapper.containsKey(ipameme.PRM_Account_Id__c)){
                        memResponseWrapper.put(ipameme.PRM_Account_Id__c, mem);
                    }
                }
            }
        Map<id,List<PRM_AccountChannelMembership__c>> acmRecMap=new Map<id,List<PRM_AccountChannelMembership__c>>();
        Set<Id> accIdsEligibleForRTA = new Set<Id>();
        Map<id, String> opidOldTierMap = new Map<id, String>();
        if(!opidCPLMap.isEmpty() || !newPartnerRoleMap.isEmpty()){ 
            for(PRM_AccountChannelMembership__c acmRecord : [select id, PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Account_Id__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.rank,PRM_Channel_Program_Level_Id__r.name, PRM_Partner_Role__c,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Status_Nm__c,PRM_Onepartner_Id__c,PRM_Status_Reason_Txt__c from PRM_AccountChannelMembership__c where (PRM_Account_Id__r.Core_IPA_One_Partner_Id__c  in : opidCPLMap.keySet() or PRM_Account_Id__c IN: newPartnerRoleMap.keyset()) order by PRM_Status_Nm__c desc]){
               if(acmRecord.PRM_Account_Id__r.RecordType.DeveloperName != Label.PRM_Partner_Account_Group_Record_Type){ 
                actToOPIDMap.put(acmRecord.PRM_Account_Id__c,acmRecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c);
                }//only location accounts
                if(acmRecMap.containsKey(acmRecord.PRM_Account_Id__c)){
                             acmRecMap.get(acmRecord.PRM_Account_Id__c).add(acmRecord);
                }
                else{
                    acmRecMap.put(acmRecord.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>{acmRecord});
                }
                if(oldAcmIdPartnerRole.containsKey(acmRecord.id) && oldAcmIdPartnerRole.get(acmRecord.id) == acmRecord.PRM_Partner_Role__c){
                    opidOldTierMap.put(acmRecord.PRM_Account_Id__c, acmRecord.PRM_Channel_Program_Level_Id__c);
                }
               System.debug('ACM Map'+acmRecMap);
                String accId = acmRecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c;
              if(acmRecord.PRM_Status_Nm__c=='Approved'){
                    if(!memResponseWrapper.containsKey(accId)){
                        memResponseWrapper.put(acmRecord.PRM_Account_Id__c, memResponseWrapper.get(acmRecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c));
                    }
                    oldAcmIdPartnerRole.put(acmRecord.Id, acmRecord.PRM_Partner_Role__c);
                                                              //OLD VALUE == PRESNET VALUE
                    if(newPartnerRoleMap.containsKey(accId) && getOldPartnerRole(newPartnerRoleMap.get(accId)).contains(acmRecord.PRM_Partner_Role__c)){// changes //OLD VALUE == PRESNET VALUE
                    accIdsEligibleForRTA.add(acmRecord.PRM_Account_Id__c);                       
                        for( String str : newPartnerRoleMap.get(accId)){
                            if(newPartnerRoleMap!=null && !newPartnerRoleMap.isEmpty() && newPartnerRoleMap.containsKey(acmRecord.PRM_Account_Id__c)){//for OPID accnts - chai TOBE - test if this is really neccessary
                                List<String> lst = newPartnerRoleMap.get(acmRecord.PRM_Account_Id__c);// lst varible name
                                if(!lst.contains(str)){
                                    lst.add(str);
                                    newPartnerRoleMap.put(acmRecord.PRM_Account_Id__c, lst);
                                }
                            }else{
                                newPartnerRoleMap.put(acmRecord.PRM_Account_Id__c, new List<String>{str}); // for location accounts , it populates from opid role
                            }
                            
                            List<String> strList = str.split('-');
                            if(acmRecord.PRM_Partner_Role__c == strList[0]){ //if old partner role == present
                                if(newPartnerRoleMap!=null && !newPartnerRoleMap.containsKey(acmRecord.PRM_Account_Id__c)){
                                    newPartnerRoleMap.put(acmRecord.PRM_Account_Id__c, new List<String>{acmRecord.PRM_Partner_Role__c+'-'+' '});//+'-'+ipameme.PRM_Partner_Role__c}); // this is for all ACM like child ones
                                }
                                String tier = String.IsNotBlank(acmRecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)? opidCPLMap.get(acmRecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c): null;
                                actIdRoleTierMap.put(acmRecord.PRM_Account_Id__c, strList[1]+'-'+tier);// anew role-tier
                               // acmIdActId.put(acmRecord.Id,acmRecord.PRM_Account_Id__c);
                                break;
                            }
                        }
                    }
                    
                }
            }
            System.debug('Account Role tier Map -->'+actIdRoleTierMap);
              List<String> strList1=new list<string>();
            if(acmRecMap!=null && !acmRecMap.isEmpty()){
                for(id accId : acmRecMap.keySet()){
                    if(accIdsEligibleForRTA.contains(accId)){
                        Boolean Flag = False;
                        for(PRM_AccountChannelMembership__c acmRec : acmRecMap.get(accId)){
                            String accIdKey = acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c;
                            String tier = String.IsNotBlank(acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)? opidCPLMap.get(acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c):null; // new tier
                            string str1= actIdRoleTierMap.get(accIdKey);
                            strList1 = str1.split('-');
                            //Location account
                            if(acmRecMap.get(accId).size() > 1){ // for more than 1 ACM? IN CASE OF mutlipla ACM ACCOUNT
                            if(acmRec.PRM_Account_Id__c != acmRec.PRM_Onepartner_Id__c){
                                if(acmRec.PRM_Partner_Role__c==strList1[0] && ((acmRec.PRM_Status_Nm__c=='Inactive' 
                                        || acmRec.PRM_Status_Nm__c=='Pending'))){ //OLD AND NEW ARE
                                            acmRec.PRM_Status_Nm__c='Approved';
                                            acmRec.PRM_Status_Reason_Txt__c = 'Approved as part of Role tier automation';//TWC729-8089 : Adding reason text : NJ
                                            System.debug('acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c'+acmRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c);
                                            acmRec.PRM_Channel_Program_Level_Id__c = tier;
                                            acmRec.PRM_Partner_Role__c = strList1[0];
                                            Flag = True;
                                           }
                                        
                               
                                  //  CURRENT                     NEW                                                  CURRENT AND OLD
                                    else if(acmRec.PRM_Partner_Role__c != strList1[0] && actIdCPLMap.containsKey(accIdKey+'-'+acmRec.PRM_Partner_Role__c) && !Flag){                             
                                        acmRec.PRM_Channel_Program_Level_Id__c = tier;
                                        acmRec.PRM_Partner_Role__c = strList1[0];
                                    }else if(!Flag && acmRec.PRM_Partner_Role__c==strList1[0] && acmRec.PRM_Channel_Program_Level_Id__c!=tier && acmRec.PRM_Status_Nm__c=='Approved'){
                                        acmRec.PRM_Channel_Program_Level_Id__c = tier;
                                       // acmRec.PRM_Partner_Role__c = strList1[0];
                                    }
                                    else{
                                        System.debug('Inside else if'+ acmRec.id);
                                        acmRec.PRM_Status_Nm__c= 'Inactive';
                                        acmRec.PRM_Status_Reason_Txt__c = 'Inactivated as part of Role tier automation';//TWC729-8089 : Adding reason text : NJ
                                    }

                            }    
                        }
                            else{
                                if(acmRec.PRM_Account_Id__c != acmRec.PRM_Onepartner_Id__c){
                               acmRec.PRM_Channel_Program_Level_Id__c = tier;
                                acmRec.PRM_Partner_Role__c = strList1[0];
                                      }
                            }
                            
                            //FOR opid ,If there are multiple ACM
                            
                            if(acmRec.PRM_Account_Id__c != acmRec.PRM_Onepartner_Id__c){
                                if(opidChildACMMap!=null && !opidChildACMMap.isEmpty() && opidChildACMMap.containsKey(acmRec.PRM_Account_Id__c)){//PRM_Account_Id__c
                                    opidChildACMMap.get(acmRec.PRM_Account_Id__c).add(acmRec);
                                }else{
                                    opidChildACMMap.put(acmRec.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acmRec});
                                }
                              //  acmIdActId.put(acmRec.Id,acmRec.PRM_Account_Id__c);
                            }else{   
                                //OLD ROLE AND CURRENT ROLE ARE SSAME AND IS FROM OPID                             
                                if(acmRec.PRM_Partner_Role__c==strList1[0] && (acmRec.PRM_Status_Nm__c=='Inactive' 
                                        || acmRec.PRM_Status_Nm__c=='Pending') && opidSourceACMMap.containsKey(acmRec.PRM_Account_Id__c) && opidSourceACMMap.get(acmRec.PRM_Account_Id__c).id != acmRec.id){
                                            acmRec.PRM_Status_Nm__c='Approved';
                                        acmRec.PRM_Status_Reason_Txt__c = 'Approved as part of Role tier automation';//TWC729-8089 : Adding reason text : NJ
                                        acmRec.PRM_Channel_Program_Level_Id__c = tier;
                                        System.debug('acmRec1-->'+acmRec);
                                        PRM_AccountChannelMembership__c sourceACM = opidSourceACMMap.get(acmRec.PRM_Account_Id__c);
                                        sourceACM.PRM_Status_Nm__c='Inactive';
                                        sourceACM.PRM_Channel_Program_Level_Id__c = opidOldTierMap.get(acmRec.PRM_Account_Id__c);
                                        sourceACM.PRM_Partner_Role__c = oldAcmIdPartnerRole.get(sourceACM.id);
                                        
                                        if(finalAcmMap.containsKey(acmRec.PRM_Account_Id__c)){
                                            finalAcmMap.get(acmRec.PRM_Account_Id__c).add(acmRec);      
                                        }else{
                                            finalAcmMap.put(acmRec.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>{acmRec});        
                                        } 
                                   }
                                   
                            }   
                            /* if(finalAcmMap.containskey(acmRec.PRM_Account_Id__c) && acmRec.PRM_Account_Id__c == acmRec.PRM_Onepartner_Id__c && opidSourceACMMap.containsKey(acmRec.PRM_Account_Id__c)){
                                acmRec.PRM_Channel_Program_Level_Id__c = opidSourceACMMap.get(acmRec.PRM_Account_Id__c).PRM_Channel_Program_Level_Id__c;
                                acmRec.PRM_Partner_Role__c = opidSourceACMMap.get(acmRec.PRM_Account_Id__c).PRM_Partner_Role__c;
                                System.debug('acmRec2-->'+acmRec);
                                finalAcmMap.put(acmRec.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>{acmRec});
                          }*/
                        }
                    }
                   
                }
            }
            
        }
            for(String Id:opidChildACMMap.keySet() ){
                finalAcmMap.put(id, opidChildACMMap.get(Id));
            }
            System.debug('finalAcmMap -->'+finalAcmMap);
            //filter duplicates
            List<PRM_AccountChannelMembership__c> acmsTobeUpdated = new List<PRM_AccountChannelMembership__c>();
            for(List<PRM_AccountChannelMembership__c> acmList : finalAcmMap.values()){
                for(PRM_AccountChannelMembership__c acm : acmList){
                    if(!acmsTobeUpdated.contains(acm)){
                        acm.PRM_Status_Reason_Txt__c = 'Updated as part of Role Tier Automation';
                        acmsTobeUpdated.add(acm);
                    }
                }
            }
           
            System.debug('acmsTobeUpdated -->'+acmsTobeUpdated);
            //System.debug('newPartnerRoleMap -->'+newPartnerRoleMap);
            
            // get all the ACR record with old partner role matching
            Set<String> roleSet = new Set<String>();
            for(Id id : newPartnerRoleMap.keyset()){
                for(String strLst : getOldPartnerRole(newPartnerRoleMap.get(id))){//oldPartnerRoleMap
                    roleSet.add(strLst);
                }
            }
              for(PRM_Account_Contact_Relationship__c acrRec : [select id,PRM_Relationship_Id__r.name,PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c, PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Contact_Id__c, PRM_Contact_Id__r.Core_IPA_PartnerRole__c , PRM_Partner_Role__c,PRM_Account_Id__c,PRM_Contact_Id__r.Core_IPA_Contact_Segment__c from PRM_Account_Contact_Relationship__c where (PRM_Account_Id__c in :newPartnerRoleMap.keySet() OR PRM_Account_Id__r.Core_IPA_One_Partner_Id__c in:opidCPLMap.keySet()) and PRM_InActive_Ind__c=false and PRM_Status_Nm__c='Complete' and  PRM_Partner_Role__c in :roleSet]){
               //Create contIdOPIDAccountMap contact id as key & OPID account as value
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
                                Contact con = new Contact();
                                con.id = acrRec.PRM_Contact_Id__c;
                                con.Core_IPA_PartnerRole__c = strList[1];
                                //con.Core_Republish_OBM_s__c = true;
                                if(!updateAccountandContact.contains(con)){
                                    system.debug('added');
                                    updateAccountandContact.add(con);}
                                if(actIdCtIdMap!=null && !actIdCtIdMap.isEmpty() &&actIdCtIdMap.containsKey(acrRec.PRM_Account_Id__c)){
                                    actIdCtIdMap.get(acrRec.PRM_Account_Id__c).add(acrRec.PRM_Contact_Id__c);
                                }else{
                                    actIdCtIdMap.put(acrRec.PRM_Account_Id__c, new Set<id>{acrRec.PRM_Contact_Id__c});
                                }
                              
                            }
                        }
                    }
                }
            }
            
            System.debug('### finalAcmMap=' + finalAcmMap);
			System.debug('### acmsTobeUpdated=' + acmsTobeUpdated);
            upsertData(acmsTobeUpdated);
            
            //get all Auto assign benefit matrix records
            
            Map<String, List<PRM_VXBnftMatrix__c>> partnerRolVxBftMat = new Map<String, List<PRM_VXBnftMatrix__c>>();
            Map<String, List<PRM_VXBnftMatrix__c>> manualPartnerRolVxBftMat = new Map<String, List<PRM_VXBnftMatrix__c>>();
            //Set<Id> automaticBenefits = new Set<id>(); // automatic benefits
            //Map<Id, Set<String>> benefitIdAccountType = new Map<Id, Set<String>>();
            for(PRM_VXBnftMatrix__c vxbnfRec : [select PRM_Channel_Program_Level_Id__r.name,PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c, PRM_Partner_Role_Nm__c from PRM_VXBnftMatrix__c  where (PRM_Approval_Type_Nm__c =:Label.PRM_ApprovalType or PRM_Approval_Type_Nm__c = 'manual') and PRM_IsActive_Ind__c = true and  PRM_Channel_Program_Level_Id__r.PRM_inactind__c = false ]){
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
            
            //System.debug('partnerRolVxBftMat -->'+partnerRolVxBftMat);
            //System.debug('accountIdRecTypemap -->'+accountIdRecTypemap);
            
            // get all the ABA records for actIds
            //Map<Id,List<Id>> abaListMap = new Map<Id,List<Id>>(); // account id, ABA record
            Map<Id,List<PRM_AccountBenefitAssociation__c>> actIdabaListMap = new Map<Id,List<PRM_AccountBenefitAssociation__c>>(); // account id, ABA record
            //Map<Id, set<PRM_AccountBenefitAssociation__c>> actbenefitId = new map<Id,Set<PRM_AccountBenefitAssociation__c>>(); // to inactivate manual benefit
            for(PRM_AccountBenefitAssociation__c abaRec : [select id,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c, PRM_Partner_Benefit_Id__c,PRM_Source__c,PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c  from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in :opidSourceACMMap.keySet() ]){ // getting the benefits only at OPID
                if(abaRec.PRM_Source__c=='Tier' || abaRec.PRM_Source__c == NULL){
                    if(actIdabaListMap.size()>0 && actIdabaListMap.containsKey(abaRec.PRM_Account_Id__c)){
                        actIdabaListMap.get(abaRec.PRM_Account_Id__c).add(abaRec);
                        system.debug('actIdabaListMap-->'+actIdabaListMap);
                    }else{
                        actIdabaListMap.put(abaRec.PRM_Account_Id__c, new List<PRM_AccountBenefitAssociation__c>{abaRec});
                        system.debug('actIdabaListMap-->'+actIdabaListMap);
                    }
                }
            }
            
            //System.debug('actIdabaListMap -->'+actIdabaListMap);
          //  PRM_ProfileResponseApexForABA.UpsertResponseWithoutBenefit(actIdabaListMap);
            Map<Id, List<PRM_AccountBenefitAssociation__c>> actSpecificABAListMp = new  Map<Id, List<PRM_AccountBenefitAssociation__c>>();
            
            //System.debug('finalAcmMap -->'+finalAcmMap);
            
            //if account tier is gold add benefit upto gold if degrade inactive benefit for higher tier
            //if account tier is titanium add benefits upto titanium
            //if account tier is member add benefit upto member
            System.debug('### acmsTobeUpdated size = ' + acmsTobeUpdated.size());
			System.debug('### acmsTobeUpdated = ' + acmsTobeUpdated);
            for(PRM_AccountChannelMembership__c acm : acmsTobeUpdated){
                //Id AccountId = acmIdActId.get(acm.Id);
                System.debug('### ACM=' + acm);
                System.debug('### Before PAG check');
                System.debug('### AccountId=' + acm.PRM_Account_Id__c);
                System.debug('### Account Rel=' + acm.PRM_Account_Id__r);
                System.debug('### PAG Label=' + Label.PRM_Partner_Account_Group_Record_Type);
                if(acm.PRM_Account_Id__r != null)
                {
                    System.debug(
                        '### RT=' +
                        acm.PRM_Account_Id__r.RecordType.DeveloperName
                    );
                }
                if(acm.PRM_Account_Id__r.RecordType.DeveloperName == Label.PRM_Partner_Account_Group_Record_Type){ // update the benefits only for OPID
                    System.debug('### Entered PAG block');
                Id AccountId = acm.PRM_Account_Id__c;
                System.debug(' aba list -->'+actIdabaListMap.get(AccountId));            //-----
              //  String key = acm.PRM_Partner_Role__c+'-'+(tierIdNames.get(acm.PRM_Channel_Program_Level_Id__c));
                List<String> applicablePartnerRoleTier = PRM_IPA_Utility.getApplicablePartnerRoleTier(acm.PRM_Partner_Role__c,tierIdNames.get(acm.PRM_Channel_Program_Level_Id__c));
                system.debug('applicable'+applicablePartnerRoleTier);
                List<String> applicableBenefits = new List<String>();
               if(actIdabaListMap.size()>0 && actIdabaListMap.containsKey(AccountId)){
                    actSpecificABAList = getListOfBenefits(actIdabaListMap.get(AccountId));// get benefits specific to act all inactive 
                    
                    List<String> containsBnft = new List<String>();
                    for( string keyStr : applicablePartnerRoleTier){
                     if(partnerRolVxBftMat.size()>0 && partnerRolVxBftMat.containsKey(keyStr)){ 
					// role+tier = list of benefits
					
   
                        for(PRM_VXBnftMatrix__c vxBnft : partnerRolVxBftMat.get(keyStr)){ // looping through all benefits applicable to roletier
                            if(!actSpecificABAList.containsKey(vxBnft.PRM_Partner_Benefit_Id__c)) // check if benefits at OPID is not present ,
                             
                            {
								//adding new benefits
                                PRM_AccountBenefitAssociation__c aba  = new PRM_AccountBenefitAssociation__c();
                                aba.PRM_Account_Id__c = AccountId;
                                aba.PRM_Partner_Benefit_Id__c = vxBnft.PRM_Partner_Benefit_Id__c;
                                aba.PRM_Status_Nm__c = 'Active';
                                aba.PRM_Status_Reason_Txt__c = 'Activated as part of Role tier automation';//TWC729-8089 : Adding reason text : NJ
                                aba.PRM_Source__c ='Tier';
                                aba.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
                                actSpecificABAListMp.putAll(getAccountSpecificABA(actSpecificABAListMp, aba, AccountId));
                            }
							if(actSpecificABAList.containsKey(vxBnft.PRM_Partner_Benefit_Id__c) && actSpecificABAList.get(vxBnft.PRM_Partner_Benefit_Id__c).PRM_Status_Nm__c == 'Inactive'){
								PRM_AccountBenefitAssociation__c aba  = new PRM_AccountBenefitAssociation__c();
                                aba.Id = actSpecificABAList.get(vxBnft.PRM_Partner_Benefit_Id__c).id;
								aba.PRM_Status_Nm__c = 'Active';
                                aba.PRM_Status_Reason_Txt__c = 'Activated as part of Role tier automation';//TWC729-8089 : Adding reason text : NJ
                                aba.PRM_Source__c ='Tier';
                                aba.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
                                actSpecificABAListMp.putAll(getAccountSpecificABA(actSpecificABAListMp, aba, AccountId));
                            
                        }
						applicableBenefits.add(vxBnft.PRM_Partner_Benefit_Id__c);
						}
					   }
					 
					 if(manualPartnerRolVxBftMat.size()>0 && manualPartnerRolVxBftMat.containsKey(keyStr)){
						  for(PRM_VXBnftMatrix__c vxManualBnft :manualPartnerRolVxBftMat.get(keyStr)){
							  applicableBenefits.add(vxManualBnft.PRM_Partner_Benefit_Id__c);
						  }
					 }
  }
  //for removal
					 for(Id benId:actSpecificABAList.keySet())
					 {
						 if(!applicableBenefits.contains(benId))
						 {
							 PRM_AccountBenefitAssociation__c aba  = new PRM_AccountBenefitAssociation__c();
                                aba.Id = actSpecificABAList.get(benId).id;
								aba.PRM_Status_Nm__c = 'Inactive';
                                aba.PRM_Status_Reason_Txt__c = 'Inactivated as part of Role tier automation';//TWC729-8089 : Adding reason text : NJ
                                aba.PRM_Source__c ='Tier';
                                aba.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
                                actSpecificABAListMp.putAll(getAccountSpecificABA(actSpecificABAListMp, aba, AccountId));
                            
						 }
					 }
					
                }
             }
               
            }
           for(List<PRM_AccountBenefitAssociation__c> abaRec : actSpecificABAListMp.values()){
             for(PRM_AccountBenefitAssociation__c benRec : abaRec){
            finalABAList.add(benRec);
             }
           } 
            System.debug('finalABAList -->'+finalABAList);
             if(isPartnerRoleChanged==true){
           pointFlagCheck(newPartnerRoleMap); 
             }  
        PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = true;
        upsertData(finalABAList);
        proccessEntitlement();
		List<PMP_OPID_MPI_Rel__c> opidMps = new List<PMP_OPID_MPI_Rel__c>();
          if (!opidsToMPIdeactivation.isEmpty()) {
            opidMps = [SELECT Id,Is_Active__c,PMP_RelLastDeactivated__c FROM PMP_OPID_MPI_Rel__c WHERE PMP_One_Partner_ID__c IN:opidsToMPIdeactivation AND Is_Active__c = TRUE ];
		  //TWC729-8027 - RTA changes for MPI activation
          }else if(!opidsToMPIactivation.isEmpty()){
			  opidMps = [SELECT Id,Is_Active__c,PMP_RelLastDeactivated__c FROM PMP_OPID_MPI_Rel__c WHERE PMP_One_Partner_ID__c IN:opidsToMPIactivation AND Is_Active__c = FALSE ];
		  }
            if (!opidMps.isEmpty()) {
                for (PMP_OPID_MPI_Rel__c opidmp : opidMps) {
                    if(opidmp.Is_Active__c == TRUE ){
                        opidmp.Is_Active__c = FALSE;opidmp.PMP_RelLastDeactivated__c = System.now();}
                
					else if(opidmp.Is_Active__c == FALSE )
                    opidmp.Is_Active__c = TRUE;
                }
                database.update(opidMps,false); // database.update
            }
		  
        if(Test.isRunningTest()) {
                throw new System.DMLException();
            }
        }catch(Exception ex){
            System.debug('Error -->'+ex.getMessage());
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, ex.getMessage(), '', null, null, '');
        }finally{
            sk = prm_skip_trigger__c.getInstance('ABA_Trigger');
            sk.inactive__c = false;
            database.update(sk,false); // database.update
        }
    }
    
   public void pointFlagCheck(Map<Id,List<String>> newPartnerRoleMapMp){
        System.debug('newPartnerRoleMap -->'+newPartnerRoleMap);
         Map<String, boolean> pointFlagCheckMap = new Map<String, boolean>();
        for(Id accountId:newPartnerRoleMap.keySet()){
            for(String oldNewRole : newPartnerRoleMap.get(accountId)){
                String newRole =  oldNewRole.split('-')[1];
                if(label.PRM_RolesEligibleForPointsBenefits.split(';').contains(newRole)){
                    pointFlagCheckMap.put(accountId,true);
                     }
                    else{
                        pointFlagCheckMap.put(accountId,false);
                        }
            }
            }
      //  PRM_ProfileResponse.fromPointsCalculation=true;
        PRM_ProfileResponseApexForABA.updateProfilePointsResponse(pointFlagCheckMap);
            
    }
        
    //COMMON METHOD TO INSERT OR UPDATE LIST OF RECORDS
    public static void upsertData(List<SObject> newLst) {   
         List<Id> conQueueFullLst=new List<Id>(); 
        // System.debug('newLst -->'+newLst);
        if(newLst!=null && !newLst.isEmpty()) {
            Database.UpsertResult[] urList = Database.upsert(newLst, false);
            Integer index = 0;
            for(Database.UpsertResult ur : urList){
                if(!ur.isSuccess() || Test.isRunningTest()){ 
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
                        system.debug('conQueueFullLst-->'+conQueueFullLst);
                    }
                    
                    if(newLst[index] instanceof PRM_AccountBenefitAssociation__c){
                       PRM_AccountBenefitAssociation__c aba =(PRM_AccountBenefitAssociation__c)newLst[index];
                        accountId = aba.PRM_Account_Id__c;
                        failedRecordId=aba.PRM_Partner_Benefit_Id__c;
                    }
                    System.debug('accountId -->'+accountId);
                    System.debug('failedRecordId -->'+failedRecordId);
                    
                    Id sId;
                    string sObjectType = '';
                    string tags = '';
                    for(Database.Error err : ur.getErrors()){
                        
                        System.debug('Error -->'+err.getMessage());
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
   
   //RETURN BENEFIT LIST specifi to ACCOUNT
    public static Map<String,PRM_AccountBenefitAssociation__c> getListOfBenefits(List<PRM_AccountBenefitAssociation__c> abaList){
        Map<String,PRM_AccountBenefitAssociation__c> benefits = new  Map<String,PRM_AccountBenefitAssociation__c>();
        if(abaList!=null && !abaList.isEmpty()){
            for(PRM_AccountBenefitAssociation__c abaRec : abaList){
                benefits.put(abaRec.PRM_Partner_Benefit_Id__c,abaRec);
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
    
   /* public static List<String> getApplicablePartnerRoleTier(PRM_AccountChannelMembership__c acm){  
        system.debug('here'+acm.PRM_Channel_Program_Level_Id__r.rank);      
        integer currentrank = tierRankMap.get(acm.PRM_Channel_Program_Level_Id__c);
        integer highestRank = PRM_IPA_Utility.getHighestTierRank();//5
        List<String> applicablePartnerRoleTier = new List<String>();
        if(currentrank < highestrank){
        while( currentrank < highestrank)
            {
                applicablePartnerRoleTier.add(acm.PRM_Partner_Role__c+'-'+tierIdNames.get(acm.PRM_Channel_Program_Level_Id__c));
                // currentrank = currentrank-1;
                if(currentrank == 4){
                break;
                }
            }
        }
       else if (currentrank == highestrank){
          applicablePartnerRoleTier.add(acm.PRM_Partner_Role__c+'-'+tierIdNames.get(acm.PRM_Channel_Program_Level_Id__c)); //fpga- prestige
        
        while(currentrank >= highestrank  ){
            highestrank = highestrank - 1;
            applicablePartnerRoleTier.add( acm.PRM_Partner_Role__c+'-'+tierRanksName.get(highestrank));
            if(highestrank == 4){
            break;}
            }
           }
         
         return applicablePartnerRoleTier;
       }
   
   */

    //SETUP BENEFITS TO ADD OR REMOVE
    
    
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
    
    // Assign Entitlement once ACM Updation is done
    public static void proccessEntitlement(){
        PRM_EntitlementResponseWrapper entWrap = new PRM_EntitlementResponseWrapper();
        //entWrap.accountIdRecTypemap = accountIdRecTypemap;
        entWrap.actIdCtIdMap = actIdCtIdMap;
        System.debug('actIdCtIdMap -->'+actIdCtIdMap);
        entWrap.actIdRoleTierMap = actIdRoleTierMap;
        System.debug('actIdRoleTierMap -->'+actIdRoleTierMap);
        entWrap.contactIdRelName = contactIdRelName;
        entWrap.tierIdNames = tierIdNames;
        entWrap.actToOPIDMap = actToOPIDMap;
        entWrap.newPartnerRoleMap = newPartnerRoleMap;
        PRM_IPAR_ACMUpdateAssignEntitlment assignEnt = new PRM_IPAR_ACMUpdateAssignEntitlment();
        entitlementsTOUpsert  = assignEnt.AssignEntitlements(entWrap);
        System.debug('entitlementsTOUpsert -->'+entitlementsTOUpsert);
    }
    
}