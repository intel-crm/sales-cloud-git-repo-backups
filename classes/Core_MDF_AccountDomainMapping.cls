/****************************************************************************************************************************************
* Class Name  : Core_MDF_AccountDomainMapping
* Version     : 1.0
* Created Date: 29-Jan-2020
* Modification Log :
* Developer                 Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - vaishali      29-Jan-2020        
*****************************************************************************************************************************************/
public without sharing class Core_MDF_AccountDomainMapping {
    
 /****************************************************************************************************************************************
* Class Name  : AcctProgWrapper
* Version     : 1.0
* Created Date: 29-Jan-2020
* Modification Log :
* Developer                 Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - vaishali      29-Jan-2020        
*****************************************************************************************************************************************/   
 
    public without sharing class AcctProgramWrapper{ 
        @AuraEnabled
        public List<ChannelProgram> listOfchannelProg;
        @AuraEnabled
        public Map<String,List<Account>> mapOfAcctCategAndAccts;
        @AuraEnabled
        public Map<String,String> mapOfAcctChanlProgAndDomain;
    }
    
    /*****************************************************************************************************
Method Name:        getLoggedInUserDetails
@return  :          Wrapper
@parameters:        None
Description:        It will get all the details of programs,accounts.
Added By:           Accenture - Vaishali - 29-Jan-2020
******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static acctProgramWrapper getLoggedInUserDetails(){   
        
        acctProgramWrapper wrapperInst = new acctProgramWrapper();
        
        Set<Id> channelProgSet =  Core_MDF_AccountDomainMappingUtility.getAllPrograms().keySet();
        
        Map<String,String> acctChanlProgAndDomainMap = new Map<String,String>();
        Map<String,List<Account>> acctCategAndAcctMap  = new Map<String,List<Account>>();
        List<Account> agencyAcctForAgencyUser = new List<Account>();
        Set<String> grpDevName = new Set<String>();   
        Set<Id> agencyAcctIdLst = new Set<Id>();
        Set<Id> corpAcctIdLst = new Set<Id>();
        Boolean isCorporateAdminuser=false;
        Boolean isAgencyAdminuser=false;

        Id loggedInUserId = UserInfo.getUserId();
        List<groupmember> grpMemLst = [select id,Group.developerName,group.name,UserOrGroupId from groupmember where UserOrGroupId=:loggedInUserId
                                       AND Group.Name LIKE:Label.Core_MDF_Like_for_PGM_Group_Name];
        
        for(GroupMember grp: grpMemLst){
            grpDevName.add(grp.Group.developerName);
        }
        
        for( Core_MDF_Partner_Group_Mapping__c pgm : [Select Core_MDF_Account__c,Core_MDF_Allowed_Email_Domains_txt__c,Core_MDF_Channel_Program__c,
                                                      Core_MDF_Channel_Program__r.Name,Core_MDF_Group_Name__c,Core_MDF_Type_of_Access__c,Core_MDF_Works_For__c
                                                      FROM Core_MDF_Partner_Group_Mapping__c 
                                                      where Core_MDF_Type_of_Access__c=:Label.Core_MDF_External_label_for_PGM
                                                      AND Core_MDF_Group_Name__c IN:grpDevName AND Core_MDF_Channel_Program__c IN:channelProgSet]){                           
              if(pgm.Core_MDF_Works_For__c==null){
                  corpAcctIdLst.add(pgm.Core_MDF_Account__c);
              }
              else if(pgm.Core_MDF_Works_For__c!=null){
                  agencyAcctIdLst.add(pgm.Core_MDF_Account__c);
              }
              
              String acctChannelProg = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c;
              if (!(acctChanlProgAndDomainMap.containsKey(acctChannelProg))) {
                  acctChanlProgAndDomainMap.put(acctChannelProg, pgm.Core_MDF_Allowed_Email_Domains_txt__c);
              }
        }
        wrapperInst.mapOfAcctChanlProgAndDomain = acctChanlProgAndDomainMap;
        
        User user = [select id, contactid,contact.AccountId from User where id=:loggedInUserId];

        Account loggedInUserAcct = [Select id,name from account where id=:user.Contact.AccountId];

        //changes/*****/
        List<Account> corpAccList = new List<Account>();
        List<Account> agencyAccList = new List<Account>();
        List<Id> listOfAcctIds =new List<Id>();
        listOfAcctIds.addAll(corpAcctIdLst);
        listOfAcctIds.addAll(agencyAcctIdLst);
        List<Account> acctList = [Select Id,Name,Core_MDF_CoMarketingActive__c,Core_MDF_CoMarketingAgency__c from Account 
                                     where Id IN:listOfAcctIds AND (Core_MDF_CoMarketingActive__c=true OR Core_MDF_CoMarketingAgency__c=true)];
        for(Account acc:acctList){
            if(acc.Core_MDF_CoMarketingActive__c){
                corpAccList.add(acc);
            }
            else if(acc.Core_MDF_CoMarketingAgency__c){
                agencyAccList.add(acc);
            }
        }
        /******/
        //List<Account> corpAccList = [Select Id,Name,Core_MDF_CoMarketingActive__c from Account where Id IN:corpAcctIdLst AND Core_MDF_CoMarketingActive__c=true];
        //List<Account> agencyAccList = [Select Id,Name,Core_MDF_CoMarketingAgency__c from Account where Id IN:agencyAcctIdLst AND Core_MDF_CoMarketingAgency__c=true];
        //system.debug('corpAccListVD'+corpAccList);
        //system.debug('agencyAccListVD'+agencyAccList);
        
        if(corpAccList!=Null || corpAccList.size()>0){
            for(Account acc:corpAccList){
                if(acc.Id==loggedInUserAcct.Id){
                    isCorporateAdminuser=true;
                    break;//changed
                }
            }
            acctCategAndAcctMap.put(Label.Core_MDF_Corporate_Account_Label,corpAccList);
        }
        if(agencyAccList!=Null || agencyAccList.size()>0){
            for(Account acc:agencyAccList){
                if(acc.Id==loggedInUserAcct.Id){
                    isAgencyAdminuser=true;
                }
            }
        }
        if(isCorporateAdminuser){
            acctCategAndAcctMap.put(Label.Core_MDF_Agency_Account_Label,agencyAccList); 
        }
        else if(isAgencyAdminuser){
            agencyAcctForAgencyUser.add(loggedInUserAcct);
            acctCategAndAcctMap.put(Label.Core_MDF_Agency_Account_Label,agencyAcctForAgencyUser); 
        }
        wrapperInst.mapOfAcctCategAndAccts = acctCategAndAcctMap;
        wrapperInst.listOfchannelProg = Core_MDF_AccountDomainMappingProgram.getAllPrograms().values();
        return wrapperInst;
    }
 /****************************************************************************************************************************************
* Class Name  : AcctProgWrapper
* Version     : 1.0
* Created Date: 29-Jan-2020
* Modification Log :
* Developer                 Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - vaishali      29-Jan-2020        
*****************************************************************************************************************************************/       
        public without sharing class DomainDetailsWrapper{ 
        @AuraEnabled
        public String variant;
        @AuraEnabled
        public String message;
    }
    
    /*****************************************************************************************************
Method Name:        updateEmailDomainInPGM
@return  :          String
@parameters:        Account Id, Channel Program Id, newDomain, Old Domain
Description:        
Added By:           Accenture - Vaishali - 29-Jan-2020
******************************************************************************************************/
    @AuraEnabled
    public static DomainDetailsWrapper updateEmailDomainInPGM(ID acct, ID channelProg, String newDomain, List<String> removedDomainList){
         
        DomainDetailsWrapper domainDetails = new DomainDetailsWrapper();
        Map<Boolean,List<String>> hasActiveContAndListDomainsMap = new Map<Boolean,List<String>>();

        Core_MDF_Partner_Group_Mapping__c pgm = [SELECT Core_MDF_Account__c, Core_MDF_Channel_Program__c, Core_MDF_Group_Id__c, Core_MDF_Type_of_Access__c, Core_MDF_Allowed_Email_Domains_txt__c, Core_MDF_AccountIdGroupName__c 
                                                 FROM Core_MDF_Partner_Group_Mapping__c 
                                                 where Core_MDF_Account__c=:acct AND Core_MDF_Channel_Program__c=:channelProg 
                                                 AND Core_MDF_Type_of_Access__c=:Label.Core_MDF_External_label_for_PGM];      
        
        if(removedDomainList==Null && removedDomainList.size()==0){
            pgm.Core_MDF_Allowed_Email_Domains_txt__c = newDomain;
            database.update(pgm);
            domainDetails.variant = 'success';
            domainDetails.message = System.label.Core_MDF_Toast_Message_with_domains+' '+newDomain;
        }
        else{
            List<String> activeContactDomainsList = checkIfDomainHaveActiveContact(acct,channelProg,removedDomainList);
            if(activeContactDomainsList!=Null && activeContactDomainsList.size()>0){
                domainDetails.variant = 'error';
                domainDetails.message = System.label.Core_MDF_Domains_Cant_be_removed_error_msg+' '+string.join(activeContactDomainsList,';');
            }
            else{
                pgm.Core_MDF_Allowed_Email_Domains_txt__c = newDomain;
                database.update(pgm);
                domainDetails.variant = 'success';
                domainDetails.message = System.label.Core_MDF_Toast_Message_with_domains+' '+newDomain;
            }
        }
        return domainDetails;
    }
    
    /*****************************************************************************************************
Method Name:        checkIfDomainHaveActiveContact
@return  :          String
@parameters:        Account Id, Channel Program Id, newDomain, domains which user is trying to remove
Description:        
Added By:           Accenture - Vaishali - 29-Jan-2020
******************************************************************************************************/
    public static List<String> checkIfDomainHaveActiveContact(Id acctId, Id channelProgId, List<String> domainToCheckForActiveCont){
        
        Set<Contact> contactSet = new Set<Contact>();
        Set<String> domainWithActiveUsersSet = new Set<String>();
        List<String> domainsHaveActiveContactList = new List<String>();
        Map<Boolean,List<String>> hasActiveContAndListDomainsMap = new Map<Boolean,List<String>>();
        
        ChannelProgram cp = [Select Id,Name,Core_MDF_Technical_Program_Name__c From ChannelProgram where id=:channelProgId];
        Core_MDF_ChannelProgram__mdt channelProgramMdt = [Select Core_MDF_Program_Name__c,Core_MDF_Technical_Program_Name__c from Core_MDF_ChannelProgram__mdt
                                                          where Core_MDF_Technical_Program_Name__c=:cp.Core_MDF_Technical_Program_Name__c];
        String abbreviatedProgName = channelProgramMdt.Core_MDF_Program_Name__c;
        List<Contact> contList =[Select Id,AccountId,Email,Core_Audience__c from Contact where AccountId=:acctId];
        if(contList!=Null && contList.size()>0){
            for(Contact cont : contList){
                if(cont.Core_Audience__c.contains(abbreviatedProgName)){
                    contactSet.add(cont);
                }
            }

            if(contactSet!=Null && contactSet.size()>0){
                List<User> userList = [Select Id,IsActive,Email,ContactId FROM User where IsActive=true AND ContactID IN:contactSet]; 

                for(User usr: userList){
                    domainWithActiveUsersSet.add(usr.Email.substringAfter('@'));
                }

                for(String domain : domainToCheckForActiveCont){
                    if(domainWithActiveUsersSet.contains(domain)){
                        domainsHaveActiveContactList.add(domain);
                    }
                }
            }
        }
        return domainsHaveActiveContactList;
    }
}