<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>SSD</label>
    <protected>false</protected>
    <values>
        <field>Pricing_Field_Label__c</field>
        <value xsi:type="xsd:string">Product Name,Density,Family Name,Forecast Product Name,Material Id</value>
    </values>
    <values>
        <field>Pricing_Field_Value__c</field>
        <value xsi:type="xsd:string">Name:Text,Core_Mem_Amt__c:Text,Core_Family_Nm__c:Text,Core_Forecast_Product_Name__c:Text,Core_Item_Id__c:Text</value>
    </values>
    <values>
        <field>Pricing_Query__c</field>
        <value xsi:type="xsd:string">Select id,Name,Core_Mem_Amt__c,Core_Family_Nm__c,Core_Forecast_Product_Name__c,Core_Item_Id__c  from Product2</value>
    </values>
    <values>
        <field>Pricing_Record_Type_Pkl__c</field>
        <value xsi:type="xsd:string">Optane™ SSD</value>
    </values>
    <values>
        <field>Pricing_Record_Type__c</field>
        <value xsi:type="xsd:string">Optane™ SSD</value>
    </values>
    <values>
        <field>Pricing_SearchColumn_Field__c</field>
        <value xsi:type="xsd:string">AND Name Like &apos;{{searchString}}&apos;</value>
    </values>
    <values>
        <field>Pricing_Where_Clause__c</field>
        <value xsi:type="xsd:string">where ((Name = &apos;Write In Product&apos;) OR (Core_Sales_Visible_Flag__c = false and IsActive =true AND Core_Product_Status__c &lt;&gt; &apos;RT&apos; AND Core_BU_Operation_Code__c IN (&apos;UD&apos;,&apos;UC&apos;) AND Core_IQR_Visible__c = true))</value>
    </values>
</CustomMetadata>
