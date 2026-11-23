<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_CoveredAccount_Notification</fullName>
        <description>Core_CoveredAccount_Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>lms.admin@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_CoveredAccount_Notification</template>
    </alerts>
    <alerts>
        <fullName>Core_Email_Notification_For_Lead_Ownership_Change</fullName>
        <description>Core_Email_Notification_For_Lead_Ownership_Change</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>lms.admin@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_Email_notification_for_lead_ownership_change</template>
    </alerts>
    <alerts>
        <fullName>Core_Lead_Send_Email_To_Partners</fullName>
        <description>Send an email notification when a lead is assigned to partners.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_Partner_Lead_Management/Core_Send_Email_To_PSG_Leads</template>
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
    <alerts>
        <fullName>Core_MAQL_SLA_Expired_Alert</fullName>
        <description>Core_MAQL_SLA_Expired Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>11983792@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>12139184@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>vikramx.dharane@intel.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>lms.admin@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/MAQL_SLA_EXPIRED</template>
    </alerts>
    <alerts>
        <fullName>Core_SAL_SLAEmail</fullName>
        <description>Core_SAL_SLAEmail</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>lms.admin@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/SAL_SLA_Expired</template>
    </alerts>
    <alerts>
        <fullName>Core_TAL_SLA_Expired_Alert</fullName>
        <description>Core_TAL_SLA_Expired Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>11983792@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>12139184@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>vikramx.dharane@intel.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>lms.admin@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/TAL_SLA_Expired</template>
    </alerts>
    <alerts>
        <fullName>Core_TQL_SLA_Expired_Alert</fullName>
        <ccEmails>navitax.junghare@intel.com,vikramx.dharane@intel.com</ccEmails>
        <description>Core_TQL_SLA_Expired Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>12139184@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>lms.admin@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/TQL_SLA_Expired</template>
    </alerts>
    <alerts>
        <fullName>MQL_In_Contact_SLA</fullName>
        <description>MQL_In_Contact_SLA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/MQL_In_Contact_SLA</template>
    </alerts>
    <alerts>
        <fullName>MQL_Qualified_Lead_not_in_SAL</fullName>
        <description>MQL_Qualified_Lead_not_in_SAL</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/MQL_Qualified_Lead_not_in_SAL</template>
    </alerts>
    <alerts>
        <fullName>SAL_Not_Converted_in_30_days</fullName>
        <description>SAL_Not_Converted_in_30_days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/SAL_Not_Converted_in_30_days</template>
    </alerts>
    <alerts>
        <fullName>SGL_Not_Contacted_in_21_days</fullName>
        <description>SGL_Not_Contacted_in_21_days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/SGL_Not_Contacted_in_21_days</template>
    </alerts>
    <alerts>
        <fullName>SGL_Not_Converted_in_30_days</fullName>
        <description>SGL_Not_Converted_in_30_days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/SGL_Not_Converted_in_30_days</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_Clear_Lead_Share_Error</fullName>
        <field>Core_Lead_Sharing_Error__c</field>
        <name>Clear Lead Share Error</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Clear_Lead_Share_Flag</fullName>
        <field>Core_Is_Lead_Shared__c</field>
        <literalValue>0</literalValue>
        <name>Clear Lead Share Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Clear_MPI_Id</fullName>
        <field>Core_MPI_Id__c</field>
        <name>Clear MPI Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Clear_Public_Group</fullName>
        <field>Core_Public_Group_Id__c</field>
        <name>Clear Public Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Conatct_No_Opportunity_Entrance</fullName>
        <field>Core_EntranceDate_Contact_No_Opportunity__c</field>
        <formula>IF(
AND(
 IsConverted = true,
 ISPICKVAL(Status, &apos;Contact - No Opportunity&apos;),
 ISPICKVAL(Core_Lead_Status__c, &apos;Disqualified&apos;)
),NOW(),null)</formula>
        <name>Core_Conatct-No Opportunity_Entrance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Coverage_MAQL_FastTrack1</fullName>
        <field>Core_Locked_TAL_Coverage__c</field>
        <formula>IF(AND (TEXT(PRIORVALUE(Status))=&quot;Marketing Qualified Lead&quot;, ISPICKVAL(Status, &quot;Sales Accepted Lead&quot;), RecordType.Name = &quot;Lead&quot; ), (IF(ISBLANK (TEXT(Owner:User.Core_User_Coverage__c)),&apos;Other&apos;,TEXT(Owner:User.Core_User_Coverage__c))),Core_Locked_TAL_Coverage__c)</formula>
        <name>Core_Coverage_MAQL_FastTrack1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Coverage_MAQL_FastTrack2</fullName>
        <field>Core_Locked_TQL_Coverage__c</field>
        <formula>IF(AND (TEXT(PRIORVALUE(Status))=&quot;Marketing Qualified Lead&quot;, ISPICKVAL(Status, &quot;Sales Accepted Lead&quot;), RecordType.Name = &quot;Lead&quot; ), (IF(ISBLANK (TEXT(Owner:User.Core_User_Coverage__c)),&apos;Other&apos;,TEXT(Owner:User.Core_User_Coverage__c))),Core_Locked_TQL_Coverage__c)</formula>
        <name>Core_Coverage_MAQL_FastTrack2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Coverage_TAL_SAL_FastTrack</fullName>
        <field>Core_Locked_TQL_Coverage__c</field>
        <formula>IF(AND (TEXT(PRIORVALUE(Status))=&quot;Tele Accepted Lead&quot;, ISPICKVAL(Status, &quot;Sales Accepted Lead&quot;)), (IF(ISBLANK (TEXT(Owner:User.Core_User_Coverage__c)),&apos;Other&apos;,TEXT(Owner:User.Core_User_Coverage__c))),Core_Locked_TQL_Coverage__c)</formula>
        <name>Core_Coverage_TAL_SAL_FastTrack</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Entrace_Date_PAL_partner</fullName>
        <field>Core_PAL_Entry_Dt__c</field>
        <formula>Now()</formula>
        <name>Entrace Date-PAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_EntranceDate_Contact_No_Opportunity</fullName>
        <field>Core_EntranceDate_Contact_No_Opportunity__c</field>
        <formula>Now()</formula>
        <name>Entrance Date – Contact – No Opportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_EntranceDate_TAL</fullName>
        <field>Core_Entrance_Date_TAL__c</field>
        <formula>Now()</formula>
        <name>Core_EntranceDate_TAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_EntranceDate_TAP</fullName>
        <field>Core_Entrance_Date_TAP__c</field>
        <formula>Now()</formula>
        <name>Core_EntranceDate_TAP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Entrance_Date_SAL</fullName>
        <field>Core_Entrance_Date_SAL__c</field>
        <formula>Now()</formula>
        <name>Entrance Date - SAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Entrance_Date_TAL</fullName>
        <field>Core_Entrance_Date_TAL__c</field>
        <formula>Now()</formula>
        <name>Entrance Date - TAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Entrance_Date_TAP</fullName>
        <field>Core_Entrance_Date_TAP__c</field>
        <formula>Now()</formula>
        <name>Entrance Date - TAP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Entrance_Date_TQL</fullName>
        <field>Core_Entrance_Date_TQL__c</field>
        <formula>Now()</formula>
        <name>Entrance Date - TQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Entrancee_Date_SAL</fullName>
        <field>Core_Entrance_Date_SAL__c</field>
        <formula>Now()</formula>
        <name>Entrance Date - SAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Entrancee_Date_TQL</fullName>
        <field>Core_Entrance_Date_TQL__c</field>
        <formula>Now()</formula>
        <name>Entrance Date - TQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exit_Date_MAQL</fullName>
        <field>Core_Exit_Date_MAQL__c</field>
        <formula>Now()</formula>
        <name>Exit Date - MAQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exit_Date_MAQL_c</fullName>
        <field>Core_Exit_Date_MAQL__c</field>
        <formula>NOW()</formula>
        <name>Core_Exit_Date_MAQL__c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exit_Date_SAL_c</fullName>
        <field>Core_Exit_Date_SAL__c</field>
        <formula>Now()</formula>
        <name>Core_Exit_Date_SAL__c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exit_Date_SQL</fullName>
        <field>Core_Exit_Date_SQL__c</field>
        <formula>Now()</formula>
        <name>Exit Date - SQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exit_Date_TAL</fullName>
        <field>Core_Exit_Date_TAL__c</field>
        <formula>NOW()</formula>
        <name>Exit Date - TAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exit_Date_TAL_c</fullName>
        <field>Core_Exit_Date_TAL__c</field>
        <formula>Now()</formula>
        <name>Core_Exit_Date_TAL__c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exit_Date_TQL</fullName>
        <field>Core_Exit_Date_TQL__c</field>
        <formula>Now()</formula>
        <name>Exit Date - TQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exit_Date_TQL_c</fullName>
        <field>Core_Exit_Date_TQL__c</field>
        <formula>Now()</formula>
        <name>Core_Exit_Date_TQL__c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exit_Datee_TAL</fullName>
        <field>Core_Exit_Date_TAL__c</field>
        <formula>Now()</formula>
        <name>Exit Date - TAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exit_Dateee_SAL</fullName>
        <field>Core_Exit_Date_SAL__c</field>
        <formula>Now()</formula>
        <name>Exit Date - SAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exit_date_PRL</fullName>
        <field>Core_PRL_Exit_Dt__c</field>
        <formula>Now()</formula>
        <name>Exit date PRL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exitt_Date_TQL</fullName>
        <field>Core_Exit_Date_TQL__c</field>
        <formula>Now()</formula>
        <name>Exit Date - TQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exitt_Datee_TAL</fullName>
        <field>Core_Exit_Date_TAL__c</field>
        <formula>IF( ISPICKVAL(Status,&apos;Tele Accepted Lead&apos;) ,Now(),  Core_Exit_Date_TAL__c )</formula>
        <name>Exit Date - TAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Exxit_Datee_SAL</fullName>
        <field>Core_Exit_Date_SAL__c</field>
        <formula>IF( ISPICKVAL(Status,&apos;Sales Accepted Lead&apos;) ,Now(),  Core_Exit_Date_SAL__c )</formula>
        <name>Exit Date - SAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_FieldUpdate_State_Terminated</fullName>
        <field>Core_Lead_State__c</field>
        <literalValue>Terminated</literalValue>
        <name>FieldUpdate State Terminated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_FieldUpdate_State_to_InPursuit</fullName>
        <field>Core_Lead_State__c</field>
        <literalValue>In Pursuit</literalValue>
        <name>FieldUpdate State to InPursuit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Flag_Update_Tasks</fullName>
        <field>Core_Having_Tasks__c</field>
        <literalValue>0</literalValue>
        <name>Core_Flag_Update_Tasks</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Is_Owner_Changed_in_TQL</fullName>
        <field>Core_Ownership_change_in_one_day_TQL__c</field>
        <literalValue>1</literalValue>
        <name>Is Owner Changed in TQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Owner_Update</fullName>
        <field>OwnerId</field>
        <lookupValue>Core_PTNR_Invalid_Partner_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Lead Owner Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
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
        <fullName>Core_Lead_State</fullName>
        <field>Core_Lead_State__c</field>
        <literalValue>Terminated</literalValue>
        <name>Lead State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Lead_Status</fullName>
        <field>Core_Lead_Status__c</field>
        <literalValue>Unreachable</literalValue>
        <name>Lead Status</name>
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
        <fullName>Core_Lead_Update_MAQL_Entrance_Date</fullName>
        <field>Core_Entrance_Date_MAQL__c</field>
        <formula>NOW()</formula>
        <name>Core_Lead_Update_MAQL_Entrance_Date</name>
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
        <fullName>Core_Lead_Update_TAL_Entrance_Date</fullName>
        <field>Core_Entrance_Date_TAL__c</field>
        <formula>NOW()</formula>
        <name>Core_Lead_Update_TAL_Entrance_Date</name>
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
        <fullName>Core_Lead_to_Opportunity_flag</fullName>
        <field>Core_Lead_to_Opportunity_Conversion_flag__c</field>
        <literalValue>1</literalValue>
        <name>Lead_to_Opportunity_flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Previous_Revive_Date</fullName>
        <field>Core_Lead_Revive_Date_Most_Recent__c</field>
        <formula>PRIORVALUE(Core_Lead_Revive_Date_Original__c)</formula>
        <name>Core_Previous_Revive_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Priority_Update</fullName>
        <description>Update the Lead Priority as Warm while cloning</description>
        <field>Core_Lead_Priority__c</field>
        <literalValue>Warm</literalValue>
        <name>Core_Priority_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Recordtype_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Sales_Lead</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Recordtype Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Rejected_Flag</fullName>
        <field>Core_Rejected_Flag__c</field>
        <literalValue>0</literalValue>
        <name>Core_Rejected_Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
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
        <fullName>Core_SQL_Converted_User</fullName>
        <field>Core_SQL_Converted_User__c</field>
        <formula>$User.FirstName +&apos; &apos;+$User.LastName</formula>
        <name>SQL Converted User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Stage_MAQL</fullName>
        <field>Core_Exit_Date_MAQL__c</field>
        <formula>IF(
AND(
 ISPICKVAL(Status, &apos;Marketing Qualified Lead&apos;),
 OR(
  ISPICKVAL(Core_Lead_Status__c, &apos;Disqualified&apos;),
  ISPICKVAL(Core_Lead_Status__c, &apos;Rejected&apos;)
 )
),NOW(),
IF(
 AND(
  ISPICKVAL(Status, &apos;Marketing Qualified Lead&apos;),
  OR(
   ISPICKVAL(Core_Lead_Status__c, &apos;New&apos;),
   ISPICKVAL(Core_Lead_Status__c, &apos;Accepted&apos;),
   ISPICKVAL(Core_Lead_Status__c, &apos;Qualified&apos;)
  )
 ),null,Core_Exit_Date_MAQL__c)
)</formula>
        <name>Core_Stage-MAQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Stage_SAL</fullName>
        <field>Core_Exit_Date_SAL__c</field>
        <formula>IF(
OR(
 AND(
 IsConverted = true, 
 ISPICKVAL(Status, &apos;Contact - No Opportunity&apos;), 
 ISPICKVAL(Core_Lead_Status__c, &apos;Disqualified&apos;) 
 ),
 AND(
  ISPICKVAL(Status, &apos;Sales Accepted Lead&apos;),
  OR(
   ISPICKVAL(Core_Lead_Status__c, &apos;Disqualified&apos;),
   ISPICKVAL(Core_Lead_Status__c, &apos;Rejected&apos;),
   ISPICKVAL(Core_Lead_Status__c, &apos;Unreachable&apos;),
   ISPICKVAL(Core_Lead_Status__c, &apos;Passed to Partner&apos;)
  )
)),NOW(),
IF(
 AND(
  ISPICKVAL(Status, &apos;Sales Accepted Lead&apos;),
  OR(
   ISPICKVAL(Core_Lead_Status__c, &apos;Accepted&apos;),
   ISPICKVAL(Core_Lead_Status__c, &apos;Qualified&apos;)
  )
 ),null,Core_Exit_Date_SAL__c)
)</formula>
        <name>Core_Stage-SAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Stage_TAL</fullName>
        <field>Core_Exit_Date_TAL__c</field>
        <formula>IF(
AND(
 ISPICKVAL(Status, &apos;Tele Accepted Lead&apos;),
 OR(
  ISPICKVAL(Core_Lead_Status__c, &apos;Disqualified&apos;),
  ISPICKVAL(Core_Lead_Status__c, &apos;Rejected&apos;),
  ISPICKVAL(Core_Lead_Status__c, &apos;Passed to Partner&apos;)
 )
),NOW(),
IF(
 AND(
  ISPICKVAL(Status, &apos;Tele Accepted Lead&apos;),
  OR(
   ISPICKVAL(Core_Lead_Status__c, &apos;Accepted&apos;),
   ISPICKVAL(Core_Lead_Status__c, &apos;Qualified&apos;)
  )
 ),null,Core_Exit_Date_TAL__c)
)</formula>
        <name>Core_Stage-TAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Stage_TQL</fullName>
        <field>Core_Exit_Date_TQL__c</field>
        <formula>IF(
AND(
 ISPICKVAL(Status, &apos;Tele Qualified Lead&apos;),
 OR(
  ISPICKVAL(Core_Lead_Status__c, &apos;Disqualified&apos;),
  ISPICKVAL(Core_Lead_Status__c, &apos;Rejected&apos;),
  ISPICKVAL(Core_Lead_Status__c, &apos;Passed to Partner&apos;)
 )
),NOW(),
IF(
 AND(
  ISPICKVAL(Status, &apos;Tele Qualified Lead&apos;),
  OR(
   ISPICKVAL(Core_Lead_Status__c, &apos;Accepted&apos;),
   ISPICKVAL(Core_Lead_Status__c, &apos;Qualified&apos;)
  )
 ),null,Core_Exit_Date_TQL__c)
)</formula>
        <name>Core_Stage-TQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Stamp_Entrance_Date_Terminated</fullName>
        <field>Core_Lead_Rejected_Dt__c</field>
        <formula>NOW()</formula>
        <name>Stamp Entrance Date – Terminated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Stamp_Lead_Id</fullName>
        <field>Core_lead_Id__c</field>
        <formula>Id</formula>
        <name>Stamping Lead Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Stamp_Partner_Lead_Id</fullName>
        <field>Core_lead_Id__c</field>
        <formula>Id</formula>
        <name>Stamping Lead Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Uncheck_Opp_Conversion_Flag</fullName>
        <field>Core_Lead_to_Opportunity_Conversion_flag__c</field>
        <literalValue>0</literalValue>
        <name>Core_Uncheck_Opp_Conversion_Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Uncheck_Remove_Current_Sharing</fullName>
        <field>Core_Remove_Current_Sharing_Ind__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Remove Current Sharing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Unreachable_Stage</fullName>
        <field>Core_Unreachable_Stage__c</field>
        <formula>Text(Status)</formula>
        <name>Unreachable Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Unreachable_Start_Date</fullName>
        <field>Core_Unreachable_Start_Date__c</field>
        <formula>NOW()</formula>
        <name>Unreachable Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Unreachable_flag</fullName>
        <field>Core_Unreachable_flag__c</field>
        <literalValue>1</literalValue>
        <name>Unreachable flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_1st_Reminder</fullName>
        <field>Core_1st_Reminder__c</field>
        <formula>DATEVALUE( CreatedDate ) + 8</formula>
        <name>Update 1st Reminder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_2nd_Reminder</fullName>
        <field>Core_2nd_Reminder__c</field>
        <formula>DATEVALUE( CreatedDate ) + 15</formula>
        <name>Update 2nd Reminder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_3rd_Reminder</fullName>
        <field>Core_3rd_Reminder__c</field>
        <formula>DATEVALUE( CreatedDate ) + 22</formula>
        <name>Update 3rd Reminder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_4th_Reminder</fullName>
        <field>Core_4th_Reminder__c</field>
        <formula>DATEVALUE( CreatedDate ) + 29</formula>
        <name>Update 4th Reminder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Entrance_Date_Contacted</fullName>
        <field>Core_Entrance_Date_Contacted_Dt__c</field>
        <formula>NOW()</formula>
        <name>Update Entrance Date Contacted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Entrance_Date_PQL</fullName>
        <field>Core_PQL_Entry_Dt__c</field>
        <formula>NOW()</formula>
        <name>Update Entrance Date PQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Entrance_Date_PRL</fullName>
        <field>Core_PRL_Entry_Dt__c</field>
        <formula>NOW()</formula>
        <name>Update Entrance Date PRL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Exit_Date_Contact_Contacted</fullName>
        <field>Core_Exit_Date_Contacted_Dt__c</field>
        <formula>NOW()</formula>
        <name>Update Exit Date Contact Contacted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Exit_Date_PAL</fullName>
        <field>Core_PAL_Exit_Dt__c</field>
        <formula>NOW()</formula>
        <name>Update Exit Date PAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Flag_Post_New_Process</fullName>
        <field>Core_Created_Post_NewLead_Process__c</field>
        <literalValue>1</literalValue>
        <name>Update Flag Post New Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Lead_Stage_Eloqua</fullName>
        <field>Status</field>
        <literalValue>PRL</literalValue>
        <name>Update Lead Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Lead_Stage_Rejected</fullName>
        <field>Status</field>
        <literalValue>REJECTED</literalValue>
        <name>Update Lead Stage Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Lead_State_Eloqua</fullName>
        <field>Core_Lead_State__c</field>
        <literalValue>Unclaimed</literalValue>
        <name>Update Lead State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Lead_Status</fullName>
        <field>Core_Lead_Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>Update Lead Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Lead_Status_Eloqua</fullName>
        <field>Core_Lead_Status__c</field>
        <literalValue>New</literalValue>
        <name>Update Lead Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Lead_Status_to_Opportunity</fullName>
        <field>Core_Lead_Status__c</field>
        <literalValue>Opportunity</literalValue>
        <name>Update Status to Opportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
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
        <fullName>Core_Update_New_Partner_Process_field</fullName>
        <field>Core_Created_Post_NewPartnerLead_Process__c</field>
        <literalValue>1</literalValue>
        <name>Update New Process field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
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
        <fullName>Core_Update_Stage</fullName>
        <field>Status</field>
        <literalValue>PAL</literalValue>
        <name>Update Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Stage_to_PAL</fullName>
        <field>Status</field>
        <literalValue>PAL</literalValue>
        <name>Update Stage to PAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Stage_to_PQL</fullName>
        <field>Status</field>
        <literalValue>PQL</literalValue>
        <name>Update Stage to PQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Stage_to_PRL</fullName>
        <field>Status</field>
        <literalValue>PRL</literalValue>
        <name>Update Stage to PRL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
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
        <fullName>Core_Update_State_partner</fullName>
        <field>Core_Lead_State__c</field>
        <literalValue>In Pursuit</literalValue>
        <name>Update State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Status_on_SAL</fullName>
        <field>Core_Lead_Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>Update Status on SAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Status_on_TAL</fullName>
        <field>Core_Lead_Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>Update Status on TAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Status_on_TAL_to_SAL</fullName>
        <field>Core_Lead_Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>Update Status on TAL to SAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Status_on_TQL</fullName>
        <field>Core_Lead_Status__c</field>
        <literalValue>Qualified</literalValue>
        <name>Update Status on TQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Status_on_TQL_To_SAL</fullName>
        <field>Core_Lead_Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>Update Status on SAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_TAL_Lead_Coverage</fullName>
        <field>Core_Locked_TAL_Coverage__c</field>
        <formula>IF(AND(TEXT(PRIORVALUE(Status))=&quot;Tele Accepted Lead&quot;, ISCHANGED(Status)), (IF(ISBLANK (TEXT(Owner:User.Core_User_Coverage__c)),&apos;Other&apos;,TEXT(Owner:User.Core_User_Coverage__c))),Core_Locked_TAL_Coverage__c)</formula>
        <name>Update TAL Lead Coverage</name>
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
        <fullName>Core_Update_Task_flag_on_Lead</fullName>
        <field>Core_Having_Tasks__c</field>
        <literalValue>0</literalValue>
        <name>Update Task flag on Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
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
    <fieldUpdates>
        <fullName>Core_Update_lead_Conversion_Flag</fullName>
        <field>Core_Lead_Conversion_Flag__c</field>
        <formula>&apos;True&apos;</formula>
        <name>Update Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_state</fullName>
        <description>Update the state as In Pursuit</description>
        <field>Core_Lead_State__c</field>
        <literalValue>In Pursuit</literalValue>
        <name>Update State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Entrance_Date_Contact_Established</fullName>
        <field>Core_Contact_Estb_Dt__c</field>
        <formula>NOW()</formula>
        <name>Update Entrance Date Contact Established</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_State_to_Converted</fullName>
        <field>Core_Lead_State__c</field>
        <literalValue>Converted</literalValue>
        <name>Update Lead State to Converted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_Contact_NoOpportunity</fullName>
        <actions>
            <name>Core_Lead_to_Opportunity_flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Sales Accepted Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Core_Lead_Status__c</field>
            <operation>equals</operation>
            <value>Disqualified</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_CoveredAccount_Email_Notification</fullName>
        <actions>
            <name>Core_CoveredAccount_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sending email</description>
        <formula>OR( AND( ISNEW(), RecordType.Name = &quot;Lead&quot;,  ISPICKVAL(Status, &quot;Marketing Qualified Lead&quot;), Core_Covered_account_owner__c=Core_Lead_Owner_Name__c,  Core_Is_Covered_Account__c=true   ), AND( OR(ISCHANGED(Core_Existing_Covered_Account__c), ISCHANGED(OwnerId)), Core_Flag_on_Queue_or_User__c =&quot;User&quot;, RecordType.Name = &quot;Lead&quot;,  ISPICKVAL(Status, &quot;Marketing Qualified Lead&quot;), Core_Covered_account_owner__c=Core_Lead_Owner_Name__c,  Core_Is_Covered_Account__c=true   ), AND( ISNEW(), RecordType.Name = &quot;Sales Lead&quot;,  ISPICKVAL(Status, &quot;Tele Accepted Lead&quot;), Core_Covered_account_owner__c=Core_Lead_Owner_Name__c,  Core_Is_Covered_Account__c=true   ), AND( OR(ISCHANGED(Core_Existing_Covered_Account__c), ISCHANGED(OwnerId)), Core_Flag_on_Queue_or_User__c =&quot;User&quot;, RecordType.Name = &quot;Sales Lead&quot;,  ISPICKVAL(Status, &quot;Tele Accepted Lead&quot;), Core_Covered_account_owner__c=Core_Lead_Owner_Name__c,  Core_Is_Covered_Account__c=true   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Dates_MAQL_to_SAL</fullName>
        <actions>
            <name>Core_Entrance_Date_TAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Entrance_Date_TAP</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Entrancee_Date_SAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Entrancee_Date_TQL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Exit_Date_MAQL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Exit_Datee_TAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Exitt_Date_TQL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Status_on_SAL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Exception Flow : The following fields should be stamped when the Lead Stage changes from &quot;Marketing Qualified Lead&quot; to &quot;Sales Accepted Lead&quot; for Record Type = Lead</description>
        <formula>AND (  ISPICKVAL(PRIORVALUE(Status), &quot;Marketing Qualified Lead&quot;),  ISPICKVAL(Status, &quot;Sales Accepted Lead&quot;),  RecordType.DeveloperName =&apos;Lead&apos;, ISCHANGED(Status ), OR( ISPICKVAL(Core_Lead_Status__c , &quot;New&quot;), ISPICKVAL(Core_Lead_Status__c , &quot;Accepted&quot;) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Dates_TAL_to_SAL</fullName>
        <actions>
            <name>Core_Entrance_Date_SAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Entrance_Date_TQL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Exit_Date_TAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Exit_Date_TQL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Status_on_TAL_to_SAL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Exception Flow : The following fields should be stamped when the Lead Stage changes from &quot;Tele Accepted Lead&quot; to &quot;Sales Accepted Lead&quot; for Record Type = Sales Lead</description>
        <formula>AND (  ISPICKVAL(PRIORVALUE(Status), &quot;Tele Accepted Lead&quot;),  ISPICKVAL(Status, &quot;Sales Accepted Lead&quot;),  RecordType.DeveloperName =&apos;Sales_Lead&apos;, ISCHANGED(Status ), OR( ISPICKVAL(Core_Lead_Status__c , &quot;Accepted&quot;), ISPICKVAL(Core_Lead_Status__c , &quot;Qualified&quot;) )    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Email_Notification_For_LeadOwnership_Change</fullName>
        <actions>
            <name>Core_Email_Notification_For_Lead_Ownership_Change</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>OR( AND( RecordType.DeveloperName =&quot;Lead&quot;, ISPICKVAL( Status, &quot;Marketing Qualified Lead&quot; ), ISCHANGED(OwnerId), Core_Flag_on_Queue_or_User__c =&quot;User&quot;, OR(Core_Covered_account_owner__c &lt;&gt; Core_Lead_Owner_Name__c, Core_Covered_account_owner__c = null) ), AND(  RecordType.DeveloperName =&quot;Sales_Lead&quot;, ISPICKVAL( Status, &quot;Tele Accepted Lead&quot; ), ISCHANGED(OwnerId), Core_Flag_on_Queue_or_User__c =&quot;User&quot;, OR(Core_Covered_account_owner__c &lt;&gt; Core_Lead_Owner_Name__c, Core_Covered_account_owner__c = null) ), AND(  RecordType.DeveloperName = &quot;Lead&quot;, OR(ISPICKVAL( Status, &quot;Tele Accepted Lead&quot; ),ISPICKVAL( Status, &quot;Tele Qualified Lead&quot; ),ISPICKVAL( Status, &quot;Sales Accepted Lead&quot; )), ISCHANGED(OwnerId), Core_Flag_on_Queue_or_User__c =&quot;User&quot; ), AND(  RecordType.DeveloperName = &quot;Sales_Lead&quot;, OR(ISPICKVAL( Status, &quot;Tele Qualified Lead&quot; ),ISPICKVAL( Status, &quot;Sales Accepted Lead&quot; )), ISCHANGED(OwnerId), Core_Flag_on_Queue_or_User__c =&quot;User&quot; ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Entrance Date %E2%80%93 Contact %E2%80%93 No Opportunity</fullName>
        <actions>
            <name>Core_EntranceDate_Contact_No_Opportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Exit_Dateee_SAL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Set when the lead Stage is set to &quot;Contact – No Opportunity&quot; and Lead Status is Disqualified</description>
        <formula>AND(  RecordType.Name &lt;&gt; &apos;Partner Lead&apos;,  ISPICKVAL(Status, &quot;Contact - No Opportunity&quot;),  ISPICKVAL (Core_Lead_Status__c, &quot;Disqualified&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_EntranceDateTAL_forSaleLead</fullName>
        <actions>
            <name>Core_EntranceDate_TAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_EntranceDate_TAP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND ( ISNULL(Core_Entrance_Date_MQL__c), ISNULL(Core_Entrance_Date_TAL__c), ISPICKVAL(Status, &quot;Tele Accepted Lead&quot;), RecordType.Name &lt;&gt;&apos;Partner Lead&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Flag_Update</fullName>
        <actions>
            <name>Core_Flag_Update_Tasks</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISCHANGED(Status)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
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
        <active>false</active>
        <description>Converts a Prospect to a Lead.
Resets the value of &apos;Lead State&apos; to &apos;Open&apos;. 
Sets the &apos;State Entrance Date - Open&apos; to current date. 
Resets all the other State Entrance Dates.</description>
        <failedMigrationToolVersion>252.11.2</failedMigrationToolVersion>
        <formula>AND ( ISCHANGED(Status), ISPICKVAL(Status, &apos;Tele Qualified Lead&apos;), RecordType.Name = &apos;Prospect&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Exit_Date_Stamp</fullName>
        <actions>
            <name>Core_Conatct_No_Opportunity_Entrance</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Stage_MAQL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Stage_SAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Stage_TAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Stage_TQL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(  RecordType.DeveloperName &lt;&gt; &apos;Partner_Lead&apos;,  NOT(ISCHANGED(Status)),  ISCHANGED(Core_Lead_Status__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Lead Rating</fullName>
        <actions>
            <name>Core_Lead_Rating_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Core_Lead_Conversion_Point__c</field>
            <operation>equals</operation>
            <value>cNDA Request</value>
        </criteriaItems>
        <description>Set Rating to Hot based on criteria</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_MAQL_Entrance</fullName>
        <actions>
            <name>Core_Lead_Update_MAQL_Entrance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_MQL_Entrance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISNULL(Core_Entrance_Date_MQL__c), ISPICKVAL( Core_Lead_Status__c ,&quot;New&quot;), ISPICKVAL(Status, &quot;Marketing Qualified Lead&quot;),  RecordType.Name  &lt;&gt;  &apos;Partner Lead&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Priority_Cold</fullName>
        <actions>
            <name>Core_Lead_Priority_Cold_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Lead.Core_Lead_PMP_Action__c</field>
            <operation>notEqual</operation>
            <value>Asked for Follow-Up,Attended Webinar,Requested Quote,Visited Booth</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Lead</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Priority_Hot</fullName>
        <actions>
            <name>Core_Lead_Priority_Hot_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Lead.Core_Lead_PMP_Action__c</field>
            <operation>equals</operation>
            <value>Asked for Follow-Up,Requested Quote</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Lead</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Priority_Warm</fullName>
        <actions>
            <name>Core_Lead_Priority_Warm_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Core_Lead_PMP_Action__c</field>
            <operation>equals</operation>
            <value>Attended Webinar,Visited Booth</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Lead</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Reset_Lead_State_New</fullName>
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
        <active>false</active>
        <description>Resets the value of &apos;Lead State&apos; to &apos;Unclaimed&apos;.
Sets the &apos;State Entrance Date - Open&apos; to current date.
Resets all the other State Entrance Dates.</description>
        <formula>AND(ISCHANGED(OwnerId), RecordType.Name != &quot;Partner Lead&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Send_Email_To_Partners</fullName>
        <active>false</active>
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
        <criteriaItems>
            <field>Lead.Core_PSG_Lead__c</field>
            <operation>equals</operation>
            <value>PSG</value>
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
        <active>false</active>
        <description>Workflow to send Email Notification to Partners when a lead is re-assigned from &apos;Invalid Partner Queue&apos; to another Partner Queue.</description>
        <formula>AND  (  ISCHANGED(OwnerId),  PRIORVALUE(OwnerId) = $Label.Core_Partner_Invalid_Queue_Id,  CONTAINS(Owner:Queue.DeveloperName, &quot;Core_PTNR&quot;), RecordType.Name = &apos;Partner Lead&apos;, ISPICKVAL(Core_PSG_Lead__c , &quot;PSG&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_TQL_Entrance</fullName>
        <actions>
            <name>Core_Exit_Date_TAL_c</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_TQL_Entrance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Status_on_TQL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND (  ISPICKVAL(PRIORVALUE(Status), &quot;Tele Accepted Lead&quot;),  ISPICKVAL(Status, &quot;Tele Qualified Lead&quot;), RecordType.Name &lt;&gt; &apos;Partner Lead&apos;, ISCHANGED(Status ), OR( ISPICKVAL(Core_Lead_Status__c , &quot;Accepted&quot;), ISPICKVAL(Core_Lead_Status__c , &quot;Qualified&quot;) )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_Accepted_Entrance</fullName>
        <actions>
            <name>Core_Update_State_Entrance_Date_Accepted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
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
        <active>false</active>
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
        <active>false</active>
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
        <active>false</active>
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
        <active>false</active>
        <description>Captures the date/time when Lead State changes to Rejected.</description>
        <formula>AND ( ISBLANK (Core_State_Entrance_Date_Rejected__c), OR(ISNEW(), ISCHANGED(Core_Lead_State__c)),  ISPICKVAL (Core_Lead_State__c, &quot;Rejected&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_SAL_Entrance</fullName>
        <actions>
            <name>Core_Exit_Date_TQL_c</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_SAL_Entrance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Status_on_TQL_To_SAL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND (  ISPICKVAL(PRIORVALUE(Status), &quot;Tele Qualified Lead&quot;),  ISPICKVAL(Status, &quot;Sales Accepted Lead&quot;),  RecordType.Name &lt;&gt; &apos;Partner Lead&apos;, ISCHANGED(Status ), OR( ISPICKVAL(Core_Lead_Status__c , &quot;Accepted&quot;), ISPICKVAL(Core_Lead_Status__c , &quot;Qualified&quot;) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_SQL_Entrance</fullName>
        <actions>
            <name>Core_Exit_Date_SAL_c</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Exit_Date_SQL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_SQL_Entrance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( ISBLANK(Core_Entrance_Date_SQL__c), ISCHANGED(IsConverted), IsConverted=true, ISPICKVAL(Status, &quot;Sales Qualified Lead&quot;), RecordType.Name &lt;&gt;&apos;Partner Lead&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Time_TAP_Entrance</fullName>
        <actions>
            <name>Core_Exit_Date_MAQL_c</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_TAL_Entrance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Update_TAP_Entrance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Status_on_TAL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND ( ISPICKVAL(PRIORVALUE(Status), &quot;Marketing Qualified Lead&quot;), ISPICKVAL(Status, &quot;Tele Accepted Lead&quot;), RecordType.Name &lt;&gt;&apos;Partner Lead&apos;, ISCHANGED(Status ),  OR(  ISPICKVAL(Core_Lead_Status__c , &quot;New&quot;),  ISPICKVAL(Core_Lead_Status__c , &quot;Accepted&quot;)  ) )</formula>
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
        <active>false</active>
        <formula>AND(ISNULL(Core_Entrance_Date_Unqualified__c),  ISPICKVAL(Status,&quot;Unqualified&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_Unreachable</fullName>
        <actions>
            <name>Core_Exitt_Datee_TAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Exxit_Datee_SAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Unreachable_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Unreachable_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Unreachable_flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Core_Lead_Status__c</field>
            <operation>equals</operation>
            <value>Unreachable</value>
        </criteriaItems>
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
        <active>false</active>
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
        <active>false</active>
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
        <active>false</active>
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
        <active>false</active>
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
        <active>false</active>
        <description>Updating the lead state (Custom Field) to Converted when the lead is converted</description>
        <formula>IsConverted = True</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Lead_to_Account_Conversion%5F%5FFlagUpdate</fullName>
        <actions>
            <name>Core_Update_lead_Conversion_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>We are using this to validate while converting lead to Comarketing Account Record type</description>
        <formula>OR( AND( OR(RecordType.Name = &quot;Sales Lead&quot;,RecordType.Name=&quot;Lead&quot;), ISPICKVAL(Status, &quot;Sales Accepted Lead&quot;) ), AND( RecordType.Name=&quot;Partner Lead&quot;  ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Opportunity_Conversion_Unlock</fullName>
        <actions>
            <name>Core_Uncheck_Opp_Conversion_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(   RecordType.DeveloperName &lt;&gt; &apos;Partner_Lead&apos;,  OR(   ISCHANGED(Status),   ISCHANGED(Core_Lead_Status__c)  ),  ISPICKVAL(Status, &apos;Sales Accepted Lead&apos;),  ISPICKVAL(Core_Lead_Status__c, &apos;Accepted&apos;),  ISPICKVAL(PRIORVALUE(Core_Lead_Status__c), &apos;Disqualified&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Ownership_Change_Within_One_Business_Day_of_Meeting_Task_TQL</fullName>
        <actions>
            <name>Core_Is_Owner_Changed_in_TQL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Lead Stage = Tele Qualified Lead
If Record is not re-assigned (ownership change) within 1 business day of Meeting Task – Meeting Date (time of the MEETING, not time of the task)</description>
        <formula>AND(  RecordType.DeveloperName &lt;&gt; &quot;Partner_Lead&quot;,  ISCHANGED(OwnerId),  NOT(ISNULL(Core_Meeting_Due_Date__c)),   ISPICKVAL(Status, &apos;Tele Qualified Lead&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_PartnerLead_Default_Values</fullName>
        <actions>
            <name>Core_Update_Lead_Stage_Eloqua</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Lead_State_Eloqua</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Lead_Status_Eloqua</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
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
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_Partner_Claim</fullName>
        <actions>
            <name>Core_Entrace_Date_PAL_partner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Exit_date_PRL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Lead_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_State_partner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(  RecordType.Name = &apos;Partner Lead&apos;,  ISCHANGED(Core_Partner_Lead_Owner__c),  PRIORVALUE(Core_Partner_Lead_Owner__c)=Null,  Core_Partner_Lead_Owner__c &lt;&gt; Null, ISPICKVAL(Core_Lead_Status__c , &quot;New&quot;), NOT(ISPICKVAL(Core_Lead_State__c , &quot;Terminated&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Partner_Lead_Entrance_Date_Contact_Established</fullName>
        <actions>
            <name>Update_Entrance_Date_Contact_Established</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(  NOT(ISNULL(Core_PAL_Entry_Dt__c)), ISNULL( Core_Contact_Estb_Dt__c ), RecordType.Name = &apos;Partner Lead&apos;,  ISPICKVAL(Status, &quot;PAL&quot;),  ISPICKVAL (Core_Lead_Status__c, &quot;Contacted&quot;), Core_Lead_Contact_Estb_Dt__c = true )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Partner_Lead_Entrance_Date_PQL_Exit_Date_PAL</fullName>
        <actions>
            <name>Core_Update_Entrance_Date_PQL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Exit_Date_Contact_Contacted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Exit_Date_PAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Stage_to_PQL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Lead_State_to_Converted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND (   RecordType.Name = &quot;Partner Lead&quot;, ISCHANGED(Core_Lead_Status__c),  ISPICKVAL(Core_Lead_Status__c , &quot;Qualified&quot;), ISPICKVAL(PRIORVALUE(Core_Lead_Status__c), &quot;Contacted&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Partner_Lead_Entrance_Date_PRL</fullName>
        <actions>
            <name>Core_Update_Entrance_Date_PRL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Stage_to_PRL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(  OR (ISNEW(), ISCHANGED(Core_Lead_Status__c)),  ISPICKVAL(Core_Lead_Status__c , &quot;New&quot;),  RecordType.Name = &quot;Partner Lead&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Partner_Lead_Entrance_Datee_Contacted</fullName>
        <actions>
            <name>Core_Update_Entrance_Date_Contacted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(  NOT(ISNULL(Core_PAL_Entry_Dt__c)), ISNULL( Core_Entrance_Date_Contacted_Dt__c ), RecordType.Name = &apos;Partner Lead&apos;,  ISPICKVAL(Status, &quot;PAL&quot;),  ISPICKVAL(PRIORVALUE(Core_Lead_Status__c),&quot;Accepted&quot;), ISPICKVAL(Core_Lead_Status__c, &quot;Contacted&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Reject_PartnerLead_On_Terminated</fullName>
        <actions>
            <name>Core_Stamp_Entrance_Date_Terminated</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Lead_Stage_Rejected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( RecordType.Name = &apos;Partner Lead&apos;, ISCHANGED(Core_Lead_State__c), ISPICKVAL(Core_Lead_State__c, &quot;Terminated&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Reject_flag_update</fullName>
        <actions>
            <name>Core_Previous_Revive_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Rejected_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( ISPICKVAL(Core_Lead_State__c, &quot;In Pursuit&quot;), ISPICKVAL(PRIORVALUE(Core_Lead_State__c), &quot;Terminated&quot;), NOT(ISPICKVAL(PRIORVALUE(Core_Lead_Status__c), &quot;Unreachable&quot;)), ISCHANGED(Core_Lead_State__c), OR(RecordType.Name = &quot;Lead&quot;, RecordType.Name = &quot;Sales Lead&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Remove_Current_Lead_Sharing</fullName>
        <actions>
            <name>Core_Clear_Lead_Share_Error</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Clear_Lead_Share_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Clear_MPI_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Lead_Owner_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Uncheck_Remove_Current_Sharing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISCHANGED( Core_Remove_Current_Sharing_Ind__c ) &amp;&amp;  Core_Remove_Current_Sharing_Ind__c = true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_SAL_Email_Alert_Trigger</fullName>
        <actions>
            <name>Core_SAL_SLAEmail</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>OR(AND(ISCHANGED(Core_SendEmail__c), Core_SendEmail__c = true, RecordType.DeveloperName &lt;&gt; &apos;Partner_Lead&apos;, ISPICKVAL( Status , &apos;Sales Accepted Lead&apos;), ISPICKVAL( Core_Lead_Status__c , &apos;Accepted&apos;), Core_Having_Tasks__c = false, Core_Created_Post_NewLead_Process__c=true, Core_SLA_Listed_User__c = true), AND(ISCHANGED( Core_SendEmail4__c ), Core_SendEmail4__c = true, RecordType.DeveloperName &lt;&gt; &apos;Partner_Lead&apos;, ISPICKVAL( Status , &apos;Sales Accepted Lead&apos;), ISPICKVAL( Core_Lead_Status__c , &apos;Accepted&apos;), Core_Created_Post_NewLead_Process__c=True, Core_SLA_Listed_User__c = true))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_SetReminderDays</fullName>
        <actions>
            <name>Core_Update_1st_Reminder</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_2nd_Reminder</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_3rd_Reminder</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_4th_Reminder</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Lead</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_Stamp_Coverage_For_Stage_SAL_MQL_Unqualified</fullName>
        <actions>
            <name>Core_Coverage_MAQL_FastTrack1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Coverage_MAQL_FastTrack2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Coverage_TAL_SAL_FastTrack</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_MQL_Lead_Coverage</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_SAL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_TAL_Lead_Coverage</name>
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
        <active>false</active>
        <formula>AND( OR( ISNEW(), ISCHANGED(Status) ), LEFT(OwnerId, 3) = &apos;005&apos;, OR( TEXT(PRIORVALUE(Status))=&quot;Unqualified&quot;, TEXT(PRIORVALUE(Status))=&quot;Sales Accepted Lead&quot;, TEXT(PRIORVALUE(Status))=&quot;Marketing Qualified Lead&quot;, TEXT(PRIORVALUE(Status))=&quot;Tele Qualified Lead&quot;,TEXT(PRIORVALUE(Status))=&quot;Tele Accepted Lead&quot; ) )</formula>
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
        <active>false</active>
        <formula>AND( OR(  ISNEW(),  ISCHANGED(IsConverted)  ),  IsConverted = True, LEFT(Owner:User.Id , 3) = &apos;005&apos;, OR( ISPICKVAL(Status,&quot;Sales Qualified Lead&quot;), ISPICKVAL(Status,&quot;Tele Qualified Lead&quot;) )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_TQL_Lead_Ownership_Change_SLA_Email_Alert</fullName>
        <active>false</active>
        <formula>AND( RecordType.DeveloperName &lt;&gt; &quot;Partner_Lead&quot;, Core_Ownership_change_in_one_day_TQL__c =false, Core_Having_Tasks_in_TQL__c=True, Core_SLA_Listed_User__c=True, Core_Created_Post_NewLead_Process__c=True, OR( ISPICKVAL(Core_Lead_Status__c , &quot;Accepted&quot;), ISPICKVAL(Core_Lead_Status__c , &quot;Qualified&quot;) ), ISPICKVAL(Status, &apos;Tele Qualified Lead&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_TQL_SLA_Expired_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Lead.Core_Meeting_date_Weekday_Calculation__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Core_Update_Field_Distinguish_New_Lead_Process</fullName>
        <actions>
            <name>Core_Stamp_Lead_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Flag_Post_New_Process</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>US203595: New Lead Process : New hidden field to distinguish old records from new</description>
        <formula>AND(ISNEW(),OR(RecordType.Name = &quot;Lead&quot;, RecordType.Name = &quot;Sales Lead&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Update_Field_Distinguish_New_PartnerLead_Process</fullName>
        <actions>
            <name>Core_Stamp_Partner_Lead_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_New_Partner_Process_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>New Lead Process : New hidden field to distinguish old records from new</description>
        <formula>AND(ISNEW(), RecordType.Name = &quot;Partner Lead&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Update_Lead_Status_onConvert</fullName>
        <actions>
            <name>Core_SQL_Converted_User</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Lead_Status_to_Opportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.IsConverted</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Sales Qualified Lead</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Update_State_Terminated</fullName>
        <actions>
            <name>Core_FieldUpdate_State_Terminated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update State to Terminated</description>
        <formula>AND( ISCHANGED(Core_Lead_Status__c), OR(ISPICKVAL(Core_Lead_Status__c , &apos;Rejected&apos;) , ISPICKVAL(Core_Lead_Status__c , &apos;Disqualified&apos;) ,  ISPICKVAL(Core_Lead_Status__c , &apos;Passed to Partner&apos;) ,  ISPICKVAL(Core_Lead_Status__c , &apos;Unreachable&apos;)) ,  RecordType.Name &lt;&gt; &apos;Partner Lead&apos; , NOT(ISCHANGED(OwnerId)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Update_State_To_InPursuit</fullName>
        <actions>
            <name>Core_FieldUpdate_State_to_InPursuit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>OR( AND( ISCHANGED(Core_Lead_Status__c), ISPICKVAL(Core_Lead_Status__c , &apos;Accepted&apos;), OR(ISPICKVAL((PRIORVALUE(Core_Lead_Status__c)), &apos;New&apos;),  ISPICKVAL((PRIORVALUE(Core_Lead_Status__c)), &apos;Rejected&apos;),  ISPICKVAL((PRIORVALUE(Core_Lead_Status__c)), &apos;Disqualified&apos;),  ISPICKVAL((PRIORVALUE(Core_Lead_Status__c)), &apos;Passed to Partner&apos;)), RecordType.Name &lt;&gt; &apos;Partner Lead&apos;, NOT(ISCHANGED(OwnerId)) ), AND(  ISCHANGED(Core_Lead_Status__c),  ISPICKVAL(Core_Lead_Status__c , &apos;Qualified&apos;),  OR(  ISPICKVAL((PRIORVALUE(Core_Lead_Status__c)), &apos;Rejected&apos;),  ISPICKVAL((PRIORVALUE(Core_Lead_Status__c)), &apos;Disqualified&apos;),  ISPICKVAL((PRIORVALUE(Core_Lead_Status__c)), &apos;Passed to Partner&apos;)),  RecordType.Name &lt;&gt; &apos;Partner Lead&apos;, NOT(ISCHANGED(OwnerId))  ),  AND(  ISPICKVAL(Status,&apos;Marketing Qualified Lead&apos;),  ISPICKVAL(Core_Lead_Status__c , &apos;New&apos;),  ISPICKVAL((PRIORVALUE(Core_Lead_Status__c)), &apos;Rejected&apos;), RecordType.Name &lt;&gt; &apos;Partner Lead&apos;, NOT(ISCHANGED(OwnerId))  ),  AND( ISCHANGED(OwnerId), LEFT(PRIORVALUE(OwnerId),3) == &apos;00G&apos; , LEFT(OwnerId,3) == &apos;005&apos; , RecordType.Name &lt;&gt; &apos;Partner Lead&apos; )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Update_Task_flag_on_Lead</fullName>
        <actions>
            <name>Core_Update_Task_flag_on_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>OR(AND ( NOT(ISNULL(Core_Entrance_Date_SAL__c)),  Core_Having_Tasks__c=true, RecordType.Name &lt;&gt; &apos;Partner Lead&apos;,ISPICKVAL(PRIORVALUE(Status), &apos;Tele Qualified Lead&apos;)), AND ( Core_Having_Tasks__c=true, ISPICKVAL(Status, &apos;Sales Accepted Lead&apos;) ,RecordType.Name &lt;&gt; &apos;Partner Lead&apos;, ISPICKVAL(PRIORVALUE(Core_Lead_Status__c), &apos;Unreachable&apos;),ISPICKVAL(Core_Lead_Status__c, &apos;Accepted&apos;) ), AND ( Core_Having_Tasks__c=true, ISPICKVAL(Status, &apos;Sales Accepted Lead&apos;) ,RecordType.Name &lt;&gt; &apos;Partner Lead&apos;, ISPICKVAL(PRIORVALUE(Core_Lead_Status__c), &apos;Accepted&apos;),OR(ISPICKVAL(Core_Lead_Status__c, &apos;Qualified&apos;),ISPICKVAL(Core_Lead_Status__c, &apos;Disqualified&apos;) ) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Updatefields_While_Cloning</fullName>
        <actions>
            <name>Core_Priority_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Recordtype_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_state</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update the  stage and status fields while cloning</description>
        <failedMigrationToolVersion>242.3.5</failedMigrationToolVersion>
        <formula>OR( AND(  ISCLONE(), $Profile.Name &lt;&gt; &quot;Eloqua Integrator&quot; ,  $Profile.Name &lt;&gt; &quot;Integration&quot;,$Profile.Name &lt;&gt; &quot;Core Integration&quot; ), AND(  OR(ISNEW(),ISCLONE()), RecordType.Name = &quot;Sales Lead&quot; ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
