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
*********************************************************************************************************************/

public without sharing class IPABenefitUtility {
    
    public static Final String ORIGIN  = 'IPABenefitUtility';
    public static Final String SEVERITY  = 'Critical';
    public static Final String PROJECT  = 'IPA';
    public static Final String ERROR  = System.label.PRM_Log_Entry_Error_Object_Level;
    public static Final String DETAILS  = System.label.PRM_Log_Entry_Details_Object_Level;
    private static final String approved = 'Approved';
    private static final String admin = 'Admin Review';
    private static final String draft = 'Draft';
    private static final String updateRequired = 'Update Required';
    private static final String STATUS_ACTIVE='Active';
    public static string pageType {set;get;}
    public static string entitlementNam {set;get;}
    public static Boolean IS_CIDAAS_ENABLED = !Test.isRunningTest()?Boolean.valueof(Label.PRM_CiDaaS_Enabled):True; //As Per CiDaaS Change
    public static IPABenefitWrapper.UserProfile userInfo(ID userID){
        system.debug('IPABenefitUtility:userInfo');
        IPABenefitWrapper.UserProfile userData = new IPABenefitWrapper.UserProfile();
        System.debug('URL :'+System.URL.getSalesforceBaseUrl());
        if(userID != null){
            //false positive
            User c= [select id,name,LanguageLocaleKey,LocaleSidKey,contact.id,contact.Core_IPA_One_Partner_Id__c,contact.title,contact.name,contact.Core_Job_Function__c,toLabel(contact.Core_Profession__c), account.name,contact.phone,account.id,contact.Email from user where id= : userID];
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
            
        }
        
        return userData;
    }
    //this method is used to fetch profile information on partner benefit experience
    @AuraEnabled(cacheable=true)
    public static IPABenefitWrapper.UserProfile  getProfileInfo(ID userID, String page){
        System.debug('UserID>>>>'+UserID);
        datetime start = datetime.NOW();
        System.debug('IPABenefitWrapper.getProfileInfo -StartTime'+ start);
        pageType = page;
        IPABenefitWrapper.UserProfile userData = userInfo(userID);
        userData.marqueeTitle=  (!String.isEmpty(pageType)  && pageType.indexOf(Label.PRM_CP_CompanyProfile_Title_ENG)>-1) ? Label.PRM_CP_CompanyProfile_Title
         :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_DDR_Title)>-1)? Label.PRM_DDR_Title
        :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_Dashboard_Title_ENG)>-1) ? Label.PRM_Dashboard_Title 
                :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_Release_Of_Information_ENG)>-1) ?Label.PRM_Release_Of_Information
                    :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_Training_Credits_ENG)>-1) ?Label.PRM_Training_Credits
                        :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_Sales_Details_Title_ENG)>-1) ?Label.PRM_Sales_Details_Title
                            :(!String.isEmpty(pageType) && pageType.indexOf(Label.EPUM_ManagePersonnel_ENG)>-1) ?Label.EPUM_ManagePersonnel  
                                :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_PartnerSearchHeader_ENG)>-1) ?Label.PRM_PartnerSearchHeader
                                    :(!String.isEmpty(pageType) && pageType.indexOf(Label.PRM_Downloads_ENG)>-1) ?Label.PRM_Downloads
                                        :System.label.IPA_Benefits_Manage_Benefits;               
        //userData.marqueeTitle = System.label.IPA_Builder_Title;
        system.debug('marqueeTitle ===>'+userData.marqueeTitle);
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
        System.debug('URL :'+URL.getSalesforceBaseUrl().toExternalForm());
        dasbboard.communityPage= '';
        dasbboard.objectPage = '';
        dasbboard.recordId = '';
        userData.dashboardLink = dasbboard;
        IPABenefitWrapper.mProfileLink profile = new IPABenefitWrapper.mProfileLink();
        profile.label =System.label.IPA_BuilderRightPanel_CTA2Label;  
        if(IS_CIDAAS_ENABLED){
            profile.externalUrl = System.Label.IPA_MyProfile_Link_Cidaas;//'https://www.intel.com';
        }
        else{
            profile.externalUrl = System.Label.IPA_MyProfile_Link;//'https://www.intel.com';
        }       
        profile.communityPage= '';
        profile.objectPage = '';
        profile.recordId = userData.companyProfileId;//c.account.Id;
        userData.myProfileLink = profile;
        datetime endd = datetime.now();
        System.debug('IPABenefitWrapper.getProfileInfo -EndTime'+ endd);
        Decimal millisecs = Decimal.valueOf(endd.getTime() - start.getTime());
        integer div = 1000;   
        Decimal cal = millisecs/div;
        system.debug('getProfileInfoSecs: ' +cal);
        return userData;        
    }
}