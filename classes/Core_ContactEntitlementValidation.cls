public without sharing class Core_ContactEntitlementValidation {
    //Start---added by popcornapps
    public static List<Core_Contact_Entitlement_Validation__c> lstconentval = Core_Contact_Entitlement_Validation__c.getall().values();
    public static Map<Id,Core_Contact_Entitlement_Validation__c> mapentIds = new Map<Id,Core_Contact_Entitlement_Validation__c>();
    public static List<Core_Contact_Entitlement_Validation_Req__c> lsteng = Core_Contact_Entitlement_Validation_Req__c.getall().values();
    public static map<Id,String> mapENtReqMessages = new Map<Id,String>();
    public static List<Core_Contact_Ent_Validation_Message__c> lstConentValErrorMsg = Core_Contact_Ent_Validation_Message__c.getall().values();
    public static Map<String,String> mapConentValErrorMsg = new Map<
        String,String>();
    public static Id coMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId(); //Added by Accenture - VD -> Check if the record type is not Co-Marketing
    public static Id pAGRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId(); //Added by Accenture - US408340 -> Check if the record type is not Core_Partner_Account_Group
    public static Map<Id,Set<Id>> mapContactEntitlement= new Map<Id,set<Id>>();
    //public static Map<Id,String> newMapEntitlement= new Map<Id,String>();//Geetha
    public static Integer count =0;
    public static Integer ipscount=0;
    public static Integer mPcount=0;
    public static Map<Id,Integer> mapContactIds = new Map<Id,Integer>();
    public static Map<Id,Integer> mapIPSContactIds = new Map<Id,Integer>();
    public static List<Core_Contact_Entitlement__c> coreAllEntitlementList = new List<Core_Contact_Entitlement__c>();
    //Sonali Start  (US731136 - Pipeline: CTO Requirement)
    public static Map<Id,Integer> mapOfContIds = new Map<Id,Integer>();
    public static Map<Id,Integer> mapOfDCBCContIds = new Map<Id,Integer>();
    public static Map<Id,Integer> mapOfCTOResellerContIds = new Map<Id,Integer>();
    public static String uniqueEntitlementNames2='';
    //Sonali END
    static {
        system.debug('lstconentval ::'+lstconentval);
         system.debug('lsteng ::'+lsteng );
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
        system.debug('mapentIds ::'+ mapentIds);
        system.debug('mapConentValErrorMsg ::'+ mapConentValErrorMsg);
        
    }
    //End----added by popcornapps
    public static List<Id> lContactIdsforEnt =new List<Id>();
    
    
        public static void validateContactEntitlementModified(List<Core_Contact_Entitlement__c> oldList, List<Core_Contact_Entitlement__c> newFullList, 
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
    //Added by Ealisha
    lContactIds.add(ce.Core_Contact_Id__c);
            }
        }
        
        //commented by Ealisha and added above to avoid for loop.
        /*for(Core_Contact_Entitlement__c c : newList) {
            lContactIds.add(c.Core_Contact_Id__c);
        }*/
    
        //Added by Geetha as per user story US113583
        //commented by Ealisha. Added the logic below in 80-97
    //validateEntitlementType(lContactIds);
    
        // Added by prem
    //Commented by Ealisha and added below inside for
        /*List<Core_Contact_Entitlement__c> coreAllEntitlementList=[Select id,Core_Contact_Id__c,Core_Type__c,Core_Selected__c,
                                                                      Core_Entitlement_Id__r.Name,Core_Entitlement_Id__c
                                                                      from Core_Contact_Entitlement__c 
                                                                      where Core_Contact_Id__c =:lContactIds
                                                                      AND Core_Selected__c = true];*/
    //*Added by Ealisha  -start
    //Utkarsh - US622576 - commented below line to make "coreAllEntitlementList" as global variable and declare it at line no 18.
    //List<Core_Contact_Entitlement__c> coreAllEntitlementList = new List<Core_Contact_Entitlement__c>();    
    for (Core_Contact_Entitlement__c entitlement : [Select id,Core_Contact_Id__c,Core_Type__c,Core_Selected__c,
                                                                      Core_Entitlement_Id__r.Name,Core_Entitlement_Id__c,Core_Source__c
                                                                      from Core_Contact_Entitlement__c 
                                                                      where Core_Contact_Id__c =:lContactIds
                                                                      AND Core_Selected__c = true]){
      coreAllEntitlementList.add(entitlement);
            if(mapContactEntitlement.get(entitlement.Core_Contact_Id__c) != null){
                Set<Id> tempSet=mapContactEntitlement.get(entitlement.Core_Contact_Id__c);
                tempSet.add(entitlement.Core_Entitlement_Id__c);
                mapContactEntitlement.put(entitlement.Core_Contact_Id__c,tempSet);
            }else{
                mapContactEntitlement.put(entitlement.Core_Contact_Id__c,new Set<id>{entitlement.Core_Entitlement_Id__c});
            }
        system.debug('mapContactEntitlement=====>>>>>>>>'+mapContactEntitlement);
        }                                 
        //*Added by Ealisha  -end
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
            //Commented by Ealisha and added below                
            /*List<Core_Entitlement__c> entitlementRecords = [SELECT Id, Core_ERPM_Engagement_Id__r.Core_Technical_DeDup_Number__c, Core_IsActive__c
                                                            FROM Core_Entitlement__c];*/
            
      //Added by Ealisha. Added the above select query inside for and also put a WHERE clause to only select the active entitlements.
            List<Core_Entitlement__c> entitlementRecords = new List<Core_Entitlement__c>();
      for(Core_Entitlement__c ce : [SELECT Id, Core_ERPM_Engagement_Id__r.Core_Technical_DeDup_Number__c, Core_IsActive__c FROM Core_Entitlement__c WHERE Core_IsActive__c=true]){
        entitlementRecords.add(ce);
                mEntActive.put(ce.Id, ce.Core_IsActive__c);                
            }
            
            Map<Id, Contact> mUpdateContEngName = new Map<Id, Contact>();
            Map<Id, Account> mUpdateAcctEngName = new Map<Id, Account>();   
            
            for(Core_Contact_Entitlement__c contEntObj : newList) 
            {
                //Skip english only validation if entitlement is InActive OR for existing entitlements
                //Commented below code by Ealisha since we are only getting the active entitlements from 113
          //boolean skipEntValidation = skipEntValidation(contEntObj, mEntActive);
                
                //System.debug(' skipValidation '+skipEntValidation);
                System.debug(' mEntActive '+mEntActive);
                System.debug(' newMap '+newMap);
                System.debug(' newMap '+oldMap);
                System.debug(' contEntObj.Id '+contEntObj.Id+ ' contEntObj.Core_Contact_Id__c '+contEntObj.Core_Contact_Id__c);
                System.debug('contactRecords=====>'+contactRecords);
                for(Contact contactObj : contactRecords) {
					//Commented by Naresh as part of  defect fix.
                    boolean validateEnglishOnlyFields = validateEnglishOnlyFields(contactObj, mUpdateContEngName, mUpdateAcctEngName);
                    // Call the local language methods to validate English Only Fields
                    System.debug('Zay - Outside validate English Only Loop '+contactObj.AccountId);
                    //if(!validateEnglishOnlyFields(contactObj)) {
                    System.debug('validateEnglishOnlyFields=====>'+!validateEnglishOnlyFields);
                    System.debug('contEntObj.Core_From_Source__c=====>'+!contEntObj.Core_From_Source__c);
                    //System.debug('!skipEntValidation=====>'+!skipEntValidation);
                    /* Changes done by Ealisha
          --old condition was to check if the entitlement was active: 
          if(!validateEnglishOnlyFields && !contEntObj.Core_From_Source__c && !skipEntValidation)
          --Replaced by using containsKey since now we only fetch the active entitlements in the map mEntActive above:  
          if(!validateEnglishOnlyFields && !contEntObj.Core_From_Source__c && mEntActive.containsKey(contEntObj.Core_Entitlement_Id__c)) {*/
          
        //Commented by Naresh as part of  defect fix.            
        if(!validateEnglishOnlyFields && !contEntObj.Core_From_Source__c && mEntActive.containsKey(contEntObj.Core_Entitlement_Id__c)){
                        System.debug('Zay - Inside validate English Only Loop');
            			//Commented by Naresh
                        
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
            
            //Commented by Ealisha and added below.
            /*if(mUpdateContEngName.size() > 0)
                update mUpdateContEngName.values();
            if(mUpdateAcctEngName.size() > 0)
                update mUpdateAcctEngName.values();*/
                  
      
            if(mContEntitlements != null && !mContEntitlements.isEmpty()) {
                Boolean updateContacts = false;
                List<Contact> contactsToUpdate = new List<Contact>();
                List<Account> accountsToUpdate = new List<Account>();
                Set<Id> contactIds = new Set<Id>();
                Set<Id> accountIds = new Set<Id>();
      
      //Added by Ealisha. Trying to have a map for update
        Map<Id,Contact> contactsToUpdateMap = new Map<Id,Contact>();
            Map<Id,Account> accountsToUpdateMap = new Map<Id,Account>();
                for(Core_Contact_Entitlement__c contEntObj : mContEntitlements.keySet()) 
                {
                    Contact contactRecord = mContEntitlements.get(contEntObj);
                    system.debug('mEntitlements:'+mEntitlements);
                    system.debug('contactRecord_modified:'+contactRecord);
                    // The following block of code sets the B2B indicator fields on the Contact and Account to true when the 
                    // ERPM Engagement Dedup Number is set to B2B
                    if(!contactRecord.Core_Contact_B2B_Indicator__c) {
                        if(mEntitlements.get(contEntObj) == 'B2B') {
                            
                            if(!contactIds.contains(contactRecord.Id)) {
                                //Modified by Ealisha. Added Core_English_Only_First_Name__c and Core_English_Only_Last_Name__c as blank value for Contact.
                Contact conRec = new Contact(
                id=contactRecord.Id, 
                AccountId=contactRecord.AccountId, 
                Core_Contact_B2B_Indicator__c = true,
                Core_English_Only_First_Name__c=contactRecord.Core_English_Only_First_Name__c,
                Core_English_Only_Last_Name__c=contactRecord.Core_English_Only_Last_Name__c);
                                contactsToUpdate.add(conRec);
                                contactIds.add(contactRecord.Id);
                //Added by Ealisha.Added to new map contactsToUpdateMap
                contactsToUpdateMap.put(contactRecord.Id,conRec);
                                if(!accountIds.contains(conRec.AccountId)) {
                                    if(!contactRecord.Account.Core_B2B_Entitlement__c) {
                                        //Modified by Ealisha. Added Core_English_Only_Name__c as blank value for Account.
                    Account accRec = new Account(
                    id=conRec.AccountId, 
                    Core_B2B_Entitlement__c = true, 
                    Core_English_Only_Name__c=contactRecord.Account.Core_English_Only_Name__c);
                                        accountsToUpdate.add(accRec);
                                        accountIds.add(conRec.AccountId);
                    //Added by Ealisha.Added to new map accountsToUpdateMap
                    accountsToUpdateMap.put(conRec.AccountId,accRec);
                                    }
                                }
                            }
                            
                        }
                    }
        
        //Added by Ealisha.-start
          //check if contact id is in mUpdateContEngName map then add to the above map.
          if(mUpdateContEngName != null && mUpdateContEngName.containsKey(contactRecord.Id))
          {
            if(contactsToUpdateMap != null && contactsToUpdateMap.containsKey(contactRecord.Id)){
              Contact c = contactsToUpdateMap.get(contactRecord.Id);
              c.Core_English_Only_First_Name__c = mUpdateContEngName.get(contactRecord.Id).Core_English_Only_First_Name__c;
              c.Core_English_Only_Last_Name__c = mUpdateContEngName.get(contactRecord.Id).Core_English_Only_Last_Name__c;
            }
            else{
              contactsToUpdateMap.put(contactRecord.Id,mUpdateContEngName.get(contactRecord.Id));
            }                        
          }
          //check if account id is in mUpdateAcctEngName map then add to the above map.
          if(mUpdateAcctEngName != null && mUpdateAcctEngName.containsKey(contactRecord.AccountId))
          {
            if(accountsToUpdateMap != null && accountsToUpdateMap.containsKey(contactRecord.AccountId)){
              Account a = accountsToUpdateMap.get(contactRecord.AccountId);
              a.Core_English_Only_Name__c = mUpdateAcctEngName.get(contactRecord.AccountId).Core_English_Only_Name__c;
            }
            else{
              accountsToUpdateMap.put(contactRecord.AccountId,mUpdateAcctEngName.get(contactRecord.AccountId));
            }                        
          }
          system.debug('contactsToUpdateMap:'+contactsToUpdateMap);
            system.debug('accountsToUpdateMap:'+accountsToUpdateMap);
          //Added by Ealisha.-end
                    
                    //SKIP ALL validations for Engagments (Core_From_Source__c = true)
                    System.debug(' From SOURCE >>  '+contEntObj.Core_From_Source__c);
                    if(contEntObj.Core_From_Source__c){
                      System.debug(' Engagement FOUND !.. and skipping validation ');
                        continue;
                    }
                        
                    
                    System.debug(' Running the validations for Entitlement > ' + contEntObj);
                    // Check for ODM Indicator field
                    if(!validateIsODM(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        System.debug(' ODM Indicator field '+contEntObj.Core_Entitlement_Id__c+' Name '+contEntObj.Name);
                        System.debug(' ODM Indicator field'+contactRecord);
                        
                        contEntObj.addError(mapConentValErrorMsg.get('System Non ODM'));
                    }  
                    // Check for CNDA field
                    if(!validateCNDANum(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        contEntObj.addError(mapConentValErrorMsg.get('System CNDA'));
                    }
                    // Check for Engagement in Contact related list
                    //Utkarsh - Made changes to prevent validation to fire for IPA Registration.
                    Boolean validatecheck = true;
                    if(contEntObj.Core_Source__c != null && contEntObj.Core_Source__c != System.Label.PRM_Entitlement_Source){
                        validatecheck =validateEngagement(contEntObj.Core_Entitlement_Id__c, contactRecord,coreAllEntitlementList);
                    }
                    system.debug('validatecheck==>'+validatecheck);
                    if(!validatecheck) {
                        system.debug('ErrorMsg==>'+mapConentValErrorMsg.get(mapENtReqMessages.get(contEntObj.Core_Entitlement_Id__c)));
                        contEntObj.addError(mapConentValErrorMsg.get(mapENtReqMessages.get(contEntObj.Core_Entitlement_Id__c)));
                        //contEntObj.addError('NO PSG Basic Engagement');
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
           if(contEntObj.Core_Entitlement_Id__c == System.Label.Core_Employee || contEntObj.Core_Entitlement_Id__c == System.Label.Core_Lead_Development_Representative || contEntObj.Core_Entitlement_Id__c == System.Label.Core_Marketing_specialist || contEntObj.Core_Entitlement_Id__c == System.Label.Core_Offering_Editor||contEntObj.Core_Entitlement_Id__c == System.Label.Core_Partner_Admin )
                    {
                        if(!validateUniqueMPEntitlement(contEntObj.Core_Entitlement_Id__c, contactRecord,'')) {
                            
                            contEntObj.addError(mapConentValErrorMsg.get('System Unique MP Entitlement'));
                            
                        }
                    }
                    //Sonali Start (US731136 - Pipeline: CTO Requirement)
                    if(contEntObj.Core_Entitlement_Id__c == System.Label.Core_CTO_Distributor || contEntObj.Core_Entitlement_Id__c == System.Label.Core_CTO_Reseller){
                        if(!validateDCBCUniqueEntitlement(contEntObj.Core_Entitlement_Id__c, contactRecord,'')) {
                            System.debug('ErrorMsg1111:-'+mapConentValErrorMsg.get('UI Single Entitlement Assignment'));
                            contEntObj.addError(mapConentValErrorMsg.get('UI Single Entitlement Assignment'));
                        } 
                    }                 
                    //Sonali END
                    
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
    //Commented by Ealisha. Replaced below code to check from new map and update the values one shot.
        /*
                if(contactsToUpdate != null && !contactsToUpdate.isEmpty()) {
                    update contactsToUpdate;
                }
                if(accountsToUpdate != null && !accountsToUpdate.isEmpty()) {
                    update accountsToUpdate;
                }  */
        
    //Added by Ealisha-start
        if(contactsToUpdateMap != null) {
                    update contactsToUpdateMap.values();
                }
                if(accountsToUpdateMap != null) {
                    update accountsToUpdateMap.values();
                }
        //Added by Ealisha-end 
            }            
        }
    }
    
    
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
        
        //********************************** Start : Change Param by Avanish August 11, 2020 (SOQL Issue)
        coreAllEntitlementList=[Select id,Core_Contact_Id__c,Core_Type__c,Core_Selected__c,
                                                                      Core_Entitlement_Id__r.Name,Core_Entitlement_Id__c
                                                                      from Core_Contact_Entitlement__c 
                                                                      where Core_Contact_Id__c =:lContactIds
                                                                      AND Core_Selected__c = true];
        //Added by Geetha as per user story US113583
        validateEntitlementType(coreAllEntitlementList);//lContactIds); //Change Param by Avanish August 11, 2020 (SOQL Issue)
        // Added by prem
        /*coreAllEntitlementList=[Select id,Core_Contact_Id__c,Core_Type__c,Core_Selected__c,
                                                                      Core_Entitlement_Id__r.Name,Core_Entitlement_Id__c
                                                                      from Core_Contact_Entitlement__c 
                                                                      where Core_Contact_Id__c =:lContactIds
                                                                      AND Core_Selected__c = true];*/
        //********************************** END : Change Param by Avanish August 11, 2020 (SOQL Issue)
        
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
                
                System.debug(' skipValidation '+skipEntValidation);
                System.debug(' mEntActive '+mEntActive);
                System.debug(' newMap '+newMap);
                System.debug(' newMap '+oldMap);
                System.debug(' contEntObj.Id '+contEntObj.Id+ ' contEntObj.Core_Contact_Id__c '+contEntObj.Core_Contact_Id__c);
                System.debug('contactRecords=====>'+contactRecords);
                for(Contact contactObj : contactRecords) {
					//Commented by Naresh as part of  defect fix.
                    boolean validateEnglishOnlyFields = validateEnglishOnlyFields(contactObj, mUpdateContEngName, mUpdateAcctEngName);
                    // Call the local language methods to validate English Only Fields
                    System.debug('Zay - Outside validate English Only Loop '+contactObj.AccountId);
                    //if(!validateEnglishOnlyFields(contactObj)) {
                    System.debug('validateEnglishOnlyFields=====>'+!validateEnglishOnlyFields);
                    System.debug('contEntObj.Core_From_Source__c=====>'+!contEntObj.Core_From_Source__c);
                    System.debug('!skipEntValidation=====>'+!skipEntValidation);
                    //Commented by Naresh as part of  defect fix.
                     if(!validateEnglishOnlyFields && !contEntObj.Core_From_Source__c && !skipEntValidation  ) {
                        System.debug('Zay - Inside validate English Only Loop');
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
                        }*///Commented Earlier
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
                    system.debug('contactRecord_old:'+contactRecord);
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
                    System.debug(' From SOURCE >>  '+contEntObj.Core_From_Source__c);
                    if(contEntObj.Core_From_Source__c){
                      System.debug(' Engagement FOUND !.. and skipping validation ');
                        continue;
                    }
                        
                    
                    System.debug(' Running the validations for Entitlement > ' + contEntObj);
                    // Check for ODM Indicator field
                    if(!validateIsODM(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        System.debug(' ODM Indicator field '+contEntObj.Core_Entitlement_Id__c+' Name '+contEntObj.Name);
                        System.debug(' ODM Indicator field'+contactRecord);
                        
                        contEntObj.addError(mapConentValErrorMsg.get('System Non ODM'));
                    }  
                    // Check for CNDA field
                    if(!validateCNDANum(contEntObj.Core_Entitlement_Id__c, contactRecord)) {
                        contEntObj.addError(mapConentValErrorMsg.get('System CNDA'));
                    }
                    // Check for Engagement in Contact related list
                    //Utkarsh - Made changes to prevent validation to fire for IPA Registration.
                    Boolean validatecheck = true;
                    if(contEntObj.Core_Source__c != null && contEntObj.Core_Source__c != System.Label.PRM_Entitlement_Source){
                        validatecheck =validateEngagement(contEntObj.Core_Entitlement_Id__c, contactRecord,coreAllEntitlementList);
                    }
                    system.debug('validatecheck==>'+validatecheck);
                    if(!validatecheck) {
                        system.debug('ErrorMsg==>'+mapConentValErrorMsg.get(mapENtReqMessages.get(contEntObj.Core_Entitlement_Id__c)));
                        contEntObj.addError(mapConentValErrorMsg.get(mapENtReqMessages.get(contEntObj.Core_Entitlement_Id__c)));
                        //contEntObj.addError('NO PSG Basic Engagement');
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
           if(contEntObj.Core_Entitlement_Id__c == System.Label.Core_Employee || contEntObj.Core_Entitlement_Id__c == System.Label.Core_Lead_Development_Representative || contEntObj.Core_Entitlement_Id__c == System.Label.Core_Marketing_specialist || contEntObj.Core_Entitlement_Id__c == System.Label.Core_Offering_Editor||contEntObj.Core_Entitlement_Id__c == System.Label.Core_Partner_Admin )
                    {
                        if(!validateUniqueMPEntitlement(contEntObj.Core_Entitlement_Id__c, contactRecord,'')) {
                            
                            contEntObj.addError(mapConentValErrorMsg.get('System Unique MP Entitlement'));
                            
                        }
                    }
                    //Sonali Start (US731136 - Pipeline: CTO Requirement)
                    if(contEntObj.Core_Entitlement_Id__c == System.Label.Core_CTO_Distributor || contEntObj.Core_Entitlement_Id__c == System.Label.Core_CTO_Reseller){
                        if(!validateDCBCUniqueEntitlement(contEntObj.Core_Entitlement_Id__c, contactRecord,'')) {
                            System.debug('ErrorMsg2222:-'+mapConentValErrorMsg.get('UI Single Entitlement Assignment'));
                            contEntObj.addError(mapConentValErrorMsg.get('UI Single Entitlement Assignment'));
                        }  
                    }                 
                    //Sonali END
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
    /* Code Added : Avanish (Draco) : August 6, 2020
    Static Variable created and increment in method : isAddContactEntitlementTriggerAgain
    */
    public static integer isAddContactEntitlementTriggerAgain = 0;
    //Remove Subordinates custom metadata 
    public static List<Contact_Entitlement_Subordinates_Removal__mdt> lstConEntSubRemove = new List<Contact_Entitlement_Subordinates_Removal__mdt>();
    //Add Or Remove Subordinates
    //@future
    public static void addContactEntitlementSubordinates(List<Core_Contact_Entitlement__c> lConEnt) {
        isAddContactEntitlementTriggerAgain ++;
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
        String updateReasonAutoAssigned = 'Auto Assigned';       
        
        //Add Subordinates custom settings
        List<Core_Contact_Entitlement_Subordinates__c> lstConEntSubAdd = Core_Contact_Entitlement_Subordinates__c.getAll().values();
        
        // ---------------------------- Added extra condition for make single SOQL - Avanish - August 11, 2020
        if(!Test.isRunningTest() && lstConEntSubRemove.isEmpty()){ // Normal scenario, when the test execution doesn't happen
            lstConEntSubRemove = [SELECT Id,Label,Core_Condition__c,Core_Entitlement_Id__c,Core_Entitlement_Name__c,Core_Entitlement_Subordinate_Id__c,Core_Entitlement_Subordinate_Name__c FROM Contact_Entitlement_Subordinates_Removal__mdt];
        }else if (Test.isRunningTest()){
            lstConEntSubRemove = (List<Contact_Entitlement_Subordinates_Removal__mdt>) new ContactEntitlementSubordinatesRemoval().getCustomMetadataRecords('SELECT Id,Label,Core_Condition__c,Core_Entitlement_Id__c,Core_Entitlement_Name__c,Core_Entitlement_Subordinate_Id__c,Core_Entitlement_Subordinate_Name__c FROM Contact_Entitlement_Subordinates_Removal__mdt WHERE DeveloperName = \'Default\'');
        }
        
        //Loop on trigger.new to prepare set of contact IDs
        for(Core_Contact_Entitlement__c conEntRef : lConEnt) {
            stContactIds.add(conEntRef.Core_Contact_Id__c);
        }
         System.debug('==lalitha===lConEnt===>'+lConEnt);
        //Qeury all existing contact entitlements for the contact set
        List<Core_Contact_Entitlement__c> lExistingConEnt = [SELECT Id, Core_Entitlement_Id__c,Core_Entitlement_Id__r.Core_IsActive__c,Core_Contact_Id__r.Account.Core_CNDA_Number__c,Core_Contact_Id__r.Account.Core_IsODM__c, Core_Contact_Id__c, Core_Selected__c 
                                                             FROM Core_Contact_Entitlement__c
                                                             WHERE Core_Contact_Id__c IN :stContactIds AND Core_Entitlement_Id__r.Core_IsActive__c = true];
        
        System.debug('==lalitha===lExistingConEnt===>'+lExistingConEnt);
        //Loop on existing entitlements to prepare maps for 'Account ODM flag' and 'Selected flag'
        for(Core_Contact_Entitlement__c entRef : lExistingConEnt){
            mapContEntSelected.put(entRef.Core_Entitlement_Id__c,entRef.Core_Selected__c);
            mapAccountODM.put(entRef.id,entRef.Core_Contact_Id__r.Account.Core_IsODM__c);
            if(entRef.Core_Contact_Id__r.Account.Core_CNDA_Number__c != null && entRef.Core_Contact_Id__r.Account.Core_CNDA_Number__c !=''){
                mapAccountCNDA.put(entRef.id,entRef.Core_Contact_Id__r.Account.Core_CNDA_Number__c);
            }
        }
        System.debug('===lalitha===mapContEntSelected==>'+mapContEntSelected);
        System.debug('===lalitha===mapAccountODM==>'+mapAccountODM);
        System.debug('======mapAccountCNDA==>'+mapAccountCNDA);
        //Loop on Add Subordinates custom settings to prepare set of Subordinates
        for(Core_Contact_Entitlement_Subordinates__c subEntRefAdd : lstConEntSubAdd){
            List<Id> lstMulti = subEntRefAdd.Core_Entitlement_Subordinate_Id__c.split(',');
            for(Id subId : lstMulti){
             stAllSubId.add(subId);
            }
        }
        //Loop on Add Subordinates custom metadata to prepare set of Subordinates
        for(Contact_Entitlement_Subordinates_Removal__mdt subEntRefRemove : lstConEntSubRemove){
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
         System.debug('Zay - In first for loop+++++++'+conEntObj);
         if(conEntObj.Core_Selected__c){
            List<Core_Contact_Entitlement_Subordinates__c> conEntSub = new List<Core_Contact_Entitlement_Subordinates__c>();
            system.debug('==mapAccountODM.get(conEntObj.id)=@@==>'+mapAccountODM.get(conEntObj.id));
             if(mapAccountODM.get(conEntObj.id)!=null && mapAccountODM.get(conEntObj.id)){
                for(Core_Contact_Entitlement_Subordinates__c conEntSubObj : lstConEntSubAdd){
                   if(conEntSubObj.Core_Is_ODM_True__c && conEntSubObj.Core_Entitlement_Id__c == conEntObj.Core_Entitlement_Id__c ){      //mahendraa
                      if(conEntSubObj.Core_Is_CNDA_True__c  && !String.isBlank(mapAccountCNDA.get(conEntObj.id))){
                          conEntSub.add(conEntSubObj);
                       }else if(!conEntSubObj.Core_Is_CNDA_True__c ){
                         conEntSub.add(conEntSubObj);
                       }
                      System.debug('conEntSub===1==>>>>>>'+conEntSub);
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
                      System.debug('conEntSub===1==>>>>>>'+conEntSub);
                   }
                }
             }
            
            for(Core_Contact_Entitlement_Subordinates__c conEntSubObj : conEntSub){
              System.debug('lalitha===1'+conEntObj.Name);
              System.debug('lalitha==2='+conEntSubObj.Name);
              System.debug('lalitha=3=='+conEntObj.Core_Selected__c);
              if(conEntObj.Core_Entitlement_Id__c == conEntSubObj.Core_Entitlement_Id__c && conEntObj.Core_Selected__c == true){
                System.debug('Zay - Inside subordinate check before update or insert check');
                Boolean checkInsOrUpdate = false;
                for(Core_Contact_Entitlement__c existingConEntObj : lExistingConEnt){
                  if(conEntSubObj.Core_Entitlement_Subordinate_Id__c == existingConEntObj.Core_Entitlement_Id__c 
                           && conEntObj.Core_Contact_Id__c == existingConEntObj.Core_Contact_Id__c
                           && !existingConEntObj.Core_Selected__c && mapSubActive.get(existingConEntObj.Core_Entitlement_Id__c)){
                    Core_Contact_Entitlement__c conEntToUpdate = new Core_Contact_Entitlement__c(id=existingConEntObj.id, Core_Selected__c = true,Core_Status__c='Pending',Core_Source__c = updateReasonAutoAssigned);
                    System.debug('Zay - conEntToUpdate : ' + conEntToUpdate);
                    System.debug('Zay - Inside subordinate update');
                    if(!sEntSubToUpdateIds.contains(conEntToUpdate.id)) {
                       lEntSubToUpdate.add(conEntToUpdate);
                    }
                    sEntSubToUpdateIds.add(conEntToUpdate.id);
                    checkInsOrUpdate = true;
                  }else if(conEntSubObj.Core_Entitlement_Subordinate_Id__c == existingConEntObj.Core_Entitlement_Id__c 
                                     && conEntObj.Core_Contact_Id__c == existingConEntObj.Core_Contact_Id__c
                                     && existingConEntObj.Core_Selected__c){
                    checkInsOrUpdate = true;
                    System.debug('Zay - Inside subordinate update 2');
                  }
                }
                if(!checkInsOrUpdate){
                  if(mapSubActive.get(conEntSubObj.Core_Entitlement_Subordinate_Id__c)){
                     Core_Contact_Entitlement__c conEntToInsert = new Core_Contact_Entitlement__c(Core_Entitlement_Id__c = conEntSubObj.Core_Entitlement_Subordinate_Id__c, 
                                                                                                         Core_Selected__c = true, Core_Contact_Id__c = conEntObj.Core_Contact_Id__c, Core_Status__c='Pending', Core_Source__c = updateReasonAutoAssigned);
                     //mEntSubToInsert.put(conEntSubObj.Core_Entitlement_Subordinate_Id__c, conEntToInsert);
                     //Added by Manikanta START(for bulk upload issue)
                     lEntSubToInsert.add(conEntToInsert);
                     //Added by Manikanta END(for bulk upload issue)
                     System.debug('Zay - Inside subordinate insert ---- SKTest '+lEntSubToInsert);
                  }
                }
              }
            }
         }
       }
         for(Core_Contact_Entitlement__c conEntObj : lConEnt){ 
         System.debug('Zay - In first for loop+++++++'+conEntObj);
         Boolean notAdded = true;
         for(Core_Contact_Entitlement__c tobeUpdated : lEntSubToUpdate){
             if(tobeUpdated.id == conEntObj.id){
                 notAdded = false;
             }
         }
         
         if(!conEntObj.Core_Selected__c && notAdded){
             Boolean isAnyEntSelected= false;
           for(Contact_Entitlement_Subordinates_Removal__mdt conEntSubObj : lstConEntSubRemove){
             if(conEntObj.Core_Entitlement_Id__c == conEntSubObj.Core_Entitlement_Id__c && conEntObj.Core_Selected__c == false){
               System.debug('in else if lalitha===>');
               Boolean checkInsOrUpdate = false;
               for(Core_Contact_Entitlement__c existingConEntObj : lExistingConEnt){
                 System.debug('in existing for lalitha===>'+existingConEntObj.Core_Entitlement_Id__c);
                 List<Id> lstMultiSub = conEntSubObj.Core_Entitlement_Subordinate_Id__c.split(',');
                 for(id subRef :lstMultiSub){ 
                   if(subRef == existingConEntObj.Core_Entitlement_Id__c 
                      && conEntObj.Core_Contact_Id__c == existingConEntObj.Core_Contact_Id__c
                      && existingConEntObj.Core_Selected__c){
                    System.debug('in if lalitha===>');
                    System.debug('123===>'+existingConEntObj.Core_Entitlement_Id__c);
                    if(!String.IsBlank(conEntSubObj.Core_Condition__c)){
                     List<Id> lstConditionEntIds =  conEntSubObj.Core_Condition__c.split(',');
                     for(id entid : lstConditionEntIds){
                       system.debug('==12===lalitha==>'+mapContEntSelected);
                       System.debug(entid+'==in map for if lalitha===>'+mapContEntSelected.get(entid));
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
                        System.debug('==lalitha==existingConEntObj.Core_Entitlement_Id__c==>'+existingConEntObj.Core_Entitlement_Id__c);
                        System.debug('==lalitha===mapSubActive.get(existingConEntObj.Core_Entitlement_Id__c)==>'+mapSubActive.get(existingConEntObj.Core_Entitlement_Id__c));
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
        System.debug('Zay - lEntSubToUpdate : ' + lEntSubToUpdate);
        update lEntSubToUpdate;
      }
        //Added by Manikanta START(for bulk upload issue)
      /*if(mEntSubToInsert != null && mEntSubToInsert.size() > 0){
        System.debug('Zay - lEntSubToInsert : ' + lEntSubToInsert);
        lEntSubToInsert = mEntSubToInsert.values();
        System.debug('Zay - lEntSubToInsert : ' + lEntSubToInsert);
        insert lEntSubToInsert;  
        System.debug('Zay - lEntSubToInsert : ' + lEntSubToInsert);
       }  */
        System.debug('Zay - lEntSubToInsert : $$$$' + lEntSubToInsert);
        if(!lEntSubToInsert.isEmpty()){
            System.debug('Zay - lEntSubToInsert : $$$$ inside' + lEntSubToInsert);
            Database.insert(lEntSubToInsert, false);
        }
        //Added by Manikanta END(for bulk upload issue)
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
    }
    
    
     //Start----Added by Popcornapps
     public static List<String> listOfInvalidCNDANum = (Label.Core_IPS_Invalid_CNDA).split(';');
       
   public static Boolean validateCNDANum(Id entId, Contact conObj) {
        // CNDA validation is only for Partner Portal.
        system.debug('Object msg mapentIds CNDANum ::'+mapentIds);
        system.debug('Object msg entId ::'+entId);
        
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
        system.debug('Object msg mapentIds SupportOwner ::'+mapentIds);
        system.debug('Object msg entId ::'+entId);
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
                System.debug('Zay - What happened');
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
      
    public static Boolean validateEngagement(Id entId, Contact conObj,List<Core_Contact_Entitlement__c> coreAllEntitlementList ) {
       system.debug('coreAllEntitlementList ====='+coreAllEntitlementList );
        Map<ID,Set<ID>> mapConEntitlement=new Map<ID,Set<ID>>();
        boolean ipaSource = false;
        ID contactId=conObj.id;
         system.debug('contactId::'+contactId);
        if(coreAllEntitlementList != null && !coreAllEntitlementList.IsEmpty()){
            for(Core_Contact_Entitlement__c allEnt: coreAllEntitlementList){
                Set<ID> relatedContEntitlement =new Set<ID>();
                for(Core_Contact_Entitlement__c allEntinner: coreAllEntitlementList)
                if(allEnt.Core_Contact_Id__c==allEntinner.Core_Contact_Id__c){
                    relatedContEntitlement.add(allEntinner.Core_Entitlement_Id__c);
                }
                mapConEntitlement.put(allEnt.Core_Contact_Id__c,relatedContEntitlement);
            }
        }
        //Getting the custom setting record values  
        Boolean engagementAvailable=false;
        Map<ID, ID> entEngagementMap = new Map<ID, ID>();
        List<Core_Contact_Entitlement_Validation_Req__c>  ccEngagementValList = new List<Core_Contact_Entitlement_Validation_Req__c>();
        ccEngagementValList = Core_Contact_Entitlement_Validation_Req__c.getAll().values();
        System.debug('ccEngagementValList=====>>>>>'+ccEngagementValList);
        system.debug('key set :: '+mapConEntitlement.keyset());
         system.debug('mapConEntitlement :: '+mapConEntitlement);
        Set<Id> entitlementSet = new Set<Id>();
        for(Core_Contact_Entitlement_Validation_Req__c ent:ccEngagementValList){
              entitlementSet.add(ent.Core_Entitlement_id__c);
              entEngagementMap.put(ent.Core_Entitlement_id__c,ent.Core_Entitlement_Req_Id__c);
              
        }
        System.debug('AAAA : entitlementSet=====>>>>>'+entitlementSet);
        System.debug('AAAA : entEngagementMap=====>>>>>'+entEngagementMap);        
        if(entitlementSet.size()>0 && entitlementSet.contains(entId)){
            //Getting the Entitlement records based on contact id and basic entitlement id from the custom setting
            if(mapConEntitlement.keyset().contains(contactId)){
               system.debug('map===='+mapConEntitlement.get(contactId).contains(entEngagementMap.get(entId)));
                engagementAvailable=mapConEntitlement.get(contactId).contains(entEngagementMap.get(entId));
            }
            if(!engagementAvailable){
                //System.Debug('AAAA : mapConEntitlement : ' + mapConEntitlement);
                //System.Debug('AAAA : entEngagementMap : ' + entEngagementMap);
                //System.Debug('AAAA : entId : ' + entId);
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
        System.debug('Zay - Inside validateContactEnglishOnlyFields');
        List<Contact> lUpdateContacts = new List<Contact>();
        for(Contact conObj : newList) {
            Boolean updateContactFirst = false;
            Boolean updateContactLast = false;
            if(conObj.Core_Contact_B2B_Indicator__c) {
                System.debug('Zay - Inside validateContactEnglishOnlyFields - B2B indicator check');
                if(conObj.Core_English_Only_First_Name__c != conObj.FirstName && conObj.FirstName != oldList.get(conObj.Id).FirstName) {
                    System.debug('Zay - Inside validateContactEnglishOnlyFields - First Name check');
                    if(checkValidText(conObj.FirstName)) {
                        conObj.Core_English_Only_First_Name__c = conObj.FirstName;
                        updateContactFirst = true;
                    } 
                }
                if(conObj.Core_English_Only_Last_Name__c != conObj.LastName && conObj.LastName != oldList.get(conObj.Id).LastName) {
                    System.debug('Zay - Inside validateContactEnglishOnlyFields - Last Name check');
                    if(checkValidText(conObj.LastName)) {
                        conObj.Core_English_Only_Last_Name__c = conObj.LastName;
                        updateContactLast = true;
                    }
                }  
            }      
        }
    }
     /***************************************************************************************************** 
    Method Name:                                             validateAccountEnglishOnlyFields
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – VD                          07/23/2018       US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account 
    ******************************************************************************************************/
    public static void validateAccountEnglishOnlyFields(List<Account> newList, Map<Id, Account> oldList) {
        List<Account> lUpdateAccounts = new List<Account>();
        for(Account acctObj : newList) 
        {
            //Start of Changes - To check if the record type is not Core_Partner_Account_Group - US408340 - by Accenture 
            if(acctObj.RecordTypeId != coMarketingRecordTypeId && acctObj.RecordTypeId != pAGRecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
            //End of Changes - To check if the record type is not Core_Partner_Account_Group - US408340 - by Accenture 
            {
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
   
    private static List<Core_Contact_Entitlement_Exclusive__c> coreContactEntExRecords = new List<Core_Contact_Entitlement_Exclusive__c>();
  
    /***************************************************************************************************** 
    Method Name:                                             getCoreContactEntExRecords
    @return  :                                               Void
    Modified By:                                     Sandip  
  Date:                                 02/28/2019 
  Changes:                                                 DE34525 - Updated Method to query Core_Contact_Entitlement_Exclusive__c
    only once during submission of entitlements
    ******************************************************************************************************/
    private static List<Core_Contact_Entitlement_Exclusive__c> getCoreContactEntExRecords(){
       
        System.debug('getCoreContactEntExRecords = '+ coreContactEntExRecords); 
        
        if(coreContactEntExRecords != null && coreContactEntExRecords.isEmpty()){ //&& emailDisablerRuleRecords.isEmpty()
            coreContactEntExRecords = [Select Id,Name,Core_Unique_Ids__c from Core_Contact_Entitlement_Exclusive__c];
        }
        
        return coreContactEntExRecords;
    }
  
    
    // Entitlement should be unique.
    //Modified by Geetha as per user story US113583
    public static Boolean validateUniqueEntitlement(Id entId, Contact conObj, String uniqueEntitlementName){
        system.debug('entId===>>>'+entId+'conObj=====>>>>'+conObj+'uniqueEntitlementName=====>>>>>'+uniqueEntitlementName);
        //mcs = Core_Contact_Entitlement_Exclusive__c.getall().values();
        //DE34525 - Commented the below line.This was causing too many SOQL queries to be fired.
        //mcs = [Select Id,Name,Core_Unique_Ids__c from Core_Contact_Entitlement_Exclusive__c];
        mcs =  getCoreContactEntExRecords();
        count=0;
        ipscount=0;
        if(mapIPSContactIds.get(conObj.id)!=null){
                    mapIPSContactIds.put(conObj.id,mapIPSContactIds.get(conObj.id));
                    system.debug('mapIPSContactIds==if==>'+mapIPSContactIds); 
                }else{
                     mapIPSContactIds.put(conObj.id,ipscount);
                     system.debug('mapIPSContactIds==else==>'+mapIPSContactIds); 
                }
        for(Core_Contact_Entitlement_Exclusive__c csVal:mcs)
        {
            idsList.addAll((List<ID>)((csVal.Core_Unique_Ids__c).split(',')));
            
        }
        system.debug('idsList====>>>>>'+idsList);
        if(idsList.contains(entId)){
            if(String.isBlank(uniqueEntitlementNames)){
                uniqueEntitlementNames=uniqueEntitlementName;
                system.debug('uniqueEntitlementNames===1==>>>>>>>>'+uniqueEntitlementNames);
            }else{
                uniqueEntitlementNames=uniqueEntitlementNames+', '+uniqueEntitlementName;
                system.debug('uniqueEntitlementNames===2==>>>>>>>>'+uniqueEntitlementNames);
            }
            if((entId+'').contains(Label.Core_Entitlement_IPS_Id)){
                      mapIPSContactIds.put(conObj.id,1);
                     system.debug('mapIPSContactIds==count==>'+mapIPSContactIds); 
            }
            if(mapContactIds.get(conObj.id)!=null){        
                mapContactIds.put(conObj.id,mapContactIds.get(conObj.id)+1);
          
            }else{
             mapContactIds.put(conObj.id,++count);
            }
            system.debug('mapContactIds==>'+mapContactIds);
        }
        if(mapContactIds.get(conObj.id)>1 && (mapIPSContactIds.get(conObj.id)==1)){ // map contact id count check
            return false;
        }else{
            return true;
        }
    }
    
    /*******************************************************************************************************************************************
     * User Story		 : US731136 - Pipeline: CTO Requirement
     * Method Name		 : validateDCBCUniqueEntitlement
     * Method Parameters : Id entId, Contact conObj, String uniqueEntitlementName
     * Owner Name 		 : Sonali Mehetre
     * Date 			 : 8/24/2020
     ******************************************************************************************************************************************/
    public static Boolean validateDCBCUniqueEntitlement(Id entId, Contact conObj, String uniqueEntitlementName){        
        mcs =  getCoreContactEntExRecords();
        count=0;
        ipscount=0;
        
        if(mapOfDCBCContIds.get(conObj.id)!=null){
            mapOfDCBCContIds.put(conObj.id,mapOfDCBCContIds.get(conObj.id));            
        }else if(mapOfCTOResellerContIds.get(conObj.id)!=null){
            mapOfCTOResellerContIds.put(conObj.id,mapOfCTOResellerContIds.get(conObj.id));            
        }else{
            mapOfCTOResellerContIds.put(conObj.id,ipscount);
            mapOfDCBCContIds.put(conObj.id,ipscount);             
        }
        
        for(Core_Contact_Entitlement_Exclusive__c csVal:mcs)
        {
            idsList.addAll((List<ID>)((csVal.Core_Unique_Ids__c).split(',')));
            
        }        
        if(idsList.contains(entId)){
            if(String.isBlank(uniqueEntitlementNames2)){
                uniqueEntitlementNames2=uniqueEntitlementName;                
            }else{
                uniqueEntitlementNames2=uniqueEntitlementNames2+', '+uniqueEntitlementName;                
            }
            if((entId+'').contains(Label.Core_CTO_Reseller)){
                mapOfCTOResellerContIds.put(conObj.id,1);                
            }else if ((entId+'').contains(Label.Core_CTO_Distributor)){
                mapOfDCBCContIds.put(conObj.id,1);                
            }
            if(mapOfContIds.get(conObj.id)!=null){                
                mapOfContIds.put(conObj.id,mapOfContIds.get(conObj.id)+1);          
            }else{
             mapOfContIds.put(conObj.id,++count);             
            }            
            
        }
        
        if(mapOfContIds.get(conObj.id)>1 && (mapOfDCBCContIds.get(conObj.id)==1) && (mapOfCTOResellerContIds.get(conObj.id)==1)){ // map contact id count check            
            return false;
        }else{
            return true;
        }        
    }
    
    
  //Added for User Story by Usha
    public static List<Core_Contact_Entitlement_Exclusive__c> mcs1;
    public static Set<ID> idsList1=new Set<ID>();
    public static String uniqueEntitlementNames1='';
    public static Map<Id,Integer> mapContactIds1 = new Map<Id,Integer>();
    public static Map<Id,Integer> mapPADelegateContactIds = new Map<Id,Integer>();
    public static Map<Id,Integer> mapPAdminContactIds = new Map<Id,Integer>();
    public static List<Core_Contact_Entitlement_Exclusive__c> entExclusive;
    
    public static Boolean validateUniqueMPEntitlement(Id entId, Contact conObj, String uniqueEntitlementName){
        system.debug('entId===>>>'+entId+'conObj=====>>>>'+conObj+'uniqueEntitlementName=====>>>>>'+uniqueEntitlementName);
        //mcs = Core_Contact_Entitlement_Exclusive__c.getall().values();
        //mcs1 = [Select Id,Name,Core_Unique_Ids__c from Core_Contact_Entitlement_Exclusive__c]; //27-Jun-2019
        mcs1 = getCoreContactEntExRecords();
        count=0;
        ipscount=0;
        if(mapPADelegateContactIds.get(conObj.id)!=null){
            mapPADelegateContactIds.put(conObj.id,mapPADelegateContactIds.get(conObj.id));
            system.debug('mapPADelegateContactIds==if==>'+mapPADelegateContactIds); 
        }
        else if(mapPAdminContactIds.get(conObj.id)!=null){
            mapPAdminContactIds.put(conObj.id,mapPAdminContactIds.get(conObj.id));
            system.debug('mapPAdminContactIds==if==>'+mapPAdminContactIds); 
        }
        else{
            mapPADelegateContactIds.put(conObj.id,ipscount);
            mapPAdminContactIds.put(conObj.id,ipscount);
            system.debug('mapPADelegateContactIds==else==>'+mapPADelegateContactIds); 
            system.debug('mapPAdminContactIds==else==>'+mapPAdminContactIds); 
        }
        if(!Test.isRunningTest()){
            for(Core_Contact_Entitlement_Exclusive__c csVal:mcs1)
            {
                idsList.addAll((List<ID>)((csVal.Core_Unique_Ids__c).split(',')));
                
            }
        }
        else{
            entExclusive = [Select Id,Name,Core_Unique_Ids__c from Core_Contact_Entitlement_Exclusive__c];
            for(Core_Contact_Entitlement_Exclusive__c csVal:entExclusive)
            {
                idsList.addAll((List<ID>)((csVal.Core_Unique_Ids__c).split(',')));
                
            }
            
        }
        system.debug('MPidsList====>>>>>'+idsList);
        system.debug('MPentId=====>'+entId);
        if(idsList.contains(entId)){
            if(String.isBlank(uniqueEntitlementNames1)){
                uniqueEntitlementNames1=uniqueEntitlementName;
                system.debug('uniqueEntitlementNames===1==>>>>>>>>'+uniqueEntitlementNames1);
            }else{
                uniqueEntitlementNames1=uniqueEntitlementNames1+', '+uniqueEntitlementName;
                system.debug('uniqueEntitlementNames===2==>>>>>>>>'+uniqueEntitlementNames);
            }
            if((entId+'').contains(Label.Core_Partner_Admin_Delegate)){
                mapPADelegateContactIds.put(conObj.id,1);
                system.debug('mapPADelegateContactIds==count==>'+mapPADelegateContactIds); 
            }
            else if ((entId+'').contains(Label.Core_Partner_Admin)){
                mapPAdminContactIds.put(conObj.id,1);
                system.debug('mapPAdminContactIds==count==>'+mapPAdminContactIds);
            }
            
            if(mapContactIds1.get(conObj.id)!=null && !String.isEmpty(uniqueEntitlementName)){        
                mapContactIds1.put(conObj.id,mapContactIds1.get(conObj.id)+1);
                
            }else if(!String.isEmpty(uniqueEntitlementName)){
                mapContactIds1.put(conObj.id,++count);
            }
            system.debug('mapContactIds1==>'+mapContactIds1);
        }
        if(mapContactIds1.get(conObj.id)>1 && (mapPADelegateContactIds.get(conObj.id)==1)){ // map contact id count check
            return false;
        }else if(mapContactIds1.get(conObj.id)>1 && (mapPAdminContactIds.get(conObj.id)==1)){
            return false;
        }
        else{
            return true;
        }
    }
    //Added by Geetha as per user story US113583
    //Method to validate uique entitlement with Data Loader
    //********************************** Start : Change Param by Avanish August 11, 2020 (SOQL Issue)
    public static void validateEntitlementType(List<Core_Contact_Entitlement__c> coreAllEntitlementList){//List<Id> lstconObj){
        /*List<Core_Contact_Entitlement__c> coreAllEntitlementList=[Select id,Core_Contact_Id__c,Core_Type__c,Core_Selected__c,
                                                                      Core_Entitlement_Id__r.Name,Core_Entitlement_Id__c
                                                                      from Core_Contact_Entitlement__c where Core_Contact_Id__c in :lstconObj AND Core_Selected__c = true];*/
      //********************************** END : Change Param by Avanish August 11, 2020 (SOQL Issue)
        for (Core_Contact_Entitlement__c entitlement : coreAllEntitlementList){
            if(mapContactEntitlement.get(entitlement.Core_Contact_Id__c) != null){
                Set<Id> tempSet=mapContactEntitlement.get(entitlement.Core_Contact_Id__c);
                tempSet.add(entitlement.Core_Entitlement_Id__c);
                mapContactEntitlement.put(entitlement.Core_Contact_Id__c,tempSet);
            }else{
                mapContactEntitlement.put(entitlement.Core_Contact_Id__c,new Set<id>{entitlement.Core_Entitlement_Id__c});
            }
        system.debug('mapContactEntitlement=====>>>>>>>>'+mapContactEntitlement);
        }  
      }
      public static Boolean validatePartnerEntitlement(Id entId, Contact conObj){
        
        //DE34525 - Commented the below line.This was causing too many SOQL queries to be fired.
        //mcs = [Select Id,Name,Core_Unique_Ids__c from Core_Contact_Entitlement_Exclusive__c];
        mcs =  getCoreContactEntExRecords();
          
        for(Core_Contact_Entitlement_Exclusive__c csVal:mcs)
        {
            idsList.addAll((List<ID>)((csVal.Core_Unique_Ids__c).split(',')));
            system.debug('idsList=before removing=>'+idsList);
            
        }
        Set<Id> partnerIds = new Set<Id>(idsList);
        partnerIds.remove((Id)Label.Core_Entitlement_IPS_Id);
        system.debug('idsList=after removing=>'+idsList);
          
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

 //COMMENT for WW22
   /* @future
    public static void ValidateLDRForPAG(Set<Id> contactIds)
    {
        Set<ID> PAGIds=new Set<ID>();
        Set<ID> contactAccountIds = new Set<ID>();
        Map<Id,List<Core_Account_Group_Member__c>> pagToIntelAccountsMap=new Map<Id,List<Core_Account_Group_Member__c>>();
        Set<Id> intelAccountIdsFromAllPAGs=new Set<Id>();
        Map<Id,Account> AccountDetailsMap=new Map<Id,Account>();
        Set<Id> contactIdsfromAllPAGS=new Set<Id>();
        
        //get list of account ids for the contacts that were updated/passed to ValidateLDRForPAG
        List<Contact> contactList = [Select AccountId from Contact where Id in :contactIds];
        for (Contact c : contactList) {
            contactAccountIds.add(c.AccountId);
        }
        
        //get list of PAG ids for the contacts based on the contact's account id
        List<Core_Account_Group_Member__c>  allPartnerAcc = [SELECT Id, Core_Partner_Account_Id__c,Core_MDA_Ind__c, Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                             WHERE Core_Intel_Account_Id__c IN:contactAccountIds];
        for(Core_Account_Group_Member__c partneraccount : allPartnerAcc)
        {
            
            PAGIds.add(partneraccount.Core_Partner_Account_Id__c);
        }
        //populate pagToIntelAccountsMap: pagId->List<Core_Account_Group_Member__c>
        for(Core_Account_Group_Member__c pagRecord:[SELECT Id, Core_Partner_Account_Id__c,Core_MDA_Ind__c, Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                    WHERE Core_Partner_Account_Id__c IN :PAGIds])
        {
            intelAccountIdsFromAllPAGs.add(pagRecord.Core_Intel_Account_Id__c);
            
            
            if(pagToIntelAccountsMap.containsKey(pagRecord.Core_Partner_Account_Id__c)) {
                List<Core_Account_Group_Member__c> PAGToIntelAccountList = pagToIntelAccountsMap.get(pagRecord.Core_Partner_Account_Id__c);
                PAGToIntelAccountList.add(pagRecord);
                pagToIntelAccountsMap.put(pagRecord.Core_Partner_Account_Id__c, PAGToIntelAccountList);
            } 
            else {
                pagToIntelAccountsMap.put(pagRecord.Core_Partner_Account_Id__c, new List<Core_Account_Group_Member__c> { pagRecord });
            }
            
            
        }
        //populate AccountDetailsMap:AccountId->Account
        for(Account acc:[Select Id,Name,Core_IPA_Partner_Role__c,Phone,RecordTypeId,(SELECT Id,Name,FirstName, LastName, Email,Core_IPA_Partner_Role__c FROM Contacts) from Account where Id in :intelAccountIdsFromAllPAGs])
        {
            
            AccountDetailsMap.put(acc.Id,acc);
            
        }
        //populate contactsWithLDRRole:contacts from multiple pags that have LDR role.
        
        for(Contact c:[Select ID from Contact where AccountId in:intelAccountIdsFromAllPAGs])
        {
            contactIdsfromAllPAGS.add(c.Id);
        }
        Set<Id> contactsWithLDRRole=new Set<Id>();
        String LDRRole=Label.LDRRole;
        for(Core_Contact_Entitlement__c cEnt:[SELECT Id, Core_Contact_Id__c, Core_Entitlement_Id__r.Name FROM Core_Contact_Entitlement__c where Core_Contact_Id__c IN:contactIdsfromAllPAGS and Core_Entitlement_Id__c=:LDRRole and Core_Selected__c=true])
        {
            contactsWithLDRRole.add(cEnt.Core_Contact_Id__c);
        }
        
        for(Id pagId:PAGIds)
        {
            
            Boolean ldrForPAG=false;
            List<Contact> pagCntList=new List<Contact>();
            Set<Id> pagContactIdsSet=new Set<Id>();
            List<Core_Account_Group_Member__c> cagList=pagToIntelAccountsMap.get(pagId);
            for(Core_Account_Group_Member__c cag:cagList)
            {
                Account a=AccountDetailsMap.get(cag.Core_Intel_Account_Id__c);
                //31 pagCntList.add(a.Contacts);
                if(a.Contacts!=null)
                {
                    for(Contact c:a.Contacts)
                    {
                        pagContactIdsSet.add(c.Id);
                    }
                }
            }
            
            for(Id pagContactId :pagContactIdsSet)
            {
                if(contactsWithLDRRole.contains(pagContactId))
                { 
                    system.debug('ldr role present for:'+pagContactId + ' under pag: '+pagId );
                    ldrForPAG=true;
                    break;
                }
                
            }
            if(!ldrForPAG)
                
            {
                
                System.debug('sending mail to public group for pag:'+pagId);
                PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();  
                objEmailNotif.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
                Map<String,String> paramMap = new Map<String,String>();
                paramMap.put('Account_ID',pagId);
                objEmailNotif.InputParameters=paramMap;
                //TODO:create label for business event
                objEmailNotif.BusinessEvent=Label.NOLDRFORPAG;
                PRM_EmailUtility.sendEmail(objEmailNotif);
                system.debug('mail sent to admin group!!!');
                
            }
        } 
        
        
        
        
    }*/
    
  
       
     
      




        
}