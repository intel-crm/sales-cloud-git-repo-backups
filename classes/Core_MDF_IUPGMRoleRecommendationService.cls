/******************************************************************************************************
* Class Name  : Core_MDF_IUPGMRoleRecommendationService
* Description : AI-assisted (RAG) role recommendation for the IUPGM chatbot flow.
*
*               RETRIEVAL     - Deterministic MDT metadata/keyword pre-filtering happens in the CALLER
*                                (Core_MDF_IUPGM_RequestAPI) before this class is ever invoked. This
*                                class never queries the full Rule Config MDT itself - it only ever
*                                works off the short, already-narrowed candidate list it is given.
*               AUGMENTATION  - Each candidate role is expanded into a rich contextual document
*                                (label, program, purpose, keywords, use cases, access requirements)
*                                and injected directly into the prompt sent to the existing CCP
*                                Generative AI chat endpoint. NO NEW ENDPOINT OR NAMED CREDENTIAL IS
*                                INTRODUCED - this reuses the exact same "callout:Core_MDF_CCP_GenAI"
*                                Named Credential + GPT-4o deployment already used by
*                                Core_MDF_GenAIProcessing / Core_MDF_AiFieldSuggestions.
*               GENERATION    - The model ranks/explains the candidates and returns confidence scores
*                                as strict JSON (one callout, both query-understanding and reranking
*                                are done together to keep governor-limit usage minimal).
*               GUARDRAIL     - Every role label the model returns is verified against the real MDT
*                                candidate map before it is ever surfaced. A hallucinated/unknown/
*                                misspelled role is silently dropped - never shown to the user. This
*                                mirrors the anti-hallucination sanitizer pattern already used in
*                                Core_MDF_AiFieldSuggestions.sanitizePicklistFields() and preserves the
*                                "AI recommends, Salesforce validates" principle.
*
*               OPTIONAL PLATFORM RAG HOOK - if the CCP Generative AI platform already has (or later
*                                gets) a managed knowledge base / Azure AI Search index wired to the
*                                same chat deployment, set the Custom Label
*                                Core_MDF_IUPGM_RoleReco_DataSource_Index to that index name and this
*                                class will automatically include a "data_sources" grounding block on
*                                the SAME request (Azure OpenAI "on your data" pattern) - still no new
*                                endpoint. Until that label is populated, the class relies purely on
*                                the in-context grounding described above, which already produces
*                                correct, independently-verified results on its own.
*
*               RESILIENCE    - The public entry point never throws. Any internal failure (callout
*                                error, timeout, malformed response) results in a RecommendationResult
*                                with success = false so the caller can fall back to its own
*                                deterministic keyword scoring without interrupting the request.
*
* Called From :    Core_MDF_IUPGM_RequestAPI (role disambiguation branch only - no new REST endpoint)
* Created By  :    Ramapriya
******************************************************************************************************/
public without sharing class Core_MDF_IUPGMRoleRecommendationService {

    // Reuses the same Azure OpenAI GPT-4o deployment already wired for Claim Ezy / Field Suggestions -
    // no new endpoint or Named Credential is created for this feature.
    private static final String GENAI_ENDPOINT_LABEL = 'Core_MDF_ClaimEzyGenAIEndpoint';
    // Optional - populate only if/when a real platform knowledge base / vector index exists.
    private static final String DATA_SOURCE_INDEX_LABEL = 'Core_MDF_IUPGM_RoleReco_DataSource_Index';

    private static final Integer MAX_CANDIDATES_TO_MODEL = 15;
    private static final Integer MAX_RECOMMENDATIONS     = 5;
    private static final Integer CALLOUT_TIMEOUT_MS      = 15000;

    public class RoleRecommendation {
        public String  roleLabel;
        public String  program;
        public String  purpose;
        public Decimal confidence;
        public String  reason;
    }

    public class RecommendationResult {
        public Boolean success               = false;
        // True once the GenAI callout returned HTTP 200 and parseable JSON - i.e. the
        // model was actually consulted, regardless of what it decided. Callers must use
        // THIS flag (not "success") to decide whether it is safe to fall back to
        // deterministic keyword scoring. If the model was reached and it legitimately
        // found no confident match, that is a real answer - not a technical failure -
        // and must NOT be overridden by a broader deterministic search (that would
        // reintroduce the exact "shows unrelated roles" bug this design prevents).
        public Boolean calloutSucceeded       = false;
        public String  rewrittenQuery;
        public Boolean needsClarification     = false;
        public String  clarificationQuestion;
        public String  errorMessage;
        public List<RoleRecommendation> recommendations = new List<RoleRecommendation>();
    }

    /**
     * Main entry point. Never throws - any internal failure results in
     * RecommendationResult.success = false so the caller can fall back to its
     * own deterministic keyword scoring without interrupting the request.
     *
     * @param userQuery   the raw, free-text request from the user/chatbot
     * @param candidates  an ALREADY metadata/keyword-filtered, best-first-sorted list of
     *                    Core_MDF_IUPGM_Rule_Config__mdt records. This class never widens the
     *                    search itself - it only ranks/explains within what it is given, and only
     *                    ever recommends a role that is actually present in this list.
     */
    public static RecommendationResult recommend(String userQuery, List<Core_MDF_IUPGM_Rule_Config__mdt> candidates) {
        RecommendationResult result = new RecommendationResult();
        try {
            if (String.isBlank(userQuery) || candidates == null || candidates.isEmpty()) {
                result.errorMessage = 'No query or candidate roles supplied.';
                return result;
            }

            // Cap the number of candidates sent to the model. The caller is expected to pass
            // records already ordered best-first (e.g. by keyword score), so capping here keeps
            // the prompt small/cheap/fast while still grounding the model only in real roles.
            List<Core_MDF_IUPGM_Rule_Config__mdt> scoped = new List<Core_MDF_IUPGM_Rule_Config__mdt>();
            Map<String, Core_MDF_IUPGM_Rule_Config__mdt> byLabel = new Map<String, Core_MDF_IUPGM_Rule_Config__mdt>();
            Map<String, List<Core_MDF_IUPGM_Rule_Config__mdt>> byProgram =
                new Map<String, List<Core_MDF_IUPGM_Rule_Config__mdt>>();
            List<String> programOrder = new List<String>();
            for (Core_MDF_IUPGM_Rule_Config__mdt c : candidates) {
                if (c.Core_MDF_Role_Label__c == null) continue;
                String program = String.isNotBlank(c.Core_MDF_Program__c)
                    ? c.Core_MDF_Program__c.trim().toLowerCase() : '';
                if (!byProgram.containsKey(program)) {
                    byProgram.put(program, new List<Core_MDF_IUPGM_Rule_Config__mdt>());
                    programOrder.add(program);
                }
                byProgram.get(program).add(c);
            }
            // Preserve cross-program coverage when capability scores tie.
            Integer round = 0;
            while (scoped.size() < MAX_CANDIDATES_TO_MODEL) {
                Boolean added = false;
                for (String program : programOrder) {
                    List<Core_MDF_IUPGM_Rule_Config__mdt> programRoles = byProgram.get(program);
                    if (round < programRoles.size()) {
                        Core_MDF_IUPGM_Rule_Config__mdt c = programRoles[round];
                        scoped.add(c);
                        byLabel.put(c.Core_MDF_Role_Label__c.trim().toLowerCase(), c);
                        added = true;
                        if (scoped.size() >= MAX_CANDIDATES_TO_MODEL) break;
                    }
                }
                if (!added) break;
                round++;
            }
            if (scoped.isEmpty()) {
                result.errorMessage = 'No valid candidate roles to ground the model with.';
                return result;
            }

            String systemMessage = buildSystemMessage();
            String userMessage   = buildUserMessage(userQuery, scoped);

            String rawContent = callGenAI(systemMessage, userMessage);
            if (String.isBlank(rawContent)) {
                result.errorMessage = 'AI service returned no usable content.';
                return result;
            }

            Map<String, Object> parsed = parseJsonContent(rawContent);
            if (parsed == null) {
                result.errorMessage = 'Could not parse AI response as JSON.';
                return result;
            }

            result.calloutSucceeded     = true;
            result.rewrittenQuery       = (String) parsed.get('rewrittenQuery');
            result.needsClarification   = parsed.get('needsClarification') == true;
            result.clarificationQuestion = (String) parsed.get('clarificationQuestion');

            List<Object> rawRecs = parsed.get('recommendations') instanceof List<Object>
                ? (List<Object>) parsed.get('recommendations') : null;

            if (rawRecs != null) {
                for (Object o : rawRecs) {
                    if (!(o instanceof Map<String, Object>)) continue;
                    Map<String, Object> m = (Map<String, Object>) o;
                    String lbl = (String) m.get('roleLabel');
                    if (String.isBlank(lbl)) continue;

                    // GUARDRAIL: only accept roles that are real, verified candidates from the
                    // list we actually sent - a hallucinated/unknown role is dropped silently.
                    Core_MDF_IUPGM_Rule_Config__mdt match = byLabel.get(lbl.trim().toLowerCase());
                    if (match == null) continue;

                    RoleRecommendation rec = new RoleRecommendation();
                    rec.roleLabel   = match.Core_MDF_Role_Label__c; // verified label, not the model's echo
                    rec.program     = match.Core_MDF_Program__c;
                    rec.purpose     = match.Core_MDF_Role_Purpose__c;
                    rec.reason      = (String) m.get('reason');
                    rec.confidence  = toDecimalOrNull(m.get('confidence'));
                    result.recommendations.add(rec);

                    if (result.recommendations.size() >= MAX_RECOMMENDATIONS) break;
                }
            }

            result.success = !result.recommendations.isEmpty();
            return result;

        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            result.success      = false;
            result.errorMessage = 'AI recommendation failed: ' + ex.getMessage();
            return result;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // PROMPT CONSTRUCTION (retrieval-augmented context injection)
    // ═══════════════════════════════════════════════════════════════════════════════

    private static String buildSystemMessage() {
        return 'You are a role-matching assistant for an internal Salesforce IUPGM access-request '
            + 'system. You will be given a user\'s natural-language access request and a numbered '
            + 'list of CANDIDATE ROLES, each with its official Role Label, Program, Purpose, Keywords, '
            + 'Use Cases and access requirements. Rank which of the CANDIDATE ROLES - and ONLY these '
            + 'roles - best satisfy the user\'s request.\n'
            + 'Rules:\n'
            + '1. Copy the "Role Label" value EXACTLY as given for any role you recommend. Never '
            + 'invent, translate, abbreviate, guess, or modify a label.\n'
            + '2. Only recommend roles that are plausibly relevant to the request. If NONE of the '
            + 'candidates are plausibly relevant at all, return an empty "recommendations" array.\n'
            + '3. Return at most 5 recommendations, ordered by relevance descending, each with a '
            + 'confidence between 0 and 1 and a one-sentence reason grounded in that role\'s Purpose '
            + 'or Use Cases.\n'
            + '4. IMPORTANT: needsClarification and recommendations are INDEPENDENT and both may be '
            + 'set at the same time. If multiple candidates are plausible but you cannot confidently '
            + 'pick just one (e.g. the same role name exists for several programs, or the request is '
            + 'vague about which variant is meant), you MUST still populate "recommendations" with '
            + 'ALL of those plausible candidates (so the user can choose from real options) AND set '
            + 'needsClarification to true with a short clarificationQuestion. Only leave '
            + '"recommendations" empty when truly NONE of the candidates are plausibly relevant.\n'
            + '5. Respond with ONLY a single JSON object - no markdown fences, no commentary - '
            + 'matching exactly this schema:\n'
            + '{"rewrittenQuery": string, "needsClarification": boolean, '
            + '"clarificationQuestion": string|null, "recommendations": '
            + '[{"roleLabel": string, "confidence": number, "reason": string}]}';
    }

    private static String buildUserMessage(String userQuery, List<Core_MDF_IUPGM_Rule_Config__mdt> scoped) {
        Map<String, Map<String, String>> knowledgeBase = loadRoleKnowledgeBase();
        List<String> docLines = new List<String>();
        Integer idx = 1;
        for (Core_MDF_IUPGM_Rule_Config__mdt r : scoped) {
            // KNOWLEDGE BASE OVERRIDE: business users maintain an Excel/CSV copy of the
            // role catalog's descriptive text (Purpose/Keywords/Use Cases) - uploaded to
            // Salesforce as the Static Resource Core_MDF_IUPGM_RoleReco_KnowledgeBase -
            // so they can edit AI-facing wording without needing Salesforce access or a
            // deployment. When a row exists for this role, its Purpose/Keywords/Use Cases
            // are used INSTEAD of the live MDT values for prompt-building purposes only.
            // MDT itself is untouched and remains the sole source of truth for which
            // roles exist/are active - the guardrail verification in recommend() below
            // still checks the AI's answer against the real MDT-derived candidate list,
            // never against this file. If a role has no row in the file (e.g. it was
            // added to MDT after the file was last exported), the live MDT text is used
            // as a safe fallback so nothing ever breaks.
            Map<String, String> kbRow = knowledgeBase.get(
                r.Core_MDF_Role_Label__c != null ? r.Core_MDF_Role_Label__c.trim().toLowerCase() : null);
            String purpose  = (kbRow != null && String.isNotBlank(kbRow.get('Purpose')))
                ? kbRow.get('Purpose') : r.Core_MDF_Role_Purpose__c;
            String keywords = (kbRow != null && String.isNotBlank(kbRow.get('Keywords')))
                ? kbRow.get('Keywords') : r.Core_MDF_Keywords__c;
            String useCases = (kbRow != null && String.isNotBlank(kbRow.get('UseCases')))
                ? kbRow.get('UseCases') : r.Core_MDF_Use_Cases__c;

            docLines.add(idx + '. Role Label: ' + r.Core_MDF_Role_Label__c);
            docLines.add('   Program: ' + blankSafe(r.Core_MDF_Program__c));
            docLines.add('   Purpose: ' + blankSafe(purpose));
            docLines.add('   Keywords: ' + blankSafe(keywords));
            docLines.add('   Use Cases: ' + blankSafe(useCases));
            docLines.add('   Requires Account: ' + String.valueOf(r.Core_MDF_Account_Required__c)
                + ' (All Accounts: ' + String.valueOf(r.Core_MDF_All_Accounts__c) + ')');
            docLines.add('   Requires Region: '
                + (r.Core_MDF_WW_Only__c == true ? 'WW only' : blankSafe(r.Core_MDF_Region_Options__c)));
            docLines.add('   Requires Budget: ' + String.valueOf(r.Core_MDF_Budget_Required_When_False__c));
            docLines.add('   Requires Approval Region: ' + String.valueOf(r.Core_MDF_Approval_Region_Required__c));
            docLines.add('   Requires Activity Classification: '
                + String.valueOf(r.Core_MDF_Activity_Classification_Req__c));
            docLines.add('');
            idx++;
        }

        return 'User request: "' + userQuery.escapeJava() + '"\n\n'
            + 'CANDIDATE ROLES:\n' + String.join(docLines, '\n');
    }

    private static final String KNOWLEDGE_BASE_RESOURCE_NAME = 'Core_MDF_IUPGM_RoleReco_KnowledgeBase';
    private static Map<String, Map<String, String>> cachedKnowledgeBase;

    /**
     * Loads and parses the business-maintained role-description CSV (uploaded as a
     * Static Resource) into a map keyed by lowercased Role Label. Cached per-transaction
     * so repeated calls within the same request don't re-query/re-parse. Returns an
     * empty map (never null, never throws) if the Static Resource is missing, empty, or
     * malformed - callers always fall back to live MDT text in that case, so this file
     * is purely additive and can never break role recommendation if it's absent.
     */
    private static Map<String, Map<String, String>> loadRoleKnowledgeBase() {
        if (cachedKnowledgeBase != null) return cachedKnowledgeBase;
        Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
        try {
            List<StaticResource> resources = [
                SELECT Body FROM StaticResource
                WHERE Name = :KNOWLEDGE_BASE_RESOURCE_NAME
                LIMIT 1
            ];
            if (!resources.isEmpty() && resources[0].Body != null) {
                String csvText = resources[0].Body.toString();
                List<String> lines = csvText.replaceAll('\r\n', '\n').split('\n');
                if (!lines.isEmpty()) {
                    List<String> headers = parseCsvLine(lines[0]);
                    Integer labelIdx = headers.indexOf('RoleLabel');
                    if (labelIdx >= 0) {
                        for (Integer i = 1; i < lines.size(); i++) {
                            if (String.isBlank(lines[i])) continue;
                            List<String> cols = parseCsvLine(lines[i]);
                            if (cols.size() <= labelIdx || String.isBlank(cols[labelIdx])) continue;
                            Map<String, String> row = new Map<String, String>();
                            for (Integer c = 0; c < headers.size() && c < cols.size(); c++) {
                                row.put(headers[c], cols[c]);
                            }
                            result.put(cols[labelIdx].trim().toLowerCase(), row);
                        }
                    }
                }
            }
        } catch (Exception ex) {
            // Missing/unreadable/malformed file - silently fall back to live MDT text.
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        cachedKnowledgeBase = result;
        return result;
    }

    /** Minimal CSV line parser - handles quoted fields (with embedded commas/escaped quotes). */
    private static List<String> parseCsvLine(String line) {
        List<String> fields = new List<String>();
        Boolean inQuotes = false;
        String current = '';
        Integer i = 0;
        while (i < line.length()) {
            String ch = line.substring(i, i + 1);
            if (inQuotes) {
                if (ch == '"') {
                    if (i + 1 < line.length() && line.substring(i + 1, i + 2) == '"') {
                        current += '"';
                        i++;
                    } else {
                        inQuotes = false;
                    }
                } else {
                    current += ch;
                }
            } else {
                if (ch == '"') {
                    inQuotes = true;
                } else if (ch == ',') {
                    fields.add(current);
                    current = '';
                } else {
                    current += ch;
                }
            }
            i++;
        }
        fields.add(current);
        return fields;
    }

    private static String blankSafe(String s) {
        return String.isNotBlank(s) ? s : 'N/A';
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // AI CALLOUT (same endpoint/Named Credential already used elsewhere in this org)
    // ═══════════════════════════════════════════════════════════════════════════════

    private static String callGenAI(String systemMessage, String userMessage) {
        String endpointSuffix = Core_MDF_CustomLabelConfig.getTextValues(GENAI_ENDPOINT_LABEL);
        if (String.isBlank(endpointSuffix)) {
            Core_MDF_CCP_UtilityClass.logErrorAsNormal(
                'IUPGM Role Recommendation: GenAI endpoint label not configured (' + GENAI_ENDPOINT_LABEL + ').',
                'Core_MDF_AI_Tracking__c');
            return null;
        }

        Map<String, Object> body = new Map<String, Object>{
            'messages' => new List<Map<String, Object>>{
                new Map<String, Object>{ 'role' => 'system', 'content' => systemMessage },
                new Map<String, Object>{ 'role' => 'user',   'content' => userMessage }
            },
            'temperature' => 0.2,
            'max_tokens'  => 900
        };

        // OPTIONAL platform-level RAG grounding (Azure OpenAI "on your data" style). Only added
        // when a real data source index has been configured - see class header. Still the same
        // endpoint/Named Credential; no new callout target is introduced either way.
        String dataSourceIndex = Core_MDF_CustomLabelConfig.getTextValues(DATA_SOURCE_INDEX_LABEL);
        if (String.isNotBlank(dataSourceIndex)) {
            body.put('data_sources', new List<Object>{
                new Map<String, Object>{
                    'type'       => 'azure_search',
                    'parameters' => new Map<String, Object>{ 'index_name' => dataSourceIndex }
                }
            });
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Core_MDF_CCP_GenAI' + endpointSuffix);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(CALLOUT_TIMEOUT_MS);
        req.setBody(JSON.serialize(body));

        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() != 200) {
            Core_MDF_CCP_UtilityClass.logErrorAsNormal(
                'IUPGM Role Recommendation GenAI callout failed. Status: ' + res.getStatusCode(),
                'Core_MDF_AI_Tracking__c');
            return null;
        }

        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> choices = (List<Object>) parsedJson.get('choices');
        if (choices == null || choices.isEmpty()) return null;
        Map<String, Object> choice = (Map<String, Object>) choices[0];
        Map<String, Object> message = (Map<String, Object>) choice.get('message');
        if (message == null) return null;
        return (String) message.get('content');
    }

    private static Map<String, Object> parseJsonContent(String content) {
        if (String.isBlank(content)) return null;
        try {
            String cleaned = content.replaceAll('```json', '').replaceAll('```', '').trim();
            Integer startIdx = cleaned.indexOf('{');
            Integer endIdx   = cleaned.lastIndexOf('}');
            if (startIdx < 0 || endIdx <= startIdx) return null;
            return (Map<String, Object>) JSON.deserializeUntyped(cleaned.substring(startIdx, endIdx + 1));
        } catch (Exception ex) {
            return null;
        }
    }

    private static Decimal toDecimalOrNull(Object val) {
        if (val == null) return null;
        try {
            return Decimal.valueOf(String.valueOf(val));
        } catch (Exception ex) {
            return null;
        }
    }
}