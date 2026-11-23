/***************************************************************************************************************************************************
Apex Class Name  : PRM_AcctContRelUtility
Version       : 1.0
Created Date  : NOV 2018
Function      : Create AGS outbound messages with roles once the account and contact relationship object is inserted

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Thenammai           21-Nov-2018
* Anupam Agarwal      06-Dec-2018                   Added the new methods mandatoryRelationshipCheck(List, List, Map), duplicateRecordCheck(List)
and mandatoryDeletionCheck(List) for checking the Relationship Criterias for the Account
Contact Relationship records
* Teja Munagala      17-Dec-2018          Added a new method for DuplicateACR(List) //
* Utkarsh            09-AUG-2019          Added a new method for if any inactive ACR updates to active then corresponding contact entitlement should become active //
***************************************************************************************************************************************************/

public without sharing class PRM_AcctContRelUtility {
    public static  boolean firstRun = true;
    public static  boolean firstRunAfter = true;
    public static  boolean firstRunAfterUpdate = true;
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_AGS_SCOPE = 'IntegrationInboundMessageAGS';
    public static final String LOG_ENTRY_ERPM_SCOPE = 'IntegrationInboundMessageERPM';
    public static final String LOG_ENTRY_BOXBACCOUNT_SCOPE = 'IntegrationInboundMessageBOXBACCOUNT';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Outbound_Message__c';    
    public static final String WORKS_FOR_RELATIONSHIP = 'Works for';
    public static boolean updateCheck = true;
    
    /**
*  @description      :  Create AGS outbound messages with roles once the account and contact relationship inserted
*  @name             : generateAgsOutBoundMsg
*  @param            : List<PRM_Account_Contact_Relationship__c>
*  @throws exception : if the AGS message is not generated//
**/
    /*  public static void generateAgsOutBoundMsg(List<PRM_Account_Contact_Relationship__c> acctContRelList)
{
Id contactId;
String tags;

try
{
List<PRM_AccountChannelMembership__c> chnlMemLvlLst=new List<PRM_AccountChannelMembership__c>();

List<PRM_EntitlementDetailMap__c> entDtlMapLst=new List<PRM_EntitlementDetailMap__c>();

List<Contact> contLst=new List<Contact>();

List<Account> acctPartnerTypeLst=new List<Account>();

List<PRM_PartnerType__c> partnerTypeLst=new List<PRM_PartnerType__c>();

List<string> partnerTypes=new List<String>();

List<string> acctPartTypes=new List<String>();

Map<id,Core_Integration_Outbound_Message__c> mapMsg = new Map<id,Core_Integration_Outbound_Message__c>();

List<String> contIdLst = new List<String>();

List<String> acctIdLst=new List<String>();

List<String> acctChnlMemIdLst=new List<String>();

List<String> chnlProgNameLst=new List<String>();

List<String> contRelIdLst=new List<String>();

List<String> contactStr=new List<String>();
string[] partnerType;

Integer i=0;
if(acctContRelList != null && !acctContRelList.isEmpty()){
for(PRM_Account_Contact_Relationship__c contAcctRel: acctContRelList)
{    
contIdLst.Add(contAcctRel.PRM_Contact_Id__c);

acctIdLst.Add(contAcctRel.PRM_Account_Id__c);

acctChnlMemIdLst.Add(contAcctRel.PRM_Account_Channel_Membership_Id__c);

chnlProgNameLst.Add(contAcctRel.Channel_Program__c);

contRelIdLst.Add(contAcctRel.PRM_Relationship_Id__c);
}
}

contLst=[select Core_Enterprise_Id__c,Core_Login_Id__c,Email from Contact where Id IN :contIdLst];

acctPartnerTypeLst=[select Core_Account_Type__c from Account where Id IN :acctIdLst AND Core_Account_Type__c != null];

if(acctPartnerTypeLst != null && !acctPartnerTypeLst.isEmpty()){
for(Account a : acctPartnerTypeLst)
{
if(!String.isBlank(a.Core_Account_Type__c)){
partnerType = a.Core_Account_Type__c.split(';');
}
for(String pType : partnerType){
partnerTypes.Add(pType);
}
}
}

if(partnerTypes != null && !partnerTypes.isEmpty() && acctPartnerTypeLst.size() > 0)
{
partnerTypeLst=[select id from PRM_PartnerType__c where name IN :partnerTypes];

if(partnerTypeLst != null && !partnerTypeLst.isEmpty()){
for(PRM_PartnerType__c partnerTypeLcl : partnerTypeLst)
{
acctPartTypes.Add(partnerTypeLcl.id);
}
}
}

chnlMemLvlLst = [Select PRM_Channel_Program_Level_Id__c from PRM_AccountChannelMembership__c where Id IN :acctChnlMemIdLst];

List<String> chnlMemLvlStr=new List<String>();

if(chnlMemLvlLst != null && !chnlMemLvlLst.isEmpty()){
for(PRM_AccountChannelMembership__c acm : chnlMemLvlLst)
{
chnlMemLvlStr.add(acm.PRM_Channel_Program_Level_Id__c);
}
}

if(chnlMemLvlStr != null && !chnlMemLvlStr.isEmpty() && acctPartTypes.size() > 0)
{
entDtlMapLst= [select PRM_Entitlement_Detail__r.Core_AGS_Role_Id__r.Core_Technical_Name__c from PRM_EntitlementDetailMap__c where 
PRM_Channel_Program__r.Name IN :chnlProgNameLst and PRM_Channel_Program_Level_Id__c IN :chnlMemLvlStr and 
PRM_Contact_Relationship__c IN :contRelIdLst and PRM_PartnerType__c IN :acctPartTypes];      
}  
else
{
entDtlMapLst= [select PRM_Entitlement_Detail__r.Core_AGS_Role_Id__r.Core_Technical_Name__c from PRM_EntitlementDetailMap__c where 
PRM_Channel_Program__r.Name IN :chnlProgNameLst and PRM_Channel_Program_Level_Id__c IN :chnlMemLvlStr and 
PRM_Contact_Relationship__c IN :contRelIdLst and  PRM_PartnerType__c = null];
}

AGS_Outbound_Msg_Wrapper agsOMW;

List<String> entDtlMapLstStr=new List<String>();

//Adding AGS roles
if(entDtlMapLst != null && !entDtlMapLst.isEmpty()){
for(PRM_EntitlementDetailMap__c entDtlmap : entDtlMapLst)
{
entDtlMapLstStr.add(entDtlmap.PRM_Entitlement_Detail__r.Core_AGS_Role_Id__r.Core_Technical_Name__c);
}
}

List<Core_Integration_Outbound_Message__c> outboundMsgLst=new List<Core_Integration_Outbound_Message__c>();

List<Contact_Message__c> contactMsg= new List<Contact_Message__c>();

if(contLst != null && !contLst.isEmpty()){
for(Contact c:contLst)
{               
tags='';

string agsRole;

agsOMW = new AGS_Outbound_Msg_Wrapper(c.Core_Enterprise_Id__c, Label.Core_Contact_Ent_AGS_Justification);              

if(entDtlMapLstStr.size() > 0 && i <= entDtlMapLstStr.size())
{
agsRole=entDtlMapLstStr[i];
i++;   
}

agsOMW.roles.Add(agsRole);

String strJson=JSON.serialize(agsOMW);

Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();

// Build up tags for log entry        
if (!String.isBlank(c.Core_Enterprise_Id__c)){
tags += addTag(c.Core_Enterprise_Id__c);
}
if (!String.isBlank(c.Core_Login_Id__c)){
tags += addTag(c.Core_Login_Id__c); 
}                       
if (!String.isBlank(c.Email)){
tags += addTag(c.Email);
}
if (!String.isBlank(c.Id)){
tags += addTag(c.Id);
}

//Creating AGS outbound message
if(strJson!=null)
{
outboundMsg.Core_MessageType__c = 'AGS Contact Entitlement';

outboundMsg.Core_Payload__c = '<![CDATA[' +  strJson + ']]>';

outboundMsg.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);

outboundMsgLst.add(outboundMsg);

contactId=c.Id;

mapMsg.put(contactId, outBoundMsg);

if(mapMsg!= null && !mapMsg.isEmpty()){
for(Id cid : mapMsg.keySet()){
contactMsg.add(new Contact_Message__c(Contact__c = cid, Outbound_Message__c = mapMsg.get(cid).id)
);
}
}
}

}
}

//Inserting into Outbound message list and Contact mesage
if(outboundMsgLst!= null && outboundMsgLst.size()>0 && !outboundMsgLst.isEmpty())
{
insert outboundMsgLst;
insert contactMsg;
}

}
catch(Exception ex)
{
String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
System.debug('##### Exception: ' + exceptionMessage);    
Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_AGS_SCOPE, LOG_ENTRY_ERROR,
'Error generating AGS OBM', '', contactId, LOG_ENTRY_OBJECT, tags, ex);
}

} */
    
    //AGS Wrapper to add enterprise id,roles and justification
    /* private class AGS_Outbound_Msg_Wrapper {
String enterpriseId;
String justification;
List<String> roles { get; set; }

public AGS_Outbound_Msg_Wrapper(String entId, String just) {
justification = just;
enterpriseId=entId;
roles = new List<String>();
}
} */
    
    // Helper method to assist with building our Tags in Log Entries
    private static String addTag(String tagToAdd) {
        return String.isBlank(tagToAdd) ? '' : (tagToAdd + ';');
            } 
    
    //Start of Changes by Anupam Agarwal on 06-Dec-2018 for mandatory relationship check
    
    public static void mandatoryRelationshipCheck(List<PRM_Account_Contact_Relationship__c> acctContRelNewList, List<PRM_Account_Contact_Relationship__c> acctContRelOldList, Map<Id, PRM_Account_Contact_Relationship__c> acctContRelOldMap)
    {   
        Set<String> accountIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Set<String> activecontactIds = new Set<String>();
        Set<ID> activeWorksForACRId = new Set<ID>();
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        for(PRM_Account_Contact_Relationship__c acr:acctContRelNewList){
            PRM_Account_Contact_Relationship__c acrOldValue = acctContRelOldMap.get(acr.Id);
            if(acrOldValue.PRM_InActive_Ind__c!=true && (acr.PRM_Relationship_Id__c != acrOldValue.PRM_Relationship_Id__c || acr.PRM_Contact_Id__c != acrOldValue.PRM_Contact_Id__c || acrOldValue.PRM_InActive_Ind__c!= acr.PRM_InActive_Ind__c)){
                acrList.add(acr);
                accountIds.add(acr.PRM_Account_Id__c);
                activecontactIds.add(acr.PRM_Contact_Id__c);
            }
        }
        if(acrList.size()>0){
            List<PRM_Account_Contact_Relationship__c> acrRecordList = [Select Id, PRM_Account_Id__c, PRM_Contact_Id__c,PRM_InActive_Ind__c, PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c, PRM_Relationship_Id__r.Name, PRM_Relationship_Id__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accountIds and PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c = true AND PRM_InActive_Ind__c=false];
            Set<String> idSet= new Set<String>();
            for(PRM_Account_Contact_Relationship__c acr : acrRecordList){
                idSet.add(acr.id);
            }
            for(PRM_Account_Contact_Relationship__c acrRecord : acctContRelNewList){
                System.debug('List Size  '+acrRecordList.size());
                if(acrRecordList.size()<=1 && idSet.contains(acrRecord.id)){acrRecord.addError(System.label.PRM_ACR_Error5);
                                                                           }
            }
        }
        //start changes by Teja Munagala  as per US389658
        Set<ID>contactIdsForWorksFor = new Set<ID>();
        //Map<PRM_Account_Contact_Relationship__c,ID> worksForACRContactMap = new Map<PRM_Account_Contact_Relationship__c,Id>();
        //Iterating over inactive acrlist and getting worksfor ids, contact ids specific to works for Relationship
        for(PRM_Account_Contact_Relationship__c accConRel : [Select id,PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c,PRM_InActive_Ind__c,PRM_Contact_Id__c  from PRM_Account_Contact_Relationship__c where id in : acrList])
        {
            System.debug('accid'+accConRel+'accConRel.PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c-------------->'+accConRel.PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c+'PRM_InActive_Ind__c-->'+ accConRel.PRM_InActive_Ind__c);
            if(accConRel.PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c == true && accConRel.PRM_InActive_Ind__c==false)
            {
                activeWorksForACRId.add(accConRel.id);
                contactIdsForWorksFor.add(accConRel.PRM_Contact_Id__c);
                // worksForACRContactMap.put(accConRel,accConRel.PRM_Contact_Id__c);
            }
            
        }
        //iterating over acr records which have primary contact relationship based on the contact ids accquired      
        if(activeWorksForACRId.size()>0){
            For(PRM_Account_Contact_Relationship__c acrActiveRecord : [Select Id, PRM_Account_Id__c, PRM_Contact_Id__c,PRM_InActive_Ind__c, PRM_Relationship_Id__c, 
                                                                       PRM_Relationship_Id__r.name from PRM_Account_Contact_Relationship__c where PRM_InActive_Ind__c=false and 
                                                                       PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c = true  AND PRM_Contact_Id__c IN :contactIdsForWorksFor]){
                                                                           contactIds.add(acrActiveRecord.PRM_Contact_Id__c);
                                                                           system.debug('acrActiveRecord'+acrActiveRecord);
                                                                           system.debug('acrActiveRecord.PRM_Relationship_Id__r.name'+acrActiveRecord.PRM_Relationship_Id__r.name);
                                                                           
                                                                       }
        }
        /*iterating over acr records and validating if its works for relationship record which has a primary contact relationship if it has then throwing an error */
        if(contactIds.size()>0){
            for(PRM_Account_Contact_Relationship__c acrRecordActiveRel : acctContRelNewList){
                system.debug('Inside loop');
                if((contactIds.contains(acrRecordActiveRel.PRM_Contact_Id__c)) && activeWorksForACRId.contains(acrRecordActiveRel.id)){acrRecordActiveRel.addError(System.label.PRM_ACR_Error4);  
                                                                                                                                      }
            }
            
        }
        if(acrList.size()>0){
            List<PRM_Account_Contact_Relationship__c> acrRecordListWorksFor = [Select Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_InActive_Ind__c, PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c, PRM_Relationship_Id__r.Name, PRM_Relationship_Id__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accountIds and PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c = true AND PRM_InActive_Ind__c=false];
            Set<String> idSet= new Set<String>();
            if(!acrRecordListWorksFor.isEmpty()){
                for(PRM_Account_Contact_Relationship__c acrWorksFor : acrRecordListWorksFor){
                    idSet.add(acrWorksFor.id);
                }
                for(PRM_Account_Contact_Relationship__c acrRecordWorksFor : acctContRelNewList){
                    System.debug('acctContRelNewList Size  '+acctContRelNewList.size());
                    if(acrRecordListWorksFor.size()<=1 && idSet.contains(acrRecordWorksFor.id)){acrRecordWorksFor.addError(System.label.PRM_ACR_Error4);
                                                                                               }
                }
            }
        }
        //Ended by teja
    }
    public static void duplicateRecordCheck(List<PRM_Account_Contact_Relationship__c> acctContRelNewList)
    {   
        Set<String> contactIds = new Set<String>();
        Set<String> accountIds = new Set<String>();
        Set<String> relationshipId = new Set<String>();
        if(acctContRelNewList != null){
            for(PRM_Account_Contact_Relationship__c acr:acctContRelNewList){
                System.debug('came here1');
                accountIds.add(acr.PRM_Account_Id__c);
                contactIds.add(acr.PRM_Contact_Id__c);    
            }
        }
        
        if(accountIds != null && contactIds != null){
            for(Contact contact : [Select id, name, AccountId, (select id,PRM_Contact_Id__c, PRM_Account_Id__c, PRM_Relationship_Id__c from  Account_Contact_Relationships__r where PRM_Contact_Id__c in :contactIds and PRM_Account_Id__c in :accountIds) from Contact where id in :contactIds and AccountId in :accountIds]){
                System.debug('came here3');
                for(PRM_Account_Contact_Relationship__c acrRecord:contact.Account_Contact_Relationships__r){
                    System.debug('came here4');
                    relationshipId.add(acrRecord.PRM_Relationship_Id__c);
                }
            }
        }
        System.debug('relationshipId-->'+relationshipId);
        List<PRM_Account_Contact_Relationship__c> acrList = [Select Id ,PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Relationship_Id__c from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c in :contactIds and PRM_Relationship_Id__c in :relationshipId];
        if(acrList != null && acrList.size()>0 && acctContRelNewList != null){
            for(PRM_Account_Contact_Relationship__c acr : acctContRelNewList){
                System.debug('came here5');
                if(RelationshipId.contains(acr.PRM_Relationship_Id__c) ){
                    acr.addError (System.label.PRM_ACR_Error1);
                } 
            } 
        } 
    } 
    
    public static void mandatoryDeletionCheck(List<PRM_Account_Contact_Relationship__c> acctContRelOldList)
    {
        Set<String> accountIds = new Set<String>();
        Set<String> channelPrograms = new Set<String>();
        Set<String> idSet= new Set<String>();
        Set<String> acrIdSet= new Set<String>();
        for(PRM_Account_Contact_Relationship__c acr:acctContRelOldList){
            accountIds.add(acr.PRM_Account_Id__c);
        }
        system.debug('inside mehotd 12'+accountIds);
        system.debug('inside mehotd 12'+channelPrograms);
        List<PRM_Account_Contact_Relationship__c> acrRecordList = [Select Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c, PRM_Relationship_Id__r.Name, PRM_Relationship_Id__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accountIds and PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c = true  and PRM_InActive_Ind__c=false];
        for(PRM_Account_Contact_Relationship__c acr : acrRecordList){idSet.add(acr.id);
                                                                    }   
        System.debug('List Size sss  '+acrRecordList.size());
        for(PRM_Account_Contact_Relationship__c acrRecord : acctContRelOldList){
            System.debug('List Size zz '+acrRecordList.size());
            if(acrRecordList.size()<=1 && idSet.contains(acrRecord.id)){
                acrRecord.addError(System.label.PRM_ACR_Error3);
            }
        }
        List<PRM_Account_Contact_Relationship__c> defaultacrRecordList = [Select Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c, PRM_Relationship_Id__r.Name, PRM_Relationship_Id__c from PRM_Account_Contact_Relationship__c where PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c = true  ];       
        Map<string,PRM_Account_Contact_Relationship__c > idMap = new Map<string,PRM_Account_Contact_Relationship__c >();
        for(PRM_Account_Contact_Relationship__c acr : defaultacrRecordList){idMap.put(acr.id, acr);
                                                                           }   
        for (PRM_Account_Contact_Relationship__c acr : acctContRelOldList) {
            if(idMap.keySet().contains(acr.id) && idMap.get(acr.id).PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c == true){acr.addError(System.label.PRM_ACR_Error2);
                                                                                                                                   }
        } 
    }
    //End of Changes by Anupam Agarwal on 06-Dec-2018 for mandatory relationship check
    
    //Start of Changes by Teja Munagala on 17-Dec-2018 for Duplicate relationship check
    
    public static void duplicateACRCheck(List<PRM_Account_Contact_Relationship__c> acctContRelNewList)
    {
        List<String> uniqstr = new List<String>();
        Map<String,Id> uniqmap = new Map<String,Id>();
        for(PRM_Account_Contact_Relationship__c acr: acctContRelNewList){
            uniqstr.add(acr.PRM_Unique_Combination__c);
        }
        List<PRM_Account_Contact_Relationship__c> acrList = [SELECT Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Relationship_Id__c, PRM_Unique_Combination__c FROM PRM_Account_Contact_Relationship__c where PRM_Unique_Combination__c IN: uniqstr];
        for(PRM_Account_Contact_Relationship__c acr: acrList){
            uniqmap.put(acr.PRM_Unique_Combination__c, acr.Id);
        }
        for(PRM_Account_Contact_Relationship__c acr: acctContRelNewList){
            System.debug('From Tejas dup method');
            if(uniqmap.containsKey(acr.PRM_Unique_Combination__c)){
                acr.addError(System.label.PRM_ACR_Error1);
            }            
        } 
        
    }
    
    public static void duplicateUpdateACRCheck(List<PRM_Account_Contact_Relationship__c> acctContRelNewList)
    {
        List<String> uniqstr = new List<String>();
        List<Id> idslist = new List<Id>();
        Map<String,Id> uniqmap = new Map<String,Id>();
        for(PRM_Account_Contact_Relationship__c acr: acctContRelNewList){
            uniqstr.add(acr.PRM_Unique_Combination__c);
            idslist.add(acr.Id);
        }
        List<PRM_Account_Contact_Relationship__c> acrList = [SELECT Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Relationship_Id__c, PRM_Unique_Combination__c FROM PRM_Account_Contact_Relationship__c where PRM_Unique_Combination__c IN: uniqstr and Id Not IN: idslist];
        for(PRM_Account_Contact_Relationship__c acr: acrList){uniqmap.put(acr.PRM_Unique_Combination__c, acr.Id);
                                                             }
        for(PRM_Account_Contact_Relationship__c acr: acctContRelNewList){
            System.debug('From Tejas update dup method');
            if(uniqmap.containsKey(acr.PRM_Unique_Combination__c)){acr.addError(System.label.PRM_ACR_Error1);
                                                                  }            
        }  
    } 
    //End of Changes by Teja Munagala on 18-Dec-2018 for Duplicate relationship check
    /*US389505 - Start - As part of the story if any ACR become inactive then delete contact entitlement related with that parent contact which parent for the inactive ACR*/
    public static void inactivateContactEntitlement(List<PRM_Account_Contact_Relationship__c> acctContRelList,Map<Id,PRM_Account_Contact_Relationship__c> acrOldMap)
    {
        List<Id> contactRelatedACRList = new List<Id>();
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> ceListPrimary = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> updateCeList = new List<Core_Contact_Entitlement__c>();
        List<PRM_Account_Contact_Relationship__c> acrListWorksfor = new List<PRM_Account_Contact_Relationship__c>();
        List<Id> acrList = new List<Id>();
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        List<PRM_VXEnttlmntMatrix__c> emListWorksfor = new List<PRM_VXEnttlmntMatrix__c>();
        List<Id> entitlementList = new List<Id>();
        List<Id> worksForEntitlement = new List<Id>();
        List<PRM_ContactSubscriptionAssociation__c> conSubAssocUpdateList = new List<PRM_ContactSubscriptionAssociation__c>();
        List<PRM_Account_Contact_Relationship__c> inactiveAcrList = new List<PRM_Account_Contact_Relationship__c>();
        set<id> contset = new set<id>();
        set<id> conFinalset = new set<id>();
        PRM_Account_Contact_Relationship__c acrOld ;
        Boolean updateCheck = false;
        //Fetching relationshipId from ACR
        if(acctContRelList != null && !acctContRelList.IsEmpty()){
            for(PRM_Account_Contact_Relationship__c acr :acctContRelList){
                if(acrOldMap!=null && acrOldMap.size()>0){
                    acrOld = (PRM_Account_Contact_Relationship__c) acrOldMap.get(acr.id) ;
                    system.debug('acrOld-->'+acrOld);
                    if((acrOld.PRM_InActive_Ind__c == false && acr.PRM_InActive_Ind__c == true) && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status){
                        system.debug('@@@@@inside ACR trigger to update Entitlement');
                        acrList.add(acr.PRM_Relationship_Id__c);
                        contactRelatedACRList.add(acr.PRM_Contact_Id__c);
                        inactiveAcrList.add(acr);
                        updateCheck = true;
                    }
                }
            }
        }
        System.debug('updateCheck-->'+updateCheck);
        if(updateCheck){
            //Fetching ACR records which has same contact with 'Works For' relation.
            acrListWorksfor = [Select Id, Name,PRM_Relationship_Id__c,PRM_Contact_Id__c,PRM_Relationship_Id__r.Name From PRM_Account_Contact_Relationship__c Where PRM_InActive_Ind__c = false AND PRM_Contact_Id__c IN :contactRelatedACRList AND PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c = true AND PRM_Relationship_Id__c NOT IN:acrList];
            System.debug('acrListWorksfor-->'+acrListWorksfor);
            
            if(acrListWorksfor != null && !acrListWorksfor.isEmpty()){
                //Fetching Entitlement Matrix record based on ACR relation.
                if(acrList !=null && !acrList.IsEmpty()){
                    emList = [Select Id, Name,PRM_Entitlement_Id__c,PRM_Contact_Relationship_Id__c,PRM_IsActive_Ind__c From PRM_VXEnttlmntMatrix__c Where PRM_Contact_Relationship_Id__c =:acrList AND PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_IsActive_Ind__c = true];
                }
                //Fetching worksfor relationship Entitlement Matrix record .
                emListWorksfor = [Select Id, Name,PRM_Entitlement_Id__c,PRM_Contact_Relationship_Id__c,PRM_IsActive_Ind__c From PRM_VXEnttlmntMatrix__c Where PRM_Contact_Relationship_Id__R.PRM_Default_Relationship_Ind__c = true AND PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_IsActive_Ind__c =true];
                
                //Fetching Entitlement id.
                if(emListWorksfor != null && !emListWorksfor.IsEmpty()){
                    for(PRM_VXEnttlmntMatrix__c entitlementWork :emListWorksfor){
                        worksForEntitlement.add(entitlementWork.PRM_Entitlement_Id__c);
                    }
                }
                //Comparing entitlements and removing entitlements which has both relationship 'primary relationship' and 'works for'.
                if(emList != null && !emList.IsEmpty()){
                    for(PRM_VXEnttlmntMatrix__c entitlement :emList){
                        if(!worksForEntitlement.contains(entitlement.PRM_Entitlement_Id__c)){
                            entitlementList.add(entitlement.PRM_Entitlement_Id__c);
                        }
                    }
                }
                //Fetching Contact Entitlement id based on parent contact of ACR and entitlements.
                if(entitlementList != null && !entitlementList.IsEmpty()){
                    ceList = [Select Id , Name ,Core_Selected__c,Core_Status__c,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Type__c From Core_Contact_Entitlement__c Where Core_Entitlement_Id__c IN :entitlementList AND Core_Contact_Id__c IN :contactRelatedACRList AND Core_Type__c =:System.Label.PRM_Entitlement_Type];
                }
                //Updating Contact Entitlement fields.
                if(ceList != null && !ceList.IsEmpty()){
                    for(Core_Contact_Entitlement__c ce :ceList){
                        if(ce.Core_Selected__c) { // Updating Contact Entitlement status to pending when entitlement is active else status will remain same as previous.
                            ce.Core_Selected__c = false;
                            if(!test.isrunningTest()) { // to avoid existing SOQL 101 exception in entitlement trigger
                                ce.Core_Data_Loaded__c = true;
                                ce.Core_Status__c = System.Label.PRM_Status_Pending;}
                            updateCeList.add(ce);
                        }
                    }
                    
                }
            }
            else{
                List<Id> existingEntId = new List<Id>();
                Set<Id> allEntId = new Set<Id>();
                Set<Id> finalExistingEntId = new Set<Id>();
                List<Core_Contact_Entitlement__c> finalCEList = new List<Core_Contact_Entitlement__c>();
                //Fetching all CE records both relation get deactivated.
                for(Core_Contact_Entitlement__c existingCE : [Select Id , Name ,Core_Selected__c,Core_Status__c,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Type__c From Core_Contact_Entitlement__c Where Core_Contact_Id__c IN :contactRelatedACRList AND Core_Type__c =:System.Label.PRM_Entitlement_Type]){
                    existingEntId.add(existingCE.Core_Entitlement_Id__c);
                }
                System.debug('existingEntId-->'+existingEntId);
                //Fetching all entitlement matrix records from are ORG.
                for(PRM_VXEnttlmntMatrix__c entMatrix : [Select Id, Name,PRM_Entitlement_Id__c,PRM_Contact_Relationship_Id__c,PRM_IsActive_Ind__c,PRM_Approval_Type_Nm__c From PRM_VXEnttlmntMatrix__c Where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_IsActive_Ind__c =true]){
                    allEntId.add(entMatrix.PRM_Entitlement_Id__c);
                }
                //Comparing existing entitlement with set of all the entitlement.
                if((existingEntId != null && !existingEntId.IsEmpty()) && (allEntId != null && !allEntId.IsEmpty())){
                    for(Id existingEntitlement :existingEntId){
                        if(allEntId.contains(existingEntitlement)){
                            finalExistingEntId.add(existingEntitlement);
                        }
                    }
                }
                
                finalCEList = [Select Id , Name ,Core_Selected__c,Core_Status__c,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Type__c From Core_Contact_Entitlement__c Where Core_Contact_Id__c IN :contactRelatedACRList AND Core_Entitlement_Id__c IN :finalExistingEntId AND Core_Type__c =:System.Label.PRM_Entitlement_Type];
                
                if(finalCEList != null && !finalCEList.IsEmpty()){
                    for(Core_Contact_Entitlement__c ce1 :finalCEList){
                        if(ce1.Core_Selected__c) { // Updating Contact Entitlement status to pending when entitlement is active else status will remain same as previous.
                            ce1.Core_Selected__c = false;
                            if(!test.isRunningTest()){  // to avoid existing SOQL 101 exception in entitlement trigger
                                ce1.Core_Data_Loaded__c = true;
                                ce1.Core_Status__c = System.Label.PRM_Status_Pending;}
                            updateCeList.add(ce1);
                            
                        }
                    }
                }
            }
            System.debug('updateCEList before update-->'+updateCEList);
            if(updateCeList != null && !updateCeList.IsEmpty()){
                update updateCeList;
            }
            System.debug('updateCeList-->'+updateCeList);
            /*Finish - US389505*/
            //start changes by Teja Munagala  as per US389658                           
            //fetching the account contact relationship records which are active for the same contacts
            for(PRM_Account_Contact_Relationship__c acr :[select id,PRM_Contact_Id__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c IN: contactRelatedACRList AND id NOT IN :inactiveAcrList AND PRM_InActive_Ind__c = false ])
            {
                contset.add(acr.PRM_Contact_Id__c);
                system.debug('acr.PRM_Contact_Id__c'+ acr.PRM_Contact_Id__c);
                system.debug('contset'+ acr.PRM_Contact_Id__c);
            }
            //Iterating over contacts to find if there is no active realtionships are there if not then taking them to a set
            for(id con: contactRelatedACRList){
                if(!contset.contains(con)){
                    conFinalset.add(con);
                    system.debug('con'+ con);
                    system.debug('conFinalset'+ conFinalset.size());
                }
            }
            if(!conFinalset.isEmpty()){
                //Fetching the contact subscriptions for the inactive contacts
                for(PRM_ContactSubscriptionAssociation__c conSubAssoc :[select id, PRM_Contact_Id__c, PRM_Status_Nm__c from PRM_ContactSubscriptionAssociation__c where PRM_Contact_Id__c IN :conFinalset AND PRM_Status_Nm__c=:System.Label.PRM_Status_Active]){
                    conSubAssoc.PRM_Status_Nm__c= System.Label.PRM_Status_Inactive;
                    conSubAssocUpdateList.add(conSubAssoc);
                    system.debug('ConSubAssoc'+ conSubAssoc);
                }
            }
        }
        if(!conSubAssocUpdateList.isEmpty()){
            try{
                update conSubAssocUpdateList;
                system.debug('conSubAssocUpdateList'+ conSubAssocUpdateList);
            }
            catch(exception e){
            }
        }
        //Ended 
    }  
    /*Utkarsh-US389509-Start - As part of the story if any ACR become active then corresponding contact entitlement should become active*/
    //Need to modify the method and compare old value and new value of Inactive indicator.
    public static void activateContactEntitlement(List<PRM_Account_Contact_Relationship__c> accConRelList,Map<Id,PRM_Account_Contact_Relationship__c> acrOldMap){
        List<Id> contactRelatedACRList = new List<Id>();
        List<Id> acrList = new List<Id>();
        List<Id> accIdList = new List<Id>();
        List<Id> benefitList = new List<Id>();
        List<Id> entitlementList = new List<Id>();
        List<Id> entitlementWithoutBEList = new List<Id>();
        List<Id> automaticBenefits = new List<Id>();
        List<Core_Contact_Entitlement__c> updateCeList = new List<Core_Contact_Entitlement__c>();
        List<PRM_ContactSubscriptionAssociation__c> conSubAssocUpdateList = new List<PRM_ContactSubscriptionAssociation__c>();
        PRM_Account_Contact_Relationship__c acrOld ;
        Boolean updateCheck = false;
        
        if(accConRelList != null && !accConRelList.IsEmpty()){
            for(PRM_Account_Contact_Relationship__c acr :accConRelList){
                System.debug('acr.PRM_InActive_Ind__c-->'+acr.PRM_InActive_Ind__c);
                if(acrOldMap!=null && acrOldMap.size()>0){
                    acrOld = (PRM_Account_Contact_Relationship__c) acrOldMap.get(acr.id) ;
                    system.debug('acrOld-->'+acrOld);
                    if((acrOld.PRM_InActive_Ind__c == true && acr.PRM_InActive_Ind__c == false) && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status){
                        system.debug('@@@@@inside ACR trigger to update Entitlement');
                        acrList.add(acr.PRM_Relationship_Id__c);
                        contactRelatedACRList.add(acr.PRM_Contact_Id__c);
                        accIdList.add(acr.PRM_Account_Id__c);
                        updateCheck = true;
                    }
                }
            }
        }
        System.debug('updateCheck-->'+updateCheck);
        System.debug('accIdList-->'+accIdList);
        System.debug('acrList-->'+acrList);
        System.debug('contactRelatedACRList-->'+contactRelatedACRList);
        if(updateCheck){
            if(accIdList != null && !accIdList.IsEmpty()){
                for(PRM_AccountBenefitAssociation__c aba :[Select Id, PRM_Partner_Benefit_Id__c,PRM_Account_Id__c From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accIdList AND PRM_Status_Nm__c =:System.Label.PRM_Status_Active]){
                    benefitList.add(aba.PRM_Partner_Benefit_Id__c);
                }
            }
            
            System.debug('benefitList-->'+benefitList);
            if(benefitList !=null && !benefitList.IsEmpty()){
                for(PRM_VXBnftMatrix__c bm :[Select Id,PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c From PRM_VXBnftMatrix__c Where PRM_Partner_Benefit_Id__c IN :benefitList AND PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType]){
                    automaticBenefits.add(bm.PRM_Partner_Benefit_Id__c);
                }
            }
            
            System.debug('automaticBenefits-->'+automaticBenefits);
            if(automaticBenefits !=null && !automaticBenefits.IsEmpty()){
                for(PRM_VXEnttlmntMatrix__c em :[Select Id,PRM_Partner_Benefit_Id__c,PRM_Entitlement_Id__c From PRM_VXEnttlmntMatrix__c Where PRM_Partner_Benefit_Id__c IN :automaticBenefits AND PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType]){
                    entitlementList.add(em.PRM_Entitlement_Id__c);
                }
            }
            for(PRM_VXEnttlmntMatrix__c emWithoutBenefits :[Select Id,PRM_Partner_Benefit_Id__c,PRM_Entitlement_Id__c From PRM_VXEnttlmntMatrix__c Where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND RecordType.Name =:System.Label.PRM_Entitlement_RecordType]){
                entitlementWithoutBEList.add(emWithoutBenefits.PRM_Entitlement_Id__c);
            }
            System.debug('entitlementWithoutBEList-->'+entitlementWithoutBEList);
            for(Core_Contact_Entitlement__c ce :[Select Id,Core_Selected__c,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Type__c From Core_Contact_Entitlement__c Where Core_Selected__c = false AND Core_Contact_Id__c IN :contactRelatedACRList AND Core_Entitlement_Id__c IN :entitlementWithoutBEList AND Core_Type__c = 'Entitlement']){
                if(!ce.Core_Selected__c){ // Updating Contact Entitlement status to pending when entitlement is inactive else status will remain same as previous.
                    ce.Core_Selected__c = true;
                    ce.Core_Status__c = System.Label.PRM_Status_Pending;
                    ce.Core_DontNotify__c = false;
                    ce.Core_Data_Loaded__c = true;
                    updateCEList.add(ce);
                }
                System.debug('ce-->'+ce);
            }
            System.debug('entitlementList-->'+entitlementList);
            if((contactRelatedACRList != null && !contactRelatedACRList.IsEmpty()) && (entitlementList != null && !entitlementList.IsEmpty())){
                for(Core_Contact_Entitlement__c ce :[Select Id,Core_Selected__c,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Type__c From Core_Contact_Entitlement__c Where Core_Selected__c = false AND Core_Contact_Id__c IN :contactRelatedACRList AND Core_Entitlement_Id__c IN :entitlementList AND Core_Type__c = 'Entitlement']){
                    if(!ce.Core_Selected__c){ // Updating Contact Entitlement status to pending when entitlement is inactive else status will remain same as previous.
                        ce.Core_Selected__c = true;
                        ce.Core_Status__c = System.Label.PRM_Status_Pending;
                        ce.Core_DontNotify__c = false;
                        if(!test.isRunningTest()){ // avoid SOQL 101 exception in existing entitlement trigger code
                            ce.Core_Data_Loaded__c = true;}
                        if(!updateCEList.Contains(ce)){
                            updateCEList.add(ce);
                        }
                    }
                    
                }
            }
            System.debug('updateCEList-->'+updateCEList);
            if(updateCEList != null && !updateCEList.IsEmpty()){
                update updateCEList;
            }
            
            //Activating subscription when ACR got active.
            if(!contactRelatedACRList.isEmpty() && contactRelatedACRList != null){
                //Fetching the contact subscriptions for the inactive contacts
                for(PRM_ContactSubscriptionAssociation__c conSubAssoc :[select id, PRM_Contact_Id__c, PRM_Status_Nm__c from PRM_ContactSubscriptionAssociation__c where PRM_Contact_Id__c IN :contactRelatedACRList AND PRM_Status_Nm__c=:System.Label.PRM_Status_Inactive]){
                    conSubAssoc.PRM_Status_Nm__c= System.Label.PRM_Status_Active;
                    conSubAssocUpdateList.add(conSubAssoc);
                    system.debug('conSubAssoc'+ conSubAssoc);
                }
            }
        }
        if(!conSubAssocUpdateList.isEmpty() && conSubAssocUpdateList != null){
            try{
                update conSubAssocUpdateList;
                system.debug('conSubAssocUpdateList'+ conSubAssocUpdateList);
            }
            catch(exception e){
            }
        }
    }
    /*Finish - US389509*/
    /*Utkarsh - Start - US389509 - As part of the story insert contact entitlements whenever ACR got inserted*/
    public static void insertContactEntitlement(List<PRM_Account_Contact_Relationship__c> accConRelList,Map<Id,PRM_Account_Contact_Relationship__c> acrOldMap){
        List<Id> contactRelatedACRList = new List<Id>();
        List<Id> acrList = new List<Id>();
        List<Id> accIdList = new List<Id>();
        List<Id> benefitList = new List<Id>();
        List<Id> entitlementList = new List<Id>();
        List<Id> entitlementWithoutBEList = new List<Id>();
        List<Id> automaticBenefits = new List<Id>();
        List<Id> benefitListTemp =new List<Id>();
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> finalCEList = new List<Core_Contact_Entitlement__c>();
        List<PRM_VXEnttlmntMatrix__c> entitlementWithoutBenefit = new List<PRM_VXEnttlmntMatrix__c>();
        Map<String,List<Id>> benefitMap = new Map<String,List<Id>>();
        Map<Core_Contact_Entitlement__c,Id> ceMap = new Map<Core_Contact_Entitlement__c,Id>();
        Map<Id,List<PRM_AccountChannelMembership__c>> acmMap = new Map<Id,List<PRM_AccountChannelMembership__c>>();
        Map<Id,Core_Contact_Entitlement__c> ceStatusMap = new Map<Id,Core_Contact_Entitlement__c>();
        String updateReasonCSPFlow = System.Label.PRM_Entitlement_Source;
        PRM_Account_Contact_Relationship__c acrOld ; 
        Map<Id,String> entAgsMap = new Map<Id,String>();
        
        //Fetching accountId, contactId, relationshipId from ACR inserted.
        if(accConRelList != null && !accConRelList.IsEmpty()){
            
            for(PRM_Account_Contact_Relationship__c acr :accConRelList){
                System.debug('acr.PRM_InActive_Ind__c-->'+acr.PRM_InActive_Ind__c);
                System.debug('acr.PRM_execute_trigger__c-->'+acr.PRM_execute_trigger__c);
                System.debug('acr.PRM_Status_Nm__c-->'+acr.PRM_Status_Nm__c);
                if(acrOldMap!=null && acrOldMap.size()>0){
                    acrOld = (PRM_Account_Contact_Relationship__c) acrOldMap.get(acr.id) ;
                    system.debug('acrOld-->'+acrOld);
                    if(acr.PRM_execute_trigger__c && ((acrOld.PRM_Status_Nm__c != System.Label.PRM_ACR_Status && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status && acr.PRM_InActive_Ind__c == false) || (acrOld.PRM_InActive_Ind__c == true && acr.PRM_InActive_Ind__c == false && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status))){
                        system.debug('@@@@@inside ACR trigger to create Entitlement');
                        acrList.add(acr.PRM_Relationship_Id__c);
                        contactRelatedACRList.add(acr.PRM_Contact_Id__c);
                        accIdList.add(acr.PRM_Account_Id__c);
                    }
                }
                else{
                    if(acr.PRM_InActive_Ind__c == false && acr.PRM_execute_trigger__c && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status){
                        system.debug('@@@@@inside ACR trigger to create Entitlement');
                        acrList.add(acr.PRM_Relationship_Id__c);
                        contactRelatedACRList.add(acr.PRM_Contact_Id__c);
                        accIdList.add(acr.PRM_Account_Id__c);
                    }
                }
            }
        }
        
        System.debug('accIdList-->'+accIdList);
        System.debug('acrList-->'+acrList);
        System.debug('contactRelatedACRList-->'+contactRelatedACRList);
        if(accIdList != null && !accIdList.IsEmpty()){
            for(PRM_AccountChannelMembership__c acm :[Select Id,PRM_Account_Id__c,PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Id__c,PRM_Partner_Role__c,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Status_Nm__c =:System.Label.PRM_Status AND PRM_Account_Id__c IN :accIdList]){
                List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
                if(acmMap.get(acm.PRM_Account_Id__c)!= null && !acmMap.get(acm.PRM_Account_Id__c).isEmpty()){
                    acmList = acmMap.get(acm.PRM_Account_Id__c);
                }
                acmList.add(acm);
                acmMap.put(acm.PRM_Account_Id__c,acmList);
                System.debug('acmList-->'+acmList);
            }
        }
        System.debug('acmMap-->'+acmMap);
        //Checking for existing benefits of parent account.
        if(accIdList != null && !accIdList.IsEmpty()){
            System.debug('came here');
            for(PRM_AccountBenefitAssociation__c aba :[Select Id, PRM_Partner_Benefit_Id__c,PRM_Account_Id__c,PRM_Status_Nm__c From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accIdList AND PRM_Status_Nm__c =:System.Label.PRM_Status_Active]){
                System.debug('aba on line 781 :- '+ aba);
                benefitList.add(aba.PRM_Partner_Benefit_Id__c);
            }
        }
        System.debug('benefitList-->'+benefitList);
        List<PRM_VXBnftMatrix__c> vxbm =[Select Id,PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_IsActive_Ind__c From PRM_VXBnftMatrix__c Where PRM_Partner_Benefit_Id__c IN :benefitList AND PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_IsActive_Ind__c = True];
        //filtering out automatic benefits from the list of benefits.
        for(PRM_Account_Contact_Relationship__c acr :accConRelList){
            if(benefitMap.get(acr.PRM_Account_Id__c)!= null && !benefitMap.get(acr.PRM_Account_Id__c).isEmpty()){
                benefitListTemp = benefitMap.get(acr.PRM_Account_Id__c);
            }
            for(PRM_VXBnftMatrix__c bm : vxbm){
                benefitListTemp.add(bm.PRM_Partner_Benefit_Id__c);
                benefitMap.put(acr.PRM_Account_Id__c,benefitListTemp);
            }
        }
        System.debug('benefitMap-->'+benefitMap);
        // Fetching entitlements which are not associated to any benefits.
        entitlementWithoutBenefit = [Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__c,PRM_Partner_Role_Nm__c,RecordType.Name,PRM_AGS_Role__c from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND RecordType.Name =:System.Label.PRM_Entitlement_RecordType AND PRM_IsActive_Ind__c = True AND PRM_Partner_Role_Nm__c != null];
        
        //Checking for multiple entitlements on single benefits.
        Map<Id,List<PRM_VXEnttlmntMatrix__c>> benefitEntitlementMap = new Map<Id,List<PRM_VXEnttlmntMatrix__c>>();
        for(PRM_VXEnttlmntMatrix__c em1 :[Select Id,PRM_Partner_Benefit_Id__c,PRM_Entitlement_Id__c,PRM_Contact_Relationship_Id__c,PRM_Partner_Role_Nm__c,PRM_Approval_Type_Nm__c,PRM_IsActive_Ind__c,PRM_AGS_Role__c,PRM_Entitlement_Id__r.Name From PRM_VXEnttlmntMatrix__c Where PRM_Partner_Benefit_Id__c IN :benefitListTemp AND PRM_Approval_Type_Nm__c = 'Automatic' AND PRM_IsActive_Ind__c = True AND PRM_Partner_Role_Nm__c != null]){
            List<PRM_VXEnttlmntMatrix__c> entitlements = new List<PRM_VXEnttlmntMatrix__c>();
            if(benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c)!= null && !benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c).isEmpty()){
                entitlements = benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c);
            }
            entitlements.add(em1);
            benefitEntitlementMap.put(em1.PRM_Partner_Benefit_Id__c,entitlements);
        }
        List<Account> accounts = [Select Id, Name From Account Where Id IN:accIdList]; 
        Map<Id,List<PRM_VXEnttlmntMatrix__c>> accEntitlementsMap= new Map<Id,List<PRM_VXEnttlmntMatrix__c>>();
        for(Account acc :accounts){
            List<Id> accBenefits = new List<Id>();
            accBenefits = benefitMap.get(acc.Id);
            if(accBenefits != null && !accBenefits.IsEmpty()){
                List<PRM_VXEnttlmntMatrix__c> accEntitlements = new List<PRM_VXEnttlmntMatrix__c>();
                if(accEntitlementsMap.get(acc.Id)!= null && !accEntitlementsMap.get(acc.Id).isEmpty()){
                    accEntitlements = accEntitlementsMap.get(acc.Id);
                }
                for(integer i=0; i<accBenefits.size(); i++){
                    List<PRM_VXEnttlmntMatrix__c> benfitEntitlements = new List<PRM_VXEnttlmntMatrix__c>();
                    benfitEntitlements = benefitEntitlementMap.get(accBenefits[i]);
                    if(benfitEntitlements != null && !benfitEntitlements.IsEmpty()){
                        accEntitlements.addAll(benfitEntitlements);
                    }
                }
                accEntitlementsMap.put(acc.Id, accEntitlements);
            }
        }
        //Assigning contact entitlements.
        for(PRM_Account_Contact_Relationship__c acr :accConRelList){
            
            List<PRM_VXEnttlmntMatrix__c> entitlements = new List<PRM_VXEnttlmntMatrix__c>();
            List<string> partnerRole = new List<string>();
            entitlements = accEntitlementsMap.get(acr.PRM_Account_Id__c);
            if(acr.PRM_Partner_Role__c != null){
                partnerRole = acr.PRM_Partner_Role__c.split('_BR_ENCODED_');
            }
            if(entitlements != null && !entitlements.IsEmpty()){ // Assigning entitlements based on the benefits.
                for(integer i=0; i<entitlements.size(); i++){
                    System.debug('entitlements-->'+entitlements);
                    if(entitlements[i].PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c && (partnerRole != null && !partnerRole.IsEmpty()) && partnerRole.contains(entitlements[i].PRM_Partner_Role_Nm__c)){
                        entAgsMap.put(entitlements[i].PRM_Entitlement_Id__c,entitlements[i].PRM_AGS_Role__c);
                        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
                        ce.Core_Contact_Id__c = acr.PRM_Contact_Id__c;
                        ce.Core_Entitlement_Id__c = entitlements[i].PRM_Entitlement_Id__c;
                        ce.Core_Selected__c = true;
                        //ce.Core_Status__c = System.Label.PRM_Status_Pending;
                        ce.Core_From_Source__c = false;
                        if(!test.isRunningTest()){ // avoid SOQL 101 exception in existing entitlement trigger code
                            ce.Core_Data_Loaded__c = true;
                            ce.Core_DontNotify__c = false;}
                        if(entitlements[i].PRM_AGS_Role__c == '' || entitlements[i].PRM_AGS_Role__c == null){
                            ce.Core_From_Source__c = true;
                        }
                        else {
                            ce.Core_Status__c = 'Pending';
                        }
                        if(!ceList.Contains(ce)){
                            ceList.add(ce);
                        }
                    }
                }
            }
            // Assigning default entitlements.
            System.debug('entitlementWithoutBenefit-->'+entitlementWithoutBenefit);
            for(PRM_VXEnttlmntMatrix__c em :entitlementWithoutBenefit){
                System.debug('em-->'+em);
                System.debug('acr-->'+acr);
                System.debug('acr.PRM_Partner_Role__c-->'+acr.PRM_Partner_Role__c);
                System.debug('partnerRole-->'+partnerRole);
                List<PRM_AccountChannelMembership__c> acm = new List<PRM_AccountChannelMembership__c>();
                if(acmMap !=null && !acmMap.IsEmpty()){
                    acm = acmMap.get(acr.PRM_Account_Id__c);
                }
                for(integer i=0; i<acm.size(); i++){
                    if(em.PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c && (partnerRole != null && !partnerRole.IsEmpty()) && partnerRole.contains(em.PRM_Partner_Role_Nm__c) && em.PRM_Channel_Program_Level_Id__c == acm[i].PRM_Channel_Program_Level_Id__c){
                        entAgsMap.put(em.PRM_Entitlement_Id__c,em.PRM_AGS_Role__c);
                        System.debug('came in else'+ em.PRM_AGS_Role__c);
                        System.debug('came in else'+ em);
                        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
                        ce1.Core_Contact_Id__c = acr.PRM_Contact_Id__c;
                        ce1.Core_Entitlement_Id__c = em.PRM_Entitlement_Id__c;
                        ce1.Core_Selected__c = true;
                        //ce1.Core_Status__c = System.Label.PRM_Status_Pending;
                        ce1.Core_Data_Loaded__c = true;
                        ce1.Core_DontNotify__c = false;
                        ce1.Core_From_Source__c = false;
                        if(em.PRM_AGS_Role__c == '' || em.PRM_AGS_Role__c == null){
                            ce1.Core_From_Source__c = true;
                        }
                        else {
                            ce1.Core_Status__c = 'Pending';
                        }
                        if(!ceList.Contains(ce1)){
                            ceList.add(ce1);
                        }
                    }
                }
            }
        }
        //Checking for existing Contact Entitlements.
        // Core_Type__c = 'Entitlement'
        for(Core_Contact_Entitlement__c ce : [Select Id, Name,Core_Selected__c,Core_Entitlement_Id__c,Core_Contact_Id__c,Core_Status__c,Core_Data_Loaded__c,Core_DontNotify__c,Core_Type__c,Core_Source__c,Core_From_Source__c From Core_Contact_Entitlement__c Where Core_Contact_Id__c IN :contactRelatedACRList]){
            Core_Contact_Entitlement__c newCe = new Core_Contact_Entitlement__c();
            newCe.Core_Contact_Id__c = ce.Core_Contact_Id__c;
            newCe.Core_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
            newCe.Core_Selected__c = true;
            if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(ce.Core_Entitlement_Id__c) != '' && entAgsMap.get(ce.Core_Entitlement_Id__c) != null)){
                newCe.Core_Status__c = 'Pending';
            }
            //newCe.Core_Status__c = System.Label.PRM_Status_Pending;
            newCe.Core_Data_Loaded__c = true;
            newCe.Core_DontNotify__c = false;
            newCe.Core_From_Source__c = ce.Core_From_Source__c;
            ceMap.put(newCe, ce.Id);
            ceStatusMap.put(ce.Id,ce);
        }
        System.debug('ceMap-->'+ceMap);
        System.debug('ceStatusMap-->'+ceStatusMap);
        for(Core_Contact_Entitlement__c ce :ceList){
            System.debug('inside for CE-->'+ce);
            updateCheck = false;
            if(ceMap.containsKey(ce)){
                ce.Id = ceMap.get(ce); //Populating Id to the existing Contact Entitlements records.
                Core_Contact_Entitlement__c contEnt = ceStatusMap.get(ce.Id);
                //System.debug('inside for CE-->'+ce);
                if(contEnt.Core_Source__c != updateReasonCSPFlow){ //Added for US539488:to Identify origin of Entitlement
                    ce.Core_Source__c = updateReasonCSPFlow;
                    updateCheck = true;
                }
                if(!contEnt.Core_Selected__c){
                    ce.Core_Selected__c = true;
                    updateCheck = true;
                }
                if(updateCheck){
                    finalCEList.add(ce);
                }
            }
            else{
                ce.Core_Selected__c = true; //Inserting Entitlements.
                if(ce.Core_Source__c != updateReasonCSPFlow){ //Added for US539488:to Identify origin of Entitlement
                    ce.Core_Source__c = updateReasonCSPFlow;
                }
                finalCEList.add(ce);
                System.debug('else finalCEList-->'+finalCEList);
            }
        }
        System.debug('finalCEList-->'+finalCEList);
        if(finalCEList != null && !finalCEList.IsEmpty()){
            upsert finalCEList;
        }
        
    }
    /* *****************************************************************************************************************************************
    * author:      Tejasree      
    * Date:        23/04/2020
    * Parameters:  list<PRM_Account_Contact_Relationship__c> lstOfACR, map<id,PRM_Account_Contact_Relationship__c> mapOldACRById 
    * Return:      Void
    * UserStory:   US632447
    * Description: This method is used to update Start Date and End Date fields of AccountContactRelationship Object on insertion and inActivation in ACR 
    ****************************************************************************************************************************************** */
    
    public static void updateStartandEndDates(List<PRM_Account_Contact_Relationship__c> acrList,Map<Id,PRM_Account_Contact_Relationship__c> oldMap){
        Set<Id> acrUpdatelist = new Set<Id>();
        List<PRM_Account_Contact_Relationship__c> finalacrUpdates = new List<PRM_Account_Contact_Relationship__c >();
        List<PRM_Account_Contact_Relationship__c> updateACR = new List<PRM_Account_Contact_Relationship__c>();
        for(PRM_Account_Contact_Relationship__c  acr: acrList){
            PRM_Account_Contact_Relationship__c  acrOld ; 
            if(oldMap!=null && oldMap.size()>0) {acrOld = (PRM_Account_Contact_Relationship__c)oldMap.get(acr.id) ;}
            //For insertion of new ACR records
            if((oldMap==null) && (acr.PRM_InActive_Ind__c==false) && (acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status)){
                acrUpdatelist.add(acr.id);
            }
            //Filtering the records based on below conditions during ACR Update 
            if(((oldMap!=null && oldMap.size()>0)&&((acrOld.PRM_InActive_Ind__c != acr.PRM_InActive_Ind__c)&&(acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status) 
   			||((acrOld.PRM_Status_Nm__c!=acr.PRM_Status_Nm__c) && (acr.PRM_Status_Nm__c ==System.Label.PRM_ACR_Status))))){
                acrUpdatelist.add(acr.id);
            }  
        }
        //SOQL query
        if(acrUpdatelist!=Null && acrUpdatelist.size()>0 &&(Schema.sObjectType.PRM_Account_Contact_Relationship__c.isAccessible())){
            updateACR = [Select Id,PRM_Start_Date_Dt__c,PRM_End_Date_Dt__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where Id IN:acrUpdatelist];}
        if(updateACR!=Null && updateACR.size()>0){
            for(PRM_Account_Contact_Relationship__c acrRec : updateACR){
                //During Activation or ReActivation of ACR record based on below conditions, set Start Date and End Date accordingly
                if(acrRec.PRM_InActive_Ind__c==false){  
                    acrRec.PRM_Start_Date_Dt__c= system.today(); 
                    System.debug('Inactive ACR Ind' +acrRec.PRM_InActive_Ind__c);
                    if((acrRec.PRM_End_Date_Dt__c!=Null)&&(acrRec.PRM_End_Date_Dt__c<=system.today())){ 
                        acrRec.PRM_End_Date_Dt__c=Null;
                        System.debug('End date after assignment' +acrRec.PRM_End_Date_Dt__c);
                    } 
                    finalacrUpdates.add(acrRec);
                }
                //Assigning EndDate value to the date when ACR is Deactivated.
                else if((acrRec.PRM_InActive_Ind__c==true)&&((acrRec.PRM_End_Date_Dt__c==null) ||(acrRec.PRM_End_Date_Dt__c>system.today()))){
                    acrRec.PRM_End_Date_Dt__c=system.today();
                    finalacrUpdates.add(acrRec);}
            }
        }
        //Updating ACR records 
        if(finalacrUpdates!=Null && finalacrUpdates.size()>0 && (Schema.sObjectType.PRM_Account_Contact_Relationship__c.isUpdateable())){
            update finalacrUpdates;
        }
    } //Finish - US632447
    /*Finish - US389509*/
    /*Utkarsh - Start - US433628 - As part of the story upsert default relation ACR record when ACR record is created with relationship other then default relation for the same contact */
    /*
    public static void upsertDefaultRelationship(List<PRM_Account_Contact_Relationship__c> accConRelList){
    System.debug('come in insertDefaultRelationship');
    List<Id> contactRelatedACRList = new List<Id>();
    List<String> acrList = new List<String>();
    List<Id> accIdList = new List<Id>();
    List<PRM_Account_Contact_Relationship__c> exixtingACR = new List<PRM_Account_Contact_Relationship__c>();
    List<PRM_Account_Contact_Relationship__c> upsertDefaultACR = new List<PRM_Account_Contact_Relationship__c>();
    List<Id> defaultRelationId = new List<Id>();
    List<Id> acrId = new List<Id>();
    if(accConRelList != null && !accConRelList.IsEmpty()){
    for(PRM_Account_Contact_Relationship__c acr :accConRelList){
    System.debug('acr.PRM_InActive_Ind__c--->'+acr.PRM_InActive_Ind__c);
    System.debug('acr.PRM_execute_trigger__c--->'+acr.PRM_execute_trigger__c);
    System.debug('acr.PRM_Status_Nm__c--->'+acr.PRM_Status_Nm__c);
    if(acr.PRM_InActive_Ind__c == false && acr.PRM_execute_trigger__c && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status){
    contactRelatedACRList.add(acr.PRM_Contact_Id__c);
    accIdList.add(acr.PRM_Account_Id__c);
    acrId.add(acr.Id);
    }
    }
    }
    System.debug('acrId--->'+acrId);
    System.debug('accIdList--->'+accIdList);
    System.debug('contactRelatedACRList--->'+contactRelatedACRList);
    for(PRM_Account_Contact_Relationship__c defaultExistingACR :[Select id, name,PRM_Relationship_Id__c,PRM_Relationship_Id__r.Name From PRM_Account_Contact_Relationship__c Where Id IN :acrId]){
    if(defaultExistingACR.PRM_Relationship_Id__r.Name == System.Label.PRM_Default_Relation){
    acrList.add(defaultExistingACR.PRM_Relationship_Id__r.Name);
    }
    }
    System.debug('acrList--->'+acrList);
    //Checking for Default Relationship in contact relation.
    for(PRM_ContactRelationships__c cr :[Select Id, Name,PRM_Default_Relationship_Ind__c From PRM_ContactRelationships__c Where PRM_Default_Relationship_Ind__c = true]){
    defaultRelationId.add(cr.Id);
    }
    System.debug('defaultRelationId-->'+defaultRelationId);
    //Checking for the exiting default relation ACR records.
    if(defaultRelationId != null && !defaultRelationId.IsEmpty() && contactRelatedACRList != null && !contactRelatedACRList.IsEmpty() && accIdList != null && !accIdList.IsEmpty()){
    exixtingACR = [Select Id, Name,PRM_Account_Id__c,PRM_Relationship_Id__c,PRM_Contact_Id__c,PRM_InActive_Ind__c From PRM_Account_Contact_Relationship__c Where PRM_Account_Id__c IN :accIdList AND PRM_Contact_Id__c IN :contactRelatedACRList AND PRM_Relationship_Id__c IN :defaultRelationId];
    }
    System.debug('exixtingACR-->'+exixtingACR);
    //if default relation ACR records exist then activate it.
    if(exixtingACR != null && !exixtingACR.IsEmpty() && (!acrList.IsEmpty() || acrList != null)){
    for(PRM_Account_Contact_Relationship__c acr :exixtingACR){
    if(acr.PRM_InActive_Ind__c == true){
    acr.PRM_InActive_Ind__c = false;
    acr.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
    upsertDefaultACR.add(acr);
    }
    }
    }
    else{ //if default relation ACR records doesn't exist then insert new ACR record with default relation.
    if(trigger.Isinsert || trigger.Isupdate){
    for(PRM_Account_Contact_Relationship__c acr :accConRelList){
    if(acr.PRM_InActive_Ind__c == false && acr.PRM_execute_trigger__c && (defaultRelationId != null && !defaultRelationId.IsEmpty()) && !defaultRelationId.contains(acr.PRM_Relationship_Id__c) && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status){
    for(integer i=0; i<defaultRelationId.size(); i++){
    PRM_Account_Contact_Relationship__c defaultACR = new PRM_Account_Contact_Relationship__c();
    defaultACR.PRM_Account_Id__c = acr.PRM_Account_Id__c;
    defaultACR.PRM_Contact_Id__c = acr.PRM_Contact_Id__c;
    defaultACR.PRM_Relationship_Id__c = defaultRelationId[i];
    defaultACR.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
    upsertDefaultACR.add(defaultACR);
    }
    }
    System.debug('upsertDefaultACR-->'+upsertDefaultACR);
    }
    }
    }
    if(upsertDefaultACR != null && !upsertDefaultACR.IsEmpty()){
    upsert upsertDefaultACR;
    System.debug('upsertDefaultACR-->'+upsertDefaultACR);
    }
    }
    /*Finish - US433628*/    
    
    //Email to primary contact when such incative operation of ACR happen
    public static void emailForPrimaryContact(Map<id,sObject> oldMap, Map<id,sObject> newMap){
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName :- '+profileName);
        
        if(String.isNotEmpty(profileName) && profileName.toUpperCase() != System.Label.PRM_INTEGRATION_PROFILE.toUpperCase()){
           PRM_EmailToPrimaryContact.sendEmailToAllPrimaryContact(oldMap,newMap,null,false, true);
        }
    }
    
    
    public class InputParamsValues{
        String accountId;
        String contactId;
    }
}