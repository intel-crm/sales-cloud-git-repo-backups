<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>My Open Cases</label>
    <protected>false</protected>
    <values>
        <field>FieldValue__c</field>
        <value xsi:type="xsd:string">Status:text,Core_Sub_Status__c:text,Core_Severity__c:text,Subject:text,Core_IPS_Product_name__c:text,Core_IPS_Project_Case__r.Name:text,Account.Name:text,Core_Contact_Name__c:text,CreatedDate:date/time,LastModifiedDate:text,Core_IPS_Legacy_IPS_ID__c:text</value>
    </values>
    <values>
        <field>HeaderValue__c</field>
        <value xsi:type="xsd:string">Status,Sub Status,Severity,Subject,Product Name,Project,Account Name,Contact Name,Date/Time Opened,Last Modified Date,Legacy ID</value>
    </values>
    <values>
        <field>Query__c</field>
        <value xsi:type="xsd:string">SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__c, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c,Core_IPS_Premier_Support_Project_ID__c, ownerId,Account.id,ContactId FROM Case where Core_IPS_Customer_Visible__c=true AND (Status = &apos;Open&apos; OR Status = &apos;On Hold&apos; OR Status = &apos;New&apos;) AND Core_Sub_Status__c!=&apos;Close-Pending&apos; limit 50</value>
    </values>
</CustomMetadata>
