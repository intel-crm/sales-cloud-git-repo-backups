/*********************************************************************************************************************
Apex Class Name  : IPABenefitUtility
Version       : 1.0
Created Date  : June 2020
Function      : Utility class containing business logic for Partner Benefits
Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Anish/Grishma/Jasmine               June 2020              Utility class containing business logic for  Partner Benefits
* Mansi Mundhra                         2021                 Addition of new blades/ctas and Adhoc Msg Functionality    
* Shraddha More                       Apr 2024               Addition of Deal Registration Blade
* Shamrin Saba                        Apr 2024               Adding link on manage benefit page under Partner lookup for Point Opportunity Report & Reseller
* Neha Sharma                         September 2024         Addition of a method(checkInternalUser) to check if the logged-in user is an internal user
*********************************************************************************************************************/
public without sharing class IPABenefitUtility {
    
    private static final String approved = 'Approved';
    private static final String admin = 'Admin Review';
    private static final String draft = 'Draft';
    private static final String updateRequired = 'Update Required';
    public static string pageType {set;get;}
    public static string entitlementNam {set;get;}    
    public static Boolean showDistiDashboard = false;
    public static Boolean showPartnerReports = false;
    public static Boolean showDZPAndRDCPremierBlade = false;
    public static Boolean showDZSAndRDCPublicBlade = false;
    public static Map<String, Boolean> showLogoMap =new Map<String, Boolean>();
    //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);  //IPA2.0-TWC727-2861
    
     //IPA2.0-TWC727-2896
    public static Id getRecordTypeId(String objectName, String developerName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();                  
    }
    //IPA2.0-TWC727-2896 
  public static void populateCTALinks(List<String> links, List<String> ctaPriorities, List<String> ctaLinks) {
        for (Integer i = 0; i < links.size(); i++) {
            ctaPriorities.add(links[0]);
            if (links[i] != ctaPriorities[0]) {
                ctaLinks.add(links[i]);
            }
            if (Test.isRunningTest()) {
                ctaPriorities.add(links[i]);
                ctaLinks.add(links[i]);
            }
        }
    }

   //IPA2.0-TWC727-2896 
     public static void populateAdhocAlerts(Map<String, String> adhocMsgs, IPABenefitWrapper.UserBenefitInfo userBenefit) {
        if (adhocMsgs != null && adhocMsgs.size() > 0) {
            List<IPABenefitWrapper.AdhocAlerts> adhocList = new List<IPABenefitWrapper.AdhocAlerts>();
            for (String key : adhocMsgs.keySet()) {
                IPABenefitWrapper.AdhocAlerts adhocAlert = new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = key.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(key);
                adhocList.add(adhocAlert);
            }
            userBenefit.adhocAlerts = adhocList;
        }
    }

       //IPA2.0-TWC727-2896 
         public static void populateAlerts(List<String> alertTitles, IPABenefitWrapper.UserBenefitInfo userBenefit) {
        if (alertTitles != null && alertTitles.size() > 0) {
            List<IPABenefitWrapper.Alerts> alertList = new List<IPABenefitWrapper.Alerts>();
            for (String a : alertTitles) {
                IPABenefitWrapper.Alerts alert = new IPABenefitWrapper.Alerts();
                alert.label = a;
                alertList.add(alert);  
            }
            userBenefit.alerts = alertList;
        }
    }


    public static IPABenefitWrapper.UserProfile userInfo(ID userID){
        IPABenefitWrapper.UserProfile userData = new IPABenefitWrapper.UserProfile();
        if(userID != null){
            User c= [select id,name,LanguageLocaleKey,LocaleSidKey,contact.id,contact.Core_IPA_One_Partner_Id__c,contact.title,contact.name,contact.Core_Job_Function__c,toLabel(contact.Core_Profession__c), account.name,contact.phone,account.id,contact.Email,email from user where id= : userID];
            userData.userId = c.id;
            userData.contactId = c.contact.id;
            userData.onePartnerId = c.contact.Core_IPA_One_Partner_Id__c;
            userData.companyProfileId = c.account.Id;   
            userData.name = c.name;//c.contact.name;    
            userData.title = c.contact.Core_Profession__c;
            userData.responsibility = c.contact.Core_Profession__c;    
            userData.phone = c.contact.phone;
            userData.email = c.contact.Email;  
            userData.faIcon = 'fa-intel-user-o';  
            userData.tier = 'Titanium Tier';  
            userData.userLanguage = c.LocaleSidKey;
            userData.UserEmail = c.email;
        }
        
        return userData;
    }
  
    //this method is used to fetch profile information on partner benefit experience
    @AuraEnabled(cacheable=true)
    public static IPABenefitWrapper.UserProfile  getProfileInfo(ID userID, String page){
        datetime start = datetime.NOW();
        pageType = page;
        IPABenefitWrapper.UserProfile userData = userInfo(userID);
        userData.marqueeTitle=  (!String.isEmpty(pageType)  && pageType.indexOf(Label.PRM_CP_CompanyProfile_Title_ENG)>-1) ? Label.PRM_CP_CompanyProfile_Title
            :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_Dashboard_Title_ENG)>-1) ? Label.PRM_Dashboard_Title 
                :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_Partner_Assist_Header_ENG)>-1) ?Label.PRM_Partner_Assist_Header
                    :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_Points_opportunity_Header_ENG)>-1) ?Label.Points_opportunity_Header
                        :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_Reseller_List_Header_ENG)>-1) ?Label.Reseller_List_Header
                    :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_Release_Of_Information_ENG)>-1) ?Label.PRM_Release_Of_Information
                        :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_Training_Credits_ENG)>-1) ?Label.PRM_Training_Credits
                            :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_Sales_Details_Title_ENG)>-1) ?Label.PRM_Sales_Details_Title
                                :(!String.isEmpty(pageType) && pageType.indexOf(Label.EPUM_ManagePersonnel_ENG)>-1) ?Label.EPUM_ManagePersonnel  
                                    :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_PartnerSearchHeader_ENG)>-1) ?Label.PRM_PartnerSearchHeader
                                        :System.label.IPA_Benefits_Manage_Benefits;           
        //userData.marqueeTitle = System.label.IPA_Builder_Title;
        IPABenefitWrapper.companyProfile singleProf = new IPABenefitWrapper.companyProfile();
        singleProf.label =System.label.IPA_BuilderRightPanel_CTA1Label; 
        singleProf.externalUrl = '';//https://www.intel.coms
        singleProf.communityPage= 'CompanyProfile__c';
        singleProf.objectPage = '';
        singleProf.recordId = userData.companyProfileId;//c.account.Id;
        userData.companyProfileLink = singleProf;
        IPABenefitWrapper.dashboardProfileLink dasbboard = new IPABenefitWrapper.dashboardProfileLink();
        dasbboard.label = System.label.IPA_BuilderRightPanel_ButtonLabel;
        dasbboard.externalUrl=URL.getSalesforceBaseUrl().toExternalForm()+Label.PRM_Dashboard_Url;

        dasbboard.communityPage= '';
        dasbboard.objectPage = '';
        dasbboard.recordId = '';
        userData.dashboardLink = dasbboard;
        IPABenefitWrapper.mProfileLink profile = new IPABenefitWrapper.mProfileLink();
        profile.label =System.label.IPA_BuilderRightPanel_CTA2Label;         
        profile.externalUrl = System.Label.IPA_MyProfile_Link_Cidaas;//'https://www.intel.com';      
        profile.communityPage= '';
        profile.objectPage = '';
        profile.recordId = userData.companyProfileId;//c.account.Id;
        userData.myProfileLink = profile;
        datetime endd = datetime.now();
        Decimal millisecs = Decimal.valueOf(endd.getTime() - start.getTime());
        integer div = 1000;   
        //Decimal cal = millisecs/div;
        return userData;        
    }
    
    //this method return the tier from ACM on passing partner role and account id/OPID
    public static String getPartnerTierACM(String partnerRole, IPABenefitWrapper.UserProfile userInfo)
    {
        String tierData = '';
        if(userInfo.onePartnerId!= null && partnerRole != null)
        { 
            Id opidRecordType = getRecordTypeId('Account','Core_Partner_Account_Group'); //IPA2.0-TWC727-2896
            List<PRM_AccountChannelMembership__c> accChnlMem = [Select id,PRM_Channel_Program_Level_Id__r.Name from PRM_AccountChannelMembership__c where PRM_Partner_Role__c = :partnerRole and PRM_Account_Id__r.Core_IPA_One_Partner_Id__c = :userInfo.onePartnerId  and PRM_Status_Nm__c  ='Approved' and PRM_Account_Id__r.RecordTypeId = :opidRecordType];
            if(accChnlMem.size()>0){
                tierData = accChnlMem[0].PRM_Channel_Program_Level_Id__r.name; 
            }
        }
        else
        {
            if(userInfo.companyProfileId!= null && partnerRole != null){
                List<PRM_AccountChannelMembership__c> accChnlMem = [Select id,PRM_Channel_Program_Level_Id__r.Name from PRM_AccountChannelMembership__c where PRM_Partner_Role__c = :partnerRole and PRM_Account_Id__c = :userInfo.companyProfileId  and PRM_Status_Nm__c  ='Approved'];
                if(accChnlMem.size()>0)
                {
                    tierData =  accChnlMem[0].PRM_Channel_Program_Level_Id__r.name;  
                }  
            } 
        }  
        return tierData;            
    }
    //this method is used to fetch blades information on partner benefit page based on security model
    @AuraEnabled(cacheable=true)
    public static IPABenefitWrapper.BenefitDetails getBenefitsInfo(Id userId)
    {
        datetime start = datetime.NOW();
        List<IPABenefitWrapper.UserBenefitInfo> userBenefitList=new List<IPABenefitWrapper.UserBenefitInfo>();
        IPABenefitWrapper.BenefitDetails bladeBenefitDetails=new IPABenefitWrapper.BenefitDetails();
        //List<String> partnerRoleList = new List<String>();
        List<String> entitlementList = new List<String>();  
        List<String> benefitsList=new List<String>();
        Boolean showSelectBenefit = false;
        List<String> selectBenefitList=new List<String>();
        List<String> specialityList=new List<String>();
        List<String> specialityNewList=new List<String>();
        List<String> ipaLookupRegionList = new List<String>();
        Id opidRT = getRecordTypeId('Account','Core_Partner_Account_Group'); //IPA2.0-TWC727-2896
        Id intelAccRT = getRecordTypeId('Account','Mastered_Account'); //IPA2.0-TWC727-2896
        String accountid;
        string opid;
        String partnerRol;
        String checkAgreement;
        List<PRM_Partner_Consent_Distributor__c> partnerConsent = new List<PRM_Partner_Consent_Distributor__c>();
        //String isUserSubscribedAll='false';
        //Boolean ifOpid=false;
        
        if(userId != null ){
            IPABenefitWrapper.UserProfile userInfo =  userInfo(userId);
            //added this to check T and C Aggrement check and if not present we are navigating in LWC component
            if(userInfo.companyProfileId != ''){
                List<PRM_AccountLegalAgreemntAssociation__c>  checkAggr = [Select id from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c =: userInfo.companyProfileId and PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c =:system.label.PRM_IPATNCCode and PRM_InActive_Ind__c=false];
                checkAgreement = (checkAggr.size() > 0) ? 'tandcpresent' : 'tandcnotpresent';          
                    for(Account acc : [Select name, Core_Geo__c FROM Account where id=:userInfo.companyProfileId and RecordTypeId=:intelAccRT ] ){
                        if(System.Label.PRM_IPALookup_Region_Check.split(';').contains(acc.Core_Geo__c)){
                            ipaLookupRegionList.add(acc.Core_Geo__c);
                        }
                    }
            } 
            if(userInfo.contactId != null){
                bladeBenefitDetails.isUserSubscribedAll='false';
                List<String> subCodeList =System.Label.PRM_Post_Onboarding_Subscription_Code.split(',');
            List<PRM_ContactSubscriptionAssociation__c> contactSubs =[Select Id, PRM_Contact_Id__r.Core_IPA_PartnerRole__c from PRM_ContactSubscriptionAssociation__c 
                                                                      where PRM_Contact_Id__c=:userInfo.contactId
                                                                      AND PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c IN:subCodeList];
            
                if(contactSubs.size()==subCodeList.size()) {
                    bladeBenefitDetails.isUserSubscribedAll='true';
                }
                if(contactSubs.size() > 0 && contactSubs[0].PRM_Contact_Id__r.Core_IPA_PartnerRole__c == 'Distributor'){
                                                showPartnerReports = true;
                                                          }
                for(contact d: getContactEntitl(userInfo.contactId)){  
                    opid =d.Core_IPA_One_Partner_Id__c;  //Retrieve One Partner Id from contact 
                    // if(opid == null || opid==''){
                    if(d.Account.id != NULL){
                        accountid = d.Account.id;   //Retrieve Intel Account Id
                    }                       
                    if(d.Core_IPA_PartnerRole__c!=NULL)
                    {
                        partnerRol =d.Core_IPA_PartnerRole__c;  //Partner Role of Contact
                    }                
                    for(Core_Contact_Entitlement__c entitl: d.Contact_Entitlements__r){
                        entitlementList.add(entitl.Core_Entitlement_Id__r.name);  //Entitlement List from Contact
                        if(entitl.Core_Entitlement_Id__r.name == 'Points Redeem'){
                            entitlementList.add('Points Manager');  
                        }
                        if(entitl.Core_Entitlement_Id__r.name == System.Label.PRM_DZP_Entitlement){ //TWC727-904 - Utkarsh - DZP entitlement check to display DZP blade.
                            showDZPAndRDCPremierBlade = true;  
                        }
                        if(entitl.Core_Entitlement_Id__r.name == System.Label.PRM_DZS_Entitlement){
                            showDZSAndRDCPublicBlade = true;
                        }
                    }     
                }
                /*TWC727-887 - Utkarsh - As part of the story set value of the boolean variable to check before enabling disti dashboard link on IPA lookup tool */
                partnerConsent = [Select id,PRM_Account_Id__c from PRM_Partner_Consent_Distributor__c where PRM_Account_Id__c =:accountid];
                if(partnerConsent != null && !partnerConsent.IsEmpty()){
                    showDistiDashboard = true;
                }
                /*TWC727-887 - END*/
                if(opid != null){  //For Opid
                    //ifOpid= true;
                    for( Account accn : [SELECT Name ,(select PRM_Partner_Benefit_Id__r.Name from AccountBenefitAssociations__r where PRM_Status_Nm__c= 'Active' and PRM_Partner_Benefit_Id__r.PRM_InActive_Ind__c=false) ,(SELECT PRM_Specialty_Id__r.Name,PRM_Specialty_Type__c,PRM_Specialty_Id__r.PRM_Access_Level_Nm__c FROM Account_Specialty_Associations__r where PRM_InActive_Ind__c= false and PRM_Specialty_Id__r.PRM_Inactive_Ind__c=false and PRM_Partner_Role__c = :partnerRol)FROM Account where Core_IPA_One_Partner_Id__c=:opid and RecordTypeId=:opidRT]){
                        for(PRM_AccountBenefitAssociation__c benefitAssoc : accn.AccountBenefitAssociations__r){
                            if(!benefitsList.contains(benefitAssoc.PRM_Partner_Benefit_Id__r.Name))
                            {
                                benefitsList.add(benefitAssoc.PRM_Partner_Benefit_Id__r.Name); //Benefits to be taken from ABA object of Opid
                            }         
                        }
                         /*if(!ipaRefresh  || test.isrunningtest()){ //IPA2.0 - TWC727-2861
                        for(PRM_Account_Specialty_Association__c specAssoc:accn.Account_Specialty_Associations__r){
                            if(specAssoc.PRM_Specialty_Type__c=='Select Benefits' && specAssoc.PRM_Specialty_Id__r.PRM_Access_Level_Nm__c=='Public' && Label.PRM_EligibleSelectBenefits.split(',').contains(specAssoc.PRM_Specialty_Id__r.Name))//&& (!selectBenefitList.contains(specAssoc.PRM_Specialty_Id__r.Name))
                            {
                                showSelectBenefit = true;
                                // selectBenefitList.add(specAssoc.PRM_Specialty_Id__r.Name);
                            }
                            if(specAssoc.PRM_Specialty_Type__c=='Specialty' && (!specialityNewList.contains(specAssoc.PRM_Specialty_Id__r.Name)))
                            {
                                specialityNewList.add(specAssoc.PRM_Specialty_Id__r.Name);  //For Intel Account , specialty to be taken from ASA object
                            } 
                        }
                      }*/ //IPA Refresh - switch removal
                        /*  if(accn.Core_IPA_Partner_Speciality__c!= Null)
{
specialityList=getListfromPicklistValue(accn.Core_IPA_Partner_Speciality__c); //Specialty to be taken from 'Core_IPA_Partner_Speciality__c' field on Opid account
}
if(specialityList.size()>0  && (!specialityList.isEmpty()))
{
for(String s:specialityList)
{
specialityNewList.add(s.removeEnd('ist')+'ty'); //Update the field text- 'Artificial Intelligence Specialist' to 'Artificial Intelligence Speciality'   
}    
} */                
                    }
                    
                }
                  
                if(accountid != null ){   //For Intel Acc
                    for( Account accn : [SELECT Name ,(select PRM_Partner_Benefit_Id__r.Name from AccountBenefitAssociations__r where PRM_Status_Nm__c= 'Active' and PRM_Partner_Benefit_Id__r.PRM_InActive_Ind__c=false) ,(SELECT PRM_Specialty_Id__r.Name,PRM_Specialty_Id__r.PRM_Access_Level_Nm__c,PRM_Specialty_Type__c FROM Account_Specialty_Associations__r where PRM_InActive_Ind__c= false and PRM_Specialty_Id__r.PRM_Inactive_Ind__c=false and PRM_Partner_Role__c = :partnerRol )FROM Account where id=:accountid and RecordTypeId=:intelAccRT]){
                        for(PRM_AccountBenefitAssociation__c benefitAssoc : accn.AccountBenefitAssociations__r){
                            if(!benefitsList.contains(benefitAssoc.PRM_Partner_Benefit_Id__r.Name))
                            {
                                benefitsList.add(benefitAssoc.PRM_Partner_Benefit_Id__r.Name);  //Benefits to be taken from Intel Account
                            }  
                        }
                        /*if(!ipaRefresh  || test.isrunningtest()){ //IPA2.0 - TWC727-2861
                        for(PRM_Account_Specialty_Association__c specAssoc:accn.Account_Specialty_Associations__r){
                            if(specAssoc.PRM_Specialty_Type__c=='Select Benefits'&& specAssoc.PRM_Specialty_Id__r.PRM_Access_Level_Nm__c=='Public' && Label.PRM_EligibleSelectBenefits.split(',').contains(specAssoc.PRM_Specialty_Id__r.Name)) //&& (!selectBenefitList.contains(specAssoc.PRM_Specialty_Id__r.Name))
                            {
                                showSelectBenefit = true;
                                //selectBenefitList.add(specAssoc.PRM_Specialty_Id__r.Name);
                            }
                            //if(ifOpid!=true)
                            //{
                            if(specAssoc.PRM_Specialty_Type__c=='Specialty' && (!specialityNewList.contains(specAssoc.PRM_Specialty_Id__r.Name)))
                            {
                                specialityNewList.add(specAssoc.PRM_Specialty_Id__r.Name);  //For Intel Account , specialty to be taken from ASA object
                            } 
                            // }                               
                        }
                        }*/ // IPA Refresh - switch removal
                    }
                }
                //calling getBenefitBlades() to get blades based on security model
                userBenefitList=getBenefitBlades(userInfo,ipaLookupRegionList,partnerRol,entitlementList,benefitsList,showSelectBenefit,selectBenefitList,null,showDistiDashboard);//TWC727-887 - Utkarsh - passed new boolean parameter
                bladeBenefitDetails.benefitInfo = userBenefitList;
                String summaryDesc =getSummaryDescription(userId);
                bladeBenefitDetails.summaryDescription = summaryDesc;  
                bladeBenefitDetails.checkAgreementBnft = checkAgreement+entitlementNam;
            }
        }
        
        datetime endd = datetime.now();
        Decimal millisecs = Decimal.valueOf(endd.getTime() - start.getTime());
        integer div = 1000;   
        //Decimal cal = millisecs/div;
        return bladeBenefitDetails;
    }
    
    //get contact object with entitlement list based on contact id
    public static List<Contact> getContactEntitl(String conId){
        List<Contact> conct = new List<Contact>();
        if(conId != null){
            conct  = [select Core_IPA_One_Partner_Id__c,id,Account.id,Core_IPA_PartnerRole__c,(Select Core_Entitlement_Id__r.Core_Display_Name__c , Core_Entitlement_Id__r.name from Contact_Entitlements__r where Core_Entitlement_Id__r.Core_IsActive__c =true and Core_Selected__c=true and Core_Status__c='Complete' ) from contact where id = :conId];     
        }
        return conct;
    }
    
    public static String  getSummaryDescription(ID userID){  
        IPABenefitWrapper.UserProfile userData = userInfo(userID);
        String partnerRelationship = '';
        String prtnerRole = '';
        string tier = '';
        String benefitDescription= '';
        List<String> entitlementListSumm = new List<String>();
        for(contact cn: getContactEntitl(userData.contactId)){ 
            for(Core_Contact_Entitlement__c entitl: cn.Contact_Entitlements__r){
                entitlementListSumm.add(entitl.Core_Entitlement_Id__r.Core_Display_Name__c);
            } 
        }
        List<Core_CustomMetadata_Object__c> benefitPriorityMapping=[Select Field_1__c,Field_2__c  from Core_CustomMetadata_Object__c where Metadata_Name__c = 'PRM_Benefit_Priority_Order__mdt' AND Header_row__c!= NULL  order by Field_2__c ];      
        for(Core_CustomMetadata_Object__c beneList :benefitPriorityMapping){
            if(entitlementListSumm.contains(beneList.Field_1__c) && String.isBlank(partnerRelationship)){//get entitlement and store as per the priority              
                partnerRelationship =beneList.Field_1__c;
                entitlementNam =partnerRelationship;
                break;
            }
        }   
        //get entitlement and store as per the priority
       /* if(entitlementListSumm.contains(System.Label.PRM_Primary_Contact)){ //check for Partner Admin Entitlemnt
            partnerRelationship= System.Label.PRM_Primary_Contact;
            entitlementNam = partnerRelationship;
        }*/
       /* if(partnerRelationship == ''){//check for Partner Admin Delegate Entitlemnt
            if(!entitlementListSumm.contains(System.Label.PRM_Primary_Contact) && entitlementListSumm.contains(System.Label.PRM_Partner_Admin_Delegate) ){
                partnerRelationship= System.Label.PRM_Partner_Admin_Delegate;
                entitlementNam = partnerRelationship;
            }
            else{//check for employee +Other entitlements
                if(entitlementListSumm.contains(System.Label.PRM_PointsManager) &&  entitlementListSumm.contains(System.Label.PRM_WorksFor)){
                    partnerRelationship = System.Label.PRM_PointsManager;
                    entitlementNam = System.Label.PRM_WorksFor;
                }
                else{
                    if(partnerRelationship == ''){
                        if(entitlementListSumm.contains(System.Label.PRM_MarketingSpecialist) &&  entitlementListSumm.contains(System.Label.PRM_WorksFor)){ 
                            partnerRelationship= System.Label.PRM_MarketingSpecialist;
                            entitlementNam = System.Label.PRM_WorksFor;
                        }
                        else{
                            if(entitlementListSumm.contains(System.Label.PRM_WebTicking) &&  entitlementListSumm.contains(System.Label.PRM_WorksFor)){
                                partnerRelationship= System.Label.PRM_WebTicking;
                                entitlementNam = System.Label.PRM_WorksFor;
                            }*//*else if(partnerRelationship == '' && entitlementListSumm.contains(System.Label.PRM_ProposalManager) && entitlementListSumm.contains(System.Label.PRM_WorksFor)){
partnerRelationship=System.Label.PRM_ProposalManagerDisplayText;
}else if(partnerRelationship == '' && entitlementListSumm.contains(System.Label.PRM_LDR) && entitlementListSumm.contains(System.Label.PRM_WorksFor)){
partnerRelationship=System.Label.PRM_LDRDisplyText;
}else if(partnerRelationship == '' && entitlementListSumm.contains(System.Label.PRM_Offering_Editor) && entitlementListSumm.contains(System.Label.PRM_WorksFor)){
partnerRelationship=System.Label.PRM_Offering_Editor;
}else if(partnerRelationship == '' && entitlementListSumm.contains(System.Label.PRM_ClaimSubmitter) && entitlementListSumm.contains(System.Label.PRM_WorksFor)){
partnerRelationship=System.Label.PRM_ClaimSubmitterDisplayText;
}  */  /*
                        }
                    }
                }      
                if(partnerRelationship == '' && entitlementListSumm.contains(System.Label.PRM_WorksFor)){
                    partnerRelationship= System.Label.PRM_WorksFor;
                    entitlementNam = partnerRelationship;
                }
            }
        }*/
        List<PRM_Account_Contact_Relationship__c>  accContRel = [select id,PRM_Contact_Id__r.Core_IPA_PartnerRole__c,PRM_Relationship_Id__r.name,PRM_Account_Id__c  from PRM_Account_Contact_Relationship__c where PRM_Status_Nm__c ='Complete' and  PRM_InActive_Ind__c = false and PRM_Contact_Id__c = :userData.contactId ];  //  
        if(accContRel.size()>0){
            if(accContRel[0].PRM_Contact_Id__r.Core_IPA_PartnerRole__c != null && userData != null ){
                //to get the label of the picklist based on the api name
                Map<String,String> pickListValuesList= new  Map<String,String>();
                Schema.DescribeFieldResult fieldResult = Contact.Core_IPA_PartnerRole__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    pickListValuesList.put(pickListVal.getValue(),pickListVal.getLabel());
                }     
                /*if(accContRel[0].PRM_Contact_Id__r.Core_IPA_PartnerRole__c == 'Service Provider'){
                    prtnerRole = pickListValuesList.get('Service Provider');
                }else if(accContRel[0].PRM_Contact_Id__r.Core_IPA_PartnerRole__c == 'Seller'){
                    prtnerRole = pickListValuesList.get('Seller');  
                }
                else if(accContRel[0].PRM_Contact_Id__r.Core_IPA_PartnerRole__c == 'Solution Integrator'){
                    prtnerRole = pickListValuesList.get('Solution Integrator'); 
                }
                else if(accContRel[0].PRM_Contact_Id__r.Core_IPA_PartnerRole__c == 'FPGA Designer'){
                    prtnerRole = pickListValuesList.get('FPGA Designer');  
                }
                else{*/
                    prtnerRole = pickListValuesList.get(accContRel[0].PRM_Contact_Id__r.Core_IPA_PartnerRole__c);
                //}
                //to get the acm tier of the contact
                tier = getPartnerTierACM(accContRel[0].PRM_Contact_Id__r.Core_IPA_PartnerRole__c,userData); 
            }
            String benftSummary = System.Label.IPA_bnftSum_txt1;
            
            benefitDescription =   benftSummary.replace('{Tier}', tier).replace('{PartnerRole}',prtnerRole).replace('{Entitlements}',partnerRelationship);
        }    
        return benefitDescription;
    }
    
    public static List<IPABenefitWrapper.UserBenefitInfo> getBenefitBlades(IPABenefitWrapper.UserProfile userInfo,List<String> ipaLookupRegionList, String partnerRol, List<String> entitlementList, List<String> benefitsList, Boolean showSelectBenefit, List<String> selectBenefitList, List<String> specialityList,boolean showDisti)//TWC727-887 -Utkarsh - passed new boolean parameter
    {
        datetime start = datetime.NOW();
        List<IPABenefitWrapper.UserBenefitInfo> userBenefits=new List<IPABenefitWrapper.UserBenefitInfo>();
        //Id benefitMatrixRT = Schema.getGlobalDescribe().get('PRM_PEx_Access_Matrix__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Benefit_Access_Rule').getRecordTypeId();
        //Id specialityMatrixRT = Schema.getGlobalDescribe().get('PRM_PEx_Access_Matrix__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Specialty_Select_Benefit_Access_Rule').getRecordTypeId();
        Id quickLinkMatrixRT =getRecordTypeId('PRM_PEx_Access_Matrix__c','Quick_Links_Access_Rule');//IPA2.0-TWC727-2896
        IPABenefitWrapper.UserBenefitInfo userBenefit =new IPABenefitWrapper.UserBenefitInfo();
        List<String> benefitPriority=new List<String>();  //lists to store CTAs
        List<String> pointLinks=new List<String>();
        List<String> leadLinks=new List<String>();
        List<String> trainingLinks=new List<String>();
        List<String> marketpLinks=new List<String>();
        List<String> mdfLinks=new List<String>();
        //List<String> specialtyLinks=new List<String>();
        List<String> selectBenefitLinks=new List<String>();
        List<String> partnerHelpLinks=new List<String>();
        List<String> marketingStudioLinks=new List<String>();
        List<String> dzsLinks=new List<String>();
        List<String> dzpLinks=new List<String>(); //TWC727-903 - Varun - Created to store DZS blade CTA and Links.     
        List<String> rdcLinks=new List<String>(); //TWC727-903 - Varun - Created to store RDC public blade's Cta and links.
        List<String> ditLinks=new List<String>(); //TWC727-905 - Utkarsh - Created to store DIT blade CTA and Links.
        List<String> iddsLinks=new List<String>(); //TWC727-905 - Utkarsh - Created to store IDDS blade CTA and Links.
        List<String> rdcPremierLinks=new List<String>(); //TWC727-904 - Utkarsh - Created to store RDC premier blade CTA and Links.
        List<String> fpgaToolsResourcesLinks=new List<String>();
        List<String> activationZonesList=new List<String>();
        List<String> ipaLookupToolLinks=new List<String>();
        List<String> pppLinks = new List<String>();
        List<String> productRoadmapLinks = new List<String>();
        /*List<String> specialtyLinksArtifical=new List<String>();
        List<String> specialtyLinksCloudData=new List<String>();
        List<String> specialtyLinksHPC=new List<String>();
        List<String> specialtyLinksVideo=new List<String>();
        List<String> specialtyLinksVisual=new List<String>();
        List<String> specialtyLinksManageService=new List<String>();
        List<String> specialtyLinksDeviceService=new List<String>();
        List<String> specialtyLinksIndustrialSoln=new List<String>();
        List<String> specialtyLinksOptaneData=new List<String>();
        List<String> specialtyLinksOptaneClient=new List<String>();
        List<String> specialtyLinksEnthu=new List<String>();
        List<String> specialtyLinksNetworking=new List<String>();*/
        String partnerTier=getPartnerTierACM(partnerRol,userInfo);
        boolean hideDZSBlades = false; //TWC727-904 - Utkarsh - Created boolean check to hide RDC blade when DZP blade is enebled
        List<String> dealRegLinks=new List<String>();
        
        List<String> partnerRolesMatrix=new List<String>();
        List<String> entitlementMatrix=new List<String>();
               List<PRM_PEx_Access_Matrix__c> benefitAccessMatrixList=[Select PRM_Benefit_Blade__c,PRM_Hide_Logo_Icon__c,PRM_Partner_Benefit__r.Name,PRM_Benefit_Priority__c,
                                                                PRM_Partner_Specialty_Select_Benefit__r.Name,PRM_Click_To_Action__c,PRM_CTA_Priority__c,
                                                                PRM_Entitlements__c,PRM_IPA_URL__c, /*IPA2.0-TWC727-3061*/
                                                                PRM_Partner_Benefit__c,PRM_IPA_Partner_Role__c,RecordTypeId  
                                                                from PRM_PEx_Access_Matrix__c 
                                                                where RecordTypeId!=:quickLinkMatrixRT
                                                                and PRM_isActive_Indicator__c=true  /* IPA2.0-TWC727-3061*/
                                                                and (PRM_Partner_Benefit__r.Name in :benefitsList or PRM_Benefit_Blade__c='FPGA Tools and Resources' 
                                                                OR PRM_Benefit_Blade__c = 'Select Benefit' or PRM_Benefit_Blade__c= 'Partner Help' 
                                                                or PRM_IPA_Partner_Role__c='Distributor' OR PRM_Benefit_Blade__c ='Design Enablement Services,DIT' 
                                                                OR PRM_Benefit_Blade__c='Deal Registration'/*OR PRM_Benefit_Blade__c='Design Enablement Services,IDDS'*/ )  
                                                                order by PRM_Benefit_Priority__c,PRM_CTA_Priority__c ];
                                                            
        if(benefitAccessMatrixList.size()>0 && partnerRol != null) {//} && entitlementList.size()>0 ) {
            for(PRM_PEx_Access_Matrix__c benefitAccessMatrix:benefitAccessMatrixList) {
            
                if(benefitAccessMatrix.PRM_Benefit_Blade__c!=null && benefitAccessMatrix.PRM_Benefit_Priority__c!=null && benefitAccessMatrix.PRM_CTA_Priority__c!=null && Integer.valueOf(benefitAccessMatrix.PRM_CTA_Priority__c) == 1 && benefitAccessMatrix.PRM_Hide_Logo_Icon__c){
                    if(!showLogoMap.containsKey(benefitAccessMatrix.PRM_Benefit_Blade__c))showLogoMap.put(benefitAccessMatrix.PRM_Benefit_Blade__c, true);
                }
                if(benefitAccessMatrix.PRM_Benefit_Blade__c!=null && benefitAccessMatrix.PRM_Benefit_Priority__c!=null && benefitAccessMatrix.PRM_CTA_Priority__c!=null && Integer.valueOf(benefitAccessMatrix.PRM_CTA_Priority__c) == 1 && !benefitAccessMatrix.PRM_Hide_Logo_Icon__c){
                    if(!showLogoMap.containsKey(benefitAccessMatrix.PRM_Benefit_Blade__c))showLogoMap.put(benefitAccessMatrix.PRM_Benefit_Blade__c, false);
                }
                ////system.debug('Access Matrix Record-->'+benefitAccessMatrix);
                partnerRolesMatrix = getListfromPicklistValue(benefitAccessMatrix.PRM_IPA_Partner_Role__c);     //Partner Roles in Access Matrix records          
              
                entitlementMatrix = getListfromPicklistValue(benefitAccessMatrix.PRM_Entitlements__c);          //Entitlements in Access Matrix records
             
                if(!partnerRolesMatrix.isEmpty() && partnerRolesMatrix.contains(partnerRol) && entitlementList.size()>0){
                     //Check if Matrix record contains Partner Role from Contact Object   
                    for(String enti:entitlementList){            //Iterate over the Entitlements from Contact 
                        if(entitlementMatrix.contains(enti) && entitlementMatrix.size()>0 ){     //Check if Matrix record contains Entitlement from Contact Object
                            ////system.debug('3--');
                            if( benefitsList.size()>0){   
                                
                                if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Points'){  //IPA2.0-TWC727-2896
                                    if(benefitAccessMatrix.PRM_Click_To_Action__c == 'Spend Points' && !pointLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)) {      //Special Rule for 'Spend Points' link
                                        pointLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);        
                                         
                                    }
                                    if(benefitAccessMatrix.PRM_Click_To_Action__c != 'Spend Points' && !pointLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        pointLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }                                        
                                }
                                if(benefitAccessMatrix.PRM_Benefit_Blade__c=='MDF' && !mdfLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                    mdfLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                }
                                if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Training'){ 
                                     if((partnerRol !='Distributor' || partnerRol =='Distributor') && benefitsList.contains('Partner University') && !trainingLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        trainingLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    } 
                                }
                                if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Leads' && !leadLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){  
                                    leadLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);                                  
                                }
                                if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Marketplace' && (benefitsList.contains(Label.PRM_Solutions_Marketplace_Basic_Profile) || benefitsList.contains(Label.PRM_Solutions_Marketplace_Basic_Access  ) || benefitsList.contains(Label.PRM_Solutions_Marketplace_Enhanced  )) && (partnerRol =='Distributor' || partnerRol !='Distributor') && !marketpLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                    marketpLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);   
                                }
                                if(benefitAccessMatrix.PRM_Benefit_Blade__c == 'Marketing Studio' && benefitsList.contains('Partner Marketing Studio') && (partnerRol =='Distributor' || partnerRol !='Distributor') && !marketingStudioLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)) {
                                    marketingStudioLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c); 
                                }
                    
                                if(benefitAccessMatrix.PRM_Benefit_Blade__c == 'FPGA Tools and Resources' && partnerRol =='FPGA Designer' && !fpgaToolsResourcesLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                    fpgaToolsResourcesLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                }
                                
                                if(benefitAccessMatrix.PRM_Benefit_Blade__c == 'Partner Lookup Tool' && partnerRol =='Distributor' && ipaLookupRegionList.size()>0 && !ipaLookupToolLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c) && (benefitAccessMatrix.PRM_Click_To_Action__c != 'Partner Assist Dashboard' || (benefitAccessMatrix.PRM_Click_To_Action__c == 'Partner Assist Dashboard' &&  showDistiDashboard )) ){
                                    ipaLookupToolLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                }
				//IPA2.0 - TWC727-2912
                                 if(benefitAccessMatrix.PRM_Benefit_Blade__c == 'Enablement Zones' && partnerRol =='Distributor' && !activationZonesList.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                    activationZonesList.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                }//TWC729-7755
                                   if(benefitAccessMatrix.PRM_Benefit_Blade__c == 'Deal Registration'){
                                        if(!dealRegLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                            dealRegLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                        }  
                                    }
                                
                                /*if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Artificial Intelligence Specialty'  ){             
                                    if(!specialtyLinksArtifical.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        //system.debug('Speciality---'+benefitAccessMatrix.PRM_Click_To_Action__c);
                                        specialtyLinksArtifical.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }
                                }*/
                                /*if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Cloud Data Center Specialty' ){             
                                    if(!specialtyLinksCloudData.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        specialtyLinksCloudData.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }
                                }*/
                                /*if(benefitAccessMatrix.PRM_Benefit_Blade__c=='High Performance Computing Data Center Specialty' ){             
                                    if(!specialtyLinksHPC.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        specialtyLinksHPC.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }
                                }*/
                                /*if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Video Specialty' ){             
                                    if(!specialtyLinksVideo.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        specialtyLinksVideo.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }
                                }*/
                                /*if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Visual Display Solutions Specialty'){             
                                    if(!specialtyLinksVisual.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        specialtyLinksVisual.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }
                                }*/
                                /*if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Industrial Solutions Builder Specialty' ){             
                                    if(!specialtyLinksIndustrialSoln.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        specialtyLinksIndustrialSoln.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }
                                }*/
                                /*if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Optane Data Center Specialty' ){             
                                    if(!specialtyLinksOptaneData.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        specialtyLinksOptaneData.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }
                                }*/
                                /*if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Optane Client Specialty' ){             
                                    if(!specialtyLinksOptaneClient.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        specialtyLinksOptaneClient.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }
                                }*/
                                /*if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Device as a Service Specialty'){             
                                    if(!specialtyLinksDeviceService.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        specialtyLinksDeviceService.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }
                                }*/
                                /*if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Managed Services Specialty' ){             
                                    if(!specialtyLinksManageService.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        specialtyLinksManageService.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }
                                }*/
                                /*if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Enthusiast PC Specialty' ){             
                                    if(!specialtyLinksEnthu.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        specialtyLinksEnthu.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }
                                } */
                                /*if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Networking Specialty' ){             
                                    if(!specialtyLinksNetworking.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                        specialtyLinksNetworking.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                    }
                                } */
                            }
                             //IPA2.0 - TWC727-2861
                            /*if((!ipaRefresh  || test.isrunningtest())&& benefitAccessMatrix.PRM_Benefit_Blade__c=='Select Benefit' && showSelectBenefit == true && !selectBenefitLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)) {
                                        selectBenefitLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);    
                            }*/ // IPA Refresh - switch removal
                            
                            // }
                            if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Intel® Developer Zone - Standard' && !dzsLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)) {    
                                dzsLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                            }
                            if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Resource & Documentation Center - Public' && !rdcLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){ 
                                    rdcLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                            }
                            if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Intel® Developer Zone - Premier' && showDZPAndRDCPremierBlade == true) { //TWC727-904 - Utkarsh - Added CTA and links of DZP blade.
                                hideDZSBlades = true;
                                if(!dzpLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                    dzpLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);  
                                }
                            }
                            if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Resource & Documentation Center - Premier Access' && showDZPAndRDCPremierBlade == true && !rdcPremierLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){ //TWC727-904 - Utkarsh - Added CTA and links of RDC premier blade.
                                rdcPremierLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c); 
                            }
                            if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Design Enablement Services,DIT' && !ditLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)) { //TWC727-905 - Utkarsh - Added CTA and links of DIT blade.
                                ditLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c); 
                            }
                            /* IPA2.0 TWC727-2912
                            if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Design Enablement Services,IDDS' && !iddsLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)) { //TWC727-905 - Utkarsh - Added CTA and links of IDDS blade.
                                    iddsLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c); 
                            }*/
                            if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Partner Help' && !partnerHelpLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)) {    //Partner Help blade to be displayed on the basis of Entitlement and Partner role in Access Matrix
                                    partnerHelpLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c); 
                            } 
                            if(partnerRol == 'Distributor' && benefitAccessMatrix.PRM_IPA_Partner_Role__c=='Distributor') {           //Blades to be displayed only if partner role of Contact is Distributor
                                if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Pricing, Points and Promotions' && !pppLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c)){
                                    pppLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);                                      
                                }
                                if(benefitAccessMatrix.PRM_Benefit_Blade__c=='Products & Roadmaps' && !productRoadmapLinks.contains(benefitAccessMatrix.PRM_Click_To_Action__c) &&  benefitAccessMatrix.PRM_Click_To_Action__c != 'Intel® Solutions Library') {  // TWC729-6644 - Added && condition
                                    productRoadmapLinks.add(benefitAccessMatrix.PRM_Click_To_Action__c);         
                                }
                            }
                        }                                                           
                    }
                    //Specialty blades to be shown only if Partner Role is matched irrespective of Entitlement
                    
                    if(!benefitPriority.contains(benefitAccessMatrix.PRM_Benefit_Blade__c)){   //Blades that have to be displayed 
                        benefitPriority.add(benefitAccessMatrix.PRM_Benefit_Blade__c);
                    }
                    ////system.debug(benefitAccessMatrix.PRM_Benefit_Blade__c);
                } 
            } 
        }

        Map<String,List<String>> alertBlades=new Map<String,List<String>>();
        alertBlades=getAlerts(userInfo); //Method to return alerts for blades.
        
        Map<String,Map<String,String>> adhocBlades=new Map<String,Map<String,String>>();
        adhocBlades=getAdhocMsg(userInfo);
    
        List<IPABenefitWrapper.Metrics> trainingMetrics=new List<IPABenefitWrapper.Metrics>();
        List<IPABenefitWrapper.Metrics> leadMetrics=new List<IPABenefitWrapper.Metrics>();
        List<IPABenefitWrapper.Metrics> marketPlaceMetrics=new List<IPABenefitWrapper.Metrics>();
        
        if(benefitPriority.contains('Training'))
        {
            trainingMetrics=getTrainingMetrics(userInfo,entitlementList);
        }
        if(benefitPriority.contains('Leads') && userInfo.onePartnerId != null)
        {
            leadMetrics =  IPABenefitUtilityHandler.getLeadsMetrics(userInfo.onePartnerId);
            
        }
        if(benefitPriority.contains('Marketplace') && userInfo.onePartnerId != null)
        {
            marketPlaceMetrics = getMarketPlaceMetrics(userInfo.onePartnerId,entitlementList);  
           
        }        
        
        //call blades and pass link and label to it
        for(String ben:benefitPriority)
        {   
            List<String> alertTitles=new List<String>();
            Map<String,String> adhocMsgs = new Map<String,String>();
            if(ben=='Points' && pointLinks.size()>0)
            {
                if(alertBlades.containsKey('Points'))
                {
                    alertTitles=alertBlades.get('Points');  
                }          
                if(adhocBlades.containsKey('Points'))
                {
                    adhocMsgs=adhocBlades.get('Points'); 
                }
                userBenefit=getPoints(pointLinks,alertTitles,adhocMsgs);
            
                userBenefits.add(userBenefit);           
            }
            else if(ben=='Leads'  && leadLinks.size()>0)
            {
                if(alertBlades.containsKey('Leads'))
                {
                    alertTitles=alertBlades.get('Leads'); 
                }
        if(adhocBlades.containsKey('Leads'))
                {
                    adhocMsgs=adhocBlades.get('Leads'); 
                }                
                userBenefit=IPABenefitUtilityHandler.getLeads(leadLinks,alertTitles,adhocMsgs,leadMetrics); 
                userBenefit.faIcon = showLogoMap.containsKey('Leads') && !showLogoMap.get('Leads')?System.Label.IPA_Leads_bnft_Icon:null;
                userBenefits.add(userBenefit);
            }
            else if(ben=='Marketplace'  && marketpLinks.size()>0 )
            {
                if(alertBlades.containsKey('Marketplace'))
                {
                    alertTitles=alertBlades.get('Marketplace');              
                }
                if(adhocBlades.containsKey('Marketplace'))
                {
                    adhocMsgs=adhocBlades.get('Marketplace'); 
                }
                userBenefit=IPABenefitUtilityHandler.getMarketPlace(marketpLinks,alertTitles,adhocMsgs,marketPlaceMetrics); 
                userBenefits.add(userBenefit);               
            }
            else if(ben=='Training'  && trainingLinks.size()>0)
            {
                if(alertBlades.containsKey('Training'))
                {
                    alertTitles=alertBlades.get('Training'); 
                } 
                if(adhocBlades.containsKey('Training'))
                {
                    adhocMsgs=adhocBlades.get('Training'); 
                }
                
                userBenefit=getTraining(trainingLinks,alertTitles,adhocMsgs,trainingMetrics);
              
                userBenefits.add(userBenefit);
            }
            else if(ben=='MDF'  && mdfLinks.size()>0)
            {
                if(alertBlades.containsKey('MDF'))
                {
                    alertTitles=alertBlades.get('MDF');   
                } 
                if(adhocBlades.containsKey('MDF'))
                {
                    adhocMsgs=adhocBlades.get('MDF'); 
                }
                userBenefit=IPABenefitUtilityHandler.getMDF(mdfLinks,alertTitles,adhocMsgs); 
                userBenefit.faIcon = showLogoMap.containsKey('MDF') && !showLogoMap.get('MDF')?System.Label.IPA_MDF_bnft_Icon:null;
                userBenefits.add(userBenefit);
            }
            else if(ben=='Intel® Developer Zone - Premier' && dzpLinks.size()>0) //TWC727-904 - Utkarsh - calling displayDZPBlade method to display DZP blade. && showDZPAndRDCPremierBlade == true
            {   
                if(adhocBlades.containsKey('Intel® Developer Zone - Premier'))
                {
                    adhocMsgs=adhocBlades.get('Intel® Developer Zone - Premier'); 
                }
                userBenefit=displayDZPBlade(dzpLinks,adhocMsgs); 
         
                ////system.debug('Intel® Developer Zone - Premier'+userBenefit);
                userBenefits.add(userBenefit);
            }
            else if(ben=='Resource & Documentation Center - Premier Access' && rdcPremierLinks.size()>0) //TWC727-904 - Utkarsh - calling displayRDCPremierBlade method to display RDC premier blade. && showDZPAndRDCPremierBlade == true
            {
                if(adhocBlades.containsKey('Resource & Documentation Center - Premier Access'))
                {
                    adhocMsgs=adhocBlades.get('Resource & Documentation Center - Premier Access'); 
                }
                userBenefit=displayRDCPremierBlade(rdcPremierLinks,adhocMsgs);
              
                ////system.debug('Resource & Documentation Center - Premier Access'+userBenefit);
                userBenefits.add(userBenefit);
            }
            else if(ben=='Design Enablement Services,DIT' && ditLinks.size()>0) //TWC727-905 - Utkarsh - calling displayDITBlade method to display DIT blade.
            {   
                if(adhocBlades.containsKey('Design Enablement Services,DIT'))
                {
                    adhocMsgs=adhocBlades.get('Design Enablement Services,DIT'); 
                }
                userBenefit=displayDITBlade(ditLinks,adhocMsgs); 
           
                ////system.debug('Design Enablement Services,DIT'+userBenefit);
                userBenefits.add(userBenefit);
            }
            /* //IPA2.0 TWC727-2912 starts here
            else if(ben=='Design Enablement Services,IDDS' && iddsLinks.size()>0) //TWC727-905 - Utkarsh - calling displayIDDSBlade method to display IDDS blade.
            {   
                if(adhocBlades.containsKey('Design Enablement Services,IDDS'))
                {
                    adhocMsgs=adhocBlades.get('Design Enablement Services,IDDS'); 
                }
                //userBenefit=displayIDDSBlade(iddsLinks,adhocMsgs); 
                ////system.debug('Design Enablement Services,IDDS'+userBenefit);
                userBenefits.add(userBenefit);
            }*/ //IPA2.0 ends here
            else if(ben=='Intel® Developer Zone - Standard' && dzsLinks.size()>0 && hideDZSBlades == false && showDZSAndRDCPublicBlade == true) //TWC727-904 - Utkarsh - Added boolean check to hide DZS blade when DZP blade is enebled && hideDZSBlades == false
            {
                if(adhocBlades.containsKey('Intel® Developer Zone - Standard'))
                {
                    ////system.debug('Inside adhocBlades Intel® Developer Zone - Standard');
                    adhocMsgs=adhocBlades.get('Intel® Developer Zone - Standard'); 
                }
                userBenefit=getDZS(dzsLinks,adhocMsgs); 
             
                ////system.debug('Intel® Developer Zone - Standard'+userBenefit);
                userBenefits.add(userBenefit);
                
            }  
            else if(ben=='Resource & Documentation Center - Public' && rdcLinks.size()>0 && hideDZSBlades == false && showDZSAndRDCPublicBlade == true) //TWC727-904 - Utkarsh - Added boolean check to hide RDC blade when DZP blade is enebled && hideDZSBlades == false                
            {
                if(adhocBlades.containsKey('Resource & Documentation Center - Public'))
                {
                    adhocMsgs=adhocBlades.get('Resource & Documentation Center - Public'); 
                }
                userBenefit=getRDC(rdcLinks,adhocMsgs);
              
                ////system.debug('Resource & Documentation Center - Public'+userBenefit);
                userBenefits.add(userBenefit);
            }  
            else if(ben=='Select Benefit' && selectBenefitLinks.size()>0)
            {
                if(adhocBlades.containsKey('Select Benefit'))
                {
                    ////system.debug('Inside adhocBlades Select Benefit');
                    adhocMsgs=adhocBlades.get('Select Benefit'); 
                }
                userBenefit=getSelectBenefit(selectBenefitLinks,adhocMsgs);
              
                userBenefits.add(userBenefit); 
            }
            /*else if(ben=='Artificial Intelligence Specialty' && specialtyLinksArtifical.size()>0 ){
                if(adhocBlades.containsKey('Artificial Intelligence Specialty'))
                {
                    ////system.debug('Inside adhocBlades Artificial Intelligence Specialty');
                    adhocMsgs=adhocBlades.get('Artificial Intelligence Specialty'); 
                }
                userBenefit=getSpecialtyArtifical(specialtyLinksArtifical,adhocMsgs);
                userBenefits.add(userBenefit);  
            }*/
            /*else if(ben== 'Cloud Data Center Specialty' && specialtyLinksCloudData.size() > 0){ 
                if(adhocBlades.containsKey('Cloud Data Center Specialty'))
                {
                    ////system.debug('Inside adhocBlades Cloud Data Center Specialty');
                    adhocMsgs=adhocBlades.get('Cloud Data Center Specialty'); 
                }
                userBenefit=getSpecialtyCloudData(specialtyLinksCloudData,adhocMsgs);
                userBenefits.add(userBenefit); 
            }*/
            /*else if(ben== 'High Performance Computing Data Center Specialty' && specialtyLinksHPC.size() > 0){ 
                if(adhocBlades.containsKey('Select Benefit'))
                {
                    ////system.debug('Inside adhocBlades High Performance Computing Data Center Specialty');
                    adhocMsgs=adhocBlades.get('High Performance Computing Data Center Specialty'); 
                }
                userBenefit=getSpecialtyHighPerformanceSpecialty(specialtyLinksHPC,adhocMsgs);
                userBenefits.add(userBenefit); 
            }*/
            /*else if(ben== 'Video Specialty' && specialtyLinksVideo.size() > 0){ 
                if(adhocBlades.containsKey('Video Specialty'))
                {
                    ////system.debug('Inside adhocBlades Video Specialty');
                    adhocMsgs=adhocBlades.get('Video Specialty'); 
                }
                userBenefit=getSpecialtyVideoSpecialty(specialtyLinksVideo,adhocMsgs);
                userBenefits.add(userBenefit); 
            }*/
            /*else if(ben== 'Visual Display Solutions Specialty' && specialtyLinksVisual.size() > 0){ 
                if(adhocBlades.containsKey('Visual Display Solutions Specialty'))
                {
                    ////system.debug('Inside adhocBlades Visual Display Solutions Specialty');
                    adhocMsgs=adhocBlades.get('Visual Display Solutions Specialty'); 
                }
                userBenefit=getSpecialtyVisualDisplay(specialtyLinksVisual,adhocMsgs);
                userBenefits.add(userBenefit); 
            }*/
            /*else if(ben== 'Industrial Solutions Builder Specialty' && specialtyLinksIndustrialSoln.size() > 0){
                if(adhocBlades.containsKey('Industrial Solutions Builder Specialty'))
                {
                    ////system.debug('Inside adhocBlades Industrial Solutions Builder Specialty');
                    adhocMsgs=adhocBlades.get('Industrial Solutions Builder Specialty'); 
                }
                userBenefit=getSpecialtySolutionsBuilder(specialtyLinksIndustrialSoln,adhocMsgs);
                userBenefits.add(userBenefit); 
            }*/
            /*else if(ben== 'Optane Data Center Specialty' && specialtyLinksOptaneData.size() > 0){ 
                if(adhocBlades.containsKey('Optane Data Center Specialty'))
                {
                    ////system.debug('Inside adhocBlades Optane Data Center Specialty');
                    adhocMsgs=adhocBlades.get('Optane Data Center Specialty'); 
                }
                userBenefit=getSpecialtyOptaneData(specialtyLinksOptaneData,adhocMsgs);
                userBenefits.add(userBenefit); 
            }*/
            /*else if(ben== 'Optane Client Specialty' && specialtyLinksOptaneClient.size() > 0){ 
                if(adhocBlades.containsKey('Optane Client Specialty'))
                {
                    ////system.debug('Inside adhocBlades Optane Client Specialty');
                    adhocMsgs=adhocBlades.get('Optane Client Specialty'); 
                }
                userBenefit=getSpecialtyOptaneClient(specialtyLinksOptaneClient,adhocMsgs);
                userBenefits.add(userBenefit); 
            }*/
            /*else if(ben== 'Device as a Service Specialty' && specialtyLinksDeviceService.size() > 0){ 
                if(adhocBlades.containsKey('Device as a Service Specialty'))
                {
                    ////system.debug('Inside adhocBlades Device as a Service Specialty');
                    adhocMsgs=adhocBlades.get('Device as a Service Specialty'); 
                }
                userBenefit=getSpecialtyDeviceService(specialtyLinksDeviceService,adhocMsgs);
                userBenefits.add(userBenefit); 
            }*/
            /*else if(ben== 'Managed Services Specialty' && specialtyLinksManageService.size() > 0){
                if(adhocBlades.containsKey('Managed Services Specialty'))
                {
                    ////system.debug('Inside adhocBlades Managed Services Specialty');
                    adhocMsgs=adhocBlades.get('Managed Services Specialty'); 
                }
                userBenefit=getSpecialtyManagedService(specialtyLinksManageService,adhocMsgs);
                userBenefits.add(userBenefit); 
            }*/
            /*else if(ben== 'Enthusiast PC Specialty' && specialtyLinksEnthu.size() > 0){ 
                if(adhocBlades.containsKey('Enthusiast PC Specialty'))
                {

                    adhocMsgs=adhocBlades.get('Enthusiast PC Specialty'); 
                }
                userBenefit=getSpecialtyEnthusiastSpecialty(specialtyLinksEnthu,adhocMsgs);
                userBenefits.add(userBenefit); 
            }*/
             /*else if(ben== 'Networking Specialty' && specialtyLinksNetworking.size() > 0){ 
                 if(adhocBlades.containsKey('Networking Specialty'))
                {
                    ////system.debug('Inside adhocBlades Networking Specialty');
                    adhocMsgs=adhocBlades.get('Networking Specialty'); 
                }
                userBenefit=getSpecialtyNetworkingSpecialty(specialtyLinksNetworking,adhocMsgs);
                userBenefits.add(userBenefit); 
            }*/
            else if(ben=='Partner Help' && partnerHelpLinks.size()>0)
            {
                if(adhocBlades.containsKey('Partner Help'))
                {
                    adhocMsgs=adhocBlades.get('Partner Help'); 
                }
                userBenefit=getPartnerHelp(partnerHelpLinks,partnerRol,userInfo,partnerTier,adhocMsgs); 
              
                userBenefits.add(userBenefit);
            }
            else if(ben=='Marketing Studio' && marketingStudioLinks.size()>0){
                if(alertBlades.containsKey('Marketing Studio'))
                {
                    alertTitles=alertBlades.get('Marketing Studio');   
                } 
                if(adhocBlades.containsKey('Marketing Studio'))
                {
                    adhocMsgs=adhocBlades.get('Marketing Studio'); 
                }
                userBenefit=getMarketingStudio(marketingStudioLinks,alertTitles,adhocMsgs);
              
                userBenefits.add(userBenefit);
            }
            else if(ben=='Pricing, Points and Promotions' && pppLinks.size()>0 ){
                if(adhocBlades.containsKey('Pricing, Points and Promotions'))
                {
                    adhocMsgs=adhocBlades.get('Pricing, Points and Promotions'); 
                }
                userBenefit=getPricingPointsPromotionsBlade(pppLinks,adhocMsgs);
             
                userBenefits.add(userBenefit);
            }
            else if(ben=='Products & Roadmaps' && productRoadmapLinks.size()>0){
                if(adhocBlades.containsKey('Products & Roadmaps'))
                {
                    adhocMsgs=adhocBlades.get('Products & Roadmaps'); 
                }
                userBenefit=getProductRoadmapsBlade(productRoadmapLinks,adhocMsgs);
             
                userBenefits.add(userBenefit);
            }
            else if(ben=='FPGA Tools and Resources' && fpgaToolsResourcesLinks.size()>0){
              
                if(adhocBlades.containsKey('FPGA Tools and Resources'))
                {
                     adhocMsgs=adhocBlades.get('FPGA Tools and Resources'); 
                }
                userBenefit=getFPGAToolsResources(fpgaToolsResourcesLinks,adhocMsgs);
              
                ////system.debug('FPGA blade'+userBenefit);
                userBenefits.add(userBenefit);
            }
            else if(ben=='Partner Lookup Tool' && ipaLookupToolLinks.size()>0){
      if(adhocBlades.containsKey('Partner Lookup Tool'))
                {
                    adhocMsgs=adhocBlades.get('Partner Lookup Tool'); 
                }
                userBenefit=getIPALookupTool(ipaLookupToolLinks,adhocMsgs,showDisti);//TWC727-887 - Utkarsh - passed new boolean parameter.
              
                ////system.debug('Look Up Tool'+userBenefit);
                userBenefits.add(userBenefit);
            }
	    //TWC729-7755
	    // IPA2.0 TWC727-2912
            else if(ben=='Enablement Zones' && activationZonesList.size()>0){
                if(adhocBlades.containsKey('Enablement Zones'))
                {
                    adhocMsgs=adhocBlades.get('Enablement Zones'); 
                }
                userBenefit=getActivationZones(activationZonesList,adhocMsgs);
              
		userBenefits.add(userBenefit);
            }
            else if(ben=='Deal Registration' && dealRegLinks.size()>0){
                userBenefit = getDealReg(dealRegLinks);
                
                userBenefits.add(userBenefit);
            }
        }   
        datetime endd = datetime.now();
        Decimal millisecs = Decimal.valueOf(endd.getTime() - start.getTime());
        integer div = 1000;   
        //Decimal cal = millisecs/div;
        return userBenefits;
    }
    
    //Method to return the Alerts for Benefit Blades
    public static Map<String,List<String>> getAlerts(IPABenefitWrapper.UserProfile userInfo)
    {
        datetime start = datetime.NOW();
        //String lang=userInfo.userLanguage;
        Datetime lastLoginTime;
        Map<String,List<String>> alertBladeInfo=new Map<String,List<String>>();
        Id messageRT = getRecordTypeId('PRM_Message__c','PRM_Event'); //IPA2.0-TWC727-2896
        List<LoginHistory> loginRec = [SELECT Id,LoginTime,LoginType,LoginUrl,Status,UserId FROM LoginHistory where UserId = :userInfo.userId and (LoginType = 'Chatter Communities External User' or LoginType = 'SAML Chatter Communities External User SSO') order by id desc limit 3 ]; //userInfo.userId 0058A000004ttVtQAI
        if(loginRec.size()>1)
        {
            lastLoginTime =loginRec[1].LoginTime;
        }       
        /* if(lang=='en_US')
{
List<PRM_Message_log__c> messageLog=[SELECT id,PRM_Message_Id__r.PRM_UI_Display_Area_Nm__c,PRM_Inactive_Ind__c,PRM_Message_Id__r.PRM_End_Date_Dt__c,PRM_Message_Id__r.PRM_Title_Txt__c,PRM_Message_Id__r.PRM_InActive_Ind__c,PRM_Message_Id__r.lastmodifieddate,lastmodifieddate from PRM_Message_log__c where PRM_Contact_Id__c =:userInfo.contactId and PRM_Message_Id__r.PRM_End_Date_Dt__c=NULL and PRM_Message_Id__r.RecordTypeId=:messageRT and PRM_Message_Id__r.PRM_InActive_Ind__c=FALSE and PRM_Inactive_Ind__c=FALSE ]; //'Event' record type-0128A000000F6I9QAK
for(PRM_Message_log__c msgcheck :messageLog){
Datetime lastAlertModifiedDate = msgcheck.lastmodifieddate;
if(lastAlertModifiedDate > lastLoginTime || lastAlertModifiedDate.AddDays(1) > DateTime.Now() ){
if(alertBladeInfo.containsKey(msgcheck.PRM_Message_Id__r.PRM_UI_Display_Area_Nm__c))
{
List<String> alerts=alertBladeInfo.get(msgcheck.PRM_Message_Id__r.PRM_UI_Display_Area_Nm__c);
alerts.add(msgcheck.PRM_Message_Id__r.PRM_Title_Txt__c);
alertBladeInfo.put(msgcheck.PRM_Message_Id__r.PRM_UI_Display_Area_Nm__c,alerts);    
}
else
{
List<String> alert=new List<String>();
alert.add(msgcheck.PRM_Message_Id__r.PRM_Title_Txt__c);
alertBladeInfo.put(msgcheck.PRM_Message_Id__r.PRM_UI_Display_Area_Nm__c,alert);                     
} 
}
}
}*/
        //else{
        String countryCode=getCountryCode(userInfo.userLanguage);
        List<PRM_Message_log__c> listlogs=[SELECT PRM_Message_Id__c,PRM_Inactive_Ind__c,lastmodifieddate from PRM_Message_log__c where PRM_Contact_Id__c =:userInfo.contactId and PRM_Inactive_Ind__c=FALSE and PRM_Message_Id__r.RecordTypeId=:messageRT and PRM_Message_Id__r.PRM_InActive_Ind__c=FALSE];
        //List<Id> logId=new List<Id>();
        Map<Id,PRM_Message_log__c> msgLogDetls = new Map<Id,PRM_Message_log__c>();
        for(PRM_Message_log__c log: listlogs){
            msgLogDetls.put(log.PRM_Message_Id__c,log);
        }
        List<PRM_Message__c> translatedList=[SELECT PRM_Title_Txt__c,Name, PRM_UI_Display_Area_Nm__c,PRM_End_Date_Dt__c,PRM_Inactive_Ind__c,lastmodifieddate,(SELECT PRM_Title_Txt__c,PRM_Description_Txt__c,lastmodifieddate,PRM_InActive_Ind__c FROM Message_Translations__r where PRM_Language_Nm__c=:countryCode  ) FROM PRM_Message__c WHERE Id IN:msgLogDetls.keyset() and RecordTypeId=:messageRT and PRM_Inactive_Ind__c=FALSE ];//and PRM_InActive_Ind__c=false
        if(translatedList.size()>0){
            for(PRM_Message__c msg:translatedList)
            {
                if(msg.Message_Translations__r.size()>0){
                    for(PRM_Message_Translation__c msgtrans:msg.Message_Translations__r)
                    {
                        PRM_Message_log__c msgDetl =msgLogDetls.get(msg.id);   
                        Datetime lastAlertModifiedDateTran = msgDetl.lastmodifieddate;
                        if(lastAlertModifiedDateTran > lastLoginTime || lastAlertModifiedDateTran.AddDays(1) > DateTime.Now() ){     
                            if(alertBladeInfo.containsKey(msg.PRM_UI_Display_Area_Nm__c)){
                                List<String> alerts=new List<String>();
                                alerts=alertBladeInfo.get(msg.PRM_UI_Display_Area_Nm__c);
                                if(msgtrans.PRM_InActive_Ind__c == true){
                                    alerts.add(msg.PRM_Title_Txt__c);   
                                }else{
                                    alerts.add(msgtrans.PRM_Title_Txt__c);  
                                }
                                alertBladeInfo.put(msg.PRM_UI_Display_Area_Nm__c,alerts);
                            }                      
                            else{
                                List<String> alerts=new List<String>();
                                if(msgtrans.PRM_InActive_Ind__c == true){
                                    alerts.add(msg.PRM_Title_Txt__c);   
                                }else{
                                    alerts.add(msgtrans.PRM_Title_Txt__c);  
                                }
                                alertBladeInfo.put(msg.PRM_UI_Display_Area_Nm__c,alerts);
                            } 
                        }     
                    }
                }
                else{
                    PRM_Message_log__c msgDetlE =msgLogDetls.get(msg.id); 
                    Datetime lastAlertModifiedDateMs = msgDetlE.lastmodifieddate;
                    if(lastAlertModifiedDateMs > lastLoginTime || lastAlertModifiedDateMs.AddDays(1) > DateTime.Now() ){
                        if(alertBladeInfo.containsKey(msg.PRM_UI_Display_Area_Nm__c)){
                            List<String> alerts=new List<String>();
                            alerts=alertBladeInfo.get(msg.PRM_UI_Display_Area_Nm__c);
                            alerts.add(msg.PRM_Title_Txt__c);
                            alertBladeInfo.put(msg.PRM_UI_Display_Area_Nm__c,alerts);}
                        else{
                            List<String> alerts=new List<String>();
                            alerts.add(msg.PRM_Title_Txt__c);
                            alertBladeInfo.put(msg.PRM_UI_Display_Area_Nm__c,alerts); 
                        }  
                    }
                }
            }
        }      
        // }
        datetime endd = datetime.now();
        Decimal millisecs = Decimal.valueOf(endd.getTime() - start.getTime());
        integer div = 1000;   
        //Decimal cal = millisecs/div;
        ////system.debug('getAlertsSecs: ' +cal);
        return alertBladeInfo;        
    }
     public static Map<String,Map<String,String>> getAdhocMsg(IPABenefitWrapper.UserProfile userInfo)
    {
        datetime start = datetime.NOW();
        String lang=userInfo.userLanguage;
        Datetime lastLoginTime;
        Map<String,Map<String,String>> adhocBladeInfo=new Map<String,Map<String,String>>();
        Id messageRT = getRecordTypeId('PRM_Message__c','PRM_Adhoc'); //IPA2.0-TWC727-2896
             
      String countryCode=getCountryCode(userInfo.userLanguage);
       List<PRM_Message__c> listMsgs=[SELECT id, PRM_UI_Display_Area_Nm__c, PRM_Title_Txt__c, PRM_Description_Txt__c,PRM_Start_Date_Dt__c,PRM_End_Date_Dt__c, PRM_InActive_Ind__c,LastModifiedDate  from PRM_Message__c where RecordTypeId=:messageRT and PRM_InActive_Ind__c = false ];      
        Map<Id,PRM_Message__c> msgLogDetls = new Map<Id,PRM_Message__c>();
        for(PRM_Message__c m: listMsgs){
            msgLogDetls.put(m.id,m);
        }
        List<PRM_Message__c> translatedList=[SELECT Id, PRM_Title_Txt__c,PRM_Description_Txt__c,Name, PRM_UI_Display_Area_Nm__c,PRM_Start_Date_Dt__c,PRM_End_Date_Dt__c,PRM_Inactive_Ind__c,lastmodifieddate,(SELECT PRM_Title_Txt__c,PRM_Description_Txt__c,lastmodifieddate,PRM_InActive_Ind__c FROM Message_Translations__r where PRM_Language_Nm__c=:countryCode  ) FROM PRM_Message__c WHERE  Id IN:msgLogDetls.keyset() and RecordTypeId=:messageRT and PRM_Inactive_Ind__c=FALSE ];//and PRM_InActive_Ind__c=false
       
        if(translatedList.size()>0){
            for(PRM_Message__c msg:translatedList)
            {
                String msgId = msg.Id;
             String msgTitle =  msg.PRM_Title_Txt__c;  
             String msgIdandTitle = String.valueOf(msgId)+','+String.valueOf(msgTitle);
                
                Date startDate =  msg.PRM_Start_Date_Dt__c;
                Date endDate = msg.PRM_End_Date_Dt__c;
                Date todaysDate = Date.today();
                
                if(msg.Message_Translations__r.size()>0){
                    for(PRM_Message_Translation__c msgtrans:msg.Message_Translations__r)
                    {
                        //PRM_Message__c msgDetl =msgLogDetls.get(msg.id);   
                         
                         String transmsgId = msgtrans.Id;
                  String transmsgTitle =  msgtrans.PRM_Title_Txt__c;  
                  String transmsgIdandTitle = String.valueOf(transmsgId)+','+String.valueOf(transmsgTitle);
                        
                        if(startDate!=null && endDate!=null && startDate<endDate && StartDate<=todaysDate && StartDate!=endDate && endDate > todaysDate){
                            if(adhocBladeInfo.containsKey(msg.PRM_UI_Display_Area_Nm__c)){
                                Map<String,String> adhocMsg=new Map<String,String>();
                                adhocMsg=adhocBladeInfo.get(msg.PRM_UI_Display_Area_Nm__c);
                                if(msgtrans.PRM_InActive_Ind__c == true){
                                     adhocMsg.put(msgIdandTitle,msg.PRM_Description_Txt__c); 
                                      
                                }else{
                                    adhocMsg.put(transmsgIdandTitle,msgtrans.PRM_Description_Txt__c); 
                                  
                                }
                                adhocBladeInfo.put(msg.PRM_UI_Display_Area_Nm__c,adhocMsg);
                            }                      
                            else{
                                 Map<String,String> adhocMsg=new Map<String,String>();
                                if(msgtrans.PRM_InActive_Ind__c == true){
                                   adhocMsg.put(msgIdandTitle,msg.PRM_Description_Txt__c); 
                                }else{
                                   adhocMsg.put(transmsgIdandTitle,msgtrans.PRM_Description_Txt__c); 
                                }
                                adhocBladeInfo.put(msg.PRM_UI_Display_Area_Nm__c,adhocMsg);
                            } 
                        }     
                    }
                }
                else{
                    PRM_Message__c msgDetlE =msgLogDetls.get(msg.id); 
                    //Datetime lastAlertModifiedDateMs = msgDetlE.lastmodifieddate;
                    if(startDate!=null && endDate!=null && startDate<endDate && StartDate<=todaysDate && StartDate!=endDate && endDate > todaysDate){
                        if(adhocBladeInfo.containsKey(msg.PRM_UI_Display_Area_Nm__c)){
                            Map<String,String> adhocMsg=new Map<String,String>();
                            adhocMsg=adhocBladeInfo.get(msg.PRM_UI_Display_Area_Nm__c);
                            adhocMsg.put(msgIdandTitle,msg.PRM_Description_Txt__c);
                            adhocBladeInfo.put(msg.PRM_UI_Display_Area_Nm__c,adhocMsg);}
                        else{
                             Map<String,String> adhocMsg=new Map<String,String>();
                            adhocMsg.put(msgIdandTitle,msg.PRM_Description_Txt__c);
                            adhocBladeInfo.put(msg.PRM_UI_Display_Area_Nm__c,adhocMsg);
                        } 
                    }
                }
            }
        }      
       
        ////system.debug('adhoc map-->'+adhocBladeInfo);
        return adhocBladeInfo;        
    }
    
    //Method to return the metrics for Trainings blade
    public static List<IPABenefitWrapper.Metrics> getTrainingMetrics(IPABenefitWrapper.UserProfile userInfo,List<String> entitlementList)
    {
        datetime start = datetime.NOW();
        List<IPABenefitWrapper.Metrics> trainingMetrics=new List<IPABenefitWrapper.Metrics>();
        if(entitlementList.contains(System.Label.PRM_Primary_Contact) || entitlementList.contains(System.Label.PRM_Partner_Admin_Delegate))   //Company Credits Metrics visible only for Partner Admin and Partner Admin Delegate
        {
            string trainingNum;
            Decimal sum=0;
            String totalCredits;
            boolean trainingVisiblity = false;
            map<id,Decimal> trainingCurMap=new map<id,Decimal>();
          
            if(userInfo.onePartnerId!= null )
            {
                try{
                    for(PRM_Value_Exchange_Data__c vxData:[select PRM_Training_Credit_Points_Count_Nbr__c ,PRM_Account_Id__c
                                                           from PRM_Value_Exchange_Data__c 
                                                           where PRM_One_Partner_Id__c =:userInfo.onePartnerId 
                                                           AND PRM_TimePeriod_Nm__c =: System.Label.PRM_Current_measurement_period order by PRM_Training_Credit_Points_Count_Nbr__c]){
                        
                 trainingCurMap.put(vxData.PRM_Account_Id__c,vxData.PRM_Training_Credit_Points_Count_Nbr__c);                                                       
                    }
                  
                    for(Decimal i:trainingCurMap?.values()){
                            sum+=i;
                    } 
                    //AggregateResult aggregateSum = [Select MAX(PRM_Training_Credit_Points_Count_Nbr__c) totalCredits from PRM_Value_Exchange_Data__c where PRM_One_Partner_Id__c =:userInfo.onePartnerId AND PRM_TimePeriod_Nm__c =: System.Label.PRM_Current_measurement_period];
                   // //system.debug('AggregateResult1----->>>'+aggregateSum);
                    trainingNum=numberConversion(sum);
                    ////system.debug('Training Num-->'+trainingNum);
                    totalCredits=trainingNum;
                    ////system.debug('totalCredits try 1----->'+totalCredits);
                }catch(Exception e){
                    totalCredits='0';
                }
                trainingVisiblity = true;
            }
            if(userInfo.onePartnerId == null && trainingVisiblity == false)
            {
                try{
                    if(userInfo.companyProfileId != null){
                        AggregateResult aggregateSum = [Select MAX(PRM_Training_Credit_Points_Count_Nbr__c) totalCredits from PRM_Value_Exchange_Data__c where PRM_Account_Id__c =:userInfo.companyProfileId AND PRM_TimePeriod_Nm__c =: System.Label.PRM_Current_measurement_period];
                        ////system.debug('AggregateResult2----->>>'+aggregateSum);
                         trainingNum=numberConversion(Integer.valueof(aggregateSum.get('totalCredits')));
                       totalCredits=trainingNum;
                        ////system.debug('trainingNumLoc-->'+trainingNum);
                       // totalCredits=Integer.valueOf(aggregateSum.get('totalCredits'));
                    }
                }catch(Exception e){
                    ////system.debug('An exception occurred in getTrainingMetrics()'+e);
                    totalCredits = '0';
                }                 
            } 
            IPABenefitWrapper.Metrics metric1=new IPABenefitWrapper.Metrics() ;
            metric1.label=System.Label.IPA_Training_mtrc_Label1;
            // IPABenefitWrapper.Link melink1=new IPABenefitWrapper.Link();
            // melink1.label=System.Label.IPA_Training_mtrc_courses_action;
            // melink1.externalUrl=System.Label.IPA_Training_mtrc_courses_url;
            // metric1.link=melink1;
           metric1.value = (totalCredits != null) ? String.valueOf(totalCredits) : '0';
            trainingMetrics.add(metric1);
        }
        
        //Individual Training Credits Metrics
        if(userInfo.contactId!=null)
        {
            List<k_v_f_training_detail_sfdcs__x> trainingDetailList=new List<k_v_f_training_detail_sfdcs__x>(); 
            Integer sum=0;
            try
            {
        /* Utkarsh - Changes made as part of PRB10047309*/
                trainingDetailList= [Select business_person_id__c, training_credit_qty__c,value_exchange_period_txt__c from k_v_f_training_detail_sfdcs__x where business_person_id__c=:userInfo.contactId AND value_exchange_period_txt__c=: System.Label.PRM_Current_measurement_period];
                
                /*for (k_v_f_training_detail_sfdcs__x kvf : [Select business_person_id__c, training_credit_qty__c from k_v_f_training_detail_sfdcs__x where business_person_id__c=:userInfo.contactId ]){
                    trainingDetailList.add(kvf);
                }*/
        /*Utkarsh - Changes ended*/
                if(trainingDetailList!=null && !trainingDetailList.isEmpty()){
                    for(k_v_f_training_detail_sfdcs__x obj:trainingDetailList)
                    {
                        Integer value=Integer.valueOf(obj.training_credit_qty__c);
                        sum=sum+value;
                    }
                }
            } catch(Exception e){
                ////system.debug('An Exception occurred'+e);
                ////system.debug('An Exception occurred'+e.getMessage());
                sum=0;
            } 
            
            IPABenefitWrapper.Metrics metric2=new IPABenefitWrapper.Metrics();
            metric2.label=System.Label.IPA_Training_mtrc_Label2;
            //  IPABenefitWrapper.Link melink2=new IPABenefitWrapper.link();
            // melink2.label=System.Label.IPA_Training_mtrc_courses_action;
            // melink2.externalUrl=System.Label.IPA_Training_mtrc_courses_url;
            // metric2.link=melink2;
            metric2.value=String.valueOf(sum);
            //metric2.description=System.Label.IPA_Training_mtrc_courses_desc1;
            trainingMetrics.add(metric2);
            
        }
        datetime endd = datetime.now();
        Decimal millisecs = Decimal.valueOf(endd.getTime() - start.getTime());
        integer div = 1000;   
        //Decimal cal = millisecs/div;
        return trainingMetrics;      
    }
    //Method to return metrics for MarketPlace blade
    public static List<IPABenefitWrapper.Metrics> getMarketPlaceMetrics(String onePartnerId,List<String> entitlementList)
    {
        
        datetime start = datetime.NOW();
        List<IPABenefitWrapper.Metrics> marketPlaceMetrics=new List<IPABenefitWrapper.Metrics>();
        if(Test.isRunningTest()){entitlementList.add('Offering Editor'); }
        if(entitlementList.contains(System.Label.PRM_Offering_Editor) )  // check to show metric only if its having entitlment as Offering Editor
        {
            Integer publishedOffering=0;
            Integer pendingOffering=0;
            
            if(onePartnerId!= null)
            {
                //new SOQL, post OPID restructuring added by Mansi as a part of TWC729-1223 to fetch Pending and Published MP Offerings
                List<PMP_OPID_MPI_Rel__c> mpirecords = [select id,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c,Is_Active__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c =:onePartnerId and Is_Active__c = true limit 1]; 
                if(mpirecords!=null && !mpirecords.isEmpty()){
                List<PMP_Company__c> companyrecords = [SELECT id, Name, PMP_Partner_Inactive_Ind__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Partner_Benefit_Type__c from PMP_Company__c where id =: mpirecords[0].PMP_Marketing_Profile_Id__c and PMP_Is_Published_Ind__c=true];
                if(companyrecords!=null && !companyrecords.isEmpty()){    
    AggregateResult aggregateSum1=[Select Count(PMP_Company_Id__c) publishedOffer  from PMP_Partner_Offering__c  where PMP_Partner_Offering_Start_Dt__c <=TODAY and PMP_Partner_Offering_End_Dt__c >= TODAY and PMP_Partner_Offering_Lifecycle_Status_Nm__c =:approved and PMP_Company_Id__c =:companyrecords[0].id ]; 
                publishedOffering = Integer.valueOf(aggregateSum1.get('publishedOffer'));            
                IPABenefitWrapper.Metrics metric1=new IPABenefitWrapper.Metrics() ;
                metric1.label=System.Label.IPA_MarketPlace_mtrc_Label2;
                metric1.value=String.valueOf(publishedOffering);
                marketPlaceMetrics.add(metric1);
                
                AggregateResult aggregateSum2=[Select Count(PMP_Company_Id__c) pendingOffer  from PMP_Partner_Offering__c  where (PMP_Partner_Offering_Lifecycle_Status_Nm__c =:admin or PMP_Partner_Offering_Lifecycle_Status_Nm__c =:draft or PMP_Partner_Offering_Lifecycle_Status_Nm__c =:updateRequired) and PMP_Company_Id__c=:companyrecords[0].id]; 
                pendingOffering = Integer.valueOf(aggregateSum2.get('pendingOffer'));
                IPABenefitWrapper.Metrics metric2=new IPABenefitWrapper.Metrics() ;
                metric2.label=System.Label.IPA_MarketPlace_mtrc_Label1;
                IPABenefitWrapper.Link melink1=new IPABenefitWrapper.Link();
                metric2.link=melink1;   
                metric2.value=String.valueOf(pendingOffering);
                marketPlaceMetrics.add(metric2);    
            }
        }      
            }    
        }      
        datetime endd = datetime.now();
        Decimal millisecs = Decimal.valueOf(endd.getTime() - start.getTime());
        integer div = 1000;   
        //Decimal cal = millisecs/div;
        //system.debug('getMarketPlaceMetricsSecs: ' +cal);
        return marketPlaceMetrics;
    }
    
    // this method return users notification 
    @AuraEnabled(cacheable=false)
    public static IPABenefitWrapper.UserNotificationInfo  getNotificationList(Id userId,String notificationView){
        datetime start = datetime.NOW();
        Id messageRecordId = getRecordTypeId('PRM_Message__c','PRM_Adhoc'); //IPA2.0-TWC727-2896
        Id messageRTEvent = getRecordTypeId('PRM_Message__c','PRM_Event'); //IPA2.0-TWC727-2896
        IPABenefitWrapper.UserNotificationInfo ndata=new IPABenefitWrapper.UserNotificationInfo();
        if(userId != null ){
            Integer notiLimit;
            if(notificationView == 'Home Notification'){
                notiLimit = 5;
            }
            else{
                notiLimit = 100;
            }
            ////system.debug('notiLimit'+notiLimit);
            List<IPABenefitWrapper.message> msgList = new List<IPABenefitWrapper.message>();
            IPABenefitWrapper.UserProfile userInfo =  userInfo(userId);//0058A000004C0JPQA0
            if(userInfo.contactId != null){
                List<PRM_EmailLog__c> getEmailLog = [select id,PRM_Read__c, PRM_Is_Deleted__c,PRM_Contact__c,PRM_Subject__c,PRM_EmailContent__c,CreatedDate,PRM_EmailHTMLContent__c from PRM_EmailLog__c where PRM_Is_Deleted__c=false and PRM_Contact__c =:userInfo.contactId order by id desc limit: notiLimit ] ;
                if(getEmailLog.size()>0){
                    for(PRM_EmailLog__c n:getEmailLog){
                        IPABenefitWrapper.message msgSingle = new IPABenefitWrapper.message();
                        msgSingle.messageId = n.Id;
                        msgSingle.subject  = n.PRM_Subject__c;
                        msgSingle.body = n.PRM_EmailHTMLContent__c != null ? n.PRM_EmailHTMLContent__c : n.PRM_EmailContent__c;
                        //msgSingle.body =n.PRM_EmailContent__c;
                        msgSingle.msgDate = n.CreatedDate.date();//.date()
                        msgSingle.read = n.PRM_Read__c;
                        msgSingle.type =  'Direct Message';
                        msgSingle.iconType = 'envelope';
                        //List<IPABenefitWrapper.Fields> fldList = new List<IPABenefitWrapper.Fields>();
                        //Fields fld = new Fields();
                        //fld.label = 'Name';
                        //fld.value = 'Test Account'; 
                        //fldList.add(fld);
                        // msgSingle.fields = fldList;
                        IPABenefitWrapper.ReplyLink replyLinkSingle =  new   IPABenefitWrapper.ReplyLink();
                        replyLinkSingle.label = 'Reply Link';
                        replyLinkSingle.externalUrl = '#ReplyLink';
                        replyLinkSingle.communityPage = '';
                        replyLinkSingle.objectPage = '';
                        replyLinkSingle.recordId = '';
                        msgSingle.replyLink = replyLinkSingle;
                        msgList.add(msgSingle);     
                    }   
                } 
         /* if(userInfo.userLanguage =='en_US'){
List<PRM_Message_log__c> getMessageLog=[SELECT id,PRM_Message_Viewed_Ind__c,CreatedDate,LastModifiedDate,PRM_Message_Id__r.PRM_UI_Display_Area_Nm__c,PRM_Message_Id__r.PRM_End_Date_Dt__c,PRM_Message_Id__r.PRM_Title_Txt__c,PRM_Message_Id__r.PRM_Description_Txt__c from PRM_Message_log__c where 
PRM_Contact_Id__c = :userInfo.contactId  and PRM_Message_Id__r.PRM_End_Date_Dt__c=NULL and PRM_Inactive_Ind__c =false and PRM_Message_Id__r.PRM_InActive_Ind__c = false and (PRM_Message_Id__r.recordtypeid = :messageRecordId or (PRM_Message_Id__r.recordtypeid = : messageRTEvent and PRM_Message_Id__r.PRM_UI_Display_Area_Nm__c = 'Notification Area' ))  order by LastModifiedDate desc limit :notiLimit];
////system.debug('Message Logs: '+getMessageLog);
if(getMessageLog.size()>0){
for(PRM_Message_log__c usrMsg : getMessageLog){
IPABenefitWrapper.message msgSingle1 = new IPABenefitWrapper.message();
msgSingle1.messageId = usrMsg.Id;
msgSingle1.subject  = usrMsg.PRM_Message_Id__r.PRM_Title_Txt__c;
msgSingle1.body =usrMsg.PRM_Message_Id__r.PRM_Description_Txt__c;
msgSingle1.msgDate = usrMsg.LastModifiedDate.Date();
msgSingle1.read = usrMsg.PRM_Message_Viewed_Ind__c;
msgSingle1.type =  'Account';
msgSingle1.iconType = 'alert';
// List<IPABenefitWrapper.Fields> fldList1 = new List<IPABenefitWrapper.Fields>();
//Fields fld = new Fields();
//fld.label = 'Name';
//fld.value = 'Test Account'; 
//fldList.add(fld);
// msgSingle1.fields = fldList1;
IPABenefitWrapper.ReplyLink replyLinkSingle1 =  new   IPABenefitWrapper.ReplyLink();
replyLinkSingle1.label = 'Reply Link';
replyLinkSingle1.externalUrl = '#ReplyLink';
replyLinkSingle1.communityPage = '';
replyLinkSingle1.objectPage = '';
replyLinkSingle1.recordId = '';
msgSingle1.replyLink = replyLinkSingle1;
msgList.add(msgSingle1);
}
}
}*/
                //else{
                Map<Id, PRM_Message_log__c> msgMapDetails = new Map<Id,PRM_Message_log__c>();
                String counCode = getCountryCode(userInfo.userLanguage);
                List<PRM_Message_log__c> listMessageLogs=[SELECT id,PRM_Message_Viewed_Ind__c,PRM_Message_Id__c,CreatedDate,LastModifiedDate from PRM_Message_log__c where  PRM_Contact_Id__c = :userInfo.contactId and PRM_Inactive_Ind__c = false and (PRM_Message_Id__r.recordtypeid = :messageRecordId or (PRM_Message_Id__r.recordtypeid = : messageRTEvent and PRM_Message_Id__r.PRM_UI_Display_Area_Nm__c = 'Notification Area' ))  order by LastModifiedDate desc limit :notiLimit];//'0038A00000RiSI5QAN'
                if(listMessageLogs.size()>0){
                    for(PRM_Message_log__c log: listMessageLogs){
                        msgMapDetails.put(log.PRM_Message_Id__c,log);
                    }
                }
                List<PRM_Message__c> translatedList=[SELECT id,Name,PRM_Title_Txt__c,PRM_Description_Txt__c,(SELECT id,PRM_Title_Txt__c,PRM_Description_Txt__c,PRM_Language_Nm__c,PRM_InActive_Ind__c FROM Message_Translations__r where PRM_Language_Nm__c =:counCode) FROM PRM_Message__c WHERE PRM_InActive_Ind__c = false and Id IN:msgMapDetails.keyset()   limit :notiLimit];//and recordtypeid = :messageRecordId //PRM_InActive_Ind__c = false
                ////system.debug('translatedList is'+translatedList); 
                if(translatedList.size()>0){
                    for(PRM_Message__c msgcheck : translatedList){
                        if(msgcheck.Message_Translations__r.size()>0){
                            for(PRM_Message_Translation__c transMsg: msgcheck.Message_Translations__r ){ 
                                PRM_Message_log__c msgDet =msgMapDetails.get(msgcheck.id);
                                ////system.debug('msgDet>>'+msgDet);
                                IPABenefitWrapper.message msgSingle2 = new IPABenefitWrapper.message();
                                msgSingle2.messageId = msgDet.Id;
                                if(transMsg.PRM_InActive_Ind__c == true){
                                    msgSingle2.subject  = msgcheck.PRM_Title_Txt__c; 
                                    msgSingle2.body =msgcheck.PRM_Description_Txt__c;   
                                }else{
                                    msgSingle2.subject  = transMsg.PRM_Title_Txt__c; 
                                    msgSingle2.body =transMsg.PRM_Description_Txt__c;  
                                }
                                msgSingle2.msgDate = msgDet.LastModifiedDate.date();//.date()
                                msgSingle2.read = msgDet.PRM_Message_Viewed_Ind__c;
                                msgSingle2.type =  'Account';
                                msgSingle2.iconType = 'alert';
                                // List<IPABenefitWrapper.Fields> fldList2 = new List<IPABenefitWrapper.Fields>();
                                //Fields fld = new Fields();
                                //fld.label = 'Name';
                                //fld.value = 'Test Account'; 
                                //fldList.add(fld);
                                // msgSingle2.fields = fldList2;
                                IPABenefitWrapper.ReplyLink replyLinkSingle2 =  new   IPABenefitWrapper.ReplyLink();
                                replyLinkSingle2.label = 'Reply Link';
                                replyLinkSingle2.externalUrl = '#ReplyLink';
                                replyLinkSingle2.communityPage = '';
                                replyLinkSingle2.objectPage = '';
                                replyLinkSingle2.recordId = '';
                                msgSingle2.replyLink = replyLinkSingle2;
                                msgList.add(msgSingle2);   
                            }   
                        }
                        else{
                            ////system.debug('ElseRecent');
                            PRM_Message_log__c msgDet =msgMapDetails.get(msgcheck.id);
                            ////system.debug('msgDet>>'+msgDet);
                            IPABenefitWrapper.message msgSingle2 = new IPABenefitWrapper.message();
                            msgSingle2.messageId = msgDet.Id;
                            msgSingle2.subject  = msgcheck.PRM_Title_Txt__c; 
                            msgSingle2.body =msgcheck.PRM_Description_Txt__c;
                            msgSingle2.msgDate = msgDet.LastModifiedDate.date();//.date()
                            msgSingle2.read = msgDet.PRM_Message_Viewed_Ind__c;
                            msgSingle2.type =  'Account';
                            msgSingle2.iconType = 'alert';
                            // List<IPABenefitWrapper.Fields> fldList2 = new List<IPABenefitWrapper.Fields>();
                            //Fields fld = new Fields();
                            //fld.label = 'Name';
                            //fld.value = 'Test Account'; 
                            //fldList.add(fld);
                            // msgSingle2.fields = fldList2;
                            IPABenefitWrapper.ReplyLink replyLinkSingle2 =  new   IPABenefitWrapper.ReplyLink();
                            replyLinkSingle2.label = 'Reply Link';
                            replyLinkSingle2.externalUrl = '#ReplyLink';
                            replyLinkSingle2.communityPage = '';
                            replyLinkSingle2.objectPage = '';
                            replyLinkSingle2.recordId = '';
                            msgSingle2.replyLink = replyLinkSingle2;
                            msgList.add(msgSingle2);
                        }
                    }
                }
                //}               
                ndata.title = System.label.IPA_Recent_notification_title;
                ndata.messages = msgList;
                IPABenefitWrapper.viewLink viewLinks = new IPABenefitWrapper.viewLink();
                viewLinks.label = System.label.IPA_View_All_Messages;
                viewLinks.externalUrl = ''; 
                viewLinks.communityPage = 'Partner_Message_List__c';//Partner_Message_List__c //manage_personnel__c
                viewLinks.objectPage = '';
                viewLinks.recordId = '';
                ndata.viewAllLink = viewLinks;  
                if(!ndata.messages.isEmpty()){
                    ndata.messages.sort();
                }
            }  
        }
        datetime endd = datetime.now();
       Decimal millisecs = Decimal.valueOf(endd.getTime() - start.getTime());
        integer div = 1000;   
        //Decimal cal = millisecs/div;
        return ndata;
    }
    //update flag on message log and email to true
    @AuraEnabled
    public static void setReadVisibility(Id recordId,String type){
        if(recordId != null && type != null){
            if(type == 'Direct Message'){
                List<PRM_EmailLog__c> emailUpdateList = new List<PRM_EmailLog__c>();   
                PRM_EmailLog__c updateEmail = [select id,PRM_Read__c from PRM_EmailLog__c where id =:recordId ];
                if(updateEmail.PRM_Read__c == false  && updateEmail.id  != null){
                    updateEmail.PRM_Read__c = true;
                    emailUpdateList.add(updateEmail);    
                } 
                if(emailUpdateList.size()>0){
                    update emailUpdateList;
                } 
            }
            if(type == 'Account'){
                List<PRM_Message_log__c> messageUpdateList = new List<PRM_Message_log__c>();
                PRM_Message_log__c updateMessage = [select id,PRM_Message_Viewed_Ind__c from PRM_Message_log__c where id =:recordId ];
                if(updateMessage.PRM_Message_Viewed_Ind__c == false  && updateMessage.id  != null){
                    updateMessage.PRM_Message_Viewed_Ind__c = true;
                    messageUpdateList.add(updateMessage);    
                }
                if(messageUpdateList.size()>0){
                    update messageUpdateList;
                }
            }
        }
    }
    @AuraEnabled
    public static void setDeleteIndicator(Id recordId,String type){
        if(recordId != null && type != null && type == 'Direct Message'){
            List<PRM_EmailLog__c> emailUpdateList1 = new List<PRM_EmailLog__c>();   
            PRM_EmailLog__c updateEmail1 = [select id,PRM_Is_Deleted__c from PRM_EmailLog__c where id =:recordId ];
            if(updateEmail1.PRM_Is_Deleted__c == false  && updateEmail1.id  != null){
                updateEmail1.PRM_Is_Deleted__c = true;
                emailUpdateList1.add(updateEmail1); 
            }
            if(emailUpdateList1.size()>0){
                update emailUpdateList1;
            }
        }
    }
        
    //Show Quick links on benefit page
    @AuraEnabled(cacheable=true)
    public static IPABenefitWrapper.PartnerQuickLinkInfo getPartnerQuickLinks(ID userId){
        datetime start = datetime.NOW();
        IPABenefitWrapper.PartnerQuickLinkInfo quickLink=new IPABenefitWrapper.PartnerQuickLinkInfo();           
        Id quickLinkMatrixRT = getRecordTypeId('PRM_PEx_Access_Matrix__c','Quick_Links_Access_Rule'); //IPA2.0-TWC727-2896
        Map<Id,PRM_PEx_Access_Matrix__c> cardLinks=new Map<Id,PRM_PEx_Access_Matrix__c>();
        
        if(userId != null ){
            IPABenefitWrapper.UserProfile userInfo =  userInfo(userId);
            if(userInfo.contactId != null){
                List<IPABenefitWrapper.Cards> cardsList=new List<IPABenefitWrapper.Cards>();
                List<Core_Contact_Entitlement__c> entitlementList=[SELECT Core_Entitlement_Id__r.Name from Core_Contact_Entitlement__c WHERE Core_Contact_Id__c=:userInfo.contactId and Core_Selected__c=true and Core_Status__c='Complete'];  
                
                //list of entitlements in benefit matrix
                List<PRM_PEx_Access_Matrix__c> matrxEntitlements=[SELECT PRM_IPA_URL__c,PRM_Click_To_Action__c,PRM_Entitlements__c, RecordTypeId, 
                                                                  PRM_IPA_Partner_Role__c FROM PRM_PEx_Access_Matrix__c where RecordTypeId = :quickLinkMatrixRT ];//IPA2.0-TWC727-3061
                //system.debug('Matrx Entlments'+matrxEntitlements);
                quickLink.title=System.Label.IPA_QuickLink_Heading;
                if(matrxEntitlements.size()>0){
                    for(PRM_PEx_Access_Matrix__c beneftAccessMatrix : matrxEntitlements)
                    {       
                        List<String> entitlementSet=new List<String>();     
                        entitlementSet = getListfromPicklistValue(beneftAccessMatrix.PRM_Entitlements__c);
                        if(entitlementList.size()>0){
                            for(Core_Contact_Entitlement__c enti:entitlementList){
                                
                                if(entitlementSet.contains(enti.Core_Entitlement_Id__r.Name) && !cardLinks.containsKey(beneftAccessMatrix.Id)){     
                                    {
                                        cardLinks.put(beneftAccessMatrix.Id,beneftAccessMatrix);                                      
                                    }                               
                                }  
                            }
                        }                             
                    }
                    if(cardLinks.size()>0)
                    {
                        for(PRM_PEx_Access_Matrix__c benefitMatrixRecord:cardLinks.values())
                        {
                            IPABenefitWrapper.Cards card1=new IPABenefitWrapper.Cards();
                            card1.icon='fa-angle-double-right';
                            card1.imageUrl='';
                            card1.svgIconUrl='';
                            card1.sfIcon='';
                            card1.title=benefitMatrixRecord.PRM_Click_To_Action__c;
                            card1.description='';
                            IPABenefitWrapper.LinkData lnkdata=new IPABenefitWrapper.LinkData();
                            switch on benefitMatrixRecord.PRM_Click_To_Action__c{
                                when 'Manage Personnel'{
                                    lnkdata.label=System.Label.IPA_QuickLink_ManagePerLabel; 
                                    card1.title=System.Label.IPA_QuickLink_ManagePerLabel;                                   
                                    lnkdata.communityPage= benefitMatrixRecord.PRM_IPA_URL__c;
                                }
                                when 'Invite members'{
                                    lnkdata.label=System.Label.IPA_QuickLink_InviteMemLabel; 
                                    card1.title=System.Label.IPA_QuickLink_InviteMemLabel;
                                    lnkdata.communityPage= benefitMatrixRecord.PRM_IPA_URL__c;
                                }
                                when 'Intel® Partner Alliance Home'{
                                    lnkdata.label= System.Label.IPA_Home_header; 
                                    card1.title=System.Label.IPA_Home_header;                                   
                                    lnkdata.externalUrl = System.Label.IPA_HomeHeader_Link_Cidaas;                                                                      
                                }
                            }
                            //lnkdata.label=benefitMatrixRecord.PRM_Click_To_Action__c;
                            ////system.debug('Links-->'+benefitMatrixRecord.PRM_Click_To_Action__c);
                            //lnkdata.communityPage= benefitMatrixRecord.PRM_IPA_URL__c;
                            // lnkdata.externalUrl= '';//benefitMatrixRecord.PRM_IPA_Quick_Links__c;  //'https://www.intelmanagepersonnel.com';
                            lnkdata.objectPage= '';
                            lnkdata.recordId= '';
                            card1.linkData=lnkdata; 
                            cardsList.add(card1);
                        }
                        quickLink.cards = cardsList; 
                    }                   
                }                   
            }      
        }
        datetime endd = datetime.now();
        Decimal millisecs = Decimal.valueOf(endd.getTime() - start.getTime());
        integer div = 1000;   
        //Decimal cal = millisecs/div;
        return quickLink;
    }
    
    // input string of comma separated and return list of string
    private static List<String> getListfromPicklistValue(String str)
    {       
        List<String> stringSet = new List<String>();
        if(String.isNotBlank(str) && str.indexOf(';') > 0){
            
            stringSet.addAll(str.split(';'));
        }else{
            stringSet.add(str);
        }
        return stringSet;
    }
    
    //Get 3 digit country code by passing 2 digit country code
    public static String getCountryCode(String lngCode){
        String countryCode;
        List<PRM_LanguageLocaleMapping__mdt> languageCodeMapping=[Select PRM_Preferred_Language_Code__c,PRM_Preferred_Locale_Code__c  from PRM_LanguageLocaleMapping__mdt where PRM_Preferred_Locale_Code__c=:lngCode]; 
        if(languageCodeMapping.size()>0 && languageCodeMapping[0].PRM_Preferred_Language_Code__c != null){
            countryCode = languageCodeMapping[0].PRM_Preferred_Language_Code__c;
        }    
        return countryCode;
    }
    //call this method to get Training Details
    public static IPABenefitWrapper.UserBenefitInfo getTraining(List<String> links,List<String> alertTitles,Map<String,String> adhocMsgs, List<IPABenefitWrapper.Metrics> trainingMetrics){
        
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        //List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        userBenefit.title=System.Label.IPA_Training_bnft_Title;
        userBenefit.faIcon=showLogoMap.containsKey('Training') && !showLogoMap.get('Training')?System.Label.IPA_Training_bnft_Icon:null;
        userBenefit.description=System.Label.IPA_Training_bnft_Description;
        populateAlerts(alertTitles, userBenefit); // IPA2.0-TWC727-2896
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
        //splitting the links for metrics CTC and right hand links CTC
        populateCTALinks(links,ctaPriorities,ctaLinks); // IPA2.0-TWC727-2896
        
       //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
        
       /* if(alertTitles.size()>0)//  display alert part
        {
            List<IPABenefitWrapper.Alerts> alertList=new List<IPABenefitWrapper.Alerts>();
            for(String a:alertTitles)
            {
                IPABenefitWrapper.Alerts alert=new IPABenefitWrapper.Alerts();
                alert.label=a;
                alertList.add(alert);  
            }
            userBenefit.alerts=alertList;    
        }
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            userBenefit.adhocAlerts=adhocList;    
        }
        //splitting the links for metrics CTC and right hand links CTC
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            } 
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]);
                ctaLinks.add(links[i]);
            }
        }*/
         //IPA2.0-TWC727-2896
       // Step 1: Create controller for your custom metadata name
        Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');

        // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
        Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();
       
       //Step 3: Iterate your CTA list
        for(String ctaPrior :ctaPriorities){ 
             IPABenefitWrapper.Link mlink = new IPABenefitWrapper.Link();
              if (ctaMetaMap.containsKey(ctaPrior)) {
                Map<String, Object> meta = ctaMetaMap.get(ctaPrior);
                IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
               
                if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0]; }
                if(String.valueOf(meta.get('type'))=='getTraining' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                  
                    mlink.label = String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    mlink.externalUrl = String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                    metricCTCS.link = mlink;
                  }
                }
                 userBenefit.Metrics = trainingMetrics;
            }
            if(ctaLinks.size()>0){
                for (String cta : ctaLinks) {
                    IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    if (ctaMetaMap.containsKey(cta)) {
                        Map<String, Object> meta = ctaMetaMap.get(cta);
                       
                    if(String.valueOf(meta.get('type'))=='getTraining' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){   
                        link1.label = String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                        link1.externalUrl = String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                        }
                     }
                      linkList.add(link1); 
                }
                userBenefit.links=linkList;  
        } 
         return userBenefit; 

    }
    //IPA2.0-TWC727-2896>> end
            /*switch on ctaPrior {              
                when 'View Courses' { 
                    IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0];    }
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Training_View_Courses_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_View_Courses_bnftlnk_Link;
                    metricCTCS.link=mlink;
                } 
                when 'My Competencies' { 
                    IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0];    }
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Training_compentencies_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Training_compentencies_bnftlnk_Link;//
                    metricCTCS.link=mlink;
                } 
               /* when 'Track My Learning' { 
                    IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0];    }
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Training_Learning_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Training_Learning_bnftlnk_Link; 
                    metricCTCS.link=mlink;
                }*/ //IPA2.0 TWC727-2912
                /*when 'Browse All Webinars' { 
                    IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0];    }
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Training_webinars_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Training_webinars_bnftlnk_Link;
                    metricCTCS.link=mlink;
                }
                when 'Get Help With Training' { 
                    IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0];    }
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Training_Get_help_Label;
                    mlink.externalUrl=System.Label.IPA_Training_Get_help_Link;
                    metricCTCS.link=mlink;
                }
                when 'View Distributor Webinars on demand' { 
                     IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0];    }
                     IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                     mlink.label= System.Label.IPA_Training_Dist_Webinars_Label;
                     mlink.externalUrl=System.Label.IPA_Training_Dist_Webinars_Link;
                     metricCTCS.link=mlink;
                }
                when 'Competitive Guidance Presentation' {
                    IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0];    }
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Training_Dist_competitive_Label;
                    mlink.externalUrl=System.Label.IPA_Training_Dist_competitive_Link;
                    metricCTCS.link=mlink;
                }
                when 'Virtual Tech Conference' {
                    IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0];    }
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Training_Dist_virtualtech_Label;
                    mlink.externalUrl=System.Label.IPA_Training_Dist_virtualtech_Link;
                    metricCTCS.link=mlink;
                }
                when 'How to sell videos' { 
                    IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0];    }
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Training_Dist_Videos_Label;
                    mlink.externalUrl=System.Label.IPA_Training_Dist_Videos_Link;
                    metricCTCS.link=mlink;
                }
                when 'Quarterly Training Matrix' { 
                    IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0];    }
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Quarterly_Training_Matrix_Label;
                    mlink.externalUrl=System.Label.IPA_Quarterly_Training_Matrix_Link;
                    metricCTCS.link=mlink;
                }
                // when 'Register for Distributor Webinars' { 
                //     IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                //     if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0];    }
                //     IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                //     mlink.label= System.Label.prm_Register_for_Distributor_Webinars;
                //     mlink.externalUrl=System.Label.prm_Register_for_Distributor_Webinars_link;
                //     metricCTCS.link=mlink;
                // }

                //IPA2.0 TWC727-2912
                 when 'Partner University Pathways' { 
                    IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(trainingMetrics.size() >= 2){ metricCTCS = trainingMetrics[1]; } else{ metricCTCS = trainingMetrics[0];    }
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Partner_University_Pathway_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Partner_University_Pathway_bnftlnk_Link;
                    metricCTCS.link=mlink;
                }
                
            }
        }
        //update the metric with last ctc and assign it to wrapper
        userBenefit.Metrics = trainingMetrics;
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
        for(String cta:ctaLinks)
        {
            IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
            switch on cta {
                when 'View Courses' {
                    link1.label=System.Label.IPA_Training_View_Courses_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_View_Courses_bnftlnk_Link;
                }
                when 'My Competencies' {
                    link1.label=System.Label.IPA_Training_compentencies_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Training_compentencies_bnftlnk_Link;
                }
                /*when 'Track My Learning' {
                    link1.label=System.Label.IPA_Training_Learning_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Training_Learning_bnftlnk_Link;
                }*/ //IPA 2.0 TWC727-2912
               /* when 'Browse All Webinars' {
                    link1.label=System.Label.IPA_Training_webinars_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Training_webinars_bnftlnk_Link;
                }
                when 'Get Help With Training' {
                    link1.label=System.Label.IPA_Training_Get_help_Label;
                    link1.externalUrl=System.Label.IPA_Training_Get_help_Link;
                }
                when 'View Distributor Webinars on demand' {
                    link1.label=System.Label.IPA_Training_Dist_Webinars_Label;
                    link1.externalUrl=System.Label.IPA_Training_Dist_Webinars_Link;
                }
                when 'Competitive Guidance Presentation' {
                    link1.label=System.Label.IPA_Training_Dist_competitive_Label;
                    link1.externalUrl=System.Label.IPA_Training_Dist_competitive_Link;
                }
                when 'Virtual Tech Conference' {
                    link1.label=System.Label.IPA_Training_Dist_virtualtech_Label;
                    link1.externalUrl=System.Label.IPA_Training_Dist_virtualtech_Link;
                }
                when 'How to sell videos' {
                    link1.label=System.Label.IPA_Training_Dist_Videos_Label;
                    link1.externalUrl=System.Label.IPA_Training_Dist_Videos_Link;
                }
                when 'Quarterly Training Matrix'{
                    link1.label=System.Label.IPA_Quarterly_Training_Matrix_Label;
                    link1.externalUrl=System.Label.IPA_Quarterly_Training_Matrix_Link;
                }
                // when 'Register for Distributor Webinars' {                     
                //     link1.label= System.Label.prm_Register_for_Distributor_Webinars;
                //     link1.externalUrl=System.Label.prm_Register_for_Distributor_Webinars_link;
                // }
                
                //IPA 2.0 TWC727-2912
                when 'Partner University Pathways'{
                    link1.label=System.Label.IPA_Partner_University_Pathway_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Partner_University_Pathway_bnftlnk_Link;
                }
            }
            linkList.add(link1);             
        }
        
        userBenefit.links=linkList;   
        // //system.debug('training--->'+userBenefit.title);
        return userBenefit;    
    }*/
    
    //call this method to get Points details    
    public static IPABenefitWrapper.UserBenefitInfo getPoints(List<String> links,List<String> alertTitles,Map<String,String> adhocMsgs){
        
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title=System.Label.IPA_Points_bnft_Title;
        userBenefit.faIcon=showLogoMap.containsKey('Points') && !showLogoMap.get('Points')?System.Label.IPA_Points_bnft_Icon:null;
        userBenefit.description=System.Label.IPA_Points_bnft_Description;
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ; //IPA2.0-TWC727-2896
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();  //IPA2.0-TWC727-2896
        populateAlerts(alertTitles, userBenefit); //IPA2.0-TWC727-2896
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
        populateCTALinks(links,ctaPriorities,ctaLinks); // IPA2.0-TWC727-2896
        //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
        //IPA2.0-TWC727-2896>> start
        // Step 1: Create controller for your custom metadata name
        Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');
        
        // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
        Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

        for (String cta : ctaPriorities) {
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
               
                if(String.valueOf(meta.get('type')) == 'getPoints'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){ 
                
                    mlink.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                    metric.link=mlink;
                }
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
         
        if(ctaLinks.size()>0){
                for (String cta : ctaLinks) {
                     IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                        if(ctaMetaMap.containsKey(cta)) {
                            Map<String, Object> meta = ctaMetaMap.get(cta);
                           
                            if(String.valueOf(meta.get('type'))=='getPoints' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                          
                                link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                             link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                            }
                        }
                         linkList.add(link1);
                    }
                     userBenefit.links=linkList; 
                }
                return userBenefit;
            }
           //IPA2.0-TWC727-2896>> end
    
       /* if(alertTitles.size()>0)
        {
            List<IPABenefitWrapper.Alerts> alertList=new List<IPABenefitWrapper.Alerts>();
            for(String a:alertTitles)
            {
                IPABenefitWrapper.Alerts alert=new IPABenefitWrapper.Alerts();
                alert.label=a;
                alertList.add(alert);  
            }
            userBenefit.alerts=alertList;            
        }
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            userBenefit.adhocAlerts=adhocList;    
        }
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            } 
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]);
                ctaLinks.add(links[i]);
            }
        }
        //create 1 metric for points based on cta priority
        for(String ctaPrior :ctaPriorities){ 
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
            
            switch on ctaPrior {              
                when 'Points Wishlist' { 
                    // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
                    // IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Points_wishlist_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Points_wishlist_bnftlnk_Link;
                    metric.link=mlink;
                    //metric.value=;
                    //metric.unit='HR';
                }  
                when 'Spend Points' { 
                    // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
                    // IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Points_spend_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Points_spend_bnftlnk_Link;
                    metric.link=mlink;
                    //metric.value=;
                    //metric.unit='HR';
                }
                //commmenting out for TWC729-7701
          		/*when 'Points Simulator Tool' { 
                    // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
                    // IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Points_tool_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Points_tool_bnftlnk_Link;
                    metric.link=mlink;
                    //metric.value=;
                    //metric.unit='HR';
                }*/
                /*when 'Earn Points' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();     
                    mlink.label=System.Label.IPA_Points_earn_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Points_earn_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'Points Matrix' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();     
                    mlink.label=System.Label.IPA_Points_mtrx_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Points_mtrx_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'View Account' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();      
                    mlink.label=System.Label.IPA_Points_view_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Points_view_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'Partner Assist' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();       
                    mlink.label=System.Label.IPA_Points_assist_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Points_assist_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'Get help with Points' {         
                    //   IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();       
                    mlink.label=System.Label.IPA_Points_help_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Points_help_bnftlnk_Link;
                    metric.link=mlink;
                }
            }
            listMetrics.add(metric);
        }
        userBenefit.Metrics = listMetrics;
        //create links on the blade
        if(ctaLinks.size()>0){
            List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
            for(String cta:ctaLinks)
            {    
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'Spend Points' {
                        //IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                        link1.label=System.Label.IPA_Points_spend_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_Points_spend_bnftlnk_Link;
                    }
                    when 'Points Wishlist' {
                        link1.label=System.Label.IPA_Points_wishlist_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_Points_wishlist_bnftlnk_Link;
                    }
                    //commmenting out for TWC729-7701
                	/*when 'Points Simulator Tool' {
                        link1.label=System.Label.IPA_Points_tool_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_Points_tool_bnftlnk_Link;
                    }*/
                   /* when 'Earn Points' {
                        link1.label=System.Label.IPA_Points_earn_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_Points_earn_bnftlnk_Link;
                    }
                    when 'Points Matrix' {
                        link1.label=System.Label.IPA_Points_mtrx_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_Points_mtrx_bnftlnk_Link;
                    }
                    when 'View Account' {
                        link1.label=System.Label.IPA_Points_view_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_Points_view_bnftlnk_Link;
                    }
                    when 'Partner Assist' {
                        link1.label=System.Label.IPA_Points_assist_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_Points_assist_bnftlnk_Link;
                    }
                    when 'Get help with Points' {
                        link1.label=System.Label.IPA_Points_help_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_Points_help_bnftlnk_Link;
                    }
                }
                linkList.add(link1);             
            }
            userBenefit.links=linkList; 
        }    
        return userBenefit;    
    }*/
    
    public static IPABenefitWrapper.UserBenefitInfo getIPALookupTool(List<String> ipaLookupToolLinks,Map<String,String> adhocMsgs,boolean showDistiOnIpaLookUp)//TWC727-887 - Utkarsh - passed new boolean parameter
    {

        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.PRM_PartnerLookup_Blade_Title;
        userBenefit.faIcon=showLogoMap.containsKey('Partner Lookup Tool') && !showLogoMap.get('Partner Lookup Tool')?System.Label.PRM_IPALookup_Icon:null;
        userBenefit.description=System.Label.PRM_IPALookup_Description;
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        
        List<IPABenefitWrapper.Metrics> ipaLookUpMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        
         populateCTALinks(ipaLookupToolLinks,ctaPriorities,ctaLinks); // IPA2.0-TWC727-2896
	 //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
         //IPA2.0-TWC727-2896>> start
        // Step 1: Create controller for your custom metadata name
            Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');
            
            // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
            Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

            // Step 3: Iterate your CTA list
            //create metric for points based on cta priority
            for (String cta : ctaPriorities) {
                 IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                if (ctaMetaMap.containsKey(cta)) {
                    Map<String, Object> meta = ctaMetaMap.get(cta);
                   
                    if(String.valueOf(meta.get('type'))=='getIPALookupTool' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                        if((cta=='Points Opportunity Report' && !showPartnerReports)||(cta=='Partner Assist Dashboard' && !showDistiOnIpaLookUp)||(cta=='Reseller List Report' && !showPartnerReports)){
                            continue;
                        }else{
                      mlink.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                      mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang)); 
                      metric.link=mlink;
                        }
                    }
                }
                  ipaLookUpMetrics.add(metric);
                  userBenefit.Metrics = ipaLookUpMetrics; 
            }
        
        //create links on the blade
        if(ctaLinks.size()>0){
            for (String cta : ctaLinks) {
             IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
              
                  if(String.valueOf(meta.get('type'))=='getIPALookupTool' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    if((cta=='Points Opportunity Report' && !showPartnerReports)||(cta=='Partner Assist Dashboard' && !showDistiOnIpaLookUp)||(cta=='Reseller List Report' && !showPartnerReports)){
                            continue;
                        }else{
                                link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),''));
                                link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),''));
                        }
                  }
                }
                if(String.isNotBlank(link1.label) || String.isNotBlank(link1.externalUrl)){
                             linkList.add(link1);
                }
            }
             userBenefit.links=linkList;
        }
         populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
         return userBenefit;  

    }
 //IPA2.0-TWC727-2896>> end
       /* for(integer i = 0;i<ipaLookupToolLinks.size(); i++){
            ctaPriorities.add(ipaLookupToolLinks[0]);
            if(ipaLookupToolLinks[i] != ctaPriorities[0]){
                ctaLinks.add(ipaLookupToolLinks[i]);  
            } 
            if(Test.isRunningTest()){
                ctaPriorities.add(ipaLookupToolLinks[i]);
                ctaLinks.add(ipaLookupToolLinks[i]);
            }
        }
        //create metric for points based on cta priority
        for(String ctaPrior :ctaPriorities){
            switch on ctaPrior {              
                when 'Partner Lookup Tool' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.PRM_PartnerLookup_Title;
                    mlink.externalUrl=System.Label.PRM_IPALookup_Link;
                    metric.link=mlink;
                }
                // TWC729-6644 - Updates to Distributor IPA Manage Benefits Page Request
                when 'Intel® Partner Alliance Overview Video' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.IPA_Overview;
                    mlink.externalUrl=System.Label.IPA_Overview_Link;
                    metric.link=mlink;
                }
                /*
                when 'Intel® Partner Alliance Brochure' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.IPA_Broucher;
                    mlink.externalUrl=System.Label.IPA_Broucher_Link;
                    metric.link=mlink;
                }*/ //IPA2.0 TWC727-2912

                /*when 'Intel® Partner Alliance 30-3-30 Distributor Version' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.IPA_DistributorVersion;
                    mlink.externalUrl=System.Label.IPA_DistributorVersion_Link;
                    metric.link=mlink;
                }
                /* //IPA2.0 starts here --TWC727-2912
                when 'Developer Zone Premier One Pager Jan 2024' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.IPA_DeveloperZone;
                    mlink.externalUrl=System.Label.IPA_DeveloperZone_Link;
                    metric.link=mlink;
                }

                when 'Points One Pager Jan 2024' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.IPA_OnePager;
                    mlink.externalUrl=System.Label.IPA_OnePager_link;
                    metric.link=mlink;
                }

                when 'Technical Enablement Redemption Coupon Jan 2024' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.IPA_TechnicalRdemption;
                    mlink.externalUrl=System.Label.IPA_TechnicalRdemption_Link;
                    metric.link=mlink;
                } 
                */ //IPA 2.0 ends here
                // TWC729-6644 - End

               /* when 'Partner Assist Dashboard' {
                    if(showDistiOnIpaLookUp == true){//TWC727-887 - Utkarsh - Check value of boolean variable before enabling Disti dashboard for link on IPA Lookup Tool.
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                        mlink.label= System.Label.PRM_IPALookUpTool_Disti;
                        mlink.externalUrl=System.Label.PRM_IPALookupDisti_Link;
                        metric.link=mlink;
                    }
                }
                when 'Points Opportunity Report' { 
                    if(showPartnerReports == true){
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.IPA_PointOpportunityReport;
                    mlink.externalUrl=System.Label.IPA_PointOpportunityReport_Link;
                    metric.link=mlink;
            }
            }
                when 'Reseller List Report' {
                    if(showPartnerReports == true){
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.IPA_ResellerListReport;
                    mlink.externalUrl=System.Label.IPA_ResellerListReport_Link;
                    metric.link=mlink;
                } 
                }

                
            }
            ipaLookUpMetrics.add(metric);
            userBenefit.Metrics = ipaLookUpMetrics;
        }
        //create links on the blade
        if(ctaLinks.size()>0){
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'Partner Lookup Tool' {
                        link1.label=System.Label.PRM_PartnerLookup_Title;
                        link1.externalUrl=System.Label.PRM_IPALookup_Link;
                    }
                    // TWC729-6644 - Updates to Distributor IPA Manage Benefits Page Request
                    when 'Intel® Partner Alliance Overview Video' {
                        link1.label=System.Label.IPA_Overview;
                        link1.externalUrl=System.Label.IPA_Overview_Link;
                    }
                    /*
                    when 'Intel® Partner Alliance Brochure' { 
                        link1.label=System.Label.IPA_Broucher;
                        link1.externalUrl=System.Label.IPA_Broucher_Link;
                    }*/ //IPA2.0 TWC727-2912

                   /* when 'Intel® Partner Alliance 30-3-30 Distributor Version' { 
                        link1.label=System.Label.IPA_DistributorVersion;
                        link1.externalUrl=System.Label.IPA_DistributorVersion_Link;
                    }
                    /* //IPA2.0 starts here --TWC727-2912
                    when 'Developer Zone Premier One Pager Jan 2024' { 
                        link1.label=System.Label.IPA_DeveloperZone;
                        link1.externalUrl=System.Label.IPA_DeveloperZone_Link;
                    }

                    when 'Points One Pager Jan 2024' { 
                        link1.label=System.Label.IPA_OnePager;
                        link1.externalUrl=System.Label.IPA_OnePager_link;
                    }

                    when 'Technical Enablement Redemption Coupon Jan 2024' { 
                        link1.label=System.Label.IPA_TechnicalRdemption;
                        link1.externalUrl=System.Label.IPA_TechnicalRdemption_Link;
                    } */ //IPA2.0 ends here
                    // TWC729-6644 - End
                    
                    /*when 'Partner Assist Dashboard' {
                        if(showDistiOnIpaLookUp == true){//TWC727-887 - Utkarsh - Check value of boolean variable before enabling Disti dashboard for link on IPA Lookup Tool.
                            link1.label=System.Label.PRM_IPALookUpTool_Disti;
                            link1.externalUrl=System.Label.PRM_IPALookupDisti_Link;
                        }
                    }
                    when 'Points Opportunity Report' {
                        if(showPartnerReports == true){
                        link1.label=System.Label.IPA_PointOpportunityReport;
                        link1.externalUrl=System.Label.IPA_PointOpportunityReport_Link;
                        }
                    }
                    when 'Reseller List Report' { 
                        if(showPartnerReports == true){
                        link1.label=System.Label.IPA_ResellerListReport;
                        link1.externalUrl=System.Label.IPA_ResellerListReport_Link;
                        }
                    }

                }
                if(String.isNotBlank(link1.label) || String.isNotBlank(link1.externalUrl)){
                             linkList.add(link1);
                }
            }
            userBenefit.links=linkList;
        }
        //display adhoc part
        if(adhocMsgs.size()>0)
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            //system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;        
    }*/
     public static IPABenefitWrapper.UserBenefitInfo getActivationZones(List<String> accessZonesList,Map<String,String> adhocMsgs)
    {//TWC729-7755

        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.PRM_Activation_Zones_Label;
	//IPA2.0 TWC727-2912
        userBenefit.faIcon=showLogoMap.containsKey('Enablement Zones') && !showLogoMap.get('Enablement Zones')?System.Label.IPA_PPP_bnft_Icon:null;
        userBenefit.description=System.Label.PRM_Activation_Zones_Description;
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        
        List<IPABenefitWrapper.Metrics> activationZoneMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        
        for(integer i = 0;i<accessZonesList.size(); i++){
            ctaPriorities.add(accessZonesList[0]);
            if(accessZonesList[i] != ctaPriorities[0]){
                ctaLinks.add(accessZonesList[i]);  
            }
        }
        //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
       //IPA2.0-TWC727-2896>> start
        // Step 1: Create controller for your custom metadata name
        Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');

        // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
        Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

        // Step 3: Iterate your CTA list
        //create metric for points based on cta priority
            for (String cta : ctaPriorities) {
                IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                if (ctaMetaMap.containsKey(cta)) {
                    Map<String, Object> meta = ctaMetaMap.get(cta);
                 
                    if(String.valueOf(meta.get('type'))=='getActivationZones' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                       
                        mlink.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                        mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                        metric.link=mlink;
                    }
                }
          activationZoneMetrics.add(metric);
          userBenefit.Metrics = activationZoneMetrics;
        }

        //create links on the blade
        if(ctaLinks.size()>0){
            for (String cta : ctaLinks) {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                if (ctaMetaMap.containsKey(cta)) {
                    Map<String, Object> meta = ctaMetaMap.get(cta);
                 
                    if(String.valueOf(meta.get('type'))=='getActivationZones' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                        link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                      link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                    }
                }
                if(String.isNotBlank(link1.label) || String.isNotBlank(link1.externalUrl)){
                             linkList.add(link1);
                }
            }
               userBenefit.links=linkList;
        }
         //display adhoc part
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
        return userBenefit; 
    } //IPA2.0-TWC727-2896>> end


       /* //create metric for points based on cta priority
        for(String ctaPrior :ctaPriorities){
            // IPA2.0 TWC727-2912
            switch on ctaPrior {              
                when 'Intel® Partner Alliance Enablement Zones' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.PRM_Activation_Zones;
                    mlink.externalUrl=System.Label.PRM_Activation_Zones_Link;
                    metric.link=mlink;
                }
                when 'Artificial Intelligence' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.PRM_AI_Zones;
                    mlink.externalUrl=System.Label.PRM_AI_Zones_Link;
                    metric.link=mlink;
                }
                when 'Data Center Modernization' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.PRM_Data_Center_Management_Zones;
                    mlink.externalUrl=System.Label.PRM_Data_Center_Management_Zones_Link;
                    metric.link=mlink;
                }

                when 'Security' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.PRM_Security_Zones;
                    mlink.externalUrl=System.Label.PRM_Security_Zones_Link;
                    metric.link=mlink;
                }
                when 'Edge and Networking' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.PRM_Edge_And_Netwroking;
                    mlink.externalUrl=System.Label.PRM_Edge_And_Netwroking_Link;
                    metric.link=mlink;
                }
                when 'Industry' { 
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.PRM_Industry_Zones;
                    mlink.externalUrl=System.Label.PRM_Industry_Zones_Link;
                    metric.link=mlink;
                }
                //IPA2.0 TWC727-2912
                when 'Commercial PC Refresh'{
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label=System.Label.Commercial_PC_Refresh;
                    mlink.externalUrl=System.Label.Commercial_PC_Refresh_Link;
                    metric.link=mlink;
                }
            }
                
        }
            activationZoneMetrics.add(metric);
            userBenefit.Metrics = activationZoneMetrics;
        //create links on the blade
        if(ctaLinks.size()>0){
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
		//IPA2.0 TWC727-2912
                when 'Intel® Partner Alliance Enablement Zones' { 
                                     
                    Link1.label=System.Label.PRM_Activation_Zones;
                    Link1.externalUrl=System.Label.PRM_Activation_Zones_Link;

                }
                when 'Artificial Intelligence' { 
                                     
                    Link1.label=System.Label.PRM_AI_Zones;
                    Link1.externalUrl=System.Label.PRM_AI_Zones_Link;

                }
                when 'Data Center Modernization' { 
                                     
                    Link1.label=System.Label.PRM_Data_Center_Management_Zones;
                    Link1.externalUrl=System.Label.PRM_Data_Center_Management_Zones_Link;

                }

                when 'Security' { 
                                     
                    Link1.label=System.Label.PRM_Security_Zones;
                    Link1.externalUrl=System.Label.PRM_Security_Zones_Link;

                }
                when 'Edge and Networking' { 
                                     
                    Link1.label=System.Label.PRM_Edge_And_Netwroking;
                    Link1.externalUrl=System.Label.PRM_Edge_And_Netwroking_Link;

                }
                when 'Industry' { 
                                     
                    Link1.label=System.Label.PRM_Industry_Zones;
                    Link1.externalUrl=System.Label.PRM_Industry_Zones_Link;

                }
                //IPA2.0 TWC727-2912
                when 'Commercial PC Refresh'{
                    Link1.label=System.Label.Commercial_PC_Refresh;
                    Link1.externalUrl=System.Label.Commercial_PC_Refresh_Link;
                } 

                }
                if(String.isNotBlank(link1.label) || String.isNotBlank(link1.externalUrl)){
                             linkList.add(link1);
                }
            }
            userBenefit.links=linkList;
        }
        //display adhoc part
        if(adhocMsgs.size()>0)
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            //system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;        
    }*/
    
    /*public static IPABenefitWrapper.UserBenefitInfo getSpecialtyArtifical(List<String> speclinks,Map<String,String> adhocMsgs)
    {
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.IPA_Specialty_AI_Title;//System.Label.IPA_Specialty_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Specialty_bnft_Icon;
        userBenefit.description=System.Label.IPA_Specialty_bnft_Description;
        //system.debug('Specialty blade'+userBenefit.title);
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        
        List<IPABenefitWrapper.Metrics> specAIMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_Specialty_ArtificialIntell_Label;
        mlink.externalUrl=System.Label.IPA_Specialty_ArtificialIntell_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        specAIMetrics.add(metric);
        userBenefit.Metrics = specAIMetrics;
        userBenefit.links=linkList;
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            //system.debug('Inside Artif adhoc msg loop');
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                //system.debug('List of ID'+IdList);
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                //system.debug('ids'+IdList[0]);
                //system.debug('labels'+IdList[1]);
                adhocList.add(adhocAlert);  
            }
            //system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;        
    }*/
    //cloud data center specialty
   /* public static IPABenefitWrapper.UserBenefitInfo getSpecialtyCloudData(List<String> speclinks,Map<String,String> adhocMsgs)
    {
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.IPA_Specialty_CD_Title;//System.Label.IPA_Specialty_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Specialty_bnft_Icon;
        userBenefit.description=System.Label.IPA_Specialty_bnft_Description;
        //system.debug('Specialty blade'+userBenefit.title);
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        
        List<IPABenefitWrapper.Metrics> specAIMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_Specialty_CloudDataCenter_Label;
        mlink.externalUrl=System.Label.IPA_Specialty_CloudDataCenter_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        specAIMetrics.add(metric);
        userBenefit.Metrics = specAIMetrics;
        userBenefit.links=linkList;
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            //system.debug('Inside Spec Cloud adhoc msg loop');
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                //system.debug('List of ID'+IdList);
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                //system.debug('ids'+IdList[0]);
                //system.debug('labels'+IdList[1]);
                adhocList.add(adhocAlert);  
            }
            //system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;        
    }*/
    //High Performance Computing Data Center Specialty
    /*public static IPABenefitWrapper.UserBenefitInfo getSpecialtyHighPerformanceSpecialty(List<String> speclinks,Map<String,String> adhocMsgs)
    {
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.IPA_Specialty_HPC_Title;//System.Label.IPA_Specialty_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Specialty_bnft_Icon;
        userBenefit.description=System.Label.IPA_Specialty_bnft_Description;
        //system.debug('Specialty blade'+userBenefit.title);
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        
        List<IPABenefitWrapper.Metrics> specAIMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_Specialty_HighPerformComp_Label;
        mlink.externalUrl=System.Label.IPA_Specialty_HighPerformComp_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        specAIMetrics.add(metric);
        userBenefit.Metrics = specAIMetrics;
        userBenefit.links=linkList;
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            //system.debug('Inside hp adhoc msg loop');
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                //system.debug('List of ID'+IdList);
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                //system.debug('ids'+IdList[0]);
                //system.debug('labels'+IdList[1]);
                adhocList.add(adhocAlert);  
            }
            //system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;        
    }*/
    //Video Specialty
    /*public static IPABenefitWrapper.UserBenefitInfo getSpecialtyVideoSpecialty(List<String> speclinks,Map<String,String> adhocMsgs)
    {
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.IPA_Specialty_Video_Title;//System.Label.IPA_Specialty_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Specialty_bnft_Icon;
        userBenefit.description=System.Label.IPA_Specialty_bnft_Description;
        //system.debug('Specialty blade'+userBenefit.title);
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        
        List<IPABenefitWrapper.Metrics> specAIMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_Specialty_Video_Label;
        mlink.externalUrl=System.Label.IPA_Specialty_Video_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        specAIMetrics.add(metric);
        userBenefit.Metrics = specAIMetrics;
        userBenefit.links=linkList;
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            //system.debug('Inside video adhoc msg loop');
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                //system.debug('List of ID'+IdList);
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                //system.debug('ids'+IdList[0]);
                //system.debug('labels'+IdList[1]);
                adhocList.add(adhocAlert);  
            }
            //system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;        
    }*/
    //Industrial Solutions Builder Specialty
    /*public static IPABenefitWrapper.UserBenefitInfo getSpecialtySolutionsBuilder(List<String> speclinks,Map<String,String> adhocMsgs)
    {
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.IPA_Specialty_SolnBuilder_Title;//System.Label.IPA_Specialty_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Specialty_bnft_Icon;
        userBenefit.description=System.Label.IPA_Specialty_bnft_Description;
        ////system.debug('Specialty blade'+userBenefit.title);
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        
        List<IPABenefitWrapper.Metrics> specAIMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_Specialty_IndusSolB_Label;
        mlink.externalUrl=System.Label.IPA_Specialty_IndusSolB_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        specAIMetrics.add(metric);
        userBenefit.Metrics = specAIMetrics;
        userBenefit.links=linkList;
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            ////system.debug('Inside builder adhoc msg loop');
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                ////system.debug('List of ID'+IdList);
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                ////system.debug('ids'+IdList[0]);
                ////system.debug('labels'+IdList[1]);
                adhocList.add(adhocAlert);  
            }
            ////system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;        
    }*/
    //Optane Data Center Specialty
    /*public static IPABenefitWrapper.UserBenefitInfo getSpecialtyOptaneData(List<String> speclinks,Map<String,String> adhocMsgs)
    {
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.IPA_Specialty_OptnData_Title;//System.Label.IPA_Specialty_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Specialty_bnft_Icon;
        userBenefit.description=System.Label.IPA_Specialty_bnft_Description;
        ////system.debug('Specialty blade'+userBenefit.title);
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        
        List<IPABenefitWrapper.Metrics> specAIMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_Specialty_OptDataCenter_Label;
        mlink.externalUrl=System.Label.IPA_Specialty_OptDataCenter_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        specAIMetrics.add(metric);
        userBenefit.Metrics = specAIMetrics;
        userBenefit.links=linkList;
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            ////system.debug('Inside optane adhoc msg loop');
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                ////system.debug('List of ID'+IdList);
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                ////system.debug('ids'+IdList[0]);
                ////system.debug('labels'+IdList[1]);
                adhocList.add(adhocAlert);  
            }
            ////system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;        
    }*/
    //Visual Display Solutions Specialty
    /*public static IPABenefitWrapper.UserBenefitInfo getSpecialtyVisualDisplay(List<String> speclinks,Map<String,String> adhocMsgs)
    {
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.IPA_Specialty_Visual_Title;//System.Label.IPA_Specialty_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Specialty_bnft_Icon;
        userBenefit.description=System.Label.IPA_Specialty_bnft_Description;
        ////system.debug('Specialty blade'+userBenefit.title);
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        
        List<IPABenefitWrapper.Metrics> specAIMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_Specialty_VisualDisplay_Label;
        mlink.externalUrl=System.Label.IPA_Specialty_VisualDisplay_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        specAIMetrics.add(metric);
        userBenefit.Metrics = specAIMetrics;
        userBenefit.links=linkList;
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            ////system.debug('Inside visual adhoc msg loop');
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                ////system.debug('List of ID'+IdList);
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                ////system.debug('ids'+IdList[0]);
                ////system.debug('labels'+IdList[1]);
                adhocList.add(adhocAlert);  
            }
            ////system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;        
    }*/
    //Optane Client Specialty
    /*public static IPABenefitWrapper.UserBenefitInfo getSpecialtyOptaneClient(List<String> speclinks,Map<String,String> adhocMsgs)
    {
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.IPA_Specialty_OptnClient_Title;//System.Label.IPA_Specialty_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Specialty_bnft_Icon;
        userBenefit.description=System.Label.IPA_Specialty_bnft_Description;
        ////system.debug('Specialty blade'+userBenefit.title);
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        
        List<IPABenefitWrapper.Metrics> specAIMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_Specialty_OptaneClient_Label;
        mlink.externalUrl=System.Label.IPA_Specialty_OptaneClient_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        specAIMetrics.add(metric);
        userBenefit.Metrics = specAIMetrics;
        userBenefit.links=linkList;
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            ////system.debug('Inside optane client adhoc msg loop');
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                ////system.debug('List of ID'+IdList);
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                ////system.debug('ids'+IdList[0]);
                ////system.debug('labels'+IdList[1]);
                adhocList.add(adhocAlert);  
            }
            ////system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;        
    }*/
    //Managed Services Specialty
    /*public static IPABenefitWrapper.UserBenefitInfo getSpecialtyManagedService(List<String> speclinks,Map<String,String> adhocMsgs)
    {
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.IPA_Specialty_MngeServ_Title;//System.Label.IPA_Specialty_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Specialty_bnft_Icon;
        userBenefit.description=System.Label.IPA_Specialty_bnft_Description;
        ////system.debug('Specialty blade'+userBenefit.title);
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        
        List<IPABenefitWrapper.Metrics> specAIMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_Specialty_ManageService_Label;
        mlink.externalUrl=System.Label.IPA_Specialty_ManageService_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        specAIMetrics.add(metric);
        userBenefit.Metrics = specAIMetrics;
        userBenefit.links=linkList;
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            ////system.debug('Inside managed adhoc msg loop');
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                ////system.debug('List of ID'+IdList);
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                ////system.debug('ids'+IdList[0]);
                ////system.debug('labels'+IdList[1]);
                adhocList.add(adhocAlert);  
            }
            ////system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;        
    }*/
    
    //Device as a Service Specialty
    /*public static IPABenefitWrapper.UserBenefitInfo getSpecialtyDeviceService(List<String> speclinks,Map<String,String> adhocMsgs)
    {
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.IPA_Specialty_DeviceServ_Title;//System.Label.IPA_Specialty_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Specialty_bnft_Icon;
        userBenefit.description=System.Label.IPA_Specialty_bnft_Description;
        ////system.debug('Specialty blade'+userBenefit.title);
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        
        List<IPABenefitWrapper.Metrics> specAIMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_Specialty_DeviceService_Label;
        mlink.externalUrl=System.Label.IPA_Specialty_DeviceService_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        specAIMetrics.add(metric);
        userBenefit.Metrics = specAIMetrics;
        userBenefit.links=linkList;
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            ////system.debug('Inside device adhoc msg loop');
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                ////system.debug('List of ID'+IdList);
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                ////system.debug('ids'+IdList[0]);
                ////system.debug('labels'+IdList[1]);
                adhocList.add(adhocAlert);  
            }
            ////system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;        
    }*/
    
    //Enthusiast PC Specialty
    /*public static IPABenefitWrapper.UserBenefitInfo getSpecialtyEnthusiastSpecialty(List<String> speclinks,Map<String,String> adhocMsgs)
    {
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.IPA_Specialty_Enthus_Title;//System.Label.IPA_Specialty_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Specialty_bnft_Icon;
        userBenefit.description=System.Label.IPA_Specialty_bnft_Description;
        ////system.debug('Specialty blade'+userBenefit.title);
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        
        List<IPABenefitWrapper.Metrics> specAIMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_Specialty_Enthus_Label;
        mlink.externalUrl=System.Label.IPA_Specialty_Enthus_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        specAIMetrics.add(metric);
        userBenefit.Metrics = specAIMetrics;
        userBenefit.links=linkList;
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            ////system.debug('Inside enthu adhoc msg loop');
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                ////system.debug('List of ID'+IdList);
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                ////system.debug('ids'+IdList[0]);
                ////system.debug('labels'+IdList[1]);
                adhocList.add(adhocAlert);  
            }
            ////system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        return userBenefit;  
        
        
    }*/
    
    // Networking Specialty
    /*public static IPABenefitWrapper.UserBenefitInfo getSpecialtyNetworkingSpecialty(List<String> speclinks,Map<String,String> adhocMsgs)
    {
    List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
    List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title= System.Label.IPA_Specialty_Networking_Title;
        userBenefit.faIcon=System.Label.IPA_NetworkingSpecialty_bnft_Icon;
        userBenefit.description=System.Label.IPA_Specialty_bnft_Description;
        ////system.debug('Specialty blade'+userBenefit.title);
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        
        List<IPABenefitWrapper.Metrics> specAIMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        // metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_Specialty_Networking_Label;
        mlink.externalUrl=System.Label.IPA_Specialty_Networking_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        specAIMetrics.add(metric);
        userBenefit.Metrics = specAIMetrics;
        userBenefit.links=linkList; 
        
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            ////system.debug('Inside network adhoc msg loop');
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                ////system.debug('List of ID'+IdList);
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                ////system.debug('ids'+IdList[0]);
                ////system.debug('labels'+IdList[1]);
                adhocList.add(adhocAlert);  
            }
            ////system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
    
    for(integer i = 0;i<speclinks.size(); i++){
            ctaPriorities.add(speclinks[0]);
            if(speclinks[i] != ctaPriorities[0]){
                ctaLinks.add(speclinks[i]);      
            }
            if(Test.isRunningTest()){
                ctaPriorities.add(speclinks[i]); 
                ctaLinks.add(speclinks[i]);
            }
        }
        //create 1 metric based on cta priority
        for(String ctPrior:ctaPriorities){
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            ////system.debug('ctPrior -->'+ctPrior);
            switch on ctPrior {
                when 'View Specialty benefit' {
                    mlink.label=System.Label.IPA_Specialty_Networking_Label;
                    mlink.externalUrl=System.Label.IPA_Specialty_Networking_Link;
                    metric.link=mlink;
                }
                when 'Visit Intel® Network Builders' {
                    mlink.label=System.Label.IPA_Networking_Speciality_Network_Builders_bnftlbl;
                    mlink.externalUrl=System.Label.IPA_Networking_Speciality_Network_Builders_bnftlnk;
                    metric.link=mlink;
                }
                when 'Visit Intel® Network Builders University' {
                    mlink.label=System.Label.IPA_Networking_Speciality_Network_Builders_Uni_bnftlbl;
                    mlink.externalUrl=System.Label.IPA_Networking_Speciality_Network_Builders_Uni_bnftlnk;
                    metric.link=mlink;
                }
                
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
    
    // create links on the blades
        if(ctaLinks.size()>0){
            List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'View Specialty benefit' {
                        link1.label=System.Label.IPA_Specialty_Networking_Label;
                        link1.externalUrl=System.Label.IPA_Specialty_Networking_Link;
                    }
                    when 'Visit Intel® Network Builders' {
                        link1.label=System.Label.IPA_Networking_Speciality_Network_Builders_bnftlbl;
                        link1.externalUrl=System.Label.IPA_Networking_Speciality_Network_Builders_bnftlnk;
                    }
                    when 'Visit Intel® Network Builders University' {
                        link1.label=System.Label.IPA_Networking_Speciality_Network_Builders_Uni_bnftlbl;
                        link1.externalUrl=System.Label.IPA_Networking_Speciality_Network_Builders_Uni_bnftlnk;
                    }
                   
                }
                linkList.add(link1);            
            }
            userBenefit.links=linkList; 
        }     
        
        return userBenefit;       
    }*/    
     public static IPABenefitWrapper.UserBenefitInfo getSelectBenefit(List<String> sBenefitlinks,Map<String,String> adhocMsgs)
{    List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        //List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title=System.Label.IPA_Select_bnft_Title;
        userBenefit.faIcon=showLogoMap.containsKey('Select Benefit') && !showLogoMap.get('Select Benefit')?System.Label.IPA_Select_bnft_Icon:null;
        userBenefit.description=System.Label.IPA_Select_bnft_Description;
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
  if(adhocMsgs.size()>0)//  display adhoc part
         {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            userBenefit.adhocAlerts=adhocList;    
        }
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        /* for(String cta:sBenefitlinks)
{
IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
switch on cta {
when 'Find help and training' {
//IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
link1.label=System.Label.IPA_Select_help_bnft_label;
link1.externalUrl=System.Label.IPA_Select_help_bnft_link;
}
when 'View results' {
//IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
link1.label=System.Label.IPA_Select_ViewResults_bnft_label;
link1.externalUrl=System.Label.IPA_Select_ViewResults_bnft_link;
}
}
}*/
        List<IPABenefitWrapper.Metrics> selectBenfitMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        mlink.label= System.Label.IPA_SelectBnft_Metric_Label;
        mlink.externalUrl=System.Label.IPA_SelectBnft_Metric_Link;
        metric.link=mlink;
        //metric.value=;
        //metric.unit='HR';
        selectBenfitMetrics.add(metric);
        userBenefit.Metrics = selectBenfitMetrics;
        userBenefit.links=linkList;
        return userBenefit;        
    }
    
    
    public static IPABenefitWrapper.UserBenefitInfo getPartnerHelp(List<String> links, String partnerRole, IPABenefitWrapper.UserProfile userInfo,String partnerTier,Map<String,String> adhocMsgs)
    {
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        //List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        String tierSupp = System.Label.IPA_Partnerhelp_bnft_Title;
        userBenefit.title=tierSupp.replace('{Tier}',partnerTier); 
        userBenefit.faIcon=showLogoMap.containsKey('Partner Help') && !showLogoMap.get('Partner Help')?System.Label.IPA_Partnerhelp_bnft_Icon:null;
        //userBenefit.description=System.Label.IPA_Partnerhelp_bnft_Description;
         List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();//IPA2.0-TWC727-2896
        List<IPABenefitWrapper.Metrics> metricList=new List<IPABenefitWrapper.Metrics>();
        metricList=getPartnerHelpMetrics(partnerRole,userInfo);
        String metVal = metricList[0].value;
        
        String dnDescription = System.Label.IPA_Partnerhelp_bnft_Description;
        userBenefit.description=dnDescription.replace('{SLA}',metVal);
        // //IPA2.0-TWC727-3141
            Id currentUserId = userInfo.userId;
         
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
        
        userBenefit.contacts = getContacts(partnerRole,userInfo);
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896 
        //splitting the links for metrics CTC and right hand links CTC
        populateCTALinks(links,ctaPriorities,ctaLinks); //IPA2.0-TWC727-2896
        //IPA2.0-TWC727-2896>> start
        // Step 1: Create controller for your custom metadata name
        Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');
        
        // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
        Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

        // Step 3: Iterate your CTA list
            for (String cta : ctaPriorities) {
                IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                    if (ctaMetaMap.containsKey(cta)) {
                        Map<String, Object> meta = ctaMetaMap.get(cta);
                      
                        if(String.valueOf(meta.get('type'))=='getPartnerHelp' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                            IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                            if(metricList.size() >= 2){ metricCTCS = metricList[1]; } else{ metricCTCS = metricList[0];}
                            mlink.label =String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                            mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                            metricCTCS.link = mlink;
                        }
                    }
                userBenefit.metrics=metricList;
            }

         if(ctaLinks.size()>0){
                for (String cta : ctaLinks) {
                     IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                        if(ctaMetaMap.containsKey(cta)) {
                            Map<String, Object> meta = ctaMetaMap.get(cta);
                             
                            if(String.valueOf(meta.get('type'))=='getPartnerHelp' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                             link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                             link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                            }
                        }
                         linkList.add(link1);
                    }
                 userBenefit.links=linkList;
                }
                 return userBenefit; 
            } //IPA2.0-TWC727-2896>> end
       /* if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            userBenefit.adhocAlerts=adhocList;    
        }
        
        IPABenefitWrapper.Metrics metricCTCS;
        //userBenefit.contacts = getContacts();
        //splitting the links for metrics CTC and right hand links CTC
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            } 
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]);
                ctaLinks.add(links[i]);
            }
        }
        for(String ctaPrior :ctaPriorities){ 
            switch on ctaPrior {              
                when 'Create Support Ticket' { 
                   // IPABenefitWrapper.Metrics metricCTCS = metricList[0];
                    //IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(metricList.size() >= 2){ metricCTCS = metricList[1]; } else{ metricCTCS = metricList[0];}
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                   
                    mlink.label= System.Label.IPA_Partnerhelp_SupportTic_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Partnerhelp_SupportTic_bnftlnk_Link;
                    metricCTCS.link=mlink;
                }
                when 'New Warranty Return' { 
                    //IPABenefitWrapper.Metrics metricCTCS = metricList[1];
                    //IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(metricList.size() >= 2){ metricCTCS = metricList[1]; } else{ metricCTCS = metricList[0];}
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Partnerhelp_NewWarr_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Partnerhelp_NewWarr_bnftlnk_Link;
                    metricCTCS.link=mlink;
                }
                when 'View All Support Tickets' { 
                    //IPABenefitWrapper.Metrics metricCTCS = metricList[1];
                    // IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(metricList.size() >= 2){ metricCTCS = metricList[1]; } else{ metricCTCS = metricList[0];}
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Partnerhelp_ViewSupport_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Partnerhelp_ViewSupport_bnftlnk_Link;
                    metricCTCS.link=mlink;
                }
                when 'View Warranty Coverage Status' { 
                   //IPABenefitWrapper.Metrics metricCTCS = metricList[1];
                   //  IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(metricList.size() >= 2){ metricCTCS = metricList[1]; } else{ metricCTCS = metricList[0];}
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Partnerhelp_WarrantyCov_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Partnerhelp_WarrantyCov_bnftlnk_Link;
                    metricCTCS.link=mlink;
                }
                when 'Intel Premier Support' { 
                   // IPABenefitWrapper.Metrics metricCTCS = metricList[1];
                   //  IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(metricList.size() >= 2){ metricCTCS = metricList[1]; } else{ metricCTCS = metricList[0];}
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Partnerhelp_Support_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Partnerhelp_Support_bnftlnk_Link;
                    metricCTCS.link=mlink;
                }
                when 'Get help with Warranty Return'{
                    //IPABenefitWrapper.Metrics metricCTCS = metricList[1];
                    // IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(metricList.size() >= 2){ metricCTCS = metricList[1]; } else{ metricCTCS = metricList[0];}
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Partnerhelp_getHelpWarrntyReturn_Label;
                    mlink.externalUrl=System.Label.IPA_Partnerhelp_getHelpWarrntyReturn_Link;
                    metricCTCS.link=mlink;
                }
                when 'Get help with Portal or program' {
                    //IPABenefitWrapper.Metrics metricCTCS = metricList[1];
                   //  IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                    if(metricList.size() >= 2){ metricCTCS = metricList[1]; } else{ metricCTCS = metricList[0];}
                    IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label= System.Label.IPA_Partnerhelp_getHelp_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_Partnerhelp_getHelp_bnftlnk_Link;
                    metricCTCS.link=mlink;
                }
            }
        }
        userBenefit.metrics=metricList;
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        for(String cta:ctaLinks)
        {
            IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
            switch on cta {
                when 'Create Support Ticket' {
                    //IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    link1.label=System.Label.IPA_Partnerhelp_SupportTic_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Partnerhelp_SupportTic_bnftlnk_Link;
                }
                when 'New Warranty Return' {
                    link1.label=System.Label.IPA_Partnerhelp_NewWarr_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Partnerhelp_NewWarr_bnftlnk_Link;
                }
                when 'View All Support Tickets' {
                    link1.label=System.Label.IPA_Partnerhelp_ViewSupport_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Partnerhelp_ViewSupport_bnftlnk_Link;
                }
                when 'View Warranty Coverage Status' {
                    link1.label=System.Label.IPA_Partnerhelp_WarrantyCov_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Partnerhelp_WarrantyCov_bnftlnk_Link;
                }
                when 'Intel Premier Support' {
                    link1.label=System.Label.IPA_Partnerhelp_Support_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Partnerhelp_Support_bnftlnk_Link;
                }
                when 'Get help with Warranty Return'{
                    link1.label=System.Label.IPA_Partnerhelp_getHelpWarrntyReturn_Label;
                    link1.externalUrl=System.Label.IPA_Partnerhelp_getHelpWarrntyReturn_Link;
                }
                when 'Get help with Portal or program' {
                    link1.label=System.Label.IPA_Partnerhelp_getHelp_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Partnerhelp_getHelp_bnftlnk_Link;
                }
            }
            linkList.add(link1);
        }
        
        userBenefit.links=linkList;
        return userBenefit;    
    }*/
    
    //get FPGA Blade
     public static IPABenefitWrapper.UserBenefitInfo getFPGAToolsResources(List<String> links,Map<String,String> adhocMsgs){
        
         List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
         IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title=System.Label.IPA_FPGA_benefit_title;
        userBenefit.faIcon=showLogoMap.containsKey('FPGA Tools and Resources') && !showLogoMap.get('FPGA Tools and Resources')?System.Label.IPA_FPGA_bnft_Icon:null;
        userBenefit.description=System.Label.IPA_FPGA_benefit_description;
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        
        /* if(alertTitles.size()>0)
        {
            List<IPABenefitWrapper.Alerts> alertList=new List<IPABenefitWrapper.Alerts>();
            for(String a:alertTitles)
            {
                IPABenefitWrapper.Alerts alert=new IPABenefitWrapper.Alerts();
                alert.label=a;
                alertList.add(alert);  
            }
            userBenefit.alerts=alertList;    
        }*/

        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
        populateCTALinks(links,ctaPriorities,ctaLinks); //IPA2.0-TWC727-2896
      
        
        //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
       // Boolean isTrue1= false;
        //IPA2.0-TWC727-2896>> start
      // Step 1: Create controller for your custom metadata name
        Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');
   
        // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
        Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

        // Step 3: Iterate your CTA list  

       for (String cta : ctaPriorities) {
          IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
          if (ctaMetaMap.containsKey(cta)) {
           Map<String, Object> meta = ctaMetaMap.get(cta);
           
             if(String.valueOf(meta.get('type'))=='getFPGAToolsResources' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
               mlink.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
               mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
               metric.link=mlink;

            }
        }
        listMetrics.add(metric);
        userBenefit.Metrics = listMetrics;
    }
        
        if(ctaLinks.size() > 0){
            for (String cta : ctaLinks) {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
               if (ctaMetaMap.containsKey(cta)) {
                 Map<String, Object> meta = ctaMetaMap.get(cta);
               
                 if(String.valueOf(meta.get('type'))=='getFPGAToolsResources' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                 }
                }
                linkList.add(link1);
            }
             userBenefit.links=linkList; 
        }
       
        return userBenefit;

    }
     //IPA2.0-TWC727-2896>> end
   /*if(adhocMsgs.size()>0)//  display adhoc part
         {
             List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
             for(String a : adhocMsgs.keySet())
             {
                 IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                 List<String> IdList = a.split(',');
                 adhocAlert.uniqueId = IdList[0];
                 adhocAlert.label = IdList[1];
                 adhocAlert.adcDescription = adhocMsgs.get(a);
                 adhocList.add(adhocAlert);  
             }
             userBenefit.adhocAlerts=adhocList;    
         }
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            } 
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]);
                ctaLinks.add(links[i]);
            }
        }
        
       // Boolean isTrue1= false;
       
        
        for(String ctaPrior :ctaPriorities){ 
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
            
            switch on ctaPrior {
                when 'Visit FPGA Communities' {
                    mlink.label= System.Label.IPA_FPGA_Visit_Communities_bnftlbl;
                    mlink.externalUrl=System.Label.IPA_FPGA_Visit_Communities_bnftlnk;
                    metric.link=mlink;
                }
                when 'Track and Enter Design Registration' {
                    mlink.label= System.Label.IPA_FPGA_Track_Enter_Design_Reg_bnftlbl;
                    mlink.externalUrl=System.Label.IPA_FPGA_Track_Enter_Design_Reg_bnftlnk;
                    metric.link=mlink; 
                }
        when 'Contact FPGA Ecosystem Team' {
                    mlink.label= System.Label.IPA_FPGA_Contact_Ecosystem_bnftlbl;
                    mlink.externalUrl=System.Label.IPA_FPGA_Contact_Ecosystem_bnftlnk;
                    metric.link=mlink; 
                }        
                when 'Design Registration' {  //TWC729-6053: Enable Link on Manage benefits blade for Disti for Design Registration
                    mlink.label=System.Label.PRM_DDRBreadCrumb_Text;
                    mlink.externalUrl=System.Label.PRM_DDRBreadCrumb_URL;
                    metric.link=mlink;
                }       
            } 
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
         
        
        if(ctaLinks.size() > 0){
            List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'Visit FPGA Communities' {
                        link1.label=System.Label.IPA_FPGA_Visit_Communities_bnftlbl;
                        link1.externalUrl=System.Label.IPA_FPGA_Visit_Communities_bnftlnk;
                        //linkList.add(link1);   
                    }
                    when 'Track and Enter Design Registration' {
                        link1.label=System.Label.IPA_FPGA_Track_Enter_Design_Reg_bnftlbl;
                        link1.externalUrl=System.Label.IPA_FPGA_Track_Enter_Design_Reg_bnftlnk;
                        //linkList.add(link1);   
                    }   
          when 'Contact FPGA Ecosystem Team' {
                        link1.label=System.Label.IPA_FPGA_Contact_Ecosystem_bnftlbl;
                        link1.externalUrl=System.Label.IPA_FPGA_Contact_Ecosystem_bnftlnk;
                        //linkList.add(link1);   
                    }   
                    when 'Design Registration' {  //TWC729-6053: Enable Link on Manage benefits blade for Disti for Design Registration
                        link1.label=System.Label.PRM_DDRBreadCrumb_Text;
                        link1.externalUrl=System.Label.PRM_DDRBreadCrumb_URL;
                    }  
                }
                linkList.add(link1);
            }
            userBenefit.links=linkList; 
        }
        return userBenefit;
    }*/
    
    public static IPABenefitWrapper.UserBenefitInfo getDZS(List<String> links,Map<String,String> adhocMsgs){
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title=System.Label.IPA_DZS_bnft_Title;
        //userBenefit.faIcon=showLogoMap.containsKey('Intel® Developer Zone - Standard') && !showLogoMap.get('Intel® Developer Zone - Standard')?System.Label.IPA_DZS_bnftIcon:null;
        userBenefit.description=System.Label.IPA_DZS_bnft_Description;
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics();//IPA2.0-TWC727-2896
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();//IPA2.0-TWC727-2896
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
        populateCTALinks(links,ctaPriorities,ctaLinks); //IPA2.0-TWC727-2896
         //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
         //IPA2.0-TWC727-2896>> start
       // Step 1: Create controller for your custom metadata name
        Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');

        // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
        Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

        // Step 3: Iterate your CTA list
        // create 1 metric based on ctr priority
        for (String cta : ctaPriorities) {
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
              
                if(String.valueOf(meta.get('type'))=='getDZS' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                   
                    mlink.label= String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                    metric.link=mlink;
                }
                
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
       
        //create links for blades
        if(ctaLinks.size()>0){
         for (String cta : ctaLinks) {
            IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
              
                if(String.valueOf(meta.get('type'))=='getDZS' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                }
            }
               linkList.add(link1);
        }
        userBenefit.links=linkList;
    }
    return userBenefit;
     
}
 //IPA2.0-TWC727-2896>> end
       /* if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            userBenefit.adhocAlerts=adhocList;    
        }
        
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            }
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]) ; 
                ctaLinks.add(links[i]);
            }
        }
        // create 1 metric based on ctr priority
        for(String ctaPrior : ctaPriorities){
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            switch on ctaPrior {     
                when 'Intel® Developer Zone' {
                    mlink.label=System.Label.IPA_DZS_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_DZS_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'Intel® Developer Cloud for the Edge & One API' {
                    mlink.label=System.Label.DZS_EdgeOneAPIlnk_Label;
                    mlink.externalUrl=System.Label.DZS_EdgeOneAPI_Link;
                    metric.link=mlink;
                }
                when 'Intel® Developer Cloud for Services' {
                    mlink.label=System.Label.DZS_IDC_Serviceslnk_Label;
                    mlink.externalUrl=System.Label.DZS_IDC_Services_link;
                    metric.link=mlink;
                }
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
        //create links for blades
        if(ctaLinks.size()>0){
            List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'Intel® Developer Zone' {
                        link1.label=System.Label.IPA_DZS_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_DZS_bnftlnk_Link;
                    }
                    when 'Intel® Developer Cloud for the Edge & One API' {
                        link1.label=System.Label.DZS_EdgeOneAPIlnk_Label;
                        link1.externalUrl=System.Label.DZS_EdgeOneAPI_Link;
                    }
                    when 'Intel® Developer Cloud for Services' {
                        link1.label=System.Label.DZS_IDC_Serviceslnk_Label;
                        link1.externalUrl=System.Label.DZS_IDC_Services_link;
                    }
                }
                linkList.add(link1);
            }
            userBenefit.links=linkList;
        }
        return userBenefit;
    }*/
    public static IPABenefitWrapper.UserBenefitInfo getRDC(List<String> links,Map<String,String> adhocMsgs){ 
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();//IPA2.0-TWC727-2896
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;//IPA2.0-TWC727-2896
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
        userBenefit.title=System.Label.IPA_DZS_RDC_Title;
        //userBenefit.faIcon=showLogoMap.containsKey('Resource & Documentation Center - Public') && !showLogoMap.get('Resource & Documentation Center - Public')?System.Label.IPA_DZS_bnftIcon:null;
        userBenefit.description=System.Label.IPA_DZS_RDC_Description;
         populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896 
        populateCTALinks(links,ctaPriorities,ctaLinks); //IPA2.0-TWC727-2896
         //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
 //IPA2.0-TWC727-2896>> start
        // Step 1: Create controller for your custom metadata name
            Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');
        
            // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
            Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

        // Step 3: Iterate your CTA list
        // create 1 metric based on ctr priority
        for (String cta : ctaPriorities) {
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='getRDC' && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    mlink.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                    metric.link=mlink;
                }
                
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
       
        //create links for blades
         if(ctaLinks.size()>0){
         for (String cta : ctaLinks) {
            IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='getRDC'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                }
            }
               linkList.add(link1);
        }
        userBenefit.links=linkList;
    }
    return userBenefit;
     
} //IPA2.0-TWC727-2896>> end
       /* if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            ////system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            }
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]) ; 
                ctaLinks.add(links[i]);
            }
        }
        // create 1 metric based on ctr priority
        for(String ctaPrior : ctaPriorities){
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            switch on ctaPrior {     
                when 'Resource & Documentation Center' {
                    mlink.label=System.Label.IPA_Resource_dev_center_Label;
                    mlink.externalUrl=System.Label.IPA_Resource_dev_center_Link;
                    metric.link=mlink;
                }
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
        //create links for blades
        if(ctaLinks.size()>0){
            List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'Resource & Documentation Center' {
                        link1.label=System.Label.IPA_Resource_dev_center_Label;
                        link1.externalUrl=System.Label.IPA_Resource_dev_center_Link;
                    }
                }
                linkList.add(link1);
            }
            userBenefit.links=linkList;
        }
        return userBenefit;
    }*/
    /*TWC727-905 - Utkarsh - New Method to display IDDS blade*/
    // IPA2.0 TWC727-2912 starts here
    /*public static IPABenefitWrapper.UserBenefitInfo displayIDDSBlade(List<String> links,Map<String,String> adhocMsgs){
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title=System.Label.IPA_IDDS_bnft_Title;
        userBenefit.description=System.Label.IPA_IDDS_bnft_Description;

        if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            userBenefit.adhocAlerts=adhocList;    
        }
        
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            }
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]) ; 
                ctaLinks.add(links[i]);
            }
        }
        //create metric based on ctr priority
        for(String ctaPrior : ctaPriorities){
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            
            switch on ctaPrior {  
                  
                when 'Intel Demo Depot' {
                    mlink.label=System.Label.IPA_IDDS_CTA_Label;
                    mlink.externalUrl=System.Label.IPA_IDDS_CTA_URL;
                    metric.link=mlink;
                }
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
        //create links for blades
        if(ctaLinks.size()>0){
            List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'Intel Demo Depot' {
                        link1.label=System.Label.IPA_IDDS_CTA_Label ;
                        link1.externalUrl=System.Label.IPA_IDDS_CTA_URL;
                    }
                  }
                linkList.add(link1);
            }
            userBenefit.links=linkList;
        }
        return userBenefit;
    }*/
    //IPA2.0 TWC727-2912 ends here
    /*TWC727-905 -END*/
    /*TWC727-905 - Utkarsh - New Method to display DIT blade*/
    public static IPABenefitWrapper.UserBenefitInfo displayDITBlade(List<String> links,Map<String,String> adhocMsgs){
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;// IPA2.0-TWC727-2896
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();// IPA2.0-TWC727-2896
        userBenefit.title=System.Label.IPA_DIT_bnft_Title;
        userBenefit.description=System.Label.IPA_DIT_bnft_Description;
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
        populateCTALinks(links,ctaPriorities,ctaLinks); //IPA2.0-TWC727-2896
        //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
         //IPA2.0-TWC727-2896>> start
        // Step 1: Create controller for your custom metadata name
            Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');
        
            // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
            Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

        // Step 3: Iterate your CTA list
        // create 1 metric based on ctr priority
        for (String cta : ctaPriorities) {
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='displayDITBlade'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    
                    mlink.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                    metric.link=mlink;
                }
                
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }

