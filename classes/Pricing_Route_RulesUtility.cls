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
        String endCustCountry;
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
                endCustCountry = flowInp.endCustomerCountry;
            }
            
            if(!String.isBlank(endCustomerNameFromQuote)) {
                FlowOutput finalOp = new FlowOutput();
                List<Pricing_Route_Rules_Utility__c> pricingRouteRulesEndCustList = new List<Pricing_Route_Rules_Utility__c>();
                
                String searchQuery1 = 'Id,Pricing_Region_Nm__c,Pricing_End_Customer_Country_Nm__c,Pricing_End_Customer_Name_Txt__c,Pricing_Category_Nm__c ';
                String searchQuery2 =  'WHERE Pricing_Category_Nm__c =\'' + routeRuleCategory + '\' and Pricing_Region_Nm__c = \'' + endCustRegion + '\'';
                String searchQuery3;
                if(routeRuleCategory == 'High Touch') {
                    searchQuery3 = ' and Pricing_End_Customer_Country_Nm__c =  \'' + endCustCountry + '\'';
                }
                if(endCustomerNameFromQuote.length() == 1) {
                    List<Pricing_Route_Rules_Utility__c> routeRulesUtilityList = new List<Pricing_Route_Rules_Utility__c>();
                    String soqlQueryString = 'Select '+ searchQuery1 + 'FROM Pricing_Route_Rules_Utility__c '+ searchQuery2;
                    soqlQueryString +=  ' and Pricing_End_Customer_Name_Txt__c = \'' + endCustomerNameFromQuote + '\'';
                    if(!String.isBlank(searchQuery3)) {
                        soqlQueryString += searchQuery3;
                    }
                    System.debug('soqlQueryString'+soqlQueryString);
                    pricingRouteRulesEndCustList = database.query(soqlQueryString);
                    System.debug('pricingRouteRulesEndCustList'+pricingRouteRulesEndCustList);
                    if(!pricingRouteRulesEndCustList.isEmpty()) {
                        Pricing_Route_Rules_Utility__c pricingRouteRulesEndCustRec = pricingRouteRulesEndCustList[0];
                        if(pricingRouteRulesEndCustRec != null) {
                            finalOp.isEndCustomerOnAnyList = true;
                        } 
                    } else {
                        finalOp.isEndCustomerOnAnyList = false;   
                    }
                    flowOutputList.add(finalOp);
                } else {
                    // [ ,()\-]+   --> Matches spaces, commas, brackets, and hyphens
                    // | - OR
                    // (?<=\\b\\w\\.) - positive lookbehind ensuring there is a single letter and a dot right before this position
                    // \\w\\b - ensures there is exactly one word character immediately after the dot - Orange S.A. - Amazon.com - Amazon com
                    String regexDelimiter = '[ ,;:()\\-]+|\\.(?!(?<=\\b\\w\\.)\\w\\b)';
                    
                    List<String> endCustNmList = new List<String>();//Amazon OR  the OR def
                    endCustNmList = endCustomerNameFromQuote.split(regexDelimiter);
                    List<String> stopWords = new List<String>{'of', 'the', 'and', 'in', 'for', 'to', 'ltd', 'limited', 'inc','&','lab','labs', 'inc.','com', 'cloud', 'services','corporation', 'organization', 'it'};
                        List<String> finalEndCustList = new List<String>();
                    for (String custNm : endCustNmList) {
                        if (String.isNotBlank(custNm) && !stopWords.contains(custNm.toLowerCase())) {
                            finalEndCustList.add('"' + custNm + '*"');
                        }
                    }
                    String finalEndCustSearchTerm = String.join(finalEndCustList, ' AND '); // State * AND  bank * AND  india * 
                    System.debug('finalEndCustSearchTerm'+finalEndCustSearchTerm);
                    List<List<SObject>> searchResults = new List<List<SObject>>();
                    String soslSearchQuery = 'FIND \'' + String.escapeSingleQuotes(finalEndCustSearchTerm) + 
                        '\' RETURNING Pricing_Route_Rules_Utility__c' + '(' + searchQuery1 + searchQuery2 +')';
                     if(!String.isBlank(searchQuery3)) {
                        soslSearchQuery += searchQuery3;
                    }
                    System.debug('soslSearchQuery'+soslSearchQuery);
                    searchResults = search.query(soslSearchQuery);
                    System.debug('searchResults'+searchResults);
                    if(searchResults != null && String.valueOf(searchResults).deleteWhitespace() != '(())' && String.valueOf(searchResults).deleteWhitespace() != '[[]]' && searchResults.size() > 0) {
                        pricingRouteRulesEndCustList = (List<Pricing_Route_Rules_Utility__c>)searchResults[0];
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