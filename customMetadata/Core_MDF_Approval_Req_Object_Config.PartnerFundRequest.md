<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>PartnerFundRequest</label>
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
        <value xsi:type="xsd:string">Activity Status:Core_MDF_Fund_Request_Status__c,Start Date - End Date:Core_MDF_Start_Date_End_Date__c,Activity #:Core_MDF_Activity_Number__c,	
Intel Contribution:Core_MDF_Activity_Reimbursement_Amt_nbr__c,Region:Core_MDF_Host_Region_or_Region_txt__c</value>
    </values>
    <values>
        <field>Core_MDF_Conditional_Field__c</field>
        <value xsi:type="xsd:string">Core_MDF_Fund_Request_Status__c=&apos;Pending Review&apos;</value>
    </values>
    <values>
        <field>Core_MDF_Detail_Field_Properties__c</field>
        <value xsi:type="xsd:string">Program:Core_MDF_Program__c,Account:ChannelPartnerId:ChannelPartner-Name,Campaign:CampaignId:Campaign-Name,Activity Description:Core_MDF_Activity_Description__c,Activity Spending Limit:RequestedAmount,Reimbursement Rate:Core_MDF_Reimbursement_Rate__c,Intel Contribution:Core_MDF_Activity_Reimbursement_Amt_nbr__c,Activity Category:Core_MDF_ActivityCategory__c,Budget Type:Core_MDF_Budget_Type_nm__c,Country/Region:Core_MDF_Country_nm__c,Activity Type:Core_MDF_Activity_Types__c</value>
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
        <value xsi:type="xsd:string">id,Title,Core_MDF_Approval_Stage__c,Core_MDF_Additional_Review_Type_txt__c,ChannelPartnerId,ChannelPartner.Name,Core_MDF_Fund_Request_Status__c,Core_MDF_Sub_Region_nm__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Ultimate_Account_Id__c,Core_MDF_ActivityCategory__c,Core_MDF_Program__c,Core_MDF_UpdateCampaign__c,Core_MDF_Start_Date_End_Date__c,Core_MDF_Region_nm__c,CampaignId,Campaign.Name,Core_MDF_Activity_Number__c,RequestedAmount,Core_MDF_Activity_Types__c,Core_MDF_Activity_Description__c,Core_MDF_Country_nm__c,Core_MDF_Host_Region_txt__c,Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_Host_Region_or_Region_txt__c,Core_MDF_Reimbursement_Rate__c,Core_MDF_Intel_Activity_Owner_txt__c,Core_MDF_Campaign_Ultimate_Account_Id__c</value>
    </values>
    <values>
        <field>Core_MDF_Fields_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Core_MDF_Icon_Name__c</field>
        <value xsi:type="xsd:string">standard:client</value>
    </values>
    <values>
        <field>Core_MDF_Navigate_Standard_Page_Ind__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Core_MDF_Object_Label_Name__c</field>
        <value xsi:type="xsd:string">Co-Marketing Activity</value>
    </values>
    <values>
        <field>Core_MDF_Object_Name__c</field>
        <value xsi:type="xsd:string">PartnerFundRequest</value>
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
        <value xsi:type="xsd:string">Program:Core_MDF_Program__c,Region:Core_MDF_Host_Region_or_Region_txt__c,Start Date - End Date:Core_MDF_Start_Date_End_Date__c,Intel Contribution:Core_MDF_Activity_Reimbursement_Amt_nbr__c,ApprovalStage:Core_MDF_Approval_Stage__c,Intel Owner:Core_MDF_Intel_Activity_Owner_txt__c</value>
    </values>
    <values>
        <field>Core_MDF_Title_Field__c</field>
        <value xsi:type="xsd:string">Title</value>
    </values>
</CustomMetadata>
