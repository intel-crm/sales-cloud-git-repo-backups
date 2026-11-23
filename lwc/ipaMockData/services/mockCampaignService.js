import { mockPartner } from '../objects/partner';
import { mockProduct } from '../objects/product';

export default {

    getCampaignCards: async ({ campaignId, cardType, page, perPage }) => {
        let log = false;
        if (log) console.log('getCampaignCards params: ', campaignId, cardType, page, perPage);
        let cards = [];
        if (cardType === 'partner') {
            while (cards.length < Math.floor(Math.random() * 20)) cards.push(mockPartner());
        }
        if (cardType === 'product') {
            while (cards.length <( Math.floor(Math.random() * 20) + 5)) cards.push(mockProduct());
        }
        if (Date.now() % 3 === 0) cards = [];
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        //await new Promise(r => setTimeout(r, 1000)) // mock server delay
        return {
            heading: 'Covid-19 ' + (cardType === 'partner' ? 'Partners' : 'Offerings'), // use for dynamic heading
            cards,
            // total: 73 // only needed if lazy loaded (page param passed in)
        }
    },

    getCampaignPromos: async ({ campaignId }) => {
        let promos = [];
        while (promos.length < (Math.floor(Math.random() * 10) + 1)) {
            promos.push({
                image: 'https://www.intel.com/content/dam/www/public/us/en/images/corporate/rwd/csr-2019-header-graphic-rwd.jpg.rendition.intel.web.576.324.jpg',
                title: 'Promo-' + promos.length + ' for (' + campaignId + ')',
                description: 'Eligendi itaque consequatur esse magni labore alias rerum rerum sapiente',
                linkLabel: 'Lorem ipsum delor',
                linkExternalUrl: 'https://www.intel.com'
            });
        }
        return promos;
    }

}