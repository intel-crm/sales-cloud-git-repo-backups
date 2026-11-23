/*********************************************************************************************************************
* Apex Class Name  : Core_ContactMessageJSONParsing
* Author And Date  : Rohit Podder, 10 AUG 2026
* Function         : Parse json payload of Integration Inbound Message
*********************************************************************************************************************/
public with sharing class Core_ContactMessageJSONParsing{
    public static Core_IntegrationUtility.ERPM_Person parsePerson(Core_IntegrationMessageJSONWrapper messageJSON) {
        Core_IntegrationUtility.ERPM_Person p = new Core_IntegrationUtility.ERPM_Person(); // Person to return
        p.isDeleteIndicator = messageJSON.IsDeleteIndicator;
        p.changeAgentId = messageJSON.changeAgent;
        p.publishTimestamp = null;
        
        if (String.isNotBlank(messageJSON.publishTimeStamp)) {
            try {
                p.publishTimestamp = Core_IntegrationUtility.convertERPMDatetimeStringToDatetime(messageJSON.publishTimeStamp);
            }catch (Exception ex) {
                Core_Log_Entry__c excepLog = new Core_Log_Entry__c(Core_Message__c = ex.getMessage(), Core_Origin__c = 'parsePerson', Core_Project__c = 'Core_ContactMessageJSONParsing' , Core_Details__c = 'Exception for publish-timestamp', Core_Severity__c = 'info', Core_When__c = System.Now());     
                Insert excepLog;
            }
        }
        
        //Person-Information
        p.erpmPersonId     = messageJSON.userProfile.personBasicProfile[0].get('PersonID');
        p.enterpriseId     = messageJSON.userProfile.personBasicProfile[0].get('EnterpriseID');
        p.identityStatus   = messageJSON.userProfile.personBasicProfile[0].get('IdentityStatus');
        p.isIdentityDeleted     = messageJSON.userProfile.personBasicProfile[0].get('IsIdentityDeleted');
        p.deleteStatusReason     = messageJSON.userProfile.personBasicProfile[0].get('PersonDeleteStatusReasonCode');
        p.loginId          = messageJSON.userProfile.personBasicProfile[0].get('ExternalLoginId'); 
        p.title            = messageJSON.userProfile.personBasicProfile[0].get('TitleCd');
        p.firstName        = messageJSON.userProfile.personBasicProfile[0].get('GivenName');
        p.lastName         = messageJSON.userProfile.personBasicProfile[0].get('FamilyName');
        p.erpmLanguageCode = messageJSON.userProfile.personBasicProfile[0].get('LanguageCode');
        p.jobFunctionCode  = messageJSON.userProfile.personBasicProfile[0].get('OccupationTitleCd');
        p.externalUserState= messageJSON.userProfile.personBasicProfile[0].get('ExternalUserState');
        p.externalStateChange= messageJSON.userProfile.personBasicProfile[0].get('ExternalUserStateChangeDateTime');
        p.email            = messageJSON.userProfile.personBasicProfile[0].get('PrimaryEmail');
        p.inactIndicator = messageJSON.userProfile.personBasicProfile[0].get('InactiveInd');
        p.englishFirstName = messageJSON.userProfile.personBasicProfile[0].get('EngGivenName');
        p.englishLastName  = messageJSON.userProfile.personBasicProfile[0].get('EngFamilyName');
        p.emailVerificationDate = messageJSON.userProfile.personBasicProfile[0].get('EmailValidStatusDateTime'); 
        p.lastLoginDate    = messageJSON.userProfile.personBasicProfile[0].get('LastLoginDatetime');
        
        if (String.isNotBlank(messageJSON.userProfile.personBasicProfile[0].get('IntelNoContactDtm'))){
            try{
                p.marketingDoNotContactDate  = Core_IntegrationUtility.convertERPMDatetimeStringToDatetime(messageJSON.userProfile.personBasicProfile[0].get('IntelNoContactDtm'));
            }catch(Exception ex) {
                Core_Log_Entry__c logentrydetails = new Core_Log_Entry__c(Core_Message__c = ex.getMessage(), Core_Origin__c = 'parsePersonPersonInfo', Core_Project__c = 'Core_ContactMessageJSONParsing' , Core_Details__c = 'Exception for marketingDoNotContactDate', Core_Severity__c = 'info', Core_When__c = System.Now());     
                Insert logentrydetails;
            }
        }
        
        if (String.isNotBlank(messageJSON.userProfile.personBasicProfile[0].get('SalesDoNotContactDtm'))){
            try{
                p.salesDoNotContactDate  = Core_IntegrationUtility.convertERPMDatetimeStringToDatetime(messageJSON.userProfile.personBasicProfile[0].get('SalesDoNotContactDtm'));
            }catch(Exception ex) {
                Core_Log_Entry__c logentrydetails = new Core_Log_Entry__c(Core_Message__c = ex.getMessage(), Core_Origin__c = 'parsePersonPersonInfo', Core_Project__c = 'Core_ContactMessageJSONParsing' , Core_Details__c = 'Exception for salesDoNotContactDate', Core_Severity__c = 'info', Core_When__c = System.Now());     
                Insert logentrydetails;
            }
        }
        
        //Electronic-Address
        if(messageJSON.userProfile.electronicAddresses.size() > 0) {
            for (Map<String,String> electronicAddress : messageJSON.userProfile.electronicAddresses) {
                if(electronicAddress.get('ElectronicAddrTypeCd') == 'FAX') {
                    p.fax = electronicAddress.get('ElectronicAddr');
                }else if(electronicAddress.get('ElectronicAddrTypeCd') == 'MOB') {
                    p.mobilePhone = electronicAddress.get('ElectronicAddr');
                }else if(electronicAddress.get('ElectronicAddrTypeCd') == 'PHONE') {
                    p.phone = electronicAddress.get('ElectronicAddr');
                }
            }
        }
        
        //Engagements
        if(messageJSON.userProfile.engagements.size() > 0) {
            Core_IntegrationUtility.ERPM_Engagement pe;
            for (Map<String,String> engagement : messageJSON.userProfile.engagements) {
                pe = new Core_IntegrationUtility.ERPM_Engagement();
                pe.engagementCode = engagement.get('EngagementCode');
                pe.engagementName = engagement.get('EngagementName');
                pe.engagementStatusCode = engagement.get('EngStatusCd');
                pe.effectiveTierCode = engagement.get('Effectivetiercd');
                pe.effEndEngagmentDate=engagement.get('EffectiveEndDtm');       
                p.personEngagements.add(pe);
            }
        }
        
        //Profession
        if(messageJSON.userProfile.professions.size() > 0) {
            p.Profession.Professioncode = messageJSON.userProfile.professions[0].get('ProfessionCode');
        }
        
        //Subscription
        if(messageJSON.userProfile.subscriptions.size() > 0) {
            List<Core_IntegrationUtility.eRPM_Subscription> ListERPM_Subscriptions = new List<Core_IntegrationUtility.eRPM_Subscription>();
            Core_IntegrationUtility.eRPM_Subscription subs;
            for (Map<String,String> subscription : messageJSON.userProfile.subscriptions) {
                subs = new Core_IntegrationUtility.eRPM_Subscription();
                subs.eRPM_EngagementCode = subscription.get('EnggCode');       
                subs.eRPM_SubscriptionCode = subscription.get('SubscriptionCode');                        
                subs.eRPM_SubscriptionStatusCode = subscription.get('Status') == 'USER-SUB' ? 'Active' : 'Inactive';
                ListERPM_Subscriptions.add(subs);
            }
            p.eRPM_Subscriptions = ListERPM_Subscriptions;
        }
        
        //Physical-Address
        if(messageJSON.userProfile.physicalAddresses.size() > 0) {
            for(Map<String,String> phyAddr : messageJSON.userProfile.physicalAddresses) {
                if (phyAddr.get('AddressUsgTypeCode') == 'MAIL') {
                    p.mailingStreet1 = phyAddr.get('Address1');
                    p.mailingStreet2 = phyAddr.get('Address2');
                    p.mailingStreet3 = phyAddr.get('Address3');
                    p.mailingStreet4 = phyAddr.get('Address4');
                    p.mailingCity = phyAddr.get('City');
                    p.mailingState = phyAddr.get('StateCode');
                    p.mailingPostalCode = phyAddr.get('PostalCode');
                    p.mailingCountry = phyAddr.get('CountryCode');
                    break;
                }
            }
        }
        return p;
    }
}