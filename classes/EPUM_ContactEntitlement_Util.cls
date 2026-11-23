/******************************************************************************************************
* Class Name  : EPUM_ContactEntitlement_Util
* Version     : 1.0 
* Created Date: 04-13-2020
* Modification Log :
* Developer  Hemavathi        
* Date   04/13/2020
* Description : This class is used for displaying contact entitlements
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
public without sharing class EPUM_ContactEntitlement_Util{
    public static String sContactIdStr;
    public static Contact objContact;
    private final static String RICHTEXT='richtext';
    // ADDED NEW
    private static final String PAD_ENTITLEMENT = 'Partner Admin Delegate';
    private static final String STATUS_PENDING = 'Pending';
    
    public static Contact getContact(){
        System.debug('*****getContact => sContactIdStr::'+ sContactIdStr);
        if(String.isBlank(sContactIdStr)){
            return null;
        }
        objContact = [SELECT Id, AccountId,Core_AGS_Integration_Status__c,Core_ERPM_Integration_Status__c,Core_Enterprise_Id__c FROM Contact WHERE Id=:sContactIdStr limit 1];
        return objContact;
    }
    
    /****************************************************************************************************** 
Method Name:        getContactEntitlementsWrap
@return  :          List of Partner Contact Entitlement Wrapper record(s)
@parameters:        <String>sContactIdStr 
Description:        This method is used to fetch entitlement data by passing secondaryContact record ID, in case of edit/New
Added By:           Accenture - AD - 04/13/2020
Modified By: Hema        Date:  04/13/2020     Changes: Initial Version
*******************************************************************************************************/
    public static list<EPUM_ContactEntitlement_Wrapper> getContactEntitlementsWrap(){
        list<Core_Entitlement__c> lstCoreEntitlements = new list<Core_Entitlement__c>();
        list<EPUM_ContactEntitlement_Wrapper> lstCoreContactEntitlementWrap = new list<EPUM_ContactEntitlement_Wrapper>();
        lstCoreEntitlements = getCoreEntitlements();
        System.debug('getContactEntitlementsWrap lstCoreEntitlements:'+lstCoreEntitlements.size());
        lstCoreContactEntitlementWrap = populateEntitlements(lstCoreEntitlements);
        System.debug('getContactEntitlementsWrap lstCoreContactEntitlementWrap:'+lstCoreContactEntitlementWrap.size());
        return lstCoreContactEntitlementWrap;
    }
    /****************************************************************************************************** 
Method Name:        saveContactEntitlements
@return  :          List of Partner Contact Entitlement Wrapper record(s)
@parameters:        <String>sContactIdStr and list<EPUM_ContactEntitlement_Wrapper> lstContactEntWrapper
Description:        This method is used to save entitlement data by passing secondaryContact record ID and list for contact entitlement wrapper record
Added By:           Accenture - AD - 04/13/2020
Modified By: Hema        Date:  04/13/2020     Changes: Initial Version
*******************************************************************************************************/
    public static Boolean saveContactEntitlements(List<Object> lstContactEntWrap){ //STORES MULTIPLE ENT
        List<Exception> exceptionMessages = new List<Exception>();
        system.debug('saveContactEntitlements lstContactEntWrap'+ lstContactEntWrap);
        system.debug('saveContactEntitlements con id'+ sContactIdStr);
        String updateReasonEPUM = 'External Partner User Management';
        Core_Contact_Entitlement__c objConEnt;
        List<Core_Contact_Entitlement__c> lstCoreContactEntitlements = new List<Core_Contact_Entitlement__c>();
        Contact ContactForPAD = new Contact();
        if(objContact == null){
            getContact();
        }
        for(Object entWrap : lstContactEntWrap){
            EPUM_ContactEntitlement_Wrapper objConEntWrapper = (EPUM_ContactEntitlement_Wrapper)JSON.deserialize(JSON.serialize(entWrap) , EPUM_ContactEntitlement_Wrapper.class);
            //Core_EPUM_ContactEntitlement_Wrapper objConEntWrapper = entWrap;
            if(objConEntWrapper.ContactEntitlement != null){
                
                objConEnt = new Core_Contact_Entitlement__c();
                objConEnt = objConEntWrapper.ContactEntitlement;
                if(  objConEntWrapper.isSelected && !objConEnt.Core_Selected__c){
                    objConEnt.Core_Selected__c = objConEntWrapper.isSelected;
                    objConEnt.Core_Status__c=STATUS_PENDING;
                    lstCoreContactEntitlements.add(objConEnt);
                }else if( objConEntWrapper.isSelected && objConEnt.Core_Selected__c){
                    //do nothing
                }else{
                    if(objConEnt.Core_Selected__c != false){
                        objConEnt.Core_Selected__c = false;
                        objConEnt.Core_Status__c= STATUS_PENDING;
                        lstCoreContactEntitlements.add(objConEnt);
                    }
                }
                if(objConEntWrapper.entitlementNameStr == PAD_ENTITLEMENT && objContact != null){
                    
                    ContactForPAD = objContact;
                }
                
                /*if(objConEnt.Core_Entitlement_Id__r.name == 'Partner Admin Delegate'){
ContactForPAD = objConEnt.Core_Contact_Id__r;
}*/
                
            }else if(objConEntWrapper.isSelected){
                objConEnt = new Core_Contact_Entitlement__c(Core_Contact_Id__c=sContactIdStr, 
                                                            Core_Entitlement_Id__c=objConEntWrapper.entitlementId,Core_Status__c='Pending',
                                                            Core_Selected__c=true);
                objConEnt.Core_Source__c = updateReasonEPUM;                        
                lstCoreContactEntitlements.add(objConEnt);  
                if(objConEntWrapper.entitlementNameStr == PAD_ENTITLEMENT && objContact != null){
                    
                    ContactForPAD = objContact;
                }
                
                /*if(objConEnt.Core_Entitlement_Id__r.name == 'Partner Admin Delegate'){
ContactForPAD = objConEnt.Core_Contact_Id__r;
}*/
            }
        }
        System.debug('#55 lstCoreContactEntitlements: ' + lstCoreContactEntitlements);
        Boolean updated = false;
        if (lstCoreContactEntitlements.size() > 0) {
            try{
                if(lstCoreContactEntitlements != null && !lstCoreContactEntitlements.isEmpty()){
                    Database.upsert(lstCoreContactEntitlements, false);
                    updated = true;                    
                }
                
            } catch(Exception e) {
                exceptionMessages.add(e);
                lstCoreContactEntitlements = new List<Core_Contact_Entitlement__c>();
                return false;
            }
        }
        if(updated) {
            System.debug('objContact:'+objContact);
            if(objContact != null){
                objContact.Core_ERPM_Integration_Status__c = 'Pending';
                objContact.Core_AGS_Integration_Status__c = 'Pending';
                update objContact;
            }
            System.debug('@RRT contact for pad:'+ContactForPAD);
            if(ContactForPAD != null  && ContactForPAD.Id != null && ContactForPAD.AccountId != null){
                System.debug('@RRT contact for pad inside if:'+ContactForPAD);
                EPUM_ContactEntitlement_Util.updateACR(ContactForPAD);
            }
        }
        
        
        //return false;
        return updated;
    }
    
    /****************************************************************************************************** 
Method Name:        getContactEntitlements
@return  :          List of Contact Entitlement record(s)
@parameters:        <String>sContactIdStr
Description:        This method is used to save entitlement data by passing secondaryContact record ID and list for contact entitlement wrapper record
Added By:           Accenture - AD - 04/13/2020
Modified By: Hema        Date:  04/13/2020     Changes: Initial Version
*******************************************************************************************************/
    public static list<Core_Contact_Entitlement__c> getContactEntitlements(set<Id> setEntitlementId){
        System.debug('getContactEntitlements sContactIdStr::'+sContactIdStr);
        // Get existing Contact Entitlements
        List<Core_Contact_Entitlement__c> lstContactEntitlement = [SELECT Id, Core_Entitlement_Id__c,Core_Status__c, Core_Entitlement_Id__r.Core_Category__c,Core_Entitlement_Id__r.Core_Sub_Category__c ,Core_Entitlement_Id__r.Core_Help_Text__c  , Core_Entitlement_Id__r.Name, Core_Entitlement_Id__r.Core_Display_Name__c, Core_Selected__c
                                                                   FROM Core_Contact_Entitlement__c    
                                                                   WHERE Core_Contact_Id__c = :sContactIdStr and
                                                                   Core_Entitlement_Id__c IN :setEntitlementId 
                                                                   ORDER by Core_Entitlement_Id__r.Core_Category__c,Core_Entitlement_Id__r.Core_Sub_Category__c
                                                                  ];      
        return lstContactEntitlement;
    }
    /****************************************************************************************************** 
Method Name:        populateEntitlements
@return  :          List of Contact Entitlement Wrapper record(s)
@parameters:        list<Core_Entitlement__c> lstCoreEntitlements, String sContactId
Description:        This method is used to populate entitlement into Wrapper Class
Added By:           Accenture - AD - 04/13/2020
Modified By: Hema        Date:  04/13/2020     Changes: Initial Version
*******************************************************************************************************/
    public static list<EPUM_ContactEntitlement_Wrapper> populateEntitlements(list<Core_Entitlement__c> lstCoreEntitlements){
        Map<String, String> helpText = new Map<String, String>();
        Set<id> setEntitlementId = new Set<id>();
        list<EPUM_ContactEntitlement_Wrapper> lstCoreEntitlementWrap = new list<EPUM_ContactEntitlement_Wrapper>();
        System.debug('populateEntitlements sContactIdStr::'+sContactIdStr);
        
        
        Map<String,EPUM_ContactEntitlement_Wrapper> mapEntIdWithContEntWrap = new Map<String,EPUM_ContactEntitlement_Wrapper>();
        Set<String> setSubCategories = new Set<String>();
        for(Core_Entitlement__c entObj : lstCoreEntitlements){
            if(entObj.Core_Sub_Category__c != null){
                setSubCategories.add(entObj.Core_Sub_Category__c);
            }
        }
        List<Core_Entitlement_SubCategory_HelpText__c> schelp  = [Select Name, Core_Help_Text__c ,Core_SubCategory_Name__c  FROM Core_Entitlement_SubCategory_HelpText__c WHERE Core_SubCategory_Name__c IN :setSubCategories 
                                                                  LIMIT 1000 ];
        for(Core_Entitlement_SubCategory_HelpText__c schelptext: schelp){
            helpText.put(schelptext.Core_SubCategory_Name__c ,schelptext.Core_Help_Text__c ); 
        }
        for(Core_Entitlement__c entObj: lstCoreEntitlements){
            setEntitlementId.add(entObj.Id);    
            //Core_EPUM_ContactEntitlement_Wrapper contEntWrap = new Core_EPUM_ContactEntitlement_Wrapper(entObj,helpText.get(entObj.Core_Sub_Category__c ));
            EPUM_ContactEntitlement_Wrapper contEntWrap = new EPUM_ContactEntitlement_Wrapper(entObj,entObj.Core_Help_Text__c);
            mapEntIdWithContEntWrap.put(entObj.Id,contEntWrap);                 
            lstCoreEntitlementWrap.add(contEntWrap);
        }
        list<Core_Contact_Entitlement__c> lstContEnts = new list<Core_Contact_Entitlement__c>();
        lstContEnts = getContactEntitlements(setEntitlementId);
        if(!lstContEnts.isEmpty()){
            for(Core_Contact_Entitlement__c conEntObj : lstContEnts){
                
                if(mapEntIdWithContEntWrap.containsKey(conEntObj.Core_Entitlement_Id__c)){
                    EPUM_ContactEntitlement_Wrapper contEntWrap = mapEntIdWithContEntWrap.get(conEntObj.Core_Entitlement_Id__c);
                    if(conEntObj.Core_Status__c =='In Progress'|| conEntObj.Core_Status__c=='Pending' ){
                        contEntWrap.readOnly=true;                
                        contEntWrap.status='Processing';                        
                    }
                    contEntWrap.recstatus=conEntObj.Core_Status__c;
                    contEntWrap.isSelected = conEntObj.Core_Selected__c;
                    contEntWrap.ContactEntitlement = conEntObj;
                    mapEntIdWithContEntWrap.put(conEntObj.Core_Entitlement_Id__c,contEntWrap);
                    lstCoreEntitlementWrap.add(contEntWrap);
                }
            }
        }
        return mapEntIdWithContEntWrap.values();        
        
    }
    
    /****************************************************************************************************** 
Method Name:        getCoreEntitlements
@return  :          List of Core Entitlement record(s)
@parameters:        <String>sContactIdStr
Description:        This method is used to save entitlement data by passing secondaryContact record ID and list for contact entitlement wrapper record
Added By:           Accenture - AD - 04/13/2020
Modified By: Hema        Date:  04/13/2020     Changes: Initial Version
*******************************************************************************************************/
    @AuraEnabled
    public static list<Core_Entitlement__c> getEntitlements(){
        return EPUM_ContactEntitlement_Util.getCoreEntitlements();
    }
    public static List<Core_Entitlement__c> getCoreEntitlements() {
        list<Core_Entitlement__c> lstCoreEntitlements = new list<Core_Entitlement__c>();
        User loggedUserInfo = [ SELECT AccountId, ContactId, Core_IPA_One_Partner_Id__c, Contact.Core_IPA_PartnerRole__c FROM User WHERE Id =:userinfo.getUserId() limit 1 ];
        String intelAccountOfPC = loggedUserInfo.AccountId;
        String onePartnerIdOfPC = loggedUserInfo.Core_IPA_One_Partner_Id__c;
        string pcPartnerRoleStr = loggedUserInfo.Contact.Core_IPA_PartnerRole__c;
        final string IPA_PART_PROGRAM_STR = 'Intel Partner Alliance';
        final string ENT_WITH_BENEFITS_RT = 'PRM_EntitlementWithBenefits';
        final string ENT_WITHOUT_BENEFITS_RT = 'PRM_EntitlementWithoutBenefits';
        final string ENT_IPA_EPUM = 'Entitlements for IPA EPUM';
        Integer intTierRank; 
        
        Set<Id> setPartnerBenfitIds = new Set<Id>();
        set<Id> setEntitlementIds = new Set<Id>();
        set<String> setEntitlementNames;
        Set<Id> setPartnerTierIds = new Set<Id>();
        List<EPUM_ContactEntitlement_Wrapper> lstEntitlementWrapper = new List<EPUM_ContactEntitlement_Wrapper>();
        //Get Partner Tier Information at one partner ID level
        System.debug('--onePartnerIdOfPC--'+onePartnerIdOfPC);
        System.debug('--intelAccountOfPC--'+intelAccountOfPC);
        System.debug('--IPA_PART_PROGRAM_STR--'+IPA_PART_PROGRAM_STR);
        for (PRM_AccountChannelMembership__c acmObj :[ SELECT PRM_Channel_Program_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c,PRM_Channel_Program_Level_Id__r.Rank
                                                      FROM PRM_AccountChannelMembership__c 
                                                      WHERE PRM_Status_Nm__c = 'Approved' and 
                                                      PRM_Partner_Role__c =: pcPartnerRoleStr and
                                                      (PRM_Account_Id__c =:onePartnerIdOfPC or 
                                                       PRM_Account_Id__c =:intelAccountOfPC) and 
                                                      PRM_Channel_Program_Id__r.Name =:IPA_PART_PROGRAM_STR 
                                                      ORDER BY PRM_Channel_Program_Level_Id__r.Rank DESC LIMIT 1] ) {
                                                          System.debug('----acmObj-----'+acmObj);
                                                          String tierCode = acmObj.PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c; 
                                                          intTierRank = acmObj.PRM_Channel_Program_Level_Id__r.Rank;
                                                          setPartnerTierIds.add(acmObj.PRM_Channel_Program_Level_Id__c);
                                                      }
        
        System.debug('---setPartnerTierIds---'+setPartnerTierIds);
        //If one partner Id belong to non member tier
        if(setPartnerTierIds.size() > 0){
            //Get Partner Benefits information at one partner Id level // PRM_Source__c ='Tier' and need to be added later
            for (PRM_AccountBenefitAssociation__c abaObj : [SELECT PRM_Partner_Benefit_Id__c  
                                                            FROM PRM_AccountBenefitAssociation__c 
                                                            WHERE PRM_Status_Nm__c = 'Active'
                                                            and PRM_Account_Id__c != null and
                                                            (PRM_Account_Id__c =:onePartnerIdOfPC or 
                                                             PRM_Account_Id__c =:intelAccountOfPC)
                                                            LIMIT 1000 
                                                           ] ) {
                                                               setPartnerBenfitIds.add(abaObj.PRM_Partner_Benefit_Id__c);
                                                           }
            Set<Id> setNonPrimaryRelationshipIds = new Set<Id>();
            for(PRM_ContactRelationships__c rel : [
                SELECT Id 
                FROM PRM_ContactRelationships__c 
                WHERE PRM_Contact_Relationship_Cd__c != 'PRIMARY' 
                AND PRM_InActive_Ind__c = false
            ]){
                setNonPrimaryRelationshipIds.add(rel.Id);
            }
            System.debug('setPartnerBenfitIds$$$$'+setPartnerBenfitIds);
            //Verify if Account have benefits, If benefit exists then 
            if (setPartnerBenfitIds.size()>0) {
                //If  benefits then entitlements are based on Benefits , Partner Role , Tier and Contact Relationship
                //Find benefit Id from benefit Matrix table
                //Commented by Manikanta To remove dependency on benefit matrix-US860385
                /*set<Id> setBenefitIds = new set<Id>();
for(PRM_VXBnftMatrix__c benefitMatrixObj : [SELECT PRM_Partner_Benefit_Id__c FROM PRM_VXBnftMatrix__c 
WHERE PRM_IsActive_Ind__c = true and 
PRM_Partner_Role_Nm__c =: pcPartnerRoleStr and 
PRM_Channel_Program_Id__r.Name =: IPA_PART_PROGRAM_STR and 
//PRM_Channel_Program_Level_Id__c =: setPartnerTierIds and 
PRM_Channel_Program_Level_Id__r.Rank <=: intTierRank and
PRM_Partner_Benefit_Id__c IN: setPartnerBenfitIds 
LIMIT 1000
]){
setBenefitIds.add(benefitMatrixObj.PRM_Partner_Benefit_Id__c);                                                                    
}  
System.debug('---setBenefitIds241---'+setBenefitIds);*/
                for (PRM_VXEnttlmntMatrix__c entitleMatrixObj : [SELECT PRM_Entitlement_Id__c 
                                                                 FROM PRM_VXEnttlmntMatrix__c 
                                                                 WHERE PRM_Approval_Type_Nm__c = 'Manual' and
                                                                 PRM_IsActive_Ind__c = true and
                                                                 PRM_Partner_Benefit_Id__c IN: setPartnerBenfitIds and 
                                                                 PRM_IPA_Partner_Role_Nm__c =:pcPartnerRoleStr and
                                                                 RecordType.DeveloperName =:ENT_WITH_BENEFITS_RT and 
                                                                 PRM_Contact_Relationship_Id__c IN :setNonPrimaryRelationshipIds]){
                                                                     setEntitlementIds.add(entitleMatrixObj.PRM_Entitlement_Id__c);
                                                                 }
                System.debug('---setEntitlementIds---'+setEntitlementIds);
                
            }
            else{
                //If no benefits then entitlements are based on Partner Role , Tier and Contact Relationship
                for (PRM_VXEnttlmntMatrix__c entitleMatrixObj : [SELECT PRM_Entitlement_Id__c FROM PRM_VXEnttlmntMatrix__c 
                                                                 WHERE PRM_Approval_Type_Nm__c = 'Manual' and
                                                                 PRM_Contact_Relationship_Id__c IN :setNonPrimaryRelationshipIds and
                                                                 PRM_IsActive_Ind__c = true and
                                                                 PRM_IPA_Partner_Role_Nm__c =:pcPartnerRoleStr and
                                                                 //PRM_Channel_Program_Level_Id__c IN: setPartnerTierIds and
                                                                 PRM_Channel_Program_Level_Id__r.Rank <=: intTierRank and
                                                                 RecordType.DeveloperName =:ENT_WITHOUT_BENEFITS_RT]){
                                                                     setEntitlementIds.add(entitleMatrixObj.PRM_Entitlement_Id__c);
                                                                 }  
                System.debug('---setEntitlementIds else---'+setEntitlementIds);
                
            }
        }
        //}
        setEntitlementNames = new Set<String>();
        //fetch the entitlements details based on segments
        for (Core_Entitlement_Profile_Access__c epa :[SELECT Core_Entitlements_Allowed__c FROM Core_Entitlement_Profile_Access__c 
                                                      WHERE Name =:ENT_IPA_EPUM ]){
                                                          String[] names = (epa.Core_Entitlements_Allowed__c).split(';');                                    
                                                          setEntitlementNames.addAll(names);                                 
                                                      }
        System.debug('---setEntitlementNames--'+setEntitlementNames+'---setEntitlementIds--'+setEntitlementIds);
        lstCoreEntitlements =   [SELECT Name, Core_Display_Name__c,Id,Core_Sub_Category__c, Core_Help_Text__c,Core_Category__c 
                                 FROM Core_Entitlement__c
                                 WHERE Id IN: setEntitlementIds OR
                                 Core_Display_Name__c IN: setEntitlementNames 
                                 ORDER BY Core_Category__c,Core_Sub_Category__c 
                                 LIMIT 50000
                                ];
        System.debug('-----lstCoreEntitlements280---'+lstCoreEntitlements);
        return lstCoreEntitlements;
    }
    
    //String Constant for Error Message
    private static final string  ERROR_MESSAGE = 'Error Message From Apex: ';
    private static final string  PENDING_STATUS = 'Pending';
    
    /****************************************************************************************************** 
Method Name:        checkAGSStatus
@return  :          EPUM_AuraProcessingMessage record(s)
Description:        This method is used check the AGS status on contact object
Added By:           Accenture - AD - 04/13/2020
Modified By: Hema        Date:  04/13/2020     Changes: Initial Version
*******************************************************************************************************/    
    public static EPUM_AuraProcessingMessage checkAGSStatus(){
        System.debug('objContact::'+objContact);
        //Initializing the wrapper message 
        EPUM_AuraProcessingMessage returnMessage = new EPUM_AuraProcessingMessage();
        
        System.debug('checkAGSStatus : objContact.Core_AGS_Integration_Status__c ====> ' + objContact.Core_AGS_Integration_Status__c);
        
        if(objContact.Core_AGS_Integration_Status__c != PENDING_STATUS){
            try{
                String strAGSResponse = Core_HttpCallouts_Handler.getUpdatedAGSStatus(objContact);
                System.debug('checkAGSStatus : strAGSResponse ===>'+ strAGSResponse);
                if(!String.isBlank(strAGSResponse) && strAGSResponse == 'NoResponse'){
                    // blnIsValid = false;
                }
            }catch(Exception ex) {
                
                system.debug('Debug Exception Message = '+ ex.getMessage());
                returnMessage.isSuccess = false;
                //Adding the error message if an exception is occured
                returnMessage.errorMsg = ERROR_MESSAGE + ex.getMessage();
            }
            
        }
        return returnMessage;
    }
    /*Method : getContactWithRoles
* 
*/
    @AuraEnabled
    public static list<contact> getContactsWithRole(){
        User loggedUserInfo = [ SELECT AccountId, Core_IPA_One_Partner_Id__c, Contact.Core_IPA_PartnerRole__c 
                               FROM User
                               WHERE Id =:userinfo.getUserId() limit 1 ];
        String intelAccountOfPC = loggedUserInfo.AccountId;
        String onePartnerIdOfPC = loggedUserInfo.Core_IPA_One_Partner_Id__c ;
        String partnerRoleIStr  = loggedUserInfo.Contact.Core_IPA_PartnerRole__c;
        //list<Core_Entitlement__c> lstEntitlements = EPUM_ContactEntitlement_Util.getCoreEntitlements();
        String query = 'SELECT Id,Name,phone,(SELECT Core_Contact_Id__c,Core_Entitlement_Id__r.Core_Display_Name__c,Core_Entitlement_Id__c FROM Contact_Entitlements__r WHERE Core_Selected__c =true AND Core_Status__c =\'Complete\' and Core_Category__c=\'Intel Partner Alliance (IPA)\'),(SELECT Id , PRM_Contact_Id__c,PRM_Relationship_Id__r.Name,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c FROM Account_Contact_Relationships__r WHERE PRM_Status_Nm__c =\'Complete\' and  PRM_InActive_Ind__c = false) FROM Contact WHERE Core_IPA_PartnerRole__c =:partnerRoleIStr and';
        query += '( AccountID =:intelAccountOfPC';
        if(onePartnerIdOfPC != null && onePartnerIdOfPC !='')
            query += ' OR Core_IPA_One_Partner_Id__c  =:onePartnerIdOfPC'; 
        query+=')';
        
        return Database.query(query);
    }
    public static user getUserInformation(){  
        return [SELECT AccountId, ContactId,Profile.Name,Core_IPA_One_Partner_Id__c, Contact.Core_IPA_PartnerRole__c   
                FROM User  
                WHERE Id =:userinfo.getUserId() limit 1 ];  
    }
    
    @AuraEnabled(cacheable=true)  
    public static list<String> getAvailableRoles(){  
        user loggedUserInfo = EPUM_ContactEntitlement_Util.getUserInformation();  
        list<Core_Entitlement__c> lstCoreEntitlements = EPUM_ContactEntitlement_Util.getCoreEntitlements();  
        list<contact> lstContactsWithRole = EPUM_ContactEntitlement_Util.getContactsWithRole();  
        set<String> rolesTaken = new set<String>();  
        set<String> setAvailableRoles = new set<String>();  
        String loggedInContactId = loggedUserInfo.ContactId;  
        for ( contact con : lstContactsWithRole ) {  
            if ( loggedInContactId == con.Id ){  
                for ( PRM_Account_Contact_Relationship__c acr : con.Account_Contact_Relationships__r ) {  
                    if ( acr.PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c != 'WORKSFOR' ) {  
                        setAvailableRoles.add(acr.PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);  
                    }  
                }  
            }  
            for ( Core_Contact_Entitlement__c ce : con.Contact_Entitlements__r ){  
                rolesTaken.add(ce.Core_Entitlement_Id__r.Core_Display_Name__c);  
            }  
        }  
        for (Core_Entitlement__c ent : lstCoreEntitlements ){  
            if ( !rolesTaken.contains(ent.Core_Display_Name__c) ){  
                setAvailableRoles.add(ent.Core_Display_Name__c);  
            }  
        }  
        list<String> lstAvailableRoles = new list<String>();  
        lstAvailableRoles.addAll(setAvailableRoles);  
        return lstAvailableRoles;  
    }
    
    @AuraEnabled(cacheable=true)
    public static String getLogoUrl(){  
        user loggedUserInfo = EPUM_ContactEntitlement_Util.getUserInformation();
        String strApproved = 'Approved';
        String strProgram = 'Intel Partner Alliance';
        String tierName = '';
        String accId = '';
        if(loggedUserInfo != null && loggedUserInfo.Core_IPA_One_Partner_Id__c !='' && loggedUserInfo.Core_IPA_One_Partner_Id__c != null){
            accId = loggedUserInfo.Core_IPA_One_Partner_Id__c;
        }else{
            accId = loggedUserInfo.AccountId;
        }
        if(accId != ''){
            List<PRM_AccountChannelMembership__c> acmObj = [SELECT PRM_Channel_Program_Id__r.Name,PRM_Channel_Program_Level_Id__r.Name 
                                                            FROM PRM_AccountChannelMembership__c 
                                                            WHERE PRM_Channel_Program_Id__r.Name =: strProgram 
                                                            AND PRM_Account_Id__c=:accId 
                                                            AND PRM_Partner_Role__c =: loggedUserInfo.Contact.Core_IPA_PartnerRole__c 
                                                            AND PRM_Status_Nm__c =: strApproved  
                                                            ORDER BY PRM_Channel_Program_Level_Id__r.Rank DESC LIMIT 1];
            if(acmObj.size() > 0){
                tierName = (String)acmObj[0].PRM_Channel_Program_Level_Id__r.Name; 
            }
        }        
        return tierName;
    }
    
    @AuraEnabled(cacheable=true)  
    public static String getResponsibilitiesConfirmationData(){
        PRM_ResponsibilitiesDataWrapper responsibilitesDataWrapper = new PRM_ResponsibilitiesDataWrapper();
        responsibilitesDataWrapper.title = System.Label.EPUM_VerifyrolesandrespTitle;
        responsibilitesDataWrapper.imageUrl = getLogoUrl();
        String roleName = '';
        
        List<PRM_ResponsibilitiesDataWrapper.cls_tableData> tableData = new List<PRM_ResponsibilitiesDataWrapper.cls_tableData>();
        //tableData.add(new PRM_ResponsibilitiesDataWrapper.cls_tableData(true, System.Label.EPUM_Responsibilities, System.Label.EPUM_Employee));
        
        System.debug('getAvailableRoles'+getAvailableRoles());
        
        for(String role : getAvailableRoles()) {
            String empName = System.Label.EPUM_Open;
            if (role == 'PRIMARY') {
                roleName = 'Partner Admin';
                empName = UserInfo.getName() + ' ('+ System.Label.EPUM_You +')';
                tableData.add(new PRM_ResponsibilitiesDataWrapper.cls_tableData(true, roleName, empName));
            } else if (role == 'PRIMCONTDEL') {
                roleName = 'Partner Admin Delegate';
                empName = UserInfo.getName() + ' ('+ System.Label.EPUM_You +')';
                tableData.add(new PRM_ResponsibilitiesDataWrapper.cls_tableData(true, roleName, empName));
            } else {
                tableData.add(new PRM_ResponsibilitiesDataWrapper.cls_tableData(false, role, empName));
            }
        }
        
        responsibilitesDataWrapper.tableData = tableData;
        
        String stepMessage = System.Label.EPUM_RolesResPopupMsg.replace('{role}',roleName);
        responsibilitesDataWrapper.content.add(new PRM_ResponsibilitiesDataWrapper.cls_content(RICHTEXT,stepMessage));
        PRM_ResponsibilitiesDataWrapper.cls_closeModalAndRedrirectLinkData closeModalAndRedrirectLinkData = new PRM_ResponsibilitiesDataWrapper.cls_closeModalAndRedrirectLinkData();
        closeModalAndRedrirectLinkData.label = System.Label.EPUM_Close;
        closeModalAndRedrirectLinkData.externalUrl = System.Label.EPUM_Manage_Personnel;//'#closeFormAndRedirectLinkData';
        responsibilitesDataWrapper.closeModalAndRedrirectLinkData = closeModalAndRedrirectLinkData;
        
        PRM_ResponsibilitiesDataWrapper.cls_footerLinkData footerLinkData = new PRM_ResponsibilitiesDataWrapper.cls_footerLinkData();
        footerLinkData.label = System.Label.EPUM_ManagePersonnel;
        footerLinkData.externalUrl = System.Label.PRM_EPUM_Redirect_Link;
        footerLinkData.communityPage = '';
        //footerLinkData.communityPage = 'manage_personnel__c';
        footerLinkData.objectPage = '';
        footerLinkData.recordId = '';
        responsibilitesDataWrapper.footerLinkData = footerLinkData;
        
        return JSON.serialize(responsibilitesDataWrapper);
    }
    
    public static void updateACR(Contact contid){
        
        System.debug('@RRT contid'+contid);
        String STR_ELIGIBLE_ENTITLEMENT = 'Partner Admin Delegate';
        
        Id contactid = contid.Id;
        // Step 1: Get the Relationship Id safely
        List<PRM_ContactRelationships__c> rels = [SELECT Id FROM PRM_ContactRelationships__c WHERE Name = :STR_ELIGIBLE_ENTITLEMENT AND PRM_InActive_Ind__c = false LIMIT 1];
        
        if(rels.isEmpty()){
            System.debug('PAD relationship metadata not found for ' + STR_ELIGIBLE_ENTITLEMENT);
            return; // Exit safely if metadata missing
        }
        
        Id relationId = rels[0].Id;
        
        
        List<PRM_Account_Contact_Relationship__c> existingContEnt = [SELECT id,PRM_Contact_Id__c,PRM_Relationship_Id__c,PRM_Relationship_Id__r.name,PRM_Status_Nm__c,PRM_Start_Date_Dt__c,PRM_InActive_Ind__c,PRM_Status_Reason_Txt__c FROM PRM_Account_Contact_Relationship__c WHERE /*PRM_Relationship_Id__r.name = :STR_ELIGIBLE_ENTITLEMENT*/ PRM_Relationship_Id__c = :relationId AND PRM_Contact_Id__c = :contactid];
        
        //Id RelationId= [SELECT Id FROM PRM_ContactRelationships__c WHERE name = :STR_ELIGIBLE_ENTITLEMENT AND PRM_InActive_Ind__c = false LIMIT 1].Id;
        
        /*for(PRM_ContactRelationships__c pcr : [SELECT Id FROM PRM_ContactRelationships__c WHERE name =: STR_ELIGIBLE_ENTITLEMENT AND PRM_InActive_Ind__c = false LIMIT 1]){
RelationId = pcr.id;
}*/
        System.debug('@RRT existingContEnt'+existingContEnt);
        list<PRM_Account_Contact_Relationship__c> acrForPAD = new list<PRM_Account_Contact_Relationship__c>();
        
        if(existingContEnt != null && !existingContEnt.isEmpty()){
            for(PRM_Account_Contact_Relationship__c acr : existingContEnt){
                if(acr.PRM_InActive_Ind__c == true){
                    acr.PRM_Status_Nm__c = 'Complete';
                    acr.PRM_InActive_Ind__c = false;
                    acr.PRM_Start_Date_Dt__c = Date.today();
                    acr.PRM_Status_Reason_Txt__c = 'ACR activated due to assignment of PAD from Manage personnel';
                }
                acrForPAD.add(acr);
            }
        }
        else{
            acrForPAD.add(new PRM_Account_Contact_Relationship__c (
                PRM_Account_Id__c = contid.AccountId,
                PRM_Contact_Id__c = contid.Id,
                PRM_Relationship_Id__c =  relationId,
                PRM_Status_Reason_Txt__c = 'ACR activated due to assignment of PAD from Manage personnel',
                PRM_Start_Date_Dt__c = Date.today(),
                PRM_Status_Nm__c = 'Complete'
            ));
        }
        System.debug('@RRT acrForPAD'+acrForPAD);
        
        if(!acrForPAD.isEmpty()){
            
            Database.UpsertResult[] results = Database.upsert(acrForPAD, false);
        }                
    }
}