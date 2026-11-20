/******************************************************************************************************
* Class Name  : EPUM_PartnerContactEnt_Controller 
* Version     : 1.0 
* Created Date: 04-13-2020
* Modification Log :
* Developer  Hemavathi        
* Date   04/13/2020
* Description : This class is used for displaying contact entitlements
* Subhadeep				   06/10/2021           Modifications done for new Manage Personnel Design
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
public without sharing class EPUM_PartnerContactEnt_Controller{		
    public class EPUM_PartnerContactEnt_Controller_Wrapper{
        @AuraEnabled public List<EPUM_ContactEntitlement_Wrapper> lstContactEntWrapper;
        @AuraEnabled public EPUM_AuraProcessingMessage auraProcessingMessage; 
        //@AuraEnabled public Map<string,String> mapEPUMConstants;
        @AuraEnabled public SelectedUserWrapper selectedConObj;     
    }
    /****************************************************************************************************** 
Method Name:        fetchContactEntitlements
@return  :          List of Partner Contact Entitlement Wrapper record(s)
@parameters:        <String>sContactIdStr 
Description:        This method is used to fetch entitlement data by passing secondaryContact record ID, in case of edit/New
Added By:           Accenture - AD - 04/13/2020
Modified By: Hema        Date:  04/13/2020     Changes: Initial Version
*******************************************************************************************************/
    @AuraEnabled
    public static EPUM_PartnerContactEnt_Controller_Wrapper fetchContactEntitlements(String sContactIdStr){
        System.debug('fetchContactEntitlements sContactIdStr:'+sContactIdStr);
        EPUM_ContactEntitlement_Util.sContactIdStr = sContactIdStr;
        //Core_EPUM_ContactEntitlement_Util.pContactIdStr = pContactIdStr;
        //Core_EPUM_ContactEntitlement_Util.intelAccountIdStr_PC = intelAccountIdStr_PC;
        //Core_EPUM_ContactEntitlement_Util.onePartnerIdStr = onePartnerIdStr;
        list<EPUM_ContactEntitlement_Wrapper> lstContactEntWrapper = EPUM_ContactEntitlement_Util.getContactEntitlementsWrap();
        
        // 'Partner Admin Delegate' should be on top of responsibilty list - Start
        list<EPUM_ContactEntitlement_Wrapper> lstContactEntWrapperNew = new list<EPUM_ContactEntitlement_Wrapper>();
        
        EPUM_ContactEntitlement_Wrapper padObj ;
        for(EPUM_ContactEntitlement_Wrapper obj:lstContactEntWrapper){            
            if(obj.entitlementNameStr == 'Partner Admin Delegate'){
                padObj = obj;
            }
        }
        
        if(padObj != null){
            lstContactEntWrapper.remove(lstContactEntWrapper.indexOf(padObj));
            lstContactEntWrapperNew.add(padObj);
        }
		System.debug('---lstContactEntWrapper--'+lstContactEntWrapper);        
        lstContactEntWrapperNew.addAll(lstContactEntWrapper);
        System.debug('---lstContactEntWrapperNew--'+lstContactEntWrapperNew);
        
        
        
        // 'Partner Admin Delegate' should be on top of responsibilty list - End
        
        
        Contact objContact = EPUM_ContactEntitlement_Util.getContact();
        EPUM_ContactEntitlement_Util.objContact = objContact;
        //Core_EPUM_AuraProcessingMessage auraProcessingMessage = Core_EPUM_ContactEntitlement_Util.checkAGSStatus();
        EPUM_PartnerContactEnt_Controller_Wrapper corePartnerContactEntWrapper = new EPUM_PartnerContactEnt_Controller_Wrapper();
        //corePartnerContactEntWrapper.lstContactEntWrapper = lstContactEntWrapper;
        corePartnerContactEntWrapper.lstContactEntWrapper = lstContactEntWrapperNew;
        corePartnerContactEntWrapper.auraProcessingMessage = new EPUM_AuraProcessingMessage();
        //corePartnerContactEntWrapper.mapEPUMConstants = EPUM_SearchContact.fetchEPUMConstants();
        corePartnerContactEntWrapper.selectedConObj=isSelectedUserPAOrPAD(sContactIdStr);
        return corePartnerContactEntWrapper;
    }
    
    @AuraEnabled
    public static Boolean saveContactEntitlements(list<Object> lstContactEntWrapper,String sContactIdStr) {
        EPUM_ContactEntitlement_Util.sContactIdStr = sContactIdStr;
        Contact objContact = EPUM_ContactEntitlement_Util.getContact();
        System.debug('saveContactEntitlements lstContactEntWrapper::'+lstContactEntWrapper);
        return EPUM_ContactEntitlement_Util.saveContactEntitlements(lstContactEntWrapper);
    }
    
    
    @AuraEnabled
    public static SelectedUserWrapper isSelectedUserPAOrPAD(String conId) {
        String partnerAdminDelegate= 'Partner Admin Delegate';
        String partnerAdmin= 'Partner Admin';
        
        SelectedUserWrapper wrapObj = new SelectedUserWrapper();
        
        List<Core_Contact_Entitlement__c> ccnList = [select Core_Entitlement_Id__r.Name ,Core_Selected__c from Core_Contact_Entitlement__c where Core_Selected__c=true AND Core_Status__c='Complete' AND Core_Contact_Id__c=:conId];
        
         if(!ccnList.isEmpty() && ccnList != null){
            for(Core_Contact_Entitlement__c ccnObj : ccnList){
                if(partnerAdminDelegate.equalsIgnoreCase(ccnObj.Core_Entitlement_Id__r.Name)){
                    wrapObj.isPartnerAdminDelegate = true;
                }
                if(partnerAdmin.equalsIgnoreCase(ccnObj.Core_Entitlement_Id__r.Name)){
                    wrapObj.isPartnerAdmin = true;
                }
            }  
        } 
        return wrapObj;
    }
    
    public class SelectedUserWrapper{
        @AuraEnabled public Boolean isPartnerAdmin = false;
        @AuraEnabled public Boolean isPartnerAdminDelegate = false;
    }


    /*********subhadeep DRACO changes START************/
    @AuraEnabled
    public static string updateContactStatus(String conId, String conStatus){
        try{
            system.debug('in update con');
            List<String> IPADetachedEntList = string.isNotBlank(Label.EPUM_IPADetachEntitlements) ? Label.EPUM_IPADetachEntitlements.split(',') : null;
            List<Core_Contact_Entitlement__c> conEntLstUpdt = new List<Core_Contact_Entitlement__c>();
            list<PRM_Account_Contact_Relationship__c> acrlist = new list<PRM_Account_Contact_Relationship__c>([SELECT Id,PRM_Contact_Id__c,PRM_InActive_Ind__c FROM PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c =:conId]);
            List<Core_Contact_Entitlement__c> conEntList = new List <Core_Contact_Entitlement__c>([select Id, Core_Selected__c from Core_Contact_Entitlement__c where Core_Selected__c=true and Core_Entitlement_Id__r.Core_Category__c = 'Intel Partner Alliance (IPA)' AND Core_Entitlement_Nm__c != :IPADetachedEntList AND Core_Contact_Id__r.Id =:conId ]);
                
            for(Core_Contact_Entitlement__c cEnt :conEntList){
                cEnt.Core_Selected__c = false;
                cEnt.Core_Status__c = 'Pending';
                conEntLstUpdt.add(cEnt);
            }
            upsert conEntLstUpdt;
     
            Contact con = new Contact();
            con.Id = conId;
            con.Core_Republish_OBM_s__c = true;
            //con.Core_IPA_Email_Verification_Date__c = null;
            update con;

            if(acrlist != Null){
                list<PRM_Account_Contact_Relationship__c> newAcrlist = new list<PRM_Account_Contact_Relationship__c>();
                for(PRM_Account_Contact_Relationship__c acrCon :acrlist){
                    acrCon.PRM_InActive_Ind__c = true;
                    newAcrlist.add(acrCon);
                }
                upsert newAcrlist; // Akshay - Retained only updatng ACR to InActive Ind = TRUE as ACR records are not supposed to be deleted directly
                return 'ACR Inactivated';
            }
            return 'Not act or Inact';
        }

        catch(Exception e){
            return e.getMessage();
        }
        

    }
    /*********subhadeep DRACO changes END************/
    
}