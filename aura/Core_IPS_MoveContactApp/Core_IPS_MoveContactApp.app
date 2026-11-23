<aura:application extends="force:slds" implements="force:appHostable,flexipage:availableForAllPageTypes,flexipage:availableForRecordHome,force:hasRecordId,forceCommunity:availableForAllPageTypes,force:hasSObjectName" access="global">
    <aura:attribute name="recordId" type="String"/> 
    <c:core_IPS_MoveContact recordId="{!v.recordId}"/>
</aura:application>