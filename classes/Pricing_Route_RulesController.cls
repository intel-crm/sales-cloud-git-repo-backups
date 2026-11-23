public without sharing class Pricing_Route_RulesController {
    
    @InvocableMethod
    public static void updatePricingManagerDetails(List<FlowInputs> flowInputs) {
        List<SBQQ__Quote__c> quoteListToBeUpd = new List<SBQQ__Quote__c>();
        set<String> quoteIdSet = new Set<String>();
        FlowInputs finalFlowInp = new FlowInputs();
        Boolean isPricingMgrDlsAvailable = false;
        Boolean isPricingMgrDlsNotAvailable = false;
        try {
            for(FlowInputs flowInp: flowInputs) {
                if(isPricingMgrDlsAvailable || isPricingMgrDlsNotAvailable) {
                    continue;
                }
                if((!String.isBlank(flowInp.pricingManagerEmail)) || (!String.isBlank(flowInp.pricingManagerGroupName))) {
                    finalFlowInp= flowInp;
                    isPricingMgrDlsAvailable = true;
                } else if(String.isBlank(flowInp.pricingManagerEmail) && String.isBlank(flowInp.pricingManagerGroupName)) {
                    finalFlowInp= flowInp;
                    isPricingMgrDlsNotAvailable = true;
                }
                
            }
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.Id = finalFlowInp.quoteId;
            if(isPricingMgrDlsAvailable) {
                if(!String.isBlank(finalFlowInp.pricingManagerEmail)) {
                    List<User> pricingMgrUserDtlsList = [SELECT Id, Name, Username, Email FROM User WHERE Email =: finalFlowInp.pricingManagerEmail and IsActive = true];
                    if(pricingMgrUserDtlsList != null && pricingMgrUserDtlsList.size() > 0) {
                        quote.pricing_pricing_manager__c = pricingMgrUserDtlsList[0].Id;
                        quote.Pricing_Pricing_Manager_Group_Name_Txt__c = null;
                        quote.Pricing_Pricing_Manager_Group_Label_Txt__c = null;
                    } else {
                        String userErrMsg = 'No Active User Found with User Email:'+' '+finalFlowInp.pricingManagerEmail;
                        Pricing_Tender_Utility.logErrorinLogObject(userErrMsg,'SBQQ__Quote__c',finalFlowInp.quoteId);
                    }
                } else if(!String.isBlank(finalFlowInp.pricingManagerGroupName)) {
                    /*List<Group> pricingMgrGroupDtlsList = [select Id, Name, DeveloperName from Group where DeveloperName =: finalFlowInp.pricingManagerGroupName];*/
                    List<GroupMember> pricingMgrGroupDtlsList = [SELECT GroupId, Group.Name, Group.DeveloperName, Group.Type, UserOrGroupId, UserOrGroup.Name FROM GroupMember WHERE UserOrGroup.IsActive = true and Group.Type = 'Regular' and group.DeveloperName =: finalFlowInp.pricingManagerGroupName];
                    if(pricingMgrGroupDtlsList != null && pricingMgrGroupDtlsList.size() > 0) {
                        quote.Pricing_Pricing_Manager_Group_Name_Txt__c = pricingMgrGroupDtlsList[0].Group.DeveloperName;
                        quote.Pricing_Pricing_Manager_Group_Label_Txt__c = pricingMgrGroupDtlsList[0].Group.Name;
                        quote.pricing_pricing_manager__c = null;
                    } else {
                        String grpErrMsg = 'No Active Group Member Found with the Group Name:'+' '+finalFlowInp.pricingManagerGroupName;
                        Pricing_Tender_Utility.logErrorinLogObject(grpErrMsg,'SBQQ__Quote__c',finalFlowInp.quoteId);
                    }
                }
                if((!String.isBlank(quote.pricing_pricing_manager__c)) || (!String.isBlank(quote.Pricing_Pricing_Manager_Group_Name_Txt__c))) {
                    quote.Pricing_Quote_Routing_Category_Nm__c = finalFlowInp.pricingManagerRouteCategory;
                    quote.Pricing_Route_Rule_Name_Txt__c = finalFlowInp.routeRuleName;
                    quote.Pricing_Route_Rule_Id_Txt__c = finalFlowInp.routeRuleId;
                    quote.Pricing_ReRouting_Reason_Nm__c = null;
                }
                quoteListToBeUpd.add(quote);
            } else {
                quote.pricing_pricing_manager__c = null;
                quote.Pricing_Pricing_Manager_Group_Name_Txt__c = null;
                quote.Pricing_Pricing_Manager_Group_Label_Txt__c = null;
                quote.Pricing_Quote_Routing_Category_Nm__c = null;
                quote.Pricing_Route_Rule_Name_Txt__c = null;
                quote.Pricing_Route_Rule_Id_Txt__c = null;
                quote.Pricing_ReRouting_Reason_Nm__c = null;
                quoteListToBeUpd.add(quote);
            }
            if(!quoteListToBeUpd.isEmpty()){
                SBQQ.TriggerControl.disable();
                update quoteListToBeUpd;
                SBQQ.TriggerControl.enable();
            }
            
        }  catch (Exception ex) {
            Pricing_Tender_Utility.logError(ex); 
        } finally {
            SBQQ.TriggerControl.enable();
        }
    }
    
    public class FlowInputs{
        @InvocableVariable public String quoteId;
        @InvocableVariable public String routeRuleId;
        @InvocableVariable public String routeRuleName;
        @InvocableVariable public String pricingManagerEmail;
        @InvocableVariable public String pricingManagerGroupName;
        @InvocableVariable public String pricingManagerRouteCategory;
    }
}