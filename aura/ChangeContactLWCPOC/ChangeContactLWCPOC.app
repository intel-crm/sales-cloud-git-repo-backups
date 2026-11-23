<aura:application extends="ltng:outApp" implements="force:appHostable,flexipage:availableForAllPageTypes,flexipage:availableForRecordHome,force:hasRecordId,forceCommunity:availableForAllPageTypes,force:hasSObjectName" access="global">
     <aura:attribute name="recordId" type="String"/>
    
   <!-- <c:core_IPS_MoveContact recordId="{!v.recordId}"/>-->
    <!--<c:core_IPS_MoveContactPOC recordId="{!v.recordId}"/>-->
   <c:ContactMove recordId="{!v.recordId}"/>
</aura:application>