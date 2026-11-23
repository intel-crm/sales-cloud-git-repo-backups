/******************************************************************************************************************************
Apex Class Name:  PRM_AcctContRel_TriggerHandlerNew
    Date: Jan 2023
    Function    : Trigger handler for the object PRM_Account_Contact_Relationship__c
    
Modification Log :
     * Developer                 Date                    Description
 * --------------------------------------------------------------------------------------------------------------------

 ******************************************************************************************************************************/

public without sharing class PRM_AcctContRel_TriggerHandlerNew extends TriggerHandler { 
    public static boolean firstRun = true;
    public static boolean IPAfirstRun = true;
    public static boolean firstUpdateRun = true;
    public static boolean firstRunAfterInsert = true;
    public static boolean firstRunAfterUpdate = true;
    public static boolean firstRunBeforeUpdate = true;
    public static boolean firstRunBeforeInsert = true;
    public static String errMsg ='';
     //HeapSize Fix
    public static List<String> errMsgs = new List<String>();
    
    private static String getLogMessage(){
        return errMsgs.isEmpty() ? '' : String.join(errMsgs, '\n');
    }
    
    private static void clearLogs(){
        errMsgs.clear();
    }
    public static boolean firstRunBeforeDelete = true;
    public static boolean isDZPRegistration = false;
    public static  set<id> acrAccIds=new set<id>();
    @TestVisible
    static Boolean executeTrigger = true;
    public static final String PRM_Intel_Partner_Alliance = 'Intel Partner Alliance';
    list<PRM_AccountChannelMembership__c> acmList;
    public static boolean updateCheck = true;
    public static User CurrentUser = [SELECT id, isportalenabled FROM User WHERE id = :userinfo.getuserid()];
    //public static boolean ipaRefresh = boolean.valueOf(label.PRM_IPARefresh);
    public static Map<String,Trigger_Execution__mdt> triggerExecution = Trigger_Execution__mdt.getAll();
    
    
    //*************************************afterInsert******************************************** */
    
    public override void afterInsert(){
        if(executeTrigger){
            List<GroupMember> finalLstInsertGrpMembers = new List<GroupMember>();
            Group allPartnerGroup = [SELECT Id FROM Group WHERE Name = 'PMP - All Partner Users' AND Type = 'Regular' LIMIT 1];
            if(triggerExecution.containsKey('AcctCtRel_Insert_ERPM_Integration_Trgr') && triggerExecution.get('AcctCtRel_Insert_ERPM_Integration_Trgr').Active__c/*isActive('AcctCtRel_Insert_ERPM_Integration_Trgr')*/ && firstRun && !(System.isBatch()
                && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))
            ){
                System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_Account_Contact_Relationship__c>) Trigger.new, Trigger.new.getSObjectType()));
                firstRun = false;
            }
            if(
                triggerExecution.containsKey('ACR_After_Insert') && triggerExecution.get('ACR_After_Insert').Active__c/*isActive('ACR_After_Insert')*/ &&
                PRM_AcctContRelUtility.firstRunAfterInsert
            ){
                //UTKARSH - If block is to stop recurssion call insertContactEntitlement() method.
                PRM_AcctContRelUtility.firstRunAfterInsert = false;
                Map<Id, PRM_Account_Contact_Relationship__c> oldMap =(Map<Id, PRM_Account_Contact_Relationship__c>) Trigger.oldMap;
                List<PRM_Account_Contact_Relationship__c> acrNewList =(List<PRM_Account_Contact_Relationship__c>) Trigger.new;
                //List<PRM_Account_Contact_Relationship__c> oldAcrList =(List<PRM_Account_Contact_Relationship__c>) Trigger.old;
                //String accountPartnerSegment;
                Map<String, String> mapOfAccountIdToPartnerSegment = new Map<String, String>();
                String contactPartnerSegment;
                List<Contact> conlst = new List<Contact>();
                Map<String, String> segTypeMap = new Map<String, String>();
                Set<String> contactIds = new Set<String>();
                Set<Id> accIds = new Set<Id>();
                List<Account> accList = new List<Account>();
                List<User> Users = new List<User>();
                Set<Id> accountIds = new Set<Id>();
                List<Contact> contList = new List<Contact>();
                
                try {
                    if(acrNewList != null){
                        for(
                            PRM_Account_Contact_Relationship__c acr : acrNewList
                        ){
                            contactIds.add(acr.PRM_Contact_Id__c);
                            accountIds.add(acr.PRM_Account_Id__c);
                        }
                    }
                   // errMsg+='Contact ID from ACR is- '+contactIds+'Account ID from ACR is-'+accountIds+'\n';
                   // heap size error fix
                   errMsgs.add('Contact ID from ACR is- ' + contactIds + ' Account ID from ACR is-' + accountIds);
                    if(accountIds != null && !accountIds.isEmpty()){
                       // errMsg+='From line 72 \n';
                       errMsgs.add('From line 72');
                        acmList = [ SELECT Id, PRM_Account_Id__c, PRM_Channel_Program_Level_Id__c, PRM_Channel_Program_Id__c, PRM_Partner_Role__c, PRM_Status_Nm__c
                                    FROM PRM_AccountChannelMembership__c
                                    WHERE PRM_Channel_Program_Id__r.Name = :System.Label.PRM_Intel_Partner_Alliance
                                    AND PRM_Status_Nm__c = :System.Label.PRM_Status AND PRM_Account_Id__c IN :accountIds];
                    }
                    
                    insertContactEntitlement(acrNewList, oldMap, acmList); //Utkarsh
                    /*US575709 - Start - Expose new Get Profile API in SF for secondary contact, Admin registration & Account Request flows*/
                    PRM_AGS_IdentityCreation.SendEmailVerificationAndCreateIdentityInAGS(acrNewList);
                    
                    // IPA Refresh check : DINESH - IPA 2.0 changes
                    /*if(!ipaRefresh || Test.isRunningTest()){
                        errMsg+='From line 85 \n';
                        if(contactIds != null && !contactIds.isEmpty()){
                            errMsg+='From line 87 \n';
                            contList = [SELECT id, name, Core_IPA_Contact_Segment__c, Core_IPA_PartnerRole__c, AccountId, Core_ERPM_Integration_Status__c
                                    FROM Contact
                                    WHERE id IN :contactIds];
                            errMsg+='From line 91--conList is--'+contList+' \n';
                            for(PRM_PartnerRoleTypeMappings__mdt segTypeReq : [SELECT Id, PRM_Partner_Role__c, PRM_Partner_Segment__c
                                                                               FROM PRM_PartnerRoleTypeMappings__mdt where PRM_Partner_Segment__c != null]
                            ){
                                segTypeMap.put(segTypeReq.PRM_Partner_Role__c, segTypeReq.PRM_Partner_Segment__c);
                            }
                        }
                        if(!contList.isEmpty()){
                            errMsg+='From line 99 \n';
                            for(Contact con : contList){
                                contactPartnerSegment = '';
                                accIds.add(con.AccountId);
                                
                                if(segTypeMap.containsKey(con.Core_IPA_PartnerRole__c)) {
                                    contactPartnerSegment = segTypeMap.get(con.Core_IPA_PartnerRole__c);
                                    mapOfAccountIdToPartnerSegment.put(con.AccountId, contactPartnerSegment);
                                }
                                
                                if( String.isBlank(con.Core_IPA_Contact_Segment__c) && String.isNotBlank(contactPartnerSegment)) {
                                    con.Core_IPA_Contact_Segment__c = contactPartnerSegment;
                                    conlst.add(con);
                                } else {
                                    if(String.isnotBlank(con.Core_IPA_Contact_Segment__c)){
                                        List<String> contactsegList =(con.Core_IPA_Contact_Segment__c).split(';');
                                        if(!contactsegList.contains(contactPartnerSegment) && String.isNotBlank(contactPartnerSegment)) {
                                            // accountPartnerSegment = con.Core_IPA_Contact_Segment__c;
                                            con.Core_IPA_Contact_Segment__c = con.Core_IPA_Contact_Segment__c + ';' + contactPartnerSegment;
                                            conlst.add(con);
                                        }
                                    }
                                }
                            }
                            if(conlst.size() > 0){
                                errMsg+='From line 124 \n';
                                //  List<Database.SaveResult> updateConResult =
                                PRM_DMLUtility.doupdate(conlst,'Contact','PRM_AccountContactRel_TriggerHandlerNew.afterInsert');
                            }
                        }
                        if(!ipaRefresh || Test.isRunningTest()){
                            errMsg+='From line 130 \n';
                            if(accIds != null && !accIds.isEmpty()){
                                errMsg+='From line 132--'+accIds+' \n';
                                List<Account> existingAccountList = [SELECT Id, Core_IPA_Partner_Role__c, Core_IPA_Partner_Segment__c FROM Account WHERE Id IN :accIds];
                                for(Account Acc : existingAccountList){
                                    if(mapOfAccountIdToPartnerSegment != null && mapOfAccountIdToPartnerSegment.containsKey(Acc.id)){
                                        String partnerSegmentToAssign = mapOfAccountIdToPartnerSegment.get(Acc.id);
                                        if(String.isBlank(acc.Core_IPA_Partner_Segment__c) || acc.Core_IPA_Partner_Segment__c == null){
                                            acc.Core_IPA_Partner_Segment__c = partnerSegmentToAssign;
                                            accList.add(acc);
                                        }else{
                                            List<String> partnersegList =(acc.Core_IPA_Partner_Segment__c).split(';');
                                            if(!partnersegList.contains(partnerSegmentToAssign)
                                            ){
                                                acc.Core_IPA_Partner_Segment__c = acc.Core_IPA_Partner_Segment__c + ';' + partnerSegmentToAssign;
                                                accList.add(acc);
                                            }
                                        }
                                    }
                                }
                                errMsg+='From line 150 \n';
                                if(accList.size() > 0){
                                    errMsg+='From line 152 \n';
                                    //List<Database.SaveResult> updateAccResult =
                                    PRM_DMLUtility.doupdate(accList,'Account','PRM_AccountContactRel_TriggerHandlerNew.afterInsert');
                                }
                            }
                        }
                        
                    }*/ //IPA refresh - switch removal
                    if(contactIds!=null && contactIds.size()>0 && (!System.Isbatch() && (!System.isQueueable() || (System.isQueueable() &&  limits.getQueueableJobs() < 1  ) )) && System.Label.PRM_Tracker_Enabled=='true')
                    {
                        //errMsg+='From 162-- '+contactIds+'\n';
                        errMsgs.add('From 162-- ' + contactIds);
                        system.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (null,contactIds,false,false));
                        
                    }
                    /*Users = [select id,name,ContactId from User where ContactId IN :contactIds];
                    if(allPartnerGroup != null){
                        GroupMember gm = new GroupMember();
                        gm.GroupId = allPartnerGroup.Id;
                        gm.UserOrGroupId = Users[0].Id;
                        lstInsertGrpMembers.add(gm);
                    
                    }
                    insert lstInsertGrpMembers;*/
                    //if (!Test.isRunningTest()) {
                    //addUsertoGroup(contactIds);
                    //}
                    
                    
                } catch(Exception e){  /*errMsg+='From 166-- '+contactIds+'\n'+e;*/errMsgs.add('From 166-- ' + contactIds);errMsgs.add(String.valueOf(e));
                    PRM_ErrorUtilityClass.logError(e);
                }
            }
        }
        // Stamps the OPID flag for any new/activated Partner Admin ACR; runs last so existing enqueues keep priority.
        if (affectsPartnerAdminFlag((List<PRM_Account_Contact_Relationship__c>) Trigger.new, null)) {
            PRM_OpidPartnerAdminFlagService.handleAcrChanges((List<PRM_Account_Contact_Relationship__c>) Trigger.new, null);
        }
       /* Long usedHeap   = Limits.getHeapSize();        
Long totalHeap  = Limits.getLimitHeapSize();
Decimal percent = (Decimal.valueOf(usedHeap) / Decimal.valueOf(totalHeap)) * 100;
System.debug('Heap Used (%)11144: ' + percent.setScale(2));*/
    }
    
    //*************************************afterUpdate******************************************** */
    public override void afterUpdate(){
       // errMsg+='From after Update of PRM_AcctContRel_TriggerHandlerNew -- \n';
       errMsgs.add('From after Update of PRM_AcctContRel_TriggerHandlerNew --');
        if( triggerExecution.containsKey('AcctCtRel_Update_ERPM_Integration_Trgr') && triggerExecution.get('AcctCtRel_Update_ERPM_Integration_Trgr').Active__c/*isActive('AcctCtRel_Update_ERPM_Integration_Trgr')*/ && firstRun && !(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))
        ){
            System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_Account_Contact_Relationship__c>) Trigger.new, Trigger.new.getSObjectType()));
            firstRun = false;
        }
        
        if(triggerExecution.containsKey('ACR_After_Update') && triggerExecution.get('ACR_After_Update').Active__c/*isActive('ACR_After_Update')*/){
           // errMsg+='Line 183 -- \n';
           errMsgs.add('Line 183 --');
            Map<Id, PRM_Account_Contact_Relationship__c> oldMap =(Map<Id, PRM_Account_Contact_Relationship__c>) Trigger.oldMap;
            Map<Id, PRM_Account_Contact_Relationship__c> newMap =(Map<Id, PRM_Account_Contact_Relationship__c>) Trigger.newMap;
            List<PRM_Account_Contact_Relationship__c> acrNewList =(List<PRM_Account_Contact_Relationship__c>) Trigger.new;
            //List<PRM_Account_Contact_Relationship__c> oldAcrList =(List<PRM_Account_Contact_Relationship__c>) Trigger.old;
            Set<Id> setConIdsForUnCheckSupression = new Set<Id>();
            //PRM_Account_Contact_Relationship__c acrOld;
            Set<String> contids = new Set<String>();
            List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
            List<Id> worksForEntitlement = new List<Id>();
            List<Id> inactiveAcrList = new List<Id>();
            List<Id> benefitList = new List<Id>();
            Set<Id> automaticBenefits = new Set<Id>();
            Map<Id, List<PRM_AccountChannelMembership__c>> acmMap = new Map<Id, List<PRM_AccountChannelMembership__c>>();
            List<PRM_VXEnttlmntMatrix__c> entitlmentWithoutBenefits = new List<PRM_VXEnttlmntMatrix__c>();
            List<Id> entitlementWithoutBEList = new List<Id>();
            List<Id> entitlementABList = new List<Id>();
            List<Id> entitlementList = new List<Id>();
            Set<Id> allEntId = new Set<Id>();
            List<PRM_Account_Contact_Relationship__c> acrListWorksfor = new List<PRM_Account_Contact_Relationship__c>();
            List<PRM_Account_Contact_Relationship__c> inactiveAcrIdList = new List<PRM_Account_Contact_Relationship__c>();
            Map<id, String> mapContIdToSourceAgent = new Map<id, String>();
            Boolean softContactIndicator = false;
            set<Id> softContatid = new Set<Id>();
            List<Id> inactiveAcrRelList = new List<Id>();
            List<Id> contactRelatedInactiveACRList = new List<Id>();
            boolean inactiveUpdateCheck = false;
            List<Id> activeAcrRelList = new List<Id>();
            List<Id> contactRelatedActiveACRList = new List<Id>();
            List<Id> activeAccIdList = new List<Id>();
            boolean activeUpdateCheck = false;
            Set<id> accIds = new Set<id>();
            //for all tier entitlements
            Map<String, List<id>> entitlementWithoutBenefitmap = new Map<String, List<id>>();
            List<id> entWithoutBenListTemp;
            String profileName = [SELECT Id, Name FROM Profile WHERE Id = :(userinfo.getProfileId())].Name;
            list<string> lstBlockedCon=new list<String>();
            map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>();
            boolean isBlocked=false;
            List<PRM_SendEmailsToPrimaryContacts.emailToContactWrapper> emailToContactWrapperList = new List<PRM_SendEmailsToPrimaryContacts.emailToContactWrapper>();
            if(PRM_AcctContRelUtility.firstRunAfterUpdate){
                //errMsg+='Line 223 -- \n';
                errMsgs.add('Line 223 --');               
                try {
                    //PRM_AcctContRelUtility.firstRunAfterUpdate = false;
                    if(acrNewList != null && !acrNewList.IsEmpty()){
                        //errMsg+='Line 227 acrNewList is --'+acrNewList+' \n';
                        errMsgs.add('Line 227 acrNewList is --' + acrNewList);
                        for( PRM_Account_Contact_Relationship__c acr : acrNewList
                        ){
                            if(oldMap != null && oldMap.size() > 0){
                                //errMsg+='Line 231 oldMap is --'+oldMap+' \n';
                                errMsgs.add('Line 231 oldMap is --' + oldMap);
                                PRM_Account_Contact_Relationship__c oldAcr = oldMap.containsKey( acr.id) ? oldMap.get(acr.id): null;
                                //errMsg+='Line 233 oldAcr is --'+oldAcr+' \n';
                                errMsgs.add('Line 233 oldAcr is --' + oldAcr);
                                if(oldAcr.PRM_Suppress_Email__c != acr.PRM_Suppress_Email__c && !acr.PRM_Suppress_Email__c){
                                   // errMsg+='Line 235 \n';
                                   errMsgs.add('Line 235 ');
                                    setConIdsForUnCheckSupression.add(acr.PRM_Contact_Id__c);
                                }
                                if((oldAcr.PRM_InActive_Ind__c != acr.PRM_InActive_Ind__c && !acr.PRM_InActive_Ind__c) 
        || (oldAcr.PRM_Status_Nm__c != acr.PRM_Status_Nm__c && acr.PRM_Status_Nm__c == 'Pending Action') 
        || (oldAcr.PRM_AGS_Response_Status__c != acr.PRM_AGS_Response_Status__c))
        {
                                    //errMsg+='Line 239 \n';
                                    errMsgs.add('Line 239 ');
                                    contids.add(acr.PRM_Contact_Id__c);
                                }
                                if(oldAcr.PRM_InActive_Ind__c != acr.PRM_InActive_Ind__c){
                                   // errMsg+='Line 243 \n';
                                    errMsgs.add('Line 243 ');
                                    if(acr.PRM_InActive_Ind__c == true && (acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status || acr.PRM_Status_Nm__c == System.Label.Pending_Action)){  
                                        //errMsg+='Line 245 \n';
                                        errMsgs.add('Line 245');
                                        if(acr.PRM_Soft_Contact__c){
                                           // errMsg+='Line 247 \n';
                                           errMsgs.add('Line 247');
                                            softContactIndicator = true;
                                            softContatid.add(acr.PRM_Contact_Id__c);
                                        }
                                        inactiveAcrList.add(acr.Id);
                                        inactiveAcrRelList.add(acr.PRM_Relationship_Id__c);
                                        contactRelatedInactiveACRList.add(acr.PRM_Contact_Id__c);
                                        inactiveUpdateCheck = true;
                                       // errMsg+='Line 255 inactiveAcrList is --'+inactiveAcrList+'--Line 255 inactiveAcrRelList is --'+inactiveAcrRelList+'--Line 255 contactRelatedInactiveACRList is --'+contactRelatedInactiveACRList+' \n';
                                       errMsgs.add( 'Line 255 inactiveAcrList is --' + inactiveAcrList + '--Line 255 inactiveAcrRelList is --' + inactiveAcrRelList + '--Line 255 contactRelatedInactiveACRList is --' + contactRelatedInactiveACRList);
                                    }
                                    if(acr.PRM_InActive_Ind__c == false && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status){
                                       // errMsg+='Line 258 \n';
                                       errMsgs.add('Line 258 ');
                                        if(!mapContIdToSourceAgent.containsKey(acr.PRM_Contact_Id__c) && acr.PRM_Source_Agent__c == 'Bulk Add'
                                            && PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad
                                        ){
                                           // errMsg+='Line 262 \n';
                                           errMsgs.add('Line 262 ');
                                            mapContIdToSourceAgent.put(acr.PRM_Contact_Id__c, acr.PRM_Source_Agent__c);
                                        }
                                        activeAcrRelList.add(acr.PRM_Relationship_Id__c);
                                        contactRelatedActiveACRList.add(acr.PRM_Contact_Id__c);
                                        activeAccIdList.add(acr.PRM_Account_Id__c);
                                        activeUpdateCheck = true;
                                        errMsg+='Line 269 activeAcrRelList is --'+activeAcrRelList+'--Line 269 contactRelatedActiveACRList is --'+contactRelatedActiveACRList+'--Line 269 activeAccIdList is --'+activeAccIdList+' \n';
                                    }
                                }
                                accIds.add(acr.PRM_Account_Id__c);
                            }
                        }
                    }
                   // errMsg+='Line 276 accIds is --'+accIds+' \n';
                   errMsgs.add('Line 276 accIds is --' + accIds);
                    if(contids!=null && !contids.isEmpty()){
                       // errMsg+='Line 278 contids is --'+contids+' \n';
                       errMsgs.add('Line 278 contids is --' + contids);
                        mapOfAccWithBlokedStatus=   getBlockedContact(contids);
                    }
                   // errMsg+='Line 281 mapOfAccWithBlokedStatus is --'+mapOfAccWithBlokedStatus+' \n';
                   errMsgs.add('Line 281 mapOfAccWithBlokedStatus is --' + mapOfAccWithBlokedStatus);
                    for( PRM_Account_Contact_Relationship__c acr : acrNewList){
                        if(mapOfAccWithBlokedStatus.containsKey(acr.PRM_Contact_Id__c) && mapOfAccWithBlokedStatus.get(acr.PRM_Contact_Id__c)==true) {
                            //errMsg+='Line 284 error msg \n';
                            errMsgs.add('Line 284 error msg');
                            acr.addError(System.Label.PRM_BlockedContError_IPA);
                        }
                    }
                    if(accIds != null && !accIds.isEmpty() && acrNewList!=null && !acrNewList.isEmpty()){
                        //errMsg+='Line 289  \n';
                        errMsgs.add('Line 289');
                        acmList = [SELECT Id, PRM_Account_Id__c, PRM_Channel_Program_Level_Id__c, PRM_Channel_Program_Id__c, PRM_Partner_Role__c, PRM_Status_Nm__c
                                   FROM PRM_AccountChannelMembership__c
                                   WHERE PRM_Channel_Program_Id__r.Name = :System.Label.PRM_Intel_Partner_Alliance
                                   AND PRM_Status_Nm__c = :System.Label.PRM_Status AND PRM_Account_Id__c = :acrNewList[0].PRM_Account_Id__c]; //discuss with piyush
                    }
                    
                    insertContactEntitlement(acrNewList, oldMap, acmList);
                    
                    if(activeAccIdList != null && !activeAccIdList.IsEmpty()){
                       // errMsg+='Line 299 \n';
                       errMsgs.add('Line 299');
                        for(PRM_AccountChannelMembership__c acm : acmList){
                            if(activeAccIdList.contains(acm.PRM_Account_Id__c)
                            ){
                               // errMsg+='Line 303 \n';
                               errMsgs.add('Line 303');
                                List<PRM_AccountChannelMembership__c> acmRecList;
                                if(acmMap.get(acm.PRM_Account_Id__c) != null && !acmMap.get(acm.PRM_Account_Id__c).isEmpty()){
                                    acmRecList = acmMap.get(acm.PRM_Account_Id__c);
                                }else{
                                    acmRecList = new List<PRM_AccountChannelMembership__c>();
                                }
                                acmRecList.add(acm);
                                acmMap.put(acm.PRM_Account_Id__c, acmRecList);
                            }
                        }
                    }
                    
                    if(inactiveUpdateCheck){
                       // errMsg+='Line 317 \n';
                        errMsgs.add('Line 317');
                        for(PRM_Account_Contact_Relationship__c accRel : [SELECT Id, Name, PRM_Relationship_Id__c, PRM_Contact_Id__c, PRM_Relationship_Id__r.Name,
                                                                          PRM_InActive_Ind__c, PRM_Contact_Id__r.Core_Login_Status__c
                                                                          FROM PRM_Account_Contact_Relationship__c
                                                                          WHERE PRM_InActive_Ind__c = FALSE
                                                                          AND PRM_Contact_Id__c IN :contactRelatedInactiveACRList
                                                                          /*AND(PRM_Relationship_Id__c NOT IN :inactiveAcrRelList
                                                                          OR id NOT IN :inactiveAcrList)*/ //ATHR Fix - TWC729-9556 - SJ
                        ]){
                            if(!inactiveAcrRelList.contains(accRel.PRM_Relationship_Id__c)){
                                acrListWorksfor.add(accRel);
                            }
                            if(!inactiveAcrList.contains(accRel.id)){
                                inactiveAcrIdList.add(accRel);
                            }
                        }
                    }
                    
                    if(activeUpdateCheck || test.isRunningTest()){
                       // errMsg+='Line 236 \n';
                       errMsgs.add('Line 402');
                        if(activeAccIdList != null && !activeAccIdList.IsEmpty()
                        ){//errMsg+='Line 338 \n';
                           errMsgs.add('Line 338');
                            for(PRM_AccountBenefitAssociation__c aba : [SELECT Id, PRM_Partner_Benefit_Id__c, PRM_Account_Id__c
                                                                        FROM PRM_AccountBenefitAssociation__c
                                                                        WHERE PRM_Account_Id__c IN :activeAccIdList AND PRM_Status_Nm__c = :System.Label.PRM_Status_Active
                            ]){
                                benefitList.add(aba.PRM_Partner_Benefit_Id__c);
                            }
                        }
                        if(benefitList != null && !benefitList.IsEmpty()){
                            for(PRM_VXBnftMatrix__c bm : [SELECT Id, PRM_Partner_Benefit_Id__c, PRM_Approval_Type_Nm__c
                                                          FROM PRM_VXBnftMatrix__c
                                                          WHERE PRM_Partner_Benefit_Id__c IN :benefitList AND PRM_Approval_Type_Nm__c = :System.Label.PRM_ApprovalType
                            ]){
                                automaticBenefits.add(bm.PRM_Partner_Benefit_Id__c);
                            }
                        }
                    }
                    
                    // added by dinesh as part of IPA refresh 2.0
                    String query = 'SELECT Id, Name, PRM_Partner_Benefit_Id__c, PRM_Entitlement_Id__c,PRM_Contact_Relationship_Id__r.name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Contact_Relationship_Id__r.PRM_Default_Relationship_Ind__c,RecordType.Name,PRM_IPA_Partner_Role_Nm__c,PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.name FROM PRM_VXEnttlmntMatrix__c WHERE PRM_Approval_Type_Nm__c = \'Automatic\'  AND ((PRM_Contact_Relationship_Id__R.PRM_Default_Relationship_Ind__c = TRUE AND PRM_IsActive_Ind__c = TRUE) OR PRM_IsActive_Ind__c = TRUE OR(PRM_Contact_Relationship_Id__c != null)) and PRM_IsActive_Ind__c = true';
                    //String filter = ipaRefresh? 'and PRM_IPARefreshCheck__c = true': 'and PRM_IPARefreshCheck__c = false'; // IPA refresh - switch removal
                    
                    for(PRM_VXEnttlmntMatrix__c em : Database.query(query/*+' '+filter*/))/*[SELECT Id, Name, PRM_Partner_Benefit_Id__c, PRM_Entitlement_Id__c, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c,
                                                      PRM_Contact_Relationship_Id__r.PRM_Default_Relationship_Ind__c,RecordType.Name,PRM_IPA_Partner_Role_Nm__c,PRM_Channel_Program_Level_Id__c
                                                      ,PRM_Channel_Program_Level_Id__r.name FROM PRM_VXEnttlmntMatrix__c
                                                      WHERE PRM_Approval_Type_Nm__c = :System.Label.PRM_ApprovalType
                                                      AND(PRM_Partner_Benefit_Id__c IN :automaticBenefits
                                                      OR(PRM_Contact_Relationship_Id__R.PRM_Default_Relationship_Ind__c = TRUE AND PRM_IsActive_Ind__c = TRUE)
                                                      OR PRM_IsActive_Ind__c = TRUE
                                                      OR(RecordType.Name = :System.Label.PRM_Entitlement_RecordType AND PRM_Contact_Relationship_Id__c IN :activeAcrRelList))*/
                    {
                        String key = em.PRM_IPA_Partner_Role_Nm__c + '-' + em.PRM_Contact_Relationship_Id__c + '-' + em.PRM_Channel_Program_Level_Id__r.Name;
                        if(activeUpdateCheck && automaticBenefits != null && !automaticBenefits.IsEmpty() && automaticBenefits.contains(em.PRM_Partner_Benefit_Id__c)){
                            entitlementABList.add(em.PRM_Entitlement_Id__c);
                        }
                        if(activeUpdateCheck && em.RecordType.Name == System.Label.PRM_Entitlement_RecordType && activeAcrRelList.contains(em.PRM_Contact_Relationship_Id__c)){
                            entitlmentWithoutBenefits.add(em);
                            if(entitlementWithoutBenefitmap.containsKey(key)){
                                entWithoutBenListTemp = entitlementWithoutBenefitmap.get(key);
                            }else
                            entWithoutBenListTemp = new List<id>();
                            entWithoutBenListTemp.add(em.id);
                            entitlementWithoutBenefitmap.put(key, entWithoutBenListTemp);
                        }
                        if(inactiveUpdateCheck && acrListWorksfor != null && !acrListWorksfor.IsEmpty() && em.PRM_Contact_Relationship_Id__R.PRM_Default_Relationship_Ind__c == true
                            && em.PRM_IsActive_Ind__c == true
                        ){
                             if(String.isNotBlank(em.PRM_Contact_Relationship_Id__c) && em.PRM_Contact_Relationship_Id__r.PRM_Default_Relationship_Ind__c == true
                                && inactiveAcrRelList.contains(em.PRM_Contact_Relationship_Id__c)
                            ){
                                
                                emList.add(em);
                            }
                            /*errMsg+='Line 391 \n';*/errMsgs.add('Line 391');
                            worksForEntitlement.add(em.PRM_Entitlement_Id__c);
                        }
                         // for IPA Developer Zone Standard Entitlement
                        else if(inactiveUpdateCheck && em.PRM_IsActive_Ind__c == true){
                            allEntId.add(em.PRM_Entitlement_Id__c);
                        }
                          //new code UAT issue: PA/PAD
                         if(inactiveUpdateCheck && acrListWorksfor != null && !acrListWorksfor.IsEmpty() 
                             && em.PRM_Contact_Relationship_Id__R.PRM_Default_Relationship_Ind__c == false
                            && em.PRM_IsActive_Ind__c == true
                        ){
                           
                            if(String.isNotBlank(em.PRM_Contact_Relationship_Id__c) 
                            && em.PRM_Contact_Relationship_Id__r.PRM_Default_Relationship_Ind__c == false
                            && inactiveAcrRelList.contains(em.PRM_Contact_Relationship_Id__c)
                            && (em.PRM_Contact_Relationship_Id__r.name==System.label.PRM_PartnerAdmin_Rel 
                            || em.PRM_Contact_Relationship_Id__r.name==System.label.PRM_Admin_Delegate))
                            { 
                                system.debug('emlist inside default false'+emList.size());
                                emList.add(em);
                            }
                        }
                     
                       
                    }
                    
                    //Comparing entitlements and removing entitlements which has both relationship 'primary relationship' and 'works for'.
                    if(inactiveUpdateCheck && !emList.IsEmpty() && !acrListWorksfor.IsEmpty()
                    ){
                        for(PRM_VXEnttlmntMatrix__c entitlement : emList){
                            if(!worksForEntitlement.contains(entitlement.PRM_Entitlement_Id__c)
                            ){
                                entitlementList.add(entitlement.PRM_Entitlement_Id__c);
                            }
                        }
                    }
                    
                    if(activeUpdateCheck && !acrNewList.IsEmpty() || Test.isRunningTest()){
                        for(PRM_Account_Contact_Relationship__c acr : acrNewList
                        ){
                            Set<id> entitlements = new Set<id>();
                            List<PRM_VXEnttlmntMatrix__c> entitlementsList = new List<PRM_VXEnttlmntMatrix__c>();
                            String keyForEnt = acr.PRM_Partner_Role__c + '-' + acr.PRM_Relationship_Id__c;
                            if(acr.PRM_Status_Nm__c != 'Complete'){
                                continue;
                            }
                            if(!entitlmentWithoutBenefits.IsEmpty()){
                               // errMsg+='Line 439 \n';
                               errMsgs.add('Line 439');
                                for(PRM_VXEnttlmntMatrix__c emWithoutBenefits : entitlmentWithoutBenefits
                                ){
                                    List<PRM_AccountChannelMembership__c> acm = new List<PRM_AccountChannelMembership__c>();
                                    if(acmMap != null && !acmMap.IsEmpty()){
                                        acm = acmMap.get(acr.PRM_Account_Id__c);
                                    }
                                    /*for(integer i = 0; i < acm.size(); i++){
                                        if(acr.PRM_Partner_Role__c != null){
                                            errMsg+='Line 448 \n';
                                            if((emWithoutBenefits.PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c)
                                                && (acr.PRM_Partner_Role__c == emWithoutBenefits.PRM_IPA_Partner_Role_Nm__c)
                                                && (emWithoutBenefits.PRM_Channel_Program_Level_Id__c == acm[i].PRM_Channel_Program_Level_Id__c)
                                                && (acr.PRM_Partner_Role__c == acm[i].PRM_Partner_Role__c)
                                            ){
                                                //higher tier with lower tiers:
                                                if(acm[i].PRM_Channel_Program_Level_Id__r.Name == 'Titanium'){
                                                    if(entitlementWithoutBenefitmap.containsKey(keyForEnt + '-' + 'Titanium')){
                                                        entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt + '-' + 'Titanium'));
                                                    }
                                                    if(entitlementWithoutBenefitmap.containsKey(keyForEnt  + '-' + 'Gold')){
                                                        entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt  + '-' + 'Gold'));
                                                    }
                                                    if(entitlementWithoutBenefitmap.containsKey(keyForEnt  + '-' + 'Member')){
                                                        entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt  + '-' + 'Member'));
                                                    }
                                                }else if(acm[i].PRM_Channel_Program_Level_Id__r.Name == 'Gold'){
                                                    if(entitlementWithoutBenefitmap.containsKey(keyForEnt  + '-' + 'Gold')){
                                                        entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt  + '-' + 'Gold'));
                                                    }
                                                    if(entitlementWithoutBenefitmap.containsKey(keyForEnt  + '-' + 'Member')){
                                                        entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt  + '-' + 'Member'));
                                                    }
                                                }else if(entitlementWithoutBenefitmap.containsKey(keyForEnt  + '-' + 'Member')){
                                                    entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt  + '-' + 'Member'));
                                                }
                                                entitlementWithoutBEList.addAll(entitlements);
                                            }
                                        }
                                    }*/
                                }
                            }
                        }
                    }
                    
                    inactivateContactEntitlement(contactRelatedInactiveACRList, entitlementList, inactiveAcrIdList, allEntId, acrListWorksfor, inactiveUpdateCheck);
                      //HeapSize Fix
                    if(contactRelatedInactiveACRList != null){
                        contactRelatedInactiveACRList.clear();
                    }
                    contactRelatedInactiveACRList = null;
                    
                    if(entitlementList != null){
                        entitlementList.clear();
                    }
                    entitlementList = null;
                    
                    if(inactiveAcrIdList != null){
                        inactiveAcrIdList.clear();
                    }
                    inactiveAcrIdList = null;
                    
                    if(allEntId != null){
                        allEntId.clear();
                    }
                    allEntId = null;
                    
                    if(acrListWorksfor != null){
                        acrListWorksfor.clear();
                    }
                    acrListWorksfor = null;
                    activateContactEntitlement(contactRelatedActiveACRList, entitlementWithoutBEList, entitlementABList, mapContIdToSourceAgent, activeUpdateCheck);
                     //HeapSize Fix TWC729-9312
                    if(contactRelatedActiveACRList != null){
                        contactRelatedActiveACRList.clear();
                    }
                    contactRelatedActiveACRList = null;
                    
                    if(entitlementWithoutBEList != null){
                        entitlementWithoutBEList.clear();
                    }
                    entitlementWithoutBEList = null;
                    
                    if(entitlementABList != null){
                        entitlementABList.clear();
                    }
                    entitlementABList = null;
                    //Email to primary contact when such incative operation of ACR happen
                    if(String.isNotEmpty(profileName) && profileName.toUpperCase() != System.Label.PRM_INTEGRATION_PROFILE.toUpperCase()
                    ){
                        /*errMsg+='Line 490 \n';*/errMsgs.add('Line 490');
                        /* Long usedHeap   = Limits.getHeapSize();        
Long totalHeap  = Limits.getLimitHeapSize();
Decimal percent = (Decimal.valueOf(usedHeap) / Decimal.valueOf(totalHeap)) * 100;
System.debug('Heap Used (%): ' + percent.setScale(2));
                        errMsgs.add('Heap size usedd--'+percent.setScale(2));*/
                        
                        List<PRM_Account_Contact_Relationship__c> acrRelationshipList=[Select id,PRM_InActive_Ind__c,PRM_Relationship_Id__c,PRM_Relationship_Id__r.Name from PRM_Account_Contact_Relationship__c where id in:oldMap.keySet()];
                        Map<Id,sObject>acrRelationMap=new Map<Id,sObject>();
                        for(PRM_Account_Contact_Relationship__c acr:acrRelationshipList){
                            acrRelationMap.put(acr.Id,acr);
                        }
                        
                        
                        //PRM_SendEmailsToPrimaryContacts.emailToContactWrapper wrapperRecForEmail = new PRM_SendEmailsToPrimaryContacts.emailToContactWrapper(oldMap,acrNewList,null,false,true, null);
                       //JB 
                       PRM_SendEmailsToPrimaryContacts.emailToContactWrapper wrapperRecForEmail = new PRM_SendEmailsToPrimaryContacts.emailToContactWrapper(acrRelationMap,acrNewList,null,false,true, null);    
                        emailToContactWrapperList.add(wrapperRecForEmail); 
                        //PRM_EmailToPrimaryContact.sendEmailToAllPrimaryContact(oldMap, newMap, null, false, true);
                        
                       // PRM_EmailToPrimaryContact.sendEmailToAllPrimaryContact(acrRelationMap, newMap, null, false, true);
                        
                        // PRM_SendEmailsToPrimaryContacts.sendEmailToAllPrimaryContact(emailToContactWrapperList);
                    }
                    if(emailToContactWrapperList!=null && !emailToContactWrapperList.isempty()){
                         PRM_SendEmailsToPrimaryContacts.sendEmailToAllPrimaryContact(emailToContactWrapperList);
                    } 
                    //heapsize error
                    Core_Log_Entry.logEntryWithDetails('PRM_AcctContRel_TriggerHandlerNew','IPA','PRM_AcctContRel_TriggerHandlerNew','Info','PRM_AcctContRel_TriggerHandlerNew - line 494 Invoked at ' + System.now(),getLogMessage(),'','','');
                   // Core_Log_Entry.logEntryWithDetails('PRM_AcctContRel_TriggerHandlerNew','IPA','PRM_AcctContRel_TriggerHandlerNew','Info','PRM_AcctContRel_TriggerHandlerNew - line 494  Invoked at' + system.now(),errMsg,'','','');
                    if(!System.Isbatch() && System.Label.PRM_Tracker_Enabled == 'true' && contids.size() > 0){
                       // errMsg+='Line 495 contids is--'+contids+' \n';
                       errMsgs.add('Line 495 contids is--' + contids);
                       /* Long usedHeap   = Limits.getHeapSize();        
Long totalHeap  = Limits.getLimitHeapSize();
Decimal percent = (Decimal.valueOf(usedHeap) / Decimal.valueOf(totalHeap)) * 100;
System.debug('Heap Used (%): ' + percent.setScale(2));
                        errMsgs.add('Heap size usedd--'+percent.setScale(2));*/
                        Core_Log_Entry.logEntryWithDetails('PRM_AcctContRel_TriggerHandlerNew','IPA','PRM_AcctContRel_TriggerHandlerNew','Info','PRM_AcctContRel_TriggerHandlerNew - line 497  Invoked at' + system.now(),errMsg,'','','');
                      //  Core_Log_Entry.logEntryWithDetails('PRM_AcctContRel_TriggerHandlerNew','IPA','PRM_AcctContRel_TriggerHandlerNew','Info','PRM_AcctContRel_TriggerHandlerNew - line 497  Invoked at' + system.now(),errMsg,'','','');
                        system.enqueueJob( new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable( null, contids, false, false ));
                    }
                      //HeapSize Fix
                    errMsgs.clear();
                    if(!setConIdsForUnCheckSupression.isEmpty()){
                        /*List<PRM_Email_Handler__c> listEmailHandler = [SELECT Id
                                                                      FROM PRM_Email_Handler__c
                                                                      WHERE PRM_Contact__c IN :setConIdsForUnCheckSupression
                                                                      AND PRM_Suppress_Email__c = TRUE
                                                                      AND PRM_Email_Handler_Status__c != 'Completed'];*/
                        //TWC729-7584 - ApexGuru
                        List<PRM_Email_Handler__c> listEmailHandler = [SELECT Id
                                                                      FROM PRM_Email_Handler__c
                                                                      WHERE PRM_Contact__c IN :setConIdsForUnCheckSupression
                                                                      AND PRM_Suppress_Email__c = TRUE
                                                                      AND PRM_Email_Handler_Status__c = 'Requested For Suppression'];
                        if(!listEmailHandler.isEmpty()){
                            for(PRM_Email_Handler__c emailHanlder : listEmailHandler
                            ){
                                emailHanlder.PRM_Suppress_Email__c = false;
                            }
                            
                            //List<Database.SaveResult> results =
                            PRM_DMLUtility.doupdate(listEmailHandler, 'PRM_Email_Handler__c', 'PRM_AccountContactRel_TriggerHandlerNew.afterUpdate');
                        }
                    }
                    if(firstUpdateRun){
                        PRM_AGS_IdentityCreation.ReInviteBySendingEmailVerification((Map<Id, PRM_Account_Contact_Relationship__c>) Trigger.oldMap, Trigger.new);
                        firstUpdateRun = false;
                    }
                } catch(Exception e){
                    PRM_ErrorUtilityClass.logError(e);
                }
            }
        }
        // Stamps the OPID flag for any new/activated Partner Admin ACR; runs last so existing enqueues keep priority.
        if (affectsPartnerAdminFlag(
            (List<PRM_Account_Contact_Relationship__c>) Trigger.new,
            (Map<Id, PRM_Account_Contact_Relationship__c>) Trigger.oldMap)) {
            PRM_OpidPartnerAdminFlagService.handleAcrChanges(
                (List<PRM_Account_Contact_Relationship__c>) Trigger.new,
                (Map<Id, PRM_Account_Contact_Relationship__c>) Trigger.oldMap);
        }
      /*  Long usedHeap   = Limits.getHeapSize();        
Long totalHeap  = Limits.getLimitHeapSize();
Decimal percent = (Decimal.valueOf(usedHeap) / Decimal.valueOf(totalHeap)) * 100;
System.debug('Heap Used (%)1113: ' + percent.setScale(2));*/
    }
    
    //*************************************beforeInsert******************************************** */
    public override void beforeInsert(){
        //code to skip to update ACR status to pending action for some profiles.TWC729-6947
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :(userinfo.getProfileId())].Name;
        string profilesForCompleteACR=LabelConfiguration__mdt.getInstance('PRM_profilesForCompleteACR').Value__c;

        //TWC729-9166:India Registration
        blockedDomainValidation(Trigger.new);

        if(executeTrigger){
            if(triggerExecution.containsKey('Ags_Outbound_Msg') && triggerExecution.get('Ags_Outbound_Msg').Active__c/*isActive('Ags_Outbound_Msg')*/ && PRM_AcctContRelUtility.firstRunBeforeInsert
            ){
                //Retrieved FROM Custom labels
                if(Trigger.isInsert){
                    Map<Id, PRM_Account_Contact_Relationship__c> oldMapAcr =(Map<Id, PRM_Account_Contact_Relationship__c>) Trigger.oldMap;
                    List<PRM_Account_Contact_Relationship__c> acrRecNewList =(List<PRM_Account_Contact_Relationship__c>) Trigger.new;
                    /*List<Id> idslist = new List<Id>();
                    List<String> uniqstr = new List<String>();
                    Map<String, Id> uniqmap = new Map<String, Id>();
                    Set<Id> contactIdSet = new Set<Id>();
                    Set<String> emailIdSet = new Set<String>();
                    Set<String> regReqEmailSet = new Set<String>();
                    Map<Id, String> conIdConEmailMap = new Map<Id, String>();
                    List<PRM_Email_Handler__c> emailHandlerRecordsToInsert = new List<PRM_Email_Handler__c>();*/
                        Set<id> SysAccIdSet = new Set<id>();
                    //Set<id> accountIdSet = new Set<id>();
                    Map<String, Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
                    set<string> lstBlockedAcc=new set<String>();
                    try {
                        PRM_AcctContRelUtility.firstRunBeforeInsert = false;
                        duplicateRecordCheck(acrRecNewList, oldMapAcr);
                       // validatePAPADConflict(acrRecNewList);//TWC729-9377-Validation needed when someone tries to create PA PCR when PAD is present and vice versa
                       List<PRM_Account_Contact_Relationship__c> papadCheckList = getPAPADCandidates(acrRecNewList, null);
                        if (!papadCheckList.isEmpty()) {
                            validatePAPADConflict(papadCheckList);//TWC729-9377
                        }
                       if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))
                        ){
                            updateStartandEndDates(acrRecNewList, oldMapAcr);
                        }
                        
                        suppressEmail(acrRecNewList, null);
                        
                        //User CurrentUser = [SELECT id, isportalenabled FROM User WHERE id = :userinfo.getuserid()];
                        
                        for(String keySetString : mapSysAcc.keySet()){
                            SysAccIdSet.add(mapSysAcc.get(keySetString).AccountId__c);
                        }
                        
                        for(PRM_Account_Contact_Relationship__c acr : acrRecNewList
                        ){
                            //PRM_Account_Contact_Relationship__c oldAcr = oldMapAcr != null && oldMapAcr.containsKey(acr.Id) ? oldMapAcr.get(acr.Id) : null;
                            
                            //PRM_AcctContRelUtility.restrictContactAssociatedSystemAcc;
                            if(acr.PRM_Account_Id__c != null && SysAccIdSet != null && SysAccIdSet.contains(acr.PRM_Account_Id__c)
                            ){
                                acr.addError(System.label.PRM_ACR_SystemAccError);
                            }
                            lstBlockedAcc.add(acr.PRM_Contact_Id__c);
                            if(acr.PRM_Account_Id__c != null && acr.PRM_Status_Nm__c=='Complete')   
                                acrAccIds.add(acr.PRM_Account_Id__c);
                        }
                         if(acrAccIds!=null && !acrAccIds.isEmpty() && !Test.isRunningTest()){
                        validateACMsOnACRs(acrAccIds,trigger.new,null);
                        }
                        map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>();
                        mapOfAccWithBlokedStatus=   getBlockedContact(lstBlockedAcc);
                        
                        //check with piyush
                        for(PRM_Account_Contact_Relationship__c acr : (List<PRM_Account_Contact_Relationship__c>) Trigger.new){
                            if(String.isBlank(acr.PRM_Initiated_By__c)){
                                acr.PRM_Initiated_By__c = Userinfo.getUserId();
                            }
                            if(mapOfAccWithBlokedStatus.containsKey(acr.PRM_Contact_Id__c) && mapOfAccWithBlokedStatus.get(acr.PRM_Contact_Id__c)==true) {
                                acr.addError(System.label.PRM_BlockedContError_IPA);
                            }
                            
                        }
                        
                        
                    }catch(Exception e){ PRM_ErrorUtilityClass.logError(e);
                    }
                }
            }
            //Update PRM_Account_Contact_Relationship Status Field to Pending Action
            if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger) && Trigger.isInsert)
            && !(profilesForCompleteACR.split(';').contains(profileName)) && !PRM_AcctContRel_TriggerHandlerNew.isDZPRegistration){
                //Bypass update of Status Field if contact is loaded through Bulk Process
                PRM_AGS_IdentityCreation.updateAcctContRelation_StatusField(Trigger.new);
            }
        }
      /* Long usedHeap   = Limits.getHeapSize();        
Long totalHeap  = Limits.getLimitHeapSize();
Decimal percent = (Decimal.valueOf(usedHeap) / Decimal.valueOf(totalHeap)) * 100;
System.debug('Heap Used (%)1112: ' + percent.setScale(2));*/
    }
    
    //*************************************beforeUpdate******************************************** */
    public override void beforeUpdate(){

        //TWC729-9166:India Registration
        blockedDomainValidation(Trigger.new);

        if(triggerExecution.containsKey('Ags_Outbound_Msg') && triggerExecution.get('Ags_Outbound_Msg').Active__c/*isActive('Ags_Outbound_Msg')*/ && PRM_AcctContRelUtility.firstRunBeforeUpdate
        ){
            //Retrieved FROM Custom labels
            Map<Id, PRM_Account_Contact_Relationship__c> oldMap =(Map<Id, PRM_Account_Contact_Relationship__c>) Trigger.oldMap;
            List<PRM_Account_Contact_Relationship__c> acrNewList =(List<PRM_Account_Contact_Relationship__c>) Trigger.new;
            //List<PRM_Account_Contact_Relationship__c> oldAcrList =(List<PRM_Account_Contact_Relationship__c>) Trigger.old;
            //List<PRM_Email_Handler__c> emailHandlerRecordsToInsert = new List<PRM_Email_Handler__c>();
            Set<String> accountIds = new Set<String>();
            Set<String> activecontactIds = new Set<String>();
            Set<String> acrPartnerRole = new Set<String>();
            List<Id> acrList = new List<Id>();
            Set<Id> activeACMList = new Set<Id>();
            Set<ID> contactIdsForWorksFor = new Set<ID>();
            Set<ID> activeWorksForACRId = new Set<ID>();
            Set<String> contactIds = new Set<String>();
            /*List<Id> idslist = new List<Id>();
            List<String> uniqstr = new List<String>();
            Map<String, Id> uniqmap = new Map<String, Id>();
            Set<Id> contactIdSet = new Set<Id>();
            Set<String> emailIdSet = new Set<String>();
            Set<String> regReqEmailSet = new Set<String>();*/
                Set<String> idSet = new Set<String>();
            List<PRM_Account_Contact_Relationship__c> acrRecordListWorksFor = new List<PRM_Account_Contact_Relationship__c>();
            List<PRM_Account_Contact_Relationship__c> acrRecordList = new List<PRM_Account_Contact_Relationship__c>();
            
            try {
                //User CurrentUser = [SELECT id, isportalenabled FROM User WHERE id = :userinfo.getuserid()];
                for(PRM_Account_Contact_Relationship__c acr : acrNewList){
                    PRM_Account_Contact_Relationship__c oldAcr = oldMap != null && oldMap.containsKey(acr.Id) ? oldMap.get(acr.Id) : null;
                    //PRM_AcctContRelUtility.mandatoryRelationshipCheck;
                    //Start of Changes by Anupam Agarwal on 06-Dec-2018 for mandatory relationship check
                    if(oldAcr.PRM_InActive_Ind__c != true && (acr.PRM_Relationship_Id__c != oldAcr.PRM_Relationship_Id__c
                        || acr.PRM_Contact_Id__c != oldAcr.PRM_Contact_Id__c || oldAcr.PRM_InActive_Ind__c != acr.PRM_InActive_Ind__c)
                    ){
                        if(acr.PRM_Status_Nm__c == 'Complete'){
                            acrList.add(acr.Id);
                        }
                        accountIds.add(acr.PRM_Account_Id__c);
                        activecontactIds.add(acr.PRM_Contact_Id__c);
                        acrPartnerRole.add(acr.PRM_Partner_Role__c);
                    }
                    
                    //PRM_AcctContRelUtility.softContactCheck
                    if(!acr.PRM_InActive_Ind__c && acr.PRM_InActive_Ind__c != oldMap.get(acr.id).PRM_InActive_Ind__c
                    ){
                        acr.PRM_Soft_Contact__c = false;
                    }
                    
                    //PRM_AcctContRelUtility.updateSuppressEmail
                    if(oldAcr != null && ((oldAcr.PRM_InActive_Ind__c == false && acr.PRM_InActive_Ind__c == true && oldAcr.PRM_Suppress_Email__c == true)
                        || (oldAcr.PRM_Suppress_Email__c == true && oldAcr.PRM_Status_Nm__c == 'Pending Action' && acr.PRM_Status_Nm__c == 'Complete'))
                    ){
                        acr.PRM_Suppress_Email__c = false;
                        acr.PRM_Status_Reason_Txt__c = 'Pending to Complete';
                    }
                }
                
                /*US808806 -UTKARSH - Bypass validation rule when ACM become inactive*/
                if(accountIds != null && !accountIds.isEmpty()){//ATHR Fix - TWC729-9556 - SJ
                    for(PRM_AccountChannelMembership__c acm : [SELECT Id, Name, PRM_Account_Id__c, /*PRM_Account_Id__r.Name, PRM_Channel_Program_Id__c,
                                                               PRM_Channel_Program_Level_Id__r.Name, PRM_Partner_Role__c, PRM_Account_Id__r.RecordTypeId, */PRM_Status_Nm__c
                                                               FROM PRM_AccountChannelMembership__c
                                                               WHERE PRM_Account_Id__c IN :accountIds
                                                               AND PRM_Partner_Role__c IN :acrPartnerRole
                                                               AND PRM_Status_Nm__c = :System.Label.PRM_Status
                    ]){
                        activeACMList.add(acm.PRM_Account_Id__c);
                    }
                }
                
                if((accountIds != null && !accountIds.isEmpty()) || (acrList != null && !acrList.isEmpty())
                ){
                    acrRecordList = [SELECT Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Status_Nm__c, PRM_Relationship_Id__c, PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c,
                                    PRM_InActive_Ind__c, PRM_Unique_Combination__c, PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c
                                    FROM PRM_Account_Contact_Relationship__c 
                                    WHERE PRM_Account_Id__c IN :accountIds
                                    // OR PRM_Contact_Id__c IN :contactIdsForWorksFor
                                    OR id IN :acrList];
                }
                
                if(acrRecordList != null && !acrRecordList.isEmpty()){
                    for(PRM_Account_Contact_Relationship__c acrRecord : acrRecordList
                    ){
                        if(acrList.contains(acrRecord.id) && acrRecord.PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c == true && acrRecord.PRM_InActive_Ind__c == false){
                            //Iterating over inactive acrlist and getting worksfor ids, contact ids specific to works for Relationship
                            activeWorksForACRId.add(acrRecord.id);
                            contactIdsForWorksFor.add(acrRecord.PRM_Contact_Id__c);
                        }
                        if(accountIds.contains(acrRecord.PRM_Account_Id__c) && acrRecord.PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c
                            && acrRecord.PRM_InActive_Ind__c == false && acrRecord.PRM_Status_Nm__c == 'Complete'
                        ){
                            idSet.add(acrRecord.id);
                            acrRecordListWorksFor.add(acrRecord);
                        }
                    }
                    
                    for(PRM_Account_Contact_Relationship__c acrRec : acrRecordList
                    ){
                        if(!acrRec.PRM_InActive_Ind__c && contactIdsForWorksFor.contains(acrRec.PRM_Contact_Id__c)
                            && acrRec.PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c && acrRec.PRM_Status_Nm__c == 'Complete'
                        ){
                            contactIds.add(acrRec.PRM_Contact_Id__c);
                        }
                    }
                }
                
                /*iterating over acr records and validating if its works for relationship record which has a primary contact relationship if it has then throwing an error */
                for(PRM_Account_Contact_Relationship__c acrRecordActiveRel : acrNewList
                ){
                    if(contactIds.size() > 0 && activeACMList.size() > 0){
                        if(
                            (contactIds.contains(acrRecordActiveRel.PRM_Contact_Id__c)) && activeWorksForACRId.size() > 0 &&
                            activeWorksForACRId.contains(acrRecordActiveRel.id) &&
                            activeACMList.contains(acrRecordActiveRel.PRM_Account_Id__c) &&
                            acrRecordActiveRel.PRM_Soft_Contact__c == false
                        ){
                            acrRecordActiveRel.addError(System.label.PRM_ACR_Error4);
                        }
                        if(acrRecordListWorksFor.size() <= 1 && idSet.contains(acrRecordActiveRel.id) &&
                            activeACMList.contains(acrRecordActiveRel.PRM_Account_Id__c) &&
                            acrRecordActiveRel.PRM_Soft_Contact__c == false
                        ){
                            acrRecordActiveRel.addError( System.label.PRM_ACR_Error4);
                        }
                    }
                      if(acrRecordActiveRel.PRM_Account_Id__c != null && acrRecordActiveRel.PRM_Status_Nm__c=='Complete')   
                                acrAccIds.add(acrRecordActiveRel.PRM_Account_Id__c);
                }
                
                
                if(acrAccIds!=null && !acrAccIds.isEmpty() && !Test.isRunningTest()){
                     //validateACMsOnACRs(acrAccIds,trigger.new,oldMap);
                }
                duplicateRecordCheck(acrNewList, oldMap);
               // validatePAPADConflict(acrNewList);//TWC729-9377-Validation needed when someone tries to create PA PCR when PAD is present and vice versa
               List<PRM_Account_Contact_Relationship__c> papadCheckList = getPAPADCandidates(acrNewList, oldMap);
                if (!papadCheckList.isEmpty()) {
                    validatePAPADConflict(papadCheckList);//TWC729-9377
                } 
               updateStartandEndDates(acrNewList, oldMap);
                suppressEmail(acrNewList, oldMap);
            } catch(Exception e){ PRM_ErrorUtilityClass.logError(e);
            }
        }
        Long usedHeap   = Limits.getHeapSize();        
Long totalHeap  = Limits.getLimitHeapSize();
Decimal percent = (Decimal.valueOf(usedHeap) / Decimal.valueOf(totalHeap)) * 100;
System.debug('Heap Used (%)111: ' + percent.setScale(2));
    }
    
    public override void beforeDelete(){
        if (affectsPartnerAdminFlag((List<PRM_Account_Contact_Relationship__c>) Trigger.old, null)) {
            PRM_OpidPartnerAdminFlagService.handleAcrDeletes((List<PRM_Account_Contact_Relationship__c>) Trigger.old);
        }
    }

    /*
     * An ACR can only change Is_Partner_Admin_Exist__c while it is active with a status that holds
     * the Partner Admin slot (Complete or Pending Action). The relationship name is not available
     * without SOQL, so the Partner Admin check itself happens later in the Queueable.
     * Pass Trigger.old with a null oldMap for deletes.
     */
    @TestVisible
    private static Boolean affectsPartnerAdminFlag(
        List<PRM_Account_Contact_Relationship__c> newList,
        Map<Id, PRM_Account_Contact_Relationship__c> oldMap
    ) {
        if (newList == null) {
            return false;
        }
        for (PRM_Account_Contact_Relationship__c acr : newList) {
            PRM_Account_Contact_Relationship__c old = (oldMap == null || acr.Id == null) ? null : oldMap.get(acr.Id);
            if (old == null) {
                if (holdsPartnerAdminSlot(acr)) {
                    return true;
                }
                continue;
            }
            if ((holdsPartnerAdminSlot(acr) || holdsPartnerAdminSlot(old))
                && (old.PRM_InActive_Ind__c != acr.PRM_InActive_Ind__c
                    || old.PRM_Status_Nm__c != acr.PRM_Status_Nm__c
                    || old.PRM_Relationship_Id__c != acr.PRM_Relationship_Id__c
                    || old.PRM_Account_Id__c != acr.PRM_Account_Id__c)) {
                return true;
            }
        }
        return false;
    }

    private static Boolean holdsPartnerAdminSlot(PRM_Account_Contact_Relationship__c acr) {
        return acr.PRM_Account_Id__c != null
            && acr.PRM_InActive_Ind__c != true
            && (acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status || acr.PRM_Status_Nm__c == 'Pending Action');
    }

    //*************************************beforeDelete******************************************** */
    /*public override void beforeDelete(){
        if(isActive('Ags_Outbound_Msg') && PRM_AcctContRelUtility.firstRunBeforeDelete){ //Retrieved FROM Custom labels
            if(Trigger.isUpdate){
                PRM_AcctContRelUtility.firstRunBeforeDelete=false;
                //Commenting this method - Agate: Data Purge Stories ACR
                //PRM_AcctContRelUtility.mandatoryDeletionCheck(Trigger.old);
            }
        }
    } */
    
    /************************************************************
    Method:    insertContactEntitlement
        Return:    void
        Purpose:   insert contact entitlements whenever ACR got inserted
        
     ************************************************************/
    
    public static void insertContactEntitlement(List<PRM_Account_Contact_Relationship__c> accConRelList, Map<Id, PRM_Account_Contact_Relationship__c> acrOldMap,
    List<PRM_AccountChannelMembership__c> acmLists
    ){
        List<Id> contactRelatedACRList = new List<Id>();
        List<Id> acrList = new List<Id>();
        List<Id> accIdList = new List<Id>();
        List<Id> benefitList = new List<Id>();
        List<Id> benefitListTemp = new List<Id>();
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> finalCEList = new List<Core_Contact_Entitlement__c>();
        List<PRM_VXEnttlmntMatrix__c> entitlementWithoutBenefit = new List<PRM_VXEnttlmntMatrix__c>();
        Map<String, List<Id>> benefitMap = new Map<String, List<Id>>();
        Map<Core_Contact_Entitlement__c, Id> ceMap = new Map<Core_Contact_Entitlement__c, Id>();
        Map<Id, List<PRM_AccountChannelMembership__c>> acmMap = new Map<Id, List<PRM_AccountChannelMembership__c>>();
        Map<Id, Core_Contact_Entitlement__c> ceStatusMap = new Map<Id, Core_Contact_Entitlement__c>();
        String updateReasonCSPFlow = System.Label.PRM_Entitlement_Source;
        PRM_Account_Contact_Relationship__c acrOld;
        Map<Id, String> entAgsMap = new Map<Id, String>();
        List<PRM_Batch_Entitlement__c> beListTemp = new List<PRM_Batch_Entitlement__c>();
        //List<PRM_VXEnttlmntMatrix__c> newEntitlementList = new List<PRM_VXEnttlmntMatrix__c>();
        List<Id> beCon = new List<Id>();
        List<Id> beEnt = new List<Id>();
        Map<Id, List<PRM_VXEnttlmntMatrix__c>> benefitEntitlementMap = new Map<Id, List<PRM_VXEnttlmntMatrix__c>>();
        Map<Id, List<Id>> mapAccToBenefits = new Map<Id, List<Id>>();
        //Fetching accountId, contactId, relationshipId FROM ACR inserted.
        try {
            if(accConRelList != null && !accConRelList.IsEmpty()){
                for(PRM_Account_Contact_Relationship__c acr : accConRelList){
                    if(acrOldMap != null && acrOldMap.size() > 0){
                        acrOld =(PRM_Account_Contact_Relationship__c) acrOldMap.get(acr.id);
                        if(((acrOld.PRM_Status_Nm__c != acr.PRM_Status_Nm__c && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status &&
                            acr.PRM_InActive_Ind__c == false) || (acrOld.PRM_InActive_Ind__c != acr.PRM_InActive_Ind__c && !acr.PRM_InActive_Ind__c &&
                            acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status))
                        ){
                            acrList.add(acr.PRM_Relationship_Id__c);
                            contactRelatedACRList.add(acr.PRM_Contact_Id__c);
                            accIdList.add(acr.PRM_Account_Id__c);
                        }
                    }else{
                        if(acr.PRM_InActive_Ind__c == false && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status
                        ){
                            acrList.add(acr.PRM_Relationship_Id__c);
                            contactRelatedACRList.add(acr.PRM_Contact_Id__c);
                            accIdList.add(acr.PRM_Account_Id__c);
                        }
                    }
                }
            }
            if(accIdList != null && !accIdList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm : acmLists){
                    if(accIdList.contains(acm.PRM_Account_Id__c)){
                        List<PRM_AccountChannelMembership__c> acmList;
                        if(acmMap.get(acm.PRM_Account_Id__c) != null && !acmMap.get(acm.PRM_Account_Id__c).isEmpty()
                        ){
                            acmList = acmMap.get(acm.PRM_Account_Id__c);
                        }else{
                            acmList = new List<PRM_AccountChannelMembership__c>();
                        }
                        acmList.add(acm);
                        acmMap.put(acm.PRM_Account_Id__c, acmList);
                    }
                }
                
                /*TWC727-747 - Utkarsh - Changes done to add 'Points redeem entitlement to Partner admin contact invited through partner invite */
                for(Core_Account_Group_Member__c pag :[Select id,Core_Intel_Account_Id__c,Core_Partner_Account_Id__c,Core_Inactive_Ind__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c IN :accIdList AND Core_Inactive_Ind__c = false]){
                    if(!accIdList.contains(pag.Core_Partner_Account_Id__c)){
                        accIdList.add(pag.Core_Partner_Account_Id__c);
                    }
                }
                
                if(!accIdList.isEmpty())
                { 	for(PRM_AccountBenefitAssociation__c aba : [SELECT Id, PRM_Partner_Benefit_Id__c, PRM_Account_Id__c, PRM_Status_Nm__c/*, PRM_Partner_Benefit_Id__r.Name*/
                                                            FROM PRM_AccountBenefitAssociation__c
                                                            WHERE PRM_Account_Id__c IN :accIdList AND PRM_Status_Nm__c = :System.Label.PRM_Status_Active
                    ]){//ATHR Fix - TWC729-9556 - SJ
                        benefitList.add(aba.PRM_Partner_Benefit_Id__c);
                        if(mapAccToBenefits.containsKey(aba.PRM_Account_Id__c)){
                            mapAccToBenefits.get(aba.PRM_Account_Id__c).add(aba.PRM_Partner_Benefit_Id__c);
                        }else {
                            mapAccToBenefits.put(aba.PRM_Account_Id__c, new List<Id>{ aba.PRM_Partner_Benefit_Id__c});
                        }
                    }
            	}
            }
            
            if(benefitList != null && !benefitList.IsEmpty()){
                List<PRM_VXBnftMatrix__c> vxbm = [Select Id,PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_IsActive_Ind__c 
                                                  From PRM_VXBnftMatrix__c 
                                                  Where PRM_Partner_Benefit_Id__c IN :benefitList AND PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_IsActive_Ind__c = True];
                //filtering out automatic benefits from the list of benefits.
                for(Id accID :accIdList){
                    if(benefitMap.get(accID)!= null && !benefitMap.get(accID).isEmpty()){
                        benefitListTemp = benefitMap.get(accID);
                    }
                    for(PRM_VXBnftMatrix__c bm : vxbm){
                        benefitListTemp.add(bm.PRM_Partner_Benefit_Id__c);
                        benefitMap.put(accID,benefitListTemp);
                    }
                }
            }
            
            // Fetching entitlements which are not associated to any benefits.
            for(PRM_VXEnttlmntMatrix__c vx : [SELECT id, PRM_Entitlement_Id__c, PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, 
                                             PRM_Partner_Benefit_Id__c, PRM_Approval_Type_Nm__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c, 
                                             PRM_IPA_Partner_Role_Nm__c, RecordType.Name, PRM_AGS_Role__c
                                             FROM PRM_VXEnttlmntMatrix__c
                                             WHERE PRM_Approval_Type_Nm__c = :System.Label.PRM_ApprovalType AND PRM_IsActive_Ind__c = TRUE AND PRM_IPA_Partner_Role_Nm__c != NULL
            ]){
                if(vx.RecordType.Name == System.Label.PRM_Entitlement_RecordType){
                    entitlementWithoutBenefit.add(vx);
                }
                if(!benefitListTemp.isEmpty() && benefitListTemp.contains(vx.PRM_Partner_Benefit_Id__c)
                ){
                    //Checking for multiple entitlements on single benefits.
                    List<PRM_VXEnttlmntMatrix__c> entitlements = new List<PRM_VXEnttlmntMatrix__c>();
                    if(benefitEntitlementMap.get(vx.PRM_Partner_Benefit_Id__c) != null && !benefitEntitlementMap.get(vx.PRM_Partner_Benefit_Id__c).isEmpty()
                    ){
                        entitlements = benefitEntitlementMap.get(vx.PRM_Partner_Benefit_Id__c);
                    }
                    entitlements.add(vx);
                    benefitEntitlementMap.put(vx.PRM_Partner_Benefit_Id__c,entitlements);
                }
            }
            
            if(accIdList != null && !accIdList.IsEmpty()){
                List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id IN :accIdList];
                Map<Id, List<PRM_VXEnttlmntMatrix__c>> accEntitlementsMap = new Map<Id, List<PRM_VXEnttlmntMatrix__c>>();
                for(Account acc : accounts){
                    List<Id> accBenefits =(List<Id>) benefitMap.get(acc.Id);
                    if(accBenefits != null && !accBenefits.IsEmpty()){
                        List<PRM_VXEnttlmntMatrix__c> accEntitlements = new List<PRM_VXEnttlmntMatrix__c>();
                        if(accEntitlementsMap.get(acc.Id) != null && !accEntitlementsMap.get(acc.Id).isEmpty()
                        ){
                            accEntitlements = accEntitlementsMap.get(acc.Id);
                        }
                        for(integer i = 0; i < accBenefits.size(); i++){
                            List<PRM_VXEnttlmntMatrix__c> benfitEntitlements = new List<PRM_VXEnttlmntMatrix__c>();
                            benfitEntitlements = benefitEntitlementMap.get(accBenefits[i]);
                            if(benfitEntitlements != null && !benfitEntitlements.IsEmpty()
                            ){
                                accEntitlements.addAll(benfitEntitlements);
                            }
                        }
                        accEntitlementsMap.put(acc.Id, accEntitlements);
                    }
                }
                //Assigning contact entitlements.
                for(PRM_Account_Contact_Relationship__c acr : accConRelList){
                    if(acr.PRM_Status_Nm__c != 'Complete'){
                        continue;
                    }
                    List<PRM_VXEnttlmntMatrix__c> entitlements = new List<PRM_VXEnttlmntMatrix__c>();
                    //List<string> partnerRole = new List<string>();
                    entitlements = accEntitlementsMap.get(acr.PRM_Account_Id__c);
                    if(entitlements != null && !entitlements.IsEmpty() && acr.PRM_Partner_Role__c != null
                    ){
                        // Assigning entitlements based on the benefits.
                        for(integer i = 0; i < entitlements.size(); i++){
                            if(entitlements[i].PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c &&
                                (acr.PRM_Partner_Role__c == entitlements[i].PRM_IPA_Partner_Role_Nm__c)
                            ){
                                entAgsMap.put(entitlements[i].PRM_Entitlement_Id__c, entitlements[i].PRM_AGS_Role__c);
                                Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
                                ce.Core_Contact_Id__c = acr.PRM_Contact_Id__c;
                                ce.Core_Entitlement_Id__c = entitlements[i].PRM_Entitlement_Id__c;
                                ce.Core_Selected__c = true;
                                ce.Core_FROM_Source__c = false;
                                // avoid SOQL 101 exception in existing entitlement trigger code
                                if(!test.isRunningTest()){
                                    ce.Core_Data_Loaded__c = true;
                                    ce.Core_DontNotify__c = false;
                                }
                                if(entitlements[i].PRM_AGS_Role__c == '' || entitlements[i].PRM_AGS_Role__c == null
                                ){
                                    ce.Core_FROM_Source__c = true;
                                }
                                if(!ceList.Contains(ce)){
                                    ceList.add(ce);
                                }
                            }
                        }
                    }
                    // Assigning default entitlements.
                    for(PRM_VXEnttlmntMatrix__c em : entitlementWithoutBenefit
                    ){
                        List<PRM_AccountChannelMembership__c> acm = new List<PRM_AccountChannelMembership__c>();
                        if(acmMap != null && !acmMap.IsEmpty()){
                            acm = acmMap.get(acr.PRM_Account_Id__c);
                        }
                        for(integer i = 0; i < acm.size(); i++){
                            if((acr.PRM_Partner_Role__c != null && em.PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c) &&
                                (acr.PRM_Partner_Role__c == em.PRM_IPA_Partner_Role_Nm__c) &&
                                (em.PRM_Channel_Program_Level_Id__c == acm[i].PRM_Channel_Program_Level_Id__c) &&
                                (acr.PRM_Partner_Role__c == acm[i].PRM_Partner_Role__c)
                            ){
                                entAgsMap.put(em.PRM_Entitlement_Id__c, em.PRM_AGS_Role__c);
                                Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
                                ce1.Core_Contact_Id__c = acr.PRM_Contact_Id__c;
                                ce1.Core_Entitlement_Id__c = em.PRM_Entitlement_Id__c;
                                ce1.Core_Selected__c = true;
                                ce1.Core_Data_Loaded__c = true;
                                ce1.Core_DontNotify__c = false;
                                ce1.Core_FROM_Source__c = false;
                                if(em.PRM_AGS_Role__c == '' || em.PRM_AGS_Role__c == null){
                                    ce1.Core_FROM_Source__c = true;
                                }
                                if(!ceList.Contains(ce1)){
                                    ceList.add(ce1);
                                }
                            }
                        }
                    }
                }
            }
            //Checking for existing Contact Entitlements.
            // Core_Type__c = 'Entitlement'
            if(!contactRelatedACRList.isEmpty()){
                for(Core_Contact_Entitlement__c ce : [SELECT Id, Name, Core_Selected__c, Core_Entitlement_Id__c, Core_Contact_Id__c, Core_Status__c,
                                                     Core_Data_Loaded__c, Core_DontNotify__c, Core_Type__c, Core_Source__c, Core_FROM_Source__c
                                                     FROM Core_Contact_Entitlement__c
                                                     WHERE Core_Contact_Id__c IN :contactRelatedACRList
                ]){
                    Core_Contact_Entitlement__c newCe = new Core_Contact_Entitlement__c();
                    newCe.Core_Contact_Id__c = ce.Core_Contact_Id__c;
                    newCe.Core_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                    newCe.Core_Selected__c = true;
                    newCe.Core_Data_Loaded__c = true;
                    newCe.Core_DontNotify__c = false;
                    newCe.Core_FROM_Source__c = ce.Core_FROM_Source__c;
                    ceMap.put(newCe, ce.Id);
                    ceStatusMap.put(ce.Id, ce);
                }
            }
            for(Core_Contact_Entitlement__c ce : ceList){
                updateCheck = false;
                beCon.add(ce.Core_Contact_Id__c);
                beEnt.add(ce.Core_Entitlement_Id__c);
                if(ceMap.containsKey(ce)){
                    ce.Id = ceMap.get(ce);
                    Core_Contact_Entitlement__c contEnt = ceStatusMap.get(ce.Id);
                    if(contEnt.Core_Source__c == '' && contEnt.Core_Source__c == null){
                        ce.Core_Source__c = updateReasonCSPFlow;
                        updateCheck = true;
                    }
                    if(!contEnt.Core_Selected__c){
                        ce.Core_Selected__c = true;
                        if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(ce.Core_Entitlement_Id__c) != '' && entAgsMap.get(ce.Core_Entitlement_Id__c) != null)
                        ){
                            ce.Core_Status__c = 'Pending';
                            updateCheck = true;
                        }
                        if(updateCheck){
                            finalCEList.add(ce);
                        }
                    }else{
                        ce.Core_Selected__c = true; //Inserting Entitlements.
                        if(ce.Core_Source__c == null && ce.Core_Source__c == ''
                        ){
                            ce.Core_Source__c = updateReasonCSPFlow;
                        }
                        if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(ce.Core_Entitlement_Id__c) != '' && entAgsMap.get(ce.Core_Entitlement_Id__c) != null)
                        ){
                            ce.Core_Status__c = 'Pending';
                        }
                        finalCEList.add(ce);
                    }
                }
                else{
                        if(ce.Core_Source__c == null && ce.Core_Source__c == ''){
                            ce.Core_Source__c = updateReasonCSPFlow;
                        }
                        if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(ce.Core_Entitlement_Id__c) != '' && entAgsMap.get(ce.Core_Entitlement_Id__c) != null)){
                            ce.Core_Status__c = 'Pending';
                        }
                        finalCEList.add(ce);
                    }
            }
            if((beCon != null && !beCon.IsEmpty()) && (beEnt != null && !beEnt.IsEmpty())
            ){
                // Updating batch entitlement records.
                for(PRM_Batch_Entitlement__c batchEntitlements : [SELECT Id, Name, PRM_Contact_Id__c, PRM_Entitlement_Id__c, PRM_Status_Nm__c, PRM_IsRemove_Ind__c,PRM_Status_Reason_Txt__c
                                                                 FROM PRM_Batch_Entitlement__c
                                                                 WHERE PRM_Status_Nm__c = 'New'  AND PRM_Contact_Id__c IN :beCon AND PRM_Entitlement_Id__c IN :beEnt
                ]){
                    batchEntitlements.PRM_Status_Nm__c = 'Success';
                    batchEntitlements.PRM_Status_Reason_Txt__c ='PRM_AcctContRel_TriggerHandlerNew : Entitlement insertion/removal succeeded';//TWC729-8089 : Adding reason text : NJ
                    beListTemp.add(batchEntitlements);
                }
            }
            if(finalCEList != null && !finalCEList.IsEmpty()){
                for(Core_Contact_Entitlement__c ce1 : finalCEList){
                    // Inserting batch entitlement records.
                    PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                    be.PRM_Contact_Id__c = ce1.Core_Contact_Id__c;
                    be.PRM_Entitlement_Id__c = ce1.Core_Entitlement_Id__c;
                    be.PRM_Status_Nm__c = System.label.PRM_Status_New;
                    be.PRM_Status_Reason_Txt__c = 'PRM_AcctContRel_TriggerHandlerNew : Activation of Entitlement';//TWC729-8089 : Adding reason text : NJ
                    if(!beListTemp.Contains(be)){
                        beListTemp.add(be);
                    }
                }
            }
            if(beListTemp != null && !beListTemp.IsEmpty()){
                //Database.UpsertResult[] upsertResult =
                PRM_DMLUtility.doupsert(beListTemp, 'PRM_Batch_Entitlement__c', 'PRM_AccountContactRel_TriggerHandlerNew.insertContactEntitlement');
            }
            //HeapSize Fix
            ceList.clear();
            finalCEList.clear();
            benefitList.clear();
            benefitListTemp.clear();
            beListTemp.clear();
            
            ceList = null;
            finalCEList = null;
            benefitList = null;
            benefitListTemp = null;
            beListTemp = null;
        } catch(Exception e){ PRM_ErrorUtilityClass.logError(e);
        }
    }
    
    /************************************************************
    Method:    inactivateContactEntitlement
        Return:    void
        Purpose:   if any ACR become inactive then delete contact entitlement related with that parent contact which parent for the inactive ACR
        
     ************************************************************/
    //US389505 - Start - As part of the story
    public static void inactivateContactEntitlement(List<Id> contactRelatedACRList, List<Id> entitlementList, List<PRM_Account_Contact_Relationship__c> inactiveAcrIdList,
    Set<Id> allEntId, List<PRM_Account_Contact_Relationship__c> acrListWorksfor, boolean updateCheck
    ){
        //System.debug('Parameters---> '+ contactRelatedACRList + '2--> ' +entitlementList +'3--> '+inactiveAcrIdList + '4--> '+allEntId+ '5--> '+acrListWorksfor+ '6--> '+updateCheck);
        //List<Id> acrList = new List<Id>();
        List<PRM_ContactSubscriptionAssociation__c> conSubAssocUpdateList = new List<PRM_ContactSubscriptionAssociation__c>();
        List<PRM_Contact_Group_Contact_Association__c> conGroupConAssocUpdateList = new List<PRM_Contact_Group_Contact_Association__c>();
        List<PRM_Batch_Entitlement__c> beListTemp = new List<PRM_Batch_Entitlement__c>();
        List<String> beuniqueList = new List<String>();
        List<Contact> UpdateContact = new List<Contact>();
        Set<id> contset = new Set<id>();
        Set<id> conFinalset = new Set<id>();
        Set<Id> softContatid = new Set<Id>();
        Boolean softContactIndicator = false;
        
        //Query on BatchCustomSetting to fetch Entitlements
        PRM_BatchCustomSetting__c batchCustomSetting;
        List<String> entitlementNotToInactivate = new List<String>();
        batchCustomSetting = [Select Id, PRM_EntitlementsNotToInactivate__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        
        if(batchCustomSetting.PRM_EntitlementsNotToInactivate__c != null){
            entitlementNotToInactivate = batchCustomSetting.PRM_EntitlementsNotToInactivate__c.split(';');
        }
        
        //Fetching relationshipId FROM ACR
        try {
            if(updateCheck || test.isRunningTest()){
                if(acrListWorksfor != null && !acrListWorksfor.isEmpty()){
                    if(!contactRelatedACRList.IsEmpty() && !entitlementList.IsEmpty()
                    ){
                        List<String> nonProcessedRecords = new List<String>();
                        List<PRM_Batch_Entitlement__c> batchEntList = [SELECT Id, Name, PRM_Contact_Id__c, PRM_Entitlement_Id__c, PRM_Status_Nm__c, PRM_IsRemove_Ind__c,PRM_Status_Reason_Txt__c
                                                                            FROM PRM_Batch_Entitlement__c
                                                                            WHERE PRM_Status_Nm__c = 'New' 
                                                                            AND PRM_Contact_Id__c IN :contactRelatedACRList AND PRM_Entitlement_Id__c IN :entitlementList];
                        for(PRM_Batch_Entitlement__c batchEntitlements :  batchEntList){
                            if(batchEntitlements.PRM_Status_Nm__c=='NEW'){
                            batchEntitlements.PRM_Status_Nm__c = 'Success';
                            batchEntitlements.PRM_Status_Reason_Txt__c ='PRM_AcctContRel_TriggerHandlerNew : Entitlement insertion/removal succeeded';//TWC729-8089 : Adding reason text : NJ
                            beListTemp.add(batchEntitlements);
                            beuniqueList.add(batchEntitlements.PRM_Contact_Id__c+'-'+batchEntitlements.PRM_Entitlement_Id__c);
                            }
                            if(batchEntitlements.PRM_IsRemove_Ind__c){
                                nonProcessedRecords.add(batchEntitlements.PRM_Contact_Id__c+'_'+batchEntitlements.PRM_Entitlement_Id__c);
                            }
                        }
                        
                        //Updating Contact Entitlement fields.
                        for(Core_Contact_Entitlement__c ce : [SELECT Id, Name, Core_SELECTed__c, Core_Status__c, Core_Contact_Id__c,
                                                                Core_Entitlement_Id__c, Core_Type__c, Core_Entitlement_Id__r.Name
                                                                FROM Core_Contact_Entitlement__c
                                                                WHERE Core_Entitlement_Id__c IN :entitlementList
                                                                AND Core_Contact_Id__c IN :contactRelatedACRList AND(Core_Type__c = :System.Label.PRM_Entitlement_Type
                                                                OR Core_Entitlement_Id__r.Name = :System.Label.PRM_PSG)
                        ]){
                            if(ce.Core_SELECTed__c || Test.IsRunningTest()){
                                // Updating Contact Entitlement status to pending when entitlement is active else status will remain same as previous.
                                if( entitlementNotToInactivate == null || (!entitlementNotToInactivate.IsEmpty() && !entitlementNotToInactivate.contains(ce.Core_Entitlement_Id__r.Name)))
                                {
                                    String key = ce.Core_Contact_Id__c+'_'+ce.Core_Entitlement_Id__c;
                                    if(!nonProcessedRecords.contains(key)){
                                    PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                                    be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                                    be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                                    be.PRM_Status_Nm__c = System.label.PRM_Status_New;
                                    be.PRM_Status_Reason_Txt__c = 'PRM_AcctContRel_TriggerHandlerNew : Removal of Entitlement';//TWC729-8089 : Adding reason text : NJ
                                    be.PRM_IsRemove_Ind__c = true;
                                    
                                    if(!beuniqueList.Contains(be.PRM_Contact_Id__c+'-'+be.PRM_Entitlement_Id__c)){
                                        beListTemp.add(be);
                                        beuniqueList.add(be.PRM_Contact_Id__c+'-'+be.PRM_Entitlement_Id__c);
                                    }
                                }
                            }
                        }
                    }
                    }
                }else {
                    Set<Id> finalExistingEntId = new Set<Id>();
                    List<Core_Contact_Entitlement__c> finalCEList = new List<Core_Contact_Entitlement__c>();
                    //List<Contact> conList = new List<Contact>();
                    
                    if(!contactRelatedACRList.IsEmpty()){
                        for(Core_Contact_Entitlement__c existingCE : [SELECT Id, Name, Core_SELECTed__c, Core_Status__c, Core_Contact_Id__c, Core_Contact_Id__r.Core_IPA_PartnerRole__c,
                                Core_Entitlement_Id__c, Core_Type__c, Core_Entitlement_Id__r.Name
                                FROM Core_Contact_Entitlement__c
                                WHERE Core_Contact_Id__c IN :contactRelatedACRList AND (NOT Core_Entitlement_Id__r.Name = :System.Label.PRM_WebTicketing)
                                AND(Core_Type__c = :System.Label.PRM_Entitlement_Type OR Core_Entitlement_Id__r.Name = :System.Label.PRM_PSG)
                                
                        ]){
                            if(!allEntId.IsEmpty() && allEntId.contains(existingCE.Core_Entitlement_Id__c)
                            ){
                                finalExistingEntId.add(existingCE.Core_Entitlement_Id__c);
                                finalCEList.add(existingCE);
                                                               
                            }
                        }
                    }
                    List<PRM_Batch_Entitlement__c> batchEntList =  new List<PRM_Batch_Entitlement__c>();
                    List<String> nonProcessedRecords = new List<String>();
                    if(!contactRelatedACRList.IsEmpty() && !finalExistingEntId.IsEmpty()
                    ){
                        batchEntList = [SELECT Id, Name, PRM_Contact_Id__c, PRM_Entitlement_Id__c, PRM_Status_Nm__c, PRM_IsRemove_Ind__c,PRM_Status_Reason_Txt__c
                                                                          FROM PRM_Batch_Entitlement__c
                                                                          WHERE (PRM_Status_Nm__c = 'New' OR PRM_Status_Nm__c = 'In Progress') AND PRM_Contact_Id__c IN :contactRelatedACRList AND PRM_Entitlement_Id__c in: finalExistingEntId ];
                        for(PRM_Batch_Entitlement__c batchEntitlements : batchEntList){
                            if(batchEntitlements.PRM_Status_Nm__c=='New' && !batchEntitlements.PRM_IsRemove_Ind__c){
                            batchEntitlements.PRM_Status_Nm__c = 'Success';
                            batchEntitlements.PRM_Status_Reason_Txt__c ='PRM_AcctContRel_TriggerHandlerNew : Entitlement insertion/removal succeeded';//TWC729-8089 : Adding reason text : NJ
                            beListTemp.add(batchEntitlements);
                            beuniqueList.add(batchEntitlements.PRM_Contact_Id__c+'-'+batchEntitlements.PRM_Entitlement_Id__c);
                            }
                            if(batchEntitlements.PRM_IsRemove_Ind__c){
                                nonProcessedRecords.add(batchEntitlements.PRM_Contact_Id__c+'_'+batchEntitlements.PRM_Entitlement_Id__c);
                            }
                        }
                    }
                    
                    // Updating Contact Entitlement status to pending when entitlement is active else status will remain same as previous.
                    if(finalCEList != null && !finalCEList.IsEmpty()){
                        for(Core_Contact_Entitlement__c ce1 : finalCEList){
                            if(ce1.Core_SELECTed__c && (entitlementNotToInactivate == null || (!entitlementNotToInactivate.IsEmpty() && !entitlementNotToInactivate.contains(ce1.Core_Entitlement_Id__r.Name))))
                            {
                                String key = ce1.Core_Contact_Id__c+'_'+ce1.Core_Entitlement_Id__c;
                                if(!nonProcessedRecords.contains(key)){
                                    PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c();
                                    be1.PRM_Contact_Id__c = ce1.Core_Contact_Id__c;
                                    be1.PRM_Entitlement_Id__c = ce1.Core_Entitlement_Id__c;
                                    be1.PRM_Status_Nm__c = System.label.PRM_Status_New;
                                    be1.PRM_Status_Reason_Txt__c = 'PRM_AcctContRel_TriggerHandlerNew : Removal of Entitlement';//TWC729-8089 : Adding reason text : NJ
                                    be1.PRM_IsRemove_Ind__c = true;
                                if(!beuniqueList.Contains(be1.PRM_Contact_Id__c+'-'+be1.PRM_Entitlement_Id__c)){
                                        beListTemp.add(be1);
                                        beuniqueList.add(be1.PRM_Contact_Id__c+'-'+be1.PRM_Entitlement_Id__c);
                                    }
                                }
                            }
                        }
                    }
                    
                    //partner role on contact need to be removed when it's child ACR is inactivated
                    if(contactRelatedACRList != null && !contactRelatedACRList.IsEmpty()
                    ){
                        for(Contact con : [SELECT id, name, Core_IPA_PartnerRole__c FROM Contact WHERE Id IN :contactRelatedACRList
                        ]){
                            if(con.Core_IPA_PartnerRole__c != ''){
                                con.Core_IPA_PartnerRole__c = '';
                                if(!UpdateContact.contains(con)){
                                    
                                    UpdateContact.add(con);
                                }
                            }
                        }
                    }
                    
                    if(UpdateContact != null && !UpdateContact.IsEmpty()){
                        if(!System.isBatch() && !System.isFuture()){
                            Schema.SObjectType con = Schema.Contact.getSObjectType();
                            System.enqueueJob(new ContactERPMIntegrationStatusHandler(UpdateContact, con));
                        }else if (System.isFuture()){
                            update UpdateContact;
                        }
                    }
                }
                
                //try {
                    if((beListTemp != null && !beListTemp.IsEmpty()) && (!softContactIndicator)
                    ){
                        //Database.UpsertResult[] upsertbeListResult =
                        PRM_DMLUtility.doupsert(beListTemp, 'PRM_Batch_Entitlement__c', 'PRM_AccountContactRel_TriggerHandlerNew.inactivateContactEntitlement');
                    }
                /*} catch(Exception ex){
                    //String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                }*/
                
                //fetching the account contact relationship records which are active for the same contacts
                for(PRM_Account_Contact_Relationship__c acr : inactiveAcrIdList
                ){
                    contset.add(acr.PRM_Contact_Id__c);
                }
                
                //Iterating over contacts to find if there is no active realtionships are there if not then taking them to a set
                for(id con : contactRelatedACRList){
                    if(!contset.contains(con)){
                        conFinalset.add(con);
                    }
                }
                
                if(!conFinalset.isEmpty()){
                    //Fetching the contact subscriptions for the inactive contacts
                    if(!softContactIndicator || test.isRunningTest()){
                        for(PRM_ContactSubscriptionAssociation__c conSubAssoc : [SELECT id, PRM_Contact_Id__c, PRM_Status_Nm__c,PRM_Status_Reason_Txt__c
                                                                                FROM PRM_ContactSubscriptionAssociation__c
                                                                                WHERE PRM_Contact_Id__c IN :conFinalset AND PRM_Status_Nm__c = :System.Label.PRM_Status_Active
                        ]){
                            conSubAssoc.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                            conSubAssoc.PRM_Status_Reason_Txt__c ='Inactivating contact subscription for inactive contact';//TWC729-8089 : Adding reason text : NJ   
                            conSubAssocUpdateList.add(conSubAssoc);
                        }
                    }
                    
                    //When all the ACR's for the contact are inactivated, then if contact is available in any contact group then it should be inactivated there
                    for(PRM_Contact_Group_Contact_Association__c conGroupConAssoc : [SELECT id, PRM_Contact_Id__c, PRM_InActive_Ind__c, PRM_End_Date_Dt__c, PRM_Start_Date_Dt__c
                                                                                    FROM PRM_Contact_Group_Contact_Association__c
                                                                                    WHERE PRM_Contact_Id__c IN :conFinalset AND PRM_InActive_Ind__c = FALSE
                    ]){
                        conGroupConAssoc.PRM_InActive_Ind__c = true;
                        conGroupConAssoc.PRM_End_Date_Dt__c = System.Today(); //End date should be set when flag is inactive in the Contact Group Contact Association
                        conGroupConAssocUpdateList.add(conGroupConAssoc);
                    }
                }
                
                if(softContactIndicator && !softContatid.isEmpty()){
                    for(PRM_ContactSubscriptionAssociation__c conSubAssoc : [SELECT id, PRM_Contact_Id__c, PRM_Status_Nm__c,PRM_Status_Reason_Txt__c
                                                                            FROM PRM_ContactSubscriptionAssociation__c
                                                                            WHERE PRM_Contact_Id__c IN :softContatid AND PRM_Status_Nm__c = :System.Label.PRM_Status_Active
                    ]){
                        conSubAssoc.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                        conSubAssoc.PRM_Status_Reason_Txt__c ='Inactivating contact subscription for inactive contact';//TWC729-8089 : Adding reason text : NJ   
                        conSubAssocUpdateList.add(conSubAssoc);
                    }
                }
            }
            
            if(!conSubAssocUpdateList.isEmpty()){
                //Database.saveResult[] updateConSubsResult =
                PRM_DMLUtility.doupdate(conSubAssocUpdateList, 'PRM_ContactSubscriptionAssociation__c', 'PRM_AccountContactRel_TriggerHandlerNew.inactivateContactEntitlement');
                
            }
            
            if(!conGroupConAssocUpdateList.isEmpty() &&(!softContactIndicator)
            ){
                // Database.saveResult[] updateConGroupConAsResult =
                PRM_DMLUtility.doupdate(conGroupConAssocUpdateList, 'PRM_Contact_Group_Contact_Association__c', 'PRM_AccountContactRel_TriggerHandlerNew.inactivateContactEntitlement');
            }
        }catch(Exception e){ PRM_ErrorUtilityClass.logError(e);
        }
    }
    
    /************************************************************
    Method:    activateContactEntitlement
        Return:    void
        Purpose:   if any ACR become active then corresponding contact entitlement should become active
        
     ************************************************************/
    public static void activateContactEntitlement(List<Id> contactRelatedACRList, List<Id> entitlementWithoutBEList, List<Id> entitlementABList, Map<id, String> mapContIdToSourceAgent, Boolean updateCheck){
        List<PRM_ContactSubscriptionAssociation__c> conSubAssocUpdateList = new List<PRM_ContactSubscriptionAssociation__c>();
        List<PRM_Batch_Entitlement__c> beListTemp = new List<PRM_Batch_Entitlement__c>();
        Map<String, PRM_Batch_Entitlement__c> mapOfContEntToBatchEnt = new Map<String, PRM_Batch_Entitlement__c>();
        String uniqueCombinationOfBEContAndEnt;
        String uniqueCombinationOfCEContAndEnt;
        
        try {
            if(updateCheck || test.isRunningTest()){
                if((!entitlementWithoutBEList.isEmpty() || !entitlementABList.isEmpty()) && !contactRelatedACRList.isEmpty()
                ){
                    for(PRM_Batch_Entitlement__c batchEntitlements : [SELECT Id, Name, PRM_Contact_Id__c, PRM_Entitlement_Id__c, PRM_Status_Nm__c, PRM_IsRemove_Ind__c,PRM_Status_Reason_Txt__c
                                                                        FROM PRM_Batch_Entitlement__c
                                                                        WHERE PRM_Status_Nm__c = 'New'
                                                                        AND PRM_Contact_Id__c IN :contactRelatedACRList AND(PRM_Entitlement_Id__c IN :entitlementWithoutBEList
                                                                        OR PRM_Entitlement_Id__c IN :entitlementABList)
                    ]){
                        batchEntitlements.PRM_Status_Nm__c = 'Success';
                        batchEntitlements.PRM_Status_Reason_Txt__c ='PRM_AcctContRel_TriggerHandlerNew : Entitlement insertion/removal succeeded';//TWC729-8089 : Adding reason text : NJ
                        uniqueCombinationOfBEContAndEnt = string.valueOf(batchEntitlements.PRM_Contact_Id__c) + string.valueOf(batchEntitlements.PRM_Entitlement_Id__c);
                        mapOfContEntToBatchEnt.put(uniqueCombinationOfBEContAndEnt, batchEntitlements);
                    }
                    
                    //System.debug('mapOfContEntToBatchEnt.values()-->' + mapOfContEntToBatchEnt.values());
                    for(Core_Contact_Entitlement__c ce : [SELECT Id, Core_SELECTed__c, Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Type__c, Core_Entitlement_Id__r.Name
                                                        FROM Core_Contact_Entitlement__c
                                                        WHERE Core_SELECTed__c = FALSE
                                                        AND Core_Contact_Id__c IN :contactRelatedACRList 
                                                        AND(Core_Entitlement_Id__c IN :entitlementWithoutBEList OR Core_Entitlement_Id__c IN :entitlementABList)
                                                        AND(Core_Type__c = :System.Label.PRM_Entitlement_Type OR Core_Entitlement_Id__r.Name = :System.Label.PRM_PSG)
                    ]){
                        if(!ce.Core_SELECTed__c){
                            // Updating Contact Entitlement status to pending when entitlement is inactive else status will remain same as previous.
                            uniqueCombinationOfCEContAndEnt = string.valueOf(ce.Core_Contact_Id__c) +  string.valueOf(ce.Core_Entitlement_Id__c);
                            if(mapOfContEntToBatchEnt.containsKey(uniqueCombinationOfCEContAndEnt)
                            ){
                                PRM_Batch_Entitlement__c be = mapOfContEntToBatchEnt.get( uniqueCombinationOfCEContAndEnt);
                                be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                                be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                                be.PRM_Status_Nm__c = System.label.PRM_Status_New;
                                be.PRM_Status_Reason_Txt__c = 'PRM_AcctContRel_TriggerHandlerNew : Activation of Entitlement';//TWC729-8089 : Adding reason text : NJ
                                be.PRM_IsRemove_Ind__c = false;
                            }else {
                                PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                                be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                                be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                                be.PRM_Status_Nm__c = System.label.PRM_Status_New;
                                be.PRM_Status_Reason_Txt__c = 'PRM_AcctContRel_TriggerHandlerNew : Activation of Entitlement';//TWC729-8089 : Adding reason text : NJ
                                be.PRM_IsRemove_Ind__c = false;
                                mapOfContEntToBatchEnt.put(uniqueCombinationOfCEContAndEnt, be);
                            }
                        }
                        //System.debug('beListTemp-->' + beListTemp);
                    }
                }
                
                //try {
                    if(mapOfContEntToBatchEnt != null && !mapOfContEntToBatchEnt.IsEmpty()
                    ){
                        //Database.UpsertResult[] upsertBatchEntResult =
                        PRM_DMLUtility.doupsert(mapOfContEntToBatchEnt.values(), 'PRM_Batch_Entitlement__c', 'PRM_AccountContactRel_TriggerHandlerNew.activateContactEntitlement');
                        
                    }
                /*} catch(Exception ex){
                    String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                }*/
                
                //Activating subscription when ACR got active.
                if(!contactRelatedACRList.isEmpty() && contactRelatedACRList != null
                ){
                    //Fetching the contact subscriptions for the inactive contacts
                    for(PRM_ContactSubscriptionAssociation__c conSubAssoc : [SELECT id, PRM_Contact_Id__c, PRM_Status_Nm__c,PRM_Status_Reason_Txt__c
                                                                            FROM PRM_ContactSubscriptionAssociation__c
                                                                            WHERE PRM_Contact_Id__c IN :contactRelatedACRList AND PRM_Status_Nm__c = :System.Label.PRM_Status_Inactive
                    ]){
                        if(!mapContIdToSourceAgent.containsKey(conSubAssoc.PRM_Contact_Id__c)
                        ){
                            conSubAssoc.PRM_Status_Nm__c = System.Label.PRM_Status_Active;
                            conSubAssoc.PRM_Status_Reason_Txt__c = 'Activated as ACR is activated ';//TWC729-8089 : Adding reason text : NJ
                            conSubAssocUpdateList.add(conSubAssoc);
                            //system.debug('conSubAssoc' + conSubAssoc);
                        }
                    }
                }
            }
            
            if(!conSubAssocUpdateList.isEmpty() && conSubAssocUpdateList != null
            ){
                //Database.saveResult[] updateConSubAssocResult =
                PRM_DMLUtility.doupdate(conSubAssocUpdateList,'PRM_ContactSubscriptionAssociation__c', 'PRM_AccountContactRel_TriggerHandlerNew.inactivateContactEntitlement');
            }
        } catch(exception e){ PRM_ErrorUtilityClass.logError(e);
        }
    }

    //******* */

    /*******************************************************
    Method: getPAPADCandidates
    Returns only ACRs that need the PA/PAD conflict check:
    - Insert: active ACR with a contact and a relationship
    - Update: active ACR whose relationship or contact changed, or that was reactivated
 ******************************************************/
public static List<PRM_Account_Contact_Relationship__c> getPAPADCandidates(
    List<PRM_Account_Contact_Relationship__c> acrList,
    Map<Id, PRM_Account_Contact_Relationship__c> oldMap
) {
    List<PRM_Account_Contact_Relationship__c> candidates = new List<PRM_Account_Contact_Relationship__c>();
    if (acrList == null || acrList.isEmpty()) {
        return candidates;
    }
    for (PRM_Account_Contact_Relationship__c acr : acrList) {
        if (acr.PRM_InActive_Ind__c == true
            || acr.PRM_Contact_Id__c == null
            || acr.PRM_Relationship_Id__c == null) {
            continue;
        }
        PRM_Account_Contact_Relationship__c oldAcr = (oldMap == null) ? null : oldMap.get(acr.Id);
        if (oldAcr == null
            || oldAcr.PRM_InActive_Ind__c == true
            || oldAcr.PRM_Relationship_Id__c != acr.PRM_Relationship_Id__c
            || oldAcr.PRM_Contact_Id__c != acr.PRM_Contact_Id__c) {
            candidates.add(acr);
        }
    }
    return candidates;
}
/******** */

/*******************************************************
    Method: validatePAPADConflict
    Validation to restrict when PA is added when PAD is active and vice versa
    TWC729-9377
 ******************************************************/
public static void validatePAPADConflict(List<PRM_Account_Contact_Relationship__c> acrList) {
    if (acrList == null || acrList.isEmpty()) {
        return;
    }
    String paName  = System.Label.PRM_PartnerAdmin_Rel;   // 'Partner Admin'
    String padName = System.Label.PRM_Admin_Delegate;     // 'Partner Admin Delegate'

    Set<Id> contactIds = new Set<Id>();
    Set<Id> relationshipIds = new Set<Id>();
    Set<Id> currentAcrIds = new Set<Id>();
    for (PRM_Account_Contact_Relationship__c acr : acrList) {
        contactIds.add(acr.PRM_Contact_Id__c);
        relationshipIds.add(acr.PRM_Relationship_Id__c);
        if (acr.Id != null) {
            currentAcrIds.add(acr.Id);
        }
    }

    // Single query: names of the new relationships + contacts already holding active PA/PAD
    Map<Id, String> relationshipMap = new Map<Id, String>();
    Map<Id, Set<String>> contactRelationships = new Map<Id, Set<String>>();
    for (PRM_ContactRelationships__c rel : [
        SELECT Id, Name,
            (SELECT PRM_Contact_Id__c
             FROM Account_Contact_Relationships__r
             WHERE PRM_Contact_Id__c IN :contactIds
             AND PRM_InActive_Ind__c = false
             AND Id NOT IN :currentAcrIds)
        FROM PRM_ContactRelationships__c
        WHERE Id IN :relationshipIds
        OR Name IN (:paName, :padName)
    ]) {
        relationshipMap.put(rel.Id, rel.Name);
        if (rel.Name != paName && rel.Name != padName) {
            continue;
        }
        for (PRM_Account_Contact_Relationship__c existingAcr : rel.Account_Contact_Relationships__r) {
            if (!contactRelationships.containsKey(existingAcr.PRM_Contact_Id__c)) {
                contactRelationships.put(existingAcr.PRM_Contact_Id__c, new Set<String>());
            }
            contactRelationships.get(existingAcr.PRM_Contact_Id__c).add(rel.Name);
        }
    }

    // Also catch PA + PAD for the same contact inside the same batch
    Map<Id, Set<String>> batchRelationships = new Map<Id, Set<String>>();
    for (PRM_Account_Contact_Relationship__c acr : acrList) {
        String newRel = relationshipMap.get(acr.PRM_Relationship_Id__c);
        if (newRel != paName && newRel != padName) {
            continue;
        }
        Set<String> existingRels = new Set<String>();
        if (contactRelationships.containsKey(acr.PRM_Contact_Id__c)) {
            existingRels.addAll(contactRelationships.get(acr.PRM_Contact_Id__c));
        }
        if (batchRelationships.containsKey(acr.PRM_Contact_Id__c)) {
            existingRels.addAll(batchRelationships.get(acr.PRM_Contact_Id__c));
        }

        if (newRel == paName && existingRels.contains(padName)) {
            acr.addError(System.Label.PRM_PAD_VALIDATION);
        } else if (newRel == padName && existingRels.contains(paName)) {
            acr.addError(System.Label.PRM_PA_VALIDATION);
        } else {
            if (!batchRelationships.containsKey(acr.PRM_Contact_Id__c)) {
                batchRelationships.put(acr.PRM_Contact_Id__c, new Set<String>());
            }
            batchRelationships.get(acr.PRM_Contact_Id__c).add(newRel);
        }
    }
}
    /*******************************************************
     	Method:validatePAPADConflict
		Validation to restrict when PA is added when PAD is active and viceversa
		TWC729-9377-Validation needed when someone tries to create PA PCR when PAD is present and vice versa
     ******************************************************/
   /* public static void validatePAPADConflict(List<PRM_Account_Contact_Relationship__c> acrList){
        Set<Id> contactIds = new Set<Id>();        
        for(PRM_Account_Contact_Relationship__c acr : acrList){
            if(acr.PRM_Contact_Id__c != null){
                contactIds.add(acr.PRM_Contact_Id__c);
            }
        }
        
        Map<Id, Set<String>> contactRelationships = new Map<Id, Set<String>>();
        if(!contactIds.isEmpty())
        { for(PRM_Account_Contact_Relationship__c existingAcr : [
            SELECT Id,
            PRM_Contact_Id__c,
            PRM_Relationship_Id__r.Name
            FROM PRM_Account_Contact_Relationship__c
            WHERE PRM_Contact_Id__c IN :contactIds
            AND PRM_InActive_Ind__c = FALSE
        ]){
            if(!contactRelationships.containsKey(existingAcr.PRM_Contact_Id__c)){
                contactRelationships.put(existingAcr.PRM_Contact_Id__c,new Set<String>());
            }
            
            contactRelationships.get(existingAcr.PRM_Contact_Id__c).add(existingAcr.PRM_Relationship_Id__r.Name);
        }
   	   }
        Set<Id> relationshipIds = new Set<Id>();
        for(PRM_Account_Contact_Relationship__c acr : acrList){
            if(acr.PRM_Relationship_Id__c != null){
                relationshipIds.add(acr.PRM_Relationship_Id__c);
            }
        }
        Map<Id,String> relationshipMap = new Map<Id,String>();
        if(!relationshipIds.isEmpty()){
        for(PRM_ContactRelationships__c rel : [ SELECT Id, Name FROM PRM_ContactRelationships__c WHERE Id IN :relationshipIds]){
            relationshipMap.put(rel.Id, rel.Name);
        }
            
        }
        for(PRM_Account_Contact_Relationship__c acr : acrList){
            
            Set<String> existingRels = contactRelationships.containsKey(acr.PRM_Contact_Id__c)? contactRelationships.get(acr.PRM_Contact_Id__c): new Set<String>();
            String newRel = relationshipMap.get(acr.PRM_Relationship_Id__c);
            System.debug('newRel = ' + newRel);
            System.debug('existingRels = ' + existingRels);
            
            if(newRel == System.Label.PRM_PartnerAdmin_Rel && existingRels.contains(System.Label.PRM_Admin_Delegate)){
                acr.addError(System.Label.PRM_PAD_VALIDATION);
            }
            
            else if(newRel == System.Label.PRM_Admin_Delegate && existingRels.contains(System.Label.PRM_PartnerAdmin_Rel)){
                acr.addError(System.Label.PRM_PA_VALIDATION);
            }
        }
    }*/
    /************************************************************
    Method:    updateStartandEndDates
        Return:    void
         ************************************************************/
    public static void updateStartandEndDates(List<PRM_Account_Contact_Relationship__c> acrList, Map<Id, PRM_Account_Contact_Relationship__c> oldMap
    ){
        try {
            for(PRM_Account_Contact_Relationship__c acr : acrList){
                PRM_Account_Contact_Relationship__c acrOld;
                if(oldMap != null && oldMap.size() > 0){
                    acrOld =(PRM_Account_Contact_Relationship__c) oldMap.get(acr.id);
                }
                //For insertion of new ACR records
                //Filtering the records based on below conditions during ACR Update
                if(((oldMap == null) && (acr.PRM_InActive_Ind__c == false) && (acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status)) ||
                    ((oldMap != null && oldMap.size() > 0) && ((acrOld.PRM_InActive_Ind__c != acr.PRM_InActive_Ind__c) && (acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status) ||
                    ((acrOld.PRM_Status_Nm__c != acr.PRM_Status_Nm__c) && (acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status))))
                ){
                    //During Activation or ReActivation of ACR record based on below conditions, set Start Date and End Date accordingly
                    if(acr.PRM_InActive_Ind__c == false){
                        acr.PRM_Start_Date_Dt__c = system.today();
                        if((acr.PRM_End_Date_Dt__c != null) && (acr.PRM_End_Date_Dt__c <= system.today())
                        ){
                            acr.PRM_End_Date_Dt__c = null;
                        }
                    }else if((acr.PRM_InActive_Ind__c == true) && ((acr.PRM_End_Date_Dt__c == null) || (acr.PRM_End_Date_Dt__c > system.today()))
                    ){
                        //Assigning EndDate value to the date when ACR is Deactivated.
                        acr.PRM_End_Date_Dt__c = system.today();
                    }
                }
            }
        } catch(Exception e){ PRM_ErrorUtilityClass.logError(e);
        }
    }
    
    /************************************************************
    Method:    suppressEmail
        Return:    void
         ************************************************************/
    
    public static void suppressEmail(List<PRM_Account_Contact_Relationship__c> acctContRelList, map<Id, PRM_Account_Contact_Relationship__c> oldMap){
        //Map<Id, String> conIdConEmailMap = new Map<Id, String>();
        List<PRM_Email_Handler__c> emailHandlerRecordsToInsert = new List<PRM_Email_Handler__c>();
        try {
            for(PRM_Account_Contact_Relationship__c acr : acctContRelList){
                PRM_Account_Contact_Relationship__c oldAcr = oldMap != null && oldMap.containsKey(acr.Id) ? oldMap.get(acr.Id) : null;
                if((oldAcr == null && acr.PRM_Suppress_Email__c) ||
                    (oldAcr != null && acr.PRM_Suppress_Email__c != oldAcr.PRM_Suppress_Email__c && acr.PRM_Suppress_Email__c)
                ){
                    PRM_Email_Handler__c emailHandler = new PRM_Email_Handler__c();
                    emailHandler.PRM_Contact__c = acr.PRM_Contact_Id__c;
                    emailHandler.PRM_Event__c = acr.PRM_Source_Agent__c != null ? acr.PRM_Source_Agent__c : 'Partner Invite';
                    emailHandler.PRM_Email_Handler_Status__c = 'Requested For Suppression';
                    emailHandler.PRM_Suppress_Email__c = true;
                    emailHandlerRecordsToInsert.add(emailHandler);
                    //acr.PRM_Status_Reason_Txt__c=UserInfo.getName()+' '+' has opted for Suppress Email In this Transaction';
                }
            }
            if(emailHandlerRecordsToInsert.size() > 0 && !emailHandlerRecordsToInsert.isEmpty()
            ){
                //Database.saveResult[] insertEmailHandlerResult =
                PRM_DMLUtility.doinsert(emailHandlerRecordsToInsert, 'PRM_Email_Handler__c', 'PRM_AccountContactRel_TriggerHandlerNew.suppressEmail');
            }
        } catch(Exception e){ PRM_ErrorUtilityClass.logError(e);
        }
    }
    
    /************************************************************
    Method:    duplicateRecordCheck
        Return:    void
        Purpose:   1. Whenever duplicate acr is inserted with same relationship it returns error.
        2. Restrict Partner invites when there is a pending self registration request for a contact.
        
     ************************************************************/
    
    public static void duplicateRecordCheck(List<PRM_Account_Contact_Relationship__c> acctContRelNewList, Map<Id, PRM_Account_Contact_Relationship__c> oldMap
    ){
        List<Id> idslist = new List<Id>();
        List<String> uniqstr = new List<String>();
        Map<String, Id> uniqmap = new Map<String, Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<String> emailIdSet = new Set<String>();
        Set<String> regReqEmailSet = new Set<String>();
        try {
            //check if current user is Partner
            //User CurrentUser = [SELECT id, isportalenabled FROM User WHERE id = :userinfo.getuserid()];
            
            for(PRM_Account_Contact_Relationship__c acr : acctContRelNewList){
                if(oldMap != null && oldMap.keyset().contains(acr.Id)){
                    //system.debug('---oldMap ' + oldMap.keyset() + acr.id);
                    PRM_Account_Contact_Relationship__c acrOldValue = oldMap.get(acr.Id);
                    if(acrOldValue.PRM_InActive_Ind__c != acr.PRM_InActive_Ind__c && acr.PRM_InActive_Ind__c == false
                    ){
                        acr.PRM_Initiated_By__c = CurrentUser.Id;
                        acr.PRM_Activated_Date__c = SYSTEM.NOW();
                        if(CurrentUser.isportalenabled){
                            acr.PRM_Source_Agent__c = 'External Partner Invite';
                            acr.PRM_CampaignId__c = null;
                            acr.Bulk_Data_Upload__c = null;
                        }
                    }
                }else {
                    //system.debug('--- new trigger');
                    if(CurrentUser.isportalenabled){
                        acr.PRM_Source_Agent__c = 'External Partner Invite';
                        acr.PRM_CampaignId__c = null;
                        acr.Bulk_Data_Upload__c = null;
                        acr.PRM_Initiated_By__c = CurrentUser.Id;
                    }
                }
                uniqstr.add(acr.PRM_Unique_Combination__c);
                idslist.add(acr.Id);
                contactIdSet.add(acr.PRM_Contact_Id__c);
            }
            
            if(uniqstr != null && !uniqstr.IsEmpty()){
                for(PRM_Account_Contact_Relationship__c acr : [SELECT Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Relationship_Id__c, PRM_Unique_Combination__c
                                                                FROM PRM_Account_Contact_Relationship__c
                                                                WHERE PRM_Unique_Combination__c IN :uniqstr and PRM_InActive_Ind__c=false
                ]){
                    if((oldMap != null && !idslist.contains(acr.Id)) || (oldMap == null)
                    ){
                        uniqmap.put(acr.PRM_Unique_Combination__c, acr.Id);
                    }
                
                }  
            }
            
            //Added below code as part of TWC729-1189 Agate- Restrict Partner invites when there is a pending self registration request for a contact
            if(!contactIdSet.isEmpty() && contactIdSet.size() > 0){
                for(Contact con : [SELECT Id, Email/*, Core_ERPM_Integration_Status__c*/ FROM Contact WHERE id = :contactIdSet]//ATHR Fix - TWC729-9556 - SJ
                ){
                    emailIdSet.add(con.email);
                }
                System.debug('emailIdSet' + emailIdSet);
            }
            
            if(!emailIdSet.isEmpty() && emailIdSet.size() > 0 && emailIdSet!=null){//NJ soql fix
                for(PRM_Registration_Request__c regReq : [SELECT Id, PRM_Status__c, PRM_Email_ID__c, PRM_Record_Type_Name_rpt_txt__c
                                                          FROM PRM_Registration_Request__c
                                                          WHERE PRM_Email_ID__c IN :emailIdSet AND PRM_Status__c = :System.label.PRM_Status_New AND PRM_Channel_Program_Level_txt__c = :PRM_Intel_Partner_Alliance
                                                          AND PRM_Record_Type_Name_rpt_txt__c = :System.label.RegistrationRequestRecordType
                ]){
                    regReqEmailSet.add(regReq.PRM_Email_ID__c);
                }
            }
            //System.debug('regReqEmailSet-->' + regReqEmailSet);
            //if( !regReqEmailSet.isEmpty() && regReqEmailSet.size() > 0 ){
                for(PRM_Account_Contact_Relationship__c acr : acctContRelNewList){
                    if(uniqmap.containsKey(acr.PRM_Unique_Combination__c) && acr.PRM_InActive_Ind__c==false){
                        acr.addError(System.label.PRM_ACR_Error1);
                    }
                    if(!regReqEmailSet.isEmpty() && regReqEmailSet.size() > 0){
                        for(String s : regReqEmailSet){
                            emailIdSet.contains(s);
                            acr.addError(System.label.PRM_Pending_Registration_Request);
                        }
                    }
                }
            } catch(Exception e){ PRM_ErrorUtilityClass.logError(e);
            }
        }
        public static  map<string,boolean> getBlockedContact(set<string> contIds){
            map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>();
            Id blocedAccContRT = Schema.getGlobalDescribe().get('PRM_SBC_Account_Search_Configuration__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_BlockedAccountContacts').getRecordTypeId();
            list<PRM_SBC_Account_Search_Configuration__c> ipaAdminConfig= new List<PRM_SBC_Account_Search_Configuration__c>();
            if(contIds!=null && contIds.isEmpty()){//NJ Soql fix
                ipaAdminConfig=[select PRM_isActive__c,Account__c,Account__r.id,PRM_Contact__c,PRM_Contact__r.email from PRM_SBC_Account_Search_Configuration__c  
                                where RecordTypeId=:blocedAccContRT and (PRM_Contact__c in:contids) and PRM_isActive__c=true and PRM_Type__c='Contact_Blocked'];
            }
            //system.debug('ipaAdminConfig'+ipaAdminConfig);
            
            iF(ipaAdminConfig.size()>0){
                for(PRM_SBC_Account_Search_Configuration__c sbc:ipaAdminConfig){
                    if(contids.contains(sbc.PRM_Contact__c) && sbc.PRM_isActive__c){
                        mapOfAccWithBlokedStatus.put(sbc.PRM_Contact__c,true);
                    }else{
                        mapOfAccWithBlokedStatus.put(sbc.PRM_Contact__c,false);
                    }
                }
            }
            return mapOfAccWithBlokedStatus;
        }
            
 public static void  validateACMsOnACRs(set<Id> acrAccIds, List<PRM_Account_Contact_Relationship__c> acrNewList,Map<Id, PRM_Account_Contact_Relationship__c> oldMap){
     set<id> activeACMaccids=new set<id>();
     if(acrAccIds!=null && !acrAccIds.isEmpty()){
         for(PRM_AccountChannelMembership__c acm:[SELECT PRM_Account_Id__c FROM PRM_AccountChannelMembership__c
                         where PRM_Status_Nm__c ='Approved' and PRM_Account_Id__c in :acrAccIds])
                         {
                            activeACMaccids.add(acm.PRM_Account_Id__c);
                         }
            }
             
             for(PRM_Account_Contact_Relationship__c acr:acrNewList)   {
                 if(!activeACMaccids.contains(acr.PRM_Account_Id__c) || (activeACMaccids.isEmpty() || activeACMaccids.size()==0))  {
                    acr.addError('ACM should present or active to add ACR');
                 }
            }
            
        }
        @future
        public static void addUsertoGroup(set<string> contIds){
    List<User> Users = new List<User>();
    List<GroupMember> lstInsertGrpMembers = new List<GroupMember>();
            Group allPartnerGroup = [SELECT Id FROM Group WHERE Name = 'PMP - All Partner Users' AND Type = 'Regular' LIMIT 1];
    
    
    if(contIds != null ){
        Users = [SELECT Id, Name, ContactId FROM User WHERE ContactId IN :contIds];
        System.debug('Users found: ' + Users.size());
        System.debug('User details: ' + Users);
    }
    
    if(Users != null && !Users.isEmpty() && allPartnerGroup != null){
        GroupMember gm = new GroupMember();
        gm.GroupId = allPartnerGroup.Id;
        gm.UserOrGroupId = Users[0].Id;
        lstInsertGrpMembers.add(gm);
        
        System.debug('Creating GroupMember: GroupId=' + gm.GroupId + ', UserId=' + gm.UserOrGroupId);
        
        try {
            insert lstInsertGrpMembers;
            System.debug('SUCCESS: GroupMember inserted');
        } catch(Exception e) {
            System.debug('ERROR inserting GroupMember: ' + e.getMessage());
        }
    } else {
        System.debug('Conditions not met:');
        System.debug('Users null/empty: ' + (Users == null || Users.isEmpty()));
        System.debug('Group null: ' + (allPartnerGroup == null));
    }
    
            System.debug('=== addUsertoGroup END ===');}

    /************************************************************
    Method:    blockedDomainValidation
        Return:    void
        Purpose:   TWC729-9166 : India Registration - Validates the contact's email
                   domain against the configured blocked domains. The blocked domain
                   list is resolved based on the related Account Geo (PRC / Non-PRC).
                   If the contact email belongs to a blocked domain, an error message
                   is added to the ACR record so the transaction is stopped.
     ************************************************************/
    public static void blockedDomainValidation(List<PRM_Account_Contact_Relationship__c> acrList){
        try{
            Set<Id> contactIds = new Set<Id>();
            for(PRM_Account_Contact_Relationship__c acr : acrList){
                if(acr.PRM_Contact_Id__c != null && acr.PRM_InActive_Ind__c == false){
                    contactIds.add(acr.PRM_Contact_Id__c);
                }
            }
            //Map each contact to the ACR record(s) that reference it so the error
            //can be added back to the correct ACR record(s)
            Map<Id, List<PRM_Account_Contact_Relationship__c>> contactIdToAcrs = new Map<Id, List<PRM_Account_Contact_Relationship__c>>();
            for(PRM_Account_Contact_Relationship__c acr : acrList){
                if(acr.PRM_Contact_Id__c != null){
                    if(!contactIdToAcrs.containsKey(acr.PRM_Contact_Id__c)){
                        contactIdToAcrs.put(acr.PRM_Contact_Id__c, new List<PRM_Account_Contact_Relationship__c>());
                    }
                    contactIdToAcrs.get(acr.PRM_Contact_Id__c).add(acr);
                }
            }
            //Fetch contact email addresses
            Map<Id, String> contactIdToEmail = new Map<Id, String>();
            //Fetch related Account Geo to determine the applicable blocked domain list
            //and the Account billing country to drive the country-based domain bypass
            Map<Id, String> conIdToAccGeo = new Map<Id, String>();
            Map<Id, String> conIdToAccCountry = new Map<Id, String>();
            for(Contact con : [SELECT Id, Email,AccountId,Account.Core_Geo__c,Account.BillingCountry FROM Contact WHERE Id IN :contactIds AND Email != null]){
                contactIdToEmail.put(con.Id, con.Email);
                conIdToAccGeo.put(con.Id, con.Account.Core_Geo__c);
                conIdToAccCountry.put(con.Id, con.Account.BillingCountry);
            }

            //TWC729-9166: India Registration
            // Retrieve country-level domain bypass configuration from Custom Metadata
            Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('Country_Level_Domain_Bypass');
            Map<String, Map<String, Object>> bypassRecords = customMetadata.getAll();

            //Build blocked domain sets from custom labels (lower-cased for case-insensitive comparison)
            Set<String> prcBlockedDomains = new Set<String>();
            for(String d : System.Label.Blocked_Domains_Prc1.split(';')){ prcBlockedDomains.add(d.trim().toLowerCase()); }
            for(String d : System.Label.Blocked_Domains_Prc2.split(';')){ prcBlockedDomains.add(d.trim().toLowerCase()); }

            Set<String> nonPrcBlockedDomains = new Set<String>();
            for(String d : System.Label.Blocked_Domains_Non_Prc1.split(';')){ nonPrcBlockedDomains.add(d.trim().toLowerCase()); }
            for(String d : System.Label.Blocked_Domains_Non_Prc2.split(';')){ nonPrcBlockedDomains.add(d.trim().toLowerCase()); }
            for(String d : System.Label.Blocked_Domains_Non_Prc3.split(';')){ nonPrcBlockedDomains.add(d.trim().toLowerCase()); }

            for(id con: contactIdToEmail.keySet()){
                if(String.isBlank(contactIdToEmail.get(con)) || !contactIdToEmail.get(con).contains('@')){
                    continue;
                }
                String emailDomain = contactIdToEmail.get(con).substringAfter('@').trim().toLowerCase();
                if(emailDomain != null && emailDomain != ''){
                    if(PRM_RegistrationRequestUtility.shouldBypassBlockedDomainCheck(conIdToAccCountry.get(con), emailDomain, bypassRecords)){
                        continue;
                    }
                    Boolean isBlocked = (conIdToAccGeo.get(con) == 'PRC') ? prcBlockedDomains.contains(emailDomain) : nonPrcBlockedDomains.contains(emailDomain);
                    if(isBlocked && contactIdToAcrs.containsKey(con)){
                        for(PRM_Account_Contact_Relationship__c acr : contactIdToAcrs.get(con)){
                            acr.addError(System.Label.PRM_BlockedDomainError);
                        }
                    }
                }
            }
        } catch(Exception e){
            PRM_ErrorUtilityClass.logError(e);
        }
    }

    }