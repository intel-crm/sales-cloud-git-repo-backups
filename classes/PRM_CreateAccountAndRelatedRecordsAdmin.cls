public without sharing class PRM_CreateAccountAndRelatedRecordsAdmin {
    public static string logEntries;
    public static string logEntryMsg;
    public static Boolean IS_Admin_Invite = false;
	public static final String ORIGIN = 'PRM_SubmitAdminRegistration';
    /*to create log entry*/
    public static final String SEVERITY = 'Info';
    /*to create log entry*/
    public static final String PROJECT = 'IPA Registrations';  
    /*to create log entry*/
    public static final string SCOPE = 'PRM_SubmitAdminRegistration';
  	public static List<Core_Log_Entry__c> listOfLogEntries = new List<Core_Log_Entry__c>();
    public static database.saveResult[] srList;
	public static List<Database.UpsertResult> result;
    //public static boolean iparefresh = boolean.valueOf(Label.PRM_IPARefresh);
    
    /**
     *  @description      : Create New Account, Contact and their related Records.
     *  @name             : createAccountAndRelatedRecords
     *  @param            : map<String,String>
     *  @throws exception : NONE
     **/
    @AuraEnabled
    public static Map<String,String> createAccountAndRelatedRecordsAdmin(Map<String,String> registrationDetailsMap, string logEntryMsg)
    {
		
         logEntryMsg+= 'Entered into createAccountAndRelatedRecordsAdmin method:with registration details?'+registrationDetailsMap;
        System.debug('registrationDetailsMap -->'+JSON.serialize(registrationDetailsMap));
        Map<String,String> recordIdsMap = new Map<String, String>();
        /*Sample input Map passed from client side...  for Reference
        {"AccountName":"s","BizOrgType":"EBM- Embedded Board Manufacturer","PartnerRole":"Not Applicable","AddressLine1":"Flat No 403, Pritam woods , Green Glen Layout","Country":"ALA","CountryLabel":"Aland Islands","State":"","StateLabel":"","City":"Be","PostalCode":"560103","ContactFirstName":"s","ContactLastName":"s","ContactEmail":"s","PreferredLanguage":"THA",
            "DuplicateInfo":"[{\"Id\":\"0016C00000BIhWeQAL\",\"Name\":\"BIG Networks\",\"BillingStreet\":\"2178  Roosevelt Street\",\"BillingCity\":\"San Francisco\",\"BillingState\":\"CA\",\"BillingPostalCode\":\"94105\",\"BillingCountry\":\"USA\",\"Core_Intel_Partner_Alliance_PartnerGroup__c\":false,\"Core_Account_Type__c\":\"EMS- Electronic Manufacturing Services;End user: Education\",\"Core_IPA_Partner_Role__c\":\"Distributor;FPGA Designer\",\"Industry\":\"Needs Defined\",\"AccountName\":\"/lightning/r/Account/0016C00000BIhWeQAL/view\",\"BillingAddress\":\"2178  Roosevelt Street,San Francisco,CA,94105,USA\",\"DuplicateStatus\":\"PartDup\"},{\"Id\":\"0016C00000CldIiQAJ\",\"Name\":\"Sapient\",\"BillingStreet\":\"4492  Golden Ridge Road Church City\",\"BillingCity\":\"Las Vegas\",\"BillingState\":\"NY\",\"BillingPostalCode\":\"07292\",\"BillingCountry\":\"USA\",\"Core_Intel_Partner_Alliance_PartnerGroup__c\":true,\"Core_Account_Type__c\":\"Cloud Service Provider (CSP)\",\"Core_IPA_Partner_Role__c\":\"Service Provider\",\"Industry\":\"Chemicals\",\"AccountName\":\"/lightning/r/Account/0016C00000CldIiQAJ/view\",\"BillingAddress\":\"4492  Golden Ridge Road Church City,Las Vegas,NY,07292,USA\",\"DuplicateStatus\":\"PartDup\"}]",
            "SelectedRow":[{"Id":"0016C00000CldIiQAJ","Name":"Sapient","BillingStreet":"4492  Golden Ridge Road Church City","BillingCity":"Las Vegas","BillingState":"NY","BillingPostalCode":"07292","BillingCountry":"USA","Core_Intel_Partner_Alliance_PartnerGroup__c":true,"Core_Account_Type__c":"Cloud Service Provider (CSP)","Core_IPA_Partner_Role__c":"Service Provider","Industry":"Chemicals","AccountName":"/lightning/r/Account/0016C00000CldIiQAJ/view","BillingAddress":"4492  Golden Ridge Road Church City,Las Vegas,NY,07292,USA","DuplicateStatus":"PartDup"}],
            "AccountDuplicateStatus":"PartDup",
            "ContactDuplicateStatus":"NoDuplicate",
        "accountAssociatedToExistingContact":{"Id":"0016C00000EPSf5QAH","Name":"Roy Enterprises","BillingStreet":"US Church Street 927181/127 Near Trinity University","BillingCity":"Las Vegas","BillingState":"NY","BillingPostalCode":"0721","BillingCountry":"USA","Core_Intel_Partner_Alliance_PartnerGroup__c":true,"Core_Account_Type__c":"Distributor;Cloud Service Provider (CSP)","Core_IPA_Partner_Role__c":"Distributor;Independent Software Vendor;Service Provider","Industry":"Banking"}}
        null in case no existingAccountFound duplicateContactRecord
             */
        //Rollback everything, in case of any exception
        Savepoint sp = Database.setSavepoint();
        try{
            
            String accPartnerRoleExisting;
            String ContPartnerSegmentExist;
            string acmstatusApp;
            boolean accexist=false;
            boolean newacm=false;
            Set<String> setOpid=new Set<String>();
            list<prm_accountchannelMembership__c> acmsList=new list<prm_accountchannelMembership__c>();
            //Get values from input Map passed
            String accountDupStatus = registrationDetailsMap.get('AccountDuplicateStatus');
            String contactDupStatus = registrationDetailsMap.get('ContactDuplicateStatus');
            String accId = registrationDetailsMap.get('AccountID');
            
            Account accountAssociatedToExistingContact ;
            Contact duplicateContactRecord ;
            Account accToProcess ;
            Contact contToProcess ;
            String AccountPartnerRole;
            String AccountPartnerSegment;
            String accNumber = '';
            String ContactPartnerSegment;
            Map<Id, String> cpLevelToIdMap = new Map<Id, String>();
            
            Boolean rowSelected = false;
            Boolean isDuplicateContact = false;
            //Parse values to get selected row details
            List<Object> selectedRowJSONList = new List<Object>();
            Map<String, Object> selectedRowMap = new Map<String,Object>();
            Map<String,String> roleTypeMap = new Map<String,String>();
            
            String PartnerRole = registrationDetailsMap.get('PartnerRole');
            
            for(PRM_PartnerRoleTypeMappings__mdt roleTypeReq : [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c,PRM_Partner_Role_Label__c  
                                                            from PRM_PartnerRoleTypeMappings__mdt]){roleTypeMap.put(roleTypeReq.PRM_Partner_Role_Label__c, roleTypeReq.PRM_Partner_Role__c); }
            
            
            for(String str : roleTypeMap.keyset()){
                if(!String.isBlank(PartnerRole) && PartnerRole.contains(str)){
                    AccountPartnerRole = roleTypeMap.get(str);
                }
            }
            
            Map<String,String> segTypeLabelMap = new Map<String,String>();
            Map<String,String> segTypeRoleMap = new Map<String,String>();
            for(PRM_PartnerRoleTypeMappings__mdt segTypeReq : [Select Id,PRM_Partner_Role__c,PRM_Partner_Segment__c,PRM_Partner_Role_Label__c from PRM_PartnerRoleTypeMappings__mdt where PRM_Partner_Segment__c != null]){
                segTypeLabelMap.put(segTypeReq.PRM_Partner_Role_Label__c,segTypeReq.PRM_Partner_Segment__c);
                segTypeRoleMap.put(segTypeReq.PRM_Partner_Role__c,segTypeReq.PRM_Partner_Segment__c);
            }
            String segType = registrationDetailsMap.get('PartnerRole');
            for(String str : segTypeLabelMap.keyset()){
                if(str.equals(segType)){
                    AccountPartnerSegment = segTypeLabelMap.get(str);
                    ContactPartnerSegment = segTypeLabelMap.get(str);
                }
            }
            system.debug('accountpartnersegment'+AccountPartnerSegment);
            system.debug('contactpartnersegmnet'+ContactPartnerSegment);
            
            if(registrationDetailsMap.keySet().contains('SelectedRow') &&  registrationDetailsMap.get('SelectedRow') != null && registrationDetailsMap.get('SelectedRow') != '')
            {
                rowSelected = true;
                selectedRowJSONList = (List<Object>) JSON.deserializeUntyped(registrationDetailsMap.get('SelectedRow'));
                selectedRowMap = (Map<String,Object>) selectedRowJSONList[0];
                // system.debug(selectedRowMap.get('Name'));
                //String Name = String.valueOf(selectedRowMap.get('Name'));
                //system.debug(name);
            }
            
            //Check scenario
            if(contactDupStatus == 'Duplicate')
            {
                isDuplicateContact = true;
                duplicateContactRecord = [select id,name,email,accountId,Core_IPA_PartnerRole__c,Core_Preferred_Language__c,Core_Do_Not_Contact__c from contact where email=:registrationDetailsMap.get('ContactEmail')];
                accountAssociatedToExistingContact = [Select Id,Name,AccountNumber,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,Industry,Core_User_Defined_Website__c,Core_User_Defined_Phone_Number__c,Core_IPA_Badge_Tier__c from Account where id = : duplicateContactRecord.Accountid ];
                accToProcess =accountAssociatedToExistingContact ;
                contToProcess = duplicateContactRecord ;
            }
            
            //Create Account ********************************
            boolean newAccountCreated = false;
            string opidWithPA='';
            Id accountId = selectedRowMap != null && selectedRowMap.containsKey('Id') && selectedRowMap.get('Id') != null?String.valueOf(selectedRowMap.get('Id')) : null;
            if((isDuplicateContact == false) && (accountDupStatus == 'NoDup' || (!rowSelected)) && String.IsBlank(accId) && String.isBlank(accountId))
            {
                Account newAccount = new Account();
                Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
                newAccount.Name = registrationDetailsMap.get('AccountName') ;
                newAccount.RecordTypeId = accountRecordType;
                newAccount.BillingCountryCode = registrationDetailsMap.get('Country');
                newAccount.ShippingCountryCode = registrationDetailsMap.get('Country');
                newAccount.BillingStateCode = registrationDetailsMap.get('State');
                newAccount.ShippingStateCode = registrationDetailsMap.get('State');
                newAccount.BillingStreet = registrationDetailsMap.get('AddressLine1');
                newAccount.ShippingStreet = registrationDetailsMap.get('AddressLine1');
                if(String.isNotBlank(registrationDetailsMap.get('AddressLine2'))){
                    newAccount.BillingStreet += ' ' + registrationDetailsMap.get('AddressLine2');
                }
                if(String.isNotBlank(registrationDetailsMap.get('AddressLine2'))){
                    newAccount.ShippingStreet += ' ' + registrationDetailsMap.get('AddressLine2');
                }
                newAccount.BillingCity = registrationDetailsMap.get('City');
                newAccount.ShippingCity = registrationDetailsMap.get('City');
                newAccount.BillingPostalCode = registrationDetailsMap.get('PostalCode');
                newAccount.ShippingPostalCode = registrationDetailsMap.get('PostalCode');
                newAccount.Core_Account_Type__c = registrationDetailsMap.get('BizOrgType');
                newAccount.Core_IPA_Partner_Role__c = AccountPartnerRole;
                /*if(AccountPartnerSegment!=null && (!iparefresh ||  Test.isRunningTest())){
                    newAccount.Core_IPA_Partner_Segment__c = AccountPartnerSegment;
                }*/ //switch removal
                
                //newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true ;
                newAccount.Core_Sales_Groups__c = System.Label.PRM_Undefined;
                newAccount.Industry = System.Label.PRM_Needs_Defined;
                newAccount.Core_User_Defined_Website__c  = registrationDetailsMap.get('Website');
                if(newAccount.AccountNumber == null || String.isBlank(newAccount.AccountNumber)){
                    accNumber = PRM_AccountNumberGenerator.getAccountNum();
                    if(String.isNotBlank(accNumber)){ newAccount.AccountNumber = accNumber;
                        
                    }
                }
                User u = [Select id from User where alias =: System.Label.PRM_UncoveredAccount] ;
                if(u != null) {newAccount.OwnerId  = u.id ; }
                if(newAccount != null) {
					logEntryMsg+='newAccount details'+newAccount;
                  database.saveresult  srList=database.insert(newAccount,false);
					 if(srList!=null){		
				
						if (!srList.isSuccess()) {
							for (Database.Error e  : srList.getErrors()) {                      
							   logEntryMsg+='Error Occured while inserting accounts'+e.getMessage()+'Id -->'+srList.getId(); 
							}
						
					}
				}
                    accToProcess = newAccount;
                    newAccountCreated = true;
                }
            }
            else if(rowSelected || String.IsNotBlank(accId)){
                accexist=true;
                List<Account> selectedAccountList  = new List<Account>();
                if(String.IsBlank(accountId)){accountId = accId;
                }
                selectedAccountList = [Select id,Name,Core_IPA_One_Partner_Id__c,AccountNumber,BillingCountryCode,ShippingCountryCode,BillingStateCode,ShippingStateCode,BillingStreet,ShippingStreet,BillingCity,ShippingCity,BillingPostalCode,ShippingPostalCode,Core_Account_Type__c,core_IPA_Partner_Role__c,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Sales_Groups__c,Industry,Core_User_Defined_Website__c,Core_User_Defined_Phone_Number__c,Core_IPA_Partner_Segment__c,Core_IPA_Badge_Tier__c from Account where id =: accountId ];
                if(selectedAccountList != null && selectedAccountList.size()>0) {
                    accToProcess =  selectedAccountList[0];
                    opidWithPA=selectedAccountList[0].Core_IPA_One_Partner_Id__c;
					setOpid.add(selectedAccountList[0].Core_IPA_One_Partner_Id__c);
                    System.debug('DEBUG setOpid = ' + setOpid);
                    System.debug('DEBUG opidWithPA = ' + opidWithPA);
                }
                list<prm_accountchannelMembership__c> acmsPending=new list<prm_accountchannelMembership__c>();
                list<prm_accountchannelMembership__c> acmsApproved=new list<prm_accountchannelMembership__c>();
                
                acmsList = [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c,PRM_Status_Nm__c,PRM_Tier_Name_txt__c,PRM_Channel_Program_Level_Id__r.Name from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: accToProcess.id order by CreatedDate asc];
                
                for(prm_accountchannelMembership__c acm: acmsList){
                    if(acm.PRM_Status_Nm__c=='Approved'){
                        acmsApproved.add(acm);
                    }else if(acm.PRM_Status_Nm__c=='Pending'){
                        acmsPending.add(acm);
                    }
                }
                newacm=true;
                if(!acmsApproved.isEmpty()){
                    newacm=false;
                    accPartnerRoleExisting=acmsApproved[0].PRM_Partner_Role__c;
                    /*if(!iparefresh ||Test.isRunningTest()){
                        ContPartnerSegmentExist=segTypeRoleMap.get(accPartnerRoleExisting);
                    }*/ //switch removal
                    acmstatusApp=acmsApproved[0].PRM_Status_Nm__c;
                }
                else if(!acmsPending.isEmpty()){
                    newacm=false;
                    accPartnerRoleExisting=acmsPending[0].PRM_Partner_Role__c;
                    /*if(!iparefresh || Test.isRunningTest()){
                        ContPartnerSegmentExist=segTypeRoleMap.get(accPartnerRoleExisting);
                    }*/ //switch removal
                    acmstatusApp=acmsPending[0].PRM_Status_Nm__c;
                }
                System.debug('accToProcess160----> ' +accToProcess);
                /** partener segment assigned to the existing account */
                /*if(accToProcess.Core_IPA_Partner_Segment__c != null &&  accToProcess.Core_IPA_Partner_Segment__c != '' && (!iparefresh || Test.isRunningTest())) {
                    List<String> partnersegList = (accToProcess.Core_IPA_Partner_Segment__c).split(';');
                    if(partnersegList.contains(AccountPartnerSegment)|| AccountPartnerSegment==Null){
                        AccountPartnerSegment = accToProcess.Core_IPA_Partner_Segment__c;
                        accToProcess.Core_IPA_Partner_Segment__c = AccountPartnerSegment;
                    }
                    else if(newacm){
                        AccountPartnerSegment = accToProcess.Core_IPA_Partner_Segment__c+';'+ AccountPartnerSegment;
                        accToProcess.Core_IPA_Partner_Segment__c = AccountPartnerSegment;
                    }
                    
                    else if(partnersegList.isEmpty() || (segTypeRoleMap.get(accPartnerRoleExisting) != null && !partnerseglist.contains(segTypeRoleMap.get(accPartnerRoleExisting)))){
                        AccountPartnerSegment = accToProcess.Core_IPA_Partner_Segment__c+';'+ segTypeRoleMap.get(accPartnerRoleExisting);
                        accToProcess.Core_IPA_Partner_Segment__c = AccountPartnerSegment;
                    }
                } else  //switch removal
                if (String.isNotBlank(AccountPartnerSegment) && String.isBlank(accToProcess.Core_IPA_Partner_Segment__c) && (!iparefresh || Test.isRunningTest())){
                    accToProcess.Core_IPA_Partner_Segment__c = AccountPartnerSegment;
                }*/ //switch removal
            }
            
            //Changing the logic - TWC729-2253 - Mapping of new website field for all the existing accounts as part of new registrations
            if(accToProcess.Core_User_Defined_Website__c == null || String.isBlank(accToProcess.Core_User_Defined_Website__c)){
                accToProcess.Core_User_Defined_Website__c = registrationDetailsMap.get('Website');
            }
            //Populate account number as part of US773141
            if(accToProcess.Core_Intel_Partner_Alliance_PartnerGroup__c == false){
                
                if(accToProcess.AccountNumber == null || String.isBlank(accToProcess.AccountNumber)){
                    System.debug('@@ BLANK ACCOUNT NUMBER');
                    accNumber = PRM_AccountNumberGenerator.getAccountNum();
                    if(String.isNotBlank(accNumber)){
                        accToProcess.AccountNumber = accNumber;
                    }
                System.debug('@@ accNumber'+accNumber);  }
            }
            
            system.debug('@ queried Account existing'+accToProcess);
            
            
            //Create Contact **************************
            boolean newContactCreated = false;
            Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
            if(contactDupStatus == 'NoDuplicate')
            {
                Contact cont = new Contact();
                cont.FirstName = registrationDetailsMap.get('ContactFirstName');
                cont.LastName = registrationDetailsMap.get('ContactLastName');
                cont.Email = registrationDetailsMap.get('ContactEmail');
                //Keerthan added as part of US609304
                /*******************/
                System.debug('ContactCountry : '+registrationDetailsMap.get('ContactCountry'));
                cont.MailingCountry = registrationDetailsMap.get('ContactCountry');
                cont.MailingCountryCode = registrationDetailsMap.get('ContactCountry');
                /*******************/
                Schema.DescribeFieldResult fieldResult = Contact.Core_Preferred_Language__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                Map<String,String> picklistlangMap = new Map<String,String>();

				//IPA2.0 - Fix for setting preferred language on contact based on Registration
                for (Schema.PicklistEntry entry : ple){
                    PicklistlangMap.put(entry.getLabel(), entry.getValue());
                }

                if(registrationDetailsMap.get('PreferredLanguage') != null && registrationDetailsMap.get('PreferredLanguage') != '' &&
                picklistlangMap != null && picklistlangMap.containsKey(registrationDetailsMap.get('PreferredLanguage'))){
                    string prefLangcode = picklistlangMap.get(registrationDetailsMap.get('PreferredLanguage'));
                    cont.Core_Preferred_Language__c = prefLangcode; //registrationDetailsMap.get('PreferredLanguage');
                    cont.Core_eRPM_Language_Code__c= prefLangcode; //registrationDetailsMap.get('PreferredLanguage');
                }
                else{
                    cont.Core_Preferred_Language__c =System.Label.PRM_ENG;
                    cont.Core_eRPM_Language_Code__c=System.Label.PRM_ENG; 
                }
                    cont.RecordTypeId = contactRecordType;
                if(accexist){
                    //if all existing acms are pending/inactive then create a new acm and map contact with that acm's partner role
                    if(newacm){
                        cont.Core_IPA_PartnerRole__c = AccountPartnerRole;
                        /*if(!iparefresh || Test.isRunningTest()){
                        cont.Core_IPA_Contact_Segment__c = ContactPartnerSegment;}*/ //switch removal
                    }
                    else{
                        /*if(!iparefresh ||Test.isRunningTest()){
                            cont.Core_IPA_Contact_Segment__c = ContPartnerSegmentExist;
                        }*/ //switch removal
                    cont.Core_IPA_PartnerRole__c = accPartnerRoleExisting;}
                }
                if(newAccountCreated){
                    cont.Core_IPA_PartnerRole__c = AccountPartnerRole;
                    //if(!iparefresh ||Test.isRunningTest())cont.Core_IPA_Contact_Segment__c = ContactPartnerSegment; //switch removal
                }
                cont.AccountId = accToProcess.id;
                System.debug('Contact JSON -->'+JSON.serialize(cont));
                insert cont;
                newContactCreated = true;
                contToProcess = cont;
                //PRM_AGS_IdentityCreation.createIdentityInAGS(cont.Id);
            }
            
            //Create ACM************************
            String ipaChannelPgmId ;
            String channelProgramLevelId ;
            Boolean newACMCreated = false;
            List<ChannelProgram> chProgramList = [select id from ChannelProgram where prm_programCode__c=: System.Label.PRM_IPAEngagement];
            Map<String,PRM_AccountChannelMembership__c> existingACMMap = new Map<String,PRM_AccountChannelMembership__c>();
            List<PRM_AccountChannelMembership__c> accChannelMembershipListToUpsert = new List<PRM_AccountChannelMembership__c>();
            if(ChProgramList != null && ChProgramList.size()>0)
            {
                ipaChannelPgmId = ChProgramList[0].id;
            }
            Set<String> tierNames = new Set<String>();
            //if(iparefresh){
                tierNames.add('Partner');
                tierNames.add('Prestige');
            //}
            if(Test.isRunningTest()){
                tierNames.add('Member');
                tierNames.add('Gold');
                tierNames.add('Titanium');
            }
            List<ChannelProgramLevel> cplevels = [select id,Name from ChannelProgramLevel where  ProgramId =:ipaChannelPgmId and name in :tierNames];
            for(ChannelProgramLevel CPLevel : cplevels){
                cpLevelToIdMap.put(CPLevel.id, CPLevel.Name);
                if(CPLevel.Name == 'Partner'){//(CPLevel.Name == system.label.PRM_Member && (!iparefresh || Test.isRunningTest())) || CPLevel.Name == 'Partner' && iparefresh)
                    channelProgramLevelId = CPLevel.Id;
                }
            }
            //check for existing ACM records :
            boolean isIPAaccount = false;
            
            if(!acmsList.isEmpty()){
                for(PRM_AccountChannelMembership__c acm : acmsList)
                {
                    if(acm.PRM_Channel_Program_Id__c == ipaChannelPgmId){
                        existingACMMap.put(String.valueOf(acm.PRM_Account_Id__c)+String.valueOf(acm.PRM_Channel_Program_Id__c)+String.valueOf(acm.PRM_Partner_Role__c),acm);
                        //if ACM record found for the same account with patrtner role provided in input, Account will be considered as IPA
                        if(acm.PRM_Status_Nm__c != null && acm.PRM_Status_Nm__c != 'Inactive')
                        {
                            isIPAaccount = true;
                        }
                    }
                }
            }
            else{
                for(PRM_AccountChannelMembership__c acm : [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c,PRM_Status_Nm__c,PRM_Tier_Name_txt__c,PRM_Channel_Program_Level_Id__r.Name from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: accToProcess.id and PRM_Channel_Program_Id__c =: ipaChannelPgmId and PRM_Partner_Role__c =: AccountPartnerRole])
                {
                    existingACMMap.put(String.valueOf(acm.PRM_Account_Id__c)+String.valueOf(acm.PRM_Channel_Program_Id__c)+String.valueOf(acm.PRM_Partner_Role__c),acm);
                    //if ACM record found for the same account with patrtner role provided in input, Account will be considered as IPA
                    if(acm.PRM_Status_Nm__c != null && acm.PRM_Status_Nm__c != 'Inactive')
                    {
                        isIPAaccount = true;
                    }
                }
            }
            
            PRM_AccountChannelMembership__c accChannelMembership ;
            
            if((!isIPAaccount) || (rowSelected == false && isDuplicateContact == false))
            {
                //Create new ACM when New Account created or existing Account is NonIPA
                newACMCreated = true;
                accChannelMembership = new PRM_AccountChannelMembership__c();
                
                
                accChannelMembership.PRM_Partner_Role__c = AccountPartnerRole;
                
                accChannelMembership.PRM_Account_Id__c = accToProcess.id ;
                accChannelMembership.PRM_Status_Nm__c = System.Label.PRM_Status_Pending ;//System.Label.PRM_Status;
                accChannelMembership.PRM_Status_Reason_Txt__c = 'Admin Registration';//TWC729-8089 : Adding reason text : NJ
                if(ipaChannelPgmId != null && ipaChannelPgmId != '') {accChannelMembership.PRM_Channel_Program_Id__c = ipaChannelPgmId;}
                if(channelProgramLevelId != null && channelProgramLevelId != '') {accChannelMembership.PRM_Channel_Program_Level_Id__c = channelProgramLevelId ;}
				logEntryMsg+='Creating new ACM when New Account created or existing Account is NonIPA'+accChannelMembership;
                //update Account(Biz Org Type, PR, IPA) and Contact(PR) when ACM record created, but when records are not newly created already
                /*if(!newContactCreated)
                {
                    if(contToProcess.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(contToProcess.Core_IPA_Partner_Role__c)))
                    {Set<String> existingPartnerRoleSet = new Set<String>();
                        existingPartnerRoleSet.addAll(contToProcess.Core_IPA_Partner_Role__c.split(';'));
                        if(! existingPartnerRoleSet.contains(registrationDetailsMap.get('PartnerRole'))) { contToProcess.Core_IPA_Partner_Role__c = contToProcess.Core_IPA_Partner_Role__c+';'+registrationDetailsMap.get('PartnerRole') ;  }
                    }else {
                        contToProcess.Core_IPA_Partner_Role__c = registrationDetailsMap.get('PartnerRole') ;
                    }
                    //contToProcess.Core_IPA_Partner_Role__c = registrationDetailsMap.get('PartnerRole') ;
                    update contToProcess ;
                    system.debug('<----Contact Updated--->');
                }*/
            }
            
            
            if(!newAccountCreated)
            {
                // added by DINESH
                
                /*if(!iparefresh || Test.isRunningTest()){
                    if(accToProcess.Core_Account_Type__c != null && String.isNotBlank(String.valueOf(accToProcess.Core_Account_Type__c)))
                    {
                        Set<String> existingAccTypeSet = new Set<String>();
                        existingAccTypeSet.addAll(accToProcess.Core_Account_Type__c.split(';'));
                        Set<String> regRequestAccType = new Set<String>();
                        regRequestAccType.addAll(registrationDetailsMap.get('BizOrgType').split(';'));
                        for(String accType: regRequestAccType){
                            if(!existingAccTypeSet.contains(accType) && newacm){
                                accToProcess.Core_Account_Type__c = accToProcess.Core_Account_Type__c+';'+accType ;
                            }
                        }
                    }
                    else{
                        if(registrationDetailsMap.containskey('BizOrgType') )
                            accToProcess.Core_Account_Type__c = registrationDetailsMap.get('BizOrgType') ;
                    }
                }*/ //Switch Removal
                
                if(accToProcess.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(accToProcess.Core_IPA_Partner_Role__c)))
                {   Set<String> existingPartnerRoleSet = new Set<String>();
                    existingPartnerRoleSet.addAll(accToProcess.Core_IPA_Partner_Role__c.split(';'));
                    
                    if(!existingPartnerRoleSet.contains(AccountPartnerRole) && newacm) {
                        
                    accToProcess.Core_IPA_Partner_Role__c = accToProcess.Core_IPA_Partner_Role__c+';'+AccountPartnerRole ;  }
                }
                else { accToProcess.Core_IPA_Partner_Role__c = AccountPartnerRole ;  }
                if(accToProcess != null && accChannelMembership != null){
                    if(cpLevelToIdMap.containskey(accChannelMembership.PRM_Channel_Program_Level_Id__c)){
                        accToProcess.Core_IPA_Badge_Tier__c  = cpLevelToIdMap.get(accChannelMembership.PRM_Channel_Program_Level_Id__c);
                        accToProcess.PRM_IPA_Badge_Tier_Date__c = System.now();
                    }
                }
                
                system.debug('<----Account Updated--->');
            }
            
            //update contact's partner role if it is an existing contact
            if(!newContactCreated  || String.isNotBlank(AccountPartnerRole)) /*&& (String.isNotBlank(ContPartnerSegmentExist))*/{
                if(contToProcess.Core_IPA_PartnerRole__c == null || contToProcess.Core_IPA_PartnerRole__c ==''){
                    contToProcess.Core_IPA_PartnerRole__c = AccountPartnerRole;
                }
                /*if(!iparefresh ||Test.isRunningTest()){ //Switch Removal
                    contToProcess.Core_IPA_Contact_Segment__c = ContPartnerSegmentExist;
                }*/
               // update contToProcess ; 
		//Database.SaveResult[] srList;
		logEntryMsg+='update contact partner role if it is an existing contact'+contToProcess;
		database.saveresult srList=Database.update(contToProcess,false);

if(srList!=null){		
		
                if (!srList.isSuccess()) {
                    for (Database.Error e  : srList.getErrors()) {                      
                       logEntryMsg+='Error Occured while updating contacts'+e.getMessage()+'Id -->'+srList.getId();
                    }
                }
            
			}
            }
           database.saveresult srList=Database.update(accToProcess,false);
			logEntryMsg+='updated account'+accToProcess;
            if(srList!=null){		
		
                if (!srList.isSuccess()) {
                    for (Database.Error e  : srList.getErrors()) {                      
                       logEntryMsg+='Error Occured while updating accounts'+e.getMessage()+'Id -->'+srList.getId();
                    }
                
            }
			}
            if(existingACMMap != null && existingACMMap.get(String.valueOf(accToProcess.id)+String.valueOf(ipaChannelPgmId)+String.valueOf(AccountPartnerRole)) != null)
            {
                if(existingACMMap.get(String.valueOf(accToProcess.id)+String.valueOf(ipaChannelPgmId)+String.valueOf(AccountPartnerRole)).PRM_Status_Nm__c == 'Inactive' ) {accChannelMembership = existingACMMap.get(String.valueOf(accToProcess.id)+String.valueOf(ipaChannelPgmId)+String.valueOf(AccountPartnerRole));
                    accChannelMembership.PRM_Status_Nm__c = System.Label.PRM_Status_Pending ;
                    accChannelMembership.PRM_Status_Reason_Txt__c = 'Admin Registration';//TWC729-8089 : Adding reason text : NJ
                    if(!isIPAaccount && channelProgramLevelId != null && channelProgramLevelId != ''){
                        accChannelMembership.PRM_Channel_Program_Level_Id__c = channelProgramLevelId ;
                    }
            accChannelMembershipListToUpsert.add(accChannelMembership) ; }  }
            // if new account is reated while doing admin reg or if new contcat is added when no acm is present on acount
            else if(newAccountCreated || newacm ){
                //If no duplicate ACM found..
				logEntryMsg+='new account is reated while doing admin reg or if new contcat is added when no acm is present on acount, created new acm'+accChannelMembershipListToUpsert;
                if(accChannelMembership != null) {accChannelMembershipListToUpsert.add(accChannelMembership) ; }
            }
            if(accChannelMembershipListToUpsert != null && accChannelMembershipListToUpsert.size()>0) {  
		logEntryMsg+='upserting accChannelMembershipListToUpsert'+accChannelMembershipListToUpsert;
				result=database.upsert(accChannelMembershipListToUpsert,false);
				if(!result.isempty()){
				for (Database.upsertResult sr : result) {
                if (!sr.isSuccess()) {
                    for (Database.Error e  : sr.getErrors()) {                      
                       logEntryMsg+='Error Occured while upserting ACM'+e.getMessage()+'Id -->'+sr.getId(); 
					   
                    }
                }
            }
		}
				}
            
            //Create ACR***********************
            boolean onlyEmp = false;
            Map<String, PRM_ContactRelationships__c> contactRelationshipsById = New Map<String,PRM_ContactRelationships__c>();
            Map<String,PRM_Account_Contact_Relationship__c> existingACRMap = new Map<String,PRM_Account_Contact_Relationship__c>();
            List<PRM_Account_Contact_Relationship__c> accConRelationshipsToUpsert = new List<PRM_Account_Contact_Relationship__c>();
            Map<String,PRM_Account_Contact_Relationship__c> ACRMapForExistingACM = new Map<String,PRM_Account_Contact_Relationship__c>();
			set<string> setPAAlreadyExist=new set<string>();
            //check for duplicates
            for(PRM_Account_Contact_Relationship__c acr : [Select id,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,PRM_Contact_Id__c,PRM_Relationship_Id__c,PRM_InActive_Ind__c,PRM_Status_Nm__c,PRM_Partner_Role__c,PRM_Relationship_Id__r.Name,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c from PRM_Account_Contact_Relationship__c 
                                                           where PRM_Account_Id__c =: accToProcess.id
														   or (PRM_Account_Id__r.Core_IPA_One_Partner_Id__c =: opidWithPA
														   and PRM_InActive_Ind__c=false and PRM_Status_Nm__c='Complete'
														   and (PRM_Relationship_Id__r.Name='Partner Admin' or PRM_Relationship_Id__r.Name='Partner Admin Delegate')
                                                          )]){
				if(accToProcess.id==acr.PRM_Account_Id__c){
					if(acr.PRM_Contact_Id__c == contToProcess.id){
                    existingACRMap.put(String.valueOf(acr.PRM_Account_Id__c)+String.valueOf(acr.PRM_Contact_Id__c)+String.valueOf(acr.PRM_Relationship_Id__c),acr) ;
                }
                ACRMapForExistingACM.put(String.valueOf(acr.PRM_Relationship_Id__c),acr);
                if(acr.PRM_InActive_Ind__c == false){
                    onlyEmp = true;
                }
				}
				if(acr.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c!=null && opidWithPA==acr.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c && acr.PRM_InActive_Ind__c == false && acr.PRM_Status_Nm__c =='Complete'
				&& (acr.PRM_Relationship_Id__r.Name == 'Partner Admin' || acr.PRM_Relationship_Id__r.Name == 'Partner Admin Delegate')){
					setPAAlreadyExist.add(acr.PRM_Relationship_Id__r.Name);
                    System.debug('DEBUG setPAAlreadyExist=' + setPAAlreadyExist);
				}
				
                
            }
            if(ipaChannelPgmId != null  && ipaChannelPgmId != '' ){
                for(PRM_ContactRelationships__c crel : [Select Id, Name, PRM_Channel_Program_Id__c From PRM_ContactRelationships__c Where PRM_Channel_Program_Id__c =: ipaChannelPgmId]){
                    contactRelationshipsById.put(crel.Name, crel);
                }
                system.debug('@@@contactRelationshipsById'+contactRelationshipsById);
            }
            Set<String> relationshipToAssign = new Set<String>();
            System.debug('setPAAlreadyExist = ' + setPAAlreadyExist);
            
            if(contactRelationshipsById != null && (!contactRelationshipsById.isEmpty())){
                //PC and WF both are assigned when new ACM is created, otherwise only WF
                try{
                    if(contactRelationshipsById.containsKey(System.Label.PRM_Primary_Contact) ){
                        if(newAccountCreated||(rowSelected == false && isDuplicateContact == false)){
                            relationshipToAssign.add(contactRelationshipsById.get(System.Label.PRM_Primary_Contact).id);
                        }
                        else if(acmstatusapp!='Approved' && setPAAlreadyExist.isEmpty()){
                            relationshipToAssign.add(contactRelationshipsById.get(System.Label.PRM_Primary_Contact).id);
                            
                        }
                    }
                    
                }
                catch(System.NullPointerException e){
                    System.debug(e);
                }
                if(contactRelationshipsById.containsKey(System.Label.PRM_WorksFor)){
                    relationshipToAssign.add(contactRelationshipsById.get(System.Label.PRM_WorksFor).id);
                }
            }
            
            system.debug('Relationship to assign-->'+relationshipToAssign);
            for(String crelID : relationshipToAssign)
            {
                PRM_Account_Contact_Relationship__c accConRel = New PRM_Account_Contact_Relationship__c();
                accConRel.PRM_Relationship_Id__c = crelID ;
                accConRel.PRM_Account_Id__c= accToProcess.id;
                accConRel.PRM_Contact_Id__c = contToProcess.id ;
                // for setting email flag to false
                accConRel.PRM_No_Email__c = false;
                //set below flag to false : for stoping trigger executioon
                accConRel.PRM_execute_trigger__c = false;
                accConRel.PRM_InActive_Ind__c= false;
                accConRel.PRM_Status_Nm__c = 'Pending Action';
                accConRel.PRM_Status_Reason_Txt__c ='Admin Registration';//TWC729-8089 : Adding reason text : NJ
                accConRel.PRM_Source_Agent__c = 'Admin Invite';
                accConRel.PRM_CampaignId__c=null;
                accConRel.Bulk_Data_Upload__c=null;
                if(registrationDetailsMap.get('SuppressEmail') == 'true'){
                    accConRel.PRM_Suppress_Email__c = true;
                    accConRel.PRM_Status_Reason_Txt__c=UserInfo.getName()+' '+' has opted for Suppress Email In this Transaction';
                }
                if(existingACRMap != null && existingACRMap.get(String.valueOf(accConRel.PRM_Account_Id__c)+String.valueOf(accConRel.PRM_Contact_Id__c)+String.valueOf(accConRel.PRM_Relationship_Id__c)) != null )
                {   //update ACR only if inActive indicator is false
                    if(existingACRMap.get(String.valueOf(accConRel.PRM_Account_Id__c)+String.valueOf(accConRel.PRM_Contact_Id__c)+String.valueOf(accConRel.PRM_Relationship_Id__c)).PRM_InActive_Ind__c == true){
                        for(PRM_Account_Contact_Relationship__c ExistingAcr: existingACRMap.values()){
                            if(ExistingAcr.PRM_Relationship_Id__c != crelID){
                                continue;
                            }
                            if(onlyEmp && ExistingAcr.PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c == 'PRIMARY'){
                                continue;
                            }
                            ExistingAcr.PRM_InActive_Ind__c= false;
                            ExistingAcr.PRM_Status_Nm__c = 'Pending Action';
                            ExistingAcr.PRM_Status_Reason_Txt__c ='Admin Registration';//TWC729-8089 : Adding reason text : NJ
                            ExistingAcr.PRM_Source_Agent__c = 'Admin Invite';
                            ExistingAcr.PRM_CampaignId__c=null;
                            ExistingAcr.Bulk_Data_Upload__c=null;
                            if(registrationDetailsMap.get('SuppressEmail') == 'true'){
                                ExistingAcr.PRM_Suppress_Email__c = true;
                                ExistingAcr.PRM_Status_Reason_Txt__c=UserInfo.getName()+' '+' has opted for Suppress Email In this Transaction';
                            }
                            accConRelationshipsToUpsert.add(ExistingAcr) ;
                        }
                    }
                }
                
                else{
                    //if no duplicate ACR record found..
                    accConRelationshipsToUpsert.add(accConRel) ;
                }
                system.debug('ACR List to upsert'+accConRelationshipsToUpsert);
            }
            if(accConRelationshipsToUpsert!= null && accConRelationshipsToUpsert.size()>0) { 
			logEntryMsg+='accConRelationshipsToUpsert'+accConRelationshipsToUpsert;
              Result=database.upsert(accConRelationshipsToUpsert,false) ; 
			  if(!result.isempty()){
				for (Database.upsertResult sr : result) {
                if (!sr.isSuccess()) {
                    for (Database.Error e  : sr.getErrors()) {                      
                       logEntryMsg+='Error Occured while upserting ACR'+e.getMessage()+'Id -->'+sr.getId(); 
                    }
                }
            }
		}
			  }
            // Get values to return**********************
            recordIdsMap.put('AccountId',accToProcess.id);
            recordIdsMap.put('ContactId',contToProcess.id);
            List<Contact> contactsTosendEmail = new List<Contact>();
            contactsTosendEmail.add(contToProcess);
            //sendWelcomeEmailNotification(contactsTosendEmail);
			 listOfLogEntries.add(new Core_Log_Entry__c(Core_Message__c = 'PRM_AccountChangeEventSubscriber', 
                                               Core_Origin__c = ORIGIN, Core_Details__c = logEntryMsg, 
                                               Core_Severity__c = SEVERITY, Core_When__c = System.Now(), 
                                               Core_Project__c = PROJECT));
			// insert a log entry for 
			if (!listOfLogEntries.isEmpty() && listOfLogEntries !=null) { Core_Log_Entry.createLogEntries(listOfLogEntries);
		   }
            return recordIdsMap;
        }
        catch(Exception e){
            PRM_ErrorUtilityClass.logError(e);
            Database.rollback( sp );
        }
        
        return null;
    }
    
    
    //Keerthan added on 01/09/2020 : To process and create related records for Admin registration
    public static void processRelatedRecordsAdmin(List<Id> accountIds, Map<Id,PRM_Registration_Request__c> accRegMap,List<String> contactEmailList){
        Set<String> emailIds=new Set<String>();
        set<String> reordIds=new set<string>();
        //Rollback everything, in case of any exception
        Savepoint sp = Database.setSavepoint();
        try{
            //##create Legal Agreement Association
            String accId;
            String conId;
            String name;
            String email;
            PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
            List<Contact> contactList = new List<Contact>();
            Set<String> legalAgrmntValues =new Set<String>();
            Map<String, String> legalAgrmntMap = new Map<String, String>();
            List<PRM_AccountLegalAgreemntAssociation__c> accLegalAgreementUpsertList = new List<PRM_AccountLegalAgreemntAssociation__c>();
            Map<String,PRM_AccountLegalAgreemntAssociation__c> existingALAMap = new Map<String,PRM_AccountLegalAgreemntAssociation__c>();
            List<PRM_AccountLegalAgreemntAssociation__c> eligibleLegalAgreementRollUpToOPID = new List<PRM_AccountLegalAgreemntAssociation__c>();
            set<String> accLegalAggrementSet = new set<String>();
            for(Id id : accountIds){
                accId = id;
            }
            if(String.isNotBlank(accId)){
                regRequest = accRegMap.get(accId);
                reordIds.add(regRequest.Id);
            }
            if(String.isNotBlank(regRequest.PRM_Legal_Agreements__c)){
                legalAgrmntValues.addall(regRequest.PRM_Legal_Agreements__c.split(';'));
            }
            if(!legalAgrmntValues.isEmpty() && legalAgrmntValues != null){
                for(PRM_PartnerAgreement__c pa : [Select Id,Name,PRM_Agreement_Cd__c from PRM_PartnerAgreement__c where PRM_Agreement_Cd__c IN : legalAgrmntValues]){
                    legalAgrmntMap.put(pa.PRM_Agreement_Cd__c,pa.id);
                }
            }
            //check for duplicates:
            for(PRM_AccountLegalAgreemntAssociation__c ala : [Select id,PRM_Account_Id__c,PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__c from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c =: accId and PRM_Partner_Agreement_Id__c in : legalAgrmntMap.values() AND PRM_InActive_Ind__c = false])
            {
                existingALAMap.put(String.valueOf(ala.PRM_Account_Id__c)+String.valueOf(ala.PRM_Partner_Agreement_Id__c),ala);
                accLegalAggrementSet.add(String.valueOf(ala.PRM_Account_Id__c)+String.valueOf(ala.PRM_Partner_Agreement_Id__c));
                
            }
            
            for(Contact c : [Select Id,AccountId,Email,Core_eRPM_Language_Code__c,Core_IPA_PartnerRole__c,Core_Do_Not_Contact__c,Core_Preferred_Language__c,Firstname,Lastname From Contact Where Email In : contactEmailList]){conId = c.Id;contactList.add(c);emailIds.add(c.Email);name = c.FirstName+' '+c.LastName;email = c.Email;}
            
            if(String.isNotBlank(regRequest.PRM_Legal_Agreements__c)){
                for(String value : regRequest.PRM_Legal_Agreements__c.split(';')){
                    if(legalAgrmntMap.containsKey(value)){
                        PRM_AccountLegalAgreemntAssociation__c acntLegalAgrAssoc = new PRM_AccountLegalAgreemntAssociation__c();
                        acntLegalAgrAssoc.PRM_Partner_Agreement_Id__c = legalAgrmntMap.get(value);
                        acntLegalAgrAssoc.PRM_Account_Id__c = accId;
                        // IPA 2.0 - TWC729-7874 -start
                        acntLegalAgrAssoc.PRM_Signed_By_Email__c = email;
                        acntLegalAgrAssoc.PRM_Signed_By_Name__c = name;
                        //IPA 2.0 - TWC729-7874 -end
                        acntLegalAgrAssoc.PRM_Agreement_Sign_Dt__c = System.Now();
                        if(!accLegalAggrementSet.contains(String.valueOf(acntLegalAgrAssoc.PRM_Account_Id__c)+String.valueOf(acntLegalAgrAssoc.PRM_Partner_Agreement_Id__c))) {accLegalAgreementUpsertList.add(acntLegalAgrAssoc);
                            
                        }
                        if(value == System.Label.PRM_IPATNCCode){
                            if(!eligibleLegalAgreementRollUpToOPID.contains(acntLegalAgrAssoc)){
                                eligibleLegalAgreementRollUpToOPID.add(acntLegalAgrAssoc);
                            }
                        }
                    }
                }
                if(eligibleLegalAgreementRollUpToOPID != null && eligibleLegalAgreementRollUpToOPID.size() > 0){
                    List<PRM_AccountLegalAgreemntAssociation__c> legalAgreementRollUpToOPID = PRM_ALA_Utility.PopulateLegalAgreeOnOPID(eligibleLegalAgreementRollUpToOPID);
                    accLegalAgreementUpsertList.addAll(legalAgreementRollUpToOPID);
                }
                
            }
            if(accLegalAgreementUpsertList!= null && accLegalAgreementUpsertList.size()>0) {IS_Admin_Invite = true; 
			//upsert accLegalAgreementUpsertList ;
			logEntryMsg+='accLegalAgreementUpsertList'+accLegalAgreementUpsertList;
			Result=database.upsert(accLegalAgreementUpsertList,false) ; 
			  if(!result.isempty()){
				for (Database.upsertResult sr : result) {
                if (!sr.isSuccess()) {
                    for (Database.Error e  : sr.getErrors()) {                      
                       logEntryMsg+='Error Occured while upserting ACR'+e.getMessage()+'Id -->'+sr.getId(); 
                    }
                }
            }
		}

			}
            
            //Update ACM to Approved Status
            Boolean isAdminProcess = True;
            List<PRM_AccountChannelMembership__c> acmList =  [Select Id,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Channel_Program_Id__c,PRM_Partner_Role__c,PRM_Tier_Name_txt__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c In : accountIds];
            List<PRM_AccountChannelMembership__c> acmListtoUpdate = new List<PRm_AccountChannelMembership__c>();
            Boolean acmApproved = False;
            if(acmList.size() > 0){
                for(PRM_AccountChannelMembership__c acm : acmList){
                    if((acm.PRM_Channel_Program_Id__c == accRegMap.get(acm.PRM_Account_Id__c).PRM_Channel_Program__c)&&(acm.PRM_Partner_Role__c==accRegMap.get(acm.PRM_Account_Id__c).PRM_Partner_Role__c)){
                        if(acm.PRM_Status_Nm__c == 'Approved'){ acmApproved = true;}
                        else{
                            
                            if(acm.PRM_Channel_Program_Level_Id__r.Name!='Member'){
                                acm.PRM_Channel_Program_Level_Id__c = accRegMap.get(acm.PRM_Account_Id__c).PRM_Channel_Program_Level__c;
                            }
                            acm.PRM_Status_Nm__c = 'Approved';
                            //TWC729-8089 : Adding reason text : NJ
                            acm.PRM_Status_Reason_Txt__c = System.Label.PRM_APPROVE_MSG;
                            acmListtoUpdate.add(acm);
                        }
                    }
                }
            }
            logEntryMsg+='acmListtoUpdate'+acmListtoUpdate;
			
            if(acmListtoUpdate.size() > 0){
              srList=database.update( acmListtoUpdate,false);
				if(srList!=null){		
		for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for (Database.Error e  : sr.getErrors()) {                      
                       logEntryMsg+='Error Occured while updating acm'+e.getMessage()+'Id -->'+sr.getId(); 
                    }
                }
            }
			}
                acmApproved = True;
            }
            if(acmApproved){
                List<Account> accountList = [Select Id,Name,AccountNumber,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,Industry,Core_User_Defined_Phone_Number__c,Core_User_Defined_Website__c, RecordType.DeveloperName From Account Where Id In : accountIds];
                //List<Contact> contactList = [Select Id,AccountId,Email,Core_eRPM_Language_Code__c,Core_IPA_Partner_Role__c,Core_Do_Not_Contact__c,Core_Preferred_Language__c,Firstname,Lastname From Contact Where Email In : contactEmailList];
                Map<Id,Contact> accContactMap = new Map<Id,Contact>();
                for(Contact con : contactList){accContactMap.put(con.AccountId,con); }
                for(Account acc : accountList){
                    createRelatedRecords(accRegMap.get(acc.id),acc,accContactMap.get(acc.Id));
                }
                
                System.enqueueJob( new PRM_RegReqProcessingQueueable(accountList,contactList,isAdminProcess,System.Label.PRM_Email_Admin_Approval_Event,regRequest,true));
                
            }
            else{
                logEntries='No Exception but ACM wasnt Approved';
            }
            listOfLogEntries.add(new Core_Log_Entry__c(Core_Message__c = 'PRM_AccountChangeEventSubscriber', 
                                               Core_Origin__c = ORIGIN, Core_Details__c = logEntryMsg, 
                                               Core_Severity__c = SEVERITY, Core_When__c = System.Now(), 
                                               Core_Project__c = PROJECT));
        }
        catch(exception e){string LogEntry=PRM_ErrorUtilityClass.logError(e);
            Database.rollback( sp );
            logEntries=logEntries!=null?logEntries+';'+LogEntry: LogEntry;
            system.debug('---getmessage '+e.getmessage());
            system.debug('---logEntries '+logEntries);
        }
        Finally{
            PRM_RegistrationTrackerUtility.EnQueueTrackerUtility(reordIds,null,logEntries,'PRM_CreateAccountAndRelatedRecordsAdmin','Admin');
        }
        
    }
    
    public static void createRelatedRecords(PRM_Registration_Request__c regRequest, Account acc, Contact cont){
        
        try{
            // Country Mapping for contact
            Map<string,string> countryMapContact = new map<string,string>();
            for(Core_Country_Code_Mapping__c allCountry : Core_Country_Code_Mapping__c.getAll().values()) {
                countryMapContact.put(allCountry.Country_Code__c, allCountry.ISO_Code__c);
            }
            
            //##Populate Account and Contact Fields
            List<Account> duplicateAccountQueueable = new List<Account>{acc};
            acc.Phone = regRequest.PRM_Account_Phone__c;
            if(acc != null)
            {
                if(String.isBlank(acc.Core_User_Defined_Phone_Number__c)){
                    if(String.isNotBlank(regRequest.PRM_Account_Phone__c)){acc.Core_User_Defined_Phone_Number__c = regRequest.PRM_Account_Phone__c ;
                    }
                    else if(String.isNotBlank(regRequest.PRM_Person_Phone_Number__c)){ acc.Core_User_Defined_Phone_Number__c = regRequest.PRM_Person_Phone_Number__c ;
                    }
                }
                if(String.isBlank(acc.Core_User_Defined_Website__c) && String.isNotBlank(regRequest.PRM_Account_URL__c)){acc.Core_User_Defined_Website__c = regRequest.PRM_Account_URL__c;
                }
            }
            if(acc.Core_Intel_Partner_Alliance_PartnerGroup__c == false){
                acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            }
            //Added by Rahul for US596330
            //starts
            if(regRequest.PRM_Partner_Role__c != null && String.isNotBlank(String.valueOf(regRequest.PRM_Partner_Role__c))){
                if(regRequest.PRM_Partner_Role__c.contains(Label.PRM_FPGA_Desginer)){
                    acc.Core_PSG_Account__c = true;
                }
            }
            //ends
            
            cont.FirstName = regRequest.PRM_First_Name__c;
            cont.LastName = regRequest.PRM_Last_Name__c;
            if(regRequest.PRM_Contact_Country__c != null && regRequest.PRM_Contact_Country__c != '')
            {
                if (regRequest.PRM_Contact_Country__c.length() == 2){
                    cont.MailingCountry = countryMapContact.get(regRequest.PRM_Contact_Country__c);
                    cont.MailingCountryCode = countryMapContact.get(regRequest.PRM_Contact_Country__c);
            }else{cont.MailingCountry = regRequest.PRM_Contact_Country__c;cont.MailingCountryCode = regRequest.PRM_Contact_Country__c;   } }
            cont.Core_Preferred_Language__c = regRequest.PRM_Preferred_Language__c;
            cont.Phone = regRequest.PRM_Person_Phone_Number__c;
            
            cont.Core_Profession__c = regRequest.PRM_Profession__c;
            Schema.SObjectType acc1 = Schema.Account.getSObjectType();
            System.enqueueJob(new ContactERPMIntegrationStatusHandler(duplicateAccountQueueable,acc1));
         database.saveresult srList=database.update(cont,false);
		  logEntryMsg+='contact to update'+cont;
			if(srList!=null){		

                if (!srList.isSuccess()) {
                    for (Database.Error e  : srList.getErrors()) {                      
                       logEntryMsg+='Error Occured while updating contacts'+e.getMessage()+'Id -->'+srList.getId(); 
                    }
                }
            }
			
            
            //##create Contact Subscription Association
            Set<String> subscriptionValues =new Set<String>();
            Map<String, PRM_Partner_Subscription__c> subscriptionMap = new Map<String, PRM_Partner_Subscription__c>();
            Map<String,PRM_ContactSubscriptionAssociation__c> existingCSAMap = new Map<String,PRM_ContactSubscriptionAssociation__c>();
            List<PRM_ContactSubscriptionAssociation__c> contactSubscriptionUpsertList = new List<PRM_ContactSubscriptionAssociation__c>();
            Set<String> subscriptionIds = new Set<String>();
            if(String.isNotBlank(regRequest.PRM_Subscriptions__c)){
                subscriptionValues.addall(regRequest.PRM_Subscriptions__c.split(';'));
            }
            if(!subscriptionValues.isEmpty() && subscriptionValues != null){
                for(PRM_Partner_Subscription__c sub : [Select Id,PRM_Subscription_Cd__c,Name from PRM_Partner_Subscription__c where PRM_Subscription_Cd__c IN : subscriptionValues]){
                    subscriptionMap.put(sub.PRM_Subscription_Cd__c,sub);
                    subscriptionIds.add(sub.id);
                }
            }
            //check for duplicate records:
            for(PRM_ContactSubscriptionAssociation__c csa : [Select id,PRM_Status_Reason_Txt__c,PRM_Partner_Subscription_Id__c,PRM_Status_Nm__c,PRM_Contact_Id__c from PRM_ContactSubscriptionAssociation__c where PRM_Partner_Subscription_Id__c in : subscriptionIds and PRM_Contact_Id__c =: cont.id]){existingCSAMap.put(String.valueOf(csa.PRM_Partner_Subscription_Id__c)+String.valueOf(csa.PRM_Contact_Id__c),csa);}
            if(String.isNotBlank(regRequest.PRM_Subscriptions__c)){
                for(String value : regRequest.PRM_Subscriptions__c.split(';')){
                    PRM_ContactSubscriptionAssociation__c cntSubscrAssoc = new PRM_ContactSubscriptionAssociation__c();
                    if(subscriptionMap.containsKey(value)){
                        cntSubscrAssoc.PRM_Partner_Subscription_Id__c = subscriptionMap.get(value).Id;
                        cntSubscrAssoc.PRM_Contact_Id__c = cont.Id;
                        if(existingCSAMap != null && existingCSAMap.get(String.valueOf(subscriptionMap.get(value).Id)+String.valueOf(cont.Id)) != null) { cntSubscrAssoc = existingCSAMap.get(String.valueOf(subscriptionMap.get(value).Id)+String.valueOf(cont.Id)) ; }
                        cntSubscrAssoc.PRM_Status_Nm__c = 'Active';
                        cntSubscrAssoc.PRM_Status_Reason_Txt__c ='Admin Registration';//TWC729-8089 : Adding reason text : NJ
                        contactSubscriptionUpsertList.add(cntSubscrAssoc);
                    }
                }
            }
            System.debug('@JJKK contactSubscriptionUpsertList'+contactSubscriptionUpsertList);
            if(contactSubscriptionUpsertList!= null && contactSubscriptionUpsertList.size()>0) { 
                List<Database.UpsertResult> result = Database.upsert(contactSubscriptionUpsertList, false); 
                for(Database.UpsertResult rs:result){
                    if(!rs.isSuccess()){
                        System.debug('@JJKK re'+rs);
						logEntryMsg+='Error -->'+rs.getErrors()+'Id -->'+rs.getId();
                    }
                }
            } // added database.upsert to help partial update

            
            
            //##create Profile Response
            List<Account> accountsToCreate = new List<Account>();
            accountsToCreate.add(acc);
            List<Contact> contactToInsert = new List<Contact>();
            contactToInsert.add(cont);
            List<PRM_Registration_Request__c> regReqList = new List<PRM_Registration_Request__c>();
            List<PRM_Registration_Request__c> listRegReq = new List<PRM_Registration_Request__c>();
            regReqList.add(regRequest);
            
            if(!regReqList.isEmpty()){
                for(PRM_Registration_Request__c regReq : regReqList){
                    listRegReq.add(new PRM_Registration_Request__c(Id = regReq.id,
                    Sync_Profile_Response__c = true)
                        );// this is to avoind any unintended update request
                }
            }
            System.debug('@@JJ listRegReq'+listRegReq);
            if(!listRegReq.isEmpty()){
               System.enqueueJob(new PRM_CreateAccountAndRelatedRecords.UpdateSyncProfileResponse(listRegReq));
            }
            
        }
        catch(Exception e){
            System.debug('Exception : '+e);
        }
    }
    
    public static void sendAdminRegApprovalEmail(List<Contact> contactList, PRM_Registration_Request__c regReq){
        List<PRM_Language_Culture_Mapping__mdt> lngmapping = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt];
        PRM_Language_Culture_Mapping__mdt langCulEmail;
        for(PRM_Language_Culture_Mapping__mdt mdtRec: lngmapping){
            if(langCulEmail == null && (mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us'))){
                langCulEmail = mdtRec;
            }
            if(mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(regReq.PRM_Contact_Country__c) && mdtRec.MasterLabel == regReq.PRM_Preferred_Language__c){langCulEmail = mdtRec;
            }
        }
        
        for(Contact con : contactList){
            PRM_EmailUtility.EmailNotification objEmailNotify = new PRM_EmailUtility.EmailNotification();
            // PRM_Email_Content_DataSetup__c emailSetup = PRM_Email_Content_DataSetup__c.getValues(con.Core_IPA_PartnerRole__c);
            map<String, String> inputParameters = new map<String, String>();
            inputParameters.put('Account_ID',con.AccountId);
            inputParameters.put('Registration_Request_ID',regReq.Id);
            
            if(langCulEmail != null){
                inputParameters.put('LanguageCulture_MDT',langCulEmail.Id);
            }
            objEmailNotify.InputParameters=inputParameters;
            objEmailNotify.BusinessEvent=System.Label.PRM_Email_Admin_Approval_Event;
            objEmailNotify.Language = con.Core_Preferred_Language__c;
            objEmailNotify.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
            objEmailNotify.PartnerType=System.Label.PRM_CsP;
            objEmailNotify.EmailID= con.Email ;
            
            if(con != null && con.Core_Do_Not_Contact__c  == false)
            {
                
                // //added as part of governor limit story:4380
                PRM_EmailUtility.sendEmail(new List<PRM_EmailUtility.EmailNotification> {objEmailNotify});
                PRM_createAccountandRelatedRecords.linkEmailLogToContact(con.Email);
            }
        }
    }
}