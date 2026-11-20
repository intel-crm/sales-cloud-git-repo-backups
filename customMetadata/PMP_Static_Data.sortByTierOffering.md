<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>sortByTierOffering</label>
    <protected>false</protected>
    <values>
        <field>Value__c</field>
        <value xsi:type="xsd:string">PMP_Featured_Offering_Ind__c DESC,PMP_Offering_Status_Update_Dt__c DESC NULLS LAST, PMP_Company_Id__r.PMP_Badge_Tier_Sequence_Nbr__c, PMP_Company_Id__r.Name</value>
    </values>
</CustomMetadata>
