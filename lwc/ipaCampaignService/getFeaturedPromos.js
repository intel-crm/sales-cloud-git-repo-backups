/**
 * Get Featured Promos for L0 Page
 * @returns {Campaign[]} Campaign Response for Promos Carousel
 * @function getFeaturedPromos
 * @memberof ipaCampaignService
*/

import getPromoData from '@salesforce/apex/PMP_SearchMarketplaceController.getPromotionData';
import LANG from '@salesforce/i18n/lang';

export default async () => {
    let promos = await getPromoData({ userLanguage: LANG });
    promos = promos.map(promo => ({
        image: promo.imageUrl,
        title: promo.title,
        ariaLabel: promo.eventScreenReader,
        description: promo.body,
        linkLabel: promo.ctaLabel,
        linkRecordId: promo.ctaLink,
        linkObjectPage: 'PMP_Marketplace_Event__c'
    }));
    return promos;
}