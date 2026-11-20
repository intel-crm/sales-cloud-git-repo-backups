<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_Entitlement_RDC_Added_E_Moss_EA</fullName>
        <ccEmails>rdcentitlement@fusionmedia.com</ccEmails>
        <description>Entitlement RDC Added E Moss EA</description>
        <protected>false</protected>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Testt/Core_Entitlement_RDC_Added_E_Moss_Role</template>
    </alerts>
    <alerts>
        <fullName>Core_Entitlement_RDC_Removed_E_Moss_EA</fullName>
        <ccEmails>rdcentitlement@fusionmedia.com</ccEmails>
        <description>Entitlement RDC Removed E Moss EA</description>
        <protected>false</protected>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Testt/Core_Entitlement_RDC_Removed_E_Moss_Role</template>
    </alerts>
    <alerts>
        <fullName>Core_Entitlement_RDC_Updated_E_Moss_EA</fullName>
        <ccEmails>rdcentitlement@fusionmedia.com</ccEmails>
        <description>Entitlement RDC Updated E Moss EA</description>
        <protected>false</protected>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Testt/Core_Entitlement_RDC_Updated_E_Moss_Role</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_Capture_Status_Change_DateTime</fullName>
        <field>Core_Status_Change_Date_Time__c</field>
        <formula>now()</formula>
        <name>Capture_Status_Change_DateTime</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Contact_Entitlement_Unique_ID</fullName>
        <field>Core_Unique_Id__c</field>
        <formula>Core_Contact_Id__c + Core_Entitlement_Id__c</formula>
        <name>Core_Contact_Entitlement_Unique_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Reset_DontNotify</fullName>
        <description>Set Notify field on contact entitlement to false.</description>
        <field>Core_DontNotify__c</field>
        <literalValue>0</literalValue>
        <name>Core Reset DontNotify</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Reset_Is_Data_Loaded</fullName>
        <description>Set Is Data Loaded field on contact entitlement to false.</description>
        <field>Core_Data_Loaded__c</field>
        <literalValue>0</literalValue>
        <name>Core Reset Is Data Loaded</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Capture_Contact_Entitlement_Status_Change_DateTime</fullName>
        <actions>
            <name>Core_Capture_Status_Change_DateTime</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow rule will capture the date/time whenever there is an update for the status field.</description>
        <formula>ISCHANGED(Core_Status__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Contact_Entitlement_Prevent_Duplicates</fullName>
        <actions>
            <name>Core_Contact_Entitlement_Unique_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>1=1</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_Disable_DontNotify</fullName>
        <actions>
            <name>Core_Reset_DontNotify</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Core_Contact_Entitlement__c.Core_DontNotify__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Set  Don&apos;t Notify field on the contact entitlement to false if it is set to true. Used to reset field after data load completes.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Disable_Is_Data_Loaded</fullName>
        <actions>
            <name>Core_Reset_Is_Data_Loaded</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Core_Contact_Entitlement__c.Core_Data_Loaded__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Set Is Data Loaded field on the contact entitlement to false if it is set to true.  Used to reset field after data load completes.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>x Entitlement RDC Added E Moss Notification WF</fullName>
        <actions>
            <name>Core_Entitlement_RDC_Added_E_Moss_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>When Contact gets the RDC Collaboration Workspaces need to send an email to the Emoss group. No longer required by RDC team as of 02/26/2020.</description>
        <formula>IF(     AND(Core_Selected__c == TRUE,         ISPICKVAL(Core_Status__c , &apos;Complete&apos;),         Core_Entitlement_Id__c == $Label.Core_Entitlement_RDC_Collab_Workspaces_Id),     TRUE,     FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>x Entitlement RDC Removed E Moss Notification WF</fullName>
        <actions>
            <name>Core_Entitlement_RDC_Removed_E_Moss_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>When Contact gets the RDC Collaboration Workspaces need to send an email to the Emoss group. No longer required by RDC team as of 02/26/2020.</description>
        <formula>IF(     AND(Core_Selected__c == FALSE, ISPICKVAL(Core_Status__c , &apos;Complete&apos;),          Core_Entitlement_Id__c == $Label.Core_Entitlement_RDC_Collab_Workspaces_Id ),     TRUE,     FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>x Entitlement RDC Updated E Moss Notification WF</fullName>
        <actions>
            <name>Core_Entitlement_RDC_Updated_E_Moss_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>When Contact gets the RDC Collaboration Workspaces need to send an email to the Emoss group. This was already Inactive as of 02/26/2020 and also no longer required by RDC team.</description>
        <formula>IF(     AND(Core_Selected__c == TRUE,         ISPICKVAL(Core_Status__c , &apos;Complete&apos;),         Core_Entitlement_Id__c == $Label.Core_Entitlement_RDC_Collab_Workspaces_Id),     TRUE,     FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
