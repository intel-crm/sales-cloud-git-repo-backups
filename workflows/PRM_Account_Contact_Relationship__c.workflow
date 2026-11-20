<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PRM_AGSIdentityFailureAlert1</fullName>
        <description>PRM_AGSIdentityFailureAlert1</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_IPAAdminsListForEPUM</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPA_English_Templates/IPA_AGS_IdentityFail</template>
    </alerts>
    <alerts>
        <fullName>PRM_AGSIdentityFailureAlert2</fullName>
        <description>PRM_AGSIdentityFailureAlert2</description>
        <protected>false</protected>
        <recipients>
            <field>PRM_Initiated_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPA_English_Templates/IPA_AGS_IdentityFail</template>
    </alerts>
</Workflow>
