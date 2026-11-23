<aura:application extends="force:slds" implements="force:appHostable,flexipage:availableForAllPageTypes,flexipage:availableForRecordHome,force:hasRecordId,force:hasSObjectName,forceCommunity:availableForAllPageTypes,force:hasSObjectName" access="global">
    <c:core_IPS_addAccountLex aura:id="Core_IPS_addAccountsLexId" recordId="{!v.recordId}"></c:core_IPS_addAccountLex><br/>
    <div align="center">
        <lightning:button label="Add" class="slds-m-left_x-small" onclick="{!c.callAddMethod}" ></lightning:button>
        <lightning:button label="Add and Done" class="slds-m-left_x-small" onclick="{!c.callAddDoneMethod}" ></lightning:button>
        <lightning:button label="Cancel" class="slds-m-left_x-small" onclick="{!c.callCancelMethod}" ></lightning:button>
    </div>
</aura:application>