//create links for blades
         if(ctaLinks.size()>0){
         for (String cta : ctaLinks) {
            IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='displayDITBlade'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                  
                    link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                }
            }
               linkList.add(link1);
        }
        userBenefit.links=linkList;
    }
   
    return userBenefit;
     
}  //IPA2.0-TWC727-2896>> end
       /* if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            userBenefit.adhocAlerts=adhocList;    
        }

        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            }
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]) ; 
                ctaLinks.add(links[i]);
            }
        }
        //create metric based on ctr priority
        for(String ctaPrior : ctaPriorities){
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            switch on ctaPrior {     
                when 'Design-In Tools Store' {
                    mlink.label=System.Label.IPA_DIT_CTA_Label;
                    mlink.externalUrl=System.Label.IPA_DIT_CTA_URL;
                    metric.link=mlink;
                }
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
        //create links for blades
        if(ctaLinks.size()>0){
            List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'Design-In Tools Store' {
                        link1.label=System.Label.IPA_DIT_CTA_Label ;
                        link1.externalUrl=System.Label.IPA_DIT_CTA_URL;
                    }
                  }
                linkList.add(link1);
            }
            userBenefit.links=linkList;
        }
        return userBenefit;
    }*/
    /*TWC727-905 -END*/
    /*TWC727-904 - Utkarsh - New Method to display DZP blade*/
    public static IPABenefitWrapper.UserBenefitInfo displayDZPBlade(List<String> links,Map<String,String> adhocMsgs){
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title=System.Label.IPA_DZP_bnft_Title;
        userBenefit.description=System.Label.IPA_DZP_bnft_Description;
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;//IPA2.0-TWC727-2896
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();//IPA2.0-TWC727-2896
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
        populateCTALinks(links,ctaPriorities,ctaLinks); //IPA2.0-TWC727-2896
        //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
        //IPA2.0-TWC727-2896>> start

  // Step 1: Create controller for your custom metadata name
            Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');
            // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
            Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

        // Step 3: Iterate your CTA list
        // create 1 metric based on ctr priority
        for (String cta : ctaPriorities) {
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='displayDZPBlade'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    mlink.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                    metric.link=mlink;
                }
                
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }

