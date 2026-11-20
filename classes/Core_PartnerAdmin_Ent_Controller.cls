/******************************************************************************************************
* Class Name  : Core_PartnerAdmin_Ent_Controller 
* Version     : 1.0 
* Created Date: 04-13-2019
* Modification Log :
* Developer  Sandip Ghosh          
* Date   04/13/2019
* Description : This class is used for displaying contact entitlements
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
public class Core_PartnerAdmin_Ent_Controller {
    
    public class Core_Partner_Entitlement_Response_Wrapper{
        
        @AuraEnabled public List<Core_Partner_Entitlement_Wrapper> lstPartnerEntWrapper;
        @AuraEnabled public Core_AuraProcessingMessage auraProcessingMessage; 
        
    }
        
/****************************************************************************************************** 
Method Name:        fetchContactbyEmail
@return  :          List of Contact record(s)
@parameters:        <String>searchKeyWord
Description:        This method is used to fetch claim data by passing claim record ID, in case of edit
Added By:           Accenture - AD - 04/06/2019
Modified By: Sandip        Date:  04/06/2019     Changes: Initial Version
*******************************************************************************************************/
    @AuraEnabled
    public static Core_Partner_Entitlement_Response_Wrapper fetchContactEntitlements(String contactId) {
	//Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper
		final String STR_PROCESSING = 'Processing';
		Core_Contact_Entitlements_Controller ccEntController = new Core_Contact_Entitlements_Controller(contactId);
		Core_Partner_Entitlement_Response_Wrapper corePartnerEntResponseWrapper = new Core_Partner_Entitlement_Response_Wrapper();
        
        List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> lstEntWrapper 
            = new List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>();
        List<Core_Partner_Entitlement_Wrapper> lstPartnerEntWrapper 
            = new List<Core_Partner_Entitlement_Wrapper>();
        
        System.debug('contactId = ' + contactId);
        ccEntController.idContact = contactId; 
        Core_AuraProcessingMessage auraProcessingMessage = ccEntController.checkAGSStatus(); 
        ccEntController.filterEntitlementsByProfile();
        lstEntWrapper = ccEntController.populateEntitlementWrapper();
        System.debug(lstEntWrapper);
        for(Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper ceWrapper : lstEntWrapper){
        	Core_Partner_Entitlement_Wrapper cpeWrapper = new Core_Partner_Entitlement_Wrapper() ;
            cpeWrapper.strName = ceWrapper.name;
            cpeWrapper.idEntitlement = ceWrapper.idEntitlement;
            cpeWrapper.selected = ceWrapper.selected;
            cpeWrapper.status = ceWrapper.status;
            if(!String.isBlank(cpeWrapper.status) && cpeWrapper.status.equalsIgnoreCase(STR_PROCESSING)){
               cpeWrapper.readOnly = true; 
            }
            //cpeWrapper.auraProcessingMessage = auraProcessingMessage;
            lstPartnerEntWrapper.add(cpeWrapper);
        }
        corePartnerEntResponseWrapper.lstPartnerEntWrapper = lstPartnerEntWrapper;
        corePartnerEntResponseWrapper.auraProcessingMessage = auraProcessingMessage;
        System.debug('lstPartnerEntWrapper = '+ lstPartnerEntWrapper);
        System.debug('corePartnerEntResponseWrapper = '+ corePartnerEntResponseWrapper);
        return corePartnerEntResponseWrapper;
        //return lstPartnerEntWrapper;
	}
    
    @AuraEnabled
    public static Boolean saveContactEntitlements(List<Core_Partner_Entitlement_Wrapper> cpEWrapperList, String contactId) {
        String UPDATE_REASON_EUM = 'External User Management';
        System.debug('saveContactEntitlements > cpEWrapperList = '+ cpEWrapperList);
        System.debug('contactId = ' + contactId);
        List<List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>> localLstlstEntitlementWrapper 
            = new List<List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>>();
        List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper> lstEntWrapper 
            = new List<Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper>();
        
                
        for(Core_Partner_Entitlement_Wrapper cpeWrapper : cpEWrapperList){
        	
            Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper ceWrapper 
                = new Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper(cpeWrapper.strName);
            ceWrapper.idEntitlement = cpeWrapper.idEntitlement;
            ceWrapper.selected = cpeWrapper.selected;
            lstEntWrapper.add(ceWrapper);
        }
        
        for(Core_Contact_Entitlements_Controller.Core_Entitlement_Wrapper ceWrapper : lstEntWrapper){
            if(ceWrapper.selected == null){
               ceWrapper.selected = false; 
            }
        }
        
        System.debug(lstEntWrapper);
        localLstlstEntitlementWrapper.add(lstEntWrapper);
        System.debug(localLstlstEntitlementWrapper);
		Core_Contact_Entitlements_Controller ccEntController = new Core_Contact_Entitlements_Controller(contactId);
        ccEntController.idContact = contactId;
        System.debug('saveContactEntitlements > before calling filterEntitlementsByProfile');
        ccEntController.filterEntitlementsByProfile();
        System.debug('saveContactEntitlements > before calling populateEntitlementWrapper');
        ccEntController.populateEntitlementWrapper();
        System.debug('saveContactEntitlements > before calling saveContactEntitlements');
        ccEntController.saveContactEntitlements(localLstlstEntitlementWrapper,UPDATE_REASON_EUM);
        return false;
    }

}