<aura:application extends="force:slds" implements="force:appHostable,flexipage:availableForAllPageTypes,flexipage:availableForRecordHome,force:hasRecordId,force:hasSObjectName,forceCommunity:availableForAllPageTypes,force:hasSObjectName" access="global" >
	 
    <c:core_IPS_AddMembers_Lex aura:id="core_IPS_AddMembers_LexId" recordId="{!v.recordId}"></c:core_IPS_AddMembers_Lex><br/>
    <!--<aura:component controller="Core_IPS_ProjectController_Lex">
        <aura:attribute name="isError" type="Boolean"/>
        <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
    </aura:component>
    <div if:true="{!v.isError}">-->
       <div align="center">
         <lightning:button label="Add" variant="brand" class="slds-m-left_x-small" onclick="{!c.callAddMethod}" ></lightning:button>
         <lightning:button label="Add and Done" variant="brand" class="slds-m-left_x-small" onclick="{!c.callAddDoneMethod}" ></lightning:button>
        <lightning:button label="Cancel" variant="brand" class="slds-m-left_x-small" onclick="{!c.callCancelMethod}" ></lightning:button>
      </div>
    
</aura:application>