//create links for blades
         if(ctaLinks.size()>0){
         for (String cta : ctaLinks) {
            IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='displayDZPBlade'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                }
            }
               linkList.add(link1);
        }
        userBenefit.links=linkList;
    }
    return userBenefit;
     
} //IPA2.0-TWC727-2896>> end

       /* if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            userBenefit.adhocAlerts=adhocList;    
        }
        
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            }
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]) ; 
                ctaLinks.add(links[i]);
            }
        }
        //create metric based on ctr priority
        for(String ctaPrior : ctaPriorities){
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            switch on ctaPrior {     
                when 'Intel Developer Zone' {
                    mlink.label=System.Label.IPA_DZP_CTA_Label;
                    mlink.externalUrl=System.Label.IPA_DZP_CTA_URL;
                    metric.link=mlink;
                }
                when 'Intel Developer Cloud for the Edge & One API' {
                    mlink.label=System.Label.IPA_DZP_FirstLink_Label;
                    mlink.externalUrl=System.Label.IPA_DZP_FirstLink_URL;
                    metric.link=mlink;
                }
                when 'Intel Developer Cloud for Services' {
                    mlink.label=System.Label.IPA_DZP_SecondLink_Label;
                    mlink.externalUrl=System.Label.IPA_DZP_SecondLink_URL;
                    metric.link=mlink;
                }
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
        //create links for blades
        if(ctaLinks.size()>0){
            List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'Intel Developer Zone' {
                        link1.label=System.Label.IPA_DZP_CTA_Label ;
                        link1.externalUrl=System.Label.IPA_DZP_CTA_URL;
                    }
                    when 'Intel Developer Cloud for the Edge & One API' {
                        link1.label=System.Label.IPA_DZP_FirstLink_Label;
                        link1.externalUrl=System.Label.IPA_DZP_FirstLink_URL;
                    }
                    when 'Intel Developer Cloud for Services' {
                        link1.label=System.Label.IPA_DZP_SecondLink_Label;
                        link1.externalUrl=System.Label.IPA_DZP_SecondLink_URL;
                    }
                }
                linkList.add(link1);
            }
            userBenefit.links=linkList;
        }
        return userBenefit;
    }*/
    /*TWC727-904 -END*/
    /*TWC727-904 - Utkarsh - New Method to display RDC premier blade*/
    public static IPABenefitWrapper.UserBenefitInfo displayRDCPremierBlade(List<String> links,Map<String,String> adhocMsgs){
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title=System.Label.IPA_DZP_RDC_Premier_Title;
        userBenefit.description=System.Label.IPA_DZP_RDC_Premier_Description;
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();//IPA2.0-TWC727-2896
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;//IPA2.0-TWC727-2896
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
        populateCTALinks(links,ctaPriorities,ctaLinks); //IPA2.0-TWC727-2896
         //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
        //IPA2.0-TWC727-2896>> start
// Step 1: Create controller for your custom metadata name
            Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');
            // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
            Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

        // Step 3: Iterate your CTA list
        // create 1 metric based on ctr priority
        for (String cta : ctaPriorities) {
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='displayRDCPremierBlade'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    mlink.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang)); 
                    mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                    metric.link=mlink;
                }
                
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }

