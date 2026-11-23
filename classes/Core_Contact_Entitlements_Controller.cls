public class Core_Contact_Entitlements_Controller {

    //Start---added code For Validation from Custom setting
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
    public List<List<Core_Entitlement_Wrapper>> lstlstEntitlementWrapper { get; set; }
    
    public String strReturnURL;
    public Id     idContact{get;set;}
    
    private String strAccountName;
    
    private List<Core_Entitlement__c>            lstEntitlement;
    private List<Core_Contact_Entitlement__c>    lstConEnt;
    private Map<Id, Core_Contact_Entitlement__c> mapConEnt;
    
    private List<Core_Entitlement_Wrapper>       lstEntitlementWrapper;
    private Contact objContact;
    
    private final String UPDATE_REASON_GRANT_ACCESS = 'Grant Access';
      
    
    public Core_Contact_Entitlements_Controller(ApexPages.StandardController controller) {
       
        
        idContact    = ApexPages.currentPage().getParameters().get('Id');
        strReturnURL = '//' + idContact;
        //Disabled Entitlement checkbox on the page
        disabledEntitlement=Label.Core_Entitlement_Disable_Grant_Access;
        disabledEntitlement2=Label.Entitlement_Disable_Grant_Access2;
        Set<Id> validatedIds = new Set<Id>();
        
        objContact = [SELECT Id, Name,FirstName,LastName,Core_Enterprise_Id__c, AccountId, Account.Name, Account.Core_CNDA_Number__c, Account.Core_IPS_Active__c,
                      Core_IPS_Intel_Support_Owner__c, Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c,Account.Owner.UserRole.Name,
                      Account.Core_IsODM__c, Core_Set_ERPM_Status_Bypass__c, Account.Core_CIM_ID__c, Core_Personal_Email_Indicator__c,
                      Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c,Account.Core_English_Only_Name__c,Core_Local_Last_Name__c,Core_Local_First_Name__c,Account.Core_Alternate_Language_Name__c,Account.Core_Deactivated__c,Account.Core_Deactivation_Reason__c 
                      FROM Contact 
                      WHERE Id = :idContact 
                      LIMIT 1];                
        
       /* if (objContact.AccountId == NULL) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'Contact must be assigned to an Account.');
            ApexPages.addMessage(myMsg);
            blnIsValid = false;
            
            // Cannot access account fields - RETURN
            return;
        }    */    
        
        strContactName = objContact.Name;
        strAccountName = objContact.Account.Name;
        
        Core_Test_Utility.checkRecordEditAccess(UserInfo.getUserId(), new Set<Id>{objContact.AccountId}, validatedIds);
        
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
        
     System.debug('    objContact.Core_Set_ERPM_Status_Bypass__c '+objContact.Core_Set_ERPM_Status_Bypass__c);        
    }
    
    public void filterEntitlementsByProfile() {
        Boolean entCheck = false;
        String userProfileId = UserInfo.getProfileId();
        userProfileId = userProfileId.substring(0, userProfileId.length()-3);
        List<String> lEntNames = new List<String>();
        System.debug('Zay Userprofileid - ' + userProfileId);
        List<Core_Entitlement_Profile_Access__c> epaObj = [Select id, Core_Entitlements_Allowed__c from Core_Entitlement_Profile_Access__c where Core_Profile_Id__c = :userProfileId];
        
        System.debug('epaObj - ' + epaObj);
        if(epaObj != null && !epaObj.isEmpty()) {
            entCheck = String.isBlank(epaObj[0].Core_Entitlements_Allowed__c);
        } else {
            entCheck = true;
        }
        if(epaObj != null && !epaObj.isEmpty() && !entCheck) {
            System.debug(lEntNames);
            lEntNames = epaObj[0].Core_Entitlements_Allowed__c.split(';');
        }
        system.debug('lEntNames '+lEntNames );
        lstEntitlement = [SELECT Id, Core_Category__c,Core_Sub_Category__c ,Core_Help_Text__c  , Name, Core_Display_Name__c
                          FROM Core_Entitlement__c
                          WHERE Core_IsActive__c = true
                          AND Name IN :lEntNames order by Core_Category__c,Core_Sub_Category__c ];
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
            system.debug('helpText Subcat : '+helpText.get(objEntitlement.Core_Sub_Category__c ));
            lstEntitlementWrapper.add(new Core_Entitlement_Wrapper(objEntitlement,helpText.get(objEntitlement.Core_Sub_Category__c )));
        }
        
        // Get existing Contact Entitlements
        lstConEnt = [SELECT Id, Core_Entitlement_Id__c,Core_Status__c, Core_Entitlement_Id__r.Core_Category__c,Core_Entitlement_Id__r.Core_Sub_Category__c ,Core_Entitlement_Id__r.Core_Help_Text__c  , Core_Entitlement_Id__r.Name, Core_Entitlement_Id__r.Core_Display_Name__c, Core_Selected__c
                     FROM Core_Contact_Entitlement__c    
                     WHERE Core_Contact_Id__c = :idContact
                     AND Core_Entitlement_Id__c IN :setEntitlementId order by Core_Entitlement_Id__r.Core_Category__c,Core_Entitlement_Id__r.Core_Sub_Category__c ];
        
        mapConEnt = new Map<Id, Core_Contact_Entitlement__c>();
        
        // Adding All entitlement to readOnlyEntitlement as editable
        readOnlyEntitlement= new Map<String, Boolean>();
        entitlementStatus=new Map<String, String>();
        for (Core_Entitlement__c entitlementObj : lstEntitlement ){
            Boolean readOnly=false;
            String status='';
            // adding 15 Digit of ID to the Map To avoid Duplicate
            readOnlyEntitlement.put((entitlementObj.Id+'').substring(0,15),readOnly);
            entitlementStatus.put((entitlementObj.Id+'').substring(0,15),status);
        }
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
        }
        system.debug('Prem === Final readOnlyEntitlement Map::'+readOnlyEntitlement.size());
        // In case an entitlement becomes inactive, it still may be assigned to a contact - expose this.
        // Using the master set of Entitlement Ids, find any Contact Entitlements that aren't included.
        // Add them to the display list.
        for (Core_Contact_Entitlement__c objConEnt : lstConEnt) {
            if (!setEntitlementId.contains(objConEnt.Core_Entitlement_Id__c)) { 
                system.debug('helpText Entitle: '+helpText.get(objConEnt.Core_Entitlement_Id__r.Core_Sub_Category__c ));
                
                lstEntitlementWrapper.add(new Core_Entitlement_Wrapper(objConEnt.Core_Entitlement_Id__c, objConEnt.Core_Entitlement_Id__r.Core_Category__c,objConEnt.Core_Entitlement_Id__r.Core_Sub_Category__c ,objConEnt.Core_Entitlement_Id__r.Core_Display_Name__c, objConEnt.Core_Selected__c, objConEnt.Core_Entitlement_Id__r.Core_Help_Text__c  ,helpText.get(objConEnt.Core_Entitlement_Id__r.Core_Sub_Category__c )));
            }    
        }    
        
        
        // Update Entitlements with contact-entitlement selected value
        for (Core_Entitlement_Wrapper objEW : lstEntitlementWrapper) {
            if (mapConEnt.containsKey(objEW.idEntitlement))
                objEW.selected = mapConEnt.get(objEW.idEntitlement).Core_Selected__c;                                
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
        
        return NULL;
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
        String strvalidateAccountEnglishOnlyFields;
        String strvalidateContactEnglishOnlyFields;
       
        Map<Id, Contact> mUpdateContEngName = new Map<Id, Contact>();
        Map<Id, Account> mUpdateAcctEngName = new Map<Id, Account>();
        system.debug('lstlstEntitlementWrapper '+lstlstEntitlementWrapper);
        for (List<Core_Entitlement_Wrapper> lstEW : lstlstEntitlementWrapper) {
            for (Core_Entitlement_Wrapper objEW : lstEW) {
                //system.debug('objEW$$$$$$$$$$$$$$ '+objEW);
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
                        strValidateUniqueEntitlement = Core_ContactEntitlementValidation.uniqueEntitlementNames;
                        result = false;
                    }
         
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
        if(!String.isBlank(strvalidateContactEnglishOnlyFields)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI English on Contact') +' '+ strvalidateContactEnglishOnlyFields);
            ApexPages.addMessage(myMsg);
        }
        if(!String.isBlank(strvalidateAccountEnglishOnlyFields)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,mapConentValErrorMsg.get('UI English on Account') +' '+ strvalidateAccountEnglishOnlyFields);
            ApexPages.addMessage(myMsg);
        }
        return result;             
    }
    
    
    public pageReference onSave() {    
        if (!validate())
            return NULL;
        
        System.debug('#51 lstlstEntitlement: ' + lstlstEntitlementWrapper);
        
        //List<Core_Contact_Entitlement__c> lstDeleteConEn = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c objConEn;
        lstConEnt = new List<Core_Contact_Entitlement__c>();
        
        for (List<Core_Entitlement_Wrapper> lstEW : lstlstEntitlementWrapper) {
            for (Core_Entitlement_Wrapper objEW : lstEW) {
                if (mapConEnt.containsKey(objEW.idEntitlement)) {
                    objConEn = mapConEnt.get(objEW.idEntitlement);
                    System.debug('objEW.selected objConEn.Core_Selected__c'+objConEn.Core_Selected__c+objEW.selected);
                    if (objEW.selected && !objConEn.Core_Selected__c) {
                        objConEn.Core_Selected__c = objEW.selected;
                        objConEn.Core_Status__c='Pending';
                        objConEn.Core_Update_Reason__c = UPDATE_REASON_GRANT_ACCESS;
                        lstConEnt.add(objConEn);
                    } else if(objEW.selected && objConEn.Core_Selected__c) {
                        // Don't do anything because nothing changed.
                    } else { 
                        if(objConEn.Core_Selected__c != false) {
                            objConEn.Core_Selected__c = false;
                            objConEn.Core_Status__c='Pending';
                            objConEn.Core_Update_Reason__c = UPDATE_REASON_GRANT_ACCESS;
                            //lstDeleteConEn.add(objConEn); 
                            lstConEnt.add(objConEn);    
                        }
                    }
                    
                } else if (objEW.selected) {
                    objConEn = new Core_Contact_Entitlement__c(Core_Contact_Id__c=idContact, 
                                                               Core_Entitlement_Id__c=objEW.idEntitlement,Core_Status__c='Pending',
                                                               Core_Selected__c=true);
                    objConEn.Core_Update_Reason__c = UPDATE_REASON_GRANT_ACCESS;
                    lstConEnt.add(objConEn);            
                }    
            }
        }
        
        System.debug('#55 lstConEnt: ' + lstConEnt);
        Boolean updated = false;
        if (lstConEnt.size() > 0) {
            try{
                System.debug('Zay - upserting in contact entitlements controller >>  '+lstConEnt);
                upsert lstConEnt;
                updated = true;
            } catch(Exception e) {
                Apexpages.addMessages(e);
                lstConEnt = new List<Core_Contact_Entitlement__c>();
                return null;
            }
        }
        /*if (lstDeleteConEn.size() > 0) {
            System.debug('Zay - updating deletion in contact entitlements controller');
            update lstDeleteConEn;
            updated = true;
        }*/
        
        
       if(updated) {
            objContact.Core_ERPM_Integration_Status__c = 'Pending';
            objContact.Core_AGS_Integration_Status__c = 'Pending';
            
            update objContact;
        }
        
        return onReturnPress();
    }
    
    
    public pageReference onReturnPress() {
        String url = '';
        if(UserInfo.getUiThemeDisplayed() == 'Theme3'){
            url = strReturnUrl;
        }else{
            url = '/one/one.app?#/sObject/'+ idContact + '/view';
        }
        PageReference prPage = new PageReference(url);    
        prPage.setRedirect(true);
        
         return prPage;
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
        
        public Core_Entitlement_Wrapper(Core_Entitlement__c objEntitlement,String strSubCatHelpText1) {
            idEntitlement = objEntitlement.Id;
            strCategory   = objEntitlement.Core_Category__c;
            strName       = objEntitlement.Core_Display_Name__c;
            strSubCategory = objEntitlement.Core_Sub_Category__c ;
            strEntitleHelpText    = objEntitlement.Core_Help_Text__c  ; 
            strSubCatHelpText    = strSubCatHelpText1;
        }        
        
        public Core_Entitlement_Wrapper(Id idEnt, String strEngCat, String strEngSubCat, String strEngName, Boolean blnSelected, String strEngEntitleHelpText, String strEngSubCatHelpText1) {
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