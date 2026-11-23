<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>NotifyApproverBatchQueryPart3</label>
    <protected>false</protected>
    <values>
        <field>Category__c</field>
        <value xsi:type="xsd:string">DDR</value>
    </values>
    <values>
        <field>Value__c</field>
        <value xsi:type="xsd:string">Core_Design_Registration_Status_Nm__c, Core_Intel_Technical_Owner_Id__r.Email FROM Core_Design_Registration__c WHERE Core_Pending_Product_Cnt__c &gt;0 AND PCC_Registration_Type__c = &apos;Design Registration&apos; AND ((Core_Approver_Grp_Nm__c != NULL</value>
    </values>
</CustomMetadata>
