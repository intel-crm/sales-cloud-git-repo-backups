<aura:application extends="force:slds" >
    <!-- <c:core_IPS_CustomLookup
  onSelectedRec="{c.handleContactChange}"
  iconname="standard:contact"
  label="Contact Name"
  searchfieldName="Name"
  queryString="FIND :key IN ALL FIELDS RETURNING CONTACT (Id, Name, FirstName, LastName, Account.Name, AccountId, Account.ownerId, Core_IPS_Intel_Support_Owner__c, Core_MINDS__c, Core_Country_Region__c where Core_IPS_Active__c=true ORDER BY Name LIMIT :recordLimit)"
  countQueryString="FIND :key IN ALL FIELDS RETURNING CONTACT (Id, Name, FirstName, LastName, Account.Name, AccountId, Account.ownerId, Core_IPS_Intel_Support_Owner__c, Core_MINDS__c, Core_Country_Region__c where Core_IPS_Active__c=true )"
  isSosl="true"
  queryExecutionRequired="true"
  extraFieldLabel="Account"
  extraField1="Account.Name">
    </c:core_IPS_CustomLookup> -->
    <!-- 
    <c:core_IPS_Case_Interested_Parties caseRecordId="5003F000006qfNtQAI" interestedPartyType="External"></c:core_IPS_Case_Interested_Parties>
    
    <br />
    -->
    
    <c:core_IPS_Case_Interested_Parties recordId="5003F000006qfNtQAI" interestedPartyType="Internal"></c:core_IPS_Case_Interested_Parties>

    <!--
    <c:mysearch />
-->
</aura:application>