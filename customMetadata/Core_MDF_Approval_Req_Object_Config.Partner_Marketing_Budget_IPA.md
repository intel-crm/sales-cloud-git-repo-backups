<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Partner Marketing Budget IPA</label>
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
        <value xsi:type="xsd:string">Budget Status:Core_MDF_Budget_Status__c,Account Node:Core_MDF_Budget_Partner__c:Core_MDF_Budget_Partner__r-Name,Start Date:StartDate,End Date:EndDate,Amount:Amount</value>
    </values>
    <values>
        <field>Core_MDF_Conditional_Field__c</field>
        <value xsi:type="xsd:string">Core_MDF_Budget_Status__c=&quot;Pending Review&quot;</value>
    </values>
    <values>
        <field>Core_MDF_Detail_Field_Properties__c</field>
        <value xsi:type="xsd:string">Budget Name:Title,Owner:OwnerId:Owner-Name,Account Node:Core_MDF_Budget_Partner__c:Core_MDF_Budget_Partner__r-Name,Program:Core_MDF_Program__c:Core_MDF_Program__r-Name,Start Date:StartDate,End Date:EndDate,Total Allocated Amount:TotalAllocatedAmount,Budget Reduction Amount:Core_MDF_Decrease_Budget_Amount_Amt__c</value>
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
        <value xsi:type="xsd:string">Title,Core_MDF_Budget_Status__c,Core_MDF_Budget_Partner__r.Name,StartDate,EndDate,Core_MDF_Budget_Type_Txt__c,Owner.Name,Core_MDF_Program_Nm__c,Amount,Core_MDF_Program__c,TotalAllocatedAmount,Core_MDF_Decrease_Budget_Amount_Amt__c,Core_MDF_Program__r.Name,Core_MDF_Ultimate_Account_Id__c</value>
    </values>
    <values>
        <field>Core_MDF_Fields_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Icon_Name__c</field>
        <value xsi:type="xsd:string">standard:partner_marketing_budget</value>
    </values>
    <values>
        <field>Core_MDF_Navigate_Standard_Page_Ind__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Core_MDF_Object_Label_Name__c</field>
        <value xsi:type="xsd:string">Budget</value>
    </values>
    <values>
        <field>Core_MDF_Object_Name__c</field>
        <value xsi:type="xsd:string">PartnerMarketingBudget</value>
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
        <value xsi:type="xsd:string">Program Name:Core_MDF_Program_Nm__c,Budget Type:Core_MDF_Budget_Type_Txt__c,Start Date:StartDate,End Date:EndDate</value>
    </values>
    <values>
        <field>Core_MDF_Title_Field__c</field>
        <value xsi:type="xsd:string">Title</value>
    </values>
</CustomMetadata>
