public class Core_ContactEntitlementValidation {
    //Start---added by popcornapps
    public static List<Core_Contact_Entitlement_Validation__c> lstconentval = Core_Contact_Entitlement_Validation__c.getall().values();
    public static Map<Id,Core_Contact_Entitlement_Validation__c> mapentIds = new Map<Id,Core_Contact_Entitlement_Validation__c>();
    public static List<Core_Contact_Entitlement_Validation_Req__c> lsteng = Core_Contact_Entitlement_Validation_Req__c.getall().values();
    public static map<Id,String> mapENtReqMessages = new Map<Id,String>();
    public static List<Core_Contact_Ent_Validation_Message__c> lstConentValErrorMsg = Core_Contact_Ent_Validation_Message__c.getall().values();
    public static Map<String,String> mapConentValErrorMsg = new Map<String,String>();
    public static Map<Id,Set<Id>> mapContactEntitlement= new Map<Id,set<Id>>();
    //public static Map<Id,String> newMapEntitlement= new Map<Id,String>();//Geetha
    public static Integer count =0;
    public static Integer ipscount=0;
    public static Map<Id,Integer> mapContactIds = new Map<Id,Integer>();
    public static Map<Id,Integer> mapIPSContactIds = new Map<Id,Integer>();
    static {
        //System.debug('lstconentval ::'+lstconentval);
        //System.debug('lsteng ::'+lsteng );
        for(Core_Contact_Entitlement_Validation__c csvalidation:lstconentval){
            mapentIds.put(csvalidation.Core_Entitlement_Id__c,csvalidation);
        }
        for(Core_Contact_Entitlement_Validation_Req__c engvalidation:lsteng){
            mapENtReqMessages.put(engvalidation.Core_Entitlement_Id__c,engvalidation.Core_Entitlement_SysMsgName__c);
        }
        for(Core_Contact_Ent_Validation_Message__c validationErrorMsg:lstConentValErrorMsg){
            String errormessage2='';
            if(validationErrorMsg.Core_Error_Message2__c!=null){
                errormessage2=validationErrorMsg.Core_Error_Message2__c;
            }
            mapConentValErrorMsg.put(validationErrorMsg.Name,validationErrorMsg.Core_Error_Message__c+errormessage2);
        }
        //System.debug('mapentIds ::'+ mapentIds);
        //System.debug('mapConentValErrorMsg ::'+ mapConentValErrorMsg);
        
    }
    //End----added by popcornapps
    public static List<Id> lContactIdsforEnt =new List<Id>();
    public static void validateContactEntitlement(List<Core_Contact_Entitlement__c> oldList, List<Core_Contact_Entitlement__c> newFullList, 
                                                  Map<Id,Core_Contact_Entitlement__c> oldMap, Map<Id,Core_Contact_Entitlement__c> newMap)
    {
        
        List<Id> lContactIds = new List<Id>();
        List<Contact> lContacts = new List<Contact>(); 
        count =0;
        ipscount=0;
        mapContactIds = new Map<Id,Integer>();
        mapIPSContactIds = new Map<Id,Integer>();
        Map<Core_Contact_Entitlement__c, Contact> mContEntitlements = new Map<Core_Contact_Entitlement__c, Contact>();
        Map<Core_Contact_Entitlement__c, String> mEntitlements = new Map<Core_Contact_Entitlement__c, String>();
        Map<Id, Boolean> mEntActive = new Map<Id, Boolean>();
        
        // Filtering Contact Entitlement with only selected true for validation
        List<Core_Contact_Entitlement__c> newList = new List<Core_Contact_Entitlement__c>();
        for(Core_Contact_Entitlement__c ce: newFullList){
            if(ce.Core_Selected__c ){
                newList.add(ce);
            }
        }
        
        for(Core_Contact_Entitlement__c c : newList) {
            lContactIds.add(c.Core_Contact_Id__c);
        }
        //Added by Geetha as per user story US113583
        validateEntitlementType(lContactIds);
        // Added by prem
        List<Core_Contact_Entitlement__c> coreAllEntitlementList=[Select id,Core_Contact_Id__c,Core_Type__c,Core_Selected__c,
                                                                  Core_Entitlement_Id__r.Name,Core_Entitlement_Id__c
                                                                  from Core_Contact_Entitlement__c 
                                                                  where Core_Contact_Id__c =:lContactIds
                                                                  AND Core_Selected__c = true];
        
        if(lContactIds != null && !lContactIds.isEmpty()) {
            List<Contact> contactRecords = [Select Id, Name, AccountId, Account.Name, Account.Core_CNDA_Number__c,Account.Owner.UserRole.Name, 
                                            Account.Core_IPS_Active__c, Core_IPS_Intel_Support_Owner__c, Account.Core_IsODM__c,
                                            Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c, FirstName, LastName,
                                            Core_Local_First_Name__c, Core_Local_Last_Name__c, Account.Core_English_Only_Name__c,
                                            Account.Core_Alternate_Language_Name__c, Core_Contact_B2B_Indicator__c,Account.Core_IPS_PSG_WOM_Check__c ,
                                            Account.Core_B2B_Entitlement__c, Core_Set_ERPM_Status_Bypass__c, Account.Core_CIM_ID__c,
                                            Core_Personal_Email_Indicator__c
                                            FROM Contact 
                                            WHERE Id IN :lContactIds];
            List<Core_Entitlement__c> entitlementRecords = [SELECT Id, Core_ERPM_Engagement_Id__r.Core_Technical_DeDup_Number__c, Core_IsActive__c
                                                            FROM Core_Entitlement__c];
            
            for(Core_Entitlement__c ce : entitlementRecords){
                mEntActive.put(ce.Id, ce.Core_IsActive__c);                
            }
            
            Map<Id, Contact> mUpdateContEngName = new Map<Id, Contact>();
            Map<Id, Account> mUpdateAcctEngName = new Map<Id, Account>();   
            
            for(Core_Contact_Entitlement__c contEntObj : newList) 
            {
                //Skip english only validation if entitlement is InActive OR for existing entitlements
                boolean skipEntValidation = skipEntValidation(contEntObj, mEntActive);
                
                //System.debug(' skipValidation '+skipEntValidation);
                //System.debug(' mEntActive '+mEntActive);
                //System.debug(' newMap '+newMap);
                //System.debug(' newMap '+oldMap);
                //System.debug(' contEntObj.Id '+contEntObj.Id+ ' contEntObj.Core_Contact_Id__c '+contEntObj.Core_Contact_Id__c);
                //System.debug('contactRecords=====>'+contactRecords);
                for(Contact contactObj : contactRecords) {
                    
                    boolean validateEnglishOnlyFields = validateEnglishOnlyFields(contactObj, mUpdateContEngName, mUpdateAcctEngName);
                    // Call the local language methods to validate English Only Fields
                    //System.debug('Zay - Outside validate English Only Loop '+contactObj.AccountId);
                    //if(!validateEnglishOnlyFields(contactObj)) {
                    //System.debug('validateEnglishOnlyFields=====>'+!validateEnglishOnlyFields);
                    //System.debug('contEntObj.Core_From_Source__c=====>'+!contEntObj.Core_From_Source__c);
                    //System.debug('!skipEntValidation=====>'+!skipEntValidation);
                    if(!validateEnglishOnlyFields && !contEntObj.Core_From_Source__c && !skipEntValidation  ) {
                        //System.debug('Zay - Inside validate English Only Loop');
                        if(String.isBlank(contactObj.Account.Core_English_Only_Name__c)&&(mapentIds.keySet().contains(contEntObj.Core_Entitlement_Id__c) && mapentIds.get(contEntObj.Core_Entitlement_Id__c).Core_Account_English_Only_Name__c)){
                            contEntObj.addError(mapConentValErrorMsg.get('System English on Account'));
                        }
                        if((String.isBlank(contactObj.Core_English_Only_First_Name__c) || String.isBlank(contactObj.Core_English_Only_Last_Name__c)) && (mapentIds.keySet().contains(contEntObj.Core_Entitlement_Id__c) && mapentIds.get(contEntObj.Core_Entitlement_Id__c).Core_Contact_English_Only_Name__c)) {
                            contEntObj.addError(mapConentValErrorMsg.get('System English on Contact'));
                        }
                        
                        /* if(String.isBlank(contactObj.Core_English_Only_First_Name__c) || String.isBlank(contactObj.Core_English_Only_Last_Name__c)) {
contEntObj.addError(mapConentValErrorMsg.get('System English on Contact'));
}
if(String.isBlank(contactObj.Account.Core_English_Only_Name__c)){
contEntObj.addError(mapConentValErrorMsg.get('System English on Account'));
}*/
                    }
                    // Create a map of contact entitlements to contacts in preparation for validations
                    if(contEntObj.Core_Contact_Id__c == contactObj.Id) {
                        mContEntitlements.put(contEntObj, contactObj);       
                    }
                }
                for(Core_Entitlement__c entObj : entitlementRecords) {
                    // Create map of contact entitlements to erpm engagement dedup numbers for B2B Indicator updates later
                    if(contEntObj.Core_Entitlement_Id__c == entObj.Id) {
                        mEntitlements.put(contEntObj, entObj.Core_ERPM_Engagement_Id__r.Core_Technical_DeDup_Number__c);
                    }
                }
            }
            
            if(mUpdateContEngName.size() > 0)
                update mUpdateContEngName.values();
            if(mUpdateAcctEngName.size() > 0)
                update mUpdateAcctEngName.values();
            
            if(mContEntitlements != null && !mContEntitlements.isEmpty()) {
                Boolean updateContacts = false;
                List<Contact> contactsToUpdate = new List<Contact>();
                List<Account> accountsToUpdate = new List<Account>();
                Set<Id> contactIds = new Set<Id>();
                Set<Id> accountIds = new Set<Id>();
                for(Core_Contact_Entitlement__c contEntObj : mContEntitlements.keySet()) 
                {
                    Contact contactRecord = mContEntitlements.get(contEntObj);
                    // The following block of code sets the B2B indicator fields on the Contact and Account to true when the 
                    // ERPM Engagement Dedup Number is set to B2B
                    if(!contactRecord.Core_Contact_B2B_Indicator__c) {
                        if(mEntitlements.get(contEntObj) == 'B2B') {
                            
                            if(!contactIds.contains(contactRecord.Id)) {
                                Contact conRec = new Contact(id=contactRecord.Id, AccountId=contactRecord.AccountId, Core_Contact_B2B_Indicator__c = true);
                                contactsToUpdate.add(conRec);
                                contactIds.add(contactRecord.Id);
                                if(!accountIds.contains(conRec.AccountId)) {
                                    if(!contactRecord.Account.Core_B2B_Entitlement__c) {
                                        Account accRec = new Account(id=conRec.AccountId, Core_B2B_Entitlement__c = true);
                                        accountsToUpdate.add(accRec);
                                        accountIds.add(conRec.AccountId);
                                    }
                                }
                            }
                            
                        }
                    }
                    
                    //SKIP ALL validations for Engagments (Core_From_Source__c = true)
                    //System.debug(' From SOURCE >>  '+contEntObj.Core_From_Source__c);
                    if(contEntObj.Core_From_Source__c){
                        //System.debug(' Engagement FOUND !.. and skipping validation ');
                        continue;
                    }
                    
                    
                    //System.debug(' Running the validations for Entitlement > ' + contEntObj);
                    // Check for ODM Indicator field
                    if(!validateIsODM(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        //System.debug(' ODM Indicator field '+contEntObj.Core_Entitlement_Id__c+' Name '+contEntObj.Name);
                        //System.debug(' ODM Indicator field'+contactRecord);
                        
                        contEntObj.addError(mapConentValErrorMsg.get('System Non ODM'));
                    }  
                    // Check for CNDA field
                    if(!validateCNDANum(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        contEntObj.addError(mapConentValErrorMsg.get('System CNDA'));
                    }
                    // Check for Engagement in Contact related list
                    if(!ValidateEngagement(contEntObj.Core_Entitlement_Id__c, contactRecord,coreAllEntitlementList)) {
                        contEntObj.addError(mapConentValErrorMsg.get(mapENtReqMessages.get(contEntObj.Core_Entitlement_Id__c)));
                    }
                    // Check for Intel Support Owner field
                    if(!validateIntelSupportOwner(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        contEntObj.addError(mapConentValErrorMsg.get('System ISO'));
                    }
                    // Check for Account Owner Role field
                    if(!validateAccountOwnerRole(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        contEntObj.addError(mapConentValErrorMsg.get('System Account Owner Role'));
                    }
                    // Check for CIM Id on Account
                    if(!validateCimId(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        contEntObj.addError(mapConentValErrorMsg.get('System CIM ID'));
                    }
                    // US90386 Added By Prem
                    // Check for PSG WOM on Account
                    if(!validatePSGWOM(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        contEntObj.addError(mapConentValErrorMsg.get('System PSG WOM'));
                    }
                    if(!validatePersonalEmailIndicator(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        contEntObj.addError(mapConentValErrorMsg.get('System PersonalEmailIndicator'));
                    }
                    if(!validateIsODMTrue(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        contEntObj.addError(mapConentValErrorMsg.get('System ODM'));
                    }
                    if(!validateUniqueEntitlement(contEntObj.Core_Entitlement_Id__c, contactRecord,'')) {
                        contEntObj.addError(mapConentValErrorMsg.get('System Unique Entitlement'));
                    }
                    //Added by Geetha as per user story US113583
                    if(!validatePartnerEntitlement(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        contEntObj.addError(mapConentValErrorMsg.get('System Unique Entitlement'));
                    }
                    //Ended by Geetha as per user story US113583
                    
                    //if(!validateEnglishOnly(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                    //contEntObj.addError('English Only on Contact can\'t be blank (Populate from Standard and Alternate if avalible and meet req)');
                    //}
                    
                }
                
                // Finish updating B2B Indicator Field on contact records
                if(contactsToUpdate != null && !contactsToUpdate.isEmpty()) {
                    update contactsToUpdate;
                }
                if(accountsToUpdate != null && !accountsToUpdate.isEmpty()) {
                    update accountsToUpdate;
                }  
            }            
        }
    }
    
    //Add Or Remove Subordinates
    //@future
    public static void addContactEntitlementSubordinates(List<Core_Contact_Entitlement__c> lConEnt) {
        
        Set<Id> stContactIds = new Set<Id>();
        Map<Core_Contact_Entitlement__c, Contact> mContEntitlements = new Map<Core_Contact_Entitlement__c, Contact>();
        List<Contact> contactRecords = new List<Contact>();
        Set<Id> sEntSubToUpdateIds = new Set<Id>();
        List<Core_Contact_Entitlement__c> lEntSubToUpdate = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> lEntSubToInsert = new List<Core_Contact_Entitlement__c>();
        Map<Id, Core_Contact_Entitlement__c> mEntSubToInsert = new Map<Id, Core_Contact_Entitlement__c>();
        List<Id> lEntToUpdateInTrigger = new List<Id>();
        Map<Id,Boolean> mapContEntSelected = new Map<Id,Boolean>();
        Map<Id,Boolean> mapAccountODM = new Map<Id,Boolean>();
        Map<Id,String> mapAccountCNDA = new Map<Id,String>();
        Map<Id,Boolean> mapSubActive = new Map<Id,Boolean>();
        Set<Id> stAllSubId = new Set<Id>();
        
        //Add Subordinates custom settings
        List<Core_Contact_Entitlement_Subordinates__c> lstConEntSubAdd = Core_Contact_Entitlement_Subordinates__c.getAll().values();
        
        //Remove Subordinates custom settings
        List<Core_Contact_Ent_Subordinates_Removal__c> lstConEntSubRemove = Core_Contact_Ent_Subordinates_Removal__c.getAll().values();
        
        //Loop on trigger.new to prepare set of contact IDs
        for(Core_Contact_Entitlement__c conEntRef : lConEnt) {
            stContactIds.add(conEntRef.Core_Contact_Id__c);
        }
        //System.debug('==lalitha===lConEnt===>'+lConEnt);
        //Qeury all existing contact entitlements for the contact set
        List<Core_Contact_Entitlement__c> lExistingConEnt = [SELECT Id, Core_Entitlement_Id__c,Core_Entitlement_Id__r.Core_IsActive__c,Core_Contact_Id__r.Account.Core_CNDA_Number__c,Core_Contact_Id__r.Account.Core_IsODM__c, Core_Contact_Id__c, Core_Selected__c 
                                                             FROM Core_Contact_Entitlement__c
                                                             WHERE Core_Contact_Id__c IN :stContactIds AND Core_Entitlement_Id__r.Core_IsActive__c = true];
        
        //System.debug('==lalitha===lExistingConEnt===>'+lExistingConEnt);
        //Loop on existing entitlements to prepare maps for 'Account ODM flag' and 'Selected flag'
        for(Core_Contact_Entitlement__c entRef : lExistingConEnt){
            mapContEntSelected.put(entRef.Core_Entitlement_Id__c,entRef.Core_Selected__c);
            mapAccountODM.put(entRef.id,entRef.Core_Contact_Id__r.Account.Core_IsODM__c);
            if(entRef.Core_Contact_Id__r.Account.Core_CNDA_Number__c != null && entRef.Core_Contact_Id__r.Account.Core_CNDA_Number__c !=''){
                mapAccountCNDA.put(entRef.id,entRef.Core_Contact_Id__r.Account.Core_CNDA_Number__c);
            }
        }
        //System.debug('===lalitha===mapContEntSelected==>'+mapContEntSelected);
        //System.debug('===lalitha===mapAccountODM==>'+mapAccountODM);
        //System.debug('======mapAccountCNDA==>'+mapAccountCNDA);
        //Loop on Add Subordinates custom settings to prepare set of Subordinates
        for(Core_Contact_Entitlement_Subordinates__c subEntRefAdd : lstConEntSubAdd){
            List<Id> lstMulti = subEntRefAdd.Core_Entitlement_Subordinate_Id__c.split(',');
            for(Id subId : lstMulti){
                stAllSubId.add(subId);
            }
        }
        //Loop on Add Subordinates custom settings to prepare set of Subordinates
        for(Core_Contact_Ent_Subordinates_Removal__c subEntRefRemove : lstConEntSubRemove){
            List<Id> lstMulti = subEntRefRemove.Core_Entitlement_Subordinate_Id__c.split(',');
            for(Id subId : lstMulti){
                stAllSubId.add(subId);
            }
        }
        //Loop on Entitlements to prepare active entitlements map
        for(Core_Entitlement__c entDetailRef : [Select id,Core_IsActive__c FROM Core_Entitlement__c WHERE Id IN : stAllSubId]){
            mapSubActive.put(entDetailRef.Id,entDetailRef.Core_IsActive__c);
        }
        
        
        
        //For loop to Add subordinates 
        for(Core_Contact_Entitlement__c conEntObj : lConEnt){ 
            //System.debug('Zay - In first for loop+++++++'+conEntObj);
            if(conEntObj.Core_Selected__c){
                List<Core_Contact_Entitlement_Subordinates__c> conEntSub = new List<Core_Contact_Entitlement_Subordinates__c>();
                //System.debug('==mapAccountODM.get(conEntObj.id)=@@==>'+mapAccountODM.get(conEntObj.id));
                if(mapAccountODM.get(conEntObj.id)!=null && mapAccountODM.get(conEntObj.id)){
                    for(Core_Contact_Entitlement_Subordinates__c conEntSubObj : lstConEntSubAdd){
                        if(conEntSubObj.Core_Is_ODM_True__c && conEntSubObj.Core_Entitlement_Id__c == conEntObj.Core_Entitlement_Id__c ){      //mahendraa
                            if(conEntSubObj.Core_Is_CNDA_True__c  && !String.isBlank(mapAccountCNDA.get(conEntObj.id))){
                                conEntSub.add(conEntSubObj);
                            }else if(!conEntSubObj.Core_Is_CNDA_True__c ){
                                conEntSub.add(conEntSubObj);
                            }
                            //System.debug('conEntSub===1==>>>>>>'+conEntSub);
                        }
                        
                        
                    }
                }else {
                    for(Core_Contact_Entitlement_Subordinates__c conEntSubObj : lstConEntSubAdd){
                        if(!conEntSubObj.Core_Is_ODM_True__c && conEntSubObj.Core_Entitlement_Id__c == conEntObj.Core_Entitlement_Id__c){
                            if(conEntSubObj.Core_Is_CNDA_True__c  && !String.isBlank(mapAccountCNDA.get(conEntObj.id))){
                                conEntSub.add(conEntSubObj);
                            }else if(!conEntSubObj.Core_Is_CNDA_True__c ){
                                conEntSub.add(conEntSubObj);
                            }
                            //System.debug('conEntSub===1==>>>>>>'+conEntSub);
                        }
                    }
                }
                
                for(Core_Contact_Entitlement_Subordinates__c conEntSubObj : conEntSub){
                    //System.debug('lalitha===1'+conEntObj.Name);
                    //System.debug('lalitha==2='+conEntSubObj.Name);
                    //System.debug('lalitha=3=='+conEntObj.Core_Selected__c);
                    if(conEntObj.Core_Entitlement_Id__c == conEntSubObj.Core_Entitlement_Id__c && conEntObj.Core_Selected__c == true){
                        //System.debug('Zay - Inside subordinate check before update or insert check');
                        Boolean checkInsOrUpdate = false;
                        for(Core_Contact_Entitlement__c existingConEntObj : lExistingConEnt){
                            if(conEntSubObj.Core_Entitlement_Subordinate_Id__c == existingConEntObj.Core_Entitlement_Id__c 
                               && conEntObj.Core_Contact_Id__c == existingConEntObj.Core_Contact_Id__c
                               && !existingConEntObj.Core_Selected__c && mapSubActive.get(existingConEntObj.Core_Entitlement_Id__c)){
                                   Core_Contact_Entitlement__c conEntToUpdate = new Core_Contact_Entitlement__c(id=existingConEntObj.id, Core_Selected__c = true,Core_Status__c='Pending');
                                   //System.debug('Zay - conEntToUpdate : ' + conEntToUpdate);
                                   //System.debug('Zay - Inside subordinate update');
                                   if(!sEntSubToUpdateIds.contains(conEntToUpdate.id)) {
                                       lEntSubToUpdate.add(conEntToUpdate);
                                   }
                                   sEntSubToUpdateIds.add(conEntToUpdate.id);
                                   checkInsOrUpdate = true;
                               }else if(conEntSubObj.Core_Entitlement_Subordinate_Id__c == existingConEntObj.Core_Entitlement_Id__c 
                                        && conEntObj.Core_Contact_Id__c == existingConEntObj.Core_Contact_Id__c
                                        && existingConEntObj.Core_Selected__c){
                                            checkInsOrUpdate = true;
                                            //System.debug('Zay - Inside subordinate update 2');
                                        }
                        }
                        if(!checkInsOrUpdate){
                            if(mapSubActive.get(conEntSubObj.Core_Entitlement_Subordinate_Id__c)){
                                Core_Contact_Entitlement__c conEntToInsert = new Core_Contact_Entitlement__c(Core_Entitlement_Id__c = conEntSubObj.Core_Entitlement_Subordinate_Id__c, 
                                                                                                             Core_Selected__c = true, Core_Contact_Id__c = conEntObj.Core_Contact_Id__c, Core_Status__c='Pending');
                                mEntSubToInsert.put(conEntSubObj.Core_Entitlement_Subordinate_Id__c, conEntToInsert);
                                //System.debug('Zay - Inside subordinate insert ---- SKTest '+lEntSubToInsert);
                            }
                        }
                    }
                }
            }
        }
        for(Core_Contact_Entitlement__c conEntObj : lConEnt){ 
            //System.debug('Zay - In first for loop+++++++'+conEntObj);
            Boolean notAdded = true;
            for(Core_Contact_Entitlement__c tobeUpdated : lEntSubToUpdate){
                if(tobeUpdated.id == conEntObj.id){
                    notAdded = false;
                }
            }
            
            if(!conEntObj.Core_Selected__c && notAdded){
                Boolean isAnyEntSelected= false;
                for(Core_Contact_Ent_Subordinates_Removal__c conEntSubObj : lstConEntSubRemove){
                    if(conEntObj.Core_Entitlement_Id__c == conEntSubObj.Core_Entitlement_Id__c && conEntObj.Core_Selected__c == false){
                        //System.debug('in else if lalitha===>');
                        Boolean checkInsOrUpdate = false;
                        for(Core_Contact_Entitlement__c existingConEntObj : lExistingConEnt){
                            //System.debug('in existing for lalitha===>'+existingConEntObj.Core_Entitlement_Id__c);
                            List<Id> lstMultiSub = conEntSubObj.Core_Entitlement_Subordinate_Id__c.split(',');
                            for(id subRef :lstMultiSub){ 
                                if(subRef == existingConEntObj.Core_Entitlement_Id__c 
                                   && conEntObj.Core_Contact_Id__c == existingConEntObj.Core_Contact_Id__c
                                   && existingConEntObj.Core_Selected__c){
                                       //System.debug('in if lalitha===>');
                                       //System.debug('123===>'+existingConEntObj.Core_Entitlement_Id__c);
                                       if(!String.IsBlank(conEntSubObj.Core_Condition__c)){
                                           List<Id> lstConditionEntIds =  conEntSubObj.Core_Condition__c.split(',');
                                           for(id entid : lstConditionEntIds){
                                               //System.debug('==12===lalitha==>'+mapContEntSelected);
                                               //System.debug(entid+'==in map for if lalitha===>'+mapContEntSelected.get(entid));
                                               if(mapContEntSelected.get(entid)!=null && mapContEntSelected.get(entid) == true){
                                                   isAnyEntSelected = true;
                                               }
                                           }  
                                           if(!isAnyEntSelected){
                                               if(mapSubActive.get(existingConEntObj.Core_Entitlement_Id__c) != null && mapSubActive.get(existingConEntObj.Core_Entitlement_Id__c)){
                                                   Core_Contact_Entitlement__c conEntToUpdate = new Core_Contact_Entitlement__c(id=existingConEntObj.id, Core_Selected__c = false, Core_Status__c='Pending');
                                                   if(!sEntSubToUpdateIds.contains(conEntToUpdate.id)){
                                                       lEntSubToUpdate.add(conEntToUpdate);
                                                   }
                                                   sEntSubToUpdateIds.add(conEntToUpdate.id);
                                               }
                                           } 
                                       }else{
                                           //System.debug('==lalitha==existingConEntObj.Core_Entitlement_Id__c==>'+existingConEntObj.Core_Entitlement_Id__c);
                                           //System.debug('==lalitha===mapSubActive.get(existingConEntObj.Core_Entitlement_Id__c)==>'+mapSubActive.get(existingConEntObj.Core_Entitlement_Id__c));
                                           if(mapSubActive.get(existingConEntObj.Core_Entitlement_Id__c) != null && mapSubActive.get(existingConEntObj.Core_Entitlement_Id__c)){
                                               Core_Contact_Entitlement__c conEntToUpdate = new Core_Contact_Entitlement__c(id=existingConEntObj.id, Core_Selected__c = false, Core_Status__c='Pending');
                                               if(!sEntSubToUpdateIds.contains(conEntToUpdate.id)){
                                                   lEntSubToUpdate.add(conEntToUpdate);
                                               }
                                               sEntSubToUpdateIds.add(conEntToUpdate.id);
                                           }
                                       }   
                                   }
                            }
                        }
                    }
                }  
            }
        }
        
        
        if(lEntSubToUpdate != null && lEntSubToUpdate.size() > 0){
            //System.debug('Zay - lEntSubToUpdate : ' + lEntSubToUpdate);
            update lEntSubToUpdate;
        }
        if(mEntSubToInsert != null && mEntSubToInsert.size() > 0){
            //System.debug('Zay - lEntSubToInsert : ' + lEntSubToInsert);
            lEntSubToInsert = mEntSubToInsert.values();
            //System.debug('Zay - lEntSubToInsert : ' + lEntSubToInsert);
            insert lEntSubToInsert;  
            //System.debug('Zay - lEntSubToInsert : ' + lEntSubToInsert);
        }      
    }
    
    public void filterEntitlementsByProfile() {
        Boolean entCheck = false;
        String userProfileId = UserInfo.getProfileId();
        userProfileId = userProfileId.substring(0, userProfileId.length()-3);
        List<String> lEntNames = new List<String>();
        //System.debug('Zay Userprofileid - ' + userProfileId);
        List<Core_Entitlement_Profile_Access__c> epaObj = [Select id, Core_Entitlements_Allowed__c from Core_Entitlement_Profile_Access__c where Core_Profile_Id__c = :userProfileId];
        
        //System.debug('epaObj - ' + epaObj);
        if(epaObj != null && !epaObj.isEmpty()) {
            entCheck = String.isBlank(epaObj[0].Core_Entitlements_Allowed__c);
        } else {
            entCheck = true;
        }
        if(epaObj != null && !epaObj.isEmpty() && !entCheck) {
            //System.debug(lEntNames);
            lEntNames = epaObj[0].Core_Entitlements_Allowed__c.split(';');
        }
    }
    
    
    //Start----Added by Popcornapps
    public static List<String> listOfInvalidCNDANum = (Label.Core_IPS_Invalid_CNDA).split(';');
    
    public static Boolean validateCNDANum(Id entId, Contact conObj) {
        // CNDA validation is only for Partner Portal.
        //System.debug('Object msg mapentIds CNDANum ::'+mapentIds);
        //System.debug('Object msg entId ::'+entId);
        
        //code for Invalid CNDA   
        //List<String> listOfInvalidCNDANum = (Label.Core_IPS_Invalid_CNDA).split(';');
        
        if(mapentIds.keySet().contains(entId) && mapentIds.get(entId).Core_CNDA__c){
            if(String.isBlank(conObj.Account.Core_CNDA_Number__c) || listOfInvalidCNDANum.contains(conObj.Account.Core_CNDA_Number__c) ) {
                return false;
            }
        }
        return true;
    }
    // Method to validate IntelSupportOwner field on Contact.  If true validation passed, if false validation failed.
    public static Boolean validateIntelSupportOwner(Id entId, Contact conObj) {
        //System.debug('Object msg mapentIds SupportOwner ::'+mapentIds);
        //System.debug('Object msg entId ::'+entId);
        //Mahendra as per US79861
        //  if(mapentIds.keySet().contains(entId) && mapentIds.get(entId).Core_Support_Owner__c && conObj.Account.Core_CNDA_Number__c != NULL && !(listOfInvalidCNDANum.contains(conObj.Account.Core_CNDA_Number__c))){
        
        if(mapentIds.keySet().contains(entId) && mapentIds.get(entId).Core_Support_Owner__c &&!((String.isBlank(conObj.Account.Core_CNDA_Number__c) || listOfInvalidCNDANum.contains(conObj.Account.Core_CNDA_Number__c)))){
            
            if(String.isBlank(conObj.Core_IPS_Intel_Support_Owner__c)) {
                return false;
            }
        }
        return true;
    }
    // Method to validate Account Owner role for Account.  If true validation passed, if false validation failed.
    public static Boolean validateAccountOwnerRole(Id entId, Contact conObj) {
        if(mapentIds.keySet().contains(entId) && mapentIds.get(entId).Core_Account_Owner_Role__c){
            if(String.isBlank(conObj.Account.Owner.UserRole.Name)) {
                return false;
            }
        }
        return true;
    }
    
    // Method to validate IsOdm field on Account.  If true validation passed, if false validation failed.
    public static Boolean validateIsODM(Id entId, Contact conObj) {
        if(mapentIds.keySet().contains(entId) && mapentIds.get(entId).Core_ODM_Checked__c){ 
            if(conObj.Account.Core_IsODM__c != true) {
                //System.debug('Zay - What happened');
                return false;
            }
        }
        return true;
    }
    // Method to validate Cim Id field on Account.  If true validation passed, if false validation failed.
    public static Boolean validateCimId(Id entId, Contact conObj) {
        if(mapentIds.keySet().contains(entId) && mapentIds.get(entId).Core_CIM_ID__c){
            if(String.isBlank(conObj.Account.Core_CIM_ID__c)) {
                return false;
            }
        }
        return true;
    }
    // US90386 Added By Prem
    // Method to validate PSG WOM field on Account.  If true validation passed, if false validation failed.
    public static Boolean validatePSGWOM(Id entId, Contact conObj) {
        if(mapentIds.keySet().contains(entId) && mapentIds.get(entId).Core_PSG_WOM__c){
            if(!conObj.Account.Core_IPS_PSG_WOM_Check__c) {
                return false;
            }
        }
        return true;
    }
    // Method to validate Personal Email Indicaor field on Contact.  If true validation passed, if false validation failed.
    public static Boolean validatePersonalEmailIndicator(Id entId, Contact conObj) {
        if(mapentIds.keySet().contains(entId) && mapentIds.get(entId).Core_Personal_Email_Domain__c){
            if(conObj.Core_Personal_Email_Indicator__c) {
                return false;
            }
        }
        return true;
    }
    // Method to validate ODM Indicator is true on Account.  If true validation passed, if false validation failed.
    public static Boolean validateIsODMTrue(Id entId, Contact conObj) {
        if(mapentIds.keySet().contains(entId) && mapentIds.get(entId).Core_ODM_Unchecked__c){
            if(conObj.Account.Core_IsODM__c) {
                return false;
            }
        }
        return true;
    }
    //Mahendra
    
    public static Boolean ValidateEngagement(Id entId, Contact conObj,List<Core_Contact_Entitlement__c> coreAllEntitlementList ) {
        //System.debug('coreAllEntitlementList ====='+coreAllEntitlementList );
        Map<ID,Set<ID>> mapConEntitlement=new Map<ID,Set<ID>>();
        ID contactId=conObj.id;
        //System.debug('contactId::'+contactId);
        for(Core_Contact_Entitlement__c allEnt: coreAllEntitlementList){
            Set<ID> relatedContEntitlement =new Set<ID>();
            for(Core_Contact_Entitlement__c allEntinner: coreAllEntitlementList)
                if(allEnt.Core_Contact_Id__c==allEntinner.Core_Contact_Id__c){
                    relatedContEntitlement.add(allEntinner.Core_Entitlement_Id__c);
                }
            mapConEntitlement.put(allEnt.Core_Contact_Id__c,relatedContEntitlement);
        }
        //Getting the custom setting record values  
        Boolean engagementAvailable=false;
        Map<ID, ID> entEngagementMap = new Map<ID, ID>();
        List<Core_Contact_Entitlement_Validation_Req__c>  ccEngagementValList = new List<Core_Contact_Entitlement_Validation_Req__c>();
        ccEngagementValList = Core_Contact_Entitlement_Validation_Req__c.getAll().values();
        //System.debug('ccEngagementValList=====>>>>>'+ccEngagementValList);
        //System.debug('key set :: '+mapConEntitlement.keyset());
        //System.debug('mapConEntitlement :: '+mapConEntitlement);
        Set<Id> entitlementSet = new Set<Id>();
        for(Core_Contact_Entitlement_Validation_Req__c ent:ccEngagementValList){
            entitlementSet.add(ent.Core_Entitlement_id__c);
            entEngagementMap.put(ent.Core_Entitlement_id__c,ent.Core_Entitlement_Req_Id__c);
        }
        //System.debug('entitlementSet=====>>>>>'+entitlementSet);
        //System.debug('entEngagementMap=====>>>>>'+entEngagementMap);        
        if(entitlementSet.size()>0 && entitlementSet.contains(entId)){
            //Getting the Entitlement records based on contact id and basic entitlement id from the custom setting
            if(mapConEntitlement.keyset().contains(contactId)){
                //System.debug('map===='+mapConEntitlement.get(contactId).contains(entEngagementMap.get(entId)));
                engagementAvailable=mapConEntitlement.get(contactId).contains(entEngagementMap.get(entId));
            }
            if(!engagementAvailable){
                return false;
            }
        }
        
        return true;
    }
    // Method to validate English Only fields on Contact.  If true validation passed, if false validation failed.
    /*public static Boolean validateEnglishOnly(Id entId, Contact conObj) {
if(mapentIds.keySet().contains(entId) && mapentIds.get(entId).Core_Contact_English_Only_Name__c){
if(String.isBlank(conObj.Core_English_Only_First_Name__c) || String.isBlank(conObj.Core_English_Only_Last_Name__c)) {
return false;
}
}
return true;
}*/
    
    //End----Added by Popcornapps
    
    
    // Local language rules method
    public static void validateContactEnglishOnlyFields(List<Contact> newList, Map<Id, Contact> oldList) {
        //System.debug('Zay - Inside validateContactEnglishOnlyFields');
        List<Contact> lUpdateContacts = new List<Contact>();
        for(Contact conObj : newList) {
            Boolean updateContactFirst = false;
            Boolean updateContactLast = false;
            if(conObj.Core_Contact_B2B_Indicator__c) {
                //System.debug('Zay - Inside validateContactEnglishOnlyFields - B2B indicator check');
                if(conObj.Core_English_Only_First_Name__c != conObj.FirstName && conObj.FirstName != oldList.get(conObj.Id).FirstName) {
                    //System.debug('Zay - Inside validateContactEnglishOnlyFields - First Name check');
                    if(checkValidText(conObj.FirstName)) {
                        conObj.Core_English_Only_First_Name__c = conObj.FirstName;
                        updateContactFirst = true;
                    } 
                }
                if(conObj.Core_English_Only_Last_Name__c != conObj.LastName && conObj.LastName != oldList.get(conObj.Id).LastName) {
                    //System.debug('Zay - Inside validateContactEnglishOnlyFields - Last Name check');
                    if(checkValidText(conObj.LastName)) {
                        conObj.Core_English_Only_Last_Name__c = conObj.LastName;
                        updateContactLast = true;
                    }
                }  
            }      
        }
    }
    public static void validateAccountEnglishOnlyFields(List<Account> newList, Map<Id, Account> oldList) {
        List<Account> lUpdateAccounts = new List<Account>();
        for(Account acctObj : newList) {
            Boolean updateAccount = false;
            if(acctObj.Core_B2B_Entitlement__c) {
                if(acctObj.Core_English_Only_Name__c != acctObj.Name && acctObj.Name != oldList.get(acctObj.Id).Name) {
                    if(checkValidText(acctObj.Name)) {
                        acctObj.Core_English_Only_Name__c = acctObj.Name;
                        updateAccount = true;
                    }
                }
            }
            
        }
        
    }
    //Rewritten the above method for bulikification
    public static Boolean validateEnglishOnlyFields(Contact conObj, Map<Id, Contact> mCont, Map<Id, Account> mAcct) {
        if(!String.isBlank(conObj.Core_English_Only_First_Name__c) && !String.isBlank(conObj.Core_English_Only_Last_Name__c) 
           && !String.isBlank(conObj.Account.Core_English_Only_Name__c)) {
               return true;    
           } else {
               
               if(String.isBlank(conObj.Core_English_Only_First_Name__c)) {                      
                   if(checkValidText(conObj.FirstName)) {
                       conObj.Core_English_Only_First_Name__c = conObj.FirstName;
                   } else if(checkValidText(conObj.Core_Local_First_Name__c)) {
                       conObj.Core_English_Only_First_Name__c = conObj.Core_Local_First_Name__c;
                   }  else {
                       return false;
                   } 
               }
               if(String.isBlank(conObj.Core_English_Only_Last_Name__c)) {
                   if(checkValidText(conObj.LastName)) {
                       conObj.Core_English_Only_Last_Name__c = conObj.LastName;
                   } else if(checkValidText(conObj.Core_Local_Last_Name__c)) {
                       conObj.Core_English_Only_Last_Name__c = conObj.Core_Local_Last_Name__c;
                   } else {
                       return false;
                   }
               }         
               if(conObj.Id != null)
                   mCont.put(conObj.Id, conObj);
               
               if(String.isBlank(conObj.Account.Core_English_Only_Name__c)) {
                   Account accountToUpdate = new Account(id=conObj.AccountId);
                   if(checkValidText(conObj.Account.Name)) {
                       accountToUpdate.Core_English_Only_Name__c = conObj.Account.Name;
                   } else if(checkValidText(conObj.Account.Core_Alternate_Language_Name__c)) {
                       accountToUpdate.Core_English_Only_Name__c = conObj.Account.Core_Alternate_Language_Name__c;
                   } else {
                       return false;
                   }
                   if(accountToUpdate.Id != null)
                       mAcct.put(accountToUpdate.Id, accountToUpdate);
               }
               
           }
        return true;
    }
    public static List<Core_Contact_Entitlement_Exclusive__c> mcs;
    public static Set<ID> idsList=new Set<ID>();
    public static String uniqueEntitlementNames='';
    
    // Entitlement should be unique.
    //Modified by Geetha as per user story US113583
    public static Boolean validateUniqueEntitlement(Id entId, Contact conObj, String uniqueEntitlementName){
        //System.debug('entId===>>>'+entId+'conObj=====>>>>'+conObj+'uniqueEntitlementName=====>>>>>'+uniqueEntitlementName);
        //mcs = Core_Contact_Entitlement_Exclusive__c.getall().values();
        mcs = [Select Id,Name,Core_Unique_Ids__c from Core_Contact_Entitlement_Exclusive__c];
        count=0;
        ipscount=0;
        if(mapIPSContactIds.get(conObj.id)!=null){
            mapIPSContactIds.put(conObj.id,mapIPSContactIds.get(conObj.id));
            //System.debug('mapIPSContactIds==if==>'+mapIPSContactIds); 
        }else{
            mapIPSContactIds.put(conObj.id,ipscount);
            //System.debug('mapIPSContactIds==else==>'+mapIPSContactIds); 
        }
        for(Core_Contact_Entitlement_Exclusive__c csVal:mcs)
        {
            idsList.addAll((List<ID>)((csVal.Core_Unique_Ids__c).split(',')));
            
        }
        //System.debug('idsList====>>>>>'+idsList);
        if(idsList.contains(entId)){
            if(String.isBlank(uniqueEntitlementNames)){
                uniqueEntitlementNames=uniqueEntitlementName;
                //System.debug('uniqueEntitlementNames===1==>>>>>>>>'+uniqueEntitlementNames);
            }else{
                uniqueEntitlementNames=uniqueEntitlementNames+', '+uniqueEntitlementName;
                //System.debug('uniqueEntitlementNames===2==>>>>>>>>'+uniqueEntitlementNames);
            }
            if((entId+'').contains(Label.Core_Entitlement_IPS_Id)){
                mapIPSContactIds.put(conObj.id,1);
                //System.debug('mapIPSContactIds==count==>'+mapIPSContactIds); 
            }
            if(mapContactIds.get(conObj.id)!=null){        
                mapContactIds.put(conObj.id,mapContactIds.get(conObj.id)+1);
                
            }else{
                mapContactIds.put(conObj.id,++count);
            }
            //System.debug('mapContactIds==>'+mapContactIds);
        }
        if(mapContactIds.get(conObj.id)>1 && (mapIPSContactIds.get(conObj.id)==1)){ // map contact id count check
            return false;
        }else{
            return true;
        }
    }
    //Added by Geetha as per user story US113583
    //Method to validate uique entitlement with Data Loader
    public static void validateEntitlementType(List<Id> lstconObj){
        List<Core_Contact_Entitlement__c> coreAllEntitlementList=[Select id,Core_Contact_Id__c,Core_Type__c,Core_Selected__c,
                                                                  Core_Entitlement_Id__r.Name,Core_Entitlement_Id__c
                                                                  from Core_Contact_Entitlement__c where Core_Contact_Id__c in :lstconObj AND Core_Selected__c = true];
        for (Core_Contact_Entitlement__c entitlement : coreAllEntitlementList){
            if(mapContactEntitlement.get(entitlement.Core_Contact_Id__c) != null){
                Set<Id> tempSet=mapContactEntitlement.get(entitlement.Core_Contact_Id__c);
                tempSet.add(entitlement.Core_Entitlement_Id__c);
                mapContactEntitlement.put(entitlement.Core_Contact_Id__c,tempSet);
            }else{
                mapContactEntitlement.put(entitlement.Core_Contact_Id__c,new Set<id>{entitlement.Core_Entitlement_Id__c});
            }
            //System.debug('mapContactEntitlement=====>>>>>>>>'+mapContactEntitlement);
        }  
    }
    public static Boolean validatePartnerEntitlement(Id entId, Contact conObj){
        mcs = [Select Id,Name,Core_Unique_Ids__c from Core_Contact_Entitlement_Exclusive__c];
        for(Core_Contact_Entitlement_Exclusive__c csVal:mcs)
        {
            idsList.addAll((List<ID>)((csVal.Core_Unique_Ids__c).split(',')));
            //System.debug('idsList=before removing=>'+idsList);
            
        }
        Set<Id> partnerIds = new Set<Id>(idsList);
        partnerIds.remove((Id)Label.Core_Entitlement_IPS_Id);
        //System.debug('idsList=after removing=>'+idsList);
        
        if(idsList.contains(entId)){
            if((!String.isBlank(entId+'') && (entId+'').contains(Label.Core_Entitlement_IPS_Id))){
                for(Id validateIds:partnerIds){
                    if(mapContactEntitlement.size()>0 && mapContactEntitlement.get((Id)conObj.id)!=null && mapContactEntitlement.get((Id)conObj.id).contains(validateIds)){
                        return false;
                    }
                }
            }else if((!String.isBlank(String.valueof(entId)) && (partnerIds.contains(String.valueof(entId))))){
                if(mapContactEntitlement.size()>0 && mapContactEntitlement.get((Id)conObj.id)!=null && mapContactEntitlement.get((Id)conObj.id).contains((Id)Label.Core_Entitlement_IPS_Id)){
                    return false;
                }
            }else{
                return true;
            }
        }
        return true;
    } 
    //Ended by Geetha as per user story US113583 
    // Used to validate Local Language fields are valid ASCII
    public static Boolean checkValidText(String text){    
        if(!String.isBlank(text)) {
            return Pattern.matches('[a-zA-Z0-9 \\p{Punct}]+', text);
        } else {
            return false;
        }
    }
    //Skip english only validation if entitlement is InActive OR for existing entitlements
    public static Boolean skipEntValidation(Core_Contact_Entitlement__c ce, Map<Id, Boolean> mEnt) {    
        boolean skip = false;
        if(ce.Id == null || (ce.Id != null && mEnt.get(ce.Core_Entitlement_Id__c) == false))
            skip = true;
        
        return skip;
    }
    
}