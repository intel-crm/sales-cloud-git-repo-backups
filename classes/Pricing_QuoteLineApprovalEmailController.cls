/**
 * @description       : Class to get values for QuoteLine Approval Notification
 * @author            : Subhanku
 * @group             : Accenture
 * @last modified on  : 03-11-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_QuoteLineApprovalEmailController {

    public Id quoteLineId {get;set;}
    public SBQQ__QuoteLine__c quoteLineData;
    private List<SBQQ__QuoteLine__c> quoteLineDataToBeDisplayed = new List<SBQQ__QuoteLine__c>();
    public static String qlEndDate {set;get;}
    public static String newQuantity {set;get;}
    public static String newRequestedPrice {set;get;}
    public static Integer quoteLineRequestedQuantity {set;get;}
    public static Integer totalRequestedQuantity {set;get;}
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
    * @author Subhanku | 11-07-2022 
    * @return String 
    **/
    public String getHeaderURL(){
        if (documentMap.isEmpty()) return null;

        Document document = documentMap.values().get(0);
        String domainName = String.valueOf(System.Url.getOrgDomainUrl()).split('=')[1].split(']')[0];
        String orgId = UserInfo.getOrganizationId();
        headerURL = domainName + '/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + orgId;
        return headerURL;
    }

    /**
    * @description Method to get the domain name
    * @author Subhanku | 11-07-2022 
    * @return String 
    **/
    public String getDomainName(){
        String domainName = String.valueOf(System.Url.getOrgDomainUrl()).split('=')[1].split(']')[0];
        return domainName;
    }

    /**
    * @description Method To fetch Quote Line data to be displayed in email Template by other methods
    * @author Subhanku | 11-07-2022 
    * @return SBQQ__QuoteLine__c 
    **/
    public SBQQ__QuoteLine__c qliDetails() {
        try {
            quoteLineDataToBeDisplayed = [SELECT Id, SBQQ__Quote__r.Id, Pricing_Sales_Rep__r.Email, Pricing_Sales_Rep__r.DelegatedApproverId, Pricing_Primary_Contact_Nm__c, Pricing_Primary_Contact_Nm__r.Name, Pricing_Request_Discount_Unit_Price_qty__c, Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c, Pricing_Reference_Quote_Line_Nbr__r.Pricing_ECAP_Price_Amt__c,
                                           Pricing_Reference_Quote_Line_Nbr__r.Pricing_End_Date_dt__c, Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Unit_Qty__c, Pricing_Reference_Quote_Line_Nbr__r.Pricing_Req_Discounted_Unit_Price__c, Pricing_Unit_Qty__c, Pricing_Quote_Total_Requested_Quantity__c,
                                           Pricing_ECAP_Price_Amt__c, Pricing_Approved_Unit_Qty__c, Pricing_Req_Discounted_Unit_Price__c, Pricing_End_Date_dt__c, Pricing_New_Quantity_qty__c
                                           FROM SBQQ__QuoteLine__c 
                                           WHERE Id = :quoteLineId LIMIT 1];

            if (!quoteLineDataToBeDisplayed.isEmpty()) {
                quoteLineData = quoteLineDataToBeDisplayed[0];
                quoteLineRequestedQuantity = (Integer) Math.round(quoteLineData.Pricing_Unit_Qty__c);
                totalRequestedQuantity = (Integer) Math.round(quoteLineData.Pricing_Quote_Total_Requested_Quantity__c);
            } else {
                quoteLineData = new SBQQ__QuoteLine__c();
            }
        } catch (Exception e) {
            Pricing_Tender_Utility.logError(e);
            quoteLineData = new SBQQ__QuoteLine__c();
        }
        return quoteLineData;
    }

    /**
    * @description Method to get the changed fields for CR Quoteline
    * @author Subhanku | 11-07-2022 
    * @return String 
    **/
    public String getChangedFields(){
        quoteLineData = quoteLineData == null || quoteLineData.Id == null ? qliDetails() : quoteLineData;
        String changedFieldsInd = '';
        Date dt;

        if (quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c != quoteLineData.Pricing_End_Date_dt__c && quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_End_Date_dt__c != null && quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_End_Date_dt__c != quoteLineData.Pricing_End_Date_dt__c) {
            changedFieldsInd = 'End Date';
            dt = quoteLineData.Pricing_End_Date_dt__c;
            qlEndDate = String.valueOf(dt.month() + '-' + dt.day() + '-' + dt.year());
        }
        if (quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Unit_Qty__c != quoteLineData.Pricing_New_Quantity_qty__c) {
            changedFieldsInd = !String.isEmpty(changedFieldsInd) ? changedFieldsInd + ', Quantity' : 'Quantity';
            newQuantity = String.valueOf(quoteLineData.Pricing_New_Quantity_qty__c);
        }
        if (quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_ECAP_Price_Amt__c != quoteLineData.Pricing_Request_Discount_Unit_Price_qty__c && quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Req_Discounted_Unit_Price__c != quoteLineData.Pricing_Request_Discount_Unit_Price_qty__c) {
            changedFieldsInd = !String.isEmpty(changedFieldsInd) ? changedFieldsInd + ', Price' : 'Price';
            newRequestedPrice = String.valueOf(quoteLineData.Pricing_Request_Discount_Unit_Price_qty__c);
        }
        return changedFieldsInd;
    }

    /**
    * @description Method to get the primary contact
    * @author Subhanku | 11-07-2022 
    * @return String 
    **/
    public String getCurrentPrimaryContact() {
        String currPrimaryContact = '';
        quoteLineData = quoteLineData == null || quoteLineData.Id == null ? qliDetails() : quoteLineData;
        boolean isDrafterLimitedContact = false;

        if (!String.isEmpty(quoteLineData.Pricing_Primary_Contact_Nm__c)) {
            List<User> primaryContactUsr = [SELECT Id, Contact.Name FROM User WHERE ContactId = :quoteLineData.Pricing_Primary_Contact_Nm__c];
            if (!primaryContactUsr.isEmpty()) {
                if (!permissionSetAssignmentMap.containsKey(primaryContactUsr[0].Id)) {
                    permissionSetAssignmentMap.put(primaryContactUsr[0].Id, [SELECT PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :primaryContactUsr[0].Id]);
                }
                for (PermissionSetAssignment psa : permissionSetAssignmentMap.get(primaryContactUsr[0].Id)) {
                    if (psa.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderDrafterLimited) {
                        isDrafterLimitedContact = true;
                        break;
                    }
                }
            }
            if (isDrafterLimitedContact || primaryContactUsr.isEmpty()) {
                currPrimaryContact = userMap.get(UserInfo.getUserId()).Contact.Name;
            } else {
                currPrimaryContact = quoteLineData.Pricing_Primary_Contact_Nm__r.Name;
            }
        }
        return currPrimaryContact;
    }
}