public class Core_IntegrationOptimization {
    
//
 public static String GetMatchingAccountSFIDfromCIMID(Set<String> cimId,Set<string> erpmAccountNumbers)
    {         
        integer previousRank=0;
        Map<Integer,Id>  sfIdRankMap=new  Map<Integer,Id>();
        List<SFAccountMatchObj> sfMatchAcct=new List<SFAccountMatchObj>();
		Set<Id> acctIds= new Set<Id>();
        Map<Id,DateTime> acctCreateDateMap=new Map<Id,DateTime>();
        Map<Id,List<Core_Account_ERPM_Engagement__c>>  enggAcctNumMap =new Map<Id,List<Core_Account_ERPM_Engagement__c>> ();
        Id inactiveAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();
        List<Account> matchSFaccounts = [SELECT Id,(select Id from Contacts),Core_CIM_ID__c,Core_Intel_Partner_Alliance_PartnerGroup__c,OwnerId,Owner.FirstName,Core_IPA_Partner_Role__c,CreatedDate, RecordTypeId FROM Account WHERE Core_CIM_ID__c  IN : cimId and RecordTypeId <>: inactiveAccountRTId ORDER by CreatedDate asc];
        Map<Id,Integer> acctContactNoMap=GetContactCountfromAccount(matchSFaccounts);
        System.debug('matchSFaccounts.size'+matchSFaccounts.Size());
        if(matchSFaccounts.size() >0) {
            //Proceed only when single account 
            for(Account accts : matchSFaccounts){
                acctIds.add(accts.Id);
                acctCreateDateMap.put(accts.Id,accts.CreatedDate);
            }
            
            for (Core_Account_ERPM_Engagement__c ermEngg :[SELECT Core_Account_Id__c, Core_ERPM_Account_Number__c  FROM Core_Account_ERPM_Engagement__c
                                                           WHERE Core_ERPM_Account_Number__c in : erpmAccountNumbers AND Core_Account_Id__r.Core_Account_Id__c  IN :acctIds]){
                                                               if(enggAcctNumMap.containsKey(ermEngg.Core_Account_Id__c)) 
                                                               {
                                                                   enggAcctNumMap.get(ermEngg.Core_Account_Id__c).add(ermEngg);
                                                               }
                                                               else{
                                                                   enggAcctNumMap.put(ermEngg.Core_Account_Id__c,new List<Core_Account_ERPM_Engagement__c>{ermEngg});
                                                               }
                                                               
                                                           }
            	
            
            if(matchSFaccounts.size() == 1){
                System.debug('Only one account get the SFId'+matchSFaccounts[0].ID);
                return matchSFaccounts[0].ID;
            }
            else{
                System.debug('*****Mulitple Accounts retrieved for CIM Id!Check for account no combination*******');
                //Querying the matching account
                for(Account accts : matchSFaccounts)
                {	 
                    integer rank = CheckRankCriteria(accts);
                    if(rank>previousRank)
                    {
                        previousRank=rank;
                        sfIdRankMap.Clear();
                        sfIdRankMap.put(rank,accts.Id);
                    } 
                    else if(rank==previousRank){
                        //check whether contacts exist for account or not
                        if(acctContactNoMap.ContainsKey(accts.Id) && acctContactNoMap.ContainsKey(sfIdRankMap.Get(previousRank)) && sfIdRankMap.size()>0){
                            if(acctContactNoMap.Get(accts.Id)>acctContactNoMap.Get(sfIdRankMap.Get(previousRank))){
                                sfIdRankMap.Clear();
                                sfIdRankMap.put(rank,accts.Id);
                            }
                            else if(acctContactNoMap.Get(accts.Id)==acctContactNoMap.Get(sfIdRankMap.Get(previousRank))) {
                                if(enggAcctNumMap.ContainsKey(accts.Id) && enggAcctNumMap.ContainsKey(sfIdRankMap.Get(previousRank))){
                                    //Both the account has account number hence consider oldest of account
                                    System.debug('DateCompare '+acctCreateDateMap.get(accts.Id)+'|'+acctCreateDateMap.get(sfIdRankMap.Get(previousRank)));
                                    if(acctCreateDateMap.get(accts.Id)<acctCreateDateMap.get(sfIdRankMap.Get(previousRank))){
                                    sfIdRankMap.Clear();
                                    sfIdRankMap.put(rank,accts.Id);
                                    }
                                }
                                else if(enggAcctNumMap.ContainsKey(accts.Id)){
                                    sfIdRankMap.Clear();
                                    sfIdRankMap.put(rank,accts.Id);
                                }
                            }
                        }
                        else{
                            sfIdRankMap.Clear();
                            sfIdRankMap.put(rank,accts.Id);
                        }
                        
                    }
                    System.debug('Rank'+previousRank);
                }                
            }   
            if(sfIdRankMap!=null && sfIdRankMap.Size()>0){
                System.debug('sfIdRankMap.Get(previousRank)'+sfIdRankMap.Get(previousRank));
                return sfIdRankMap.Get(previousRank);
            }
            
            else{
                return matchSFaccounts[0].Id; 
            }
        }
        return '';
    }
    ///Gets the rank based on the inpue bits.
    //It will convert strinb bits to integer.
    public static integer GetRankedAccounts(String Bits)
    {        
         System.debug('Bits'+Bits);
        double result = 0.0;
        integer i = 7, x = 0;
        while (i >= 0)
        {
            result += math.pow(double.valueof(2.0), double.valueof(i)) * integer.valueof(String.valueOf(Bits).leftPad(8, '0').substring(x, x + 1));
            x++;
            i--;
        }
       return result.intvalue();
    }


