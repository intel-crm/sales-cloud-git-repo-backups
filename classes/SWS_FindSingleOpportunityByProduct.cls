public with sharing class SWS_FindSingleOpportunityByProduct {
    /**
     * Input contract for Flow
     */
    public class Request {
        @InvocableVariable(required=false)
        public String body;

        @InvocableVariable(required=false)
        public List<Id> opportunityIds;
    }

    /**
     * Output contract for Flow
     */
    public class Result {
        @InvocableVariable
        public Id opportunityId;

        @InvocableVariable
        public String opportunityName;
    }

    /**
     * Internal DTO to hold Opportunity minimal info for selection
     */
    private class OppInfo {
        Id id;
        String name;
        Datetime lastModified;

        OppInfo(Id id, String name, Datetime lastModified) {
            this.id = id;
            this.name = name;
            this.lastModified = lastModified;
        }
    }

    /**
     * Invocable method entry point
     */
    @InvocableMethod(label='SWS: Find Single Opportunity by Product' description='Returns a single Opportunity from provided Ids where any related product name appears in the email body. Tie-breaker by latest LastModifiedDate.')
    public static List<Result> findOneByProduct(List<Request> requests) {
        if (isEmptyRequests(requests)) {
            return new List<Result>();
        }
        Set<Id> allOppIds = collectAllOppIds(requests);
        if (allOppIds.isEmpty()) {
            return new List<Result>(new Result[requests.size()]);
        }
        Map<Id, OppInfo> oppById = loadOppInfo(allOppIds);
        Map<Id, Set<String>> oppIdToProductNames = loadOppProducts(allOppIds);
        List<Result> results = new List<Result>();
        for (Request r : requests) {
            results.add(processSingleRequest(r, oppById, oppIdToProductNames));
        }
        return results;
    }

    /**
     * Handle a single request, returning a single matching Opportunity or null.
     */
    private static Result processSingleRequest(Request r, Map<Id, OppInfo> oppById, Map<Id, Set<String>> oppIdToProductNames) {
        Result out = new Result();
        if (isInvalid(r)) return out;

        String normBody = normalize(r.body);
        Set<Id> candidateIds = collectMatchingOppIds(r.opportunityIds, normBody, oppById, oppIdToProductNames);
        
        // If no products matched, return the opportunity with latest LastModifiedDate among all provided
        if (candidateIds.isEmpty()) {
            // Use existing query pattern to get latest opportunity
            for (Opportunity o : [
                SELECT Id, Name
                FROM Opportunity
                WHERE Id IN :r.opportunityIds
                ORDER BY LastModifiedDate DESC
                LIMIT 1
            ]) {
                out.opportunityId = o.Id;
                out.opportunityName = o.Name;
                break;
            }
            return out;
        }
       

        // One selective query per request to choose winner; still within 100 SOQL governor limit
        for (Opportunity o : [
            SELECT Id, Name
            FROM Opportunity
            WHERE Id IN :candidateIds
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ]) {
            out.opportunityId = o.Id;
            out.opportunityName = o.Name;
            break;
        }
        return out;
        
    }

    /**
     * Returns true if the haystack contains any string from needles (all assumed normalized).
     */
    private static Boolean containsAny(String haystack, Set<String> needles) {
        if (String.isBlank(haystack) || needles == null || needles.isEmpty()) return false;
        for (String n : needles) {
            if (!String.isBlank(n) && haystack.contains(n)) return true;
        }
        return false;
    }

    /**
     * Normalizes text for case-insensitive, simple substring matching.
     * - Lowercase
     * - Trim
     */
    private static String normalize(String s) {
        return s == null ? '' : s.toLowerCase().trim();
    }

    // Helper: empty requests
    private static Boolean isEmptyRequests(List<Request> reqs) {
        return reqs == null || reqs.isEmpty();
    }

    // Helper: invalid single request
    private static Boolean isInvalid(Request r) {
        return r == null || String.isBlank(r.body) || r.opportunityIds == null || r.opportunityIds.isEmpty();
    }

    // Helper: collect all opp ids across requests
    private static Set<Id> collectAllOppIds(List<Request> requests) {
        Set<Id> allOppIds = new Set<Id>();
        for (Request r : requests) {
            if (r == null || r.opportunityIds == null) continue;
            for (Id oid : r.opportunityIds) {
                if (oid != null) allOppIds.add(oid);
            }
        }
        return allOppIds;
    }

    // Helper: load opportunities once
    private static Map<Id, OppInfo> loadOppInfo(Set<Id> oppIds) {
        Map<Id, OppInfo> oppById = new Map<Id, OppInfo>();
        for (Opportunity o : [
            SELECT Id, Name, LastModifiedDate
            FROM Opportunity
            WHERE Id IN :oppIds
        ]) {
            oppById.put(o.Id, new OppInfo(o.Id, o.Name, o.LastModifiedDate));
        }
        return oppById;
    }

    // Helper: load product names per opportunity
    private static Map<Id, Set<String>> loadOppProducts(Set<Id> oppIds) {
        Map<Id, Set<String>> oppIdToProductNames = new Map<Id, Set<String>>();
        for (OpportunityLineItem oli : [
            SELECT Id, OpportunityId, Product2.Name
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppIds
        ]) {
            if (oli.OpportunityId == null || oli.Product2 == null || String.isBlank(oli.Product2.Name)) continue;
            Set<String> names = oppIdToProductNames.get(oli.OpportunityId);
            if (names == null) {
                names = new Set<String>();
                oppIdToProductNames.put(oli.OpportunityId, names);
            }
            names.add(normalize(oli.Product2.Name));
        }
        return oppIdToProductNames;
    }

    // Helper: collect matching opp ids for one request
    private static Set<Id> collectMatchingOppIds(List<Id> requestOppIds, String normBody, Map<Id, OppInfo> oppById, Map<Id, Set<String>> oppIdToProductNames) {
        Set<Id> candidateIds = new Set<Id>();
        for (Id oppId : requestOppIds) {
            if (oppId == null) continue;
            if (!oppById.containsKey(oppId)) continue;
            Set<String> prodNames = oppIdToProductNames.get(oppId);
            if (prodNames == null || prodNames.isEmpty()) continue;
            if (containsAny(normBody, prodNames)) candidateIds.add(oppId);
        }
        return candidateIds;
    }
}