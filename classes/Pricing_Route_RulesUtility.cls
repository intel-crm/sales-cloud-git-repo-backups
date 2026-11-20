/**********************************************************************************************************
* Class Name  : Pricing_Route_RulesUtility 
* Test Class Name: Pricing_Route_RulesUtility_Test
* Created Date: 25-05-2026
* Modification Log      : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------
* Accenture - VB     25-05-2026        To Verify the End Customer is Part of High Touch/CSP/Exclsuion List
***********************************************************************************************************/
public Without Sharing Class Pricing_Route_RulesUtility {
    @InvocableMethod
    public static List<FlowOutput> isEndCustomerOnAnyList(List<FlowInputs> flowInputs) {
        List<FlowOutput> flowOutputList = new List<FlowOutput>();
        String routeRuleCategory;
        String endCustomerNameFromQuote;
        String endCustRegion;
        Set<String> quoteIdSet = new Set<String>();
        try {
            for(FlowInputs flowInp: flowInputs) {
                if(quoteIdSet.contains(flowInp.quoteId)) {
                    continue;
                }
                quoteIdSet.add(flowInp.quoteId);
                routeRuleCategory = flowInp.context;
                endCustomerNameFromQuote = getEndCustomerName(flowInp);
                endCustRegion = flowInp.endCustomerRegion;
            }
            
            if(!String.isBlank(endCustomerNameFromQuote)) {
                // [ ,()\-]+   --> Matches spaces, commas, brackets, and hyphens
                // | - OR
                // (?<=\\b\\w\\.) - positive lookbehind ensuring there is a single letter and a dot right before this position
                // \\w\\b - ensures there is exactly one word character immediately after the dot - Orange S.A. - Amazon.com - Amazon com
                String regexDelimiter = '[ ,;:()\\-]+|\\.(?!(?<=\\b\\w\\.)\\w\\b)';
                List<String> endCustNmList = new List<String>();//Amazon OR  the OR def
                endCustNmList = endCustomerNameFromQuote.split(regexDelimiter);
                List<String> finalEndCustList = new List<String>();
                for (String custNm : endCustNmList) {
                    if (String.isNotBlank(custNm)) {
                        //cleanTokens.add(token);
                        finalEndCustList.add('"' + custNm + '*"');
                    }
                }
                String finalEndCustSearchTerm = String.join(finalEndCustList, ' OR ');
                List<List<SObject>> searchResults = new List<List<SObject>>();
                searchResults = [FIND :finalEndCustSearchTerm
                    IN ALL FIELDS
                    RETURNING Pricing_Route_Rules_Utility__c(
                        Id,
                        Pricing_Region_Nm__c,
                        Pricing_End_Customer_Country_Nm__c,
                        Pricing_End_Customer_Name_Txt__c,
                        
                        Pricing_Category_Nm__c                        
                        WHERE Pricing_Category_Nm__c =: routeRuleCategory
                        AND Pricing_Region_Nm__c =: endCustRegion
                    )
                ];
                FlowOutput finalOp = new FlowOutput();
                if(searchResults != null && String.valueOf(searchResults).deleteWhitespace() != '(())' && String.valueOf(searchResults).deleteWhitespace() != '[[]]' && searchResults.size() > 0) {
                    List<Pricing_Route_Rules_Utility__c> pricingRouteRulesEndCustList = (List<Pricing_Route_Rules_Utility__c>)searchResults[0];
                    if (!pricingRouteRulesEndCustList.isEmpty()) {
                        Pricing_Route_Rules_Utility__c pricingRouteRulesEndCustRec = pricingRouteRulesEndCustList[0];
                        if(pricingRouteRulesEndCustRec != null) {
                            finalOp.isEndCustomerOnAnyList = true;
                            
                        } 
                    }
                } else {
                    finalOp.isEndCustomerOnAnyList = false;
                   
                }
                flowOutputList.add(finalOp); 
            }
        } catch (Exception ex) {
            Pricing_Tender_Utility.logError(ex); 
        }
        
        return flowOutputList;
    }        
    public static String getEndCustomerName(FlowInputs endCustomerDetails) {
        String endCustomerName;
        FlowInputs endCustDetails = endCustomerDetails;
        if(!String.isBlank(endCustDetails.endCustomerUnifiedName)) {
            endCustomerName = endCustDetails.endCustomerUnifiedName;
        } else if(!String.isBlank(endCustDetails.writeInEndCustomerName)) {
            endCustomerName = endCustDetails.writeInEndCustomerName;
        } else if(!String.isBlank(endCustDetails.endCustomerName)) {
            endCustomerName = endCustDetails.endCustomerName;
        } 
        
        return endCustomerName;
    }
    
    public class FlowInputs {
        @InvocableVariable public String quoteId;
        @InvocableVariable public String endCustomerCountry;
        @InvocableVariable public String endCustomerName;
        @InvocableVariable public String writeInEndCustomerName;
        @InvocableVariable public String context;
        @InvocableVariable public String endCustomerUnifiedName;
        @InvocableVariable public String endCustomerRegion;
        @InvocableVariable public String quoteLineId;
    }
    
    public class FlowOutput {
        @InvocableVariable public Boolean isEndCustomerOnAnyList;
        
    }
}