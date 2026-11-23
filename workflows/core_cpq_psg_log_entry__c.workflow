<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PSG_Log_Alert</fullName>
        <description>PSG Log Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>11992939@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>12026740@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>12073796@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>12157180@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSG_Email_Templates/PSG_Log_Entry_Email</template>
    </alerts>
</Workflow>
