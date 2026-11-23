<aura:application extends="force:slds" implements="force:appHostable,flexipage:availableForAllPageTypes">
	 <aura:attribute name="id" type="String"/>    
    <c:core_IPS_Create_Opportunity_PAR recordId="{!v.id}"/>
</aura:application>