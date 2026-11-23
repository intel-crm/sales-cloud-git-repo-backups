// Modification log : Om Tripathi    23/09/2021  Changes code for Grant Access GEC block Integration
// Modification log : Shashwat Vairale  7/12/2021  Changes code for Grant Access Enhancement for Admins
// Modification log : Akshay More [Draco]  01/02/2022  Don't change ERPM Integration Status in case of 2.0 flow
public without sharing class Core_Contact_Entitlements_Controller {
    
    //Start---added code For Validation from Custom setting
    
    public String userInput{get;set;} 
    public static List<Core_Contact_Entitlement_Validation__c> lstconentval = Core_Contact_Entitlement_Validation__c.getall().values();
    public static Map<Id,Core_Contact_Entitlement_Validation__c> mapentIds = new Map<Id,Core_Contact_Entitlement_Validation__c>();
    public static List<Core_Contact_Ent_Validation_Message__c> lstConentValErrorMsg = Core_Contact_Ent_Validation_Message__c.getall().values();
    public static Map<String,String> mapConentValErrorMsg = new Map<String,String>();
    //public static List<String> lstOfEntitlementForException {get;set;}
    public static boolean isUpdtateCon = false;
    public static boolean startedFromGA = false;  
    public static Map<String,Set<String>> EntToBenefitsMap {get;set;}
    public boolean showDialougeBox{get;set;}
    public Set<String> Benefits{get;set;}
    public Set<string> selectedbenefits  {get;set;}
    public string selectedTrueOrFalseBool {get;set;}
    public string isCheckedvalue {get;set;}
    public string selectedNameOnUI {get;set;}
    public string selectedNameOnUICont {get;set;}
    public integer acrCountPA{get;set;}
    public integer acrCountPAD{get;set;} 
    public boolean isActiveEntMatrix{get;set;}
    public integer acrCount{get;set;}  
    public static List<String> lstOfEntitlementForSuppressSoftPopups {get;set;}
    static {
        
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
        
        
    }
    
    
    public Boolean blnIsValid { get; set; }
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
    
    public String entBenifitsMap{get;set;} 
    
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
    public string employee {get; set;}  
    public string partnerAdmin {get; set;}
    public string partnerAdminDel {get; set;}
    
    public List<string> benefitEntitlementList = new List<string>();
    List<Id> entlWithBenefitList = new List<Id>();
    public List<AggregateResult> conCount{get;set;} //Shashwat Changes
    public Core_Contact_Entitlements_Controller(String contactId) {
        idContact    = contactId;
        
        objContact = [SELECT Id, Name,Email,FirstName,LastName,Core_Enterprise_Id__c, AccountId, Account.Name, Account.Core_CNDA_Number__c, Account.Core_IPS_Active__c,Account.PRM_Count_IPA_Terms_And_Conditions__c,
                      Core_IPS_Intel_Support_Owner__c, Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c,Account.Owner.UserRole.Name, Core_Contact_B2B_Indicator__c,
                      Account.Core_IsODM__c,Account.Core_IPS_PSG_WOM_Check__c, Core_Set_ERPM_Status_Bypass__c, Account.Core_CIM_ID__c,Account.Core_Business_Party_Id__c, Core_Personal_Email_Indicator__c, Core_ERPM_Integration_Queue_txt__c,
                      Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c,Account.Core_English_Only_Name__c,Core_Local_Last_Name__c,Core_Local_First_Name__c,Account.Core_Alternate_Language_Name__c,Account.Core_Deactivated__c,Account.Core_Deactivation_Reason__c,Core_AGS_Republish_Ind__c,
                      (SELECT id,name,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Entitlement_Nm__c,Core_Status__c, Core_Selected__c,Core_Entitlement_Id__r.Id,Core_Entitlement_Id__r.Core_AGS_Role_Id__c FROM contact_entitlements__r)
                      FROM Contact 
                      WHERE Id = :idContact 
                      LIMIT 1];
    }
    
    public Core_Contact_Entitlements_Controller() {
    }
    
    public Core_Contact_Entitlements_Controller(ApexPages.StandardController controller) {
        //Shashwat Changes Start
        employee = 'Employee';
        partnerAdmin = 'Partner Admin';
        partnerAdminDel = 'Partner Admin Delegate';
        //Shashwat Changes End
        
        isShowSearchResults = false;
        isNotExist = false;
        lstlstSearchEntitlementWrapper = new List<List<Core_Entitlement_Wrapper>>();
        idContact    = ApexPages.currentPage().getParameters().get('Id');
        strReturnURL = '//' + idContact;
        //Disabled Entitlement checkbox on the page
        disabledEntitlement=Label.Core_Entitlement_Disable_Grant_Access;
        disabledEntitlement2=Label.Entitlement_Disable_Grant_Access2;
        Set<Id> validatedIds = new Set<Id>();
        acrCount = 0;
        acrCountPA = 0;
        acrCountPAD = 0;
        for(PRM_Account_Contact_Relationship__c acRel :[select id, PRM_Relationship_Id__r.Name, PRM_InActive_Ind__c, PRM_Status_Nm__c from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c= :idContact]){
            if(acRel.PRM_Relationship_Id__r.Name == 'Employee' && acRel.PRM_InActive_Ind__c == false && acRel.PRM_Status_Nm__c == 'Complete')
                acrCount++;
            if(acRel.PRM_Relationship_Id__r.Name == 'Partner Admin' && acRel.PRM_InActive_Ind__c == false && acRel.PRM_Status_Nm__c == 'Complete')
                acrCountPA++;
            if(acRel.PRM_Relationship_Id__r.Name == 'Partner Admin Delegate' && acRel.PRM_InActive_Ind__c == false && acRel.PRM_Status_Nm__c == 'Complete')
                acrCountPAD++;
        }
        
        
        
        objContact = [SELECT Id, Name,Email,FirstName,LastName,Core_Enterprise_Id__c, AccountId, Account.Name,Account.Core_Intel_Partner_Alliance_PartnerGroup__c, Account.Core_CNDA_Number__c, Account.Core_IPS_Active__c,Account.PRM_Count_IPA_Terms_And_Conditions__c,
                      Core_IPS_Intel_Support_Owner__c, Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c,Account.Owner.UserRole.Name, Core_Contact_B2B_Indicator__c,
                      Account.Core_IsODM__c,Account.Core_IPS_PSG_WOM_Check__c, Core_Set_ERPM_Status_Bypass__c, Account.Core_CIM_ID__c,Account.Core_Business_Party_Id__c, Core_Personal_Email_Indicator__c, Core_ERPM_Integration_Queue_txt__c,
                      Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c,Account.Core_English_Only_Name__c,Core_Local_Last_Name__c,Core_Local_First_Name__c,Account.Core_Alternate_Language_Name__c,Account.Core_Deactivated__c,Account.Core_Deactivation_Reason__c,Core_AGS_Republish_Ind__c,Core_Contact_Export_Compliance_Block__c,
                      (SELECT id,name,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Entitlement_Nm__c,Core_Status__c, Core_Selected__c,Core_Entitlement_Id__r.Id,Core_Entitlement_Id__r.Core_AGS_Role_Id__c FROM contact_entitlements__r)//om changes GEC
                      FROM Contact 
                      WHERE Id = :idContact 
                      LIMIT 1];                
        
        
        
        strContactName = objContact.Name;
        strAccountName = objContact.Account.Name;
        iSIpaAccount = objContact.Account.Core_Intel_Partner_Alliance_PartnerGroup__c;
        
        User currentuser=[Select Id,ProfileId,Name from User where Id=:userinfo.getuserId()];
        Id profileId=currentuser.ProfileId;
        
        Core_Test_Utility.checkRecordEditAccess(UserInfo.getUserId(), new Set<Id>{objContact.AccountId}, validatedIds);
        
        If(!objContact.Core_Contact_Export_Compliance_Block__c){ // om changes GEC
            
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
        } 
        
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, Core_Contact_Ent_Validation_Message__c.getValues('Restricted Grant Access for GEC').Core_Error_Message__c);
            ApexPages.addMessage(myMsg);
            blnIsValid = false;
        }
        
        
        
        lstOfEntitlementForSuppressSoftPopups = new List<String>();
        //String EntitlementsForException = System.Label.Core_Benefit_Exception;
        //lstOfEntitlementForException = EntitlementsForException.split(';');
        
        List<Core_GA_Page_Validation_Control__c> GA_Page_Validation_Control = new List<Core_GA_Page_Validation_Control__c>();
        GA_Page_Validation_Control = Core_GA_Page_Validation_Control__c.getAll().values();
        
        for(Core_GA_Page_Validation_Control__c GA_Page_VC :GA_Page_Validation_Control){
            if(GA_Page_VC.Suppress_Popup__c){
                lstOfEntitlementForSuppressSoftPopups.add(GA_Page_VC.Core_Entitlement_Display_Name__c);
            }
        }
        
        EntToBenefitsMap = new Map<String,Set<String>>();
        List<AggregateResult> EntBenefitAggResult =  [SELECT PRM_Entitlement_Id__r.Core_Display_Name__c EntName, PRM_Partner_Benefit_Id__r.name BenefitName , PRM_Entitlement_Id__r.Core_Category__c FROM PRM_VXEnttlmntMatrix__c WHERE PRM_Partner_Benefit_Id__r.name != null and PRM_IsActive_Ind__c = true and PRM_Partner_Benefit_Id__r.PRM_InActive_Ind__c = false and  PRM_Entitlement_Id__r.Core_Category__c='Intel Partner Alliance (IPA)' GROUP BY PRM_Entitlement_Id__r.Core_Display_Name__c, PRM_Partner_Benefit_Id__r.Name, PRM_Entitlement_Id__r.Core_Category__c];
        for(AggregateResult EntBen: EntBenefitAggResult){
            if(EntToBenefitsMap.containskey((String)EntBen.get('EntName'))){
                EntToBenefitsMap.get((String)EntBen.get('EntName')).add((String)EntBen.get('BenefitName'));
                entBenifitsMap=JSON.serialize(EntToBenefitsMap); 
            } else{
                EntToBenefitsMap.put((String)EntBen.get('EntName'), new Set<String>{(String)EntBen.get('BenefitName')});
                entBenifitsMap=JSON.serialize(EntToBenefitsMap); 
            }
            
        } 
        
    }
    
    
    
    
    public Boolean checkIPAAccount(Contact con){
        List<PRM_Account_Contact_Relationship__c> listPCR = new List<PRM_Account_Contact_Relationship__c>([Select Id, Name, PRM_Status_Nm__c, PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c =: con.Id and PRM_Relationship_Id__r.Name = 'Employee' and PRM_Status_Nm__c = 'Complete' AND PRM_InActive_Ind__c = false]);
        If(listPCR.size()>0){
            return true;
        }
        return false;
    }
    
    public List<Core_Entitlement__c> filterEntitlementsByProfile() {
        Boolean entCheck = false;
        String userProfileId = UserInfo.getProfileId();
        userProfileId = userProfileId.substring(0, userProfileId.length()-3);
        String UserId = UserInfo.getUserId();
        List<String> lEntNames = new List<String>();
        List<String> lEntNames1 = new List<String>();      
	
	List<Core_Entitlement_Profile_Access__c> epaObj = new List<Core_Entitlement_Profile_Access__c>();        
        String PARTNER_PROFILE_ID = Label.Core_Partner_Profile_Id; 
        
        
        //restrict Entitlements on Account benefit----START
        List<User> userContactId = new List<User>();//CHANGE---restrict Entitlements on Account benefit
        userContactId = [Select ContactId,Email,name,Core_IPS_AccountId__c From User Where Id =: UserId];//CHANGE---restrict Entitlements on Account benefit
        List<contact> conList = new List<contact>([SELECT AccountId,Core_IPA_One_Partner_Id__c from contact where id = :idContact]);
        List<string> acctIdOpId = new List<string>();
        /*if(conList[0].AccountId != null)
            acctIdOpId.add(conList[0].AccountId);*/
        if(conList[0].Core_IPA_One_Partner_Id__c != null && conList[0].Core_IPA_One_Partner_Id__c != '')
            acctIdOpId.add(conList[0].Core_IPA_One_Partner_Id__c);
        
        for(PRM_VXEnttlmntMatrix__c entlMatrix :[select PRM_Entitlement_Id__c 
                                                 from PRM_VXEnttlmntMatrix__c 
                                                 where PRM_IsActive_Ind__c = true and RecordType.DeveloperName = 'PRM_EntitlementWithBenefits' and PRM_Partner_Benefit_Id__c 
                                                 in (Select PRM_Partner_Benefit_Id__c 
                                                     from PRM_AccountBenefitAssociation__c 
                                                     where PRM_Account_Id__c = :acctIdOpId /*:conList[0].AccountId OR PRM_Account_Id__c = :conList[0].Core_IPA_One_Partner_Id__c)*/ AND PRM_Status_Nm__c = 'Active')]){
                                                         
                                                         if(!benefitEntitlementList.contains(entlMatrix.PRM_Entitlement_Id__c))
                                                             benefitEntitlementList.add(entlMatrix.PRM_Entitlement_Id__c);             
                                                         
                                                     }
        
        for(PRM_VXEnttlmntMatrix__c entlMatrix :[select PRM_Entitlement_Id__c from PRM_VXEnttlmntMatrix__c where RecordType.DeveloperName = 'PRM_EntitlementWithBenefits' AND PRM_IsActive_Ind__c = true]){
            entlWithBenefitList.add(entlMatrix.PRM_Entitlement_Id__c);
        }
        
        //restrict Entitlements on Account benefit----END
        
        if(userProfileId.equals(PARTNER_PROFILE_ID)) //For external users
        {
            /******************************Draco : Remove dependency from Audience - START*************************************/
            //List<User> userContactId = new List<User>();//CHANGE---restrict Entitlements on Account benefit
            List<Core_Contact_Entitlement__c> lstContEnt = new List<Core_Contact_Entitlement__c>();
            List<String> lstOfEnt = new List<String> ();
            
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
            
            
            
            if(epaObj != null && !epaObj.isEmpty()) {
                entCheck = String.isBlank(epaObj[0].Core_Entitlements_Allowed__c);
            } else {
                entCheck = true;
            }
            
            if(epaObj != null && !epaObj.isEmpty() && !entCheck) {
                for(Core_Entitlement_Profile_Access__c epaObjRec : epaObj){
                    
                    if(epaObjRec.Core_Entitlements_Allowed__c != null){
                        lEntNames1= epaObjRec.Core_Entitlements_Allowed__c.split(';');
                        lEntNames.addall(lEntNames1);
                    }
                    
                }
                lstEntitlement = [SELECT Id, Core_Category__c,Core_Sub_Category__c ,Core_Help_Text__c  , Name, Core_Display_Name__c
                                  FROM Core_Entitlement__c
                                  WHERE Core_IsActive__c = true
                                  AND Name IN :lEntNames order by Core_Category__c,Core_Sub_Category__c ];
            }
            
        }
        else{ // for internal users - existing code
            epaObj = [Select id, Core_Entitlements_Allowed__c from Core_Entitlement_Profile_Access__c where Core_Profile_Id__c = :userProfileId];
            List<Core_entitlement__Share> entshare = [SELECT ParentId, Parent.Name, Parent.Core_Display_Name__c, UserOrGroup.Name, UserOrGroupId 
                                                      FROM Core_entitlement__Share 
                                                      WHERE UserOrGroupId IN (SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :UserId)];
           
            for(Core_entitlement__Share pgshare : entshare){
                lEntNames.add(pgshare.Parent.Name);
            }
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
        
        if(objContact.Core_AGS_Integration_Status__c != 'Pending'){
            try{
                String strAGSResponse = Core_HttpCallouts_Handler.getUpdatedAGSStatus(objContact);
                
                if(!String.isBlank(strAGSResponse)){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, mapConentValErrorMsg.get('UI Read Time Out')+'<a href="./Core_Contact_Entitlements?scontrolCaching=1&id='+idContact+'"><B>Reload</B></a>'+'<br/>System Error: '+strAGSResponse);
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
        
        
        
        if(objContact.Core_AGS_Integration_Status__c != PENDING_STATUS){
            try{
                String strAGSResponse = Core_HttpCallouts_Handler.getUpdatedAGSStatus(objContact);
                if(!String.isBlank(strAGSResponse) && strAGSResponse == 'NoResponse'){
                    blnIsValid = false;
                }
                //throw new MyException('AGS failure');
            }catch(Exception ex) {
                
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
        
        for (Core_Entitlement__c objEntitlement : lstEntitlement) {
            setEntitlementId.add(objEntitlement.Id);
            lstEntitlementWrapper.add(new Core_Entitlement_Wrapper(objEntitlement,helpText.get(objEntitlement.Core_Sub_Category__c )));
        }
        
        
        
        // Get existing Contact Entitlements
        lstConEnt = [SELECT Id, Core_Entitlement_Id__c,Core_Status__c, Core_Entitlement_Id__r.Core_Category__c,Core_Entitlement_Id__r.Core_Sub_Category__c ,Core_Entitlement_Id__r.Core_Help_Text__c  , Core_Entitlement_Id__r.Name, Core_Entitlement_Id__r.Core_Display_Name__c, Core_Selected__c,Core_Entitlement_Id__r.Core_AGS_Role_Id__c
                     FROM Core_Contact_Entitlement__c    
                     WHERE Core_Contact_Id__c = :idContact
                     AND Core_Entitlement_Id__c IN :setEntitlementId order by Core_Entitlement_Id__r.Core_Category__c,Core_Entitlement_Id__r.Core_Sub_Category__c ];
        
        mapConEnt = new Map<Id, Core_Contact_Entitlement__c>();
        
        // Adding All entitlement to readOnlyEntitlement as editable
        readOnlyEntitlement= new Map<String, Boolean>();
        entitlementStatus=new Map<String, String>();
        entitlementEighteenDigStatus = new Map<String, String>();
        
        for (Core_Entitlement__c entitlementObj : lstEntitlement ){
            Boolean readOnly=false;
            String status='';
            // adding 15 Digit of ID to the Map To avoid Duplicate
            readOnlyEntitlement.put((entitlementObj.Id+'').substring(0,15),readOnly);
            entitlementStatus.put((entitlementObj.Id+'').substring(0,15),status);
        }
        
        for (Core_Contact_Entitlement__c objCE : lstConEnt){
            mapConEnt.put(objCE.Core_Entitlement_Id__c, objCE);
            Boolean readOnly=false;
            String status='';
            if(objCE.Core_Status__c =='In Progress'|| objCE.Core_Status__c=='Pending' ){
                readOnly=true;
                
                status='Processing';
            }
            readOnlyEntitlement.put((objCE.Core_Entitlement_Id__c+'').substring(0,15),readOnly);
            entitlementStatus.put((objCE.Core_Entitlement_Id__c+'').substring(0,15),status);
            entitlementEighteenDigStatus.put(objCE.Core_Entitlement_Id__c,status);
        }
        
        // In case an entitlement becomes inactive, it still may be assigned to a contact - expose this.
        // Using the master set of Entitlement Ids, find any Contact Entitlements that aren't included.
        // Add them to the display list.
        for (Core_Contact_Entitlement__c objConEnt : lstConEnt) {
            if (!setEntitlementId.contains(objConEnt.Core_Entitlement_Id__c)) { 
                
                
                lstEntitlementWrapper.add(new Core_Entitlement_Wrapper(objConEnt.Core_Entitlement_Id__c, objConEnt.Core_Entitlement_Id__r.Core_Category__c,objConEnt.Core_Entitlement_Id__r.Core_Sub_Category__c ,objConEnt.Core_Entitlement_Id__r.Core_Display_Name__c, objConEnt.Core_Selected__c, objConEnt.Core_Entitlement_Id__r.Core_Help_Text__c  ,helpText.get(objConEnt.Core_Entitlement_Id__r.Core_Sub_Category__c )));
                
            }    
        }    
        
        // Update Entitlements with contact-entitlement selected value
        for (Core_Entitlement_Wrapper objEW : lstEntitlementWrapper) {
            if (mapConEnt.containsKey(objEW.idEntitlement))
                objEW.selected = mapConEnt.get(objEW.idEntitlement).Core_Selected__c;
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
            if (currentCategory != objEW.category && lstCategory.size() > 0) {
                lstlstEntitlementWrapper.add(lstCategory);
            }
            if (currentCategory != objEW.category) {  
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
                CategoryColumnName.put((cew[0].category).toUpperCase(),'COLUMN B');
                
            }
        }
        
        
        
        
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
                    if(name != null && name.containsIgnoreCase(userInput)){
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
            
        }
    }
    
    public void clear(){
        userInput = '';
        isShowSearchResults = false;
        isNotExist = false;
    }
    
    public String msgStr {get; set;}  
    public Boolean validate() {
        Boolean result = true;
        String strValidateCNDANum;
        String strValidateIsODM;
        String strValidateCimId;
        String strValidateEngagement;
        String strValidateUnifiedId;
        String strValidateIntelSupportOwner;
        String strValidateAccountOwnerRole;
        String strValidatePersonalEmailIndicator;
        String strValidateIsODMTrue;
        String strValidateIsPSGWOMTrue;
        String strValidateUniqueEntitlement;
        String strValidateConflictPolicy;
        String strValidateMPUniqueEntitlement;
        String strvalidateAccountEnglishOnlyFields;
        String strvalidateContactEnglishOnlyFields;
        String strValidateACR;
	String strValidateEntitlementRemoval;
        //String strValidateDCBCUniqueEntitlement;
        string strValidateEntlOnBenefits;/*Restrict entitlements on Account Benefit*/
        
        Set<Id> selectedEntitlementIds = new Set<Id>();
        Map<Id, Contact> mUpdateContEngName = new Map<Id, Contact>();
        Map<Id, Account> mUpdateAcctEngName = new Map<Id, Account>();
        
        // List<String> lstOfEntitlementForException = new List<String>();
        // String EntitlementsForException = System.Label.Core_Benefit_Exception;
        // lstOfEntitlementForException = EntitlementsForException.split(';');
        
        
        List<String> lstOfEntitlementForSuppressHardValidation = new List<String>();
        List<Core_GA_Page_Validation_Control__c> GA_Page_Validation_Control = new List<Core_GA_Page_Validation_Control__c>();
        GA_Page_Validation_Control = Core_GA_Page_Validation_Control__c.getAll().values();
        
        for(Core_GA_Page_Validation_Control__c GA_Page_VC :GA_Page_Validation_Control){
            if(GA_Page_VC.cCore_Suppress_Hard_Validation__c){
                lstOfEntitlementForSuppressHardValidation.add(GA_Page_VC.Core_Entitlement_Display_Name__c);
            }
        }
        
        for (List<Core_Entitlement_Wrapper> lstEW : lstlstEntitlementWrapper) {
            for (Core_Entitlement_Wrapper objEW : lstEW) {
               String entitlementName = (objEW.strName != null) ? objEW.strName.trim() : '';
                if(objEW.selected) {
                    selectedEntitlementIds.add(objEW.idEntitlement);
                    if(!Core_ContactEntitlementValidation.validateEnglishOnlyFields(objContact, mUpdateContEngName, mUpdateAcctEngName) ) {
                        
                        
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
                        
                        
                    }
                    
                    if(!Core_ContactEntitlementValidation.validateCimId(objEW.idEntitlement, objContact)) {
                        if(String.isBlank(strValidateCimId)){
                            strValidateCimId = objEW.strName;
                        }else{
                            strValidateCimId = strValidateCimId+', '+objEW.strName;
                        }
                        result = false;
                    }
                    List<Core_Contact_Entitlement__c> coreAllEntitlementList = new List<Core_Contact_Entitlement__c>();
                    for(Core_Contact_Entitlement__c conEnt : objContact.Contact_Entitlements__r){
                        coreAllEntitlementList.add(conEnt);
                    }
                    if(!Core_ContactEntitlementValidation.validateEngagement(objEW.idEntitlement, objContact, coreAllEntitlementList)) {
                        if(String.isBlank(strValidateEngagement)){
                            strValidateEngagement = objEW.strName;
                        }else{
                            strValidateEngagement = strValidateEngagement+', '+objEW.strName;
                        }
                        result = false;
                    }
                    if(!Core_ContactEntitlementValidation.validateUnifiedId(objEW.idEntitlement, objContact)) {
                        if(String.isBlank(strValidateUnifiedId)){
                            strValidateUnifiedId = objEW.strName;
                        }else{
                            strValidateUnifiedId = strValidateUnifiedId+', '+objEW.strName;
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
                    if(!Core_ContactEntitlementValidation.validatePSGWOM(objEW.idEntitlement, objContact)) {
                        if(String.isBlank(strValidateIsPSGWOMTrue)){
                            strValidateIsPSGWOMTrue = objEW.strName;
                        }else{
                            strValidateIsPSGWOMTrue = strValidateIsPSGWOMTrue+', '+objEW.strName;
                        }
                        
                        result = false;
                    }
                    
                    if(!Core_ContactEntitlementValidation.validateConflictPolicy(objEW.idEntitlement, objContact, objEW.strName)) {
                        strValidateConflictPolicy = Core_ContactEntitlementValidation.conflictPolicyValidationMessage;
                        result = false;
                    }
                    if(!Core_ContactEntitlementValidation.validateUniqueEntitlement(objEW.idEntitlement, objContact, objEW.strName)) {
                        
                        strValidateUniqueEntitlement = Core_ContactEntitlementValidation.uniqueEntitlementNames;
                        result = false;
                    }
                    
                    if(objEW.idEntitlement == System.Label.Core_Employee || objEW.idEntitlement == System.Label.Core_Lead_Development_Representative || objEW.idEntitlement == System.Label.Core_Marketing_specialist ||objEW.idEntitlement == System.Label.Core_Partner_Admin ||objEW.idEntitlement == System.Label.Core_Partner_Admin_Delegate )
                    {
                        
                        if(!Core_ContactEntitlementValidation.validateUniqueMPEntitlement(objEW.idEntitlement, objContact, objEW.strName)) {
                            strValidateMPUniqueEntitlement = Core_ContactEntitlementValidation.uniqueEntitlementNames1;
                            result = false;
                        }
                    }
                    
                    
                    if (
                        ((objEW.idEntitlement == System.Label.Core_Employee || objEW.idEntitlement == System.Label.Core_Partner_Admin || objEW.idEntitlement == System.Label.Core_Partner_Admin_Delegate))
                        && !Core_ContactEntitlementValidation.validateIPAContactRelationship(objContact.Id, entitlementName)
                    ) {
                        if (String.isBlank(strValidateACR)) {
                            strValidateACR = entitlementName;
                        } else if (!strValidateACR.contains(entitlementName)) {
                            strValidateACR += ', ' + entitlementName;
                        }
                        result = false;
                    }

                    
		

                    
                    /*if(objEW.idEntitlement == System.Label.Core_CTO_Distributor || objEW.idEntitlement == System.Label.Core_CTO_Reseller){
                        
                        if(!Core_ContactEntitlementValidation.validateDCBCUniqueEntitlement(objEW.idEntitlement, objContact, objEW.strName)) {
                            strValidateDCBCUniqueEntitlement = Core_ContactEntitlementValidation.uniqueEntitlementNames2;
                            result = false;
                        }
                    }*/
                    
                    if(objEW.strCategory == 'Intel Partner Alliance (IPA)' && entlWithBenefitList.contains(objEW.idEntitlement) && !lstOfEntitlementForSuppressHardValidation.contains(objEW.strName)){// excluding the PVP from IPA category
                        if(!Core_ContactEntitlementValidation.validateAccountBenefit(objEW.idEntitlement,benefitEntitlementList)){
                            
                            if(String.isBlank(strValidateEntlOnBenefits)){
                                strValidateEntlOnBenefits = objEW.strName;
                            }                            
                            else {
                                strValidateEntlOnBenefits = strValidateEntlOnBenefits +', '+objEW.strName;
                            }
                            result = false;
                            
                        }
                    }
                    /*END-----Restrict entitlements on Account Benefit-------*/
                }
                else {
                if (
                    (objEW.idEntitlement == System.Label.Core_Employee ||
                     objEW.idEntitlement == System.Label.Core_Partner_Admin ||
                     objEW.idEntitlement == System.Label.Core_Partner_Admin_Delegate)
                ) {
                    Boolean wasAssigned = false;
                    List<Core_Contact_Entitlement__c> lstExistingContactEntitlements = [SELECT Core_Entitlement_Id__c FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c = :objContact.Id];
                    for (Core_Contact_Entitlement__c existingEnt : lstExistingContactEntitlements) {
                        if (existingEnt.Core_Entitlement_Id__c == objEW.idEntitlement) {
                            wasAssigned = true;
                            break;
                        }
                    }

                    if (wasAssigned && Core_ContactEntitlementValidation.validateIPAContactRelationship(objContact.Id, entitlementName)) {

                        if (String.isBlank(strValidateEntitlementRemoval)) {
                            strValidateEntitlementRemoval = entitlementName;
                        } else if (!strValidateEntitlementRemoval.contains(entitlementName)) {
                            strValidateEntitlementRemoval += ', ' + entitlementName;
                        }
                        result = false;
                    }
                }
                }
     

            }
        }
        if(mUpdateContEngName.size() > 0){
            
            //update mUpdateContEngName.values();
        }
        if(mUpdateAcctEngName.size() > 0){
            update mUpdateAcctEngName.values();
        }
        /*START-----Restrict entitlements on Account Benefit-------*/
        if(!String.isBlank(strValidateEntlOnBenefits)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, mapConentValErrorMsg.get('UI Account Benefits') +' '+ strValidateEntlOnBenefits);
            ApexPages.addMessage(myMsg);
        }
        /*END-----Restrict entitlements on Account Benefit-------*/ 
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
        if(!String.isBlank(strValidateEngagement)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI PSG Basic') +' '+ strValidateEngagement);
            ApexPages.addMessage(myMsg);
        }
        if(!String.isBlank(strValidateUnifiedId)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI Unified ID') +' '+ strValidateUnifiedId);
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
        if(!String.isBlank(strValidateIsPSGWOMTrue)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI PSG WOM') +' '+ strValidateIsPSGWOMTrue);
            ApexPages.addMessage(myMsg);
        }
        if(!String.isBlank(strValidateConflictPolicy)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, strValidateConflictPolicy);
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
        if (!String.isBlank(strValidateACR)) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI IPA Contact Relationship')+' '+ strValidateACR);
            ApexPages.addMessage(myMsg);
        }
		if (!String.isBlank(strValidateEntitlementRemoval)) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI IPA ENT Removal')+' '+ strValidateEntitlementRemoval);
            ApexPages.addMessage(myMsg);
        }
       
       
        //Sonali START (US731136 - Pipeline: CTO Requirement)
        /*if(!String.isBlank(strValidateDCBCUniqueEntitlement)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI Single Entitlement Assignment'));
            ApexPages.addMessage(myMsg);
            msgStr = mapConentValErrorMsg.get('UI Single Entitlement Assignment');
            
        }*/
        
        return result;
    }
    
    
    public pageReference onSave() {
        
        if (!validate()){
            
            return NULL;
        }
        
        List<Exception> exptions = saveContactEntitlements(lstlstEntitlementWrapper,UPDATE_REASON_GRANT_ACCESS);
        if(exptions.size() > 0){
            Apexpages.addMessages(exptions.get(0));              
            return NULL;
        } 
        
        return onReturnPress();
    }
    
    public List<Exception> saveContactEntitlements(List<List<Core_Entitlement_Wrapper>> localLstlstEntitlementWrapper,String updateReason){    
        
        List<Exception> exceptionMessages = new List<Exception>();
        
        for(Core_Entitlement_Wrapper cew : localLstlstEntitlementWrapper[0]){
            
        }
        
        Core_Contact_Entitlement__c objConEn;
        lstConEnt = new List<Core_Contact_Entitlement__c>();
        
        for (List<Core_Entitlement_Wrapper> lstEW : localLstlstEntitlementWrapper) { 
            for (Core_Entitlement_Wrapper objEW : lstEW) {
                if (mapConEnt.containsKey(objEW.idEntitlement)) {
                    objConEn = mapConEnt.get(objEW.idEntitlement);
                    if (objEW.selected && !objConEn.Core_Selected__c) {
                        objConEn.Core_Selected__c = objEW.selected;
                        objConEn.Core_Status__c='Pending';
                        objConEn.Core_Entitlement_Requester_Id__c = UserInfo.getUserId();
                        objConEn.Core_Email_Pending_To_Requester_Ind__c = true;
                        lstConEnt.add(objConEn);
                    } else if(objEW.selected && objConEn.Core_Selected__c) {
                        // Don't do anything because nothing changed.
                    } else { 
                        if(objConEn.Core_Selected__c != false) {
                            objConEn.Core_Selected__c = false;
                            objConEn.Core_Status__c='Pending';
                            objConEn.Core_Entitlement_Requester_Id__c = UserInfo.getUserId();
                            objConEn.Core_Email_Pending_To_Requester_Ind__c = true;
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
        
        Boolean updated = false;
        if (lstConEnt.size() > 0) {
            try{
                if(lstConEnt != null && !lstConEnt.isEmpty()){
                    //upsert lstConEnt;
                    Database.upsert(lstConEnt, false);
                    updated = true;                    
                }
                
            } catch(Exception e) {
                exceptionMessages.add(e);
                lstConEnt = new List<Core_Contact_Entitlement__c>();
                return exceptionMessages;
            }
        }
        
        
        if(updated) {
            
            objContact = [SELECT Id, Name,Email,FirstName,LastName,Core_Enterprise_Id__c, AccountId, Account.Name, Account.Core_CNDA_Number__c, Account.Core_IPS_Active__c,Account.PRM_Count_IPA_Terms_And_Conditions__c,
                          Core_IPS_Intel_Support_Owner__c, Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c,Account.Owner.UserRole.Name, Core_Contact_B2B_Indicator__c,
                          Account.Core_IsODM__c,Account.Core_IPS_PSG_WOM_Check__c,Core_Set_ERPM_Status_Bypass__c, Account.Core_CIM_ID__c,Account.Core_Business_Party_Id__c, Core_Personal_Email_Indicator__c, Core_ERPM_Integration_Queue_txt__c,
                          Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c,Account.Core_English_Only_Name__c,Core_Local_Last_Name__c,Core_Local_First_Name__c,Account.Core_Alternate_Language_Name__c,Account.Core_Deactivated__c,Account.Core_Deactivation_Reason__c,Core_AGS_Republish_Ind__c,
                          (SELECT id,name,Core_Entitlement_Nm__c,Core_Status__c, Core_Selected__c,Core_Entitlement_Id__r.Id,Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__c,Core_Entitlement_Id__r.Core_Entitlement_Type__c FROM contact_entitlements__r)
                          FROM Contact WHERE Id = :idContact LIMIT 1];
            
            
            startedFromGA = true; //This variable will tell wheather the transaction is initiated from GA page. Used in Core_Entitlement_Outbound_Integrations from ERPM bypass
            boolean hasEntWithERPMEnga = false;
	    for(Core_Contact_Entitlement__c conEnt : objContact.Contact_Entitlements__r){ 
                if(conEnt.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__c != null && conEnt.Core_Status__c == 'Pending'){
                    hasEntWithERPMEnga = true;
                }
            }
            
            if(hasEntWithERPMEnga){
                objContact = [SELECT Id, Name,Email,FirstName,LastName,Core_Enterprise_Id__c, AccountId, Account.Name, Account.Core_CNDA_Number__c, Account.Core_IPS_Active__c,Account.PRM_Count_IPA_Terms_And_Conditions__c,
                              Core_IPS_Intel_Support_Owner__c, Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c,Account.Owner.UserRole.Name, Core_Contact_B2B_Indicator__c,
                              Account.Core_IsODM__c,Account.Core_IPS_PSG_WOM_Check__c, Core_Set_ERPM_Status_Bypass__c, Account.Core_CIM_ID__c,Account.Core_Business_Party_Id__c, Core_Personal_Email_Indicator__c, Core_ERPM_Integration_Queue_txt__c,
                              Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c,Account.Core_English_Only_Name__c,Core_Local_Last_Name__c,Core_Local_First_Name__c,Account.Core_Alternate_Language_Name__c,Account.Core_Deactivated__c,Account.Core_Deactivation_Reason__c,Core_AGS_Republish_Ind__c,
                              (SELECT id,name,Core_Entitlement_Nm__c,Core_Status__c, Core_Selected__c,Core_Entitlement_Id__r.Id FROM contact_entitlements__r)
                              FROM Contact WHERE Id = :idContact LIMIT 1];
                if(objContact.Core_ERPM_Integration_Status__c != 'Pending' && objContact.Core_ERPM_Integration_Status__c != 'In-Progress') {
                    objContact.Core_ERPM_Integration_Status__c = 'Pending';
                    objContact.Core_ERPM_Integration_Queue_txt__c = 'Empty';                    
                } else if((objContact.Core_ERPM_Integration_Status__c == 'Pending' || objContact.Core_ERPM_Integration_Status__c == 'In-Progress') 
                          && objContact.Core_ERPM_Integration_Queue_txt__c != 'Full') {
                              objContact.Core_ERPM_Integration_Queue_txt__c = 'Full';
                          }
            }
            // ******************* Draco Updates - END - [08-01-2022] - Dont change ERPM Integration Status in case of 2.0 flow*******************
            
            /***********************Draco : AGS Multiple OBM issue 14 Aug - START****************************/
            if(objContact.Core_AGS_Integration_Status__c != 'Pending' && objContact.Core_AGS_Integration_Status__c!= 'In-Progress'){
                objContact.Core_AGS_Integration_Status__c = 'Pending';
                objContact.Core_AGS_Republish_Ind__c = false;
                
            }
            else if(( objContact.Core_AGS_Integration_Status__c == 'In-Progress')
                    && !objContact.Core_AGS_Republish_Ind__c){
                        objContact.Core_AGS_Republish_Ind__c = true;
                    }
            
            /***********************Draco : AGS Multiple OBM issue 14 Aug - END******************************/
            if(!isUpdtateCon){
                //isUpdtateCon = true;
                update objContact;
            }
            
        } 
        return exceptionMessages;
    }
    
    public pageReference onReturnPress() {
        String url = '';
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
    
    public void checkEntitlementSubordinates() {
        
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
                if (subcategory == rec.subcategory && name> rec.name){
                    return greaterValue;
                    
                }
            }  
            return lesserValue ;
        }
    }
}