<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_Lead_Send_Email_To_Partners</fullName>
        <description>Send an email notification when a lead is assigned to partners.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>lms.admin@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_Partner_Lead_Management/Core_Partner_Lead_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Core_Lead_Transfer_SAL</fullName>
        <description>Core_Lead_Transfer_SAL</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/LeadsNewassignmentnotificationSAMPLE</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_Lead_Priority_Cold_Update</fullName>
        <field>Core_Lead_Priority__c</field>
        <literalValue>Cold</literalValue>
        <name>Core_Lead_Priority_Cold_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Priority_Hot_Update</fullName>
        <field>Core_Lead_Priority__c</field>
        <literalValue>Hot</literalValue>
        <name>Core_Lead_Priority_Hot_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Priority_Warm_Update</fullName>
        <field>Core_Lead_Priority__c</field>
        <literalValue>Warm</literalValue>
        <name>Core_Lead_Priority_Warm_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Rating_Field_Update</fullName>
        <description>Change to Hot if criteria met</description>
        <field>Rating</field>
        <literalValue>Hot</literalValue>
        <name>Core_Lead_Rating_Field_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Reset_Lead_State_To_Open</fullName>
        <description>Update the value of &apos;Lead State&apos; field to &quot;Open&quot;.</description>
        <field>Core_Lead_State__c</field>
        <literalValue>Open</literalValue>
        <name>Core_Lead_Reset_Lead_State_To_Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Reset_Rejection_Comments</fullName>
        <description>Resets the field - Rejection Comments</description>
        <field>Core_Rejection_Comments__c</field>
        <name>Core_Lead_Reset_Rejection_Comments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Reset_Rejection_Reason</fullName>
        <description>Resets the field - Rejection Reason</description>
        <field>Core_Rejection__c</field>
        <name>Core_Lead_Reset_Rejection_Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_Address_Flag_To_False</fullName>
        <description>Updates the Address Flag to False since the Address update is done.</description>
        <field>Core_System_Update_Address__c</field>
        <literalValue>0</literalValue>
        <name>Core_Lead_Update Address Flag To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_Address_Flag_To_True</fullName>
        <description>Updates the Address Flag to True so the second workflow can pick this and update the rest of the Address data from Account to Lead.</description>
        <field>Core_System_Update_Address__c</field>
        <literalValue>1</literalValue>
        <name>Core_Lead_Update Address Flag To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_City</fullName>
        <description>Updates the City field of the Lead with the Billing Address City of the related Existing Account.</description>
        <field>City</field>
        <formula>Core_Existing_Covered_Account__r.BillingCity</formula>
        <name>Core_Lead_Update City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_Company</fullName>
        <description>Updates the Company field of the Lead with the Company of the related Existing Account.</description>
        <field>Company</field>
        <formula>Core_Existing_Covered_Account__r.Name</formula>
        <name>Core_Lead_Update Company</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_Country</fullName>
        <description>Updates the Country field of the Lead with the Billing Country of the related Existing Account.</description>
        <field>Country</field>
        <formula>Core_Existing_Covered_Account__r.BillingCountry</formula>
        <name>Core_Lead_Update Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_MQL_Entrance_Date</fullName>
        <field>Core_Entrance_Date_MQL__c</field>
        <formula>NOW()</formula>
        <name>Core_Lead_Update_MQL_Entrance_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_Postal_Code</fullName>
        <description>Updates the Postal Code field of the Lead with the Billing Address Postal Code of the related Existing Account.</description>
        <field>PostalCode</field>
        <formula>Core_Existing_Covered_Account__r.BillingPostalCode</formula>
        <name>Core_Lead_Update Postal Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_Record_Type_To_Lead</fullName>
        <description>Updates the Record Type to the value of Lead.</description>
        <field>RecordTypeId</field>
        <lookupValue>Lead</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Core_Lead_Update_Record_Type_To_Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_SAL_Entrance_Date</fullName>
        <field>Core_Entrance_Date_SAL__c</field>
        <formula>NOW()</formula>
        <name>Core_Lead_Update_SAL_Entrance_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_SQL_Entrance_Date</fullName>
        <field>Core_Entrance_Date_SQL__c</field>
        <formula>NOW()</formula>
        <name>Core_Lead_Update_SQL_Entrance_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_Stage_Change_Date_Time</fullName>
        <description>Update the Lead Stage Date/Time field to now.</description>
        <field>Core_Lead_Stage_Change_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Core_Lead_Update_Stage_Change_Date_Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_State</fullName>
        <description>Updates the State field of the Lead with the Billing Address State of the related Existing Account.</description>
        <field>State</field>
        <formula>Core_Existing_Covered_Account__r.BillingState</formula>
        <name>Core_Lead_Update State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_State_Change_Date_Time</fullName>
        <description>Update the Lead State Date/Time field to now.</description>
        <field>Core_Lead_State_Change_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Core_Lead_Update_State_Change_Date_Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_State_To_Converted</fullName>
        <description>Set the lead State to &apos;Converted&apos;</description>
        <field>Core_Lead_State__c</field>
        <literalValue>Converted</literalValue>
        <name>Core_Lead_Update_State_To_Converted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_Street</fullName>
        <description>Updates the Street field of the Lead with the Billing Address Street of the related Existing Account.</description>
        <field>Street</field>
        <formula>Core_Existing_Covered_Account__r.BillingStreet</formula>
        <name>Core_Lead_Update Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_TAP_Entrance_Date</fullName>
        <field>Core_Entrance_Date_TAP__c</field>
        <formula>NOW()</formula>
        <name>Core_Lead_Update_TAP_Entrance_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_TQL_Entrance_Date</fullName>
        <field>Core_Entrance_Date_TQL__c</field>
        <formula>NOW()</formula>
        <name>Core_Lead_Update_TQL_Entrance_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Update_Unqualified_Entrance_Da</fullName>
        <field>Core_Entrance_Date_Unqualified__c</field>
        <formula>NOW()</formula>
        <name>Core_Lead_Update_Unqualified_Entrance_Da</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Reset_State_Entrance_Date_Accepted</fullName>
        <description>Sets the State Entrance Date - Accepted to NULL</description>
        <field>Core_State_Entrance_Date_Accepted__c</field>
        <name>Core_Reset_State_Entrance_Date_Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Reset_State_Entrance_Date_Engaged</fullName>
        <description>Sets the State Entrance Date - Engaged to NULL</description>
        <field>Core_State_Entrance_Date_Engaged__c</field>
        <name>Core_Reset_State_Entrance_Date_Engaged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Reset_State_Entrance_Date_OnHold</fullName>
        <description>Sets the State Entrance Date - On Hold to NULL</description>
        <field>Core_State_Entrance_Date_OnHold__c</field>
        <name>Core_Reset_State_Entrance_Date_OnHold</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Reset_State_Entrance_Date_Rejected</fullName>
        <description>Sets the State Entrance Date - Rejected to NULL</description>
        <field>Core_State_Entrance_Date_Rejected__c</field>
        <name>Core_Reset_State_Entrance_Date_Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_MQL_Lead_Coverage</fullName>
        <field>Core_Locked_MQL_Coverage__c</field>
        <formula>IF(TEXT(PRIORVALUE(Status))=&quot;Marketing Qualified Lead&quot;, (IF(ISBLANK (TEXT(Owner:User.Core_User_Coverage__c)),&apos;Other&apos;,TEXT(Owner:User.Core_User_Coverage__c))),Core_Locked_MQL_Coverage__c)</formula>
        <name>Update MQL Lead Coverage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_SAL</fullName>
        <field>Core_Locked_SAL_Coverage__c</field>
        <formula>IF(TEXT(PRIORVALUE(Status))=&quot;Sales Accepted Lead&quot;,  (IF(ISBLANK (TEXT(Owner:User.Core_User_Coverage__c)),&apos;Other&apos;,TEXT(Owner:User.Core_User_Coverage__c))),Core_Locked_SAL_Coverage__c)</formula>
        <name>Update SAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_SQL</fullName>
        <field>Core_Locked_SQL_Coverage__c</field>
        <formula>IF(ISPICKVAL(Status,&apos;Sales Qualified Lead&apos;), (IF(ISBLANK (TEXT(Owner:User.Core_User_Coverage__c)),&apos;Other&apos;,TEXT(Owner:User.Core_User_Coverage__c))), Core_Locked_SQL_Coverage__c)</formula>
        <name>Update SQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_State_Entrance_Date_Accepted</fullName>
        <description>Sets the State Entrance Date - Accepted to NOW()</description>
        <field>Core_State_Entrance_Date_Accepted__c</field>
        <formula>NOW()</formula>
        <name>Core_Update_State_Entrance_Date_Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_State_Entrance_Date_Engaged</fullName>
        <description>Sets the State Entrance Date - Engaged to NOW()</description>
        <field>Core_State_Entrance_Date_Engaged__c</field>
        <formula>NOW()</formula>
        <name>Core_Update_State_Entrance_Date_Engaged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_State_Entrance_Date_OnHold</fullName>
        <description>Sets the State Entrance Date - OnHold to NOW()</description>
        <field>Core_State_Entrance_Date_OnHold__c</field>
        <formula>NOW()</formula>
        <name>Core_Update_State_Entrance_Date_OnHold</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_State_Entrance_Date_Open</fullName>
        <description>Sets the State Entrance Date - Open to NOW()</description>
        <field>Core_State_Entrance_Date_Open__c</field>
        <formula>NOW()</formula>
        <name>Core_Update_State_Entrance_Date_Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_State_Entrance_Date_Rejected</fullName>
        <description>Sets the State Entrance Date - Rejected to NOW()</description>
        <field>Core_State_Entrance_Date_Rejected__c</field>
        <formula>NOW()</formula>
        <name>Core_Update_State_Entrance_Date_Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_TQL</fullName>
        <field>Core_Locked_TQL_Coverage__c</field>
        <formula>IF(ISPICKVAL(Status,&apos;Tele Qualified Lead&apos;), (IF(ISBLANK (TEXT(Owner:User.Core_User_Coverage__c)),&apos;Other&apos;,TEXT(Owner:User.Core_User_Coverage__c))), Core_Locked_TQL_Coverage__c)</formula>
        <name>Update TQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_TQL_Lead_Coverage</fullName>
        <field>Core_Locked_TQL_Coverage__c</field>
        <formula>IF(TEXT(PRIORVALUE(Status))=&quot;Tele Qualified Lead&quot;, (IF(ISBLANK (TEXT(Owner:User.Core_User_Coverage__c)),&apos;Other&apos;,TEXT(Owner:User.Core_User_Coverage__c))),Core_Locked_TQL_Coverage__c)</formula>
        <name>Update TQL Lead Coverage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Unqualified_Lead_Coverage</fullName>
        <field>Core_Locked_Unqualified_Coverage__c</field>
        <formula>IF(TEXT(PRIORVALUE(Status))=&quot;Unqualified&quot;,  (IF(ISBLANK (TEXT(Owner:User.Core_User_Coverage__c)),&apos;Other&apos;,TEXT(Owner:User.Core_User_Coverage__c))),Core_Locked_Unqualified_Coverage__c)</formula>
        <name>Update Unqualified Lead Coverage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_Lead_Create_TQL</fullName>
        <actions>
            <name>Core_Lead_Reset_Lead_State_To_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_Record_Type_To_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Reset_State_Entrance_Date_Accepted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Reset_State_Entrance_Date_Engaged</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Reset_State_Entrance_Date_OnHold</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Reset_State_Entrance_Date_Rejected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_State_Entrance_Date_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Converts a Prospect to a Lead.
