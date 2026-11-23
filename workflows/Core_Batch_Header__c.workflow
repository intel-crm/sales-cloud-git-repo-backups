<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PMP_Sending_Emailalert_To_DL</fullName>
        <description>PMP_Sending_Emailalert_To_DL</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Distribution_List__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Core_PMP_Partner_MarketPlace_Templates/PMP_Successful_Syncup_of_Taxonomy_files</template>
    </alerts>
    <rules>
        <fullName>EmailToDL</fullName>
        <actions>
            <name>PMP_Sending_Emailalert_To_DL</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Core_Batch_Header__c.Name</field>
            <operation>contains</operation>
            <value>Test</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
