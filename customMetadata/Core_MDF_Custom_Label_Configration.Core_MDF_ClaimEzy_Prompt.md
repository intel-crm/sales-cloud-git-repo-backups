<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Core_MDF_ClaimEzy_Prompt</label>
    <protected>false</protected>
    <values>
        <field>Core_MDF_Category_Txt__c</field>
        <value xsi:type="xsd:string">Claim</value>
    </values>
    <values>
        <field>Core_MDF_Org_Specific_Ind__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Core_MDF_Value2_Txt__c</field>
        <value xsi:type="xsd:string">nformation not found return Not Provided for that attribute.If the currency code is not explicitly mentioned look for currency symbol before amount and get currency code accordingly. Invoice Amount should include tax amount also if tax is present. Invoice</value>
    </values>
    <values>
        <field>Core_MDF_Value3_Txt__c</field>
        <value xsi:type="xsd:string">number may also have been mentioned as Activity Number or Bill No in invoice information. Consider Tax attribute if tax is explicitly mentioned only. Invoice Information:&apos;&apos;&apos;{{{rawData}}}&apos;&apos;&apos;.Output Format:Invoice Number: XXX (Replace XXX with the ge</value>
    </values>
    <values>
        <field>Core_MDF_Value4_Txt__c</field>
        <value xsi:type="xsd:string">nerated code)Invoice Amount: $11111 (Replace 11111 with the generated amount)Invoice Date: DD/MM/YYYY (Replace DD with date,MM with month and YYYY with year)Tax: $XXX (Replace XXX with the generated code)Currency Code: XXX(Replace XXX with the generated c</value>
    </values>
    <values>
        <field>Core_MDF_Value5_Txt__c</field>
        <value xsi:type="xsd:string">ode)&quot;}],&quot;temperature&quot;: 0.7,&quot;top_p&quot;: 0.95,&quot;frequency_penalty&quot;: 0,&quot;presence_penalty&quot;: 0,&quot;max_tokens&quot;: 800,&quot;stop&quot;: null}</value>
    </values>
    <values>
        <field>Core_MDF_Value_Txt__c</field>
        <value xsi:type="xsd:string">{&quot;messages&quot;: [{&quot;role&quot;: &quot;system&quot;,&quot;content&quot;:&quot;Please extract the following information from the provided invoice details. Ensure that the output format for each piece of information is as specified. Invoice information is provided in three backticks and if i</value>
    </values>
</CustomMetadata>