    public static Map<Id,Integer> GetContactCountfromAccount(List<Account> accounts){
        Map<Id,Integer>  noOfContacts= new Map<Id,Integer> ();
        for(Account accts :accounts){ 
            noOfContacts.put(accts.Id, accts.Contacts.Size());
        }     
        System.debug('noOfContacts'+noOfContacts);
        return noOfContacts;
    }
    public class SFAccountMatchObj  {
        public string SFId='' ;
        public string IPAFlagExist='0' ;
        public string AccountOwnerExist='0';
        public string PartnerRoleExist='0' ;
        public DateTime AccountCreateTime ;

    }
    
     public static void SendEmail(String emailId, String templateName) {
         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();        
         email.setToAddresses(Label.Multiple_ITP_CIMId_EmailId.Split(','));
         EmailTemplate et = [SELECT Id, Body, Subject  FROM EmailTemplate where DeveloperName =: templateName];        
         email.setSubject(et.Subject);
         //String destAcctNames = String.Join(new List<String>(params.get('DestAcctNames')), ', ');
         et.Body = et.Body.replace('{Email}', emailId);
         //et.Body = et.Body.replace('{ConatctName}', params.get('ContactName') != null ? new List<String>(params.get('ContactName'))[0] : '');  
         //et.Body = et.Body.replace('{CurrAcctName}', params.get('CurrAcctName') != null ? new List<String>(params.get('CurrAcctName'))[0] : '');
         //et.Body = et.Body.replace('{CimIds}', String.join(new List<String>(params.get('MatchCimIds')), ', '));
         //et.Body = et.Body.replace('{DestCimIds}', String.join(new List<String>(params.get('DestCimIds')), ', '));
         email.setHtmlBody(et.Body);
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });        
    }
    
    private static integer CheckRankCriteria(Account acct)
    {
        List<String> parRoleAccount=new List<String>();
        parRoleAccount=acct.Core_IPA_Partner_Role__c!=null ? acct.Core_IPA_Partner_Role__c.Split(';'):null;
        List<String> partnerRoleList = Label.SFPartnerRole.split(';'); 
        SFAccountMatchObj acctMatch=new SFAccountMatchObj();
        //Check for IPA Flag
        if(acct.Core_Intel_Partner_Alliance_PartnerGroup__c){                        
            acctMatch.IPAFlagExist='1';
        }
        //Check For Account Owner
        ///TO:DO
        System.debug('acct.OwnerId'+acct.Owner.FirstName);
        if(String.isNotEmpty(acct.OwnerId) && acct.Owner.FirstName!='Uncovered')
        {
            acctMatch.AccountOwnerExist='1'; 
        }
        //Check for Partner Role
        System.debug('acct.Core_IPA_Partner_Role__c '+acct.Core_IPA_Partner_Role__c );
        
        if (parRoleAccount !=null)
        {
            for(string role : parRoleAccount){
                if(partnerRoleList.Contains(role)){
                    acctMatch.PartnerRoleExist='1';
                    system.debug('matched role'+role);
                    break;
                } 
            }
        }
        //Get the new rank and compare with the old rank.If the ran greater than previous rank.Update to the new rank.
        System.Debug('IPAFlagExist + AccountOwnerExist + PartnerRoleExist' + acctMatch.IPAFlagExist+acctMatch.AccountOwnerExist+acctMatch.PartnerRoleExist);
        return GetRankedAccounts(acctMatch.IPAFlagExist+acctMatch.AccountOwnerExist+acctMatch.PartnerRoleExist);
    }
    
        
}