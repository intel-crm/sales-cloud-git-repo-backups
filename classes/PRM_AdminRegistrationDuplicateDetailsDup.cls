/*Function      : Displaying duplicate account and contact details in the Admin Registration UI 

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nishant      11 November,2019            Displaying duplicate account and contact details in the Admin Registration UI

*********************************************************************************************************************/
public without sharing class PRM_AdminRegistrationDuplicateDetailsDup {
    @AuraEnabled
    public static AccountContactList showAccountsContacts(map<string,string> requestDetails){
        list<Account> accountDetails = new list<Account>();
        list<Contact> contactDetails = new list<Contact>();
        map<string,account> addrAccountMap = new map<string,account>();
        AccountContactList accCntList = new AccountContactList();
        Account accountAssociatedToExistingContact = new Account() ;
        Contact duplicateContactRecord = new Contact();
		String AccountPartnerRole;
        Boolean associatedAccountIsIPA = false;
        Boolean accountMatchSfdc = false;
        String regAccountCimId;
        List<Account> sfdcMatchList = new List<Account>();
        List<Contact> existingContact = new List<Contact>();
        try{
            system.debug(requestDetails);
            String billingStreet;
            set<id> reqAccId = new set<id>();
            String duplicateInfo = requestDetails.get('DuplicateInfo');
            String accountName = requestDetails.get('AccountName').trim();
            String contactEmail = requestDetails.get('ContactEmail').trim();
            String addressLineOne = requestDetails.get('AddressLine1').trim();
            String emailAddr = requestDetails.get('ContactEmail').trim();
            String bizOrgtype = requestDetails.get('BizOrgType').trim();
            
            //Rahul added
            //Querying metatdata for getting 2 digit country code for calling cim
            Map<String,String> countryMap = new map<String,String>();
            for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
                countryMap.put(allCountries.ISO_Code__c, allCountries.Country_Code__c);
            }
            System.debug('countryMap'+countryMap);
            
            Map<String,String> roleTypeMap = new Map<String,String>();
            for(PRM_PartnerRoleTypeMappings__mdt roleTypeReq : [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c,PRM_Partner_Role_Label__c
                                                                from PRM_PartnerRoleTypeMappings__mdt]){
                                                                    roleTypeMap.put(roleTypeReq.PRM_Biz_Org_Type__c,roleTypeReq.PRM_Partner_Role_Label__c);
                                                                }
            
            String partnerRole = roleTypeMap.get(bizOrgtype);
            system.debug('partnerROLE >>>>'+partnerRole);
            if (requestDetails.get('AddressLine2')!=null && requestDetails.get('AddressLine2')!=' ' && requestDetails.get('AddressLine2')!=''){
                billingStreet = addressLineOne+' '+requestDetails.get('AddressLine2').trim();   
            }else{
                billingStreet = addressLineOne; 
            }        
            String billingCity , billingState , billingPostalCode ,billingCountry,billingCountryForCallout ;
            if( requestDetails.get('City')!= null &&  requestDetails.get('City')!= '') { billingCity = requestDetails.get('City').trim(); }
            if( requestDetails.get('State')!= null &&  requestDetails.get('State')!= '') { billingState = requestDetails.get('State').trim(); }
            if( requestDetails.get('PostalCode')!= null &&  requestDetails.get('PostalCode')!= '') { billingPostalCode = requestDetails.get('PostalCode').trim();}
            if( requestDetails.get('Country')!= null &&  requestDetails.get('Country')!= '') { billingCountry = requestDetails.get('Country').trim();}
            system.debug('accountName -->'+accountName);
            System.debug('requestDetails'+requestDetails.get('City'));
            System.debug('billingStreet'+billingStreet);
            
            List<PRM_CIMSearchResults__c> cimResults = new list<PRM_CIMSearchResults__c>();
            List<id> cimAccIds = new list<id>();
            map<id,account> sortedAccounts = new map<id,account>();
            // Search the Account first in SFDC org
            for(Account acc : [select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,toLabel(Core_IPA_Partner_Role__c),Industry from Account where name=:accountName and BillingState=: billingState and BillingPostalCode=:billingPostalCode and BillingCountry=:billingCountry ]){
                if((billingStreet!= null && String.isNotBlank(billingStreet) && acc.BillingStreet!= null && String.isNotBlank(acc.BillingStreet) &&
                    billingStreet.trim().replaceAll('(\\s+)', '') == acc.BillingStreet.trim().replaceAll('(\\s+)', ''))
                   && (billingCity != null && String.isNotBlank(billingCity) &&  acc.BillingCity!= null && String.isNotBlank(acc.BillingCity) && billingCity.trim().replaceAll('(\\s+)', '') == acc.BillingCity.trim().replaceAll('(\\s+)', ''))){
                    //accountDetails.add(acc); 
                    accCntList.accountDupStatus= 'FullDup';
                    //Code for setting status based on existing account
                    //accountDetails =null;
                    reqAccId.add(acc.id);
                    accCntList.displayRequestedAccount = True;
                    accountMatchSfdc = true;
                    sfdcMatchList.add(acc);
                    //accCntList.accountDupStatus= 'NoDup';
                }else{                
                    system.debug('Account not matched --> '+acc.Name +' '+acc.BillingStreet);
                }
            }
            system.debug('addrAccountMap -->'+addrAccountMap);
            system.debug('accountDetails -->'+accountDetails.size());
            system.debug('duplicateInfo -->'+duplicateInfo.length());
            System.debug('billingCountry'+billingCountry);
            System.debug('billingCountry.length'+billingCountry.length());
            
            //Rahul added
            //replacing 3 digit country code to 2 digit country code for calling PRM_UICIMCallout
            if(billingCountry.length() == 3 && countryMap != null){
                billingCountryForCallout = countryMap.get(billingCountry);
            }
            System.debug('billingCountryForCallout'+billingCountryForCallout);
            
            existingContact = [select id,name,email,accountId from contact where email=:contactEmail];
            // Invoke CIM if the Account doesn't exist in SFDC org
            if (accountDetails !=null && accountDetails.size() == 0 ){
                if(duplicateInfo !=null && duplicateInfo.length() == 0 && existingContact.size() ==0){
                    PRM_UICIMCallout uiCallOut= new PRM_UICIMCallout();
                    //cimResults=uiCallOut.getCimResults('Teledyne','700 Chestnut Ridge Rd','109776435','Chestnut Ridge','US',null);
                    cimResults=uiCallOut.getCimResults(accountName,billingStreet,billingPostalCode,billingCity,billingCountryForCallout,billingState,null,null,null,null,emailAddr,partnerRole);                
                    system.debug('CIM LIST VALUES ---> '+cimResults);
                    //cimResults = null;
                    boolean checkForOtherRecords = true ;
                    boolean checkFullDup=false;
                    boolean checkPartDup=false;
                    //if No CIm results found, set dup Status to 'NoDup' default 
                    ////Saba: Added if condition to avoid overwriting dup status in case of exact match in sf
                    if(String.IsBlank(accCntList.accountDupStatus)){
                    	accCntList.accountDupStatus = 'NoDup';
                    }
                    if(cimResults != null && cimResults.size()>0 )
                    {
                        accCntList.displayRequestedAccount = True;
                        for(PRM_CIMSearchResults__c cimSrchResults : cimResults){
                            //cimAccIds.add((id)cimSrchResults.PRM_Account_Id__c);
                            //sortedAccounts.put((id)cimSrchResults.PRM_Account_Id__c,null);
                            //if(checkForOtherRecords)
                            if(!reqAccId.contains((id)cimSrchResults.PRM_Account_Id__c))
                            {
                                cimAccIds.add((id)cimSrchResults.PRM_Account_Id__c);
                                sortedAccounts.put((id)cimSrchResults.PRM_Account_Id__c,null);
                                if(cimSrchResults.PRM_CIM_ID__c!=null && cimSrchResults.PRM_CIM_ID__c!=''){
                                    if(Integer.valueOf(cimSrchResults.PRM_SearchScore_Nbr__c) >= 82) 
                                    {
                                        accCntList.accountDupStatus = 'FullDup';
                                        checkFullDup=true;
                                    }
                                    if(checkFullDup == False){
                                        if(Integer.valueOf(cimSrchResults.PRM_SearchScore_Nbr__c) >= 55) 
                                        {
                                            accCntList.accountDupStatus = 'PartDup';
                                            checkPartDup = true;
                                        }else if(checkPartDup==false)  {
                                            accCntList.accountDupStatus = 'NoDup';
                                        }
                                    }
                                    
                                    //checkForOtherRecords = false; 
                                }
                                else{
                                    accCntList.accountDupStatus = 'FullDup';
                                }
                                
                            }
                        }
                        
                        for(Account acc : [select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,toLabel(Core_IPA_Partner_Role__c),Industry from Account where id IN:cimAccIds]){
                            //accountDetails.add(acc);
                            sortedAccounts.put(acc.id,acc);
                        }
                        accountDetails.addall(sortedAccounts.values());
                    }
                    else{
                        	accountDetails=null;
                    }   
                }
                else{
                    accountDetails=null;
                } 
            }
            //keerthan added as part of DE76928/ DE76773 
            if(accountMatchSfdc /*&& (accountDetails==null || accountDetails.size()==0)*/ && String.IsBlank(duplicateInfo)){
                system.debug('__>inside if'+sfdcMatchList);
                //accountDetails = sfdcMatchList;
                if(accountDetails != null){
                    
                    sfdcMatchList.addAll(accountDetails);
                    accountDetails = sfdcMatchList;                	
                }else{
                    accountDetails = new list<Account>();
                    accountDetails.addAll(sfdcMatchList);
                }
                accCntList.accountDupStatus = 'FullDup';
            }
            
            accCntList.accountList= accountDetails;
            System.debug('-->accountDetails'+accCntList.accountList);
            
            // Search the existing Contact in SFDC org
            if(existingContact.size() > 0){
                for(Contact cntc : existingContact){
                    contactDetails.add(cntc); 
                    accCntList.accountDupStatus= 'NoDup';
                    accCntList.displayRequestedAccount = False;
                    accCntList.accountList = null;
                }
            }
			accCntList.contactList=contactDetails;
            
            if(contactDetails != null && contactDetails.size()>0)
            {
                accCntList.contactDupStatus = 'Duplicate' ;
                accountAssociatedToExistingContact = [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,toLabel(Core_IPA_Partner_Role__c),Industry from Account where id = : contactDetails[0].Accountid ];
                List<ChannelProgram> chProgramList = [select id from ChannelProgram where prm_programCode__c=: System.Label.PRM_IPAEngagement];
                String ipaChannelPgmId ;
                if(ChProgramList != null && ChProgramList.size()>0)
                {
                    ipaChannelPgmId = ChProgramList[0].id;
                }
				Map<String,String> roleTypeMap1 = new Map<String,String>();
				for(PRM_PartnerRoleTypeMappings__mdt roleTypeReq : [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c,PRM_Partner_Role_Label__c	
                                                            from PRM_PartnerRoleTypeMappings__mdt]){
                                                                roleTypeMap1.put(roleTypeReq.PRM_Partner_Role_Label__c, roleTypeReq.PRM_Partner_Role__c);
                                                            }
															String PartnerRole1 = requestDetails.get('PartnerRole');
															system.debug('partner role'+PartnerRole1);
															//String account partner role='';
															for(String str : roleTypeMap1.keyset()){
															  if(str.equals(PartnerRole1)){
																  AccountPartnerRole = roleTypeMap1.get(str);
															    
																 
															  }
                                                                 }
                List<PRM_AccountChannelMembership__c> associatedACMList = new List<PRM_AccountChannelMembership__c>();
                associatedACMList = [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c,PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: accountAssociatedToExistingContact.id and PRM_Channel_Program_Id__c =: ipaChannelPgmId and PRM_Partner_Role__c =: AccountPartnerRole and PRM_Status_Nm__c != 'Inactive' and PRM_Status_Nm__c !='' ];
                accCntList.accountAssociatedToExistingContact = accountAssociatedToExistingContact;
                accCntList.duplicateContactRecord = contactDetails[0];
                if(associatedACMList != null && associatedACMList.size()>0)
                {
                    associatedAccountIsIPA = true;
                }
            }
            else
            {
                accCntList.contactDupStatus = 'NoDuplicate' ;
                accCntList.accountAssociatedToExistingContact = null;
                duplicateContactRecord = null ;
            }
            accCntList.associatedAccountIsIPA = associatedAccountIsIPA;
            system.debug('accountAssociatedToExistingContact found -->'+accCntList.accountAssociatedToExistingContact);
            system.debug('AccountContactList -->'+accCntList);
        } 
        catch(Exception e){
            
            PRM_ErrorUtilityClass.logError(e);
            system.debug('exc::'+e.getMessage());
            
        }
        return accCntList;
    }
    // Wrapper class for the account and contact details
    public class AccountContactList {
        
        @AuraEnabled
        public list<Account> accountList = new list<Account>();
        @AuraEnabled
        public list<Contact> contactList = new list<Contact>();
        @AuraEnabled
        public String accountDupStatus ;
        @AuraEnabled
        public String contactDupStatus ;
        @AuraEnabled
        public Account accountAssociatedToExistingContact ;
        @AuraEnabled
        public Contact duplicateContactRecord ;
        @AuraEnabled
        public Boolean associatedAccountIsIPA ;
        @AuraEnabled
        public Boolean displayRequestedAccount ;
        
    }
}