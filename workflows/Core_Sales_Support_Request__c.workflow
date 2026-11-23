<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_Email_IT_Intel_APJ_Email_List</fullName>
        <description>Email IT @ Intel APJ Email List</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_IT_Intel_APJ</recipient>
            <type>group</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>test_m/Core_IT_at_Intel_Approval</template>
    </alerts>
    <alerts>
        <fullName>Core_Email_IT_Intel_ASMO_Email_List</fullName>
        <description>Email IT @ Intel ASMO Email List</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_IT_Intel_ASMO</recipient>
            <type>group</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>test_m/Core_IT_at_Intel_Approval</template>
    </alerts>
    <alerts>
        <fullName>Core_Email_IT_Intel_EMEA_Email_List</fullName>
        <description>Email IT @ Intel EMEA Email List</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_IT_Intel_EMEA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>test_m/Core_IT_at_Intel_Approval</template>
    </alerts>
    <alerts>
        <fullName>Core_Email_IT_Intel_PRC_Email_List</fullName>
        <description>Email IT @ Intel PRC Email List</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_IT_Intel_PRC</recipient>
            <type>group</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>test_m/Core_IT_at_Intel_Approval</template>
    </alerts>
    <alerts>
        <fullName>Core_IT_Intel_Mgr_Assignment</fullName>
        <description>Send e-mail to IT @ Intel Manager</description>
        <protected>false</protected>
        <recipients>
            <field>Core_IT_Geo_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>test_m/Core_IT_Intel_Mgr_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Core_IT_Send_e_mail_to_APJ_Queue</fullName>
        <description>Send e-mail to APJ Queue</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_IT_Intel_APJ</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>test_m/Core_IT_at_Intel_Approval</template>
    </alerts>
    <alerts>
        <fullName>Core_IT_Send_e_mail_to_ASMO_Queue</fullName>
        <description>Send e-mail to ASMO Queue</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_IT_Intel_ASMO</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>test_m/Core_IT_at_Intel_Approval</template>
    </alerts>
    <alerts>
        <fullName>Core_IT_Send_e_mail_to_EMEA_Queue</fullName>
        <description>Send e-mail to EMEA Queue</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_IT_Intel_EMEA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>test_m/Core_IT_at_Intel_Approval</template>
    </alerts>
    <alerts>
        <fullName>Core_IT_Send_e_mail_to_PRC_Queue</fullName>
        <description>Send e-mail to PRC Queue</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_IT_Intel_PRC</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>test_m/Core_IT_at_Intel_Approval</template>
    </alerts>
    <fieldUpdates>
        <fullName>Add_IT_Geo_Manager</fullName>
        <field>Core_IT_Geo_Manager__c</field>
        <name>Add IT Geo Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IT_Intel_Open_Status</fullName>
        <description>Simple Rule to change the status from None to Open</description>
        <field>Status__c</field>
        <literalValue>Open</literalValue>
        <name>IT Intel Open Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IT_Update_IT_Geo_Manager</fullName>
        <description>Update the IT Geo Manager</description>
        <field>Core_IT_Geo_Manager__c</field>
        <name>Update IT Geo Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IT_Update_Status_to_In_Process</fullName>
        <description>Updates the status to in process once a geo manager is selected</description>
        <field>Status__c</field>
        <literalValue>In Process</literalValue>
        <name>Update Status to In Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Add_Oppty_team</fullName>
        <description>Updates the add opportunity team to empty on create</description>
        <field>Core_Add_to_Opportunity_Team__c</field>
        <literalValue>0</literalValue>
        <name>Update Add Oppty team</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Feedback_Field</fullName>
        <field>Core_Feedback_Comments__c</field>
        <name>Update Feedback Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Rating</fullName>
        <field>Core_Rate_Enagement__c</field>
        <name>Update Rating</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Update_Status</fullName>
        <field>Status__c</field>
        <literalValue>Open</literalValue>
        <name>Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_IT_Intel_Create_Field_Updates</fullName>
        <actions>
            <name>Core_Update_Feedback_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Rating</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Update_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.DeveloperName = &quot;Core_DS_IT_Intel&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_IT_Intel_Email_APJ</fullName>
        <actions>
            <name>Core_Email_IT_Intel_APJ_Email_List</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Emails IT @ Intel Geo email public group APJ</description>
        <formula>AND (TEXT(Core_IT_Intel_Geo__c) = &quot;APJ&quot;,        LEN(Core_IT_Geo_Manager__c) = 0       )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_IT_Intel_Email_ASMO</fullName>
        <actions>
            <name>Core_Email_IT_Intel_ASMO_Email_List</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Emails IT @ Intel Geo email public group ASMO</description>
        <formula>AND (TEXT(Core_IT_Intel_Geo__c) = &quot;ASMO&quot;,        LEN(Core_IT_Geo_Manager__c) = 0       )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_IT_Intel_Email_EMEA</fullName>
        <actions>
            <name>Core_Email_IT_Intel_EMEA_Email_List</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Emails IT @ Intel Geo email public group EMEA</description>
        <formula>AND (TEXT(Core_IT_Intel_Geo__c) = &quot;EMEA&quot;,        LEN(Core_IT_Geo_Manager__c) = 0       )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_IT_Intel_Email_Mgr</fullName>
        <actions>
            <name>Core_IT_Intel_Mgr_Assignment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends an e-mail to the assigned IT @ Intel User account</description>
        <formula>ISCHANGED( Core_IT_Geo_Manager__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IT_Intel_Email_PRC</fullName>
        <actions>
            <name>Core_Email_IT_Intel_PRC_Email_List</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Emails IT @ Intel Geo email public group PRC</description>
        <formula>AND (TEXT(Core_IT_Intel_Geo__c) = &quot;PRC&quot;,        LEN(Core_IT_Geo_Manager__c) = 0       )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_IT_Intel_Open_Status</fullName>
        <actions>
            <name>Core_IT_Intel_Open_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Core_Sales_Support_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>IT @ Intel</value>
        </criteriaItems>
        <description>Changes status once the request is filled</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_IT_Intel_Status_In_Process</fullName>
        <actions>
            <name>Core_IT_Update_Status_to_In_Process</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Moves the request to in process once the geo manager is assigned</description>
        <formula>PRIORVALUE( Status__c ) = &quot;Open&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