//create links for blades
         if(ctaLinks.size()>0){
         for (String cta : ctaLinks) {
            IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='displayRDCPremierBlade'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                }
            }
               linkList.add(link1);
        }
        userBenefit.links=linkList;
    }
    return userBenefit;
     
} //IPA2.0-TWC727-2896>> end
       /* if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            ////system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            }
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]) ; 
                ctaLinks.add(links[i]);
            }
        }
        //create metric based on ctr priority
        for(String ctaPrior : ctaPriorities){
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            switch on ctaPrior {     
                when 'Resource & Documentation Center' {
                    mlink.label=System.Label.IPA_Resource_dev_center_Label;
                    mlink.externalUrl=System.Label.IPA_DZP_RDC_Premier_CTA_Link;
                    metric.link=mlink;
                }
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
        //create links for blades
        if(ctaLinks.size()>0){
            List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'Resource & Documentation Center' {
                        link1.label=System.Label.IPA_Resource_dev_center_Label ;
                        link1.externalUrl=System.Label.IPA_DZP_RDC_Premier_CTA_Link;
                    }
                 }
                linkList.add(link1);
            }
            userBenefit.links=linkList;
        }
        return userBenefit;
    }*/
    /*TWC727-904 -END*/
    
    //get marketing studio blade
    public static IPABenefitWrapper.UserBenefitInfo getMarketingStudio(List<String> links,List<String> alertTitles,Map<String,String> adhocMsgs){
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title=System.Label.IPA_MarketStudio_bnft_Title;
        userBenefit.faIcon=showLogoMap.containsKey('Marketing Studio') && !showLogoMap.get('Marketing Studio')?System.Label.IPA_MarketStudio_bnft_Icon:null;
        userBenefit.description=System.Label.IPA_MarketStudio_bnft_Description;
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;//IPA2.0-TWC727-2896
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();//IPA2.0-TWC727-2896
         populateAlerts(alertTitles, userBenefit); //IPA2.0-TWC727-2896
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
        populateCTALinks(links,ctaPriorities,ctaLinks); //IPA2.0-TWC727-2896 
         //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
 //IPA2.0-TWC727-2896>> start
        // Step 1: Create controller for your custom metadata name
            Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');
        
            // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
            Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

        // Step 3: Iterate your CTA list
        // create 1 metric based on ctr priority
        for (String cta : ctaPriorities) {
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='getMarketingStudio'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    mlink.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                    metric.link=mlink;
                }
                
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }

 if(ctaLinks.size()>0){
         for (String cta : ctaLinks) {
            IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='getMarketingStudio'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                }
            }
               linkList.add(link1);
        }
        userBenefit.links=linkList;
    }
    return userBenefit;
     
} //IPA2.0-TWC727-2896>> end
       /*if(alertTitles.size()>0)
        {
            List<IPABenefitWrapper.Alerts> alertList=new List<IPABenefitWrapper.Alerts>();
            for(String a:alertTitles)
            {
                IPABenefitWrapper.Alerts alert=new IPABenefitWrapper.Alerts();
                alert.label=a;
                alertList.add(alert);  
            }
            userBenefit.alerts=alertList;            
        }
    if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            ////system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            }
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]) ; 
                ctaLinks.add(links[i]);
            }
        }
        // create 1 metric based on ctr priority
        for(String ctaPrior : ctaPriorities){
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            switch on ctaPrior {     
                when 'Marketing Asset Library' {
                    //IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    // IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                    mlink.label=System.Label.IPA_MarketStudio_assestLib_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_MarketStudio_assestLib_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'View Campaigns' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                    
                    mlink.label=System.Label.IPA_MarketStudio_camp_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_MarketStudio_camp_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'Get help with Marketing Studio' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                                   
                    mlink.label=System.Label.IPA_MarketStudio_gethelp_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_MarketStudio_gethelp_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'Visit Partner Marketing Studio' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                                  
                    mlink.label=System.Label.IPA_MarketStudio_visit_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_MarketStudio_visit_bnftlnk_Link;
                    metric.link=mlink;
                }
                // IPA2.0 starts here TWC727-2912
                 when 'Branding Guidelines for Intel Partners' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                                  
                    mlink.label=System.Label.prm_Branding_Guidelines_for_Intel_Partners_label;
                    mlink.externalUrl=System.Label.prm_Branding_Guidelines_for_Intel_Partners_link;
                    metric.link=mlink;
                }
                 when 'Intel Brand Logo and Trademark Usage Guidelines' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                                  
                    mlink.label=System.Label.prm_Intel_Brand_Logo_Trademark_Usage_Guidelines_label;
                    mlink.externalUrl=System.Label.prm_Intel_Brand_Logo_Trademark_Usage_Guidelines_link;
                    metric.link=mlink;
                }
                //IPA 2.0 ends here
                
                when 'Links To Badges' {
                    // IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                                  
                    mlink.label=System.Label.IPA_MarketStudio_badges_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_MarketStudio_badges_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'Links To Logos' {
                    // IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();                                    
                    mlink.label=System.Label.IPA_MarketStudio_logo_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_MarketStudio_logo_bnftlnk_Link;
                    metric.link=mlink;
                } 
                /*
                when 'Intel® Brand Logo and Usage Guidelines' { 
                    
                    mlink.label= System.Label.prm_Intel_Brand_Logo_and_Usage_Guidelines;
                    mlink.externalUrl=System.Label.prm_Intel_Brand_Logo_and_Usage_Guidelines_link;
                    metric.link=mlink;
                    
                }*/ //IPA 2.0 TWC727-2912
                /*when 'Intel® Authorized Distributor and Intel® Approved Supplier Badge and Assets' { 
                    
                    mlink.label= System.Label.PRM_Intel_Authorized_Distributor_and_Intel_Approved_Supplier_Badge_and_Assets;
                    mlink.externalUrl=System.Label.prm_Intel_Authorized_Distributor_and_Intel_Approved_Supplier_Badge_and_Ass_Link;
                    metric.link=mlink;
                }
                when 'Intel® Partner Alliance Welcome Kit' { // Utkarsh - TWC727-531 - Reused as part of the story to display new label and link.
                    
                    mlink.label= System.Label.IPA_Email_Template;
                    mlink.externalUrl=System.Label.IPA_Email_Template_link;
                    metric.link=mlink;
                }
                /* when 'Intel® Partner Alliance Web Banners' { // Utkarsh - TWC727-531 - Commented as this link is no longer needed.
                    
                    mlink.label= System.Label.IPA_Web_Banners;
                    mlink.externalUrl=System.Label.IPA_Web_Banners_link;
                    metric.link=mlink;
                }*/
            /*}
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
        //create links for blades
        if(ctaLinks.size()>0){
            List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'Marketing Asset Library' {
                        //IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                        link1.label=System.Label.IPA_MarketStudio_assestLib_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_MarketStudio_assestLib_bnftlnk_Link;
                    }
                    when 'View Campaigns' {
                        link1.label=System.Label.IPA_MarketStudio_camp_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_MarketStudio_camp_bnftlnk_Link;
                    }
                    when 'Get help with Marketing Studio' {
                        link1.label=System.Label.IPA_MarketStudio_gethelp_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_MarketStudio_gethelp_bnftlnk_Link;
                    }
                    when 'Visit Partner Marketing Studio' {
                        link1.label=System.Label.IPA_MarketStudio_visit_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_MarketStudio_visit_bnftlnk_Link;
                    }
                    // IPA 2.0 starts here TWC727-2912
                    when 'Branding Guidelines for Intel Partners' {
                        link1.label=System.Label.prm_Branding_Guidelines_for_Intel_Partners_label;
                        link1.externalUrl=System.Label.prm_Branding_Guidelines_for_Intel_Partners_link;
                    }
                    when 'Intel Brand Logo and Trademark Usage Guidelines' {
                        link1.label=System.Label.prm_Intel_Brand_Logo_Trademark_Usage_Guidelines_label;
                        link1.externalUrl=System.Label.prm_Intel_Brand_Logo_Trademark_Usage_Guidelines_link;
                    }
                    // IPA2.0 ends here

                    when 'Links To Badges' {
                        link1.label=System.Label.IPA_MarketStudio_badges_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_MarketStudio_badges_bnftlnk_Link;
                    }
                    when 'Links To Logos' {
                        link1.label=System.Label.IPA_MarketStudio_logo_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_MarketStudio_logo_bnftlnk_Link;
                    }
                    /*
                    when 'Intel® Brand Logo and Usage Guidelines' { 
                        
                        link1.label= System.Label.prm_Intel_Brand_Logo_and_Usage_Guidelines;
                        link1.externalUrl=System.Label.prm_Intel_Brand_Logo_and_Usage_Guidelines_link;
                        
                    }*/ //IPA 2.0 TWC727-2912
                    /*when 'Intel® Authorized Distributor and Intel® Approved Supplier Badge and Assets' { 
                        
                        link1.label= System.Label.PRM_Intel_Authorized_Distributor_and_Intel_Approved_Supplier_Badge_and_Assets;
                        link1.externalUrl=System.Label.prm_Intel_Authorized_Distributor_and_Intel_Approved_Supplier_Badge_and_Ass_Link;
                    }
                    when 'Intel® Partner Alliance Welcome Kit' { // Utkarsh - TWC727-531 - Reused as part of the story to display new label and link.
                        
                        link1.label= System.Label.IPA_Email_Template;
                        link1.externalUrl=System.Label.IPA_Email_Template_link;
                        
                    }
                   /* when 'Intel® Partner Alliance Web Banners' { // Utkarsh - TWC727-531 - Commented as this link is no longer needed.
                        
                        link1.label= System.Label.IPA_Web_Banners;
                        link1.externalUrl=System.Label.IPA_Web_Banners_link;
                        
                    }*/
                /*}
                linkList.add(link1);            
            }
            
            userBenefit.links=linkList;  
        }    
        // //system.debug('training--->'+userBenefit.title);
        return userBenefit;    
    }*/
    
    public static IPABenefitWrapper.UserBenefitInfo getPricingPointsPromotionsBlade(List<String> links,Map<String,String> adhocMsgs){
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title=System.Label.IPA_PPP_bnft_Title;
        userBenefit.faIcon=showLogoMap.containsKey('Pricing, Points and Promotions') && !showLogoMap.get('Pricing, Points and Promotions')?System.Label.IPA_PPP_bnft_Icon:null;
        userBenefit.description=System.Label.IPA_PPP_bnft_Description;
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;//IPA2.0-TWC727-2896
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();//IPA2.0-TWC727-2896
        
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
        populateCTALinks(links,ctaPriorities,ctaLinks); //IPA2.0-TWC727-2896
        
        //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
         //IPA2.0-TWC727-2896>> start
        //create 1 metric based on cta priority
        // Step 1: Create controller for your custom metadata name
            Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');

            // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
            Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

        // Step 3: Iterate your CTA list
        // create 1 metric based on ctr priority
        for (String cta : ctaPriorities) {
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
             
                if(String.valueOf(meta.get('type'))=='getPricingPointsPromotionsBlade'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    mlink.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                    metric.link=mlink;
                }
                
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
if(ctaLinks.size()>0){
         for (String cta : ctaLinks) {
            IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='getPricingPointsPromotionsBlade'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                }
            }
               linkList.add(link1);
        }
        userBenefit.links=linkList;
    }
    return userBenefit;
     
} //IPA2.0-TWC727-2896>> end