Resets the value of &apos;Lead State&apos; to &apos;Open&apos;. 
Sets the &apos;State Entrance Date - Open&apos; to current date. 
Resets all the other State Entrance Dates.</description>
        <formula>AND ( ISCHANGED(Status), ISPICKVAL(Status, &apos;Tele Qualified Lead&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Lead Rating</fullName>
        <actions>
            <name>Core_Lead_Rating_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Core_Lead_Conversion_Point__c</field>
            <operation>equals</operation>
            <value>cNDA Request</value>
        </criteriaItems>
        <description>Set Rating to Hot based on criteria</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Priority_Cold</fullName>
        <actions>
            <name>Core_Lead_Priority_Cold_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Core_Lead_Score__c</field>
            <operation>lessOrEqual</operation>
            <value>5</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Priority_Hot</fullName>
        <actions>
            <name>Core_Lead_Priority_Hot_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Core_Lead_Score__c</field>
            <operation>greaterOrEqual</operation>
            <value>10</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Priority_Warm</fullName>
        <actions>
            <name>Core_Lead_Priority_Warm_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Core_Lead_Score__c</field>
            <operation>greaterThan</operation>
            <value>5</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Core_Lead_Score__c</field>
            <operation>lessThan</operation>
            <value>10</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Reset_Lead_State</fullName>
        <actions>
            <name>Core_Lead_Reset_Lead_State_To_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Reset_Rejection_Comments</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Reset_Rejection_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Reset_State_Entrance_Date_Accepted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Reset_State_Entrance_Date_Engaged</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Reset_State_Entrance_Date_OnHold</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Reset_State_Entrance_Date_Rejected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_State_Entrance_Date_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Resets the value of &apos;Lead State&apos; to &apos;Open&apos;.
Resets Rejection Reason, Rejection Comments.
Sets the &apos;State Entrance Date - Open&apos; to current date.
Resets all the other State Entrance Dates.</description>
        <formula>ISCHANGED (OwnerId)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Reset_Rejection_Data</fullName>
        <actions>
            <name>Core_Lead_Reset_Rejection_Comments</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Reset_Rejection_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to reset the Rejection Reason, Rejection Comments.</description>
        <formula>AND ( ISCHANGED(Core_Lead_State__c), NOT(ISPICKVAL(Core_Lead_State__c, &apos;Rejected&apos;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Send_Email_To_Partners</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.CreatedById</field>
            <operation>contains</operation>
            <value>Eloqua</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Core_Notify_Owner__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Workflow to send Email Notification to Partners when a new lead is assigned.</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_Lead_Send_Email_To_Partners</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Lead.Core_System_Email_Trigger_Time__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Core_Lead_Send_Email_To_Partners_On_Owner_Change</fullName>
        <actions>
            <name>Core_Lead_Send_Email_To_Partners</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workflow to send Email Notification to Partners when a lead is re-assigned from &apos;Invalid Partner Queue&apos; to another Partner Queue.</description>
        <formula>AND  (  ISCHANGED(OwnerId),  PRIORVALUE(OwnerId) = $Label.Core_Partner_Invalid_Queue_Id,  CONTAINS(Owner:Queue.DeveloperName, &quot;Core_PTNR&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_Accepted_Entrance</fullName>
        <actions>
            <name>Core_Update_State_Entrance_Date_Accepted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Captures the date/time when Lead State changes to Accepted.</description>
        <formula>AND  (  ISBLANK (Core_State_Entrance_Date_Accepted__c), OR(ISNEW(), ISCHANGED(Core_Lead_State__c)),  ISPICKVAL (Core_Lead_State__c, &quot;Accepted&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_Engaged_Entrance</fullName>
        <actions>
            <name>Core_Update_State_Entrance_Date_Engaged</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Captures the date/time when Lead State changes to Engaged.</description>
        <formula>AND  (  ISBLANK (Core_State_Entrance_Date_Engaged__c), OR(ISNEW(), ISCHANGED(Core_Lead_State__c)),   ISPICKVAL (Core_Lead_State__c, &quot;Engaged&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_MQL_Entrance</fullName>
        <actions>
            <name>Core_Lead_Update_MQL_Entrance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISNULL(Core_Entrance_Date_MQL__c), ISPICKVAL(Status,&quot;Marketing Qualified Lead&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_OnHold_Entrance</fullName>
        <actions>
            <name>Core_Update_State_Entrance_Date_OnHold</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Captures the date/time when Lead State changes to On Hold.</description>
        <formula>AND  (  ISBLANK (Core_State_Entrance_Date_OnHold__c), OR(ISNEW(), ISCHANGED(Core_Lead_State__c)), ISPICKVAL (Core_Lead_State__c, &quot;On Hold&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_Open_Entrance</fullName>
        <actions>
            <name>Core_Reset_State_Entrance_Date_Accepted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Reset_State_Entrance_Date_Engaged</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Reset_State_Entrance_Date_OnHold</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Reset_State_Entrance_Date_Rejected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_State_Entrance_Date_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Captures the date/time when Lead State changes to Open.</description>
        <formula>AND  (  ISBLANK (Core_State_Entrance_Date_Open__c), OR(ISNEW(), ISCHANGED(Core_Lead_State__c)),   ISPICKVAL (Core_Lead_State__c, &quot;Open&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_Rejected_Entrance</fullName>
        <actions>
            <name>Core_Update_State_Entrance_Date_Rejected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Captures the date/time when Lead State changes to Rejected.</description>
        <formula>AND ( ISBLANK (Core_State_Entrance_Date_Rejected__c), OR(ISNEW(), ISCHANGED(Core_Lead_State__c)),  ISPICKVAL (Core_Lead_State__c, &quot;Rejected&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_SAL_Entrance</fullName>
        <actions>
            <name>Core_Lead_Update_SAL_Entrance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISNULL(Core_Entrance_Date_SAL__c), ISPICKVAL(Status,&quot;Sales Accepted Lead&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_SQL_Entrance</fullName>
        <actions>
            <name>Core_Lead_Update_SQL_Entrance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISBLANK(Core_Entrance_Date_SQL__c),  ISPICKVAL(Status,&quot;Sales Qualified Lead&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_TAP_Entrance</fullName>
        <actions>
            <name>Core_Lead_Update_TAP_Entrance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( ISNULL(Core_Entrance_Date_TAP__c),  ISPICKVAL(Status,&quot;Tele Accepted Prospect&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_TQL_Entrance</fullName>
        <actions>
            <name>Core_Lead_Update_TQL_Entrance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( ISNULL(Core_Entrance_Date_TQL__c),  ISPICKVAL(Status,&quot;Tele Qualified Lead&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_Unqualified_Entrance</fullName>
        <actions>
            <name>Core_Lead_Update_Unqualified_Entrance_Da</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISNULL(Core_Entrance_Date_Unqualified__c),  ISPICKVAL(Status,&quot;Unqualified&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Transfer_SAL</fullName>
        <actions>
            <name>Core_Lead_Transfer_SAL</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND((ISCHANGED(  OwnerId  )),  ISPICKVAL( Status, &quot;Sales Accepted Lead&quot; ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Update_Address_From_Existing_Account</fullName>
        <actions>
            <name>Core_Lead_Update_Address_Flag_To_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_Company</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_Postal_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Core_System_Update_Address__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates the Address value, Company name from Existing Account to the Lead Object.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Update_Country_From_Existing_Account</fullName>
        <actions>
            <name>Core_Lead_Update_Address_Flag_To_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Country value from Existing Account to the Lead Object. Sets the &apos;System Update Address&apos; to True so rest of the Address can be updated in the second workflow Core_Lead_Update_Address_From_Existing_Account.</description>
        <formula>OR (  AND ( ISNEW(),  NOT (ISBLANK(Core_Existing_Covered_Account__c)) ), AND ( ISCHANGED(Core_Existing_Covered_Account__c),  NOT (ISBLANK(Core_Existing_Covered_Account__c)) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Update_Stage_Changed_Date_Time</fullName>
        <actions>
            <name>Core_Lead_Update_Stage_Change_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the date/time when the Lead Stage had last changed.</description>
        <formula>ISCHANGED(Status)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Update_State_Changed_Date_Time</fullName>
        <actions>
            <name>Core_Lead_Update_State_Change_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the date/time when the Lead State had last changed.</description>
        <formula>ISCHANGED(Core_Lead_State__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Update_State_On_Conversion</fullName>
        <actions>
            <name>Core_Lead_Update_State_To_Converted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updating the lead state (Custom Field) to Converted when the lead is converted</description>
        <formula>IsConverted = True</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Stamp_Coverage_For_Stage_SAL_MQL_Unqualified</fullName>
        <actions>
            <name>Core_Update_MQL_Lead_Coverage</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_SAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_TQL_Lead_Coverage</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Unqualified_Lead_Coverage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( OR( ISNEW(), ISCHANGED(Status) ), LEFT(OwnerId, 3) = &apos;005&apos;, OR( TEXT(PRIORVALUE(Status))=&quot;Unqualified&quot;, TEXT(PRIORVALUE(Status))=&quot;Sales Accepted Lead&quot;, TEXT(PRIORVALUE(Status))=&quot;Marketing Qualified Lead&quot;, TEXT(PRIORVALUE(Status))=&quot;Tele Qualified Lead&quot; ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Stamp_Coverage_For_Stage_SQL_TQL</fullName>
        <actions>
            <name>Core_Update_SQL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_TQL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( OR(  ISNEW(),  ISCHANGED(IsConverted)  ),  IsConverted = True, LEFT(Owner:User.Id , 3) = &apos;005&apos;, OR( ISPICKVAL(Status,&quot;Sales Qualified Lead&quot;), ISPICKVAL(Status,&quot;Tele Qualified Lead&quot;) )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
