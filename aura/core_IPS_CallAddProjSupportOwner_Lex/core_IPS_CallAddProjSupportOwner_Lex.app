<aura:application extends="force:slds" implements="force:appHostable,flexipage:availableForAllPageTypes,flexipage:availableForRecordHome,force:hasRecordId,force:hasSObjectName,forceCommunity:availableForAllPageTypes,force:hasSObjectName" access="global" >
	 <!--<lightning:navigation aura:id="navLink"/> 
    <c:core_IPS_AddMembers_Lex recordId="{!v.recordId}" />-->
    
    <c:core_IPS_AddProjSupportOwner_Lex aura:id="core_IPS_AddProjSupportOwner_LexId" recordId="{!v.recordId}"></c:core_IPS_AddProjSupportOwner_Lex><br/>
<div align="center">
<lightning:button label="Save" variant="brand" class="slds-m-left_x-small" onclick="{!c.callSaveMethod}" ></lightning:button>
<lightning:button label="Cancel" variant="brand" class="slds-m-left_x-small" onclick="{!c.callCancelMethod}" ></lightning:button>
 </div>
</aura:application>