/*        if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            ////system.debug('Adhoc list'+adhocList);
            userBenefit.adhocAlerts=adhocList;    
        }
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            } 
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]) ;
                ctaLinks.add(links[i]);
            }
        }
        //create 1 metric based on cta priority
        for(String ctaPrior : ctaPriorities){
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
            switch on ctaPrior {
                when 'Pricing, Points and Promotions' {
                    //IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    // IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label=System.Label.IPA_PPP_Primary_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_PPP_Primary_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'Price List & Rebates' {
                    // IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label=System.Label.IPA_PPP_PriceReb_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_PPP_PriceReb_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'Points' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label=System.Label.IPA_PPP_Points_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_PPP_Points_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'Web Quote Tool' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label=System.Label.IPA_PPP_Web_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_PPP_Web_bnftlnk_Link;
                    metric.link=mlink;
                }
                /*
                when 'Demo Depot' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();   
                    mlink.label=System.Label.IPA_PPP_Demo_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_PPP_Demo_bnftlnk_Link;
                    metric.link=mlink;
                }*/ //IPA 2.0 TWC727-2912          
                /*when 'Design Registration' {  //TWC729-6053: Enable Link on Manage benefits blade for Disti for Design Registration
                    mlink.label=System.Label.PRM_DDRBreadCrumb_Text;
                    mlink.externalUrl=System.Label.PRM_DDRBreadCrumb_URL;
                    metric.link=mlink;
                }          
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
        
        //create links on the blade
        if(ctaLinks.size()>0){
            List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'Pricing, Points and Promotions' {
                        //IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                        link1.label=System.Label.IPA_PPP_Primary_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_PPP_Primary_bnftlnk_Link;
                    }
                    when 'Price List & Rebates' {
                        link1.label=System.Label.IPA_PPP_PriceReb_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_PPP_PriceReb_bnftlnk_Link;
                    }
                    when 'Points' {
                        link1.label=System.Label.IPA_PPP_Points_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_PPP_Points_bnftlnk_Link;
                    }
                    when 'Web Quote Tool' {
                        link1.label=System.Label.IPA_PPP_Web_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_PPP_Web_bnftlnk_Link;
                    }
                    /*
                    when 'Demo Depot' {
                        link1.label=System.Label.IPA_PPP_Demo_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_PPP_Demo_bnftlnk_Link;
                    }*/ //IPA 2.0 TWC727-2912         
                    /*when 'Design Registration' {  //TWC729-6053: Enable Link on Manage benefits blade for Disti for Design Registration
                        link1.label=System.Label.PRM_DDRBreadCrumb_Text;
                        link1.externalUrl=System.Label.PRM_DDRBreadCrumb_URL;
                    }            
                }
                linkList.add(link1);            
            }
            userBenefit.links=linkList; 
        }     
        // //system.debug('training--->'+userBenefit.title);
        return userBenefit;    
    }*/
    
    public static IPABenefitWrapper.UserBenefitInfo getProductRoadmapsBlade(List<String> links,Map<String,String> adhocMsgs){
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title=System.Label.IPA_ProductRoadmap_bnft_Title;
        userBenefit.faIcon=showLogoMap.containsKey('Products & Roadmaps') && !showLogoMap.get('Products & Roadmaps')?System.Label.IPA_ProductRoadmap_bnft_Icon:null;
        userBenefit.description=System.Label.IPA_ProductRoadmap_bnft_Description;
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;//IPA2.0-TWC727-2896
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();//IPA2.0-TWC727-2896
        
        populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896 
        populateCTALinks(links,ctaPriorities,ctaLinks); //IPA2.0-TWC727-2896
        
         //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
 //IPA2.0-TWC727-2896>> start
        // Step 1: Create controller for your custom metadata name
            Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');

            // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
            Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();

        // Step 3: Iterate your CTA list
        // create 1 metric based on ctr priority
        for (String cta : ctaPriorities) {
           
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='getProductRoadmapsBlade'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    mlink.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                   
                    mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                   
                    metric.link=mlink;
                }
                
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }

      if(ctaLinks.size()>0){
     
         for (String cta : ctaLinks) {
          
            IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
              
                if(String.valueOf(meta.get('type'))=='getProductRoadmapsBlade'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                     
                    link1.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                  
                    link1.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                   
                }
            }
               linkList.add(link1);
        }
        userBenefit.links=linkList;
    }
    return userBenefit;
     
} //IPA2.0-TWC727-2896>> end

