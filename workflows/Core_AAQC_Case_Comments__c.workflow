<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_to_the_Owner_created_by_when_the_Case_comment_is_updated</fullName>
        <ccEmails>pritix.bhale@intel.com</ccEmails>
        <description>Notification to the Owner/created by when the Case comment is updated</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Core_AACQ_Ask_Commission_Email_Folder/Ask_Commissions_Case_Comment_is_updated</template>
    </alerts>
</Workflow>
