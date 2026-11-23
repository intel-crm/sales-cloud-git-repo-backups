<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CEP_Response_Email1</fullName>
        <description>CEP Response Email - New</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>customer.excellence@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CEP_Email_Templates/Core_CEP_Response_Email1</template>
    </alerts>
    <alerts>
        <fullName>Core_CEP_Response_EMail</fullName>
        <description>CEP_Response_EMail</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Core_CEP_Response_Email</template>
    </alerts>
</Workflow>
