<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Claim Release Hold</label>
    <protected>false</protected>
    <values>
        <field>Core_MDF_Active_Ind__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Core_MDF_Button_Name_nm__c</field>
        <value xsi:type="xsd:string">Release Hold</value>
    </values>
    <values>
        <field>Core_MDF_Button_Type_nm__c</field>
        <value xsi:type="xsd:string">LightningComponent</value>
    </values>
    <values>
        <field>Core_MDF_Filter_Criteria_Field__c</field>
        <value xsi:type="xsd:string">Core_MDF_Proposal_Based_Ind__c == False AND Core_MDF_OutcomeBased_Ind__c == true AND Core_MDF_Has_Sub_Claims_Ind__c == false AND Core_MDF_Bank_Doc_Hold_Ind__c == True AND Core_MDF_Campaign_Id__c != null</value>
    </values>
    <values>
        <field>Core_MDF_Object_API_Name_nm__c</field>
        <value xsi:type="xsd:string">PartnerFundClaim</value>
    </values>
    <values>
        <field>Core_MDF_Object_Name_nm__c</field>
        <value xsi:type="xsd:string">Claim</value>
    </values>
</CustomMetadata>
