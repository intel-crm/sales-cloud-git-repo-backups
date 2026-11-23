/** Benefit
 * Data used to represent a blade in the partner benefits page
 * @typedef Benefit
 * @memberof ipaBenefitService
 * @property {string} id the id of the benefit
 * @property {string} title the title of the benefit
 * @property {string} faIcon the font awesome icon name
 * @property {string} description the optional description for the metric
 * @property {ipaBenefitService.Alert[]} alerts the optional alerts for the metric 1 or more, it will highlight the metric
 * @property {ipaBenefitService.Metric[]} metrics the optional metric presented on the middle column
 * @property {Link[]} links the links to be rendered on the 3rd column of the benefit
 * @property {ipaBenefitService.Contacts} contacts the links to be rendered on the 3rd column of the benefit
 */

import helpers from './helpers/index';
import {mockMetrics} from './metric';
import {mockAlert} from './alert';
import {mockLinks} from './link';
import {mockContacts} from './contact';

const benefitsSample = () => {
    return [
        {
            id: helpers.id(),
            title: "MDF",
            faIcon: "fa-envelope-open-dollar-o",
            description: "Apply for and use Marketing Development Funds to help grow your business.",
            alerts: [mockAlert()],
            metrics: mockMetrics([0]),
            links: mockLinks([0,1,2]),
            contacts: []
        },
        {
            id: helpers.id(),
            title: "Points",
            faIcon: "fa-coins-o",
            description: "Earn points for your purchases of Intel products and redeem them for exclusive rewards.",
            alerts: [mockAlert(), mockAlert()],
            metrics: mockMetrics([1]),
            links: mockLinks([3,4,5,6,7,8]),
            contacts: []
        },
        {
            id: helpers.id(),
            title: "Leads",
            faIcon: "fa-user-check-o",
            description: "Track and develop the sales leads you generate from your Intel partner marketing activities.",
            alerts: [],
            metrics: mockMetrics([2]),
            links: mockLinks([9,10]),
            contacts: []
        },
        {
            id: helpers.id(),
            title: "Cloud Specialty Benefit",
            faIcon: "fa-cloud-o",
            description: "Plan, implement, and deliver your cloud solutions with exclusive Intel resources and perks.",
            alerts: [],
            metrics: mockMetrics([3]),
            links: mockLinks([9,10]),
            contacts: []
        },
        {
            id: helpers.id(),
            title: "Training",
            faIcon: "fa-graduation-cap-1",
            description: "Gain knowledge and expand your skillset with training courses tailored to your career.",
            alerts: [],
            metrics: mockMetrics([4,5]),
            links: mockLinks([11,12,13,14,15]),
            contacts: []
        },
        {
            id: helpers.id(),
            title: "Marketplace",
            faIcon: "fa-store-o",
            description: "Bring your Intel-based products and services to market, connect with other partners, and find what you need.",
            alerts: [],
            metrics: mockMetrics([6]),
            links: mockLinks([16,17,18]),
            contacts: []
        },
        {
            id: helpers.id(),
            title: "Marketing Studio",
            faIcon: "fa-picture",
            description: "Access our library of customizable marketing assets and tools to help you promote your business.",
            alerts: [],
            metrics: mockMetrics([7]),
            links: mockLinks([19,20]),
            contacts: []
        },
        {
            id: helpers.id(),
            title: "Titanium Tier Partner Support",
            faIcon: "fa-question-circle-o",
            description: "Create and check the status of a support ticket—you're entitled to four-hour turnaround time.",
            alerts: [],
            metrics: mockMetrics([8,9]),
            links: mockLinks([21,22]),
            contacts: mockContacts()
        },
        {
            id: helpers.id(),
            title: "Lorem Select Benefit",
            faIcon: "fa-box-dollar-o",
            description: "Curabitur blandit tempus porttitor. Vestibulum id ligula porta felis euismod semper.",
            alerts: [],
            metrics: mockMetrics([10]),
            links: mockLinks([9,10]),
            contacts: []
        },
        {
            id: helpers.id(),
            title: "Lorem Test Same CTA Double footers ",
            faIcon: "fa-box-dollar-o",
            description: "Curabitur blandit tempus porttitor. Vestibulum id ligula porta felis euismod semper.",
            alerts: [],
            metrics: mockMetrics([11,12]),
            links: mockLinks([9,10]),
            contacts: []
        },
        {
            id: helpers.id(),
            title: "Lorem Test Same CTA Different footers Different CTA ",
            faIcon: "fa-box-dollar-o",
            description: "Curabitur blandit tempus porttitor. Vestibulum id ligula porta felis euismod semper.",
            alerts: [],
            metrics: mockMetrics([11,12,0]),
            links: mockLinks([9,10]),
            contacts: []
        },
        {
            id: helpers.id(),
            title: "Lorem Test Same Empty Metric Test ",
            faIcon: "fa-box-dollar-o",
            description: "Curabitur blandit tempus porttitor. Vestibulum id ligula porta felis euismod semper.",
            alerts: [],
            metrics: mockMetrics([13,13,13,13,13]),
            links: mockLinks([9,10]),
            contacts: []
        }
    ];
}


export const mockBenefits = () => {
    return {
      benefitInfo: benefitsSample(),
      summaryDescription: 'Summary Description'
    }
}