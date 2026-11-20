public without sharing class PRM_SalesCloud_Integration {
    
    public static final String ACCOUNT_MESSAGE_TYPE = Label.PRM_SalesCloudInt_Account_Message_Type;
    public static final String CONTACT_MESSAGE_TYPE = Label.PRM_SalesCloudInt_Contact_Message_Type;
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_SalesCloud_Integration';
    public static final String LOG_ENTRY_PROJECT    = 'IPA';
    
    
    //public static boolean IPARefresh = Boolean.valueOf(label.PRM_IPARefresh);
    public static List<PRM_AccountBenefitAssociation__c> accBenefitList = new  List<PRM_AccountBenefitAssociation__c>();
    public static Id PAGRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
    public static Map<String,Integer> warrantyQtyMap = new Map<String,Integer>();
    public static Map<String,Integer> ProgramTierRankingMap = new Map<String,Integer>();
    public static Map<Integer,String> rankTierMap = new Map<Integer,String>();
           
    public static void GenerateAccountOBM (set<Id> IPAAccountIds){
        
        // This method is called from PRM_SalesCloud_AccountPayload_Batch class.
        if(IPAAccountIds.size() > 0){
            
          
            String tierRanking = /*(!IPARefresh) ?LabelConfiguration__mdt.getInstance('ChannelProgramLevelRanking1').Value__c :*/ LabelConfiguration__mdt.getInstance('IPA2TierRanking').Value__c; // IPA Refresh - switch rmeoval
            for(String prgmrank : tierRanking.split(';'))
            {
                List<String> progTier = prgmrank.split(':');
                ProgramTierRankingMap.put(progTier[0],Integer.valueOf(progTier[1]));
                rankTierMap.put(Integer.valueOf(progTier[1]),progTier[0]);
                
            }
            Map<Id,PRM_PartnerBenefit__c> warrantyBenefitsMap = new Map<Id,PRM_PartnerBenefit__c>([Select Id FROM PRM_PartnerBenefit__c WHERE PRM_Quantitative_Ind__c = TRUE AND PRM_InActive_Ind__c = FALSE AND PRM_Channel_Program_Id__r.PRM_programCode__c = : Label.PRM_IPAEngagement ]);
            if(warrantyBenefitsMap.size() > 0){
                List<PRM_VXBnftMatrix__c> benefitMatrixList = new List<PRM_VXBnftMatrix__c>();
                /*  if (IPARefresh=='TRUE'){
                    benefitMatrixList = [SELECT Id,Name,PRM_Partner_Role_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,
                                                            PRM_Channel_Program_Level_Id__r.Name,PRM_Total_Quantity_Nbr__c From PRM_VXBnftMatrix__c 
                                                            WHERE PRM_Partner_Benefit_Id__c IN :warrantyBenefitsMap.keySet() and PRM_Channel_Program_Level_Id__r.PRM_inactind__c  = false];
                }else{
                    benefitMatrixList = [SELECT Id,Name,PRM_Partner_Role_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,
                                                            PRM_Channel_Program_Level_Id__r.Name,PRM_Total_Quantity_Nbr__c From PRM_VXBnftMatrix__c 
                                                            WHERE PRM_Partner_Benefit_Id__c IN :warrantyBenefitsMap.keySet()];
                }*/
                //IPA2.0 - Switch setup for filtering only active tier's benefits
                benefitMatrixList = /*(IPARefresh)?*/ [SELECT Id,Name,PRM_Partner_Role_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,
                                                            PRM_Channel_Program_Level_Id__r.Name,PRM_Total_Quantity_Nbr__c From PRM_VXBnftMatrix__c 
                                                            WHERE  PRM_Channel_Program_Level_Id__r.PRM_inactind__c  = false and PRM_IsActive_Ind__c = true] /*: [SELECT Id,Name,PRM_Partner_Role_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,
                                                            PRM_Channel_Program_Level_Id__r.Name,PRM_Total_Quantity_Nbr__c From PRM_VXBnftMatrix__c 
                                                            WHERE PRM_Partner_Benefit_Id__c IN :warrantyBenefitsMap.keySet() and PRM_Channel_Program_Level_Id__r.PRM_inactind__c  = true]*/; // IPA Refresh - switch removal
                for(PRM_VXBnftMatrix__c benefitMatrixRec :benefitMatrixList ){
                    {
                        warrantyQtyMap.put(benefitMatrixRec.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c+'~~'+benefitMatrixRec.PRM_Partner_Role_Nm__c+'~~'+
                            benefitMatrixRec.PRM_Channel_Program_Level_Id__r.Name,  (String.isEmpty(String.valueOf(benefitMatrixRec.PRM_Total_Quantity_Nbr__c)) ? 0 : (Integer) benefitMatrixRec.PRM_Total_Quantity_Nbr__c ));
                    }
                }
                
            }
            generateAccOutboundMessage(warrantyQtyMap,ProgramTierRankingMap,IPAAccountIds);
      }
                                                        }
    public static void generateAccOutboundMessage(Map<String,Integer> warrantyQtyMap, Map<String,Integer> ProgramTierRankingMap,set<Id> IPAAccountIds){
        List<Account> accountsToBeUpdated = new List<Account>();
        List<Core_Log_Entry__c> listCoreLogEntry = new List<Core_Log_Entry__c>();
        
             List<Account> accts = new List<Account>();
        
        /*if ( IPARefresh ){*/
            accts = [SELECT Name,AccountNumber,Core_Prime_Account_Name__c,Core_Sales_Groups__c,Industry,Core_Covered_Account__c,Core_CNDA_Number__c,
                                   Core_CIM_ID__c, Core_Business_Partner_Id__c,Core_Business_ID__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,
                                   Core_Geo__c,Core_Sub_Geo__c,Core_User_Defined_Phone_Number__c,Core_User_Defined_Website__c,Core_IPA_One_Partner_Id__c,
                                   Core_English_Only_Name__c,Core_IPA_Partner_Segment__c,RecordTypeId,Core_IPA_Badge_Tier__c,
                                   Core_Account_Legal_Name__c,Core_Account_BU_Focus__c,LastModifiedDate,Core_Business_Party_Id__c,
                                   OwnerId,Owner.Email,Owner.FirstName,Owner.LastName,RecordType.Name,Core_Intel_Partner_Alliance_PartnerGroup__c,                               
                                   BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,BillingCountryCode,BillingPostalCode,
                                   ShippingStreet,ShippingCity,ShippingState,ShippingStateCode,ShippingCountry,ShippingCountryCode,ShippingPostalCode,  Core_Deactivated__c,Core_Deactivation_Reason__c,                                   
                                   //PRM_IPA_Integration_Status__c,PRM_IPA_Integration_Queue_Text__c,
                                   // Account ERPM Engagements
                                  //Commenting as its no longert used (SELECT Core_Account_Id__r.Name,Core_ERPM_Engagement_Id__r.Name,Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,Core_ERPM_Engagement_Id__r.Core_Technical_Tier_Code__c FROM Account_ERPM_Engagements__r),
                                   // Account Channel Memberships
                                   (SELECT Id, PRM_Status_Change_Dt__c,PRM_Channel_Program_Id__r.Name,PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Channel_Program_Level_Id__r.Rank,PRM_Partner_Role__c,PRM_Status_Nm__c,PRM_Channel_Program_Level_Id__r.PRM_Partner_Tier_Name__c FROM Channel_Memberships1__r WHERE PRM_Channel_Program_Level_Id__r.PRM_inactind__c = false),
                                   // Account Benefit Associations     
                                   (SELECT PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Status_Nm__c/*,PRM_Quantity__c*/ FROM AccountBenefitAssociations__r),
                                   // Account Specialty Assciations       
                                   (SELECT Name,PRM_Start_Date_Dt__c,PRM_InActive_Ind__c,PRM_Specialty_Id__r.Name,PRM_Specialty_Id__r.PRM_Role_Nm__c,PRM_Specialty_Id__r.PRM_Tier_Nm__c,PRM_Specialty_Type__c FROM Account_Specialty_Associations__r),
                                   // Account ONE PARTNER ID GROUP MEMEBRS       
                                   (SELECT Name,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Name,Core_Partner_Account_Id__c,Core_Partner_Account_Id__r.Name,Core_Inactive_Ind__c,Core_MDA_Ind__c FROM Partner_Account_Group_Members1__r WHERE Core_Inactive_Ind__c=false AND Core_Business_Party_Id__c != null limit 1),
                                   //Partner Group Members                                   
                                   (SELECT Name,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Core_CIM_ID__c,Core_Intel_Account_Id__r.Core_Business_Party_Id__c,Core_Intel_Account_Id__r.Name,Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c ,Core_Partner_Account_Id__c,Core_Partner_Account_Id__r.Name,Core_Inactive_Ind__c,Core_MDA_Ind__c FROM Partner_Account_Group_Members__r WHERE Core_Business_Party_Id__c != null),                                   
                               // Account Legal Agreements       
                                   (SELECT Name,PRM_Agreement_Sign_Dt__c,PRM_Signed_By_Name__c,PRM_Signed_By_Email__c,PRM_Partner_Agreement_Id__r.Name,PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name FROM AccountLegalAgreementAssociations__r),
                                   (SELECT Name,Partner_Program__r.name,Effective_End_Date_Time__c,Inactive_Indicator__c FROM Account_Whitelisted_Domains__r),
                                   (SELECT PRM_Distributor_Id__r.Name,PRM_Choice_Nm__c,PRM_Consent_Provided_By_Id__r.Name,PRM_Consent_Provided_Date_Dt__c,PRM_Start_Date_Dt__c,PRM_End_Date_Dt__c,PRM_Consent_Provided_Ind__c FROM Partner_Assist_Consent__r)
                                   FROM Account WHERE Id IN :IPAAccountIds];
        /*}else{
            accts = [SELECT Name,AccountNumber,Core_Prime_Account_Name__c,Core_Sales_Groups__c,Industry,Core_Covered_Account__c,Core_CNDA_Number__c,
                                   Core_CIM_ID__c, Core_Business_Partner_Id__c,Core_Business_ID__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,
                                   Core_Geo__c,Core_Sub_Geo__c,Core_User_Defined_Phone_Number__c,Core_User_Defined_Website__c,Core_IPA_One_Partner_Id__c,
                                   Core_English_Only_Name__c,Core_IPA_Partner_Segment__c,RecordTypeId,Core_IPA_Badge_Tier__c,
                                   Core_Account_Legal_Name__c,Core_Account_BU_Focus__c,LastModifiedDate,Core_Business_Party_Id__c,
                                   OwnerId,Owner.Email,Owner.FirstName,Owner.LastName,RecordType.Name,Core_Intel_Partner_Alliance_PartnerGroup__c,                               
                                   BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,BillingCountryCode,BillingPostalCode,
                                   ShippingStreet,ShippingCity,ShippingState,ShippingStateCode,ShippingCountry,ShippingCountryCode,ShippingPostalCode,  Core_Deactivated__c,Core_Deactivation_Reason__c,                                   
                                   //PRM_IPA_Integration_Status__c,PRM_IPA_Integration_Queue_Text__c,
                                    // Account Channel Memberships
                                   (SELECT Id, PRM_Status_Change_Dt__c,PRM_Channel_Program_Id__r.Name,PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Channel_Program_Level_Id__r.rank,PRM_Channel_Program_Level_Id__r.Name,PRM_Channel_Program_Level_Id__r.PRM_Partner_Tier_Name__c,PRM_Partner_Role__c,PRM_Status_Nm__c FROM Channel_Memberships1__r),
                                  
                                   // Account ONE PARTNER ID GROUP MEMEBRS       
                                   (SELECT Name,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Name,Core_Partner_Account_Id__c,Core_Partner_Account_Id__r.Name,Core_Inactive_Ind__c,Core_MDA_Ind__c FROM Partner_Account_Group_Members1__r WHERE Core_Inactive_Ind__c=false),
                                   //Partner Group Members                                   
                                   (SELECT Name,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Core_CIM_ID__c,Core_Intel_Account_Id__r.Core_Business_Party_Id__c,Core_Intel_Account_Id__r.Name,Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c ,Core_Partner_Account_Id__c,Core_Partner_Account_Id__r.Name,Core_Inactive_Ind__c,Core_MDA_Ind__c FROM Partner_Account_Group_Members__r),                                   
                               //Account Legal Agreements       
                                   (SELECT Name,PRM_Agreement_Sign_Dt__c,PRM_Signed_By_Name__c,PRM_Partner_Agreement_Id__r.Name,PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name FROM AccountLegalAgreementAssociations__r),
                                   (SELECT Name,Partner_Program__r.name,Effective_End_Date_Time__c,Inactive_Indicator__c FROM Account_Whitelisted_Domains__r),
                                   (SELECT PRM_Distributor_Id__r.Name,PRM_Choice_Nm__c,PRM_Consent_Provided_By_Id__r.Name,PRM_Consent_Provided_Date_Dt__c,PRM_Start_Date_Dt__c,PRM_End_Date_Dt__c,PRM_Consent_Provided_Ind__c FROM Partner_Assist_Consent__r)
                                   FROM Account WHERE Id IN :IPAAccountIds];
            
        }*/ // IPA Refresh - switch removal
        
        
        if(accts.size() > 0) {
            List<Core_Integration_Outbound_Message__c> outboundMsgs = new List<Core_Integration_Outbound_Message__c>();
            List<PRM_ISVC_Integration_Warranty__c> isvcWarrantyDataTable = new List<PRM_ISVC_Integration_Warranty__c>();
            for(Account acct: accts){
                String tags = '';
                Id onePartnerId;
                PRM_SalesCloud_Integration_Model.AccountPayload payload = new PRM_SalesCloud_Integration_Model.AccountPayload();
                try{
                    integer SLAhours,AWRQuantity,SWRQuantity;
                    payload.MessageType = ACCOUNT_MESSAGE_TYPE; // Adding account message type to the payload
                    payload.WarrantyBenefits = new PRM_SalesCloud_Integration_Model.WarrantyBenefit();
                    payload.WarrantyBenefits =  getWarrantyInformation(acct, warrantyQtyMap, PAGRecordTypeId, ProgramTierRankingMap);
                    //WarrantyBenefits.SLAHours =  getSLAHours(acct, warrantyQtyMapSLA, PAGRecordTypeId);\
                    //Remove this line - Chaithaly
                    SLAhours = (integer)payload.WarrantyBenefits.SLAHours;
                    AWRQuantity = (integer)payload.WarrantyBenefits.AWRQuantity;
                    SWRQuantity = (integer)payload.WarrantyBenefits.SWRQuantity;
                    payload.AccountId = acct.Id;
                    
                    payload.unifiedId=acct.Core_Business_Party_Id__c; //TWC729-6860 EOL activities
                    payload.LastModifiedDate = acct.LastModifiedDate;
                    //TWC729-7183 : Adding Deactivated checkbox and Deactivation Reason to Service cloud payload
                    payload.Deactivated = acct.Core_Deactivated__c;
                    payload.DeactivatedReason = acct.Core_Deactivation_Reason__c!=null?acct.Core_Deactivation_Reason__c:'';
                    payload.AccountInformation = getAccountInformation(acct, PAGRecordTypeId);
                    //--------------------------------------------------------------------------------
                     payload.AccountSpecialities = /*(!IPARefresh)?getAccountSpecialityAssociations(acct):*/ new List<PRM_SalesCloud_Integration_Model.AccountSpecialityAssociation>(); //IPA2.0 Changes,send AccountSpecialities as '' 
                    payload.AccountChannelMemberships = getAccountChannelMemberships(acct);
                    payload.AccoutBenefits = getAccoutBenefitAssociations(acct); //IPA2.0 Sending benefitInfo from OPID
                    //payload.OnePartnerIDGroupMembers = (acct.RecordTypeId == PAGRecordTypeId) ? getOnePartnerIDGroupMembers(acct.Partner_Account_Group_Members__r) : getOnePartnerIDGroupMembers(acct.Partner_Account_Group_Members1__r) ;
                    payload.OnePartnerIDGroupMembers = (acct.RecordTypeId == PAGRecordTypeId) ? getOnePartnerIDGroupMembers(acct.Partner_Account_Group_Members__r) : new List<PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember>() ;
                    payload.AccountLegalAgreements=getAccountLegalAgreements(acct);
                    //--------------------------------------------------------------------------------
                    onePartnerId = acct.Core_IPA_One_Partner_Id__c;
                    tags = acct.Id+';'+acct.Name;
                    outboundMsgs.add(createAndGetOBM(ACCOUNT_MESSAGE_TYPE, JSON.serialize(payload) , tags,acct.Id)); //Remove this line - Chaithaly
                    acct.PRM_IPA_Integration_Status__c = 'Successful';
                    accountsToBeUpdated.add(acct);

                    //Creating isvc integration warranty object to store SLA,SWR,AWR - TWC729-8312
                    isvcWarrantyDataTable.add(createISVCWarrantyData(acct.Id, onePartnerId, SLAhours, SWRQuantity, AWRQuantity));

                    if(Test.isRunningTest()){
                        throw new System.DMLException();
                    }
                }catch(exception ex){
                    listCoreLogEntry.add(PRM_SalesCloud_Integration.createLogEntry(ex.getMessage(),ex,acct.id,null,'Medium','Account'));
                }
            }
            if(outboundMsgs.size() > 0){
                sendOutboundMessage(outboundMsgs,accountsToBeUpdated);
            }

            //Inserting isvc integration warranty object to store SLA,SWR,AWR - TWC729-8312
            if((isvcWarrantyDataTable.size() > 0) && (!isvcWarrantyDataTable.isEmpty())){
                List<Database.SaveResult> listOfWarrantydata = Database.insert(isvcWarrantyDataTable,false);
                for(Database.SaveResult sr: listOfWarrantydata){
                    if (!sr.isSuccess()) {
                        String errorMsg = 'ISVC Integration Warranty Obj Creation - Id - '+sr.getId();
                        for (Database.Error err: sr.getErrors()) {
                            errorMsg = errorMsg +' **** '+ err.getStatusCode()+'- '+err.getMessage()+ 'Fields- '+err.getFields();
                        }
                        listCoreLogEntry.add(PRM_SalesCloud_Integration.createLogEntry(errorMsg,null,sr.getId(),null,'Medium','PRM_ISVC_Integration_Warranty__c'));
                    }
                }
            }


            if(!listCoreLogEntry.isEmpty()){
                database.insert(listCoreLogEntry,false);
            }
        }
    }
    public static void sendOutboundMessage( List<Core_Integration_Outbound_Message__c> outboundMsgs,List<Account> accountsToBeUpdated){
          List<Database.SaveResult> listOutbound = Database.insert(outboundMsgs, False);
           for (Database.SaveResult sr: listOutbound) {
            if (!sr.isSuccess()) {
                String errorMsg = 'Id - '+sr.getId();
                for (Database.Error err: sr.getErrors()) {
                    errorMsg = errorMsg +' **** '+ err.getStatusCode()+'- '+err.getMessage()+ 'Fields- '+err.getFields();
                }
                 Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_SCOPE, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, 'Low','DML ERROR'+system.now() ,errorMsg,'', '', '');
                      
            }
        }
        //update accountsToBeUpdated;
        List<Database.SaveResult> list_save=Database.Update(accountsToBeUpdated, FALSE);
        for (Database.SaveResult sr: list_save) {
            if (!sr.isSuccess()) {
                String errorMsg = 'Id - '+sr.getId();
                for (Database.Error err: sr.getErrors()) {
                    errorMsg = errorMsg +' **** '+ err.getStatusCode()+'- '+err.getMessage()+ 'Fields- '+err.getFields();
                }
                 Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_SCOPE, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, 'Low','DML ERROR'+system.now() ,errorMsg,  sr.getId(), '', '');
                      
            }
        }
    }
     public static Core_Log_Entry__c createLogEntry(String message, Exception ex, id acnt, String tags, String severity, String objectType){
        String strDetailsAndEx = '';
        if( ex != null ) {
            strDetailsAndEx += 'Message: ' + ex.getMessage() + '\n';
            strDetailsAndEx += 'Cause: ' + ex.getCause() + '\n';
            strDetailsAndEx += 'Line Number: ' + ex.getLineNumber() + '\n';
            strDetailsAndEx += 'Stack Trace: ' +ex.getStackTraceString() + '\n';
            strDetailsAndEx += 'Type Name: ' +ex.getTypeName() + '\n';
        }
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
            Core_Origin__c = LOG_ENTRY_SCOPE,
        Core_Scope__c = LOG_ENTRY_SCOPE,
        Core_Severity__c = 'Medium',
        Core_Message__c =  (message == null || message.length() <= 255 ? message : message.substring(0, 255)),
        Core_Details__c = strDetailsAndEx,
        Core_When__c = system.now(),
        Core_sObjectId__c = acnt,
        Core_sObjectType__c = objectType
            );
        return objCLE;
    }
    private static String getTierRoleKey(String key, Map<String,Integer> ProgramTierRankingMap, String benefitCode, Map<String,Integer> warrantyQtyMap)
    {
        List<String> TierRoleKey = key.split('~~');
        String Tierkey = TierRoleKey[1]; //Titanium
        Integer rank = 0;
        //ProgramTierRankingMap : Member-1, Gold-2 ,Titanium-3
        if(ProgramTierRankingMap.containsKey(Tierkey))
        {
            /*if(IPARefresh){*/
                rank = (Tierkey != 'Partner') ? ProgramTierRankingMap.get(Tierkey) - 1 : ProgramTierRankingMap.get(Tierkey); // 3-1=2
            /*}else{
            rank = (Tierkey != Label.Member_Tier) ? ProgramTierRankingMap.get(Tierkey) - 1 : ProgramTierRankingMap.get(Tierkey); // 3-1=2
            }*/ // IPA refresh - switch removal
            for(String tier : ProgramTierRankingMap.keySet())
            {
                if(ProgramTierRankingMap.get(tier) == rank)
                {
                    Tierkey = TierRoleKey[0]+'~~'+tier; // OEM~~Gold
                    if(tier == Label.Member_Tier || tier == 'Partner' )
                        return Tierkey;
                }
            }
        }
        
        return warrantyQtyMap.containsKey(benefitCode + '~~' + Tierkey) ? Tierkey : getTierRoleKey(Tierkey, ProgramTierRankingMap, benefitCode, warrantyQtyMap);
        
    }
    
    private static Map<String,Integer> getBenefitQuantity(String benefitCode,String key, Map<String,Integer> warrantyQtyMap,Map<String,Integer> warrantyBenefits,Map<String,Integer> ProgramTierRankingMap,Map<String,String> bnftOperator,Map<String,String> bnftCommonNameMap)
    {
       Integer QtyCount = warrantyBenefits.containsKey(bnftCommonNameMap.get(benefitCode)) ? warrantyBenefits.get(bnftCommonNameMap.get(benefitCode)) : 0;
        if(bnftOperator.containsKey(benefitCode))
        {
            if(bnftOperator.get(benefitCode)=='high')
            {
                
                if(warrantyQtyMap.containsKey(benefitCode+'~~'+key) && (QtyCount < warrantyQtyMap.get(benefitCode+'~~'+key) || QtyCount==0))
                {
                    QtyCount = warrantyQtyMap.get(benefitCode+'~~'+key);
                }
                else
                {
                    String Tierkey = getTierRoleKey(key, ProgramTierRankingMap,benefitCode,warrantyQtyMap);
                    QtyCount = (warrantyQtyMap.containsKey(benefitCode+'~~'+Tierkey) && (QtyCount < warrantyQtyMap.get(benefitCode+'~~'+key) || QtyCount==0)) ? warrantyQtyMap.get(benefitCode+'~~'+Tierkey) : QtyCount;
                }
            }
            else if(bnftOperator.get(benefitCode)=='low')
            {
                if(warrantyQtyMap.containsKey(benefitCode+'~~'+key) && (QtyCount > warrantyQtyMap.get(benefitCode+'~~'+key) || QtyCount==0))
                {
                    QtyCount = warrantyQtyMap.get(benefitCode.toUpperCase()+'~~'+key);//4
                }
                else
                {
                    String Tierkey = getTierRoleKey(key, ProgramTierRankingMap,benefitCode,warrantyQtyMap);
                    QtyCount = (warrantyQtyMap.containsKey(benefitCode+'~~'+Tierkey) && (QtyCount > warrantyQtyMap.get(benefitCode+'~~'+key) || QtyCount==0)) ? warrantyQtyMap.get(benefitCode+'~~'+Tierkey) : QtyCount;
                }
            }
            warrantyBenefits.put(bnftCommonNameMap.get(benefitCode),QtyCount);
        }
        return warrantyBenefits;
    }
    private static PRM_SalesCloud_Integration_Model.WarrantyBenefit getWarrantyInformation(Account acct, Map<String,Integer> warrantyQtyMap, Id PAGRecordTypeId, Map<String,Integer> ProgramTierRankingMap){
        
        PRM_SalesCloud_Integration_Model.WarrantyBenefit warrantyBenefit = new PRM_SalesCloud_Integration_Model.WarrantyBenefit();
        warrantyBenefit.SLAHours = 0;
        Map<String,Integer> warrantyBenefits = getWarrantyBenefits(acct,warrantyQtyMap,ProgramTierRankingMap);
       
        warrantyBenefit.AWRQuantity = warrantyBenefits.containsKey(Label.PRM_AdvancedWarranty_Code) ? warrantyBenefits.get(Label.PRM_AdvancedWarranty_Code) : 0;
        warrantyBenefit.SWRQuantity = warrantyBenefits.containsKey(Label.PRM_StandardWarranty_Code) ? warrantyBenefits.get(Label.PRM_StandardWarranty_Code) : 0;
        warrantyBenefit.SLAHours = warrantyBenefits.containsKey(Label.PRM_CustomerSupportBenefit_Code)? warrantyBenefits.get(Label.PRM_CustomerSupportBenefit_Code) : 0;        //-------------revisit later
      return warrantyBenefit;
    }
    public static Map<String,Integer> getWarrantyBenefits(Account acct, Map<String,Integer> warrantyQtyMap,Map<String,Integer> ProgramTierRankingMap){
        Map<String,Integer> warrantyBenefits = new Map<String,Integer>();
        set<String> partnerRoleTiers = new Set<String>();
        for(PRM_AccountChannelMembership__c acm : acct.Channel_Memberships1__r) {
            if(acm.PRM_Status_Nm__c != 'Inactive')
            {
                String tierCode = acm.PRM_Channel_Program_Level_Id__r.Name;
                if(!String.isEmpty(tierCode)){
                    partnerRoleTiers.add(acm.PRM_Partner_Role__c+'~~'+tierCode);
                }
            }
        }
        
        Map<String,String> bnftOperator = new Map<String,String>();
        Map<String,String>  bnftCommonNameMap = new Map<String,String>();
        
        //Chaithaly - Commenting below code as part of custom metadata conversion to new framework
        /*Map<Id,PRM_Warranty_Benefits_Configuration__mdt> warrantyBenefitsConfig = new Map<Id,PRM_Warranty_Benefits_Configuration__mdt>([Select Id,BenefitCode__c,BenefitCommonName__c,OperationCode__c from PRM_Warranty_Benefits_Configuration__mdt]);
        if(warrantyBenefitsConfig.size() > 0 ) {
            
            for(Id mdtId : warrantyBenefitsConfig.keySet() ){
                bnftOperator.put((String)warrantyBenefitsConfig.get(mdtId).get('BenefitCode__c'),(String)warrantyBenefitsConfig.get(mdtId).get('OperationCode__c'));
                bnftCommonNameMap.put((String)warrantyBenefitsConfig.get(mdtId).get('BenefitCode__c'),(String)warrantyBenefitsConfig.get(mdtId).get('BenefitCommonName__c'));
            }
        }*/
        
        Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('PRM_Warranty_Benefits_Configuration__mdt');
        Map<String, Map<String, Object>> benefitConigRecs = customMetadata.getAll();
        if(benefitConigRecs.size()>0){
            for(String metadataRec :benefitConigRecs.keySet()){
                bnftOperator.put((String)benefitConigRecs.get(metadataRec).get('BenefitCode__c'),(String)benefitConigRecs.get(metadataRec).get('OperationCode__c'));
                bnftCommonNameMap.put((String)benefitConigRecs.get(metadataRec).get('BenefitCode__c'),(String)benefitConigRecs.get(metadataRec).get('BenefitCommonName__c'));
            }
        }
        
        //Chaithaly - As part of IPA2.0 ,We fecth the benefits from Account's OPID only and not on location account.
        accBenefitList = /*(!IPARefresh) ? acct.AccountBenefitAssociations__r :*/ getAccountBenefits(acct);
        for(PRM_AccountBenefitAssociation__c acctBenefitAssoc : accBenefitList){
            if(acctBenefitAssoc.PRM_Status_Nm__c != 'Active'){ // Defect fix - only active benefit mapping value on OBM
                continue;
            }
            String benefitCode;
            if(acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c!=null){
                benefitCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c.toUpperCase();
            }
            for(String key:partnerRoleTiers)
            {
                warrantyBenefits = getBenefitQuantity(benefitCode,key,warrantyQtyMap,warrantyBenefits,ProgramTierRankingMap,bnftOperator,bnftCommonNameMap);
            }
        }
        return warrantyBenefits;
    }
    //Chaithaly IPA2.0 - Fetching all benefits from Account's OPID 
   // Method to get account benefits based on role and tier
    public static List<PRM_AccountBenefitAssociation__c> getAccountBenefits(Account acct) {
        List<PRM_AccountBenefitAssociation__c> accountBenefitList = new List<PRM_AccountBenefitAssociation__c>();
        
        if (acct.Partner_Account_Group_Members1__r.size() > 0) {
            Id opidAccountId = acct.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__c;
            List<String> applicablePartnerRoleTier = getApplicablePartnerRoleTier(acct);
            accountBenefitList = getBenefitsForAccount(opidAccountId, applicablePartnerRoleTier);
        } else if (acct.RecordTypeId == PAGRecordTypeId) {
            accountBenefitList = getBenefitsForAccount(acct.Id, null);
        }
         System.debug('final list'+accountBenefitList);
        return accountBenefitList;
    }

    // Get applicable partner role-tier combinations
    private static List<String> getApplicablePartnerRoleTier(Account acct) {
        List<String> applicablePartnerRoleTier = new List<String>();
        Integer highestTierRank = PRM_IPA_Utility.getHighestTierRank();
        for (PRM_AccountChannelMembership__c acm : acct.Channel_Memberships1__r) {
            if (acm.PRM_Status_Nm__c != 'Inactive') {
                String currentTier = acm.PRM_Channel_Program_Level_Id__r.Name;
                applicablePartnerRoleTier.add(acm.PRM_Partner_Role__c + '~~' + currentTier);
             // Add lower tier if current tier is Prestige
              Integer currentTierRank = acm.PRM_Channel_Program_Level_Id__r.rank;
            if (currentTierRank == highestTierRank) {
                    String lowerTier = rankTierMap.get(currentTierRank - 1);
                  //  String lowerTier = rankTierMap.get(ProgramTierRankingMap.get(currentTier) - 1);
                    applicablePartnerRoleTier.add(acm.PRM_Partner_Role__c + '~~' + lowerTier);
            }
        }
    }      
               
        return applicablePartnerRoleTier;
    }

    

    // Get benefits for a given account and applicable role-tier combinations
    private static List<PRM_AccountBenefitAssociation__c> getBenefitsForAccount(Id accountId, List<String> applicablePartnerRoleTier) {
          List<PRM_AccountBenefitAssociation__c> applicableBenefits = new List<PRM_AccountBenefitAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> benefitList = [SELECT PRM_Partner_Benefit_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c, 
                                                               PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, 
                                                               PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c, PRM_Status_Nm__c 
                                                               FROM PRM_AccountBenefitAssociation__c 
                                                               WHERE PRM_Account_Id__c = :accountId];
        if(applicablePartnerRoleTier != null){//for location accounts in case of multiple ACM at OPID
       for (PRM_AccountBenefitAssociation__c aba : benefitList) {
            for (String roleTier : applicablePartnerRoleTier) {
                   //benefitcode~~Distributer~~Partner
                if (warrantyQtyMap.containsKey(aba.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c + '~~' + roleTier)) {
                    applicableBenefits.add(aba);
                    break; // No need to check further combinations for this benefit code
                }
            }
        }
        }
        else if(applicablePartnerRoleTier == null){
            applicableBenefits = benefitList; // for OPID, no filter on benefits
        }
       return applicableBenefits;
    }

    private static PRM_SalesCloud_Integration_Model.AccountInformation getAccountInformation(Account acct, Id PAGRecordTypeId){
        PRM_SalesCloud_Integration_Model.AccountInformation acctInfo = new PRM_SalesCloud_Integration_Model.AccountInformation();
        acctInfo.Name = acct.Name;
        acctInfo.AccountNo = acct.AccountNumber;
        
        acctInfo.SalesGroup = acct.Core_Sales_Groups__c;
        acctInfo.Industry = acct.Industry;
        acctInfo.CoveredAccount = acct.Core_Covered_Account__c;
        acctInfo.CNDANumber = acct.Core_CNDA_Number__c;
        acctInfo.BusinessPartnerId = acct.Core_Business_Partner_Id__c;
       
        acctInfo.BizOrgType = acct.Core_Account_Type__c;
        acctInfo.PartnerRole = acct.Core_IPA_Partner_Role__c;
        acctInfo.Region = acct.Core_Geo__c;
        acctInfo.SubRegion = acct.Core_Sub_Geo__c;
        acctInfo.UserDefinedPhoneNumber = acct.Core_User_Defined_Phone_Number__c;
        acctInfo.UserDefinedWebsite = acct.Core_User_Defined_Website__c;
        acctInfo.EnglishNameOnly = acct.Core_English_Only_Name__c;
        acctInfo.PartnerProgramSegment = /*(!IPARefresh)?acct.Core_IPA_Partner_Segment__c:*/'';//IPA2.0 Changes
        acctInfo.PartnerProgramSpecialty = '';
       
        acctInfo.AccountBUFocus = acct.Core_Account_BU_Focus__c;
        acctInfo.RecordType = acct.RecordType.Name;
        acctInfo.IsIPA = acct.Core_Intel_Partner_Alliance_PartnerGroup__c;
        acctInfo.AccountOwner = new PRM_SalesCloud_Integration_Model.RecordOwner(acct.Owner.Email, acct.Owner.FirstName, acct.Owner.LastName);
        acctInfo.BadgeTier = acct.Core_IPA_Badge_Tier__c;
        List<Schema.PicklistEntry> pickListValues = Account.Core_IPA_Badge_Tier__c.getDescribe().getPicklistValues();
        String tierLabel;
        for (Schema.PicklistEntry picklistval : pickListValues) {
            if (acct.Core_IPA_Badge_Tier__c == picklistval.getValue()) {
                tierLabel= picklistval.getLabel();
            }
        }
        /*if(IPARefresh){*/ acctInfo.BadgeTierLabel = tierLabel;//} // IPA2.0 - New attribute in payload
        if(acct.RecordTypeId != PAGRecordTypeId && acct.Partner_Account_Group_Members1__r.size() > 0 ) {
            //acctInfo.OnePartnerIdAccountName = acct.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__r.Name;
            acctInfo.PAGAccountId = acct.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__c;
        }
        acctInfo.address = new PRM_SalesCloud_Integration_Model.AccountAddress();
        acctInfo.address.PrimaryAddress = getAccountPrimaryAddress(acct);
        acctInfo.address.SecondaryAddress = getAccountSecondaryAddress(acct);
        acctInfo.WhitelistedDomains = getWhiteListedDomains(acct);
        acctInfo.PartnerAssist = getPartnerAssist(acct);
        acctInfo.PartnerRoleLabel ='';
        List<String> PRLabelList = new List<String>();
        if(!String.isEmpty(acct.Core_IPA_Partner_Role__c)){
            List<String> partnerRoles = acct.Core_IPA_Partner_Role__c.split(';');
            List<Schema.PicklistEntry> roleValues = Account.Core_IPA_Partner_Role__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry picklistval : roleValues) {
                if (partnerRoles.Contains(picklistval.getValue())) {
                    PRLabelList.add(picklistval.getLabel());
                }
            }
        }
        acctInfo.PartnerRoleLabel = String.join(PRLabelList, ';');
        
        
        return acctInfo;
    }
    
    // Partner Assist and WhiteListed domain Method
    private static List<PRM_SalesCloud_Integration_Model.PartnerAssist> getPartnerAssist(Account acct){
        List<PRM_SalesCloud_Integration_Model.PartnerAssist> PartnerAssist = new List<PRM_SalesCloud_Integration_Model.PartnerAssist>();
        for(PRM_Partner_Assist_Consent__c partnerConsent : acct.Partner_Assist_Consent__r) {
            PRM_SalesCloud_Integration_Model.PartnerAssist pa = new PRM_SalesCloud_Integration_Model.PartnerAssist();
            pa.DistributorName = partnerConsent.PRM_Distributor_Id__r.Name;
            pa.choice = partnerConsent.PRM_Choice_Nm__c;
            pa.ConsentProvidedBy = partnerConsent.PRM_Consent_Provided_By_Id__r.Name;
            pa.ConsentProvidedDate = partnerConsent.PRM_Consent_Provided_Date_Dt__c;
            pa.StartDate = partnerConsent.PRM_Start_Date_Dt__c;
            pa.EndDate = partnerConsent.PRM_End_Date_Dt__c;
            pa.ConsentProvidedIndicator = partnerConsent.PRM_Consent_Provided_Ind__c;
            PartnerAssist.add(pa);
        }
        return PartnerAssist;
    }
    private static List<PRM_SalesCloud_Integration_Model.WhiteListedDomain> getWhiteListedDomains(Account acct){
        List<PRM_SalesCloud_Integration_Model.WhiteListedDomain> WhiteListedDomains = new List<PRM_SalesCloud_Integration_Model.WhiteListedDomain>();
        for(Core_Account_Whitelisted_Domains__c whiteListedDomain : acct.Account_Whitelisted_Domains__r) {
            PRM_SalesCloud_Integration_Model.WhiteListedDomain wDomain = new PRM_SalesCloud_Integration_Model.WhiteListedDomain();
            wDomain.DomainName = whiteListedDomain.Name;
            wDomain.PartnerProgramName = whiteListedDomain.Partner_Program__r.name;
            wDomain.EndDate = whiteListedDomain.Effective_End_Date_Time__c;
            wDomain.IsInactive = whiteListedDomain.Inactive_Indicator__c;
            WhiteListedDomains.add(wDomain);
        }
        return WhiteListedDomains;
    }
    
    // End Partner and WhiteListed Domain
    private Static PRM_SalesCloud_Integration_Model.Address getAccountPrimaryAddress(Account acct){
        PRM_SalesCloud_Integration_Model.Address primaryAddress = new PRM_SalesCloud_Integration_Model.Address();
        boolean isAddressEmpty = false;
        isAddressEmpty = (String.isEmpty(acct.BillingStreet) && String.isEmpty(acct.Billingcity)
            && String.isEmpty(acct.BillingState) && String.isEmpty(acct.BillingCountry)
            && String.isEmpty(acct.BillingPostalCode) ) ? true: false;
        if(!isAddressEmpty){
            primaryAddress.Street = acct.BillingStreet;
            primaryAddress.City = acct.Billingcity;
            primaryAddress.State = acct.BillingState;
            primaryAddress.StateCode = acct.BillingStateCode;
            primaryAddress.Country = acct.BillingCountry;
            primaryAddress.CountryCode = acct.BillingCountryCode;
            primaryAddress.PostalCode = acct.BillingPostalCode;
            return primaryAddress;
        }else{
            return null;
        }
    }
    
    private Static PRM_SalesCloud_Integration_Model.Address getAccountSecondaryAddress(Account acct){
        boolean isAddressEmpty = false;
        PRM_SalesCloud_Integration_Model.Address secondaryAddress = new PRM_SalesCloud_Integration_Model.Address();
        isAddressEmpty = (String.isEmpty(acct.ShippingStreet) && String.isEmpty(acct.Shippingcity) && String.isEmpty(acct.ShippingState) && String.isEmpty(acct.ShippingCountry) && String.isEmpty(acct.ShippingPostalCode) ) ? true: false;
        if(!isAddressEmpty){
            secondaryAddress.Street = acct.ShippingStreet;
            secondaryAddress.City = acct.Shippingcity;
            secondaryAddress.State = acct.ShippingState;
            secondaryAddress.StateCode = acct.ShippingStateCode;
            secondaryAddress.Country = acct.ShippingCountry;
            secondaryAddress.CountryCode = acct.ShippingCountryCode;
            secondaryAddress.PostalCode = acct.ShippingPostalCode;
            return secondaryAddress;
        }else{
            return null;
        }
    }
    
    //IPA2.0 Destructive - this method can be removed
    public static List<PRM_SalesCloud_Integration_Model.AccountSpecialityAssociation> getAccountSpecialityAssociations(Account acct){
        List<PRM_SalesCloud_Integration_Model.AccountSpecialityAssociation> asas = new List<PRM_SalesCloud_Integration_Model.AccountSpecialityAssociation>();
        for(PRM_Account_Specialty_Association__c acctSpecialityAssoc : acct.Account_Specialty_Associations__r){
            PRM_SalesCloud_Integration_Model.AccountSpecialityAssociation asa = new PRM_SalesCloud_Integration_Model.AccountSpecialityAssociation();
            asa.Name = acctSpecialityAssoc.Name;
            //asa.SalescloudId = acctSpecialityAssoc.Id;
            asa.IsInactive = acctSpecialityAssoc.PRM_InActive_Ind__c;
            //asa.SpecialityId = acctSpecialityAssoc.PRM_Specialty_Id__c;
            asa.SpecialityName = acctSpecialityAssoc.PRM_Specialty_Id__r.Name;
            asa.SpecialityType = acctSpecialityAssoc.PRM_Specialty_Type__c;
            asa.SpecialityRole = (String.isEmpty(acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Role_Nm__c))?null: ((String) acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Role_Nm__c).replace('<br>', ',');
            asa.SpecialityTier = (String.isEmpty(acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Tier_Nm__c))?null: ((String) acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Tier_Nm__c).replace('<br>', ',');
            asa.StartDateUtc = acctSpecialityAssoc.PRM_Start_Date_Dt__c;
            asas.add(asa);
        }
        return asas;
    }
    
    private static List<PRM_SalesCloud_Integration_Model.AccountChannelMembership> getAccountChannelMemberships(Account acct){
        List<PRM_SalesCloud_Integration_Model.AccountChannelMembership> acms = new List<PRM_SalesCloud_Integration_Model.AccountChannelMembership>();
        for(PRM_AccountChannelMembership__c channelMembership: acct.Channel_Memberships1__r ){
            PRM_SalesCloud_Integration_Model.AccountChannelMembership acm = new PRM_SalesCloud_Integration_Model.AccountChannelMembership();
            acm.PartnerProgramName = channelMembership.PRM_Channel_Program_Id__r.Name;
            acm.PartnerProgramCode = channelMembership.PRM_Channel_Program_Id__r.PRM_programCode__c;
            acm.PartnerTier = channelMembership.PRM_Channel_Program_Level_Id__r.Name;
            /*if( IPARefresh ){*/ acm.PartnerTierLabel = channelMembership.PRM_Channel_Program_Level_Id__r.PRM_Partner_Tier_Name__c!=null?channelMembership.PRM_Channel_Program_Level_Id__r.PRM_Partner_Tier_Name__c:'';//} // IPA2.0 New attribute
            acm.PartnerRole = (String.isEmpty(channelMembership.PRM_Partner_Role__c))?null:((String) channelMembership.PRM_Partner_Role__c).replace('<br>',','  );
            acm.Status = channelMembership.PRM_Status_Nm__c;
            //acm.AccountChannelMembershipId = channelMembership.Id;
            //acm.AccountId = acct.Id;
            acm.StatusChangeDateUtc = channelMembership.PRM_Status_Change_Dt__c;
            acm.PartnerRoleLabel ='';
            if(!String.isEmpty(channelMembership.PRM_Partner_Role__c)){
                List<Schema.PicklistEntry> pickListValues = PRM_AccountChannelMembership__c.PRM_Partner_Role__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry picklistval : pickListValues) {
                    if (picklistval.getValue() == channelMembership.PRM_Partner_Role__c) {
                        acm.PartnerRoleLabel = picklistval.getLabel();
                        break;
                    }
                }
            }
            
            acms.add(acm);
        }
        return acms;
    }
      
    private static List<PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember> getOnePartnerIDGroupMembers(List<Core_Account_Group_Member__c> onePartnerGMs){
        List<PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember> opidms = new List<PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember>();
        for(Core_Account_Group_Member__c onePartnerGM: onePartnerGMs){
            PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember opidm = new PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember();
            opidm.AccountId = onePartnerGM.Core_Intel_Account_Id__c;
            opidm.isInactive = onePartnerGM.Core_Inactive_Ind__c;
            
            opidm.unifiedId=onePartnerGM.Core_Intel_Account_Id__r.Core_Business_Party_Id__c; //TWC729-6860 EOL activities
            opidm.IsIPA = onePartnerGM.Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c;
            opidms.add(opidm);
        }
        return opidms;
    }
    
    private static List<PRM_SalesCloud_Integration_Model.AccoutBenefitAssociation> getAccoutBenefitAssociations(Account acct){
        
        List<PRM_SalesCloud_Integration_Model.AccoutBenefitAssociation> abas = new List<PRM_SalesCloud_Integration_Model.AccoutBenefitAssociation>();
      //  List<PRM_AccountBenefitAssociation__c> accBenefitList = new  List<PRM_AccountBenefitAssociation__c>();
        //Chaithaly IPA2.0 - We fecth the benefits from Account's OPID only and not on location account.
        accBenefitList = /*(!IPARefresh  ) ? acct.AccountBenefitAssociations__r :*/ accBenefitList;
        
        for(PRM_AccountBenefitAssociation__c acctBenefitAssoc : accBenefitList){
            PRM_SalesCloud_Integration_Model.AccoutBenefitAssociation aba = new PRM_SalesCloud_Integration_Model.AccoutBenefitAssociation();
            aba.BenefitName = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.Name;
            aba.BenefitCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c;
            aba.BenefitType = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c;
            aba.PartnerProgamName = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name;
            aba.PartnerProgamCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c;
            aba.Status = acctBenefitAssoc.PRM_Status_Nm__c;
            abas.add(aba);
        }
        return abas;
    }
    private static List<PRM_SalesCloud_Integration_Model.AccountLegalAgreement> getAccountLegalAgreements(Account acct){
        //(SELECT Name,PRM_Agreement_Sign_Dt__c,PRM_Contact__r.Name,PRM_Partner_Agreement_Id__r.Name,PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name FROM AccountLegalAgreementAssociations__r)
        List<PRM_SalesCloud_Integration_Model.AccountLegalAgreement> legalAgreements = new List<PRM_SalesCloud_Integration_Model.AccountLegalAgreement>();
        for(PRM_AccountLegalAgreemntAssociation__c agreement : acct.AccountLegalAgreementAssociations__r){
            PRM_SalesCloud_Integration_Model.AccountLegalAgreement legalAgreement = new PRM_SalesCloud_Integration_Model.AccountLegalAgreement();
            legalAgreement.LeagalAgreementName = agreement.Name;
            legalAgreement.AgreementSignedDate = agreement.PRM_Agreement_Sign_Dt__c;
            // IPA 2.0 - TWC729-7874 -start
            legalAgreement.AgreementSignedBy = agreement.PRM_Signed_By_Name__c;
            //IPA 2.0 - TWC729-7874 -end
            legalAgreement.IsInActive = agreement.PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c;
            legalAgreement.PartnerAgreementName = agreement.PRM_Partner_Agreement_Id__r.Name;
            legalAgreement.PartnerAgreementCode = agreement.PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c;
            legalAgreement.PartnerProgramName = agreement.PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name;
            legalAgreements.add(legalAgreement);
        }
        return legalAgreements;
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------
    public static void GenerateContactOBM(Set<Id> contactIds){
        
        List<Contact> conts = new List<Contact>();
        
        conts = [SELECT id,Salutation,Name,FirstName,LastName,AccountId,Account.Name,Account.AccountNumber, Account.Core_CIM_ID__c, Account.Core_Business_Party_Id__c, Title,Core_IPA_Contact_Segment__c,Core_Preferred_Language__c,Core_Preferred_Communication__c,Phone,Fax,MobilePhone,Email,
                               Core_IPA_PartnerRole__c,Core_IPS_Region__c,Core_IPS_Sub_Region__c,Core_Local_First_Name__c,Core_Local_Last_Name__c,Core_Do_Not_Contact__c,
                               Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c,Core_Job_Function__c,Core_Job_Function_Code__c,Core_Profession__c,Core_eRPM_Person_Id__c,Core_Enterprise_Id__c,                         
                               MailingStreet,MailingCity,MailingState,MailingStateCode,MailingCountry,MailingCountryCode,MailingPostalCode,LastModifiedDate,  
                               PRM_Wechat_Union_Id__c,Core_IPA_Partner_Community__c,External_User_State__c,External_User_State_Change_Date_Times__c,Core_IPA_Intel_Last_Login_Date__c,//PRM_Registration_Source_txt__c,PRM_Wechat_Open_Id__c,PRM_Wechat_Union_Id__c, PRM_Registration_Source_txt__c,
                               // Account Contact Relationships
                               (SELECT Id,PRM_Status_Nm__c,PRM_Contact_Id__c,PRM_Relationship_Id__c,PRM_Relationship_Id__r.Name,PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_InActive_Ind__c FROM Account_Contact_Relationships__r),
                               // Contact Subscriptions
                               (SELECT PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Status_Nm__c FROM Contact_Subscription_Associations__r),
                               //Contact Entitlements
                               (SELECT Core_Entitlement_Id__r.Name,Core_Type__c,Core_Status__c,Core_Selected__c,Core_Status_Change_Date_Time__c FROM Contact_Entitlements__r)
                               FROM Contact WHERE id IN :contactIds];
        
        if(conts.size() > 0){
            GenerateContactOutboundMessage(conts);
        }
    }
    public static void GenerateContactOutboundMessage(List<Contact> conts){
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Account> accountsMap = new Map<Id,Account>();
        List<Contact> contactsToBeUpdated=new List<Contact>();
        Map<String,String> pRoleLabelValueMap = new Map<String,String>();
        List<Schema.PicklistEntry> pickListValues = Contact.Core_IPA_PartnerRole__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry v : pickListValues) {
            pRoleLabelValueMap.put(v.getValue(), v.getLabel());
        }
        List<Core_Integration_Outbound_Message__c> outboundMsgs = new List<Core_Integration_Outbound_Message__c>();
        for(Contact con: conts){
            accountIdSet.add(con.AccountId);
        }
        //To fetch Account with Account Id in Contact
        if(!accountIdSet.isEmpty()){
            accountsMap = new Map<Id, Account>([SELECT name,Core_Sales_Groups__c,Industry,Core_Account_Type__c,Core_IPA_Partner_Role__c,                               
                                                    BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,BillingCountryCode,BillingPostalCode FROM Account WHERE Id IN :accountIdSet]);
        }
        
        for(Contact cont: conts){
            String tags = '';
            PRM_SalesCloud_Integration_Model.ContactPayload payload = new PRM_SalesCloud_Integration_Model.ContactPayload();
            payload.AccountId = cont.AccountId;
            payload.MessageType = CONTACT_MESSAGE_TYPE; // Adding contact message type to the payload
            payload.ContactId = cont.Id;
            
            payload.unifiedId=cont.Account.Core_Business_Party_Id__c; //TWC729-6860 EOL activities
            payload.AccountNum = cont.Account.AccountNumber;
            //payload.ContactBasicProfile = new PRM_SalesCloud_Integration_Model.ContactBasicProfile();
            payload.ContactBasicInformation = getContactBasicDetails(cont,pRoleLabelValueMap);
            payload.ContactEntitlements = getContactEntitlements(cont);
            payload.ContactSubscriptions = getContactSubscriptions(cont);
            payload.AccountContactRelationships = getAccountContactRelationships(cont);
            payload.LastModifiedDate = cont.LastModifiedDate;
            //Updated for US612331 (As an IPA admin I would like Contact to Contact integration to be established for all related contact attributes that are synced from Sales cloud to service cloud.)
            tags = cont.Id+';'+cont.Email+';'+cont.Name;
            outboundMsgs.add(createAndGetOBM(CONTACT_MESSAGE_TYPE, JSON.serialize(payload) , tags,null));
            cont.PRM_IPA_Integration_Status__c = 'Successful';
            contactsToBeUpdated.add(cont);
        }
        if(outboundMsgs.size() > 0){
          //  Database.insert(outboundMsgs, False);
            List<Database.SaveResult> listOutbound = Database.insert(outboundMsgs, False);
           for (Database.SaveResult sr: listOutbound) {
            if (!sr.isSuccess()) {
                String errorMsg = 'Id - '+sr.getId();
                for (Database.Error err: sr.getErrors()) {
                    errorMsg = errorMsg +' **** '+ err.getStatusCode()+'- '+err.getMessage()+ 'Fields- '+err.getFields();
                }
                 Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_SCOPE, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, 'Low','DML ERROR'+system.now() ,errorMsg,'', '', '');
                      
            }
        }
            //update contactsToBeUpdated;
            List<Database.SaveResult> list_save=Database.Update(contactsToBeUpdated, FALSE);
            for (Database.SaveResult sr: list_save) {
                if (!sr.isSuccess()) {
                    String errorMsg = 'Id - '+sr.getId();
                    for (Database.Error err: sr.getErrors()) {
                        errorMsg = errorMsg +' **** '+ err.getStatusCode()+'- '+err.getMessage()+ 'Fields- '+err.getFields();
                    }
                }
            }
        }
    }
    private static PRM_SalesCloud_Integration_Model.ContactBasicInformation getContactBasicDetails(Contact cont, Map<String,String> pRoleLabelValueMap){
        //ContactBasicProfileWrapper ContactProfile
        PRM_SalesCloud_Integration_Model.ContactBasicInformation ContactDetails = new PRM_SalesCloud_Integration_Model.ContactBasicInformation();
        ContactDetails.AccountName = cont.Account.Name;
        //ContactDetails.Title = cont.Title;
        //updated as part of
        ContactDetails.Title = cont.Salutation;
        ContactDetails.FullName = cont.Name;
        ContactDetails.FirstName = cont.FirstName;
        ContactDetails.LastName = cont.LastName;
        ContactDetails.LocalFirstName = cont.Core_Local_First_Name__c;
        ContactDetails.LocalLastName = cont.Core_Local_Last_Name__c;
        ContactDetails.EnglishFirstName = cont.Core_English_Only_First_Name__c;
        ContactDetails.EnglishLastName = cont.Core_English_Only_Last_Name__c;
        ContactDetails.JobFunction = cont.Core_Job_Function__c;
        ContactDetails.JobFunctionCode = cont.Core_Job_Function_Code__c;
        ContactDetails.Phone = cont.phone;
        ContactDetails.Fax = cont.Fax;
        ContactDetails.Mobile = cont.MobilePhone;
        ContactDetails.Email = cont.email;
        ContactDetails.PreferredCommunication = cont.Core_Preferred_Communication__c;
        ContactDetails.PreferredLanguage = cont.Core_Preferred_Language__c;
        ContactDetails.PartnerRole = cont.Core_IPA_PartnerRole__c;
        ContactDetails.PartnerRoleLabel = String.isEmpty(cont.Core_IPA_PartnerRole__c)?null:(pRoleLabelValueMap.containsKey(cont.Core_IPA_PartnerRole__c)?pRoleLabelValueMap.get(cont.Core_IPA_PartnerRole__c):cont.Core_IPA_PartnerRole__c);
        ContactDetails.Segment = /*(!IPARefresh )?cont.Core_IPA_Contact_Segment__c:*/'';//IPA2.0 Changes - attibute to be null
        ContactDetails.eRPMPersonId = cont.Core_eRPM_Person_Id__c;
        ContactDetails.EnterpriseId = cont.Core_Enterprise_Id__c;
        ContactDetails.Region = cont.Core_IPS_Region__c;
        ContactDetails.SubRegion = cont.Core_IPS_Sub_Region__c;
        ContactDetails.DNC = cont.Core_Do_Not_Contact__c;
        ContactDetails.Communities = /*(!IPARefresh)? cont.Core_IPA_Partner_Community__c:*/''; //IPA2.0 Changes - attibute to be null
        ContactDetails.MailingAddress = getContactMailingAddress(cont);
        //ContactDetails.WeChatUnionId = String.IsEmpty(cont.PRM_Wechat_Union_Id__c) ? null :EncryptDecryptHelper.EncryptData(cont.PRM_Wechat_Union_Id__c);
        ContactDetails.WeChatUnionId = cont.PRM_Wechat_Union_Id__c;
        ContactDetails.ExternalUserState = cont.External_User_State__c;
        ContactDetails.ExternalUserStateChangeDtTime = cont.External_User_State_Change_Date_Times__c;
        ContactDetails.IntelLastLoginDate = cont.Core_IPA_Intel_Last_Login_Date__c;
        return ContactDetails;
    }
    private static PRM_SalesCloud_Integration_Model.Address getContactMailingAddress(Contact cont){
        PRM_SalesCloud_Integration_Model.Address mailingAddr = new PRM_SalesCloud_Integration_Model.Address();
        boolean isAddressEmpty = (String.isEmpty(cont.MailingStreet) && String.isEmpty(cont.MailingCity)
            && String.isEmpty(cont.MailingState) && String.isEmpty(cont.MailingCountry)
            && String.isEmpty(cont.MailingPostalCode) ) ? true: false;
        if(!isAddressEmpty){
            mailingAddr.Street = cont.MailingStreet;
            mailingAddr.City = cont.MailingCity;
            mailingAddr.State = cont.MailingState;
            mailingAddr.StateCode = cont.MailingStateCode;
            mailingAddr.Country = cont.MailingCountry;
            mailingAddr.CountryCode = cont.MailingCountryCode;
            mailingAddr.PostalCode = cont.MailingPostalCode;
            return mailingAddr;
        }else{
            return null;
        }
        
    }
    private static List<PRM_SalesCloud_Integration_Model.AccountContactRelationship> getAccountContactRelationships(Contact cont){
        List<PRM_SalesCloud_Integration_Model.AccountContactRelationship> acrs = new List<PRM_SalesCloud_Integration_Model.AccountContactRelationship>();
        for(PRM_Account_Contact_Relationship__c acr: cont.Account_Contact_Relationships__r){
            PRM_SalesCloud_Integration_Model.AccountContactRelationship accContRel = new PRM_SalesCloud_Integration_Model.AccountContactRelationship();
            //accContRel.AccountName=acr.PRM_Account_Id__r.Name;
            accContRel.Relationship=acr.PRM_Relationship_Id__r.Name;
            accContRel.InactiveIndicator=acr.PRM_InActive_Ind__c;
            accContRel.Status = acr.PRM_Status_Nm__c;
            //accContRel.PartnerRole= String.isEmpty(acr.PRM_Partner_Role__c)?null: ((String) acr.PRM_Partner_Role__c).replace('<br>',';');
            String PartnerRoles= String.isEmpty(acr.PRM_Partner_Role__c)?null: ((String) acr.PRM_Partner_Role__c).replace('<br>',';');
            if(PartnerRoles!=null && (PartnerRoles.length()-PartnerRoles.lastIndexOf(';'))==1){
                PartnerRoles = PartnerRoles.left(PartnerRoles.lastIndexOf(';'));
            }
            accContRel.PartnerRole = PartnerRoles;
            accContRel.PartnerRoleLabel = '';
            //accContRel.ContactInfo = new PRM_SalesCloud_Integration_Model.ACRContact(cont.Email, cont.FirstName, cont.LastName, cont.Core_Login_Id__c, cont.Core_eRPM_Person_Id__c);
            if(!String.isEmpty(acr.PRM_Partner_Role__c)){
                List<Schema.PicklistEntry> pickListValues = Contact.Core_IPA_PartnerRole__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry picklistval : pickListValues) {
                    if (picklistval.getValue() == acr.PRM_Partner_Role__c) {
                        accContRel.PartnerRoleLabel = picklistval.getLabel();
                        break;
                    }
                }
            }
            acrs.add(accContRel);
        }
        return acrs;
    }
    private static List<PRM_SalesCloud_Integration_Model.ContactEntitlement> getContactEntitlements(Contact cont){
        
        List<PRM_SalesCloud_Integration_Model.ContactEntitlement> ContactEntitlements = new List<PRM_SalesCloud_Integration_Model.ContactEntitlement>();
        for(Core_Contact_Entitlement__c ce: cont.Contact_Entitlements__r){
            PRM_SalesCloud_Integration_Model.ContactEntitlement ContEntitlement = new PRM_SalesCloud_Integration_Model.ContactEntitlement();
            ContEntitlement.Name = ce.Core_Entitlement_Id__r.Name;
            ContEntitlement.Type = ce.Core_Type__c;
            ContEntitlement.Status = ce.Core_Status__c;
            ContEntitlement.IsSelected = ce.Core_Selected__c;
            ContEntitlement.StatusChangeDateUtc = ce.Core_Status_Change_Date_Time__c;
            ContactEntitlements.add(ContEntitlement);
        }
        return ContactEntitlements;
    }
    private static List<PRM_SalesCloud_Integration_Model.ContactSubscription> getContactSubscriptions(Contact cont){
        
        List<PRM_SalesCloud_Integration_Model.ContactSubscription> subscriptions = new List<PRM_SalesCloud_Integration_Model.ContactSubscription>();
        for(PRM_ContactSubscriptionAssociation__c pcsa: cont.Contact_Subscription_Associations__r){
            PRM_SalesCloud_Integration_Model.ContactSubscription cs = new PRM_SalesCloud_Integration_Model.ContactSubscription();
            cs.Name = pcsa.PRM_Partner_Subscription_Id__r.Name;
            cs.Status = pcsa.PRM_Status_Nm__c;
            cs.Code = pcsa.PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c;
            subscriptions.add(cs);
        }
        return subscriptions;
    }
    private static Core_Integration_Outbound_Message__c createAndGetOBM (String MessageType, String payload, String tags,String accId){
        Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();
        outboundMsg.Core_MessageType__c = MessageType;
        outboundMsg.Core_Payload__c ='<![CDATA[' +  payload + ']]>';
        outboundMsg.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);
        outboundMsg.PRM_Account_ID__c = accId;

        return outboundMsg;
    }

    //Method for creating isvc integration warranty object to store SLA,SWR,AWR - TWC729-8312
    private static PRM_ISVC_Integration_Warranty__c createISVCWarrantyData (String accId, String opID, integer SLA, integer SWR, Integer AWR){
        PRM_ISVC_Integration_Warranty__c isvcwarranty = new PRM_ISVC_Integration_Warranty__c();
        isvcwarranty.PRM_OPIDAWR__c = AWR;
        isvcwarranty.PRM_OPIDSWR__c = SWR;
        isvcwarranty.PRM_OPIDSLA__c = SLA;
        isvcwarranty.PRM_One_Partner_ID__c = opID;
        isvcwarranty.PRM_Account_ID__c = accId;

        return isvcwarranty;
    }
   
    
}