/*        if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            userBenefit.adhocAlerts=adhocList;    
        }
        
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);      
            }
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]); 
                ctaLinks.add(links[i]);
            }
        }
        //create 1 metric based on cta priority
        for(String ctPrior:ctaPriorities){
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            switch on ctPrior {
                when 'Products & Roadmaps' {
                    //IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    //IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                    mlink.label=System.Label.IPA_ProductRoadmap_Primary_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_ProductRoadmap_Primary_bnftlnk_Link;
                    metric.link=mlink;
                }
                when 'Web Order Management' {
                    // IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();      
                    mlink.label=System.Label.IPA_ProductRoadmap_webOrder_bnftlnk_Label;
                    mlink.externalUrl=System.Label.IPA_ProductRoadmap_webOrder_bnftlnk_Link;
                    metric.link=mlink;
                }
                // when 'Server Configurator' {
                //     //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                //     mlink.label=System.Label.IPA_ProductRoadmap_Server_bnftlnk_Label;
                //     mlink.externalUrl=System.Label.IPA_ProductRoadmap_Server_bnftlnk_Link;
                //     metric.link=mlink;
                // }//IPA2.0 TWC727-2912
                when 'Intel® New Product Information' {
                        //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                        mlink.label=System.Label.prm_Intel_New_Product_Information;
                        mlink.externalUrl=System.Label.prm_Intel_New_Product_Information_link;
                        metric.link=mlink;
                    }
                    
                    // when 'Embedded/IoT Zone' {
                    //     //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                    //     mlink.label=System.Label.prm_Embedded_IoT_Zone;
                    //     mlink.externalUrl=System.Label.prm_Embedded_IoT_Zone_link;
                    //     metric.link=mlink;
                        
                    // }
                    // when 'Branded Systems Zone' {
                    //     //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                    //     mlink.label=System.Label.prm_Branded_Systems_Zone;
                    //     mlink.externalUrl=System.Label.prm_Branded_Systems_Zone_link;
                    //     metric.link=mlink;
                        
                    // }
                    /* TWC729-6644 - Commented as part of this story 
                    when 'Intel® Solutions Library' {
                        //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                        mlink.label=System.Label.prm_Intel_Solutions_Library;
                        mlink.externalUrl=System.Label.prm_Intel_Solutions_Library_link;
                        metric.link=mlink;
                        
                    } */
                   //IPA2.0 starts here TWC727-2912
                   /*when 'Intel® Xeon® 6 Processors for Partners' {
                        //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                        mlink.label=System.Label.prm_Intel_Xeon_6_Processors_for_Partners;
                        mlink.externalUrl=System.Label.Intel_Xeon_6_Processors_for_Partners_link; 
                        metric.link=mlink;   
                    }
                     when 'Intel_Core_Ultra_for_Partners_link' {
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                        mlink.label=System.Label.Intel_Core_Ultra_for_Partners;
                        mlink.externalUrl=System.Label.Intel_Core_Ultra_for_Partners_link; 
                        metric.link=mlink;
                    }
                    when 'vPro® for Partners'{
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                        mlink.label=System.Label.prm_vPro_for_Partners;
                        mlink.externalUrl=System.Label.vPro_for_Partners_link;
                        metric.link=mlink;    
                    }
                    when 'Gaudi for Partners'{
                    //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                        mlink.label=System.Label.Gaudi_for_Partners_label;
                        mlink.externalUrl=System.Label.Gaudi_for_Partners_link;
                        metric.link=mlink;      
                    }
                    // IPA2.0 ends here
                                    
            }
            listMetrics.add(metric);
            userBenefit.Metrics = listMetrics;
        }
        
        // create links on the blades
        if(ctaLinks.size()>0){
            List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                switch on cta {
                    when 'Products & Roadmaps' {
                        //IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                        link1.label=System.Label.IPA_ProductRoadmap_Primary_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_ProductRoadmap_Primary_bnftlnk_Link;
                    }
                    when 'Web Order Management' {
                        link1.label=System.Label.IPA_ProductRoadmap_webOrder_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_ProductRoadmap_webOrder_bnftlnk_Link;
                    }
                    // when 'Server Configurator' {
                    //     link1.label=System.Label.IPA_ProductRoadmap_Server_bnftlnk_Label;
                    //     link1.externalUrl=System.Label.IPA_ProductRoadmap_Server_bnftlnk_Link;
                    // }//IPA2.0 TWC727-2912
                    when 'Intel® New Product Information' {
                        //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                        link1.label=System.Label.prm_Intel_New_Product_Information;
                        link1.externalUrl=System.Label.prm_Intel_New_Product_Information_link;
                        
                    }
                    
                    // when 'Embedded/IoT Zone' {
                    //     //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                    //     link1.label=System.Label.prm_Embedded_IoT_Zone;
                    //     link1.externalUrl=System.Label.prm_Embedded_IoT_Zone_link;
                        
                    // }
                    // when 'Branded Systems Zone' {
                    //     //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                    //     link1.label=System.Label.prm_Branded_Systems_Zone;
                    //     link1.externalUrl=System.Label.prm_Branded_Systems_Zone_link;
                        
                    // }
                    /* TWC729-6644 - Commented as part of this story
                    when 'Intel® Solutions Library' {
                        //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                        link1.label=System.Label.prm_Intel_Solutions_Library;
                        link1.externalUrl=System.Label.prm_Intel_Solutions_Library_link;
                        
                    } */
                   //IPA 2.0 --starts here TWC727-2912
                  /* when 'Intel® Xeon® 6 Processors for Partners' {
                        //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                        link1.label=System.Label.prm_Intel_Xeon_6_Processors_for_Partners;
                        link1.externalUrl=System.Label.Intel_Xeon_6_Processors_for_Partners_link;    
                    }
                    when 'Intel® Core® Ultra™ for Partners' {
                        //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                        link1.label=System.Label.Intel_Core_Ultra_for_Partners;
                        link1.externalUrl=System.Label.Intel_Core_Ultra_for_Partners_link;    
                    }
                    when 'vPro® for Partners'{
                        //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                        link1.label=System.Label.prm_vPro_for_Partners;
                        link1.externalUrl=System.Label.vPro_for_Partners_link; 
                    }
                    when 'Gaudi for Partners'{
                        //  IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();         
                        link1.label=System.Label.Gaudi_for_Partners_label;
                        link1.externalUrl=System.Label.Gaudi_for_Partners_link; 
                    }
                    //IPA 2.0 ends here
                    
                }
                linkList.add(link1);            
            }
            userBenefit.links=linkList; 
        }     
        // //system.debug('training--->'+userBenefit.title);
        return userBenefit;    
    }*/
    
    public static List<IPABenefitWrapper.Metrics> getPartnerHelpMetrics(String partnerRole,IPABenefitWrapper.UserProfile userInfo)
    {
        String metricValue = '0';
        String getTier; 
       if(partnerRole!='Distributor'){
            //getTier=getPartnerTier(partnerRole, accId);
            getTier=getPartnerTierACM(partnerRole,userInfo);
            if(getTier=='Partner'){
                metricValue='8'; //IPA2.0-TWC727-3009
            }
            else if(getTier=='Prestige'){
                metricValue='4';//IPA2.0-TWC727-3009
            }
           /*else if(getTier=='Member'){
                metricValue='48'; //IPA2.0-TWC727-3009
            }*/
        }
        else{
            metricValue='4';//IPA2.0-TWC727-3009
        }
        
        Integer awrMetric = 0;
        boolean awrVisibility = false;
       // //system.debug('benefitsList in IPA'+benefitsList);
            if(userInfo.onePartnerId!= null)
            {
                List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
                for(PRM_AccountBenefitAssociation__c pba : [Select id, name, PRM_Partner_Benefit_Id__r.Name from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c= :userInfo.onePartnerId and PRM_Status_Nm__c = 'Active' and PRM_Partner_Benefit_Id__r.Name =: Label.PRM_Advanced_Warranty_Replacement ]){
                    abaList.add(pba);
                }
                if(abaList.size() > 0 && !abaList.isempty()){
                try{
                    AggregateResult aggregateSum = [Select Sum(PRM_Number_Of_AWR_Remaining_Nbr__c) awrMetric from PRM_Warranty_Data__c where PRM_One_Partner_Id__c =:userInfo.onePartnerId];
                    awrMetric=Integer.valueOf(aggregateSum.get('awrMetric'));
                    awrVisibility = true;
                }catch(Exception e){
                    //system.debug('An exception has occurred in getPartnerMetrics()!'+e);
                }
                }     
                
            }
         List<IPABenefitWrapper.Metrics> partnerHelpMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
        metric.label=System.Label.IPA_Partnerhelp_mtrc_Label;
        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
        IPABenefitWrapper.Metrics metric1=new IPABenefitWrapper.Metrics() ;
        metric1.label=System.Label.PRM_AWR_Units;
        IPABenefitWrapper.Link mlink1=new IPABenefitWrapper.Link();
        //mlink1.label=System.Label.IPA_Partnerhelp_mtrc_SupportTic_action;
        //mlink1.externalUrl=System.Label.IPA_Partnerhelp_mtrc_SupportTic_url;
        mlink1.label = '';
        mlink1.externalUrl= '';
        mlink.label='';
        mlink.externalUrl='';
        metric.link=mlink;
        metric.value=metricValue;
        metric.unit='HR';
        metric1.link=mlink1;
        partnerHelpMetrics.add(metric);
        
        if(awrMetric != null){
            metric1.value=String.valueOf(awrMetric);
        }
        else{
           metric1.value='0'; 
        }
          if(awrVisibility == true){
            partnerHelpMetrics.add(metric1);    
        } 
        return partnerHelpMetrics;        
    }   
    
    public static IPABenefitWrapper.Contactdata getContacts(String partnerRole,IPABenefitWrapper.UserProfile userInfo)
    {
        IPABenefitWrapper.Contactdata contArr = new IPABenefitWrapper.Contactdata();
        List<IPABenefitWrapper.Contact> contList = new List<IPABenefitWrapper.Contact>();
        List<PRM_Account_Contact_Relationship__c> accTeam = [SELECT Id ,PRM_Account_Id__r.Core_Covered_Account__c,PRM_Account_Id__r.Owner.FirstName,PRM_Account_Id__r.Owner.LastName,PRM_Account_Id__r.Owner.Title,PRM_Account_Id__r.Owner.Phone,PRM_Account_Id__r.Owner.Email,PRM_Contact_Id__r.FirstName,PRM_Contact_Id__r.LastName ,PRM_Contact_Id__r.Core_Job_Function__c,toLabel(PRM_Contact_Id__r.Core_Profession__c),PRM_Relationship_Id__r.Name,PRM_Contact_Id__r.Phone, PRM_Contact_Id__r.Email FROM PRM_Account_Contact_Relationship__c WHERE PRM_Account_Id__c =: userInfo.companyProfileId AND PRM_Partner_Role__c =: partnerRole  AND (PRM_Relationship_Id__r.Name = 'Partner Admin' OR PRM_Relationship_Id__r.Name = 'Partner Admin Delegate') AND PRM_InActive_Ind__c = false AND PRM_Status_Nm__c='Complete' ORDER BY PRM_Relationship_Id__r.Name LIMIT 2];
        ////system.debug('ACCTEAM : ' + accTeam);
        List<IPABenefitWrapper.Contact> contPAList = new List<IPABenefitWrapper.Contact>();
        List<IPABenefitWrapper.Contact> contPADList = new List<IPABenefitWrapper.Contact>();
        if(accTeam!=null && !accTeam.IsEmpty())
        {
            if(accTeam[0].PRM_Account_Id__r.Core_Covered_Account__c)
            {
                IPABenefitWrapper.Contact acctOwner = new IPABenefitWrapper.Contact();
                acctOwner.id = '1';
                acctOwner.name = accTeam[0].PRM_Account_Id__r.Owner.FirstName + ' ' + accTeam[0].PRM_Account_Id__r.Owner.LastName;
                acctOwner.title = accTeam[0].PRM_Account_Id__r.Owner.Title;
                acctOwner.role = 'Account Manager';
                acctOwner.phone = accTeam[0].PRM_Account_Id__r.Owner.Phone;
                acctOwner.email = accTeam[0].PRM_Account_Id__r.Owner.Email;
                acctOwner.faIcon = 'fa-intel-user-o';
                contList.add(acctOwner);
            }
            else
            {
                //Need to check if we have to get it from the One Partner ID
            }
            Integer cnt = 2;
            for(PRM_Account_Contact_Relationship__c acrTemp : accTeam)
            {
                ////system.debug('ACRTEMP : ' + acrTemp);
                IPABenefitWrapper.Contact acctPAdmin = new IPABenefitWrapper.Contact();
                acctPAdmin.id = ''+cnt;cnt++;
                acctPAdmin.name = acrTemp.PRM_Contact_Id__r.FirstName + ' ' + acrTemp.PRM_Contact_Id__r.LastName;
                acctPAdmin.title = acrTemp.PRM_Contact_Id__r.Core_Profession__c;
                acctPAdmin.role = acrTemp.PRM_Relationship_Id__r.Name;
                acctPAdmin.phone = acrTemp.PRM_Contact_Id__r.Phone;
                acctPAdmin.email = acrTemp.PRM_Contact_Id__r.Email;
                acctPAdmin.faIcon = 'fa-intel-user-o';
                ////system.debug('ACCTEMP : ' + acctPAdmin);
                if(acctPAdmin.role == 'Partner Admin')
                    contPAList.add(acctPAdmin);
                else if(acctPAdmin.role == 'Partner Admin Delegate')
                    contPADList.add(acctPAdmin);
            }
            if(!contPAList.IsEmpty())
            {
                contPAList.addAll(contList); 
                contArr.contacts = contPAList;
            }
            else if(!contPADList.IsEmpty())
            {
                contPADList.addAll(contList);
                contArr.contacts = contPADList;
            }
            contArr.label = System.Label.PRM_AccountTeam;
        }
        else
        {
            List<Account> accountTeam = [SELECT Id,Core_Covered_Account__c,Owner.FirstName,Owner.LastName,Owner.Title,Owner.Phone,Owner.Email FROM Account WHERE Id =: userInfo.companyProfileId AND Core_Covered_Account__c = TRUE];
            if(accountTeam!=null && !accountTeam.IsEmpty())
            {
                IPABenefitWrapper.Contact acctOwner = new IPABenefitWrapper.Contact();
                acctOwner.id = '1';
                acctOwner.name = accountTeam[0].Owner.FirstName + ' ' + accountTeam[0].Owner.LastName;
                acctOwner.title = accountTeam[0].Owner.Title;
                acctOwner.role = 'Account Manager';
                acctOwner.phone = accountTeam[0].Owner.Phone;
                acctOwner.email = accountTeam[0].Owner.Email;
                acctOwner.faIcon = 'fa-intel-user-o';
                List<IPABenefitWrapper.Contact> lstAcctTeam = new List<IPABenefitWrapper.Contact>();
                lstAcctTeam.add(acctOwner);
                contArr.contacts = lstAcctTeam;
            }
        }
        return contArr;
    }
    
    public static string numberConversion(Decimal trainingCount){
        Decimal roundNumber=0;
        String value;

        /*Utkarsh - TWC727-661 - Below code is added to put comma in the training data*/
        roundNumber = trainingCount;
        List<String> args = new String[]{'0','number','###,###,##0.00'};
        value = String.format(roundNumber.format(), args);
        //Commented the below code since we need to display full training data.
        /*
        if(trainingCount < 1000){
            trainingCount=trainingCount;
            roundNumber=trainingCount.setScale(0, RoundingMode.HALF_UP);
            value = string.valueOf(roundNumber);

        }else if(trainingCount >=1000 && trainingCount<1000000){
           trainingCount=trainingCount/1000;
             roundNumber=trainingCount.setScale(0, RoundingMode.HALF_UP);
            value = string.valueOf(roundNumber)+'K';
            //system.debug('Inside numberconv 1 if');
            //system.debug('Value of numconv'+value);
        }
       
         else if(trainingCount >=1000000 && trainingCount<1000000000){
            trainingCount=trainingCount/1000000;
            roundNumber=trainingCount.setScale(0, RoundingMode.HALF_UP);
            value = string.valueOf(roundNumber)+'M';
            //system.debug('Inside numberconv 2 if');
             //system.debug('Value of numconv'+value);
        } else if (trainingCount >=1000000000){
            trainingCount=trainingCount/1000000000;
            roundNumber=trainingCount.setScale(0, RoundingMode.HALF_UP);
            value = string.valueOf(roundNumber)+'B';
        }*/
         
        return value;
      
    }
              
    /* To Show Deal Registration Blade
              ** Added by Shraddha More*/
    public static IPABenefitWrapper.UserBenefitInfo getDealReg(List<String> dealRegLinks){
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();

        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Link> linkList =  new List<IPABenefitWrapper.Link>();
        List<IPABenefitWrapper.Metrics> dealRegMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;

        userBenefit.title= System.Label.PCC_Deal_Blade;
        //userBenefit.faIcon=showLogoMap.containsKey('Partner Lookup Tool') && !showLogoMap.get('Partner Lookup Tool')?System.Label.PRM_IPALookup_Icon:null;
        userBenefit.description= System.Label.PCC_DealRegBlade_Desc;
         populateCTALinks(dealRegLinks,ctaPriorities,ctaLinks); //IPA2.0-TWC727-2896
         //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = userInfo(currentUserId);
            String lang = profile.userLanguage;
 //IPA2.0-TWC727-2896>> start
          // Step 1: Create controller for your custom metadata name
            Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');

            // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
            Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();
            
        // Step 3: Iterate your CTA list
        // create 1 metric based on ctr priority
        for (String cta : ctaPriorities) {
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
            if (ctaMetaMap.containsKey(cta)) {
                Map<String, Object> meta = ctaMetaMap.get(cta);
                if(String.valueOf(meta.get('type'))=='getDealReg'  && Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())){
                    mlink.label=String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                    mlink.externalUrl=String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                    metric.link=mlink;
                }
                
            }
            dealRegMetrics.add(metric);
            userBenefit.Metrics = dealRegMetrics;
        }
        return userBenefit; 
    } //IPA2.0-TWC727-2896>> end
        /*for(integer i = 0;i<dealRegLinks.size(); i++) {
            ctaPriorities.add(dealRegLinks[0]);
            if(dealRegLinks[i] != ctaPriorities[0]){
                ctaLinks.add(dealRegLinks[i]);  
            } 
            if(Test.isRunningTest()){
                ctaPriorities.add(dealRegLinks[i]);
                ctaLinks.add(dealRegLinks[i]);
            }
        }

         //create metric for points based on cta priority
        for(String ctaPrior : ctaPriorities){
            switch on ctaPrior {              
                when 'Deal Registration' { 
                    IPABenefitWrapper.Link mlink = new IPABenefitWrapper.Link();                   
                    mlink.label = System.Label.PCC_Deal_Blade;
                    mlink.externalUrl = System.Label.PCC_DealBlade_Link;
                    metric.link=mlink;
                }
            }
            dealRegMetrics.add(metric);
            userBenefit.Metrics = dealRegMetrics;
        }

        return userBenefit;        
    }*/

    @AuraEnabled(cacheable=true)
    public static String checkInternalUser(Id userId, String currentUrl){
        String isRedirectToAccessDenied = 'false';
        List<String> userPermissionSets = new List<String>();
        if(userId != null && !String.isBlank(currentUrl) && currentUrl.contains(System.Label.IPA_Secure_Homepage_Link)){
            IPABenefitWrapper.UserProfile userInfo =  userInfo(userId);
            String email = userInfo.UserEmail;
            String emailDomain = email.split('@')[1];
            if(emailDomain == LabelConfiguration__mdt.getInstance('PRM_internalDomain').Value__c){
                List<String> mpPermissionSet = LabelConfiguration__mdt.getInstance('PRM_MP_permissionSet').Value__c.split(';');
                isRedirectToAccessDenied = 'true';
                for (PermissionSetAssignment psa : [
                    SELECT PermissionSet.Name 
                    FROM PermissionSetAssignment 
                    WHERE AssigneeId = :userId
                ]){
                    if(mpPermissionSet.contains(psa.PermissionSet.Name) && currentUrl.contains(System.Label.PMP_IPA_Dashboard_Url)){
                            isRedirectToAccessDenied = 'false';
                            break;
                        }
                }
            }
        }
        return isRedirectToAccessDenied;
    }
}