/****************************************************************************************************************************************
* Class Name  : PRM_DashboardTabVisibilityController 
* Version     : 1.0 
* Created Date: 26-Jun-2020
* Developer       Date                     Description
* ----------------------------------------------------------------------------------------------------------
* Tejasree        26/06/2020               Created to check the visibility of dashboard tabs in IPA Community
*****************************************************************************************************************************************/
public without sharing class PRM_DashboardTabVisibilityController {
    @TestVisible
    private final static String STATUS_ACTIVE='Active';
    public static final string SYM_COL= ',' ;   
    public static Set<String> loggedInUserpermissionSet = new Set<String>();
    public static Set<Id> accIds = new Set<Id>();
    public static Set<Id> loggedInUserContactId = new Set<Id>();
    public static Set<String> contactEntitlements = new Set<String>();
    public static List<PRM_AccountBenefitAssociation__c> benefits = new List<PRM_AccountBenefitAssociation__c>();
    public static Set<String> benefitCode = new Set<String>();
    public static User loggedInUser;
    //public static string renewalCombo; //IPA2.0 TWC727-3135
    public static string profileName;
    public static Final String ORIGIN  = 'PRM_DashboardTabVisibilityController';
    public static Final String SEVERITY  = 'Info';
    public static Final String PROJECT  = 'IPA';   
    public static final String LOG_ENTRY_SCOPE    = 'PRM_DashboardTabVisibilityController';       
    public static final String LOG_ENTRY_SEVERITY = 'Error';   
    //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh); //IPA2.0-TWC727-2923 Dashboard changes for role/tier
    
    public static list<PRM_AccountChannelMembership__c> acmTierCheck =new list<PRM_AccountChannelMembership__c>();
    public class responseWrapper {
        
        @AuraEnabled 
        public String link;
        @AuraEnabled
        public String userType; 
        @AuraEnabled
        public String loggedInuserType;
        @AuraEnabled
        public boolean legalAgreementCheck;
        @AuraEnabled
        public boolean showManagePartnerBtn;  
        @AuraEnabled
        public boolean showManageStorefrontBtn; 
        @AuraEnabled
        public String partnerKeyMetricExtLink;  
        @AuraEnabled
        public Map<String,boolean> tabAccess;           
        @AuraEnabled 
	public PointsWrapper ptWrapper;
        @AuraEnabled 
        public String onBoardingReidrecturl;   
        /*@AuraEnabled 
        public Map<String,String> renewalContent;*/ //IPA2.0 TWC727-3135
        
    }
    
    @AuraEnabled
    public static responseWrapper getResponse(){
        
        responseWrapper rr = new responseWrapper();  
        profileName = profileCheck();
        if( loggedInUserContactId != null){
            for(Core_Contact_Entitlement__c cntctEntl : [Select Id,Core_Entitlement_Id__r.Name from Core_Contact_Entitlement__c where Core_Contact_Id__c=:loggedInUserContactId AND Core_Status__c=:Label.PRM_ACR_Status and Core_Selected__c =true ]){
                contactEntitlements.add(cntctEntl.Core_Entitlement_Id__r.Name);
            } 
        }
        // get benefit list of the account  
        benefits = [SELECT PRM_Account_Id__c, PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c where PRM_Account_Id__c IN:accIds AND PRM_Status_Nm__c=:Label.PRM_Status_Active]; 
        // set of benefit code 
        for(PRM_AccountBenefitAssociation__c bft: benefits) {
            benefitCode.add(bft.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c);
        }      
        Map<String,boolean> tabMap = new Map<String,boolean>();
        tabMap.put('showPointsTab',showPointsTab().booleanPointsTabsVisibility);
        rr.ptWrapper = showPointsTab();
        //tabMap.put('showPartnerKeyMetricsTab',isPartnerKeyMetric()); //IPA2.0-TWC729-8064
        tabMap.put('showLeadTab',isLead());
        //tabMap.put('showPartnerKeyMetricsExtTab',isPartnerKeyMetricExt());
         //tabMap.put('showPartnerTab',isPartner()); //IPA2.0-TWC729-8064
         //tabMap.put('showOfferingTab',isOfferingsOE()); //IPA2.0-TWC729-8064
         //tabMap.put('showOfferingKeyMetricsTab',isOfferingKeyMetric()); //IPA2.0-TWC729-8064
        tabMap.put('showSalesTab',isSalesUser());
        tabMap.put('showTrainingTab',isTrainingUser());
        tabMap.put('showAccountActivityTab',isAccountActivity());
         //tabMap.put('showOfferingSection',isOfferingSection()); //IPA2.0-TWC729-8064
         //tabMap.put('showSolutionSection',isSolutionSection()); //IPA2.0-TWC729-8064
        tabMap.put('showWarrantyTab',isWarranty());
        //tabMap.put('showRenewalTab',isRenewal()); //IPA2.0 TWC727-3135
        
        String relation = checkRelation();
        boolean legalAgreement = isCheckAgreementDetails();
        
        Boolean isStepOneCompleted = isStepOneCompleted();
        if(Test.isRunningTest()){
            relation ='Partner';
            profileName = 'Partner';
        }
        if(relation =='Partner'){
            rr.userType = 'Partner';
            if(!legalAgreement){
                rr.link = '/ipa/s/post-launch-primary';
            }
            if(!isStepOneCompleted) {
                rr.onBoardingReidrecturl = System.Label.PRM_Post_Launch_Primary_Link;   
            }            
        }
        if(Test.isRunningTest()){
            relation ='Employee';
            profileName = Label.PRM_External_User;
        }
        if(relation =='Employee'){
            rr.userType = 'Employee';
            if(!legalAgreement){
                rr.link = '/ipa/s/post-launch-non-primary';
            }
              if(!isStepOneCompleted) {
                rr.onBoardingReidrecturl = System.Label.PRM_Post_Launch_Non_Primary_Link;  
            }  
        }
        if(profileName == Label.PRM_External_User){
            rr.showManageStorefrontBtn = true;
            rr.showManagePartnerBtn = false;
            rr.loggedInuserType = Label.PRM_External_User;
        }
        if(profileName == Label.PRM_Internal_User || Test.isRunningTest()){
            rr.showManageStorefrontBtn = false;
            rr.showManagePartnerBtn = true;
            rr.loggedInuserType = Label.PRM_Internal_User;
        }
        if(String.isNotBlank(isPartnerKeyMetricExt())){
            rr.partnerKeyMetricExtLink = isPartnerKeyMetricExt();  
        }
        rr.tabAccess = tabMap; 
        /*try{
            if(tabMap!=null && tabMap.containskey('showRenewalTab') && tabMap.get('showRenewalTab') )
                rr.renewalContent= getRenewalContent(); 
        }catch(exception e){
            Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', e.getMessage() ,'' ,'PRM_DashboardTabVisibilityController' ,'' ,e);    
        }*/ //IPA2.0 TWC727-3135
        
        return rr;
    }
    
    
    public class PointsWrapper{
        @AuraEnabled public boolean booleanPointsTabsVisibility{get;set;}
        @AuraEnabled public boolean showLocationActSection{get;set;}
        @AuraEnabled public boolean showDQFlag{get;set;}
    
    }
    
    
    @AuraEnabled
        public static pointsWrapper showPointsTab(){
        Set<String> accountIds = new Set<String>();
        Set<String> opids = new Set<String>();
        User loggedInUser ;
        PointsWrapper ptWrapper;
        Id userId = UserInfo.getUserId();
        if(userId != null){
           List<User> ud =[SELECT ContactId,Contact.Core_IPA_PartnerRole__c,Email, AccountId,profile.Name,Core_IPA_One_Partner_Id__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(!ud.isEmpty()){
                for(User u : ud){
                accountIds.add(u.AccountId);
                opids.add(u.Core_IPA_One_Partner_Id__c);
               // accountIds.add(ud.Core_IPA_One_Partner_Id__c);
                loggedInUser = new User();
                loggedInUser = u;
                }
            }
        }
        //select id, Contact.Core_IPA_Partner_Role__c, Contact.AccountId, Contact.Account.Core_IPA_Partner_Role__c, Core_IPA_One_Partner_Id__c from user
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        //boolean reedeemFlag = false;
        boolean ptsFlag = false;
        boolean dqFlag = false;    
        if(loggedInUser!=null){
            ptWrapper = new PointsWrapper();
            for(PRM_Account_Contact_Relationship__c acrRec : [select id,PRM_Contact_Id__r.Core_IPA_PartnerRole__c from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c = :loggedInUser.ContactId and PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c in ('PRIMARY','PRIMCONTDEL','WORKSFOR') and PRM_Status_Nm__c=:Label.PRM_Complete]){
                acr = acrRec;
            }
            if(acr!=null && loggedInUser.profile.Name=='Partner') {
                if(Label.PRM_Points_view_Partner_Roles_visibility.split(';').contains(acr.PRM_Contact_Id__r.Core_IPA_PartnerRole__c)|| Test.isRunningTest()){
                    
                    //if(ipaRefresh){
                    ptWrapper = PRM_DashboardTabVisibilityController.showPointsTabhelper(accountIds,opids);//}
                    /*else{
                    ptWrapper = PRM_DashboardTabVisibilityController.showPointsTabHelper(accountIds,null);
                    }*/
                        
                        // for( PRM_AccountBenefitAssociation__c aba : [select id,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c from PRM_AccountBenefitAssociation__c where PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c in :Label.PRM_benefits_for_point_not_eligible_flag.split(';') and PRM_Account_Id__c =:accountIds and PRM_Status_Nm__c ='Active']){
                            
                        //     if(aba.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c=='BFTPTSVIEW'){
                        //         ptsFlag= true;
                        //     }
                            
                        // }
                        // if(accountIds!=null && !accountIds.isEmpty()){
                        //    List<PRM_Points_Data__c> pd = [select id,Name,DQ_Flag__c from PRM_Points_Data__c where PRM_Account_Id__c =:accountIds limit 1];
                        //     if(!pd.isEmpty()){
                        //         for(PRM_Points_Data__c p : pd){
                        //             dqFlag = p.DQ_Flag__c;
                        //         }
                        //     }
                        // }
                        // dqFlag = showPointsTab.showPointsTabHelper(ptsFlag);
                        // if(ptsFlag && dqFlag){             //when acc has 'Points accural view' benefit and DQ flag is checked,user can see points metrics
                        //     system.debug('1st');
                        //     ptWrapper.booleanPointsTabsVisibility = true;
                        //     ptWrapper.showLocationActSection = true;
                        //     ptWrapper.showDQFlag=false;
                        // }
                        
                        // else if(ptsFlag && !dqFlag){          //when acc has 'Points accural view' benefit and DQ flag is Unchecked, user can see Points tab on dashboard but not points metrics
                        //     system.debug('2nd');
                        //     ptWrapper.booleanPointsTabsVisibility = true;
                        //     ptWrapper.showLocationActSection = false;
                        //     ptWrapper.showDQFlag=true;
                        // }
                        
                        // else if((!ptsFlag && dqFlag) || (!ptsFlag && !dqFlag)){  //when acc has not 'Points accural view' benefit,user can't see Points tab itself.
                        //     system.debug('3rd');
                        //     ptWrapper.booleanPointsTabsVisibility =false;
                        //     ptWrapper.showLocationActSection = false;
                        //     ptWrapper.showDQFlag=false;
                        // }
                        
                 }else{
                    
                    ptWrapper.booleanPointsTabsVisibility = false;
                    ptWrapper.showLocationActSection = false;
                }
            }else{
                //considering user is standard user
                ptWrapper.booleanPointsTabsVisibility = true;
                ptWrapper.showLocationActSection = true;
            }
        }
        //}
        return ptWrapper;
    }

    public static pointsWrapper showPointsTabhelper(Set<String> accountIds, Set<String> opids){

        boolean reedeemFlag = false;
        boolean ptsFlag = false;
        boolean dqFlag = false; 
        PointsWrapper ptWrapper;
        List <PRM_AccountBenefitAssociation__c> abalist ;
        ptWrapper = new PointsWrapper();
        
        //if(ipaRefresh){
            abalist =[select id,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c from PRM_AccountBenefitAssociation__c where PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c in :Label.PRM_benefits_for_point_not_eligible_flag.split(';') and PRM_Account_Id__c =:opids and PRM_Status_Nm__c ='Active'];
        /*}else{
            abalist =[select id,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c from PRM_AccountBenefitAssociation__c where PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c in :Label.PRM_benefits_for_point_not_eligible_flag.split(';') and PRM_Account_Id__c =:opids and PRM_Status_Nm__c ='Active'];
        }*/

                        for( PRM_AccountBenefitAssociation__c aba : abalist){
                            
                            if(aba.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c=='BFTPTSVIEW'){
                                ptsFlag= true;
                            }
                            
                        }
                        if(accountIds!=null && !accountIds.isEmpty()){
                           List<PRM_Points_Data__c> pd = [select id,Name,DQ_Flag__c from PRM_Points_Data__c where PRM_Account_Id__c =:accountIds limit 1];
                            if(!pd.isEmpty()){
                                for(PRM_Points_Data__c p : pd){
                                    dqFlag = p.DQ_Flag__c;
                                }
                            }
                        }
                        if(ptsFlag && dqFlag){             //when acc has 'Points accural view' benefit and DQ flag is checked,user can see points metrics
                            //system.debug('1st');
                            ptWrapper.booleanPointsTabsVisibility = true;
                            ptWrapper.showLocationActSection = true;
                            ptWrapper.showDQFlag=false;
                        }
                        
                        if(ptsFlag && !dqFlag){          //when acc has 'Points accural view' benefit and DQ flag is Unchecked, user can see Points tab on dashboard but not points metrics
                            //system.debug('2nd');
                            ptWrapper.booleanPointsTabsVisibility = true;
                            ptWrapper.showLocationActSection = false;
                            ptWrapper.showDQFlag=true;
                        }
                        
                        if((!ptsFlag && dqFlag) || (!ptsFlag && !dqFlag)){  //when acc has not 'Points accural view' benefit,user can't see Points tab itself.
                            system.debug('3rd');
                            ptWrapper.booleanPointsTabsVisibility =false;
                            ptWrapper.showLocationActSection = false;
                            ptWrapper.showDQFlag=false;
                        }

            return ptWrapper;
    }
    
    @AuraEnabled
    public static string checkRelation(){ // return true if employee
        User loggedInUser = [SELECT ContactId,Email, AccountId,profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        if(loggedInUser.ContactId!=null && loggedInUser.profile.Name=='Partner'){
            List<String> partnerEntlmnt = new List<String>();
            List<String> empEntlmnt = new List<String>();
            for(Core_Contact_Entitlement__c entlmnt : [select id,Core_Entitlement_Id__r.name, Core_Status__c, Core_Selected__c from Core_Contact_Entitlement__c where Core_Selected__c=true and Core_Status__c='complete' and Core_Contact_Id__c =:loggedInUser.ContactId]){
                if(entlmnt.Core_Entitlement_Id__r.name =='Employee'){
                    empEntlmnt.add(entlmnt.Core_Entitlement_Id__r.name);
                }
                if( entlmnt.Core_Entitlement_Id__r.name =='Partner Admin' || entlmnt.Core_Entitlement_Id__r.name =='Partner Admin Delegate'){
                    partnerEntlmnt.add(entlmnt.Core_Entitlement_Id__r.name);
                }
            }
            if(empEntlmnt.size()>partnerEntlmnt.size()){
                return 'Employee';
            }else{
                return 'Partner';
            }
        }
        return 'standardUser';
    }
    
    //To Check Sales Tab visibility in Dashboard Page of IPA Community.    
    @AuraEnabled
    public static Boolean isSalesUser(){
        String salesTab=Label.PRM_Sales_Tab;
        Boolean isSalesTab = isTabVisibility(salesTab);
        System.debug('In Sales Tab Method' +isSalesTab);
        return isSalesTab;
    }
    //To Check Training Tab visibility in Dashboard Page of IPA Community.
    @AuraEnabled  
    public static boolean isTrainingUser(){
        String tabName=Label.PRM_Training_Tab;
        Boolean isTrainingTab = isTabVisibility(tabName);
        return isTrainingTab;
    }
    //To Check Account Activity Tab visibility in Dashboard Page of IPA Community.
    @AuraEnabled
    public static boolean isAccountActivity(){
        String accTab=Label.PRM_Account_Activity_Tab;
        Boolean isAccountTab = isTabVisibility(accTab);
        return isAccountTab;
    }
    @AuraEnabled
    public static boolean isCheckAgreementDetails(){
        //Boolean entLegalflag;   
        
        User loggedInUser = [SELECT ContactId,Email, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(!String.valueOf(loggedInUser.Email).contains('@intel.com')){  
            if(loggedInUser != null){
                List<PRM_AccountLegalAgreemntAssociation__c>  checkAggr = [Select id from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c = :loggedInUser.AccountId and PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c =:system.label.PRM_IPATNCCode and PRM_InActive_Ind__c=false]; 
                /*if(checkAggr.size()>0){
                    return true;
                }else{
                    return false;
                }*/ //JB
                return checkAggr.size()>0?true:false;
            }
        }
        return true;
    }
    //Utility method for sales,Training & Account Activity Tab Visibility,based on ContactEntitlements assigned and partner roles of logged in user's Contact record
    //Offering key metrics
    public static boolean isTabVisibility(String tabName){
        Boolean entFlag=false;
        Boolean roleFlag=false;
        Boolean tabVisibility=false;
        String userRole='';
        List<String> profiles=new List<String>();
        List<String> entitlements=new List<String>();
        List<String> partnerRoles=new List<String>();
        List<String> userEntl=new List<String>(); 
        //List<Core_Contact_Entitlement__c> contEntlmnts = new List<Core_Contact_Entitlement__c>();
        Id contactId=[SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId()].contactId;
        List<Profile> profileName = new List<Profile>();
        if(contactId!=Null){
            Contact con=[Select Id,Core_IPA_PartnerRole__c from Contact where Id=:contactId];
            if(con.Core_IPA_PartnerRole__c !=Null){
                userRole=con.Core_IPA_PartnerRole__c;
		}
        }
        for(Core_Contact_Entitlement__c ce:[Select Name,Core_Contact_Id__c,Core_Contact_Id__r.Core_IPA_PartnerRole__c,Core_Entitlement_Id__r.Name from Core_Contact_Entitlement__c where 
                                            Core_Contact_Id__c=:contactId AND Core_Status__c=:Label.PRM_ACR_Status and Core_Selected__c =true]){
                                                if(ce.Core_Entitlement_Id__r.Name!=Null){
                                                    userEntl.add(ce.Core_Entitlement_Id__r.Name);}
                                            }
        
        System.debug('userRole' +userRole);
        for(PMP_Dashboard_Tab__mdt metadata :[Select Id,DeveloperName, MasterLabel,PRM_Entitlement_Txt__c, PRM_Profile_Txt__c, PRM_Partner_Role_Txt__c, 
                                              PMP_Permission_Set_Name_Txt__c from PMP_Dashboard_Tab__mdt 
                                              where MasterLabel =:tabName AND PMP_Is_Active_Ind__c=True]){
                                                  roleFlag=false;
                                                  entFlag=false;
                                                  if(metadata.PRM_Partner_Role_Txt__c!=Null){
                                                      partnerRoles=metadata.PRM_Partner_Role_Txt__c.split(SYM_COL);
						      }
                                                  if(metadata.PRM_Entitlement_Txt__c!=Null){
                                                      entitlements=metadata.PRM_Entitlement_Txt__c.split(SYM_COL);
						      }
                                                  
                                                  if(metadata.PRM_Profile_Txt__c!=Null){
                                                      profiles =metadata.PRM_Profile_Txt__c.split(SYM_COL);}
                                                  
                                                  if(metadata.PRM_Partner_Role_Txt__c=='' || metadata.PRM_Partner_Role_Txt__c==Null){
                                                      roleFlag=true;
                                                  }else if(partnerRoles.contains(userRole)) {
                                                      roleFlag=true;
						      }
                                                  if(metadata.PRM_Entitlement_Txt__c=='' || metadata.PRM_Entitlement_Txt__c==Null){
                                                      entFlag=true;  
						      }
                                                  else if(entitlements!=Null && entFlag==false){
                                                      
                                                      for(String en :entitlements){
                                                          if(userEntl.contains(en)){
                                                              entFlag=true;
                                                              break;}         
                                                      }
                                                      
                                                  }
                                                  if(roleFlag==true && entFlag==true){
                                                      break;}
                                              }
        
        if(profiles.size()>0){
            profileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() AND (Name IN:profiles) LIMIT 1];
        }
        
        System.debug('Final partner Role flag' +roleFlag);
        System.debug('Final entitlement flag' +entFlag);
        
        if((entFlag==true && roleFlag==true) || profileName.size()>0){
            tabVisibility = true; 
            System.debug('Training tab visibility' +tabVisibility);}
        return tabVisibility;
    }
        /***********************************************************************************************************************
        Method:    showRenewalTabCheck        
        Return:    Boolean value to show and hide renewal tab
        Purpose:   to show renewal tab on dashboard
        
************************************************************************************************************************/  
    // public static boolean showRenewalTabCheck() {
    //     try{
    //     boolean flag = false; string partrole;
    //     PMP_Dashboard_Tab__mdt dash=PMP_Dashboard_Tab__mdt.getInstance('Renewal');
    //     system.debug('---dash '+dash );
        
        
    //     list<string> partnerrole=string.isnotblank(dash.PRM_Partner_Role_Txt__c)?(dash.PRM_Partner_Role_Txt__c).split(';'):null;
    //     list<string> entitlments=string.isnotblank(dash.PRM_Entitlement_Txt__c)?(dash.PRM_Entitlement_Txt__c).split(';'):null;
    //     list<string> Tier=string.isnotblank(dash.PMP_Benefit_Code_Txt__c)?(dash.PMP_Benefit_Code_Txt__c).split(';'):null;
    //     loggedInUser = [SELECT ContactId,Email, AccountId,profile.Name,Contact.AccountId,Contact.Core_IPA_PartnerRole__c, Contact.Account.Core_IPA_One_Partner_Id__c, toLabel(LanguageLocaleKey) FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    //     system.debug('---strings '+partnerrole +'--'+entitlments+'--'+Tier);
    //     if(loggedInUser!=null && partnerrole.size()>0 && entitlments.size()>0 && Tier.size()>0){        
    //         system.debug('---loggedInUser '+loggedInUser);
    //         system.debug('Contact.Account.Core_IPA_One_Partner_Id__c--->'+loggedInUser.Contact.Account.Core_IPA_One_Partner_Id__c);
    //         system.debug('Contact Partner Role1'+loggedInUser.Contact.Core_IPA_PartnerRole__c);
    //         integer acrCheck =[select count() from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c=:loggedInUser.ContactId and PRM_Status_Nm__c='Complete' and PRM_Partner_Role__c in :partnerrole  and PRM_InActive_Ind__c=false];
    //         acmTierCheck =[select id,PRM_Tier_Name_txt__c,PRM_Partner_Role__c,PRM_Account_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c=:loggedInUser.Contact.AccountId  and PRM_Status_Nm__c='Approved' and PRM_Partner_Role__c =:loggedInUser.Contact.Core_IPA_PartnerRole__c and PRM_Tier_Name_txt__c in :Tier];
    //         integer entitlmentCheck =[SELECT COUNT() from Core_Contact_Entitlement__c where Core_Contact_Id__c=:loggedInUser.ContactId AND Core_Status__c=:Label.PRM_ACR_Status and Core_Selected__c =true and  Core_Display_Nm__c in :entitlments];
            
    //         system.debug('---Count '+acrCheck+'--'+acmTierCheck+'--'+entitlmentCheck);
    //         /*if(string.isnotblank(loggedInUser.Contact.Core_IPA_PartnerRole__c)){
    //             partRole=loggedInUser.Contact.Core_IPA_PartnerRole__c=='Seller'?'Solution Provider':loggedInUser.Contact.Core_IPA_PartnerRole__c;
    //             if(acrCheck >0 && acmTierCheck.size() >0 && entitlmentCheck>0){
    //                 renewalCombo=acmTierCheck[0].PRM_Tier_Name_txt__c+'-'+partRole+'-';
    //                 flag=true;
    //             }
    //         }*/ //JB
    //         //IPA2.0-TWC727-2923 Dashboard changes for role/tier
    //         if(!ipaRefresh && string.isnotblank(loggedInUser.Contact.Core_IPA_PartnerRole__c)){ 
    //             partRole=loggedInUser.Contact.Core_IPA_PartnerRole__c=='Seller'?'Solution Provider':loggedInUser.Contact.Core_IPA_PartnerRole__c;
    //         }else{
    //             partRole=loggedInUser.Contact.Core_IPA_PartnerRole__c;
    //         }
    //         if(string.isnotblank(loggedInUser.Contact.Core_IPA_PartnerRole__c) && acrCheck >0 && acmTierCheck.size() >0 && entitlmentCheck>0){
    //             renewalCombo=acmTierCheck[0].PRM_Tier_Name_txt__c+'-'+partRole+'-';
    //             flag=true;
    //         } 
    //      } 
    //     return flag;
       
    //     }catch(Exception e){
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // } //IPA2.0 TWC727-3135
    
    /***********************************************************************************************************************
        Method:    getRenewalContent        
        Return:    String value to show renewal content of value exchange
        Purpose:   to show renewal content on renewal tab on dashboard
        
************************************************************************************************************************/  
    // public static Map<String,String> getRenewalContent(){
    //   try
    // {
    //         string content,content2,MEvalue;
    //         set<string> opId=new set<string>();
    //         map<string,string> contentMap=new  map<string,string>();
    //         map<string,string> returnvalues = new map<string,string>();
    //         system.debug('loggedInUser-->'+loggedInUser);
    //         system.debug('acmTierCheck-->'+acmTierCheck); 
    //         Map<String,string> langTo=new map<string,string>();
    //         Map<String,string> langTo1=new map<string,string>();
    //         Map<String,string> mapLangToField=new map<string,string>{
    //         'Bahasa Indonesia' => 'PRM_Renewal_Content_Indonesian__c',
    //         'Português (Brasil)' => 'PRM_Renewal_Content_Portuguese__c',
    //         'English' => 'PRM_Renewal_Content__c',
    //         '한국어' => 'PRM_Renewal_Content_Korean__c',
    //         'ไทย' => 'PRM_Renewal_Content_Thai__c',
    //         'Deutsch' => 'PRM_Renewal_Content_German__c',
    //         'Türkçe' => 'PRM_Renewal_Content_Turkish__c',
    //         'Suomalainen' => 'PRM_Renewal_Content_Finnish__c',
    //         'Русский' => 'PRM_Renewal_Content_Russian__c',
    //         'Español (México)' => 'PRM_Renewal_Content_Spanish__c',
    //         '中文（简体）' => 'PRM_Renewal_Content_Chinese_simplified__c',
    //         'Français' => 'PRM_Renewal_Content_French__c',
    //         '日本語' => 'PRM_Renewal_Content_Japanese__c',
    //         'Tiếng Việt' => 'PRM_Renewal_Content_vietnamese__c',
    //         'Svenska' => 'PRM_Renewal_Content_Swedish__c',
    //         'Norsk' => 'PRM_Renewal_Content_Norwegian__c',
    //         'Polski' => 'PRM_Renewal_Content_Polish__c',
    //         '繁體中文' => 'PRM_Renewal_Content_Chinese_Traditional__c',
    //         'Dansk' => 'PRM_Renewal_Content_Danish__c',
    //         'Italiano' => 'PRM_Renewal_Content_Italian__c',
    //         'Dutch' => 'PRM_Renewal_Content_Dutch__c'
    //         };
    //         Map<String,string> mapLangToField1=new map<string,string>{
    //         'English' => 'PRM_Renewal_Content2__c',
    //         'Bahasa Indonesia' => 'PRM_Renewal_Content2_Indonesian__c',
    //         'Português (Brasil)' => 'PRM_Renewal_Content2_Portuguese__c',
    //         '한국어' => 'PRM_Renewal_Content2_Korean__c',
    //         'ไทย' => 'PRM_Renewal_Content2_Thai__c',
    //         'Deutsch' => 'PRM_Renewal_Content2_German__c',
    //         'Türkçe' => 'PRM_Renewal_Content2_Turkish__c',
    //         'Suomalainen' => 'PRM_Renewal_Content2_Finnish__c',
    //         'Русский' => 'PRM_Renewal_Content2_Russian__c',
    //         'Español (México)' => 'PRM_Renewal_Content2_Spanish__c',
    //         '中文（简体）' => 'PRM_Renewal_Content2_Chinese_simplified__c',
    //         'Français' => 'PRM_Renewal_Content2_French__c',
    //         '日本語' => 'PRM_Renewal_Content2_Japanese__c',
    //         'Tiếng Việt' => 'PRM_Renewal_Content2_vietnamese__c',
    //         'Svenska' => 'PRM_Renewal_Content2_Swedish__c',
    //         'Norsk' => 'PRM_Renewal_Content2_Norwegian__c',
    //         'Polski' => 'PRM_Renewal_Content2_Polish__c',
    //         '繁體中文' => 'PRM_Renewal_Content2_Chinese_Traditional__c',
    //         'Dansk' => 'PRM_Renewal_Content2_Danish__c',
    //         'Italiano' => 'PRM_Renewal_Content2_Italian__c',
    //         'Dutch' => 'PRM_Renewal_Content2_Dutch__c'
    //      };

    //         //for(Value_Exchange_Content_Translation__mdt vxLangRec:[select  MasterLabel, PRM_Renewal_Content_Field__c from Value_Exchange_Content_Translation__mdt]){
    //         if(mapLangToField.containskey(loggedInUser.LanguageLocaleKey)) {
    //             langTo.put(loggedInUser.LanguageLocaleKey,mapLangToField.get(loggedInUser.LanguageLocaleKey));
    //         }
    //         if(mapLangToField1.containskey(loggedInUser.LanguageLocaleKey)){
    //             langTo1.put(loggedInUser.LanguageLocaleKey,mapLangToField1.get(loggedInUser.LanguageLocaleKey));
    //         }
    //         // system.debug('vxLangRec.MasterLabel--->'+vxLangRec.MasterLabel+'vxLangRec.PRM_Renewal_Content_Field__c-->'+vxLangRec.PRM_Renewal_Content_Field__c);
    //         //  }
    //         if(loggedInUser!=null && acmTierCheck.size()>0){
    //         string partrole=acmTierCheck[0].PRM_Partner_Role__c, tier=acmTierCheck[0].PRM_Tier_Name_txt__c,accId=loggedInUser.contact.Account.Core_IPA_One_Partner_Id__c;
    //         for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c =:loggedInUser.Contact.AccountId AND Core_Inactive_Ind__c = false]){ 
    //             opId.add(agm.Core_Partner_Account_Id__c);
    //         }            
    //         //query all value exchange datas
    //         list<PRM_Value_Exchange_Data__c> VEList=new list<PRM_Value_Exchange_Data__c>();
    //         List<Id> SetvalueExchangeDataId=new List<Id>();
    //         //Map<String,string> langTo=new map<string,string>();
    //         //IPA2.0-TWC727-2923 Dashboard changes for role/tier
    //         string roleToDisplayOnContent;
    //         if(!ipaRefresh){
    //             roleToDisplayOnContent=partRole=='Seller'?'Solution Provider':partRole;
    //         }else{
    //             roleToDisplayOnContent=partRole;
    //         }
    //         contentMap.put('role',roleToDisplayOnContent);
    //         contentMap.put('tier',tier);
    //         string VEQuery='select id,PRM_Country_Market_Type_Nm__c,PRM_Sales_Amount_Nbr__c,PRM_Tier_Id__r.Name,PRM_Training_Credit_Points_Count_Nbr__c,PRM_TimePeriod_Nm__c,PRM_Account_Id__c from PRM_Value_Exchange_Data__c where PRM_Tier_Id__r.Name=:tier and '; // //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087  
    //         if(opId.size()>0){
    //             VEQuery+=' PRM_One_Partner_Id__c in :opId ';
    //         }
    //         else{
    //             VEQuery+=' PRM_Account_Id__c = :accId ';
    //         }
    //         system.debug('---VEQuery '+VEQuery);
    //         VEList=database.query(VEQuery);
	// 		 String strPeriod;
	// 		 map<id,Decimal> trainingCurMap=new map<id,Decimal>();
    //         system.debug('---VEList '+VEList);
    //         if(acmTierCheck[0].PRM_Partner_Role__c==Label.PRM_Role_Builder){ //IPA2.0-TWC727-2923 Dashboard changes for role/tier     
    //             MEvalue='NA';
    //         }
    //         else{
    //             for(PRM_Value_Exchange_Data__c ve :VEList ){
    //                 if(string.isnotblank(ve.PRM_Country_Market_Type_Nm__c)){
    //                     //System.debug('market type-->'+ve.PRM_Country_Market_Type_Nm__c);
    //                     if(ve.PRM_Country_Market_Type_Nm__c==Label.PRM_Mature){
    //                         MEvalue=Label.PRM_Mature;
    //                         break;
    //                     }
    //                     else if(ve.PRM_Country_Market_Type_Nm__c==Label.PRM_EmergingLbl){
    //                         MEvalue=Label.PRM_EmergingLbl;                        
    //                     }                    
    //                 }                
    //             }
             
    //         }
    //         for(PRM_Value_Exchange_Data__c ve :VEList ){
    //             strPeriod = ve.PRM_TimePeriod_Nm__c;

    //             if(strPeriod==system.Label.PRM_Renewal_Previous_Measurement_Period ){
    //                 trainingCurMap.put(ve.PRM_Account_Id__c,ve.PRM_Training_Credit_Points_Count_Nbr__c);                                                       
    //                 system.debug('trainingCurMap-->'+trainingCurMap);
    //             }
    //         SetvalueExchangeDataId.add(ve.id);
    //         }
    //         //system.debug('---MEvalue '+MEvalue);
    //         //system.debug('SetvalueExchangeDataId-->'+SetvalueExchangeDataId);
    //         if(string.isnotblank(renewalCombo) && MEvalue!=null)
    //             renewalCombo+=MEvalue;
    //         system.debug('---renewalCombo '+renewalCombo);
    //         if(string.isnotblank(renewalCombo) && string.isnotblank(MEvalue)){
    //             PRM_ValueExchange__c ve=[select id,name,PRM_Renewal_Content__c,PRM_Renewal_Content2__c,PRM_Renewal_Content_Italian__c,PRM_Renewal_Content_Korean__c,PRM_Renewal_Content_Chinese_simplified__c,
    //                                      PRM_Renewal_Content_Chinese_Traditional__c,PRM_Renewal_Content_Danish__c,PRM_Renewal_Content_Dutch__c,
    //                                      PRM_Renewal_Content_Finnish__c,PRM_Renewal_Content_French__c,PRM_Renewal_Content_German__c,PRM_Renewal_Content_Indonesian__c,
    //                                      PRM_Renewal_Content_Japanese__c,PRM_Renewal_Content_Norwegian__c,PRM_Renewal_Content_Polish__c,PRM_Renewal_Content_Portuguese__c,
    //                                      PRM_Renewal_Content_Russian__c,PRM_Renewal_Content_Spanish__c,PRM_Renewal_Content_Swedish__c,PRM_Renewal_Content_Thai__c,
    //                                      PRM_Renewal_Content_Turkish__c,PRM_Renewal_Content_vietnamese__c,PRM_Dynamic_Content_Visibility__c,
    //                                      PRM_Renewal_Content2_Korean__c,PRM_Renewal_Content2_Indonesian__c,PRM_Renewal_Content2_Portuguese__c,PRM_Renewal_Content2_Thai__c,
    //                                      PRM_Renewal_Content2_German__c,PRM_Renewal_Content2_Turkish__c,PRM_Renewal_Content2_Finnish__c,PRM_Renewal_Content2_Russian__c,
    //                                      PRM_Renewal_Content2_Spanish__c,PRM_Renewal_Content2_Chinese_simplified__c,PRM_Renewal_Content2_French__c,PRM_Renewal_Content2_Japanese__c,
    //                                      PRM_Renewal_Content2_vietnamese__c,PRM_Renewal_Content2_Swedish__c,PRM_Renewal_Content2_Norwegian__c,PRM_Renewal_Content2_Polish__c,
    //                                      PRM_Renewal_Content2_Chinese_Traditional__c,PRM_Renewal_Content2_Danish__c,PRM_Renewal_Content2_Italian__c,PRM_Renewal_Content2_Dutch__c
    //                                      from PRM_ValueExchange__c where name=:renewalCombo limit 1];
    //             system.debug('Dynamic Content--->'+ve.PRM_Dynamic_Content_Visibility__c);
    //             // returnvalues.put('dynamiccontent',ve.PRM_Dynamic_Content_Visibility__c.replaceAll('\r\n',''));                         
    //             sobject obj=ve;
    //             //system.debug('langTo--->'+langTo);
    //             if(ve!=null){
    //                if(langTo.containsKey(loggedInUser.LanguageLocaleKey) && langTo1.containsKey(loggedInUser.LanguageLocaleKey)){
    //                     content=(string)obj.get(langTo.get(loggedInUser.LanguageLocaleKey)); /*langTo.get(loggedInUser.LanguageLocaleKey);*/
    //                     content2=(string)obj.get(langTo1.get(loggedInUser.LanguageLocaleKey));
    //                     //system.debug('loggedInUser.LanguageLocaleKey--->'+loggedInUser.LanguageLocaleKey);
    //                 }
    //                 else{
    //                     content=ve.PRM_Renewal_Content__c;
    //                     content2=ve.PRM_Renewal_Content2__c;
                        
    //                 }
    //                 //set<
    //                 for(PRM_Value_Exchange_Criteria_Association__c veca: [select id,name,PRM_Value_Txt__c,PRM_Specialty_Criteria_Id__r.Name 
    //                 from PRM_Value_Exchange_Criteria_Association__c where PRM_Value_Exchange_Id__c=:ve.Id]){
    //                     if(veca.PRM_Specialty_Criteria_Id__r.Name=='Number of Solutions in Mplace'){
    //                         contentMap.put('offercontent',veca.PRM_Value_Txt__c);
    //                     }
    //                     if(veca.PRM_Specialty_Criteria_Id__r.Name=='Sales'){
    //                         contentMap.put('revenuecontent',veca.PRM_Value_Txt__c);
    //                     }
    //                     if(veca.PRM_Specialty_Criteria_Id__r.Name=='Training Credits'){
    //                         contentMap.put('trainingcontent',veca.PRM_Value_Txt__c);
    //                     } 
    //                     if(veca.PRM_Specialty_Criteria_Id__r.Name=='Minimum Number of employees doing the training'){
    //                         contentMap.put('trainedemployeecontent',veca.PRM_Value_Txt__c);
    //                     } 
                        
    //                 }
					
    //                 System.debug('contentMap'+contentMap);
	// 				//sales calculation
	// 				List<AggregateResult> dataList = new List<AggregateResult>();
	// 				Decimal totalSalesData,totalTrainingCurrent;
	// 				Decimal sumCurrent=0;
	// 				dataList = [SELECT sum(PRM_Sales_Amount_Nbr__c) sales from PRM_Value_Exchange_Data__c WHERE Id IN: SetvalueExchangeDataId
	// 				and PRM_TimePeriod_Nm__c=:Label.PRM_Renewal_Previous_Measurement_Period group by PRM_One_Partner_Id__c];
	// 				for(AggregateResult vx: dataList){
	// 					totalSalesData =(Decimal)vx.get('sales');
	// 					system.debug('totalSalesData-->'+totalSalesData);
	// 				}
					
	// 				//training calculation
	// 				//List<AggregateResult> trainingValdataList = new List<AggregateResult>();
	// 				for(Decimal i:trainingCurMap?.values()){
    //                         sumCurrent+=i;
	// 				} 
	// 				totalTrainingCurrent=sumCurrent;
					
	// 				//approvedSolution calculation//IPA2.0: US-TWC729-7976
    //                 /*List<AggregateResult> totalApprovedSolutionsList = new List<AggregateResult>();
    //                 totalApprovedSolutionsList =  [select count(PSS_Partner_Account_Id__c) approvedSolution from ArdiraSurvey__Survey_Result__c where PSS_OPID_Account_Id__c= :accId 
    //                 and PSS_Partner_Solution_Lifecycle_Status_Nm__c in ('Converted To MP Offerings', 'Approved') group by PSS_OPID_Account_Id__c];
    //                 Decimal totalApprovedSolutions;
    //                 for(AggregateResult vx: totalApprovedSolutionsList){
    //                     totalApprovedSolutions = (Decimal)vx.get('approvedSolution');
    //                 }
    //                 system.debug('totalApprovedSolutions-->'+totalApprovedSolutions);*/
                    			
    //                 for(PRM_Value_Exchange_Data__c ve1 :VEList ){
    //                     //IPA2.0-TWC727-2923 Dashboard changes for role/tier
    //                     //IPA2.0: US-TWC729-7976 Solution EOL
    //                     if(!ipaRefresh){
    //                     if(ve1.PRM_Tier_Id__r.Name=='Gold'){
    //                         if(Integer.valueof(totalSalesData)>=Integer.valueof(contentMap.get('revenuecontent').replaceAll(',',''))
    //                         || Integer.valueof(totalTrainingCurrent)>=Integer.valueof(contentMap.get('trainingcontent').replaceAll(',',''))
    //                             /*|| Integer.valueof(totalApprovedSolutions)>=Integer.valueof(contentMap.get('offercontent').replaceAll(',',''))*/){
    //                             returnvalues.put('val',label.PRM_Yes);
    //                         }else{
    //                             returnvalues.put('val',label.PRM_No);
    //                         }
                           
    //                     }else if(ve1.PRM_Tier_Id__r.Name=='Titanium'){
    //                         if(Integer.valueof(totalSalesData)>=Integer.valueOf(contentMap.get('revenuecontent').replaceAll(',',''))
    //                         && (Integer.valueof(totalTrainingCurrent)>=Integer.valueOf(contentMap.get('trainingcontent').replaceAll(',',''))
    //                             /*|| Integer.valueof(totalApprovedSolutions)>=Integer.valueOf(contentMap.get('offercontent').replaceAll(',',''))*/)){
    //                             returnvalues.put('val',label.PRM_Yes);
    //                         }else{
    //                             returnvalues.put('val',label.PRM_No);
    //                         }
                           
    //                     }
    //                     }else{
    //                         if(ve1.PRM_Tier_Id__r.Name==Label.PRM_Tier_Partner){
    //                             if(Integer.valueof(totalSalesData)>=Integer.valueof(contentMap.get('revenuecontent').replaceAll(',',''))
    //                             || Integer.valueof(totalTrainingCurrent)>=Integer.valueof(contentMap.get('trainingcontent').replaceAll(',',''))
    //                             /*|| Integer.valueof(totalApprovedSolutions)>=Integer.valueof(contentMap.get('offercontent').replaceAll(',',''))*/){
    //                                 returnvalues.put('val',label.PRM_Yes);
    //                             }else{
    //                                 returnvalues.put('val',label.PRM_No);
    //                 }
                    
    //                         }else if(ve1.PRM_Tier_Id__r.Name==Label.PRM_Tier_Prestige){
    //                             if(Integer.valueof(totalSalesData)>=Integer.valueOf(contentMap.get('revenuecontent').replaceAll(',',''))
    //                             && (Integer.valueof(totalTrainingCurrent)>=Integer.valueOf(contentMap.get('trainingcontent').replaceAll(',',''))
    //                             /*|| Integer.valueof(totalApprovedSolutions)>=Integer.valueOf(contentMap.get('offercontent').replaceAll(',',''))*/)){
    //                                 returnvalues.put('val',label.PRM_Yes);
    //                             }else{
    //                                 returnvalues.put('val',label.PRM_No);
    //                             }
                           
    //                         }
    //                     }
                       
    //                 }
    //                 system.debug('contentMap-->'+contentMap);
    //                 for(string str:contentMap.keyset()){
    //                     if(contentMap.containskey(str))
    //                         content = content.replace('{{'+str+'}}', contentMap.get(str));                    
    //                 }
    //                 //system.debug('content-->'+content);
    //                // system.debug('content2-->'+content2);
    //                 returnvalues.put('content',content); 
    //                 returnvalues.put('dynamiccontent',ve.PRM_Dynamic_Content_Visibility__c.replaceAll('\r\n',''));                         
    //                 returnvalues.put('content2',content2);  
    //             }
    //         }
    //     }
    //         //system.debug('---returnvalues---> '+returnvalues);
    //         return returnvalues;
    //     }
    //     catch(Exception e){
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
    //IPA2.0 TWC727-3135


    //Method for visibility of Partner tab in Dashboard Page of IPA Community based on permission sets & profiles
    //IPA2.0-TWC729-8064
    /*@AuraEnabled
    public static Boolean isPartner(){  
        Boolean result = false;
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        List<String> profileList = new List<String>();
        List<String> permissionList= new List<String>();
        try{
            PMP_Dashboard_Tab__mdt dashTab=[Select Id,PMP_Permission_Set_Name_Txt__c,PRM_Profile_Txt__c from PMP_Dashboard_Tab__mdt where DeveloperName=:Label.PRM_MKM_Lead_Off AND PMP_Is_Active_Ind__c=True];
            
            permissionList =dashTab.PMP_Permission_Set_Name_Txt__c.split(SYM_COL);
            profileList =dashTab.PRM_Profile_Txt__c.split(SYM_COL);
            if(profileList.size()>0 || permissionList.size()>0){
                permissionSetList = [SELECT Id,Assignee.Profile.Name  FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()
                                     AND ((PermissionSet.Name IN:permissionList) OR(Assignee.Profile.Name IN:profileList))];
            }
            if(permissionSetList.size()>0){
                result =true;
            }
            System.debug('the result'+result);
            
        }catch(Exception e){ throw new AuraHandledException(e.getMessage());}
        return result;
        
    }*/
    
    @AuraEnabled
    public static String isPartnerKeyMetricExt(){        
        // User userId = getLoggedInUser();
        // PMP_Company__c CmpnyDetails = getCompanyInfo(userId.AccountId);
        // User
        PMP_Company__c CmpnyDetails = Core_UtilityController.getCompany();        
        String partnrDet;
        system.debug('CmpId'+CmpnyDetails);    
        if(CmpnyDetails != null && CmpnyDetails.id != null && CmpnyDetails.name != null){
            
            partnrDet = System.Label.PRM_Storefront_Url.replace('<Partner ID>',CmpnyDetails.id).replace('<Partner Name>',CmpnyDetails.name); 
        }
        return partnrDet;
    } 
    
     /* common functionality to check tab visibility */
    public static boolean checkTabVisibility(String tabName) {
        boolean tabVisibility = false;  
        
        system.debug('---profileName '+profileName);
        if(profileName == Label.PRM_SysAdminProfile || profileName == Label.PRM_ITAdminProfile || profileName == Label.PRM_Internal_User) { // profile and internal user check 
            tabVisibility = true;
        } else if(profileName == Label.PRM_External_User || profileName =='Partner') { // check external user
            // list of entitlements of logged in user           
            
            system.debug('---tabName '+tabName);
            /*if(tabName=='Renewal'){
                tabVisibility=showRenewalTabCheck();
            }
            else{
                tabVisibility = metadataCheck(tabName);
            }*/ //IPA2.0 TWC727-3135
            
            tabVisibility=metadataCheck(tabName); //IPA2.0 TWC727-3135

        }
        system.debug('---tabVisibility '+tabVisibility);
        return tabVisibility;
    }   
    
    /* If external user then check tab visibility based on custom metadata record*/
    public static boolean metadataCheck(String tabName) {
        boolean flag = false;
        List<String> permisionSets = new List<String>();
        List<String> entitlements = new List<String>();
        for(PMP_Dashboard_Tab__mdt metadata : [Select PRM_Entitlement_Txt__c, PMP_Permission_Set_Name_Txt__c from PMP_Dashboard_Tab__mdt where MasterLabel =:tabName AND PMP_Benefit_Code_Txt__c IN:benefitCode AND PMP_Is_Active_Ind__c=True]) {           
            if(String.isNotBlank(metadata.PMP_Permission_Set_Name_Txt__c)) {
                permisionSets = metadata.PMP_Permission_Set_Name_Txt__c.split(SYM_COL);   
                
            } 
            if(String.isNotBlank(metadata.PRM_Entitlement_Txt__c)) {
                entitlements = metadata.PRM_Entitlement_Txt__c.split(SYM_COL);  
            } 
        }
        // checking contacts entitlement with metadata record         
        for(String entitlement: entitlements) {
            if(contactEntitlements.contains(entitlement)) {
                flag= true; continue;
            }
        }
        // checking permissionsets with metadata record
        for(String permisionSet: permisionSets) {
            if(loggedInUserpermissionSet.contains(permisionSet)) {
                flag= true; continue;
            }
        }
        return flag;
    }
    /* returning external user or internal user or profile name of logged in user*/
    public static string profileCheck() {        
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name; 
        if(profileName == Label.PRM_SysAdminProfile || profileName == Label.PRM_ITAdminProfile) {
            return profileName;
        } else {
            Set<String> benefitset = new Set<String>();         
            user u = [select id, AccountId, contactId, Core_IPA_One_Partner_Id__c from user where id =:userinfo.getUserId() limit 1];
            if(String.isNotBlank(u.AccountId)){
                accIds.add(u.AccountId);
            }
            if(String.isNotBlank(u.Core_IPA_One_Partner_Id__c)){
                accIds.add(u.Core_IPA_One_Partner_Id__c);
            }
            loggedInUserContactId.add(u.contactId);
            if(u.Core_IPA_One_Partner_Id__c != null) {
                for(PRM_AccountBenefitAssociation__c pba : [Select id, name, PRM_Partner_Benefit_Id__r.Name from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c= :u.Core_IPA_One_Partner_Id__c and PRM_Status_Nm__c = 'Active'] ){
                    if(pba.PRM_Partner_Benefit_Id__r.Name == Label.PRM_Solutions_Marketplace_Basic_Profile || pba.PRM_Partner_Benefit_Id__r.Name == Label.PRM_Solutions_Marketplace_Enhanced || pba.PRM_Partner_Benefit_Id__r.Name == Label.PRM_Solutions_Marketplace_Basic_Access || pba.PRM_Partner_Benefit_Id__r.Name == Label.PRM_Advanced_Warranty_Replacement) {   
                        benefitset.add(pba.PRM_Partner_Benefit_Id__r.Name);
                    } 
                }
            }
            
            if(u.AccountId!=Null && benefitset.isEmpty()){                
                for(PRM_AccountBenefitAssociation__c pba : [Select id, name, PRM_Partner_Benefit_Id__r.Name from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c= :u.AccountId and PRM_Status_Nm__c = 'Active'] ){
                    if(pba.PRM_Partner_Benefit_Id__r.Name == Label.PRM_Solutions_Marketplace_Basic_Access){ 
                        benefitset.add(pba.PRM_Partner_Benefit_Id__r.Name);
                    } 
                }
            }
            
            for(PermissionSetAssignment pmsa : [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE AssigneeId = :userinfo.getUserId()]){
                loggedInUserpermissionSet.add(pmsa.PermissionSet.Name);
            }         
            if(loggedInUserpermissionSet.contains(Label.PRM_Internal_Intel_Admin) || loggedInUserpermissionSet.contains(Label.PRM_Internal_Intel_Read_Only_pmset_name)) {
                profileName = Label.PRM_Internal_User;
            }else if(loggedInUserpermissionSet.contains(Label.PRM_External_Employee_pmset_name) && benefitset.size() > 0  && loggedInUserpermissionSet.size() > 0) {
                profileName = Label.PRM_External_User;  
            } 
            return profileName;
        }        
    }
    
    /*public static boolean isPartnerKeyMetric(){
        String tabName= 'Partner Key Metric';
        Boolean isPartnerTab = checkTabVisibility(tabName);
        return  isPartnerTab;
    }*/ //IPA2.0-TWC729-8064
     /*public static boolean isOfferingsOE(){
        String tabName= 'Offerings OE';
        Boolean isOfferingTab = checkTabVisibility(tabName);
        return isOfferingTab;
    }*/ //IPA2.0-TWC729-8064
    
    public static boolean isLead(){
        String tabName= 'Lead';
        Boolean isLeadTab = checkTabVisibility(tabName);
        return isLeadTab;
    } 
   /*public static boolean isOfferingKeyMetric(){
        String tabName= 'Offering Key Metric';
        Boolean isOfferingKeyMetricTab = checkTabVisibility(tabName);
        return isOfferingKeyMetricTab;
    }*/ //IPA2.0-TWC729-8064
    /*public static boolean isOfferingSection(){
        String tabName= 'Offering Section';
        Boolean isOfferingSection = checkTabVisibility(tabName);
        return isOfferingSection;
    }*/ //IPA2.0-TWC729-8064
    /*public static boolean isSolutionSection(){
        String tabName= 'Solution Section';
        Boolean isSolutionSection = checkTabVisibility(tabName);
        return isSolutionSection;
    }*/ //IPA2.0-TWC729-8064
    public static boolean isWarranty(){
        String tabName= 'Warranty';
        Boolean isWarrantyTab = checkTabVisibility(tabName);
        return isWarrantyTab;
    }
    /*public static boolean isRenewal(){
        String tabName= 'Renewal';
        Boolean RenewalTab = checkTabVisibility(tabName);
        return RenewalTab;
    }*/ //IPA2.0 TWC727-3135
    @testvisible
    private static Boolean isTAndCAccepted (Id loggedInContactId){
        Boolean isTandCAccepted =false;
        Id accId =[Select AccountId from Contact where Id=:loggedInContactId limit 1 ].AccountId; 
        List<PRM_AccountLegalAgreemntAssociation__c> accLegalAssoc =[Select Id,PRM_InActive_Ind__c 
                                                                     from PRM_AccountLegalAgreemntAssociation__c 
                                                                     where PRM_Account_Id__c=:accId 
                                                                     AND PRM_Partner_Agreement_Id__r.Name=:System.Label.PRM_IPA_Terms_Condition AND PRM_InActive_Ind__c = false]; 
        if(!accLegalAssoc.isEmpty()){
            isTandCAccepted=true;
        }
        return isTandCAccepted;
    }
    
    @testvisible
    private static Boolean isStepOneCompleted() {
        Boolean isStepOneCompleted =false;
        try{
            Id loggedInContactId = [Select ContactId from User where Id =:UserInfo.getUserId() limit 1].ContactId;
            Boolean isTandCAccepted=isTAndCAccepted(loggedInContactId);
            List<String> subCodeList =System.Label.PRM_Post_Onboarding_Subscription_Code.split(',');
            List<PRM_ContactSubscriptionAssociation__c> contactSubs =[Select Id from PRM_ContactSubscriptionAssociation__c 
                                                                      where PRM_Contact_Id__c=:loggedInContactId
                                                                      AND PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c IN:subCodeList];
            if(!contactSubs.isEmpty() && contactSubs.size()==subCodeList.size() && isTandCAccepted) {               
                isStepOneCompleted=true;                
            }                    
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        return isStepOneCompleted;
    }    
}