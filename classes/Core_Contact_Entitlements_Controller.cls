public without sharing class Core_Contact_Entitlements_Controller {
    
    //Start---added code For Validation from Custom setting
    
    public String userInput{get;set;} 
    public static List<Core_Contact_Entitlement_Validation__c> lstconentval = Core_Contact_Entitlement_Validation__c.getall().values();
    public static Map<Id,Core_Contact_Entitlement_Validation__c> mapentIds = new Map<Id,Core_Contact_Entitlement_Validation__c>();
    public static List<Core_Contact_Ent_Validation_Message__c> lstConentValErrorMsg = Core_Contact_Ent_Validation_Message__c.getall().values();
    public static Map<String,String> mapConentValErrorMsg = new Map<String,String>();
    static {
        system.debug('lstconentval ::'+lstconentval);
        for(Core_Contact_Entitlement_Validation__c csvalidation:lstconentval){
            mapentIds.put(csvalidation.Core_Entitlement_Id__c,csvalidation);
        }
        for(Core_Contact_Ent_Validation_Message__c validationErrorMsg:lstConentValErrorMsg){
            String errormessage2='';
            if(validationErrorMsg.Core_Error_Message2__c!=null){
                errormessage2=validationErrorMsg.Core_Error_Message2__c;
            }
            mapConentValErrorMsg.put(validationErrorMsg.Name,validationErrorMsg.Core_Error_Message__c+errormessage2);
        }
        system.debug('mapentIds ::'+ mapentIds);
        system.debug('mapConentValErrorMsg ::'+ mapConentValErrorMsg);
        /*for(String mapContentValError : mapConentValErrorMsg.values()){
            System.debug('mapContentValError = '+ mapContentValError);
        }*/
        
    }
    //End----
    
    public Boolean blnIsValid { get; set; }
    // public Boolean blnHasAccess { get; set; }
    public String  strContactName { get; set; }
    public String subordinateEntName { get; set; }
    public Integer limitRows{ get; set; }
    public Map<String, String> CategoryColumnName{get;set;} 
    public String disabledEntitlement{get;set;}
    public String disabledEntitlement2{get;set;}
    public Map<String,Boolean> readOnlyEntitlement{get;set;}
    public Map<String,String> entitlementStatus{get;set;}
    public Map<String,String> entitlementEighteenDigStatus{get;set;}
    public List<List<Core_Entitlement_Wrapper>> lstlstEntitlementWrapper { get; set; }
    public List<List<Core_Entitlement_Wrapper>> lstlstSearchEntitlementWrapper { get; set; }
    public Boolean isShowSearchResults { get; set; }
    public Boolean isNotExist { get; set; }
    public String disableIPSEntitlement{get;set;}
    
    public String strReturnURL;
    public Id idContact{get;set;}
    
    private String strAccountName;
    private Boolean iSIpaAccount=false;
    
    private List<Core_Entitlement__c> lstEntitlement;
    private List<Core_Contact_Entitlement__c> lstConEnt;
    private Map<Id, Core_Contact_Entitlement__c> mapConEnt;
    
    private List<Core_Entitlement_Wrapper> lstEntitlementWrapper;
    private Contact objContact;
    
    private final String UPDATE_REASON_GRANT_ACCESS = 'Grant Access';
    
    
    public Core_Contact_Entitlements_Controller(String contactId) {
        idContact    = contactId;
         
        objContact = [SELECT Id, Name,FirstName,LastName,Core_Enterprise_Id__c, AccountId, Account.Name, Account.Core_CNDA_Number__c, Account.Core_IPS_Active__c,
                      Core_IPS_Intel_Support_Owner__c, Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c,Account.Owner.UserRole.Name,
                      Account.Core_IsODM__c, Core_Set_ERPM_Status_Bypass__c, Account.Core_CIM_ID__c, Core_Personal_Email_Indicator__c,
                      Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c,Account.Core_English_Only_Name__c,Core_Local_Last_Name__c,Core_Local_First_Name__c,Account.Core_Alternate_Language_Name__c,Account.Core_Deactivated__c,Account.Core_Deactivation_Reason__c,Core_AGS_Republish_Ind__c 
                      FROM Contact 
                      WHERE Id = :idContact 
                      LIMIT 1];
    }
    
    public Core_Contact_Entitlements_Controller() {
    }
    
    public Core_Contact_Entitlements_Controller(ApexPages.StandardController controller) {
        
        isShowSearchResults = false;
        isNotExist = false;
        lstlstSearchEntitlementWrapper = new List<List<Core_Entitlement_Wrapper>>();
        idContact    = ApexPages.currentPage().getParameters().get('Id');
        strReturnURL = '//' + idContact;
        //Disabled Entitlement checkbox on the page
        disabledEntitlement=Label.Core_Entitlement_Disable_Grant_Access;
        disabledEntitlement2=Label.Entitlement_Disable_Grant_Access2;
        disableIPSEntitlement = Label.Core_IPS_Org_Wide_Email_Display_Name;
        Set<Id> validatedIds = new Set<Id>();
        
        objContact = [SELECT Id, Name,FirstName,LastName,Core_Enterprise_Id__c, AccountId, Account.Name,Account.Core_Intel_Partner_Alliance_PartnerGroup__c, Account.Core_CNDA_Number__c, Account.Core_IPS_Active__c,
                      Core_IPS_Intel_Support_Owner__c, Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c,Account.Owner.UserRole.Name,
                      Account.Core_IsODM__c, Core_Set_ERPM_Status_Bypass__c, Account.Core_CIM_ID__c, Core_Personal_Email_Indicator__c,
                      Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c,Account.Core_English_Only_Name__c,Core_Local_Last_Name__c,Core_Local_First_Name__c,Account.Core_Alternate_Language_Name__c,Account.Core_Deactivated__c,Account.Core_Deactivation_Reason__c 
                      FROM Contact 
                      WHERE Id = :idContact 
                      LIMIT 1];                
        
        /* if (objContact.AccountId == NULL) {
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'Contact must be assigned to an Account.');
ApexPages.addMessage(myMsg);data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAPCAYAAADd/14OAAAA40lEQVQoz2P4//8/AzpWzGj6L59U/V8urgxMg/g4FUn6J/+X9E38LxWc8V8htR67IpCkuGfMfxCQjSpENRFFkXvk/1+/foGxQloDSD0DVkVfvnyBY7hCdEVv3rxBwXCFIIdKh2WDFT1+/BgDo1qd2fL/1q1bWDFcoW5xz3/Xppn/oycu/X/x4kUMDFeoWdD136R8wn+f9rlgxSdOnEDBKFajK96/fz8coyjEpnj79u1gjKEQXXFE/+L/Gzdu/G9WMfG/am4HZlzDFAf3LPwfOWEJWBPIwwzYUg9MsXXNFDAN4gMAmASShdkS4AcAAAAASUVORK5CYII=
blnIsValid = false;

// Cannot access account fields - RETURN
return;
}    */    
        
        strContactName = objContact.Name;
        strAccountName = objContact.Account.Name;
        iSIpaAccount = objContact.Account.Core_Intel_Partner_Alliance_PartnerGroup__c;
        
        User currentuser=[Select Id,ProfileId,Name from User where Id=:userinfo.getuserId()];
        Id profileId=currentuser.ProfileId;
        
        Core_Test_Utility.checkRecordEditAccess(UserInfo.getUserId(), new Set<Id>{objContact.AccountId}, validatedIds);
         
       //Based on US455570(Modify IPA A&E User Profile for Uncovered Accounts), modified by Ankit Kumar Thakur
        if(validatedIds.size() == 0 && profileId == Label.Core_IPA_AE_Profile_Id && iSIpaAccount == true){
            validatedIds.add(objContact.AccountId);
        }
        blnIsValid = true;
         
        if (validatedIds.size() == 0) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, mapConentValErrorMsg.get('UI Account Team Access'));
            ApexPages.addMessage(myMsg);
            blnIsValid = false;            
        } 
        
        if(objContact.Core_Set_ERPM_Status_Bypass__c) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, mapConentValErrorMsg.get('UI Initial ERPM Response'));
            ApexPages.addMessage(myMsg);
            blnIsValid = false;
        }
        if(objContact.Account.Core_Deactivated__c && objContact.Account.Core_Deactivation_Reason__c!=null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, mapConentValErrorMsg.get('UI Account Deactive')+objContact.Account.Core_Deactivation_Reason__c );
            ApexPages.addMessage(myMsg);
            blnIsValid = false;
        }
        
        //System.debug('objContact.Core_Set_ERPM_Status_Bypass__c '+objContact.Core_Set_ERPM_Status_Bypass__c);        
    }
    
    public List<Core_Entitlement__c> filterEntitlementsByProfile() {
        Boolean entCheck = false;
        String userProfileId = UserInfo.getProfileId();
        userProfileId = userProfileId.substring(0, userProfileId.length()-3);
        String UserId = UserInfo.getUserId();
        List<String> lEntNames = new List<String>();
        List<String> lEntNames1 = new List<String>();      
        List<User> audienceUserList = new List<User>();
        List<Contact> audienceContactList = new List<Contact>();     
        List<Core_Entitlement_Profile_Access__c> epaObj = new List<Core_Entitlement_Profile_Access__c>();        
        String PARTNER_PROFILE_ID = Label.Core_Partner_Profile_Id; 
        //String PARTNER_PROFILE_ID = '';
        
        if(userProfileId.equals(PARTNER_PROFILE_ID)) //For external users
        {
            system.debug('UserId : ' +UserId);
            
            /*audienceUserList = [Select ContactId From User Where Id =: UserId];
            system.debug('audienceUserList='+audienceUserList);
            if(audienceUserList[0] != null && audienceUserList[0].ContactId != null){
              audienceContactList = [Select Id, Core_Audience__c From Contact where Id =: audienceUserList[0].ContactId];
                system.debug('audienceContactList : '+audienceContactList);
            }
            
            System.debug('audienceUserList : '+ audienceUserList);
            System.debug('audienceContactList : '+ audienceContactList);
                        
            List<String> contactAudiences = new List<String> ();
            for(Contact contactRec: audienceContactList){
                if(contactRec.Core_Audience__c != null){
                   contactAudiences = contactRec.Core_Audience__c.split(';');
                }   
            }
            system.debug('contactAudiences : '+contactAudiences);*/
            
            /******************************Draco : Remove dependency from Audience - START*************************************/
            List<User> userContactId = new List<User>();
            List<Core_Contact_Entitlement__c> lstContEnt = new List<Core_Contact_Entitlement__c>();
            List<String> lstOfEnt = new List<String> ();
            
            userContactId = [Select ContactId,Email,name From User Where Id =: UserId];
            if(userContactId[0] != null && userContactId[0].ContactId != null){
                lstContEnt = [select Core_Entitlement_Id__r.name,Core_Entitlement_Nm__c from Core_Contact_Entitlement__c where Core_Contact_Id__c =: userContactId[0].ContactId and Core_Selected__c = true and Core_Status__c = 'Complete'];
            }
            for(Core_Contact_Entitlement__C contEnt : lstContEnt){
                if(contEnt.Core_Entitlement_Nm__c != null){
                    lstOfEnt.add(contEnt.Core_Entitlement_Nm__c) ;                        
                }
            }
            if(lstOfEnt != null && !lstOfEnt.isEmpty()){
               epaObj = [Select id, Core_Entitlements_Allowed__c from Core_Entitlement_Profile_Access__c 
                          where Core_Profile_Id__c = :userProfileId and Core_User_Type__c in :lstOfEnt]; 
            }
            /******************************Draco : Remove dependency from Audience - END *************************************/
            
            /*if(contactAudiences != null && !contactAudiences.isEmpty()){
                System.debug('userProfileId = '+ userProfileId); //15-digit id
                System.debug('contactAudiences = '+ contactAudiences);
                epaObj = [Select id, Core_Entitlements_Allowed__c from Core_Entitlement_Profile_Access__c 
                          where Core_Profile_Id__c = :userProfileId and Core_User_Type__c in :contactAudiences];
            }*/
            system.debug('epaObj1='+epaObj);
            if(epaObj != null && !epaObj.isEmpty()) {
                entCheck = String.isBlank(epaObj[0].Core_Entitlements_Allowed__c);
            } else {
                entCheck = true;
            }
            
            if(epaObj != null && !epaObj.isEmpty() && !entCheck) {
                for(Core_Entitlement_Profile_Access__c epaObjRec : epaObj){
                    System.debug('1. lEntNames = '+ lEntNames);
                    if(epaObjRec.Core_Entitlements_Allowed__c != null){
                        lEntNames1= epaObjRec.Core_Entitlements_Allowed__c.split(';');
                        lEntNames.addall(lEntNames1);
                    }
                    system.debug('2. lEntNames = '+ lEntNames );
                }
                lstEntitlement = [SELECT Id, Core_Category__c,Core_Sub_Category__c ,Core_Help_Text__c  , Name, Core_Display_Name__c
                                  FROM Core_Entitlement__c
                                  WHERE Core_IsActive__c = true
                                  AND Name IN :lEntNames order by Core_Category__c,Core_Sub_Category__c ];
            }

        }
        else{ // for internal users - existing code
            epaObj = [Select id, Core_Entitlements_Allowed__c from Core_Entitlement_Profile_Access__c where Core_Profile_Id__c = :userProfileId];
            System.debug('epaObj - ' + epaObj);
            if(epaObj != null && !epaObj.isEmpty()) {
                entCheck = true;
                for(Core_Entitlement_Profile_Access__c entProfileAccess: epaObj){
                    if(entCheck){
                        entCheck = String.isBlank(entProfileAccess.Core_Entitlements_Allowed__c);
                    }
                }
            } else {
                entCheck = true;
            }
            if(epaObj != null && !epaObj.isEmpty() && !entCheck) {
                System.debug(lEntNames);
                 // -------- US760479 (issue for number of entitlements selected for visibility on GA page) -------
                for(Core_Entitlement_Profile_Access__c entProfileAccess: epaObj){
                    if(!String.isBlank(entProfileAccess.Core_Entitlements_Allowed__c)){
                        for(String entAllowed: entProfileAccess.Core_Entitlements_Allowed__c.split(';')){
                            lEntNames.add(entAllowed);
                        }
                    }
                }
                // -------- US760479 (issue for number of entitlements selected for visibility on GA page) -------
            }
            system.debug('lEntNames '+lEntNames );
            lstEntitlement = [SELECT Id, Core_Category__c,Core_Sub_Category__c ,Core_Help_Text__c  , Name, Core_Display_Name__c
                              FROM Core_Entitlement__c
                              WHERE Core_IsActive__c = true
                              AND Name IN :lEntNames order by Core_Category__c,Core_Sub_Category__c ];
             
            
        }
        return lstEntitlement;
        
    }
    
    public PageReference onPageLoad() {
        
        if (!blnIsValid) 
            return NULL;
        // Call AGS for updated AGS roles before loading the page  
        System.debug('===Lalitha==AGS Status====>'+objContact.Core_AGS_Integration_Status__c);
        if(objContact.Core_AGS_Integration_Status__c != 'Pending'){
            try{
                String strAGSResponse = Core_HttpCallouts_Handler.getUpdatedAGSStatus(objContact);
                System.debug('===lalitha===strAGSResponse==in controller===>'+strAGSResponse);
                if(!String.isBlank(strAGSResponse) && strAGSResponse == 'NoResponse'){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, mapConentValErrorMsg.get('UI Read Time Out')+'<a href="./Core_Contact_Entitlements?scontrolCaching=1&id='+idContact+'"><B>Reload</B></a>'+'<br/>System Error: No response from AGS.');
                    ApexPages.addMessage(myMsg);  
                    blnIsValid = false;
                }
            }catch(Exception e) {
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, mapConentValErrorMsg.get('UI Read Time Out')+'<a href="./Core_Contact_Entitlements?scontrolCaching=1&id='+idContact+'"><B>Reload</B></a>'+'<br/>System Error: '+e.getMessage());
                ApexPages.addMessage(myMsg);
                blnIsValid = false;
                
            }
            
        }
        //lstEntitlement = [SELECT Id, Core_Category__c, Name, Core_Display_Name__c
        //FROM Core_Entitlement__c
        //WHERE Core_IsActive__c = true];  */
        
        
        filterEntitlementsByProfile();
        populateEntitlementWrapper();          
        
        return NULL;
    }
    
    public class MyException extends Exception {}

    //String Constant for Error Message
    private static final string  ERROR_MESSAGE = 'Error Message From Apex: ';
    private static final string  PENDING_STATUS = 'Pending';
        
    public Core_AuraProcessingMessage checkAGSStatus(){
        
        //Initializing the wrapper message 
        Core_AuraProcessingMessage returnMessage = new Core_AuraProcessingMessage();
        
        System.debug('checkAGSStatus : objContact.Core_AGS_Integration_Status__c ====> ' + objContact.Core_AGS_Integration_Status__c);
        
        if(objContact.Core_AGS_Integration_Status__c != PENDING_STATUS){
            try{
                String strAGSResponse = Core_HttpCallouts_Handler.getUpdatedAGSStatus(objContact);
                System.debug('checkAGSStatus : strAGSResponse ===>'+ strAGSResponse);
                if(!String.isBlank(strAGSResponse) && strAGSResponse == 'NoResponse'){
                    blnIsValid = false;
                }
                //throw new MyException('AGS failure');
            }catch(Exception ex) {
                
                system.debug('Debug Exception Message = '+ ex.getMessage());
                returnMessage.isSuccess = false;
                //Adding the error message if an exception is occured
                returnMessage.errorMsg = ERROR_MESSAGE + ex.getMessage();
                //throw new AuraHandledException( 'Yor Error Message ==> '+ ex);
                blnIsValid = false;
            }
            
        }
        return returnMessage;
    }
    
    public List<Core_Entitlement_Wrapper> populateEntitlementWrapper(){
        // And Entitlements into a display wrapper                         
        lstEntitlementWrapper    = new List<Core_Entitlement_Wrapper>();
        Set<Id> setEntitlementId = new Set<Id>();
        
        Map<String, String> helpText = new Map<String, String>();
        
        List<Core_Entitlement_SubCategory_HelpText__c> schelp  = [Select Name, Core_Help_Text__c ,Core_SubCategory_Name__c  FROM Core_Entitlement_SubCategory_HelpText__c];
        for(Core_Entitlement_SubCategory_HelpText__c schelptext: schelp){
            helpText.put(schelptext.Core_SubCategory_Name__c ,schelptext.Core_Help_Text__c ); 
        }
        //Sonali (Added null check to cover test class failure)
        //if(lstEntitlement != null && !lstEntitlement.isEmpty()){
            for (Core_Entitlement__c objEntitlement : lstEntitlement) {
            setEntitlementId.add(objEntitlement.Id);
            system.debug('helpText Subcat : '+helpText.get(objEntitlement.Core_Sub_Category__c ));
            lstEntitlementWrapper.add(new Core_Entitlement_Wrapper(objEntitlement,helpText.get(objEntitlement.Core_Sub_Category__c )));
           }
        //}
        
        
        // Get existing Contact Entitlements
        lstConEnt = [SELECT Id, Core_Entitlement_Id__c,Core_Status__c, Core_Entitlement_Id__r.Core_Category__c,Core_Entitlement_Id__r.Core_Sub_Category__c ,Core_Entitlement_Id__r.Core_Help_Text__c  , Core_Entitlement_Id__r.Name, Core_Entitlement_Id__r.Core_Display_Name__c, Core_Selected__c
                     FROM Core_Contact_Entitlement__c    
                     WHERE Core_Contact_Id__c = :idContact
                     AND Core_Entitlement_Id__c IN :setEntitlementId order by Core_Entitlement_Id__r.Core_Category__c,Core_Entitlement_Id__r.Core_Sub_Category__c ];
        
        mapConEnt = new Map<Id, Core_Contact_Entitlement__c>();
        
        // Adding All entitlement to readOnlyEntitlement as editable
        readOnlyEntitlement= new Map<String, Boolean>();
        entitlementStatus=new Map<String, String>();
        entitlementEighteenDigStatus = new Map<String, String>();
        //Sonali (Added null check to cover test class failure)
        //if(lstEntitlement != null && !lstEntitlement.isEmpty()){
            for (Core_Entitlement__c entitlementObj : lstEntitlement ){
                Boolean readOnly=false;
                String status='';
                // adding 15 Digit of ID to the Map To avoid Duplicate
                readOnlyEntitlement.put((entitlementObj.Id+'').substring(0,15),readOnly);
                entitlementStatus.put((entitlementObj.Id+'').substring(0,15),status);
            }
        //}        
        // Updating readOnlyEntitlement with the contact entitlement status to readonly true/false
        
            for (Core_Contact_Entitlement__c objCE : lstConEnt){
                mapConEnt.put(objCE.Core_Entitlement_Id__c, objCE);
                Boolean readOnly=false;
                String status='';
                String entitleID=objCE.Core_Entitlement_Id__c;
                if(objCE.Core_Status__c =='In Progress'|| objCE.Core_Status__c=='Pending' ){
                    readOnly=true;
                    //   status=objCE.Core_Status__c;
                    status='Processing';
                }
                readOnlyEntitlement.put((objCE.Core_Entitlement_Id__c+'').substring(0,15),readOnly);
                entitlementStatus.put((objCE.Core_Entitlement_Id__c+'').substring(0,15),status);
                entitlementEighteenDigStatus.put(objCE.Core_Entitlement_Id__c,status);
            } 
                
        system.debug('Prem === Final readOnlyEntitlement Map::'+readOnlyEntitlement.size());
        // In case an entitlement becomes inactive, it still may be assigned to a contact - expose this.
        // Using the master set of Entitlement Ids, find any Contact Entitlements that aren't included.
        // Add them to the display list.
        for (Core_Contact_Entitlement__c objConEnt : lstConEnt) {
            if (!setEntitlementId.contains(objConEnt.Core_Entitlement_Id__c)) { 
                system.debug('helpText Entitle: '+helpText.get(objConEnt.Core_Entitlement_Id__r.Core_Sub_Category__c ));
                
                lstEntitlementWrapper.add(new Core_Entitlement_Wrapper(objConEnt.Core_Entitlement_Id__c, objConEnt.Core_Entitlement_Id__r.Core_Category__c,objConEnt.Core_Entitlement_Id__r.Core_Sub_Category__c ,objConEnt.Core_Entitlement_Id__r.Core_Display_Name__c, objConEnt.Core_Selected__c, objConEnt.Core_Entitlement_Id__r.Core_Help_Text__c  ,helpText.get(objConEnt.Core_Entitlement_Id__r.Core_Sub_Category__c )));
                //lstEntitlementWrapper.add(new Core_Entitlement_Wrapper(objConEnt.Core_Entitlement_Id__c, objConEnt.Core_Entitlement_Id__r.Core_Category__c,objConEnt.Core_Entitlement_Id__r.Core_Sub_Category__c ,objConEnt.Core_Entitlement_Id__r.Core_Display_Name__c, objConEnt.Core_Selected__c, objConEnt.Core_Entitlement_Id__r.Core_Help_Text__c  ,helpText.get(objConEnt.Core_Entitlement_Id__r.Core_Sub_Category__c )));
              //System.debug('objConEnt.Core_Status__c = '+ objConEnt.Core_Status__c); 
            }    
        }    
        
        System.debug('entitlementEighteenDigStatus.keySet() = '+ entitlementEighteenDigStatus.keySet());
        
        // Update Entitlements with contact-entitlement selected value
        for (Core_Entitlement_Wrapper objEW : lstEntitlementWrapper) {
            if (mapConEnt.containsKey(objEW.idEntitlement))
                objEW.selected = mapConEnt.get(objEW.idEntitlement).Core_Selected__c;
            System.debug('objEW.idEntitlement = ' + objEW.idEntitlement);
            if(entitlementEighteenDigStatus.containsKey(objEW.idEntitlement)){
              if(entitlementEighteenDigStatus.get(objEW.idEntitlement) != null)
                  objEW.status = entitlementEighteenDigStatus.get(objEW.idEntitlement);
            }
        }
        
        
        // Sort - by Category & Engagement Name
        // This drives the sort on the page           
        lstEntitlementWrapper.sort();
        
        
        // Create a List of Lists - Each List contains a single Category of entitlements
        lstlstEntitlementWrapper = new List<List<Core_Entitlement_Wrapper>>();
        
        List<Core_Entitlement_Wrapper> lstCategory = new List<Core_Entitlement_Wrapper>();
        String currentCategory   = '';
        
        for (Core_Entitlement_Wrapper objEW : lstEntitlementWrapper) {
            if (currentCategory != objEW.category) {
                if (lstCategory.size() > 0)
                    lstlstEntitlementWrapper.add(lstCategory);                
                
                lstCategory     = new List<Core_Entitlement_Wrapper>();    
                currentCategory = objEW.category;
            }
            
            lstCategory.add(objEW);
            
        }                 
        if (lstCategory.size() > 0)
            lstlstEntitlementWrapper.add(lstCategory);                
        
        // Limiting rows on the visualforce 
        if(math.mod(lstlstEntitlementWrapper.size(),2)==0)
            limitRows=lstlstEntitlementWrapper.size()/2;                      
        else
            limitRows=(lstlstEntitlementWrapper.size()/2)+1;   
        
        // Tracking Column for the category
        CategoryColumnName= new Map<String, String>();
        
        List<Core_Entitlement_Category_Handler__c> categoryColumn  = [Select Name, Core_Category_Name__c,Core_Column_Name__c FROM Core_Entitlement_Category_Handler__c];
        for(Core_Entitlement_Category_Handler__c catColObj: categoryColumn){
            CategoryColumnName.put((catColObj.Core_Category_Name__c).toUpperCase(),(catColObj.Core_Column_Name__c).toUpperCase()); 
        }
        
        // Handling category not present in custom setting 
        for(List<Core_Entitlement_Wrapper> cew:lstlstEntitlementWrapper){
            if(!CategoryColumnName.containsKey((cew[0].category).toUpperCase())){
                system.debug(':::::::::::'+cew[0].category);
                CategoryColumnName.put((cew[0].category).toUpperCase(),'COLUMN B');
                //   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info,'Please Add Category "'+cew[0].category+ '" to Custom Setting Name: Core_Entitlement_Category_Handler'));
                
            }
        }
        
        system.debug('CategoryColumnName: '+CategoryColumnName); 
        
        return lstEntitlementWrapper;
        
    }
    //  Search on grant access page
    public void search(){
        if(userInput != null && userInput != '' ){
        lstlstSearchEntitlementWrapper = new List<List<Core_Entitlement_Wrapper>>();
        isShowSearchResults = true;
        for (List<Core_Entitlement_Wrapper> lstEW : lstlstEntitlementWrapper) {
            List<Core_Entitlement_Wrapper> lstEWS = new List<Core_Entitlement_Wrapper>();
            for (Core_Entitlement_Wrapper objEW : lstEW) {
                String name = objEW.Name;
                system.debug(objEW.Name);
                system.debug(userInput);
                if(name != null && name.containsIgnoreCase(userInput)){
                    system.debug('inside');
                    lstEWS.add(objEW);
                }
            }
            if(lstEWS.size() > 0){
                lstlstSearchEntitlementWrapper.add(lstEWS);
            }
        }
        if(lstlstSearchEntitlementWrapper.size() > 0){
            isNotExist = false;
        } else {
            isNotExist = true;
        }
        system.debug(isNotExist);
    }
    }
    
    public void clear(){
        userInput = '';
        isShowSearchResults = false;
        isNotExist = false;
    }
    
    /*public pageReference removeSubordinate(){

Map<ID,Set<ID>> mapsubordinateIds=new Map<ID,Set<ID>>();
Map<ID,Set<ID>> mapsubordinateConditionIds=new Map<ID,Set<ID>>();
Map<ID,Set<ID>> mapsubordinateEntitlementIds=new Map<ID,Set<ID>>();

Boolean result = true;
//Remove Subordinates custom settings
List<Core_Contact_Ent_Subordinates_Removal__c> lstConEntSubRemove = Core_Contact_Ent_Subordinates_Removal__c.getAll().values();

//Loop on Remove Subordinates custom settings to prepare map of Subordinates
for(Core_Contact_Ent_Subordinates_Removal__c subEntRefRemove : lstConEntSubRemove){
if(mapsubordinateIds.get(subEntRefRemove.Core_Entitlement_Id__c)==null){
mapsubordinateIds.put(subEntRefRemove.Core_Entitlement_Id__c,(new Set<ID>((List<ID>)(subEntRefRemove.Core_Entitlement_Subordinate_Id__c).split(','))));
}else{
mapsubordinateIds.get(subEntRefRemove.Core_Entitlement_Id__c).addAll(new Set<ID>((List<ID>)(subEntRefRemove.Core_Entitlement_Subordinate_Id__c).split(',')));
}
// Condition Map preparation
if(mapsubordinateConditionIds.get(subEntRefRemove.Core_Entitlement_Id__c)==null){
if(subEntRefRemove.Core_Condition__c !=null){
mapsubordinateConditionIds.put(subEntRefRemove.Core_Entitlement_Id__c,(new Set<ID>((List<ID>)(subEntRefRemove.Core_Condition__c).split(','))));
}else{
mapsubordinateConditionIds.put(subEntRefRemove.Core_Entitlement_Id__c,new Set<ID>());
}
}else{
if(subEntRefRemove.Core_Condition__c !=null){
mapsubordinateConditionIds.get(subEntRefRemove.Core_Entitlement_Id__c).addAll(new Set<ID>((List<ID>)(subEntRefRemove.Core_Condition__c).split(',')));
}else{
mapsubordinateConditionIds.get(subEntRefRemove.Core_Entitlement_Id__c).addAll(new Set<ID>());

}
}
//Subordinate with entitlement id
if(mapsubordinateEntitlementIds.get(subEntRefRemove.Core_Entitlement_Subordinate_Id__c)==null){

mapsubordinateEntitlementIds.put(subEntRefRemove.Core_Entitlement_Subordinate_Id__c,new Set<ID>{subEntRefRemove.Core_Entitlement_Id__c});
}else{
mapsubordinateEntitlementIds.get(subEntRefRemove.Core_Entitlement_Subordinate_Id__c).addAll(new Set<ID>{subEntRefRemove.Core_Entitlement_Id__c});
}
}
system.debug('mapsubordinateEntitlementIds :'+mapsubordinateEntitlementIds);
system.debug('mapsubordinateIds : '+mapsubordinateIds);
system.debug('mapsubordinateConditionIds: '+mapsubordinateConditionIds);
// Checking DeSelected Entitlement contains subordinate logic  
Map<ID,Set<ID>> deselected =new Map<ID,Set<ID>>();
Set<ID> Alldeselected =new Set<ID>();
Set<ID> forRemoval =new Set<ID>();
for (List<Core_Entitlement_Wrapper> lstEW : lstlstEntitlementWrapper) {
for (Core_Entitlement_Wrapper objEW : lstEW) {
if(!objEW.selected ) {
if(mapsubordinateIds.keySet().contains(objEW.idEntitlement)) {
deselected.put(objEW.idEntitlement,mapsubordinateIds.get(objEW.idEntitlement));
forRemoval.addAll(mapsubordinateIds.get(objEW.idEntitlement));
}
Alldeselected.add(objEW.idEntitlement);
}

}
}

system.debug('deselected : '+deselected);
system.debug('Alldeselected :'+Alldeselected);
system.debug('forRemoval :'+forRemoval);
for (List<Core_Entitlement_Wrapper> lstEW : lstlstEntitlementWrapper) {
for (Core_Entitlement_Wrapper objEW : lstEW) {
system.debug('objEW.idEntitlement : '+objEW.idEntitlement+': :'+objEW.idEntitlement);
system.debug('forRemoval.contains(objEW.idEntitlement)'+forRemoval.contains(objEW.idEntitlement));
if(forRemoval.contains(objEW.idEntitlement) && objEW.selected) {
//  system.debug('Alldeselected.containsAll(mapsubordinateConditionIds.get((objEW.idEntitlement).substring(0,15)))'+mapsubordinateConditionIds.get(objEW.idEntitlement));
if(Alldeselected.containsAll(mapsubordinateEntitlementIds.get(objEW.idEntitlement))){
objEW.selected=false;
result = false;
}
}

}
}
system.debug('result : '+result);
return Null;
}*/
    
    
    
    /*public pageReference AddSubordinate(){ 
Set<ID> odmSubordinateIds=new Set<Id>();  
Set<ID> nonOdmSubordinateIds=new Set<Id>();  
Map<ID,ID> mapsubordinateIdsforOdm=new Map<ID,ID>();
Map<ID,ID> mapsubordinateIdsforNOnOdm=new Map<ID,ID>();

//  Set<ID> subordinateIdforOdm=new Set<Id>();
// Set<ID> subordinateIdforNOnOdm=new Set<Id>();

Boolean result = true;
//Get Subordinates from custom settings
List<Core_Contact_Entitlement_Subordinates__c> lstConEntSubAdd = [select id,Core_Entitlement_Subordinate_Id__c,Core_Entitlement_Id__c,Core_Is_ODM_True__c from Core_Contact_Entitlement_Subordinates__c];
//Loop on Add Subordinates custom settings to prepare map of Subordinates
for(Core_Contact_Entitlement_Subordinates__c subEntRefAdd : lstConEntSubAdd){
if(subEntRefAdd.Core_Is_ODM_True__c){
mapsubordinateIdsforOdm.put(subEntRefAdd.Core_Entitlement_Id__c,subEntRefAdd.Core_Entitlement_Subordinate_Id__c);     
}

if(!subEntRefAdd.Core_Is_ODM_True__c){
mapsubordinateIdsforNOnOdm.put(subEntRefAdd.Core_Entitlement_Id__c,subEntRefAdd.Core_Entitlement_Subordinate_Id__c);     
}
}
system.debug('mapsubordinateIdsforOdm : '+mapsubordinateIdsforOdm);
system.debug('mapsubordinateIdsforNOnOdm : '+mapsubordinateIdsforNOnOdm);
// Checking Selected Entitlement contains subordinate logic  
for (List<Core_Entitlement_Wrapper> lstEW : lstlstEntitlementWrapper) {
for (Core_Entitlement_Wrapper objEW : lstEW) {
// ODM Contact Account subordinate
if(objEW.selected && objContact.Account.Core_IsODM__c) {
if(mapsubordinateIdsforOdm.keySet().contains(objEW.idEntitlement)) {
odmSubordinateIds.add(mapsubordinateIdsforOdm.get(objEW.idEntitlement));
}
}
// Non ODM Contact Account subordinate
if(objEW.selected && !objContact.Account.Core_IsODM__c) {
if(mapsubordinateIdsforNOnOdm.keySet().contains(objEW.idEntitlement)) {
nonOdmSubordinateIds.add(mapsubordinateIdsforNOnOdm.get(objEW.idEntitlement));
}
}
}
}
system.debug('odmSubordinateIds : '+odmSubordinateIds);
system.debug('nonOdmSubordinateIds : '+nonOdmSubordinateIds);
for (List<Core_Entitlement_Wrapper> lstEW : lstlstEntitlementWrapper) {
for (Core_Entitlement_Wrapper objEW : lstEW) {
system.debug('objEW.idEntitlement : '+objEW.idEntitlement);
if(odmSubordinateIds.contains(objEW.idEntitlement) && !objEW.selected) {
objEW.selected=true;
result = false;
}
if(nonOdmSubordinateIds.contains(objEW.idEntitlement) && !objEW.selected) {
objEW.selected=true;
result = false;
}
}
}
system.debug('result : '+result);
Boolean validEntitlement=validate();
return Null;
}*/
    
    public Boolean validate() {
        Boolean result = true;
        String strValidateCNDANum;
        String strValidateIsODM;
        String strValidateCimId;
        String strValidateIntelSupportOwner;
        String strValidateAccountOwnerRole;
        String strValidatePersonalEmailIndicator;
        String strValidateIsODMTrue;
        String strValidateUniqueEntitlement;
        String strValidateMPUniqueEntitlement;
        String strvalidateAccountEnglishOnlyFields;
        String strvalidateContactEnglishOnlyFields;
        String strValidateDCBCUniqueEntitlement;//Sonali (US731136)
        
        
        Map<Id, Contact> mUpdateContEngName = new Map<Id, Contact>();
        Map<Id, Account> mUpdateAcctEngName = new Map<Id, Account>();
        system.debug('lstlstEntitlementWrapper '+lstlstEntitlementWrapper);
        for (List<Core_Entitlement_Wrapper> lstEW : lstlstEntitlementWrapper) {
            for (Core_Entitlement_Wrapper objEW : lstEW) {
                system.debug('objEW$$$$$$$$$$$$$$ '+objEW);
                if(objEW.selected) {
                    
                    if(!Core_ContactEntitlementValidation.validateEnglishOnlyFields(objContact, mUpdateContEngName, mUpdateAcctEngName) ) {
                        /*if(String.isBlank(objContact.Core_English_Only_First_Name__c) || String.isBlank(objContact.Core_English_Only_Last_Name__c)){
if(String.isBlank(strvalidateContactEnglishOnlyFields)){
strvalidateContactEnglishOnlyFields= objEW.strName;
}else{
strvalidateContactEnglishOnlyFields= strvalidateContactEnglishOnlyFields+', '+objEW.strName;
}
}
if(String.isBlank(objContact.Account.Core_English_Only_Name__c)){
if(String.isBlank(strvalidateAccountEnglishOnlyFields)){
strvalidateAccountEnglishOnlyFields= objEW.strName;
}else{
strvalidateAccountEnglishOnlyFields= strvalidateAccountEnglishOnlyFields+', '+objEW.strName;
}
}*/
                        
                        if((String.isBlank(objContact.Core_English_Only_First_Name__c) || String.isBlank(objContact.Core_English_Only_Last_Name__c)) && (mapentIds.keySet().contains(objEW.idEntitlement) && mapentIds.get(objEW.idEntitlement).Core_Contact_English_Only_Name__c)) {
                            if(String.isBlank(strvalidateContactEnglishOnlyFields)){
                                strvalidateContactEnglishOnlyFields= objEW.strName;
                            }else{
                                strvalidateContactEnglishOnlyFields= strvalidateContactEnglishOnlyFields+', '+objEW.strName;
                            }
                        }
                        if(String.isBlank(objContact.Account.Core_English_Only_Name__c)&&(mapentIds.keySet().contains(objEW.idEntitlement) && mapentIds.get(objEW.idEntitlement).Core_Account_English_Only_Name__c)){
                            if(String.isBlank(strvalidateAccountEnglishOnlyFields)){
                                strvalidateAccountEnglishOnlyFields= objEW.strName;
                            }else{
                                strvalidateAccountEnglishOnlyFields= strvalidateAccountEnglishOnlyFields+', '+objEW.strName;
                            }
                        }
                        
                        if((mapentIds.keySet().contains(objEW.idEntitlement) && (mapentIds.get(objEW.idEntitlement).Core_Account_English_Only_Name__c || mapentIds.get(objEW.idEntitlement).Core_Contact_English_Only_Name__c))){
                            result = false;
                        }
                        /*if((String.isBlank(contactObj.Core_English_Only_First_Name__c) || String.isBlank(contactObj.Core_English_Only_Last_Name__c)) && (mapentIds.keySet().contains(objEW.idEntitlement) && mapentIds.get(objEW.idEntitlement).Core_Contact_English_Only_Name__c)) {
contEntObj.addError(mapConentValErrorMsg.get('System English on Contact'));
}
//&&(mapentIds.keySet().contains(contEntObj.Id) && mapentIds.get(contEntObj.Id).Core_Account_English_Only_Name__c)
if(String.isBlank(contactObj.Account.Core_English_Only_Name__c)&&(mapentIds.keySet().contains(objEW.idEntitlement) && mapentIds.get(objEW.idEntitlement).Core_Account_English_Only_Name__c)){
contEntObj.addError(mapConentValErrorMsg.get('System English on Account'));
}*/
                        
                    }
                    system.debug('objEW :: '+objEW);
                    if(!Core_ContactEntitlementValidation.validateCimId(objEW.idEntitlement, objContact)) {
                        if(String.isBlank(strValidateCimId)){
                            strValidateCimId = objEW.strName;
                        }else{
                            strValidateCimId = strValidateCimId+', '+objEW.strName;
                        }
                        result = false;
                    }
                    if(!Core_ContactEntitlementValidation.validateCNDANum(objEW.idEntitlement, objContact)) {                        
                        if(String.isBlank(strValidateCNDANum)){
                            strValidateCNDANum = objEW.strName;
                        }else{
                            strValidateCNDANum = strValidateCNDANum+', '+objEW.strName;
                        }
                        result = false;
                    }
                    
                    if(!Core_ContactEntitlementValidation.validateIsODM(objEW.idEntitlement, objContact)) {
                        if(String.isBlank(strValidateIsODM)){
                            strValidateIsODM = objEW.strName;
                        }else{
                            strValidateIsODM = strValidateIsODM+', '+objEW.strName;
                        }
                        result = false;
                    }
                    if(!Core_ContactEntitlementValidation.validateIntelSupportOwner(objEW.idEntitlement, objContact)) {
                        if(String.isBlank(strValidateIntelSupportOwner)){
                            strValidateIntelSupportOwner = objEW.strName;
                        }else{
                            strValidateIntelSupportOwner = strValidateIntelSupportOwner+', '+objEW.strName;
                        }
                        result = false;
                    }
                    if(!Core_ContactEntitlementValidation.validateAccountOwnerRole(objEW.idEntitlement, objContact)) {
                        if(String.isBlank(strValidateAccountOwnerRole)){
                            strValidateAccountOwnerRole = objEW.strName;
                        }else{
                            strValidateAccountOwnerRole = strValidateAccountOwnerRole+', '+objEW.strName;
                        }
                        result = false;
                    }
                    
                    if(!Core_ContactEntitlementValidation.validatePersonalEmailIndicator(objEW.idEntitlement, objContact)) {
                        if(String.isBlank(strValidatePersonalEmailIndicator)){
                            strValidatePersonalEmailIndicator = objEW.strName;
                        }else{
                            strValidatePersonalEmailIndicator = strValidatePersonalEmailIndicator+', '+objEW.strName;
                        }
                        result = false;
                    }
                    if(!Core_ContactEntitlementValidation.validateIsODMTrue(objEW.idEntitlement, objContact)) {
                        if(String.isBlank(strValidateIsODMTrue)){
                            strValidateIsODMTrue = objEW.strName;
                        }else{
                            strValidateIsODMTrue = strValidateIsODMTrue+', '+objEW.strName;
                        }
                        
                        result = false;
                    }
                    if(!Core_ContactEntitlementValidation.validateUniqueEntitlement(objEW.idEntitlement, objContact, objEW.strName)) {
                        System.debug('In validateUniqueEntitlement controller Method');
                        strValidateUniqueEntitlement = Core_ContactEntitlementValidation.uniqueEntitlementNames;
                        result = false;
                    }
                    System.Debug('objEW.idEntitlement Outside'+objEW.idEntitlement);
                    if(objEW.idEntitlement == System.Label.Core_Employee || objEW.idEntitlement == System.Label.Core_Lead_Development_Representative || objEW.idEntitlement == System.Label.Core_Marketing_specialist || objEW.idEntitlement == System.Label.Core_Offering_Editor||objEW.idEntitlement == System.Label.Core_Partner_Admin ||objEW.idEntitlement == System.Label.Core_Partner_Admin_Delegate )
                     {
                         System.Debug('objEW.idEntitlement Inside'+objEW);
                         System.debug('objContact ='+objContact);
                    if(!Core_ContactEntitlementValidation.validateUniqueMPEntitlement(objEW.idEntitlement, objContact, objEW.strName)) {
                        strValidateMPUniqueEntitlement = Core_ContactEntitlementValidation.uniqueEntitlementNames1;
                        result = false;
                    }
                     }
                    //Sonali START  (US731136 - Pipeline: CTO Requirement)
                    if(objEW.idEntitlement == System.Label.Core_CTO_Distributor || objEW.idEntitlement == System.Label.Core_CTO_Reseller){
                        if(!Core_ContactEntitlementValidation.validateDCBCUniqueEntitlement(objEW.idEntitlement, objContact, objEW.strName)) {
                            strValidateDCBCUniqueEntitlement = Core_ContactEntitlementValidation.uniqueEntitlementNames2;                            
                            result = false;
                        }  
                    }                                  
                    //Sonali END
                }
            }
        }
        if(mUpdateContEngName.size() > 0){
            system.debug('===mUpdateContEngName==geetha=>'+mUpdateContEngName);
            update mUpdateContEngName.values();
        }
        if(mUpdateAcctEngName.size() > 0){
            system.debug('===mUpdateAcctEngName====geetha===>'+mUpdateAcctEngName);
            update mUpdateAcctEngName.values();
        }
        if(!String.isBlank(strValidateCNDANum)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, mapConentValErrorMsg.get('UI CNDA') +' '+ strValidateCNDANum);
            ApexPages.addMessage(myMsg);
        }
        
        if(!String.isBlank(strValidateIsODM)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI Non ODM') +' '+ strValidateIsODM);
            ApexPages.addMessage(myMsg);
        }
        if(!String.isBlank(strValidateIntelSupportOwner)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI ISO') +' '+ strValidateIntelSupportOwner);
            ApexPages.addMessage(myMsg);
        }
        if(!String.isBlank(strValidateAccountOwnerRole)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI Account Owner Role') +' '+ strValidateAccountOwnerRole);
            ApexPages.addMessage(myMsg);
        }
        if(!String.isBlank(strValidateCimId)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI CIM ID') +' '+ strValidateCimId);
            ApexPages.addMessage(myMsg);
        }
        if(!String.isBlank(strValidatePersonalEmailIndicator)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI PersonalEmailIndicator') +' '+ strValidatePersonalEmailIndicator);
            ApexPages.addMessage(myMsg);   
        }
        if(!String.isBlank(strValidateIsODMTrue)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI ODM') +' '+ strValidateIsODMTrue);
            ApexPages.addMessage(myMsg);
        }
        if(!String.isBlank(strValidateUniqueEntitlement)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI Unique Entitlement') +' '+ strValidateUniqueEntitlement);
            ApexPages.addMessage(myMsg);
        }
        if(!String.isBlank(strValidateMPUniqueEntitlement)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI Unique MP Entitlement') +' '+ strValidateMPUniqueEntitlement);
            ApexPages.addMessage(myMsg);
        }
        if(!String.isBlank(strvalidateContactEnglishOnlyFields)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI English on Contact') +' '+ strvalidateContactEnglishOnlyFields);
            ApexPages.addMessage(myMsg);
        }
        if(!String.isBlank(strvalidateAccountEnglishOnlyFields)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI English on Account') +' '+ strvalidateAccountEnglishOnlyFields);
            ApexPages.addMessage(myMsg);
        }
        //Sonali START (US731136 - Pipeline: CTO Requirement)
        if(!String.isBlank(strValidateDCBCUniqueEntitlement)){            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI Single Entitlement Assignment'));
            ApexPages.addMessage(myMsg); 
            System.debug('myMsg dist>>'+myMsg);
        }
        //Sonali END
        return result;             
    }
    
    
    public pageReference onSave() {
        System.debug('In Validation:-'+!validate());
        if (!validate()){
            System.debug('<<Valid>>');
            return NULL;
        }
            
        System.debug('lstlstEntitlementWrapper ONSAVE>>>>>'+lstlstEntitlementWrapper);
        if(saveContactEntitlements(lstlstEntitlementWrapper,UPDATE_REASON_GRANT_ACCESS) != null 
           && !saveContactEntitlements(lstlstEntitlementWrapper,UPDATE_REASON_GRANT_ACCESS).isEmpty()){  //Error has occurred
            Exception e = saveContactEntitlements(lstlstEntitlementWrapper,UPDATE_REASON_GRANT_ACCESS).get(0);
            System.debug('Message:-'+e);
            Apexpages.addMessages(e);              
          return NULL;
        }
        return onReturnPress();
    }
    
    public List<Exception> saveContactEntitlements(List<List<Core_Entitlement_Wrapper>> localLstlstEntitlementWrapper,String updateReason){    
        
        List<Exception> exceptionMessages = new List<Exception>();
        System.debug('#51 localLstlstEntitlementWrapper: ' + localLstlstEntitlementWrapper);
        
        
         for(Core_Entitlement_Wrapper cew : localLstlstEntitlementWrapper[0]){
            System.debug('cew ='+ cew );
        }
        
        //List<Core_Contact_Entitlement__c> lstDeleteConEn = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c objConEn;
        lstConEnt = new List<Core_Contact_Entitlement__c>();
        
        for (List<Core_Entitlement_Wrapper> lstEW : localLstlstEntitlementWrapper) { 
            for (Core_Entitlement_Wrapper objEW : lstEW) {
                System.debug('objEW?????'+objEW);
                if (mapConEnt.containsKey(objEW.idEntitlement)) {
                    objConEn = mapConEnt.get(objEW.idEntitlement);
                    System.debug('objEW.selected objConEn.Core_Selected__c'+objConEn.Core_Selected__c+objEW.selected);
                    if (objEW.selected && !objConEn.Core_Selected__c) {
                        objConEn.Core_Selected__c = objEW.selected;
                        objConEn.Core_Status__c='Pending';
                          objConEn.Core_Entitlement_Requester_Id__c = UserInfo.getUserId();
                          objConEn.Core_Email_Pending_To_Requester_Ind__c = true;
                        //objConEn.Core_Update_Reason__c = UPDATE_REASON_GRANT_ACCESS;
                        
                        lstConEnt.add(objConEn);
                    } else if(objEW.selected && objConEn.Core_Selected__c) {
                        // Don't do anything because nothing changed.
                    } else { 
                        if(objConEn.Core_Selected__c != false) {
                            objConEn.Core_Selected__c = false;
                            objConEn.Core_Status__c='Pending';
                            //objConEn.Core_Update_Reason__c = UPDATE_REASON_GRANT_ACCESS;
                             objConEn.Core_Entitlement_Requester_Id__c = UserInfo.getUserId();
                             objConEn.Core_Email_Pending_To_Requester_Ind__c = true;
                            //lstDeleteConEn.add(objConEn); 
                            lstConEnt.add(objConEn);    
                        }
                    }
                    
                } else if (objEW.selected) {
                    objConEn = new Core_Contact_Entitlement__c(Core_Contact_Id__c=idContact, 
                                                               Core_Entitlement_Id__c=objEW.idEntitlement,Core_Status__c='Pending',
                                                               Core_Selected__c=true);
                        objConEn.Core_Source__c = updateReason;
                         objConEn.Core_Entitlement_Requester_Id__c = UserInfo.getUserId();
                         objConEn.Core_Email_Pending_To_Requester_Ind__c = true;
                    lstConEnt.add(objConEn);            
                }    
            }
        }
        
        System.debug('#55 lstConEnt: ' + lstConEnt);
        Boolean updated = false;
        if (lstConEnt.size() > 0) {
            try{
                System.debug('Zay - upserting in contact entitlements controller >>  '+lstConEnt);
                //lstConEnt = checkForDuplicates(lstConEnt);
                if(lstConEnt != null && !lstConEnt.isEmpty()){
                  //upsert lstConEnt;
                  Database.upsert(lstConEnt, false);
                  updated = true;                    
                }

            } catch(Exception e) {
                //Apexpages.addMessages(e);
                exceptionMessages.add(e);
                lstConEnt = new List<Core_Contact_Entitlement__c>();
                return exceptionMessages;
                //return null;
            }
        }
        /*if (lstDeleteConEn.size() > 0) {
        System.debug('Zay - updating deletion in contact entitlements controller');
        update lstDeleteConEn;
        updated = true;
        }*/

        if(updated) {
            objContact.Core_ERPM_Integration_Status__c = 'Pending';
            //objContact.Core_AGS_Integration_Status__c = 'Pending';
            /***********************Draco : AGS Multiple OBM issue 14 Aug - START****************************/
                    system.debug('PM : Beging contact.Core_AGS_Republish_Ind__c ==>'+objContact.Core_AGS_Republish_Ind__c);
                    if(objContact.Core_AGS_Integration_Status__c != 'Pending' && objContact.Core_AGS_Integration_Status__c!= 'In-Progress'){
            objContact.Core_AGS_Integration_Status__c = 'Pending';
                        objContact.Core_AGS_Republish_Ind__c = false;
                    }
                    else if((/*objContact.Core_AGS_Integration_Status__c == 'Pending' ||*/ objContact.Core_AGS_Integration_Status__c == 'In-Progress')
                            && !objContact.Core_AGS_Republish_Ind__c){
                                objContact.Core_AGS_Republish_Ind__c = true;
                            }
                    system.debug('PM : contact.Core_AGS_Integration_Status__c==>'+objContact.Core_AGS_Integration_Status__c);
                    system.debug('PM : contact.Core_AGS_Republish_Ind__c ==>'+objContact.Core_AGS_Republish_Ind__c);
                    /***********************Draco : AGS Multiple OBM issue 14 Aug - END******************************/
            
            update objContact;
        }
        return exceptionMessages;
    }
    
    //Goes through list of contact entitlements and removes the duplicates
    /*private List<Core_Contact_Entitlement__c> checkForDuplicates(List<Core_Contact_Entitlement__c> lstConEnt){
        
        Map<Id, Set<Id>> conIdToEntitlements = new Map<Id, Set<Id>>();
        List<Core_Contact_Entitlement__c> revisedContactEntitlements = new List<Core_Contact_Entitlement__c>();
        
        for(Core_Contact_Entitlement__c coreConEntitlement : lstConEnt){
            if(conIdToEntitlements.get(coreConEntitlement.Core_Contact_Id__c) != null && coreConEntitlement.Core_Contact_Id__c != null ){
                conIdToEntitlements.get(coreConEntitlement.Core_Contact_Id__c).add(coreConEntitlement.Core_Entitlement_Id__c);  
            }else{
                if(coreConEntitlement.Core_Contact_Id__c != null)
                    conIdToEntitlements.put(coreConEntitlement.Core_Contact_Id__c, new Set<Id>{coreConEntitlement.Core_Entitlement_Id__c});
            }
        }
        System.debug('conIdToEntitlements = '+ conIdToEntitlements);
        
        Map<Id, Set<Id>> existingConIdToEntitlements = new Map<Id, Set<Id>>();
        if(!conIdToEntitlements.isEmpty()){
            List<Core_Contact_Entitlement__c> existingEntitlements  = [Select Id, Core_Contact_Id__c, 
                                                                     Core_Entitlement_Id__c from Core_Contact_Entitlement__c where 
                                           Core_Contact_Id__c in :conIdToEntitlements.keySet()];
            for(Core_Contact_Entitlement__c coreConEntitlement : existingEntitlements){
                 if(existingConIdToEntitlements.get(coreConEntitlement.Core_Contact_Id__c) != null){
                  existingConIdToEntitlements.get(coreConEntitlement.Core_Contact_Id__c).add(coreConEntitlement.Core_Entitlement_Id__c);  
              }else{
                  existingConIdToEntitlements.put(coreConEntitlement.Core_Contact_Id__c, new Set<Id>{coreConEntitlement.Core_Entitlement_Id__c});
              } 
            }
        }
        System.debug('existingConIdToEntitlements = '+ existingConIdToEntitlements);
        
        Map<Id, Set<Id>> refinedConIdToEntitlements = new Map<Id, Set<Id>>();
        if(!conIdToEntitlements.isEmpty() && !existingConIdToEntitlements.isEmpty()){
            
            for(Id contactId : conIdToEntitlements.keySet()){
              Set<Id> entitlementIds = conIdToEntitlements.get(contactId);
                for(Id entitlementId : entitlementIds){
                    System.debug('existingConIdToEntitlements.get(contactId) = '+ existingConIdToEntitlements.get(contactId));
                    if(existingConIdToEntitlements.get(contactId) != null 
                       && !existingConIdToEntitlements.get(contactId).contains(entitlementId)){
                        if(refinedConIdToEntitlements.get(contactId) != null){
                            refinedConIdToEntitlements.get(contactId).add(entitlementId);  
                        }else{
                            refinedConIdToEntitlements.put(contactId, new Set<Id>{entitlementId});
                        }
                    } 
                }
            }
            
        }
        System.debug('refinedConIdToEntitlements = '+ refinedConIdToEntitlements);
        
        for(Id contactId : refinedConIdToEntitlements.keySet()){
            if(refinedConIdToEntitlements.get(contactId) != null){
                for(Id entitlementId  : refinedConIdToEntitlements.get(contactId)){
                    for(Core_Contact_Entitlement__c coreConEntitlement : lstConEnt){
                        if(coreConEntitlement.Core_Contact_Id__c != null 
                           && coreConEntitlement.Core_Entitlement_Id__c != null
                           && entitlementId == coreConEntitlement.Core_Entitlement_Id__c
                           && contactId == coreConEntitlement.Core_Contact_Id__c){
                               revisedContactEntitlements.add(coreConEntitlement);
                        }//end of if
                    }//end of inside for 
                }//end of outer for      
            }//end of outside if
        }//end of outmost for
        
        if(existingConIdToEntitlements.isEmpty()){
            revisedContactEntitlements = lstConEnt;
        }  
        System.debug('revisedContactEntitlements = '+ revisedContactEntitlements);
        return revisedContactEntitlements; 
    }*/
    
    public pageReference onReturnPress() {
        String url = '';
        /* if(UserInfo.getUiThemeDisplayed() == 'Theme3'){
url = strReturnUrl;
}else{
url = '/one/one.app?#/sObject/'+ idContact + '/view';
}*/
        
        if (Site.getSiteId() != null) { //Community
            url= Label.SandbxURL+idContact;
        } else if (UserInfo.getUIThemeDisplayed() == 'Theme3') { //Classic
            url = strReturnUrl;
        } else {//Lightning
            url = '/one/one.app?#/sObject/'+ idContact + '/view';
        }
        
        PageReference prPage = new PageReference(url);    
        prPage.setRedirect(true);
        
        return prPage;
    }
      
    public boolean displayPopup {get; set;}    
   
    public void closePopup()
    {      
        displayPopup = false;  
    }    
    public void showPopup()
    {    
        string passedParam1 = Apexpages.currentPage().getParameters().get('myParam1');
        //System.debug('passedParam1'+passedParam1);
        string passedParam2 = system.CurrentPageReference().getParameters().get('myParam2');
        //System.debug('passedParam2'+passedParam2);
        
        if(passedParam1 == 'Employee' && passedParam2 == 'true'){
             displayPopup = true;  
        }
       
    } 
  
    public void checkEntitlementSubordinates() {
        System.debug('Zay - Test Apex Action Support - ' + subordinateEntName);
        /*for (List<Core_Entitlement_Wrapper> lstEW : lstlstEntitlementWrapper) {
for (Core_Entitlement_Wrapper objEW : lstEW) {
objEW.selected = true;
}
}*/ 
        
    }
    
    public class Core_Entitlement_Wrapper implements Comparable {
        
        public final String CATEGORY_DEFAULT = 'Entitlements';
        public final String SUBCATEGORY_DEFAULT = '';
        public final String ENTITLE_HELPTEXT_DEFAULT= '';
        public final String SUBCAT_HELPTEXT_DEFAULT='';
        public Boolean selected { get; set; }     
    public String status { get; set; }         
        
        private String strCategory = '';
        public String category { 
            get 
            {
                if (String.isBlank(strCategory))
                    return CATEGORY_DEFAULT;
                else     
                    return strCategory;
            }
        }
        
        public String strEntitleHelpText= '';
        public String entitlehelpText{ 
            get 
            {
                if (String.isBlank(strEntitleHelpText))
                    return ENTITLE_HELPTEXT_DEFAULT;
                else     
                    return strEntitleHelpText;
            }
        }
        public String strSubCatHelpText= '';
        public String subCatHelpText{ 
            get 
            {
                if (String.isBlank(strSubCatHelpText))
                    return SUBCAT_HELPTEXT_DEFAULT;
                else     
                    return strSubCatHelpText;
            }
        }
        private String  strSubCategory= '';
        public String subcategory { 
            get 
            {
                if (String.isBlank(strSubCategory))
                    return SUBCATEGORY_DEFAULT;
                else     
                    return strSubCategory;
            }
        }
        
        private String strName = '';
        public String name { get {return strName;} } 
        
        public Id idEntitlement{get;set;}
        
        public Core_Entitlement_Wrapper(String strName) {
            this.strName  = strName;
        }
        
        public Core_Entitlement_Wrapper(Core_Entitlement__c objEntitlement,String strSubCatHelpText1) {
            idEntitlement = objEntitlement.Id;
            strCategory   = objEntitlement.Core_Category__c;
            strName       = objEntitlement.Core_Display_Name__c;
            strSubCategory = objEntitlement.Core_Sub_Category__c ;
            strEntitleHelpText    = objEntitlement.Core_Help_Text__c  ; 
            strSubCatHelpText    = strSubCatHelpText1;
            //External User Management
            //this.status = status;
        }        
        
        public Core_Entitlement_Wrapper(Id idEnt, String strEngCat, String strEngSubCat, String strEngName, Boolean blnSelected, String strEngEntitleHelpText, String strEngSubCatHelpText1) {
            //this.status = status;
            idEntitlement = idEnt;
            strCategory   = strEngCat;
            strName       = strEngName;            
            selected      = blnSelected;
            strSubCategory =strEngSubCat;
            strEntitleHelpText=strEngEntitleHelpText;
            strSubCatHelpText    = strEngSubCatHelpText1;
            
        } 
        
        public Integer compareTo(Object compareTo) 
        {      
            Core_Entitlement_Wrapper rec = (Core_Entitlement_Wrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer greaterValue = 1;
            Integer lesserValue  = -1;
            if (category > rec.category){
                return greaterValue;
            }   
            
            if (category == rec.category){
                if (subcategory > rec.subcategory){
                    return greaterValue;
                }
                if (subcategory == rec.subcategory){
                    if (name> rec.name){
                        return greaterValue;
                    } 
                }
            }  
            return lesserValue ;
        }
        
    }
    
}