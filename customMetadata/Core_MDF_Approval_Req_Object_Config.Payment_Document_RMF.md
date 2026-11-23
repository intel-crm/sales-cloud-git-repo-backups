<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Payment Document RMF</label>
    <protected>false</protected>
    <values>
        <field>Core_MDF_Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Core_MDF_By_Pass_Bulk__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Core_MDF_Compact_Field_Properties__c</field>
        <value xsi:type="xsd:string">Tax Invoice Number:Core_MDF_VAT_Invoice_Number_Txt__c,Tax Amount:Core_MDF_VAT_Amt__c,Document Status:Core_MDF_Status_Txt__c,Reimbursement amount:Core_MDF_Reimbursement_Amt__c,Tax %:Core_MDF_VAT_Per__c</value>
    </values>
    <values>
        <field>Core_MDF_Conditional_Field__c</field>
        <value xsi:type="xsd:string">Core_MDF_Status_Txt__c=&apos;Under Review&apos;</value>
    </values>
    <values>
        <field>Core_MDF_Detail_Field_Properties__c</field>
        <value xsi:type="xsd:string">Document ID:Name,Document Type:Core_MDF_Document_Type_Txt__c,Tax Invoice Number:Core_MDF_VAT_Invoice_Number_Txt__c,Claim:Core_MDF_Claim_Id__c:Core_MDF_Claim_Id__r-Title,	
Document Status:Core_MDF_Status_Txt__c,Tax Amount:Core_MDF_VAT_Amt__c,Created By:Core_MDF_VAT_CreatedBy_Nm__c,Last Modified By:Core_MDF_Last_VAT_ModifiedBy_Nm__c,Claim Submitter Reminder Date:Core_MDF_ClaimSubmitterReminder_Dtm__c,Payment Admin Reminder Date:Core_MDF_Payment_Admin_Reminder_Date_Dtm__c</value>
    </values>
    <values>
        <field>Core_MDF_Detail_Propertie__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Details_Properties__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Field_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Field_Propertie__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Field_Properties__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Fields_API_Name__c</field>
        <value xsi:type="xsd:string">id,Name,Core_MDF_VAT_Invoice_Number_Txt__c,Core_MDF_VAT_Amt__c,Core_MDF_Status_Txt__c,Core_MDF_Document_Type_Txt__c,Core_MDF_VAT_Per__c,Core_MDF_Claim_Id__r.Title,Core_MDF_Reimbursement_Amt__c,Core_MDF_Approved_File_Name_Txt__c,Core_MDF_Vat_Inv_Guide_Link__c,Core_MDF_VAT_CreatedBy_Nm__c,Core_MDF_Last_VAT_ModifiedBy_Nm__c,Core_MDF_Payment_Admin_Reminder_Date_Dtm__c,Core_MDF_ClaimSubmitterReminder_Dtm__c</value>
    </values>
    <values>
        <field>Core_MDF_Fields_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Icon_Name__c</field>
        <value xsi:type="xsd:string">custom:custom76</value>
    </values>
    <values>
        <field>Core_MDF_Navigate_Standard_Page_Ind__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Core_MDF_Object_Label_Name__c</field>
        <value xsi:type="xsd:string">Payment Document</value>
    </values>
    <values>
        <field>Core_MDF_Object_Name__c</field>
        <value xsi:type="xsd:string">Core_MDF_Claim_VAT_Info__c</value>
    </values>
    <values>
        <field>Core_MDF_PrgorRecType__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Program__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Record_Propertie__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Record_Properties__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Sorted_By__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Table_View_Field_Properties__c</field>
        <value xsi:type="xsd:string">Tax Invoice Number:Core_MDF_VAT_Invoice_Number_Txt__c,Status:Core_MDF_Status_Txt__c,Document Type:Core_MDF_Document_Type_Txt__c,Tax %:Core_MDF_VAT_Per__c</value>
    </values>
    <values>
        <field>Core_MDF_Title_Field__c</field>
        <value xsi:type="xsd:string">Name</value>
    </values>
</CustomMetadata>
