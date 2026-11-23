@IsTest
public class CntctERPMIntStsHandlerTestDataFctry {

    private static Integer accountNumberSequence = 0;
    private static Integer contactNumberSequence = 0;
    private static List<PRM_Partner_Subscription__c> subscriptionList;
    private static Map<Id, List<Id>> profileResponses;
    private static List<PRM_ContactRelationships__c> relationshipList;
    private static List<PRM_PartnerAgreement__c> agreementsList;
    private static List<PRM_PartnerBenefit__c> benefitList;

    public static Id createAccount(String accountType) {
        accountNumberSequence++;
        Account acct = new Account(Name = 'TestAccount' + accountNumberSequence
                                   ,Core_Account_Type__c = accountType
                                   ,BillingCountryCode = 'USA'
                                   ,BIllingStateCode = 'AL'
                                   ,BillingCity = 'Alabama'
                                   ,BillingStreet = 'Test Street');
        insert acct;
        return acct.Id;
    }

    public static Id createContact(String emailId, Id accountId, String erpmIntegrationStatus, String partnerRoles) {
        contactNumberSequence++;
        Contact cntct = new Contact(FirstName = 'Jon' + contactNumberSequence
                                    ,LastName = 'Doe' + contactNumberSequence
                                    ,Email = emailId
                                    ,AccountId = accountId
                                    //,Core_IPA_Partner_Role__c = partnerRoles);
                                    ,Core_IPA_PartnerRole__c = partnerRoles);
        insert cntct;
        cntct.Core_ERPM_Integration_Status__c = erpmIntegrationStatus;
        update cntct;
        return cntct.Id;
    }    

    public static List<PRM_Partner_Subscription__c> createSubscriptions() {
        if(subscriptionList == null || subscriptionList.size() == 0) {
            subscriptionList = new List<PRM_Partner_Subscription__c>();
            subscriptionList.add(new PRM_Partner_Subscription__c(Name = 'Intel® Cloud Insider Webinars',PRM_Subscription_Cd__c = 'CSPx2_Sub3')); 
            insert subscriptionList;  
        } 
        return subscriptionList;
    }

    public static Map<Id, List<Id>> createProfileResponses() {
        if(profileResponses == null || profileResponses.size() == 0) {
            profileResponses = new Map<Id, List<Id>>();
            PRM_Profile_Questions__c question1 = new PRM_Profile_Questions__c(PRM_Question_Cd__c = 'QCode1'
                                                                              ,PRM_Question_Display_Txt__c = 'QCode1'
                                                                              ,PRM_Question_Display_Type_Nm__c = 'EXTERNAL'
                                                                              ,PRM_InActive_Ind__c = false);
            insert question1;
            PRM_Profile_Answer__c answer1 = new PRM_Profile_Answer__c(PRM_Answer_Cd__c = 'ACode1'
                                                                      ,PRM_Answer_Txt__c = 'ACode1'
                                                                      ,PRM_Profile_Questions_Id__c = question1.Id
                                                                      ,PRM_InActive_Ind__c = false);
            insert answer1;
            List<Id> answerList = new List<Id>();
            answerList.add(answer1.Id);
            profileResponses.put(question1.id, answerList);                                                                     
        }
        return profileResponses;
    }    

    public static List<PRM_ContactRelationships__c> createRelationships(Id channelProgramId) {
        if(relationshipList == null || relationshipList.size() == 0) {
            relationshipList = new List<PRM_ContactRelationships__c>();
            PRM_ContactRelationships__c relationship1 = new PRM_ContactRelationships__c(PRM_Contact_Relationship_Cd__c = 'PRIMARY'
                                                                                       ,PRM_InActive_Ind__c= false
                                                                                       ,PRM_Channel_Program_Id__c = channelProgramId);                                                                   
            insert relationship1;
            relationshipList.add(relationship1);                                                                         
        }
        return relationshipList;
    }   

    public static List<PRM_PartnerAgreement__c> createPartnerAgreements(Id channelProgramId) {
        if(agreementsList == null || agreementsList.size() == 0) {
            agreementsList = new List<PRM_PartnerAgreement__c>();
            PRM_PartnerAgreement__c agreement1 = new PRM_PartnerAgreement__c(PRM_Agreement_Cd__c = 'AGR1'
                                                                             ,PRM_InActive_Ind__c= false
                                                                             ,PRM_Language_Codes__c = 'ENG'
                                                                             ,PRM_Channel_Program_Id__c = channelProgramId
                                                                             ,Name = 'AGR1');                                                                   
            insert agreement1;
            agreementsList.add(agreement1);                                                                         
        }
        return agreementsList;
    }  

    public static List<PRM_PartnerBenefit__c> createBenefits(Id channelProgramId) {
        if(benefitList == null || benefitList.size() == 0) {
            benefitList = new List<PRM_PartnerBenefit__c>();
            PRM_PartnerBenefit__c benefit1 = new PRM_PartnerBenefit__c(PRM_Benefit_Cd__c = 'BCode1'
                                                                       ,PRM_InActive_Ind__c = false
                                                                       ,PRM_Channel_Program_Id__c = channelProgramId
                                                                       ,PRM_Benefit_Type_Nm__c = 'MKTG'
                                                                       ,Name = 'BCode1');                                                                   
            insert benefit1;
            benefitList.add(benefit1);                                                                         
        }
        return benefitList;
    }               

}