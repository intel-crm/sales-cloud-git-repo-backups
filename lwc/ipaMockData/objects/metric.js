/** Metric
 * Metric is presented on the center column of the benefits page.
 * @typedef Metric
 * @memberof ipaBenefitService
 * @property {string} id unique metric id
 * @property {string} label the label of the metric
 * @property {Link} link the link of the metric, if all metrics have matching links it will be combined in a bottom button
 * @property {string} value the optional value of the metric
 * @property {string} unit the optional unit of the metric presented in a smaller font
 * @property {string} description the optional description of the metric
 */
import helpers from './helpers/index';
const metricSample = (index) => {
    let mockMetric = [
        {
            "label": "Total MDF",
            "link": {
              "label": "Submit a proposal",
              "externalUrl": "#",
              "communityPage": "",
              "objectPage": "",
              "recordId": ""
            },
            "value": "$20",
            "unit": "M",
            "description": "Guidance amount of $50k and up to 50%"
        },
        {
            "label": "Points expiring soon",
            "link": {
              "label": "Redeem now",
              "externalUrl": "#",
              "communityPage": "",
              "objectPage": "",
              "recordId": ""
            },
            "value": "3",
            "unit": "",
            "description": ""
        },
        {
            "label": "Leads to disposition",
            "link": {
              "label": "Manage Leads",
              "externalUrl": "#",
              "communityPage": "",
              "objectPage": "",
              "recordId": ""
            },
            "value": "3",
            "unit": "",
            "description": ""
        },
        {
            "label": "Dolor set et",
            "link": {
              "label": "Manage specialty",
              "externalUrl": "#",
              "communityPage": "",
              "objectPage": "",
              "recordId": ""
            },
            "value": "2",
            "unit": "",
            "description": ""
        },
        {
            "label": "Company credits needed to maintain status",
            "link": {
              "label": "View courses",
              "externalUrl": "https://www.intel.com",
              "communityPage": "",
              "objectPage": "",
              "recordId": ""
            },
            "value": "20",
            "unit": "",
            "description": ""
        },
        {
            "label": "Individual training credits",
            "link": {
              "label": "View courses",
              "externalUrl": "https://www.intel.com",
              "communityPage": "",
              "objectPage": "",
              "recordId": ""
            },
            "value": "60",
            "unit": "",
            "description": ""
        },
        //IPA2.0:US-4497-1631_OfferingEOL
        // {
        //     "label": "Offers Pending",
        //     "link": {
        //       "label": "Manage offerings",
        //       "externalUrl": "https://www.intel.com",
        //       "communityPage": "",
        //       "objectPage": "",
        //       "recordId": ""
        //     },
        //     "value": "7",
        //     "unit": "",
        //     "description": ""
        // },
        {
            "label": "",
            "link": {
              "label": "Visit Partner Marketing Studio",
              "externalUrl": "https://www.intel.com",
              "communityPage": "",
              "objectPage": "",
              "recordId": ""
            },
            "value": "",
            "unit": "",
            "description": ""
        },
        {
            "label": "SLA",
            "link": {
              "label": "Create support ticket",
              "externalUrl": "https://www.intel.com",
              "communityPage": "",
              "objectPage": "",
              "recordId": ""
            },
            "value": "4",
            "unit": "HR",
            "description": ""
        },
        {
            "label": "Advanced warranty replacment units",
            "link": {
              "label": "New warranty return",
              "externalUrl": "https://www.intel.com",
              "communityPage": "",
              "objectPage": "",
              "recordId": ""
            },
            "value": "25",
            "unit": "",
            "description": ""
        },
        {
            "label": "Lorem Ipsum",
            "link": {
              "label": "Manage select",
              "externalUrl": "https://www.intel.com",
              "communityPage": "",
              "objectPage": "",
              "recordId": ""
            },
            "value": "4",
            "unit": "",
            "description": ""
        },
        {
            "label": "Double footer training credits1",
            "link": {
              "label": "View courses",
              "externalUrl": "https://www.intel.com",
              "communityPage": "",
              "objectPage": "",
              "recordId": ""
            },
            "value": "40",
            "unit": "",
            "description": "Footer 1 lorem ipsum"
        },
        {
            "label": "Double footer training credits2",
            "link": {
              "label": "View courses",
              "externalUrl": "https://www.intel.com",
              "communityPage": "",
              "objectPage": "",
              "recordId": ""
            },
            "value": "50",
            "unit": "",
            "description": "Footer 2 lorem ipsum"
        },



    ]
    return index>-1  && mockMetric.length > index ? mockMetric[index] : helpers.sample(mockMetric);
}

export const mockMetrics = (indexList) => {
    let result = [];

    if (Array.isArray(indexList)){
        for (let value of indexList){
            result.push(metricSample(value));
        }
    } else {
        result.push(metricSample());
    }

    return result;
}