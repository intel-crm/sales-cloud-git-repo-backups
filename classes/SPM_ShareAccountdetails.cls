/**************************************************************************************
Apex Class Name:  SPM_ShareAccountdetails
Version     : 1.0 
Created Date: 24 Aug 2023
Function    : 
Test Class Name: SPM_ShareAccountdetailsTest 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay					  24/08/2023			  Queried Version
*************************************************************************************/
global class SPM_ShareAccountdetails implements Database.Batchable<SPM_Account_Detail__c>,Database.Stateful  {
    public boolean uncoveredAccount= false;
    public string conditionForAccountQuery = '';
    public static string intelLed = Core_CRM_Utility.getCRMLabel('Intel_Led');
    public static string partnerLed = Core_CRM_Utility.getCRMLabel('Partner_led');
    public static string uncovered = Core_CRM_Utility.getCRMLabel('Uncovered');
    public static string otherLedAccount = Core_CRM_Utility.getCRMLabel('Other_Led_Account');
    public Map<String,List<SPM_Security_Mapping__c>> securityMap = new Map<String,List<SPM_Security_Mapping__c>>();
    public Map<String,List<SPM_Security_Mapping__c>> regionalLeadMap = new Map<String,List<SPM_Security_Mapping__c>>();
    public Map<String,List<SPM_Security_Mapping__c>> uncoveredAccountUserView = new Map<String,List<SPM_Security_Mapping__c>>();
    public Map<String,List<SPM_Security_Mapping__c>> uncoveredAccountUserViewIntelLed = new Map<String,List<SPM_Security_Mapping__c>>();
    public List<String> unCoveredAccID = new List<String>();
    public static Map<String, List<Id>> categoryShareMap = new Map<String,List<Id>>();
    
    public integer batchSize = 1;
    public set<String> checkSecurity = new set<String>();
    public set<String> checkSecurityIntelLed = new set<String>();
    
    public list<Id> AccWWIDs = new list<id>();//TWC3123-6456
    public boolean batchFromFlow = false;//TWC3123-6456
    public list<Id> AccountDetailIds = new list<id>();//TWC3123-6456
    
    // Constructor for the Account owner is not null
    public SPM_ShareAccountdetails(boolean uncoveredAccount, string conditionForAccountQuery,integer batchSize) {
        this.uncoveredAccount = uncoveredAccount;
        this.conditionForAccountQuery = conditionForAccountQuery;   
        this.batchSize = batchSize;
        
    }
    // Constructor for the Account owner is null
    public SPM_ShareAccountdetails(boolean uncoveredAccount, string conditionForAccountQuery,Map<String,List<SPM_Security_Mapping__c>> uncoveredAccountUserView,Map<String,List<SPM_Security_Mapping__c>> uncoveredAccountUserViewIntelLed,integer batchSize,List<String> unCoveredAccID) {
        this.uncoveredAccount = uncoveredAccount;
        this.conditionForAccountQuery = conditionForAccountQuery;   
        this.uncoveredAccountUserView = uncoveredAccountUserView;
        this.uncoveredAccountUserViewIntelLed = uncoveredAccountUserViewIntelLed;
        this.batchSize = batchSize;
        this.unCoveredAccID = unCoveredAccID;
    }
    // Constructor for the Account owner is not null from flow //TWC3123-6456
    public SPM_ShareAccountdetails(boolean uncoveredAccount, boolean batchFromFlow, string conditionForAccountQuery,list<id> acountOwnerWWIdlst, list<id> accountDetailIdlst, integer batchSize) {
        this.uncoveredAccount = uncoveredAccount;
        this.batchFromFlow = batchFromFlow;
        this.conditionForAccountQuery = conditionForAccountQuery;
        this.AccWWIDs  = acountOwnerWWIdlst;
        this.AccountDetailIds = accountDetailIdlst;
        this.batchSize = batchSize;
    }
    
    // Get the Account details based on the Dynamic query
    global Iterable<SPM_Account_Detail__c> start(Database.BatchableContext bc) {  
        String query = 'SELECT Id, Account_Owner__c,Account_Owner_WWID__c,SPM_Customer_ID__c,SPM_Customer_ID__r.Core_Region__c,SPM_Customer_ID__r.Coverage__c,SPM_Customer_ID__r.Core_Regional_Customer_Id__c, Region__c,Regional_Lead__c, Category__c,DR__c,VP__c,GM__c,TA_VP__c,TA_GM__c FROM SPM_Account_Detail__c ' + conditionForAccountQuery ;  
        //system.debug('-query--'+query);
        
        if(uncoveredAccount)
            List<String> intelLedCovered = unCoveredAccID;        
        
        return (Iterable<SPM_Account_Detail__c>)Database.query(query);  
    }  
    
    
    global void execute(Database.BatchableContext BC, List<SPM_Account_Detail__c> scope) {
        
        
        Map< string ,SPM_Account_Detail__Share> shareAccount = new Map<string,SPM_Account_Detail__Share>();
        Map<string ,SPM_Account_Detail__c> updateRolesInAccount = new Map<string ,SPM_Account_Detail__c>();       
        
        
        //Variables for Customer details share
        Map<string , SPM_Customer_Detail__Share> customerShare = new Map<string , SPM_Customer_Detail__Share>();
        Map<string , SPM_Customer_Category__Share> customercategory = new Map<string , SPM_Customer_Category__Share>();
        List<String> customerIdUsershare = new List<String>();
        Set<Id> customerId = new Set<Id>();
        List<String> customerCategoryCheck = new List<String>();
        Map<String ,List<Id>> uncoveredAccess = new Map<String ,List<Id>>();
        
        //Variables for Regional Customer share
        Map<string , SPM_Regional_Customer__Share> regionalShare = new Map<string , SPM_Regional_Customer__Share>();
        List<String> regionalIdUsershare = new List<String>();
        Set<Id> regionalCustId = new Set<Id>();
        try{
            set<string> uniqueManagerSet = new set<string>();
            // Create a Security Map to share account details
            if(securityMap.size() == 0  ){
                
                Map<String,List<SPM_Security_Mapping__c>> securityMapTemp = new Map<String,List<SPM_Security_Mapping__c>>();
                
                for(SPM_Security_Mapping__c  tempSecurity : [select Id,TA__c, Account_Owner__c,Account_Owner__r.Core_WWID__c, Customer_Category__c,Region__c,Role__c,Manager__c from SPM_Security_Mapping__c where Account_Owner__r.IsActive  = true and Manager__r.IsActive = true ]){
                    if(!uncoveredAccount){
                        if(!securityMapTemp.containsKey(tempSecurity.Account_Owner__r.Core_WWID__c))
                            securityMapTemp.put(tempSecurity.Account_Owner__r.Core_WWID__c, new List<SPM_Security_Mapping__c>());
                        
                        securityMapTemp.get(tempSecurity.Account_Owner__r.Core_WWID__c).add(tempSecurity);
                        securityMap =securityMapTemp;
                    }
                    
                    if(tempSecurity.Role__c == 'Regional Lead'){
                        
                        if(!regionalLeadMap.containsKey(tempSecurity.Region__c)) {
                            regionalLeadMap.put(tempSecurity.Region__c, new List<SPM_Security_Mapping__c>{tempSecurity});
                            
                        }
                        else if(!uniqueManagerSet.contains(tempSecurity.Region__c+'_'+tempSecurity.Manager__c)) {
                            regionalLeadMap.get(tempSecurity.Region__c).add(tempSecurity);
                            uniqueManagerSet.add(tempSecurity.Region__c+'_'+tempSecurity.Manager__c);
                        } 
                    }                    
                }             
            } 
            //system.debug('Inside security map size:'+securityMap.size());
            //Check whether account details are shared to user       
            Map<id,SPM_Account_Detail__c> accountDetaislID = new Map<Id,SPM_Account_Detail__c>(scope);
            List<String> accountIdUser = getCurrentAccountOwner(accountDetaislID.keySet());
            
            for(SPM_Account_Detail__c accountDetail : scope){
                customerId.add(accountDetail.SPM_Customer_ID__c);
                regionalCustId.add(accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c);
            }
            
            uncoveredAccess = checkUncoveredsharing();
            
            customerIdUsershare = getCurrentCustomerOwner(customerId);
            
            regionalIdUsershare = getRegionalCustomerOwner(regionalCustId);
            
            customerCategoryCheck = getCategoryOwner();
            
             
            //Iterate through each account to update access
            for (SPM_Account_Detail__c accountDetail : scope) {
                //system.debug('ACCOUNTDETAIL IS:'+accountDetail);
                boolean isIntelLed = false ;
                boolean isPartnerUncoverd = false;
                List<SPM_Security_Mapping__c> userToShareIds = new List<SPM_Security_Mapping__c>();
                //check Account is Partner-Led or Uncovered
                if(uncoveredAccess.containskey(accountDetail.SPM_Customer_ID__c+'_'+accountDetail.Category__c+'_'+partnerLed) || uncoveredAccess.containskey(accountDetail.SPM_Customer_ID__c+'_'+accountDetail.Category__c+'_'+uncovered) || 
                   uncoveredAccess.containskey(accountDetail.SPM_Customer_ID__c+'_'+accountDetail.Category__c+'_'+otherLedAccount)){
                       isPartnerUncoverd = true;
                       if(!uncoveredAccount)
                           unCoveredAccID.add(accountDetail.id);                    
                   }
                if(categoryShareMap.containskey(accountDetail.SPM_Customer_ID__c+'_'+accountDetail.Category__c+'_'+intelLed))
                    isIntelLed = true;
                
                //Covered account(Account Owner is not null) : Check user is present in security Map
                if (securityMap.containsKey(accountDetail.Account_Owner_WWID__c) && !uncoveredAccount ) {
                    userToShareIds = securityMap.get(accountDetail.Account_Owner_WWID__c);
                    
                    // Access Account detail
                    SPM_Account_Detail__Share shareAcc = new SPM_Account_Detail__Share();
                    shareAcc.ParentId = accountDetail.Id;
                    shareAcc.UserOrGroupId = userToShareIds[0].Account_Owner__c;
                    shareAcc.AccessLevel = 'Read';  
                    
                    if(!accountIdUser.contains(accountDetail.id+'_'+userToShareIds[0].Account_Owner__c) && !shareAccount.containsKey(accountDetail.id+'_'+userToShareIds[0].Account_Owner__c))
                        shareAccount.put(accountDetail.id+'_'+userToShareIds[0].Account_Owner__c,shareAcc);
                    
                    //Access to Customer detail
                    SPM_Customer_Detail__Share shareCust = new SPM_Customer_Detail__Share();
                    shareCust.ParentId = accountDetail.SPM_Customer_ID__c;
                    shareCust.UserOrGroupId = userToShareIds[0].Account_Owner__c;
                    shareCust.AccessLevel = 'Read'; 
                    
                    if(!customerIdUsershare.contains(accountDetail.SPM_Customer_ID__c+'_'+userToShareIds[0].Account_Owner__c) && !customerShare.containsKey(accountDetail.SPM_Customer_ID__c+'_'+userToShareIds[0].Account_Owner__c))
                        customerShare.put(accountDetail.SPM_Customer_ID__c+'_'+userToShareIds[0].Account_Owner__c,shareCust);
                    
                    //Access to Regional customer
                    if(accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c != null){
                        SPM_Regional_Customer__Share shareRegional= new SPM_Regional_Customer__Share();
                        shareRegional.ParentId = accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c;
                        shareRegional.UserOrGroupId = userToShareIds[0].Account_Owner__c;
                        shareRegional.AccessLevel = 'Read'; 
                        
                        if(!regionalIdUsershare.contains(accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c+'_'+userToShareIds[0].Account_Owner__c) && !regionalShare.containsKey(accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c+'_'+userToShareIds[0].Account_Owner__c))
                            regionalShare.put(accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c+'_'+userToShareIds[0].Account_Owner__c,shareRegional);
                    }
                }
                
                //Uncovered account(Account Owner is null and custmore'Partner Led', 'Uncovered' ) : Check user is present in Uncovered security Map
                if (uncoveredAccountUserView.containsKey(accountDetail.SPM_Customer_ID__r.Core_Region__c+'_'+accountDetail.Category__c) && uncoveredAccount && isPartnerUncoverd && uncoveredAccountUserView.get(accountDetail.SPM_Customer_ID__r.Core_Region__c+'_'+accountDetail.Category__c) != null) 
                    userToShareIds.addAll(uncoveredAccountUserView.get(accountDetail.SPM_Customer_ID__r.Core_Region__c+'_'+accountDetail.Category__c));
                //system.debug('userToShareIds-2-'+userToShareIds);
                //Uncovered account(Account Owner is null and custmore 'Intel Led')
                if(uncoveredAccount && isIntelLed && uncoveredAccountUserViewIntelLed.containsKey(accountDetail.SPM_Customer_ID__c))
                    userToShareIds.addAll(uncoveredAccountUserViewIntelLed.get(accountDetail.SPM_Customer_ID__c));
                //WW45 Sharing for regional lead
                //system.debug('REGIONALLEADMAP 233 '+accountDetail.SPM_Customer_ID__r.Core_Region__c+':'+regionalLeadMap.get(accountDetail.SPM_Customer_ID__r.Core_Region__c));
                if( regionalLeadMap.containsKey(accountDetail.SPM_Customer_ID__r.Core_Region__c) && regionalLeadMap.get(accountDetail.SPM_Customer_ID__r.Core_Region__c) != null)
                    userToShareIds.addAll(regionalLeadMap.get(accountDetail.SPM_Customer_ID__r.Core_Region__c));
                //system.debug('userToShareIds3--'+userToShareIds);
                //Iterate through a list of users to share Account details
                
                for (SPM_Security_Mapping__c userToShareId : userToShareIds) {
                    //system.debug('SECURITY REC:'+userToShareId);
                    SPM_Account_Detail__Share share = new SPM_Account_Detail__Share();
                    share.ParentId = accountDetail.Id;
                    share.UserOrGroupId = userToShareId.Manager__c;
                    share.AccessLevel = 'Read';
                    if(userToShareId.Role__c == 'Regional Lead')
                    {
                        share.AccessLevel = 'Edit';
                    }
                    
                    SPM_Account_Detail__Share shareTA = new SPM_Account_Detail__Share(); //TWC3123-6460
                    if(userToShareId.TA__c<>null) { 
                        shareTA.ParentId = accountDetail.Id;
                        shareTA.UserOrGroupId = userToShareId.TA__c;
                        shareTA.AccessLevel = 'Read';
                    }
                    
                    //Share if Partner-led and intel-led are from same region
                    boolean checkNotIntelLet = (uncoveredAccount || isIntelLed);
                    //Check user already present in the Account detail-sharing
                    if(!accountIdUser.contains(accountDetail.id+'_'+userToShareId.Manager__c) && !shareAccount.containsKey(accountDetail.id+'_'+userToShareId.Manager__c) && checkNotIntelLet)
                         shareAccount.put(accountDetail.id+'_'+userToShareId.Manager__c,share);
                    
                    
                    //Check TA user already present in the Account detail-sharing --TWC3123-6460
                    if(userToShareId.TA__c<>null && !accountIdUser.contains(accountDetail.id+'_'+userToShareId.TA__c) && !shareAccount.containsKey(accountDetail.id+'_'+userToShareId.TA__c) && checkNotIntelLet)
                        shareAccount.put(accountDetail.id+'_'+userToShareId.TA__c,shareTA);
                    
                    //Access to Customer detail
                    SPM_Customer_Detail__Share shareCust = new SPM_Customer_Detail__Share();
                    shareCust.ParentId = accountDetail.SPM_Customer_ID__c;
                    shareCust.UserOrGroupId = userToShareId.Manager__c;
                    shareCust.AccessLevel = 'Read';
                    if(userToShareId.Role__c == 'Regional Lead')
                        shareCust.AccessLevel = 'Edit'; 
                    
                    SPM_Customer_Detail__Share shareCustTA = new SPM_Customer_Detail__Share();//TWC3123-6460
                    if(userToShareId.TA__c<>null) { 
                        shareCustTA.ParentId = accountDetail.SPM_Customer_ID__c;
                        shareCustTA.UserOrGroupId = userToShareId.TA__c;
                        shareCustTA.AccessLevel = 'Read';
                    }
                    
                    //Check user already present in the Customer detail-sharing
                    if(!customerIdUsershare.contains(accountDetail.SPM_Customer_ID__c+'_'+userToShareId.Manager__c) && !customerShare.containsKey(accountDetail.SPM_Customer_ID__c+'_'+userToShareId.Manager__c) && checkNotIntelLet)
                        customerShare.put(accountDetail.SPM_Customer_ID__c+'_'+userToShareId.Manager__c,shareCust);
                    
                    //Check user already present in the Customer detail-sharing --TWC3123-6460
                    if(userToShareId.TA__c<>null && !customerIdUsershare.contains(accountDetail.SPM_Customer_ID__c+'_'+userToShareId.TA__c) && !customerShare.containsKey(accountDetail.SPM_Customer_ID__c+'_'+userToShareId.TA__c) && checkNotIntelLet)
                        customerShare.put(accountDetail.SPM_Customer_ID__c+'_'+userToShareId.TA__c,shareCustTA);
                    
                    //Access to Regional customer
                    if(accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c != null){
                        SPM_Regional_Customer__Share shareRegional= new SPM_Regional_Customer__Share();
                        shareRegional.ParentId = accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c;
                        shareRegional.UserOrGroupId = userToShareId.Manager__c;
                        shareRegional.AccessLevel = 'Edit'; 
                        if(userToShareId.Role__c == 'Regional Lead')
                            shareRegional.AccessLevel = 'Edit';   
                        
                        
                        if(!regionalIdUsershare.contains(accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c+'_'+userToShareId.Manager__c) && !regionalShare.containsKey(accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c+'_'+userToShareId.Manager__c) && checkNotIntelLet)
                            regionalShare.put(accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c+'_'+userToShareId.Manager__c,shareRegional);
                        
                        if(userToShareId.TA__c<>null) { //TWC3123-6460
                            SPM_Regional_Customer__Share shareRegionalTA= new SPM_Regional_Customer__Share();
                            shareRegionalTA.ParentId = accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c;
                            shareRegionalTA.UserOrGroupId = userToShareId.TA__c;
                            shareRegionalTA.AccessLevel = 'Edit'; 
                            
                            if(!regionalIdUsershare.contains(accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c+'_'+userToShareId.TA__c) && !regionalShare.containsKey(accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c+'_'+userToShareId.TA__c) && checkNotIntelLet)
                                regionalShare.put(accountDetail.SPM_Customer_ID__r.Core_Regional_Customer_Id__c+'_'+userToShareId.TA__c,shareRegionalTA);
                        }
                    }
                    List<Id> custCatIds = new List<Id>();
                    //Share Customer category
                    if(isIntelLed)
                        custCatIds = categoryShareMap.get(accountDetail.SPM_Customer_ID__c+'_'+accountDetail.Category__c+'_'+intelLed);
                    
                    if(isPartnerUncoverd && checkNotIntelLet && uncoveredAccess.containskey(accountDetail.SPM_Customer_ID__c+'_'+accountDetail.Category__c+'_'+partnerLed))
                        custCatIds = uncoveredAccess.get(accountDetail.SPM_Customer_ID__c+'_'+accountDetail.Category__c+'_'+partnerLed);
                    
                    if(isPartnerUncoverd && checkNotIntelLet && uncoveredAccess.containskey(accountDetail.SPM_Customer_ID__c+'_'+accountDetail.Category__c+'_'+uncovered))
                        custCatIds = uncoveredAccess.get(accountDetail.SPM_Customer_ID__c+'_'+accountDetail.Category__c+'_'+uncovered);
                    
                    if(isPartnerUncoverd && checkNotIntelLet && uncoveredAccess.containskey(accountDetail.SPM_Customer_ID__c+'_'+accountDetail.Category__c+'_'+otherLedAccount))
                        custCatIds = uncoveredAccess.get(accountDetail.SPM_Customer_ID__c+'_'+accountDetail.Category__c+'_'+otherLedAccount);
                    for( Id categoryId: custCatIds){
                        SPM_Customer_Category__Share shareCate = new SPM_Customer_Category__Share();
                        shareCate.ParentId = categoryId;
                        shareCate.UserOrGroupId = userToShareId.Manager__c;
                        shareCate.AccessLevel = 'Read'; 
                        if(userToShareId.Role__c == 'Regional Lead')
                            shareCate.AccessLevel = 'Edit';   
                        
                        if(!customerCategoryCheck.contains(categoryId+'_'+userToShareId.Manager__c) && !customercategory.containsKey(categoryId+'_'+userToShareId.Manager__c))
                            customercategory.put(categoryId+'_'+userToShareId.Manager__c , shareCate);
                        
                        if(userToShareId.TA__c<>null) { //TWC3123-6460
                            SPM_Customer_Category__Share shareCateTA = new SPM_Customer_Category__Share();
                            shareCateTA.ParentId = categoryId;
                            shareCateTA.UserOrGroupId = userToShareId.TA__c;
                            shareCateTA.AccessLevel = 'Read'; 
                            
                            if(!customerCategoryCheck.contains(categoryId+'_'+userToShareId.TA__c) && !customercategory.containsKey(categoryId+'_'+userToShareId.TA__c))
                                customercategory.put(categoryId+'_'+userToShareId.TA__c , shareCateTA);
                        }
                    }
                    
                    
                    //If it's Covered account then update DR ,VP , GM,TA-VP ,TA-GM ,TA-CM and Regional Lead in Account details
                    if(!uncoveredAccount){
                        SPM_Account_Detail__c tempAccountDetails = new SPM_Account_Detail__c();
                        if(updateRolesInAccount.containsKey(accountDetail.id))
                            tempAccountDetails = updateRolesInAccount.get(accountDetail.id);
                        else 
                            tempAccountDetails = accountDetail;
                        boolean checkToupdate = false;
                        if(isIntelLed || (isPartnerUncoverd && accountDetail.SPM_Customer_ID__r.Core_Region__c.toLowerCase() == userToShareId.Region__c.toLowerCase()))
                            checkToupdate = true;                                 
                        if(userToShareId.Role__c == 'DR' && checkToupdate )
                            accountDetail.DR__c = userToShareId.Manager__c;
                        if(userToShareId.Role__c == 'VP' && checkToupdate ) {
                            accountDetail.VP__c = userToShareId.Manager__c;
                            //TWC3123-6460--start
                            if(userToShareId.TA__c <> null) {
                                accountDetail.TA_VP__c = userToShareId.TA__c;
                            }
                        }
                        if(userToShareId.Role__c == 'GM' && checkToupdate) {
                            accountDetail.GM__c = userToShareId.Manager__c;
                            if(userToShareId.TA__c <> null){
                                accountDetail.TA_GM__c = userToShareId.TA__c;
                            }
                        }
                        //TWC3123-6460--end
                        
                        //if(userToShareId.Role__c == 'Regional Lead' && accountDetail.SPM_Customer_ID__r.Core_Region__c.toLowerCase() == userToShareId.Region__c.toLowerCase())
                        //  accountDetail.Regional_Lead__c = userToShareId.Manager__c;
                        //system.debug('SECURITY:::'+userToShareId+'INTELLED:::'+isIntelLed+'ROLE:::'+userToShareId.Role__c+'CHECKTOUPDATE:::'+checkToupdate+'MANAGER:::'+userToShareId.Manager__c);
                        updateRolesInAccount.put(accountDetail.id,tempAccountDetails);
                        
                        // Create a Security map for the Uncovered account
                        // Need to Share the account details with users who have the same Region and category.
                        // Initially updating covered Account details and based to covered details sharing Uncovered account which is having same region category
                        
                        //This Map user to share Customer is 'Partner Led' and 'Uncovered'
                        if(!uncoveredAccountUserView.containsKey(accountDetail.SPM_Customer_ID__r.Core_Region__c+'_'+accountDetail.Category__c))
                            uncoveredAccountUserView.put(accountDetail.SPM_Customer_ID__r.Core_Region__c+'_'+accountDetail.Category__c, new List<SPM_Security_Mapping__c>());
                        
                        if(!checkSecurity.contains(accountDetail.SPM_Customer_ID__r.Core_Region__c+'_'+accountDetail.Category__c+'_'+userToShareId.Manager__c) && accountDetail.SPM_Customer_ID__r.Core_Region__c.toLowerCase() == userToShareId.Region__c.toLowerCase()){
                            uncoveredAccountUserView.get(accountDetail.SPM_Customer_ID__r.Core_Region__c+'_'+accountDetail.Category__c).add(userToShareId);
                            
                            checkSecurity.add(accountDetail.SPM_Customer_ID__r.Core_Region__c+'_'+accountDetail.Category__c+'_'+userToShareId.Manager__c);
                        }
                        //This Map user to share Customer is 'Intel led'
                        if(categoryShareMap.containsKey(accountDetail.SPM_Customer_ID__c+'_'+accountDetail.Category__c+'_'+intelLed)){
                            if(!uncoveredAccountUserViewIntelLed.containsKey(accountDetail.SPM_Customer_ID__c))
                                uncoveredAccountUserViewIntelLed.put(accountDetail.SPM_Customer_ID__c, new List<SPM_Security_Mapping__c>());
                            
                            if(!checkSecurityIntelLed.contains(accountDetail.SPM_Customer_ID__c+'_'+userToShareId.Manager__c))
                                uncoveredAccountUserViewIntelLed.get(accountDetail.SPM_Customer_ID__c).add(userToShareId);
                            
                            checkSecurityIntelLed.add(accountDetail.SPM_Customer_ID__c+'_'+userToShareId.Manager__c);
                        }
                    }
                }
                
                
            }
            //system.debug('updateRolesInAccount --'+updateRolesInAccount.size());
            if(!updateRolesInAccount.isEmpty())
                update updateRolesInAccount.values();
            
            //system.debug('shareAccount records --'+shareAccount.size());
            if(!shareAccount.isEmpty())
                insert shareAccount.values();
            //system.debug('customerShare records --'+customerShare.size());
            if(!customerShare.isEmpty())
                insert customerShare.values();            
            //system.debug('regionalShare records --'+regionalShare.size());
            if(!regionalShare.isEmpty())
                insert regionalShare.values();
            
            if(!customercategory.isEmpty())
                insert customercategory.values();
            
        } catch (Exception e) {
            Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = 'Failure : ########### - '+e.getStackTraceString()+' Cause'+e.getMessage(),Core_Class_Name__c ='SPM_ShareAccountdetails',Core_Method_Name__c ='Bacth execute',Core_IPS_Object_Name__c = 'Sharing Object');
            insert excep;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        // Calling the same batch to update access to the Uncovered account
        if(!uncoveredAccount && batchFromFlow == false){ //TWC3123-6456-added batchFromFlow boolean check
            SPM_ShareAccountdetails batchForUncovered = new SPM_ShareAccountdetails(true,'Where  (Account_Owner_WWID__c = null OR ID IN:intelLedCovered )   and SPM_Customer_ID__c != null and CRM_CST_Is_Active_Planning_Period__c=true' ,uncoveredAccountUserView,uncoveredAccountUserViewIntelLed,batchSize, unCoveredAccID);
            Database.executeBatch(batchForUncovered,batchSize);
        } 
    }
    //creating Security map for covered account
    public static Map<String,List<SPM_Security_Mapping__c>> getSecurtiyMape() {
        Map<String,List<SPM_Security_Mapping__c>> securityMapTemp = new Map<String,List<SPM_Security_Mapping__c>>();
        //  Map<String,List<SPM_Security_Mapping__c>> regionalLeadMap = new Map<String,List<SPM_Security_Mapping__c>>();
        //set<id> uniqueManagerSet = new set<id>();
        for(SPM_Security_Mapping__c  tempSecurity : [select Id,TA__c, Account_Owner__c,Account_Owner__r.Core_WWID__c, Customer_Category__c,Region__c,Role__c,Manager__c from SPM_Security_Mapping__c where Account_Owner__r.IsActive  = true and Manager__r.IsActive = true ]){
            if(!securityMapTemp.containsKey(tempSecurity.Account_Owner__r.Core_WWID__c))
                securityMapTemp.put(tempSecurity.Account_Owner__r.Core_WWID__c, new List<SPM_Security_Mapping__c>());
            
            securityMapTemp.get(tempSecurity.Account_Owner__r.Core_WWID__c).add(tempSecurity);
            
            
        }
        
        return securityMapTemp;
    }
    //check user is present in the account sharing details as the owner
    public List<String> getCurrentAccountOwner(set<Id> accountId){
        List<String> currentOwnerId = new List<String>();
        for(SPM_Account_Detail__Share userInAccShare : [select id ,ParentId,RowCause,UserOrGroupId from SPM_Account_Detail__Share where ParentId IN: accountId and RowCause = 'Owner' and parent.CRM_CST_Is_Active_Planning_Period__c=true])
            currentOwnerId.add(userInAccShare.ParentId+'_'+userInAccShare.UserOrGroupId);            
        
        //system.debug('getCurrentAccountOwner ='+currentOwnerId);
        return currentOwnerId;
    }
    
    //check user is present in the account sharing details as the owner
    public List<String> getCurrentCustomerOwner(set<Id> customerId){
        List<String> currentOwnerId = new List<String>();
        for(SPM_Customer_Detail__Share userInAccShare : [select id ,ParentId,RowCause,UserOrGroupId from SPM_Customer_Detail__Share  where ParentId IN: customerId and RowCause = 'Owner' and parent.CRM_CST_IsActive_Planning_Period__c=true])
            currentOwnerId.add(userInAccShare.ParentId+'_'+userInAccShare.UserOrGroupId); 
        
        //system.debug('getCurrentCustomerOwner ='+currentOwnerId);
        return currentOwnerId;
    }
    
    public List<String> getRegionalCustomerOwner( set<Id> recordIds){
        List<String> currentOwnerId = new List<String>();
        for(SPM_Regional_Customer__Share  userInAccShare : [select id ,ParentId,RowCause,UserOrGroupId from SPM_Regional_Customer__Share   where ParentId IN: recordIds and RowCause = 'Owner' and parent.CRM_CST_Is_Active_Planning_Period__c=true])
            currentOwnerId.add(userInAccShare.ParentId+'_'+userInAccShare.UserOrGroupId);  
        
        // system.debug('getRegionalCustomerOwner ='+currentOwnerId);
        return currentOwnerId;
    }
    
    public List<String> getCategoryOwner(){
        List<String> currentCategoryOwnerId = new List<String>();
        for(SPM_Customer_Category__Share  userInAccShare : [select id ,ParentId,RowCause,UserOrGroupId from SPM_Customer_Category__Share where  RowCause = 'Owner'and Parent.CRM_CST_Is_Active_Planning_Period__c = true])
            currentCategoryOwnerId.add(userInAccShare.ParentId+'_'+userInAccShare.UserOrGroupId);  
        
        // system.debug('getCategoryOwner ='+currentCategoryOwnerId);
        return currentCategoryOwnerId;
    }
    
    public static Map<String ,List<Id>> checkUncoveredsharing(){
        //system.debug('Inside CHECKUNCOVERED');
        //string recommendation = Core_CRM_Utility.getCRMLabel('CST_Check_Recommendation_for_uncovered').toLowerCase();//commented as part of TWC3123-6021
        Map<String ,List<Id>> customerGiveAccess = new Map<String, List<Id>>();
        for(SPM_Customer_Category__c  checkCust : [select id,Customer_Detail__c,Coverage__c, Category__c,Core_Recommendation__c from SPM_Customer_Category__c WHERE CRM_CST_Is_Active_Planning_Period__c= TRUE]){
            //string recommendationFromCate = checkCust.Core_Recommendation__c != null ? checkCust.Core_Recommendation__c.toLowerCase(): '';//commented as part of TWC3123-6021
            if(/*recommendationFromCate.contains(recommendation) &&*/ (checkCust.Coverage__c == partnerLed || checkCust.Coverage__c == uncovered || checkCust.Coverage__c == otherLedAccount)){
                if(!customerGiveAccess.containsKey(checkCust.Customer_Detail__c+'_'+checkCust.Category__c+'_'+checkCust.Coverage__c))
                    customerGiveAccess.put(checkCust.Customer_Detail__c+'_'+checkCust.Category__c+'_'+checkCust.Coverage__c, new List<String>());
                customerGiveAccess.get(checkCust.Customer_Detail__c+'_'+checkCust.Category__c+'_'+checkCust.Coverage__c).add(checkCust.id);
                
            }
            
            if(checkCust.Coverage__c == intelLed){                
                if(!categoryShareMap.containsKey(checkCust.Customer_Detail__c+'_'+checkCust.Category__c+'_'+checkCust.Coverage__c))
                    categoryShareMap.put(checkCust.Customer_Detail__c+'_'+checkCust.Category__c+'_'+checkCust.Coverage__c, new List<String>());
                
                categoryShareMap.get(checkCust.Customer_Detail__c+'_'+checkCust.Category__c+'_'+checkCust.Coverage__c).add(checkCust.id);            
            }  
        }
        //system.debug('Inside customerGiveAccess:'+customerGiveAccess);
        return customerGiveAccess;
    }
    
    //TWC3123-6456
    @invocablemethod(label='executeShareAccountBatch')
    public static void executeCRMAccountBatch(List<FlowInputs> request) {
        list<Id> acountOwnerWWIdlst = new list<id>();
        list<Id> accountDetailIdlst = new list<id>();
        if(request.size()>0) {
            for(FlowInputs fi : request) {
                acountOwnerWWIdlst.addAll(fi.AccountOwnerWWIDList);
                accountDetailIdlst.addAll(fi.AccountDetailIdList);
            }
        }
        if(accountDetailIdlst.size()>0 && acountOwnerWWIdlst.size()>0) {
            Database.executeBatch(new SPM_ShareAccountdetails(false,true,'Where Account_Owner_WWID__c IN :AccWWIDs and Id In :AccountDetailIds and CRM_CST_Is_Active_Planning_Period__c=true ' ,acountOwnerWWIdlst,accountDetailIdlst,50)); 
        }
    }
    
    public class FlowInputs {
        @InvocableVariable public List<Id> AccountOwnerWWIDList;
        @InvocableVariable public List<Id> AccountDetailIdList;
    }
    
}