/**
 * @description       : Class to get values for Approval Price Rules Notification
 * @author            : Suraj
 * @group             : Accenture
 * @last modified on  : 05-23-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_PriceRulesEmailController {

    public Id approvalPriceRuleId {get;set;}
    public Pricing_Approval_Price_Rules__c approvalPriceRuleData;
    private List<Pricing_Approval_Price_Rules__c> approvalPriceRuleDataToBeDisplayed = new List<Pricing_Approval_Price_Rules__c>();
    public String headerURL;

    private static Map<Id, Document> documentMap;
    private static Map<Id, User> userMap;
    private static Map<Id, List<PermissionSetAssignment>> permissionSetAssignmentMap;

    static {
        documentMap = new Map<Id, Document>([SELECT Id FROM Document WHERE Name = :Label.Pricing_IQR_Intel_Logo LIMIT 1]);
        userMap = new Map<Id, User>([SELECT Id, Contact.Name FROM User WHERE Id = :UserInfo.getUserId()]);
        permissionSetAssignmentMap = new Map<Id, List<PermissionSetAssignment>>();
    }

    /**
    * @description Rturn the header URL value to email template body
    * @author Suraj | 05-05-2025 
    * @return String 
    **/
    public String getHeaderURL(){
        if (documentMap.isEmpty()) return null;

        Document document = documentMap.values().get(0);
        String domainName = URL.getOrgDomainUrl().toExternalForm();
        String orgId = UserInfo.getOrganizationId();
        headerURL = domainName + '/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + orgId;
        return headerURL;
    }

    /**
    * @description Method to get the domain name
    * @author Suraj | 05-05-2025 
    * @return String 
    **/
    public String getDomainName(){
        String domainName = URL.getOrgDomainUrl().toExternalForm();
        return domainName;
    }

    /**
    * @description Method To fetch Approval Price Rules to be displayed in email Template by other methods
    * @author Suraj | 05-05-2025 
    * @return Pricing_Approval_Price_Rules__c 
    **/
    public Pricing_Approval_Price_Rules__c approvalPriceRuleDetails() {
        try {
            approvalPriceRuleDataToBeDisplayed = [SELECT Id, Name, Pricing_Quote_Type__c, Pricing_Form_Factor__c, Pricing_Server_Deal_Type_Nm__c, Pricing_End_Customer_Country__c, Pricing_Account__r.Name, Pricing_Market_Segment_values_Nm__c, Pricing_Intel_Sales_Rep_Email_Txt__c, Pricing_Intel_Account_Exec_Email_Txt__c, Pricing_Approval_Status__c
                                                   FROM Pricing_Approval_Price_Rules__c 
                                                   WHERE Id = :approvalPriceRuleId LIMIT 1];

            if (!approvalPriceRuleDataToBeDisplayed.isEmpty()) {
                approvalPriceRuleData = approvalPriceRuleDataToBeDisplayed[0];
            } else {
                approvalPriceRuleData = new Pricing_Approval_Price_Rules__c();
            }
        } catch (Exception e) {
            Pricing_Tender_Utility.logError(e);
            approvalPriceRuleData = new Pricing_Approval_Price_Rules__c();
        }
        return approvalPriceRuleData;
    }
}