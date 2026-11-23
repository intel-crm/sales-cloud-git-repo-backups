<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Document - Collapsible Docs</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: "Salesforce Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            overflow: hidden;
        }

        header {
            background: #d3d3d3;
            text-align: center;
        }

        header h1 {
            font-size: 2.2rem;
            margin-bottom: 8px;
            font-weight: 700;
        }

        header p {
            opacity: 0.95;
            font-size: 1rem;
        }

        .toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            padding: 16px 24px;
            border-bottom: 1px solid #e6e6e6;
            background: #fafbff;
            flex-wrap: wrap;
        }

        .version-chip {
            background: #e8f5e9;
            color: #2e7d32;
            border-radius: 999px;
            padding: 8px 14px;
            font-size: 0.9rem;
            font-weight: 600;
        }

        .version-dropdown {
            position: relative;
            display: inline-block;
        }

        .version-dropdown-btn {
            background: #e8f5e9;
            color: #2e7d32;
            border-radius: 999px;
            padding: 8px 14px;
            font-size: 0.9rem;
            font-weight: 600;
            border: none;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .version-dropdown-btn:hover {
            background: #c8e6c9;
        }

        .version-dropdown-content {
            display: none;
            position: absolute;
            background-color: #f9f9f9;
            min-width: 200px;
            box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
            padding: 12px 16px;
            z-index: 1;
            border-radius: 6px;
            top: 100%;
            margin-top: 8px;
        }

        .version-dropdown-content a {
            color: black;
            padding: 12px 16px;
            text-decoration: none;
            display: block;
            cursor: pointer;
        }

        .version-dropdown-content a:hover {
            background-color: #f1f1f1;
            border-radius: 4px;
        }

        .version-dropdown:hover .version-dropdown-content {
            display: block;
        }

        .toolbar-actions button {
            border: 0;
            background: #667eea;
            color: #fff;
            border-radius: 6px;
            padding: 8px 12px;
            cursor: pointer;
            margin-left: 8px;
            font-weight: 600;
        }

        .toolbar-actions button:hover {
            background: #4f67d6;
        }

        main {
            padding: 24px;
        }

        .note {
            margin-bottom: 18px;
            background: #eef3ff;
            border-left: 4px solid #667eea;
            padding: 12px 14px;
            border-radius: 6px;
        }

        .accordion {
            display: grid;
            gap: 14px;
        }

        .panel {
            border: 1px solid #dde3f1;
            border-radius: 8px;
            overflow: hidden;
            background: #fff;
        }

        .panel button {
            border: 0;
            background: #f6f8ff;
            color: #1d2b53;
            text-align: left;
            padding: 16px 18px;
            font-weight: 700;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
        }

        .panel button:hover {
            background: #eef2ff;
        }

        .panel button .meta {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
        }

        .method {
            display: inline-block;
            font-size: 0.75rem;
            background: #ffc107;
            color: #fff;
            border-radius: 4px;
            padding: 3px 8px;
            letter-spacing: 0.3px;
        }

        .chevron {
            transition: transform 0.2s ease;
            font-size: 1.15rem;
        }

        .panel.open .chevron {
            transform: rotate(180deg);
        }

        .panel-content {
            display: none;
            padding: 16px;
            border-top: 1px solid #e6ebf7;
            background: #fff;
        }

        .panel.open .panel-content {
            display: block;
        }

        .container-panel {
            border-color: #c7d3fb;
        }

        .container-panel > button {
            background: linear-gradient(135deg, #eef2ff 0%, #f6f8ff 100%);
        }

        .container-panel .panel-content {
            background: #fbfcff;
        }

        .endpoint {
            background: #f9fbff;
            border: 1px solid #e6ebf7;
            border-radius: 6px;
            padding: 12px;
            margin-bottom: 14px;
            font-family: Consolas, Monaco, "Courier New", monospace;
            font-size: 0.92rem;
            overflow-x: auto;
        }

        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
        }

        @media (max-width: 980px) {
            .grid {
                grid-template-columns: 1fr;
            }
        }

        .box {
            border: 1px solid #e3e3e3;
            border-radius: 6px;
            overflow: hidden;
            background: #fff;
        }

        .box h4 {
            padding: 10px 12px;
            background: #f6f6f8;
            border-bottom: 1px solid #e3e3e3;
            font-size: 0.95rem;
        }

        pre {
            margin: 0;
            padding: 12px;
            background: #1e1e1e;
            color: #d4d4d4;
            overflow-x: auto;
            font-size: 0.85rem;
            line-height: 1.5;
        }

        .tip {
            margin-top: 12px;
            background: #e8f5e9;
            border-left: 4px solid #43a047;
            border-radius: 6px;
            padding: 10px 12px;
        }

        footer {
            border-top: 1px solid #ececec;
            background: #fafafa;
            padding: 14px 18px;
            text-align: center;
            color: #666;
            font-size: 0.9rem;
        }

        .download-btn {
            background: #667eea;
            color: #fff;
            border: none;
            border-radius: 4px;
            padding: 2px 7px;
            font-size: 0.65rem;
            cursor: pointer;
            font-weight: 600;
            line-height: 1.2;
            width: auto;
            min-width: 62px;
            flex: 0 0 auto;
            transition: background 0.2s ease;
        }

        .download-btn:hover {
            background: #4f67d6;
        }

        .api-section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
            padding: 8px 10px;
            background: #f6f6f8;
            border-bottom: 1px solid #e3e3e3;
        }

        .api-section-header h4 {
            flex: 1;
            margin: 0;
            padding: 0;
            background: transparent;
            border: 0;
            font-size: 0.85rem;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>API Document</h1>
        </header>

        <div class="toolbar">
            <div class="version-dropdown">
                <button class="version-dropdown-btn" type="button">
                    Version 1.0.0 (Current)
                    <span>▼</span>
                </button>
                <div class="version-dropdown-content">
                    <a href="#v1.0.0">Version 1.0.0 (Current)</a>
                    <a href="#v0.9.0">Version 0.9.0 (Beta)</a>
                </div>
            </div>
            <div class="toolbar-actions">
                <button type="button" id="expandAll">Expand All</button>
                <button type="button" id="collapseAll">Collapse All</button>
            </div>
        </div>

        <main>

            <section class="accordion" id="apiAccordion">
                <article class="panel open container-panel" id="pfrApiContainer">
                    <button type="button" class="panel-toggle" id="pfrApiContainerToggle">
                        <span># PFR Activity API</span>
                        <span class="meta">
                            <span class="chevron">▼</span>
                        </span>
                    </button>
                    <div class="panel-content">
                        <section class="accordion" id="pfrActivityAccordion">
                            <article class="panel open">
                                <button type="button" class="panel-toggle">
                                    <span>Create Activity</span>
                                    <span class="meta">
                                        <span class="method">POST</span>
                                        <span class="chevron">▼</span>
                                    </span>
                                </button>
                                <div class="panel-content">
                                    <div class="endpoint">
                                        https://<Org Instance URL>/services/apexrest/v1.0/activity?action=create
                                    </div>

                                    <div class="grid">
                                        <div class="box">
                                            <div class="api-section-header">
                                                <h4>Request Body (Create)</h4>
                                                <button class="download-btn" onclick="downloadJSON('create-request', 'Create-Activity-Request.json')">⬇ Download</button>
                                            </div>
                                            <pre id="create-request">{
  "activity": {
    "ActivityName": "Q3 2026 Marketing Push",
    "ActivityDescription": "Digital marketing campaign",
    "StartDate": "2026-06-07",
    "EndDate": "2026-06-30",
    "Campaign": "00013107",
    "Priority": "AI PC - Commercial",
    "AccountName": "DELL Corp EMEA",
    "BudgetType": "OEM CMP",
    "ActivitySpendingLimitLocal": 5000.00,
    "ReimbursementRate": "50",
    "TargetAudience": "Enterprise",
    "Country": "USA;CANADA",
    "Brand": "Intel Core",
    "ProductType": "Chromebook",
    "BudgetReferenceNumber": "BUD-02988",
    "ActivityCategory": "Digital",
    "ActivityTypes": "Email Campaign",
    "EcosystemPartner": "Dell",
    "Industry": "Technology",
    "MemberAcceptorUsername": "user@intel.com",
    "Currency": "USD"
  }
}</pre>
                                        </div>

                                        <div class="box">
                                            <div class="api-section-header">
                                                <h4>Response (201)</h4>
                                                <button class="download-btn" onclick="downloadJSON('create-response', 'Create-Activity-Response.json')">⬇ Download</button>
                                            </div>
                                            <pre id="create-response">{
  "isSuccess": true,
  "code": "201",
  "message": "Success",
  "totalRecords": 1,
  "successContent": [
    {
      "activityNumber": "00046418",
      "pfrName": "Q3 2026 Marketing Push",
      "status": "Pending Approval",
      "createdDate": "2026-06-29T14:25:31Z"
    }
  ],
  "failureContent": null
}</pre>
                                        </div>
                                    </div>

                                    <div class="tip">
                                        Create requires all mandatory business fields and performs full validation.
                                    </div>
                                </div>
                            </article>

                            <article class="panel">
                                <button type="button" class="panel-toggle">
                                    <span>Field Reference</span>
                                    <span class="meta">
                                        <span class="chevron">▼</span>
                                    </span>
                                </button>
                                <div class="panel-content">
                                    <div class="box">
                                        <h4>Key Fields</h4>
                                        <pre>Required on Create:
- ActivityName
- ActivityDescription
- StartDate
- EndDate
- Campaign
- AccountName
- Priority
- BudgetType
- ActivitySpendingLimitLocal
- ReimbursementRate
- TargetAudience
- Country
- Brand
- ProductType
- BudgetReferenceNumber
- ActivityCategory
- ActivityTypes
- EcosystemPartner
- Industry
- MemberAcceptorUsername
- Currency

Optional:
- Files
- RequestedAmount
- ReimbursementAmt

Conditional:
- EventName when ActivityCategory = Event
- DomainType when ActivityCategory = Digital</pre>
                                    </div>
                                </div>
                            </article>

                            <article class="panel">
                                <button type="button" class="panel-toggle">
                                    <span>Error Codes</span>
                                    <span class="meta">
                                        <span class="chevron">▼</span>
                                    </span>
                                </button>
                                <div class="panel-content">
                                    <div class="box">
                                        <h4>Common Error Codes</h4>
                                        <pre>ERR-9015: Required field missing
ERR-9014: Invalid field value/type
ERR-9030: Invalid Activity Category
ERR-9031: Invalid Activity Type
ERR-9012: Lookup could not be resolved
ERR-9013: Lookup matched multiple records
ERR-9025: Channel Partner cannot be updated
ERR-9006: Business validation failed
ERR-9000: Technical/server error</pre>
                                    </div>
                                </div>
                            </article>
                        </section>
                    </div>
                </article>

                <article class="panel open container-panel" id="campaignApiContainer">
                    <button type="button" class="panel-toggle" id="campaignApiContainerToggle">
                        <span># Campaign Creation API</span>
                        <span class="meta">
                            <span class="chevron">▼</span>
                        </span>
                    </button>
                    <div class="panel-content">
                        <section class="accordion" id="campaignActivityAccordion">
                            <article class="panel open">
                                <button type="button" class="panel-toggle">
                                    <span>Create Campaign</span>
                                    <span class="meta">
                                        <span class="method">POST</span>
                                        <span class="chevron">▼</span>
                                    </span>
                                </button>
                                <div class="panel-content">
                                    <div class="endpoint">
                                        https://<Org Instance URL>/services/apexrest/v1.0/campaign?action=create
                                    </div>

                                    <div class="grid">
                                        <div class="box">
                                            <div class="api-section-header">
                                                <h4>Request Body (Create Campaign)</h4>
                                                <button class="download-btn" onclick="downloadJSON('campaign-create-request', 'Campaign-Create-Request.json')">⬇ Download</button>
                                            </div>
                                            <pre id="campaign-create-request">{
  "details": {
    "Core_MDF_Campaign_Outcomes__c": [
      {
        "Goal Value": 1,
        "Outcome Metric": "Revenue - Pipelines/Opportunities"
      }
    ],
    "Core_MDF_Campaign_Budgets__c": [],
    "details": {
      "Status": "Planned",
      "Start Date": "2026-07-03",
      "Name": "Test CCF External API Validation Campaign - Json",
      "End Date": "2026-07-23",
      "Description": "Test",
      "Technology": "ACPC;Intel vPro;X Series;Xeon",
      "Program": "Client",
      "Product Type": "2-in-1;All-in-one;Desktop",
      "Priority #3": null,
      "Priority #2": "AI PC & Consumer",
      "Priority": "AI PC - Commercial",
      "Outcome Metric": "Revenue - Pipelines/Opportunities",
      "Other Outcome Metric": null,
      "Budget type": "MDF;MDF+;OEM CMP",
      "Theme / Messaging": null,
      "Member Solution": null,
      "Marketing Objective / Strategy": null,
      "Country": "CAYMAN ISLANDS;CHAD;CHILE",
      "Key Performance Indicator": "Test",
      "Industry": "Arts, Entertainment and Recreation;Automotive (Non Manufacturing)",
      "Brand": "Intel® Corporate Logo;Intel® Xeon® Processor;Intel® Core™ i3 Processor",
      "Audience": "Commercial;Consumer;Creator;Gamer;Partner Sales Force;Small and Medium Business;Enterprise",
      "Activity Type": "Outcome-Based",
      "Activity Category ->Type": "Outcome-Based->Outcome-Based",
      "Account": "001D300000qsxfZIAQ"
    }
  }
}</pre>
                                        </div>

                                        <div class="box">
                                            <div class="api-section-header">
                                                <h4>Response (200)</h4>
                                                <button class="download-btn" onclick="downloadJSON('campaign-create-response', 'Campaign-Create-Response.json')">⬇ Download</button>
                                            </div>
                                            <pre id="campaign-create-response">{
  "isSuccess": true,
  "success": {
    "code": "200",
    "message": "Campaign details retrieved successfully"
  },
  "details": {
    "campaignId": "701xx0000000123",
    "campaignName": "Test CCF External API Validation Campaign - Json",
    "status": "Planned",
    "startDate": "2026-07-03",
    "endDate": "2026-07-23",
    "program": "Client",
    "account": "001D300000qsxfZIAQ",
    "createdDate": "2026-07-06T10:30:45Z",
    "recordUrl": "/campaign/701xx0000000123"
  }
}</pre>
                                        </div>
                                    </div>

                                    <div class="tip">
                                        Create Campaign requires all mandatory business fields. Outcomes and Budgets are child records and can be included in the request.
                                    </div>
                                </div>
                            </article>

                            <article class="panel">
                                <button type="button" class="panel-toggle">
                                    <span>Campaign Fields Reference</span>
                                    <span class="meta">
                                        <span class="chevron">▼</span>
                                    </span>
                                </button>
                                <div class="panel-content">
                                    <div class="box">
                                        <h4>Required Fields</h4>
                                        <pre>Mandatory Campaign Fields:
- Name
- Account
- Start Date
- End Date
- Status
- Program
- Activity Type
- Audience
- Brand
- Country
- Industry
- Product Type
- Budget type
- Outcome Metric

Optional Fields:
- Description
- Theme / Messaging
- Member Solution
- Marketing Objective / Strategy
- Other Outcome Metric
- Key Performance Indicator
- Priority
- Priority #2
- Priority #3
- Technology

Child Records:
- Core_MDF_Campaign_Outcomes__c (Array)
- Core_MDF_Campaign_Budgets__c (Array)</pre>
                                    </div>
                                </div>
                            </article>

                            <article class="panel">
                                <button type="button" class="panel-toggle">
                                    <span>Error Codes</span>
                                    <span class="meta">
                                        <span class="chevron">▼</span>
                                    </span>
                                </button>
                                <div class="panel-content">
                                    <div class="box">
                                        <h4>Common Error Codes</h4>
                                        <pre>ERR-8001: Required field missing
ERR-8002: Invalid field value
ERR-8003: Account not found
ERR-8004: Program not supported
ERR-8005: Duplicate campaign name
ERR-8006: Invalid date range
ERR-8007: Business validation failed
ERR-8008: Child record creation failed
ERR-8000: Technical/server error</pre>
                                    </div>
                                </div>
                            </article>
                        </section>
                    </div>
                </article>

                <article class="panel open container-panel" id="picklistApiContainer">
                    <button type="button" class="panel-toggle" id="picklistApiContainerToggle">
                        <span># CampaignToActivity Picklist API</span>
                        <span class="meta">
                            <span class="chevron">▼</span>
                        </span>
                    </button>
                    <div class="panel-content">
                        <section class="accordion" id="picklistActivityAccordion">
                            <article class="panel open">
                                <button type="button" class="panel-toggle">
                                    <span>Get Picklist Values</span>
                                    <span class="meta">
                                        <span class="method">GET</span>
                                        <span class="chevron">▼</span>
                                    </span>
                                </button>
                                <div class="panel-content">
                                    <div class="endpoint">
                                        https://<Org Instance URL>/services/apexrest/v1.0/activitymetadata/picklist-values?campaignId=701xx0000000123
                                    </div>

                                    <div class="grid">
                                        <div class="box">
                                            <div class="api-section-header">
                                                <h4>Query Parameters</h4>
                                                <button class="download-btn" onclick="downloadJSON('picklist-params', 'Picklist-Parameters.json')">⬇ Download</button>
                                            </div>
                                            <pre id="picklist-params">{
  "campaignId": "701xx0000000123 (Optional - Campaign ID to filter picklist values)"
}</pre>
                                        </div>

                                        <div class="box">
                                            <div class="api-section-header">
                                                <h4>Response (200)</h4>
                                                <button class="download-btn" onclick="downloadJSON('picklist-response', 'Picklist-Response.json')">⬇ Download</button>
                                            </div>
                                            <pre id="picklist-response">{
  "isSuccess": true,
  "code": "200",
  "message": "Success",
  "campaignId": "701xx0000000123",
  "campaignName": "Q3 2026 Campaign",
  "fields": [
    {
      "fieldName": "ActivityCategory",
      "label": "Activity Category",
      "values": [
        "Digital",
        "Event",
        "Co-Marketing"
      ]
    },
    {
      "fieldName": "ActivityType",
      "label": "Activity Type",
      "values": [
        "Email Campaign",
        "Webinar",
        "Trade Show"
      ],
      "dependentOn": "Activity Category",
      "dependentValues": {
        "Digital": ["Email Campaign", "Social Media"],
        "Event": ["Trade Show", "Webinar"]
      }
    },
    {
      "fieldName": "TargetAudience",
      "label": "Target Audience",
      "values": [
        "Enterprise",
        "SMB",
        "Consumer"
      ]
    }
  ]
}</pre>
                                        </div>
                                    </div>

                                    <div class="tip">
                                        Get Picklist Values returns all available picklist options for Activity fields. Use campaignId parameter to filter values based on campaign configuration.
                                    </div>
                                </div>
                            </article>

                            <article class="panel">
                                <button type="button" class="panel-toggle">
                                    <span>Campaign to Activity Field Mapping</span>
                                    <span class="meta">
                                        <span class="chevron">▼</span>
                                    </span>
                                </button>
                                <div class="panel-content">
                                    <div class="box">
                                        <h4>Field Mappings</h4>
                                        <pre>Campaign Fields -> Activity Fields Mapping:

Core_MDF_Activity_Category__c -> Core_MDF_ActivityCategory__c
Core_MDF_Activity_Type__c -> Core_MDF_Activity_Types__c
Core_MDF_Audience__c -> Core_MDF_TargetAudience__c
Core_MDF_Market__c -> Core_MDF_Country_nm__c
Core_MDF_Brand__c -> Core_MDF_Brand_nm__c
Core_MDF_Product_Type__c -> Core_MDF_ProductType__c
Core_MDF_Industry_Nm__c -> Core_MDF_Industry_Multi_nm__c
Core_MDF_Opal_Budget_Type_Txt__c -> Core_MDF_Opal_Budget_Type_Txt__c

Notes:
- Dependent fields are controlled by their parent field selections
- Only active picklist values are returned
- Campaign restrictions filter applicable values</pre>
                                    </div>
                                </div>
                            </article>

                            <article class="panel">
                                <button type="button" class="panel-toggle">
                                    <span>Error Codes</span>
                                    <span class="meta">
                                        <span class="chevron">▼</span>
                                    </span>
                                </button>
                                <div class="panel-content">
                                    <div class="box">
                                        <h4>Common Error Codes</h4>
                                        <pre>ERR-9001: Campaign not found
ERR-9002: Invalid campaign ID
ERR-9003: Campaign access denied
ERR-9004: Invalid query parameters
ERR-9005: Field metadata unavailable
ERR-9000: Technical/server error</pre>
                                    </div>
                                </div>
                            </article>
                        </section>
                    </div>
                </article>

                <article class="panel open container-panel" id="fileUploadApiContainer">
                    <button type="button" class="panel-toggle" id="fileUploadApiContainerToggle">
                        <span># File Upload API</span>
                        <span class="meta">
                            <span class="chevron">▼</span>
                        </span>
                    </button>
                    <div class="panel-content">
                        <section class="accordion" id="fileUploadAccordion">
                            <article class="panel open">
                                <button type="button" class="panel-toggle">
                                    <span>Upload File</span>
                                    <span class="meta">
                                        <span class="method">POST</span>
                                        <span class="chevron">▼</span>
                                    </span>
                                </button>
                                <div class="panel-content">
                                    <div class="endpoint">
                                        https://<Org Instance URL>/services/apexrest/v1.0/activity/uploadfile
                                    </div>

                                    <div class="grid">
                                        <div class="box">
                                            <div class="api-section-header">
                                                <h4>Request Body (Upload File)</h4>
                                                <button class="download-btn" onclick="downloadJSON('file-upload-request', 'File-Upload-Request.json')">⬇ Download</button>
                                            </div>
                                            <pre id="file-upload-request">{
  "activity": "0RJdh0000001RRBGA2",
  "FileName": "Testduplicateremovaltestfile.xlsx",
  "file": "UEsDBBQAAAAIAAAAIQA2F+/ikwEAAGoIAAATAAAAW0NvbnRlbnRfVHlwZXNdLnhtbMyWyW7CMBRF95X6D5G3VWKgoyoCiw7LFqn0A9z4JbHwJNtMf1/bhIoiCq1AajZxYvu+e3wTJ+kPF4InMzCWKZmjbtZBCchCUSarHL2Pn9M7lFhHJCVcScjREiwaDs7P+uOlBpt4tbQ5qp3T9xjbogZBbKY0SD9SKiOI85emwpoUE1IB7nU6N7hQ0oF0qQs10KD/CCWZcpc8LXz3ikTLCiUPq3nBKkdMBH3oxzsVBrjdkhCtOSuI82vDM0m3uNKGKfPKOMfWTNsLD/6DQxj5zrRp0OhefZiGUUhGxLgXIjw5XnA8V2byodQk219kB6UqS1YAVcVU+Mwyqw0QamsAJ3gW20wQJtfcu/y9eGSUtj54A38nWOcU1Kn2hcA4Bl9J7XX0CR29ZAiPBQX6S+8m7RiNxbHpnjj2cDdj4X2p7+DotYTjsiUcVy3huG4Jx01LOG7/icP57wfgeDx+y8YyBzaodUsO9tQv5Vj0kHNNDN",
  "comment": "Testing upload"
}</pre>
                                        </div>

                                        <div class="box">
                                            <div class="api-section-header">
                                                <h4>Response (200)</h4>
                                                <button class="download-btn" onclick="downloadJSON('file-upload-response', 'File-Upload-Response.json')">⬇ Download</button>
                                            </div>
                                            <pre id="file-upload-response">{
  "isSuccess": true,
  "code": "200",
  "message": "File uploaded successfully",
  "data": {
    "fileId": "00Pxx0000000001",
    "fileName": "Testduplicateremovaltestfile.xlsx",
    "fileSize": 1024,
    "uploadedDate": "2026-07-06T14:30:45Z",
    "activity": "0RJdh0000001RRBGA2",
    "comment": "Testing upload",
    "contentVersion": "0680J0000005K23QAE"
  }
}</pre>
                                        </div>
                                    </div>

                                    <div class="tip">
                                        Upload File requires Base64 encoded file content. Maximum file size is 25MB. Supported formats: PDF, Excel, Word, Images, Text.
                                    </div>
                                </div>
                            </article>

                            <article class="panel">
                                <button type="button" class="panel-toggle">
                                    <span>File Fields Reference</span>
                                    <span class="meta">
                                        <span class="chevron">▼</span>
                                    </span>
                                </button>
                                <div class="panel-content">
                                    <div class="box">
                                        <h4>Request Fields</h4>
                                        <pre>Required Fields:
- activity (String): Activity ID or Record ID (0RJxx format)
- FileName (String): Name of the file to upload (max 255 characters)
- file (String): Base64 encoded file content

Optional Fields:
- comment (String): Comment or description for the uploaded file (max 500 characters)

Response Fields:
- isSuccess (Boolean): Indicates if upload was successful
- code (String): HTTP status code
- message (String): Success or error message
- data (Object): Contains file details
  - fileId: Unique identifier for uploaded file
  - fileName: Name of uploaded file
  - fileSize: Size of file in bytes
  - uploadedDate: Timestamp of upload
  - activity: Associated activity ID
  - comment: User comment/description
  - contentVersion: Salesforce ContentVersion ID</pre>
                                    </div>
                                </div>
                            </article>

                            <article class="panel">
                                <button type="button" class="panel-toggle">
                                    <span>Error Codes</span>
                                    <span class="meta">
                                        <span class="chevron">▼</span>
                                    </span>
                                </button>
                                <div class="panel-content">
                                    <div class="box">
                                        <h4>Common Error Codes</h4>
                                        <pre>ERR-7001: Required field missing (activity, file, or FileName)
ERR-7002: Invalid activity ID format
ERR-7003: Activity record not found
ERR-7004: File size exceeds maximum limit (25MB)
ERR-7005: Invalid file format or corrupted file
ERR-7006: File encoding error (invalid Base64)
ERR-7007: FileName exceeds maximum length
ERR-7008: Insufficient storage space
ERR-7009: File upload permission denied
ERR-7000: Technical/server error</pre>
                                    </div>
                                </div>
                            </article>
                        </section>
                    </div>
                </article>
            </section>
        </main>

        <footer>
            <div>API Document | Core MDF PFR Activity API | Last Updated: 2026-07-06</div>
            <div style="margin-top: 10px; font-size: 0.85rem;">
                <a href="https://intel--crmdevccp.sandbox.my.site.com/Partnercenter/s/" target="_blank" style="color: #667eea; text-decoration: none;">Partner Center</a> | 
                <a href="https://intel--crmdevccp.sandbox.my.site.com/Partnercenter/s/resource/1782791977000/CoreMDFAPIDocumentation" target="_blank" style="color: #667eea; text-decoration: none;">Documentation</a> | 
                Generated for Community Usage
            </div>
        </footer>
    </div>

    <script>
        const apiContainer = document.getElementById("pfrApiContainer");
        const apiContainerToggle = document.getElementById("pfrApiContainerToggle");
        const campaignContainer = document.getElementById("campaignApiContainer");
        const campaignContainerToggle = document.getElementById("campaignApiContainerToggle");
        const picklistContainer = document.getElementById("picklistApiContainer");
        const picklistContainerToggle = document.getElementById("picklistApiContainerToggle");
        const fileUploadContainer = document.getElementById("fileUploadApiContainer");
        const fileUploadContainerToggle = document.getElementById("fileUploadApiContainerToggle");
        const pfrPanels = Array.from(document.querySelectorAll("#pfrActivityAccordion .panel"));
        const campaignPanels = Array.from(document.querySelectorAll("#campaignActivityAccordion .panel"));
        const picklistPanels = Array.from(document.querySelectorAll("#picklistActivityAccordion .panel"));
        const fileUploadPanels = Array.from(document.querySelectorAll("#fileUploadAccordion .panel"));
        const allPanels = [...pfrPanels, ...campaignPanels, ...picklistPanels, ...fileUploadPanels];

        apiContainerToggle.addEventListener("click", () => {
            apiContainer.classList.toggle("open");
        });

        campaignContainerToggle.addEventListener("click", () => {
            campaignContainer.classList.toggle("open");
        });

        picklistContainerToggle.addEventListener("click", () => {
            picklistContainer.classList.toggle("open");
        });

        fileUploadContainerToggle.addEventListener("click", () => {
            fileUploadContainer.classList.toggle("open");
        });

        allPanels.forEach((panel) => {
            const toggle = panel.querySelector(".panel-toggle");
            toggle.addEventListener("click", () => {
                panel.classList.toggle("open");
            });
        });

        document.getElementById("expandAll").addEventListener("click", () => {
            apiContainer.classList.add("open");
            campaignContainer.classList.add("open");
            picklistContainer.classList.add("open");
            fileUploadContainer.classList.add("open");
            allPanels.forEach((p) => p.classList.add("open"));
        });

        document.getElementById("collapseAll").addEventListener("click", () => {
            apiContainer.classList.remove("open");
            campaignContainer.classList.remove("open");
            picklistContainer.classList.remove("open");
            fileUploadContainer.classList.remove("open");
            allPanels.forEach((p) => p.classList.remove("open"));
        });

        // Download JSON function
        function downloadJSON(elementId, filename) {
            const element = document.getElementById(elementId);
            const jsonText = element.innerText;
            const blob = new Blob([jsonText], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.download = filename;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(url);
        }
    </script>
</body>
</html>
